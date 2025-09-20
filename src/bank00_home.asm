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
    jp   call_00_0150_Init                                   ;; 00:0101 $c3 $50 $01
    ds   $30                                           ;; 00:0104
    db   "POCKET GEX3AXGE"                             ;; 00:0134
    db   CART_COMPATIBLE_GBC                           ;; 00:0143
    db   $34, $46                                      ;; 00:0144 ??
    db   CART_INDICATOR_GB                             ;; 00:0146
    db   CART_ROM_MBC5, CART_ROM_2048KB, CART_SRAM_NONE ;; 00:0147
    db   CART_DEST_NON_JAPANESE, $33, $00              ;; 00:014a $01 $33 $00
    ds   3                                             ;; 00:014d

call_00_0150_Init:
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
    call call_00_0f25_AltSwitchBank                                  ;; 00:020d $cd $25 $0f
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
    call entry_04_4000                                  ;; 00:0239 $cd $00 $40
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
    ld   HL, entry_01_435e                                     ;; 00:0320 $21 $5e $43
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0323 $cd $dd $0e
.jr_00_0326:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0326 $ea $d6 $da
    ld   A, $03                                        ;; 00:0329 $3e $03
    ld   HL, entry_03_6c89_CopyLevelData                              ;; 00:032b $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:032e $cd $dd $0e
    ld   A, [wDC4F]                                    ;; 00:0331 $fa $4f $dc
    add  A, $04                                        ;; 00:0334 $c6 $04
    ld   [wDC50], A                                    ;; 00:0336 $ea $50 $dc
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0339 $ea $d6 $da
    ld   A, $01                                        ;; 00:033c $3e $01
    ld   HL, entry_01_432b                                     ;; 00:033e $21 $2b $43
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0341 $cd $dd $0e
    call call_00_0e3b                                  ;; 00:0344 $cd $3b $0e
    call call_00_2f85_LoadCollectibleMapData                                  ;; 00:0347 $cd $85 $2f
    call call_00_2ff8                                  ;; 00:034a $cd $f8 $2f
    call call_00_0595                                  ;; 00:034d $cd $95 $05
    call call_00_1ea0_UpdateMain                                  ;; 00:0350 $cd $a0 $1e
    xor  A, A                                          ;; 00:0353 $af
    ld   [wDC69], A                                    ;; 00:0354 $ea $69 $dc
.jp_00_0357:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:0357 $fa $1e $dc
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:035a $ea $6c $db
    ld   [wDAD6_ReturnBank], A                                    ;; 00:035d $ea $d6 $da
    ld   A, $03                                        ;; 00:0360 $3e $03
    ld   HL, entry_03_6c89_CopyLevelData                              ;; 00:0362 $21 $89 $6c
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
    call call_00_2f85_LoadCollectibleMapData                                  ;; 00:0388 $cd $85 $2f
    call call_00_2ff8                                  ;; 00:038b $cd $f8 $2f
.jp_00_038e:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:038e $ea $d6 $da
    ld   A, $03                                        ;; 00:0391 $3e $03
    ld   HL, entry_03_6c89_CopyLevelData                              ;; 00:0393 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0396 $cd $dd $0e
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:0399 $fa $1e $dc
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
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:03b6 $fa $1e $dc
    cp   A, $08                                        ;; 00:03b9 $fe $08
    ld   A, $2f                                        ;; 00:03bb $3e $2f
    jr   Z, .jr_00_03e8                                ;; 00:03bd $28 $29
    ld   A, [wDC1F]                                    ;; 00:03bf $fa $1f $dc
    cp   A, $01                                        ;; 00:03c2 $fe $01
    jr   Z, .jr_00_03d6                                ;; 00:03c4 $28 $10
    ld   A, [wDC78]                                    ;; 00:03c6 $fa $78 $dc
    cp   A, $00                                        ;; 00:03c9 $fe $00
    jr   Z, .jr_00_03e8                                ;; 00:03cb $28 $1b
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 00:03cd $fa $01 $d8
    sub  A, $3c                                        ;; 00:03d0 $d6 $3c
    jr   C, .jr_00_03eb                                ;; 00:03d2 $38 $17
    jr   .jr_00_03e8                                   ;; 00:03d4 $18 $12
