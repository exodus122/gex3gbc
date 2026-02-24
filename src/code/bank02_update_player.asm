call_02_4db1_Player_CheckXDistanceFromObject:
; Checks whether an object exists (call_00_29ce), then compares the object’s X position to the player’s. 
; If the object is left of the player (carry set), branches to a special handler. If they are perfectly aligned, 
; it returns. Otherwise jumps to a general trigger routine.
; Purpose: Detects horizontal proximity for events.
    call call_00_29ce_Object_CheckExists                                  ;; 02:4db1 $cd $ce $29
    ret  NZ                                            ;; 02:4db4 $c0
    ld   A, L                                          ;; 02:4db5 $7d
    or   A, $0e                                        ;; 02:4db6 $f6 $0e
    ld   L, A                                          ;; 02:4db8 $6f
    ld   BC, $01                                       ;; 02:4db9 $01 $01 $00
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:4dbc $fa $0e $d8
    sub  A, [HL]                                       ;; 02:4dbf $96
    ld   E, A                                          ;; 02:4dc0 $5f
    inc  HL                                            ;; 02:4dc1 $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 02:4dc2 $fa $0f $d8
    sbc  A, [HL]                                       ;; 02:4dc5 $9e
    jp   C, call_02_51f9_ApplyRightwardCollisionAdjustment                               ;; 02:4dc6 $da $f9 $51
    or   A, E                                          ;; 02:4dc9 $b3
    ret  Z                                             ;; 02:4dca $c8
    jp   call_02_518a_ApplyLeftwardCollisionAdjustment                                  ;; 02:4dcb $c3 $8a $51

call_02_4dce_SetTriggerByLevel:
; Sets flag wDC80_Player_UnkStates bit 6, then selects a trigger value based on the current level (wDB6C_CurrentMapId). 
; Uses inputs (wDC81_CurrentInputsAlt) to decide between trigger IDs, then jumps to call_02_54f9_SwitchPlayerAction.
; Purpose: Level-specific event/door trigger.
    ld   HL, wDC80_Player_UnkStates                                     ;; 02:4dce $21 $80 $dc
    set  6, [HL]                                       ;; 02:4dd1 $cb $f6
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:4dd3 $fa $6c $db
    cp   A, $07                                        ;; 02:4dd6 $fe $07
    ld   A, PLAYERACTION_UNK36                                        ;; 02:4dd8 $3e $24
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:4dda $ca $f9 $54
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:4ddd $fa $6c $db
    cp   A, $08                                        ;; 02:4de0 $fe $08
    ld   A, PLAYERACTION_UNK48                                        ;; 02:4de2 $3e $30
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:4de4 $ca $f9 $54
    ld   C, PLAYERACTION_IDLE                                        ;; 02:4de7 $0e $01
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:4de9 $fa $81 $dc
    and  A, $30                                        ;; 02:4dec $e6 $30
    jr   Z, .jr_02_4df2                                ;; 02:4dee $28 $02
    ld   C, PLAYERACTION_WALK                                        ;; 02:4df0 $0e $03
.jr_02_4df2:
    ld   A, C                                          ;; 02:4df2 $79
    jp   call_02_54f9_SwitchPlayerAction                                  ;; 02:4df3 $c3 $f9 $54

call_02_4df6_FlagCollisionActive:
; Masks the lower nibble of wDC80_Player_UnkStates, forces the high bit, and stores it back.
; Purpose: Marks that a collision/event state is active.
    ld   A, [wDC80_Player_UnkStates]                                    ;; 02:4df6 $fa $80 $dc
    and  A, $0f                                        ;; 02:4df9 $e6 $0f
    or   A, $80                                        ;; 02:4dfb $f6 $80
    ld   [wDC80_Player_UnkStates], A                                    ;; 02:4dfd $ea $80 $dc
    ret                                                ;; 02:4e00 $c9

call_02_4e01_SetOneTimeFlag:
; If wDC87 is zero, sets it to 1. Used to ensure an action happens only once per frame or state.
; Purpose: Single-use event guard.
    ld   A, [wDC87]                                    ;; 02:4e01 $fa $87 $dc
    and  A, A                                          ;; 02:4e04 $a7
    ret  NZ                                            ;; 02:4e05 $c0
    ld   A, $01                                        ;; 02:4e06 $3e $01
    ld   [wDC87], A                                    ;; 02:4e08 $ea $87 $dc
    ret                                                ;; 02:4e0b $c9

call_02_4E0C_UpdateActionSequence:
; Updates counters (wDCA2_PlayerUnk1–wDCA6_PlayerUnk5) for a repeating animation or scripted sequence. 
; Uses call_02_4E7A_LookupFrameData to fetch frame data from tables at $4EA1/$4EC3. Handles two cases: 
; when the player’s action ID is $27 (special move) or any other action. Sets flags (wDC7F_Player_IsAttacking, wDC80_Player_UnkStates), 
; triggers sound/action (call_02_54f9_SwitchPlayerAction) when counters overflow, and sets wDB66_HDMATransferFlags to signal a redraw.
; Purpose: Manage complex animation or event sequences based on timers and player state.
    ld   a,[wDCA5_PlayerUnk4]
    ld   [wDCA6_PlayerUnk5],a
    ld   hl,wDC95
    ld   e,[hl]
    call call_02_4E7A_LookupFrameData
    inc  d
    dec  d
    jr   nz,.jr_00_4E24
    ld   hl,wDC93
    ld   e,[hl]
    call call_02_4E7A_LookupFrameData
.jr_00_4E24:
    ld   hl,wDCA5_PlayerUnk4
    ld   [hl],d
    ld   a,[wD801_Player_ActionId]
    cp   a,$27
    jr   nz,.jr_00_4E57
    ld   hl,wDCA3_PlayerUnk2
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_00_4E50
    ld   [hl],$03
    ld   hl,wDCA2_PlayerUnk1
    inc  [hl]
    ld   a,[hl]
    cp   a,$08
    jr   c,.jr_00_4E50
    xor  a
    ld   [wDC7F_Player_IsAttacking],a
    ld   hl,wDC80_Player_UnkStates
    set  6,[hl]
    ld   a,PLAYERACTION_UNK36
    jp   call_02_54f9_SwitchPlayerAction
.jr_00_4E50:
    ld   a,[wDCA2_PlayerUnk1]
    and  a,$07
    jr   .jr_00_4E6A
.jr_00_4E57:
    ld   hl,wDCA3_PlayerUnk2
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_00_4E65
    ld   [hl],$09
    ld   hl,wDCA2_PlayerUnk1
    inc  [hl]
.jr_00_4E65:
    ld   a,[wDCA2_PlayerUnk1]
    and  a,$01
.jr_00_4E6A:
    ld   hl,wDCA4_PlayerUnk3
    add  [hl]
    ld   hl,wD80A_Player_SpriteId
    cp   [hl]
    ret  z
    ld   [hl],a
    ld   hl,wDB66_HDMATransferFlags
    set  0,[hl]
    ret  

call_02_4E7A_LookupFrameData:
; Scans a table for an entry matching value E, then selects a frame or command 
; byte based on facing direction. Stores result in wDCA4_PlayerUnk3.
; Purpose: Table-driven frame or pattern lookup for 4E0C.
    ld   d,$00
    ld   hl,.data_02_4EC3
    ld   a,[wD801_Player_ActionId]
    cp   a,$27
    jr   z,.jr_00_4E89
    ld   hl,.data_02_4EA3-2
.jr_00_4E89:
    inc  hl
    inc  hl
    ldi  a,[hl]
    cp   a,$FF
    ret  z
    cp   e
    jr   nz,.jr_00_4E89
    ld   d,e
    ld   c,[hl]
    inc  hl
    ld   b,[hl]
    ld   a,[wD80D_PlayerFacingDirection]
    cp   a,$00
    ld   a,c
    jr   z,.jr_00_4E9F
    ld   a,b
.jr_00_4E9F:
    ld   [wDCA4_PlayerUnk3],a
    ret  
.data_02_4EA3:
    db   $01        ;; 02:4e9c ????????
    db   $05, $05, $06, $09, $01, $0d, $09, $01        ;; 02:4ea4 ????????
    db   $05, $01, $09, $0e, $01, $09, $09, $07        ;; 02:4eac ????????
    db   $03, $0a, $07, $03, $0b, $03, $07, $0c        ;; 02:4eb4 ????????
    db   $03, $07, $0f, $03, $07, $10, $03
.data_02_4EC3:
    db   $07        ;; 02:4ebc ????????
    db   $ff, $01, $0b, $0b, $06, $1b, $13, $0d        ;; 02:4ec4 ????????
    db   $1b, $13, $05, $13, $1b, $0e, $13, $1b        ;; 02:4ecc ????????
    db   $09, $2b, $23, $0a, $2b, $23, $0b, $23        ;; 02:4ed4 ????????
    db   $2b, $0c, $23, $2b, $0f, $23, $2b, $10        ;; 02:4edc ????????
    db   $23, $2b, $ff

call_02_4ee7_MapCollisionFlags:
; Reads high nibble of wDC81_CurrentInputsAlt. Searches .data_02_4F01 for a matching flag, returns mapped code or $FF if none.
; Purpose: Convert collision flags into an index or behavior code.
    ld   a,[wDC81_CurrentInputsAlt]
    and  a,$F0
    jr   z,.jr_00_4EFB
    ld   hl,.data_02_4F01
    ld   b,$08
.jr_00_4EF3:
    cp   [hl]
    jr   z,.jr_02_4EFE
    inc  hl
    inc  hl
    dec  b
    jr   nz,.jr_00_4EF3
.jr_00_4EFB:
    ld   a,$FF
    ret  
.jr_02_4EFE:
    inc  hl
    ld   a,[hl]
    ret  
.data_02_4F01   
    db   $40, $00, $80, $04, $20, $06, $10, $02
    db   $60, $07, $a0, $05, $50, $01, $90, $03

