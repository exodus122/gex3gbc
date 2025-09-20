call_00_2299:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2299 $fa $00 $da
    rlca                                               ;; 00:229c $07
    rlca                                               ;; 00:229d $07
    rlca                                               ;; 00:229e $07
    and  A, $07                                        ;; 00:229f $e6 $07
    ld   L, A                                          ;; 00:22a1 $6f
    ld   H, $00                                        ;; 00:22a2 $26 $00
    ld   DE, wDA01                                     ;; 00:22a4 $11 $01 $da
    add  HL, DE                                        ;; 00:22a7 $19
    ld   L, [HL]                                       ;; 00:22a8 $6e
    ld   H, $d7                                        ;; 00:22a9 $26 $d7
    ld   A, [HL]                                       ;; 00:22ab $7e
    and  A, $f0                                        ;; 00:22ac $e6 $f0
    or   A, C                                          ;; 00:22ae $b1
    ld   [HL], A                                       ;; 00:22af $77
    ret                                                ;; 00:22b0 $c9

call_00_22b1:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:22b1 $fa $00 $da
    rlca                                               ;; 00:22b4 $07
    rlca                                               ;; 00:22b5 $07
    rlca                                               ;; 00:22b6 $07
    and  A, $07                                        ;; 00:22b7 $e6 $07
    ld   L, A                                          ;; 00:22b9 $6f
    ld   H, $00                                        ;; 00:22ba $26 $00
    ld   DE, wDA01                                     ;; 00:22bc $11 $01 $da
    add  HL, DE                                        ;; 00:22bf $19
    ld   L, [HL]                                       ;; 00:22c0 $6e
    ld   H, $d7                                        ;; 00:22c1 $26 $d7
    ld   A, [HL]                                       ;; 00:22c3 $7e
    and  A, $0f                                        ;; 00:22c4 $e6 $0f
    cp   A, C                                          ;; 00:22c6 $b9
    ret  Z                                             ;; 00:22c7 $c8
    ld   [wDAD6_ReturnBank], A                                    ;; 00:22c8 $ea $d6 $da
    ld   A, $02                                        ;; 00:22cb $3e $02
    ld   HL, entry_02_72ac                              ;; 00:22cd $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:22d0 $cd $dd $0e
    ret                                                ;; 00:22d3 $c9
    db   $cd, $0f, $23, $06, $00, $21, $b1, $dc        ;; 00:22d4 ????????
    db   $09, $7e, $a7, $c9, $cd, $0f, $23, $79        ;; 00:22dc ????????
    db   $fe, $10, $d0, $06, $00, $21, $b1, $dc        ;; 00:22e4 ????????
    db   $09, $34, $c9, $cd, $0f, $23, $79, $fe        ;; 00:22ec ????????
    db   $10, $d0, $06, $00, $21, $b1, $dc, $09        ;; 00:22f4 ????????
    db   $36, $01, $c9, $cd, $0f, $23, $79, $fe        ;; 00:22fc ????????
    db   $10, $d0, $06, $00, $21, $b1, $dc, $09        ;; 00:2304 ????????
    db   $36, $00, $c9                                 ;; 00:230c ???

call_00_230f:
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:230f $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2312 $cd $ee $0e
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:2315 $21 $17 $dc
    ld   C, [HL]                                       ;; 00:2318 $4e
    inc  HL                                            ;; 00:2319 $23
    ld   B, [HL]                                       ;; 00:231a $46
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:231b $fa $00 $da
    rlca                                               ;; 00:231e $07
    rlca                                               ;; 00:231f $07
    rlca                                               ;; 00:2320 $07
    and  A, $07                                        ;; 00:2321 $e6 $07
    ld   L, A                                          ;; 00:2323 $6f
    ld   H, $00                                        ;; 00:2324 $26 $00
    ld   DE, wDA01                                     ;; 00:2326 $11 $01 $da
    add  HL, DE                                        ;; 00:2329 $19
    ld   L, [HL]                                       ;; 00:232a $6e
    dec  L                                             ;; 00:232b $2d
    ld   H, $00                                        ;; 00:232c $26 $00
    add  HL, HL                                        ;; 00:232e $29
    add  HL, HL                                        ;; 00:232f $29
    add  HL, HL                                        ;; 00:2330 $29
    add  HL, HL                                        ;; 00:2331 $29
    add  HL, BC                                        ;; 00:2332 $09
    ld   DE, $0d                                       ;; 00:2333 $11 $0d $00
    add  HL, DE                                        ;; 00:2336 $19
    ld   C, [HL]                                       ;; 00:2337 $4e
    push BC                                            ;; 00:2338 $c5
    call call_00_0f08_SwitchBank2                                  ;; 00:2339 $cd $08 $0f
    pop  BC                                            ;; 00:233c $c1
    ret                                                ;; 00:233d $c9
    db   $26, $d8, $fa, $00, $da, $f6, $1b, $6f        ;; 00:233e ????????
    db   $34, $7e, $d6, $2e, $20, $06, $77, $2c        ;; 00:2346 ????????
    db   $34, $cb, $96, $2d, $2c, $3a, $6e, $26        ;; 00:234e ????????
    db   $00, $29, $11, $b4, $23, $19, $fe, $00        ;; 00:2356 ????????
    db   $28, $21, $fe, $01, $28, $15, $fe, $02        ;; 00:235e ????????
    db   $28, $07, $2a, $2f, $3c, $4f, $5e, $18        ;; 00:2366 ????????
    db   $15, $2a, $2f, $3c, $5f, $7e, $2f, $3c        ;; 00:236e ????????
    db   $4f, $18, $0b, $4e, $23, $7e, $2f, $3c        ;; 00:2376 ????????
    db   $5f, $18, $03, $5e, $23, $4e, $7b, $fe        ;; 00:237e ????????
    db   $80, $3e, $ff, $ce, $00, $57, $d5, $cd        ;; 00:2386 ????????
    db   $35, $28, $e1, $19, $e5, $79, $fe, $80        ;; 00:238e ????????
    db   $3e, $ff, $ce, $00, $47, $c5, $cd, $f3        ;; 00:2396 ????????
    db   $27, $e1, $19, $e5, $c1, $d1, $26, $d8        ;; 00:239e ????????
    db   $fa, $00, $da, $f6, $0e, $6f, $7b, $22        ;; 00:23a6 ????????
    db   $7a, $22, $79, $22, $70, $c9, $00, $e0        ;; 00:23ae ????????
    db   $01, $e0, $02, $e0, $03, $e0, $04, $e0        ;; 00:23b6 ????????
    db   $05, $e0, $06, $e1, $07, $e1, $08, $e1        ;; 00:23be ????????
    db   $09, $e1, $0a, $e2, $0b, $e2, $0c, $e2        ;; 00:23c6 ????????
    db   $0d, $e3, $0e, $e3, $0f, $e4, $10, $e5        ;; 00:23ce ????????
    db   $11, $e5, $12, $e6, $13, $e7, $14, $e8        ;; 00:23d6 ????????
    db   $15, $e8, $16, $e9, $17, $ea, $17, $eb        ;; 00:23de ????????
    db   $18, $ec, $19, $ed, $1a, $ee, $1a, $ef        ;; 00:23e6 ????????
    db   $1b, $f0, $1b, $f1, $1c, $f2, $1c, $f3        ;; 00:23ee ????????
    db   $1d, $f4, $1d, $f5, $1d, $f6, $1e, $f7        ;; 00:23f6 ????????
    db   $1e, $f8, $1e, $f9, $1e, $fa, $1f, $fb        ;; 00:23fe ????????
    db   $1f, $fc, $1f, $fd, $1f, $fe, $1f, $ff        ;; 00:2406 ????????
    db   $1f, $00, $26, $d8, $fa, $00, $da, $f6        ;; 00:240e ????????
    db   $0e, $6f, $0e, $20, $fa, $0e, $d8, $96        ;; 00:2416 ????????
    db   $23, $fa, $0f, $d8, $9e, $38, $02, $0e        ;; 00:241e ????????
    db   $00, $7d, $ee, $02, $6f, $71, $c9, $26        ;; 00:2426 ????????
    db   $d8, $fa, $00, $da, $f6, $0e, $6f, $0e        ;; 00:242e ????????
    db   $00, $fa, $0e, $d8, $96, $23, $fa, $0f        ;; 00:2436 ????????
    db   $d8, $9e, $38, $02, $0e, $20, $7d, $ee        ;; 00:243e ????????
    db   $02, $6f, $71, $c9                            ;; 00:2446 ????

