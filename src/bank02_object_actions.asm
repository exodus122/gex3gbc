data_02_582e:
    ret                                                ;; 02:582e $c9
    db   $cd, $8a, $28, $cd, $8b, $2b, $cd, $5d        ;; 02:582f ????????
    db   $2a, $c2, $be, $2b, $c9                       ;; 02:5837 ?????

data_02_583c:
    call call_00_29f5                                  ;; 02:583c $cd $f5 $29
    jr   Z, .jr_02_5850                                ;; 02:583f $28 $0f
    ld   HL, .data_02_5857                             ;; 02:5841 $21 $57 $58
    call call_00_2c20                                  ;; 02:5844 $cd $20 $2c
    call call_00_288c_ObjectUnkAndSet14                                  ;; 02:5847 $cd $8a $28
    call call_00_2b8b                                  ;; 02:584a $cd $8b $2b
    call call_00_2c67_Particle_InitBurst                                  ;; 02:584d $cd $67 $2c
.jr_02_5850:
    call call_00_2c89_Particle_UpdateBurst                                  ;; 02:5850 $cd $89 $2c
    jp   Z, jp_00_2bbe                                 ;; 02:5853 $ca $be $2b
    ret                                                ;; 02:5856 $c9
.data_02_5857:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f        ;; 02:5857 ........
    db   $cd, $f5, $29, $28, $0a, $0e, $80, $cd        ;; 02:585f ????????
    db   $80, $29, $0e, $f0, $cd, $0d, $29, $cd        ;; 02:5867 ????????
    db   $8a, $29, $cb, $7e, $28, $17, $0e, $00        ;; 02:586f ????????
    db   $cd, $c8, $28, $cd, $22, $29, $c0, $cd        ;; 02:5877 ????????
    db   $8a, $29, $e6, $7f, $ee, $40, $77, $cd        ;; 02:587f ????????
    db   $0f, $23, $c3, $0d, $29, $0e, $01, $cd        ;; 02:5887 ????????
    db   $c8, $28, $cd, $8a, $29, $01, $01, $00        ;; 02:588f ????????
    db   $cb, $76, $20, $03, $01, $ff, $ff, $26        ;; 02:5897 ????????
    db   $d8, $fa, $00, $da, $f6, $0e, $6f, $79        ;; 02:589f ????????
    db   $86, $22, $78, $8e, $77, $cd, $c9, $26        ;; 02:58a7 ????????
    db   $cd, $22, $29, $c0, $cd, $8a, $29, $cb        ;; 02:58af ????????
    db   $fe, $0e, $78, $c3, $0d, $29, $cd, $f5        ;; 02:58b7 ????????
    db   $29, $28, $0a, $0e, $80, $cd, $80, $29        ;; 02:58bf ????????
    db   $0e, $f0, $cd, $0d, $29, $cd, $8a, $29        ;; 02:58c7 ????????
    db   $cb, $7e, $28, $17, $0e, $00, $cd, $dc        ;; 02:58cf ????????
    db   $28, $cd, $22, $29, $c0, $cd, $8a, $29        ;; 02:58d7 ????????
    db   $e6, $7f, $ee, $40, $77, $cd, $0f, $23        ;; 02:58df ????????
    db   $c3, $0d, $29, $0e, $01, $cd, $dc, $28        ;; 02:58e7 ????????
    db   $cd, $8a, $29, $01, $01, $00, $cb, $76        ;; 02:58ef ????????
    db   $20, $03, $01, $ff, $ff, $26, $d8, $fa        ;; 02:58f7 ????????
    db   $00, $da, $f6, $10, $6f, $79, $86, $22        ;; 02:58ff ????????
    db   $78, $8e, $77, $cd, $22, $29, $c0, $cd        ;; 02:5907 ????????
    db   $8a, $29, $cb, $fe, $0e, $78, $c3, $0d        ;; 02:590f ????????
    db   $29, $fa, $71, $dc, $0f, $e6, $0f, $6f        ;; 02:5917 ????????
    db   $26, $00, $29, $29, $01, $4f, $59, $09        ;; 02:591f ????????
    db   $4d, $44, $cd, $35, $28, $26, $d8, $fa        ;; 02:5927 ????????
    db   $00, $da, $f6, $0e, $6f, $0a, $83, $22        ;; 02:592f ????????
    db   $03, $0a, $8a, $77, $03, $cd, $f3, $27        ;; 02:5937 ????????
    db   $26, $d8, $fa, $00, $da, $f6, $10, $6f        ;; 02:593f ????????
    db   $0a, $83, $22, $03, $0a, $8a, $77, $c9        ;; 02:5947 ????????
    db   $00, $00, $de, $ff, $fe, $ff, $dc, $ff        ;; 02:594f ????????
    db   $fc, $ff, $e0, $ff, $fc, $ff, $e0, $ff        ;; 02:5957 ????????
    db   $fa, $ff, $e2, $ff, $fc, $ff, $e4, $ff        ;; 02:595f ????????
    db   $fe, $ff, $e2, $ff, $00, $00, $e4, $ff        ;; 02:5967 ????????
    db   $00, $00, $e2, $ff, $fe, $ff, $e0, $ff        ;; 02:596f ????????
    db   $fe, $ff, $de, $ff, $fc, $ff, $dc, $ff        ;; 02:5977 ????????
    db   $fa, $ff, $da, $ff, $fc, $ff, $d8, $ff        ;; 02:597f ????????
    db   $fe, $ff, $da, $ff, $00, $00, $dc, $ff        ;; 02:5987 ????????
    db   $cd, $d2, $59, $c5, $cd, $10, $2b, $c1        ;; 02:598f ????????
    db   $48, $cc, $92, $37, $3e, $03, $c3, $ac        ;; 02:5997 ????????
    db   $72, $00, $04, $01, $05, $02, $06, $03        ;; 02:599f ????????
    db   $07, $04, $08, $cd, $f5, $29, $0e, $78        ;; 02:59a7 ????????
    db   $c4, $0d, $29, $cd, $d2, $59, $cd, $10        ;; 02:59af ????????
    db   $2b, $c0, $cd, $0f, $23, $79, $a7, $c8        ;; 02:59b7 ????????
    db   $cd, $22, $29, $c0, $0e, $01, $cd, $aa        ;; 02:59bf ????????
    db   $28, $0e, $00, $cd, $99, $22, $3e, $04        ;; 02:59c7 ????????
    db   $c3, $ac, $72, $cd, $3a, $29, $d6, $09        ;; 02:59cf ????????
    db   $6f, $26, $00, $29, $11, $e3, $59, $19        ;; 02:59d7 ????????
    db   $46, $23, $4e, $c9, $00, $04, $01, $05        ;; 02:59df ????????
    db   $02, $06, $03, $07, $04, $08, $cd, $f5        ;; 02:59e7 ????????
    db   $29, $28, $0e, $cd, $76, $29, $0e, $d0        ;; 02:59ef ????????
    db   $e6, $20, $20, $02, $0e, $30, $cd, $c8        ;; 02:59f7 ????????
    db   $28, $cd, $c0, $24, $c9                       ;; 02:59ff ?????

data_02_5a04:
    call call_00_29f5                                  ;; 02:5a04 $cd $f5 $29
    jr   NZ, jr_02_5a83                                ;; 02:5a07 $20 $7a
    ld   C, $00                                        ;; 02:5a09 $0e $00
    call call_00_22b1                                  ;; 02:5a0b $cd $b1 $22
    ld   HL, .data_02_5a14                             ;; 02:5a0e $21 $14 $5a
    jp   call_00_2c20                                  ;; 02:5a11 $c3 $20 $2c
.data_02_5a14:
    db   $00, $00, $00, $00, $73, $4e, $1f, $00        ;; 02:5a14 ........

data_02_5a1c:
    call call_00_29f5                                  ;; 02:5a1c $cd $f5 $29
    jr   NZ, jr_02_5a83                                ;; 02:5a1f $20 $62
    call call_02_5a75                                  ;; 02:5a21 $cd $75 $5a
    ld   A, [wDC7B]                                    ;; 02:5a24 $fa $7b $dc
    ld   HL, wDA00_CurrentObjectAddr                                     ;; 02:5a27 $21 $00 $da
    cp   A, [HL]                                       ;; 02:5a2a $be
    ret  NZ                                            ;; 02:5a2b $c0
    ld   A, $02                                        ;; 02:5a2c $3e $02
    call call_02_72ac                                  ;; 02:5a2e $cd $ac $72
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 02:5a31 $fa $6c $db
    cp   A, $07                                        ;; 02:5a34 $fe $07
    ld   A, $2c                                        ;; 02:5a36 $3e $2c
    jr   Z, .jr_02_5a45                                ;; 02:5a38 $28 $0b
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 02:5a3a $fa $6c $db
    cp   A, $08                                        ;; 02:5a3d $fe $08
    ld   A, $39                                        ;; 02:5a3f $3e $39
    jr   Z, .jr_02_5a45                                ;; 02:5a41 $28 $02
    ld   A, $0c                                        ;; 02:5a43 $3e $0c
.jr_02_5a45:
    call call_02_54f9                                  ;; 02:5a45 $cd $f9 $54
    call call_00_230f                                  ;; 02:5a48 $cd $0f $23
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5a4b $fa $1e $dc
    and  A, A                                          ;; 02:5a4e $a7
    jr   Z, .jr_02_5a6a                                ;; 02:5a4f $28 $19
    push BC                                            ;; 02:5a51 $c5
    ld   B, $00                                        ;; 02:5a52 $06 $00
    ld   HL, .data_02_5a71                             ;; 02:5a54 $21 $71 $5a
    add  HL, BC                                        ;; 02:5a57 $09
    ld   C, [HL]                                       ;; 02:5a58 $4e
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 02:5a59 $21 $1e $dc
    ld   L, [HL]                                       ;; 02:5a5c $6e
    ld   H, $00                                        ;; 02:5a5d $26 $00
    ld   DE, wDC5C                                     ;; 02:5a5f $11 $5c $dc
    add  HL, DE                                        ;; 02:5a62 $19
    ld   A, [HL]                                       ;; 02:5a63 $7e
    or   A, C                                          ;; 02:5a64 $b1
    ld   [HL], A                                       ;; 02:5a65 $77
    pop  BC                                            ;; 02:5a66 $c1
    jp   call_00_2260                                    ;; 02:5a67 $c3 $60 $22
.jr_02_5a6a:
    ld   HL, wDC5B                                     ;; 02:5a6a $21 $5b $dc
    ld   [HL], C                                       ;; 02:5a6d $71
    jp   call_00_2260                                    ;; 02:5a6e $c3 $60 $22
.data_02_5a71:
    db   $00, $01, $02, $04                            ;; 02:5a71 ????

call_02_5a75:
    ld   HL, .data_02_5a7b                             ;; 02:5a75 $21 $7b $5a
    jp   call_00_2c20                                  ;; 02:5a78 $c3 $20 $2c
.data_02_5a7b:
    db   $00, $00, $00, $00, $73, $4e, $e0, $03        ;; 02:5a7b ........

jr_02_5a83:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5a83 $fa $1e $dc
    and  A, A                                          ;; 02:5a86 $a7
    ret  NZ                                            ;; 02:5a87 $c0
    call call_00_230f                                  ;; 02:5a88 $cd $0f $23
    ld   B, $00                                        ;; 02:5a8b $06 $00
    ld   HL, $b19                                      ;; 02:5a8d $21 $19 $0b
    add  HL, BC                                        ;; 02:5a90 $09
    bit  7, [HL]                                       ;; 02:5a91 $cb $7e
    jr   Z, .jr_02_5aaa                                ;; 02:5a93 $28 $15
    push HL                                            ;; 02:5a95 $e5
    ld   [wDAD6_ReturnBank], A                                    ;; 02:5a96 $ea $d6 $da
    ld   A, $01                                        ;; 02:5a99 $3e $01
    ld   HL, entry_01_4ae7                              ;; 02:5a9b $21 $e7 $4a
    call call_00_0edd_CallAltBankFunc                                  ;; 02:5a9e $cd $dd $0e
    pop  HL                                            ;; 02:5aa1 $e1
    ld   C, [HL]                                       ;; 02:5aa2 $4e
    res  7, C                                          ;; 02:5aa3 $cb $b9
    cp   A, C                                          ;; 02:5aa5 $b9
    jr   C, .jr_02_5aba                                ;; 02:5aa6 $38 $12
    jr   .jr_02_5aca                                   ;; 02:5aa8 $18 $20
.jr_02_5aaa:
    push HL                                            ;; 02:5aaa $e5
    ld   [wDAD6_ReturnBank], A                                    ;; 02:5aab $ea $d6 $da
    ld   A, $01                                        ;; 02:5aae $3e $01
    ld   HL, entry_01_4ab9                              ;; 02:5ab0 $21 $b9 $4a
    call call_00_0edd_CallAltBankFunc                                  ;; 02:5ab3 $cd $dd $0e
    pop  HL                                            ;; 02:5ab6 $e1
    cp   A, [HL]                                       ;; 02:5ab7 $be
    jr   NC, .jr_02_5aca                               ;; 02:5ab8 $30 $10
.jr_02_5aba:
    call call_00_2962_ObjectGetActionId                                  ;; 02:5aba $cd $62 $29
    cp   A, $00                                        ;; 02:5abd $fe $00
    ret  Z                                             ;; 02:5abf $c8
    ld   C, $00                                        ;; 02:5ac0 $0e $00
    call call_00_2299                                  ;; 02:5ac2 $cd $99 $22
    ld   A, $00                                        ;; 02:5ac5 $3e $00
    jp   call_02_72ac                                  ;; 02:5ac7 $c3 $ac $72