call_02_4f11_ChooseNextActionBasedOnLevel:
; Reads two state flags (wDABD_UnkBGCollisionFlags and wDABE_UnkBGCollisionFlags2) and ORs them together. 
; If bit 7 is set (likely “player busy/disabled”), it returns immediately. 
; Otherwise, it checks the current level ID (wDB6C_CurrentMapId) to pick an action ID:
; If level is 07h → $28.
; If level is 08h → $35.
; Otherwise → $11.
; It then jumps to call_02_54f9_SwitchPlayerAction to switch the player's action/animation.
    ld   A, [wDABD_UnkBGCollisionFlags]                                    ;; 02:4f11 $fa $bd $da
    ld   HL, wDABE_UnkBGCollisionFlags2                                     ;; 02:4f14 $21 $be $da
    or   A, [HL]                                       ;; 02:4f17 $b6
    bit  7, A                                          ;; 02:4f18 $cb $7f
    ret  NZ                                            ;; 02:4f1a $c0
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:4f1b $fa $6c $db
    cp   A, $07                                        ;; 02:4f1e $fe $07
    ld   A, PLAYERACTION_UNK40                                        ;; 02:4f20 $3e $28
    jr   Z, .jr_02_4f2f                                ;; 02:4f22 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:4f24 $fa $6c $db
    cp   A, $08                                        ;; 02:4f27 $fe $08
    ld   A, PLAYERACTION_UNK53                                        ;; 02:4f29 $3e $35
    jr   Z, .jr_02_4f2f                                ;; 02:4f2b $28 $02
    ld   A, PLAYERACTION_FALL                                        ;; 02:4f2d $3e $11
.jr_02_4f2f:
    jp   call_02_54f9_SwitchPlayerAction                                  ;; 02:4f2f $c3 $f9 $54

call_02_4f32_PlayerUpdateMain:
; The main per-frame player update.
; Actions:
; - Processes inputs, clearing or setting bits in wDC80_Player_UnkStates/wDC81_CurrentInputsAlt.
; - Manages timers (wDC7E_PlayerDamageCooldownTimer, wDCA9_FlyTimerOrFlags4–wDCAB_FlyTimerOrFlags2) using call_02_4ffb_DecTimerEveryCycle.
; - Calls palette setup (call_03_6567_SetupObjectPalettes), BG collision update, object caching, and object loading.
; - Jumps to the player action function (wD802_Player_ActionFunc).
; - Clears bits and finalizes state before call_02_724d.
; Purpose: Central routine for player state, input, collisions, and rendering per frame.
    ld   A, [wDAD7_CurrentInputs]                                    ;; 02:4f32 $fa $d7 $da
    ld   C, A                                          ;; 02:4f35 $4f
    ld   E, A                                          ;; 02:4f36 $5f
    ld   HL, wDC80_Player_UnkStates                                     ;; 02:4f37 $21 $80 $dc
    bit  0, [HL]                                       ;; 02:4f3a $cb $46
    jr   Z, .jr_02_4f46                                ;; 02:4f3c $28 $08
    bit  0, E                                          ;; 02:4f3e $cb $43
    jr   NZ, .jr_02_4f44                               ;; 02:4f40 $20 $02
    res  0, [HL]                                       ;; 02:4f42 $cb $86
.jr_02_4f44:
    res  0, C                                          ;; 02:4f44 $cb $81
.jr_02_4f46:
    bit  6, [HL]                                       ;; 02:4f46 $cb $76
    jr   Z, .jr_02_4f56                                ;; 02:4f48 $28 $0c
    bit  1, E                                          ;; 02:4f4a $cb $4b
    jr   NZ, .jr_02_4f52                               ;; 02:4f4c $20 $04
    ld   A, [HL]                                       ;; 02:4f4e $7e
    and  A, $0f                                        ;; 02:4f4f $e6 $0f
    ld   [HL], A                                       ;; 02:4f51 $77
.jr_02_4f52:
    res  1, C                                          ;; 02:4f52 $cb $89
    jr   .jr_02_4f71                                   ;; 02:4f54 $18 $1b
.jr_02_4f56:
    bit  7, [HL]                                       ;; 02:4f56 $cb $7e
    jr   Z, .jr_02_4f71                                ;; 02:4f58 $28 $17
    res  1, C                                          ;; 02:4f5a $cb $89
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 02:4f5c $fa $8c $dc
    bit  7, A                                          ;; 02:4f5f $cb $7f
    jr   Z, .jr_02_4f71                                ;; 02:4f61 $28 $0e
    bit  1, E                                          ;; 02:4f63 $cb $4b
    jr   NZ, .jr_02_4f6b                               ;; 02:4f65 $20 $04
    set  4, [HL]                                       ;; 02:4f67 $cb $e6
    jr   .jr_02_4f71                                   ;; 02:4f69 $18 $06
.jr_02_4f6b:
    bit  4, [HL]                                       ;; 02:4f6b $cb $66
    jr   Z, .jr_02_4f71                                ;; 02:4f6d $28 $02
    set  1, C                                          ;; 02:4f6f $cb $c9
.jr_02_4f71:
    ld   A, [wD801_Player_ActionId]                                    ;; 02:4f71 $fa $01 $d8
    cp   A, $07                                        ;; 02:4f74 $fe $07
    jr   NZ, .jr_02_4f89                               ;; 02:4f76 $20 $11
    res  4, C                                          ;; 02:4f78 $cb $a1
    res  5, C                                          ;; 02:4f7a $cb $a9
    ld   A, [wD80D_PlayerFacingDirection]                                    ;; 02:4f7c $fa $0d $d8
    and  A, $20                                        ;; 02:4f7f $e6 $20
    ld   A, $20                                        ;; 02:4f81 $3e $20
    jr   NZ, .jr_02_4f87                               ;; 02:4f83 $20 $02
    ld   A, $10                                        ;; 02:4f85 $3e $10
.jr_02_4f87:
    or   A, C                                          ;; 02:4f87 $b1
    ld   C, A                                          ;; 02:4f88 $4f
.jr_02_4f89:
    ld   HL, wDC81_CurrentInputsAlt                                     ;; 02:4f89 $21 $81 $dc
    ld   [HL], C                                       ;; 02:4f8c $71
    ld   HL, wDC7E_PlayerDamageCooldownTimer                                     ;; 02:4f8d $21 $7e $dc
    ld   A, [HL]                                       ;; 02:4f90 $7e
    and  A, A                                          ;; 02:4f91 $a7
    jr   Z, .jr_02_4f95                                ;; 02:4f92 $28 $01
    dec  [HL]                                          ;; 02:4f94 $35
.jr_02_4f95:
    ld   HL, wDCA9_FlyTimerOrFlags4                                     ;; 02:4f95 $21 $a9 $dc
    call call_02_4ffb_DecTimerEveryCycle                                  ;; 02:4f98 $cd $fb $4f
    ld   HL, wDCAA_FlyTimerOrFlags1                                     ;; 02:4f9b $21 $aa $dc
    call call_02_4ffb_DecTimerEveryCycle                                  ;; 02:4f9e $cd $fb $4f
    ld   HL, wDCAB_FlyTimerOrFlags2                                     ;; 02:4fa1 $21 $ab $dc
    call call_02_4ffb_DecTimerEveryCycle                                  ;; 02:4fa4 $cd $fb $4f
    farcall call_03_6567_SetupObjectPalettes
    call call_02_5081_Player_UpdateFacingAndMovementVector                                  ;; 02:4fb2 $cd $81 $50
    farcall call_03_46e0_UpdateBgCollision_MainDispatcher
    call call_02_5267_PlatformSlopeAndTriggerHandler                                  ;; 02:4fc0 $cd $67 $52
    farcall call_03_4bb6_CacheNearbyTileValues
    call call_02_5431_HandleActionTriggersAndEvents                                  ;; 02:4fce $cd $31 $54
    ld   HL, wDC79                                     ;; 02:4fd1 $21 $79 $dc
    ld   A, [HL]                                       ;; 02:4fd4 $7e
    ld   [HL], $ff                                     ;; 02:4fd5 $36 $ff
    cp   A, $ff                                        ;; 02:4fd7 $fe $ff
    call NZ, call_02_72ac_SetObjectAction                              ;; 02:4fd9 $c4 $ac $72
    ld   HL, wD802_Player_ActionFunc                                     ;; 02:4fdc $21 $02 $d8
    ld   A, [HL+]                                      ;; 02:4fdf $2a
    ld   H, [HL]                                       ;; 02:4fe0 $66
    ld   L, A                                          ;; 02:4fe1 $6f
    call call_00_0f22_JumpHL                                  ;; 02:4fe2 $cd $22 $0f
    ld   HL, wDCAC                                     ;; 02:4fe5 $21 $ac $dc
    ld   A, [HL]                                       ;; 02:4fe8 $7e
    and  A, A                                          ;; 02:4fe9 $a7
    jr   Z, .jr_02_4fed                                ;; 02:4fea $28 $01
    dec  [HL]                                          ;; 02:4fec $35
.jr_02_4fed:
    call call_02_5100_Player_HorizontalMovementHandler                                  ;; 02:4fed $cd $00 $51
    call call_02_5047_CachePlayerTileCoords                                  ;; 02:4ff0 $cd $47 $50
    ld   HL, wD805_Player_MovementFlags                                     ;; 02:4ff3 $21 $05 $d8
    res  4, [HL]                                       ;; 02:4ff6 $cb $a6
    jp   call_02_724d_UpdateObjectAnimationTimersAndSpriteId                                  ;; 02:4ff8 $c3 $4d $72

call_02_4ffb_DecTimerEveryCycle:
; Decrements a timer in [HL] every wDCA8_FlyTimerOrFlags3 frames. Resets wDCA8_FlyTimerOrFlags3 to 3C when it wraps.
; Purpose: Frame-based countdown helper.
    ld   A, [HL]                                       ;; 02:4ffb $7e
    and  A, A                                          ;; 02:4ffc $a7
    ret  Z                                             ;; 02:4ffd $c8
    ld   A, [wDCA8_FlyTimerOrFlags3]                                    ;; 02:4ffe $fa $a8 $dc
    dec  A                                             ;; 02:5001 $3d
    jr   NZ, .jr_02_5006                               ;; 02:5002 $20 $02
    ld   A, TIMER_AMOUNT_60_FRAMES                                        ;; 02:5004 $3e $3c
.jr_02_5006:
    ld   [wDCA8_FlyTimerOrFlags3], A                                    ;; 02:5006 $ea $a8 $dc
    cp   A, TIMER_AMOUNT_60_FRAMES                                        ;; 02:5009 $fe $3c
    ret  NZ                                            ;; 02:500b $c0
    dec  [HL]                                          ;; 02:500c $35
    ret                                                ;; 02:500d $c9

call_02_500e_ApplyDirectionalInputToPlayer:
; Checks for directional inputs (Right/Left/Down/Up) using call_00_0f6e etc. 
; Adjusts X or Y position via call_02_5033_Player_ApplyXDelta / 503d.
; Purpose: Applies directional movement vectors to the player.
    call call_00_0f6e_CheckInputRight
    ld   bc,$0002
    call nz,call_02_5033_Player_ApplyXDelta
    call call_00_0f68_CheckInputLeft
    ld   bc,hFFFE
    call nz,call_02_5033_Player_ApplyXDelta
    call call_00_0f7a_CheckInputDown
    ld   bc,$0002
    call nz,call_02_503d_Player_ApplyYDelta
    call call_00_0f74_CheckInputUp
    ld   bc,hFFFE
    call nz,call_02_503d_Player_ApplyYDelta
    ret  

