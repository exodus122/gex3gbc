call_00_21ef_Entity_PlayRemoteSFX:
; Pushes BC (preserve), loads A=1E, calls QueueSoundEffectWithPriority, restores BC.
; Just plays the remote spawned/obtained sound effect
    push BC                                            ;; 00:21ef $c5
    ld   A, SFX_REMOTE                                        ;; 00:21f0 $3e $1e
    call call_00_0ff5_QueueSoundEffect                                  ;; 00:21f2 $cd $f5 $0f
    pop  BC                                            ;; 00:21f5 $c1

call_00_21f6_Entity_SetTVButtonFlags:
; Switches to the bank containing the entity list (wDC16_EntityListBank).
; Reads the start of the entity list (wDC17_EntityListBankOffset).
; Iterates through 16-byte entity records, searching for entities of type $11 (ENTITY_TV_BUTTON)
; whose parameter matches C.
; When found, it updates a D7xx structure at index B:
; Sets a nibble/flag ([DE] = ([DE] & $F0) | value).
; Uses a small table (db $00,$01,$02,$04 at .data_00_225c) and level mask (wDC1E_CurrentLevelID) 
; to decide which flag (1 or 2) to apply.
; Exits by restoring the previous bank. 
; Usage:
; Marks specific entities (e.g., collectibles, triggers, or doors) as "active" or "visited" 
; for the current level. This is typical of collectible or progression flags.
    push BC                                            ;; 00:21f6 $c5
    ld   A, [wDC16_EntityListBank]                                    ;; 00:21f7 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:21fa $cd $ee $0e
    pop  BC                                            ;; 00:21fd $c1
    ld   HL, wDC17_EntityListBankOffset                                     ;; 00:21fe $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:2201 $2a
    ld   H, [HL]                                       ;; 00:2202 $66
    ld   L, A                                          ;; 00:2203 $6f
    ld   A, [HL]                                       ;; 00:2204 $7e
    cp   A, $ff                                        ;; 00:2205 $fe $ff
    jp   Z, call_00_0f08_RestoreBank                               ;; 00:2207 $ca $08 $0f
    ld   B, $01                                        ;; 00:220a $06 $01
.jr_00_220c:
    push HL                                            ;; 00:220c $e5
    ld   A, [HL]                                       ;; 00:220d $7e
    cp   A, ENTITY_TV_BUTTON                                        ;; 00:220e $fe $11
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
    jp   call_00_0f08_RestoreBank                                  ;; 00:2225 $c3 $08 $0f
.jr_00_2228:
    pop  HL                                            ;; 00:2228 $e1
    ld   E, B                                          ;; 00:2229 $58
    ld   D, HIGH(wD700_EntityFlags)                                        ;; 00:222a $16 $d7
    ld   A, [DE]                                       ;; 00:222c $1a
    and  A, $f0                                        ;; 00:222d $e6 $f0
    or   A, $01                                        ;; 00:222f $f6 $01
    ld   [DE], A                                       ;; 00:2231 $12
    inc  E                                             ;; 00:2232 $1c
    ld   L, C                                          ;; 00:2233 $69
    ld   H, $00                                        ;; 00:2234 $26 $00
    ld   BC, .data_00_225c                                     ;; 00:2236 $01 $5c $22
    add  HL, BC                                        ;; 00:2239 $09
    ld   A, [HL]                                       ;; 00:223a $7e
    push AF                                            ;; 00:223b $f5
    ld   HL, wDC1E_CurrentLevelID                                     ;; 00:223c $21 $1e $dc
    ld   L, [HL]                                       ;; 00:223f $6e
    ld   H, $00                                        ;; 00:2240 $26 $00
    ld   BC, wDC5C_ProgressFlags                                     ;; 00:2242 $01 $5c $dc
    add  HL, BC                                        ;; 00:2245 $09
    pop  AF                                            ;; 00:2246 $f1
    ld   C, $01                                        ;; 00:2247 $0e $01
    and  A, [HL]                                       ;; 00:2249 $a6
    jr   Z, .jr_00_2254                                ;; 00:224a $28 $08
    ld   A, [wDC1E_CurrentLevelID]                                    ;; 00:224c $fa $1e $dc
    and  A, A                                          ;; 00:224f $a7
    jr   Z, .jr_00_2254                                ;; 00:2250 $28 $02
    ld   C, $02                                        ;; 00:2252 $0e $02
.jr_00_2254:
    ld   A, [DE]                                       ;; 00:2254 $1a
    and  A, $f0                                        ;; 00:2255 $e6 $f0
    or   A, C                                          ;; 00:2257 $b1
    ld   [DE], A                                       ;; 00:2258 $12
    jp   call_00_0f08_RestoreBank                                  ;; 00:2259 $c3 $08 $0f
.data_00_225c:
    db   $00, $01, $02, $04                            ;; 00:225c ?...

call_00_2260_Entity_SetTVRemoteFlags:
; Switches to the entity list bank and scans through entity entries starting 
; from wDC17_EntityListBankOffset.
; For each entry, checks if the type byte is $12 (ENTITY_TV_REMOTE). If found, jumps 13 bytes 
; forward and compares that value to C.
; When a match is found, modifies a status nibble in the entity’s status table ($D7xx) 
; to set bits $04 while preserving upper bits.
; If no match is found and a $FF terminator is reached, exits by restoring the bank.
; Purpose: Search for an entity of type $12 linked to a particular identifier C and 
; flag it as active/triggered.
    push BC                                            ;; 00:2260 $c5
    ld   A, [wDC16_EntityListBank]                                    ;; 00:2261 $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2264 $cd $ee $0e
    pop  BC                                            ;; 00:2267 $c1
    ld   HL, wDC17_EntityListBankOffset                                     ;; 00:2268 $21 $17 $dc
    ld   A, [HL+]                                      ;; 00:226b $2a
    ld   H, [HL]                                       ;; 00:226c $66
    ld   L, A                                          ;; 00:226d $6f
    ld   B, $01                                        ;; 00:226e $06 $01
.jr_00_2270:
    push HL                                            ;; 00:2270 $e5
    ld   A, [HL]                                       ;; 00:2271 $7e
    cp   A, ENTITY_TV_REMOTE                                       ;; 00:2272 $fe $12
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
    jp   call_00_0f08_RestoreBank                                  ;; 00:2289 $c3 $08 $0f
.jr_00_228c:
    pop  HL                                            ;; 00:228c $e1
    ld   E, B                                          ;; 00:228d $58
    ld   D, HIGH(wD700_EntityFlags)                                        ;; 00:228e $16 $d7
    ld   A, [DE]                                       ;; 00:2290 $1a
    and  A, $f0                                        ;; 00:2291 $e6 $f0
    or   A, $04                                        ;; 00:2293 $f6 $04
    ld   [DE], A                                       ;; 00:2295 $12
    jp   call_00_0f08_RestoreBank                                  ;; 00:2296 $c3 $08 $0f

call_00_2299_Entity_UpdateFlags:
; Uses the current entity’s ID (wDA00_CurrentEntityAddrLo) to compute a pointer 
; into $D7xx status table.
; Replaces the lower nibble of that status byte with C, preserving the upper nibble.
; Purpose: Update the low-nibble state for the current entity’s status entry.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2299 $fa $00 $da
    rlca                                               ;; 00:229c $07
    rlca                                               ;; 00:229d $07
    rlca                                               ;; 00:229e $07
    and  A, $07                                        ;; 00:229f $e6 $07
    ld   L, A                                          ;; 00:22a1 $6f
    ld   H, $00                                        ;; 00:22a2 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:22a4 $11 $01 $da
    add  HL, DE                                        ;; 00:22a7 $19
    ld   L, [HL]                                       ;; 00:22a8 $6e
    ld   H, HIGH(wD700_EntityFlags)                                        ;; 00:22a9 $26 $d7
    ld   A, [HL]                                       ;; 00:22ab $7e
    and  A, $f0                                        ;; 00:22ac $e6 $f0
    or   A, C                                          ;; 00:22ae $b1
    ld   [HL], A                                       ;; 00:22af $77
    ret                                                ;; 00:22b0 $c9

