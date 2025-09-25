call_02_47b4_PlayerAction_Spawn:
; Checks bit 4 of wD805 (a flag for spawning in a level). 
; If the bit is not set, it returns. If set, it:
; Clears state variables (wDCA2, wDCA3, wDC87).
; Sets wDCA4 = 05h (some delay or counter).
; Plays sound effect $0E via call_00_0ff5_QueueSoundEffectWithPriority
    ld   HL, wD805                                     ;; 02:47b4 $21 $05 $d8
    bit  4, [HL]                                       ;; 02:47b7 $cb $66
    ret  Z                                             ;; 02:47b9 $c8
    xor  A, A                                          ;; 02:47ba $af
    ld   [wDCA2], A                                    ;; 02:47bb $ea $a2 $dc
    ld   [wDCA3], A                                    ;; 02:47be $ea $a3 $dc
    ld   [wDC87], A                                    ;; 02:47c1 $ea $87 $dc
    ld   A, $05                                        ;; 02:47c4 $3e $05
    ld   [wDCA4], A                                    ;; 02:47c6 $ea $a4 $dc
    ld   A, $0e                                        ;; 02:47c9 $3e $0e
    jp   call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:47cb $c3 $f5 $0f

call_02_47ce_PlayerAction_Idle:
; Also checks bit 4 of wD805. If set:
; Sets bit 6 of wDC80 (marking a new sub-state).
; Clears wDC86, wDC8C, and wDC87.
; Sets wDC83 = F0h (a countdown timer).
; Regardless, it checks if wDC81 == 40h and, if so, calls call_00_1bbc_CheckPlayerLevelTriggers.
; It then calls call_02_4f11 to potentially switch actions.
; Finally, it decrements the countdown timer at wDC83. If it hits zero, it switches player action to $02.
    ld   HL, wD805                                     ;; 02:47ce $21 $05 $d8
    bit  4, [HL]                                       ;; 02:47d1 $cb $66
    jr   Z, .jr_02_47e9                                ;; 02:47d3 $28 $14
    ld   HL, wDC80                                     ;; 02:47d5 $21 $80 $dc
    set  6, [HL]                                       ;; 02:47d8 $cb $f6
    xor  A, A                                          ;; 02:47da $af
    ld   [wDC86], A                                    ;; 02:47db $ea $86 $dc
    ld   [wDC8C], A                                    ;; 02:47de $ea $8c $dc
    ld   [wDC87], A                                    ;; 02:47e1 $ea $87 $dc
    ld   A, $f0                                        ;; 02:47e4 $3e $f0
    ld   [wDC83], A                                    ;; 02:47e6 $ea $83 $dc
.jr_02_47e9:
    ld   A, [wDC81]                                    ;; 02:47e9 $fa $81 $dc
    cp   A, $40                                        ;; 02:47ec $fe $40
    call Z, call_00_1bbc_CheckPlayerLevelTriggers                               ;; 02:47ee $cc $bc $1b
    call call_02_4f11_ChooseNextActionBasedOnLevel                                  ;; 02:47f1 $cd $11 $4f
    ld   HL, wDC83                                     ;; 02:47f4 $21 $83 $dc
    dec  [HL]                                          ;; 02:47f7 $35
    ld   A, $02                                        ;; 02:47f8 $3e $02
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:47fa $ca $f9 $54
    ret                                                ;; 02:47fd $c9

call_02_47fe_PlayerAction_IdleAnimation:
; Simpler variant of the above. Checks if wDC81 == 40h, and if so, calls the level trigger routine. 
; Then calls call_02_4f11 to update the player’s action. No countdown logic.
    ld   A, [wDC81]                                    ;; 02:47fe $fa $81 $dc
    cp   A, $40                                        ;; 02:4801 $fe $40
    call Z, call_00_1bbc_CheckPlayerLevelTriggers                               ;; 02:4803 $cc $bc $1b
    call call_02_4f11_ChooseNextActionBasedOnLevel                                  ;; 02:4806 $cd $11 $4f
    ret                                                ;; 02:4809 $c9