call_02_5033_Player_ApplyXDelta:
; Adds signed BC offset to player X position (wD80E).
; Purpose: Horizontal position adjust.
    ld   hl,wD80E_PlayerXPosition
    ld   a,[hl]
    add  c
    ldi  [hl],a
    ld   a,[hl]
    adc  b
    ld   [hl],a
    ret  

call_02_503d_Player_ApplyYDelta:
; Adds signed BC offset to player Y position (wD810).
; Purpose: Vertical position adjust.
    ld   hl,wD810_PlayerYPosition
    ld   a,[hl]
    add  c
    ldi  [hl],a
    ld   a,[hl]
    adc  b
    ld   [hl],a
    ret  

call_02_5047_CachePlayerTileCoords:
; Shifts the player’s X and Y positions right by 4 (div 16) to convert from subpixel 
; to tile coordinates, then stores them in wDC54_CachedTileXCoord–wDC56_CachedTileYCoord.
; Purpose: Cache tilemap indices for collision lookups.
    ld   HL, wD80E_PlayerXPosition                                     ;; 02:5047 $21 $0e $d8
    ld   A, [HL+]                                      ;; 02:504a $2a
    ld   E, A                                          ;; 02:504b $5f
    ld   D, [HL]                                       ;; 02:504c $56
    srl  D                                             ;; 02:504d $cb $3a
    rr   E                                             ;; 02:504f $cb $1b
    srl  D                                             ;; 02:5051 $cb $3a
    rr   E                                             ;; 02:5053 $cb $1b
    srl  D                                             ;; 02:5055 $cb $3a
    rr   E                                             ;; 02:5057 $cb $1b
    srl  D                                             ;; 02:5059 $cb $3a
    rr   E                                             ;; 02:505b $cb $1b
    ld   A, E                                          ;; 02:505d $7b
    ld   HL, wDC54_CachedTileXCoord                                     ;; 02:505e $21 $54 $dc
    ld   A, E                                          ;; 02:5061 $7b
    ld   [HL+], A                                      ;; 02:5062 $22
    ld   [HL], D                                       ;; 02:5063 $72
    ld   HL, wD810_PlayerYPosition                                     ;; 02:5064 $21 $10 $d8
    ld   A, [HL+]                                      ;; 02:5067 $2a
    ld   E, A                                          ;; 02:5068 $5f
    ld   D, [HL]                                       ;; 02:5069 $56
    srl  D                                             ;; 02:506a $cb $3a
    rr   E                                             ;; 02:506c $cb $1b
    srl  D                                             ;; 02:506e $cb $3a
    rr   E                                             ;; 02:5070 $cb $1b
    srl  D                                             ;; 02:5072 $cb $3a
    rr   E                                             ;; 02:5074 $cb $1b
    srl  D                                             ;; 02:5076 $cb $3a
    rr   E                                             ;; 02:5078 $cb $1b
    ld   HL, wDC56_CachedTileYCoord                                     ;; 02:507a $21 $56 $dc
    ld   A, E                                          ;; 02:507d $7b
    ld   [HL+], A                                      ;; 02:507e $22
    ld   [HL], D                                       ;; 02:507f $72
    ret                                                ;; 02:5080 $c9

call_02_5081_Player_UpdateFacingAndMovementVector:
; Uses the player’s current action ID and collision flags to:
; - Choose a new facing direction (wD80D_PlayerFacingDirection).
; - Look up a movement vector from .data_02_50f0.
; - Smoothly adjust acceleration (wDC86) with hysteresis against wDC87.
; Purpose: Update facing direction and movement acceleration vectors.
    ld   HL, wD801_Player_ActionId                                     ;; 02:5081 $21 $01 $d8
    ld   L, [HL]                                       ;; 02:5084 $6e
    ld   H, $00                                        ;; 02:5085 $26 $00
    ld   DE, data_02_554d                              ;; 02:5087 $11 $4d $55
    add  HL, DE                                        ;; 02:508a $19
    bit  2, [HL]                                       ;; 02:508b $cb $56
    jr   NZ, .jr_02_50db                               ;; 02:508d $20 $4c
    call call_02_5541_GetActionPropertyByte                                  ;; 02:508f $cd $41 $55
    and  A, $a0                                        ;; 02:5092 $e6 $a0
    jr   NZ, .jr_02_509d                               ;; 02:5094 $20 $07
    ld   A, [wDC1F]                                    ;; 02:5096 $fa $1f $dc
    cp   A, $00                                        ;; 02:5099 $fe $00
    jr   Z, .jr_02_50c4                                ;; 02:509b $28 $27
.jr_02_509d:
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:509d $fa $81 $dc
    and  A, $30                                        ;; 02:50a0 $e6 $30
    jr   Z, .jr_02_50b0                                ;; 02:50a2 $28 $0c
    ld   C, $00                                        ;; 02:50a4 $0e $00
    and  A, $10                                        ;; 02:50a6 $e6 $10
    jr   NZ, .jr_02_50ac                               ;; 02:50a8 $20 $02
    ld   C, $20                                        ;; 02:50aa $0e $20
.jr_02_50ac:
    ld   HL, wD80D_PlayerFacingDirection                                     ;; 02:50ac $21 $0d $d8
    ld   [HL], C                                       ;; 02:50af $71
.jr_02_50b0:
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:50b0 $fa $81 $dc
    swap A                                             ;; 02:50b3 $cb $37
    and  A, $0f                                        ;; 02:50b5 $e6 $0f
    ld   L, A                                          ;; 02:50b7 $6f
    ld   H, $00                                        ;; 02:50b8 $26 $00
    ld   DE, .data_02_50f0                             ;; 02:50ba $11 $f0 $50
    add  HL, DE                                        ;; 02:50bd $19
    ld   A, [HL]                                       ;; 02:50be $7e
    ld   [wDC89], A                                    ;; 02:50bf $ea $89 $dc
    jr   .jr_02_50e0                                   ;; 02:50c2 $18 $1c
.jr_02_50c4:
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:50c4 $fa $81 $dc
    and  A, $30                                        ;; 02:50c7 $e6 $30
    jr   Z, .jr_02_50db                                ;; 02:50c9 $28 $10
    ld   C, $00                                        ;; 02:50cb $0e $00
    and  A, $10                                        ;; 02:50cd $e6 $10
    jr   NZ, .jr_02_50d3                               ;; 02:50cf $20 $02
    ld   C, $20                                        ;; 02:50d1 $0e $20
.jr_02_50d3:
    ld   HL, wD80D_PlayerFacingDirection                                     ;; 02:50d3 $21 $0d $d8
    ld   A, [HL]                                       ;; 02:50d6 $7e
    ld   [HL], C                                       ;; 02:50d7 $71
    cp   A, C                                          ;; 02:50d8 $b9
    jr   Z, .jr_02_50e0                                ;; 02:50d9 $28 $05
.jr_02_50db:
    xor  A, A                                          ;; 02:50db $af
    ld   [wDC86], A                                    ;; 02:50dc $ea $86 $dc
    ret                                                ;; 02:50df $c9
.jr_02_50e0:
    ld   A, [wDC86]                                    ;; 02:50e0 $fa $86 $dc
    ld   HL, wDC87                                     ;; 02:50e3 $21 $87 $dc
    cp   A, [HL]                                       ;; 02:50e6 $be
    jr   C, .jr_02_50eb                                ;; 02:50e7 $38 $02
    ld   A, [HL]                                       ;; 02:50e9 $7e
    dec  A                                             ;; 02:50ea $3d
.jr_02_50eb:
    inc  A                                             ;; 02:50eb $3c
    ld   [wDC86], A                                    ;; 02:50ec $ea $86 $dc
    ret                                                ;; 02:50ef $c9
.data_02_50f0:
    db   $00, $03, $07, $03, $01, $02, $08, $02        ;; 02:50f0 ????????
    db   $05, $04, $06, $04, $05, $04, $06, $04        ;; 02:50f8 ????????

call_02_5100_Player_HorizontalMovementHandler:
; Purpose: Main dispatcher for handling horizontal player movement.
; Details:
; Calls call_02_5541_GetActionPropertyByte to poll input state.
; Checks movement bits ($10, $20, $40, $80) and calls appropriate handlers 
; (call_02_51f9_ApplyRightwardCollisionAdjustment for right, call_02_518a_ApplyLeftwardCollisionAdjustment for left, etc.).
; Handles inversion if facing left (cpl/inc pattern), triggers collision tests (call_02_53e7_ApplyVerticalMovementAndClamp), 
; and adjusts movement depending on player action IDs.
; Falls back to a routine when no direct input (.jr_02_5159 path) to apply momentum or snapping
    call call_02_5541_GetActionPropertyByte                                  ;; 02:5100 $cd $41 $55
    and  A, $a0                                        ;; 02:5103 $e6 $a0
    jr   NZ, .jr_02_510e                               ;; 02:5105 $20 $07
    ld   A, [wDC1F]                                    ;; 02:5107 $fa $1f $dc
    cp   A, $00                                        ;; 02:510a $fe $00
    jr   Z, .jr_02_5159                                ;; 02:510c $28 $4b
.jr_02_510e:
    ld   A, [wDC86]                                    ;; 02:510e $fa $86 $dc
    and  A, A                                          ;; 02:5111 $a7
    ret  Z                                             ;; 02:5112 $c8
    ld   HL, wDC86                                     ;; 02:5113 $21 $86 $dc
    ld   C, [HL]                                       ;; 02:5116 $4e
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:5117 $fa $81 $dc
    and  A, PADF_RIGHT                                        ;; 02:511a $e6 $10
    call NZ, call_02_51f9_ApplyRightwardCollisionAdjustment                              ;; 02:511c $c4 $f9 $51
    ld   HL, wDC86                                     ;; 02:511f $21 $86 $dc
    ld   C, [HL]                                       ;; 02:5122 $4e
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:5123 $fa $81 $dc
    and  A, PADF_LEFT                                        ;; 02:5126 $e6 $20
    call NZ, call_02_518a_ApplyLeftwardCollisionAdjustment                              ;; 02:5128 $c4 $8a $51
    call call_02_553b_PollForSpecialInput                                  ;; 02:512b $cd $3b $55
    jr   Z, .jr_02_513a                                ;; 02:512e $28 $0a
    ld   A, [wD801_Player_ActionId]                                    ;; 02:5130 $fa $01 $d8
    cp   A, $19                                        ;; 02:5133 $fe $19
    jr   Z, .jr_02_513a                                ;; 02:5135 $28 $03
    cp   A, $1f                                        ;; 02:5137 $fe $1f
    ret  NZ                                            ;; 02:5139 $c0