.jr_00_03d6:
    ld   A, [wDC78]                                    ;; 00:03d6 $fa $78 $dc
    cp   A, $00                                        ;; 00:03d9 $fe $00
    ld   A, $3c                                        ;; 00:03db $3e $3c
    jr   Z, .jr_00_03e8                                ;; 00:03dd $28 $09
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 00:03df $fa $01 $d8
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
    ld   HL, entry_03_647c                                     ;; 00:03fc $21 $7c $64
    call call_00_0edd_CallAltBankFunc                                  ;; 00:03ff $cd $dd $0e
    call call_00_1056_LoadMap                                  ;; 00:0402 $cd $56 $10
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0405 $ea $d6 $da
    ld   A, $02                                        ;; 00:0408 $3e $02
    ld   HL, entry_02_708f                                     ;; 00:040a $21 $8f $70
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
    ld   HL, entry_02_7142                                     ;; 00:042f $21 $42 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:0432 $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0435 $ea $d6 $da
    ld   A, $03                                        ;; 00:0438 $3e $03
    ld   HL, entry_03_68d9                                     ;; 00:043a $21 $d9 $68
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
    ld   HL, entry_01_42fd                                     ;; 00:0479 $21 $fd $42
    call call_00_0edd_CallAltBankFunc                                  ;; 00:047c $cd $dd $0e
    cp   A, $40                                        ;; 00:047f $fe $40
    jp   Z, .jp_00_02cc                                ;; 00:0481 $ca $cc $02
    jp   .jp_00_02b2                                   ;; 00:0484 $c3 $b2 $02
.jr_00_0487:
    ld   [wDAD6_ReturnBank], A                                    ;; 00:0487 $ea $d6 $da
    ld   A, $02                                        ;; 00:048a $3e $02
    ld   HL, entry_02_5541                                     ;; 00:048c $21 $41 $55
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
    ld   HL, entry_02_7132                                     ;; 00:04aa $21 $32 $71
    call call_00_0edd_CallAltBankFunc                                  ;; 00:04ad $cd $dd $0e
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:04b0 $fa $1e $dc
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
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:04ca $fa $1e $dc
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
    ld   [wDABF_GexSpriteBank], A                                    ;; 00:0528 $ea $bf $da
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
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:053d $fa $bf $da
    add  A, C                                          ;; 00:0540 $81
    ld   [wDABF_GexSpriteBank], A                                    ;; 00:0541 $ea $bf $da
    call call_00_0f08_SwitchBank2                                  ;; 00:0544 $cd $08 $0f
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:0547 $fa $bf $da
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
    ld   HL, entry_03_5ec1_UpdateObjectGraphics                                     ;; 00:0587 $21 $c1 $5e
    call call_00_0edd_CallAltBankFunc                                  ;; 00:058a $cd $dd $0e
    ld   A, $01                                        ;; 00:058d $3e $01
    ld   [wDD6A], A                                    ;; 00:058f $ea $6a $dd
    jp   call_00_0b92_UpdateVRAMTiles                                  ;; 00:0592 $c3 $92 $0b

call_00_0595:
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:0595 $21 $1e $dc
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
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 00:0606 $fa $01 $d8
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
    ld   HL, entry_02_54f9                                     ;; 00:061d $21 $f9 $54
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
    ld   HL, entry_02_54f9                                     ;; 00:06b3 $21 $f9 $54
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
    ld   HL, entry_02_54f9                             ;; 00:06d3 $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:06d6 $cd $dd $0e
    ret                                                ;; 00:06d9 $c9

jp_00_06da:
    ld   A, $1b                                        ;; 00:06da $3e $1b
    ld   [wDAD6_ReturnBank], A                                    ;; 00:06dc $ea $d6 $da
    ld   A, $02                                        ;; 00:06df $3e $02
    ld   HL, entry_02_54f9                              ;; 00:06e1 $21 $f9 $54
    call call_00_0edd_CallAltBankFunc                                  ;; 00:06e4 $cd $dd $0e
    ret                                                ;; 00:06e7 $c9