call_00_244a:
    ld   H, $d8                                        ;; 00:244a $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:244c $fa $00 $da
    or   A, $1d                                        ;; 00:244f $f6 $1d
    ld   L, A                                          ;; 00:2451 $6f
    ld   A, [HL]                                       ;; 00:2452 $7e
    sub  A, $02                                        ;; 00:2453 $d6 $02
    bit  7, A                                          ;; 00:2455 $cb $7f
    jr   Z, .jr_00_245f                                ;; 00:2457 $28 $06
    cp   A, $c0                                        ;; 00:2459 $fe $c0
    jr   NC, .jr_00_245f                               ;; 00:245b $30 $02
    ld   A, $c0                                        ;; 00:245d $3e $c0
.jr_00_245f:
    ld   [HL], A                                       ;; 00:245f $77
    cpl                                                ;; 00:2460 $2f
    inc  A                                             ;; 00:2461 $3c
    sra  A                                             ;; 00:2462 $cb $2f
    sra  A                                             ;; 00:2464 $cb $2f
    sra  A                                             ;; 00:2466 $cb $2f
    sra  A                                             ;; 00:2468 $cb $2f
    ld   C, A                                          ;; 00:246a $4f
    cp   A, $80                                        ;; 00:246b $fe $80
    ld   A, $ff                                        ;; 00:246d $3e $ff
    adc  A, $00                                        ;; 00:246f $ce $00
    ld   B, A                                          ;; 00:2471 $47
    jp   jp_00_250d                                    ;; 00:2472 $c3 $0d $25
    db   $26, $d8, $fa, $00, $da, $f6, $1d, $6f        ;; 00:2475 ????????
    db   $7e, $d6, $02, $cb, $7f, $28, $06, $fe        ;; 00:247d ????????
    db   $c0, $30, $02, $3e, $c0, $77, $cb, $2f        ;; 00:2485 ????????
    db   $cb, $2f, $cb, $2f, $cb, $2f, $4f, $fe        ;; 00:248d ????????
    db   $80, $3e, $ff, $ce, $00, $47, $7d, $ee        ;; 00:2495 ????????
    db   $0d, $6f, $7e, $81, $22, $7e, $88, $77        ;; 00:249d ????????
    db   $cd, $f3, $27, $26, $d8, $fa, $00, $da        ;; 00:24a5 ????????
    db   $f6, $10, $6f, $7b, $96, $23, $7a, $9e        ;; 00:24ad ????????
    db   $d8, $72, $2d, $73, $7d, $ee, $0d, $6f        ;; 00:24b5 ????????
    db   $af, $77, $c9                                 ;; 00:24bd ???

call_00_24c0:
    ld   H, $d8                                        ;; 00:24c0 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:24c2 $fa $00 $da
    or   A, $1b                                        ;; 00:24c5 $f6 $1b
    ld   L, A                                          ;; 00:24c7 $6f
    ld   A, [HL+]                                      ;; 00:24c8 $2a
    add  A, [HL]                                       ;; 00:24c9 $86
    ld   C, A                                          ;; 00:24ca $4f
    and  A, $0f                                        ;; 00:24cb $e6 $0f
    ld   [HL], A                                       ;; 00:24cd $77
    ld   A, C                                          ;; 00:24ce $79
    sra  A                                             ;; 00:24cf $cb $2f
    sra  A                                             ;; 00:24d1 $cb $2f
    sra  A                                             ;; 00:24d3 $cb $2f
    sra  A                                             ;; 00:24d5 $cb $2f
    ld   C, A                                          ;; 00:24d7 $4f
    cp   A, $80                                        ;; 00:24d8 $fe $80
    ld   A, $ff                                        ;; 00:24da $3e $ff
    adc  A, $00                                        ;; 00:24dc $ce $00
    ld   B, A                                          ;; 00:24de $47
    ld   H, $d8                                        ;; 00:24df $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:24e1 $fa $00 $da
    or   A, $0e                                        ;; 00:24e4 $f6 $0e
    ld   L, A                                          ;; 00:24e6 $6f
    ld   A, [HL]                                       ;; 00:24e7 $7e
    add  A, C                                          ;; 00:24e8 $81
    ld   [HL+], A                                      ;; 00:24e9 $22
    ld   A, [HL]                                       ;; 00:24ea $7e
    adc  A, B                                          ;; 00:24eb $88
    ld   [HL], A                                       ;; 00:24ec $77
    ret                                                ;; 00:24ed $c9

call_00_24ee:
    ld   H, $d8                                        ;; 00:24ee $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:24f0 $fa $00 $da
    or   A, $1d                                        ;; 00:24f3 $f6 $1d
    ld   L, A                                          ;; 00:24f5 $6f
    ld   A, [HL+]                                      ;; 00:24f6 $2a
    add  A, [HL]                                       ;; 00:24f7 $86
    ld   C, A                                          ;; 00:24f8 $4f
    and  A, $0f                                        ;; 00:24f9 $e6 $0f
    ld   [HL], A                                       ;; 00:24fb $77
    ld   A, C                                          ;; 00:24fc $79
    sra  A                                             ;; 00:24fd $cb $2f
    sra  A                                             ;; 00:24ff $cb $2f
    sra  A                                             ;; 00:2501 $cb $2f
    sra  A                                             ;; 00:2503 $cb $2f
    ld   C, A                                          ;; 00:2505 $4f
    cp   A, $80                                        ;; 00:2506 $fe $80
    ld   A, $ff                                        ;; 00:2508 $3e $ff
    adc  A, $00                                        ;; 00:250a $ce $00
    ld   B, A                                          ;; 00:250c $47

jp_00_250d:
    ld   H, $d8                                        ;; 00:250d $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:250f $fa $00 $da
    or   A, $10                                        ;; 00:2512 $f6 $10
    ld   L, A                                          ;; 00:2514 $6f
    ld   A, [HL]                                       ;; 00:2515 $7e
    add  A, C                                          ;; 00:2516 $81
    ld   [HL+], A                                      ;; 00:2517 $22
    ld   A, [HL]                                       ;; 00:2518 $7e
    adc  A, B                                          ;; 00:2519 $88
    ld   [HL], A                                       ;; 00:251a $77
    ret                                                ;; 00:251b $c9

call_00_251c:
    call call_00_254a                                  ;; 00:251c $cd $4a $25
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:251f $fa $00 $da
    rrca                                               ;; 00:2522 $0f
    and  A, $70                                        ;; 00:2523 $e6 $70
    ld   L, A                                          ;; 00:2525 $6f
    ld   H, $00                                        ;; 00:2526 $26 $00
    ld   BC, wDA1C                                     ;; 00:2528 $01 $1c $da
    add  HL, BC                                        ;; 00:252b $09
    ld   C, $20                                        ;; 00:252c $0e $20
    ld   A, [HL+]                                      ;; 00:252e $2a
    sub  A, E                                          ;; 00:252f $93
    ld   A, [HL+]                                      ;; 00:2530 $2a
    sbc  A, D                                          ;; 00:2531 $9a
    jr   C, .jr_00_253e                                ;; 00:2532 $38 $0a
    ld   C, $00                                        ;; 00:2534 $0e $00
    ld   A, [HL+]                                      ;; 00:2536 $2a
    sub  A, E                                          ;; 00:2537 $93
    ld   A, [HL]                                       ;; 00:2538 $7e
    sbc  A, D                                          ;; 00:2539 $9a
    jr   NC, .jr_00_253e                               ;; 00:253a $30 $02
    xor  A, A                                          ;; 00:253c $af
    ret                                                ;; 00:253d $c9
.jr_00_253e:
    ld   H, $d8                                        ;; 00:253e $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2540 $fa $00 $da
    or   A, $0d                                        ;; 00:2543 $f6 $0d
    ld   L, A                                          ;; 00:2545 $6f
    ld   A, [HL]                                       ;; 00:2546 $7e
    ld   [HL], C                                       ;; 00:2547 $71
    cp   A, C                                          ;; 00:2548 $b9
    ret                                                ;; 00:2549 $c9

