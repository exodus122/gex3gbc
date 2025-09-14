;; Disassembled with BadBoy Disassembler: https://github.com/daid/BadBoy

INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/charmaps.inc"
INCLUDE "constants.inc"
INCLUDE "memory.asm"

INCLUDE "bank00_home.asm"
INCLUDE "bank01_menus.asm"
INCLUDE "bank02_objects.asm"
INCLUDE "bank03_misc.asm"
INCLUDE "audio_engine/bank04_audio1.asm"
INCLUDE "audio_engine/bank05_audio2.asm"

SECTION "bank06", ROMX[$4000], BANK[$06]
image_006_4000:
    INCBIN ".gfx/menus/image_006_4000.bin"
image_006_4000_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_006_4000_bgmap_tile_ids.bin"
image_006_4000_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_4000_palette_ids.bin"
image_006_47a6:
    INCBIN ".gfx/menus/image_006_47a6.bin"
image_006_47a6_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_006_47a6_bgmap_tile_ids.bin"
image_006_47a6_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_47a6_palette_ids.bin"
image_006_4a1e:
    INCBIN ".gfx/menus/image_006_4a1e.bin"
image_006_4a1e_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_006_4a1e_bgmap_tile_ids.bin"
image_006_4a1e_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_4a1e_palette_ids.bin"
image_006_59ce:
    INCBIN ".gfx/menus/image_006_59ce.bin"
image_006_59ce_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_006_59ce_bgmap_tile_ids.bin"
image_006_59ce_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_59ce_palette_ids.bin"
image_006_6086:
    INCBIN ".gfx/menus/image_006_6086.bin"
image_006_6086_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_006_6086_bgmap_tile_ids.bin"
image_006_6086_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_6086_palette_ids.bin"
image_006_67c6:
    INCBIN ".gfx/menus/image_006_67c6.bin"
image_006_67c6_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_006_67c6_bgmap_tile_ids.bin"
image_006_67c6_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_006_67c6_palette_ids.bin"

SECTION "bank07", ROMX[$4000], BANK[$07]
image_007_4000:
    INCBIN "./.gfx/object_sprites/image_007_4000.bin"
image_007_5b00:
    INCBIN "./.gfx/menus/image_007_5b00.bin"
image_007_5b00_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_007_5b00_bgmap_tile_ids.bin"

SECTION "bank08", ROMX[$4000], BANK[$08]
image_08_4000:
    INCBIN ".gfx/object_sprites/image_008_4000.bin"

SECTION "bank09", ROMX[$4000], BANK[$09]
image_09_4000:
    INCBIN ".gfx/object_sprites/image_009_4000.bin"

SECTION "bank0a", ROMX[$4000], BANK[$0A]
image_0a_4000:
    INCBIN ".gfx/object_sprites/image_00a_4000.bin"
image_0a_6000:
    INCBIN ".gfx/object_sprites/image_00a_6000.bin"

SECTION "bank0b", ROMX[$4000], BANK[$0B]
image_0b_4000:
    INCBIN ".gfx/object_sprites/image_00b_4000.bin"

SECTION "bank0c", ROMX[$4000], BANK[$0C]
image_0c_4000:
    INCBIN ".gfx/object_sprites/image_00c_4000.bin"

SECTION "bank0d", ROMX[$4000], BANK[$0D]
image_0d_4000:
    INCBIN ".gfx/object_sprites/image_00d_4000.bin"

SECTION "bank0e", ROMX[$4000], BANK[$0E]
image_0e_4000:
    INCBIN ".gfx/object_sprites/image_00e_4000.bin"

SECTION "bank0f", ROMX[$4000], BANK[$0F]
image_0f_4000:
    INCBIN ".gfx/object_sprites/image_00f_4000.bin"

SECTION "bank10", ROMX[$4000], BANK[$10]
image_10_4000:
    INCBIN ".gfx/object_sprites/image_010_4000.bin"

SECTION "bank11", ROMX[$4000], BANK[$11]
image_11_4000:
    INCBIN ".gfx/menus/image_011_4000.bin"
image_11_4000_bgmap_tile_ids:
    INCBIN "gfx/menus/bgmap_tile_ids/image_011_4000_bgmap_tile_ids.bin"
