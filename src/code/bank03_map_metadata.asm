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
    dw   .data_03_6d1a_LevelData_GexCave1
    dw   .data_03_6d96_LevelData_HolidayTV1
    dw   .data_03_6e12_LevelData_MysteryTV1
    dw   .data_03_6f48_LevelData_TutTV1
    dw   .data_03_7021_LevelData_WesternStation1
    dw   .data_03_7138_LevelData_AnimeChannel1
    dw   .data_03_724f_LevelData_SuperheroShow1
    dw   .data_03_7309_LevelData_GextremeSports1
    dw   .data_03_7385_LevelData_MarsupialMadness1
    dw   .data_03_73a4_LevelData_WWGexWrestling1
    dw   .data_03_73c3_LevelData_LizardOfOz1
    dw   .data_03_73e2_LevelData_ChannelZ1
    dw   .data_03_6d39_LevelData_GexCave2
    dw   .data_03_6d58_LevelData_GexCave3
    dw   .data_03_6d77_LevelData_GexCave4
    dw   .data_03_6db5_LevelData_HolidayTV2
    dw   .data_03_6dd4_LevelData_HolidayTV3
    dw   .data_03_6df3_LevelData_HolidayTV4
    dw   .data_03_6e31_LevelData_MysteryTV2
    dw   .data_03_6e50_LevelData_MysteryTV3
    dw   .data_03_6e6f_LevelData_MysteryTV4
    dw   .data_03_6e8e_LevelData_MysteryTV5
    dw   .data_03_6ead_LevelData_MysteryTV6
    dw   .data_03_6ecc_LevelData_MysteryTV7
    dw   .data_03_6eeb_LevelData_MysteryTV8
    dw   .data_03_6f0a_LevelData_MysteryTV9
    dw   .data_03_6f29_LevelData_MysteryTV10
    dw   .data_03_6f67_LevelData_TutTV2
    dw   .data_03_6f86_LevelData_TutTV3
    dw   .data_03_6fa5_LevelData_TutTV4
    dw   .data_03_6fc4_LevelData_TutTV5
    dw   .data_03_6fe3_LevelData_TutTV6
    dw   .data_03_7002_LevelData_TutTV7
    dw   .data_03_7040_LevelData_WesternStation2
    dw   .data_03_705f_LevelData_WesternStation3
    dw   .data_03_707e_LevelData_WesternStation4
    dw   .data_03_709d_LevelData_WesternStation5
    dw   .data_03_70bc_LevelData_WesternStation6
    dw   .data_03_70db_LevelData_WesternStation7
    dw   .data_03_70fa_LevelData_WesternStation8
    dw   .data_03_7119_LevelData_WesternStation9
    dw   .data_03_7157_LevelData_AnimeChannel2
    dw   .data_03_7176_LevelData_AnimeChannel3
    dw   .data_03_7195_LevelData_AnimeChannel4
    dw   .data_03_71b4_LevelData_AnimeChannel5
    dw   .data_03_71d3_LevelData_AnimeChannel6
    dw   .data_03_71f2_LevelData_AnimeChannel7
    dw   .data_03_7211_LevelData_AnimeChannel8
    dw   .data_03_7230_LevelData_AnimeChannel9
    dw   .data_03_726e_LevelData_SuperheroShow2
    dw   .data_03_728d_LevelData_SuperheroShow3
    dw   .data_03_72ac_LevelData_SuperheroShow4
    dw   .data_03_72cb_LevelData_SuperheroShow5
    dw   .data_03_72ea_LevelData_SuperheroShow6
    dw   .data_03_7328_LevelData_GextremeSports2
    dw   .data_03_7347_LevelData_GextremeSports3
    dw   .data_03_7366_LevelData_GextremeSports4
    dw   .data_03_7401_LevelData_ChannelZ2
    dw   .data_03_7420_LevelData_ChannelZ3
    dw   .data_03_743f_LevelData_ChannelZ4
    dw   .data_03_745e_LevelData_ChannelZ5
