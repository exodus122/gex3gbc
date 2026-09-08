# gex3gbc

A disassembly of **Gex 3: Deep Pocket Gecko** for Game Boy Color.

The build reproduces the original ROM byte for byte. There are no raw ROM addresses
or bank numbers in the source, so code and data can be moved, resized or reordered
within a bank and everything that points at it follows automatically.

## Requirements

- [RGBDS](https://rgbds.gbdev.io/) (built and verified with 1.0.3)
- Python 3, for the font encoder and the extraction tools in `tools/`

## Building

```sh
make          # assemble and link, producing rom.gb
make check    # build, then verify rom.gb against the original's md5
make clean    # remove build output and generated graphics

make maps-docs    # regenerate the map .asm from the .bin files
make maps-verify  # fail if a generated .asm is stale or does not match its .bin
```

If `rgbasm` and friends are not on your `PATH`: `make RGBDS=/path/to/rgbds/`

## Layout

```
src/main.asm      section map - every bank, in order
src/code/         disassembled code, one file per bank or subsystem
src/data/maps/    map data as .bin, plus the .asm generated from it (see below)
src/data/         Gex's sprite frames, audio
src/gfx/          graphics as PNGs, converted at build time
src/constants/    hardware, memory map and game constants
tools/            extraction and conversion scripts
tools/map_formats.json   record layouts for everything under src/data/maps/
```

## Map data

The map assets under `src/data/maps/` — entity lists, door lists, spawn tables, map edge
transitions, boundary rectangles — are `.bin` files, so `tools/map_editor` can read and
write them directly. Beside each one is an `.asm` that is **generated** from it by
`tools/render_map_asm.py`, and it is the `.asm` that gets assembled: `db ENTITY_TV_BUTTON`
rather than `$11`, `MAP_DOOR_NO_TRIGGER` rather than `$ff`, one record per line, with each
map and level id named.

Some of the annotation is computed rather than stored, so it cannot go stale: each
boundary rectangle is labelled with the maps that select it, read back out of
`map_boundary_indices.bin`, which is how "59 records for 61 maps" stays legible after a
map is repointed.

That gives the data one source of truth and the documentation no way to drift. `grep`
finds every map an entity appears in and the answer is current by construction; a binary
edit made in the map editor becomes a reviewable `git diff` after `make maps-docs`; and
because the generated file is what the ROM is built from, a generator bug fails
`make check` rather than quietly producing a wrong document.

`tools/map_formats.json` is where the record layouts live, and it is the file to edit when
you work out what a byte means — name it once and every generated `.asm` improves. Nothing
in the generator knows a ROM address, so unlike `tools/extract_*.py` (one-shot scripts
that read the original ROM) it is safe to re-run on edited data. `render_map_asm.py` is
the same file as gex2gbc's; only the schema differs.

Pointer tables stay hand-written asm, because they hold `dw` of labels and binning them
would put absolute addresses back in the source.

Do not hand-edit a generated `.asm`; the next build overwrites it. Edit the `.bin`, or the
schema, then `make maps-docs`.

## Shiftability

Where the ROM stores something other than a plain pointer, the source writes the
thing it means rather than the number:

| What the ROM stores | How the source writes it |
|---|---|
| A bank number | `BANK(label)` |
| Bank + address of a map's blobs | `farpointer label` |
| An entity's frame ids | `entity_frames image, objs, 0, 1, 2, ...` |
| An oversized entity's array | `entity_gfx_big ENTITY_*, image, objs` |
| Gex's frame directory rows | `player_frame label` |
| A canned HDMA transfer | `hdma_config src, dest, bytes, bank, vram bank` |

An entity frame id is an index into an array shared by every entity of the same
size, counting from `ENTITY_GFX_BASE_n` in `constants/constants.asm`. The macro
derives it back from the artwork's own label, so those bases are the one place a
sprite bank's layout is written down - the resolvers in `bank00_home.asm` and every
frame id both read them.

Two sites are deliberately left as literals, each commented where it sits:

- `data_02_769f` (`ENTITY_BONUS_STAGE_TIMER`) names bank `$03`, whose `$4000` is
  `call_03_46e0_BgCollision_Update`. Its one frame resolves onto code, not artwork,
  so there is no label to name. Nothing spawns the entity.
- The `gfx_stream`-style bank byte in `.data_00_0aa9_HdmaConfigTable` entries sourced
  from WRAM, which the transfer never reads.

## Extracting graphics

`tools/extract_entity_sprites.py` re-cuts the entity tile banks into per-entity
sheets by resolving every frame the engine can reach. `--dry-run` prints the split,
`--verify` checks each PNG re-encodes to the original ROM bytes.

## Verifying a change

`make check` is the regression test. Anything meant to be cosmetic - renaming,
re-laying-out a table, converting a literal to a label - should leave it passing.