image_11_4000_palette_ids:
    INCBIN "gfx/menus/palette_ids/image_011_4000_palette_ids.bin"

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
    INCBIN "data/bank_01c_text.bin"

SECTION "bank1d", ROMX[$4000], BANK[$1D]
image_1d_4000:
    INCBIN ".gfx/object_sprites/image_01d_4000.bin"

SECTION "bank1e", ROMX[$4000], BANK[$1E]
image_1e_4000:
    INCBIN ".gfx/object_sprites/image_01e_4000.bin"

SECTION "bank1f", ROMX[$4000], BANK[$1F]
image_01f_00.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_00.bin"
image_01f_00_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_00_palette_ids.bin"
image_01f_00_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_00_palette.bin"
image_01f_01.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_01.bin"
image_01f_01_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_01_palette_ids.bin"
image_01f_01_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_01_palette.bin"
image_01f_02.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_02.bin"
image_01f_02_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_02_palette_ids.bin"
image_01f_02_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_02_palette.bin"
image_01f_03.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_03.bin"
image_01f_03_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_03_palette_ids.bin"
image_01f_03_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_03_palette.bin"
image_01f_04.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_04.bin"
image_01f_04_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_04_palette_ids.bin"
image_01f_04_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_04_palette.bin"
image_01f_05.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_05.bin"
image_01f_05_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_05_palette_ids.bin"
image_01f_05_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_05_palette.bin"
image_01f_06.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_06.bin"
image_01f_06_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_06_palette_ids.bin"
image_01f_06_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_06_palette.bin"
image_01f_07.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_07.bin"
image_01f_07_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_07_palette_ids.bin"
image_01f_07_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_07_palette.bin"
image_01f_08.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_08.bin"
image_01f_08_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_08_palette_ids.bin"
image_01f_08_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_08_palette.bin"
image_01f_09.bin:
    INCBIN ".gfx/secondary_tilesets/image_01f_09.bin"
image_01f_09_palette_ids.bin:
    INCBIN "gfx/secondary_tilesets/palette_ids/image_01f_09_palette_ids.bin"
image_01f_09_palette.bin:
    INCBIN "gfx/secondary_tilesets/palettes/image_01f_09_palette.bin"

SECTION "bank20", ROMX[$4000], BANK[$20]

SECTION "bank21", ROMX[$4000], BANK[$21]
INCBIN "data/bank_021_bg_palettes.bin"
GexCave_collectible_list.bin:
    INCBIN "data/maps/GexCave/GexCave_collectible_list.bin"
HolidayTV_collectible_list.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_collectible_list.bin"
MysteryTV_collectible_list.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_collectible_list.bin"
TutTV_collectible_list.bin:
    INCBIN "data/maps/TutTV/TutTV_collectible_list.bin"
WesternStation_collectible_list.bin:
    INCBIN "data/maps/WesternStation/WesternStation_collectible_list.bin"
AnimeChannel_collectible_list.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_collectible_list.bin"
SuperheroShow_collectible_list.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_collectible_list.bin"
GextremeSports_collectible_list.bin:
    INCBIN "data/maps/GextremeSports/GextremeSports_collectible_list.bin"
MarsupialMadness_collectible_list.bin:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_collectible_list.bin"
WWGexWrestling_collectible_list.bin:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_collectible_list.bin"
LizardOfOz_collectible_list.bin:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_collectible_list.bin"
ChannelZ_collectible_list.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_collectible_list.bin"

SECTION "bank22", ROMX[$4000], BANK[$22]
GexCave_object_list.bin:
    INCBIN "data/maps/GexCave/GexCave_object_list.bin"
HolidayTV_object_list.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_object_list.bin"
MysteryTV_object_list.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_object_list.bin"
TutTV_object_list.bin:
    INCBIN "data/maps/TutTV/TutTV_object_list.bin"
WesternStation_object_list.bin:
    INCBIN "data/maps/WesternStation/WesternStation_object_list.bin"
AnimeChannel_object_list.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_object_list.bin"
SuperheroShow_object_list.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_object_list.bin"
GextremeSports_object_list.bin:
    INCBIN "data/maps/GextremeSports/GextremeSports_object_list.bin"
