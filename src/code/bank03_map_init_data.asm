; ==================================================================
; Bank 3. What a map IS: one descriptor record per map saying where every piece of its
; data lives, and the routine that copies the current one into RAM.
;
; A gex3 map needs nine separate blobs, and they are scattered over the ROM by size
; rather than by map, so the descriptor is nine farpointers - bank plus address -
; followed by four bytes of geometry:
;
;   map                 the blockmap: one byte per 16x16 block, the low byte of a
;                       block id, rows MAPDATA width bytes apart
;   map extended        the same grid again, supplying the HIGH byte of the block id.
;                       Together they let a map address more than 256 distinct blocks
;   tileset             the 2bpp graphics
;   blockset            8 bytes per block id - four tile ids then four CGB attribute
;                       bytes - which is what turns a block id into four tiles
;   collision           a third grid over the same blocks, naming a collision block
;   collision blockset  4 bytes per collision block id, its four collision tiles
;   palette             the map's CGB background palettes
;   entity list         shared by every map in the level, see bank00_entity_load
;   collectible list    likewise, see bank00_level_init
;
;   geometry            width and height in blocks, the LEVEL_* this map belongs to,
;                       and BG_COLLISION_TYPE_SIDESCROLLER or _TOPDOWN
;
; The record is copied as one MAPDATA_RECORD_SIZE-byte block straight into
; wDC01_MapBank, so the WRAM layout there IS this layout - the two have to be edited
; together.
;
; Note the entity and collectible pointers repeat across every map of a level. They
; are per-LEVEL data stored in a per-MAP table, which is why changing a level's entity
; list means editing every one of its map records.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank00_map_init_data.asm
; ------------------------------------------------------------------
; Same idea - one record per map, indexed by the current map id - but the two solve
; the access problem in opposite ways:
;
;   accessors     gex2 never copies. It has eleven little routines,
;                 call_00_2e3a_MapData_GetTVPaletteId and friends, each of which
;                 calls call_00_2eb0_MapData_GetRecordAddr, adds a MAPDATA_* offset
;                 and reads one field. gex3 memcpys the whole record into fixed WRAM
;                 once per map load and everything reads the WRAM copy directly
;   the index     gex2's record is padded to $10 bytes so the id can be multiplied by
;                 four `add HL,HL` shifts. gex3's is $1F bytes and not a power of two,
;                 so it needs a pointer table - .data_03_6ca0_MapDataPointers - and
;                 pays two bytes per map to avoid the padding
;   what is in it gex2 has no extended blockmap (its second plane is a one-bit alt
;                 blockset selector), no separate collision layer (collision shares
;                 the blockset's bank), and no per-map entity or collectible pointer
;                 (both are per-level tables in banks $0A and $0B). It does carry
;                 things gex3's does not: a TV palette id, a mission-progress row and
;                 a text block pointer, because gex2's menus read the map table
;   the geometry  gex2 has none. Every gex2 map is the same size, so its camera clamps
;                 against constants; gex3 stores width and height per map, and the
;                 boundaries live in their own table next door
; ==================================================================

call_03_6c89_MapData_LoadForCurrentMap:
; Copies the current map's descriptor into wDC01_MapBank, and that is the whole
; routine - a table lookup and a MAPDATA_RECORD_SIZE-byte memcpy.
;
; Everything downstream reads the WRAM copy, so this is the single point where "which
; map are we on" turns into "where is its data". It is called on every level load,
; every map change within a level, by the cutscene runner, and by the menus, which
; borrow the map machinery to draw their backgrounds - the four callers in
; bank00_home.asm, bank00_cutscenes.asm and bank01_menus.asm all set
; wDB6C_CurrentMapId first and let this do the rest.
;
; gex2's call_00_2eb0_MapData_GetRecordAddr is the closest thing, but it hands back a
; pointer for one accessor to read one field; nothing in gex2 copies a record
    ld   HL, wDB6C_CurrentMapId                       ;; 03:6c89 $21 $6c $db
    ld   L, [HL]                                      ;; 03:6c8c $6e
    ld   H, $00                                       ;; 03:6c8d $26 $00
    add  HL, HL                                       ;; 03:6c8f $29
    ld   DE, .data_03_6ca0_MapDataPointers            ;; 03:6c90 $11 $a0 $6c
    add  HL, DE                                       ;; 03:6c93 $19
    ld   A, [HL+]                                     ;; 03:6c94 $2a
    ld   H, [HL]                                      ;; 03:6c95 $66
    ld   L, A                                         ;; 03:6c96 $6f
    ld   DE, wDC01_MapBank                            ;; 03:6c97 $11 $01 $dc
    ld   BC, MAPDATA_RECORD_SIZE                      ;; 03:6c9a $01 $1f $00
    jp   call_00_076e_MemCopy                         ;; 03:6c9d $c3 $6e $07
.data_03_6ca0_MapDataPointers:
    dw   .data_03_6d1a_MapData_GexCave1             ; MAP_GEX_CAVE1
    dw   .data_03_6d96_MapData_HolidayTV1           ; MAP_HOLIDAY_TV1
    dw   .data_03_6e12_MapData_MysteryTV1           ; MAP_MYSTERY_TV1
    dw   .data_03_6f48_MapData_TutTV1               ; MAP_TUT_TV1
    dw   .data_03_7021_MapData_WesternStation1      ; MAP_WESTERN_STATION1
    dw   .data_03_7138_MapData_AnimeChannel1        ; MAP_ANIME_CHANNEL1
    dw   .data_03_724f_MapData_SuperheroShow1       ; MAP_SUPERHERO_SHOW1
    dw   .data_03_7309_MapData_GextremeSports1      ; MAP_GEXTREME_SPORTS1
    dw   .data_03_7385_MapData_MarsupialMadness1    ; MAP_MARSUPIAL_MADNESS1
    dw   .data_03_73a4_MapData_WWGexWrestling1      ; MAP_WW_GEX_WRESTLING1
    dw   .data_03_73c3_MapData_LizardOfOz1          ; MAP_LIZARD_OF_OZ1
    dw   .data_03_73e2_MapData_ChannelZ1            ; MAP_CHANNEL_Z1
    dw   .data_03_6d39_MapData_GexCave2             ; MAP_GEX_CAVE2
    dw   .data_03_6d58_MapData_GexCave3             ; MAP_GEX_CAVE3
    dw   .data_03_6d77_MapData_GexCave4             ; MAP_GEX_CAVE4
    dw   .data_03_6db5_MapData_HolidayTV2           ; MAP_HOLIDAY_TV2
    dw   .data_03_6dd4_MapData_HolidayTV3           ; MAP_HOLIDAY_TV3
    dw   .data_03_6df3_MapData_HolidayTV4           ; MAP_HOLIDAY_TV4
    dw   .data_03_6e31_MapData_MysteryTV2           ; MAP_MYSTERY_TV2
    dw   .data_03_6e50_MapData_MysteryTV3           ; MAP_MYSTERY_TV3
    dw   .data_03_6e6f_MapData_MysteryTV4           ; MAP_MYSTERY_TV4
    dw   .data_03_6e8e_MapData_MysteryTV5           ; MAP_MYSTERY_TV5
    dw   .data_03_6ead_MapData_MysteryTV6           ; MAP_MYSTERY_TV6
    dw   .data_03_6ecc_MapData_MysteryTV7           ; MAP_MYSTERY_TV7
    dw   .data_03_6eeb_MapData_MysteryTV8           ; MAP_MYSTERY_TV8
    dw   .data_03_6f0a_MapData_MysteryTV9           ; MAP_MYSTERY_TV9
    dw   .data_03_6f29_MapData_MysteryTV10          ; MAP_MYSTERY_TV10
    dw   .data_03_6f67_MapData_TutTV2               ; MAP_TUT_TV2
    dw   .data_03_6f86_MapData_TutTV3               ; MAP_TUT_TV3
    dw   .data_03_6fa5_MapData_TutTV4               ; MAP_TUT_TV4
    dw   .data_03_6fc4_MapData_TutTV5               ; MAP_TUT_TV5
    dw   .data_03_6fe3_MapData_TutTV6               ; MAP_TUT_TV6
    dw   .data_03_7002_MapData_TutTV7               ; MAP_TUT_TV7
    dw   .data_03_7040_MapData_WesternStation2      ; MAP_WESTERN_STATION2
    dw   .data_03_705f_MapData_WesternStation3      ; MAP_WESTERN_STATION3
    dw   .data_03_707e_MapData_WesternStation4      ; MAP_WESTERN_STATION4
    dw   .data_03_709d_MapData_WesternStation5      ; MAP_WESTERN_STATION5
    dw   .data_03_70bc_MapData_WesternStation6      ; MAP_WESTERN_STATION6
    dw   .data_03_70db_MapData_WesternStation7      ; MAP_WESTERN_STATION7
    dw   .data_03_70fa_MapData_WesternStation8      ; MAP_WESTERN_STATION8
    dw   .data_03_7119_MapData_WesternStation9      ; MAP_WESTERN_STATION9
    dw   .data_03_7157_MapData_AnimeChannel2        ; MAP_ANIME_CHANNEL2
    dw   .data_03_7176_MapData_AnimeChannel3        ; MAP_ANIME_CHANNEL3
    dw   .data_03_7195_MapData_AnimeChannel4        ; MAP_ANIME_CHANNEL4
    dw   .data_03_71b4_MapData_AnimeChannel5        ; MAP_ANIME_CHANNEL5
    dw   .data_03_71d3_MapData_AnimeChannel6        ; MAP_ANIME_CHANNEL6
    dw   .data_03_71f2_MapData_AnimeChannel7        ; MAP_ANIME_CHANNEL7
    dw   .data_03_7211_MapData_AnimeChannel8        ; MAP_ANIME_CHANNEL8
    dw   .data_03_7230_MapData_AnimeChannel9        ; MAP_ANIME_CHANNEL9
    dw   .data_03_726e_MapData_SuperheroShow2       ; MAP_SUPERHERO_SHOW2
    dw   .data_03_728d_MapData_SuperheroShow3       ; MAP_SUPERHERO_SHOW3
    dw   .data_03_72ac_MapData_SuperheroShow4       ; MAP_SUPERHERO_SHOW4
    dw   .data_03_72cb_MapData_SuperheroShow5       ; MAP_SUPERHERO_SHOW5
    dw   .data_03_72ea_MapData_SuperheroShow6       ; MAP_SUPERHERO_SHOW6
    dw   .data_03_7328_MapData_GextremeSports2      ; MAP_GEXTREME_SPORTS2
    dw   .data_03_7347_MapData_GextremeSports3      ; MAP_GEXTREME_SPORTS3
    dw   .data_03_7366_MapData_GextremeSports4      ; MAP_GEXTREME_SPORTS4
    dw   .data_03_7401_MapData_ChannelZ2            ; MAP_CHANNEL_Z2
    dw   .data_03_7420_MapData_ChannelZ3            ; MAP_CHANNEL_Z3
    dw   .data_03_743f_MapData_ChannelZ4            ; MAP_CHANNEL_Z4
    dw   .data_03_745e_MapData_ChannelZ5            ; MAP_CHANNEL_Z5
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
    map_geometry  30,  17, LEVEL_GEX_CAVE, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  30,  17, LEVEL_GEX_CAVE, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  30,  17, LEVEL_GEX_CAVE, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  30,  17, LEVEL_GEX_CAVE, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 160,  80, LEVEL_HOLIDAY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  22, LEVEL_HOLIDAY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  22, LEVEL_HOLIDAY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,   9, LEVEL_HOLIDAY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  45,  45, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  40,  50, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_TOPDOWN
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
    map_geometry  45,  30, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  42, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  42, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  42, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,   8, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_TOPDOWN
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
    map_geometry  10,   9, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_TOPDOWN
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
    map_geometry  20,  42, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  40,  50, LEVEL_MYSTERY_TV, BG_COLLISION_TYPE_TOPDOWN
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
    map_geometry  39,  19, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  52,  51, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 100,  23, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  74,  19, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,   9, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,   9, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  50,  25, LEVEL_TUT_TV, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  40,  22, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  38,  22, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  11, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,  18, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  80,  18, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 125,  51, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,  18, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,  18, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,  18, LEVEL_WESTERN_STATION, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  62,  30, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  48,  30, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  56,  19, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  94,  42, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 245,  22, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  30,  51, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  30,  51, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  30,  51, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 245,  22, LEVEL_ANIME_CHANNEL, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 191,  30, LEVEL_SUPERHERO_SHOW, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry 194,  68, LEVEL_SUPERHERO_SHOW, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  67,  30, LEVEL_SUPERHERO_SHOW, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  96,  30, LEVEL_SUPERHERO_SHOW, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  48,  34, LEVEL_SUPERHERO_SHOW, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  10,   8, LEVEL_SUPERHERO_SHOW, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  48,  48, LEVEL_GEXTREME_SPORTS, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  22, LEVEL_GEXTREME_SPORTS, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  22, LEVEL_GEXTREME_SPORTS, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  20,  22, LEVEL_GEXTREME_SPORTS, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  32,  66, LEVEL_MARSUPIAL_MADNESS, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  24,  18, LEVEL_WW_GEX_WRESTLING, BG_COLLISION_TYPE_TOPDOWN
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
    map_geometry  15,   8, LEVEL_LIZARD_OF_OZ, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  40,  56, LEVEL_CHANNEL_Z, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  31,  17, LEVEL_CHANNEL_Z, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  40,  32, LEVEL_CHANNEL_Z, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  40,  32, LEVEL_CHANNEL_Z, BG_COLLISION_TYPE_SIDESCROLLER
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
    map_geometry  15,   8, LEVEL_CHANNEL_Z, BG_COLLISION_TYPE_SIDESCROLLER
