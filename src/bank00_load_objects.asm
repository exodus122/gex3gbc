call_00_21ef:
    push BC                                            ;; 00:21ef $c5
    ld   A, $1e                                        ;; 00:21f0 $3e $1e
    call call_00_0ff5                                  ;; 00:21f2 $cd $f5 $0f
    pop  BC                                            ;; 00:21f5 $c1

call_00_21f6_FindAndMarkObjectInList:
; Switches to the bank containing the object list (wDC16_ObjectListBank).
; Reads the start of the object list (wDC17_ObjectListBankOffset).
; Iterates through 16-byte object records, searching for objects of type $11 
; whose parameter matches C.
; When found, it updates a D7xx structure at index B:
; Sets a nibble/flag ([DE] = ([DE] & $F0) | value).
; Uses a small table (db $00,$01,$02,$04 at $225C) and level mask (wDC1E_CurrentLevelNumber) 
; to decide which flag (1 or 2) to apply.
; Exits by restoring the previous bank. 
; Usage:
; Marks specific objects (e.g., collectibles, triggers, or doors) as “active” or “visited” 
; for the current level. This is typical of collectible or progression flags.
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
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:223c $21 $1e $dc
    ld   L, [HL]                                       ;; 00:223f $6e
    ld   H, $00                                        ;; 00:2240 $26 $00
    ld   BC, wDC5C                                     ;; 00:2242 $01 $5c $dc
    add  HL, BC                                        ;; 00:2245 $09
    pop  AF                                            ;; 00:2246 $f1
    ld   C, $01                                        ;; 00:2247 $0e $01
    and  A, [HL]                                       ;; 00:2249 $a6
    jr   Z, .jr_00_2254                                ;; 00:224a $28 $08
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:224c $fa $1e $dc
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

INCLUDE "bank00_object_utils.asm"

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