.jr_02_5aca:
    call call_00_2962_ObjectGetActionId                                  ;; 02:5aca $cd $62 $29
    cp   A, $01                                        ;; 02:5acd $fe $01
    ret  Z                                             ;; 02:5acf $c8
    ld   C, $01                                        ;; 02:5ad0 $0e $01
    call call_00_2299                                  ;; 02:5ad2 $cd $99 $22
    ld   A, $01                                        ;; 02:5ad5 $3e $01
    jp   call_02_72ac                                  ;; 02:5ad7 $c3 $ac $72

data_02_5ada:
    call call_00_29f5                                  ;; 02:5ada $cd $f5 $29
    jr   NZ, jr_02_5af8                                ;; 02:5add $20 $19
    ld   C, $00                                        ;; 02:5adf $0e $00
    jp   call_00_22b1                                  ;; 02:5ae1 $c3 $b1 $22

data_02_5ae4:
    call call_00_29f5                                  ;; 02:5ae4 $cd $f5 $29
    jr   NZ, jr_02_5af8                                ;; 02:5ae7 $20 $0f
    ld   C, $01                                        ;; 02:5ae9 $0e $01
    jp   call_00_22b1                                  ;; 02:5aeb $c3 $b1 $22
    db   $cd, $f5, $29, $20, $05, $0e, $02, $c3        ;; 02:5aee ????????
    db   $b1, $22                                      ;; 02:5af6 ??

jr_02_5af8:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5af8 $fa $1e $dc
    and  A, A                                          ;; 02:5afb $a7
    ret  NZ                                            ;; 02:5afc $c0
    call call_00_230f                                  ;; 02:5afd $cd $0f $23
    ld   B, $00                                        ;; 02:5b00 $06 $00
    ld   HL, $b19                                      ;; 02:5b02 $21 $19 $0b
    add  HL, BC                                        ;; 02:5b05 $09
    bit  7, [HL]                                       ;; 02:5b06 $cb $7e
    jr   Z, .jr_02_5b1f                                ;; 02:5b08 $28 $15
    push HL                                            ;; 02:5b0a $e5
    ld   [wDAD6_ReturnBank], A                                    ;; 02:5b0b $ea $d6 $da
    ld   A, $01                                        ;; 02:5b0e $3e $01
    ld   HL, entry_01_4ae7                              ;; 02:5b10 $21 $e7 $4a
    call call_00_0edd_CallAltBankFunc                                  ;; 02:5b13 $cd $dd $0e
    pop  HL                                            ;; 02:5b16 $e1
    ld   C, [HL]                                       ;; 02:5b17 $4e
    res  7, C                                          ;; 02:5b18 $cb $b9
    cp   A, C                                          ;; 02:5b1a $b9
    jr   C, .jr_02_5b2f                                ;; 02:5b1b $38 $12
    jr   .jr_02_5b6e                                   ;; 02:5b1d $18 $4f
.jr_02_5b1f:
    push HL                                            ;; 02:5b1f $e5
    ld   [wDAD6_ReturnBank], A                                    ;; 02:5b20 $ea $d6 $da
    ld   A, $01                                        ;; 02:5b23 $3e $01
    ld   HL, entry_01_4ab9                              ;; 02:5b25 $21 $b9 $4a
    call call_00_0edd_CallAltBankFunc                                  ;; 02:5b28 $cd $dd $0e
    pop  HL                                            ;; 02:5b2b $e1
    cp   A, [HL]                                       ;; 02:5b2c $be
    jr   NC, .jr_02_5b6e                               ;; 02:5b2d $30 $3f
.jr_02_5b2f:
    call call_00_2962_ObjectGetActionId                                  ;; 02:5b2f $cd $62 $29
    cp   A, $03                                        ;; 02:5b32 $fe $03
    jr   Z, .jr_02_5b40                                ;; 02:5b34 $28 $0a
    ld   C, $03                                        ;; 02:5b36 $0e $03
    call call_00_2299                                  ;; 02:5b38 $cd $99 $22
    ld   A, $03                                        ;; 02:5b3b $3e $03
    call call_02_72ac                                  ;; 02:5b3d $cd $ac $72
.jr_02_5b40:
    call call_00_230f                                  ;; 02:5b40 $cd $0f $23
    ld   B, $00                                        ;; 02:5b43 $06 $00
    ld   HL, .data_02_5b7e                             ;; 02:5b45 $21 $7e $5b
    add  HL, BC                                        ;; 02:5b48 $09
    ld   C, [HL]                                       ;; 02:5b49 $4e
    ld   H, $d8                                        ;; 02:5b4a $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 02:5b4c $fa $00 $da
    or   A, $0a                                        ;; 02:5b4f $f6 $0a
    ld   L, A                                          ;; 02:5b51 $6f
    ld   A, C                                          ;; 02:5b52 $79
    add  A, $40                                        ;; 02:5b53 $c6 $40
    cp   A, [HL]                                       ;; 02:5b55 $be
    ld   [HL], A                                       ;; 02:5b56 $77
    jr   Z, .jr_02_5b5f                                ;; 02:5b57 $28 $06
    ld   A, L                                          ;; 02:5b59 $7d
    xor  A, $0f                                        ;; 02:5b5a $ee $0f
    ld   L, A                                          ;; 02:5b5c $6f
    set  1, [HL]                                       ;; 02:5b5d $cb $ce
.jr_02_5b5f:
    ld   HL, .data_02_5b8a                             ;; 02:5b5f $21 $8a $5b
    ld   A, C                                          ;; 02:5b62 $79
    cp   A, $09                                        ;; 02:5b63 $fe $09
    jp   C, call_00_2c20                               ;; 02:5b65 $da $20 $2c
    ld   HL, .data_02_5b92                             ;; 02:5b68 $21 $92 $5b
    jp   call_00_2c20                                  ;; 02:5b6b $c3 $20 $2c
.jr_02_5b6e:
    call call_00_2962_ObjectGetActionId                                  ;; 02:5b6e $cd $62 $29
    cp   A, $01                                        ;; 02:5b71 $fe $01
    ret  Z                                             ;; 02:5b73 $c8
    ld   C, $01                                        ;; 02:5b74 $0e $01
    call call_00_2299                                  ;; 02:5b76 $cd $99 $22
    ld   A, $01                                        ;; 02:5b79 $3e $01
    jp   call_02_72ac                                  ;; 02:5b7b $c3 $ac $72
.data_02_5b7e:
    db   $00, $00, $01, $02, $03, $05, $07, $09        ;; 02:5b7e ?.......
    db   $0a, $04, $06, $08                            ;; 02:5b86 ....
.data_02_5b8a:
    db   $00, $00, $00, $00, $ff, $7f, $1f, $00        ;; 02:5b8a ........
.data_02_5b92:
    db   $00, $00, $00, $00, $1f, $00, $ff, $03        ;; 02:5b92 ........

data_02_5b9a:
    call call_00_29f5                                  ;; 02:5b9a $cd $f5 $29
    jr   Z, .jr_02_5ba9                                ;; 02:5b9d $28 $0a
    ld   C, $30                                        ;; 02:5b9f $0e $30
    call call_00_28dc_ObjectSet1D                                  ;; 02:5ba1 $cd $dc $28
    ld   C, $3c                                        ;; 02:5ba4 $0e $3c
    call call_00_290d_ObjectSetTimer1A                                  ;; 02:5ba6 $cd $0d $29
.jr_02_5ba9:
    call call_00_244a                                  ;; 02:5ba9 $cd $4a $24
    call call_00_2922_ObjectTimer1ACountdown                                  ;; 02:5bac $cd $22 $29
    jp   Z, call_00_2b80                               ;; 02:5baf $ca $80 $2b
    ret                                                ;; 02:5bb2 $c9

entry_02_5bb3:
    db   $26, $d8, $fa, $00, $da, $f6, $0e, $6f        ;; 02:5bb3 ????????
    db   $fa, $f9, $db, $c6, $50, $22, $fa, $fa        ;; 02:5bbb ????????
    db   $db, $ce, $00, $22, $fa, $fb, $db, $c6        ;; 02:5bc3 ????????
    db   $08, $22, $fa, $fc, $db, $ce, $00, $77        ;; 02:5bcb ????????
    db   $c9                                           ;; 02:5bd3 ?

data_02_5bd4:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5bd4 $fa $1e $dc
    and  A, A                                          ;; 02:5bd7 $a7
    jr   Z, .jr_02_5be4                                ;; 02:5bd8 $28 $0a
    ld   A, [wDCD2]                                    ;; 02:5bda $fa $d2 $dc
    and  A, A                                          ;; 02:5bdd $a7
    ld   A, $01                                        ;; 02:5bde $3e $01
    jp   NZ, call_02_72ac                              ;; 02:5be0 $c2 $ac $72
    ret                                                ;; 02:5be3 $c9
.jr_02_5be4:
    ld   HL, wDC5C                                     ;; 02:5be4 $21 $5c $dc
    bit  0, [HL]                                       ;; 02:5be7 $cb $46
    ld   A, $01                                        ;; 02:5be9 $3e $01
    jp   Z, call_02_72ac                               ;; 02:5beb $ca $ac $72
    ret                                                ;; 02:5bee $c9

data_02_5bef:
    ld   A, [wDCD2]                                    ;; 02:5bef $fa $d2 $dc
    cp   A, $81                                        ;; 02:5bf2 $fe $81
    ld   A, $02                                        ;; 02:5bf4 $3e $02
    jp   Z, call_02_72ac                               ;; 02:5bf6 $ca $ac $72
    ret                                                ;; 02:5bf9 $c9

data_02_5bfa:
    call call_00_29f5                                  ;; 02:5bfa $cd $f5 $29
    jr   Z, .jr_02_5c23                                ;; 02:5bfd $28 $24
    ld   A, $1e                                        ;; 02:5bff $3e $1e
    call call_00_0ff5                                  ;; 02:5c01 $cd $f5 $0f
    ld   HL, .data_02_5c3b                             ;; 02:5c04 $21 $3b $5c
    call call_00_2c20                                  ;; 02:5c07 $cd $20 $2c
    call call_00_288c_ObjectUnkAndSet14                                  ;; 02:5c0a $cd $8a $28
    call call_00_2b8b                                  ;; 02:5c0d $cd $8b $2b
    call call_00_2c67_Particle_InitBurst                                  ;; 02:5c10 $cd $67 $2c
    ld   C, $3c                                        ;; 02:5c13 $0e $3c
    call call_00_290d_ObjectSetTimer1A                                  ;; 02:5c15 $cd $0d $29
    call call_00_230f                                  ;; 02:5c18 $cd $0f $23
    ld   B, $00                                        ;; 02:5c1b $06 $00
    ld   HL, wDC5C                                     ;; 02:5c1d $21 $5c $dc
    add  HL, BC                                        ;; 02:5c20 $09
    set  0, [HL]                                       ;; 02:5c21 $cb $c6
.jr_02_5c23:
    call call_00_2c89_Particle_UpdateBurst                                  ;; 02:5c23 $cd $89 $2c
    ret  NZ                                            ;; 02:5c26 $c0
    call call_00_2922_ObjectTimer1ACountdown                                  ;; 02:5c27 $cd $22 $29
    ret  NZ                                            ;; 02:5c2a $c0
    call call_00_230f                                  ;; 02:5c2b $cd $0f $23
    inc  C                                             ;; 02:5c2e $0c
    dec  C                                             ;; 02:5c2f $0d
    jp   Z, jp_00_2b7a                                 ;; 02:5c30 $ca $7a $2b
    ld   HL, wDB6A                                     ;; 02:5c33 $21 $6a $db
    set  4, [HL]                                       ;; 02:5c36 $cb $e6
    jp   jp_00_2b7a                                    ;; 02:5c38 $c3 $7a $2b
.data_02_5c3b:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f        ;; 02:5c3b ........

data_02_5c43:
    ld   A, $03                                        ;; 02:5c43 $3e $03
    ld   [wDCC4], A                                    ;; 02:5c45 $ea $c4 $dc
    call call_02_5d02                                  ;; 02:5c48 $cd $02 $5d
    ld   A, $01                                        ;; 02:5c4b $3e $01
    jp   call_02_72ac                                  ;; 02:5c4d $c3 $ac $72

data_02_5c50:
    call call_00_29f5                                  ;; 02:5c50 $cd $f5 $29
    jr   Z, .jr_02_5c62                                ;; 02:5c53 $28 $0d
    call call_02_5d02                                  ;; 02:5c55 $cd $02 $5d
    ld   C, $20                                        ;; 02:5c58 $0e $20
    call call_00_28c8_ObjectSet1B                                  ;; 02:5c5a $cd $c8 $28
    ld   C, $28                                        ;; 02:5c5d $0e $28
    call call_00_28dc_ObjectSet1D                                  ;; 02:5c5f $cd $dc $28
.jr_02_5c62:
    call call_00_251c                                  ;; 02:5c62 $cd $1c $25
    call call_00_244a                                  ;; 02:5c65 $cd $4a $24
    call call_00_2766                                  ;; 02:5c68 $cd $66 $27
    ret  C                                             ;; 02:5c6b $d8
    call call_00_299f_ObjectFlipFacingDirection                                  ;; 02:5c6c $cd $9f $29
    ld   A, $02                                        ;; 02:5c6f $3e $02
    jp   call_02_72ac                                  ;; 02:5c71 $c3 $ac $72

