; This file handles collisions between the player and other entities.

call_03_4c38_UpdateEntityCollision_Dispatch:
; Main dispatcher: checks if collisions enabled (wDCA7_DrawGexFlag).
; Reads per-entity collision type/index, decrements a cooldown if nonzero.
; Uses jump table .data_03_4c63_EntityCollisionJumpTable to call the right handler.
    ld   A, [wDCA7_DrawGexFlag]                                    ;; 03:4c38 $fa $a7 $dc
    and  A, A                                          ;; 03:4c3b $a7
    ret  Z                                             ;; 03:4c3c $c8
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   A, [HL]                                       ;; 03:4c45 $7e
    and  A, A                                          ;; 03:4c46 $a7
    jr   Z, .jr_03_4c4a                                ;; 03:4c47 $28 $01
    dec  [HL]                                          ;; 03:4c49 $35 ; if instance+15 is not 0, decrement it
.jr_03_4c4a:
    ld   A, L                                          ;; 03:4c4a $7d
    xor  A, $10                                        ;; 03:4c4b $ee $10
    ld   L, A                                          ;; 03:4c4d $6f
    bit  0, [HL]                                       ;; 03:4c4e $cb $46
    ret  NZ                                            ;; 03:4c50 $c0 ; return if bit 0 of instance+05 is set
    ld   A, L                                          ;; 03:4c51 $7d
    xor  A, $11                                        ;; 03:4c52 $ee $11
    ld   L, A                                          ;; 03:4c54 $6f
    ld   L, [HL]                                       ;; 03:4c55 $6e ; l = instance+14
    res  7, L                                          ;; 03:4c56 $cb $bd ; unset bit 0 in instance+14
    ld   H, $00                                        ;; 03:4c58 $26 $00
    add  HL, HL                                        ;; 03:4c5a $29
    ld   BC, .data_03_4c63_EntityCollisionJumpTable    ;; 03:4c5b $01 $63 $4c
    add  HL, BC                                        ;; 03:4c5e $09
    ld   A, [HL+]                                      ;; 03:4c5f $2a
    ld   H, [HL]                                       ;; 03:4c60 $66
    ld   L, A                                          ;; 03:4c61 $6f
    jp   HL                                            ;; 03:4c62 $e9 ; load collision routine and jump
.data_03_4c63_EntityCollisionJumpTable:
    dw   call_03_4ccf_CollisionHandler_None ; 00
    dw   call_03_56c1_CollisionHandler_Platform ; 01
    dw   call_03_4cd0_CollisionHandler_InvulnerableEnemy ; 02
    dw   call_03_4cd7_CollisionHandler_Projectile ; 03
    dw   call_03_4ce1_CollisionHandler_GenericEnemy ; 04
    dw   call_03_4d38_CollisionHandler_GenericEnemyUnused ; 05 ; unused?
    dw   call_03_4d44_CollisionHandler_DamagePlayerUnused ; 06 ; unused?
    dw   call_03_4d9b_CollisionHandler_BonusCoin ; 07
    dw   call_03_4db3_CollisionHandler_FlyCoin ; 08
    dw   call_03_4dc2_CollisionHandler_PawCoin ; 09
    dw   call_03_4e04_CollisionHandler_Fly ; 0A
    dw   call_03_4e31_CollisionHandler_FlyTV ; 0B
    dw   call_03_4e4b_CollisionHandler_IceSculpture ; 0C
    dw   call_03_4e89_CollisionHandler_EvilSantaProjectile ; 0D
    dw   call_03_4f23_CollisionHandler_HolidayTV_Elf ; 0E
    dw   call_03_4f60_CollisionHandler_BloodCooler ; 0F
    dw   call_03_4f8c_CollisionHandler_MagicSword ; 10
    dw   call_03_4f98_CollisionHandler_GhostKnight ; 11
    dw   call_03_4fad_CollisionHandler_Hand ; 12
    dw   call_03_4fca_CollisionHandler_LostArk ; 13
    dw   call_03_4ff1_CollisionHandler_RaStaff ; 14
    dw   call_03_500d_CollisionHandler_Coffin ; 15
    dw   call_03_50b6_CollisionHandler_AlienCultureTube ; 16
    dw   call_03_50e0_CollisionHandler_OnSwitch ; 17
    dw   call_03_50ea_CollisionHandler_OffSwitch ; 18
    dw   call_03_50f4_CollisionHandler_OnSwitch2 ; 19
    dw   call_03_5116_CollisionHandler_Door ; 1A
    dw   call_03_5156_CollisionHandler_Door2 ; 1B
    dw   call_03_5196_CollisionHandler_Secbot ; 1C
    dw   call_03_51b8_CollisionHandler_SailorToonGirl ; 1D
    dw   call_03_5201_CollisionHandler_BigSilverRobot ; 1E
    dw   call_03_5231_CollisionHandler_Mech ; 1F
    dw   call_03_5274_CollisionHandler_PlanetOBlast ; 20
    dw   call_03_528c_CollisionHandler_StrayCat ; 21
    dw   call_03_52aa_CollisionHandler_Convict ; 22
    dw   call_03_52c8_CollisionHandler_YellowGoon ; 23
    dw   call_03_52da_CollisionHandler_ChomperTV ; 24
    dw   call_03_52fa_CollisionHandler_Bomb ; 25
    dw   call_03_531a_CollisionHandler_WaterTowerStand ; 26
    dw   call_03_532f_CollisionHandler_GextremeSports_Elf ; 27
    dw   call_03_537a_CollisionHandler_BonusTimeCoin ; 28
    dw   call_03_538e_CollisionHandler_Bell ; 29
    dw   call_03_53eb_CollisionHandler_Cannon ; 2A
    dw   call_03_5406_CollisionHandler_BrainOfOz ; 2B
    dw   call_03_5469_CollisionHandler_BrainOfOzProjectile ; 2C
    dw   call_03_5473_CollisionHandler_FreestandingRemote ; 2D
    dw   call_03_5028_CollisionHandler_Cactus ; 2E
    dw   call_03_5069_CollisionHandler_PlayingCard ; 2F
    dw   call_03_5085_CollisionHandler_HardHat ; 30
    dw   call_03_5483_CollisionHandler_Meteor ; 31
    dw   call_03_54a8_CollisionHandler_Rez ; 32
    dw   call_03_581a_CollisionHandler_TVButton ; 33
    dw   call_03_54ee_CollisionHandler_RaStatueProjectile ; 34
    dw   call_03_53c2_CollisionHandler_RockHard ; 35

call_03_4ccf_CollisionHandler_None:
; Does nothing, just returns.
; Acts as a "null" collision handler.
    ret                                                ;; 03:4ccf $c9

call_03_4cd0_CollisionHandler_InvulnerableEnemy:
; Checks for player-entity interaction.
; If collision is detected (carry set), jumps to call_00_06f6_DealDamageToPlayer (probably a generic "hit" or interaction response).
; Otherwise returns.
    call call_03_550e_Entity_CheckPlayerInteraction
    jp   c,call_00_06f6_DealDamageToPlayer
    ret  

call_03_4cd7_CollisionHandler_Projectile:
; Calls CheckPlayerEntityInteraction.
; If no collision → return. If collision → calls call_03_4cea_CollisionHandler_DamagePlayer (special interaction routine), 
; then clears the entity from memory.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_03_4cea_CollisionHandler_DamagePlayer
    jp   call_00_2b80_DeactivateEntitySlot

call_03_4ce1_CollisionHandler_GenericEnemy:
; Calls CheckPlayerEntityInteraction.
; If collision and A!=0, jumps to HandleEntityHit.
; If A==0, falls into call_03_4cea_CollisionHandler_DamagePlayer.
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4ce1 $cd $0e $55
    ret  NC                                            ;; 03:4ce4 $d0
    cp   A, PLAYER_TOUCHED_ENTITY                                        ;; 03:4ce5 $fe $00
    jp   NZ, call_03_5671_HandleEntityHit                                ;; 03:4ce7 $c2 $71 $56
call_03_4cea_CollisionHandler_DamagePlayer:
; Reads player action ID. If certain actions (09, 29, 36) → skip. Otherwise, if not 45, calls HandleGenericHitResponse.
; Then calculates player vs entity X difference, stores facing direction in wDC98.
; Depending on level ID (07, 08), sets a return bank (player action variant).
; Switches player action by calling into banked routine.
; This is basically a player transformation / state-change trigger.
    ld   A, [wD801_Player_ActionId]                                    ;; 03:4cea $fa $01 $d8
    cp   A, PLAYERACTION_TAKE_DAMAGE                                        ;; 03:4ced $fe $09
    jr   Z, .jr_03_4cfe                                ;; 03:4cef $28 $0d
    cp   A, PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE                                        ;; 03:4cf1 $fe $29
    jr   Z, .jr_03_4cfe                                ;; 03:4cf3 $28 $09
    cp   A, PLAYERACTION_KANGAROO_TAKE_DAMAGE                                        ;; 03:4cf5 $fe $36
    jr   Z, .jr_03_4cfe                                ;; 03:4cf7 $28 $05
    cp   A, PLAYERACTION_TOPDOWN_TAKE_DAMAGE                                        ;; 03:4cf9 $fe $45
    call NZ, call_00_06f6_DealDamageToPlayer                              ;; 03:4cfb $c4 $f6 $06