call_00_2ce2_BuildGexSpriteDrawList:
; This is a complex sprite/OAM population routine. It:
; Sets wDAC2=1 and combines the player’s facing direction with a state byte (wDC7A) into wDC53.
; Switches banks to retrieve sprite graphics metadata based on the current level (wDB6C_CurrentLevelId).
; Computes the address of Gex’s sprite frame data (using offsets and increments).
; Reads sprite tiles, positions, and attributes, adjusting for the player’s position 
; relative to the map (wDBF9, wDBFB, wD80E, wD810).
; Handles flipped and mirrored variants depending on direction bits (bits 5 and 6 in wDC53).
; Writes formatted sprite entries (X, Y, tile index, attributes) into a buffer at D9xx.
; Optionally writes extra entries if a certain flag (wDC51) is set, using offsets from data_00_2f14.
; Updates wDC6F with the new buffer pointer and restores the previous ROM bank.
; Usage:
; Populates the hardware sprite list for Gex’s current animation frame, handling mirroring, flipping, 
; and level-specific offsets.
    ld   A, $01                                        ;; 00:2ce2 $3e $01
    ld   [wDAC2], A                                    ;; 00:2ce4 $ea $c2 $da
    ld   A, [wD80D_PlayerFacingDirection]                                    ;; 00:2ce7 $fa $0d $d8
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
    ld   [wDABF_GexSpriteBank], A                                    ;; 00:2d06 $ea $bf $da
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
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:2d1b $fa $bf $da
    add  A, C                                          ;; 00:2d1e $81
    ld   [wDABF_GexSpriteBank], A                                    ;; 00:2d1f $ea $bf $da
    call call_00_0f08_SwitchBank2                                  ;; 00:2d22 $cd $08 $0f
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:2d25 $fa $bf $da
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
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2d55 $fa $0e $d8
    sub  A, C                                          ;; 00:2d58 $91
    add  A, $08                                        ;; 00:2d59 $c6 $08
    ld   [wDC90], A                                    ;; 00:2d5b $ea $90 $dc
    ld   C, A                                          ;; 00:2d5e $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2d5f $fa $fb $db
    ld   B, A                                          ;; 00:2d62 $47
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:2d63 $fa $10 $d8
    sub  A, B                                          ;; 00:2d66 $90
    add  A, $10                                        ;; 00:2d67 $c6 $10
    ld   [wDC91], A                                    ;; 00:2d69 $ea $91 $dc
    add  A, $10                                        ;; 00:2d6c $c6 $10
    ld   B, A                                          ;; 00:2d6e $47
    ld   A, [wDC88]                                    ;; 00:2d6f $fa $88 $dc
    add  A, B                                          ;; 00:2d72 $80
    ld   B, A                                          ;; 00:2d73 $47
    call call_00_2f00_CallBank2_Helper_AndCheckBit8                                  ;; 00:2d74 $cd $00 $2f
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
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2db0 $fa $0e $d8
    sub  A, C                                          ;; 00:2db3 $91
    add  A, $08                                        ;; 00:2db4 $c6 $08
    ld   [wDC90], A                                    ;; 00:2db6 $ea $90 $dc
    ld   C, A                                          ;; 00:2db9 $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2dba $fa $fb $db
    ld   B, A                                          ;; 00:2dbd $47
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:2dbe $fa $10 $d8
    sub  A, B                                          ;; 00:2dc1 $90
    add  A, $10                                        ;; 00:2dc2 $c6 $10
    ld   [wDC91], A                                    ;; 00:2dc4 $ea $91 $dc
    add  A, $10                                        ;; 00:2dc7 $c6 $10
    ld   B, A                                          ;; 00:2dc9 $47
    ld   A, [wDC88]                                    ;; 00:2dca $fa $88 $dc
    add  A, B                                          ;; 00:2dcd $80
    ld   B, A                                          ;; 00:2dce $47
    call call_00_2f00_CallBank2_Helper_AndCheckBit8                                  ;; 00:2dcf $cd $00 $2f
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
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2e14 $fa $0e $d8
    sub  A, C                                          ;; 00:2e17 $91
    add  A, $08                                        ;; 00:2e18 $c6 $08
    ld   [wDC90], A                                    ;; 00:2e1a $ea $90 $dc
    ld   C, A                                          ;; 00:2e1d $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2e1e $fa $fb $db
    ld   B, A                                          ;; 00:2e21 $47
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:2e22 $fa $10 $d8
    sub  A, B                                          ;; 00:2e25 $90
    add  A, $10                                        ;; 00:2e26 $c6 $10
    ld   [wDC91], A                                    ;; 00:2e28 $ea $91 $dc
    add  A, $10                                        ;; 00:2e2b $c6 $10
    ld   B, A                                          ;; 00:2e2d $47
    ld   A, [wDC88]                                    ;; 00:2e2e $fa $88 $dc
    add  A, B                                          ;; 00:2e31 $80
    ld   B, A                                          ;; 00:2e32 $47
    call call_00_2f00_CallBank2_Helper_AndCheckBit8                                  ;; 00:2e33 $cd $00 $2f
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
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2e73 $fa $0e $d8
    sub  A, C                                          ;; 00:2e76 $91
    add  A, $08                                        ;; 00:2e77 $c6 $08
    ld   [wDC90], A                                    ;; 00:2e79 $ea $90 $dc
    ld   C, A                                          ;; 00:2e7c $4f
    ld   A, [wDBFB_YPositionInMap]                                    ;; 00:2e7d $fa $fb $db
    ld   B, A                                          ;; 00:2e80 $47
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:2e81 $fa $10 $d8
    sub  A, B                                          ;; 00:2e84 $90
    add  A, $10                                        ;; 00:2e85 $c6 $10
    ld   [wDC91], A                                    ;; 00:2e87 $ea $91 $dc
    add  A, $10                                        ;; 00:2e8a $c6 $10
    ld   B, A                                          ;; 00:2e8c $47
    ld   A, [wDC88]                                    ;; 00:2e8d $fa $88 $dc
    add  A, B                                          ;; 00:2e90 $80
    ld   B, A                                          ;; 00:2e91 $47
    call call_00_2f00_CallBank2_Helper_AndCheckBit8                                  ;; 00:2e92 $cd $00 $2f
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
    ld   BC, data_00_2f14                                     ;; 00:2ede $01 $14 $2f
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

