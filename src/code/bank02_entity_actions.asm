; ==================================================================
; ENTITY ACTION FUNCTIONS
;
; One function per row of the per-entity tables in
; bank02_entity_pointer_tables.asm. call_02_724d_Entity_TickAction calls the
; current one once a frame with wDA00_CurrentEntityAddrLo pointing at the entity's
; slot, and it decides what that entity does next.
;
; The action id an entity is in is a position in ITS OWN table and means nothing
; outside it, so `ld A, $02 / jp call_02_72ac_Entity_SetAction` reads as "row 2 of
; my table". Setting an action also reloads the animation from the row's data block
; in bank02_entity_animation_data.asm, which is why so many state changes here are
; a single jump with no other work: the sprite change comes for free.
;
; Two things happen without any code in this file:
;
;   a row whose function is call_02_582e_EntityAction_None is pure animation. The
;   data block's PENDING_ACTION byte names the action to enter when the animation
;   ends, so long scripted sequences - a chest opening, a knight vanishing and
;   reappearing - are entirely table-driven
;
;   a defeated enemy is put into an action by ENTITY_ATTR_DEFEAT_FLAGS in
;   data_00_3258_EntityAttributeTable, read by call_03_5671_HandleEntityHit. That
;   is the gex3 difference from gex2, which turned a defeated enemy into a generic
;   burst entity instead - here each enemy dies into a row of its own
;
; The shared routines come first, then one section per level in ENTITY_* id order
; ==================================================================

call_02_582e_EntityAction_None:
    ret                                                ;; 02:582e $c9

call_02_582f_EntityAction_DestroyWithoutParticles:
    call call_00_288a_Entity_SetCollisionTypeNone
    call call_00_2b8b_Entity_MarkDefeated
    call call_00_2a5d_Entity_CheckAnimationEnded
    jp   nz,call_00_2bbe_Entity_TurnIntoFlyCoin
    ret  

call_02_583c_EntityAction_Destroy:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:583c $cd $f5 $29
    jr   Z, .jr_02_5850                                ;; 02:583f $28 $0f
    ld   HL, .data_02_5857_ParticlesPalette                             ;; 02:5841 $21 $57 $58
    call call_00_2c20_Entity_CopyPaletteToBuffer                                  ;; 02:5844 $cd $20 $2c
    call call_00_288a_Entity_SetCollisionTypeNone                                  ;; 02:5847 $cd $8a $28
    call call_00_2b8b_Entity_MarkDefeated                                  ;; 02:584a $cd $8b $2b
    call call_00_2c67_Particle_InitBurst                                  ;; 02:584d $cd $67 $2c
.jr_02_5850:
    call call_00_2c89_Particle_UpdateBurst                                  ;; 02:5850 $cd $89 $2c
    jp   Z, call_00_2bbe_Entity_TurnIntoFlyCoin                                 ;; 02:5853 $ca $be $2b
    ret                                                ;; 02:5856 $c9
.data_02_5857_ParticlesPalette:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f        ;; 02:5857 ........

call_02_585f_EntityAction_MovePlatformHorizontally:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_586E
    ld   c,$80
    call call_00_2980_Entity_SetMiscFlags
    ld   c,TIMER_AMOUNT_240_FRAMES
    call call_00_290d_Entity_SetMiscTimer
.jr_00_586E:
    call call_00_298a_Entity_GetMiscFlags
    bit  7,[hl]
    jr   z,.jr_00_588C
    ld   c,$00
    call call_00_28c8_Entity_SetXVelocity
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    call call_00_298a_Entity_GetMiscFlags
    and  a,$7F
    xor  a,$40
    ld   [hl],a
    call call_00_230f_Entity_GetParameterIntoC
    jp   call_00_290d_Entity_SetMiscTimer
.jr_00_588C:
    ld   c,$01
    call call_00_28c8_Entity_SetXVelocity
    call call_00_298a_Entity_GetMiscFlags
    ld   bc,$0001
    bit  6,[hl]
    jr   nz,.jr_00_589E
    ld   bc,$FFFF
.jr_00_589E:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,c
    add  [hl]
    ldi  [hl],a
    ld   a,b
    adc  [hl]
    ld   [hl],a
    call call_00_26c9_Entity_CarryOrPushPlayerX
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    call call_00_298a_Entity_GetMiscFlags
    set  7,[hl]
    ld   c,TIMER_AMOUNT_120_FRAMES
    jp   call_00_290d_Entity_SetMiscTimer

call_02_58bd_EntityAction_MovePlatformVertically:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_58CC
    ld   c,$80
    call call_00_2980_Entity_SetMiscFlags
    ld   c,TIMER_AMOUNT_240_FRAMES
    call call_00_290d_Entity_SetMiscTimer
.jr_00_58CC:
    call call_00_298a_Entity_GetMiscFlags
    bit  7,[hl]
    jr   z,.jr_00_58EA
    ld   c,$00
    call call_00_28dc_Entity_SetYVelocity
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    call call_00_298a_Entity_GetMiscFlags
    and  a,$7F
    xor  a,$40
    ld   [hl],a
    call call_00_230f_Entity_GetParameterIntoC
    jp   call_00_290d_Entity_SetMiscTimer
.jr_00_58EA:
    ld   c,$01
    call call_00_28dc_Entity_SetYVelocity
    call call_00_298a_Entity_GetMiscFlags
    ld   bc,$0001
    bit  6,[hl]
    jr   nz,.jr_00_58FC
    ld   bc,$FFFF
.jr_00_58FC:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ld   a,c
    add  [hl]
    ldi  [hl],a
    ld   a,b
    adc  [hl]
    ld   [hl],a
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    call call_00_298a_Entity_GetMiscFlags
    set  7,[hl]
    ld   c,TIMER_AMOUNT_120_FRAMES
    jp   call_00_290d_Entity_SetMiscTimer

call_02_5918_EntityAction_Fly_Update:
    ld   a,[wDC71_VBlankFrameCounter]
    rrca 
    and  a,$0F
    ld   l,a
    ld   h,00
    add  hl,hl
    add  hl,hl
    ld   bc,.data_02_594f
    add  hl,bc
    ld   c,l
    ld   b,h
    call call_00_2835_Entity_GetInitialXPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,[bc]
    add  e
    ldi  [hl],a
    inc  bc
    ld   a,[bc]
    adc  d
    ld   [hl],a
    inc  bc
    call call_00_27f3_Entity_GetInitialYPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ld   a,[bc]
    add  e
    ldi  [hl],a
    inc  bc
    ld   a,[bc]
    adc  d
    ld   [hl],a
    ret  
.data_02_594f:
    db   $00, $00, $de, $ff, $fe, $ff, $dc, $ff        ;; 02:594f ????????
    db   $fc, $ff, $e0, $ff, $fc, $ff, $e0, $ff        ;; 02:5957 ????????
    db   $fa, $ff, $e2, $ff, $fc, $ff, $e4, $ff        ;; 02:595f ????????
    db   $fe, $ff, $e2, $ff, $00, $00, $e4, $ff        ;; 02:5967 ????????
    db   $00, $00, $e2, $ff, $fe, $ff, $e0, $ff        ;; 02:596f ????????
    db   $fe, $ff, $de, $ff, $fc, $ff, $dc, $ff        ;; 02:5977 ????????
    db   $fa, $ff, $da, $ff, $fc, $ff, $d8, $ff        ;; 02:597f ????????
    db   $fe, $ff, $da, $ff, $00, $00, $dc, $ff        ;; 02:5987 ????????

call_02_598f_EntityAction_FlyTV_SpawnFly:
    call call_02_59D2_FlyTV_unk
    push bc
    call call_00_2b10_Entity_FindDuplicateInstance
    pop  bc
    ld   c,b
    call z,call_00_3792_EntitySpawn_SpawnChild
    ld   a,$03
    jp   call_02_72ac_Entity_SetAction
    
    db   $00, $04, $01, $05, $02, $06, $03        ;; 02:599f ????????
    db   $07, $04, $08

call_02_59aa_EntityAction_FlyTV_Reset:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,TIMER_AMOUNT_120_FRAMES
    call nz,call_00_290d_Entity_SetMiscTimer
    call call_02_59D2_FlyTV_unk
    call call_00_2b10_Entity_FindDuplicateInstance
    ret  nz
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    and  a
    ret  z
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    ld   c,$01
    call call_00_28aa_Entity_SetDamageState
    ld   c,$00
    call call_00_2299_Entity_SetListState
    ld   a,$04
    jp   call_02_72ac_Entity_SetAction

call_02_59D2_FlyTV_unk:
    call call_00_293a_Entity_GetId
    sub  a,$09
    ld   l,a
    ld   h,$00
    add  hl,hl
    ld   de,.data_02_59e3
    add  hl,de
    ld   b,[hl]
    inc  hl
    ld   c,[hl]
    ret  
.data_02_59e3:
    db   $00, $04, $01, $05        ;; 02:59df ????????
    db   $02, $06, $03, $07, $04, $08
    
call_02_59ed_EntityAction_Unk_unk:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_5A00
    call call_00_2976_Entity_GetFacingDirection
    ld   c,$D0
    and  a,$20
    jr   nz,.jr_00_59FD
    ld   c,$30
.jr_00_59FD:
    call call_00_28c8_Entity_SetXVelocity
.jr_00_5A00:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    ret  

call_02_5a04_EntityAction_TVButton_unk:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:5a04 $cd $f5 $29
    jr   NZ, call_02_5a83_EntityAction_TVButton_unk4                                ;; 02:5a07 $20 $7a
    ld   C, $00                                        ;; 02:5a09 $0e $00
    call call_00_22b1_Entity_SetListStateAndAction                                  ;; 02:5a0b $cd $b1 $22
    ld   HL, .data_02_5a14                             ;; 02:5a0e $21 $14 $5a
    jp   call_00_2c20_Entity_CopyPaletteToBuffer                                  ;; 02:5a11 $c3 $20 $2c
.data_02_5a14:
    db   $00, $00, $00, $00, $73, $4e, $1f, $00        ;; 02:5a14 ........

call_02_5a1c_EntityAction_TVButton_unk2:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:5a1c $cd $f5 $29
    jr   NZ, call_02_5a83_EntityAction_TVButton_unk4                                ;; 02:5a1f $20 $62
    call call_02_5a75_EntityAction_TVButton_unk3                                  ;; 02:5a21 $cd $75 $5a
    ld   A, [wDC7B_Player_EntityStoodOnLo]                                    ;; 02:5a24 $fa $7b $dc
    ld   HL, wDA00_CurrentEntityAddrLo                                     ;; 02:5a27 $21 $00 $da
    cp   A, [HL]                                       ;; 02:5a2a $be
    ret  NZ                                            ;; 02:5a2b $c0
    ld   A, $02                                        ;; 02:5a2c $3e $02
    call call_02_72ac_Entity_SetAction                                  ;; 02:5a2e $cd $ac $72
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:5a31 $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                                        ;; 02:5a34 $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON                                        ;; 02:5a36 $3e $2c
    jr   Z, .jr_02_5a45                                ;; 02:5a38 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:5a3a $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                                        ;; 02:5a3d $fe $08
    ld   A, PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON                                        ;; 02:5a3f $3e $39
    jr   Z, .jr_02_5a45                                ;; 02:5a41 $28 $02
    ld   A, PLAYERACTION_STAND_ON_TV_BUTTON                                        ;; 02:5a43 $3e $0c
.jr_02_5a45:
    call call_02_54f9_Player_RequestAction                                  ;; 02:5a45 $cd $f9 $54
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 02:5a48 $cd $0f $23
    ld   A, [wDC1E_CurrentLevelID]                                    ;; 02:5a4b $fa $1e $dc
    and  A, A                                          ;; 02:5a4e $a7
    jr   Z, .jr_02_5a6a_InGexCave                                ;; 02:5a4f $28 $19
    push BC                                            ;; 02:5a51 $c5
    ld   B, $00                                        ;; 02:5a52 $06 $00
    ld   HL, .data_02_5a71                             ;; 02:5a54 $21 $71 $5a
    add  HL, BC                                        ;; 02:5a57 $09
    ld   C, [HL]                                       ;; 02:5a58 $4e
    ld   HL, wDC1E_CurrentLevelID                                     ;; 02:5a59 $21 $1e $dc
    ld   L, [HL]                                       ;; 02:5a5c $6e
    ld   H, $00                                        ;; 02:5a5d $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 02:5a5f $11 $5c $dc
    add  HL, DE                                        ;; 02:5a62 $19
    ld   A, [HL]                                       ;; 02:5a63 $7e
    or   A, C                                          ;; 02:5a64 $b1
    ld   [HL], A                                       ;; 02:5a65 $77
    pop  BC                                            ;; 02:5a66 $c1
    jp   call_00_2260_Entity_MarkRemoteCollected                                    ;; 02:5a67 $c3 $60 $22
.jr_02_5a6a_InGexCave:
    ld   HL, wDC5B_LevelIdFromTVButton                                     ;; 02:5a6a $21 $5b $dc
    ld   [HL], C                                       ;; 02:5a6d $71
    jp   call_00_2260_Entity_MarkRemoteCollected                                    ;; 02:5a6e $c3 $60 $22
.data_02_5a71:
    db   $00, $01, $02, $04                            ;; 02:5a71 ????

call_02_5a75_EntityAction_TVButton_unk3:
    ld   HL, .data_02_5a7b                             ;; 02:5a75 $21 $7b $5a
    jp   call_00_2c20_Entity_CopyPaletteToBuffer                                  ;; 02:5a78 $c3 $20 $2c
.data_02_5a7b:
    db   $00, $00, $00, $00, $73, $4e, $e0, $03        ;; 02:5a7b ........

call_02_5a83_EntityAction_TVButton_unk4:
    ld   A, [wDC1E_CurrentLevelID]                                    ;; 02:5a83 $fa $1e $dc
    and  A, A                                          ;; 02:5a86 $a7
    ret  NZ                                            ;; 02:5a87 $c0
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 02:5a88 $cd $0f $23
    ld   B, $00                                        ;; 02:5a8b $06 $00
    ld   HL, data_00_0b19_TvUnlockRequirements                                      ;; 02:5a8d $21 $19 $0b
    add  HL, BC                                        ;; 02:5a90 $09
    bit  7, [HL]                                       ;; 02:5a91 $cb $7e
    jr   Z, .jr_02_5aaa                                ;; 02:5a93 $28 $15
    push HL                                            ;; 02:5a95 $e5
    farcall call_01_4ae7_CountLevelsWithBonusCoin
    pop  HL                                            ;; 02:5aa1 $e1
    ld   C, [HL]                                       ;; 02:5aa2 $4e
    res  7, C                                          ;; 02:5aa3 $cb $b9
    cp   A, C                                          ;; 02:5aa5 $b9
    jr   C, .jr_02_5aba                                ;; 02:5aa6 $38 $12
    jr   .jr_02_5aca                                   ;; 02:5aa8 $18 $20
.jr_02_5aaa:
    push HL                                            ;; 02:5aaa $e5
    farcall call_01_4ab9_CountAllCollectedObjectives
    pop  HL                                            ;; 02:5ab6 $e1
    cp   A, [HL]                                       ;; 02:5ab7 $be
    jr   NC, .jr_02_5aca                               ;; 02:5ab8 $30 $10
.jr_02_5aba:
    call call_00_2962_Entity_GetActionId                                  ;; 02:5aba $cd $62 $29
    cp   A, $00                                        ;; 02:5abd $fe $00
    ret  Z                                             ;; 02:5abf $c8
    ld   C, $00                                        ;; 02:5ac0 $0e $00
    call call_00_2299_Entity_SetListState                                  ;; 02:5ac2 $cd $99 $22
    ld   A, $00                                        ;; 02:5ac5 $3e $00
    jp   call_02_72ac_Entity_SetAction                                  ;; 02:5ac7 $c3 $ac $72
.jr_02_5aca:
    call call_00_2962_Entity_GetActionId                                  ;; 02:5aca $cd $62 $29
    cp   A, $01                                        ;; 02:5acd $fe $01
    ret  Z                                             ;; 02:5acf $c8
    ld   C, $01                                        ;; 02:5ad0 $0e $01
    call call_00_2299_Entity_SetListState                                  ;; 02:5ad2 $cd $99 $22
    ld   A, $01                                        ;; 02:5ad5 $3e $01
    jp   call_02_72ac_Entity_SetAction                                  ;; 02:5ad7 $c3 $ac $72

call_02_5ada_EntityAction_TVRemote_unk:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:5ada $cd $f5 $29
    jr   NZ, call_02_5af8_EntityAction_TVRemote_unk4                                ;; 02:5add $20 $19
    ld   C, $00                                        ;; 02:5adf $0e $00
    jp   call_00_22b1_Entity_SetListStateAndAction                                  ;; 02:5ae1 $c3 $b1 $22

call_02_5ae4_EntityAction_TVRemote_unk2:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:5ae4 $cd $f5 $29
    jr   NZ, call_02_5af8_EntityAction_TVRemote_unk4                                ;; 02:5ae7 $20 $0f
    ld   C, $01                                        ;; 02:5ae9 $0e $01
    jp   call_00_22b1_Entity_SetListStateAndAction         

call_02_5aee_EntityAction_TVRemote_unk3:    ;; 02:5aeb $c3 $b1 $22
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   nz,call_02_5af8_EntityAction_TVRemote_unk4
    ld   c,$02
    jp   call_00_22b1_Entity_SetListStateAndAction

call_02_5af8_EntityAction_TVRemote_unk4:
    ld   A, [wDC1E_CurrentLevelID]                                    ;; 02:5af8 $fa $1e $dc
    and  A, A                                          ;; 02:5afb $a7
    ret  NZ                                            ;; 02:5afc $c0
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 02:5afd $cd $0f $23
    ld   B, $00                                        ;; 02:5b00 $06 $00
    ld   HL, data_00_0b19_TvUnlockRequirements                                      ;; 02:5b02 $21 $19 $0b
    add  HL, BC                                        ;; 02:5b05 $09
    bit  7, [HL]                                       ;; 02:5b06 $cb $7e
    jr   Z, .jr_02_5b1f                                ;; 02:5b08 $28 $15
    push HL                                            ;; 02:5b0a $e5
    farcall call_01_4ae7_CountLevelsWithBonusCoin
    pop  HL                                            ;; 02:5b16 $e1
    ld   C, [HL]                                       ;; 02:5b17 $4e
    res  7, C                                          ;; 02:5b18 $cb $b9
    cp   A, C                                          ;; 02:5b1a $b9
    jr   C, .jr_02_5b2f                                ;; 02:5b1b $38 $12
    jr   .jr_02_5b6e                                   ;; 02:5b1d $18 $4f
