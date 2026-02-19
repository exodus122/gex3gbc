call_03_6c89_LoadMapData:
; Purpose: Copies level-specific metadata from a lookup table into working RAM.
; Behavior:
; Uses wDB6C_CurrentMapId as index into .data_03_6ca0_LevelData.
; Reads a pointer to the level’s configuration, then copies 0x1F bytes into wDC01_MapBank.
; Usage: Part of level setup, ensuring the correct map bank and related data are loaded.
    ld   HL, wDB6C_CurrentMapId                                     ;; 03:6c89 $21 $6c $db
    ld   L, [HL]                                       ;; 03:6c8c $6e
    ld   H, $00                                        ;; 03:6c8d $26 $00
    add  HL, HL                                        ;; 03:6c8f $29
    ld   DE, .data_03_6ca0_LevelData                             ;; 03:6c90 $11 $a0 $6c
    add  HL, DE                                        ;; 03:6c93 $19
    ld   A, [HL+]                                      ;; 03:6c94 $2a
    ld   H, [HL]                                       ;; 03:6c95 $66
    ld   L, A                                          ;; 03:6c96 $6f
    ld   DE, wDC01_MapBank                                     ;; 03:6c97 $11 $01 $dc
    ld   BC, $1f                                       ;; 03:6c9a $01 $1f $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 03:6c9d $c3 $6e $07
.data_03_6ca0_LevelData:
    dw   .data_03_6d1a_LevelDataGexCave1
    dw   .data_03_6d96_LevelDataHolidayTV1
    dw   .data_03_6e12_LevelDataMysteryTV1
    dw   .data_03_6f48_LevelDataTutTV1
    dw   .data_03_7021_LevelWesternStation
    dw   .data_03_7138_LevelAnimeChannel
    dw   .data_03_724f_LevelSuperheroShow
    dw   .data_03_7309_LevelGextremeSports
    dw   .data_03_7385_LevelMarsupialMadness
    dw   .data_03_73a4_LevelWWGexWrestling
    dw   .data_03_73c3_LevelLizardOfOz
    dw   .data_03_73e2_LevelChannelZ
    dw   .data_03_6d39_LevelDataGexCave2
    dw   .data_03_6d58_LevelDataGexCave3
    dw   .data_03_6d77_LevelDataGexCave4
    dw   .data_03_6db5_LevelDataHolidayTV2
    dw   .data_03_6dd4_LevelDataHolidayTV3
    dw   .data_03_6df3_LevelDataHolidayTV4
    dw   .data_03_6e31_LevelDataMysteryTV2
    dw   .data_03_6e50_LevelDataMysteryTV3
    dw   .data_03_6e6f_LevelDataMysteryTV4
    dw   .data_03_6e8e_LevelDataMysteryTV5
    dw   .data_03_6ead_LevelDataMysteryTV6
    dw   .data_03_6ecc_LevelDataMysteryTV7
    dw   .data_03_6eeb_LevelDataMysteryTV8
    dw   .data_03_6f0a_LevelDataMysteryTV9
    dw   .data_03_6f29_LevelDataMysteryTV10
    dw   .data_03_6f67_LevelDataTutTV2
    dw   .data_03_6f86_LevelDataTutTV3
    dw   .data_03_6fa5_LevelDataTutTV4
    dw   .data_03_6fc4_LevelDataTutTV5
    dw   .data_03_6fe3_LevelDataTutTV6
    dw   .data_03_7002_LevelDataTutTV7
    db   $40, $70, $5f, $70, $7e, $70        ;; 03:6ce0 ????????
    db   $9d, $70, $bc, $70, $db, $70, $fa, $70        ;; 03:6ce8 ????????
    db   $19, $71, $57, $71, $76, $71, $95, $71        ;; 03:6cf0 ????????
    db   $b4, $71, $d3, $71, $f2, $71, $11, $72        ;; 03:6cf8 ????????
    db   $30, $72, $6e, $72, $8d, $72, $ac, $72        ;; 03:6d00 ????????
    db   $cb, $72, $ea, $72, $28, $73, $47, $73        ;; 03:6d08 ????????
    db   $66, $73, $01, $74, $20, $74, $3f, $74        ;; 03:6d10 ????????
    db   $5e, $74

