entry_03_46e0_UpdateBgCollision:
call_03_46e0_UpdateBgCollision:
    ld   [wDAD6_ReturnBank], A                                    ;; 03:46e0 $ea $d6 $da
    ld   A, $02                                        ;; 03:46e3 $3e $02
    ld   HL, entry_02_5541                                ;; 03:46e5 $21 $41 $55
    call call_00_0edd_CallAltBankFunc                                  ;; 03:46e8 $cd $dd $0e
    bit  5, A                                          ;; 03:46eb $cb $6f
    jp   NZ, call_03_4a3f                               ;; 03:46ed $c2 $3f $4a
    bit  7, A                                          ;; 03:46f0 $cb $7f
    jp   NZ, call_03_4ae4                               ;; 03:46f2 $c2 $e4 $4a
    ld   HL, wDC1F                                     ;; 03:46f5 $21 $1f $dc
    ld   L, [HL]                                       ;; 03:46f8 $6e
    ld   H, $00                                        ;; 03:46f9 $26 $00
    add  HL, HL                                        ;; 03:46fb $29
    ld   DE, .data_03_4704                             ;; 03:46fc $11 $04 $47
    add  HL, DE                                        ;; 03:46ff $19
    ld   A, [HL+]                                      ;; 03:4700 $2a
    ld   H, [HL]                                       ;; 03:4701 $66
    ld   L, A                                          ;; 03:4702 $6f
    jp   HL                                            ;; 03:4703 $e9
.data_03_4704:
    dw   call_03_4708_ProcessSidescrollCollision                                 ;; 03:4704 pP
    dw   call_03_48ad_ProcessTopDownCollision                                      ;; 03:4706 ..

call_03_4708_ProcessSidescrollCollision:
    ld   HL, wDABE                                     ;; 03:4708 $21 $be $da
    ld   A, [HL]                                       ;; 03:470b $7e
    ld   [HL], $00                                     ;; 03:470c $36 $00
    ld   [wDABD], A                                    ;; 03:470e $ea $bd $da
    ld   A, [wDC7B]                                    ;; 03:4711 $fa $7b $dc
    and  A, A                                          ;; 03:4714 $a7
    jr   Z, .jr_03_471c                                ;; 03:4715 $28 $05
    ld   HL, wDABE                                     ;; 03:4717 $21 $be $da
    set  7, [HL]                                       ;; 03:471a $cb $fe
.jr_03_471c:
    ld   A, [wDC8C]                                    ;; 03:471c $fa $8c $dc
    sub  A, $02                                        ;; 03:471f $d6 $02
    bit  7, A                                          ;; 03:4721 $cb $7f
    jr   Z, .jr_03_472b                                ;; 03:4723 $28 $06
    cp   A, $c0                                        ;; 03:4725 $fe $c0
    jr   NC, .jr_03_472b                               ;; 03:4727 $30 $02
    ld   A, $c0                                        ;; 03:4729 $3e $c0
.jr_03_472b:
    sra  A                                             ;; 03:472b $cb $2f
    sra  A                                             ;; 03:472d $cb $2f
    sra  A                                             ;; 03:472f $cb $2f
    sra  A                                             ;; 03:4731 $cb $2f
    ld   [wDC8B], A                                    ;; 03:4733 $ea $8b $dc
    call call_03_4b37                                  ;; 03:4736 $cd $37 $4b
    jp   Z, .jp_03_47f6                                ;; 03:4739 $ca $f6 $47
    ld   E, A                                          ;; 03:473c $5f
    bit  7, E                                          ;; 03:473d $cb $7b
    jr   Z, .jr_03_474b                                ;; 03:473f $28 $0a
    ld   A, [wD80E]                                    ;; 03:4741 $fa $0e $d8
    and  A, $07                                        ;; 03:4744 $e6 $07
    add  A, E                                          ;; 03:4746 $83
    ld   C, $ff                                        ;; 03:4747 $0e $ff
    jr   .jr_03_4753                                   ;; 03:4749 $18 $08
.jr_03_474b:
    ld   A, [wD80E]                                    ;; 03:474b $fa $0e $d8
    and  A, $07                                        ;; 03:474e $e6 $07
    add  A, E                                          ;; 03:4750 $83
    ld   C, $01                                        ;; 03:4751 $0e $01
