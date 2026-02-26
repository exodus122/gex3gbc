call_03_6c89_LoadMapDataPtrs:
; Purpose: Copies map-specific metadata from a lookup table into working RAM.
; Behavior:
; Uses wDB6C_CurrentMapId as index into .data_03_6ca0_MapDataPtrs.
; Reads a pointer to the map’s configuration, then copies 0x1F bytes into wDC01_MapBank.
; Usage: Part of map setup, ensuring the correct map bank and related data are loaded.
    ld   HL, wDB6C_CurrentMapId                                     ;; 03:6c89 $21 $6c $db
    ld   L, [HL]                                       ;; 03:6c8c $6e
    ld   H, $00                                        ;; 03:6c8d $26 $00
    add  HL, HL                                        ;; 03:6c8f $29
    ld   DE, .data_03_6ca0_MapDataPtrs                             ;; 03:6c90 $11 $a0 $6c
    add  HL, DE                                        ;; 03:6c93 $19
    ld   A, [HL+]                                      ;; 03:6c94 $2a
    ld   H, [HL]                                       ;; 03:6c95 $66
    ld   L, A                                          ;; 03:6c96 $6f
    ld   DE, wDC01_MapBank                                     ;; 03:6c97 $11 $01 $dc
    ld   BC, $1f                                       ;; 03:6c9a $01 $1f $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 03:6c9d $c3 $6e $07
.data_03_6ca0_MapDataPtrs:
    dw   .data_03_6d1a_MapData_GexCave1
    dw   .data_03_6d96_MapData_HolidayTV1
    dw   .data_03_6e12_MapData_MysteryTV1
    dw   .data_03_6f48_MapData_TutTV1
    dw   .data_03_7021_MapData_WesternStation1
    dw   .data_03_7138_MapData_AnimeChannel1
    dw   .data_03_724f_MapData_SuperheroShow1
    dw   .data_03_7309_MapData_GextremeSports1
    dw   .data_03_7385_MapData_MarsupialMadness1
    dw   .data_03_73a4_MapData_WWGexWrestling1
    dw   .data_03_73c3_MapData_LizardOfOz1
    dw   .data_03_73e2_MapData_ChannelZ1
    dw   .data_03_6d39_MapData_GexCave2
    dw   .data_03_6d58_MapData_GexCave3
    dw   .data_03_6d77_MapData_GexCave4
    dw   .data_03_6db5_MapData_HolidayTV2
    dw   .data_03_6dd4_MapData_HolidayTV3
    dw   .data_03_6df3_MapData_HolidayTV4
    dw   .data_03_6e31_MapData_MysteryTV2
    dw   .data_03_6e50_MapData_MysteryTV3
    dw   .data_03_6e6f_MapData_MysteryTV4
    dw   .data_03_6e8e_MapData_MysteryTV5
    dw   .data_03_6ead_MapData_MysteryTV6
    dw   .data_03_6ecc_MapData_MysteryTV7
    dw   .data_03_6eeb_MapData_MysteryTV8
    dw   .data_03_6f0a_MapData_MysteryTV9
    dw   .data_03_6f29_MapData_MysteryTV10
    dw   .data_03_6f67_MapData_TutTV2
    dw   .data_03_6f86_MapData_TutTV3
    dw   .data_03_6fa5_MapData_TutTV4
    dw   .data_03_6fc4_MapData_TutTV5
    dw   .data_03_6fe3_MapData_TutTV6
    dw   .data_03_7002_MapData_TutTV7
    dw   .data_03_7040_MapData_WesternStation2
    dw   .data_03_705f_MapData_WesternStation3
    dw   .data_03_707e_MapData_WesternStation4
    dw   .data_03_709d_MapData_WesternStation5
    dw   .data_03_70bc_MapData_WesternStation6
    dw   .data_03_70db_MapData_WesternStation7
    dw   .data_03_70fa_MapData_WesternStation8
    dw   .data_03_7119_MapData_WesternStation9
    dw   .data_03_7157_MapData_AnimeChannel2
    dw   .data_03_7176_MapData_AnimeChannel3
    dw   .data_03_7195_MapData_AnimeChannel4
    dw   .data_03_71b4_MapData_AnimeChannel5
    dw   .data_03_71d3_MapData_AnimeChannel6
    dw   .data_03_71f2_MapData_AnimeChannel7
    dw   .data_03_7211_MapData_AnimeChannel8
    dw   .data_03_7230_MapData_AnimeChannel9
    dw   .data_03_726e_MapData_SuperheroShow2
    dw   .data_03_728d_MapData_SuperheroShow3
    dw   .data_03_72ac_MapData_SuperheroShow4
    dw   .data_03_72cb_MapData_SuperheroShow5
    dw   .data_03_72ea_MapData_SuperheroShow6
    dw   .data_03_7328_MapData_GextremeSports2
    dw   .data_03_7347_MapData_GextremeSports3
    dw   .data_03_7366_MapData_GextremeSports4
    dw   .data_03_7401_MapData_ChannelZ2
    dw   .data_03_7420_MapData_ChannelZ3
    dw   .data_03_743f_MapData_ChannelZ4
    dw   .data_03_745e_MapData_ChannelZ5