.jr_02_513a:
    ld   HL, wDC86                                     ;; 02:513a $21 $86 $dc
    ld   C, [HL]                                       ;; 02:513d $4e
    ld   B, $00                                        ;; 02:513e $06 $00
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:5140 $fa $81 $dc
    and  A, PADF_DOWN                                        ;; 02:5143 $e6 $80
    call NZ, call_02_53e7_ApplyVerticalMovementAndClamp                              ;; 02:5145 $c4 $e7 $53
    ld   A, [wDC86]                                    ;; 02:5148 $fa $86 $dc
    cpl                                                ;; 02:514b $2f
    inc  A                                             ;; 02:514c $3c
    ld   C, A                                          ;; 02:514d $4f
    ld   B, $ff                                        ;; 02:514e $06 $ff
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:5150 $fa $81 $dc
    and  A, PADF_UP                                        ;; 02:5153 $e6 $40
    call NZ, call_02_53e7_ApplyVerticalMovementAndClamp                              ;; 02:5155 $c4 $e7 $53
    ret                                                ;; 02:5158 $c9
.jr_02_5159:
    ld   A, [wDC86]                                    ;; 02:5159 $fa $86 $dc
    ld   HL, wD80D_PlayerFacingDirection                                     ;; 02:515c $21 $0d $d8
    bit  5, [HL]                                       ;; 02:515f $cb $6e
    jr   Z, .jr_02_5165                                ;; 02:5161 $28 $02
    cpl                                                ;; 02:5163 $2f
    inc  A                                             ;; 02:5164 $3c
.jr_02_5165:
    ld   HL, wDC85                                     ;; 02:5165 $21 $85 $dc
    add  A, [HL]                                       ;; 02:5168 $86
    ld   HL, wDC84                                     ;; 02:5169 $21 $84 $dc
    add  A, [HL]                                       ;; 02:516c $86
    ret  Z                                             ;; 02:516d $c8
    push AF                                            ;; 02:516e $f5
    ld   A, [wDABE_UnkBGCollisionFlags2]                                    ;; 02:516f $fa $be $da
    and  A, $0f                                        ;; 02:5172 $e6 $0f
    jr   Z, .jr_02_517e                                ;; 02:5174 $28 $08
    cpl                                                ;; 02:5176 $2f
    inc  A                                             ;; 02:5177 $3c
    ld   C, A                                          ;; 02:5178 $4f
    ld   B, $ff                                        ;; 02:5179 $06 $ff
    call call_02_53e7_ApplyVerticalMovementAndClamp                                  ;; 02:517b $cd $e7 $53
.jr_02_517e:
    pop  AF                                            ;; 02:517e $f1
    ld   C, A                                          ;; 02:517f $4f
    bit  7, A                                          ;; 02:5180 $cb $7f
    jr   Z, call_02_51f9_ApplyRightwardCollisionAdjustment                               ;; 02:5182 $28 $75
    cpl                                                ;; 02:5184 $2f
    inc  A                                             ;; 02:5185 $3c
    ld   C, A                                          ;; 02:5186 $4f
    jp   call_02_518a_ApplyLeftwardCollisionAdjustment                                  ;; 02:5187 $c3 $8a $51

call_02_518a_ApplyLeftwardCollisionAdjustment:
; Purpose: Adjusts the player's X-position when moving left against solid tiles or obstacles.
; Details:
; Checks flags (wDC7C_PlayerCollisionUnusedFlag, wDC7B_CurrentObjectAddrLoAlt2) for collision state.
; Computes the delta between player position and reference points.
; Writes corrected position back to wD80E_PlayerXPosition or clamps based on collision checks.
; Works together with call_02_5195_ResolveLeftwardTilePushback to fine-tune adjustments.
    ld   A, [wDC7C_PlayerCollisionUnusedFlag]                                    ;; 02:518a $fa $7c $dc
    and  A, A                                          ;; 02:518d $a7
    jr   NZ, call_02_51cb_CheckLeftCollisionAndStoreOffset                                ;; 02:518e $20 $3b
    ld   A, [wDC7B_CurrentObjectAddrLoAlt2]                                    ;; 02:5190 $fa $7d $dc
    and  A, A                                          ;; 02:5193 $a7
    ret  NZ                                            ;; 02:5194 $c0

call_02_5195_ResolveLeftwardTilePushback:
; Purpose: Performs fine collision resolution when pushing left into a block.
; Details:
; Calculates distance between player and tile edges (wDC3C_MapBoundaryXMinLoPlus10, wD80E_PlayerXPosition).
; Updates temporary velocity/direction flags (wDC8A).
; Chooses whether to store adjusted coordinates or preserve original deltas based on flags.
    ld   HL, wDC3C_MapBoundaryXMinLoPlus10                                     ;; 02:5195 $21 $3c $dc
    ld   A, [HL+]                                      ;; 02:5198 $2a
    ld   D, [HL]                                       ;; 02:5199 $56
    ld   E, A                                          ;; 02:519a $5f
    ld   HL, wD80E_PlayerXPosition                                     ;; 02:519b $21 $0e $d8
    ld   A, [HL+]                                      ;; 02:519e $2a
    sub  A, C                                          ;; 02:519f $91
    ld   C, A                                          ;; 02:51a0 $4f
    ld   A, [HL]                                       ;; 02:51a1 $7e
    sbc  A, $00                                        ;; 02:51a2 $de $00
    ld   B, A                                          ;; 02:51a4 $47
    jr   C, .jr_02_51b6                                ;; 02:51a5 $38 $0f
    ld   A, E                                          ;; 02:51a7 $7b
    sub  A, C                                          ;; 02:51a8 $91
    ld   A, D                                          ;; 02:51a9 $7a
    sbc  A, B                                          ;; 02:51aa $98
    jr   C, .jr_02_51b4                                ;; 02:51ab $38 $07
    ld   A, $02                                        ;; 02:51ad $3e $02
    ld   [wDC8A], A                                    ;; 02:51af $ea $8a $dc
    jr   .jr_02_51b6                                   ;; 02:51b2 $18 $02
.jr_02_51b4:
    ld   E, C                                          ;; 02:51b4 $59
    ld   D, B                                          ;; 02:51b5 $50
.jr_02_51b6:
    ld   HL, wD80E_PlayerXPosition                                     ;; 02:51b6 $21 $0e $d8
    ld   A, [wDC2A_MapBoundaryIndex]                                    ;; 02:51b9 $fa $2a $dc
    cp   A, $00                                        ;; 02:51bc $fe $00
    jr   Z, .jr_02_51c4                                ;; 02:51be $28 $04
    ld   A, E                                          ;; 02:51c0 $7b
    ld   [HL+], A                                      ;; 02:51c1 $22
    ld   [HL], D                                       ;; 02:51c2 $72
    ret                                                ;; 02:51c3 $c9
.jr_02_51c4:
    ld   A, C                                          ;; 02:51c4 $79
    ld   [HL+], A                                      ;; 02:51c5 $22
    ld   A, B                                          ;; 02:51c6 $78
    and  A, $0f                                        ;; 02:51c7 $e6 $0f
    ld   [HL], A                                       ;; 02:51c9 $77
    ret                                                ;; 02:51ca $c9

call_02_51cb_CheckLeftCollisionAndStoreOffset:
; Purpose: Handles left-side collision testing.
; Behavior:
; Offsets into the player object table, checks a collision flag (bit 7).
; Compares the player’s X position to stored tile edge positions.
; If overlap exists, calls ResolveLeftwardTilePushback.
; Stores the corrected offset between player and solid edge back into the object table.
    or   A, OBJECT_FIELD_COLLISION_TYPE                                        ;; 02:51cb $f6 $14
    ld   L, A                                          ;; 02:51cd $6f
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 02:51ce $26 $d8
    bit  7, [HL]                                       ;; 02:51d0 $cb $7e
    ret  NZ                                            ;; 02:51d2 $c0
    dec  L                                             ;; 02:51d3 $2d
    dec  L                                             ;; 02:51d4 $2d
    ld   E, [HL]                                       ;; 02:51d5 $5e
    ld   A, L                                          ;; 02:51d6 $7d
    xor  A, $1c                                        ;; 02:51d7 $ee $1c
    ld   L, A                                          ;; 02:51d9 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:51da $fa $0e $d8
    sub  A, [HL]                                       ;; 02:51dd $96
    inc  HL                                            ;; 02:51de $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 02:51df $fa $0f $d8
    sbc  A, [HL]                                       ;; 02:51e2 $9e
    jr   C, call_02_5195_ResolveLeftwardTilePushback                               ;; 02:51e3 $38 $b0
    push HL                                            ;; 02:51e5 $e5
    push DE                                            ;; 02:51e6 $d5
    call call_02_5195_ResolveLeftwardTilePushback                                  ;; 02:51e7 $cd $95 $51
    pop  DE                                            ;; 02:51ea $d1
    pop  HL                                            ;; 02:51eb $e1
    dec  L                                             ;; 02:51ec $2d
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:51ed $fa $0e $d8
    sub  A, E                                          ;; 02:51f0 $93
    ld   [HL+], A                                      ;; 02:51f1 $22
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 02:51f2 $fa $0f $d8
    sbc  A, $00                                        ;; 02:51f5 $de $00
    ld   [HL], A                                       ;; 02:51f7 $77
    ret                                                ;; 02:51f8 $c9

call_02_51f9_ApplyRightwardCollisionAdjustment:
; Purpose: Mirrors call_02_518a for rightward movement.
; Details:
; Similar structure to 518a but uses addition instead of subtraction for position deltas.
; Works with call_02_5204_ResolveRightwardTilePushback for fine collision detection.
    ld   A, [wDC7C_PlayerCollisionUnusedFlag]                                    ;; 02:51f9 $fa $7c $dc
    and  A, A                                          ;; 02:51fc $a7
    jr   NZ, call_02_5238_CheckRightCollisionAndStoreOffset                                ;; 02:51fd $20 $39
    ld   A, [wDC7B_CurrentObjectAddrLoAlt2]                                    ;; 02:51ff $fa $7d $dc
    and  A, A                                          ;; 02:5202 $a7
    ret  NZ                                            ;; 02:5203 $c0

