; Relevant wRAM notes:
; Many are multi-collectible handlers (wDCC5–wDCCF).
; Others are slot managers (activate/clear/increment).
; A few are conditional transforms (load new object data depending on state or player).
; Counters (wDCCA–wDCCD, wDCCC, etc.) are collectible progress trackers.
; Transformations usually load new object data from a bank depending on state.
; Slot functions either set/clear/accumulate object slot values.
; Special flags (wDCD2, wDC88) are level or event triggers.

call_03_4c38_UpdateObjectCollision_Dispatch:
; Main dispatcher: checks if collisions enabled (wDCA7).
; Reads per-object collision type/index, decrements a cooldown if nonzero.
; Uses jump table .data_03_4c63_ObjectCollisionJumpTable to call the right handler.
    ld   A, [wDCA7]                                    ;; 03:4c38 $fa $a7 $dc
    and  A, A                                          ;; 03:4c3b $a7
    ret  Z                                             ;; 03:4c3c $c8
    ld   H, $d8                                        ;; 03:4c3d $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                  ;; 03:4c3f $fa $00 $da
    or   A, OBJECT_UNK15_OFFSET                                        ;; 03:4c42 $f6 $15
    ld   L, A                                          ;; 03:4c44 $6f
    ld   A, [HL]                                       ;; 03:4c45 $7e
    and  A, A                                          ;; 03:4c46 $a7
    jr   Z, .jr_03_4c4a                                ;; 03:4c47 $28 $01
    dec  [HL]                                          ;; 03:4c49 $35
.jr_03_4c4a:
    ld   A, L                                          ;; 03:4c4a $7d
    xor  A, $10                                        ;; 03:4c4b $ee $10
    ld   L, A                                          ;; 03:4c4d $6f
    bit  0, [HL]                                       ;; 03:4c4e $cb $46
    ret  NZ                                            ;; 03:4c50 $c0
    ld   A, L                                          ;; 03:4c51 $7d
    xor  A, $11                                        ;; 03:4c52 $ee $11
    ld   L, A                                          ;; 03:4c54 $6f
    ld   L, [HL]                                       ;; 03:4c55 $6e
    res  7, L                                          ;; 03:4c56 $cb $bd
    ld   H, $00                                        ;; 03:4c58 $26 $00
    add  HL, HL                                        ;; 03:4c5a $29
    ld   BC, .data_03_4c63_ObjectCollisionJumpTable    ;; 03:4c5b $01 $63 $4c
    add  HL, BC                                        ;; 03:4c5e $09
    ld   A, [HL+]                                      ;; 03:4c5f $2a
    ld   H, [HL]                                       ;; 03:4c60 $66
    ld   L, A                                          ;; 03:4c61 $6f
    jp   HL                                            ;; 03:4c62 $e9
.data_03_4c63_ObjectCollisionJumpTable:
    dw   call_03_4ccf_CollisionHandler_None                                 ;; 03:4c63 pP
    dw   call_03_56c1_CheckPlayerObjectCollision_Main
    dw   call_03_4cd0_Collision_PlayerHitGeneric
    dw   call_03_4cd7_Collision_PlayerHit_RemoveObject                  ;; 03:4c65 ??????
    dw   call_03_4ce1_Collision_PlayerHit_ActionSwitch                                 ;; 03:4c6b pP
    dw   call_03_4d38_Collision_PlayerHit_GenericOrRespawn
    dw   call_03_4d44_Collision_PlayerHit_ActionChangeConditional                            ;; 03:4c6d ????
    dw   call_03_4d9b_Collision_PlayerHit_SetLevelFlag                                 ;; 03:4c71 pP
    dw   call_03_4db3_Collision_PlayerHit_IncrementCounter                                 ;; 03:4c73 pP
    dw   call_03_4dc2_Collision_PlayerHit_CollectibleTracker                                 ;; 03:4c75 pP
    dw   call_03_4e04_Collision_PlayerHit_TriggerPhaseChange
    dw   call_03_4e31_Collision_PlayerHit_SetObjectState                           ;; 03:4c77 ????
    dw   call_03_4e4b_Collision_PlayerHit_MultiStageCollectible                                 ;; 03:4c7b pP
    dw   call_03_4e89_Collision_ObjectStateOrTransform                                 ;; 03:4c7d pP
    dw   call_03_4f23_Collision_ObjectCounterDecrement                                 ;; 03:4c7f pP
    dw   call_03_4f60_Collision_TripleCollectible_Counter
    dw   call_03_4f8c_Collision_PlaySoundAndRemove
    dw   call_03_4f98_Collision_ObjectActivateIfAction5
    dw   call_03_4fad_Collision_TransformIfIdle        ;; 03:4c81 ????????
    dw   call_03_4fca_Collision_TripleCollectible_TypeB
    dw   call_03_4ff1_Collision_TripleCollectible_TypeC
    dw   call_03_500d_Collision_IdleToLoadedTransform
    dw   call_03_50b6_Collision_TripleCollectible_WithSlot        ;; 03:4c89 ????????
    dw   call_03_50e0_Collision_ActivateSlot
    dw   call_03_50ea_Collision_ClearSlot
    dw   call_03_50f4_Collision_SlotIncrementTransform
    dw   call_03_5116_Collision_ConditionalTransform_Sound18or1B        ;; 03:4c91 ????????
    dw   call_03_5156_Collision_ConditionalTransform_Bank3
    dw   call_03_5196_Collision_RespawnOrActivateSlot
    dw   call_03_51b8_Collision_TransformOrSlotBurst
    dw   call_03_5201_Collision_TransformOrSlotSet        ;; 03:4c99 ????????
    dw   call_03_5231_Collision_Counter4_LevelGate
    dw   call_03_5274_Collision_ClearSlot_OnType2
    dw   call_03_528c_Collision_TripleCollectible_Counter2
    dw   call_03_52aa_Collision_QuintCollectible_Counter3        ;; 03:4ca1 ????????
    dw   call_03_52c8_Collision_FacingSensitiveHit
    dw   call_03_52da_Collision_RespawnOrTransform
    dw   call_03_52fa_Collision_ActionSwitchOrTransform
    dw   call_03_531a_Collision_SlotSetIfFlags        ;; 03:4ca9 ????????
    dw   call_03_532f_Collision_DecrementCounterBank4
    dw   call_03_537a_Collision_SlotIndexAccumulator
    dw   call_03_538e_Collision_HeptCollectibleToBank1
    dw   call_03_53eb_Collision_Action2Transform        ;; 03:4cb1 ????????
    dw   call_03_5406_Collision_ProximityTransform_Bank6
    dw   call_03_5469_Collision_ClearObjectAlways                            ;; 03:4cb9 ????
    dw   call_03_5473_Collision_SetEvent81                                 ;; 03:4cbd pP
    dw   call_03_5028_Collision_ConditionalTransformByDistance
    dw   call_03_5069_Collision_QuintCollectible
    dw   call_03_5085_Collision_TransformOrRespawnSwitch
    dw   call_03_5483_Collision_YMapTransform        ;; 03:4cbf ????????
    dw   call_03_54a8_Collision_PropertyBasedTransform                                   ;; 03:4cc7 ??
    dw   call_03_581a_CheckPlayerObjectCollision_Simple                                  ;; 03:4cc9 pP
    dw   call_03_54ee_Collision_TransformBank0AndSetTimer
    dw   call_03_53c2_Collision_TransformIfFlagClear                           ;; 03:4ccb ????

call_03_4ccf_CollisionHandler_None:
; Does nothing, just returns.
; Acts as a “null” collision handler.
    ret                                                ;; 03:4ccf $c9

call_03_4cd0_Collision_PlayerHitGeneric:
; Checks for player-object interaction.
; If collision is detected (carry set), jumps to call_00_06f6_HandleGenericHitResponse (probably a generic “hit” or interaction response).
; Otherwise returns.
    call call_03_550e_CheckPlayerObjectInteraction
    jp   c,call_00_06f6_HandleGenericHitResponse
    ret  

call_03_4cd7_Collision_PlayerHit_RemoveObject:
; Calls CheckPlayerObjectInteraction.
; If no collision → return. If collision → calls call_03_4cea_TriggerPlayerActionChange (special interaction routine), 
; then clears the object from memory.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    call call_03_4cea_TriggerPlayerActionChange
    jp   call_00_2b80_ClearObjectMemoryEntry

call_03_4ce1_Collision_PlayerHit_ActionSwitch:
; Calls CheckPlayerObjectInteraction.
; If collision and A!=0, jumps to HandleObjectHitOrRespawn.
; If A==0, falls into call_03_4cea_TriggerPlayerActionChange.
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4ce1 $cd $0e $55
    ret  NC                                            ;; 03:4ce4 $d0
    cp   A, $00                                        ;; 03:4ce5 $fe $00
    jp   NZ, call_03_5671_HandleObjectHitOrRespawn                                ;; 03:4ce7 $c2 $71 $56
    
call_03_4cea_TriggerPlayerActionChange:
; Reads player action ID. If certain actions (09, 29, 36) → skip. Otherwise, if not 45, calls HandleGenericHitResponse.
; Then calculates player vs object X difference, stores facing direction in wDC98.
; Depending on level ID (07, 08), sets a return bank (player action variant).
; Switches player action by calling into banked routine.
; This is basically a player transformation / state-change trigger.
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:4cea $fa $01 $d8
    cp   A, $09                                        ;; 03:4ced $fe $09
    jr   Z, .jr_03_4cfe                                ;; 03:4cef $28 $0d
    cp   A, $29                                        ;; 03:4cf1 $fe $29
    jr   Z, .jr_03_4cfe                                ;; 03:4cf3 $28 $09
    cp   A, $36                                        ;; 03:4cf5 $fe $36
    jr   Z, .jr_03_4cfe                                ;; 03:4cf7 $28 $05
    cp   A, $45                                        ;; 03:4cf9 $fe $45
    call NZ, call_00_06f6_HandleGenericHitResponse                              ;; 03:4cfb $c4 $f6 $06
