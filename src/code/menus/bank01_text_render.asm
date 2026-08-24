call_01_4875_Text_Render:
; Draws a string into the tile staging buffer, one line at a time. The renderer
; proper - and it writes GRAPHICS, not a tilemap.
;
; It loads the font descriptor for wDBA6_MenuCmd_Arg2 out of
; data_01_5b77_FontDescriptors, has call_01_49bb_Text_WrapAndAlign break the text into
; lines that fit, and then walks lines until a blank one or the end of the string.
; Each line's characters go through call_01_48cd_Text_DrawGlyph; each line advances the
; pen by wDBE2_Text_LineAdvance.
;
; If wDBE1_Text_RequestedX is TEXT_AUTO_ALIGN the line is centred, by measuring it and
; starting at half the block width minus half the text width.
;
; gex2's call_01_4a8f_Text_Render
    ld   HL, wDBA6_MenuCmd_Arg2                       ;; 01:4875 $21 $a6 $db
    ld   L, [HL]                                      ;; 01:4878 $6e
    ld   H, $00                                       ;; 01:4879 $26 $00
    add  HL, HL                                       ;; 01:487b $29
    add  HL, HL                                       ;; 01:487c $29
    add  HL, HL                                       ;; 01:487d $29
    ld   DE, data_01_5b77_FontDescriptors             ;; 01:487e $11 $77 $5b
    add  HL, DE                                       ;; 01:4881 $19
    ld   DE, wDBAB_Font_GlyphBase                     ;; 01:4882 $11 $ab $db
    ld   BC, MENUCMD_DESCRIPTOR_COPY_BYTES            ;; 01:4885 $01 $06 $00
    call call_00_076e_MemCopy                         ;; 01:4888 $cd $6e $07
    call call_01_49bb_Text_WrapAndAlign               ;; 01:488b $cd $bb $49
.jr_01_488e:
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:488e $21 $a7 $db
    ld   E, [HL]                                      ;; 01:4891 $5e
    inc  HL                                           ;; 01:4892 $23
    ld   D, [HL]                                      ;; 01:4893 $56
    ld   A, [DE]                                      ;; 01:4894 $1a
    cp   A, $80                                       ;; 01:4895 $fe $80
    ret  Z                                            ;; 01:4897 $c8
    and  A, A                                         ;; 01:4898 $a7
    ret  Z                                            ;; 01:4899 $c8
    ld   A, [wDBE1_Text_RequestedX]                   ;; 01:489a $fa $e1 $db
    cp   A, TEXT_AUTO_ALIGN                           ;; 01:489d $fe $fe
    jr   NZ, .jr_01_48ac                              ;; 01:489f $20 $0b
    call call_01_4a55_Text_MeasureLine                ;; 01:48a1 $cd $55 $4a
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:48a4 $fa $9e $db
    add  A, A                                         ;; 01:48a7 $87
    add  A, A                                         ;; 01:48a8 $87
    srl  C                                            ;; 01:48a9 $cb $39
    sub  A, C                                         ;; 01:48ab $91
.jr_01_48ac:
    ld   [wDBA4_Text_PenX], A                         ;; 01:48ac $ea $a4 $db
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:48af $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:48b2 $2a
    ld   H, [HL]                                      ;; 01:48b3 $66
    ld   L, A                                         ;; 01:48b4 $6f
.jr_01_48b5:
    ld   A, [HL+]                                     ;; 01:48b5 $2a
    push HL                                           ;; 01:48b6 $e5
    call call_01_48cd_Text_DrawGlyph                  ;; 01:48b7 $cd $cd $48
    pop  HL                                           ;; 01:48ba $e1
    bit  7, [HL]                                      ;; 01:48bb $cb $7e
    jr   Z, .jr_01_48b5                               ;; 01:48bd $28 $f6
    inc  HL                                           ;; 01:48bf $23
    call call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:48c0 $cd $fa $4c
    ld   HL, wDBA5_Text_PenY                          ;; 01:48c3 $21 $a5 $db
    ld   A, [wDBE2_Text_LineAdvance]                  ;; 01:48c6 $fa $e2 $db
    add  A, [HL]                                      ;; 01:48c9 $86
    ld   [HL], A                                      ;; 01:48ca $77
    jr   .jr_01_488e                                  ;; 01:48cb $18 $c1