call_02_480a:
; Checks bit 4 of wD805. If set, sets wDC87 = 02h (possibly a movement or animation flag). 
; Then calls call_02_4f11.
    ld   HL, wD805                                     ;; 02:480a $21 $05 $d8
    bit  4, [HL]                                       ;; 02:480d $cb $66
    jr   Z, .jr_02_4816                                ;; 02:480f $28 $05
    ld   A, $02                                        ;; 02:4811 $3e $02
    ld   [wDC87], A                                    ;; 02:4813 $ea $87 $dc
.jr_02_4816:
    call call_02_4f11_ChooseNextActionBasedOnLevel                                  ;; 02:4816 $cd $11 $4f
    ret                                                ;; 02:4819 $c9

call_02_481a:
; Simply clears wDC87 (writes 0) and returns. 
; Used to reset a temporary player state or movement flag.
    xor  A, A                                          ;; 02:481a $af
    ld   [wDC87], A                                    ;; 02:481b $ea $87 $dc
    ret                                                ;; 02:481e $c9

call_02_481f_IncrementDCACWithClamp:
; Increments wDCAC by 2 but clamps the value to a maximum of $41. 
; Used for a position, animation frame, or velocity value that should not exceed a limit.
    ld   A, [wDCAC]                                    ;; 02:481f $fa $ac $dc
    add  A, $02                                        ;; 02:4822 $c6 $02
    cp   A, $41                                        ;; 02:4824 $fe $41
    jr   C, .jr_02_482a                                ;; 02:4826 $38 $02
    ld   A, $41                                        ;; 02:4828 $3e $41
.jr_02_482a:
    ld   [wDCAC], A                                    ;; 02:482a $ea $ac $dc
    ret                                                ;; 02:482d $c9

call_02_482e:
    ld   A, [wD809]                                    ;; 02:482e $fa $09 $d8
    srl  A                                             ;; 02:4831 $cb $3f
    ld   C, A                                          ;; 02:4833 $4f
    ld   A, $02                                        ;; 02:4834 $3e $02
    sub  A, C                                          ;; 02:4836 $91
    jr   NC, .jr_02_483a                               ;; 02:4837 $30 $01
    xor  A, A                                          ;; 02:4839 $af
.jr_02_483a:
    ld   [wDC87], A                                    ;; 02:483a $ea $87 $dc
    ret                                                ;; 02:483d $c9

call_02_483e:
    ld   hl,wD805
    bit  4,[hl]
    ret  z
    ld   a,$05
    call call_00_0ff5_QueueSoundEffectWithPriority
    xor  a
    jp   call_00_0624_SetPhase_TimersAndFlags

call_02_484d:
    ld   HL, wD805                                     ;; 02:484d $21 $05 $d8
    bit  4, [HL]                                       ;; 02:4850 $cb $66
    jr   Z, .jr_02_4864                                ;; 02:4852 $28 $10
    ld   A, $1c                                        ;; 02:4854 $3e $1c
    ld   [wDC8C], A                                    ;; 02:4856 $ea $8c $dc
    ld   [wDC8E], A                                    ;; 02:4859 $ea $8e $dc
    call call_02_4e01_SetOneTimeFlag                                  ;; 02:485c $cd $01 $4e
    ld   A, $0a                                        ;; 02:485f $3e $0a
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:4861 $cd $f5 $0f
.jr_02_4864:
    ld   A, $3c                                        ;; 02:4864 $3e $3c
    ld   [wDC7E], A                                    ;; 02:4866 $ea $7e $dc
    ld   A, [wDC8E]                                    ;; 02:4869 $fa $8e $dc
    and  A, A                                          ;; 02:486c $a7
    ld   A, $01                                        ;; 02:486d $3e $01
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:486f $ca $f9 $54
    ret                                                ;; 02:4872 $c9