call_00_22b1_Entity_UpdateFlagsAndSetAction:
; Similar indexing logic as 2299, but:
; Compares the current low nibble with C.
; If different, stores the old low nibble to wDAD6_ReturnBank.
; Then calls an alternate-bank routine (call_02_72ac_SetEntityAction)
; Purpose: Detect a change in the entity’s state nibble and, if changed, 
; trigger an alternate-bank handler for state transitions.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:22b1 $fa $00 $da
    rlca                                               ;; 00:22b4 $07
    rlca                                               ;; 00:22b5 $07
    rlca                                               ;; 00:22b6 $07
    and  A, $07                                        ;; 00:22b7 $e6 $07
    ld   L, A                                          ;; 00:22b9 $6f
    ld   H, $00                                        ;; 00:22ba $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:22bc $11 $01 $da
    add  HL, DE                                        ;; 00:22bf $19
    ld   L, [HL]                                       ;; 00:22c0 $6e
    ld   H, HIGH(wD700_EntityFlags)                                        ;; 00:22c1 $26 $d7
    ld   A, [HL]                                       ;; 00:22c3 $7e
    and  A, $0f                                        ;; 00:22c4 $e6 $0f
    cp   A, C                                          ;; 00:22c6 $b9
    ret  Z                                             ;; 00:22c7 $c8
    farcall call_02_72ac_SetEntityAction
    ret                                                ;; 00:22d3 $c9
    
call_00_22d4_Entity_CheckTriggerFlag:
; Get the entity's parameter (C).
; Uses that param to look up a byte in the table at wDCB1_LevelTriggerBuffer.
; Returns with A = value at that slot (flags zero/non-zero).
; Purpose: Check if a flag/slot for this entity is set.
    call call_00_230f_Entity_GetParameterIntoC
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    ld   a,[hl]
    and  a
    ret  

call_00_22e0_Entity_IncrementTriggerFlag:
; Gets entity parameter via 230F.
; If parameter < $10, increments that entity’s slot in wDCB1_LevelTriggerBuffer.
; Purpose: Increment a small counter for this entity (capped at 16 slots).
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    cp   a,$10
    ret  nc
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    inc  [hl]
    ret  

call_00_22ef_Entity_SetTriggerActive:
; Gets entity parameter via 230F.
; If parameter < $10, sets that entity’s slot to 1.
; Purpose: Mark the slot as "active" or "initialized."
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    cp   a,$10
    ret  nc
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    ld   [hl],$01
    ret  

call_00_22ff_Entity_SetTriggerInactive:
; Gets entity parameter via 230F.
; If parameter < $10, clears that slot to 0.
; Purpose: Mark the slot as inactive/cleared.
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    cp   a,$10
    ret  nc
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    ld   [hl],$00
    ret  

call_00_230f_Entity_GetParameterIntoC:
; Switches to the entity list bank (wDC16_EntityListBank).
; Uses wDC17_EntityListBankOffset and the current entity’s ID (wDA00_CurrentEntityAddrLo) to compute 
; an index (C) into the entity list.
; Performs bit shifts and offset calculations to get the entity's parameter in the spawn struct, then switches banks back.
; Returns C = spawn parameter for the entity.
; Purpose: Resolve an entity’s parameter across banks.
    ld   A, [wDC16_EntityListBank]                                    ;; 00:230f $fa $16 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:2312 $cd $ee $0e
    ld   HL, wDC17_EntityListBankOffset                                     ;; 00:2315 $21 $17 $dc
    ld   C, [HL]                                       ;; 00:2318 $4e
    inc  HL                                            ;; 00:2319 $23
    ld   B, [HL]                                       ;; 00:231a $46
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:231b $fa $00 $da
    rlca                                               ;; 00:231e $07
    rlca                                               ;; 00:231f $07
    rlca                                               ;; 00:2320 $07
    and  A, $07                                        ;; 00:2321 $e6 $07
    ld   L, A                                          ;; 00:2323 $6f
    ld   H, $00                                        ;; 00:2324 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:2326 $11 $01 $da
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

call_00_233e_Entity_UpdatePatternedMovement:
; Updates an entity’s velocity counter, uses it as an index into a 
; velocity lookup table (.data_00_23B4_Velocities).
; Depending on a "motion type" flag (0, 1, or 2), it interprets table entries 
; differently (normal, flipped X, flipped Y).
; Computes a signed (Δx, Δy) vector, adds it to the entity’s initial position, 
; and stores the new position into the entity’s X/Y position fields.
; Effectively produces oscillating or patterned movement along a predefined velocity curve.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    inc  [hl]
    ld   a,[hl]
    sub  a,$2E
    jr   nz,.jr_00_2352
    ld   [hl],a
    inc  l
    inc  [hl]
    res  2,[hl]
    dec  l
.jr_00_2352:
    inc  l
    ldd  a,[hl]
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   de,.data_00_23B4_Velocities
    add  hl,de
    cp   a,$00
    jr   z,.jr_00_2381
    cp   a,$01
    jr   z,.jr_00_2379
    cp   a,$02
    jr   z,.jr_00_236F
    ldi  a,[hl]
    cpl  
    inc  a
    ld   c,a
    ld   e,[hl]
    jr   .jr_00_2384
.jr_00_236F:
    ldi  a,[hl]
    cpl  
    inc  a
    ld   e,a
    ld   a,[hl]
    cpl  
    inc  a
    ld   c,a
    jr   .jr_00_2384
.jr_00_2379:
    ld   c,[hl]
    inc  hl
    ld   a,[hl]
    cpl  
    inc  a
    ld   e,a
    jr   .jr_00_2384
.jr_00_2381:
    ld   e,[hl]
    inc  hl
    ld   c,[hl]
.jr_00_2384:
    ld   a,e
    cp   a,$80
    ld   a,$FF
    adc  a,$00
    ld   d,a
    push de
    call call_00_2835_Entity_GetInitialXPos
    pop  hl
    add  hl,de
    push hl
    ld   a,c
    cp   a,$80
    ld   a,$FF
    adc  a,$00
    ld   b,a
    push bc
    call call_00_27f3_Entity_GetInitialYPos
    pop  hl
    add  hl,de
    push hl
    pop  bc
    pop  de
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
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

call_00_2410_Entity_FaceTorwardsPlayer:
; Loads the current entity’s position ($0E/$0F).
; Compares it with the player’s X position (wD80E/F).
; Sets a nearby state byte (L xor $02) to $20 if the player is 
; left of the entity, otherwise $00.
; Purpose: A left/right proximity flag to influence AI.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   c,ENTITY_RIGHT_OF_GEX
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    jr   c,.jr_00_2427
    ld   c,ENTITY_LEFT_OF_GEX
.jr_00_2427:
    ld   a,l
    xor  a,$02
    ld   l,a
    ld   [hl],c
    ret  
    
call_00_242d_Entity_FaceAwayFromPlayer:
; Same comparison as 2410 but reversed:
; Sets the flag to $20 if the player is right of the entity, otherwise $00.
; Purpose: Mirror of the above for right-side checking.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   c,ENTITY_LEFT_OF_GEX
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    jr   c,.jr_00_2444
    ld   c,ENTITY_RIGHT_OF_GEX
.jr_00_2444:
    ld   a,l
    xor  a,$02
    ld   l,a
    ld   [hl],c
    ret  

call_00_2475_Entity_ApplyVerticalVelocity:
; Updates vertical velocity with a clamp (min cap at $C0), then derives a fractional 
; step (shifted velocity), and finally applies it to Y position.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
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
    jp   call_00_250d_Entity_AdjustYPosition                                    ;; 00:2472 $c3 $0d $25

call_00_2475_Entity_ApplyGravityAndSnapToGround:
; Applies gravity to the entity’s vertical velocity (with clamp), integrates it into 
; the entity’s Y position using subpixel precision, and compares against a stored ground reference. 
; If the entity falls past this reference, its Y position is snapped back and velocity is reset to zero.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   a,[hl]
    sub  a,$02
    bit  $7,a
    jr   z,.jr_00_248A
    cp   a,$C0
    jr   nc,.jr_00_248A
    ld   a,$C0