.jr_03_4753:
    push DE                                            ;; 03:4753 $d5
    ld   A, E                                          ;; 03:4754 $7b
    ld   HL, wD80E                                     ;; 03:4755 $21 $0e $d8
    add  A, [HL]                                       ;; 03:4758 $86
    add  A, C                                          ;; 03:4759 $81
    ld   C, A                                          ;; 03:475a $4f
    ld   A, [wD810]                                    ;; 03:475b $fa $10 $d8
    sub  A, $09                                        ;; 03:475e $d6 $09
    ld   HL, wDC8B                                     ;; 03:4760 $21 $8b $dc
    and  A, $f8                                        ;; 03:4763 $e6 $f8
    ld   L, A                                          ;; 03:4765 $6f
    ld   H, $30                                        ;; 03:4766 $26 $30
    add  HL, HL                                        ;; 03:4768 $29
    add  HL, HL                                        ;; 03:4769 $29
    ld   A, C                                          ;; 03:476a $79
    rrca                                               ;; 03:476b $0f
    rrca                                               ;; 03:476c $0f
    rrca                                               ;; 03:476d $0f
    and  A, $1f                                        ;; 03:476e $e6 $1f
    or   A, L                                          ;; 03:4770 $b5
    ld   L, A                                          ;; 03:4771 $6f
    ld   D, $40                                        ;; 03:4772 $16 $40
    ld   C, $00                                        ;; 03:4774 $0e $00
    ld   B, $04                                        ;; 03:4776 $06 $04
.jr_03_4778:
    ld   E, [HL]                                       ;; 03:4778 $5e
    ld   A, [DE]                                       ;; 03:4779 $1a
    or   A, C                                          ;; 03:477a $b1
    ld   C, A                                          ;; 03:477b $4f
    ld   A, L                                          ;; 03:477c $7d
    add  A, $20                                        ;; 03:477d $c6 $20
    ld   L, A                                          ;; 03:477f $6f
    ld   A, H                                          ;; 03:4780 $7c
    adc  A, $00                                        ;; 03:4781 $ce $00
    res  2, A                                          ;; 03:4783 $cb $97
    ld   H, A                                          ;; 03:4785 $67
    dec  B                                             ;; 03:4786 $05
    jr   NZ, .jr_03_4778                               ;; 03:4787 $20 $ef
    pop  DE                                            ;; 03:4789 $d1
    bit  0, C                                          ;; 03:478a $cb $41
    jr   Z, .jr_03_47b0                                ;; 03:478c $28 $22
    ld   HL, wD80E                                     ;; 03:478e $21 $0e $d8
    bit  7, E                                          ;; 03:4791 $cb $7b
    jr   NZ, .jr_03_479c                               ;; 03:4793 $20 $07
    ld   A, $07                                        ;; 03:4795 $3e $07
    sub  A, [HL]                                       ;; 03:4797 $96
    and  A, $07                                        ;; 03:4798 $e6 $07
    jr   .jr_03_47a1                                   ;; 03:479a $18 $05
.jr_03_479c:
    ld   A, [HL]                                       ;; 03:479c $7e
    and  A, $07                                        ;; 03:479d $e6 $07
    cpl                                                ;; 03:479f $2f
    inc  A                                             ;; 03:47a0 $3c
.jr_03_47a1:
    xor  A, A                                          ;; 03:47a1 $af
    ld   [wDC86], A                                    ;; 03:47a2 $ea $86 $dc
    ld   [wDC85], A                                    ;; 03:47a5 $ea $85 $dc
    ld   [wDC84], A                                    ;; 03:47a8 $ea $84 $dc
    ld   HL, wDABE                                     ;; 03:47ab $21 $be $da
    set  6, [HL]                                       ;; 03:47ae $cb $f6
.jr_03_47b0:
    ld   HL, wDABE                                     ;; 03:47b0 $21 $be $da
    bit  7, [HL]                                       ;; 03:47b3 $cb $7e
    jr   NZ, .jp_03_47f6                               ;; 03:47b5 $20 $3f
    call call_03_4b37                                  ;; 03:47b7 $cd $37 $4b
    jr   Z, .jp_03_47f6                                ;; 03:47ba $28 $3a
    bit  7, A                                          ;; 03:47bc $cb $7f
    jr   NZ, .jr_03_47d5                               ;; 03:47be $20 $15
    ld   B, $00                                        ;; 03:47c0 $06 $00
    ld   C, $01                                        ;; 03:47c2 $0e $01