call_00_2f00_CallBank2_Helper_AndCheckBit8:
; Switch to Bank 2 and Run Entry
; Behavior: Saves registers, stores current bank (wDAD6_ReturnBank), switches to bank $02, 
; and calls entry_02_5541 using the alternate-bank call routine. Restores registers, masks result with $08, and returns.
; Purpose: Executes a helper routine from bank 2 and checks a specific status bit.
    push HL                                            ;; 00:2f00 $e5
    push DE                                            ;; 00:2f01 $d5
    push BC                                            ;; 00:2f02 $c5
    ld   [wDAD6_ReturnBank], A                                    ;; 00:2f03 $ea $d6 $da
    ld   A, $02                                        ;; 00:2f06 $3e $02
    ld   HL, entry_02_5541                                     ;; 00:2f08 $21 $41 $55
    call call_00_0edd_CallAltBankFunc                                  ;; 00:2f0b $cd $dd $0e
    pop  BC                                            ;; 00:2f0e $c1
    pop  DE                                            ;; 00:2f0f $d1
    pop  HL                                            ;; 00:2f10 $e1
    and  A, $08                                        ;; 00:2f11 $e6 $08
    ret                                                ;; 00:2f13 $c9

data_00_2f14:
    db   $00, $fe, $fe, $fc, $fc, $fe, $fc, $00        ;; 00:2f14 ????????
    db   $fa, $02, $fc, $04, $fe, $02, $00, $04        ;; 00:2f1c ????????
    db   $00, $02, $fe, $00, $fe, $fe, $fc, $fc        ;; 00:2f24 ????????
    db   $fa, $fa, $fc, $f8, $fe, $fa, $00, $fc        ;; 00:2f2c ????????

call_00_2f34_CountActiveCollectibles:
; Count Enabled Collectibles
; Behavior: Switches to the collectible list bank, iterates through the list (step $0003), 
; counts active entries (!= 0), switches back and iterates object list comparing IDs against data_00_325F. 
; Increments counter C for each collectible meeting bit-6 set criteria.
; Purpose: Counts collectible items present for the current map.
    ld   a,[wDC19_CollectibleListBank]
    call call_00_0eee_SwitchBank
    ld   hl,wDC1A_CollectibleListBankOffset
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    inc  hl
    ld   de,$0003
    ld   c,$FF
label2F46:
    ld   a,[hl]
    add  hl,de
    inc  c
    and  a
    jr   nz,label2F46
    push bc
    call call_00_0f08_SwitchBank2
    ld   a,[wDC16_ObjectListBank]
    call call_00_0eee_SwitchBank
    ld   hl,wDC17_ObjectListBankOffset
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    pop  bc
label2F5D:
    ld   a,[hl]
    cp   a,$FF
    jr   z,label2F7E
    push hl
    ld   l,a
    ld   h,$00
    add  hl,hl
    add  hl,hl
    add  hl,hl
    ld   de,data_00_325F
    add  hl,de
    ld   a,[hl]
    cp   a,$FF
    jr   z,label2F77
    bit  6,a
    jr   z,label2F77
    inc  c
label2F77:
    pop  hl
    ld   de,$0010
    add  hl,de
    jr   label2F5D
label2F7E:
    ld   a,c
    push af
    call call_00_0f08_SwitchBank2
    pop  af
    ret  

call_00_2f85_LoadAndSortCollectibleData:
; Behavior: Clears collectible state tables (wD100–wD2FF), loads entries from the 
; collectible list bank into working memory, sorts/organizes them (wD200, wD300), 
; then returns to original bank.
; Purpose: Initializes and sorts collectible positions for the current level.
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

call_00_2ff8_InitLevelObjectsAndConfig:
; Initialize Level State
; Behavior: Switches to the object list bank, resets wDAB8 counter, clears a large block 
; of level state variables (wDCC5–wDCDA), copies level-specific configuration tables 
; (.data_00_30ba and .data_00_317a) into RAM, sets default timers (wDCD5–wDCD9), adjusts 
; special-case values for level 07/08, and calls setup routines 3180, 31d9, 320d, and 3252.
; Purpose: Sets up all object, collectible, and configuration state for a new level.
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:2ff8 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2ffb $cd $ee $0e
    call call_00_3252_ResetObjectCounter                                  ;; 00:2ffe $cd $52 $32
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
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:3052 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:3055 $6e
    ld   H, $00                                        ;; 00:3056 $26 $00
    add  HL, HL                                        ;; 00:3058 $29
    add  HL, HL                                        ;; 00:3059 $29
    add  HL, HL                                        ;; 00:305a $29
    add  HL, HL                                        ;; 00:305b $29
    ld   DE, .data_00_30ba                                     ;; 00:305c $11 $ba $30
    add  HL, DE                                        ;; 00:305f $19
    ld   DE, wDCB1                                     ;; 00:3060 $11 $b1 $dc
    ld   BC, $10                                       ;; 00:3063 $01 $10 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:3066 $cd $6e $07
    ld   HL, .data_00_317a                                     ;; 00:3069 $21 $7a $31
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
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:308b $fa $1e $dc
    cp   A, $07                                        ;; 00:308e $fe $07
    jr   Z, .jr_00_3096                                ;; 00:3090 $28 $04
    cp   A, $08                                        ;; 00:3092 $fe $08
    jr   NZ, .jr_00_30ab                               ;; 00:3094 $20 $15