call_02_4873:
    ld   HL, wD805                                     ;; 02:4873 $21 $05 $d8
    bit  4, [HL]                                       ;; 02:4876 $cb $66
    jr   Z, .jr_02_4883                                ;; 02:4878 $28 $09
    xor  A, A                                          ;; 02:487a $af
    ld   [wDC87], A                                    ;; 02:487b $ea $87 $dc
    ld   A, $0d                                        ;; 02:487e $3e $0d
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:4880 $cd $f5 $0f
.jr_02_4883:
    ld   A, $3c                                        ;; 02:4883 $3e $3c
    ld   [wDC7E], A                                    ;; 02:4885 $ea $7e $dc
    ret                                                ;; 02:4888 $c9

call_02_4889:
    xor  A, A                                          ;; 02:4889 $af
    ld   [wDC87], A                                    ;; 02:488a $ea $87 $dc
    ld   A, $3c                                        ;; 02:488d $3e $3c
    ld   [wDC7E], A                                    ;; 02:488f $ea $7e $dc
    ld   A, [wD805]                                    ;; 02:4892 $fa $05 $d8
    and  A, $04                                        ;; 02:4895 $e6 $04
    ret  Z                                             ;; 02:4897 $c8
    ld   A, [wDB6A]                                    ;; 02:4898 $fa $6a $db
    or   A, $02                                        ;; 02:489b $f6 $02
    ld   [wDB6A], A                                    ;; 02:489d $ea $6a $db
    ret                                                ;; 02:48a0 $c9

call_02_48a1:
    ld   HL, wD805                                     ;; 02:48a1 $21 $05 $d8
    bit  4, [HL]                                       ;; 02:48a4 $cb $66
    ld   A, $1d                                        ;; 02:48a6 $3e $1d
    call NZ, call_00_0ff5_QueueSoundEffectWithPriority                              ;; 02:48a8 $c4 $f5 $0f
    ld   C, $11                                        ;; 02:48ab $0e $11
    jp   call_02_4db1_CheckPlayerObjectXDistance                                    ;; 02:48ad $c3 $b1 $4d

call_02_48b0:
    ld   A, [wD805]                                    ;; 02:48b0 $fa $05 $d8
    and  A, $04                                        ;; 02:48b3 $e6 $04
    ret  Z                                             ;; 02:48b5 $c8
    ld   HL, wDB6A                                     ;; 02:48b6 $21 $6a $db
    set  4, [HL]                                       ;; 02:48b9 $cb $e6
    ret                                                ;; 02:48bb $c9

call_02_48bc:
    ld   HL, wD805                                     ;; 02:48bc $21 $05 $d8
    bit  4, [HL]                                       ;; 02:48bf $cb $66
    jr   Z, .jr_02_48d6                                ;; 02:48c1 $28 $13
    ld   A, $06                                        ;; 02:48c3 $3e $06
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:48c5 $cd $f5 $0f
    ld   A, $2a                                        ;; 02:48c8 $3e $2a
    ld   [wDC8C], A                                    ;; 02:48ca $ea $8c $dc
    ld   [wDC8E], A                                    ;; 02:48cd $ea $8e $dc
    call call_02_4df6_FlagCollisionActive                                  ;; 02:48d0 $cd $f6 $4d
    call call_02_4e01_SetOneTimeFlag                                  ;; 02:48d3 $cd $01 $4e
.jr_02_48d6:
    ld   A, [wDC8E]                                    ;; 02:48d6 $fa $8e $dc
    and  A, A                                          ;; 02:48d9 $a7
    ret  NZ                                            ;; 02:48da $c0
    ld   A, [wDC81]                                    ;; 02:48db $fa $81 $dc
    and  A, $02                                        ;; 02:48de $e6 $02
    ld   A, $0f                                        ;; 02:48e0 $3e $0f
    jp   NZ, call_02_54f9_SwitchPlayerAction                              ;; 02:48e2 $c2 $f9 $54
    jp   call_02_4dce_SetTriggerByLevel                                    ;; 02:48e5 $c3 $ce $4d

call_02_48e8:
    ld   HL, wD805                                     ;; 02:48e8 $21 $05 $d8
    bit  4, [HL]                                       ;; 02:48eb $cb $66
    jr   Z, .jr_02_4902                                ;; 02:48ed $28 $13
