call_00_1056_LoadFullMap:
; Role: Orchestrates loading an entire level/map. Clears game state, resets VRAM/tables, 
; loads palettes and background maps in several passes, copies collision tileset data to WRAM, 
; Calls external banked functions for map-specific assets, and finally resets status flags.
; Why: It’s the master routine for initializing a new map and its supporting graphics/collision data.
    call call_00_0e3b_ClearGameStateVariables                                  ;; 00:1056 $cd $3b $0e
    call call_00_0e62_ResetFlagsAndVRAMState                                  ;; 00:1059 $cd $62 $0e
    call call_00_10c7_InitRowOffsetTableForMap                                  ;; 00:105c $cd $c7 $10
    ld   C, $00                                        ;; 00:105f $0e $00
    farcall call_03_65c6_LoadMenuOrLevelPalettes
    ld   C, $03                                        ;; 00:106c $0e $03
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:106e $cd $6a $0a
    ld   C, $04                                        ;; 00:1071 $0e $04
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1073 $cd $6a $0a
    ld   C, $05                                        ;; 00:1076 $0e $05
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1078 $cd $6a $0a
    ld   C, $06                                        ;; 00:107b $0e $06
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:107d $cd $6a $0a
    ld   A, $04                                        ;; 00:1080 $3e $04
    call call_00_1a22_LoadInitialBgMap                                  ;; 00:1082 $cd $22 $1a
    ld   C, $07                                        ;; 00:1085 $0e $07
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1087 $cd $6a $0a
    ld   A, $00                                        ;; 00:108a $3e $00
    call call_00_1a22_LoadInitialBgMap                                  ;; 00:108c $cd $22 $1a
    ld   C, $08                                        ;; 00:108f $0e $08
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:1091 $cd $6a $0a
    ld   A, $80                                        ;; 00:1094 $3e $80
    call call_00_1a22_LoadInitialBgMap                                  ;; 00:1096 $cd $22 $1a
    ld   A, BANK_03_COLLISION_AND_GRAPHICS_CODE                                        ;; 00:1099 $3e $03
    call call_00_0eee_SwitchBank                                  ;; 00:109b $cd $ee $0e
    ld   HL, image_003_4100_collision_tileset                                     ;; 00:109e $21 $00 $41
    ld   DE, wC400_CollisionTilesetData                                     ;; 00:10a1 $11 $00 $c4
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
    ld   [wDC20], A                                    ;; 00:10c3 $ea $20 $dc
    ret                                                ;; 00:10c6 $c9

call_00_10c7_InitRowOffsetTableForMap:
; Role: Builds a lookup table of row start addresses for a tilemap based on its width, 
; so the engine can quickly convert (x,y) positions to memory offsets.
; Why: This table accelerates map rendering and collision checks by precomputing row offsets.
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

call_00_10de_UpdatePlayerMapWindow:
; Role: Computes the player’s X/Y position within the map, clamps it against map bounds, 
; and calculates visible window extents. Stores several intermediate values 
; (e.g., wDA14_CameraPos_Left–wDA1A_CameraPos_Bottom+1, wDBF9–wDBFC) used for scrolling and collision.
; Why: Prepares all map-relative coordinates for rendering and collision based on the player’s position.
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
    ld   HL, wDCAC                                     ;; 00:1156 $21 $ac $dc
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

call_00_11c8_LoadBgMapDirtyRegions:
; Role: Checks scroll flags in wDC20 to see whether vertical or horizontal 
; background map sections need updating. Calls the appropriate vertical (11E5) 
; or horizontal (1351) loader and sets a busy flag.
; Why: Handles incremental background updates only where scrolling occurred.
    ld   HL, wDC20                                     ;; 00:11c8 $21 $20 $dc
    bit  7, [HL]                                       ;; 00:11cb $cb $7e
    jr   NZ, call_00_11c8_LoadBgMapDirtyRegions                              ;; 00:11cd $20 $f9
    ld   A, [wDC20]                                    ;; 00:11cf $fa $20 $dc
    and  A, $03                                        ;; 00:11d2 $e6 $03
    call NZ, call_00_11e5_LoadVerticalBgStrip                              ;; 00:11d4 $c4 $e5 $11
    ld   A, [wDC20]                                    ;; 00:11d7 $fa $20 $dc
    and  A, $0c                                        ;; 00:11da $e6 $0c
    call NZ, call_00_1351_LoadHorizontalBgStrip                              ;; 00:11dc $c4 $51 $13
    ld   HL, wDC20                                     ;; 00:11df $21 $20 $dc
    set  7, [HL]                                       ;; 00:11e2 $cb $fe
    ret                                                ;; 00:11e4 $c9

call_00_11e5_LoadVerticalBgStrip:
; Role: Loads a vertical strip of background tiles into VRAM based on the player’s Y position. 
; Switches between multiple banks to pull map, extended, and collision data, 
; then assembles tiles and writes them to VRAM buffers.
; Why: Updates the tilemap column(s) entering view when the camera scrolls vertically.
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:11e5 $21 $fb $db
    ld   A, [HL+]                                      ;; 00:11e8 $2a
    ld   C, A                                          ;; 00:11e9 $4f
    ld   A, [HL+]                                      ;; 00:11ea $2a
    ld   B, A                                          ;; 00:11eb $47
    ld   HL, $88                                       ;; 00:11ec $21 $88 $00
    ld   A, [wDC20]                                    ;; 00:11ef $fa $20 $dc
    and  A, $02                                        ;; 00:11f2 $e6 $02
    jr   NZ, .jr_00_11f9                               ;; 00:11f4 $20 $03
    ld   HL, rIE                                       ;; 00:11f6 $21 $ff $ff
.jr_00_11f9:
    add  HL, BC                                        ;; 00:11f9 $09
    ld   C, L                                          ;; 00:11fa $4d
    ld   B, H                                          ;; 00:11fb $44
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:11fc $21 $f9 $db
    ld   E, [HL]                                       ;; 00:11ff $5e
    inc  HL                                            ;; 00:1200 $23
    ld   D, [HL]                                       ;; 00:1201 $56
    call call_00_14e2_ConvertXYToTileCoords                                  ;; 00:1202 $cd $e2 $14
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
    ld   [wDC25], A                                    ;; 00:1213 $ea $25 $dc
    or   A, L                                          ;; 00:1216 $b5
    ld   [wDC21], A                                    ;; 00:1217 $ea $21 $dc
    ld   A, H                                          ;; 00:121a $7c
    or   A, $98                                        ;; 00:121b $f6 $98
    ld   [wDC22], A                                    ;; 00:121d $ea $22 $dc
    ld   A, C                                          ;; 00:1220 $79
    rrca                                               ;; 00:1221 $0f
    rrca                                               ;; 00:1222 $0f
    and  A, $02                                        ;; 00:1223 $e6 $02
    ld   E, A                                          ;; 00:1225 $5f
    ld   D, $00                                        ;; 00:1226 $16 $00
    push DE                                            ;; 00:1228 $d5
    push DE                                            ;; 00:1229 $d5
    ld   A, [wDC01_MapBank]                                    ;; 00:122a $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:122d $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1230 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:1242 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1245 $6e
    ld   H, $00                                        ;; 00:1246 $26 $00
    add  HL, DE                                        ;; 00:1248 $19
    ld   E, L                                          ;; 00:1249 $5d
    ld   D, H                                          ;; 00:124a $54
    ld   HL, wDC25                                     ;; 00:124b $21 $25 $dc
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
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:125f $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1262 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1265 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:1277 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:127a $6e
    ld   H, $00                                        ;; 00:127b $26 $00
    add  HL, DE                                        ;; 00:127d $19
    ld   E, L                                          ;; 00:127e $5d
    ld   D, H                                          ;; 00:127f $54
    ld   HL, wDC25                                     ;; 00:1280 $21 $25 $dc
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
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1295 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1298 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:129b $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:12ad $21 $27 $dc
    ld   L, [HL]                                       ;; 00:12b0 $6e
    ld   H, $00                                        ;; 00:12b1 $26 $00
    add  HL, DE                                        ;; 00:12b3 $19
    ld   E, L                                          ;; 00:12b4 $5d
    ld   D, H                                          ;; 00:12b5 $54
    ld   HL, wDC22                                     ;; 00:12b6 $21 $22 $dc
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
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:12d6 $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:12d9 $cd $ee $0e
    ld   HL, wDC25                                     ;; 00:12dc $21 $25 $dc
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
    ld   A, [DE]                                       ;; 00:12f0 $1a
    ld   L, A                                          ;; 00:12f1 $6f
    inc  E                                             ;; 00:12f2 $1c
    ld   A, [DE]                                       ;; 00:12f3 $1a
    ld   H, A                                          ;; 00:12f4 $67
    dec  E                                             ;; 00:12f5 $1d
    add  HL, HL                                        ;; 00:12f6 $29
    add  HL, HL                                        ;; 00:12f7 $29
    add  HL, HL                                        ;; 00:12f8 $29
    add  HL, BC                                        ;; 00:12f9 $09
    ld   A, [HL+]                                      ;; 00:12fa $2a
    ld   [DE], A                                       ;; 00:12fb $12
    inc  E                                             ;; 00:12fc $1c
    ld   A, [HL+]                                      ;; 00:12fd $2a
    ld   [DE], A                                       ;; 00:12fe $12
    dec  E                                             ;; 00:12ff $1d
    set  7, E                                          ;; 00:1300 $cb $fb
    inc  HL                                            ;; 00:1302 $23
    inc  HL                                            ;; 00:1303 $23
    ld   A, [HL+]                                      ;; 00:1304 $2a
    ld   [DE], A                                       ;; 00:1305 $12
    inc  E                                             ;; 00:1306 $1c
    ld   A, [HL+]                                      ;; 00:1307 $2a
    ld   [DE], A                                       ;; 00:1308 $12
    res  7, E                                          ;; 00:1309 $cb $bb
    inc  E                                             ;; 00:130b $1c
    res  5, E                                          ;; 00:130c $cb $ab
    pop  AF                                            ;; 00:130e $f1
    dec  A                                             ;; 00:130f $3d
    jr   NZ, .jr_00_12ef                               ;; 00:1310 $20 $dd
    call call_00_0f08_RestoreBank                                  ;; 00:1312 $cd $08 $0f
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:1315 $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1318 $cd $ee $0e
    ld   HL, wDC22                                     ;; 00:131b $21 $22 $dc
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

