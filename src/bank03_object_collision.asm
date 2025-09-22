call_03_4c38_UpdateObjectCollision:
    ld   A, [wDCA7]                                    ;; 03:4c38 $fa $a7 $dc
    and  A, A                                          ;; 03:4c3b $a7
    ret  Z                                             ;; 03:4c3c $c8
    ld   H, $d8                                        ;; 03:4c3d $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:4c3f $fa $00 $da
    or   A, $15                                        ;; 03:4c42 $f6 $15
    ld   L, A                                          ;; 03:4c44 $6f
    ld   A, [HL]                                       ;; 03:4c45 $7e
    and  A, A                                          ;; 03:4c46 $a7
    jr   Z, .jr_03_4c4a                                ;; 03:4c47 $28 $01
    dec  [HL]                                          ;; 03:4c49 $35
.jr_03_4c4a:
    ld   A, L                                          ;; 03:4c4a $7d
    xor  A, $10                                        ;; 03:4c4b $ee $10
    ld   L, A                                          ;; 03:4c4d $6f
    bit  0, [HL]                                       ;; 03:4c4e $cb $46
    ret  NZ                                            ;; 03:4c50 $c0
    ld   A, L                                          ;; 03:4c51 $7d
    xor  A, $11                                        ;; 03:4c52 $ee $11
    ld   L, A                                          ;; 03:4c54 $6f
    ld   L, [HL]                                       ;; 03:4c55 $6e
    res  7, L                                          ;; 03:4c56 $cb $bd
    ld   H, $00                                        ;; 03:4c58 $26 $00
    add  HL, HL                                        ;; 03:4c5a $29
    ld   BC, .data_03_4c63_ObjectCollisionJumpTable                             ;; 03:4c5b $01 $63 $4c
    add  HL, BC                                        ;; 03:4c5e $09
    ld   A, [HL+]                                      ;; 03:4c5f $2a
    ld   H, [HL]                                       ;; 03:4c60 $66
    ld   L, A                                          ;; 03:4c61 $6f
    jp   HL                                            ;; 03:4c62 $e9
.data_03_4c63_ObjectCollisionJumpTable:
    dw   .data_03_4ccf                                 ;; 03:4c63 pP
    db   $c1, $56, $d0, $4c, $d7, $4c                  ;; 03:4c65 ??????
    dw   .data_03_4ce1                                 ;; 03:4c6b pP
    db   $38, $4d, $44, $4d                            ;; 03:4c6d ????
    dw   .data_03_4d9b                                 ;; 03:4c71 pP
    dw   .data_03_4db3                                 ;; 03:4c73 pP
    dw   .data_03_4dc2                                 ;; 03:4c75 pP
    db   $04, $4e, $31, $4e                            ;; 03:4c77 ????
    dw   .data_03_4e4b                                 ;; 03:4c7b pP
    dw   .data_03_4e89                                 ;; 03:4c7d pP
    dw   .data_03_4f23                                 ;; 03:4c7f pP
    db   $60, $4f, $8c, $4f, $98, $4f, $ad, $4f        ;; 03:4c81 ????????
    db   $ca, $4f, $f1, $4f, $0d, $50, $b6, $50        ;; 03:4c89 ????????
    db   $e0, $50, $ea, $50, $f4, $50, $16, $51        ;; 03:4c91 ????????
    db   $56, $51, $96, $51, $b8, $51, $01, $52        ;; 03:4c99 ????????
    db   $31, $52, $74, $52, $8c, $52, $aa, $52        ;; 03:4ca1 ????????
    db   $c8, $52, $da, $52, $fa, $52, $1a, $53        ;; 03:4ca9 ????????
    db   $2f, $53, $7a, $53, $8e, $53, $eb, $53        ;; 03:4cb1 ????????
    db   $06, $54, $69, $54                            ;; 03:4cb9 ????
    dw   .data_03_5473                                 ;; 03:4cbd pP
    db   $28, $50, $69, $50, $85, $50, $83, $54        ;; 03:4cbf ????????
    db   $a8, $54                                      ;; 03:4cc7 ??
    dw   data_03_581a                                  ;; 03:4cc9 pP
    db   $ee, $54, $c2, $53                            ;; 03:4ccb ????
.data_03_4ccf:
    ret                                                ;; 03:4ccf $c9
    db   $cd, $0e, $55, $da, $f6, $06, $c9, $cd        ;; 03:4cd0 ????????
    db   $0e, $55, $d0, $cd, $ea, $4c, $c3, $80        ;; 03:4cd8 ????????
    db   $2b                                           ;; 03:4ce0 ?
.data_03_4ce1:
    call call_03_550e                                  ;; 03:4ce1 $cd $0e $55
    ret  NC                                            ;; 03:4ce4 $d0
    cp   A, $00                                        ;; 03:4ce5 $fe $00
    jp   NZ, call_03_5671                                ;; 03:4ce7 $c2 $71 $56
.jp_03_4cea:
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:4cea $fa $01 $d8
    cp   A, $09                                        ;; 03:4ced $fe $09
    jr   Z, .jr_03_4cfe                                ;; 03:4cef $28 $0d
    cp   A, $29                                        ;; 03:4cf1 $fe $29
    jr   Z, .jr_03_4cfe                                ;; 03:4cf3 $28 $09
    cp   A, $36                                        ;; 03:4cf5 $fe $36
    jr   Z, .jr_03_4cfe                                ;; 03:4cf7 $28 $05
    cp   A, $45                                        ;; 03:4cf9 $fe $45
    call NZ, call_00_06f6                              ;; 03:4cfb $c4 $f6 $06
.jr_03_4cfe:
    ld   H, $d8                                        ;; 03:4cfe $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:4d00 $fa $00 $da
    or   A, $0e                                        ;; 03:4d03 $f6 $0e
    ld   L, A                                          ;; 03:4d05 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4d06 $fa $0e $d8
    sub  A, [HL]                                       ;; 03:4d09 $96
    inc  HL                                            ;; 03:4d0a $23
    ld   A, [wD80F_PlayerXPosition]                                    ;; 03:4d0b $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:4d0e $9e
    ld   A, $ff                                        ;; 03:4d0f $3e $ff
    jr   C, .jr_03_4d15                                ;; 03:4d11 $38 $02
    ld   A, $01                                        ;; 03:4d13 $3e $01
.jr_03_4d15:
    ld   [wDC98], A                                    ;; 03:4d15 $ea $98 $dc
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 03:4d18 $fa $6c $db
    cp   A, $07                                        ;; 03:4d1b $fe $07
    ld   A, $29                                        ;; 03:4d1d $3e $29
    jr   Z, .jr_03_4d2c                                ;; 03:4d1f $28 $0b
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 03:4d21 $fa $6c $db
    cp   A, $08                                        ;; 03:4d24 $fe $08
    ld   A, $36                                        ;; 03:4d26 $3e $36
    jr   Z, .jr_03_4d2c                                ;; 03:4d28 $28 $02
    ld   A, $09                                        ;; 03:4d2a $3e $09
.jr_03_4d2c:
    ld   [wDAD6_ReturnBank], A                                    ;; 03:4d2c $ea $d6 $da
    ld   A, $02                                        ;; 03:4d2f $3e $02
    ld   HL, entry_02_54f9_SwitchPlayerAction                             ;; 03:4d31 $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 03:4d34 $cd $dd $0e
    ret                                                ;; 03:4d37 $c9
    db   $cd, $0e, $55, $d0, $fe, $00, $ca, $f6        ;; 03:4d38 ????????
    db   $06, $c3, $71, $56, $fa, $01, $d8, $fe        ;; 03:4d40 ????????
    db   $09, $c8, $fe, $29, $c8, $fe, $36, $c8        ;; 03:4d48 ????????
    db   $fe, $45, $c8, $cd, $0e, $55, $d0, $fe        ;; 03:4d50 ????????
    db   $01, $ca, $71, $56, $3e, $3c, $ea, $7e        ;; 03:4d58 ????????
    db   $dc, $26, $d8, $fa, $00, $da, $f6, $0e        ;; 03:4d60 ????????
    db   $6f, $fa, $0e, $d8, $96, $23, $fa, $0f        ;; 03:4d68 ????????
    db   $d8, $9e, $3e, $ff, $38, $02, $3e, $01        ;; 03:4d70 ????????
    db   $ea, $98, $dc, $fa, $6c, $db, $fe, $07        ;; 03:4d78 ????????
    db   $3e, $29, $28, $0b, $fa, $6c, $db, $fe        ;; 03:4d80 ????????
    db   $08, $3e, $36, $28, $02, $3e, $09, $ea        ;; 03:4d88 ????????
    db   $d6, $da, $3e, $02, $21, $f9, $54, $cd        ;; 03:4d90 ????????
    db   $dd, $0e, $c9                                 ;; 03:4d98 ???
