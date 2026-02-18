call_02_582e_ObjectAction_None:
    ret                                                ;; 02:582e $c9

call_02_582f_ObjectAction_DestroyWithoutParticles:
    call call_00_288c_Object_ClearCollisionType
    call call_00_2b8b_HandleObjectFlag6ClearOrInit
    call call_00_2a5d_Object_Check5Flag2
    jp   nz,call_00_2bbe_SpawnCollectibleObject
    ret  

call_02_583c_ObjectAction_Destroy:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:583c $cd $f5 $29
    jr   Z, .jr_02_5850                                ;; 02:583f $28 $0f
    ld   HL, .data_02_5857_ParticlesPalette                             ;; 02:5841 $21 $57 $58
    call call_00_2c20_Object_CopyPaletteToBuffer                                  ;; 02:5844 $cd $20 $2c
    call call_00_288c_Object_ClearCollisionType                                  ;; 02:5847 $cd $8a $28
    call call_00_2b8b_HandleObjectFlag6ClearOrInit                                  ;; 02:584a $cd $8b $2b
    call call_00_2c67_Particle_InitBurst                                  ;; 02:584d $cd $67 $2c
.jr_02_5850:
    call call_00_2c89_Particle_UpdateBurst                                  ;; 02:5850 $cd $89 $2c
    jp   Z, call_00_2bbe_SpawnCollectibleObject                                 ;; 02:5853 $ca $be $2b
    ret                                                ;; 02:5856 $c9
.data_02_5857_ParticlesPalette:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f        ;; 02:5857 ........

call_02_585f_ObjectAction_MovePlatformHorizontally:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,label586E
    ld   c,$80
    call call_00_2980_Object_SetExtraFlags
    ld   c,$F0
    call call_00_290d_Object_SetTimer1A
label586E:
    call call_00_298a_Object_GetExtraFlags
    bit  7,[hl]
    jr   z,label588C
    ld   c,$00
    call call_00_28c8_Object_SetXVelocity
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    call call_00_298a_Object_GetExtraFlags
    and  a,$7F
    xor  a,$40
    ld   [hl],a
    call call_00_230f_ResolveObjectListIndex
    jp   call_00_290d_Object_SetTimer1A
label588C:
    ld   c,$01
    call call_00_28c8_Object_SetXVelocity
    call call_00_298a_Object_GetExtraFlags
    ld   bc,$0001
    bit  6,[hl]
    jr   nz,label589E
    ld   bc,$FFFF
label589E:
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ld   a,c
    add  [hl]
    ldi  [hl],a
    ld   a,b
    adc  [hl]
    ld   [hl],a
    call call_00_26c9_Object_InfluencePlayerX
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    call call_00_298a_Object_GetExtraFlags
    set  7,[hl]
    ld   c,$78
    jp   call_00_290d_Object_SetTimer1A

call_02_58bd_ObjectAction_MovePlatformVertically:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,label58CC
    ld   c,$80
    call call_00_2980_Object_SetExtraFlags
    ld   c,$F0
    call call_00_290d_Object_SetTimer1A
label58CC:
    call call_00_298a_Object_GetExtraFlags
    bit  7,[hl]
    jr   z,label58EA
    ld   c,$00
    call call_00_28dc_Object_SetYVelocity
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    call call_00_298a_Object_GetExtraFlags
    and  a,$7F
    xor  a,$40
    ld   [hl],a
    call call_00_230f_ResolveObjectListIndex
    jp   call_00_290d_Object_SetTimer1A
label58EA:
    ld   c,$01
    call call_00_28dc_Object_SetYVelocity
    call call_00_298a_Object_GetExtraFlags
    ld   bc,$0001
    bit  6,[hl]
    jr   nz,label58FC
    ld   bc,$FFFF
label58FC:
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ld   a,c
    add  [hl]
    ldi  [hl],a
    ld   a,b
    adc  [hl]
    ld   [hl],a
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    call call_00_298a_Object_GetExtraFlags
    set  7,[hl]
    ld   c,$78
    jp   call_00_290d_Object_SetTimer1A

call_02_5918:
    ld   a,[wDC71_FrameCounter]
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
    call call_00_2835_Object_GetInitialXPos
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ld   a,[bc]
    add  e
    ldi  [hl],a
    inc  bc
    ld   a,[bc]
    adc  d
    ld   [hl],a
    inc  bc
    call call_00_27f3_Object_GetInitialYPos
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
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

call_02_598f_ObjectAction_FlyTV_SpawnFly:
    call call_02_59D2_FlyTV_unk
    push bc
    call call_00_2b10_Object_FindDuplicateInstance
    pop  bc
    ld   c,b
    call z,call_00_3792_PrepareRelativeObjectSpawn
    ld   a,$03
    jp   call_02_72ac_SetupNewAction
    
    db   $00, $04, $01, $05, $02, $06, $03        ;; 02:599f ????????
    db   $07, $04, $08

call_02_59aa_ObjectAction_FlyTV_Reset:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$78
    call nz,call_00_290d_Object_SetTimer1A
    call call_02_59D2_FlyTV_unk
    call call_00_2b10_Object_FindDuplicateInstance
    ret  nz
    call call_00_230f_ResolveObjectListIndex
    ld   a,c
    and  a
    ret  z
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    ld   c,$01
    call call_00_28aa_Object_Set16
    ld   c,$00
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$04
    jp   call_02_72ac_SetupNewAction

call_02_59D2_FlyTV_unk:
    call call_00_293a_Object_GetId
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
    
call_02_59ed:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,label5A00
    call call_00_2976_Object_GetFacingDirection
    ld   c,$D0
    and  a,$20
    jr   nz,label59FD
    ld   c,$30
label59FD:
    call call_00_28c8_Object_SetXVelocity
label5A00:
    call call_00_24c0_Object_IntegrateXVelocity
    ret  

call_02_5a04_ObjectAction_TVButton_unk:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5a04 $cd $f5 $29
    jr   NZ, call_02_5a83_ObjectAction_TVButton_unk4                                ;; 02:5a07 $20 $7a
    ld   C, $00                                        ;; 02:5a09 $0e $00
    call call_00_22b1_HandleObjectStateChange                                  ;; 02:5a0b $cd $b1 $22
    ld   HL, .data_02_5a14                             ;; 02:5a0e $21 $14 $5a
    jp   call_00_2c20_Object_CopyPaletteToBuffer                                  ;; 02:5a11 $c3 $20 $2c
.data_02_5a14:
    db   $00, $00, $00, $00, $73, $4e, $1f, $00        ;; 02:5a14 ........

call_02_5a1c_ObjectAction_TVButton_unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5a1c $cd $f5 $29
    jr   NZ, call_02_5a83_ObjectAction_TVButton_unk4                                ;; 02:5a1f $20 $62
    call call_02_5a75_ObjectAction_TVButton_unk3                                  ;; 02:5a21 $cd $75 $5a
    ld   A, [wDC7B]                                    ;; 02:5a24 $fa $7b $dc
    ld   HL, wDA00_CurrentObjectAddrLo                                     ;; 02:5a27 $21 $00 $da
    cp   A, [HL]                                       ;; 02:5a2a $be
    ret  NZ                                            ;; 02:5a2b $c0
    ld   A, $02                                        ;; 02:5a2c $3e $02
    call call_02_72ac_SetupNewAction                                  ;; 02:5a2e $cd $ac $72
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:5a31 $fa $6c $db
    cp   A, $07                                        ;; 02:5a34 $fe $07
    ld   A, $2c                                        ;; 02:5a36 $3e $2c
    jr   Z, .jr_02_5a45                                ;; 02:5a38 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 02:5a3a $fa $6c $db
    cp   A, $08                                        ;; 02:5a3d $fe $08
    ld   A, $39                                        ;; 02:5a3f $3e $39
    jr   Z, .jr_02_5a45                                ;; 02:5a41 $28 $02
    ld   A, $0c                                        ;; 02:5a43 $3e $0c
.jr_02_5a45:
    call call_02_54f9_SwitchPlayerAction                                  ;; 02:5a45 $cd $f9 $54
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5a48 $cd $0f $23
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5a4b $fa $1e $dc
    and  A, A                                          ;; 02:5a4e $a7
    jr   Z, .jr_02_5a6a                                ;; 02:5a4f $28 $19
    push BC                                            ;; 02:5a51 $c5
    ld   B, $00                                        ;; 02:5a52 $06 $00
    ld   HL, .data_02_5a71                             ;; 02:5a54 $21 $71 $5a
    add  HL, BC                                        ;; 02:5a57 $09
    ld   C, [HL]                                       ;; 02:5a58 $4e
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 02:5a59 $21 $1e $dc
    ld   L, [HL]                                       ;; 02:5a5c $6e
    ld   H, $00                                        ;; 02:5a5d $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 02:5a5f $11 $5c $dc
    add  HL, DE                                        ;; 02:5a62 $19
    ld   A, [HL]                                       ;; 02:5a63 $7e
    or   A, C                                          ;; 02:5a64 $b1
    ld   [HL], A                                       ;; 02:5a65 $77
    pop  BC                                            ;; 02:5a66 $c1
    jp   call_00_2260_FindAndFlagObject_TVRemote                                    ;; 02:5a67 $c3 $60 $22
.jr_02_5a6a:
    ld   HL, wDC5B                                     ;; 02:5a6a $21 $5b $dc
    ld   [HL], C                                       ;; 02:5a6d $71
    jp   call_00_2260_FindAndFlagObject_TVRemote                                    ;; 02:5a6e $c3 $60 $22
.data_02_5a71:
    db   $00, $01, $02, $04                            ;; 02:5a71 ????

call_02_5a75_ObjectAction_TVButton_unk3:
    ld   HL, .data_02_5a7b                             ;; 02:5a75 $21 $7b $5a
    jp   call_00_2c20_Object_CopyPaletteToBuffer                                  ;; 02:5a78 $c3 $20 $2c
.data_02_5a7b:
    db   $00, $00, $00, $00, $73, $4e, $e0, $03        ;; 02:5a7b ........

call_02_5a83_ObjectAction_TVButton_unk4:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5a83 $fa $1e $dc
    and  A, A                                          ;; 02:5a86 $a7
    ret  NZ                                            ;; 02:5a87 $c0
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5a88 $cd $0f $23
    ld   B, $00                                        ;; 02:5a8b $06 $00
    ld   HL, $b19                                      ;; 02:5a8d $21 $19 $0b
    add  HL, BC                                        ;; 02:5a90 $09
    bit  7, [HL]                                       ;; 02:5a91 $cb $7e
    jr   Z, .jr_02_5aaa                                ;; 02:5a93 $28 $15
    push HL                                            ;; 02:5a95 $e5
    farcall call_01_4ae7_CountLevelsWithFlag4
    pop  HL                                            ;; 02:5aa1 $e1
    ld   C, [HL]                                       ;; 02:5aa2 $4e
    res  7, C                                          ;; 02:5aa3 $cb $b9
    cp   A, C                                          ;; 02:5aa5 $b9
    jr   C, .jr_02_5aba                                ;; 02:5aa6 $38 $12
    jr   .jr_02_5aca                                   ;; 02:5aa8 $18 $20
.jr_02_5aaa:
    push HL                                            ;; 02:5aaa $e5
    farcall call_01_4ab9_CountSetBitsInFlags
    pop  HL                                            ;; 02:5ab6 $e1
    cp   A, [HL]                                       ;; 02:5ab7 $be
    jr   NC, .jr_02_5aca                               ;; 02:5ab8 $30 $10
.jr_02_5aba:
    call call_00_2962_Object_GetActionId                                  ;; 02:5aba $cd $62 $29
    cp   A, $00                                        ;; 02:5abd $fe $00
    ret  Z                                             ;; 02:5abf $c8
    ld   C, $00                                        ;; 02:5ac0 $0e $00
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 02:5ac2 $cd $99 $22
    ld   A, $00                                        ;; 02:5ac5 $3e $00
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5ac7 $c3 $ac $72
.jr_02_5aca:
    call call_00_2962_Object_GetActionId                                  ;; 02:5aca $cd $62 $29
    cp   A, $01                                        ;; 02:5acd $fe $01
    ret  Z                                             ;; 02:5acf $c8
    ld   C, $01                                        ;; 02:5ad0 $0e $01
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 02:5ad2 $cd $99 $22
    ld   A, $01                                        ;; 02:5ad5 $3e $01
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5ad7 $c3 $ac $72

call_02_5ada_ObjectAction_TVRemote_unk:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5ada $cd $f5 $29
    jr   NZ, call_02_5af8_ObjectAction_TVRemote_unk4                                ;; 02:5add $20 $19
    ld   C, $00                                        ;; 02:5adf $0e $00
    jp   call_00_22b1_HandleObjectStateChange                                  ;; 02:5ae1 $c3 $b1 $22

call_02_5ae4_ObjectAction_TVRemote_unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5ae4 $cd $f5 $29
    jr   NZ, call_02_5af8_ObjectAction_TVRemote_unk4                                ;; 02:5ae7 $20 $0f
    ld   C, $01                                        ;; 02:5ae9 $0e $01
    jp   call_00_22b1_HandleObjectStateChange         

