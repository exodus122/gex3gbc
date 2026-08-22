; ==================================================================
; BG MAP - bank 00
;
; Everything that puts the background on screen and everything that moves the
; player from one map to another.
;
; ------------------------------------------------------------------
; What a map is made of
; ------------------------------------------------------------------
; The background is built out of BLOCKS. A block is 16x16 pixels, i.e. 2x2
; tiles, and one map is a rectangle of blocks whose width and height come from
; wDC1C_CurrentMapWidthAndHeightInBlocks. Maps are not all the same size, so
; call_00_10c7_BgMap_BuildRowOffsetTable precomputes the start of every row into
; wCD00_RowOffsetTableForMap when the map loads, and every routine below reaches
; a block as rowOffsetTable[block Y] + block X.
;
; Six ROM streams describe the map, each with its own bank and offset in the
; wDC01_MapBank .. wDC11_CollisionBlocksetOffset block of WRAM:
;
;   map                 one byte per block - LOW byte of the block id
;   extended map        one byte per block - HIGH byte of the block id
;   blockset            8 bytes per block id: 4 tile ids, then the 4 matching
;                       GBC attribute bytes (palette, flips, VRAM bank)
;   collision map       one byte per block - which collision block sits there
;   collision blockset  4 bytes per collision block id: 4 collision tile ids
;   tileset             the tile graphics themselves
;
; The map and extended map are two halves of one 16-bit block id, which is what
; lets a single map use more than 256 distinct blocks. Collision is its own
; parallel pair of layers rather than a property of the graphics, so the same
; scenery block can be solid in one place and passable in another.
;
; ------------------------------------------------------------------
; Getting it on screen
; ------------------------------------------------------------------
; Two paths, and neither of them writes VRAM from inside the loader.
;
;   * call_00_1056_BgMap_LoadFull runs when a map is entered. It sweeps the
;     whole visible area three times, once per value of
;     wDC33_BgMap_InitialLoadPass, staging each sweep in wC000_BgMapTileIds.
;     Config entries 7 and 8 of .data_00_0aa9_TilesetLoadConfigTable HDMA the
;     first two sweeps out to VRAM - attributes to bank 1, tile ids to bank 0.
;     The third sweep is collision, and is simply left in wC000_BgMapTileIds,
;     which is where call_03_4b4c_BgCollision_TestTile reads it for the rest of
;     the map's life.
;
;   * call_00_11c8_BgMap_LoadDirtyRegions runs once per frame. The camera
;     watchers in bank 02 raise a bit in wDC20_BgMapLoadingFlags for each edge
;     the camera has uncovered, and for each of those this assembles one strip
;     of BGMAP_STRIP_BLOCKS blocks - a row for vertical scrolling
;     (call_00_11e5_BgMap_LoadRowForVerticalScroll), a column for horizontal
;     (call_00_1351_BgMap_LoadColumnForHorizontalScroll) - into the wCF00
;     scratch buffers, then sets MAP_PENDING_VRAM_TRANSFER.
;     call_00_0b9f_Frame_GraphicsUpdateHandler flushes those buffers to the
;     tilemap during the next vblank and clears the flags.
;
; A strip loader is five bank switches in a row: read the block id low bytes,
; read the high bytes, read the collision ids, then expand the block ids through
; the blockset and the collision ids through the collision blockset. The expand
; steps overwrite the ids in place, so one buffer serves as both the id list and
; the tile list. Both the tilemap walk and the scratch walk wrap - `res 5` for
; the 32-byte scratch window, masking with $E0 for the 32-tile tilemap row - so
; a strip that runs off one side reappears on the other exactly as the hardware
; tilemap does.
;
; ------------------------------------------------------------------
; Getting between maps
; ------------------------------------------------------------------
; A level is many maps, and the second half of the file is how the player
; crosses between them. Two things can request a transition:
;
;   * call_00_150f_Map_CheckEdgeTransition - the player was clamped against a
;     map boundary, recorded in wDC8A_MapEdgeTouched. Which map that leads to
;     comes out of .data_00_153f_MapEdgeSpawnIds, indexed by map id and edge.
;
;   * call_00_1bbc_CheckForDoorAndEnter - the player pressed Up while standing
;     on a door listed in .data_00_1c33_DoorLocationsByMap. Doors can be locked
;     behind a wDCB1_LevelTriggerBuffer entry.
;
; Both end the same way: a spawn id in wDC69_PlayerSpawnIdInLevel and bit 2 of
; wDB6A_WarpFlags. call_00_1633_Map_LoadWarpDestination then turns that spawn id
; into a destination map and position, using the per-level tables at
; .data_00_16a2_LevelSpawnTables. A spawn record can name a fixed position, or
; link to the spawn record on the other side of the seam, in which case the
; arrival Y is the player's offset from that linked point - which is what makes
; walking off the side of a map continuous rather than a jump to a fixed spot.
;
; ------------------------------------------------------------------
; How this differs from gex2's bank00_bg_map.asm
; ------------------------------------------------------------------
; The two files answer the same question and share the flag byte, the strip
; idea and most of the naming, but almost none of the geometry:
;
;   block size    gex2 32x32 px (4x4 tiles), gex3 16x16 px (2x2 tiles)
;   strip width   gex2 6 blocks, gex3 11 blocks (BGMAP_STRIP_BLOCKS)
;   map size      gex2 is always 128 blocks wide, so it reaches a row by
;                 shifting; gex3 maps are each their own size, so
;                 call_00_10c7_BgMap_BuildRowOffsetTable precomputes every row
;                 start into wCD00_RowOffsetTableForMap and the loaders index
;                 that instead
;   block ids     gex2 has 256 per map and spends its second map layer on a
;                 one-bit "alt blockset" selector plus a whole secondary-tileset
;                 streaming system; gex3 spends the same layer on the high byte
;                 of a 16-bit block id and has no secondary tilesets at all
;   collision     gex2 reads it out of the blockset bank; gex3 has a separate
;                 collision map and collision blockset, expanded into
;                 wC000_BgMapTileIds
;   VRAM          gex2 writes tiles into VRAM inside the loader, toggling
;                 GBC banks with `set 3, H`; gex3 stages into wCF00 and defers
;                 the write to bank 03 in vblank
;   levels        a gex2 level is one map; a gex3 level is many maps stitched
;                 together with edge transitions and doors
;   block patches gex2's whole BlockPatch subsystem - runtime geometry changes
;                 registered into the $CC00-$CF00 tables and reapplied as the
;                 camera scrolls back - has no counterpart here
; ==================================================================

call_00_1056_BgMap_LoadFull:
; Builds the whole visible background for the map that has just been entered.
;
; After clearing game state and building wCD00_RowOffsetTableForMap for the new
; map's width, it loads the BG palettes and then walks
; .data_00_0aa9_TilesetLoadConfigTable entries 3-6, which stream the map's tile
; graphics into VRAM. Entries 7 and 8 are the interesting ones: each is an HDMA
; job that copies wC000_BgMapTileIds to $9800, entry 7 into VRAM bank 1 and
; entry 8 into VRAM bank 0. That is why the map is drawn three times over:
;
;   BGMAP_PASS_ATTRIBUTES -> config 7   attribute bytes to VRAM bank 1
;   BGMAP_PASS_TILE_IDS   -> config 8   tile ids to VRAM bank 0
;   BGMAP_PASS_COLLISION  -> no flush   collision ids stay in wC000_BgMapTileIds
;
; Each pass is one call_00_1a22_BgMap_LoadAllRowsForPass, which draws
; BGMAP_INITIAL_ROWS rows and leaves the camera where it started.
;
; Finally it copies image_003_4100_collision_tileset out of bank 03 into
; wC400_CollisionTilesetData, transposed - the source is 8 consecutive bytes per
; collision tile, the destination is 8 pages of 256 bytes, so that
; call_03_4b4c_BgCollision_TestTile can pick a row with `(y AND 7) + $C4` and
; index it by tile id in one go. Then it waits a frame, updates the map window
; and clears wDC20_BgMapLoadingFlags.
;
; gex2's call_00_1264_BgMap_LoadFull does the same job in a single pass of 22
; rows, because there it is the row loader itself that writes VRAM
    call call_00_0e3b_ClearGameStateVariables                                  ;; 00:1056 $cd $3b $0e
    call call_00_0e62_ResetFlagsAndVRAMState                                  ;; 00:1059 $cd $62 $0e
    call call_00_10c7_BgMap_BuildRowOffsetTable                                  ;; 00:105c $cd $c7 $10
    ld   C, $00                                        ;; 00:105f $0e $00
    farcall call_03_65c6_LoadBgPalettes
    ld   C, $03                                        ;; 00:106c $0e $03
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:106e $cd $6a $0a
    ld   C, $04                                        ;; 00:1071 $0e $04
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1073 $cd $6a $0a
    ld   C, $05                                        ;; 00:1076 $0e $05
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1078 $cd $6a $0a
    ld   C, $06                                        ;; 00:107b $0e $06
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:107d $cd $6a $0a
    ld   A, BGMAP_PASS_ATTRIBUTES                      ;; 00:1080 $3e $04
    call call_00_1a22_BgMap_LoadAllRowsForPass                                  ;; 00:1082 $cd $22 $1a  ; -> config 7 flushes this to VRAM bank 1
    ld   C, $07                                        ;; 00:1085 $0e $07
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1087 $cd $6a $0a
    ld   A, BGMAP_PASS_TILE_IDS                        ;; 00:108a $3e $00
    call call_00_1a22_BgMap_LoadAllRowsForPass                                  ;; 00:108c $cd $22 $1a  ; -> config 8 flushes this to VRAM bank 0
    ld   C, $08                                        ;; 00:108f $0e $08
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1091 $cd $6a $0a
    ld   A, BGMAP_PASS_COLLISION                       ;; 00:1094 $3e $80
    call call_00_1a22_BgMap_LoadAllRowsForPass                                  ;; 00:1096 $cd $22 $1a  ; no flush - stays in wC000_BgMapTileIds
    ld   A, BANK_03_COLLISION_AND_GRAPHICS_CODE                                        ;; 00:1099 $3e $03
    call call_00_0eee_SwitchBank                                  ;; 00:109b $cd $ee $0e
    ld   HL, image_003_4100_collision_tileset                                     ;; 00:109e $21 $00 $41
    ld   DE, wC400_CollisionTilesetData                                     ;; 00:10a1 $11 $00 $c4
    ; transpose the collision tileset: 8 consecutive source bytes per collision
    ; tile become one byte on each of 8 pages, so a lookup is page + tile id
.jr_00_10a4:
    push DE                                            ;; 00:10a4 $d5
    ld   B, $08                                        ;; 00:10a5 $06 $08
.jr_00_10a7:
    ld   A, [HL+]                                      ;; 00:10a7 $2a
    ld   [DE], A                                       ;; 00:10a8 $12
    inc  D                                             ;; 00:10a9 $14
    dec  B                                             ;; 00:10aa $05
    jr   NZ, .jr_00_10a7                               ;; 00:10ab $20 $fa
    pop  DE                                            ;; 00:10ad $d1
    inc  E                                             ;; 00:10ae $1c
    jr   NZ, .jr_00_10a4                               ;; 00:10af $20 $f3
    call call_00_0f08_RestoreBank                                  ;; 00:10b1 $cd $08 $0f
    call call_00_0b92_WaitForInterrupt                                  ;; 00:10b4 $cd $92 $0b
    farcall call_02_72fb_UpdateMapWindow
    xor  A, A                                          ;; 00:10c2 $af
    ld   [wDC20_BgMapLoadingFlags], A                                    ;; 00:10c3 $ea $20 $dc
    ret                                                ;; 00:10c6 $c9

call_00_10c7_BgMap_BuildRowOffsetTable:
; Fills wCD00_RowOffsetTableForMap with the byte offset of every map row:
; entry N = N * wDC1C_CurrentMapWidthAndHeightInBlocks, for all 256 possible
; rows. The running total is kept in HL and the map width is simply added once
; per entry, so no multiply is needed.
;
; The table is stored split - low bytes at $CD00+N, high bytes at $CE00+N -
; which is why the writes step `inc D` / `dec D` around each pair. Every strip
; loader in this file reads it back the same way:
;   ld L, [row] / ld H, HIGH(wCD00...) / ld E, [HL] / inc H / ld D, [HL]
;
; This exists because gex3 maps are each their own size. gex2 hardcodes a
; 128-block-wide blockmap and can reach a row with three `add HL, HL`, so it
; has nothing like this
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:10c7 $21 $1c $dc
    ld   C, [HL]                                       ;; 00:10ca $4e
    ld   B, $00                                        ;; 00:10cb $06 $00
    ld   DE, wCD00_RowOffsetTableForMap                                     ;; 00:10cd $11 $00 $cd
    ld   HL, $00                                       ;; 00:10d0 $21 $00 $00
.jr_00_10d3:
    ld   A, L                                          ;; 00:10d3 $7d
    ld   [DE], A                                       ;; 00:10d4 $12
    inc  D                                             ;; 00:10d5 $14
    ld   A, H                                          ;; 00:10d6 $7c
    ld   [DE], A                                       ;; 00:10d7 $12
    dec  D                                             ;; 00:10d8 $15
    add  HL, BC                                        ;; 00:10d9 $09
    inc  E                                             ;; 00:10da $1c
    jr   NZ, .jr_00_10d3                               ;; 00:10db $20 $f6
    ret                                                ;; 00:10dd $c9

call_00_10de_BgMap_UpdateWindowFromPlayerPos:
; Places the camera from the player's world position and publishes everything
; downstream needs from it. Returns immediately when
; wDC29_SkipMapWindowUpdateFlag is set, which is how cutscenes and scripted
; camera moves keep the camera where they put it.
;
; Each axis is handled the same way. Take the player position, subtract half a
; screen ($50 on X, $48 on Y) to centre the camera, then clamp it into the map's
; own rectangle - wDC34_MapBoundaryXMinLo..wDC37 on X, wDC38_MapBoundaryYMinLo..
; wDC3B on Y - snapping to the minimum on underflow and to the maximum when the
; camera would run past the right/bottom edge. On X there is one extra case:
; when wDC2A_MapBoundaryIndex is 0 the clamp is replaced by a plain `AND $0F` on
; the high byte, i.e. the camera wraps within a 4096-pixel span instead of
; stopping. That is the horizontally looping map.
;
; The clamped value is then written out three ways:
;   wDBF9_XPositionInMap / wDBFB_YPositionInMap   the camera itself, and the
;       origin every strip loader in this file works from
;   wDA14_CameraPos_Left..wDA1A_CameraPos_Bottom  the on-screen rectangle,
;       widened by $10 before and $B0 after, used to decide which entities are
;       near enough to update
;   wDAAC_CameraXHi / wDAAD_CameraYHi             the same position >> 4, i.e.
;       in blocks
;
; The Y input is offset by wDCAC_Player_CrouchLookDownRelated first, which is
; what lets the camera pan down when the player looks down.
;
; Same role as gex2's call_00_13a6_BgMap_UpdateWindowFromPlayerPos, but gex2
; clamps against constants ($20..$0F40 / $20..$0F50) because every one of its
; maps is the same size, and it derives its block range from the scroll value
; rather than storing a camera rectangle
    ld   A, [wDC29_SkipMapWindowUpdateFlag]                                    ;; 00:10de $fa $29 $dc
    and  A, A                                          ;; 00:10e1 $a7
    ret  NZ                                            ;; 00:10e2 $c0
    ld   HL, wDC34_MapBoundaryXMinLo                                     ;; 00:10e3 $21 $34 $dc
    ld   A, [HL+]                                      ;; 00:10e6 $2a
    ld   E, A                                          ;; 00:10e7 $5f
    ld   A, [HL+]                                      ;; 00:10e8 $2a
    ld   D, A                                          ;; 00:10e9 $57
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:10ea $fa $0e $d8
    sub  A, $50                                        ;; 00:10ed $d6 $50
    ld   C, A                                          ;; 00:10ef $4f
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:10f0 $fa $0f $d8
    sbc  A, $00                                        ;; 00:10f3 $de $00
    ld   B, A                                          ;; 00:10f5 $47
    jr   C, .jr_00_1109                                ;; 00:10f6 $38 $11
    ld   A, C                                          ;; 00:10f8 $79
    sub  A, E                                          ;; 00:10f9 $93
    ld   A, B                                          ;; 00:10fa $78
    sbc  A, D                                          ;; 00:10fb $9a
    jr   C, .jr_00_1109                                ;; 00:10fc $38 $0b
    ld   A, [HL+]                                      ;; 00:10fe $2a
    ld   E, A                                          ;; 00:10ff $5f
    ld   D, [HL]                                       ;; 00:1100 $56
    ld   A, C                                          ;; 00:1101 $79
    sub  A, E                                          ;; 00:1102 $93
    ld   A, B                                          ;; 00:1103 $78
    sbc  A, D                                          ;; 00:1104 $9a
    jr   NC, .jr_00_1109                               ;; 00:1105 $30 $02
    ld   E, C                                          ;; 00:1107 $59
    ld   D, B                                          ;; 00:1108 $50