MarsupialMadness_object_list.bin:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_object_list.bin"
WWGexWrestling_object_list.bin:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_object_list.bin"
LizardOfOz_object_list.bin:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_object_list.bin"
ChannelZ_object_list.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_object_list.bin"

SECTION "bank23", ROMX[$4000], BANK[$23]
INCBIN "data/bank_023_collision_blocksets.bin"

SECTION "bank24", ROMX[$4000], BANK[$24]
MysteryTV_1_blockset.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_blockset.bin"
MysteryTV_2_blockset.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_blockset.bin"
MysteryTV_3_blockset.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_blockset.bin"
MysteryTV_4_blockset.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_blockset.bin"
MysteryTV_7_blockset.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_blockset.bin"
MysteryTV_8_blockset.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_blockset.bin"
HolidayTV_1_blockset.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_blockset.bin"
HolidayTV_4_blockset.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_blockset.bin"
TutTV_6_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_blockset.bin"

SECTION "bank25", ROMX[$4000], BANK[$25]
HolidayTV_2_blockset.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_blockset.bin"
TutTV_1_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_blockset.bin"
TutTV_2_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_blockset.bin"
TutTV_3_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_blockset.bin"
TutTV_4_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_blockset.bin"
TutTV_5_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_blockset.bin"
TutTV_7_blockset.bin:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_blockset.bin"
WesternStation_1_blockset.bin:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_blockset.bin"
WesternStation_2_blockset.bin:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_blockset.bin"
WesternStation_3_blockset.bin:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_blockset.bin"
WesternStation_4_blockset.bin:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_blockset.bin"
LizardOfOz_1_blockset.bin:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_blockset.bin"

SECTION "bank26", ROMX[$4000], BANK[$26]
AnimeChannel_1_blockset.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_blockset.bin"
AnimeChannel_2_blockset.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_blockset.bin"
AnimeChannel_3_blockset.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_blockset.bin"
AnimeChannel_4_blockset.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_blockset.bin"
AnimeChannel_5_blockset.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_blockset.bin"
AnimeChannel_6_blockset.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_blockset.bin"
SuperheroShow_1_blockset.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_blockset.bin"
SuperheroShow_2_blockset.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_blockset.bin"
SuperheroShow_3_blockset.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_blockset.bin"
SuperheroShow_4_blockset.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_blockset.bin"
SuperheroShow_5_blockset.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_blockset.bin"
SuperheroShow_6_blockset.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_blockset.bin"

SECTION "bank27", ROMX[$4000], BANK[$27]
GextremeSports_1_blockset.bin:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_blockset.bin"	
MarsupialMadness_1_blockset.bin:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_blockset.bin"
ChannelZ_1_blockset.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_blockset.bin"
ChannelZ_2_blockset.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_blockset.bin"
ChannelZ_3_blockset.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_blockset.bin"
ChannelZ_4_blockset.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_blockset.bin"
ChannelZ_5_blockset.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_blockset.bin"
WesternStation_5_blockset.bin:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_blockset.bin"

SECTION "bank28", ROMX[$4000], BANK[$28]
GexCave_1_blockset.bin:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_blockset.bin"
GexCave_2_blockset.bin:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_blockset.bin"
GexCave_3_blockset.bin:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_blockset.bin"
GexCave_4_blockset.bin:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_blockset.bin"	
WWGexWrestling_1_blockset.bin:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_blockset.bin"
WesternStation_6_blockset.bin:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_blockset.bin"

SECTION "bank29", ROMX[$4000], BANK[$29]
SECTION "bank2A", ROMX[$4000], BANK[$2A]
SECTION "bank2B", ROMX[$4000], BANK[$2B]
SECTION "bank2C", ROMX[$4000], BANK[$2C]
SECTION "bank2D", ROMX[$4000], BANK[$2D]

SECTION "bank2e", ROMX[$4000], BANK[$2e]
ChannelZ_1_extended.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_extended.bin"
ChannelZ_2_extended.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_extended.bin"
ChannelZ_3_extended.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_extended.bin"
ChannelZ_4_extended.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_extended.bin"
ChannelZ_5_extended.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_extended.bin"
WesternStation_1_extended.bin:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_extended.bin"
junk_extended_data.bin:
    INCBIN "data/maps/WesternStation/junk_extended_data.bin"
