call_03_6203_LoadLevelBoundariesFromId:
; Purpose: Given the current level ID, looks up and stores the level’s screen/window boundaries.
; Behavior:
; Reads wDB6C_CurrentMapId.
; Indexes .data_03_6210_MapBoundaryIndices and .data_03_62a4 tables.
; Fills a series of wDC34_MapBoundaryXMinLo–wDC43_MapBoundaryYMaxHiPlus0 registers with the level’s rectangle bounds 
; (left/right/top/bottom and offsets for scrolling and collision).
; Usage: Called whenever a new level or respawn is set to update collision/window limits.
    ld   HL, wDB6C_CurrentMapId                                     ;; 03:6203 $21 $6c $db
    ld   L, [HL]                                       ;; 03:6206 $6e
    ld   H, $00                                        ;; 03:6207 $26 $00
    ld   DE, .data_03_6210_MapBoundaryIndices                             ;; 03:6209 $11 $10 $62
    add  HL, DE                                        ;; 03:620c $19
    ld   C, [HL]                                       ;; 03:620d $4e
    jr   .jr_03_624d                                   ;; 03:620e $18 $3d
.data_03_6210_MapBoundaryIndices:
    db   $01, $02, $06, $10, $17, $20, $29, $2f        ;; 03:6210 ww??????
    db   $33, $34, $35, $36, $01, $01, $01, $03        ;; 03:6218 ????wwww
    db   $04, $05, $07, $08, $09, $0a, $0b, $0c        ;; 03:6220 ?w??????
    db   $0d, $0e, $0f, $11, $12, $13, $14, $15        ;; 03:6228 ????????
    db   $16, $18, $19, $1a, $1b, $1c, $1d, $1e        ;; 03:6230 ????????
    db   $1f, $21, $22, $23, $24, $25, $26, $27        ;; 03:6238 ????????
    db   $28, $2a, $2b, $2c, $2d, $2e, $30, $31        ;; 03:6240 ????????
    db   $32, $37, $38, $39, $3a                       ;; 03:6248 ?????
.jr_03_624d:
    ld   HL, wDC2A_MapBoundaryIndex                    ;; 03:624d $21 $2a $dc
    ld   [HL], C                                       ;; 03:6250 $71
    ld   L, C                                          ;; 03:6251 $69
    ld   H, $00                                        ;; 03:6252 $26 $00
    add  HL, HL                                        ;; 03:6254 $29
    add  HL, HL                                        ;; 03:6255 $29
    add  HL, HL                                        ;; 03:6256 $29
    ld   DE, .data_03_62a4                             ;; 03:6257 $11 $a4 $62
    add  HL, DE                                        ;; 03:625a $19
    ld   A, [HL+]                                      ;; 03:625b $2a
    ld   [wDC34_MapBoundaryXMinLo], A                                    ;; 03:625c $ea $34 $dc
    add  A, $10                                        ;; 03:625f $c6 $10
    ld   [wDC3C_MapBoundaryXMinLoPlus10], A                                    ;; 03:6261 $ea $3c $dc
    ld   A, [HL+]                                      ;; 03:6264 $2a
    ld   [wDC35_MapBoundaryXMinHi], A                                    ;; 03:6265 $ea $35 $dc
    adc  A, $00                                        ;; 03:6268 $ce $00
    ld   [wDC3D_MapBoundaryXMinHiPlus0], A                                    ;; 03:626a $ea $3d $dc
    ld   A, [HL+]                                      ;; 03:626d $2a
    ld   [wDC36_MapBoundaryXMaxLo], A                                    ;; 03:626e $ea $36 $dc
    add  A, $90                                        ;; 03:6271 $c6 $90
    ld   [wDC3E_MapBoundaryXMaxLoPlus90], A                                    ;; 03:6273 $ea $3e $dc
    ld   A, [HL+]                                      ;; 03:6276 $2a
    ld   [wDC37_MapBoundaryXMaxHi], A                                    ;; 03:6277 $ea $37 $dc
    adc  A, $00                                        ;; 03:627a $ce $00
    ld   [wDC3F_MapBoundaryXMaxHiPlus0], A                                    ;; 03:627c $ea $3f $dc
    ld   A, [HL+]                                      ;; 03:627f $2a
    ld   [wDC38_MapBoundaryYMinLo], A                                    ;; 03:6280 $ea $38 $dc
    add  A, $10                                        ;; 03:6283 $c6 $10
    ld   [wDC40_MapBoundaryYMinLoPlus10], A                                    ;; 03:6285 $ea $40 $dc
    ld   A, [HL+]                                      ;; 03:6288 $2a
    ld   [wDC39_MapBoundaryYMinHi], A                                    ;; 03:6289 $ea $39 $dc
    adc  A, $00                                        ;; 03:628c $ce $00
    ld   [wDC41_MapBoundaryYMinHiPlus00], A                                    ;; 03:628e $ea $41 $dc
    ld   A, [HL+]                                      ;; 03:6291 $2a
    ld   [wDC3A_MapBoundaryYMaxLo], A                                    ;; 03:6292 $ea $3a $dc
    add  A, $78                                        ;; 03:6295 $c6 $78
    ld   [wDC42_MapBoundaryYMaxLoPlus78], A                                    ;; 03:6297 $ea $42 $dc
    ld   A, [HL+]                                      ;; 03:629a $2a
    ld   [wDC3B_MapBoundaryYMaxHi], A                                    ;; 03:629b $ea $3b $dc
    adc  A, $00                                        ;; 03:629e $ce $00
    ld   [wDC43_MapBoundaryYMaxHiPlus0], A                                    ;; 03:62a0 $ea $43 $dc
    ret                                                ;; 03:62a3 $c9
