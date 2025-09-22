call_00_2299_SetObjectStatusLowNibble:
; Uses the current object’s ID (wDA00_CurrentObjectAddr) to compute a pointer 
; into $D7xx status table.
; Replaces the lower nibble of that status byte with C, preserving the upper nibble.
; Purpose: Update the low-nibble state for the current object’s status entry.
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

call_00_22b1_HandleObjectStateChange:
; Similar indexing logic as 2299, but:
; Compares the current low nibble with C.
; If different, stores the old low nibble to wDAD6_ReturnBank.
; Then calls an alternate-bank routine (entry_02_72ac_LoadObjectData) using bank-switch 
; helper call_00_0EDD_CallAltBankFunc.
; Purpose: Detect a change in the object’s state nibble and, if changed, 
; trigger an alternate-bank handler for state transitions.
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
    ld   HL, entry_02_72ac_LoadObjectData                              ;; 00:22cd $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:22d0 $cd $dd $0e
    ret                                                ;; 00:22d3 $c9
    
call_00_22d4_CheckObjectSlotFlag:
; Calls call_00_230f_ResolveObjectListIndex to resolve the current object’s index (C).
; Uses that index to look up a byte in the table at wDCB1.
; Returns with A = value at that slot (flags zero/non-zero).
; Purpose: Check if a flag/slot for this object is set.
    call call_00_230f_ResolveObjectListIndex
    ld   b,$00
    ld   hl,wDCB1
    add  hl,bc
    ld   a,[hl]
    and  a
    ret  

call_00_22e0_IncrementObjectSlot:
; Gets object index via 230F.
; If index < $10, increments that object’s slot in wDCB1.
; Purpose: Increment a small counter for this object (capped at 16 slots).
    call call_00_230f_ResolveObjectListIndex
    ld   a,c
    cp   a,$10
    ret  nc
    ld   b,$00
    ld   hl,wDCB1
    add  hl,bc
    inc  [hl]
    ret  

call_00_22ef_SetObjectSlotActive:
; Gets object index via 230F.
; If index < $10, sets that object’s slot to 1.
; Purpose: Mark the slot as “active” or “initialized.”
    call call_00_230f_ResolveObjectListIndex
    ld   a,c
    cp   a,$10
    ret  nc
    ld   b,$00
    ld   hl,wDCB1
    add  hl,bc
    ld   [hl],$01
    ret  

call_00_22ff_ClearObjectSlot:
; Gets object index via 230F.
; If index < $10, clears that slot to 0.
; Purpose: Mark the slot as inactive/cleared.
    call call_00_230f_ResolveObjectListIndex
    ld   a,c
    cp   a,$10
    ret  nc
    ld   b,$00
    ld   hl,wDCB1
    add  hl,bc
    ld   [hl],$00
    ret  

call_00_230f_ResolveObjectListIndex:
; Switches to the object list bank (wDC16_ObjectListBank).
; Uses wDC17_ObjectListBankOffset and the current object’s ID (wDA00_CurrentObjectAddr) to compute 
; an index (C) into the object list.
; Performs bit shifts and offset calculations to get the proper entry pointer, then switches banks back.
; Returns C = resolved index for the object.
; Purpose: Resolve an object’s list index across banks.
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
    call call_00_0f08_RestoreBank                                  ;; 00:2339 $cd $08 $0f
    pop  BC                                            ;; 00:233c $c1
    ret                                                ;; 00:233d $c9

call_00_233e_UpdateObjectMotionFromVectorTable:
; Increments an object timer ($1B/$1C fields).
; Every $2E ticks, rolls over and increments a secondary counter while clearing a bit.
; Uses the counters to pick a two-byte vector from .data_00_23B4_Velocities (a table of X/Y velocities).
; Depending on the counter value, inverts and reorders components to get (e,c) velocity pair.
; Converts those velocities into signed words (d,b) and (e,c).
; Calls 2835_Object_GetVector_DA24 and 27F3_Object_GetVector_DA26 to adjust positions.
; Stores the computed 4-byte vector back into the object’s data block at $0E.
; Purpose: Generate and apply a predefined movement pattern (probably a curve or wave) over time to move an object.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1B
    ld   l,a
    inc  [hl]
    ld   a,[hl]
    sub  a,$2E
    jr   nz,.label2352
    ld   [hl],a
    inc  l
    inc  [hl]
    res  2,[hl]
    dec  l
.label2352:
    inc  l
    ldd  a,[hl]
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   de,.data_00_23B4_Velocities
    add  hl,de
    cp   a,$00
    jr   z,.label2381
    cp   a,$01
    jr   z,.label2379
    cp   a,$02
    jr   z,.label236F
    ldi  a,[hl]
    cpl  
    inc  a
    ld   c,a
    ld   e,[hl]
    jr   .label2384
.label236F:
    ldi  a,[hl]
    cpl  
    inc  a
    ld   e,a
    ld   a,[hl]
    cpl  
    inc  a
    ld   c,a
    jr   .label2384