data_02_5c74:
    call call_00_2a5d                                  ;; 02:5c74 $cd $5d $2a
    ret  Z                                             ;; 02:5c77 $c8
    ld   C, $05                                        ;; 02:5c78 $0e $05
    call call_00_3792                                  ;; 02:5c7a $cd $92 $37
    ld   A, $03                                        ;; 02:5c7d $3e $03
    jp   call_02_72ac                                  ;; 02:5c7f $c3 $ac $72

data_02_5c82:
    ld   A, [wDCDB]                                    ;; 02:5c82 $fa $db $dc
    and  A, A                                          ;; 02:5c85 $a7
    jr   NZ, .jr_02_5c93                               ;; 02:5c86 $20 $0b
    ld   C, $1f                                        ;; 02:5c88 $0e $1f
    call call_00_2b10                                  ;; 02:5c8a $cd $10 $2b
    ld   A, $01                                        ;; 02:5c8d $3e $01
    jp   Z, call_02_72ac                               ;; 02:5c8f $ca $ac $72
    ret                                                ;; 02:5c92 $c9
.jr_02_5c93:
    xor  A, A                                          ;; 02:5c93 $af
    ld   [wDCDB], A                                    ;; 02:5c94 $ea $db $dc
    ld   HL, wDCC4                                     ;; 02:5c97 $21 $c4 $dc
    dec  [HL]                                          ;; 02:5c9a $35
    ld   A, $05                                        ;; 02:5c9b $3e $05
    jp   NZ, call_02_72ac                              ;; 02:5c9d $c2 $ac $72
    ld   A, $06                                        ;; 02:5ca0 $3e $06
    jp   call_02_72ac                                  ;; 02:5ca2 $c3 $ac $72
    db   $cd, $f5, $29, $3e, $19, $c4, $f5, $0f        ;; 02:5ca5 ????????
    db   $fa, $71, $dc, $e6, $0f, $fe, $0c, $21        ;; 02:5cad ????????
    db   $c8, $5c, $da, $20, $2c, $21, $c0, $5c        ;; 02:5cb5 ????????
    db   $c3, $20, $2c, $00, $00, $00, $00, $1f        ;; 02:5cbd ????????
    db   $00, $ff, $7f, $00, $00, $84, $10, $08        ;; 02:5cc5 ????????
    db   $21, $8c, $31, $cd, $f5, $29, $28, $1b        ;; 02:5ccd ????????
    db   $3e, $1a, $cd, $f5, $0f, $cd, $02, $5d        ;; 02:5cd5 ????????
    db   $cd, $76, $29, $0e, $f2, $cb, $6f, $20        ;; 02:5cdd ????????
    db   $02, $0e, $0e, $cd, $c8, $28, $0e, $05        ;; 02:5ce5 ????????
    db   $cd, $dc, $28, $cd, $c0, $24, $cd, $ee        ;; 02:5ced ????????
    db   $24, $cd, $5d, $2a, $c8, $0e, $03, $cd        ;; 02:5cf5 ????????
    db   $ef, $21, $c3, $7a, $2b                       ;; 02:5cfd ?????

call_02_5d02:
    ld   HL, .data_02_5d08                             ;; 02:5d02 $21 $08 $5d
    jp   call_00_2c20                                  ;; 02:5d05 $c3 $20 $2c
.data_02_5d08:
    db   $00, $00, $00, $00, $1f, $00, $ff, $7f        ;; 02:5d08 ........

data_02_5d10:
    ld   H, $d8                                        ;; 02:5d10 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 02:5d12 $fa $00 $da
    or   A, $0e                                        ;; 02:5d15 $f6 $0e
    ld   L, A                                          ;; 02:5d17 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:5d18 $fa $0e $d8
    sub  A, [HL]                                       ;; 02:5d1b $96
    ld   E, A                                          ;; 02:5d1c $5f
    inc  HL                                            ;; 02:5d1d $23
    ld   A, [wD80F_PlayerXPosition]                                    ;; 02:5d1e $fa $0f $d8
    sbc  A, [HL]                                       ;; 02:5d21 $9e
    ld   D, A                                          ;; 02:5d22 $57
    push AF                                            ;; 02:5d23 $f5
    jr   NC, .jr_02_5d2d                               ;; 02:5d24 $30 $07
    xor  A, A                                          ;; 02:5d26 $af
    sub  A, E                                          ;; 02:5d27 $93
    ld   E, A                                          ;; 02:5d28 $5f
    ld   A, $00                                        ;; 02:5d29 $3e $00
    sbc  A, D                                          ;; 02:5d2b $9a
    ld   D, A                                          ;; 02:5d2c $57
.jr_02_5d2d:
    ld   A, D                                          ;; 02:5d2d $7a
    and  A, A                                          ;; 02:5d2e $a7
    jr   NZ, .jr_02_5d36                               ;; 02:5d2f $20 $05
    ld   A, E                                          ;; 02:5d31 $7b
    cp   A, $a0                                        ;; 02:5d32 $fe $a0
    jr   C, .jr_02_5d38                                ;; 02:5d34 $38 $02
.jr_02_5d36:
    ld   A, $a0                                        ;; 02:5d36 $3e $a0
.jr_02_5d38:
    srl  A                                             ;; 02:5d38 $cb $3f
    srl  A                                             ;; 02:5d3a $cb $3f
    ld   L, A                                          ;; 02:5d3c $6f
    ld   H, $00                                        ;; 02:5d3d $26 $00
    ld   DE, .data_02_5d57                             ;; 02:5d3f $11 $57 $5d
    add  HL, DE                                        ;; 02:5d42 $19
    pop  AF                                            ;; 02:5d43 $f1
    ld   A, [HL]                                       ;; 02:5d44 $7e
    jr   NC, .jr_02_5d49                               ;; 02:5d45 $30 $02
    cpl                                                ;; 02:5d47 $2f
    inc  A                                             ;; 02:5d48 $3c
.jr_02_5d49:
    ld   C, A                                          ;; 02:5d49 $4f
    call call_00_28c8_ObjectSet1B                                  ;; 02:5d4a $cd $c8 $28
    ld   C, $10                                        ;; 02:5d4d $0e $10
    call call_00_28dc_ObjectSet1D                                  ;; 02:5d4f $cd $dc $28
    ld   A, $01                                        ;; 02:5d52 $3e $01
    jp   call_02_72ac                                  ;; 02:5d54 $c3 $ac $72
.data_02_5d57:
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 02:5d57 ??.....?
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10        ;; 02:5d5f ??.?.??.
    db   $11, $12, $13, $14, $15, $16, $17, $18        ;; 02:5d67 ?....???
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21        ;; 02:5d6f ?????.?.
    db   $22, $23, $24, $25, $27, $28, $29, $2a        ;; 02:5d77 ???.????
    db   $2b                                           ;; 02:5d7f ?

data_02_5d80:
    call call_00_24c0                                  ;; 02:5d80 $cd $c0 $24
    call call_00_24ee                                  ;; 02:5d83 $cd $ee $24
    call call_00_28d2_ObjectGet1D                                  ;; 02:5d86 $cd $d2 $28
    ld   C, A                                          ;; 02:5d89 $4f
    ld   H, $d8                                        ;; 02:5d8a $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 02:5d8c $fa $00 $da
    or   A, $10                                        ;; 02:5d8f $f6 $10
    ld   L, A                                          ;; 02:5d91 $6f
    ld   A, [HL]                                       ;; 02:5d92 $7e
    sub  A, $88                                        ;; 02:5d93 $d6 $88
    jp   NC, call_00_2b80                              ;; 02:5d95 $d2 $80 $2b
    bit  7, C                                          ;; 02:5d98 $cb $79
    jr   Z, .jr_02_5db5                                ;; 02:5d9a $28 $19
    ld   C, $01                                        ;; 02:5d9c $0e $01
    ld   A, [HL]                                       ;; 02:5d9e $7e
    sub  A, $25                                        ;; 02:5d9f $d6 $25
    jr   C, .jr_02_5dcd                                ;; 02:5da1 $38 $2a
    cp   A, $09                                        ;; 02:5da3 $fe $09
    jr   Z, .jr_02_5dc9                                ;; 02:5da5 $28 $22
    ld   C, $02                                        ;; 02:5da7 $0e $02
    cp   A, $1d                                        ;; 02:5da9 $fe $1d
    jr   Z, .jr_02_5dc9                                ;; 02:5dab $28 $1c
    ld   C, $03                                        ;; 02:5dad $0e $03
    cp   A, $3b                                        ;; 02:5daf $fe $3b
    ret  NZ                                            ;; 02:5db1 $c0
    jr   Z, .jr_02_5dc9                                ;; 02:5db2 $28 $15
    ret                                                ;; 02:5db4 $c9
.jr_02_5db5:
    ld   C, $02                                        ;; 02:5db5 $0e $02
    ld   A, [HL]                                       ;; 02:5db7 $7e
    sub  A, $25                                        ;; 02:5db8 $d6 $25
    cp   A, $0a                                        ;; 02:5dba $fe $0a
    jr   Z, .jr_02_5dc9                                ;; 02:5dbc $28 $0b
    ld   C, $03                                        ;; 02:5dbe $0e $03
    cp   A, $1e                                        ;; 02:5dc0 $fe $1e
    jr   Z, .jr_02_5dc9                                ;; 02:5dc2 $28 $05
    cp   A, $3c                                        ;; 02:5dc4 $fe $3c
    ret  NZ                                            ;; 02:5dc6 $c0
    ld   C, $04                                        ;; 02:5dc7 $0e $04
.jr_02_5dc9:
    ld   A, C                                          ;; 02:5dc9 $79
    jp   call_02_72ac                                  ;; 02:5dca $c3 $ac $72
.jr_02_5dcd:
    ld   A, $01                                        ;; 02:5dcd $3e $01
    ld   [wDCDB], A                                    ;; 02:5dcf $ea $db $dc
    ld   A, $05                                        ;; 02:5dd2 $3e $05
    jp   call_02_72ac                                  ;; 02:5dd4 $c3 $ac $72

data_02_5dd7:
    call call_00_2a5d                                  ;; 02:5dd7 $cd $5d $2a
    jp   NZ, call_00_2b80                              ;; 02:5dda $c2 $80 $2b
    ret                                                ;; 02:5ddd $c9

data_02_5dde:
    call call_00_29f5                                  ;; 02:5dde $cd $f5 $29
    ld   C, $20                                        ;; 02:5de1 $0e $20
    call NZ, call_00_28c8_ObjectSet1B                              ;; 02:5de3 $c4 $c8 $28
    ld   A, [wDC71]                                    ;; 02:5de6 $fa $71 $dc
    and  A, $07                                        ;; 02:5de9 $e6 $07
    ld   C, $10                                        ;; 02:5deb $0e $10
    call Z, call_00_2588                               ;; 02:5ded $cc $88 $25
    call call_00_251c                                  ;; 02:5df0 $cd $1c $25
    call call_00_2722                                  ;; 02:5df3 $cd $22 $27
    ret  Z                                             ;; 02:5df6 $c8
    call call_00_2a68                                  ;; 02:5df7 $cd $68 $2a
    call call_00_2976_ObjectGetFacingDirection                                  ;; 02:5dfa $cd $76 $29
    ld   HL, wDA12                                     ;; 02:5dfd $21 $12 $da
    cp   A, [HL]                                       ;; 02:5e00 $be
    ret  NZ                                            ;; 02:5e01 $c0
    ld   A, [wDA11]                                    ;; 02:5e02 $fa $11 $da
    cp   A, $40                                        ;; 02:5e05 $fe $40
    ld   A, $02                                        ;; 02:5e07 $3e $02
    jp   C, call_02_72ac                               ;; 02:5e09 $da $ac $72
    ret                                                ;; 02:5e0c $c9

data_02_5e0d:
    ld   C, $20                                        ;; 02:5e0d $0e $20
    call call_00_28dc_ObjectSet1D                                  ;; 02:5e0f $cd $dc $28
    ld   C, $28                                        ;; 02:5e12 $0e $28
    call call_00_2588                                  ;; 02:5e14 $cd $88 $25
    call call_00_251c                                  ;; 02:5e17 $cd $1c $25
    call call_00_28be_ObjectGet1B                                  ;; 02:5e1a $cd $be $28
    cp   A, $28                                        ;; 02:5e1d $fe $28
    ld   A, $03                                        ;; 02:5e1f $3e $03
    jp   Z, call_02_72ac                               ;; 02:5e21 $ca $ac $72
    ret                                                ;; 02:5e24 $c9

data_02_5e25:
    call call_00_251c                                  ;; 02:5e25 $cd $1c $25
    call call_00_244a                                  ;; 02:5e28 $cd $4a $24
    call call_00_2766                                  ;; 02:5e2b $cd $66 $27
    ld   A, $00                                        ;; 02:5e2e $3e $00
    jp   NC, call_02_72ac                              ;; 02:5e30 $d2 $ac $72
    ret                                                ;; 02:5e33 $c9

data_02_5e34:
    call call_00_29f5                                  ;; 02:5e34 $cd $f5 $29
    jr   Z, .jr_02_5e45                                ;; 02:5e37 $28 $0c
    call call_00_2766                                  ;; 02:5e39 $cd $66 $27
    ld   C, $00                                        ;; 02:5e3c $0e $00
    jr   C, .jr_02_5e42                                ;; 02:5e3e $38 $02
    ld   C, $01                                        ;; 02:5e40 $0e $01