.data_03_4d9b:
    call call_03_550e                                  ;; 03:4d9b $cd $0e $55
    ret  NC                                            ;; 03:4d9e $d0
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 03:4d9f $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4da2 $6e
    ld   H, $00                                        ;; 03:4da3 $26 $00
    ld   DE, wDC5C                                     ;; 03:4da5 $11 $5c $dc
    add  HL, DE                                        ;; 03:4da8 $19
    set  4, [HL]                                       ;; 03:4da9 $cb $e6
    ld   A, $02                                        ;; 03:4dab $3e $02
    call call_00_0ff5_MaybeQueueBankChange                                  ;; 03:4dad $cd $f5 $0f
    jp   call_03_5671                                    ;; 03:4db0 $c3 $71 $56
.data_03_4db3:
    call call_03_550e                                  ;; 03:4db3 $cd $0e $55
    ret  NC                                            ;; 03:4db6 $d0
    call call_00_0723                                  ;; 03:4db7 $cd $23 $07
    ld   A, $02                                        ;; 03:4dba $3e $02
    call call_00_0ff5_MaybeQueueBankChange                                  ;; 03:4dbc $cd $f5 $0f
    jp   call_03_5671                                    ;; 03:4dbf $c3 $71 $56
.data_03_4dc2:
    call call_03_550e                                  ;; 03:4dc2 $cd $0e $55
    ret  NC                                            ;; 03:4dc5 $d0
    call call_00_230f_ResolveObjectListIndex                                  ;; 03:4dc6 $cd $0f $23
    ld   B, $00                                        ;; 03:4dc9 $06 $00
    ld   HL, .data_03_4e00                             ;; 03:4dcb $21 $00 $4e
    add  HL, BC                                        ;; 03:4dce $09
    ld   C, [HL]                                       ;; 03:4dcf $4e
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 03:4dd0 $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4dd3 $6e
    ld   H, $00                                        ;; 03:4dd4 $26 $00
    ld   DE, wDC5C                                     ;; 03:4dd6 $11 $5c $dc
    add  HL, DE                                        ;; 03:4dd9 $19
    ld   A, [HL]                                       ;; 03:4dda $7e
    or   A, C                                          ;; 03:4ddb $b1
    ld   [HL], A                                       ;; 03:4ddc $77
    ld   HL, wDCAF                                     ;; 03:4ddd $21 $af $dc
    inc  [HL]                                          ;; 03:4de0 $34
    ld   A, [HL]                                       ;; 03:4de1 $7e
    sub  A, $04                                        ;; 03:4de2 $d6 $04
    jr   NZ, .jr_03_4df8                               ;; 03:4de4 $20 $12
    ld   HL, wDC4F                                     ;; 03:4de6 $21 $4f $dc
    ld   A, [HL]                                       ;; 03:4de9 $7e
    cp   A, $04                                        ;; 03:4dea $fe $04
    jr   Z, .jr_03_4df8                                ;; 03:4dec $28 $0a
    inc  [HL]                                          ;; 03:4dee $34
    xor  A, A                                          ;; 03:4def $af
    ld   [wDCAF], A                                    ;; 03:4df0 $ea $af $dc
    ld   HL, wDB69                                     ;; 03:4df3 $21 $69 $db
    set  1, [HL]                                       ;; 03:4df6 $cb $ce
.jr_03_4df8:
    ld   A, $02                                        ;; 03:4df8 $3e $02
    call call_00_0ff5_MaybeQueueBankChange                                  ;; 03:4dfa $cd $f5 $0f
    jp   call_03_5671                                    ;; 03:4dfd $c3 $71 $56
.data_03_4e00:
    db   $00, $20, $40, $80, $cd, $0e, $55, $d0        ;; 03:4e00 ?...????
    db   $cd, $3a, $29, $d6, $04, $6f, $26, $00        ;; 03:4e08 ????????
    db   $11, $2c, $4e, $19, $7e, $cd, $24, $06        ;; 03:4e10 ????????
    db   $26, $d8, $fa, $00, $da, $f6, $1f, $6f        ;; 03:4e18 ????????
    db   $6e, $26, $d7, $7e, $e6, $f0, $f6, $03        ;; 03:4e20 ????????
    db   $77, $c3, $80, $2b, $03, $04, $01, $05        ;; 03:4e28 ????????
    db   $02, $cd, $62, $29, $fe, $00, $c0, $cd        ;; 03:4e30 ????????
    db   $0e, $55, $d0, $fe, $01, $c0, $3e, $03        ;; 03:4e38 ????????
    db   $cd, $f5, $0f, $cd, $71, $56, $0e, $02        ;; 03:4e40 ????????
    db   $c3, $99, $22                                 ;; 03:4e48 ???
.data_03_4e4b:
    call call_00_2962_ObjectGetActionId                                  ;; 03:4e4b $cd $62 $29
    cp   A, $02                                        ;; 03:4e4e $fe $02
    ret  NC                                            ;; 03:4e50 $d0
    call call_03_550e                                  ;; 03:4e51 $cd $0e $55
    ret  NC                                            ;; 03:4e54 $d0
    cp   A, $01                                        ;; 03:4e55 $fe $01
    ret  NZ                                            ;; 03:4e57 $c0
    ld   A, $19                                        ;; 03:4e58 $3e $19
    call call_00_0ff5_MaybeQueueBankChange                                  ;; 03:4e5a $cd $f5 $0f
    call call_00_2962_ObjectGetActionId                                  ;; 03:4e5d $cd $62 $29
    inc  A                                             ;; 03:4e60 $3c
    push AF                                            ;; 03:4e61 $f5
    push AF                                            ;; 03:4e62 $f5
    ld   C, A                                          ;; 03:4e63 $4f
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 03:4e64 $cd $99 $22
    pop  AF                                            ;; 03:4e67 $f1
    ld   [wDAD6_ReturnBank], A                                    ;; 03:4e68 $ea $d6 $da
    ld   A, $02                                        ;; 03:4e6b $3e $02
    ld   HL, entry_02_72ac_LoadObjectData                              ;; 03:4e6d $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 03:4e70 $cd $dd $0e
    pop  AF                                            ;; 03:4e73 $f1
    cp   A, $02                                        ;; 03:4e74 $fe $02
    ret  NZ                                            ;; 03:4e76 $c0
    ld   HL, wDCC3                                     ;; 03:4e77 $21 $c3 $dc
    inc  [HL]                                          ;; 03:4e7a $34
    ld   A, [HL]                                       ;; 03:4e7b $7e
    cp   A, $05                                        ;; 03:4e7c $fe $05
    ld   C, $01                                        ;; 03:4e7e $0e $01
    call Z, call_00_21ef                               ;; 03:4e80 $cc $ef $21
    ld   A, [wDCC3]                                    ;; 03:4e83 $fa $c3 $dc
    jp   call_00_2c09_DispatchOffsetAction                                  ;; 03:4e86 $c3 $09 $2c
.data_03_4e89:
    call call_00_28d2_ObjectGet1D                                  ;; 03:4e89 $cd $d2 $28
    bit  7, A                                          ;; 03:4e8c $cb $7f
    ret  NZ                                            ;; 03:4e8e $c0
    call call_00_2962_ObjectGetActionId                                  ;; 03:4e8f $cd $62 $29
    cp   A, $05                                        ;; 03:4e92 $fe $05
    ret  NC                                            ;; 03:4e94 $d0
    call call_03_550e                                  ;; 03:4e95 $cd $0e $55
    ret  NC                                            ;; 03:4e98 $d0
    cp   A, $01                                        ;; 03:4e99 $fe $01
    jr   NZ, .jr_03_4eea                               ;; 03:4e9b $20 $4d
    call call_00_28d2_ObjectGet1D                                  ;; 03:4e9d $cd $d2 $28
    cpl                                                ;; 03:4ea0 $2f
    inc  A                                             ;; 03:4ea1 $3c
    ld   [HL], A                                       ;; 03:4ea2 $77
    ld   C, $1e                                        ;; 03:4ea3 $0e $1e
    call call_00_29ce_ObjectExistsCheck                                  ;; 03:4ea5 $cd $ce $29
    jp   NZ, call_00_2b80_ClearObjectMemoryEntry                              ;; 03:4ea8 $c2 $80 $2b
    ld   A, L                                          ;; 03:4eab $7d
    or   A, $0e                                        ;; 03:4eac $f6 $0e
    ld   L, A                                          ;; 03:4eae $6f
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:4eaf $fa $00 $da
    or   A, $0e                                        ;; 03:4eb2 $f6 $0e
    ld   E, A                                          ;; 03:4eb4 $5f
    ld   D, $d8                                        ;; 03:4eb5 $16 $d8
    ld   A, [DE]                                       ;; 03:4eb7 $1a
    sub  A, [HL]                                       ;; 03:4eb8 $96
    ld   C, A                                          ;; 03:4eb9 $4f
    inc  HL                                            ;; 03:4eba $23
    inc  DE                                            ;; 03:4ebb $13
    ld   A, [DE]                                       ;; 03:4ebc $1a
    sbc  A, [HL]                                       ;; 03:4ebd $9e
    ld   B, A                                          ;; 03:4ebe $47
    push AF                                            ;; 03:4ebf $f5
    jr   NC, .jr_03_4ec9                               ;; 03:4ec0 $30 $07
    xor  A, A                                          ;; 03:4ec2 $af
    sub  A, C                                          ;; 03:4ec3 $91
    ld   C, A                                          ;; 03:4ec4 $4f
    ld   A, $00                                        ;; 03:4ec5 $3e $00
    sbc  A, B                                          ;; 03:4ec7 $98
    ld   B, A                                          ;; 03:4ec8 $47
