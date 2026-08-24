; ==================================================================
; Bank 3. Where a map begins and ends, and where Gex is put down in it.
;
; Two routines that always run together - call_03_647c_Map_SetSpawnPosition calls
; call_03_6203_MapBounds_LoadForCurrentMap on the way out of every path - and four
; data tables between them.
;
; The boundary side is two levels deep on purpose. A per-map index table points into
; a smaller table of rectangles, so the fifteen Gex Cave and unused maps that share a
; rectangle share one record: 59 records for 61 maps, and a rectangle can be retuned
; in one place.
;
; Each rectangle is stored once and lands in RAM twice. The stored values are the
; CAMERA's limits, in wDC34_MapBoundaryXMinLo..wDC3B; the loader then adds the four
; PLAYER_BOUNDARY_*_INSET offsets and writes a second, wider rectangle into
; wDC3C_PlayerBoundaryXMinLo..wDC43. The player one is wider because the camera stops
; when its own top-left corner reaches the limit while Gex may keep walking most of a
; screen further - the max insets are a screen less a margin.
;
; The spawn side has three cases, and they are chosen in this order:
;
;   1. WARP_CHANGE_MAP set   a door or a map edge already picked the destination, and
;                            wDC6A_WarpDestinationX / wDC6C_WarpDestinationY hold it.
;                            call_00_1633_Map_LoadWarpDestination over in
;                            bank00_bg_map.asm is what put them there
;   2. any map but the cave  the level's fixed starting position, out of
;                            .data_03_6537_LevelStartSpawnPoints
;   3. the cave, map 0       Gex has come back out of a TV.
;                            wDC5B_LevelIdFromTVButton says which level's TV, that
;                            picks a cave map out of .data_03_652b_GexCaveSpawnMapIds
;                            and a position out of .data_03_64fb_GexCaveSpawnPoints,
;                            and the map data is re-loaded before the position is set
;
; All three converge on the same two calls: load the boundaries, then jump to
; call_00_10de_BgMap_UpdateWindowFromPlayerPos so the camera is already where it
; belongs on the first frame rather than sliding into place.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank0B_map_spawns.asm
; ------------------------------------------------------------------
; gex2's call_0b_4efe_Map_SetSpawnPosition is the same routine with the same three
; cases and the same closing jump, and the cases even correspond one to one:
;
;   the door case   gex2 does the door lookup HERE. It converts the player's position
;                   back to a block, searches the level's door list for a matching
;                   block, and returns without moving anyone if nothing matches. gex3
;                   did that work earlier, in bank00_bg_map.asm, and by the time this
;                   routine runs the answer is already sitting in two WRAM words
;   the hub case    gex2's Media Dimension is gex3's Gex Cave, and both index a hub
;                   spawn table by which TV was just exited. gex3 needs a second table
;                   because its hub is four maps and gex2's is one
;   the level case  the same fixed per-level position. gex2 indexes level * 8 +
;                   checkpoint * 2 because it stores several checkpoints per level;
;                   gex3 stores one position per level and handles checkpoints through
;                   the warp case above
;   coordinates     gex2's tables are in BLOCKS and get shifted up by
;                   SPAWN_UNITS_PER_BLOCK with a per-case offset. gex3's are already
;                   world pixels, which is why there is no conversion here at all
;   the boundaries  gex2 has no equivalent of the boundary half of this file. Every
;                   gex2 map is the same size, so its camera clamps against constants
;                   baked into call_00_13a6_BgMap_UpdateWindowFromPlayerPos
; ==================================================================

call_03_6203_MapBounds_LoadForCurrentMap:
; Loads the current map's rectangle into the eight camera-boundary bytes and the eight
; player-boundary bytes, going through the index table so that maps sharing a
; rectangle share a record.
;
; The chosen record number is kept in wDC2A_MapBoundaryIndex, which matters beyond
; this routine: call_02_7337_MapScroll_CheckHorizontal compares it against
; MAP_WRAP_BOUNDARY_INDEX to decide whether the map wraps, and
; call_00_10de_BgMap_UpdateWindowFromPlayerPos and
; call_02_5195_Player_MoveLeftClampedToMap both do the same.
;
; The two rectangles are built in one pass, `add` on the low byte and `adc A, $00` on
; the high byte, so each inset is a proper 16-bit addition even though only the low
; byte is ever non-zero in the constant
    ld   HL, wDB6C_CurrentMapId                       ;; 03:6203 $21 $6c $db
    ld   L, [HL]                                      ;; 03:6206 $6e
    ld   H, $00                                       ;; 03:6207 $26 $00
    ld   DE, .data_03_6210_MapBoundaryIndices         ;; 03:6209 $11 $10 $62
    add  HL, DE                                       ;; 03:620c $19
    ld   C, [HL]                                      ;; 03:620d $4e
    jr   .jr_03_624d                                  ;; 03:620e $18 $3d