call_02_5aee_ObjectAction_TVRemote_unk3:    ;; 02:5aeb $c3 $b1 $22
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   nz,call_02_5af8_ObjectAction_TVRemote_unk4
    ld   c,$02
    jp   call_00_22b1_HandleObjectStateChange

call_02_5af8_ObjectAction_TVRemote_unk4:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5af8 $fa $1e $dc
    and  A, A                                          ;; 02:5afb $a7
    ret  NZ                                            ;; 02:5afc $c0
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5afd $cd $0f $23
    ld   B, $00                                        ;; 02:5b00 $06 $00
    ld   HL, $b19                                      ;; 02:5b02 $21 $19 $0b
    add  HL, BC                                        ;; 02:5b05 $09
    bit  7, [HL]                                       ;; 02:5b06 $cb $7e
    jr   Z, .jr_02_5b1f                                ;; 02:5b08 $28 $15
    push HL                                            ;; 02:5b0a $e5
    farcall call_01_4ae7_CountLevelsWithFlag4
    pop  HL                                            ;; 02:5b16 $e1
    ld   C, [HL]                                       ;; 02:5b17 $4e
    res  7, C                                          ;; 02:5b18 $cb $b9
    cp   A, C                                          ;; 02:5b1a $b9
    jr   C, .jr_02_5b2f                                ;; 02:5b1b $38 $12
    jr   .jr_02_5b6e                                   ;; 02:5b1d $18 $4f
.jr_02_5b1f:
    push HL                                            ;; 02:5b1f $e5
    farcall call_01_4ab9_CountSetBitsInFlags
    pop  HL                                            ;; 02:5b2b $e1
    cp   A, [HL]                                       ;; 02:5b2c $be
    jr   NC, .jr_02_5b6e                               ;; 02:5b2d $30 $3f
.jr_02_5b2f:
    call call_00_2962_Object_GetActionId                                  ;; 02:5b2f $cd $62 $29
    cp   A, $03                                        ;; 02:5b32 $fe $03
    jr   Z, .jr_02_5b40                                ;; 02:5b34 $28 $0a
    ld   C, $03                                        ;; 02:5b36 $0e $03
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 02:5b38 $cd $99 $22
    ld   A, $03                                        ;; 02:5b3b $3e $03
    call call_02_72ac_SetupNewAction                                  ;; 02:5b3d $cd $ac $72
.jr_02_5b40:
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5b40 $cd $0f $23
    ld   B, $00                                        ;; 02:5b43 $06 $00
    ld   HL, .data_02_5b7e                             ;; 02:5b45 $21 $7e $5b
    add  HL, BC                                        ;; 02:5b48 $09
    ld   C, [HL]                                       ;; 02:5b49 $4e
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 02:5b4a $26 $d8
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:5b4c $fa $00 $da
    or   A, OBJECT_SPRITE_ID_OFFSET                                        ;; 02:5b4f $f6 $0a
    ld   L, A                                          ;; 02:5b51 $6f
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
    jp   C, call_00_2c20_Object_CopyPaletteToBuffer                               ;; 02:5b65 $da $20 $2c
    ld   HL, .data_02_5b92                             ;; 02:5b68 $21 $92 $5b
    jp   call_00_2c20_Object_CopyPaletteToBuffer                                  ;; 02:5b6b $c3 $20 $2c
.jr_02_5b6e:
    call call_00_2962_Object_GetActionId                                  ;; 02:5b6e $cd $62 $29
    cp   A, $01                                        ;; 02:5b71 $fe $01
    ret  Z                                             ;; 02:5b73 $c8
    ld   C, $01                                        ;; 02:5b74 $0e $01
    call call_00_2299_SetObjectStatusLowNibble                                  ;; 02:5b76 $cd $99 $22
    ld   A, $01                                        ;; 02:5b79 $3e $01
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5b7b $c3 $ac $72
.data_02_5b7e:
    db   $00, $00, $01, $02, $03, $05, $07, $09        ;; 02:5b7e ?.......
    db   $0a, $04, $06, $08                            ;; 02:5b86 ....
.data_02_5b8a:
    db   $00, $00, $00, $00, $ff, $7f, $1f, $00        ;; 02:5b8a ........
.data_02_5b92:
    db   $00, $00, $00, $00, $1f, $00, $ff, $03        ;; 02:5b92 ........

call_02_5b9a_ObjectAction_UpdateGoalCounter:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5b9a $cd $f5 $29
    jr   Z, .jr_02_5ba9                                ;; 02:5b9d $28 $0a
    ld   C, $30                                        ;; 02:5b9f $0e $30
    call call_00_28dc_Object_SetYVelocity                                  ;; 02:5ba1 $cd $dc $28
    ld   C, $3c                                        ;; 02:5ba4 $0e $3c
    call call_00_290d_Object_SetTimer1A                                  ;; 02:5ba6 $cd $0d $29
.jr_02_5ba9:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped                                  ;; 02:5ba9 $cd $4a $24
    call call_00_2922_Object_Timer1ACountdown                                  ;; 02:5bac $cd $22 $29
    jp   Z, call_00_2b80_ClearObjectMemoryEntry                               ;; 02:5baf $ca $80 $2b
    ret                                                ;; 02:5bb2 $c9

call_02_5bb3_ObjectAction_UpdateBonusStageTimer:
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
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

call_02_5bd4_ObjectAction_FreestandingRemote_unk0:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 02:5bd4 $fa $1e $dc
    and  A, A                                          ;; 02:5bd7 $a7
    jr   Z, .jr_02_5be4                                ;; 02:5bd8 $28 $0a
    ld   A, [wDCD2_FreestandingRemoteHitFlags]                                    ;; 02:5bda $fa $d2 $dc
    and  A, A                                          ;; 02:5bdd $a7
    ld   A, $01                                        ;; 02:5bde $3e $01
    jp   NZ, call_02_72ac_SetupNewAction                              ;; 02:5be0 $c2 $ac $72
    ret                                                ;; 02:5be3 $c9
.jr_02_5be4:
    ld   HL, wDC5C_ProgressFlags                                     ;; 02:5be4 $21 $5c $dc
    bit  0, [HL]                                       ;; 02:5be7 $cb $46
    ld   A, $01                                        ;; 02:5be9 $3e $01
    jp   Z, call_02_72ac_SetupNewAction                               ;; 02:5beb $ca $ac $72
    ret                                                ;; 02:5bee $c9

call_02_5bef_ObjectAction_FreestandingRemote_unk1:
    ld   A, [wDCD2_FreestandingRemoteHitFlags]                                    ;; 02:5bef $fa $d2 $dc
    cp   A, $81                                        ;; 02:5bf2 $fe $81
    ld   A, $02                                        ;; 02:5bf4 $3e $02
    jp   Z, call_02_72ac_SetupNewAction                               ;; 02:5bf6 $ca $ac $72
    ret                                                ;; 02:5bf9 $c9

call_02_5bfa_ObjectAction_FreestandingRemote_unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5bfa $cd $f5 $29
    jr   Z, .jr_02_5c23                                ;; 02:5bfd $28 $24
    ld   A, SFX_REMOTE                                        ;; 02:5bff $3e $1e
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:5c01 $cd $f5 $0f
    ld   HL, .data_02_5c3b                             ;; 02:5c04 $21 $3b $5c
    call call_00_2c20_Object_CopyPaletteToBuffer                                  ;; 02:5c07 $cd $20 $2c
    call call_00_288c_Object_ClearCollisionType                                  ;; 02:5c0a $cd $8a $28
    call call_00_2b8b_HandleObjectFlag6ClearOrInit                                  ;; 02:5c0d $cd $8b $2b
    call call_00_2c67_Particle_InitBurst                                  ;; 02:5c10 $cd $67 $2c
    ld   C, $3c                                        ;; 02:5c13 $0e $3c
    call call_00_290d_Object_SetTimer1A                                  ;; 02:5c15 $cd $0d $29
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5c18 $cd $0f $23
    ld   B, $00                                        ;; 02:5c1b $06 $00
    ld   HL, wDC5C_ProgressFlags                                     ;; 02:5c1d $21 $5c $dc
    add  HL, BC                                        ;; 02:5c20 $09
    set  0, [HL]                                       ;; 02:5c21 $cb $c6
.jr_02_5c23:
    call call_00_2c89_Particle_UpdateBurst                                  ;; 02:5c23 $cd $89 $2c
    ret  NZ                                            ;; 02:5c26 $c0
    call call_00_2922_Object_Timer1ACountdown                                  ;; 02:5c27 $cd $22 $29
    ret  NZ                                            ;; 02:5c2a $c0
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5c2b $cd $0f $23
    inc  C                                             ;; 02:5c2e $0c
    dec  C                                             ;; 02:5c2f $0d
    jp   Z, call_00_2b7a_ClearObjectThenJump                                 ;; 02:5c30 $ca $7a $2b
    ld   HL, wDB6A                                     ;; 02:5c33 $21 $6a $db
    set  4, [HL]                                       ;; 02:5c36 $cb $e6
    jp   call_00_2b7a_ClearObjectThenJump                                    ;; 02:5c38 $c3 $7a $2b
.data_02_5c3b:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f        ;; 02:5c3b ........

call_02_5c43_ObjectAction_EvilSanta_Init:
    ld   A, $03                                        ;; 02:5c43 $3e $03
    ld   [wDCC4_EvilSantaHealth], A                                    ;; 02:5c45 $ea $c4 $dc
    call call_02_5d02_LoadEvilSantaPalette                                  ;; 02:5c48 $cd $02 $5d
    ld   A, $01                                        ;; 02:5c4b $3e $01
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5c4d $c3 $ac $72

call_02_5c50_ObjectAction_EvilSanta_Jumping:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5c50 $cd $f5 $29
    jr   Z, .jr_02_5c62                                ;; 02:5c53 $28 $0d
    call call_02_5d02_LoadEvilSantaPalette                                  ;; 02:5c55 $cd $02 $5d
    ld   C, $20                                        ;; 02:5c58 $0e $20
    call call_00_28c8_Object_SetXVelocity                                  ;; 02:5c5a $cd $c8 $28
    ld   C, $28                                        ;; 02:5c5d $0e $28
    call call_00_28dc_Object_SetYVelocity                                  ;; 02:5c5f $cd $dc $28
.jr_02_5c62:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5c62 $cd $1c $25
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped                                  ;; 02:5c65 $cd $4a $24
    call call_00_2766_Object_ResetYIfAboveStart                                  ;; 02:5c68 $cd $66 $27
    ret  C                                             ;; 02:5c6b $d8
    call call_00_299f_Object_TurnAround                                  ;; 02:5c6c $cd $9f $29
    ld   A, $02                                        ;; 02:5c6f $3e $02
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5c71 $c3 $ac $72

call_02_5c74_ObjectAction_EvilSanta_PrepareThrow:
    call call_00_2a5d_Object_Check5Flag2                                  ;; 02:5c74 $cd $5d $2a
    ret  Z                                             ;; 02:5c77 $c8
    ld   C, $05                                        ;; 02:5c78 $0e $05
    call call_00_3792_PrepareRelativeObjectSpawn                                  ;; 02:5c7a $cd $92 $37
    ld   A, $03                                        ;; 02:5c7d $3e $03
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5c7f $c3 $ac $72

call_02_5c82_ObjectAction_EvilSanta_Stand:
    ld   A, [wDCDB_EvilSantaHitByProjectileFlag]                                    ;; 02:5c82 $fa $db $dc
    and  A, A                                          ;; 02:5c85 $a7
    jr   NZ, .jr_02_5c93                               ;; 02:5c86 $20 $0b
    ld   C, $1f                                        ;; 02:5c88 $0e $1f
    call call_00_2b10_Object_FindDuplicateInstance                                  ;; 02:5c8a $cd $10 $2b
    ld   A, $01                                        ;; 02:5c8d $3e $01
    jp   Z, call_02_72ac_SetupNewAction                               ;; 02:5c8f $ca $ac $72
    ret                                                ;; 02:5c92 $c9
.jr_02_5c93:
    xor  A, A                                          ;; 02:5c93 $af
    ld   [wDCDB_EvilSantaHitByProjectileFlag], A                                    ;; 02:5c94 $ea $db $dc
    ld   HL, wDCC4_EvilSantaHealth                                     ;; 02:5c97 $21 $c4 $dc
    dec  [HL]                                          ;; 02:5c9a $35
    ld   A, $05                                        ;; 02:5c9b $3e $05
    jp   NZ, call_02_72ac_SetupNewAction                              ;; 02:5c9d $c2 $ac $72
    ld   A, $06                                        ;; 02:5ca0 $3e $06
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5ca2 $c3 $ac $72

call_02_5ca5_ObjectAction_EvilSanta_Damaged:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   a,SFX_SMALL_BANG
    call nz,call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,[wDC71_FrameCounter]
    and  a,$0F
    cp   a,$0C
    ld   hl,.data_02_5cc8_EvilSantaDamagedPalette2
    jp   c,call_00_2c20_Object_CopyPaletteToBuffer
    ld   hl,.data_02_5cc0_EvilSantaDamagedPalette1
    jp   call_00_2c20_Object_CopyPaletteToBuffer