.data_03_6d1a_MapData_GexCave1:
    farpointer GexCave_1_map
    farpointer GexCave_1_map_extended
    farpointer GexCave_1_tileset
    farpointer GexCave_1_blockset
    farpointer GexCave_1_collision
    farpointer GexCave_1_collision_blockset
    farpointer GexCave_1_palette
    farpointer GexCave_entity_list
    farpointer GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d39_MapData_GexCave2:
    farpointer GexCave_2_map
    farpointer GexCave_2_map_extended
    farpointer GexCave_2_tileset
    farpointer GexCave_2_blockset
    farpointer GexCave_2_collision
    farpointer GexCave_2_collision_blockset
    farpointer GexCave_2_palette
    farpointer GexCave_entity_list
    farpointer GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d58_MapData_GexCave3:
    farpointer GexCave_3_map
    farpointer GexCave_3_map_extended
    farpointer GexCave_3_tileset
    farpointer GexCave_3_blockset
    farpointer GexCave_3_collision
    farpointer GexCave_3_collision_blockset
    farpointer GexCave_3_palette
    farpointer GexCave_entity_list
    farpointer GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d77_MapData_GexCave4:
    farpointer GexCave_4_map
    farpointer GexCave_4_map_extended
    farpointer GexCave_4_tileset
    farpointer GexCave_4_blockset
    farpointer GexCave_4_collision
    farpointer GexCave_4_collision_blockset
    farpointer GexCave_4_palette
    farpointer GexCave_entity_list
    farpointer GexCave_collectible_list
    db   $1e, $11, $00, $00
.data_03_6d96_MapData_HolidayTV1:
    farpointer HolidayTV_1_map
    farpointer HolidayTV_1_map_extended
    farpointer HolidayTV_1_tileset
    farpointer HolidayTV_1_blockset
    farpointer HolidayTV_1_collision
    farpointer HolidayTV_1_collision_blockset
    farpointer HolidayTV_1_palette
    farpointer HolidayTV_entity_list
    farpointer HolidayTV_collectible_list
    db   $a0, $50, $01, $00
.data_03_6db5_MapData_HolidayTV2:
    farpointer HolidayTV_2_map
    farpointer HolidayTV_2_map_extended
    farpointer HolidayTV_2_tileset
    farpointer HolidayTV_2_blockset
    farpointer HolidayTV_2_collision
    farpointer HolidayTV_2_collision_blockset
    farpointer HolidayTV_2_palette
    farpointer HolidayTV_entity_list
    farpointer HolidayTV_collectible_list
    db   $14, $16, $01, $00
