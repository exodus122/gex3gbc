; ==================================================================
; Bank 2. One routine per player action - the "what does Gex do this frame" half of
; the player, with the machinery that drives it next door in
; bank02_update_player.asm and the table that reaches these routines in
; bank02_entity_pointer_tables.asm.
;
; The shape every action shares
; -----------------------------
; call_02_4f32_Player_UpdateMain calls exactly one of these per frame, through the
; pointer in wD802_Player_ActionFunc. They are not state machines - they run once
; and return, and everything that persists lives in WRAM. Almost all of them are
; built from the same three parts:
;
;   ld HL, wD805_Player_ActionState / bit ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]
;       the setup gate. The body under it runs on the first frame of the action
;       only - queue the sound effect, set the launch velocity, block a button - and
;       is skipped on every frame after. Player_UpdateMain clears that bit at the
;       end of the frame, which is what makes it a one-shot
;
;   and A, ACTION_STATE_ANIM_ENDED
;       the teardown gate. True on the single frame the animation wraps, which is
;       how an action that plays once knows it is finished
;
;   jp call_02_54f9_Player_RequestAction
;       the exit. Actions do not fall into one another; they ask for the next action
;       and return, and the request lands at the top of the next frame
;
; Nothing here reads the pad directly - wDC81_Player_EffectiveInputs is the filtered
; copy, and the two buttons are one-frame events because
; wDC80_ButtonBlockingFlags suppresses them until release.
;
; Airborne actions and wDC8E_InitialYVelocity
; -------------------------------------------
; Every jump, fall and knockback sets wDC8E_InitialYVelocity nonzero on its first
; frame and then does nothing until call_02_5267_Player_ApplyYVelocity zeroes it on
; landing. So `ld A, [wDC8E_InitialYVelocity] / and A / ret NZ` is this file's idiom
; for "still in the air, come back next frame", and the code after it is the landing
; case. Read it that way and the jump, double jump, fall, blown-upwards and both
; vehicle jumps are all the same six lines.
;
; Three characters, one table
; ---------------------------
; Gex has three movement sets - on foot, on the snowboard in
; MAP_GEXTREME_SPORTS1, and on the kangaroo in MAP_MARSUPIAL_MADNESS1 - and the
; vehicle sets are not variations, they are separate action ids with their own
; routines. That is why jump, fall, take-damage and land each appear three times
; here with different velocities and different follow-on actions.
;
; The snowboard set is the odd one: its sprite is picked from the terrain by
; call_02_4e0c_Player_UpdateSnowboardSprite rather than played as an animation, so
; those actions write wD80A_Player_SpriteId and raise GFX_XFER_PLAYER_GFX
; themselves.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank02_player_actions.asm
; ------------------------------------------------------------------
; The two files are built the same way - one routine per action, the first-frame
; gate, the animation-ended gate, the tail call into RequestAction - and several
; actions are close to line for line: Spawn, TakeDamage, Death, DeathSetUpWarp,
; Jump, DoubleJump, TailSpin. PLAYER_JUMP_VELOCITY is even the same $2A in both.
; What differs:
;
;   the roster    gex2 has 32 actions and gex3 has 60, twice over. The extra ones
;                 are almost all the two vehicle sets plus the swimming and climbing
;                 sub-states; the on-foot set is very close, minus gex2's run, skid,
;                 teeter and push actions, which gex3 simply does not have
;   speed         gex2 has separate walk and run actions and picks between them when
;                 landing. gex3 has one PLAYERACTION_WALK and a speed ramp, so a
;                 landing only has to choose between idle and walk
;   jumping       same two-action structure and the same button-block trick, but the
;                 airborne gate is different. A gex3 jump action ignores B until
;                 wDC8E_InitialYVelocity says Gex has landed, so B is read on the
;                 landing frame - and the double jump re-enters itself there rather
;                 than requesting an action, so the launch can chain
;   climbing      gex2's climb is one routine. gex3's is two behind one action id,
;                 dispatched through data_02_4adb_ClimbSubStateTable, because Gex can
;                 tail spin while hanging on
;   swimming      gex3 only. The direction index from
;                 call_02_4ee7_Player_GetDPadDirectionIndex picks a base sprite and a
;                 facing out of two parallel tables, which is the same two-table
;                 pattern the climb uses
;   springs       gex2's jump velocity is chosen by the tile underfoot - the spring
;                 and powered-spring types, and an entity override for the geyser.
;                 gex3 has no equivalent: its launches are the fixed constants above
;                 and the updraft tiles handled in bank02_update_player.asm
;   absent here   gex2's IntroWarp, ExitTV, EnterDoor, LeaveDoor, GoldRemoteWarp and
;                 RidingRocket have no gex3 counterpart in this file
; ==================================================================

call_02_47b4_PlayerAction_Spawn:
; First frame only: clear the snowboard animation counters, stop Gex, seed the
; snowboard sprite, and play SFX_GEX_SPAWN. Shared by all three characters - the
; snowboard and kangaroo spawn ids point at this same routine, which is why it
; clears the snowboard state even on foot
    ld   HL, wD805_Player_ActionState                 ;; 02:47b4 $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:47b7 $cb $66
    ret  Z                                            ;; 02:47b9 $c8
    xor  A, A                                         ;; 02:47ba $af
    ld   [wDCA2_Player_SnowboardingRelated], A        ;; 02:47bb $ea $a2 $dc
    ld   [wDCA3_Player_SnowboardingRelated2], A       ;; 02:47be $ea $a3 $dc
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:47c1 $ea $87 $dc
    ld   A, PLAYER_SNOWBOARD_SPRITE_BASE              ;; 02:47c4 $3e $05
    ld   [wDCA4_Player_SnowboardingRelated3], A       ;; 02:47c6 $ea $a4 $dc
    ld   A, SFX_GEX_SPAWN                             ;; 02:47c9 $3e $0e
    jp   call_00_0ff5_QueueSFX                        ;; 02:47cb $c3 $f5 $0f

call_02_47ce_PlayerAction_Idle:
; Standing still. First frame blocks B until release, zeroes both velocities and the
; target speed, and starts wDC83_PlayerIdleTimer at TIMER_AMOUNT_240_FRAMES.
;
; Every frame: UP alone (and nothing else - the compare is against the whole input
; byte) tries the door under him, and call_02_4f11_Player_RequestFallAction checks
; whether the ground has gone. Then the idle timer counts down and the idle
; animation starts when it reaches zero.
;
; Note the timer is decremented unconditionally rather than clamped, so it wraps and
; the animation restarts every 256 frames after the first
    ld   HL, wD805_Player_ActionState                 ;; 02:47ce $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:47d1 $cb $66
    jr   Z, .jr_02_47e9                               ;; 02:47d3 $28 $14
    ld   HL, wDC80_ButtonBlockingFlags                ;; 02:47d5 $21 $80 $dc
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT, [HL]          ;; 02:47d8 $cb $f6
    xor  A, A                                         ;; 02:47da $af
    ld   [wDC86_PlayerXVelocity], A                   ;; 02:47db $ea $86 $dc
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:47de $ea $8c $dc
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:47e1 $ea $87 $dc
    ld   A, TIMER_AMOUNT_240_FRAMES                   ;; 02:47e4 $3e $f0
    ld   [wDC83_PlayerIdleTimer], A                   ;; 02:47e6 $ea $83 $dc