.data_03_6d1a_LevelDataGexCave1:
    db   BANK(GexCave_1_map)
    dw   GexCave_1_map
    db   BANK(GexCave_1_map_extended)
    dw   GexCave_1_map_extended
    db   BANK(GexCave_1_tileset)
    dw   GexCave_1_tileset
    db   BANK(GexCave_1_blockset)
    dw   GexCave_1_blockset
    db   BANK(GexCave_1_collision)
    dw   GexCave_1_collision
    db   BANK(GexCave_1_collision_blockset)
    dw   GexCave_1_collision_blockset
    db   BANK(GexCave_1_palette)
    dw   GexCave_1_palette
    db   BANK(GexCave_object_list)
    dw   GexCave_object_list
    db   BANK(GexCave_collectible_list)
    dw   GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d39_LevelDataGexCave2:
    db   BANK(GexCave_2_map)
    dw   GexCave_2_map
    db   BANK(GexCave_2_map_extended)
    dw   GexCave_2_map_extended
    db   BANK(GexCave_2_tileset)
    dw   GexCave_2_tileset
    db   BANK(GexCave_2_blockset)
    dw   GexCave_2_blockset
    db   BANK(GexCave_2_collision)
    dw   GexCave_2_collision
    db   BANK(GexCave_2_collision_blockset)
    dw   GexCave_2_collision_blockset
    db   BANK(GexCave_2_palette)
    dw   GexCave_2_palette
    db   BANK(GexCave_object_list)
    dw   GexCave_object_list
    db   BANK(GexCave_collectible_list)
    dw   GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d58_LevelDataGexCave3:
    db   BANK(GexCave_3_map)
    dw   GexCave_3_map
    db   BANK(GexCave_3_map_extended)
    dw   GexCave_3_map_extended
    db   BANK(GexCave_3_tileset)
    dw   GexCave_3_tileset
    db   BANK(GexCave_3_blockset)
    dw   GexCave_3_blockset
    db   BANK(GexCave_3_collision)
    dw   GexCave_3_collision
    db   BANK(GexCave_3_collision_blockset)
    dw   GexCave_3_collision_blockset
    db   BANK(GexCave_3_palette)
    dw   GexCave_3_palette
    db   BANK(GexCave_object_list)
    dw   GexCave_object_list
    db   BANK(GexCave_collectible_list)
    dw   GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d77_LevelDataGexCave4:
    db   BANK(GexCave_4_map)
    dw   GexCave_4_map
    db   BANK(GexCave_4_map_extended)
    dw   GexCave_4_map_extended
    db   BANK(GexCave_4_tileset)
    dw   GexCave_4_tileset
    db   BANK(GexCave_4_blockset)
    dw   GexCave_4_blockset
    db   BANK(GexCave_4_collision)
    dw   GexCave_4_collision
    db   BANK(GexCave_4_collision_blockset)
    dw   GexCave_4_collision_blockset
    db   BANK(GexCave_4_palette)
    dw   GexCave_4_palette
    db   BANK(GexCave_object_list)
    dw   GexCave_object_list
    db   BANK(GexCave_collectible_list)
    dw   GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d96_LevelDataHolidayTV1:
    db   BANK(HolidayTV_1_map)
    dw   HolidayTV_1_map
    db   BANK(HolidayTV_1_map_extended)
    dw   HolidayTV_1_map_extended
    db   BANK(HolidayTV_1_tileset)
    dw   HolidayTV_1_tileset
    db   BANK(HolidayTV_1_blockset)
    dw   HolidayTV_1_blockset
    db   BANK(HolidayTV_1_collision)
    dw   HolidayTV_1_collision
    db   BANK(HolidayTV_1_collision_blockset)
    dw   HolidayTV_1_collision_blockset
    db   BANK(HolidayTV_1_palette)
    dw   HolidayTV_1_palette
    db   BANK(HolidayTV_object_list)
    dw   HolidayTV_object_list
    db   BANK(HolidayTV_collectible_list)
    dw   HolidayTV_collectible_list
    db   $a0, $50, $01, $00
.data_03_6db5_LevelDataHolidayTV2:
    db   BANK(HolidayTV_2_map)
    dw   HolidayTV_2_map
    db   BANK(HolidayTV_2_map_extended)
    dw   HolidayTV_2_map_extended
    db   BANK(HolidayTV_2_tileset)
    dw   HolidayTV_2_tileset
    db   BANK(HolidayTV_2_blockset)
    dw   HolidayTV_2_blockset
    db   BANK(HolidayTV_2_collision)
    dw   HolidayTV_2_collision
    db   BANK(HolidayTV_2_collision_blockset)
    dw   HolidayTV_2_collision_blockset
    db   BANK(HolidayTV_2_palette)
    dw   HolidayTV_2_palette
    db   BANK(HolidayTV_object_list)
    dw   HolidayTV_object_list
    db   BANK(HolidayTV_collectible_list)
    dw   HolidayTV_collectible_list
    db   $14, $16, $01, $00
.data_03_6dd4_LevelDataHolidayTV3:
    db   BANK(HolidayTV_2_map)
    dw   HolidayTV_2_map
    db   BANK(HolidayTV_2_map_extended)
    dw   HolidayTV_2_map_extended
    db   BANK(HolidayTV_2_tileset)
    dw   HolidayTV_2_tileset
    db   BANK(HolidayTV_2_blockset)
    dw   HolidayTV_2_blockset
    db   BANK(HolidayTV_2_collision)
    dw   HolidayTV_2_collision
    db   BANK(HolidayTV_2_collision_blockset)
    dw   HolidayTV_2_collision_blockset
    db   BANK(HolidayTV_3_palette_4180)
    dw   HolidayTV_3_palette_4180
    db   BANK(HolidayTV_object_list)
    dw   HolidayTV_object_list
    db   BANK(HolidayTV_collectible_list)
    dw   HolidayTV_collectible_list
    db   $14, $16, $01, $00