call_01_48cd_Text_DrawGlyph:
; One character, composited into the staging buffer at the pen, and the densest
; routine in the file.
;
; The problem it solves: glyphs are proportional, so a character does not begin on a
; tile boundary. wDBC8_Text_ShiftCount is 8 minus the pen's sub-tile column, and each
; eight-pixel glyph row is treated as the high byte of a 16-bit value shifted left by
; it - the high half lands in the current tile column and the low half in the next
; one. Both halves are XOR'd in rather than stored, so glyphs composite with whatever
; is already there and drawing the same glyph twice erases it. That is how the
; password keyboard's highlight blinks.
;
; The address arithmetic is worth reading slowly: the destination is the tile at
; (penX & $F8) plus the pixel row within it, plus whole tile rows for penY >> 3, all
; relative to the block's own base from
; call_01_4cd4_Menu_GetStagingAddrForDestTile. When the write cursor crosses a
; TILE_SIZE_BYTES boundary it jumps a whole block-row so the next pixel row lands in
; the tile directly below. The outer loop repeats for wide glyphs.
;
; gex2's call_01_4ae7_Text_DrawGlyph
    call call_01_4a7f_Text_SelectGlyph                ;; 01:48cd $cd $7f $4a
    ld   A, [wDBA4_Text_PenX]                         ;; 01:48d0 $fa $a4 $db
    and  A, $07                                       ;; 01:48d3 $e6 $07
    ld   C, A                                         ;; 01:48d5 $4f
    ld   A, $08                                       ;; 01:48d6 $3e $08
    sub  A, C                                         ;; 01:48d8 $91
    ld   [wDBC8_Text_ShiftCount], A                   ;; 01:48d9 $ea $c8 $db
    ld   A, [wDBA4_Text_PenX]                         ;; 01:48dc $fa $a4 $db
    and  A, $f8                                       ;; 01:48df $e6 $f8
    ld   L, A                                         ;; 01:48e1 $6f
    ld   H, $00                                       ;; 01:48e2 $26 $00
    add  HL, HL                                       ;; 01:48e4 $29
    ld   A, [wDBA5_Text_PenY]                         ;; 01:48e5 $fa $a5 $db
    and  A, $07                                       ;; 01:48e8 $e6 $07
    add  A, A                                         ;; 01:48ea $87
    ld   E, A                                         ;; 01:48eb $5f
    ld   D, $00                                       ;; 01:48ec $16 $00
    add  HL, DE                                       ;; 01:48ee $19
    ld   A, [wDBA5_Text_PenY]                         ;; 01:48ef $fa $a5 $db
    srl  A                                            ;; 01:48f2 $cb $3f
    srl  A                                            ;; 01:48f4 $cb $3f
    srl  A                                            ;; 01:48f6 $cb $3f
    jr   Z, .jr_01_490c                               ;; 01:48f8 $28 $12
    ld   C, A                                         ;; 01:48fa $4f
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:48fb $fa $9e $db
    swap A                                            ;; 01:48fe $cb $37
    ld   D, A                                         ;; 01:4900 $57
    and  A, $f0                                       ;; 01:4901 $e6 $f0
    ld   E, A                                         ;; 01:4903 $5f
    ld   A, D                                         ;; 01:4904 $7a
    and  A, $0f                                       ;; 01:4905 $e6 $0f
    ld   D, A                                         ;; 01:4907 $57
.jr_01_4908:
    add  HL, DE                                       ;; 01:4908 $19
    dec  C                                            ;; 01:4909 $0d
    jr   NZ, .jr_01_4908                              ;; 01:490a $20 $fc
.jr_01_490c:
    push HL                                           ;; 01:490c $e5
    call call_01_4cd4_Menu_GetStagingAddrForDestTile  ;; 01:490d $cd $d4 $4c
    pop  HL                                           ;; 01:4910 $e1
    add  HL, DE                                       ;; 01:4911 $19
    ld   A, [wDBAF_Font_GlyphWidthCols]               ;; 01:4912 $fa $af $db