.jr_02_5b1f:
    push HL                                            ;; 02:5b1f $e5
    farcall call_01_4ab9_CountAllCollectedObjectives
    pop  HL                                            ;; 02:5b2b $e1
    cp   A, [HL]                                       ;; 02:5b2c $be
    jr   NC, .jr_02_5b6e                               ;; 02:5b2d $30 $3f
.jr_02_5b2f:
    call call_00_2962_Entity_GetActionId                                  ;; 02:5b2f $cd $62 $29
    cp   A, $03                                        ;; 02:5b32 $fe $03
    jr   Z, .jr_02_5b40                                ;; 02:5b34 $28 $0a
    ld   C, $03                                        ;; 02:5b36 $0e $03
    call call_00_2299_Entity_SetListState                                  ;; 02:5b38 $cd $99 $22
    ld   A, $03                                        ;; 02:5b3b $3e $03
    call call_02_72ac_Entity_SetAction                                  ;; 02:5b3d $cd $ac $72
.jr_02_5b40:
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 02:5b40 $cd $0f $23
    ld   B, $00                                        ;; 02:5b43 $06 $00
    ld   HL, .data_02_5b7e                             ;; 02:5b45 $21 $7e $5b
    add  HL, BC                                        ;; 02:5b48 $09
    ld   C, [HL]                                       ;; 02:5b49 $4e
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_SPRITE_ID
    ld   A, C                                          ;; 02:5b52 $79
    add  A, $40                                        ;; 02:5b53 $c6 $40
    cp   A, [HL]                                       ;; 02:5b55 $be
    ld   [HL], A                                       ;; 02:5b56 $77
    jr   Z, .jr_02_5b5f                                ;; 02:5b57 $28 $06
    ld   A, L                                          ;; 02:5b59 $7d
    xor  A, $0f                                        ;; 02:5b5a $ee $0f
    ld   L, A                                          ;; 02:5b5c $6f
    set  1, [HL]                                       ;; 02:5b5d $cb $ce
.jr_02_5b5f:
    ld   HL, .data_02_5b8a                             ;; 02:5b5f $21 $8a $5b
    ld   A, C                                          ;; 02:5b62 $79
    cp   A, $09                                        ;; 02:5b63 $fe $09
    jp   C, call_00_2c20_Entity_CopyPaletteToBuffer                               ;; 02:5b65 $da $20 $2c
    ld   HL, .data_02_5b92                             ;; 02:5b68 $21 $92 $5b
    jp   call_00_2c20_Entity_CopyPaletteToBuffer                                  ;; 02:5b6b $c3 $20 $2c
.jr_02_5b6e:
    call call_00_2962_Entity_GetActionId                                  ;; 02:5b6e $cd $62 $29
    cp   A, $01                                        ;; 02:5b71 $fe $01
    ret  Z                                             ;; 02:5b73 $c8
    ld   C, $01                                        ;; 02:5b74 $0e $01
    call call_00_2299_Entity_SetListState                                  ;; 02:5b76 $cd $99 $22
    ld   A, $01                                        ;; 02:5b79 $3e $01
    jp   call_02_72ac_Entity_SetAction                                  ;; 02:5b7b $c3 $ac $72
.data_02_5b7e:
    db   $00, $00, $01, $02, $03, $05, $07, $09        ;; 02:5b7e ?.......
    db   $0a, $04, $06, $08                            ;; 02:5b86 ....
.data_02_5b8a:
    db   $00, $00, $00, $00, $ff, $7f, $1f, $00        ;; 02:5b8a ........
.data_02_5b92:
    db   $00, $00, $00, $00, $1f, $00, $ff, $03        ;; 02:5b92 ........

call_02_5b9a_EntityAction_UpdateGoalCounter:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:5b9a $cd $f5 $29
    jr   Z, .jr_02_5ba9                                ;; 02:5b9d $28 $0a
    ld   C, $30                                        ;; 02:5b9f $0e $30
    call call_00_28dc_Entity_SetYVelocity                                  ;; 02:5ba1 $cd $dc $28
    ld   C, TIMER_AMOUNT_60_FRAMES                                        ;; 02:5ba4 $0e $3c
    call call_00_290d_Entity_SetMiscTimer                                  ;; 02:5ba6 $cd $0d $29
.jr_02_5ba9:
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped                                  ;; 02:5ba9 $cd $4a $24
    call call_00_2922_Entity_DecrementMiscTimer                                  ;; 02:5bac $cd $22 $29
    jp   Z, call_00_2b80_Entity_DeactivateSelf                               ;; 02:5baf $ca $80 $2b
    ret                                                ;; 02:5bb2 $c9

call_02_5bb3_EntityAction_UpdateBonusStageTimer:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,[wDBF9_XPositionInMap]
    add  a,$50
    ldi  [hl],a
    ld   a,[wDBF9_XPositionInMap+1]
    adc  a,$00
    ldi  [hl],a
    ld   a,[wDBFB_YPositionInMap]
    add  a,$08
    ldi  [hl],a
    ld   a,[wDBFB_YPositionInMap+1]
    adc  a,$00
    ld   [hl],a
    ret  

call_02_5bd4_EntityAction_FreestandingRemote_unk0:
    ld   A, [wDC1E_CurrentLevelID]                                    ;; 02:5bd4 $fa $1e $dc
    and  A, A                                          ;; 02:5bd7 $a7
    jr   Z, .jr_02_5be4                                ;; 02:5bd8 $28 $0a
    ld   A, [wDCD2_FreestandingRemoteHitFlags]                                    ;; 02:5bda $fa $d2 $dc
    and  A, A                                          ;; 02:5bdd $a7
    ld   A, $01                                        ;; 02:5bde $3e $01
    jp   NZ, call_02_72ac_Entity_SetAction                              ;; 02:5be0 $c2 $ac $72
    ret                                                ;; 02:5be3 $c9
.jr_02_5be4:
    ld   HL, wDC5C_ProgressFlags                                     ;; 02:5be4 $21 $5c $dc
    bit  0, [HL]                                       ;; 02:5be7 $cb $46
    ld   A, $01                                        ;; 02:5be9 $3e $01
    jp   Z, call_02_72ac_Entity_SetAction                               ;; 02:5beb $ca $ac $72
    ret                                                ;; 02:5bee $c9

call_02_5bef_EntityAction_FreestandingRemote_unk1:
    ld   A, [wDCD2_FreestandingRemoteHitFlags]                                    ;; 02:5bef $fa $d2 $dc
    cp   A, $81                                        ;; 02:5bf2 $fe $81
    ld   A, $02                                        ;; 02:5bf4 $3e $02
    jp   Z, call_02_72ac_Entity_SetAction                               ;; 02:5bf6 $ca $ac $72
    ret                                                ;; 02:5bf9 $c9

call_02_5bfa_EntityAction_FreestandingRemote_unk2:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear                                  ;; 02:5bfa $cd $f5 $29
    jr   Z, .jr_02_5c23                                ;; 02:5bfd $28 $24
    ld   A, SFX_REMOTE                                        ;; 02:5bff $3e $1e
    call call_00_0ff5_QueueSFX                                  ;; 02:5c01 $cd $f5 $0f
    ld   HL, .data_02_5c3b                             ;; 02:5c04 $21 $3b $5c
    call call_00_2c20_Entity_CopyPaletteToBuffer                                  ;; 02:5c07 $cd $20 $2c
    call call_00_288a_Entity_SetCollisionTypeNone                                  ;; 02:5c0a $cd $8a $28
    call call_00_2b8b_Entity_MarkDefeated                                  ;; 02:5c0d $cd $8b $2b
    call call_00_2c67_Particle_InitBurst                                  ;; 02:5c10 $cd $67 $2c
    ld   C, TIMER_AMOUNT_60_FRAMES                                        ;; 02:5c13 $0e $3c
    call call_00_290d_Entity_SetMiscTimer                                  ;; 02:5c15 $cd $0d $29
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 02:5c18 $cd $0f $23
    ld   B, $00                                        ;; 02:5c1b $06 $00
    ld   HL, wDC5C_ProgressFlags                                     ;; 02:5c1d $21 $5c $dc
    add  HL, BC                                        ;; 02:5c20 $09
    set  0, [HL]                                       ;; 02:5c21 $cb $c6
.jr_02_5c23:
    call call_00_2c89_Particle_UpdateBurst                                  ;; 02:5c23 $cd $89 $2c
    ret  NZ                                            ;; 02:5c26 $c0
    call call_00_2922_Entity_DecrementMiscTimer                                  ;; 02:5c27 $cd $22 $29
    ret  NZ                                            ;; 02:5c2a $c0
    call call_00_230f_Entity_GetParameterIntoC                                  ;; 02:5c2b $cd $0f $23
    inc  C                                             ;; 02:5c2e $0c
    dec  C                                             ;; 02:5c2f $0d
    jp   Z, call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn                                 ;; 02:5c30 $ca $7a $2b
    ld   HL, wDB6A_WarpFlags                                     ;; 02:5c33 $21 $6a $db
    set  4, [HL]                                       ;; 02:5c36 $cb $e6
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn                                    ;; 02:5c38 $c3 $7a $2b
.data_02_5c3b:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f        ;; 02:5c3b ........

; ==================================================================
; HOLIDAY TV
;
; Five entity types, and between them they cover most of the shapes the rest of
; this file repeats: a piece of scenery whose whole life is in its collision
; handler (the ice sculpture), a boss with its own health byte in WRAM (Evil
; Santa), a projectile that Gex is meant to hit back (the snowball), an enemy
; whose health outlives it (the skating elf) and an ordinary two-action hopper
; (the penguin).
;
; ENTITY_HOLIDAY_TV_ICE_SCULPTURE has no code at all. Its three rows are all
; call_02_582e_EntityAction_None with three different single-frame blocks - intact,
; cracked, shattered - and call_03_4e4b_CollisionHandler_IceSculpture steps it
; through them, using the action id as the list state so a half-broken sculpture
; stays half-broken across a revisit
; ==================================================================

; ------------------------------------------------------------------
; EVIL SANTA - the Holiday TV boss, and the only entity in this level with a
; health value of his own.
;
; His COLLISION_TYPE is NONE, so he cannot be touched or whipped at all. The only
; thing that hurts him is his own snowball coming back: Gex whips it, and
; call_02_5d80_EntityAction_EvilSantaProjectile_UpdateTrajectory raises
; wDCDB_EvilSantaHitByProjectileFlag when the returning snowball climbs high
; enough. Action $04 is the only place that flag is read.
;
; The loop is
;
;   $00 Init         set health, load the palette, fall straight through to $01
;   $01 Jumping      hop across, turn round on landing, go to $02
;   $02 PrepareThrow wind up, spawn the snowball, go to $03
;   $03 -            the follow-through pose. No code: data_02_76d9 carries
;                    pending action $04, so the animation hands off by itself
;   $04 Stand        wait. Take the hit if there is one, otherwise jump again as
;                    soon as the snowball is gone
;   $05 Damaged      flash, and data_02_76e5's pending action $01 puts him back
;                    into the jump
;   $06 Death        launch backwards and expire
;
; Health starts at three, so it is three returned snowballs
; ------------------------------------------------------------------

call_02_5c43_EntityAction_EvilSanta_Init:
; Action $00. Runs for a single frame - the last thing it does is switch to $01
    ld   A, $03
    ld   [wDCC4_EvilSantaHealth], A
    call call_02_5d02_LoadEvilSantaPalette
    ld   A, $01
    jp   call_02_72ac_Entity_SetAction                 ; -> Jumping

call_02_5c50_EntityAction_EvilSanta_Jumping:
; Action $01. One hop: $20 forward, $28 up, and the floor is his spawn Y
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   Z, .jr_02_5c62
    call call_02_5d02_LoadEvilSantaPalette             ; undo the damage flash
    ld   C, $20
    call call_00_28c8_Entity_SetXVelocity
    ld   C, $28
    call call_00_28dc_Entity_SetYVelocity
.jr_02_5c62:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ret  C                                             ; still airborne
    call call_00_299f_Entity_TurnAround                ; landed - face the other way
    ld   A, $02
    jp   call_02_72ac_Entity_SetAction                 ; -> PrepareThrow

call_02_5c74_EntityAction_EvilSanta_PrepareThrow:
; Action $02. The ten-frame wind-up in data_02_76ca. The snowball is spawned on the
; frame the animation wraps, not at the start of it
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  Z
    ld   C, SPAWN_CHILD_ENTITY_EVIL_SANTA_PROJECTILE
    call call_00_3792_EntitySpawn_SpawnChild
    ld   A, $03
    jp   call_02_72ac_Entity_SetAction                 ; -> the throw pose

call_02_5c82_EntityAction_EvilSanta_Stand:
; Action $04, reached from action $03's pending action. Santa is idle here and this
; is where both of his decisions are made.
;
; Entity_FindDuplicateInstance is being used as "is my snowball still in the air?"
; - it looks for a loaded ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE belonging to the
; same entity-list entry, and Z means there is none, so he only throws again once
; the last one has gone
    ld   A, [wDCDB_EvilSantaHitByProjectileFlag]
    and  A, A
    jr   NZ, .jr_02_5c93                               ; the snowball came back
    ld   C, ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    call call_00_2b10_Entity_FindDuplicateInstance
    ld   A, $01
    jp   Z, call_02_72ac_Entity_SetAction              ; snowball gone -> Jumping
    ret
.jr_02_5c93:
    xor  A, A
    ld   [wDCDB_EvilSantaHitByProjectileFlag], A       ; consume the hit
    ld   HL, wDCC4_EvilSantaHealth
    dec  [HL]
    ld   A, $05
    jp   NZ, call_02_72ac_Entity_SetAction             ; -> Damaged
    ld   A, $06
    jp   call_02_72ac_Entity_SetAction                 ; out of health -> Death

call_02_5ca5_EntityAction_EvilSanta_Damaged:
; Action $05. Alternates between two palettes on a 16-frame cycle - 12 frames of
; one, 4 of the other - so the flash is not symmetric. It never leaves this action
; itself: data_02_76e5 carries pending action $01, and the eight-frame animation
; is what times the flash
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   a,SFX_SMALL_BANG
    call nz,call_00_0ff5_QueueSFX
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$0F
    cp   a,$0C
    ld   hl,.data_02_5cc8_EvilSantaDamagedPalette2
    jp   c,call_00_2c20_Entity_CopyPaletteToBuffer
    ld   hl,.data_02_5cc0_EvilSantaDamagedPalette1
    jp   call_00_2c20_Entity_CopyPaletteToBuffer
.data_02_5cc0_EvilSantaDamagedPalette1:
; Flat red on black - the same palette as the normal one below, which is why the
; flash reads as a colour dropping out rather than a colour appearing
    db   $00, $00, $00, $00, $1f, $00, $ff, $7f
.data_02_5cc8_EvilSantaDamagedPalette2:
    db   $00, $00, $84, $10, $08, $21, $8c, $31

call_02_5cd0_EntityAction_EvilSanta_Death:
; Action $06. Thrown backwards - $F2 (-14) when facing left, $0E when facing right
; - and $05 upwards, with no floor check, so he simply drifts off. The animation
; ending is what ends him.
;
; Entity_PlayRemoteSFX does two jobs despite the name: it plays the fanfare AND
; marks tv button 3 as pressed, which is what opens the level's exit
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_5CF0
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSFX
    call call_02_5d02_LoadEvilSantaPalette
    call call_00_2976_Entity_GetFacingDirection
    ld   c,$F2
    bit  5,a                                           ; ENTITY_FACING_LEFT_BIT
    jr   nz,.jr_00_5CE8
    ld   c,$0E
.jr_00_5CE8:
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$05
    call call_00_28dc_Entity_SetYVelocity
.jr_00_5CF0:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_24ee_Entity_ApplyYVelocity_Subpixel
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    ld   c,$03
    call call_00_21ef_Entity_PlayRemoteSFX
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

call_02_5d02_LoadEvilSantaPalette:
; Santa's normal palette. Called from Init, from the top of every jump and from the
; death, all three of which can follow a damage flash
    ld   HL, .data_02_5d08_EvilSantaPalette
    jp   call_00_2c20_Entity_CopyPaletteToBuffer
.data_02_5d08_EvilSantaPalette:
    db   $00, $00, $00, $00, $1f, $00, $ff, $7f

; ------------------------------------------------------------------
; THE SNOWBALL. Seven rows, and only three of them are code - the four rows in the
; middle are the same UpdateTrajectory function with four different single-frame
; sprites, which is how the snowball appears to rotate as it arcs.
;
; The height it is at picks the sprite, and which direction it is travelling picks
; which set of thresholds is used, so it shows one set of frames on the way up and
; the reverse on the way down.
;
; The interesting part is that this routine is also Santa's damage detector. Gex
; whips the snowball, call_03_4e89_CollisionHandler_EvilSantaProjectile negates its
; Y velocity and gives it an X velocity chosen by how far Santa is standing away,
; and the snowball comes back. When it climbs past Y $25 - higher than any of the
; sprite thresholds - the routine sets wDCDB_EvilSantaHitByProjectileFlag and puts
; the snowball into its burst. Nothing else raises that flag
; ------------------------------------------------------------------

call_02_5d10_EntityAction_EvilSantaProjectile_Init:
; Action $00. Aims the throw. Takes the 16-bit gap to Gex, keeps the sign on the
; stack, takes the absolute value, clamps it to $A0 and divides by four to index
; .data_02_5d57 - so the throw is faster the further away Gex is standing, and the
; snowball lands near him rather than always at a fixed distance
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   A, [wD80E_PlayerXPosition]
    sub  A, [HL]
    ld   E, A
    inc  HL
    ld   A, [wD80E_PlayerXPosition+1]
    sbc  A, [HL]
    ld   D, A
    push AF                                            ; keep the sign of the gap
    jr   NC, .jr_02_5d2d
    xor  A, A
    sub  A, E
    ld   E, A
    ld   A, $00
    sbc  A, D
    ld   D, A                                          ; DE = |PlayerX - X|
.jr_02_5d2d:
    ld   A, D
    and  A, A
    jr   NZ, .jr_02_5d36
    ld   A, E
    cp   A, $a0
    jr   C, .jr_02_5d38
.jr_02_5d36:
    ld   A, $a0                                        ; saturate
.jr_02_5d38:
    srl  A
    srl  A                                             ; distance / 4
    ld   L, A
    ld   H, $00
    ld   DE, .data_02_5d57
    add  HL, DE
    pop  AF
    ld   A, [HL]
    jr   NC, .jr_02_5d49
    cpl
    inc  A                                             ; Gex is to the left - negate