.data_03_6210_MapBoundaryIndices:
; Which boundary record each map uses, one byte per MAP_* id. Several maps share a
; record - every Gex Cave map is the same rectangle, and so is every unused slot -
; which is why there are 59 records for 61 maps.
;
; Record MAP_WRAP_BOUNDARY_INDEX is the odd one out: a map pointed at it wraps
; horizontally, and call_02_7337_MapScroll_CheckHorizontal treats the step across the
; seam as an ordinary one-column scroll. No map here uses it - every entry is 1 or
; more - so the wrap path is reachable only if wDC2A_MapBoundaryIndex is set from
; somewhere else
    db   $01                                ; MAP_GEX_CAVE1
    db   $02                                ; MAP_HOLIDAY_TV1
    db   $06                                ; MAP_MYSTERY_TV1
    db   $10                                ; MAP_TUT_TV1
    db   $17                                ; MAP_WESTERN_STATION1
    db   $20                                ; MAP_ANIME_CHANNEL1
    db   $29                                ; MAP_SUPERHERO_SHOW1
    db   $2f                                ; MAP_GEXTREME_SPORTS1
    db   $33                                ; MAP_MARSUPIAL_MADNESS1
    db   $34                                ; MAP_WW_GEX_WRESTLING1
    db   $35                                ; MAP_LIZARD_OF_OZ1
    db   $36                                ; MAP_CHANNEL_Z1
    db   $01                                ; MAP_GEX_CAVE2
    db   $01                                ; MAP_GEX_CAVE3
    db   $01                                ; MAP_GEX_CAVE4
    db   $03                                ; MAP_HOLIDAY_TV2
    db   $04                                ; MAP_HOLIDAY_TV3
    db   $05                                ; MAP_HOLIDAY_TV4
    db   $07                                ; MAP_MYSTERY_TV2
    db   $08                                ; MAP_MYSTERY_TV3
    db   $09                                ; MAP_MYSTERY_TV4
    db   $0a                                ; MAP_MYSTERY_TV5
    db   $0b                                ; MAP_MYSTERY_TV6
    db   $0c                                ; MAP_MYSTERY_TV7
    db   $0d                                ; MAP_MYSTERY_TV8
    db   $0e                                ; MAP_MYSTERY_TV9
    db   $0f                                ; MAP_MYSTERY_TV10
    db   $11                                ; MAP_TUT_TV2
    db   $12                                ; MAP_TUT_TV3
    db   $13                                ; MAP_TUT_TV4
    db   $14                                ; MAP_TUT_TV5
    db   $15                                ; MAP_TUT_TV6
    db   $16                                ; MAP_TUT_TV7
    db   $18                                ; MAP_WESTERN_STATION2
    db   $19                                ; MAP_WESTERN_STATION3
    db   $1a                                ; MAP_WESTERN_STATION4
    db   $1b                                ; MAP_WESTERN_STATION5
    db   $1c                                ; MAP_WESTERN_STATION6
    db   $1d                                ; MAP_WESTERN_STATION7
    db   $1e                                ; MAP_WESTERN_STATION8
    db   $1f                                ; MAP_WESTERN_STATION9
    db   $21                                ; MAP_ANIME_CHANNEL2
    db   $22                                ; MAP_ANIME_CHANNEL3
    db   $23                                ; MAP_ANIME_CHANNEL4
    db   $24                                ; MAP_ANIME_CHANNEL5
    db   $25                                ; MAP_ANIME_CHANNEL6
    db   $26                                ; MAP_ANIME_CHANNEL7
    db   $27                                ; MAP_ANIME_CHANNEL8
    db   $28                                ; MAP_ANIME_CHANNEL9
    db   $2a                                ; MAP_SUPERHERO_SHOW2
    db   $2b                                ; MAP_SUPERHERO_SHOW3
    db   $2c                                ; MAP_SUPERHERO_SHOW4
    db   $2d                                ; MAP_SUPERHERO_SHOW5
    db   $2e                                ; MAP_SUPERHERO_SHOW6
    db   $30                                ; MAP_GEXTREME_SPORTS2
    db   $31                                ; MAP_GEXTREME_SPORTS3
    db   $32                                ; MAP_GEXTREME_SPORTS4
    db   $37                                ; MAP_CHANNEL_Z2
    db   $38                                ; MAP_CHANNEL_Z3
    db   $39                                ; MAP_CHANNEL_Z4
    db   $3a                                ; MAP_CHANNEL_Z5