.jr_03_4cfe:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4d06 $fa $0e $d8
    sub  A, [HL]                                       ;; 03:4d09 $96
    inc  HL                                            ;; 03:4d0a $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 03:4d0b $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:4d0e $9e
    ld   A, $ff                                        ;; 03:4d0f $3e $ff
    jr   C, .jr_03_4d15                                ;; 03:4d11 $38 $02
    ld   A, $01                                        ;; 03:4d13 $3e $01
.jr_03_4d15:
    ld   [wDC98], A                                    ;; 03:4d15 $ea $98 $dc
    ld   A, [wDB6C_CurrentMapId]                                    ;; 03:4d18 $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                                        ;; 03:4d1b $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE                                        ;; 03:4d1d $3e $29
    jr   Z, .jr_03_4d2c                                ;; 03:4d1f $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 03:4d21 $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                                        ;; 03:4d24 $fe $08
    ld   A, PLAYERACTION_KANGAROO_TAKE_DAMAGE                                        ;; 03:4d26 $3e $36
    jr   Z, .jr_03_4d2c                                ;; 03:4d28 $28 $02
    ld   A, PLAYERACTION_TAKE_DAMAGE                                        ;; 03:4d2a $3e $09
.jr_03_4d2c:
    farcall call_02_54f9_SwitchPlayerAction
    ret                                                ;; 03:4d37 $c9

call_03_4d38_CollisionHandler_GenericEnemyUnused:
; If collision, checks A. If zero, deal damage to player. Otherwise, goes to entity hit handler.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_TOUCHED_ENTITY
    jp   z,call_00_06f6_DealDamageToPlayer
    jp   call_03_5671_HandleEntityHit

call_03_4d44_CollisionHandler_DamagePlayerUnused:
; Excludes some player actions (09, 29, 36, 45).
; On collision: if A==01, goes to entity hit handler. Otherwise sets timer, 
; calculates relative position, sets facing direction, and triggers action change (like 4cea).
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_TAKE_DAMAGE
    ret  z
    cp   a,PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    ret  z
    cp   a,PLAYERACTION_KANGAROO_TAKE_DAMAGE
    ret  z
    cp   a,PLAYERACTION_TOPDOWN_TAKE_DAMAGE
    ret  z
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   z,call_03_5671_HandleEntityHit
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDC7E_PlayerDamageCooldownTimer],a
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    ld   a,$FF
    jr   c,.jr_00_4D78
    ld   a,$01
.jr_00_4D78:
    ld   [wDC98],a
    ld   a,[wDB6C_CurrentMapId]
    cp   a,MAP_GEXTREME_SPORTS1
    ld   a,PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    jr   z,.jr_00_4D8F
    ld   a,[wDB6C_CurrentMapId]
    cp   a,MAP_MARSUPIAL_MADNESS1
    ld   a,PLAYERACTION_KANGAROO_TAKE_DAMAGE
    jr   z,.jr_00_4D8F
    ld   a,PLAYERACTION_TAKE_DAMAGE
.jr_00_4D8F:
    farcall call_02_54f9_SwitchPlayerAction
    ret  

call_03_4d9b_CollisionHandler_BonusCoin:
; If collision: sets per-level progress bit (bit4 of level data), plays sound 02, then handles entity hit.
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4d9b $cd $0e $55
    ret  NC                                            ;; 03:4d9e $d0
    ld   HL, wDC1E_CurrentLevelID                                     ;; 03:4d9f $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4da2 $6e
    ld   H, $00                                        ;; 03:4da3 $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 03:4da5 $11 $5c $dc
    add  HL, DE                                        ;; 03:4da8 $19
    set  4, [HL]                                       ;; 03:4da9 $cb $e6
    ld   A, SFX_ITEM_PICKUP                                        ;; 03:4dab $3e $02
    call call_00_0ff5_QueueSoundEffect                                  ;; 03:4dad $cd $f5 $0f
    jp   call_03_5671_HandleEntityHit                                    ;; 03:4db0 $c3 $71 $56

call_03_4db3_CollisionHandler_FlyCoin:
; If collision: calls IncrementProgressCounter, plays sound 02, then handles entity hit.
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4db3 $cd $0e $55
    ret  NC                                            ;; 03:4db6 $d0
    call call_00_0723_IncrementCollectibleCount                                  ;; 03:4db7 $cd $23 $07
    ld   A, SFX_ITEM_PICKUP                                        ;; 03:4dba $3e $02
    call call_00_0ff5_QueueSoundEffect                                  ;; 03:4dbc $cd $f5 $0f
    jp   call_03_5671_HandleEntityHit                                    ;; 03:4dbf $c3 $71 $56

call_03_4dc2_CollisionHandler_PawCoin:
; If collision:
; Looks up a flag mask (00, 20, 40, 80).
; ORs it into level data, increments wDCAF_PawCoinCounter.
; Every 4 collected, increments wDC4F_PawCoinExtraHealth (if <4), resets counter, sets flag in wDB69_HUDGraphicsUpdateFlags.
; Plays sound 02, then handles entity hit.
; This is basically a collectible counter with milestones.
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4dc2 $cd $0e $55
    ret  NC                                            ;; 03:4dc5 $d0
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 03:4dc6 $cd $0f $23
    ld   B, $00                                        ;; 03:4dc9 $06 $00
    ld   HL, .data_03_4e00                             ;; 03:4dcb $21 $00 $4e
    add  HL, BC                                        ;; 03:4dce $09
    ld   C, [HL]                                       ;; 03:4dcf $4e
    ld   HL, wDC1E_CurrentLevelID                                     ;; 03:4dd0 $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4dd3 $6e
    ld   H, $00                                        ;; 03:4dd4 $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 03:4dd6 $11 $5c $dc
    add  HL, DE                                        ;; 03:4dd9 $19
    ld   A, [HL]                                       ;; 03:4dda $7e
    or   A, C                                          ;; 03:4ddb $b1
    ld   [HL], A                                       ;; 03:4ddc $77
    ld   HL, wDCAF_PawCoinCounter                                     ;; 03:4ddd $21 $af $dc
    inc  [HL]                                          ;; 03:4de0 $34
    ld   A, [HL]                                       ;; 03:4de1 $7e
    sub  A, $04                                        ;; 03:4de2 $d6 $04
    jr   NZ, .jr_03_4df8                               ;; 03:4de4 $20 $12
    ld   HL, wDC4F_PawCoinExtraHealth                                     ;; 03:4de6 $21 $4f $dc
    ld   A, [HL]                                       ;; 03:4de9 $7e
    cp   A, $04                                        ;; 03:4dea $fe $04
    jr   Z, .jr_03_4df8                                ;; 03:4dec $28 $0a
    inc  [HL]                                          ;; 03:4dee $34
    xor  A, A                                          ;; 03:4def $af
    ld   [wDCAF_PawCoinCounter], A                                    ;; 03:4df0 $ea $af $dc
    ld   HL, wDB69_HUDGraphicsUpdateFlags                                     ;; 03:4df3 $21 $69 $db
    set  1, [HL]                                       ;; 03:4df6 $cb $ce
.jr_03_4df8:
    ld   A, SFX_ITEM_PICKUP                                        ;; 03:4df8 $3e $02
    call call_00_0ff5_QueueSoundEffect                                  ;; 03:4dfa $cd $f5 $0f
    jp   call_03_5671_HandleEntityHit                                    ;; 03:4dfd $c3 $71 $56
.data_03_4e00:
    db   $00, $20, $40, $80

call_03_4e04_CollisionHandler_Fly:
; If collision: gets entity ID, looks up a state value in .data_03_4e2c, calls call_00_0624_SetFly_TimersAndFlags.
; Modifies entity graphics/status, then clears the entity.
; Looks like a pickup that triggers a phase/state change.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_00_293a_Entity_GetId
    sub  a,04
    ld   l,a
    ld   h,00
    ld   de,.data_03_4e2c
    add  hl,de
    ld   a,[hl]
    call call_00_0624_SetFly_TimersAndFlags
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_PARENT
    ld   l,[hl]
    ld   h,HIGH(wD700_EntityFlags)
    ld   a,[hl]
    and  a,$F0
    or   a,$03
    ld   [hl],a
    jp   call_00_2b80_DeactivateEntitySlot
.data_03_4e2c:
    db   $03, $04, $01, $05, $02

call_03_4e31_CollisionHandler_FlyTV:
; If entity action ID==0 and collision detected with A==01: plays sound 03, 
; handles entity hit, then sets entity status low nibble to 02.
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,SFX_FLY_TV
    call call_00_0ff5_QueueSoundEffect
    call call_03_5671_HandleEntityHit
    ld   c,$02
    jp   call_00_2299_Entity_UpdateFlags

