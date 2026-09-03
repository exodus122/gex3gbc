#!/usr/bin/env python3
"""
Split the entity tile banks into spritesheets, cut where the ENGINE cuts them.

Banks $07-$10, $1D and $1E are currently checked in as blind bank-sized slabs
(image_007_4000.bin and friends). Nothing in the game addresses tiles that way. One
mechanism does, and it says exactly where every picture starts and stops:

  call_00_08f8_StageNextGfxTransfer resolves an entity's live sprite id into a ROM
  address every time its animation frame changes. The bank comes from byte +0 of the
  action's block in bank02_entity_animation_data.asm, and the address from

      base + sprite_id * stride

  where both come from the entity's own row in data_03_58d2_EntitySpriteDescriptors.
  Byte +1 of that row is the entity's size in 8x16 OBJs, and it does double duty: it
  is the HDMA length (rHDMA5 gets count * 2 - 1) AND the index into
  .data_00_0a58_EntityVRAMSourceResolvers, nine little shift-and-add routines that
  each multiply the frame number by one sprite size. So an entity's artwork is a
  contiguous array of fixed-size frames, and its frame ids are indices into it.

  The eight biggest entities go the other way. An action with ACTION_STATE_UNK20 set
  sends its tiles to VRAM bank 1, and those entities are resolved through a small
  (entity id, stride, base) table built into StageNextGfxTransfer instead - the five
  bytes per row after .jr_00_096e_RaiseEntityGfxRequest, indexed by entity id, where
  the base is pre-biased down by one stride because the loop adds before it stops.

So: resolve every (entity, action, frame) the ROM can actually reach, work out which
bytes each entity owns, cut on the boundaries where ownership changes, and name the
file after the owner. Runs that nothing references become image_unused_* so the
partition still covers the banks byte for byte and the ROM still rebuilds.

Nothing here is assumed. The resolvers are recovered by EXECUTING them - the script
interprets the handful of opcodes they are built from - rather than by transcribing
constants out of the disassembly, so they cannot drift out of step with the ROM.

TILE ORDER. Every sprite is an 8x16 OBJ (the game never leaves 8x16 mode) and every
shape in data_03_59ea_SpriteShapeTable numbers its tiles +2 down a column and +2 *
rows across, i.e. a frame is stored column by column - which is why the Makefile
passes --columns for entity_sprites. A frame is therefore drawn as a (width / 8) by
(height / 8) grid of tiles, and both come from the shape's own piece list rather
than from its name: SPRITE_SHAPE_8X128 draws one obj eight times down the screen and
SPRITE_SHAPE_32X64_MIRRORED draws its left half twice, so for those two the shape on
screen is bigger than the artwork behind it.

Usage:
    python3 tools/extract_entity_sprites.py              # write PNGs + main.asm snippet
    python3 tools/extract_entity_sprites.py --verify     # also check png -> bin -> rom
    python3 tools/extract_entity_sprites.py --dry-run    # print the plan, touch nothing
    python3 tools/extract_entity_sprites.py --remove-old # delete the slab PNGs this replaces

Run it from anywhere - paths are resolved from this file. Needs rgbgfx on PATH, the
same one the Makefile uses.
"""

import argparse
import os
import re
import struct
import subprocess
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

ROM_PATH = os.path.join(ROOT, "rom.gb")
CONSTANTS_PATH = os.path.join(ROOT, "src", "constants", "constants.asm")
OUT_ROOT = os.path.join(ROOT, "src", "gfx", "entity_sprites")
SNIPPET_PATH = os.path.join(OUT_ROOT, "main_asm_snippet.inc")

BANK_SIZE = 0x4000
ROMX_BASE = 0x4000
BANK_END = 0x8000
TILE_SIZE = 0x10
OBJ_BYTES = 0x20                       # one 8x16 OBJ is two tiles

# --- ROM addresses, all named after the labels in the disassembly -------------

BANK_HOME = 0x00
BANK_ENTITY_CODE = 0x02
BANK_OAM_CODE = 0x03