.data_03_6dd4_MapData_HolidayTV3:
    farpointer HolidayTV_2_map
    farpointer HolidayTV_2_map_extended
    farpointer HolidayTV_2_tileset
    farpointer HolidayTV_2_blockset
    farpointer HolidayTV_2_collision
    farpointer HolidayTV_2_collision_blockset
    farpointer HolidayTV_3_palette_4180
    farpointer HolidayTV_entity_list
    farpointer HolidayTV_collectible_list
    db   $14, $16, $01, $00
.data_03_6df3_MapData_HolidayTV4:
    farpointer HolidayTV_4_map
    farpointer HolidayTV_4_map_extended
    farpointer HolidayTV_4_tileset
    farpointer HolidayTV_4_blockset
    farpointer HolidayTV_4_collision
    farpointer HolidayTV_4_collision_blockset
    farpointer HolidayTV_4_palette
    farpointer HolidayTV_entity_list
    farpointer HolidayTV_collectible_list
    db   $14, $9, $01, $00
.data_03_6e12_MapData_MysteryTV1:
    farpointer MysteryTV_1_map
    farpointer MysteryTV_1_map_extended
    farpointer MysteryTV_1_tileset
    farpointer MysteryTV_1_blockset
    farpointer MysteryTV_1_collision
    farpointer MysteryTV_1_collision_blockset
    farpointer MysteryTV_1_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $2d, $2d, $02, $00
.data_03_6e31_MapData_MysteryTV2:
    farpointer MysteryTV_2_map
    farpointer MysteryTV_2_map_extended
    farpointer MysteryTV_2_tileset
    farpointer MysteryTV_2_blockset
    farpointer MysteryTV_2_collision
    farpointer MysteryTV_2_collision_blockset
    farpointer MysteryTV_2_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $28, $32, $02, $01
.data_03_6e50_MapData_MysteryTV3:
    farpointer MysteryTV_3_map
    farpointer MysteryTV_3_map_extended
    farpointer MysteryTV_3_tileset
    farpointer MysteryTV_3_blockset
    farpointer MysteryTV_3_collision
    farpointer MysteryTV_3_collision_blockset
    farpointer MysteryTV_3_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $2d, $1e, $02, $00
.data_03_6e6f_MapData_MysteryTV4:
    farpointer MysteryTV_4_map
    farpointer MysteryTV_4_map_extended
    farpointer MysteryTV_4_tileset
    farpointer MysteryTV_4_blockset
    farpointer MysteryTV_4_collision
    farpointer MysteryTV_4_collision_blockset
    farpointer MysteryTV_4_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6e8e_MapData_MysteryTV5:
    farpointer MysteryTV_4_map
    farpointer MysteryTV_4_map_extended
    farpointer MysteryTV_4_tileset
    farpointer MysteryTV_4_blockset
    farpointer MysteryTV_4_collision
    farpointer MysteryTV_4_collision_blockset
    farpointer MysteryTV_5_palette_4300
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6ead_MapData_MysteryTV6:
    farpointer MysteryTV_4_map
    farpointer MysteryTV_4_map_extended
    farpointer MysteryTV_4_tileset
    farpointer MysteryTV_4_blockset
    farpointer MysteryTV_4_collision
    farpointer MysteryTV_4_collision_blockset
    farpointer MysteryTV_6_palette_4340
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6ecc_MapData_MysteryTV7:
    farpointer MysteryTV_7_map
    farpointer MysteryTV_7_map_extended
    farpointer MysteryTV_7_tileset
    farpointer MysteryTV_7_blockset
    farpointer MysteryTV_7_collision
    farpointer MysteryTV_7_collision_blockset
    farpointer MysteryTV_7_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $0a, $08, $02, $01
.data_03_6eeb_MapData_MysteryTV8:
    farpointer MysteryTV_8_map
    farpointer MysteryTV_8_map_extended
    farpointer MysteryTV_8_tileset
    farpointer MysteryTV_8_blockset
    farpointer MysteryTV_8_collision
    farpointer MysteryTV_8_collision_blockset
    farpointer MysteryTV_8_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $0a, $09, $02, $01