.jr_01_4915:
    push AF                                           ;; 01:4915 $f5
    push HL                                           ;; 01:4916 $e5
    ld   A, L                                         ;; 01:4917 $7d
    ld   [wDBBB_Text_DestPtr], A                      ;; 01:4918 $ea $bb $db
    ld   A, H                                         ;; 01:491b $7c
    ld   [wDBBC_Text_DestPtrHi], A                                   ;; 01:491c $ea $bc $db
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:491f $fa $b0 $db
.jr_01_4922:
    push AF                                           ;; 01:4922 $f5
    ld   A, [wDBBD_Text_GlyphPtr]                     ;; 01:4923 $fa $bd $db
    ld   L, A                                         ;; 01:4926 $6f
    ld   A, [wDBBE_Text_GlyphPtrHi]                                   ;; 01:4927 $fa $be $db
    ld   H, A                                         ;; 01:492a $67
    ld   E, [HL]                                      ;; 01:492b $5e
    inc  HL                                           ;; 01:492c $23
    ld   C, [HL]                                      ;; 01:492d $4e
    inc  HL                                           ;; 01:492e $23
    ld   A, L                                         ;; 01:492f $7d
    ld   [wDBBD_Text_GlyphPtr], A                     ;; 01:4930 $ea $bd $db
    ld   A, H                                         ;; 01:4933 $7c
    ld   [wDBBE_Text_GlyphPtrHi], A                                   ;; 01:4934 $ea $be $db
    ld   D, $00                                       ;; 01:4937 $16 $00
    ld   B, $00                                       ;; 01:4939 $06 $00
    ld   A, [wDBC8_Text_ShiftCount]                   ;; 01:493b $fa $c8 $db
.jr_01_493e:
    sla  E                                            ;; 01:493e $cb $23
    rl   D                                            ;; 01:4940 $cb $12
    sla  C                                            ;; 01:4942 $cb $21
    rl   B                                            ;; 01:4944 $cb $10
    dec  A                                            ;; 01:4946 $3d
    jr   NZ, .jr_01_493e                              ;; 01:4947 $20 $f5
    ld   A, [wDBBB_Text_DestPtr]                      ;; 01:4949 $fa $bb $db
    ld   L, A                                         ;; 01:494c $6f
    ld   A, [wDBBC_Text_DestPtrHi]                                   ;; 01:494d $fa $bc $db
    ld   H, A                                         ;; 01:4950 $67
    ld   A, D                                         ;; 01:4951 $7a
    xor  A, [HL]                                      ;; 01:4952 $ae
    ld   [HL+], A                                     ;; 01:4953 $22
    ld   A, B                                         ;; 01:4954 $78
    xor  A, [HL]                                      ;; 01:4955 $ae
    ld   [HL], A                                      ;; 01:4956 $77
    ld   A, E                                         ;; 01:4957 $7b
    ld   DE, $0f                                      ;; 01:4958 $11 $0f $00
    add  HL, DE                                       ;; 01:495b $19
    xor  A, [HL]                                      ;; 01:495c $ae
    ld   [HL+], A                                     ;; 01:495d $22
    ld   A, C                                         ;; 01:495e $79
    xor  A, [HL]                                      ;; 01:495f $ae
    ld   [HL], A                                      ;; 01:4960 $77
    ld   HL, wDBBB_Text_DestPtr                       ;; 01:4961 $21 $bb $db
    ld   A, [HL+]                                     ;; 01:4964 $2a
    ld   H, [HL]                                      ;; 01:4965 $66
    ld   L, A                                         ;; 01:4966 $6f
    inc  HL                                           ;; 01:4967 $23
    inc  HL                                           ;; 01:4968 $23
    ld   A, L                                         ;; 01:4969 $7d
    and  A, $0f                                       ;; 01:496a $e6 $0f
    jr   NZ, .jr_01_4980                              ;; 01:496c $20 $12
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:496e $fa $9e $db
    swap A                                            ;; 01:4971 $cb $37
    ld   D, A                                         ;; 01:4973 $57
    and  A, $f0                                       ;; 01:4974 $e6 $f0
    ld   E, A                                         ;; 01:4976 $5f
    ld   A, D                                         ;; 01:4977 $7a
    and  A, $0f                                       ;; 01:4978 $e6 $0f
    ld   D, A                                         ;; 01:497a $57
    add  HL, DE                                       ;; 01:497b $19
    ld   DE, hFFF0                                    ;; 01:497c $11 $f0 $ff
    add  HL, DE                                       ;; 01:497f $19