.data_03_6df3_LevelDataHolidayTV4:
    db   BANK(HolidayTV_4_map)
    dw   HolidayTV_4_map
    db   BANK(HolidayTV_4_map_extended)
    dw   HolidayTV_4_map_extended
    db   BANK(HolidayTV_4_tileset)
    dw   HolidayTV_4_tileset
    db   BANK(HolidayTV_4_blockset)
    dw   HolidayTV_4_blockset
    db   BANK(HolidayTV_4_collision)
    dw   HolidayTV_4_collision
    db   BANK(HolidayTV_4_collision_blockset)
    dw   HolidayTV_4_collision_blockset
    db   BANK(HolidayTV_4_palette)
    dw   HolidayTV_4_palette
    db   BANK(HolidayTV_object_list)
    dw   HolidayTV_object_list
    db   BANK(HolidayTV_collectible_list)
    dw   HolidayTV_collectible_list
    db   $14, $9, $01, $00
.data_03_6e12_LevelDataMysteryTV1:
    db   BANK(MysteryTV_1_map)
    dw   MysteryTV_1_map
    db   BANK(MysteryTV_1_map_extended)
    dw   MysteryTV_1_map_extended
    db   BANK(MysteryTV_1_tileset)
    dw   MysteryTV_1_tileset
    db   BANK(MysteryTV_1_blockset)
    dw   MysteryTV_1_blockset
    db   BANK(MysteryTV_1_collision)
    dw   MysteryTV_1_collision
    db   BANK(MysteryTV_1_collision_blockset)
    dw   MysteryTV_1_collision_blockset
    db   BANK(MysteryTV_1_palette)
    dw   MysteryTV_1_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $2d, $2d, $02, $00
.data_03_6e31_LevelDataMysteryTV2:
    db   BANK(MysteryTV_2_map)
    dw   MysteryTV_2_map
    db   BANK(MysteryTV_2_map_extended)
    dw   MysteryTV_2_map_extended
    db   BANK(MysteryTV_2_tileset)
    dw   MysteryTV_2_tileset
    db   BANK(MysteryTV_2_blockset)
    dw   MysteryTV_2_blockset
    db   BANK(MysteryTV_2_collision)
    dw   MysteryTV_2_collision
    db   BANK(MysteryTV_2_collision_blockset)
    dw   MysteryTV_2_collision_blockset
    db   BANK(MysteryTV_2_palette)
    dw   MysteryTV_2_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $28, $32, $02, $01
.data_03_6e50_LevelDataMysteryTV3:
    db   BANK(MysteryTV_3_map)
    dw   MysteryTV_3_map
    db   BANK(MysteryTV_3_map_extended)
    dw   MysteryTV_3_map_extended
    db   BANK(MysteryTV_3_tileset)
    dw   MysteryTV_3_tileset
    db   BANK(MysteryTV_3_blockset)
    dw   MysteryTV_3_blockset
    db   BANK(MysteryTV_3_collision)
    dw   MysteryTV_3_collision
    db   BANK(MysteryTV_3_collision_blockset)
    dw   MysteryTV_3_collision_blockset
    db   BANK(MysteryTV_3_palette)
    dw   MysteryTV_3_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $2d, $1e, $02, $00