.data_03_6f0a_MapData_MysteryTV9:
    farpointer MysteryTV_4_map
    farpointer MysteryTV_4_map_extended
    farpointer MysteryTV_4_tileset
    farpointer MysteryTV_4_blockset
    farpointer MysteryTV_4_collision
    farpointer MysteryTV_4_collision_blockset
    farpointer MysteryTV_4_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $14, $2a, $02, $00
.data_03_6f29_MapData_MysteryTV10:
    farpointer MysteryTV_2_map
    farpointer MysteryTV_2_map_extended
    farpointer MysteryTV_2_tileset
    farpointer MysteryTV_2_blockset
    farpointer MysteryTV_2_collision
    farpointer MysteryTV_2_collision_blockset
    farpointer MysteryTV_2_palette
    farpointer MysteryTV_entity_list
    farpointer MysteryTV_collectible_list
    db   $28, $32, $02, $01
.data_03_6f48_MapData_TutTV1:
    farpointer TutTV_1_map
    farpointer TutTV_1_map_extended
    farpointer TutTV_1_tileset
    farpointer TutTV_1_blockset
    farpointer TutTV_1_collision
    farpointer TutTV_1_collision_blockset
    farpointer TutTV_1_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $27, $13, $03, $00
.data_03_6f67_MapData_TutTV2:
    farpointer TutTV_2_map
    farpointer TutTV_2_map_extended
    farpointer TutTV_2_tileset
    farpointer TutTV_2_blockset
    farpointer TutTV_2_collision
    farpointer TutTV_2_collision_blockset
    farpointer TutTV_2_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $34, $33, $03, $00
.data_03_6f86_MapData_TutTV3:
    farpointer TutTV_3_map
    farpointer TutTV_3_map_extended
    farpointer TutTV_3_tileset
    farpointer TutTV_3_blockset
    farpointer TutTV_3_collision
    farpointer TutTV_3_collision_blockset
    farpointer TutTV_3_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $64, $17, $03, $00
.data_03_6fa5_MapData_TutTV4:
    farpointer TutTV_4_map
    farpointer TutTV_4_map_extended
    farpointer TutTV_4_tileset
    farpointer TutTV_4_blockset
    farpointer TutTV_4_collision
    farpointer TutTV_4_collision_blockset
    farpointer TutTV_4_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $4a, $13, $03, $00
.data_03_6fc4_MapData_TutTV5:
    farpointer TutTV_5_map
    farpointer TutTV_5_map_extended
    farpointer TutTV_5_tileset
    farpointer TutTV_5_blockset
    farpointer TutTV_5_collision
    farpointer TutTV_5_collision_blockset
    farpointer TutTV_5_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $0a, $09, $03, $00
.data_03_6fe3_MapData_TutTV6:
    farpointer TutTV_6_map
    farpointer TutTV_6_map_extended
    farpointer TutTV_6_tileset
    farpointer TutTV_6_blockset
    farpointer TutTV_6_collision
    farpointer TutTV_6_collision_blockset
    farpointer TutTV_6_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $14, $09, $03, $00
.data_03_7002_MapData_TutTV7:
    farpointer TutTV_7_map
    farpointer TutTV_7_map_extended
    farpointer TutTV_7_tileset
    farpointer TutTV_7_blockset
    farpointer TutTV_7_collision
    farpointer TutTV_7_collision_blockset
    farpointer TutTV_7_palette
    farpointer TutTV_entity_list
    farpointer TutTV_collectible_list
    db   $32, $19, $03, $00  
.data_03_7021_MapData_WesternStation1:
    farpointer WesternStation_1_map
    farpointer WesternStation_1_map_extended
    farpointer WesternStation_1_tileset
    farpointer WesternStation_1_blockset
    farpointer WesternStation_1_collision
    farpointer WesternStation_1_collision_blockset
    farpointer WesternStation_1_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $28, $16, $04, $00
.data_03_7040_MapData_WesternStation2:
    farpointer WesternStation_2_map
    farpointer WesternStation_2_map_extended
    farpointer WesternStation_2_tileset
    farpointer WesternStation_2_blockset
    farpointer WesternStation_2_collision
    farpointer WesternStation_2_collision_blockset
    farpointer WesternStation_2_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $26, $16, $04, $00