.jr_00_248A:
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
    call call_00_27f3_Entity_GetInitialYPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
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

call_00_24c0_Entity_ApplyXVelocity:
; Accumulates subpixels from X velocity, shifts them into actual pixel delta, and updates X position.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
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
call_00_24df_Entity_AdjustXPosition:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   A, [HL]                                       ;; 00:24e7 $7e
    add  A, C                                          ;; 00:24e8 $81
    ld   [HL+], A                                      ;; 00:24e9 $22
    ld   A, [HL]                                       ;; 00:24ea $7e
    adc  A, B                                          ;; 00:24eb $88
    ld   [HL], A                                       ;; 00:24ec $77
    ret                                                ;; 00:24ed $c9

call_00_24ee_Entity_ApplyYVelocity_NoClip:
; Same logic as call_00_24c0_Entity_ApplyXVelocity but for Y axis. 
; Calls into the common Y position updater (250d).
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
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
call_00_250d_Entity_AdjustYPosition:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   A, [HL]                                       ;; 00:2515 $7e
    add  A, C                                          ;; 00:2516 $81
    ld   [HL+], A                                      ;; 00:2517 $22
    ld   A, [HL]                                       ;; 00:2518 $7e
    adc  A, B                                          ;; 00:2519 $88
    ld   [HL], A                                       ;; 00:251a $77
    ret                                                ;; 00:251b $c9

call_00_251c_Entity_HandleHorizontalBoundingBoxTurnAround:
; Checks if the entity’s horizontal position is within a bounding box. If the position is outside, 
; it updates the entity's facing direction flag and returns a value indicating whether the 
; facing direction was changed.
    call call_00_254a_Entity_AdvancePosition_XDelta                                  ;; 00:251c $cd $4a $25
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:251f $fa $00 $da
    rrca                                               ;; 00:2522 $0f
    and  A, $70                                        ;; 00:2523 $e6 $70
    ld   L, A                                          ;; 00:2525 $6f
    ld   H, $00                                        ;; 00:2526 $26 $00
    ld   BC, wDA1C_EntityBoundingBoxXMax                                     ;; 00:2528 $01 $1c $da
    add  HL, BC                                        ;; 00:252b $09
    ld   C, ENTITY_FACING_LEFT                                        ;; 00:252c $0e $20
    ld   A, [HL+]                                      ;; 00:252e $2a
    sub  A, E                                          ;; 00:252f $93
    ld   A, [HL+]                                      ;; 00:2530 $2a
    sbc  A, D                                          ;; 00:2531 $9a
    jr   C, .jr_00_253e                                ;; 00:2532 $38 $0a
    ld   C, ENTITY_FACING_RIGHT                                        ;; 00:2534 $0e $00
    ld   A, [HL+]                                      ;; 00:2536 $2a
    sub  A, E                                          ;; 00:2537 $93
    ld   A, [HL]                                       ;; 00:2538 $7e
    sbc  A, D                                          ;; 00:2539 $9a
    jr   NC, .jr_00_253e                               ;; 00:253a $30 $02
    xor  A, A                                          ;; 00:253c $af
    ret                                                ;; 00:253d $c9
.jr_00_253e:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                       ;; 00:2546 $7e
    ld   [HL], C                                       ;; 00:2547 $71
    cp   A, C                                          ;; 00:2548 $b9
    ret                                                ;; 00:2549 $c9

call_00_254a_Entity_AdvancePosition_XDelta:
; Calculates X delta based on facing direction and velocity, 
; saves it to wDA13_EntityXVelocityDelta, and advances entity position.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   C, [HL]                                       ;; 00:2552 $4e
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   A, [HL+]                                      ;; 00:255b $2a
    bit  5, C                                          ;; 00:255c $cb $69
    jr   Z, .jr_00_2562                                ;; 00:255e $28 $02
    cpl                                                ;; 00:2560 $2f
    inc  A                                             ;; 00:2561 $3c
.jr_00_2562:
    add  A, [HL]                                       ;; 00:2562 $86 ; ENTITY_FIELD_XVEL_RELATED
    ld   C, A                                          ;; 00:2563 $4f
    and  A, $0f                                        ;; 00:2564 $e6 $0f
    ld   [HL], A                                       ;; 00:2566 $77
    ld   A, C                                          ;; 00:2567 $79
    sra  A                                             ;; 00:2568 $cb $2f
    sra  A                                             ;; 00:256a $cb $2f
    sra  A                                             ;; 00:256c $cb $2f
    sra  A                                             ;; 00:256e $cb $2f
    ld   C, A                                          ;; 00:2570 $4f
    ld   [wDA13_EntityXVelocityDelta], A                                    ;; 00:2571 $ea $13 $da
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

call_00_2588_Entity_ApproachXVelocity:
; Increments/decrements the entity’s X velocity by 1 until it equals a target C.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
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

call_00_259d_Entity_HandleVerticalBoundingBoxTurnAround:
; This function integrates the entity's velocity and checks the bounding box 
; to update the entity's state based on its velocity and position.
    call call_00_25CB_Entity_IntegrateVelocity_Helper
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA20_EntityBoundingBoxYMin
    add  hl,bc
    ld   c,ENTITY_FACING_RIGHT
    ldi  a,[hl]
    sub  e
    ldi  a,[hl]
    sbc  d
    jr   c,call_00_25BF_Entity_SetAndCompareFacingDirection
    ld   c,ENTITY_FACING_VERTICAL_FLIP
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jr   nc,call_00_25BF_Entity_SetAndCompareFacingDirection
    xor  a
    ret  

call_00_25BF_Entity_SetAndCompareFacingDirection:
; Writes a new state flag into entity and returns whether it changed.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   a,[hl]
    ld   [hl],c
    cp   c
    ret  

call_00_25CB_Entity_IntegrateVelocity_Helper:
; Internal helper for fractional velocity integration (handles facing, 
; subpixel carry, writes X position + velocity delta to DE).
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   c,[hl]
    ld   a,l
    xor  a,$10
    ld   l,a
    ldi  a,[hl]
    bit  6,c
    jr   nz,.jr_00_25DF
    cpl  
    inc  a
.jr_00_25DF:
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

call_00_2602_Entity_ApproachYVelocity:
; Compares current Y velocity against a target (C).
; Increments or decrements the Y velocity by 1 until it matches.
; This gives smooth acceleration/deceleration to the desired speed.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   a,[hl]
    cp   c
    ret  z
    jr   c,.jr_00_2613
    dec  [hl]
    ld   a,[hl]
    cp   c
    ret  
.jr_00_2613:
    inc  [hl]
    ld   a,[hl]
    cp   c
    ret  

call_00_2879_Entity_HandleHorizontalBoundingBoxStop:
; Compares the entity's X position with the bounding box limits (XMin and XMax) and adjusts 
; the position if necessary, updating the velocity delta and position.
    call call_00_2857_Entity_GetBoundingBoxXMin
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ldi  a,[hl]
    sub  e
    ldd  a,[hl]
    sbc  d
    jr   c,.jr_00_2639
    call call_00_2846_Entity_GetBoundingBoxXMax
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ldi  a,[hl]
    sub  e
    ldd  a,[hl]
    sbc  d
    ret  c
    dec  de
.jr_00_2639:
    ld   a,e
    sub  [hl]
    ld   [hl],e
    inc  hl
    ld   [hl],d
    ld   hl,wDA13_EntityXVelocityDelta
    add  [hl]
    ld   [hl],a
    xor  a
    ret  

call_00_2645_Entity_AdjustXAgainstBounds:
; Adjusts an entity’s X velocity or position against bounding box edges.
; Depending on facing bit 7 (a), it computes whether the entity should 
; clamp its movement using XMin or XMax bounds.
; Writes the corrected position and adjusts velocity deltas accordingly.
    bit  $7,a
    jr   nz,.jr_00_265B
    ld   b,$00
    call call_00_2846_Entity_GetBoundingBoxXMax
    call call_00_2678_Entity_AddOffsetToXPos
    ld   a,c
    sub  e
    ld   a,b
    sbc  d
    jr   c,.jr_00_266E
    ld   c,e
    ld   b,d
    jr   .jr_00_266E