.data_03_6e6f_LevelDataMysteryTV4:
    db   BANK(MysteryTV_4_map)
    dw   MysteryTV_4_map
    db   BANK(MysteryTV_4_map_extended)
    dw   MysteryTV_4_map_extended
    db   BANK(MysteryTV_4_tileset)
    dw   MysteryTV_4_tileset
    db   BANK(MysteryTV_4_blockset)
    dw   MysteryTV_4_blockset
    db   BANK(MysteryTV_4_collision)
    dw   MysteryTV_4_collision
    db   BANK(MysteryTV_4_collision_blockset)
    dw   MysteryTV_4_collision_blockset
    db   BANK(MysteryTV_4_palette)
    dw   MysteryTV_4_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6e8e_LevelDataMysteryTV5:
    db   BANK(MysteryTV_4_map)
    dw   MysteryTV_4_map
    db   BANK(MysteryTV_4_map_extended)
    dw   MysteryTV_4_map_extended
    db   BANK(MysteryTV_4_tileset)
    dw   MysteryTV_4_tileset
    db   BANK(MysteryTV_4_blockset)
    dw   MysteryTV_4_blockset
    db   BANK(MysteryTV_4_collision)
    dw   MysteryTV_4_collision
    db   BANK(MysteryTV_4_collision_blockset)
    dw   MysteryTV_4_collision_blockset
    db   BANK(MysteryTV_5_palette_4300)
    dw   MysteryTV_5_palette_4300
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6ead_LevelDataMysteryTV6:
    db   BANK(MysteryTV_4_map)
    dw   MysteryTV_4_map
    db   BANK(MysteryTV_4_map_extended)
    dw   MysteryTV_4_map_extended
    db   BANK(MysteryTV_4_tileset)
    dw   MysteryTV_4_tileset
    db   BANK(MysteryTV_4_blockset)
    dw   MysteryTV_4_blockset
    db   BANK(MysteryTV_4_collision)
    dw   MysteryTV_4_collision
    db   BANK(MysteryTV_4_collision_blockset)
    dw   MysteryTV_4_collision_blockset
    db   BANK(MysteryTV_6_palette_4340)
    dw   MysteryTV_6_palette_4340
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6ecc_LevelDataMysteryTV7:
    db   BANK(MysteryTV_7_map)
    dw   MysteryTV_7_map
    db   BANK(MysteryTV_7_map_extended)
    dw   MysteryTV_7_map_extended
    db   BANK(MysteryTV_7_tileset)
    dw   MysteryTV_7_tileset
    db   BANK(MysteryTV_7_blockset)
    dw   MysteryTV_7_blockset
    db   BANK(MysteryTV_7_collision)
    dw   MysteryTV_7_collision
    db   BANK(MysteryTV_7_collision_blockset)
    dw   MysteryTV_7_collision_blockset
    db   BANK(MysteryTV_7_palette)
    dw   MysteryTV_7_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $0a, $08, $02, $01
.data_03_6eeb_LevelDataMysteryTV8:
    db   BANK(MysteryTV_8_map)
    dw   MysteryTV_8_map
    db   BANK(MysteryTV_8_map_extended)
    dw   MysteryTV_8_map_extended
    db   BANK(MysteryTV_8_tileset)
    dw   MysteryTV_8_tileset
    db   BANK(MysteryTV_8_blockset)
    dw   MysteryTV_8_blockset
    db   BANK(MysteryTV_8_collision)
    dw   MysteryTV_8_collision
    db   BANK(MysteryTV_8_collision_blockset)
    dw   MysteryTV_8_collision_blockset
    db   BANK(MysteryTV_8_palette)
    dw   MysteryTV_8_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $0a, $09, $02, $01
.data_03_6f0a_LevelDataMysteryTV9:
    db   BANK(MysteryTV_4_map)
    dw   MysteryTV_4_map
    db   BANK(MysteryTV_4_map_extended)
    dw   MysteryTV_4_map_extended
    db   BANK(MysteryTV_4_tileset)
    dw   MysteryTV_4_tileset
    db   BANK(MysteryTV_4_blockset)
    dw   MysteryTV_4_blockset
    db   BANK(MysteryTV_4_collision)
    dw   MysteryTV_4_collision
    db   BANK(MysteryTV_4_collision_blockset)
    dw   MysteryTV_4_collision_blockset
    db   BANK(MysteryTV_4_palette)
    dw   MysteryTV_4_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6f29_LevelDataMysteryTV10:
    db   BANK(MysteryTV_2_map)
    dw   MysteryTV_2_map
    db   BANK(MysteryTV_2_map_extended)
    dw   MysteryTV_2_map_extended
    db   BANK(MysteryTV_2_tileset)
    dw   MysteryTV_2_tileset
    db   BANK(MysteryTV_2_blockset)
    dw   MysteryTV_2_blockset
    db   BANK(MysteryTV_2_collision)
    dw   MysteryTV_2_collision
    db   BANK(MysteryTV_2_collision_blockset)
    dw   MysteryTV_2_collision_blockset
    db   BANK(MysteryTV_2_palette)
    dw   MysteryTV_2_palette
    db   BANK(MysteryTV_object_list)
    dw   MysteryTV_object_list
    db   BANK(MysteryTV_collectible_list)
    dw   MysteryTV_collectible_list
    db   $28, $32, $02, $01
.data_03_6f48_LevelDataTutTV1:
    db   BANK(TutTV_1_map)
    dw   TutTV_1_map
    db   BANK(TutTV_1_map_extended)
    dw   TutTV_1_map_extended
    db   BANK(TutTV_1_tileset)
    dw   TutTV_1_tileset
    db   BANK(TutTV_1_blockset)
    dw   TutTV_1_blockset
    db   BANK(TutTV_1_collision)
    dw   TutTV_1_collision
    db   BANK(TutTV_1_collision_blockset)
    dw   TutTV_1_collision_blockset
    db   BANK(TutTV_1_palette)
    dw   TutTV_1_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $27, $13, $03, $00