call_02_5204_ResolveRightwardTilePushback:
; Purpose: Mirrors call_02_5195 for right side collisions.
; Details:
; Uses positive deltas to adjust player’s X-position when moving right.
; pdates flags (wDC8A) and writes corrected values to player position.
    ld   HL, wDC3E_MapBoundaryXMaxLoPlus90                                     ;; 02:5204 $21 $3e $dc
    ld   A, [HL+]                                      ;; 02:5207 $2a
    ld   D, [HL]                                       ;; 02:5208 $56
    ld   E, A                                          ;; 02:5209 $5f
    ld   HL, wD80E_PlayerXPosition                                     ;; 02:520a $21 $0e $d8
    ld   A, [HL+]                                      ;; 02:520d $2a
    add  A, C                                          ;; 02:520e $81
    ld   C, A                                          ;; 02:520f $4f
    ld   A, [HL]                                       ;; 02:5210 $7e
    adc  A, $00                                        ;; 02:5211 $ce $00
    ld   B, A                                          ;; 02:5213 $47
    ld   A, E                                          ;; 02:5214 $7b
    sub  A, C                                          ;; 02:5215 $91
    ld   A, D                                          ;; 02:5216 $7a
    sbc  A, B                                          ;; 02:5217 $98
    jr   NC, .jr_02_5221                               ;; 02:5218 $30 $07
    ld   A, $03                                        ;; 02:521a $3e $03
    ld   [wDC8A], A                                    ;; 02:521c $ea $8a $dc
    jr   .jr_02_5223                                   ;; 02:521f $18 $02
.jr_02_5221:
    ld   E, C                                          ;; 02:5221 $59
    ld   D, B                                          ;; 02:5222 $50
.jr_02_5223:
    ld   HL, wD80E_PlayerXPosition                                     ;; 02:5223 $21 $0e $d8
    ld   A, [wDC2A_MapBoundaryIndex]                                    ;; 02:5226 $fa $2a $dc
    cp   A, $00                                        ;; 02:5229 $fe $00
    jr   Z, .jr_02_5231                                ;; 02:522b $28 $04
    ld   A, E                                          ;; 02:522d $7b
    ld   [HL+], A                                      ;; 02:522e $22
    ld   [HL], D                                       ;; 02:522f $72
    ret                                                ;; 02:5230 $c9
.jr_02_5231:
    ld   A, C                                          ;; 02:5231 $79
    ld   [HL+], A                                      ;; 02:5232 $22
    ld   A, B                                          ;; 02:5233 $78
    and  A, $0f                                        ;; 02:5234 $e6 $0f
    ld   [HL], A                                       ;; 02:5236 $77
    ret                                                ;; 02:5237 $c9

call_02_5238_CheckRightCollisionAndStoreOffset:
; Purpose: Right-side equivalent of 51CB.
; Behavior:
; Performs the same operations but for movement to the right.
; Calls ResolveRightwardTilePushback when needed.
; Updates the tile offset table after adjustment.
    or   A, OBJECT_FIELD_COLLISION_TYPE                                        ;; 02:5238 $f6 $14
    ld   L, A                                          ;; 02:523a $6f
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 02:523b $26 $d8
    bit  7, [HL]                                       ;; 02:523d $cb $7e
    ret  NZ                                            ;; 02:523f $c0
    dec  L                                             ;; 02:5240 $2d
    dec  L                                             ;; 02:5241 $2d
    ld   E, [HL]                                       ;; 02:5242 $5e
    inc  E                                             ;; 02:5243 $1c
    ld   A, L                                          ;; 02:5244 $7d
    xor  A, $1c                                        ;; 02:5245 $ee $1c
    ld   L, A                                          ;; 02:5247 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:5248 $fa $0e $d8
    sub  A, [HL]                                       ;; 02:524b $96
    inc  HL                                            ;; 02:524c $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 02:524d $fa $0f $d8
    sbc  A, [HL]                                       ;; 02:5250 $9e
    jr   NC, call_02_5204_ResolveRightwardTilePushback                              ;; 02:5251 $30 $b1
    push HL                                            ;; 02:5253 $e5
    push DE                                            ;; 02:5254 $d5
    call call_02_5204_ResolveRightwardTilePushback                                  ;; 02:5255 $cd $04 $52
    pop  DE                                            ;; 02:5258 $d1
    pop  HL                                            ;; 02:5259 $e1
    dec  L                                             ;; 02:525a $2d
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:525b $fa $0e $d8
    add  A, E                                          ;; 02:525e $83
    ld   [HL+], A                                      ;; 02:525f $22
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 02:5260 $fa $0f $d8
    adc  A, $00                                        ;; 02:5263 $ce $00
    ld   [HL], A                                       ;; 02:5265 $77
    ret                                                ;; 02:5266 $c9

call_02_5267_PlatformSlopeAndTriggerHandler:
; Purpose: Manages sloped surfaces, triggers, and speed modifiers.
; Details:
; Reads slope/collision data (wDC8C_PlayerYVelocity, wDC8F, etc.) and adjusts horizontal velocity.
; Checks level ID and player action IDs to trigger special cases (calls call_02_54f9_SwitchPlayerAction).
; Handles different terrain behaviors (e.g., slippery slopes or triggers unique to levels 7 & 8).
    call call_02_5541_GetActionPropertyByte                                  ;; 02:5267 $cd $41 $55
    and  A, $a0                                        ;; 02:526a $e6 $a0
    ret  NZ                                            ;; 02:526c $c0
    ld   A, [wDC1F]                                    ;; 02:526d $fa $1f $dc
    cp   A, $01                                        ;; 02:5270 $fe $01
    jp   Z, .jp_02_5348                                ;; 02:5272 $ca $48 $53
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 02:5275 $fa $8c $dc
    bit  7, A                                          ;; 02:5278 $cb $7f
    jr   NZ, .jr_02_52b3                               ;; 02:527a $20 $37
    and  A, A                                          ;; 02:527c $a7
    jr   Z, .jr_02_52b3                                ;; 02:527d $28 $34
    xor  A, A                                          ;; 02:527f $af
    ld   [wDC8F], A                                    ;; 02:5280 $ea $8f $dc
.jp_02_5283:
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 02:5283 $fa $8c $dc
    sub  A, $02                                        ;; 02:5286 $d6 $02
    bit  7, A                                          ;; 02:5288 $cb $7f
    jr   Z, .jr_02_529b                                ;; 02:528a $28 $0f
    cp   A, $c0                                        ;; 02:528c $fe $c0
    jr   NC, .jr_02_529b                               ;; 02:528e $30 $0b
    ld   HL, wDC8F                                     ;; 02:5290 $21 $8f $dc
    ld   A, [HL]                                       ;; 02:5293 $7e
    cp   A, $7f                                        ;; 02:5294 $fe $7f
    adc  A, $00                                        ;; 02:5296 $ce $00
    ld   [HL], A                                       ;; 02:5298 $77
    ld   A, $c0                                        ;; 02:5299 $3e $c0
.jr_02_529b:
    ld   [wDC8C_PlayerYVelocity], A                                    ;; 02:529b $ea $8c $dc
    cpl                                                ;; 02:529e $2f
    inc  A                                             ;; 02:529f $3c
    swap A                                             ;; 02:52a0 $cb $37
    and  A, $0f                                        ;; 02:52a2 $e6 $0f
    ld   C, A                                          ;; 02:52a4 $4f
    ld   B, $00                                        ;; 02:52a5 $06 $00
    bit  3, A                                          ;; 02:52a7 $cb $5f
    jp   Z, call_02_53e7_ApplyVerticalMovementAndClamp                               ;; 02:52a9 $ca $e7 $53
    or   A, $f0                                        ;; 02:52ac $f6 $f0
    ld   C, A                                          ;; 02:52ae $4f
    dec  B                                             ;; 02:52af $05
    jp   call_02_53e7_ApplyVerticalMovementAndClamp                                  ;; 02:52b0 $c3 $e7 $53
.jr_02_52b3:
    ld   A, [wDABE_UnkBGCollisionFlags2]                                    ;; 02:52b3 $fa $be $da
    and  A, $80                                        ;; 02:52b6 $e6 $80
    jr   Z, .jr_02_52cf                                ;; 02:52b8 $28 $15
    ld   A, [wDC8D]                                    ;; 02:52ba $fa $8d $dc
    and  A, A                                          ;; 02:52bd $a7
    jr   Z, .jr_02_52f8                                ;; 02:52be $28 $38
    ld   HL, wDABD_UnkBGCollisionFlags                                     ;; 02:52c0 $21 $bd $da
    bit  7, [HL]                                       ;; 02:52c3 $cb $7e
    jr   NZ, .jr_02_529b                               ;; 02:52c5 $20 $d4
    ld   HL, wDC8C_PlayerYVelocity                                     ;; 02:52c7 $21 $8c $dc
    cp   A, [HL]                                       ;; 02:52ca $be
    jr   NC, .jr_02_529b                               ;; 02:52cb $30 $ce
    jr   .jp_02_5283                                   ;; 02:52cd $18 $b4
.jr_02_52cf:
    ld   A, [wDABD_UnkBGCollisionFlags]                                    ;; 02:52cf $fa $bd $da
    and  A, $80                                        ;; 02:52d2 $e6 $80
    jr   NZ, .jr_02_52de                               ;; 02:52d4 $20 $08
    ld   A, [wDC8F]                                    ;; 02:52d6 $fa $8f $dc
    cp   A, $10                                        ;; 02:52d9 $fe $10
    jp   C, .jp_02_5283                                ;; 02:52db $da $83 $52
.jr_02_52de:
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:52de $fa $6c $db
    cp   A, $07                                        ;; 02:52e1 $fe $07
    ld   A, PLAYERACTION_UNK40                                        ;; 02:52e3 $3e $28
    jr   Z, .jr_02_52f2                                ;; 02:52e5 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:52e7 $fa $6c $db
    cp   A, $08                                        ;; 02:52ea $fe $08
    ld   A, PLAYERACTION_UNK53                                        ;; 02:52ec $3e $35
    jr   Z, .jr_02_52f2                                ;; 02:52ee $28 $02
    ld   A, PLAYERACTION_FALL                                        ;; 02:52f0 $3e $11
.jr_02_52f2:
    call call_02_54f9_SwitchPlayerAction                                  ;; 02:52f2 $cd $f9 $54
    jp   .jp_02_5283                                   ;; 02:52f5 $c3 $83 $52