.jr_03_47c4:
    push AF                                            ;; 03:47c4 $f5
    push BC                                            ;; 03:47c5 $c5
    call call_03_4b4c                                  ;; 03:47c6 $cd $4c $4b
    pop  BC                                            ;; 03:47c9 $c1
    and  A, A                                          ;; 03:47ca $a7
    jr   Z, .jr_03_47ce                                ;; 03:47cb $28 $01
    dec  B                                             ;; 03:47cd $05
.jr_03_47ce:
    inc  C                                             ;; 03:47ce $0c
    pop  AF                                            ;; 03:47cf $f1
    dec  A                                             ;; 03:47d0 $3d
    jr   NZ, .jr_03_47c4                               ;; 03:47d1 $20 $f1
    jr   .jr_03_47e8                                   ;; 03:47d3 $18 $13
.jr_03_47d5:
    ld   B, $00                                        ;; 03:47d5 $06 $00
    ld   C, $ff                                        ;; 03:47d7 $0e $ff
.jr_03_47d9:
    push AF                                            ;; 03:47d9 $f5
    push BC                                            ;; 03:47da $c5
    call call_03_4b4c                                  ;; 03:47db $cd $4c $4b
    pop  BC                                            ;; 03:47de $c1
    and  A, A                                          ;; 03:47df $a7
    jr   Z, .jr_03_47e3                                ;; 03:47e0 $28 $01
    dec  B                                             ;; 03:47e2 $05
.jr_03_47e3:
    dec  C                                             ;; 03:47e3 $0d
    pop  AF                                            ;; 03:47e4 $f1
    inc  A                                             ;; 03:47e5 $3c
    jr   NZ, .jr_03_47d9                               ;; 03:47e6 $20 $f1
.jr_03_47e8:
    ld   A, B                                          ;; 03:47e8 $78
    cpl                                                ;; 03:47e9 $2f
    inc  A                                             ;; 03:47ea $3c
    ld   HL, wDABE                                     ;; 03:47eb $21 $be $da
    or   A, [HL]                                       ;; 03:47ee $b6
    ld   [HL], A                                       ;; 03:47ef $77
    and  A, $0f                                        ;; 03:47f0 $e6 $0f
    jr   Z, .jp_03_47f6                                ;; 03:47f2 $28 $02
    set  7, [HL]                                       ;; 03:47f4 $cb $fe
.jp_03_47f6:
    xor  A, A                                          ;; 03:47f6 $af
    ld   [wDC8D], A                                    ;; 03:47f7 $ea $8d $dc
    ld   HL, wDABE                                     ;; 03:47fa $21 $be $da
    bit  7, [HL]                                       ;; 03:47fd $cb $7e
    ret  NZ                                            ;; 03:47ff $c0
    ld   A, [wDC8C]                                    ;; 03:4800 $fa $8c $dc
    and  A, A                                          ;; 03:4803 $a7
    jr   Z, .jr_03_480a                                ;; 03:4804 $28 $04
    bit  7, A                                          ;; 03:4806 $cb $7f
    jr   Z, .jr_03_4876                                ;; 03:4808 $28 $6c