.jr_03_624d:
    ld   HL, wDC2A_MapBoundaryIndex                   ;; 03:624d $21 $2a $dc
    ld   [HL], C                                      ;; 03:6250 $71
    ld   L, C                                         ;; 03:6251 $69
    ld   H, $00                                       ;; 03:6252 $26 $00
    add  HL, HL                                       ;; 03:6254 $29
    add  HL, HL                                       ;; 03:6255 $29
    add  HL, HL                                       ;; 03:6256 $29
    ld   DE, .data_03_62a4_MapBoundaryRecords         ;; 03:6257 $11 $a4 $62
    add  HL, DE                                       ;; 03:625a $19
    ld   A, [HL+]                                     ;; 03:625b $2a
    ld   [wDC34_MapBoundaryXMinLo], A                 ;; 03:625c $ea $34 $dc
    add  A, PLAYER_BOUNDARY_X_MIN_INSET               ;; 03:625f $c6 $10
    ld   [wDC3C_PlayerBoundaryXMinLo], A              ;; 03:6261 $ea $3c $dc
    ld   A, [HL+]                                     ;; 03:6264 $2a
    ld   [wDC35_MapBoundaryXMinHi], A                 ;; 03:6265 $ea $35 $dc
    adc  A, $00                                       ;; 03:6268 $ce $00
    ld   [wDC3D_PlayerBoundaryXMinHi], A              ;; 03:626a $ea $3d $dc
    ld   A, [HL+]                                     ;; 03:626d $2a
    ld   [wDC36_MapBoundaryXMaxLo], A                 ;; 03:626e $ea $36 $dc
    add  A, PLAYER_BOUNDARY_X_MAX_INSET               ;; 03:6271 $c6 $90
    ld   [wDC3E_PlayerBoundaryXMaxLo], A              ;; 03:6273 $ea $3e $dc
    ld   A, [HL+]                                     ;; 03:6276 $2a
    ld   [wDC37_MapBoundaryXMaxHi], A                 ;; 03:6277 $ea $37 $dc
    adc  A, $00                                       ;; 03:627a $ce $00
    ld   [wDC3F_PlayerBoundaryXMaxHi], A              ;; 03:627c $ea $3f $dc
    ld   A, [HL+]                                     ;; 03:627f $2a
    ld   [wDC38_MapBoundaryYMinLo], A                 ;; 03:6280 $ea $38 $dc
    add  A, PLAYER_BOUNDARY_Y_MIN_INSET               ;; 03:6283 $c6 $10
    ld   [wDC40_PlayerBoundaryYMinLo], A              ;; 03:6285 $ea $40 $dc
    ld   A, [HL+]                                     ;; 03:6288 $2a
    ld   [wDC39_MapBoundaryYMinHi], A                 ;; 03:6289 $ea $39 $dc
    adc  A, $00                                       ;; 03:628c $ce $00
    ld   [wDC41_PlayerBoundaryYMinHi], A              ;; 03:628e $ea $41 $dc
    ld   A, [HL+]                                     ;; 03:6291 $2a
    ld   [wDC3A_MapBoundaryYMaxLo], A                 ;; 03:6292 $ea $3a $dc
    add  A, PLAYER_BOUNDARY_Y_MAX_INSET               ;; 03:6295 $c6 $78
    ld   [wDC42_PlayerBoundaryYMaxLo], A              ;; 03:6297 $ea $42 $dc
    ld   A, [HL+]                                     ;; 03:629a $2a
    ld   [wDC3B_MapBoundaryYMaxHi], A                 ;; 03:629b $ea $3b $dc
    adc  A, $00                                       ;; 03:629e $ce $00
    ld   [wDC43_PlayerBoundaryYMaxHi], A              ;; 03:62a0 $ea $43 $dc
    ret                                               ;; 03:62a3 $c9