.jr_00_265B:
    xor  a
    sub  c
    ld   c,a
    ld   b,$FF
    call call_00_2857_Entity_GetBoundingBoxXMin
    call call_00_2678_Entity_AddOffsetToXPos
    ld   a,e
    sub  c
    ld   a,d
    sbc  b
    jr   c,.jr_00_266E
    ld   c,e
    ld   b,d
.jr_00_266E:
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

call_00_2678_Entity_AddOffsetToXPos:
; Helper: adds (c,b) offset to the entity’s current X position.
; Used by the bounding adjustment routines.
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_XPOS
    ldi  a,[hl]
    add  c
    ld   c,a
    ld   a,[hl]
    adc  b
    ld   b,a
    ret  

call_00_2687_Entity_AdjustYAgainstBounds:
; Y-axis version of 2645.
; Uses YMin / YMax bounding box depending on facing bit 7, applies corrections, 
; updates entity position, and checks velocity deltas.
    bit  $7,a
    jr   nz,.jr_00_269D
    ld   b,$00
    call call_00_2804_Entity_GetBoundingBoxYMin
    call call_00_26BA_Entity_AddOffsetToYPos
    ld   a,c
    sub  e
    ld   a,b
    sbc  d
    jr   c,.jr_00_26B0
    ld   c,e
    ld   b,d
    jr   .jr_00_26B0
.jr_00_269D:
    xor  a
    sub  c
    ld   c,a
    ld   b,$FF
    call call_00_2815_Entity_GetBoundingBoxYMax
    call call_00_26BA_Entity_AddOffsetToYPos
    ld   a,e
    sub  c
    ld   a,d
    sbc  b
    jr   c,.jr_00_26B0
    ld   c,e
    ld   b,d
.jr_00_26B0:
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

call_00_26BA_Entity_AddOffsetToYPos:
; Helper: adds (c,b) offset to the entity’s current Y position.
; Parallel to 2678.
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_YPOS
    ldi  a,[hl]
    add  c
    ld   c,a
    ld   a,[hl]
    adc  b
    ld   b,a
    ret  

call_00_26c9_Entity_CarryPlayerHorizontally:
; Complex: Reads entity’s X velocity, some state flags, and bounding values.
; Compares against global state vars (wDC7B_CurrentEntityAddrLoAlt, wDC7B_CurrentEntityAddrLoAlt2).
; If conditions match, applies an adjustment to the player’s X position relative to the entity (e.g. conveyor belts, pushers).
; Appears to handle environmental effects that "move the player."
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
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
    jr   nz,.jr_00_26E3
    xor  a
    sub  c
    ld   c,a
.jr_00_26E3:
    ld   a,l
    and  a,$E0
    ld   hl,wDC7B_CurrentEntityAddrLoAlt
    cp   [hl]
    jr   nz,call_00_26F1_Entity_UpdatePlayerXPosition
    ld   a,c
    ld   [wDC85],a
    ret  

call_00_26F1_Entity_UpdatePlayerXPosition:
; Update Player X Relative to Entity
; Compares player position to the entity and adjusts or clamps X.
    ld   hl,wDC7B_CurrentEntityAddrLoAlt2
    cp   [hl]
    ret  nz
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WIDTH
    ld   a,[wD80E_PlayerXPosition]
    sub  e
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  d
    jr   c,call_00_2714_Entity_ClampPlayerXPosition
    ld   a,e
    add  [hl]
    ld   [wD80E_PlayerXPosition],a
    ld   a,d
    adc  a,$00
    ld   [wD80E_PlayerXPosition+1],a
    ret  

call_00_2714_Entity_ClampPlayerXPosition:
; Clamp Player X
; When the player is too far left of the entity, this clamps the player’s X position 
; to just inside the entity boundary (adds one to the entity’s stored width, then 
; subtracts from the delta).
    ld   c,[hl]
    inc  c
    ld   a,e
    sub  c
    ld   [wD80E_PlayerXPosition],a
    ld   a,d
    sbc  a,$00
    ld   [wD80E_PlayerXPosition+1],a
    ret  

call_00_2722_Entity_IsNearPlayer:
; Performs a spatial proximity and overlap check between the player and the current entity. 
; Specifically, it:
; 1. Compares Y positions of the player and entity to see if they're roughly aligned 
;    vertically (i.e., close enough on the Y-axis).
; 2. If so, it checks whether the player's X position falls within the entity's bounding 
;    box (XMin to XMax).
; 3. Returns A = 1 if the player is inside the entity’s horizontal bounding box and aligned 
;    vertically; else returns A = 0.
; Checks if the player is vertically aligned with the entity and within its horizontal bounding box — 
; essentially determining whether the player is "standing near" or overlapping with the entity. 
; Likely used to trigger proximity-based events like interactions or collisions.
    ld   HL, wD810_PlayerYPosition                                     ;; 00:2722 $21 $10 $d8
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2725 $fa $00 $da
    or   A, ENTITY_FIELD_YPOS                                        ;; 00:2728 $f6 $10
    ld   C, A                                          ;; 00:272a $4f
    ld   B, HIGH(wD800_EntityMemory)                                        ;; 00:272b $06 $d8
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
    call call_00_2857_Entity_GetBoundingBoxXMin                                  ;; 00:2746 $cd $57 $28
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2749 $fa $0e $d8
    sub  A, E                                          ;; 00:274c $93
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:274d $fa $0f $d8
    sbc  A, D                                          ;; 00:2750 $9a
    jr   C, .jr_00_2764                                ;; 00:2751 $38 $11
    call call_00_2846_Entity_GetBoundingBoxXMax                                  ;; 00:2753 $cd $46 $28
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2756 $fa $0e $d8
    sub  A, E                                          ;; 00:2759 $93
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:275a $fa $0f $d8
    sbc  A, D                                          ;; 00:275d $9a
    jr   NC, .jr_00_2764                               ;; 00:275e $30 $04
    ld   A, $01                                        ;; 00:2760 $3e $01
    and  A, A                                          ;; 00:2762 $a7
    ret                                                ;; 00:2763 $c9
.jr_00_2764:
    xor  A, A                                          ;; 00:2764 $af
    ret                                                ;; 00:2765 $c9

call_00_2766_Entity_ResetYPosIfBelowInitial:
; Gets entity’s initial Y position and compares it to current.
; If entity has moved below its starting point, snaps it back up to that initial Y and 
; clears a related state flag.
; Prevents jumping entities from landing below the floor
    call call_00_27f3_Entity_GetInitialYPos                                  ;; 00:2766 $cd $f3 $27
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
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

call_00_2780_Entity_CheckIfOffscreenBelow:
; Loads current map scroll position + offset, compares against entity’s Y position.
; Likely used for despawning when off-screen below the camera.
    ld   hl,wDBFB_YPositionInMap
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    ld   de,$00B0
    add  hl,de
    ld   e,l
    ld   d,h
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  

call_00_2799_Entity_UpdateYFromXDisplacement:
; Computes horizontal distance between entity’s initial and current X.
; If negative, takes absolute value. Then halves that distance.
; Uses it as an offset to add to the entity’s initial Y position, and updates the current Y accordingly.
; Looks like it enforces an arc/trajectory path (parabola-like).
    call call_00_2835_Entity_GetInitialXPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ldi  a,[hl]
    sub  e
    ld   e,a
    ld   a,[hl]
    sbc  d
    ld   d,a
    jr   nc,.jr_00_27B3
    xor  a
    sub  e
    ld   e,a
    ld   a,$00
    sbc  d
    ld   d,a
.jr_00_27B3:
    srl  d
    rr   e
    push de
    call call_00_27f3_Entity_GetInitialYPos
    pop  hl
    add  hl,de
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_YPOS
    ld   a,l
    ld   [de],a
    inc  e
    ld   a,h
    ld   [de],a
    ret  