.data_03_6f67_LevelDataTutTV2:
    db   BANK(TutTV_2_map)
    dw   TutTV_2_map
    db   BANK(TutTV_2_map_extended)
    dw   TutTV_2_map_extended
    db   BANK(TutTV_2_tileset)
    dw   TutTV_2_tileset
    db   BANK(TutTV_2_blockset)
    dw   TutTV_2_blockset
    db   BANK(TutTV_2_collision)
    dw   TutTV_2_collision
    db   BANK(TutTV_2_collision_blockset)
    dw   TutTV_2_collision_blockset
    db   BANK(TutTV_2_palette)
    dw   TutTV_2_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $34, $33, $03, $00
.data_03_6f86_LevelDataTutTV3:
    db   BANK(TutTV_3_map)
    dw   TutTV_3_map
    db   BANK(TutTV_3_map_extended)
    dw   TutTV_3_map_extended
    db   BANK(TutTV_3_tileset)
    dw   TutTV_3_tileset
    db   BANK(TutTV_3_blockset)
    dw   TutTV_3_blockset
    db   BANK(TutTV_3_collision)
    dw   TutTV_3_collision
    db   BANK(TutTV_3_collision_blockset)
    dw   TutTV_3_collision_blockset
    db   BANK(TutTV_3_palette)
    dw   TutTV_3_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $64, $17, $03, $00
.data_03_6fa5_LevelDataTutTV4:
    db   BANK(TutTV_4_map)
    dw   TutTV_4_map
    db   BANK(TutTV_4_map_extended)
    dw   TutTV_4_map_extended
    db   BANK(TutTV_4_tileset)
    dw   TutTV_4_tileset
    db   BANK(TutTV_4_blockset)
    dw   TutTV_4_blockset
    db   BANK(TutTV_4_collision)
    dw   TutTV_4_collision
    db   BANK(TutTV_4_collision_blockset)
    dw   TutTV_4_collision_blockset
    db   BANK(TutTV_4_palette)
    dw   TutTV_4_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $4a, $13, $03, $00
.data_03_6fc4_LevelDataTutTV5:
    db   BANK(TutTV_5_map)
    dw   TutTV_5_map
    db   BANK(TutTV_5_map_extended)
    dw   TutTV_5_map_extended
    db   BANK(TutTV_5_tileset)
    dw   TutTV_5_tileset
    db   BANK(TutTV_5_blockset)
    dw   TutTV_5_blockset
    db   BANK(TutTV_5_collision)
    dw   TutTV_5_collision
    db   BANK(TutTV_5_collision_blockset)
    dw   TutTV_5_collision_blockset
    db   BANK(TutTV_5_palette)
    dw   TutTV_5_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $0a, $09, $03, $00
.data_03_6fe3_LevelDataTutTV6:
    db   BANK(TutTV_6_map)
    dw   TutTV_6_map
    db   BANK(TutTV_6_map_extended)
    dw   TutTV_6_map_extended
    db   BANK(TutTV_6_tileset)
    dw   TutTV_6_tileset
    db   BANK(TutTV_6_blockset)
    dw   TutTV_6_blockset
    db   BANK(TutTV_6_collision)
    dw   TutTV_6_collision
    db   BANK(TutTV_6_collision_blockset)
    dw   TutTV_6_collision_blockset
    db   BANK(TutTV_6_palette)
    dw   TutTV_6_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $14, $09, $03, $00
.data_03_7002_LevelDataTutTV7:
    db   BANK(TutTV_7_map)
    dw   TutTV_7_map
    db   BANK(TutTV_7_map_extended)
    dw   TutTV_7_map_extended
    db   BANK(TutTV_7_tileset)
    dw   TutTV_7_tileset
    db   BANK(TutTV_7_blockset)
    dw   TutTV_7_blockset
    db   BANK(TutTV_7_collision)
    dw   TutTV_7_collision
    db   BANK(TutTV_7_collision_blockset)
    dw   TutTV_7_collision_blockset
    db   BANK(TutTV_7_palette)
    dw   TutTV_7_palette
    db   BANK(TutTV_object_list)
    dw   TutTV_object_list
    db   BANK(TutTV_collectible_list)
    dw   TutTV_collectible_list
    db   $32, $19, $03, $00