.jr_03_4ec9:
    ld   A, B                                          ;; 03:4ec9 $78
    and  A, A                                          ;; 03:4eca $a7
    jr   NZ, .jr_03_4ed2                               ;; 03:4ecb $20 $05
    ld   A, C                                          ;; 03:4ecd $79
    cp   A, $a0                                        ;; 03:4ece $fe $a0
    jr   C, .jr_03_4ed4                                ;; 03:4ed0 $38 $02
.jr_03_4ed2:
    ld   A, $a0                                        ;; 03:4ed2 $3e $a0
.jr_03_4ed4:
    srl  A                                             ;; 03:4ed4 $cb $3f
    srl  A                                             ;; 03:4ed6 $cb $3f
    ld   L, A                                          ;; 03:4ed8 $6f
    ld   H, $00                                        ;; 03:4ed9 $26 $00
    ld   DE, .data_03_4efa                             ;; 03:4edb $11 $fa $4e
    add  HL, DE                                        ;; 03:4ede $19
    pop  AF                                            ;; 03:4edf $f1
    ld   A, [HL]                                       ;; 03:4ee0 $7e
    jr   C, .jr_03_4ee5                                ;; 03:4ee1 $38 $02
    cpl                                                ;; 03:4ee3 $2f
    inc  A                                             ;; 03:4ee4 $3c
.jr_03_4ee5:
    ld   C, A                                          ;; 03:4ee5 $4f
    call call_00_28c8_ObjectSet1B                                  ;; 03:4ee6 $cd $c8 $28
    ret                                                ;; 03:4ee9 $c9
.jr_03_4eea:
    ld   A, $06                                        ;; 03:4eea $3e $06
    ld   [wDAD6_ReturnBank], A                                    ;; 03:4eec $ea $d6 $da
    ld   A, $02                                        ;; 03:4eef $3e $02
    ld   HL, entry_02_72ac_LoadObjectData                              ;; 03:4ef1 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 03:4ef4 $cd $dd $0e
    jp   .jp_03_4cea                                   ;; 03:4ef7 $c3 $ea $4c
.data_03_4efa:
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 03:4efa ???.????
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10        ;; 03:4f02 ????????
    db   $11, $12, $13, $14, $15, $16, $17, $18        ;; 03:4f0a ????????
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21        ;; 03:4f12 ????????
    db   $22, $23, $24, $25, $27, $28, $29, $2a        ;; 03:4f1a ????????
    db   $2b                                           ;; 03:4f22 ?
