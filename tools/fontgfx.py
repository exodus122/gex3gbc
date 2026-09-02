#!/usr/bin/env python3
"""
Convert the bank $01 menu fonts between .bin and .png, in both directions.

These fonts cannot go through rgbgfx. They are not 8x8 tile data: the font descriptor
table at data_01_5b77_FontDescriptors (menus/bank01_menu_gfx.asm) gives each font a
height in PIXELS - 7, 8, 8 and 16 - and call_01_4875_Text_Render addresses a glyph as

    stride    = width_cols * height_px * 2
    glyph_ptr = base + index * stride

with no special case for index 0, so there is no header and no tile grid.

font0_text_small is the one that rgbgfx cannot describe at all: its glyphs are SEVEN
pixels tall, so 1008 bytes is 504 rows, which is not a multiple of 8. The old
src/gfx/text/image_001_5c79.png was an 8px-tall strip that happened to contain the
right 1008 bytes, but every glyph past the first was sliced and shifted down the
strip - correct data, unreadable picture.

The other three are describable but were not laid out helpfully:
font1_text_large was an 8x9 grid read COLUMN MAJOR, so its glyphs ran downwards.
All four now decode to one horizontal row of glyphs, which is also what gex2 does.

Within a glyph the layout is COLUMN MAJOR - all height_px rows of column 0, then all
height_px rows of column 1 - and each row is two bytes of ordinary GB 2bpp
(plane 0, plane 1). For the three one-column fonts that degenerates to plain
sequential rows; only font3_password_large has a second column.

The PNG side is a single row of glyphs, no padding, 4-colour indexed. Decode and
encode are exact inverses; `verify-all` asserts that on the real files.

    python3 fontgfx.py decode  --cols 2 --height 16 -o out.png in.bin
    python3 fontgfx.py encode  --cols 2 --height 16 -o out.bin in.png
    python3 fontgfx.py decode-all          # bootstrap every known font to .png
    python3 fontgfx.py verify-all          # assert png -> bin is byte exact

Stdlib only, by design - the build should not need a pip install.
"""

import argparse
import os
import struct
import sys
import zlib

# basename -> (width in 8px columns, height in pixels)
# The order is the font id in data_01_5b77_FontDescriptors.
FONTS = {
    "font0_text_small": (1, 7),      # 72 glyphs - the proportional face most menus use
    "font1_text_large": (1, 8),      # 72 glyphs - the same set, one pixel taller
    "font2_password_small": (1, 8),  # 33 glyphs - the password alphabet
    "font3_password_large": (2, 16), # 33 glyphs - the same alphabet at 2x2 tiles
}

FONT_DIR = os.path.join("src", "gfx", "text")

# index 0 .. 3 of the 2bpp value. Index 0 is the background.
PALETTE = [(0xFF, 0xFF, 0xFF), (0xAA, 0xAA, 0xAA), (0x55, 0x55, 0x55), (0x00, 0x00, 0x00)]

PNG_SIG = b"\x89PNG\r\n\x1a\n"


# --------------------------------------------------------------------------- PNG out

def png_write(path, width, height, indices, palette):
    def chunk(tag, data):
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    raw = b"".join(
        b"\x00" + bytes(indices[y * width:(y + 1) * width]) for y in range(height)
    )
    plte = b"".join(bytes(c) for c in palette)

    blob = PNG_SIG
    blob += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0))
    blob += chunk(b"PLTE", plte)
    blob += chunk(b"IDAT", zlib.compress(raw, 9))
    blob += chunk(b"IEND", b"")

    with open(path, "wb") as fh:
        fh.write(blob)


# ---------------------------------------------------------------------------- PNG in