.data_03_7021_LevelWesternStation:    
    db   $2f, $47        ;; 03:7021 ??????..
    db   $55, $2e, $47, $55, $42, $00, $40, $25        ;; 03:7023 ........
    db   $20, $67, $30, $47, $55, $23, $cc, $44        ;; 03:702b ........
    db   $21, $c0, $45, $22, $94, $48, $21, $c2        ;; 03:7033 ........
    db   $4f, $28, $16, $04, $00
    
    db   $2f, $df, $58        ;; 03:7040 ...w.???
    db   $2e, $df, $58, $42, $90, $5a, $25, $30        ;; 03:7043 ????????
    db   $6f, $30, $df, $58, $23, $b0, $45, $21        ;; 03:704b ????????
    db   $00, $46, $22, $94, $48, $21, $c2, $4f        ;; 03:7053 ????????
    db   $26, $16, $04, $00
    
    db   $2f, $23, $5c, $2e        ;; 03:705f ????????
    db   $23, $5c, $41, $00, $40, $25, $f0, $74        ;; 03:7063 ????????
    db   $30, $23, $5c, $23, $04, $46, $21, $40        ;; 03:706b ????????
    db   $46, $22, $94, $48, $21, $c2, $4f, $14        ;; 03:7073 ????????
    db   $0b, $04, $00
    
    db   $2f, $ff, $5c, $2e, $ff        ;; 03:707e ????????
    db   $5c, $4b, $00, $40, $25, $20, $7b, $30        ;; 03:7083 ????????
    db   $ff, $5c, $23, $40, $46, $21, $80, $46        ;; 03:708b ????????
    db   $22, $94, $48, $21, $c2, $4f, $0a, $12        ;; 03:7093 ????????
    db   $04, $00
    
    db   $2f, $b3, $5d, $2e, $b3, $5d        ;; 03:709d ????????
    db   $4b, $80, $56, $27, $f8, $77, $30, $b3        ;; 03:70a3 ????????
    db   $5d, $23, $7c, $46, $21, $c0, $46, $22        ;; 03:70ab ????????
    db   $94, $48, $21, $c2, $4f, $50, $12, $04        ;; 03:70b3 ????????
    db   $00
    
    db   $2f, $53, $63, $2e, $53, $63, $4f        ;; 03:70bc ????????
    db   $20, $57, $28, $58, $59, $30, $53, $63        ;; 03:70c3 ????????
    db   $23, $f0, $46, $21, $00, $47, $22, $94        ;; 03:70cb ????????
    db   $48, $21, $c2, $4f, $7d, $33, $04, $00        ;; 03:70d3 ????????

    db   $2f, $ff, $5c, $2e, $ff, $5c, $4b, $00        ;; 03:70db ????????
    db   $40, $25, $20, $7b, $30, $ff, $5c, $23        ;; 03:70e3 ????????
    db   $40, $46, $21, $80, $46, $22, $94, $48        ;; 03:70eb ????????
    db   $21, $c2, $4f, $0a, $12, $04, $00
    
    db   $2f        ;; 03:70fa ????????
    db   $ff, $5c, $2e, $ff, $5c, $4b, $00, $40        ;; 03:70fb ????????
    db   $25, $20, $7b, $30, $ff, $5c, $23, $40        ;; 03:7103 ????????
    db   $46, $21, $80, $46, $22, $94, $48, $21        ;; 03:710b ????????
    db   $c2, $4f, $0a, $12, $04, $00
    
    db   $2f, $ff        ;; 03:7119 ????????
    db   $5c, $2e, $ff, $5c, $4b, $00, $40, $25        ;; 03:711b ????????
    db   $20, $7b, $30, $ff, $5c, $23, $40, $46        ;; 03:7123 ????????
    db   $21, $80, $46, $22, $94, $48, $21, $c2        ;; 03:712b ????????
    db   $4f, $0a, $12, $04, $00
.data_03_7138_LevelAnimeChannel:     
    db   $38, $00, $40        ;; 03:7138 ?????...
    db   $37, $00, $40, $40, $00, $40, $26, $00        ;; 03:713b ........
    db   $40, $39, $00, $40, $23, $d0, $47, $21        ;; 03:7143 ........
    db   $40, $47, $22, $45, $4c, $21, $a6, $50        ;; 03:714b ........
    db   $3e, $1e, $05, $00
    
    db   $38, $44, $47, $37        ;; 03:7157 ..w.????
    db   $44, $47, $40, $50, $59, $26, $10, $45        ;; 03:715b ????????
    db   $39, $44, $47, $23, $fc, $47, $21, $80        ;; 03:7163 ????????
    db   $47, $22, $45, $4c, $21, $a6, $50, $30        ;; 03:716b ????????
    db   $1e, $05, $00
    
    db   $38, $e4, $4c, $37, $e4        ;; 03:7176 ????????
    db   $4c, $48, $00, $40, $26, $08, $4b, $39        ;; 03:717b ????????
    db   $e4, $4c, $23, $50, $48, $21, $c0, $47        ;; 03:7183 ????????
    db   $22, $45, $4c, $21, $a6, $50, $38, $13        ;; 03:718b ????????
    db   $05, $00
    
    db   $38, $0c, $51, $37, $0c, $51        ;; 03:7195 ????????
    db   $41, $a0, $5e, $26, $68, $50, $39, $0c        ;; 03:719b ????????
    db   $51, $23, $d8, $48, $21, $00, $48, $22        ;; 03:71a3 ????????
    db   $45, $4c, $21, $a6, $50, $5e, $2a, $05        ;; 03:71ab ????????
    db   $00
    
    db   $38, $78, $60, $37, $78, $60, $48        ;; 03:71b4 ????????
    db   $f0, $55, $26, $28, $56, $39, $78, $60        ;; 03:71bb ????????
    db   $23, $7c, $49, $21, $40, $48, $22, $45        ;; 03:71c3 ????????
    db   $4c, $21, $a6, $50, $f5, $16, $05, $00        ;; 03:71cb ????????

    db   $38, $86, $75, $37, $86, $75, $4d, $00        ;; 03:71d3 ????????
    db   $40, $26, $58, $5c, $39, $86, $75, $23        ;; 03:71db ????????
    db   $10, $4a, $21, $80, $48, $22, $45, $4c        ;; 03:71e3 ????????
    db   $21, $a6, $50, $1e, $33, $05, $00
    
    db   $38        ;; 03:71f2 ????????
    db   $86, $75, $37, $86, $75, $4d, $00, $40        ;; 03:71f3 ????????
    db   $26, $58, $5c, $39, $86, $75, $23, $10        ;; 03:71fb ????????
    db   $4a, $21, $80, $48, $22, $45, $4c, $21        ;; 03:7203 ????????
    db   $a6, $50, $1e, $33, $05, $00
    
    db   $38, $86        ;; 03:7211 ????????
    db   $75, $37, $86, $75, $4d, $00, $40, $26        ;; 03:7213 ????????
    db   $58, $5c, $39, $86, $75, $23, $10, $4a        ;; 03:721b ????????
    db   $21, $80, $48, $22, $45, $4c, $21, $a6        ;; 03:7223 ????????
    db   $50, $1e, $33, $05, $00
    
    db   $38, $78, $60        ;; 03:7230 ????????
    db   $37, $78, $60, $48, $f0, $55, $26, $28        ;; 03:7233 ????????
    db   $56, $39, $78, $60, $23, $7c, $49, $21        ;; 03:723b ????????
    db   $40, $48, $22, $45, $4c, $21, $a6, $50        ;; 03:7243 ????????
    db   $f5, $16, $05, $00
