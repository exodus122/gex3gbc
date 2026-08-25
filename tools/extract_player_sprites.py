#!/usr/bin/env python3
"""Split banks $62-$7E of Gex 3 GBC into per-bank frame tables and sprite sheets.

Those 29 banks hold Gex's own animation frames and nothing else, currently checked in
as opaque 16KB blobs (src/data/sprite_data/bank_0XX.bin). Every one of them has the
same shape:

    $4000              frame records, packed and in sprite-id order
       ...             zero padding to a 16-byte boundary
    <tile base>        2bpp tile data, PLAYER_FRAME_PIECE_TILE_BYTES per piece,
                       in the same order as the records
       ...             zero filler to $8000

This script rebuilds that structure from the ROM and writes it back out as

    src/gfx/player_sprites/image_0XX_YYYY.png     the tiles, as an editable sheet
    src/data/sprite_data/bankXX_frames.asm        the records, as macro invocations

The layout is not assumed. It is read out of bank $7F's index tables, which give the
directory of every graphics set, and then checked: records must tile $4000 upwards
with no gap, tile data must be contiguous and in record order, everything outside the
two regions must be zero. If any of that fails the script stops without writing.

Nothing is written until every bank has been reassembled in memory from the exact
bytes that are about to be emitted - macros expanded, PNG decoded back to tiles - and
compared to the ROM. With rgbgfx on PATH the PNGs are additionally round-tripped
through it, which is what the build will actually do.

It also goes the other way. --preview renders each frame assembled, in colour, into
docs/player_frames; --import reads those sheets back into the packed ones. The packed
sheets stay the source of truth, because a composite cannot say which piece owns which
pixel - 201,519 opaque pixels fall inside two or more pieces' 8x16 boxes - so import
takes ownership from the tile data that is already there and only moves the colours.

Usage:
    python3 tools/extract_player_sprites.py                # write, and print the
                                                           # main.asm / Makefile text
    python3 tools/extract_player_sprites.py --dry-run      # verify only
    python3 tools/extract_player_sprites.py --patch-main --patch-makefile
    python3 tools/extract_player_sprites.py --no-relink    # leave bank7F.asm alone
    python3 tools/extract_player_sprites.py --preview      # contact sheets to look at
    python3 tools/extract_player_sprites.py --import       # edited sheets -> src/gfx
"""

import argparse
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib

# ---------------------------------------------------------------------------
# the shape of the data, all of it checked below rather than trusted

BANK_INDEX          = 0x7F     # the bank holding the tables this script reads
MAP_TABLE           = 0x4000   # map id -> byte offset into the set table
SET_TABLE           = 0x403D   # the graphics set records
SET_SIZE            = 5        # base bank, dw frame directory, dw OBJ palettes
SET_COUNT           = 9
ENTRY_SIZE          = 3        # a frame directory entry: bank offset, dw address
HEADER_SIZE         = 5        # a frame header: count, two unread bytes, dw tiles
PIECE_SIZE          = 4        # a piece record: Y, X, attributes, unread
PIECE_TILE_BYTES    = 32       # one 8x16 OBJ is two 16-byte tiles
PAL_BLOCK           = 0x40
PAD_TILES_MIN       = 16       # blank tiles a sheet may add to reach a decent shape
BANK_SIZE           = 0x4000
BANK_BASE           = 0x4000

# src/gfx PNGs in this repo are opaque RGBA in the DMG grey ramp; rgbgfx orders a
# palette by descending luminance, so these four map to indices 0-3 in this order
RAMP = [(0xFF, 0xFF, 0xFF), (0xAA, 0xAA, 0xAA), (0x55, 0x55, 0x55), (0x00, 0x00, 0x00)]

GFX_SUBDIR   = os.path.join('src', 'gfx', 'player_sprites')
DATA_SUBDIR  = os.path.join('src', 'data', 'sprite_data')
BANK7F       = os.path.join(DATA_SUBDIR, 'bank7F.asm')
MACROS       = os.path.join('src', 'code', 'macros', 'macros.asm')
MAIN         = os.path.join('src', 'main.asm')
MAKEFILE     = 'Makefile'

MAKEFILE_RULE = 'src/.gfx/player_sprites/%.bin: rgbgfx += --columns'

CONST_TEXT = """
; ------------------------------------------------------------------
; A frame piece's attribute byte - data/sprite_data/bankXX_frames.asm
; ------------------------------------------------------------------
; call_00_2ce2_Player_BuildSprites ORs this byte into wDC53_Player_OamAttributes on its
; way into OAM, so a piece can raise any OAM attribute bit. Across all 11005 pieces in
; the game the only value other than zero is 1, the CGB OBJ palette number - so what
; the byte does in practice is pick which of Gex's two palettes the piece draws with
DEF PLAYER_PIECE_PAL0            EQU 0    ; his body colours, the same in every set
DEF PLAYER_PIECE_PAL1            EQU 1    ; his per-theme colours, and the only thing
                                          ; that differs between the sets' palettes
DEF PLAYER_FRAME_PIECE_TILE_BYTES EQU 32  ; an 8x16 OBJ, so two 16-byte tiles
"""

MACRO_TEXT = """
; ------------------------------------------------------------------
; Gex's animation frames - see data/sprite_data/bankXX_frames.asm
; ------------------------------------------------------------------
; A frame header. The two middle bytes are stored for every frame in the game and read
; by nothing; they are small numbers in the right range for a size but they do not
; match the frame's piece extents, so what they meant is unknown
MACRO player_frame_header ; piece count, unread, unread, tile data
    db   \\1, \\2, \\3
    dw   \\4
ENDM

; One 8x16 OBJ of a frame. The offsets are relative to Gex's screen position and are
; mirrored by the build for the flipped variants. The attribute byte is OR'd into
; wDC53_Player_OamAttributes, and the only bit any frame in the game sets is palette 1.
; The fourth byte is $00 in all 11005 pieces and is stepped over without being read
MACRO player_piece ; Y offset, X offset, OBJ palette
    db   \\1, \\2, \\3, 0
ENDM
"""


# ---------------------------------------------------------------------------
# minimal PNG, stdlib only

