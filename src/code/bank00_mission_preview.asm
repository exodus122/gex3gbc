call_00_1ea0_MissionPreview_LoadAndRun:
; Uses the current level number (wDC1E_CurrentLevelID) and sub-index (wDC5A_MissionNumberSelected) 
; to select an entry from .data_00_1fc0.
; Retrieves a pointer from .data_00_1ff0 to a level setup script (data_2014, 202a, 2040, …).
; Temporarily stores the current level ID, loads a new one from the script, and swaps 
; banks to copy in the proper level/map data (call_03_6c89_LoadMapDataPtrs, call_03_6203_LoadLevelBoundariesFromId, etc.).
; Sets the player’s starting X/Y positions and various working variables.

; Enters a loop that:
; Waits for inputs and updates the map
; Calls call_00_217f_MissionPreview_UpdateMovement (movement handler below) and updates entities (call_02_7152_UpdateAllEntities).
; Spawns any queued entities (call_00_35fa_WaitForLineThenSpawnEntity).
; Decrements timing counters until the script says to advance or exit.

; After finishing, restores the previous level ID and player positions, 
; then copies level data again for the new state.
; Usage: Core routine for loading and running scripted level transitions—used for mission preview cutscenes, 
; changing areas while preserving player state.
    ld   HL, wDC1E_CurrentLevelID                                     ;; 00:1ea0 $21 $1e $dc
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
    ld   A, PLAYERACTION_SPAWN                                        ;; 00:1ee5 $3e $00
    ld   [wDC78_PlayerPendingActionId], A                                    ;; 00:1ee7 $ea $78 $dc
    call call_00_04fb                                  ;; 00:1eea $cd $fb $04
    farcall call_03_6c89_LoadMapDataPtrs
    farcall call_03_6203_LoadLevelBoundariesFromId
    call call_00_10de_BgMap_UpdateWindowFromPlayerPos                                  ;; 00:1f03 $cd $de $10
    call call_00_1056_BgMap_LoadFull                                  ;; 00:1f06 $cd $56 $10
    farcall call_02_708f_InitEntitiesAndSpawnPlayer
    call call_00_0513_DrawEntitiesWrapper                                  ;; 00:1f14 $cd $13 $05
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
    call call_00_217f_MissionPreview_UpdateMovement                                  ;; 00:1f45 $cd $7f $21
    farcall call_02_7152_UpdateAllEntities
    call call_00_11c8_BgMap_LoadDirtyRegions                                  ;; 00:1f53 $cd $c8 $11
    call call_00_35fa_WaitForLineThenSpawnEntity                                  ;; 00:1f56 $cd $fa $35
    call call_00_08f8_SetupEntityVRAMTransfer                                  ;; 00:1f59 $cd $f8 $08
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
    farcall call_02_7152_UpdateAllEntities
    call call_00_11c8_BgMap_LoadDirtyRegions                                  ;; 00:1f89 $cd $c8 $11
    call call_00_35fa_WaitForLineThenSpawnEntity                                  ;; 00:1f8c $cd $fa $35
    call call_00_08f8_SetupEntityVRAMTransfer                                  ;; 00:1f8f $cd $f8 $08
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
    farcall call_03_6c89_LoadMapDataPtrs
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

call_00_217f_MissionPreview_UpdateMovement:
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
    bit  PADF_RIGHT_BIT, [HL]                                       ;; 00:21a3 $cb $66
    jr   Z, .jr_00_21b6                                ;; 00:21a5 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21a7 $fa $0e $d8
    add  A, C                                          ;; 00:21aa $81
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21ab $ea $0e $d8
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:21ae $fa $0f $d8
    adc  A, $00                                        ;; 00:21b1 $ce $00
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 00:21b3 $ea $0f $d8
.jr_00_21b6:
    bit  PADF_LEFT_BIT, [HL]                                       ;; 00:21b6 $cb $6e
    jr   Z, .jr_00_21c9                                ;; 00:21b8 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21ba $fa $0e $d8
    sub  A, C                                          ;; 00:21bd $91
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21be $ea $0e $d8
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:21c1 $fa $0f $d8
    sbc  A, $00                                        ;; 00:21c4 $de $00
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 00:21c6 $ea $0f $d8
.jr_00_21c9:
    bit  PADF_DOWN_BIT, [HL]                                       ;; 00:21c9 $cb $7e
    jr   Z, .jr_00_21dc                                ;; 00:21cb $28 $0f
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21cd $fa $10 $d8
    add  A, C                                          ;; 00:21d0 $81
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21d1 $ea $10 $d8
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:21d4 $fa $11 $d8
    adc  A, $00                                        ;; 00:21d7 $ce $00
    ld   [wD810_PlayerYPosition+1], A                                    ;; 00:21d9 $ea $11 $d8
.jr_00_21dc:
    bit  PADF_UP_BIT, [HL]                                       ;; 00:21dc $cb $76
    ret  Z                                             ;; 00:21de $c8
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21df $fa $10 $d8
    sub  A, C                                          ;; 00:21e2 $91
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21e3 $ea $10 $d8
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:21e6 $fa $11 $d8
    sbc  A, $00                                        ;; 00:21e9 $de $00
    ld   [wD810_PlayerYPosition+1], A                                    ;; 00:21eb $ea $11 $d8
    ret                                                ;; 00:21ee $c9
    