.label2379:
    ld   c,[hl]
    inc  hl
    ld   a,[hl]
    cpl  
    inc  a
    ld   e,a
    jr   .label2384
.label2381:
    ld   e,[hl]
    inc  hl
    ld   c,[hl]
.label2384:
    ld   a,e
    cp   a,$80
    ld   a,$FF
    adc  a,$00
    ld   d,a
    push de
    call call_00_2835_Object_GetVector_DA24
    pop  hl
    add  hl,de
    push hl
    ld   a,c
    cp   a,$80
    ld   a,$FF
    adc  a,$00
    ld   b,a
    push bc
    call call_00_27f3_Object_GetVector_DA26
    pop  hl
    add  hl,de
    push hl
    pop  bc
    pop  de
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ld   a,e
    ldi  [hl],a
    ld   a,d
    ldi  [hl],a
    ld   a,c
    ldi  [hl],a
    ld   [hl],b
    ret  
.data_00_23B4_Velocities:
    db   $00, $e0        ;; 00:23ae ????????
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
    db   $1f, $00

call_00_2410_SetDirectionFlag_PlayerLeft:
; Loads the current object’s position ($0E/$0F).
; Compares it with the player’s X position (wD80E/F).
; Sets a nearby state byte (L xor $02) to $20 if the player is 
; left of the object, otherwise $00.
; Purpose: A left/right proximity flag to influence AI.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ld   c,$20
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80F_PlayerXPosition]
    sbc  [hl]
    jr   c,label2427
    ld   c,$00
label2427:
    ld   a,l
    xor  a,$02
    ld   l,a
    ld   [hl],c
    ret  
    
call_00_242d_SetDirectionFlag_PlayerRight:
; Same comparison as 2410 but reversed:
; Sets the flag to $20 if the player is right of the object, otherwise $00.
; Purpose: Mirror of the above for right-side checking.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ld   c,$00
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80F_PlayerXPosition]
    sbc  [hl]
    jr   c,label2444
    ld   c,$20
label2444:
    ld   a,l
    xor  a,$02
    ld   l,a
    ld   [hl],c
    ret  

call_00_244a_Object_ApplyClampedVerticalVelocity:
; Gets a value from $1D (likely vertical velocity). Subtracts 2, clamps negative values to at least $C0.
; Stores the result back.
; Computes a small step (cpl/inc + four sra) to get a signed delta (C,B).
; Jumps to call_00_250d_Object_UpdateYPosition to apply the delta to object position.
; Purpose: Reduces velocity, clamps it, and applies movement on Y-axis.
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
    jp   call_00_250d_Object_UpdateYPosition                                    ;; 00:2472 $c3 $0d $25

call_00_2475_Object_MoveAndClampVerticalPosition:
; Similar to 244A: subtracts 2 from $1D, clamps to $C0.
; Computes step (C,B) by shifting four times.
; Adds the delta directly to position at $0D/$0E.
; Calls 27F3_Object_GetVector_DA26 (likely gets a reference vector).
; Compares the result (E,D) to another position vector at $10.
; If overshooting, snaps the object back to (D,E) and clears $0D.
; Purpose: Applies vertical movement with boundary checking and snapping.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1D
    ld   l,a
    ld   a,[hl]
    sub  a,$02
    bit  $7,a
    jr   z,label248A
    cp   a,$C0
    jr   nc,label248A
    ld   a,$C0
label248A:
    ld   [hl],a
    sra  a
    sra  a
    sra  a
    sra  a
    ld   c,a
    cp   a,$80
    ld   a,$FF
    adc  a,$00
    ld   b,a
    ld   a,l
    xor  a,$0D
    ld   l,a
    ld   a,[hl]
    add  c
    ldi  [hl],a
    ld   a,[hl]
    adc  b
    ld   [hl],a
    call call_00_27f3_Object_GetVector_DA26
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   l,a
    ld   a,e
    sub  [hl]
    inc  hl
    ld   a,d
    sbc  [hl]
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   a,l
    xor  a,$0D
    ld   l,a
    xor  a
    ld   [hl],a
    ret  

call_00_24c0_Object_IntegrateFractionalVelocity_X:
; Reads two velocity bytes at offset $1B, accumulates them, 
; keeps the lower nibble for fractional remainder.
; Arithmetic right-shifts the sum to get a signed step (C,B).
; Adds this step to the object’s position vector at $0E.
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

call_00_24ee_Object_IntegrateFractionalVelocity_Y:
; Same pattern as call_00_24c0_Object_IntegrateFractionalVelocity_X but works on 
; $1D and updates position at $10.
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
call_00_250d_Object_UpdateYPosition:
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

call_00_251c_Object_CheckRegionAndSetFlag:
; Uses 254A to update velocity, then compares object’s tile vector (wDA1C table)
; against (E,D) to decide if the object is inside a region.
; Updates a flag at $0D or returns zero if outside
    call call_00_254a_Object_UpdateDeltaAndAdvancePosition                                  ;; 00:251c $cd $4a $25
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