.jr_03_4cfe:
    ld   H, $d8                                        ;; 03:4cfe $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:4d00 $fa $00 $da
    or   A, OBJECT_XPOS_OFFSET                                        ;; 03:4d03 $f6 $0e
    ld   L, A                                          ;; 03:4d05 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4d06 $fa $0e $d8
    sub  A, [HL]                                       ;; 03:4d09 $96
    inc  HL                                            ;; 03:4d0a $23
    ld   A, [wD80F_PlayerXPosition]                                    ;; 03:4d0b $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:4d0e $9e
    ld   A, $ff                                        ;; 03:4d0f $3e $ff
    jr   C, .jr_03_4d15                                ;; 03:4d11 $38 $02
    ld   A, $01                                        ;; 03:4d13 $3e $01
.jr_03_4d15:
    ld   [wDC98], A                                    ;; 03:4d15 $ea $98 $dc
    ld   A, [wDB6C_CurrentMapId]                                    ;; 03:4d18 $fa $6c $db
    cp   A, $07                                        ;; 03:4d1b $fe $07
    ld   A, $29                                        ;; 03:4d1d $3e $29
    jr   Z, .jr_03_4d2c                                ;; 03:4d1f $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 03:4d21 $fa $6c $db
    cp   A, $08                                        ;; 03:4d24 $fe $08
    ld   A, $36                                        ;; 03:4d26 $3e $36
    jr   Z, .jr_03_4d2c                                ;; 03:4d28 $28 $02
    ld   A, $09                                        ;; 03:4d2a $3e $09
.jr_03_4d2c:
    farcall entry_02_54f9_SwitchPlayerAction
    ret                                                ;; 03:4d37 $c9

call_03_4d38_Collision_PlayerHit_GenericOrRespawn:
; If collision, checks A. If zero, generic hit. Otherwise, goes to respawn handler.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$00
    jp   z,call_00_06f6_HandleGenericHitResponse
    jp   entry_03_5671_HandleObjectHitOrRespawn

call_03_4d44_Collision_PlayerHit_ActionChangeConditional:
; Similar to above but excludes some player actions (09, 29, 36, 45).
; On collision: if A==01, goes to respawn handler. Otherwise sets timer, 
; calculates relative position, sets facing direction, and triggers action change (like 4cea).
    ld   a,[wD801_PlayerObject_ActionId]
    cp   a,$09
    ret  z
    cp   a,$29
    ret  z
    cp   a,$36
    ret  z
    cp   a,$45
    ret  z
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   z,entry_03_5671_HandleObjectHitOrRespawn
    ld   a,$3C
    ld   [wDC7E],a
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80F_PlayerXPosition]
    sbc  [hl]
    ld   a,$FF
    jr   c,.label4D78
    ld   a,$01
.label4D78:
    ld   [wDC98],a
    ld   a,[wDB6C_CurrentMapId]
    cp   a,$07
    ld   a,$29
    jr   z,.label4D8F
    ld   a,[wDB6C_CurrentMapId]
    cp   a,$08
    ld   a,$36
    jr   z,.label4D8F
    ld   a,$09
.label4D8F:
    farcall entry_02_54f9_SwitchPlayerAction
    ret  

call_03_4d9b_Collision_PlayerHit_SetLevelFlag:
; If collision: sets per-level progress bit (bit4 of level data), plays sound 02, then handles respawn/hit.
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4d9b $cd $0e $55
    ret  NC                                            ;; 03:4d9e $d0
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 03:4d9f $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4da2 $6e
    ld   H, $00                                        ;; 03:4da3 $26 $00
    ld   DE, wDC5C                                     ;; 03:4da5 $11 $5c $dc
    add  HL, DE                                        ;; 03:4da8 $19
    set  4, [HL]                                       ;; 03:4da9 $cb $e6
    ld   A, $02                                        ;; 03:4dab $3e $02
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 03:4dad $cd $f5 $0f
    jp   call_03_5671_HandleObjectHitOrRespawn                                    ;; 03:4db0 $c3 $71 $56

call_03_4db3_Collision_PlayerHit_IncrementCounter:
; If collision: calls IncrementProgressCounter, plays sound 02, then handles respawn/hit.
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4db3 $cd $0e $55
    ret  NC                                            ;; 03:4db6 $d0
    call call_00_0723_IncrementProgressCounter                                  ;; 03:4db7 $cd $23 $07
    ld   A, $02                                        ;; 03:4dba $3e $02
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 03:4dbc $cd $f5 $0f
    jp   call_03_5671_HandleObjectHitOrRespawn                                    ;; 03:4dbf $c3 $71 $56

call_03_4dc2_Collision_PlayerHit_CollectibleTracker:
; If collision:
; Resolves object index via call_00_230f_ResolveObjectListIndex.
; Looks up a flag mask (00, 20, 40, 80).
; ORs it into level data, increments wDCAF.
; Every 4 collected, increments wDC4F (if <4), resets counter, sets flag in wDB69.
; Plays sound 02, then handles respawn/hit.
; This is basically a collectible counter with milestones.
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4dc2 $cd $0e $55
    ret  NC                                            ;; 03:4dc5 $d0
    call call_00_230f_ResolveObjectListIndex                                  ;; 03:4dc6 $cd $0f $23
    ld   B, $00                                        ;; 03:4dc9 $06 $00
    ld   HL, .data_03_4e00                             ;; 03:4dcb $21 $00 $4e
    add  HL, BC                                        ;; 03:4dce $09
    ld   C, [HL]                                       ;; 03:4dcf $4e
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 03:4dd0 $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4dd3 $6e
    ld   H, $00                                        ;; 03:4dd4 $26 $00
    ld   DE, wDC5C                                     ;; 03:4dd6 $11 $5c $dc
    add  HL, DE                                        ;; 03:4dd9 $19
    ld   A, [HL]                                       ;; 03:4dda $7e
    or   A, C                                          ;; 03:4ddb $b1
    ld   [HL], A                                       ;; 03:4ddc $77
    ld   HL, wDCAF                                     ;; 03:4ddd $21 $af $dc
    inc  [HL]                                          ;; 03:4de0 $34
    ld   A, [HL]                                       ;; 03:4de1 $7e
    sub  A, $04                                        ;; 03:4de2 $d6 $04
    jr   NZ, .jr_03_4df8                               ;; 03:4de4 $20 $12
    ld   HL, wDC4F                                     ;; 03:4de6 $21 $4f $dc
    ld   A, [HL]                                       ;; 03:4de9 $7e
    cp   A, $04                                        ;; 03:4dea $fe $04
    jr   Z, .jr_03_4df8                                ;; 03:4dec $28 $0a
    inc  [HL]                                          ;; 03:4dee $34
    xor  A, A                                          ;; 03:4def $af
    ld   [wDCAF], A                                    ;; 03:4df0 $ea $af $dc
    ld   HL, wDB69                                     ;; 03:4df3 $21 $69 $db
    set  1, [HL]                                       ;; 03:4df6 $cb $ce
.jr_03_4df8:
    ld   A, $02                                        ;; 03:4df8 $3e $02
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 03:4dfa $cd $f5 $0f
    jp   call_03_5671_HandleObjectHitOrRespawn                                    ;; 03:4dfd $c3 $71 $56
.data_03_4e00:
    db   $00, $20, $40, $80

call_03_4e04_Collision_PlayerHit_TriggerPhaseChange:
; If collision: gets object ID, looks up a state value in .data_03_4e2c, calls SetPhase_TimersAndFlags.
; Modifies object graphics/status, then clears the object.
; Looks like a pickup that triggers a phase/state change.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    call call_00_293a_ObjectGetId
    sub  a,04
    ld   l,a
    ld   h,00
    ld   de,.data_03_4e2c
    add  hl,de
    ld   a,[hl]
    call call_00_0624_SetPhase_TimersAndFlags
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_UNK1F_OFFSET
    ld   l,a
    ld   l,[hl]
    ld   h,$D7
    ld   a,[hl]
    and  a,$F0
    or   a,$03
    ld   [hl],a
    jp   call_00_2b80_ClearObjectMemoryEntry
.data_03_4e2c:
    db   $03, $04, $01, $05, $02

call_03_4e31_Collision_PlayerHit_SetObjectState:
; If object action ID==0 and collision detected with A==01: plays sound 03, 
; handles respawn, then sets object status low nibble to 02.
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    ld   a,$03
    call call_00_0ff5_QueueSoundEffectWithPriority
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   c,$02
    jp   call_00_2299_SetObjectStatusLowNibble

call_03_4e4b_Collision_PlayerHit_MultiStageCollectible:
; If object action ID<2 and collision A==01:
; Plays sound 19, increments action ID, updates object status nibble.
; Loads new object data (via banked routine).
; If new action ID==2, increments wDCC3.
; When wDCC3==5, triggers PlaySound_1E.
; Then dispatches new offset action.
; Basically a multi-stage collectible or progress item (like 5 items → trigger special event).
    call call_00_2962_ObjectGetActionId                                  ;; 03:4e4b $cd $62 $29
    cp   A, $02                                        ;; 03:4e4e $fe $02
    ret  NC                                            ;; 03:4e50 $d0
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4e51 $cd $0e $55
    ret  NC                                            ;; 03:4e54 $d0
    cp   A, $01                                        ;; 03:4e55 $fe $01
    ret  NZ                                            ;; 03:4e57 $c0
    ld   A, $19                                        ;; 03:4e58 $3e $19
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 03:4e5a $cd $f5 $0f
    call call_00_2962_ObjectGetActionId                                  ;; 03:4e5d $cd $62 $29
    inc  A                                             ;; 03:4e60 $3c
    push AF                                            ;; 03:4e61 $f5
    push AF                                            ;; 03:4e62 $f5
    ld   C, A                                          ;; 03:4e63 $4f
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 03:4e64 $cd $99 $22
    pop  AF                                            ;; 03:4e67 $f1
    farcall entry_02_72ac_LoadObjectData
    pop  AF                                            ;; 03:4e73 $f1
    cp   A, $02                                        ;; 03:4e74 $fe $02
    ret  NZ                                            ;; 03:4e76 $c0
    ld   HL, wDCC3                                     ;; 03:4e77 $21 $c3 $dc
    inc  [HL]                                          ;; 03:4e7a $34
    ld   A, [HL]                                       ;; 03:4e7b $7e
    cp   A, $05                                        ;; 03:4e7c $fe $05
    ld   C, $01                                        ;; 03:4e7e $0e $01
    call Z, call_00_21ef_PlaySound_1E                               ;; 03:4e80 $cc $ef $21
    ld   A, [wDCC3]                                    ;; 03:4e83 $fa $c3 $dc
    jp   call_00_2c09_DispatchOffsetAction                                  ;; 03:4e86 $c3 $09 $2c