call_00_1351_LoadHorizontalBgStrip:
; Role: Loads a horizontal strip of background tiles into VRAM based on the player’s X position. 
; Switches between multiple banks to pull map, extended, and collision data, 
; then assembles tiles and writes them to VRAM buffers.
; Why: Updates the tilemap row(s) entering view when the camera scrolls horizontally.
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:1351 $21 $f9 $db
    ld   A, [HL+]                                      ;; 00:1354 $2a
    ld   E, A                                          ;; 00:1355 $5f
    ld   A, [HL+]                                      ;; 00:1356 $2a
    ld   D, A                                          ;; 00:1357 $57
    ld   HL, $a0                                       ;; 00:1358 $21 $a0 $00
    ld   A, [wDC20]                                    ;; 00:135b $fa $20 $dc
    and  A, $08                                        ;; 00:135e $e6 $08
    jr   NZ, .jr_00_1365                               ;; 00:1360 $20 $03
    ld   HL, rIE                                       ;; 00:1362 $21 $ff $ff
.jr_00_1365:
    add  HL, DE                                        ;; 00:1365 $19
    ld   E, L                                          ;; 00:1366 $5d
    ld   D, H                                          ;; 00:1367 $54
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1368 $21 $fb $db
    ld   C, [HL]                                       ;; 00:136b $4e
    inc  HL                                            ;; 00:136c $23
    ld   B, [HL]                                       ;; 00:136d $46
    call call_00_14e2_ConvertXYToTileCoords                                  ;; 00:136e $cd $e2 $14
    ld   A, C                                          ;; 00:1371 $79
    and  A, $f0                                        ;; 00:1372 $e6 $f0
    ld   L, A                                          ;; 00:1374 $6f
    swap A                                             ;; 00:1375 $cb $37
    add  A, A                                          ;; 00:1377 $87
    or   A, $40                                        ;; 00:1378 $f6 $40
    ld   [wDC26], A                                    ;; 00:137a $ea $26 $dc
    ld   H, $00                                        ;; 00:137d $26 $00
    add  HL, HL                                        ;; 00:137f $29
    add  HL, HL                                        ;; 00:1380 $29
    ld   A, E                                          ;; 00:1381 $7b
    rrca                                               ;; 00:1382 $0f
    rrca                                               ;; 00:1383 $0f
    rrca                                               ;; 00:1384 $0f
    and  A, $1f                                        ;; 00:1385 $e6 $1f
    or   A, L                                          ;; 00:1387 $b5
    ld   [wDC23], A                                    ;; 00:1388 $ea $23 $dc
    ld   A, H                                          ;; 00:138b $7c
    or   A, $98                                        ;; 00:138c $f6 $98
    ld   [wDC24], A                                    ;; 00:138e $ea $24 $dc
    ld   A, E                                          ;; 00:1391 $7b
    rrca                                               ;; 00:1392 $0f
    rrca                                               ;; 00:1393 $0f
    rrca                                               ;; 00:1394 $0f
    and  A, $01                                        ;; 00:1395 $e6 $01
    ld   E, A                                          ;; 00:1397 $5f
    ld   D, $00                                        ;; 00:1398 $16 $00
    push DE                                            ;; 00:139a $d5
    push DE                                            ;; 00:139b $d5
    ld   A, [wDC01_MapBank]                                    ;; 00:139c $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:139f $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:13a2 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:13b4 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:13b7 $6e
    ld   H, $00                                        ;; 00:13b8 $26 $00
    add  HL, DE                                        ;; 00:13ba $19
    push HL                                            ;; 00:13bb $e5
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:13bc $21 $1c $dc
    ld   C, [HL]                                       ;; 00:13bf $4e
    ld   B, $00                                        ;; 00:13c0 $06 $00
    ld   HL, wDC26                                     ;; 00:13c2 $21 $26 $dc
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
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:13da $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:13dd $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:13e0 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:13f2 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:13f5 $6e
    ld   H, $00                                        ;; 00:13f6 $26 $00
    add  HL, DE                                        ;; 00:13f8 $19
    push HL                                            ;; 00:13f9 $e5
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:13fa $21 $1c $dc
    ld   C, [HL]                                       ;; 00:13fd $4e
    ld   B, $00                                        ;; 00:13fe $06 $00
    ld   HL, wDC26                                     ;; 00:1400 $21 $26 $dc
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
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1419 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:141c $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:141f $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:1431 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1434 $6e
    ld   H, $00                                        ;; 00:1435 $26 $00
    add  HL, DE                                        ;; 00:1437 $19
    ld   E, L                                          ;; 00:1438 $5d
    ld   D, H                                          ;; 00:1439 $54
    ld   BC, $40                                       ;; 00:143a $01 $40 $00
    ld   HL, wDC24                                     ;; 00:143d $21 $24 $dc
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
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:145f $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1462 $cd $ee $0e
    ld   HL, wDC26                                     ;; 00:1465 $21 $26 $dc
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
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:149f $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:14a2 $cd $ee $0e
    ld   HL, wDC24                                     ;; 00:14a5 $21 $24 $dc
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

call_00_14e2_ConvertXYToTileCoords:
; Coordinate Downscaler
; Takes two 16-bit coordinates (BC and DE), right-shifts them four times (divides by 16), 
; and stores the resulting low bytes in wDC27 (E → low Y) and wDC28 (C → low X). 
; Used to convert pixel positions to tile indices for map lookups.
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
    ld   [wDC27], A                                    ;; 00:1505 $ea $27 $dc
    ld   A, C                                          ;; 00:1508 $79
    ld   [wDC28], A                                    ;; 00:1509 $ea $28 $dc
    pop  DE                                            ;; 00:150c $d1
    pop  BC                                            ;; 00:150d $c1
    ret                                                ;; 00:150e $c9

call_00_150f_CheckAndSetLevelTrigger:
; Level Event Trigger Checker
; Reads wDC8A as an event flag. If not already triggered (bit7 clear), it marks it triggered, 
; looks up a table (.data_00_153f) indexed by current level and offset E, and loads a value into wDC69_PlayerSpawnIdInLevel. 
; It also sets bit2 of wDB6A_WarpFlags. Handles special values $ff (no action) and $fe (conditional on wDCB1_LevelTriggerBuffer).
    ld   HL, wDC8A                                     ;; 00:150f $21 $8a $dc
    ld   E, [HL]                                       ;; 00:1512 $5e
    bit  7, E                                          ;; 00:1513 $cb $7b
    ret  NZ                                            ;; 00:1515 $c0
    ld   [HL], $ff                                     ;; 00:1516 $36 $ff
    ld   D, $00                                        ;; 00:1518 $16 $00
    ld   HL, wDB6C_CurrentMapId                                     ;; 00:151a $21 $6c $db
    ld   L, [HL]                                       ;; 00:151d $6e
    ld   H, $00                                        ;; 00:151e $26 $00
    add  HL, HL                                        ;; 00:1520 $29
    add  HL, HL                                        ;; 00:1521 $29
    add  HL, DE                                        ;; 00:1522 $19
    ld   DE, .data_00_153f                                     ;; 00:1523 $11 $3f $15
    add  HL, DE                                        ;; 00:1526 $19
    ld   A, [HL]                                       ;; 00:1527 $7e
    cp   A, $ff                                        ;; 00:1528 $fe $ff
    ret  Z                                             ;; 00:152a $c8
    cp   A, $fe                                        ;; 00:152b $fe $fe
    jr   NZ, .jr_00_1536                               ;; 00:152d $20 $07
    ld   A, [wDCB1_LevelTriggerBuffer]                                    ;; 00:152f $fa $b1 $dc
    and  A, A                                          ;; 00:1532 $a7
    ret  Z                                             ;; 00:1533 $c8
    ld   A, $10                                        ;; 00:1534 $3e $10
.jr_00_1536:
    ld   [wDC69_PlayerSpawnIdInLevel], A                                    ;; 00:1536 $ea $69 $dc
    ld   HL, wDB6A_WarpFlags                                     ;; 00:1539 $21 $6a $db
    set  2, [HL]                                       ;; 00:153c $cb $d6
    ret                                                ;; 00:153e $c9
