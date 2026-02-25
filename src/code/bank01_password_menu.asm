call_01_4f7e_SeedTileLookupTable:
; Description:
; Initializes wDB7E_PasswordValues with $20 and copies it forward 17 bytes, 
; clearing or seeding a lookup table used by map computations.
    ld   HL, wDB7E_PasswordValues                                     ;; 01:4f7e $21 $7e $db
    ld   DE, wDB7E_PasswordValues+1                                     ;; 01:4f81 $11 $7f $db
    ld   BC, $11                                       ;; 01:4f84 $01 $11 $00
    ld   [HL], $20                                     ;; 01:4f87 $36 $20
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4f89 $c3 $6e $07

call_01_4f8c_BuildPasswordBitfieldAndChecksum:
; Description:
; Clears wDB72_PasswordEncodedBuffer–wDB7D, seeds wDB73_PasswordLivesRemaining–wDB75_PasswordPawCoinExtraHealth from wDC4E_LivesRemaining/AF/4F, then iterates through DC5C/DC5D data, 
; checking bit masks (.data_01_5013 and .data_01_501f) to build bitfields in wDB76_PasswordEncodedBuffer+. 
; Sums values for a checksum in wDB72_PasswordEncodedBuffer and sets a completion flag wDB91_PasswordCompletionFlag.
    ld   HL, wDB72_PasswordEncodedBuffer                                     ;; 01:4f8c $21 $72 $db
    ld   B, $0c                                        ;; 01:4f8f $06 $0c
    xor  A, A                                          ;; 01:4f91 $af
.jr_01_4f92:
    ld   [HL+], A                                      ;; 01:4f92 $22
    dec  B                                             ;; 01:4f93 $05
    jr   NZ, .jr_01_4f92                               ;; 01:4f94 $20 $fc
    xor  A, A                                          ;; 01:4f96 $af
    ld   [wDB72_PasswordEncodedBuffer], A                                    ;; 01:4f97 $ea $72 $db
    ld   A, [wDC4E_LivesRemaining]                                    ;; 01:4f9a $fa $4e $dc
    ld   [wDB73_PasswordLivesRemaining], A                                    ;; 01:4f9d $ea $73 $db
    ld   A, [wDCAF_PawCoinCounter]                                    ;; 01:4fa0 $fa $af $dc
    ld   [wDB74_PasswordPawCoinCounter], A                                    ;; 01:4fa3 $ea $74 $db
    ld   A, [wDC4F_PawCoinExtraHealth]                                    ;; 01:4fa6 $fa $4f $dc
    ld   [wDB75_PasswordPawCoinExtraHealth], A                                    ;; 01:4fa9 $ea $75 $db
    xor  A, A                                          ;; 01:4fac $af
    ld   [wDB90_PasswordCounter], A                                    ;; 01:4fad $ea $90 $db
    ld   DE, $00                                       ;; 01:4fb0 $11 $00 $00
.jr_01_4fb3:
    push DE                                            ;; 01:4fb3 $d5
    ld   HL, wDC5C_ProgressFlags                                     ;; 01:4fb4 $21 $5c $dc
    add  HL, DE                                        ;; 01:4fb7 $19
    ld   C, [HL]                                       ;; 01:4fb8 $4e
    ld   HL, .data_01_5013                             ;; 01:4fb9 $21 $13 $50
    add  HL, DE                                        ;; 01:4fbc $19
    ld   B, [HL]                                       ;; 01:4fbd $46
    ld   A, $08                                        ;; 01:4fbe $3e $08