.jr_02_47e9:
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:47e9 $fa $81 $dc
    cp   A, PADF_UP                                   ;; 02:47ec $fe $40
    call Z, call_00_1bbc_CheckForDoorAndEnter         ;; 02:47ee $cc $bc $1b
    call call_02_4f11_Player_RequestFallAction        ;; 02:47f1 $cd $11 $4f
    ld   HL, wDC83_PlayerIdleTimer                    ;; 02:47f4 $21 $83 $dc
    dec  [HL]                                         ;; 02:47f7 $35
    ld   A, PLAYERACTION_IDLE_ANIMATION               ;; 02:47f8 $3e $02
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:47fa $ca $f9 $54
    ret                                               ;; 02:47fd $c9

call_02_47fe_PlayerAction_IdleAnimation:
; The idle animation is just idle without the timer or the velocity reset - the door
; check and the fall check, and nothing else. It ends by its animation running out,
; through the input table rather than from here
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:47fe $fa $81 $dc
    cp   A, PADF_UP                                   ;; 02:4801 $fe $40
    call Z, call_00_1bbc_CheckForDoorAndEnter         ;; 02:4803 $cc $bc $1b
    call call_02_4f11_Player_RequestFallAction        ;; 02:4806 $cd $11 $4f
    ret                                               ;; 02:4809 $c9

call_02_480a_PlayerAction_Walk:
; First frame sets the target speed to PLAYER_SPEED_WALK; after that the only thing
; walking does is check for the ground disappearing. The actual movement is
; call_02_5100_Player_ApplyXMovement's job, later in the same frame
    ld   HL, wD805_Player_ActionState                 ;; 02:480a $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:480d $cb $66
    jr   Z, .jr_02_4816                               ;; 02:480f $28 $05
    ld   A, PLAYER_SPEED_WALK                         ;; 02:4811 $3e $02
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:4813 $ea $87 $dc
.jr_02_4816:
    call call_02_4f11_Player_RequestFallAction        ;; 02:4816 $cd $11 $4f
    ret                                               ;; 02:4819 $c9

call_02_481a_PlayerAction_StartCrouch:
; Stops Gex. The crouch itself is animation, and the input table decides what
; happens next
    xor  A, A                                         ;; 02:481a $af
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:481b $ea $87 $dc
    ret                                               ;; 02:481e $c9

call_02_481f_PlayerAction_CrouchLookDown:
; Pans the camera down while Gex holds the crouch, PLAYER_CROUCH_LOOK_STEP pixels a
; frame into wDCAC_Player_CrouchLookDownRelated and stopping at
; PLAYER_CROUCH_LOOK_MAX. Player_UpdateMain walks the offset back down one pixel a
; frame once the action ends.
;
; This is the one routine the top-down half of the action table replaces with
; call_02_582e_EntityAction_None - looking down means nothing on a top-down map
    ld   A, [wDCAC_Player_CrouchLookDownRelated]      ;; 02:481f $fa $ac $dc
    add  A, PLAYER_CROUCH_LOOK_STEP                   ;; 02:4822 $c6 $02
    cp   A, PLAYER_CROUCH_LOOK_MAX                    ;; 02:4824 $fe $41
    jr   C, .jr_02_482a                               ;; 02:4826 $38 $02
    ld   A, PLAYER_CROUCH_LOOK_MAX                    ;; 02:4828 $3e $41
.jr_02_482a:
    ld   [wDCAC_Player_CrouchLookDownRelated], A      ;; 02:482a $ea $ac $dc
    ret                                               ;; 02:482d $c9

call_02_482e_PlayerAction_Unk7:
; Ramps the target speed DOWN as the animation plays: 2 minus half the frame index,
; floored at zero. So whatever this action is, Gex enters it moving and coasts to a
; stop over the first four frames.
;
; The other half of it is in call_02_4f32_Player_UpdateMain, which forces left or
; right into the input to match his facing while this action runs - so he keeps
; moving forward no matter what the player does
    ld   A, [wD809_Player_SpriteCounter]              ;; 02:482e $fa $09 $d8
    srl  A                                            ;; 02:4831 $cb $3f
    ld   C, A                                         ;; 02:4833 $4f
    ld   A, $02                                       ;; 02:4834 $3e $02
    sub  A, C                                         ;; 02:4836 $91
    jr   NC, .jr_02_483a                              ;; 02:4837 $30 $01
    xor  A, A                                         ;; 02:4839 $af
.jr_02_483a:
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:483a $ea $87 $dc
    ret                                               ;; 02:483d $c9

call_02_483e_PlayerAction_EatFly:
; First frame only: play the sound and hand a fly of $00 to
; call_00_0624_Player_SwapFlyPowerup, which swaps out whatever he was carrying -
; swapping the old one out is what makes the new one take effect
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    ret  z
    ld   a,SFX_UNK05
    call call_00_0ff5_QueueSFX
    xor  a
    jp   call_00_0624_Player_SwapFlyPowerup

call_02_484d_PlayerAction_TakeDamage:
; First frame: bounce him with PLAYER_HIT_BOUNCE_VELOCITY, make sure he keeps some
; air control, and play SFX_PLAYER_DAMAGED. Every frame it re-arms the invincibility
; window, so the window is measured from the END of the recoil rather than from the
; hit.
;
; Then the standard airborne idiom - back to idle once
; wDC8E_InitialYVelocity says he has landed
    ld   HL, wD805_Player_ActionState                 ;; 02:484d $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:4850 $cb $66
    jr   Z, .jr_02_4864                               ;; 02:4852 $28 $10
    ld   A, PLAYER_HIT_BOUNCE_VELOCITY                ;; 02:4854 $3e $1c
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:4856 $ea $8c $dc
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:4859 $ea $8e $dc
    call call_02_4e01_Player_EnsureMinXSpeed          ;; 02:485c $cd $01 $4e
    ld   A, SFX_PLAYER_DAMAGED                        ;; 02:485f $3e $0a
    call call_00_0ff5_QueueSFX                        ;; 02:4861 $cd $f5 $0f