call_03_4e89_Collision_ObjectStateOrTransform:
; Rejects if object “inactive” (bit 7 of property set) or action ≥ 5.
; If collision and result A==01:
; - Negates a property byte (ObjectGet1D), does distance check, looks up a value in 
;   .data_03_4efa (a table of progression values), writes it to object state.
; If collision A!=01:
; - Loads new object data from bank 6, then triggers a player action change.
    call call_00_28d2_ObjectGetYVelocity                                  ;; 03:4e89 $cd $d2 $28
    bit  7, A                                          ;; 03:4e8c $cb $7f
    ret  NZ                                            ;; 03:4e8e $c0
    call call_00_2962_ObjectGetActionId                                  ;; 03:4e8f $cd $62 $29
    cp   A, $05                                        ;; 03:4e92 $fe $05
    ret  NC                                            ;; 03:4e94 $d0
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4e95 $cd $0e $55
    ret  NC                                            ;; 03:4e98 $d0
    cp   A, $01                                        ;; 03:4e99 $fe $01
    jr   NZ, .jr_03_4eea                               ;; 03:4e9b $20 $4d
    call call_00_28d2_ObjectGetYVelocity                                  ;; 03:4e9d $cd $d2 $28
    cpl                                                ;; 03:4ea0 $2f
    inc  A                                             ;; 03:4ea1 $3c
    ld   [HL], A                                       ;; 03:4ea2 $77
    ld   C, $1e                                        ;; 03:4ea3 $0e $1e
    call call_00_29ce_ObjectExistsCheck                                  ;; 03:4ea5 $cd $ce $29
    jp   NZ, call_00_2b80_ClearObjectMemoryEntry                              ;; 03:4ea8 $c2 $80 $2b
    ld   A, L                                          ;; 03:4eab $7d
    or   A, OBJECT_XPOS_OFFSET                                        ;; 03:4eac $f6 $0e
    ld   L, A                                          ;; 03:4eae $6f
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:4eaf $fa $00 $da
    or   A, OBJECT_XPOS_OFFSET                                        ;; 03:4eb2 $f6 $0e
    ld   E, A                                          ;; 03:4eb4 $5f
    ld   D, $d8                                        ;; 03:4eb5 $16 $d8
    ld   A, [DE]                                       ;; 03:4eb7 $1a
    sub  A, [HL]                                       ;; 03:4eb8 $96
    ld   C, A                                          ;; 03:4eb9 $4f
    inc  HL                                            ;; 03:4eba $23
    inc  DE                                            ;; 03:4ebb $13
    ld   A, [DE]                                       ;; 03:4ebc $1a
    sbc  A, [HL]                                       ;; 03:4ebd $9e
    ld   B, A                                          ;; 03:4ebe $47
    push AF                                            ;; 03:4ebf $f5
    jr   NC, .jr_03_4ec9                               ;; 03:4ec0 $30 $07
    xor  A, A                                          ;; 03:4ec2 $af
    sub  A, C                                          ;; 03:4ec3 $91
    ld   C, A                                          ;; 03:4ec4 $4f
    ld   A, $00                                        ;; 03:4ec5 $3e $00
    sbc  A, B                                          ;; 03:4ec7 $98
    ld   B, A                                          ;; 03:4ec8 $47
.jr_03_4ec9:
    ld   A, B                                          ;; 03:4ec9 $78
    and  A, A                                          ;; 03:4eca $a7
    jr   NZ, .jr_03_4ed2                               ;; 03:4ecb $20 $05
    ld   A, C                                          ;; 03:4ecd $79
    cp   A, $a0                                        ;; 03:4ece $fe $a0
    jr   C, .jr_03_4ed4                                ;; 03:4ed0 $38 $02
.jr_03_4ed2:
    ld   A, $a0                                        ;; 03:4ed2 $3e $a0
.jr_03_4ed4:
    srl  A                                             ;; 03:4ed4 $cb $3f
    srl  A                                             ;; 03:4ed6 $cb $3f
    ld   L, A                                          ;; 03:4ed8 $6f
    ld   H, $00                                        ;; 03:4ed9 $26 $00
    ld   DE, .data_03_4efa                             ;; 03:4edb $11 $fa $4e
    add  HL, DE                                        ;; 03:4ede $19
    pop  AF                                            ;; 03:4edf $f1
    ld   A, [HL]                                       ;; 03:4ee0 $7e
    jr   C, .jr_03_4ee5                                ;; 03:4ee1 $38 $02
    cpl                                                ;; 03:4ee3 $2f
    inc  A                                             ;; 03:4ee4 $3c
.jr_03_4ee5:
    ld   C, A                                          ;; 03:4ee5 $4f
    call call_00_28c8_ObjectSetXVelocity                                  ;; 03:4ee6 $cd $c8 $28
    ret                                                ;; 03:4ee9 $c9
.jr_03_4eea:
    ld   A, $06                                        ;; 03:4eea $3e $06
    farcall entry_02_72ac_LoadObjectData
    jp   call_03_4cea_TriggerPlayerActionChange                                   ;; 03:4ef7 $c3 $ea $4c
.data_03_4efa:
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 03:4efa ???.????
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10        ;; 03:4f02 ????????
    db   $11, $12, $13, $14, $15, $16, $17, $18        ;; 03:4f0a ????????
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21        ;; 03:4f12 ????????
    db   $22, $23, $24, $25, $27, $28, $29, $2a        ;; 03:4f1a ????????
    db   $2b                                           ;; 03:4f22 ?

call_03_4f23_Collision_ObjectCounterDecrement:
; On collision:
; - If A!=01 → trigger player action change.
; - If A==01: loads new object data (bank 4), decrements per-object counter (wDCD5), 
;   clears object when it hits 0, increments wDCC8, dispatches offset action.
; - If all counters zero → play sound 1E.
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:4f23 $cd $0e $55
    ret  NC                                            ;; 03:4f26 $d0
    cp   A, $01                                        ;; 03:4f27 $fe $01
    jp   NZ, call_03_4cea_TriggerPlayerActionChange                               ;; 03:4f29 $c2 $ea $4c
    ld   A, $04                                        ;; 03:4f2c $3e $04
    farcall entry_02_72ac_LoadObjectData
    call call_00_230f_ResolveObjectListIndex                                  ;; 03:4f39 $cd $0f $23
    ld   B, $00                                        ;; 03:4f3c $06 $00
    ld   HL, wDCD5                                     ;; 03:4f3e $21 $d5 $dc
    add  HL, BC                                        ;; 03:4f41 $09
    ld   A, [HL]                                       ;; 03:4f42 $7e
    and  A, A                                          ;; 03:4f43 $a7
    ret  Z                                             ;; 03:4f44 $c8
    dec  [HL]                                          ;; 03:4f45 $35
    ret  NZ                                            ;; 03:4f46 $c0
    call call_00_288c_Object_Clear14                                  ;; 03:4f47 $cd $8a $28
    call call_00_2b8b_HandleObjectFlag6ClearOrInit                                  ;; 03:4f4a $cd $8b $2b
    ld   HL, wDCC8                                     ;; 03:4f4d $21 $c8 $dc
    inc  [HL]                                          ;; 03:4f50 $34
    ld   A, [HL]                                       ;; 03:4f51 $7e
    call call_00_2c09_DispatchOffsetAction                                  ;; 03:4f52 $cd $09 $2c
    ld   HL, wDCD5                                     ;; 03:4f55 $21 $d5 $dc
    ld   A, [HL+]                                      ;; 03:4f58 $2a
    or   A, [HL]                                       ;; 03:4f59 $b6
    ret  NZ                                            ;; 03:4f5a $c0
    ld   C, $02                                        ;; 03:4f5b $0e $02
    jp   call_00_21ef_PlaySound_1E                                  ;; 03:4f5d $c3 $ef $21

call_03_4f60_Collision_TripleCollectible_Counter:
; Only for objects in action 00.
; If collision with A==01:
; - Handles hit/respawn, plays sound 19, sets object status, increments wDCC5.
; - When wDCC5==3, plays sound 1E.
; - Dispatches offset action.
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   a,$19
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   c,$01
    call call_00_2299_SetObjectStatusLowNibble
    ld   hl,wDCC5
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCC5]
    jp   call_00_2c09_DispatchOffsetAction

call_03_4f8c_Collision_PlaySoundAndRemove:
; On any collision: plays sound 1E with parameter 3, then respawns/removes object.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    ld   c,$03
    call call_00_21ef_PlaySound_1E
    jp   entry_03_5671_HandleObjectHitOrRespawn

call_03_4f98_Collision_ObjectActivateIfAction5:
; On collision:
; - If A!=01 → trigger player action change.
; - If A==01: handle hit/respawn, check action ID, and if 05 → mark object slot active.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$05
    jp   z,call_00_22ef_SetObjectSlotActive
    ret  

call_03_4fad_Collision_TransformIfIdle:
; On collision A==01: if object’s action ID is 00, loads new object data (bank 1).
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call call_00_2995_ObjectGetActionId
    cp   a,$00
    ret  nz
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_4fca_Collision_TripleCollectible_TypeB:
; For action 00 only.
; On collision A==02:
; Handle hit/respawn, set status nibble 04, increment wDCC6.
; On 3rd collected, play sound 1E.
; Dispatch offset action.
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$02
    ret  nz
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   c,$04
    call call_00_2299_SetObjectStatusLowNibble
    ld   hl,wDCC6
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCC6]
    jp   call_00_2c09_DispatchOffsetAction
    
call_03_4ff1_Collision_TripleCollectible_TypeC:
; On collision A==01:
; - Handle hit/respawn, increment wDCC7.
; - On 3rd collected, play sound 1E.
; - Dispatch offset action.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   hl,wDCC7
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$01
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCC7]
    jp   call_00_2c09_DispatchOffsetAction
    