.data_03_705f_MapData_WesternStation3:
    farpointer WesternStation_3_map
    farpointer WesternStation_3_map_extended
    farpointer WesternStation_3_tileset
    farpointer WesternStation_3_blockset
    farpointer WesternStation_3_collision
    farpointer WesternStation_3_collision_blockset
    farpointer WesternStation_3_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $14, $0b, $04, $00
.data_03_707e_MapData_WesternStation4:
    farpointer WesternStation_4_map
    farpointer WesternStation_4_map_extended
    farpointer WesternStation_4_tileset
    farpointer WesternStation_4_blockset
    farpointer WesternStation_4_collision
    farpointer WesternStation_4_collision_blockset
    farpointer WesternStation_4_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_709d_MapData_WesternStation5:
    farpointer WesternStation_5_map
    farpointer WesternStation_5_map_extended
    farpointer WesternStation_5_tileset
    farpointer WesternStation_5_blockset
    farpointer WesternStation_5_collision
    farpointer WesternStation_5_collision_blockset
    farpointer WesternStation_5_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $50, $12, $04, $00
.data_03_70bc_MapData_WesternStation6:
    farpointer WesternStation_6_map
    farpointer WesternStation_6_map_extended
    farpointer WesternStation_6_tileset
    farpointer WesternStation_6_blockset
    farpointer WesternStation_6_collision
    farpointer WesternStation_6_collision_blockset
    farpointer WesternStation_6_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $7d, $33, $04, $00
.data_03_70db_MapData_WesternStation7:
    farpointer WesternStation_4_map
    farpointer WesternStation_4_map_extended
    farpointer WesternStation_4_tileset
    farpointer WesternStation_4_blockset
    farpointer WesternStation_4_collision
    farpointer WesternStation_4_collision_blockset
    farpointer WesternStation_4_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_70fa_MapData_WesternStation8:
    farpointer WesternStation_4_map
    farpointer WesternStation_4_map_extended
    farpointer WesternStation_4_tileset
    farpointer WesternStation_4_blockset
    farpointer WesternStation_4_collision
    farpointer WesternStation_4_collision_blockset
    farpointer WesternStation_4_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_7119_MapData_WesternStation9:
    farpointer WesternStation_4_map
    farpointer WesternStation_4_map_extended
    farpointer WesternStation_4_tileset
    farpointer WesternStation_4_blockset
    farpointer WesternStation_4_collision
    farpointer WesternStation_4_collision_blockset
    farpointer WesternStation_4_palette
    farpointer WesternStation_entity_list
    farpointer WesternStation_collectible_list
    db   $0a, $12, $04, $00
.data_03_7138_MapData_AnimeChannel1:     
    farpointer AnimeChannel_1_map
    farpointer AnimeChannel_1_map_extended
    farpointer AnimeChannel_1_tileset
    farpointer AnimeChannel_1_blockset
    farpointer AnimeChannel_1_collision
    farpointer AnimeChannel_1_collision_blockset
    farpointer AnimeChannel_1_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $3e, $1e, $05, $00   
.data_03_7157_MapData_AnimeChannel2:
    farpointer AnimeChannel_2_map
    farpointer AnimeChannel_2_map_extended
    farpointer AnimeChannel_2_tileset
    farpointer AnimeChannel_2_blockset
    farpointer AnimeChannel_2_collision
    farpointer AnimeChannel_2_collision_blockset
    farpointer AnimeChannel_2_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $30, $1e, $05, $00
.data_03_7176_MapData_AnimeChannel3:
    farpointer AnimeChannel_3_map
    farpointer AnimeChannel_3_map_extended
    farpointer AnimeChannel_3_tileset
    farpointer AnimeChannel_3_blockset
    farpointer AnimeChannel_3_collision
    farpointer AnimeChannel_3_collision_blockset
    farpointer AnimeChannel_3_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $38, $13, $05, $00