call_00_254a_Object_UpdateDeltaAndAdvancePosition:
; Helper: computes a signed velocity delta from $1B and the current $0D state, 
; preserves fractional nibble, shifts for step size, and adds to position at $12.
; Stores intermediate delta in wDA13.
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

call_00_2588_Object_ApproachTargetValue_Byte:
; Compares the value at $1B with C.
; Increments or decrements $1B by 1 toward C.
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

call_00_259d_Object_CheckRegionAndUpdateState:
; Calls 25CB to update velocity/position.
; Compares two position ranges in wDA20 with (E,D).
; If outside bounds, sets $0D to $40 or $00.
    call call_00_25CB_Object_IntegrateFractionalVelocity_Helper
    ld   a,[wDA00_CurrentObjectAddr]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA20
    add  hl,bc
    ld   c,$00
    ldi  a,[hl]
    sub  e
    ldi  a,[hl]
    sbc  d
    jr   c,call_00_25BF_Object_SetAndCompareState
    ld   c,$40
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jr   nc,call_00_25BF_Object_SetAndCompareState
    xor  a
    ret  

call_00_25BF_Object_SetAndCompareState:
; Stores a new state value C into $0D and compares previous value.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0D
    ld   l,a
    ld   a,[hl]
    ld   [hl],c
    cp   c
    ret  

call_00_25CB_Object_IntegrateFractionalVelocity_Helper:
; Computes signed delta from $0D and $10, masks the lower nibble, shifts, and adds to position.
; Produces (D,E) as updated position deltas.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0D
    ld   l,a
    ld   c,[hl]
    ld   a,l
    xor  a,$10
    ld   l,a
    ldi  a,[hl]
    bit  6,c
    jr   nz,label25DF
    cpl  
    inc  a
label25DF:
    add  [hl]
    ld   c,a
    and  a,$0F
    ld   [hl],a
    ld   a,c
    sra  a
    sra  a
    sra  a
    sra  a
    ld   c,a
    cp   a,$80
    ld   a,$FF
    adc  a,$00
    ld   b,a
    ld   a,l
    xor  a,$0E
    ld   l,a
    ld   a,[hl]
    add  c
    ldi  [hl],a
    ld   e,a
    ld   a,[hl]
    adc  b
    ld   [hl],a
    ld   d,a
    ret  

call_00_2602_Object_ApproachTargetValue_Y:
; Adjusts the value at $1D up or down until it equals C.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1D
    ld   l,a
    ld   a,[hl]
    cp   c
    ret  z
    jr   c,call_00_2613
    dec  [hl]
    ld   a,[hl]
    cp   c
    ret  

call_00_2613:
    inc  [hl]
    ld   a,[hl]
    cp   c
    ret  

call_00_2617_SnapPositionAndUpdateDelta:
; Compares two object vectors (DA1E and DA1C) against current position; 
; if behind boundary, decrements DE.
; Snaps the stored position to (E,D) and adjusts global delta wDA13.
    call call_00_2857_Object_GetVector_DA1E
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ldi  a,[hl]
    sub  e
    ldd  a,[hl]
    sbc  d
    jr   c,label2639
    call call_00_2846_Object_GetVector_DA1C
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ldi  a,[hl]
    sub  e
    ldd  a,[hl]
    sbc  d
    ret  c
    dec  de
label2639:
    ld   a,e
    sub  [hl]
    ld   [hl],e
    inc  hl
    ld   [hl],d
    ld   hl,wDA13
    add  [hl]
    ld   [hl],a
    xor  a
    ret  

call_00_2645_Object_SelectNearestVector_DA1C_DA1E:
; Select Closest Vector From DA1C/DA1E
; Chooses between two stored vectors (DA1C and DA1E) based on the sign bit of A.
; It compares distances to some reference (after adjusting with call_00_2678_Vector_AddObjectXPos) and 
; selects whichever vector (C,B) is closer, then writes it back through HL.
    bit  $7,a
    jr   nz,label265B
    ld   b,$00
    call call_00_2846_Object_GetVector_DA1C
    call call_00_2678_Vector_AddObjectXPos
    ld   a,c
    sub  e
    ld   a,b
    sbc  d
    jr   c,label266E
    ld   c,e
    ld   b,d
    jr   label266E
label265B:
    xor  a
    sub  c
    ld   c,a
    ld   b,$FF
    call call_00_2857_Object_GetVector_DA1E
    call call_00_2678_Vector_AddObjectXPos
    ld   a,e
    sub  c
    ld   a,d
    sbc  b
    jr   c,label266E
    ld   c,e
    ld   b,d
label266E:
    ld   a,b
    ldd  [hl],a
    ld   [hl],c
    ld   a,c
    sub  e
    ld   c,a
    ld   a,b
    sbc  d
    or   c
    ret  