.jr_00_1109:
    ld   A, [wDC2A_MapBoundaryIndex]                                    ;; 00:1109 $fa $2a $dc
    cp   A, $00                                        ;; 00:110c $fe $00
    jr   NZ, .jr_00_1115                               ;; 00:110e $20 $05
    ld   E, C                                          ;; 00:1110 $59
    ld   A, B                                          ;; 00:1111 $78
    and  A, $0f                                        ;; 00:1112 $e6 $0f
    ld   D, A                                          ;; 00:1114 $57
.jr_00_1115:
    push DE                                            ;; 00:1115 $d5
    push DE                                            ;; 00:1116 $d5
    ld   A, E                                          ;; 00:1117 $7b
    ld   [wDBF9_XPositionInMap], A                                    ;; 00:1118 $ea $f9 $db
    ld   A, D                                          ;; 00:111b $7a
    ld   [wDBF9_XPositionInMap+1], A                                    ;; 00:111c $ea $fa $db
    ld   A, E                                          ;; 00:111f $7b
    sub  A, $10                                        ;; 00:1120 $d6 $10
    ld   E, A                                          ;; 00:1122 $5f
    ld   A, D                                          ;; 00:1123 $7a
    sbc  A, $00                                        ;; 00:1124 $de $00
    ld   D, A                                          ;; 00:1126 $57
    jr   NC, .jr_00_112c                               ;; 00:1127 $30 $03
    ld   DE, $00                                       ;; 00:1129 $11 $00 $00
.jr_00_112c:
    ld   A, E                                          ;; 00:112c $7b
    ld   [wDA14_CameraPos_Left], A                                    ;; 00:112d $ea $14 $da
    ld   A, D                                          ;; 00:1130 $7a
    ld   [wDA14_CameraPos_Left+1], A                                    ;; 00:1131 $ea $15 $da
    pop  DE                                            ;; 00:1134 $d1
    ld   A, E                                          ;; 00:1135 $7b
    add  A, $b0                                        ;; 00:1136 $c6 $b0
    ld   [wDA16_CameraPos_Right], A                                    ;; 00:1138 $ea $16 $da
    ld   A, D                                          ;; 00:113b $7a
    adc  A, $00                                        ;; 00:113c $ce $00
    ld   [wDA16_CameraPos_Right+1], A                                    ;; 00:113e $ea $17 $da
    pop  DE                                            ;; 00:1141 $d1
    srl  D                                             ;; 00:1142 $cb $3a
    rr   E                                             ;; 00:1144 $cb $1b
    srl  D                                             ;; 00:1146 $cb $3a
    rr   E                                             ;; 00:1148 $cb $1b
    srl  D                                             ;; 00:114a $cb $3a
    rr   E                                             ;; 00:114c $cb $1b
    srl  D                                             ;; 00:114e $cb $3a
    rr   E                                             ;; 00:1150 $cb $1b
    ld   A, E                                          ;; 00:1152 $7b
    ld   [wDAAC_CameraXHi], A                                    ;; 00:1153 $ea $ac $da
    ld   HL, wDCAC_Player_CrouchLookDownRelated                                     ;; 00:1156 $21 $ac $dc
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:1159 $fa $10 $d8
    add  A, [HL]                                       ;; 00:115c $86
    ld   C, A                                          ;; 00:115d $4f
    inc  HL                                            ;; 00:115e $23
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:115f $fa $11 $d8
    adc  A, [HL]                                       ;; 00:1162 $8e
    ld   B, A                                          ;; 00:1163 $47
    ld   HL, wDC38_MapBoundaryYMinLo                                     ;; 00:1164 $21 $38 $dc
    ld   A, [HL+]                                      ;; 00:1167 $2a
    ld   E, A                                          ;; 00:1168 $5f
    ld   A, [HL+]                                      ;; 00:1169 $2a
    ld   D, A                                          ;; 00:116a $57
    ld   A, C                                          ;; 00:116b $79
    sub  A, $48                                        ;; 00:116c $d6 $48
    ld   C, A                                          ;; 00:116e $4f
    ld   A, B                                          ;; 00:116f $78
    sbc  A, $00                                        ;; 00:1170 $de $00
    ld   B, A                                          ;; 00:1172 $47
    jr   C, .jr_00_1186                                ;; 00:1173 $38 $11
    ld   A, C                                          ;; 00:1175 $79
    sub  A, E                                          ;; 00:1176 $93
    ld   A, B                                          ;; 00:1177 $78
    sbc  A, D                                          ;; 00:1178 $9a
    jr   C, .jr_00_1186                                ;; 00:1179 $38 $0b
    ld   A, [HL+]                                      ;; 00:117b $2a
    ld   E, A                                          ;; 00:117c $5f
    ld   D, [HL]                                       ;; 00:117d $56
    ld   A, C                                          ;; 00:117e $79
    sub  A, E                                          ;; 00:117f $93
    ld   A, B                                          ;; 00:1180 $78
    sbc  A, D                                          ;; 00:1181 $9a
    jr   NC, .jr_00_1186                               ;; 00:1182 $30 $02
    ld   E, C                                          ;; 00:1184 $59
    ld   D, B                                          ;; 00:1185 $50
.jr_00_1186:
    push DE                                            ;; 00:1186 $d5
    push DE                                            ;; 00:1187 $d5
    ld   A, E                                          ;; 00:1188 $7b
    ld   [wDBFB_YPositionInMap], A                                    ;; 00:1189 $ea $fb $db
    ld   A, D                                          ;; 00:118c $7a
    ld   [wDBFB_YPositionInMap+1], A                                    ;; 00:118d $ea $fc $db
    ld   A, E                                          ;; 00:1190 $7b
    sub  A, $10                                        ;; 00:1191 $d6 $10
    ld   E, A                                          ;; 00:1193 $5f
    ld   A, D                                          ;; 00:1194 $7a
    sbc  A, $00                                        ;; 00:1195 $de $00
    ld   D, A                                          ;; 00:1197 $57
    jr   NC, .jr_00_119d                               ;; 00:1198 $30 $03
    ld   DE, $00                                       ;; 00:119a $11 $00 $00
.jr_00_119d:
    ld   A, E                                          ;; 00:119d $7b
    ld   [wDA18_CameraPos_Top], A                                    ;; 00:119e $ea $18 $da
    ld   A, D                                          ;; 00:11a1 $7a
    ld   [wDA18_CameraPos_Top+1], A                                    ;; 00:11a2 $ea $19 $da
    pop  DE                                            ;; 00:11a5 $d1
    ld   A, E                                          ;; 00:11a6 $7b
    add  A, $b0                                        ;; 00:11a7 $c6 $b0
    ld   [wDA1A_CameraPos_Bottom], A                                    ;; 00:11a9 $ea $1a $da
    ld   A, D                                          ;; 00:11ac $7a
    adc  A, $00                                        ;; 00:11ad $ce $00
    ld   [wDA1A_CameraPos_Bottom+1], A                                    ;; 00:11af $ea $1b $da
    pop  DE                                            ;; 00:11b2 $d1
    srl  D                                             ;; 00:11b3 $cb $3a
    rr   E                                             ;; 00:11b5 $cb $1b
    srl  D                                             ;; 00:11b7 $cb $3a
    rr   E                                             ;; 00:11b9 $cb $1b
    srl  D                                             ;; 00:11bb $cb $3a
    rr   E                                             ;; 00:11bd $cb $1b
    srl  D                                             ;; 00:11bf $cb $3a
    rr   E                                             ;; 00:11c1 $cb $1b
    ld   A, E                                          ;; 00:11c3 $7b
    ld   [wDAAD_CameraYHi], A                                    ;; 00:11c4 $ea $ad $da
    ret                                                ;; 00:11c7 $c9

call_00_11c8_BgMap_LoadDirtyRegions:
; Once-per-frame entry point for scrolling. Spin-waits while
; MAP_PENDING_VRAM_TRANSFER is still set, because that means the previous
; frame's strip is still sitting in the wCF00 buffers waiting on vblank and
; overwriting it now would lose it.
;
; Then, from wDC20_BgMapLoadingFlags: a vertical scroll bit calls the row
; loader, a horizontal scroll bit calls the column loader, and both can fire in
; the same frame when the camera moved diagonally. Setting
; MAP_PENDING_VRAM_TRANSFER at the end hands the buffers to
; call_00_0b9f_Frame_GraphicsUpdateHandler, which flushes them and clears the
; whole flag byte.
;
; Structurally identical to gex2's call_00_1455_BgMap_LoadDirtyRegions - the
; difference is only what the two loaders do once they are called
    ld   HL, wDC20_BgMapLoadingFlags                                     ;; 00:11c8 $21 $20 $dc
    bit  MAP_PENDING_VRAM_TRANSFER, [HL]               ;; 00:11cb $cb $7e
    jr   NZ, call_00_11c8_BgMap_LoadDirtyRegions                              ;; 00:11cd $20 $f9
    ld   A, [wDC20_BgMapLoadingFlags]                                    ;; 00:11cf $fa $20 $dc
    and  A, MAP_SCROLL_UP | MAP_SCROLL_DOWN            ;; 00:11d2 $e6 $03
    call NZ, call_00_11e5_BgMap_LoadRowForVerticalScroll                              ;; 00:11d4 $c4 $e5 $11
    ld   A, [wDC20_BgMapLoadingFlags]                                    ;; 00:11d7 $fa $20 $dc
    and  A, MAP_SCROLL_LEFT | MAP_SCROLL_RIGHT         ;; 00:11da $e6 $0c
    call NZ, call_00_1351_BgMap_LoadColumnForHorizontalScroll                              ;; 00:11dc $c4 $51 $13
    ld   HL, wDC20_BgMapLoadingFlags                                     ;; 00:11df $21 $20 $dc
    set  MAP_PENDING_VRAM_TRANSFER, [HL]               ;; 00:11e2 $cb $fe
    ret                                                ;; 00:11e4 $c9

call_00_11e5_BgMap_LoadRowForVerticalScroll:
; Vertical scrolling exposes a new horizontal ROW, so this loader builds one:
; BGMAP_STRIP_BLOCKS blocks side by side, starting at the camera's block column.
; The column twin below handles the other axis.
;
; Which row depends on the direction. MAP_SCROLL_DOWN takes camera Y + $88, the
; row just off the bottom of the screen; otherwise camera Y - 1, the row just
; off the top. `ld HL, rIE` is $FFFF, i.e. -1 - the disassembler picked the
; hardware register name for the constant.
;
; call_00_14e2_BgMap_SetScrollBlockCoords then turns the camera position into
; wDC27_BgMap_ScrollBlockX / wDC28_BgMap_ScrollBlockY, and the routine works out
; three addresses that the rest of it keeps coming back to:
;   wDC21_BgMap_RowWritePosLo/Hi   where in the $9800 tilemap this row lands
;   wDC25_BgMap_ScratchRowOffset   where in the wCF00 buffers it is staged
;   the E value pushed twice        which half of each block to read, i.e.
;                                   (camera Y AND 8) ? 2 : 0
;
; Then it makes five passes, switching banks each time:
;   1. map bank            11 block-id low bytes  -> scratch, stride 2
;   2. extended map bank   11 block-id high bytes -> scratch, interleaved
;   3. collision map bank  11 collision block ids -> wC000_BgMapTileIds
;   4. blockset bank       expand each 16-bit block id: tile ids overwrite the
;                          scratch entry in place, attribute bytes go to the
;                          +$80 half (wCF80_BgMap_TempScratchRowAttributes)
;   5. collision blockset  expand each collision id into 2 collision tile ids,
;                          back over the same wC000_BgMapTileIds bytes
;
; Every walk wraps with `res 5` (32-byte scratch window) or by masking L with
; $E0 (32-tile tilemap row), so a strip that runs off one side reappears on the
; other exactly as the hardware tilemap does.
;
; Nothing here writes VRAM - that is the big split from gex2's
; call_00_1472_BgMap_LoadRowForVerticalScroll, which writes tiles straight in.
; gex2 also reads 6 blocks instead of 11, applies its alt-blockset mask and any
; registered block patches to the strip before expanding it, and expands each
; block into 8 tiles instead of 2 because its blocks are 32x32
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:11e5 $21 $fb $db
    ld   A, [HL+]                                      ;; 00:11e8 $2a
    ld   C, A                                          ;; 00:11e9 $4f
    ld   A, [HL+]                                      ;; 00:11ea $2a
    ld   B, A                                          ;; 00:11eb $47                ; BC = camera Y
    ld   HL, $88                                       ;; 00:11ec $21 $88 $00        ; row below the screen
    ld   A, [wDC20_BgMapLoadingFlags]                                    ;; 00:11ef $fa $20 $dc
    and  A, MAP_SCROLL_DOWN                              ;; 00:11f2 $e6 $02
    jr   NZ, .jr_00_11f9                               ;; 00:11f4 $20 $03
    ld   HL, rIE                                       ;; 00:11f6 $21 $ff $ff        ; = -1, the row above the screen
.jr_00_11f9:
    add  HL, BC                                        ;; 00:11f9 $09
    ld   C, L                                          ;; 00:11fa $4d
    ld   B, H                                          ;; 00:11fb $44
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:11fc $21 $f9 $db
    ld   E, [HL]                                       ;; 00:11ff $5e
    inc  HL                                            ;; 00:1200 $23
    ld   D, [HL]                                       ;; 00:1201 $56
    call call_00_14e2_BgMap_SetScrollBlockCoords                                  ;; 00:1202 $cd $e2 $14
    ld   A, C                                          ;; 00:1205 $79
    and  A, $f8                                        ;; 00:1206 $e6 $f8
    ld   L, A                                          ;; 00:1208 $6f
    ld   H, $00                                        ;; 00:1209 $26 $00
    add  HL, HL                                        ;; 00:120b $29
    add  HL, HL                                        ;; 00:120c $29
    ld   A, E                                          ;; 00:120d $7b
    swap A                                             ;; 00:120e $cb $37
    add  A, A                                          ;; 00:1210 $87
    and  A, $1e                                        ;; 00:1211 $e6 $1e
    ld   [wDC25_BgMap_ScratchRowOffset], A                                    ;; 00:1213 $ea $25 $dc
    or   A, L                                          ;; 00:1216 $b5
    ld   [wDC21_BgMap_RowWritePosLo], A                                    ;; 00:1217 $ea $21 $dc
    ld   A, H                                          ;; 00:121a $7c
    or   A, $98                                        ;; 00:121b $f6 $98
    ld   [wDC22_BgMap_RowWritePosHi], A                                    ;; 00:121d $ea $22 $dc
    ld   A, C                                          ;; 00:1220 $79
    rrca                                               ;; 00:1221 $0f
    rrca                                               ;; 00:1222 $0f
    and  A, $02                                        ;; 00:1223 $e6 $02
    ld   E, A                                          ;; 00:1225 $5f
    ld   D, $00                                        ;; 00:1226 $16 $00
    push DE                                            ;; 00:1228 $d5                ; E = (camera Y AND 8) ? 2 : 0
    push DE                                            ;; 00:1229 $d5                ; popped again by passes 4 and 5
    ; --- pass 1: block id low bytes from the map ---
    ld   A, [wDC01_MapBank]                                    ;; 00:122a $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:122d $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:1230 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1233 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:1234 $26 $cd
    ld   E, [HL]                                       ;; 00:1236 $5e
    inc  H                                             ;; 00:1237 $24
    ld   D, [HL]                                       ;; 00:1238 $56
    ld   HL, wDC02_MapBankOffset                                     ;; 00:1239 $21 $02 $dc
    ld   A, [HL+]                                      ;; 00:123c $2a
    add  A, E                                          ;; 00:123d $83
    ld   E, A                                          ;; 00:123e $5f
    ld   A, [HL]                                       ;; 00:123f $7e
    adc  A, D                                          ;; 00:1240 $8a
    ld   D, A                                          ;; 00:1241 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:1242 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1245 $6e
    ld   H, $00                                        ;; 00:1246 $26 $00
    add  HL, DE                                        ;; 00:1248 $19
    ld   E, L                                          ;; 00:1249 $5d
    ld   D, H                                          ;; 00:124a $54
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:124b $21 $25 $dc
    ld   L, [HL]                                       ;; 00:124e $6e
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:124f $26 $cf
    ld   B, $0b                                        ;; 00:1251 $06 $0b
