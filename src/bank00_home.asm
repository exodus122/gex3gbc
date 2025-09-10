SECTION "bank00", ROM0[$0000]
    db   $d9                                           ;; 00:0000 ?

SECTION "isrVBlank", ROM0[$0040]

isrVBlank:
    jp   jp_00_0b25                                    ;; 00:0040 $c3 $25 $0b

SECTION "isrLCDC", ROM0[$0048]

isrLCDC:
    jp   wD9A0                                         ;; 00:0048 $c3 $a0 $d9

SECTION "isrTimer", ROM0[$0050]

isrTimer:
    reti                                               ;; 00:0050 $d9

SECTION "isrSerial", ROM0[$0058]

isrSerial:
    reti                                               ;; 00:0058 $d9

SECTION "isrJoypad", ROM0[$0060]

isrJoypad:
    reti                                               ;; 00:0060 $d9

SECTION "entry", ROM0[$0100]

entry:
    nop                                                ;; 00:0100 $00
    jp   .jp_00_0150                                   ;; 00:0101 $c3 $50 $01
    ds   $30                                           ;; 00:0104
    db   "POCKET GEX3AXGE"                             ;; 00:0134
    db   CART_COMPATIBLE_GBC                           ;; 00:0143
    db   $34, $46                                      ;; 00:0144 ??
    db   CART_INDICATOR_GB                             ;; 00:0146
    db   CART_ROM_MBC5, CART_ROM_2048KB, CART_SRAM_NONE ;; 00:0147
    db   CART_DEST_NON_JAPANESE, $33, $00              ;; 00:014a $01 $33 $00
    ds   3                                             ;; 00:014d

.jp_00_0150:
    di                                                 ;; 00:0150 $f3
    ld   SP, hFFFE                                     ;; 00:0151 $31 $fe $ff
    push AF                                            ;; 00:0154 $f5
    cp   A, $11                                        ;; 00:0155 $fe $11
    jr   NZ, .jr_00_015d                               ;; 00:0157 $20 $04
    ld   A, $01                                        ;; 00:0159 $3e $01
    ldh  [rSVBK], A                                    ;; 00:015b $e0 $70
.jr_00_015d:
    ldh  A, [rLY]                                      ;; 00:015d $f0 $44
    cp   A, $91                                        ;; 00:015f $fe $91
    jr   NZ, .jr_00_015d                               ;; 00:0161 $20 $fa
    ldh  A, [rLCDC]                                    ;; 00:0163 $f0 $40
    and  A, $7f                                        ;; 00:0165 $e6 $7f
    ldh  [rLCDC], A                                    ;; 00:0167 $e0 $40
    xor  A, A                                          ;; 00:0169 $af
    ld   [MBC1SRamEnable], A                                    ;; 00:016a $ea $01 $00
    ld   [MBC1SRamBankingMode], A                                    ;; 00:016d $ea $01 $60
    ld   HL, wC000_BgMapTileIds                                     ;; 00:0170 $21 $00 $c0
    ld   DE, $c001                                     ;; 00:0173 $11 $01 $c0 ; wC000_BgMapTileIds
    ld   BC, $1fff                                     ;; 00:0176 $01 $ff $1f
    ld   [HL], $00                                     ;; 00:0179 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:017b $cd $6e $07
    xor  A, A                                          ;; 00:017e $af
    ldh  [rSCX], A                                     ;; 00:017f $e0 $43
    ldh  [rSCY], A                                     ;; 00:0181 $e0 $42
    ld   A, $07                                        ;; 00:0183 $3e $07
    ld   [wDADB], A                                    ;; 00:0185 $ea $db $da
    ldh  [rWX], A                                      ;; 00:0188 $e0 $4b
    ld   A, $80                                        ;; 00:018a $3e $80
    ld   [wDADC], A                                    ;; 00:018c $ea $dc $da
    ldh  [rWY], A                                      ;; 00:018f $e0 $4a
    pop  AF                                            ;; 00:0191 $f1
    cp   A, $11                                        ;; 00:0192 $fe $11
    jr   Z, .jr_00_01d2                                ;; 00:0194 $28 $3c
    ld   A, $07                                        ;; 00:0196 $3e $07
    ld   [MBC1RomBank], A                                    ;; 00:0198 $ea $01 $20
    swap A                                             ;; 00:019b $cb $37
    rrca                                               ;; 00:019d $0f
    and  A, $00                                        ;; 00:019e $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:01a0 $ea $01 $40
    ld   HL, $5b00                                     ;; 00:01a3 $21 $00 $5b
    ld   DE, $8000                                     ;; 00:01a6 $11 $00 $80
    ld   BC, $a00                                      ;; 00:01a9 $01 $00 $0a
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:01ac $cd $6e $07
    ld   HL, $9800                                     ;; 00:01af $21 $00 $98
    ld   DE, $6500                                     ;; 00:01b2 $11 $00 $65
    ld   C, $12                                        ;; 00:01b5 $0e $12
.jr_00_01b7:
    ld   B, $14                                        ;; 00:01b7 $06 $14
.jr_00_01b9:
    ld   A, [DE]                                       ;; 00:01b9 $1a
    ld   [HL+], A                                      ;; 00:01ba $22
    inc  DE                                            ;; 00:01bb $13
    dec  B                                             ;; 00:01bc $05
    jr   NZ, .jr_00_01b9                               ;; 00:01bd $20 $fa
    push BC                                            ;; 00:01bf $c5
    ld   BC, $0c                                       ;; 00:01c0 $01 $0c $00
    add  HL, BC                                        ;; 00:01c3 $09
    pop  BC                                            ;; 00:01c4 $c1
    dec  C                                             ;; 00:01c5 $0d
    jr   NZ, .jr_00_01b7                               ;; 00:01c6 $20 $ef
    ld   A, $d5                                        ;; 00:01c8 $3e $d5
    ldh  [rLCDC], A                                    ;; 00:01ca $e0 $40
    ld   A, $93                                        ;; 00:01cc $3e $93
    ldh  [rBGP], A                                     ;; 00:01ce $e0 $47
.jr_00_01d0:
    jr   .jr_00_01d0                                   ;; 00:01d0 $18 $fe
.jr_00_01d2:
    ld   A, $00                                        ;; 00:01d2 $3e $00
    ldh  [rVBK], A                                     ;; 00:01d4 $e0 $4f
    call call_00_0e81                                  ;; 00:01d6 $cd $81 $0e
    ld   HL, $e29                                      ;; 00:01d9 $21 $29 $0e
    ld   DE, hFF80                                     ;; 00:01dc $11 $80 $ff
    ld   BC, $0a                                       ;; 00:01df $01 $0a $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:01e2 $cd $6e $07
    ld   A, $01                                        ;; 00:01e5 $3e $01
.jr_00_01e7:
    push AF                                            ;; 00:01e7 $f5
    ldh  [rVBK], A                                     ;; 00:01e8 $e0 $4f
    ld   HL, $8000                                     ;; 00:01ea $21 $00 $80
    ld   DE, $8001                                     ;; 00:01ed $11 $01 $80
    ld   BC, $1fff                                     ;; 00:01f0 $01 $ff $1f
    ld   [HL], $00                                     ;; 00:01f3 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:01f5 $cd $6e $07
    pop  AF                                            ;; 00:01f8 $f1
    dec  A                                             ;; 00:01f9 $3d
    bit  7, A                                          ;; 00:01fa $cb $7f
    jr   Z, .jr_00_01e7                                ;; 00:01fc $28 $e9
    ld   HL, wDAD3                                     ;; 00:01fe $21 $d3 $da
    ld   DE, wDAC3                                     ;; 00:0201 $11 $c3 $da
    ld   A, $01                                        ;; 00:0204 $3e $01
    ld   [HL], E                                       ;; 00:0206 $73
    inc  HL                                            ;; 00:0207 $23
    ld   [HL], D                                       ;; 00:0208 $72
    ld   [wDAD5], A                                    ;; 00:0209 $ea $d5 $da
    ld   [DE], A                                       ;; 00:020c $12
    call call_00_0f25                                  ;; 00:020d $cd $25 $0f
    ld   HL, rKEY1                                     ;; 00:0210 $21 $4d $ff
    bit  7, [HL]                                       ;; 00:0213 $cb $7e
    jr   NZ, .jr_00_0224                               ;; 00:0215 $20 $0d
    set  0, [HL]                                       ;; 00:0217 $cb $c6
    xor  A, A                                          ;; 00:0219 $af
    ldh  [rIF], A                                      ;; 00:021a $e0 $0f
    ldh  [rIE], A                                      ;; 00:021c $e0 $ff
    ld   A, $30                                        ;; 00:021e $3e $30
    ldh  [rP1], A                                      ;; 00:0220 $e0 $00
    stop                                               ;; 00:0222 $10 $00
.jr_00_0224:
    ld   A, $00                                        ;; 00:0224 $3e $00
    call call_00_0c1b                                  ;; 00:0226 $cd $1b $0c
    xor  A, A                                          ;; 00:0229 $af
    ldh  [rIF], A                                      ;; 00:022a $e0 $0f
    ld   A, $08                                        ;; 00:022c $3e $08
    ldh  [rSTAT], A                                    ;; 00:022e $e0 $41
    ld   A, $03                                        ;; 00:0230 $3e $03
    ldh  [rIE], A                                      ;; 00:0232 $e0 $ff
    ld   A, $04                                        ;; 00:0234 $3e $04
    call call_00_0eee_SwitchBank                                  ;; 00:0236 $cd $ee $0e
    call call_04_4000                                  ;; 00:0239 $cd $00 $40
    call call_00_0f08_SwitchBank2                                  ;; 00:023c $cd $08 $0f
    xor  A, A                                          ;; 00:023f $af
    ld   [wDE60], A                                    ;; 00:0240 $ea $60 $de
    ld   [wDE5E], A                                    ;; 00:0243 $ea $5e $de
    ld   [wDE5F], A                                    ;; 00:0246 $ea $5f $de
    ld   A, $ff                                        ;; 00:0249 $3e $ff
    ld   [wDE5C], A                                    ;; 00:024b $ea $5c $de
    ld   [wDE5D], A                                    ;; 00:024e $ea $5d $de
    ld   A, $c7                                        ;; 00:0251 $3e $c7
    ld   [wDAD8], A                                    ;; 00:0253 $ea $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0256 $e0 $40
    ei                                                 ;; 00:0258 $fb
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:0259 $cd $92 $0b
    ld   [wDAD6_ReturnBank], A                                    ;; 00:025c $ea $d6 $da
    ld   A, $01                                        ;; 00:025f $3e $01
    ld   HL, call_01_4f7e                              ;; 00:0261 $21 $7e $4f
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0264 $cd $dd $0e
.jp_00_0267:
    ld   A, $00                                        ;; 00:0267 $3e $00
    call call_00_0fa2                                  ;; 00:0269 $cd $a2 $0f
    ld   A, $00                                        ;; 00:026c $3e $00
    call call_00_0fd7                                  ;; 00:026e $cd $d7 $0f
    ld   A, $11                                        ;; 00:0271 $3e $11
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0273 $ea $d6 $da
    ld   A, $01                                        ;; 00:0276 $3e $01
    ld   HL, call_01_4000                              ;; 00:0278 $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:027b $cd $dd $0e
    ld   A, $12                                        ;; 00:027e $3e $12
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0280 $ea $d6 $da
    ld   A, $01                                        ;; 00:0283 $3e $01
    ld   HL, call_01_4000                              ;; 00:0285 $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0288 $cd $dd $0e
    ld   A, $14                                        ;; 00:028b $3e $14
    ld   [wDAD6_ReturnBank], A                                    ;; 00:028d $ea $d6 $da
    ld   A, $01                                        ;; 00:0290 $3e $01
    ld   HL, call_01_4000                              ;; 00:0292 $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0295 $cd $dd $0e
    ld   A, $13                                        ;; 00:0298 $3e $13
    ld   [wDAD6_ReturnBank], A                                    ;; 00:029a $ea $d6 $da
    ld   A, $01                                        ;; 00:029d $3e $01
    ld   HL, call_01_4000                              ;; 00:029f $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:02a2 $cd $dd $0e
    ld   A, $0f                                        ;; 00:02a5 $3e $0f
    ld   [wDAD6_ReturnBank], A                                    ;; 00:02a7 $ea $d6 $da
    ld   A, $01                                        ;; 00:02aa $3e $01
    ld   HL, call_01_4000                              ;; 00:02ac $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:02af $cd $dd $0e
.jp_00_02b2:
    ld   A, $01                                        ;; 00:02b2 $3e $01
    call call_00_0fa2                                  ;; 00:02b4 $cd $a2 $0f
    ld   A, $00                                        ;; 00:02b7 $3e $00
    ld   [wDAD6_ReturnBank], A                                    ;; 00:02b9 $ea $d6 $da
    ld   A, $01                                        ;; 00:02bc $3e $01
    ld   HL, call_01_4000                              ;; 00:02be $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:02c1 $cd $dd $0e
    cp   A, $20                                        ;; 00:02c4 $fe $20
    jr   Z, .jr_00_02ed                                ;; 00:02c6 $28 $25
    cp   A, $10                                        ;; 00:02c8 $fe $10
    jr   NZ, .jp_00_02b2                               ;; 00:02ca $20 $e6
.jp_00_02cc:
    ld   A, $04                                        ;; 00:02cc $3e $04
    ld   [wDC4E], A                                    ;; 00:02ce $ea $4e $dc
    xor  A, A                                          ;; 00:02d1 $af
    ld   [wDCAF], A                                    ;; 00:02d2 $ea $af $dc
    ld   [wDC4F], A                                    ;; 00:02d5 $ea $4f $dc
    ld   HL, wDC5C                                     ;; 00:02d8 $21 $5c $dc
    ld   B, $0c                                        ;; 00:02db $06 $0c
    xor  A, A                                          ;; 00:02dd $af
.jr_00_02de:
    ld   [HL+], A                                      ;; 00:02de $22
    dec  B                                             ;; 00:02df $05
    jr   NZ, .jr_00_02de                               ;; 00:02e0 $20 $fc
    ld   [wDAD6_ReturnBank], A                                    ;; 00:02e2 $ea $d6 $da
    ld   A, $01                                        ;; 00:02e5 $3e $01
    ld   HL, call_01_4f8c                              ;; 00:02e7 $21 $8c $4f
    call call_00_0edd_CallAltBankFunc                                  ;; 00:02ea $cd $dd $0e
.jr_00_02ed:
    xor  A, A                                          ;; 00:02ed $af
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:02ee $ea $6c $db
    ld   [wDC5B], A                                    ;; 00:02f1 $ea $5b $dc
    ld   [wDC69], A                                    ;; 00:02f4 $ea $69 $dc
    ld   [wDB6A], A                                    ;; 00:02f7 $ea $6a $db
    call call_00_0e3b                                  ;; 00:02fa $cd $3b $0e
    call call_00_0e62                                  ;; 00:02fd $cd $62 $0e
    ld   C, $00                                        ;; 00:0300 $0e $00
    call call_00_0a6a                                  ;; 00:0302 $cd $6a $0a
    ld   C, $01                                        ;; 00:0305 $0e $01
    call call_00_0a6a                                  ;; 00:0307 $cd $6a $0a
    ld   C, $02                                        ;; 00:030a $0e $02
    call call_00_0a6a                                  ;; 00:030c $cd $6a $0a
    ld   A, $e7                                        ;; 00:030f $3e $e7
    call call_00_0e33                                  ;; 00:0311 $cd $33 $0e
.jp_00_0314:
    ld   A, [wDB6A]                                    ;; 00:0314 $fa $6a $db
    and  A, $10                                        ;; 00:0317 $e6 $10
    jr   Z, .jr_00_0326                                ;; 00:0319 $28 $0b
    ld   [wDAD6_ReturnBank], A                                    ;; 00:031b $ea $d6 $da
    ld   A, $01                                        ;; 00:031e $3e $01
    ld   HL, $435e                                     ;; 00:0320 $21 $5e $43
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0323 $cd $dd $0e
.jr_00_0326:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0326 $ea $d6 $da
    ld   A, $03                                        ;; 00:0329 $3e $03
    ld   HL, call_03_6c89_CopyLevelData                              ;; 00:032b $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:032e $cd $dd $0e
    ld   A, [wDC4F]                                    ;; 00:0331 $fa $4f $dc
    add  A, $04                                        ;; 00:0334 $c6 $04
    ld   [wDC50], A                                    ;; 00:0336 $ea $50 $dc
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0339 $ea $d6 $da
    ld   A, $01                                        ;; 00:033c $3e $01
    ld   HL, $432b                                     ;; 00:033e $21 $2b $43
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0341 $cd $dd $0e
    call call_00_0e3b                                  ;; 00:0344 $cd $3b $0e
    call call_00_2f85                                  ;; 00:0347 $cd $85 $2f
    call call_00_2ff8                                  ;; 00:034a $cd $f8 $2f
    call call_00_0595                                  ;; 00:034d $cd $95 $05
    call call_00_1ea0_UpdateMain                                  ;; 00:0350 $cd $a0 $1e
    xor  A, A                                          ;; 00:0353 $af
    ld   [wDC69], A                                    ;; 00:0354 $ea $69 $dc
.jp_00_0357:
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:0357 $fa $1e $dc
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:035a $ea $6c $db
    ld   [wDAD6_ReturnBank], A                                    ;; 00:035d $ea $d6 $da
    ld   A, $03                                        ;; 00:0360 $3e $03
    ld   HL, call_03_6c89_CopyLevelData                              ;; 00:0362 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0365 $cd $dd $0e
    xor  A, A                                          ;; 00:0368 $af
    ld   [wDC51], A                                    ;; 00:0369 $ea $51 $dc
    ld   [wDCA9], A                                    ;; 00:036c $ea $a9 $dc
    ld   [wDCAA], A                                    ;; 00:036f $ea $aa $dc
    ld   [wDCAB], A                                    ;; 00:0372 $ea $ab $dc
    ld   [wDC89], A                                    ;; 00:0375 $ea $89 $dc
    ld   A, [wDC4F]                                    ;; 00:0378 $fa $4f $dc
    add  A, $04                                        ;; 00:037b $c6 $04
    ld   [wDC50], A                                    ;; 00:037d $ea $50 $dc
    ld   A, $00                                        ;; 00:0380 $3e $00
    ld   [wDC78], A                                    ;; 00:0382 $ea $78 $dc
    call call_00_0e3b                                  ;; 00:0385 $cd $3b $0e
    call call_00_2f85                                  ;; 00:0388 $cd $85 $2f
    call call_00_2ff8                                  ;; 00:038b $cd $f8 $2f
.jp_00_038e:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:038e $ea $d6 $da
    ld   A, $03                                        ;; 00:0391 $3e $03
    ld   HL, call_03_6c89_CopyLevelData                              ;; 00:0393 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0396 $cd $dd $0e
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:0399 $fa $1e $dc
    cp   A, $07                                        ;; 00:039c $fe $07
    jr   NZ, .jr_00_03b6                               ;; 00:039e $20 $16
    ld   A, [wDC78]                                    ;; 00:03a0 $fa $78 $dc
    cp   A, $00                                        ;; 00:03a3 $fe $00
    ld   A, $23                                        ;; 00:03a5 $3e $23
    jr   Z, .jr_00_03e8                                ;; 00:03a7 $28 $3f
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:03a9 $fa $6c $db
    cp   A, $07                                        ;; 00:03ac $fe $07
    ld   A, $24                                        ;; 00:03ae $3e $24
    jr   Z, .jr_00_03e8                                ;; 00:03b0 $28 $36
    ld   A, $01                                        ;; 00:03b2 $3e $01
    jr   .jr_00_03e8                                   ;; 00:03b4 $18 $32
.jr_00_03b6:
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:03b6 $fa $1e $dc
    cp   A, $08                                        ;; 00:03b9 $fe $08
    ld   A, $2f                                        ;; 00:03bb $3e $2f
    jr   Z, .jr_00_03e8                                ;; 00:03bd $28 $29
    ld   A, [wDC1F]                                    ;; 00:03bf $fa $1f $dc
    cp   A, $01                                        ;; 00:03c2 $fe $01
    jr   Z, .jr_00_03d6                                ;; 00:03c4 $28 $10
    ld   A, [wDC78]                                    ;; 00:03c6 $fa $78 $dc
    cp   A, $00                                        ;; 00:03c9 $fe $00
    jr   Z, .jr_00_03e8                                ;; 00:03cb $28 $1b
    ld   A, [wD801]                                    ;; 00:03cd $fa $01 $d8
    sub  A, $3c                                        ;; 00:03d0 $d6 $3c
    jr   C, .jr_00_03eb                                ;; 00:03d2 $38 $17
    jr   .jr_00_03e8                                   ;; 00:03d4 $18 $12
.jr_00_03d6:
    ld   A, [wDC78]                                    ;; 00:03d6 $fa $78 $dc
    cp   A, $00                                        ;; 00:03d9 $fe $00
    ld   A, $3c                                        ;; 00:03db $3e $3c
    jr   Z, .jr_00_03e8                                ;; 00:03dd $28 $09
    ld   A, [wD801]                                    ;; 00:03df $fa $01 $d8
    cp   A, $3c                                        ;; 00:03e2 $fe $3c
    jr   NC, .jr_00_03eb                               ;; 00:03e4 $30 $05
    add  A, $3c                                        ;; 00:03e6 $c6 $3c
.jr_00_03e8:
    ld   [wDC78], A                                    ;; 00:03e8 $ea $78 $dc
.jr_00_03eb:
    xor  A, A                                          ;; 00:03eb $af
    ld   [wDC29], A                                    ;; 00:03ec $ea $29 $dc
    ld   A, $01                                        ;; 00:03ef $3e $01
    ld   [wDCA7], A                                    ;; 00:03f1 $ea $a7 $dc
    call call_00_04fb                                  ;; 00:03f4 $cd $fb $04
    ld   [wDAD6_ReturnBank], A                                    ;; 00:03f7 $ea $d6 $da
    ld   A, $03                                        ;; 00:03fa $3e $03
    ld   HL, $647c                                     ;; 00:03fc $21 $7c $64
    call call_00_0edd_CallAltBankFunc                                  ;; 00:03ff $cd $dd $0e
    call call_00_1056_LoadMap                                  ;; 00:0402 $cd $56 $10
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0405 $ea $d6 $da
    ld   A, $02                                        ;; 00:0408 $3e $02
    ld   HL, $708f                                     ;; 00:040a $21 $8f $70
    call call_00_0edd_CallAltBankFunc                                  ;; 00:040d $cd $dd $0e
    call call_00_0513                                  ;; 00:0410 $cd $13 $05
    xor  A, A                                          ;; 00:0413 $af
    ld   [wDB6A], A                                    ;; 00:0414 $ea $6a $db
    ld   [wDCDB], A                                    ;; 00:0417 $ea $db $dc
    ld   A, $ff                                        ;; 00:041a $3e $ff
    ld   [wDC8A], A                                    ;; 00:041c $ea $8a $dc
    jr   .jp_00_0443                                   ;; 00:041f $18 $22
.jp_00_0421:
    call call_00_0595                                  ;; 00:0421 $cd $95 $05
    call call_00_04fb                                  ;; 00:0424 $cd $fb $04
    call call_00_1056_LoadMap                                  ;; 00:0427 $cd $56 $10
    ld   [wDAD6_ReturnBank], A                                    ;; 00:042a $ea $d6 $da
    ld   A, $02                                        ;; 00:042d $3e $02
    ld   HL, $7142                                     ;; 00:042f $21 $42 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0432 $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0435 $ea $d6 $da
    ld   A, $03                                        ;; 00:0438 $3e $03
    ld   HL, $68d9                                     ;; 00:043a $21 $d9 $68
    call call_00_0edd_CallAltBankFunc                                  ;; 00:043d $cd $dd $0e
    call call_00_0513                                  ;; 00:0440 $cd $13 $05
.jp_00_0443:
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:0443 $cd $92 $0b
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0446 $fa $d7 $da
    cp   A, $0f                                        ;; 00:0449 $fe $0f
    jp   Z, .jp_00_0267                                ;; 00:044b $ca $67 $02
    ld   HL, wDB6A                                     ;; 00:044e $21 $6a $db
    bit  2, [HL]                                       ;; 00:0451 $cb $56
    jr   Z, .jr_00_045e                                ;; 00:0453 $28 $09
    call call_00_1633                                  ;; 00:0455 $cd $33 $16
    call call_00_2b3d                                  ;; 00:0458 $cd $3d $2b
    jp   .jp_00_038e                                   ;; 00:045b $c3 $8e $03
.jr_00_045e:
    ld   HL, wDB6A                                     ;; 00:045e $21 $6a $db
    bit  4, [HL]                                       ;; 00:0461 $cb $66
    jp   NZ, .jp_00_0314                               ;; 00:0463 $c2 $14 $03
    ld   HL, wDB6A                                     ;; 00:0466 $21 $6a $db
    bit  1, [HL]                                       ;; 00:0469 $cb $4e
    jr   Z, .jr_00_0487                                ;; 00:046b $28 $1a
    ld   HL, wDC4E                                     ;; 00:046d $21 $4e $dc
    dec  [HL]                                          ;; 00:0470 $35
    jp   NZ, .jp_00_0357                               ;; 00:0471 $c2 $57 $03
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0474 $ea $d6 $da
    ld   A, $01                                        ;; 00:0477 $3e $01
    ld   HL, $42fd                                     ;; 00:0479 $21 $fd $42
    call call_00_0edd_CallAltBankFunc                                  ;; 00:047c $cd $dd $0e
    cp   A, $40                                        ;; 00:047f $fe $40
    jp   Z, .jp_00_02cc                                ;; 00:0481 $ca $cc $02
    jp   .jp_00_02b2                                   ;; 00:0484 $c3 $b2 $02
.jr_00_0487:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0487 $ea $d6 $da
    ld   A, $02                                        ;; 00:048a $3e $02
    ld   HL, $5541                                     ;; 00:048c $21 $41 $55
    call call_00_0edd_CallAltBankFunc                                  ;; 00:048f $cd $dd $0e
    and  A, $08                                        ;; 00:0492 $e6 $08
    jr   NZ, .jr_00_04d8                               ;; 00:0494 $20 $42
    call call_00_0f80                                  ;; 00:0496 $cd $80 $0f
    jr   Z, .jr_00_04d8                                ;; 00:0499 $28 $3d
    ld   A, $00                                        ;; 00:049b $3e $00
    call call_00_0fa2                                  ;; 00:049d $cd $a2 $0f
    ld   A, $00                                        ;; 00:04a0 $3e $00
    call call_00_0fd7                                  ;; 00:04a2 $cd $d7 $0f
    ld   [wDAD6_ReturnBank], A                                    ;; 00:04a5 $ea $d6 $da
    ld   A, $02                                        ;; 00:04a8 $3e $02
    ld   HL, $7132                                     ;; 00:04aa $21 $32 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:04ad $cd $dd $0e
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:04b0 $fa $1e $dc
    and  A, A                                          ;; 00:04b3 $a7
    ld   A, $0b                                        ;; 00:04b4 $3e $0b
    jr   Z, .jr_00_04ba                                ;; 00:04b6 $28 $02
    ld   A, $0d                                        ;; 00:04b8 $3e $0d
.jr_00_04ba:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:04ba $ea $d6 $da
    ld   A, $01                                        ;; 00:04bd $3e $01
    ld   HL, call_01_4000                              ;; 00:04bf $21 $00 $40
    call call_00_0edd_CallAltBankFunc                                  ;; 00:04c2 $cd $dd $0e
    cp   A, $60                                        ;; 00:04c5 $fe $60
    jp   NZ, .jp_00_0421                               ;; 00:04c7 $c2 $21 $04
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:04ca $fa $1e $dc
    and  A, A                                          ;; 00:04cd $a7
    jp   Z, .jp_00_02b2                                ;; 00:04ce $ca $b2 $02
    xor  A, A                                          ;; 00:04d1 $af
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:04d2 $ea $6c $db
    jp   .jp_00_0314                                   ;; 00:04d5 $c3 $14 $03
.jr_00_04d8:
    call call_00_05fd                                  ;; 00:04d8 $cd $fd $05
    call call_00_05c7                                  ;; 00:04db $cd $c7 $05
    ld   [wDAD6_ReturnBank], A                                    ;; 00:04de $ea $d6 $da
    ld   A, $02                                        ;; 00:04e1 $3e $02
    ld   HL, entry_02_7152_UpdateObjects                                     ;; 00:04e3 $21 $52 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:04e6 $cd $dd $0e
    call call_00_11c8_LoadBgMap                                  ;; 00:04e9 $cd $c8 $11
    call call_00_0fc8                                  ;; 00:04ec $cd $c8 $0f
    call call_00_150f                                  ;; 00:04ef $cd $0f $15
    call call_00_35fa                                  ;; 00:04f2 $cd $fa $35
    call call_00_08f8                                  ;; 00:04f5 $cd $f8 $08
    jp   .jp_00_0443                                   ;; 00:04f8 $c3 $43 $04

call_00_04fb:
    xor  A, A                                          ;; 00:04fb $af
    ld   [wDE5E], A                                    ;; 00:04fc $ea $5e $de
    ld   [wDE5F], A                                    ;; 00:04ff $ea $5f $de
    ld   A, $ff                                        ;; 00:0502 $3e $ff
    ld   [wDE5D], A                                    ;; 00:0504 $ea $5d $de
    call call_00_0e3b                                  ;; 00:0507 $cd $3b $0e
    call call_00_0e62                                  ;; 00:050a $cd $62 $0e
    ld   A, $e7                                        ;; 00:050d $3e $e7
    call call_00_0e33                                  ;; 00:050f $cd $33 $0e
    ret                                                ;; 00:0512 $c9

call_00_0513:
    ld   A, $7f                                        ;; 00:0513 $3e $7f
    call call_00_0eee_SwitchBank                                  ;; 00:0515 $cd $ee $0e
    ld   HL, wDB6C_CurrentLevelId                                     ;; 00:0518 $21 $6c $db
    ld   E, [HL]                                       ;; 00:051b $5e
    ld   D, $00                                        ;; 00:051c $16 $00
    ld   HL, $4000                                     ;; 00:051e $21 $00 $40
    add  HL, DE                                        ;; 00:0521 $19
    ld   E, [HL]                                       ;; 00:0522 $5e
    ld   HL, $403d                                     ;; 00:0523 $21 $3d $40
    add  HL, DE                                        ;; 00:0526 $19
    ld   A, [HL+]                                      ;; 00:0527 $2a
    ld   [wDABF_CurrentGexSpriteBank], A                                    ;; 00:0528 $ea $bf $da
    ld   A, [HL+]                                      ;; 00:052b $2a
    ld   H, [HL]                                       ;; 00:052c $66
    ld   L, A                                          ;; 00:052d $6f
    ld   A, [wD80A]                                    ;; 00:052e $fa $0a $d8
    ld   E, A                                          ;; 00:0531 $5f
    ld   D, $00                                        ;; 00:0532 $16 $00
    add  HL, DE                                        ;; 00:0534 $19
    add  HL, DE                                        ;; 00:0535 $19
    add  HL, DE                                        ;; 00:0536 $19
    ld   C, [HL]                                       ;; 00:0537 $4e
    inc  HL                                            ;; 00:0538 $23
    ld   A, [HL+]                                      ;; 00:0539 $2a
    ld   H, [HL]                                       ;; 00:053a $66
    ld   L, A                                          ;; 00:053b $6f
    push HL                                            ;; 00:053c $e5
    ld   A, [wDABF_CurrentGexSpriteBank]                                    ;; 00:053d $fa $bf $da
    add  A, C                                          ;; 00:0540 $81
    ld   [wDABF_CurrentGexSpriteBank], A                                    ;; 00:0541 $ea $bf $da
    call call_00_0f08_SwitchBank2                                  ;; 00:0544 $cd $08 $0f
    ld   A, [wDABF_CurrentGexSpriteBank]                                    ;; 00:0547 $fa $bf $da
    call call_00_0eee_SwitchBank                                  ;; 00:054a $cd $ee $0e
    pop  HL                                            ;; 00:054d $e1
    ld   A, [HL+]                                      ;; 00:054e $2a
    ld   [wDAC2], A                                    ;; 00:054f $ea $c2 $da
    inc  HL                                            ;; 00:0552 $23
    inc  HL                                            ;; 00:0553 $23
    ld   A, [HL+]                                      ;; 00:0554 $2a
    ld   [wDAC0], A                                    ;; 00:0555 $ea $c0 $da
    ld   A, [HL+]                                      ;; 00:0558 $2a
    ld   [wDAC1], A                                    ;; 00:0559 $ea $c1 $da
    call call_00_0f08_SwitchBank2                                  ;; 00:055c $cd $08 $0f
    ld   HL, wDB66                                     ;; 00:055f $21 $66 $db
    set  0, [HL]                                       ;; 00:0562 $cb $c6
    ld   A, $05                                        ;; 00:0564 $3e $05
    call call_00_0c10                                  ;; 00:0566 $cd $10 $0c
    ld   HL, wDB69                                     ;; 00:0569 $21 $69 $db
    ld   [HL], $17                                     ;; 00:056c $36 $17
.jr_00_056e:
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:056e $cd $92 $0b
    call call_00_08f8                                  ;; 00:0571 $cd $f8 $08
    ld   A, [wDB66]                                    ;; 00:0574 $fa $66 $db
    and  A, $ff                                        ;; 00:0577 $e6 $ff
    jr   NZ, .jr_00_056e                               ;; 00:0579 $20 $f3
    ld   A, [wDB69]                                    ;; 00:057b $fa $69 $db
    and  A, $2f                                        ;; 00:057e $e6 $2f
    jr   NZ, .jr_00_056e                               ;; 00:0580 $20 $ec
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0582 $ea $d6 $da
    ld   A, $03                                        ;; 00:0585 $3e $03
    ld   HL, $5ec1                                     ;; 00:0587 $21 $c1 $5e
    call call_00_0edd_CallAltBankFunc                                  ;; 00:058a $cd $dd $0e
    ld   A, $01                                        ;; 00:058d $3e $01
    ld   [wDD6A], A                                    ;; 00:058f $ea $6a $dd
    jp   call_00_0b92_UpdateVRAMTiles                                  ;; 00:0592 $c3 $92 $0b

call_00_0595:
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:0595 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:0598 $6e
    ld   H, $00                                        ;; 00:0599 $26 $00
    ld   DE, $5a3                                      ;; 00:059b $11 $a3 $05
    add  HL, DE                                        ;; 00:059e $19
    ld   A, [HL]                                       ;; 00:059f $7e
    jp   call_00_0fa2                                  ;; 00:05a0 $c3 $a2 $0f
    db   $04, $02, $12, $05, $03, $14, $17, $16        ;; 00:05a3 ..??????
    db   $16, $11, $11, $18                            ;; 00:05ab ????

call_00_05af_LoadMapPalettes:
    ld   A, [wDC13_BgPaletteBank]                                    ;; 00:05af $fa $13 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:05b2 $cd $ee $0e
    ld   HL, wDC14_BgPaletteBankOffset                                     ;; 00:05b5 $21 $14 $dc
    ld   A, [HL+]                                      ;; 00:05b8 $2a
    ld   H, [HL]                                       ;; 00:05b9 $66
    ld   L, A                                          ;; 00:05ba $6f
    ld   DE, wDCEA_BgPalettes                                     ;; 00:05bb $11 $ea $dc
    ld   BC, $40                                       ;; 00:05be $01 $40 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:05c1 $cd $6e $07
    jp   call_00_0f08_SwitchBank2                                  ;; 00:05c4 $c3 $08 $0f

call_00_05c7:
    ld   A, [wDB6D]                                    ;; 00:05c7 $fa $6d $db
    and  A, A                                          ;; 00:05ca $a7
    ret  Z                                             ;; 00:05cb $c8
    ld   HL, wDCD2                                     ;; 00:05cc $21 $d2 $dc
    bit  7, [HL]                                       ;; 00:05cf $cb $7e
    jr   NZ, .jr_00_05f1                               ;; 00:05d1 $20 $1e
    ld   HL, wDB6F                                     ;; 00:05d3 $21 $6f $db
    dec  [HL]                                          ;; 00:05d6 $35
    ret  NZ                                            ;; 00:05d7 $c0
    ld   [HL], $3c                                     ;; 00:05d8 $36 $3c
    ld   HL, wDB69                                     ;; 00:05da $21 $69 $db
    set  2, [HL]                                       ;; 00:05dd $cb $d6
    ld   HL, wDB6E                                     ;; 00:05df $21 $6e $db
    ld   A, [HL]                                       ;; 00:05e2 $7e
    sub  A, $01                                        ;; 00:05e3 $d6 $01
    ld   [HL], A                                       ;; 00:05e5 $77
    ret  NC                                            ;; 00:05e6 $d0
    ld   [HL], $00                                     ;; 00:05e7 $36 $00
    ld   HL, wDB6A                                     ;; 00:05e9 $21 $6a $db
    set  4, [HL]                                       ;; 00:05ec $cb $e6
    set  5, [HL]                                       ;; 00:05ee $cb $ee
    ret                                                ;; 00:05f0 $c9
.jr_00_05f1:
    ld   C, $1c                                        ;; 00:05f1 $0e $1c
    call call_00_29ce                                  ;; 00:05f3 $cd $ce $29
    ret  Z                                             ;; 00:05f6 $c8
    ld   HL, wDB6A                                     ;; 00:05f7 $21 $6a $db
    set  4, [HL]                                       ;; 00:05fa $cb $e6
    ret                                                ;; 00:05fc $c9

call_00_05fd:
    call call_00_0f8b                                  ;; 00:05fd $cd $8b $0f
    ret  Z                                             ;; 00:0600 $c8
    ld   A, [wDC51]                                    ;; 00:0601 $fa $51 $dc
    and  A, A                                          ;; 00:0604 $a7
    ret  Z                                             ;; 00:0605 $c8
    ld   A, [wD801]                                    ;; 00:0606 $fa $01 $d8
    cp   A, $01                                        ;; 00:0609 $fe $01
    ret  C                                             ;; 00:060b $d8
    cp   A, $03                                        ;; 00:060c $fe $03
    jr   C, .jr_00_0616                                ;; 00:060e $38 $06
    cp   A, $3d                                        ;; 00:0610 $fe $3d
    ret  C                                             ;; 00:0612 $d8
    cp   A, $3f                                        ;; 00:0613 $fe $3f
    ret  NC                                            ;; 00:0615 $d0
.jr_00_0616:
    ld   A, $08                                        ;; 00:0616 $3e $08
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0618 $ea $d6 $da
    ld   A, $02                                        ;; 00:061b $3e $02
    ld   HL, $54f9                                     ;; 00:061d $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0620 $cd $dd $0e
    ret                                                ;; 00:0623 $c9
    db   $21, $51, $dc, $4e, $77, $79, $fe, $03        ;; 00:0624 ????????
    db   $28, $54, $fe, $04, $ca, $4b, $07, $fe        ;; 00:062c ????????
    db   $01, $28, $35, $fe, $05, $28, $1a, $fe        ;; 00:0634 ????????
    db   $02, $c0, $af, $ea, $aa, $dc, $ea, $ab        ;; 00:063c ????????
    db   $dc, $3e, $14, $ea, $a9, $dc, $3e, $3c        ;; 00:0644 ????????
    db   $ea, $a8, $dc, $3e, $02, $ea, $ae, $dc        ;; 00:064c ????????
    db   $c9, $af, $ea, $aa, $dc, $ea, $a9, $dc        ;; 00:0654 ????????
    db   $3e, $14, $ea, $ab, $dc, $3e, $3c, $ea        ;; 00:065c ????????
    db   $a8, $dc, $3e, $01, $ea, $ae, $dc, $c9        ;; 00:0664 ????????
    db   $af, $ea, $a9, $dc, $ea, $ab, $dc, $3e        ;; 00:066c ????????
    db   $14, $ea, $aa, $dc, $3e, $3c, $ea, $a8        ;; 00:0674 ????????
    db   $dc, $af, $ea, $ae, $dc, $c9, $fa, $4f        ;; 00:067c ????????
    db   $dc, $c6, $04, $21, $50, $dc, $be, $c8        ;; 00:0684 ????????
    db   $34, $21, $69, $db, $cb, $ce, $c9             ;; 00:068c ???????

jp_00_0693:
    ld   HL, wDABE                                     ;; 00:0693 $21 $be $da
    bit  7, [HL]                                       ;; 00:0696 $cb $7e
    jr   NZ, .jr_00_06ba                               ;; 00:0698 $20 $20
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:069a $fa $6c $db
    cp   A, $07                                        ;; 00:069d $fe $07
    ld   A, $2e                                        ;; 00:069f $3e $2e
    jr   Z, .jr_00_06ae                                ;; 00:06a1 $28 $0b
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:06a3 $fa $6c $db
    cp   A, $08                                        ;; 00:06a6 $fe $08
    ld   A, $3b                                        ;; 00:06a8 $3e $3b
    jr   Z, .jr_00_06ae                                ;; 00:06aa $28 $02
    ld   A, $1a                                        ;; 00:06ac $3e $1a
.jr_00_06ae:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:06ae $ea $d6 $da
    ld   A, $02                                        ;; 00:06b1 $3e $02
    ld   HL, $54f9                                     ;; 00:06b3 $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:06b6 $cd $dd $0e
    ret                                                ;; 00:06b9 $c9
.jr_00_06ba:
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:06ba $fa $6c $db
    cp   A, $07                                        ;; 00:06bd $fe $07
    ld   A, $2a                                        ;; 00:06bf $3e $2a
    jr   Z, .jr_00_06ce                                ;; 00:06c1 $28 $0b
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:06c3 $fa $6c $db
    cp   A, $08                                        ;; 00:06c6 $fe $08
    ld   A, $37                                        ;; 00:06c8 $3e $37
    jr   Z, .jr_00_06ce                                ;; 00:06ca $28 $02
    ld   A, $0a                                        ;; 00:06cc $3e $0a
.jr_00_06ce:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:06ce $ea $d6 $da
    ld   A, $02                                        ;; 00:06d1 $3e $02
    ld   HL, data_03_54f9                             ;; 00:06d3 $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:06d6 $cd $dd $0e
    ret                                                ;; 00:06d9 $c9

jp_00_06da:
    ld   A, $1b                                        ;; 00:06da $3e $1b
    ld   [wDAD6_ReturnBank], A                                    ;; 00:06dc $ea $d6 $da
    ld   A, $02                                        ;; 00:06df $3e $02
    ld   HL, call_02_54f9                              ;; 00:06e1 $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:06e4 $cd $dd $0e
    ret                                                ;; 00:06e7 $c9

jp_00_06e8:
    ld   A, $13                                        ;; 00:06e8 $3e $13
    ld   [wDAD6_ReturnBank], A                                    ;; 00:06ea $ea $d6 $da
    ld   A, $02                                        ;; 00:06ed $3e $02
    ld   HL, $54f9                                     ;; 00:06ef $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:06f2 $cd $dd $0e
    ret                                                ;; 00:06f5 $c9

call_00_06f6:
    call call_00_0759                                  ;; 00:06f6 $cd $59 $07
    ret  NZ                                            ;; 00:06f9 $c0
    ld   A, $3c                                        ;; 00:06fa $3e $3c
    ld   [wDC7E], A                                    ;; 00:06fc $ea $7e $dc
    ld   HL, wDB69                                     ;; 00:06ff $21 $69 $db
    set  1, [HL]                                       ;; 00:0702 $cb $ce
    ld   A, $0a                                        ;; 00:0704 $3e $0a
    call call_00_0ff5                                  ;; 00:0706 $cd $f5 $0f
    ld   HL, wDC51                                     ;; 00:0709 $21 $51 $dc
    ld   A, [HL]                                       ;; 00:070c $7e
    and  A, A                                          ;; 00:070d $a7
    jr   Z, .jr_00_0713                                ;; 00:070e $28 $03
    ld   [HL], $00                                     ;; 00:0710 $36 $00
    ret                                                ;; 00:0712 $c9
.jr_00_0713:
    ld   A, [wDC50]                                    ;; 00:0713 $fa $50 $dc
    sub  A, $01                                        ;; 00:0716 $d6 $01
    jr   NC, .jr_00_071b                               ;; 00:0718 $30 $01
    xor  A, A                                          ;; 00:071a $af
.jr_00_071b:
    ld   [wDC50], A                                    ;; 00:071b $ea $50 $dc
    and  A, A                                          ;; 00:071e $a7
    jp   Z, jp_00_0693                                 ;; 00:071f $ca $93 $06
    ret                                                ;; 00:0722 $c9

call_00_0723:
    ld   HL, wDB69                                     ;; 00:0723 $21 $69 $db
    set  0, [HL]                                       ;; 00:0726 $cb $c6
    ld   A, $02                                        ;; 00:0728 $3e $02
    call call_00_0ff5                                  ;; 00:072a $cd $f5 $0f
    ld   HL, wDC68                                     ;; 00:072d $21 $68 $dc
    inc  [HL]                                          ;; 00:0730 $34
    ld   A, [HL]                                       ;; 00:0731 $7e
    cp   A, $32                                        ;; 00:0732 $fe $32
    jr   Z, .jr_00_074b                                ;; 00:0734 $28 $15
    cp   A, $64                                        ;; 00:0736 $fe $64
    ret  NZ                                            ;; 00:0738 $c0
    ld   A, $1e                                        ;; 00:0739 $3e $1e
    call call_00_0ff5                                  ;; 00:073b $cd $f5 $0f
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:073e $21 $1e $dc
    ld   L, [HL]                                       ;; 00:0741 $6e
    ld   H, $00                                        ;; 00:0742 $26 $00
    ld   DE, wDC5C                                     ;; 00:0744 $11 $5c $dc
    add  HL, DE                                        ;; 00:0747 $19
    set  3, [HL]                                       ;; 00:0748 $cb $de
    ret                                                ;; 00:074a $c9
.jr_00_074b:
    ld   HL, wDC4E                                     ;; 00:074b $21 $4e $dc
    ld   A, [HL]                                       ;; 00:074e $7e
    cp   A, $63                                        ;; 00:074f $fe $63
    ret  NC                                            ;; 00:0751 $d0
    inc  [HL]                                          ;; 00:0752 $34
    ld   HL, wDB69                                     ;; 00:0753 $21 $69 $db
    set  0, [HL]                                       ;; 00:0756 $cb $c6
    ret                                                ;; 00:0758 $c9

call_00_0759:
    ld   A, [wDC7E]                                    ;; 00:0759 $fa $7e $dc
    and  A, A                                          ;; 00:075c $a7
    ret  NZ                                            ;; 00:075d $c0
    ret                                                ;; 00:075e $c9

call_00_075f:
    push HL                                            ;; 00:075f $e5
    push DE                                            ;; 00:0760 $d5
    push BC                                            ;; 00:0761 $c5
    call call_00_0eee_SwitchBank                                  ;; 00:0762 $cd $ee $0e
    pop  BC                                            ;; 00:0765 $c1
    pop  DE                                            ;; 00:0766 $d1
    pop  HL                                            ;; 00:0767 $e1
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:0768 $cd $6e $07
    jp   call_00_0f08_SwitchBank2                                  ;; 00:076b $c3 $08 $0f

call_00_076e_CopyBCBytesFromHLToDE:
    ld   A, [HL+]                                      ;; 00:076e $2a
    ld   [DE], A                                       ;; 00:076f $12
    inc  DE                                            ;; 00:0770 $13
    dec  BC                                            ;; 00:0771 $0b
    ld   A, B                                          ;; 00:0772 $78
    or   A, C                                          ;; 00:0773 $b1
    jr   NZ, call_00_076e_CopyBCBytesFromHLToDE                              ;; 00:0774 $20 $f8
    ret                                                ;; 00:0776 $c9

call_00_0777:
    ld   L, A                                          ;; 00:0777 $6f
    ld   H, $00                                        ;; 00:0778 $26 $00
    add  HL, HL                                        ;; 00:077a $29
    add  HL, DE                                        ;; 00:077b $19
    ld   E, [HL]                                       ;; 00:077c $5e
    inc  HL                                            ;; 00:077d $23
    ld   H, [HL]                                       ;; 00:077e $66
    ld   L, E                                          ;; 00:077f $6b
    ret                                                ;; 00:0780 $c9

jp_00_0781:
    ld   A, [wDBB2]                                    ;; 00:0781 $fa $b2 $db
    call call_00_0eee_SwitchBank                                  ;; 00:0784 $cd $ee $0e
    ld   HL, wDBB7                                     ;; 00:0787 $21 $b7 $db
    ld   C, [HL]                                       ;; 00:078a $4e
    inc  HL                                            ;; 00:078b $23
    ld   B, [HL]                                       ;; 00:078c $46
    ld   HL, wDBB5                                     ;; 00:078d $21 $b5 $db
    ld   A, [HL+]                                      ;; 00:0790 $2a
    ld   H, [HL]                                       ;; 00:0791 $66
    ld   L, A                                          ;; 00:0792 $6f
    ld   A, C                                          ;; 00:0793 $79
    sub  A, $00                                        ;; 00:0794 $d6 $00
    ld   E, A                                          ;; 00:0796 $5f
    ld   A, B                                          ;; 00:0797 $78
    sbc  A, $10                                        ;; 00:0798 $de $10
    jr   C, .jr_00_07b2                                ;; 00:079a $38 $16
    ld   B, A                                          ;; 00:079c $47
    ld   C, E                                          ;; 00:079d $4b
    push HL                                            ;; 00:079e $e5
    ld   DE, $1000                                     ;; 00:079f $11 $00 $10
    add  HL, DE                                        ;; 00:07a2 $19
    ld   DE, wC000_BgMapTileIds                                     ;; 00:07a3 $11 $00 $c0
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07a6 $cd $6e $07
    ld   C, $0a                                        ;; 00:07a9 $0e $0a
    call call_00_0a6a                                  ;; 00:07ab $cd $6a $0a
    pop  HL                                            ;; 00:07ae $e1
    ld   BC, $1000                                     ;; 00:07af $01 $00 $10
.jr_00_07b2:
    ld   DE, wC000_BgMapTileIds                                     ;; 00:07b2 $11 $00 $c0
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07b5 $cd $6e $07
    ld   HL, wDBB3                                     ;; 00:07b8 $21 $b3 $db
    ld   A, [HL+]                                      ;; 00:07bb $2a
    ld   H, [HL]                                       ;; 00:07bc $66
    ld   L, A                                          ;; 00:07bd $6f
    ld   DE, wD400                                     ;; 00:07be $11 $00 $d4
    ld   BC, $168                                      ;; 00:07c1 $01 $68 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07c4 $cd $6e $07
    ld   A, [wDBB1]                                    ;; 00:07c7 $fa $b1 $db
    and  A, A                                          ;; 00:07ca $a7
    jr   Z, .jr_00_07d9                                ;; 00:07cb $28 $0c
    ld   DE, wD578                                     ;; 00:07cd $11 $78 $d5
    ld   BC, $168                                      ;; 00:07d0 $01 $68 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07d3 $cd $6e $07
    jp   call_00_0f08_SwitchBank2                                  ;; 00:07d6 $c3 $08 $0f
.jr_00_07d9:
    push HL                                            ;; 00:07d9 $e5
    ld   HL, wD400                                     ;; 00:07da $21 $00 $d4
    ld   DE, wD578                                     ;; 00:07dd $11 $78 $d5
    ld   BC, $168                                      ;; 00:07e0 $01 $68 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07e3 $cd $6e $07
    pop  DE                                            ;; 00:07e6 $d1
    ld   HL, wD578                                     ;; 00:07e7 $21 $78 $d5
    ld   BC, $168                                      ;; 00:07ea $01 $68 $01
.jr_00_07ed:
    push DE                                            ;; 00:07ed $d5
    ld   A, [HL]                                       ;; 00:07ee $7e
    add  A, E                                          ;; 00:07ef $83
    ld   E, A                                          ;; 00:07f0 $5f
    ld   A, $00                                        ;; 00:07f1 $3e $00
    adc  A, D                                          ;; 00:07f3 $8a
    ld   D, A                                          ;; 00:07f4 $57
    ld   A, [DE]                                       ;; 00:07f5 $1a
    ld   [HL+], A                                      ;; 00:07f6 $22
    pop  DE                                            ;; 00:07f7 $d1
    dec  BC                                            ;; 00:07f8 $0b
    ld   A, B                                          ;; 00:07f9 $78
    or   A, C                                          ;; 00:07fa $b1
    jr   NZ, .jr_00_07ed                               ;; 00:07fb $20 $f0
    jp   call_00_0f08_SwitchBank2                                  ;; 00:07fd $c3 $08 $0f

call_00_0800:
    push HL                                            ;; 00:0800 $e5
    push DE                                            ;; 00:0801 $d5
    push BC                                            ;; 00:0802 $c5
    push HL                                            ;; 00:0803 $e5
    ld   A, $1f                                        ;; 00:0804 $3e $1f
    call call_00_0eee_SwitchBank                                  ;; 00:0806 $cd $ee $0e
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:0809 $fa $6c $db
    ld   DE, $b01                                      ;; 00:080c $11 $01 $0b
    call call_00_0777                                  ;; 00:080f $cd $77 $07
    ld   DE, $300                                      ;; 00:0812 $11 $00 $03
    add  HL, DE                                        ;; 00:0815 $19
    ld   E, L                                          ;; 00:0816 $5d
    ld   D, H                                          ;; 00:0817 $54
    pop  HL                                            ;; 00:0818 $e1
    ld   C, $06                                        ;; 00:0819 $0e $06
.jr_00_081b:
    ld   B, $08                                        ;; 00:081b $06 $08
.jr_00_081d:
    ld   A, [DE]                                       ;; 00:081d $1a
    ld   [HL+], A                                      ;; 00:081e $22
    inc  DE                                            ;; 00:081f $13
    dec  B                                             ;; 00:0820 $05
    jr   NZ, .jr_00_081d                               ;; 00:0821 $20 $fa
    ld   A, L                                          ;; 00:0823 $7d
    add  A, $0c                                        ;; 00:0824 $c6 $0c
    ld   L, A                                          ;; 00:0826 $6f
    ld   A, H                                          ;; 00:0827 $7c
    adc  A, $00                                        ;; 00:0828 $ce $00
    ld   H, A                                          ;; 00:082a $67
    dec  C                                             ;; 00:082b $0d
    jr   NZ, .jr_00_081b                               ;; 00:082c $20 $ed
    call call_00_0f08_SwitchBank2                                  ;; 00:082e $cd $08 $0f
    pop  BC                                            ;; 00:0831 $c1
    pop  DE                                            ;; 00:0832 $d1
    pop  HL                                            ;; 00:0833 $e1
    ret                                                ;; 00:0834 $c9

call_00_0835_LoadFromTextBank1C:
    ld   A, $1c                                        ;; 00:0835 $3e $1c
    call call_00_0eee_SwitchBank                                  ;; 00:0837 $cd $ee $0e
    ld   HL, wDBA7                                     ;; 00:083a $21 $a7 $db
    ld   A, [HL+]                                      ;; 00:083d $2a
    ld   D, [HL]                                       ;; 00:083e $56
    ld   E, A                                          ;; 00:083f $5f
    ld   HL, wDBF8                                     ;; 00:0840 $21 $f8 $db
    ld   L, [HL]                                       ;; 00:0843 $6e
    ld   H, $00                                        ;; 00:0844 $26 $00
    add  HL, HL                                        ;; 00:0846 $29
    add  HL, DE                                        ;; 00:0847 $19
    ld   A, [HL+]                                      ;; 00:0848 $2a
    ld   H, [HL]                                       ;; 00:0849 $66
    ld   L, A                                          ;; 00:084a $6f
    ld   DE, wDADD                                     ;; 00:084b $11 $dd $da
.jr_00_084e:
    ld   A, [HL+]                                      ;; 00:084e $2a
    ld   [DE], A                                       ;; 00:084f $12
    inc  DE                                            ;; 00:0850 $13
    bit  7, A                                          ;; 00:0851 $cb $7f
    jr   Z, .jr_00_084e                                ;; 00:0853 $28 $f9
    xor  A, A                                          ;; 00:0855 $af
    ld   [DE], A                                       ;; 00:0856 $12
    ld   HL, wDADD                                     ;; 00:0857 $21 $dd $da
    ld   A, L                                          ;; 00:085a $7d
    ld   [wDBA7], A                                    ;; 00:085b $ea $a7 $db
    ld   A, H                                          ;; 00:085e $7c
    ld   [wDBA8], A                                    ;; 00:085f $ea $a8 $db
    jp   call_00_0f08_SwitchBank2                                  ;; 00:0862 $c3 $08 $0f
    db   $d5, $3e, $1c, $cd, $ee, $0e, $d1, $21        ;; 00:0865 ????????
    db   $f8, $db, $6e, $26, $00, $29, $19, $2a        ;; 00:086d ????????
    db   $66, $6f, $11, $dc, $da, $13, $1a, $fe        ;; 00:0875 ????????
    db   $80, $20, $fa, $2a, $12, $13, $fe, $80        ;; 00:087d ????????
    db   $20, $f9, $c3, $08, $0f                       ;; 00:0885 ?????

jp_00_088a:
    ld   A, [wDBE3]                                    ;; 00:088a $fa $e3 $db
    and  A, A                                          ;; 00:088d $a7
    ret  Z                                             ;; 00:088e $c8
    ld   A, $0a                                        ;; 00:088f $3e $0a
    call call_00_0eee_SwitchBank                                  ;; 00:0891 $cd $ee $0e
    ld   HL, wDC72                                     ;; 00:0894 $21 $72 $dc
    inc  [HL]                                          ;; 00:0897 $34
    ld   A, [HL]                                       ;; 00:0898 $7e
    sub  A, $0a                                        ;; 00:0899 $d6 $0a
    jr   NZ, .jr_00_089e                               ;; 00:089b $20 $01
    ld   [HL], A                                       ;; 00:089d $77
.jr_00_089e:
    ld   DE, $8dc                                      ;; 00:089e $11 $dc $08
    ld   B, $04                                        ;; 00:08a1 $06 $04
.jr_00_08a3:
    ld   A, [DE]                                       ;; 00:08a3 $1a
    inc  DE                                            ;; 00:08a4 $13
    ld   L, A                                          ;; 00:08a5 $6f
    ld   A, [DE]                                       ;; 00:08a6 $1a
    inc  DE                                            ;; 00:08a7 $13
    ld   H, A                                          ;; 00:08a8 $67
    ld   A, [wDC72]                                    ;; 00:08a9 $fa $72 $dc
    and  A, A                                          ;; 00:08ac $a7
    jr   NZ, .jr_00_08b5                               ;; 00:08ad $20 $06
    inc  [HL]                                          ;; 00:08af $34
    ld   A, [DE]                                       ;; 00:08b0 $1a
    sub  A, [HL]                                       ;; 00:08b1 $96
    jr   NZ, .jr_00_08b5                               ;; 00:08b2 $20 $01
    ld   [HL], A                                       ;; 00:08b4 $77
.jr_00_08b5:
    ld   A, [HL]                                       ;; 00:08b5 $7e
    swap A                                             ;; 00:08b6 $cb $37
    ld   L, A                                          ;; 00:08b8 $6f
    ld   H, $00                                        ;; 00:08b9 $26 $00
    add  HL, HL                                        ;; 00:08bb $29
    add  HL, HL                                        ;; 00:08bc $29
    inc  DE                                            ;; 00:08bd $13
    ld   A, [DE]                                       ;; 00:08be $1a
    inc  DE                                            ;; 00:08bf $13
    add  A, L                                          ;; 00:08c0 $85
    ld   L, A                                          ;; 00:08c1 $6f
    ld   A, [DE]                                       ;; 00:08c2 $1a
    inc  DE                                            ;; 00:08c3 $13
    adc  A, H                                          ;; 00:08c4 $8c
    ldh  [rHDMA1], A                                   ;; 00:08c5 $e0 $51
    ld   A, L                                          ;; 00:08c7 $7d
    ldh  [rHDMA2], A                                   ;; 00:08c8 $e0 $52
    ld   A, [DE]                                       ;; 00:08ca $1a
    inc  DE                                            ;; 00:08cb $13
    ldh  [rHDMA4], A                                   ;; 00:08cc $e0 $54
    ld   A, [DE]                                       ;; 00:08ce $1a
    inc  DE                                            ;; 00:08cf $13
    ldh  [rHDMA3], A                                   ;; 00:08d0 $e0 $53
    ld   A, $03                                        ;; 00:08d2 $3e $03
    ldh  [rHDMA5], A                                   ;; 00:08d4 $e0 $55
    dec  B                                             ;; 00:08d6 $05
    jr   NZ, .jr_00_08a3                               ;; 00:08d7 $20 $ca
    jp   call_00_0f08_SwitchBank2                                  ;; 00:08d9 $c3 $08 $0f
    dw   wDBE4                                         ;; 00:08dc pP
    db   $08, $a0, $57, $80, $8f                       ;; 00:08de .....
    dw   wDBE5                                         ;; 00:08e3 pP
    db   $04, $a0, $4a, $c0, $8e                       ;; 00:08e5 .....
    dw   wDBE6                                         ;; 00:08ea pP
    db   $06, $a0, $4b, $00, $8f                       ;; 00:08ec .....
    dw   wDBE7                                         ;; 00:08f1 pP
    db   $08, $20, $4d, $40, $8f                       ;; 00:08f3 .....

call_00_08f8:
    ld   HL, wDB66                                     ;; 00:08f8 $21 $66 $db
    bit  7, [HL]                                       ;; 00:08fb $cb $7e
    jr   NZ, call_00_08f8                              ;; 00:08fd $20 $f9
    bit  2, [HL]                                       ;; 00:08ff $cb $56
    jp   NZ, .jp_00_0a52                               ;; 00:0901 $c2 $52 $0a
    bit  0, [HL]                                       ;; 00:0904 $cb $46
    jp   NZ, .jp_00_0a52                               ;; 00:0906 $c2 $52 $0a
    bit  1, [HL]                                       ;; 00:0909 $cb $4e
    ret  NZ                                            ;; 00:090b $c0
    ld   HL, wD840                                     ;; 00:090c $21 $40 $d8
.jr_00_090f:
    push HL                                            ;; 00:090f $e5
    ld   A, [HL]                                       ;; 00:0910 $7e
    inc  A                                             ;; 00:0911 $3c
    jr   Z, .jr_00_0922                                ;; 00:0912 $28 $0e
    ld   A, L                                          ;; 00:0914 $7d
    or   A, $05                                        ;; 00:0915 $f6 $05
    ld   L, A                                          ;; 00:0917 $6f
    bit  1, [HL]                                       ;; 00:0918 $cb $4e
    jr   Z, .jr_00_0922                                ;; 00:091a $28 $06
    bit  5, [HL]                                       ;; 00:091c $cb $6e
    jr   NZ, .jr_00_092a                               ;; 00:091e $20 $0a
    jr   .jr_00_099c                                   ;; 00:0920 $18 $7a
.jr_00_0922:
    pop  HL                                            ;; 00:0922 $e1
    ld   A, L                                          ;; 00:0923 $7d
    add  A, $20                                        ;; 00:0924 $c6 $20
    ld   L, A                                          ;; 00:0926 $6f
    jr   NZ, .jr_00_090f                               ;; 00:0927 $20 $e6
    ret                                                ;; 00:0929 $c9
.jr_00_092a:
    res  1, [HL]                                       ;; 00:092a $cb $8e
    pop  HL                                            ;; 00:092c $e1
    ld   A, L                                          ;; 00:092d $7d
    ld   [wDB61], A                                    ;; 00:092e $ea $61 $db
    or   A, $0a                                        ;; 00:0931 $f6 $0a
    ld   L, A                                          ;; 00:0933 $6f
    ld   C, [HL]                                       ;; 00:0934 $4e
    inc  C                                             ;; 00:0935 $0c
    ld   A, L                                          ;; 00:0936 $7d
    xor  A, $0a                                        ;; 00:0937 $ee $0a
    ld   L, A                                          ;; 00:0939 $6f
    ld   B, [HL]                                       ;; 00:093a $46
    ld   HL, $96e                                      ;; 00:093b $21 $6e $09
    ld   DE, $05                                       ;; 00:093e $11 $05 $00
.jr_00_0941:
    add  HL, DE                                        ;; 00:0941 $19
    ld   A, [HL]                                       ;; 00:0942 $7e
    cp   A, $ff                                        ;; 00:0943 $fe $ff
    ret  Z                                             ;; 00:0945 $c8
    cp   A, B                                          ;; 00:0946 $b8
    jr   NZ, .jr_00_0941                               ;; 00:0947 $20 $f8
    ld   A, [HL+]                                      ;; 00:0949 $2a
    ld   A, [HL+]                                      ;; 00:094a $2a
    ld   E, A                                          ;; 00:094b $5f
    ld   A, [HL+]                                      ;; 00:094c $2a
    ld   D, A                                          ;; 00:094d $57
    ld   A, [HL+]                                      ;; 00:094e $2a
    ld   H, [HL]                                       ;; 00:094f $66
    ld   L, A                                          ;; 00:0950 $6f
.jr_00_0951:
    add  HL, DE                                        ;; 00:0951 $19
    dec  C                                             ;; 00:0952 $0d
    jr   NZ, .jr_00_0951                               ;; 00:0953 $20 $fc
    ld   A, L                                          ;; 00:0955 $7d
    ld   [wDB64], A                                    ;; 00:0956 $ea $64 $db
    ld   A, H                                          ;; 00:0959 $7c
    ld   [wDB65], A                                    ;; 00:095a $ea $65 $db
    ld   [wDAD6_ReturnBank], A                                    ;; 00:095d $ea $d6 $da
    ld   A, $03                                        ;; 00:0960 $3e $03
    ld   HL, $59b6                                     ;; 00:0962 $21 $b6 $59
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0965 $cd $dd $0e
    ld   [wDB63], A                                    ;; 00:0968 $ea $63 $db
    ld   HL, wDB66                                     ;; 00:096b $21 $66 $db
    set  1, [HL]                                       ;; 00:096e $cb $ce
    set  7, [HL]                                       ;; 00:0970 $cb $fe
    ret                                                ;; 00:0972 $c9
    db   $1e                                           ;; 00:0973 .
    dw   $0300                                         ;; 00:0974 wW
    dw   $3d00                                         ;; 00:0976 wW
    db   $38, $00, $02, $00, $77, $4d, $80, $01        ;; 00:0978 ????????
    db   $80, $3e, $55, $40, $02, $c0, $3d, $39        ;; 00:0980 ????????
    db   $80, $01, $80, $3e, $3a, $80, $01, $80        ;; 00:0988 ????????
    db   $3e, $6e, $80, $03, $80, $3c, $66, $00        ;; 00:0990 ????????
    db   $02, $00, $3e, $ff                            ;; 00:0998 ????
.jr_00_099c:
    res  1, [HL]                                       ;; 00:099c $cb $8e
    pop  HL                                            ;; 00:099e $e1
    ld   A, L                                          ;; 00:099f $7d
    ld   [wDB61], A                                    ;; 00:09a0 $ea $61 $db
    or   A, $0a                                        ;; 00:09a3 $f6 $0a
    ld   L, A                                          ;; 00:09a5 $6f
    ld   A, [HL]                                       ;; 00:09a6 $7e
    push AF                                            ;; 00:09a7 $f5
    ld   [wDAD6_ReturnBank], A                                    ;; 00:09a8 $ea $d6 $da
    ld   A, $03                                        ;; 00:09ab $3e $03
    ld   HL, $59b6                                     ;; 00:09ad $21 $b6 $59
    call call_00_0edd_CallAltBankFunc                                  ;; 00:09b0 $cd $dd $0e
    ld   [wDB63], A                                    ;; 00:09b3 $ea $63 $db
    ld   L, A                                          ;; 00:09b6 $6f
    ld   H, $00                                        ;; 00:09b7 $26 $00
    add  HL, HL                                        ;; 00:09b9 $29
    ld   DE, $a58                                      ;; 00:09ba $11 $58 $0a
    add  HL, DE                                        ;; 00:09bd $19
    ld   A, [HL+]                                      ;; 00:09be $2a
    ld   H, [HL]                                       ;; 00:09bf $66
    ld   L, A                                          ;; 00:09c0 $6f
    pop  AF                                            ;; 00:09c1 $f1
    ld   D, A                                          ;; 00:09c2 $57
    ld   E, $00                                        ;; 00:09c3 $1e $00
    jp   HL                                            ;; 00:09c5 $e9
    db   $cb, $3a, $cb, $1b, $cb, $3a, $cb, $1b        ;; 00:09c6 ????????
    db   $6b, $62, $cb, $3a, $cb, $1b, $19, $11        ;; 00:09ce ????????
    db   $e0, $79, $19, $18, $6a, $cb, $3a, $cb        ;; 00:09d6 ????????
    db   $1b, $6b, $62, $cb, $3a, $cb, $1b, $cb        ;; 00:09de ????????
    db   $3a, $cb, $1b, $19, $11, $a0, $7a, $19        ;; 00:09e6 ????????
    db   $18, $55                                      ;; 00:09ee ??
.data_00_09f0:
    srl  D                                             ;; 00:09f0 $cb $3a
    rr   E                                             ;; 00:09f2 $cb $1b
    ld   L, E                                          ;; 00:09f4 $6b
    ld   H, D                                          ;; 00:09f5 $62
    srl  D                                             ;; 00:09f6 $cb $3a
    rr   E                                             ;; 00:09f8 $cb $1b
    add  HL, DE                                        ;; 00:09fa $19
    ld   DE, call_01_4000                              ;; 00:09fb $11 $00 $40
    add  HL, DE                                        ;; 00:09fe $19
    jr   .jr_00_0a45                                   ;; 00:09ff $18 $44
    db   $cb, $3a, $cb, $1b, $6b, $62, $cb, $3a        ;; 00:0a01 ????????
    db   $cb, $1b, $19, $cb, $3a, $cb, $1b, $19        ;; 00:0a09 ????????
    db   $11, $a0, $7a, $19, $18, $2e                  ;; 00:0a11 ??????
.data_00_0a17:
    srl  D                                             ;; 00:0a17 $cb $3a
    rr   E                                             ;; 00:0a19 $cb $1b
    srl  D                                             ;; 00:0a1b $cb $3a
    rr   E                                             ;; 00:0a1d $cb $1b
    srl  D                                             ;; 00:0a1f $cb $3a
    rr   E                                             ;; 00:0a21 $cb $1b
    ld   HL, call_01_4000                              ;; 00:0a23 $21 $00 $40
    add  HL, DE                                        ;; 00:0a26 $19
    jr   .jr_00_0a45                                   ;; 00:0a27 $18 $1c
.data_00_0a29:
    srl  D                                             ;; 00:0a29 $cb $3a
    rr   E                                             ;; 00:0a2b $cb $1b
    srl  D                                             ;; 00:0a2d $cb $3a
    rr   E                                             ;; 00:0a2f $cb $1b
    ld   HL, $4aa0                                     ;; 00:0a31 $21 $a0 $4a
    add  HL, DE                                        ;; 00:0a34 $19
    jr   .jr_00_0a45                                   ;; 00:0a35 $18 $0e
    db   $cb, $3a, $cb, $1b, $21, $00, $40, $19        ;; 00:0a37 ????????
    db   $18, $04                                      ;; 00:0a3f ??
.data_00_0a41:
    ld   HL, call_01_4000                              ;; 00:0a41 $21 $00 $40
    add  HL, DE                                        ;; 00:0a44 $19
.jr_00_0a45:
    ld   A, L                                          ;; 00:0a45 $7d
    ld   [wDB64], A                                    ;; 00:0a46 $ea $64 $db
    ld   A, H                                          ;; 00:0a49 $7c
    ld   [wDB65], A                                    ;; 00:0a4a $ea $65 $db
    ld   HL, wDB66                                     ;; 00:0a4d $21 $66 $db
    set  1, [HL]                                       ;; 00:0a50 $cb $ce
.jp_00_0a52:
    ld   HL, wDB66                                     ;; 00:0a52 $21 $66 $db
    set  7, [HL]                                       ;; 00:0a55 $cb $fe
    ret                                                ;; 00:0a57 $c9
    db   $17, $0a                                      ;; 00:0a58 ??
    dw   .data_00_0a17                                 ;; 00:0a5a pP
    dw   .data_00_0a29                                 ;; 00:0a5c pP
    db   $c6, $09, $37, $0a, $db, $09                  ;; 00:0a5e ??????
    dw   .data_00_09f0                                 ;; 00:0a64 pP
    db   $01, $0a                                      ;; 00:0a66 ??
    dw   .data_00_0a41                                 ;; 00:0a68 pP

call_00_0a6a:
    ld   L, C                                          ;; 00:0a6a $69
    ld   H, $00                                        ;; 00:0a6b $26 $00
    add  HL, HL                                        ;; 00:0a6d $29
    add  HL, HL                                        ;; 00:0a6e $29
    add  HL, HL                                        ;; 00:0a6f $29
    ld   DE, .data_00_0aa9                                      ;; 00:0a70 $11 $a9 $0a
    add  HL, DE                                        ;; 00:0a73 $19
    ld   DE, wDC2B                                     ;; 00:0a74 $11 $2b $dc
    ld   BC, $08                                       ;; 00:0a77 $01 $08 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:0a7a $cd $6e $07
    ld   A, [wDC31]                                    ;; 00:0a7d $fa $31 $dc
    cp   A, $ff                                        ;; 00:0a80 $fe $ff
    jr   NZ, .jr_00_0a94                               ;; 00:0a82 $20 $10
    ld   HL, wDC2B                                     ;; 00:0a84 $21 $2b $dc
    ld   A, [wDC08_TilesetBankOffset]                                    ;; 00:0a87 $fa $08 $dc
    add  A, [HL]                                       ;; 00:0a8a $86
    ld   [HL+], A                                      ;; 00:0a8b $22
    ld   A, [wDC09_TilesetBankOffset]                                    ;; 00:0a8c $fa $09 $dc
    adc  A, [HL]                                       ;; 00:0a8f $8e
    ld   [HL], A                                       ;; 00:0a90 $77
    ld   A, [wDC07_TilesetBank]                                    ;; 00:0a91 $fa $07 $dc
.jr_00_0a94:
    ld   [wDC31], A                                    ;; 00:0a94 $ea $31 $dc
    ld   HL, wDB66                                     ;; 00:0a97 $21 $66 $db
    set  2, [HL]                                       ;; 00:0a9a $cb $d6
    set  7, [HL]                                       ;; 00:0a9c $cb $fe
.jr_00_0a9e:
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:0a9e $cd $92 $0b
    ld   HL, wDB66                                     ;; 00:0aa1 $21 $66 $db
    bit  2, [HL]                                       ;; 00:0aa4 $cb $56
    jr   NZ, .jr_00_0a9e                               ;; 00:0aa6 $20 $f6
    ret                                                ;; 00:0aa8 $c9
.data_00_0aa9:
    dw   $7800, $8000, $03c0, $010c                    ;; 00:0aa9 $78 $00
    dw   $7c00, $9c00, $0040, $010c                    ;; 00:0ab1 $00 $0c
    dw   $7bc0, $9c00, $0040, $000c                    ;; 00:0ab9 $00 $0c
    dw   $0000, $9000, $0800, $00ff                    ;; 00:0ac1 ........
    dw   $0800, $8800, $0800, $00ff                    ;; 00:0ac9 ........
    dw   $1000, $9000, $0800, $01ff                    ;; 00:0ad1 ........
    dw   $1800, $8800, $0800, $01ff                    ;; 00:0ad9 ........
    dw   $c000, $9800, $0400, $0101                    ;; 00:0ae1 ........
    dw   $c000, $9800, $0400, $0001                    ;; 00:0ae9 ........
    dw   $c000, $8000, $1000, $0001                    ;; 00:0af1 ........
    dw   $c000, $8000, $1000, $0101                    ;; 00:0af9 .???????
    dw   $4000, $4000, $4350, $46a0                    ;; 00:0b01 .???????
    dw   $49f0, $4d40, $5090, $53e0                    ;; 00:0b09 .???????
    dw   $53e0, $5730, $5a80, $5dd0                    ;; 00:0b11 .???????
    dw   $0100, $0502, $0d09, $8312                    ;; 00:0b19 .???????
    dw   $0e87, $1713                                  ;; 00:0b21 .???????

jp_00_0b25:
    push AF                                            ;; 00:0b25 $f5
    push BC                                            ;; 00:0b26 $c5
    push DE                                            ;; 00:0b27 $d5
    push HL                                            ;; 00:0b28 $e5
    call hFF80                                         ;; 00:0b29 $cd $80 $ff
    call call_00_0b9f                                  ;; 00:0b2c $cd $9f $0b
    ld   A, [wD9FD]                                    ;; 00:0b2f $fa $fd $d9
    bit  7, A                                          ;; 00:0b32 $cb $7f
    call Z, call_00_0c1b                               ;; 00:0b34 $cc $1b $0c
    ld   HL, wD9FE                                     ;; 00:0b37 $21 $fe $d9
    ld   A, [HL+]                                      ;; 00:0b3a $2a
    ld   H, [HL]                                       ;; 00:0b3b $66
    ld   L, A                                          ;; 00:0b3c $6f
    call call_00_0f22_CallFuncInHL                                  ;; 00:0b3d $cd $22 $0f
    call call_00_0f31                                  ;; 00:0b40 $cd $31 $0f
    call call_00_0e81                                  ;; 00:0b43 $cd $81 $0e
    ld   A, [wDAD8]                                    ;; 00:0b46 $fa $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0b49 $e0 $40
    ld   A, [wDAD9]                                    ;; 00:0b4b $fa $d9 $da
    ldh  [rSCX], A                                     ;; 00:0b4e $e0 $43
    ld   A, [wDADA]                                    ;; 00:0b50 $fa $da $da
    ldh  [rSCY], A                                     ;; 00:0b53 $e0 $42
    ld   A, [wDADB]                                    ;; 00:0b55 $fa $db $da
    ldh  [rWX], A                                      ;; 00:0b58 $e0 $4b
    ld   A, [wDADC]                                    ;; 00:0b5a $fa $dc $da
    ldh  [rWY], A                                      ;; 00:0b5d $e0 $4a
    ld   HL, wDC71                                     ;; 00:0b5f $21 $71 $dc
    inc  [HL]                                          ;; 00:0b62 $34
    ld   A, [wDE60]                                    ;; 00:0b63 $fa $60 $de
    add  A, $04                                        ;; 00:0b66 $c6 $04
    call call_00_0f25                                  ;; 00:0b68 $cd $25 $0f
    call call_04_4009                                  ;; 00:0b6b $cd $09 $40
    ld   A, [wDAD5]                                    ;; 00:0b6e $fa $d5 $da
    call call_00_0f25                                  ;; 00:0b71 $cd $25 $0f
    ld   A, $01                                        ;; 00:0b74 $3e $01
    ld   [wDB6B], A                                    ;; 00:0b76 $ea $6b $db
    ldh  A, [rLY]                                      ;; 00:0b79 $f0 $44
    cp   A, $90                                        ;; 00:0b7b $fe $90
    jr   NC, .jr_00_0b88                               ;; 00:0b7d $30 $09
    ld   C, A                                          ;; 00:0b7f $4f
.jr_00_0b80:
    ldh  A, [rLY]                                      ;; 00:0b80 $f0 $44
    cp   A, C                                          ;; 00:0b82 $b9
    jr   Z, .jr_00_0b80                                ;; 00:0b83 $28 $fb
    ld   [wDB67], A                                    ;; 00:0b85 $ea $67 $db
.jr_00_0b88:
    ld   HL, rIF                                       ;; 00:0b88 $21 $0f $ff
    res  1, [HL]                                       ;; 00:0b8b $cb $8e
    pop  HL                                            ;; 00:0b8d $e1
    pop  DE                                            ;; 00:0b8e $d1
    pop  BC                                            ;; 00:0b8f $c1
    pop  AF                                            ;; 00:0b90 $f1
    reti                                               ;; 00:0b91 $d9

call_00_0b92_UpdateVRAMTiles:
    xor  A, A                                          ;; 00:0b92 $af
    ld   [wDB6B], A                                    ;; 00:0b93 $ea $6b $db
.jr_00_0b96:
    halt                                               ;; 00:0b96 $76
    nop                                                ;; 00:0b97 $00
    ld   A, [wDB6B]                                    ;; 00:0b98 $fa $6b $db
    and  A, A                                          ;; 00:0b9b $a7
    jr   Z, .jr_00_0b96                                ;; 00:0b9c $28 $f8
    ret                                                ;; 00:0b9e $c9

call_00_0b9f:
    ld   A, $03                                        ;; 00:0b9f $3e $03
    call call_00_0f25                                  ;; 00:0ba1 $cd $25 $0f
    ld   HL, wDC20                                     ;; 00:0ba4 $21 $20 $dc
    bit  7, [HL]                                       ;; 00:0ba7 $cb $7e
    jr   Z, .jr_00_0bc6                                ;; 00:0ba9 $28 $1b
    res  7, [HL]                                       ;; 00:0bab $cb $be
    ld   A, [wDC20]                                    ;; 00:0bad $fa $20 $dc
    and  A, $0f                                        ;; 00:0bb0 $e6 $0f
    jr   Z, .jr_00_0bc6                                ;; 00:0bb2 $28 $12
    and  A, $03                                        ;; 00:0bb4 $e6 $03
    call NZ, call_03_75e3                              ;; 00:0bb6 $c4 $e3 $75
    ld   A, [wDC20]                                    ;; 00:0bb9 $fa $20 $dc
    and  A, $0c                                        ;; 00:0bbc $e6 $0c
    call NZ, call_03_7664                              ;; 00:0bbe $c4 $64 $76
    xor  A, A                                          ;; 00:0bc1 $af
    ld   [wDC20], A                                    ;; 00:0bc2 $ea $20 $dc
    ret                                                ;; 00:0bc5 $c9
.jr_00_0bc6:
    call call_03_747d                                  ;; 00:0bc6 $cd $7d $74
    call call_03_753e                                  ;; 00:0bc9 $cd $3e $75
    jp   jp_00_088a                                    ;; 00:0bcc $c3 $8a $08

jp_00_0bcf:
    ld   A, [HL+]                                      ;; 00:0bcf $2a
    ld   [DE], A                                       ;; 00:0bd0 $12
    inc  E                                             ;; 00:0bd1 $1c
    ld   A, [HL+]                                      ;; 00:0bd2 $2a
    ld   [DE], A                                       ;; 00:0bd3 $12
    inc  E                                             ;; 00:0bd4 $1c
    ld   A, [HL+]                                      ;; 00:0bd5 $2a
    ld   [DE], A                                       ;; 00:0bd6 $12
    inc  E                                             ;; 00:0bd7 $1c
    ld   A, [HL+]                                      ;; 00:0bd8 $2a
    ld   [DE], A                                       ;; 00:0bd9 $12
    inc  E                                             ;; 00:0bda $1c
    ld   A, [HL+]                                      ;; 00:0bdb $2a
    ld   [DE], A                                       ;; 00:0bdc $12
    inc  E                                             ;; 00:0bdd $1c
    ld   A, [HL+]                                      ;; 00:0bde $2a
    ld   [DE], A                                       ;; 00:0bdf $12
    inc  E                                             ;; 00:0be0 $1c
    ld   A, [HL+]                                      ;; 00:0be1 $2a
    ld   [DE], A                                       ;; 00:0be2 $12
    inc  E                                             ;; 00:0be3 $1c
    ld   A, [HL+]                                      ;; 00:0be4 $2a
    ld   [DE], A                                       ;; 00:0be5 $12
    inc  E                                             ;; 00:0be6 $1c
    ld   A, [HL+]                                      ;; 00:0be7 $2a
    ld   [DE], A                                       ;; 00:0be8 $12
    inc  E                                             ;; 00:0be9 $1c
    ld   A, [HL+]                                      ;; 00:0bea $2a
    ld   [DE], A                                       ;; 00:0beb $12
    inc  E                                             ;; 00:0bec $1c
    ld   A, [HL+]                                      ;; 00:0bed $2a
    ld   [DE], A                                       ;; 00:0bee $12
    inc  E                                             ;; 00:0bef $1c
    ld   A, [HL+]                                      ;; 00:0bf0 $2a
    ld   [DE], A                                       ;; 00:0bf1 $12
    inc  E                                             ;; 00:0bf2 $1c
    ld   A, [HL+]                                      ;; 00:0bf3 $2a
    ld   [DE], A                                       ;; 00:0bf4 $12
    inc  E                                             ;; 00:0bf5 $1c
    ld   A, [HL+]                                      ;; 00:0bf6 $2a
    ld   [DE], A                                       ;; 00:0bf7 $12
    inc  E                                             ;; 00:0bf8 $1c
    ld   A, [HL+]                                      ;; 00:0bf9 $2a
    ld   [DE], A                                       ;; 00:0bfa $12
    inc  E                                             ;; 00:0bfb $1c
    ld   A, [HL+]                                      ;; 00:0bfc $2a
    ld   [DE], A                                       ;; 00:0bfd $12
    inc  DE                                            ;; 00:0bfe $13
    dec  B                                             ;; 00:0bff $05
    jr   NZ, jp_00_0bcf                                ;; 00:0c00 $20 $cd
    ret                                                ;; 00:0c02 $c9
    db   $fa, $fd, $d9, $e6, $7f, $fe, $00, $c8        ;; 00:0c03 ????????
    db   $cd, $92, $0b, $18, $f3                       ;; 00:0c0b ?????

call_00_0c10:
    ld   HL, wD9FD                                     ;; 00:0c10 $21 $fd $d9
    or   A, $80                                        ;; 00:0c13 $f6 $80
    cp   A, [HL]                                       ;; 00:0c15 $be
    ret  Z                                             ;; 00:0c16 $c8
    and  A, $7f                                        ;; 00:0c17 $e6 $7f
    ld   [HL], A                                       ;; 00:0c19 $77
    ret                                                ;; 00:0c1a $c9

call_00_0c1b:
    ld   L, A                                          ;; 00:0c1b $6f
    or   A, $80                                        ;; 00:0c1c $f6 $80
    ld   [wD9FD], A                                    ;; 00:0c1e $ea $fd $d9
    ld   H, $00                                        ;; 00:0c21 $26 $00
    ld   DE, $c44                                      ;; 00:0c23 $11 $44 $0c
    add  HL, DE                                        ;; 00:0c26 $19
    ld   A, [HL+]                                      ;; 00:0c27 $2a
    ldh  [rSTAT], A                                    ;; 00:0c28 $e0 $41
    ld   A, [HL+]                                      ;; 00:0c2a $2a
    ldh  [rLYC], A                                     ;; 00:0c2b $e0 $45
    ld   B, [HL]                                       ;; 00:0c2d $46
    inc  HL                                            ;; 00:0c2e $23
    ld   A, [HL+]                                      ;; 00:0c2f $2a
    ld   H, [HL]                                       ;; 00:0c30 $66
    ld   L, A                                          ;; 00:0c31 $6f
    ld   DE, wD9A0                                     ;; 00:0c32 $11 $a0 $d9
.jr_00_0c35:
    ld   A, [HL+]                                      ;; 00:0c35 $2a
    ld   [DE], A                                       ;; 00:0c36 $12
    inc  E                                             ;; 00:0c37 $1c
    dec  B                                             ;; 00:0c38 $05
    jr   NZ, .jr_00_0c35                               ;; 00:0c39 $20 $fa
    ld   A, L                                          ;; 00:0c3b $7d
    ld   [wD9FE], A                                    ;; 00:0c3c $ea $fe $d9
    ld   A, H                                          ;; 00:0c3f $7c
    ld   [wD9FF], A                                    ;; 00:0c40 $ea $ff $d9
    ret                                                ;; 00:0c43 $c9
    db   $08, $00, $01, $53, $0c, $08, $00, $15        ;; 00:0c44 ........
    db   $55, $0c, $08, $00, $01, $f8, $0d, $d9        ;; 00:0c4c ........
    ret                                                ;; 00:0c54 $c9
    db   $f5, $e5, $fa, $67, $db, $d6, $7f, $ca        ;; 00:0c55 ........
    db   $8b, $0d, $3d, $ca, $c6, $0d, $21, $67        ;; 00:0c5d ........
    db   $db, $34, $e1, $f1, $d9                       ;; 00:0c65 .....

call_00_0c6a:
    xor  A, A                                          ;; 00:0c6a $af
    ld   [wDB67], A                                    ;; 00:0c6b $ea $67 $db
    ld   HL, wDB66                                     ;; 00:0c6e $21 $66 $db
    bit  7, [HL]                                       ;; 00:0c71 $cb $7e
    ret  Z                                             ;; 00:0c73 $c8
    bit  2, [HL]                                       ;; 00:0c74 $cb $56
    jp   NZ, .jp_00_0d14                               ;; 00:0c76 $c2 $14 $0d
    bit  0, [HL]                                       ;; 00:0c79 $cb $46
    jr   NZ, .jr_00_0c84                               ;; 00:0c7b $20 $07
    bit  1, [HL]                                       ;; 00:0c7d $cb $4e
    jr   NZ, .jr_00_0cab                               ;; 00:0c7f $20 $2a
    res  7, [HL]                                       ;; 00:0c81 $cb $be
    ret                                                ;; 00:0c83 $c9
.jr_00_0c84:
    ld   A, [wDABF_CurrentGexSpriteBank]                                    ;; 00:0c84 $fa $bf $da
    call call_00_0f25                                  ;; 00:0c87 $cd $25 $0f
    ld   A, [wDAC1]                                    ;; 00:0c8a $fa $c1 $da
    ldh  [rHDMA1], A                                   ;; 00:0c8d $e0 $51
    ld   A, [wDAC0]                                    ;; 00:0c8f $fa $c0 $da
    ldh  [rHDMA2], A                                   ;; 00:0c92 $e0 $52
    ld   A, $80                                        ;; 00:0c94 $3e $80
    ldh  [rHDMA3], A                                   ;; 00:0c96 $e0 $53
    xor  A, A                                          ;; 00:0c98 $af
    ldh  [rHDMA4], A                                   ;; 00:0c99 $e0 $54
    ld   A, [wDAC2]                                    ;; 00:0c9b $fa $c2 $da
    add  A, A                                          ;; 00:0c9e $87
    sub  A, $01                                        ;; 00:0c9f $d6 $01
    ldh  [rHDMA5], A                                   ;; 00:0ca1 $e0 $55
    ld   HL, wDB66                                     ;; 00:0ca3 $21 $66 $db
    res  0, [HL]                                       ;; 00:0ca6 $cb $86
    res  7, [HL]                                       ;; 00:0ca8 $cb $be
    ret                                                ;; 00:0caa $c9
.jr_00_0cab:
    ld   H, $d8                                        ;; 00:0cab $26 $d8
    ld   A, [wDB61]                                    ;; 00:0cad $fa $61 $db
    or   A, $17                                        ;; 00:0cb0 $f6 $17
    ld   L, A                                          ;; 00:0cb2 $6f
    ld   A, [HL]                                       ;; 00:0cb3 $7e
    call call_00_0f25                                  ;; 00:0cb4 $cd $25 $0f
    ld   H, $d8                                        ;; 00:0cb7 $26 $d8
    ld   A, [wDB61]                                    ;; 00:0cb9 $fa $61 $db
    or   A, $05                                        ;; 00:0cbc $f6 $05
    ld   L, A                                          ;; 00:0cbe $6f
    bit  5, [HL]                                       ;; 00:0cbf $cb $6e
    jr   NZ, .jr_00_0ceb                               ;; 00:0cc1 $20 $28
    ld   A, [wDB65]                                    ;; 00:0cc3 $fa $65 $db
    ldh  [rHDMA1], A                                   ;; 00:0cc6 $e0 $51
    ld   A, [wDB64]                                    ;; 00:0cc8 $fa $64 $db
    ldh  [rHDMA2], A                                   ;; 00:0ccb $e0 $52
    ld   A, [wDB61]                                    ;; 00:0ccd $fa $61 $db
    rlca                                               ;; 00:0cd0 $07
    rlca                                               ;; 00:0cd1 $07
    rlca                                               ;; 00:0cd2 $07
    and  A, $07                                        ;; 00:0cd3 $e6 $07
    add  A, $80                                        ;; 00:0cd5 $c6 $80
    ldh  [rHDMA3], A                                   ;; 00:0cd7 $e0 $53
    xor  A, A                                          ;; 00:0cd9 $af
    ldh  [rHDMA4], A                                   ;; 00:0cda $e0 $54
    ld   A, [wDB63]                                    ;; 00:0cdc $fa $63 $db
    add  A, A                                          ;; 00:0cdf $87
    dec  A                                             ;; 00:0ce0 $3d
    ldh  [rHDMA5], A                                   ;; 00:0ce1 $e0 $55
    ld   HL, wDB66                                     ;; 00:0ce3 $21 $66 $db
    res  1, [HL]                                       ;; 00:0ce6 $cb $8e
    res  7, [HL]                                       ;; 00:0ce8 $cb $be
    ret                                                ;; 00:0cea $c9
.jr_00_0ceb:
    ld   A, $01                                        ;; 00:0ceb $3e $01
    ldh  [rVBK], A                                     ;; 00:0ced $e0 $4f
    ld   A, [wDB65]                                    ;; 00:0cef $fa $65 $db
    ldh  [rHDMA1], A                                   ;; 00:0cf2 $e0 $51
    ld   A, [wDB64]                                    ;; 00:0cf4 $fa $64 $db
    ldh  [rHDMA2], A                                   ;; 00:0cf7 $e0 $52
    ld   A, $84                                        ;; 00:0cf9 $3e $84
    ldh  [rHDMA3], A                                   ;; 00:0cfb $e0 $53
    ld   A, $00                                        ;; 00:0cfd $3e $00
    ldh  [rHDMA4], A                                   ;; 00:0cff $e0 $54
    ld   A, [wDB63]                                    ;; 00:0d01 $fa $63 $db
    add  A, A                                          ;; 00:0d04 $87
    dec  A                                             ;; 00:0d05 $3d
    ldh  [rHDMA5], A                                   ;; 00:0d06 $e0 $55
    ld   A, $00                                        ;; 00:0d08 $3e $00
    ldh  [rVBK], A                                     ;; 00:0d0a $e0 $4f
    ld   HL, wDB66                                     ;; 00:0d0c $21 $66 $db
    res  1, [HL]                                       ;; 00:0d0f $cb $8e
    res  7, [HL]                                       ;; 00:0d11 $cb $be
    ret                                                ;; 00:0d13 $c9
.jp_00_0d14:
    ld   A, [wDC31]                                    ;; 00:0d14 $fa $31 $dc
    call call_00_0f25                                  ;; 00:0d17 $cd $25 $0f
    ld   A, [wDC32_VRAMBank]                                    ;; 00:0d1a $fa $32 $dc
    ldh  [rVBK], A                                     ;; 00:0d1d $e0 $4f
    ld   A, [wDC2C]                                    ;; 00:0d1f $fa $2c $dc
    ldh  [rHDMA1], A                                   ;; 00:0d22 $e0 $51
    ld   A, [wDC2B]                                    ;; 00:0d24 $fa $2b $dc
    ldh  [rHDMA2], A                                   ;; 00:0d27 $e0 $52
    ld   A, [wDC2E]                                    ;; 00:0d29 $fa $2e $dc
    ldh  [rHDMA3], A                                   ;; 00:0d2c $e0 $53
    ld   A, [wDC2D]                                    ;; 00:0d2e $fa $2d $dc
    ldh  [rHDMA4], A                                   ;; 00:0d31 $e0 $54
    ld   HL, wDC2F                                     ;; 00:0d33 $21 $2f $dc
    ld   A, [HL+]                                      ;; 00:0d36 $2a
    ld   E, A                                          ;; 00:0d37 $5f
    ld   D, [HL]                                       ;; 00:0d38 $56
    srl  D                                             ;; 00:0d39 $cb $3a
    rr   E                                             ;; 00:0d3b $cb $1b
    srl  D                                             ;; 00:0d3d $cb $3a
    rr   E                                             ;; 00:0d3f $cb $1b
    srl  D                                             ;; 00:0d41 $cb $3a
    rr   E                                             ;; 00:0d43 $cb $1b
    srl  D                                             ;; 00:0d45 $cb $3a
    rr   E                                             ;; 00:0d47 $cb $1b
    inc  D                                             ;; 00:0d49 $14
    dec  D                                             ;; 00:0d4a $15
    jr   NZ, .jr_00_0d52                               ;; 00:0d4b $20 $05
    ld   A, E                                          ;; 00:0d4d $7b
    cp   A, $40                                        ;; 00:0d4e $fe $40
    jr   C, .jr_00_0d54                                ;; 00:0d50 $38 $02
.jr_00_0d52:
    ld   E, $40                                        ;; 00:0d52 $1e $40
.jr_00_0d54:
    ld   A, E                                          ;; 00:0d54 $7b
    dec  A                                             ;; 00:0d55 $3d
    ldh  [rHDMA5], A                                   ;; 00:0d56 $e0 $55
    ld   A, $00                                        ;; 00:0d58 $3e $00
    ldh  [rVBK], A                                     ;; 00:0d5a $e0 $4f
    ld   L, E                                          ;; 00:0d5c $6b
    ld   H, $00                                        ;; 00:0d5d $26 $00
    add  HL, HL                                        ;; 00:0d5f $29
    add  HL, HL                                        ;; 00:0d60 $29
    add  HL, HL                                        ;; 00:0d61 $29
    add  HL, HL                                        ;; 00:0d62 $29
    ld   E, L                                          ;; 00:0d63 $5d
    ld   D, H                                          ;; 00:0d64 $54
    ld   HL, wDC2B                                     ;; 00:0d65 $21 $2b $dc
    ld   A, [HL]                                       ;; 00:0d68 $7e
    add  A, E                                          ;; 00:0d69 $83
    ld   [HL+], A                                      ;; 00:0d6a $22
    ld   A, [HL]                                       ;; 00:0d6b $7e
    adc  A, D                                          ;; 00:0d6c $8a
    ld   [HL], A                                       ;; 00:0d6d $77
    ld   HL, wDC2D                                     ;; 00:0d6e $21 $2d $dc
    ld   A, [HL]                                       ;; 00:0d71 $7e
    add  A, E                                          ;; 00:0d72 $83
    ld   [HL+], A                                      ;; 00:0d73 $22
    ld   A, [HL]                                       ;; 00:0d74 $7e
    adc  A, D                                          ;; 00:0d75 $8a
    ld   [HL], A                                       ;; 00:0d76 $77
    ld   HL, wDC2F                                     ;; 00:0d77 $21 $2f $dc
    ld   A, [HL]                                       ;; 00:0d7a $7e
    sub  A, E                                          ;; 00:0d7b $93
    ld   [HL+], A                                      ;; 00:0d7c $22
    ld   C, A                                          ;; 00:0d7d $4f
    ld   A, [HL]                                       ;; 00:0d7e $7e
    sbc  A, D                                          ;; 00:0d7f $9a
    ld   [HL], A                                       ;; 00:0d80 $77
    or   A, C                                          ;; 00:0d81 $b1
    ret  NZ                                            ;; 00:0d82 $c0
    ld   HL, wDB66                                     ;; 00:0d83 $21 $66 $db
    res  2, [HL]                                       ;; 00:0d86 $cb $96
    res  7, [HL]                                       ;; 00:0d88 $cb $be
    ret                                                ;; 00:0d8a $c9
    db   $21, $be, $0d, $3e, $80, $e0, $68, $2a        ;; 00:0d8b ????????
    db   $e0, $69, $2a, $e0, $69, $2a, $e0, $69        ;; 00:0d93 ????????
    db   $2a, $e0, $69, $3e, $88, $e0, $68, $2a        ;; 00:0d9b ????????
    db   $e0, $69, $2a, $e0, $69, $2a, $e0, $69        ;; 00:0da3 ????????
    db   $2a, $e0, $69, $fa, $d8, $da, $e6, $fd        ;; 00:0dab ????????
    db   $f6, $10, $e0, $40, $21, $67, $db, $34        ;; 00:0db3 ????????
    db   $e1, $f1, $d9, $00, $00, $e0, $01, $00        ;; 00:0dbb ????????
    db   $00, $e0, $01, $21, $f0, $0d, $3e, $84        ;; 00:0dc3 ????????
    db   $e0, $68, $2a, $e0, $69, $2a, $e0, $69        ;; 00:0dcb ????????
    db   $2a, $e0, $69, $2a, $e0, $69, $3e, $8c        ;; 00:0dd3 ????????
    db   $e0, $68, $2a, $e0, $69, $2a, $e0, $69        ;; 00:0ddb ????????
    db   $2a, $e0, $69, $2a, $e0, $69, $21, $67        ;; 00:0de3 ????????
    db   $db, $34, $e1, $f1, $d9, $ff, $7f, $80        ;; 00:0deb ????????
    db   $03, $ff, $03, $ff, $7f, $d9                  ;; 00:0df3 ?????.
    call call_00_0c6a                                  ;; 00:0df9 $cd $6a $0c
    jp   .jp_00_0dff                                   ;; 00:0dfc $c3 $ff $0d
.jp_00_0dff:
    ld   HL, wDBEF                                     ;; 00:0dff $21 $ef $db
    ld   A, [HL]                                       ;; 00:0e02 $7e
    and  A, A                                          ;; 00:0e03 $a7
    ret  Z                                             ;; 00:0e04 $c8
    dec  [HL]                                          ;; 00:0e05 $35
    inc  HL                                            ;; 00:0e06 $23
    ld   B, [HL]                                       ;; 00:0e07 $46
    inc  HL                                            ;; 00:0e08 $23
    ld   A, [HL]                                       ;; 00:0e09 $7e
    call call_00_0f25                                  ;; 00:0e0a $cd $25 $0f
    ld   HL, wDBF6                                     ;; 00:0e0d $21 $f6 $db
    ld   A, [HL+]                                      ;; 00:0e10 $2a
    ld   H, [HL]                                       ;; 00:0e11 $66
    ld   L, A                                          ;; 00:0e12 $6f
    ld   E, [HL]                                       ;; 00:0e13 $5e
    inc  HL                                            ;; 00:0e14 $23
    ld   D, [HL]                                       ;; 00:0e15 $56
    inc  HL                                            ;; 00:0e16 $23
    push DE                                            ;; 00:0e17 $d5
    ld   E, [HL]                                       ;; 00:0e18 $5e
    inc  HL                                            ;; 00:0e19 $23
    ld   D, [HL]                                       ;; 00:0e1a $56
    inc  HL                                            ;; 00:0e1b $23
    ld   A, L                                          ;; 00:0e1c $7d
    ld   [wDBF6], A                                    ;; 00:0e1d $ea $f6 $db
    ld   A, H                                          ;; 00:0e20 $7c
    ld   [wDBF7], A                                    ;; 00:0e21 $ea $f7 $db
    pop  HL                                            ;; 00:0e24 $e1
    jp   jp_00_0bcf                                    ;; 00:0e25 $c3 $cf $0b
    db   $c9, $3e, $d9, $e0, $46, $3e, $28, $3d        ;; 00:0e28 ?.......
    db   $20, $fd, $c9                                 ;; 00:0e30 ...

call_00_0e33:
    ld   [wDAD8], A                                    ;; 00:0e33 $ea $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0e36 $e0 $40
    jp   call_00_0b92_UpdateVRAMTiles                                  ;; 00:0e38 $c3 $92 $0b

call_00_0e3b:
    xor  A, A                                          ;; 00:0e3b $af
    ld   [wDC7E], A                                    ;; 00:0e3c $ea $7e $dc
    ld   [wDC20], A                                    ;; 00:0e3f $ea $20 $dc
    ld   [wDB66], A                                    ;; 00:0e42 $ea $66 $db
    ld   [wDB69], A                                    ;; 00:0e45 $ea $69 $db
    ld   [wDBEF], A                                    ;; 00:0e48 $ea $ef $db
    ld   [wDC72], A                                    ;; 00:0e4b $ea $72 $dc
    ld   [wDBE3], A                                    ;; 00:0e4e $ea $e3 $db
    ld   [wDD6B], A                                    ;; 00:0e51 $ea $6b $dd
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0e54 $ea $d6 $da
    ld   A, $02                                        ;; 00:0e57 $3e $02
    ld   HL, $7123                                     ;; 00:0e59 $21 $23 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0e5c $cd $dd $0e
    jp   call_00_0b92_UpdateVRAMTiles                                  ;; 00:0e5f $c3 $92 $0b

call_00_0e62:
    xor  A, A                                          ;; 00:0e62 $af
    ld   [wDD6A], A                                    ;; 00:0e63 $ea $6a $dd
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:0e66 $cd $92 $0b
    xor  A, A                                          ;; 00:0e69 $af
    ld   [wDAD9], A                                    ;; 00:0e6a $ea $d9 $da
    ld   [wDADA], A                                    ;; 00:0e6d $ea $da $da
    ld   HL, wD900                                     ;; 00:0e70 $21 $00 $d9
    ld   DE, wD901                                     ;; 00:0e73 $11 $01 $d9
    ld   BC, $9f                                       ;; 00:0e76 $01 $9f $00
    ld   [HL], $00                                     ;; 00:0e79 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:0e7b $cd $6e $07
    jp   call_00_0b92_UpdateVRAMTiles                                  ;; 00:0e7e $c3 $92 $0b

call_00_0e81:
    ld   A, [wDD6A]                                    ;; 00:0e81 $fa $6a $dd
    and  A, A                                          ;; 00:0e84 $a7
    jr   NZ, .jr_00_0e97                               ;; 00:0e85 $20 $10
    ld   A, $80                                        ;; 00:0e87 $3e $80
    ldh  [rBCPS], A                                    ;; 00:0e89 $e0 $68
    ldh  [rOCPS], A                                    ;; 00:0e8b $e0 $6a
    ld   B, $40                                        ;; 00:0e8d $06 $40
.jr_00_0e8f:
    ldh  [rBCPD], A                                    ;; 00:0e8f $e0 $69
    ldh  [rOCPD], A                                    ;; 00:0e91 $e0 $6b
    dec  B                                             ;; 00:0e93 $05
    jr   NZ, .jr_00_0e8f                               ;; 00:0e94 $20 $f9
    ret                                                ;; 00:0e96 $c9
.jr_00_0e97:
    ld   HL, wDCEA_BgPalettes                                     ;; 00:0e97 $21 $ea $dc
    ld   A, $80                                        ;; 00:0e9a $3e $80
    ldh  [rBCPS], A                                    ;; 00:0e9c $e0 $68
    ld   B, $08                                        ;; 00:0e9e $06 $08
.jr_00_0ea0:
    ld   A, [HL+]                                      ;; 00:0ea0 $2a
    ldh  [rBCPD], A                                    ;; 00:0ea1 $e0 $69
    ld   A, [HL+]                                      ;; 00:0ea3 $2a
    ldh  [rBCPD], A                                    ;; 00:0ea4 $e0 $69
    ld   A, [HL+]                                      ;; 00:0ea6 $2a
    ldh  [rBCPD], A                                    ;; 00:0ea7 $e0 $69
    ld   A, [HL+]                                      ;; 00:0ea9 $2a
    ldh  [rBCPD], A                                    ;; 00:0eaa $e0 $69
    ld   A, [HL+]                                      ;; 00:0eac $2a
    ldh  [rBCPD], A                                    ;; 00:0ead $e0 $69
    ld   A, [HL+]                                      ;; 00:0eaf $2a
    ldh  [rBCPD], A                                    ;; 00:0eb0 $e0 $69
    ld   A, [HL+]                                      ;; 00:0eb2 $2a
    ldh  [rBCPD], A                                    ;; 00:0eb3 $e0 $69
    ld   A, [HL+]                                      ;; 00:0eb5 $2a
    ldh  [rBCPD], A                                    ;; 00:0eb6 $e0 $69
    dec  B                                             ;; 00:0eb8 $05
    jr   NZ, .jr_00_0ea0                               ;; 00:0eb9 $20 $e5
    ld   A, $80                                        ;; 00:0ebb $3e $80
    ldh  [rOCPS], A                                    ;; 00:0ebd $e0 $6a
    ld   B, $08                                        ;; 00:0ebf $06 $08
.jr_00_0ec1:
    ld   A, [HL+]                                      ;; 00:0ec1 $2a
    ldh  [rOCPD], A                                    ;; 00:0ec2 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ec4 $2a
    ldh  [rOCPD], A                                    ;; 00:0ec5 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ec7 $2a
    ldh  [rOCPD], A                                    ;; 00:0ec8 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0eca $2a
    ldh  [rOCPD], A                                    ;; 00:0ecb $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ecd $2a
    ldh  [rOCPD], A                                    ;; 00:0ece $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ed0 $2a
    ldh  [rOCPD], A                                    ;; 00:0ed1 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ed3 $2a
    ldh  [rOCPD], A                                    ;; 00:0ed4 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ed6 $2a
    ldh  [rOCPD], A                                    ;; 00:0ed7 $e0 $6b
    dec  B                                             ;; 00:0ed9 $05
    jr   NZ, .jr_00_0ec1                               ;; 00:0eda $20 $e5
    ret                                                ;; 00:0edc $c9

call_00_0edd_CallAltBankFunc:
    push HL                                            ;; 00:0edd $e5
    call call_00_0eee_SwitchBank                                  ;; 00:0ede $cd $ee $0e
    pop  HL                                            ;; 00:0ee1 $e1
    ld   A, [wDAD6_ReturnBank]                                    ;; 00:0ee2 $fa $d6 $da
    call call_00_0f22_CallFuncInHL                                  ;; 00:0ee5 $cd $22 $0f
    push AF                                            ;; 00:0ee8 $f5
    call call_00_0f08_SwitchBank2                                  ;; 00:0ee9 $cd $08 $0f
    pop  AF                                            ;; 00:0eec $f1
    ret                                                ;; 00:0eed $c9

call_00_0eee_SwitchBank:
    ld   HL, wDAD3                                     ;; 00:0eee $21 $d3 $da
    ld   E, [HL]                                       ;; 00:0ef1 $5e
    inc  HL                                            ;; 00:0ef2 $23
    ld   D, [HL]                                       ;; 00:0ef3 $56
    inc  DE                                            ;; 00:0ef4 $13
    ld   [DE], A                                       ;; 00:0ef5 $12
    ld   [HL], D                                       ;; 00:0ef6 $72
    dec  HL                                            ;; 00:0ef7 $2b
    ld   [HL], E                                       ;; 00:0ef8 $73
    ld   [wDAD5], A                                    ;; 00:0ef9 $ea $d5 $da
    ld   [MBC1RomBank], A                                    ;; 00:0efc $ea $01 $20
    swap A                                             ;; 00:0eff $cb $37
    rrca                                               ;; 00:0f01 $0f
    and  A, $00                                        ;; 00:0f02 $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:0f04 $ea $01 $40
    ret                                                ;; 00:0f07 $c9

call_00_0f08_SwitchBank2:
    ld   HL, wDAD3                                     ;; 00:0f08 $21 $d3 $da
    ld   E, [HL]                                       ;; 00:0f0b $5e
    inc  HL                                            ;; 00:0f0c $23
    ld   D, [HL]                                       ;; 00:0f0d $56
    dec  DE                                            ;; 00:0f0e $1b
    ld   A, [DE]                                       ;; 00:0f0f $1a
    ld   [HL], D                                       ;; 00:0f10 $72
    dec  HL                                            ;; 00:0f11 $2b
    ld   [HL], E                                       ;; 00:0f12 $73
    ld   [wDAD5], A                                    ;; 00:0f13 $ea $d5 $da
    ld   [MBC1RomBank], A                                    ;; 00:0f16 $ea $01 $20
    swap A                                             ;; 00:0f19 $cb $37
    rrca                                               ;; 00:0f1b $0f
    and  A, $00                                        ;; 00:0f1c $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:0f1e $ea $01 $40
    ret                                                ;; 00:0f21 $c9

call_00_0f22_CallFuncInHL:
    jp   HL                                            ;; 00:0f22 $e9
    db   $3e, $03                                      ;; 00:0f23 ??

call_00_0f25:
    ld   [MBC1RomBank], A                                    ;; 00:0f25 $ea $01 $20
    swap A                                             ;; 00:0f28 $cb $37
    rrca                                               ;; 00:0f2a $0f
    and  A, $00                                        ;; 00:0f2b $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:0f2d $ea $01 $40
    ret                                                ;; 00:0f30 $c9

call_00_0f31:
    ld   C, $00                                        ;; 00:0f31 $0e $00
    ld   A, $20                                        ;; 00:0f33 $3e $20
    ldh  [C], A                                        ;; 00:0f35 $e2
    ldh  A, [C]                                        ;; 00:0f36 $f2
    ldh  A, [C]                                        ;; 00:0f37 $f2
    ldh  A, [C]                                        ;; 00:0f38 $f2
    ld   B, A                                          ;; 00:0f39 $47
    ld   A, $10                                        ;; 00:0f3a $3e $10
    ldh  [C], A                                        ;; 00:0f3c $e2
    ld   A, B                                          ;; 00:0f3d $78
    and  A, $0f                                        ;; 00:0f3e $e6 $0f
    swap A                                             ;; 00:0f40 $cb $37
    ld   B, A                                          ;; 00:0f42 $47
    ldh  A, [C]                                        ;; 00:0f43 $f2
    ldh  A, [C]                                        ;; 00:0f44 $f2
    ldh  A, [C]                                        ;; 00:0f45 $f2
    ldh  A, [C]                                        ;; 00:0f46 $f2
    ldh  A, [C]                                        ;; 00:0f47 $f2
    ldh  A, [C]                                        ;; 00:0f48 $f2
    ldh  A, [C]                                        ;; 00:0f49 $f2
    ldh  A, [C]                                        ;; 00:0f4a $f2
    ldh  A, [C]                                        ;; 00:0f4b $f2
    ldh  A, [C]                                        ;; 00:0f4c $f2
    ldh  A, [C]                                        ;; 00:0f4d $f2
    ldh  A, [C]                                        ;; 00:0f4e $f2
    ldh  A, [C]                                        ;; 00:0f4f $f2
    ldh  A, [C]                                        ;; 00:0f50 $f2
    and  A, $0f                                        ;; 00:0f51 $e6 $0f
    or   A, B                                          ;; 00:0f53 $b0
    cpl                                                ;; 00:0f54 $2f
    ld   B, A                                          ;; 00:0f55 $47
    ld   A, $30                                        ;; 00:0f56 $3e $30
    ldh  [C], A                                        ;; 00:0f58 $e2
    ld   A, B                                          ;; 00:0f59 $78
    ld   [wDAD7_CurrentInputs], A                                    ;; 00:0f5a $ea $d7 $da
    ret                                                ;; 00:0f5d $c9

call_00_0f5e:
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:0f5e $cd $92 $0b
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f61 $fa $d7 $da
    and  A, A                                          ;; 00:0f64 $a7
    jr   NZ, call_00_0f5e                              ;; 00:0f65 $20 $f7
    ret                                                ;; 00:0f67 $c9

call_00_0f68:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f68 $fa $d7 $da
    and  A, $20                                        ;; 00:0f6b $e6 $20
    ret                                                ;; 00:0f6d $c9

call_00_0f6e:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f6e $fa $d7 $da
    and  A, $10                                        ;; 00:0f71 $e6 $10
    ret                                                ;; 00:0f73 $c9

call_00_0f74:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f74 $fa $d7 $da
    and  A, $40                                        ;; 00:0f77 $e6 $40
    ret                                                ;; 00:0f79 $c9

call_00_0f7a:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f7a $fa $d7 $da
    and  A, $80                                        ;; 00:0f7d $e6 $80
    ret                                                ;; 00:0f7f $c9

call_00_0f80:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f80 $fa $d7 $da
    cp   A, $08                                        ;; 00:0f83 $fe $08
    jr   Z, .jr_00_0f89                                ;; 00:0f85 $28 $02
    xor  A, A                                          ;; 00:0f87 $af
    ret                                                ;; 00:0f88 $c9
.jr_00_0f89:
    and  A, A                                          ;; 00:0f89 $a7
    ret                                                ;; 00:0f8a $c9

call_00_0f8b:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f8b $fa $d7 $da
    cp   A, $04                                        ;; 00:0f8e $fe $04
    jr   Z, .jr_00_0f94                                ;; 00:0f90 $28 $02
    xor  A, A                                          ;; 00:0f92 $af
    ret                                                ;; 00:0f93 $c9
.jr_00_0f94:
    and  A, A                                          ;; 00:0f94 $a7
    ret                                                ;; 00:0f95 $c9
    db   $fa, $d7, $da, $e6, $01, $c9                  ;; 00:0f96 ??????

call_00_0f9c:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f9c $fa $d7 $da
    and  A, $02                                        ;; 00:0f9f $e6 $02
    ret                                                ;; 00:0fa1 $c9

call_00_0fa2:
    cp   A, $ff                                        ;; 00:0fa2 $fe $ff
    ret  Z                                             ;; 00:0fa4 $c8
    ld   HL, wDE5C                                     ;; 00:0fa5 $21 $5c $de
    cp   A, [HL]                                       ;; 00:0fa8 $be
    ret  Z                                             ;; 00:0fa9 $c8
    ld   [HL], A                                       ;; 00:0faa $77
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:0fab $cd $92 $0b
    ld   A, [wDE5C]                                    ;; 00:0fae $fa $5c $de
    swap A                                             ;; 00:0fb1 $cb $37
    and  A, $0f                                        ;; 00:0fb3 $e6 $0f
    ld   [wDE60], A                                    ;; 00:0fb5 $ea $60 $de
    add  A, $04                                        ;; 00:0fb8 $c6 $04
    call call_00_0eee_SwitchBank                                  ;; 00:0fba $cd $ee $0e
    ld   A, [wDE5C]                                    ;; 00:0fbd $fa $5c $de
    and  A, $0f                                        ;; 00:0fc0 $e6 $0f
    call call_04_4006                                  ;; 00:0fc2 $cd $06 $40
    jp   call_00_0f08_SwitchBank2                                  ;; 00:0fc5 $c3 $08 $0f

call_00_0fc8:
    ld   HL, wDE5D                                     ;; 00:0fc8 $21 $5d $de
    ld   A, [HL]                                       ;; 00:0fcb $7e
    ld   [HL], $ff                                     ;; 00:0fcc $36 $ff
    cp   A, $ff                                        ;; 00:0fce $fe $ff
    jr   NZ, call_00_0fd7                              ;; 00:0fd0 $20 $05
    xor  A, A                                          ;; 00:0fd2 $af
    ld   [wDE5E], A                                    ;; 00:0fd3 $ea $5e $de
    ret                                                ;; 00:0fd6 $c9

call_00_0fd7:
    cp   A, $ff                                        ;; 00:0fd7 $fe $ff
    ret  Z                                             ;; 00:0fd9 $c8
    push AF                                            ;; 00:0fda $f5
    ld   A, $04                                        ;; 00:0fdb $3e $04
    call call_00_0eee_SwitchBank                                  ;; 00:0fdd $cd $ee $0e
    ld   A, $00                                        ;; 00:0fe0 $3e $00
    call call_04_4024                                  ;; 00:0fe2 $cd $24 $40
    pop  AF                                            ;; 00:0fe5 $f1
    call call_04_4024                                  ;; 00:0fe6 $cd $24 $40
    ld   HL, wDE5E                                     ;; 00:0fe9 $21 $5e $de
    ld   A, [HL]                                       ;; 00:0fec $7e
    ld   [HL], $00                                     ;; 00:0fed $36 $00
    ld   [wDE5F], A                                    ;; 00:0fef $ea $5f $de
    jp   call_00_0f08_SwitchBank2                                  ;; 00:0ff2 $c3 $08 $0f

call_00_0ff5:
    cp   A, $ff                                        ;; 00:0ff5 $fe $ff
    ret  Z                                             ;; 00:0ff7 $c8
    ld   C, A                                          ;; 00:0ff8 $4f
    ld   B, $00                                        ;; 00:0ff9 $06 $00
    ld   HL, $1037                                     ;; 00:0ffb $21 $37 $10
    add  HL, BC                                        ;; 00:0ffe $09
    ld   B, [HL]                                       ;; 00:0fff $46
    xor  A, A                                          ;; 00:1000 $af
    ld   HL, wDF68                                     ;; 00:1001 $21 $68 $df
    or   A, [HL]                                       ;; 00:1004 $b6
    inc  HL                                            ;; 00:1005 $23
    or   A, [HL]                                       ;; 00:1006 $b6
    ld   HL, wDF6B                                     ;; 00:1007 $21 $6b $df
    or   A, [HL]                                       ;; 00:100a $b6
    inc  HL                                            ;; 00:100b $23
    or   A, [HL]                                       ;; 00:100c $b6
    ld   HL, wDF6E                                     ;; 00:100d $21 $6e $df
    or   A, [HL]                                       ;; 00:1010 $b6
    inc  HL                                            ;; 00:1011 $23
    or   A, [HL]                                       ;; 00:1012 $b6
    ld   HL, wDF71                                     ;; 00:1013 $21 $71 $df
    or   A, [HL]                                       ;; 00:1016 $b6
    inc  HL                                            ;; 00:1017 $23
    or   A, [HL]                                       ;; 00:1018 $b6
    jr   Z, .jr_00_1021                                ;; 00:1019 $28 $06
    ld   A, B                                          ;; 00:101b $78
    ld   HL, wDE5F                                     ;; 00:101c $21 $5f $de
    cp   A, [HL]                                       ;; 00:101f $be
    ret  C                                             ;; 00:1020 $d8
.jr_00_1021:
    ld   A, [wDE5D]                                    ;; 00:1021 $fa $5d $de
    cp   A, $ff                                        ;; 00:1024 $fe $ff
    jr   Z, .jr_00_102e                                ;; 00:1026 $28 $06
    ld   A, B                                          ;; 00:1028 $78
    ld   HL, wDE5E                                     ;; 00:1029 $21 $5e $de
    cp   A, [HL]                                       ;; 00:102c $be
    ret  C                                             ;; 00:102d $d8
.jr_00_102e:
    ld   HL, wDE5D                                     ;; 00:102e $21 $5d $de
    ld   [HL], C                                       ;; 00:1031 $71
    ld   HL, wDE5E                                     ;; 00:1032 $21 $5e $de
    ld   [HL], B                                       ;; 00:1035 $70
    ret                                                ;; 00:1036 $c9
    db   $11, $01, $08, $08, $01, $01, $01, $01        ;; 00:1037 ??.?.?..
    db   $01, $01, $01, $01, $01, $10, $10, $07        ;; 00:103f .?.??..?
    db   $07, $01, $01, $01, $08, $08, $01, $08        ;; 00:1047 .???????
    db   $08, $0e, $0f, $08, $08, $10, $10             ;; 00:104f ?.???..

call_00_1056_LoadMap:
    call call_00_0e3b                                  ;; 00:1056 $cd $3b $0e
    call call_00_0e62                                  ;; 00:1059 $cd $62 $0e
    call call_00_10c7_InitRowOffsetTableForMap                                  ;; 00:105c $cd $c7 $10
    ld   C, $00                                        ;; 00:105f $0e $00
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1061 $ea $d6 $da
    ld   A, $03                                        ;; 00:1064 $3e $03
    ld   HL, entry_03_65c6_LoadPalettes                              ;; 00:1066 $21 $c6 $65
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1069 $cd $dd $0e
    ld   C, $03                                        ;; 00:106c $0e $03
    call call_00_0a6a                                  ;; 00:106e $cd $6a $0a
    ld   C, $04                                        ;; 00:1071 $0e $04
    call call_00_0a6a                                  ;; 00:1073 $cd $6a $0a
    ld   C, $05                                        ;; 00:1076 $0e $05
    call call_00_0a6a                                  ;; 00:1078 $cd $6a $0a
    ld   C, $06                                        ;; 00:107b $0e $06
    call call_00_0a6a                                  ;; 00:107d $cd $6a $0a
    ld   A, $04                                        ;; 00:1080 $3e $04
    call call_00_1a22_LoadBgMapInitial                                  ;; 00:1082 $cd $22 $1a
    ld   C, $07                                        ;; 00:1085 $0e $07
    call call_00_0a6a                                  ;; 00:1087 $cd $6a $0a
    ld   A, $00                                        ;; 00:108a $3e $00
    call call_00_1a22_LoadBgMapInitial                                  ;; 00:108c $cd $22 $1a
    ld   C, $08                                        ;; 00:108f $0e $08
    call call_00_0a6a                                  ;; 00:1091 $cd $6a $0a
    ld   A, $80                                        ;; 00:1094 $3e $80
    call call_00_1a22_LoadBgMapInitial                                  ;; 00:1096 $cd $22 $1a
    ld   A, $03                                        ;; 00:1099 $3e $03
    call call_00_0eee_SwitchBank                                  ;; 00:109b $cd $ee $0e
    ld   HL, data_03_4100_bg_collision_tileset                                     ;; 00:109e $21 $00 $41
    ld   DE, wC400                                     ;; 00:10a1 $11 $00 $c4
.jr_00_10a4:
    push DE                                            ;; 00:10a4 $d5
    ld   B, $08                                        ;; 00:10a5 $06 $08
.jr_00_10a7:
    ld   A, [HL+]                                      ;; 00:10a7 $2a
    ld   [DE], A                                       ;; 00:10a8 $12
    inc  D                                             ;; 00:10a9 $14
    dec  B                                             ;; 00:10aa $05
    jr   NZ, .jr_00_10a7                               ;; 00:10ab $20 $fa
    pop  DE                                            ;; 00:10ad $d1
    inc  E                                             ;; 00:10ae $1c
    jr   NZ, .jr_00_10a4                               ;; 00:10af $20 $f3
    call call_00_0f08_SwitchBank2                                  ;; 00:10b1 $cd $08 $0f
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:10b4 $cd $92 $0b
    ld   [wDAD6_ReturnBank], A                                    ;; 00:10b7 $ea $d6 $da
    ld   A, $02                                        ;; 00:10ba $3e $02
    ld   HL, entry_02_72fb                                     ;; 00:10bc $21 $fb $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:10bf $cd $dd $0e
    xor  A, A                                          ;; 00:10c2 $af
    ld   [wDC20], A                                    ;; 00:10c3 $ea $20 $dc
    ret                                                ;; 00:10c6 $c9

call_00_10c7_InitRowOffsetTableForMap:
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:10c7 $21 $1c $dc
    ld   C, [HL]                                       ;; 00:10ca $4e
    ld   B, $00                                        ;; 00:10cb $06 $00
    ld   DE, wCD00_RowOffsetTableForMap                                     ;; 00:10cd $11 $00 $cd
    ld   HL, $00                                       ;; 00:10d0 $21 $00 $00
.jr_00_10d3:
    ld   A, L                                          ;; 00:10d3 $7d
    ld   [DE], A                                       ;; 00:10d4 $12
    inc  D                                             ;; 00:10d5 $14
    ld   A, H                                          ;; 00:10d6 $7c
    ld   [DE], A                                       ;; 00:10d7 $12
    dec  D                                             ;; 00:10d8 $15
    add  HL, BC                                        ;; 00:10d9 $09
    inc  E                                             ;; 00:10da $1c
    jr   NZ, .jr_00_10d3                               ;; 00:10db $20 $f6
    ret                                                ;; 00:10dd $c9

call_00_10de:
    ld   A, [wDC29]                                    ;; 00:10de $fa $29 $dc
    and  A, A                                          ;; 00:10e1 $a7
    ret  NZ                                            ;; 00:10e2 $c0
    ld   HL, wDC34                                     ;; 00:10e3 $21 $34 $dc
    ld   A, [HL+]                                      ;; 00:10e6 $2a
    ld   E, A                                          ;; 00:10e7 $5f
    ld   A, [HL+]                                      ;; 00:10e8 $2a
    ld   D, A                                          ;; 00:10e9 $57
    ld   A, [wD80E]                                    ;; 00:10ea $fa $0e $d8
    sub  A, $50                                        ;; 00:10ed $d6 $50
    ld   C, A                                          ;; 00:10ef $4f
    ld   A, [wD80F]                                    ;; 00:10f0 $fa $0f $d8
    sbc  A, $00                                        ;; 00:10f3 $de $00
    ld   B, A                                          ;; 00:10f5 $47
    jr   C, .jr_00_1109                                ;; 00:10f6 $38 $11
    ld   A, C                                          ;; 00:10f8 $79
    sub  A, E                                          ;; 00:10f9 $93
    ld   A, B                                          ;; 00:10fa $78
    sbc  A, D                                          ;; 00:10fb $9a
    jr   C, .jr_00_1109                                ;; 00:10fc $38 $0b
    ld   A, [HL+]                                      ;; 00:10fe $2a
    ld   E, A                                          ;; 00:10ff $5f
    ld   D, [HL]                                       ;; 00:1100 $56
    ld   A, C                                          ;; 00:1101 $79
    sub  A, E                                          ;; 00:1102 $93
    ld   A, B                                          ;; 00:1103 $78
    sbc  A, D                                          ;; 00:1104 $9a
    jr   NC, .jr_00_1109                               ;; 00:1105 $30 $02
    ld   E, C                                          ;; 00:1107 $59
    ld   D, B                                          ;; 00:1108 $50
.jr_00_1109:
    ld   A, [wDC2A]                                    ;; 00:1109 $fa $2a $dc
    cp   A, $00                                        ;; 00:110c $fe $00
    jr   NZ, .jr_00_1115                               ;; 00:110e $20 $05
    ld   E, C                                          ;; 00:1110 $59
    ld   A, B                                          ;; 00:1111 $78
    and  A, $0f                                        ;; 00:1112 $e6 $0f
    ld   D, A                                          ;; 00:1114 $57
.jr_00_1115:
    push DE                                            ;; 00:1115 $d5
    push DE                                            ;; 00:1116 $d5
    ld   A, E                                          ;; 00:1117 $7b
    ld   [wDBF9_XPositionInMap], A                                    ;; 00:1118 $ea $f9 $db
    ld   A, D                                          ;; 00:111b $7a
    ld   [wDBFA], A                                    ;; 00:111c $ea $fa $db
    ld   A, E                                          ;; 00:111f $7b
    sub  A, $10                                        ;; 00:1120 $d6 $10
    ld   E, A                                          ;; 00:1122 $5f
    ld   A, D                                          ;; 00:1123 $7a
    sbc  A, $00                                        ;; 00:1124 $de $00
    ld   D, A                                          ;; 00:1126 $57
    jr   NC, .jr_00_112c                               ;; 00:1127 $30 $03
    ld   DE, $00                                       ;; 00:1129 $11 $00 $00
.jr_00_112c:
    ld   A, E                                          ;; 00:112c $7b
    ld   [wDA14], A                                    ;; 00:112d $ea $14 $da
    ld   A, D                                          ;; 00:1130 $7a
    ld   [wDA15], A                                    ;; 00:1131 $ea $15 $da
    pop  DE                                            ;; 00:1134 $d1
    ld   A, E                                          ;; 00:1135 $7b
    add  A, $b0                                        ;; 00:1136 $c6 $b0
    ld   [wDA16], A                                    ;; 00:1138 $ea $16 $da
    ld   A, D                                          ;; 00:113b $7a
    adc  A, $00                                        ;; 00:113c $ce $00
    ld   [wDA17], A                                    ;; 00:113e $ea $17 $da
    pop  DE                                            ;; 00:1141 $d1
    srl  D                                             ;; 00:1142 $cb $3a
    rr   E                                             ;; 00:1144 $cb $1b
    srl  D                                             ;; 00:1146 $cb $3a
    rr   E                                             ;; 00:1148 $cb $1b
    srl  D                                             ;; 00:114a $cb $3a
    rr   E                                             ;; 00:114c $cb $1b
    srl  D                                             ;; 00:114e $cb $3a
    rr   E                                             ;; 00:1150 $cb $1b
    ld   A, E                                          ;; 00:1152 $7b
    ld   [wDAAC], A                                    ;; 00:1153 $ea $ac $da
    ld   HL, wDCAC                                     ;; 00:1156 $21 $ac $dc
    ld   A, [wD810]                                    ;; 00:1159 $fa $10 $d8
    add  A, [HL]                                       ;; 00:115c $86
    ld   C, A                                          ;; 00:115d $4f
    inc  HL                                            ;; 00:115e $23
    ld   A, [wD811]                                    ;; 00:115f $fa $11 $d8
    adc  A, [HL]                                       ;; 00:1162 $8e
    ld   B, A                                          ;; 00:1163 $47
    ld   HL, wDC38                                     ;; 00:1164 $21 $38 $dc
    ld   A, [HL+]                                      ;; 00:1167 $2a
    ld   E, A                                          ;; 00:1168 $5f
    ld   A, [HL+]                                      ;; 00:1169 $2a
    ld   D, A                                          ;; 00:116a $57
    ld   A, C                                          ;; 00:116b $79
    sub  A, $48                                        ;; 00:116c $d6 $48
    ld   C, A                                          ;; 00:116e $4f
    ld   A, B                                          ;; 00:116f $78
    sbc  A, $00                                        ;; 00:1170 $de $00
    ld   B, A                                          ;; 00:1172 $47
    jr   C, .jr_00_1186                                ;; 00:1173 $38 $11
    ld   A, C                                          ;; 00:1175 $79
    sub  A, E                                          ;; 00:1176 $93
    ld   A, B                                          ;; 00:1177 $78
    sbc  A, D                                          ;; 00:1178 $9a
    jr   C, .jr_00_1186                                ;; 00:1179 $38 $0b
    ld   A, [HL+]                                      ;; 00:117b $2a
    ld   E, A                                          ;; 00:117c $5f
    ld   D, [HL]                                       ;; 00:117d $56
    ld   A, C                                          ;; 00:117e $79
    sub  A, E                                          ;; 00:117f $93
    ld   A, B                                          ;; 00:1180 $78
    sbc  A, D                                          ;; 00:1181 $9a
    jr   NC, .jr_00_1186                               ;; 00:1182 $30 $02
    ld   E, C                                          ;; 00:1184 $59
    ld   D, B                                          ;; 00:1185 $50
.jr_00_1186:
    push DE                                            ;; 00:1186 $d5
    push DE                                            ;; 00:1187 $d5
    ld   A, E                                          ;; 00:1188 $7b
    ld   [wDBFB_YPositionInMap], A                                    ;; 00:1189 $ea $fb $db
    ld   A, D                                          ;; 00:118c $7a
    ld   [wDBFC], A                                    ;; 00:118d $ea $fc $db
    ld   A, E                                          ;; 00:1190 $7b
    sub  A, $10                                        ;; 00:1191 $d6 $10
    ld   E, A                                          ;; 00:1193 $5f
    ld   A, D                                          ;; 00:1194 $7a
    sbc  A, $00                                        ;; 00:1195 $de $00
    ld   D, A                                          ;; 00:1197 $57
    jr   NC, .jr_00_119d                               ;; 00:1198 $30 $03
    ld   DE, $00                                       ;; 00:119a $11 $00 $00
.jr_00_119d:
    ld   A, E                                          ;; 00:119d $7b
    ld   [wDA18], A                                    ;; 00:119e $ea $18 $da
    ld   A, D                                          ;; 00:11a1 $7a
    ld   [wDA19], A                                    ;; 00:11a2 $ea $19 $da
    pop  DE                                            ;; 00:11a5 $d1
    ld   A, E                                          ;; 00:11a6 $7b
    add  A, $b0                                        ;; 00:11a7 $c6 $b0
    ld   [wDA1A], A                                    ;; 00:11a9 $ea $1a $da
    ld   A, D                                          ;; 00:11ac $7a
    adc  A, $00                                        ;; 00:11ad $ce $00
    ld   [wDA1B], A                                    ;; 00:11af $ea $1b $da
    pop  DE                                            ;; 00:11b2 $d1
    srl  D                                             ;; 00:11b3 $cb $3a
    rr   E                                             ;; 00:11b5 $cb $1b
    srl  D                                             ;; 00:11b7 $cb $3a
    rr   E                                             ;; 00:11b9 $cb $1b
    srl  D                                             ;; 00:11bb $cb $3a
    rr   E                                             ;; 00:11bd $cb $1b
    srl  D                                             ;; 00:11bf $cb $3a
    rr   E                                             ;; 00:11c1 $cb $1b
    ld   A, E                                          ;; 00:11c3 $7b
    ld   [wDAAD], A                                    ;; 00:11c4 $ea $ad $da
    ret                                                ;; 00:11c7 $c9

call_00_11c8_LoadBgMap:
    ld   HL, wDC20                                     ;; 00:11c8 $21 $20 $dc
    bit  7, [HL]                                       ;; 00:11cb $cb $7e
    jr   NZ, call_00_11c8_LoadBgMap                              ;; 00:11cd $20 $f9
    ld   A, [wDC20]                                    ;; 00:11cf $fa $20 $dc
    and  A, $03                                        ;; 00:11d2 $e6 $03
    call NZ, call_00_11e5_LoadBgMapVertical                              ;; 00:11d4 $c4 $e5 $11
    ld   A, [wDC20]                                    ;; 00:11d7 $fa $20 $dc
    and  A, $0c                                        ;; 00:11da $e6 $0c
    call NZ, call_00_1351_LoadBgMapHorizontal                              ;; 00:11dc $c4 $51 $13
    ld   HL, wDC20                                     ;; 00:11df $21 $20 $dc
    set  7, [HL]                                       ;; 00:11e2 $cb $fe
    ret                                                ;; 00:11e4 $c9

call_00_11e5_LoadBgMapVertical:
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:11e5 $21 $fb $db
    ld   A, [HL+]                                      ;; 00:11e8 $2a
    ld   C, A                                          ;; 00:11e9 $4f
    ld   A, [HL+]                                      ;; 00:11ea $2a
    ld   B, A                                          ;; 00:11eb $47
    ld   HL, $88                                       ;; 00:11ec $21 $88 $00
    ld   A, [wDC20]                                    ;; 00:11ef $fa $20 $dc
    and  A, $02                                        ;; 00:11f2 $e6 $02
    jr   NZ, .jr_00_11f9                               ;; 00:11f4 $20 $03
    ld   HL, rIE                                       ;; 00:11f6 $21 $ff $ff
.jr_00_11f9:
    add  HL, BC                                        ;; 00:11f9 $09
    ld   C, L                                          ;; 00:11fa $4d
    ld   B, H                                          ;; 00:11fb $44
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:11fc $21 $f9 $db
    ld   E, [HL]                                       ;; 00:11ff $5e
    inc  HL                                            ;; 00:1200 $23
    ld   D, [HL]                                       ;; 00:1201 $56
    call call_00_14e2                                  ;; 00:1202 $cd $e2 $14
    ld   A, C                                          ;; 00:1205 $79
    and  A, $f8                                        ;; 00:1206 $e6 $f8
    ld   L, A                                          ;; 00:1208 $6f
    ld   H, $00                                        ;; 00:1209 $26 $00
    add  HL, HL                                        ;; 00:120b $29
    add  HL, HL                                        ;; 00:120c $29
    ld   A, E                                          ;; 00:120d $7b
    swap A                                             ;; 00:120e $cb $37
    add  A, A                                          ;; 00:1210 $87
    and  A, $1e                                        ;; 00:1211 $e6 $1e
    ld   [wDC25], A                                    ;; 00:1213 $ea $25 $dc
    or   A, L                                          ;; 00:1216 $b5
    ld   [wDC21], A                                    ;; 00:1217 $ea $21 $dc
    ld   A, H                                          ;; 00:121a $7c
    or   A, $98                                        ;; 00:121b $f6 $98
    ld   [wDC22], A                                    ;; 00:121d $ea $22 $dc
    ld   A, C                                          ;; 00:1220 $79
    rrca                                               ;; 00:1221 $0f
    rrca                                               ;; 00:1222 $0f
    and  A, $02                                        ;; 00:1223 $e6 $02
    ld   E, A                                          ;; 00:1225 $5f
    ld   D, $00                                        ;; 00:1226 $16 $00
    push DE                                            ;; 00:1228 $d5
    push DE                                            ;; 00:1229 $d5
    ld   A, [wDC01_MapBank]                                    ;; 00:122a $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:122d $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1230 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1233 $6e
    ld   H, $cd                                        ;; 00:1234 $26 $cd
    ld   E, [HL]                                       ;; 00:1236 $5e
    inc  H                                             ;; 00:1237 $24
    ld   D, [HL]                                       ;; 00:1238 $56
    ld   HL, wDC02_MapBankOffset                                     ;; 00:1239 $21 $02 $dc
    ld   A, [HL+]                                      ;; 00:123c $2a
    add  A, E                                          ;; 00:123d $83
    ld   E, A                                          ;; 00:123e $5f
    ld   A, [HL]                                       ;; 00:123f $7e
    adc  A, D                                          ;; 00:1240 $8a
    ld   D, A                                          ;; 00:1241 $57
    ld   HL, wDC27                                     ;; 00:1242 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1245 $6e
    ld   H, $00                                        ;; 00:1246 $26 $00
    add  HL, DE                                        ;; 00:1248 $19
    ld   E, L                                          ;; 00:1249 $5d
    ld   D, H                                          ;; 00:124a $54
    ld   HL, wDC25                                     ;; 00:124b $21 $25 $dc
    ld   L, [HL]                                       ;; 00:124e $6e
    ld   H, $cf                                        ;; 00:124f $26 $cf
    ld   B, $0b                                        ;; 00:1251 $06 $0b
.jr_00_1253:
    ld   A, [DE]                                       ;; 00:1253 $1a
    ld   [HL+], A                                      ;; 00:1254 $22
    inc  L                                             ;; 00:1255 $2c
    res  5, L                                          ;; 00:1256 $cb $ad
    inc  DE                                            ;; 00:1258 $13
    dec  B                                             ;; 00:1259 $05
    jr   NZ, .jr_00_1253                               ;; 00:125a $20 $f7
    call call_00_0f08_SwitchBank2                                  ;; 00:125c $cd $08 $0f
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:125f $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1262 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1265 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1268 $6e
    ld   H, $cd                                        ;; 00:1269 $26 $cd
    ld   E, [HL]                                       ;; 00:126b $5e
    inc  H                                             ;; 00:126c $24
    ld   D, [HL]                                       ;; 00:126d $56
    ld   HL, wDC05_MapExtendedBankOffset                                     ;; 00:126e $21 $05 $dc
    ld   A, [HL+]                                      ;; 00:1271 $2a
    add  A, E                                          ;; 00:1272 $83
    ld   E, A                                          ;; 00:1273 $5f
    ld   A, [HL]                                       ;; 00:1274 $7e
    adc  A, D                                          ;; 00:1275 $8a
    ld   D, A                                          ;; 00:1276 $57
    ld   HL, wDC27                                     ;; 00:1277 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:127a $6e
    ld   H, $00                                        ;; 00:127b $26 $00
    add  HL, DE                                        ;; 00:127d $19
    ld   E, L                                          ;; 00:127e $5d
    ld   D, H                                          ;; 00:127f $54
    ld   HL, wDC25                                     ;; 00:1280 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1283 $6e
    inc  L                                             ;; 00:1284 $2c
    ld   H, $cf                                        ;; 00:1285 $26 $cf
    ld   B, $0b                                        ;; 00:1287 $06 $0b
.jr_00_1289:
    ld   A, [DE]                                       ;; 00:1289 $1a
    ld   [HL+], A                                      ;; 00:128a $22
    res  5, L                                          ;; 00:128b $cb $ad
    inc  L                                             ;; 00:128d $2c
    inc  DE                                            ;; 00:128e $13
    dec  B                                             ;; 00:128f $05
    jr   NZ, .jr_00_1289                               ;; 00:1290 $20 $f7
    call call_00_0f08_SwitchBank2                                  ;; 00:1292 $cd $08 $0f
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1295 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1298 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:129b $21 $28 $dc
    ld   L, [HL]                                       ;; 00:129e $6e
    ld   H, $cd                                        ;; 00:129f $26 $cd
    ld   E, [HL]                                       ;; 00:12a1 $5e
    inc  H                                             ;; 00:12a2 $24
    ld   D, [HL]                                       ;; 00:12a3 $56
    ld   HL, wDC0E_MapCollisionBankOffset                                     ;; 00:12a4 $21 $0e $dc
    ld   A, [HL+]                                      ;; 00:12a7 $2a
    add  A, E                                          ;; 00:12a8 $83
    ld   E, A                                          ;; 00:12a9 $5f
    ld   A, [HL]                                       ;; 00:12aa $7e
    adc  A, D                                          ;; 00:12ab $8a
    ld   D, A                                          ;; 00:12ac $57
    ld   HL, wDC27                                     ;; 00:12ad $21 $27 $dc
    ld   L, [HL]                                       ;; 00:12b0 $6e
    ld   H, $00                                        ;; 00:12b1 $26 $00
    add  HL, DE                                        ;; 00:12b3 $19
    ld   E, L                                          ;; 00:12b4 $5d
    ld   D, H                                          ;; 00:12b5 $54
    ld   HL, wDC22                                     ;; 00:12b6 $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:12b9 $3a
    ld   L, [HL]                                       ;; 00:12ba $6e
    and  A, $03                                        ;; 00:12bb $e6 $03
    add  A, $c0                                        ;; 00:12bd $c6 $c0
    ld   H, A                                          ;; 00:12bf $67
    ld   B, $0b                                        ;; 00:12c0 $06 $0b
.jr_00_12c2:
    ld   A, [DE]                                       ;; 00:12c2 $1a
    ld   [HL+], A                                      ;; 00:12c3 $22
    inc  HL                                            ;; 00:12c4 $23
    ld   A, L                                          ;; 00:12c5 $7d
    and  A, $1f                                        ;; 00:12c6 $e6 $1f
    jr   NZ, .jr_00_12cf                               ;; 00:12c8 $20 $05
    dec  HL                                            ;; 00:12ca $2b
    ld   A, L                                          ;; 00:12cb $7d
    and  A, $e0                                        ;; 00:12cc $e6 $e0
    ld   L, A                                          ;; 00:12ce $6f
.jr_00_12cf:
    inc  DE                                            ;; 00:12cf $13
    dec  B                                             ;; 00:12d0 $05
    jr   NZ, .jr_00_12c2                               ;; 00:12d1 $20 $ef
    call call_00_0f08_SwitchBank2                                  ;; 00:12d3 $cd $08 $0f
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:12d6 $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:12d9 $cd $ee $0e
    ld   HL, wDC25                                     ;; 00:12dc $21 $25 $dc
    ld   E, [HL]                                       ;; 00:12df $5e
    ld   D, $cf                                        ;; 00:12e0 $16 $cf
    pop  BC                                            ;; 00:12e2 $c1
    ld   A, [wDC0B_BlocksetBankOffset]                                    ;; 00:12e3 $fa $0b $dc
    add  A, C                                          ;; 00:12e6 $81
    ld   C, A                                          ;; 00:12e7 $4f
    ld   A, [wDC0C_BlocksetBankOffset]                                    ;; 00:12e8 $fa $0c $dc
    adc  A, B                                          ;; 00:12eb $88
    ld   B, A                                          ;; 00:12ec $47
    ld   A, $0b                                        ;; 00:12ed $3e $0b
.jr_00_12ef:
    push AF                                            ;; 00:12ef $f5
    ld   A, [DE]                                       ;; 00:12f0 $1a
    ld   L, A                                          ;; 00:12f1 $6f
    inc  E                                             ;; 00:12f2 $1c
    ld   A, [DE]                                       ;; 00:12f3 $1a
    ld   H, A                                          ;; 00:12f4 $67
    dec  E                                             ;; 00:12f5 $1d
    add  HL, HL                                        ;; 00:12f6 $29
    add  HL, HL                                        ;; 00:12f7 $29
    add  HL, HL                                        ;; 00:12f8 $29
    add  HL, BC                                        ;; 00:12f9 $09
    ld   A, [HL+]                                      ;; 00:12fa $2a
    ld   [DE], A                                       ;; 00:12fb $12
    inc  E                                             ;; 00:12fc $1c
    ld   A, [HL+]                                      ;; 00:12fd $2a
    ld   [DE], A                                       ;; 00:12fe $12
    dec  E                                             ;; 00:12ff $1d
    set  7, E                                          ;; 00:1300 $cb $fb
    inc  HL                                            ;; 00:1302 $23
    inc  HL                                            ;; 00:1303 $23
    ld   A, [HL+]                                      ;; 00:1304 $2a
    ld   [DE], A                                       ;; 00:1305 $12
    inc  E                                             ;; 00:1306 $1c
    ld   A, [HL+]                                      ;; 00:1307 $2a
    ld   [DE], A                                       ;; 00:1308 $12
    res  7, E                                          ;; 00:1309 $cb $bb
    inc  E                                             ;; 00:130b $1c
    res  5, E                                          ;; 00:130c $cb $ab
    pop  AF                                            ;; 00:130e $f1
    dec  A                                             ;; 00:130f $3d
    jr   NZ, .jr_00_12ef                               ;; 00:1310 $20 $dd
    call call_00_0f08_SwitchBank2                                  ;; 00:1312 $cd $08 $0f
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:1315 $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1318 $cd $ee $0e
    ld   HL, wDC22                                     ;; 00:131b $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:131e $3a
    ld   E, [HL]                                       ;; 00:131f $5e
    and  A, $03                                        ;; 00:1320 $e6 $03
    add  A, $c0                                        ;; 00:1322 $c6 $c0
    ld   D, A                                          ;; 00:1324 $57
    pop  BC                                            ;; 00:1325 $c1
    ld   A, [wDC11_CollisionBlocksetOffset]                                    ;; 00:1326 $fa $11 $dc
    add  A, C                                          ;; 00:1329 $81
    ld   C, A                                          ;; 00:132a $4f
    ld   A, [wDC12_CollisionBlocksetOffset]                                    ;; 00:132b $fa $12 $dc
    adc  A, B                                          ;; 00:132e $88
    ld   B, A                                          ;; 00:132f $47
    ld   A, $0b                                        ;; 00:1330 $3e $0b
.jr_00_1332:
    push AF                                            ;; 00:1332 $f5
    ld   A, [DE]                                       ;; 00:1333 $1a
    ld   L, A                                          ;; 00:1334 $6f
    ld   H, $00                                        ;; 00:1335 $26 $00
    add  HL, HL                                        ;; 00:1337 $29
    add  HL, HL                                        ;; 00:1338 $29
    add  HL, BC                                        ;; 00:1339 $09
    ld   A, [HL+]                                      ;; 00:133a $2a
    ld   [DE], A                                       ;; 00:133b $12
    inc  DE                                            ;; 00:133c $13
    ld   A, [HL]                                       ;; 00:133d $7e
    ld   [DE], A                                       ;; 00:133e $12
    inc  DE                                            ;; 00:133f $13
    ld   A, E                                          ;; 00:1340 $7b
    and  A, $1f                                        ;; 00:1341 $e6 $1f
    jr   NZ, .jr_00_134a                               ;; 00:1343 $20 $05
    dec  DE                                            ;; 00:1345 $1b
    ld   A, E                                          ;; 00:1346 $7b
    and  A, $e0                                        ;; 00:1347 $e6 $e0
    ld   E, A                                          ;; 00:1349 $5f
.jr_00_134a:
    pop  AF                                            ;; 00:134a $f1
    dec  A                                             ;; 00:134b $3d
    jr   NZ, .jr_00_1332                               ;; 00:134c $20 $e4
    jp   call_00_0f08_SwitchBank2                                  ;; 00:134e $c3 $08 $0f

call_00_1351_LoadBgMapHorizontal:
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:1351 $21 $f9 $db
    ld   A, [HL+]                                      ;; 00:1354 $2a
    ld   E, A                                          ;; 00:1355 $5f
    ld   A, [HL+]                                      ;; 00:1356 $2a
    ld   D, A                                          ;; 00:1357 $57
    ld   HL, $a0                                       ;; 00:1358 $21 $a0 $00
    ld   A, [wDC20]                                    ;; 00:135b $fa $20 $dc
    and  A, $08                                        ;; 00:135e $e6 $08
    jr   NZ, .jr_00_1365                               ;; 00:1360 $20 $03
    ld   HL, rIE                                       ;; 00:1362 $21 $ff $ff
.jr_00_1365:
    add  HL, DE                                        ;; 00:1365 $19
    ld   E, L                                          ;; 00:1366 $5d
    ld   D, H                                          ;; 00:1367 $54
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1368 $21 $fb $db
    ld   C, [HL]                                       ;; 00:136b $4e
    inc  HL                                            ;; 00:136c $23
    ld   B, [HL]                                       ;; 00:136d $46
    call call_00_14e2                                  ;; 00:136e $cd $e2 $14
    ld   A, C                                          ;; 00:1371 $79
    and  A, $f0                                        ;; 00:1372 $e6 $f0
    ld   L, A                                          ;; 00:1374 $6f
    swap A                                             ;; 00:1375 $cb $37
    add  A, A                                          ;; 00:1377 $87
    or   A, $40                                        ;; 00:1378 $f6 $40
    ld   [wDC26], A                                    ;; 00:137a $ea $26 $dc
    ld   H, $00                                        ;; 00:137d $26 $00
    add  HL, HL                                        ;; 00:137f $29
    add  HL, HL                                        ;; 00:1380 $29
    ld   A, E                                          ;; 00:1381 $7b
    rrca                                               ;; 00:1382 $0f
    rrca                                               ;; 00:1383 $0f
    rrca                                               ;; 00:1384 $0f
    and  A, $1f                                        ;; 00:1385 $e6 $1f
    or   A, L                                          ;; 00:1387 $b5
    ld   [wDC23], A                                    ;; 00:1388 $ea $23 $dc
    ld   A, H                                          ;; 00:138b $7c
    or   A, $98                                        ;; 00:138c $f6 $98
    ld   [wDC24], A                                    ;; 00:138e $ea $24 $dc
    ld   A, E                                          ;; 00:1391 $7b
    rrca                                               ;; 00:1392 $0f
    rrca                                               ;; 00:1393 $0f
    rrca                                               ;; 00:1394 $0f
    and  A, $01                                        ;; 00:1395 $e6 $01
    ld   E, A                                          ;; 00:1397 $5f
    ld   D, $00                                        ;; 00:1398 $16 $00
    push DE                                            ;; 00:139a $d5
    push DE                                            ;; 00:139b $d5
    ld   A, [wDC01_MapBank]                                    ;; 00:139c $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:139f $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:13a2 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:13a5 $6e
    ld   H, $cd                                        ;; 00:13a6 $26 $cd
    ld   E, [HL]                                       ;; 00:13a8 $5e
    inc  H                                             ;; 00:13a9 $24
    ld   D, [HL]                                       ;; 00:13aa $56
    ld   HL, wDC02_MapBankOffset                                     ;; 00:13ab $21 $02 $dc
    ld   A, [HL+]                                      ;; 00:13ae $2a
    add  A, E                                          ;; 00:13af $83
    ld   E, A                                          ;; 00:13b0 $5f
    ld   A, [HL]                                       ;; 00:13b1 $7e
    adc  A, D                                          ;; 00:13b2 $8a
    ld   D, A                                          ;; 00:13b3 $57
    ld   HL, wDC27                                     ;; 00:13b4 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:13b7 $6e
    ld   H, $00                                        ;; 00:13b8 $26 $00
    add  HL, DE                                        ;; 00:13ba $19
    push HL                                            ;; 00:13bb $e5
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:13bc $21 $1c $dc
    ld   C, [HL]                                       ;; 00:13bf $4e
    ld   B, $00                                        ;; 00:13c0 $06 $00
    ld   HL, wDC26                                     ;; 00:13c2 $21 $26 $dc
    ld   E, [HL]                                       ;; 00:13c5 $5e
    ld   D, $cf                                        ;; 00:13c6 $16 $cf
    pop  HL                                            ;; 00:13c8 $e1
    ld   A, $0b                                        ;; 00:13c9 $3e $0b
.jr_00_13cb:
    push AF                                            ;; 00:13cb $f5
    ld   A, [HL]                                       ;; 00:13cc $7e
    ld   [DE], A                                       ;; 00:13cd $12
    inc  E                                             ;; 00:13ce $1c
    inc  E                                             ;; 00:13cf $1c
    res  5, E                                          ;; 00:13d0 $cb $ab
    add  HL, BC                                        ;; 00:13d2 $09
    pop  AF                                            ;; 00:13d3 $f1
    dec  A                                             ;; 00:13d4 $3d
    jr   NZ, .jr_00_13cb                               ;; 00:13d5 $20 $f4
    call call_00_0f08_SwitchBank2                                  ;; 00:13d7 $cd $08 $0f
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:13da $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:13dd $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:13e0 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:13e3 $6e
    ld   H, $cd                                        ;; 00:13e4 $26 $cd
    ld   E, [HL]                                       ;; 00:13e6 $5e
    inc  H                                             ;; 00:13e7 $24
    ld   D, [HL]                                       ;; 00:13e8 $56
    ld   HL, wDC05_MapExtendedBankOffset                                     ;; 00:13e9 $21 $05 $dc
    ld   A, [HL+]                                      ;; 00:13ec $2a
    add  A, E                                          ;; 00:13ed $83
    ld   E, A                                          ;; 00:13ee $5f
    ld   A, [HL]                                       ;; 00:13ef $7e
    adc  A, D                                          ;; 00:13f0 $8a
    ld   D, A                                          ;; 00:13f1 $57
    ld   HL, wDC27                                     ;; 00:13f2 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:13f5 $6e
    ld   H, $00                                        ;; 00:13f6 $26 $00
    add  HL, DE                                        ;; 00:13f8 $19
    push HL                                            ;; 00:13f9 $e5
    ld   HL, wDC1C_CurrentMapWidthAndHeightInBlocks                                     ;; 00:13fa $21 $1c $dc
    ld   C, [HL]                                       ;; 00:13fd $4e
    ld   B, $00                                        ;; 00:13fe $06 $00
    ld   HL, wDC26                                     ;; 00:1400 $21 $26 $dc
    ld   E, [HL]                                       ;; 00:1403 $5e
    inc  E                                             ;; 00:1404 $1c
    ld   D, $cf                                        ;; 00:1405 $16 $cf
    pop  HL                                            ;; 00:1407 $e1
    ld   A, $0b                                        ;; 00:1408 $3e $0b
.jr_00_140a:
    push AF                                            ;; 00:140a $f5
    ld   A, [HL]                                       ;; 00:140b $7e
    ld   [DE], A                                       ;; 00:140c $12
    inc  E                                             ;; 00:140d $1c
    res  5, E                                          ;; 00:140e $cb $ab
    inc  E                                             ;; 00:1410 $1c
    add  HL, BC                                        ;; 00:1411 $09
    pop  AF                                            ;; 00:1412 $f1
    dec  A                                             ;; 00:1413 $3d
    jr   NZ, .jr_00_140a                               ;; 00:1414 $20 $f4
    call call_00_0f08_SwitchBank2                                  ;; 00:1416 $cd $08 $0f
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1419 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:141c $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:141f $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1422 $6e
    ld   H, $cd                                        ;; 00:1423 $26 $cd
    ld   E, [HL]                                       ;; 00:1425 $5e
    inc  H                                             ;; 00:1426 $24
    ld   D, [HL]                                       ;; 00:1427 $56
    ld   HL, wDC0E_MapCollisionBankOffset                                     ;; 00:1428 $21 $0e $dc
    ld   A, [HL+]                                      ;; 00:142b $2a
    add  A, E                                          ;; 00:142c $83
    ld   E, A                                          ;; 00:142d $5f
    ld   A, [HL]                                       ;; 00:142e $7e
    adc  A, D                                          ;; 00:142f $8a
    ld   D, A                                          ;; 00:1430 $57
    ld   HL, wDC27                                     ;; 00:1431 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1434 $6e
    ld   H, $00                                        ;; 00:1435 $26 $00
    add  HL, DE                                        ;; 00:1437 $19
    ld   E, L                                          ;; 00:1438 $5d
    ld   D, H                                          ;; 00:1439 $54
    ld   BC, $40                                       ;; 00:143a $01 $40 $00
    ld   HL, wDC24                                     ;; 00:143d $21 $24 $dc
    ld   A, [HL-]                                      ;; 00:1440 $3a
    ld   L, [HL]                                       ;; 00:1441 $6e
    and  A, $03                                        ;; 00:1442 $e6 $03
    add  A, $c0                                        ;; 00:1444 $c6 $c0
    ld   H, A                                          ;; 00:1446 $67
    ld   A, $0b                                        ;; 00:1447 $3e $0b
.jr_00_1449:
    push AF                                            ;; 00:1449 $f5
    ld   A, [DE]                                       ;; 00:144a $1a
    ld   [HL], A                                       ;; 00:144b $77
    ld   A, [wDC1C_CurrentMapWidthAndHeightInBlocks]                                    ;; 00:144c $fa $1c $dc
    add  A, E                                          ;; 00:144f $83
    ld   E, A                                          ;; 00:1450 $5f
    ld   A, $00                                        ;; 00:1451 $3e $00
    adc  A, D                                          ;; 00:1453 $8a
    ld   D, A                                          ;; 00:1454 $57
    add  HL, BC                                        ;; 00:1455 $09
    res  2, H                                          ;; 00:1456 $cb $94
    pop  AF                                            ;; 00:1458 $f1
    dec  A                                             ;; 00:1459 $3d
    jr   NZ, .jr_00_1449                               ;; 00:145a $20 $ed
    call call_00_0f08_SwitchBank2                                  ;; 00:145c $cd $08 $0f
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:145f $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1462 $cd $ee $0e
    ld   HL, wDC26                                     ;; 00:1465 $21 $26 $dc
    ld   E, [HL]                                       ;; 00:1468 $5e
    ld   D, $cf                                        ;; 00:1469 $16 $cf
    pop  BC                                            ;; 00:146b $c1
    ld   A, [wDC0B_BlocksetBankOffset]                                    ;; 00:146c $fa $0b $dc
    add  A, C                                          ;; 00:146f $81
    ld   C, A                                          ;; 00:1470 $4f
    ld   A, [wDC0C_BlocksetBankOffset]                                    ;; 00:1471 $fa $0c $dc
    adc  A, B                                          ;; 00:1474 $88
    ld   B, A                                          ;; 00:1475 $47
    ld   A, $0b                                        ;; 00:1476 $3e $0b
.jr_00_1478:
    push AF                                            ;; 00:1478 $f5
    ld   A, [DE]                                       ;; 00:1479 $1a
    ld   L, A                                          ;; 00:147a $6f
    inc  E                                             ;; 00:147b $1c
    ld   A, [DE]                                       ;; 00:147c $1a
    ld   H, A                                          ;; 00:147d $67
    dec  E                                             ;; 00:147e $1d
    add  HL, HL                                        ;; 00:147f $29
    add  HL, HL                                        ;; 00:1480 $29
    add  HL, HL                                        ;; 00:1481 $29
    add  HL, BC                                        ;; 00:1482 $09
    ld   A, [HL+]                                      ;; 00:1483 $2a
    ld   [DE], A                                       ;; 00:1484 $12
    inc  HL                                            ;; 00:1485 $23
    inc  E                                             ;; 00:1486 $1c
    ld   A, [HL+]                                      ;; 00:1487 $2a
    ld   [DE], A                                       ;; 00:1488 $12
    dec  E                                             ;; 00:1489 $1d
    set  7, E                                          ;; 00:148a $cb $fb
    inc  HL                                            ;; 00:148c $23
    ld   A, [HL+]                                      ;; 00:148d $2a
    ld   [DE], A                                       ;; 00:148e $12
    inc  HL                                            ;; 00:148f $23
    inc  E                                             ;; 00:1490 $1c
    ld   A, [HL+]                                      ;; 00:1491 $2a
    ld   [DE], A                                       ;; 00:1492 $12
    res  7, E                                          ;; 00:1493 $cb $bb
    inc  E                                             ;; 00:1495 $1c
    res  5, E                                          ;; 00:1496 $cb $ab
    pop  AF                                            ;; 00:1498 $f1
    dec  A                                             ;; 00:1499 $3d
    jr   NZ, .jr_00_1478                               ;; 00:149a $20 $dc
    call call_00_0f08_SwitchBank2                                  ;; 00:149c $cd $08 $0f
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:149f $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:14a2 $cd $ee $0e
    ld   HL, wDC24                                     ;; 00:14a5 $21 $24 $dc
    ld   A, [HL-]                                      ;; 00:14a8 $3a
    ld   E, [HL]                                       ;; 00:14a9 $5e
    and  A, $03                                        ;; 00:14aa $e6 $03
    add  A, $c0                                        ;; 00:14ac $c6 $c0
    ld   D, A                                          ;; 00:14ae $57
    pop  BC                                            ;; 00:14af $c1
    ld   A, [wDC11_CollisionBlocksetOffset]                                    ;; 00:14b0 $fa $11 $dc
    add  A, C                                          ;; 00:14b3 $81
    ld   C, A                                          ;; 00:14b4 $4f
    ld   A, [wDC12_CollisionBlocksetOffset]                                    ;; 00:14b5 $fa $12 $dc
    adc  A, B                                          ;; 00:14b8 $88
    ld   B, A                                          ;; 00:14b9 $47
    ld   A, $0b                                        ;; 00:14ba $3e $0b
.jr_00_14bc:
    push AF                                            ;; 00:14bc $f5
    ld   A, [DE]                                       ;; 00:14bd $1a
    ld   L, A                                          ;; 00:14be $6f
    ld   H, $00                                        ;; 00:14bf $26 $00
    add  HL, HL                                        ;; 00:14c1 $29
    add  HL, HL                                        ;; 00:14c2 $29
    add  HL, BC                                        ;; 00:14c3 $09
    ld   A, [HL+]                                      ;; 00:14c4 $2a
    ld   [DE], A                                       ;; 00:14c5 $12
    ld   A, E                                          ;; 00:14c6 $7b
    add  A, $20                                        ;; 00:14c7 $c6 $20
    ld   E, A                                          ;; 00:14c9 $5f
    ld   A, D                                          ;; 00:14ca $7a
    adc  A, $00                                        ;; 00:14cb $ce $00
    ld   D, A                                          ;; 00:14cd $57
    inc  HL                                            ;; 00:14ce $23
    ld   A, [HL]                                       ;; 00:14cf $7e
    ld   [DE], A                                       ;; 00:14d0 $12
    ld   A, E                                          ;; 00:14d1 $7b
    add  A, $20                                        ;; 00:14d2 $c6 $20
    ld   E, A                                          ;; 00:14d4 $5f
    ld   A, D                                          ;; 00:14d5 $7a
    adc  A, $00                                        ;; 00:14d6 $ce $00
    ld   D, A                                          ;; 00:14d8 $57
    res  2, D                                          ;; 00:14d9 $cb $92
    pop  AF                                            ;; 00:14db $f1
    dec  A                                             ;; 00:14dc $3d
    jr   NZ, .jr_00_14bc                               ;; 00:14dd $20 $dd
    jp   call_00_0f08_SwitchBank2                                  ;; 00:14df $c3 $08 $0f

call_00_14e2:
    push BC                                            ;; 00:14e2 $c5
    push DE                                            ;; 00:14e3 $d5
    srl  B                                             ;; 00:14e4 $cb $38
    rr   C                                             ;; 00:14e6 $cb $19
    srl  B                                             ;; 00:14e8 $cb $38
    rr   C                                             ;; 00:14ea $cb $19
    srl  B                                             ;; 00:14ec $cb $38
    rr   C                                             ;; 00:14ee $cb $19
    srl  B                                             ;; 00:14f0 $cb $38
    rr   C                                             ;; 00:14f2 $cb $19
    srl  D                                             ;; 00:14f4 $cb $3a
    rr   E                                             ;; 00:14f6 $cb $1b
    srl  D                                             ;; 00:14f8 $cb $3a
    rr   E                                             ;; 00:14fa $cb $1b
    srl  D                                             ;; 00:14fc $cb $3a
    rr   E                                             ;; 00:14fe $cb $1b
    srl  D                                             ;; 00:1500 $cb $3a
    rr   E                                             ;; 00:1502 $cb $1b
    ld   A, E                                          ;; 00:1504 $7b
    ld   [wDC27], A                                    ;; 00:1505 $ea $27 $dc
    ld   A, C                                          ;; 00:1508 $79
    ld   [wDC28], A                                    ;; 00:1509 $ea $28 $dc
    pop  DE                                            ;; 00:150c $d1
    pop  BC                                            ;; 00:150d $c1
    ret                                                ;; 00:150e $c9

call_00_150f:
    ld   HL, wDC8A                                     ;; 00:150f $21 $8a $dc
    ld   E, [HL]                                       ;; 00:1512 $5e
    bit  7, E                                          ;; 00:1513 $cb $7b
    ret  NZ                                            ;; 00:1515 $c0
    ld   [HL], $ff                                     ;; 00:1516 $36 $ff
    ld   D, $00                                        ;; 00:1518 $16 $00
    ld   HL, wDB6C_CurrentLevelId                                     ;; 00:151a $21 $6c $db
    ld   L, [HL]                                       ;; 00:151d $6e
    ld   H, $00                                        ;; 00:151e $26 $00
    add  HL, HL                                        ;; 00:1520 $29
    add  HL, HL                                        ;; 00:1521 $29
    add  HL, DE                                        ;; 00:1522 $19
    ld   DE, $153f                                     ;; 00:1523 $11 $3f $15
    add  HL, DE                                        ;; 00:1526 $19
    ld   A, [HL]                                       ;; 00:1527 $7e
    cp   A, $ff                                        ;; 00:1528 $fe $ff
    ret  Z                                             ;; 00:152a $c8
    cp   A, $fe                                        ;; 00:152b $fe $fe
    jr   NZ, .jr_00_1536                               ;; 00:152d $20 $07
    ld   A, [wDCB1]                                    ;; 00:152f $fa $b1 $dc
    and  A, A                                          ;; 00:1532 $a7
    ret  Z                                             ;; 00:1533 $c8
    ld   A, $10                                        ;; 00:1534 $3e $10
.jr_00_1536:
    ld   [wDC69], A                                    ;; 00:1536 $ea $69 $dc
    ld   HL, wDB6A                                     ;; 00:1539 $21 $6a $db
    set  2, [HL]                                       ;; 00:153c $cb $d6
    ret                                                ;; 00:153e $c9
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:153f ??????.?
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00        ;; 00:1547 ????????
    db   $ff, $ff, $ff, $0a, $ff, $ff, $ff, $ff        ;; 00:154f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1557 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:155f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1567 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:156f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1577 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $05        ;; 00:157f ????.??w
    db   $08, $06, $07, $12, $ff, $ff, $ff, $ff        ;; 00:1587 ????????
    db   $14, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:158f ????????
    db   $ff, $ff, $ff, $ff, $fe, $0f, $ff, $ff        ;; 00:1597 ????????
    db   $ff, $11, $ff, $ff, $ff, $15, $ff, $ff        ;; 00:159f ????????
    db   $ff, $ff, $13, $ff, $ff, $02, $05, $03        ;; 00:15a7 ????????
    db   $ff, $ff, $04, $09, $06, $ff, $ff, $ff        ;; 00:15af ????????
    db   $ff, $ff, $08, $ff, $ff, $ff, $0a, $ff        ;; 00:15b7 ????????
    db   $ff, $ff, $0c, $ff, $ff, $ff, $0b, $ff        ;; 00:15bf ????????
    db   $ff, $0e, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15c7 ????????
    db   $ff, $ff, $0d, $ff, $10, $ff, $ff, $0c        ;; 00:15cf ????????
    db   $ff, $ff, $ff, $ff, $ff, $0f, $ff, $ff        ;; 00:15d7 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15df ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15e7 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15ef ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15f7 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:15ff ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1607 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:160f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1617 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:161f ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1627 ????????
    db   $ff, $ff, $ff, $ff                            ;; 00:162f ????

call_00_1633:
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:1633 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1636 $6e
    ld   H, $00                                        ;; 00:1637 $26 $00
    add  HL, HL                                        ;; 00:1639 $29
    ld   DE, $16a2                                     ;; 00:163a $11 $a2 $16
    add  HL, DE                                        ;; 00:163d $19
    ld   A, [HL+]                                      ;; 00:163e $2a
    ld   D, [HL]                                       ;; 00:163f $56
    ld   E, A                                          ;; 00:1640 $5f
    ld   HL, wDC69                                     ;; 00:1641 $21 $69 $dc
    ld   L, [HL]                                       ;; 00:1644 $6e
    ld   H, $00                                        ;; 00:1645 $26 $00
    add  HL, HL                                        ;; 00:1647 $29
    add  HL, HL                                        ;; 00:1648 $29
    add  HL, HL                                        ;; 00:1649 $29
    add  HL, DE                                        ;; 00:164a $19
    push HL                                            ;; 00:164b $e5
    ld   BC, $05                                       ;; 00:164c $01 $05 $00
    add  HL, BC                                        ;; 00:164f $09
    ld   A, [HL]                                       ;; 00:1650 $7e
    cp   A, $ff                                        ;; 00:1651 $fe $ff
    jr   NZ, .jr_00_1663                               ;; 00:1653 $20 $0e
    pop  HL                                            ;; 00:1655 $e1
    ld   A, [HL+]                                      ;; 00:1656 $2a
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:1657 $ea $6c $db
    ld   DE, wDC6A                                     ;; 00:165a $11 $6a $dc
    ld   BC, $04                                       ;; 00:165d $01 $04 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:1660 $c3 $6e $07
.jr_00_1663:
    ld   L, A                                          ;; 00:1663 $6f
    ld   H, $00                                        ;; 00:1664 $26 $00
    add  HL, HL                                        ;; 00:1666 $29
    add  HL, HL                                        ;; 00:1667 $29
    add  HL, HL                                        ;; 00:1668 $29
    add  HL, DE                                        ;; 00:1669 $19
    ld   DE, $03                                       ;; 00:166a $11 $03 $00
    add  HL, DE                                        ;; 00:166d $19
    ld   A, [wD810]                                    ;; 00:166e $fa $10 $d8
    sub  A, [HL]                                       ;; 00:1671 $96
    ld   E, A                                          ;; 00:1672 $5f
    inc  HL                                            ;; 00:1673 $23
    ld   A, [wD811]                                    ;; 00:1674 $fa $11 $d8
    sbc  A, [HL]                                       ;; 00:1677 $9e
    ld   D, A                                          ;; 00:1678 $57
    pop  HL                                            ;; 00:1679 $e1
    ld   A, [HL+]                                      ;; 00:167a $2a
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:167b $ea $6c $db
    ld   A, [HL+]                                      ;; 00:167e $2a
    ld   [wDC6A], A                                    ;; 00:167f $ea $6a $dc
    ld   A, [HL+]                                      ;; 00:1682 $2a
    ld   [wDC6B], A                                    ;; 00:1683 $ea $6b $dc
    ld   A, [HL+]                                      ;; 00:1686 $2a
    add  A, E                                          ;; 00:1687 $83
    ld   E, A                                          ;; 00:1688 $5f
    ld   A, [HL]                                       ;; 00:1689 $7e
    adc  A, D                                          ;; 00:168a $8a
    ld   D, A                                          ;; 00:168b $57
    bit  7, A                                          ;; 00:168c $cb $7f
    jr   NZ, .jr_00_1698                               ;; 00:168e $20 $08
    ld   A, E                                          ;; 00:1690 $7b
    sub  A, $10                                        ;; 00:1691 $d6 $10
    ld   A, D                                          ;; 00:1693 $7a
    sbc  A, $00                                        ;; 00:1694 $de $00
    jr   NC, .jr_00_169b                               ;; 00:1696 $30 $03
.jr_00_1698:
    ld   DE, $10                                       ;; 00:1698 $11 $10 $00
.jr_00_169b:
    ld   HL, wDC6C                                     ;; 00:169b $21 $6c $dc
    ld   [HL], E                                       ;; 00:169e $73
    inc  HL                                            ;; 00:169f $23
    ld   [HL], D                                       ;; 00:16a0 $72
    ret                                                ;; 00:16a1 $c9
    dw   $16c2                                         ;; 00:16a2 wW
    dw   $16f2                                         ;; 00:16a4 wW
    db   $22, $17, $e2, $17, $4a, $18, $d2, $18        ;; 00:16a6 ????????
    db   $62, $19, $b2, $19, $ba, $16, $ba, $16        ;; 00:16ae ????????
    db   $ba, $16, $e2, $19, $00, $00, $00, $00        ;; 00:16b6 ????????
    db   $00, $00, $00, $00, $00, $b0, $01             ;; 00:16be ????w..
    dw   $00f0                                         ;; 00:16c5 wW
    db   $ff, $00, $00, $00, $50, $00                  ;; 00:16c7 .??w..
    dw   $0070                                         ;; 00:16cd wW
    db   $ff, $00, $00, $00, $50, $01                  ;; 00:16cf .??w..
    dw   $0040                                         ;; 00:16d5 wW
    db   $ff, $00, $00, $0c, $f0, $00, $80, $00        ;; 00:16d7 .??w....
    db   $ff, $00, $00, $0d, $f0, $00                  ;; 00:16df .??w..
    dw   $00f0                                         ;; 00:16e5 wW
    db   $ff, $00, $00, $0e, $30, $00                  ;; 00:16e7 .??w..
    dw   $0030                                         ;; 00:16ed wW
    db   $ff, $00, $00, $0f, $20, $01, $80, $00        ;; 00:16ef .??w....
    db   $ff, $00, $00, $10, $20, $00, $30, $01        ;; 00:16f7 .???????
    db   $ff, $00, $00, $11, $30, $01, $60, $00        ;; 00:16ff ???w...W
    db   $ff, $00, $00, $01, $60, $09                  ;; 00:1707 .??w..
    dw   $0400                                         ;; 00:170d wW
    db   $ff, $00, $00, $01, $a0, $07, $00, $01        ;; 00:170f .???????
    db   $ff, $00, $00, $01, $c8, $02, $80, $00        ;; 00:1717 ???w....
    db   $ff, $00, $00, $12, $c0, $00, $60, $02        ;; 00:171f .???????
    db   $ff, $00, $00, $14, $20, $00, $80, $00        ;; 00:1727 ????????
    db   $ff, $00, $00, $15, $20, $01, $30, $01        ;; 00:172f ????????
    db   $ff, $00, $00, $16, $20, $00, $e0, $01        ;; 00:1737 ????????
    db   $ff, $00, $00, $16, $20, $01, $e0, $01        ;; 00:173f ????????
    db   $ff, $00, $00, $17, $48, $00, $60, $00        ;; 00:1747 ????????
    db   $ff, $00, $00, $02, $98, $02, $b0, $02        ;; 00:174f ????????
    db   $ff, $00, $00, $13, $18, $00, $68, $00        ;; 00:1757 ????????
    db   $ff, $00, $00, $13, $b8, $02, $68, $00        ;; 00:175f ????????
    db   $ff, $00, $00, $12, $10, $00, $cc, $00        ;; 00:1767 ????????
    db   $ff, $00, $00, $12, $38, $02, $10, $00        ;; 00:176f ????????
    db   $ff, $00, $00, $02, $28, $02, $b0, $02        ;; 00:1777 ????????
    db   $ff, $00, $00, $02, $68, $02, $d0, $01        ;; 00:177f ????????
    db   $ff, $00, $00, $02, $d8, $00, $40, $01        ;; 00:1787 ????????
    db   $ff, $00, $00, $02, $f8, $01, $80, $00        ;; 00:178f ????????
    db   $ff, $00, $00, $02, $28, $00, $50, $00        ;; 00:1797 ????????
    db   $ff, $00, $00, $18, $50, $00, $70, $00        ;; 00:179f ????????
    db   $ff, $00, $00, $17, $50, $00, $10, $00        ;; 00:17a7 ????????
    db   $ff, $00, $00, $1a, $10, $00, $d8, $02        ;; 00:17af ????????
    db   $ff, $00, $00, $12, $70, $02, $2c, $02        ;; 00:17b7 ????????
    db   $ff, $00, $00, $19, $a0, $00, $80, $02        ;; 00:17bf ????????
    db   $ff, $00, $00, $14, $a0, $00, $10, $00        ;; 00:17c7 ????????
    db   $ff, $00, $00, $02, $08, $01, $50, $02        ;; 00:17cf ????????
    db   $ff, $00, $00, $02, $a8, $02, $d0, $01        ;; 00:17d7 ????????
    db   $ff, $00, $00, $1b, $10, $00, $00, $03        ;; 00:17df ????????
    db   $05, $00, $00, $1d, $54, $04, $10, $00        ;; 00:17e7 ????????
    db   $ff, $00, $00, $1d, $54, $04, $10, $00        ;; 00:17ef ????????
    db   $ff, $00, $00, $1c, $10, $00, $40, $01        ;; 00:17f7 ????????
    db   $04, $00, $00, $1b, $30, $03, $00, $03        ;; 00:17ff ????????
    db   $03, $00, $00, $03, $60, $02, $d0, $00        ;; 00:1807 ????????
    db   $00, $00, $00, $03, $48, $00, $10, $01        ;; 00:180f ????????
    db   $ff, $00, $00, $1e, $10, $00, $78, $00        ;; 00:1817 ????????
    db   $ff, $00, $00, $1b, $ec, $00, $60, $02        ;; 00:181f ????????
    db   $ff, $00, $00, $1f, $08, $00, $70, $00        ;; 00:1827 ????????
    db   $0a, $00, $00, $1c, $30, $06, $40, $01        ;; 00:182f ????????
    db   $09, $00, $00, $20, $10, $00, $60, $01        ;; 00:1837 ????????
    db   $ff, $00, $00, $1b, $7c, $02, $60, $02        ;; 00:183f ????????
    db   $ff, $00, $00, $23, $10, $00, $70, $00        ;; 00:1847 ????????
    db   $ff, $00, $00, $04, $c0, $00, $50, $01        ;; 00:184f ????????
    db   $ff, $00, $00, $26, $10, $00, $70, $00        ;; 00:1857 ????????
    db   $ff, $00, $00, $04, $10, $01, $50, $01        ;; 00:185f ????????
    db   $ff, $00, $00, $27, $10, $00, $00, $01        ;; 00:1867 ????????
    db   $ff, $00, $00, $04, $98, $01, $a0, $00        ;; 00:186f ????????
    db   $ff, $00, $00, $28, $10, $00, $70, $00        ;; 00:1877 ????????
    db   $ff, $00, $00, $04, $f0, $01, $50, $01        ;; 00:187f ????????
    db   $ff, $00, $00, $22, $30, $01, $90, $00        ;; 00:1887 ????????
    db   $ff, $00, $00, $21, $aa, $01, $98, $00        ;; 00:188f ????????
    db   $ff, $00, $00, $21, $10, $00, $40, $01        ;; 00:1897 ????????
    db   $0b, $00, $00, $04, $70, $02, $50, $01        ;; 00:189f ????????
    db   $0a, $00, $00, $24, $10, $00, $00, $01        ;; 00:18a7 ????????
    db   $0d, $00, $00, $25, $c0, $07, $48, $02        ;; 00:18af ????????
    db   $0c, $00, $00, $25, $28, $00, $10, $00        ;; 00:18b7 ????????
    db   $ff, $00, $00, $25, $68, $03, $10, $00        ;; 00:18bf ????????
    db   $ff, $00, $00, $27, $60, $00, $10, $01        ;; 00:18c7 ????????
    db   $ff, $00, $00, $2b, $30, $00, $80, $02        ;; 00:18cf ????????
    db   $ff, $00, $00, $2c, $a0, $09, $80, $00        ;; 00:18d7 ????????
    db   $ff, $00, $00, $29, $30, $00, $c0, $01        ;; 00:18df ????????
    db   $ff, $00, $00, $05, $c0, $00, $c0, $01        ;; 00:18e7 ????????
    db   $ff, $00, $00, $05, $f0, $01, $c0, $01        ;; 00:18ef ????????
    db   $ff, $00, $00, $05, $20, $03, $c0, $01        ;; 00:18f7 ????????
    db   $ff, $00, $00, $29, $20, $00, $00, $01        ;; 00:18ff ????????
    db   $ff, $00, $00, $29, $e0, $02, $00, $01        ;; 00:1907 ????????
    db   $ff, $00, $00, $2a, $c0, $01, $80, $00        ;; 00:190f ????????
    db   $ff, $00, $00, $2a, $c0, $01, $80, $00        ;; 00:1917 ????????
    db   $ff, $00, $00, $2c, $e0, $03, $40, $01        ;; 00:191f ????????
    db   $ff, $00, $00, $30, $b0, $03, $40, $01        ;; 00:1927 ????????
    db   $ff, $00, $00, $30, $70, $01, $a0, $00        ;; 00:192f ????????
    db   $ff, $00, $00, $30, $50, $02, $30, $00        ;; 00:1937 ????????
    db   $ff, $00, $00, $30, $30, $03, $a0, $00        ;; 00:193f ????????
    db   $ff, $00, $00, $2d, $a0, $01, $f0, $00        ;; 00:1947 ????????
    db   $ff, $00, $00, $2e, $f0, $00, $00, $02        ;; 00:194f ????????
    db   $ff, $00, $00, $2f, $50, $00, $10, $03        ;; 00:1957 ????????
    db   $ff, $00, $00, $31, $c0, $0b, $a0, $02        ;; 00:195f ????????
    db   $ff, $00, $00, $06, $70, $00, $b0, $00        ;; 00:1967 ????????
    db   $ff, $00, $00, $32, $60, $00, $80, $00        ;; 00:196f ????????
    db   $ff, $00, $00, $06, $70, $00, $00, $01        ;; 00:1977 ????????
    db   $ff, $00, $00, $33, $e0, $00, $a0, $01        ;; 00:197f ????????
    db   $ff, $00, $00, $31, $80, $00, $20, $03        ;; 00:1987 ????????
    db   $ff, $00, $00, $34, $a0, $02, $c0, $01        ;; 00:198f ????????
    db   $ff, $00, $00, $31, $40, $04, $00, $01        ;; 00:1997 ????????
    db   $ff, $00, $00, $35, $50, $00, $60, $00        ;; 00:199f ????????
    db   $ff, $00, $00, $34, $a0, $02, $80, $00        ;; 00:19a7 ????????
    db   $ff, $00, $00, $36, $20, $00, $30, $01        ;; 00:19af ????????
    db   $ff, $00, $00, $37, $20, $00, $30, $01        ;; 00:19b7 ????????
    db   $ff, $00, $00, $38, $20, $00, $30, $01        ;; 00:19bf ????????
    db   $ff, $00, $00, $07, $7c, $02, $b8, $02        ;; 00:19c7 ????????
    db   $ff, $00, $00, $07, $fc, $01, $b8, $01        ;; 00:19cf ????????
    db   $ff, $00, $00, $07, $8c, $01, $f8, $00        ;; 00:19d7 ????????
    db   $ff, $00, $00, $39, $00, $01, $b0, $00        ;; 00:19df ????????
    db   $ff, $00, $00, $39, $30, $00, $f0, $00        ;; 00:19e7 ????????
    db   $ff, $00, $00, $39, $c0, $01, $f0, $00        ;; 00:19ef ????????
    db   $ff, $00, $00, $39, $00, $01, $20, $00        ;; 00:19f7 ????????
    db   $ff, $00, $00, $0b, $60, $02, $c0, $00        ;; 00:19ff ????????
    db   $ff, $00, $00, $3a, $38, $01, $80, $01        ;; 00:1a07 ????????
    db   $ff, $00, $00, $3b, $38, $01, $80, $01        ;; 00:1a0f ????????
    db   $ff, $00, $00, $3c, $78, $00, $68, $00        ;; 00:1a17 ????????
    db   $ff, $00, $00                                 ;; 00:1a1f ???

call_00_1a22_LoadBgMapInitial:
    ld   [wDC33], A                                    ;; 00:1a22 $ea $33 $dc
    ld   A, $16                                        ;; 00:1a25 $3e $16
.jr_00_1a27:
    push AF                                            ;; 00:1a27 $f5
    call call_00_1a46_LoadBgMapInitial2                                  ;; 00:1a28 $cd $46 $1a
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1a2b $21 $fb $db
    ld   A, [HL]                                       ;; 00:1a2e $7e
    add  A, $08                                        ;; 00:1a2f $c6 $08
    ld   [HL+], A                                      ;; 00:1a31 $22
    ld   A, [HL]                                       ;; 00:1a32 $7e
    adc  A, $00                                        ;; 00:1a33 $ce $00
    ld   [HL], A                                       ;; 00:1a35 $77
    pop  AF                                            ;; 00:1a36 $f1
    dec  A                                             ;; 00:1a37 $3d
    jr   NZ, .jr_00_1a27                               ;; 00:1a38 $20 $ed
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1a3a $21 $fb $db
    ld   A, [HL]                                       ;; 00:1a3d $7e
    sub  A, $b0                                        ;; 00:1a3e $d6 $b0
    ld   [HL+], A                                      ;; 00:1a40 $22
    ld   A, [HL]                                       ;; 00:1a41 $7e
    sbc  A, $00                                        ;; 00:1a42 $de $00
    ld   [HL], A                                       ;; 00:1a44 $77
    ret                                                ;; 00:1a45 $c9

call_00_1a46_LoadBgMapInitial2:
    ld   HL, wDBFB_YPositionInMap                                     ;; 00:1a46 $21 $fb $db
    ld   A, [HL+]                                      ;; 00:1a49 $2a
    sub  A, $01                                        ;; 00:1a4a $d6 $01
    ld   C, A                                          ;; 00:1a4c $4f
    ld   A, [HL]                                       ;; 00:1a4d $7e
    sbc  A, $00                                        ;; 00:1a4e $de $00
    ld   B, A                                          ;; 00:1a50 $47
    ld   HL, wDBF9_XPositionInMap                                     ;; 00:1a51 $21 $f9 $db
    ld   A, [HL+]                                      ;; 00:1a54 $2a
    ld   E, A                                          ;; 00:1a55 $5f
    ld   D, [HL]                                       ;; 00:1a56 $56
    call call_00_14e2                                  ;; 00:1a57 $cd $e2 $14
    ld   A, C                                          ;; 00:1a5a $79
    and  A, $f8                                        ;; 00:1a5b $e6 $f8
    ld   L, A                                          ;; 00:1a5d $6f
    ld   H, $00                                        ;; 00:1a5e $26 $00
    add  HL, HL                                        ;; 00:1a60 $29
    add  HL, HL                                        ;; 00:1a61 $29
    ld   A, E                                          ;; 00:1a62 $7b
    swap A                                             ;; 00:1a63 $cb $37
    add  A, A                                          ;; 00:1a65 $87
    and  A, $1e                                        ;; 00:1a66 $e6 $1e
    ld   [wDC25], A                                    ;; 00:1a68 $ea $25 $dc
    or   A, L                                          ;; 00:1a6b $b5
    ld   [wDC21], A                                    ;; 00:1a6c $ea $21 $dc
    ld   A, H                                          ;; 00:1a6f $7c
    or   A, $98                                        ;; 00:1a70 $f6 $98
    ld   [wDC22], A                                    ;; 00:1a72 $ea $22 $dc
    ld   A, C                                          ;; 00:1a75 $79
    rrca                                               ;; 00:1a76 $0f
    rrca                                               ;; 00:1a77 $0f
    and  A, $02                                        ;; 00:1a78 $e6 $02
    ld   E, A                                          ;; 00:1a7a $5f
    ld   A, [wDC33]                                    ;; 00:1a7b $fa $33 $dc
    and  A, $7f                                        ;; 00:1a7e $e6 $7f
    or   A, E                                          ;; 00:1a80 $b3
    ld   E, A                                          ;; 00:1a81 $5f
    ld   D, $00                                        ;; 00:1a82 $16 $00
    push DE                                            ;; 00:1a84 $d5
    ld   A, [wDC33]                                    ;; 00:1a85 $fa $33 $dc
    bit  7, A                                          ;; 00:1a88 $cb $7f
    jp   NZ, .jp_00_1b40                               ;; 00:1a8a $c2 $40 $1b
    ld   A, [wDC01_MapBank]                                    ;; 00:1a8d $fa $01 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1a90 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1a93 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1a96 $6e
    ld   H, $cd                                        ;; 00:1a97 $26 $cd
    ld   E, [HL]                                       ;; 00:1a99 $5e
    inc  H                                             ;; 00:1a9a $24
    ld   D, [HL]                                       ;; 00:1a9b $56
    ld   HL, wDC02_MapBankOffset                                     ;; 00:1a9c $21 $02 $dc
    ld   A, [HL+]                                      ;; 00:1a9f $2a
    add  A, E                                          ;; 00:1aa0 $83
    ld   E, A                                          ;; 00:1aa1 $5f
    ld   A, [HL]                                       ;; 00:1aa2 $7e
    adc  A, D                                          ;; 00:1aa3 $8a
    ld   D, A                                          ;; 00:1aa4 $57
    ld   HL, wDC27                                     ;; 00:1aa5 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1aa8 $6e
    ld   H, $00                                        ;; 00:1aa9 $26 $00
    add  HL, DE                                        ;; 00:1aab $19
    ld   E, L                                          ;; 00:1aac $5d
    ld   D, H                                          ;; 00:1aad $54
    ld   HL, wDC25                                     ;; 00:1aae $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1ab1 $6e
    ld   H, $cf                                        ;; 00:1ab2 $26 $cf
    ld   B, $0b                                        ;; 00:1ab4 $06 $0b
.jr_00_1ab6:
    ld   A, [DE]                                       ;; 00:1ab6 $1a
    ld   [HL+], A                                      ;; 00:1ab7 $22
    inc  L                                             ;; 00:1ab8 $2c
    res  5, L                                          ;; 00:1ab9 $cb $ad
    inc  DE                                            ;; 00:1abb $13
    dec  B                                             ;; 00:1abc $05
    jr   NZ, .jr_00_1ab6                               ;; 00:1abd $20 $f7
    call call_00_0f08_SwitchBank2                                  ;; 00:1abf $cd $08 $0f
    ld   A, [wDC04_MapExtendedBank]                                    ;; 00:1ac2 $fa $04 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1ac5 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1ac8 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1acb $6e
    ld   H, $cd                                        ;; 00:1acc $26 $cd
    ld   E, [HL]                                       ;; 00:1ace $5e
    inc  H                                             ;; 00:1acf $24
    ld   D, [HL]                                       ;; 00:1ad0 $56
    ld   HL, wDC05_MapExtendedBankOffset                                     ;; 00:1ad1 $21 $05 $dc
    ld   A, [HL+]                                      ;; 00:1ad4 $2a
    add  A, E                                          ;; 00:1ad5 $83
    ld   E, A                                          ;; 00:1ad6 $5f
    ld   A, [HL]                                       ;; 00:1ad7 $7e
    adc  A, D                                          ;; 00:1ad8 $8a
    ld   D, A                                          ;; 00:1ad9 $57
    ld   HL, wDC27                                     ;; 00:1ada $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1add $6e
    ld   H, $00                                        ;; 00:1ade $26 $00
    add  HL, DE                                        ;; 00:1ae0 $19
    ld   E, L                                          ;; 00:1ae1 $5d
    ld   D, H                                          ;; 00:1ae2 $54
    ld   HL, wDC25                                     ;; 00:1ae3 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1ae6 $6e
    inc  L                                             ;; 00:1ae7 $2c
    ld   H, $cf                                        ;; 00:1ae8 $26 $cf
    ld   B, $0b                                        ;; 00:1aea $06 $0b
.jr_00_1aec:
    ld   A, [DE]                                       ;; 00:1aec $1a
    ld   [HL+], A                                      ;; 00:1aed $22
    res  5, L                                          ;; 00:1aee $cb $ad
    inc  L                                             ;; 00:1af0 $2c
    inc  DE                                            ;; 00:1af1 $13
    dec  B                                             ;; 00:1af2 $05
    jr   NZ, .jr_00_1aec                               ;; 00:1af3 $20 $f7
    call call_00_0f08_SwitchBank2                                  ;; 00:1af5 $cd $08 $0f
    ld   A, [wDC0A_BlocksetBank]                                    ;; 00:1af8 $fa $0a $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1afb $cd $ee $0e
    ld   HL, wDC22                                     ;; 00:1afe $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:1b01 $3a
    ld   C, [HL]                                       ;; 00:1b02 $4e
    and  A, $03                                        ;; 00:1b03 $e6 $03
    add  A, $c0                                        ;; 00:1b05 $c6 $c0
    ld   B, A                                          ;; 00:1b07 $47
    ld   HL, wDC25                                     ;; 00:1b08 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1b0b $6e
    ld   H, $cf                                        ;; 00:1b0c $26 $cf
    pop  DE                                            ;; 00:1b0e $d1
    ld   A, [wDC0B_BlocksetBankOffset]                                    ;; 00:1b0f $fa $0b $dc
    add  A, E                                          ;; 00:1b12 $83
    ld   E, A                                          ;; 00:1b13 $5f
    ld   A, [wDC0C_BlocksetBankOffset]                                    ;; 00:1b14 $fa $0c $dc
    adc  A, D                                          ;; 00:1b17 $8a
    ld   D, A                                          ;; 00:1b18 $57
    ld   A, $0b                                        ;; 00:1b19 $3e $0b
.jr_00_1b1b:
    push AF                                            ;; 00:1b1b $f5
    push HL                                            ;; 00:1b1c $e5
    ld   A, [HL+]                                      ;; 00:1b1d $2a
    ld   H, [HL]                                       ;; 00:1b1e $66
    ld   L, A                                          ;; 00:1b1f $6f
    add  HL, HL                                        ;; 00:1b20 $29
    add  HL, HL                                        ;; 00:1b21 $29
    add  HL, HL                                        ;; 00:1b22 $29
    add  HL, DE                                        ;; 00:1b23 $19
    ld   A, [HL+]                                      ;; 00:1b24 $2a
    ld   [BC], A                                       ;; 00:1b25 $02
    inc  BC                                            ;; 00:1b26 $03
    ld   A, [HL]                                       ;; 00:1b27 $7e
    ld   [BC], A                                       ;; 00:1b28 $02
    inc  BC                                            ;; 00:1b29 $03
    ld   A, C                                          ;; 00:1b2a $79
    and  A, $1f                                        ;; 00:1b2b $e6 $1f
    jr   NZ, .jr_00_1b34                               ;; 00:1b2d $20 $05
    dec  BC                                            ;; 00:1b2f $0b
    ld   A, C                                          ;; 00:1b30 $79
    and  A, $e0                                        ;; 00:1b31 $e6 $e0
    ld   C, A                                          ;; 00:1b33 $4f
.jr_00_1b34:
    pop  HL                                            ;; 00:1b34 $e1
    inc  L                                             ;; 00:1b35 $2c
    inc  L                                             ;; 00:1b36 $2c
    res  5, L                                          ;; 00:1b37 $cb $ad
    pop  AF                                            ;; 00:1b39 $f1
    dec  A                                             ;; 00:1b3a $3d
    jr   NZ, .jr_00_1b1b                               ;; 00:1b3b $20 $de
    jp   call_00_0f08_SwitchBank2                                  ;; 00:1b3d $c3 $08 $0f
.jp_00_1b40:
    ld   A, [wDC0D_MapCollisionBank]                                    ;; 00:1b40 $fa $0d $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1b43 $cd $ee $0e
    ld   HL, wDC28                                     ;; 00:1b46 $21 $28 $dc
    ld   L, [HL]                                       ;; 00:1b49 $6e
    ld   H, $cd                                        ;; 00:1b4a $26 $cd
    ld   E, [HL]                                       ;; 00:1b4c $5e
    inc  H                                             ;; 00:1b4d $24
    ld   D, [HL]                                       ;; 00:1b4e $56
    ld   HL, wDC0E_MapCollisionBankOffset                                     ;; 00:1b4f $21 $0e $dc
    ld   A, [HL+]                                      ;; 00:1b52 $2a
    add  A, E                                          ;; 00:1b53 $83
    ld   E, A                                          ;; 00:1b54 $5f
    ld   A, [HL]                                       ;; 00:1b55 $7e
    adc  A, D                                          ;; 00:1b56 $8a
    ld   D, A                                          ;; 00:1b57 $57
    ld   HL, wDC27                                     ;; 00:1b58 $21 $27 $dc
    ld   L, [HL]                                       ;; 00:1b5b $6e
    ld   H, $00                                        ;; 00:1b5c $26 $00
    add  HL, DE                                        ;; 00:1b5e $19
    ld   E, L                                          ;; 00:1b5f $5d
    ld   D, H                                          ;; 00:1b60 $54
    ld   HL, wDC25                                     ;; 00:1b61 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1b64 $6e
    ld   H, $cf                                        ;; 00:1b65 $26 $cf
    ld   B, $0b                                        ;; 00:1b67 $06 $0b
.jr_00_1b69:
    ld   A, [DE]                                       ;; 00:1b69 $1a
    ld   [HL+], A                                      ;; 00:1b6a $22
    inc  L                                             ;; 00:1b6b $2c
    res  5, L                                          ;; 00:1b6c $cb $ad
    inc  DE                                            ;; 00:1b6e $13
    dec  B                                             ;; 00:1b6f $05
    jr   NZ, .jr_00_1b69                               ;; 00:1b70 $20 $f7
    call call_00_0f08_SwitchBank2                                  ;; 00:1b72 $cd $08 $0f
    ld   A, [wDC10_CollisionBlockset]                                    ;; 00:1b75 $fa $10 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:1b78 $cd $ee $0e
    ld   HL, wDC22                                     ;; 00:1b7b $21 $22 $dc
    ld   A, [HL-]                                      ;; 00:1b7e $3a
    ld   C, [HL]                                       ;; 00:1b7f $4e
    and  A, $03                                        ;; 00:1b80 $e6 $03
    add  A, $c0                                        ;; 00:1b82 $c6 $c0
    ld   B, A                                          ;; 00:1b84 $47
    ld   HL, wDC25                                     ;; 00:1b85 $21 $25 $dc
    ld   L, [HL]                                       ;; 00:1b88 $6e
    ld   H, $cf                                        ;; 00:1b89 $26 $cf
    pop  DE                                            ;; 00:1b8b $d1
    ld   A, [wDC11_CollisionBlocksetOffset]                                    ;; 00:1b8c $fa $11 $dc
    add  A, E                                          ;; 00:1b8f $83
    ld   E, A                                          ;; 00:1b90 $5f
    ld   A, [wDC12_CollisionBlocksetOffset]                                    ;; 00:1b91 $fa $12 $dc
    adc  A, D                                          ;; 00:1b94 $8a
    ld   D, A                                          ;; 00:1b95 $57
    ld   A, $0b                                        ;; 00:1b96 $3e $0b
.jr_00_1b98:
    push AF                                            ;; 00:1b98 $f5
    push HL                                            ;; 00:1b99 $e5
    ld   L, [HL]                                       ;; 00:1b9a $6e
    ld   H, $00                                        ;; 00:1b9b $26 $00
    add  HL, HL                                        ;; 00:1b9d $29
    add  HL, HL                                        ;; 00:1b9e $29
    add  HL, DE                                        ;; 00:1b9f $19
    ld   A, [HL+]                                      ;; 00:1ba0 $2a
    ld   [BC], A                                       ;; 00:1ba1 $02
    inc  BC                                            ;; 00:1ba2 $03
    ld   A, [HL]                                       ;; 00:1ba3 $7e
    ld   [BC], A                                       ;; 00:1ba4 $02
    inc  BC                                            ;; 00:1ba5 $03
    ld   A, C                                          ;; 00:1ba6 $79
    and  A, $1f                                        ;; 00:1ba7 $e6 $1f
    jr   NZ, .jr_00_1bb0                               ;; 00:1ba9 $20 $05
    dec  BC                                            ;; 00:1bab $0b
    ld   A, C                                          ;; 00:1bac $79
    and  A, $e0                                        ;; 00:1bad $e6 $e0
    ld   C, A                                          ;; 00:1baf $4f
.jr_00_1bb0:
    pop  HL                                            ;; 00:1bb0 $e1
    inc  L                                             ;; 00:1bb1 $2c
    inc  L                                             ;; 00:1bb2 $2c
    res  5, L                                          ;; 00:1bb3 $cb $ad
    pop  AF                                            ;; 00:1bb5 $f1
    dec  A                                             ;; 00:1bb6 $3d
    jr   NZ, .jr_00_1b98                               ;; 00:1bb7 $20 $df
    jp   call_00_0f08_SwitchBank2                                  ;; 00:1bb9 $c3 $08 $0f

call_00_1bbc:
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:1bbc $fa $1e $dc
    cp   A, $05                                        ;; 00:1bbf $fe $05
    ret  Z                                             ;; 00:1bc1 $c8
    cp   A, $0b                                        ;; 00:1bc2 $fe $0b
    ret  Z                                             ;; 00:1bc4 $c8
    and  A, A                                          ;; 00:1bc5 $a7
    jr   Z, .jr_00_1bce                                ;; 00:1bc6 $28 $06
    ld   A, [wDCD2]                                    ;; 00:1bc8 $fa $d2 $dc
    cp   A, $81                                        ;; 00:1bcb $fe $81
    ret  Z                                             ;; 00:1bcd $c8
.jr_00_1bce:
    ld   HL, wDB6C_CurrentLevelId                                     ;; 00:1bce $21 $6c $db
    ld   L, [HL]                                       ;; 00:1bd1 $6e
    ld   H, $00                                        ;; 00:1bd2 $26 $00
    add  HL, HL                                        ;; 00:1bd4 $29
    ld   DE, $1c33                                     ;; 00:1bd5 $11 $33 $1c
    add  HL, DE                                        ;; 00:1bd8 $19
    ld   A, [HL+]                                      ;; 00:1bd9 $2a
    ld   H, [HL]                                       ;; 00:1bda $66
    ld   L, A                                          ;; 00:1bdb $6f
    or   A, H                                          ;; 00:1bdc $b4
    ret  Z                                             ;; 00:1bdd $c8
.jr_00_1bde:
    ld   A, [HL+]                                      ;; 00:1bde $2a
    ld   [wDCC1], A                                    ;; 00:1bdf $ea $c1 $dc
    ld   A, [HL+]                                      ;; 00:1be2 $2a
    ld   [wDCC2], A                                    ;; 00:1be3 $ea $c2 $dc
    ld   E, [HL]                                       ;; 00:1be6 $5e
    inc  HL                                            ;; 00:1be7 $23
    ld   D, [HL]                                       ;; 00:1be8 $56
    inc  HL                                            ;; 00:1be9 $23
    ld   A, [wD810]                                    ;; 00:1bea $fa $10 $d8
    sub  A, [HL]                                       ;; 00:1bed $96
    ld   B, A                                          ;; 00:1bee $47
    inc  HL                                            ;; 00:1bef $23
    ld   A, [wD811]                                    ;; 00:1bf0 $fa $11 $d8
    sbc  A, [HL]                                       ;; 00:1bf3 $9e
    inc  HL                                            ;; 00:1bf4 $23
    or   A, B                                          ;; 00:1bf5 $b0
    jr   NZ, .jr_00_1c10                               ;; 00:1bf6 $20 $18
    ld   A, [wD80E]                                    ;; 00:1bf8 $fa $0e $d8
    sub  A, E                                          ;; 00:1bfb $93
    ld   E, A                                          ;; 00:1bfc $5f
    ld   A, [wD80F]                                    ;; 00:1bfd $fa $0f $d8
    sbc  A, D                                          ;; 00:1c00 $9a
    ld   D, A                                          ;; 00:1c01 $57
    ld   A, E                                          ;; 00:1c02 $7b
    add  A, $08                                        ;; 00:1c03 $c6 $08
    ld   E, A                                          ;; 00:1c05 $5f
    ld   A, D                                          ;; 00:1c06 $7a
    adc  A, $00                                        ;; 00:1c07 $ce $00
    jr   NZ, .jr_00_1c10                               ;; 00:1c09 $20 $05
    ld   A, E                                          ;; 00:1c0b $7b
    cp   A, $10                                        ;; 00:1c0c $fe $10
    jr   C, .jr_00_1c16                                ;; 00:1c0e $38 $06
.jr_00_1c10:
    ld   A, [HL]                                       ;; 00:1c10 $7e
    cp   A, $ff                                        ;; 00:1c11 $fe $ff
    jr   NZ, .jr_00_1bde                               ;; 00:1c13 $20 $c9
    ret                                                ;; 00:1c15 $c9
.jr_00_1c16:
    ld   A, [wDCC2]                                    ;; 00:1c16 $fa $c2 $dc
    cp   A, $ff                                        ;; 00:1c19 $fe $ff
    jr   Z, .jr_00_1c27                                ;; 00:1c1b $28 $0a
    ld   E, A                                          ;; 00:1c1d $5f
    ld   D, $00                                        ;; 00:1c1e $16 $00
    ld   HL, wDCB1                                     ;; 00:1c20 $21 $b1 $dc
    add  HL, DE                                        ;; 00:1c23 $19
    ld   A, [HL]                                       ;; 00:1c24 $7e
    and  A, A                                          ;; 00:1c25 $a7
    ret  Z                                             ;; 00:1c26 $c8
.jr_00_1c27:
    ld   A, [wDCC1]                                    ;; 00:1c27 $fa $c1 $dc
    ld   [wDC69], A                                    ;; 00:1c2a $ea $69 $dc
    ld   HL, wDB6A                                     ;; 00:1c2d $21 $6a $db
    set  2, [HL]                                       ;; 00:1c30 $cb $d6
    ret                                                ;; 00:1c32 $c9
    db   $ad, $1c, $d5, $1c, $f6, $1c, $00, $00        ;; 00:1c33 ....????
    db   $5c, $1d, $9f, $1d, $08, $1e, $4a, $1e        ;; 00:1c3b ????????
    db   $00, $00, $00, $00, $00, $00, $72, $1e        ;; 00:1c43 ????????
    db   $c0, $1c, $c7, $1c, $ce, $1c, $e8, $1c        ;; 00:1c4b ........
    db   $ef, $1c, $00, $00, $00, $00, $27, $1d        ;; 00:1c53 ????????
    db   $34, $1d, $3b, $1d, $42, $1d, $00, $00        ;; 00:1c5b ????????
    db   $00, $00, $00, $00, $00, $00, $4f, $1d        ;; 00:1c63 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:1c6b ????????
    db   $00, $00, $75, $1d, $7c, $1d, $83, $1d        ;; 00:1c73 ????????
    db   $00, $00, $00, $00, $8a, $1d, $91, $1d        ;; 00:1c7b ????????
    db   $98, $1d, $b2, $1d, $bf, $1d, $c6, $1d        ;; 00:1c83 ????????
    db   $cd, $1d, $da, $1d, $e1, $1d, $e8, $1d        ;; 00:1c8b ????????
    db   $ef, $1d, $15, $1e, $28, $1e, $2f, $1e        ;; 00:1c93 ????????
    db   $36, $1e, $43, $1e, $5d, $1e, $64, $1e        ;; 00:1c9b ????????
    db   $6b, $1e, $79, $1e, $92, $1e, $99, $1e        ;; 00:1ca3 ????????
    db   $00, $00, $03, $ff, $b0, $01, $f0, $00        ;; 00:1cab ??w...??
    db   $04, $ff, $50, $00, $70, $00, $05, $ff        ;; 00:1cb3 w...??w.
    db   $50, $01, $40, $00, $ff, $00, $ff, $f0        ;; 00:1cbb ..??.w..
    db   $00, $80, $00, $ff, $01, $ff, $f0, $00        ;; 00:1cc3 .???w...
    db   $f0, $00, $ff, $02, $ff, $30, $00, $30        ;; 00:1ccb ???w...?
    db   $00, $ff, $00, $ff, $60, $09, $00, $04        ;; 00:1cd3 ??w...??
    db   $01, $ff, $a0, $07, $00, $01, $02, $ff        ;; 00:1cdb ....??w.
    db   $c8, $02, $80, $00, $ff, $03, $ff, $20        ;; 00:1ce3 ..??.w..
    db   $01, $80, $00, $ff, $04, $ff, $20, $00        ;; 00:1ceb .??.????
    db   $30, $01, $ff, $00, $ff, $98, $02, $b0        ;; 00:1cf3 ????????
    db   $02, $01, $ff, $28, $02, $b0, $02, $02        ;; 00:1cfb ????????
    db   $ff, $68, $02, $d0, $01, $03, $ff, $d8        ;; 00:1d03 ????????
    db   $00, $40, $01, $04, $ff, $f8, $01, $80        ;; 00:1d0b ????????
    db   $00, $05, $ff, $28, $00, $50, $00, $17        ;; 00:1d13 ????????
    db   $ff, $08, $01, $50, $02, $16, $ff, $a8        ;; 00:1d1b ????????
    db   $02, $d0, $01, $ff, $09, $ff, $18, $00        ;; 00:1d23 ????????
    db   $68, $00, $0a, $ff, $b8, $02, $68, $00        ;; 00:1d2b ????????
    db   $ff, $0b, $ff, $20, $00, $80, $00, $ff        ;; 00:1d33 ????????
    db   $0c, $ff, $20, $01, $30, $01, $ff, $0d        ;; 00:1d3b ????????
    db   $ff, $20, $00, $e0, $01, $0e, $ff, $20        ;; 00:1d43 ????????
    db   $01, $e0, $01, $ff, $07, $00, $ec, $00        ;; 00:1d4b ????????
    db   $60, $02, $0b, $01, $7c, $02, $60, $02        ;; 00:1d53 ????????
    db   $ff, $00, $ff, $c0, $00, $50, $01, $02        ;; 00:1d5b ????????
    db   $ff, $10, $01, $50, $01, $04, $ff, $98        ;; 00:1d63 ????????
    db   $01, $a0, $00, $06, $ff, $f0, $01, $50        ;; 00:1d6b ????????
    db   $01, $ff, $08, $ff, $aa, $01, $98, $00        ;; 00:1d73 ????????
    db   $ff, $09, $ff, $30, $01, $90, $00, $ff        ;; 00:1d7b ????????
    db   $01, $ff, $10, $00, $70, $00, $ff, $03        ;; 00:1d83 ????????
    db   $ff, $10, $00, $70, $00, $ff, $05, $ff        ;; 00:1d8b ????????
    db   $10, $00, $00, $01, $ff, $07, $ff, $10        ;; 00:1d93 ????????
    db   $00, $70, $00, $ff, $00, $ff, $c0, $00        ;; 00:1d9b ????????
    db   $c0, $01, $01, $ff, $f0, $01, $c0, $01        ;; 00:1da3 ????????
    db   $02, $ff, $20, $03, $c0, $01, $ff, $05        ;; 00:1dab ????????
    db   $ff, $30, $00, $c0, $01, $09, $ff, $e0        ;; 00:1db3 ????????
    db   $02, $00, $01, $ff, $07, $ff, $c0, $01        ;; 00:1dbb ????????
    db   $80, $00, $ff, $03, $ff, $30, $00, $80        ;; 00:1dc3 ????????
    db   $02, $ff, $04, $ff, $a0, $09, $80, $00        ;; 00:1dcb ????????
    db   $0b, $05, $e0, $03, $40, $01, $ff, $0c        ;; 00:1dd3 ????????
    db   $ff, $a0, $01, $f0, $00, $ff, $0d, $ff        ;; 00:1ddb ????????
    db   $f0, $00, $00, $02, $ff, $0e, $ff, $50        ;; 00:1de3 ????????
    db   $00, $10, $03, $ff, $0a, $0d, $b0, $03        ;; 00:1deb ????????
    db   $40, $01, $0f, $0a, $70, $01, $a0, $00        ;; 00:1df3 ????????
    db   $10, $0b, $50, $02, $30, $00, $11, $0c        ;; 00:1dfb ????????
    db   $30, $03, $a0, $00, $ff, $00, $ff, $70        ;; 00:1e03 ????????
    db   $00, $b0, $00, $02, $ff, $70, $00, $00        ;; 00:1e0b ????????
    db   $01, $ff, $01, $ff, $c0, $0b, $a0, $02        ;; 00:1e13 ????????
    db   $04, $ff, $80, $00, $20, $03, $06, $ff        ;; 00:1e1b ????????
    db   $40, $04, $00, $01, $ff, $03, $ff, $60        ;; 00:1e23 ????????
    db   $00, $80, $00, $ff, $05, $ff, $e0, $00        ;; 00:1e2b ????????
    db   $a0, $01, $ff, $07, $ff, $a0, $02, $c0        ;; 00:1e33 ????????
    db   $01, $08, $ff, $a0, $02, $80, $00, $ff        ;; 00:1e3b ????????
    db   $09, $ff, $50, $00, $60, $00, $ff, $00        ;; 00:1e43 ????????
    db   $ff, $7c, $02, $b8, $02, $01, $ff, $fc        ;; 00:1e4b ????????
    db   $01, $b8, $01, $02, $ff, $8c, $01, $f8        ;; 00:1e53 ????????
    db   $00, $ff, $03, $ff, $20, $00, $30, $01        ;; 00:1e5b ????????
    db   $ff, $04, $ff, $20, $00, $30, $01, $ff        ;; 00:1e63 ????????
    db   $05, $ff, $20, $00, $30, $01, $ff, $00        ;; 00:1e6b ????????
    db   $00, $60, $02, $c0, $00, $ff, $05, $ff        ;; 00:1e73 ????????
    db   $30, $00, $f0, $00, $04, $ff, $00, $01        ;; 00:1e7b ????????
    db   $b0, $00, $06, $01, $c0, $01, $f0, $00        ;; 00:1e83 ????????
    db   $07, $02, $00, $01, $20, $00, $ff, $01        ;; 00:1e8b ????????
    db   $ff, $38, $01, $80, $01, $ff, $02, $ff        ;; 00:1e93 ????????
    db   $38, $01, $80, $01, $ff                       ;; 00:1e9b ?????

call_00_1ea0_UpdateMain:
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:1ea0 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1ea3 $6e
    ld   H, $00                                        ;; 00:1ea4 $26 $00
    add  HL, HL                                        ;; 00:1ea6 $29
    add  HL, HL                                        ;; 00:1ea7 $29
    ld   DE, $1fc0                                     ;; 00:1ea8 $11 $c0 $1f
    add  HL, DE                                        ;; 00:1eab $19
    ld   A, [wDC5A]                                    ;; 00:1eac $fa $5a $dc
    ld   E, A                                          ;; 00:1eaf $5f
    ld   D, $00                                        ;; 00:1eb0 $16 $00
    add  HL, DE                                        ;; 00:1eb2 $19
    ld   A, [HL]                                       ;; 00:1eb3 $7e
    cp   A, $ff                                        ;; 00:1eb4 $fe $ff
    ret  Z                                             ;; 00:1eb6 $c8
    ld   L, A                                          ;; 00:1eb7 $6f
    ld   H, $00                                        ;; 00:1eb8 $26 $00
    add  HL, HL                                        ;; 00:1eba $29
    ld   DE, $1ff0                                     ;; 00:1ebb $11 $f0 $1f
    add  HL, DE                                        ;; 00:1ebe $19
    ld   E, [HL]                                       ;; 00:1ebf $5e
    inc  HL                                            ;; 00:1ec0 $23
    ld   D, [HL]                                       ;; 00:1ec1 $56
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:1ec2 $fa $6c $db
    push AF                                            ;; 00:1ec5 $f5
    ld   A, [DE]                                       ;; 00:1ec6 $1a
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:1ec7 $ea $6c $db
    inc  DE                                            ;; 00:1eca $13
    ld   HL, wD80E                                     ;; 00:1ecb $21 $0e $d8
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
    ld   [wDCA7], A                                    ;; 00:1ee2 $ea $a7 $dc
    ld   A, $00                                        ;; 00:1ee5 $3e $00
    ld   [wDC78], A                                    ;; 00:1ee7 $ea $78 $dc
    call call_00_04fb                                  ;; 00:1eea $cd $fb $04
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1eed $ea $d6 $da
    ld   A, $03                                        ;; 00:1ef0 $3e $03
    ld   HL, call_03_6c89_CopyLevelData                              ;; 00:1ef2 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1ef5 $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1ef8 $ea $d6 $da
    ld   A, $03                                        ;; 00:1efb $3e $03
    ld   HL, $6203                                     ;; 00:1efd $21 $03 $62
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1f00 $cd $dd $0e
    call call_00_10de                                  ;; 00:1f03 $cd $de $10
    call call_00_1056_LoadMap                                  ;; 00:1f06 $cd $56 $10
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1f09 $ea $d6 $da
    ld   A, $02                                        ;; 00:1f0c $3e $02
    ld   HL, $708f                                     ;; 00:1f0e $21 $8f $70
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1f11 $cd $dd $0e
    call call_00_0513                                  ;; 00:1f14 $cd $13 $05
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
    ld   [wDCE0], A                                    ;; 00:1f24 $ea $e0 $dc
    ld   [wDCE1], A                                    ;; 00:1f27 $ea $e1 $dc
    ld   A, [HL+]                                      ;; 00:1f2a $2a
.jr_00_1f2b:
    ld   [wDC81], A                                    ;; 00:1f2b $ea $81 $dc
    ld   A, [HL+]                                      ;; 00:1f2e $2a
    ld   [wDCDE], A                                    ;; 00:1f2f $ea $de $dc
    ld   A, [HL+]                                      ;; 00:1f32 $2a
    ld   [wDCDF], A                                    ;; 00:1f33 $ea $df $dc
    push HL                                            ;; 00:1f36 $e5
.jr_00_1f37:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:1f37 $fa $d7 $da
    and  A, A                                          ;; 00:1f3a $a7
    jr   Z, .jr_00_1f42                                ;; 00:1f3b $28 $05
    pop  HL                                            ;; 00:1f3d $e1
    pop  HL                                            ;; 00:1f3e $e1
    jp   .jp_00_1f9f                                   ;; 00:1f3f $c3 $9f $1f
.jr_00_1f42:
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:1f42 $cd $92 $0b
    call call_00_217f                                  ;; 00:1f45 $cd $7f $21
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1f48 $ea $d6 $da
    ld   A, $02                                        ;; 00:1f4b $3e $02
    ld   HL, entry_02_7152_UpdateObjects                                     ;; 00:1f4d $21 $52 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1f50 $cd $dd $0e
    call call_00_11c8_LoadBgMap                                  ;; 00:1f53 $cd $c8 $11
    call call_00_35fa                                  ;; 00:1f56 $cd $fa $35
    call call_00_08f8                                  ;; 00:1f59 $cd $f8 $08
    ld   HL, wDCDE                                     ;; 00:1f5c $21 $de $dc
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
    call call_00_0b92_UpdateVRAMTiles                                  ;; 00:1f7b $cd $92 $0b
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1f7e $ea $d6 $da
    ld   A, $02                                        ;; 00:1f81 $3e $02
    ld   HL, entry_02_7152_UpdateObjects                                     ;; 00:1f83 $21 $52 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1f86 $cd $dd $0e
    call call_00_11c8_LoadBgMap                                  ;; 00:1f89 $cd $c8 $11
    call call_00_35fa                                  ;; 00:1f8c $cd $fa $35
    call call_00_08f8                                  ;; 00:1f8f $cd $f8 $08
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
    ld   [wDCA7], A                                    ;; 00:1fa1 $ea $a7 $dc
    ld   HL, wD811                                     ;; 00:1fa4 $21 $11 $d8
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
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:1fb1 $ea $6c $db
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1fb4 $ea $d6 $da
    ld   A, $03                                        ;; 00:1fb7 $3e $03
    ld   HL, call_03_6c89_CopyLevelData                              ;; 00:1fb9 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1fbc $cd $dd $0e
    ret                                                ;; 00:1fbf $c9
    db   $ff, $ff, $ff, $ff, $00, $01, $02, $ff        ;; 00:1fc0 ...?www?
    db   $03, $04, $05, $ff, $06, $07, $08, $ff        ;; 00:1fc8 ????????
    db   $09, $0a, $0b, $ff, $0c, $0d, $0e, $ff        ;; 00:1fd0 ????????
    db   $0f, $10, $11, $ff, $ff, $ff, $ff, $ff        ;; 00:1fd8 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1fe0 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1fe8 ????????
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

call_00_217f:
    ld   A, [wDC81]                                    ;; 00:217f $fa $81 $dc
    and  A, A                                          ;; 00:2182 $a7
    jr   NZ, .jr_00_218c                               ;; 00:2183 $20 $07
    ld   HL, wDCE0                                     ;; 00:2185 $21 $e0 $dc
    ld   [HL], $00                                     ;; 00:2188 $36 $00
    jr   .jr_00_2191                                   ;; 00:218a $18 $05
.jr_00_218c:
    ld   HL, wDCE0                                     ;; 00:218c $21 $e0 $dc
    ld   [HL], $10                                     ;; 00:218f $36 $10
.jr_00_2191:
    ld   HL, wDCE0                                     ;; 00:2191 $21 $e0 $dc
    ld   A, [HL+]                                      ;; 00:2194 $2a
    ld   C, A                                          ;; 00:2195 $4f
    ld   A, [HL]                                       ;; 00:2196 $7e
    and  A, $0f                                        ;; 00:2197 $e6 $0f
    add  A, C                                          ;; 00:2199 $81
    ld   [HL], A                                       ;; 00:219a $77
    swap A                                             ;; 00:219b $cb $37
    and  A, $0f                                        ;; 00:219d $e6 $0f
    ld   C, A                                          ;; 00:219f $4f
    ld   HL, wDC81                                     ;; 00:21a0 $21 $81 $dc
    bit  4, [HL]                                       ;; 00:21a3 $cb $66
    jr   Z, .jr_00_21b6                                ;; 00:21a5 $28 $0f
    ld   A, [wD80E]                                    ;; 00:21a7 $fa $0e $d8
    add  A, C                                          ;; 00:21aa $81
    ld   [wD80E], A                                    ;; 00:21ab $ea $0e $d8
    ld   A, [wD80F]                                    ;; 00:21ae $fa $0f $d8
    adc  A, $00                                        ;; 00:21b1 $ce $00
    ld   [wD80F], A                                    ;; 00:21b3 $ea $0f $d8
.jr_00_21b6:
    bit  5, [HL]                                       ;; 00:21b6 $cb $6e
    jr   Z, .jr_00_21c9                                ;; 00:21b8 $28 $0f
    ld   A, [wD80E]                                    ;; 00:21ba $fa $0e $d8
    sub  A, C                                          ;; 00:21bd $91
    ld   [wD80E], A                                    ;; 00:21be $ea $0e $d8
    ld   A, [wD80F]                                    ;; 00:21c1 $fa $0f $d8
    sbc  A, $00                                        ;; 00:21c4 $de $00
    ld   [wD80F], A                                    ;; 00:21c6 $ea $0f $d8
.jr_00_21c9:
    bit  7, [HL]                                       ;; 00:21c9 $cb $7e
    jr   Z, .jr_00_21dc                                ;; 00:21cb $28 $0f
    ld   A, [wD810]                                    ;; 00:21cd $fa $10 $d8
    add  A, C                                          ;; 00:21d0 $81
    ld   [wD810], A                                    ;; 00:21d1 $ea $10 $d8
    ld   A, [wD811]                                    ;; 00:21d4 $fa $11 $d8
    adc  A, $00                                        ;; 00:21d7 $ce $00
    ld   [wD811], A                                    ;; 00:21d9 $ea $11 $d8
.jr_00_21dc:
    bit  6, [HL]                                       ;; 00:21dc $cb $76
    ret  Z                                             ;; 00:21de $c8
    ld   A, [wD810]                                    ;; 00:21df $fa $10 $d8
    sub  A, C                                          ;; 00:21e2 $91
    ld   [wD810], A                                    ;; 00:21e3 $ea $10 $d8
    ld   A, [wD811]                                    ;; 00:21e6 $fa $11 $d8
    sbc  A, $00                                        ;; 00:21e9 $de $00
    ld   [wD811], A                                    ;; 00:21eb $ea $11 $d8
    ret                                                ;; 00:21ee $c9

call_00_21ef:
    push BC                                            ;; 00:21ef $c5
    ld   A, $1e                                        ;; 00:21f0 $3e $1e
    call call_00_0ff5                                  ;; 00:21f2 $cd $f5 $0f
    pop  BC                                            ;; 00:21f5 $c1

call_00_21f6:
    push BC                                            ;; 00:21f6 $c5
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:21f7 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:21fa $cd $ee $0e
    pop  BC                                            ;; 00:21fd $c1
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:21fe $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:2201 $2a
    ld   H, [HL]                                       ;; 00:2202 $66
    ld   L, A                                          ;; 00:2203 $6f
    ld   A, [HL]                                       ;; 00:2204 $7e
    cp   A, $ff                                        ;; 00:2205 $fe $ff
    jp   Z, call_00_0f08_SwitchBank2                               ;; 00:2207 $ca $08 $0f
    ld   B, $01                                        ;; 00:220a $06 $01
.jr_00_220c:
    push HL                                            ;; 00:220c $e5
    ld   A, [HL]                                       ;; 00:220d $7e
    cp   A, $11                                        ;; 00:220e $fe $11
    jr   NZ, .jr_00_221a                               ;; 00:2210 $20 $08
    ld   DE, $0d                                       ;; 00:2212 $11 $0d $00
    add  HL, DE                                        ;; 00:2215 $19
    ld   A, [HL]                                       ;; 00:2216 $7e
    cp   A, C                                          ;; 00:2217 $b9
    jr   Z, .jr_00_2228                                ;; 00:2218 $28 $0e
.jr_00_221a:
    inc  B                                             ;; 00:221a $04
    pop  HL                                            ;; 00:221b $e1
    ld   DE, $10                                       ;; 00:221c $11 $10 $00
    add  HL, DE                                        ;; 00:221f $19
    ld   A, [HL]                                       ;; 00:2220 $7e
    cp   A, $ff                                        ;; 00:2221 $fe $ff
    jr   NZ, .jr_00_220c                               ;; 00:2223 $20 $e7
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2225 $c3 $08 $0f
.jr_00_2228:
    pop  HL                                            ;; 00:2228 $e1
    ld   E, B                                          ;; 00:2229 $58
    ld   D, $d7                                        ;; 00:222a $16 $d7
    ld   A, [DE]                                       ;; 00:222c $1a
    and  A, $f0                                        ;; 00:222d $e6 $f0
    or   A, $01                                        ;; 00:222f $f6 $01
    ld   [DE], A                                       ;; 00:2231 $12
    inc  E                                             ;; 00:2232 $1c
    ld   L, C                                          ;; 00:2233 $69
    ld   H, $00                                        ;; 00:2234 $26 $00
    ld   BC, $225c                                     ;; 00:2236 $01 $5c $22
    add  HL, BC                                        ;; 00:2239 $09
    ld   A, [HL]                                       ;; 00:223a $7e
    push AF                                            ;; 00:223b $f5
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:223c $21 $1e $dc
    ld   L, [HL]                                       ;; 00:223f $6e
    ld   H, $00                                        ;; 00:2240 $26 $00
    ld   BC, wDC5C                                     ;; 00:2242 $01 $5c $dc
    add  HL, BC                                        ;; 00:2245 $09
    pop  AF                                            ;; 00:2246 $f1
    ld   C, $01                                        ;; 00:2247 $0e $01
    and  A, [HL]                                       ;; 00:2249 $a6
    jr   Z, .jr_00_2254                                ;; 00:224a $28 $08
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:224c $fa $1e $dc
    and  A, A                                          ;; 00:224f $a7
    jr   Z, .jr_00_2254                                ;; 00:2250 $28 $02
    ld   C, $02                                        ;; 00:2252 $0e $02
.jr_00_2254:
    ld   A, [DE]                                       ;; 00:2254 $1a
    and  A, $f0                                        ;; 00:2255 $e6 $f0
    or   A, C                                          ;; 00:2257 $b1
    ld   [DE], A                                       ;; 00:2258 $12
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2259 $c3 $08 $0f
    db   $00, $01, $02, $04                            ;; 00:225c ?...

jp_00_2260:
    push BC                                            ;; 00:2260 $c5
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:2261 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2264 $cd $ee $0e
    pop  BC                                            ;; 00:2267 $c1
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:2268 $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:226b $2a
    ld   H, [HL]                                       ;; 00:226c $66
    ld   L, A                                          ;; 00:226d $6f
    ld   B, $01                                        ;; 00:226e $06 $01
.jr_00_2270:
    push HL                                            ;; 00:2270 $e5
    ld   A, [HL]                                       ;; 00:2271 $7e
    cp   A, $12                                        ;; 00:2272 $fe $12
    jr   NZ, .jr_00_227e                               ;; 00:2274 $20 $08
    ld   DE, $0d                                       ;; 00:2276 $11 $0d $00
    add  HL, DE                                        ;; 00:2279 $19
    ld   A, [HL]                                       ;; 00:227a $7e
    cp   A, C                                          ;; 00:227b $b9
    jr   Z, .jr_00_228c                                ;; 00:227c $28 $0e
.jr_00_227e:
    inc  B                                             ;; 00:227e $04
    pop  HL                                            ;; 00:227f $e1
    ld   DE, $10                                       ;; 00:2280 $11 $10 $00
    add  HL, DE                                        ;; 00:2283 $19
    ld   A, [HL]                                       ;; 00:2284 $7e
    cp   A, $ff                                        ;; 00:2285 $fe $ff
    jr   NZ, .jr_00_2270                               ;; 00:2287 $20 $e7
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2289 $c3 $08 $0f
.jr_00_228c:
    pop  HL                                            ;; 00:228c $e1
    ld   E, B                                          ;; 00:228d $58
    ld   D, $d7                                        ;; 00:228e $16 $d7
    ld   A, [DE]                                       ;; 00:2290 $1a
    and  A, $f0                                        ;; 00:2291 $e6 $f0
    or   A, $04                                        ;; 00:2293 $f6 $04
    ld   [DE], A                                       ;; 00:2295 $12
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2296 $c3 $08 $0f

call_00_2299:
    ld   A, [wDA00]                                    ;; 00:2299 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:22b1 $fa $00 $da
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
    ld   HL, call_02_72ac                              ;; 00:22cd $21 $ac $72
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
    ld   A, [wDA00]                                    ;; 00:231b $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:244c $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:24c2 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:24e1 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:24f0 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:250f $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:251f $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2540 $fa $00 $da
    or   A, $0d                                        ;; 00:2543 $f6 $0d
    ld   L, A                                          ;; 00:2545 $6f
    ld   A, [HL]                                       ;; 00:2546 $7e
    ld   [HL], C                                       ;; 00:2547 $71
    cp   A, C                                          ;; 00:2548 $b9
    ret                                                ;; 00:2549 $c9

call_00_254a:
    ld   H, $d8                                        ;; 00:254a $26 $d8
    ld   A, [wDA00]                                    ;; 00:254c $fa $00 $da
    or   A, $0d                                        ;; 00:254f $f6 $0d
    ld   L, A                                          ;; 00:2551 $6f
    ld   C, [HL]                                       ;; 00:2552 $4e
    ld   H, $d8                                        ;; 00:2553 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2555 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:258a $fa $00 $da
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
    ld   HL, wD810                                     ;; 00:2722 $21 $10 $d8
    ld   A, [wDA00]                                    ;; 00:2725 $fa $00 $da
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
    ld   A, [wD80E]                                    ;; 00:2749 $fa $0e $d8
    sub  A, E                                          ;; 00:274c $93
    ld   A, [wD80F]                                    ;; 00:274d $fa $0f $d8
    sbc  A, D                                          ;; 00:2750 $9a
    jr   C, .jr_00_2764                                ;; 00:2751 $38 $11
    call call_00_2846                                  ;; 00:2753 $cd $46 $28
    ld   A, [wD80E]                                    ;; 00:2756 $fa $0e $d8
    sub  A, E                                          ;; 00:2759 $93
    ld   A, [wD80F]                                    ;; 00:275a $fa $0f $d8
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
    ld   A, [wDA00]                                    ;; 00:276b $fa $00 $da
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
    db   $21, $fb, $db, $2a, $66, $6f, $11, $b0        ;; 00:2780 ????????
    db   $00, $19, $5d, $54, $26, $d8, $fa, $00        ;; 00:2788 ????????
    db   $da, $f6, $10, $6f, $2a, $93, $7e, $9a        ;; 00:2790 ????????
    db   $c9, $cd, $35, $28, $26, $d8, $fa, $00        ;; 00:2798 ????????
    db   $da, $f6, $0e, $6f, $2a, $93, $5f, $7e        ;; 00:27a0 ????????
    db   $9a, $57, $30, $07, $af, $93, $5f, $3e        ;; 00:27a8 ????????
    db   $00, $9a, $57, $cb, $3a, $cb, $1b, $d5        ;; 00:27b0 ????????
    db   $cd, $f3, $27, $e1, $19, $16, $d8, $fa        ;; 00:27b8 ????????
    db   $00, $da, $f6, $10, $5f, $7d, $12, $1c        ;; 00:27c0 ????????
    db   $7c, $12, $c9, $26, $d8, $fa, $00, $da        ;; 00:27c8 ????????
    db   $f6, $10, $6f, $fa, $fb, $db, $d6, $14        ;; 00:27d0 ????????
    db   $22, $fa, $fc, $db, $de, $00, $77, $d0        ;; 00:27d8 ????????
    db   $af, $32, $77, $c9, $cd, $f3, $27, $26        ;; 00:27e0 ????????
    db   $d8, $fa, $00, $da, $f6, $10, $6f, $7b        ;; 00:27e8 ????????
    db   $22, $72, $c9                                 ;; 00:27f0 ???

call_00_27f3:
    ld   A, [wDA00]                                    ;; 00:27f3 $fa $00 $da
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
    db   $fa, $00, $da, $0f, $e6, $70, $6f, $26        ;; 00:2804 ????????
    db   $00, $11, $20, $da, $19, $2a, $5f, $56        ;; 00:280c ????????
    db   $c9, $fa, $00, $da, $0f, $e6, $70, $6f        ;; 00:2814 ????????
    db   $26, $00, $11, $22, $da, $19, $2a, $5f        ;; 00:281c ????????
    db   $56, $c9, $cd, $35, $28, $26, $d8, $fa        ;; 00:2824 ????????
    db   $00, $da, $f6, $0e, $6f, $7b, $22, $72        ;; 00:282c ????????
    db   $c9, $fa, $00, $da, $0f, $e6, $70, $6f        ;; 00:2834 ????????
    db   $26, $00, $11, $24, $da, $19, $2a, $5f        ;; 00:283c ????????
    db   $56, $c9                                      ;; 00:2844 ??

call_00_2846:
    ld   A, [wDA00]                                    ;; 00:2846 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2857 $fa $00 $da
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
    db   $fa, $00, $da, $0f, $e6, $70, $6f, $26        ;; 00:2868 ????????
    db   $00, $01, $1c, $da, $09, $7b, $22, $72        ;; 00:2870 ????????
    db   $c9, $fa, $00, $da, $0f, $e6, $70, $6f        ;; 00:2878 ????????
    db   $26, $00, $01, $1e, $da, $09, $7b, $22        ;; 00:2880 ????????
    db   $72, $c9                                      ;; 00:2888 ??

call_00_288a:
    ld   C, $00                                        ;; 00:288a $0e $00

call_00_288c:
    ld   H, $d8                                        ;; 00:288c $26 $d8
    ld   A, [wDA00]                                    ;; 00:288e $fa $00 $da
    or   A, $14                                        ;; 00:2891 $f6 $14
    ld   L, A                                          ;; 00:2893 $6f
    ld   [HL], C                                       ;; 00:2894 $71
    ret                                                ;; 00:2895 $c9
    db   $26, $d8, $fa, $00, $da, $f6, $15, $6f        ;; 00:2896 ????????
    db   $71, $c9, $26, $d8, $fa, $00, $da, $f6        ;; 00:289e ????????
    db   $15, $6f, $7e, $c9                            ;; 00:28a6 ????

call_00_28aa:
    ld   H, $d8                                        ;; 00:28aa $26 $d8
    ld   A, [wDA00]                                    ;; 00:28ac $fa $00 $da
    or   A, $16                                        ;; 00:28af $f6 $16
    ld   L, A                                          ;; 00:28b1 $6f
    ld   [HL], C                                       ;; 00:28b2 $71
    ret                                                ;; 00:28b3 $c9
    db   $26, $d8, $fa, $00, $da, $f6, $16, $6f        ;; 00:28b4 ????????
    db   $7e, $c9                                      ;; 00:28bc ??

call_00_28be:
    ld   H, $d8                                        ;; 00:28be $26 $d8
    ld   A, [wDA00]                                    ;; 00:28c0 $fa $00 $da
    or   A, $1b                                        ;; 00:28c3 $f6 $1b
    ld   L, A                                          ;; 00:28c5 $6f
    ld   A, [HL]                                       ;; 00:28c6 $7e
    ret                                                ;; 00:28c7 $c9

call_00_28c8:
    ld   H, $d8                                        ;; 00:28c8 $26 $d8
    ld   A, [wDA00]                                    ;; 00:28ca $fa $00 $da
    or   A, $1b                                        ;; 00:28cd $f6 $1b
    ld   L, A                                          ;; 00:28cf $6f
    ld   [HL], C                                       ;; 00:28d0 $71
    ret                                                ;; 00:28d1 $c9

call_00_28d2:
    ld   H, $d8                                        ;; 00:28d2 $26 $d8
    ld   A, [wDA00]                                    ;; 00:28d4 $fa $00 $da
    or   A, $1d                                        ;; 00:28d7 $f6 $1d
    ld   L, A                                          ;; 00:28d9 $6f
    ld   A, [HL]                                       ;; 00:28da $7e
    ret                                                ;; 00:28db $c9

call_00_28dc:
    ld   H, $d8                                        ;; 00:28dc $26 $d8
    ld   A, [wDA00]                                    ;; 00:28de $fa $00 $da
    or   A, $1d                                        ;; 00:28e1 $f6 $1d
    ld   L, A                                          ;; 00:28e3 $6f
    ld   [HL], C                                       ;; 00:28e4 $71
    ret                                                ;; 00:28e5 $c9
    db   $26, $d8, $fa, $00, $da, $f6, $1b, $6f        ;; 00:28e6 ????????
    db   $7e, $a7, $c9, $26, $d8, $fa, $00, $da        ;; 00:28ee ????????
    db   $f6, $1d, $6f, $7e, $a7, $c9, $26, $d8        ;; 00:28f6 ????????
    db   $fa, $00, $da, $f6, $19, $6f, $7e, $34        ;; 00:28fe ????????
    db   $e6, $03, $6f, $26, $00, $19, $4e             ;; 00:2906 ???????

call_00_290d:
    ld   H, $d8                                        ;; 00:290d $26 $d8
    ld   A, [wDA00]                                    ;; 00:290f $fa $00 $da
    or   A, $1a                                        ;; 00:2912 $f6 $1a
    ld   L, A                                          ;; 00:2914 $6f
    ld   [HL], C                                       ;; 00:2915 $71
    ret                                                ;; 00:2916 $c9
    db   $26, $d8, $fa, $00, $da, $f6, $1a, $6f        ;; 00:2917 ????????
    db   $7e, $a7, $c9                                 ;; 00:291f ???

call_00_2922:
    ld   H, $d8                                        ;; 00:2922 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2924 $fa $00 $da
    or   A, $1a                                        ;; 00:2927 $f6 $1a
    ld   L, A                                          ;; 00:2929 $6f
    ld   A, [HL]                                       ;; 00:292a $7e
    and  A, A                                          ;; 00:292b $a7
    ret  Z                                             ;; 00:292c $c8
    dec  [HL]                                          ;; 00:292d $35
    ld   A, [HL]                                       ;; 00:292e $7e
    ret                                                ;; 00:292f $c9

call_00_2930:
    ld   H, $d8                                        ;; 00:2930 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2932 $fa $00 $da
    or   A, $00                                        ;; 00:2935 $f6 $00
    ld   L, A                                          ;; 00:2937 $6f
    ld   [HL], C                                       ;; 00:2938 $71
    ret                                                ;; 00:2939 $c9
    db   $26, $d8, $fa, $00, $da, $f6, $00, $6f        ;; 00:293a ????????
    db   $7e, $c9                                      ;; 00:2942 ??

call_00_2944:
    ld   H, $d8                                        ;; 00:2944 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2946 $fa $00 $da
    or   A, $12                                        ;; 00:2949 $f6 $12
    ld   L, A                                          ;; 00:294b $6f
    ld   [HL], C                                       ;; 00:294c $71
    ret                                                ;; 00:294d $c9

call_00_294e:
    ld   H, $d8                                        ;; 00:294e $26 $d8
    ld   A, [wDA00]                                    ;; 00:2950 $fa $00 $da
    or   A, $13                                        ;; 00:2953 $f6 $13
    ld   L, A                                          ;; 00:2955 $6f
    ld   [HL], C                                       ;; 00:2956 $71
    ret                                                ;; 00:2957 $c9

call_00_2958:
    ld   H, $d8                                        ;; 00:2958 $26 $d8
    ld   A, [wDA00]                                    ;; 00:295a $fa $00 $da
    or   A, $0d                                        ;; 00:295d $f6 $0d
    ld   L, A                                          ;; 00:295f $6f
    ld   [HL], C                                       ;; 00:2960 $71
    ret                                                ;; 00:2961 $c9

call_00_2962:
    ld   H, $d8                                        ;; 00:2962 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2964 $fa $00 $da
    or   A, $01                                        ;; 00:2967 $f6 $01
    ld   L, A                                          ;; 00:2969 $6f
    ld   A, [HL]                                       ;; 00:296a $7e
    ret                                                ;; 00:296b $c9
    db   $26, $d8, $fa, $00, $da, $f6, $09, $6f        ;; 00:296c ????????
    db   $7e, $c9                                      ;; 00:2974 ??

call_00_2976:
    ld   H, $d8                                        ;; 00:2976 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2978 $fa $00 $da
    or   A, $0d                                        ;; 00:297b $f6 $0d
    ld   L, A                                          ;; 00:297d $6f
    ld   A, [HL]                                       ;; 00:297e $7e
    ret                                                ;; 00:297f $c9

call_00_2980:
    ld   H, $d8                                        ;; 00:2980 $26 $d8
    ld   A, [wDA00]                                    ;; 00:2982 $fa $00 $da
    or   A, $19                                        ;; 00:2985 $f6 $19
    ld   L, A                                          ;; 00:2987 $6f
    ld   [HL], C                                       ;; 00:2988 $71
    ret                                                ;; 00:2989 $c9

call_00_298a:
    ld   H, $d8                                        ;; 00:298a $26 $d8
    ld   A, [wDA00]                                    ;; 00:298c $fa $00 $da
    or   A, $19                                        ;; 00:298f $f6 $19
    ld   L, A                                          ;; 00:2991 $6f
    ld   A, [HL]                                       ;; 00:2992 $7e
    and  A, A                                          ;; 00:2993 $a7
    ret                                                ;; 00:2994 $c9
    db   $26, $d8, $fa, $00, $da, $f6, $01, $6f        ;; 00:2995 ????????
    db   $7e, $c9                                      ;; 00:299d ??

call_00_299f:
    ld   H, $d8                                        ;; 00:299f $26 $d8
    ld   A, [wDA00]                                    ;; 00:29a1 $fa $00 $da
    or   A, $0d                                        ;; 00:29a4 $f6 $0d
    ld   L, A                                          ;; 00:29a6 $6f
    ld   A, [HL]                                       ;; 00:29a7 $7e
    xor  A, $20                                        ;; 00:29a8 $ee $20
    ld   [HL], A                                       ;; 00:29aa $77
    ret                                                ;; 00:29ab $c9
    db   $cd, $68, $2a, $cd, $76, $29, $21, $12        ;; 00:29ac ????????
    db   $da, $be, $c9, $26, $d8, $2e, $40, $7e        ;; 00:29b4 ????????
    db   $b9, $28, $09, $7d, $c6, $20, $6f, $20        ;; 00:29bc ????????
    db   $f6, $0e, $ff, $c9, $7d, $f6, $01, $6f        ;; 00:29c4 ????????
    db   $4e, $c9                                      ;; 00:29cc ??

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
    ld   A, [wDA00]                                    ;; 00:29f7 $fa $00 $da
    or   A, $05                                        ;; 00:29fa $f6 $05
    ld   L, A                                          ;; 00:29fc $6f
    ld   A, [HL]                                       ;; 00:29fd $7e
    res  4, [HL]                                       ;; 00:29fe $cb $a6
    bit  4, A                                          ;; 00:2a00 $cb $67
    ret                                                ;; 00:2a02 $c9

call_00_2a03:
    ld   A, [wDA00]                                    ;; 00:2a03 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2a15 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2a39 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2a5f $fa $00 $da
    or   A, $05                                        ;; 00:2a62 $f6 $05
    ld   L, A                                          ;; 00:2a64 $6f
    bit  2, [HL]                                       ;; 00:2a65 $cb $56
    ret                                                ;; 00:2a67 $c9

call_00_2a68:
    ld   C, $00                                        ;; 00:2a68 $0e $00
    ld   H, $d8                                        ;; 00:2a6a $26 $d8
    ld   A, [wDA00]                                    ;; 00:2a6c $fa $00 $da
    or   A, $0e                                        ;; 00:2a6f $f6 $0e
    ld   L, A                                          ;; 00:2a71 $6f
    ld   A, [wD80E]                                    ;; 00:2a72 $fa $0e $d8
    sub  A, [HL]                                       ;; 00:2a75 $96
    ld   E, A                                          ;; 00:2a76 $5f
    inc  HL                                            ;; 00:2a77 $23
    ld   A, [wD80F]                                    ;; 00:2a78 $fa $0f $d8
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
    ld   A, [wDA00]                                    ;; 00:2b10 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2b3d $fa $00 $da
    push AF                                            ;; 00:2b40 $f5
    ld   A, $20                                        ;; 00:2b41 $3e $20
.jr_00_2b43:
    ld   [wDA00], A                                    ;; 00:2b43 $ea $00 $da
    or   A, $00                                        ;; 00:2b46 $f6 $00
    ld   L, A                                          ;; 00:2b48 $6f
    ld   H, $d8                                        ;; 00:2b49 $26 $d8
    ld   A, [HL]                                       ;; 00:2b4b $7e
    cp   A, $ff                                        ;; 00:2b4c $fe $ff
    call NZ, call_00_2b5d                              ;; 00:2b4e $c4 $5d $2b
    ld   A, [wDA00]                                    ;; 00:2b51 $fa $00 $da
    add  A, $20                                        ;; 00:2b54 $c6 $20
    jr   NZ, .jr_00_2b43                               ;; 00:2b56 $20 $eb
    pop  AF                                            ;; 00:2b58 $f1
    ld   [wDA00], A                                    ;; 00:2b59 $ea $00 $da
    ret                                                ;; 00:2b5c $c9

call_00_2b5d:
    ld   A, [wDA00]                                    ;; 00:2b5d $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2b82 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2b94 $fa $00 $da
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
    ld   A, [wDA00]                                    ;; 00:2ba9 $fa $00 $da
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
    call call_00_2930                                  ;; 00:2bcb $cd $30 $29
    ld   C, $08                                        ;; 00:2bce $0e $08
    call call_00_288c                                  ;; 00:2bd0 $cd $8c $28
    ld   C, $12                                        ;; 00:2bd3 $0e $12
    call call_00_2944                                  ;; 00:2bd5 $cd $44 $29
    ld   C, $12                                        ;; 00:2bd8 $0e $12
    call call_00_294e                                  ;; 00:2bda $cd $4e $29
    ld   C, $00                                        ;; 00:2bdd $0e $00
    call call_00_2958                                  ;; 00:2bdf $cd $58 $29
    ld   C, $01                                        ;; 00:2be2 $0e $01
    call call_00_28aa                                  ;; 00:2be4 $cd $aa $28
    ld   C, $00                                        ;; 00:2be7 $0e $00
    call call_00_2299                                  ;; 00:2be9 $cd $99 $22
    call call_00_2ba9                                  ;; 00:2bec $cd $a9 $2b
    xor  A, A                                          ;; 00:2bef $af
    ld   [wDAD6_ReturnBank], A                                    ;; 00:2bf0 $ea $d6 $da
    ld   A, $02                                        ;; 00:2bf3 $3e $02
    ld   HL, call_02_72ac                              ;; 00:2bf5 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:2bf8 $cd $dd $0e
    ld   HL, $2c01                                     ;; 00:2bfb $21 $01 $2c
    jp   call_00_2c20                                  ;; 00:2bfe $c3 $20 $2c
    db   $00, $00, $00, $00, $60, $02, $9c, $03        ;; 00:2c01 ........

call_00_2c09:
    add  A, $06                                        ;; 00:2c09 $c6 $06
    ld   C, A                                          ;; 00:2c0b $4f
    jp   call_00_3792                                  ;; 00:2c0c $c3 $92 $37
    db   $fa, $00, $da, $07, $07, $07, $e6, $07        ;; 00:2c0f ????????
    db   $6f, $26, $00, $11, $ae, $da, $19, $71        ;; 00:2c17 ????????
    db   $c9                                           ;; 00:2c1f ?

call_00_2c20:
    push HL                                            ;; 00:2c20 $e5
    ld   A, [wDA00]                                    ;; 00:2c21 $fa $00 $da
    rlca                                               ;; 00:2c24 $07
    rlca                                               ;; 00:2c25 $07
    rlca                                               ;; 00:2c26 $07
    and  A, $07                                        ;; 00:2c27 $e6 $07
    ld   L, A                                          ;; 00:2c29 $6f
    ld   H, $00                                        ;; 00:2c2a $26 $00
    ld   DE, wDAAE                                     ;; 00:2c2c $11 $ae $da
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
    db   $c4, $dd, $d7, $dd, $ea, $dd, $fd, $dd        ;; 00:2c43 ????????
    db   $10, $de, $23, $de                            ;; 00:2c4b ????
    dw   $de36                                         ;; 00:2c4f pP
    dw   $de49                                         ;; 00:2c51 pP

call_00_2c53:
    ld   A, [wDA00]                                    ;; 00:2c53 $fa $00 $da
    rlca                                               ;; 00:2c56 $07
    rlca                                               ;; 00:2c57 $07
    rlca                                               ;; 00:2c58 $07
    and  A, $07                                        ;; 00:2c59 $e6 $07
    ld   L, A                                          ;; 00:2c5b $6f
    ld   H, $00                                        ;; 00:2c5c $26 $00
    add  HL, HL                                        ;; 00:2c5e $29
    ld   DE, $2c43                                     ;; 00:2c5f $11 $43 $2c
    add  HL, DE                                        ;; 00:2c62 $19
    ld   E, [HL]                                       ;; 00:2c63 $5e
    inc  HL                                            ;; 00:2c64 $23
    ld   D, [HL]                                       ;; 00:2c65 $56
    ret                                                ;; 00:2c66 $c9

call_00_2c67:
    call call_00_2c53                                  ;; 00:2c67 $cd $53 $2c
    ld   A, $40                                        ;; 00:2c6a $3e $40
    ld   [DE], A                                       ;; 00:2c6c $12
    inc  DE                                            ;; 00:2c6d $13
    ld   HL, $2c77                                     ;; 00:2c6e $21 $77 $2c
    ld   BC, $12                                       ;; 00:2c71 $01 $12 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:2c74 $c3 $6e $07
    db   $0b, $00, $00, $f5, $00, $00, $10, $00        ;; 00:2c77 ........
    db   $00, $00, $00, $00, $0b, $00, $00, $0b        ;; 00:2c7f ........
    db   $00, $00                                      ;; 00:2c87 ..

call_00_2c89:
    call call_00_2c53                                  ;; 00:2c89 $cd $53 $2c
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

call_00_2cbf_LoadObjectPalettes:
    ld   A, $7f                                        ;; 00:2cbf $3e $7f
    call call_00_0eee_SwitchBank                                  ;; 00:2cc1 $cd $ee $0e
    ld   HL, wDB6C_CurrentLevelId                                     ;; 00:2cc4 $21 $6c $db
    ld   E, [HL]                                       ;; 00:2cc7 $5e
    ld   D, $00                                        ;; 00:2cc8 $16 $00
    ld   HL, $4000                                     ;; 00:2cca $21 $00 $40
    add  HL, DE                                        ;; 00:2ccd $19
    ld   E, [HL]                                       ;; 00:2cce $5e
    ld   HL, $4040                                     ;; 00:2ccf $21 $40 $40
    add  HL, DE                                        ;; 00:2cd2 $19
    ld   A, [HL+]                                      ;; 00:2cd3 $2a
    ld   H, [HL]                                       ;; 00:2cd4 $66
    ld   L, A                                          ;; 00:2cd5 $6f
    ld   DE, wDD2A_ObjectPalettes                                     ;; 00:2cd6 $11 $2a $dd
    ld   BC, $10                                       ;; 00:2cd9 $01 $10 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:2cdc $cd $6e $07
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2cdf $c3 $08 $0f

call_00_2ce2:
    ld   A, $01                                        ;; 00:2ce2 $3e $01
    ld   [wDAC2], A                                    ;; 00:2ce4 $ea $c2 $da
    ld   A, [wD80D]                                    ;; 00:2ce7 $fa $0d $d8
    ld   HL, wDC7A                                     ;; 00:2cea $21 $7a $dc
    or   A, [HL]                                       ;; 00:2ced $b6
    ld   [wDC53], A                                    ;; 00:2cee $ea $53 $dc
    ld   A, $7f                                        ;; 00:2cf1 $3e $7f
    call call_00_0eee_SwitchBank                                  ;; 00:2cf3 $cd $ee $0e
    ld   HL, wDB6C_CurrentLevelId                                     ;; 00:2cf6 $21 $6c $db
    ld   E, [HL]                                       ;; 00:2cf9 $5e
    ld   D, $00                                        ;; 00:2cfa $16 $00
    ld   HL, $4000                                     ;; 00:2cfc $21 $00 $40
    add  HL, DE                                        ;; 00:2cff $19
    ld   E, [HL]                                       ;; 00:2d00 $5e
    ld   HL, $403d                                     ;; 00:2d01 $21 $3d $40
    add  HL, DE                                        ;; 00:2d04 $19
    ld   A, [HL+]                                      ;; 00:2d05 $2a
    ld   [wDABF_CurrentGexSpriteBank], A                                    ;; 00:2d06 $ea $bf $da
    ld   A, [HL+]                                      ;; 00:2d09 $2a
    ld   H, [HL]                                       ;; 00:2d0a $66
    ld   L, A                                          ;; 00:2d0b $6f
    ld   A, [wD80A]                                    ;; 00:2d0c $fa $0a $d8
    ld   E, A                                          ;; 00:2d0f $5f
    ld   D, $00                                        ;; 00:2d10 $16 $00
    add  HL, DE                                        ;; 00:2d12 $19
    add  HL, DE                                        ;; 00:2d13 $19
    add  HL, DE                                        ;; 00:2d14 $19
    ld   C, [HL]                                       ;; 00:2d15 $4e
    inc  HL                                            ;; 00:2d16 $23
    ld   A, [HL+]                                      ;; 00:2d17 $2a
    ld   H, [HL]                                       ;; 00:2d18 $66
    ld   L, A                                          ;; 00:2d19 $6f
    push HL                                            ;; 00:2d1a $e5
    ld   A, [wDABF_CurrentGexSpriteBank]                                    ;; 00:2d1b $fa $bf $da
    add  A, C                                          ;; 00:2d1e $81
    ld   [wDABF_CurrentGexSpriteBank], A                                    ;; 00:2d1f $ea $bf $da
    call call_00_0f08_SwitchBank2                                  ;; 00:2d22 $cd $08 $0f
    ld   A, [wDABF_CurrentGexSpriteBank]                                    ;; 00:2d25 $fa $bf $da
    call call_00_0eee_SwitchBank                                  ;; 00:2d28 $cd $ee $0e
    pop  HL                                            ;; 00:2d2b $e1
    ld   A, [HL+]                                      ;; 00:2d2c $2a
    ld   [wDAC2], A                                    ;; 00:2d2d $ea $c2 $da
    inc  HL                                            ;; 00:2d30 $23
    inc  HL                                            ;; 00:2d31 $23
    ld   A, [HL+]                                      ;; 00:2d32 $2a
    ld   [wDAC0], A                                    ;; 00:2d33 $ea $c0 $da
    ld   A, [HL+]                                      ;; 00:2d36 $2a
    ld   [wDAC1], A                                    ;; 00:2d37 $ea $c1 $da
    xor  A, A                                          ;; 00:2d3a $af
    ld   [wDC52], A                                    ;; 00:2d3b $ea $52 $dc
    ld   A, [wDC6F]                                    ;; 00:2d3e $fa $6f $dc
    ld   E, A                                          ;; 00:2d41 $5f
    ld   D, $d9                                        ;; 00:2d42 $16 $d9
    ld   A, [wDC53]                                    ;; 00:2d44 $fa $53 $dc
    bit  6, A                                          ;; 00:2d47 $cb $77
    jp   NZ, .jp_00_2e0b                               ;; 00:2d49 $c2 $0b $2e
    bit  5, A                                          ;; 00:2d4c $cb $6f
    jp   NZ, .jp_00_2dac                               ;; 00:2d4e $c2 $ac $2d
    ld   A, [wDBF9_XPositionInMap]                                    ;; 00:2d51 $fa $f9 $db
    ld   C, A                                          ;; 00:2d54 $4f
    ld   A, [wD80E]                                    ;; 00:2d55 $fa $0e $d8
    sub  A, C                                          ;; 00:2d58 $91
    add  A, $08                                        ;; 00:2d59 $c6 $08
    ld   [wDC90], A                                    ;; 00:2d5b $ea $90 $dc
    ld   C, A                                          ;; 00:2d5e $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2d5f $fa $fb $db
    ld   B, A                                          ;; 00:2d62 $47
    ld   A, [wD810]                                    ;; 00:2d63 $fa $10 $d8
    sub  A, B                                          ;; 00:2d66 $90
    add  A, $10                                        ;; 00:2d67 $c6 $10
    ld   [wDC91], A                                    ;; 00:2d69 $ea $91 $dc
    add  A, $10                                        ;; 00:2d6c $c6 $10
    ld   B, A                                          ;; 00:2d6e $47
    ld   A, [wDC88]                                    ;; 00:2d6f $fa $88 $dc
    add  A, B                                          ;; 00:2d72 $80
    ld   B, A                                          ;; 00:2d73 $47
    call call_00_2f00                                  ;; 00:2d74 $cd $00 $2f
    jr   NZ, .jr_00_2d87                               ;; 00:2d77 $20 $0e
    ld   A, [wDC7E]                                    ;; 00:2d79 $fa $7e $dc
    and  A, A                                          ;; 00:2d7c $a7
    jr   Z, .jr_00_2d87                                ;; 00:2d7d $28 $08
    ld   A, [wDC71]                                    ;; 00:2d7f $fa $71 $dc
    and  A, $07                                        ;; 00:2d82 $e6 $07
    jp   NZ, .jp_00_2ece                               ;; 00:2d84 $c2 $ce $2e
.jr_00_2d87:
    ld   A, [wDAC2]                                    ;; 00:2d87 $fa $c2 $da
.jr_00_2d8a:
    push AF                                            ;; 00:2d8a $f5
    ld   A, [HL+]                                      ;; 00:2d8b $2a
    add  A, B                                          ;; 00:2d8c $80
    ld   [DE], A                                       ;; 00:2d8d $12
    inc  E                                             ;; 00:2d8e $1c
    ld   A, [HL+]                                      ;; 00:2d8f $2a
    add  A, C                                          ;; 00:2d90 $81
    ld   [DE], A                                       ;; 00:2d91 $12
    inc  E                                             ;; 00:2d92 $1c
    ld   A, [wDC52]                                    ;; 00:2d93 $fa $52 $dc
    ld   [DE], A                                       ;; 00:2d96 $12
    add  A, $02                                        ;; 00:2d97 $c6 $02
    ld   [wDC52], A                                    ;; 00:2d99 $ea $52 $dc
    inc  E                                             ;; 00:2d9c $1c
    ld   A, [wDC53]                                    ;; 00:2d9d $fa $53 $dc
    or   A, [HL]                                       ;; 00:2da0 $b6
    ld   [DE], A                                       ;; 00:2da1 $12
    inc  E                                             ;; 00:2da2 $1c
    inc  HL                                            ;; 00:2da3 $23
    inc  HL                                            ;; 00:2da4 $23
    pop  AF                                            ;; 00:2da5 $f1
    dec  A                                             ;; 00:2da6 $3d
    jr   NZ, .jr_00_2d8a                               ;; 00:2da7 $20 $e1
    jp   .jp_00_2ece                                   ;; 00:2da9 $c3 $ce $2e
.jp_00_2dac:
    ld   A, [wDBF9_XPositionInMap]                                    ;; 00:2dac $fa $f9 $db
    ld   C, A                                          ;; 00:2daf $4f
    ld   A, [wD80E]                                    ;; 00:2db0 $fa $0e $d8
    sub  A, C                                          ;; 00:2db3 $91
    add  A, $08                                        ;; 00:2db4 $c6 $08
    ld   [wDC90], A                                    ;; 00:2db6 $ea $90 $dc
    ld   C, A                                          ;; 00:2db9 $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2dba $fa $fb $db
    ld   B, A                                          ;; 00:2dbd $47
    ld   A, [wD810]                                    ;; 00:2dbe $fa $10 $d8
    sub  A, B                                          ;; 00:2dc1 $90
    add  A, $10                                        ;; 00:2dc2 $c6 $10
    ld   [wDC91], A                                    ;; 00:2dc4 $ea $91 $dc
    add  A, $10                                        ;; 00:2dc7 $c6 $10
    ld   B, A                                          ;; 00:2dc9 $47
    ld   A, [wDC88]                                    ;; 00:2dca $fa $88 $dc
    add  A, B                                          ;; 00:2dcd $80
    ld   B, A                                          ;; 00:2dce $47
    call call_00_2f00                                  ;; 00:2dcf $cd $00 $2f
    jr   NZ, .jr_00_2de2                               ;; 00:2dd2 $20 $0e
    ld   A, [wDC7E]                                    ;; 00:2dd4 $fa $7e $dc
    and  A, A                                          ;; 00:2dd7 $a7
    jr   Z, .jr_00_2de2                                ;; 00:2dd8 $28 $08
    ld   A, [wDC71]                                    ;; 00:2dda $fa $71 $dc
    and  A, $07                                        ;; 00:2ddd $e6 $07
    jp   NZ, .jp_00_2ece                               ;; 00:2ddf $c2 $ce $2e
.jr_00_2de2:
    ld   A, [wDAC2]                                    ;; 00:2de2 $fa $c2 $da
.jr_00_2de5:
    push AF                                            ;; 00:2de5 $f5
    ld   A, [HL+]                                      ;; 00:2de6 $2a
    add  A, B                                          ;; 00:2de7 $80
    ld   [DE], A                                       ;; 00:2de8 $12
    inc  E                                             ;; 00:2de9 $1c
    ld   A, [HL+]                                      ;; 00:2dea $2a
    cpl                                                ;; 00:2deb $2f
    inc  A                                             ;; 00:2dec $3c
    sub  A, $08                                        ;; 00:2ded $d6 $08
    add  A, C                                          ;; 00:2def $81
    ld   [DE], A                                       ;; 00:2df0 $12
    inc  E                                             ;; 00:2df1 $1c
    ld   A, [wDC52]                                    ;; 00:2df2 $fa $52 $dc
    ld   [DE], A                                       ;; 00:2df5 $12
    add  A, $02                                        ;; 00:2df6 $c6 $02
    ld   [wDC52], A                                    ;; 00:2df8 $ea $52 $dc
    inc  E                                             ;; 00:2dfb $1c
    ld   A, [wDC53]                                    ;; 00:2dfc $fa $53 $dc
    or   A, [HL]                                       ;; 00:2dff $b6
    ld   [DE], A                                       ;; 00:2e00 $12
    inc  E                                             ;; 00:2e01 $1c
    inc  HL                                            ;; 00:2e02 $23
    inc  HL                                            ;; 00:2e03 $23
    pop  AF                                            ;; 00:2e04 $f1
    dec  A                                             ;; 00:2e05 $3d
    jr   NZ, .jr_00_2de5                               ;; 00:2e06 $20 $dd
    jp   .jp_00_2ece                                   ;; 00:2e08 $c3 $ce $2e
.jp_00_2e0b:
    bit  5, A                                          ;; 00:2e0b $cb $6f
    jp   NZ, .jp_00_2e6f                               ;; 00:2e0d $c2 $6f $2e
    ld   A, [wDBF9_XPositionInMap]                                    ;; 00:2e10 $fa $f9 $db
    ld   C, A                                          ;; 00:2e13 $4f
    ld   A, [wD80E]                                    ;; 00:2e14 $fa $0e $d8
    sub  A, C                                          ;; 00:2e17 $91
    add  A, $08                                        ;; 00:2e18 $c6 $08
    ld   [wDC90], A                                    ;; 00:2e1a $ea $90 $dc
    ld   C, A                                          ;; 00:2e1d $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2e1e $fa $fb $db
    ld   B, A                                          ;; 00:2e21 $47
    ld   A, [wD810]                                    ;; 00:2e22 $fa $10 $d8
    sub  A, B                                          ;; 00:2e25 $90
    add  A, $10                                        ;; 00:2e26 $c6 $10
    ld   [wDC91], A                                    ;; 00:2e28 $ea $91 $dc
    add  A, $10                                        ;; 00:2e2b $c6 $10
    ld   B, A                                          ;; 00:2e2d $47
    ld   A, [wDC88]                                    ;; 00:2e2e $fa $88 $dc
    add  A, B                                          ;; 00:2e31 $80
    ld   B, A                                          ;; 00:2e32 $47
    call call_00_2f00                                  ;; 00:2e33 $cd $00 $2f
    jr   NZ, .jr_00_2e46                               ;; 00:2e36 $20 $0e
    ld   A, [wDC7E]                                    ;; 00:2e38 $fa $7e $dc
    and  A, A                                          ;; 00:2e3b $a7
    jr   Z, .jr_00_2e46                                ;; 00:2e3c $28 $08
    ld   A, [wDC71]                                    ;; 00:2e3e $fa $71 $dc
    and  A, $07                                        ;; 00:2e41 $e6 $07
    jp   NZ, .jp_00_2ece                               ;; 00:2e43 $c2 $ce $2e
.jr_00_2e46:
    ld   A, [wDAC2]                                    ;; 00:2e46 $fa $c2 $da
.jr_00_2e49:
    push AF                                            ;; 00:2e49 $f5
    ld   A, [HL+]                                      ;; 00:2e4a $2a
    cpl                                                ;; 00:2e4b $2f
    inc  A                                             ;; 00:2e4c $3c
    sub  A, $30                                        ;; 00:2e4d $d6 $30
    add  A, B                                          ;; 00:2e4f $80
    ld   [DE], A                                       ;; 00:2e50 $12
    inc  E                                             ;; 00:2e51 $1c
    ld   A, [HL+]                                      ;; 00:2e52 $2a
    add  A, C                                          ;; 00:2e53 $81
    ld   [DE], A                                       ;; 00:2e54 $12
    inc  E                                             ;; 00:2e55 $1c
    ld   A, [wDC52]                                    ;; 00:2e56 $fa $52 $dc
    ld   [DE], A                                       ;; 00:2e59 $12
    add  A, $02                                        ;; 00:2e5a $c6 $02
    ld   [wDC52], A                                    ;; 00:2e5c $ea $52 $dc
    inc  E                                             ;; 00:2e5f $1c
    ld   A, [wDC53]                                    ;; 00:2e60 $fa $53 $dc
    or   A, [HL]                                       ;; 00:2e63 $b6
    ld   [DE], A                                       ;; 00:2e64 $12
    inc  E                                             ;; 00:2e65 $1c
    inc  HL                                            ;; 00:2e66 $23
    inc  HL                                            ;; 00:2e67 $23
    pop  AF                                            ;; 00:2e68 $f1
    dec  A                                             ;; 00:2e69 $3d
    jr   NZ, .jr_00_2e49                               ;; 00:2e6a $20 $dd
    jp   .jp_00_2ece                                   ;; 00:2e6c $c3 $ce $2e
.jp_00_2e6f:
    ld   A, [wDBF9_XPositionInMap]                                    ;; 00:2e6f $fa $f9 $db
    ld   C, A                                          ;; 00:2e72 $4f
    ld   A, [wD80E]                                    ;; 00:2e73 $fa $0e $d8
    sub  A, C                                          ;; 00:2e76 $91
    add  A, $08                                        ;; 00:2e77 $c6 $08
    ld   [wDC90], A                                    ;; 00:2e79 $ea $90 $dc
    ld   C, A                                          ;; 00:2e7c $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2e7d $fa $fb $db
    ld   B, A                                          ;; 00:2e80 $47
    ld   A, [wD810]                                    ;; 00:2e81 $fa $10 $d8
    sub  A, B                                          ;; 00:2e84 $90
    add  A, $10                                        ;; 00:2e85 $c6 $10
    ld   [wDC91], A                                    ;; 00:2e87 $ea $91 $dc
    add  A, $10                                        ;; 00:2e8a $c6 $10
    ld   B, A                                          ;; 00:2e8c $47
    ld   A, [wDC88]                                    ;; 00:2e8d $fa $88 $dc
    add  A, B                                          ;; 00:2e90 $80
    ld   B, A                                          ;; 00:2e91 $47
    call call_00_2f00                                  ;; 00:2e92 $cd $00 $2f
    jr   NZ, .jr_00_2ea4                               ;; 00:2e95 $20 $0d
    ld   A, [wDC7E]                                    ;; 00:2e97 $fa $7e $dc
    and  A, A                                          ;; 00:2e9a $a7
    jr   Z, .jr_00_2ea4                                ;; 00:2e9b $28 $07
    ld   A, [wDC71]                                    ;; 00:2e9d $fa $71 $dc
    and  A, $07                                        ;; 00:2ea0 $e6 $07
    jr   NZ, .jp_00_2ece                               ;; 00:2ea2 $20 $2a
.jr_00_2ea4:
    ld   A, [wDAC2]                                    ;; 00:2ea4 $fa $c2 $da
.jr_00_2ea7:
    push AF                                            ;; 00:2ea7 $f5
    ld   A, [HL+]                                      ;; 00:2ea8 $2a
    cpl                                                ;; 00:2ea9 $2f
    inc  A                                             ;; 00:2eaa $3c
    sub  A, $30                                        ;; 00:2eab $d6 $30
    add  A, B                                          ;; 00:2ead $80
    ld   [DE], A                                       ;; 00:2eae $12
    inc  E                                             ;; 00:2eaf $1c
    ld   A, [HL+]                                      ;; 00:2eb0 $2a
    cpl                                                ;; 00:2eb1 $2f
    inc  A                                             ;; 00:2eb2 $3c
    sub  A, $08                                        ;; 00:2eb3 $d6 $08
    add  A, C                                          ;; 00:2eb5 $81
    ld   [DE], A                                       ;; 00:2eb6 $12
    inc  E                                             ;; 00:2eb7 $1c
    ld   A, [wDC52]                                    ;; 00:2eb8 $fa $52 $dc
    ld   [DE], A                                       ;; 00:2ebb $12
    add  A, $02                                        ;; 00:2ebc $c6 $02
    ld   [wDC52], A                                    ;; 00:2ebe $ea $52 $dc
    inc  E                                             ;; 00:2ec1 $1c
    ld   A, [wDC53]                                    ;; 00:2ec2 $fa $53 $dc
    or   A, [HL]                                       ;; 00:2ec5 $b6
    ld   [DE], A                                       ;; 00:2ec6 $12
    inc  E                                             ;; 00:2ec7 $1c
    inc  HL                                            ;; 00:2ec8 $23
    inc  HL                                            ;; 00:2ec9 $23
    pop  AF                                            ;; 00:2eca $f1
    dec  A                                             ;; 00:2ecb $3d
    jr   NZ, .jr_00_2ea7                               ;; 00:2ecc $20 $d9
.jp_00_2ece:
    ld   A, [wDC51]                                    ;; 00:2ece $fa $51 $dc
    and  A, A                                          ;; 00:2ed1 $a7
    jr   Z, .jr_00_2ef9                                ;; 00:2ed2 $28 $25
    ld   A, [wDC71]                                    ;; 00:2ed4 $fa $71 $dc
    rrca                                               ;; 00:2ed7 $0f
    and  A, $0f                                        ;; 00:2ed8 $e6 $0f
    add  A, A                                          ;; 00:2eda $87
    ld   L, A                                          ;; 00:2edb $6f
    ld   H, $00                                        ;; 00:2edc $26 $00
    ld   BC, $2f14                                     ;; 00:2ede $01 $14 $2f
    add  HL, BC                                        ;; 00:2ee1 $09
    ld   A, [wDC91]                                    ;; 00:2ee2 $fa $91 $dc
    add  A, [HL]                                       ;; 00:2ee5 $86
    sub  A, $20                                        ;; 00:2ee6 $d6 $20
    ld   [DE], A                                       ;; 00:2ee8 $12
    inc  E                                             ;; 00:2ee9 $1c
    inc  HL                                            ;; 00:2eea $23
    ld   A, [wDC90]                                    ;; 00:2eeb $fa $90 $dc
    add  A, [HL]                                       ;; 00:2eee $86
    ld   [DE], A                                       ;; 00:2eef $12
    inc  E                                             ;; 00:2ef0 $1c
    ld   A, $32                                        ;; 00:2ef1 $3e $32
    ld   [DE], A                                       ;; 00:2ef3 $12
    inc  E                                             ;; 00:2ef4 $1c
    ld   A, $08                                        ;; 00:2ef5 $3e $08
    ld   [DE], A                                       ;; 00:2ef7 $12
    inc  E                                             ;; 00:2ef8 $1c
.jr_00_2ef9:
    ld   A, E                                          ;; 00:2ef9 $7b
    ld   [wDC6F], A                                    ;; 00:2efa $ea $6f $dc
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2efd $c3 $08 $0f

call_00_2f00:
    push HL                                            ;; 00:2f00 $e5
    push DE                                            ;; 00:2f01 $d5
    push BC                                            ;; 00:2f02 $c5
    ld   [wDAD6_ReturnBank], A                                    ;; 00:2f03 $ea $d6 $da
    ld   A, $02                                        ;; 00:2f06 $3e $02
    ld   HL, $5541                                     ;; 00:2f08 $21 $41 $55
    call call_00_0edd_CallAltBankFunc                                  ;; 00:2f0b $cd $dd $0e
    pop  BC                                            ;; 00:2f0e $c1
    pop  DE                                            ;; 00:2f0f $d1
    pop  HL                                            ;; 00:2f10 $e1
    and  A, $08                                        ;; 00:2f11 $e6 $08
    ret                                                ;; 00:2f13 $c9
    db   $00, $fe, $fe, $fc, $fc, $fe, $fc, $00        ;; 00:2f14 ????????
    db   $fa, $02, $fc, $04, $fe, $02, $00, $04        ;; 00:2f1c ????????
    db   $00, $02, $fe, $00, $fe, $fe, $fc, $fc        ;; 00:2f24 ????????
    db   $fa, $fa, $fc, $f8, $fe, $fa, $00, $fc        ;; 00:2f2c ????????
    db   $fa, $19, $dc, $cd, $ee, $0e, $21, $1a        ;; 00:2f34 ????????
    db   $dc, $2a, $66, $6f, $23, $11, $03, $00        ;; 00:2f3c ????????
    db   $0e, $ff, $7e, $19, $0c, $a7, $20, $fa        ;; 00:2f44 ????????
    db   $c5, $cd, $08, $0f, $fa, $16, $dc, $cd        ;; 00:2f4c ????????
    db   $ee, $0e, $21, $17, $dc, $2a, $66, $6f        ;; 00:2f54 ????????
    db   $c1, $7e, $fe, $ff, $28, $1c, $e5, $6f        ;; 00:2f5c ????????
    db   $26, $00, $29, $29, $29, $11, $5f, $32        ;; 00:2f64 ????????
    db   $19, $7e, $fe, $ff, $28, $05, $cb, $77        ;; 00:2f6c ????????
    db   $28, $01, $0c, $e1, $11, $10, $00, $19        ;; 00:2f74 ????????
    db   $18, $df, $79, $f5, $cd, $08, $0f, $f1        ;; 00:2f7c ????????
    db   $c9                                           ;; 00:2f84 ?

call_00_2f85:
    xor  A, A                                          ;; 00:2f85 $af
    ld   [wDC68], A                                    ;; 00:2f86 $ea $68 $dc
    ld   A, [wDC19_CollectibleListBank]                                    ;; 00:2f89 $fa $19 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2f8c $cd $ee $0e
    ld   L, $00                                        ;; 00:2f8f $2e $00
.jr_00_2f91:
    ld   H, $d1                                        ;; 00:2f91 $26 $d1
    ld   A, $ff                                        ;; 00:2f93 $3e $ff
    bit  7, L                                          ;; 00:2f95 $cb $7d
    jr   Z, .jr_00_2f9a                                ;; 00:2f97 $28 $01
    xor  A, A                                          ;; 00:2f99 $af
.jr_00_2f9a:
    ld   [HL], A                                       ;; 00:2f9a $77
    inc  H                                             ;; 00:2f9b $24
    ld   [HL], $00                                     ;; 00:2f9c $36 $00
    dec  H                                             ;; 00:2f9e $25
    inc  L                                             ;; 00:2f9f $2c
    jr   NZ, .jr_00_2f91                               ;; 00:2fa0 $20 $ef
    ld   HL, wDC1A_CollectibleListBankOffset                                     ;; 00:2fa2 $21 $1a $dc
    ld   A, [HL+]                                      ;; 00:2fa5 $2a
    ld   H, [HL]                                       ;; 00:2fa6 $66
    ld   L, A                                          ;; 00:2fa7 $6f
    ld   E, $00                                        ;; 00:2fa8 $1e $00
.jr_00_2faa:
    ld   D, $d1                                        ;; 00:2faa $16 $d1
    ld   A, [HL+]                                      ;; 00:2fac $2a
    ld   [DE], A                                       ;; 00:2fad $12
    set  7, E                                          ;; 00:2fae $cb $fb
    ld   A, [HL+]                                      ;; 00:2fb0 $2a
    ld   [DE], A                                       ;; 00:2fb1 $12
    push AF                                            ;; 00:2fb2 $f5
    ld   D, $d0                                        ;; 00:2fb3 $16 $d0
    ld   A, [HL+]                                      ;; 00:2fb5 $2a
    ld   [DE], A                                       ;; 00:2fb6 $12
    pop  AF                                            ;; 00:2fb7 $f1
    res  7, E                                          ;; 00:2fb8 $cb $bb
    inc  E                                             ;; 00:2fba $1c
    and  A, A                                          ;; 00:2fbb $a7
    jr   NZ, .jr_00_2faa                               ;; 00:2fbc $20 $ec
    ld   DE, wD200                                     ;; 00:2fbe $11 $00 $d2
.jr_00_2fc1:
    ld   HL, wD100                                     ;; 00:2fc1 $21 $00 $d1
.jr_00_2fc4:
    ld   A, [HL+]                                      ;; 00:2fc4 $2a
    cp   A, $ff                                        ;; 00:2fc5 $fe $ff
    jr   Z, .jr_00_2fcc                                ;; 00:2fc7 $28 $03
    cp   A, E                                          ;; 00:2fc9 $bb
    jr   C, .jr_00_2fc4                                ;; 00:2fca $38 $f8
.jr_00_2fcc:
    ld   A, L                                          ;; 00:2fcc $7d
    dec  A                                             ;; 00:2fcd $3d
    ld   [DE], A                                       ;; 00:2fce $12
    inc  E                                             ;; 00:2fcf $1c
    jr   NZ, .jr_00_2fc1                               ;; 00:2fd0 $20 $ef
    ld   E, $00                                        ;; 00:2fd2 $1e $00
.jr_00_2fd4:
    ld   D, $d2                                        ;; 00:2fd4 $16 $d2
    ld   A, [DE]                                       ;; 00:2fd6 $1a
    ld   L, A                                          ;; 00:2fd7 $6f
    ld   H, $d1                                        ;; 00:2fd8 $26 $d1
    ld   B, $00                                        ;; 00:2fda $06 $00
    ld   C, $ff                                        ;; 00:2fdc $0e $ff
    ld   A, E                                          ;; 00:2fde $7b
    add  A, $0b                                        ;; 00:2fdf $c6 $0b
    jr   C, .jr_00_2fe4                                ;; 00:2fe1 $38 $01
    ld   C, A                                          ;; 00:2fe3 $4f
.jr_00_2fe4:
    inc  B                                             ;; 00:2fe4 $04
    ld   A, [HL+]                                      ;; 00:2fe5 $2a
    cp   A, $ff                                        ;; 00:2fe6 $fe $ff
    jr   Z, .jr_00_2fed                                ;; 00:2fe8 $28 $03
    cp   A, C                                          ;; 00:2fea $b9
    jr   C, .jr_00_2fe4                                ;; 00:2feb $38 $f7
.jr_00_2fed:
    ld   D, $d3                                        ;; 00:2fed $16 $d3
    ld   A, B                                          ;; 00:2fef $78
    dec  A                                             ;; 00:2ff0 $3d
    ld   [DE], A                                       ;; 00:2ff1 $12
    inc  E                                             ;; 00:2ff2 $1c
    jr   NZ, .jr_00_2fd4                               ;; 00:2ff3 $20 $df
    jp   call_00_0f08_SwitchBank2                                  ;; 00:2ff5 $c3 $08 $0f

call_00_2ff8:
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:2ff8 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2ffb $cd $ee $0e
    call call_00_3252                                  ;; 00:2ffe $cd $52 $32
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:3001 $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:3004 $2a
    ld   H, [HL]                                       ;; 00:3005 $66
    ld   L, A                                          ;; 00:3006 $6f
    ld   A, [HL]                                       ;; 00:3007 $7e
    cp   A, $ff                                        ;; 00:3008 $fe $ff
    jr   Z, .jr_00_3021                                ;; 00:300a $28 $15
.jr_00_300c:
    push HL                                            ;; 00:300c $e5
    ld   HL, wDAB8                                     ;; 00:300d $21 $b8 $da
    ld   A, [HL]                                       ;; 00:3010 $7e
    inc  [HL]                                          ;; 00:3011 $34
    ld   L, A                                          ;; 00:3012 $6f
    ld   H, $d7                                        ;; 00:3013 $26 $d7
    ld   [HL], $80                                     ;; 00:3015 $36 $80
    pop  HL                                            ;; 00:3017 $e1
    ld   DE, $10                                       ;; 00:3018 $11 $10 $00
    add  HL, DE                                        ;; 00:301b $19
    ld   A, [HL]                                       ;; 00:301c $7e
    cp   A, $ff                                        ;; 00:301d $fe $ff
    jr   NZ, .jr_00_300c                               ;; 00:301f $20 $eb
.jr_00_3021:
    xor  A, A                                          ;; 00:3021 $af
    ld   [wDCC5], A                                    ;; 00:3022 $ea $c5 $dc
    ld   [wDCC3], A                                    ;; 00:3025 $ea $c3 $dc
    ld   [wDCC6], A                                    ;; 00:3028 $ea $c6 $dc
    ld   [wDCC7], A                                    ;; 00:302b $ea $c7 $dc
    ld   [wDCC8], A                                    ;; 00:302e $ea $c8 $dc
    ld   [wDCC9], A                                    ;; 00:3031 $ea $c9 $dc
    ld   [wDCCA], A                                    ;; 00:3034 $ea $ca $dc
    ld   [wDCCB], A                                    ;; 00:3037 $ea $cb $dc
    ld   [wDCCC], A                                    ;; 00:303a $ea $cc $dc
    ld   [wDCCD], A                                    ;; 00:303d $ea $cd $dc
    ld   [wDCCE], A                                    ;; 00:3040 $ea $ce $dc
    ld   [wDCCF], A                                    ;; 00:3043 $ea $cf $dc
    ld   [wDCD0], A                                    ;; 00:3046 $ea $d0 $dc
    ld   [wDCD1], A                                    ;; 00:3049 $ea $d1 $dc
    ld   [wDCD2], A                                    ;; 00:304c $ea $d2 $dc
    ld   [wDCDA], A                                    ;; 00:304f $ea $da $dc
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:3052 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:3055 $6e
    ld   H, $00                                        ;; 00:3056 $26 $00
    add  HL, HL                                        ;; 00:3058 $29
    add  HL, HL                                        ;; 00:3059 $29
    add  HL, HL                                        ;; 00:305a $29
    add  HL, HL                                        ;; 00:305b $29
    ld   DE, $30ba                                     ;; 00:305c $11 $ba $30
    add  HL, DE                                        ;; 00:305f $19
    ld   DE, wDCB1                                     ;; 00:3060 $11 $b1 $dc
    ld   BC, $10                                       ;; 00:3063 $01 $10 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:3066 $cd $6e $07
    ld   HL, $317a                                     ;; 00:3069 $21 $7a $31
    ld   DE, wDCE2                                     ;; 00:306c $11 $e2 $dc
    ld   BC, $06                                       ;; 00:306f $01 $06 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:3072 $cd $6e $07
    ld   A, $02                                        ;; 00:3075 $3e $02
    ld   [wDCD5], A                                    ;; 00:3077 $ea $d5 $dc
    ld   [wDCD6], A                                    ;; 00:307a $ea $d6 $dc
    ld   [wDCD7], A                                    ;; 00:307d $ea $d7 $dc
    ld   [wDCD8], A                                    ;; 00:3080 $ea $d8 $dc
    ld   [wDCD9], A                                    ;; 00:3083 $ea $d9 $dc
    ld   HL, wDB6D                                     ;; 00:3086 $21 $6d $db
    ld   [HL], $00                                     ;; 00:3089 $36 $00
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:308b $fa $1e $dc
    cp   A, $07                                        ;; 00:308e $fe $07
    jr   Z, .jr_00_3096                                ;; 00:3090 $28 $04
    cp   A, $08                                        ;; 00:3092 $fe $08
    jr   NZ, .jr_00_30ab                               ;; 00:3094 $20 $15
.jr_00_3096:
    ld   [HL], $01                                     ;; 00:3096 $36 $01
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:3098 $fa $1e $dc
    cp   A, $07                                        ;; 00:309b $fe $07
    ld   A, $3c                                        ;; 00:309d $3e $3c
    jr   Z, .jr_00_30a3                                ;; 00:309f $28 $02
    ld   A, $69                                        ;; 00:30a1 $3e $69
.jr_00_30a3:
    ld   [wDB6E], A                                    ;; 00:30a3 $ea $6e $db
    ld   A, $3c                                        ;; 00:30a6 $3e $3c
    ld   [wDB6F], A                                    ;; 00:30a8 $ea $6f $db
.jr_00_30ab:
    call call_00_3180                                  ;; 00:30ab $cd $80 $31
    call call_00_31d9                                  ;; 00:30ae $cd $d9 $31
    call call_00_320d                                  ;; 00:30b1 $cd $0d $32
    call call_00_3252                                  ;; 00:30b4 $cd $52 $32
    jp   call_00_0f08_SwitchBank2                                  ;; 00:30b7 $c3 $08 $0f
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30ba ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30c2 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30ca ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30d2 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30da ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30e2 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30ea ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30f2 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:30fa ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3102 ????????
    db   $00, $01, $00, $00, $01, $00, $00, $00        ;; 00:310a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3112 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:311a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3122 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:312a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3132 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:313a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3142 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:314a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3152 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:315a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3162 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:316a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:3172 ????????
    db   $98, $02, $58, $01, $d8, $01                  ;; 00:317a ......

call_00_3180:
    ld   A, [wDC1E_CurrentLevelNumberFromMap]                                    ;; 00:3180 $fa $1e $dc
    and  A, A                                          ;; 00:3183 $a7
    jr   Z, .jr_00_31a0                                ;; 00:3184 $28 $1a
    ld   L, A                                          ;; 00:3186 $6f
    ld   H, $00                                        ;; 00:3187 $26 $00
    ld   DE, $31c1                                     ;; 00:3189 $11 $c1 $31
    add  HL, DE                                        ;; 00:318c $19
    ld   B, [HL]                                       ;; 00:318d $46
    ld   C, $01                                        ;; 00:318e $0e $01
.jr_00_3190:
    push BC                                            ;; 00:3190 $c5
    bit  0, B                                          ;; 00:3191 $cb $40
    call NZ, call_00_21f6                              ;; 00:3193 $c4 $f6 $21
    pop  BC                                            ;; 00:3196 $c1
    rr   B                                             ;; 00:3197 $cb $18
    inc  C                                             ;; 00:3199 $0c
    ld   A, C                                          ;; 00:319a $79
    cp   A, $04                                        ;; 00:319b $fe $04
    jr   C, .jr_00_3190                                ;; 00:319d $38 $f1
    ret                                                ;; 00:319f $c9
.jr_00_31a0:
    ld   BC, $01                                       ;; 00:31a0 $01 $01 $00
.jr_00_31a3:
    push BC                                            ;; 00:31a3 $c5
    push BC                                            ;; 00:31a4 $c5
    ld   [wDAD6_ReturnBank], A                                    ;; 00:31a5 $ea $d6 $da
    ld   A, $01                                        ;; 00:31a8 $3e $01
    ld   HL, $4ab9                                     ;; 00:31aa $21 $b9 $4a
    call call_00_0edd_CallAltBankFunc                                  ;; 00:31ad $cd $dd $0e
    pop  BC                                            ;; 00:31b0 $c1
    ld   HL, $31cd                                     ;; 00:31b1 $21 $cd $31
    add  HL, BC                                        ;; 00:31b4 $09
    cp   A, [HL]                                       ;; 00:31b5 $be
    call NC, call_00_21f6                              ;; 00:31b6 $d4 $f6 $21
    pop  BC                                            ;; 00:31b9 $c1
    inc  C                                             ;; 00:31ba $0c
    ld   A, C                                          ;; 00:31bb $79
    cp   A, $0c                                        ;; 00:31bc $fe $0c
    jr   C, .jr_00_31a3                                ;; 00:31be $38 $e3
    ret                                                ;; 00:31c0 $c9
    db   $00, $00, $01, $04, $05, $00, $00, $00        ;; 00:31c1 ?.??????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:31c9 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:31d1 ????????

call_00_31d9:
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:31d9 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:31dc $6e
    ld   H, $00                                        ;; 00:31dd $26 $00
    ld   DE, wDC5C                                     ;; 00:31df $11 $5c $dc
    add  HL, DE                                        ;; 00:31e2 $19
    bit  4, [HL]                                       ;; 00:31e3 $cb $66
    ret  Z                                             ;; 00:31e5 $c8
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:31e6 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:31e9 $cd $ee $0e
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:31ec $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:31ef $2a
    ld   H, [HL]                                       ;; 00:31f0 $66
    ld   L, A                                          ;; 00:31f1 $6f
    ld   DE, $10                                       ;; 00:31f2 $11 $10 $00
    ld   C, $01                                        ;; 00:31f5 $0e $01
    ld   A, [HL]                                       ;; 00:31f7 $7e
.jr_00_31f8:
    cp   A, $01                                        ;; 00:31f8 $fe $01
    jr   Z, .jr_00_3206                                ;; 00:31fa $28 $0a
    add  HL, DE                                        ;; 00:31fc $19
    inc  C                                             ;; 00:31fd $0c
    ld   A, [HL]                                       ;; 00:31fe $7e
    cp   A, $ff                                        ;; 00:31ff $fe $ff
    jr   NZ, .jr_00_31f8                               ;; 00:3201 $20 $f5
    jp   call_00_0f08_SwitchBank2                                  ;; 00:3203 $c3 $08 $0f
.jr_00_3206:
    ld   B, $d7                                        ;; 00:3206 $06 $d7
    xor  A, A                                          ;; 00:3208 $af
    ld   [BC], A                                       ;; 00:3209 $02
    jp   call_00_0f08_SwitchBank2                                  ;; 00:320a $c3 $08 $0f

call_00_320d:
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:320d $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:3210 $cd $ee $0e
    ld   HL, wDC1E_CurrentLevelNumberFromMap                                     ;; 00:3213 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:3216 $6e
    ld   H, $00                                        ;; 00:3217 $26 $00
    ld   DE, wDC5C                                     ;; 00:3219 $11 $5c $dc
    add  HL, DE                                        ;; 00:321c $19
    ld   C, [HL]                                       ;; 00:321d $4e
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:321e $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:3221 $2a
    ld   H, [HL]                                       ;; 00:3222 $66
    ld   L, A                                          ;; 00:3223 $6f
    ld   B, $01                                        ;; 00:3224 $06 $01
.jr_00_3226:
    push HL                                            ;; 00:3226 $e5
    ld   A, [HL]                                       ;; 00:3227 $7e
    cp   A, $03                                        ;; 00:3228 $fe $03
    jr   NZ, .jr_00_3240                               ;; 00:322a $20 $14
    ld   DE, $0d                                       ;; 00:322c $11 $0d $00
    add  HL, DE                                        ;; 00:322f $19
    ld   L, [HL]                                       ;; 00:3230 $6e
    ld   H, $00                                        ;; 00:3231 $26 $00
    ld   DE, $324e                                     ;; 00:3233 $11 $4e $32
    add  HL, DE                                        ;; 00:3236 $19
    ld   A, [HL]                                       ;; 00:3237 $7e
    and  A, C                                          ;; 00:3238 $a1
    jr   Z, .jr_00_3240                                ;; 00:3239 $28 $05
    ld   H, $d7                                        ;; 00:323b $26 $d7
    ld   L, B                                          ;; 00:323d $68
    ld   [HL], $00                                     ;; 00:323e $36 $00
.jr_00_3240:
    inc  B                                             ;; 00:3240 $04
    pop  HL                                            ;; 00:3241 $e1
    ld   DE, $10                                       ;; 00:3242 $11 $10 $00
    add  HL, DE                                        ;; 00:3245 $19
    ld   A, [HL]                                       ;; 00:3246 $7e
    cp   A, $ff                                        ;; 00:3247 $fe $ff
    jr   NZ, .jr_00_3226                               ;; 00:3249 $20 $db
    jp   call_00_0f08_SwitchBank2                                  ;; 00:324b $c3 $08 $0f
    db   $00, $20, $40, $80                            ;; 00:324e ?...

call_00_3252:
    ld   A, $01                                        ;; 00:3252 $3e $01
    ld   [wDAB8], A                                    ;; 00:3254 $ea $b8 $da
    ret                                                ;; 00:3257 $c9
    db   $00, $00, $00, $00, $00, $00, $00, $ff        ;; 00:3258 ????????
    db   $01, $0c, $0c, $07, $02, $00, $ff, $81        ;; 00:3260 ......??
    db   $01, $0c, $0c, $08, $02, $00, $ff, $81        ;; 00:3268 ......?.
    db   $01, $0c, $0c, $09, $02, $00, $ff, $81        ;; 00:3270 ......?.
    db   $01, $0c, $0c, $0a, $00, $00, $ff, $ff        ;; 00:3278 ????????
    db   $01, $0c, $0c, $0a, $00, $00, $ff, $ff        ;; 00:3280 ????????
    db   $01, $0c, $0c, $0a, $00, $00, $ff, $ff        ;; 00:3288 ????????
    db   $01, $0c, $0c, $0a, $00, $00, $ff, $ff        ;; 00:3290 ????????
    db   $01, $0c, $0c, $0a, $00, $00, $ff, $ff        ;; 00:3298 ????????
    db   $01, $0c, $10, $0b, $02, $00, $ff, $01        ;; 00:32a0 ????????
    db   $01, $0c, $10, $0b, $02, $00, $ff, $01        ;; 00:32a8 ????????
    db   $01, $0c, $10, $0b, $02, $00, $ff, $01        ;; 00:32b0 ????????
    db   $01, $0c, $10, $0b, $02, $00, $ff, $01        ;; 00:32b8 ????????
    db   $01, $0c, $10, $0b, $02, $00, $ff, $01        ;; 00:32c0 ????????
    db   $01, $08, $08, $00, $00, $00, $ff, $ff        ;; 00:32c8 ????????
    db   $01, $08, $08, $00, $00, $00, $ff, $ff        ;; 00:32d0 ????????
    db   $01, $08, $08, $00, $00, $00, $ff, $ff        ;; 00:32d8 ????????
    db   $01, $08, $08, $33, $00, $00, $ff, $ff        ;; 00:32e0 ......??
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:32e8 ......?.
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:32f0 ????????
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:32f8 ?.....??
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3300 ?.....??
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3308 ?.....??
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3310 ?.....??
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3318 ????????
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3320 ????????
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3328 ????????
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3330 ????????
    db   $01, $10, $10, $2d, $02, $00, $ff, $82        ;; 00:3338 ......?.
    db   $01, $0c, $10, $0c, $00, $00, $ff, $ff        ;; 00:3340 ......??
    db   $01, $0c, $10, $00, $00, $00, $ff, $ff        ;; 00:3348 ......??
    db   $01, $0c, $08, $0d, $00, $00, $ff, $ff        ;; 00:3350 ?.....??
    db   $01, $0c, $10, $0e, $00, $00, $ff, $c0        ;; 00:3358 ......?.
    db   $01, $0a, $0a, $04, $02, $00, $ff, $c3        ;; 00:3360 ......?.
    db   $01, $10, $10, $04, $02, $00, $ff, $c3        ;; 00:3368 ????????
    db   $01, $0c, $10, $0f, $02, $00, $ff, $01        ;; 00:3370 ????????
    db   $01, $0c, $0c, $02, $00, $00, $ff, $ff        ;; 00:3378 ????????
    db   $01, $08, $10, $10, $02, $00, $ff, $c2        ;; 00:3380 ????????
    db   $01, $10, $10, $04, $02, $00, $ff, $c3        ;; 00:3388 ????????
    db   $01, $0c, $10, $03, $00, $00, $ff, $ff        ;; 00:3390 ????????
    db   $01, $08, $08, $11, $04, $00, $ff, $85        ;; 00:3398 ????????
    db   $01, $0a, $0a, $04, $00, $00, $ff, $ff        ;; 00:33a0 ????????
    db   $01, $0c, $0c, $12, $00, $00, $ff, $ff        ;; 00:33a8 ????????
    db   $01, $10, $08, $13, $02, $00, $ff, $01        ;; 00:33b0 ????????
    db   $01, $0c, $08, $81, $00, $00, $ff, $ff        ;; 00:33b8 ????????
    db   $01, $0c, $08, $81, $00, $00, $ff, $ff        ;; 00:33c0 ????????
    db   $01, $0c, $0c, $04, $02, $00, $ff, $c4        ;; 00:33c8 ????????
    db   $01, $10, $08, $81, $00, $00, $ff, $ff        ;; 00:33d0 ????????
    db   $01, $08, $08, $04, $02, $00, $ff, $c3        ;; 00:33d8 ????????
    db   $01, $08, $08, $04, $02, $00, $ff, $c3        ;; 00:33e0 ????????
    db   $01, $06, $08, $03, $00, $00, $ff, $ff        ;; 00:33e8 ????????
    db   $01, $06, $08, $03, $00, $00, $ff, $ff        ;; 00:33f0 ????????
    db   $01, $08, $10, $14, $02, $00, $ff, $81        ;; 00:33f8 ????????
    db   $01, $0a, $0a, $34, $00, $00, $ff, $ff        ;; 00:3400 ????????
    db   $01, $0a, $0a, $34, $00, $00, $ff, $ff        ;; 00:3408 ????????
    db   $01, $12, $08, $81, $00, $00, $ff, $ff        ;; 00:3410 ????????
    db   $01, $10, $20, $15, $00, $00, $ff, $ff        ;; 00:3418 ????????
    db   $01, $10, $18, $2e, $03, $00, $ff, $46        ;; 00:3420 ????????
    db   $01, $10, $18, $04, $00, $00, $ff, $ff        ;; 00:3428 ????????
    db   $01, $0a, $10, $81, $00, $00, $ff, $ff        ;; 00:3430 ????????
    db   $01, $0a, $0a, $30, $02, $00, $ff, $c4        ;; 00:3438 ????????
    db   $01, $0a, $0a, $2f, $02, $00, $ff, $81        ;; 00:3440 ????????
    db   $01, $0a, $0a, $04, $02, $00, $ff, $84        ;; 00:3448 ????????
    db   $01, $0c, $08, $81, $00, $00, $ff, $ff        ;; 00:3450 ????????
    db   $01, $08, $08, $1a, $00, $00, $ff, $ff        ;; 00:3458 ????????
    db   $01, $08, $08, $1b, $00, $00, $ff, $ff        ;; 00:3460 ????????
    db   $01, $00, $00, $00, $00, $00, $ff, $ff        ;; 00:3468 ????????
    db   $01, $10, $10, $1f, $04, $00, $ff, $81        ;; 00:3470 ????????
    db   $01, $10, $10, $1f, $04, $00, $ff, $81        ;; 00:3478 ????????
    db   $01, $12, $08, $81, $00, $00, $ff, $ff        ;; 00:3480 ????????
    db   $01, $08, $08, $19, $00, $00, $ff, $ff        ;; 00:3488 ????????
    db   $01, $10, $20, $16, $02, $00, $ff, $01        ;; 00:3490 ????????
    db   $01, $08, $40, $81, $00, $00, $ff, $ff        ;; 00:3498 ????????
    db   $01, $08, $08, $81, $00, $00, $ff, $ff        ;; 00:34a0 ????????
    db   $01, $08, $08, $17, $00, $00, $ff, $ff        ;; 00:34a8 ????????
    db   $01, $08, $08, $18, $00, $00, $ff, $ff        ;; 00:34b0 ????????
    db   $01, $10, $10, $1d, $04, $00, $ff, $42        ;; 00:34b8 ????????
    db   $01, $10, $20, $1e, $04, $00, $ff, $03        ;; 00:34c0 ????????
    db   $01, $0a, $0a, $04, $02, $00, $ff, $c2        ;; 00:34c8 ????????
    db   $01, $0a, $0a, $1c, $03, $00, $ff, $c4        ;; 00:34d0 ????????
    db   $01, $0a, $0a, $03, $00, $00, $ff, $ff        ;; 00:34d8 ????????
    db   $01, $12, $08, $81, $00, $00, $ff, $ff        ;; 00:34e0 ????????
    db   $01, $0c, $0c, $04, $00, $00, $ff, $ff        ;; 00:34e8 ????????
    db   $01, $0a, $0a, $04, $00, $00, $ff, $ff        ;; 00:34f0 ????????
    db   $01, $14, $14, $20, $04, $00, $ff, $c1        ;; 00:34f8 ????????
    db   $01, $10, $18, $00, $06, $00, $ff, $05        ;; 00:3500 ????????
    db   $01, $0a, $0a, $25, $00, $00, $ff, $ff        ;; 00:3508 ????????
    db   $01, $10, $10, $81, $00, $00, $ff, $ff        ;; 00:3510 ????????
    db   $01, $14, $18, $26, $02, $00, $ff, $01        ;; 00:3518 ????????
    db   $01, $0c, $10, $22, $02, $00, $ff, $c3        ;; 00:3520 ????????
    db   $01, $0a, $0a, $04, $03, $00, $ff, $c3        ;; 00:3528 ????????
    db   $01, $0c, $0c, $21, $02, $00, $ff, $c5        ;; 00:3530 ????????
    db   $01, $0c, $10, $23, $04, $00, $ff, $c3        ;; 00:3538 ????????
    db   $01, $0c, $0c, $04, $04, $00, $ff, $c2        ;; 00:3540 ????????
    db   $01, $0a, $0a, $24, $03, $00, $ff, $c3        ;; 00:3548 ????????
    db   $01, $10, $08, $81, $00, $00, $ff, $ff        ;; 00:3550 ????????
    db   $01, $0a, $0a, $04, $00, $00, $ff, $ff        ;; 00:3558 ????????
    db   $01, $0c, $10, $27, $00, $00, $ff, $80        ;; 00:3560 ????????
    db   $01, $10, $10, $28, $02, $00, $ff, $81        ;; 00:3568 ????????
    db   $01, $10, $10, $29, $00, $00, $ff, $ff        ;; 00:3570 ????????
    db   $01, $08, $08, $00, $00, $00, $ff, $ff        ;; 00:3578 ????????
    db   $01, $0a, $0a, $04, $02, $00, $ff, $81        ;; 00:3580 ????????
    db   $01, $10, $20, $35, $04, $00, $ff, $05        ;; 00:3588 ????????
    db   $01, $0c, $10, $2b, $08, $00, $ff, $87        ;; 00:3590 ????????
    db   $01, $10, $10, $00, $00, $00, $ff, $ff        ;; 00:3598 ????????
    db   $01, $08, $08, $2a, $00, $00, $ff, $ff        ;; 00:35a0 ????????
    db   $01, $0a, $0a, $2c, $00, $00, $ff, $ff        ;; 00:35a8 ????????
    db   $01, $10, $10, $00, $00, $00, $ff, $ff        ;; 00:35b0 ????????
    db   $01, $10, $08, $81, $00, $00, $ff, $ff        ;; 00:35b8 ????????
    db   $01, $10, $08, $81, $00, $00, $ff, $ff        ;; 00:35c0 ????????
    db   $01, $1c, $20, $32, $10, $00, $ff, $8a        ;; 00:35c8 ????????
    db   $01, $0a, $40, $04, $00, $00, $ff, $ff        ;; 00:35d0 ????????
    db   $01, $0c, $0c, $31, $02, $00, $ff, $82        ;; 00:35d8 ????????
    db   $01, $0a, $0a, $04, $02, $00, $ff, $81        ;; 00:35e0 ????????

call_00_35e8:
    ld   HL, wDA00                                     ;; 00:35e8 $21 $00 $da
    ld   L, [HL]                                       ;; 00:35eb $6e
    ld   H, $d8                                        ;; 00:35ec $26 $d8
    ld   L, [HL]                                       ;; 00:35ee $6e
    ld   H, $00                                        ;; 00:35ef $26 $00
    add  HL, HL                                        ;; 00:35f1 $29
    add  HL, HL                                        ;; 00:35f2 $29
    add  HL, HL                                        ;; 00:35f3 $29
    ld   DE, $325f                                     ;; 00:35f4 $11 $5f $32
    add  HL, DE                                        ;; 00:35f7 $19
    ld   A, [HL]                                       ;; 00:35f8 $7e
    ret                                                ;; 00:35f9 $c9

call_00_35fa:
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:35fa $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:35fd $cd $ee $0e
.jr_00_3600:
    call call_00_3618                                  ;; 00:3600 $cd $18 $36
    ldh  A, [rLY]                                      ;; 00:3603 $f0 $44
    cp   A, $80                                        ;; 00:3605 $fe $80
    jr   C, .jr_00_3600                                ;; 00:3607 $38 $f7
    jp   call_00_0f08_SwitchBank2                                  ;; 00:3609 $c3 $08 $0f

call_00_360c:
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:360c $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:360f $cd $ee $0e
    call call_00_3618                                  ;; 00:3612 $cd $18 $36
    jp   call_00_0f08_SwitchBank2                                  ;; 00:3615 $c3 $08 $0f

call_00_3618:
    call call_00_2afc                                  ;; 00:3618 $cd $fc $2a
    jr   NZ, .jr_00_3641                               ;; 00:361b $20 $24
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:361d $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:3620 $2a
    ld   H, [HL]                                       ;; 00:3621 $66
    ld   L, A                                          ;; 00:3622 $6f
    ld   DE, hFFF0                                     ;; 00:3623 $11 $f0 $ff
    add  HL, DE                                        ;; 00:3626 $19
    ld   E, L                                          ;; 00:3627 $5d
    ld   D, H                                          ;; 00:3628 $54
    ld   HL, wDAB8                                     ;; 00:3629 $21 $b8 $da
    ld   L, [HL]                                       ;; 00:362c $6e
    ld   H, $00                                        ;; 00:362d $26 $00
    add  HL, HL                                        ;; 00:362f $29
    add  HL, HL                                        ;; 00:3630 $29
    add  HL, HL                                        ;; 00:3631 $29
    add  HL, HL                                        ;; 00:3632 $29
    add  HL, DE                                        ;; 00:3633 $19
    ld   E, L                                          ;; 00:3634 $5d
    ld   D, H                                          ;; 00:3635 $54
    ld   A, [DE]                                       ;; 00:3636 $1a
    cp   A, $ff                                        ;; 00:3637 $fe $ff
    jp   Z, call_00_3252                               ;; 00:3639 $ca $52 $32
    ld   HL, wDAB8                                     ;; 00:363c $21 $b8 $da
    inc  [HL]                                          ;; 00:363f $34
    ret                                                ;; 00:3640 $c9
.jr_00_3641:
    ld   [wDA00], A                                    ;; 00:3641 $ea $00 $da
    rlca                                               ;; 00:3644 $07
    rlca                                               ;; 00:3645 $07
    rlca                                               ;; 00:3646 $07
    ld   [wDAB9], A                                    ;; 00:3647 $ea $b9 $da
    ld   HL, wDC17_ObjectListBankOffset                                     ;; 00:364a $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:364d $2a
    ld   H, [HL]                                       ;; 00:364e $66
    ld   L, A                                          ;; 00:364f $6f
    ld   DE, hFFF0                                     ;; 00:3650 $11 $f0 $ff
    add  HL, DE                                        ;; 00:3653 $19
    ld   E, L                                          ;; 00:3654 $5d
    ld   D, H                                          ;; 00:3655 $54
    ld   HL, wDAB8                                     ;; 00:3656 $21 $b8 $da
    ld   L, [HL]                                       ;; 00:3659 $6e
    ld   H, $00                                        ;; 00:365a $26 $00
    add  HL, HL                                        ;; 00:365c $29
    add  HL, HL                                        ;; 00:365d $29
    add  HL, HL                                        ;; 00:365e $29
    add  HL, HL                                        ;; 00:365f $29
    add  HL, DE                                        ;; 00:3660 $19
    ld   E, L                                          ;; 00:3661 $5d
    ld   D, H                                          ;; 00:3662 $54
    ld   A, [DE]                                       ;; 00:3663 $1a
    cp   A, $ff                                        ;; 00:3664 $fe $ff
    jp   Z, call_00_3252                               ;; 00:3666 $ca $52 $32
    ld   [wDABB], A                                    ;; 00:3669 $ea $bb $da
    ld   HL, wDAB8                                     ;; 00:366c $21 $b8 $da
    ld   C, [HL]                                       ;; 00:366f $4e
    inc  [HL]                                          ;; 00:3670 $34
    ld   B, $d7                                        ;; 00:3671 $06 $d7
    ld   A, [BC]                                       ;; 00:3673 $0a
    and  A, A                                          ;; 00:3674 $a7
    ret  Z                                             ;; 00:3675 $c8
    bit  6, A                                          ;; 00:3676 $cb $77
    ret  NZ                                            ;; 00:3678 $c0
    ld   [wDABC], A                                    ;; 00:3679 $ea $bc $da
    bit  4, A                                          ;; 00:367c $cb $67
    jr   Z, .jr_00_3685                                ;; 00:367e $28 $05
    ld   A, $02                                        ;; 00:3680 $3e $02
    ld   [wDABB], A                                    ;; 00:3682 $ea $bb $da
.jr_00_3685:
    ld   A, C                                          ;; 00:3685 $79
    ld   [wDABA], A                                    ;; 00:3686 $ea $ba $da
    ld   HL, $0f                                       ;; 00:3689 $21 $0f $00
    add  HL, DE                                        ;; 00:368c $19
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:368d $fa $6c $db
    cp   A, [HL]                                       ;; 00:3690 $be
    ret  NZ                                            ;; 00:3691 $c0
    inc  DE                                            ;; 00:3692 $13
    ld   HL, $04                                       ;; 00:3693 $21 $04 $00
    add  HL, DE                                        ;; 00:3696 $19
    ld   C, L                                          ;; 00:3697 $4d
    ld   B, H                                          ;; 00:3698 $44
    ld   HL, wDA14                                     ;; 00:3699 $21 $14 $da
    ld   A, [BC]                                       ;; 00:369c $0a
    sub  A, [HL]                                       ;; 00:369d $96
    inc  HL                                            ;; 00:369e $23
    inc  BC                                            ;; 00:369f $03
    ld   A, [BC]                                       ;; 00:36a0 $0a
    sbc  A, [HL]                                       ;; 00:36a1 $9e
    ret  C                                             ;; 00:36a2 $d8
    inc  BC                                            ;; 00:36a3 $03
    ld   L, C                                          ;; 00:36a4 $69
    ld   H, B                                          ;; 00:36a5 $60
    ld   A, [wDA16]                                    ;; 00:36a6 $fa $16 $da
    sub  A, [HL]                                       ;; 00:36a9 $96
    inc  HL                                            ;; 00:36aa $23
    ld   A, [wDA17]                                    ;; 00:36ab $fa $17 $da
    sbc  A, [HL]                                       ;; 00:36ae $9e
    ret  C                                             ;; 00:36af $d8
    inc  HL                                            ;; 00:36b0 $23
    ld   C, L                                          ;; 00:36b1 $4d
    ld   B, H                                          ;; 00:36b2 $44
    ld   HL, wDA18                                     ;; 00:36b3 $21 $18 $da
    ld   A, [BC]                                       ;; 00:36b6 $0a
    sub  A, [HL]                                       ;; 00:36b7 $96
    inc  HL                                            ;; 00:36b8 $23
    inc  BC                                            ;; 00:36b9 $03
    ld   A, [BC]                                       ;; 00:36ba $0a
    sbc  A, [HL]                                       ;; 00:36bb $9e
    ret  C                                             ;; 00:36bc $d8
    inc  BC                                            ;; 00:36bd $03
    ld   L, C                                          ;; 00:36be $69
    ld   H, B                                          ;; 00:36bf $60
    ld   A, [wDA1A]                                    ;; 00:36c0 $fa $1a $da
    sub  A, [HL]                                       ;; 00:36c3 $96
    inc  HL                                            ;; 00:36c4 $23
    ld   A, [wDA1B]                                    ;; 00:36c5 $fa $1b $da
    sbc  A, [HL]                                       ;; 00:36c8 $9e
    ret  C                                             ;; 00:36c9 $d8
    ld   HL, wDAB9                                     ;; 00:36ca $21 $b9 $da
    ld   L, [HL]                                       ;; 00:36cd $6e
    ld   H, $00                                        ;; 00:36ce $26 $00
    add  HL, HL                                        ;; 00:36d0 $29
    add  HL, HL                                        ;; 00:36d1 $29
    add  HL, HL                                        ;; 00:36d2 $29
    add  HL, HL                                        ;; 00:36d3 $29
    ld   BC, wDA24                                     ;; 00:36d4 $01 $24 $da
    add  HL, BC                                        ;; 00:36d7 $09
    ld   C, L                                          ;; 00:36d8 $4d
    ld   B, H                                          ;; 00:36d9 $44
    ld   H, $d8                                        ;; 00:36da $26 $d8
    ld   A, [wDA00]                                    ;; 00:36dc $fa $00 $da
    or   A, $0e                                        ;; 00:36df $f6 $0e
    ld   L, A                                          ;; 00:36e1 $6f
    ld   A, [DE]                                       ;; 00:36e2 $1a
    ld   [HL+], A                                      ;; 00:36e3 $22
    ld   [BC], A                                       ;; 00:36e4 $02
    inc  BC                                            ;; 00:36e5 $03
    inc  DE                                            ;; 00:36e6 $13
    ld   A, [DE]                                       ;; 00:36e7 $1a
    ld   [HL+], A                                      ;; 00:36e8 $22
    ld   [BC], A                                       ;; 00:36e9 $02
    inc  BC                                            ;; 00:36ea $03
    inc  DE                                            ;; 00:36eb $13
    ld   A, [DE]                                       ;; 00:36ec $1a
    ld   [HL+], A                                      ;; 00:36ed $22
    ld   [BC], A                                       ;; 00:36ee $02
    inc  BC                                            ;; 00:36ef $03
    inc  DE                                            ;; 00:36f0 $13
    ld   A, [DE]                                       ;; 00:36f1 $1a
    ld   [HL], A                                       ;; 00:36f2 $77
    ld   [BC], A                                       ;; 00:36f3 $02
    inc  DE                                            ;; 00:36f4 $13
    ld   HL, wDAB9                                     ;; 00:36f5 $21 $b9 $da
    ld   L, [HL]                                       ;; 00:36f8 $6e
    ld   H, $00                                        ;; 00:36f9 $26 $00
    add  HL, HL                                        ;; 00:36fb $29
    add  HL, HL                                        ;; 00:36fc $29
    add  HL, HL                                        ;; 00:36fd $29
    add  HL, HL                                        ;; 00:36fe $29
    ld   BC, wDA1C                                     ;; 00:36ff $01 $1c $da
    add  HL, BC                                        ;; 00:3702 $09
    ld   A, [DE]                                       ;; 00:3703 $1a
    ld   [HL+], A                                      ;; 00:3704 $22
    inc  DE                                            ;; 00:3705 $13
    ld   A, [DE]                                       ;; 00:3706 $1a
    ld   [HL+], A                                      ;; 00:3707 $22
    inc  DE                                            ;; 00:3708 $13
    ld   A, [DE]                                       ;; 00:3709 $1a
    ld   [HL+], A                                      ;; 00:370a $22
    inc  DE                                            ;; 00:370b $13
    ld   A, [DE]                                       ;; 00:370c $1a
    ld   [HL+], A                                      ;; 00:370d $22
    inc  DE                                            ;; 00:370e $13
    ld   A, [DE]                                       ;; 00:370f $1a
    ld   [HL+], A                                      ;; 00:3710 $22
    inc  DE                                            ;; 00:3711 $13
    ld   A, [DE]                                       ;; 00:3712 $1a
    ld   [HL+], A                                      ;; 00:3713 $22
    inc  DE                                            ;; 00:3714 $13
    ld   A, [DE]                                       ;; 00:3715 $1a
    ld   [HL+], A                                      ;; 00:3716 $22
    inc  DE                                            ;; 00:3717 $13
    ld   A, [DE]                                       ;; 00:3718 $1a
    ld   [HL], A                                       ;; 00:3719 $77
    ld   HL, wDABB                                     ;; 00:371a $21 $bb $da
    ld   L, [HL]                                       ;; 00:371d $6e
    ld   H, $00                                        ;; 00:371e $26 $00
    add  HL, HL                                        ;; 00:3720 $29
    add  HL, HL                                        ;; 00:3721 $29
    add  HL, HL                                        ;; 00:3722 $29
    ld   BC, $3258                                     ;; 00:3723 $01 $58 $32
    add  HL, BC                                        ;; 00:3726 $09
    ld   A, [HL+]                                      ;; 00:3727 $2a
    ld   A, [wDA00]                                    ;; 00:3728 $fa $00 $da
    or   A, $00                                        ;; 00:372b $f6 $00
    ld   E, A                                          ;; 00:372d $5f
    ld   D, $d8                                        ;; 00:372e $16 $d8
    ld   A, [wDABB]                                    ;; 00:3730 $fa $bb $da
    ld   [DE], A                                       ;; 00:3733 $12
    ld   A, E                                          ;; 00:3734 $7b
    xor  A, $12                                        ;; 00:3735 $ee $12
    ld   E, A                                          ;; 00:3737 $5f
    ld   A, [HL+]                                      ;; 00:3738 $2a
    ld   [DE], A                                       ;; 00:3739 $12
    inc  E                                             ;; 00:373a $1c
    ld   A, [HL+]                                      ;; 00:373b $2a
    ld   [DE], A                                       ;; 00:373c $12
    inc  E                                             ;; 00:373d $1c
    ld   A, [HL+]                                      ;; 00:373e $2a
    ld   [DE], A                                       ;; 00:373f $12
    inc  E                                             ;; 00:3740 $1c
    xor  A, A                                          ;; 00:3741 $af
    ld   [DE], A                                       ;; 00:3742 $12
    inc  E                                             ;; 00:3743 $1c
    ld   A, [HL+]                                      ;; 00:3744 $2a
    dec  A                                             ;; 00:3745 $3d
    ld   [DE], A                                       ;; 00:3746 $12
    inc  E                                             ;; 00:3747 $1c
    inc  E                                             ;; 00:3748 $1c
    xor  A, A                                          ;; 00:3749 $af
    ld   [DE], A                                       ;; 00:374a $12
    inc  E                                             ;; 00:374b $1c
    ld   A, [HL]                                       ;; 00:374c $7e
    ld   [DE], A                                       ;; 00:374d $12
    inc  E                                             ;; 00:374e $1c
    xor  A, A                                          ;; 00:374f $af
    ld   [DE], A                                       ;; 00:3750 $12
    inc  E                                             ;; 00:3751 $1c
    ld   [DE], A                                       ;; 00:3752 $12
    inc  E                                             ;; 00:3753 $1c
    ld   [DE], A                                       ;; 00:3754 $12
    inc  E                                             ;; 00:3755 $1c
    ld   [DE], A                                       ;; 00:3756 $12
    inc  E                                             ;; 00:3757 $1c
    ld   [DE], A                                       ;; 00:3758 $12
    inc  E                                             ;; 00:3759 $1c
    ld   [DE], A                                       ;; 00:375a $12
    ld   A, E                                          ;; 00:375b $7b
    xor  A, $12                                        ;; 00:375c $ee $12
    ld   E, A                                          ;; 00:375e $5f
    ld   A, $00                                        ;; 00:375f $3e $00
    ld   [DE], A                                       ;; 00:3761 $12
    ld   HL, wDAB9                                     ;; 00:3762 $21 $b9 $da
    ld   L, [HL]                                       ;; 00:3765 $6e
    ld   H, $00                                        ;; 00:3766 $26 $00
    ld   DE, wDA01                                     ;; 00:3768 $11 $01 $da
    add  HL, DE                                        ;; 00:376b $19
    ld   A, [wDABA]                                    ;; 00:376c $fa $ba $da
    ld   [HL], A                                       ;; 00:376f $77
    ld   L, A                                          ;; 00:3770 $6f
    ld   H, $d7                                        ;; 00:3771 $26 $d7
    ld   A, [wDABC]                                    ;; 00:3773 $fa $bc $da
    or   A, $40                                        ;; 00:3776 $f6 $40
    ld   [HL], A                                       ;; 00:3778 $77
    and  A, $0f                                        ;; 00:3779 $e6 $0f
    ld   [wDAD6_ReturnBank], A                                    ;; 00:377b $ea $d6 $da
    ld   A, $02                                        ;; 00:377e $3e $02
    ld   HL, $72ac                                     ;; 00:3780 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:3783 $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:3786 $ea $d6 $da
    ld   A, $03                                        ;; 00:3789 $3e $03
    ld   HL, $687c                                     ;; 00:378b $21 $7c $68
    call call_00_0edd_CallAltBankFunc                                  ;; 00:378e $cd $dd $0e
    ret                                                ;; 00:3791 $c9

call_00_3792:
    push BC                                            ;; 00:3792 $c5
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:3793 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:3796 $cd $ee $0e
    pop  BC                                            ;; 00:3799 $c1
    call call_00_37a0                                  ;; 00:379a $cd $a0 $37
    jp   call_00_0f08_SwitchBank2                                  ;; 00:379d $c3 $08 $0f

call_00_37a0:
    call call_00_2afc                                  ;; 00:37a0 $cd $fc $2a
    ret  Z                                             ;; 00:37a3 $c8
    push DE                                            ;; 00:37a4 $d5
    ld   [wDAD6_ReturnBank], A                                    ;; 00:37a5 $ea $d6 $da
    ld   A, $03                                        ;; 00:37a8 $3e $03
    ld   HL, $59c6                                     ;; 00:37aa $21 $c6 $59
    call call_00_0edd_CallAltBankFunc                                  ;; 00:37ad $cd $dd $0e
    ld   [wDCE9], A                                    ;; 00:37b0 $ea $e9 $dc
    ld   A, [wDA00]                                    ;; 00:37b3 $fa $00 $da
    rlca                                               ;; 00:37b6 $07
    rlca                                               ;; 00:37b7 $07
    rlca                                               ;; 00:37b8 $07
    and  A, $07                                        ;; 00:37b9 $e6 $07
    ld   L, A                                          ;; 00:37bb $6f
    ld   H, $00                                        ;; 00:37bc $26 $00
    ld   DE, wDA01                                     ;; 00:37be $11 $01 $da
    add  HL, DE                                        ;; 00:37c1 $19
    ld   A, [HL]                                       ;; 00:37c2 $7e
    ld   [wDCE8], A                                    ;; 00:37c3 $ea $e8 $dc
    pop  DE                                            ;; 00:37c6 $d1
    ld   L, C                                          ;; 00:37c7 $69
    ld   H, $00                                        ;; 00:37c8 $26 $00
    add  HL, HL                                        ;; 00:37ca $29
    add  HL, HL                                        ;; 00:37cb $29
    add  HL, HL                                        ;; 00:37cc $29
    ld   BC, $38b6                                     ;; 00:37cd $01 $b6 $38
    add  HL, BC                                        ;; 00:37d0 $09
    ld   A, [HL+]                                      ;; 00:37d1 $2a
    ld   A, [wDA00]                                    ;; 00:37d2 $fa $00 $da
    push AF                                            ;; 00:37d5 $f5
    or   A, $0d                                        ;; 00:37d6 $f6 $0d
    ld   C, A                                          ;; 00:37d8 $4f
    ld   B, $d8                                        ;; 00:37d9 $06 $d8
    ld   A, D                                          ;; 00:37db $7a
    ld   [wDA00], A                                    ;; 00:37dc $ea $00 $da
    or   A, $0d                                        ;; 00:37df $f6 $0d
    ld   E, A                                          ;; 00:37e1 $5f
    ld   D, B                                          ;; 00:37e2 $50
    ld   A, [BC]                                       ;; 00:37e3 $0a
    ld   [DE], A                                       ;; 00:37e4 $12
    ld   A, [wDCE9]                                    ;; 00:37e5 $fa $e9 $dc
    and  A, A                                          ;; 00:37e8 $a7
    jr   NZ, .jr_00_37f0                               ;; 00:37e9 $20 $05
    ld   A, [DE]                                       ;; 00:37eb $1a
    bit  5, A                                          ;; 00:37ec $cb $6f
    jr   NZ, .jr_00_37fd                               ;; 00:37ee $20 $0d
.jr_00_37f0:
    inc  C                                             ;; 00:37f0 $0c
    inc  E                                             ;; 00:37f1 $1c
    ld   A, [BC]                                       ;; 00:37f2 $0a
    add  A, [HL]                                       ;; 00:37f3 $86
    ld   [DE], A                                       ;; 00:37f4 $12
    inc  BC                                            ;; 00:37f5 $03
    inc  DE                                            ;; 00:37f6 $13
    inc  HL                                            ;; 00:37f7 $23
    ld   A, [BC]                                       ;; 00:37f8 $0a
    adc  A, [HL]                                       ;; 00:37f9 $8e
    ld   [DE], A                                       ;; 00:37fa $12
    jr   .jr_00_3808                                   ;; 00:37fb $18 $0b
.jr_00_37fd:
    inc  C                                             ;; 00:37fd $0c
    inc  E                                             ;; 00:37fe $1c
    ld   A, [BC]                                       ;; 00:37ff $0a
    sub  A, [HL]                                       ;; 00:3800 $96
    ld   [DE], A                                       ;; 00:3801 $12
    inc  BC                                            ;; 00:3802 $03
    inc  DE                                            ;; 00:3803 $13
    inc  HL                                            ;; 00:3804 $23
    ld   A, [BC]                                       ;; 00:3805 $0a
    sbc  A, [HL]                                       ;; 00:3806 $9e
    ld   [DE], A                                       ;; 00:3807 $12
.jr_00_3808:
    inc  C                                             ;; 00:3808 $0c
    inc  E                                             ;; 00:3809 $1c
    inc  HL                                            ;; 00:380a $23
    ld   A, [BC]                                       ;; 00:380b $0a
    add  A, [HL]                                       ;; 00:380c $86
    ld   [DE], A                                       ;; 00:380d $12
    inc  BC                                            ;; 00:380e $03
    inc  DE                                            ;; 00:380f $13
    inc  HL                                            ;; 00:3810 $23
    ld   A, [BC]                                       ;; 00:3811 $0a
    adc  A, [HL]                                       ;; 00:3812 $8e
    ld   [DE], A                                       ;; 00:3813 $12
    inc  HL                                            ;; 00:3814 $23
    ld   A, E                                          ;; 00:3815 $7b
    xor  A, $11                                        ;; 00:3816 $ee $11
    ld   E, A                                          ;; 00:3818 $5f
    ld   A, [HL+]                                      ;; 00:3819 $2a
    ld   [DE], A                                       ;; 00:381a $12
    ld   L, A                                          ;; 00:381b $6f
    ld   H, $00                                        ;; 00:381c $26 $00
    add  HL, HL                                        ;; 00:381e $29
    add  HL, HL                                        ;; 00:381f $29
    add  HL, HL                                        ;; 00:3820 $29
    ld   BC, $3259                                     ;; 00:3821 $01 $59 $32
    add  HL, BC                                        ;; 00:3824 $09
    ld   A, E                                          ;; 00:3825 $7b
    xor  A, $12                                        ;; 00:3826 $ee $12
    ld   E, A                                          ;; 00:3828 $5f
    ld   A, [HL+]                                      ;; 00:3829 $2a
    ld   [DE], A                                       ;; 00:382a $12
    inc  E                                             ;; 00:382b $1c
    ld   A, [HL+]                                      ;; 00:382c $2a
    ld   [DE], A                                       ;; 00:382d $12
    inc  E                                             ;; 00:382e $1c
    ld   A, [HL+]                                      ;; 00:382f $2a
    ld   [DE], A                                       ;; 00:3830 $12
    inc  E                                             ;; 00:3831 $1c
    xor  A, A                                          ;; 00:3832 $af
    ld   [DE], A                                       ;; 00:3833 $12
    inc  E                                             ;; 00:3834 $1c
    ld   A, [HL+]                                      ;; 00:3835 $2a
    dec  A                                             ;; 00:3836 $3d
    ld   [DE], A                                       ;; 00:3837 $12
    inc  E                                             ;; 00:3838 $1c
    inc  E                                             ;; 00:3839 $1c
    xor  A, A                                          ;; 00:383a $af
    ld   [DE], A                                       ;; 00:383b $12
    inc  E                                             ;; 00:383c $1c
    ld   A, [HL+]                                      ;; 00:383d $2a
    ld   [DE], A                                       ;; 00:383e $12
    inc  E                                             ;; 00:383f $1c
    xor  A, A                                          ;; 00:3840 $af
    ld   [DE], A                                       ;; 00:3841 $12
    inc  E                                             ;; 00:3842 $1c
    ld   [DE], A                                       ;; 00:3843 $12
    inc  E                                             ;; 00:3844 $1c
    ld   [DE], A                                       ;; 00:3845 $12
    inc  E                                             ;; 00:3846 $1c
    ld   [DE], A                                       ;; 00:3847 $12
    inc  E                                             ;; 00:3848 $1c
    ld   [DE], A                                       ;; 00:3849 $12
    inc  E                                             ;; 00:384a $1c
    ld   A, [wDCE8]                                    ;; 00:384b $fa $e8 $dc
    ld   [DE], A                                       ;; 00:384e $12
    call call_00_2a03                                  ;; 00:384f $cd $03 $2a
    xor  A, A                                          ;; 00:3852 $af
    ld   [wDAD6_ReturnBank], A                                    ;; 00:3853 $ea $d6 $da
    ld   A, $02                                        ;; 00:3856 $3e $02
    ld   HL, $72ac                                     ;; 00:3858 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:385b $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:385e $ea $d6 $da
    ld   A, $03                                        ;; 00:3861 $3e $03
    ld   HL, $687c                                     ;; 00:3863 $21 $7c $68
    call call_00_0edd_CallAltBankFunc                                  ;; 00:3866 $cd $dd $0e
    pop  AF                                            ;; 00:3869 $f1
    ld   HL, wDA00                                     ;; 00:386a $21 $00 $da
    ld   C, [HL]                                       ;; 00:386d $4e
    ld   [HL], A                                       ;; 00:386e $77
    rrca                                               ;; 00:386f $0f
    and  A, $70                                        ;; 00:3870 $e6 $70
    ld   L, A                                          ;; 00:3872 $6f
    ld   H, $00                                        ;; 00:3873 $26 $00
    ld   DE, wDA1C                                     ;; 00:3875 $11 $1c $da
    add  HL, DE                                        ;; 00:3878 $19
    ld   E, L                                          ;; 00:3879 $5d
    ld   D, H                                          ;; 00:387a $54
    ld   A, C                                          ;; 00:387b $79
    rrca                                               ;; 00:387c $0f
    and  A, $70                                        ;; 00:387d $e6 $70
    ld   L, A                                          ;; 00:387f $6f
    ld   H, $00                                        ;; 00:3880 $26 $00
    ld   BC, wDA1C                                     ;; 00:3882 $01 $1c $da
    add  HL, BC                                        ;; 00:3885 $09
    ld   A, [DE]                                       ;; 00:3886 $1a
    ld   [HL+], A                                      ;; 00:3887 $22
    inc  DE                                            ;; 00:3888 $13
    ld   A, [DE]                                       ;; 00:3889 $1a
    ld   [HL+], A                                      ;; 00:388a $22
    inc  DE                                            ;; 00:388b $13
    ld   A, [DE]                                       ;; 00:388c $1a
    ld   [HL+], A                                      ;; 00:388d $22
    inc  DE                                            ;; 00:388e $13
    ld   A, [DE]                                       ;; 00:388f $1a
    ld   [HL+], A                                      ;; 00:3890 $22
    inc  DE                                            ;; 00:3891 $13
    ld   A, [DE]                                       ;; 00:3892 $1a
    ld   [HL+], A                                      ;; 00:3893 $22
    inc  DE                                            ;; 00:3894 $13
    ld   A, [DE]                                       ;; 00:3895 $1a
    ld   [HL+], A                                      ;; 00:3896 $22
    inc  DE                                            ;; 00:3897 $13
    ld   A, [DE]                                       ;; 00:3898 $1a
    ld   [HL+], A                                      ;; 00:3899 $22
    inc  DE                                            ;; 00:389a $13
    ld   A, [DE]                                       ;; 00:389b $1a
    ld   [HL+], A                                      ;; 00:389c $22
    inc  DE                                            ;; 00:389d $13
    ld   A, [DE]                                       ;; 00:389e $1a
    ld   [HL+], A                                      ;; 00:389f $22
    inc  DE                                            ;; 00:38a0 $13
    ld   A, [DE]                                       ;; 00:38a1 $1a
    ld   [HL+], A                                      ;; 00:38a2 $22
    inc  DE                                            ;; 00:38a3 $13
    ld   A, [DE]                                       ;; 00:38a4 $1a
    ld   [HL+], A                                      ;; 00:38a5 $22
    inc  DE                                            ;; 00:38a6 $13
    ld   A, [DE]                                       ;; 00:38a7 $1a
    ld   [HL+], A                                      ;; 00:38a8 $22
    inc  DE                                            ;; 00:38a9 $13
    ld   A, [DE]                                       ;; 00:38aa $1a
    ld   [HL+], A                                      ;; 00:38ab $22
    inc  DE                                            ;; 00:38ac $13
    ld   A, [DE]                                       ;; 00:38ad $1a
    ld   [HL+], A                                      ;; 00:38ae $22
    inc  DE                                            ;; 00:38af $13
    ld   A, [DE]                                       ;; 00:38b0 $1a
    ld   [HL+], A                                      ;; 00:38b1 $22
    inc  DE                                            ;; 00:38b2 $13
    ld   A, [DE]                                       ;; 00:38b3 $1a
    ld   [HL], A                                       ;; 00:38b4 $77
    ret                                                ;; 00:38b5 $c9
    db   $01, $00, $00, $e0, $ff, $04, $00, $00        ;; 00:38b6 ????????
    db   $01, $00, $00, $e0, $ff, $05, $00, $00        ;; 00:38be ????????
    db   $01, $00, $00, $e0, $ff, $06, $00, $00        ;; 00:38c6 ????????
    db   $01, $00, $00, $e0, $ff, $07, $00, $00        ;; 00:38ce ????????
    db   $01, $00, $00, $e0, $ff, $08, $00, $00        ;; 00:38d6 ????????
    db   $01, $f3, $ff, $fd, $ff, $1f, $00, $00        ;; 00:38de .????w??
    db   $01, $0e, $00, $fb, $ff, $27, $00, $00        ;; 00:38e6 ????????
    db   $01, $00, $00, $00, $00, $14, $00, $00        ;; 00:38ee .????w??
    db   $01, $00, $00, $00, $00, $15, $00, $00        ;; 00:38f6 .????w??
    db   $01, $00, $00, $00, $00, $16, $00, $00        ;; 00:38fe .????w??
    db   $01, $00, $00, $00, $00, $17, $00, $00        ;; 00:3906 .????w??
    db   $01, $00, $00, $00, $00, $18, $00, $00        ;; 00:390e ????????
    db   $01, $00, $00, $00, $00, $19, $00, $00        ;; 00:3916 ????????
    db   $01, $00, $00, $00, $00, $1a, $00, $00        ;; 00:391e ????????
    db   $01, $07, $00, $07, $00, $32, $00, $00        ;; 00:3926 ????????
    db   $01, $07, $00, $07, $00, $33, $00, $00        ;; 00:392e ????????
    db   $01, $0c, $00, $00, $00, $50, $00, $00        ;; 00:3936 ????????
    db   $00, $00, $00, $00, $00, $0e, $00, $00        ;; 00:393e ????????
    db   $00, $00, $00, $00, $00, $0f, $00, $00        ;; 00:3946 ????????
    db   $00, $00, $00, $00, $00, $10, $00, $00        ;; 00:394e ????????
    db   $00, $00, $00, $08, $00, $60, $00, $00        ;; 00:3956 ????????
    db   $00, $f0, $ff, $04, $00, $56, $00, $00        ;; 00:395e ????????
    db   $00, $01, $00, $f0, $ff, $68, $00, $00        ;; 00:3966 ????????
    db   $00, $00, $00, $00, $00, $6b, $00, $00        ;; 00:396e ????????
    db   $00, $00, $00, $08, $00, $6a, $00, $00        ;; 00:3976 ????????
    db   $00, $00, $00, $00, $00, $1b, $00, $00        ;; 00:397e ????????
    db   $01, $00, $00, $00, $00, $50, $00, $00        ;; 00:3986 ????????
    db   $01, $04, $00, $f2, $ff, $29, $00, $00        ;; 00:398e ????????
    db   $00, $ff, $ff, $0b, $00, $65, $00, $00        ;; 00:3996 ????????
    db   $00, $c0, $ff, $50, $00, $71, $00, $00        ;; 00:399e ????????
    db   $00, $40, $00, $50, $00, $71, $00, $00        ;; 00:39a6 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $6b        ;; 00:39ae ????????
    db   $00, $00, $00, $00, $00, $08, $00, $6a        ;; 00:39b6 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $1b        ;; 00:39be ????????
    db   $00, $00, $01, $00, $00, $00, $00, $50        ;; 00:39c6 ????????
    db   $00, $00, $01, $04, $00, $f2, $ff, $29        ;; 00:39ce ????????
    db   $00, $00, $00, $ff, $ff, $0b, $00, $65        ;; 00:39d6 ????????
    db   $00, $00, $00, $c0, $ff, $50, $00, $71        ;; 00:39de ????????
    db   $00, $00, $00, $40, $00, $50, $00, $71        ;; 00:39e6 ????????