def png_write(path, width_px, height_px, indices):
    """indices[y][x] in 0..3, written as opaque RGBA in the repo's grey ramp."""
    raw = bytearray()
    for y in range(height_px):
        raw.append(0)                                   # filter: none
        row = indices[y]
        for x in range(width_px):
            r, g, b = RAMP[row[x]]
            raw += bytes((r, g, b, 0xFF))

    def chunk(tag, payload):
        return (struct.pack('>I', len(payload)) + tag + payload
                + struct.pack('>I', zlib.crc32(tag + payload) & 0xFFFFFFFF))

    with open(path, 'wb') as fh:
        fh.write(b'\x89PNG\r\n\x1a\n')
        fh.write(chunk(b'IHDR', struct.pack('>IIBBBBB', width_px, height_px, 8, 6, 0, 0, 0)))
        fh.write(chunk(b'IDAT', zlib.compress(bytes(raw), 9)))
        fh.write(chunk(b'IEND', b''))


def png_read_indices(path):
    """A packed sheet back to palette indices, by matching the grey ramp."""
    width, height, rows = png_read_rgba(path)
    back = {c: i for i, c in enumerate(RAMP)}
    out = []
    for y in range(height):
        try:
            out.append([back[px[:3]] for px in rows[y]])
        except KeyError as exc:
            raise SystemExit(f"{path} row {y}: colour {exc.args[0]} is not one of the "
                             f"four greys a packed sheet may use")
    return width, height, out


def tiles_to_indices(tiles, cols, rows_):
    """2bpp tiles, column-major, into a pixel grid - the layout rgbgfx --columns reads."""
    grid = [[0] * (cols * 8) for _ in range(rows_ * 8)]
    for n in range(cols * rows_):
        tx, ty = n // rows_, n % rows_                  # column-major
        tile = tiles[n * 16:n * 16 + 16]
        for y in range(8):
            lo, hi = tile[y * 2], tile[y * 2 + 1]
            for x in range(8):
                bit = 7 - x
                grid[ty * 8 + y][tx * 8 + x] = (((hi >> bit) & 1) << 1) | ((lo >> bit) & 1)
    return grid


def indices_to_tiles(grid, cols, rows_):
    out = bytearray()
    for n in range(cols * rows_):
        tx, ty = n // rows_, n % rows_
        for y in range(8):
            lo = hi = 0
            for x in range(8):
                v = grid[ty * 8 + y][tx * 8 + x]
                lo = (lo << 1) | (v & 1)
                hi = (hi << 1) | ((v >> 1) & 1)
            out += bytes((lo, hi))
    return bytes(out)


