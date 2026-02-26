call_03_747d_StatusBar_UpdateOrTiles:
; Checks status flags in wDB69. If bit 0 is set, clears it and draws numbers to tilemap using call_03_74f5_DrawTwoDigitNumber. 
; If bit 1 is set, clears it and draws a multi-digit value to VRAM using a lookup table.
; Effectively manages HUD/status bar updates.
    ld   HL, wDB69                                     ;; 03:747d $21 $69 $db
    bit  0, [HL]                                       ;; 03:7480 $cb $46
    jr   Z, .jr_03_749d                                ;; 03:7482 $28 $19
    res  0, [HL]                                       ;; 03:7484 $cb $86
    ld   A, [wDC4E_LivesRemaining]                                    ;; 03:7486 $fa $4e $dc
    ld   HL, $9c02                                     ;; 03:7489 $21 $02 $9c
    ld   DE, $9c22                                     ;; 03:748c $11 $22 $9c
    call call_03_74f5_DrawTwoDigitNumber                                  ;; 03:748f $cd $f5 $74
    ld   A, [wDC68_CollectibleCount]                                    ;; 03:7492 $fa $68 $dc
    ld   HL, $9c11                                     ;; 03:7495 $21 $11 $9c
    ld   DE, $9c31                                     ;; 03:7498 $11 $31 $9c
    jr   call_03_74f5_DrawTwoDigitNumber                                  ;; 03:749b $18 $58
.jr_03_749d:
    bit  1, [HL]                                       ;; 03:749d $cb $4e
    jp   Z, call_03_757e_LoadHUDSprites_HDMA                                 ;; 03:749f $ca $7e $75
    res  1, [HL]                                       ;; 03:74a2 $cb $8e
    ld   B, $00                                        ;; 03:74a4 $06 $00
.jr_03_74a6:
    ld   A, [wDC50_PlayerHealth]                                    ;; 03:74a6 $fa $50 $dc
    sub  A, $04                                        ;; 03:74a9 $d6 $04
    jr   NC, .jr_03_74ae                               ;; 03:74ab $30 $01
    xor  A, A                                          ;; 03:74ad $af
.jr_03_74ae:
    ld   D, A                                          ;; 03:74ae $57
    ld   E, $00                                        ;; 03:74af $1e $00
    ld   A, B                                          ;; 03:74b1 $78
    ld   HL, wDC50_PlayerHealth                                     ;; 03:74b2 $21 $50 $dc
    cp   A, [HL]                                       ;; 03:74b5 $be
    jr   NC, .jr_03_74ba                               ;; 03:74b6 $30 $02
    set  0, E                                          ;; 03:74b8 $cb $c3
.jr_03_74ba:
    ld   HL, wDC4F_PawCoinExtraHealth                                     ;; 03:74ba $21 $4f $dc
    cp   A, [HL]                                       ;; 03:74bd $be
    jr   NC, .jr_03_74cb                               ;; 03:74be $30 $0b
    set  1, E                                          ;; 03:74c0 $cb $cb
    bit  0, E                                          ;; 03:74c2 $cb $43
    jr   Z, .jr_03_74cb                                ;; 03:74c4 $28 $05
    cp   A, D                                          ;; 03:74c6 $ba
    jr   NC, .jr_03_74cb                               ;; 03:74c7 $30 $02
    set  2, E                                          ;; 03:74c9 $cb $d3
.jr_03_74cb:
    ld   D, $00                                        ;; 03:74cb $16 $00
    ld   HL, .data_03_74ed                             ;; 03:74cd $21 $ed $74
    add  HL, DE                                        ;; 03:74d0 $19
    ld   A, [HL]                                       ;; 03:74d1 $7e
    ld   L, B                                          ;; 03:74d2 $68
    ld   H, $00                                        ;; 03:74d3 $26 $00
    add  HL, HL                                        ;; 03:74d5 $29
    ld   DE, $9c05                                     ;; 03:74d6 $11 $05 $9c
    add  HL, DE                                        ;; 03:74d9 $19
    ld   [HL+], A                                      ;; 03:74da $22
    add  A, $02                                        ;; 03:74db $c6 $02
    ld   [HL-], A                                      ;; 03:74dd $32
    ld   DE, $20                                       ;; 03:74de $11 $20 $00
    add  HL, DE                                        ;; 03:74e1 $19
    dec  A                                             ;; 03:74e2 $3d
    ld   [HL+], A                                      ;; 03:74e3 $22
    add  A, $02                                        ;; 03:74e4 $c6 $02
    ld   [HL], A                                       ;; 03:74e6 $77
    inc  B                                             ;; 03:74e7 $04
    bit  2, B                                          ;; 03:74e8 $cb $50
    jr   Z, .jr_03_74a6                                ;; 03:74ea $28 $ba
    ret                                                ;; 03:74ec $c9