.jr_00_1253:
    ld   A, [DE]                                       ;; 00:1253 $1a
    ld   [HL+], A                                      ;; 00:1254 $22
    inc  L                                             ;; 00:1255 $2c
    res  5, L                                          ;; 00:1256 $cb $ad
    inc  DE                                            ;; 00:1258 $13
    dec  B                                             ;; 00:1259 $05
    jr   NZ, .jr_00_1253                               ;; 00:125a $20 $f7
    call call_00_0f08_RestoreBank                                  ;; 00:125c $cd $08 $0f
    ; --- pass 2: block id high bytes from the extended map, interleaved ---
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:125f $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1262 $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:1265 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1268 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:1269 $26 $cd
    ld   E, [HL]                                       ;; 00:126b $5e
    inc  H                                             ;; 00:126c $24
    ld   D, [HL]                                       ;; 00:126d $56
    ld   HL, wDC05_MapExtendedBankOffset                                     ;; 00:126e $21 $05 $dc
    ld   A, [HL+]                                      ;; 00:1271 $2a
    add  A, E                                          ;; 00:1272 $83
    ld   E, A                                          ;; 00:1273 $5f
    ld   A, [HL]                                       ;; 00:1274 $7e
    adc  A, D                                          ;; 00:1275 $8a
    ld   D, A                                          ;; 00:1276 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:1277 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:127a $6e
    ld   H, $00                                        ;; 00:127b $26 $00
    add  HL, DE                                        ;; 00:127d $19
    ld   E, L                                          ;; 00:127e $5d
    ld   D, H                                          ;; 00:127f $54
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:1280 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1283 $6e
    inc  L                                             ;; 00:1284 $2c
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1285 $26 $cf
    ld   B, $0b                                        ;; 00:1287 $06 $0b
.jr_00_1289:
    ld   A, [DE]                                       ;; 00:1289 $1a
    ld   [HL+], A                                      ;; 00:128a $22
    res  5, L                                          ;; 00:128b $cb $ad
    inc  L                                             ;; 00:128d $2c
    inc  DE                                            ;; 00:128e $13
    dec  B                                             ;; 00:128f $05
    jr   NZ, .jr_00_1289                               ;; 00:1290 $20 $f7
    call call_00_0f08_RestoreBank                                  ;; 00:1292 $cd $08 $0f
    ; --- pass 3: collision block ids, staged in wC000_BgMapTileIds ---
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1295 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1298 $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:129b $21 $28 $dc
    ld   L, [HL]                                       ;; 00:129e $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:129f $26 $cd
    ld   E, [HL]                                       ;; 00:12a1 $5e
    inc  H                                             ;; 00:12a2 $24
    ld   D, [HL]                                       ;; 00:12a3 $56
    ld   HL, wDC0E_MapCollisionBankOffset                                     ;; 00:12a4 $21 $0e $dc
    ld   A, [HL+]                                      ;; 00:12a7 $2a
    add  A, E                                          ;; 00:12a8 $83
    ld   E, A                                          ;; 00:12a9 $5f
    ld   A, [HL]                                       ;; 00:12aa $7e
    adc  A, D                                          ;; 00:12ab $8a
    ld   D, A                                          ;; 00:12ac $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:12ad $21 $27 $dc
    ld   L, [HL]                                       ;; 00:12b0 $6e
    ld   H, $00                                        ;; 00:12b1 $26 $00
    add  HL, DE                                        ;; 00:12b3 $19
    ld   E, L                                          ;; 00:12b4 $5d
    ld   D, H                                          ;; 00:12b5 $54
    ld   HL, wDC22_BgMap_RowWritePosHi                                     ;; 00:12b6 $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:12b9 $3a
    ld   L, [HL]                                       ;; 00:12ba $6e
    and  A, $03                                        ;; 00:12bb $e6 $03
    add  A, $c0                                        ;; 00:12bd $c6 $c0
    ld   H, A                                          ;; 00:12bf $67
    ld   B, $0b                                        ;; 00:12c0 $06 $0b
.jr_00_12c2:
    ld   A, [DE]                                       ;; 00:12c2 $1a
    ld   [HL+], A                                      ;; 00:12c3 $22
    inc  HL                                            ;; 00:12c4 $23
    ld   A, L                                          ;; 00:12c5 $7d
    and  A, $1f                                        ;; 00:12c6 $e6 $1f
    jr   NZ, .jr_00_12cf                               ;; 00:12c8 $20 $05
    dec  HL                                            ;; 00:12ca $2b
    ld   A, L                                          ;; 00:12cb $7d
    and  A, $e0                                        ;; 00:12cc $e6 $e0
    ld   L, A                                          ;; 00:12ce $6f
.jr_00_12cf:
    inc  DE                                            ;; 00:12cf $13
    dec  B                                             ;; 00:12d0 $05
    jr   NZ, .jr_00_12c2                               ;; 00:12d1 $20 $ef
    call call_00_0f08_RestoreBank                                  ;; 00:12d3 $cd $08 $0f
    ; --- pass 4: expand each block id into 2 tile ids + 2 attribute bytes ---
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:12d6 $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:12d9 $cd $ee $0e
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:12dc $21 $25 $dc
    ld   E, [HL]                                       ;; 00:12df $5e
    ld   D, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:12e0 $16 $cf
    pop  BC                                            ;; 00:12e2 $c1
    ld   A, [wDC0B_BlocksetBankOffset]                                    ;; 00:12e3 $fa $0b $dc
    add  A, C                                          ;; 00:12e6 $81
    ld   C, A                                          ;; 00:12e7 $4f
    ld   A, [wDC0B_BlocksetBankOffset+1]                                    ;; 00:12e8 $fa $0c $dc
    adc  A, B                                          ;; 00:12eb $88
    ld   B, A                                          ;; 00:12ec $47
    ld   A, $0b                                        ;; 00:12ed $3e $0b
.jr_00_12ef:
    push AF                                            ;; 00:12ef $f5
    ld   A, [DE]                                       ;; 00:12f0 $1a                ; block id low byte (map)
    ld   L, A                                          ;; 00:12f1 $6f
    inc  E                                             ;; 00:12f2 $1c
    ld   A, [DE]                                       ;; 00:12f3 $1a                ; block id high byte (extended map)
    ld   H, A                                          ;; 00:12f4 $67
    dec  E                                             ;; 00:12f5 $1d
    add  HL, HL                                        ;; 00:12f6 $29
    add  HL, HL                                        ;; 00:12f7 $29
    add  HL, HL                                        ;; 00:12f8 $29                ; * BGMAP_BLOCKSET_ENTRY_SIZE
    add  HL, BC                                        ;; 00:12f9 $09                ; + blockset base + half-of-block offset
    ld   A, [HL+]                                      ;; 00:12fa $2a                ; blockset bytes 0-1: the row's two tile ids
    ld   [DE], A                                       ;; 00:12fb $12                ; overwrite the block id in place
    inc  E                                             ;; 00:12fc $1c
    ld   A, [HL+]                                      ;; 00:12fd $2a
    ld   [DE], A                                       ;; 00:12fe $12
    dec  E                                             ;; 00:12ff $1d
    set  7, E                                          ;; 00:1300 $cb $fb                ; -> wCF80_BgMap_TempScratchRowAttributes
    inc  HL                                            ;; 00:1302 $23
    inc  HL                                            ;; 00:1303 $23                ; skip to bytes 4-5, the matching attributes
    ld   A, [HL+]                                      ;; 00:1304 $2a
    ld   [DE], A                                       ;; 00:1305 $12
    inc  E                                             ;; 00:1306 $1c
    ld   A, [HL+]                                      ;; 00:1307 $2a
    ld   [DE], A                                       ;; 00:1308 $12
    res  7, E                                          ;; 00:1309 $cb $bb                ; back to the tile id half
    inc  E                                             ;; 00:130b $1c
    res  5, E                                          ;; 00:130c $cb $ab
    pop  AF                                            ;; 00:130e $f1
    dec  A                                             ;; 00:130f $3d
    jr   NZ, .jr_00_12ef                               ;; 00:1310 $20 $dd
    call call_00_0f08_RestoreBank                                  ;; 00:1312 $cd $08 $0f
    ; --- pass 5: expand each collision block id into 2 collision tile ids ---
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:1315 $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1318 $cd $ee $0e
    ld   HL, wDC22_BgMap_RowWritePosHi                                     ;; 00:131b $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:131e $3a
    ld   E, [HL]                                       ;; 00:131f $5e
    and  A, $03                                        ;; 00:1320 $e6 $03
    add  A, $c0                                        ;; 00:1322 $c6 $c0
    ld   D, A                                          ;; 00:1324 $57
    pop  BC                                            ;; 00:1325 $c1
    ld   A, [wDC11_CollisionBlocksetOffset]                                    ;; 00:1326 $fa $11 $dc
    add  A, C                                          ;; 00:1329 $81
    ld   C, A                                          ;; 00:132a $4f
    ld   A, [wDC11_CollisionBlocksetOffset+1]                                    ;; 00:132b $fa $12 $dc
    adc  A, B                                          ;; 00:132e $88
    ld   B, A                                          ;; 00:132f $47
    ld   A, $0b                                        ;; 00:1330 $3e $0b
.jr_00_1332:
    push AF                                            ;; 00:1332 $f5
    ld   A, [DE]                                       ;; 00:1333 $1a
    ld   L, A                                          ;; 00:1334 $6f
    ld   H, $00                                        ;; 00:1335 $26 $00
    add  HL, HL                                        ;; 00:1337 $29
    add  HL, HL                                        ;; 00:1338 $29
    add  HL, BC                                        ;; 00:1339 $09
    ld   A, [HL+]                                      ;; 00:133a $2a
    ld   [DE], A                                       ;; 00:133b $12
    inc  DE                                            ;; 00:133c $13
    ld   A, [HL]                                       ;; 00:133d $7e
    ld   [DE], A                                       ;; 00:133e $12
    inc  DE                                            ;; 00:133f $13
    ld   A, E                                          ;; 00:1340 $7b
    and  A, $1f                                        ;; 00:1341 $e6 $1f
    jr   NZ, .jr_00_134a                               ;; 00:1343 $20 $05
    dec  DE                                            ;; 00:1345 $1b
    ld   A, E                                          ;; 00:1346 $7b
    and  A, $e0                                        ;; 00:1347 $e6 $e0
    ld   E, A                                          ;; 00:1349 $5f
.jr_00_134a:
    pop  AF                                            ;; 00:134a $f1
    dec  A                                             ;; 00:134b $3d
    jr   NZ, .jr_00_1332                               ;; 00:134c $20 $e4
    jp   call_00_0f08_RestoreBank                                  ;; 00:134e $c3 $08 $0f

call_00_1351_BgMap_LoadColumnForHorizontalScroll:
; The vertical COLUMN twin of the row loader above. Horizontal scrolling exposes
; a column, so this one reads BGMAP_STRIP_BLOCKS blocks stacked vertically,
; stepping wDC1C_CurrentMapWidthAndHeightInBlocks bytes - one map row - between
; each. Everything else is the same shape: the same five bank passes, the same
; read-block-ids-then-expand-in-place trick.
;
; MAP_SCROLL_RIGHT takes camera X + $A0, the column just off the right of the
; screen; otherwise camera X - 1, the column just off the left.
;
; The differences from the row loader are all bookkeeping:
;   * it stages into wCF40_BgMap_TempScratchColumnTileIds and
;     wCFC0_BgMap_TempScratchColumnAttributes, which is what the `OR $40` in
;     wDC26_BgMap_ScratchColumnOffset selects
;   * the tilemap address goes to wDC23_BgMap_ColumnWritePosLo/Hi, and stepping
;     down a row means adding $20 and clearing bit 2 of the high byte to stay
;     inside the tilemap
;   * the half-of-block selector is (camera X AND 8) ? 1 : 0 rather than 2 or 0,
;     because within a block the two tile ids of a row sit next to each other
;     (bytes 0 and 1) while the two of a column are two apart (bytes 0 and 2)
;
; gex2's counterpart is call_00_157a_BgMap_LoadColumnForHorizontalScroll, which
; steps a fixed $80 bytes per row because its maps are all 128 blocks wide
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:1351 $21 $f9 $db
    ld   A, [HL+]                                      ;; 00:1354 $2a
    ld   E, A                                          ;; 00:1355 $5f
    ld   A, [HL+]                                      ;; 00:1356 $2a
    ld   D, A                                          ;; 00:1357 $57                ; DE = camera X
    ld   HL, $a0                                       ;; 00:1358 $21 $a0 $00        ; column right of the screen
    ld   A, [wDC20_BgMapLoadingFlags]                                    ;; 00:135b $fa $20 $dc
    and  A, MAP_SCROLL_RIGHT                            ;; 00:135e $e6 $08
    jr   NZ, .jr_00_1365                               ;; 00:1360 $20 $03
    ld   HL, rIE                                       ;; 00:1362 $21 $ff $ff        ; = -1, the column left of the screen
.jr_00_1365:
    add  HL, DE                                        ;; 00:1365 $19
    ld   E, L                                          ;; 00:1366 $5d
    ld   D, H                                          ;; 00:1367 $54
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1368 $21 $fb $db
    ld   C, [HL]                                       ;; 00:136b $4e
    inc  HL                                            ;; 00:136c $23
    ld   B, [HL]                                       ;; 00:136d $46
    call call_00_14e2_BgMap_SetScrollBlockCoords                                  ;; 00:136e $cd $e2 $14
    ld   A, C                                          ;; 00:1371 $79
    and  A, $f0                                        ;; 00:1372 $e6 $f0
    ld   L, A                                          ;; 00:1374 $6f
    swap A                                             ;; 00:1375 $cb $37
    add  A, A                                          ;; 00:1377 $87
    or   A, $40                                        ;; 00:1378 $f6 $40
    ld   [wDC26_BgMap_ScratchColumnOffset], A                                    ;; 00:137a $ea $26 $dc
    ld   H, $00                                        ;; 00:137d $26 $00
    add  HL, HL                                        ;; 00:137f $29
    add  HL, HL                                        ;; 00:1380 $29
    ld   A, E                                          ;; 00:1381 $7b
    rrca                                               ;; 00:1382 $0f
    rrca                                               ;; 00:1383 $0f
    rrca                                               ;; 00:1384 $0f
    and  A, $1f                                        ;; 00:1385 $e6 $1f
    or   A, L                                          ;; 00:1387 $b5
    ld   [wDC23_BgMap_ColumnWritePosLo], A                                    ;; 00:1388 $ea $23 $dc
    ld   A, H                                          ;; 00:138b $7c
    or   A, $98                                        ;; 00:138c $f6 $98
    ld   [wDC24_BgMap_ColumnWritePosHi], A                                    ;; 00:138e $ea $24 $dc
    ld   A, E                                          ;; 00:1391 $7b
    rrca                                               ;; 00:1392 $0f
    rrca                                               ;; 00:1393 $0f
    rrca                                               ;; 00:1394 $0f
    and  A, $01                                        ;; 00:1395 $e6 $01
    ld   E, A                                          ;; 00:1397 $5f
    ld   D, $00                                        ;; 00:1398 $16 $00
    push DE                                            ;; 00:139a $d5                ; E = (camera X AND 8) ? 1 : 0
    push DE                                            ;; 00:139b $d5                ; popped again by passes 4 and 5
    ; --- pass 1: block id low bytes from the map, one map row apart ---
    ld   A, [wDC01_MapBank]                                    ;; 00:139c $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:139f $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:13a2 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:13a5 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:13a6 $26 $cd
    ld   E, [HL]                                       ;; 00:13a8 $5e
    inc  H                                             ;; 00:13a9 $24
    ld   D, [HL]                                       ;; 00:13aa $56
    ld   HL, wDC02_MapBankOffset                                     ;; 00:13ab $21 $02 $dc
    ld   A, [HL+]                                      ;; 00:13ae $2a
    add  A, E                                          ;; 00:13af $83
    ld   E, A                                          ;; 00:13b0 $5f
    ld   A, [HL]                                       ;; 00:13b1 $7e
    adc  A, D                                          ;; 00:13b2 $8a
    ld   D, A                                          ;; 00:13b3 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:13b4 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:13b7 $6e
    ld   H, $00                                        ;; 00:13b8 $26 $00
    add  HL, DE                                        ;; 00:13ba $19
    push HL                                            ;; 00:13bb $e5
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:13bc $21 $1c $dc
    ld   C, [HL]                                       ;; 00:13bf $4e
    ld   B, $00                                        ;; 00:13c0 $06 $00
    ld   HL, wDC26_BgMap_ScratchColumnOffset                                     ;; 00:13c2 $21 $26 $dc
    ld   E, [HL]                                       ;; 00:13c5 $5e
    ld   D, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:13c6 $16 $cf
    pop  HL                                            ;; 00:13c8 $e1
    ld   A, $0b                                        ;; 00:13c9 $3e $0b