.data_02_5cc0_EvilSantaDamagedPalette1:
    db   $00, $00, $00, $00, $1f, $00, $ff, $7f
.data_02_5cc8_EvilSantaDamagedPalette2:
    db   $00, $00, $84, $10, $08, $21, $8c, $31
    
call_02_5cd0_ObjectAction_EvilSanta_Death:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,label5CF0
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    call call_02_5d02_LoadEvilSantaPalette
    call call_00_2976_Object_GetFacingDirection
    ld   c,$F2
    bit  5,a
    jr   nz,label5CE8
    ld   c,$0E
label5CE8:
    call call_00_28c8_Object_SetXVelocity
    ld   c,$05
    call call_00_28dc_Object_SetYVelocity
label5CF0:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_24ee_Object_IntegrateYVelocity
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    ld   c,$03
    call call_00_21ef_PlayRemoteSpawnSFX
    jp   call_00_2b7a_ClearObjectThenJump

call_02_5d02_LoadEvilSantaPalette:
    ld   HL, .data_02_5d08_EvilSantaPalette                             ;; 02:5d02 $21 $08 $5d
    jp   call_00_2c20_Object_CopyPaletteToBuffer                                  ;; 02:5d05 $c3 $20 $2c
.data_02_5d08_EvilSantaPalette:
    db   $00, $00, $00, $00, $1f, $00, $ff, $7f        ;; 02:5d08 ........

call_02_5d10_ObjectAction_EvilSantaProjectile_Init:
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 02:5d10 $26 $d8
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:5d12 $fa $00 $da
    or   A, OBJECT_XPOS_OFFSET                                        ;; 02:5d15 $f6 $0e
    ld   L, A                                          ;; 02:5d17 $6f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 02:5d18 $fa $0e $d8
    sub  A, [HL]                                       ;; 02:5d1b $96
    ld   E, A                                          ;; 02:5d1c $5f
    inc  HL                                            ;; 02:5d1d $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 02:5d1e $fa $0f $d8
    sbc  A, [HL]                                       ;; 02:5d21 $9e
    ld   D, A                                          ;; 02:5d22 $57
    push AF                                            ;; 02:5d23 $f5
    jr   NC, .jr_02_5d2d                               ;; 02:5d24 $30 $07
    xor  A, A                                          ;; 02:5d26 $af
    sub  A, E                                          ;; 02:5d27 $93
    ld   E, A                                          ;; 02:5d28 $5f
    ld   A, $00                                        ;; 02:5d29 $3e $00
    sbc  A, D                                          ;; 02:5d2b $9a
    ld   D, A                                          ;; 02:5d2c $57
.jr_02_5d2d:
    ld   A, D                                          ;; 02:5d2d $7a
    and  A, A                                          ;; 02:5d2e $a7
    jr   NZ, .jr_02_5d36                               ;; 02:5d2f $20 $05
    ld   A, E                                          ;; 02:5d31 $7b
    cp   A, $a0                                        ;; 02:5d32 $fe $a0
    jr   C, .jr_02_5d38                                ;; 02:5d34 $38 $02
.jr_02_5d36:
    ld   A, $a0                                        ;; 02:5d36 $3e $a0
.jr_02_5d38:
    srl  A                                             ;; 02:5d38 $cb $3f
    srl  A                                             ;; 02:5d3a $cb $3f
    ld   L, A                                          ;; 02:5d3c $6f
    ld   H, $00                                        ;; 02:5d3d $26 $00
    ld   DE, .data_02_5d57                             ;; 02:5d3f $11 $57 $5d
    add  HL, DE                                        ;; 02:5d42 $19
    pop  AF                                            ;; 02:5d43 $f1
    ld   A, [HL]                                       ;; 02:5d44 $7e
    jr   NC, .jr_02_5d49                               ;; 02:5d45 $30 $02
    cpl                                                ;; 02:5d47 $2f
    inc  A                                             ;; 02:5d48 $3c
.jr_02_5d49:
    ld   C, A                                          ;; 02:5d49 $4f
    call call_00_28c8_Object_SetXVelocity                                  ;; 02:5d4a $cd $c8 $28
    ld   C, $10                                        ;; 02:5d4d $0e $10
    call call_00_28dc_Object_SetYVelocity                                  ;; 02:5d4f $cd $dc $28
    ld   A, $01                                        ;; 02:5d52 $3e $01
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5d54 $c3 $ac $72
.data_02_5d57:
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 02:5d57 ??.....?
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10        ;; 02:5d5f ??.?.??.
    db   $11, $12, $13, $14, $15, $16, $17, $18        ;; 02:5d67 ?....???
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21        ;; 02:5d6f ?????.?.
    db   $22, $23, $24, $25, $27, $28, $29, $2a        ;; 02:5d77 ???.????
    db   $2b                                           ;; 02:5d7f ?

call_02_5d80_ObjectAction_EvilSantaProjectile_UpdateTrajectory:
    call call_00_24c0_Object_IntegrateXVelocity                                  ;; 02:5d80 $cd $c0 $24
    call call_00_24ee_Object_IntegrateYVelocity                                  ;; 02:5d83 $cd $ee $24
    call call_00_28d2_Object_GetYVelocity                                  ;; 02:5d86 $cd $d2 $28
    ld   C, A                                          ;; 02:5d89 $4f
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 02:5d8a $26 $d8
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:5d8c $fa $00 $da
    or   A, OBJECT_YPOS_OFFSET                                        ;; 02:5d8f $f6 $10
    ld   L, A                                          ;; 02:5d91 $6f
    ld   A, [HL]                                       ;; 02:5d92 $7e
    sub  A, $88                                        ;; 02:5d93 $d6 $88
    jp   NC, call_00_2b80_ClearObjectMemoryEntry                              ;; 02:5d95 $d2 $80 $2b
    bit  7, C                                          ;; 02:5d98 $cb $79
    jr   Z, .jr_02_5db5                                ;; 02:5d9a $28 $19
    ld   C, $01                                        ;; 02:5d9c $0e $01
    ld   A, [HL]                                       ;; 02:5d9e $7e
    sub  A, $25                                        ;; 02:5d9f $d6 $25
    jr   C, .jr_02_5dcd                                ;; 02:5da1 $38 $2a
    cp   A, $09                                        ;; 02:5da3 $fe $09
    jr   Z, .jr_02_5dc9                                ;; 02:5da5 $28 $22
    ld   C, $02                                        ;; 02:5da7 $0e $02
    cp   A, $1d                                        ;; 02:5da9 $fe $1d
    jr   Z, .jr_02_5dc9                                ;; 02:5dab $28 $1c
    ld   C, $03                                        ;; 02:5dad $0e $03
    cp   A, $3b                                        ;; 02:5daf $fe $3b
    ret  NZ                                            ;; 02:5db1 $c0
    jr   Z, .jr_02_5dc9                                ;; 02:5db2 $28 $15
    ret                                                ;; 02:5db4 $c9
.jr_02_5db5:
    ld   C, $02                                        ;; 02:5db5 $0e $02
    ld   A, [HL]                                       ;; 02:5db7 $7e
    sub  A, $25                                        ;; 02:5db8 $d6 $25
    cp   A, $0a                                        ;; 02:5dba $fe $0a
    jr   Z, .jr_02_5dc9                                ;; 02:5dbc $28 $0b
    ld   C, $03                                        ;; 02:5dbe $0e $03
    cp   A, $1e                                        ;; 02:5dc0 $fe $1e
    jr   Z, .jr_02_5dc9                                ;; 02:5dc2 $28 $05
    cp   A, $3c                                        ;; 02:5dc4 $fe $3c
    ret  NZ                                            ;; 02:5dc6 $c0
    ld   C, $04                                        ;; 02:5dc7 $0e $04
.jr_02_5dc9:
    ld   A, C                                          ;; 02:5dc9 $79
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5dca $c3 $ac $72
.jr_02_5dcd:
    ld   A, $01                                        ;; 02:5dcd $3e $01
    ld   [wDCDB_EvilSantaHitByProjectileFlag], A                                    ;; 02:5dcf $ea $db $dc
    ld   A, $05                                        ;; 02:5dd2 $3e $05
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5dd4 $c3 $ac $72

call_02_5dd7_ObjectAction_EvilSantaProjectile_Destroy:
    call call_00_2a5d_Object_Check5Flag2                                  ;; 02:5dd7 $cd $5d $2a
    jp   NZ, call_00_2b80_ClearObjectMemoryEntry                              ;; 02:5dda $c2 $80 $2b
    ret                                                ;; 02:5ddd $c9

call_02_5dde_ObjectAction_SkatingElf_Skate:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5dde $cd $f5 $29
    ld   C, $20                                        ;; 02:5de1 $0e $20
    call NZ, call_00_28c8_Object_SetXVelocity                              ;; 02:5de3 $c4 $c8 $28
    ld   A, [wDC71_FrameCounter]                                    ;; 02:5de6 $fa $71 $dc
    and  A, $07                                        ;; 02:5de9 $e6 $07
    ld   C, $10                                        ;; 02:5deb $0e $10
    call Z, call_00_2588_Object_ApproachXVelocity                               ;; 02:5ded $cc $88 $25
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5df0 $cd $1c $25
    call call_00_2722_IsPlayerNearObject                                  ;; 02:5df3 $cd $22 $27
    ret  Z                                             ;; 02:5df6 $c8
    call call_00_2a68_Object_ComputePlayerXProximity                                  ;; 02:5df7 $cd $68 $2a
    call call_00_2976_Object_GetFacingDirection                                  ;; 02:5dfa $cd $76 $29
    ld   HL, wDA12_ObjectDirectionRelativeToPlayer                                     ;; 02:5dfd $21 $12 $da
    cp   A, [HL]                                       ;; 02:5e00 $be
    ret  NZ                                            ;; 02:5e01 $c0
    ld   A, [wDA11_ObjectXDistFromPlayer]                                    ;; 02:5e02 $fa $11 $da
    cp   A, $40                                        ;; 02:5e05 $fe $40
    ld   A, $02                                        ;; 02:5e07 $3e $02
    jp   C, call_02_72ac_SetupNewAction                               ;; 02:5e09 $da $ac $72
    ret                                                ;; 02:5e0c $c9

call_02_5e0d_ObjectAction_SkatingElf_PrepareJump:
    ld   C, $20                                        ;; 02:5e0d $0e $20
    call call_00_28dc_Object_SetYVelocity                                  ;; 02:5e0f $cd $dc $28
    ld   C, $28                                        ;; 02:5e12 $0e $28
    call call_00_2588_Object_ApproachXVelocity                                  ;; 02:5e14 $cd $88 $25
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5e17 $cd $1c $25
    call call_00_28be_Object_GetXVelocity                                  ;; 02:5e1a $cd $be $28
    cp   A, $28                                        ;; 02:5e1d $fe $28
    ld   A, $03                                        ;; 02:5e1f $3e $03
    jp   Z, call_02_72ac_SetupNewAction                               ;; 02:5e21 $ca $ac $72
    ret                                                ;; 02:5e24 $c9

call_02_5e25_ObjectAction_SkatingElf_Jump:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5e25 $cd $1c $25
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped                                  ;; 02:5e28 $cd $4a $24
    call call_00_2766_Object_ResetYIfAboveStart                                  ;; 02:5e2b $cd $66 $27
    ld   A, $00                                        ;; 02:5e2e $3e $00
    jp   NC, call_02_72ac_SetupNewAction                              ;; 02:5e30 $d2 $ac $72
    ret                                                ;; 02:5e33 $c9

call_02_5e34_ObjectAction_SkatingElf_Damaged:
    call call_00_29f5_Object_ClearActiveFlagAndCheck                                  ;; 02:5e34 $cd $f5 $29
    jr   Z, .jr_02_5e45                                ;; 02:5e37 $28 $0c
    call call_00_2766_Object_ResetYIfAboveStart                                  ;; 02:5e39 $cd $66 $27
    ld   C, $00                                        ;; 02:5e3c $0e $00
    jr   C, .jr_02_5e42                                ;; 02:5e3e $38 $02
    ld   C, $01                                        ;; 02:5e40 $0e $01
.jr_02_5e42:
    call call_00_2980_Object_SetExtraFlags                                  ;; 02:5e42 $cd $80 $29