.jr_02_5d49:
    ld   C, A
    call call_00_28c8_Entity_SetXVelocity
    ld   C, $10
    call call_00_28dc_Entity_SetYVelocity
    ld   A, $01
    jp   call_02_72ac_Entity_SetAction                 ; -> the arc
.data_02_5d57:
; Throw speed by distance, indexed by (clamped gap) >> 2. Forty-one entries, which
; covers the whole $00-$A0 range. Almost the identity - it climbs by one per step
; and skips a value every twelfth entry.
;
; call_03_4e89_CollisionHandler_EvilSantaProjectile has its own copy of this table
; at .data_03_4efa for the return throw
    db   $00, $01, $02, $03, $04, $05, $06, $07
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10
    db   $11, $12, $13, $14, $15, $16, $17, $18
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21
    db   $22, $23, $24, $25, $27, $28, $29, $2a
    db   $2b

call_02_5d80_EntityAction_EvilSantaProjectile_UpdateTrajectory:
; Actions $01 through $04, all four rows. Moves the snowball, then decides which of
; the four it should be showing and switches only if that is not the one it is
; already in - so a frame where nothing changed costs one compare.
;
; Y is measured relative to $25, and the two branches use thresholds one apart
; ($09/$1D/$3B rising, $0A/$1E/$3C falling) so the same physical height does not
; flip the sprite twice. Reaching Y $88 is the ground and frees the slot; climbing
; above $25 - only possible once Gex has whipped it back - is the hit on Santa
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_24ee_Entity_ApplyYVelocity_Subpixel
    call call_00_28d2_Entity_GetYVelocity
    ld   C, A
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ld   A, [HL]
    sub  A, $88
    jp   NC, call_00_2b80_Entity_DeactivateSelf        ; hit the ground
    bit  7, C
    jr   Z, .jr_02_5db5                                ; falling
    ld   C, $01
    ld   A, [HL]
    sub  A, $25
    jr   C, .jr_02_5dcd                               ; above Santa's head - a hit
    cp   A, $09
    jr   Z, .jr_02_5dc9
    ld   C, $02
    cp   A, $1d
    jr   Z, .jr_02_5dc9
    ld   C, $03
    cp   A, $3b
    ret  NZ
    jr   Z, .jr_02_5dc9
    ret                                                ; unreachable
.jr_02_5db5:
    ld   C, $02
    ld   A, [HL]
    sub  A, $25
    cp   A, $0a
    jr   Z, .jr_02_5dc9
    ld   C, $03
    cp   A, $1e
    jr   Z, .jr_02_5dc9
    cp   A, $3c
    ret  NZ
    ld   C, $04
.jr_02_5dc9:
    ld   A, C
    jp   call_02_72ac_Entity_SetAction                 ; swap the sprite
.jr_02_5dcd:
    ld   A, $01
    ld   [wDCDB_EvilSantaHitByProjectileFlag], A       ; Santa reads this in action $04
    ld   A, $05
    jp   call_02_72ac_Entity_SetAction                 ; -> burst

call_02_5dd7_EntityAction_EvilSantaProjectile_Destroy:
; Actions $05 and $06, the two three-frame bursts. $05 is the one the hit above
; asks for; $06 is where call_03_4e89_CollisionHandler_EvilSantaProjectile puts a
; snowball that touched Gex
    call call_00_2a5d_Entity_CheckAnimationEnded
    jp   NZ, call_00_2b80_Entity_DeactivateSelf
    ret

; ------------------------------------------------------------------
; THE SKATING ELF, five of them per level, and the one enemy here whose health is
; not in its own slot.
;
; call_03_4f23_CollisionHandler_HolidayTV_Elf keeps it in wDCD5_ElfHealth1 and the
; four bytes after, indexed by the elf's spawn parameter, so an elf that has been
; hit once stays hit once even after it scrolls off and respawns. The elf's own
; ENTITY_ATTR_DAMAGE_STATE is $00, which the spawn turns into $FF - invulnerable -
; which is what keeps HandleEntityHit out of it entirely.
;
; Actions $00 and $01 are the same Skate function with two data blocks whose
; pending actions point at each other, so the skating animation runs as one long
; loop across both rows
; ------------------------------------------------------------------

call_02_5dde_EntityAction_SkatingElf_Skate:
; Actions $00 and $01. Kicks off at $20 and coasts down toward $10 one unit every
; eighth frame. Charges when Gex is inside its bounds, it is already facing him and
; he is within $40
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   C, $20
    call NZ, call_00_28c8_Entity_SetXVelocity
    ld   A, [wDC71_VBlankFrameCounter]
    and  A, $07
    ld   C, $10
    call Z, call_00_2588_Entity_NudgeXVelocityTowardC  ; one unit per 8 frames
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2722_Entity_IsPlayerInsideBounds
    ret  Z
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   HL, wDA12_EntityDirectionRelativeToPlayer
    cp   A, [HL]
    ret  NZ                                            ; facing the other way
    ld   A, [wDA11_EntityXDistFromPlayer]
    cp   A, $40
    ld   A, $02
    jp   C, call_02_72ac_Entity_SetAction              ; -> PrepareJump
    ret

call_02_5e0d_EntityAction_SkatingElf_PrepareJump:
; Action $02. Arms the jump and then waits for the acceleration to finish: the
; nudge adds one to XVEL per frame and the action only changes on the frame XVEL
; actually reaches $28, so the wind-up is as long as the speed-up needs to be
    ld   C, $20
    call call_00_28dc_Entity_SetYVelocity
    ld   C, $28
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_28be_Entity_GetXVelocity
    cp   A, $28
    ld   A, $03
    jp   Z, call_02_72ac_Entity_SetAction              ; at full speed -> Jump
    ret

call_02_5e25_EntityAction_SkatingElf_Jump:
; Action $03. Carry clear from the floor clamp is the landing
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   A, $00
    jp   NC, call_02_72ac_Entity_SetAction             ; -> Skate
    ret

call_02_5e34_EntityAction_SkatingElf_Damaged:
; Action $04, set by the collision handler on every hit whether or not it was the
; last one. The elf slides to a stop and only then finds out whether it is dead.
;
; ENTITY_FIELD_MISC_FLAGS is being used as a one-bit "am I on the ground yet",
; because the elf can be hit mid-jump: zero means still airborne and the second
; half of the routine runs the fall, one means grounded and the first half runs the
; skid. The skid ends when MoveXByFacingMomentum_BoundsChecked reports a turn -
; that is, when it reaches the end of its patrol - and that is where the shared
; health byte is finally read
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   Z, .jr_02_5e45
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   C, $00                                        ; still in the air
    jr   C, .jr_02_5e42
    ld   C, $01                                        ; hit while on the ground
.jr_02_5e42:
    call call_00_2980_Entity_SetMiscFlags
.jr_02_5e45:
    call call_00_298a_Entity_GetMiscFlags
    jr   Z, .jr_02_5e6d                                ; airborne - fall first
    ld   A, [wDC71_VBlankFrameCounter]
    and  A, $07
    ld   C, $10
    call Z, call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ret  Z                                             ; still sliding
    call call_00_230f_Entity_GetParameterIntoC         ; which of the five elves
    ld   B, $00
    ld   HL, wDCD5_ElfHealth1
    add  HL, BC
    ld   A, [HL]
    and  A, A
    ld   A, $00
    jp   NZ, call_02_72ac_Entity_SetAction             ; still alive -> Skate
    ld   A, $05
    jp   call_02_72ac_Entity_SetAction                 ; -> Destroy
.jr_02_5e6d:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   C, $01
    call NC, call_00_2980_Entity_SetMiscFlags          ; landed - start skidding
    ret

; ------------------------------------------------------------------
; THE PENGUIN, and the only enemy in the level that runs away.
;
; Action $00 does both halves of that. Beyond $30 it ambles at speed $04 in
; whatever direction it was already going; inside $30 it turns to face AWAY from
; Gex - the `xor $20` on the direction-relative-to-player - and bolts at $1E.
;
; It jumps for one of two reasons, and they are the same jump. Either the run took
; it into the end of its patrol, which MoveXByFacingMomentum_BoundsChecked reports
; as NZ, or Gex closed to within $18, in which case it first turns back TOWARD him
; so the hop carries it over his head
;
; Action $02 is a two-frame block nothing ever selects: the penguin's
; ENTITY_ATTR_DEFEAT_FLAGS are $C3, so a defeated one goes to action $03
; ------------------------------------------------------------------

call_02_5e7c_EntityAction_Penguin_WalkOrRun:
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   A, [wDA11_EntityXDistFromPlayer]
    cp   A, $30
    jr   C, .jr_02_5e8e
    ld   C, $04
    call call_00_2588_Entity_NudgeXVelocityTowardC     ; far away - amble
    jp   call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
.jr_02_5e8e:
    ld   A, [wDA12_EntityDirectionRelativeToPlayer]
    xor  A, $20                                        ; face away from Gex
    ld   C, A
    call call_00_2958_Entity_SetFacingDirection
    ld   C, $1e
    call call_00_2588_Entity_NudgeXVelocityTowardC     ; and run
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    jr   NZ, .jr_02_5eae                               ; cornered - jump
    ld   A, [wDA11_EntityXDistFromPlayer]
    cp   A, $18
    ret  NC                                            ; still has room to run
    ld   HL, wDA12_EntityDirectionRelativeToPlayer
    ld   C, [HL]
    call call_00_2958_Entity_SetFacingDirection        ; turn back and jump over him
.jr_02_5eae:
    ld   C, $30
    call call_00_28dc_Entity_SetYVelocity
    ld   A, ENTITYACTION_PENGUIN_JUMP
    jp   call_02_72ac_Entity_SetAction

call_02_5eb8_EntityAction_Penguin_Jump:
    ld   C, $10
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   A, ENTITYACTION_PENGUIN_WALK_OR_RUN
    jp   NC, call_02_72ac_Entity_SetAction             ; landed
    ret


; ==================================================================
; MYSTERY TV
;
; Seven entity types. Three of them - the blood cooler, the magic sword and the
; rezling's death - are entirely animation: their rows are
; call_02_582e_EntityAction_None and the data blocks' pending actions do the
; sequencing, so the only code in this level belongs to the fish, Safari Sam and
; the ghost knight.
;
; ENTITY_MYSTERY_TV_BLOOD_COOLER is two rows, intact and broken, stepped by
; call_03_4f60_CollisionHandler_BloodCooler. ENTITY_MYSTERY_TV_MAGIC_SWORD is two
; idle blocks whose pending actions point at each other - an eight-frame shimmer
; followed by 120 frames of stillness, looping - plus a Destroy row that
; ENTITY_ATTR_DEFEAT_FLAGS $C2 selects when Gex takes it
; ==================================================================

; ------------------------------------------------------------------
; THE REZLING walks straight at Gex and never turns round on its own - it uses
; Entity_FaceTowardsPlayer and Entity_MoveXByFacingSpeed rather than the
; patrol-and-turn helper every other enemy here uses, and only
; Entity_ClampXToBounds keeps it inside its span.
;
; Its other five rows are all `ret`. Three separate ones, at three consecutive
; addresses, because three table rows point at three different addresses that
; happen to hold the same instruction. Actions $01 and $02 are a hit reaction that
; nothing ever selects; $03 is where ENTITY_ATTR_DEFEAT_FLAGS $C3 sends a defeated
; rezling, and data_02_7796's pending action carries it on to $04 and then $05
; ------------------------------------------------------------------

call_02_5ecc_EntityAction_Rezling_Walk:
    ld   c,$14
    call call_00_28c8_Entity_SetXVelocity
    call call_00_2410_Entity_FaceTowardsPlayer
    call call_00_254a_Entity_MoveXByFacingSpeed        ; no turn at the bounds
    jp   call_00_2617_Entity_ClampXToBounds

call_02_5eda_EntityAction_Rezling_None:
; Action $01
    ret

call_02_5edb_EntityAction_Rezling_None:
; Action $02
    ret

call_02_5edc_EntityAction_Rezling_None:
; Action $03 - the death, handed straight to the animation
    ret

; ------------------------------------------------------------------
; THE FISH is COLLISION_TYPE_INVULNERABLE_ENEMY, so it cannot be killed at all -
; it can only be avoided. Two actions, and the second one is a burst of speed
; rather than a different behaviour: both call the same nudge-and-pace pair, one
; toward $08 and one toward $20.
;
; It only lunges when Gex is inside its bounds AND it is already facing him, so it
; will not turn to start a charge - it has to be swum into. data_02_77c5 carries
; pending action $00, so the lunge lasts the 30 frames of its own block and then
; drops back to the cruise
; ------------------------------------------------------------------

call_02_5edd_EntityAction_Fish_Cruise:
    call call_00_2722_Entity_IsPlayerInsideBounds
    jr   z,.jr_00_5EF1
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction               ; facing him -> Lunge
.jr_00_5EF1:
    ld   c,$08
    call call_00_2588_Entity_NudgeXVelocityTowardC
    jp   call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked

call_02_5ef9_EntityAction_Fish_Lunge:
    ld   c,$20
    call call_00_2588_Entity_NudgeXVelocityTowardC
    jp   call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked

; ------------------------------------------------------------------
; SAFARI SAM. Five rows, three of them code:
;
;   $00 Patrol   walk, turn to face Gex if he gets close, count down to a shot
;   $01 -        the raise-rifle pose. No code; data_02_77f0 chains to $02
;   $02 Fire     spawn the bullet on the first frame, and data_02_77fb chains back
;                to $00 when the recoil animation ends
;   $03 Death    a small pop upwards, then data_02_7806 chains to $04 after 60
;                frames
;   $04 Destroy
;
; He will not start a shot while one of his bullets is still on screen, and the
; timer does not even tick while one is - Entity_FindDuplicateInstance returning NZ
; leaves the countdown where it was
; ------------------------------------------------------------------

call_02_5f01_EntityAction_SafariSam_Patrol:
; Action $00. He turns to face Gex only from behind and only within $40: the
; `jr z` skips the turn when he is already facing him, so this reads as "notice
; someone sneaking up"
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,TIMER_AMOUNT_240_FRAMES
    call nz,call_00_290d_Entity_SetMiscTimer
    call call_00_2722_Entity_IsPlayerInsideBounds
    jr   z,.jr_00_5F22
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    jr   z,.jr_00_5F22                                 ; already facing him
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$40
    call c,call_00_2410_Entity_FaceTowardsPlayer       ; close and behind - turn
.jr_00_5F22:
    ld   c,$06
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ld   c,ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    call call_00_2b10_Entity_FindDuplicateInstance
    ret  nz                                            ; a bullet is still in flight
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction               ; -> raise the rifle
    ret

call_02_5f39_EntityAction_SafariSam_Fire:
; Action $02, entered by data_02_77f0's pending action. The bullet leaves on the
; first frame; the rest of the block is the recoil, and its own pending action puts
; him back on patrol
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,SPAWN_CHILD_ENTITY_SAFARI_SAM_PROJECTILE
    call nz,call_00_3792_EntitySpawn_SpawnChild
    ret

call_02_5f42_EntityAction_SafariSam_Death:
; Action $03, where ENTITY_ATTR_DEFEAT_FLAGS $C3 sends him. A single hop back onto
; his own spawn line - there is no horizontal component at all
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$30
    call nz,call_00_28dc_Entity_SetYVelocity
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    jp   call_00_2766_Entity_ClampYToSpawnFloor

call_02_5f50_EntityAction_SafariSamProjectile_Update:
; The bullet's only action. Flies in whatever direction it inherited from Sam and
; expires on the timer rather than on a wall, which is why Sam's own "is one still
; out?" test is what limits his rate of fire
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_5F5F
    ld   c,TIMER_AMOUNT_240_FRAMES
    call call_00_290d_Entity_SetMiscTimer
    ld   c,$0A
    call call_00_28c8_Entity_SetXVelocity
.jr_00_5F5F:
    call call_00_254a_Entity_MoveXByFacingSpeed
    call call_00_2922_Entity_DecrementMiscTimer
    jp   z,call_00_2b80_Entity_DeactivateSelf
    ret

; ------------------------------------------------------------------
; THE GHOST KNIGHT does not move. It appears at one of eight fixed posts, fires a
; fan of shots, vanishes, and reappears at the next one, and both halves of that
; are table-driven.
;
; Two counters in WRAM rather than in the slot, because the knight is despawned and
; respawned between posts:
;
;   wDCD3_GhostKnightDamageCounter1  which post it is at, 0-7
;   wDCD4_GhostKnightDamageCounter2  which of that post's four shots is next
;
; The names date from before the tables were read - neither has anything to do with
; damage. The knight's health is the ordinary ENTITY_FIELD_DAMAGE_STATE, $04, and
; call_03_4f98_CollisionHandler_GhostKnight spends it; ENTITY_ATTR_DEFEAT_FLAGS $85
; is what sends the dead knight to action $05.
;
;   $00 Init      zero both counters, place it at post 0, go to $01
;   $01 Attack    hold for TIMER_AMOUNT_GHOST_KNIGHT frames, dropping a shot every
;                 16th, then go to $02
;   $02 -         the vanish. data_02_7821 chains to $03
;   $03 Relocate  step the post counter and move, then data_02_782a holds for 120
;                 frames and chains to $04
;   $04 -         the reappear. data_02_7830 chains back to $01
;   $05 Destroy
; ------------------------------------------------------------------

call_02_5f69_EntityAction_GhostKnight_Init:
    xor  a
    ld   [wDCD3_GhostKnightDamageCounter1],a           ; post 0
    ld   [wDCD4_GhostKnightDamageCounter2],a           ; first shot of the fan
    call call_02_5f9b_GhostKnight_MoveToPost
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction                 ; -> Attack

call_02_5f78_EntityAction_GhostKnight_Attack:
; Action $01. DecrementMiscTimer leaves HL on the timer field, which is what the
; `ld a,[hl]` reads - so the shot cadence is driven by the low nibble of the same
; countdown that ends the action, one shot every sixteenth frame
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,TIMER_AMOUNT_GHOST_KNIGHT
    call nz,call_00_290d_Entity_SetMiscTimer
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$02
    jp   z,call_02_72ac_Entity_SetAction               ; done -> vanish
    ld   a,[hl]                                        ; HL still on MISC_TIMER
    and  a,$0F
    ld   c,SPAWN_CHILD_ENTITY_GHOST_KNIGHT_PROJECTILE
    jp   z,call_00_3792_EntitySpawn_SpawnChild
    ret

call_02_5f91_EntityAction_GhostKnight_Relocate:
; Action $03. `inc [hl]` then `res 3,[hl]` is the post counter wrapping at eight
; without a compare, and it falls straight into the placement below
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ret  z
    ld   hl,wDCD3_GhostKnightDamageCounter1
    inc  [hl]
    res  3,[hl]                                        ; wrap 0-7
