entry_03_4bb6:
call_03_4bb6:
    ld   A, [wD810]                                    ;; 03:4bb6 $fa $10 $d8
    sub  A, $10                                        ;; 03:4bb9 $d6 $10
    and  A, $f8                                        ;; 03:4bbb $e6 $f8
    ld   L, A                                          ;; 03:4bbd $6f
    ld   H, $30                                        ;; 03:4bbe $26 $30
    add  HL, HL                                        ;; 03:4bc0 $29
    add  HL, HL                                        ;; 03:4bc1 $29
    ld   A, [wD80E]                                    ;; 03:4bc2 $fa $0e $d8
    rrca                                               ;; 03:4bc5 $0f
    rrca                                               ;; 03:4bc6 $0f
    rrca                                               ;; 03:4bc7 $0f
    and  A, $1f                                        ;; 03:4bc8 $e6 $1f
    or   A, L                                          ;; 03:4bca $b5
    ld   L, A                                          ;; 03:4bcb $6f
    ld   A, [HL]                                       ;; 03:4bcc $7e
    ld   [wDC97], A                                    ;; 03:4bcd $ea $97 $dc
    ld   DE, $40                                       ;; 03:4bd0 $11 $40 $00
    add  HL, DE                                        ;; 03:4bd3 $19
    res  2, H                                          ;; 03:4bd4 $cb $94
    ld   A, [HL]                                       ;; 03:4bd6 $7e
    ld   [wDC92], A                                    ;; 03:4bd7 $ea $92 $dc
    ld   DE, $20                                       ;; 03:4bda $11 $20 $00
    add  HL, DE                                        ;; 03:4bdd $19
    res  2, H                                          ;; 03:4bde $cb $94
    ld   A, [HL]                                       ;; 03:4be0 $7e
    ld   [wDC93], A                                    ;; 03:4be1 $ea $93 $dc
    add  HL, DE                                        ;; 03:4be4 $19
    res  2, H                                          ;; 03:4be5 $cb $94
    ld   A, [HL]                                       ;; 03:4be7 $7e
    ld   [wDC95], A                                    ;; 03:4be8 $ea $95 $dc
    ld   C, $09                                        ;; 03:4beb $0e $09
    ld   A, [wD80D]                                    ;; 03:4bed $fa $0d $d8
    cp   A, $00                                        ;; 03:4bf0 $fe $00
    jr   Z, .jr_03_4bf6                                ;; 03:4bf2 $28 $02
    ld   C, $f7                                        ;; 03:4bf4 $0e $f7
.jr_03_4bf6:
    ld   A, [wD810]                                    ;; 03:4bf6 $fa $10 $d8
    sub  A, $08                                        ;; 03:4bf9 $d6 $08
    and  A, $f8                                        ;; 03:4bfb $e6 $f8
    ld   L, A                                          ;; 03:4bfd $6f
    ld   H, $30                                        ;; 03:4bfe $26 $30
    add  HL, HL                                        ;; 03:4c00 $29
    add  HL, HL                                        ;; 03:4c01 $29
    ld   A, [wD80E]                                    ;; 03:4c02 $fa $0e $d8
    add  A, C                                          ;; 03:4c05 $81
    rrca                                               ;; 03:4c06 $0f
    rrca                                               ;; 03:4c07 $0f
    rrca                                               ;; 03:4c08 $0f
    and  A, $1f                                        ;; 03:4c09 $e6 $1f
    or   A, L                                          ;; 03:4c0b $b5
    ld   L, A                                          ;; 03:4c0c $6f
    ld   A, [HL]                                       ;; 03:4c0d $7e
    ld   [wDC94], A                                    ;; 03:4c0e $ea $94 $dc
    ret                                                ;; 03:4c11 $c9

call_03_4c12:
    ld   A, [wD810]                                    ;; 03:4c12 $fa $10 $d8
    add  A, B                                          ;; 03:4c15 $80
    and  A, $f8                                        ;; 03:4c16 $e6 $f8
    ld   L, A                                          ;; 03:4c18 $6f
    ld   H, $30                                        ;; 03:4c19 $26 $30
    add  HL, HL                                        ;; 03:4c1b $29
    add  HL, HL                                        ;; 03:4c1c $29
    ld   A, [wD80E]                                    ;; 03:4c1d $fa $0e $d8
    add  A, C                                          ;; 03:4c20 $81
    rrca                                               ;; 03:4c21 $0f
    rrca                                               ;; 03:4c22 $0f
    rrca                                               ;; 03:4c23 $0f
    and  A, $1f                                        ;; 03:4c24 $e6 $1f
    or   A, L                                          ;; 03:4c26 $b5
    ld   L, A                                          ;; 03:4c27 $6f
    ld   C, [HL]                                       ;; 03:4c28 $4e
    ld   B, $40                                        ;; 03:4c29 $06 $40
    ld   A, [BC]                                       ;; 03:4c2b $0a
    ld   B, A                                          ;; 03:4c2c $47
    ret                                                ;; 03:4c2d $c9

entry_03_4c2e:
    ld   BC, $00                                       ;; 03:4c2e $01 $00 $00
    call call_03_4c12                                  ;; 03:4c31 $cd $12 $4c
    ld   A, C                                          ;; 03:4c34 $79
    cp   A, $3d                                        ;; 03:4c35 $fe $3d
    ret                                                ;; 03:4c37 $c9
    