.data_03_7195_MapData_AnimeChannel4:
    farpointer AnimeChannel_4_map
    farpointer AnimeChannel_4_map_extended
    farpointer AnimeChannel_4_tileset
    farpointer AnimeChannel_4_blockset
    farpointer AnimeChannel_4_collision
    farpointer AnimeChannel_4_collision_blockset
    farpointer AnimeChannel_4_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $5e, $2a, $05, $00
.data_03_71b4_MapData_AnimeChannel5:
    farpointer AnimeChannel_5_map
    farpointer AnimeChannel_5_map_extended
    farpointer AnimeChannel_5_tileset
    farpointer AnimeChannel_5_blockset
    farpointer AnimeChannel_5_collision
    farpointer AnimeChannel_5_collision_blockset
    farpointer AnimeChannel_5_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $f5, $16, $05, $00
.data_03_71d3_MapData_AnimeChannel6:
    farpointer AnimeChannel_6_map
    farpointer AnimeChannel_6_map_extended
    farpointer AnimeChannel_6_tileset
    farpointer AnimeChannel_6_blockset
    farpointer AnimeChannel_6_collision
    farpointer AnimeChannel_6_collision_blockset
    farpointer AnimeChannel_6_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $1e, $33, $05, $00
.data_03_71f2_MapData_AnimeChannel7:
    farpointer AnimeChannel_6_map
    farpointer AnimeChannel_6_map_extended
    farpointer AnimeChannel_6_tileset
    farpointer AnimeChannel_6_blockset
    farpointer AnimeChannel_6_collision
    farpointer AnimeChannel_6_collision_blockset
    farpointer AnimeChannel_6_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $1e, $33, $05, $00
.data_03_7211_MapData_AnimeChannel8:
    farpointer AnimeChannel_6_map
    farpointer AnimeChannel_6_map_extended
    farpointer AnimeChannel_6_tileset
    farpointer AnimeChannel_6_blockset
    farpointer AnimeChannel_6_collision
    farpointer AnimeChannel_6_collision_blockset
    farpointer AnimeChannel_6_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $1e, $33, $05, $00
.data_03_7230_MapData_AnimeChannel9:
    farpointer AnimeChannel_5_map
    farpointer AnimeChannel_5_map_extended
    farpointer AnimeChannel_5_tileset
    farpointer AnimeChannel_5_blockset
    farpointer AnimeChannel_5_collision
    farpointer AnimeChannel_5_collision_blockset
    farpointer AnimeChannel_5_palette
    farpointer AnimeChannel_entity_list
    farpointer AnimeChannel_collectible_list
    db   $f5, $16, $05, $00
.data_03_724f_MapData_SuperheroShow1:
    farpointer SuperheroShow_1_map
    farpointer SuperheroShow_1_map_extended
    farpointer SuperheroShow_1_tileset
    farpointer SuperheroShow_1_blockset
    farpointer SuperheroShow_1_collision
    farpointer SuperheroShow_1_collision_blockset
    farpointer SuperheroShow_1_palette
    farpointer SuperheroShow_entity_list
    farpointer SuperheroShow_collectible_list
    db   $bf, $1e, $06, $00
.data_03_726e_MapData_SuperheroShow2:
    farpointer SuperheroShow_2_map
    farpointer SuperheroShow_2_map_extended
    farpointer SuperheroShow_2_tileset
    farpointer SuperheroShow_2_blockset
    farpointer SuperheroShow_2_collision
    farpointer SuperheroShow_2_collision_blockset
    farpointer SuperheroShow_2_palette
    farpointer SuperheroShow_entity_list
    farpointer SuperheroShow_collectible_list
    db   $c2, $44, $06, $00