call_03_500d_Collision_IdleToLoadedTransform:
; For action 00 only.
; On collision A==01: transforms object via bank 1 loader.
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    ret  
   
call_03_5028_Collision_ConditionalTransformByDistance:
; Collision logic depends on nearby flags (wDCA9–wDCAB).
; Sometimes triggers hit/respawn if action ID < 5.
; Otherwise, for action 05, can trigger a player action change.
; If action < 4 and player within 0x28 in X vector → loads new object data (bank 5).
    call call_03_550e_CheckPlayerObjectInteraction
    jr   nc,label504C
    cp   a,$00
    jr   z,label5044
    ld   hl,wDCA9
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    jr   z,label5044
    call call_00_2962_ObjectGetActionId
    cp   a,$05
    call c,entry_03_5671_HandleObjectHitOrRespawn
    jr   label504C
label5044:
    call call_00_2962_ObjectGetActionId
    cp   a,$05
    call z,call_03_4cea_TriggerPlayerActionChange
label504C:
    call call_00_2962_ObjectGetActionId
    cp   a,$04
    ret  nc
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$28
    ret  nc
    ld   a,$05
    farcall entry_02_72ac_LoadObjectData
    ret  

call_03_5069_Collision_QuintCollectible:
; On collision where A!=00:
; - Handle hit/respawn, increment wDCCF.
; - On 5th collected, play sound 1E.
; - Dispatch offset action.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$00
    ret  z
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   hl,wDCCF
    inc  [hl]
    ld   a,[hl]
    cp   a,$05
    ld   c,$02
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCCF]
    jp   call_00_2c09_DispatchOffsetAction

call_03_5085_Collision_TransformOrRespawnSwitch:
; On collision:
; - If A!=01 → trigger player action change.
; - If A==01:
;   - Action ID==2 → load bank1 data.
;   - Action ID==1 → respawn handler.
;   - Else → load bank2 data.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call call_00_2962_ObjectGetActionId
    cp   a,$02
    jr   z,label50A8
    cp   a,$01
    jp   z,entry_03_5671_HandleObjectHitOrRespawn
    ld   a,$02
    farcall entry_02_72ac_LoadObjectData
    ret  
label50A8:
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    ret  

call_03_50b6_Collision_TripleCollectible_WithSlot:
; For action 00 only.
; On collision A==01:
; - Handle hit/respawn, mark slot active, set status, increment wDCC9.
; - On 3rd collected, play sound 1E.
; - Dispatch offset action.
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_22ef_SetObjectSlotActive
    ld   c,$02
    call call_00_2299_SetObjectStatusLowNibble
    ld   hl,wDCC9
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$01
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCC9]
    jp   call_00_2c09_DispatchOffsetAction

call_03_50e0_Collision_ActivateSlot:
; On collision A==01: marks object slot active.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   z,call_00_22ef_SetObjectSlotActive
    ret  
    
call_03_50ea_Collision_ClearSlot:
    ; On collision A==01: clears object slot.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   z,call_00_22ff_ClearObjectSlot
    ret  
    
call_03_50f4_Collision_SlotIncrementTransform:
; For action 00 only.
; On collision A==01: sets object status, loads new data (bank 1), increments object slot.
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    ld   c,$01
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    jp   call_00_22e0_IncrementObjectSlot
    
call_03_5116_Collision_ConditionalTransform_Sound18or1B:
; For action 00 only.
; On collision: requires certain global flags (wDABE, wDC81_CurrentInputs) and player action between 01–02.
; Checks object slot flag; plays sound 1B if not set, else sound 18.
; Loads new object data (bank 1).
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    ld   hl,wDABE
    bit  7,[hl]
    ret  z
    ld   hl,wDC81_CurrentInputs
    bit  6,[hl]
    ret  z
    ld   a,[wD801_PlayerObject_ActionId]
    cp   a,$01
    ret  c
    cp   a,$03
    ret  nc
    call call_00_230f_ResolveObjectListIndex
    inc  c
    jr   z,label5143
    call call_00_22d4_CheckObjectSlotFlag
    ld   a,$1B
    jp   z,call_00_0ff5_QueueSoundEffectWithPriority
label5143:
    ld   a,$18
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    ret  

call_03_5156_Collision_ConditionalTransform_Bank3:
; Same as above, but for action 02, and loads bank 3 data.
    call call_00_2962_ObjectGetActionId
    cp   a,$02
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    ld   hl,wDABE
    bit  7,[hl]
    ret  z
    ld   hl,wDC81_CurrentInputs
    bit  6,[hl]
    ret  z
    ld   a,[wD801_PlayerObject_ActionId]
    cp   a,$01
    ret  c
    cp   a,$03
    ret  nc
    call call_00_230f_ResolveObjectListIndex
    inc  c
    jr   z,label5183
    call call_00_22d4_CheckObjectSlotFlag
    ld   a,$1B
    jp   z,call_00_0ff5_QueueSoundEffectWithPriority
label5183:
    ld   a,$18
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$03
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_5196_Collision_RespawnOrActivateSlot:
; On collision:
; - If A!=01 → trigger action change.
; - If A==01: respawn handler, then if action ID==0 → transform to bank2 data; else mark slot active.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    jp   nz,call_00_22ef_SetObjectSlotActive
    ld   a,$02
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_51b8_Collision_TransformOrSlotBurst:
; On collision:
; - If A!=01 → trigger action change.
; - If A==01:
;   - If action==2 → activate slot, reset state, init particle burst, transform to bank7 data.
;   - Else → respawn handler, then either update status or transform to bank3 data.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call call_00_2962_ObjectGetActionId
    cp   a,$02
    jr   z,label51E3
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$02
    ld   c,$02
    jp   z,call_00_2299_SetObjectStatusLowNibble
    ld   a,$03
    farcall entry_02_72ac_LoadObjectData
    ret  
label51E3:
    call call_00_22ef_SetObjectSlotActive
    ld   c,$00
    call call_00_288c_Object_Set14
    ld   c,$00
    call call_00_2958_ObjectSetFacingDirection
    call call_00_2c67_Particle_InitBurst
    ld   a,$07
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_5201_Collision_TransformOrSlotSet:
; Skips if action ID = 3.
; If player collides and interaction = 1 → handle hit/respawn, then if action = 3 → set slot active.
; If interaction ≠ 1 → trigger player action change, load new object data (bank 2), face player left.
    call call_00_2962_ObjectGetActionId
    cp   a,$03
    ret  z
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jr   z,label5222
    call call_03_4cea_TriggerPlayerActionChange
    ld   a,$02
    farcall entry_02_72ac_LoadObjectData
    jp   call_00_2410_Object_SetFacingRelativeToPlayer
label5222:
    call call_00_2410_Object_SetFacingRelativeToPlayer
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$03
    jp   z,call_00_22ef_SetObjectSlotActive
    ret  
    
call_03_5231_Collision_Counter4_LevelGate:
; If collision →
; - If interaction ≠ 1 → player action change.
; - If = 1 and wDCA9–wDCAB flags are set:
;   - Handle hit/respawn, increment wDCCB.
;   - Every 4th, play sound 1E, then dispatch offset action.
; Special case for levels $29/$2A only.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    ld   hl,wDCA9
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    ret  z
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$01
    ret  nz
    call call_00_22e0_IncrementObjectSlot
    ld   a,[wDB6C_CurrentMapId]
    cp   a,$29
    jr   z,label5258
    cp   a,$2A
    ret  nz
label5258:
    ld   hl,wDCCB
    inc  [hl]
    ld   a,[hl]
    cp   a,$04
    ld   c,$03
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCCB]
    jp   call_00_2c09_DispatchOffsetAction
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$00
    jp   z,call_03_4cea_TriggerPlayerActionChange
    ret  
    