.jr_02_5e45:
    call call_00_298a_Object_GetExtraFlags                                  ;; 02:5e45 $cd $8a $29
    jr   Z, .jr_02_5e6d                                ;; 02:5e48 $28 $23
    ld   A, [wDC71_FrameCounter]                                    ;; 02:5e4a $fa $71 $dc
    and  A, $07                                        ;; 02:5e4d $e6 $07
    ld   C, $10                                        ;; 02:5e4f $0e $10
    call Z, call_00_2588_Object_ApproachXVelocity                               ;; 02:5e51 $cc $88 $25
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5e54 $cd $1c $25
    ret  Z                                             ;; 02:5e57 $c8
    call call_00_230f_ResolveObjectListIndex                                  ;; 02:5e58 $cd $0f $23
    ld   B, $00                                        ;; 02:5e5b $06 $00
    ld   HL, wDCD5_ElfHealth1                                     ;; 02:5e5d $21 $d5 $dc
    add  HL, BC                                        ;; 02:5e60 $09
    ld   A, [HL]                                       ;; 02:5e61 $7e
    and  A, A                                          ;; 02:5e62 $a7
    ld   A, $00                                        ;; 02:5e63 $3e $00
    jp   NZ, call_02_72ac_SetupNewAction                              ;; 02:5e65 $c2 $ac $72
    ld   A, $05                                        ;; 02:5e68 $3e $05
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5e6a $c3 $ac $72
.jr_02_5e6d:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5e6d $cd $1c $25
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped                                  ;; 02:5e70 $cd $4a $24
    call call_00_2766_Object_ResetYIfAboveStart                                  ;; 02:5e73 $cd $66 $27
    ld   C, $01                                        ;; 02:5e76 $0e $01
    call NC, call_00_2980_Object_SetExtraFlags                              ;; 02:5e78 $d4 $80 $29
    ret                                                ;; 02:5e7b $c9

call_02_5e7c_ObjectAction_Penguin_WalkOrRun:
; if player and object distance is <(or equal?) 30, run, else walk
    call call_00_2a68_Object_ComputePlayerXProximity                                  ;; 02:5e7c $cd $68 $2a
    ld   A, [wDA11_ObjectXDistFromPlayer]                                    ;; 02:5e7f $fa $11 $da
    cp   A, $30                                        ;; 02:5e82 $fe $30
    jr   C, .jr_02_5e8e                                ;; 02:5e84 $38 $08
    ld   C, $04                                        ;; 02:5e86 $0e $04
    call call_00_2588_Object_ApproachXVelocity                                  ;; 02:5e88 $cd $88 $25
    jp   call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5e8b $c3 $1c $25
.jr_02_5e8e:
    ld   A, [wDA12_ObjectDirectionRelativeToPlayer]                                    ;; 02:5e8e $fa $12 $da
    xor  A, $20                                        ;; 02:5e91 $ee $20
    ld   C, A                                          ;; 02:5e93 $4f
    call call_00_2958_Object_SetFacingDirection                                  ;; 02:5e94 $cd $58 $29
    ld   C, $1e                                        ;; 02:5e97 $0e $1e
    call call_00_2588_Object_ApproachXVelocity                                  ;; 02:5e99 $cd $88 $25
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5e9c $cd $1c $25
    jr   NZ, .jr_02_5eae                               ;; 02:5e9f $20 $0d
    ld   A, [wDA11_ObjectXDistFromPlayer]                                    ;; 02:5ea1 $fa $11 $da
    cp   A, $18                                        ;; 02:5ea4 $fe $18
    ret  NC                                            ;; 02:5ea6 $d0
    ld   HL, wDA12_ObjectDirectionRelativeToPlayer                                     ;; 02:5ea7 $21 $12 $da
    ld   C, [HL]                                       ;; 02:5eaa $4e
    call call_00_2958_Object_SetFacingDirection                                  ;; 02:5eab $cd $58 $29
.jr_02_5eae:
    ld   C, $30                                        ;; 02:5eae $0e $30
    call call_00_28dc_Object_SetYVelocity                                  ;; 02:5eb0 $cd $dc $28
    ld   A, OBJECTACTION_PENGUIN_JUMP                                        ;; 02:5eb3 $3e $01
    jp   call_02_72ac_SetupNewAction                                  ;; 02:5eb5 $c3 $ac $72

call_02_5eb8_ObjectAction_Penguin_Jump:
    ld   C, $10                                        ;; 02:5eb8 $0e $10
    call call_00_2588_Object_ApproachXVelocity                                  ;; 02:5eba $cd $88 $25
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing                                  ;; 02:5ebd $cd $1c $25
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped                                  ;; 02:5ec0 $cd $4a $24
    call call_00_2766_Object_ResetYIfAboveStart                                  ;; 02:5ec3 $cd $66 $27
    ld   A, OBJECTACTION_PENGUIN_WALK_OR_RUN                                        ;; 02:5ec6 $3e $00
    jp   NC, call_02_72ac_SetupNewAction                              ;; 02:5ec8 $d2 $ac $72
    ret                                                ;; 02:5ecb $c9

call_02_5ecc_ObjectAction_Rezling_Walk:
    ld   c,$14
    call call_00_28c8_Object_SetXVelocity
    call call_00_2410_Object_SetFacingRelativeToPlayer
    call call_00_254a_Object_AdvancePosition_XDelta
    jp   call_00_2879_Object_SnapXPosition

call_02_5eda_ObjectAction_Rezling_None:
    ret  

call_02_5edb_ObjectAction_Rezling_None:
    ret  

call_02_5edc_ObjectAction_Rezling_None:
    ret  

call_02_5edd_ObjectAction_Fish_Unk0:
    call call_00_2722_IsPlayerNearObject
    jr   z,label5EF1
    call call_00_2a68_Object_ComputePlayerXProximity
    call call_00_2976_Object_GetFacingDirection
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    cp   [hl]
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
label5EF1:
    ld   c,$08
    call call_00_2588_Object_ApproachXVelocity
    jp   call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing

call_02_5ef9_ObjectAction_Fish_Unk1:
    ld   c,$20
    call call_00_2588_Object_ApproachXVelocity
    jp   call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing

call_02_5f01_ObjectAction_SafariSam_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$F0
    call nz,call_00_290d_Object_SetTimer1A
    call call_00_2722_IsPlayerNearObject
    jr   z,label5F22
    call call_00_2a68_Object_ComputePlayerXProximity
    call call_00_2976_Object_GetFacingDirection
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    cp   [hl]
    jr   z,label5F22
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$40
    call c,call_00_2410_Object_SetFacingRelativeToPlayer
label5F22:
    ld   c,$06
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ld   c,$27
    call call_00_2b10_Object_FindDuplicateInstance
    ret  nz
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_5f39_ObjectAction_SafariSam_Unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$06
    call nz,call_00_3792_PrepareRelativeObjectSpawn
    ret  

call_02_5f42_ObjectAction_SafariSam_Unk3:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$30
    call nz,call_00_28dc_Object_SetYVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    jp   call_00_2766_Object_ResetYIfAboveStart

call_02_5f50_ObjectAction_SafariSamProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label5F5F
    ld   c,$F0
    call call_00_290d_Object_SetTimer1A
    ld   c,$0A
    call call_00_28c8_Object_SetXVelocity
.label5F5F:
    call call_00_254a_Object_AdvancePosition_XDelta
    call call_00_2922_Object_Timer1ACountdown
    jp   z,call_00_2b80_ClearObjectMemoryEntry
    ret  

call_02_5f69_ObjectAction_GhostKnight_Unk0:
    xor  a
    ld   [wDCD3_GhostKnightDamageCounter1],a
    ld   [wDCD4_GhostKnightDamageCounter2],a
    call call_02_5F9B
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_5f78_ObjectAction_GhostKnight_Unk1:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$41
    call nz,call_00_290d_Object_SetTimer1A
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$02
    jp   z,call_02_72ac_SetupNewAction
    ld   a,[hl]
    and  a,$0F
    ld   c,$1B
    jp   z,call_00_3792_PrepareRelativeObjectSpawn
    ret  

call_02_5f91_ObjectAction_GhostKnight_Unk3:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ret  z
    ld   hl,wDCD3_GhostKnightDamageCounter1
    inc  [hl]
    res  3,[hl]
call_02_5F9B:
    ld   hl,wDCD3_GhostKnightDamageCounter1
    ld   l,[hl]
    ld   h,00
    ld   de,.data_02_5fbf
    add  hl,de
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    add  hl,hl
    ld   de,.data_02_5fc7
    add  hl,de
    ld   d, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   e,a
    ld   b,$04
.label5FB8:
    ldi  a,[hl]
    ld   [de],a
    inc  e
    dec  b
    jr   nz,.label5FB8
    ret  
.data_02_5fbf:
    db   $04, $0e, $1d, $23, $34        ;; 02:5fbc ????????
    db   $2a, $19, $0a
.data_02_5fc7:
    db   $27, $00, $13, $00, $33        ;; 02:5fc4 ????????
    db   $00, $13, $00, $3f, $00, $13, $00, $4c        ;; 02:5fcc ????????
    db   $00, $13, $00, $58, $00, $13, $00, $64        ;; 02:5fd4 ????????
    db   $00, $13, $00, $71, $00, $13, $00, $7d        ;; 02:5fdc ????????
    db   $00, $13, $00, $25, $00, $19, $00, $31        ;; 02:5fe4 ????????
    db   $00, $19, $00, $3e, $00, $19, $00, $4c        ;; 02:5fec ????????
    db   $00, $19, $00, $58, $00, $19, $00, $65        ;; 02:5ff4 ????????
    db   $00, $19, $00, $72, $00, $19, $00, $7f        ;; 02:5ffc ????????
    db   $00, $19, $00, $23, $00, $20, $00, $30        ;; 02:6004 ????????
    db   $00, $20, $00, $3e, $00, $20, $00, $4c        ;; 02:600c ????????
    db   $00, $20, $00, $58, $00, $20, $00, $66        ;; 02:6014 ????????
    db   $00, $20, $00, $73, $00, $20, $00, $81        ;; 02:601c ????????
    db   $00, $20, $00, $20, $00, $28, $00, $2f        ;; 02:6024 ????????
    db   $00, $28, $00, $3d, $00, $28, $00, $4b        ;; 02:602c ????????
    db   $00, $28, $00, $59, $00, $28, $00, $67        ;; 02:6034 ????????
    db   $00, $28, $00, $75, $00, $28, $00, $83        ;; 02:603c ????????
    db   $00, $28, $00, $1d, $00, $33, $00, $2c        ;; 02:6044 ????????
    db   $00, $33, $00, $3b, $00, $33, $00, $4b        ;; 02:604c ????????
    db   $00, $33, $00, $59, $00, $33, $00, $69        ;; 02:6054 ????????
    db   $00, $33, $00, $78, $00, $33, $00, $87        ;; 02:605c ????????
    db   $00, $33, $00, $19, $00, $3f, $00, $29        ;; 02:6064 ????????
    db   $00, $3f, $00, $3a, $00, $3f, $00, $4a        ;; 02:606c ????????
    db   $00, $3f, $00, $5a, $00, $3f, $00, $6a        ;; 02:6074 ????????
    db   $00, $3f, $00, $7a, $00, $3f, $00, $8a        ;; 02:607c ????????
    db   $00, $3f, $00, $15, $00, $4d, $00, $27        ;; 02:6084 ????????
    db   $00, $4d, $00, $38, $00, $4d, $00, $4a        ;; 02:608c ????????
    db   $00, $4d, $00, $5a, $00, $4d, $00, $6c        ;; 02:6094 ????????
    db   $00, $4d, $00, $7d, $00, $4d, $00, $8e        ;; 02:609c ????????
    db   $00, $4d, $00, $10, $00, $5d, $00, $23        ;; 02:60a4 ????????
    db   $00, $5d, $00, $36, $00, $5d, $00, $48        ;; 02:60ac ????????
    db   $00, $5d, $00, $5b, $00, $5d, $00, $6e        ;; 02:60b4 ????????
    db   $00, $5d, $00, $80, $00, $5d, $00, $93        ;; 02:60bc ????????
    db   $00, $5d, $00
    
call_02_60c7_ObjectAction_GhostKnightProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label60F2
    ld   a,[wDCD3_GhostKnightDamageCounter1]
    add  a
    add  a
    ld   c,a
    ld   hl,wDCD4_GhostKnightDamageCounter2
    ld   a,[hl]
    inc  [hl]
    and  a,$03
    or   c
    ld   l,a
    ld   h,$00
    add  hl,hl
    ld   de,.data_02_60ff
    add  hl,de
    ld   c,[hl]
    push hl
    call call_00_28c8_Object_SetXVelocity
    pop  hl
    inc  hl
    ld   c,[hl]
    call call_00_28dc_Object_SetYVelocity
    ld   c,$5A
    call call_00_290d_Object_SetTimer1A
.label60F2:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_24ee_Object_IntegrateYVelocity
    call call_00_2922_Object_Timer1ACountdown
    jp   z,call_00_2b7a_ClearObjectThenJump
    ret  
.data_02_60ff:
    db   $e0, $20, $00, $20, $20        ;; 02:60fc ????????
    db   $20, $00, $20, $e0, $00, $e0, $20, $00        ;; 02:6104 ????????
    db   $20, $20, $20, $00, $20, $e0, $20, $e0        ;; 02:610c ????????
    db   $00, $e0, $e0, $e0, $e0, $20, $e0, $20        ;; 02:6114 ????????
    db   $20, $e0, $20, $e0, $00, $e0, $e0, $00        ;; 02:611c ????????
    db   $e0, $20, $e0, $00, $e0, $20, $e0, $20        ;; 02:6124 ????????
    db   $00, $20, $20, $20, $e0, $20, $00, $20        ;; 02:612c ????????
    db   $20, $00, $20, $e0, $20, $00, $20, $20        ;; 02:6134 ????????
    db   $20, $20, $00

