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

SECTION "bank07", ROMX[$4000], BANK[$07]
INCBIN "./gfx/bank_007.bin"

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

SECTION "bank21", ROMX[$4000], BANK[$21]
INCBIN "../data/bank_021.bin"
SECTION "bank22", ROMX[$4000], BANK[$22]
INCBIN "../data/bank_022.bin"
SECTION "bank23", ROMX[$4000], BANK[$23]
INCBIN "../data/bank_023.bin"

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

SECTION "bank62", ROMX[$4000], BANK[$62]
INCBIN "../data/sprite_data/bank_062.bin"
SECTION "bank63", ROMX[$4000], BANK[$63]
INCBIN "../data/sprite_data/bank_063.bin"
SECTION "bank64", ROMX[$4000], BANK[$64]
INCBIN "../data/sprite_data/bank_064.bin"
SECTION "bank65", ROMX[$4000], BANK[$65]
INCBIN "../data/sprite_data/bank_065.bin"
SECTION "bank66", ROMX[$4000], BANK[$66]
INCBIN "../data/sprite_data/bank_066.bin"
SECTION "bank67", ROMX[$4000], BANK[$67]
INCBIN "../data/sprite_data/bank_067.bin"
SECTION "bank68", ROMX[$4000], BANK[$68]
INCBIN "../data/sprite_data/bank_068.bin"
SECTION "bank69", ROMX[$4000], BANK[$69]
INCBIN "../data/sprite_data/bank_069.bin"
SECTION "bank6a", ROMX[$4000], BANK[$6a]
INCBIN "../data/sprite_data/bank_06a.bin"
SECTION "bank6b", ROMX[$4000], BANK[$6b]
INCBIN "../data/sprite_data/bank_06b.bin"
SECTION "bank6c", ROMX[$4000], BANK[$6c]
INCBIN "../data/sprite_data/bank_06c.bin"
SECTION "bank6d", ROMX[$4000], BANK[$6d]
INCBIN "../data/sprite_data/bank_06d.bin"
SECTION "bank6e", ROMX[$4000], BANK[$6e]
INCBIN "../data/sprite_data/bank_06e.bin"
SECTION "bank6f", ROMX[$4000], BANK[$6f]
INCBIN "../data/sprite_data/bank_06f.bin"
SECTION "bank70", ROMX[$4000], BANK[$70]
INCBIN "../data/sprite_data/bank_070.bin"
SECTION "bank71", ROMX[$4000], BANK[$71]
INCBIN "../data/sprite_data/bank_071.bin"
SECTION "bank72", ROMX[$4000], BANK[$72]
INCBIN "../data/sprite_data/bank_072.bin"
SECTION "bank73", ROMX[$4000], BANK[$73]
INCBIN "../data/sprite_data/bank_073.bin"
SECTION "bank74", ROMX[$4000], BANK[$74]
INCBIN "../data/sprite_data/bank_074.bin"
SECTION "bank75", ROMX[$4000], BANK[$75]
INCBIN "../data/sprite_data/bank_075.bin"
SECTION "bank76", ROMX[$4000], BANK[$76]
INCBIN "../data/sprite_data/bank_076.bin"
SECTION "bank77", ROMX[$4000], BANK[$77]
INCBIN "../data/sprite_data/bank_077.bin"
SECTION "bank78", ROMX[$4000], BANK[$78]
INCBIN "../data/sprite_data/bank_078.bin"
SECTION "bank79", ROMX[$4000], BANK[$79]
INCBIN "../data/sprite_data/bank_079.bin"
SECTION "bank7a", ROMX[$4000], BANK[$7a]
INCBIN "../data/sprite_data/bank_07a.bin"
SECTION "bank7b", ROMX[$4000], BANK[$7b]
INCBIN "../data/sprite_data/bank_07b.bin"
SECTION "bank7c", ROMX[$4000], BANK[$7c]
INCBIN "../data/sprite_data/bank_07c.bin"
SECTION "bank7d", ROMX[$4000], BANK[$7d]
INCBIN "../data/sprite_data/bank_07d.bin"
SECTION "bank7e", ROMX[$4000], BANK[$7e]
INCBIN "../data/sprite_data/bank_07e.bin"
SECTION "bank7f", ROMX[$4000], BANK[$7f]
INCBIN "../data/sprite_data/bank_07f.bin"