WesternStation_2_extended.bin:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_extended.bin"
WesternStation_3_extended.bin:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_extended.bin"
WesternStation_4_extended.bin:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_extended.bin"
WesternStation_5_extended.bin:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_extended.bin"
WesternStation_6_extended.bin:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_extended.bin"

SECTION "bank2f", ROMX[$4000], BANK[$2f]
ChannelZ_1_map.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_map.bin"
ChannelZ_2_map.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_map.bin"
ChannelZ_3_map.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_map.bin"
ChannelZ_4_map.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_map.bin"
ChannelZ_5_map.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_map.bin"
WesternStation_1_map.bin:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_map.bin"
junk_map_data.bin:
    INCBIN "data/maps/WesternStation/junk_map_data.bin"
WesternStation_2_map.bin:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_map.bin"
WesternStation_3_map.bin:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_map.bin"
WesternStation_4_map.bin:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_map.bin"
WesternStation_5_map.bin:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_map.bin"
WesternStation_6_map.bin:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_map.bin"

SECTION "bank30", ROMX[$4000], BANK[$30]
ChannelZ_1_collision.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_1/ChannelZ_1_collision.bin"
ChannelZ_2_collision.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_2/ChannelZ_2_collision.bin"
ChannelZ_3_collision.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_3/ChannelZ_3_collision.bin"
ChannelZ_4_collision.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_4/ChannelZ_4_collision.bin"
ChannelZ_5_collision.bin:
    INCBIN "data/maps/ChannelZ/ChannelZ_5/ChannelZ_5_collision.bin"
WesternStation_1_collision.bin:
    INCBIN "data/maps/WesternStation/WesternStation_1/WesternStation_1_collision.bin"
junk_collision_data.bin:
    INCBIN "data/maps/WesternStation/junk_collision_data.bin"
WesternStation_2_collision.bin:
    INCBIN "data/maps/WesternStation/WesternStation_2/WesternStation_2_collision.bin"
WesternStation_3_collision.bin:
    INCBIN "data/maps/WesternStation/WesternStation_3/WesternStation_3_collision.bin"
WesternStation_4_collision.bin:
    INCBIN "data/maps/WesternStation/WesternStation_4/WesternStation_4_collision.bin"
WesternStation_5_collision.bin:
    INCBIN "data/maps/WesternStation/WesternStation_5/WesternStation_5_collision.bin"
WesternStation_6_collision.bin:
    INCBIN "data/maps/WesternStation/WesternStation_6/WesternStation_6_collision.bin"

SECTION "bank31", ROMX[$4000], BANK[$31]
MysteryTV_1_extended.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_extended.bin"
MysteryTV_2_extended.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_extended.bin"
MysteryTV_3_extended.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_extended.bin"
MysteryTV_4_extended.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_extended.bin"
MysteryTV_7_extended.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_extended.bin"
MysteryTV_8_extended.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_extended.bin"
TutTV_1_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_extended.bin"
TutTV_2_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_extended.bin"
TutTV_3_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_extended.bin"
TutTV_4_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_extended.bin"
TutTV_5_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_extended.bin"
TutTV_6_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_extended.bin"
TutTV_7_extended.bin:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_extended.bin"	
HolidayTV_2_extended.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_extended.bin"

SECTION "bank32", ROMX[$4000], BANK[$32]
MysteryTV_1_map.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_map.bin"
MysteryTV_2_map.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_map.bin"
MysteryTV_3_map.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_map.bin"
MysteryTV_4_map.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_map.bin"
MysteryTV_7_map.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_map.bin"
MysteryTV_8_map.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_map.bin"
TutTV_1_map.bin:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_map.bin"
TutTV_2_map.bin:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_map.bin"
TutTV_3_map.bin:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_map.bin"
TutTV_4_map.bin:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_map.bin"
TutTV_5_map.bin:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_map.bin"
TutTV_6_map.bin:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_map.bin"
TutTV_7_map.bin:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_map.bin"	
HolidayTV_2_map.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_map.bin"