def sheet_shape(tile_count):
    """Pick a near-square sheet for this many tiles, padding to fill the rectangle.

    Tile counts like 886 = 2 x 443 have no useful factorisation, so an exact rectangle
    would be 3544x16 pixels. A few blank tiles buy a sensible shape instead. Rows are
    kept even so an 8x16 piece never straddles a column, and the padding goes at the
    END, where column-major order puts it - which is what lets main.asm INCBIN just the
    real prefix and leave the blanks out of the ROM.
    """
    budget = max(PAD_TILES_MIN, tile_count // 32)
    best = None
    for rows_ in range(2, 65, 2):
        cols = -(-tile_count // rows_)                  # ceil
        waste = cols * rows_ - tile_count
        if waste > budget:
            continue
        aspect = max(cols, rows_) / min(cols, rows_)
        key = (round(aspect, 3), waste)
        if best is None or key < best[0]:
            best = (key, cols, rows_)
    if best is None:                                    # no padding fits the budget
        rows_ = sheet_rows_exact(tile_count)
        return tile_count // rows_, rows_
    return best[1], best[2]


def sheet_rows_exact(tile_count):
    best = 2
    for h in range(2, 17, 2):
        if tile_count % h == 0:
            best = h
    return best



# ---------------------------------------------------------------------------
# previews: the frames assembled, in their real colours. These are for looking
# at - the build never reads them. See the note in write_previews.

FONT = {c: r for c, r in zip('0123456789abcdef', [
    (0b111, 0b101, 0b101, 0b101, 0b111), (0b010, 0b110, 0b010, 0b010, 0b111),
    (0b111, 0b001, 0b111, 0b100, 0b111), (0b111, 0b001, 0b111, 0b001, 0b111),
    (0b101, 0b101, 0b111, 0b001, 0b001), (0b111, 0b100, 0b111, 0b001, 0b111),
    (0b111, 0b100, 0b111, 0b101, 0b111), (0b111, 0b001, 0b001, 0b001, 0b001),
    (0b111, 0b101, 0b111, 0b101, 0b111), (0b111, 0b101, 0b111, 0b001, 0b111),
    (0b111, 0b101, 0b111, 0b101, 0b101), (0b110, 0b101, 0b110, 0b101, 0b110),
    (0b111, 0b100, 0b100, 0b100, 0b111), (0b110, 0b101, 0b101, 0b101, 0b110),
    (0b111, 0b100, 0b111, 0b100, 0b111), (0b111, 0b100, 0b111, 0b100, 0b100)])}



PREVIEW_MARGIN = 7          # a strip above each cell for its id, which no piece can reach
PREVIEW_COLUMNS = 16


def preview_layout(banks, set_id, columns=PREVIEW_COLUMNS):
    """Where every frame of a set sits in its contact sheet.

    Extraction and import both call this, so a sheet is always read back on the same
    grid it was drawn on. Cells are sized to the whole set's extent and aligned on
    Gex's origin, which is what makes the animation hold still across the grid.
    """
    frames = sorted((f for b in banks.values() if b['set'] == set_id
                     for f in b['frames']), key=lambda f: f['sid'])
    if not frames:
        return None
    xs = [s8(p[1]) for f in frames for p in f['piece']]
    ys = [s8(p[0]) for f in frames for p in f['piece']]
    x0, y0 = min(xs), min(ys)
    cw = max(xs) + 8 - x0 + 2
    ch = max(ys) + 16 - y0 + 2 + PREVIEW_MARGIN
    rows_n = -(-len(frames) // columns)
    return dict(frames=frames, cw=cw, ch=ch, x0=x0, y0=y0, columns=columns,
                W=cw * columns, H=ch * rows_n)


def frame_origin(lay, n):
    """Top-left of frame n's sprite area, already offset so a piece at (y0,x0) lands there."""
    return ((n % lay['columns']) * lay['cw'] + 1 - lay['x0'],
            (n // lay['columns']) * lay['ch'] + 1 + PREVIEW_MARGIN - lay['y0'])


def frame_tiles(banks, f):
    for b in banks.values():
        for g in b['frames']:
            if g is f:
                at = f['tiles'] - b['tile_base']
                return b['tiles'][at:at + PIECE_TILE_BYTES * f['pieces']]
    raise KeyError('frame not found')


def piece_grid(blob, i):
    """Piece i as a 16x8 grid of palette indices."""
    g = [[0] * 8 for _ in range(16)]
    for half in range(2):
        tile = blob[(i * 2 + half) * 16:(i * 2 + half) * 16 + 16]
        for y in range(8):
            lo, hi = tile[y * 2], tile[y * 2 + 1]
            for x in range(8):
                bit = 7 - x
                g[half * 8 + y][x] = (((hi >> bit) & 1) << 1) | ((lo >> bit) & 1)
    return g


def grid_to_piece(g):
    """The inverse: a 16x8 grid of indices back to 32 bytes of 8x16 tile data."""
    out = bytearray()
    for half in range(2):
        for y in range(8):
            lo = hi = 0
            for x in range(8):
                v = g[half * 8 + y][x]
                lo = (lo << 1) | (v & 1)
                hi = (hi << 1) | ((v >> 1) & 1)
            out += bytes((lo, hi))
    return bytes(out)


def set_palettes(rom, pal_ptr):
    index = rom[BANK_INDEX * BANK_SIZE:(BANK_INDEX + 1) * BANK_SIZE]
    out = []
    for n in range(2):
        out.append([cgb_rgb(index[pal_ptr - BANK_BASE + 8 * n + 2 * k]
                            | (index[pal_ptr - BANK_BASE + 8 * n + 2 * k + 1] << 8))
                    for k in range(4)])
    return out


def png_write_rgb(path, width, height, rows):
    """rows of (r, g, b) or (r, g, b, a) tuples, written as 8-bit RGBA."""
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for px in rows[y]:
            raw += bytes(px) if len(px) == 4 else bytes(px) + b'\xff'

    def chunk(tag, payload):
        return (struct.pack('>I', len(payload)) + tag + payload
                + struct.pack('>I', zlib.crc32(tag + payload) & 0xFFFFFFFF))

    with open(path, 'wb') as fh:
        fh.write(b'\x89PNG\r\n\x1a\n')
        fh.write(chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)))
        fh.write(chunk(b'IDAT', zlib.compress(bytes(raw), 9)))
        fh.write(chunk(b'IEND', b''))


def png_read_rgba(path):
    """Any 8-bit RGBA PNG, filters included - an editor will not write them unfiltered."""
    data = open(path, 'rb').read()
    pos, idat, width, height = 8, b'', 0, 0
    while pos < len(data):
        length, tag = struct.unpack('>I4s', data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        if tag == b'IHDR':
            width, height, depth, ctype = struct.unpack('>IIBB', body[:10])
            if (depth, ctype) != (8, 6):
                raise SystemExit(f"{path}: needs to be 8-bit RGBA, got depth {depth} "
                                 f"colour type {ctype} - re-export with alpha")
        elif tag == b'IDAT':
            idat += body
        elif tag == b'IEND':
            break
        pos += 12 + length
    raw = zlib.decompress(idat)
    stride, bpp = width * 4, 4
    rows, prev, p = [], bytearray(stride), 0
    for _ in range(height):
        ftype = raw[p]; p += 1
        line = bytearray(raw[p:p + stride]); p += stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if ftype == 1:   line[x] = (line[x] + a) & 0xFF
            elif ftype == 2: line[x] = (line[x] + b) & 0xFF
            elif ftype == 3: line[x] = (line[x] + (a + b) // 2) & 0xFF
            elif ftype == 4:
                pp = a + b - c
                pa, pb, pc = abs(pp - a), abs(pp - b), abs(pp - c)
                line[x] = (line[x] + (a if (pa <= pb and pa <= pc)
                                      else (b if pb <= pc else c))) & 0xFF
        rows.append([tuple(line[x * 4:x * 4 + 4]) for x in range(width)])
        prev = line
    return width, height, rows


def cgb_rgb(word):
    """BGR555 as the Game Boy Color stores it, widened to 8 bits per channel."""
    return tuple(((word >> s) & 31) << 3 | ((word >> s) & 31) >> 2 for s in (0, 5, 10))


def write_previews(out_dir, rom, sets, banks, set_names, columns=PREVIEW_COLUMNS):
    """One contact sheet per graphics set: every frame assembled from its pieces, in the
    OBJ palettes bank $7F gives that set.

    Transparent pixels are written with alpha 0, which is what makes the sheet
    importable again - see import_previews. The id label lives in a PREVIEW_MARGIN
    strip above each cell that no piece box can reach, so reading a cell back never
    picks up the label.

    src/gfx sheets cannot have this layout: the ROM's tile order is the artist's piece
    order rather than anything positional, and 201,519 opaque pixels fall inside two or
    more pieces' boxes, so an image alone cannot say which piece owns them. That is
    exactly why import needs the packed sheet as well as this one.
    """
    os.makedirs(out_dir, exist_ok=True)
    written = []
    for set_id, (_, _, pal_ptr) in enumerate(sets):
        lay = preview_layout(banks, set_id, columns)
        if lay is None:
            continue
        pals = set_palettes(rom, pal_ptr)
        W, H = lay['W'], lay['H']
        img = [[(0, 0, 0, 0)] * W for _ in range(H)]

        # cell separators and the id label, both inside the margin strip
        for n in range(len(lay['frames'])):
            cx, cy = (n % columns) * lay['cw'], (n // columns) * lay['ch']
            for x in range(cx, min(cx + lay['cw'], W)):
                img[cy][x] = (0xD8, 0xD8, 0xE0, 0xFF)
            label = f"{lay['frames'][n]['sid']:02x}"
            for ci, ch_ in enumerate(label):
                for ry in range(5):
                    bits = FONT[ch_][ry]
                    for rx in range(3):
                        if (bits >> (2 - rx)) & 1:
                            y, x = cy + 1 + ry, cx + 1 + ci * 4 + rx
                            if y < H and x < W:
                                img[y][x] = (0x88, 0x88, 0x99, 0xFF)

        for n, f in enumerate(lay['frames']):
            ox, oy = frame_origin(lay, n)
            blob = frame_tiles(banks, f)
            for i, (py, px, attr, _) in enumerate(f['piece']):
                colours = pals[1 if attr else 0]
                g = piece_grid(blob, i)
                for dy in range(16):
                    for dx in range(8):
                        v = g[dy][dx]
                        if v == 0:
                            continue                     # OBJ colour 0 is transparent
                        Y, X = oy + s8(py) + dy, ox + s8(px) + dx
                        if 0 <= Y < H and 0 <= X < W:
                            img[Y][X] = colours[v] + (0xFF,)

        name = f"set{set_id}_{set_names[set_id].replace('PLAYER_GFX_SET_', '').lower()}.png"
        png_write_rgb(os.path.join(out_dir, name), W, H, img)
        written.append((name, len(lay['frames']), W, H))
    return written


def import_previews(preview_dir, rom, sets, banks, set_names, columns=PREVIEW_COLUMNS):
    """Read edited contact sheets back into the packed tile data.

    A composite cannot say which piece owns a pixel, so ownership comes from the tile
    data that is already there: a piece keeps exactly the pixels it is currently opaque
    at and picks up its new colour from the sheet. A pixel whose colour has not changed
    keeps its existing palette index, so an untouched sheet imports back to identical
    bytes even where a palette holds the same colour twice.

    Newly painted pixels - transparent before, opaque now - go to the covering piece
    whose centre is nearest. Anything painted outside every piece's box would need a new
    piece in the frame table, so it is reported rather than quietly dropped.

    Returns {bank: new tile bytes} for the banks that changed, plus a list of warnings.
    """
    where = {}                                          # frame -> (bank, offset in tiles)
    for bk, b in banks.items():
        for f in b['frames']:
            where[f['addr'], bk] = (bk, f['tiles'] - b['tile_base'])
    tiles = {bk: bytearray(b['tiles']) for bk, b in banks.items()}
    touched, warnings = {}, []

    for set_id, (_, _, pal_ptr) in enumerate(sets):
        lay = preview_layout(banks, set_id, columns)
        if lay is None:
            continue
        name = f"set{set_id}_{set_names[set_id].replace('PLAYER_GFX_SET_', '').lower()}.png"
        path = os.path.join(preview_dir, name)
        if not os.path.isfile(path):
            warnings.append(f"{name}: not found - set {set_id} left alone")
            continue
        W, H, img = png_read_rgba(path)
        if (W, H) != (lay['W'], lay['H']):
            warnings.append(f"{name}: is {W}x{H}, expected {lay['W']}x{lay['H']}; "
                            f"a resized sheet cannot be imported")
            continue
        pals = set_palettes(rom, pal_ptr)
        # reversed() so the LOWEST index wins when a palette repeats a colour
        rev = [{c: k for k, c in reversed(list(enumerate(p))) if k} for p in pals]

        for n, f in enumerate(lay['frames']):
            ox, oy = frame_origin(lay, n)
            bk, at = where[f['addr'], next(k for k in banks
                                           if f in banks[k]['frames'])]
            blob = bytes(tiles[bk][at:at + PIECE_TILE_BYTES * f['pieces']])
            grids = [piece_grid(blob, i) for i in range(f['pieces'])]
            pos = [(s8(p[0]), s8(p[1])) for p in f['piece']]

            def at_px(y, x):
                Y, X = oy + y, ox + x
                return img[Y][X] if 0 <= Y < H and 0 <= X < W else (0, 0, 0, 0)

            owner, boxed = {}, set()
            for i, g in enumerate(grids):
                for dy in range(16):
                    for dx in range(8):
                        key = (pos[i][0] + dy, pos[i][1] + dx)
                        boxed.add(key)
                        if g[dy][dx]:
                            owner[key] = i

            for key in boxed - set(owner):               # newly painted, inside a box
                if at_px(*key)[3] == 0:
                    continue
                covers = [j for j, (qy, qx) in enumerate(pos)
                          if 0 <= key[0] - qy < 16 and 0 <= key[1] - qx < 8]
                owner[key] = min(covers, key=lambda j: (pos[j][0] + 8 - key[0]) ** 2
                                 + (pos[j][1] + 4 - key[1]) ** 2)

            for i, g in enumerate(grids):
                pal = 1 if f['piece'][i][2] else 0
                for dy in range(16):
                    for dx in range(8):
                        key = (pos[i][0] + dy, pos[i][1] + dx)
                        if owner.get(key) != i:
                            g[dy][dx] = 0
                            continue
                        px = at_px(*key)
                        if px[3] == 0:
                            g[dy][dx] = 0
                            continue
                        rgb = px[:3]
                        if g[dy][dx] and pals[pal][g[dy][dx]] == rgb:
                            continue                     # unchanged, keep the index
                        if rgb in rev[pal]:
                            g[dy][dx] = rev[pal][rgb]
                        else:
                            warnings.append(
                                f"{name}: frame ${f['sid']:02x} pixel ({ox + key[1]},"
                                f"{oy + key[0]}) is #{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}, "
                                f"not a colour of OBJ palette {pal} - left as it was")

            # anything painted in this cell but outside every piece box is unrepresentable
            stray = 0
            for y in range(PREVIEW_MARGIN + 1, lay['ch']):
                for x in range(1, lay['cw']):
                    gy = (n // columns) * lay['ch'] + y
                    gx = (n % columns) * lay['cw'] + x
                    if img[gy][gx][3] and (gy - oy, gx - ox) not in boxed:
                        stray += 1
            if stray:
                warnings.append(f"{name}: frame ${f['sid']:02x} has {stray} painted pixel(s) "
                                f"outside every piece - that needs a new player_piece in "
                                f"bank{bk:02x}_frames.asm, so they were dropped")

            new = b''.join(grid_to_piece(g) for g in grids)
            if new != blob:
                tiles[bk][at:at + len(new)] = new
                touched[bk] = touched.get(bk, 0) + 1

    return ({bk: bytes(tiles[bk]) for bk in touched},
            {bk: touched[bk] for bk in touched}, warnings)


# ---------------------------------------------------------------------------

def s8(v):
    return v - 256 if v >= 128 else v


def parse(rom):
    """Read bank $7F's tables, then every frame they reach. Checks as it goes."""
    assert len(rom) >= (BANK_INDEX + 1) * BANK_SIZE, 'ROM is too small'

    def bank(n):
        return rom[n * BANK_SIZE:(n + 1) * BANK_SIZE]

    idx = bank(BANK_INDEX)
    rd8 = lambda a: idx[a - BANK_BASE]
    rd16 = lambda a: idx[a - BANK_BASE] | (idx[a - BANK_BASE + 1] << 8)

    sets = [(rd8(SET_TABLE + SET_SIZE * n),
             rd16(SET_TABLE + SET_SIZE * n + 1),
             rd16(SET_TABLE + SET_SIZE * n + 3)) for n in range(SET_COUNT)]
    dirs = sorted(s[1] for s in sets)
    pals = sorted(s[2] for s in sets)
    assert dirs[0] == SET_TABLE + SET_SIZE * SET_COUNT, \
        'the frame directories do not start where the set table ends'
    assert pals == [pals[0] + PAL_BLOCK * k for k in range(SET_COUNT)], \
        'the palette blocks are not contiguous'
    assert dirs[-1] < pals[0], 'a frame directory runs into the palettes'
    end = {s: (dirs[i + 1] if i + 1 < SET_COUNT else pals[0]) for i, s in enumerate(dirs)}

    banks = {}
    for set_id, (base, dptr, _) in enumerate(sets):
        count = (end[dptr] - dptr) // ENTRY_SIZE
        assert (end[dptr] - dptr) % ENTRY_SIZE == 0, f'set {set_id} directory is ragged'
        assert (rd8(dptr), rd16(dptr + 1)) == (0, 0), f'set {set_id} entry 0 is not null'
        for sid in range(1, count):
            off, addr = rd8(dptr + ENTRY_SIZE * sid), rd16(dptr + ENTRY_SIZE * sid + 1)
            assert BANK_BASE <= addr < BANK_BASE + BANK_SIZE, \
                f'set {set_id} frame {sid} points outside a bank'
            blob = bank(base + off)
            at = addr - BANK_BASE
            pieces = blob[at]
            banks.setdefault(base + off, []).append(dict(
                set=set_id, sid=sid, addr=addr, pieces=pieces,
                unread=(blob[at + 1], blob[at + 2]),
                tiles=blob[at + 3] | (blob[at + 4] << 8),
                piece=[tuple(blob[at + HEADER_SIZE + PIECE_SIZE * i:
                                  at + HEADER_SIZE + PIECE_SIZE * (i + 1)])
                       for i in range(pieces)]))

    out = {}
    for bk in sorted(banks):
        frames = sorted(banks[bk], key=lambda f: f['addr'])
        assert len({f['set'] for f in frames}) == 1, f'bank ${bk:02x} mixes graphics sets'
        ids = [f['sid'] for f in frames]
        assert ids == list(range(ids[0], ids[0] + len(ids))), \
            f'bank ${bk:02x} sprite ids are not contiguous'

        cursor = BANK_BASE
        for f in frames:
            assert f['addr'] == cursor, \
                f"bank ${bk:02x}: expected a frame at ${cursor:04x}, found one at ${f['addr']:04x}"
            assert all(p[3] == 0 for p in f['piece']), \
                f"bank ${bk:02x} frame {f['sid']} has a non-zero fourth piece byte"
            cursor += HEADER_SIZE + PIECE_SIZE * f['pieces']
        records_end = cursor

        by_tiles = sorted(frames, key=lambda f: f['tiles'])
        assert [f['addr'] for f in by_tiles] == [f['addr'] for f in frames], \
            f'bank ${bk:02x}: tile data is not in the same order as the records'
        tile_base, cursor = by_tiles[0]['tiles'], by_tiles[0]['tiles']
        for f in by_tiles:
            assert f['tiles'] == cursor, \
                f"bank ${bk:02x}: tile data is not contiguous at ${cursor:04x}"
            cursor += PIECE_TILE_BYTES * f['pieces']
        tiles_end = cursor

        blob = bank(bk)
        assert records_end <= tile_base, f'bank ${bk:02x}: records overlap the tiles'
        assert set(blob[records_end - BANK_BASE:tile_base - BANK_BASE]) <= {0}, \
            f'bank ${bk:02x}: the gap before the tiles is not zero'
        assert set(blob[tiles_end - BANK_BASE:]) <= {0}, \
            f'bank ${bk:02x}: there is data after the tiles'
        out[bk] = dict(frames=frames, set=frames[0]['set'], records_end=records_end,
                       tile_base=tile_base, tiles_end=tiles_end,
                       tiles=blob[tile_base - BANK_BASE:tiles_end - BANK_BASE])
    return sets, out


# ---------------------------------------------------------------------------

def frame_label(bk, f):
    return f"data_{bk:02x}_{f['addr']:04x}_PlayerFrame_{f['sid']:03d}"


def tiles_label(bk, info):
    return f"data_{bk:02x}_{info['tile_base']:04x}_PlayerTiles"


def png_name(bk, info):
    return f"image_{bk:03x}_{info['tile_base']:04x}.png"


def emit_frames_asm(bk, info, set_names):
    f0, f1 = info['frames'][0], info['frames'][-1]
    n_tiles = len(info['tiles']) // 16
    L = [
        '; ==================================================================',
        f"; Bank ${bk:02x}. Gex's animation frames {f0['sid']} to {f1['sid']} of "
        f"{set_names[info['set']]}.",
        ';',
        '; Generated by tools/extract_player_sprites.py. The bank splits in two: these',
        f"; records from $4000 to ${info['records_end'] - 1:04x}, then "
        f"{n_tiles} tiles of graphics from "
        f"${info['tile_base']:04x} to ${info['tiles_end'] - 1:04x}, which main.asm",
        '; INCBINs straight after this file. Both halves are in sprite-id order.',
        ';',
        '; The sheet is padded with blank tiles to reach a square-ish shape. They sit at',
        "; the end, so main.asm's INCBIN takes a length and leaves them out of the ROM.",
        ';',
        '; A frame is reached from data/sprite_data/bank7F.asm, which documents the',
        "; lookup and the format; code/bank00_player_sprites.asm is what walks it.",
        '; ==================================================================',
        '',
    ]
    for f in info['frames']:
        off = f['tiles'] - info['tile_base']
        L.append(f"{frame_label(bk, f)}:")
        L.append(f"    player_frame_header {f['pieces']:3d}, ${f['unread'][0]:02x}, "
                 f"${f['unread'][1]:02x}, {tiles_label(bk, info)} + ${off:04x}")
        for y, x, attr, _ in f['piece']:
            pal = 'PLAYER_PIECE_PAL0' if attr == 0 else 'PLAYER_PIECE_PAL1'
            L.append(f"    player_piece {s8(y):4d}, {s8(x):4d}, {pal}")
        L.append('')
    L += [
        f"    ds   ${info['tile_base']:04x} - @, 0"
        f"{'':<20}; the bank pads to a 16-byte boundary here",
        f"{tiles_label(bk, info)}:",
        '; INCBINd by main.asm - see the header above',
    ]
    return '\n'.join(L) + '\n'


def assemble_frames(bk, info):
    """The bytes emit_frames_asm's macros expand to, so the result can be checked."""
    out = bytearray()
    for f in info['frames']:
        out += bytes((f['pieces'], f['unread'][0], f['unread'][1],
                      f['tiles'] & 0xFF, f['tiles'] >> 8))
        for y, x, attr, _ in f['piece']:
            out += bytes((y, x, attr, 0))
    out += bytes(info['tile_base'] - info['records_end'])
    return bytes(out)


def main_asm_block(banks, sets):
    L = []
    for bk in sorted(banks):
        info = banks[bk]
        L.append(f'SECTION "bank{bk:02x}", ROMX[$4000], BANK[${bk:02x}]')
        L.append(f'INCLUDE "data/sprite_data/bank{bk:02x}_frames.asm"')
        n = len(info['tiles'])
        tail = (f', 0, ${n:04x}{"":<6}; {n // 16} tiles, without the sheet\'s blank '
                f'padding' if info['pad'] else '')
        L.append(f'    INCBIN ".gfx/player_sprites/{png_name(bk, info)[:-4]}.bin"{tail}')
    return '\n'.join(L)


# ---------------------------------------------------------------------------

def relink_bank7f(text, banks, sets):
    """Point bank7F.asm's frame directory rows at the labels this script just made.

    A row only says "this many banks past the base", so the base has to come from the
    directory the row is in. The set table gives directory address -> base bank, and
    each directory in the file is introduced by a label carrying its address, so the
    two are matched on that rather than by tracking state down the file.
    """
    by_addr = {}
    for bk, info in banks.items():
        for f in info['frames']:
            by_addr[(bk, f['addr'])] = frame_label(bk, f)
    base_of_dir = {dptr: base for base, dptr, _ in sets}

    out, base, n, skipped = [], None, 0, 0
    for line in text.split('\n'):
        m = re.match(r'data_7f_([0-9a-f]{4})_PlayerFrames_\w*:', line)
        if m:
            base = base_of_dir.get(int(m.group(1), 16))
        elif re.match(r'[A-Za-z_.][\w.]*:', line):
            base = None                       # some other table started
        m = re.match(r'(\s*player_frame )\$([0-9a-f]{2}), \$([0-9a-f]{4})\s*(;.*)?$', line)
        if m and int(m.group(3), 16) == 0:
            # the null entry keeps its zeros, but line up with the rows below it
            head = f"{m.group(1)}${m.group(2)}, ${m.group(3)}"
            line = f"{head:<66}{m.group(4) or ''}".rstrip()
        elif m:
            if base is None:
                skipped += 1
            else:
                key = (base + int(m.group(2), 16), int(m.group(3), 16))
                if key not in by_addr:
                    skipped += 1
                else:
                    label = by_addr[key]
                    head = f"{m.group(1)}${m.group(2)}, {label}"
                    line = f"{head:<66}{m.group(4) or ''}".rstrip()
                    n += 1
        out.append(line)
    return '\n'.join(out), n, skipped


def rgbgfx_check(png_path, expect, pad_bytes):
    exe = shutil.which('rgbgfx')
    if not exe:
        return None
    with tempfile.NamedTemporaryFile(suffix='.bin', delete=False) as tmp:
        tmp_path = tmp.name
    try:
        subprocess.run([exe, '--columns', '-o', tmp_path, png_path],
                       check=True, capture_output=True)
        got = open(tmp_path, 'rb').read()
        return got[:len(expect)] == expect and got[len(expect):] == bytes(pad_bytes)
    finally:
        os.unlink(tmp_path)


def run_import(repo, rom, sets, banks, set_names, args):
    """--import: edited contact sheets -> the packed sheets the build reads."""
    gfx_dir = os.path.join(repo, GFX_SUBDIR)
    prev_dir = os.path.join(repo, args.import_dir)
    if not os.path.isdir(prev_dir):
        sys.exit(f"no contact sheets in {args.import_dir} - run with --preview first")

    # the packed sheets are the ownership reference, so they have to agree with the ROM
    shapes, stale = {}, []
    for bk, info in banks.items():
        n_tiles = len(info['tiles']) // 16
        cols, rows_ = sheet_shape(n_tiles)
        shapes[bk] = (cols, rows_)
        path = os.path.join(gfx_dir, png_name(bk, info))
        if not os.path.isfile(path):
            sys.exit(f"{path} is missing - run the extract first")
        w, h, grid = png_read_indices(path)
        if (w, h) != (cols * 8, rows_ * 8) or \
                indices_to_tiles(grid, cols, rows_)[:len(info['tiles'])] != info['tiles']:
            stale.append(f"${bk:02x}")
    if stale:
        sys.exit(f"the packed sheet(s) for bank(s) {', '.join(stale)} do not match "
                 f"rom.gb.\nrom.gb has to be current for import to know which piece owns "
                 f"which pixel - run make, then try again")
    print(f"packed sheets agree with {os.path.basename(args.rom or 'rom.gb')}\n")

    new_tiles, counts, warnings = import_previews(prev_dir, rom, sets, banks, set_names)
    for w_ in warnings:
        print(f"  ! {w_}")
    if not new_tiles:
        print("\nno pixels changed - the contact sheets import back to the bytes "
              "already in src/gfx")
        return
    if args.dry_run:
        print(f"\n--dry-run: {sum(counts.values())} frame(s) across {len(new_tiles)} "
              f"bank(s) would change; nothing written")
        return
    for bk, blob in sorted(new_tiles.items()):
        cols, rows_ = shapes[bk]
        pad = cols * rows_ - len(blob) // 16
        grid = tiles_to_indices(blob + bytes(16 * pad), cols, rows_)
        png_write(os.path.join(gfx_dir, png_name(bk, banks[bk])), cols * 8, rows_ * 8, grid)
        print(f"  bank ${bk:02x}: {counts[bk]} frame(s) rewritten")
    print(f"\nupdated {len(new_tiles)} packed sheet(s) - run make to fold them into the ROM")


def find_repo(start):
    here = os.path.abspath(start)
    while True:
        if os.path.isfile(os.path.join(here, MAIN)):
            return here
        parent = os.path.dirname(here)
        if parent == here:
            sys.exit(f"could not find a repo with {MAIN} at or above {start}")
        here = parent


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--repo', default='.', help='repo root (default: search upwards)')
    ap.add_argument('--rom', default=None, help='ROM to read (default: <repo>/rom.gb)')
    ap.add_argument('--dry-run', action='store_true', help='verify and report, write nothing')
    ap.add_argument('--no-relink', action='store_true', help='leave bank7F.asm alone')
    ap.add_argument('--patch-main', action='store_true', help='rewrite the bank $62-$7e section of main.asm')
    ap.add_argument('--patch-makefile', action='store_true', help='add the rgbgfx --columns rule')
    ap.add_argument('--skip-rgbgfx', action='store_true', help='do not round-trip through rgbgfx')
    ap.add_argument('--import', nargs='?', dest='import_dir',
                    const=os.path.join('docs', 'player_frames'),
                    default=None, metavar='DIR',
                    help='the other direction: read edited contact sheets from DIR back '
                         'into the packed sheets in src/gfx. Nothing else is written')
    ap.add_argument('--preview', nargs='?', const=os.path.join('docs', 'player_frames'),
                    default=None, metavar='DIR',
                    help='also render assembled contact sheets, in colour, for looking '
                         'at (default DIR: docs/player_frames). The build never reads these')
    args = ap.parse_args()

    repo = find_repo(args.repo)
    rom_path = args.rom or os.path.join(repo, 'rom.gb')
    if not os.path.isfile(rom_path):
        sys.exit(f"no ROM at {rom_path} - build one first, or pass --rom")
    rom = open(rom_path, 'rb').read()
    print(f"repo {repo}\nrom  {rom_path} ({len(rom)} bytes)\n")

    sets, banks = parse(rom)
    ctext = open(os.path.join(repo, 'src/constants/constants.asm'), encoding='utf-8').read()
    # PLAYER_GFX_SET_SIZE and _PALETTE_FIELD share the prefix and would shadow sets 5
    # and 3, so take only the run of DEFs whose values ascend 0, 1, 2 ... in file order
    set_names, want = {}, 0
    for m in re.finditer(r'^DEF (PLAYER_GFX_SET_\w+)\s+EQU (\d+)\b', ctext, re.M):
        if int(m.group(2)) == want:
            set_names[want] = m.group(1)
            want += 1
            if want == SET_COUNT:
                break
    for n in range(SET_COUNT):
        set_names.setdefault(n, f'graphics set {n}')

    if args.import_dir:
        return run_import(repo, rom, sets, banks, set_names, args)

    total_frames = sum(len(b['frames']) for b in banks.values())
    total_tiles = sum(len(b['tiles']) // 16 for b in banks.values())
    print(f"{len(banks)} banks, {total_frames} frames, {total_tiles} tiles, "
          f"{sum(len(b['tiles']) for b in banks.values())} bytes of graphics")

    # ---- build everything in memory, prove it, then write ----
    planned, failures = [], 0
    for bk in sorted(banks):
        info = banks[bk]
        n_tiles = len(info['tiles']) // 16
        cols, rows_ = sheet_shape(n_tiles)
        pad = cols * rows_ - n_tiles
        assert pad >= 0
        padded = info['tiles'] + bytes(16 * pad)

        grid = tiles_to_indices(padded, cols, rows_)
        assert indices_to_tiles(grid, cols, rows_) == padded, \
            f'bank ${bk:02x}: the tile/pixel conversion does not round-trip'
        info['pad'] = pad

        asm = emit_frames_asm(bk, info, set_names)
        rebuilt = assemble_frames(bk, info) + info['tiles']
        rebuilt += bytes(BANK_SIZE - len(rebuilt))
        original = rom[bk * BANK_SIZE:(bk + 1) * BANK_SIZE]
        ok = rebuilt == original
        if not ok:
            failures += 1
            d = next(i for i, (x, y) in enumerate(zip(rebuilt, original)) if x != y)
            print(f"  bank ${bk:02x}: REBUILD DIFFERS at ${BANK_BASE + d:04x}")
        planned.append((bk, info, asm, grid, cols, rows_))
        print(f"  bank ${bk:02x}: {len(info['frames']):3d} frames, {n_tiles:3d} tiles "
              f"-> {cols * 8}x{rows_ * 8} px sheet (+{pad:2d} blank)   "
              f"rebuild {'OK' if ok else 'FAILED'}")

    if failures:
        sys.exit(f"\n{failures} bank(s) did not reassemble to the ROM - nothing written")
    print("\nall 29 banks reassemble to the ROM byte for byte")

    gfx_dir = os.path.join(repo, GFX_SUBDIR)
    data_dir = os.path.join(repo, DATA_SUBDIR)
    if args.dry_run:
        print("\n--dry-run: nothing written\n")
    else:
        os.makedirs(gfx_dir, exist_ok=True)
        os.makedirs(data_dir, exist_ok=True)
        for bk, info, asm, grid, cols, rows_ in planned:
            p = os.path.join(gfx_dir, png_name(bk, info))
            png_write(p, cols * 8, rows_ * 8, grid)
            w, h, back = png_read_indices(p)
            assert (w, h) == (cols * 8, rows_ * 8) and back == grid, \
                f'{p} did not read back as written'
            with open(os.path.join(data_dir, f'bank{bk:02x}_frames.asm'), 'w',
                      encoding='utf-8') as fh:
                fh.write(asm)
        print(f"wrote {len(planned)} sheets to {GFX_SUBDIR}")
        print(f"wrote {len(planned)} frame tables to {DATA_SUBDIR}")

    # ---- the check that matters: what rgbgfx will actually produce ----
    if args.skip_rgbgfx or args.dry_run:
        print("(skipped the rgbgfx round-trip)")
    elif not shutil.which('rgbgfx'):
        print("! rgbgfx is not on PATH, so the sheets were not round-tripped through it")
    else:
        bad = [f"${bk:02x}" for bk, info, *_ in planned
               if not rgbgfx_check(os.path.join(gfx_dir, png_name(bk, info)),
                                   info['tiles'], 16 * info['pad'])]
        if bad:
            sys.exit(f"rgbgfx did not reproduce the tile data for bank(s) {', '.join(bad)}")
        print(f"rgbgfx --columns reproduces all {len(planned)} banks byte for byte")

    # ---- previews ----
    if args.preview and not args.dry_run:
        out_dir = os.path.join(repo, args.preview)
        for name, n, w, h in write_previews(out_dir, rom, sets, banks, set_names):
            print(f"  preview {name:<34} {n:3d} frames  {w}x{h}")
        print(f"wrote contact sheets to {args.preview}")

    # ---- constants and macros ----
    consts_path = os.path.join(repo, 'src/constants/constants.asm')
    if 'DEF PLAYER_PIECE_PAL0' in ctext:
        print("constants.asm already has PLAYER_PIECE_PAL0 / PAL1")
    elif not args.dry_run:
        with open(consts_path, 'a', encoding='utf-8') as fh:
            fh.write(CONST_TEXT)
        print("appended PLAYER_PIECE_PAL0 / PAL1 to constants.asm")

    macros_path = os.path.join(repo, MACROS)
    have = open(macros_path, encoding='utf-8').read()
    if 'MACRO player_frame_header' in have:
        print("macros.asm already has player_frame_header / player_piece")
    elif not args.dry_run:
        with open(macros_path, 'a', encoding='utf-8') as fh:
            fh.write(MACRO_TEXT)
        print("appended player_frame_header / player_piece to macros.asm")

    # ---- bank7F relink ----
    b7f = os.path.join(repo, BANK7F)
    if args.no_relink:
        print("--no-relink: bank7F.asm untouched")
    elif not os.path.isfile(b7f):
        print(f"! {BANK7F} not found, skipping the relink")
    else:
        text = open(b7f, encoding='utf-8').read()
        new, n, skipped = relink_bank7f(text, banks, sets)
        if skipped:
            sys.exit(f"bank7F.asm: {skipped} frame rows could not be matched to a "
                     f"label - not rewriting the file")
        if n == 0:
            print("bank7F.asm: no bare-address player_frame rows left to relink")
        elif args.dry_run:
            print(f"bank7F.asm: {n} rows would be relinked")
        else:
            open(b7f, 'w', encoding='utf-8').write(new)
            print(f"bank7F.asm: {n} frame directory rows now name their frame")

    # ---- the text the user has to place ----
    block = main_asm_block(banks, sets)
    print("\n" + "=" * 72)
    print("main.asm - replace the bank $62-$7e SECTION/INCBIN lines with:")
    print("=" * 72)
    print(block)
    print("=" * 72)
    print(f"Makefile - add next to the other rgbgfx rules:\n\n    {MAKEFILE_RULE}\n")

    if args.patch_main and not args.dry_run:
        path = os.path.join(repo, MAIN)
        lines = open(path, encoding='utf-8').read().split('\n')
        lo, hi = min(banks), max(banks)
        sec = re.compile(r'\s*SECTION\s+"[^"]*",\s*ROMX\[\$4000\],\s*BANK\[\$([0-9a-fA-F]{2})\]')

        start = next((i for i, l in enumerate(lines)
                      if (m := sec.match(l)) and int(m.group(1), 16) == lo), None)
        if start is None:
            print(f"! main.asm has no SECTION for bank ${lo:02x}; place the block by hand")
        else:
            # the block runs to the first section that is not one of ours, so a second
            # run replaces exactly what the first one wrote
            end = len(lines)
            for i in range(start + 1, len(lines)):
                m = sec.match(lines[i])
                if m and not (lo <= int(m.group(1), 16) <= hi):
                    end = i
                    break
            seen = {int(m.group(1), 16) for l in lines[start:end] if (m := sec.match(l))}
            if seen != set(banks):
                print(f"! the bank ${lo:02x}-${hi:02x} run in main.asm covers "
                      f"{len(seen)} banks, not {len(banks)}; place the block by hand")
            else:
                lines[start:end] = block.split('\n')
                open(path, 'w', encoding='utf-8').write('\n'.join(lines))
                print(f"patched {MAIN} ({end - start} lines replaced)")

    if args.patch_makefile and not args.dry_run:
        path = os.path.join(repo, MAKEFILE)
        text = open(path, encoding='utf-8').read()
        if MAKEFILE_RULE in text:
            print("Makefile already has the rule")
        else:
            anchor = 'src/.gfx/entity_sprites/%.bin: rgbgfx += --columns'
            if anchor not in text:
                print("! could not find the rgbgfx rules in the Makefile; add the line by hand")
            else:
                open(path, 'w', encoding='utf-8').write(
                    text.replace(anchor, anchor + '\n' + MAKEFILE_RULE, 1))
                print(f"patched {MAKEFILE}")

    print("\nThe old src/data/sprite_data/bank_062.bin .. bank_07e.bin are now unused "
          "and can be deleted once the ROM still builds.")


if __name__ == '__main__':
    main()