.jr_03_480a:
    ld   A, [wD801]                                    ;; 03:480a $fa $01 $d8
    cp   A, $1b                                        ;; 03:480d $fe $1b
    ld   A, $04                                        ;; 03:480f $3e $04
    jr   Z, .jr_03_486e                                ;; 03:4811 $28 $5b
    ld   B, $00                                        ;; 03:4813 $06 $00
    call call_03_4b37                                  ;; 03:4815 $cd $37 $4b
    ld   C, A                                          ;; 03:4818 $4f
    ld   A, [wD810]                                    ;; 03:4819 $fa $10 $d8
    add  A, $10                                        ;; 03:481c $c6 $10
    add  A, B                                          ;; 03:481e $80
    ld   B, A                                          ;; 03:481f $47
    and  A, $f8                                        ;; 03:4820 $e6 $f8
    ld   L, A                                          ;; 03:4822 $6f
    ld   H, $30                                        ;; 03:4823 $26 $30
    add  HL, HL                                        ;; 03:4825 $29
    add  HL, HL                                        ;; 03:4826 $29
    ld   A, [wD80E]                                    ;; 03:4827 $fa $0e $d8
    add  A, C                                          ;; 03:482a $81
    ld   C, A                                          ;; 03:482b $4f
    rrca                                               ;; 03:482c $0f
    rrca                                               ;; 03:482d $0f
    rrca                                               ;; 03:482e $0f
    and  A, $1f                                        ;; 03:482f $e6 $1f
    or   A, L                                          ;; 03:4831 $b5
    ld   L, A                                          ;; 03:4832 $6f
    ld   A, [HL]                                       ;; 03:4833 $7e
    ld   DE, $20                                       ;; 03:4834 $11 $20 $00
    add  HL, DE                                        ;; 03:4837 $19
    res  2, H                                          ;; 03:4838 $cb $94
    ld   E, A                                          ;; 03:483a $5f
    ld   D, [HL]                                       ;; 03:483b $56
    ld   A, C                                          ;; 03:483c $79
    and  A, $07                                        ;; 03:483d $e6 $07
    add  A, $a5                                        ;; 03:483f $c6 $a5
    ld   L, A                                          ;; 03:4841 $6f
    ld   A, $00                                        ;; 03:4842 $3e $00
    adc  A, $48                                        ;; 03:4844 $ce $48
    ld   H, A                                          ;; 03:4846 $67
    ld   C, [HL]                                       ;; 03:4847 $4e
    ld   A, B                                          ;; 03:4848 $78
    and  A, $07                                        ;; 03:4849 $e6 $07
    add  A, $c4                                        ;; 03:484b $c6 $c4
    ld   H, A                                          ;; 03:484d $67
    ld   L, E                                          ;; 03:484e $6b
    ld   B, $00                                        ;; 03:484f $06 $00
.jr_03_4851:
    ld   A, [HL]                                       ;; 03:4851 $7e
    and  A, C                                          ;; 03:4852 $a1
    jr   NZ, .jr_03_4868                               ;; 03:4853 $20 $13
    inc  H                                             ;; 03:4855 $24
    ld   A, H                                          ;; 03:4856 $7c
    cp   A, $cc                                        ;; 03:4857 $fe $cc
    jr   NZ, .jr_03_485e                               ;; 03:4859 $20 $03
    ld   H, $c4                                        ;; 03:485b $26 $c4
    ld   L, D                                          ;; 03:485d $6a
.jr_03_485e:
    inc  B                                             ;; 03:485e $04
    ld   A, B                                          ;; 03:485f $78
    cp   A, $05                                        ;; 03:4860 $fe $05
    jr   NZ, .jr_03_4851                               ;; 03:4862 $20 $ed
    ld   A, $04                                        ;; 03:4864 $3e $04
    jr   .jr_03_486e                                   ;; 03:4866 $18 $06
.jr_03_4868:
    ld   HL, wDABE                                     ;; 03:4868 $21 $be $da
    set  7, [HL]                                       ;; 03:486b $cb $fe
    ld   A, B                                          ;; 03:486d $78
.jr_03_486e:
    swap A                                             ;; 03:486e $cb $37
    cpl                                                ;; 03:4870 $2f
    inc  A                                             ;; 03:4871 $3c
    ld   [wDC8D], A                                    ;; 03:4872 $ea $8d $dc
    ret                                                ;; 03:4875 $c9
.jr_03_4876:
    call call_03_4b37                                  ;; 03:4876 $cd $37 $4b
    ld   C, A                                          ;; 03:4879 $4f
    ld   A, [wDC8C]                                    ;; 03:487a $fa $8c $dc
    swap A                                             ;; 03:487d $cb $37
    and  A, $0f                                        ;; 03:487f $e6 $0f
    add  A, $11                                        ;; 03:4881 $c6 $11
    ld   B, A                                          ;; 03:4883 $47
    ld   A, [wD810]                                    ;; 03:4884 $fa $10 $d8
    sub  A, B                                          ;; 03:4887 $90
    and  A, $f8                                        ;; 03:4888 $e6 $f8
    ld   L, A                                          ;; 03:488a $6f
    ld   H, $30                                        ;; 03:488b $26 $30
    add  HL, HL                                        ;; 03:488d $29
    add  HL, HL                                        ;; 03:488e $29
    ld   A, [wD80E]                                    ;; 03:488f $fa $0e $d8
    add  A, C                                          ;; 03:4892 $81
    rrca                                               ;; 03:4893 $0f
    rrca                                               ;; 03:4894 $0f
    rrca                                               ;; 03:4895 $0f
    and  A, $1f                                        ;; 03:4896 $e6 $1f
    or   A, L                                          ;; 03:4898 $b5
    ld   L, A                                          ;; 03:4899 $6f
    ld   L, [HL]                                       ;; 03:489a $6e
    ld   H, $40                                        ;; 03:489b $26 $40
    bit  1, [HL]                                       ;; 03:489d $cb $4e
    ret  Z                                             ;; 03:489f $c8
    xor  A, A                                          ;; 03:48a0 $af
    ld   [wDC8C], A                                    ;; 03:48a1 $ea $8c $dc
    ret                                                ;; 03:48a4 $c9
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 03:48a5 ........