call_02_613f_ObjectAction_Hand_Unk0:
    ld   c,$04
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ld   a,$01
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_614d_ObjectAction_Hand_Unk1:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$38
    call nz,call_00_28dc_Object_SetYVelocity
label6155:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_28d2_Object_GetYVelocity
    bit  7,a
    ld   a,$02
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_6163_ObjectAction_Hand_Unk2:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   a,$03
    jp   nc,call_02_72ac_SetupNewAction
    ret  
    
call_02_616f_ObjectAction_Hand_Unk3:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label61A1
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   c,$10
    call call_00_28dc_Object_SetYVelocity
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  a,$B0
    ld   e,a
    ld   a,[hl]
    sbc  a,$01
    ld   d,a
    ld   a,e
    add  a,$0C
    ld   e,a
    ld   a,d
    adc  a,$00
    jr   nz,.label61A1
    ld   a,e
    cp   a,$18
    jr   nc,.label61A1
    ld   a,$01
    ld   [wDCDC_HandObjectUnkFlag],a
.label61A1:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ret  c
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$04
    jp   call_02_72ac_SetupNewAction

call_02_61b2_ObjectAction_Hand_Unk5:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    jp   call_00_2766_Object_ResetYIfAboveStart

call_02_61b8_ObjectAction_LostArk_Unk2:
    ld   hl,.data_02_61be
    jp   call_00_2c20_Object_CopyPaletteToBuffer
.data_02_61be:
    db   $00, $00, $ff, $7f, $b5, $56, $ad, $35

call_02_61c6_ObjectAction_Bee_Unk0:
    ld   c,04
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2a68_Object_ComputePlayerXProximity
    call call_00_2976_Object_GetFacingDirection
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    cp   [hl]
    ret  nz
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$30
    ret  nc
    ld   c,$20
    call call_00_28c8_Object_SetXVelocity
    ld   c,$30
    call call_00_28dc_Object_SetYVelocity
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_61ee_ObjectAction_Bee_Unk1:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyGravityAndSnapToGround
    ld   c,$00
    jr   nc,.label620B
    call call_00_28d2_Object_GetYVelocity
    bit  7,a
    jr   nz,.label6206
    ld   c,$02
    cp   a,$08
    jr   c,.label620B
    ret  
.label6206:
    cp   a,$F8
    ret  nc
    ld   c,$03
.label620B:
    call call_00_2962_Object_GetActionId
    ld   a,c
    cp   [hl]
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_6214_ObjectAction_Raft_ResetAndWait:
; This is the raft initialization / reset state.
; Calls call_00_29f5 (a condition check, probably “is Gex nearby / on raft?”). If false, it bails out early.
; Otherwise, resets the raft back to its initial X and Y positions.
; Clears its velocity and facing direction.
; Nudges the raft downward by $28 pixels (placing it into the river).
; Sets a countdown timer (Timer1A = $28).
; In its idle loop: every 4 frames it slowly drifts upward (bc=$FFFF → add -1 to Y).
; When the timer expires, it switches the raft into the next action (via call_02_72ac_SetupNewAction).
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6239
    call call_00_2826_Object_ResetToInitialXPos
    call call_00_27e4_Object_ResetToInitialYPos
    ld   c,$40
    call call_00_2980_Object_SetExtraFlags
    ld   c,$00
    call call_00_28c8_Object_SetXVelocity
    ld   c,$00
    call call_00_2958_Object_SetFacingDirection
    ld   bc,$0028
    call call_00_250d_Object_UpdateYPosition
    ld   c,$28
    call call_00_290d_Object_SetTimer1A
.label6239:
    ld   a,[wDC71_FrameCounter]
    and  a,$03
    ret  nz
    ld   bc,$FFFF
    call call_00_250d_Object_UpdateYPosition
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_624e_ObjectAction_Raft_MoveRightAndCarryPlayer:
; This is the raft’s main ferrying state, where it moves sideways.
; Every frame, alternates X velocity between 0 and 1 (so it “jitters” or drifts right at half-speed).
; Update X position of raft
; Calls call_00_26c9_Object_InfluencePlayerX so that Gex is pushed along when standing on the raft.
; Then it checks the raft’s X position against the camera’s left and right bounds (wDA14..wDA16).
; If raft goes fully off-screen: switch to reset state (action 0).
; If raft snaps against the right edge: switch to state 2.
; Otherwise, keeps moving right.
    ld   a,[wDC71_FrameCounter]
    and  a,$01
    ld   c,$00
    jp   z,call_00_28c8_Object_SetXVelocity
    ld   c,$01
    call call_00_28c8_Object_SetXVelocity
    ld   bc,$0001
    call call_00_24df_Object_UpdateXPosition
    call call_00_26c9_Object_InfluencePlayerX
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    ld   d,[hl]
    ld   e,a
    ld   hl,wDA14_CameraPos_Left
    ld   a,e
    sub  [hl]
    inc  hl
    ld   a,d
    sbc  [hl]
    jr   c,.label6285
    ld   hl,wDA16_CameraPos_Right
    ld   a,e
    sub  [hl]
    inc  hl
    ld   a,d
    sbc  [hl]
    jr   c,.label628A
.label6285:
    ld   a,$00
    jp   call_02_72ac_SetupNewAction
.label628A:
    call call_00_2879_Object_SnapXPosition
    ld   a,$02
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_6293_ObjectAction_Raft_DriftDown:
; This is the raft return state.
; Calls call_00_29f5 again (same condition gate). If false, it doesn’t reinit.
; Otherwise, resets facing and X velocity to 0, and sets a timer (Timer1A = $28).
; In its loop: every 4 frames, nudges raft downward (bc=$0001 → +1 to Y).
; Once the timer expires, transitions raft back to state 0.
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label62A7
    ld   c,$00
    call call_00_28c8_Object_SetXVelocity
    ld   c,$00
    call call_00_2958_Object_SetFacingDirection
    ld   c,$28
    call call_00_290d_Object_SetTimer1A
.label62A7:
    ld   a,[wDC71_FrameCounter]
    and  a,$03
    ret  nz
    ld   bc,$0001
    call call_00_250d_Object_UpdateYPosition
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$00
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_62bc_ObjectAction_Snake_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label62D0
    ld   c,$08
    call call_00_2944_Object_SetWidth
    call call_00_293a_Object_GetId
    cp   a,$31
    ld   c,$20
    call z,call_00_2958_Object_SetFacingDirection
.label62D0:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    call call_00_2a68_Object_ComputePlayerXProximity
    call call_00_2976_Object_GetFacingDirection
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    cp   [hl]
    ret  nz
    call call_00_293a_Object_GetId
    ld   c,$32
    cp   a,$30
    jr   z,.label62EA
    ld   c,$33
.label62EA:
    call call_00_2b10_Object_FindDuplicateInstance
    ret  nz
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$40
    ld   a,$01
    jp   c,call_02_72ac_SetupNewAction
    ret  

call_02_62f9_ObjectAction_Snake_Unk1:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    ld   c,$10
    call call_00_2944_Object_SetWidth
    call call_00_293a_Object_GetId
    ld   c,$0E
    cp   a,$30
    jr   z,.label630D
    ld   c,$0F
.label630D:
    call call_00_3792_PrepareRelativeObjectSpawn
    ld   a,$02
    jp   call_02_72ac_SetupNewAction

call_02_6315_ObjectAction_Snake_Unk2:
    ld   c,$08
    jp   call_00_2944_Object_SetWidth

call_02_631a_ObjectAction_SnakeRightProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6329
    ld   c,$20
    call call_00_28c8_Object_SetXVelocity
    ld   c,$40
    call call_00_290d_Object_SetTimer1A
.label6329:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2922_Object_Timer1ACountdown
    jp   z,call_00_2b7a_ClearObjectThenJump
    ret  

call_02_6333_ObjectAction_SnakeLeftProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6342
    ld   c,$E0
    call call_00_28c8_Object_SetXVelocity
    ld   c,$40
    call call_00_290d_Object_SetTimer1A
.label6342:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2922_Object_Timer1ACountdown
    jp   z,call_00_2b7a_ClearObjectThenJump
    ret  

call_02_634c_ObjectAction_RaStatue_Unk0:
    call call_00_293a_Object_GetId
    cp   a,$36
    ld   c,$20
    call z,call_00_2958_Object_SetFacingDirection
    call call_00_2826_Object_ResetToInitialXPos
    call call_00_27e4_Object_ResetToInitialYPos
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6361_ObjectAction_RaStatue_Unk1:
    ld   de,.data_02_6367
    jp   call_00_2a98_HandlePlayerObjectInteraction
.data_02_6367:    
    db   $c0, $01, $20, $70, $00        ;; 02:6364 ????????
    db   $10, $36, $20, $20, $02, $c0, $01, $20        ;; 02:636c ????????
    db   $70, $00, $10, $36, $e0, $20, $02, $90        ;; 02:6374 ????????
    db   $01, $10, $68, $01, $10, $56, $20, $10        ;; 02:637c ????????
    db   $02, $90, $01, $10, $68, $01, $10, $56        ;; 02:6384 ????????
    db   $e0, $10, $02, $70, $02, $10, $60, $01        ;; 02:638c ????????
    db   $20, $22, $e4, $20, $02

call_02_6399_ObjectAction_RaStatue_Unk3:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_24ee_Object_IntegrateYVelocity
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$00
    jp   z,call_02_72ac_SetupNewAction
    ret
    
call_02_63a8_ObjectAction_BreakableBlock_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label63B1
    xor  a
    ld   [wDCDC_HandObjectUnkFlag],a
.label63B1:
    ld   hl,wDCDC_HandObjectUnkFlag
    bit  0,[hl]
    ret  z
    ld   [hl],$00
    call call_00_2962_Object_GetActionId
    inc  a
    jp   call_02_72ac_SetupNewAction

call_02_63c0_ObjectAction_BreakableBlock_Unk3:
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    farcall call_03_57f8_ClearCollisionForObject
    jp   call_00_2b7a_ClearObjectThenJump

call_02_63d3_ObjectAction_Coffin_Unk2:
    call call_00_22ef_SetObjectSlotActive
    ld   c,$02
    jp   call_00_2299_SetObjectStatusLowNibble

call_02_63db_ObjectAction_Cactus_Unk0:
    ld   c,$28
    call call_00_28c8_Object_SetXVelocity
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA12_ObjectDirectionRelativeToPlayer]
    ld   hl,wD80D_PlayerFacingDirection
    cp   [hl]
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_63f0_ObjectAction_Cactus_Unk1:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label63FD
    ld   c,$3C
    call call_00_290d_Object_SetTimer1A
    call call_00_2410_Object_SetFacingRelativeToPlayer
.label63FD:
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$02
    jp   z,call_02_72ac_SetupNewAction

call_02_6405:
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA12_ObjectDirectionRelativeToPlayer]
    ld   hl,wD80D_PlayerFacingDirection
    cp   [hl]
    ld   a,$00
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_6415_ObjectAction_Cactus_Unk4:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$20
    call nz,call_00_28dc_Object_SetYVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ret  c
    ld   a,$03
    call call_02_72ac_SetupNewAction
    jr   call_02_6405

call_02_642e_ObjectAction_Rock_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label643D
    ld   c,$00
    call call_00_290d_Object_SetTimer1A
    ld   c,$10
    call call_00_294e_Object_SetHeight
.label643D:
    call call_00_2917_Object_CheckIfTimer1AIsZero
    jr   nz,.label6450
    ld   a,[wDC7B]
    ld   hl,wDA00_CurrentObjectAddrLo
    cp   [hl]
    ret  nz
    call call_00_230f_ResolveObjectListIndex
    jp   call_00_290d_Object_SetTimer1A
.label6450:
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6459_ObjectAction_Rock_Unk1:
    call call_00_296c_Object_Get9
    ld   l,a
    ld   h,$00
    ld   de,.data_02_6467
    add  hl,de
    ld   c,[hl]
    jp   call_00_294e_Object_SetHeight
.data_02_6467:
    db   $10, $0e, $0c, $0a, $08, $06, $04, $02

call_02_646f_ObjectAction_Rock_Unk2:
    farcall call_03_57f8_ClearCollisionForObject
    ret  

call_02_647b_ObjectAction_Rock_Unk3:
    call call_00_296c_Object_Get9
    ld   l,a
    ld   h,$00
    ld   de,call_02_6489
    add  hl,de
    ld   c,[hl]
    jp   call_00_294e_Object_SetHeight

call_02_6489:
    ld   [bc],a
    inc  b
    ld   b,$08
    ld   a,[bc]
    inc  c
    ld   c,$10
call_02_6491_ObjectAction_HardHat_Unk0:
    call call_00_2722_IsPlayerNearObject
    jr   z,.label64A0
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$30
    jr   c,.label64A8
.label64A0:
    ld   c,$04
    call call_00_2588_Object_ApproachXVelocity
    jp   call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
.label64A8:
    ld   a,[wDA12_ObjectDirectionRelativeToPlayer]
    xor  a,$20
    ld   c,a
    call call_00_2958_Object_SetFacingDirection
    ld   c,$1E
    call call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    jr   nz,.label64C8
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$20
    ret  nc
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    ld   c,[hl]
    call call_00_2958_Object_SetFacingDirection