call_00_2780_Entity_CheckIfOffscreenAbove:
; Sets entity’s Y position relative to the map scroll (YPositionInMap - 0x14).
; If underflows, clamps to zero.
; Likely spawns or aligns the entity a bit above the current viewport.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   a,[wDBFB_YPositionInMap]
    sub  a,$14
    ldi  [hl],a
    ld   a,[wDBFB_YPositionInMap+1]
    sbc  a,$00
    ld   [hl],a
    ret  nc
    xor  a
    ldd  [hl],a
    ld   [hl],a
    ret  

call_00_27e4_Entity_ResetToInitialYPos:
    call call_00_27f3_Entity_GetInitialYPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_27f3_Entity_GetInitialYPos:
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:27f3 $fa $00 $da
    rrca                                               ;; 00:27f6 $0f
    and  A, $70                                        ;; 00:27f7 $e6 $70
    ld   L, A                                          ;; 00:27f9 $6f
    ld   H, $00                                        ;; 00:27fa $26 $00
    ld   DE, wDA26_EntityInitialYPos                                     ;; 00:27fc $11 $26 $da
    add  HL, DE                                        ;; 00:27ff $19
    ld   A, [HL+]                                      ;; 00:2800 $2a
    ld   E, A                                          ;; 00:2801 $5f
    ld   D, [HL]                                       ;; 00:2802 $56
    ret                                                ;; 00:2803 $c9

call_00_2804_Entity_GetBoundingBoxYMin:
; This function retrieves the minimum Y position of the entity's bounding box.
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA20_EntityBoundingBoxYMin
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2815_Entity_GetBoundingBoxYMax:
; This function retrieves the maximum Y position of the entity's bounding box.
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA22_EntityBoundingBoxYMax
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2826_Entity_ResetToInitialXPos:
; Gets entity's initial x pos and stores it in the entity’s $D8:xx0E slot (X position).
    call call_00_2835_Entity_GetInitialXPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_2835_Entity_GetInitialXPos:
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA24_EntityInitialXPos
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2846_Entity_GetBoundingBoxXMax:
; This function retrieves the maximum X position of the entity's bounding box.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2846 $fa $00 $da
    rrca                                               ;; 00:2849 $0f
    and  A, $70                                        ;; 00:284a $e6 $70
    ld   L, A                                          ;; 00:284c $6f
    ld   H, $00                                        ;; 00:284d $26 $00
    ld   DE, wDA1C_EntityBoundingBoxXMax                                     ;; 00:284f $11 $1c $da
    add  HL, DE                                        ;; 00:2852 $19
    ld   A, [HL+]                                      ;; 00:2853 $2a
    ld   E, A                                          ;; 00:2854 $5f
    ld   D, [HL]                                       ;; 00:2855 $56
    ret                                                ;; 00:2856 $c9

call_00_2857_Entity_GetBoundingBoxXMin:
; This function retrieves the minimum X position of the entity's bounding box.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2857 $fa $00 $da
    rrca                                               ;; 00:285a $0f
    and  A, $70                                        ;; 00:285b $e6 $70
    ld   L, A                                          ;; 00:285d $6f
    ld   H, $00                                        ;; 00:285e $26 $00
    ld   DE, wDA1E_EntityBoundingBoxXMin                                     ;; 00:2860 $11 $1e $da
    add  HL, DE                                        ;; 00:2863 $19
    ld   A, [HL+]                                      ;; 00:2864 $2a
    ld   E, A                                          ;; 00:2865 $5f
    ld   D, [HL]                                       ;; 00:2866 $56
    ret                                                ;; 00:2867 $c9

call_00_2868_Entity_SetBoundingBoxXMax:
; This function sets the maximum X position of the entity's bounding box
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA1C_EntityBoundingBoxXMax
    add  hl,bc
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_2879_Entity_SetBoundingBoxXMin:
; This function sets the minimum X position of the entity's bounding box
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA1E_EntityBoundingBoxXMin
    add  hl,bc
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_288a_Entity_SetCollisionTypeNone:
    ld   C, COLLISION_TYPE_NONE                                       ;; 00:288a $0e $00
call_00_288c_Entity_SetCollisionType:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COLLISION_TYPE
    ld   [HL], C                                       ;; 00:2894 $71
    ret                                                ;; 00:2895 $c9

call_00_2896_Entity_SetCooldownTimer:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   [hl],c
    ret  

call_00_28a0_Entity_GetCooldownTimer:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   a,[hl]
    ret  

call_00_28aa_Entity_Set16:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_DAMAGE_STATE
    ld   [HL], C
    ret  

call_00_28b4_Entity_Get16:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_DAMAGE_STATE
    ld   a,[hl]
    ret  

call_00_28be_Entity_GetXVelocity:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   A, [HL]
    ret  

call_00_28c8_Entity_SetXVelocity:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   [HL], C
    ret  

call_00_28d2_Entity_GetYVelocity:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   A, [HL]
    ret  

call_00_28dc_Entity_SetYVelocity:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   [HL], C
    ret  

call_00_28e6_Entity_CheckIfXVelocityIsZero:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   a,[hl]
    and  a
    ret  

call_00_28f1_Entity_CheckIfYVelocityIsZero:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   a,[hl]
    and  a
    ret  

call_00_28fc_Entity_UpdateMiscFlags:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_FLAGS
    ld   a,[hl]
    inc  [hl]
    and  a,$03
    ld   l,a
    ld   h,$00
    add  hl,de
    ld   c,[hl]

call_00_290d_Entity_SetMiscTimer:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_TIMER
    ld   [HL], C                                       ;; 00:2915 $71
    ret                                                ;; 00:2916 $c9

call_00_2917_Entity_CheckIfMiscTimerIsZero:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_TIMER
    ld   a,[hl]
    and  a
    ret  

call_00_2922_Entity_MiscTimerCountdown:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_TIMER
    ld   A, [HL]                                       ;; 00:292a $7e
    and  A, A                                          ;; 00:292b $a7
    ret  Z                                             ;; 00:292c $c8
    dec  [HL]                                          ;; 00:292d $35
    ld   A, [HL]                                       ;; 00:292e $7e
    ret                                                ;; 00:292f $c9

call_00_2930_Entity_SetId:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   [HL], C                                       ;; 00:2938 $71
    ret                                                ;; 00:2939 $c9

call_00_293a_Entity_GetId:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   a,[hl]
    ret  

call_00_2944_Entity_SetWidth:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WIDTH
    ld   [HL], C                                       ;; 00:294c $71
    ret                                                ;; 00:294d $c9

call_00_294e_Entity_SetHeight:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_HEIGHT
    ld   [HL], C                                       ;; 00:2956 $71
    ret                                                ;; 00:2957 $c9

call_00_2958_Entity_SetFacingDirection:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   [HL], C                                       ;; 00:2960 $71
    ret                                                ;; 00:2961 $c9

call_00_2962_Entity_GetActionId:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_ID
    ld   A, [HL]                                       ;; 00:296a $7e
    ret                                                ;; 00:296b $c9

call_00_296c_Entity_GetSpriteCounter:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_SPRITE_COUNTER
    ld   a,[hl]
    ret  

call_00_2976_Entity_GetFacingDirection:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                       ;; 00:297e $7e
    ret                                                ;; 00:297f $c9

call_00_2980_Entity_SetMiscFlags:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_FLAGS
    ld   [HL], C                                       ;; 00:2988 $71
    ret                                                ;; 00:2989 $c9

call_00_298a_Entity_GetMiscFlags:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_FLAGS
    ld   A, [HL]                                       ;; 00:2992 $7e
    and  A, A                                          ;; 00:2993 $a7
    ret                                                ;; 00:2994 $c9

call_00_2995_Entity_GetActionId:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_ID
    ld   a,[hl]
    ret  