.jr_01_4980:
    ld   A, L                                         ;; 01:4980 $7d
    ld   [wDBBB_Text_DestPtr], A                      ;; 01:4981 $ea $bb $db
    ld   A, H                                         ;; 01:4984 $7c
    ld   [wDBBC_Text_DestPtrHi], A                                   ;; 01:4985 $ea $bc $db
    pop  AF                                           ;; 01:4988 $f1
    dec  A                                            ;; 01:4989 $3d
    jr   NZ, .jr_01_4922                              ;; 01:498a $20 $96
    pop  HL                                           ;; 01:498c $e1
    ld   DE, $10                                      ;; 01:498d $11 $10 $00
    add  HL, DE                                       ;; 01:4990 $19
    pop  AF                                           ;; 01:4991 $f1
    dec  A                                            ;; 01:4992 $3d
    jr   NZ, .jr_01_4915                              ;; 01:4993 $20 $80
    ld   HL, wDBA4_Text_PenX                          ;; 01:4995 $21 $a4 $db
    ld   A, [wDBC9_Text_GlyphAdvance]                 ;; 01:4998 $fa $c9 $db
    add  A, [HL]                                      ;; 01:499b $86
    inc  A                                            ;; 01:499c $3c
    ld   [HL], A                                      ;; 01:499d $77
    ret                                               ;; 01:499e $c9

call_01_499f_Text_ClearBuffer:
; Blanks the current block's tiles in the staging buffer, so the XOR compositing above
; starts from a clean page. Sixteen unrolled stores per tile, and the tile count comes
; back in A from call_01_4ce5_Menu_GetTileDataSize.
;
; Unlike gex2's call_01_4bb7_Text_ClearBuffer, which always clears from the start of
; the buffer, this one clears from the block's own base - so gex3 can blank one part
; of a screen without touching the rest
    call call_01_4ce5_Menu_GetTileDataSize            ;; 01:499f $cd $e5 $4c
    ld   B, A                                         ;; 01:49a2 $47
    call call_01_4cd4_Menu_GetStagingAddrForDestTile  ;; 01:49a3 $cd $d4 $4c
    xor  A, A                                         ;; 01:49a6 $af
.jr_01_49a7:
    ld   [HL+], A                                     ;; 01:49a7 $22
    ld   [HL+], A                                     ;; 01:49a8 $22
    ld   [HL+], A                                     ;; 01:49a9 $22
    ld   [HL+], A                                     ;; 01:49aa $22
    ld   [HL+], A                                     ;; 01:49ab $22
    ld   [HL+], A                                     ;; 01:49ac $22
    ld   [HL+], A                                     ;; 01:49ad $22
    ld   [HL+], A                                     ;; 01:49ae $22
    ld   [HL+], A                                     ;; 01:49af $22
    ld   [HL+], A                                     ;; 01:49b0 $22
    ld   [HL+], A                                     ;; 01:49b1 $22
    ld   [HL+], A                                     ;; 01:49b2 $22
    ld   [HL+], A                                     ;; 01:49b3 $22
    ld   [HL+], A                                     ;; 01:49b4 $22
    ld   [HL+], A                                     ;; 01:49b5 $22
    ld   [HL+], A                                     ;; 01:49b6 $22
    dec  B                                            ;; 01:49b7 $05
    jr   NZ, .jr_01_49a7                              ;; 01:49b8 $20 $ed
    ret                                               ;; 01:49ba $c9