call_03_5274_Collision_ClearSlot_OnType2:
; On collision, only if interaction = 2.
; Handles hit/respawn, if action=1 → play sound 1E (#2), clear object slot.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$02
    ret  nz
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$01
    ret  nz
    ld   c,$02
    call call_00_21ef_PlaySound_1E
    jp   call_00_22ff_ClearObjectSlot
    
call_03_528c_Collision_TripleCollectible_Counter2:
; On collision, if interaction ≠ 0 → handle hit/respawn, increment wDCCA.
; Every 3rd → play sound 1E (#2).
; Always dispatch offset action.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$00
    jp   z,call_03_4cea_TriggerPlayerActionChange
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   hl,wDCCA
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCCA]
    jp   call_00_2c09_DispatchOffsetAction
    
call_03_52aa_Collision_QuintCollectible_Counter3:
; On collision (interaction=1):
; Handle hit/respawn, increment wDCCD.
; Every 5th → play sound 1E (#3).
; Dispatch offset action.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   hl,wDCCD
    inc  [hl]
    ld   a,[hl]
    cp   a,$05
    ld   c,$03
    call z,call_00_21ef_PlaySound_1E
    ld   a,[wDCCD]
    jp   call_00_2c09_DispatchOffsetAction
    
call_03_52c8_Collision_FacingSensitiveHit:
; On collision (interaction=1):
; - If object facing doesn’t match stored direction → handle hit/respawn.
; - Else → just player action change.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call call_00_29ac_ObjectFacingMatchesStoredDirection
    jp   z,call_03_4cea_TriggerPlayerActionChange
    jp   entry_03_5671_HandleObjectHitOrRespawn
    
call_03_52da_Collision_RespawnOrTransform:
; On collision (interaction=1):
; - Handle hit/respawn.
; - If action ≠ 3 → load new object data (bank 2).
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2962_ObjectGetActionId
    cp   a,$03
    ret  z
    ld   a,$02
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_52fa_Collision_ActionSwitchOrTransform:
; If object is action=4 → special hit handler.
; If action=2 and collision=1 → load new data (bank 3).
    call call_00_2962_ObjectGetActionId
    cp   a,$04
    jp   z,call_03_4ce1_Collision_PlayerHit_ActionSwitch
    cp   a,$02
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    ld   a,$03
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_531a_Collision_SlotSetIfFlags:
; On collision (interaction=1):
; - If wDCA9–wDCAB flags set → handle hit/respawn, then set slot active.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    ld   hl,wDCA9
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    ret  z
    call entry_03_5671_HandleObjectHitOrRespawn
    jp   call_00_22ef_SetObjectSlotActive
    
call_03_532f_Collision_DecrementCounterBank4:
; Works for actions < 4 only.
; On collision (interaction=1):
; - Loads new data (bank 4).
; - Decrements object counter wDCD5.
; - If zero → clear object, increment wDCC8, dispatch action.
; - If all counters = 0 → set wDCD2=1 (event flag).
    call call_00_2962_ObjectGetActionId
    cp   a,$04
    ret  nc
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    ld   a,$04
    farcall entry_02_72ac_LoadObjectData
    call call_00_230f_ResolveObjectListIndex
    ld   b,$00
    ld   hl,wDCD5
    add  hl,bc
    ld   a,[hl]
    and  a
    ret  z
    dec  [hl]
    ret  nz
    call call_00_288c_Object_Clear14
    call call_00_2b8b_HandleObjectFlag6ClearOrInit
    ld   hl,wDCC8
    inc  [hl]
    ld   a,[hl]
    call call_00_2c09_DispatchOffsetAction
    ld   hl,wDCD5
    ld   b,$05
    xor  a
label536D:
    or   [hl]
    inc  hl
    dec  b
    jr   nz,label536D
    and  a
    ret  nz
    ld   a,$01
    ld   [wDCD2],a
    ret  
    
call_03_537a_Collision_SlotIndexAccumulator:
; On collision (interaction=1):
; - Adds slot index to wDB6E.
; - Handles hit/respawn.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    call call_00_230f_ResolveObjectListIndex
    ld   a,[wDB6E]
    add  c
    ld   [wDB6E],a
    jp   entry_03_5671_HandleObjectHitOrRespawn
    
call_03_538e_Collision_HeptCollectibleToBank1:
; On collision (interaction=1):
; - If action=0 → increment wDCCC, dispatch action, set wDCD2=1 when =7.
; - Always load new data (bank 1), set status nibble=2.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    jr   nz,label53B0
    ld   hl,wDCCC
    inc  [hl]
    ld   a,[hl]
    call call_00_2c09_DispatchOffsetAction
    ld   a,[wDCCC]
    cp   a,$07
    jr   nz,label53B0
    ld   a,$01
    ld   [wDCD2],a
label53B0:
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    ld   c,$02
    jp   call_00_2299_SetObjectStatusLowNibble

call_03_53c2_Collision_TransformIfFlagClear:
; For actions < 5.
; If action=3: only transform if wDC88=0.
; Else, collision (interaction=1) → handle hit/respawn.
    call call_00_2962_ObjectGetActionId
    cp   a,$05
    ret  nc
    cp   a,$03
    jr   z,label53D6
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   z,entry_03_5671_HandleObjectHitOrRespawn
    ret  
label53D6:
    ld   a,[wDC88]
    and  a
    ret  nz
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    jp   call_03_4cea_TriggerPlayerActionChange
    
call_03_53eb_Collision_Action2Transform:
; For action=2 only.
; On collision (interaction=1): loads new data (bank 3).
    call call_00_2962_ObjectGetActionId
    cp   a,$02
    ret  nz
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    ret  nz
    ld   a,$03
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_5406_Collision_ProximityTransform_Bank6:
; Complex distance check against another object.
; If player is within a 0x0C–0x18 box both X and Y:
; - Handle hit/respawn.
; - If action≠7 → transform to bank 6.
    call call_03_4ce1_Collision_PlayerHit_ActionSwitch
    call call_00_2995_ObjectGetActionId
    cp   a,$06
    ret  nc
    ld   c,$68
    call call_00_29ce_ObjectExistsCheck
    ret  nz
    ld   a,l
    or   a,$1D
    ld   l,a
    bit  7,[hl]
    ret  z
    ld   a,l
    xor  a,$13
    ld   l,a
    ld   d,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_XPOS_OFFSET
    ld   e,a
    ld   a,[de]
    sub  [hl]
    ld   c,a
    inc  de
    inc  hl
    ld   a,[de]
    sbc  [hl]
    ld   b,a
    ld   a,c
    add  a,$0C
    ld   c,a
    ld   a,b
    adc  a,$00
    ret  nz
    ld   a,c
    cp   a,$18
    ret  nc
    inc  de
    inc  hl
    ld   a,[de]
    sub  [hl]
    ld   c,a
    inc  de
    inc  hl
    ld   a,[de]
    sbc  [hl]
    ld   b,a
    ld   a,c
    add  a,$0C
    ld   c,a
    ld   a,b
    adc  a,$00
    ret  nz
    ld   a,c
    cp   a,$18
    ret  nc
    call entry_03_5671_HandleObjectHitOrRespawn
    call call_00_2995_ObjectGetActionId
    cp   a,$07
    ret  z
    ld   a,$06
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_5469_Collision_ClearObjectAlways:
; On collision (any interaction): player action change, clear object.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    call call_03_4cea_TriggerPlayerActionChange
    jp   call_00_2b7a_ClearObjectThenJump

call_03_5473_Collision_SetEvent81:
; On collision (interaction=1): set wDCD2=0x81 (event flag).
    call call_03_550e_CheckPlayerObjectInteraction                                  ;; 03:5473 $cd $0e $55
    ret  NC                                            ;; 03:5476 $d0
    cp   A, $01                                        ;; 03:5477 $fe $01
    ret  NZ                                            ;; 03:5479 $c0
    call call_00_2962_ObjectGetActionId                                  ;; 03:547a $cd $62 $29
    ld   A, $81                                        ;; 03:547d $3e $81
    ld   [wDCD2], A                                    ;; 03:547f $ea $d2 $dc
    ret                                                ;; 03:5482 $c9
    
call_03_5483_Collision_YMapTransform:
; On collision (interaction=0):
; - If action=0 → set Y from map, load new object data (bank 1).
; - If action=1 → player action change.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$00
    ret  nz
    call call_00_2962_ObjectGetActionId
    cp   a,$00
    jr   z,.jr_03_5497
    cp   a,$01
    jp   z,call_03_4cea_TriggerPlayerActionChange
    ret  
.jr_03_5497:
    call call_00_27cb_Object_SetYFromMap
    ld   a,$01
    farcall entry_02_72ac_LoadObjectData
    ret                                          ;; 03:5482 $c9
    
call_03_54a8_Collision_PropertyBasedTransform:
; For actions < 3.
; - On collision (interaction=1):
; - Handle hit/respawn, zero out byte at offset 15.
; - Get object property, decide a bank (03/06/09/0C → bank3 else → bank9).
; - Transform via that bank.
    call call_00_2995_ObjectGetActionId
    cp   a,$03
    ret  nc
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    cp   a,$01
    jp   nz,call_03_4cea_TriggerPlayerActionChange
    call entry_03_5671_HandleObjectHitOrRespawn
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_UNK15_OFFSET
    ld   l,a
    ld   [hl],$00
    call call_00_2995_ObjectGetActionId
    cp   a,$0A
    ret  z
    call call_00_28b4_ObjectGet16
    ld   c,$03
    cp   a,$03
    jr   z,label54E1
    cp   a,$06
    jr   z,label54E1
    cp   a,$09
    jr   z,label54E1
    cp   a,$0C
    jr   z,label54E1
    ld   c,$09
label54E1:
    ld   a,c
    farcall entry_02_72ac_LoadObjectData
    ret  
    
call_03_54ee_Collision_TransformBank0AndSetTimer:
; On collision: always triggers player action change, then transforms to bank0.
    call call_03_550e_CheckPlayerObjectInteraction
    ret  nc
    call call_03_4cea_TriggerPlayerActionChange
    ld   a,$00
    farcall entry_02_72ac_LoadObjectData
    ret  

call_03_54f9:
; Writes 0x3C to byte at offset 15.
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_UNK15_OFFSET
    ld   l,a
    ld   h,$D8
    ld   [hl],$3C
    ret  

call_03_550e_CheckPlayerObjectInteraction:
; Starts by checking an object’s state byte at offset +$15. If nonzero, bails out (call_03_55fd_ReturnNoInteraction → return 0).
; Otherwise, looks up a value in the data_03_55ff_ObjectInteractionFlagsTable table using the object’s type ID. 
; - Stores this into wDC58 — looks like an interaction ruleset (bitflags: different behavior per object type).
; Then does precise bounding-box checks between the player and the object:
; - Player’s Y position, adjusted by velocity (wDC88) and sometimes by +8 if in action $05 (likely crouch/duck).
; - Compares against object’s bounding box (+$10/$11 for Y, +$0E/$0F for X, plus size fields later).
; - Uses signed arithmetic to check whether the player is within object extents both vertically and horizontally.
; If overlap fails → bail (call_03_55fd_ReturnNoInteraction).
; If overlap succeeds → branch into different behaviors depending on wDC58 bits:
; - Bit 1 case: interacts with wDC7F (player state flags), clears it, and returns a “special” interaction result ($FF+2).
; - Bit 2 case: only triggers if the player is in certain action IDs ($0E,$0F,$25,$26), and if vertical velocity (wDC8C) is negative (jump/falling). Then sets wDC8C = $2A and returns $FF+3. This looks like a bounce effect (spring/booster tile).
; - Otherwise calls call_00_0759 (probably a more general collision/interaction handler). If that succeeds, returns $FF+1.
; So this routine is the core collision handler for player–object interactions, with special cases for springs, breakables, pushables, etc., driven by data_03_55ff_ObjectInteractionFlagsTable.
    ld   B, $d8                                        ;; 03:550e $06 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5510 $fa $00 $da
    or   A, OBJECT_UNK15_OFFSET                                        ;; 03:5513 $f6 $15
    ld   C, A                                          ;; 03:5515 $4f
    ld   A, [BC]                                       ;; 03:5516 $0a
    and  A, A                                          ;; 03:5517 $a7
    jp   NZ, call_03_55fd_ReturnNoInteraction                                ;; 03:5518 $c2 $fd $55
    ld   H, $d8                                        ;; 03:551b $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:551d $fa $00 $da
    or   A, OBJECT_ID_OFFSET                                        ;; 03:5520 $f6 $00
    ld   L, A                                          ;; 03:5522 $6f
    ld   L, [HL]                                       ;; 03:5523 $6e
    ld   H, $00                                        ;; 03:5524 $26 $00
    ld   DE, data_03_55ff_ObjectInteractionFlagsTable                              ;; 03:5526 $11 $ff $55
    add  HL, DE                                        ;; 03:5529 $19
    ld   A, [HL]                                       ;; 03:552a $7e
    ld   [wDC58], A                                    ;; 03:552b $ea $58 $dc
    ld   HL, wD810_PlayerYPosition                                     ;; 03:552e $21 $10 $d8
    ld   A, [HL+]                                      ;; 03:5531 $2a
    ld   H, [HL]                                       ;; 03:5532 $66
    ld   L, A                                          ;; 03:5533 $6f
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:5534 $fa $01 $d8
    ld   DE, $00                                       ;; 03:5537 $11 $00 $00
    cp   A, $05                                        ;; 03:553a $fe $05
    jr   NZ, .jr_03_5541                                ;; 03:553c $20 $03
    ld   DE, $08                                       ;; 03:553e $11 $08 $00
.jr_03_5541:
    add  HL, DE                                        ;; 03:5541 $19
    ld   A, [wDC88]                                    ;; 03:5542 $fa $88 $dc
    ld   E, A                                          ;; 03:5545 $5f
    ld   D, $00                                        ;; 03:5546 $16 $00
    bit  7, A                                          ;; 03:5548 $cb $7f
    jr   Z, .jr_03_554d                                ;; 03:554a $28 $01
    dec  D                                             ;; 03:554c $15
.jr_03_554d:
    add  HL, DE                                        ;; 03:554d $19
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:554e $fa $00 $da
    or   A, OBJECT_YPOS_OFFSET                                        ;; 03:5551 $f6 $10
    ld   C, A                                          ;; 03:5553 $4f
    ld   A, [BC]                                       ;; 03:5554 $0a
    sub  A, L                                          ;; 03:5555 $95
    ld   E, A                                          ;; 03:5556 $5f
    inc  BC                                            ;; 03:5557 $03
    ld   A, [BC]                                       ;; 03:5558 $0a
    sbc  A, H                                          ;; 03:5559 $9c
    ld   D, A                                          ;; 03:555a $57
    ld   A, C                                          ;; 03:555b $79
    xor  A, $02                                        ;; 03:555c $ee $02
    ld   C, A                                          ;; 03:555e $4f
    ld   A, [BC]                                       ;; 03:555f $0a ; loads OBJECT_HEIGHT_OFFSET
    add  A, E                                          ;; 03:5560 $83
    ld   E, A                                          ;; 03:5561 $5f
    ld   A, $00                                        ;; 03:5562 $3e $00
    adc  A, D                                          ;; 03:5564 $8a
    jp   NZ, call_03_55fd_ReturnNoInteraction                                ;; 03:5565 $c2 $fd $55
    ld   A, [BC]                                       ;; 03:5568 $0a ; loads OBJECT_HEIGHT_OFFSET
    add  A, A                                          ;; 03:5569 $87
    cp   A, E                                          ;; 03:556a $bb
    jp   C, call_03_55fd_ReturnNoInteraction                                 ;; 03:556b $da $fd $55
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:556e $21 $0e $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5571 $fa $00 $da
    or   A, OBJECT_XPOS_OFFSET                                        ;; 03:5574 $f6 $0e
    ld   C, A                                          ;; 03:5576 $4f
    ld   A, [BC]                                       ;; 03:5577 $0a
    sub  A, [HL]                                       ;; 03:5578 $96
    ld   E, A                                          ;; 03:5579 $5f
    inc  BC                                            ;; 03:557a $03
    inc  HL                                            ;; 03:557b $23
    ld   A, [BC]                                       ;; 03:557c $0a
    sbc  A, [HL]                                       ;; 03:557d $9e
    ld   D, A                                          ;; 03:557e $57
    ld   A, C                                          ;; 03:557f $79
    xor  A, $1d                                        ;; 03:5580 $ee $1d
    ld   C, A                                          ;; 03:5582 $4f
    ld   A, [BC]                                       ;; 03:5583 $0a ; loads OBJECT_WIDTH_OFFSET
    add  A, $08                                        ;; 03:5584 $c6 $08
    add  A, E                                          ;; 03:5586 $83
    ld   E, A                                          ;; 03:5587 $5f
    ld   A, $00                                        ;; 03:5588 $3e $00
    adc  A, D                                          ;; 03:558a $8a
    jr   NZ, call_03_55fd_ReturnNoInteraction                                ;; 03:558b $20 $70
    ld   A, [BC]                                       ;; 03:558d $0a ; loads OBJECT_WIDTH_OFFSET
    add  A, $08                                        ;; 03:558e $c6 $08
    add  A, A                                          ;; 03:5590 $87
    cp   A, E                                          ;; 03:5591 $bb
    jr   C, call_03_55fd_ReturnNoInteraction                                 ;; 03:5592 $38 $69
    ld   A, [wDC58]                                    ;; 03:5594 $fa $58 $dc
    bit  1, A                                          ;; 03:5597 $cb $4f
    jr   Z, .jr_03_55a9                                ;; 03:5599 $28 $0e
    ld   HL, wDC7F                                     ;; 03:559b $21 $7f $dc
    bit  0, [HL]                                       ;; 03:559e $cb $46
    jr   Z, .jr_03_55a9                                ;; 03:55a0 $28 $07
    ld   [HL], $00                                     ;; 03:55a2 $36 $00
    ld   A, $ff                                        ;; 03:55a4 $3e $ff
    add  A, $02                                        ;; 03:55a6 $c6 $02
    ret                                                ;; 03:55a8 $c9
.jr_03_55a9:
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:55a9 $21 $0e $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:55ac $fa $00 $da
    or   A, OBJECT_XPOS_OFFSET                                        ;; 03:55af $f6 $0e
    ld   C, A                                          ;; 03:55b1 $4f
    ld   A, [BC]                                       ;; 03:55b2 $0a
    sub  A, [HL]                                       ;; 03:55b3 $96
    ld   E, A                                          ;; 03:55b4 $5f
    inc  BC                                            ;; 03:55b5 $03
    inc  HL                                            ;; 03:55b6 $23
    ld   A, [BC]                                       ;; 03:55b7 $0a
    sbc  A, [HL]                                       ;; 03:55b8 $9e
    ld   D, A                                          ;; 03:55b9 $57
    ld   A, C                                          ;; 03:55ba $79
    xor  A, $1d                                        ;; 03:55bb $ee $1d
    ld   C, A                                          ;; 03:55bd $4f
    ld   A, [BC]                                       ;; 03:55be $0a
    add  A, E                                          ;; 03:55bf $83
    ld   E, A                                          ;; 03:55c0 $5f
    ld   A, $00                                        ;; 03:55c1 $3e $00
    adc  A, D                                          ;; 03:55c3 $8a
    jr   NZ, call_03_55fd_ReturnNoInteraction                                ;; 03:55c4 $20 $37
    ld   A, [BC]                                       ;; 03:55c6 $0a
    add  A, A                                          ;; 03:55c7 $87
    cp   A, E                                          ;; 03:55c8 $bb
    jr   C, call_03_55fd_ReturnNoInteraction                                 ;; 03:55c9 $38 $32
    ld   A, [wDC58]                                    ;; 03:55cb $fa $58 $dc
    bit  2, A                                          ;; 03:55ce $cb $57
    jr   Z, .jr_03_55f3                                ;; 03:55d0 $28 $21
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:55d2 $fa $01 $d8
    cp   A, $0e                                        ;; 03:55d5 $fe $0e
    jr   Z, .jr_03_55e5                                ;; 03:55d7 $28 $0c
    cp   A, $0f                                        ;; 03:55d9 $fe $0f
    jr   Z, .jr_03_55e5                                ;; 03:55db $28 $08
    cp   A, $25                                        ;; 03:55dd $fe $25
    jr   Z, .jr_03_55e5                                ;; 03:55df $28 $04
    cp   A, $26                                        ;; 03:55e1 $fe $26
    jr   NZ, .jr_03_55f3                               ;; 03:55e3 $20 $0e
.jr_03_55e5:
    ld   HL, wDC8C                                     ;; 03:55e5 $21 $8c $dc
    bit  7, [HL]                                       ;; 03:55e8 $cb $7e
    jr   Z, .jr_03_55f3                                ;; 03:55ea $28 $07
    ld   [HL], $2a                                     ;; 03:55ec $36 $2a
    ld   A, $ff                                        ;; 03:55ee $3e $ff
    add  A, $03                                        ;; 03:55f0 $c6 $03
    ret                                                ;; 03:55f2 $c9
.jr_03_55f3:
    call call_00_0759                                  ;; 03:55f3 $cd $59 $07
    jr   NZ, call_03_55fd_ReturnNoInteraction                                ;; 03:55f6 $20 $05
    ld   A, $ff                                        ;; 03:55f8 $3e $ff
    add  A, $01                                        ;; 03:55fa $c6 $01
    ret                                                ;; 03:55fc $c9

call_03_55fd_ReturnNoInteraction:
; Just xor A and ret.
; Acts as the “failed collision / no interaction” exit for call_03_550e.
    xor  A, A                                          ;; 03:55fd $af
    ret                                                ;; 03:55fe $c9

data_03_55ff_ObjectInteractionFlagsTable:
; What it is:
; A lookup table of bytes, indexed by object type or subtype.
; Each value is stored in wDC58 and influences behavior bits:
; - Bit 1 → “reset interaction flag”
; - Bit 2 → “bounce if stomped”
; Others may map to more cases.
    db   $00, $03, $03, $03, $03, $03, $03, $03        ;; 03:55ff ?...????
    db   $03, $02, $02, $02, $02, $02, $00, $00        ;; 03:5607 ????????
    db   $00, $01, $00, $00, $00, $00, $00, $00        ;; 03:560f ????????
    db   $00, $00, $00, $00, $02, $02, $01, $03        ;; 03:5617 ????..?.
    db   $03, $07, $07, $02, $01, $03, $03, $01        ;; 03:561f ..??????
    db   $03, $01, $03, $04, $00, $00, $03, $00        ;; 03:5627 ????????
    db   $05, $05, $01, $01, $02, $01, $01, $00        ;; 03:562f ????????
    db   $02, $03, $01, $00, $03, $06, $03, $00        ;; 03:5637 ????????
    db   $01, $01, $00, $03, $03, $00, $02, $02        ;; 03:563f ????????
    db   $01, $00, $02, $02, $03, $03, $05, $03        ;; 03:5647 ????????
    db   $01, $00, $00, $01, $04, $00, $03, $00        ;; 03:564f ????????
    db   $03, $03, $03, $07, $03, $03, $03, $00        ;; 03:5657 ????????
    db   $01, $03, $02, $02, $01, $01, $03, $01        ;; 03:565f ????????
    db   $00, $02, $01, $00, $00, $00, $03, $01        ;; 03:5667 ????????
    db   $01, $01                                      ;; 03:566f ??

entry_03_5671_HandleObjectHitOrRespawn:
call_03_5671_HandleObjectHitOrRespawn:
; Reads object state bytes at +$15/$16.
; If $15 is nonzero, returns (object busy).
; If $16 is $FF or 0, returns (inactive/dead).
; Otherwise decrements $16.
; If it reaches 0:
; - Clears it.
; - Looks up object type (call_00_35e8_GetObjectTypeIndex).
; - If invalid, removes object (call_00_2b7a_ClearObjectThenJump).
; - If valid:
;   - If high bit set → sets facing direction, initializes particles (burst effect), 
;     sets object param $14, plays effect.
;   - Stores low 6 bits into wDAD6_ReturnBank, then calls entry_02_72ac_LoadObjectData 
;     from bank 2 (reloads object definition).
;   - Plays sound effect $10.
; - If $16 didn’t reach 0:
;   - Writes it back.
;   - Resets $15 to $3C (cooldown timer).
;   - Plays sound effect $0F.
; So this is an object interaction lifecycle handler: triggered when the player collides with certain objects, 
; decrements a counter, and either reloads/respawns the object, spawns particles, or plays sounds depending on conditions.
    ld   H, $d8                                        ;; 03:5671 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5673 $fa $00 $da
    or   A, OBJECT_UNK15_OFFSET                                        ;; 03:5676 $f6 $15
    ld   L, A                                          ;; 03:5678 $6f
    ld   A, [HL]                                       ;; 03:5679 $7e
    and  A, A                                          ;; 03:567a $a7
    ret  NZ                                            ;; 03:567b $c0
    inc  L                                             ;; 03:567c $2c
    ld   A, [HL]                                       ;; 03:567d $7e
    cp   A, $ff                                        ;; 03:567e $fe $ff
    ret  Z                                             ;; 03:5680 $c8
    and  A, A                                          ;; 03:5681 $a7
    ret  Z                                             ;; 03:5682 $c8
    sub  A, $01                                        ;; 03:5683 $d6 $01
    jr   Z, .jr_03_5689                                ;; 03:5685 $28 $02
    jr   NC, .jr_03_56b8                               ;; 03:5687 $30 $2f
.jr_03_5689:
    ld   [HL], $00                                     ;; 03:5689 $36 $00
    call call_00_35e8_GetObjectTypeIndex                                  ;; 03:568b $cd $e8 $35
    cp   A, $ff                                        ;; 03:568e $fe $ff
    jp   Z, call_00_2b7a_ClearObjectThenJump                                 ;; 03:5690 $ca $7a $2b
    bit  7, A                                          ;; 03:5693 $cb $7f
    jr   Z, .jr_03_56a6                                ;; 03:5695 $28 $0f
    push AF                                            ;; 03:5697 $f5
    ld   C, $00                                        ;; 03:5698 $0e $00
    call call_00_288c_Object_Set14                                  ;; 03:569a $cd $8c $28
    ld   C, $00                                        ;; 03:569d $0e $00
    call call_00_2958_ObjectSetFacingDirection                                  ;; 03:569f $cd $58 $29
    call call_00_2c67_Particle_InitBurst                                  ;; 03:56a2 $cd $67 $2c
    pop  AF                                            ;; 03:56a5 $f1
.jr_03_56a6:
    and  A, $3f                                        ;; 03:56a6 $e6 $3f
    farcall entry_02_72ac_LoadObjectData
    ld   A, $10                                        ;; 03:56b3 $3e $10
    jp   call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 03:56b5 $c3 $f5 $0f
.jr_03_56b8:
    ld   [HL], A                                       ;; 03:56b8 $77
    dec  L                                             ;; 03:56b9 $2d
    ld   [HL], $3c                                     ;; 03:56ba $36 $3c
    ld   A, $0f                                        ;; 03:56bc $3e $0f
    jp   call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 03:56be $c3 $f5 $0f

call_03_56c1_CheckPlayerObjectCollision_Main:
; Early exit if the player’s ActionId is in certain states 
; (1A, 2E, 3B, 1B = probably cutscenes, knockback, death, or other “don’t collide” states).
; Otherwise, it takes the player’s Y position + vertical offset (wDC88, which looks like a 
; per-frame Y delta or velocity), then compares against the current object’s bounding box 
; stored at $D8xx (using wDA00_CurrentObjectAddr).
; Performs bounding-box intersection checks for both vertical and horizontal overlap.
; Splits into several cases depending on whether the player is above, below, or inside the object.
; If overlap is valid, it calls into call_03_58a9_ComputeCollisionOffset for fine-grained offset adjustment and then either:
; Jumps to call_03_580b_RegisterSecondaryCollision (registers the object as the active collision target),
; Or to call_03_57f8_ClearCollisionForObject (clear/ignore collision).
; Role: The main “does the player collide with this object?” function.
    ld   a,[wD801_PlayerObject_ActionId]
    cp   a,$1A
    jp   z,call_03_57f8_ClearCollisionForObject
    cp   a,$2E
    jp   z,call_03_57f8_ClearCollisionForObject
    cp   a,$3B
    jp   z,call_03_57f8_ClearCollisionForObject
    cp   a,$1B
    jp   z,call_03_57f8_ClearCollisionForObject
    ld   a,[wDC88]
    ld   e,a
    ld   d,$00
    bit  7,a
    jr   z,label56E3
    dec  d
label56E3:
    ld   a,[wD810_PlayerYPosition]
    add  e
    ld   e,a
    ld   a,[wD811_PlayerYPosition]
    adc  d
    ld   d,a
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ld   a,e
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,d
    sbc  [hl]
    ld   d,a
    jr   c,label570D
    and  a
    jp   nz,call_03_57f8_ClearCollisionForObject
    inc  l
    inc  l
    ldd  a,[hl]
    add  a,$0F
    cp   e
    jp   c,call_03_57f8_ClearCollisionForObject
    jr   label571F
label570D:
    xor  a
    sub  e
    ld   e,a
    ld   a,$00
    sbc  d
    and  a
    jp   nz,call_03_57f8_ClearCollisionForObject
    inc  l
    inc  l
    ldd  a,[hl]
    add  a,$0F
    cp   e
    jr   c,label577C
label571F:
    ld   c,[hl]
    ld   a,l
    xor  a,$1C
    ld   l,a
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD80F_PlayerXPosition]
    sbc  [hl]
    ld   d,a
    ld   a,e
    add  c
    ld   e,a
    ld   a,d
    adc  a,$00
    bit  7,a
    jr   nz,label575D
    and  a
    jp   nz,call_03_57f8_ClearCollisionForObject
    ld   a,e
    sla  c
    sub  c
    jp   c,call_03_57f8_ClearCollisionForObject
    cp   a,$08
    jp   nc,call_03_57f8_ClearCollisionForObject
    ld   c,a
    call call_03_58a9_ComputeCollisionOffset
    ld   a,c
    sub  b
    add  e
    add  d
    bit  7,a
    jp   nz,call_03_580b_RegisterSecondaryCollision
    and  a
    jp   z,call_03_580b_RegisterSecondaryCollision
    jp   call_03_57f8_ClearCollisionForObject
label575D:
    inc  d
    jp   nz,call_03_57f8_ClearCollisionForObject
    ld   a,e
    cpl  
    cp   a,$08
    jp   nc,call_03_57f8_ClearCollisionForObject
    ld   c,a
    call call_03_58a9_ComputeCollisionOffset
    ld   a,c
    add  b
    sub  e
    sub  d
    bit  7,a
    jp   nz,call_03_580b_RegisterSecondaryCollision
    and  a
    jp   z,call_03_580b_RegisterSecondaryCollision
    jp   call_03_57f8_ClearCollisionForObject
label577C:
    ldi  a,[hl]
    ld   c,a
    ld   b,[hl]
    ld   a,l
    xor  a,$1D
    ld   l,a
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD80F_PlayerXPosition]
    sbc  [hl]
    ld   d,a
    ld   a,e
    add  c
    ld   e,a
    ld   a,$00
    adc  d
    jr   nz,call_03_57f8_ClearCollisionForObject
    ld   a,c
    add  a
    cp   e
    jr   c,call_03_57f8_ClearCollisionForObject
    inc  l
    ldi  a,[hl]
    sub  b
    ld   c,a
    ld   a,[hl]
    sbc  a,$00
    ld   b,a
    ld   a,[wDC88]
    ld   e,a
    ld   d,$00
    bit  7,a
    jr   z,label57AE
    dec  d