call_03_4e4b_CollisionHandler_IceSculpture:
; If entity action ID<2 and collision A==01:
; Plays sound 19, increments action ID, updates entity status nibble.
; Loads new entity data (via banked routine).
; If new action ID==2, increments wDCC3_IceSculptureCounter.
; When wDCC3_IceSculptureCounter==5, triggers PlaySound_1E.
; Then dispatches new offset action.
; Basically a multi-stage collectible or progress item (like 5 items → trigger special event).
    call call_00_2962_Entity_GetActionId                                  ;; 03:4e4b $cd $62 $29
    cp   A, $02                                        ;; 03:4e4e $fe $02
    ret  NC                                            ;; 03:4e50 $d0
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4e51 $cd $0e $55
    ret  NC                                            ;; 03:4e54 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:4e55 $fe $01
    ret  NZ                                            ;; 03:4e57 $c0
    ld   A, SFX_SMALL_BANG                                        ;; 03:4e58 $3e $19
    call call_00_0ff5_QueueSoundEffect                                  ;; 03:4e5a $cd $f5 $0f
    call call_00_2962_Entity_GetActionId                                  ;; 03:4e5d $cd $62 $29
    inc  A                                             ;; 03:4e60 $3c
    push AF                                            ;; 03:4e61 $f5
    push AF                                            ;; 03:4e62 $f5
    ld   C, A                                          ;; 03:4e63 $4f
    call call_00_2299_Entity_UpdateFlags                                  ;; 03:4e64 $cd $99 $22
    pop  AF                                            ;; 03:4e67 $f1
    farcall call_02_72ac_SetEntityAction
    pop  AF                                            ;; 03:4e73 $f1
    cp   A, $02                                        ;; 03:4e74 $fe $02
    ret  NZ                                            ;; 03:4e76 $c0
    ld   HL, wDCC3_IceSculptureCounter                                     ;; 03:4e77 $21 $c3 $dc
    inc  [HL]                                          ;; 03:4e7a $34
    ld   A, [HL]                                       ;; 03:4e7b $7e
    cp   A, $05                                        ;; 03:4e7c $fe $05
    ld   C, $01                                        ;; 03:4e7e $0e $01
    call Z, call_00_21ef_Entity_PlayRemoteSFX                               ;; 03:4e80 $cc $ef $21
    ld   A, [wDCC3_IceSculptureCounter]                                    ;; 03:4e83 $fa $c3 $dc
    jp   call_00_2c09_Entity_SpawnGoalCounter                                  ;; 03:4e86 $c3 $09 $2c

call_03_4e89_CollisionHandler_EvilSantaProjectile:
; Rejects if entity "inactive" (bit 7 of property set) or action ≥ 5.
; If collision and result A==01:
; - Negates a property byte (EntityGet1D), does distance check, looks up a value in 
;   .data_03_4efa (a table of progression values), writes it to entity state.
; If collision A!=01:
; - Loads new entity data from bank 6, then triggers a player action change.
    call call_00_28d2_Entity_GetYVelocity                                  ;; 03:4e89 $cd $d2 $28
    bit  7, A                                          ;; 03:4e8c $cb $7f
    ret  NZ                                            ;; 03:4e8e $c0
    call call_00_2962_Entity_GetActionId                                  ;; 03:4e8f $cd $62 $29
    cp   A, $05                                        ;; 03:4e92 $fe $05
    ret  NC                                            ;; 03:4e94 $d0
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4e95 $cd $0e $55
    ret  NC                                            ;; 03:4e98 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:4e99 $fe $01
    jr   NZ, .jr_03_4eea                               ;; 03:4e9b $20 $4d
    call call_00_28d2_Entity_GetYVelocity                                  ;; 03:4e9d $cd $d2 $28
    cpl                                                ;; 03:4ea0 $2f
    inc  A                                             ;; 03:4ea1 $3c
    ld   [HL], A                                       ;; 03:4ea2 $77
    ld   C, ENTITY_HOLIDAY_TV_EVIL_SANTA                                        ;; 03:4ea3 $0e $1e
    call call_00_29ce_Entity_CheckExists                                  ;; 03:4ea5 $cd $ce $29
    jp   NZ, call_00_2b80_DeactivateEntitySlot                              ;; 03:4ea8 $c2 $80 $2b
    ld   A, L                                          ;; 03:4eab $7d
    or   A, ENTITY_FIELD_XPOS                                        ;; 03:4eac $f6 $0e
    ld   L, A                                          ;; 03:4eae $6f
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:4eaf $fa $00 $da
    or   A, ENTITY_FIELD_XPOS                                        ;; 03:4eb2 $f6 $0e
    ld   E, A                                          ;; 03:4eb4 $5f
    ld   D, HIGH(wD800_EntityMemory)                                        ;; 03:4eb5 $16 $d8
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
    call call_00_28c8_Entity_SetXVelocity                                  ;; 03:4ee6 $cd $c8 $28
    ret                                                ;; 03:4ee9 $c9
.jr_03_4eea:
    ld   A, $06                                        ;; 03:4eea $3e $06
    farcall call_02_72ac_SetEntityAction
    jp   call_03_4cea_CollisionHandler_DamagePlayer                                   ;; 03:4ef7 $c3 $ea $4c
.data_03_4efa:
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 03:4efa ???.????
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10        ;; 03:4f02 ????????
    db   $11, $12, $13, $14, $15, $16, $17, $18        ;; 03:4f0a ????????
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21        ;; 03:4f12 ????????
    db   $22, $23, $24, $25, $27, $28, $29, $2a        ;; 03:4f1a ????????
    db   $2b                                           ;; 03:4f22 ?

call_03_4f23_CollisionHandler_HolidayTV_Elf:
; On collision:
; - If A!=01 → trigger player action change.
; - If A==01: loads new entity data (bank 4), decrements per-entity counter (wDCD5_ElfHealth1), 
;   clears entity when it hits 0, increments wDCC8_ElfCounter, dispatches offset action.
; - If all counters zero → play sound 1E.
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4f23 $cd $0e $55
    ret  NC                                            ;; 03:4f26 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:4f27 $fe $01
    jp   NZ, call_03_4cea_CollisionHandler_DamagePlayer                               ;; 03:4f29 $c2 $ea $4c
    ld   A, $04                                        ;; 03:4f2c $3e $04
    farcall call_02_72ac_SetEntityAction
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 03:4f39 $cd $0f $23
    ld   B, $00                                        ;; 03:4f3c $06 $00
    ld   HL, wDCD5_ElfHealth1                                     ;; 03:4f3e $21 $d5 $dc
    add  HL, BC                                        ;; 03:4f41 $09
    ld   A, [HL]                                       ;; 03:4f42 $7e
    and  A, A                                          ;; 03:4f43 $a7
    ret  Z                                             ;; 03:4f44 $c8
    dec  [HL]                                          ;; 03:4f45 $35
    ret  NZ                                            ;; 03:4f46 $c0
    call call_00_288a_Entity_SetCollisionTypeNone                                  ;; 03:4f47 $cd $8a $28
    call call_00_2b8b_AttemptToSetEntityFlagsTo50                                  ;; 03:4f4a $cd $8b $2b
    ld   HL, wDCC8_ElfCounter                                     ;; 03:4f4d $21 $c8 $dc
    inc  [HL]                                          ;; 03:4f50 $34
    ld   A, [HL]                                       ;; 03:4f51 $7e
    call call_00_2c09_Entity_SpawnGoalCounter                                  ;; 03:4f52 $cd $09 $2c
    ld   HL, wDCD5_ElfHealth1                                     ;; 03:4f55 $21 $d5 $dc
    ld   A, [HL+]                                      ;; 03:4f58 $2a
    or   A, [HL]                                       ;; 03:4f59 $b6
    ret  NZ                                            ;; 03:4f5a $c0
    ld   C, $02                                        ;; 03:4f5b $0e $02
    jp   call_00_21ef_Entity_PlayRemoteSFX                                  ;; 03:4f5d $c3 $ef $21

call_03_4f60_CollisionHandler_BloodCooler:
; Only for entities in action 00.
; If collision with A==01:
; - Handles entity hit, plays sound 19, sets entity status, increments wDCC5_BloodCoolerCounter.
; - When wDCC5_BloodCoolerCounter==3, plays sound 1E.
; - Dispatches offset action.
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffect
    ld   c,$01
    call call_00_2299_Entity_UpdateFlags
    ld   hl,wDCC5_BloodCoolerCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC5_BloodCoolerCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter

call_03_4f8c_CollisionHandler_MagicSword:
; On any collision: plays sound 1E with parameter 3, then handles entity hit.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    ld   c,$03
    call call_00_21ef_Entity_PlayRemoteSFX
    jp   call_03_5671_HandleEntityHit

call_03_4f98_CollisionHandler_GhostKnight:
; On collision:
; - If A!=01 → trigger player action change.
; - If A==01: handle entity hit, check action ID, and if 05 → mark entity slot active.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$05
    jp   z,call_00_22ef_Entity_SetTriggerActive
    ret  

call_03_4fad_CollisionHandler_Hand:
; On collision A==01: if entity’s action ID is 00, loads new entity data (bank 1).
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_00_2995_Entity_GetActionId
    cp   a,$00
    ret  nz
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_4fca_CollisionHandler_LostArk:
; For action 00 only.
; On collision A==02:
; Handle entity hit, set status nibble 04, increment wDCC6_LostArkCounter.
; On 3rd collected, play sound 1E.
; Dispatch offset action.
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_STOMPED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    ld   c,$04
    call call_00_2299_Entity_UpdateFlags
    ld   hl,wDCC6_LostArkCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC6_LostArkCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter
    
call_03_4ff1_CollisionHandler_RaStaff:
; On collision A==01:
; - Handle entity hit, increment wDCC7_RaStaffCounter.
; - On 3rd collected, play sound 1E.
; - Dispatch offset action.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    ld   hl,wDCC7_RaStaffCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$01
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC7_RaStaffCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter
    
call_03_500d_CollisionHandler_Coffin:
; For action 00 only.
; On collision A==01: transforms entity via bank 1 loader.
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    ret  
   