.jr_00_13cb:
    push AF                                            ;; 00:13cb $f5
    ld   A, [HL]                                       ;; 00:13cc $7e
    ld   [DE], A                                       ;; 00:13cd $12
    inc  E                                             ;; 00:13ce $1c
    inc  E                                             ;; 00:13cf $1c
    res  5, E                                          ;; 00:13d0 $cb $ab
    add  HL, BC                                        ;; 00:13d2 $09
    pop  AF                                            ;; 00:13d3 $f1
    dec  A                                             ;; 00:13d4 $3d
    jr   NZ, .jr_00_13cb                               ;; 00:13d5 $20 $f4
    call call_00_0f08_RestoreBank                                  ;; 00:13d7 $cd $08 $0f
    ; --- pass 2: block id high bytes from the extended map, interleaved ---
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:13da $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:13dd $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:13e0 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:13e3 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:13e4 $26 $cd
    ld   E, [HL]                                       ;; 00:13e6 $5e
    inc  H                                             ;; 00:13e7 $24
    ld   D, [HL]                                       ;; 00:13e8 $56
    ld   HL, wDC05_MapExtendedBankOffset                                     ;; 00:13e9 $21 $05 $dc
    ld   A, [HL+]                                      ;; 00:13ec $2a
    add  A, E                                          ;; 00:13ed $83
    ld   E, A                                          ;; 00:13ee $5f
    ld   A, [HL]                                       ;; 00:13ef $7e
    adc  A, D                                          ;; 00:13f0 $8a
    ld   D, A                                          ;; 00:13f1 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:13f2 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:13f5 $6e
    ld   H, $00                                        ;; 00:13f6 $26 $00
    add  HL, DE                                        ;; 00:13f8 $19
    push HL                                            ;; 00:13f9 $e5
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:13fa $21 $1c $dc
    ld   C, [HL]                                       ;; 00:13fd $4e
    ld   B, $00                                        ;; 00:13fe $06 $00
    ld   HL, wDC26_BgMap_ScratchColumnOffset                                     ;; 00:1400 $21 $26 $dc
    ld   E, [HL]                                       ;; 00:1403 $5e
    inc  E                                             ;; 00:1404 $1c
    ld   D, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1405 $16 $cf
    pop  HL                                            ;; 00:1407 $e1
    ld   A, $0b                                        ;; 00:1408 $3e $0b
.jr_00_140a:
    push AF                                            ;; 00:140a $f5
    ld   A, [HL]                                       ;; 00:140b $7e
    ld   [DE], A                                       ;; 00:140c $12
    inc  E                                             ;; 00:140d $1c
    res  5, E                                          ;; 00:140e $cb $ab
    inc  E                                             ;; 00:1410 $1c
    add  HL, BC                                        ;; 00:1411 $09
    pop  AF                                            ;; 00:1412 $f1
    dec  A                                             ;; 00:1413 $3d
    jr   NZ, .jr_00_140a                               ;; 00:1414 $20 $f4
    call call_00_0f08_RestoreBank                                  ;; 00:1416 $cd $08 $0f
    ; --- pass 3: collision block ids, staged in wC000_BgMapTileIds ---
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1419 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:141c $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:141f $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1422 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:1423 $26 $cd
    ld   E, [HL]                                       ;; 00:1425 $5e
    inc  H                                             ;; 00:1426 $24
    ld   D, [HL]                                       ;; 00:1427 $56
    ld   HL, wDC0E_MapCollisionBankOffset                                     ;; 00:1428 $21 $0e $dc
    ld   A, [HL+]                                      ;; 00:142b $2a
    add  A, E                                          ;; 00:142c $83
    ld   E, A                                          ;; 00:142d $5f
    ld   A, [HL]                                       ;; 00:142e $7e
    adc  A, D                                          ;; 00:142f $8a
    ld   D, A                                          ;; 00:1430 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:1431 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1434 $6e
    ld   H, $00                                        ;; 00:1435 $26 $00
    add  HL, DE                                        ;; 00:1437 $19
    ld   E, L                                          ;; 00:1438 $5d
    ld   D, H                                          ;; 00:1439 $54
    ld   BC, $40                                       ;; 00:143a $01 $40 $00
    ld   HL, wDC24_BgMap_ColumnWritePosHi                                     ;; 00:143d $21 $24 $dc
    ld   A, [HL-]                                      ;; 00:1440 $3a
    ld   L, [HL]                                       ;; 00:1441 $6e
    and  A, $03                                        ;; 00:1442 $e6 $03
    add  A, $c0                                        ;; 00:1444 $c6 $c0
    ld   H, A                                          ;; 00:1446 $67
    ld   A, $0b                                        ;; 00:1447 $3e $0b
.jr_00_1449:
    push AF                                            ;; 00:1449 $f5
    ld   A, [DE]                                       ;; 00:144a $1a
    ld   [HL], A                                       ;; 00:144b $77
    ld   A, [wDC1C_CurrentMapWidthAndHeightInBlocks]                                    ;; 00:144c $fa $1c $dc
    add  A, E                                          ;; 00:144f $83
    ld   E, A                                          ;; 00:1450 $5f
    ld   A, $00                                        ;; 00:1451 $3e $00
    adc  A, D                                          ;; 00:1453 $8a
    ld   D, A                                          ;; 00:1454 $57
    add  HL, BC                                        ;; 00:1455 $09
    res  2, H                                          ;; 00:1456 $cb $94
    pop  AF                                            ;; 00:1458 $f1
    dec  A                                             ;; 00:1459 $3d
    jr   NZ, .jr_00_1449                               ;; 00:145a $20 $ed
    call call_00_0f08_RestoreBank                                  ;; 00:145c $cd $08 $0f
    ; --- pass 4: expand each block id into 2 tile ids + 2 attribute bytes ---
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:145f $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1462 $cd $ee $0e
    ld   HL, wDC26_BgMap_ScratchColumnOffset                                     ;; 00:1465 $21 $26 $dc
    ld   E, [HL]                                       ;; 00:1468 $5e
    ld   D, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1469 $16 $cf
    pop  BC                                            ;; 00:146b $c1
    ld   A, [wDC0B_BlocksetBankOffset]                                    ;; 00:146c $fa $0b $dc
    add  A, C                                          ;; 00:146f $81
    ld   C, A                                          ;; 00:1470 $4f
    ld   A, [wDC0B_BlocksetBankOffset+1]                                    ;; 00:1471 $fa $0c $dc
    adc  A, B                                          ;; 00:1474 $88
    ld   B, A                                          ;; 00:1475 $47
    ld   A, $0b                                        ;; 00:1476 $3e $0b
.jr_00_1478:
    push AF                                            ;; 00:1478 $f5
    ld   A, [DE]                                       ;; 00:1479 $1a
    ld   L, A                                          ;; 00:147a $6f
    inc  E                                             ;; 00:147b $1c
    ld   A, [DE]                                       ;; 00:147c $1a
    ld   H, A                                          ;; 00:147d $67
    dec  E                                             ;; 00:147e $1d
    add  HL, HL                                        ;; 00:147f $29
    add  HL, HL                                        ;; 00:1480 $29
    add  HL, HL                                        ;; 00:1481 $29
    add  HL, BC                                        ;; 00:1482 $09
    ld   A, [HL+]                                      ;; 00:1483 $2a
    ld   [DE], A                                       ;; 00:1484 $12
    inc  HL                                            ;; 00:1485 $23
    inc  E                                             ;; 00:1486 $1c
    ld   A, [HL+]                                      ;; 00:1487 $2a
    ld   [DE], A                                       ;; 00:1488 $12
    dec  E                                             ;; 00:1489 $1d
    set  7, E                                          ;; 00:148a $cb $fb
    inc  HL                                            ;; 00:148c $23
    ld   A, [HL+]                                      ;; 00:148d $2a
    ld   [DE], A                                       ;; 00:148e $12
    inc  HL                                            ;; 00:148f $23
    inc  E                                             ;; 00:1490 $1c
    ld   A, [HL+]                                      ;; 00:1491 $2a
    ld   [DE], A                                       ;; 00:1492 $12
    res  7, E                                          ;; 00:1493 $cb $bb
    inc  E                                             ;; 00:1495 $1c
    res  5, E                                          ;; 00:1496 $cb $ab
    pop  AF                                            ;; 00:1498 $f1
    dec  A                                             ;; 00:1499 $3d
    jr   NZ, .jr_00_1478                               ;; 00:149a $20 $dc
    call call_00_0f08_RestoreBank                                  ;; 00:149c $cd $08 $0f
    ; --- pass 5: expand each collision block id into 2 collision tile ids ---
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:149f $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:14a2 $cd $ee $0e
    ld   HL, wDC24_BgMap_ColumnWritePosHi                                     ;; 00:14a5 $21 $24 $dc
    ld   A, [HL-]                                      ;; 00:14a8 $3a
    ld   E, [HL]                                       ;; 00:14a9 $5e
    and  A, $03                                        ;; 00:14aa $e6 $03
    add  A, $c0                                        ;; 00:14ac $c6 $c0
    ld   D, A                                          ;; 00:14ae $57
    pop  BC                                            ;; 00:14af $c1
    ld   A, [wDC11_CollisionBlocksetOffset]                                    ;; 00:14b0 $fa $11 $dc
    add  A, C                                          ;; 00:14b3 $81
    ld   C, A                                          ;; 00:14b4 $4f
    ld   A, [wDC11_CollisionBlocksetOffset+1]                                    ;; 00:14b5 $fa $12 $dc
    adc  A, B                                          ;; 00:14b8 $88
    ld   B, A                                          ;; 00:14b9 $47
    ld   A, $0b                                        ;; 00:14ba $3e $0b
.jr_00_14bc:
    push AF                                            ;; 00:14bc $f5
    ld   A, [DE]                                       ;; 00:14bd $1a
    ld   L, A                                          ;; 00:14be $6f
    ld   H, $00                                        ;; 00:14bf $26 $00
    add  HL, HL                                        ;; 00:14c1 $29
    add  HL, HL                                        ;; 00:14c2 $29
    add  HL, BC                                        ;; 00:14c3 $09
    ld   A, [HL+]                                      ;; 00:14c4 $2a
    ld   [DE], A                                       ;; 00:14c5 $12
    ld   A, E                                          ;; 00:14c6 $7b
    add  A, $20                                        ;; 00:14c7 $c6 $20
    ld   E, A                                          ;; 00:14c9 $5f
    ld   A, D                                          ;; 00:14ca $7a
    adc  A, $00                                        ;; 00:14cb $ce $00
    ld   D, A                                          ;; 00:14cd $57
    inc  HL                                            ;; 00:14ce $23
    ld   A, [HL]                                       ;; 00:14cf $7e
    ld   [DE], A                                       ;; 00:14d0 $12
    ld   A, E                                          ;; 00:14d1 $7b
    add  A, $20                                        ;; 00:14d2 $c6 $20
    ld   E, A                                          ;; 00:14d4 $5f
    ld   A, D                                          ;; 00:14d5 $7a
    adc  A, $00                                        ;; 00:14d6 $ce $00
    ld   D, A                                          ;; 00:14d8 $57
    res  2, D                                          ;; 00:14d9 $cb $92
    pop  AF                                            ;; 00:14db $f1
    dec  A                                             ;; 00:14dc $3d
    jr   NZ, .jr_00_14bc                               ;; 00:14dd $20 $dd
    jp   call_00_0f08_RestoreBank                                  ;; 00:14df $c3 $08 $0f

call_00_14e2_BgMap_SetScrollBlockCoords:
; Turns the pixel position of the strip about to be loaded into block
; coordinates, by shifting both 16-bit inputs right four times
; (BGMAP_BLOCK_SIZE_PX = 16) and keeping the low byte of each.
;
; Called with DE = X and BC = Y, so it writes
;   wDC27_BgMap_ScrollBlockX <- E >> 4
;   wDC28_BgMap_ScrollBlockY <- C >> 4
; and restores both pairs, because the callers still need the pixel values for
; the sub-block bits.
;
; Block Y is the index into wCD00_RowOffsetTableForMap and block X is the offset
; added to the row start, so between them these two are the address of the first
; block of the strip in all three map layers.
;
; gex2 keeps the same two values in wD779_BgMap_ScrollBlockX /
; wD77A_BgMap_ScrollBlockY, but computes them inline as (scroll * 8) >> 8, which
; is a divide by 32 - its blocks are 32x32 pixels rather than 16x16
    push BC                                            ;; 00:14e2 $c5
    push DE                                            ;; 00:14e3 $d5
    srl  B                                             ;; 00:14e4 $cb $38
    rr   C                                             ;; 00:14e6 $cb $19
    srl  B                                             ;; 00:14e8 $cb $38
    rr   C                                             ;; 00:14ea $cb $19
    srl  B                                             ;; 00:14ec $cb $38
    rr   C                                             ;; 00:14ee $cb $19
    srl  B                                             ;; 00:14f0 $cb $38
    rr   C                                             ;; 00:14f2 $cb $19
    srl  D                                             ;; 00:14f4 $cb $3a
    rr   E                                             ;; 00:14f6 $cb $1b
    srl  D                                             ;; 00:14f8 $cb $3a
    rr   E                                             ;; 00:14fa $cb $1b
    srl  D                                             ;; 00:14fc $cb $3a
    rr   E                                             ;; 00:14fe $cb $1b
    srl  D                                             ;; 00:1500 $cb $3a
    rr   E                                             ;; 00:1502 $cb $1b
    ld   A, E                                          ;; 00:1504 $7b
    ld   [wDC27_BgMap_ScrollBlockX], A                                    ;; 00:1505 $ea $27 $dc
    ld   A, C                                          ;; 00:1508 $79
    ld   [wDC28_BgMap_ScrollBlockY], A                                    ;; 00:1509 $ea $28 $dc
    pop  DE                                            ;; 00:150c $d1
    pop  BC                                            ;; 00:150d $c1
    ret                                                ;; 00:150e $c9

call_00_150f_Map_CheckEdgeTransition:
; Walking off the side of a map is how you move between the maps of a level, and
; this is the routine that turns "clamped against an edge" into a warp request.
;
; wDC8A_MapEdgeTouched carries the edge the player-position clamps in
; bank02_update_player.asm ran into. MAP_EDGE_NONE has bit 7 set, so a single
; `bit 7` rejects the common case; anything else is consumed by writing
; MAP_EDGE_NONE straight back, which is what stops the same edge firing twice.
;
; The edge then indexes .data_00_153f_MapEdgeSpawnIds at
; (map id * 4) + edge. The byte there is the spawn id to arrive at, or:
;   MAP_EDGE_SPAWN_NONE  ($FF)  that edge is a dead end, do nothing
;   MAP_EDGE_SPAWN_CONDITIONAL ($FE)  use spawn $10, but only once
;                               wDCB1_LevelTriggerBuffer[0] has been set
;
; A real spawn id goes to wDC69_PlayerSpawnIdInLevel and bit 2 of
; wDB6A_WarpFlags is raised; call_00_1633_Map_LoadWarpDestination does the rest.
;
; gex2 has nothing comparable - one gex2 level is one map, and its edges are
; simply walls
    ld   HL, wDC8A_MapEdgeTouched                                     ;; 00:150f $21 $8a $dc
    ld   E, [HL]                                       ;; 00:1512 $5e
    bit  7, E                                          ;; 00:1513 $cb $7b                ; MAP_EDGE_NONE?
    ret  NZ                                            ;; 00:1515 $c0
    ld   [HL], MAP_EDGE_NONE                           ;; 00:1516 $36 $ff                ; consume it
    ld   D, $00                                        ;; 00:1518 $16 $00
    ld   HL, wDB6C_CurrentMapId                                     ;; 00:151a $21 $6c $db
    ld   L, [HL]                                       ;; 00:151d $6e
    ld   H, $00                                        ;; 00:151e $26 $00
    add  HL, HL                                        ;; 00:1520 $29
    add  HL, HL                                        ;; 00:1521 $29                ; map id * 4 edges
    add  HL, DE                                        ;; 00:1522 $19                ; + which edge
    ld   DE, .data_00_153f_MapEdgeSpawnIds                                     ;; 00:1523 $11 $3f $15
    add  HL, DE                                        ;; 00:1526 $19
    ld   A, [HL]                                       ;; 00:1527 $7e
    cp   A, MAP_EDGE_SPAWN_NONE                        ;; 00:1528 $fe $ff
    ret  Z                                             ;; 00:152a $c8
    cp   A, MAP_EDGE_SPAWN_CONDITIONAL                 ;; 00:152b $fe $fe
    jr   NZ, .jr_00_1536                               ;; 00:152d $20 $07
    ld   A, [wDCB1_LevelTriggerBuffer]                                    ;; 00:152f $fa $b1 $dc
    and  A, A                                          ;; 00:1532 $a7
    ret  Z                                             ;; 00:1533 $c8                ; trigger not set, edge stays closed
    ld   A, $10                                        ;; 00:1534 $3e $10
.jr_00_1536:
    ld   [wDC69_PlayerSpawnIdInLevel], A                                    ;; 00:1536 $ea $69 $dc
    ld   HL, wDB6A_WarpFlags                                     ;; 00:1539 $21 $6a $db
    set  2, [HL]                                       ;; 00:153c $cb $d6                ; request the warp
    ret                                                ;; 00:153e $c9