.data_03_62a4_MapBoundaryRecords:
; The map rectangles themselves, eight bytes each, in world pixels:
;
;   +0  dw  X min      +2  dw  X max
;   +4  dw  Y min      +6  dw  Y max
;
; The values as stored are the CAMERA's travel, and go into
; wDC34_MapBoundaryXMinLo... The loader also adds the four PLAYER_BOUNDARY_*_INSET
; offsets and writes that wider rectangle into wDC3C_PlayerBoundaryXMinLo.., which is
; how far GEX may walk - further than the camera, because the camera stops when its
; own corner reaches the limit while Gex has most of a screen left to cross.
;
; Record 0 is never selected by any map - see the index table above - and it is not a
; real rectangle either: X min and X max are both $0000, so it has no width at all
    map_bounds $0000, $0000, $0204, $0373    ; unused
    map_bounds $0000, $0140, $0000, $0090    ; MAP_GEX_CAVE1, MAP_GEX_CAVE2 +2 more
    map_bounds $0000, $0960, $0001, $047f    ; MAP_HOLIDAY_TV1
    map_bounds $0000, $00a0, $0001, $002f    ; MAP_HOLIDAY_TV2
    map_bounds $0000, $00a0, $00b1, $00df    ; MAP_HOLIDAY_TV3
    map_bounds $0000, $00a0, $0000, $0000    ; MAP_HOLIDAY_TV4
    map_bounds $0000, $0230, $0001, $024f    ; MAP_MYSTERY_TV1
    map_bounds $0000, $01e0, $0001, $01ef    ; MAP_MYSTERY_TV2
    map_bounds $0000, $0230, $0001, $015f    ; MAP_MYSTERY_TV3
    map_bounds $0000, $00a0, $0001, $002f    ; MAP_MYSTERY_TV4
    map_bounds $0000, $00a0, $00b1, $00df    ; MAP_MYSTERY_TV5
    map_bounds $0000, $00a0, $0161, $018f    ; MAP_MYSTERY_TV6
    map_bounds $0000, $0000, $0000, $0000    ; MAP_MYSTERY_TV7
    map_bounds $0000, $0000, $0000, $0000    ; MAP_MYSTERY_TV8
    map_bounds $0000, $00a0, $0211, $021f    ; MAP_MYSTERY_TV9
    map_bounds $0000, $01e0, $0290, $02a0    ; MAP_MYSTERY_TV10
    map_bounds $0000, $01d0, $0000, $00b0    ; MAP_TUT_TV1
    map_bounds $0000, $02a0, $0000, $02b0    ; MAP_TUT_TV2
    map_bounds $0000, $05a0, $0000, $00f0    ; MAP_TUT_TV3
    map_bounds $0000, $0400, $0000, $00b0    ; MAP_TUT_TV4
    map_bounds $0000, $0000, $0001, $000f    ; MAP_TUT_TV5
    map_bounds $0000, $00a0, $0000, $0010    ; MAP_TUT_TV6
    map_bounds $0000, $0280, $0000, $0110    ; MAP_TUT_TV7
    map_bounds $0000, $01e0, $0000, $00f0    ; MAP_WESTERN_STATION1
    map_bounds $0000, $01c0, $0000, $00e0    ; MAP_WESTERN_STATION2
    map_bounds $0000, $00a0, $0000, $0030    ; MAP_WESTERN_STATION3
    map_bounds $0000, $0000, $0000, $0010    ; MAP_WESTERN_STATION4
    map_bounds $0000, $0460, $0000, $00a0    ; MAP_WESTERN_STATION5
    map_bounds $0000, $0730, $0000, $02b0    ; MAP_WESTERN_STATION6
    map_bounds $0000, $0000, $0000, $0010    ; MAP_WESTERN_STATION7
    map_bounds $0000, $0000, $0090, $00a0    ; MAP_WESTERN_STATION8
    map_bounds $0000, $0000, $0000, $0010    ; MAP_WESTERN_STATION9
    map_bounds $0000, $0340, $0000, $0160    ; MAP_ANIME_CHANNEL1
    map_bounds $0000, $0260, $0000, $0160    ; MAP_ANIME_CHANNEL2
    map_bounds $0000, $02e0, $0000, $00b0    ; MAP_ANIME_CHANNEL3
    map_bounds $0000, $0540, $0000, $0220    ; MAP_ANIME_CHANNEL4
    map_bounds $03c0, $0eb0, $0000, $00e0    ; MAP_ANIME_CHANNEL5
    map_bounds $0000, $0140, $0000, $0090    ; MAP_ANIME_CHANNEL6
    map_bounds $0000, $0140, $0110, $01a0    ; MAP_ANIME_CHANNEL7
    map_bounds $0000, $0140, $0220, $02b0    ; MAP_ANIME_CHANNEL8
    map_bounds $0100, $0330, $0000, $00e0    ; MAP_ANIME_CHANNEL9
    map_bounds $0000, $0b50, $0000, $0160    ; MAP_SUPERHERO_SHOW1
    map_bounds $0000, $0b80, $0000, $03c0    ; MAP_SUPERHERO_SHOW2
    map_bounds $0000, $0390, $0000, $0160    ; MAP_SUPERHERO_SHOW3
    map_bounds $0000, $0560, $0000, $0160    ; MAP_SUPERHERO_SHOW4
    map_bounds $0000, $0260, $0000, $01a0    ; MAP_SUPERHERO_SHOW5
    map_bounds $0000, $0000, $0000, $0000    ; MAP_SUPERHERO_SHOW6
    map_bounds $0000, $0260, $0000, $0280    ; MAP_GEXTREME_SPORTS1
    map_bounds $0000, $00a0, $00b0, $00e0    ; MAP_GEXTREME_SPORTS2
    map_bounds $0000, $00a0, $00b0, $00e0    ; MAP_GEXTREME_SPORTS3
    map_bounds $0000, $00a0, $00b0, $00e0    ; MAP_GEXTREME_SPORTS4
    map_bounds $0000, $0160, $0000, $03a0    ; MAP_MARSUPIAL_MADNESS1
    map_bounds $0000, $00e0, $0000, $00a0    ; MAP_WW_GEX_WRESTLING1
    map_bounds $0028, $0028, $0000, $0000    ; MAP_LIZARD_OF_OZ1
    map_bounds $0000, $01e0, $0000, $0300    ; MAP_CHANNEL_Z1
    map_bounds $0000, $0150, $0000, $0090    ; MAP_CHANNEL_Z2
    map_bounds $0000, $01e0, $0000, $0180    ; MAP_CHANNEL_Z3
    map_bounds $0000, $01e0, $0000, $0180    ; MAP_CHANNEL_Z4
    map_bounds $0028, $0028, $0000, $0000    ; MAP_CHANNEL_Z5

