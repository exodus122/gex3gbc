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

Usage:
    python3 tools/extract_player_sprites.py                # write, and print the
                                                           # main.asm / Makefile text
    python3 tools/extract_player_sprites.py --dry-run      # verify only
    python3 tools/extract_player_sprites.py --patch-main --patch-makefile
    python3 tools/extract_player_sprites.py --no-relink    # leave bank7F.asm alone
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
    """Read back a PNG this script wrote; returns (w, h, indices[y][x])."""
    data = open(path, 'rb').read()
    pos, idat = 8, b''
    width = height = 0
    while pos < len(data):
        length, tag = struct.unpack('>I4s', data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        if tag == b'IHDR':
            width, height, depth, ctype = struct.unpack('>IIBB', body[:10])
            assert (depth, ctype) == (8, 6), 'expected 8-bit RGBA'
        elif tag == b'IDAT':
            idat += body
        elif tag == b'IEND':
            break
        pos += 12 + length
    raw = zlib.decompress(idat)
    stride, back = width * 4, {c: i for i, c in enumerate(RAMP)}
    rows, prev, p = [], bytearray(stride), 0
    for _ in range(height):
        ftype = raw[p]; p += 1
        line = bytearray(raw[p:p + stride]); p += stride
        assert ftype == 0, 'this script only writes unfiltered rows'
        rows.append([back[tuple(line[x * 4:x * 4 + 3])] for x in range(width)])
        prev = line
    return width, height, rows


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


def sheet_rows(tile_count):
    """Rows of tiles in the sheet: the tallest even divisor up to 16, so that whole
    8x16 pieces stay inside one column and the image is not absurdly wide."""
    best = 2
    for h in range(2, 17, 2):
        if tile_count % h == 0:
            best = h
    return best


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
        L.append(f'    INCBIN ".gfx/player_sprites/{png_name(bk, info)[:-4]}.bin"')
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


def rgbgfx_check(png_path, expect):
    exe = shutil.which('rgbgfx')
    if not exe:
        return None
    with tempfile.NamedTemporaryFile(suffix='.bin', delete=False) as tmp:
        tmp_path = tmp.name
    try:
        subprocess.run([exe, '--columns', '-o', tmp_path, png_path],
                       check=True, capture_output=True)
        return open(tmp_path, 'rb').read() == expect
    finally:
        os.unlink(tmp_path)


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
    args = ap.parse_args()

    repo = find_repo(args.repo)
    rom_path = args.rom or os.path.join(repo, 'rom.gb')
    if not os.path.isfile(rom_path):
        sys.exit(f"no ROM at {rom_path} - build one first, or pass --rom")
    rom = open(rom_path, 'rb').read()
    print(f"repo {repo}\nrom  {rom_path} ({len(rom)} bytes)\n")

    sets, banks = parse(rom)
    set_names = {}
    ctext = open(os.path.join(repo, 'src/constants/constants.asm'), encoding='utf-8').read()
    for n in range(SET_COUNT):
        m = re.search(rf'^DEF (PLAYER_GFX_SET_\w+)\s+EQU {n}\s*(?:;|$)', ctext, re.M)
        set_names[n] = m.group(1) if m else f'graphics set {n}'

    total_frames = sum(len(b['frames']) for b in banks.values())
    total_tiles = sum(len(b['tiles']) // 16 for b in banks.values())
    print(f"{len(banks)} banks, {total_frames} frames, {total_tiles} tiles, "
          f"{sum(len(b['tiles']) for b in banks.values())} bytes of graphics")

    # ---- build everything in memory, prove it, then write ----
    planned, failures = [], 0
    for bk in sorted(banks):
        info = banks[bk]
        n_tiles = len(info['tiles']) // 16
        rows_ = sheet_rows(n_tiles)
        cols = n_tiles // rows_
        assert cols * rows_ == n_tiles

        grid = tiles_to_indices(info['tiles'], cols, rows_)
        assert indices_to_tiles(grid, cols, rows_) == info['tiles'], \
            f'bank ${bk:02x}: the tile/pixel conversion does not round-trip'

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
              f"-> {cols * 8}x{rows_ * 8} px sheet   rebuild {'OK' if ok else 'FAILED'}")

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
               if not rgbgfx_check(os.path.join(gfx_dir, png_name(bk, info)), info['tiles'])]
        if bad:
            sys.exit(f"rgbgfx did not reproduce the tile data for bank(s) {', '.join(bad)}")
        print(f"rgbgfx --columns reproduces all {len(planned)} banks byte for byte")

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
        text = open(path, encoding='utf-8').read()
        lo, hi = min(banks), max(banks)
        pat = re.compile(
            rf'SECTION "bank{lo:02x}", ROMX\[\$4000\], BANK\[\${lo:02x}\].*?'
            rf'(?:INCBIN|INCLUDE) "[^"]*bank_?0?{hi:02x}[^"]*"[^\n]*\n?',
            re.S | re.I)
        if not pat.search(text):
            print(f"! could not find the bank ${lo:02x}-${hi:02x} block in main.asm; patch it by hand")
        else:
            open(path, 'w', encoding='utf-8').write(pat.sub(block + '\n', text, count=1))
            print(f"patched {MAIN}")

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