ADDR_VRAM_SOURCE_RESOLVERS = 0x0A58    # .data_00_0a58_EntityVRAMSourceResolvers
NUM_RESOLVERS = 9
ADDR_UNK20_TABLE = 0x0973              # the rows after .jr_00_096e_RaiseEntityGfxRequest
UNK20_ROW_SIZE = 5

ADDR_ACTION_JUMP_TABLE = 0x4000        # data_02_4000_EntityActionJumpTable
NUM_ENTITIES = 114
ACTION_ROW_SIZE = 4

ADDR_HDMA_CONFIG_TABLE = 0x0AA9        # .data_00_0aa9_HdmaConfigTable
HDMA_ENTRY_SIZE = 8
HDMA_BANK_MAP_TILESET = 0xFF           # not a fixed address - relocated per map
HDMA_NAMES = ["hud_tiles", "hud_attributes", "hud_tilemap"]

ADDR_SPRITE_DESCRIPTORS = 0x58D2       # data_03_58d2_EntitySpriteDescriptors
ADDR_SPRITE_SHAPE_TABLE = 0x59EA       # data_03_59ea_SpriteShapeTable
SPRITE_SHAPES_PER_ENTITY = 4
OAM_ENTRY_SIZE = 4

SPRITE_DESC_SHAPE_MASK = 0x3F
ACTION_STATE_UNK20 = 0x20

# The entity tile banks. Bank $03 is deliberately absent: ENTITY_BONUS_STAGE_TIMER's
# only block names bank $03, whose $4000 is bank03_bg_collision.asm, so its "frames"
# are code read as tiles. Nothing spawns it, and it is not artwork to extract
GFX_BANKS = [0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x1D, 0x1E]

# Where a bank stops being entity artwork because something else owns the rest of it.
# Only bank $07 has a neighbour: image_007_5b00, a menu image. Every other bank in
# GFX_BANKS ends in padding, and find_bank_end trims that instead
BANK_DATA_END = {0x07: 0x5B00}

MAX_LABEL = 48                         # keep Windows paths comfortably short


# =============================================================================

class Rom:
    def __init__(self, path):
        with open(path, "rb") as f:
            self.data = f.read()
        if len(self.data) < 0x80 * BANK_SIZE:
            raise SystemExit(f"{path}: too small to be the 2 MiB ROM")

    def read(self, bank, addr, n=1):
        off = bank * BANK_SIZE + (addr - ROMX_BASE if addr >= ROMX_BASE else addr)
        return self.data[off:off + n]

    def byte(self, bank, addr):
        return self.read(bank, addr, 1)[0]

    def word(self, bank, addr):
        return struct.unpack("<H", self.read(bank, addr, 2))[0]


# =============================================================================
# Names, pulled out of constants.asm so this file never goes stale
# =============================================================================

def load_names(path):
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            text = f.read()
    except OSError:
        return {}, {}

    entities, shapes = {}, {}
    for name, value in re.findall(r"^DEF\s+(ENTITY_[A-Z0-9_]+)\s+EQU\s+\$([0-9A-Fa-f]+)",
                                  text, re.MULTILINE):
        entities.setdefault(int(value, 16), name)
    for name, value in re.findall(r"^DEF\s+(SPRITE_SHAPE_[A-Z0-9_]+)\s+EQU\s+(\d+)",
                                  text, re.MULTILINE):
        shapes.setdefault(int(value), name)
    return entities, shapes


def slug(name):
    if name.startswith("ENTITY_"):
        name = name[len("ENTITY_"):]
    return name.lower().strip("_") or "unnamed"


def label_and_note(owners, entity_names):
    """A short file label plus the full list for the comment above the INCBIN.

    Sharing is common - five flies on one frame array, two snakes that differ only
    in which way they face - so the label names the first owner or two and counts
    the rest rather than growing a 90-character filename.
    """
    owners = sorted(o for o in owners if isinstance(o, int))
    if not owners:
        return "unused", "not reachable from any action"
    full = [entity_names.get(i, f"entity ${i:02x}") for i in owners]
    for shown in (2, 1):
        label = "_".join(slug(f) for f in full[:shown])
        if len(owners) > shown:
            label += f"_and_{len(owners) - shown}_more"
        if len(label) <= MAX_LABEL:
            break
    return label, ", ".join(full)