call_00_2678_Vector_AddObjectXPos:
; Offset Vector By Object X
; Loads the object’s X position ($D8:xx0E/$D8:xx0F) and adds it to C,B. 
; Used to convert local offsets into world coordinates.
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ld   h,$D8
    ldi  a,[hl]
    add  c
    ld   c,a
    ld   a,[hl]
    adc  b
    ld   b,a
    ret  

call_00_2687_Object_SelectNearestVector_DA20_DA22:
; Select Closest Vector From DA20/DA22
; Same selection pattern but for tables DA20 and DA22 and uses call_00_26BA_Vector_AddObjectYPos 
; to offset with Y.
    bit  $7,a
    jr   nz,label269D
    ld   b,$00
    call call_00_2804_Object_GetVector_DA20
    call call_00_26BA_Vector_AddObjectYPos
    ld   a,c
    sub  e
    ld   a,b
    sbc  d
    jr   c,label26B0
    ld   c,e
    ld   b,d
    jr   label26B0
label269D:
    xor  a
    sub  c
    ld   c,a
    ld   b,$FF
    call call_00_2815_Object_GetVector_DA22
    call call_00_26BA_Vector_AddObjectYPos
    ld   a,e
    sub  c
    ld   a,d
    sbc  b
    jr   c,label26B0
    ld   c,e
    ld   b,d
label26B0:
    ld   a,b
    ldd  [hl],a
    ld   [hl],c
    ld   a,c
    sub  e
    ld   c,a
    ld   a,b
    sbc  d
    or   c
    ret  

call_00_26BA_Vector_AddObjectYPos:
; Offset Vector By Object Y
; Loads the object’s Y position ($D8:xx10) and adds it to C,B
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   l,a
    ld   h,$D8
    ldi  a,[hl]
    add  c
    ld   c,a
    ld   a,[hl]
    adc  b
    ld   b,a
    ret  

call_00_26c9_Object_HandleXCollisionOrSectorCheck:
; Handle Object State / X Collision Probe
; Reads a couple of object bytes at offsets $1B, $02, $17 into C,B,DE, checks a flag 
; bit, possibly negates C, compares an upper-bits mask to wDC7B (tilemap or sector ID), 
; and if equal calls call_00_26F1_Player_UpdateXFromObject. Finally stores the horizontal delta (C) to wDC85.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1B
    ld   l,a
    ld   c,[hl]
    xor  a,$02
    ld   l,a
    ld   b,[hl]
    xor  a,$17
    ld   l,a
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    bit  $6,b
    jr   nz,label26E3
    xor  a
    sub  c
    ld   c,a
label26E3:
    ld   a,l
    and  a,$E0
    ld   hl,wDC7B
    cp   [hl]
    jr   nz,call_00_26F1_Player_UpdateXFromObject
    ld   a,c
    ld   [wDC85],a
    ret  

call_00_26F1_Player_UpdateXFromObject:
; Update Player X Relative to Object
; Compares player position to the object and adjusts or clamps X.
    ld   hl,wDC7D
    cp   [hl]
    ret  nz
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$12
    ld   l,a
    ld   a,[wD80E_PlayerXPosition]
    sub  e
    ld   a,[wD80F_PlayerXPosition]
    sbc  d
    jr   c,call_00_2714_Player_ClampXLeft
    ld   a,e
    add  [hl]
    ld   [wD80E_PlayerXPosition],a
    ld   a,d
    adc  a,$00
    ld   [wD80F_PlayerXPosition],a
    ret  

call_00_2714_Player_ClampXLeft:
; Clamp Player X
; When the player is too far left of the object, this clamps the player’s X position 
; to just inside the object boundary (adds one to the object’s stored width, then 
; subtracts from the delta).
    ld   c,[hl]
    inc  c
    ld   a,e
    sub  c
    ld   [wD80E_PlayerXPosition],a
    ld   a,d
    sbc  a,$00
    ld   [wD80F_PlayerXPosition],a
    ret  

call_00_2722_Player_IsWithinObjectYRange:
; Check Vertical Collision Window
; Computes the relative Y distance between the player and an object, 
; checks two auxiliary offsets (GetDA1E and GetDA1C), and returns A=1 
; if the player is within a certain vertical band or collision box, 
; else returns zero.
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
    call call_00_2857_Object_GetVector_DA1E                                  ;; 00:2746 $cd $57 $28
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2749 $fa $0e $d8
    sub  A, E                                          ;; 00:274c $93
    ld   A, [wD80F_PlayerXPosition]                                    ;; 00:274d $fa $0f $d8
    sbc  A, D                                          ;; 00:2750 $9a
    jr   C, .jr_00_2764                                ;; 00:2751 $38 $11
    call call_00_2846_Object_GetVector_DA1C                                  ;; 00:2753 $cd $46 $28
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

call_00_2766_Object_UpdateXPositionFromVector:
; Update Object Position if Player Behind
; Uses GetDA26 (probably retrieves the object’s movement vector), compares it to the 
; player’s relative position. If the player is not in front, writes a new object 
; position (E,D) into the object’s slot and clears a state flag.
    call call_00_27f3_Object_GetVector_DA26                                  ;; 00:2766 $cd $f3 $27
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