.jr_02_52f8:
    xor  A, A                                          ;; 02:52f8 $af
    ld   [wDC8C_PlayerYVelocity], A                                    ;; 02:52f9 $ea $8c $dc
    ld   HL, wDC8F                                     ;; 02:52fc $21 $8f $dc
    ld   C, [HL]                                       ;; 02:52ff $4e
    ld   [HL], $00                                     ;; 02:5300 $36 $00
    ld   A, [wD801_Player_ActionId]                                    ;; 02:5302 $fa $01 $d8
    cp   A, $1a                                        ;; 02:5305 $fe $1a
    ld   A, PLAYERACTION_DIE                                        ;; 02:5307 $3e $0a
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:5309 $ca $f9 $54
    ld   A, [wD801_Player_ActionId]                                    ;; 02:530c $fa $01 $d8
    cp   A, $2e                                        ;; 02:530f $fe $2e
    ld   A, PLAYERACTION_DIE_2                                        ;; 02:5311 $3e $2a
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:5313 $ca $f9 $54
    ld   A, [wD801_Player_ActionId]                                    ;; 02:5316 $fa $01 $d8
    cp   A, $3b                                        ;; 02:5319 $fe $3b
    ld   A, PLAYERACTION_DIE_3                                        ;; 02:531b $3e $37
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:531d $ca $f9 $54
    ld   A, C                                          ;; 02:5320 $79
    cp   A, $08                                        ;; 02:5321 $fe $08
    jr   NC, .jr_02_532a                               ;; 02:5323 $30 $05
    xor  A, A                                          ;; 02:5325 $af
    ld   [wDC8E_InitialYVelocity], A                                    ;; 02:5326 $ea $8e $dc
    ret                                                ;; 02:5329 $c9
.jr_02_532a:
    cp   A, $10                                        ;; 02:532a $fe $10
    jp   C, call_02_4dce_SetTriggerByLevel                                 ;; 02:532c $da $ce $4d
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:532f $fa $6c $db
    cp   A, $07                                        ;; 02:5332 $fe $07
    ld   A, PLAYERACTION_UNK36                                        ;; 02:5334 $3e $24
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:5336 $ca $f9 $54
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:5339 $fa $6c $db
    cp   A, $08                                        ;; 02:533c $fe $08
    ld   A, PLAYERACTION_UNK48                                        ;; 02:533e $3e $30
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:5340 $ca $f9 $54
    ld   A, PLAYERACTION_FALLING_LAND                                        ;; 02:5343 $3e $12
    jp   call_02_54f9_SwitchPlayerAction                                  ;; 02:5345 $c3 $f9 $54
.jp_02_5348:
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 02:5348 $fa $8c $dc
    sub  A, $02                                        ;; 02:534b $d6 $02
    bit  7, A                                          ;; 02:534d $cb $7f
    jr   Z, .jr_02_5357                                ;; 02:534f $28 $06
    cp   A, $c0                                        ;; 02:5351 $fe $c0
    jr   NC, .jr_02_5357                               ;; 02:5353 $30 $02
    ld   A, $c0                                        ;; 02:5355 $3e $c0
.jr_02_5357:
    ld   [wDC8C_PlayerYVelocity], A                                    ;; 02:5357 $ea $8c $dc
    cpl                                                ;; 02:535a $2f
    inc  A                                             ;; 02:535b $3c
    swap A                                             ;; 02:535c $cb $37
    and  A, $0f                                        ;; 02:535e $e6 $0f
    bit  3, A                                          ;; 02:5360 $cb $5f
    jr   Z, .jr_02_5366                                ;; 02:5362 $28 $02
    or   A, $f0                                        ;; 02:5364 $f6 $f0
.jr_02_5366:
    ld   HL, wDC88_CurrentObject_UnkVerticalOffset                                     ;; 02:5366 $21 $88 $dc
    add  A, [HL]                                       ;; 02:5369 $86
    bit  7, A                                          ;; 02:536a $cb $7f
    jr   NZ, .jr_02_5372                               ;; 02:536c $20 $04
    xor  A, A                                          ;; 02:536e $af
    ld   [wDC8E_InitialYVelocity], A                                    ;; 02:536f $ea $8e $dc
.jr_02_5372:
    ld   [HL], A                                       ;; 02:5372 $77
    ret                                                ;; 02:5373 $c9

call_02_5374_LevelSpecificEventTrigger:
; Purpose: Triggers scripted events or hazards tied to specific X positions or collectibles.
; Details:
; Filters on input state (and A,$08).
; Uses level number and index (wDC1E_CurrentLevelNumber) to find event tables (.data_02_53bf).
; Compares collected values (wDCB1_LevelTriggerBuffer) to thresholds and modifies wDC8C_PlayerYVelocity (horizontal momentum or trigger accumulator).
; Likely handles special pickups or doors that open based on conditions.
    call call_02_5541_GetActionPropertyByte                                  ;; 02:5374 $cd $41 $55
    and  A, $08                                        ;; 02:5377 $e6 $08
    ret  NZ                                            ;; 02:5379 $c0
    ld   A, [wDC93]                                    ;; 02:537a $fa $93 $dc
    cp   A, $3e                                        ;; 02:537d $fe $3e
    ret  C                                             ;; 02:537f $d8
    cp   A, $42                                        ;; 02:5380 $fe $42
    ret  NC                                            ;; 02:5382 $d0
    sub  A, $3e                                        ;; 02:5383 $d6 $3e
    ld   C, A                                          ;; 02:5385 $4f
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 02:5386 $21 $1e $dc
    ld   L, [HL]                                       ;; 02:5389 $6e
    ld   H, $00                                        ;; 02:538a $26 $00
    add  HL, HL                                        ;; 02:538c $29
    ld   DE, .data_02_53bf                             ;; 02:538d $11 $bf $53
    add  HL, DE                                        ;; 02:5390 $19
    ld   A, [HL+]                                      ;; 02:5391 $2a
    ld   D, [HL]                                       ;; 02:5392 $56
    ld   E, A                                          ;; 02:5393 $5f
    or   A, D                                          ;; 02:5394 $b2
    ret  Z                                             ;; 02:5395 $c8
    ld   L, C                                          ;; 02:5396 $69
    ld   H, $00                                        ;; 02:5397 $26 $00
    add  HL, HL                                        ;; 02:5399 $29
    add  HL, DE                                        ;; 02:539a $19
    ld   C, [HL]                                       ;; 02:539b $4e
    inc  HL                                            ;; 02:539c $23
    ld   A, [HL]                                       ;; 02:539d $7e
    cp   A, $ff                                        ;; 02:539e $fe $ff
    jr   Z, .jr_02_53ac                                ;; 02:53a0 $28 $0a
    ld   L, A                                          ;; 02:53a2 $6f
    ld   H, $00                                        ;; 02:53a3 $26 $00
    ld   DE, wDCB1_LevelTriggerBuffer                                     ;; 02:53a5 $11 $b1 $dc
    add  HL, DE                                        ;; 02:53a8 $19
    ld   A, [HL]                                       ;; 02:53a9 $7e
    cp   A, C                                          ;; 02:53aa $b9
    ret  C                                             ;; 02:53ab $d8
.jr_02_53ac:
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 02:53ac $fa $8c $dc
    add  A, $03                                        ;; 02:53af $c6 $03
    cp   A, $20                                        ;; 02:53b1 $fe $20
    jr   C, .jr_02_53b7                                ;; 02:53b3 $38 $02
    ld   A, $20                                        ;; 02:53b5 $3e $20
.jr_02_53b7:
    ld   [wDC8C_PlayerYVelocity], A                                    ;; 02:53b7 $ea $8c $dc
    ld   A, PLAYERACTION_UNK29                                        ;; 02:53ba $3e $1d
    jp   call_02_54f9_SwitchPlayerAction                                  ;; 02:53bc $c3 $f9 $54
.data_02_53bf:
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:53bf ????????
    db   $00, $00, $d7, $53, $df, $53, $00, $00        ;; 02:53c7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:53cf ????????
    db   $01, $06, $02, $06, $01, $01, $01, $04        ;; 02:53d7 ????????
    db   $00, $ff, $00, $ff, $00, $ff, $00, $ff        ;; 02:53df ????????

call_02_53e7_ApplyVerticalMovementAndClamp:
; Referenced by multiple functions: Applies calculated delta (C,B) to update or test tile collisions.
; Purpose: Updates Y position and prevents moving outside bounds or through solids.
; Behavior:
; Adds (C,B) delta to Y coordinates (wD810–wD811).
; If player isn’t in a special action (≠ $1B), compares the new position against stored map window bounds (wDC40_MapBoundaryYMinLoPlus10–wDC43_MapBoundaryYMaxHiPlus0).
; If out of bounds, clamps Y to the limit and sets wDC8A as a collision indicator.
    ld   HL, wD810_PlayerYPosition                                     ;; 02:53e7 $21 $10 $d8
    ld   A, [HL]                                       ;; 02:53ea $7e
    add  A, C                                          ;; 02:53eb $81
    ld   [HL+], A                                      ;; 02:53ec $22
    ld   C, A                                          ;; 02:53ed $4f
    ld   A, [HL]                                       ;; 02:53ee $7e
    adc  A, B                                          ;; 02:53ef $88
    ld   [HL], A                                       ;; 02:53f0 $77
    ld   B, A                                          ;; 02:53f1 $47
    ld   A, [wD801_Player_ActionId]                                    ;; 02:53f2 $fa $01 $d8
    cp   A, $1b                                        ;; 02:53f5 $fe $1b
    ret  Z                                             ;; 02:53f7 $c8
    bit  7, B                                          ;; 02:53f8 $cb $78
    jr   NZ, .jr_02_541f                               ;; 02:53fa $20 $23
    ld   HL, wDC40_MapBoundaryYMinLoPlus10                                     ;; 02:53fc $21 $40 $dc
    ld   A, C                                          ;; 02:53ff $79
    sub  A, [HL]                                       ;; 02:5400 $96
    inc  HL                                            ;; 02:5401 $23
    ld   A, B                                          ;; 02:5402 $78
    sbc  A, [HL]                                       ;; 02:5403 $9e
    jr   C, .jr_02_541f                                ;; 02:5404 $38 $19
    inc  HL                                            ;; 02:5406 $23
    ld   A, C                                          ;; 02:5407 $79
    sub  A, [HL]                                       ;; 02:5408 $96
    inc  HL                                            ;; 02:5409 $23
    ld   A, B                                          ;; 02:540a $78
    sbc  A, [HL]                                       ;; 02:540b $9e
    ret  C                                             ;; 02:540c $d8
    ld   A, [wDC42_MapBoundaryYMaxLoPlus78]                                    ;; 02:540d $fa $42 $dc
    ld   [wD810_PlayerYPosition], A                                    ;; 02:5410 $ea $10 $d8
    ld   A, [wDC43_MapBoundaryYMaxHiPlus0]                                    ;; 02:5413 $fa $43 $dc
    ld   [wD810_PlayerYPosition+1], A                                    ;; 02:5416 $ea $11 $d8
    ld   A, $01                                        ;; 02:5419 $3e $01
    ld   [wDC8A], A                                    ;; 02:541b $ea $8a $dc
    ret                                                ;; 02:541e $c9