call_03_48ad_ProcessTopDownCollision:
    ld   hl,wDABE
    ld   a,[hl]
    ld   [hl],00
    ld   [wDABD],a
    ld   hl,wDABE
    set  7,[hl]
    ld   a,[wDC86]
    and  a
    ret  z
    ld   hl,wDC89
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   de,.data_03_48cf
    add  hl,de
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    jp   hl
.data_03_48cf:
    dw   .call_03_48E1, .call_03_49ED, .call_03_48E6
    dw   .call_03_49ED, .call_03_491B, .call_03_49ED, .call_03_499F
    dw   .call_03_49ED, .call_03_496B
.call_03_48E1:
    xor  a
    ld   [wDC86],a
    ret  
.call_03_48E6:
    ld   c,$01
    ld   b,$FF
    call call_03_4b4c
    jr   nz,.call_03_4900
    ld   a,[wDC86]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$FE
    call call_03_4b4c
    jp   nz,.call_03_4A15
    ret  
.call_03_4900:
    ld   c,$00
    ld   b,$FF
    call call_03_4b4c
    jr   nz,.call_03_4950
    ld   a,[wDC81]
    and  a,$0F
    or   a,$40
    ld   [wDC81],a
    ld   a,$01
    ld   [wDC89],a
    jp   .call_03_49ED

.call_03_491B:
    ld   c,$01
    ld   b,$01
    call call_03_4b4c
    jr   nz,.call_03_4935
    ld   a,[wDC86]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$02
    call call_03_4b4c
    jp   nz,.call_03_4A15
    ret  
.call_03_4935:
    ld   c,$00
    ld   b,$01
    call call_03_4b4c
    jr   nz,.call_03_4950
    ld   a,[wDC81]
    and  a,$0F
    or   a,$80
    ld   [wDC81],a
    ld   a,$05
    ld   [wDC89],a
    jp   .call_03_49ED
.call_03_4950:
    ld   c,$01
    ld   b,$00
    call call_03_4b4c
    jr   nz,.call_03_48E1
    ld   a,[wDC81]
    and  a,$0F
    or   a,$10
    ld   [wDC81],a
    ld   a,$03
    ld   [wDC89],a
    jp   .call_03_49ED

.call_03_496B:
    ld   c,$FF
    ld   b,$FF
    call call_03_4b4c
    jr   nz,.call_03_4985
    ld   a,[wDC86]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$FE
    call call_03_4b4c
    jp   nz,.call_03_4A15
    ret  
.call_03_4985:
    ld   c,$00
    ld   b,$FF
    call call_03_4b4c
    jr   nz,.call_03_49D2
    ld   a,[wDC81]
    and  a,$0F
    or   a,$40
    ld   [wDC81],a
    ld   a,$01
    ld   [wDC89],a
    jr   .call_03_49ED

.call_03_499F:
    ld   c,$FF
    ld   b,$01
    call call_03_4b4c
    jr   nz,.call_03_49B8
    ld   a,[wDC86]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$02
    call call_03_4b4c
    jr   nz,.call_03_4A15
    ret  
.call_03_49B8:
    ld   c,$00
    ld   b,$01
    call call_03_4b4c
    jr   nz,.call_03_49D2
    ld   a,[wDC81]
    and  a,$0F
    or   a,$80
    ld   [wDC81],a
    ld   a,$05
    ld   [wDC89],a
    jr   .call_03_49ED
.call_03_49D2:
    ld   c,$FF
    ld   b,$00
    call call_03_4b4c
    jp   nz,.call_03_48E1
    ld   a,[wDC81]
    and  a,$0F
    or   a,$20
    ld   [wDC81],a
    ld   a,$07
    ld   [wDC89],a
    jr   .call_03_49ED