call_00_254a:
    ld   H, $d8                                        ;; 00:254a $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:254c $fa $00 $da
    or   A, $0d                                        ;; 00:254f $f6 $0d
    ld   L, A                                          ;; 00:2551 $6f
    ld   C, [HL]                                       ;; 00:2552 $4e
    ld   H, $d8                                        ;; 00:2553 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2555 $fa $00 $da
    or   A, $1b                                        ;; 00:2558 $f6 $1b
    ld   L, A                                          ;; 00:255a $6f
    ld   A, [HL+]                                      ;; 00:255b $2a
    bit  5, C                                          ;; 00:255c $cb $69
    jr   Z, .jr_00_2562                                ;; 00:255e $28 $02
    cpl                                                ;; 00:2560 $2f
    inc  A                                             ;; 00:2561 $3c
.jr_00_2562:
    add  A, [HL]                                       ;; 00:2562 $86
    ld   C, A                                          ;; 00:2563 $4f
    and  A, $0f                                        ;; 00:2564 $e6 $0f
    ld   [HL], A                                       ;; 00:2566 $77
    ld   A, C                                          ;; 00:2567 $79
    sra  A                                             ;; 00:2568 $cb $2f
    sra  A                                             ;; 00:256a $cb $2f
    sra  A                                             ;; 00:256c $cb $2f
    sra  A                                             ;; 00:256e $cb $2f
    ld   C, A                                          ;; 00:2570 $4f
    ld   [wDA13], A                                    ;; 00:2571 $ea $13 $da
    cp   A, $80                                        ;; 00:2574 $fe $80
    ld   A, $ff                                        ;; 00:2576 $3e $ff
    adc  A, $00                                        ;; 00:2578 $ce $00
    ld   B, A                                          ;; 00:257a $47
    ld   A, L                                          ;; 00:257b $7d
    xor  A, $12                                        ;; 00:257c $ee $12
    ld   L, A                                          ;; 00:257e $6f
    ld   A, [HL]                                       ;; 00:257f $7e
    add  A, C                                          ;; 00:2580 $81
    ld   [HL+], A                                      ;; 00:2581 $22
    ld   E, A                                          ;; 00:2582 $5f
    ld   A, [HL]                                       ;; 00:2583 $7e
    adc  A, B                                          ;; 00:2584 $88
    ld   [HL], A                                       ;; 00:2585 $77
    ld   D, A                                          ;; 00:2586 $57
    ret                                                ;; 00:2587 $c9

call_00_2588:
    ld   H, $d8                                        ;; 00:2588 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:258a $fa $00 $da
    or   A, $1b                                        ;; 00:258d $f6 $1b
    ld   L, A                                          ;; 00:258f $6f
    ld   A, [HL]                                       ;; 00:2590 $7e
    cp   A, C                                          ;; 00:2591 $b9
    ret  Z                                             ;; 00:2592 $c8
    jr   C, .jr_00_2599                                ;; 00:2593 $38 $04
    dec  [HL]                                          ;; 00:2595 $35
    ld   A, [HL]                                       ;; 00:2596 $7e
    cp   A, C                                          ;; 00:2597 $b9
    ret                                                ;; 00:2598 $c9
.jr_00_2599:
    inc  [HL]                                          ;; 00:2599 $34
    ld   A, [HL]                                       ;; 00:259a $7e
    cp   A, C                                          ;; 00:259b $b9
    ret                                                ;; 00:259c $c9

    db   $cd, $cb, $25, $fa, $00, $da, $0f, $e6        ;; 00:259d ????????
    db   $70, $6f, $26, $00, $01, $20, $da, $09        ;; 00:25a5 ????????
    db   $0e, $00, $2a, $93, $2a, $9a, $38, $0a        ;; 00:25ad ????????
    db   $0e, $40, $2a, $93, $7e, $9a, $30, $02        ;; 00:25b5 ????????
    db   $af, $c9, $26, $d8, $fa, $00, $da, $f6        ;; 00:25bd ????????
    db   $0d, $6f, $7e, $71, $b9, $c9, $26, $d8        ;; 00:25c5 ????????
    db   $fa, $00, $da, $f6, $0d, $6f, $4e, $7d        ;; 00:25cd ????????
    db   $ee, $10, $6f, $2a, $cb, $71, $20, $02        ;; 00:25d5 ????????
    db   $2f, $3c, $86, $4f, $e6, $0f, $77, $79        ;; 00:25dd ????????
    db   $cb, $2f, $cb, $2f, $cb, $2f, $cb, $2f        ;; 00:25e5 ????????
    db   $4f, $fe, $80, $3e, $ff, $ce, $00, $47        ;; 00:25ed ????????
    db   $7d, $ee, $0e, $6f, $7e, $81, $22, $5f        ;; 00:25f5 ????????
    db   $7e, $88, $77, $57, $c9, $26, $d8, $fa        ;; 00:25fd ????????
    db   $00, $da, $f6, $1d, $6f, $7e, $b9, $c8        ;; 00:2605 ????????
    db   $38, $04, $35, $7e, $b9, $c9, $34, $7e        ;; 00:260d ????????
    db   $b9, $c9, $cd, $57, $28, $26, $d8, $fa        ;; 00:2615 ????????
    db   $00, $da, $f6, $0e, $6f, $2a, $93, $3a        ;; 00:261d ????????
    db   $9a, $38, $11, $cd, $46, $28, $26, $d8        ;; 00:2625 ????????
    db   $fa, $00, $da, $f6, $0e, $6f, $2a, $93        ;; 00:262d ????????
    db   $3a, $9a, $d8, $1b, $7b, $96, $73, $23        ;; 00:2635 ????????
    db   $72, $21, $13, $da, $86, $77, $af, $c9        ;; 00:263d ????????
    db   $cb, $7f, $20, $12, $06, $00, $cd, $46        ;; 00:2645 ????????
    db   $28, $cd, $78, $26, $79, $93, $78, $9a        ;; 00:264d ????????
    db   $38, $17, $4b, $42, $18, $13, $af, $91        ;; 00:2655 ????????
    db   $4f, $06, $ff, $cd, $57, $28, $cd, $78        ;; 00:265d ????????
    db   $26, $7b, $91, $7a, $98, $38, $02, $4b        ;; 00:2665 ????????
    db   $42, $78, $32, $71, $79, $93, $4f, $78        ;; 00:266d ????????
    db   $9a, $b1, $c9, $fa, $00, $da, $f6, $0e        ;; 00:2675 ????????
    db   $6f, $26, $d8, $2a, $81, $4f, $7e, $88        ;; 00:267d ????????
    db   $47, $c9, $cb, $7f, $20, $12, $06, $00        ;; 00:2685 ????????
    db   $cd, $04, $28, $cd, $ba, $26, $79, $93        ;; 00:268d ????????
    db   $78, $9a, $38, $17, $4b, $42, $18, $13        ;; 00:2695 ????????
    db   $af, $91, $4f, $06, $ff, $cd, $15, $28        ;; 00:269d ????????
    db   $cd, $ba, $26, $7b, $91, $7a, $98, $38        ;; 00:26a5 ????????
    db   $02, $4b, $42, $78, $32, $71, $79, $93        ;; 00:26ad ????????
    db   $4f, $78, $9a, $b1, $c9, $fa, $00, $da        ;; 00:26b5 ????????
    db   $f6, $10, $6f, $26, $d8, $2a, $81, $4f        ;; 00:26bd ????????
    db   $7e, $88, $47, $c9, $26, $d8, $fa, $00        ;; 00:26c5 ????????
    db   $da, $f6, $1b, $6f, $4e, $ee, $02, $6f        ;; 00:26cd ????????
    db   $46, $ee, $17, $6f, $2a, $5f, $56, $cb        ;; 00:26d5 ????????
    db   $70, $20, $03, $af, $91, $4f, $7d, $e6        ;; 00:26dd ????????
    db   $e0, $21, $7b, $dc, $be, $20, $05, $79        ;; 00:26e5 ????????
    db   $ea, $85, $dc, $c9, $21, $7d, $dc, $be        ;; 00:26ed ????????
    db   $c0, $26, $d8, $fa, $00, $da, $f6, $12        ;; 00:26f5 ????????
    db   $6f, $fa, $0e, $d8, $93, $fa, $0f, $d8        ;; 00:26fd ????????
    db   $9a, $38, $0c, $7b, $86, $ea, $0e, $d8        ;; 00:2705 ????????
    db   $7a, $ce, $00, $ea, $0f, $d8, $c9, $4e        ;; 00:270d ????????
    db   $0c, $7b, $91, $ea, $0e, $d8, $7a, $de        ;; 00:2715 ????????
    db   $00, $ea, $0f, $d8, $c9                       ;; 00:271d ?????

