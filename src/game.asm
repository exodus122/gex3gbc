;; Disassembled with BadBoy Disassembler: https://github.com/daid/BadBoy

INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/charmaps.inc"
INCLUDE "include/constants.inc"
INCLUDE "memory.asm"

INCLUDE "bank00_home.asm"
INCLUDE "bank01_menus.asm"
INCLUDE "bank02_objects.asm"
INCLUDE "bank03_collision_graphics.asm"
INCLUDE "./audio_engine/bank04_audio1.asm"
INCLUDE "./audio_engine/bank05_audio2.asm"

SECTION "bank06", ROMX[$4000], BANK[$06]
image_06_4000:
    INCBIN "./.gfx/menus/image_006_4000.bin"
image_06_4000_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_006_4000_bgmap_tile_ids.bin"
image_06_4000_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_006_4000_palette_ids.bin"
image_06_47a6:
    INCBIN "./.gfx/menus/image_006_47a6.bin"
image_06_47a6_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_006_47a6_bgmap_tile_ids.bin"
image_06_47a6_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_006_47a6_palette_ids.bin"
image_06_4a1e:
    INCBIN "./.gfx/menus/image_006_4a1e.bin"
image_06_4a1e_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_006_4a1e_bgmap_tile_ids.bin"
image_06_4a1e_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_006_4a1e_palette_ids.bin"
image_06_59ce:
    INCBIN "./.gfx/menus/image_006_59ce.bin"
image_06_59ce_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_006_59ce_bgmap_tile_ids.bin"
image_06_59ce_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_006_59ce_palette_ids.bin"
image_06_6086:
    INCBIN "./.gfx/menus/image_006_6086.bin"
image_06_6086_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_006_6086_bgmap_tile_ids.bin"
image_06_6086_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_006_6086_palette_ids.bin"
image_06_67c6:
    INCBIN "./.gfx/menus/image_006_67c6.bin"
image_06_67c6_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_006_67c6_bgmap_tile_ids.bin"
image_06_67c6_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_006_67c6_palette_ids.bin"

INCLUDE "bank07.asm"

SECTION "bank08", ROMX[$4000], BANK[$08]
image_08_4000:
    INCBIN "./.gfx/object_sprites/image_008_4000.bin"

SECTION "bank09", ROMX[$4000], BANK[$09]
image_09_4000:
    INCBIN "./.gfx/object_sprites/image_009_4000.bin"

SECTION "bank0a", ROMX[$4000], BANK[$0A]
image_0a_4000:
    INCBIN "./.gfx/object_sprites/image_00a_4000.bin"
image_0a_6000:
    INCBIN "./.gfx/object_sprites/image_00a_6000.bin"

SECTION "bank0b", ROMX[$4000], BANK[$0B]
image_0b_4000:
    INCBIN "./.gfx/object_sprites/image_00b_4000.bin"

SECTION "bank0c", ROMX[$4000], BANK[$0C]
image_0c_4000:
    INCBIN "./.gfx/object_sprites/image_00c_4000.bin"

SECTION "bank0d", ROMX[$4000], BANK[$0D]
image_0d_4000:
    INCBIN "./.gfx/object_sprites/image_00d_4000.bin"

SECTION "bank0e", ROMX[$4000], BANK[$0E]
image_0e_4000:
    INCBIN "./.gfx/object_sprites/image_00e_4000.bin"

SECTION "bank0f", ROMX[$4000], BANK[$0F]
image_0f_4000:
    INCBIN "./.gfx/object_sprites/image_00f_4000.bin"

SECTION "bank10", ROMX[$4000], BANK[$10]
image_10_4000:
    INCBIN "./.gfx/object_sprites/image_010_4000.bin"

SECTION "bank11", ROMX[$4000], BANK[$11]
image_11_4000:
    INCBIN "./.gfx/menus/image_011_4000.bin"
image_11_4000_bgmap_tile_ids:
    INCBIN "./gfx/menus/bgmap_tile_ids/image_011_4000_bgmap_tile_ids.bin"
image_11_4000_palette_ids:
    INCBIN "./gfx/menus/palette_ids/image_011_4000_palette_ids.bin"

SECTION "bank12", ROMX[$4000], BANK[$12]
SECTION "bank13", ROMX[$4000], BANK[$13]
SECTION "bank14", ROMX[$4000], BANK[$14]
SECTION "bank15", ROMX[$4000], BANK[$15]
SECTION "bank16", ROMX[$4000], BANK[$16]
SECTION "bank17", ROMX[$4000], BANK[$17]
SECTION "bank18", ROMX[$4000], BANK[$18]
SECTION "bank19", ROMX[$4000], BANK[$19]
SECTION "bank1A", ROMX[$4000], BANK[$1A]
SECTION "bank1B", ROMX[$4000], BANK[$1B]

SECTION "bank1C", ROMX[$4000], BANK[$1C]
bank_01c_text:
    INCBIN "./data/bank_01c_text.bin"