.jr_02_48ef:
    ld   A, $07                                        ;; 02:48ef $3e $07
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:48f1 $cd $f5 $0f
    ld   A, $3e                                        ;; 02:48f4 $3e $3e
    ld   [wDC8C], A                                    ;; 02:48f6 $ea $8c $dc
    ld   [wDC8E], A                                    ;; 02:48f9 $ea $8e $dc
    call call_02_4df6_FlagCollisionActive                                  ;; 02:48fc $cd $f6 $4d
    call call_02_4e01_SetOneTimeFlag                                  ;; 02:48ff $cd $01 $4e
.jr_02_4902:
    ld   A, [wDC8E]                                    ;; 02:4902 $fa $8e $dc
    and  A, A                                          ;; 02:4905 $a7
    ret  NZ                                            ;; 02:4906 $c0
    ld   A, [wDC81]                                    ;; 02:4907 $fa $81 $dc
    and  A, $02                                        ;; 02:490a $e6 $02
    jr   NZ, .jr_02_48ef                               ;; 02:490c $20 $e1
    jp   call_02_4dce_SetTriggerByLevel                                    ;; 02:490e $c3 $ce $4d

call_02_4911:
    ld   HL, wD805                                     ;; 02:4911 $21 $05 $d8
    bit  4, [HL]                                       ;; 02:4914 $cb $66
    jr   Z, .jr_02_492a                                ;; 02:4916 $28 $12
    ld   A, $04                                        ;; 02:4918 $3e $04
    call call_00_0ff5_QueueSoundEffectWithPriority                                  ;; 02:491a $cd $f5 $0f
    ld   HL, wDC80                                     ;; 02:491d $21 $80 $dc
    set  0, [HL]                                       ;; 02:4920 $cb $c6
    ld   A, $01                                        ;; 02:4922 $3e $01
    ld   [wDC7F], A                                    ;; 02:4924 $ea $7f $dc
    call call_02_4e01_SetOneTimeFlag                                  ;; 02:4927 $cd $01 $4e
.jr_02_492a:
    ld   A, [wD805]                                    ;; 02:492a $fa $05 $d8
    and  A, $04                                        ;; 02:492d $e6 $04
    ret  Z                                             ;; 02:492f $c8
    xor  A, A                                          ;; 02:4930 $af
    ld   [wDC7F], A                                    ;; 02:4931 $ea $7f $dc
    ld   HL, wDABE                                     ;; 02:4934 $21 $be $da
    bit  7, [HL]                                       ;; 02:4937 $cb $7e
    ret  Z                                             ;; 02:4939 $c8
    ld   HL, wDC80                                     ;; 02:493a $21 $80 $dc
    set  6, [HL]                                       ;; 02:493d $cb $f6
    ld   C, $11                                        ;; 02:493f $0e $11
    ld   HL, wDABE                                     ;; 02:4941 $21 $be $da
    bit  7, [HL]                                       ;; 02:4944 $cb $7e
    jr   Z, .jr_02_4953                                ;; 02:4946 $28 $0b
    ld   C, $01                                        ;; 02:4948 $0e $01
    ld   A, [wDC81]                                    ;; 02:494a $fa $81 $dc
    and  A, $30                                        ;; 02:494d $e6 $30
    jr   Z, .jr_02_4953                                ;; 02:494f $28 $02
    ld   C, $03                                        ;; 02:4951 $0e $03
.jr_02_4953:
    ld   A, C                                          ;; 02:4953 $79
    jp   call_02_54f9_SwitchPlayerAction                                  ;; 02:4954 $c3 $f9 $54

call_02_4957:
    ld   HL, wD805                                     ;; 02:4957 $21 $05 $d8
    bit  4, [HL]                                       ;; 02:495a $cb $66
    jr   Z, .jr_02_4966                                ;; 02:495c $28 $08
    ld   A, $01                                        ;; 02:495e $3e $01
    ld   [wDC8E], A                                    ;; 02:4960 $ea $8e $dc
    call call_02_4e01_SetOneTimeFlag                                  ;; 02:4963 $cd $01 $4e