call_00_2722:
    ld   HL, wD810_PlayerYPosition                                     ;; 00:2722 $21 $10 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2725 $fa $00 $da
    or   A, $10                                        ;; 00:2728 $f6 $10
    ld   C, A                                          ;; 00:272a $4f
    ld   B, $d8                                        ;; 00:272b $06 $d8
    ld   A, [BC]                                       ;; 00:272d $0a
    sub  A, [HL]                                       ;; 00:272e $96
    ld   E, A                                          ;; 00:272f $5f
    inc  BC                                            ;; 00:2730 $03
    inc  HL                                            ;; 00:2731 $23
    ld   A, [BC]                                       ;; 00:2732 $0a
    sbc  A, [HL]                                       ;; 00:2733 $9e
    ld   D, A                                          ;; 00:2734 $57
    ld   A, C                                          ;; 00:2735 $79
    xor  A, $02                                        ;; 00:2736 $ee $02
    ld   C, A                                          ;; 00:2738 $4f
    ld   A, [BC]                                       ;; 00:2739 $0a
    add  A, E                                          ;; 00:273a $83
    ld   E, A                                          ;; 00:273b $5f
    ld   A, $00                                        ;; 00:273c $3e $00
    adc  A, D                                          ;; 00:273e $8a
    jr   NZ, .jr_00_2764                               ;; 00:273f $20 $23
    ld   A, [BC]                                       ;; 00:2741 $0a
    add  A, A                                          ;; 00:2742 $87
    cp   A, E                                          ;; 00:2743 $bb
    jr   C, .jr_00_2764                                ;; 00:2744 $38 $1e
    call call_00_2857                                  ;; 00:2746 $cd $57 $28
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2749 $fa $0e $d8
    sub  A, E                                          ;; 00:274c $93
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:274d $fa $0f $d8
    sbc  A, D                                          ;; 00:2750 $9a
    jr   C, .jr_00_2764                                ;; 00:2751 $38 $11
    call call_00_2846                                  ;; 00:2753 $cd $46 $28
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2756 $fa $0e $d8
    sub  A, E                                          ;; 00:2759 $93
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:275a $fa $0f $d8
    sbc  A, D                                          ;; 00:275d $9a
    jr   NC, .jr_00_2764                               ;; 00:275e $30 $04
    ld   A, $01                                        ;; 00:2760 $3e $01
    and  A, A                                          ;; 00:2762 $a7
    ret                                                ;; 00:2763 $c9
.jr_00_2764:
    xor  A, A                                          ;; 00:2764 $af
    ret                                                ;; 00:2765 $c9

call_00_2766:
    call call_00_27f3                                  ;; 00:2766 $cd $f3 $27
    ld   H, $d8                                        ;; 00:2769 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:276b $fa $00 $da
    or   A, $10                                        ;; 00:276e $f6 $10
    ld   L, A                                          ;; 00:2770 $6f
    ld   A, [HL+]                                      ;; 00:2771 $2a
    sub  A, E                                          ;; 00:2772 $93
    ld   A, [HL]                                       ;; 00:2773 $7e
    sbc  A, D                                          ;; 00:2774 $9a
    ret  C                                             ;; 00:2775 $d8
    ld   [HL], D                                       ;; 00:2776 $72
    dec  L                                             ;; 00:2777 $2d
    ld   [HL], E                                       ;; 00:2778 $73
    ld   A, L                                          ;; 00:2779 $7d
    xor  A, $0d                                        ;; 00:277a $ee $0d
    ld   L, A                                          ;; 00:277c $6f
    xor  A, A                                          ;; 00:277d $af
    ld   [HL], A                                       ;; 00:277e $77
    ret                                                ;; 00:277f $c9

call_00_2780:
    ld   hl,wDBFB_YPositionInMap
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    ld   de,$00B0
    add  hl,de
    ld   e,l
    ld   d,h
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  

call_00_2799:
    call call_00_2835
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   e,a
    ld   a,[hl]
    sbc  d
    ld   d,a
    jr   nc,label27B3
    xor  a
    sub  e
    ld   e,a
    ld   a,$00
    sbc  d
    ld   d,a
label27B3:
    srl  d
    rr   e
    push de
    call call_00_27f3
    pop  hl
    add  hl,de
    ld   d,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   e,a
    ld   a,l
    ld   [de],a
    inc  e
    ld   a,h
    ld   [de],a
    ret  

call_00_27cb:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   l,a
    ld   a,[wDBFB_YPositionInMap]
    sub  a,$14
    ldi  [hl],a
    ld   a,[wDBFC_YPositionInMap]
    sbc  a,$00
    ld   [hl],a
    ret  nc
    xor  a
    ldd  [hl],a
    ld   [hl],a
    ret  

call_00_27e4:
    call call_00_27f3
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   l,a
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_27f3:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:27f3 $fa $00 $da
    rrca                                               ;; 00:27f6 $0f
    and  A, $70                                        ;; 00:27f7 $e6 $70
    ld   L, A                                          ;; 00:27f9 $6f
    ld   H, $00                                        ;; 00:27fa $26 $00
    ld   DE, wDA26                                     ;; 00:27fc $11 $26 $da
    add  HL, DE                                        ;; 00:27ff $19
    ld   A, [HL+]                                      ;; 00:2800 $2a
    ld   E, A                                          ;; 00:2801 $5f
    ld   D, [HL]                                       ;; 00:2802 $56
    ret                                                ;; 00:2803 $c9

call_00_2804:
    ld   a,[wDA00_CurrentObjectAddr]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA20
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2815:
    ld   a,[wDA00_CurrentObjectAddr]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA22
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2826:
    call call_00_2835
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_2835:
    ld   a,[wDA00_CurrentObjectAddr]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA24
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2846:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2846 $fa $00 $da
    rrca                                               ;; 00:2849 $0f
    and  A, $70                                        ;; 00:284a $e6 $70
    ld   L, A                                          ;; 00:284c $6f
    ld   H, $00                                        ;; 00:284d $26 $00
    ld   DE, wDA1C                                     ;; 00:284f $11 $1c $da
    add  HL, DE                                        ;; 00:2852 $19
    ld   A, [HL+]                                      ;; 00:2853 $2a
    ld   E, A                                          ;; 00:2854 $5f
    ld   D, [HL]                                       ;; 00:2855 $56
    ret                                                ;; 00:2856 $c9

call_00_2857:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2857 $fa $00 $da
    rrca                                               ;; 00:285a $0f
    and  A, $70                                        ;; 00:285b $e6 $70
    ld   L, A                                          ;; 00:285d $6f
    ld   H, $00                                        ;; 00:285e $26 $00
    ld   DE, wDA1E                                     ;; 00:2860 $11 $1e $da
    add  HL, DE                                        ;; 00:2863 $19
    ld   A, [HL+]                                      ;; 00:2864 $2a
    ld   E, A                                          ;; 00:2865 $5f
    ld   D, [HL]                                       ;; 00:2866 $56
    ret                                                ;; 00:2867 $c9

call_00_2868:
    ld   a,[wDA00_CurrentObjectAddr]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA1C
    add  hl,bc
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_2879:
    ld   a,[wDA00_CurrentObjectAddr]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA1E
    add  hl,bc
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_288c_ObjectUnkAndSet14:
    ld   C, $00                                        ;; 00:288a $0e $00

call_00_288c_ObjectSet14:
    ld   H, $d8                                        ;; 00:288c $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:288e $fa $00 $da
    or   A, $14                                        ;; 00:2891 $f6 $14
    ld   L, A                                          ;; 00:2893 $6f
    ld   [HL], C                                       ;; 00:2894 $71
    ret                                                ;; 00:2895 $c9

call_00_2896_ObjectSet15:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$15
    ld   l,a
    ld   [hl],c
    ret  

call_00_28a0_ObjectGet15:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$15
    ld   l,a
    ld   a,[hl]
    ret  

call_00_28aa_ObjectSet16:
    ld   H, $d8                                        ;; 00:28aa $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:28ac $fa $00 $da
    or   A, $16                                        ;; 00:28af $f6 $16
    ld   L, A                                          ;; 00:28b1 $6f
    ld   [HL], C                                       ;; 00:28b2 $71
    ret                                                ;; 00:28b3 $c9

call_00_28b4_ObjectGet16:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$16
    ld   l,a
    ld   a,[hl]
    ret  