.data_03_6d1a_LevelData_GexCave1:
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
.data_03_6d39_LevelData_GexCave2:
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
.data_03_6d58_LevelData_GexCave3:
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
.data_03_6d77_LevelData_GexCave4:
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
.data_03_6d96_LevelData_HolidayTV1:
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
.data_03_6db5_LevelData_HolidayTV2:
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
.data_03_6dd4_LevelData_HolidayTV3:
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
.data_03_6df3_LevelData_HolidayTV4:
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
.data_03_6e12_LevelData_MysteryTV1:
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
.data_03_6e31_LevelData_MysteryTV2:
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
.data_03_6e50_LevelData_MysteryTV3:
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
.data_03_6e6f_LevelData_MysteryTV4:
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
.data_03_6e8e_LevelData_MysteryTV5:
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
.data_03_6ead_LevelData_MysteryTV6:
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
.data_03_6ecc_LevelData_MysteryTV7:
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
.data_03_6eeb_LevelData_MysteryTV8:
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
.data_03_6f0a_LevelData_MysteryTV9:
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
.data_03_6f29_LevelData_MysteryTV10:
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
.data_03_6f48_LevelData_TutTV1:
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
.data_03_6f67_LevelData_TutTV2:
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
.data_03_6f86_LevelData_TutTV3:
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
.data_03_6fa5_LevelData_TutTV4:
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
.data_03_6fc4_LevelData_TutTV5:
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
.data_03_6fe3_LevelData_TutTV6:
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
.data_03_7002_LevelData_TutTV7:
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
.data_03_7021_LevelData_WesternStation1:
    db   BANK(WesternStation_1_map)
    dw   WesternStation_1_map
    db   BANK(WesternStation_1_map_extended)
    dw   WesternStation_1_map_extended
    db   BANK(WesternStation_1_tileset)
    dw   WesternStation_1_tileset
    db   BANK(WesternStation_1_blockset)
    dw   WesternStation_1_blockset
    db   BANK(WesternStation_1_collision)
    dw   WesternStation_1_collision
    db   BANK(WesternStation_1_collision_blockset)
    dw   WesternStation_1_collision_blockset
    db   BANK(WesternStation_1_palette)
    dw   WesternStation_1_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $28, $16, $04, $00
.data_03_7040_LevelData_WesternStation2:
    db   BANK(WesternStation_2_map)
    dw   WesternStation_2_map
    db   BANK(WesternStation_2_map_extended)
    dw   WesternStation_2_map_extended
    db   BANK(WesternStation_2_tileset)
    dw   WesternStation_2_tileset
    db   BANK(WesternStation_2_blockset)
    dw   WesternStation_2_blockset
    db   BANK(WesternStation_2_collision)
    dw   WesternStation_2_collision
    db   BANK(WesternStation_2_collision_blockset)
    dw   WesternStation_2_collision_blockset
    db   BANK(WesternStation_2_palette)
    dw   WesternStation_2_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $26, $16, $04, $00
.data_03_705f_LevelData_WesternStation3:
    db   BANK(WesternStation_3_map)
    dw   WesternStation_3_map
    db   BANK(WesternStation_3_map_extended)
    dw   WesternStation_3_map_extended
    db   BANK(WesternStation_3_tileset)
    dw   WesternStation_3_tileset
    db   BANK(WesternStation_3_blockset)
    dw   WesternStation_3_blockset
    db   BANK(WesternStation_3_collision)
    dw   WesternStation_3_collision
    db   BANK(WesternStation_3_collision_blockset)
    dw   WesternStation_3_collision_blockset
    db   BANK(WesternStation_3_palette)
    dw   WesternStation_3_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $14, $0b, $04, $00
.data_03_707e_LevelData_WesternStation4:
    db   BANK(WesternStation_4_map)
    dw   WesternStation_4_map
    db   BANK(WesternStation_4_map_extended)
    dw   WesternStation_4_map_extended
    db   BANK(WesternStation_4_tileset)
    dw   WesternStation_4_tileset
    db   BANK(WesternStation_4_blockset)
    dw   WesternStation_4_blockset
    db   BANK(WesternStation_4_collision)
    dw   WesternStation_4_collision
    db   BANK(WesternStation_4_collision_blockset)
    dw   WesternStation_4_collision_blockset
    db   BANK(WesternStation_4_palette)
    dw   WesternStation_4_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_709d_LevelData_WesternStation5:
    db   BANK(WesternStation_5_map)
    dw   WesternStation_5_map
    db   BANK(WesternStation_5_map_extended)
    dw   WesternStation_5_map_extended
    db   BANK(WesternStation_5_tileset)
    dw   WesternStation_5_tileset
    db   BANK(WesternStation_5_blockset)
    dw   WesternStation_5_blockset
    db   BANK(WesternStation_5_collision)
    dw   WesternStation_5_collision
    db   BANK(WesternStation_5_collision_blockset)
    dw   WesternStation_5_collision_blockset
    db   BANK(WesternStation_5_palette)
    dw   WesternStation_5_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $50, $12, $04, $00