.jr_02_4966:
    ld   A, [wDC8E]                                    ;; 02:4966 $fa $8e $dc
    and  A, A                                          ;; 02:4969 $a7
    ret  NZ                                            ;; 02:496a $c0
    ld   A, [wDC81]                                    ;; 02:496b $fa $81 $dc
    and  A, $30                                        ;; 02:496e $e6 $30
    ld   A, $03                                        ;; 02:4970 $3e $03
    jp   NZ, call_02_54f9_SwitchPlayerAction                              ;; 02:4972 $c2 $f9 $54
    ld   A, $01                                        ;; 02:4975 $3e $01
    jp   call_02_54f9_SwitchPlayerAction                                  ;; 02:4977 $c3 $f9 $54

call_02_497a:
    ld   HL, wD805                                     ;; 02:497a $21 $05 $d8
    bit  4, [HL]                                       ;; 02:497d $cb $66
    ld   A, $08                                        ;; 02:497f $3e $08
    call NZ, call_00_0ff5_QueueSoundEffectWithPriority                              ;; 02:4981 $c4 $f5 $0f
    xor  A, A                                          ;; 02:4984 $af
    ld   [wDC87], A                                    ;; 02:4985 $ea $87 $dc
    ret                                                ;; 02:4988 $c9

call_02_4989:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,call_02_49a8
    ld   a,$30
    ld   [wDC8C],a
    ld   [wDC8E],a
    call call_02_4e01_SetOneTimeFlag
    call call_00_06f6_HandleGenericHitResponse
    ld   a,$0B
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$14
    call entry_02_72ac_LoadObjectData

call_02_49a8:
    ld   a,[wDC8E]
    and  a
    ld   a,$01
    jp   z,entry_02_54f9_SwitchPlayerAction
    ret  
    
call_02_49b2:  
    ret  

call_02_49b3:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,.label49CE
    ld   hl,wDC80
    set  6,[hl]
    xor  a
    ld   [wDC9B],a
    ld   [wDC8C],a
    ld   [wDC8D],a
    ld   a,01
    ld   [wDC87],a
.label49CE:
    call call_02_4ee7_MapCollisionFlags
    ld   hl,wDC9D
    cp   a,$FF
    jr   z,.label49D9
    ld   [hl],a
.label49D9:
    ld   e,[hl]
    ld   d,$00
    ld   hl,.data_02_4a1d
    add  hl,de
    ld   a,[hl]
    and  a,$20
    ld   [wD80D_PlayerFacingDirection],a
    ld   a,[hl]
    and  a,$40
    ld   [wDC7A],a
    ld   hl,.data_02_4a15
    add  hl,de
    ld   c,[hl]
    ld   hl,wDC9C
    dec  [hl]
    bit  7,[hl]
    jr   z,.label4A05
    ld   [hl],$05
    ld   hl,wDC9B
    inc  [hl]
    ld   a,[hl]
    sub  a,$07
    jr   nz,.label4A05
    ld   [hl],a
.label4A05:
    ld   a,[wDC9B]
    add  c
    ld   hl,wD80A
    cp   [hl]
    ret  z
    ld   [hl],a
    ld   hl,wDB66
    set  0,[hl]
    ret  
.data_02_4a15:
    db   $7d, $4f, $48, $56, $7d, $56, $48, $4f        ;; 02:4a11 ????????
.data_02_4a1d:
    db   $00, $00, $00, $00, $60, $20, $20, $20        ;; 02:4a19 ????????

call_02_4a25:
    xor  a
    ld   [wDC87],a
    ld   a,$3C
    ld   [wDC7E],a
    ld   a,[wDC93]
    cp   a,$28
    jp   z,jp_00_06da
    ret  