.data_00_153f_MapEdgeSpawnIds:
; 61 maps x 4 bytes, one byte per edge in MAP_EDGE_TOP, MAP_EDGE_BOTTOM,
; MAP_EDGE_LEFT, MAP_EDGE_RIGHT order. Each byte is the spawn id the player
; arrives at when leaving by that edge, or MAP_EDGE_SPAWN_NONE /
; MAP_EDGE_SPAWN_CONDITIONAL. Rows run MAP_GEX_CAVE1 ($00) through
; MAP_CHANNEL_Z5 ($3C); two rows are listed per line below
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_GEX_CAVE1 / MAP_HOLIDAY_TV1
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00        ; MAP_MYSTERY_TV1 / MAP_TUT_TV1
    db   $ff, $ff, $ff, $0a, $ff, $ff, $ff, $ff        ; MAP_WESTERN_STATION1 / MAP_ANIME_CHANNEL1
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_SUPERHERO_SHOW1 / MAP_GEXTREME_SPORTS1
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_MARSUPIAL_MADNESS1 / MAP_WW_GEX_WRESTLING1
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_LIZARD_OF_OZ1 / MAP_CHANNEL_Z1
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_GEX_CAVE2 / MAP_GEX_CAVE3
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_GEX_CAVE4 / MAP_HOLIDAY_TV2
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $05        ; MAP_HOLIDAY_TV3 / MAP_HOLIDAY_TV4
    db   $08, $06, $07, $12, $ff, $ff, $ff, $ff        ; MAP_MYSTERY_TV2 / MAP_MYSTERY_TV3
    db   $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_MYSTERY_TV4 / MAP_MYSTERY_TV5
    db   $ff, $ff, $ff, $ff, $fe, $0f, $ff, $ff        ; MAP_MYSTERY_TV6 / MAP_MYSTERY_TV7
    db   $ff, $11, $ff, $ff, $ff, $15, $ff, $ff        ; MAP_MYSTERY_TV8 / MAP_MYSTERY_TV9
    db   $ff, $ff, $13, $ff, $ff, $02, $05, $03        ; MAP_MYSTERY_TV10 / MAP_TUT_TV2
    db   $ff, $ff, $04, $09, $06, $ff, $ff, $ff        ; MAP_TUT_TV3 / MAP_TUT_TV4
    db   $ff, $ff, $08, $ff, $ff, $ff, $0a, $ff        ; MAP_TUT_TV5 / MAP_TUT_TV6
    db   $ff, $ff, $0c, $ff, $ff, $ff, $0b, $ff        ; MAP_TUT_TV7 / MAP_WESTERN_STATION2
    db   $ff, $0e, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_WESTERN_STATION3 / MAP_WESTERN_STATION4
    db   $ff, $ff, $0d, $ff, $10, $ff, $ff, $0c        ; MAP_WESTERN_STATION5 / MAP_WESTERN_STATION6
    db   $ff, $ff, $ff, $ff, $ff, $0f, $ff, $ff        ; MAP_WESTERN_STATION7 / MAP_WESTERN_STATION8
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_WESTERN_STATION9 / MAP_ANIME_CHANNEL2
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_ANIME_CHANNEL3 / MAP_ANIME_CHANNEL4
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_ANIME_CHANNEL5 / MAP_ANIME_CHANNEL6
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_ANIME_CHANNEL7 / MAP_ANIME_CHANNEL8
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_ANIME_CHANNEL9 / MAP_SUPERHERO_SHOW2
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_SUPERHERO_SHOW3 / MAP_SUPERHERO_SHOW4
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_SUPERHERO_SHOW5 / MAP_SUPERHERO_SHOW6
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_GEXTREME_SPORTS2 / MAP_GEXTREME_SPORTS3
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_GEXTREME_SPORTS4 / MAP_CHANNEL_Z2
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ; MAP_CHANNEL_Z3 / MAP_CHANNEL_Z4
    db   $ff, $ff, $ff, $ff                            ; MAP_CHANNEL_Z5

call_00_1633_Map_LoadWarpDestination:
; Resolves the pending warp: takes wDC69_PlayerSpawnIdInLevel - set by
; call_00_150f_Map_CheckEdgeTransition or call_00_1bbc_CheckForDoorAndEnter -
; and produces the map and position to arrive at.
;
; wDC1E_CurrentLevelID picks one of the twelve tables in
; .data_00_16a2_LevelSpawnTables, and the spawn id indexes it in
; MAP_SPAWN_ENTRY_SIZE steps. A record is:
;   +0  db  destination map id
;   +1  dw  destination X
;   +3  dw  destination Y
;   +5  db  linked spawn id, or MAP_SPAWN_LINK_ABSOLUTE
;   +6      2 spare bytes
;
; With MAP_SPAWN_LINK_ABSOLUTE the record is taken literally: map id and both
; coordinates are copied straight out.
;
; Otherwise byte +5 names another spawn in the same table, and the arrival Y
; becomes relative: the player's current Y minus that linked spawn's Y, added to
; this record's Y. That is what makes walking off the side of a map continuous -
; the linked record marks the same doorway from the other map, so the player
; comes out at the height they left at rather than snapping to a fixed point.
; The result is finally floored at $10 so a negative or too-small Y cannot push
; the player through the top of the destination map
    ld   HL, wDC1E_CurrentLevelID                                     ;; 00:1633 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1636 $6e
    ld   H, $00                                        ;; 00:1637 $26 $00
    add  HL, HL                                        ;; 00:1639 $29
    ld   DE, .data_00_16a2_LevelSpawnTables                             ;; 00:163a $11 $a2 $16
    add  HL, DE                                        ;; 00:163d $19
    ld   A, [HL+]                                      ;; 00:163e $2a
    ld   D, [HL]                                       ;; 00:163f $56
    ld   E, A                                          ;; 00:1640 $5f                ; DE = this level's spawn table
    ld   HL, wDC69_PlayerSpawnIdInLevel                                     ;; 00:1641 $21 $69 $dc
    ld   L, [HL]                                       ;; 00:1644 $6e
    ld   H, $00                                        ;; 00:1645 $26 $00
    add  HL, HL                                        ;; 00:1647 $29
    add  HL, HL                                        ;; 00:1648 $29
    add  HL, HL                                        ;; 00:1649 $29                ; * MAP_SPAWN_ENTRY_SIZE
    add  HL, DE                                        ;; 00:164a $19
    push HL                                            ;; 00:164b $e5
    ld   BC, $05                                       ;; 00:164c $01 $05 $00
    add  HL, BC                                        ;; 00:164f $09                ; +5, the linked spawn id
    ld   A, [HL]                                       ;; 00:1650 $7e
    cp   A, MAP_SPAWN_LINK_ABSOLUTE                    ;; 00:1651 $fe $ff
    jr   NZ, .jr_00_1663                               ;; 00:1653 $20 $0e
    pop  HL                                            ;; 00:1655 $e1
    ld   A, [HL+]                                      ;; 00:1656 $2a
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:1657 $ea $6c $db
    ld   DE, wDC6A_CheckpointStoredX                                     ;; 00:165a $11 $6a $dc
    ld   BC, $04                                       ;; 00:165d $01 $04 $00
    jp   call_00_076e_MemCopy                                  ;; 00:1660 $c3 $6e $07
.jr_00_1663:
    ld   L, A                                          ;; 00:1663 $6f
    ld   H, $00                                        ;; 00:1664 $26 $00
    add  HL, HL                                        ;; 00:1666 $29
    add  HL, HL                                        ;; 00:1667 $29
    add  HL, HL                                        ;; 00:1668 $29
    add  HL, DE                                        ;; 00:1669 $19
    ld   DE, $03                                       ;; 00:166a $11 $03 $00
    add  HL, DE                                        ;; 00:166d $19
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:166e $fa $10 $d8
    sub  A, [HL]                                       ;; 00:1671 $96
    ld   E, A                                          ;; 00:1672 $5f
    inc  HL                                            ;; 00:1673 $23
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:1674 $fa $11 $d8
    sbc  A, [HL]                                       ;; 00:1677 $9e
    ld   D, A                                          ;; 00:1678 $57
    pop  HL                                            ;; 00:1679 $e1
    ld   A, [HL+]                                      ;; 00:167a $2a
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:167b $ea $6c $db
    ld   A, [HL+]                                      ;; 00:167e $2a
    ld   [wDC6A_CheckpointStoredX], A                                    ;; 00:167f $ea $6a $dc
    ld   A, [HL+]                                      ;; 00:1682 $2a
    ld   [wDC6A_CheckpointStoredX+1], A                                    ;; 00:1683 $ea $6b $dc
    ld   A, [HL+]                                      ;; 00:1686 $2a
    add  A, E                                          ;; 00:1687 $83
    ld   E, A                                          ;; 00:1688 $5f
    ld   A, [HL]                                       ;; 00:1689 $7e
    adc  A, D                                          ;; 00:168a $8a
    ld   D, A                                          ;; 00:168b $57
    bit  7, A                                          ;; 00:168c $cb $7f
    jr   NZ, .jr_00_1698                               ;; 00:168e $20 $08
    ld   A, E                                          ;; 00:1690 $7b
    sub  A, $10                                        ;; 00:1691 $d6 $10
    ld   A, D                                          ;; 00:1693 $7a
    sbc  A, $00                                        ;; 00:1694 $de $00
    jr   NC, .jr_00_169b                               ;; 00:1696 $30 $03
.jr_00_1698:
    ld   DE, $10                                       ;; 00:1698 $11 $10 $00        ; floor: never arrive above y=$10
.jr_00_169b:
    ld   HL, wDC6C_CheckpointStoredY                                     ;; 00:169b $21 $6c $dc
    ld   [HL], E                                       ;; 00:169e $73
    inc  HL                                            ;; 00:169f $23
    ld   [HL], D                                       ;; 00:16a0 $72
    ret                                                ;; 00:16a1 $c9
.data_00_16a2_LevelSpawnTables:
; One pointer per level to that level's list of spawn points. Each entry of a
; list is MAP_SPAWN_ENTRY_SIZE bytes:
;   +0  db  destination map id
;   +1  dw  destination X
;   +3  dw  destination Y
;   +5  db  linked spawn id, or MAP_SPAWN_LINK_ABSOLUTE for a fixed position
;   +6      2 spare bytes
; The three bonus/boss levels that are a single map each share one empty stub
    dw   .spawns_gex_cave                              ; LEVEL_GEX_CAVE
    dw   .spawns_holiday_tv                            ; LEVEL_HOLIDAY_TV
    dw   .spawns_mystery_tv                            ; LEVEL_MYSTERY_TV
    dw   .spawns_tut_tv                                ; LEVEL_TUT_TV
    dw   .spawns_western_station                       ; LEVEL_WESTERN_STATION
    dw   .spawns_anime_channel                         ; LEVEL_ANIME_CHANNEL
    dw   .spawns_superhero_show                        ; LEVEL_SUPERHERO_SHOW
    dw   .spawns_gextreme_sports                       ; LEVEL_GEXTREME_SPORTS
    dw   .spawns_none                                  ; LEVEL_MARSUPIAL_MADNESS - single map
    dw   .spawns_none                                  ; LEVEL_WW_GEX_WRESTLING - single map
    dw   .spawns_none                                  ; LEVEL_LIZARD_OF_OZ - single map
    dw   .spawns_channel_z                             ; LEVEL_CHANNEL_Z
.spawns_none:
; Shared empty stub for the levels that are one map and never warp
    db   $00, $00, $00, $00, $00, $00, $00, $00   ; never read
.spawns_gex_cave:
    db   $00, $b0, $01, $f0, $00, $ff, $00, $00   ; spawn $00: MAP_GEX_CAVE1 at $01b0,$00f0, absolute
    db   $00, $50, $00, $70, $00, $ff, $00, $00   ; spawn $01: MAP_GEX_CAVE1 at $0050,$0070, absolute
    db   $00, $50, $01, $40, $00, $ff, $00, $00   ; spawn $02: MAP_GEX_CAVE1 at $0150,$0040, absolute
    db   $0c, $f0, $00, $80, $00, $ff, $00, $00   ; spawn $03: MAP_GEX_CAVE2 at $00f0,$0080, absolute
    db   $0d, $f0, $00, $f0, $00, $ff, $00, $00   ; spawn $04: MAP_GEX_CAVE3 at $00f0,$00f0, absolute
    db   $0e, $30, $00, $30, $00, $ff, $00, $00   ; spawn $05: MAP_GEX_CAVE4 at $0030,$0030, absolute
.spawns_holiday_tv:
    db   $0f, $20, $01, $80, $00, $ff, $00, $00   ; spawn $00: MAP_HOLIDAY_TV2 at $0120,$0080, absolute
    db   $10, $20, $00, $30, $01, $ff, $00, $00   ; spawn $01: MAP_HOLIDAY_TV3 at $0020,$0130, absolute
    db   $11, $30, $01, $60, $00, $ff, $00, $00   ; spawn $02: MAP_HOLIDAY_TV4 at $0130,$0060, absolute
    db   $01, $60, $09, $00, $04, $ff, $00, $00   ; spawn $03: MAP_HOLIDAY_TV1 at $0960,$0400, absolute
    db   $01, $a0, $07, $00, $01, $ff, $00, $00   ; spawn $04: MAP_HOLIDAY_TV1 at $07a0,$0100, absolute
    db   $01, $c8, $02, $80, $00, $ff, $00, $00   ; spawn $05: MAP_HOLIDAY_TV1 at $02c8,$0080, absolute
.spawns_mystery_tv:
    db   $12, $c0, $00, $60, $02, $ff, $00, $00   ; spawn $00: MAP_MYSTERY_TV2 at $00c0,$0260, absolute
    db   $14, $20, $00, $80, $00, $ff, $00, $00   ; spawn $01: MAP_MYSTERY_TV4 at $0020,$0080, absolute
    db   $15, $20, $01, $30, $01, $ff, $00, $00   ; spawn $02: MAP_MYSTERY_TV5 at $0120,$0130, absolute
    db   $16, $20, $00, $e0, $01, $ff, $00, $00   ; spawn $03: MAP_MYSTERY_TV6 at $0020,$01e0, absolute
    db   $16, $20, $01, $e0, $01, $ff, $00, $00   ; spawn $04: MAP_MYSTERY_TV6 at $0120,$01e0, absolute
    db   $17, $48, $00, $60, $00, $ff, $00, $00   ; spawn $05: MAP_MYSTERY_TV7 at $0048,$0060, absolute
    db   $02, $98, $02, $b0, $02, $ff, $00, $00   ; spawn $06: MAP_MYSTERY_TV1 at $0298,$02b0, absolute
    db   $13, $18, $00, $68, $00, $ff, $00, $00   ; spawn $07: MAP_MYSTERY_TV3 at $0018,$0068, absolute
    db   $13, $b8, $02, $68, $00, $ff, $00, $00   ; spawn $08: MAP_MYSTERY_TV3 at $02b8,$0068, absolute
    db   $12, $10, $00, $cc, $00, $ff, $00, $00   ; spawn $09: MAP_MYSTERY_TV2 at $0010,$00cc, absolute
    db   $12, $38, $02, $10, $00, $ff, $00, $00   ; spawn $0a: MAP_MYSTERY_TV2 at $0238,$0010, absolute
    db   $02, $28, $02, $b0, $02, $ff, $00, $00   ; spawn $0b: MAP_MYSTERY_TV1 at $0228,$02b0, absolute
    db   $02, $68, $02, $d0, $01, $ff, $00, $00   ; spawn $0c: MAP_MYSTERY_TV1 at $0268,$01d0, absolute
    db   $02, $d8, $00, $40, $01, $ff, $00, $00   ; spawn $0d: MAP_MYSTERY_TV1 at $00d8,$0140, absolute
    db   $02, $f8, $01, $80, $00, $ff, $00, $00   ; spawn $0e: MAP_MYSTERY_TV1 at $01f8,$0080, absolute
    db   $02, $28, $00, $50, $00, $ff, $00, $00   ; spawn $0f: MAP_MYSTERY_TV1 at $0028,$0050, absolute
    db   $18, $50, $00, $70, $00, $ff, $00, $00   ; spawn $10: MAP_MYSTERY_TV8 at $0050,$0070, absolute
    db   $17, $50, $00, $10, $00, $ff, $00, $00   ; spawn $11: MAP_MYSTERY_TV7 at $0050,$0010, absolute
    db   $1a, $10, $00, $d8, $02, $ff, $00, $00   ; spawn $12: MAP_MYSTERY_TV10 at $0010,$02d8, absolute
    db   $12, $70, $02, $2c, $02, $ff, $00, $00   ; spawn $13: MAP_MYSTERY_TV2 at $0270,$022c, absolute
    db   $19, $a0, $00, $80, $02, $ff, $00, $00   ; spawn $14: MAP_MYSTERY_TV9 at $00a0,$0280, absolute
    db   $14, $a0, $00, $10, $00, $ff, $00, $00   ; spawn $15: MAP_MYSTERY_TV4 at $00a0,$0010, absolute
    db   $02, $08, $01, $50, $02, $ff, $00, $00   ; spawn $16: MAP_MYSTERY_TV1 at $0108,$0250, absolute
    db   $02, $a8, $02, $d0, $01, $ff, $00, $00   ; spawn $17: MAP_MYSTERY_TV1 at $02a8,$01d0, absolute