.jr_02_4864:
    ld   A, TIMER_AMOUNT_60_FRAMES                    ;; 02:4864 $3e $3c
    ld   [wDC7E_Player_DamageCooldownTimer], A        ;; 02:4866 $ea $7e $dc
    ld   A, [wDC8E_InitialYVelocity]                  ;; 02:4869 $fa $8e $dc
    and  A, A                                         ;; 02:486c $a7
    ld   A, PLAYERACTION_IDLE                         ;; 02:486d $3e $01
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:486f $ca $f9 $54
    ret                                               ;; 02:4872 $c9

call_02_4873_PlayerAction_Death:
; First frame stops him and plays the death sound; every frame re-arms the damage
; cooldown so nothing can hit him again on the way down. Shared by all three
; characters. It does not decide anything - the animation running out moves him on
; to DeathSetUpWarp through the action data
    ld   HL, wD805_Player_ActionState                 ;; 02:4873 $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:4876 $cb $66
    jr   Z, .jr_02_4883                               ;; 02:4878 $28 $09
    xor  A, A                                         ;; 02:487a $af
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:487b $ea $87 $dc
    ld   A, SFX_UNK0D                                 ;; 02:487e $3e $0d
    call call_00_0ff5_QueueSFX                        ;; 02:4880 $cd $f5 $0f
.jr_02_4883:
    ld   A, TIMER_AMOUNT_60_FRAMES                    ;; 02:4883 $3e $3c
    ld   [wDC7E_Player_DamageCooldownTimer], A        ;; 02:4885 $ea $7e $dc
    ret                                               ;; 02:4888 $c9

call_02_4889_PlayerAction_DeathSetUpWarp:
; Holds Gex still until the death animation wraps, then raises WARP_DIED in
; wDB6A_WarpFlags - which is what the outer loop in bank 0 is watching for to spend
; a life and respawn him. Shared by all three characters
    xor  A, A                                         ;; 02:4889 $af
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:488a $ea $87 $dc
    ld   A, TIMER_AMOUNT_60_FRAMES                    ;; 02:488d $3e $3c
    ld   [wDC7E_Player_DamageCooldownTimer], A        ;; 02:488f $ea $7e $dc
    ld   A, [wD805_Player_ActionState]                ;; 02:4892 $fa $05 $d8
    and  A, ACTION_STATE_ANIM_ENDED                   ;; 02:4895 $e6 $04
    ret  Z                                            ;; 02:4897 $c8
    ld   A, [wDB6A_WarpFlags]                         ;; 02:4898 $fa $6a $db
    or   A, WARP_DIED                                 ;; 02:489b $f6 $02
    ld   [wDB6A_WarpFlags], A                         ;; 02:489d $ea $6a $db
    ret                                               ;; 02:48a0 $c9

call_02_48a1_PlayerAction_StandOnTVButton:
; Plays the button sound on the first frame and then keeps Gex from standing inside
; the button entity, one pixel a frame, through
; call_02_4db1_Player_PushOutOfEntity
    ld   HL, wD805_Player_ActionState                 ;; 02:48a1 $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:48a4 $cb $66
    ld   A, SFX_UNK1D                                 ;; 02:48a6 $3e $1d
    call NZ, call_00_0ff5_QueueSFX                    ;; 02:48a8 $c4 $f5 $0f
    ld   C, ENTITY_TV_BUTTON                          ;; 02:48ab $0e $11
    jp   call_02_4db1_Player_PushOutOfEntity          ;; 02:48ad $c3 $b1 $4d

call_02_48b0_PlayerAction_EnterTV:
; Waits for the animation to finish and then raises WARP_NEW_LEVEL, which takes Gex
; out of the level entirely. Shared by all three characters
    ld   A, [wD805_Player_ActionState]                ;; 02:48b0 $fa $05 $d8
    and  A, ACTION_STATE_ANIM_ENDED                   ;; 02:48b3 $e6 $04
    ret  Z                                            ;; 02:48b5 $c8
    ld   HL, wDB6A_WarpFlags                          ;; 02:48b6 $21 $6a $db
    set  WARP_NEW_LEVEL_BIT, [HL]                     ;; 02:48b9 $cb $e6
    ret                                               ;; 02:48bb $c9

call_02_48bc_PlayerAction_Jump:
; First frame: SFX_GEX_JUMP, PLAYER_JUMP_VELOCITY into both the live velocity and
; wDC8E_InitialYVelocity, block B for the rise, and make sure there is some air
; speed to ramp toward.
;
; Then the airborne idiom - return while wDC8E_InitialYVelocity is nonzero. On the
; frame it lands, B still held means PLAYERACTION_DOUBLE_JUMP and otherwise
; call_02_4dce_Player_SetLandingAction picks idle or walk.
;
;
; Worth reading carefully: the `ret NZ` means this action ignores B for the whole
; time Gex is off the ground, so the double jump is requested on the frame he lands
; and not before. Mid-air input goes through the transition table instead, and the
; jump's list only names A - which gives the tail spin. B in the air does nothing
; until the landing
    ld   HL, wD805_Player_ActionState                 ;; 02:48bc $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:48bf $cb $66
    jr   Z, .jr_02_48d6                               ;; 02:48c1 $28 $13
    ld   A, SFX_GEX_JUMP                              ;; 02:48c3 $3e $06
    call call_00_0ff5_QueueSFX                        ;; 02:48c5 $cd $f5 $0f
    ld   A, PLAYER_JUMP_VELOCITY                      ;; 02:48c8 $3e $2a
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:48ca $ea $8c $dc
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:48cd $ea $8e $dc
    call call_02_4df6_Player_LockBPress               ;; 02:48d0 $cd $f6 $4d
    call call_02_4e01_Player_EnsureMinXSpeed          ;; 02:48d3 $cd $01 $4e
.jr_02_48d6:
    ld   A, [wDC8E_InitialYVelocity]                  ;; 02:48d6 $fa $8e $dc
    and  A, A                                         ;; 02:48d9 $a7
    ret  NZ                                           ;; 02:48da $c0
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:48db $fa $81 $dc
    and  A, PADF_B                                    ;; 02:48de $e6 $02
    ld   A, PLAYERACTION_DOUBLE_JUMP                  ;; 02:48e0 $3e $0f
    jp   NZ, call_02_54f9_Player_RequestAction        ;; 02:48e2 $c2 $f9 $54
    jp   call_02_4dce_Player_SetLandingAction         ;; 02:48e5 $c3 $ce $4d

call_02_48e8_PlayerAction_DoubleJump:
; The same shape with PLAYER_DOUBLE_JUMP_VELOCITY and SFX_GEX_DOUBLE_JUMP, with one
; difference that matters: its B check `jr`s back to its OWN first-frame body rather
; than requesting an action. So landing with B still held re-launches Gex without
; ever leaving this action, and the chain can repeat - the jump above can only reach
; the double jump once
    ld   HL, wD805_Player_ActionState                 ;; 02:48e8 $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:48eb $cb $66
    jr   Z, .jr_02_4902                               ;; 02:48ed $28 $13