call_00_28be_ObjectGet1B:
    ld   H, $d8                                        ;; 00:28be $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:28c0 $fa $00 $da
    or   A, $1b                                        ;; 00:28c3 $f6 $1b
    ld   L, A                                          ;; 00:28c5 $6f
    ld   A, [HL]                                       ;; 00:28c6 $7e
    ret                                                ;; 00:28c7 $c9

call_00_28c8_ObjectSet1B:
    ld   H, $d8                                        ;; 00:28c8 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:28ca $fa $00 $da
    or   A, $1b                                        ;; 00:28cd $f6 $1b
    ld   L, A                                          ;; 00:28cf $6f
    ld   [HL], C                                       ;; 00:28d0 $71
    ret                                                ;; 00:28d1 $c9

call_00_28d2_ObjectGet1D:
    ld   H, $d8                                        ;; 00:28d2 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:28d4 $fa $00 $da
    or   A, $1d                                        ;; 00:28d7 $f6 $1d
    ld   L, A                                          ;; 00:28d9 $6f
    ld   A, [HL]                                       ;; 00:28da $7e
    ret                                                ;; 00:28db $c9

call_00_28dc_ObjectSet1D:
    ld   H, $d8                                        ;; 00:28dc $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:28de $fa $00 $da
    or   A, $1d                                        ;; 00:28e1 $f6 $1d
    ld   L, A                                          ;; 00:28e3 $6f
    ld   [HL], C                                       ;; 00:28e4 $71
    ret                                                ;; 00:28e5 $c9

call_00_28e6_ObjectCheckIf1BIsZero:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1B
    ld   l,a
    ld   a,[hl]
    and  a
    ret  

call_00_28f1_ObjectCheckIf1DIsZero:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1D
    ld   l,a
    ld   a,[hl]
    and  a
    ret  

call_00_28fc_ObjectUpdate19:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$19
    ld   l,a
    ld   a,[hl]
    inc  [hl]
    and  a,$03
    ld   l,a
    ld   h,$00
    add  hl,de
    ld   c,[hl]

call_00_290d_ObjectSetTimer1A:
    ld   H, $d8                                        ;; 00:290d $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:290f $fa $00 $da
    or   A, $1a                                        ;; 00:2912 $f6 $1a
    ld   L, A                                          ;; 00:2914 $6f
    ld   [HL], C                                       ;; 00:2915 $71
    ret                                                ;; 00:2916 $c9

call_00_2917_ObjectCheckIfTimer1AIsZero:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1A
    ld   l,a
    ld   a,[hl]
    and  a
    ret  

call_00_2922_ObjectTimer1ACountdown:
    ld   H, $d8                                        ;; 00:2922 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2924 $fa $00 $da
    or   A, $1a                                        ;; 00:2927 $f6 $1a
    ld   L, A                                          ;; 00:2929 $6f
    ld   A, [HL]                                       ;; 00:292a $7e
    and  A, A                                          ;; 00:292b $a7
    ret  Z                                             ;; 00:292c $c8
    dec  [HL]                                          ;; 00:292d $35
    ld   A, [HL]                                       ;; 00:292e $7e
    ret                                                ;; 00:292f $c9

call_00_2930_ObjectSetId:
    ld   H, $d8                                        ;; 00:2930 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2932 $fa $00 $da
    or   A, $00                                        ;; 00:2935 $f6 $00
    ld   L, A                                          ;; 00:2937 $6f
    ld   [HL], C                                       ;; 00:2938 $71
    ret                                                ;; 00:2939 $c9

call_00_293a_ObjectGetId:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$00
    ld   l,a
    ld   a,[hl]
    ret  

call_00_2944_ObjectSet12:
    ld   H, $d8                                        ;; 00:2944 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2946 $fa $00 $da
    or   A, $12                                        ;; 00:2949 $f6 $12
    ld   L, A                                          ;; 00:294b $6f
    ld   [HL], C                                       ;; 00:294c $71
    ret                                                ;; 00:294d $c9

call_00_294e_ObjectSet13:
    ld   H, $d8                                        ;; 00:294e $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2950 $fa $00 $da
    or   A, $13                                        ;; 00:2953 $f6 $13
    ld   L, A                                          ;; 00:2955 $6f
    ld   [HL], C                                       ;; 00:2956 $71
    ret                                                ;; 00:2957 $c9

call_00_2958_ObjectSetFacingDirection:
    ld   H, $d8                                        ;; 00:2958 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:295a $fa $00 $da
    or   A, $0d                                        ;; 00:295d $f6 $0d
    ld   L, A                                          ;; 00:295f $6f
    ld   [HL], C                                       ;; 00:2960 $71
    ret                                                ;; 00:2961 $c9

call_00_2962_ObjectGetActionId:
    ld   H, $d8                                        ;; 00:2962 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2964 $fa $00 $da
    or   A, $01                                        ;; 00:2967 $f6 $01
    ld   L, A                                          ;; 00:2969 $6f
    ld   A, [HL]                                       ;; 00:296a $7e
    ret                                                ;; 00:296b $c9

call_00_296c_ObjectGet9:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$09
    ld   l,a
    ld   a,[hl]
    ret  

call_00_2976_ObjectGetFacingDirection:
    ld   H, $d8                                        ;; 00:2976 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2978 $fa $00 $da
    or   A, $0d                                        ;; 00:297b $f6 $0d
    ld   L, A                                          ;; 00:297d $6f
    ld   A, [HL]                                       ;; 00:297e $7e
    ret                                                ;; 00:297f $c9

call_00_2980_ObjectSet19:
    ld   H, $d8                                        ;; 00:2980 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2982 $fa $00 $da
    or   A, $19                                        ;; 00:2985 $f6 $19
    ld   L, A                                          ;; 00:2987 $6f
    ld   [HL], C                                       ;; 00:2988 $71
    ret                                                ;; 00:2989 $c9

call_00_298a_ObjectGet19:
    ld   H, $d8                                        ;; 00:298a $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:298c $fa $00 $da
    or   A, $19                                        ;; 00:298f $f6 $19
    ld   L, A                                          ;; 00:2991 $6f
    ld   A, [HL]                                       ;; 00:2992 $7e
    and  A, A                                          ;; 00:2993 $a7
    ret                                                ;; 00:2994 $c9

call_00_2995_ObjectGetActionId:
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$01
    ld   l,a
    ld   a,[hl]
    ret  

call_00_299f_ObjectFlipFacingDirection:
    ld   H, $d8                                        ;; 00:299f $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:29a1 $fa $00 $da
    or   A, $0d                                        ;; 00:29a4 $f6 $0d
    ld   L, A                                          ;; 00:29a6 $6f
    ld   A, [HL]                                       ;; 00:29a7 $7e
    xor  A, $20                                        ;; 00:29a8 $ee $20
    ld   [HL], A                                       ;; 00:29aa $77
    ret                                                ;; 00:29ab $c9

call_00_29ac:
    call call_00_2a68
    call call_00_2976_ObjectGetFacingDirection
    ld   hl,wDA12
    cp   [hl]
    ret  

call_00_29b7:
    ld   h,$D8
    ld   l,$40
label29BB:
    ld   a,[hl]
    cp   c
    jr   z,call_00_29C8
    ld   a,l
    add  a,$20
    ld   l,a
    jr   nz,label29BB
    ld   c,$FF
    ret  

call_00_29C8:
    ld   a,l
    or   a,$01
    ld   l,a
    ld   c,[hl]
    ret  

call_00_29ce:
    ld   H, $d8                                        ;; 00:29ce $26 $d8
    ld   L, $40                                        ;; 00:29d0 $2e $40
.jr_00_29d2:
    ld   A, [HL]                                       ;; 00:29d2 $7e
    cp   A, C                                          ;; 00:29d3 $b9
    ret  Z                                             ;; 00:29d4 $c8
    ld   A, L                                          ;; 00:29d5 $7d
    add  A, $20                                        ;; 00:29d6 $c6 $20
    ld   L, A                                          ;; 00:29d8 $6f
    jr   NZ, .jr_00_29d2                               ;; 00:29d9 $20 $f7
    ld   A, $01                                        ;; 00:29db $3e $01
    and  A, A                                          ;; 00:29dd $a7
    ret                                                ;; 00:29de $c9
    db   $26, $d8, $fa, $00, $da, $f6, $0d, $6f        ;; 00:29df ????????
    db   $cb, $fe, $c9, $26, $d8, $fa, $00, $da        ;; 00:29e7 ????????
    db   $f6, $0d, $6f, $cb, $be, $c9                  ;; 00:29ef ??????