.jr_02_541f:
    ld   A, [wDC40_MapBoundaryYMinLoPlus10]                                    ;; 02:541f $fa $40 $dc
    ld   [wD810_PlayerYPosition], A                                    ;; 02:5422 $ea $10 $d8
    ld   A, [wDC41_MapBoundaryYMinHiPlus00]                                    ;; 02:5425 $fa $41 $dc
    ld   [wD810_PlayerYPosition+1], A                                    ;; 02:5428 $ea $11 $d8
    ld   A, $00                                        ;; 02:542b $3e $00
    ld   [wDC8A], A                                    ;; 02:542d $ea $8a $dc
    ret                                                ;; 02:5430 $c9

call_02_5431_HandleActionTriggersAndEvents:
; Purpose: Central dispatcher for action-specific triggers, tile events, and scripted transitions.
; Behavior:
; Looks up the current action’s properties (data_02_554d) to check event bits.
; Compares nearby tile IDs (wDC92, wDC93) for special cases (e.g., doors, hazards).
; Calls LevelSpecificEventTrigger (5374) and call_02_553b_PollForSpecialInput (input polling).
; May queue new action states via call_02_54f9_SwitchPlayerAction or reset collision variables if certain tile types are detected.
    ld   HL, wD801_Player_ActionId                                     ;; 02:5431 $21 $01 $d8
    ld   L, [HL]                                       ;; 02:5434 $6e
    ld   H, $00                                        ;; 02:5435 $26 $00
    ld   DE, data_02_554d                              ;; 02:5437 $11 $4d $55
    add  HL, DE                                        ;; 02:543a $19
    bit  3, [HL]                                       ;; 02:543b $cb $5e
    jr   NZ, .jr_02_545b                               ;; 02:543d $20 $1c
    bit  4, [HL]                                       ;; 02:543f $cb $66
    jr   NZ, .jr_02_5453                               ;; 02:5441 $20 $10
    ld   A, [wDC92]                                    ;; 02:5443 $fa $92 $dc
    cp   A, $28                                        ;; 02:5446 $fe $28
    jp   Z, jp_00_06da                                 ;; 02:5448 $ca $da $06
    ld   A, [wDC93]                                    ;; 02:544b $fa $93 $dc
    cp   A, $28                                        ;; 02:544e $fe $28
    jp   Z, jp_00_06da                                 ;; 02:5450 $ca $da $06
.jr_02_5453:
    ld   A, [wDC93]                                    ;; 02:5453 $fa $93 $dc
    cp   A, $19                                        ;; 02:5456 $fe $19
    jp   Z, jp_00_06e8                                 ;; 02:5458 $ca $e8 $06
.jr_02_545b:
    call call_02_5374_LevelSpecificEventTrigger                                  ;; 02:545b $cd $74 $53
    call call_02_553b_PollForSpecialInput                                  ;; 02:545e $cd $3b $55
    jr   Z, .jr_02_5488                                ;; 02:5461 $28 $25
    ld   A, [wD801_Player_ActionId]                                    ;; 02:5463 $fa $01 $d8
    cp   A, $19                                        ;; 02:5466 $fe $19
    jr   Z, .jr_02_546e                                ;; 02:5468 $28 $04
    cp   A, $1f                                        ;; 02:546a $fe $1f
    jr   NZ, .jr_02_54a7                               ;; 02:546c $20 $39
.jr_02_546e:
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:546e $fa $81 $dc
    and  A, PADF_UP                                        ;; 02:5471 $e6 $40
    jr   Z, .jr_02_54a7                                ;; 02:5473 $28 $32
    ld   A, [wDC92]                                    ;; 02:5475 $fa $92 $dc
    cp   A, $36                                        ;; 02:5478 $fe $36
    jr   NZ, .jr_02_54a7                               ;; 02:547a $20 $2b
    ld   A, $04                                        ;; 02:547c $3e $04
    ld   [wDC9D], A                                    ;; 02:547e $ea $9d $dc
    ld   A, PLAYERACTION_UNK32                                        ;; 02:5481 $3e $20
    call call_02_54f9_SwitchPlayerAction                                  ;; 02:5483 $cd $f9 $54
    jr   .jr_02_54a7                                   ;; 02:5486 $18 $1f
.jr_02_5488:
    ld   A, [wD801_Player_ActionId]                                    ;; 02:5488 $fa $01 $d8
    cp   A, $0f                                        ;; 02:548b $fe $0f
    jr   NZ, .jr_02_5496                               ;; 02:548d $20 $07
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 02:548f $fa $8c $dc
    bit  7, A                                          ;; 02:5492 $cb $7f
    jr   Z, .jr_02_54a7                                ;; 02:5494 $28 $11
.jr_02_5496:
    ld   A, [wDC92]                                    ;; 02:5496 $fa $92 $dc
    cp   A, $36                                        ;; 02:5499 $fe $36
    jr   NZ, .jr_02_54a7                               ;; 02:549b $20 $0a
    ld   A, $04                                        ;; 02:549d $3e $04
    ld   [wDC9D], A                                    ;; 02:549f $ea $9d $dc
    ld   A, PLAYERACTION_UNK32                                        ;; 02:54a2 $3e $20
    call call_02_54f9_SwitchPlayerAction                                  ;; 02:54a4 $cd $f9 $54
.jr_02_54a7:
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:54a7 $fa $81 $dc
    and  A, PADF_UP                                        ;; 02:54aa $e6 $40
    jr   Z, .jr_02_54d0                                ;; 02:54ac $28 $22
    ld   A, [wD801_Player_ActionId]                                    ;; 02:54ae $fa $01 $d8
    cp   A, $22                                        ;; 02:54b1 $fe $22
    jr   Z, .jr_02_54d0                                ;; 02:54b3 $28 $1b
    farcall call_03_4c2e_IsTileType3D
    jr   NZ, .jr_02_54d0                               ;; 02:54c0 $20 $0e
    xor  A, A                                          ;; 02:54c2 $af
    ld   [wDCA1_PlayerUnk6], A                                    ;; 02:54c3 $ea $a1 $dc
    ld   [wDC86], A                                    ;; 02:54c6 $ea $86 $dc
    ld   [wDC8C_PlayerYVelocity], A                                    ;; 02:54c9 $ea $8c $dc
    ld   A, PLAYERACTION_UNK34                                        ;; 02:54cc $3e $22
    jr   call_02_54f9_SwitchPlayerAction                                  ;; 02:54ce $18 $29
.jr_02_54d0:
    ld   HL, wD801_Player_ActionId                                     ;; 02:54d0 $21 $01 $d8
    ld   L, [HL]                                       ;; 02:54d3 $6e
    ld   H, $00                                        ;; 02:54d4 $26 $00
    add  HL, HL                                        ;; 02:54d6 $29
    ld   DE, data_02_55c5                              ;; 02:54d7 $11 $c5 $55
    add  HL, DE                                        ;; 02:54da $19
    ld   A, [HL+]                                      ;; 02:54db $2a
    ld   H, [HL]                                       ;; 02:54dc $66
    ld   L, A                                          ;; 02:54dd $6f
    or   A, H                                          ;; 02:54de $b4
    ret  Z                                             ;; 02:54df $c8
    ld   A, [wDC81_CurrentInputsAlt]                                    ;; 02:54e0 $fa $81 $dc
    and  A, $f3                                        ;; 02:54e3 $e6 $f3
    ld   C, A                                          ;; 02:54e5 $4f
.jr_02_54e6:
    ld   A, [HL+]                                      ;; 02:54e6 $2a
    cp   A, $ff                                        ;; 02:54e7 $fe $ff
    ret  Z                                             ;; 02:54e9 $c8
    cp   A, $fe                                        ;; 02:54ea $fe $fe
    jr   NZ, .jr_02_54f2                               ;; 02:54ec $20 $04
    inc  C                                             ;; 02:54ee $0c
    dec  C                                             ;; 02:54ef $0d
    jr   NZ, .jr_02_54f8                               ;; 02:54f0 $20 $06
.jr_02_54f2:
    cp   A, C                                          ;; 02:54f2 $b9
    jr   Z, .jr_02_54f8                                ;; 02:54f3 $28 $03
    inc  HL                                            ;; 02:54f5 $23
    jr   .jr_02_54e6                                   ;; 02:54f6 $18 $ee
.jr_02_54f8:
    ld   A, [HL+]                                      ;; 02:54f8 $2a

call_02_54f9_SwitchPlayerAction:
; Purpose: Safely change the player’s action/state.
; Behavior:
; Adjusts action index if in special level/bank.
; Avoids redundant switches if already in that action.
; Validates against flags in data_02_554d.
; Writes new action ID to wDC79 and resets auxiliary timers (wDC7F_Player_IsAttacking, wDC7A).
    ld   L, A                                          ;; 02:54f9 $6f
    cp   A, $3c                                        ;; 02:54fa $fe $3c
    jr   NC, .jr_02_5509                               ;; 02:54fc $30 $0b
    ld   A, [wDC1F]                                    ;; 02:54fe $fa $1f $dc
    cp   A, $01                                        ;; 02:5501 $fe $01
    jr   NZ, .jr_02_5509                               ;; 02:5503 $20 $04
    ld   A, L                                          ;; 02:5505 $7d
    add  A, $3c                                        ;; 02:5506 $c6 $3c
    ld   L, A                                          ;; 02:5508 $6f
.jr_02_5509:
    ld   A, L                                          ;; 02:5509 $7d
    ld   HL, wD801_Player_ActionId                                     ;; 02:550a $21 $01 $d8
    cp   A, [HL]                                       ;; 02:550d $be
    ret  Z                                             ;; 02:550e $c8
    ld   L, A                                          ;; 02:550f $6f
    ld   H, $00                                        ;; 02:5510 $26 $00
    ld   DE, data_02_554d                              ;; 02:5512 $11 $4d $55
    add  HL, DE                                        ;; 02:5515 $19
    bit  0, [HL]                                       ;; 02:5516 $cb $46
    jr   NZ, .jr_02_552e                               ;; 02:5518 $20 $14
    ld   HL, wDC79                                     ;; 02:551a $21 $79 $dc
    bit  7, [HL]                                       ;; 02:551d $cb $7e
    jr   Z, .jr_02_5524                                ;; 02:551f $28 $03
    ld   HL, wD801_Player_ActionId                                     ;; 02:5521 $21 $01 $d8