# =============================================================================
# The addressing, read back out of the ROM
# =============================================================================

def read_resolvers(rom):
    """OBJ count -> (base address, bytes per frame), by executing each resolver.

    Each one is a run of `srl d / rr e` halvings with `add hl,de` accumulations and
    one `ld de,nn` or `ld hl,nn` base, ending at the shared `ld a,l` tail. Running
    it for frame 0 and frame 1 gives the base and the stride without this script
    having to know which shifts any particular one uses.
    """
    def run(addr, frame):
        d, e, h, l, carry = frame & 0xFF, 0, 0, 0, 0
        pc = BANK_HOME * BANK_SIZE + addr
        for _ in range(64):
            op = rom.data[pc]
            if op == 0xCB:
                op2 = rom.data[pc + 1]
                pc += 2
                if op2 == 0x3A:                      # srl d
                    carry, d = d & 1, d >> 1
                elif op2 == 0x1B:                    # rr e
                    nxt = e & 1
                    e = (carry << 7) | (e >> 1)
                    carry = nxt
                else:
                    raise SystemExit(f"resolver ${addr:04x}: unexpected cb ${op2:02x}")
            elif op == 0x6B: l = e; pc += 1           # ld l,e
            elif op == 0x62: h = d; pc += 1           # ld h,d
            elif op == 0x19:                          # add hl,de
                v = ((h << 8 | l) + (d << 8 | e)) & 0xFFFF
                h, l = v >> 8, v & 0xFF
                pc += 1
            elif op == 0x11:                          # ld de,nn
                e, d = rom.data[pc + 1], rom.data[pc + 2]; pc += 3
            elif op == 0x21:                          # ld hl,nn
                l, h = rom.data[pc + 1], rom.data[pc + 2]; pc += 3
            elif op == 0x18:                          # jr
                off = rom.data[pc + 1]
                pc += 2 + (off - 256 if off > 127 else off)
            elif op == 0x7D:                          # ld a,l - the shared tail
                return (h << 8) | l
            else:
                raise SystemExit(f"resolver ${addr:04x}: unexpected op ${op:02x}")
        raise SystemExit(f"resolver ${addr:04x} did not reach its tail")

    out = {}
    for i in range(NUM_RESOLVERS):
        addr = rom.word(BANK_HOME, ADDR_VRAM_SOURCE_RESOLVERS + i * 2)
        base = run(addr, 0)
        out[i] = (base, run(addr, 1) - base)
    return out


def read_unk20_table(rom):
    """entity id -> (bytes per frame, base). The base is one stride low - the reader
    adds before it tests, so frame 0 lands one stride in."""
    out = {}
    addr = ADDR_UNK20_TABLE
    while rom.byte(BANK_HOME, addr) != 0xFF:
        out[rom.byte(BANK_HOME, addr)] = (rom.word(BANK_HOME, addr + 1),
                                          rom.word(BANK_HOME, addr + 3))
        addr += UNK20_ROW_SIZE
    return out


def read_descriptors(rom):
    """entity id -> (shape id, OBJ count)."""
    out = []
    for i in range(NUM_ENTITIES):
        flags = rom.byte(BANK_OAM_CODE, ADDR_SPRITE_DESCRIPTORS + i * 2)
        out.append((flags & SPRITE_DESC_SHAPE_MASK,
                    rom.byte(BANK_OAM_CODE, ADDR_SPRITE_DESCRIPTORS + i * 2 + 1)))
    return out