call_00_299f_Entity_TurnAround:
; flips facing direction from $00 to $20 or $20 to $00
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                       ;; 00:29a7 $7e
    xor  A, ENTITY_FACING_LEFT                                        ;; 00:29a8 $ee $20
    ld   [HL], A                                       ;; 00:29aa $77
    ret                                                ;; 00:29ab $c9

call_00_29ac_Entity_IsFacingPlayer:
; Compares entity’s facing direction with the direction relative to the player.
; Returns if they match.
; Used for checks like "is the entity facing the player?"
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    ret  

call_00_29b7_Entity_SearchForAndGetActionID:
; Starts at entity table base $D840.
; Iterates through entries (+20h each = 32 bytes per entity) comparing [HL] to register C.
; If a match is found, jumps to call_00_29C8_Entity_FetchActionID.
; If none, sets C=$FF and returns.
    ld   h, HIGH(wD840_EntityMemoryAfterPlayer)
    ld   l, LOW(wD840_EntityMemoryAfterPlayer)
.jr_00_29BB:
    ld   a,[hl]
    cp   c
    jr   z,call_00_29C8_Entity_FetchActionID
    ld   a,l
    add  a,$20
    ld   l,a
    jr   nz,.jr_00_29BB
    ld   c,$FF
    ret  

call_00_29C8_Entity_FetchActionID:
; When a match is found, loads the action id for this entity into C.
    ld   a,l
    or   a,$01
    ld   l,a
    ld   c,[hl]
    ret  

call_00_29ce_Entity_CheckExists:
; Almost identical to 29b7, but:
; Returns immediately if found (ret Z).
; If none found, loads $01 into A, ANDs A with itself, and returns 
; (effectively a false indicator).
    ld   H, HIGH(wD840_EntityMemoryAfterPlayer)                                        ;; 00:29ce $26 $d8
    ld   L, LOW(wD840_EntityMemoryAfterPlayer)                                        ;; 00:29d0 $2e $40
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
    
call_00_29df_Entity_SetFacingUnkFlag:
; Computes HL = $D80D + current entity index.
; Sets bit 7 of [HL] (marking entity as "active," "visible," or "flagged").
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    set  7,[hl]
    ret  

call_00_29ea_Entity_ClearFacingUnkFlag:
; Same indexing, but clears bit 7 instead of setting it.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    res  7,[hl]
    ret  

call_00_29f5_Entity_ClearGraphicsFlag4AndCheck:
; Gets entity entry byte at $D805+index.
; Clears bit 4 in memory.
; Returns with carry based on the old bit 4 state (bit 4,A).
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_GRAPHICS_FLAGS
    ld   A, [HL]                                       ;; 00:29fd $7e
    res  4, [HL]                                       ;; 00:29fe $cb $a6
    bit  4, A                                          ;; 00:2a00 $cb $67
    ret                                                ;; 00:2a02 $c9

call_00_2a03_ResetEntityListIndex:
; Derives a small index from wDA00_CurrentEntityAddrLo by rotating left and masking.
; Writes 0 to wDA01_EntityListIndexesForCurrentEntities + index.
; Likely clears a small per-entity temporary slot.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2a03 $fa $00 $da
    rlca                                               ;; 00:2a06 $07
    rlca                                               ;; 00:2a07 $07
    rlca                                               ;; 00:2a08 $07
    and  A, $07                                        ;; 00:2a09 $e6 $07
    ld   L, A                                          ;; 00:2a0b $6f
    ld   H, $00                                        ;; 00:2a0c $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:2a0e $11 $01 $da
    add  HL, DE                                        ;; 00:2a11 $19
    ld   [HL], $00                                     ;; 00:2a12 $36 $00
    ret                                                ;; 00:2a14 $c9

call_00_2a15_CheckCameraOverlapBoundingBox:
; This function checks if the camera intersects with the entity’s bounding box, 
; comparing both X and Y boundaries. Returns carry if overlap fails, else returns normally.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2a15 $fa $00 $da
    rrca                                               ;; 00:2a18 $0f
    and  A, $70                                        ;; 00:2a19 $e6 $70
    ld   L, A                                          ;; 00:2a1b $6f
    ld   H, $00                                        ;; 00:2a1c $26 $00
    ld   DE, wDA1C_EntityBoundingBoxXMax                                     ;; 00:2a1e $11 $1c $da
    add  HL, DE                                        ;; 00:2a21 $19
    ld   A, [HL+]                                      ;; 00:2a22 $2a
    ld   E, A                                          ;; 00:2a23 $5f
    ld   A, [HL+]                                      ;; 00:2a24 $2a
    ld   D, A                                          ;; 00:2a25 $57
    ld   A, [HL+]                                      ;; 00:2a26 $2a
    ld   C, A                                          ;; 00:2a27 $4f
    ld   A, [HL+]                                      ;; 00:2a28 $2a
    ld   B, A                                          ;; 00:2a29 $47
    ld   HL, wDA14_CameraPos_Left                                     ;; 00:2a2a $21 $14 $da
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
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2a39 $fa $00 $da
    rrca                                               ;; 00:2a3c $0f
    and  A, $70                                        ;; 00:2a3d $e6 $70
    ld   L, A                                          ;; 00:2a3f $6f
    ld   H, $00                                        ;; 00:2a40 $26 $00
    ld   DE, wDA20_EntityBoundingBoxYMin                                     ;; 00:2a42 $11 $20 $da
    add  HL, DE                                        ;; 00:2a45 $19
    ld   A, [HL+]                                      ;; 00:2a46 $2a
    ld   E, A                                          ;; 00:2a47 $5f
    ld   A, [HL+]                                      ;; 00:2a48 $2a
    ld   D, A                                          ;; 00:2a49 $57
    ld   A, [HL+]                                      ;; 00:2a4a $2a
    ld   C, A                                          ;; 00:2a4b $4f
    ld   A, [HL+]                                      ;; 00:2a4c $2a
    ld   B, A                                          ;; 00:2a4d $47
    ld   HL, wDA18_CameraPos_Top                                     ;; 00:2a4e $21 $18 $da
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

call_00_2a5d_Entity_CheckGraphicsFlag2:
; Computes HL = D805 + current entity index.
; Tests bit 2 of the entity’s flags.
; Purpose: Checks a particular state flag (likely "grounded," "active," or similar).
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_GRAPHICS_FLAGS
    bit  2, [HL]                                       ;; 00:2a65 $cb $56
    ret                                                ;; 00:2a67 $c9

call_00_2a68_Entity_ComputeXDistanceFromPlayer:
; Calculates the X-distance vector between the player (wD80E/F) and the current entity’s position (D80E + offset).
; Normalizes the sign: if negative, flips and sets C=$20 to indicate direction.
; Stores the horizontal difference in wDA11_EntityXDistFromPlayer
; and direction in wDA12_EntityDirectionRelativeToPlayer, and returns.
; Purpose: Prepares relative X-direction info for later checks.
    ld   C, ENTITY_LEFT_OF_GEX                                        ;; 00:2a68 $0e $00
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:2a72 $fa $0e $d8
    sub  A, [HL]                                       ;; 00:2a75 $96
    ld   E, A                                          ;; 00:2a76 $5f
    inc  HL                                            ;; 00:2a77 $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:2a78 $fa $0f $d8
    sbc  A, [HL]                                       ;; 00:2a7b $9e
    ld   D, A                                          ;; 00:2a7c $57
    jr   NC, .jr_00_2a88                               ;; 00:2a7d $30 $09
    xor  A, A                                          ;; 00:2a7f $af
    sub  A, E                                          ;; 00:2a80 $93
    ld   E, A                                          ;; 00:2a81 $5f
    ld   A, $00                                        ;; 00:2a82 $3e $00
    sbc  A, D                                          ;; 00:2a84 $9a
    ld   D, A                                          ;; 00:2a85 $57
    ld   C, ENTITY_RIGHT_OF_GEX                                        ;; 00:2a86 $0e $20
.jr_00_2a88:
    ld   A, D                                          ;; 00:2a88 $7a
    and  A, A                                          ;; 00:2a89 $a7
    ld   A, E                                          ;; 00:2a8a $7b
    jr   Z, .jr_00_2a8f                                ;; 00:2a8b $28 $02
    ld   A, $ff                                        ;; 00:2a8d $3e $ff