.spawns_tut_tv:
    db   $1b, $10, $00, $00, $03, $05, $00, $00   ; spawn $00: MAP_TUT_TV2 at $0010,$0300, linked to spawn $05
    db   $1d, $54, $04, $10, $00, $ff, $00, $00   ; spawn $01: MAP_TUT_TV4 at $0454,$0010, absolute
    db   $1d, $54, $04, $10, $00, $ff, $00, $00   ; spawn $02: MAP_TUT_TV4 at $0454,$0010, absolute
    db   $1c, $10, $00, $40, $01, $04, $00, $00   ; spawn $03: MAP_TUT_TV3 at $0010,$0140, linked to spawn $04
    db   $1b, $30, $03, $00, $03, $03, $00, $00   ; spawn $04: MAP_TUT_TV2 at $0330,$0300, linked to spawn $03
    db   $03, $60, $02, $d0, $00, $00, $00, $00   ; spawn $05: MAP_TUT_TV1 at $0260,$00d0, linked to spawn $00
    db   $03, $48, $00, $10, $01, $ff, $00, $00   ; spawn $06: MAP_TUT_TV1 at $0048,$0110, absolute
    db   $1e, $10, $00, $78, $00, $ff, $00, $00   ; spawn $07: MAP_TUT_TV5 at $0010,$0078, absolute
    db   $1b, $ec, $00, $60, $02, $ff, $00, $00   ; spawn $08: MAP_TUT_TV2 at $00ec,$0260, absolute
    db   $1f, $08, $00, $70, $00, $0a, $00, $00   ; spawn $09: MAP_TUT_TV6 at $0008,$0070, linked to spawn $0a
    db   $1c, $30, $06, $40, $01, $09, $00, $00   ; spawn $0a: MAP_TUT_TV3 at $0630,$0140, linked to spawn $09
    db   $20, $10, $00, $60, $01, $ff, $00, $00   ; spawn $0b: MAP_TUT_TV7 at $0010,$0160, absolute
    db   $1b, $7c, $02, $60, $02, $ff, $00, $00   ; spawn $0c: MAP_TUT_TV2 at $027c,$0260, absolute
.spawns_western_station:
    db   $23, $10, $00, $70, $00, $ff, $00, $00   ; spawn $00: MAP_WESTERN_STATION4 at $0010,$0070, absolute
    db   $04, $c0, $00, $50, $01, $ff, $00, $00   ; spawn $01: MAP_WESTERN_STATION1 at $00c0,$0150, absolute
    db   $26, $10, $00, $70, $00, $ff, $00, $00   ; spawn $02: MAP_WESTERN_STATION7 at $0010,$0070, absolute
    db   $04, $10, $01, $50, $01, $ff, $00, $00   ; spawn $03: MAP_WESTERN_STATION1 at $0110,$0150, absolute
    db   $27, $10, $00, $00, $01, $ff, $00, $00   ; spawn $04: MAP_WESTERN_STATION8 at $0010,$0100, absolute
    db   $04, $98, $01, $a0, $00, $ff, $00, $00   ; spawn $05: MAP_WESTERN_STATION1 at $0198,$00a0, absolute
    db   $28, $10, $00, $70, $00, $ff, $00, $00   ; spawn $06: MAP_WESTERN_STATION9 at $0010,$0070, absolute
    db   $04, $f0, $01, $50, $01, $ff, $00, $00   ; spawn $07: MAP_WESTERN_STATION1 at $01f0,$0150, absolute
    db   $22, $30, $01, $90, $00, $ff, $00, $00   ; spawn $08: MAP_WESTERN_STATION3 at $0130,$0090, absolute
    db   $21, $aa, $01, $98, $00, $ff, $00, $00   ; spawn $09: MAP_WESTERN_STATION2 at $01aa,$0098, absolute
    db   $21, $10, $00, $40, $01, $0b, $00, $00   ; spawn $0a: MAP_WESTERN_STATION2 at $0010,$0140, linked to spawn $0b
    db   $04, $70, $02, $50, $01, $0a, $00, $00   ; spawn $0b: MAP_WESTERN_STATION1 at $0270,$0150, linked to spawn $0a
    db   $24, $10, $00, $00, $01, $0d, $00, $00   ; spawn $0c: MAP_WESTERN_STATION5 at $0010,$0100, linked to spawn $0d
    db   $25, $c0, $07, $48, $02, $0c, $00, $00   ; spawn $0d: MAP_WESTERN_STATION6 at $07c0,$0248, linked to spawn $0c
    db   $25, $28, $00, $10, $00, $ff, $00, $00   ; spawn $0e: MAP_WESTERN_STATION6 at $0028,$0010, absolute
    db   $25, $68, $03, $10, $00, $ff, $00, $00   ; spawn $0f: MAP_WESTERN_STATION6 at $0368,$0010, absolute
    db   $27, $60, $00, $10, $01, $ff, $00, $00   ; spawn $10: MAP_WESTERN_STATION8 at $0060,$0110, absolute
.spawns_anime_channel:
    db   $2b, $30, $00, $80, $02, $ff, $00, $00   ; spawn $00: MAP_ANIME_CHANNEL4 at $0030,$0280, absolute
    db   $2c, $a0, $09, $80, $00, $ff, $00, $00   ; spawn $01: MAP_ANIME_CHANNEL5 at $09a0,$0080, absolute
    db   $29, $30, $00, $c0, $01, $ff, $00, $00   ; spawn $02: MAP_ANIME_CHANNEL2 at $0030,$01c0, absolute
    db   $05, $c0, $00, $c0, $01, $ff, $00, $00   ; spawn $03: MAP_ANIME_CHANNEL1 at $00c0,$01c0, absolute
    db   $05, $f0, $01, $c0, $01, $ff, $00, $00   ; spawn $04: MAP_ANIME_CHANNEL1 at $01f0,$01c0, absolute
    db   $05, $20, $03, $c0, $01, $ff, $00, $00   ; spawn $05: MAP_ANIME_CHANNEL1 at $0320,$01c0, absolute
    db   $29, $20, $00, $00, $01, $ff, $00, $00   ; spawn $06: MAP_ANIME_CHANNEL2 at $0020,$0100, absolute
    db   $29, $e0, $02, $00, $01, $ff, $00, $00   ; spawn $07: MAP_ANIME_CHANNEL2 at $02e0,$0100, absolute
    db   $2a, $c0, $01, $80, $00, $ff, $00, $00   ; spawn $08: MAP_ANIME_CHANNEL3 at $01c0,$0080, absolute
    db   $2a, $c0, $01, $80, $00, $ff, $00, $00   ; spawn $09: MAP_ANIME_CHANNEL3 at $01c0,$0080, absolute
    db   $2c, $e0, $03, $40, $01, $ff, $00, $00   ; spawn $0a: MAP_ANIME_CHANNEL5 at $03e0,$0140, absolute
    db   $30, $b0, $03, $40, $01, $ff, $00, $00   ; spawn $0b: MAP_ANIME_CHANNEL9 at $03b0,$0140, absolute
    db   $30, $70, $01, $a0, $00, $ff, $00, $00   ; spawn $0c: MAP_ANIME_CHANNEL9 at $0170,$00a0, absolute
    db   $30, $50, $02, $30, $00, $ff, $00, $00   ; spawn $0d: MAP_ANIME_CHANNEL9 at $0250,$0030, absolute
    db   $30, $30, $03, $a0, $00, $ff, $00, $00   ; spawn $0e: MAP_ANIME_CHANNEL9 at $0330,$00a0, absolute
    db   $2d, $a0, $01, $f0, $00, $ff, $00, $00   ; spawn $0f: MAP_ANIME_CHANNEL6 at $01a0,$00f0, absolute
    db   $2e, $f0, $00, $00, $02, $ff, $00, $00   ; spawn $10: MAP_ANIME_CHANNEL7 at $00f0,$0200, absolute
    db   $2f, $50, $00, $10, $03, $ff, $00, $00   ; spawn $11: MAP_ANIME_CHANNEL8 at $0050,$0310, absolute
.spawns_superhero_show:
    db   $31, $c0, $0b, $a0, $02, $ff, $00, $00   ; spawn $00: MAP_SUPERHERO_SHOW2 at $0bc0,$02a0, absolute
    db   $06, $70, $00, $b0, $00, $ff, $00, $00   ; spawn $01: MAP_SUPERHERO_SHOW1 at $0070,$00b0, absolute
    db   $32, $60, $00, $80, $00, $ff, $00, $00   ; spawn $02: MAP_SUPERHERO_SHOW3 at $0060,$0080, absolute
    db   $06, $70, $00, $00, $01, $ff, $00, $00   ; spawn $03: MAP_SUPERHERO_SHOW1 at $0070,$0100, absolute
    db   $33, $e0, $00, $a0, $01, $ff, $00, $00   ; spawn $04: MAP_SUPERHERO_SHOW4 at $00e0,$01a0, absolute
    db   $31, $80, $00, $20, $03, $ff, $00, $00   ; spawn $05: MAP_SUPERHERO_SHOW2 at $0080,$0320, absolute
    db   $34, $a0, $02, $c0, $01, $ff, $00, $00   ; spawn $06: MAP_SUPERHERO_SHOW5 at $02a0,$01c0, absolute
    db   $31, $40, $04, $00, $01, $ff, $00, $00   ; spawn $07: MAP_SUPERHERO_SHOW2 at $0440,$0100, absolute
    db   $35, $50, $00, $60, $00, $ff, $00, $00   ; spawn $08: MAP_SUPERHERO_SHOW6 at $0050,$0060, absolute
    db   $34, $a0, $02, $80, $00, $ff, $00, $00   ; spawn $09: MAP_SUPERHERO_SHOW5 at $02a0,$0080, absolute
.spawns_gextreme_sports:
    db   $36, $20, $00, $30, $01, $ff, $00, $00   ; spawn $00: MAP_GEXTREME_SPORTS2 at $0020,$0130, absolute
    db   $37, $20, $00, $30, $01, $ff, $00, $00   ; spawn $01: MAP_GEXTREME_SPORTS3 at $0020,$0130, absolute
    db   $38, $20, $00, $30, $01, $ff, $00, $00   ; spawn $02: MAP_GEXTREME_SPORTS4 at $0020,$0130, absolute
    db   $07, $7c, $02, $b8, $02, $ff, $00, $00   ; spawn $03: MAP_GEXTREME_SPORTS1 at $027c,$02b8, absolute
    db   $07, $fc, $01, $b8, $01, $ff, $00, $00   ; spawn $04: MAP_GEXTREME_SPORTS1 at $01fc,$01b8, absolute
    db   $07, $8c, $01, $f8, $00, $ff, $00, $00   ; spawn $05: MAP_GEXTREME_SPORTS1 at $018c,$00f8, absolute
.spawns_channel_z:
    db   $39, $00, $01, $b0, $00, $ff, $00, $00   ; spawn $00: MAP_CHANNEL_Z2 at $0100,$00b0, absolute
    db   $39, $30, $00, $f0, $00, $ff, $00, $00   ; spawn $01: MAP_CHANNEL_Z2 at $0030,$00f0, absolute
    db   $39, $c0, $01, $f0, $00, $ff, $00, $00   ; spawn $02: MAP_CHANNEL_Z2 at $01c0,$00f0, absolute
    db   $39, $00, $01, $20, $00, $ff, $00, $00   ; spawn $03: MAP_CHANNEL_Z2 at $0100,$0020, absolute
    db   $0b, $60, $02, $c0, $00, $ff, $00, $00   ; spawn $04: MAP_CHANNEL_Z1 at $0260,$00c0, absolute
    db   $3a, $38, $01, $80, $01, $ff, $00, $00   ; spawn $05: MAP_CHANNEL_Z3 at $0138,$0180, absolute
    db   $3b, $38, $01, $80, $01, $ff, $00, $00   ; spawn $06: MAP_CHANNEL_Z4 at $0138,$0180, absolute
    db   $3c, $78, $00, $68, $00, $ff, $00, $00   ; spawn $07: MAP_CHANNEL_Z5 at $0078,$0068, absolute

call_00_1a22_BgMap_LoadAllRowsForPass:
; Draws the whole visible area once, for one layer. Called three times by
; call_00_1056_BgMap_LoadFull with A = BGMAP_PASS_ATTRIBUTES, BGMAP_PASS_TILE_IDS
; and BGMAP_PASS_COLLISION; that value is parked in wDC33_BgMap_InitialLoadPass
; and read by every iteration of call_00_1a46_BgMap_LoadInitialRow.
;
; The loop simply walks the camera down the map, BGMAP_INITIAL_ROWS rows one
; tile (8 px) apart, drawing a row at each stop. $16 * 8 = $B0, so the closing
; `sub A, $b0` puts wDBFB_YPositionInMap back exactly where it started and the
; next pass can repeat the same sweep.
;
; gex2 does this inline in call_00_1264_BgMap_LoadFull, with the same 22-row
; count and the same 8-pixel step - but only once, because there is only one
; layer to draw
    ld   [wDC33_BgMap_InitialLoadPass], A                                    ;; 00:1a22 $ea $33 $dc
    ld   A, BGMAP_INITIAL_ROWS                         ;; 00:1a25 $3e $16
.jr_00_1a27:
    push AF                                            ;; 00:1a27 $f5
    call call_00_1a46_BgMap_LoadInitialRow                                  ;; 00:1a28 $cd $46 $1a
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1a2b $21 $fb $db
    ld   A, [HL]                                       ;; 00:1a2e $7e
    add  A, $08                                        ;; 00:1a2f $c6 $08
    ld   [HL+], A                                      ;; 00:1a31 $22
    ld   A, [HL]                                       ;; 00:1a32 $7e
    adc  A, $00                                        ;; 00:1a33 $ce $00
    ld   [HL], A                                       ;; 00:1a35 $77
    pop  AF                                            ;; 00:1a36 $f1
    dec  A                                             ;; 00:1a37 $3d
    jr   NZ, .jr_00_1a27                               ;; 00:1a38 $20 $ed
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1a3a $21 $fb $db
    ld   A, [HL]                                       ;; 00:1a3d $7e
    sub  A, $b0                                        ;; 00:1a3e $d6 $b0
    ld   [HL+], A                                      ;; 00:1a40 $22
    ld   A, [HL]                                       ;; 00:1a41 $7e
    sbc  A, $00                                        ;; 00:1a42 $de $00
    ld   [HL], A                                       ;; 00:1a44 $77
    ret                                                ;; 00:1a45 $c9

call_00_1a46_BgMap_LoadInitialRow:
; One row of the initial map load. Same shape as
; call_00_11e5_BgMap_LoadRowForVerticalScroll - work out the row above the
; camera, get the block coordinates, walk BGMAP_STRIP_BLOCKS blocks - but it
; writes one layer instead of all of them, and it writes into
; wC000_BgMapTileIds rather than the wCF00 scratch buffers, because these rows
; are flushed to VRAM a whole screen at a time by HDMA rather than a strip at a
; time in vblank.
;
; wDC33_BgMap_InitialLoadPass decides which layer, in two ways at once. Bit 7
; branches to the collision path at .jp_00_1b40, which reads the collision map
; and expands it through the collision blockset. The low bits are OR'd into the
; byte offset used inside each 8-byte blockset entry, on top of the
; (camera Y AND 8) ? 2 : 0 that picks the top or bottom tile row of the block -
; so BGMAP_PASS_TILE_IDS lands on bytes 0-3 and BGMAP_PASS_ATTRIBUTES on bytes
; 4-7. One loop, two layers, chosen by a single byte
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1a46 $21 $fb $db
    ld   A, [HL+]                                      ;; 00:1a49 $2a
    sub  A, $01                                        ;; 00:1a4a $d6 $01
    ld   C, A                                          ;; 00:1a4c $4f
    ld   A, [HL]                                       ;; 00:1a4d $7e
    sbc  A, $00                                        ;; 00:1a4e $de $00
    ld   B, A                                          ;; 00:1a50 $47
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:1a51 $21 $f9 $db
    ld   A, [HL+]                                      ;; 00:1a54 $2a
    ld   E, A                                          ;; 00:1a55 $5f
    ld   D, [HL]                                       ;; 00:1a56 $56
    call call_00_14e2_BgMap_SetScrollBlockCoords                                  ;; 00:1a57 $cd $e2 $14
    ld   A, C                                          ;; 00:1a5a $79
    and  A, $f8                                        ;; 00:1a5b $e6 $f8
    ld   L, A                                          ;; 00:1a5d $6f
    ld   H, $00                                        ;; 00:1a5e $26 $00
    add  HL, HL                                        ;; 00:1a60 $29
    add  HL, HL                                        ;; 00:1a61 $29
    ld   A, E                                          ;; 00:1a62 $7b
    swap A                                             ;; 00:1a63 $cb $37
    add  A, A                                          ;; 00:1a65 $87
    and  A, $1e                                        ;; 00:1a66 $e6 $1e
    ld   [wDC25_BgMap_ScratchRowOffset], A                                    ;; 00:1a68 $ea $25 $dc
    or   A, L                                          ;; 00:1a6b $b5
    ld   [wDC21_BgMap_RowWritePosLo], A                                    ;; 00:1a6c $ea $21 $dc
    ld   A, H                                          ;; 00:1a6f $7c
    or   A, $98                                        ;; 00:1a70 $f6 $98
    ld   [wDC22_BgMap_RowWritePosHi], A                                    ;; 00:1a72 $ea $22 $dc
    ld   A, C                                          ;; 00:1a75 $79
    rrca                                               ;; 00:1a76 $0f
    rrca                                               ;; 00:1a77 $0f
    and  A, $02                                        ;; 00:1a78 $e6 $02
    ld   E, A                                          ;; 00:1a7a $5f
    ld   A, [wDC33_BgMap_InitialLoadPass]                                    ;; 00:1a7b $fa $33 $dc
    and  A, $7f                                        ;; 00:1a7e $e6 $7f                ; drop the collision bit
    or   A, E                                          ;; 00:1a80 $b3                ; pass offset + top/bottom half of the block
    ld   E, A                                          ;; 00:1a81 $5f
    ld   D, $00                                        ;; 00:1a82 $16 $00
    push DE                                            ;; 00:1a84 $d5
    ld   A, [wDC33_BgMap_InitialLoadPass]                                    ;; 00:1a85 $fa $33 $dc
    bit  7, A                                          ;; 00:1a88 $cb $7f                ; BGMAP_PASS_COLLISION?
    jp   NZ, .jp_00_1b40                               ;; 00:1a8a $c2 $40 $1b
    ld   A, [wDC01_MapBank]                                    ;; 00:1a8d $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1a90 $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:1a93 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1a96 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:1a97 $26 $cd
    ld   E, [HL]                                       ;; 00:1a99 $5e
    inc  H                                             ;; 00:1a9a $24
    ld   D, [HL]                                       ;; 00:1a9b $56
    ld   HL, wDC02_MapBankOffset                                     ;; 00:1a9c $21 $02 $dc
    ld   A, [HL+]                                      ;; 00:1a9f $2a
    add  A, E                                          ;; 00:1aa0 $83
    ld   E, A                                          ;; 00:1aa1 $5f
    ld   A, [HL]                                       ;; 00:1aa2 $7e
    adc  A, D                                          ;; 00:1aa3 $8a
    ld   D, A                                          ;; 00:1aa4 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:1aa5 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1aa8 $6e
    ld   H, $00                                        ;; 00:1aa9 $26 $00
    add  HL, DE                                        ;; 00:1aab $19
    ld   E, L                                          ;; 00:1aac $5d
    ld   D, H                                          ;; 00:1aad $54
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:1aae $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1ab1 $6e
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1ab2 $26 $cf
    ld   B, $0b                                        ;; 00:1ab4 $06 $0b