call_02_5f9b_GhostKnight_MoveToPost:
; Two lookups. The post counter indexes .data_02_5fbf, which gives a record number,
; and that record number times four indexes .data_02_5fc7, which is copied over
; ENTITY_FIELD_WORLD_X and ENTITY_FIELD_WORLD_Y in one four-byte loop
    ld   hl,wDCD3_GhostKnightDamageCounter1
    ld   l,[hl]
    ld   h,00
    ld   de,.data_02_5fbf
    add  hl,de
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    add  hl,hl                                         ; record * 4
    ld   de,.data_02_5fc7
    add  hl,de
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_X
    ld   b,$04
.jr_00_5FB8:
    ldi  a,[hl]
    ld   [de],a
    inc  e
    dec  b
    jr   nz,.jr_00_5FB8                                ; X lo, X hi, Y lo, Y hi
    ret
.data_02_5fbf:
; The eight posts, as record numbers into the grid below. They are not in order and
; they do not use consecutive cells - $04, $0E, $1D, $23, $34, $2A, $19, $0A walks
; down the left of the room and back up the right
    db   $04, $0e, $1d, $23, $34
    db   $2a, $19, $0a
.data_02_5fc7:
; A 64-entry grid of X,Y positions, four bytes each, both 16-bit. Only the eight
; picked out above are ever used; the rest is a full eight-by-eight lattice of
; candidate positions, laid out in rows of eight with the Y value repeated across
; each row ($13, $19, $20, $28, $33, $3F, $4D, $5D)
    db   $27, $00, $13, $00, $33
    db   $00, $13, $00, $3f, $00, $13, $00, $4c
    db   $00, $13, $00, $58, $00, $13, $00, $64
    db   $00, $13, $00, $71, $00, $13, $00, $7d
    db   $00, $13, $00, $25, $00, $19, $00, $31
    db   $00, $19, $00, $3e, $00, $19, $00, $4c
    db   $00, $19, $00, $58, $00, $19, $00, $65
    db   $00, $19, $00, $72, $00, $19, $00, $7f
    db   $00, $19, $00, $23, $00, $20, $00, $30
    db   $00, $20, $00, $3e, $00, $20, $00, $4c
    db   $00, $20, $00, $58, $00, $20, $00, $66
    db   $00, $20, $00, $73, $00, $20, $00, $81
    db   $00, $20, $00, $20, $00, $28, $00, $2f
    db   $00, $28, $00, $3d, $00, $28, $00, $4b
    db   $00, $28, $00, $59, $00, $28, $00, $67
    db   $00, $28, $00, $75, $00, $28, $00, $83
    db   $00, $28, $00, $1d, $00, $33, $00, $2c
    db   $00, $33, $00, $3b, $00, $33, $00, $4b
    db   $00, $33, $00, $59, $00, $33, $00, $69
    db   $00, $33, $00, $78, $00, $33, $00, $87
    db   $00, $33, $00, $19, $00, $3f, $00, $29
    db   $00, $3f, $00, $3a, $00, $3f, $00, $4a
    db   $00, $3f, $00, $5a, $00, $3f, $00, $6a
    db   $00, $3f, $00, $7a, $00, $3f, $00, $8a
    db   $00, $3f, $00, $15, $00, $4d, $00, $27
    db   $00, $4d, $00, $38, $00, $4d, $00, $4a
    db   $00, $4d, $00, $5a, $00, $4d, $00, $6c
    db   $00, $4d, $00, $7d, $00, $4d, $00, $8e
    db   $00, $4d, $00, $10, $00, $5d, $00, $23
    db   $00, $5d, $00, $36, $00, $5d, $00, $48
    db   $00, $5d, $00, $5b, $00, $5d, $00, $6e
    db   $00, $5d, $00, $80, $00, $5d, $00, $93
    db   $00, $5d, $00

call_02_60c7_EntityAction_GhostKnightProjectile_Update:
; The knight's shot, and the reason the fan looks aimed when nothing here aims.
;
; The velocity is looked up, not computed: the post number times four, OR'd with
; the low two bits of the shot counter, gives one of 32 entries in .data_02_60ff,
; two bytes each. So each post has its own four fixed directions and they are fired
; in rotation. The shot counter is post-incremented, so it keeps counting across
; posts and only its bottom two bits matter
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_60F2
    ld   a,[wDCD3_GhostKnightDamageCounter1]
    add  a
    add  a                                             ; post * 4
    ld   c,a
    ld   hl,wDCD4_GhostKnightDamageCounter2
    ld   a,[hl]
    inc  [hl]
    and  a,$03                                         ; which of the four
    or   c
    ld   l,a
    ld   h,$00
    add  hl,hl                                         ; two bytes per entry
    ld   de,.data_02_60ff
    add  hl,de
    ld   c,[hl]
    push hl
    call call_00_28c8_Entity_SetXVelocity
    pop  hl
    inc  hl
    ld   c,[hl]
    call call_00_28dc_Entity_SetYVelocity
    ld   c,TIMER_AMOUNT_GHOST_KNIGHT_PROJECTILE
    call call_00_290d_Entity_SetMiscTimer
.jr_00_60F2:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_24ee_Entity_ApplyYVelocity_Subpixel
    call call_00_2922_Entity_DecrementMiscTimer
    jp   z,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret
.data_02_60ff:
; 32 X,Y velocity pairs - four per post, in post order. Every component is $E0
; (-$20), $00 or $20, so each shot goes in one of the eight compass directions and
; a post's four entries pick which four of them that post uses
    db   $e0, $20, $00, $20, $20
    db   $20, $00, $20, $e0, $00, $e0, $20, $00
    db   $20, $20, $20, $00, $20, $e0, $20, $e0
    db   $00, $e0, $e0, $e0, $e0, $20, $e0, $20
    db   $20, $e0, $20, $e0, $00, $e0, $e0, $00
    db   $e0, $20, $e0, $00, $e0, $20, $e0, $20
    db   $00, $20, $20, $20, $e0, $20, $00, $20
    db   $20, $00, $20, $e0, $20, $00, $20, $20
    db   $20, $20, $00


; ==================================================================
; TUT TV
;
; The largest of the three levels documented here, and the one that uses the most
; of the engine's shared machinery: the two moving-platform helpers at the top of
; this file, the hotspot table in call_00_2a98_Entity_CheckPlayerInHotspotAndSetAction,
; the paired left/right entity ids that share one action table, and the only
; cross-entity signal in the file - the mummy hand's slam, which is what breaks the
; breakable blocks.
;
; ENTITY_TUT_TV_RISING_PLATFORM and ENTITY_TUT_TV_SIDEWAYS_PLATFORM have no code of
; their own at all: one row each, pointing at
; call_02_58bd_EntityAction_MovePlatformVertically and
; call_02_585f_EntityAction_MovePlatformHorizontally, with the spawn parameter
; setting the dwell time at each end
; ==================================================================

; ------------------------------------------------------------------
; THE MUMMY HAND. Six rows, five of them code, and its whole cycle is
;
;   $00 Crawl   walk along the sand until it reaches the end of its patrol
;   $01 Rise    launch straight up; leave when the rise turns into a fall
;   $02 Fall    come back down; leave when it reaches its spawn line
;   $03 Slam    the impact, and the one frame that can set wDCDC
;   $04 -       no code. data_02_7861 holds for 40 frames and chains back to $00
;   $05 Settle  unreachable - nothing selects action $05
;
; It cannot be killed. Its ENTITY_ATTR_DAMAGE_STATE is $00 and
; call_03_4fad_CollisionHandler_Hand never calls HandleEntityHit; all whipping it
; does is push it from $00 into $01, so Gex can trigger the leap early but not
; stop it
; ------------------------------------------------------------------

call_02_613f_EntityAction_Hand_Crawl:
; Action $00. NZ from the mover means it just turned at a patrol bound, which is
; the cue to leap. Whipping it gets to $01 the other way, through the handler
    ld   c,$04
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ld   a,$01
    jp   nz,call_02_72ac_Entity_SetAction              ; end of the patrol -> Rise
    ret

call_02_614d_EntityAction_Hand_Rise:
; Action $01. Gravity is applied every frame, so the apex is simply the frame YVEL
; goes negative - no height check
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$38
    call nz,call_00_28dc_Entity_SetYVelocity
.jr_00_6155:
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_28d2_Entity_GetYVelocity
    bit  7,a
    ld   a,$02
    jp   nz,call_02_72ac_Entity_SetAction              ; past the apex -> Fall
    ret

call_02_6163_EntityAction_Hand_Fall:
; Action $02. Carry clear from the floor clamp is the landing
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   a,$03
    jp   nc,call_02_72ac_Entity_SetAction              ; -> Slam
    ret

call_02_616f_EntityAction_Hand_Slam:
; Action $03, and the only place in this file that talks to another entity.
;
; On the first frame it checks its own world X against a fixed window: the
; arithmetic is (X - $01B0) + $0C, required to be positive and below $18, which is
; X somewhere in $01A4..$01BB. That is one particular spot in the level, and
; landing there raises wDCDC_HandEntityUnkFlag - which
; call_02_63a8_EntityAction_BreakableBlock_TakeHit reads and clears. So the
; breakable blocks are broken by the hand's slam, not by Gex.
;
; The $10 upward velocity is the small bounce out of the impact; the second
; SFX_SMALL_BANG is the landing after it
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_61A1
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    ld   c,$10
    call call_00_28dc_Entity_SetYVelocity
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ldi  a,[hl]
    sub  a,$B0
    ld   e,a
    ld   a,[hl]
    sbc  a,$01
    ld   d,a                                           ; DE = X - $01B0
    ld   a,e
    add  a,$0C
    ld   e,a
    ld   a,d
    adc  a,$00
    jr   nz,.jr_00_61A1
    ld   a,e
    cp   a,$18
    jr   nc,.jr_00_61A1                                ; outside $01A4..$01BB
    ld   a,$01
    ld   [wDCDC_HandEntityUnkFlag],a                   ; the breakable block reads this
.jr_00_61A1:
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ret  c
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    ld   a,$04
    jp   call_02_72ac_Entity_SetAction                 ; -> the rest, then back to $00

call_02_61b2_EntityAction_Hand_Settle:
; Action $05. Nothing selects it - the cycle above runs $00-$04 and data_02_7861
; closes the loop - so this is dead code kept alive only by its table row
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    jp   call_00_2766_Entity_ClampYToSpawnFloor

; ------------------------------------------------------------------
; THE LOST ARK, three per level, and the only thing in the game that has to be
; STOMPED rather than whipped - see call_03_4fca_CollisionHandler_LostArk.
;
; Five rows and one instruction of code. Taking it drops the ark into action $01
; through ENTITY_ATTR_DEFEAT_FLAGS $01, and from there the data blocks' pending
; actions run the whole opening on their own: $01 lid, $02 the flash below, $03 the
; burst, $04 the empty ark that stays behind
; ------------------------------------------------------------------

call_02_61b8_EntityAction_LostArk_Flash:
; Action $02. Loads a bright palette every frame it runs; data_02_7883 only holds
; for 15 frames before chaining on, so this is the white-out at the top of the
; opening rather than a state
    ld   hl,.data_02_61be
    jp   call_00_2c20_Entity_CopyPaletteToBuffer
.data_02_61be:
    db   $00, $00, $ff, $7f, $b5, $56, $ad, $35

; ------------------------------------------------------------------
; THE BEE hovers along its patrol and dive-bombs. The dive is one action function
; across three rows, and which row it is in is chosen by its own vertical speed:
;
;   $01  |YVEL| large    the launch
;   $02  YVEL under $08  near the top of the arc
;   $03  YVEL past $F8   coming down
;
; and landing puts it back to $00. Each frame it works out which of those it should
; be and only calls Entity_SetAction when that differs from the action id it is
; already in, so the sprite swap is free on the frames nothing changed
; ------------------------------------------------------------------

call_02_61c6_EntityAction_Bee_Hover:
; Action $00. Paces at $04. Dives when it is facing Gex and he is within $30 -
; it will not turn round to start one
    ld   c,04
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    ret  nz                                            ; facing the other way
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$30
    ret  nc
    ld   c,$20
    call call_00_28c8_Entity_SetXVelocity              ; commit to the dive
    ld   c,$30
    call call_00_28dc_Entity_SetYVelocity
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_61ee_EntityAction_Bee_Dive:
; Actions $01, $02 and $03. Entity_ApplyGravityMoveY_WithFloorCollision returns
; carry clear on the frame it lands, and that is the only exit
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2475_Entity_ApplyGravityMoveY_WithFloorCollision
    ld   c,$00
    jr   nc,.jr_00_620B                                ; landed -> Hover
    call call_00_28d2_Entity_GetYVelocity
    bit  7,a
    jr   nz,.jr_00_6206
    ld   c,$02
    cp   a,$08
    jr   c,.jr_00_620B                                ; slowing at the top
    ret                                                ; still climbing hard
.jr_00_6206:
    cp   a,$F8
    ret  nc                                            ; only just started to drop
    ld   c,$03
.jr_00_620B:
    call call_00_2962_Entity_GetActionId
    ld   a,c
    cp   [hl]
    jp   nz,call_02_72ac_Entity_SetAction              ; only if it actually changed
    ret

; ------------------------------------------------------------------
; THE RAFT, a three-action ferry, and one of the few entities whose position is
; reset rather than respawned. All three rows share one data block - it is a single
; sprite held forever, so nothing here is animated.
;
; ENTITY_FIELD_MISC_TIMER is used as a dwell count in $00 and $02 and the vertical
; drift is tied to it: one pixel every fourth frame for TIMER_AMOUNT_RAFT ticks,
; down on the way in and up on the way out, which is what makes the raft look like
; it is bobbing into and out of the river rather than teleporting
; ------------------------------------------------------------------

call_02_6214_EntityAction_Raft_ResetAndWait:
; Action $00. Puts the raft back where it spawned, $28 pixels lower, then rises one
; pixel every fourth frame while the timer runs down. Reached both from $02 at the
; end of a round trip and from $01 if the raft is ever left off screen
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6239
    call call_00_2826_Entity_ResetToInitialXPos
    call call_00_27e4_Entity_ResetToInitialYPos
    ld   c,$40
    call call_00_2980_Entity_SetMiscFlags
    ld   c,$00
    call call_00_28c8_Entity_SetXVelocity
    ld   c,ENTITY_FACING_RIGHT
    call call_00_2958_Entity_SetFacingDirection
    ld   bc,$0028
    call call_00_250d_Entity_MoveY                     ; start it sunk
    ld   c,TIMER_AMOUNT_RAFT
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6239:
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$03
    ret  nz
    ld   bc,$FFFF
    call call_00_250d_Entity_MoveY                     ; up one pixel per 4 frames
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction               ; surfaced -> ferry
    ret

call_02_624e_EntityAction_Raft_MoveRightAndCarryPlayer:
; Action $01, the crossing. The alternation on the frame counter is a half-speed
; trick: on odd frames it sets XVEL $01 and moves one pixel, on even frames it sets
; XVEL $00 and returns immediately - so the raft travels at half a pixel a frame
; while still reporting a nonzero velocity for Gex to inherit.
;
; Entity_CarryOrPushPlayerX is what moves Gex with it. The two bounds tests are
; against the CAMERA, not the map: past the left edge means the raft has been left
; behind and it goes back to $00, and Entity_ClampXToBounds reporting a clamp at
; the far end means it has arrived and goes to $02
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$01
    ld   c,$00
    jp   z,call_00_28c8_Entity_SetXVelocity            ; the idle half-frame
    ld   c,$01
    call call_00_28c8_Entity_SetXVelocity
    ld   bc,$0001
    call call_00_24df_Entity_MoveX
    call call_00_26c9_Entity_CarryOrPushPlayerX
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ldi  a,[hl]
    ld   d,[hl]
    ld   e,a
    ld   hl,wDA14_CameraPos_Left
    ld   a,e
    sub  [hl]
    inc  hl
    ld   a,d
    sbc  [hl]
    jr   c,.jr_00_6285                                 ; off the left of the camera
    ld   hl,wDA16_CameraPos_Right
    ld   a,e
    sub  [hl]
    inc  hl
    ld   a,d
    sbc  [hl]
    jr   c,.jr_00_628A
.jr_00_6285:
    ld   a,$00
    jp   call_02_72ac_Entity_SetAction                 ; -> ResetAndWait
.jr_00_628A:
    call call_00_2617_Entity_ClampXToBounds
    ld   a,$02
    jp   nc,call_02_72ac_Entity_SetAction              ; reached the far bank
    ret

call_02_6293_EntityAction_Raft_DriftDown:
; Action $02. The mirror of $00 - the same timer, the same one pixel every fourth
; frame, downwards this time - and then back to $00, which is what teleports it
; home while it is under the water
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_62A7
    ld   c,$00
    call call_00_28c8_Entity_SetXVelocity
    ld   c,ENTITY_FACING_RIGHT
    call call_00_2958_Entity_SetFacingDirection
    ld   c,TIMER_AMOUNT_RAFT
    call call_00_290d_Entity_SetMiscTimer
.jr_00_62A7:
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$03
    ret  nz
    ld   bc,$0001
    call call_00_250d_Entity_MoveY                     ; down one pixel per 4 frames
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$00
    jp   z,call_02_72ac_Entity_SetAction               ; sunk -> ResetAndWait
    ret

; ------------------------------------------------------------------
; THE SNAKES. ENTITY_TUT_TV_SNAKE_FACING_RIGHT ($30) and
; ENTITY_TUT_TV_SNAKE_FACING_LEFT ($31) are two entity ids sharing one action
; table, and the code tells them apart by asking Entity_GetId - once in action $00
; to set the initial facing, and once in each of $00 and $01 to pick which of the
; two projectile ids belongs to it. That is the whole difference between them.
;
; The snake also resizes itself: ENTITY_FIELD_COLLISION_WIDTH is $08 while it is
; coiled and $10 while it is extended, so the strike has reach the idle pose does
; not
; ------------------------------------------------------------------

call_02_62bc_EntityAction_Snake_Coiled:
; Action $00. Strikes only on the frame the idle animation wraps, only if facing
; Gex, only if it has no shot already in flight, and only within $40
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_62D0
    ld   c,$08
    call call_00_2944_Entity_SetWidth                  ; narrow while coiled
    call call_00_293a_Entity_GetId
    cp   a,$31                                         ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
    ld   c,ENTITY_FACING_LEFT
    call z,call_00_2958_Entity_SetFacingDirection