call_00_29f5:
    ld   H, $d8                                        ;; 00:29f5 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:29f7 $fa $00 $da
    or   A, $05                                        ;; 00:29fa $f6 $05
    ld   L, A                                          ;; 00:29fc $6f
    ld   A, [HL]                                       ;; 00:29fd $7e
    res  4, [HL]                                       ;; 00:29fe $cb $a6
    bit  4, A                                          ;; 00:2a00 $cb $67
    ret                                                ;; 00:2a02 $c9

call_00_2a03:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2a03 $fa $00 $da
    rlca                                               ;; 00:2a06 $07
    rlca                                               ;; 00:2a07 $07
    rlca                                               ;; 00:2a08 $07
    and  A, $07                                        ;; 00:2a09 $e6 $07
    ld   L, A                                          ;; 00:2a0b $6f
    ld   H, $00                                        ;; 00:2a0c $26 $00
    ld   DE, wDA01                                     ;; 00:2a0e $11 $01 $da
    add  HL, DE                                        ;; 00:2a11 $19
    ld   [HL], $00                                     ;; 00:2a12 $36 $00
    ret                                                ;; 00:2a14 $c9

call_00_2a15:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2a15 $fa $00 $da
    rrca                                               ;; 00:2a18 $0f
    and  A, $70                                        ;; 00:2a19 $e6 $70
    ld   L, A                                          ;; 00:2a1b $6f
    ld   H, $00                                        ;; 00:2a1c $26 $00
    ld   DE, wDA1C                                     ;; 00:2a1e $11 $1c $da
    add  HL, DE                                        ;; 00:2a21 $19
    ld   A, [HL+]                                      ;; 00:2a22 $2a
    ld   E, A                                          ;; 00:2a23 $5f
    ld   A, [HL+]                                      ;; 00:2a24 $2a
    ld   D, A                                          ;; 00:2a25 $57
    ld   A, [HL+]                                      ;; 00:2a26 $2a
    ld   C, A                                          ;; 00:2a27 $4f
    ld   A, [HL+]                                      ;; 00:2a28 $2a
    ld   B, A                                          ;; 00:2a29 $47
    ld   HL, wDA14                                     ;; 00:2a2a $21 $14 $da
    ld   A, E                                          ;; 00:2a2d $7b
    sub  A, [HL]                                       ;; 00:2a2e $96
    inc  HL                                            ;; 00:2a2f $23
    ld   A, D                                          ;; 00:2a30 $7a
    sbc  A, [HL]                                       ;; 00:2a31 $9e
    ret  C                                             ;; 00:2a32 $d8
    inc  HL                                            ;; 00:2a33 $23
    ld   A, [HL+]                                      ;; 00:2a34 $2a
    sub  A, C                                          ;; 00:2a35 $91
    ld   A, [HL]                                       ;; 00:2a36 $7e
    sbc  A, B                                          ;; 00:2a37 $98
    ret  C                                             ;; 00:2a38 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2a39 $fa $00 $da
    rrca                                               ;; 00:2a3c $0f
    and  A, $70                                        ;; 00:2a3d $e6 $70
    ld   L, A                                          ;; 00:2a3f $6f
    ld   H, $00                                        ;; 00:2a40 $26 $00
    ld   DE, wDA20                                     ;; 00:2a42 $11 $20 $da
    add  HL, DE                                        ;; 00:2a45 $19
    ld   A, [HL+]                                      ;; 00:2a46 $2a
    ld   E, A                                          ;; 00:2a47 $5f
    ld   A, [HL+]                                      ;; 00:2a48 $2a
    ld   D, A                                          ;; 00:2a49 $57
    ld   A, [HL+]                                      ;; 00:2a4a $2a
    ld   C, A                                          ;; 00:2a4b $4f
    ld   A, [HL+]                                      ;; 00:2a4c $2a
    ld   B, A                                          ;; 00:2a4d $47
    ld   HL, wDA18                                     ;; 00:2a4e $21 $18 $da
    ld   A, E                                          ;; 00:2a51 $7b
    sub  A, [HL]                                       ;; 00:2a52 $96
    inc  HL                                            ;; 00:2a53 $23
    ld   A, D                                          ;; 00:2a54 $7a
    sbc  A, [HL]                                       ;; 00:2a55 $9e
    ret  C                                             ;; 00:2a56 $d8
    inc  HL                                            ;; 00:2a57 $23
    ld   A, [HL+]                                      ;; 00:2a58 $2a
    sub  A, C                                          ;; 00:2a59 $91
    ld   A, [HL]                                       ;; 00:2a5a $7e
    sbc  A, B                                          ;; 00:2a5b $98
    ret                                                ;; 00:2a5c $c9

call_00_2a5d:
    ld   H, $d8                                        ;; 00:2a5d $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2a5f $fa $00 $da
    or   A, $05                                        ;; 00:2a62 $f6 $05
    ld   L, A                                          ;; 00:2a64 $6f
    bit  2, [HL]                                       ;; 00:2a65 $cb $56
    ret                                                ;; 00:2a67 $c9

call_00_2a68:
    ld   C, $00                                        ;; 00:2a68 $0e $00
    ld   H, $d8                                        ;; 00:2a6a $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2a6c $fa $00 $da
    or   A, $0e                                        ;; 00:2a6f $f6 $0e
    ld   L, A                                          ;; 00:2a71 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2a72 $fa $0e $d8
    sub  A, [HL]                                       ;; 00:2a75 $96
    ld   E, A                                          ;; 00:2a76 $5f
    inc  HL                                            ;; 00:2a77 $23
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:2a78 $fa $0f $d8
    sbc  A, [HL]                                       ;; 00:2a7b $9e
    ld   D, A                                          ;; 00:2a7c $57
    jr   NC, .jr_00_2a88                               ;; 00:2a7d $30 $09
    xor  A, A                                          ;; 00:2a7f $af
    sub  A, E                                          ;; 00:2a80 $93
    ld   E, A                                          ;; 00:2a81 $5f
    ld   A, $00                                        ;; 00:2a82 $3e $00
    sbc  A, D                                          ;; 00:2a84 $9a
    ld   D, A                                          ;; 00:2a85 $57
    ld   C, $20                                        ;; 00:2a86 $0e $20
.jr_00_2a88:
    ld   A, D                                          ;; 00:2a88 $7a
    and  A, A                                          ;; 00:2a89 $a7
    ld   A, E                                          ;; 00:2a8a $7b
    jr   Z, .jr_00_2a8f                                ;; 00:2a8b $28 $02
    ld   A, $ff                                        ;; 00:2a8d $3e $ff
.jr_00_2a8f:
    ld   [wDA11], A                                    ;; 00:2a8f $ea $11 $da
    ld   B, A                                          ;; 00:2a92 $47
    ld   A, C                                          ;; 00:2a93 $79
    ld   [wDA12], A                                    ;; 00:2a94 $ea $12 $da
    ret                                                ;; 00:2a97 $c9

    db   $d5, $cd, $0f, $23, $69, $26, $00, $29        ;; 00:2a98 ????????
    db   $5d, $54, $29, $29, $19, $d1, $19, $fa        ;; 00:2aa0 ????????
    db   $0e, $d8, $96, $5f, $23, $fa, $0f, $d8        ;; 00:2aa8 ????????
    db   $9e, $57, $23, $7e, $83, $5f, $7a, $ce        ;; 00:2ab0 ????????
    db   $00, $c0, $2a, $87, $57, $7b, $ba, $d0        ;; 00:2ab8 ????????
    db   $fa, $10, $d8, $96, $5f, $23, $fa, $11        ;; 00:2ac0 ????????
    db   $d8, $9e, $57, $23, $7e, $83, $5f, $7a        ;; 00:2ac8 ????????
    db   $ce, $00, $c0, $2a, $87, $57, $7b, $ba        ;; 00:2ad0 ????????
    db   $d0, $16, $d8, $fa, $00, $da, $f6, $1a        ;; 00:2ad8 ????????
    db   $5f, $2a, $12, $13, $2a, $12, $13, $af        ;; 00:2ae0 ????????
    db   $12, $13, $2a, $12, $13, $af, $12, $7e        ;; 00:2ae8 ????????
    db   $ea, $d6, $da, $3e, $02, $21, $ac, $72        ;; 00:2af0 ????????
    db   $cd, $dd, $0e, $c9                            ;; 00:2af8 ????