.jr_00_1ab6:
    ld   A, [DE]                                       ;; 00:1ab6 $1a
    ld   [HL+], A                                      ;; 00:1ab7 $22
    inc  L                                             ;; 00:1ab8 $2c
    res  5, L                                          ;; 00:1ab9 $cb $ad
    inc  DE                                            ;; 00:1abb $13
    dec  B                                             ;; 00:1abc $05
    jr   NZ, .jr_00_1ab6                               ;; 00:1abd $20 $f7
    call call_00_0f08_RestoreBank                                  ;; 00:1abf $cd $08 $0f
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:1ac2 $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1ac5 $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:1ac8 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1acb $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:1acc $26 $cd
    ld   E, [HL]                                       ;; 00:1ace $5e
    inc  H                                             ;; 00:1acf $24
    ld   D, [HL]                                       ;; 00:1ad0 $56
    ld   HL, wDC05_MapExtendedBankOffset                                     ;; 00:1ad1 $21 $05 $dc
    ld   A, [HL+]                                      ;; 00:1ad4 $2a
    add  A, E                                          ;; 00:1ad5 $83
    ld   E, A                                          ;; 00:1ad6 $5f
    ld   A, [HL]                                       ;; 00:1ad7 $7e
    adc  A, D                                          ;; 00:1ad8 $8a
    ld   D, A                                          ;; 00:1ad9 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:1ada $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1add $6e
    ld   H, $00                                        ;; 00:1ade $26 $00
    add  HL, DE                                        ;; 00:1ae0 $19
    ld   E, L                                          ;; 00:1ae1 $5d
    ld   D, H                                          ;; 00:1ae2 $54
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:1ae3 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1ae6 $6e
    inc  L                                             ;; 00:1ae7 $2c
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1ae8 $26 $cf
    ld   B, $0b                                        ;; 00:1aea $06 $0b
.jr_00_1aec:
    ld   A, [DE]                                       ;; 00:1aec $1a
    ld   [HL+], A                                      ;; 00:1aed $22
    res  5, L                                          ;; 00:1aee $cb $ad
    inc  L                                             ;; 00:1af0 $2c
    inc  DE                                            ;; 00:1af1 $13
    dec  B                                             ;; 00:1af2 $05
    jr   NZ, .jr_00_1aec                               ;; 00:1af3 $20 $f7
    call call_00_0f08_RestoreBank                                  ;; 00:1af5 $cd $08 $0f
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:1af8 $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1afb $cd $ee $0e
    ld   HL, wDC22_BgMap_RowWritePosHi                                     ;; 00:1afe $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:1b01 $3a
    ld   C, [HL]                                       ;; 00:1b02 $4e
    and  A, $03                                        ;; 00:1b03 $e6 $03
    add  A, $c0                                        ;; 00:1b05 $c6 $c0
    ld   B, A                                          ;; 00:1b07 $47
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:1b08 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1b0b $6e
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1b0c $26 $cf
    pop  DE                                            ;; 00:1b0e $d1
    ld   A, [wDC0B_BlocksetBankOffset]                                    ;; 00:1b0f $fa $0b $dc
    add  A, E                                          ;; 00:1b12 $83
    ld   E, A                                          ;; 00:1b13 $5f
    ld   A, [wDC0B_BlocksetBankOffset+1]                                    ;; 00:1b14 $fa $0c $dc
    adc  A, D                                          ;; 00:1b17 $8a
    ld   D, A                                          ;; 00:1b18 $57
    ld   A, $0b                                        ;; 00:1b19 $3e $0b
.jr_00_1b1b:
    push AF                                            ;; 00:1b1b $f5
    push HL                                            ;; 00:1b1c $e5
    ld   A, [HL+]                                      ;; 00:1b1d $2a
    ld   H, [HL]                                       ;; 00:1b1e $66
    ld   L, A                                          ;; 00:1b1f $6f
    add  HL, HL                                        ;; 00:1b20 $29
    add  HL, HL                                        ;; 00:1b21 $29
    add  HL, HL                                        ;; 00:1b22 $29
    add  HL, DE                                        ;; 00:1b23 $19
    ld   A, [HL+]                                      ;; 00:1b24 $2a
    ld   [BC], A                                       ;; 00:1b25 $02
    inc  BC                                            ;; 00:1b26 $03
    ld   A, [HL]                                       ;; 00:1b27 $7e
    ld   [BC], A                                       ;; 00:1b28 $02
    inc  BC                                            ;; 00:1b29 $03
    ld   A, C                                          ;; 00:1b2a $79
    and  A, $1f                                        ;; 00:1b2b $e6 $1f
    jr   NZ, .jr_00_1b34                               ;; 00:1b2d $20 $05
    dec  BC                                            ;; 00:1b2f $0b
    ld   A, C                                          ;; 00:1b30 $79
    and  A, $e0                                        ;; 00:1b31 $e6 $e0
    ld   C, A                                          ;; 00:1b33 $4f
.jr_00_1b34:
    pop  HL                                            ;; 00:1b34 $e1
    inc  L                                             ;; 00:1b35 $2c
    inc  L                                             ;; 00:1b36 $2c
    res  5, L                                          ;; 00:1b37 $cb $ad
    pop  AF                                            ;; 00:1b39 $f1
    dec  A                                             ;; 00:1b3a $3d
    jr   NZ, .jr_00_1b1b                               ;; 00:1b3b $20 $de
    jp   call_00_0f08_RestoreBank                                  ;; 00:1b3d $c3 $08 $0f
.jp_00_1b40:
    ; BGMAP_PASS_COLLISION: collision map -> collision blockset -> wC000_BgMapTileIds,
    ; where it stays for the rest of the map's life as the collision layer
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1b40 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1b43 $cd $ee $0e
    ld   HL, wDC28_BgMap_ScrollBlockY                                     ;; 00:1b46 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1b49 $6e
    ld   H, HIGH(wCD00_RowOffsetTableForMap)                                        ;; 00:1b4a $26 $cd
    ld   E, [HL]                                       ;; 00:1b4c $5e
    inc  H                                             ;; 00:1b4d $24
    ld   D, [HL]                                       ;; 00:1b4e $56
    ld   HL, wDC0E_MapCollisionBankOffset                                     ;; 00:1b4f $21 $0e $dc
    ld   A, [HL+]                                      ;; 00:1b52 $2a
    add  A, E                                          ;; 00:1b53 $83
    ld   E, A                                          ;; 00:1b54 $5f
    ld   A, [HL]                                       ;; 00:1b55 $7e
    adc  A, D                                          ;; 00:1b56 $8a
    ld   D, A                                          ;; 00:1b57 $57
    ld   HL, wDC27_BgMap_ScrollBlockX                                     ;; 00:1b58 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1b5b $6e
    ld   H, $00                                        ;; 00:1b5c $26 $00
    add  HL, DE                                        ;; 00:1b5e $19
    ld   E, L                                          ;; 00:1b5f $5d
    ld   D, H                                          ;; 00:1b60 $54
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:1b61 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1b64 $6e
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1b65 $26 $cf
    ld   B, $0b                                        ;; 00:1b67 $06 $0b
.jr_00_1b69:
    ld   A, [DE]                                       ;; 00:1b69 $1a
    ld   [HL+], A                                      ;; 00:1b6a $22
    inc  L                                             ;; 00:1b6b $2c
    res  5, L                                          ;; 00:1b6c $cb $ad
    inc  DE                                            ;; 00:1b6e $13
    dec  B                                             ;; 00:1b6f $05
    jr   NZ, .jr_00_1b69                               ;; 00:1b70 $20 $f7
    call call_00_0f08_RestoreBank                                  ;; 00:1b72 $cd $08 $0f
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:1b75 $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1b78 $cd $ee $0e
    ld   HL, wDC22_BgMap_RowWritePosHi                                     ;; 00:1b7b $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:1b7e $3a
    ld   C, [HL]                                       ;; 00:1b7f $4e
    and  A, $03                                        ;; 00:1b80 $e6 $03
    add  A, $c0                                        ;; 00:1b82 $c6 $c0
    ld   B, A                                          ;; 00:1b84 $47
    ld   HL, wDC25_BgMap_ScratchRowOffset                                     ;; 00:1b85 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1b88 $6e
    ld   H, HIGH(wCF00_TileScratchBuffers)                                        ;; 00:1b89 $26 $cf
    pop  DE                                            ;; 00:1b8b $d1
    ld   A, [wDC11_CollisionBlocksetOffset]                                    ;; 00:1b8c $fa $11 $dc
    add  A, E                                          ;; 00:1b8f $83
    ld   E, A                                          ;; 00:1b90 $5f
    ld   A, [wDC11_CollisionBlocksetOffset+1]                                    ;; 00:1b91 $fa $12 $dc
    adc  A, D                                          ;; 00:1b94 $8a
    ld   D, A                                          ;; 00:1b95 $57
    ld   A, $0b                                        ;; 00:1b96 $3e $0b
.jr_00_1b98:
    push AF                                            ;; 00:1b98 $f5
    push HL                                            ;; 00:1b99 $e5
    ld   L, [HL]                                       ;; 00:1b9a $6e
    ld   H, $00                                        ;; 00:1b9b $26 $00
    add  HL, HL                                        ;; 00:1b9d $29
    add  HL, HL                                        ;; 00:1b9e $29
    add  HL, DE                                        ;; 00:1b9f $19
    ld   A, [HL+]                                      ;; 00:1ba0 $2a
    ld   [BC], A                                       ;; 00:1ba1 $02
    inc  BC                                            ;; 00:1ba2 $03
    ld   A, [HL]                                       ;; 00:1ba3 $7e
    ld   [BC], A                                       ;; 00:1ba4 $02
    inc  BC                                            ;; 00:1ba5 $03
    ld   A, C                                          ;; 00:1ba6 $79
    and  A, $1f                                        ;; 00:1ba7 $e6 $1f
    jr   NZ, .jr_00_1bb0                               ;; 00:1ba9 $20 $05
    dec  BC                                            ;; 00:1bab $0b
    ld   A, C                                          ;; 00:1bac $79
    and  A, $e0                                        ;; 00:1bad $e6 $e0
    ld   C, A                                          ;; 00:1baf $4f
.jr_00_1bb0:
    pop  HL                                            ;; 00:1bb0 $e1
    inc  L                                             ;; 00:1bb1 $2c
    inc  L                                             ;; 00:1bb2 $2c
    res  5, L                                          ;; 00:1bb3 $cb $ad
    pop  AF                                            ;; 00:1bb5 $f1
    dec  A                                             ;; 00:1bb6 $3d
    jr   NZ, .jr_00_1b98                               ;; 00:1bb7 $20 $df
    jp   call_00_0f08_RestoreBank                                  ;; 00:1bb9 $c3 $08 $0f

call_00_1bbc_CheckForDoorAndEnter:
; The other way into another map: standing in a doorway and pressing Up.
;
; Two levels are excluded outright - LEVEL_ANIME_CHANNEL and LEVEL_CHANNEL_Z use
; the Up input for something else - and outside LEVEL_GEX_CAVE a
; wDCD2_FreestandingRemoteHitFlags value of $81 suppresses doors as well.
;
; wDB6C_CurrentMapId then selects this map's door list out of
; .data_00_1c33_DoorLocationsByMap; a null pointer means the map has no doors.
; The list is walked one MAP_DOOR_ENTRY_SIZE record at a time until
; MAP_DOOR_LIST_END:
;   +0  db  spawn id to arrive at        -> wDCC1_Door_TargetSpawnId
;   +1  db  required wDCB1_LevelTriggerBuffer index, or MAP_DOOR_NO_TRIGGER
;                                        -> wDCC2_Door_RequiredTriggerIndex
;   +2  dw  door X
;   +4  dw  door Y
;
; A record matches when the player's Y equals the door's Y exactly and their X
; is within MAP_DOOR_X_TOLERANCE either side - the exact Y test is why doors sit
; on the ground the player is standing on. On a match with a trigger index, the
; corresponding wDCB1_LevelTriggerBuffer slot must be non-zero or the door stays
; shut, which is how doors are locked until something in the level has been done.
;
; Otherwise it is the same handoff as the edge transition: spawn id to
; wDC69_PlayerSpawnIdInLevel, bit 2 of wDB6A_WarpFlags, and
; call_00_1633_Map_LoadWarpDestination finishes the job
    ld   A, [wDC1E_CurrentLevelID]                                    ;; 00:1bbc $fa $1e $dc
    cp   A, LEVEL_ANIME_CHANNEL                                        ;; 00:1bbf $fe $05
    ret  Z                                             ;; 00:1bc1 $c8
    cp   A, LEVEL_CHANNEL_Z                                        ;; 00:1bc2 $fe $0b
    ret  Z                                             ;; 00:1bc4 $c8
    and  A, A                                          ;; 00:1bc5 $a7
    jr   Z, .jr_00_1bce                                ;; 00:1bc6 $28 $06
    ld   A, [wDCD2_FreestandingRemoteHitFlags]                                    ;; 00:1bc8 $fa $d2 $dc
    cp   A, $81                                        ;; 00:1bcb $fe $81
    ret  Z                                             ;; 00:1bcd $c8
.jr_00_1bce:
    ld   HL, wDB6C_CurrentMapId                                     ;; 00:1bce $21 $6c $db
    ld   L, [HL]                                       ;; 00:1bd1 $6e
    ld   H, $00                                        ;; 00:1bd2 $26 $00
    add  HL, HL                                        ;; 00:1bd4 $29
    ld   DE, .data_00_1c33_DoorLocationsByMap                                     ;; 00:1bd5 $11 $33 $1c
    add  HL, DE                                        ;; 00:1bd8 $19
    ld   A, [HL+]                                      ;; 00:1bd9 $2a
    ld   H, [HL]                                       ;; 00:1bda $66
    ld   L, A                                          ;; 00:1bdb $6f
    or   A, H                                          ;; 00:1bdc $b4
    ret  Z                                             ;; 00:1bdd $c8