.jr_00_2a8f:
    ld   [wDA11_EntityXDistFromPlayer], A                                    ;; 00:2a8f $ea $11 $da
    ld   B, A                                          ;; 00:2a92 $47
    ld   A, C                                          ;; 00:2a93 $79
    ld   [wDA12_EntityDirectionRelativeToPlayer], A                                    ;; 00:2a94 $ea $12 $da
    ret                                                ;; 00:2a97 $c9

call_00_2a98_RaStatueEntity_PlayerInteraction:
; Resolves the entity's parameter, computes a pointer to an entity’s bounding box/metadata in memory.
; Compares the player’s X/Y positions against that entity’s bounding box (series of sub/sbc, add, cp checks).
; If inside bounds, copies several bytes from the entity’s data into the current entity’s D8xx structure and 
; triggers a banked function (call_02_72ac_SetEntityAction)
; Purpose: Detects when the player collides with or interacts with a special entity and dispatches a handler.
    push de
    call call_00_230f_Entity_GetParameterIntoC
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
    ld   a,[wD80E_PlayerXPosition+1]
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
    ld   a,[wD810_PlayerYPosition+1]
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
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_MISC_TIMER
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
    farcall call_02_72ac_SetEntityAction
    ret  

call_00_2afc_FindFreeEntitySlot:
; Iterates through all entity slots ($D840… step $20).
; Finds the first free slot (checks for inc A; jr NZ to catch zero).
; Returns A=D as 0 if none found.
; Purpose: Locate a free entry in the entity table.
    ld   H, HIGH(wD800_EntityMemory)                                        ;; 00:2afc $26 $d8
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

call_00_2b10_Entity_FindDuplicateInstance:
; Iterates through a block of entity slots in WRAM.
; Compares each entry’s ID and list index against the current entity.
; If a match is found, returns success (A=1).
; Basically: "does another instance of this entity already exist?"
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2b10 $fa $00 $da
    rlca                                               ;; 00:2b13 $07
    rlca                                               ;; 00:2b14 $07
    rlca                                               ;; 00:2b15 $07
    and  A, $07                                        ;; 00:2b16 $e6 $07
    ld   L, A                                          ;; 00:2b18 $6f
    ld   H, $00                                        ;; 00:2b19 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:2b1b $11 $01 $da
    add  HL, DE                                        ;; 00:2b1e $19
    ld   B, [HL]                                       ;; 00:2b1f $46
    ld   H, HIGH(wD800_EntityMemory)                                        ;; 00:2b20 $26 $d8
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

call_00_2b3d_ClearAllEntitySlots:
; Iterates through entity slots in increments of $20, checking each slot in wD8xx. 
; If the slot value isn’t $FF (active), it clears the entry. 
; Restores wDA00_CurrentEntityAddrLo afterward. Essentially sweeps all entity entries and deactivates them.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2b3d $fa $00 $da
    push AF                                            ;; 00:2b40 $f5
    ld   A, $20                                        ;; 00:2b41 $3e $20
.jr_00_2b43:
    ld   [wDA00_CurrentEntityAddrLo], A                                    ;; 00:2b43 $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                                        ;; 00:2b46 $f6 $00
    ld   L, A                                          ;; 00:2b48 $6f
    ld   H, HIGH(wD800_EntityMemory)                                        ;; 00:2b49 $26 $d8
    ld   A, [HL]                                       ;; 00:2b4b $7e
    cp   A, $ff                                        ;; 00:2b4c $fe $ff
    call NZ, call_00_2b5d_ClearEntitySlot                              ;; 00:2b4e $c4 $5d $2b
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2b51 $fa $00 $da
    add  A, $20                                        ;; 00:2b54 $c6 $20
    jr   NZ, .jr_00_2b43                               ;; 00:2b56 $20 $eb
    pop  AF                                            ;; 00:2b58 $f1
    ld   [wDA00_CurrentEntityAddrLo], A                                    ;; 00:2b59 $ea $00 $da
    ret                                                ;; 00:2b5c $c9

call_00_2b5d_ClearEntitySlot:
; Marks the current entity slot as inactive by writing $FF to wD8xx. Then computes a related index 
; from the slot address to access another table (wDA01_EntityListIndexesForCurrentEntities → wD7xx) and clears bit 6 of its status 
; byte—likely removing an "active" or "visible" flag for that entity.
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_ENTITY_ID
    ld   [HL], $ff                                     ;; 00:2b65 $36 $ff
    ld   A, L                                          ;; 00:2b67 $7d
    rlca                                               ;; 00:2b68 $07
    rlca                                               ;; 00:2b69 $07
    rlca                                               ;; 00:2b6a $07
    and  A, $07                                        ;; 00:2b6b $e6 $07
    ld   L, A                                          ;; 00:2b6d $6f
    ld   H, $00                                        ;; 00:2b6e $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:2b70 $11 $01 $da
    add  HL, DE                                        ;; 00:2b73 $19
    ld   L, [HL]                                       ;; 00:2b74 $6e
    ld   H, HIGH(wD700_EntityFlags)                                        ;; 00:2b75 $26 $d7
    res  6, [HL]                                       ;; 00:2b77 $cb $b6
    ret                                                ;; 00:2b79 $c9

call_00_2b7a_DeactivateEntity:
; Calls call_00_2b80_DeactivateEntitySlot (sets slot to $FF), then jumps to call_00_2b94_ClearEntityFlags (zeroes a related entry in wD7xx). 
; Used as a branch to fully clear an entity before continuing.
    call call_00_2b80_DeactivateEntitySlot                                  ;; 00:2b7a $cd $80 $2b
    jp   call_00_2b94_ClearEntityFlags                                    ;; 00:2b7d $c3 $94 $2b

call_00_2b80_DeactivateEntitySlot:
; Writes $FF to the current entity’s wD8xx slot. This is a lightweight variant 
; of call_00_2b5d without touching flags.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   [HL], $ff                                     ;; 00:2b88 $36 $ff
    ret                                                ;; 00:2b8a $c9

call_00_2b8b_AttemptToSetEntityFlagsTo50:
; Get the entity's collision flags, tests bit 6 of A. If clear, 
; jumps to call_00_2b94_ClearEntityFlags (zero related data). If set, 
; jumps to call_00_2ba9_SetEntityFlagsTo50 to initialize a 
; status value. Used to decide whether to zero or set $50.
    call call_00_35e8_GetEntityCollisionFlags                                  ;; 00:2b8b $cd $e8 $35
    bit  6, A                                          ;; 00:2b8e $cb $77
    jr   Z, call_00_2b94_ClearEntityFlags                                 ;; 00:2b90 $28 $02
    jr   call_00_2ba9_SetEntityFlagsTo50                                  ;; 00:2b92 $18 $15

call_00_2b94_ClearEntityFlags:
; Computes an index from the entity address and writes $00 to a corresponding wD7xx status 
; byte—used to mark an entity as inactive or reset its state.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2b94 $fa $00 $da
    rlca                                               ;; 00:2b97 $07
    rlca                                               ;; 00:2b98 $07
    rlca                                               ;; 00:2b99 $07
    and  A, $07                                        ;; 00:2b9a $e6 $07
    ld   L, A                                          ;; 00:2b9c $6f
    ld   H, $00                                        ;; 00:2b9d $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:2b9f $11 $01 $da
    add  HL, DE                                        ;; 00:2ba2 $19
    ld   L, [HL]                                       ;; 00:2ba3 $6e
    ld   H, HIGH(wD700_EntityFlags)                                        ;; 00:2ba4 $26 $d7
    ld   [HL], $00                                     ;; 00:2ba6 $36 $00
    ret                                                ;; 00:2ba8 $c9