SECTION "bank33", ROMX[$4000], BANK[$33]
MysteryTV_1_collision.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_1/MysteryTV_1_collision.bin"
MysteryTV_2_collision.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_2/MysteryTV_2_collision.bin"
MysteryTV_3_collision.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_3/MysteryTV_3_collision.bin"
MysteryTV_4_collision.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_4/MysteryTV_4_collision.bin"
MysteryTV_7_collision.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_7/MysteryTV_7_collision.bin"
MysteryTV_8_collision.bin:
    INCBIN "data/maps/MysteryTV/MysteryTV_8/MysteryTV_8_collision.bin"
TutTV_1_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_1/TutTV_1_collision.bin"
TutTV_2_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_2/TutTV_2_collision.bin"
TutTV_3_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_3/TutTV_3_collision.bin"
TutTV_4_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_4/TutTV_4_collision.bin"
TutTV_5_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_5/TutTV_5_collision.bin"
TutTV_6_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_6/TutTV_6_collision.bin"
TutTV_7_collision.bin:
    INCBIN "data/maps/TutTV/TutTV_7/TutTV_7_collision.bin"	
HolidayTV_2_collision.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_2/HolidayTV_2_collision.bin"

SECTION "bank34", ROMX[$4000], BANK[$34]
HolidayTV_1_extended.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_extended.bin"
HolidayTV_4_extended.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_extended.bin"
MarsupialMadness_1_extended.bin:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_extended.bin"
WWGexWrestling_1_extended.bin:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_extended.bin"

SECTION "bank35", ROMX[$4000], BANK[$35]
HolidayTV_1_map.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_map.bin"
HolidayTV_4_map.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_map.bin"
MarsupialMadness_1_map.bin:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_map.bin"
WWGexWrestling_1_map.bin:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_map.bin"

SECTION "bank36", ROMX[$4000], BANK[$36]
HolidayTV_1_collision.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_1/HolidayTV_1_collision.bin"
HolidayTV_4_collision.bin:
    INCBIN "data/maps/HolidayTV/HolidayTV_4/HolidayTV_4_collision.bin"
MarsupialMadness_1_collision.bin:
    INCBIN "data/maps/MarsupialMadness/MarsupialMadness_1/MarsupialMadness_1_collision.bin"
WWGexWrestling_1_collision.bin:
    INCBIN "data/maps/WWGexWrestling/WWGexWrestling_1/WWGexWrestling_1_collision.bin"

SECTION "bank37", ROMX[$4000], BANK[$37]
AnimeChannel_1_extended.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_extended.bin"
AnimeChannel_2_extended.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_extended.bin"
AnimeChannel_3_extended.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_extended.bin"
AnimeChannel_4_extended.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_extended.bin"
AnimeChannel_5_extended.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_extended.bin"
AnimeChannel_6_extended.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_extended.bin"
LizardOfOz_1_extended.bin:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_extended.bin"

SECTION "bank38", ROMX[$4000], BANK[$38]
AnimeChannel_1_map.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_map.bin"
AnimeChannel_2_map.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_map.bin"
AnimeChannel_3_map.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_map.bin"
AnimeChannel_4_map.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_map.bin"
AnimeChannel_5_map.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_map.bin"
AnimeChannel_6_map.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_map.bin"
LizardOfOz_1_map.bin:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_map.bin"

SECTION "bank39", ROMX[$4000], BANK[$39]
AnimeChannel_1_collision.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_1/AnimeChannel_1_collision.bin"
AnimeChannel_2_collision.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_2/AnimeChannel_2_collision.bin"
AnimeChannel_3_collision.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_3/AnimeChannel_3_collision.bin"
AnimeChannel_4_collision.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_4/AnimeChannel_4_collision.bin"
AnimeChannel_5_collision.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_5/AnimeChannel_5_collision.bin"
AnimeChannel_6_collision.bin:
    INCBIN "data/maps/AnimeChannel/AnimeChannel_6/AnimeChannel_6_collision.bin"
LizardOfOz_1_collision.bin:
    INCBIN "data/maps/LizardOfOz/LizardOfOz_1/LizardOfOz_1_collision.bin"

SECTION "bank3a", ROMX[$4000], BANK[$3a]
SuperheroShow_2_extended.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_extended.bin"
GextremeSports_1_extended.bin:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_extended.bin"

SECTION "bank3b", ROMX[$4000], BANK[$3b]
SuperheroShow_2_map.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_map.bin"
GextremeSports_1_map.bin:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_map.bin"