.data_03_74ed:
    db   $18, $14, $24, $20, $1c, $1c, $1c, $1c        ;; 03:74ed ....???.

call_03_74f5_DrawTwoDigitNumber:
; Writes a bordered region of $30/$31 tiles, then converts value A to tens and ones (and hundreds if needed) 
; and writes corresponding digit tiles to the tilemap at HL and DE. Used by call_03_747d for number drawing.
    push HL                                            ;; 03:74f5 $e5
    ld   C, $30                                        ;; 03:74f6 $0e $30
    ld   [HL], C                                       ;; 03:74f8 $71
    inc  L                                             ;; 03:74f9 $2c
    ld   [HL], C                                       ;; 03:74fa $71
    inc  L                                             ;; 03:74fb $2c
    ld   [HL], C                                       ;; 03:74fc $71
    ld   BC, $1e                                       ;; 03:74fd $01 $1e $00
    add  HL, BC                                        ;; 03:7500 $09
    ld   C, $31                                        ;; 03:7501 $0e $31
    ld   [HL], C                                       ;; 03:7503 $71
    inc  L                                             ;; 03:7504 $2c
    ld   [HL], C                                       ;; 03:7505 $71
    inc  L                                             ;; 03:7506 $2c
    ld   [HL], C                                       ;; 03:7507 $71
    pop  HL                                            ;; 03:7508 $e1
    cp   A, $0a                                        ;; 03:7509 $fe $0a
    jr   C, .jr_03_7537                                ;; 03:750b $38 $2a
    cp   A, $64                                        ;; 03:750d $fe $64
    jr   C, .jr_03_7524                                ;; 03:750f $38 $13
    ld   C, $ff                                        ;; 03:7511 $0e $ff
.jr_03_7513:
    inc  C                                             ;; 03:7513 $0c
    sub  A, $64                                        ;; 03:7514 $d6 $64
    jr   NC, .jr_03_7513                               ;; 03:7516 $30 $fb
    add  A, $64                                        ;; 03:7518 $c6 $64
    ld   B, A                                          ;; 03:751a $47
    ld   A, C                                          ;; 03:751b $79
    add  A, A                                          ;; 03:751c $87
    add  A, $00                                        ;; 03:751d $c6 $00
    ld   [HL+], A                                      ;; 03:751f $22
    inc  A                                             ;; 03:7520 $3c
    ld   [DE], A                                       ;; 03:7521 $12
    inc  E                                             ;; 03:7522 $1c
    ld   A, B                                          ;; 03:7523 $78
.jr_03_7524:
    ld   C, $ff                                        ;; 03:7524 $0e $ff
.jr_03_7526:
    inc  C                                             ;; 03:7526 $0c
    sub  A, $0a                                        ;; 03:7527 $d6 $0a
    jr   NC, .jr_03_7526                               ;; 03:7529 $30 $fb
    add  A, $0a                                        ;; 03:752b $c6 $0a
    ld   B, A                                          ;; 03:752d $47
    ld   A, C                                          ;; 03:752e $79
    add  A, A                                          ;; 03:752f $87
    add  A, $00                                        ;; 03:7530 $c6 $00
    ld   [HL+], A                                      ;; 03:7532 $22
    inc  A                                             ;; 03:7533 $3c
    ld   [DE], A                                       ;; 03:7534 $12
    inc  E                                             ;; 03:7535 $1c
    ld   A, B                                          ;; 03:7536 $78
.jr_03_7537:
    add  A, A                                          ;; 03:7537 $87
    add  A, $00                                        ;; 03:7538 $c6 $00
    ld   [HL], A                                       ;; 03:753a $77
    inc  A                                             ;; 03:753b $3c
    ld   [DE], A                                       ;; 03:753c $12
    ret                                                ;; 03:753d $c9