.jr_02_48ef:
    ld   A, SFX_GEX_DOUBLE_JUMP                       ;; 02:48ef $3e $07
    call call_00_0ff5_QueueSFX                        ;; 02:48f1 $cd $f5 $0f
    ld   A, PLAYER_DOUBLE_JUMP_VELOCITY               ;; 02:48f4 $3e $3e
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:48f6 $ea $8c $dc
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:48f9 $ea $8e $dc
    call call_02_4df6_Player_LockBPress               ;; 02:48fc $cd $f6 $4d
    call call_02_4e01_Player_EnsureMinXSpeed          ;; 02:48ff $cd $01 $4e
.jr_02_4902:
    ld   A, [wDC8E_InitialYVelocity]                  ;; 02:4902 $fa $8e $dc
    and  A, A                                         ;; 02:4905 $a7
    ret  NZ                                           ;; 02:4906 $c0
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:4907 $fa $81 $dc
    and  A, PADF_B                                    ;; 02:490a $e6 $02
    jr   NZ, .jr_02_48ef                              ;; 02:490c $20 $e1
    jp   call_02_4dce_Player_SetLandingAction         ;; 02:490e $c3 $ce $4d

call_02_4911_PlayerAction_TailSpin:
; The attack. First frame plays the sound, blocks A until release, sets
; wDC7F_Player_IsAttacking - which is what makes contact with an entity a hit rather
; than damage - and ensures some air speed.
;
; The rest runs only on the frame the animation wraps: clear the attacking flag, and
; then return unless there is ground under him, so a spin that ends in mid-air
; simply ends and leaves him falling. On the ground it blocks B and picks walk or
; idle from the d-pad.
;
; The second `bit 7, [HL]` on wDABE_CollisionFlags is a re-test of the one three
; instructions above it and can only ever take the same branch
    ld   HL, wD805_Player_ActionState                 ;; 02:4911 $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:4914 $cb $66
    jr   Z, .jr_02_492a                               ;; 02:4916 $28 $12
    ld   A, SFX_GEX_TAIL_SPIN                         ;; 02:4918 $3e $04
    call call_00_0ff5_QueueSFX                        ;; 02:491a $cd $f5 $0f
    ld   HL, wDC80_ButtonBlockingFlags                ;; 02:491d $21 $80 $dc
    set  BTN_BLOCK_A_BIT, [HL]                        ;; 02:4920 $cb $c6
    ld   A, $01                                       ;; 02:4922 $3e $01
    ld   [wDC7F_Player_IsAttacking], A                ;; 02:4924 $ea $7f $dc
    call call_02_4e01_Player_EnsureMinXSpeed          ;; 02:4927 $cd $01 $4e
.jr_02_492a:
    ld   A, [wD805_Player_ActionState]                ;; 02:492a $fa $05 $d8
    and  A, ACTION_STATE_ANIM_ENDED                   ;; 02:492d $e6 $04
    ret  Z                                            ;; 02:492f $c8
    xor  A, A                                         ;; 02:4930 $af
    ld   [wDC7F_Player_IsAttacking], A                ;; 02:4931 $ea $7f $dc
    ld   HL, wDABE_CollisionFlags                     ;; 02:4934 $21 $be $da
    bit  7, [HL]                                      ;; 02:4937 $cb $7e
    ret  Z                                            ;; 02:4939 $c8
    ld   HL, wDC80_ButtonBlockingFlags                ;; 02:493a $21 $80 $dc
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT, [HL]          ;; 02:493d $cb $f6
    ld   C, PLAYERACTION_FALL                         ;; 02:493f $0e $11
    ld   HL, wDABE_CollisionFlags                     ;; 02:4941 $21 $be $da
    bit  7, [HL]                                      ;; 02:4944 $cb $7e
    jr   Z, .jr_02_4953                               ;; 02:4946 $28 $0b
    ld   C, PLAYERACTION_IDLE                         ;; 02:4948 $0e $01
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:494a $fa $81 $dc
    and  A, PADF_RIGHT | PADF_LEFT                    ;; 02:494d $e6 $30
    jr   Z, .jr_02_4953                               ;; 02:494f $28 $02
    ld   C, PLAYERACTION_WALK                         ;; 02:4951 $0e $03
.jr_02_4953:
    ld   A, C                                         ;; 02:4953 $79
    jp   call_02_54f9_Player_RequestAction            ;; 02:4954 $c3 $f9 $54

call_02_4957_PlayerAction_Fall:
; Falling. The first frame only marks him airborne and gives him air control - the
; gravity itself is call_02_5267_Player_ApplyYVelocity's job. On landing, walk if a
; direction is held and idle if not
    ld   HL, wD805_Player_ActionState                 ;; 02:4957 $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:495a $cb $66
    jr   Z, .jr_02_4966                               ;; 02:495c $28 $08
    ld   A, $01                                       ;; 02:495e $3e $01
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:4960 $ea $8e $dc
    call call_02_4e01_Player_EnsureMinXSpeed          ;; 02:4963 $cd $01 $4e
.jr_02_4966:
    ld   A, [wDC8E_InitialYVelocity]                  ;; 02:4966 $fa $8e $dc
    and  A, A                                         ;; 02:4969 $a7
    ret  NZ                                           ;; 02:496a $c0
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:496b $fa $81 $dc
    and  A, PADF_RIGHT | PADF_LEFT                    ;; 02:496e $e6 $30
    ld   A, PLAYERACTION_WALK                         ;; 02:4970 $3e $03
    jp   NZ, call_02_54f9_Player_RequestAction        ;; 02:4972 $c2 $f9 $54
    ld   A, PLAYERACTION_IDLE                         ;; 02:4975 $3e $01
    jp   call_02_54f9_Player_RequestAction            ;; 02:4977 $c3 $f9 $54

call_02_497a_PlayerAction_LandFromFall:
; The heavy landing, entered when the fall counter passed PLAYER_FALL_LONG. Plays a
; thud and zeroes the target speed, so a long fall costs Gex his momentum; the
; animation running out returns him to idle through the action data
    ld   HL, wD805_Player_ActionState                 ;; 02:497a $21 $05 $d8
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:497d $cb $66
    ld   A, SFX_UNK08                                 ;; 02:497f $3e $08
    call NZ, call_00_0ff5_QueueSFX                    ;; 02:4981 $c4 $f5 $0f
    xor  A, A                                         ;; 02:4984 $af
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:4985 $ea $87 $dc
    ret                                               ;; 02:4988 $c9