.data_03_728d_MapData_SuperheroShow3:
    farpointer SuperheroShow_3_map
    farpointer SuperheroShow_3_map_extended
    farpointer SuperheroShow_3_tileset
    farpointer SuperheroShow_3_blockset
    farpointer SuperheroShow_3_collision
    farpointer SuperheroShow_3_collision_blockset
    farpointer SuperheroShow_3_palette
    farpointer SuperheroShow_entity_list
    farpointer SuperheroShow_collectible_list
    db   $43, $1e, $06, $00
.data_03_72ac_MapData_SuperheroShow4:
    farpointer SuperheroShow_4_map
    farpointer SuperheroShow_4_map_extended
    farpointer SuperheroShow_4_tileset
    farpointer SuperheroShow_4_blockset
    farpointer SuperheroShow_4_collision
    farpointer SuperheroShow_4_collision_blockset
    farpointer SuperheroShow_4_palette
    farpointer SuperheroShow_entity_list
    farpointer SuperheroShow_collectible_list
    db   $60, $1e, $06, $00
.data_03_72cb_MapData_SuperheroShow5:
    farpointer SuperheroShow_5_map
    farpointer SuperheroShow_5_map_extended
    farpointer SuperheroShow_5_tileset
    farpointer SuperheroShow_5_blockset
    farpointer SuperheroShow_5_collision
    farpointer SuperheroShow_5_collision_blockset
    farpointer SuperheroShow_5_palette
    farpointer SuperheroShow_entity_list
    farpointer SuperheroShow_collectible_list
    db   $30, $22, $06, $00
.data_03_72ea_MapData_SuperheroShow6:
    farpointer SuperheroShow_6_map
    farpointer SuperheroShow_6_map_extended
    farpointer SuperheroShow_6_tileset
    farpointer SuperheroShow_6_blockset
    farpointer SuperheroShow_6_collision
    farpointer SuperheroShow_6_collision_blockset
    farpointer SuperheroShow_6_palette
    farpointer SuperheroShow_entity_list
    farpointer SuperheroShow_collectible_list
    db   $0a, $08, $06, $00
.data_03_7309_MapData_GextremeSports1:
    farpointer GextremeSports_1_map
    farpointer GextremeSports_1_map_extended
    farpointer GextremeSports_1_tileset
    farpointer GextremeSports_1_blockset
    farpointer GextremeSports_1_collision
    farpointer GextremeSports_1_collision_blockset
    farpointer GextremeSports_1_palette
    farpointer GextremeSports_entity_list
    farpointer GextremeSports_collectible_list
    db   $30, $30, $07, $00
.data_03_7328_MapData_GextremeSports2:
    farpointer HolidayTV_2_map
    farpointer HolidayTV_2_map_extended
    farpointer HolidayTV_2_tileset
    farpointer HolidayTV_2_blockset
    farpointer HolidayTV_2_collision
    farpointer HolidayTV_2_collision_blockset
    farpointer HolidayTV_3_palette_4180
    farpointer GextremeSports_entity_list
    farpointer GextremeSports_collectible_list
    db   $14, $16, $07, $00
.data_03_7347_MapData_GextremeSports3:
    farpointer HolidayTV_2_map
    farpointer HolidayTV_2_map_extended
    farpointer HolidayTV_2_tileset
    farpointer HolidayTV_2_blockset
    farpointer HolidayTV_2_collision
    farpointer HolidayTV_2_collision_blockset
    farpointer HolidayTV_3_palette_4180
    farpointer GextremeSports_entity_list
    farpointer GextremeSports_collectible_list
    db   $14, $16, $07, $00
.data_03_7366_MapData_GextremeSports4:
    farpointer HolidayTV_2_map
    farpointer HolidayTV_2_map_extended
    farpointer HolidayTV_2_tileset
    farpointer HolidayTV_2_blockset
    farpointer HolidayTV_2_collision
    farpointer HolidayTV_2_collision_blockset
    farpointer HolidayTV_3_palette_4180
    farpointer GextremeSports_entity_list
    farpointer GextremeSports_collectible_list
    db   $14, $16, $07, $00