.data_03_70bc_LevelData_WesternStation6:
    db   BANK(WesternStation_6_map)
    dw   WesternStation_6_map
    db   BANK(WesternStation_6_map_extended)
    dw   WesternStation_6_map_extended
    db   BANK(WesternStation_6_tileset)
    dw   WesternStation_6_tileset
    db   BANK(WesternStation_6_blockset)
    dw   WesternStation_6_blockset
    db   BANK(WesternStation_6_collision)
    dw   WesternStation_6_collision
    db   BANK(WesternStation_6_collision_blockset)
    dw   WesternStation_6_collision_blockset
    db   BANK(WesternStation_6_palette)
    dw   WesternStation_6_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $7d, $33, $04, $00
.data_03_70db_LevelData_WesternStation7:
    db   BANK(WesternStation_4_map)
    dw   WesternStation_4_map
    db   BANK(WesternStation_4_map_extended)
    dw   WesternStation_4_map_extended
    db   BANK(WesternStation_4_tileset)
    dw   WesternStation_4_tileset
    db   BANK(WesternStation_4_blockset)
    dw   WesternStation_4_blockset
    db   BANK(WesternStation_4_collision)
    dw   WesternStation_4_collision
    db   BANK(WesternStation_4_collision_blockset)
    dw   WesternStation_4_collision_blockset
    db   BANK(WesternStation_4_palette)
    dw   WesternStation_4_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_70fa_LevelData_WesternStation8:
    db   BANK(WesternStation_4_map)
    dw   WesternStation_4_map
    db   BANK(WesternStation_4_map_extended)
    dw   WesternStation_4_map_extended
    db   BANK(WesternStation_4_tileset)
    dw   WesternStation_4_tileset
    db   BANK(WesternStation_4_blockset)
    dw   WesternStation_4_blockset
    db   BANK(WesternStation_4_collision)
    dw   WesternStation_4_collision
    db   BANK(WesternStation_4_collision_blockset)
    dw   WesternStation_4_collision_blockset
    db   BANK(WesternStation_4_palette)
    dw   WesternStation_4_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_7119_LevelData_WesternStation9:
    db   BANK(WesternStation_4_map)
    dw   WesternStation_4_map
    db   BANK(WesternStation_4_map_extended)
    dw   WesternStation_4_map_extended
    db   BANK(WesternStation_4_tileset)
    dw   WesternStation_4_tileset
    db   BANK(WesternStation_4_blockset)
    dw   WesternStation_4_blockset
    db   BANK(WesternStation_4_collision)
    dw   WesternStation_4_collision
    db   BANK(WesternStation_4_collision_blockset)
    dw   WesternStation_4_collision_blockset
    db   BANK(WesternStation_4_palette)
    dw   WesternStation_4_palette
    db   BANK(WesternStation_object_list)
    dw   WesternStation_object_list
    db   BANK(WesternStation_collectible_list)
    dw   WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_7138_LevelData_AnimeChannel1:     
    db   BANK(AnimeChannel_1_map)
    dw   AnimeChannel_1_map
    db   BANK(AnimeChannel_1_map_extended)
    dw   AnimeChannel_1_map_extended
    db   BANK(AnimeChannel_1_tileset)
    dw   AnimeChannel_1_tileset
    db   BANK(AnimeChannel_1_blockset)
    dw   AnimeChannel_1_blockset
    db   BANK(AnimeChannel_1_collision)
    dw   AnimeChannel_1_collision
    db   BANK(AnimeChannel_1_collision_blockset)
    dw   AnimeChannel_1_collision_blockset
    db   BANK(AnimeChannel_1_palette)
    dw   AnimeChannel_1_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $3e, $1e, $05, $00   