.label64C8:
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_64cd_ObjectAction_HardHat_Unk1:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$20
    call nz,call_00_28dc_Object_SetYVelocity
    ld   c,$10
    call call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   a,$00
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_64e9_ObjectAction_Bat_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label64F4
    call call_00_2826_Object_ResetToInitialXPos
    call call_00_27e4_Object_ResetToInitialYPos
.label64F4:
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$10
    ld   a,$01
    jp   c,call_02_72ac_SetupNewAction
    ret  

call_02_6502_ObjectAction_Bat_Unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label651D
    call call_00_2410_Object_SetFacingRelativeToPlayer
    call call_00_2976_Object_GetFacingDirection
    ld   c,$10
    cp   a,$00
    jr   z,.label6515
    ld   c,$F0
.label6515:
    call call_00_28c8_Object_SetXVelocity
    ld   c,$20
    call call_00_28dc_Object_SetYVelocity
.label651D:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_28f1_Object_CheckIfYVelocityIsZero
    bit  7,a
    ld   a,$03
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_652e_ObjectAction_Bat_Unk3:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2780_Object_CheckBelowMapViewport
    ld   a,$00
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_653d_ObjectAction_Door1_Unk1:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    call call_00_1bbc_CheckForDoorAndEnter.jr_00_1bce
    ld   c,$02
    jp   call_00_2299_SetObjectStatusLowNibble

call_02_6549_ObjectAction_Door1_Unk2:
    ld   c,$00
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$03
    jp   call_02_72ac_SetupNewAction

call_02_6553_ObjectAction_Door2_Unk0:
    ld   c,$02
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_655d_ObjectAction_Door2_Unk3:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    call call_00_1bbc_CheckForDoorAndEnter.jr_00_1bce
    ld   c,$00
    jp   call_00_2299_SetObjectStatusLowNibble

call_02_6569_ObjectAction_FanLift_Unk0:
    call call_00_22d4_CheckObjectSlotFlag
    ret  z
    ld   c,$02
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6577_ObjectAction_FanLift_Unk2:
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  [hl]
    ld   hl,wDC71_FrameCounter
    and  [hl]
    and  a,$1F
    jr   z,.label6589
    call call_00_2976_Object_GetFacingDirection
    xor  a,$20
    ld   [hl],a
.label6589:
    call call_00_22d4_CheckObjectSlotFlag
    ret  nz
    ld   c,$00
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$03
    jp   call_02_72ac_SetupNewAction

call_02_6597_ObjectAction_MechLeft_Unk0:
    ld   c,$20
    call call_00_2958_Object_SetFacingDirection
call_02_659c_ObjectAction_MechRight_Unk0:
    ret  

call_02_659d_ObjectAction_AnimeDisappearingFloor_Unk0:
    call call_00_22d4_CheckObjectSlotFlag
    cp   a,$02
    ret  c
    farcall call_03_57f8_ClearCollisionForObject
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_65b3_ObjectAction_Onswitch2_Unk1:
    ld   a,[wDB6C_CurrentMapId]
    cp   a,$2B
    ret  nz
    call call_00_22d4_CheckObjectSlotFlag
    cp   a,$01
    ret  nz
    ld   c,$00
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$00
    jp   call_02_72ac_SetupNewAction

call_02_65c9_ObjectAction_BlueBeamBarrier_Unk0:
    call call_00_22d4_CheckObjectSlotFlag
    ret  z
    ld   c,$01
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_65d7_ObjectAction_AnimeRisingPlatform_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$00
    call nz,call_00_290d_Object_SetTimer1A
    ld   a,[wDC7B]
    and  a
    jr   z,.label65F8
    ld   hl,wDA00_CurrentObjectAddrLo
    cp   [hl]
    jr   z,.label65F8
    call call_00_2917_Object_CheckIfTimer1AIsZero
    cp   a,$A8
    ret  nc
    inc  [hl]
    ld   bc,$FFFF
    jp   call_00_250d_Object_UpdateYPosition
.label65F8:
    ld   a,[wDC71_FrameCounter]
    and  a,$03
    ret  nz
    call call_00_2917_Object_CheckIfTimer1AIsZero
    ret  z
    dec  [hl]
    ld   bc,$0001
    jp   call_00_250d_Object_UpdateYPosition

call_02_659d_ObjectAction_OnSwitch_Unk0:
    call call_00_22d4_CheckObjectSlotFlag
    ret  z
    ld   c,$01
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6617_ObjectAction_OnSwitch_Unk1:
    call call_00_22d4_CheckObjectSlotFlag
    ret  nz
    ld   c,$00
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$00
    jp   call_02_72ac_SetupNewAction

call_02_6617_ObjectAction_OffSwitch_Unk0:
    call call_00_22d4_CheckObjectSlotFlag
    ret  z
    ld   c,$01
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6633_ObjectAction_OffSwitch_Unk1:
    call call_00_22d4_CheckObjectSlotFlag
    ret  nz
    ld   c,$00
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$00
    jp   call_02_72ac_SetupNewAction

call_02_6641_ObjectAction_SailorToonGirl_Unk0:
    ld   c,$10
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2722_IsPlayerNearObject
    ret  z
    call call_00_2410_Object_SetFacingRelativeToPlayer
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$18
    jr   c,.label6662
    cp   a,$40
    ld   a,$04
    jp   nc,call_02_72ac_SetupNewAction
    ret  
.label6662:
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  a
    cp   a,$09
    jr   c,.label666B
    xor  a
.label666B:
    ld   [hl],a
    ld   l,a
    ld   h,$00
    ld   de,call_02_667e
    add  hl,de
    ld   a,[hl]
    push af
    cp   a,$04
    call z,call_00_242d_Object_SetFacingRelativeToPlayer_Inverse
    pop  af
    jp   call_02_72ac_SetupNewAction

call_02_667e:
    ld   bc,$0606
    ld   bc,$0104
    inc  b
    ld   b,$04
call_02_6687_ObjectAction_SailorToonGirl_Unk2:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    jp   call_00_2766_Object_ResetYIfAboveStart

call_02_668d_ObjectAction_SailorToonGirl_Unk3:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ret  c
    call call_00_2a5d_Object_Check5Flag2
    ld   a,$04
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_669d_ObjectAction_SailorToonGirl_Unk5:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label66AC
    ld   c,$18
    call call_00_28c8_Object_SetXVelocity
    ld   c,$28
    call call_00_28dc_Object_SetYVelocity
.label66AC:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   a,$00
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_66bb_ObjectAction_BigSilverRobot_Unk0:
    call call_00_2410_Object_SetFacingRelativeToPlayer
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$38
    ld   a,$01
    jp   c,call_02_72ac_SetupNewAction
    ret  

call_02_66cc_ObjectAction_BigSilverRobot_Unk1:
    ld   c,$10
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ret  z
    call call_00_2976_Object_GetFacingDirection
    xor  a,$20
    ld   [hl],a
    ld   a,$02
    jp   call_02_72ac_SetupNewAction

call_02_66e0_ObjectAction_BigSilverRobot_Unk2:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    call call_00_2976_Object_GetFacingDirection
    xor  a,$20
    ld   [hl],a
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_66ef_ObjectAction_BigSilverRobot_Unk3:
    call call_00_2a5d_Object_Check5Flag2
    jp   nz,call_00_2b7a_ClearObjectThenJump
    ret  

call_02_66f6_ObjectAction_SmallBlueRobot_Unk0:
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$38
    jr   c,.label6708
    ld   c,$06
    call call_00_2588_Object_ApproachXVelocity
    jp   call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
.label6708:
    ld   a,[wDA12_ObjectDirectionRelativeToPlayer]
    xor  a,$20
    ld   c,a
    call call_00_2958_Object_SetFacingDirection
    ld   c,$10
    call call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    jr   nz,.label6728
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$28
    ret  nc
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    ld   c,[hl]
    call call_00_2958_Object_SetFacingDirection
.label6728:
    ld   c,$30
    call call_00_28dc_Object_SetYVelocity
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6732_ObjectAction_SmallBlueRobot_Unk1:
    ld   c,$02
    call call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   a,$00
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_6746_ObjectAction_Secbot_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$00
    call nz,call_00_290d_Object_SetTimer1A
    ld   c,$04
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ld   c,$02
    call nz,call_00_290d_Object_SetTimer1A
    call call_00_29ac_Object_CheckFacingPlayer
    ret  nz
    call call_00_2922_Object_Timer1ACountdown
    ld   c,$10
    jp   nz,call_00_3792_PrepareRelativeObjectSpawn
    ret  

call_02_6768_ObjectAction_Secbot_Unk1:
    call call_00_298a_Object_GetExtraFlags
    cp   a,$50
    jr   z,.label6776
    inc  [hl]
    ld   bc,$FFFF
    call call_00_250d_Object_UpdateYPosition
.label6776:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$00
    call nz,call_00_290d_Object_SetTimer1A
    ld   c,$10
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ld   c,$C1
    call nz,call_00_290d_Object_SetTimer1A
    call call_00_29ac_Object_CheckFacingPlayer
    ret  nz
    call call_00_2922_Object_Timer1ACountdown
    ret  z
    and  a,$3F
    ld   c,$10
    jp   z,call_00_3792_PrepareRelativeObjectSpawn
    ret  

call_02_679b_ObjectAction_SecbotProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label67B3
    call call_00_2976_Object_GetFacingDirection
    ld   c,$18
    cp   a,$00
    jr   z,.label67AB
    ld   c,$E8
.label67AB:
    call call_00_28c8_Object_SetXVelocity
    ld   c,$B4
    call call_00_290d_Object_SetTimer1A
.label67B3:
    call call_00_2922_Object_Timer1ACountdown
    jp   z,call_00_2b7a_ClearObjectThenJump
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    jp   call_00_2766_Object_ResetYIfAboveStart

call_02_67c2_ObjectAction_Elevator_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label67DF
    call call_02_688E
    ld   l,c
    ld   h,$00
    add  hl,hl
    ld   de,wDCE2_ElevatorObjectUnkData
    add  hl,de
    ld   d, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   e,a
    ldi  a,[hl]
    ld   [de],a
    inc  e
    ld   a,[hl]
    ld   [de],a
.label67DF:
    ld   a,[wDC7B]
    ld   hl,wDA00_CurrentObjectAddrLo
    cp   [hl]
    ret  nz
    call call_00_22d4_CheckObjectSlotFlag
    ld   c,a
    ld   hl,.data_02_686a
.label67EE:
    push hl
    ldi  a,[hl]
    cp   c
    jr   nz,.label6805
    ld   d, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   e,a
    ld   a,[de]
    sub  [hl]
    ld   b,a
    inc  de
    inc  hl
    ld   a,[de]
    sbc  [hl]
    or   b
    jr   z,.label6810
.label6805:
    pop  hl
    ld   de,$0005
    add  hl,de
    ld   a,[hl]
    cp   a,$FF
    jr   nz,.label67EE
    ret  
.label6810:
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
    jr   c,.label6847
    or   c
    jr   nz,.label6842
    call call_02_688E
    ld   l,c
    ld   h,$00
    add  hl,hl
    ld   de,wDCE2_ElevatorObjectUnkData
    add  hl,de
    ld   d, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   e,a
    ld   a,[de]
    ldi  [hl],a
    inc  e
    ld   a,[de]
    ld   [hl],a
    ld   a,[wD801_Player_ActionId]
    cp   a,$1E
    ld   a,$01
    jp   z,call_02_54f9_SwitchPlayerAction
    ret  
.label6842:
    ld   bc,$FFFF
    jr   .label684A
.label6847:
    ld   bc,$0001
.label684A:
    ld   a,$1E
    ld   hl,wD801_Player_ActionId
    cp   [hl]
    jp   nz,call_02_54f9_SwitchPlayerAction
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    ld   e,a
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    or   e
    jp   z,call_00_250d_Object_UpdateYPosition
    ret  
.data_02_686a:    
    db   $00, $a0, $01, $98, $02        ;; 02:6867 ????????
    db   $01, $a0, $01, $58, $01, $01, $40, $03        ;; 02:686f ????????
    db   $d8, $01, $01, $c0, $05, $58, $02, $02        ;; 02:6877 ????????
    db   $a0, $01, $08, $01, $02, $40, $03, $58        ;; 02:687f ????????
    db   $01, $02, $c0, $05, $d8, $01, $ff
    
call_02_688E:
    ld   hl,.data_02_68A9
    ld   d, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   e,a
    ld   c,$FF
.label689B:
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
    jr   nz,.label689B
    ret  
.data_02_68A9:   
    db   $a0, $01, $40, $03, $c0, $05        ;; 02:68a7 ????????

call_02_68af_ObjectAction_FireWallEnemy_Update:
    jp   call_00_233e_Object_UpdatePatternedPositionFromVelocityTable