.jr_00_62D0:
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    ret  nz
    call call_00_293a_Entity_GetId
    ld   c,ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    cp   a,$30                                         ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
    jr   z,.jr_00_62EA
    ld   c,ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
.jr_00_62EA:
    call call_00_2b10_Entity_FindDuplicateInstance
    ret  nz                                            ; its shot is still out
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$40
    ld   a,$01
    jp   c,call_02_72ac_Entity_SetAction               ; -> Strike
    ret

call_02_62f9_EntityAction_Snake_Strike:
; Action $01. Waits out the lunge animation, widens the hitbox, spits, and hands on
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    ld   c,$10
    call call_00_2944_Entity_SetWidth                  ; extended
    call call_00_293a_Entity_GetId
    ld   c,SPAWN_CHILD_ENTITY_SNAKE_RIGHT_PROJECTILE
    cp   a,$30
    jr   z,.jr_00_630D
    ld   c,SPAWN_CHILD_ENTITY_SNAKE_LEFT_PROJECTILE
.jr_00_630D:
    call call_00_3792_EntitySpawn_SpawnChild
    ld   a,$02
    jp   call_02_72ac_Entity_SetAction                 ; -> Recoil

call_02_6315_EntityAction_Snake_Recoil:
; Action $02. Just puts the hitbox back; data_02_78ce's pending action returns it
; to $00 when the recoil animation ends
    ld   c,$08
    jp   call_00_2944_Entity_SetWidth

call_02_631a_EntityAction_SnakeRightProjectile_Update:
; The right-hand snake's shot. Flies at a fixed $20 with no facing involved, and
; expires on TIMER_AMOUNT_SNAKE_PROJECTILE
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6329
    ld   c,$20
    call call_00_28c8_Entity_SetXVelocity
    ld   c,TIMER_AMOUNT_SNAKE_PROJECTILE
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6329:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_2922_Entity_DecrementMiscTimer
    jp   z,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret

call_02_6333_EntityAction_SnakeLeftProjectile_Update:
; The same routine with $E0 in place of $20. Two entity ids and two copies of the
; code rather than one that reads the facing - which is also why the two snakes
; needed separate ids in the first place
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6342
    ld   c,$E0
    call call_00_28c8_Entity_SetXVelocity
    ld   c,TIMER_AMOUNT_SNAKE_PROJECTILE
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6342:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_2922_Entity_DecrementMiscTimer
    jp   z,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret

; ------------------------------------------------------------------
; THE RA STATUE SHOTS. There is no statue entity - the statues are background art,
; and ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE ($35) and
; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE ($36) are the shots themselves, sat
; parked at the statue's mouth waiting to be triggered. That is why action $00
; resets them to their SPAWN position instead of freeing the slot: the same entity
; is fired over and over, and call_03_54ee_CollisionHandler_RaStatueProjectile puts
; it back to $00 when it hits Gex rather than deactivating it.
;
; Both ids share one action table and are told apart the same way the snakes are -
; by asking Entity_GetId.
;
;   $00 Reset          face the right way, snap back to the spawn point, go to $01
;   $01 WaitForPlayer  the hotspot test. Everything about the shot comes from here
;   $02 -              the launch animation. data_02_7913 chains to $03
;   $03 Fly            move until the timer runs out, then back to $00
; ------------------------------------------------------------------

call_02_634c_EntityAction_RaStatue_Reset:
    call call_00_293a_Entity_GetId
    cp   a,$36                                         ; the diagonal one fires left
    ld   c,ENTITY_FACING_LEFT
    call z,call_00_2958_Entity_SetFacingDirection
    call call_00_2826_Entity_ResetToInitialXPos
    call call_00_27e4_Entity_ResetToInitialYPos
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction                 ; -> WaitForPlayer

call_02_6361_EntityAction_RaStatue_WaitForPlayer:
; Action $01. All of the work is in the shared helper: it picks one record out of
; the table below using this entity's spawn parameter, tests Gex against that
; record's box, and on a hit copies the record's payload into MISC_TIMER, X_VELOCITY
; and Y_VELOCITY and starts the action the record names
    ld   de,.data_02_6367
    jp   call_00_2a98_Entity_CheckPlayerInHotspotAndSetAction
.data_02_6367:
; Five ten-byte hotspot records, indexed by the shot's spawn parameter. Each is
;
;   +0 X centre (16-bit)   +2 X half-width
;   +3 Y centre (16-bit)   +5 Y half-height
;   +6 MISC_TIMER          +7 X velocity   +8 Y velocity   +9 action to start
;
; so the table sets the flight time, the direction and the duration all at once.
; Records 0/1 and 2/3 are the same box twice with $20 and $E0 for the X velocity -
; the same trigger arming the left-firing and right-firing statue at that spot.
; Every record names action $02, the launch animation, which chains on to Fly
    db   $c0, $01, $20, $70, $00
    db   $10, $36, $20, $20, $02, $c0, $01, $20
    db   $70, $00, $10, $36, $e0, $20, $02, $90
    db   $01, $10, $68, $01, $10, $56, $20, $10
    db   $02, $90, $01, $10, $68, $01, $10, $56
    db   $e0, $10, $02, $70, $02, $10, $60, $01
    db   $20, $22, $e4, $20, $02

call_02_6399_EntityAction_RaStatue_Fly:
; Action $03. Runs on the velocities and the timer the hotspot record loaded, and
; going back to $00 is what re-parks it at the statue for the next trigger
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_24ee_Entity_ApplyYVelocity_Subpixel
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$00
    jp   z,call_02_72ac_Entity_SetAction               ; -> Reset
    ret

; ------------------------------------------------------------------
; THE BREAKABLE BLOCK. Four rows: three degrees of damage sharing one function, and
; a shatter.
;
; It is not Gex that breaks it. Its collision type is
; COLLISION_TYPE_PLATFORM | COLLISION_TYPE_FLAG_IMMOVABLE - solid ground with no
; handler of its own - and the only thing that advances it is
; wDCDC_HandEntityUnkFlag, which call_02_616f_EntityAction_Hand_Slam raises when
; the mummy hand slams down in one particular spot. Three slams take the block
; through $00, $01, $02 and into $03
; ------------------------------------------------------------------

call_02_63a8_EntityAction_BreakableBlock_TakeHit:
; Actions $00, $01 and $02. `GetActionId / inc a` is what makes one function serve
; three rows - each hit simply steps to the next one. The flag is cleared as it is
; read, so one slam cannot count twice, and action $00 clears it on entry in case a
; slam landed while no block was watching
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_63B1
    xor  a
    ld   [wDCDC_HandEntityUnkFlag],a
.jr_00_63B1:
    ld   hl,wDCDC_HandEntityUnkFlag
    bit  0,[hl]
    ret  z                                             ; no slam this frame
    ld   [hl],$00                                      ; consume it
    call call_00_2962_Entity_GetActionId
    inc  a
    jp   call_02_72ac_Entity_SetAction                 ; one step more broken

call_02_63c0_EntityAction_BreakableBlock_Shatter:
; Action $03. The farcall is the important line - the block was standable, so its
; entry in the collision map has to be cleared before the slot is freed or Gex goes
; on walking on air
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSFX
    farcall call_03_57f8_ClearCollisionForEntity
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

; ------------------------------------------------------------------
; THE COFFIN. Three rows and one of them is code.
;
; call_03_500d_CollisionHandler_Coffin sends it from $00 to $01 when Gex whips it;
; data_02_794b's pending action carries $01 on to $02 when the two-frame opening
; animation ends. Action $02 is the payoff - it raises the entity's trigger, which
; is what the level's script is waiting on, and records list state 2 so the coffin
; is still open on a revisit
; ------------------------------------------------------------------

call_02_63d3_EntityAction_Coffin_Opened:
    call call_00_22ef_Entity_SetTriggerActive
    ld   c,$02
    jp   call_00_2299_Entity_SetListState

; ==================================================================
; WESTERN STATION
;
; Seven entity types. The interesting pair are the cactus, which is the only
; enemy in the game that watches which way GEX is facing, and the rock platform,
; which is the only one that uses ENTITY_FIELD_COLLISION_HEIGHT as an animation
; channel.
;
; ENTITY_WESTERN_STATION_CACTUS ($3A) is a single row of
; call_02_582e_EntityAction_None with a 30-frame block - scenery, and probably the
; leftover the constants file marks "unused?". ENTITY_WESTERN_STATION_PLAYING_CARD
; is two rows, an idle spin and a Destroy that ENTITY_ATTR_DEFEAT_FLAGS $81
; selects. ENTITY_WESTERN_STATION_RISING_PLATFORM is one row pointing at the
; shared call_02_58bd_EntityAction_MovePlatformVertically
; ==================================================================

; ------------------------------------------------------------------
; THE ENEMY CACTUS creeps up on Gex while his back is turned and freezes when he
; looks at it.
;
; Both halves of that are one comparison: wDA12_EntityDirectionRelativeToPlayer
; against wD80D_PlayerFacingDirection. The two use the same constant values, so
; equal means "the cactus is on the side Gex is facing AWAY from" - it is behind
; him. Action $00 leaves only when that is true; call_02_6405 below returns to $00
; the moment it stops being true.
;
;   $00 Frozen  still, and only wakes when Gex turns his back
;   $01 Turn    face him, hold for 60 frames
;   $02 -       wind-up, chains to $03
;   $03 -       crouch, chains to $04
;   $04 Hop     one hop; on landing go back to $03 and re-test whether he is
;               looking, so the hopping repeats on its own
;   $05 -       the spikes out, and the ONLY state in which it can hurt Gex
;   $06 DestroyWithoutParticles
;
; Nothing here selects $05 - call_03_5028_CollisionHandler_Cactus does, from any
; action below $04, as soon as Gex is within $28. data_02_7980 then holds the
; spikes for 30 frames and chains back to $00. That same handler is also the only
; way to damage it, and only while a fly power-up is running
; ------------------------------------------------------------------

call_02_63db_EntityAction_EnemyCactus_Frozen:
; Action $00. The XVEL is set here rather than in the hop, so the speed is already
; loaded by the time action $04 runs
    ld   c,$28
    call call_00_28c8_Entity_SetXVelocity
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA12_EntityDirectionRelativeToPlayer]
    ld   hl,wD80D_PlayerFacingDirection
    cp   [hl]
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction               ; his back is turned
    ret

call_02_63f0_EntityAction_EnemyCactus_Turn:
; Action $01. One second of facing him before the wind-up starts
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_63FD
    ld   c,TIMER_AMOUNT_60_FRAMES
    call call_00_290d_Entity_SetMiscTimer
    call call_00_2410_Entity_FaceTowardsPlayer
.jr_00_63FD:
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$02
    jp   z,call_02_72ac_Entity_SetAction               ; -> the wind-up

call_02_6405_EnemyCactus_FreezeIfWatched:
; The mirror of the test in action $00, and only reached by falling out of the hop
; below. NOT equal means Gex is now looking this way, and the cactus drops back to
; $00 and stops
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA12_EntityDirectionRelativeToPlayer]
    ld   hl,wD80D_PlayerFacingDirection
    cp   [hl]
    ld   a,$00
    jp   nz,call_02_72ac_Entity_SetAction              ; caught in the act
    ret

call_02_6415_EntityAction_EnemyCactus_Hop:
; Action $04. Landing puts it back into the crouch and then immediately asks
; whether Gex is watching, so a cactus behind him hops $03 -> $04 -> $03 -> $04
; without ever passing through $00 again. The `jr` into the routine above rather
; than a `jp` is only because it is 11 bytes away
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$20
    call nz,call_00_28dc_Entity_SetYVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ret  c                                             ; still in the air
    ld   a,$03
    call call_02_72ac_Entity_SetAction                 ; back to the crouch
    jr   call_02_6405_EnemyCactus_FreezeIfWatched

; ------------------------------------------------------------------
; THE ROCK PLATFORM crumbles under Gex and comes back.
;
; It is the only entity here that animates its COLLISION_HEIGHT: actions $01 and
; $03 look the height up by ENTITY_FIELD_SPRITE_COUNTER, so the box shrinks and
; grows in step with the sprite the animation is already showing rather than
; needing a timer of its own. The two tables are each other reversed.
;
;   $00 Solid    intact. Standing on it arms the countdown
;   $01 Crumble  height $10 down to $02 over eight frames, chains to $02
;   $02 Gone     drop out of the collision map, chains to $03 after 120 frames
;   $03 Reform   height $02 back up to $10, chains back to $00
;
; How long you get is the entity's spawn parameter, so different rocks in the same
; room can be set to different fuses
; ------------------------------------------------------------------

call_02_642e_EntityAction_Rock_Solid:
; Action $00. Two phases in one routine: while the timer is zero it is waiting to
; be stood on, and once it is non-zero it is counting down. wDC7B_Player_EntityStoodOnLo
; holds the slot base of whatever Gex is standing on, which is compared straight
; against this entity's own
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_643D
    ld   c,TIMER_AMOUNT_0_FRAMES
    call call_00_290d_Entity_SetMiscTimer
    ld   c,$10
    call call_00_294e_Entity_SetHeight                 ; full height
.jr_00_643D:
    call call_00_2917_Entity_CheckMiscTimerZero
    jr   nz,.jr_00_6450                                ; already counting down
    ld   a,[wDC7B_Player_EntityStoodOnLo]
    ld   hl,wDA00_CurrentEntityAddrLo
    cp   [hl]
    ret  nz                                            ; nobody on it
    call call_00_230f_Entity_GetParameterIntoC         ; this rock's own fuse
    jp   call_00_290d_Entity_SetMiscTimer
.jr_00_6450:
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction               ; -> Crumble
    ret

call_02_6459_EntityAction_Rock_Crumble:
; Action $01. The height follows the animation frame, so nothing here needs to know
; how long the crumble takes - data_02_7998's own pending action ends it
    call call_00_296c_Entity_GetSpriteCounter
    ld   l,a
    ld   h,$00
    ld   de,.data_02_6467
    add  hl,de
    ld   c,[hl]
    jp   call_00_294e_Entity_SetHeight
.data_02_6467:
; Collision height per animation frame, shrinking
    db   $10, $0e, $0c, $0a, $08, $06, $04, $02

call_02_646f_EntityAction_Rock_Gone:
; Action $02. Removing it from the BG collision map is what actually drops Gex -
; the height above only shrinks the box
    farcall call_03_57f8_ClearCollisionForEntity
    ret

call_02_647b_EntityAction_Rock_Reform:
; Action $03. The same trick as Crumble with the table the other way round
    call call_00_296c_Entity_GetSpriteCounter
    ld   l,a
    ld   h,$00
    ld   de,.data_02_6489
    add  hl,de
    ld   c,[hl]
    jp   call_00_294e_Entity_SetHeight
.data_02_6489:
; Collision height per animation frame, growing
    db   $02, $04, $06, $08, $0a, $0c, $0e, $10

; ------------------------------------------------------------------
; THE HARD HAT is the penguin's routine again, threshold for threshold: amble at
; $04 beyond $30, turn away and run at $1E inside it, and jump when either the run
; hits the end of the patrol or Gex closes to within $20.
;
; What makes him a different fight is his collision handler rather than his
; movement. call_03_5085_CollisionHandler_HardHat only lets a hit land while he is
; in action $01 - in the air - and a hit at any other time just ducks him into
; action $02 under the helmet. Actions $02 and $03 have no code: their data blocks
; carry pending action $00 and time the duck out on their own
; ------------------------------------------------------------------

call_02_6491_EntityAction_HardHat_Walk:
    call call_00_2722_Entity_IsPlayerInsideBounds
    jr   z,.jr_00_64A0
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$30
    jr   c,.jr_00_64A8
.jr_00_64A0:
    ld   c,$04
    call call_00_2588_Entity_NudgeXVelocityTowardC     ; far away - amble
    jp   call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
.jr_00_64A8:
    ld   a,[wDA12_EntityDirectionRelativeToPlayer]
    xor  a,$20                                         ; face away from Gex
    ld   c,a
    call call_00_2958_Entity_SetFacingDirection
    ld   c,$1E
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    jr   nz,.jr_00_64C8                                ; cornered - jump
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$20
    ret  nc                                            ; still has room to run
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    ld   c,[hl]
    call call_00_2958_Entity_SetFacingDirection        ; turn back and jump over him
.jr_00_64C8:
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_64cd_EntityAction_HardHat_Jump:
; Action $01, and the only state he can be hit in
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$20
    call nz,call_00_28dc_Entity_SetYVelocity
    ld   c,$10
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   a,$00
    jp   nc,call_02_72ac_Entity_SetAction              ; landed -> Walk
    ret

; ------------------------------------------------------------------
; THE BAT hangs from the ceiling, drops on Gex and flies off the bottom of the
; screen, and the loop closes by putting it back on its perch rather than by
; respawning it - action $00 resets X and Y to the spawn position on its first
; frame.
;
;   $00 Hanging  reset to the perch; drop when Gex is within $10
;   $01 -        the release, chains to $02
;   $02 Swoop    fly at him while the climb lasts
;   $03 Dive     keep going until it is off the bottom of the camera, then $00
;   $04 Destroy
;
; Note action $02 sets a LITERAL velocity by facing ($10 or $F0) rather than using
; the facing-aware mover, which is why it uses Entity_ApplyXVelocity_Subpixel and
; not Entity_MoveXByFacingSpeed - the bat is not on a patrol and must not turn
; round at a bound
; ------------------------------------------------------------------

call_02_64e9_EntityAction_Bat_Hanging:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_64F4
    call call_00_2826_Entity_ResetToInitialXPos        ; back on the perch
    call call_00_27e4_Entity_ResetToInitialYPos
.jr_00_64F4:
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$10
    ld   a,$01
    jp   c,call_02_72ac_Entity_SetAction               ; he is underneath -> drop
    ret

call_02_6502_EntityAction_Bat_Swoop:
; Action $02, entered from data_02_79f9's pending action. Gravity is fighting the
; $20 launch, so the swoop ends the frame the velocity turns negative
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_651D
    call call_00_2410_Entity_FaceTowardsPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   c,$10
    cp   a,$00                                         ; ENTITY_FACING_RIGHT
    jr   z,.jr_00_6515
    ld   c,$F0
.jr_00_6515:
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$20
    call call_00_28dc_Entity_SetYVelocity
.jr_00_651D:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_28f1_Entity_CheckIfYVelocityIsZero
    bit  7,a
    ld   a,$03
    jp   nz,call_02_72ac_Entity_SetAction              ; now descending -> Dive
    ret

call_02_652e_EntityAction_Bat_Dive:
; Action $03. No floor check at all - it falls straight past the level and the
; camera test is what recycles it
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2780_Entity_IsBelowCameraBottom
    ld   a,$00
    jp   nc,call_02_72ac_Entity_SetAction              ; off screen -> Hanging
    ret