.jr_01_4fc0:
    push AF                                            ;; 01:4fc0 $f5
    bit  7, B                                          ;; 01:4fc1 $cb $78
    jr   Z, .jr_01_4fee                                ;; 01:4fc3 $28 $29
    bit  7, C                                          ;; 01:4fc5 $cb $79
    jr   Z, .jr_01_4fea                                ;; 01:4fc7 $28 $21
    ld   A, [wDB90_PasswordCounter]                                    ;; 01:4fc9 $fa $90 $db
    srl  A                                             ;; 01:4fcc $cb $3f
    srl  A                                             ;; 01:4fce $cb $3f
    srl  A                                             ;; 01:4fd0 $cb $3f
    ld   E, A                                          ;; 01:4fd2 $5f
    ld   D, $00                                        ;; 01:4fd3 $16 $00
    ld   HL, wDB76_PasswordEncodedBuffer                                     ;; 01:4fd5 $21 $76 $db
    add  HL, DE                                        ;; 01:4fd8 $19
    push HL                                            ;; 01:4fd9 $e5
    ld   A, [wDB90_PasswordCounter]                                    ;; 01:4fda $fa $90 $db
    and  A, $07                                        ;; 01:4fdd $e6 $07
    ld   E, A                                          ;; 01:4fdf $5f
    ld   D, $00                                        ;; 01:4fe0 $16 $00
    ld   HL, .data_01_501f                             ;; 01:4fe2 $21 $1f $50
    add  HL, DE                                        ;; 01:4fe5 $19
    ld   A, [HL]                                       ;; 01:4fe6 $7e
    pop  HL                                            ;; 01:4fe7 $e1
    or   A, [HL]                                       ;; 01:4fe8 $b6
    ld   [HL], A                                       ;; 01:4fe9 $77
.jr_01_4fea:
    ld   HL, wDB90_PasswordCounter                                     ;; 01:4fea $21 $90 $db
    inc  [HL]                                          ;; 01:4fed $34
.jr_01_4fee:
    sla  C                                             ;; 01:4fee $cb $21
    sla  B                                             ;; 01:4ff0 $cb $20
    pop  AF                                            ;; 01:4ff2 $f1
    dec  A                                             ;; 01:4ff3 $3d
    jr   NZ, .jr_01_4fc0                               ;; 01:4ff4 $20 $ca
    pop  DE                                            ;; 01:4ff6 $d1
    inc  E                                             ;; 01:4ff7 $1c
    ld   A, E                                          ;; 01:4ff8 $7b
    cp   A, $0c                                        ;; 01:4ff9 $fe $0c
    jr   C, .jr_01_4fb3                                ;; 01:4ffb $38 $b6
    ld   HL, wDB73_PasswordLivesRemaining                                     ;; 01:4ffd $21 $73 $db
    ld   B, $0b                                        ;; 01:5000 $06 $0b
    xor  A, A                                          ;; 01:5002 $af
.jr_01_5003:
    add  A, [HL]                                       ;; 01:5003 $86
    inc  HL                                            ;; 01:5004 $23
    dec  B                                             ;; 01:5005 $05
    jr   NZ, .jr_01_5003                               ;; 01:5006 $20 $fb
    xor  A, $b6                                        ;; 01:5008 $ee $b6
    ld   [wDB72_PasswordEncodedBuffer], A                                    ;; 01:500a $ea $72 $db
    ld   A, $01                                        ;; 01:500d $3e $01
    ld   [wDB91_PasswordCompletionFlag], A                                    ;; 01:500f $ea $91 $db
    ret                                                ;; 01:5012 $c9
.data_01_5013:
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01        ;; 01:5013 ........
    db   $01, $01, $01, $01                            ;; 01:501b ....
.data_01_501f:
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 01:501f ??.?.???