call_02_4989_PlayerAction_Unk19:
; A knock-up that costs a hit: PLAYER_UNK19_BOUNCE_VELOCITY, a call into
; call_00_06f6_Player_TakeDamage, a sound, and then an immediate
; call_02_72ac_Entity_SetAction to action $14 - note SetAction, not RequestAction,
; so this one bypasses the queue and the permission table entirely and changes the
; action mid-frame.
;
; Falls through into call_02_49a8_PlayerAction_EnterIdle
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,call_02_49a8_PlayerAction_EnterIdle
    ld   a,PLAYER_UNK19_BOUNCE_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4e01_Player_EnsureMinXSpeed
    call call_00_06f6_Player_TakeDamage
    ld   a,SFX_UNK0B
    call call_00_0ff5_QueueSFX
    ld   a,$14
    call call_02_72ac_Entity_SetAction

call_02_49a8_PlayerAction_EnterIdle:
; Back to idle once wDC8E_InitialYVelocity says he has landed
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ld   a,PLAYERACTION_IDLE
    jp   z,call_02_54f9_Player_RequestAction
    ret  
    
call_02_49b2_PlayerAction_None:  
; Does nothing. Four of the unused action slots point here
    ret  

call_02_49b3_PlayerAction_Water_Swimming:
; Swimming, and the template the climb below copies.
;
; First frame blocks B, clears the vertical velocities and gives him
; PLAYER_SPEED_MINIMUM. Every frame the d-pad becomes a direction index through
; call_02_4ee7_Player_GetDPadDirectionIndex - kept from last frame when nothing is
; held - and that index reads two parallel tables:
; .data_02_4a1d_SwimFacingByDirection gives the facing and the
; up/down flag, .data_02_4a15_SwimSpriteBase gives the base sprite id.
;
; On top of the base, a frame counter cycles PLAYER_SWIM_FRAME_COUNT poses every
; PLAYER_SWIM_FRAME_DELAY frames. The result is written straight to
; wD80A_Player_SpriteId with GFX_XFER_PLAYER_GFX raised - so like the snowboard,
; swimming draws itself rather than being animated by the action data
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_49ce
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
    xor  a
    ld   [wDC9B_Player_SwimmingRelated3],a
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8D_Player_FloorSnapVelocity],a
    ld   a,PLAYER_SPEED_MINIMUM
    ld   [wDC87_PlayerXMaxVelocity],a
.jr_02_49ce:
    call call_02_4ee7_Player_GetDPadDirectionIndex
    ld   hl,wDC9D_Player_SwimmingRelated
    cp   a,DPAD_DIRECTION_NONE
    jr   z,.jr_02_49d9
    ld   [hl],a
.jr_02_49d9:
    ld   e,[hl]
    ld   d,$00
    ld   hl,.data_02_4a1d_SwimFacingByDirection
    add  hl,de
    ld   a,[hl]
    and  a,PLAYER_DIR_FACING_MASK
    ld   [wD80D_PlayerFacingDirection],a
    ld   a,[hl]
    and  a,PLAYER_DIR_VERTICAL_MASK
    ld   [wDC7A_PlayerClimbingOrSwimmingRelated],a
    ld   hl,.data_02_4a15_SwimSpriteBase
    add  hl,de
    ld   c,[hl]
    ld   hl,wDC9C_Player_SwimmingRelated2
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_02_4a05
    ld   [hl],PLAYER_SWIM_FRAME_DELAY
    ld   hl,wDC9B_Player_SwimmingRelated3
    inc  [hl]
    ld   a,[hl]
    sub  a,PLAYER_SWIM_FRAME_COUNT
    jr   nz,.jr_02_4a05
    ld   [hl],a
.jr_02_4a05:
    ld   a,[wDC9B_Player_SwimmingRelated3]
    add  c
    ld   hl,wD80A_Player_SpriteId
    cp   [hl]
    ret  z
    ld   [hl],a
    ld   hl,wDB66_GfxTransferFlags
    set  GFX_XFER_PLAYER_GFX,[hl]
    ret  
.data_02_4a15_SwimSpriteBase:
    db   $7d, $4f, $48, $56, $7d, $56, $48, $4f       ;; 02:4a11 ????????
.data_02_4a1d_SwimFacingByDirection:
    db   $00, $00, $00, $00, $60, $20, $20, $20       ;; 02:4a19 ????????

call_02_4a25_PlayerAction_DeathInPitAlt:
; Stops Gex and holds the damage cooldown, and drops into the real pit death only
; once the tile under him actually is TILE_TYPE_INSTANT_KILL. The "Alt" of the pair
; is the approach; the one below is the fall
    xor  a
    ld   [wDC87_PlayerXMaxVelocity],a
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDC7E_Player_DamageCooldownTimer],a
    ld   a,[wDC93_TileTypeBehindGexsLowerBody]
    cp   a,TILE_TYPE_INSTANT_KILL
    jp   z,jp_00_06da_Player_DieInPit
    ret  

call_02_4a37_PlayerAction_DeathInPit:
; The fall down a pit. Stops him, holds the cooldown, and sets
; wDC29_SkipMapWindowUpdateFlag so the camera stays put while he drops out of frame.
;
; The respawn is not asked for until wDC91_Player_ScreenY passes
; PLAYER_OFFSCREEN_BOTTOM_Y - so the game waits for him to be visibly gone before
; raising WARP_DIED, rather than cutting away the moment he starts falling
    xor  A, A                                         ;; 02:4a37 $af
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:4a38 $ea $87 $dc
    ld   A, TIMER_AMOUNT_60_FRAMES                    ;; 02:4a3b $3e $3c
    ld   [wDC7E_Player_DamageCooldownTimer], A        ;; 02:4a3d $ea $7e $dc
    ld   A, $01                                       ;; 02:4a40 $3e $01
    ld   [wDC29_SkipMapWindowUpdateFlag], A           ;; 02:4a42 $ea $29 $dc
    ld   A, [wDC91_Player_ScreenY]                    ;; 02:4a45 $fa $91 $dc
    cp   A, PLAYER_OFFSCREEN_BOTTOM_Y                 ;; 02:4a48 $fe $b0
    ret  C                                            ;; 02:4a4a $d8
    ld   HL, wDB6A_WarpFlags                          ;; 02:4a4b $21 $6a $db
    set  WARP_DIED_BIT, [HL]                          ;; 02:4a4e $cb $ce
    ret                                               ;; 02:4a50 $c9

call_02_4a51_PlayerAction_None2:
; A second do-nothing, for the one remaining unused slot
    ret  

call_02_4a52_PlayerAction_BlownUpwards:
; What an updraft tile puts Gex in - see call_02_5374_Player_CheckUpdraftTiles,
; which keeps topping his velocity up for as long as he is over the vent. This
; action only marks him airborne and waits for the landing
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4a61
    ld   a,$01
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4a61:
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    jp   z,call_02_4dce_Player_SetLandingAction
    ret  