call_03_647c_Map_SetSpawnPosition:
; Puts Gex where he belongs for the map about to be shown, then loads that map's
; boundaries and snaps the camera to him. The three cases are in the file header.
;
; Note what case 3 does that the others do not: it CHANGES wDB6C_CurrentMapId and
; calls call_03_6c89_MapData_LoadForCurrentMap again. Arriving in the cave from a TV
; is the one path where the caller does not know which map it wants - it knows which
; level's TV was used, and the map falls out of that.
;
; The two flags cleared at the top are the look-down camera offset, so a respawn never
; inherits a panned camera from wherever the last one happened.
;
; gex2's call_0b_4efe_Map_SetSpawnPosition
    xor  A, A                                         ;; 03:647c $af
    ld   [wDCAC_Player_CrouchLookDownRelated], A      ;; 03:647d $ea $ac $dc
    ld   [wDCAD], A                                   ;; 03:6480 $ea $ad $dc
    ld   HL, wDB6A_WarpFlags                          ;; 03:6483 $21 $6a $db
    bit  WARP_CHANGE_MAP_BIT, [HL]                    ;; 03:6486 $cb $56
    jr   Z, .jr_03_64a4                               ;; 03:6488 $28 $1a
    ld   A, [wDC6A_WarpDestinationX]                  ;; 03:648a $fa $6a $dc
    ld   [wD80E_PlayerXPosition], A                   ;; 03:648d $ea $0e $d8
    ld   A, [wDC6A_WarpDestinationX+1]                ;; 03:6490 $fa $6b $dc
    ld   [wD80E_PlayerXPosition+1], A                 ;; 03:6493 $ea $0f $d8
    ld   A, [wDC6C_WarpDestinationY]                  ;; 03:6496 $fa $6c $dc
    ld   [wD810_PlayerYPosition], A                   ;; 03:6499 $ea $10 $d8
    ld   A, [wDC6C_WarpDestinationY+1]                ;; 03:649c $fa $6d $dc
    ld   [wD810_PlayerYPosition+1], A                 ;; 03:649f $ea $11 $d8
    jr   .jr_03_64c6                                  ;; 03:64a2 $18 $22