call_03_753e_AnimatedBackground_HDMA:
; If bit 4 of wDB69 is set, advances frame counters (wDC72_FrameCounter2/wDC73_FrameCounter3) and uses HDMA to copy a 
; tile graphic from image_003_4400 into VRAM bank 1. Provides a cycling background or HUD animation.
    ld   HL, wDB69                                     ;; 03:753e $21 $69 $db
    bit  4, [HL]                                       ;; 03:7541 $cb $66
    ret  Z                                             ;; 03:7543 $c8
    ld   HL, wDC72_FrameCounter2                                     ;; 03:7544 $21 $72 $dc
    inc  [HL]                                          ;; 03:7547 $34
    ld   A, [HL]                                       ;; 03:7548 $7e
    sub  A, $08                                        ;; 03:7549 $d6 $08
    ret  NZ                                            ;; 03:754b $c0
    ld   [HL], A                                       ;; 03:754c $77
    ld   HL, wDC73_FrameCounter3                                     ;; 03:754d $21 $73 $dc
    inc  [HL]                                          ;; 03:7550 $34
    ld   A, [HL]                                       ;; 03:7551 $7e
    sub  A, $06                                        ;; 03:7552 $d6 $06
    jr   NZ, .jr_03_7557                               ;; 03:7554 $20 $01
    ld   [HL], A                                       ;; 03:7556 $77
.jr_03_7557:
    ld   A, [HL]                                       ;; 03:7557 $7e
    swap A                                             ;; 03:7558 $cb $37
    ld   L, A                                          ;; 03:755a $6f
    ld   H, $00                                        ;; 03:755b $26 $00
    add  HL, HL                                        ;; 03:755d $29
    add  HL, HL                                        ;; 03:755e $29
    ld   DE, image_003_4400                              ;; 03:755f $11 $00 $44
    add  HL, DE                                        ;; 03:7562 $19
    ld   A, $01                                        ;; 03:7563 $3e $01
    ldh  [rVBK], A                                     ;; 03:7565 $e0 $4f
    ld   A, H                                          ;; 03:7567 $7c
    ldh  [rHDMA1], A                                   ;; 03:7568 $e0 $51
    ld   A, L                                          ;; 03:756a $7d
    ldh  [rHDMA2], A                                   ;; 03:756b $e0 $52
    ld   A, $83                                        ;; 03:756d $3e $83
    ldh  [rHDMA3], A                                   ;; 03:756f $e0 $53
    ld   A, $c0                                        ;; 03:7571 $3e $c0
    ldh  [rHDMA4], A                                   ;; 03:7573 $e0 $54
    ld   A, $03                                        ;; 03:7575 $3e $03
    ldh  [rHDMA5], A                                   ;; 03:7577 $e0 $55
    ld   A, $00                                        ;; 03:7579 $3e $00
    ldh  [rVBK], A                                     ;; 03:757b $e0 $4f
    ret                                                ;; 03:757d $c9

call_03_757e_LoadHUDSprites_HDMA:
; If bit 2 of wDB69 is set and a value exists in wDB6D_InBonusLevel, converts values in wDB6E 
; to tile indices and issues several HDMA transfers from image_003_4580 to VRAM 
; positions ($8400+). Loads a 4×2 block of HUD sprite tiles.
    ld   HL, wDB69                                     ;; 03:757e $21 $69 $db
    bit  2, [HL]                                       ;; 03:7581 $cb $56
    ret  Z                                             ;; 03:7583 $c8
    res  2, [HL]                                       ;; 03:7584 $cb $96
    ld   A, [wDB6D_InBonusLevel]                                    ;; 03:7586 $fa $6d $db
    and  A, A                                          ;; 03:7589 $a7
    ret  Z                                             ;; 03:758a $c8
    ld   A, [wDB6E]                                    ;; 03:758b $fa $6e $db
    ld   C, $ff                                        ;; 03:758e $0e $ff
.jr_03_7590:
    inc  C                                             ;; 03:7590 $0c
    sub  A, $3c                                        ;; 03:7591 $d6 $3c
    jr   NC, .jr_03_7590                               ;; 03:7593 $30 $fb
    add  A, $3c                                        ;; 03:7595 $c6 $3c
    ld   D, $ff                                        ;; 03:7597 $16 $ff