call_03_5028_CollisionHandler_Cactus:
; Collision logic depends on nearby flags (wDCA9_FlyTimerOrFlags4–wDCAB_FlyTimerOrFlags2).
; Sometimes triggers entity hit if action ID < 5.
; Otherwise, for action 05, can trigger a player action change.
; If action < 4 and player within 0x28 in X vector → loads new entity data (bank 5).
    call call_03_550e_Entity_CheckPlayerInteraction
    jr   nc,.jr_00_504C
    cp   a,PLAYER_TOUCHED_ENTITY
    jr   z,.jr_00_5044
    ld   hl,wDCA9_FlyTimerOrFlags4
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    jr   z,.jr_00_5044
    call call_00_2962_Entity_GetActionId
    cp   a,$05
    call c,call_03_5671_HandleEntityHit
    jr   .jr_00_504C
.jr_00_5044:
    call call_00_2962_Entity_GetActionId
    cp   a,$05
    call z,call_03_4cea_CollisionHandler_DamagePlayer
.jr_00_504C:
    call call_00_2962_Entity_GetActionId
    cp   a,$04
    ret  nc
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$28
    ret  nc
    ld   a,$05
    farcall call_02_72ac_SetEntityAction
    ret  

call_03_5069_CollisionHandler_PlayingCard:
; On collision where A!=00:
; - Handle entity hit, increment wDCCF_PlayingCardCounter.
; - On 5th collected, play sound 1E.
; - Dispatch offset action.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_TOUCHED_ENTITY
    ret  z
    call call_03_5671_HandleEntityHit
    ld   hl,wDCCF_PlayingCardCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$05
    ld   c,$02
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCCF_PlayingCardCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter

call_03_5085_CollisionHandler_HardHat:
; If the collision type isn’t "01", the player takes damage.
; If it is type 01:
;    HardHat is only vulnerable while it is jumping (action 1)
;    Otherwise it switches to the crouch down action (action 2)
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    jr   z,.jr_00_50A8
    cp   a,$01
    jp   z,call_03_5671_HandleEntityHit
    ld   a,$02
    farcall call_02_72ac_SetEntityAction
    ret  
.jr_00_50A8:
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    ret  

call_03_50b6_CollisionHandler_AlienCultureTube:
; For action 00 only.
; On collision A==01:
; - Handle entity hit, mark slot active, set status, increment wDCC9_AlienCultureTubeCounter.
; - On 3rd collected, play sound 1E.
; - Dispatch offset action.
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    call call_00_22ef_Entity_SetTriggerActive
    ld   c,$02
    call call_00_2299_Entity_UpdateFlags
    ld   hl,wDCC9_AlienCultureTubeCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$01
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC9_AlienCultureTubeCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter

call_03_50e0_CollisionHandler_OnSwitch:
; On collision A==01: marks entity slot active.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   z,call_00_22ef_Entity_SetTriggerActive
    ret  
    
call_03_50ea_CollisionHandler_OffSwitch:
    ; On collision A==01: clears entity slot.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   z,call_00_22ff_Entity_SetTriggerInactive
    ret  
    
call_03_50f4_CollisionHandler_OnSwitch2:
; For action 00 only.
; On collision A==01: sets entity status, loads new data (bank 1), increments entity slot.
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   c,$01
    call call_00_2299_Entity_UpdateFlags
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    jp   call_00_22e0_Entity_IncrementTriggerFlag
    
call_03_5116_CollisionHandler_Door:
; For action 00 only.
; On collision: requires certain global flags (wDABE_UnkBGCollisionFlags2, wDC81_CurrentInputsAlt) and player action between 01–02.
; Checks entity slot flag; plays sound 1B if not set, else sound 18.
; Loads new entity data (bank 1).
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    ld   hl,wDABE_UnkBGCollisionFlags2
    bit  7,[hl]
    ret  z
    ld   hl,wDC81_CurrentInputsAlt
    bit  6,[hl]
    ret  z
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_IDLE
    ret  c
    cp   a,PLAYERACTION_WALK
    ret  nc
    call call_00_230f_Entity_GetParameterIntoC
    inc  c
    jr   z,.jr_00_5143
    call call_00_22d4_Entity_CheckTriggerFlag
    ld   a,SFX_DOOR2
    jp   z,call_00_0ff5_QueueSoundEffect
.jr_00_5143:
    ld   a,SFX_DOOR1
    call call_00_0ff5_QueueSoundEffect
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    ret  

call_03_5156_CollisionHandler_Door2:
; Same as above, but for action 02, and loads bank 3 data.
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    ld   hl,wDABE_UnkBGCollisionFlags2
    bit  7,[hl]
    ret  z
    ld   hl,wDC81_CurrentInputsAlt
    bit  6,[hl]
    ret  z
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_IDLE
    ret  c
    cp   a,PLAYERACTION_WALK
    ret  nc
    call call_00_230f_Entity_GetParameterIntoC
    inc  c
    jr   z,.jr_00_5183
    call call_00_22d4_Entity_CheckTriggerFlag
    ld   a,SFX_DOOR2
    jp   z,call_00_0ff5_QueueSoundEffect
.jr_00_5183:
    ld   a,SFX_DOOR1
    call call_00_0ff5_QueueSoundEffect
    ld   a,$03
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_5196_CollisionHandler_Secbot:
; On collision:
; - If A!=01 → trigger action change.
; - If A==01: entity hit handler, then if action ID==0 → transform to bank2 data; else mark slot active.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    jp   nz,call_00_22ef_Entity_SetTriggerActive
    ld   a,$02
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_51b8_CollisionHandler_SailorToonGirl:
; On collision:
; - If A!=01 → trigger action change.
; - If A==01:
;   - If action==2 → activate slot, reset state, init particle burst, transform to bank7 data.
;   - Else → entity hit handler, then either update status or transform to bank3 data.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    jr   z,.jr_00_51E3
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    ld   c,$02
    jp   z,call_00_2299_Entity_UpdateFlags
    ld   a,$03
    farcall call_02_72ac_SetEntityAction
    ret  
.jr_00_51E3:
    call call_00_22ef_Entity_SetTriggerActive
    ld   c,ENTITY_FACING_RIGHT
    call call_00_288c_Entity_SetCollisionType
    ld   c,ENTITY_FACING_RIGHT
    call call_00_2958_Entity_SetFacingDirection
    call call_00_2c67_Particle_InitBurst
    ld   a,$07
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_5201_CollisionHandler_BigSilverRobot:
; Skips if action ID = 3.
; If player collides and interaction = 1 → handle entity hit, then if action = 3 → set slot active.
; If interaction ≠ 1 → trigger player action change, load new entity data (bank 2), face player left.
    call call_00_2962_Entity_GetActionId
    cp   a,$03
    ret  z
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jr   z,.jr_00_5222
    call call_03_4cea_CollisionHandler_DamagePlayer
    ld   a,$02
    farcall call_02_72ac_SetEntityAction
    jp   call_00_2410_Entity_FaceTorwardsPlayer
.jr_00_5222:
    call call_00_2410_Entity_FaceTorwardsPlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$03
    jp   z,call_00_22ef_Entity_SetTriggerActive
    ret  
    
call_03_5231_CollisionHandler_Mech:
; If collision →
; - If interaction ≠ 1 → player action change.
; - If = 1 and wDCA9_FlyTimerOrFlags4–wDCAB_FlyTimerOrFlags2 flags are set:
;   - Handle entity hit, increment wDCCB_MechCounter.
;   - Every 4th, play sound 1E, then dispatch offset action.
; Special case for levels $29/$2A only.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    ld   hl,wDCA9_FlyTimerOrFlags4
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    ret  z
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$01
    ret  nz
    call call_00_22e0_Entity_IncrementTriggerFlag
    ld   a,[wDB6C_CurrentMapId]
    cp   a,MAP_ANIME_CHANNEL2
    jr   z,.jr_00_5258
    cp   a,MAP_ANIME_CHANNEL3
    ret  nz
.jr_00_5258:
    ld   hl,wDCCB_MechCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$04
    ld   c,$03
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCCB_MechCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_TOUCHED_ENTITY
    jp   z,call_03_4cea_CollisionHandler_DamagePlayer
    ret  
    