call_02_4a37:
    xor  A, A                                          ;; 02:4a37 $af
    ld   [wDC87], A                                    ;; 02:4a38 $ea $87 $dc
    ld   A, $3c                                        ;; 02:4a3b $3e $3c
    ld   [wDC7E], A                                    ;; 02:4a3d $ea $7e $dc
    ld   A, $01                                        ;; 02:4a40 $3e $01
    ld   [wDC29], A                                    ;; 02:4a42 $ea $29 $dc
    ld   A, [wDC91]                                    ;; 02:4a45 $fa $91 $dc
    cp   A, $b0                                        ;; 02:4a48 $fe $b0
    ret  C                                             ;; 02:4a4a $d8
    ld   HL, wDB6A                                     ;; 02:4a4b $21 $6a $db
    set  1, [HL]                                       ;; 02:4a4e $cb $ce
    ret                                                ;; 02:4a50 $c9

call_02_4a51:
    ret  

call_02_4a52:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4A61
    ld   a,$01
    ld   [wDC8E],a
    call call_02_4e01_SetOneTimeFlag
label4A61:
    ld   a,[wDC8E]
    and  a
    jp   z,call_02_4dce_SetTriggerByLevel
    ret  

call_02_4a69:
    ld   c,$51
    jp   call_02_4db1_CheckPlayerObjectXDistance

call_02_4a6e:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4A87
    ld   a,$04
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   hl,wDC80
    set  0,[hl]
    ld   a,$01
    ld   [wDC7F],a
    ld   [wDC87],a
label4A87:
    ld   a,[wD805]
    and  a,$04
    ret  z
    xor  a
    ld   [wDC7F],a
    ld   hl,wDC80
    set  6,[hl]
    ld   a,$19
    jp   entry_02_54f9_SwitchPlayerAction

call_02_4a9b:
    ld   a,$01
    ld   [wDC87],a
    ret  

call_02_4aa1:
    ld   a,$01
    ld   [wDC87],a
    ld   a,$04
    ld   [wDC9D],a
    ret  

call_02_4aac:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,.label4ACC
    ld   hl,wDC80
    set  6,[hl]
    xor  a
    ld   [wDC9F],a
    ld   [wDC8C],a
    ld   [wDC8D],a
    ld   a,$01
    ld   [wDC87],a
    ld   a,$00
    ld   [wDC9E],a
.label4ACC:
    ld   hl,wDC9E
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   de,call_02_4adb
    add  hl,de
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    jp   hl

call_02_4adb:
    rst  $18
    ld   c,d
    ld   h,[hl]
    ld   c,e
    call call_02_4ee7_MapCollisionFlags
    ld   hl,wDCA1
    cp   a,$FF
    jr   z,.label4AEA
    ld   [hl],a
.label4AEA:
    ld   e,[hl]
    ld   d,00
    ld   hl,.data_02_4b5e
    add  hl,de
    ld   a,[hl]
    and  a,$20
    ld   [wD80D_PlayerFacingDirection],a
    ld   a,[hl]
    and  a,$40
    ld   [wDC7A],a
    ld   hl,.data_02_4b56
    add  hl,de
    ld   c,[hl]
    ld   hl,wDCA0
    dec  [hl]
    bit  7,[hl]
    jr   z,.label4B16
    ld   [hl],$05
    ld   hl,wDC9F
    inc  [hl]
    ld   a,[hl]
    sub  a,$0A
    jr   nz,.label4B16
    ld   [hl],a
.label4B16:
    ld   a,[wDC9F]
    add  c
    ld   hl,wD80A
    cp   [hl]
    jr   z,.label4B26
    ld   [hl],a
    ld   hl,wDB66
    set  0,[hl]
.label4B26:
    ld   a,[wDC81]
    and  a,$02
    jr   z,.label4B32
    ld   a,$0E
    call entry_02_54f9_SwitchPlayerAction
.label4B32:
    ld   a,[wDC81]
    and  a,$01
    jr   z,.call_02_4B55
    ld   a,$04
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   hl,wDC80
    set  0,[hl]
    call call_02_4e01_SetOneTimeFlag
    ld   a,$01
    ld   [wDC9E],a
    xor  a
    ld   [wDC9F],a
    ld   a,$01
    ld   [wDC7F],a
    ret  