.data_00_153f:
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:153f ??????.?
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00        ;; 00:1547 ????????
    db   $ff, $ff, $ff, $0a, $ff, $ff, $ff, $ff        ;; 00:154f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1557 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:155f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1567 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:156f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1577 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $05        ;; 00:157f ????.??w
    db   $08, $06, $07, $12, $ff, $ff, $ff, $ff        ;; 00:1587 ????????
    db   $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:158f ????????
    db   $ff, $ff, $ff, $ff, $fe, $0f, $ff, $ff        ;; 00:1597 ????????
    db   $ff, $11, $ff, $ff, $ff, $15, $ff, $ff        ;; 00:159f ????????
    db   $ff, $ff, $13, $ff, $ff, $02, $05, $03        ;; 00:15a7 ????????
    db   $ff, $ff, $04, $09, $06, $ff, $ff, $ff        ;; 00:15af ????????
    db   $ff, $ff, $08, $ff, $ff, $ff, $0a, $ff        ;; 00:15b7 ????????
    db   $ff, $ff, $0c, $ff, $ff, $ff, $0b, $ff        ;; 00:15bf ????????
    db   $ff, $0e, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15c7 ????????
    db   $ff, $ff, $0d, $ff, $10, $ff, $ff, $0c        ;; 00:15cf ????????
    db   $ff, $ff, $ff, $ff, $ff, $0f, $ff, $ff        ;; 00:15d7 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15df ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15e7 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15ef ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15f7 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15ff ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1607 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:160f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1617 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:161f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1627 ????????
    db   $ff, $ff, $ff, $ff                            ;; 00:162f ????

call_00_1633_HandleLevelWarpOrExit:
; Level Transition Loader
; Calculates a destination level and coordinates based on current level number (wDC1E) and 
; player Y-position. It fetches a pointer from .data_00_16a2_PlayerSpawnPositions, determines the new level ID, 
; screen positions (wDC6A_CheckpointStoredX/B), and offset vector (wDC6C_CheckpointStoredY), ensuring transitions are within bounds.
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:1633 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1636 $6e
    ld   H, $00                                        ;; 00:1637 $26 $00
    add  HL, HL                                        ;; 00:1639 $29
    ld   DE, .data_00_16a2_PlayerSpawnPositions                             ;; 00:163a $11 $a2 $16
    add  HL, DE                                        ;; 00:163d $19
    ld   A, [HL+]                                      ;; 00:163e $2a
    ld   D, [HL]                                       ;; 00:163f $56
    ld   E, A                                          ;; 00:1640 $5f
    ld   HL, wDC69_PlayerSpawnIdInLevel                                     ;; 00:1641 $21 $69 $dc
    ld   L, [HL]                                       ;; 00:1644 $6e
    ld   H, $00                                        ;; 00:1645 $26 $00
    add  HL, HL                                        ;; 00:1647 $29
    add  HL, HL                                        ;; 00:1648 $29
    add  HL, HL                                        ;; 00:1649 $29
    add  HL, DE                                        ;; 00:164a $19
    push HL                                            ;; 00:164b $e5
    ld   BC, $05                                       ;; 00:164c $01 $05 $00
    add  HL, BC                                        ;; 00:164f $09
    ld   A, [HL]                                       ;; 00:1650 $7e
    cp   A, $ff                                        ;; 00:1651 $fe $ff
    jr   NZ, .jr_00_1663                               ;; 00:1653 $20 $0e
    pop  HL                                            ;; 00:1655 $e1
    ld   A, [HL+]                                      ;; 00:1656 $2a
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:1657 $ea $6c $db
    ld   DE, wDC6A_CheckpointStoredX                                     ;; 00:165a $11 $6a $dc
    ld   BC, $04                                       ;; 00:165d $01 $04 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:1660 $c3 $6e $07
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
    ld   DE, $10                                       ;; 00:1698 $11 $10 $00
.jr_00_169b:
    ld   HL, wDC6C_CheckpointStoredY                                     ;; 00:169b $21 $6c $dc
    ld   [HL], E                                       ;; 00:169e $73
    inc  HL                                            ;; 00:169f $23
    ld   [HL], D                                       ;; 00:16a0 $72
    ret                                                ;; 00:16a1 $c9
.data_00_16a2_PlayerSpawnPositions:
    dw   .data_00_16c2
    dw   .data_00_16f2
    dw   .data_00_1722
    dw   .data_00_17e2
    dw   .data_00_184a
    dw   .data_00_18d2
    dw   .data_00_1962
    dw   .data_00_19b2
    dw   .data_00_16ba
    dw   .data_00_16ba
    dw   .data_00_16ba
    dw   .data_00_19e2
.data_00_16ba:
    db   $00, $00, $00, $00        ;; 00:16b6 ????????
    db   $00, $00, $00, $00
.data_00_16c2:
    db   $00, $b0, $01             ;; 00:16be ????w..
    dw   $00f0                                         ;; 00:16c5 wW
    db   $ff, $00, $00, $00, $50, $00                  ;; 00:16c7 .??w..
    dw   $0070                                         ;; 00:16cd wW
    db   $ff, $00, $00, $00, $50, $01                  ;; 00:16cf .??w..
    dw   $0040                                         ;; 00:16d5 wW
    db   $ff, $00, $00, $0c, $f0, $00, $80, $00        ;; 00:16d7 .??w....
    db   $ff, $00, $00, $0d, $f0, $00                  ;; 00:16df .??w..
    dw   $00f0                                         ;; 00:16e5 wW
    db   $ff, $00, $00, $0e, $30, $00                  ;; 00:16e7 .??w..
    dw   $0030                                         ;; 00:16ed wW
    db   $ff, $00, $00
.data_00_16f2:
    db   $0f, $20, $01, $80, $00        ;; 00:16ef .??w....
    db   $ff, $00, $00, $10, $20, $00, $30, $01        ;; 00:16f7 .???????
    db   $ff, $00, $00, $11, $30, $01, $60, $00        ;; 00:16ff ???w...W
    db   $ff, $00, $00, $01, $60, $09                  ;; 00:1707 .??w..
    dw   $0400                                         ;; 00:170d wW
    db   $ff, $00, $00, $01, $a0, $07, $00, $01        ;; 00:170f .???????
    db   $ff, $00, $00, $01, $c8, $02, $80, $00        ;; 00:1717 ???w....
    db   $ff, $00, $00
.data_00_1722:
    db   $12, $c0, $00, $60, $02        ;; 00:171f .???????
    db   $ff, $00, $00, $14, $20, $00, $80, $00        ;; 00:1727 ????????
    db   $ff, $00, $00, $15, $20, $01, $30, $01        ;; 00:172f ????????
    db   $ff, $00, $00, $16, $20, $00, $e0, $01        ;; 00:1737 ????????
    db   $ff, $00, $00, $16, $20, $01, $e0, $01        ;; 00:173f ????????
    db   $ff, $00, $00, $17, $48, $00, $60, $00        ;; 00:1747 ????????
    db   $ff, $00, $00, $02, $98, $02, $b0, $02        ;; 00:174f ????????
    db   $ff, $00, $00, $13, $18, $00, $68, $00        ;; 00:1757 ????????
    db   $ff, $00, $00, $13, $b8, $02, $68, $00        ;; 00:175f ????????
    db   $ff, $00, $00, $12, $10, $00, $cc, $00        ;; 00:1767 ????????
    db   $ff, $00, $00, $12, $38, $02, $10, $00        ;; 00:176f ????????
    db   $ff, $00, $00, $02, $28, $02, $b0, $02        ;; 00:1777 ????????
    db   $ff, $00, $00, $02, $68, $02, $d0, $01        ;; 00:177f ????????
    db   $ff, $00, $00, $02, $d8, $00, $40, $01        ;; 00:1787 ????????
    db   $ff, $00, $00, $02, $f8, $01, $80, $00        ;; 00:178f ????????
    db   $ff, $00, $00, $02, $28, $00, $50, $00        ;; 00:1797 ????????
    db   $ff, $00, $00, $18, $50, $00, $70, $00        ;; 00:179f ????????
    db   $ff, $00, $00, $17, $50, $00, $10, $00        ;; 00:17a7 ????????
    db   $ff, $00, $00, $1a, $10, $00, $d8, $02        ;; 00:17af ????????
    db   $ff, $00, $00, $12, $70, $02, $2c, $02        ;; 00:17b7 ????????
    db   $ff, $00, $00, $19, $a0, $00, $80, $02        ;; 00:17bf ????????
    db   $ff, $00, $00, $14, $a0, $00, $10, $00        ;; 00:17c7 ????????
    db   $ff, $00, $00, $02, $08, $01, $50, $02        ;; 00:17cf ????????
    db   $ff, $00, $00, $02, $a8, $02, $d0, $01        ;; 00:17d7 ????????
    db   $ff, $00, $00