.jr_00_3096:
    ld   [HL], $01                                     ;; 00:3096 $36 $01
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:3098 $fa $1e $dc
    cp   A, $07                                        ;; 00:309b $fe $07
    ld   A, $3c                                        ;; 00:309d $3e $3c
    jr   Z, .jr_00_30a3                                ;; 00:309f $28 $02
    ld   A, $69                                        ;; 00:30a1 $3e $69
.jr_00_30a3:
    ld   [wDB6E], A                                    ;; 00:30a3 $ea $6e $db
    ld   A, $3c                                        ;; 00:30a6 $3e $3c
    ld   [wDB6F], A                                    ;; 00:30a8 $ea $6f $db
.jr_00_30ab:
    call call_00_3180_MarkInitialLevelObjects                                  ;; 00:30ab $cd $80 $31
    call call_00_31d9_CheckFlag4_ResetObjectType1                                  ;; 00:30ae $cd $d9 $31
    call call_00_320d_ApplyLevelMaskToType3Objects                                  ;; 00:30b1 $cd $0d $32
    call call_00_3252_ResetObjectCounter                                  ;; 00:30b4 $cd $52 $32
    jp   call_00_0f08_SwitchBank2                                  ;; 00:30b7 $c3 $08 $0f
.data_00_30ba:
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
.data_00_317a:
    db   $98, $02, $58, $01, $d8, $01                  ;; 00:317a ......

call_00_3180_MarkInitialLevelObjects:
; Mark Starting Objects for Level
; Behavior: If level number ≠ 0, looks up a bitmask table ($31C1+level) and, 
; for each bit set, calls FindAndMarkObjectInList. For level 0, performs a banked 
; call comparison loop using entry_01_4ab9 and thresholds in $31CD.
; Purpose: Ensures certain objects are flagged or activated when the level begins.
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:3180 $fa $1e $dc
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
    call NZ, call_00_21f6_FindAndMarkObjectInList                              ;; 00:3193 $c4 $f6 $21
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
    ld   HL, entry_01_4ab9                                     ;; 00:31aa $21 $b9 $4a
    call call_00_0edd_CallAltBankFunc                                  ;; 00:31ad $cd $dd $0e
    pop  BC                                            ;; 00:31b0 $c1
    ld   HL, $31cd                                     ;; 00:31b1 $21 $cd $31
    add  HL, BC                                        ;; 00:31b4 $09
    cp   A, [HL]                                       ;; 00:31b5 $be
    call NC, call_00_21f6_FindAndMarkObjectInList                              ;; 00:31b6 $d4 $f6 $21
    pop  BC                                            ;; 00:31b9 $c1
    inc  C                                             ;; 00:31ba $0c
    ld   A, C                                          ;; 00:31bb $79
    cp   A, $0c                                        ;; 00:31bc $fe $0c
    jr   C, .jr_00_31a3                                ;; 00:31be $38 $e3
    ret                                                ;; 00:31c0 $c9
    db   $00, $00, $01, $04, $05, $00, $00, $00        ;; 00:31c1 ?.??????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:31c9 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 00:31d1 ????????

call_00_31d9_CheckFlag4_ResetObjectType1:
; Handle Level Flag 4 Special Object
; Behavior: Uses level number + wDC5C as a flag table, checks bit-4; if set, 
; searches object list for type 01 and clears a RAM byte (wD7??) to zero.
; Purpose: Disables or resets a specific object type when a special flag is set.
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:31d9 $21 $1e $dc
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

call_00_320d_ApplyLevelMaskToType3Objects:
; Mask Object Flags by Level Setting
; Behavior: Gets a bitmask (C) from wDC5C + level, scans the object list for type 03. 
; For each, uses its 13th byte as an index into $324E (00,20,40,80), ANDs with C; if nonzero, 
; clears the corresponding entry in RAM (wD7xx).
; Purpose: Applies level-specific masking to object type 3 spawns.
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:320d $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:3210 $cd $ee $0e
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:3213 $21 $1e $dc
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