.data_03_7157_LevelData_AnimeChannel2:
    db   BANK(AnimeChannel_2_map)
    dw   AnimeChannel_2_map
    db   BANK(AnimeChannel_2_map_extended)
    dw   AnimeChannel_2_map_extended
    db   BANK(AnimeChannel_2_tileset)
    dw   AnimeChannel_2_tileset
    db   BANK(AnimeChannel_2_blockset)
    dw   AnimeChannel_2_blockset
    db   BANK(AnimeChannel_2_collision)
    dw   AnimeChannel_2_collision
    db   BANK(AnimeChannel_2_collision_blockset)
    dw   AnimeChannel_2_collision_blockset
    db   BANK(AnimeChannel_2_palette)
    dw   AnimeChannel_2_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $30, $1e, $05, $00
.data_03_7176_LevelData_AnimeChannel3:
    db   BANK(AnimeChannel_3_map)
    dw   AnimeChannel_3_map
    db   BANK(AnimeChannel_3_map_extended)
    dw   AnimeChannel_3_map_extended
    db   BANK(AnimeChannel_3_tileset)
    dw   AnimeChannel_3_tileset
    db   BANK(AnimeChannel_3_blockset)
    dw   AnimeChannel_3_blockset
    db   BANK(AnimeChannel_3_collision)
    dw   AnimeChannel_3_collision
    db   BANK(AnimeChannel_3_collision_blockset)
    dw   AnimeChannel_3_collision_blockset
    db   BANK(AnimeChannel_3_palette)
    dw   AnimeChannel_3_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $38, $13, $05, $00
.data_03_7195_LevelData_AnimeChannel4:
    db   BANK(AnimeChannel_4_map)
    dw   AnimeChannel_4_map
    db   BANK(AnimeChannel_4_map_extended)
    dw   AnimeChannel_4_map_extended
    db   BANK(AnimeChannel_4_tileset)
    dw   AnimeChannel_4_tileset
    db   BANK(AnimeChannel_4_blockset)
    dw   AnimeChannel_4_blockset
    db   BANK(AnimeChannel_4_collision)
    dw   AnimeChannel_4_collision
    db   BANK(AnimeChannel_4_collision_blockset)
    dw   AnimeChannel_4_collision_blockset
    db   BANK(AnimeChannel_4_palette)
    dw   AnimeChannel_4_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $5e, $2a, $05, $00
.data_03_71b4_LevelData_AnimeChannel5:
    db   BANK(AnimeChannel_5_map)
    dw   AnimeChannel_5_map
    db   BANK(AnimeChannel_5_map_extended)
    dw   AnimeChannel_5_map_extended
    db   BANK(AnimeChannel_5_tileset)
    dw   AnimeChannel_5_tileset
    db   BANK(AnimeChannel_5_blockset)
    dw   AnimeChannel_5_blockset
    db   BANK(AnimeChannel_5_collision)
    dw   AnimeChannel_5_collision
    db   BANK(AnimeChannel_5_collision_blockset)
    dw   AnimeChannel_5_collision_blockset
    db   BANK(AnimeChannel_5_palette)
    dw   AnimeChannel_5_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $f5, $16, $05, $00
.data_03_71d3_LevelData_AnimeChannel6:
    db   BANK(AnimeChannel_6_map)
    dw   AnimeChannel_6_map
    db   BANK(AnimeChannel_6_map_extended)
    dw   AnimeChannel_6_map_extended
    db   BANK(AnimeChannel_6_tileset)
    dw   AnimeChannel_6_tileset
    db   BANK(AnimeChannel_6_blockset)
    dw   AnimeChannel_6_blockset
    db   BANK(AnimeChannel_6_collision)
    dw   AnimeChannel_6_collision
    db   BANK(AnimeChannel_6_collision_blockset)
    dw   AnimeChannel_6_collision_blockset
    db   BANK(AnimeChannel_6_palette)
    dw   AnimeChannel_6_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $1e, $33, $05, $00
.data_03_71f2_LevelData_AnimeChannel7:
    db   BANK(AnimeChannel_6_map)
    dw   AnimeChannel_6_map
    db   BANK(AnimeChannel_6_map_extended)
    dw   AnimeChannel_6_map_extended
    db   BANK(AnimeChannel_6_tileset)
    dw   AnimeChannel_6_tileset
    db   BANK(AnimeChannel_6_blockset)
    dw   AnimeChannel_6_blockset
    db   BANK(AnimeChannel_6_collision)
    dw   AnimeChannel_6_collision
    db   BANK(AnimeChannel_6_collision_blockset)
    dw   AnimeChannel_6_collision_blockset
    db   BANK(AnimeChannel_6_palette)
    dw   AnimeChannel_6_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $1e, $33, $05, $00