.data_00_17e2:
    db   $1b, $10, $00, $00, $03        ;; 00:17df ????????
    db   $05, $00, $00, $1d, $54, $04, $10, $00        ;; 00:17e7 ????????
    db   $ff, $00, $00, $1d, $54, $04, $10, $00        ;; 00:17ef ????????
    db   $ff, $00, $00, $1c, $10, $00, $40, $01        ;; 00:17f7 ????????
    db   $04, $00, $00, $1b, $30, $03, $00, $03        ;; 00:17ff ????????
    db   $03, $00, $00, $03, $60, $02, $d0, $00        ;; 00:1807 ????????
    db   $00, $00, $00, $03, $48, $00, $10, $01        ;; 00:180f ????????
    db   $ff, $00, $00, $1e, $10, $00, $78, $00        ;; 00:1817 ????????
    db   $ff, $00, $00, $1b, $ec, $00, $60, $02        ;; 00:181f ????????
    db   $ff, $00, $00, $1f, $08, $00, $70, $00        ;; 00:1827 ????????
    db   $0a, $00, $00, $1c, $30, $06, $40, $01        ;; 00:182f ????????
    db   $09, $00, $00, $20, $10, $00, $60, $01        ;; 00:1837 ????????
    db   $ff, $00, $00, $1b, $7c, $02, $60, $02        ;; 00:183f ????????
    db   $ff, $00, $00
.data_00_184a:
    db   $23, $10, $00, $70, $00        ;; 00:1847 ????????
    db   $ff, $00, $00, $04, $c0, $00, $50, $01        ;; 00:184f ????????
    db   $ff, $00, $00, $26, $10, $00, $70, $00        ;; 00:1857 ????????
    db   $ff, $00, $00, $04, $10, $01, $50, $01        ;; 00:185f ????????
    db   $ff, $00, $00, $27, $10, $00, $00, $01        ;; 00:1867 ????????
    db   $ff, $00, $00, $04, $98, $01, $a0, $00        ;; 00:186f ????????
    db   $ff, $00, $00, $28, $10, $00, $70, $00        ;; 00:1877 ????????
    db   $ff, $00, $00, $04, $f0, $01, $50, $01        ;; 00:187f ????????
    db   $ff, $00, $00, $22, $30, $01, $90, $00        ;; 00:1887 ????????
    db   $ff, $00, $00, $21, $aa, $01, $98, $00        ;; 00:188f ????????
    db   $ff, $00, $00, $21, $10, $00, $40, $01        ;; 00:1897 ????????
    db   $0b, $00, $00, $04, $70, $02, $50, $01        ;; 00:189f ????????
    db   $0a, $00, $00, $24, $10, $00, $00, $01        ;; 00:18a7 ????????
    db   $0d, $00, $00, $25, $c0, $07, $48, $02        ;; 00:18af ????????
    db   $0c, $00, $00, $25, $28, $00, $10, $00        ;; 00:18b7 ????????
    db   $ff, $00, $00, $25, $68, $03, $10, $00        ;; 00:18bf ????????
    db   $ff, $00, $00, $27, $60, $00, $10, $01        ;; 00:18c7 ????????
    db   $ff, $00, $00
.data_00_18d2:
    db   $2b, $30, $00, $80, $02        ;; 00:18cf ????????
    db   $ff, $00, $00, $2c, $a0, $09, $80, $00        ;; 00:18d7 ????????
    db   $ff, $00, $00, $29, $30, $00, $c0, $01        ;; 00:18df ????????
    db   $ff, $00, $00, $05, $c0, $00, $c0, $01        ;; 00:18e7 ????????
    db   $ff, $00, $00, $05, $f0, $01, $c0, $01        ;; 00:18ef ????????
    db   $ff, $00, $00, $05, $20, $03, $c0, $01        ;; 00:18f7 ????????
    db   $ff, $00, $00, $29, $20, $00, $00, $01        ;; 00:18ff ????????
    db   $ff, $00, $00, $29, $e0, $02, $00, $01        ;; 00:1907 ????????
    db   $ff, $00, $00, $2a, $c0, $01, $80, $00        ;; 00:190f ????????
    db   $ff, $00, $00, $2a, $c0, $01, $80, $00        ;; 00:1917 ????????
    db   $ff, $00, $00, $2c, $e0, $03, $40, $01        ;; 00:191f ????????
    db   $ff, $00, $00, $30, $b0, $03, $40, $01        ;; 00:1927 ????????
    db   $ff, $00, $00, $30, $70, $01, $a0, $00        ;; 00:192f ????????
    db   $ff, $00, $00, $30, $50, $02, $30, $00        ;; 00:1937 ????????
    db   $ff, $00, $00, $30, $30, $03, $a0, $00        ;; 00:193f ????????
    db   $ff, $00, $00, $2d, $a0, $01, $f0, $00        ;; 00:1947 ????????
    db   $ff, $00, $00, $2e, $f0, $00, $00, $02        ;; 00:194f ????????
    db   $ff, $00, $00, $2f, $50, $00, $10, $03        ;; 00:1957 ????????
    db   $ff, $00, $00
.data_00_1962:
    db   $31, $c0, $0b, $a0, $02        ;; 00:195f ????????
    db   $ff, $00, $00, $06, $70, $00, $b0, $00        ;; 00:1967 ????????
    db   $ff, $00, $00, $32, $60, $00, $80, $00        ;; 00:196f ????????
    db   $ff, $00, $00, $06, $70, $00, $00, $01        ;; 00:1977 ????????
    db   $ff, $00, $00, $33, $e0, $00, $a0, $01        ;; 00:197f ????????
    db   $ff, $00, $00, $31, $80, $00, $20, $03        ;; 00:1987 ????????
    db   $ff, $00, $00, $34, $a0, $02, $c0, $01        ;; 00:198f ????????
    db   $ff, $00, $00, $31, $40, $04, $00, $01        ;; 00:1997 ????????
    db   $ff, $00, $00, $35, $50, $00, $60, $00        ;; 00:199f ????????
    db   $ff, $00, $00, $34, $a0, $02, $80, $00        ;; 00:19a7 ????????
    db   $ff, $00, $00
.data_00_19b2:
    db   $36, $20, $00, $30, $01        ;; 00:19af ????????
    db   $ff, $00, $00, $37, $20, $00, $30, $01        ;; 00:19b7 ????????
    db   $ff, $00, $00, $38, $20, $00, $30, $01        ;; 00:19bf ????????
    db   $ff, $00, $00, $07, $7c, $02, $b8, $02        ;; 00:19c7 ????????
    db   $ff, $00, $00, $07, $fc, $01, $b8, $01        ;; 00:19cf ????????
    db   $ff, $00, $00, $07, $8c, $01, $f8, $00        ;; 00:19d7 ????????
    db   $ff, $00, $00
.data_00_19e2:
    db   $39, $00, $01, $b0, $00        ;; 00:19df ????????
    db   $ff, $00, $00, $39, $30, $00, $f0, $00        ;; 00:19e7 ????????
    db   $ff, $00, $00, $39, $c0, $01, $f0, $00        ;; 00:19ef ????????
    db   $ff, $00, $00, $39, $00, $01, $20, $00        ;; 00:19f7 ????????
    db   $ff, $00, $00, $0b, $60, $02, $c0, $00        ;; 00:19ff ????????
    db   $ff, $00, $00, $3a, $38, $01, $80, $01        ;; 00:1a07 ????????
    db   $ff, $00, $00, $3b, $38, $01, $80, $01        ;; 00:1a0f ????????
    db   $ff, $00, $00, $3c, $78, $00, $68, $00        ;; 00:1a17 ????????
    db   $ff, $00, $00                                 ;; 00:1a1f ???

call_00_1a22_LoadInitialBgMap:
; Initialize Background Map Rows
; Loops 22 times ($16), each time calling LoadBgMapInitial2, then increments the map’s Y position by 8 pixels, 
; effectively filling the initial BG map rows. After finishing, it subtracts $b0 from Y to restore the pointer.
    ld   [wDC33_BgMapRelated], A                                    ;; 00:1a22 $ea $33 $dc
    ld   A, $16                                        ;; 00:1a25 $3e $16
.jr_00_1a27:
    push AF                                            ;; 00:1a27 $f5
    call call_00_1a46_LoadBgMapRow                                  ;; 00:1a28 $cd $46 $1a
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