.call_03_49ED:
    ld   hl,wDC89
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,hl
    ld   de,.data_03_4a1b
    add  hl,de
    ld   e,$00
    ld   a,[wDC86]
    ld   d,a
.call_03_49FF:
    ldi  a,[hl]
    ld   c,a
    ldi  a,[hl]
    ld   b,a
    push hl
    push de
    call call_03_4b4c
    pop  de
    pop  hl
    jr   nz,.call_03_4A10
    inc  e
    dec  d
    jr   nz,.call_03_49FF
.call_03_4A10:
    ld   a,e
    ld   [wDC86],a
    ret  
.call_03_4A15:
    ld   a,$01
    ld   [wDC86],a
    ret  
.data_03_4a1b:
    db   $00, $00        ;; 03:4a15 ????????
    db   $00, $00, $00, $ff, $00, $fe, $01, $ff        ;; 03:4a1d ????????
    db   $02, $fe, $01, $00, $02, $00, $01, $01        ;; 03:4a25 ????????
    db   $02, $02, $00, $01, $00, $02, $ff, $01        ;; 03:4a2d ????????
    db   $fe, $02, $ff, $00, $fe, $00, $ff, $ff        ;; 03:4a35 ????????
    db   $fe, $fe                                      ;; 03:4a3d ??

call_03_4a3f:
    ld   HL, wDABE                                     ;; 03:4a3f $21 $be $da
    ld   A, [HL]                                       ;; 03:4a42 $7e
    ld   [HL], $00                                     ;; 03:4a43 $36 $00
    ld   [wDABD], A                                    ;; 03:4a45 $ea $bd $da
    set  7, [HL]                                       ;; 03:4a48 $cb $fe
    ld   A, [wD801]                                    ;; 03:4a4a $fa $01 $d8
    ld   L, $03                                        ;; 03:4a4d $2e $03
    cp   A, $1f                                        ;; 03:4a4f $fe $1f
    jr   Z, .jr_03_4a61                                ;; 03:4a51 $28 $0e
    ld   L, $02                                        ;; 03:4a53 $2e $02
    cp   A, $21                                        ;; 03:4a55 $fe $21
    jr   Z, .jr_03_4a61                                ;; 03:4a57 $28 $08
    ld   L, $01                                        ;; 03:4a59 $2e $01
    cp   A, $20                                        ;; 03:4a5b $fe $20
    jr   Z, .jr_03_4a61                                ;; 03:4a5d $28 $02
    ld   L, $00                                        ;; 03:4a5f $2e $00
.jr_03_4a61:
    ld   H, $00                                        ;; 03:4a61 $26 $00
    add  HL, HL                                        ;; 03:4a63 $29
    ld   DE, .data_03_4a98                             ;; 03:4a64 $11 $98 $4a
    add  HL, DE                                        ;; 03:4a67 $19
    ld   A, [HL+]                                      ;; 03:4a68 $2a
    ld   H, [HL]                                       ;; 03:4a69 $66
    ld   L, A                                          ;; 03:4a6a $6f
    ld   A, [wDC81]                                    ;; 03:4a6b $fa $81 $dc
    and  A, [HL]                                       ;; 03:4a6e $a6
    ret  Z                                             ;; 03:4a6f $c8
    inc  HL                                            ;; 03:4a70 $23
    ld   B, [HL]                                       ;; 03:4a71 $46
    inc  HL                                            ;; 03:4a72 $23
    ld   E, [HL]                                       ;; 03:4a73 $5e
    inc  HL                                            ;; 03:4a74 $23
    ld   D, [HL]                                       ;; 03:4a75 $56
    inc  HL                                            ;; 03:4a76 $23
.jr_03_4a77:
    cp   A, [HL]                                       ;; 03:4a77 $be
    jr   Z, .jr_03_4a87                                ;; 03:4a78 $28 $0d
    add  HL, DE                                        ;; 03:4a7a $19
    dec  B                                             ;; 03:4a7b $05
    jr   NZ, .jr_03_4a77                               ;; 03:4a7c $20 $f9
.jr_03_4a7e:
    ld   A, [wDC81]                                    ;; 03:4a7e $fa $81 $dc
    and  A, $0f                                        ;; 03:4a81 $e6 $0f
    ld   [wDC81], A                                    ;; 03:4a83 $ea $81 $dc
    ret                                                ;; 03:4a86 $c9