.data_03_62a4:
    db   $00, $00, $00, $00, $04, $02, $73, $03        ;; 03:62a4 ????????
    db   $00, $00                                      ;; 03:62ac ..
    dw   $0140                                         ;; 03:62ae wW
    db   $00, $00                                      ;; 03:62b0 ..
    dw   $0090                                         ;; 03:62b2 wW
    db   $00, $00, $60, $09, $01, $00, $7f, $04        ;; 03:62b4 ........
    db   $00, $00                                      ;; 03:62bc ..
    dw   $00a0                                         ;; 03:62be wW
    db   $01, $00, $2f, $00, $00, $00, $a0, $00        ;; 03:62c0 ....????
    db   $b1, $00, $df, $00, $00, $00                  ;; 03:62c8 ????..
    dw   $00a0                                         ;; 03:62ce wW
    db   $00, $00, $00, $00, $00, $00, $30, $02        ;; 03:62d0 .W..????
    db   $01, $00, $4f, $02, $00, $00, $e0, $01        ;; 03:62d8 ????????
    db   $01, $00, $ef, $01, $00, $00, $30, $02        ;; 03:62e0 ????????
    db   $01, $00, $5f, $01, $00, $00, $a0, $00        ;; 03:62e8 ????????
    db   $01, $00, $2f, $00, $00, $00, $a0, $00        ;; 03:62f0 ????????
    db   $b1, $00, $df, $00, $00, $00, $a0, $00        ;; 03:62f8 ????????
    db   $61, $01, $8f, $01, $00, $00, $00, $00        ;; 03:6300 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 03:6308 ????????
    db   $00, $00, $00, $00, $00, $00, $a0, $00        ;; 03:6310 ????????
    db   $11, $02, $1f, $02, $00, $00, $e0, $01        ;; 03:6318 ????????
    db   $90, $02, $a0, $02, $00, $00, $d0, $01        ;; 03:6320 ????????
    db   $00, $00, $b0, $00, $00, $00, $a0, $02        ;; 03:6328 ????????
    db   $00, $00, $b0, $02, $00, $00, $a0, $05        ;; 03:6330 ????????
    db   $00, $00, $f0, $00, $00, $00, $00, $04        ;; 03:6338 ????????
    db   $00, $00, $b0, $00, $00, $00, $00, $00        ;; 03:6340 ????????
    db   $01, $00, $0f, $00, $00, $00, $a0, $00        ;; 03:6348 ????????
    db   $00, $00, $10, $00, $00, $00, $80, $02        ;; 03:6350 ????????
    db   $00, $00, $10, $01, $00, $00, $e0, $01        ;; 03:6358 ????????
    db   $00, $00, $f0, $00, $00, $00, $c0, $01        ;; 03:6360 ????????
    db   $00, $00, $e0, $00, $00, $00, $a0, $00        ;; 03:6368 ????????
    db   $00, $00, $30, $00, $00, $00, $00, $00        ;; 03:6370 ????????
    db   $00, $00, $10, $00, $00, $00, $60, $04        ;; 03:6378 ????????
    db   $00, $00, $a0, $00, $00, $00, $30, $07        ;; 03:6380 ????????
    db   $00, $00, $b0, $02, $00, $00, $00, $00        ;; 03:6388 ????????
    db   $00, $00, $10, $00, $00, $00, $00, $00        ;; 03:6390 ????????
    db   $90, $00, $a0, $00, $00, $00, $00, $00        ;; 03:6398 ????????
    db   $00, $00, $10, $00, $00, $00, $40, $03        ;; 03:63a0 ????????
    db   $00, $00, $60, $01, $00, $00, $60, $02        ;; 03:63a8 ????????
    db   $00, $00, $60, $01, $00, $00, $e0, $02        ;; 03:63b0 ????????
    db   $00, $00, $b0, $00, $00, $00, $40, $05        ;; 03:63b8 ????????
    db   $00, $00, $20, $02, $c0, $03, $b0, $0e        ;; 03:63c0 ????????
    db   $00, $00, $e0, $00, $00, $00, $40, $01        ;; 03:63c8 ????????
    db   $00, $00, $90, $00, $00, $00, $40, $01        ;; 03:63d0 ????????
    db   $10, $01, $a0, $01, $00, $00, $40, $01        ;; 03:63d8 ????????
    db   $20, $02, $b0, $02, $00, $01, $30, $03        ;; 03:63e0 ????????
    db   $00, $00, $e0, $00, $00, $00, $50, $0b        ;; 03:63e8 ????????
    db   $00, $00, $60, $01, $00, $00, $80, $0b        ;; 03:63f0 ????????
    db   $00, $00, $c0, $03, $00, $00, $90, $03        ;; 03:63f8 ????????
    db   $00, $00, $60, $01, $00, $00, $60, $05        ;; 03:6400 ????????
    db   $00, $00, $60, $01, $00, $00, $60, $02        ;; 03:6408 ????????
    db   $00, $00, $a0, $01, $00, $00, $00, $00        ;; 03:6410 ????????
    db   $00, $00, $00, $00, $00, $00, $60, $02        ;; 03:6418 ????????
    db   $00, $00, $80, $02, $00, $00, $a0, $00        ;; 03:6420 ????????
    db   $b0, $00, $e0, $00, $00, $00, $a0, $00        ;; 03:6428 ????????
    db   $b0, $00, $e0, $00, $00, $00, $a0, $00        ;; 03:6430 ????????
    db   $b0, $00, $e0, $00, $00, $00, $60, $01        ;; 03:6438 ????????
    db   $00, $00, $a0, $03, $00, $00, $e0, $00        ;; 03:6440 ????????
    db   $00, $00, $a0, $00, $28, $00, $28, $00        ;; 03:6448 ????????
    db   $00, $00, $00, $00, $00, $00, $e0, $01        ;; 03:6450 ????????
    db   $00, $00, $00, $03, $00, $00, $50, $01        ;; 03:6458 ????????
    db   $00, $00, $90, $00, $00, $00, $e0, $01        ;; 03:6460 ????????
    db   $00, $00, $80, $01, $00, $00, $e0, $01        ;; 03:6468 ????????
    db   $00, $00, $80, $01, $28, $00, $28, $00        ;; 03:6470 ????????
    db   $00, $00, $00, $00                            ;; 03:6478 ????