.jr_02_5e42:
    call call_00_2980_ObjectSet19                                  ;; 02:5e42 $cd $80 $29
.jr_02_5e45:
    call call_00_298a_ObjectGet19                                  ;; 02:5e45 $cd $8a $29
    jr   Z, .jr_02_5e6d                                ;; 02:5e48 $28 $23
    ld   A, [wDC71]                                    ;; 02:5e4a $fa $71 $dc
    and  A, $07                                        ;; 02:5e4d $e6 $07
    ld   C, $10                                        ;; 02:5e4f $0e $10
    call Z, call_00_2588                               ;; 02:5e51 $cc $88 $25
    call call_00_251c                                  ;; 02:5e54 $cd $1c $25
    ret  Z                                             ;; 02:5e57 $c8
    call call_00_230f                                  ;; 02:5e58 $cd $0f $23
    ld   B, $00                                        ;; 02:5e5b $06 $00
    ld   HL, wDCD5                                     ;; 02:5e5d $21 $d5 $dc
    add  HL, BC                                        ;; 02:5e60 $09
    ld   A, [HL]                                       ;; 02:5e61 $7e
    and  A, A                                          ;; 02:5e62 $a7
    ld   A, $00                                        ;; 02:5e63 $3e $00
    jp   NZ, call_02_72ac                              ;; 02:5e65 $c2 $ac $72
    ld   A, $05                                        ;; 02:5e68 $3e $05
    jp   call_02_72ac                                  ;; 02:5e6a $c3 $ac $72
.jr_02_5e6d:
    call call_00_251c                                  ;; 02:5e6d $cd $1c $25
    call call_00_244a                                  ;; 02:5e70 $cd $4a $24
    call call_00_2766                                  ;; 02:5e73 $cd $66 $27
    ld   C, $01                                        ;; 02:5e76 $0e $01
    call NC, call_00_2980_ObjectSet19                              ;; 02:5e78 $d4 $80 $29
    ret                                                ;; 02:5e7b $c9

data_02_5e7c:
    call call_00_2a68                                  ;; 02:5e7c $cd $68 $2a
    ld   A, [wDA11]                                    ;; 02:5e7f $fa $11 $da
    cp   A, $30                                        ;; 02:5e82 $fe $30
    jr   C, .jr_02_5e8e                                ;; 02:5e84 $38 $08
    ld   C, $04                                        ;; 02:5e86 $0e $04
    call call_00_2588                                  ;; 02:5e88 $cd $88 $25
    jp   call_00_251c                                  ;; 02:5e8b $c3 $1c $25
.jr_02_5e8e:
    ld   A, [wDA12]                                    ;; 02:5e8e $fa $12 $da
    xor  A, $20                                        ;; 02:5e91 $ee $20
    ld   C, A                                          ;; 02:5e93 $4f
    call call_00_2958_ObjectSetFacingDirection                                  ;; 02:5e94 $cd $58 $29
    ld   C, $1e                                        ;; 02:5e97 $0e $1e
    call call_00_2588                                  ;; 02:5e99 $cd $88 $25
    call call_00_251c                                  ;; 02:5e9c $cd $1c $25
    jr   NZ, .jr_02_5eae                               ;; 02:5e9f $20 $0d
    ld   A, [wDA11]                                    ;; 02:5ea1 $fa $11 $da
    cp   A, $18                                        ;; 02:5ea4 $fe $18
    ret  NC                                            ;; 02:5ea6 $d0
    ld   HL, wDA12                                     ;; 02:5ea7 $21 $12 $da
    ld   C, [HL]                                       ;; 02:5eaa $4e
    call call_00_2958_ObjectSetFacingDirection                                  ;; 02:5eab $cd $58 $29
.jr_02_5eae:
    ld   C, $30                                        ;; 02:5eae $0e $30
    call call_00_28dc_ObjectSet1D                                  ;; 02:5eb0 $cd $dc $28
    ld   A, $01                                        ;; 02:5eb3 $3e $01
    jp   call_02_72ac                                  ;; 02:5eb5 $c3 $ac $72