.jr_03_4a87:
    inc  HL                                            ;; 03:4a87 $23
    ld   A, [HL+]                                      ;; 03:4a88 $2a
    ld   C, A                                          ;; 03:4a89 $4f
    ld   A, [HL]                                       ;; 03:4a8a $7e
    sub  A, $0f                                        ;; 03:4a8b $d6 $0f
    ld   B, A                                          ;; 03:4a8d $47
    push BC                                            ;; 03:4a8e $c5
    push HL                                            ;; 03:4a8f $e5
    call call_03_4b4c                                  ;; 03:4a90 $cd $4c $4b
    pop  HL                                            ;; 03:4a93 $e1
    pop  BC                                            ;; 03:4a94 $c1
    jr   NZ, .jr_03_4a7e                               ;; 03:4a95 $20 $e7
    ret                                                ;; 03:4a97 $c9
.data_03_4a98:
    db   $a0, $4a, $cc, $4a, $da, $4a, $a0, $4a        ;; 03:4a98 ????????
    db   $f0, $08, $05, $00, $40, $00, $ef, $00        ;; 03:4aa0 ????????
    db   $ff, $80, $00, $10, $00, $01, $20, $f7        ;; 03:4aa8 ????????
    db   $00, $ff, $00, $10, $09, $00, $01, $00        ;; 03:4ab0 ????????
    db   $60, $f7, $ef, $ff, $ff, $a0, $f7, $10        ;; 03:4ab8 ????????
    db   $ff, $01, $50, $09, $ef, $01, $ff, $90        ;; 03:4ac0 ????????
    db   $09, $10, $01, $01, $30, $02, $05, $00        ;; 03:4ac8 ????????
    db   $20, $f7, $00, $ff, $00, $10, $09, $00        ;; 03:4ad0 ????????
    db   $01, $00, $00, $01, $00, $05, $00, $80        ;; 03:4ad8 ????????
    db   $00, $10, $00, $01                            ;; 03:4ae0 ????

call_03_4ae4:
    ld   HL, wDABE                                     ;; 03:4ae4 $21 $be $da
    ld   A, [HL]                                       ;; 03:4ae7 $7e
    ld   [HL], $00                                     ;; 03:4ae8 $36 $00
    ld   [wDABD], A                                    ;; 03:4aea $ea $bd $da
    set  7, [HL]                                       ;; 03:4aed $cb $fe
    ld   HL, .data_03_4b1b                             ;; 03:4aef $21 $1b $4b
    ld   A, [wDC81]                                    ;; 03:4af2 $fa $81 $dc
    and  A, [HL]                                       ;; 03:4af5 $a6
    ret  Z                                             ;; 03:4af6 $c8
    inc  HL                                            ;; 03:4af7 $23
    ld   B, [HL]                                       ;; 03:4af8 $46
    inc  HL                                            ;; 03:4af9 $23
    ld   E, [HL]                                       ;; 03:4afa $5e
    inc  HL                                            ;; 03:4afb $23
    ld   D, [HL]                                       ;; 03:4afc $56
    inc  HL                                            ;; 03:4afd $23
.jr_03_4afe:
    cp   A, [HL]                                       ;; 03:4afe $be
    jr   Z, .jr_03_4b0e                                ;; 03:4aff $28 $0d
    add  HL, DE                                        ;; 03:4b01 $19
    dec  B                                             ;; 03:4b02 $05
    jr   NZ, .jr_03_4afe                               ;; 03:4b03 $20 $f9
.jr_03_4b05:
    ld   A, [wDC81]                                    ;; 03:4b05 $fa $81 $dc
    and  A, $0f                                        ;; 03:4b08 $e6 $0f
    ld   [wDC81], A                                    ;; 03:4b0a $ea $81 $dc
    ret                                                ;; 03:4b0d $c9
.jr_03_4b0e:
    inc  HL                                            ;; 03:4b0e $23
    ld   A, [HL+]                                      ;; 03:4b0f $2a
    ld   C, A                                          ;; 03:4b10 $4f
    ld   A, [HL]                                       ;; 03:4b11 $7e
    ld   B, A                                          ;; 03:4b12 $47
    call call_03_4c12                                  ;; 03:4b13 $cd $12 $4c
    bit  3, B                                          ;; 03:4b16 $cb $58
    jr   Z, .jr_03_4b05                                ;; 03:4b18 $28 $eb
    ret                                                ;; 03:4b1a $c9