SECTION "bank3c", ROMX[$4000], BANK[$3c]
SuperheroShow_2_collision.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_2/SuperheroShow_2_collision.bin"
GextremeSports_1_collision.bin:
    INCBIN "data/maps/GextremeSports/GextremeSports_1/GextremeSports_1_collision.bin"

SECTION "bank3d", ROMX[$4000], BANK[$3d]
SuperheroShow_1_extended.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_extended.bin"
SuperheroShow_3_extended.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_extended.bin"
SuperheroShow_4_extended.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_extended.bin"
SuperheroShow_5_extended.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_extended.bin"
SuperheroShow_6_extended.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_extended.bin"
GexCave_1_extended.bin:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_extended.bin"
GexCave_2_extended.bin:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_extended.bin"
GexCave_3_extended.bin:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_extended.bin"
GexCave_4_extended.bin:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_extended.bin"

SECTION "bank3e", ROMX[$4000], BANK[$3e]
SuperheroShow_1_map.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_map.bin"
SuperheroShow_3_map.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_map.bin"
SuperheroShow_4_map.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_map.bin"
SuperheroShow_5_map.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_map.bin"
SuperheroShow_6_map.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_map.bin"
GexCave_1_map.bin:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_map.bin"
GexCave_2_map.bin:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_map.bin"
GexCave_3_map.bin:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_map.bin"
GexCave_4_map.bin:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_map.bin"

SECTION "bank3f", ROMX[$4000], BANK[$3f]
SuperheroShow_1_collision.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_1/SuperheroShow_1_collision.bin"
SuperheroShow_3_collision.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_3/SuperheroShow_3_collision.bin"
SuperheroShow_4_collision.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_4/SuperheroShow_4_collision.bin"
SuperheroShow_5_collision.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_5/SuperheroShow_5_collision.bin"
SuperheroShow_6_collision.bin:
    INCBIN "data/maps/SuperheroShow/SuperheroShow_6/SuperheroShow_6_collision.bin"
GexCave_1_collision.bin:
    INCBIN "data/maps/GexCave/GexCave_1/GexCave_1_collision.bin"
GexCave_2_collision.bin:
    INCBIN "data/maps/GexCave/GexCave_2/GexCave_2_collision.bin"
GexCave_3_collision.bin:
    INCBIN "data/maps/GexCave/GexCave_3/GexCave_3_collision.bin"
GexCave_4_collision.bin:
    INCBIN "data/maps/GexCave/GexCave_4/GexCave_4_collision.bin"