.data_03_724f_LevelSuperheroShow:    
    db   $3e, $00, $40, $3d        ;; 03:724f ????....
    db   $00, $40, $49, $00, $40, $26, $00, $60        ;; 03:7253 ........
    db   $3f, $00, $40, $23, $94, $4a, $21, $c0        ;; 03:725b ........
    db   $48, $22, $b6, $53, $21, $a2, $51, $bf        ;; 03:7263 ........
    db   $1e, $06, $00
    
    db   $3b, $00, $40, $3a, $00        ;; 03:726e .w.?????
    db   $40, $49, $50, $5f, $26, $40, $67, $3c        ;; 03:7273 ????????
    db   $00, $40, $23, $0c, $4b, $21, $00, $49        ;; 03:727b ????????
    db   $22, $b6, $53, $21, $a2, $51, $c2, $44        ;; 03:7283 ????????
    db   $06, $00
    
    db   $3e, $62, $56, $3d, $62, $56        ;; 03:728d ????????
    db   $4a, $00, $40, $26, $b8, $6e, $3f, $62        ;; 03:7293 ????????
    db   $56, $23, $78, $4b, $21, $40, $49, $22        ;; 03:729b ????????
    db   $b6, $53, $21, $a2, $51, $43, $1e, $06        ;; 03:72a3 ????????
    db   $00                                           ;; 03:72ab ?

    db   $3e, $3c, $5e, $3d, $3c, $5e, $4a, $40        ;; 03:72ac ????????
    db   $58, $26, $48, $74, $3f, $3c, $5e, $23        ;; 03:72b4 ????????
    db   $d8, $4b, $21, $80, $49, $22, $b6, $53        ;; 03:72bc ????????
    db   $21, $a2, $51, $60, $1e, $06, $00
    
    db   $3e        ;; 03:72cb ????????
    db   $7c, $69, $3d, $7c, $69, $47, $80, $6b        ;; 03:72cc ????????
    db   $26, $00, $7a, $3f, $7c, $69, $23, $30        ;; 03:72d4 ????????
    db   $4c, $21, $c0, $49, $22, $b6, $53, $21        ;; 03:72dc ????????
    db   $a2, $51, $30, $22, $06, $00
    
    db   $3e, $dc        ;; 03:72e4 ????????
    db   $6f, $3d, $dc, $6f, $4a, $50, $7c, $26        ;; 03:72ec ????????
    db   $b8, $7e, $3f, $dc, $6f, $23, $58, $4c        ;; 03:72f4 ????????
    db   $21, $00, $4a, $22, $b6, $53, $21, $a2        ;; 03:72fc ????????
    db   $51, $0a, $08, $06, $00