call_00_3252_ResetObjectCounter:
; Reset Object Counter
; Behavior: Simply sets wDAB8 = 1 and returns.
; Purpose: Initializes the object counter used by other routines.
    ld   A, $01                                        ;; 00:3252 $3e $01
    ld   [wDAB8], A                                    ;; 00:3254 $ea $b8 $da
    ret                                                ;; 00:3257 $c9

data_00_3258:
    db   $00, $00, $00, $00, $00, $00, $00
data_00_325F:    
    db   $ff        ;; 00:3258 ????????
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

call_00_35e8_GetObjectTypeIndex:
; Follows a chain of lookups based on the current object address (wDA00_CurrentObjectAddr) to compute an index into data_00_325F.
; Shifts HL left three times (×8), adds the table base, and returns the byte at that location.
; Usage: Fetches an object-type ID or pointer index for the active object.
    ld   HL, wDA00_CurrentObjectAddr                                     ;; 00:35e8 $21 $00 $da
    ld   L, [HL]                                       ;; 00:35eb $6e
    ld   H, $d8                                        ;; 00:35ec $26 $d8
    ld   L, [HL]                                       ;; 00:35ee $6e
    ld   H, $00                                        ;; 00:35ef $26 $00
    add  HL, HL                                        ;; 00:35f1 $29
    add  HL, HL                                        ;; 00:35f2 $29
    add  HL, HL                                        ;; 00:35f3 $29
    ld   DE, data_00_325F                                     ;; 00:35f4 $11 $5f $32
    add  HL, DE                                        ;; 00:35f7 $19
    ld   A, [HL]                                       ;; 00:35f8 $7e
    ret                                                ;; 00:35f9 $c9

call_00_35fa_WaitForLineThenSpawnObject:
; Switches to the current object list bank, then repeatedly calls 
; call_00_3618_HandleObjectSpawn until the LCD Y-register (rLY) is ≥ $80.
; Once the scanline threshold is reached, switches back to the previous bank.
; Usage: Synchronizes spawning/updating objects with the LCD scanline timing to avoid VRAM conflicts.
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:35fa $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:35fd $cd $ee $0e
.jr_00_3600:
    call call_00_3618_HandleObjectSpawn                                  ;; 00:3600 $cd $18 $36
    ldh  A, [rLY]                                      ;; 00:3603 $f0 $44
    cp   A, $80                                        ;; 00:3605 $fe $80
    jr   C, .jr_00_3600                                ;; 00:3607 $38 $f7
    jp   call_00_0f08_SwitchBank2                                  ;; 00:3609 $c3 $08 $0f

call_00_360c_SpawnObjectOnceImmediate:
; Similar to 35FA but calls 3618 once without waiting for the scanline, then switches banks back.
; Usage: Quickly spawns or processes one object entry without frame timing checks.
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:360c $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:360f $cd $ee $0e
    call call_00_3618_HandleObjectSpawn                                  ;; 00:3612 $cd $18 $36
    jp   call_00_0f08_SwitchBank2                                  ;; 00:3615 $c3 $08 $0f

call_00_3618_HandleObjectSpawn:
; Finds a free object slot.
; If none free, resets the object counter (3252).
; If a slot is found:
; Calculates an offset into the object spawn table using wDAB8 and the bank offset.
; Checks for $FF sentinel and level ID match.
; Performs collision-distance checks against player position (wDA14–wDA1B).
; If within range, copies multiple fields from the spawn table into working object memory (wDA24, wDA1C, etc.).
; Sets up animation/state data, calls alt-bank functions to finish initialization.
; Usage: Core routine that validates and copies object-spawn data into live object RAM.
    call call_00_2afc_FindFreeObjectSlot                                  ;; 00:3618 $cd $fc $2a
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
    jp   Z, call_00_3252_ResetObjectCounter                               ;; 00:3639 $ca $52 $32
    ld   HL, wDAB8                                     ;; 00:363c $21 $b8 $da
    inc  [HL]                                          ;; 00:363f $34
    ret                                                ;; 00:3640 $c9