call_00_2780_Object_ComputeMapYDelta:
; Compute Object-to-Map Y Delta
; Loads the map’s Y base (wDBFB_YPositionInMap), adds an offset ($B0), then 
; computes the difference between that and the object’s stored Y to get a signed 
; vertical distance.
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

call_00_2799_Object_InterpolateTowardVector:
; Move Object Toward Target Vector
; Gets a vector from GetDA24, computes the difference between the object’s position 
; and the vector, halves the delta (srl d / rr e), then adds it back to the current 
; stored vector (GetDA26). Finally, writes the interpolated position back into the 
; object’s position slot. This looks like smooth following or homing movement.
    call call_00_2835_Object_GetVector_DA24
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
    call call_00_27f3_Object_GetVector_DA26
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

call_00_27cb_Object_SetYFromMap:
; Store Map Y Position Into Object
; Copies the map’s Y position minus $14 into the object’s Y slot, with carry handling:
; if subtraction underflows, it zeros both low and high bytes. This anchors an object 
; relative to the map’s scrolling.
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

call_00_27e4_Object_SetYPosFromDA26:
; Write DA26 Vector to Object Y Pos
; Calls GetDA26 to fetch a two-byte vector from table wDA26 and writes it 
; into the current object’s position slot at $D8:xx10.
    call call_00_27f3_Object_GetVector_DA26
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$10
    ld   l,a
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_27f3_Object_GetVector_DA26:
; Uses wDA00_CurrentObjectAddr to compute an index, reads a two-byte 
; vector from table wDA26 into DE.
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

call_00_2804_Object_GetVector_DA20:
; Reads a vector from wDA20
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

call_00_2815_Object_GetVector_DA22:
; Reads a vector from wDA22
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

call_00_2826_Object_SetXFromDA24:
; Gets DA24 vector and stores it in the object’s $D8:xx0E slot (X position).
    call call_00_2835_Object_GetVector_DA24
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0E
    ld   l,a
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_2835_Object_GetVector_DA24:
; Reads a vector from wDA24
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

call_00_2846_Object_GetVector_DA1C:
; Reads a vector from wDA1C
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

call_00_2857_Object_GetVector_DA1E:
; Reads a vector from wDA1E
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

call_00_2868_Object_SetVector_DA1C:
; Writes DE into wDA1C entry for the current object.
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

call_00_2879_Object_SetVector_DA1E:
; Writes DE into wDA1E entry for the current object.
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

call_00_288c_Object_Clear14:
; Write Byte to Object Offset $14
; Writes register C (or zero if called via the preceding stub) into the 
; object’s $D8:xx14 slot, likely a state/timer field.
    ld   C, $00                                        ;; 00:288a $0e $00
call_00_288c_Object_Set14:
    ld   H, $d8                                        ;; 00:288c $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:288e $fa $00 $da
    or   A, $14                                        ;; 00:2891 $f6 $14
    ld   L, A                                          ;; 00:2893 $6f
    ld   [HL], C                                       ;; 00:2894 $71
    ret                                                ;; 00:2895 $c9

call_00_2896_Object_Set15:
; Writes C into the object’s $D8:xx15 slot—another per-object state byte.
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