; ==================================================================
; ANIME CHANNEL
;
; The biggest section in this file, and the one level built around wiring rather
; than around enemies. Nine of its entity types do nothing but read or write
; wDCB1_LevelTriggerBuffer - the sixteen-byte per-level scratchpad indexed by an
; entity's spawn parameter - so a switch, a broken tube or a beaten mech can open a
; door somewhere else in the room.
;
; The four routines that make that work are in bank00_entity_utils.asm:
; Entity_CheckTriggerFlag reads this entity's slot, Entity_SetTriggerActive sets
; it, and Entity_SetListState writes the low nibble of this entity's
; wD700_EntityFlags byte - which is the action the entry will SPAWN INTO next time
; the room is entered. That is why so many routines here pair "set list state N"
; with "set action M": one is what happens now, the other is what happens on a
; revisit.
;
; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE has no code - three
; call_02_582e_EntityAction_None rows, with
; call_03_50b6_CollisionHandler_AlienCultureTube stepping it and
; ENTITY_ATTR_DEFEAT_FLAGS $01 choosing action $01, whose pending action carries it
; to $02. ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON is an idle plus a Destroy
; ==================================================================

; ------------------------------------------------------------------
; THE DOOR PAIR. ENTITY_ANIME_CHANNEL_DOOR is the door Gex walks INTO and
; ENTITY_ANIME_CHANNEL_DOOR2 the one he comes OUT of, and the two four-row tables
; are the same four states rotated by two.
;
; Both collision handlers - call_03_5116_CollisionHandler_Door and
; call_03_5156_CollisionHandler_Door2 - want Gex standing still on the ground with
; UP held, and check the door's trigger slot unless its spawn parameter is $FF.
; Door opens into action $01, Door2 into action $03.
;
; call_00_1bbc_CheckForDoorAndEnter.jr_00_1bce is the local entry point that
; actually moves Gex to the other end, and it is called from the middle of the
; opening animation - on the frame it wraps - rather than from the handler
; ------------------------------------------------------------------

call_02_653d_EntityAction_Door1_Opening:
; Door action $01. List state 2 is the door's state for the return trip: coming
; back into this room spawns it in action $02 below, standing open
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    call call_00_1bbc_CheckForDoorAndEnter.jr_00_1bce  ; take Gex through
    ld   c,$02
    jp   call_00_2299_Entity_SetListState

call_02_6549_EntityAction_Door1_CloseAfterReturn:
; Door action $02, only ever reached by spawning into it. Puts the list state back
; to $00 - closed - and runs the closing animation, which chains to $00 itself
    ld   c,$00
    call call_00_2299_Entity_SetListState
    ld   a,$03
    jp   call_02_72ac_Entity_SetAction                 ; -> the closing frames

call_02_6553_EntityAction_Door2_ArriveAndClose:
; Door2 action $00. This is the door Gex has just stepped out of: it starts open,
; records list state 2 so a revisit finds it shut, and shuts itself
    ld   c,$02
    call call_00_2299_Entity_SetListState
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction                 ; -> the closing frames

call_02_655d_EntityAction_Door2_Opening:
; Door2 action $03, the mirror of Door1's $01
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    call call_00_1bbc_CheckForDoorAndEnter.jr_00_1bce
    ld   c,$00
    jp   call_00_2299_Entity_SetListState

; ------------------------------------------------------------------
; THE FAN LIFT is the updraft, not the fan: its attribute row is
; COLLISION_TYPE_NONE with zero width and height, so it never touches anything.
; What it does is exist while its trigger is set, and
; call_02_4a52_PlayerAction_BlownUpwards is what carries Gex.
;
;   $00 WaitForTrigger  off. Turns on when the trigger goes up
;   $01 -               spin-up, chains to $02
;   $02 Blow            running. Turns off when the trigger goes down
;   $03 -               spin-down, chains back to $00
; ------------------------------------------------------------------

call_02_6569_EntityAction_FanLift_WaitForTrigger:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  z
    ld   c,$02
    call call_00_2299_Entity_SetListState              ; spawn running on a revisit
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_6577_EntityAction_FanLift_Blow:
; Action $02. The first half is the flicker: Entity_CheckMiscTimerZero leaves HL on
; MISC_TIMER and A holding it, the timer is bumped, and it is ANDed with the frame
; counter and masked to $1F. On any frame where that is non-zero the facing byte is
; flipped, which mirrors the sprite - so the draught shimmers on a pattern rather
; than on a period
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  [hl]
    ld   hl,wDC71_VBlankFrameCounter
    and  [hl]
    and  a,$1F
    jr   z,.jr_00_6589
    call call_00_2976_Entity_GetFacingDirection
    xor  a,$20
    ld   [hl],a                                        ; mirror the sprite
.jr_00_6589:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  nz                                            ; still switched on
    ld   c,$00
    call call_00_2299_Entity_SetListState
    ld   a,$03
    jp   call_02_72ac_Entity_SetAction                 ; -> spin down

; ------------------------------------------------------------------
; THE MECHS do not move at all. Both are one row of code plus a Destroy, and the
; only difference between them is that the left-facing one re-asserts its facing
; every frame before falling into the right-facing one's `ret`.
;
; They are the level's power-up gate: call_03_5231_CollisionHandler_Mech ignores an
; attack completely unless a fly power-up timer is running, and a mech that dies
; raises its trigger slot.
;
; data_02_7a85 is two blocks the disassembly did not split - a second six-byte
; block for sprite $3f follows it at $7a8b, and nothing references it. Both mech
; tables point at $7a85, so the right-facing sprite is used for both
; ------------------------------------------------------------------

call_02_6597_EntityAction_MechLeft_HoldFacingLeft:
    ld   c,ENTITY_FACING_LEFT
    call call_00_2958_Entity_SetFacingDirection
call_02_659c_EntityAction_MechRight_Idle:
    ret

; ------------------------------------------------------------------
; THE DISAPPEARING FLOOR is the one entity that reads a trigger as a COUNT rather
; than as a flag. `cp a,$02 / ret c` means two switches, and
; call_03_50f4_CollisionHandler_OnSwitch2 is the switch type that INCREMENTS its
; slot rather than setting it - which is the whole reason that variant exists.
;
; Once both are thrown the floor drops out of the BG collision map and goes to
; action $01, its Destroy row
; ------------------------------------------------------------------

call_02_659d_EntityAction_AnimeDisappearingFloor_WaitForSwitches:
    call call_00_22d4_Entity_CheckTriggerFlag
    cp   a,$02
    ret  c                                             ; fewer than two switches
    farcall call_03_57f8_ClearCollisionForEntity
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_65b3_EntityAction_Onswitch2_Thrown:
; ENTITY_ANIME_CHANNEL_ON_SWITCH2, action $01 - the thrown pose. The one-shot
; switch normally stays thrown forever; this is the exception, and it is hard-wired
; to a single room. On MAP_ANIME_CHANNEL4, if the count has fallen back to exactly
; one, the switch resets itself to $00 and can be thrown again
    ld   a,[wDB6C_CurrentMapId]
    cp   a,MAP_ANIME_CHANNEL4
    ret  nz
    call call_00_22d4_Entity_CheckTriggerFlag
    cp   a,$01
    ret  nz
    ld   c,$00
    call call_00_2299_Entity_SetListState
    ld   a,$00
    jp   call_02_72ac_Entity_SetAction                 ; ready again

call_02_65c9_EntityAction_BlueBeamBarrier_Solid:
; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER, action $00 - the beam is up. Its
; attribute row is a $08 x $40 immovable platform, so a standing beam is a wall.
; When its trigger goes up it switches to action $01, whose data block sets the
; invisible flag, and records list state 1 so it stays down
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  z
    ld   c,$01
    call call_00_2299_Entity_SetListState
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction                 ; beam off

call_02_65d7_EntityAction_AnimeRisingPlatform_Update:
; The pressure plate, and the only entity in the file that uses MISC_TIMER as a
; position rather than a countdown: it holds how far the platform has been pushed
; down, from $00 to $A7.
;
; Standing on anything ELSE (or nothing) lets it rise a pixel a frame until the
; count reaches $A8; standing on THIS platform lets it sink a pixel every fourth
; frame until the count is back to zero. So Gex's weight pushes it down and it
; floats back up when he steps off - the timer and the height can never drift
; apart because both move by one at a time
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,TIMER_AMOUNT_0_FRAMES
    call nz,call_00_290d_Entity_SetMiscTimer
    ld   a,[wDC7B_Player_EntityStoodOnLo]
    and  a
    jr   z,.jr_00_65F8                                 ; standing on nothing
    ld   hl,wDA00_CurrentEntityAddrLo
    cp   [hl]
    jr   z,.jr_00_65F8                                 ; standing on this one
    call call_00_2917_Entity_CheckMiscTimerZero
    cp   a,$A8
    ret  nc                                            ; fully raised
    inc  [hl]
    ld   bc,$FFFF
    jp   call_00_250d_Entity_MoveY                     ; up one pixel
.jr_00_65F8:
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$03
    ret  nz                                            ; one frame in four
    call call_00_2917_Entity_CheckMiscTimerZero
    ret  z                                             ; fully lowered
    dec  [hl]
    ld   bc,$0001
    jp   call_00_250d_Entity_MoveY                     ; down one pixel

; ------------------------------------------------------------------
; THE TWO SWITCHES. Four routines, and all four are the same six instructions -
; read the trigger, write a list state, change action. The on-switch shows its
; thrown pose while the trigger is set and the off-switch shows its thrown pose
; while it is set too; what differs is what their COLLISION handlers do to the
; trigger, not what these do with it. call_03_50e0_CollisionHandler_OnSwitch sets
; the slot, call_03_50ea_CollisionHandler_OffSwitch clears it.
;
; The two "unthrown" labels used to carry the address of the routine above them -
; the on-switch's was named $659d and the off-switch's $6617 - which is how a
; disassembly copy-and-paste shows up. They are at $6609 and $6625
; ------------------------------------------------------------------

call_02_6609_EntityAction_OnSwitch_Unthrown:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  z
    ld   c,$01
    call call_00_2299_Entity_SetListState
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_6617_EntityAction_OnSwitch_Thrown:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  nz
    ld   c,$00
    call call_00_2299_Entity_SetListState
    ld   a,$00
    jp   call_02_72ac_Entity_SetAction

call_02_6625_EntityAction_OffSwitch_Unthrown:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  z
    ld   c,$01
    call call_00_2299_Entity_SetListState
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_6633_EntityAction_OffSwitch_Thrown:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  nz
    ld   c,$00
    call call_00_2299_Entity_SetListState
    ld   a,$00
    jp   call_02_72ac_Entity_SetAction

; ------------------------------------------------------------------
; SAILOR TOON GIRL, and the only enemy in the file with a scripted move list.
;
; Action $00 paces. Once Gex is inside her bounds she turns to face him and then
; splits on distance: past $40 she leaps ($04), inside $18 she picks her next move
; out of .data_02_667e. That table is walked one entry per encounter and wraps at
; nine, so the sequence is fixed and repeats - kick, pose, pose, kick, leap, kick,
; leap, pose, leap - and she turns her back before every leap.
;
;   $00 Patrol     the routine above
;   $01 -          the kick. Chains back to $00
;   $02 Stunned    beaten down. Only gravity
;   $03 Knockdown  the reeling hit, into $04 when the animation ends
;   $04 -          crouch, chains to $05
;   $05 Leap       the jump itself, back to $00 on landing
;   $06 -          the pose. Chains back to $00
;   $07 Destroy
;
; call_03_51b8_CollisionHandler_SailorToonGirl is what puts her into $03 and,
; once she is sitting in $02, finishes her into $07
; ------------------------------------------------------------------

call_02_6641_EntityAction_SailorToonGirl_Patrol:
    ld   c,$10
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2722_Entity_IsPlayerInsideBounds
    ret  z
    call call_00_2410_Entity_FaceTowardsPlayer
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$18
    jr   c,.jr_00_6662                                 ; in range - pick a move
    cp   a,$40
    ld   a,$04
    jp   nc,call_02_72ac_Entity_SetAction              ; far - close the gap
    ret
.jr_00_6662:
; MISC_TIMER is the cursor into the move list, wrapping at nine
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  a
    cp   a,$09
    jr   c,.jr_00_666B
    xor  a
.jr_00_666B:
    ld   [hl],a
    ld   l,a
    ld   h,$00
    ld   de,.data_02_667e
    add  hl,de
    ld   a,[hl]
    push af
    cp   a,$04
    call z,call_00_242d_Entity_FaceAwayFromPlayer      ; leaps go backwards
    pop  af
    jp   call_02_72ac_Entity_SetAction
.data_02_667e:
; Her move list, one entry per time Gex comes inside $18. $01 kick, $04 leap away,
; $06 pose
    db   $01, $06, $06, $01, $04, $01, $04, $06, $04

call_02_6687_EntityAction_SailorToonGirl_Stunned:
; Action $02, the beaten pose. She still falls, but nothing else runs - and the
; handler treats being in this action as "one more hit finishes her"
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    jp   call_00_2766_Entity_ClampYToSpawnFloor

call_02_668d_EntityAction_SailorToonGirl_Knockdown:
; Action $03. Must be back on the ground AND have finished the animation before it
; hands on, so a hit taken in mid-air plays out its fall first
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ret  c                                             ; still airborne
    call call_00_2a5d_Entity_CheckAnimationEnded
    ld   a,$04
    jp   nz,call_02_72ac_Entity_SetAction
    ret

call_02_669d_EntityAction_SailorToonGirl_Leap:
; Action $05, entered from data_02_7b0d's pending action. Uses the facing set back
; in Patrol, so a leap chosen off the move list carries her away from Gex and a
; leap chosen by the distance test carries her toward him
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_66AC
    ld   c,$18
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$28
    call call_00_28dc_Entity_SetYVelocity
.jr_00_66AC:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   a,$00
    jp   nc,call_02_72ac_Entity_SetAction              ; landed -> Patrol
    ret

; ------------------------------------------------------------------
; THE BIG SILVER ROBOT charges in a straight line and turns round at the wall.
;
; Both $01 and $02 flip the facing byte by hand with `xor $20` on top of what
; Entity_MoveXByFacingMomentum_BoundsChecked has already done, which cancels out -
; so the robot keeps charging the SAME way after hitting a bound and only the long
; 34-frame recovery in $02 breaks up the pattern.
;
; Action $03 is its death, and call_03_5201_CollisionHandler_BigSilverRobot skips
; the whole handler while it is in that action. That handler also turns it to face
; Gex before every hit, so it always dies facing him
; ------------------------------------------------------------------

call_02_66bb_EntityAction_BigSilverRobot_Watch:
    call call_00_2410_Entity_FaceTowardsPlayer
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$38
    ld   a,$01
    jp   c,call_02_72ac_Entity_SetAction               ; -> Charge
    ret

call_02_66cc_EntityAction_BigSilverRobot_Charge:
    ld   c,$10
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ret  z                                             ; still inside the patrol
    call call_00_2976_Entity_GetFacingDirection
    xor  a,$20
    ld   [hl],a                                        ; undo the mover's turn
    ld   a,$02
    jp   call_02_72ac_Entity_SetAction

call_02_66e0_EntityAction_BigSilverRobot_Recover:
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    call call_00_2976_Entity_GetFacingDirection
    xor  a,$20
    ld   [hl],a
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction                 ; charge back the other way

call_02_66ef_EntityAction_BigSilverRobot_Death:
; Action $03, from ENTITY_ATTR_DEFEAT_FLAGS $03 - no particles and no collectible,
; so the eleven-frame animation is the whole death
    call call_00_2a5d_Entity_CheckAnimationEnded
    jp   nz,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret

; ------------------------------------------------------------------
; THE SMALL BLUE ROBOT is the penguin routine for the third time - amble beyond
; $38, flee inside it, jump when cornered or when Gex closes to $28 - with slower
; numbers and no floor-relative behaviour of its own
; ------------------------------------------------------------------

call_02_66f6_EntityAction_SmallBlueRobot_WalkOrRun:
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$38
    jr   c,.jr_00_6708
    ld   c,$06
    call call_00_2588_Entity_NudgeXVelocityTowardC
    jp   call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
.jr_00_6708:
    ld   a,[wDA12_EntityDirectionRelativeToPlayer]
    xor  a,$20                                         ; face away from Gex
    ld   c,a
    call call_00_2958_Entity_SetFacingDirection
    ld   c,$10
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    jr   nz,.jr_00_6728                                ; cornered
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$28
    ret  nc
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    ld   c,[hl]
    call call_00_2958_Entity_SetFacingDirection        ; turn back and jump over him
.jr_00_6728:
    ld   c,$30
    call call_00_28dc_Entity_SetYVelocity
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_6732_EntityAction_SmallBlueRobot_Jump:
    ld   c,$02
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   a,$00
    jp   nc,call_02_72ac_Entity_SetAction
    ret

; ------------------------------------------------------------------
; THE SECBOT patrols on the ground until it is hit, then rises eighty pixels and
; patrols in the air at four times the speed. Getting hit makes it WORSE, which is
; unusual here - call_03_5196_CollisionHandler_Secbot sends a secbot that survives
; a hit in action $00 to action $02, and data_02_7b8f chains that on to $01.
;
; Both actions fire the same way - only while facing Gex - but they time it
; differently, and both use the timer for something other than a countdown to a
; state change:
;
;   $00 Patrol  the timer is reloaded with $02 every time it turns round, so it
;               gets exactly one shot off per pass
;   $01 Hover   the timer is reloaded with $C1 on a turn and a shot goes out every
;               time the low six bits reach zero - every 64 frames
;
; ENTITY_FIELD_MISC_FLAGS is the rise counter in $01: it counts to $50 one pixel a
; frame and then stops, so the climb happens once
; ------------------------------------------------------------------

call_02_6746_EntityAction_Secbot_Patrol:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,TIMER_AMOUNT_0_FRAMES
    call nz,call_00_290d_Entity_SetMiscTimer
    ld   c,$04
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ld   c,TIMER_AMOUNT_SECBOT_2
    call nz,call_00_290d_Entity_SetMiscTimer           ; just turned - arm a shot
    call call_00_29ac_Entity_IsFacingPlayer
    ret  nz
    call call_00_2922_Entity_DecrementMiscTimer
    ld   c,SPAWN_CHILD_ENTITY_SECBOT_PROJECTILE
    jp   nz,call_00_3792_EntitySpawn_SpawnChild
    ret