.data_03_7309_LevelGextremeSports:     
    db   $3b, $88, $73        ;; 03:7309 ????????
    db   $3a, $88, $73, $4d, $10, $51, $27, $00        ;; 03:730c ????????
    db   $40, $3c, $88, $73, $23, $74, $4c, $21        ;; 03:7314 ????????
    db   $40, $4a, $22, $87, $59, $21, $44, $52        ;; 03:731c ????????
    db   $30, $30, $07, $00
    
    db   $32, $9c, $7a, $31        ;; 03:7328 ????????
    db   $9c, $7a, $43, $00, $5c, $25, $00, $40        ;; 03:732c ????????
    db   $33, $9c, $7a, $23, $0c, $41, $21, $80        ;; 03:7334 ????????
    db   $41, $22, $87, $59, $21, $44, $52, $14        ;; 03:733c ????????
    db   $16, $07, $00
    
    db   $32, $9c, $7a, $31, $9c        ;; 03:7347 ????????
    db   $7a, $43, $00, $5c, $25, $00, $40, $33        ;; 03:734c ????????
    db   $9c, $7a, $23, $0c, $41, $21, $80, $41        ;; 03:7354 ????????
    db   $22, $87, $59, $21, $44, $52, $14, $16        ;; 03:735c ????????
    db   $07, $00
    
    db   $32, $9c, $7a, $31, $9c, $7a        ;; 03:7366 ????????
    db   $43, $00, $5c, $25, $00, $40, $33, $9c        ;; 03:736c ????????
    db   $7a, $23, $0c, $41, $21, $80, $41, $22        ;; 03:7374 ????????
    db   $87, $59, $21, $44, $52, $14, $16, $07        ;; 03:737c ????????
    db   $00
.data_03_7385_LevelMarsupialMadness:     
    db   $35, $b4, $72, $34, $b4, $72, $40        ;; 03:7385 ????????
    db   $30, $72, $27, $d8, $4d, $36, $b4, $72        ;; 03:738c ????????
    db   $23, $08, $4d, $21, $80, $4a, $22, $18        ;; 03:7394 ????????
    db   $5a, $21, $47, $52, $20, $42, $08, $00        ;; 03:739c ????????
.data_03_73a4_LevelWWGexWrestling: 
    db   $35, $f4, $7a, $34, $f4, $7a, $4f, $00        ;; 03:73a4 ????????
    db   $40, $28, $d8, $53, $36, $f4, $7a, $23        ;; 03:73ac ????????
    db   $8c, $4d, $21, $c0, $4a, $22, $f9, $5a        ;; 03:73b4 ????????
    db   $21, $4a, $52, $18, $12, $09, $01
.data_03_73c3_LevelLizardOfOz:
    db   $38        ;; 03:73c3 ????????
    db   $80, $7b, $37, $80, $7b, $41, $70, $79        ;; 03:73c4 ????????
    db   $25, $10, $7e, $39, $80, $7b, $23, $bc        ;; 03:73cc ????????
    db   $4d, $21, $00, $4b, $22, $0a, $5b, $21        ;; 03:73d4 ????????
    db   $4d, $52, $0f, $08, $0a, $00
.data_03_73e2_LevelChannelZ:
    db   $2f, $00        ;; 03:73e2 ????????
    db   $40, $2e, $00, $40, $4c, $00, $40, $27        ;; 03:73e4 ????????
    db   $68, $6a, $30, $00, $40, $23, $d8, $4d        ;; 03:73ec ????????
    db   $21, $40, $4b, $22, $2b, $5b, $21, $50        ;; 03:73f4 ????????
    db   $52, $28, $38, $0b, $00
    
    db   $2f, $c0, $48        ;; 03:7301 ????????
    db   $2e, $c0, $48, $4c, $00, $60, $27, $90        ;; 03:7404 ????????
    db   $6f, $30, $c0, $48, $23, $08, $4e, $21        ;; 03:740c ????????
    db   $80, $4b, $22, $2b, $5b, $21, $50, $52        ;; 03:7414 ????????
    db   $1f, $11, $0b, $00
    
    db   $2f, $cf, $4a, $2e        ;; 03:7420 ????????
    db   $cf, $4a, $4c, $c0, $68, $27, $58, $72        ;; 03:7424 ????????
    db   $30, $cf, $4a, $23, $1c, $4e, $21, $c0        ;; 03:742c ????????
    db   $4b, $22, $2b, $5b, $21, $50, $52, $28        ;; 03:7434 ????????
    db   $20, $0b, $00
    
    db   $2f, $cf, $4f, $2e, $cf        ;; 03:743f ????????
    db   $4f, $4f, $f0, $4a, $27, $b0, $74, $30        ;; 03:7444 ????????
    db   $cf, $4f, $23, $44, $4e, $21, $00, $4c        ;; 03:744c ????????
    db   $22, $2b, $5b, $21, $50, $52, $28, $20        ;; 03:7454 ????????
    db   $0b, $00
    
    db   $2f, $cf, $54, $2e, $cf, $54        ;; 03:745e ????????
    db   $4c, $f0, $74, $27, $10, $77, $30, $cf        ;; 03:7464 ????????
    db   $54, $23, $6c, $4e, $21, $40, $4c, $22        ;; 03:746c ????????
    db   $2b, $5b, $21, $50, $52, $0f, $08, $0b        ;; 03:7474 ????????
    db   $00                                           ;; 03:747c ?