jp_00_06e8:
    ld   A, $13                                        ;; 00:06e8 $3e $13
    ld   [wDAD6_ReturnBank], A                                    ;; 00:06ea $ea $d6 $da
    ld   A, $02                                        ;; 00:06ed $3e $02
    ld   HL, entry_02_54f9                                     ;; 00:06ef $21 $f9 $54
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
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:073e $21 $1e $dc
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

call_00_075f_SwitchBankAndCopyBCBytesFromHLToDE:
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
    ld   HL, entry_03_59b6                                     ;; 00:0962 $21 $b6 $59
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
    ld   HL, entry_03_59b6                                     ;; 00:09ad $21 $b6 $59
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
    call call_00_0f25_AltSwitchBank                                  ;; 00:0b68 $cd $25 $0f
    call call_04_4009                                  ;; 00:0b6b $cd $09 $40
    ld   A, [wDAD5]                                    ;; 00:0b6e $fa $d5 $da
    call call_00_0f25_AltSwitchBank                                  ;; 00:0b71 $cd $25 $0f
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
    call call_00_0f25_AltSwitchBank                                  ;; 00:0ba1 $cd $25 $0f
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
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:0c84 $fa $bf $da
    call call_00_0f25_AltSwitchBank                                  ;; 00:0c87 $cd $25 $0f
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
    call call_00_0f25_AltSwitchBank                                  ;; 00:0cb4 $cd $25 $0f
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
    call call_00_0f25_AltSwitchBank                                  ;; 00:0d17 $cd $25 $0f
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
    call call_00_0f25_AltSwitchBank                                  ;; 00:0e0a $cd $25 $0f
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
    ld   HL, entry_02_7123                                     ;; 00:0e59 $21 $23 $71
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

call_00_0f25_AltSwitchBank:
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

INCLUDE "bank00_load_maps.asm"

call_00_1bbc:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:1bbc $fa $1e $dc
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
    ld   DE, .data_00_1c33                                     ;; 00:1bd5 $11 $33 $1c
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
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:1bea $fa $10 $d8
    sub  A, [HL]                                       ;; 00:1bed $96
    ld   B, A                                          ;; 00:1bee $47
    inc  HL                                            ;; 00:1bef $23
    ld   A, [wD811_PlayerYPosition]                                    ;; 00:1bf0 $fa $11 $d8
    sbc  A, [HL]                                       ;; 00:1bf3 $9e
    inc  HL                                            ;; 00:1bf4 $23
    or   A, B                                          ;; 00:1bf5 $b0
    jr   NZ, .jr_00_1c10                               ;; 00:1bf6 $20 $18
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:1bf8 $fa $0e $d8
    sub  A, E                                          ;; 00:1bfb $93
    ld   E, A                                          ;; 00:1bfc $5f
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:1bfd $fa $0f $d8
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
.data_00_1c33:
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
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:1ea0 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1ea3 $6e
    ld   H, $00                                        ;; 00:1ea4 $26 $00
    add  HL, HL                                        ;; 00:1ea6 $29
    add  HL, HL                                        ;; 00:1ea7 $29
    ld   DE, .data_00_1fc0                                     ;; 00:1ea8 $11 $c0 $1f
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
    ld   DE, .data_00_1ff0                                     ;; 00:1ebb $11 $f0 $1f
    add  HL, DE                                        ;; 00:1ebe $19
    ld   E, [HL]                                       ;; 00:1ebf $5e
    inc  HL                                            ;; 00:1ec0 $23
    ld   D, [HL]                                       ;; 00:1ec1 $56
    ld   A, [wDB6C_CurrentLevelId]                                    ;; 00:1ec2 $fa $6c $db
    push AF                                            ;; 00:1ec5 $f5
    ld   A, [DE]                                       ;; 00:1ec6 $1a
    ld   [wDB6C_CurrentLevelId], A                                    ;; 00:1ec7 $ea $6c $db
    inc  DE                                            ;; 00:1eca $13
    ld   HL, wD80E_PlayerXPosition                                     ;; 00:1ecb $21 $0e $d8
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
    ld   HL, entry_03_6c89_CopyLevelData                              ;; 00:1ef2 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1ef5 $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1ef8 $ea $d6 $da
    ld   A, $03                                        ;; 00:1efb $3e $03
    ld   HL, entry_03_6203                                     ;; 00:1efd $21 $03 $62
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1f00 $cd $dd $0e
    call call_00_10de                                  ;; 00:1f03 $cd $de $10
    call call_00_1056_LoadMap                                  ;; 00:1f06 $cd $56 $10
    ld   [wDAD6_ReturnBank], A                                    ;; 00:1f09 $ea $d6 $da
    ld   A, $02                                        ;; 00:1f0c $3e $02
    ld   HL, entry_02_708f                                     ;; 00:1f0e $21 $8f $70
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
    ld   HL, wD811_PlayerYPosition                                     ;; 00:1fa4 $21 $11 $d8
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
    ld   HL, entry_03_6c89_CopyLevelData                              ;; 00:1fb9 $21 $89 $6c
    call call_00_0edd_CallAltBankFunc                                  ;; 00:1fbc $cd $dd $0e
    ret                                                ;; 00:1fbf $c9