.jr_03_64a4:
    ld   A, [wDB6C_CurrentMapId]                      ;; 03:64a4 $fa $6c $db
    and  A, A                                         ;; 03:64a7 $a7
    jr   Z, .jr_03_64cc                               ;; 03:64a8 $28 $22
    ld   HL, wDB6C_CurrentMapId                       ;; 03:64aa $21 $6c $db
    ld   L, [HL]                                      ;; 03:64ad $6e
    ld   H, $00                                       ;; 03:64ae $26 $00
    add  HL, HL                                       ;; 03:64b0 $29
    add  HL, HL                                       ;; 03:64b1 $29
    ld   DE, .data_03_6537_LevelStartSpawnPoints      ;; 03:64b2 $11 $37 $65
    add  HL, DE                                       ;; 03:64b5 $19
    ld   A, [HL+]                                     ;; 03:64b6 $2a
    ld   [wD80E_PlayerXPosition], A                   ;; 03:64b7 $ea $0e $d8
    ld   A, [HL+]                                     ;; 03:64ba $2a
    ld   [wD80E_PlayerXPosition+1], A                 ;; 03:64bb $ea $0f $d8
    ld   A, [HL+]                                     ;; 03:64be $2a
    ld   [wD810_PlayerYPosition], A                   ;; 03:64bf $ea $10 $d8
    ld   A, [HL]                                      ;; 03:64c2 $7e
    ld   [wD810_PlayerYPosition+1], A                 ;; 03:64c3 $ea $11 $d8
.jr_03_64c6:
    call call_03_6203_MapBounds_LoadForCurrentMap     ;; 03:64c6 $cd $03 $62
    jp   call_00_10de_BgMap_UpdateWindowFromPlayerPos ;; 03:64c9 $c3 $de $10
.jr_03_64cc:
    ld   HL, wDC5B_LevelIdFromTVButton                ;; 03:64cc $21 $5b $dc
    ld   L, [HL]                                      ;; 03:64cf $6e
    ld   H, $00                                       ;; 03:64d0 $26 $00
    ld   DE, .data_03_652b_GexCaveSpawnMapIds         ;; 03:64d2 $11 $2b $65
    add  HL, DE                                       ;; 03:64d5 $19
    ld   A, [HL]                                      ;; 03:64d6 $7e
    ld   [wDB6C_CurrentMapId], A                      ;; 03:64d7 $ea $6c $db
    call call_03_6c89_MapData_LoadForCurrentMap       ;; 03:64da $cd $89 $6c
    ld   HL, wDC5B_LevelIdFromTVButton                ;; 03:64dd $21 $5b $dc
    ld   L, [HL]                                      ;; 03:64e0 $6e
    ld   H, $00                                       ;; 03:64e1 $26 $00
    add  HL, HL                                       ;; 03:64e3 $29
    add  HL, HL                                       ;; 03:64e4 $29
    ld   DE, .data_03_64fb_GexCaveSpawnPoints         ;; 03:64e5 $11 $fb $64
    add  HL, DE                                       ;; 03:64e8 $19
    ld   A, [HL+]                                     ;; 03:64e9 $2a
    ld   [wD80E_PlayerXPosition], A                   ;; 03:64ea $ea $0e $d8
    ld   A, [HL+]                                     ;; 03:64ed $2a
    ld   [wD80E_PlayerXPosition+1], A                 ;; 03:64ee $ea $0f $d8
    ld   A, [HL+]                                     ;; 03:64f1 $2a
    ld   [wD810_PlayerYPosition], A                   ;; 03:64f2 $ea $10 $d8
    ld   A, [HL]                                      ;; 03:64f5 $7e
    ld   [wD810_PlayerYPosition+1], A                 ;; 03:64f6 $ea $11 $d8
    jr   .jr_03_64c6                                  ;; 03:64f9 $18 $cb