call_02_6768_EntityAction_Secbot_Hover:
    call call_00_298a_Entity_GetMiscFlags
    cp   a,$50
    jr   z,.jr_00_6776                                 ; finished climbing
    inc  [hl]
    ld   bc,$FFFF
    call call_00_250d_Entity_MoveY                     ; up one pixel a frame
.jr_00_6776:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,TIMER_AMOUNT_0_FRAMES
    call nz,call_00_290d_Entity_SetMiscTimer
    ld   c,$10
    call call_00_28c8_Entity_SetXVelocity              ; four times the ground speed
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ld   c,TIMER_AMOUNT_SECBOT
    call nz,call_00_290d_Entity_SetMiscTimer
    call call_00_29ac_Entity_IsFacingPlayer
    ret  nz
    call call_00_2922_Entity_DecrementMiscTimer
    ret  z
    and  a,$3F
    ld   c,SPAWN_CHILD_ENTITY_SECBOT_PROJECTILE
    jp   z,call_00_3792_EntitySpawn_SpawnChild         ; every 64 frames
    ret

call_02_679b_EntityAction_SecbotProjectile_Update:
; The shot. It is given gravity and a floor clamp as well as a horizontal velocity,
; so it drops as it travels and skids along the ground rather than flying straight
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_67B3
    call call_00_2976_Entity_GetFacingDirection
    ld   c,$18
    cp   a,$00                                         ; ENTITY_FACING_RIGHT
    jr   z,.jr_00_67AB
    ld   c,$E8
.jr_00_67AB:
    call call_00_28c8_Entity_SetXVelocity
    ld   c,TIMER_AMOUNT_180_FRAMES
    call call_00_290d_Entity_SetMiscTimer
.jr_00_67B3:
    call call_00_2922_Entity_DecrementMiscTimer
    jp   z,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    jp   call_00_2766_Entity_ClampYToSpawnFloor

; ------------------------------------------------------------------
; THE ELEVATOR, the most table-driven entity in the file and the only one that
; keeps state outside its own slot.
;
; There are three shafts in the level, at X $01A0, $0340 and $05C0
; (.data_02_68A9). call_02_688e_Elevator_GetShaftIndex turns this entity's X into
; an index 0-2, and the three words at wDCE2_ElevatorEntityUnkData remember each
; shaft's height - so an elevator that scrolls off screen and respawns comes back
; where it was left rather than at its spawn point.
;
; Where it should GO comes from .data_02_686a, which is keyed on the shaft's X and
; on the trigger COUNT: with the count at $00 shaft 1 sits at Y $0298, at $01 the
; three shafts go to $0158/$01D8/$0258, at $02 to $0108/$0158/$01D8. So throwing
; switches raises every elevator in the level a floor at a time.
;
; It only moves while Gex is standing on it, and while moving it holds him in
; PLAYERACTION_RIDING_ELEVATOR and drops him back to PLAYERACTION_IDLE on arrival
; ------------------------------------------------------------------

call_02_67c2_EntityAction_Elevator_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_67DF
    call call_02_688e_Elevator_GetShaftIndex
    ld   l,c
    ld   h,$00
    add  hl,hl                                         ; two bytes per shaft
    ld   de,wDCE2_ElevatorEntityUnkData
    add  hl,de
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    ld   [de],a
    inc  e
    ld   a,[hl]
    ld   [de],a                                        ; restore the remembered Y
.jr_00_67DF:
    ld   a,[wDC7B_Player_EntityStoodOnLo]
    ld   hl,wDA00_CurrentEntityAddrLo
    cp   [hl]
    ret  nz                                            ; nobody riding
    call call_00_22d4_Entity_CheckTriggerFlag
    ld   c,a                                           ; C = how many switches
    ld   hl,.data_02_686a
.jr_00_67EE:
; Walk the destination table looking for a record with this trigger count and this
; shaft's X
    push hl
    ldi  a,[hl]
    cp   c
    jr   nz,.jr_00_6805
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_X
    ld   a,[de]
    sub  [hl]
    ld   b,a
    inc  de
    inc  hl
    ld   a,[de]
    sbc  [hl]
    or   b
    jr   z,.jr_00_6810                                 ; this record is ours
.jr_00_6805:
    pop  hl
    ld   de,$0005                                      ; next five-byte record
    add  hl,de
    ld   a,[hl]
    cp   a,$FF
    jr   nz,.jr_00_67EE
    ret                                                ; no destination - sit still
.jr_00_6810:
; HL is on the record's target Y. Compare it with where the elevator is now
    inc  de
    inc  hl
    ld   a,[de]
    sub  [hl]
    ld   c,a
    inc  de
    inc  hl
    ld   a,[de]
    sbc  [hl]
    pop  hl
    jr   c,.jr_00_6847                                 ; below the target - go down
    or   c
    jr   nz,.jr_00_6842                                ; above it - go up
; Arrived. Write the height back to the shaft slot and let Gex stand up again
    call call_02_688e_Elevator_GetShaftIndex
    ld   l,c
    ld   h,$00
    add  hl,hl
    ld   de,wDCE2_ElevatorEntityUnkData
    add  hl,de
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_Y
    ld   a,[de]
    ldi  [hl],a
    inc  e
    ld   a,[de]
    ld   [hl],a
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_RIDING_ELEVATOR
    ld   a,PLAYERACTION_IDLE
    jp   z,call_02_54f9_Player_RequestAction
    ret
.jr_00_6842:
    ld   bc,$FFFF                                      ; one pixel up
    jr   .jr_00_684A
.jr_00_6847:
    ld   bc,$0001                                      ; one pixel down
.jr_00_684A:
; Lock Gex into the riding action, then move - but only if he is exactly lined up
; with the platform, which is what stops it dragging him through a wall
    ld   a,PLAYERACTION_RIDING_ELEVATOR
    ld   hl,wD801_Player_ActionId
    cp   [hl]
    jp   nz,call_02_54f9_Player_RequestAction
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    or   e
    jp   z,call_00_250d_Entity_MoveY
    ret
.data_02_686a:
; Seven five-byte records and an $FF terminator:
;
;   +0 trigger count   +1 shaft X (16-bit)   +3 target Y (16-bit)
;
; count $00 parks shaft 1 at the bottom; $01 and $02 each raise all three
    db   $00, $a0, $01, $98, $02
    db   $01, $a0, $01, $58, $01, $01, $40, $03
    db   $d8, $01, $01, $c0, $05, $58, $02, $02
    db   $a0, $01, $08, $01, $02, $40, $03, $58
    db   $01, $02, $c0, $05, $d8, $01, $ff

call_02_688e_Elevator_GetShaftIndex:
; Returns in C which of the three shafts this elevator is in, by matching its X
; against the list below. There is no bounds check - an elevator placed at any
; other X walks off the end of the table
    ld   hl,.data_02_68A9
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_X
    ld   c,$FF
.jr_00_689B:
    inc  c
    ld   a,[de]
    sub  [hl]
    ld   b,a
    inc  de
    inc  hl
    ld   a,[de]
    sbc  [hl]
    dec  de
    inc  hl
    or   b
    jr   nz,.jr_00_689B
    ret
.data_02_68A9:
; The three shaft X positions: $01A0, $0340, $05C0
    db   $a0, $01, $40, $03, $c0, $05

call_02_68af_EntityAction_FireWallEnemy_Update:
; One instruction. call_00_233e_Entity_MoveAlongArcTable flies it round a canned
; circle relative to its spawn position, so the whole behaviour is in that helper
; and in ENTITY_FIELD_X_VELOCITY / X_SUBPIXEL, which it reuses as a step counter
; and a quadrant
    jp   call_00_233e_Entity_MoveAlongArcTable

; ------------------------------------------------------------------
; THE GRENADE never stops. Its three actions loop forever - reset, bounce three
; times, explode, reset - and it is scenery rather than an enemy that can be
; beaten: its ENTITY_ATTR_DEFEAT_FLAGS are $FF.
;
; MISC_TIMER counts the bounces down from TIMER_AMOUNT_GRENADE ($04) and doubles as
; the index into the bounce-height table, so each bounce is lower than the last
; ------------------------------------------------------------------

call_02_68b2_EntityAction_Grenade_Reset:
; Action $00, and it runs only on its first frame. Puts the grenade back at its
; spawn point offset by the low nibble of the frame counter horizontally and by its
; own spawn parameter vertically - `ld b,$FF` makes that offset negative, so it
; starts ABOVE the spawn line. The X jitter is what stops several grenades in a row
; falling in step
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ret  z
    ld   hl,.data_02_68e5
    call call_00_2c20_Entity_CopyPaletteToBuffer
    call call_00_2826_Entity_ResetToInitialXPos
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$0F
    ld   c,a
    ld   b,$00
    call call_00_24df_Entity_MoveX                     ; jitter X by 0-15
    call call_00_27e4_Entity_ResetToInitialYPos
    call call_00_230f_Entity_GetParameterIntoC
    ld   b,$FF
    call call_00_250d_Entity_MoveY                     ; start this far above
    ld   c,TIMER_AMOUNT_GRENADE
    call call_00_290d_Entity_SetMiscTimer              ; four bounces
    ld   c,$00
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$00
    call call_00_28dc_Entity_SetYVelocity
    ret
.data_02_68e5:
    db   $00, $00, $00, $00, $ff, $03, $ff, $7f

call_02_68ed_EntityAction_Grenade_Bounce:
; Action $01. Nothing happens until it lands - `ret c` covers the whole flight -
; and then the timer both counts the bounce and picks how high the next one is.
;
; DecrementMiscTimer leaves HL on the timer, so `ld l,[hl]` reads the new count
; straight into the table index. A new horizontal velocity is only chosen when the
; grenade is not already moving sideways, from four candidates by the frame counter
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ret  c                                             ; still in the air
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$02
    jp   z,call_02_72ac_Entity_SetAction               ; out of bounces -> Explode
    ld   l,[hl]                                        ; HL still on MISC_TIMER
    ld   h,$00
    ld   de,.data_02_6924
    add  hl,de
    ld   c,[hl]
    call call_00_28dc_Entity_SetYVelocity
    call call_00_28e6_Entity_CheckIfXVelocityIsZero
    ret  nz                                            ; already drifting
    ld   a,[wDC71_VBlankFrameCounter]
    swap a
    and  a,$03
    ld   l,a
    ld   h,$00
    ld   de,.data_02_6920
    add  hl,de
    ld   c,[hl]
    jp   call_00_28c8_Entity_SetXVelocity
.data_02_6920:
; Bounce directions: +8, -8, +4, -4
    db   $08, $f8, $04, $fc
.data_02_6924:
; Bounce height by bounces remaining - $30 for the first, then $28, then $20, then
; nothing left
    db   $00, $20, $28, $30

call_02_6928_EntityAction_Grenade_Explode:
; Action $02. Drops it eight pixels on the first frame so the blast sits on the
; ground rather than at the sprite's centre, and holds the flash palette for the
; six frames of data_02_7bcd, whose pending action starts the cycle over
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   bc,$0008
    call nz,call_00_250d_Entity_MoveY
    ld   hl,.data_02_6937
    jp   call_00_2c20_Entity_CopyPaletteToBuffer
.data_02_6937:
    db   $00, $00, $1b, $00, $5f, $02, $1f, $1b

call_02_693f_EntityAction_MadBomber_Unk2:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,SPAWN_CHILD_ENTITY_BOMB
    call nz,call_00_3792_EntitySpawn_SpawnChild
call_02_6947_EntityAction_MadBomber_Unk0:
    ld   hl,wDCD0_MadBomberFlag
    ld   a,[hl]
    and  a
    ret  z
    ld   [hl],$00
    call call_00_28a0_Entity_GetCooldownTimer
    and  a
    ret  nz
    ld   a,$04
    call call_02_72ac_Entity_SetAction
    farcall call_03_5671_HandleEntityHit
    ret  

call_02_6965_EntityAction_MadBomber_Unk5:
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    ld   c,$01
    call call_00_21ef_Entity_PlayRemoteSFX
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

call_02_6971_EntityAction_Bomb_Unk0:
    ld   c,ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    call call_00_29b7_Entity_FindSlotByIdAndGetActionId
    ld   a,c
    cp   a,$02
    ld   a,$01
    jp   nz,call_02_72ac_Entity_SetAction
    
call_02_697e: ; unreferenced function?
    ld   a,l
    xor  a,$08
    ld   l,a
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,hl
    ld   de,.data_02_699f
    add  hl,de
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_X
    ldi  a,[hl]
    ld   [de],a
    inc  e
    ldi  a,[hl]
    ld   [de],a
    inc  e
    ldi  a,[hl]
    ld   [de],a
    inc  e
    ld   a,[hl]
    ld   [de],a
    ret  
.data_02_699f:
    db   $50, $00, $1c, $00, $50, $00, $1c, $00        ;; 02:699f ????????
    db   $50, $00, $1c, $00, $50, $00, $19, $00        ;; 02:69a7 ????????

call_02_69af_EntityAction_Bomb_Unk1:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_69CB
    ld   hl,wDCCE_BombCounter
    ld   a,[hl]
    inc  [hl]
    and  a,$07
    ld   l,a
    ld   h,$00
    ld   de,.data_02_69fc
    add  hl,de
    ld   c,[hl]
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$20
    call call_00_28dc_Entity_SetYVelocity
.jr_00_69CB:
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    ld   de,$0068
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jp   c,call_00_24c0_Entity_ApplyXVelocity_Subpixel
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   c,$00
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$00
    call call_00_28dc_Entity_SetYVelocity
    ld   c,TIMER_AMOUNT_BOMB
    call call_00_290d_Entity_SetMiscTimer
    ld   a,SFX_BOMB
    call call_00_0ff5_QueueSFX
    ld   a,$02
    jp   call_02_72ac_Entity_SetAction
.data_02_69fc:    
    db   $10, $f0, $08, $f8, $10, $f0, $04, $fc
    
call_02_6a04_EntityAction_Bomb_Unk2:
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$03
    ret  nz
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$04
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6a13_EntityAction_Bomb_Unk3:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6A38
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,[hl]
    ld   hl,.data_02_6a40
    ld   b,$05
.jr_00_6A26:
    cp   [hl]
    jr   c,.jr_00_6A2E
    inc  hl
    inc  hl
    dec  b
    jr   nz,.jr_00_6A26
.jr_00_6A2E:
    inc  hl
    ld   c,[hl]
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$D8
    call call_00_28dc_Entity_SetYVelocity
.jr_00_6A38:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_24ee_Entity_ApplyYVelocity_Subpixel
    jr   call_02_6a04_EntityAction_Bomb_Unk2
.data_02_6a40:
    db   $17, $26, $35, $17, $44, $0f, $62        ;; 02:6a3f ????????
    db   $00, $71, $f9, $8f, $ea
    
call_02_6a4c_EntityAction_Bomb_Unk4:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   a,SFX_SMALL_BANG
    call nz,call_00_0ff5_QueueSFX
    ld   hl,.data_02_6a89
    call call_00_2c20_Entity_CopyPaletteToBuffer
    call call_00_2a5d_Entity_CheckAnimationEnded
    jp   nz,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ld   c,ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    call call_00_29b7_Entity_FindSlotByIdAndGetActionId
    ld   a,c
    cp   a,$04
    ret  nc
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,[hl]
    sub  a,$60
    add  a,$0A
    cp   a,$14
    ret  nc
    inc  hl
    inc  hl
    ld   a,[hl]
    sub  a,$18
    add  a,$0A
    cp   a,$14
    ret  nc
    ld   a,$01
    ld   [wDCD0_MadBomberFlag],a
    ret  
.data_02_6a89:
    db   $00, $00, $1b, $00, $5f, $02, $1f, $1b
    
call_02_6a91_EntityAction_WaterTowerTank_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6AA1
    ld   bc,$FFD0
    call call_00_250d_Entity_MoveY
    ld   c,$28
    call call_00_294e_Entity_SetHeight
.jr_00_6AA1:
    call call_00_22d4_Entity_CheckTriggerFlag
    ret  z
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSFX
    ld   c,$02
    call call_00_2299_Entity_SetListState
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_6ab4_EntityAction_WaterTowerTank_Unk1:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$10
    call nz,call_00_294e_Entity_SetHeight
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ret  c
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    ld   a,$02
    jp   call_02_72ac_Entity_SetAction

call_02_6acd_EntityAction_Convict_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jp   nz,call_00_2410_Entity_FaceTowardsPlayer
    ret  

call_02_6ad4_EntityAction_Convict_Unk2:    
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,SPAWN_CHILD_ENTITY_CONVICT_PROJECTILE
    jp   nz,call_00_3792_EntitySpawn_SpawnChild
    ret  

call_02_6add_EntityAction_ConvictProjectile_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6AF5
    call call_00_2976_Entity_GetFacingDirection
    ld   c,$20
    cp   a,$00
    jr   z,.jr_00_6AED
    ld   c,$E0
.jr_00_6AED:
    call call_00_28c8_Entity_SetXVelocity
    ld   c,TIMER_AMOUNT_120_FRAMES
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6AF5:
    call call_00_2922_Entity_DecrementMiscTimer
    jp   z,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    cp   a,$3C
    call c,call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    jp   call_00_24c0_Entity_ApplyXVelocity_Subpixel

call_02_6b03_EntityAction_Spider_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6B0E
    call call_00_230f_Entity_GetParameterIntoC
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6B0E:
    ld   bc,$0002
    call call_00_250d_Entity_MoveY
    call call_00_2917_Entity_CheckMiscTimerZero
    sub  a,$02
    ld   [hl],a
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6b20_EntityAction_Spider_Unk1:
    ld   bc,$FFFF
    call call_00_250d_Entity_MoveY
    call call_00_230f_Entity_GetParameterIntoC
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  a
    ld   [hl],a
    cp   c
    ld   a,$02
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6b35_EntityAction_Spider_Unk2:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6B47
    ld   c,$20
    call call_00_28c8_Entity_SetXVelocity
    ld   c,TIMER_AMOUNT_SPIDER
    call call_00_290d_Entity_SetMiscTimer
    call call_00_2410_Entity_FaceTowardsPlayer
.jr_00_6B47:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$00
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6b53_EntityAction_StrayCat_Unk0:
    ld   c,$02
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$28
    ld   a,$01
    jp   c,call_02_72ac_Entity_SetAction
    ret  

call_02_6b69_EntityAction_YellowGoon_Unk0:
    call call_00_2722_Entity_IsPlayerInsideBounds
    jr   z,.jr_00_6B78
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$0E
    jr   c,.jr_00_6B8B