SECTION "bank1d", ROMX[$4000], BANK[$1D]
image_1d_4000:
    INCBIN "./.gfx/object_sprites/image_01d_4000.bin"

SECTION "bank1e", ROMX[$4000], BANK[$1E]
image_1e_4000:
    INCBIN "./.gfx/object_sprites/image_01e_4000.bin"

SECTION "bank1f", ROMX[$4000], BANK[$1F]
image_01f_00.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_00.bin"
image_01f_00_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_00_palette_ids.bin"
image_01f_00_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_00_palette.bin"
image_01f_01.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_01.bin"
image_01f_01_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_01_palette_ids.bin"
image_01f_01_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_01_palette.bin"
image_01f_02.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_02.bin"
image_01f_02_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_02_palette_ids.bin"
image_01f_02_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_02_palette.bin"
image_01f_03.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_03.bin"
image_01f_03_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_03_palette_ids.bin"
image_01f_03_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_03_palette.bin"
image_01f_04.bin:
    INCBIN "../.gfx/secondary_tilesets/image_01f_04.bin"
image_01f_04_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_04_palette_ids.bin"
image_01f_04_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_04_palette.bin"
image_01f_05.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_05.bin"
image_01f_05_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_05_palette_ids.bin"
image_01f_05_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_05_palette.bin"
image_01f_06.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_06.bin"
image_01f_06_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_06_palette_ids.bin"
image_01f_06_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_06_palette.bin"
image_01f_07.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_07.bin"
image_01f_07_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_07_palette_ids.bin"
image_01f_07_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_07_palette.bin"
image_01f_08.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_08.bin"
image_01f_08_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_08_palette_ids.bin"
image_01f_08_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_08_palette.bin"
image_01f_09.bin:
    INCBIN "./.gfx/secondary_tilesets/image_01f_09.bin"
image_01f_09_palette_ids.bin:
    INCBIN "../gfx/secondary_tilesets/palette_ids/image_01f_09_palette_ids.bin"
image_01f_09_palette.bin:
    INCBIN "../gfx/secondary_tilesets/palettes/image_01f_09_palette.bin"

SECTION "bank20", ROMX[$4000], BANK[$20]
INCLUDE "bank21.asm"
INCLUDE "bank22.asm"
INCLUDE "bank23.asm"

SECTION "bank24", ROMX[$4000], BANK[$24]
INCBIN "../data/blockset_data/bank_024.bin"
SECTION "bank25", ROMX[$4000], BANK[$25]
INCBIN "../data/blockset_data/bank_025.bin"
SECTION "bank26", ROMX[$4000], BANK[$26]
INCBIN "../data/blockset_data/bank_026.bin"
SECTION "bank27", ROMX[$4000], BANK[$27]
INCBIN "../data/blockset_data/bank_027.bin"
SECTION "bank28", ROMX[$4000], BANK[$28]
INCBIN "../data/blockset_data/bank_028.bin"

SECTION "bank29", ROMX[$4000], BANK[$29]
SECTION "bank2A", ROMX[$4000], BANK[$2A]
SECTION "bank2B", ROMX[$4000], BANK[$2B]
SECTION "bank2C", ROMX[$4000], BANK[$2C]
SECTION "bank2D", ROMX[$4000], BANK[$2D]

SECTION "bank2e", ROMX[$4000], BANK[$2e]
INCBIN "../data/map_blockset_override/bank_02e.bin"
SECTION "bank2f", ROMX[$4000], BANK[$2f]
INCBIN "../data/maps/bank_02f.bin"
SECTION "bank30", ROMX[$4000], BANK[$30]
INCBIN "../data/map_collision/bank_030.bin"
SECTION "bank31", ROMX[$4000], BANK[$31]
INCBIN "../data/map_blockset_override/bank_031.bin"
SECTION "bank32", ROMX[$4000], BANK[$32]
INCBIN "../data/maps/bank_032.bin"
SECTION "bank33", ROMX[$4000], BANK[$33]
INCBIN "../data/map_collision/bank_033.bin"
SECTION "bank34", ROMX[$4000], BANK[$34]
INCBIN "../data/map_blockset_override/bank_034.bin"
SECTION "bank35", ROMX[$4000], BANK[$35]
INCBIN "../data/maps/bank_035.bin"
SECTION "bank36", ROMX[$4000], BANK[$36]
INCBIN "../data/map_collision/bank_036.bin"
SECTION "bank37", ROMX[$4000], BANK[$37]
INCBIN "../data/map_blockset_override/bank_037.bin"
SECTION "bank38", ROMX[$4000], BANK[$38]
INCBIN "../data/maps/bank_038.bin"
SECTION "bank39", ROMX[$4000], BANK[$39]
INCBIN "../data/map_collision/bank_039.bin"
SECTION "bank3a", ROMX[$4000], BANK[$3a]
INCBIN "../data/map_blockset_override/bank_03a.bin"
SECTION "bank3b", ROMX[$4000], BANK[$3b]
INCBIN "../data/maps/bank_03b.bin"
SECTION "bank3c", ROMX[$4000], BANK[$3c]
INCBIN "../data/map_collision/bank_03c.bin"
SECTION "bank3d", ROMX[$4000], BANK[$3d]
INCBIN "../data/map_blockset_override/bank_03d.bin"
SECTION "bank3e", ROMX[$4000], BANK[$3e]
INCBIN "../data/maps/bank_03e.bin"
SECTION "bank3f", ROMX[$4000], BANK[$3f]
INCBIN "../data/map_collision/bank_03f.bin"