.jr_00_3641:
    ld   [wDA00_CurrentObjectAddr], A                                    ;; 00:3641 $ea $00 $da
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
    jp   Z, call_00_3252_ResetObjectCounter                               ;; 00:3666 $ca $52 $32
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
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:36dc $fa $00 $da
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
    ld   BC, data_00_3258                                     ;; 00:3723 $01 $58 $32
    add  HL, BC                                        ;; 00:3726 $09
    ld   A, [HL+]                                      ;; 00:3727 $2a
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:3728 $fa $00 $da
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
    ld   HL, entry_02_72ac                                     ;; 00:3780 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:3783 $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:3786 $ea $d6 $da
    ld   A, $03                                        ;; 00:3789 $3e $03
    ld   HL, entry_03_687c                                     ;; 00:378b $21 $7c $68
    call call_00_0edd_CallAltBankFunc                                  ;; 00:378e $cd $dd $0e
    ret                                                ;; 00:3791 $c9

call_00_3792_PrepareRelativeObjectSpawn:
; Switches to the object list bank, then calls 37A0 with BC preserved.
; After execution, restores bank.
; Usage: Prepares to spawn an object relative to another object or dynamic offset.
    push BC                                            ;; 00:3792 $c5
    ld   A, [wDC16_ObjectListBank]                                    ;; 00:3793 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:3796 $cd $ee $0e
    pop  BC                                            ;; 00:3799 $c1
    call call_00_37a0_SpawnObjectRelative                                  ;; 00:379a $cd $a0 $37
    jp   call_00_0f08_SwitchBank2                                  ;; 00:379d $c3 $08 $0f

call_00_37a0_SpawnObjectRelative:
; Finds a free slot.
; Calls a banked routine (entry_03_59c6) to fetch spawn data.
; Derives offsets using the current object address.
; Reads a table (.data_00_38b6) and copies positional deltas.
; Depending on a flag in wDCE9, adds or subtracts position offsets.
; Writes adjusted coordinates and state values into live object memory.
; Calls 2a03_ResetObjectTempSlot and finalizes setup with banked calls.
; Usage: Spawns a new object at a position relative to the parent object, 
; handling direction and mirroring.
    call call_00_2afc_FindFreeObjectSlot                                  ;; 00:37a0 $cd $fc $2a
    ret  Z                                             ;; 00:37a3 $c8
    push DE                                            ;; 00:37a4 $d5
    ld   [wDAD6_ReturnBank], A                                    ;; 00:37a5 $ea $d6 $da
    ld   A, $03                                        ;; 00:37a8 $3e $03
    ld   HL, entry_03_59c6                                     ;; 00:37aa $21 $c6 $59
    call call_00_0edd_CallAltBankFunc                                  ;; 00:37ad $cd $dd $0e
    ld   [wDCE9], A                                    ;; 00:37b0 $ea $e9 $dc
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:37b3 $fa $00 $da
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
    ld   BC, .data_00_38b6                                     ;; 00:37cd $01 $b6 $38
    add  HL, BC                                        ;; 00:37d0 $09
    ld   A, [HL+]                                      ;; 00:37d1 $2a
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:37d2 $fa $00 $da
    push AF                                            ;; 00:37d5 $f5
    or   A, $0d                                        ;; 00:37d6 $f6 $0d
    ld   C, A                                          ;; 00:37d8 $4f
    ld   B, $d8                                        ;; 00:37d9 $06 $d8
    ld   A, D                                          ;; 00:37db $7a
    ld   [wDA00_CurrentObjectAddr], A                                    ;; 00:37dc $ea $00 $da
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
    call call_00_2a03_ResetObjectTempSlot                                  ;; 00:384f $cd $03 $2a
    xor  A, A                                          ;; 00:3852 $af
    ld   [wDAD6_ReturnBank], A                                    ;; 00:3853 $ea $d6 $da
    ld   A, $02                                        ;; 00:3856 $3e $02
    ld   HL, entry_02_72ac                                     ;; 00:3858 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:385b $cd $dd $0e
    ld   [wDAD6_ReturnBank], A                                    ;; 00:385e $ea $d6 $da
    ld   A, $03                                        ;; 00:3861 $3e $03
    ld   HL, entry_03_687c                                     ;; 00:3863 $21 $7c $68
    call call_00_0edd_CallAltBankFunc                                  ;; 00:3866 $cd $dd $0e
    pop  AF                                            ;; 00:3869 $f1
    ld   HL, wDA00_CurrentObjectAddr                                     ;; 00:386a $21 $00 $da
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
.data_00_38b6:
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