.data_03_4f23:
    call call_03_550e                                  ;; 03:4f23 $cd $0e $55
    ret  NC                                            ;; 03:4f26 $d0
    cp   A, $01                                        ;; 03:4f27 $fe $01
    jp   NZ, .jp_03_4cea                               ;; 03:4f29 $c2 $ea $4c
    ld   A, $04                                        ;; 03:4f2c $3e $04
    ld   [wDAD6_ReturnBank], A                                    ;; 03:4f2e $ea $d6 $da
    ld   A, $02                                        ;; 03:4f31 $3e $02
    ld   HL, entry_02_72ac_LoadObjectData                              ;; 03:4f33 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 03:4f36 $cd $dd $0e
    call call_00_230f_ResolveObjectListIndex                                  ;; 03:4f39 $cd $0f $23
    ld   B, $00                                        ;; 03:4f3c $06 $00
    ld   HL, wDCD5                                     ;; 03:4f3e $21 $d5 $dc
    add  HL, BC                                        ;; 03:4f41 $09
    ld   A, [HL]                                       ;; 03:4f42 $7e
    and  A, A                                          ;; 03:4f43 $a7
    ret  Z                                             ;; 03:4f44 $c8
    dec  [HL]                                          ;; 03:4f45 $35
    ret  NZ                                            ;; 03:4f46 $c0
    call call_00_288c_Object_Clear14                                  ;; 03:4f47 $cd $8a $28
    call call_00_2b8b_HandleObjectFlag6ClearOrInit                                  ;; 03:4f4a $cd $8b $2b
    ld   HL, wDCC8                                     ;; 03:4f4d $21 $c8 $dc
    inc  [HL]                                          ;; 03:4f50 $34
    ld   A, [HL]                                       ;; 03:4f51 $7e
    call call_00_2c09_DispatchOffsetAction                                  ;; 03:4f52 $cd $09 $2c
    ld   HL, wDCD5                                     ;; 03:4f55 $21 $d5 $dc
    ld   A, [HL+]                                      ;; 03:4f58 $2a
    or   A, [HL]                                       ;; 03:4f59 $b6
    ret  NZ                                            ;; 03:4f5a $c0
    ld   C, $02                                        ;; 03:4f5b $0e $02
    jp   call_00_21ef                                  ;; 03:4f5d $c3 $ef $21
    db   $cd, $62, $29, $fe, $00, $c0, $cd, $0e        ;; 03:4f60 ????????
    db   $55, $d0, $fe, $01, $c0, $cd, $71, $56        ;; 03:4f68 ????????
    db   $3e, $19, $cd, $f5, $0f, $0e, $01, $cd        ;; 03:4f70 ????????
    db   $99, $22, $21, $c5, $dc, $34, $7e, $fe        ;; 03:4f78 ????????
    db   $03, $0e, $02, $cc, $ef, $21, $fa, $c5        ;; 03:4f80 ????????
    db   $dc, $c3, $09, $2c, $cd, $0e, $55, $d0        ;; 03:4f88 ????????
    db   $0e, $03, $cd, $ef, $21, $c3, $71, $56        ;; 03:4f90 ????????
    db   $cd, $0e, $55, $d0, $fe, $01, $c2, $ea        ;; 03:4f98 ????????
    db   $4c, $cd, $71, $56, $cd, $62, $29, $fe        ;; 03:4fa0 ????????
    db   $05, $ca, $ef, $22, $c9, $cd, $0e, $55        ;; 03:4fa8 ????????
    db   $d0, $fe, $01, $c2, $ea, $4c, $cd, $95        ;; 03:4fb0 ????????
    db   $29, $fe, $00, $c0, $3e, $01, $ea, $d6        ;; 03:4fb8 ????????
    db   $da, $3e, $02, $21, $ac, $72, $cd, $dd        ;; 03:4fc0 ????????
    db   $0e, $c9, $cd, $62, $29, $fe, $00, $c0        ;; 03:4fc8 ????????
    db   $cd, $0e, $55, $d0, $fe, $02, $c0, $cd        ;; 03:4fd0 ????????
    db   $71, $56, $0e, $04, $cd, $99, $22, $21        ;; 03:4fd8 ????????
    db   $c6, $dc, $34, $7e, $fe, $03, $0e, $02        ;; 03:4fe0 ????????
    db   $cc, $ef, $21, $fa, $c6, $dc, $c3, $09        ;; 03:4fe8 ????????
    db   $2c, $cd, $0e, $55, $d0, $fe, $01, $c0        ;; 03:4ff0 ????????
    db   $cd, $71, $56, $21, $c7, $dc, $34, $7e        ;; 03:4ff8 ????????
    db   $fe, $03, $0e, $01, $cc, $ef, $21, $fa        ;; 03:5000 ????????
    db   $c7, $dc, $c3, $09, $2c, $cd, $62, $29        ;; 03:5008 ????????
    db   $fe, $00, $c0, $cd, $0e, $55, $d0, $fe        ;; 03:5010 ????????
    db   $01, $c0, $3e, $01, $ea, $d6, $da, $3e        ;; 03:5018 ????????
    db   $02, $21, $ac, $72, $cd, $dd, $0e, $c9        ;; 03:5020 ????????
    db   $cd, $0e, $55, $30, $1f, $fe, $00, $28        ;; 03:5028 ????????
    db   $13, $21, $a9, $dc, $2a, $b6, $23, $b6        ;; 03:5030 ????????
    db   $28, $0a, $cd, $62, $29, $fe, $05, $dc        ;; 03:5038 ????????
    db   $71, $56, $18, $08, $cd, $62, $29, $fe        ;; 03:5040 ????????
    db   $05, $cc, $ea, $4c, $cd, $62, $29, $fe        ;; 03:5048 ????????
    db   $04, $d0, $cd, $68, $2a, $fa, $11, $da        ;; 03:5050 ????????
    db   $fe, $28, $d0, $3e, $05, $ea, $d6, $da        ;; 03:5058 ????????
    db   $3e, $02, $21, $ac, $72, $cd, $dd, $0e        ;; 03:5060 ????????
    db   $c9, $cd, $0e, $55, $d0, $fe, $00, $c8        ;; 03:5068 ????????
    db   $cd, $71, $56, $21, $cf, $dc, $34, $7e        ;; 03:5070 ????????
    db   $fe, $05, $0e, $02, $cc, $ef, $21, $fa        ;; 03:5078 ????????
    db   $cf, $dc, $c3, $09, $2c, $cd, $0e, $55        ;; 03:5080 ????????
    db   $d0, $fe, $01, $c2, $ea, $4c, $cd, $62        ;; 03:5088 ????????
    db   $29, $fe, $02, $28, $13, $fe, $01, $ca        ;; 03:5090 ????????
    db   $71, $56, $3e, $02, $ea, $d6, $da, $3e        ;; 03:5098 ????????
    db   $02, $21, $ac, $72, $cd, $dd, $0e, $c9        ;; 03:50a0 ????????
    db   $3e, $01, $ea, $d6, $da, $3e, $02, $21        ;; 03:50a8 ????????
    db   $ac, $72, $cd, $dd, $0e, $c9, $cd, $62        ;; 03:50b0 ????????
    db   $29, $fe, $00, $c0, $cd, $0e, $55, $d0        ;; 03:50b8 ????????
    db   $fe, $01, $c0, $cd, $71, $56, $cd, $ef        ;; 03:50c0 ????????
    db   $22, $0e, $02, $cd, $99, $22, $21, $c9        ;; 03:50c8 ????????
    db   $dc, $34, $7e, $fe, $03, $0e, $01, $cc        ;; 03:50d0 ????????
    db   $ef, $21, $fa, $c9, $dc, $c3, $09, $2c        ;; 03:50d8 ????????
    db   $cd, $0e, $55, $d0, $fe, $01, $ca, $ef        ;; 03:50e0 ????????
    db   $22, $c9, $cd, $0e, $55, $d0, $fe, $01        ;; 03:50e8 ????????
    db   $ca, $ff, $22, $c9, $cd, $62, $29, $fe        ;; 03:50f0 ????????
    db   $00, $c0, $cd, $0e, $55, $d0, $fe, $01        ;; 03:50f8 ????????
    db   $c0, $0e, $01, $cd, $99, $22, $3e, $01        ;; 03:5100 ????????
    db   $ea, $d6, $da, $3e, $02, $21, $ac, $72        ;; 03:5108 ????????
    db   $cd, $dd, $0e, $c3, $e0, $22, $cd, $62        ;; 03:5110 ????????
    db   $29, $fe, $00, $c0, $cd, $0e, $55, $d0        ;; 03:5118 ????????
    db   $21, $be, $da, $cb, $7e, $c8, $21, $81        ;; 03:5120 ????????
    db   $dc, $cb, $76, $c8, $fa, $01, $d8, $fe        ;; 03:5128 ????????
    db   $01, $d8, $fe, $03, $d0, $cd, $0f, $23        ;; 03:5130 ????????
    db   $0c, $28, $08, $cd, $d4, $22, $3e, $1b        ;; 03:5138 ????????
    db   $ca, $f5, $0f, $3e, $18, $cd, $f5, $0f        ;; 03:5140 ????????
    db   $3e, $01, $ea, $d6, $da, $3e, $02, $21        ;; 03:5148 ????????
    db   $ac, $72, $cd, $dd, $0e, $c9, $cd, $62        ;; 03:5150 ????????
    db   $29, $fe, $02, $c0, $cd, $0e, $55, $d0        ;; 03:5158 ????????
    db   $21, $be, $da, $cb, $7e, $c8, $21, $81        ;; 03:5160 ????????
    db   $dc, $cb, $76, $c8, $fa, $01, $d8, $fe        ;; 03:5168 ????????
    db   $01, $d8, $fe, $03, $d0, $cd, $0f, $23        ;; 03:5170 ????????
    db   $0c, $28, $08, $cd, $d4, $22, $3e, $1b        ;; 03:5178 ????????
    db   $ca, $f5, $0f, $3e, $18, $cd, $f5, $0f        ;; 03:5180 ????????
    db   $3e, $03, $ea, $d6, $da, $3e, $02, $21        ;; 03:5188 ????????
    db   $ac, $72, $cd, $dd, $0e, $c9, $cd, $0e        ;; 03:5190 ????????
    db   $55, $d0, $fe, $01, $c2, $ea, $4c, $cd        ;; 03:5198 ????????
    db   $71, $56, $cd, $62, $29, $fe, $00, $c2        ;; 03:51a0 ????????
    db   $ef, $22, $3e, $02, $ea, $d6, $da, $3e        ;; 03:51a8 ????????
    db   $02, $21, $ac, $72, $cd, $dd, $0e, $c9        ;; 03:51b0 ????????
    db   $cd, $0e, $55, $d0, $fe, $01, $c2, $ea        ;; 03:51b8 ????????
    db   $4c, $cd, $62, $29, $fe, $02, $28, $1b        ;; 03:51c0 ????????
    db   $cd, $71, $56, $cd, $62, $29, $fe, $02        ;; 03:51c8 ????????
    db   $0e, $02, $ca, $99, $22, $3e, $03, $ea        ;; 03:51d0 ????????
    db   $d6, $da, $3e, $02, $21, $ac, $72, $cd        ;; 03:51d8 ????????
    db   $dd, $0e, $c9, $cd, $ef, $22, $0e, $00        ;; 03:51e0 ????????
    db   $cd, $8c, $28, $0e, $00, $cd, $58, $29        ;; 03:51e8 ????????
    db   $cd, $67, $2c, $3e, $07, $ea, $d6, $da        ;; 03:51f0 ????????
    db   $3e, $02, $21, $ac, $72, $cd, $dd, $0e        ;; 03:51f8 ????????
    db   $c9, $cd, $62, $29, $fe, $03, $c8, $cd        ;; 03:5200 ????????
    db   $0e, $55, $d0, $fe, $01, $28, $13, $cd        ;; 03:5208 ????????
    db   $ea, $4c, $3e, $02, $ea, $d6, $da, $3e        ;; 03:5210 ????????
    db   $02, $21, $ac, $72, $cd, $dd, $0e, $c3        ;; 03:5218 ????????
    db   $10, $24, $cd, $10, $24, $cd, $71, $56        ;; 03:5220 ????????
    db   $cd, $62, $29, $fe, $03, $ca, $ef, $22        ;; 03:5228 ????????
    db   $c9, $cd, $0e, $55, $d0, $fe, $01, $c2        ;; 03:5230 ????????
    db   $ea, $4c, $21, $a9, $dc, $2a, $b6, $23        ;; 03:5238 ????????
    db   $b6, $c8, $cd, $71, $56, $cd, $62, $29        ;; 03:5240 ????????
    db   $fe, $01, $c0, $cd, $e0, $22, $fa, $6c        ;; 03:5248 ????????
    db   $db, $fe, $29, $28, $03, $fe, $2a, $c0        ;; 03:5250 ????????
    db   $21, $cb, $dc, $34, $7e, $fe, $04, $0e        ;; 03:5258 ????????
    db   $03, $cc, $ef, $21, $fa, $cb, $dc, $c3        ;; 03:5260 ????????
    db   $09, $2c, $cd, $0e, $55, $d0, $fe, $00        ;; 03:5268 ????????
    db   $ca, $ea, $4c, $c9, $cd, $0e, $55, $d0        ;; 03:5270 ????????
    db   $fe, $02, $c0, $cd, $71, $56, $cd, $62        ;; 03:5278 ????????
    db   $29, $fe, $01, $c0, $0e, $02, $cd, $ef        ;; 03:5280 ????????
    db   $21, $c3, $ff, $22, $cd, $0e, $55, $d0        ;; 03:5288 ????????
    db   $fe, $00, $ca, $ea, $4c, $cd, $71, $56        ;; 03:5290 ????????
    db   $21, $ca, $dc, $34, $7e, $fe, $03, $0e        ;; 03:5298 ????????
    db   $02, $cc, $ef, $21, $fa, $ca, $dc, $c3        ;; 03:52a0 ????????
    db   $09, $2c, $cd, $0e, $55, $d0, $fe, $01        ;; 03:52a8 ????????
    db   $c2, $ea, $4c, $cd, $71, $56, $21, $cd        ;; 03:52b0 ????????
    db   $dc, $34, $7e, $fe, $05, $0e, $03, $cc        ;; 03:52b8 ????????
    db   $ef, $21, $fa, $cd, $dc, $c3, $09, $2c        ;; 03:52c0 ????????
    db   $cd, $0e, $55, $d0, $fe, $01, $c2, $ea        ;; 03:52c8 ????????
    db   $4c, $cd, $ac, $29, $ca, $ea, $4c, $c3        ;; 03:52d0 ????????
    db   $71, $56, $cd, $0e, $55, $d0, $fe, $01        ;; 03:52d8 ????????
    db   $c2, $ea, $4c, $cd, $71, $56, $cd, $62        ;; 03:52e0 ????????
    db   $29, $fe, $03, $c8, $3e, $02, $ea, $d6        ;; 03:52e8 ????????
    db   $da, $3e, $02, $21, $ac, $72, $cd, $dd        ;; 03:52f0 ????????
    db   $0e, $c9, $cd, $62, $29, $fe, $04, $ca        ;; 03:52f8 ????????
    db   $e1, $4c, $fe, $02, $c0, $cd, $0e, $55        ;; 03:5300 ????????
    db   $d0, $fe, $01, $c0, $3e, $03, $ea, $d6        ;; 03:5308 ????????
    db   $da, $3e, $02, $21, $ac, $72, $cd, $dd        ;; 03:5310 ????????
    db   $0e, $c9, $cd, $0e, $55, $d0, $fe, $01        ;; 03:5318 ????????
    db   $c0, $21, $a9, $dc, $2a, $b6, $23, $b6        ;; 03:5320 ????????
    db   $c8, $cd, $71, $56, $c3, $ef, $22, $cd        ;; 03:5328 ????????
    db   $62, $29, $fe, $04, $d0, $cd, $0e, $55        ;; 03:5330 ????????
    db   $d0, $fe, $01, $c2, $ea, $4c, $3e, $04        ;; 03:5338 ????????
    db   $ea, $d6, $da, $3e, $02, $21, $ac, $72        ;; 03:5340 ????????
    db   $cd, $dd, $0e, $cd, $0f, $23, $06, $00        ;; 03:5348 ????????
    db   $21, $d5, $dc, $09, $7e, $a7, $c8, $35        ;; 03:5350 ????????
    db   $c0, $cd, $8a, $28, $cd, $8b, $2b, $21        ;; 03:5358 ????????
    db   $c8, $dc, $34, $7e, $cd, $09, $2c, $21        ;; 03:5360 ????????
    db   $d5, $dc, $06, $05, $af, $b6, $23, $05        ;; 03:5368 ????????
    db   $20, $fb, $a7, $c0, $3e, $01, $ea, $d2        ;; 03:5370 ????????
    db   $dc, $c9, $cd, $0e, $55, $d0, $fe, $01        ;; 03:5378 ????????
    db   $c0, $cd, $0f, $23, $fa, $6e, $db, $81        ;; 03:5380 ????????
    db   $ea, $6e, $db, $c3, $71, $56, $cd, $0e        ;; 03:5388 ????????
    db   $55, $d0, $fe, $01, $c0, $cd, $62, $29        ;; 03:5390 ????????
    db   $fe, $00, $20, $14, $21, $cc, $dc, $34        ;; 03:5398 ????????
    db   $7e, $cd, $09, $2c, $fa, $cc, $dc, $fe        ;; 03:53a0 ????????
    db   $07, $20, $05, $3e, $01, $ea, $d2, $dc        ;; 03:53a8 ????????
    db   $3e, $01, $ea, $d6, $da, $3e, $02, $21        ;; 03:53b0 ????????
    db   $ac, $72, $cd, $dd, $0e, $0e, $02, $c3        ;; 03:53b8 ????????
    db   $99, $22, $cd, $62, $29, $fe, $05, $d0        ;; 03:53c0 ????????
    db   $fe, $03, $28, $0a, $cd, $0e, $55, $d0        ;; 03:53c8 ????????
    db   $fe, $01, $ca, $71, $56, $c9, $fa, $88        ;; 03:53d0 ????????
    db   $dc, $a7, $c0, $3e, $01, $ea, $d6, $da        ;; 03:53d8 ????????
    db   $3e, $02, $21, $ac, $72, $cd, $dd, $0e        ;; 03:53e0 ????????
    db   $c3, $ea, $4c, $cd, $62, $29, $fe, $02        ;; 03:53e8 ????????
    db   $c0, $cd, $0e, $55, $d0, $fe, $01, $c0        ;; 03:53f0 ????????
    db   $3e, $03, $ea, $d6, $da, $3e, $02, $21        ;; 03:53f8 ????????
    db   $ac, $72, $cd, $dd, $0e, $c9, $cd, $e1        ;; 03:5400 ????????
    db   $4c, $cd, $95, $29, $fe, $06, $d0, $0e        ;; 03:5408 ????????
    db   $68, $cd, $ce, $29, $c0, $7d, $f6, $1d        ;; 03:5410 ????????
    db   $6f, $cb, $7e, $c8, $7d, $ee, $13, $6f        ;; 03:5418 ????????
    db   $16, $d8, $fa, $00, $da, $f6, $0e, $5f        ;; 03:5420 ????????
    db   $1a, $96, $4f, $13, $23, $1a, $9e, $47        ;; 03:5428 ????????
    db   $79, $c6, $0c, $4f, $78, $ce, $00, $c0        ;; 03:5430 ????????
    db   $79, $fe, $18, $d0, $13, $23, $1a, $96        ;; 03:5438 ????????
    db   $4f, $13, $23, $1a, $9e, $47, $79, $c6        ;; 03:5440 ????????
    db   $0c, $4f, $78, $ce, $00, $c0, $79, $fe        ;; 03:5448 ????????
    db   $18, $d0, $cd, $71, $56, $cd, $95, $29        ;; 03:5450 ????????
    db   $fe, $07, $c8, $3e, $06, $ea, $d6, $da        ;; 03:5458 ????????
    db   $3e, $02, $21, $ac, $72, $cd, $dd, $0e        ;; 03:5460 ????????
    db   $c9, $cd, $0e, $55, $d0, $cd, $ea, $4c        ;; 03:5468 ????????
    db   $c3, $7a, $2b                                 ;; 03:5470 ???
