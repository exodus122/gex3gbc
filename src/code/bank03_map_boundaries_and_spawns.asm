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
    INCLUDE "data/maps/map_boundary_indices.asm"

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
    INCLUDE "data/maps/map_boundary_records.asm"

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
    INCLUDE "data/maps/gex_cave_spawn_points.asm"

.data_03_652b_GexCaveSpawnMapIds:
    INCLUDE "data/maps/gex_cave_spawn_map_ids.asm"

.data_03_6537_LevelStartSpawnPoints:
    INCLUDE "data/maps/level_start_spawn_points.asm"