.data_03_7211_LevelData_AnimeChannel8:
    db   BANK(AnimeChannel_6_map)
    dw   AnimeChannel_6_map
    db   BANK(AnimeChannel_6_map_extended)
    dw   AnimeChannel_6_map_extended
    db   BANK(AnimeChannel_6_tileset)
    dw   AnimeChannel_6_tileset
    db   BANK(AnimeChannel_6_blockset)
    dw   AnimeChannel_6_blockset
    db   BANK(AnimeChannel_6_collision)
    dw   AnimeChannel_6_collision
    db   BANK(AnimeChannel_6_collision_blockset)
    dw   AnimeChannel_6_collision_blockset
    db   BANK(AnimeChannel_6_palette)
    dw   AnimeChannel_6_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $1e, $33, $05, $00
.data_03_7230_LevelData_AnimeChannel9:
    db   BANK(AnimeChannel_5_map)
    dw   AnimeChannel_5_map
    db   BANK(AnimeChannel_5_map_extended)
    dw   AnimeChannel_5_map_extended
    db   BANK(AnimeChannel_5_tileset)
    dw   AnimeChannel_5_tileset
    db   BANK(AnimeChannel_5_blockset)
    dw   AnimeChannel_5_blockset
    db   BANK(AnimeChannel_5_collision)
    dw   AnimeChannel_5_collision
    db   BANK(AnimeChannel_5_collision_blockset)
    dw   AnimeChannel_5_collision_blockset
    db   BANK(AnimeChannel_5_palette)
    dw   AnimeChannel_5_palette
    db   BANK(AnimeChannel_object_list)
    dw   AnimeChannel_object_list
    db   BANK(AnimeChannel_collectible_list)
    dw   AnimeChannel_collectible_list
    db   $f5, $16, $05, $00
.data_03_724f_LevelData_SuperheroShow1:
    db   BANK(SuperheroShow_1_map)
    dw   SuperheroShow_1_map
    db   BANK(SuperheroShow_1_map_extended)
    dw   SuperheroShow_1_map_extended
    db   BANK(SuperheroShow_1_tileset)
    dw   SuperheroShow_1_tileset
    db   BANK(SuperheroShow_1_blockset)
    dw   SuperheroShow_1_blockset
    db   BANK(SuperheroShow_1_collision)
    dw   SuperheroShow_1_collision
    db   BANK(SuperheroShow_1_collision_blockset)
    dw   SuperheroShow_1_collision_blockset
    db   BANK(SuperheroShow_1_palette)
    dw   SuperheroShow_1_palette
    db   BANK(SuperheroShow_object_list)
    dw   SuperheroShow_object_list
    db   BANK(SuperheroShow_collectible_list)
    dw   SuperheroShow_collectible_list
    db   $bf, $1e, $06, $00
.data_03_726e_LevelData_SuperheroShow2:
    db   BANK(SuperheroShow_2_map)
    dw   SuperheroShow_2_map
    db   BANK(SuperheroShow_2_map_extended)
    dw   SuperheroShow_2_map_extended
    db   BANK(SuperheroShow_2_tileset)
    dw   SuperheroShow_2_tileset
    db   BANK(SuperheroShow_2_blockset)
    dw   SuperheroShow_2_blockset
    db   BANK(SuperheroShow_2_collision)
    dw   SuperheroShow_2_collision
    db   BANK(SuperheroShow_2_collision_blockset)
    dw   SuperheroShow_2_collision_blockset
    db   BANK(SuperheroShow_2_palette)
    dw   SuperheroShow_2_palette
    db   BANK(SuperheroShow_object_list)
    dw   SuperheroShow_object_list
    db   BANK(SuperheroShow_collectible_list)
    dw   SuperheroShow_collectible_list
    db   $c2, $44, $06, $00
.data_03_728d_LevelData_SuperheroShow3:
    db   BANK(SuperheroShow_3_map)
    dw   SuperheroShow_3_map
    db   BANK(SuperheroShow_3_map_extended)
    dw   SuperheroShow_3_map_extended
    db   BANK(SuperheroShow_3_tileset)
    dw   SuperheroShow_3_tileset
    db   BANK(SuperheroShow_3_blockset)
    dw   SuperheroShow_3_blockset
    db   BANK(SuperheroShow_3_collision)
    dw   SuperheroShow_3_collision
    db   BANK(SuperheroShow_3_collision_blockset)
    dw   SuperheroShow_3_collision_blockset
    db   BANK(SuperheroShow_3_palette)
    dw   SuperheroShow_3_palette
    db   BANK(SuperheroShow_object_list)
    dw   SuperheroShow_object_list
    db   BANK(SuperheroShow_collectible_list)
    dw   SuperheroShow_collectible_list
    db   $43, $1e, $06, $00