.data_00_1fc0:
    db   $ff, $ff, $ff, $ff, $00, $01, $02, $ff        ;; 00:1fc0 ...?www?
    db   $03, $04, $05, $ff, $06, $07, $08, $ff        ;; 00:1fc8 ????????
    db   $09, $0a, $0b, $ff, $0c, $0d, $0e, $ff        ;; 00:1fd0 ????????
    db   $0f, $10, $11, $ff, $ff, $ff, $ff, $ff        ;; 00:1fd8 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1fe0 ????????
    db   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff        ;; 00:1fe8 ????????
.data_00_1ff0:
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
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21a7 $fa $0e $d8
    add  A, C                                          ;; 00:21aa $81
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21ab $ea $0e $d8
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:21ae $fa $0f $d8
    adc  A, $00                                        ;; 00:21b1 $ce $00
    ld   [wD80F_PlayerXPosition], A                                    ;; 00:21b3 $ea $0f $d8
.jr_00_21b6:
    bit  5, [HL]                                       ;; 00:21b6 $cb $6e
    jr   Z, .jr_00_21c9                                ;; 00:21b8 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21ba $fa $0e $d8
    sub  A, C                                          ;; 00:21bd $91
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21be $ea $0e $d8
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:21c1 $fa $0f $d8
    sbc  A, $00                                        ;; 00:21c4 $de $00
    ld   [wD80F_PlayerXPosition], A                                    ;; 00:21c6 $ea $0f $d8
.jr_00_21c9:
    bit  7, [HL]                                       ;; 00:21c9 $cb $7e
    jr   Z, .jr_00_21dc                                ;; 00:21cb $28 $0f
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21cd $fa $10 $d8
    add  A, C                                          ;; 00:21d0 $81
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21d1 $ea $10 $d8
    ld   A, [wD811_PlayerYPosition]                                    ;; 00:21d4 $fa $11 $d8
    adc  A, $00                                        ;; 00:21d7 $ce $00
    ld   [wD811_PlayerYPosition], A                                    ;; 00:21d9 $ea $11 $d8
.jr_00_21dc:
    bit  6, [HL]                                       ;; 00:21dc $cb $76
    ret  Z                                             ;; 00:21de $c8
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21df $fa $10 $d8
    sub  A, C                                          ;; 00:21e2 $91
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21e3 $ea $10 $d8
    ld   A, [wD811_PlayerYPosition]                                    ;; 00:21e6 $fa $11 $d8
    sbc  A, $00                                        ;; 00:21e9 $de $00
    ld   [wD811_PlayerYPosition], A                                    ;; 00:21eb $ea $11 $d8
    ret                                                ;; 00:21ee $c9

INCLUDE "bank00_load_objects.asm"