call_00_29ac_ObjectFacingMatchesStoredDirection:
; Calls call_00_2a68_ComputePlayerObjectXVector (unknown, likely updates or computes something about the current object).
; Calls call_00_2976_ObjectGetFacingDirection (gets the object's facing direction).
; Compares A (direction) to [wDA12] (a stored reference direction/state).
; Returns if equal/different.
; Summary: Checks if an object's current facing direction matches a stored direction after updating.
    call call_00_2a68_ComputePlayerObjectXVector
    call call_00_2976_ObjectGetFacingDirection
    ld   hl,wDA12
    cp   [hl]
    ret  

call_00_29b7_FindObjectByID_C:
; Starts at object table base $D840.
; Iterates through entries (+20h each = 32 bytes per object) comparing [HL] to register C.
; If a match is found, jumps to call_00_29C8_FetchObjectSecondaryValue.
; If none, sets C=$FF and returns.
    ld   h,$D8
    ld   l,$40
label29BB:
    ld   a,[hl]
    cp   c
    jr   z,call_00_29C8_FetchObjectSecondaryValue
    ld   a,l
    add  a,$20
    ld   l,a
    jr   nz,label29BB
    ld   c,$FF
    ret  

call_00_29C8_FetchObjectSecondaryValue:
; When a match is found: ORs L with $01 (moves to second byte in object record).
; Loads [HL] into C (likely returns a pointer or secondary ID).
    ld   a,l
    or   a,$01
    ld   l,a
    ld   c,[hl]
    ret  

call_00_29ce_ObjectExistsCheck:
; Almost identical to 29b7, but:
; Returns immediately if found (ret Z).
; If none found, loads $01 into A, ANDs A with itself, and returns 
; (effectively a false indicator).
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
    
call_00_29df_ObjectSetActiveFlag:
; Computes HL = $D80D + current object index.
; Sets bit 7 of [HL] (marking object as “active,” “visible,” or “flagged”).
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0D
    ld   l,a
    set  7,[hl]
    ret  

call_00_29ea_ObjectClearActiveFlag:
; Same indexing, but clears bit 7 instead of setting it.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$0D
    ld   l,a
    res  7,[hl]
    ret  

call_00_29f5_ObjectClearCollisionFlagAndCheck:
; Gets object entry byte at $D805+index.
; Clears bit 4 in memory.
; Returns with carry based on the old bit 4 state (bit 4,A).
    ld   H, $d8                                        ;; 00:29f5 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:29f7 $fa $00 $da
    or   A, $05                                        ;; 00:29fa $f6 $05
    ld   L, A                                          ;; 00:29fc $6f
    ld   A, [HL]                                       ;; 00:29fd $7e
    res  4, [HL]                                       ;; 00:29fe $cb $a6
    bit  4, A                                          ;; 00:2a00 $cb $67
    ret                                                ;; 00:2a02 $c9

call_00_2a03_ResetObjectTempSlot:
; Derives a small index from wDA00_CurrentObjectAddr by rotating left and masking.
; Writes 0 to wDA01 + index.
; Likely clears a small per-object temporary slot.
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

call_00_2a15_CheckObjectBoundingBoxCollision:
; Derives an index from wDA00_CurrentObjectAddr (right rotate + mask).
; Loads a 4-byte rectangle (E,D,C,B) from wDA1C.
; Compares against another rectangle at wDA14 (x,y pairs) → first collision check.
; If no carry (no fail), repeats with another rectangle from wDA20 vs wDA18.
; Returns carry if overlap fails, else returns normally.
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

call_00_2a5d_ObjectCheckFlag2:
; Computes HL = D805 + current object index.
; Tests bit 2 of the object’s flags.
; Purpose: Checks a particular state flag (likely “grounded,” “active,” or similar).
    ld   H, $d8                                        ;; 00:2a5d $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2a5f $fa $00 $da
    or   A, $05                                        ;; 00:2a62 $f6 $05
    ld   L, A                                          ;; 00:2a64 $6f
    bit  2, [HL]                                       ;; 00:2a65 $cb $56
    ret                                                ;; 00:2a67 $c9

call_00_2a68_ComputePlayerObjectXVector:
; Calculates the X-distance vector between the player (wD80E/F) and the current object’s position (D80E + offset).
; Normalizes the sign: if negative, flips and sets C=$20 to indicate direction.
; Stores the horizontal difference or direction in wDA11/wDA12, and returns.
; Purpose: Prepares relative X-direction info for later checks.
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

call_00_2a98_HandlePlayerObjectInteraction:
; Resolves an object list index, computes a pointer to an object’s bounding box/metadata in memory.
; Compares the player’s X/Y positions against that object’s bounding box (series of sub/sbc, add, cp checks).
; If inside bounds, copies several bytes from the object’s data into the current object’s D8xx structure and 
; triggers a banked function (entry_02_72ac_LoadObjectData) via call_00_0edd_CallAltBankFunc.
; Purpose: Detects when the player collides with or interacts with a special object and dispatches a handler.
    push de
    call call_00_230f_ResolveObjectListIndex
    ld   l,c
    ld   h,$00
    add  hl,hl
    ld   e,l
    ld   d,h
    add  hl,hl
    add  hl,hl
    add  hl,de
    pop  de
    add  hl,de
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD80F_PlayerXPosition]
    sbc  [hl]
    ld   d,a
    inc  hl
    ld   a,[hl]
    add  e
    ld   e,a
    ld   a,d
    adc  a,$00
    ret  nz
    ldi  a,[hl]
    add  a
    ld   d,a
    ld   a,e
    cp   d
    ret  nc
    ld   a,[wD810_PlayerYPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD811_PlayerYPosition]
    sbc  [hl]
    ld   d,a
    inc  hl
    ld   a,[hl]
    add  e
    ld   e,a
    ld   a,d
    adc  a,$00
    ret  nz
    ldi  a,[hl]
    add  a
    ld   d,a
    ld   a,e
    cp   d
    ret  nc
    ld   d,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,$1A
    ld   e,a
    ldi  a,[hl]
    ld   [de],a
    inc  de
    ldi  a,[hl]
    ld   [de],a
    inc  de
    xor  a
    ld   [de],a
    inc  de
    ldi  a,[hl]
    ld   [de],a
    inc  de
    xor  a
    ld   [de],a
    ld   a,[hl]
    ld   [wDAD6_ReturnBank],a
    ld   a,02
    ld   hl,entry_02_72ac_LoadObjectData
    call call_00_0edd_CallAltBankFunc
    ret  