.data_03_72ac_LevelData_SuperheroShow4:
    db   BANK(SuperheroShow_4_map)
    dw   SuperheroShow_4_map
    db   BANK(SuperheroShow_4_map_extended)
    dw   SuperheroShow_4_map_extended
    db   BANK(SuperheroShow_4_tileset)
    dw   SuperheroShow_4_tileset
    db   BANK(SuperheroShow_4_blockset)
    dw   SuperheroShow_4_blockset
    db   BANK(SuperheroShow_4_collision)
    dw   SuperheroShow_4_collision
    db   BANK(SuperheroShow_4_collision_blockset)
    dw   SuperheroShow_4_collision_blockset
    db   BANK(SuperheroShow_4_palette)
    dw   SuperheroShow_4_palette
    db   BANK(SuperheroShow_object_list)
    dw   SuperheroShow_object_list
    db   BANK(SuperheroShow_collectible_list)
    dw   SuperheroShow_collectible_list
    db   $60, $1e, $06, $00
.data_03_72cb_LevelData_SuperheroShow5:
    db   BANK(SuperheroShow_5_map)
    dw   SuperheroShow_5_map
    db   BANK(SuperheroShow_5_map_extended)
    dw   SuperheroShow_5_map_extended
    db   BANK(SuperheroShow_5_tileset)
    dw   SuperheroShow_5_tileset
    db   BANK(SuperheroShow_5_blockset)
    dw   SuperheroShow_5_blockset
    db   BANK(SuperheroShow_5_collision)
    dw   SuperheroShow_5_collision
    db   BANK(SuperheroShow_5_collision_blockset)
    dw   SuperheroShow_5_collision_blockset
    db   BANK(SuperheroShow_5_palette)
    dw   SuperheroShow_5_palette
    db   BANK(SuperheroShow_object_list)
    dw   SuperheroShow_object_list
    db   BANK(SuperheroShow_collectible_list)
    dw   SuperheroShow_collectible_list
    db   $30, $22, $06, $00
.data_03_72ea_LevelData_SuperheroShow6:
    db   BANK(SuperheroShow_6_map)
    dw   SuperheroShow_6_map
    db   BANK(SuperheroShow_6_map_extended)
    dw   SuperheroShow_6_map_extended
    db   BANK(SuperheroShow_6_tileset)
    dw   SuperheroShow_6_tileset
    db   BANK(SuperheroShow_6_blockset)
    dw   SuperheroShow_6_blockset
    db   BANK(SuperheroShow_6_collision)
    dw   SuperheroShow_6_collision
    db   BANK(SuperheroShow_6_collision_blockset)
    dw   SuperheroShow_6_collision_blockset
    db   BANK(SuperheroShow_6_palette)
    dw   SuperheroShow_6_palette
    db   BANK(SuperheroShow_object_list)
    dw   SuperheroShow_object_list
    db   BANK(SuperheroShow_collectible_list)
    dw   SuperheroShow_collectible_list
    db   $0a, $08, $06, $00
.data_03_7309_LevelData_GextremeSports1:
    db   BANK(GextremeSports_1_map)
    dw   GextremeSports_1_map
    db   BANK(GextremeSports_1_map_extended)
    dw   GextremeSports_1_map_extended
    db   BANK(GextremeSports_1_tileset)
    dw   GextremeSports_1_tileset
    db   BANK(GextremeSports_1_blockset)
    dw   GextremeSports_1_blockset
    db   BANK(GextremeSports_1_collision)
    dw   GextremeSports_1_collision
    db   BANK(GextremeSports_1_collision_blockset)
    dw   GextremeSports_1_collision_blockset
    db   BANK(GextremeSports_1_palette)
    dw   GextremeSports_1_palette
    db   BANK(GextremeSports_object_list)
    dw   GextremeSports_object_list
    db   BANK(GextremeSports_collectible_list)
    dw   GextremeSports_collectible_list
    db   $30, $30, $07, $00