call_00_2ba9_SetEntityFlagsTo50:
; Like call_00_2b94_ClearEntityFlags, but writes $50 instead of $00. 
; Likely initializes or flags an entity as partially active.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2ba9 $fa $00 $da
    rlca                                               ;; 00:2bac $07
    rlca                                               ;; 00:2bad $07
    rlca                                               ;; 00:2bae $07
    and  A, $07                                        ;; 00:2baf $e6 $07
    ld   L, A                                          ;; 00:2bb1 $6f
    ld   H, $00                                        ;; 00:2bb2 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities                                     ;; 00:2bb4 $11 $01 $da
    add  HL, DE                                        ;; 00:2bb7 $19
    ld   L, [HL]                                       ;; 00:2bb8 $6e
    ld   H, HIGH(wD700_EntityFlags)                                        ;; 00:2bb9 $26 $d7
    ld   [HL], $50                                     ;; 00:2bbb $36 $50
    ret                                                ;; 00:2bbd $c9

call_00_2bbe_AttemptToConvertEntityToCollectible:
; Full entity creation routine:
; If collision flags are $ff, clear the entity without spawning a collectible
; If not $FF and bit 6 is set, sets up multiple entity parameters 
; (EntitySetId, Entity_Set14, palette, facing direction, etc.).
; Updates its status to $50, resets return bank, calls an alternate bank function (call_02_72ac_SetEntityAction), 
; and copies a palette (call_00_2c20_Entity_CopyPaletteToBuffer).
; This is the main "spawn/setup entity" function.
    call call_00_35e8_GetEntityCollisionFlags                                  ;; 00:2bbe $cd $e8 $35
    cp   A, $ff                                        ;; 00:2bc1 $fe $ff
    jr   Z, call_00_2b7a_DeactivateEntity                                 ;; 00:2bc3 $28 $b5
    bit  6, A                                          ;; 00:2bc5 $cb $77
    jr   Z, call_00_2b7a_DeactivateEntity                                 ;; 00:2bc7 $28 $b1
    ld   C, ENTITY_FLY_COIN_SPAWN                                        ;; 00:2bc9 $0e $02
    call call_00_2930_Entity_SetId                                  ;; 00:2bcb $cd $30 $29
    ld   C, COLLISION_TYPE_FLY_COIN                                        ;; 00:2bce $0e $08
    call call_00_288c_Entity_SetCollisionType                                  ;; 00:2bd0 $cd $8c $28
    ld   C, $12                                        ;; 00:2bd3 $0e $12
    call call_00_2944_Entity_SetWidth                                  ;; 00:2bd5 $cd $44 $29
    ld   C, $12                                        ;; 00:2bd8 $0e $12
    call call_00_294e_Entity_SetHeight                                  ;; 00:2bda $cd $4e $29
    ld   C, ENTITY_FACING_RIGHT                                        ;; 00:2bdd $0e $00
    call call_00_2958_Entity_SetFacingDirection                                  ;; 00:2bdf $cd $58 $29
    ld   C, $01                                        ;; 00:2be2 $0e $01
    call call_00_28aa_Entity_Set16                                  ;; 00:2be4 $cd $aa $28
    ld   C, $00                                        ;; 00:2be7 $0e $00
    call call_00_2299_Entity_UpdateFlags                                  ;; 00:2be9 $cd $99 $22
    call call_00_2ba9_SetEntityFlagsTo50                                  ;; 00:2bec $cd $a9 $2b
    xor  A, A                                          ;; 00:2bef $af
    farcall call_02_72ac_SetEntityAction
    ld   HL, .data_02_2c01                                     ;; 00:2bfb $21 $01 $2c
    jp   call_00_2c20_Entity_CopyPaletteToBuffer                                  ;; 00:2bfe $c3 $20 $2c
.data_02_2c01:
    db   $00, $00, $00, $00, $60, $02, $9c, $03        ;; 00:2c01 ........

call_00_2c09_Entity_SpawnGoalCounter:
; Adds +6 to A, stores in C.
; Then immediately jumps into PrepareRelativeEntitySpawn routine.
; Used for spawning a related/sub-entity with offset index.
    add  A, $06                                        ;; 00:2c09 $c6 $06
    ld   C, A                                          ;; 00:2c0b $4f
    jp   call_00_3792_PrepareRelativeEntitySpawn                                  ;; 00:2c0c $c3 $92 $37

call_00_2c0f_Entity_AssignPaletteId:
; Uses the current entity address to compute an index into wDAAE_EntityPaletteIds, 
; then stores register C there. Assigns a palette ID to the entity for rendering.
    ld   a,[wDA00_CurrentEntityAddrLo]
    rlca 
    rlca 
    rlca 
    and  a,$07
    ld   l,a
    ld   h,$00
    ld   de,wDAAE_EntityPaletteIds
    add  hl,de
    ld   [hl],c
    ret  

call_00_2c20_Entity_CopyPaletteToBuffer:
; Looks up the palette slot previously stored in wDAAE for the current entity.
; Multiplies that index by 8 to get a byte offset into wDD2A_EntityPalettes.
; Copies 8 bytes from whatever source HL pointed to into that palette slot.
    push HL                                            ;; 00:2c20 $e5
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2c21 $fa $00 $da
    rlca                                               ;; 00:2c24 $07
    rlca                                               ;; 00:2c25 $07
    rlca                                               ;; 00:2c26 $07
    and  A, $07                                        ;; 00:2c27 $e6 $07
    ld   L, A                                          ;; 00:2c29 $6f
    ld   H, $00                                        ;; 00:2c2a $26 $00
    ld   DE, wDAAE_EntityPaletteIds                                     ;; 00:2c2c $11 $ae $da
    add  HL, DE                                        ;; 00:2c2f $19
    ld   L, [HL]                                       ;; 00:2c30 $6e
    ld   H, $00                                        ;; 00:2c31 $26 $00
    add  HL, HL                                        ;; 00:2c33 $29
    add  HL, HL                                        ;; 00:2c34 $29
    add  HL, HL                                        ;; 00:2c35 $29
    ld   DE, wDD2A_EntityPalettes                                     ;; 00:2c36 $11 $2a $dd
    add  HL, DE                                        ;; 00:2c39 $19
    ld   E, L                                          ;; 00:2c3a $5d
    ld   D, H                                          ;; 00:2c3b $54
    pop  HL                                            ;; 00:2c3c $e1
    ld   BC, $08                                       ;; 00:2c3d $01 $08 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:2c40 $c3 $6e $07

data_00_2c43_ParticleSlotPointerTable:
; The pointer table to the individual particle buffers.
    dw   wDDC4_ParticleSlot1, wDDD7_ParticleSlot2
    dw   wDDEA_ParticleSlot3, wDDFD_ParticleSlot4        ;; 00:2c43 ????????
    dw   wDE10_ParticleSlot5, wDE23_ParticleSlot6
    dw   wDE36_ParticleSlot7, wDE49_ParticleSlot8                                         ;; 00:2c51 pP

call_00_2c53_Particle_GetSlotPtr:
; Fetches the DE pointer for the particle slot based on the current entity’s bits.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 00:2c53 $fa $00 $da
    rlca                                               ;; 00:2c56 $07
    rlca                                               ;; 00:2c57 $07
    rlca                                               ;; 00:2c58 $07
    and  A, $07                                        ;; 00:2c59 $e6 $07
    ld   L, A                                          ;; 00:2c5b $6f
    ld   H, $00                                        ;; 00:2c5c $26 $00
    add  HL, HL                                        ;; 00:2c5e $29
    ld   DE, data_00_2c43_ParticleSlotPointerTable                                     ;; 00:2c5f $11 $43 $2c
    add  HL, DE                                        ;; 00:2c62 $19
    ld   E, [HL]                                       ;; 00:2c63 $5e
    inc  HL                                            ;; 00:2c64 $23
    ld   D, [HL]                                       ;; 00:2c65 $56
    ret                                                ;; 00:2c66 $c9

call_00_2c67_Particle_InitBurst:
; Initializes a particle slot with the default burst data and timer ($40).
    call call_00_2c53_Particle_GetSlotPtr                                  ;; 00:2c67 $cd $53 $2c
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
    call call_00_2c53_Particle_GetSlotPtr                                  ;; 00:2c89 $cd $53 $2c
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