label57AE:
    ld   a,[wD810_PlayerYPosition]
    add  e
    ld   e,a
    ld   a,[wD811_PlayerYPosition]
    adc  d
    ld   d,a
    ld   a,e
    add  a,$10
    ld   e,a
    ld   a,d
    adc  a,$00
    ld   d,a
    ld   a,c
    sub  e
    ld   c,a
    ld   a,b
    sbc  d
    ld   b,a
    jr   c,call_03_57f8_ClearCollisionForObject
    jr   nz,call_03_57f8_ClearCollisionForObject
    ld   a,c
    cp   a,$10
    jr   nc,call_03_57f8_ClearCollisionForObject
    ld   a,[wDC8C]
    sra  a
    sra  a
    sra  a
    sra  a
    add  c
    dec  a
    bit  7,a
    jr   nz,call_03_57e6_ResolveCollision_Reset
    cp   a,$02
    jr   c,call_03_57e6_ResolveCollision_Reset
    jr   call_03_57f8_ClearCollisionForObject

call_03_57e6_ResolveCollision_Reset:
; Clears wDC88 (the player’s vertical delta).
; Stores the current object ID (wDA00_CurrentObjectAddr) into wDC7B.
; If that ID was already in wDC7D, resets it to zero.
; Role: This looks like a collision resolution / reset routine. 
; It wipes motion and registers the colliding object as "current collision", 
; while clearing old records.
    xor  A, A                                          ;; 03:57e6 $af
    ld   [wDC88], A                                    ;; 03:57e7 $ea $88 $dc
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:57ea $fa $00 $da
    ld   [wDC7B], A                                    ;; 03:57ed $ea $7b $dc
    ld   HL, wDC7D                                     ;; 03:57f0 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:57f3 $be
    ret  NZ                                            ;; 03:57f4 $c0
    ld   [HL], $00                                     ;; 03:57f5 $36 $00
    ret                                                ;; 03:57f7 $c9