call_00_2afc_FindFreeObjectSlot:
; Iterates through all object slots ($D840… step $20).
; Finds the first free slot (checks for inc A; jr NZ to catch zero).
; Returns A=D as 0 if none found.
; Purpose: Locate a free entry in the object table.
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

call_00_2b10_VerifyObjectPairExists:
; Derives a per-object small index from wDA00_CurrentObjectAddr.
; Loads a saved value B from wDA01 + index.
; Scans the object table comparing:
; Primary ID ([HL] vs C), then
; A secondary ID ([HL|1F] vs B).
; Returns carry if none, or sets A=1 if a match is found.
; Purpose: Check whether an object with a given ID pair exists in the object table.
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

call_00_2b3d_SweepAndClearActiveObjects:
; Iterates through object slots in increments of $20, checking each slot in wD8xx. 
; If the slot value isn’t $FF (active), it calls call_00_2b5d_DeactivateObjectSlot to clear the entry. 
; Restores wDA00_CurrentObjectAddr afterward. Essentially sweeps all object entries and deactivates them.
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
    call NZ, call_00_2b5d_DeactivateObjectSlot                              ;; 00:2b4e $c4 $5d $2b
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b51 $fa $00 $da
    add  A, $20                                        ;; 00:2b54 $c6 $20
    jr   NZ, .jr_00_2b43                               ;; 00:2b56 $20 $eb
    pop  AF                                            ;; 00:2b58 $f1
    ld   [wDA00_CurrentObjectAddr], A                                    ;; 00:2b59 $ea $00 $da
    ret                                                ;; 00:2b5c $c9

call_00_2b5d_DeactivateObjectSlot:
; Marks the current object slot as inactive by writing $FF to wD8xx. Then computes a related index 
; from the slot address to access another table (wDA01 → wD7xx) and clears bit 6 of its status 
; byte—likely removing an “active” or “visible” flag for that object.
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

call_00_2b7a_ClearObjectThenJump:
; Calls call_00_2b80_ClearObjectMemoryEntry (sets slot to $FF), then jumps to call_00_2b94_ZeroObjectStatusEntry (zeroes a related entry in wD7xx). 
; Used as a branch to fully clear an object before continuing.
    call call_00_2b80_ClearObjectMemoryEntry                                  ;; 00:2b7a $cd $80 $2b
    jp   call_00_2b94_ZeroObjectStatusEntry                                    ;; 00:2b7d $c3 $94 $2b

call_00_2b80_ClearObjectMemoryEntry:
; Writes $FF to the current object’s wD8xx slot. This is a lightweight variant 
; of call_00_2b5d without touching flags.
    ld   H, $d8                                        ;; 00:2b80 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 00:2b82 $fa $00 $da
    or   A, $00                                        ;; 00:2b85 $f6 $00
    ld   L, A                                          ;; 00:2b87 $6f
    ld   [HL], $ff                                     ;; 00:2b88 $36 $ff
    ret                                                ;; 00:2b8a $c9

call_00_2b8b_HandleObjectFlag6ClearOrInit:
; Calls call_00_35e8_GetObjectTypeIndex (likely reads or updates object state), tests bit 6 of A. If clear, 
; jumps to call_00_2b94_ZeroObjectStatusEntry (zero related data). If set, jumps to call_00_2ba9_SetObjectStatusTo50 to initialize a 
; status value. Used to decide whether to zero or set $50.
    call call_00_35e8_GetObjectTypeIndex                                  ;; 00:2b8b $cd $e8 $35
    bit  6, A                                          ;; 00:2b8e $cb $77
    jr   Z, call_00_2b94_ZeroObjectStatusEntry                                 ;; 00:2b90 $28 $02
    jr   call_00_2ba9_SetObjectStatusTo50                                  ;; 00:2b92 $18 $15

call_00_2b94_ZeroObjectStatusEntry:
; Computes an index from the object address and writes $00 to a corresponding wD7xx status 
; byte—used to mark an object as inactive or reset its state.
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

call_00_2ba9_SetObjectStatusTo50:
; Like call_00_2b94_ZeroObjectStatusEntry, but writes $50 instead of $00. 
; Likely initializes or flags an object as partially active.
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