.jr_03_7599:
    inc  D                                             ;; 03:7599 $14
    sub  A, $0a                                        ;; 03:759a $d6 $0a
    jr   NC, .jr_03_7599                               ;; 03:759c $30 $fb
    add  A, $0a                                        ;; 03:759e $c6 $0a
    ld   E, A                                          ;; 03:75a0 $5f
    push DE                                            ;; 03:75a1 $d5
    push DE                                            ;; 03:75a2 $d5
    ld   DE, _VRAM+$0400                                     ;; 03:75a3 $11 $00 $84
    call call_03_75be_HDMA_CopyNumberTileBlock                                  ;; 03:75a6 $cd $be $75
    ld   C, $0a                                        ;; 03:75a9 $0e $0a
    ld   DE, _VRAM+$0420                                     ;; 03:75ab $11 $20 $84
    call call_03_75be_HDMA_CopyNumberTileBlock                                  ;; 03:75ae $cd $be $75
    pop  DE                                            ;; 03:75b1 $d1
    ld   C, D                                          ;; 03:75b2 $4a
    ld   DE, _VRAM+$0440                                     ;; 03:75b3 $11 $40 $84
    call call_03_75be_HDMA_CopyNumberTileBlock                                  ;; 03:75b6 $cd $be $75
    pop  DE                                            ;; 03:75b9 $d1
    ld   C, E                                          ;; 03:75ba $4b
    ld   DE, _VRAM+$0460                                     ;; 03:75bb $11 $60 $84

call_03_75be_HDMA_CopyNumberTileBlock:
; Core routine for jp_03_757e. Calculates tile source address in image_003_4580 based 
; on index C and transfers 16×16-pixel tile data via HDMA to destination DE in VRAM bank 1.
    ld   L, C                                          ;; 03:75be $69
    ld   H, $00                                        ;; 03:75bf $26 $00
    add  HL, HL                                        ;; 03:75c1 $29
    add  HL, HL                                        ;; 03:75c2 $29
    add  HL, HL                                        ;; 03:75c3 $29
    add  HL, HL                                        ;; 03:75c4 $29
    add  HL, HL                                        ;; 03:75c5 $29
    ld   BC, image_003_4580                              ;; 03:75c6 $01 $80 $45
    add  HL, BC                                        ;; 03:75c9 $09
    ld   A, $01                                        ;; 03:75ca $3e $01
    ldh  [rVBK], A                                     ;; 03:75cc $e0 $4f
    ld   A, H                                          ;; 03:75ce $7c
    ldh  [rHDMA1], A                                   ;; 03:75cf $e0 $51
    ld   A, L                                          ;; 03:75d1 $7d
    ldh  [rHDMA2], A                                   ;; 03:75d2 $e0 $52
    ld   A, D                                          ;; 03:75d4 $7a
    ldh  [rHDMA3], A                                   ;; 03:75d5 $e0 $53
    ld   A, E                                          ;; 03:75d7 $7b
    ldh  [rHDMA4], A                                   ;; 03:75d8 $e0 $54
    ld   A, $01                                        ;; 03:75da $3e $01
    ldh  [rHDMA5], A                                   ;; 03:75dc $e0 $55
    ld   A, $00                                        ;; 03:75de $3e $00
    ldh  [rVBK], A                                     ;; 03:75e0 $e0 $4f
    ret                                                ;; 03:75e2 $c9