call_01_5027_BuildPasswordBufferFromBitfield:
; Description:
; Initializes the buffer at wDB7E_PasswordValues to zeros, then iterates through bits in wDB72_PasswordEncodedBuffer to set flags in the buffer. 
; It scans wDB72_PasswordEncodedBuffer bitfields (masking with $80, $40, etc.) and for each set bit, ORs $10 into the corresponding 
; entry in wDB7E_PasswordValues. Essentially, it maps a bitfield of collision/attribute flags into a tile-flag buffer.
    ld   HL, wDB7E_PasswordValues                                     ;; 01:5027 $21 $7e $db
    ld   DE, wDB7E_PasswordValues+1                                     ;; 01:502a $11 $7f $db
    ld   BC, $11                                       ;; 01:502d $01 $11 $00
    ld   [HL], $00                                     ;; 01:5030 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:5032 $cd $6e $07
    ld   HL, wDB72_PasswordEncodedBuffer                                     ;; 01:5035 $21 $72 $db
    ld   B, $80                                        ;; 01:5038 $06 $80
    ld   DE, wDB7E_PasswordValues                                     ;; 01:503a $11 $7e $db
    ld   C, $10                                        ;; 01:503d $0e $10
    ld   A, $5a                                        ;; 01:503f $3e $5a
.jr_01_5041:
    push AF                                            ;; 01:5041 $f5
    ld   A, [HL]                                       ;; 01:5042 $7e
    and  A, B                                          ;; 01:5043 $a0
    jr   Z, .jr_01_5049                                ;; 01:5044 $28 $03
    ld   A, [DE]                                       ;; 01:5046 $1a
    or   A, C                                          ;; 01:5047 $b1
    ld   [DE], A                                       ;; 01:5048 $12
.jr_01_5049:
    rrc  C                                             ;; 01:5049 $cb $09
    jr   NC, .jr_01_5050                               ;; 01:504b $30 $03
    inc  DE                                            ;; 01:504d $13
    ld   C, $10                                        ;; 01:504e $0e $10
.jr_01_5050:
    rrc  B                                             ;; 01:5050 $cb $08
    jr   NC, .jr_01_5055                               ;; 01:5052 $30 $01
    inc  HL                                            ;; 01:5054 $23
.jr_01_5055:
    pop  AF                                            ;; 01:5055 $f1
    dec  A                                             ;; 01:5056 $3d
    jr   NZ, .jr_01_5041                               ;; 01:5057 $20 $e8
    ret                                                ;; 01:5059 $c9

call_01_505a_ValidatePassword:
; Description:
; Checks wDB7E_PasswordValues for any tile flagged $20. If found early, returns 0. If not found after scanning $12 entries, 
; it resets buffers (wDB72_PasswordEncodedBuffer–wDB7D), then reconstructs bitfields from wDB7E_PasswordValues back into wDB72_PasswordEncodedBuffer. It sums these values, 
; XORs with $B6, and compares to wDB72_PasswordEncodedBuffer as a checksum. On match, it calls call_01_50b5_SetProgressFlagsFromPasswordMasks 
; (which rebuilds DC5C/DC4E tile password data) and returns $20; otherwise, returns 0.
    ld   HL, wDB7E_PasswordValues                                     ;; 01:505a $21 $7e $db
    ld   B, $12                                        ;; 01:505d $06 $12
.jr_01_505f:
    ld   A, [HL+]                                      ;; 01:505f $2a
    cp   A, $20                                        ;; 01:5060 $fe $20
    jr   Z, .jr_01_50b2                                ;; 01:5062 $28 $4e
    dec  B                                             ;; 01:5064 $05
    jr   NZ, .jr_01_505f                               ;; 01:5065 $20 $f8
    ld   HL, wDB72_PasswordEncodedBuffer                                     ;; 01:5067 $21 $72 $db
    ld   DE, wDB73_PasswordLivesRemaining                                     ;; 01:506a $11 $73 $db
    ld   BC, $0b                                       ;; 01:506d $01 $0b $00
    ld   [HL], $00                                     ;; 01:5070 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:5072 $cd $6e $07
    ld   HL, wDB72_PasswordEncodedBuffer                                     ;; 01:5075 $21 $72 $db
    ld   B, $80                                        ;; 01:5078 $06 $80
    ld   DE, wDB7E_PasswordValues                                     ;; 01:507a $11 $7e $db
    ld   C, $10                                        ;; 01:507d $0e $10
    ld   A, $5a                                        ;; 01:507f $3e $5a