call_03_5274_CollisionHandler_PlanetOBlast:
; On collision, only if interaction = 2.
; Handles entity hit, if action=1 → play sound 1E (#2), clear entity slot.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_STOMPED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$01
    ret  nz
    ld   c,$02
    call call_00_21ef_Entity_PlayRemoteSFX
    jp   call_00_22ff_Entity_SetTriggerInactive
    
call_03_528c_CollisionHandler_StrayCat:
; On collision, if interaction ≠ 0 → handle entity hit, increment wDCCA_StrayCatCounter.
; Every 3rd → play sound 1E (#2).
; Always dispatch offset action.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_TOUCHED_ENTITY
    jp   z,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    ld   hl,wDCCA_StrayCatCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCCA_StrayCatCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter
    
call_03_52aa_CollisionHandler_Convict:
; On collision (interaction=1):
; Handle entity hit, increment wDCCD_ConvictCounter.
; Every 5th → play sound 1E (#3).
; Dispatch offset action.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    ld   hl,wDCCD_ConvictCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$05
    ld   c,$03
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCCD_ConvictCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter
    
call_03_52c8_CollisionHandler_YellowGoon:
; On collision (interaction=1):
; - If entity facing doesn’t match stored direction → handle entity hit.
; - Else → just player action change.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_00_29ac_Entity_IsFacingPlayer
    jp   z,call_03_4cea_CollisionHandler_DamagePlayer
    jp   call_03_5671_HandleEntityHit
    
call_03_52da_CollisionHandler_ChomperTV:
; On collision (interaction=1):
; - Handle entity hit.
; - If action ≠ 3 → load new entity data (bank 2).
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$03
    ret  z
    ld   a,$02
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_52fa_CollisionHandler_Bomb:
; If entity is action=4 → special hit handler.
; If action=2 and collision=1 → load new data (bank 3).
    call call_00_2962_Entity_GetActionId
    cp   a,$04
    jp   z,call_03_4ce1_CollisionHandler_GenericEnemy
    cp   a,$02
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,$03
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_531a_CollisionHandler_WaterTowerStand:
; On collision (interaction=1):
; - If wDCA9_FlyTimerOrFlags4–wDCAB_FlyTimerOrFlags2 flags set → handle entity hit, then set slot active.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   hl,wDCA9_FlyTimerOrFlags4
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    ret  z
    call call_03_5671_HandleEntityHit
    jp   call_00_22ef_Entity_SetTriggerActive
    
call_03_532f_CollisionHandler_GextremeSports_Elf:
; Works for actions < 4 only.
; On collision (interaction=1):
; - Loads new data (bank 4).
; - Decrements entity counter wDCD5_ElfHealth1.
; - If zero → clear entity, increment wDCC8_ElfCounter, dispatch action.
; - If all counters = 0 → set wDCD2_FreestandingRemoteHitFlags=1 (event flag).
    call call_00_2962_Entity_GetActionId
    cp   a,$04
    ret  nc
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    ld   a,$04
    farcall call_02_72ac_SetEntityAction
    call call_00_230f_Entity_GetParameterIntoC
    ld   b,$00
    ld   hl,wDCD5_ElfHealth1
    add  hl,bc
    ld   a,[hl]
    and  a
    ret  z
    dec  [hl]
    ret  nz
    call call_00_288a_Entity_SetCollisionTypeNone
    call call_00_2b8b_AttemptToSetEntityFlagsTo50
    ld   hl,wDCC8_ElfCounter
    inc  [hl]
    ld   a,[hl]
    call call_00_2c09_Entity_SpawnGoalCounter
    ld   hl,wDCD5_ElfHealth1
    ld   b,$05
    xor  a
.jr_00_536D:
    or   [hl]
    inc  hl
    dec  b
    jr   nz,.jr_00_536D
    and  a
    ret  nz
    ld   a,$01
    ld   [wDCD2_FreestandingRemoteHitFlags],a
    ret  
    
call_03_537a_CollisionHandler_BonusTimeCoin:
; On collision (interaction=1):
; - Adds parameter to wDB6E_BonusStageTimerHi.
; - Handles entity hit.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,[wDB6E_BonusStageTimerHi]
    add  c
    ld   [wDB6E_BonusStageTimerHi],a
    jp   call_03_5671_HandleEntityHit
    
call_03_538e_CollisionHandler_Bell:
; On collision (interaction=1):
; - If action=0 → increment wDCCC_BellCounter, dispatch action, set wDCD2_FreestandingRemoteHitFlags=1 when =7.
; - Always load new data (bank 1), set status nibble=2.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    jr   nz,.jr_00_53B0
    ld   hl,wDCCC_BellCounter
    inc  [hl]
    ld   a,[hl]
    call call_00_2c09_Entity_SpawnGoalCounter
    ld   a,[wDCCC_BellCounter]
    cp   a,$07
    jr   nz,.jr_00_53B0
    ld   a,$01
    ld   [wDCD2_FreestandingRemoteHitFlags],a
.jr_00_53B0:
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    ld   c,$02
    jp   call_00_2299_Entity_UpdateFlags

call_03_53c2_CollisionHandler_RockHard:
; For actions < 5.
; If action=3: only transform if wDC88_CurrentEntity_UnkVerticalOffset=0.
; Else, collision (interaction=1) → handle entity hit.
    call call_00_2962_Entity_GetActionId
    cp   a,$05
    ret  nc
    cp   a,$03
    jr   z,.jr_00_53D6
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   z,call_03_5671_HandleEntityHit
    ret  
.jr_00_53D6:
    ld   a,[wDC88_CurrentEntity_UnkVerticalOffset]
    and  a
    ret  nz
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    jp   call_03_4cea_CollisionHandler_DamagePlayer
    
call_03_53eb_CollisionHandler_Cannon:
; For action=2 only.
; On collision (interaction=1): loads new data (bank 3).
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,$03
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_5406_CollisionHandler_BrainOfOz:
; Complex distance check against another entity.
; If player is within a 0x0C–0x18 box both X and Y:
; - Handle entity hit.
; - If action≠7 → transform to bank 6.
    call call_03_4ce1_CollisionHandler_GenericEnemy
    call call_00_2995_Entity_GetActionId
    cp   a,$06
    ret  nc
    ld   c,ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    call call_00_29ce_Entity_CheckExists
    ret  nz
    ld   a,l
    or   a,$1D
    ld   l,a
    bit  7,[hl]
    ret  z
    ld   a,l
    xor  a,$13
    ld   l,a
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_XPOS
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
    call call_03_5671_HandleEntityHit
    call call_00_2995_Entity_GetActionId
    cp   a,$07
    ret  z
    ld   a,$06
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_5469_CollisionHandler_BrainOfOzProjectile:
; On collision (any interaction): player action change, clear entity.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_03_4cea_CollisionHandler_DamagePlayer
    jp   call_00_2b7a_DeactivateEntity

call_03_5473_CollisionHandler_FreestandingRemote:
; On collision (interaction=1): set wDCD2_FreestandingRemoteHitFlags=0x81 (event flag).
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:5473 $cd $0e $55
    ret  NC                                            ;; 03:5476 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:5477 $fe $01
    ret  NZ                                            ;; 03:5479 $c0
    call call_00_2962_Entity_GetActionId                                  ;; 03:547a $cd $62 $29
    ld   A, $81                                        ;; 03:547d $3e $81
    ld   [wDCD2_FreestandingRemoteHitFlags], A                                    ;; 03:547f $ea $d2 $dc
    ret                                                ;; 03:5482 $c9
    
call_03_5483_CollisionHandler_Meteor:
; On collision (interaction=0):
; - If action=0 → set Y from map, load new entity data (bank 1).
; - If action=1 → player action change.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_TOUCHED_ENTITY
    ret  nz
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    jr   z,.jr_03_5497
    cp   a,$01
    jp   z,call_03_4cea_CollisionHandler_DamagePlayer
    ret  
.jr_03_5497:
    call call_00_2780_Entity_CheckIfOffscreenAbove
    ld   a,$01
    farcall call_02_72ac_SetEntityAction
    ret                                          ;; 03:5482 $c9
    
call_03_54a8_CollisionHandler_Rez:
; For actions < 3.
; - On collision (interaction=1):
; - Handle entity hit, zero out byte at offset 15.
; - Get entity property, decide an action (03/06/09/0C → action3 else → action9).
; - Transform via that action.
    call call_00_2995_Entity_GetActionId
    cp   a,$03
    ret  nc
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   [hl],$00
    call call_00_2995_Entity_GetActionId
    cp   a,$0A
    ret  z
    call call_00_28b4_Entity_Get16
    ld   c,$03
    cp   a,$03
    jr   z,.jr_00_54E1
    cp   a,$06
    jr   z,.jr_00_54E1
    cp   a,$09
    jr   z,.jr_00_54E1
    cp   a,$0C
    jr   z,.jr_00_54E1
    ld   c,$09
.jr_00_54E1:
    ld   a,c
    farcall call_02_72ac_SetEntityAction
    ret  
    
call_03_54ee_CollisionHandler_RaStatueProjectile:
; On collision: always triggers player action change, then transforms to bank0.
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_03_4cea_CollisionHandler_DamagePlayer
    ld   a,$00
    farcall call_02_72ac_SetEntityAction
    ret  

call_03_54f9_InitializeEntityCooldownTimer: ; unreferenced function?
; Writes 0x3C to byte at offset 15.
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_COOLDOWN_TIMER
    ld   [hl],TIMER_AMOUNT_60_FRAMES
    ret  

call_03_550e_Entity_CheckPlayerInteraction:
; Returns interaction result in A and sets Carry if an interaction occurred.
; Crouching shifts the effective collision box down, letting the player avoid some entities they'd otherwise hit.
;
; Return format:
;   Carry = 0 → No interaction (entity inactive, cooldown, etc.)
;   Carry = 1 → Interaction happened, with type encoded in A:
;       A = 0 → Player touched entity
;       A = 1 → Player attacked the entity (with tail spin)
;       A = 2 → Player stomped the entity
;
; Implementation note:
;   The routine uses A=$FF then `add A,n` to set carry via overflow and
;   simultaneously return (A = n-1) as the interaction type.
    LOAD_OBJ_FIELD_TO_BC ENTITY_FIELD_COOLDOWN_TIMER
    ld   A, [BC]                                       ;; 03:5516 $0a
    and  A, A                                          ;; 03:5517 $a7
    jp   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:5518 $c2 $fd $55
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   L, [HL]                                       ;; 03:5523 $6e
    ld   H, $00                                        ;; 03:5524 $26 $00
    ld   DE, .data_03_55ff_EntityInteractionFlagsTable                              ;; 03:5526 $11 $ff $55
    add  HL, DE                                        ;; 03:5529 $19
    ld   A, [HL]                                       ;; 03:552a $7e
    ld   [wDC58_CurrentEntityInteractionFlags], A                                    ;; 03:552b $ea $58 $dc
    ld   HL, wD810_PlayerYPosition                                     ;; 03:552e $21 $10 $d8
    ld   A, [HL+]                                      ;; 03:5531 $2a
    ld   H, [HL]                                       ;; 03:5532 $66
    ld   L, A                                          ;; 03:5533 $6f
    ld   A, [wD801_Player_ActionId]                                    ;; 03:5534 $fa $01 $d8
    ld   DE, $00                                       ;; 03:5537 $11 $00 $00
    cp   A, PLAYERACTION_CROUCH_LOOK_DOWN                                        ;; 03:553a $fe $05
    jr   NZ, .jr_03_5541                                ;; 03:553c $20 $03
    ld   DE, $08                                       ;; 03:553e $11 $08 $00
.jr_03_5541:
    add  HL, DE                                        ;; 03:5541 $19
    ld   A, [wDC88_CurrentEntity_UnkVerticalOffset]                                    ;; 03:5542 $fa $88 $dc
    ld   E, A                                          ;; 03:5545 $5f
    ld   D, $00                                        ;; 03:5546 $16 $00
    bit  7, A                                          ;; 03:5548 $cb $7f
    jr   Z, .jr_03_554d                                ;; 03:554a $28 $01
    dec  D                                             ;; 03:554c $15
.jr_03_554d:
    add  HL, DE                                        ;; 03:554d $19
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:554e $fa $00 $da
    or   A, ENTITY_FIELD_YPOS                                        ;; 03:5551 $f6 $10
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
    ld   A, [BC]                                       ;; 03:555f $0a ; loads ENTITY_FIELD_HEIGHT
    add  A, E                                          ;; 03:5560 $83
    ld   E, A                                          ;; 03:5561 $5f
    ld   A, $00                                        ;; 03:5562 $3e $00
    adc  A, D                                          ;; 03:5564 $8a
    jp   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:5565 $c2 $fd $55
    ld   A, [BC]                                       ;; 03:5568 $0a ; loads ENTITY_FIELD_HEIGHT
    add  A, A                                          ;; 03:5569 $87
    cp   A, E                                          ;; 03:556a $bb
    jp   C, .jr_03_55fd_ReturnNoInteraction                                 ;; 03:556b $da $fd $55
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:556e $21 $0e $d8
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:5571 $fa $00 $da
    or   A, ENTITY_FIELD_XPOS                                        ;; 03:5574 $f6 $0e
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
    ld   A, [BC]                                       ;; 03:5583 $0a ; loads ENTITY_FIELD_WIDTH
    add  A, $08                                        ;; 03:5584 $c6 $08
    add  A, E                                          ;; 03:5586 $83
    ld   E, A                                          ;; 03:5587 $5f
    ld   A, $00                                        ;; 03:5588 $3e $00
    adc  A, D                                          ;; 03:558a $8a
    jr   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:558b $20 $70
    ld   A, [BC]                                       ;; 03:558d $0a ; loads ENTITY_FIELD_WIDTH
    add  A, $08                                        ;; 03:558e $c6 $08
    add  A, A                                          ;; 03:5590 $87
    cp   A, E                                          ;; 03:5591 $bb
    jr   C, .jr_03_55fd_ReturnNoInteraction                                 ;; 03:5592 $38 $69
    ld   A, [wDC58_CurrentEntityInteractionFlags]                                    ;; 03:5594 $fa $58 $dc
    bit  1, A                                          ;; 03:5597 $cb $4f
    jr   Z, .jr_03_55a9                                ;; 03:5599 $28 $0e
    ld   HL, wDC7F_Player_IsAttacking                                     ;; 03:559b $21 $7f $dc
    bit  0, [HL]                                       ;; 03:559e $cb $46
    jr   Z, .jr_03_55a9                                ;; 03:55a0 $28 $07
    ld   [HL], $00                                     ;; 03:55a2 $36 $00
    ld   A, $ff                                        ;; 03:55a4 $3e $ff
    add  A, $02                                        ;; 03:55a6 $c6 $02
    ret                                                ;; 03:55a8 $c9
.jr_03_55a9:
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:55a9 $21 $0e $d8
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:55ac $fa $00 $da
    or   A, ENTITY_FIELD_XPOS                                        ;; 03:55af $f6 $0e
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
    jr   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:55c4 $20 $37
    ld   A, [BC]                                       ;; 03:55c6 $0a
    add  A, A                                          ;; 03:55c7 $87
    cp   A, E                                          ;; 03:55c8 $bb
    jr   C, .jr_03_55fd_ReturnNoInteraction                                 ;; 03:55c9 $38 $32
    ld   A, [wDC58_CurrentEntityInteractionFlags]                                    ;; 03:55cb $fa $58 $dc
    bit  2, A                                          ;; 03:55ce $cb $57
    jr   Z, .jr_03_55f3                                ;; 03:55d0 $28 $21
    ld   A, [wD801_Player_ActionId]                                    ;; 03:55d2 $fa $01 $d8
    cp   A, PLAYERACTION_JUMP                                        ;; 03:55d5 $fe $0e
    jr   Z, .jr_03_55e5                                ;; 03:55d7 $28 $0c
    cp   A, PLAYERACTION_DOUBLE_JUMP                                        ;; 03:55d9 $fe $0f
    jr   Z, .jr_03_55e5                                ;; 03:55db $28 $08
    cp   A, PLAYERACTION_SNOWBOARDING_JUMP                                        ;; 03:55dd $fe $25
    jr   Z, .jr_03_55e5                                ;; 03:55df $28 $04
    cp   A, PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP                                        ;; 03:55e1 $fe $26
    jr   NZ, .jr_03_55f3                               ;; 03:55e3 $20 $0e
.jr_03_55e5:
    ld   HL, wDC8C_PlayerYVelocity                                     ;; 03:55e5 $21 $8c $dc
    bit  7, [HL]                                       ;; 03:55e8 $cb $7e
    jr   Z, .jr_03_55f3                                ;; 03:55ea $28 $07
    ld   [HL], $2a                                     ;; 03:55ec $36 $2a
    ld   A, $ff                                        ;; 03:55ee $3e $ff
    add  A, $03                                        ;; 03:55f0 $c6 $03
    ret                                                ;; 03:55f2 $c9
.jr_03_55f3:
    call call_00_0759_IsPlayerDamageCooldownActive                                  ;; 03:55f3 $cd $59 $07
    jr   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:55f6 $20 $05
    ld   A, $ff                                        ;; 03:55f8 $3e $ff
    add  A, $01                                        ;; 03:55fa $c6 $01
    ret                                                ;; 03:55fc $c9
.jr_03_55fd_ReturnNoInteraction:
; Just xor A and ret.
; Acts as the "failed collision / no interaction" exit for call_03_550e.
    xor  A, A                                          ;; 03:55fd $af
    ret                                                ;; 03:55fe $c9
.data_03_55ff_EntityInteractionFlagsTable:
; What it is:
; A lookup table of bytes, indexed by entity type or subtype.
; Each value is stored in wDC58_CurrentEntityInteractionFlags and influences behavior bits:
; - Bit 0 (01) → can be interacted with by touching?
; - Bit 1 (02) → can be hit with tailspin?
; - Bit 2 (04) → can be stomped?
; Others may map to more cases.
    db   $00 ; ENTITY_GEX
    db   $03 ; ENTITY_BONUS_COIN
    db   $03 ; ENTITY_FLY_COIN_SPAWN
    db   $03 ; ENTITY_PAW_COIN
    db   $03 ; ENTITY_FLY_1
    db   $03 ; ENTITY_FLY_2
    db   $03 ; ENTITY_FLY_3
    db   $03 ; ENTITY_FLY_4
    db   $03 ; ENTITY_FLY_5
    db   $02 ; ENTITY_GREEN_FLY_TV
    db   $02 ; ENTITY_PURPLE_FLY_TV
    db   $02 ; ENTITY_UNK_FLY_TV_3
    db   $02 ; ENTITY_BLUE_FLY_TV
    db   $02 ; ENTITY_UNK_FLY_TV_5
    db   $00 ; ENTITY_UNK0E
    db   $00 ; ENTITY_UNK0F
    db   $00 ; ENTITY_UNK10
    db   $01 ; ENTITY_TV_BUTTON
    db   $00 ; ENTITY_TV_REMOTE
    db   $00 ; ENTITY_UNK13
    db   $00 ; ENTITY_GOAL_COUNTER_1
    db   $00 ; ENTITY_GOAL_COUNTER_2
    db   $00 ; ENTITY_GOAL_COUNTER_3
    db   $00 ; ENTITY_GOAL_COUNTER_4
    db   $00 ; ENTITY_GOAL_COUNTER_5
    db   $00 ; ENTITY_GOAL_COUNTER_6
    db   $00 ; ENTITY_GOAL_COUNTER_7
    db   $00 ; ENTITY_BONUS_STAGE_TIMER
    db   $02 ; ENTITY_FREESTANDING_REMOTE
    db   $02 ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
    db   $01 ; ENTITY_HOLIDAY_TV_EVIL_SANTA
    db   $03 ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    db   $03 ; ENTITY_HOLIDAY_TV_SKATING_ELF
    db   $07 ; ENTITY_HOLIDAY_TV_PENGUIN
    db   $07 ; ENTITY_MYSTERY_TV_REZLING
    db   $02 ; ENTITY_MYSTERY_TV_BLOOD_COOLER
    db   $01 ; ENTITY_MYSTERY_TV_FISH
    db   $03 ; ENTITY_MYSTERY_TV_MAGIC_SWORD
    db   $03 ; ENTITY_MYSTERY_TV_SAFARI_SAM
    db   $01 ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    db   $03 ; ENTITY_MYSTERY_TV_GHOST_KNIGHT
    db   $01 ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
    db   $03 ; ENTITY_TUT_TV_HAND
    db   $04 ; ENTITY_TUT_TV_LOST_ARK
    db   $00 ; ENTITY_TUT_TV_RISING_PLATFORM
    db   $00 ; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
    db   $03 ; ENTITY_TUT_TV_BEE
    db   $00 ; ENTITY_TUT_TV_RAFT
    db   $05 ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
    db   $05 ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
    db   $01 ; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    db   $01 ; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
    db   $02 ; ENTITY_TUT_TV_RA_STAFF
    db   $01 ; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE
    db   $01 ; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
    db   $00 ; ENTITY_TUT_TV_BREAKABLE_BLOCK
    db   $02 ; ENTITY_TUT_TV_COFFIN
    db   $03 ; ENTITY_WESTERN_STATION_ENEMY_CACTUS
    db   $01 ; ENTITY_WESTERN_STATION_CACTUS
    db   $00 ; ENTITY_WESTERN_STATION_ROCK_PLATFORM
    db   $03 ; ENTITY_WESTERN_STATION_HARD_HAT
    db   $06 ; ENTITY_WESTERN_STATION_PLAYING_CARD
    db   $03 ; ENTITY_WESTERN_STATION_BAT
    db   $00 ; ENTITY_WESTERN_STATION_RISING_PLATFORM
    db   $01 ; ENTITY_ANIME_CHANNEL_DOOR
    db   $01 ; ENTITY_ANIME_CHANNEL_DOOR2
    db   $00 ; ENTITY_ANIME_CHANNEL_FAN_LIFT
    db   $03 ; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT
    db   $03 ; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
    db   $00 ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR
    db   $02 ; ENTITY_ANIME_CHANNEL_ON_SWITCH2
    db   $02 ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
    db   $01 ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER
    db   $00 ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM
    db   $02 ; ENTITY_ANIME_CHANNEL_ON_SWITCH
    db   $02 ; ENTITY_ANIME_CHANNEL_OFF_SWITCH
    db   $03 ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
    db   $03 ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
    db   $05 ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
    db   $03 ; ENTITY_ANIME_CHANNEL_SECBOT
    db   $01 ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
    db   $00 ; ENTITY_ANIME_CHANNEL_ELEVATOR
    db   $00 ; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY
    db   $01 ; ENTITY_ANIME_CHANNEL_GRENADE
    db   $04 ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
    db   $00 ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    db   $03 ; ENTITY_SUPERHERO_SHOW_BOMB
    db   $00 ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
    db   $03 ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
    db   $03 ; ENTITY_SUPERHERO_SHOW_CONVICT
    db   $03 ; ENTITY_SUPERHERO_SHOW_SPIDER
    db   $07 ; ENTITY_SUPERHERO_SHOW_STRAY_CAT
    db   $03 ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON
    db   $03 ; ENTITY_SUPERHERO_SHOW_RAT
    db   $03 ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV
    db   $00 ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
    db   $01 ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
    db   $03 ; ENTITY_GEXTREME_SPORTS_ELF
    db   $02 ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
    db   $02 ; ENTITY_MARSUPIAL_MADNESS_BELL
    db   $01 ; ENTITY_MARSUPIAL_MADNESS_BIRD
    db   $01 ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
    db   $03 ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD
    db   $01 ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
    db   $00 ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    db   $02 ; ENTITY_LIZARD_OF_OZ_CANNON
    db   $01 ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
    db   $00 ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2
    db   $00 ; ENTITY_CHANNEL_Z_GREEN_BLOCK
    db   $00 ; ENTITY_CHANNEL_Z_ORANGE_BLOCK
    db   $03 ; ENTITY_CHANNEL_Z_REZ
    db   $01 ; ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
    db   $01 ; ENTITY_CHANNEL_Z_METEOR
    db   $01 ; ENTITY_CHANNEL_Z_REZ_PROJECTILE

call_03_5671_HandleEntityHit:
; Input:
;   ENTITY_FIELD_DAMAGE_STATE = hit type / HP+1
;   ENTITY_FIELD_COOLDOWN_TIMER prevents repeated hits
;
; Behavior:
;   If cooldown != 0           → return
;   If hit = FF or hit = 00    → return (no hit)
;   If hit = 01                → kill entity
;   If hit > 01                → damage entity (decrement HP)
;
; Kill path:
;   - Clear hit field
;   - Get collision flags
;   - If flags == FF: deactivate entity
;   - If flags.bit7 set:
;         remove collision, reset facing, spawn burst particles
;   - Set new entity action via action table
;   - Play SFX_ENEMY_KILLED
;
; Damage path:
;   - Store (hit - 1)
;   - Set 60-frame cooldown
;   - Play SFX_ENEMY_DAMAGED
; ----------------------------------------------
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   A, [HL]                                       ;; 03:5679 $7e
    and  A, A                                          ;; 03:567a $a7
    ret  NZ                                            ;; 03:567b $c0
    inc  L                                             ;; 03:567c $2c ; HL = ENTITY_FIELD_DAMAGE_STATE
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
    call call_00_35e8_GetEntityCollisionFlags                                  ;; 03:568b $cd $e8 $35
    cp   A, $ff                                        ;; 03:568e $fe $ff
    jp   Z, call_00_2b7a_DeactivateEntity                                 ;; 03:5690 $ca $7a $2b
    bit  7, A                                          ;; 03:5693 $cb $7f
    jr   Z, .jr_03_56a6                                ;; 03:5695 $28 $0f
    push AF                                            ;; 03:5697 $f5
    ld   C, COLLISION_TYPE_NONE                                        ;; 03:5698 $0e $00
    call call_00_288c_Entity_SetCollisionType                                  ;; 03:569a $cd $8c $28
    ld   C, ENTITY_FACING_RIGHT                                        ;; 03:569d $0e $00
    call call_00_2958_Entity_SetFacingDirection                                  ;; 03:569f $cd $58 $29
    call call_00_2c67_Particle_InitBurst                                  ;; 03:56a2 $cd $67 $2c
    pop  AF                                            ;; 03:56a5 $f1
.jr_03_56a6:
    and  A, $3f                                        ;; 03:56a6 $e6 $3f
    farcall call_02_72ac_SetEntityAction
    ld   A, SFX_ENEMY_KILLED                                        ;; 03:56b3 $3e $10
    jp   call_00_0ff5_QueueSoundEffect                                  ;; 03:56b5 $c3 $f5 $0f
.jr_03_56b8:
    ld   [HL], A                                       ;; 03:56b8 $77
    dec  L                                             ;; 03:56b9 $2d ; HL = ENTITY_FIELD_COOLDOWN_TIMER
    ld   [HL], TIMER_AMOUNT_60_FRAMES                                     ;; 03:56ba $36 $3c
    ld   A, SFX_ENEMY_DAMAGED                                        ;; 03:56bc $3e $0f
    jp   call_00_0ff5_QueueSoundEffect                                  ;; 03:56be $c3 $f5 $0f

call_03_56c1_CollisionHandler_Platform:
; Early exit if the player’s ActionId is in certain states 
; (1A, 2E, 3B, 1B = probably cutscenes, knockback, death, or other "don’t collide" states).
; Otherwise, it takes the player’s Y position + vertical offset (wDC88_CurrentEntity_UnkVerticalOffset, which looks like a 
; per-frame Y delta or velocity), then compares against the current entity’s bounding box 
; stored at $D8xx (using wDA00_CurrentEntityAddrLo).
; Performs bounding-box intersection checks for both vertical and horizontal overlap.
; Splits into several cases depending on whether the player is above, below, or inside the entity.
; If overlap is valid, it calls into call_03_58a9_ComputeCollisionOffset for fine-grained offset adjustment and then either:
; Jumps to call_03_580b_RegisterSecondaryCollision (registers the entity as the active collision target),
; Or to call_03_57f8_ClearCollisionForEntity (clear/ignore collision).
; Role: The main "does the player collide with this entity?" function.
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_DEATH_IN_PIT_ALT
    jp   z,call_03_57f8_ClearCollisionForEntity
    cp   a,PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    jp   z,call_03_57f8_ClearCollisionForEntity
    cp   a,PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT
    jp   z,call_03_57f8_ClearCollisionForEntity
    cp   a,PLAYERACTION_DEATH_IN_PIT
    jp   z,call_03_57f8_ClearCollisionForEntity
    ld   a,[wDC88_CurrentEntity_UnkVerticalOffset]
    ld   e,a
    ld   d,$00
    bit  7,a
    jr   z,.jr_00_56E3
    dec  d
.jr_00_56E3:
    ld   a,[wD810_PlayerYPosition]
    add  e
    ld   e,a
    ld   a,[wD810_PlayerYPosition+1]
    adc  d
    ld   d,a
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   a,e
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,d
    sbc  [hl]
    ld   d,a
    jr   c,.jr_00_570D
    and  a
    jp   nz,call_03_57f8_ClearCollisionForEntity
    inc  l
    inc  l
    ldd  a,[hl]
    add  a,$0F
    cp   e
    jp   c,call_03_57f8_ClearCollisionForEntity
    jr   .jr_00_571F
.jr_00_570D:
    xor  a
    sub  e
    ld   e,a
    ld   a,$00
    sbc  d
    and  a
    jp   nz,call_03_57f8_ClearCollisionForEntity
    inc  l
    inc  l
    ldd  a,[hl]
    add  a,$0F
    cp   e
    jr   c,.jr_00_577C
.jr_00_571F:
    ld   c,[hl]
    ld   a,l
    xor  a,$1C
    ld   l,a
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    ld   d,a
    ld   a,e
    add  c
    ld   e,a
    ld   a,d
    adc  a,$00
    bit  7,a
    jr   nz,.jr_00_575D
    and  a
    jp   nz,call_03_57f8_ClearCollisionForEntity
    ld   a,e
    sla  c
    sub  c
    jp   c,call_03_57f8_ClearCollisionForEntity
    cp   a,$08
    jp   nc,call_03_57f8_ClearCollisionForEntity
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
    jp   call_03_57f8_ClearCollisionForEntity
.jr_00_575D:
    inc  d
    jp   nz,call_03_57f8_ClearCollisionForEntity
    ld   a,e
    cpl  
    cp   a,$08
    jp   nc,call_03_57f8_ClearCollisionForEntity
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
    jp   call_03_57f8_ClearCollisionForEntity
.jr_00_577C:
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
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    ld   d,a
    ld   a,e
    add  c
    ld   e,a
    ld   a,$00
    adc  d
    jr   nz,call_03_57f8_ClearCollisionForEntity
    ld   a,c
    add  a
    cp   e
    jr   c,call_03_57f8_ClearCollisionForEntity
    inc  l
    ldi  a,[hl]
    sub  b
    ld   c,a
    ld   a,[hl]
    sbc  a,$00
    ld   b,a
    ld   a,[wDC88_CurrentEntity_UnkVerticalOffset]
    ld   e,a
    ld   d,$00
    bit  7,a
    jr   z,.jr_00_57AE
    dec  d
.jr_00_57AE:
    ld   a,[wD810_PlayerYPosition]
    add  e
    ld   e,a
    ld   a,[wD810_PlayerYPosition+1]
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
    jr   c,call_03_57f8_ClearCollisionForEntity
    jr   nz,call_03_57f8_ClearCollisionForEntity
    ld   a,c
    cp   a,$10
    jr   nc,call_03_57f8_ClearCollisionForEntity
    ld   a,[wDC8C_PlayerYVelocity]
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
    jr   call_03_57f8_ClearCollisionForEntity

call_03_57e6_ResolveCollision_Reset:
; Clears wDC88_CurrentEntity_UnkVerticalOffset (the player’s vertical delta).
; Stores the current entity ID (wDA00_CurrentEntityAddrLo) into wDC7B_CurrentEntityAddrLoAlt.
; If that ID was already in wDC7B_CurrentEntityAddrLoAlt2, resets it to zero.
; Role: This looks like a collision resolution / reset routine. 
; It wipes motion and registers the colliding entity as "current collision", 
; while clearing old records.
    xor  A, A                                          ;; 03:57e6 $af
    ld   [wDC88_CurrentEntity_UnkVerticalOffset], A                                    ;; 03:57e7 $ea $88 $dc
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:57ea $fa $00 $da
    ld   [wDC7B_CurrentEntityAddrLoAlt], A                                    ;; 03:57ed $ea $7b $dc
    ld   HL, wDC7B_CurrentEntityAddrLoAlt2                                     ;; 03:57f0 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:57f3 $be
    ret  NZ                                            ;; 03:57f4 $c0
    ld   [HL], $00                                     ;; 03:57f5 $36 $00
    ret                                                ;; 03:57f7 $c9

call_03_57f8_ClearCollisionForEntity:
; Compares the current entity ID to the two "last touched entity" slots (wDC7B_CurrentEntityAddrLoAlt and wDC7B_CurrentEntityAddrLoAlt2).
; If it matches, clears those slots.
; Effectively means: "This entity is no longer colliding with the player, remove it from tracking."
; Role: Collision cleanup when no intersection occurs.
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:57f8 $fa $00 $da
    ld   HL, wDC7B_CurrentEntityAddrLoAlt                                     ;; 03:57fb $21 $7b $dc
    cp   A, [HL]                                       ;; 03:57fe $be
    jr   NZ, .jr_03_5803                               ;; 03:57ff $20 $02
    ld   [HL], $00                                     ;; 03:5801 $36 $00
.jr_03_5803:
    ld   HL, wDC7B_CurrentEntityAddrLoAlt2                                     ;; 03:5803 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:5806 $be
    ret  NZ                                            ;; 03:5807 $c0
    ld   [HL], $00                                     ;; 03:5808 $36 $00
    ret                                                ;; 03:580a $c9

call_03_580b_RegisterSecondaryCollision:
; Marks the current entity as the "secondary" collision slot (wDC7B_CurrentEntityAddrLoAlt2).
; If it was in wDC7B_CurrentEntityAddrLoAlt, clears that first.
; Role: Assigns the entity as the active secondary collision candidate.
    ld   a,[wDA00_CurrentEntityAddrLo]
    ld   hl,wDC7B_CurrentEntityAddrLoAlt
    cp   [hl]
    jr   nz,.jr_00_5816
    ld   [hl],$00
.jr_00_5816:
    ld   [wDC7B_CurrentEntityAddrLoAlt2],a
    ret  

call_03_581a_CollisionHandler_TVButton:
; Skips entirely if the player is in the same "ignore" action IDs.
; Uses the entity’s width/height at $D8xx+12/+13 to test bounding-box intersection against the player.
; Again compares Y offset + vertical delta (wDC88_CurrentEntity_UnkVerticalOffset).
; If all checks pass, adjusts by camera scroll (wDC8C_PlayerYVelocity >> 4) and then calls into 57e6 (collision hit) or 57f8 (miss).
; Role: This is a simplified AABB collision test between the player and an entity. 
; It’s likely for a different type of entity (maybe platforms, triggers, or zones).
    ld   A, [wD801_Player_ActionId]                                    ;; 03:581a $fa $01 $d8
    cp   A, PLAYERACTION_DEATH_IN_PIT_ALT                                        ;; 03:581d $fe $1a
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:581f $ca $f8 $57
    cp   A, PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT                                        ;; 03:5822 $fe $2e
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:5824 $ca $f8 $57
    cp   A, PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT                                        ;; 03:5827 $fe $3b
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:5829 $ca $f8 $57
    cp   A, PLAYERACTION_DEATH_IN_PIT                                        ;; 03:582c $fe $1b
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:582e $ca $f8 $57
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WIDTH
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
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 03:5846 $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:5849 $9e
    ld   D, A                                          ;; 03:584a $57
    ld   A, E                                          ;; 03:584b $7b
    add  A, C                                          ;; 03:584c $81
    ld   E, A                                          ;; 03:584d $5f
    ld   A, $00                                        ;; 03:584e $3e $00
    adc  A, D                                          ;; 03:5850 $8a
    jr   NZ, call_03_57f8_ClearCollisionForEntity                                ;; 03:5851 $20 $a5
    ld   A, C                                          ;; 03:5853 $79
    add  A, A                                          ;; 03:5854 $87
    cp   A, E                                          ;; 03:5855 $bb
    jr   C, call_03_57f8_ClearCollisionForEntity                                 ;; 03:5856 $38 $a0
    inc  L                                             ;; 03:5858 $2c
    ld   A, [HL+]                                      ;; 03:5859 $2a
    sub  A, B                                          ;; 03:585a $90
    ld   C, A                                          ;; 03:585b $4f
    ld   A, [HL]                                       ;; 03:585c $7e
    sbc  A, $00                                        ;; 03:585d $de $00
    ld   B, A                                          ;; 03:585f $47
    ld   A, [wDC88_CurrentEntity_UnkVerticalOffset]                                    ;; 03:5860 $fa $88 $dc
    ld   E, A                                          ;; 03:5863 $5f
    ld   D, $00                                        ;; 03:5864 $16 $00
    bit  7, A                                          ;; 03:5866 $cb $7f
    jr   Z, .jr_03_586b                                ;; 03:5868 $28 $01
    dec  D                                             ;; 03:586a $15
.jr_03_586b:
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:586b $fa $10 $d8
    add  A, E                                          ;; 03:586e $83
    ld   E, A                                          ;; 03:586f $5f
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 03:5870 $fa $11 $d8
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
    jp   C, call_03_57f8_ClearCollisionForEntity                                 ;; 03:5883 $da $f8 $57
    jp   NZ, call_03_57f8_ClearCollisionForEntity                                ;; 03:5886 $c2 $f8 $57
    ld   A, C                                          ;; 03:5889 $79
    cp   A, $10                                        ;; 03:588a $fe $10
    jp   NC, call_03_57f8_ClearCollisionForEntity                                ;; 03:588c $d2 $f8 $57
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 03:588f $fa $8c $dc
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
    jp   call_03_57f8_ClearCollisionForEntity                                    ;; 03:58a6 $c3 $f8 $57

call_03_58a9_ComputeCollisionOffset:
; Loads the entity’s parameter at $D8xx+1B.
; Flips it if the entity’s direction byte ($D8xx+19) has bit 7 set (sign extension trick).
; Combines this with wDC84–wDC86_PlayerXVelocity (looks like camera or scroll deltas).
; Then checks wD80D_PlayerFacingDirection, and if bit 5 is set, flips the result.
; Role: This is a collision offset calculator: adjusts collision testing 
; depending on entity properties (size/offset) and player facing direction.
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   b,[hl]
    dec  l
    dec  l
    bit  7,[hl]
    jr   z,.jr_00_58BB
    xor  a
    sub  b
    ld   b,a
    .jr_00_58BB:
    ld   a,[wDC84]
    ld   d,a
    ld   a,[wDC85]
    add  d
    ld   d,a
    ld   a,[wDC86_PlayerXVelocity]
    ld   e,a
    ld   hl,wD80D_PlayerFacingDirection
    bit  5,[hl]
    ret  z
    cpl  
    inc  a
    ld   e,a
    ret  