call_00_2afc:
    ld   H, $d8                                        ;; 00:2afc $26 $d8
    ld   A, $40                                        ;; 00:2afe $3e $40
    ld   D, $00                                        ;; 00:2b00 $16 $00
.jr_00_2b02:
    ld   L, A                                          ;; 00:2b02 $6f
    ld   A, [HL]                                       ;; 00:2b03 $7e
    inc  A                                             ;; 00:2b04 $3c
    jr   NZ, .jr_00_2b08                               ;; 00:2b05 $20 $01
    ld   D, L                                          ;; 00:2b07 $55
.jr_00_2b08:
    ld   A, L                                          ;; 00:2b08 $7d
    add  A, $20                                        ;; 00:2b09 $c6 $20
    jr   NZ, .jr_00_2b02                               ;; 00:2b0b $20 $f5
    ld   A, D                                          ;; 00:2b0d $7a
    and  A, A                                          ;; 00:2b0e $a7
    ret                                                ;; 00:2b0f $c9

call_00_2b10:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b10 $fa $00 $da
    rlca                                               ;; 00:2b13 $07
    rlca                                               ;; 00:2b14 $07
    rlca                                               ;; 00:2b15 $07
    and  A, $07                                        ;; 00:2b16 $e6 $07
    ld   L, A                                          ;; 00:2b18 $6f
    ld   H, $00                                        ;; 00:2b19 $26 $00
    ld   DE, wDA01                                     ;; 00:2b1b $11 $01 $da
    add  HL, DE                                        ;; 00:2b1e $19
    ld   B, [HL]                                       ;; 00:2b1f $46
    ld   H, $d8                                        ;; 00:2b20 $26 $d8
    ld   A, $40                                        ;; 00:2b22 $3e $40
.jr_00_2b24:
    ld   L, A                                          ;; 00:2b24 $6f
    ld   A, [HL]                                       ;; 00:2b25 $7e
    cp   A, C                                          ;; 00:2b26 $b9
    jr   NZ, .jr_00_2b31                               ;; 00:2b27 $20 $08
    ld   A, L                                          ;; 00:2b29 $7d
    or   A, $1f                                        ;; 00:2b2a $f6 $1f
    ld   L, A                                          ;; 00:2b2c $6f
    ld   A, [HL]                                       ;; 00:2b2d $7e
    cp   A, B                                          ;; 00:2b2e $b8
    jr   Z, .jr_00_2b39                                ;; 00:2b2f $28 $08
.jr_00_2b31:
    ld   A, L                                          ;; 00:2b31 $7d
    and  A, $e0                                        ;; 00:2b32 $e6 $e0
    add  A, $20                                        ;; 00:2b34 $c6 $20
    jr   NZ, .jr_00_2b24                               ;; 00:2b36 $20 $ec
    ret                                                ;; 00:2b38 $c9
.jr_00_2b39:
    ld   A, $01                                        ;; 00:2b39 $3e $01
    and  A, A                                          ;; 00:2b3b $a7
    ret                                                ;; 00:2b3c $c9

call_00_2b3d:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b3d $fa $00 $da
    push AF                                            ;; 00:2b40 $f5
    ld   A, $20                                        ;; 00:2b41 $3e $20
.jr_00_2b43:
    ld   [wDA00_CurrentObjectAddr], A                                    ;; 00:2b43 $ea $00 $da
    or   A, $00                                        ;; 00:2b46 $f6 $00
    ld   L, A                                          ;; 00:2b48 $6f
    ld   H, $d8                                        ;; 00:2b49 $26 $d8
    ld   A, [HL]                                       ;; 00:2b4b $7e
    cp   A, $ff                                        ;; 00:2b4c $fe $ff
    call NZ, call_00_2b5d                              ;; 00:2b4e $c4 $5d $2b
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b51 $fa $00 $da
    add  A, $20                                        ;; 00:2b54 $c6 $20
    jr   NZ, .jr_00_2b43                               ;; 00:2b56 $20 $eb
    pop  AF                                            ;; 00:2b58 $f1
    ld   [wDA00_CurrentObjectAddr], A                                    ;; 00:2b59 $ea $00 $da
    ret                                                ;; 00:2b5c $c9

call_00_2b5d:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b5d $fa $00 $da
    or   A, $00                                        ;; 00:2b60 $f6 $00
    ld   L, A                                          ;; 00:2b62 $6f
    ld   H, $d8                                        ;; 00:2b63 $26 $d8
    ld   [HL], $ff                                     ;; 00:2b65 $36 $ff
    ld   A, L                                          ;; 00:2b67 $7d
    rlca                                               ;; 00:2b68 $07
    rlca                                               ;; 00:2b69 $07
    rlca                                               ;; 00:2b6a $07
    and  A, $07                                        ;; 00:2b6b $e6 $07
    ld   L, A                                          ;; 00:2b6d $6f
    ld   H, $00                                        ;; 00:2b6e $26 $00
    ld   DE, wDA01                                     ;; 00:2b70 $11 $01 $da
    add  HL, DE                                        ;; 00:2b73 $19
    ld   L, [HL]                                       ;; 00:2b74 $6e
    ld   H, $d7                                        ;; 00:2b75 $26 $d7
    res  6, [HL]                                       ;; 00:2b77 $cb $b6
    ret                                                ;; 00:2b79 $c9

jp_00_2b7a:
    call call_00_2b80                                  ;; 00:2b7a $cd $80 $2b
    jp   jp_00_2b94                                    ;; 00:2b7d $c3 $94 $2b

call_00_2b80:
    ld   H, $d8                                        ;; 00:2b80 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b82 $fa $00 $da
    or   A, $00                                        ;; 00:2b85 $f6 $00
    ld   L, A                                          ;; 00:2b87 $6f
    ld   [HL], $ff                                     ;; 00:2b88 $36 $ff
    ret                                                ;; 00:2b8a $c9

call_00_2b8b:
    call call_00_35e8                                  ;; 00:2b8b $cd $e8 $35
    bit  6, A                                          ;; 00:2b8e $cb $77
    jr   Z, jp_00_2b94                                 ;; 00:2b90 $28 $02
    jr   call_00_2ba9                                  ;; 00:2b92 $18 $15

jp_00_2b94:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b94 $fa $00 $da
    rlca                                               ;; 00:2b97 $07
    rlca                                               ;; 00:2b98 $07
    rlca                                               ;; 00:2b99 $07
    and  A, $07                                        ;; 00:2b9a $e6 $07
    ld   L, A                                          ;; 00:2b9c $6f
    ld   H, $00                                        ;; 00:2b9d $26 $00
    ld   DE, wDA01                                     ;; 00:2b9f $11 $01 $da
    add  HL, DE                                        ;; 00:2ba2 $19
    ld   L, [HL]                                       ;; 00:2ba3 $6e
    ld   H, $d7                                        ;; 00:2ba4 $26 $d7
    ld   [HL], $00                                     ;; 00:2ba6 $36 $00
    ret                                                ;; 00:2ba8 $c9

call_00_2ba9:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2ba9 $fa $00 $da
    rlca                                               ;; 00:2bac $07
    rlca                                               ;; 00:2bad $07
    rlca                                               ;; 00:2bae $07
    and  A, $07                                        ;; 00:2baf $e6 $07
    ld   L, A                                          ;; 00:2bb1 $6f
    ld   H, $00                                        ;; 00:2bb2 $26 $00
    ld   DE, wDA01                                     ;; 00:2bb4 $11 $01 $da
    add  HL, DE                                        ;; 00:2bb7 $19
    ld   L, [HL]                                       ;; 00:2bb8 $6e
    ld   H, $d7                                        ;; 00:2bb9 $26 $d7
    ld   [HL], $50                                     ;; 00:2bbb $36 $50
    ret                                                ;; 00:2bbd $c9