.jr_01_5081:
    push AF                                            ;; 01:5081 $f5
    ld   A, [DE]                                       ;; 01:5082 $1a
    and  A, C                                          ;; 01:5083 $a1
    jr   Z, .jr_01_5089                                ;; 01:5084 $28 $03
    ld   A, [HL]                                       ;; 01:5086 $7e
    or   A, B                                          ;; 01:5087 $b0
    ld   [HL], A                                       ;; 01:5088 $77
.jr_01_5089:
    rrc  C                                             ;; 01:5089 $cb $09
    jr   NC, .jr_01_5090                               ;; 01:508b $30 $03
    inc  DE                                            ;; 01:508d $13
    ld   C, $10                                        ;; 01:508e $0e $10
.jr_01_5090:
    rrc  B                                             ;; 01:5090 $cb $08
    jr   NC, .jr_01_5095                               ;; 01:5092 $30 $01
    inc  HL                                            ;; 01:5094 $23
.jr_01_5095:
    pop  AF                                            ;; 01:5095 $f1
    dec  A                                             ;; 01:5096 $3d
    jr   NZ, .jr_01_5081                               ;; 01:5097 $20 $e8
    ld   HL, wDB73_PasswordLivesRemaining                                     ;; 01:5099 $21 $73 $db
    ld   B, $0b                                        ;; 01:509c $06 $0b
    xor  A, A                                          ;; 01:509e $af
.jr_01_509f:
    add  A, [HL]                                       ;; 01:509f $86
    inc  HL                                            ;; 01:50a0 $23
    dec  B                                             ;; 01:50a1 $05
    jr   NZ, .jr_01_509f                               ;; 01:50a2 $20 $fb
    xor  A, $b6                                        ;; 01:50a4 $ee $b6
    ld   HL, wDB72_PasswordEncodedBuffer                                     ;; 01:50a6 $21 $72 $db
    cp   A, [HL]                                       ;; 01:50a9 $be
    jr   NZ, .jr_01_50b2                               ;; 01:50aa $20 $06
    call call_01_50b5_SetProgressFlagsFromPasswordMasks                                  ;; 01:50ac $cd $b5 $50
    ld   A, PASSWORD_VALID                                        ;; 01:50af $3e $20
    ret                                                ;; 01:50b1 $c9
.jr_01_50b2:
    ld   A, PASSWORD_INVALID                                        ;; 01:50b2 $3e $00
    ret                                                ;; 01:50b4 $c9

call_01_50b5_SetProgressFlagsFromPasswordMasks:
; Description:
; Builds a password lookup table (wDC5C_ProgressFlags) from static mask tables 
; .data_01_511a_PasswordColumnMaskTable and .data_01_5126_BitMaskLut_80to01. 
; It iterates through each mask byte, rotates bits, checks wDB76_PasswordEncodedBuffer bitfields, and sets password bits 
; in a temporary register (C). Once a row is processed, it stores the result into wDC5C_ProgressFlags, repeating 
; for 12 entries. Finally, it updates wDC4E_LivesRemaining/AF/4F with values from wDB73_PasswordLivesRemaining–wDB75_PasswordPawCoinExtraHealth.
    xor  A, A                                          ;; 01:50b5 $af
    ld   [wDB90_PasswordCounter], A                                    ;; 01:50b6 $ea $90 $db
    ld   DE, $00                                       ;; 01:50b9 $11 $00 $00
.jr_01_50bc:
    push DE                                            ;; 01:50bc $d5
    ld   HL, .data_01_511a_PasswordColumnMaskTable                             ;; 01:50bd $21 $1a $51
    add  HL, DE                                        ;; 01:50c0 $19
    ld   B, [HL]                                       ;; 01:50c1 $46
    ld   C, $00                                        ;; 01:50c2 $0e $00
    ld   A, $08                                        ;; 01:50c4 $3e $08