call_01_49bb_Text_WrapAndAlign:
; Word-wraps a string to the block's width and, if asked, spreads the lines evenly
; down its height. Runs before any drawing.
;
; Wrapping is done in place and destructively: it measures a line, and if it is too
; wide it scans back to the nearest TEXT_SPACE and overwrites that space with a
; TEXT_TERMINATOR, turning it into a line break. Then it re-measures from the top,
; because the break may have changed everything after it. A second pass turns stray
; terminators back into spaces where the text continues.
;
; Vertical distribution kicks in when the pen Y is TEXT_AUTO_ALIGN: it counts the
; lines, works out the leftover height, and divides it by lines + 1 by repeated
; subtraction, so the gap above, between and below all match.
;
; The string it edits is the WRAM copy, not the ROM original -
; call_00_0835_Text_LoadStringToBuffer put it there first. gex2's
; call_01_4bd3_Text_WrapAndAlign
    call call_00_0835_Text_LoadStringToBuffer         ;; 01:49bb $cd $35 $08
.jr_01_49be:
    call call_01_4a55_Text_MeasureLine                ;; 01:49be $cd $55 $4a
    ld   HL, wDB9E_MenuCmd_WidthTiles                 ;; 01:49c1 $21 $9e $db
    ld   L, [HL]                                      ;; 01:49c4 $6e
    ld   H, $00                                       ;; 01:49c5 $26 $00
    add  HL, HL                                       ;; 01:49c7 $29
    add  HL, HL                                       ;; 01:49c8 $29
    add  HL, HL                                       ;; 01:49c9 $29
    ld   A, L                                         ;; 01:49ca $7d
    sub  A, C                                         ;; 01:49cb $91
    ld   A, H                                         ;; 01:49cc $7c
    sbc  A, B                                         ;; 01:49cd $98
    jr   NC, .jr_01_49e5                              ;; 01:49ce $30 $15
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:49d0 $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:49d3 $2a
    ld   H, [HL]                                      ;; 01:49d4 $66
    ld   L, A                                         ;; 01:49d5 $6f
.jr_01_49d6:
    inc  HL                                           ;; 01:49d6 $23
    bit  7, [HL]                                      ;; 01:49d7 $cb $7e
    jr   Z, .jr_01_49d6                               ;; 01:49d9 $28 $fb
.jr_01_49db:
    dec  HL                                           ;; 01:49db $2b
    ld   A, [HL]                                      ;; 01:49dc $7e
    cp   A, TEXT_SPACE                                ;; 01:49dd $fe $20
    jr   NZ, .jr_01_49db                              ;; 01:49df $20 $fa
    ld   [HL], TEXT_TERMINATOR                        ;; 01:49e1 $36 $80
    jr   .jr_01_49be                                  ;; 01:49e3 $18 $d9
.jr_01_49e5:
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:49e5 $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:49e8 $2a
    ld   H, [HL]                                      ;; 01:49e9 $66
    ld   L, A                                         ;; 01:49ea $6f
.jr_01_49eb:
    ld   A, [HL+]                                     ;; 01:49eb $2a
    bit  7, A                                         ;; 01:49ec $cb $7f
    jr   Z, .jr_01_49eb                               ;; 01:49ee $28 $fb
    ld   A, [HL]                                      ;; 01:49f0 $7e
    and  A, A                                         ;; 01:49f1 $a7
    jr   Z, .jr_01_4a06                               ;; 01:49f2 $28 $12
    call call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:49f4 $cd $fa $4c
.jr_01_49f7:
    ld   A, [HL+]                                     ;; 01:49f7 $2a
    bit  7, A                                         ;; 01:49f8 $cb $7f
    jr   Z, .jr_01_49f7                               ;; 01:49fa $28 $fb
    ld   A, [HL]                                      ;; 01:49fc $7e
    and  A, A                                         ;; 01:49fd $a7
    jr   Z, .jr_01_49be                               ;; 01:49fe $28 $be
    dec  HL                                           ;; 01:4a00 $2b
    ld   [HL], TEXT_SPACE                             ;; 01:4a01 $36 $20
    inc  HL                                           ;; 01:4a03 $23
    jr   .jr_01_49f7                                  ;; 01:4a04 $18 $f1