SECTION "bank40", ROMX[$4000], BANK[$40]
INCBIN "../.gfx/tilesets/tileset_040.bin"
SECTION "bank41", ROMX[$4000], BANK[$41]
INCBIN "../.gfx/tilesets/tileset_041.bin"
SECTION "bank42", ROMX[$4000], BANK[$42]
INCBIN "../.gfx/tilesets/tileset_042.bin"
SECTION "bank43", ROMX[$4000], BANK[$43]
INCBIN "../.gfx/tilesets/tileset_043.bin"
SECTION "bank44", ROMX[$4000], BANK[$44]
INCBIN "../.gfx/tilesets/tileset_044.bin"
SECTION "bank45", ROMX[$4000], BANK[$45]
INCBIN "../.gfx/tilesets/tileset_045.bin"
SECTION "bank46", ROMX[$4000], BANK[$46]
INCBIN "../.gfx/tilesets/tileset_046.bin"
SECTION "bank47", ROMX[$4000], BANK[$47]
INCBIN "../.gfx/tilesets/tileset_047.bin"
SECTION "bank48", ROMX[$4000], BANK[$48]
INCBIN "../.gfx/tilesets/tileset_048.bin"
SECTION "bank49", ROMX[$4000], BANK[$49]
INCBIN "../.gfx/tilesets/tileset_049.bin"
SECTION "bank4a", ROMX[$4000], BANK[$4a]
INCBIN "../.gfx/tilesets/tileset_04a.bin"
SECTION "bank4b", ROMX[$4000], BANK[$4b]
INCBIN "../.gfx/tilesets/tileset_04b.bin"
SECTION "bank4c", ROMX[$4000], BANK[$4c]
INCBIN "../.gfx/tilesets/tileset_04c.bin"
SECTION "bank4d", ROMX[$4000], BANK[$4d]
INCBIN "../.gfx/tilesets/tileset_04d.bin"
SECTION "bank4e", ROMX[$4000], BANK[$4e]
INCBIN "../.gfx/tilesets/tileset_04e.bin"
SECTION "bank4f", ROMX[$4000], BANK[$4f]
INCBIN "../.gfx/tilesets/tileset_04f.bin"

SECTION "bank50", ROMX[$4000], BANK[$50]
SECTION "bank51", ROMX[$4000], BANK[$51]
SECTION "bank52", ROMX[$4000], BANK[$52]
SECTION "bank53", ROMX[$4000], BANK[$53]
SECTION "bank54", ROMX[$4000], BANK[$54]
SECTION "bank55", ROMX[$4000], BANK[$55]
SECTION "bank56", ROMX[$4000], BANK[$56]
SECTION "bank57", ROMX[$4000], BANK[$57]
SECTION "bank58", ROMX[$4000], BANK[$58]
SECTION "bank59", ROMX[$4000], BANK[$59]
SECTION "bank5A", ROMX[$4000], BANK[$5A]
SECTION "bank5B", ROMX[$4000], BANK[$5B]
SECTION "bank5C", ROMX[$4000], BANK[$5C]
SECTION "bank5D", ROMX[$4000], BANK[$5D]
SECTION "bank5E", ROMX[$4000], BANK[$5E]
SECTION "bank5F", ROMX[$4000], BANK[$5F]
SECTION "bank60", ROMX[$4000], BANK[$60]
SECTION "bank61", ROMX[$4000], BANK[$61]
INCLUDE "bank62.asm"
INCLUDE "bank63.asm"
INCLUDE "bank64.asm"
INCLUDE "bank65.asm"
INCLUDE "bank66.asm"
INCLUDE "bank67.asm"
INCLUDE "bank68.asm"
INCLUDE "bank69.asm"
INCLUDE "bank6A.asm"
INCLUDE "bank6B.asm"
INCLUDE "bank6C.asm"
INCLUDE "bank6D.asm"
INCLUDE "bank6E.asm"
INCLUDE "bank6F.asm"
INCLUDE "bank70.asm"
INCLUDE "bank71.asm"
INCLUDE "bank72.asm"
INCLUDE "bank73.asm"
INCLUDE "bank74.asm"
INCLUDE "bank75.asm"
INCLUDE "bank76.asm"
INCLUDE "bank77.asm"
INCLUDE "bank78.asm"
INCLUDE "bank79.asm"
INCLUDE "bank7A.asm"
INCLUDE "bank7B.asm"
INCLUDE "bank7C.asm"
INCLUDE "bank7D.asm"
INCLUDE "bank7E.asm"
INCLUDE "bank7F.asm"