call_02_68b2_ObjectAction_Grenade_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ret  z
    ld   hl,.data_02_68e5
    call call_00_2c20_Object_CopyPaletteToBuffer
    call call_00_2826_Object_ResetToInitialXPos
    ld   a,[wDC71_FrameCounter]
    and  a,$0F
    ld   c,a
    ld   b,$00
    call call_00_24df_Object_UpdateXPosition
    call call_00_27e4_Object_ResetToInitialYPos
    call call_00_230f_ResolveObjectListIndex
    ld   b,$FF
    call call_00_250d_Object_UpdateYPosition
    ld   c,$04
    call call_00_290d_Object_SetTimer1A
    ld   c,$00
    call call_00_28c8_Object_SetXVelocity
    ld   c,$00
    call call_00_28dc_Object_SetYVelocity
    ret  
.data_02_68e5:    
    db   $00, $00, $00, $00, $ff, $03, $ff, $7f

call_02_68ed_ObjectAction_Grenade_Unk1:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ret  c
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$02
    jp   z,call_02_72ac_SetupNewAction
    ld   l,[hl]
    ld   h,$00
    ld   de,.data_02_6924
    add  hl,de
    ld   c,[hl]
    call call_00_28dc_Object_SetYVelocity
    call call_00_28e6_Object_CheckIfXVelocityIsZero
    ret  nz
    ld   a,[wDC71_FrameCounter]
    swap a
    and  a,$03
    ld   l,a
    ld   h,$00
    ld   de,.data_02_6920
    add  hl,de
    ld   c,[hl]
    jp   call_00_28c8_Object_SetXVelocity
.data_02_6920:
    db   $08, $f8, $04, $fc
.data_02_6924:
    db   $00, $20, $28, $30

call_02_6928_ObjectAction_Grenade_Unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   bc,$0008
    call nz,call_00_250d_Object_UpdateYPosition
    ld   hl,.data_02_6937
    jp   call_00_2c20_Object_CopyPaletteToBuffer
.data_02_6937:
    db   $00, $00, $1b, $00, $5f, $02, $1f, $1b        ;; 02:6937 ????????

call_02_693f_ObjectAction_MadBomber_Unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$15
    call nz,call_00_3792_PrepareRelativeObjectSpawn
call_02_6947_ObjectAction_MadBomber_Unk0:
    ld   hl,wDCD0_MadBomberFlag
    ld   a,[hl]
    and  a
    ret  z
    ld   [hl],$00
    call call_00_28a0_Object_Get15
    and  a
    ret  nz
    ld   a,$04
    call call_02_72ac_SetupNewAction
    farcall call_03_5671_HandleObjectHitOrRespawn
    ret  

call_02_6965_ObjectAction_MadBomber_Unk5:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    ld   c,$01
    call call_00_21ef_PlayRemoteSpawnSFX
    jp   call_00_2b7a_ClearObjectThenJump

call_02_6971_ObjectAction_Bomb_Unk0:
    ld   c,$55
    call call_00_29b7_FindObjectByID_C
    ld   a,c
    cp   a,$02
    ld   a,$01
    jp   nz,call_02_72ac_SetupNewAction
    
call_02_697e:
    ld   a,l
    xor  a,$08
    ld   l,a
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,hl
    ld   de,.data_02_699f
    add  hl,de
    ld   d, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   e,a
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

call_02_69af_ObjectAction_Bomb_Unk1:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label69CB
    ld   hl,wDCCE_BombCounter
    ld   a,[hl]
    inc  [hl]
    and  a,$07
    ld   l,a
    ld   h,$00
    ld   de,.data_02_69fc
    add  hl,de
    ld   c,[hl]
    call call_00_28c8_Object_SetXVelocity
    ld   c,$20
    call call_00_28dc_Object_SetYVelocity
.label69CB:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    ld   de,$0068
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jp   c,call_00_24c0_Object_IntegrateXVelocity
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   c,$00
    call call_00_28c8_Object_SetXVelocity
    ld   c,$00
    call call_00_28dc_Object_SetYVelocity
    ld   c,$2D
    call call_00_290d_Object_SetTimer1A
    ld   a,SFX_BOMB
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$02
    jp   call_02_72ac_SetupNewAction
.data_02_69fc:    
    db   $10, $f0, $08, $f8, $10, $f0, $04, $fc
    
call_02_6a04_ObjectAction_Bomb_Unk2:
    ld   a,[wDC71_FrameCounter]
    and  a,$03
    ret  nz
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$04
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6a13_ObjectAction_Bomb_Unk3:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6A38
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ld   a,[hl]
    ld   hl,.data_02_6a40
    ld   b,$05
.label6A26:
    cp   [hl]
    jr   c,.label6A2E
    inc  hl
    inc  hl
    dec  b
    jr   nz,.label6A26
.label6A2E:
    inc  hl
    ld   c,[hl]
    call call_00_28c8_Object_SetXVelocity
    ld   c,$D8
    call call_00_28dc_Object_SetYVelocity
.label6A38:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_24ee_Object_IntegrateYVelocity
    jr   call_02_6a04_ObjectAction_Bomb_Unk2
.data_02_6a40:
    db   $17, $26, $35, $17, $44, $0f, $62        ;; 02:6a3f ????????
    db   $00, $71, $f9, $8f, $ea
    
call_02_6a4c_ObjectAction_Bomb_Unk4:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   a,SFX_SMALL_BANG
    call nz,call_00_0ff5_QueueSoundEffectWithPriority
    ld   hl,.data_02_6a89
    call call_00_2c20_Object_CopyPaletteToBuffer
    call call_00_2a5d_Object_Check5Flag2
    jp   nz,call_00_2b7a_ClearObjectThenJump
    ld   c,$55
    call call_00_29b7_FindObjectByID_C
    ld   a,c
    cp   a,$04
    ret  nc
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
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
    
call_02_6a91_ObjectAction_WaterTowerTank_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6AA1
    ld   bc,$FFD0
    call call_00_250d_Object_UpdateYPosition
    ld   c,$28
    call call_00_294e_Object_SetHeight
.label6AA1:
    call call_00_22d4_CheckObjectSlotFlag
    ret  z
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   c,$02
    call call_00_2299_SetObjectStatusLowNibble
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6ab4_ObjectAction_WaterTowerTank_Unk1:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$10
    call nz,call_00_294e_Object_SetHeight
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ret  c
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$02
    jp   call_02_72ac_SetupNewAction

call_02_6acd_ObjectAction_Convict_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jp   nz,call_00_2410_Object_SetFacingRelativeToPlayer
    ret  

call_02_6ad4_ObjectAction_Convict_Unk2:    
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$14
    jp   nz,call_00_3792_PrepareRelativeObjectSpawn
    ret  

call_02_6add_ObjectAction_ConvictProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6AF5
    call call_00_2976_Object_GetFacingDirection
    ld   c,$20
    cp   a,$00
    jr   z,.label6AED
    ld   c,$E0
.label6AED:
    call call_00_28c8_Object_SetXVelocity
    ld   c,$78
    call call_00_290d_Object_SetTimer1A
.label6AF5:
    call call_00_2922_Object_Timer1ACountdown
    jp   z,call_00_2b7a_ClearObjectThenJump
    cp   a,$3C
    call c,call_00_2475_Object_ApplyVerticalVelocity_Clamped
    jp   call_00_24c0_Object_IntegrateXVelocity

call_02_6b03_ObjectAction_Spider_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6B0E
    call call_00_230f_ResolveObjectListIndex
    call call_00_290d_Object_SetTimer1A
.label6B0E:
    ld   bc,$0002
    call call_00_250d_Object_UpdateYPosition
    call call_00_2917_Object_CheckIfTimer1AIsZero
    sub  a,$02
    ld   [hl],a
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6b20_ObjectAction_Spider_Unk1:
    ld   bc,$FFFF
    call call_00_250d_Object_UpdateYPosition
    call call_00_230f_ResolveObjectListIndex
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  a
    ld   [hl],a
    cp   c
    ld   a,$02
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6b35_ObjectAction_Spider_Unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6B47
    ld   c,$20
    call call_00_28c8_Object_SetXVelocity
    ld   c,$08
    call call_00_290d_Object_SetTimer1A
    call call_00_2410_Object_SetFacingRelativeToPlayer
.label6B47:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$00
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6b53_ObjectAction_StrayCat_Unk0:
    ld   c,$02
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$28
    ld   a,$01
    jp   c,call_02_72ac_SetupNewAction
    ret  

call_02_6b69_ObjectAction_YellowGoon_Unk0:
    call call_00_2722_IsPlayerNearObject
    jr   z,.label6B78
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$0E
    jr   c,.label6B8B
.label6B78:
    ld   c,$08
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ret  z
    call call_00_2922_Object_Timer1ACountdown
    jr   z,.label6B8B
    ld   a,$01
    jp   call_02_72ac_SetupNewAction
.label6B8B:
    call call_00_2917_Object_CheckIfTimer1AIsZero
    ld   [hl],$03
    call call_00_2722_IsPlayerNearObject
    call nz,call_00_2410_Object_SetFacingRelativeToPlayer
    ld   a,$02
    jp   call_02_72ac_SetupNewAction

call_02_6b9b_ObjectAction_Rat_Unk0:
    ld   c,$10
    call call_00_28c8_Object_SetXVelocity
    jp   call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing

call_02_6ba3_ObjectAction_ChomperTV_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6BB3
    ld   c,$04
    call call_00_28c8_Object_SetXVelocity
    call call_00_230f_ResolveObjectListIndex
    call call_00_290d_Object_SetTimer1A
.label6BB3:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ld   bc,$0002
    call call_00_250d_Object_UpdateYPosition
    call call_00_2917_Object_CheckIfTimer1AIsZero
    sub  a,$02
    ld   [hl],a
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6bc8_ObjectAction_ChomperTV_Unk2:
    call call_00_2917_Object_CheckIfTimer1AIsZero
    ld   a,[wDC71_FrameCounter]
    and  [hl]
    and  a,$3F
    jr   nz,.label6BDC
    call call_00_2976_Object_GetFacingDirection
    xor  a,$20
    ld   c,a
    call call_00_2958_Object_SetFacingDirection
.label6BDC:
    ld   c,$10
    call call_00_28c8_Object_SetXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing

call_02_6be4_ObjectAction_ChomperTV_Unk1:
    call call_00_230f_ResolveObjectListIndex
    call call_00_2917_Object_CheckIfTimer1AIsZero
    cp   c
    ld   a,$00
    jp   z,call_02_72ac_SetupNewAction
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  a
    ld   [hl],a
    ld   bc,$FFFF
    jp   call_00_250d_Object_UpdateYPosition

call_02_6bfb_ObjectAction_CrumblingFloor_Unk0:
    ld   a,[wDC7B]
    ld   hl,wDA00_CurrentObjectAddrLo
    cp   [hl]
    ld   a,$01
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6c08_ObjectAction_CrumblingFloor_Unk2:
    farcall call_03_57f8_ClearCollisionForObject
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2780_Object_CheckBelowMapViewport
    jp   nc,call_00_2b7a_ClearObjectThenJump
    ret  

call_02_6c1d_ObjectAction_GextremeSportsElf_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$20
    call nz,call_00_28c8_Object_SetXVelocity
    ld   a,[wDC71_FrameCounter]
    and  a,$07
    ld   c,$10
    call z,call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2722_IsPlayerNearObject
    ret  z
    call call_00_2a68_Object_ComputePlayerXProximity
    call call_00_2976_Object_GetFacingDirection
    ld   hl,wDA12_ObjectDirectionRelativeToPlayer
    cp   [hl]
    ret  nz
    ld   a,[wDA11_ObjectXDistFromPlayer]
    cp   a,$40
    ld   a,$02
    jp   c,call_02_72ac_SetupNewAction
    ret  

call_02_6c4c_ObjectAction_GextremeSportsElf_Unk2:
    ld   c,$20
    call call_00_28dc_Object_SetYVelocity
    ld   c,$28
    call call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_28be_Object_GetXVelocity
    cp   a,$28
    ld   a,$03
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6c64_ObjectAction_GextremeSportsElf_Unk3:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   a,$00
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_6c73_ObjectAction_GextremeSportsElf_Unk4:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6C84
    call call_00_2766_Object_ResetYIfAboveStart
    ld   c,$00
    jr   c,.label6C81
    ld   c,$01
.label6C81:
    call call_00_2980_Object_SetExtraFlags
.label6C84:
    call call_00_298a_Object_GetExtraFlags
    jr   z,.label6CAC
    ld   a,[wDC71_FrameCounter]
    and  a,$07
    ld   c,$10
    call z,call_00_2588_Object_ApproachXVelocity
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    ret  z
    call call_00_230f_ResolveObjectListIndex
    ld   b,$00
    ld   hl,wDCD5_ElfHealth1
    add  hl,bc
    ld   a,[hl]
    and  a
    ld   a,$00
    jp   nz,call_02_72ac_SetupNewAction
    ld   a,$05
    jp   call_02_72ac_SetupNewAction
.label6CAC:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   c,$01
    call nc,call_00_2980_Object_SetExtraFlags
    ret 
    
call_02_6cbb_ObjectAction_Bird_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6CC6
    call call_00_230f_ResolveObjectListIndex
    call call_00_2958_Object_SetFacingDirection
.label6CC6:
    call call_00_27f3_Object_GetInitialYPos
    ld   a,[wD810_PlayerYPosition]
    sub  e
    ld   a,[wD810_PlayerYPosition+1]
    sbc  d
    ret  c
    ld   c,$65
    call call_00_2b10_Object_FindDuplicateInstance
    ret  nz
    ld   c,$1C
    jp   call_00_3792_PrepareRelativeObjectSpawn