call_00_1a46_LoadBgMapRow:
; Load One BG Map Row
; Loads a single horizontal row of background map tiles:
; Uses call_00_14e2 to convert pixel X/Y to tile indices.
; Computes tile/block pointers, switches to the correct VRAM/map banks, 
; copies tile and collision data into VRAM buffers, and restores banks.
; Handles both visual tiles and collision blocks.
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
    call call_00_14e2_ConvertXYToTileCoords                                  ;; 00:1a57 $cd $e2 $14
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
    ld   [wDC25], A                                    ;; 00:1a68 $ea $25 $dc
    or   A, L                                          ;; 00:1a6b $b5
    ld   [wDC21], A                                    ;; 00:1a6c $ea $21 $dc
    ld   A, H                                          ;; 00:1a6f $7c
    or   A, $98                                        ;; 00:1a70 $f6 $98
    ld   [wDC22], A                                    ;; 00:1a72 $ea $22 $dc
    ld   A, C                                          ;; 00:1a75 $79
    rrca                                               ;; 00:1a76 $0f
    rrca                                               ;; 00:1a77 $0f
    and  A, $02                                        ;; 00:1a78 $e6 $02
    ld   E, A                                          ;; 00:1a7a $5f
    ld   A, [wDC33_BgMapRelated]                                    ;; 00:1a7b $fa $33 $dc
    and  A, $7f                                        ;; 00:1a7e $e6 $7f
    or   A, E                                          ;; 00:1a80 $b3
    ld   E, A                                          ;; 00:1a81 $5f
    ld   D, $00                                        ;; 00:1a82 $16 $00
    push DE                                            ;; 00:1a84 $d5
    ld   A, [wDC33_BgMapRelated]                                    ;; 00:1a85 $fa $33 $dc
    bit  7, A                                          ;; 00:1a88 $cb $7f
    jp   NZ, .jp_00_1b40                               ;; 00:1a8a $c2 $40 $1b
    ld   A, [wDC01_MapBank]                                    ;; 00:1a8d $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1a90 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1a93 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:1aa5 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1aa8 $6e
    ld   H, $00                                        ;; 00:1aa9 $26 $00
    add  HL, DE                                        ;; 00:1aab $19
    ld   E, L                                          ;; 00:1aac $5d
    ld   D, H                                          ;; 00:1aad $54
    ld   HL, wDC25                                     ;; 00:1aae $21 $25 $dc
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
    ld   HL, wDC28                                     ;; 00:1ac8 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:1ada $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1add $6e
    ld   H, $00                                        ;; 00:1ade $26 $00
    add  HL, DE                                        ;; 00:1ae0 $19
    ld   E, L                                          ;; 00:1ae1 $5d
    ld   D, H                                          ;; 00:1ae2 $54
    ld   HL, wDC25                                     ;; 00:1ae3 $21 $25 $dc
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
    ld   HL, wDC22                                     ;; 00:1afe $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:1b01 $3a
    ld   C, [HL]                                       ;; 00:1b02 $4e
    and  A, $03                                        ;; 00:1b03 $e6 $03
    add  A, $c0                                        ;; 00:1b05 $c6 $c0
    ld   B, A                                          ;; 00:1b07 $47
    ld   HL, wDC25                                     ;; 00:1b08 $21 $25 $dc
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
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1b40 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1b43 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1b46 $21 $28 $dc
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
    ld   HL, wDC27                                     ;; 00:1b58 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1b5b $6e
    ld   H, $00                                        ;; 00:1b5c $26 $00
    add  HL, DE                                        ;; 00:1b5e $19
    ld   E, L                                          ;; 00:1b5f $5d
    ld   D, H                                          ;; 00:1b60 $54
    ld   HL, wDC25                                     ;; 00:1b61 $21 $25 $dc
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
    ld   HL, wDC22                                     ;; 00:1b7b $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:1b7e $3a
    ld   C, [HL]                                       ;; 00:1b7f $4e
    and  A, $03                                        ;; 00:1b80 $e6 $03
    add  A, $c0                                        ;; 00:1b82 $c6 $c0
    ld   B, A                                          ;; 00:1b84 $47
    ld   HL, wDC25                                     ;; 00:1b85 $21 $25 $dc
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
; Using the current level number (wDC1E_CurrentLevelNumber) and position (wD80E/wD810), 
; scans a table (.data_00_1c33_DoorLocationsByMap) for proximity to door trigger points. If within a bounding box, 
; writes trigger data to wDCC1_EnterDoorRelated1/wDCC2_EnterDoorRelated2, sets wDC69_PlayerSpawnIdInLevel, and marks wDB6A_WarpFlags flag. 
; Skips special levels $05 and $0B.
; Purpose: Used to enter doors after pressing Up on Dpad
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:1bbc $fa $1e $dc
    cp   A, $05                                        ;; 00:1bbf $fe $05
    ret  Z                                             ;; 00:1bc1 $c8
    cp   A, $0b                                        ;; 00:1bc2 $fe $0b
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
    ld   [wDCC1_EnterDoorRelated1], A                                    ;; 00:1bdf $ea $c1 $dc
    ld   A, [HL+]                                      ;; 00:1be2 $2a
    ld   [wDCC2_EnterDoorRelated2], A                                    ;; 00:1be3 $ea $c2 $dc
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
    cp   A, $10                                        ;; 00:1c0c $fe $10
    jr   C, .jr_00_1c16                                ;; 00:1c0e $38 $06
.jr_00_1c10:
    ld   A, [HL]                                       ;; 00:1c10 $7e
    cp   A, $ff                                        ;; 00:1c11 $fe $ff
    jr   NZ, .jr_00_1bde                               ;; 00:1c13 $20 $c9
    ret                                                ;; 00:1c15 $c9
.jr_00_1c16:
    ld   A, [wDCC2_EnterDoorRelated2]                                    ;; 00:1c16 $fa $c2 $dc
    cp   A, $ff                                        ;; 00:1c19 $fe $ff
    jr   Z, .jr_00_1c27                                ;; 00:1c1b $28 $0a
    ld   E, A                                          ;; 00:1c1d $5f
    ld   D, $00                                        ;; 00:1c1e $16 $00
    ld   HL, wDCB1_LevelTriggerBuffer                                     ;; 00:1c20 $21 $b1 $dc
    add  HL, DE                                        ;; 00:1c23 $19
    ld   A, [HL]                                       ;; 00:1c24 $7e
    and  A, A                                          ;; 00:1c25 $a7
    ret  Z                                             ;; 00:1c26 $c8
.jr_00_1c27:
    ld   A, [wDCC1_EnterDoorRelated1]                                    ;; 00:1c27 $fa $c1 $dc
    ld   [wDC69_PlayerSpawnIdInLevel], A                                    ;; 00:1c2a $ea $69 $dc
    ld   HL, wDB6A_WarpFlags                                     ;; 00:1c2d $21 $6a $db
    set  2, [HL]                                       ;; 00:1c30 $cb $d6
    ret                                                ;; 00:1c32 $c9
.data_00_1c33_DoorLocationsByMap:
    dw   .data_00_1cad, .data_00_1cd5, .data_00_1cf6, $0000        ;; 00:1c33 ....????
    dw   .data_00_1d5c, .data_00_1d9f, .data_00_1e08, .data_00_1e4a        ;; 00:1c3b ????????
    dw   $0000, $0000, $0000, .data_00_1e72        ;; 00:1c43 ????????
    dw   .data_00_1cc0, .data_00_1cc7, .data_00_1cce, .data_00_1ce8        ;; 00:1c4b ........
    dw   .data_00_1cef, $0000, $0000, .data_00_1d27        ;; 00:1c53 ????????
    dw   .data_00_1d34, .data_00_1d3b, .data_00_1d42, $0000        ;; 00:1c5b ????????
    dw   $0000, $0000, $0000, .data_00_1d4f        ;; 00:1c63 ????????
    dw   $0000, $0000, $0000, $0000        ;; 00:1c6b ????????
    dw   $0000, .data_00_1d75, .data_00_1d7c, .data_00_1d83        ;; 00:1c73 ????????
    dw   $0000, $0000, .data_00_1d8a, .data_00_1d91        ;; 00:1c7b ????????
    dw   .data_00_1d98, .data_00_1db2, .data_00_1dbf, .data_00_1dc6        ;; 00:1c83 ????????
    dw   .data_00_1dcd, .data_00_1dda, .data_00_1de1, .data_00_1de8        ;; 00:1c8b ????????
    dw   .data_00_1def, .data_00_1e15, .data_00_1e28, .data_00_1e2f        ;; 00:1c93 ????????
    dw   .data_00_1e36, .data_00_1e43, .data_00_1e5d, .data_00_1e64        ;; 00:1c9b ????????
    dw   .data_00_1e6b, .data_00_1e79, .data_00_1e92, .data_00_1e99        ;; 00:1ca3 ????????
    dw   $0000
.data_00_1cad:
    db   $03, $ff, $b0, $01, $f0, $00        ;; 00:1cab ??w...??
    db   $04, $ff, $50, $00, $70, $00, $05, $ff        ;; 00:1cb3 w...??w.
    db   $50, $01, $40, $00, $ff
.data_00_1cc0:
    db   $00, $ff, $f0        ;; 00:1cbb ..??.w..
    db   $00, $80, $00, $ff
.data_00_1cc7:
    db   $01, $ff, $f0, $00        ;; 00:1cc3 .???w...
    db   $f0, $00, $ff
.data_00_1cce:
    db   $02, $ff, $30, $00, $30        ;; 00:1ccb ???w...?
    db   $00, $ff
.data_00_1cd5:
    db   $00, $ff, $60, $09, $00, $04        ;; 00:1cd3 ??w...??
    db   $01, $ff, $a0, $07, $00, $01, $02, $ff        ;; 00:1cdb ....??w.
    db   $c8, $02, $80, $00, $ff
.data_00_1ce8:
    db   $03, $ff, $20        ;; 00:1ce3 ..??.w..
    db   $01, $80, $00, $ff
.data_00_1cef:
    db   $04, $ff, $20, $00        ;; 00:1ceb .??.????
    db   $30, $01, $ff
.data_00_1cf6:
    db   $00, $ff, $98, $02, $b0        ;; 00:1cf3 ????????
    db   $02, $01, $ff, $28, $02, $b0, $02, $02        ;; 00:1cfb ????????
    db   $ff, $68, $02, $d0, $01, $03, $ff, $d8        ;; 00:1d03 ????????
    db   $00, $40, $01, $04, $ff, $f8, $01, $80        ;; 00:1d0b ????????
    db   $00, $05, $ff, $28, $00, $50, $00, $17        ;; 00:1d13 ????????
    db   $ff, $08, $01, $50, $02, $16, $ff, $a8        ;; 00:1d1b ????????
    db   $02, $d0, $01, $ff