data_02_5eb8:
    ld   C, $10                                        ;; 02:5eb8 $0e $10
    call call_00_2588                                  ;; 02:5eba $cd $88 $25
    call call_00_251c                                  ;; 02:5ebd $cd $1c $25
    call call_00_244a                                  ;; 02:5ec0 $cd $4a $24
    call call_00_2766                                  ;; 02:5ec3 $cd $66 $27
    ld   A, $00                                        ;; 02:5ec6 $3e $00
    jp   NC, call_02_72ac                              ;; 02:5ec8 $d2 $ac $72
    ret                                                ;; 02:5ecb $c9
    db   $0e, $14, $cd, $c8, $28, $cd, $10, $24        ;; 02:5ecc ????????
    db   $cd, $4a, $25, $c3, $17, $26, $c9, $c9        ;; 02:5ed4 ????????
    db   $c9, $cd, $22, $27, $28, $0f, $cd, $68        ;; 02:5edc ????????
    db   $2a, $cd, $76, $29, $21, $12, $da, $be        ;; 02:5ee4 ????????
    db   $3e, $01, $ca, $ac, $72, $0e, $08, $cd        ;; 02:5eec ????????
    db   $88, $25, $c3, $1c, $25, $0e, $20, $cd        ;; 02:5ef4 ????????
    db   $88, $25, $c3, $1c, $25, $cd, $f5, $29        ;; 02:5efc ????????
    db   $0e, $f0, $c4, $0d, $29, $cd, $22, $27        ;; 02:5f04 ????????
    db   $28, $14, $cd, $68, $2a, $cd, $76, $29        ;; 02:5f0c ????????
    db   $21, $12, $da, $be, $28, $08, $fa, $11        ;; 02:5f14 ????????
    db   $da, $fe, $40, $dc, $10, $24, $0e, $06        ;; 02:5f1c ????????
    db   $cd, $c8, $28, $cd, $1c, $25, $0e, $27        ;; 02:5f24 ????????
    db   $cd, $10, $2b, $c0, $cd, $22, $29, $3e        ;; 02:5f2c ????????
    db   $01, $ca, $ac, $72, $c9, $cd, $f5, $29        ;; 02:5f34 ????????
    db   $0e, $06, $c4, $92, $37, $c9, $cd, $f5        ;; 02:5f3c ????????
    db   $29, $0e, $30, $c4, $dc, $28, $cd, $4a        ;; 02:5f44 ????????
    db   $24, $c3, $66, $27, $cd, $f5, $29, $28        ;; 02:5f4c ????????
    db   $0a, $0e, $f0, $cd, $0d, $29, $0e, $0a        ;; 02:5f54 ????????
    db   $cd, $c8, $28, $cd, $4a, $25, $cd, $22        ;; 02:5f5c ????????
    db   $29, $ca, $80, $2b, $c9, $af, $ea, $d3        ;; 02:5f64 ????????
    db   $dc, $ea, $d4, $dc, $cd, $9b, $5f, $3e        ;; 02:5f6c ????????
    db   $01, $c3, $ac, $72, $cd, $f5, $29, $0e        ;; 02:5f74 ????????
    db   $41, $c4, $0d, $29, $cd, $22, $29, $3e        ;; 02:5f7c ????????
    db   $02, $ca, $ac, $72, $7e, $e6, $0f, $0e        ;; 02:5f84 ????????
    db   $1b, $ca, $92, $37, $c9, $cd, $f5, $29        ;; 02:5f8c ????????
    db   $c8, $21, $d3, $dc, $34, $cb, $9e, $21        ;; 02:5f94 ????????
    db   $d3, $dc, $6e, $26, $00, $11, $bf, $5f        ;; 02:5f9c ????????
    db   $19, $6e, $26, $00, $29, $29, $11, $c7        ;; 02:5fa4 ????????
    db   $5f, $19, $16, $d8, $fa, $00, $da, $f6        ;; 02:5fac ????????
    db   $0e, $5f, $06, $04, $2a, $12, $1c, $05        ;; 02:5fb4 ????????
    db   $20, $fa, $c9, $04, $0e, $1d, $23, $34        ;; 02:5fbc ????????
    db   $2a, $19, $0a, $27, $00, $13, $00, $33        ;; 02:5fc4 ????????
    db   $00, $13, $00, $3f, $00, $13, $00, $4c        ;; 02:5fcc ????????
    db   $00, $13, $00, $58, $00, $13, $00, $64        ;; 02:5fd4 ????????
    db   $00, $13, $00, $71, $00, $13, $00, $7d        ;; 02:5fdc ????????
    db   $00, $13, $00, $25, $00, $19, $00, $31        ;; 02:5fe4 ????????
    db   $00, $19, $00, $3e, $00, $19, $00, $4c        ;; 02:5fec ????????
    db   $00, $19, $00, $58, $00, $19, $00, $65        ;; 02:5ff4 ????????
    db   $00, $19, $00, $72, $00, $19, $00, $7f        ;; 02:5ffc ????????
    db   $00, $19, $00, $23, $00, $20, $00, $30        ;; 02:6004 ????????
    db   $00, $20, $00, $3e, $00, $20, $00, $4c        ;; 02:600c ????????
    db   $00, $20, $00, $58, $00, $20, $00, $66        ;; 02:6014 ????????
    db   $00, $20, $00, $73, $00, $20, $00, $81        ;; 02:601c ????????
    db   $00, $20, $00, $20, $00, $28, $00, $2f        ;; 02:6024 ????????
    db   $00, $28, $00, $3d, $00, $28, $00, $4b        ;; 02:602c ????????
    db   $00, $28, $00, $59, $00, $28, $00, $67        ;; 02:6034 ????????
    db   $00, $28, $00, $75, $00, $28, $00, $83        ;; 02:603c ????????
    db   $00, $28, $00, $1d, $00, $33, $00, $2c        ;; 02:6044 ????????
    db   $00, $33, $00, $3b, $00, $33, $00, $4b        ;; 02:604c ????????
    db   $00, $33, $00, $59, $00, $33, $00, $69        ;; 02:6054 ????????
    db   $00, $33, $00, $78, $00, $33, $00, $87        ;; 02:605c ????????
    db   $00, $33, $00, $19, $00, $3f, $00, $29        ;; 02:6064 ????????
    db   $00, $3f, $00, $3a, $00, $3f, $00, $4a        ;; 02:606c ????????
    db   $00, $3f, $00, $5a, $00, $3f, $00, $6a        ;; 02:6074 ????????
    db   $00, $3f, $00, $7a, $00, $3f, $00, $8a        ;; 02:607c ????????
    db   $00, $3f, $00, $15, $00, $4d, $00, $27        ;; 02:6084 ????????
    db   $00, $4d, $00, $38, $00, $4d, $00, $4a        ;; 02:608c ????????
    db   $00, $4d, $00, $5a, $00, $4d, $00, $6c        ;; 02:6094 ????????
    db   $00, $4d, $00, $7d, $00, $4d, $00, $8e        ;; 02:609c ????????
    db   $00, $4d, $00, $10, $00, $5d, $00, $23        ;; 02:60a4 ????????
    db   $00, $5d, $00, $36, $00, $5d, $00, $48        ;; 02:60ac ????????
    db   $00, $5d, $00, $5b, $00, $5d, $00, $6e        ;; 02:60b4 ????????
    db   $00, $5d, $00, $80, $00, $5d, $00, $93        ;; 02:60bc ????????
    db   $00, $5d, $00, $cd, $f5, $29, $28, $26        ;; 02:60c4 ????????
    db   $fa, $d3, $dc, $87, $87, $4f, $21, $d4        ;; 02:60cc ????????
    db   $dc, $7e, $34, $e6, $03, $b1, $6f, $26        ;; 02:60d4 ????????
    db   $00, $29, $11, $ff, $60, $19, $4e, $e5        ;; 02:60dc ????????
    db   $cd, $c8, $28, $e1, $23, $4e, $cd, $dc        ;; 02:60e4 ????????
    db   $28, $0e, $5a, $cd, $0d, $29, $cd, $c0        ;; 02:60ec ????????
    db   $24, $cd, $ee, $24, $cd, $22, $29, $ca        ;; 02:60f4 ????????
    db   $7a, $2b, $c9, $e0, $20, $00, $20, $20        ;; 02:60fc ????????
    db   $20, $00, $20, $e0, $00, $e0, $20, $00        ;; 02:6104 ????????
    db   $20, $20, $20, $00, $20, $e0, $20, $e0        ;; 02:610c ????????
    db   $00, $e0, $e0, $e0, $e0, $20, $e0, $20        ;; 02:6114 ????????
    db   $20, $e0, $20, $e0, $00, $e0, $e0, $00        ;; 02:611c ????????
    db   $e0, $20, $e0, $00, $e0, $20, $e0, $20        ;; 02:6124 ????????
    db   $00, $20, $20, $20, $e0, $20, $00, $20        ;; 02:612c ????????
    db   $20, $00, $20, $e0, $20, $00, $20, $20        ;; 02:6134 ????????
    db   $20, $20, $00, $0e, $04, $cd, $c8, $28        ;; 02:613c ????????
    db   $cd, $1c, $25, $3e, $01, $c2, $ac, $72        ;; 02:6144 ????????
    db   $c9, $cd, $f5, $29, $0e, $38, $c4, $dc        ;; 02:614c ????????
    db   $28, $cd, $4a, $24, $cd, $d2, $28, $cb        ;; 02:6154 ????????
    db   $7f, $3e, $02, $c2, $ac, $72, $c9, $cd        ;; 02:615c ????????
    db   $4a, $24, $cd, $66, $27, $3e, $03, $d2        ;; 02:6164 ????????
    db   $ac, $72, $c9, $cd, $f5, $29, $28, $2d        ;; 02:616c ????????
    db   $3e, $19, $cd, $f5, $0f, $0e, $10, $cd        ;; 02:6174 ????????
    db   $dc, $28, $26, $d8, $fa, $00, $da, $f6        ;; 02:617c ????????
    db   $0e, $6f, $2a, $d6, $b0, $5f, $7e, $de        ;; 02:6184 ????????
    db   $01, $57, $7b, $c6, $0c, $5f, $7a, $ce        ;; 02:618c ????????
    db   $00, $20, $0a, $7b, $fe, $18, $30, $05        ;; 02:6194 ????????
    db   $3e, $01, $ea, $dc, $dc, $cd, $4a, $24        ;; 02:619c ????????
    db   $cd, $66, $27, $d8, $3e, $19, $cd, $f5        ;; 02:61a4 ????????
    db   $0f, $3e, $04, $c3, $ac, $72, $cd, $4a        ;; 02:61ac ????????
    db   $24, $c3, $66, $27, $21, $be, $61, $c3        ;; 02:61b4 ????????
    db   $20, $2c, $00, $00, $ff, $7f, $b5, $56        ;; 02:61bc ????????
    db   $ad, $35, $0e, $04, $cd, $c8, $28, $cd        ;; 02:61c4 ????????
    db   $1c, $25, $cd, $68, $2a, $cd, $76, $29        ;; 02:61cc ????????
    db   $21, $12, $da, $be, $c0, $fa, $11, $da        ;; 02:61d4 ????????
    db   $fe, $30, $d0, $0e, $20, $cd, $c8, $28        ;; 02:61dc ????????
    db   $0e, $30, $cd, $dc, $28, $3e, $01, $c3        ;; 02:61e4 ????????
    db   $ac, $72, $cd, $1c, $25, $cd, $75, $24        ;; 02:61ec ????????
    db   $0e, $00, $30, $13, $cd, $d2, $28, $cb        ;; 02:61f4 ????????
    db   $7f, $20, $07, $0e, $02, $fe, $08, $38        ;; 02:61fc ????????
    db   $06, $c9, $fe, $f8, $d0, $0e, $03, $cd        ;; 02:6204 ????????
    db   $62, $29, $79, $be, $c2, $ac, $72, $c9        ;; 02:620c ????????
    db   $cd, $f5, $29, $28, $20, $cd, $26, $28        ;; 02:6214 ????????
    db   $cd, $e4, $27, $0e, $40, $cd, $80, $29        ;; 02:621c ????????
    db   $0e, $00, $cd, $c8, $28, $0e, $00, $cd        ;; 02:6224 ????????
    db   $58, $29, $01, $28, $00, $cd, $0d, $25        ;; 02:622c ????????
    db   $0e, $28, $cd, $0d, $29, $fa, $71, $dc        ;; 02:6234 ????????
    db   $e6, $03, $c0, $01, $ff, $ff, $cd, $0d        ;; 02:623c ????????
    db   $25, $cd, $22, $29, $3e, $01, $ca, $ac        ;; 02:6244 ????????
    db   $72, $c9, $fa, $71, $dc, $e6, $01, $0e        ;; 02:624c ????????
    db   $00, $ca, $c8, $28, $0e, $01, $cd, $c8        ;; 02:6254 ????????
    db   $28, $01, $01, $00, $cd, $df, $24, $cd        ;; 02:625c ????????
    db   $c9, $26, $26, $d8, $fa, $00, $da, $f6        ;; 02:6264 ????????
    db   $0e, $6f, $2a, $56, $5f, $21, $14, $da        ;; 02:626c ????????
    db   $7b, $96, $23, $7a, $9e, $38, $0a, $21        ;; 02:6274 ????????
    db   $16, $da, $7b, $96, $23, $7a, $9e, $38        ;; 02:627c ????????
    db   $05, $3e, $00, $c3, $ac, $72, $cd, $17        ;; 02:6284 ????????
    db   $26, $3e, $02, $d2, $ac, $72, $c9, $cd        ;; 02:628c ????????
    db   $f5, $29, $28, $0f, $0e, $00, $cd, $c8        ;; 02:6294 ????????
    db   $28, $0e, $00, $cd, $58, $29, $0e, $28        ;; 02:629c ????????
    db   $cd, $0d, $29, $fa, $71, $dc, $e6, $03        ;; 02:62a4 ????????
    db   $c0, $01, $01, $00, $cd, $0d, $25, $cd        ;; 02:62ac ????????
    db   $22, $29, $3e, $00, $ca, $ac, $72, $c9        ;; 02:62b4 ????????
    db   $cd, $f5, $29, $28, $0f, $0e, $08, $cd        ;; 02:62bc ????????
    db   $44, $29, $cd, $3a, $29, $fe, $31, $0e        ;; 02:62c4 ????????
    db   $20, $cc, $58, $29, $cd, $5d, $2a, $c8        ;; 02:62cc ????????
    db   $cd, $68, $2a, $cd, $76, $29, $21, $12        ;; 02:62d4 ????????
    db   $da, $be, $c0, $cd, $3a, $29, $0e, $32        ;; 02:62dc ????????
    db   $fe, $30, $28, $02, $0e, $33, $cd, $10        ;; 02:62e4 ????????
    db   $2b, $c0, $fa, $11, $da, $fe, $40, $3e        ;; 02:62ec ????????
    db   $01, $da, $ac, $72, $c9, $cd, $5d, $2a        ;; 02:62f4 ????????
    db   $c8, $0e, $10, $cd, $44, $29, $cd, $3a        ;; 02:62fc ????????
    db   $29, $0e, $0e, $fe, $30, $28, $02, $0e        ;; 02:6304 ????????
    db   $0f, $cd, $92, $37, $3e, $02, $c3, $ac        ;; 02:630c ????????
    db   $72, $0e, $08, $c3, $44, $29, $cd, $f5        ;; 02:6314 ????????
    db   $29, $28, $0a, $0e, $20, $cd, $c8, $28        ;; 02:631c ????????
    db   $0e, $40, $cd, $0d, $29, $cd, $c0, $24        ;; 02:6324 ????????
    db   $cd, $22, $29, $ca, $7a, $2b, $c9, $cd        ;; 02:632c ????????
    db   $f5, $29, $28, $0a, $0e, $e0, $cd, $c8        ;; 02:6334 ????????
    db   $28, $0e, $40, $cd, $0d, $29, $cd, $c0        ;; 02:633c ????????
    db   $24, $cd, $22, $29, $ca, $7a, $2b, $c9        ;; 02:6344 ????????
    db   $cd, $3a, $29, $fe, $36, $0e, $20, $cc        ;; 02:634c ????????
    db   $58, $29, $cd, $26, $28, $cd, $e4, $27        ;; 02:6354 ????????
    db   $3e, $01, $c3, $ac, $72, $11, $67, $63        ;; 02:635c ????????
    db   $c3, $98, $2a, $c0, $01, $20, $70, $00        ;; 02:6364 ????????
    db   $10, $36, $20, $20, $02, $c0, $01, $20        ;; 02:636c ????????
    db   $70, $00, $10, $36, $e0, $20, $02, $90        ;; 02:6374 ????????
    db   $01, $10, $68, $01, $10, $56, $20, $10        ;; 02:637c ????????
    db   $02, $90, $01, $10, $68, $01, $10, $56        ;; 02:6384 ????????
    db   $e0, $10, $02, $70, $02, $10, $60, $01        ;; 02:638c ????????
    db   $20, $22, $e4, $20, $02, $cd, $c0, $24        ;; 02:6394 ????????
    db   $cd, $ee, $24, $cd, $22, $29, $3e, $00        ;; 02:639c ????????
    db   $ca, $ac, $72, $c9, $cd, $f5, $29, $28        ;; 02:63a4 ????????
    db   $04, $af, $ea, $dc, $dc, $21, $dc, $dc        ;; 02:63ac ????????
    db   $cb, $46, $c8, $36, $00, $cd, $62, $29        ;; 02:63b4 ????????
    db   $3c, $c3, $ac, $72, $3e, $1a, $cd, $f5        ;; 02:63bc ????????
    db   $0f, $ea, $d6, $da, $3e, $03, $21, $f8        ;; 02:63c4 ????????
    db   $57, $cd, $dd, $0e, $c3, $7a, $2b, $cd        ;; 02:63cc ????????
    db   $ef, $22, $0e, $02, $c3, $99, $22, $0e        ;; 02:63d4 ????????
    db   $28, $cd, $c8, $28, $cd, $68, $2a, $fa        ;; 02:63dc ????????
    db   $12, $da, $21, $0d, $d8, $be, $3e, $01        ;; 02:63e4 ????????
    db   $ca, $ac, $72, $c9, $cd, $f5, $29, $28        ;; 02:63ec ????????
    db   $08, $0e, $3c, $cd, $0d, $29, $cd, $10        ;; 02:63f4 ????????
    db   $24, $cd, $22, $29, $3e, $02, $ca, $ac        ;; 02:63fc ????????
    db   $72, $cd, $68, $2a, $fa, $12, $da, $21        ;; 02:6404 ????????
    db   $0d, $d8, $be, $3e, $00, $c2, $ac, $72        ;; 02:640c ????????
    db   $c9, $cd, $f5, $29, $0e, $20, $c4, $dc        ;; 02:6414 ????????
    db   $28, $cd, $1c, $25, $cd, $4a, $24, $cd        ;; 02:641c ????????
    db   $66, $27, $d8, $3e, $03, $cd, $ac, $72        ;; 02:6424 ????????
    db   $18, $d7, $cd, $f5, $29, $28, $0a, $0e        ;; 02:642c ????????
    db   $00, $cd, $0d, $29, $0e, $10, $cd, $4e        ;; 02:6434 ????????
    db   $29, $cd, $17, $29, $20, $0e, $fa, $7b        ;; 02:643c ????????
    db   $dc, $21, $00, $da, $be, $c0, $cd, $0f        ;; 02:6444 ????????
    db   $23, $c3, $0d, $29, $cd, $22, $29, $3e        ;; 02:644c ????????
    db   $01, $ca, $ac, $72, $c9, $cd, $6c, $29        ;; 02:6454 ????????
    db   $6f, $26, $00, $11, $67, $64, $19, $4e        ;; 02:645c ????????
    db   $c3, $4e, $29, $10, $0e, $0c, $0a, $08        ;; 02:6464 ????????
    db   $06, $04, $02, $ea, $d6, $da, $3e, $03        ;; 02:646c ????????
    db   $21, $f8, $57, $cd, $dd, $0e, $c9, $cd        ;; 02:6474 ????????
    db   $6c, $29, $6f, $26, $00, $11, $89, $64        ;; 02:647c ????????
    db   $19, $4e, $c3, $4e, $29, $02, $04, $06        ;; 02:6484 ????????
    db   $08, $0a, $0c, $0e, $10, $cd, $22, $27        ;; 02:648c ????????
    db   $28, $0a, $cd, $68, $2a, $fa, $11, $da        ;; 02:6494 ????????
    db   $fe, $30, $38, $08, $0e, $04, $cd, $88        ;; 02:649c ????????
    db   $25, $c3, $1c, $25, $fa, $12, $da, $ee        ;; 02:64a4 ????????
    db   $20, $4f, $cd, $58, $29, $0e, $1e, $cd        ;; 02:64ac ????????
    db   $88, $25, $cd, $1c, $25, $20, $0d, $fa        ;; 02:64b4 ????????
    db   $11, $da, $fe, $20, $d0, $21, $12, $da        ;; 02:64bc ????????
    db   $4e, $cd, $58, $29, $3e, $01, $c3, $ac        ;; 02:64c4 ????????
    db   $72, $cd, $f5, $29, $0e, $20, $c4, $dc        ;; 02:64cc ????????
    db   $28, $0e, $10, $cd, $88, $25, $cd, $1c        ;; 02:64d4 ????????
    db   $25, $cd, $4a, $24, $cd, $66, $27, $3e        ;; 02:64dc ????????
    db   $00, $d2, $ac, $72, $c9, $cd, $f5, $29        ;; 02:64e4 ????????
    db   $28, $06, $cd, $26, $28, $cd, $e4, $27        ;; 02:64ec ????????
    db   $cd, $68, $2a, $fa, $11, $da, $fe, $10        ;; 02:64f4 ????????
    db   $3e, $01, $da, $ac, $72, $c9, $cd, $f5        ;; 02:64fc ????????
    db   $29, $28, $16, $cd, $10, $24, $cd, $76        ;; 02:6504 ????????
    db   $29, $0e, $10, $fe, $00, $28, $02, $0e        ;; 02:650c ????????
    db   $f0, $cd, $c8, $28, $0e, $20, $cd, $dc        ;; 02:6514 ????????
    db   $28, $cd, $c0, $24, $cd, $4a, $24, $cd        ;; 02:651c ????????
    db   $f1, $28, $cb, $7f, $3e, $03, $c2, $ac        ;; 02:6524 ????????
    db   $72, $c9, $cd, $c0, $24, $cd, $4a, $24        ;; 02:652c ????????
    db   $cd, $80, $27, $3e, $00, $d2, $ac, $72        ;; 02:6534 ????????
    db   $c9, $cd, $5d, $2a, $c8, $cd, $ce, $1b        ;; 02:653c ????????
    db   $0e, $02, $c3, $99, $22, $0e, $00, $cd        ;; 02:6544 ????????
    db   $99, $22, $3e, $03, $c3, $ac, $72, $0e        ;; 02:654c ????????
    db   $02, $cd, $99, $22, $3e, $01, $c3, $ac        ;; 02:6554 ????????
    db   $72, $cd, $5d, $2a, $c8, $cd, $ce, $1b        ;; 02:655c ????????
    db   $0e, $00, $c3                                 ;; 02:6564 ???
    db   $99, $22, $cd, $d4, $22, $c8, $0e, $02        ;; 02:6567 ????????
    db   $cd, $99, $22, $3e, $01, $c3, $ac, $72        ;; 02:656f ????????
    db   $cd, $17, $29, $34, $21, $71, $dc, $a6        ;; 02:6577 ????????
    db   $e6, $1f, $28, $06, $cd, $76, $29, $ee        ;; 02:657f ????????
    db   $20, $77, $cd, $d4, $22, $c0, $0e, $00        ;; 02:6587 ????????
    db   $cd, $99, $22, $3e, $03, $c3, $ac, $72        ;; 02:658f ????????
    db   $0e, $20, $cd, $58, $29, $c9, $cd, $d4        ;; 02:6597 ????????
    db   $22, $fe, $02, $d8, $ea, $d6, $da, $3e        ;; 02:659f ????????
    db   $03, $21, $f8, $57, $cd, $dd, $0e, $3e        ;; 02:65a7 ????????
    db   $01, $c3, $ac, $72, $fa, $6c, $db, $fe        ;; 02:65af ????????
    db   $2b, $c0, $cd, $d4, $22, $fe, $01, $c0        ;; 02:65b7 ????????
    db   $0e, $00, $cd, $99, $22, $3e, $00, $c3        ;; 02:65bf ????????
    db   $ac, $72, $cd, $d4, $22, $c8, $0e, $01        ;; 02:65c7 ????????
    db   $cd, $99, $22, $3e, $01, $c3, $ac, $72        ;; 02:65cf ????????
    db   $cd, $f5, $29, $0e, $00, $c4, $0d, $29        ;; 02:65d7 ????????
    db   $fa, $7b, $dc, $a7, $28, $13, $21, $00        ;; 02:65df ????????
    db   $da, $be, $28, $0d, $cd, $17, $29, $fe        ;; 02:65e7 ????????
    db   $a8, $d0, $34, $01, $ff, $ff, $c3, $0d        ;; 02:65ef ????????
    db   $25, $fa, $71, $dc, $e6, $03, $c0, $cd        ;; 02:65f7 ????????
    db   $17, $29, $c8, $35, $01, $01, $00, $c3        ;; 02:65ff ????????
    db   $0d, $25, $cd, $d4, $22, $c8, $0e, $01        ;; 02:6607 ????????
    db   $cd, $99, $22, $3e, $01, $c3, $ac, $72        ;; 02:660f ????????
    db   $cd, $d4, $22, $c0, $0e, $00, $cd, $99        ;; 02:6617 ????????
    db   $22, $3e, $00, $c3, $ac, $72, $cd, $d4        ;; 02:661f ????????
    db   $22, $c8, $0e, $01, $cd, $99, $22, $3e        ;; 02:6627 ????????
    db   $01, $c3, $ac, $72, $cd, $d4, $22, $c0        ;; 02:662f ????????
    db   $0e, $00, $cd, $99, $22, $3e, $00, $c3        ;; 02:6637 ????????
    db   $ac, $72, $0e, $10, $cd, $c8, $28, $cd        ;; 02:663f ????????
    db   $1c, $25, $cd, $22, $27, $c8, $cd, $10        ;; 02:6647 ????????
    db   $24, $cd, $68, $2a, $fa, $11, $da, $fe        ;; 02:664f ????????
    db   $18, $38, $08, $fe, $40, $3e, $04, $d2        ;; 02:6657 ????????
    db   $ac, $72, $c9, $cd, $17, $29, $3c, $fe        ;; 02:665f ????????
    db   $09, $38, $01, $af, $77, $6f, $26, $00        ;; 02:6667 ????????
    db   $11, $7e, $66, $19, $7e, $f5, $fe, $04        ;; 02:666f ????????
    db   $cc, $2d, $24, $f1, $c3, $ac, $72, $01        ;; 02:6677 ????????
    db   $06, $06, $01, $04, $01, $04, $06, $04        ;; 02:667f ????????
    db   $cd, $4a, $24, $c3, $66, $27, $cd, $4a        ;; 02:6687 ????????
    db   $24, $cd, $66, $27, $d8, $cd, $5d, $2a        ;; 02:668f ????????
    db   $3e, $04, $c2, $ac, $72, $c9, $cd, $f5        ;; 02:6697 ????????
    db   $29, $28, $0a, $0e, $18, $cd, $c8, $28        ;; 02:669f ????????
    db   $0e, $28, $cd, $dc, $28, $cd, $1c, $25        ;; 02:66a7 ????????
    db   $cd, $4a, $24, $cd, $66, $27, $3e, $00        ;; 02:66af ????????
    db   $d2, $ac, $72, $c9, $cd, $10, $24, $cd        ;; 02:66b7 ????????
    db   $68, $2a, $fa, $11, $da, $fe, $38, $3e        ;; 02:66bf ????????
    db   $01, $da, $ac, $72, $c9, $0e, $10, $cd        ;; 02:66c7 ????????
    db   $c8, $28, $cd, $1c, $25, $c8, $cd, $76        ;; 02:66cf ????????
    db   $29, $ee, $20, $77, $3e, $02, $c3, $ac        ;; 02:66d7 ????????
    db   $72, $cd, $5d, $2a, $c8, $cd, $76, $29        ;; 02:66df ????????
    db   $ee, $20, $77, $3e, $01, $c3, $ac, $72        ;; 02:66e7 ????????
    db   $cd, $5d, $2a, $c2, $7a, $2b, $c9, $cd        ;; 02:66ef ????????
    db   $68, $2a, $fa, $11, $da, $fe, $38, $38        ;; 02:66f7 ????????
    db   $08, $0e, $06, $cd, $88, $25, $c3, $1c        ;; 02:66ff ????????
    db   $25, $fa, $12, $da, $ee, $20, $4f, $cd        ;; 02:6707 ????????
    db   $58, $29, $0e, $10, $cd, $88, $25, $cd        ;; 02:670f ????????
    db   $1c, $25, $20, $0d, $fa, $11, $da, $fe        ;; 02:6717 ????????
    db   $28, $d0, $21, $12, $da, $4e, $cd, $58        ;; 02:671f ????????
    db   $29, $0e, $30, $cd, $dc, $28, $3e, $01        ;; 02:6727 ????????
    db   $c3, $ac, $72, $0e, $02, $cd, $88, $25        ;; 02:672f ????????
    db   $cd, $1c, $25, $cd, $4a, $24, $cd, $66        ;; 02:6737 ????????
    db   $27, $3e, $00, $d2, $ac, $72, $c9, $cd        ;; 02:673f ????????
    db   $f5, $29, $0e, $00, $c4, $0d, $29, $0e        ;; 02:6747 ????????
    db   $04, $cd, $c8, $28, $cd, $1c, $25, $0e        ;; 02:674f ????????
    db   $02, $c4, $0d, $29, $cd, $ac, $29, $c0        ;; 02:6757 ????????
    db   $cd, $22, $29, $0e, $10, $c2, $92, $37        ;; 02:675f ????????
    db   $c9, $cd, $8a, $29, $fe, $50, $28, $07        ;; 02:6767 ????????
    db   $34, $01, $ff, $ff, $cd, $0d, $25, $cd        ;; 02:676f ????????
    db   $f5, $29, $0e, $00, $c4, $0d, $29, $0e        ;; 02:6777 ????????
    db   $10, $cd, $c8, $28, $cd, $1c, $25, $0e        ;; 02:677f ????????
    db   $c1, $c4, $0d, $29, $cd, $ac, $29, $c0        ;; 02:6787 ????????
    db   $cd, $22, $29, $c8, $e6, $3f, $0e, $10        ;; 02:678f ????????
    db   $ca, $92, $37, $c9, $cd, $f5, $29, $28        ;; 02:6797 ????????
    db   $13, $cd, $76, $29, $0e, $18, $fe, $00        ;; 02:679f ????????
    db   $28, $02, $0e, $e8, $cd, $c8, $28, $0e        ;; 02:67a7 ????????
    db   $b4, $cd, $0d, $29, $cd, $22, $29, $ca        ;; 02:67af ????????
    db   $7a, $2b, $cd, $c0, $24, $cd, $4a, $24        ;; 02:67b7 ????????
    db   $c3, $66, $27, $cd, $f5, $29, $28, $18        ;; 02:67bf ????????
    db   $cd, $8e, $68, $69, $26, $00, $29, $11        ;; 02:67c7 ????????
    db   $e2, $dc, $19, $16, $d8, $fa, $00, $da        ;; 02:67cf ????????
    db   $f6, $10, $5f, $2a, $12, $1c, $7e, $12        ;; 02:67d7 ????????
    db   $fa, $7b, $dc, $21, $00, $da, $be, $c0        ;; 02:67df ????????
    db   $cd, $d4, $22, $4f, $21, $6a, $68, $e5        ;; 02:67e7 ????????
    db   $2a, $b9, $20, $12, $16, $d8, $fa, $00        ;; 02:67ef ????????
    db   $da, $f6, $0e, $5f, $1a, $96, $47, $13        ;; 02:67f7 ????????
    db   $23, $1a, $9e, $b0, $28, $0b, $e1, $11        ;; 02:67ff ????????
    db   $05, $00, $19, $7e, $fe, $ff, $20, $df        ;; 02:6807 ????????
    db   $c9, $13, $23, $1a, $96, $4f, $13, $23        ;; 02:680f ????????
    db   $1a, $9e, $e1, $38, $2b, $b1, $20, $23        ;; 02:6817 ????????
    db   $cd, $8e, $68, $69, $26, $00, $29, $11        ;; 02:681f ????????
    db   $e2, $dc, $19, $16, $d8, $fa, $00, $da        ;; 02:6827 ????????
    db   $f6, $10, $5f, $1a, $22, $1c, $1a, $77        ;; 02:682f ????????
    db   $fa, $01, $d8, $fe, $1e, $3e, $01, $ca        ;; 02:6837 ????????
    db   $f9, $54, $c9, $01, $ff, $ff, $18, $03        ;; 02:683f ????????
    db   $01, $01, $00, $3e, $1e, $21, $01, $d8        ;; 02:6847 ????????
    db   $be, $c2, $f9, $54, $26, $d8, $fa, $00        ;; 02:684f ????????
    db   $da, $f6, $0e, $6f, $fa, $0e, $d8, $96        ;; 02:6857 ????????
    db   $5f, $23, $fa, $0f, $d8, $9e, $b3, $ca        ;; 02:685f ????????
    db   $0d, $25, $c9, $00, $a0, $01, $98, $02        ;; 02:6867 ????????
    db   $01, $a0, $01, $58, $01, $01, $40, $03        ;; 02:686f ????????
    db   $d8, $01, $01, $c0, $05, $58, $02, $02        ;; 02:6877 ????????
    db   $a0, $01, $08, $01, $02, $40, $03, $58        ;; 02:687f ????????
    db   $01, $02, $c0, $05, $d8, $01, $ff, $21        ;; 02:6887 ????????
    db   $a9, $68, $16, $d8, $fa, $00, $da, $f6        ;; 02:688f ????????
    db   $0e, $5f, $0e, $ff, $0c, $1a, $96, $47        ;; 02:6897 ????????
    db   $13, $23, $1a, $9e, $1b, $23, $b0, $20        ;; 02:689f ????????
    db   $f3, $c9, $a0, $01, $40, $03, $c0, $05        ;; 02:68a7 ????????
    db   $c3, $3e, $23, $cd, $f5, $29, $c8, $21        ;; 02:68af ????????
    db   $e5, $68, $cd, $20, $2c, $cd, $26, $28        ;; 02:68b7 ????????
    db   $fa, $71, $dc, $e6, $0f, $4f, $06, $00        ;; 02:68bf ????????
    db   $cd, $df, $24, $cd, $e4, $27, $cd, $0f        ;; 02:68c7 ????????
    db   $23, $06, $ff, $cd, $0d, $25, $0e, $04        ;; 02:68cf ????????
    db   $cd, $0d, $29, $0e, $00, $cd, $c8, $28        ;; 02:68d7 ????????
    db   $0e, $00, $cd, $dc, $28, $c9, $00, $00        ;; 02:68df ????????
    db   $00, $00, $ff, $03, $ff, $7f, $cd, $c0        ;; 02:68e7 ????????
    db   $24, $cd, $4a, $24, $cd, $66, $27, $d8        ;; 02:68ef ????????
    db   $cd, $22, $29, $3e, $02, $ca, $ac, $72        ;; 02:68f7 ????????
    db   $6e, $26, $00, $11, $24, $69, $19, $4e        ;; 02:68ff ????????
    db   $cd, $dc, $28, $cd, $e6, $28, $c0, $fa        ;; 02:6907 ????????
    db   $71, $dc, $cb, $37, $e6, $03, $6f, $26        ;; 02:690f ????????
    db   $00, $11, $20, $69, $19, $4e, $c3, $c8        ;; 02:6917 ????????
    db   $28, $08, $f8, $04, $fc, $00, $20, $28        ;; 02:691f ????????
    db   $30, $cd, $f5, $29, $01, $08, $00, $c4        ;; 02:6927 ????????
    db   $0d, $25, $21, $37, $69, $c3, $20, $2c        ;; 02:692f ????????
    db   $00, $00, $1b, $00, $5f, $02, $1f, $1b        ;; 02:6937 ????????
    db   $cd, $f5, $29, $0e, $15, $c4, $92, $37        ;; 02:693f ????????
    db   $21, $d0, $dc, $7e, $a7, $c8, $36, $00        ;; 02:6947 ????????
    db   $cd, $a0, $28, $a7, $c0, $3e, $04, $cd        ;; 02:694f ????????
    db   $ac, $72, $ea, $d6, $da, $3e, $03, $21        ;; 02:6957 ????????
    db   $71, $56, $cd, $dd, $0e, $c9, $cd, $5d        ;; 02:695f ????????
    db   $2a, $c8, $0e, $01, $cd, $ef, $21, $c3        ;; 02:6967 ????????
    db   $7a, $2b, $0e, $55, $cd, $b7, $29, $79        ;; 02:696f ????????
    db   $fe, $02, $3e, $01, $c2, $ac, $72, $7d        ;; 02:6977 ????????
    db   $ee, $08, $6f, $6e, $26, $00, $29, $29        ;; 02:697f ????????
    db   $11, $9f, $69, $19, $16, $d8, $fa, $00        ;; 02:6987 ????????
    db   $da, $f6, $0e, $5f, $2a, $12, $1c, $2a        ;; 02:698f ????????
    db   $12, $1c, $2a, $12, $1c, $7e, $12, $c9        ;; 02:6997 ????????
    db   $50, $00, $1c, $00, $50, $00, $1c, $00        ;; 02:699f ????????
    db   $50, $00, $1c, $00, $50, $00, $19, $00        ;; 02:69a7 ????????
    db   $cd, $f5, $29, $28, $17, $21, $ce, $dc        ;; 02:69af ????????
    db   $7e, $34, $e6, $07, $6f, $26, $00, $11        ;; 02:69b7 ????????
    db   $fc, $69, $19, $4e, $cd, $c8, $28, $0e        ;; 02:69bf ????????
    db   $20, $cd, $dc, $28, $cd, $4a, $24, $11        ;; 02:69c7 ????????
    db   $68, $00, $26, $d8, $fa, $00, $da, $f6        ;; 02:69cf ????????
    db   $10, $6f, $2a, $93, $7e, $9a, $da, $c0        ;; 02:69d7 ????????
    db   $24, $72, $2d, $73, $0e, $00, $cd, $c8        ;; 02:69df ????????
    db   $28, $0e, $00, $cd, $dc, $28, $0e, $2d        ;; 02:69e7 ????????
    db   $cd, $0d, $29, $3e, $1c, $cd, $f5, $0f        ;; 02:69ef ????????
    db   $3e, $02, $c3, $ac, $72, $10, $f0, $08        ;; 02:69f7 ????????
    db   $f8, $10, $f0, $04, $fc, $fa, $71, $dc        ;; 02:69ff ????????
    db   $e6, $03, $c0, $cd, $22, $29, $3e, $04        ;; 02:6a07 ????????
    db   $ca, $ac, $72, $c9, $cd, $f5, $29, $28        ;; 02:6a0f ????????
    db   $20, $26, $d8, $fa, $00, $da, $f6, $0e        ;; 02:6a17 ????????
    db   $6f, $7e, $21, $40, $6a, $06, $05, $be        ;; 02:6a1f ????????
    db   $38, $05, $23, $23, $05, $20, $f8, $23        ;; 02:6a27 ????????
    db   $4e, $cd, $c8, $28, $0e, $d8, $cd, $dc        ;; 02:6a2f ????????
    db   $28, $cd, $c0, $24, $cd, $ee, $24, $18        ;; 02:6a37 ????????
    db   $c4, $17, $26, $35, $17, $44, $0f, $62        ;; 02:6a3f ????????
    db   $00, $71, $f9, $8f, $ea, $cd, $f5, $29        ;; 02:6a47 ????????
    db   $3e, $19, $c4, $f5, $0f, $21, $89, $6a        ;; 02:6a4f ????????
    db   $cd, $20, $2c, $cd, $5d, $2a, $c2, $7a        ;; 02:6a57 ????????
    db   $2b, $0e, $55, $cd, $b7, $29, $79, $fe        ;; 02:6a5f ????????
    db   $04, $d0, $26, $d8, $fa, $00, $da, $f6        ;; 02:6a67 ????????
    db   $0e, $6f, $7e, $d6, $60, $c6, $0a, $fe        ;; 02:6a6f ????????
    db   $14, $d0, $23, $23, $7e, $d6, $18, $c6        ;; 02:6a77 ????????
    db   $0a, $fe, $14, $d0, $3e, $01, $ea, $d0        ;; 02:6a7f ????????
    db   $dc, $c9, $00, $00, $1b, $00, $5f, $02        ;; 02:6a87 ????????
    db   $1f, $1b, $cd, $f5, $29, $28, $0b, $01        ;; 02:6a8f ????????
    db   $d0, $ff, $cd, $0d, $25, $0e, $28, $cd        ;; 02:6a97 ????????
    db   $4e, $29, $cd, $d4, $22, $c8, $3e, $1a        ;; 02:6a9f ????????
    db   $cd, $f5, $0f, $0e, $02, $cd, $99, $22        ;; 02:6aa7 ????????
    db   $3e, $01, $c3, $ac, $72, $cd, $f5, $29        ;; 02:6aaf ????????
    db   $0e, $10, $c4, $4e, $29, $cd, $4a, $24        ;; 02:6ab7 ????????
    db   $cd, $66, $27, $d8, $3e, $19, $cd, $f5        ;; 02:6abf ????????
    db   $0f, $3e, $02, $c3, $ac, $72, $cd, $f5        ;; 02:6ac7 ????????
    db   $29, $c2, $10, $24, $c9, $cd, $f5, $29        ;; 02:6acf ????????
    db   $0e, $14, $c2, $92, $37, $c9, $cd, $f5        ;; 02:6ad7 ????????
    db   $29, $28, $13, $cd, $76, $29, $0e, $20        ;; 02:6adf ????????
    db   $fe, $00, $28, $02, $0e, $e0, $cd, $c8        ;; 02:6ae7 ????????
    db   $28, $0e, $78, $cd, $0d, $29, $cd, $22        ;; 02:6aef ????????
    db   $29, $ca, $7a, $2b, $fe, $3c, $dc, $4a        ;; 02:6af7 ????????
    db   $24, $c3, $c0, $24, $cd, $f5, $29, $28        ;; 02:6aff ????????
    db   $06, $cd, $0f, $23, $cd, $0d, $29, $01        ;; 02:6b07 ????????
    db   $02, $00, $cd, $0d, $25, $cd, $17, $29        ;; 02:6b0f ????????
    db   $d6, $02, $77, $3e, $01, $ca, $ac, $72        ;; 02:6b17 ????????
    db   $c9, $01, $ff, $ff, $cd, $0d, $25, $cd        ;; 02:6b1f ????????
    db   $0f, $23, $cd, $17, $29, $3c, $77, $b9        ;; 02:6b27 ????????
    db   $3e, $02, $ca, $ac, $72, $c9, $cd, $f5        ;; 02:6b2f ????????
    db   $29, $28, $0d, $0e, $20, $cd, $c8, $28        ;; 02:6b37 ????????
    db   $0e, $08, $cd, $0d, $29, $cd, $10, $24        ;; 02:6b3f ????????
    db   $cd, $1c, $25, $cd, $22, $29, $3e, $00        ;; 02:6b47 ????????
    db   $ca, $ac, $72, $c9, $0e, $02, $cd, $c8        ;; 02:6b4f ????????
    db   $28, $cd, $1c, $25, $cd, $68, $2a, $fa        ;; 02:6b57 ????????
    db   $11, $da, $fe, $28, $3e, $01, $da, $ac        ;; 02:6b5f ????????
    db   $72, $c9, $cd, $22, $27, $28, $0a, $cd        ;; 02:6b67 ????????
    db   $68, $2a, $fa, $11, $da, $fe, $0e, $38        ;; 02:6b6f ????????
    db   $13, $0e, $08, $cd, $c8, $28, $cd, $1c        ;; 02:6b77 ????????
    db   $25, $c8, $cd, $22, $29, $28, $05, $3e        ;; 02:6b7f ????????
    db   $01, $c3, $ac, $72, $cd, $17, $29, $36        ;; 02:6b87 ????????
    db   $03, $cd, $22, $27, $c4, $10, $24, $3e        ;; 02:6b8f ????????
    db   $02, $c3, $ac, $72, $0e, $10, $cd, $c8        ;; 02:6b97 ????????
    db   $28, $c3, $1c, $25, $cd, $f5, $29, $28        ;; 02:6b9f ????????
    db   $0b, $0e, $04, $cd, $c8, $28, $cd, $0f        ;; 02:6ba7 ????????
    db   $23, $cd, $0d, $29, $cd, $1c, $25, $01        ;; 02:6baf ????????
    db   $02, $00, $cd, $0d, $25, $cd, $17, $29        ;; 02:6bb7 ????????
    db   $d6, $02, $77, $3e, $01, $ca, $ac, $72        ;; 02:6bbf ????????
    db   $c9, $cd, $17, $29, $fa, $71, $dc, $a6        ;; 02:6bc7 ????????
    db   $e6, $3f, $20, $09, $cd, $76, $29, $ee        ;; 02:6bcf ????????
    db   $20, $4f, $cd, $58, $29, $0e, $10, $cd        ;; 02:6bd7 ????????
    db   $c8, $28, $cd, $1c, $25, $cd, $0f, $23        ;; 02:6bdf ????????
    db   $cd, $17, $29, $b9, $3e, $00, $ca, $ac        ;; 02:6be7 ????????
    db   $72, $cd, $17, $29, $3c, $77, $01, $ff        ;; 02:6bef ????????
    db   $ff, $c3, $0d, $25, $fa, $7b, $dc, $21        ;; 02:6bf7 ????????
    db   $00, $da, $be, $3e, $01, $ca, $ac, $72        ;; 02:6bff ????????
    db   $c9, $ea, $d6, $da, $3e, $03, $21, $f8        ;; 02:6c07 ????????
    db   $57, $cd, $dd, $0e, $cd, $4a, $24, $cd        ;; 02:6c0f ????????
    db   $80, $27, $d2, $7a, $2b, $c9, $cd, $f5        ;; 02:6c17 ????????
    db   $29, $0e, $20, $c4, $c8, $28, $fa, $71        ;; 02:6c1f ????????
    db   $dc, $e6, $07, $0e, $10, $cc, $88, $25        ;; 02:6c27 ????????
    db   $cd, $1c, $25, $cd, $22, $27, $c8, $cd        ;; 02:6c2f ????????
    db   $68, $2a, $cd, $76, $29, $21, $12, $da        ;; 02:6c37 ????????
    db   $be, $c0, $fa, $11, $da, $fe, $40, $3e        ;; 02:6c3f ????????
    db   $02, $da, $ac, $72, $c9, $0e, $20, $cd        ;; 02:6c47 ????????
    db   $dc, $28, $0e, $28, $cd, $88, $25, $cd        ;; 02:6c4f ????????
    db   $1c, $25, $cd, $be, $28, $fe, $28, $3e        ;; 02:6c57 ????????
    db   $03, $ca, $ac, $72, $c9, $cd, $1c, $25        ;; 02:6c5f ????????
    db   $cd, $4a, $24, $cd, $66, $27, $3e, $00        ;; 02:6c67 ????????
    db   $d2, $ac, $72, $c9, $cd, $f5, $29, $28        ;; 02:6c6f ????????
    db   $0c, $cd, $66, $27, $0e, $00, $38, $02        ;; 02:6c77 ????????
    db   $0e, $01, $cd, $80, $29, $cd, $8a, $29        ;; 02:6c7f ????????
    db   $28, $23, $fa, $71, $dc, $e6, $07, $0e        ;; 02:6c87 ????????
    db   $10, $cc, $88, $25, $cd, $1c, $25, $c8        ;; 02:6c8f ????????
    db   $cd, $0f, $23, $06, $00, $21, $d5, $dc        ;; 02:6c97 ????????
    db   $09, $7e, $a7, $3e, $00, $c2, $ac, $72        ;; 02:6c9f ????????
    db   $3e, $05, $c3, $ac, $72, $cd, $1c, $25        ;; 02:6ca7 ????????
    db   $cd, $4a, $24, $cd, $66, $27, $0e, $01        ;; 02:6caf ????????
    db   $d4, $80, $29, $c9, $cd, $f5, $29, $28        ;; 02:6cb7 ????????
    db   $06, $cd, $0f, $23, $cd, $58, $29, $cd        ;; 02:6cbf ????????
    db   $f3, $27, $fa, $10, $d8, $93, $fa, $11        ;; 02:6cc7 ????????
    db   $d8, $9a, $d8, $0e, $65, $cd, $10, $2b        ;; 02:6ccf ????????
    db   $c0, $0e, $1c, $c3, $92, $37, $cd, $f5        ;; 02:6cd7 ????????
    db   $29, $28, $13, $cd, $76, $29, $0e, $14        ;; 02:6cdf ????????
    db   $fe, $00, $28, $02, $0e, $ec, $cd, $c8        ;; 02:6ce7 ????????
    db   $28, $0e, $03, $cd, $0d, $29, $cd, $c0        ;; 02:6cef ????????
    db   $24, $cd, $4a, $24, $cd, $f3, $27, $cd        ;; 02:6cf7 ????????
    db   $17, $29, $6e, $26, $00, $29, $01, $31        ;; 02:6cff ????????
    db   $6d, $09, $2a, $83, $5f, $7e, $8a, $57        ;; 02:6d07 ????????
    db   $26, $d8, $fa, $00, $da, $f6, $10, $6f        ;; 02:6d0f ????????
    db   $2a, $93, $7e, $9a, $d8, $72, $2d, $73        ;; 02:6d17 ????????
    db   $3e, $19, $cd, $f5, $0f, $cd, $22, $29        ;; 02:6d1f ????????
    db   $0e, $20, $c2, $dc, $28, $3e, $01, $c3        ;; 02:6d27 ????????
    db   $ac, $72, $00, $00, $56, $00, $46, $00        ;; 02:6d2f ????????
    db   $36, $00, $c9, $c9, $cd, $5d, $2a, $c8        ;; 02:6d37 ????????
    db   $3e, $1a, $cd, $f5, $0f, $3e, $03, $c3        ;; 02:6d3f ????????
    db   $ac, $72, $cd, $5d, $2a, $3e, $06, $c2        ;; 02:6d47 ????????
    db   $ac, $72, $c9, $cd, $f5, $29, $28, $05        ;; 02:6d4f ????????
    db   $0e, $78, $cd, $0d, $29, $cd, $22, $29        ;; 02:6d57 ????????
    db   $c0, $3e, $01, $ea, $65, $dc, $21, $6a        ;; 02:6d5f ????????
    db   $db, $cb, $e6, $c3, $7a, $2b, $cd, $f5        ;; 02:6d67 ????????
    db   $29, $28, $10, $cd, $17, $29, $34, $fe        ;; 02:6d6f ????????
    db   $0a, $3e, $02, $cc, $ac, $72, $3e, $02        ;; 02:6d77 ????????
    db   $ea, $da, $dc, $c3, $3e, $23, $cd, $3e        ;; 02:6d7f ????????
    db   $23, $0e, $69, $cd, $b7, $29, $79, $fe        ;; 02:6d87 ????????
    db   $00, $c0, $0e, $68, $cd, $b7, $29, $0c        ;; 02:6d8f ????????
    db   $c0, $fa, $d1, $dc, $a7, $c0, $21, $da        ;; 02:6d97 ????????
    db   $dc, $35, $cb, $7e, $28, $02, $36, $02        ;; 02:6d9f ????????
    db   $6e, $26, $00, $11, $b7, $6d, $19, $4e        ;; 02:6da7 ????????
    db   $cd, $0d, $29, $3e, $03, $c3, $ac, $72        ;; 02:6daf ????????
    db   $49, $39, $29, $cd, $3e, $23, $cd, $22        ;; 02:6db7 ????????
    db   $29, $20, $10, $0e, $6a, $cd, $ce, $29        ;; 02:6dbf ????????
    db   $c8, $3e, $01, $ea, $d1, $dc, $3e, $02        ;; 02:6dc7 ????????
    db   $c3, $ac, $72, $e6, $07, $3e, $04, $ca        ;; 02:6dcf ????????
    db   $ac, $72, $c9, $c3, $3e, $23, $cd, $3e        ;; 02:6dd7 ????????
    db   $23, $cd, $f5, $29, $c8, $3e, $15, $cd        ;; 02:6ddf ????????
    db   $f5, $0f, $0e, $18, $c3, $92, $37, $cd        ;; 02:6de7 ????????
    db   $4a, $24, $11, $68, $00, $26, $d8, $fa        ;; 02:6def ????????
    db   $00, $da, $f6, $10, $6f, $2a, $93, $7e        ;; 02:6df7 ????????
    db   $9a, $d8, $72, $2d, $73, $3e, $08, $c3        ;; 02:6dff ????????
    db   $ac, $72, $cd, $f5, $29, $28, $19, $3e        ;; 02:6e07 ????????
    db   $1a, $cd, $f5, $0f, $21, $3c, $6e, $cd        ;; 02:6e0f ????????
    db   $20, $2c, $cd, $8a, $28, $cd, $8b, $2b        ;; 02:6e17 ????????
    db   $cd, $67, $2c, $0e, $3c, $cd, $0d, $29        ;; 02:6e1f ????????
    db   $cd, $89, $2c, $c0, $cd, $22, $29, $c0        ;; 02:6e27 ????????
    db   $3e, $01, $ea, $66, $dc, $21, $6a, $db        ;; 02:6e2f ????????
    db   $cb, $e6, $c3, $7a, $2b, $00, $00, $08        ;; 02:6e37 ????????
    db   $02, $04, $01, $ff, $7f, $cd, $f5, $29        ;; 02:6e3f ????????
    db   $28, $0a, $0e, $00, $cd, $c8, $28, $0e        ;; 02:6e47 ????????
    db   $10, $cd, $dc, $28, $cd, $68, $2a, $fa        ;; 02:6e4f ????????
    db   $12, $da, $fe, $20, $28, $0a, $cd, $be        ;; 02:6e57 ????????
    db   $28, $fe, $10, $28, $0b, $34, $18, $08        ;; 02:6e5f ????????
    db   $cd, $be, $28, $fe, $f0, $28, $01, $35        ;; 02:6e67 ????????
    db   $cd, $c0, $24, $cd, $4a, $24, $11, $88        ;; 02:6e6f ????????
    db   $00, $26, $d8, $fa, $00, $da, $f6, $10        ;; 02:6e77 ????????
    db   $6f, $2a, $93, $7e, $9a, $d2, $7a, $2b        ;; 02:6e7f ????????
    db   $c9, $21, $d1, $dc, $cb, $46, $c8, $36        ;; 02:6e87 ????????
    db   $00, $26, $d8, $fa, $00, $da, $f6, $0e        ;; 02:6e8f ????????
    db   $6f, $11, $78, $00, $73, $2c, $72, $0e        ;; 02:6e97 ????????
    db   $ff, $cd, $0d, $29, $3e, $01, $c3, $ac        ;; 02:6e9f ????????
    db   $72, $cd, $f5, $29, $3e, $1b, $c4, $f5        ;; 02:6ea7 ????????
    db   $0f, $cd, $22, $29, $3e, $04, $ca, $ac        ;; 02:6eaf ????????
    db   $72, $c9, $cd, $f5, $29, $c8, $0e, $16        ;; 02:6eb7 ????????
    db   $cd, $92, $37, $3e, $14, $c3, $f5, $0f        ;; 02:6ebf ????????
    db   $cd, $f5, $29, $0e, $3c, $c4, $dc, $28        ;; 02:6ec7 ????????
    db   $0e, $67, $cd, $ce, $29, $c0, $7d, $f6        ;; 02:6ecf ????????
    db   $01, $6f, $7e, $fe, $06, $30, $1c, $cd        ;; 02:6ed7 ????????
    db   $4a, $24, $cd, $f1, $28, $cb, $7e, $c8        ;; 02:6edf ????????
    db   $11, $38, $00, $26, $d8, $fa, $00, $da        ;; 02:6ee7 ????????
    db   $f6, $10, $6f, $2a, $93, $7e, $9a, $d8        ;; 02:6eef ????????
    db   $72, $2d, $73, $3e, $19, $cd, $f5, $0f        ;; 02:6ef7 ????????
    db   $0e, $17, $cd, $92, $37, $c3, $7a, $2b        ;; 02:6eff ????????
    db   $cd, $5d, $2a, $c2, $7a, $2b, $c9, $c9        ;; 02:6f07 ????????
    db   $cd, $f5, $29, $c8, $0e, $20, $cd, $c8        ;; 02:6f0f ????????
    db   $28, $0e, $00, $cd, $dc, $28, $cd, $17        ;; 02:6f17 ????????
    db   $29, $34, $fe, $0a, $3e, $02, $ca, $ac        ;; 02:6f1f ????????
    db   $72, $c9, $cd, $1c, $25, $cd, $02, $70        ;; 02:6f27 ????????
    db   $0e, $38, $d2, $dc, $28, $c9, $cd, $02        ;; 02:6f2f ????????
    db   $70, $3e, $04, $d2, $ac, $72, $c9, $cd        ;; 02:6f37 ????????
    db   $f5, $29, $0e, $00, $c4, $dc, $28, $cd        ;; 02:6f3f ????????
    db   $d3, $6f, $d0, $0e, $00, $cd, $0d, $29        ;; 02:6f47 ????????
    db   $3e, $06, $c3, $ac, $72, $cd, $f5, $29        ;; 02:6f4f ????????
    db   $c8, $cd, $17, $29, $34, $fe, $0a, $3e        ;; 02:6f57 ????????
    db   $08, $ca, $ac, $72, $c9, $cd, $f5, $29        ;; 02:6f5f ????????
    db   $28, $0b, $cd, $26, $28, $cd, $e4, $27        ;; 02:6f67 ????????
    db   $0e, $06, $cd, $0d, $29, $cd, $17, $29        ;; 02:6f6f ????????
    db   $28, $1a, $fa, $71, $dc, $e6, $3f, $c0        ;; 02:6f77 ????????
    db   $cd, $22, $29, $28, $0f, $fa, $da, $dc        ;; 02:6f7f ????????
    db   $0e, $1d, $e6, $01, $ca, $92, $37, $0e        ;; 02:6f87 ????????
    db   $1e, $c3, $92, $37, $0e, $71, $cd, $ce        ;; 02:6f8f ????????
    db   $29, $3e, $00, $c2, $ac, $72, $c9, $c3        ;; 02:6f97 ????????
    db   $d3, $6f, $cd, $02, $70, $3e, $0b, $d2        ;; 02:6f9f ????????
    db   $ac, $72, $c9, $cd, $f5, $29, $28, $0f        ;; 02:6fa7 ????????
    db   $3e, $1a, $cd, $f5, $0f, $0e, $b4, $cd        ;; 02:6faf ????????
    db   $0d, $29, $0e, $30, $cd, $dc, $28, $cd        ;; 02:6fb7 ????????
    db   $02, $70, $d8, $cd, $22, $29, $c0, $3e        ;; 02:6fbf ????????
    db   $01, $ea, $67, $dc, $21, $6a, $db, $cb        ;; 02:6fc7 ????????
    db   $e6, $c3, $7a, $2b, $cd, $f1, $28, $cb        ;; 02:6fcf ????????
    db   $7f, $20, $06, $fe, $20, $3e, $20, $30        ;; 02:6fd7 ????????
    db   $03, $7e, $c6, $04, $77, $cd, $4a, $24        ;; 02:6fdf ????????
    db   $11, $24, $00, $26, $d8, $fa, $00, $da        ;; 02:6fe7 ????????
    db   $f6, $10, $6f, $2a, $93, $7e, $9a, $d0        ;; 02:6fef ????????
    db   $f5, $72, $2d, $73, $0e, $00, $cd, $dc        ;; 02:6ff7 ????????
    db   $28, $f1, $c9, $cd, $4a, $24, $11, $58        ;; 02:6fff ????????
    db   $00, $26, $d8, $fa, $00, $da, $f6, $10        ;; 02:7007 ????????
    db   $6f, $2a, $93, $7e, $9a, $d8, $72, $2b        ;; 02:700f ????????
    db   $73, $c9, $c9, $cd, $f5, $29, $3e, $13        ;; 02:7017 ????????
    db   $c4, $f5, $0f, $cd, $4a, $24, $cd, $66        ;; 02:701f ????????
    db   $27, $3e, $02, $d2, $ac, $72, $c9, $cd        ;; 02:7027 ????????
    db   $f5, $29, $28, $23, $21, $da, $dc, $7e        ;; 02:702f ????????
    db   $34, $e6, $07, $f5, $6f, $26, $00, $29        ;; 02:7037 ????????
    db   $11, $7f, $70, $19, $f1, $4e, $23, $c5        ;; 02:703f ????????
    db   $4e, $e6, $01, $28, $03, $af, $96, $4f        ;; 02:7047 ????????
    db   $cd, $c8, $28, $c1, $cd, $dc, $28, $cd        ;; 02:704f ????????
    db   $c0, $24, $cd, $4a, $24, $cd, $f1, $28        ;; 02:7057 ????????
    db   $cb, $7f, $c8, $11, $70, $00, $26, $d8        ;; 02:705f ????????
    db   $fa, $00, $da, $f6, $10, $6f, $2a, $93        ;; 02:7067 ????????
    db   $7e, $9a, $d8, $72, $2b, $73, $3e, $19        ;; 02:706f ????????
    db   $cd, $f5, $0f, $3e, $01, $c3, $ac, $72        ;; 02:7077 ????????
    db   $30, $28, $30, $28, $20, $30, $20, $30        ;; 02:707f ????????
    db   $40, $10, $40, $10, $50, $08, $50, $08        ;; 02:7087 ????????