.jr_01_50c6:
    push AF                                            ;; 01:50c6 $f5
    bit  7, B                                          ;; 01:50c7 $cb $78
    jr   Z, .jr_01_50f3                                ;; 01:50c9 $28 $28
    ld   A, [wDB90_PasswordCounter]                                    ;; 01:50cb $fa $90 $db
    srl  A                                             ;; 01:50ce $cb $3f
    srl  A                                             ;; 01:50d0 $cb $3f
    srl  A                                             ;; 01:50d2 $cb $3f
    ld   E, A                                          ;; 01:50d4 $5f
    ld   D, $00                                        ;; 01:50d5 $16 $00
    ld   HL, wDB76_PasswordEncodedBuffer                                     ;; 01:50d7 $21 $76 $db
    add  HL, DE                                        ;; 01:50da $19
    push HL                                            ;; 01:50db $e5
    ld   A, [wDB90_PasswordCounter]                                    ;; 01:50dc $fa $90 $db
    and  A, $07                                        ;; 01:50df $e6 $07
    ld   E, A                                          ;; 01:50e1 $5f
    ld   D, $00                                        ;; 01:50e2 $16 $00
    ld   HL, .data_01_5126_BitMaskLut_80to01                             ;; 01:50e4 $21 $26 $51
    add  HL, DE                                        ;; 01:50e7 $19
    ld   A, [HL]                                       ;; 01:50e8 $7e
    pop  HL                                            ;; 01:50e9 $e1
    and  A, [HL]                                       ;; 01:50ea $a6
    jr   Z, .jr_01_50ef                                ;; 01:50eb $28 $02
    set  7, C                                          ;; 01:50ed $cb $f9
.jr_01_50ef:
    ld   HL, wDB90_PasswordCounter                                     ;; 01:50ef $21 $90 $db
    inc  [HL]                                          ;; 01:50f2 $34
.jr_01_50f3:
    rlc  C                                             ;; 01:50f3 $cb $01
    sla  B                                             ;; 01:50f5 $cb $20
    pop  AF                                            ;; 01:50f7 $f1
    dec  A                                             ;; 01:50f8 $3d
    jr   NZ, .jr_01_50c6                               ;; 01:50f9 $20 $cb
    pop  DE                                            ;; 01:50fb $d1
    ld   HL, wDC5C_ProgressFlags                                     ;; 01:50fc $21 $5c $dc
    add  HL, DE                                        ;; 01:50ff $19
    ld   [HL], C                                       ;; 01:5100 $71
    inc  E                                             ;; 01:5101 $1c
    ld   A, E                                          ;; 01:5102 $7b
    cp   A, $0c                                        ;; 01:5103 $fe $0c
    jr   C, .jr_01_50bc                                ;; 01:5105 $38 $b5
    ld   A, [wDB73_PasswordLivesRemaining]                                    ;; 01:5107 $fa $73 $db
    ld   [wDC4E_LivesRemaining], A                                    ;; 01:510a $ea $4e $dc
    ld   A, [wDB74_PasswordPawCoinCounter]                                    ;; 01:510d $fa $74 $db
    ld   [wDCAF_PawCoinCounter], A                                    ;; 01:5110 $ea $af $dc
    ld   A, [wDB75_PasswordPawCoinExtraHealth]                                    ;; 01:5113 $fa $75 $db
    ld   [wDC4F_PawCoinExtraHealth], A                                    ;; 01:5116 $ea $4f $dc
    ret                                                ;; 01:5119 $c9
.data_01_511a_PasswordColumnMaskTable:
; Description:
; A static table of bit masks used by call_01_50b5 to control which password checks 
; to perform for each column. Likely a column mask pattern for map rows.
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01        ;; 01:511a ????????
    db   $01, $01, $01, $01                            ;; 01:5122 ????
.data_01_5126_BitMaskLut_80to01:
; Description:
; A standard bitmask lookup table for individual bits ($80, $40, $20 … $01). 
; Used for testing individual tile bits in wDB76_PasswordEncodedBuffer.
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 01:5126 ????????