.jr_01_4a06:
    ld   A, [wDBA4_Text_PenX]                         ;; 01:4a06 $fa $a4 $db
    ld   [wDBE1_Text_RequestedX], A                   ;; 01:4a09 $ea $e1 $db
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:4a0c $21 $dd $da
    call call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:4a0f $cd $fa $4c
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:4a12 $fa $b0 $db
    inc  A                                            ;; 01:4a15 $3c
    ld   [wDBE2_Text_LineAdvance], A                  ;; 01:4a16 $ea $e2 $db
    ld   A, [wDBA5_Text_PenY]                         ;; 01:4a19 $fa $a5 $db
    cp   A, TEXT_AUTO_ALIGN                           ;; 01:4a1c $fe $fe
    ret  NZ                                           ;; 01:4a1e $c0
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:4a1f $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:4a22 $2a
    ld   H, [HL]                                      ;; 01:4a23 $66
    ld   L, A                                         ;; 01:4a24 $6f
    ld   C, $00                                       ;; 01:4a25 $0e $00
.jr_01_4a27:
    ld   A, [HL+]                                     ;; 01:4a27 $2a
    bit  7, A                                         ;; 01:4a28 $cb $7f
    jr   Z, .jr_01_4a27                               ;; 01:4a2a $28 $fb
    inc  C                                            ;; 01:4a2c $0c
    ld   A, [HL]                                      ;; 01:4a2d $7e
    and  A, A                                         ;; 01:4a2e $a7
    jr   NZ, .jr_01_4a27                              ;; 01:4a2f $20 $f6
    push BC                                           ;; 01:4a31 $c5
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:4a32 $fa $b0 $db
    ld   B, A                                         ;; 01:4a35 $47
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:4a36 $fa $9f $db
    add  A, A                                         ;; 01:4a39 $87
    add  A, A                                         ;; 01:4a3a $87
    add  A, A                                         ;; 01:4a3b $87
.jr_01_4a3c:
    sub  A, B                                         ;; 01:4a3c $90
    dec  C                                            ;; 01:4a3d $0d
    jr   NZ, .jr_01_4a3c                              ;; 01:4a3e $20 $fc
    pop  BC                                           ;; 01:4a40 $c1
    inc  C                                            ;; 01:4a41 $0c
    ld   B, $ff                                       ;; 01:4a42 $06 $ff
.jr_01_4a44:
    inc  B                                            ;; 01:4a44 $04
    sub  A, C                                         ;; 01:4a45 $91
    jr   NC, .jr_01_4a44                              ;; 01:4a46 $30 $fc
    ld   A, B                                         ;; 01:4a48 $78
    ld   [wDBA5_Text_PenY], A                         ;; 01:4a49 $ea $a5 $db
    ld   HL, wDBB0_Font_GlyphHeightPx                 ;; 01:4a4c $21 $b0 $db
    add  A, [HL]                                      ;; 01:4a4f $86
    inc  A                                            ;; 01:4a50 $3c
    ld   [wDBE2_Text_LineAdvance], A                  ;; 01:4a51 $ea $e2 $db
    ret                                               ;; 01:4a54 $c9

call_01_4a55_Text_MeasureLine:
; Width in pixels of the text up to the next line break, in BC. Each character's
; advance comes from the font's width table via the glyph index, plus one pixel of
; spacing per character - and the trailing space is removed with a single `dec BC` at
; the end rather than being special-cased in the loop. Returns 0 for an empty line.
; gex2's call_01_4c81_Text_MeasureLine
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:4a55 $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:4a58 $2a
    ld   H, [HL]                                      ;; 01:4a59 $66
    ld   L, A                                         ;; 01:4a5a $6f
    ld   BC, $00                                      ;; 01:4a5b $01 $00 $00
    bit  7, [HL]                                      ;; 01:4a5e $cb $7e
    ret  NZ                                           ;; 01:4a60 $c0