call_00_2bbe_SpawnCollectibleObject:
; Full object creation routine:
; Validates current object value via call_00_35e8_GetObjectTypeIndex.
; If not $FF and bit 6 is set, sets up multiple object parameters 
; (ObjectSetId, Object_Set14, palette, facing direction, etc.).
; Updates its status to $50, resets return bank, calls an alternate bank function (entry_02_72ac_LoadObjectData), 
; and copies a palette (call_00_2c20_ObjectPalette_CopyToBuffer).
; This is the main “spawn/setup object” function.
    call call_00_35e8_GetObjectTypeIndex                                  ;; 00:2bbe $cd $e8 $35
    cp   A, $ff                                        ;; 00:2bc1 $fe $ff
    jr   Z, call_00_2b7a_ClearObjectThenJump                                 ;; 00:2bc3 $28 $b5
    bit  6, A                                          ;; 00:2bc5 $cb $77
    jr   Z, call_00_2b7a_ClearObjectThenJump                                 ;; 00:2bc7 $28 $b1
    ld   C, $02                                        ;; 00:2bc9 $0e $02
    call call_00_2930_ObjectSetId                                  ;; 00:2bcb $cd $30 $29
    ld   C, $08                                        ;; 00:2bce $0e $08
    call call_00_288c_Object_Set14                                  ;; 00:2bd0 $cd $8c $28
    ld   C, $12                                        ;; 00:2bd3 $0e $12
    call call_00_2944_ObjectSet12                                  ;; 00:2bd5 $cd $44 $29
    ld   C, $12                                        ;; 00:2bd8 $0e $12
    call call_00_294e_ObjectSet13                                  ;; 00:2bda $cd $4e $29
    ld   C, $00                                        ;; 00:2bdd $0e $00
    call call_00_2958_ObjectSetFacingDirection                                  ;; 00:2bdf $cd $58 $29
    ld   C, $01                                        ;; 00:2be2 $0e $01
    call call_00_28aa_ObjectSet16                                  ;; 00:2be4 $cd $aa $28
    ld   C, $00                                        ;; 00:2be7 $0e $00
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 00:2be9 $cd $99 $22
    call call_00_2ba9_SetObjectStatusTo50                                  ;; 00:2bec $cd $a9 $2b
    xor  A, A                                          ;; 00:2bef $af
    ld   [wDAD6_ReturnBank], A                                    ;; 00:2bf0 $ea $d6 $da
    ld   A, $02                                        ;; 00:2bf3 $3e $02
    ld   HL, entry_02_72ac_LoadObjectData                              ;; 00:2bf5 $21 $ac $72
    call call_00_0edd_CallAltBankFunc                                  ;; 00:2bf8 $cd $dd $0e
    ld   HL, .data_02_2c01                                     ;; 00:2bfb $21 $01 $2c
    jp   call_00_2c20_ObjectPalette_CopyToBuffer                                  ;; 00:2bfe $c3 $20 $2c
.data_02_2c01:
    db   $00, $00, $00, $00, $60, $02, $9c, $03        ;; 00:2c01 ........

call_00_2c09_DispatchOffsetAction:
; Adds $06 to A, moves it to C, and jumps to call_00_3792_PrepareRelativeObjectSpawn. 
; Likely an offset-based action dispatcher or table index calculation.
    add  A, $06                                        ;; 00:2c09 $c6 $06
    ld   C, A                                          ;; 00:2c0b $4f
    jp   call_00_3792_PrepareRelativeObjectSpawn                                  ;; 00:2c0c $c3 $92 $37

call_00_2c0f_AssignObjectPaletteId:
; Uses the current object address to compute an index into wDAAE_ObjectPaletteIds, 
; then stores register C there. Assigns a palette ID to the object for rendering.
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

call_00_2c20_ObjectPalette_CopyToBuffer:
; Looks up the palette slot previously stored in wDAAE for the current object.
; Multiplies that index by 8 to get a byte offset into wDD2A_ObjectPalettes.
; Copies 8 bytes from whatever source HL pointed to into that palette slot.
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
; The pointer table to the individual particle buffers.
    dw   wDDC4_ParticleSlot1Buffer, wDDD7_ParticleSlot2Buffer
    dw   wDDEA_ParticleSlot3Buffer, wDDFD_ParticleSlot4Buffer        ;; 00:2c43 ????????
    dw   wDE10_ParticleSlot5Buffer, wDE23_ParticleSlot6Buffer
    dw   wDE36_ParticleSlot7Buffer, wDE49_ParticleSlot8Buffer                                         ;; 00:2c51 pP

call_00_2c53_ParticleSlot_GetBufferPtr:
; Fetches the DE pointer for the particle slot based on the current object’s bits.
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
; Initializes a particle slot with the default burst data and timer ($40).
    call call_00_2c53_ParticleSlot_GetBufferPtr                                  ;; 00:2c67 $cd $53 $2c
    ld   A, $40                                        ;; 00:2c6a $3e $40
    ld   [DE], A                                       ;; 00:2c6c $12
    inc  DE                                            ;; 00:2c6d $13
    ld   HL, .data_00_2c77_Particle_DefaultBurstTemplate                                     ;; 00:2c6e $21 $77 $2c
    ld   BC, $12                                       ;; 00:2c71 $01 $12 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:2c74 $c3 $6e $07
.data_00_2c77_Particle_DefaultBurstTemplate:
; Default particle data copied during initialization.
    db   $0b, $00, $00, $f5, $00, $00, $10, $00        ;; 00:2c77 ........
    db   $00, $00, $00, $00, $0b, $00, $00, $0b        ;; 00:2c7f ........
    db   $00, $00                                      ;; 00:2c87 ..

call_00_2c89_Particle_UpdateBurst:
; Per-frame update: decrements the timer and smooths/blends velocity/position values.
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