call_02_4a69_PlayerAction_RidingElevator:
; Keeps Gex from sinking into the elevator he is riding, through
; call_02_4db1_Player_PushOutOfEntity. Everything else about the ride is the
; elevator entity's own action
    ld   c,ENTITY_ANIME_CHANNEL_ELEVATOR
    jp   call_02_4db1_Player_PushOutOfEntity

call_02_4a6e_PlayerAction_Water_TailSpin:
; The tail spin, underwater. Same first frame as the dry one - sound, block A, set
; the attacking flag - and the same wrap-frame teardown, except that it always
; returns to PLAYERACTION_WATER_SWIMMING rather than choosing from the d-pad
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4a87
    ld   a,SFX_GEX_TAIL_SPIN
    call call_00_0ff5_QueueSFX
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_A_BIT,[hl]
    ld   a,$01
    ld   [wDC7F_Player_IsAttacking],a
    ld   [wDC87_PlayerXMaxVelocity],a
.jr_02_4a87:
    ld   a,[wD805_Player_ActionState]
    and  a,ACTION_STATE_ANIM_ENDED
    ret  z
    xor  a
    ld   [wDC7F_Player_IsAttacking],a
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
    ld   a,PLAYERACTION_WATER_SWIMMING
    jp   call_02_54f9_Player_RequestAction

call_02_4a9b_PlayerAction_Water_Treading:
; Treading water at the surface. One instruction of substance: give him
; PLAYER_SPEED_MINIMUM. The surface break that gets him here is in
; call_02_5431_Player_CheckTileInteractions
    ld   a,PLAYER_SPEED_MINIMUM
    ld   [wDC87_PlayerXMaxVelocity],a
    ret  

call_02_4aa1_PlayerAction_Water_Diving:
; Diving. Sets the minimum speed and forces the direction index to 4 - straight
; down - so the swim tables draw him head-first regardless of the d-pad
    ld   a,$01
    ld   [wDC87_PlayerXMaxVelocity],a
    ld   a,PLAYER_SWIM_DIRECTION_DOWN
    ld   [wDC9D_Player_SwimmingRelated],a
    ret  

call_02_4aac_PlayerAction_Climbing:
; Climbing, which is really two actions behind one id.
;
; The first frame blocks B, clears the vertical velocities, gives him
; PLAYER_SPEED_MINIMUM and resets wDC9E_Player_ClimbSubState to
; CLIMB_SUBSTATE_NORMAL. Every frame after that it just dispatches on that sub-state
; through data_02_4adb_ClimbSubStateTable, so the body of the climb is in one of the
; two routines below
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4acc
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
    xor  a
    ld   [wDC9F_Player_ClimbingRelated],a
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8D_Player_FloorSnapVelocity],a
    ld   a,PLAYER_SPEED_MINIMUM
    ld   [wDC87_PlayerXMaxVelocity],a
    ld   a,CLIMB_SUBSTATE_NORMAL
    ld   [wDC9E_Player_ClimbSubState],a
.jr_02_4acc:
    ld   hl,wDC9E_Player_ClimbSubState
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   de,data_02_4adb_ClimbSubStateTable
    add  hl,de
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    jp   hl

data_02_4adb_ClimbSubStateTable:
; Two handlers, indexed by wDC9E_Player_ClimbSubState. Disassembled as instructions
; for a long time - the four bytes $DF $4A $66 $4B are these two addresses
    dw   call_02_4adf_PlayerAction_Climbing_Normal
    dw   call_02_4b66_PlayerAction_Climbing_TailSpin

call_02_4adf_PlayerAction_Climbing_Normal:
; The ordinary climb, built exactly like the swim above: the d-pad becomes a
; direction index, .data_02_4b5e_ClimbFacingByDirection gives the facing and the
; vertical flag, .data_02_4b56_ClimbSpriteBase gives the base sprite, and a counter
; cycles PLAYER_CLIMB_FRAME_COUNT poses every PLAYER_CLIMB_FRAME_DELAY frames.
;
; Two inputs are handled on top of that: B requests PLAYERACTION_JUMP and leaves the
; wall, and A starts the climbing tail spin - which is not an action change but a
; switch of wDC9E_Player_ClimbSubState to CLIMB_SUBSTATE_TAIL_SPIN
    call call_02_4ee7_Player_GetDPadDirectionIndex
    ld   hl,wDCA1_Player_ClimbingRelated4
    cp   a,DPAD_DIRECTION_NONE
    jr   z,.jr_02_4aea
    ld   [hl],a
.jr_02_4aea:
    ld   e,[hl]
    ld   d,00
    ld   hl,.data_02_4b5e_ClimbFacingByDirection
    add  hl,de
    ld   a,[hl]
    and  a,PLAYER_DIR_FACING_MASK
    ld   [wD80D_PlayerFacingDirection],a
    ld   a,[hl]
    and  a,PLAYER_DIR_VERTICAL_MASK
    ld   [wDC7A_PlayerClimbingOrSwimmingRelated],a
    ld   hl,.data_02_4b56_ClimbSpriteBase
    add  hl,de
    ld   c,[hl]
    ld   hl,wDCA0_Player_ClimbingRelated3
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_02_4b16
    ld   [hl],PLAYER_CLIMB_FRAME_DELAY
    ld   hl,wDC9F_Player_ClimbingRelated
    inc  [hl]
    ld   a,[hl]
    sub  a,PLAYER_CLIMB_FRAME_COUNT
    jr   nz,.jr_02_4b16
    ld   [hl],a
.jr_02_4b16:
    ld   a,[wDC9F_Player_ClimbingRelated]
    add  c
    ld   hl,wD80A_Player_SpriteId
    cp   [hl]
    jr   z,.jr_02_4b26
    ld   [hl],a
    ld   hl,wDB66_GfxTransferFlags
    set  GFX_XFER_PLAYER_GFX,[hl]
.jr_02_4b26:
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_B
    jr   z,.jr_02_4b32
    ld   a,PLAYERACTION_JUMP
    call call_02_54f9_Player_RequestAction
.jr_02_4b32:
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A
    jr   z,.jr_02_4b55
    ld   a,SFX_GEX_TAIL_SPIN
    call call_00_0ff5_QueueSFX
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_A_BIT,[hl]
    call call_02_4e01_Player_EnsureMinXSpeed
    ld   a,CLIMB_SUBSTATE_TAIL_SPIN
    ld   [wDC9E_Player_ClimbSubState],a
    xor  a
    ld   [wDC9F_Player_ClimbingRelated],a
    ld   a,$01
    ld   [wDC7F_Player_IsAttacking],a
    ret  