def _unfilter(raw, width, height, depth, channels):
    bpp = max(1, (depth * channels) // 8)
    stride = (width * channels * depth + 7) // 8
    need = (stride + 1) * height
    if len(raw) < need:
        raise ValueError(f"truncated image data: got {len(raw)}, need {need}")

    out = bytearray()
    prev = bytearray(stride)
    pos = 0
    for y in range(height):
        ft = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride

        if ft == 0:
            pass
        elif ft == 1:
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 0xFF
        elif ft == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ft == 3:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif ft == 4:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                c = prev[i - bpp] if i >= bpp else 0
                b = prev[i]
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        else:
            raise ValueError(f"unknown PNG filter type {ft} on row {y}")

        out += line
        prev = line

    return bytes(out), stride


def _unpack_samples(row, width, depth, channels):
    """Return `width * channels` samples from one unfiltered scanline."""
    if depth == 8:
        return list(row[:width * channels])
    if depth in (1, 2, 4) and channels == 1:
        per_byte = 8 // depth
        mask = (1 << depth) - 1
        vals = []
        for i in range(width):
            byte = row[i // per_byte]
            shift = 8 - depth * (i % per_byte + 1)
            vals.append((byte >> shift) & mask)
        return vals
    raise ValueError(f"unsupported bit depth {depth} with {channels} channel(s)")


def png_read_rgb(path):
    """Read a PNG into (width, height, [ (r,g,b), ... ]). 8-bit, non-interlaced."""
    with open(path, "rb") as fh:
        blob = fh.read()

    if not blob.startswith(PNG_SIG):
        raise ValueError("not a PNG file")

    pos = len(PNG_SIG)
    width = height = depth = ctype = None
    interlace = 0
    plte = []
    idat = bytearray()

    while pos < len(blob):
        (length,) = struct.unpack(">I", blob[pos:pos + 4])
        tag = blob[pos + 4:pos + 8]
        data = blob[pos + 8:pos + 8 + length]
        pos += 12 + length

        if tag == b"IHDR":
            width, height, depth, ctype, _comp, _filt, interlace = struct.unpack(
                ">IIBBBBB", data
            )
        elif tag == b"PLTE":
            plte = [tuple(data[i:i + 3]) for i in range(0, len(data), 3)]
        elif tag == b"IDAT":
            idat += data
        elif tag == b"IEND":
            break

    if width is None:
        raise ValueError("missing IHDR")
    if interlace:
        raise ValueError(
            "interlaced PNG is not supported - re-save without Adam7 interlacing"
        )

    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(ctype)
    if channels is None:
        raise ValueError(f"unsupported PNG colour type {ctype}")
    if ctype != 3 and depth != 8:
        raise ValueError(
            f"unsupported bit depth {depth} for colour type {ctype} - re-save as 8-bit"
        )

    raw, stride = _unfilter(zlib.decompress(bytes(idat)), width, height, depth, channels)

    pixels = []
    for y in range(height):
        row = raw[y * stride:(y + 1) * stride]
        samples = _unpack_samples(row, width, depth, channels)
        for x in range(width):
            if ctype == 3:
                idx = samples[x]
                if idx >= len(plte):
                    raise ValueError(f"palette index {idx} out of range at {x},{y}")
                pixels.append(plte[idx])
            elif ctype == 0:
                v = samples[x]
                pixels.append((v, v, v))
            elif ctype == 4:
                v = samples[x * 2]
                pixels.append((v, v, v))
            elif ctype == 2:
                pixels.append(tuple(samples[x * 3:x * 3 + 3]))
            else:  # 6
                pixels.append(tuple(samples[x * 4:x * 4 + 3]))

    return width, height, pixels


# ------------------------------------------------------------------------- transforms

def bin_to_indices(data, cols, height):
    """-> (glyph_count, sheet_width, flat list of palette indices)"""
    stride = cols * height * 2
    if stride == 0:
        raise ValueError("cols and height must both be nonzero")
    count, leftover = divmod(len(data), stride)
    if leftover:
        raise ValueError(
            f"{len(data)} bytes is not a whole number of {stride}-byte glyphs "
            f"({leftover} left over) - wrong --cols/--height?"
        )

    gw = cols * 8
    sheet_w = gw * count
    out = [0] * (sheet_w * height)

    for g in range(count):
        base = g * stride
        for c in range(cols):
            for r in range(height):
                off = base + (c * height + r) * 2
                p0, p1 = data[off], data[off + 1]
                dst = r * sheet_w + g * gw + c * 8
                for x in range(8):
                    bit = 7 - x
                    out[dst + x] = ((p0 >> bit) & 1) | (((p1 >> bit) & 1) << 1)

    return count, sheet_w, out


def indices_to_bin(indices, sheet_w, cols, height):
    gw = cols * 8
    if sheet_w % gw:
        raise ValueError(
            f"image width {sheet_w} is not a multiple of the {gw}px glyph width"
        )
    count = sheet_w // gw
    out = bytearray()

    for g in range(count):
        for c in range(cols):
            for r in range(height):
                p0 = p1 = 0
                src = r * sheet_w + g * gw + c * 8
                for x in range(8):
                    v = indices[src + x]
                    bit = 7 - x
                    p0 |= (v & 1) << bit
                    p1 |= ((v >> 1) & 1) << bit
                out.append(p0)
                out.append(p1)

    return bytes(out)


def pixels_to_indices(pixels, palette):
    lookup = {rgb: i for i, rgb in enumerate(palette)}
    out = []
    unknown = {}
    for i, px in enumerate(pixels):
        idx = lookup.get(px)
        if idx is None:
            unknown[px] = unknown.get(px, 0) + 1
            idx = 0
        out.append(idx)
    if unknown:
        listing = ", ".join(
            f"#{r:02X}{g:02X}{b:02X} x{n}"
            for (r, g, b), n in sorted(unknown.items(), key=lambda kv: -kv[1])[:6]
        )
        raise ValueError(
            f"image contains {len(unknown)} colour(s) outside the 4-colour palette: "
            f"{listing}. Re-save using exactly "
            + ", ".join(f"#{r:02X}{g:02X}{b:02X}" for r, g, b in palette)
        )
    return out


# ------------------------------------------------------------------------- operations

def do_decode(src, dst, cols, height):
    with open(src, "rb") as fh:
        data = fh.read()
    count, sheet_w, indices = bin_to_indices(data, cols, height)
    png_write(dst, sheet_w, height, indices, PALETTE)
    print(f"{src} -> {dst}  ({count} glyphs, {cols*8}x{height} each)")


def do_encode(src, dst, cols, height):
    width, png_h, pixels = png_read_rgb(src)
    if png_h != height:
        raise ValueError(
            f"{src} is {png_h}px tall but this font's glyphs are {height}px"
        )
    indices = pixels_to_indices(pixels, PALETTE)
    data = indices_to_bin(indices, width, cols, height)
    with open(dst, "wb") as fh:
        fh.write(data)
    print(f"{src} -> {dst}  ({len(data)} bytes)")


def _known(name):
    if name not in FONTS:
        raise SystemExit(f"unknown font '{name}'; known: {', '.join(sorted(FONTS))}")
    return FONTS[name]


def do_decode_all(root):
    for name, (cols, height) in sorted(FONTS.items()):
        src = os.path.join(root, FONT_DIR, name + ".bin")
        dst = os.path.join(root, FONT_DIR, name + ".png")
        if not os.path.exists(src):
            print(f"skip {name}: {src} not found", file=sys.stderr)
            continue
        do_decode(src, dst, cols, height)


def do_verify_all(root):
    """Assert encode and decode are exact inverses on the real font images.

    The .bin files are build output and live under src/.gfx, so comparing against
    them would be circular. Instead this encodes each .png, decodes the result back
    to pixels, and re-encodes: if the two transforms are inverses the second .bin is
    identical to the first, and any glyph the PNG cannot represent shows up as a
    mismatch. A reference .bin sitting next to the .png - an extracted original, say
    - is compared too when one is there.

    What proves the bytes are actually RIGHT is `make check`, which builds the ROM
    through this script and compares its md5.
    """
    ok = True
    for name, (cols, height) in sorted(FONTS.items()):
        pngp = os.path.join(root, FONT_DIR, name + ".png")
        if not os.path.exists(pngp):
            print(f"FAIL {name}: {pngp} not found", file=sys.stderr)
            ok = False
            continue

        width, png_h, pixels = png_read_rgb(pngp)
        if png_h != height:
            print(f"FAIL {name}: png is {png_h}px tall, expected {height}")
            ok = False
            continue

        first = indices_to_bin(pixels_to_indices(pixels, PALETTE), width, cols, height)
        count, sheet_w, indices = bin_to_indices(first, cols, height)
        again = indices_to_bin(indices, sheet_w, cols, height)

        if again != first or sheet_w != width:
            print(f"FAIL {name}: decode(encode(png)) does not round-trip")
            ok = False
            continue

        note = ""
        refp = os.path.join(root, FONT_DIR, name + ".bin")
        if os.path.exists(refp):
            with open(refp, "rb") as fh:
                original = fh.read()
            if original == first:
                note = ", matches the reference .bin"
            else:
                bad = [i for i in range(min(len(original), len(first)))
                       if original[i] != first[i]]
                where = f"first at 0x{bad[0]:X}" if bad else "length differs"
                print(f"FAIL {name}: does not match {refp} ({where})")
                ok = False
                continue

        print(f"OK   {name}: {count} glyphs, {len(first)} bytes round-trip exactly{note}")
    return ok


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(here)

    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    sub = ap.add_subparsers(dest="cmd", required=True)

    for cmd in ("decode", "encode"):
        p = sub.add_parser(cmd)
        p.add_argument("input")
        p.add_argument("-o", "--output", required=True)
        p.add_argument("--cols", type=int, help="glyph width in 8px columns")
        p.add_argument("--height", type=int, help="glyph height in pixels")
        p.add_argument("--font", help="look up --cols/--height by font name instead")

    sub.add_parser("decode-all")
    sub.add_parser("verify-all")

    args = ap.parse_args()

    if args.cmd == "decode-all":
        do_decode_all(root)
        return 0

    if args.cmd == "verify-all":
        return 0 if do_verify_all(root) else 1

    if args.font:
        cols, height = _known(args.font)
    elif args.cols and args.height:
        cols, height = args.cols, args.height
    else:
        stem = os.path.splitext(os.path.basename(args.input))[0]
        if stem in FONTS:
            cols, height = FONTS[stem]
        else:
            raise SystemExit("need --cols and --height (or a recognised filename)")

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)

    if args.cmd == "decode":
        do_decode(args.input, args.output, cols, height)
    else:
        do_encode(args.input, args.output, cols, height)
    return 0


if __name__ == "__main__":
    sys.exit(main())