.jr_00_1bde:
    ld   A, [HL+]                                      ;; 00:1bde $2a
    ld   [wDCC1_Door_TargetSpawnId], A                                    ;; 00:1bdf $ea $c1 $dc
    ld   A, [HL+]                                      ;; 00:1be2 $2a
    ld   [wDCC2_Door_RequiredTriggerIndex], A                                    ;; 00:1be3 $ea $c2 $dc
    ld   E, [HL]                                       ;; 00:1be6 $5e
    inc  HL                                            ;; 00:1be7 $23
    ld   D, [HL]                                       ;; 00:1be8 $56
    inc  HL                                            ;; 00:1be9 $23
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:1bea $fa $10 $d8
    sub  A, [HL]                                       ;; 00:1bed $96
    ld   B, A                                          ;; 00:1bee $47
    inc  HL                                            ;; 00:1bef $23
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:1bf0 $fa $11 $d8
    sbc  A, [HL]                                       ;; 00:1bf3 $9e
    inc  HL                                            ;; 00:1bf4 $23
    or   A, B                                          ;; 00:1bf5 $b0
    jr   NZ, .jr_00_1c10                               ;; 00:1bf6 $20 $18
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:1bf8 $fa $0e $d8
    sub  A, E                                          ;; 00:1bfb $93
    ld   E, A                                          ;; 00:1bfc $5f
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:1bfd $fa $0f $d8
    sbc  A, D                                          ;; 00:1c00 $9a
    ld   D, A                                          ;; 00:1c01 $57
    ld   A, E                                          ;; 00:1c02 $7b
    add  A, $08                                        ;; 00:1c03 $c6 $08
    ld   E, A                                          ;; 00:1c05 $5f
    ld   A, D                                          ;; 00:1c06 $7a
    adc  A, $00                                        ;; 00:1c07 $ce $00
    jr   NZ, .jr_00_1c10                               ;; 00:1c09 $20 $05
    ld   A, E                                          ;; 00:1c0b $7b
    cp   A, MAP_DOOR_X_TOLERANCE * 2                   ;; 00:1c0c $fe $10                ; |player X - door X| < 8
    jr   C, .jr_00_1c16                                ;; 00:1c0e $38 $06
.jr_00_1c10:
    ld   A, [HL]                                       ;; 00:1c10 $7e
    cp   A, MAP_DOOR_LIST_END                          ;; 00:1c11 $fe $ff
    jr   NZ, .jr_00_1bde                               ;; 00:1c13 $20 $c9                ; next door in this map's list
    ret                                                ;; 00:1c15 $c9
.jr_00_1c16:
    ld   A, [wDCC2_Door_RequiredTriggerIndex]                                    ;; 00:1c16 $fa $c2 $dc
    cp   A, MAP_DOOR_NO_TRIGGER                        ;; 00:1c19 $fe $ff
    jr   Z, .jr_00_1c27                                ;; 00:1c1b $28 $0a
    ld   E, A                                          ;; 00:1c1d $5f
    ld   D, $00                                        ;; 00:1c1e $16 $00
    ld   HL, wDCB1_LevelTriggerBuffer                                     ;; 00:1c20 $21 $b1 $dc
    add  HL, DE                                        ;; 00:1c23 $19
    ld   A, [HL]                                       ;; 00:1c24 $7e
    and  A, A                                          ;; 00:1c25 $a7
    ret  Z                                             ;; 00:1c26 $c8
.jr_00_1c27:
    ld   A, [wDCC1_Door_TargetSpawnId]                                    ;; 00:1c27 $fa $c1 $dc
    ld   [wDC69_PlayerSpawnIdInLevel], A                                    ;; 00:1c2a $ea $69 $dc
    ld   HL, wDB6A_WarpFlags                                     ;; 00:1c2d $21 $6a $db
    set  2, [HL]                                       ;; 00:1c30 $cb $d6
    ret                                                ;; 00:1c32 $c9
.data_00_1c33_DoorLocationsByMap:
; One pointer per map to that map's list of doors, or $0000 when the map has
; none. Each list is MAP_DOOR_ENTRY_SIZE-byte records ended by MAP_DOOR_LIST_END:
;   db spawn id, db required trigger index, dw door X, dw door Y
    dw   .doors_gex_cave1            ; MAP_GEX_CAVE1
    dw   .doors_holiday_tv1            ; MAP_HOLIDAY_TV1
    dw   .doors_mystery_tv1            ; MAP_MYSTERY_TV1
    dw   $0000                    ; MAP_TUT_TV1 - no doors
    dw   .doors_western_station1            ; MAP_WESTERN_STATION1
    dw   .doors_anime_channel1            ; MAP_ANIME_CHANNEL1
    dw   .doors_superhero_show1            ; MAP_SUPERHERO_SHOW1
    dw   .doors_gextreme_sports1            ; MAP_GEXTREME_SPORTS1
    dw   $0000                    ; MAP_MARSUPIAL_MADNESS1 - no doors
    dw   $0000                    ; MAP_WW_GEX_WRESTLING1 - no doors
    dw   $0000                    ; MAP_LIZARD_OF_OZ1 - no doors
    dw   .doors_channel_z1            ; MAP_CHANNEL_Z1
    dw   .doors_gex_cave2            ; MAP_GEX_CAVE2
    dw   .doors_gex_cave3            ; MAP_GEX_CAVE3
    dw   .doors_gex_cave4            ; MAP_GEX_CAVE4
    dw   .doors_holiday_tv2            ; MAP_HOLIDAY_TV2
    dw   .doors_holiday_tv3            ; MAP_HOLIDAY_TV3
    dw   $0000                    ; MAP_HOLIDAY_TV4 - no doors
    dw   $0000                    ; MAP_MYSTERY_TV2 - no doors
    dw   .doors_mystery_tv3            ; MAP_MYSTERY_TV3
    dw   .doors_mystery_tv4            ; MAP_MYSTERY_TV4
    dw   .doors_mystery_tv5            ; MAP_MYSTERY_TV5
    dw   .doors_mystery_tv6            ; MAP_MYSTERY_TV6
    dw   $0000                    ; MAP_MYSTERY_TV7 - no doors
    dw   $0000                    ; MAP_MYSTERY_TV8 - no doors
    dw   $0000                    ; MAP_MYSTERY_TV9 - no doors
    dw   $0000                    ; MAP_MYSTERY_TV10 - no doors
    dw   .doors_tut_tv2            ; MAP_TUT_TV2
    dw   $0000                    ; MAP_TUT_TV3 - no doors
    dw   $0000                    ; MAP_TUT_TV4 - no doors
    dw   $0000                    ; MAP_TUT_TV5 - no doors
    dw   $0000                    ; MAP_TUT_TV6 - no doors
    dw   $0000                    ; MAP_TUT_TV7 - no doors
    dw   .doors_western_station2            ; MAP_WESTERN_STATION2
    dw   .doors_western_station3            ; MAP_WESTERN_STATION3
    dw   .doors_western_station4            ; MAP_WESTERN_STATION4
    dw   $0000                    ; MAP_WESTERN_STATION5 - no doors
    dw   $0000                    ; MAP_WESTERN_STATION6 - no doors
    dw   .doors_western_station7            ; MAP_WESTERN_STATION7
    dw   .doors_western_station8            ; MAP_WESTERN_STATION8
    dw   .doors_western_station9            ; MAP_WESTERN_STATION9
    dw   .doors_anime_channel2            ; MAP_ANIME_CHANNEL2
    dw   .doors_anime_channel3            ; MAP_ANIME_CHANNEL3
    dw   .doors_anime_channel4            ; MAP_ANIME_CHANNEL4
    dw   .doors_anime_channel5            ; MAP_ANIME_CHANNEL5
    dw   .doors_anime_channel6            ; MAP_ANIME_CHANNEL6
    dw   .doors_anime_channel7            ; MAP_ANIME_CHANNEL7
    dw   .doors_anime_channel8            ; MAP_ANIME_CHANNEL8
    dw   .doors_anime_channel9            ; MAP_ANIME_CHANNEL9
    dw   .doors_superhero_show2            ; MAP_SUPERHERO_SHOW2
    dw   .doors_superhero_show3            ; MAP_SUPERHERO_SHOW3
    dw   .doors_superhero_show4            ; MAP_SUPERHERO_SHOW4
    dw   .doors_superhero_show5            ; MAP_SUPERHERO_SHOW5
    dw   .doors_superhero_show6            ; MAP_SUPERHERO_SHOW6
    dw   .doors_gextreme_sports2            ; MAP_GEXTREME_SPORTS2
    dw   .doors_gextreme_sports3            ; MAP_GEXTREME_SPORTS3
    dw   .doors_gextreme_sports4            ; MAP_GEXTREME_SPORTS4
    dw   .doors_channel_z2            ; MAP_CHANNEL_Z2
    dw   .doors_channel_z3            ; MAP_CHANNEL_Z3
    dw   .doors_channel_z4            ; MAP_CHANNEL_Z4
    dw   $0000                    ; MAP_CHANNEL_Z5 - no doors
.doors_gex_cave1:
    db   $03, $ff, $b0, $01, $f0, $00         ; spawn $03 at $01b0,$00f0, no trigger
    db   $04, $ff, $50, $00, $70, $00         ; spawn $04 at $0050,$0070, no trigger
    db   $05, $ff, $50, $01, $40, $00         ; spawn $05 at $0150,$0040, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gex_cave2:
    db   $00, $ff, $f0, $00, $80, $00         ; spawn $00 at $00f0,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gex_cave3:
    db   $01, $ff, $f0, $00, $f0, $00         ; spawn $01 at $00f0,$00f0, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gex_cave4:
    db   $02, $ff, $30, $00, $30, $00         ; spawn $02 at $0030,$0030, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_holiday_tv1:
    db   $00, $ff, $60, $09, $00, $04         ; spawn $00 at $0960,$0400, no trigger
    db   $01, $ff, $a0, $07, $00, $01         ; spawn $01 at $07a0,$0100, no trigger
    db   $02, $ff, $c8, $02, $80, $00         ; spawn $02 at $02c8,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_holiday_tv2:
    db   $03, $ff, $20, $01, $80, $00         ; spawn $03 at $0120,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_holiday_tv3:
    db   $04, $ff, $20, $00, $30, $01         ; spawn $04 at $0020,$0130, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_mystery_tv1:
    db   $00, $ff, $98, $02, $b0, $02         ; spawn $00 at $0298,$02b0, no trigger
    db   $01, $ff, $28, $02, $b0, $02         ; spawn $01 at $0228,$02b0, no trigger
    db   $02, $ff, $68, $02, $d0, $01         ; spawn $02 at $0268,$01d0, no trigger
    db   $03, $ff, $d8, $00, $40, $01         ; spawn $03 at $00d8,$0140, no trigger
    db   $04, $ff, $f8, $01, $80, $00         ; spawn $04 at $01f8,$0080, no trigger
    db   $05, $ff, $28, $00, $50, $00         ; spawn $05 at $0028,$0050, no trigger
    db   $17, $ff, $08, $01, $50, $02         ; spawn $17 at $0108,$0250, no trigger
    db   $16, $ff, $a8, $02, $d0, $01         ; spawn $16 at $02a8,$01d0, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_mystery_tv3:
    db   $09, $ff, $18, $00, $68, $00         ; spawn $09 at $0018,$0068, no trigger
    db   $0a, $ff, $b8, $02, $68, $00         ; spawn $0a at $02b8,$0068, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_mystery_tv4:
    db   $0b, $ff, $20, $00, $80, $00         ; spawn $0b at $0020,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_mystery_tv5:
    db   $0c, $ff, $20, $01, $30, $01         ; spawn $0c at $0120,$0130, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_mystery_tv6:
    db   $0d, $ff, $20, $00, $e0, $01         ; spawn $0d at $0020,$01e0, no trigger
    db   $0e, $ff, $20, $01, $e0, $01         ; spawn $0e at $0120,$01e0, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_tut_tv2:
    db   $07, $00, $ec, $00, $60, $02         ; spawn $07 at $00ec,$0260, needs trigger $00
    db   $0b, $01, $7c, $02, $60, $02         ; spawn $0b at $027c,$0260, needs trigger $01
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station1:
    db   $00, $ff, $c0, $00, $50, $01         ; spawn $00 at $00c0,$0150, no trigger
    db   $02, $ff, $10, $01, $50, $01         ; spawn $02 at $0110,$0150, no trigger
    db   $04, $ff, $98, $01, $a0, $00         ; spawn $04 at $0198,$00a0, no trigger
    db   $06, $ff, $f0, $01, $50, $01         ; spawn $06 at $01f0,$0150, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station2:
    db   $08, $ff, $aa, $01, $98, $00         ; spawn $08 at $01aa,$0098, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station3:
    db   $09, $ff, $30, $01, $90, $00         ; spawn $09 at $0130,$0090, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station4:
    db   $01, $ff, $10, $00, $70, $00         ; spawn $01 at $0010,$0070, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station7:
    db   $03, $ff, $10, $00, $70, $00         ; spawn $03 at $0010,$0070, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station8:
    db   $05, $ff, $10, $00, $00, $01         ; spawn $05 at $0010,$0100, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_western_station9:
    db   $07, $ff, $10, $00, $70, $00         ; spawn $07 at $0010,$0070, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel1:
    db   $00, $ff, $c0, $00, $c0, $01         ; spawn $00 at $00c0,$01c0, no trigger
    db   $01, $ff, $f0, $01, $c0, $01         ; spawn $01 at $01f0,$01c0, no trigger
    db   $02, $ff, $20, $03, $c0, $01         ; spawn $02 at $0320,$01c0, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel2:
    db   $05, $ff, $30, $00, $c0, $01         ; spawn $05 at $0030,$01c0, no trigger
    db   $09, $ff, $e0, $02, $00, $01         ; spawn $09 at $02e0,$0100, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel3:
    db   $07, $ff, $c0, $01, $80, $00         ; spawn $07 at $01c0,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel4:
    db   $03, $ff, $30, $00, $80, $02         ; spawn $03 at $0030,$0280, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel5:
    db   $04, $ff, $a0, $09, $80, $00         ; spawn $04 at $09a0,$0080, no trigger
    db   $0b, $05, $e0, $03, $40, $01         ; spawn $0b at $03e0,$0140, needs trigger $05
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel6:
    db   $0c, $ff, $a0, $01, $f0, $00         ; spawn $0c at $01a0,$00f0, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel7:
    db   $0d, $ff, $f0, $00, $00, $02         ; spawn $0d at $00f0,$0200, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel8:
    db   $0e, $ff, $50, $00, $10, $03         ; spawn $0e at $0050,$0310, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_anime_channel9:
    db   $0a, $0d, $b0, $03, $40, $01         ; spawn $0a at $03b0,$0140, needs trigger $0d
    db   $0f, $0a, $70, $01, $a0, $00         ; spawn $0f at $0170,$00a0, needs trigger $0a
    db   $10, $0b, $50, $02, $30, $00         ; spawn $10 at $0250,$0030, needs trigger $0b
    db   $11, $0c, $30, $03, $a0, $00         ; spawn $11 at $0330,$00a0, needs trigger $0c
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_superhero_show1:
    db   $00, $ff, $70, $00, $b0, $00         ; spawn $00 at $0070,$00b0, no trigger
    db   $02, $ff, $70, $00, $00, $01         ; spawn $02 at $0070,$0100, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_superhero_show2:
    db   $01, $ff, $c0, $0b, $a0, $02         ; spawn $01 at $0bc0,$02a0, no trigger
    db   $04, $ff, $80, $00, $20, $03         ; spawn $04 at $0080,$0320, no trigger
    db   $06, $ff, $40, $04, $00, $01         ; spawn $06 at $0440,$0100, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_superhero_show3:
    db   $03, $ff, $60, $00, $80, $00         ; spawn $03 at $0060,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_superhero_show4:
    db   $05, $ff, $e0, $00, $a0, $01         ; spawn $05 at $00e0,$01a0, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_superhero_show5:
    db   $07, $ff, $a0, $02, $c0, $01         ; spawn $07 at $02a0,$01c0, no trigger
    db   $08, $ff, $a0, $02, $80, $00         ; spawn $08 at $02a0,$0080, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_superhero_show6:
    db   $09, $ff, $50, $00, $60, $00         ; spawn $09 at $0050,$0060, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gextreme_sports1:
    db   $00, $ff, $7c, $02, $b8, $02         ; spawn $00 at $027c,$02b8, no trigger
    db   $01, $ff, $fc, $01, $b8, $01         ; spawn $01 at $01fc,$01b8, no trigger
    db   $02, $ff, $8c, $01, $f8, $00         ; spawn $02 at $018c,$00f8, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gextreme_sports2:
    db   $03, $ff, $20, $00, $30, $01         ; spawn $03 at $0020,$0130, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gextreme_sports3:
    db   $04, $ff, $20, $00, $30, $01         ; spawn $04 at $0020,$0130, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_gextreme_sports4:
    db   $05, $ff, $20, $00, $30, $01         ; spawn $05 at $0020,$0130, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_channel_z1:
    db   $00, $00, $60, $02, $c0, $00         ; spawn $00 at $0260,$00c0, needs trigger $00
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_channel_z2:
    db   $05, $ff, $30, $00, $f0, $00         ; spawn $05 at $0030,$00f0, no trigger
    db   $04, $ff, $00, $01, $b0, $00         ; spawn $04 at $0100,$00b0, no trigger
    db   $06, $01, $c0, $01, $f0, $00         ; spawn $06 at $01c0,$00f0, needs trigger $01
    db   $07, $02, $00, $01, $20, $00         ; spawn $07 at $0100,$0020, needs trigger $02
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_channel_z3:
    db   $01, $ff, $38, $01, $80, $01         ; spawn $01 at $0138,$0180, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
.doors_channel_z4:
    db   $02, $ff, $38, $01, $80, $01         ; spawn $02 at $0138,$0180, no trigger
    db   $ff                                ; MAP_DOOR_LIST_END