.data_03_5473:
    call call_03_550e                                  ;; 03:5473 $cd $0e $55
    ret  NC                                            ;; 03:5476 $d0
    cp   A, $01                                        ;; 03:5477 $fe $01
    ret  NZ                                            ;; 03:5479 $c0
    call call_00_2962_ObjectGetActionId                                  ;; 03:547a $cd $62 $29
    ld   A, $81                                        ;; 03:547d $3e $81
    ld   [wDCD2], A                                    ;; 03:547f $ea $d2 $dc
    ret                                                ;; 03:5482 $c9
    db   $cd, $0e, $55, $d0, $fe, $00, $c0, $cd        ;; 03:5483 ????????
    db   $62, $29, $fe, $00, $28, $06, $fe, $01        ;; 03:548b ????????
    db   $ca, $ea, $4c, $c9, $cd, $cb, $27, $3e        ;; 03:5493 ????????
    db   $01, $ea, $d6, $da, $3e, $02, $21, $ac        ;; 03:549b ????????
    db   $72, $cd, $dd, $0e, $c9, $cd, $95, $29        ;; 03:54a3 ????????
    db   $fe, $03, $d0, $cd, $0e, $55, $d0, $fe        ;; 03:54ab ????????
    db   $01, $c2, $ea, $4c, $cd, $71, $56, $26        ;; 03:54b3 ????????
    db   $d8, $fa, $00, $da, $f6, $15, $6f, $36        ;; 03:54bb ????????
    db   $00, $cd, $95, $29, $fe, $0a, $c8, $cd        ;; 03:54c3 ????????
    db   $b4, $28, $0e, $03, $fe, $03, $28, $0e        ;; 03:54cb ????????
    db   $fe, $06, $28, $0a, $fe, $09, $28, $06        ;; 03:54d3 ????????
    db   $fe, $0c, $28, $02, $0e, $09, $79, $ea        ;; 03:54db ????????
    db   $d6, $da, $3e, $02, $21, $ac, $72, $cd        ;; 03:54e3 ????????
    db   $dd, $0e, $c9, $cd, $0e, $55, $d0, $cd        ;; 03:54eb ????????
    db   $ea, $4c, $3e, $00, $ea, $d6                  ;; 03:54f3 ??????
    db   $da, $3e, $02, $21, $ac, $72, $cd, $dd        ;; 03:54f9 ????????
    db   $0e, $c9, $fa, $00, $da, $f6, $15, $6f        ;; 03:5501 ????????
    db   $26, $d8, $36, $3c, $c9                       ;; 03:5509 ?????