.data_00_1d27:
    db   $09, $ff, $18, $00        ;; 00:1d23 ????????
    db   $68, $00, $0a, $ff, $b8, $02, $68, $00        ;; 00:1d2b ????????
    db   $ff
.data_00_1d34:
    db   $0b, $ff, $20, $00, $80, $00, $ff        ;; 00:1d33 ????????
.data_00_1d3b:
    db   $0c, $ff, $20, $01, $30, $01, $ff
.data_00_1d42:
    db   $0d        ;; 00:1d3b ????????
    db   $ff, $20, $00, $e0, $01, $0e, $ff, $20        ;; 00:1d43 ????????
    db   $01, $e0, $01, $ff
.data_00_1d4f:
    db   $07, $00, $ec, $00        ;; 00:1d4b ????????
    db   $60, $02, $0b, $01, $7c, $02, $60, $02        ;; 00:1d53 ????????
    db   $ff
.data_00_1d5c:
    db   $00, $ff, $c0, $00, $50, $01, $02        ;; 00:1d5b ????????
    db   $ff, $10, $01, $50, $01, $04, $ff, $98        ;; 00:1d63 ????????
    db   $01, $a0, $00, $06, $ff, $f0, $01, $50        ;; 00:1d6b ????????
    db   $01, $ff
.data_00_1d75:
    db   $08, $ff, $aa, $01, $98, $00        ;; 00:1d73 ????????
    db   $ff
.data_00_1d7c:
    db   $09, $ff, $30, $01, $90, $00, $ff        ;; 00:1d7b ????????
.data_00_1d83:
    db   $01, $ff, $10, $00, $70, $00, $ff
.data_00_1d8a:
    db   $03        ;; 00:1d83 ????????
    db   $ff, $10, $00, $70, $00, $ff
.data_00_1d91:
    db   $05, $ff        ;; 00:1d8b ????????
    db   $10, $00, $00, $01, $ff
.data_00_1d98:
    db   $07, $ff, $10        ;; 00:1d93 ????????
    db   $00, $70, $00, $ff
.data_00_1d9f:
    db   $00, $ff, $c0, $00        ;; 00:1d9b ????????
    db   $c0, $01, $01, $ff, $f0, $01, $c0, $01        ;; 00:1da3 ????????
    db   $02, $ff, $20, $03, $c0, $01, $ff
.data_00_1db2:
    db   $05        ;; 00:1dab ????????
    db   $ff, $30, $00, $c0, $01, $09, $ff, $e0        ;; 00:1db3 ????????
    db   $02, $00, $01, $ff
.data_00_1dbf:
    db   $07, $ff, $c0, $01        ;; 00:1dbb ????????
    db   $80, $00, $ff
.data_00_1dc6:
    db   $03, $ff, $30, $00, $80        ;; 00:1dc3 ????????
    db   $02, $ff
.data_00_1dcd:
    db   $04, $ff, $a0, $09, $80, $00        ;; 00:1dcb ????????
    db   $0b, $05, $e0, $03, $40, $01, $ff
.data_00_1dda:
    db   $0c        ;; 00:1dd3 ????????
    db   $ff, $a0, $01, $f0, $00, $ff
.data_00_1de1:
    db   $0d, $ff        ;; 00:1ddb ????????
    db   $f0, $00, $00, $02, $ff
.data_00_1de8:
    db   $0e, $ff, $50        ;; 00:1de3 ????????
    db   $00, $10, $03, $ff
.data_00_1def:
    db   $0a, $0d, $b0, $03        ;; 00:1deb ????????
    db   $40, $01, $0f, $0a, $70, $01, $a0, $00        ;; 00:1df3 ????????
    db   $10, $0b, $50, $02, $30, $00, $11, $0c        ;; 00:1dfb ????????
    db   $30, $03, $a0, $00, $ff
.data_00_1e08:
    db   $00, $ff, $70        ;; 00:1e03 ????????
    db   $00, $b0, $00, $02, $ff, $70, $00, $00        ;; 00:1e0b ????????
    db   $01, $ff
.data_00_1e15:
    db   $01, $ff, $c0, $0b, $a0, $02        ;; 00:1e13 ????????
    db   $04, $ff, $80, $00, $20, $03, $06, $ff        ;; 00:1e1b ????????
    db   $40, $04, $00, $01, $ff
.data_00_1e28:
    db   $03, $ff, $60        ;; 00:1e23 ????????
    db   $00, $80, $00, $ff
.data_00_1e2f:
    db   $05, $ff, $e0, $00        ;; 00:1e2b ????????
    db   $a0, $01, $ff
.data_00_1e36:
    db   $07, $ff, $a0, $02, $c0        ;; 00:1e33 ????????
    db   $01, $08, $ff, $a0, $02, $80, $00, $ff        ;; 00:1e3b ????????
.data_00_1e43:
    db   $09, $ff, $50, $00, $60, $00, $ff
.data_00_1e4a:
    db   $00        ;; 00:1e43 ????????
    db   $ff, $7c, $02, $b8, $02, $01, $ff, $fc        ;; 00:1e4b ????????
    db   $01, $b8, $01, $02, $ff, $8c, $01, $f8        ;; 00:1e53 ????????
    db   $00, $ff
.data_00_1e5d:
    db   $03, $ff, $20, $00, $30, $01        ;; 00:1e5b ????????
    db   $ff
.data_00_1e64:
    db   $04, $ff, $20, $00, $30, $01, $ff        ;; 00:1e63 ????????
.data_00_1e6b:
    db   $05, $ff, $20, $00, $30, $01, $ff
.data_00_1e72:
    db   $00, $00, $60, $02, $c0, $00, $ff ;; 00:1e6b ????????
.data_00_1e79:
    db   $05, $ff        ;; 00:1e73 ????????
    db   $30, $00, $f0, $00, $04, $ff, $00, $01        ;; 00:1e7b ????????
    db   $b0, $00, $06, $01, $c0, $01, $f0, $00        ;; 00:1e83 ????????
    db   $07, $02, $00, $01, $20, $00, $ff
.data_00_1e92:
    db   $01        ;; 00:1e8b ????????
    db   $ff, $38, $01, $80, $01, $ff
.data_00_1e99:
    db   $02, $ff        ;; 00:1e93 ????????
    db   $38, $01, $80, $01, $ff                       ;; 00:1e9b ?????

call_00_1ea0_LoadAndRunMissionPreviewCutscene:
; Uses the current level number (wDC1E_CurrentLevelNumber) and sub-index (wDC5A_MissionNumberSelected) 
; to select an entry from .data_00_1fc0.
; Retrieves a pointer from .data_00_1ff0 to a level setup script (data_2014, 202a, 2040, …).
; Temporarily stores the current level ID, loads a new one from the script, and swaps 
; banks to copy in the proper level/map data (call_03_6c89_LoadMapData, call_03_6203_LoadLevelBoundariesFromId, etc.).
; Sets the player’s starting X/Y positions and various working variables.

; Enters a loop that:
; Waits for inputs and updates the map
; Calls call_00_217f_ProcessCutsceneMovement (movement handler below) and updates objects (call_02_7152_UpdateAllObjects).
; Spawns any queued objects (call_00_35fa_WaitForLineThenSpawnObject).
; Decrements timing counters until the script says to advance or exit.