def read_shape_columns(rom, shape_id):
    """How many 8-pixel columns of ARTWORK a shape draws from.

    Counted as the distinct X offsets at which a tile number first appears, so a
    shape that repeats one tile down a column (SPRITE_SHAPE_8X128) or mirrors its
    own left half (SPRITE_SHAPE_32X64_MIRRORED) reports the artwork it reads, not
    the rectangle it covers.
    """
    ptr = rom.word(BANK_OAM_CODE,
                   ADDR_SPRITE_SHAPE_TABLE + shape_id * SPRITE_SHAPES_PER_ENTITY * 2)
    count = rom.byte(BANK_OAM_CODE, ptr)
    first_x = {}
    for i in range(count):
        rec = rom.read(BANK_OAM_CODE, ptr + 1 + i * OAM_ENTRY_SIZE, OAM_ENTRY_SIZE)
        x, tile = rec[1], rec[2]
        first_x.setdefault(tile, x)
    return len(set(first_x.values()))


def read_hdma_regions(rom):
    """The fixed ROM sources of .data_00_0aa9_HdmaConfigTable.

    The status bar's tiles, attributes and tilemap live at the end of bank $0c and
    are pulled straight into VRAM by HDMA, so no entity ever names them - which is
    why they would otherwise land in the split as image_unused_*. Entries whose bank
    is HDMA_BANK_MAP_TILESET are relocated against the current map's tileset and
    entries sourced from WRAM are not in ROM at all; neither is a region here.

    Returns [(bank, start, end, name, is_tile_data)]. A destination in the tilemap
    area is one byte per tile rather than 2bpp graphics, so it is written out as a
    plain .bin instead of a sheet.
    """
    out = []
    for i in range(len(HDMA_NAMES)):
        base = ADDR_HDMA_CONFIG_TABLE + i * HDMA_ENTRY_SIZE
        src = rom.word(BANK_HOME, base)
        dest = rom.word(BANK_HOME, base + 2)
        length = rom.word(BANK_HOME, base + 4)
        bank = rom.byte(BANK_HOME, base + 6)
        if bank in (0x00, HDMA_BANK_MAP_TILESET) or src < ROMX_BASE:
            continue
        out.append((bank, src, src + length, HDMA_NAMES[i], dest < 0x9800))
    return out


def read_action_tables(rom):
    """entity id -> [animation block address].

    data_02_4000_EntityActionJumpTable holds one table address per entity id; each
    table is four bytes per action (handler, then the action's animation block).
    A table runs until the next distinct table begins, and the last one until the
    first action handler - the handlers are assembled straight after the tables, so
    the lowest handler address IS where they stop.
    """
    heads = [rom.word(BANK_ENTITY_CODE, ADDR_ACTION_JUMP_TABLE + i * 2)
             for i in range(NUM_ENTITIES)]
    starts = sorted(set(heads))

    handlers = []
    for a, b in zip(starts, starts[1:]):
        handlers += [rom.word(BANK_ENTITY_CODE, r) for r in range(a, b, ACTION_ROW_SIZE)]
    tables_end = min(handlers)

    def end_of(start):
        later = [s for s in starts if s > start]
        return later[0] if later else tables_end

    out = defaultdict(list)
    for eid, head in enumerate(heads):
        for row in range(head, end_of(head), ACTION_ROW_SIZE):
            out[eid].append(rom.word(BANK_ENTITY_CODE, row + 2))
    return out


def read_animation_block(rom, addr):
    """A five-byte header plus the sprite ids the ticker will actually read.

    Several blocks carry spare ids past their declared count - cut animation left in
    place - so the count is what decides where the list ends, not the next label.
    """
    hdr = rom.read(BANK_ENTITY_CODE, addr, 5)
    return dict(bank=hdr[0], pending=hdr[1], flags=hdr[2], ticks=hdr[3],
                ids=list(rom.read(BANK_ENTITY_CODE, addr + 5, hdr[4])))


def frame_location(eid, block, sprite_id, descriptors, resolvers, unk20):
    """(bank, address, bytes) for one frame, or None if the block carries no tiles."""
    if block["bank"] == 0x00:
        return None                      # Gex, and the shared Destroy block
    if block["flags"] & ACTION_STATE_UNK20 and eid in unk20:
        stride, base = unk20[eid]
        return block["bank"], (base + (sprite_id + 1) * stride) & 0xFFFF, stride
    count = descriptors[eid][1]
    if count not in resolvers:
        return None
    base, stride = resolvers[count]
    return block["bank"], (base + sprite_id * stride) & 0xFFFF, stride