call_03_550e:
    ld   B, $d8                                        ;; 03:550e $06 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5510 $fa $00 $da
    or   A, $15                                        ;; 03:5513 $f6 $15
    ld   C, A                                          ;; 03:5515 $4f
    ld   A, [BC]                                       ;; 03:5516 $0a
    and  A, A                                          ;; 03:5517 $a7
    jp   NZ, jp_03_55fd                                ;; 03:5518 $c2 $fd $55
    ld   H, $d8                                        ;; 03:551b $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:551d $fa $00 $da
    or   A, $00                                        ;; 03:5520 $f6 $00
    ld   L, A                                          ;; 03:5522 $6f
    ld   L, [HL]                                       ;; 03:5523 $6e
    ld   H, $00                                        ;; 03:5524 $26 $00
    ld   DE, data_03_55ff                              ;; 03:5526 $11 $ff $55
    add  HL, DE                                        ;; 03:5529 $19
    ld   A, [HL]                                       ;; 03:552a $7e
    ld   [wDC58], A                                    ;; 03:552b $ea $58 $dc
    ld   HL, wD810_PlayerYPosition                                     ;; 03:552e $21 $10 $d8
    ld   A, [HL+]                                      ;; 03:5531 $2a
    ld   H, [HL]                                       ;; 03:5532 $66
    ld   L, A                                          ;; 03:5533 $6f
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:5534 $fa $01 $d8
    ld   DE, $00                                       ;; 03:5537 $11 $00 $00
    cp   A, $05                                        ;; 03:553a $fe $05
    jr   NZ, jr_03_5541                                ;; 03:553c $20 $03
    ld   DE, $08                                       ;; 03:553e $11 $08 $00

jr_03_5541:
    add  HL, DE                                        ;; 03:5541 $19
    ld   A, [wDC88]                                    ;; 03:5542 $fa $88 $dc
    ld   E, A                                          ;; 03:5545 $5f
    ld   D, $00                                        ;; 03:5546 $16 $00
    bit  7, A                                          ;; 03:5548 $cb $7f
    jr   Z, .jr_03_554d                                ;; 03:554a $28 $01
    dec  D                                             ;; 03:554c $15
.jr_03_554d:
    add  HL, DE                                        ;; 03:554d $19
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:554e $fa $00 $da
    or   A, $10                                        ;; 03:5551 $f6 $10
    ld   C, A                                          ;; 03:5553 $4f
    ld   A, [BC]                                       ;; 03:5554 $0a
    sub  A, L                                          ;; 03:5555 $95
    ld   E, A                                          ;; 03:5556 $5f
    inc  BC                                            ;; 03:5557 $03
    ld   A, [BC]                                       ;; 03:5558 $0a
    sbc  A, H                                          ;; 03:5559 $9c
    ld   D, A                                          ;; 03:555a $57
    ld   A, C                                          ;; 03:555b $79
    xor  A, $02                                        ;; 03:555c $ee $02
    ld   C, A                                          ;; 03:555e $4f
    ld   A, [BC]                                       ;; 03:555f $0a
    add  A, E                                          ;; 03:5560 $83
    ld   E, A                                          ;; 03:5561 $5f
    ld   A, $00                                        ;; 03:5562 $3e $00
    adc  A, D                                          ;; 03:5564 $8a
    jp   NZ, jp_03_55fd                                ;; 03:5565 $c2 $fd $55
    ld   A, [BC]                                       ;; 03:5568 $0a
    add  A, A                                          ;; 03:5569 $87
    cp   A, E                                          ;; 03:556a $bb
    jp   C, jp_03_55fd                                 ;; 03:556b $da $fd $55
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:556e $21 $0e $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5571 $fa $00 $da
    or   A, $0e                                        ;; 03:5574 $f6 $0e
    ld   C, A                                          ;; 03:5576 $4f
    ld   A, [BC]                                       ;; 03:5577 $0a
    sub  A, [HL]                                       ;; 03:5578 $96
    ld   E, A                                          ;; 03:5579 $5f
    inc  BC                                            ;; 03:557a $03
    inc  HL                                            ;; 03:557b $23
    ld   A, [BC]                                       ;; 03:557c $0a
    sbc  A, [HL]                                       ;; 03:557d $9e
    ld   D, A                                          ;; 03:557e $57
    ld   A, C                                          ;; 03:557f $79
    xor  A, $1d                                        ;; 03:5580 $ee $1d
    ld   C, A                                          ;; 03:5582 $4f
    ld   A, [BC]                                       ;; 03:5583 $0a
    add  A, $08                                        ;; 03:5584 $c6 $08
    add  A, E                                          ;; 03:5586 $83
    ld   E, A                                          ;; 03:5587 $5f
    ld   A, $00                                        ;; 03:5588 $3e $00
    adc  A, D                                          ;; 03:558a $8a
    jr   NZ, jp_03_55fd                                ;; 03:558b $20 $70
    ld   A, [BC]                                       ;; 03:558d $0a
    add  A, $08                                        ;; 03:558e $c6 $08
    add  A, A                                          ;; 03:5590 $87
    cp   A, E                                          ;; 03:5591 $bb
    jr   C, jp_03_55fd                                 ;; 03:5592 $38 $69
    ld   A, [wDC58]                                    ;; 03:5594 $fa $58 $dc
    bit  1, A                                          ;; 03:5597 $cb $4f
    jr   Z, .jr_03_55a9                                ;; 03:5599 $28 $0e
    ld   HL, wDC7F                                     ;; 03:559b $21 $7f $dc
    bit  0, [HL]                                       ;; 03:559e $cb $46
    jr   Z, .jr_03_55a9                                ;; 03:55a0 $28 $07
    ld   [HL], $00                                     ;; 03:55a2 $36 $00
    ld   A, $ff                                        ;; 03:55a4 $3e $ff
    add  A, $02                                        ;; 03:55a6 $c6 $02
    ret                                                ;; 03:55a8 $c9
.jr_03_55a9:
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:55a9 $21 $0e $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:55ac $fa $00 $da
    or   A, $0e                                        ;; 03:55af $f6 $0e
    ld   C, A                                          ;; 03:55b1 $4f
    ld   A, [BC]                                       ;; 03:55b2 $0a
    sub  A, [HL]                                       ;; 03:55b3 $96
    ld   E, A                                          ;; 03:55b4 $5f
    inc  BC                                            ;; 03:55b5 $03
    inc  HL                                            ;; 03:55b6 $23
    ld   A, [BC]                                       ;; 03:55b7 $0a
    sbc  A, [HL]                                       ;; 03:55b8 $9e
    ld   D, A                                          ;; 03:55b9 $57
    ld   A, C                                          ;; 03:55ba $79
    xor  A, $1d                                        ;; 03:55bb $ee $1d
    ld   C, A                                          ;; 03:55bd $4f
    ld   A, [BC]                                       ;; 03:55be $0a
    add  A, E                                          ;; 03:55bf $83
    ld   E, A                                          ;; 03:55c0 $5f
    ld   A, $00                                        ;; 03:55c1 $3e $00
    adc  A, D                                          ;; 03:55c3 $8a
    jr   NZ, jp_03_55fd                                ;; 03:55c4 $20 $37
    ld   A, [BC]                                       ;; 03:55c6 $0a
    add  A, A                                          ;; 03:55c7 $87
    cp   A, E                                          ;; 03:55c8 $bb
    jr   C, jp_03_55fd                                 ;; 03:55c9 $38 $32
    ld   A, [wDC58]                                    ;; 03:55cb $fa $58 $dc
    bit  2, A                                          ;; 03:55ce $cb $57
    jr   Z, .jr_03_55f3                                ;; 03:55d0 $28 $21
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:55d2 $fa $01 $d8
    cp   A, $0e                                        ;; 03:55d5 $fe $0e
    jr   Z, .jr_03_55e5                                ;; 03:55d7 $28 $0c
    cp   A, $0f                                        ;; 03:55d9 $fe $0f
    jr   Z, .jr_03_55e5                                ;; 03:55db $28 $08
    cp   A, $25                                        ;; 03:55dd $fe $25
    jr   Z, .jr_03_55e5                                ;; 03:55df $28 $04
    cp   A, $26                                        ;; 03:55e1 $fe $26
    jr   NZ, .jr_03_55f3                               ;; 03:55e3 $20 $0e