.data_03_64fb_GexCaveSpawnPoints:
; Where Gex stands in the cave after coming back out of a TV, one record per level,
; indexed by wDC5B_LevelIdFromTVButton. Paired with the map ids below: that table says
; WHICH cave map, this one says where on it
    spawn_pos $0100, $00f0            ; LEVEL_GEX_CAVE
    spawn_pos $01b0, $0050            ; LEVEL_HOLIDAY_TV
    spawn_pos $0030, $0050            ; LEVEL_MYSTERY_TV
    spawn_pos $0060, $00f0            ; LEVEL_TUT_TV
    spawn_pos $0180, $00f0            ; LEVEL_WESTERN_STATION
    spawn_pos $00f0, $0080            ; LEVEL_ANIME_CHANNEL
    spawn_pos $0100, $0040            ; LEVEL_SUPERHERO_SHOW
    spawn_pos $0030, $0030            ; LEVEL_GEXTREME_SPORTS
    spawn_pos $0050, $00f0            ; LEVEL_MARSUPIAL_MADNESS
    spawn_pos $01b0, $0030            ; LEVEL_WW_GEX_WRESTLING
    spawn_pos $0114, $00f0            ; LEVEL_LIZARD_OF_OZ
    spawn_pos $01b0, $0030            ; LEVEL_CHANNEL_Z

.data_03_652b_GexCaveSpawnMapIds:
; Which cave map each level's TV sits on. Level 0 is the cave itself and maps to
; MAP_GEX_CAVE1; the rest are spread over the three later cave maps
    db   MAP_GEX_CAVE1                     ; LEVEL_GEX_CAVE
    db   MAP_GEX_CAVE2                     ; LEVEL_HOLIDAY_TV
    db   MAP_GEX_CAVE2                     ; LEVEL_MYSTERY_TV
    db   MAP_GEX_CAVE3                     ; LEVEL_TUT_TV
    db   MAP_GEX_CAVE3                     ; LEVEL_WESTERN_STATION
    db   MAP_GEX_CAVE3                     ; LEVEL_ANIME_CHANNEL
    db   MAP_GEX_CAVE4                     ; LEVEL_SUPERHERO_SHOW
    db   MAP_GEX_CAVE3                     ; LEVEL_GEXTREME_SPORTS
    db   MAP_GEX_CAVE2                     ; LEVEL_MARSUPIAL_MADNESS
    db   MAP_GEX_CAVE3                     ; LEVEL_WW_GEX_WRESTLING
    db   MAP_GEX_CAVE4                     ; LEVEL_LIZARD_OF_OZ
    db   MAP_GEX_CAVE4                     ; LEVEL_CHANNEL_Z

.data_03_6537_LevelStartSpawnPoints:
; Where Gex starts a level, one record per level. Indexed by wDB6C_CurrentMapId,
; which at this point in a level load holds the LEVEL id - home.asm copies
; wDC1E_CurrentLevelID into it just before calling - and the first map of every level
; happens to have the same id as the level. So the twelve records cover every entry
; the index can produce, and a real map id above $0B never reaches here
    spawn_pos $0100, $00f0            ; LEVEL_GEX_CAVE
    spawn_pos $0050, $04c0            ; LEVEL_HOLIDAY_TV
    spawn_pos $0048, $02b0            ; LEVEL_MYSTERY_TV
    spawn_pos $00f0, $0110            ; LEVEL_TUT_TV
    spawn_pos $0038, $0150            ; LEVEL_WESTERN_STATION
    spawn_pos $01f0, $0080            ; LEVEL_ANIME_CHANNEL
    spawn_pos $0ad8, $0120            ; LEVEL_SUPERHERO_SHOW
    spawn_pos $0298, $02b8            ; LEVEL_GEXTREME_SPORTS
    spawn_pos $01a8, $03f8            ; LEVEL_MARSUPIAL_MADNESS
    spawn_pos $00c0, $0080            ; LEVEL_WW_GEX_WRESTLING
    spawn_pos $0078, $0060            ; LEVEL_LIZARD_OF_OZ
    spawn_pos $00c8, $0320            ; LEVEL_CHANNEL_Z