.data_03_7328_LevelData_GextremeSports2:
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
    db   BANK(GextremeSports_object_list)
    dw   GextremeSports_object_list
    db   BANK(GextremeSports_collectible_list)
    dw   GextremeSports_collectible_list
    db   $14, $16, $07, $00
.data_03_7347_LevelData_GextremeSports3:
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
    db   BANK(GextremeSports_object_list)
    dw   GextremeSports_object_list
    db   BANK(GextremeSports_collectible_list)
    dw   GextremeSports_collectible_list
    db   $14, $16, $07, $00
.data_03_7366_LevelData_GextremeSports4:
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
    db   BANK(GextremeSports_object_list)
    dw   GextremeSports_object_list
    db   BANK(GextremeSports_collectible_list)
    dw   GextremeSports_collectible_list
    db   $14, $16, $07, $00
.data_03_7385_LevelData_MarsupialMadness1:
    db   BANK(MarsupialMadness_1_map)
    dw   MarsupialMadness_1_map
    db   BANK(MarsupialMadness_1_map_extended)
    dw   MarsupialMadness_1_map_extended
    db   BANK(MarsupialMadness_1_tileset)
    dw   MarsupialMadness_1_tileset
    db   BANK(MarsupialMadness_1_blockset)
    dw   MarsupialMadness_1_blockset
    db   BANK(MarsupialMadness_1_collision)
    dw   MarsupialMadness_1_collision
    db   BANK(MarsupialMadness_1_collision_blockset)
    dw   MarsupialMadness_1_collision_blockset
    db   BANK(MarsupialMadness_1_palette)
    dw   MarsupialMadness_1_palette
    db   BANK(MarsupialMadness_object_list)
    dw   MarsupialMadness_object_list
    db   BANK(MarsupialMadness_collectible_list)
    dw   MarsupialMadness_collectible_list
    db   $20, $42, $08, $00
.data_03_73a4_LevelData_WWGexWrestling1:
    db   BANK(WWGexWrestling_1_map)
    dw   WWGexWrestling_1_map
    db   BANK(WWGexWrestling_1_map_extended)
    dw   WWGexWrestling_1_map_extended
    db   BANK(WWGexWrestling_1_tileset)
    dw   WWGexWrestling_1_tileset
    db   BANK(WWGexWrestling_1_blockset)
    dw   WWGexWrestling_1_blockset
    db   BANK(WWGexWrestling_1_collision)
    dw   WWGexWrestling_1_collision
    db   BANK(WWGexWrestling_1_collision_blockset)
    dw   WWGexWrestling_1_collision_blockset
    db   BANK(WWGexWrestling_1_palette)
    dw   WWGexWrestling_1_palette
    db   BANK(WWGexWrestling_object_list)
    dw   WWGexWrestling_object_list
    db   BANK(WWGexWrestling_collectible_list)
    dw   WWGexWrestling_collectible_list
    db   $18, $12, $09, $01
.data_03_73c3_LevelData_LizardOfOz1:
    db   BANK(LizardOfOz_1_map)
    dw   LizardOfOz_1_map
    db   BANK(LizardOfOz_1_map_extended)
    dw   LizardOfOz_1_map_extended
    db   BANK(LizardOfOz_1_tileset)
    dw   LizardOfOz_1_tileset
    db   BANK(LizardOfOz_1_blockset)
    dw   LizardOfOz_1_blockset
    db   BANK(LizardOfOz_1_collision)
    dw   LizardOfOz_1_collision
    db   BANK(LizardOfOz_1_collision_blockset)
    dw   LizardOfOz_1_collision_blockset
    db   BANK(LizardOfOz_1_palette)
    dw   LizardOfOz_1_palette
    db   BANK(LizardOfOz_object_list)
    dw   LizardOfOz_object_list
    db   BANK(LizardOfOz_collectible_list)
    dw   LizardOfOz_collectible_list
    db   $0f, $08, $0a, $00