.call_02_4B55:
    ret  
.data_02_4b56:
    db   $73, $d1, $c7, $db, $73, $db, $c7, $d1
.data_02_4b5e:
    db   $00, $00, $00, $00, $60, $20, $20, $20

call_02_4B66:
    call call_02_4ee7_MapCollisionFlags
    ld   hl,wDCA1
    cp   a,$FF
    jr   z,label4B71
    ld   [hl],a
label4B71:
    ld   hl,wDCA0
    dec  [hl]
    bit  7,[hl]
    jr   z,label4B7F
    ld   [hl],$02
    ld   hl,wDC9F
    inc  [hl]
label4B7F:
    ld   a,[wDC9F]
    ld   hl,wDCA1
    add  [hl]
    and  a,$07
    add  a,$E5
    ld   hl,wD80A
    cp   [hl]
    ret  z
    ld   [hl],a
    ld   a,$00
    ld   [wD80D_PlayerFacingDirection],a
    ld   a,$00
    ld   [wDC7A],a
    ld   hl,wDB66
    set  0,[hl]
    ld   a,[wDC9F]
    cp   a,$08
    ret  c
    ld   a,$00
    ld   [wDC9E],a
    xor  a
    ld   [wDC9F],a
    ld   [wDC7F],a
    ld   hl,wDC80
    set  6,[hl]
    ret  

call_02_4bb7:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4BDC
    ld   a,$03
    ld   [wDC87],a
    xor  a
    ld   [wDCA2],a
    ld   [wDCA3],a
    ld   a,$05
    ld   [wDCA4],a
    ld   a,$01
    ld   [wDCA5],a
    ld   [wDCA6],a
    ld   hl,wDC80
    set  6,[hl]
label4BDC:
    ld   a,[wDC81]
    bit  6,a
    call nz,call_00_1bbc_CheckPlayerLevelTriggers
    call call_02_4E0C_UpdateActionSequence
    ld   a,[wDCA5]
    and  a
    jr   z,call_02_4C11
    ld   a,[wDCA6]
    and  a
    jr   z,call_02_4C10
    ld   c,a
    ld   a,[wDCA5]
    cp   a,$01
    ret  nz
    ld   hl,call_02_4C16
label4BFD:
    inc  hl
    ldi  a,[hl]
    cp   a,$FF
    ret  z
    cp   c
    jr   nz,label4BFD
    ld   a,[wD80D_PlayerFacingDirection]
    cp   [hl]
    ret  nz
    ld   a,$20
    ld   [wDC8C],a
    ret  

call_02_4C10:
    ret  

call_02_4C11:
    ld   a,[wDCA6]
    and  a
    ret  z
call_02_4C16:
    ret  
    
    db   $06, $00, $0d, $00, $09, $00, $0a        ;; 02:4c17 ????????
    db   $00, $05, $20, $0b, $20, $0c, $20, $0e        ;; 02:4c1e ????????
    db   $20, $0f, $20, $10, $20, $ff

call_02_4c2c:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4C46
    ld   a,$06
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$2A
    ld   [wDC8C],a
    ld   [wDC8E],a
    call call_02_4df6_FlagCollisionActive
    call call_02_4e01_SetOneTimeFlag
label4C46:
    ld   a,[wDC8E]
    and  a
    ret  nz
    ld   a,[wDC81]
    and  a,$02
    ld   a,$26
    jp   nz,entry_02_54f9_SwitchPlayerAction
    jp   call_02_4dce_SetTriggerByLevel

call_02_4c58:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4C72
    ld   a,$07
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   a,$3E
    ld   [wDC8C],a
    ld   [wDC8E],a
    call call_02_4df6_FlagCollisionActive
    call call_02_4e01_SetOneTimeFlag
label4C72:
    ld   a,[wDC8E]
    and  a
    jp   z,call_02_4dce_SetTriggerByLevel
    ret  

