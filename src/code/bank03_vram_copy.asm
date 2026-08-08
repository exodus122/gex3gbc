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