.jr_03_55e5:
    ld   HL, wDC8C                                     ;; 03:55e5 $21 $8c $dc
    bit  7, [HL]                                       ;; 03:55e8 $cb $7e
    jr   Z, .jr_03_55f3                                ;; 03:55ea $28 $07
    ld   [HL], $2a                                     ;; 03:55ec $36 $2a
    ld   A, $ff                                        ;; 03:55ee $3e $ff
    add  A, $03                                        ;; 03:55f0 $c6 $03
    ret                                                ;; 03:55f2 $c9
.jr_03_55f3:
    call call_00_0759                                  ;; 03:55f3 $cd $59 $07
    jr   NZ, jp_03_55fd                                ;; 03:55f6 $20 $05
    ld   A, $ff                                        ;; 03:55f8 $3e $ff
    add  A, $01                                        ;; 03:55fa $c6 $01
    ret                                                ;; 03:55fc $c9

jp_03_55fd:
    xor  A, A                                          ;; 03:55fd $af
    ret                                                ;; 03:55fe $c9

data_03_55ff:
    db   $00, $03, $03, $03, $03, $03, $03, $03        ;; 03:55ff ?...????
    db   $03, $02, $02, $02, $02, $02, $00, $00        ;; 03:5607 ????????
    db   $00, $01, $00, $00, $00, $00, $00, $00        ;; 03:560f ????????
    db   $00, $00, $00, $00, $02, $02, $01, $03        ;; 03:5617 ????..?.
    db   $03, $07, $07, $02, $01, $03, $03, $01        ;; 03:561f ..??????
    db   $03, $01, $03, $04, $00, $00, $03, $00        ;; 03:5627 ????????
    db   $05, $05, $01, $01, $02, $01, $01, $00        ;; 03:562f ????????
    db   $02, $03, $01, $00, $03, $06, $03, $00        ;; 03:5637 ????????
    db   $01, $01, $00, $03, $03, $00, $02, $02        ;; 03:563f ????????
    db   $01, $00, $02, $02, $03, $03, $05, $03        ;; 03:5647 ????????
    db   $01, $00, $00, $01, $04, $00, $03, $00        ;; 03:564f ????????
    db   $03, $03, $03, $07, $03, $03, $03, $00        ;; 03:5657 ????????
    db   $01, $03, $02, $02, $01, $01, $03, $01        ;; 03:565f ????????
    db   $00, $02, $01, $00, $00, $00, $03, $01        ;; 03:5667 ????????
    db   $01, $01                                      ;; 03:566f ??

entry_03_5671:
call_03_5671:
    ld   H, $d8                                        ;; 03:5671 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5673 $fa $00 $da
    or   A, $15                                        ;; 03:5676 $f6 $15
    ld   L, A                                          ;; 03:5678 $6f
    ld   A, [HL]                                       ;; 03:5679 $7e
    and  A, A                                          ;; 03:567a $a7
    ret  NZ                                            ;; 03:567b $c0
    inc  L                                             ;; 03:567c $2c
    ld   A, [HL]                                       ;; 03:567d $7e
    cp   A, $ff                                        ;; 03:567e $fe $ff
    ret  Z                                             ;; 03:5680 $c8
    and  A, A                                          ;; 03:5681 $a7
    ret  Z                                             ;; 03:5682 $c8
    sub  A, $01                                        ;; 03:5683 $d6 $01
    jr   Z, .jr_03_5689                                ;; 03:5685 $28 $02
    jr   NC, .jr_03_56b8                               ;; 03:5687 $30 $2f
.jr_03_5689:
    ld   [HL], $00                                     ;; 03:5689 $36 $00
    call call_00_35e8_GetObjectTypeIndex                                  ;; 03:568b $cd $e8 $35
    cp   A, $ff                                        ;; 03:568e $fe $ff
    jp   Z, call_00_2b7a_ClearObjectThenJump                                 ;; 03:5690 $ca $7a $2b
    bit  7, A                                          ;; 03:5693 $cb $7f
    jr   Z, .jr_03_56a6                                ;; 03:5695 $28 $0f
    push AF                                            ;; 03:5697 $f5
    ld   C, $00                                        ;; 03:5698 $0e $00
    call call_00_288c_Object_Set14                                  ;; 03:569a $cd $8c $28
    ld   C, $00                                        ;; 03:569d $0e $00
    call call_00_2958_ObjectSetFacingDirection                                  ;; 03:569f $cd $58 $29
    call call_00_2c67_Particle_InitBurst                                  ;; 03:56a2 $cd $67 $2c
    pop  AF                                            ;; 03:56a5 $f1
.jr_03_56a6:
    and  A, $3f                                        ;; 03:56a6 $e6 $3f
    ld   [wDAD6_ReturnBank], A                                    ;; 03:56a8 $ea $d6 $da
    ld   A, $02                                        ;; 03:56ab $3e $02
    ld   HL, entry_02_72ac_LoadObjectData                              ;; 03:56ad $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 03:56b0 $cd $dd $0e
    ld   A, $10                                        ;; 03:56b3 $3e $10
    jp   call_00_0ff5_MaybeQueueBankChange                                  ;; 03:56b5 $c3 $f5 $0f
.jr_03_56b8:
    ld   [HL], A                                       ;; 03:56b8 $77
    dec  L                                             ;; 03:56b9 $2d
    ld   [HL], $3c                                     ;; 03:56ba $36 $3c
    ld   A, $0f                                        ;; 03:56bc $3e $0f
    jp   call_00_0ff5_MaybeQueueBankChange                                  ;; 03:56be $c3 $f5 $0f
    db   $fa, $01, $d8, $fe, $1a, $ca, $f8, $57        ;; 03:56c1 ????????
    db   $fe, $2e, $ca, $f8, $57, $fe, $3b, $ca        ;; 03:56c9 ????????
    db   $f8, $57, $fe, $1b, $ca, $f8, $57, $fa        ;; 03:56d1 ????????
    db   $88, $dc, $5f, $16, $00, $cb, $7f, $28        ;; 03:56d9 ????????
    db   $01, $15, $fa, $10, $d8, $83, $5f, $fa        ;; 03:56e1 ????????
    db   $11, $d8, $8a, $57, $26, $d8, $fa, $00        ;; 03:56e9 ????????
    db   $da, $f6, $10, $6f, $7b, $96, $5f, $23        ;; 03:56f1 ????????
    db   $7a, $9e, $57, $38, $0f, $a7, $c2, $f8        ;; 03:56f9 ????????
    db   $57, $2c, $2c, $3a, $c6, $0f, $bb, $da        ;; 03:5701 ????????
    db   $f8, $57, $18, $12, $af, $93, $5f, $3e        ;; 03:5709 ????????
    db   $00, $9a, $a7, $c2, $f8, $57, $2c, $2c        ;; 03:5711 ????????
    db   $3a, $c6, $0f, $bb, $38, $5d, $4e, $7d        ;; 03:5719 ????????
    db   $ee, $1c, $6f, $fa, $0e, $d8, $96, $5f        ;; 03:5721 ????????
    db   $23, $fa, $0f, $d8, $9e, $57, $7b, $81        ;; 03:5729 ????????
    db   $5f, $7a, $ce, $00, $cb, $7f, $20, $24        ;; 03:5731 ????????
    db   $a7, $c2, $f8, $57, $7b, $cb, $21, $91        ;; 03:5739 ????????
    db   $da, $f8, $57, $fe, $08, $d2, $f8, $57        ;; 03:5741 ????????
    db   $4f, $cd, $a9, $58, $79, $90, $83, $82        ;; 03:5749 ????????
    db   $cb, $7f, $c2, $0b, $58, $a7, $ca, $0b        ;; 03:5751 ????????
    db   $58, $c3, $f8, $57, $14, $c2, $f8, $57        ;; 03:5759 ????????
    db   $7b, $2f, $fe, $08, $d2, $f8, $57, $4f        ;; 03:5761 ????????
    db   $cd, $a9, $58, $79, $80, $93, $92, $cb        ;; 03:5769 ????????
    db   $7f, $c2, $0b, $58, $a7, $ca, $0b, $58        ;; 03:5771 ????????
    db   $c3, $f8, $57, $2a, $4f, $46, $7d, $ee        ;; 03:5779 ????????
    db   $1d, $6f, $fa, $0e, $d8, $96, $5f, $23        ;; 03:5781 ????????
    db   $fa, $0f, $d8, $9e, $57, $7b, $81, $5f        ;; 03:5789 ????????
    db   $3e, $00, $8a, $20, $62, $79, $87, $bb        ;; 03:5791 ????????
    db   $38, $5d, $2c, $2a, $90, $4f, $7e, $de        ;; 03:5799 ????????
    db   $00, $47, $fa, $88, $dc, $5f, $16, $00        ;; 03:57a1 ????????
    db   $cb, $7f, $28, $01, $15, $fa, $10, $d8        ;; 03:57a9 ????????
    db   $83, $5f, $fa, $11, $d8, $8a, $57, $7b        ;; 03:57b1 ????????
    db   $c6, $10, $5f, $7a, $ce, $00, $57, $79        ;; 03:57b9 ????????
    db   $93, $4f, $78, $9a, $47, $38, $30, $20        ;; 03:57c1 ????????
    db   $2e, $79, $fe, $10, $30, $29, $fa, $8c        ;; 03:57c9 ????????
    db   $dc, $cb, $2f, $cb, $2f, $cb, $2f, $cb        ;; 03:57d1 ????????
    db   $2f, $81, $3d, $cb, $7f, $20, $06, $fe        ;; 03:57d9 ????????
    db   $02, $38, $02, $18, $12                       ;; 03:57e1 ?????