jp_00_2bbe:
    call call_00_35e8                                  ;; 00:2bbe $cd $e8 $35
    cp   A, $ff                                        ;; 00:2bc1 $fe $ff
    jr   Z, jp_00_2b7a                                 ;; 00:2bc3 $28 $b5
    bit  6, A                                          ;; 00:2bc5 $cb $77
    jr   Z, jp_00_2b7a                                 ;; 00:2bc7 $28 $b1
    ld   C, $02                                        ;; 00:2bc9 $0e $02
    call call_00_2930_ObjectSetId                                  ;; 00:2bcb $cd $30 $29
    ld   C, $08                                        ;; 00:2bce $0e $08
    call call_00_288c_ObjectSet14                                  ;; 00:2bd0 $cd $8c $28
    ld   C, $12                                        ;; 00:2bd3 $0e $12
    call call_00_2944_ObjectSet12                                  ;; 00:2bd5 $cd $44 $29
    ld   C, $12                                        ;; 00:2bd8 $0e $12
    call call_00_294e_ObjectSet13                                  ;; 00:2bda $cd $4e $29
    ld   C, $00                                        ;; 00:2bdd $0e $00
    call call_00_2958_ObjectSetFacingDirection                                  ;; 00:2bdf $cd $58 $29
    ld   C, $01                                        ;; 00:2be2 $0e $01
    call call_00_28aa_ObjectSet16                                  ;; 00:2be4 $cd $aa $28
    ld   C, $00                                        ;; 00:2be7 $0e $00
    call call_00_2299                                  ;; 00:2be9 $cd $99 $22
    call call_00_2ba9                                  ;; 00:2bec $cd $a9 $2b
    xor  A, A                                          ;; 00:2bef $af
    ld   [wDAD6_ReturnBank], A                                    ;; 00:2bf0 $ea $d6 $da
    ld   A, $02                                        ;; 00:2bf3 $3e $02
    ld   HL, entry_02_72ac                              ;; 00:2bf5 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:2bf8 $cd $dd $0e
    ld   HL, $2c01                                     ;; 00:2bfb $21 $01 $2c
    jp   call_00_2c20                                  ;; 00:2bfe $c3 $20 $2c
    db   $00, $00, $00, $00, $60, $02, $9c, $03        ;; 00:2c01 ........

call_00_2c09:
    add  A, $06                                        ;; 00:2c09 $c6 $06
    ld   C, A                                          ;; 00:2c0b $4f
    jp   call_00_3792                                  ;; 00:2c0c $c3 $92 $37

call_00_2c0f:
    ld   a,[wDA00_CurrentObjectAddr]
    rlca 
    rlca 
    rlca 
    and  a,$07
    ld   l,a
    ld   h,$00
    ld   de,wDAAE_ObjectPaletteIds
    add  hl,de
    ld   [hl],c
    ret  

call_00_2c20:
    push HL                                            ;; 00:2c20 $e5
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2c21 $fa $00 $da
    rlca                                               ;; 00:2c24 $07
    rlca                                               ;; 00:2c25 $07
    rlca                                               ;; 00:2c26 $07
    and  A, $07                                        ;; 00:2c27 $e6 $07
    ld   L, A                                          ;; 00:2c29 $6f
    ld   H, $00                                        ;; 00:2c2a $26 $00
    ld   DE, wDAAE_ObjectPaletteIds                                     ;; 00:2c2c $11 $ae $da
    add  HL, DE                                        ;; 00:2c2f $19
    ld   L, [HL]                                       ;; 00:2c30 $6e
    ld   H, $00                                        ;; 00:2c31 $26 $00
    add  HL, HL                                        ;; 00:2c33 $29
    add  HL, HL                                        ;; 00:2c34 $29
    add  HL, HL                                        ;; 00:2c35 $29
    ld   DE, wDD2A_ObjectPalettes                                     ;; 00:2c36 $11 $2a $dd
    add  HL, DE                                        ;; 00:2c39 $19
    ld   E, L                                          ;; 00:2c3a $5d
    ld   D, H                                          ;; 00:2c3b $54
    pop  HL                                            ;; 00:2c3c $e1
    ld   BC, $08                                       ;; 00:2c3d $01 $08 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:2c40 $c3 $6e $07

data_00_2c43_ParticleBufferPointerTable:
    dw   wDDC4_ParticleSlot1Buffer, wDDD7_ParticleSlot2Buffer
    dw   wDDEA_ParticleSlot3Buffer, wDDFD_ParticleSlot4Buffer        ;; 00:2c43 ????????
    dw   wDE10_ParticleSlot5Buffer, wDE23_ParticleSlot6Buffer
    dw   wDE36_ParticleSlot7Buffer, wDE49_ParticleSlot8Buffer                                         ;; 00:2c51 pP

call_00_2c53_ParticleSlot_GetBufferPtr:
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2c53 $fa $00 $da
    rlca                                               ;; 00:2c56 $07
    rlca                                               ;; 00:2c57 $07
    rlca                                               ;; 00:2c58 $07
    and  A, $07                                        ;; 00:2c59 $e6 $07
    ld   L, A                                          ;; 00:2c5b $6f
    ld   H, $00                                        ;; 00:2c5c $26 $00
    add  HL, HL                                        ;; 00:2c5e $29
    ld   DE, data_00_2c43_ParticleBufferPointerTable                                     ;; 00:2c5f $11 $43 $2c
    add  HL, DE                                        ;; 00:2c62 $19
    ld   E, [HL]                                       ;; 00:2c63 $5e
    inc  HL                                            ;; 00:2c64 $23
    ld   D, [HL]                                       ;; 00:2c65 $56
    ret                                                ;; 00:2c66 $c9

call_00_2c67_Particle_InitBurst:
    call call_00_2c53_ParticleSlot_GetBufferPtr                                  ;; 00:2c67 $cd $53 $2c
    ld   A, $40                                        ;; 00:2c6a $3e $40
    ld   [DE], A                                       ;; 00:2c6c $12
    inc  DE                                            ;; 00:2c6d $13
    ld   HL, .data_00_2c77_Particle_DefaultBurstTemplate                                     ;; 00:2c6e $21 $77 $2c
    ld   BC, $12                                       ;; 00:2c71 $01 $12 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:2c74 $c3 $6e $07
.data_00_2c77_Particle_DefaultBurstTemplate:
    db   $0b, $00, $00, $f5, $00, $00, $10, $00        ;; 00:2c77 ........
    db   $00, $00, $00, $00, $0b, $00, $00, $0b        ;; 00:2c7f ........
    db   $00, $00                                      ;; 00:2c87 ..

call_00_2c89_Particle_UpdateBurst:
    call call_00_2c53_ParticleSlot_GetBufferPtr                                  ;; 00:2c89 $cd $53 $2c
    ld   L, E                                          ;; 00:2c8c $6b
    ld   H, D                                          ;; 00:2c8d $62
    ld   A, [HL]                                       ;; 00:2c8e $7e
    and  A, A                                          ;; 00:2c8f $a7
    jr   Z, .jr_00_2c93                                ;; 00:2c90 $28 $01
    dec  [HL]                                          ;; 00:2c92 $35
.jr_00_2c93:
    ld   A, [HL+]                                      ;; 00:2c93 $2a
    push AF                                            ;; 00:2c94 $f5
    ld   B, $03                                        ;; 00:2c95 $06 $03
.jr_00_2c97:
    ld   C, [HL]                                       ;; 00:2c97 $4e
    inc  HL                                            ;; 00:2c98 $23
    ld   A, [HL]                                       ;; 00:2c99 $7e
    and  A, $0f                                        ;; 00:2c9a $e6 $0f
    add  A, C                                          ;; 00:2c9c $81
    ld   [HL+], A                                      ;; 00:2c9d $22
    sra  A                                             ;; 00:2c9e $cb $2f
    sra  A                                             ;; 00:2ca0 $cb $2f
    sra  A                                             ;; 00:2ca2 $cb $2f
    sra  A                                             ;; 00:2ca4 $cb $2f
    add  A, [HL]                                       ;; 00:2ca6 $86
    ld   [HL+], A                                      ;; 00:2ca7 $22
    ld   C, [HL]                                       ;; 00:2ca8 $4e
    inc  HL                                            ;; 00:2ca9 $23
    ld   A, [HL]                                       ;; 00:2caa $7e
    and  A, $0f                                        ;; 00:2cab $e6 $0f
    add  A, C                                          ;; 00:2cad $81
    ld   [HL+], A                                      ;; 00:2cae $22
    sra  A                                             ;; 00:2caf $cb $2f
    sra  A                                             ;; 00:2cb1 $cb $2f
    sra  A                                             ;; 00:2cb3 $cb $2f
    sra  A                                             ;; 00:2cb5 $cb $2f
    add  A, [HL]                                       ;; 00:2cb7 $86
    ld   [HL+], A                                      ;; 00:2cb8 $22
    dec  B                                             ;; 00:2cb9 $05
    jr   NZ, .jr_00_2c97                               ;; 00:2cba $20 $db
    pop  AF                                            ;; 00:2cbc $f1
    and  A, A                                          ;; 00:2cbd $a7
    ret                                                ;; 00:2cbe $c9