.jr_02_4b55:
    ret  
.data_02_4b56_ClimbSpriteBase:
    db   $73, $d1, $c7, $db, $73, $db, $c7, $d1
.data_02_4b5e_ClimbFacingByDirection:
    db   $00, $00, $00, $00, $60, $20, $20, $20

call_02_4b66_PlayerAction_Climbing_TailSpin: ; unreferenced function?
; The tail spin performed while hanging on a wall. Long labelled unreferenced,
; because the only thing that reaches it is the table above.
;
; Runs a fixed PLAYER_CLIMB_SPIN_FRAME_COUNT-frame cycle from
; PLAYER_CLIMB_SPIN_SPRITE_BASE, holding the facing straight ahead, and when the
; count is used up it puts wDC9E_Player_ClimbSubState back to
; CLIMB_SUBSTATE_NORMAL, clears the attacking flag and blocks B - so the climb
; resumes without ever having left PLAYERACTION_CLIMBING
    call call_02_4ee7_Player_GetDPadDirectionIndex
    ld   hl,wDCA1_Player_ClimbingRelated4
    cp   a,DPAD_DIRECTION_NONE
    jr   z,.jr_02_4b71
    ld   [hl],a
.jr_02_4b71:
    ld   hl,wDCA0_Player_ClimbingRelated3
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_02_4b7f
    ld   [hl],PLAYER_CLIMB_SPIN_FRAME_DELAY
    ld   hl,wDC9F_Player_ClimbingRelated
    inc  [hl]
.jr_02_4b7f:
    ld   a,[wDC9F_Player_ClimbingRelated]
    ld   hl,wDCA1_Player_ClimbingRelated4
    add  [hl]
    and  a,PLAYER_CLIMB_SPIN_SPRITE_MASK
    add  a,PLAYER_CLIMB_SPIN_SPRITE_BASE
    ld   hl,wD80A_Player_SpriteId
    cp   [hl]
    ret  z
    ld   [hl],a
    ld   a,$00
    ld   [wD80D_PlayerFacingDirection],a
    ld   a,$00
    ld   [wDC7A_PlayerClimbingOrSwimmingRelated],a
    ld   hl,wDB66_GfxTransferFlags
    set  GFX_XFER_PLAYER_GFX,[hl]
    ld   a,[wDC9F_Player_ClimbingRelated]
    cp   a,PLAYER_CLIMB_SPIN_FRAME_COUNT
    ret  c
    ld   a,CLIMB_SUBSTATE_NORMAL
    ld   [wDC9E_Player_ClimbSubState],a
    xor  a
    ld   [wDC9F_Player_ClimbingRelated],a
    ld   [wDC7F_Player_IsAttacking],a
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
    ret  

call_02_4bb7_PlayerAction_Snowboarding_StandOrWalk:
; Riding the snowboard - there is no separate stand and walk, because the board is
; always moving.
;
; First frame sets PLAYER_SPEED_SNOWBOARD, resets the sprite counters and blocks B.
; Every frame: UP tries a door, then
; call_02_4e0c_Player_UpdateSnowboardSprite picks the pose from the terrain.
;
; The rest is the launch check. If the terrain sprite the picker chose appears in
; .data_02_4c17_SnowboardLaunchSprites with a matching facing, Gex is thrown upward
; at PLAYER_SNOWBOARD_LAUNCH_VELOCITY - that is how a ramp works on this map,
; without any jump action being involved
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4bdc
    ld   a,PLAYER_SPEED_SNOWBOARD
    ld   [wDC87_PlayerXMaxVelocity],a
    xor  a
    ld   [wDCA2_Player_SnowboardingRelated],a
    ld   [wDCA3_Player_SnowboardingRelated2],a
    ld   a,PLAYER_SNOWBOARD_SPRITE_BASE
    ld   [wDCA4_Player_SnowboardingRelated3],a
    ld   a,$01
    ld   [wDCA5_Player_SnowboardingRelated4],a
    ld   [wDCA6_Player_SnowboardingRelated5],a
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
.jr_02_4bdc:
    ld   a,[wDC81_Player_EffectiveInputs]
    bit  PADF_UP_BIT,a
    call nz,call_00_1bbc_CheckForDoorAndEnter
    call call_02_4e0c_Player_UpdateSnowboardSprite
    ld   a,[wDCA5_Player_SnowboardingRelated4]
    and  a
    jr   z,.jr_02_4c11
    ld   a,[wDCA6_Player_SnowboardingRelated5]
    and  a
    jr   z,.jr_02_4c10
    ld   c,a
    ld   a,[wDCA5_Player_SnowboardingRelated4]
    cp   a,$01
    ret  nz
    ld   hl,.data_02_4c17_SnowboardLaunchSprites - 1
.jr_02_4bfd:
    inc  hl
    ldi  a,[hl]
    cp   a,ACTION_INPUT_END
    ret  z
    cp   c
    jr   nz,.jr_02_4bfd
    ld   a,[wD80D_PlayerFacingDirection]
    cp   [hl]
    ret  nz
    ld   a,PLAYER_SNOWBOARD_LAUNCH_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ret  
.jr_02_4c10:
    ret  
.jr_02_4c11:
    ld   a,[wDCA6_Player_SnowboardingRelated5]
    and  a
    ret  z
.jr_02_4c16:
    ret  

.data_02_4c17_SnowboardLaunchSprites:
; (sprite id, facing) pairs ending in $FF. The reader above points one byte BEFORE
; this label because its loop starts with an `inc hl`
    db   $06, $00, $0d, $00, $09, $00, $0a            ;; 02:4c17 ????????
    db   $00, $05, $20, $0b, $20, $0c, $20, $0e       ;; 02:4c1e ????????
    db   $20, $0f, $20, $10, $20, $ff

call_02_4c2c_PlayerAction_Snowboarding_Jump:
; The on-foot jump with the snowboard's follow-on actions. Same
; PLAYER_JUMP_VELOCITY, same button block, same airborne idiom
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4c46
    ld   a,SFX_GEX_JUMP
    call call_00_0ff5_QueueSFX
    ld   a,PLAYER_JUMP_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4df6_Player_LockBPress
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4c46:
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ret  nz
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_B
    ld   a,PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    jp   nz,call_02_54f9_Player_RequestAction
    jp   call_02_4dce_Player_SetLandingAction

call_02_4c58_PlayerAction_Snowboarding_DoubleJump:
; The snowboard double jump. Unlike the on-foot version this one does NOT re-enter
; itself on a held B - it simply lands - so the board gets two jumps and no more
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4c72
    ld   a,SFX_GEX_DOUBLE_JUMP
    call call_00_0ff5_QueueSFX
    ld   a,PLAYER_DOUBLE_JUMP_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4df6_Player_LockBPress
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4c72:
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    jp   z,call_02_4dce_Player_SetLandingAction
    ret  