call_03_75e3_Tilemap_UpdateBlockFromBuffer:
; Sets VRAM bank 1, reads tilemap pointer from wDC21,
; copies a 32-byte metatile chunk (block) of data from scratch buffer (wCF80_MetatileScratchBuffer2) into VRAM.
; Then repeats for VRAM bank 0 with a different buffer (wCF00_MetatileScratchBuffer).
; This routine sets up a destination in VRAM (DE) based on wDC21 (likely current tile update coordinates) 
; and uses call_03_7604 to copy a fixed-size block of data from a RAM staging area into VRAM.
; It does this once for VRAM bank 1 (attributes) and again for bank 0 (tile indices).
    ld   A, $01                                        ;; 03:75e3 $3e $01
    ldh  [rVBK], A                                     ;; 03:75e5 $e0 $4f
    ld   HL, wDC21                                     ;; 03:75e7 $21 $21 $dc
    ld   A, [HL+]                                      ;; 03:75ea $2a
    and  A, $e0                                        ;; 03:75eb $e6 $e0
    ld   D, [HL]                                       ;; 03:75ed $56
    ld   E, A                                          ;; 03:75ee $5f
    ld   HL, wCF80_MetatileScratchBuffer2                                     ;; 03:75ef $21 $80 $cf
    call call_03_7604_MemCopy32Bytes                                  ;; 03:75f2 $cd $04 $76
    ld   A, $00                                        ;; 03:75f5 $3e $00
    ldh  [rVBK], A                                     ;; 03:75f7 $e0 $4f
    ld   HL, wDC21                                     ;; 03:75f9 $21 $21 $dc
    ld   A, [HL+]                                      ;; 03:75fc $2a
    and  A, $e0                                        ;; 03:75fd $e6 $e0
    ld   D, [HL]                                       ;; 03:75ff $56
    ld   E, A                                          ;; 03:7600 $5f
    ld   HL, wCF00_MetatileScratchBuffer                                     ;; 03:7601 $21 $00 $cf