entry_03_57f8_ClearCollisionForObject:
call_03_57f8_ClearCollisionForObject:
; Compares the current object ID to the two “last touched object” slots (wDC7B and wDC7D).
; If it matches, clears those slots.
; Effectively means: “This object is no longer colliding with the player, remove it from tracking.”
; Role: Collision cleanup when no intersection occurs.
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:57f8 $fa $00 $da
    ld   HL, wDC7B                                     ;; 03:57fb $21 $7b $dc
    cp   A, [HL]                                       ;; 03:57fe $be
    jr   NZ, .jr_03_5803                               ;; 03:57ff $20 $02
    ld   [HL], $00                                     ;; 03:5801 $36 $00
.jr_03_5803:
    ld   HL, wDC7D                                     ;; 03:5803 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:5806 $be
    ret  NZ                                            ;; 03:5807 $c0
    ld   [HL], $00                                     ;; 03:5808 $36 $00
    ret                                                ;; 03:580a $c9

call_03_580b_RegisterSecondaryCollision:
; Marks the current object as the “secondary” collision slot (wDC7D).
; If it was in wDC7B, clears that first.
; Role: Assigns the object as the active secondary collision candidate.
    ld   a,[wDA00_CurrentObjectAddr]
    ld   hl,wDC7B
    cp   [hl]
    jr   nz,label5816
    ld   [hl],$00