call_02_4c7a_PlayerAction_Snowboarding_TailSpin:
; The tail spin on the board. Seeds the spin sprite counters from
; PLAYER_SNOWBOARD_SPIN_SPRITE_BASE and then hands every frame to
; call_02_4e0c_Player_UpdateSnowboardSprite, which counts the eight spin poses and
; returns him to standing when they run out - so unlike every other action here, its
; ending is in the sprite picker rather than in this routine
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4ca1
    xor  a
    ld   [wDCA2_Player_SnowboardingRelated],a
    ld   a,$03
    ld   [wDCA3_Player_SnowboardingRelated2],a
    ld   a,PLAYER_SNOWBOARD_SPIN_SPRITE_BASE
    ld   [wDCA4_Player_SnowboardingRelated3],a
    ld   a,SFX_GEX_TAIL_SPIN
    call call_00_0ff5_QueueSFX
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_A_BIT,[hl]
    ld   a,$01
    ld   [wDC7F_Player_IsAttacking],a
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4ca1:
    jp   call_02_4e0c_Player_UpdateSnowboardSprite

call_02_4ca4_PlayerAction_Snowboarding_Fall:
; Falling on the board, back to riding on landing
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4cb3
    ld   a,$01
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4cb3:
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ld   a,PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    jp   z,call_02_54f9_Player_RequestAction
    ret  

call_02_4cbd_PlayerAction_Snowboarding_TakeDamage:
; Taking a hit on the board: the same PLAYER_HIT_BOUNCE_VELOCITY recoil as on foot,
; back to riding when it ends
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4cd4
    ld   a,PLAYER_HIT_BOUNCE_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4e01_Player_EnsureMinXSpeed
    ld   a,SFX_PLAYER_DAMAGED
    call call_00_0ff5_QueueSFX
.jr_02_4cd4:
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDC7E_Player_DamageCooldownTimer],a
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ld   a,PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    jp   z,call_02_54f9_Player_RequestAction
    ret  

call_02_4ce3_PlayerAction_Kangaroo_Idle:
; The kangaroo never stands still - "idle" is one hop.
;
; There is no first-frame gate here: every frame plays the jump sound, requests
; PLAYERACTION_KANGAROO_HOPPING and blocks B, and then launches at
; PLAYER_KANGAROO_HOP_VELOCITY only if there is ground under him. The request is a
; no-op once it has been granted, so in practice this runs once and the hop action
; takes over.
;
; Falls through into the hop below
    ld   a,SFX_GEX_JUMP
    call call_00_0ff5_QueueSFX
    call call_02_4e01_Player_EnsureMinXSpeed
    ld   a,PLAYERACTION_KANGAROO_HOPPING
    call call_02_54f9_Player_RequestAction
    call call_02_4df6_Player_LockBPress
    ld   hl,wDABE_CollisionFlags
    bit  7,[hl]
    jr   z,call_02_4d02_PlayerAction_Kangaroo_Hopping
    ld   a,PLAYER_KANGAROO_HOP_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
call_02_4d02_PlayerAction_Kangaroo_Hopping:
; Mid-hop. The airborne idiom, and on landing B gives the big jump while anything
; else lands normally
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ret  nz
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_B
    ld   a,PLAYERACTION_KANGAROO_START_JUMP
    jp   nz,call_02_54f9_Player_RequestAction
    jp   call_02_4dce_Player_SetLandingAction

call_02_4d14_PlayerAction_Kangaroo_StartJump:
; The big jump, built exactly like the hop above but with
; PLAYER_KANGAROO_JUMP_VELOCITY, and falling through into its own airborne half
    ld   a,SFX_GEX_DOUBLE_JUMP
    call call_00_0ff5_QueueSFX
    call call_02_4e01_Player_EnsureMinXSpeed
    ld   a,PLAYERACTION_KANGAROO_JUMP
    call call_02_54f9_Player_RequestAction
    call call_02_4df6_Player_LockBPress
    ld   hl,wDABE_CollisionFlags
    bit  7,[hl]
    jr   z,call_02_4d33_PlayerAction_Kangaroo_Jump
    ld   a,PLAYER_KANGAROO_JUMP_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
call_02_4d33_PlayerAction_Kangaroo_Jump:
; Mid-jump. Landing with B held starts another big jump, so the kangaroo can be
; bounced along indefinitely
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ret  nz
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_B
    ld   a,PLAYERACTION_KANGAROO_START_JUMP
    jp   nz,call_02_54f9_Player_RequestAction
    jp   call_02_4dce_Player_SetLandingAction

call_02_4d45_PlayerAction_Kangaroo_TailSpin:
; The tail spin on the kangaroo. Same first frame as the other two, and on the wrap
; frame it always returns to PLAYERACTION_KANGAROO_IDLE - which, being one hop, puts
; him straight back in motion
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4d5e
    ld   a,SFX_GEX_TAIL_SPIN
    call call_00_0ff5_QueueSFX
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_A_BIT,[hl]
    ld   a,$01
    ld   [wDC7F_Player_IsAttacking],a
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4d5e:
    ld   a,[wD805_Player_ActionState]
    and  a,ACTION_STATE_ANIM_ENDED
    ret  z
    xor  a
    ld   [wDC7F_Player_IsAttacking],a
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
    ld   a,PLAYERACTION_KANGAROO_IDLE
    jp   call_02_54f9_Player_RequestAction

call_02_4d72_PlayerAction_Kangaroo_Fall:
; Falling on the kangaroo, back to hopping on landing
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4d81
    ld   a,$01
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4e01_Player_EnsureMinXSpeed
.jr_02_4d81:
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ld   a,PLAYERACTION_KANGAROO_IDLE
    jp   z,call_02_54f9_Player_RequestAction
    ret  

call_02_4d8b_PlayerAction_Kangaroo_TakeDamage:
; Taking a hit on the kangaroo - the same recoil and cooldown as the other two, back
; to hopping when it ends
    ld   hl,wD805_Player_ActionState
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT,[hl]
    jr   z,.jr_02_4da2
    ld   a,PLAYER_HIT_BOUNCE_VELOCITY
    ld   [wDC8C_PlayerYVelocity],a
    ld   [wDC8E_InitialYVelocity],a
    call call_02_4e01_Player_EnsureMinXSpeed
    ld   a,SFX_PLAYER_DAMAGED
    call call_00_0ff5_QueueSFX
.jr_02_4da2:
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDC7E_Player_DamageCooldownTimer],a
    ld   a,[wDC8E_InitialYVelocity]
    and  a
    ld   a,PLAYERACTION_KANGAROO_IDLE
    jp   z,call_02_54f9_Player_RequestAction
    ret  