.jr_00_6B78:
    ld   c,$08
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ret  z
    call call_00_2922_Entity_DecrementMiscTimer
    jr   z,.jr_00_6B8B
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction
.jr_00_6B8B:
    call call_00_2917_Entity_CheckMiscTimerZero
    ld   [hl],$03
    call call_00_2722_Entity_IsPlayerInsideBounds
    call nz,call_00_2410_Entity_FaceTowardsPlayer
    ld   a,$02
    jp   call_02_72ac_Entity_SetAction

call_02_6b9b_EntityAction_Rat_Unk0:
    ld   c,$10
    call call_00_28c8_Entity_SetXVelocity
    jp   call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked

call_02_6ba3_EntityAction_ChomperTV_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6BB3
    ld   c,$04
    call call_00_28c8_Entity_SetXVelocity
    call call_00_230f_Entity_GetParameterIntoC
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6BB3:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ld   bc,$0002
    call call_00_250d_Entity_MoveY
    call call_00_2917_Entity_CheckMiscTimerZero
    sub  a,$02
    ld   [hl],a
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6bc8_EntityAction_ChomperTV_Unk2:
    call call_00_2917_Entity_CheckMiscTimerZero
    ld   a,[wDC71_VBlankFrameCounter]
    and  [hl]
    and  a,$3F
    jr   nz,.jr_00_6BDC
    call call_00_2976_Entity_GetFacingDirection
    xor  a,$20
    ld   c,a
    call call_00_2958_Entity_SetFacingDirection
.jr_00_6BDC:
    ld   c,$10
    call call_00_28c8_Entity_SetXVelocity
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked

call_02_6be4_EntityAction_ChomperTV_Unk1:
    call call_00_230f_Entity_GetParameterIntoC
    call call_00_2917_Entity_CheckMiscTimerZero
    cp   c
    ld   a,$00
    jp   z,call_02_72ac_Entity_SetAction
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  a
    ld   [hl],a
    ld   bc,$FFFF
    jp   call_00_250d_Entity_MoveY

call_02_6bfb_EntityAction_CrumblingFloor_Unk0:
    ld   a,[wDC7B_Player_EntityStoodOnLo]
    ld   hl,wDA00_CurrentEntityAddrLo
    cp   [hl]
    ld   a,$01
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6c08_EntityAction_CrumblingFloor_Unk2:
    farcall call_03_57f8_ClearCollisionForEntity
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2780_Entity_IsBelowCameraBottom
    jp   nc,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret  

call_02_6c1d_EntityAction_GextremeSportsElf_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$20
    call nz,call_00_28c8_Entity_SetXVelocity
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$07
    ld   c,$10
    call z,call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_2722_Entity_IsPlayerInsideBounds
    ret  z
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    ret  nz
    ld   a,[wDA11_EntityXDistFromPlayer]
    cp   a,$40
    ld   a,$02
    jp   c,call_02_72ac_Entity_SetAction
    ret  

call_02_6c4c_EntityAction_GextremeSportsElf_Unk2:
    ld   c,$20
    call call_00_28dc_Entity_SetYVelocity
    ld   c,$28
    call call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_28be_Entity_GetXVelocity
    cp   a,$28
    ld   a,$03
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6c64_EntityAction_GextremeSportsElf_Unk3:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   a,$00
    jp   nc,call_02_72ac_Entity_SetAction
    ret  

call_02_6c73_EntityAction_GextremeSportsElf_Unk4:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6C84
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   c,$00
    jr   c,.jr_00_6C81
    ld   c,$01
.jr_00_6C81:
    call call_00_2980_Entity_SetMiscFlags
.jr_00_6C84:
    call call_00_298a_Entity_GetMiscFlags
    jr   z,.jr_00_6CAC
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$07
    ld   c,$10
    call z,call_00_2588_Entity_NudgeXVelocityTowardC
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    ret  z
    call call_00_230f_Entity_GetParameterIntoC
    ld   b,$00
    ld   hl,wDCD5_ElfHealth1
    add  hl,bc
    ld   a,[hl]
    and  a
    ld   a,$00
    jp   nz,call_02_72ac_Entity_SetAction
    ld   a,$05
    jp   call_02_72ac_Entity_SetAction
.jr_00_6CAC:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   c,$01
    call nc,call_00_2980_Entity_SetMiscFlags
    ret 
    
call_02_6cbb_EntityAction_Bird_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6CC6
    call call_00_230f_Entity_GetParameterIntoC
    call call_00_2958_Entity_SetFacingDirection
.jr_00_6CC6:
    call call_00_27f3_Entity_GetInitialYPos
    ld   a,[wD810_PlayerYPosition]
    sub  e
    ld   a,[wD810_PlayerYPosition+1]
    sbc  d
    ret  c
    ld   c,ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
    call call_00_2b10_Entity_FindDuplicateInstance
    ret  nz
    ld   c,SPAWN_CHILD_ENTITY_BIRD_PROJECTILE
    jp   call_00_3792_EntitySpawn_SpawnChild

call_02_6cdd_EntityAction_BirdProjectile_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6CF5
    call call_00_2976_Entity_GetFacingDirection
    ld   c,$14
    cp   a,$00
    jr   z,.jr_00_6CED
    ld   c,$EC
.jr_00_6CED:
    call call_00_28c8_Entity_SetXVelocity
    ld   c,TIMER_AMOUNT_BIRD_PROJECTILE
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6CF5:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_27f3_Entity_GetInitialYPos
    call call_00_2917_Entity_CheckMiscTimerZero
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   bc,.data_02_6d31
    add  hl,bc
    ldi  a,[hl]
    add  e
    ld   e,a
    ld   a,[hl]
    adc  d
    ld   d,a
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    call call_00_2922_Entity_DecrementMiscTimer
    ld   c,$20
    jp   nz,call_00_28dc_Entity_SetYVelocity
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction
.data_02_6d31:
    db   $00, $00, $56, $00, $46, $00        ;; 02:6d2f ????????
    db   $36, $00

call_02_6d39_EntityAction_RockHard_Unk1:
    ret  

call_02_6d3a_EntityAction_RockHard_Unk0:
    ret  

call_02_6d3b_EntityAction_RockHard_Unk2:
    call call_00_2a5d_Entity_CheckAnimationEnded
    ret  z
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSFX
    ld   a,$03
    jp   call_02_72ac_Entity_SetAction

call_02_6d49_EntityAction_RockHard_Unk5:
    call call_00_2a5d_Entity_CheckAnimationEnded
    ld   a,$06
    jp   nz,call_02_72ac_Entity_SetAction
    ret  

call_02_6d52_EntityAction_RockHard_Unk6:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6D5C
    ld   c,TIMER_AMOUNT_120_FRAMES
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6D5C:
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    ld   a,$01
    ld   [wDC65_ProgressFlags_WWGex],a
    ld   hl,wDB6A_WarpFlags
    set  4,[hl]
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

call_02_6d6d_EntityAction_BrainOfOz_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6D82
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  [hl]
    cp   a,$0A
    ld   a,$02
    call z,call_02_72ac_Entity_SetAction
    ld   a,$02
    ld   [wDCDA_BrainOfOzAndRezCounter],a
.jr_00_6D82:
    jp   call_00_233e_Entity_MoveAlongArcTable

call_02_6d85_EntityAction_BrainOfOz_Unk2:
    call call_00_233e_Entity_MoveAlongArcTable
    ld   c,ENTITY_LIZARD_OF_OZ_CANNON
    call call_00_29b7_Entity_FindSlotByIdAndGetActionId
    ld   a,c
    cp   a,$00
    ret  nz
    ld   c,ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    call call_00_29b7_Entity_FindSlotByIdAndGetActionId
    inc  c
    ret  nz
    ld   a,[wDCD1_BrainOfOzFlag]
    and  a
    ret  nz
    ld   hl,wDCDA_BrainOfOzAndRezCounter
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_00_6DA7
    ld   [hl],$02
.jr_00_6DA7:
    ld   l,[hl]
    ld   h,$00
    ld   de,.data_02_6db7
    add  hl,de
    ld   c,[hl]
    call call_00_290d_Entity_SetMiscTimer
    ld   a,$03
    jp   call_02_72ac_Entity_SetAction
.data_02_6db7:
    db   TIMER_AMOUNT_BRAINOFOZ1, TIMER_AMOUNT_BRAINOFOZ2, TIMER_AMOUNT_BRAINOFOZ3

call_02_6dba_EntityAction_BrainOfOz_Unk3:
    call call_00_233e_Entity_MoveAlongArcTable
    call call_00_2922_Entity_DecrementMiscTimer
    jr   nz,.jr_00_6DD2
    ld   c,ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
    call call_00_29ce_Entity_FindSlotById
    ret  z
    ld   a,$01
    ld   [wDCD1_BrainOfOzFlag],a
    ld   a,$02
    jp   call_02_72ac_Entity_SetAction
.jr_00_6DD2:
    and  a,$07
    ld   a,$04
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6dda_EntityAction_BrainOfOz_Unk4:
    jp   call_00_233e_Entity_MoveAlongArcTable

call_02_6ddd_EntityAction_BrainOfOz_Unk5:
    call call_00_233e_Entity_MoveAlongArcTable
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ret  z
    ld   a,SFX_BRAIN_OF_OZ
    call call_00_0ff5_QueueSFX
    ld   c,SPAWN_CHILD_ENTITY_BRAIN_OF_OZ_PROJECTILE
    jp   call_00_3792_EntitySpawn_SpawnChild

call_02_6dee_EntityAction_BrainOfOz_Unk7:
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    ld   de,$0068
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   a,$08
    jp   call_02_72ac_Entity_SetAction

call_02_6e09_EntityAction_BrainOfOz_Unk8:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6E27
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSFX
    ld   hl,.data_6e3c
    call call_00_2c20_Entity_CopyPaletteToBuffer
    call call_00_288a_Entity_SetCollisionTypeNone
    call call_00_2b8b_Entity_MarkDefeated
    call call_00_2c67_Particle_InitBurst
    ld   c,TIMER_AMOUNT_60_FRAMES
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6E27:
    call call_00_2c89_Particle_UpdateBurst
    ret  nz
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    ld   a,$01
    ld   [wDC66_ProgressFlags_LizardOfOz],a
    ld   hl,wDB6A_WarpFlags
    set  4,[hl]
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
.data_6e3c:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f

call_02_6e44_EntityAction_BrainOfOzProjectile_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6E53
    ld   c,$00
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$10
    call call_00_28dc_Entity_SetYVelocity
.jr_00_6E53:
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    ld   a,[wDA12_EntityDirectionRelativeToPlayer]
    cp   a,$20
    jr   z,.jr_00_6E67
    call call_00_28be_Entity_GetXVelocity
    cp   a,$10
    jr   z,.jr_00_6E6F
    inc  [hl]
    jr   .jr_00_6E6F
.jr_00_6E67:
    call call_00_28be_Entity_GetXVelocity
    cp   a,$F0
    jr   z,.jr_00_6E6F
    dec  [hl]
.jr_00_6E6F:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    ld   de,$0088
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jp   nc,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret  

call_02_6e88_EntityAction_Cannon_Unk0:
    ld   hl,wDCD1_BrainOfOzFlag
    bit  0,[hl]
    ret  z
    ld   [hl],$00
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   de,$0078
    ld   [hl],e
    inc  l
    ld   [hl],d
    ld   c,TIMER_AMOUNT_CANNON
    call call_00_290d_Entity_SetMiscTimer
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction

call_02_6ea8_EntityAction_Cannon_Unk2:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   a,SFX_DOOR2
    call nz,call_00_0ff5_QueueSFX
    call call_00_2922_Entity_DecrementMiscTimer
    ld   a,$04
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6eb9_EntityAction_Cannon_Unk3:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ret  z
    ld   c,SPAWN_CHILD_ENTITY_CANNON_PROJECTILE
    call call_00_3792_EntitySpawn_SpawnChild
    ld   a,SFX_CANNON
    jp   call_00_0ff5_QueueSFX

call_02_6ec7_EntityAction_CannonProjectile_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$3C
    call nz,call_00_28dc_Entity_SetYVelocity
    ld   c,ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
    call call_00_29ce_Entity_FindSlotById
    ret  nz
    ld   a,l
    or   a,$01
    ld   l,a
    ld   a,[hl]
    cp   a,$06
    jr   nc,.jr_00_6EFA
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_28f1_Entity_CheckIfYVelocityIsZero
    bit  7,[hl]
    ret  z
    ld   de,$0038
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
.jr_00_6EFA:
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    ld   c,SPAWN_CHILD_ENTITY_CANNON_PROJECTILE_2
    call call_00_3792_EntitySpawn_SpawnChild
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

call_02_6f07_EntityAction_CannonProjectile2_Update:
    call call_00_2a5d_Entity_CheckAnimationEnded
    jp   nz,call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn
    ret  

call_02_6f0e_EntityAction_Unk_None:
    ret  

call_02_6f0f_EntityAction_Rez_Unk0:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ret  z
    ld   c,$20
    call call_00_28c8_Entity_SetXVelocity
    ld   c,$00
    call call_00_28dc_Entity_SetYVelocity
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  [hl]
    cp   a,$0A
    ld   a,$02
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6f29_EntityAction_Rez_Unk2:
    call call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_02_7002_Rez_unk2
    ld   c,$38
    jp   nc,call_00_28dc_Entity_SetYVelocity
    ret  

call_02_6f35_EntityAction_Rez_Unk3:
    call call_02_7002_Rez_unk2
    ld   a,$04
    jp   nc,call_02_72ac_Entity_SetAction
    ret  

call_02_6f3e_EntityAction_Rez_Unk5:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   c,$00
    call nz,call_00_28dc_Entity_SetYVelocity
    call call_02_6FD3_Rez_unk
    ret  nc
    ld   c,TIMER_AMOUNT_0_FRAMES
    call call_00_290d_Entity_SetMiscTimer
    ld   a,$06
    jp   call_02_72ac_Entity_SetAction

call_02_6f54_EntityAction_Rez_Unk6:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ret  z
    call call_00_2917_Entity_CheckMiscTimerZero
    inc  [hl]
    cp   a,$0A
    ld   a,$08
    jp   z,call_02_72ac_Entity_SetAction
    ret  

call_02_6f64_EntityAction_Rez_Unk8:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6F74
    call call_00_2826_Entity_ResetToInitialXPos
    call call_00_27e4_Entity_ResetToInitialYPos
    ld   c,TIMER_AMOUNT_REZ
    call call_00_290d_Entity_SetMiscTimer
.jr_00_6F74:
    call call_00_2917_Entity_CheckMiscTimerZero
    jr   z,.jr_00_6F93
    ld   a,[wDC71_VBlankFrameCounter]
    and  a,$3F
    ret  nz
    call call_00_2922_Entity_DecrementMiscTimer
    jr   z,.jr_00_6F93
    ld   a,[wDCDA_BrainOfOzAndRezCounter]
    ld   c,SPAWN_CHILD_ENTITY_REZ_PROJECTILE
    and  a,$01
    jp   z,call_00_3792_EntitySpawn_SpawnChild
    ld   c,SPAWN_CHILD_ENTITY_REZ_PROJECTILE_2
    jp   call_00_3792_EntitySpawn_SpawnChild
.jr_00_6F93:
    ld   c,ENTITY_CHANNEL_Z_REZ_PROJECTILE
    call call_00_29ce_Entity_FindSlotById
    ld   a,$00
    jp   nz,call_02_72ac_Entity_SetAction
    ret  

call_02_6f9e_EntityAction_Rez_Unk9:
    jp   call_02_6FD3_Rez_unk

call_02_6fa1_EntityAction_Rez_Unk10:
    call call_02_7002_Rez_unk2
    ld   a,$0B
    jp   nc,call_02_72ac_Entity_SetAction
    ret  

call_02_6faa_EntityAction_Rez_Unk11:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_6FBE
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSFX
    ld   c,TIMER_AMOUNT_180_FRAMES
    call call_00_290d_Entity_SetMiscTimer
    ld   c,$30
    call call_00_28dc_Entity_SetYVelocity
.jr_00_6FBE:
    call call_02_7002_Rez_unk2
    ret  c
    call call_00_2922_Entity_DecrementMiscTimer
    ret  nz
    ld   a,$01
    ld   [wDC67_ProgressFlags_ChannelZ],a
    ld   hl,wDB6A_WarpFlags
    set  4,[hl]
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

call_02_6FD3_Rez_unk:
    call call_00_28f1_Entity_CheckIfYVelocityIsZero
    bit  7,a
    jr   nz,.jr_00_6FE0
    cp   a,$20
    ld   a,$20
    jr   nc,.jr_00_6FE3
.jr_00_6FE0:
    ld   a,[hl]
    add  a,$04
.jr_00_6FE3:
    ld   [hl],a
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    ld   de,$0024
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  nc
    push af
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   c,$00
    call call_00_28dc_Entity_SetYVelocity
    pop  af
    ret  

call_02_7002_Rez_unk2:
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    ld   de,$0058
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  hl
    ld   [hl],e
    ret  

call_02_7019_EntityAction_Unk_None:
    ret  

call_02_701a_EntityAction_Meteor_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    ld   a,SFX_METEOR
    call nz,call_00_0ff5_QueueSFX
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_2766_Entity_ClampYToSpawnFloor
    ld   a,$02
    jp   nc,call_02_72ac_Entity_SetAction
    ret  

call_02_702e_EntityAction_RezProjectile_Update:
    call call_00_29f5_Entity_IsFirstFrameOfActionAndClear
    jr   z,.jr_00_7056
    ld   hl,wDCDA_BrainOfOzAndRezCounter
    ld   a,[hl]
    inc  [hl]
    and  a,$07
    push af
    ld   l,a
    ld   h,$00
    add  hl,hl
    ld   de,.data_02_707f
    add  hl,de
    pop  af
    ld   c,[hl]
    inc  hl
    push bc
    ld   c,[hl]
    and  a,$01
    jr   z,.jr_00_704F
    xor  a
    sub  [hl]
    ld   c,a
.jr_00_704F:
    call call_00_28c8_Entity_SetXVelocity
    pop  bc
    call call_00_28dc_Entity_SetYVelocity
.jr_00_7056:
    call call_00_24c0_Entity_ApplyXVelocity_Subpixel
    call call_00_244a_Entity_ApplyGravityAndMoveY_Clamped
    call call_00_28f1_Entity_CheckIfYVelocityIsZero
    bit  7,a
    ret  z
    ld   de,$0070
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  hl
    ld   [hl],e
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    ld   a,$01
    jp   call_02_72ac_Entity_SetAction
.data_02_707f:
    db   $30, $28, $30, $28, $20, $30, $20, $30        ;; 02:707f ????????
    db   $40, $10, $40, $10, $50, $08, $50, $08        ;; 02:7087 ????????