call_02_4c7a:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4CA1
    xor  a
    ld   [wDCA2],a
    ld   a,$03
    ld   [wDCA3],a
    ld   a,$0B
    ld   [wDCA4],a
    ld   a,$04
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   hl,wDC80
    set  0,[hl]
    ld   a,$01
    ld   [wDC7F],a
    call call_02_4e01_SetOneTimeFlag
label4CA1:
    jp   call_02_4E0C_UpdateActionSequence

call_02_4ca4:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4CB3
    ld   a,$01
    ld   [wDC8E],a
    call call_02_4e01_SetOneTimeFlag
label4CB3:
    ld   a,[wDC8E]
    and  a
    ld   a,$24
    jp   z,entry_02_54f9_SwitchPlayerAction
    ret  

call_02_4cbd:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4CD4
    ld   a,$1C
    ld   [wDC8C],a
    ld   [wDC8E],a
    call call_02_4e01_SetOneTimeFlag
    ld   a,$0A
    call call_00_0ff5_QueueSoundEffectWithPriority
label4CD4:
    ld   a,$3C
    ld   [wDC7E],a
    ld   a,[wDC8E]
    and  a
    ld   a,$24
    jp   z,entry_02_54f9_SwitchPlayerAction
    ret  

call_02_4ce3:
    ld   a,$06
    call call_00_0ff5_QueueSoundEffectWithPriority
    call call_02_4e01_SetOneTimeFlag
    ld   a,$31
    call entry_02_54f9_SwitchPlayerAction
    call call_02_4df6_FlagCollisionActive
    ld   hl,wDABE
    bit  7,[hl]
    jr   z,call_02_4d02
    ld   a,$1E
    ld   [wDC8C],a
    ld   [wDC8E],a
call_02_4d02:
    ld   a,[wDC8E]
    and  a
    ret  nz
    ld   a,[wDC81]
    and  a,$02
    ld   a,$32
    jp   nz,entry_02_54f9_SwitchPlayerAction
    jp   call_02_4dce_SetTriggerByLevel

call_02_4d14:
    ld   a,$07
    call call_00_0ff5_QueueSoundEffectWithPriority
    call call_02_4e01_SetOneTimeFlag
    ld   a,$33
    call entry_02_54f9_SwitchPlayerAction
    call call_02_4df6_FlagCollisionActive
    ld   hl,wDABE
    bit  7,[hl]
    jr   z,call_02_4d33
    ld   a,$36
    ld   [wDC8C],a
    ld   [wDC8E],a
call_02_4d33:
    ld   a,[wDC8E]
    and  a
    ret  nz
    ld   a,[wDC81]
    and  a,$02
    ld   a,$32
    jp   nz,entry_02_54f9_SwitchPlayerAction
    jp   call_02_4dce_SetTriggerByLevel

call_02_4d45:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4D5E
    ld   a,$04
    call call_00_0ff5_QueueSoundEffectWithPriority
    ld   hl,wDC80
    set  0,[hl]
    ld   a,$01
    ld   [wDC7F],a
    call call_02_4e01_SetOneTimeFlag
label4D5E:
    ld   a,[wD805]
    and  a,$04
    ret  z
    xor  a
    ld   [wDC7F],a
    ld   hl,wDC80
    set  6,[hl]
    ld   a,$30
    jp   entry_02_54f9_SwitchPlayerAction

call_02_4d72:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4D81
    ld   a,$01
    ld   [wDC8E],a
    call call_02_4e01_SetOneTimeFlag
label4D81:
    ld   a,[wDC8E]
    and  a
    ld   a,$30
    jp   z,entry_02_54f9_SwitchPlayerAction
    ret  

call_02_4d8b:
    ld   hl,wD805
    bit  4,[hl]
    jr   z,label4DA2
    ld   a,$1C
    ld   [wDC8C],a
    ld   [wDC8E],a
    call call_02_4e01_SetOneTimeFlag
    ld   a,$0A
    call call_00_0ff5_QueueSoundEffectWithPriority
label4DA2:
    ld   a,$3C
    ld   [wDC7E],a
    ld   a,[wDC8E]
    and  a
    ld   a,$30
    jp   z,entry_02_54f9_SwitchPlayerAction
    ret  