call_03_647c_InitPlayerPositionAndLevel:
; Purpose: Initializes the player’s spawn coordinates and current level on scene entry or respawn.
; Behavior:
; Resets checkpoint flags (wDCAC/wDCAD).
; If checkpoint bit set in wDB6A, restores stored X/Y from wDC6A_CheckpointStoredX–wDC6D.
; Else, if level ID non-zero, fetches default spawn coords from .data_03_6537.
; If level ID is zero, pulls next-level ID from .data_03_652b, copies level data (call_03_6c89), 
; then fetches new spawn coords.
; Calls call_03_6203 to set window boundaries and jumps to call_00_10de_UpdatePlayerMapWindow.
    xor  A, A                                          ;; 03:647c $af
    ld   [wDCAC], A                                    ;; 03:647d $ea $ac $dc
    ld   [wDCAD], A                                    ;; 03:6480 $ea $ad $dc
    ld   HL, wDB6A                                     ;; 03:6483 $21 $6a $db
    bit  2, [HL]                                       ;; 03:6486 $cb $56
    jr   Z, .jr_03_64a4                                ;; 03:6488 $28 $1a
    ld   A, [wDC6A_CheckpointStoredX]                                    ;; 03:648a $fa $6a $dc
    ld   [wD80E_PlayerXPosition], A                                    ;; 03:648d $ea $0e $d8
    ld   A, [wDC6A_CheckpointStoredX+1]                                    ;; 03:6490 $fa $6b $dc
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 03:6493 $ea $0f $d8
    ld   A, [wDC6C_CheckpointStoredY]                                    ;; 03:6496 $fa $6c $dc
    ld   [wD810_PlayerYPosition], A                                    ;; 03:6499 $ea $10 $d8
    ld   A, [wDC6C_CheckpointStoredY+1]                                    ;; 03:649c $fa $6d $dc
    ld   [wD810_PlayerYPosition+1], A                                    ;; 03:649f $ea $11 $d8
    jr   .jr_03_64c6                                   ;; 03:64a2 $18 $22