.jr_02_5524:
    ld   L, [HL]                                       ;; 02:5524 $6e
    ld   H, $00                                        ;; 02:5525 $26 $00
    ld   DE, data_02_554d                              ;; 02:5527 $11 $4d $55
    add  HL, DE                                        ;; 02:552a $19
    bit  1, [HL]                                       ;; 02:552b $cb $4e
    ret  NZ                                            ;; 02:552d $c0
.jr_02_552e:
    ld   [wDC79], A                                    ;; 02:552e $ea $79 $dc
    xor  A, A                                          ;; 02:5531 $af
    ld   [wDC7F_Player_IsAttacking], A                                    ;; 02:5532 $ea $7f $dc
    ld   A, $00                                        ;; 02:5535 $3e $00
    ld   [wDC7A], A                                    ;; 02:5537 $ea $7a $dc
    ret                                                ;; 02:553a $c9

call_02_553b_PollForSpecialInput:
; Purpose: Checks if a specific input bit ($20) is pressed.
; Behavior:
; Calls call_02_5541_GetActionPropertyByte to fetch current input/action data.
; Returns Z/NZ depending on whether the special bit is set.
    call call_02_5541_GetActionPropertyByte                                  ;; 02:553b $cd $41 $55
    and  A, $20                                        ;; 02:553e $e6 $20
    ret                                                ;; 02:5540 $c9

call_02_5541_GetActionPropertyByte:
; Purpose: Helper to fetch the property byte for the current action.
; Behavior:
; Uses the current action ID (wD801) as an index into data_02_554d.
; Returns the byte containing action flags (e.g., input mask, movement rules).
    ld   HL, wD801_Player_ActionId                                     ;; 02:5541 $21 $01 $d8
    ld   L, [HL]                                       ;; 02:5544 $6e
    ld   H, $00                                        ;; 02:5545 $26 $00
    ld   DE, data_02_554d                              ;; 02:5547 $11 $4d $55
    add  HL, DE                                        ;; 02:554a $19
    ld   A, [HL]                                       ;; 02:554b $7e
    ret                                                ;; 02:554c $c9

data_02_554d:
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:554d ........
    db   $00, $04, $0f, $0f, $07, $07, $00, $00        ;; 02:5555 ?.......
    db   $00, $00, $04, $00, $00, $04, $04, $04        ;; 02:555d ...?????
    db   $04, $20, $0f, $0f, $00, $00, $04, $20        ;; 02:5565 ???.????
    db   $20, $24, $80, $00, $00, $00, $00, $00        ;; 02:556d ????????
    db   $00, $04, $0f, $0f, $07, $07, $0f, $00        ;; 02:5575 ????????
    db   $00, $00, $00, $00, $00, $00, $04, $0f        ;; 02:557d ????????
    db   $0f, $07, $07, $0f, $00, $00, $00, $00        ;; 02:5585 ????????
    db   $00, $00, $00, $00, $00, $04, $0f, $0f        ;; 02:558d ????????
    db   $07, $07, $00, $00, $00, $00, $04, $00        ;; 02:5595 ????????
    db   $00, $04, $04, $04, $04, $20, $0f, $0f        ;; 02:559d ????????
    db   $00, $00, $04, $20, $20, $24, $80, $00        ;; 02:55a5 ????????
    db   $00, $00, $00, $00, $00, $04, $0f, $0f        ;; 02:55ad ????????
    db   $07, $07, $0f, $00, $00, $00, $00, $00        ;; 02:55b5 ????????
    db   $00, $00, $04, $0f, $0f, $07, $07, $0f        ;; 02:55bd ????????

data_02_55c5:
    db   $b5, $56, $b8, $56, $b8, $56, $eb, $56        ;; 02:55c5 ........
    db   $12, $57, $15, $57, $00, $00, $00, $00        ;; 02:55cd ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:55d5 ??......
    db   $00, $00, $00, $00, $44, $57, $44, $57        ;; 02:55dd ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:55e5 ......??
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:55ed ????????
    db   $00, $00, $57, $57, $00, $00, $00, $00        ;; 02:55f5 ??????..
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:55fd ????????
    db   $6a, $57, $00, $00, $00, $00, $8f, $57        ;; 02:5605 ????????
    db   $92, $57, $b7, $57, $b7, $57, $00, $00        ;; 02:560d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:5615 ????????
    db   $00, $00, $00, $00, $00, $00, $79, $57        ;; 02:561d ????????
    db   $00, $00, $7c, $57, $00, $00, $7c, $57        ;; 02:5625 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:562d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:5635 ????????
    db   $ca, $57, $cd, $57, $cd, $57, $f2, $57        ;; 02:563d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:5645 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:564d ????????
    db   $00, $00, $00, $00, $1b, $58, $1b, $58        ;; 02:5655 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:565d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:5665 ????????
    db   $00, $00, $57, $57, $00, $00, $00, $00        ;; 02:566d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:5675 ????????
    db   $6a, $57, $00, $00, $00, $00, $8f, $57        ;; 02:567d ????????
    db   $92, $57, $b7, $57, $b7, $57, $00, $00        ;; 02:5685 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:568d ????????
    db   $00, $00, $00, $00, $00, $00, $79, $57        ;; 02:5695 ????????
    db   $00, $00, $7c, $57, $00, $00, $7c, $57        ;; 02:569d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:56a5 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 02:56ad ????????
    db   $fe, $01, $ff, $50, $03, $10, $03, $90        ;; 02:56b5 .w..w.w.
    db   $04, $80, $04, $a0, $04, $20, $03, $60        ;; 02:56bd ?.w.?.w.
    db   $03, $01, $10, $41, $10, $51, $10, $11        ;; 02:56c5 ?.w.?.?.
    db   $10, $91, $10, $81, $10, $a1, $10, $21        ;; 02:56cd w.?.?.?.
    db   $10, $61, $10, $02, $0e, $42, $0e, $52        ;; 02:56d5 w.?.w.?.
    db   $0e, $12, $0e, $92, $0e, $82, $0e, $a2        ;; 02:56dd ?.w.?.?.
    db   $0e, $22, $0e, $62, $0e, $ff, $01, $10        ;; 02:56e5 ?.w.?..w
    db   $41, $10, $51, $10, $11, $10, $91, $10        ;; 02:56ed .?.?.w.w
    db   $81, $10, $a1, $10, $21, $10, $61, $10        ;; 02:56f5 .?.?.w.?
    db   $12, $0e, $22, $0e, $52, $0e, $62, $0e        ;; 02:56fd .w.w.?.?
    db   $80, $07, $90, $07, $a0, $07, $40, $01        ;; 02:5705 .?.w.w.w
    db   $03, $01, $00, $01, $ff, $00, $01, $ff        ;; 02:570d .?.w..w.
    db   $82, $0e, $92, $0e, $a2, $0e, $12, $0e        ;; 02:5715 .?.?.?.?
    db   $22, $0e, $42, $0e, $52, $0e, $62, $0e        ;; 02:571d .?.?.?.?
    db   $01, $10, $41, $10, $51, $10, $11, $10        ;; 02:5725 .?.?.?.?
    db   $91, $10, $81, $10, $a1, $10, $21, $10        ;; 02:572d .?.?.w.?
    db   $61, $10, $40, $06, $50, $06, $60, $06        ;; 02:5735 .?.?.?.?
    db   $10, $03, $20, $03, $00, $06, $ff, $01        ;; 02:573d .w.?.w..
    db   $10, $41, $10, $51, $10, $11, $10, $91        ;; 02:5745 w.?.?.w.
    db   $10, $81, $10, $a1, $10, $21, $10, $61        ;; 02:574d ?.?.?.w.
    db   $10, $ff, $01, $1f, $41, $1f, $51, $1f        ;; 02:5755 ?.??????
    db   $11, $1f, $91, $1f, $81, $1f, $a1, $1f        ;; 02:575d ????????
    db   $21, $1f, $61, $1f, $ff, $02, $0f, $42        ;; 02:5765 ????????
    db   $0f, $52, $0f, $12, $0f, $22, $0f, $62        ;; 02:576d ????????
    db   $0f, $80, $21, $ff, $fe, $30, $ff, $01        ;; 02:5775 ????????
    db   $34, $41, $34, $51, $34, $11, $34, $91        ;; 02:577d ????????
    db   $34, $81, $34, $a1, $34, $21, $34, $61        ;; 02:5785 ????????
    db   $34, $ff, $fe, $24, $ff, $01, $27, $41        ;; 02:578d ????????
    db   $27, $51, $27, $11, $27, $91, $27, $81        ;; 02:5795 ????????
    db   $27, $a1, $27, $21, $27, $61, $27, $02        ;; 02:579d ????????
    db   $25, $42, $25, $52, $25, $12, $25, $92        ;; 02:57a5 ????????
    db   $25, $82, $25, $a2, $25, $22, $25, $62        ;; 02:57ad ????????
    db   $25, $ff, $01, $27, $41, $27, $51, $27        ;; 02:57b5 ????????
    db   $11, $27, $91, $27, $81, $27, $a1, $27        ;; 02:57bd ????????
    db   $21, $27, $61, $27, $ff, $fe, $3d, $ff        ;; 02:57c5 ????????
    db   $40, $3f, $50, $3f, $10, $3f, $90, $3f        ;; 02:57cd ????????
    db   $80, $3f, $a0, $3f, $20, $3f, $60, $3f        ;; 02:57d5 ????????
    db   $01, $4c, $02, $4a, $42, $4a, $52, $4a        ;; 02:57dd ????????
    db   $12, $4a, $92, $4a, $82, $4a, $a2, $4a        ;; 02:57e5 ????????
    db   $22, $4a, $62, $4a, $ff, $01, $4c, $41        ;; 02:57ed ????????
    db   $4c, $51, $4c, $11, $4c, $91, $4c, $81        ;; 02:57f5 ????????
    db   $4c, $a1, $4c, $21, $4c, $61, $4c, $02        ;; 02:57fd ????????
    db   $4a, $42, $4a, $52, $4a, $12, $4a, $92        ;; 02:5805 ????????
    db   $4a, $82, $4a, $a2, $4a, $22, $4a, $62        ;; 02:580d ????????
    db   $4a, $03, $3d, $00, $3d, $ff, $01, $4c        ;; 02:5815 ????????
    db   $41, $4c, $51, $4c, $11, $4c, $91, $4c        ;; 02:581d ????????
    db   $81, $4c, $a1, $4c, $21, $4c, $61, $4c        ;; 02:5825 ????????
    db   $ff                                           ;; 02:582d ?