label5816:
    ld   [wDC7D],a
    ret  

call_03_581a_CheckPlayerObjectCollision_Simple:
; Another collision test, but narrower than 56c1.
; Skips entirely if the player is in the same “ignore” action IDs.
; Uses the object’s width/height at $D8xx+12/+13 to test bounding-box intersection against the player.
; Again compares Y offset + vertical delta (wDC88).
; If all checks pass, adjusts by camera scroll (wDC8C >> 4) and then calls into 57e6 (collision hit) or 57f8 (miss).
; Role: This is a simplified AABB collision test between the player and an object. 
; It’s likely for a different type of object (maybe platforms, triggers, or zones).
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 03:581a $fa $01 $d8
    cp   A, $1a                                        ;; 03:581d $fe $1a
    jp   Z, call_03_57f8_ClearCollisionForObject                                 ;; 03:581f $ca $f8 $57
    cp   A, $2e                                        ;; 03:5822 $fe $2e
    jp   Z, call_03_57f8_ClearCollisionForObject                                 ;; 03:5824 $ca $f8 $57
    cp   A, $3b                                        ;; 03:5827 $fe $3b
    jp   Z, call_03_57f8_ClearCollisionForObject                                 ;; 03:5829 $ca $f8 $57
    cp   A, $1b                                        ;; 03:582c $fe $1b
    jp   Z, call_03_57f8_ClearCollisionForObject                                 ;; 03:582e $ca $f8 $57
    ld   H, $d8                                        ;; 03:5831 $26 $d8
    ld   A, [wDA00_CurrentObjectAddr]                                    ;; 03:5833 $fa $00 $da
    or   A, OBJECT_WIDTH_OFFSET                                        ;; 03:5836 $f6 $12
    ld   L, A                                          ;; 03:5838 $6f
    ld   A, [HL+]                                      ;; 03:5839 $2a
    ld   C, A                                          ;; 03:583a $4f
    ld   B, [HL]                                       ;; 03:583b $46
    ld   A, L                                          ;; 03:583c $7d
    xor  A, $1d                                        ;; 03:583d $ee $1d
    ld   L, A                                          ;; 03:583f $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:5840 $fa $0e $d8
    sub  A, [HL]                                       ;; 03:5843 $96
    ld   E, A                                          ;; 03:5844 $5f
    inc  HL                                            ;; 03:5845 $23
    ld   A, [wD80F_PlayerXPosition]                                    ;; 03:5846 $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:5849 $9e
    ld   D, A                                          ;; 03:584a $57
    ld   A, E                                          ;; 03:584b $7b
    add  A, C                                          ;; 03:584c $81
    ld   E, A                                          ;; 03:584d $5f
    ld   A, $00                                        ;; 03:584e $3e $00
    adc  A, D                                          ;; 03:5850 $8a
    jr   NZ, call_03_57f8_ClearCollisionForObject                                ;; 03:5851 $20 $a5
    ld   A, C                                          ;; 03:5853 $79
    add  A, A                                          ;; 03:5854 $87
    cp   A, E                                          ;; 03:5855 $bb
    jr   C, call_03_57f8_ClearCollisionForObject                                 ;; 03:5856 $38 $a0
    inc  L                                             ;; 03:5858 $2c
    ld   A, [HL+]                                      ;; 03:5859 $2a
    sub  A, B                                          ;; 03:585a $90
    ld   C, A                                          ;; 03:585b $4f
    ld   A, [HL]                                       ;; 03:585c $7e
    sbc  A, $00                                        ;; 03:585d $de $00
    ld   B, A                                          ;; 03:585f $47
    ld   A, [wDC88]                                    ;; 03:5860 $fa $88 $dc
    ld   E, A                                          ;; 03:5863 $5f
    ld   D, $00                                        ;; 03:5864 $16 $00
    bit  7, A                                          ;; 03:5866 $cb $7f
    jr   Z, .jr_03_586b                                ;; 03:5868 $28 $01
    dec  D                                             ;; 03:586a $15
.jr_03_586b:
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:586b $fa $10 $d8
    add  A, E                                          ;; 03:586e $83
    ld   E, A                                          ;; 03:586f $5f
    ld   A, [wD811_PlayerYPosition]                                    ;; 03:5870 $fa $11 $d8
    adc  A, D                                          ;; 03:5873 $8a
    ld   D, A                                          ;; 03:5874 $57
    ld   A, E                                          ;; 03:5875 $7b
    add  A, $10                                        ;; 03:5876 $c6 $10
    ld   E, A                                          ;; 03:5878 $5f
    ld   A, D                                          ;; 03:5879 $7a
    adc  A, $00                                        ;; 03:587a $ce $00
    ld   D, A                                          ;; 03:587c $57
    ld   A, C                                          ;; 03:587d $79
    sub  A, E                                          ;; 03:587e $93
    ld   C, A                                          ;; 03:587f $4f
    ld   A, B                                          ;; 03:5880 $78
    sbc  A, D                                          ;; 03:5881 $9a
    ld   B, A                                          ;; 03:5882 $47
    jp   C, call_03_57f8_ClearCollisionForObject                                 ;; 03:5883 $da $f8 $57
    jp   NZ, call_03_57f8_ClearCollisionForObject                                ;; 03:5886 $c2 $f8 $57
    ld   A, C                                          ;; 03:5889 $79
    cp   A, $10                                        ;; 03:588a $fe $10
    jp   NC, call_03_57f8_ClearCollisionForObject                                ;; 03:588c $d2 $f8 $57
    ld   A, [wDC8C]                                    ;; 03:588f $fa $8c $dc
    sra  A                                             ;; 03:5892 $cb $2f
    sra  A                                             ;; 03:5894 $cb $2f
    sra  A                                             ;; 03:5896 $cb $2f
    sra  A                                             ;; 03:5898 $cb $2f
    add  A, C                                          ;; 03:589a $81
    dec  A                                             ;; 03:589b $3d
    bit  7, A                                          ;; 03:589c $cb $7f
    jp   NZ, call_03_57e6_ResolveCollision_Reset                                ;; 03:589e $c2 $e6 $57
    cp   A, $02                                        ;; 03:58a1 $fe $02
    jp   C, call_03_57e6_ResolveCollision_Reset                                 ;; 03:58a3 $da $e6 $57
    jp   call_03_57f8_ClearCollisionForObject                                    ;; 03:58a6 $c3 $f8 $57

call_03_58a9_ComputeCollisionOffset:
; Loads the object’s parameter at $D8xx+1B.
; Flips it if the object’s direction byte ($D8xx+19) has bit 7 set (sign extension trick).
; Combines this with wDC84–wDC86 (looks like camera or scroll deltas).
; Then checks wD80D_PlayerFacingDirection, and if bit 5 is set, flips the result.
; Role: This is a collision offset calculator: adjusts collision testing 
; depending on object properties (size/offset) and player facing direction.
    ld   h,$D8
    ld   a,[wDA00_CurrentObjectAddr]
    or   a,OBJECT_XVEL_OFFSET
    ld   l,a
    ld   b,[hl]
    dec  l
    dec  l
    bit  7,[hl]
    jr   z,label58BB
    xor  a
    sub  b
    ld   b,a
    label58BB:
    ld   a,[wDC84]
    ld   d,a
    ld   a,[wDC85]
    add  d
    ld   d,a
    ld   a,[wDC86]
    ld   e,a
    ld   hl,wD80D_PlayerFacingDirection
    bit  5,[hl]
    ret  z
    cpl  
    inc  a
    ld   e,a
    ret  