.jr_03_64a4:
    ld   A, [wDB6C_CurrentMapId]                                    ;; 03:64a4 $fa $6c $db
    and  A, A                                          ;; 03:64a7 $a7
    jr   Z, .jr_03_64cc                                ;; 03:64a8 $28 $22
    ld   HL, wDB6C_CurrentMapId                                     ;; 03:64aa $21 $6c $db
    ld   L, [HL]                                       ;; 03:64ad $6e
    ld   H, $00                                        ;; 03:64ae $26 $00
    add  HL, HL                                        ;; 03:64b0 $29
    add  HL, HL                                        ;; 03:64b1 $29
    ld   DE, .data_03_6537                             ;; 03:64b2 $11 $37 $65
    add  HL, DE                                        ;; 03:64b5 $19
    ld   A, [HL+]                                      ;; 03:64b6 $2a
    ld   [wD80E_PlayerXPosition], A                                    ;; 03:64b7 $ea $0e $d8
    ld   A, [HL+]                                      ;; 03:64ba $2a
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 03:64bb $ea $0f $d8
    ld   A, [HL+]                                      ;; 03:64be $2a
    ld   [wD810_PlayerYPosition], A                                    ;; 03:64bf $ea $10 $d8
    ld   A, [HL]                                       ;; 03:64c2 $7e
    ld   [wD810_PlayerYPosition+1], A                                    ;; 03:64c3 $ea $11 $d8
.jr_03_64c6:
    call call_03_6203_LoadLevelBoundariesFromId                                  ;; 03:64c6 $cd $03 $62
    jp   call_00_10de_UpdatePlayerMapWindow                                  ;; 03:64c9 $c3 $de $10
.jr_03_64cc:
    ld   HL, wDC5B                                     ;; 03:64cc $21 $5b $dc
    ld   L, [HL]                                       ;; 03:64cf $6e
    ld   H, $00                                        ;; 03:64d0 $26 $00
    ld   DE, .data_03_652b                             ;; 03:64d2 $11 $2b $65
    add  HL, DE                                        ;; 03:64d5 $19
    ld   A, [HL]                                       ;; 03:64d6 $7e
    ld   [wDB6C_CurrentMapId], A                                    ;; 03:64d7 $ea $6c $db
    call call_03_6c89_LoadMapData                                  ;; 03:64da $cd $89 $6c
    ld   HL, wDC5B                                     ;; 03:64dd $21 $5b $dc
    ld   L, [HL]                                       ;; 03:64e0 $6e
    ld   H, $00                                        ;; 03:64e1 $26 $00
    add  HL, HL                                        ;; 03:64e3 $29
    add  HL, HL                                        ;; 03:64e4 $29
    ld   DE, .data_03_64fb                             ;; 03:64e5 $11 $fb $64
    add  HL, DE                                        ;; 03:64e8 $19
    ld   A, [HL+]                                      ;; 03:64e9 $2a
    ld   [wD80E_PlayerXPosition], A                                    ;; 03:64ea $ea $0e $d8
    ld   A, [HL+]                                      ;; 03:64ed $2a
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 03:64ee $ea $0f $d8
    ld   A, [HL+]                                      ;; 03:64f1 $2a
    ld   [wD810_PlayerYPosition], A                                    ;; 03:64f2 $ea $10 $d8
    ld   A, [HL]                                       ;; 03:64f5 $7e
    ld   [wD810_PlayerYPosition+1], A                                    ;; 03:64f6 $ea $11 $d8
    jr   .jr_03_64c6                                   ;; 03:64f9 $18 $cb
.data_03_64fb:
    db   $00, $01                                      ;; 03:64fb ..
    dw   $00f0                                         ;; 03:64fd wW
    db   $b0, $01, $50, $00, $30, $00, $50, $00        ;; 03:64ff ....????
    db   $60, $00, $f0, $00, $80, $01, $f0, $00        ;; 03:6507 ????????
    db   $f0, $00, $80, $00, $00, $01, $40, $00        ;; 03:650f ????????
    db   $30, $00, $30, $00, $50, $00, $f0, $00        ;; 03:6517 ????????
    db   $b0, $01, $30, $00, $14, $01, $f0, $00        ;; 03:651f ????????
    db   $b0, $01, $30, $00                            ;; 03:6527 ????
.data_03_652b:
    db   $00, $0c, $0c, $0d, $0d, $0d, $0e, $0d        ;; 03:652b ww??????
    db   $0c, $0d, $0e, $0e                            ;; 03:6533 ????
.data_03_6537:
    db   $00, $01, $f0, $00, $50, $00                  ;; 03:6537 ????..
    dw   $04c0                                         ;; 03:653d wW
    db   $48, $00, $b0, $02, $f0, $00, $10, $01        ;; 03:653f ????????
    db   $38, $00, $50, $01, $f0, $01, $80, $00        ;; 03:6547 ????????
    db   $d8, $0a, $20, $01, $98, $02, $b8, $02        ;; 03:654f ????????
    db   $a8, $01, $f8, $03, $c0, $00, $80, $00        ;; 03:6557 ????????
    db   $78, $00, $60, $00, $c8, $00, $20, $03        ;; 03:655f ????????