; After finishing, restores the previous level ID and player positions, 
; then copies level data again for the new state.
; Usage: Core routine for loading and running scripted level transitions—used for mission preview cutscenes, 
; changing areas while preserving player state.
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:1ea0 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1ea3 $6e
    ld   H, $00                                        ;; 00:1ea4 $26 $00
    add  HL, HL                                        ;; 00:1ea6 $29
    add  HL, HL                                        ;; 00:1ea7 $29
    ld   DE, .data_00_1fc0                                     ;; 00:1ea8 $11 $c0 $1f
    add  HL, DE                                        ;; 00:1eab $19
    ld   A, [wDC5A_MissionNumberSelected]                                    ;; 00:1eac $fa $5a $dc
    ld   E, A                                          ;; 00:1eaf $5f
    ld   D, $00                                        ;; 00:1eb0 $16 $00
    add  HL, DE                                        ;; 00:1eb2 $19
    ld   A, [HL]                                       ;; 00:1eb3 $7e
    cp   A, $ff                                        ;; 00:1eb4 $fe $ff
    ret  Z                                             ;; 00:1eb6 $c8
    ld   L, A                                          ;; 00:1eb7 $6f
    ld   H, $00                                        ;; 00:1eb8 $26 $00
    add  HL, HL                                        ;; 00:1eba $29
    ld   DE, .data_00_1ff0                                     ;; 00:1ebb $11 $f0 $1f
    add  HL, DE                                        ;; 00:1ebe $19
    ld   E, [HL]                                       ;; 00:1ebf $5e
    inc  HL                                            ;; 00:1ec0 $23
    ld   D, [HL]                                       ;; 00:1ec1 $56
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:1ec2 $fa $6c $db
    push AF                                            ;; 00:1ec5 $f5
    ld   A, [DE]                                       ;; 00:1ec6 $1a
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:1ec7 $ea $6c $db
    inc  DE                                            ;; 00:1eca $13
    ld   HL, wD80E_PlayerXPosition                                     ;; 00:1ecb $21 $0e $d8
    ld   C, [HL]                                       ;; 00:1ece $4e
    ld   A, [DE]                                       ;; 00:1ecf $1a
    ld   [HL+], A                                      ;; 00:1ed0 $22
    inc  DE                                            ;; 00:1ed1 $13
    ld   B, [HL]                                       ;; 00:1ed2 $46
    ld   A, [DE]                                       ;; 00:1ed3 $1a
    ld   [HL+], A                                      ;; 00:1ed4 $22
    inc  DE                                            ;; 00:1ed5 $13
    push BC                                            ;; 00:1ed6 $c5
    ld   C, [HL]                                       ;; 00:1ed7 $4e
    ld   A, [DE]                                       ;; 00:1ed8 $1a
    ld   [HL+], A                                      ;; 00:1ed9 $22
    inc  DE                                            ;; 00:1eda $13
    ld   B, [HL]                                       ;; 00:1edb $46
    ld   A, [DE]                                       ;; 00:1edc $1a
    ld   [HL], A                                       ;; 00:1edd $77
    inc  DE                                            ;; 00:1ede $13
    push BC                                            ;; 00:1edf $c5
    push DE                                            ;; 00:1ee0 $d5
    xor  A, A                                          ;; 00:1ee1 $af
    ld   [wDCA7_DrawGexFlag], A                                    ;; 00:1ee2 $ea $a7 $dc
    ld   A, $00                                        ;; 00:1ee5 $3e $00
    ld   [wDC78_PlayerActionIdRelated], A                                    ;; 00:1ee7 $ea $78 $dc
    call call_00_04fb                                  ;; 00:1eea $cd $fb $04
    farcall call_03_6c89_LoadMapData
    farcall call_03_6203_LoadLevelBoundariesFromId
    call call_00_10de_UpdatePlayerMapWindow                                  ;; 00:1f03 $cd $de $10
    call call_00_1056_LoadFullMap                                  ;; 00:1f06 $cd $56 $10
    farcall call_02_708f_InitObjectsAndSpawnPlayer
    call call_00_0513                                  ;; 00:1f14 $cd $13 $05
    pop  HL                                            ;; 00:1f17 $e1
    ld   E, [HL]                                       ;; 00:1f18 $5e
    inc  HL                                            ;; 00:1f19 $23
    ld   D, [HL]                                       ;; 00:1f1a $56
    inc  HL                                            ;; 00:1f1b $23
    ld   A, E                                          ;; 00:1f1c $7b
    or   A, D                                          ;; 00:1f1d $b2
    jr   Z, .jr_00_1f72                                ;; 00:1f1e $28 $52
    push HL                                            ;; 00:1f20 $e5
    ld   L, E                                          ;; 00:1f21 $6b
    ld   H, D                                          ;; 00:1f22 $62
    xor  A, A                                          ;; 00:1f23 $af
    ld   [wDCE0_MissionPreviewCutsceneMovementFlags], A                                    ;; 00:1f24 $ea $e0 $dc
    ld   [wDCE0_MissionPreviewCutsceneMovementFlags+1], A                                    ;; 00:1f27 $ea $e1 $dc
    ld   A, [HL+]                                      ;; 00:1f2a $2a
.jr_00_1f2b:
    ld   [wDC81_CurrentInputsAlt], A                                    ;; 00:1f2b $ea $81 $dc
    ld   A, [HL+]                                      ;; 00:1f2e $2a
    ld   [wDCDE_MissionPreviewCutsceneRelated], A                                    ;; 00:1f2f $ea $de $dc
    ld   A, [HL+]                                      ;; 00:1f32 $2a
    ld   [wDCDE_MissionPreviewCutsceneRelated+1], A                                    ;; 00:1f33 $ea $df $dc
    push HL                                            ;; 00:1f36 $e5
.jr_00_1f37:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:1f37 $fa $d7 $da
    and  A, A                                          ;; 00:1f3a $a7
    jr   Z, .jr_00_1f42                                ;; 00:1f3b $28 $05
    pop  HL                                            ;; 00:1f3d $e1
    pop  HL                                            ;; 00:1f3e $e1
    jp   .jp_00_1f9f                                   ;; 00:1f3f $c3 $9f $1f
.jr_00_1f42:
    call call_00_0b92_WaitForInterrupt                                  ;; 00:1f42 $cd $92 $0b
    call call_00_217f_ProcessCutsceneMovement                                  ;; 00:1f45 $cd $7f $21
    farcall call_02_7152_UpdateAllObjects
    call call_00_11c8_LoadBgMapDirtyRegions                                  ;; 00:1f53 $cd $c8 $11
    call call_00_35fa_WaitForLineThenSpawnObject                                  ;; 00:1f56 $cd $fa $35
    call call_00_08f8_SetupObjectVRAMTransfer                                  ;; 00:1f59 $cd $f8 $08
    ld   HL, wDCDE_MissionPreviewCutsceneRelated                                     ;; 00:1f5c $21 $de $dc
    ld   A, [HL]                                       ;; 00:1f5f $7e
    sub  A, $01                                        ;; 00:1f60 $d6 $01
    ld   [HL+], A                                      ;; 00:1f62 $22
    ld   C, A                                          ;; 00:1f63 $4f
    ld   A, [HL]                                       ;; 00:1f64 $7e
    sbc  A, $00                                        ;; 00:1f65 $de $00
    ld   [HL], A                                       ;; 00:1f67 $77
    or   A, C                                          ;; 00:1f68 $b1
    jr   NZ, .jr_00_1f37                               ;; 00:1f69 $20 $cc
    pop  HL                                            ;; 00:1f6b $e1
    ld   A, [HL+]                                      ;; 00:1f6c $2a
    cp   A, $ff                                        ;; 00:1f6d $fe $ff
    jr   NZ, .jr_00_1f2b                               ;; 00:1f6f $20 $ba
    pop  HL                                            ;; 00:1f71 $e1
.jr_00_1f72:
    ld   A, [HL+]                                      ;; 00:1f72 $2a
    ld   H, [HL]                                       ;; 00:1f73 $66
    ld   L, A                                          ;; 00:1f74 $6f
    or   A, H                                          ;; 00:1f75 $b4
    jr   Z, .jr_00_1f78                                ;; 00:1f76 $28 $00
.jr_00_1f78:
    ld   A, $b4                                        ;; 00:1f78 $3e $b4
.jr_00_1f7a:
    push AF                                            ;; 00:1f7a $f5
    call call_00_0b92_WaitForInterrupt                                  ;; 00:1f7b $cd $92 $0b
    farcall call_02_7152_UpdateAllObjects
    call call_00_11c8_LoadBgMapDirtyRegions                                  ;; 00:1f89 $cd $c8 $11
    call call_00_35fa_WaitForLineThenSpawnObject                                  ;; 00:1f8c $cd $fa $35
    call call_00_08f8_SetupObjectVRAMTransfer                                  ;; 00:1f8f $cd $f8 $08
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:1f92 $fa $d7 $da
    and  A, A                                          ;; 00:1f95 $a7
    jr   Z, .jr_00_1f9b                                ;; 00:1f96 $28 $03
    pop  AF                                            ;; 00:1f98 $f1
    jr   .jp_00_1f9f                                   ;; 00:1f99 $18 $04
.jr_00_1f9b:
    pop  AF                                            ;; 00:1f9b $f1
    dec  A                                             ;; 00:1f9c $3d
    jr   NZ, .jr_00_1f7a                               ;; 00:1f9d $20 $db
.jp_00_1f9f:
    ld   A, $01                                        ;; 00:1f9f $3e $01
    ld   [wDCA7_DrawGexFlag], A                                    ;; 00:1fa1 $ea $a7 $dc
    ld   HL, wD810_PlayerYPosition+1                                     ;; 00:1fa4 $21 $11 $d8
    pop  BC                                            ;; 00:1fa7 $c1
    ld   [HL], B                                       ;; 00:1fa8 $70
    dec  HL                                            ;; 00:1fa9 $2b
    ld   [HL], C                                       ;; 00:1faa $71
    dec  HL                                            ;; 00:1fab $2b
    pop  BC                                            ;; 00:1fac $c1
    ld   [HL], B                                       ;; 00:1fad $70
    dec  HL                                            ;; 00:1fae $2b
    ld   [HL], C                                       ;; 00:1faf $71
    pop  AF                                            ;; 00:1fb0 $f1
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:1fb1 $ea $6c $db
    farcall call_03_6c89_LoadMapData
    ret                                                ;; 00:1fbf $c9
.data_00_1fc0:
    db   $ff, $ff, $ff, $ff, $00, $01, $02, $ff        ;; 00:1fc0 ...?www?
    db   $03, $04, $05, $ff, $06, $07, $08, $ff        ;; 00:1fc8 ????????
    db   $09, $0a, $0b, $ff, $0c, $0d, $0e, $ff        ;; 00:1fd0 ????????
    db   $0f, $10, $11, $ff, $ff, $ff, $ff, $ff        ;; 00:1fd8 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1fe0 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1fe8 ????????