jp_03_57e6:
    xor  A, A                                          ;; 03:57e6 $af
    ld   [wDC88], A                                    ;; 03:57e7 $ea $88 $dc
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:57ea $fa $00 $da
    ld   [wDC7B], A                                    ;; 03:57ed $ea $7b $dc
    ld   HL, wDC7D                                     ;; 03:57f0 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:57f3 $be
    ret  NZ                                            ;; 03:57f4 $c0
    ld   [HL], $00                                     ;; 03:57f5 $36 $00
    ret                                                ;; 03:57f7 $c9

entry_03_57f8:
call_03_57f8:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:57f8 $fa $00 $da
    ld   HL, wDC7B                                     ;; 03:57fb $21 $7b $dc
    cp   A, [HL]                                       ;; 03:57fe $be
    jr   NZ, .jr_03_5803                               ;; 03:57ff $20 $02
    ld   [HL], $00                                     ;; 03:5801 $36 $00
.jr_03_5803:
    ld   HL, wDC7D                                     ;; 03:5803 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:5806 $be
    ret  NZ                                            ;; 03:5807 $c0
    ld   [HL], $00                                     ;; 03:5808 $36 $00
    ret                                                ;; 03:580a $c9
    db   $fa, $00, $da, $21, $7b, $dc, $be, $20        ;; 03:580b ????????
    db   $02, $36, $00, $ea, $7d, $dc, $c9             ;; 03:5813 ???????

data_03_581a:
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:581a $fa $01 $d8
    cp   A, $1a                                        ;; 03:581d $fe $1a
    jp   Z, call_03_57f8                                 ;; 03:581f $ca $f8 $57
    cp   A, $2e                                        ;; 03:5822 $fe $2e
    jp   Z, call_03_57f8                                 ;; 03:5824 $ca $f8 $57
    cp   A, $3b                                        ;; 03:5827 $fe $3b
    jp   Z, call_03_57f8                                 ;; 03:5829 $ca $f8 $57
    cp   A, $1b                                        ;; 03:582c $fe $1b
    jp   Z, call_03_57f8                                 ;; 03:582e $ca $f8 $57
    ld   H, $d8                                        ;; 03:5831 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5833 $fa $00 $da
    or   A, $12                                        ;; 03:5836 $f6 $12
    ld   L, A                                          ;; 03:5838 $6f
    ld   A, [HL+]                                      ;; 03:5839 $2a
    ld   C, A                                          ;; 03:583a $4f
    ld   B, [HL]                                       ;; 03:583b $46
    ld   A, L                                          ;; 03:583c $7d
    xor  A, $1d                                        ;; 03:583d $ee $1d
    ld   L, A                                          ;; 03:583f $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:5840 $fa $0e $d8
    sub  A, [HL]                                       ;; 03:5843 $96
    ld   E, A                                          ;; 03:5844 $5f
    inc  HL                                            ;; 03:5845 $23
    ld   A, [wD80F_PlayerXPosition]                                    ;; 03:5846 $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:5849 $9e
    ld   D, A                                          ;; 03:584a $57
    ld   A, E                                          ;; 03:584b $7b
    add  A, C                                          ;; 03:584c $81
    ld   E, A                                          ;; 03:584d $5f
    ld   A, $00                                        ;; 03:584e $3e $00
    adc  A, D                                          ;; 03:5850 $8a
    jr   NZ, call_03_57f8                                ;; 03:5851 $20 $a5
    ld   A, C                                          ;; 03:5853 $79
    add  A, A                                          ;; 03:5854 $87
    cp   A, E                                          ;; 03:5855 $bb
    jr   C, call_03_57f8                                 ;; 03:5856 $38 $a0
    inc  L                                             ;; 03:5858 $2c
    ld   A, [HL+]                                      ;; 03:5859 $2a
    sub  A, B                                          ;; 03:585a $90
    ld   C, A                                          ;; 03:585b $4f
    ld   A, [HL]                                       ;; 03:585c $7e
    sbc  A, $00                                        ;; 03:585d $de $00
    ld   B, A                                          ;; 03:585f $47
    ld   A, [wDC88]                                    ;; 03:5860 $fa $88 $dc
    ld   E, A                                          ;; 03:5863 $5f
    ld   D, $00                                        ;; 03:5864 $16 $00
    bit  7, A                                          ;; 03:5866 $cb $7f
    jr   Z, .jr_03_586b                                ;; 03:5868 $28 $01
    dec  D                                             ;; 03:586a $15
.jr_03_586b:
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:586b $fa $10 $d8
    add  A, E                                          ;; 03:586e $83
    ld   E, A                                          ;; 03:586f $5f
    ld   A, [wD811_PlayerYPosition]                                    ;; 03:5870 $fa $11 $d8
    adc  A, D                                          ;; 03:5873 $8a
    ld   D, A                                          ;; 03:5874 $57
    ld   A, E                                          ;; 03:5875 $7b
    add  A, $10                                        ;; 03:5876 $c6 $10
    ld   E, A                                          ;; 03:5878 $5f
    ld   A, D                                          ;; 03:5879 $7a
    adc  A, $00                                        ;; 03:587a $ce $00
    ld   D, A                                          ;; 03:587c $57
    ld   A, C                                          ;; 03:587d $79
    sub  A, E                                          ;; 03:587e $93
    ld   C, A                                          ;; 03:587f $4f
    ld   A, B                                          ;; 03:5880 $78
    sbc  A, D                                          ;; 03:5881 $9a
    ld   B, A                                          ;; 03:5882 $47
    jp   C, call_03_57f8                                 ;; 03:5883 $da $f8 $57
    jp   NZ, call_03_57f8                                ;; 03:5886 $c2 $f8 $57
    ld   A, C                                          ;; 03:5889 $79
    cp   A, $10                                        ;; 03:588a $fe $10
    jp   NC, call_03_57f8                                ;; 03:588c $d2 $f8 $57
    ld   A, [wDC8C]                                    ;; 03:588f $fa $8c $dc
    sra  A                                             ;; 03:5892 $cb $2f
    sra  A                                             ;; 03:5894 $cb $2f
    sra  A                                             ;; 03:5896 $cb $2f
    sra  A                                             ;; 03:5898 $cb $2f
    add  A, C                                          ;; 03:589a $81
    dec  A                                             ;; 03:589b $3d
    bit  7, A                                          ;; 03:589c $cb $7f
    jp   NZ, jp_03_57e6                                ;; 03:589e $c2 $e6 $57
    cp   A, $02                                        ;; 03:58a1 $fe $02
    jp   C, jp_03_57e6                                 ;; 03:58a3 $da $e6 $57
    jp   call_03_57f8                                    ;; 03:58a6 $c3 $f8 $57
    db   $26, $d8, $fa, $00, $da, $f6, $1b, $6f        ;; 03:58a9 ????????
    db   $46, $2d, $2d, $cb, $7e, $28, $03, $af        ;; 03:58b1 ????????
    db   $90, $47, $fa, $84, $dc, $57, $fa, $85        ;; 03:58b9 ????????
    db   $dc, $82, $57, $fa, $86, $dc, $5f, $21        ;; 03:58c1 ????????
    db   $0d, $d8, $cb, $6e, $c8, $2f, $3c, $5f        ;; 03:58c9 ????????
    db   $c9                                           ;; 03:58d1 ?