# =============================================================================
# The split
# =============================================================================

class Chunk:
    """One output file: a byte range of one bank plus how to draw it."""

    def __init__(self, bank, start, end, name, rows, note="", is_tiles=True):
        self.bank, self.start, self.end = bank, start, end
        self.name, self.rows, self.note = name, rows, note
        self.is_tiles = is_tiles          # False: one byte per tile, not 2bpp graphics

    @property
    def size(self): return self.end - self.start

    @property
    def tiles(self): return self.size // TILE_SIZE

    @property
    def columns(self): return self.tiles // self.rows

    @property
    def stem(self): return f"image_{self.name}_{self.bank:03x}_{self.start:04x}"

    def data(self, rom): return rom.read(self.bank, self.start, self.size)


def find_bank_end(rom, bank, last_referenced):
    """Where this bank's artwork stops.

    A bank either butts up against something else that main.asm names - only bank
    $07 does - or it trails off into the zero padding rgblink adds to fill the bank
    out. Trimming that padding is what keeps the split from emitting sheets that are
    nothing but blank tiles; a tail with any content in it is kept, because
    unreferenced does not mean empty (banks $0c and $0d both end in real leftover
    artwork that no action reaches).
    """
    if bank in BANK_DATA_END:
        return BANK_DATA_END[bank]
    end = BANK_END
    while end > last_referenced and rom.byte(bank, end - 1) == 0:
        end -= 1
    end = last_referenced if end <= last_referenced else (end + TILE_SIZE - 1) // TILE_SIZE * TILE_SIZE
    if any(rom.read(bank, end, BANK_END - end)):
        raise SystemExit(f"bank ${bank:02x}: the tail from ${end:04x} is not all padding")
    return end


def generic_rows(tiles):
    """A readable shape for a run no entity claims: as close to four rows as divides."""
    for r in (4, 2, 1):
        if tiles % r == 0:
            return r
    return 1