.data_03_4b1b:
    db   $f0, $08, $03, $00, $40, $00, $ff, $80        ;; 03:4b1b ????????
    db   $00, $01, $20, $ff, $00, $10, $01, $00        ;; 03:4b23 ????????
    db   $60, $ff, $ff, $a0, $ff, $01, $50, $01        ;; 03:4b2b ????????
    db   $ff, $90, $01, $01                            ;; 03:4b33 ????

call_03_4b37:
    ld   A, [wDC86]                                    ;; 03:4b37 $fa $86 $dc
    ld   HL, wD80D                                     ;; 03:4b3a $21 $0d $d8
    bit  5, [HL]                                       ;; 03:4b3d $cb $6e
    jr   Z, .jr_03_4b43                                ;; 03:4b3f $28 $02
    cpl                                                ;; 03:4b41 $2f
    inc  A                                             ;; 03:4b42 $3c
.jr_03_4b43:
    ld   HL, wDC84                                     ;; 03:4b43 $21 $84 $dc
    add  A, [HL]                                       ;; 03:4b46 $86
    ld   HL, wDC85                                     ;; 03:4b47 $21 $85 $dc
    add  A, [HL]                                       ;; 03:4b4a $86
    ret                                                ;; 03:4b4b $c9

call_03_4b4c:
    ld   A, [wD810]                                    ;; 03:4b4c $fa $10 $d8
    add  A, $0f                                        ;; 03:4b4f $c6 $0f
    add  A, B                                          ;; 03:4b51 $80
    ld   B, A                                          ;; 03:4b52 $47
    and  A, $f8                                        ;; 03:4b53 $e6 $f8
    ld   L, A                                          ;; 03:4b55 $6f
    ld   H, $30                                        ;; 03:4b56 $26 $30
    add  HL, HL                                        ;; 03:4b58 $29
    add  HL, HL                                        ;; 03:4b59 $29
    ld   A, [wD80E]                                    ;; 03:4b5a $fa $0e $d8
    add  A, C                                          ;; 03:4b5d $81
    ld   C, A                                          ;; 03:4b5e $4f
    rrca                                               ;; 03:4b5f $0f
    rrca                                               ;; 03:4b60 $0f
    rrca                                               ;; 03:4b61 $0f
    and  A, $1f                                        ;; 03:4b62 $e6 $1f
    or   A, L                                          ;; 03:4b64 $b5
    ld   L, A                                          ;; 03:4b65 $6f
    ld   E, [HL]                                       ;; 03:4b66 $5e
    ld   A, B                                          ;; 03:4b67 $78
    and  A, $07                                        ;; 03:4b68 $e6 $07
    add  A, $c4                                        ;; 03:4b6a $c6 $c4
    ld   D, A                                          ;; 03:4b6c $57
    ld   A, C                                          ;; 03:4b6d $79
    and  A, $07                                        ;; 03:4b6e $e6 $07
    ld   L, A                                          ;; 03:4b70 $6f
    ld   H, $00                                        ;; 03:4b71 $26 $00
    ld   BC, .data_03_4b7a                             ;; 03:4b73 $01 $7a $4b
    add  HL, BC                                        ;; 03:4b76 $09
    ld   A, [DE]                                       ;; 03:4b77 $1a
    and  A, [HL]                                       ;; 03:4b78 $a6
    ret                                                ;; 03:4b79 $c9
.data_03_4b7a:
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 03:4b7a ????????

call_03_4b82:
    ld   a,[wD810]
    add  b
    ld   b,a
    and  a,$F8
    ld   l,a
    ld   h,$30
    add  hl,hl
    add  hl,hl
    ld   a,[wD80E]
    add  c
    ld   c,a
    rrca 
    rrca 
    rrca 
    and  a,$1F
    or   l
    ld   l,a
    ld   e,[hl]
    ld   a,b
    and  a,$07
    add  a,$C4
    ld   d,a
    ld   a,c
    and  a,$07
    ld   l,a
    ld   h,$00
    ld   bc,.data_03_4bae
    add  hl,bc
    ld   a,[de]
    and  [hl]
    ret
.data_03_4bae:
    db   $80, $40, $20, $10, $08, $04, $02, $01                            ;; 03:4bb2 ????