.data_00_1ff0:
    dw   .data_00_2014                                 ;; 00:1ff0 pP
    dw   .data_00_202a                                 ;; 00:1ff2 pP
    dw   .data_00_2040                                 ;; 00:1ff4 pP
    db   $53, $20, $66, $20, $79, $20, $89, $20        ;; 00:1ff6 ????????
    db   $9c, $20, $b2, $20, $c5, $20, $db, $20        ;; 00:1ffe ????????
    db   $ee, $20, $01, $21, $1d, $21, $2d, $21        ;; 00:2006 ????????
    db   $43, $21, $53, $21, $69, $21                  ;; 00:200e ??????
.data_00_2014:
    db   $01, $80, $07, $f0, $02, $1d, $20, $00        ;; 00:2014 w.......
    db   $00, $00, $3c, $00, $10, $d0, $00, $40        ;; 00:201c ........
    db   $e0, $01, $00, $3c, $00, $ff                  ;; 00:2024 ......
.data_00_202a:
    db   $01, $50, $06, $60, $02, $33, $20, $00        ;; 00:202a w.......
    db   $00, $00, $3c, $00, $90, $a0, $01, $10        ;; 00:2032 ........
    db   $70, $01, $00, $3c, $00, $ff                  ;; 00:203a ......
.data_00_2040:
    db   $11, $30, $01, $60, $00, $49, $20, $00        ;; 00:2040 w.......
    db   $00, $00, $3c, $00, $20, $e0, $00, $00        ;; 00:2048 ........
    db   $3c, $00, $ff, $12, $c0, $00, $40, $02        ;; 00:2050 ...?????
    db   $5c, $20, $00, $00, $00, $3c, $00, $50        ;; 00:2058 ????????
    db   $70, $01, $00, $3c, $00, $ff, $02, $dc        ;; 00:2060 ????????
    db   $00, $a0, $02, $6f, $20, $00, $00, $00        ;; 00:2068 ????????
    db   $3c, $00, $40, $d8, $01, $00, $3c, $00        ;; 00:2070 ????????
    db   $ff, $18, $50, $00, $70, $00, $82, $20        ;; 00:2078 ????????
    db   $00, $00, $00, $3c, $00, $00, $3c, $00        ;; 00:2080 ????????
    db   $ff, $20, $90, $01, $60, $01, $92, $20        ;; 00:2088 ????????
    db   $00, $00, $00, $3c, $00, $10, $f0, $00        ;; 00:2090 ????????
    db   $00, $3c, $00, $ff, $03, $e0, $00, $10        ;; 00:2098 ????????
    db   $01, $a5, $20, $00, $00, $00, $3c, $00        ;; 00:20a0 ????????
    db   $10, $58, $00, $40, $a8, $00, $00, $3c        ;; 00:20a8 ????????
    db   $00, $ff, $1c, $50, $00, $40, $01, $bb        ;; 00:20b0 ????????
    db   $20, $00, $00, $00, $3c, $00, $10, $d0        ;; 00:20b8 ????????
    db   $02, $00, $3c, $00, $ff, $24, $78, $02        ;; 00:20c0 ????????
    db   $e8, $00, $ce, $20, $00, $00, $00, $3c        ;; 00:20c8 ????????
    db   $00, $10, $d8, $01, $50, $68, $00, $00        ;; 00:20d0 ????????
    db   $3c, $00, $ff, $21, $50, $00, $28, $01        ;; 00:20d8 ????????
    db   $e4, $20, $00, $00, $00, $3c, $00, $10        ;; 00:20e0 ????????
    db   $e0, $00, $00, $3c, $00, $ff, $25, $f8        ;; 00:20e8 ????????
    db   $06, $50, $02, $f7, $20, $00, $00, $00        ;; 00:20f0 ????????
    db   $3c, $00, $10, $88, $00, $00, $3c, $00        ;; 00:20f8 ????????
    db   $ff, $30, $70, $01, $10, $01, $0a, $21        ;; 00:2100 ????????
    db   $00, $00, $00, $3c, $00, $40, $70, $00        ;; 00:2108 ????????
    db   $50, $50, $00, $10, $20, $01, $90, $50        ;; 00:2110 ????????
    db   $00, $00, $3c, $00, $ff, $2b, $a8, $05        ;; 00:2118 ????????
    db   $80, $00, $26, $21, $00, $00, $00, $3c        ;; 00:2120 ????????
    db   $00, $00, $3c, $00, $ff, $29, $80, $01        ;; 00:2128 ????????
    db   $a0, $01, $36, $21, $00, $00, $00, $3c        ;; 00:2130 ????????
    db   $00, $40, $30, $01, $20, $10, $01, $00        ;; 00:2138 ????????
    db   $3c, $00, $ff, $35, $50, $00, $60, $00        ;; 00:2140 ????????
    db   $4c, $21, $00, $00, $00, $3c, $00, $00        ;; 00:2148 ????????
    db   $3c, $00, $ff, $32, $50, $03, $40, $00        ;; 00:2150 ????????
    db   $5c, $21, $00, $00, $00, $3c, $00, $80        ;; 00:2158 ????????
    db   $00, $01, $20, $d0, $01, $00, $3c, $00        ;; 00:2160 ????????
    db   $ff, $33, $50, $00, $80, $01, $72, $21        ;; 00:2168 ????????
    db   $00, $00, $00, $3c, $00, $10, $20, $02        ;; 00:2170 ????????
    db   $50, $40, $00, $00, $3c, $00, $ff             ;; 00:2178 ???????

call_00_217f_ProcessCutsceneMovement:
; Reads wDC81_CurrentInputsAlt (input flags).
; Writes either $10 or $00 to wDCE0_MissionPreviewCutsceneMovementFlags, mixes low bits into its second byte, then derives a movement step (C).
; Checks bits in wDC81_CurrentInputsAlt to adjust player position:
; Bit 4: move player right by C.
; Bit 5: move player left by C.
; Bit 7: move player down by C.
; Bit 6: move player up by C.
; Updates both low and high bytes of player X/Y position (wD80E–wD811) with proper carry/borrow handling.
; Usage: Low-level player movement updater—applies directional flags and speed accumulation each frame.
; This is used to move around the "camera" for the mission preview cutscenes
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 00:217f $fa $81 $dc
    and  A, A                                          ;; 00:2182 $a7
    jr   NZ, .jr_00_218c                               ;; 00:2183 $20 $07
    ld   HL, wDCE0_MissionPreviewCutsceneMovementFlags                                     ;; 00:2185 $21 $e0 $dc
    ld   [HL], $00                                     ;; 00:2188 $36 $00
    jr   .jr_00_2191                                   ;; 00:218a $18 $05
.jr_00_218c:
    ld   HL, wDCE0_MissionPreviewCutsceneMovementFlags                                     ;; 00:218c $21 $e0 $dc
    ld   [HL], $10                                     ;; 00:218f $36 $10
.jr_00_2191:
    ld   HL, wDCE0_MissionPreviewCutsceneMovementFlags                                     ;; 00:2191 $21 $e0 $dc
    ld   A, [HL+]                                      ;; 00:2194 $2a
    ld   C, A                                          ;; 00:2195 $4f
    ld   A, [HL]                                       ;; 00:2196 $7e
    and  A, $0f                                        ;; 00:2197 $e6 $0f
    add  A, C                                          ;; 00:2199 $81
    ld   [HL], A                                       ;; 00:219a $77
    swap A                                             ;; 00:219b $cb $37
    and  A, $0f                                        ;; 00:219d $e6 $0f
    ld   C, A                                          ;; 00:219f $4f
    ld   HL, wDC81_CurrentInputsAlt                                     ;; 00:21a0 $21 $81 $dc
    bit  4, [HL]                                       ;; 00:21a3 $cb $66
    jr   Z, .jr_00_21b6                                ;; 00:21a5 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21a7 $fa $0e $d8
    add  A, C                                          ;; 00:21aa $81
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21ab $ea $0e $d8
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:21ae $fa $0f $d8
    adc  A, $00                                        ;; 00:21b1 $ce $00
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 00:21b3 $ea $0f $d8
.jr_00_21b6:
    bit  5, [HL]                                       ;; 00:21b6 $cb $6e
    jr   Z, .jr_00_21c9                                ;; 00:21b8 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21ba $fa $0e $d8
    sub  A, C                                          ;; 00:21bd $91
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21be $ea $0e $d8
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:21c1 $fa $0f $d8
    sbc  A, $00                                        ;; 00:21c4 $de $00
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 00:21c6 $ea $0f $d8
.jr_00_21c9:
    bit  7, [HL]                                       ;; 00:21c9 $cb $7e
    jr   Z, .jr_00_21dc                                ;; 00:21cb $28 $0f
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21cd $fa $10 $d8
    add  A, C                                          ;; 00:21d0 $81
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21d1 $ea $10 $d8
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:21d4 $fa $11 $d8
    adc  A, $00                                        ;; 00:21d7 $ce $00
    ld   [wD810_PlayerYPosition+1], A                                    ;; 00:21d9 $ea $11 $d8
.jr_00_21dc:
    bit  6, [HL]                                       ;; 00:21dc $cb $76
    ret  Z                                             ;; 00:21de $c8
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21df $fa $10 $d8
    sub  A, C                                          ;; 00:21e2 $91
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21e3 $ea $10 $d8
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:21e6 $fa $11 $d8
    sbc  A, $00                                        ;; 00:21e9 $de $00
    ld   [wD810_PlayerYPosition+1], A                                    ;; 00:21eb $ea $11 $d8
    ret                                                ;; 00:21ee $c9
    