SECTION "bank40", ROMX[$4000], BANK[$40]
INCBIN ".gfx/tilesets/tileset_040.bin"
SECTION "bank41", ROMX[$4000], BANK[$41]
INCBIN ".gfx/tilesets/tileset_041.bin"
SECTION "bank42", ROMX[$4000], BANK[$42]
INCBIN ".gfx/tilesets/tileset_042.bin"
SECTION "bank43", ROMX[$4000], BANK[$43]
INCBIN ".gfx/tilesets/tileset_043.bin"
SECTION "bank44", ROMX[$4000], BANK[$44]
INCBIN ".gfx/tilesets/tileset_044.bin"
SECTION "bank45", ROMX[$4000], BANK[$45]
INCBIN ".gfx/tilesets/tileset_045.bin"
SECTION "bank46", ROMX[$4000], BANK[$46]
INCBIN ".gfx/tilesets/tileset_046.bin"
SECTION "bank47", ROMX[$4000], BANK[$47]
INCBIN ".gfx/tilesets/tileset_047.bin"
SECTION "bank48", ROMX[$4000], BANK[$48]
INCBIN ".gfx/tilesets/tileset_048.bin"
SECTION "bank49", ROMX[$4000], BANK[$49]
INCBIN ".gfx/tilesets/tileset_049.bin"
SECTION "bank4a", ROMX[$4000], BANK[$4a]
INCBIN ".gfx/tilesets/tileset_04a.bin"
SECTION "bank4b", ROMX[$4000], BANK[$4b]
INCBIN ".gfx/tilesets/tileset_04b.bin"
SECTION "bank4c", ROMX[$4000], BANK[$4c]
INCBIN ".gfx/tilesets/tileset_04c.bin"
SECTION "bank4d", ROMX[$4000], BANK[$4d]
INCBIN ".gfx/tilesets/tileset_04d.bin"
SECTION "bank4e", ROMX[$4000], BANK[$4e]
INCBIN ".gfx/tilesets/tileset_04e.bin"
SECTION "bank4f", ROMX[$4000], BANK[$4f]
INCBIN ".gfx/tilesets/tileset_04f.bin"

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
INCBIN "data/sprite_data/bank_062.bin"
SECTION "bank63", ROMX[$4000], BANK[$63]
INCBIN "data/sprite_data/bank_063.bin"
SECTION "bank64", ROMX[$4000], BANK[$64]
INCBIN "data/sprite_data/bank_064.bin"
SECTION "bank65", ROMX[$4000], BANK[$65]
INCBIN "data/sprite_data/bank_065.bin"
SECTION "bank66", ROMX[$4000], BANK[$66]
INCBIN "data/sprite_data/bank_066.bin"
SECTION "bank67", ROMX[$4000], BANK[$67]
INCBIN "data/sprite_data/bank_067.bin"
SECTION "bank68", ROMX[$4000], BANK[$68]
INCBIN "data/sprite_data/bank_068.bin"
SECTION "bank69", ROMX[$4000], BANK[$69]
INCBIN "data/sprite_data/bank_069.bin"
SECTION "bank6a", ROMX[$4000], BANK[$6a]
INCBIN "data/sprite_data/bank_06a.bin"
SECTION "bank6b", ROMX[$4000], BANK[$6b]
INCBIN "data/sprite_data/bank_06b.bin"
SECTION "bank6c", ROMX[$4000], BANK[$6c]
INCBIN "data/sprite_data/bank_06c.bin"
SECTION "bank6d", ROMX[$4000], BANK[$6d]
INCBIN "data/sprite_data/bank_06d.bin"
SECTION "bank6e", ROMX[$4000], BANK[$6e]
INCBIN "data/sprite_data/bank_06e.bin"
SECTION "bank6f", ROMX[$4000], BANK[$6f]
INCBIN "data/sprite_data/bank_06f.bin"
SECTION "bank70", ROMX[$4000], BANK[$70]
INCBIN "data/sprite_data/bank_070.bin"
SECTION "bank71", ROMX[$4000], BANK[$71]
INCBIN "data/sprite_data/bank_071.bin"
SECTION "bank72", ROMX[$4000], BANK[$72]
INCBIN "data/sprite_data/bank_072.bin"
SECTION "bank73", ROMX[$4000], BANK[$73]
INCBIN "data/sprite_data/bank_073.bin"
SECTION "bank74", ROMX[$4000], BANK[$74]
INCBIN "data/sprite_data/bank_074.bin"
SECTION "bank75", ROMX[$4000], BANK[$75]
INCBIN "data/sprite_data/bank_075.bin"
SECTION "bank76", ROMX[$4000], BANK[$76]
INCBIN "data/sprite_data/bank_076.bin"
SECTION "bank77", ROMX[$4000], BANK[$77]
INCBIN "data/sprite_data/bank_077.bin"
SECTION "bank78", ROMX[$4000], BANK[$78]
INCBIN "data/sprite_data/bank_078.bin"
SECTION "bank79", ROMX[$4000], BANK[$79]
INCBIN "data/sprite_data/bank_079.bin"
SECTION "bank7a", ROMX[$4000], BANK[$7a]
INCBIN "data/sprite_data/bank_07a.bin"
SECTION "bank7b", ROMX[$4000], BANK[$7b]
INCBIN "data/sprite_data/bank_07b.bin"
SECTION "bank7c", ROMX[$4000], BANK[$7c]
INCBIN "data/sprite_data/bank_07c.bin"
SECTION "bank7d", ROMX[$4000], BANK[$7d]
INCBIN "data/sprite_data/bank_07d.bin"
SECTION "bank7e", ROMX[$4000], BANK[$7e]
INCBIN "data/sprite_data/bank_07e.bin"
SECTION "bank7f", ROMX[$4000], BANK[$7f]
INCBIN "data/sprite_data/bank_07f.bin"