.data_03_73e2_LevelData_ChannelZ1:
    db   BANK(ChannelZ_1_map)
    dw   ChannelZ_1_map
    db   BANK(ChannelZ_1_map_extended)
    dw   ChannelZ_1_map_extended
    db   BANK(ChannelZ_1_tileset)
    dw   ChannelZ_1_tileset
    db   BANK(ChannelZ_1_blockset)
    dw   ChannelZ_1_blockset
    db   BANK(ChannelZ_1_collision)
    dw   ChannelZ_1_collision
    db   BANK(ChannelZ_1_collision_blockset)
    dw   ChannelZ_1_collision_blockset
    db   BANK(ChannelZ_1_palette)
    dw   ChannelZ_1_palette
    db   BANK(ChannelZ_object_list)
    dw   ChannelZ_object_list
    db   BANK(ChannelZ_collectible_list)
    dw   ChannelZ_collectible_list
    db   $28, $38, $0b, $00
.data_03_7401_LevelData_ChannelZ2:
    db   BANK(ChannelZ_2_map)
    dw   ChannelZ_2_map
    db   BANK(ChannelZ_2_map_extended)
    dw   ChannelZ_2_map_extended
    db   BANK(ChannelZ_2_tileset)
    dw   ChannelZ_2_tileset
    db   BANK(ChannelZ_2_blockset)
    dw   ChannelZ_2_blockset
    db   BANK(ChannelZ_2_collision)
    dw   ChannelZ_2_collision
    db   BANK(ChannelZ_2_collision_blockset)
    dw   ChannelZ_2_collision_blockset
    db   BANK(ChannelZ_2_palette)
    dw   ChannelZ_2_palette
    db   BANK(ChannelZ_object_list)
    dw   ChannelZ_object_list
    db   BANK(ChannelZ_collectible_list)
    dw   ChannelZ_collectible_list
    db   $1f, $11, $0b, $00
.data_03_7420_LevelData_ChannelZ3:
    db   BANK(ChannelZ_3_map)
    dw   ChannelZ_3_map
    db   BANK(ChannelZ_3_map_extended)
    dw   ChannelZ_3_map_extended
    db   BANK(ChannelZ_3_tileset)
    dw   ChannelZ_3_tileset
    db   BANK(ChannelZ_3_blockset)
    dw   ChannelZ_3_blockset
    db   BANK(ChannelZ_3_collision)
    dw   ChannelZ_3_collision
    db   BANK(ChannelZ_3_collision_blockset)
    dw   ChannelZ_3_collision_blockset
    db   BANK(ChannelZ_3_palette)
    dw   ChannelZ_3_palette
    db   BANK(ChannelZ_object_list)
    dw   ChannelZ_object_list
    db   BANK(ChannelZ_collectible_list)
    dw   ChannelZ_collectible_list
    db   $28, $20, $0b, $00
.data_03_743f_LevelData_ChannelZ4:
    db   BANK(ChannelZ_4_map)
    dw   ChannelZ_4_map
    db   BANK(ChannelZ_4_map_extended)
    dw   ChannelZ_4_map_extended
    db   BANK(ChannelZ_4_tileset)
    dw   ChannelZ_4_tileset
    db   BANK(ChannelZ_4_blockset)
    dw   ChannelZ_4_blockset
    db   BANK(ChannelZ_4_collision)
    dw   ChannelZ_4_collision
    db   BANK(ChannelZ_4_collision_blockset)
    dw   ChannelZ_4_collision_blockset
    db   BANK(ChannelZ_4_palette)
    dw   ChannelZ_4_palette
    db   BANK(ChannelZ_object_list)
    dw   ChannelZ_object_list
    db   BANK(ChannelZ_collectible_list)
    dw   ChannelZ_collectible_list
    db   $28, $20, $0b, $00
.data_03_745e_LevelData_ChannelZ5:
    db   BANK(ChannelZ_5_map)
    dw   ChannelZ_5_map
    db   BANK(ChannelZ_5_map_extended)
    dw   ChannelZ_5_map_extended
    db   BANK(ChannelZ_5_tileset)
    dw   ChannelZ_5_tileset
    db   BANK(ChannelZ_5_blockset)
    dw   ChannelZ_5_blockset
    db   BANK(ChannelZ_5_collision)
    dw   ChannelZ_5_collision
    db   BANK(ChannelZ_5_collision_blockset)
    dw   ChannelZ_5_collision_blockset
    db   BANK(ChannelZ_5_palette)
    dw   ChannelZ_5_palette
    db   BANK(ChannelZ_object_list)
    dw   ChannelZ_object_list
    db   BANK(ChannelZ_collectible_list)
    dw   ChannelZ_collectible_list
    db   $0f, $08, $0b, $00