.jr_01_4a61:
    ld   A, [HL+]                                     ;; 01:4a61 $2a
    push HL                                           ;; 01:4a62 $e5
    call call_01_4df4_Text_CharToGlyphIndex           ;; 01:4a63 $cd $f4 $4d
    ld   HL, wDBAD_Font_WidthTable                    ;; 01:4a66 $21 $ad $db
    ld   E, [HL]                                      ;; 01:4a69 $5e
    inc  HL                                           ;; 01:4a6a $23
    ld   D, [HL]                                      ;; 01:4a6b $56
    ld   L, A                                         ;; 01:4a6c $6f
    ld   H, $00                                       ;; 01:4a6d $26 $00
    add  HL, DE                                       ;; 01:4a6f $19
    ld   A, [HL]                                      ;; 01:4a70 $7e
    add  A, C                                         ;; 01:4a71 $81
    ld   C, A                                         ;; 01:4a72 $4f
    ld   A, $00                                       ;; 01:4a73 $3e $00
    adc  A, B                                         ;; 01:4a75 $88
    ld   B, A                                         ;; 01:4a76 $47
    inc  BC                                           ;; 01:4a77 $03
    pop  HL                                           ;; 01:4a78 $e1
    bit  7, [HL]                                      ;; 01:4a79 $cb $7e
    jr   Z, .jr_01_4a61                               ;; 01:4a7b $28 $e4
    dec  BC                                           ;; 01:4a7d $0b
    ret                                               ;; 01:4a7e $c9

call_01_4a7f_Text_SelectGlyph:
; Points wDBBD_Text_GlyphPtr at one character's bitmap and records its advance in
; wDBC9_Text_GlyphAdvance.
;
; The stride is computed rather than stored: height in pixels, times two bytes per row
; because the glyphs are 2bpp, times the glyph's width in tile columns. There is no
; special case for glyph 0, so a font blob has no header - the first glyph starts at
; byte zero. It returns nothing; both results are left in WRAM. gex2's
; call_01_4cab_Text_SelectGlyph
    call call_01_4df4_Text_CharToGlyphIndex           ;; 01:4a7f $cd $f4 $4d
    push AF                                           ;; 01:4a82 $f5
    ld   HL, wDBAD_Font_WidthTable                    ;; 01:4a83 $21 $ad $db
    ld   E, [HL]                                      ;; 01:4a86 $5e
    inc  HL                                           ;; 01:4a87 $23
    ld   D, [HL]                                      ;; 01:4a88 $56
    ld   L, A                                         ;; 01:4a89 $6f
    ld   H, $00                                       ;; 01:4a8a $26 $00
    add  HL, DE                                       ;; 01:4a8c $19
    ld   A, [HL]                                      ;; 01:4a8d $7e
    ld   [wDBC9_Text_GlyphAdvance], A                 ;; 01:4a8e $ea $c9 $db
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:4a91 $fa $b0 $db
    add  A, A                                         ;; 01:4a94 $87
    ld   C, A                                         ;; 01:4a95 $4f
    ld   A, [wDBAF_Font_GlyphWidthCols]               ;; 01:4a96 $fa $af $db
    ld   B, A                                         ;; 01:4a99 $47
    xor  A, A                                         ;; 01:4a9a $af
.jr_01_4a9b:
    add  A, C                                         ;; 01:4a9b $81
    dec  B                                            ;; 01:4a9c $05
    jr   NZ, .jr_01_4a9b                              ;; 01:4a9d $20 $fc
    ld   E, A                                         ;; 01:4a9f $5f
    ld   D, $00                                       ;; 01:4aa0 $16 $00
    ld   HL, wDBAB_Font_GlyphBase                     ;; 01:4aa2 $21 $ab $db
    ld   A, [HL+]                                     ;; 01:4aa5 $2a
    ld   H, [HL]                                      ;; 01:4aa6 $66
    ld   L, A                                         ;; 01:4aa7 $6f
    pop  AF                                           ;; 01:4aa8 $f1
    and  A, A                                         ;; 01:4aa9 $a7
    jr   Z, .jr_01_4ab0                               ;; 01:4aaa $28 $04
.jr_01_4aac:
    add  HL, DE                                       ;; 01:4aac $19
    dec  A                                            ;; 01:4aad $3d
    jr   NZ, .jr_01_4aac                              ;; 01:4aae $20 $fc
.jr_01_4ab0:
    ld   A, L                                         ;; 01:4ab0 $7d
    ld   [wDBBD_Text_GlyphPtr], A                     ;; 01:4ab1 $ea $bd $db
    ld   A, H                                         ;; 01:4ab4 $7c
    ld   [wDBBE_Text_GlyphPtrHi], A                                   ;; 01:4ab5 $ea $be $db
    ret                                               ;; 01:4ab8 $c9