call_03_7604_MemCopy32Bytes:
; Copies 32 bytes sequentially from HL -> DE (VRAM).
; This is a fixed unrolled loop that copies 32 bytes from the RAM buffer (HL) into VRAM ([DE]).
; It increments DE after each write, so it’s just a fast DMA-like copy.
    ld   A, [HL+]                                      ;; 03:7604 $2a
    ld   [DE], A                                       ;; 03:7605 $12
    inc  E                                             ;; 03:7606 $1c
    ld   A, [HL+]                                      ;; 03:7607 $2a
    ld   [DE], A                                       ;; 03:7608 $12
    inc  E                                             ;; 03:7609 $1c
    ld   A, [HL+]                                      ;; 03:760a $2a
    ld   [DE], A                                       ;; 03:760b $12
    inc  E                                             ;; 03:760c $1c
    ld   A, [HL+]                                      ;; 03:760d $2a
    ld   [DE], A                                       ;; 03:760e $12
    inc  E                                             ;; 03:760f $1c
    ld   A, [HL+]                                      ;; 03:7610 $2a
    ld   [DE], A                                       ;; 03:7611 $12
    inc  E                                             ;; 03:7612 $1c
    ld   A, [HL+]                                      ;; 03:7613 $2a
    ld   [DE], A                                       ;; 03:7614 $12
    inc  E                                             ;; 03:7615 $1c
    ld   A, [HL+]                                      ;; 03:7616 $2a
    ld   [DE], A                                       ;; 03:7617 $12
    inc  E                                             ;; 03:7618 $1c
    ld   A, [HL+]                                      ;; 03:7619 $2a
    ld   [DE], A                                       ;; 03:761a $12
    inc  E                                             ;; 03:761b $1c
    ld   A, [HL+]                                      ;; 03:761c $2a
    ld   [DE], A                                       ;; 03:761d $12
    inc  E                                             ;; 03:761e $1c
    ld   A, [HL+]                                      ;; 03:761f $2a
    ld   [DE], A                                       ;; 03:7620 $12
    inc  E                                             ;; 03:7621 $1c
    ld   A, [HL+]                                      ;; 03:7622 $2a
    ld   [DE], A                                       ;; 03:7623 $12
    inc  E                                             ;; 03:7624 $1c
    ld   A, [HL+]                                      ;; 03:7625 $2a
    ld   [DE], A                                       ;; 03:7626 $12
    inc  E                                             ;; 03:7627 $1c
    ld   A, [HL+]                                      ;; 03:7628 $2a
    ld   [DE], A                                       ;; 03:7629 $12
    inc  E                                             ;; 03:762a $1c
    ld   A, [HL+]                                      ;; 03:762b $2a
    ld   [DE], A                                       ;; 03:762c $12
    inc  E                                             ;; 03:762d $1c
    ld   A, [HL+]                                      ;; 03:762e $2a
    ld   [DE], A                                       ;; 03:762f $12
    inc  E                                             ;; 03:7630 $1c
    ld   A, [HL+]                                      ;; 03:7631 $2a
    ld   [DE], A                                       ;; 03:7632 $12
    inc  E                                             ;; 03:7633 $1c
    ld   A, [HL+]                                      ;; 03:7634 $2a
    ld   [DE], A                                       ;; 03:7635 $12
    inc  E                                             ;; 03:7636 $1c
    ld   A, [HL+]                                      ;; 03:7637 $2a
    ld   [DE], A                                       ;; 03:7638 $12
    inc  E                                             ;; 03:7639 $1c
    ld   A, [HL+]                                      ;; 03:763a $2a
    ld   [DE], A                                       ;; 03:763b $12
    inc  E                                             ;; 03:763c $1c
    ld   A, [HL+]                                      ;; 03:763d $2a
    ld   [DE], A                                       ;; 03:763e $12
    inc  E                                             ;; 03:763f $1c
    ld   A, [HL+]                                      ;; 03:7640 $2a
    ld   [DE], A                                       ;; 03:7641 $12
    inc  E                                             ;; 03:7642 $1c
    ld   A, [HL+]                                      ;; 03:7643 $2a
    ld   [DE], A                                       ;; 03:7644 $12
    inc  E                                             ;; 03:7645 $1c
    ld   A, [HL+]                                      ;; 03:7646 $2a
    ld   [DE], A                                       ;; 03:7647 $12
    inc  E                                             ;; 03:7648 $1c
    ld   A, [HL+]                                      ;; 03:7649 $2a
    ld   [DE], A                                       ;; 03:764a $12
    inc  E                                             ;; 03:764b $1c
    ld   A, [HL+]                                      ;; 03:764c $2a
    ld   [DE], A                                       ;; 03:764d $12
    inc  E                                             ;; 03:764e $1c
    ld   A, [HL+]                                      ;; 03:764f $2a
    ld   [DE], A                                       ;; 03:7650 $12
    inc  E                                             ;; 03:7651 $1c
    ld   A, [HL+]                                      ;; 03:7652 $2a
    ld   [DE], A                                       ;; 03:7653 $12
    inc  E                                             ;; 03:7654 $1c
    ld   A, [HL+]                                      ;; 03:7655 $2a
    ld   [DE], A                                       ;; 03:7656 $12
    inc  E                                             ;; 03:7657 $1c
    ld   A, [HL+]                                      ;; 03:7658 $2a
    ld   [DE], A                                       ;; 03:7659 $12
    inc  E                                             ;; 03:765a $1c
    ld   A, [HL+]                                      ;; 03:765b $2a
    ld   [DE], A                                       ;; 03:765c $12
    inc  E                                             ;; 03:765d $1c
    ld   A, [HL+]                                      ;; 03:765e $2a
    ld   [DE], A                                       ;; 03:765f $12
    inc  E                                             ;; 03:7660 $1c
    ld   A, [HL+]                                      ;; 03:7661 $2a
    ld   [DE], A                                       ;; 03:7662 $12
    ret                                                ;; 03:7663 $c9

call_03_7664_Tilemap_UpdateColumnFromBuffer:
; Sets VRAM bank 1, computes tilemap address from wDC23,
; copies a vertical strip from scratch buffer (wCFC0_TileColumnScratchBuffer2) into VRAM.
; Repeats for VRAM bank 0 with wCF40_TileColumnScratchBuffer.
; This one differs from 75e3: instead of a block copy, it writes values 
; spaced 32 tiles apart (adds BC=$20 after each).
; That means it’s writing a vertical column of tiles/attributes into the tilemap at $9800 (BG map).
    ld   A, $01                                        ;; 03:7664 $3e $01
    ldh  [rVBK], A                                     ;; 03:7666 $e0 $4f
    ld   A, [wDC23]                                    ;; 03:7668 $fa $23 $dc
    and  A, $1f                                        ;; 03:766b $e6 $1f
    ld   L, A                                          ;; 03:766d $6f
    ld   H, $98                                        ;; 03:766e $26 $98
    ld   DE, wCFC0_TileColumnScratchBuffer2                                     ;; 03:7670 $11 $c0 $cf
    call call_03_7685_MemCopyColumn16                                  ;; 03:7673 $cd $85 $76
    ld   A, $00                                        ;; 03:7676 $3e $00
    ldh  [rVBK], A                                     ;; 03:7678 $e0 $4f
    ld   A, [wDC23]                                    ;; 03:767a $fa $23 $dc
    and  A, $1f                                        ;; 03:767d $e6 $1f
    ld   L, A                                          ;; 03:767f $6f
    ld   H, HIGH(_SCRN0)                                        ;; 03:7680 $26 $98
    ld   DE, wCF40_TileColumnScratchBuffer                                     ;; 03:7682 $11 $40 $cf