def build_chunks(rom, descriptors, entity_names, resolvers, unk20, tables):
    """Every byte of every graphics bank, attributed to whoever reaches it."""
    owners = {b: defaultdict(set) for b in GFX_BANKS}       # bank -> addr -> {eid}
    art_rows = {}                                           # eid -> tile rows per frame
    strays = defaultdict(set)

    # the HDMA-sourced regions own their bytes too, and are named for the transfer
    named = {}                                              # (bank, start) -> (name, is_tiles)
    for bank, start, end, name, is_tiles in read_hdma_regions(rom):
        if bank not in owners:
            continue
        named[(bank, start)] = (name, is_tiles)
        for a in range(start, end):
            owners[bank][a].add(f"hdma:{name}")

    for eid, blocks in tables.items():
        for addr in set(blocks):
            block = read_animation_block(rom, addr)
            for sprite_id in block["ids"]:
                where = frame_location(eid, block, sprite_id, descriptors, resolvers, unk20)
                if where is None:
                    continue
                bank, at, size = where
                if bank not in owners:
                    strays[bank].add(eid)
                    continue
                if at < ROMX_BASE or at + size > BANK_END:
                    raise SystemExit(
                        f"entity ${eid:02x} block ${addr:04x} frame ${sprite_id:02x} "
                        f"resolves to ${bank:02x}:${at:04x}+${size:x}, outside the bank")
                for a in range(at, at + size):
                    owners[bank][a].add(eid)
                cols = read_shape_columns(rom, descriptors[eid][0])
                art_rows[eid] = (size // TILE_SIZE) // cols

    chunks = []
    ends = {}
    for bank in GFX_BANKS:
        used = owners[bank].keys()
        ends[bank] = find_bank_end(rom, bank, max(used) + 1 if used else ROMX_BASE)
        run = None
        runs = []
        for a in range(ROMX_BASE, ends[bank]):
            who = frozenset(owners[bank].get(a, ()))
            if run is not None and run[2] == who:
                run[1] = a + 1
            else:
                run = [a, a + 1, who]
                runs.append(run)
        for start, end, who in runs:
            tag = next((w for w in who if isinstance(w, str)), None)
            if tag is not None:
                name, is_tiles = named[(bank, start)]
                chunks.append(Chunk(bank, start, end, name,
                                    generic_rows((end - start) // TILE_SIZE),
                                    "loaded by HDMA, not by any entity",
                                    is_tiles=is_tiles))
                continue
            label, note = label_and_note(who, entity_names)
            tiles = (end - start) // TILE_SIZE
            if who:
                rows = min(art_rows[e] for e in who if isinstance(e, int))
                if tiles % rows:
                    rows = generic_rows(tiles)
            else:
                rows = generic_rows(tiles)
            chunks.append(Chunk(bank, start, end, label, rows, note))
    return chunks, strays, ends


# =============================================================================
# Checks
# =============================================================================

def check_partition(chunks, ends):
    problems = []
    for bank in GFX_BANKS:
        cursor = ROMX_BASE
        for c in sorted((c for c in chunks if c.bank == bank), key=lambda c: c.start):
            if c.start < cursor:
                problems.append(f"bank ${bank:02x}: {c.stem} overlaps ${cursor:04x}")
            elif c.start > cursor:
                problems.append(f"bank ${bank:02x}: gap ${cursor:04x}-${c.start:04x}")
            cursor = max(cursor, c.end)
        if cursor != ends[bank]:
            problems.append(f"bank ${bank:02x}: covered to ${cursor:04x}, "
                            f"expected ${ends[bank]:04x}")
    return problems


def check_reassembly(rom, chunks, ends):
    problems = []
    for bank in GFX_BANKS:
        mine = sorted((c for c in chunks if c.bank == bank), key=lambda c: c.start)
        if b"".join(c.data(rom) for c in mine) != rom.read(bank, ROMX_BASE, ends[bank] - ROMX_BASE):
            problems.append(f"bank ${bank:02x}: the chunks do not reassemble into the bank")
    return problems


def check_geometry(chunks):
    problems = []
    for c in chunks:
        if c.size % TILE_SIZE:
            problems.append(f"{c.stem}: ${c.size:04x} bytes is not a whole number of tiles")
        elif c.tiles % c.rows:
            problems.append(f"{c.stem}: {c.tiles} tiles does not divide into {c.rows} rows")
    return problems


# =============================================================================
# Output
# =============================================================================

def run_rgbgfx(args):
    try:
        subprocess.run(["rgbgfx"] + args, check=True,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except FileNotFoundError:
        raise SystemExit("rgbgfx not found on PATH - it is the same one the Makefile uses")
    except subprocess.CalledProcessError as exc:
        raise SystemExit(f"rgbgfx {' '.join(args)} failed:\n"
                         f"{exc.stderr.decode(errors='replace')}")


# What the bank-sized split left in src/gfx/entity_sprites: image_<bank>_<addr>.png,
# one per slab. Anything else in there is left alone.
OLD_SHEET = re.compile(r"^image_(%s)_[0-9a-fA-F]{4}\.png$"
                       % "|".join(f"{b:03x}" for b in GFX_BANKS), re.IGNORECASE)


def superseded_pngs():
    try:
        return [os.path.join(OUT_ROOT, n) for n in sorted(os.listdir(OUT_ROOT))
                if OLD_SHEET.match(n)]
    except OSError:
        return []


def write_chunks(rom, chunks, verify):
    os.makedirs(OUT_ROOT, exist_ok=True)
    for c in chunks:
        raw = c.data(rom)
        binpath = os.path.join(OUT_ROOT, c.stem + ".bin")
        pngpath = os.path.join(OUT_ROOT, c.stem + ".png")
        with open(binpath, "wb") as f:
            f.write(raw)
        if not c.is_tiles:
            continue                      # checked in as bytes; there is nothing to draw
        run_rgbgfx(["--reverse", str(c.columns), "--columns", "-o", binpath, pngpath])
        os.remove(binpath)

        if verify:
            check = pngpath + ".check.bin"
            run_rgbgfx(["--columns", "-o", check, pngpath])
            with open(check, "rb") as f:
                got = f.read()
            os.remove(check)
            if got != raw:
                raise SystemExit(f"{c.stem}: png -> bin does not reproduce the ROM bytes "
                                 f"({len(got)} vs {len(raw)} bytes)")


def write_snippet(chunks):
    by_bank = defaultdict(list)
    for c in chunks:
        by_bank[c.bank].append(c)

    lines = [
        "; Generated by tools/extract_entity_sprites.py - paste over the matching",
        "; SECTION blocks in src/main.asm. The .bin files come from src/gfx via the",
        "; Makefile's png -> bin rule, which already passes --columns for entity_sprites.",
        "",
    ]
    for bank in sorted(by_bank):
        lines.append(f'SECTION "bank{bank:02x}", ROMX[$4000], BANK[${bank:02X}]')
        for c in sorted(by_bank[bank], key=lambda c: c.start):
            lines.append(f"    ; ${c.start:04x}  {c.columns}x{c.rows} tiles - {c.note}")
            lines.append(f"{c.stem}:")
            path = (f'.gfx/entity_sprites/{c.stem}.bin' if c.is_tiles
                    else f'gfx/entity_sprites/{c.stem}.bin')
            lines.append(f'    INCBIN "{path}"')
        lines.append("")

    os.makedirs(OUT_ROOT, exist_ok=True)
    with open(SNIPPET_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    return SNIPPET_PATH


# =============================================================================

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", default=ROM_PATH)
    ap.add_argument("--dry-run", action="store_true", help="print the split, write nothing")
    ap.add_argument("--verify", action="store_true",
                    help="re-encode each PNG and check it reproduces the ROM bytes")
    ap.add_argument("--remove-old", action="store_true",
                    help="delete the bank-sized PNGs this split replaces")
    args = ap.parse_args()

    rom = Rom(args.rom)
    entity_names, _shape_names = load_names(CONSTANTS_PATH)
    descriptors = read_descriptors(rom)
    resolvers = read_resolvers(rom)
    unk20 = read_unk20_table(rom)
    tables = read_action_tables(rom)

    chunks, strays, ends = build_chunks(rom, descriptors, entity_names,
                                        resolvers, unk20, tables)

    problems = (check_partition(chunks, ends) + check_reassembly(rom, chunks, ends)
                + check_geometry(chunks))
    if problems:
        print("The split does not cover the banks cleanly:", file=sys.stderr)
        for p in problems:
            print("  " + p, file=sys.stderr)
        return 1

    for bank in sorted({c.bank for c in chunks}):
        mine = sorted((c for c in chunks if c.bank == bank), key=lambda c: c.start)
        print(f'SECTION "bank{bank:02x}"  -  {len(mine)} sheets')
        for c in mine:
            print(f"  ${c.bank:02x}:${c.start:04x}-${c.end:04x}  {c.columns:4d}x{c.rows} tiles"
                  f"  {c.stem}")
    print(f"\n{len(chunks)} sheets total")

    if strays:
        print("\nentities whose blocks name a bank that holds no entity artwork:")
        for bank, eids in sorted(strays.items()):
            who = ", ".join(entity_names.get(e, f"${e:02x}") for e in sorted(eids))
            print(f"  bank ${bank:02x}: {who}")

    stale = superseded_pngs()
    if stale:
        print("\nsuperseded by this split:")
        for path in stale:
            print("  " + os.path.relpath(path, ROOT))
        if not args.remove_old:
            print("  (pass --remove-old to delete them - the Makefile globs every png "
                  "under src/gfx, so leaving them builds stale .bin files)")

    if args.dry_run:
        return 0

    write_chunks(rom, chunks, args.verify)
    if args.remove_old:
        for path in stale:
            os.remove(path)
        print(f"removed {len(stale)} superseded png(s)")
    print("wrote " + os.path.relpath(write_snippet(chunks), ROOT))
    return 0



if __name__ == "__main__":
    sys.exit(main())