.data_03_7385_MapData_MarsupialMadness1:
    farpointer MarsupialMadness_1_map
    farpointer MarsupialMadness_1_map_extended
    farpointer MarsupialMadness_1_tileset
    farpointer MarsupialMadness_1_blockset
    farpointer MarsupialMadness_1_collision
    farpointer MarsupialMadness_1_collision_blockset
    farpointer MarsupialMadness_1_palette
    farpointer MarsupialMadness_entity_list
    farpointer MarsupialMadness_collectible_list
    db   $20, $42, $08, $00
.data_03_73a4_MapData_WWGexWrestling1:
    farpointer WWGexWrestling_1_map
    farpointer WWGexWrestling_1_map_extended
    farpointer WWGexWrestling_1_tileset
    farpointer WWGexWrestling_1_blockset
    farpointer WWGexWrestling_1_collision
    farpointer WWGexWrestling_1_collision_blockset
    farpointer WWGexWrestling_1_palette
    farpointer WWGexWrestling_entity_list
    farpointer WWGexWrestling_collectible_list
    db   $18, $12, $09, $01
.data_03_73c3_MapData_LizardOfOz1:
    farpointer LizardOfOz_1_map
    farpointer LizardOfOz_1_map_extended
    farpointer LizardOfOz_1_tileset
    farpointer LizardOfOz_1_blockset
    farpointer LizardOfOz_1_collision
    farpointer LizardOfOz_1_collision_blockset
    farpointer LizardOfOz_1_palette
    farpointer LizardOfOz_entity_list
    farpointer LizardOfOz_collectible_list
    db   $0f, $08, $0a, $00
.data_03_73e2_MapData_ChannelZ1:
    farpointer ChannelZ_1_map
    farpointer ChannelZ_1_map_extended
    farpointer ChannelZ_1_tileset
    farpointer ChannelZ_1_blockset
    farpointer ChannelZ_1_collision
    farpointer ChannelZ_1_collision_blockset
    farpointer ChannelZ_1_palette
    farpointer ChannelZ_entity_list
    farpointer ChannelZ_collectible_list
    db   $28, $38, $0b, $00
.data_03_7401_MapData_ChannelZ2:
    farpointer ChannelZ_2_map
    farpointer ChannelZ_2_map_extended
    farpointer ChannelZ_2_tileset
    farpointer ChannelZ_2_blockset
    farpointer ChannelZ_2_collision
    farpointer ChannelZ_2_collision_blockset
    farpointer ChannelZ_2_palette
    farpointer ChannelZ_entity_list
    farpointer ChannelZ_collectible_list
    db   $1f, $11, $0b, $00
.data_03_7420_MapData_ChannelZ3:
    farpointer ChannelZ_3_map
    farpointer ChannelZ_3_map_extended
    farpointer ChannelZ_3_tileset
    farpointer ChannelZ_3_blockset
    farpointer ChannelZ_3_collision
    farpointer ChannelZ_3_collision_blockset
    farpointer ChannelZ_3_palette
    farpointer ChannelZ_entity_list
    farpointer ChannelZ_collectible_list
    db   $28, $20, $0b, $00
.data_03_743f_MapData_ChannelZ4:
    farpointer ChannelZ_4_map
    farpointer ChannelZ_4_map_extended
    farpointer ChannelZ_4_tileset
    farpointer ChannelZ_4_blockset
    farpointer ChannelZ_4_collision
    farpointer ChannelZ_4_collision_blockset
    farpointer ChannelZ_4_palette
    farpointer ChannelZ_entity_list
    farpointer ChannelZ_collectible_list
    db   $28, $20, $0b, $00
.data_03_745e_MapData_ChannelZ5:
    farpointer ChannelZ_5_map
    farpointer ChannelZ_5_map_extended
    farpointer ChannelZ_5_tileset
    farpointer ChannelZ_5_blockset
    farpointer ChannelZ_5_collision
    farpointer ChannelZ_5_collision_blockset
    farpointer ChannelZ_5_palette
    farpointer ChannelZ_entity_list
    farpointer ChannelZ_collectible_list
    db   $0f, $08, $0b, $00