call_03_7685_MemCopyColumn16:
; Core routine: copy 16 bytes from DE -> HL,
; but each step jumps down one row in the BG map (HL += $20).
; Takes DE (buffer in RAM) and writes its contents into a column of the BG map.
; Used by call_03_7664.
    ld   BC, $20                                       ;; 03:7685 $01 $20 $00
    ld   A, [DE]                                       ;; 03:7688 $1a
    ld   [HL], A                                       ;; 03:7689 $77
    add  HL, BC                                        ;; 03:768a $09
    inc  E                                             ;; 03:768b $1c
    ld   A, [DE]                                       ;; 03:768c $1a
    ld   [HL], A                                       ;; 03:768d $77
    add  HL, BC                                        ;; 03:768e $09
    inc  E                                             ;; 03:768f $1c
    ld   A, [DE]                                       ;; 03:7690 $1a
    ld   [HL], A                                       ;; 03:7691 $77
    add  HL, BC                                        ;; 03:7692 $09
    inc  E                                             ;; 03:7693 $1c
    ld   A, [DE]                                       ;; 03:7694 $1a
    ld   [HL], A                                       ;; 03:7695 $77
    add  HL, BC                                        ;; 03:7696 $09
    inc  E                                             ;; 03:7697 $1c
    ld   A, [DE]                                       ;; 03:7698 $1a
    ld   [HL], A                                       ;; 03:7699 $77
    add  HL, BC                                        ;; 03:769a $09
    inc  E                                             ;; 03:769b $1c
    ld   A, [DE]                                       ;; 03:769c $1a
    ld   [HL], A                                       ;; 03:769d $77
    add  HL, BC                                        ;; 03:769e $09
    inc  E                                             ;; 03:769f $1c
    ld   A, [DE]                                       ;; 03:76a0 $1a
    ld   [HL], A                                       ;; 03:76a1 $77
    add  HL, BC                                        ;; 03:76a2 $09
    inc  E                                             ;; 03:76a3 $1c
    ld   A, [DE]                                       ;; 03:76a4 $1a
    ld   [HL], A                                       ;; 03:76a5 $77
    add  HL, BC                                        ;; 03:76a6 $09
    inc  E                                             ;; 03:76a7 $1c
    ld   A, [DE]                                       ;; 03:76a8 $1a
    ld   [HL], A                                       ;; 03:76a9 $77
    add  HL, BC                                        ;; 03:76aa $09
    inc  E                                             ;; 03:76ab $1c
    ld   A, [DE]                                       ;; 03:76ac $1a
    ld   [HL], A                                       ;; 03:76ad $77
    add  HL, BC                                        ;; 03:76ae $09
    inc  E                                             ;; 03:76af $1c
    ld   A, [DE]                                       ;; 03:76b0 $1a
    ld   [HL], A                                       ;; 03:76b1 $77
    add  HL, BC                                        ;; 03:76b2 $09
    inc  E                                             ;; 03:76b3 $1c
    ld   A, [DE]                                       ;; 03:76b4 $1a
    ld   [HL], A                                       ;; 03:76b5 $77
    add  HL, BC                                        ;; 03:76b6 $09
    inc  E                                             ;; 03:76b7 $1c
    ld   A, [DE]                                       ;; 03:76b8 $1a
    ld   [HL], A                                       ;; 03:76b9 $77
    add  HL, BC                                        ;; 03:76ba $09
    inc  E                                             ;; 03:76bb $1c
    ld   A, [DE]                                       ;; 03:76bc $1a
    ld   [HL], A                                       ;; 03:76bd $77
    add  HL, BC                                        ;; 03:76be $09
    inc  E                                             ;; 03:76bf $1c
    ld   A, [DE]                                       ;; 03:76c0 $1a
    ld   [HL], A                                       ;; 03:76c1 $77
    add  HL, BC                                        ;; 03:76c2 $09
    inc  E                                             ;; 03:76c3 $1c
    ld   A, [DE]                                       ;; 03:76c4 $1a
    ld   [HL], A                                       ;; 03:76c5 $77
    add  HL, BC                                        ;; 03:76c6 $09
    inc  E                                             ;; 03:76c7 $1c
    ld   A, [DE]                                       ;; 03:76c8 $1a
    ld   [HL], A                                       ;; 03:76c9 $77
    add  HL, BC                                        ;; 03:76ca $09
    inc  E                                             ;; 03:76cb $1c
    ld   A, [DE]                                       ;; 03:76cc $1a
    ld   [HL], A                                       ;; 03:76cd $77
    add  HL, BC                                        ;; 03:76ce $09
    inc  E                                             ;; 03:76cf $1c
    ld   A, [DE]                                       ;; 03:76d0 $1a
    ld   [HL], A                                       ;; 03:76d1 $77
    add  HL, BC                                        ;; 03:76d2 $09
    inc  E                                             ;; 03:76d3 $1c
    ld   A, [DE]                                       ;; 03:76d4 $1a
    ld   [HL], A                                       ;; 03:76d5 $77
    add  HL, BC                                        ;; 03:76d6 $09
    inc  E                                             ;; 03:76d7 $1c
    ld   A, [DE]                                       ;; 03:76d8 $1a
    ld   [HL], A                                       ;; 03:76d9 $77
    add  HL, BC                                        ;; 03:76da $09
    inc  E                                             ;; 03:76db $1c
    ld   A, [DE]                                       ;; 03:76dc $1a
    ld   [HL], A                                       ;; 03:76dd $77
    add  HL, BC                                        ;; 03:76de $09
    inc  E                                             ;; 03:76df $1c
    ld   A, [DE]                                       ;; 03:76e0 $1a
    ld   [HL], A                                       ;; 03:76e1 $77
    add  HL, BC                                        ;; 03:76e2 $09
    inc  E                                             ;; 03:76e3 $1c
    ld   A, [DE]                                       ;; 03:76e4 $1a
    ld   [HL], A                                       ;; 03:76e5 $77
    add  HL, BC                                        ;; 03:76e6 $09
    inc  E                                             ;; 03:76e7 $1c
    ld   A, [DE]                                       ;; 03:76e8 $1a
    ld   [HL], A                                       ;; 03:76e9 $77
    add  HL, BC                                        ;; 03:76ea $09
    inc  E                                             ;; 03:76eb $1c
    ld   A, [DE]                                       ;; 03:76ec $1a
    ld   [HL], A                                       ;; 03:76ed $77
    add  HL, BC                                        ;; 03:76ee $09
    inc  E                                             ;; 03:76ef $1c
    ld   A, [DE]                                       ;; 03:76f0 $1a
    ld   [HL], A                                       ;; 03:76f1 $77
    add  HL, BC                                        ;; 03:76f2 $09
    inc  E                                             ;; 03:76f3 $1c
    ld   A, [DE]                                       ;; 03:76f4 $1a
    ld   [HL], A                                       ;; 03:76f5 $77
    add  HL, BC                                        ;; 03:76f6 $09
    inc  E                                             ;; 03:76f7 $1c
    ld   A, [DE]                                       ;; 03:76f8 $1a
    ld   [HL], A                                       ;; 03:76f9 $77
    add  HL, BC                                        ;; 03:76fa $09
    inc  E                                             ;; 03:76fb $1c
    ld   A, [DE]                                       ;; 03:76fc $1a
    ld   [HL], A                                       ;; 03:76fd $77
    add  HL, BC                                        ;; 03:76fe $09
    inc  E                                             ;; 03:76ff $1c
    ld   A, [DE]                                       ;; 03:7700 $1a
    ld   [HL], A                                       ;; 03:7701 $77
    add  HL, BC                                        ;; 03:7702 $09
    inc  E                                             ;; 03:7703 $1c
    ld   A, [DE]                                       ;; 03:7704 $1a
    ld   [HL], A                                       ;; 03:7705 $77
    ret                                                ;; 03:7706 $c9
