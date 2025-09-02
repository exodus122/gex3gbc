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
INCLUDE "bank24.asm"
INCLUDE "bank25.asm"
INCLUDE "bank26.asm"
INCLUDE "bank27.asm"
INCLUDE "bank28.asm"
SECTION "bank29", ROMX[$4000], BANK[$29]
SECTION "bank2A", ROMX[$4000], BANK[$2A]
SECTION "bank2B", ROMX[$4000], BANK[$2B]
SECTION "bank2C", ROMX[$4000], BANK[$2C]
SECTION "bank2D", ROMX[$4000], BANK[$2D]
INCLUDE "bank2E.asm"
INCLUDE "bank2F.asm"
INCLUDE "bank30.asm"
INCLUDE "bank31.asm"
INCLUDE "bank32.asm"
INCLUDE "bank33.asm"
INCLUDE "bank34.asm"
INCLUDE "bank35.asm"
INCLUDE "bank36.asm"
SECTION "bank37", ROMX[$4000], BANK[$37]
INCLUDE "bank38.asm"
INCLUDE "bank39.asm"
INCLUDE "bank3A.asm"
INCLUDE "bank3B.asm"
INCLUDE "bank3C.asm"
SECTION "bank3D", ROMX[$4000], BANK[$3D]
INCLUDE "bank3E.asm"
INCLUDE "bank3F.asm"
INCLUDE "bank40.asm"
INCLUDE "bank41.asm"
INCLUDE "bank42.asm"
INCLUDE "bank43.asm"
INCLUDE "bank44.asm"
INCLUDE "bank45.asm"
INCLUDE "bank46.asm"
INCLUDE "bank47.asm"
INCLUDE "bank48.asm"
INCLUDE "bank49.asm"
INCLUDE "bank4A.asm"
INCLUDE "bank4B.asm"
INCLUDE "bank4C.asm"
INCLUDE "bank4D.asm"
INCLUDE "bank4E.asm"
INCLUDE "bank4F.asm"
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