call_02_6cdd_ObjectAction_BirdProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6CF5
    call call_00_2976_Object_GetFacingDirection
    ld   c,$14
    cp   a,$00
    jr   z,.label6CED
    ld   c,$EC
.label6CED:
    call call_00_28c8_Object_SetXVelocity
    ld   c,$03
    call call_00_290d_Object_SetTimer1A
.label6CF5:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_27f3_Object_GetInitialYPos
    call call_00_2917_Object_CheckIfTimer1AIsZero
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
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    call call_00_2922_Object_Timer1ACountdown
    ld   c,$20
    jp   nz,call_00_28dc_Object_SetYVelocity
    ld   a,$01
    jp   call_02_72ac_SetupNewAction
.data_02_6d31:
    db   $00, $00, $56, $00, $46, $00        ;; 02:6d2f ????????
    db   $36, $00

call_02_6d39_ObjectAction_RockHard_Unk1:
    ret  

call_02_6d3a_ObjectAction_RockHard_Unk0:
    ret  

call_02_6d3b_ObjectAction_RockHard_Unk2:
    call call_00_2a5d_Object_Check5Flag2
    ret  z
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$03
    jp   call_02_72ac_SetupNewAction

call_02_6d49_ObjectAction_RockHard_Unk5:
    call call_00_2a5d_Object_Check5Flag2
    ld   a,$06
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_6d52_ObjectAction_RockHard_Unk6:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6D5C
    ld   c,$78
    call call_00_290d_Object_SetTimer1A
.label6D5C:
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    ld   a,$01
    ld   [wDC65_ProgressFlags_WWGex],a
    ld   hl,wDB6A
    set  4,[hl]
    jp   call_00_2b7a_ClearObjectThenJump

call_02_6d6d_ObjectAction_BrainOfOz_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6D82
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  [hl]
    cp   a,$0A
    ld   a,$02
    call z,call_02_72ac_SetupNewAction
    ld   a,$02
    ld   [wDCDA_BrainOfOzAndRezCounter],a
.label6D82:
    jp   call_00_233e_Object_UpdatePatternedPositionFromVelocityTable

call_02_6d85_ObjectAction_BrainOfOz_Unk2:
    call call_00_233e_Object_UpdatePatternedPositionFromVelocityTable
    ld   c,$69
    call call_00_29b7_FindObjectByID_C
    ld   a,c
    cp   a,$00
    ret  nz
    ld   c,$68
    call call_00_29b7_FindObjectByID_C
    inc  c
    ret  nz
    ld   a,[wDCD1_BrainOfOzFlag]
    and  a
    ret  nz
    ld   hl,wDCDA_BrainOfOzAndRezCounter
    dec  [hl]
    bit  7,[hl]
    jr   z,label6DA7
    ld   [hl],$02
label6DA7:
    ld   l,[hl]
    ld   h,$00
    ld   de,call_02_6db7
    add  hl,de
    ld   c,[hl]
    call call_00_290d_Object_SetTimer1A
    ld   a,$03
    jp   call_02_72ac_SetupNewAction

call_02_6db7:
    ld   c,c
    add  hl,sp
    add  hl,hl
call_02_6dba_ObjectAction_BrainOfOz_Unk3:
    call call_00_233e_Object_UpdatePatternedPositionFromVelocityTable
    call call_00_2922_Object_Timer1ACountdown
    jr   nz,.label6DD2
    ld   c,$6A
    call call_00_29ce_ObjectExistsCheck
    ret  z
    ld   a,$01
    ld   [wDCD1_BrainOfOzFlag],a
    ld   a,$02
    jp   call_02_72ac_SetupNewAction
.label6DD2:
    and  a,$07
    ld   a,$04
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6dda_ObjectAction_BrainOfOz_Unk4:
    jp   call_00_233e_Object_UpdatePatternedPositionFromVelocityTable

call_02_6ddd_ObjectAction_BrainOfOz_Unk5:
    call call_00_233e_Object_UpdatePatternedPositionFromVelocityTable
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ret  z
    ld   a,SFX_BRAIN_OF_OZ
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   c,$18
    jp   call_00_3792_PrepareRelativeObjectSpawn

call_02_6dee_ObjectAction_BrainOfOz_Unk7:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    ld   de,$0068
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
    ld   a,$08
    jp   call_02_72ac_SetupNewAction

call_02_6e09_ObjectAction_BrainOfOz_Unk8:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6E27
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   hl,.data_6e3c
    call call_00_2c20_Object_CopyPaletteToBuffer
    call call_00_288c_Object_ClearCollisionType
    call call_00_2b8b_HandleObjectFlag6ClearOrInit
    call call_00_2c67_Particle_InitBurst
    ld   c,$3C
    call call_00_290d_Object_SetTimer1A
.label6E27:
    call call_00_2c89_Particle_UpdateBurst
    ret  nz
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    ld   a,$01
    ld   [wDC66_ProgressFlags_LizardOfOz],a
    ld   hl,wDB6A
    set  4,[hl]
    jp   call_00_2b7a_ClearObjectThenJump
.data_6e3c:
    db   $00, $00, $08, $02, $04, $01, $ff, $7f

call_02_6e44_ObjectAction_BrainOfOzProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6E53
    ld   c,$00
    call call_00_28c8_Object_SetXVelocity
    ld   c,$10
    call call_00_28dc_Object_SetYVelocity
.label6E53:
    call call_00_2a68_Object_ComputePlayerXProximity
    ld   a,[wDA12_ObjectDirectionRelativeToPlayer]
    cp   a,$20
    jr   z,.label6E67
    call call_00_28be_Object_GetXVelocity
    cp   a,$10
    jr   z,.label6E6F
    inc  [hl]
    jr   .label6E6F
.label6E67:
    call call_00_28be_Object_GetXVelocity
    cp   a,$F0
    jr   z,.label6E6F
    dec  [hl]
.label6E6F:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    ld   de,$0088
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jp   nc,call_00_2b7a_ClearObjectThenJump
    ret  

call_02_6e88_ObjectAction_Cannon_Unk0:
    ld   hl,wDCD1_BrainOfOzFlag
    bit  0,[hl]
    ret  z
    ld   [hl],$00
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_XPOS_OFFSET
    ld   l,a
    ld   de,$0078
    ld   [hl],e
    inc  l
    ld   [hl],d
    ld   c,$FF
    call call_00_290d_Object_SetTimer1A
    ld   a,$01
    jp   call_02_72ac_SetupNewAction

call_02_6ea8_ObjectAction_Cannon_Unk2:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   a,SFX_DOOR2
    call nz,call_00_0ff5_QueueSoundEffectWithPriority
    call call_00_2922_Object_Timer1ACountdown
    ld   a,$04
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6eb9_ObjectAction_Cannon_Unk3:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ret  z
    ld   c,$16
    call call_00_3792_PrepareRelativeObjectSpawn
    ld   a,SFX_CANNON
    jp   call_00_0ff5_QueueSoundEffectWithPriority

call_02_6ec7_ObjectAction_CannonProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$3C
    call nz,call_00_28dc_Object_SetYVelocity
    ld   c,$67
    call call_00_29ce_ObjectExistsCheck
    ret  nz
    ld   a,l
    or   a,$01
    ld   l,a
    ld   a,[hl]
    cp   a,$06
    jr   nc,.label6EFA
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_28f1_Object_CheckIfYVelocityIsZero
    bit  7,[hl]
    ret  z
    ld   de,$0038
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  l
    ld   [hl],e
.label6EFA:
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   c,$17
    call call_00_3792_PrepareRelativeObjectSpawn
    jp   call_00_2b7a_ClearObjectThenJump

call_02_6f07:
    call call_00_2a5d_Object_Check5Flag2
    jp   nz,call_00_2b7a_ClearObjectThenJump
    ret  

call_02_6f0e_ObjectAction_Unk_None:
    ret  

call_02_6f0f_ObjectAction_Rez_Unk0:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ret  z
    ld   c,$20
    call call_00_28c8_Object_SetXVelocity
    ld   c,$00
    call call_00_28dc_Object_SetYVelocity
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  [hl]
    cp   a,$0A
    ld   a,$02
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6f29_ObjectAction_Rez_Unk2:
    call call_00_251c_Object_CheckHorizontalBoundingBox_UpdateFacing
    call call_02_7002
    ld   c,$38
    jp   nc,call_00_28dc_Object_SetYVelocity
    ret  

call_02_6f35_ObjectAction_Rez_Unk3:
    call call_02_7002
    ld   a,$04
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_6f3e_ObjectAction_Rez_Unk5:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   c,$00
    call nz,call_00_28dc_Object_SetYVelocity
    call call_02_6FD3
    ret  nc
    ld   c,$00
    call call_00_290d_Object_SetTimer1A
    ld   a,$06
    jp   call_02_72ac_SetupNewAction

call_02_6f54_ObjectAction_Rez_Unk6:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ret  z
    call call_00_2917_Object_CheckIfTimer1AIsZero
    inc  [hl]
    cp   a,$0A
    ld   a,$08
    jp   z,call_02_72ac_SetupNewAction
    ret  

call_02_6f64_ObjectAction_Rez_Unk8:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6F74
    call call_00_2826_Object_ResetToInitialXPos
    call call_00_27e4_Object_ResetToInitialYPos
    ld   c,$06
    call call_00_290d_Object_SetTimer1A
.label6F74:
    call call_00_2917_Object_CheckIfTimer1AIsZero
    jr   z,.label6F93
    ld   a,[wDC71_FrameCounter]
    and  a,$3F
    ret  nz
    call call_00_2922_Object_Timer1ACountdown
    jr   z,.label6F93
    ld   a,[wDCDA_BrainOfOzAndRezCounter]
    ld   c,$1D
    and  a,$01
    jp   z,call_00_3792_PrepareRelativeObjectSpawn
    ld   c,$1E
    jp   call_00_3792_PrepareRelativeObjectSpawn
.label6F93:
    ld   c,$71
    call call_00_29ce_ObjectExistsCheck
    ld   a,$00
    jp   nz,call_02_72ac_SetupNewAction
    ret  

call_02_6f9e_ObjectAction_Rez_Unk9:
    jp   call_02_6FD3

call_02_6fa1_ObjectAction_Rez_Unk10:
    call call_02_7002
    ld   a,$0B
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_6faa_ObjectAction_Rez_Unk11:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label6FBE
    ld   a,SFX_LOUD_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   c,$B4
    call call_00_290d_Object_SetTimer1A
    ld   c,$30
    call call_00_28dc_Object_SetYVelocity
.label6FBE:
    call call_02_7002
    ret  c
    call call_00_2922_Object_Timer1ACountdown
    ret  nz
    ld   a,$01
    ld   [wDC67_ProgressFlags_ChannelZ],a
    ld   hl,wDB6A
    set  4,[hl]
    jp   call_00_2b7a_ClearObjectThenJump

call_02_6FD3:
    call call_00_28f1_Object_CheckIfYVelocityIsZero
    bit  7,a
    jr   nz,.label6FE0
    cp   a,$20
    ld   a,$20
    jr   nc,.label6FE3
.label6FE0:
    ld   a,[hl]
    add  a,$04
.label6FE3:
    ld   [hl],a
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    ld   de,$0024
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
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
    call call_00_28dc_Object_SetYVelocity
    pop  af
    ret  

call_02_7002:
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    ld   de,isrSerial
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  hl
    ld   [hl],e
    ret  

call_02_7019_ObjectAction_Unk_None:
    ret  

call_02_701a_ObjectAction_Meteor_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    ld   a,SFX_METEOR
    call nz,call_00_0ff5_QueueSoundEffectWithPriority
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_2766_Object_ResetYIfAboveStart
    ld   a,$02
    jp   nc,call_02_72ac_SetupNewAction
    ret  

call_02_702e_ObjectAction_RezProjectile_Update:
    call call_00_29f5_Object_ClearActiveFlagAndCheck
    jr   z,.label7056
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
    jr   z,.label704F
    xor  a
    sub  [hl]
    ld   c,a
.label704F:
    call call_00_28c8_Object_SetXVelocity
    pop  bc
    call call_00_28dc_Object_SetYVelocity
.label7056:
    call call_00_24c0_Object_IntegrateXVelocity
    call call_00_2475_Object_ApplyVerticalVelocity_Clamped
    call call_00_28f1_Object_CheckIfYVelocityIsZero
    bit  7,a
    ret  z
    ld   de,$0070
    ld   h, HIGH(wD800_ObjectMemory)
    ld   a,[wDA00_CurrentObjectAddrLo]
    or   a,OBJECT_YPOS_OFFSET
    ld   l,a
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  c
    ld   [hl],d
    dec  hl
    ld   [hl],e
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$01
    jp   call_02_72ac_SetupNewAction
.data_02_707f:
    db   $30, $28, $30, $28, $20, $30, $20, $30        ;; 02:707f ????????
    db   $40, $10, $40, $10, $50, $08, $50, $08        ;; 02:7087 ????????
