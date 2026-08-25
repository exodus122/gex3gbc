; ==================================================================
; Bank 2. Gex himself. call_02_4f32_Player_UpdateMain is his whole per-frame
; update, called once from call_02_7152_Entities_UpdateAll, and the order it does
; things in matters because each step consumes what the last one produced:
;
;   1. build wDC81_Player_EffectiveInputs from the raw pad, filtered through
;      wDC80_ButtonBlockingFlags. Everything downstream reads that byte and never
;      the pad
;   2. tick the damage cooldown and the three fly power-up timers
;   3. call_02_5081_Player_UpdateFacing - held directions become a facing, and the
;      walk speed ramps one step toward what the action asked for
;   4. bank 3 works out what he is standing on and next to
;   5. call_02_5267_Player_ApplyYVelocity - gravity, terminal velocity, the fall
;      counter, and the landing
;   6. bank 3 caches the tile types around him
;   7. call_02_5431_Player_CheckTileInteractions - kill tiles, water, climbing, and
;      the input transition table. This is where nearly every action change starts
;   8. commit whatever action was requested during 1-7, then run the current
;      action's own function out of wD802_Player_ActionFunc
;   9. call_02_5100_Player_ApplyXMovement - the horizontal move, last, so it sees
;      the speed the action just set
;  10. cache his tile coordinates, clear ACTION_STATE_IS_FIRST_FRAME, and tick his
;      animation through the shared call_02_724d_Entity_TickAction
;
; The action machine
; ------------------
; Gex is entity slot 0, so he has an action id and an action function like any
; entity. What he has on top of that is a queue and a rule table.
;
; Nothing writes wD801_Player_ActionId directly. Every change goes through
; call_02_54f9_Player_RequestAction, which parks the id in
; wDC79_Player_QueuedAction, and step 8 above commits it - so an action change
; always lands on a frame boundary and the last request of the frame wins.
;
; Whether a request is allowed is decided by data_02_554d_PlayerStatesPerAction,
; one PLAYER_STATE_* byte per action. PLAYER_STATE_ACTION_INSTANT means the request
; is honoured no matter what; otherwise the action already holding the queue gets a
; say, and if that one is PLAYER_STATE_ACTION_LOCKED the new request is dropped on
; the floor. That is the whole mechanism that stops a player mashing the d-pad from
; cancelling out of a death or a warp.
;
; The same table doubles as Gex's state: PLAYER_STATE_IN_WATER,
; PLAYER_STATE_CLIMBING, PLAYER_STATE_DEAD and PLAYER_STATE_NO_INPUT_CONTROL are
; all read straight off it by call_02_5541_Player_GetActionStates, so "is he
; swimming" is answered by looking up his action rather than by a flag somebody has
; to remember to clear.
;
; data_02_55c5_ActionInputTransitionTable is the control scheme, as data: one input
; list per action, each a run of (input byte, action id) pairs. The match is on the
; whole input byte rather than on individual bits, which is why every direction
; combination is spelled out separately. A null pointer means the action ignores
; input entirely - that, and nothing else, is what makes the death and warp actions
; uninterruptible.
;
; Vertical is not horizontal
; --------------------------
; Y velocity is signed with POSITIVE MEANING UPWARD, so "still rising" is the sign
; bit being clear and PLAYER_MAX_FALL_VELOCITY is a large negative number. The
; velocity becomes a pixel delta by negating and swapping nibbles, after which bit 3
; of the low nibble carries the sign - the `bit 3, A / or $F0` pair that appears
; twice in call_02_5267_Player_ApplyYVelocity.
;
; Horizontal has no velocity in that sense. wDC86_PlayerXVelocity is a speed, always
; positive, and the direction comes from wD80D_PlayerFacingDirection. It ramps one
; step per frame toward wDC87_PlayerXMaxVelocity and resets to zero on a turn, which
; is why Gex accelerates out of every direction change.
;
; Map of this file
; ----------------
;   $4DB1-$4E0B  small helpers the action functions in bank02_player_actions call
;   $4E0C-$4EE6  the snowboard sprite picker and its two tables
;   $4EE7-$4F31  the d-pad direction index, and "start falling"
;   $4F32-$500D  the per-frame update and the power-up timers
;   $500E-$5080  position helpers and the tile-coordinate cache
;   $5081-$5266  facing, the horizontal move, and the four collision resolvers
;   $5267-$5373  gravity and landing
;   $5374-$53E6  the updraft tiles
;   $53E7-$54F8  the vertical move, the tile interactions and the input table scan
;   $54F9-$554C  requesting an action, and reading an action's state byte
;   $554D-$581B  the two big per-action tables
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank02_update_player.asm
; ------------------------------------------------------------------
; The skeleton is the same and several routines are recognisable line for line -
; the button blocking, the speed ramp, the queued action committed once a frame, the
; per-action flags table, the input transition table with its two sentinels. What
; changed is mostly a consequence of gex3 having top-down maps and vehicle levels:
;
;   two axes       gex2 is a side-scroller and its player code assumes it. gex3
;                  branches on wDC1F_CurrentBgCollisionType in four separate places
;                  (UpdateFacing, ApplyXMovement, ApplyYVelocity and RequestAction),
;                  because on a BG_COLLISION_TYPE_TOPDOWN map the d-pad drives a
;                  direction index rather than a facing, and "gravity" becomes a
;                  hop offset in wDC88_Player_HopYOffset
;   action offset  every side-scrolling action has a top-down twin
;                  PLAYERACTION_TOPDOWN higher, and
;                  call_02_54f9_Player_RequestAction adds that offset on the way
;                  through. So "walk" is one request that lands in two different
;                  actions depending on the map. gex2 has nothing like it
;   vehicles       and on top of that, three actions have to be chosen by map:
;                  MAP_GEXTREME_SPORTS1 uses the snowboard set and
;                  MAP_MARSUPIAL_MADNESS1 the kangaroo set, which is why the
;                  "start falling", "land" and "idle" paths are each written three
;                  times over. call_02_4e0c_Player_UpdateSnowboardSprite exists
;                  only for the snowboard
;   flags table    gex2 splits the per-action data in two -
;                  .data_02_4cf5_ActionTransitionFlagsTable for the two transition
;                  bits, and state elsewhere. gex3 packs both into
;                  data_02_554d_PlayerStatesPerAction, so PLAYER_STATE_* covers what
;                  gex2 calls ACTION_TRANSITION_* as well
;   map edges      gex3 levels are several maps, so running into the side of one is
;                  a transition rather than a wall: the four clamp paths here record
;                  MAP_EDGE_* in wDC8A_MapEdgeTouched and let
;                  call_00_150f_Map_CheckEdgeTransition warp. On maps that wrap
;                  (wDC2A_MapBoundaryIndex zero) the clamp is skipped entirely and
;                  the position is masked instead. gex2 just stops
;   absent here    gex2's demo playback, its jump-velocity lookup with the spring
;                  tiles, its lava check and its idle-timer helper are all either
;                  gex3-elsewhere or gone. gex3 adds the tile-coordinate cache, the
;                  updraft tiles and the entity push-out at $4DB1, none of which
;                  gex2 has
; ==================================================================

call_02_4db1_Player_PushOutOfEntity:
; Shoves Gex clear of a particular entity, by id in C.
;
; Finds the slot, compares its X against his, and jumps into whichever of the two
; horizontal movers pushes him away from it - right if the entity is to his left,
; left if it is to his right. Exactly aligned does nothing. BC is $0001, so the push
; is one pixel per frame rather than a teleport.
;
; Called by the action functions for the things Gex must not stand inside. No gex2
; equivalent
    call call_00_29ce_Entity_FindSlotById             ;; 02:4db1 $cd $ce $29
    ret  NZ                                           ;; 02:4db4 $c0
    ld   A, L                                         ;; 02:4db5 $7d
    or   A, $0e                                       ;; 02:4db6 $f6 $0e
    ld   L, A                                         ;; 02:4db8 $6f
    ld   BC, $01                                      ;; 02:4db9 $01 $01 $00
    ld   A, [wD80E_PlayerXPosition]                   ;; 02:4dbc $fa $0e $d8
    sub  A, [HL]                                      ;; 02:4dbf $96
    ld   E, A                                         ;; 02:4dc0 $5f
    inc  HL                                           ;; 02:4dc1 $23
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 02:4dc2 $fa $0f $d8
    sbc  A, [HL]                                      ;; 02:4dc5 $9e
    jp   C, call_02_51f9_Player_MoveRight             ;; 02:4dc6 $da $f9 $51
    or   A, E                                         ;; 02:4dc9 $b3
    ret  Z                                            ;; 02:4dca $c8
    jp   call_02_518a_Player_MoveLeft                 ;; 02:4dcb $c3 $8a $51

call_02_4dce_Player_SetLandingAction:
; Picks the action to land in, and is the shared tail of every landing path.
;
; Sets BTN_BLOCK_B_UNTIL_RELEASE first, so a held B cannot immediately re-jump out
; of the landing. Then the choice: MAP_GEXTREME_SPORTS1 and MAP_MARSUPIAL_MADNESS1
; have vehicle actions of their own, and everywhere else it is
; PLAYERACTION_WALK if a direction is held and PLAYERACTION_IDLE if not.
;
; gex2's call_02_489a_Player_SetLandingAction does the same job with the same
; button block, and additionally distinguishes walk from run by the speed carried
; into the landing - gex3 has no separate run action
    ld   HL, wDC80_ButtonBlockingFlags                ;; 02:4dce $21 $80 $dc
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT, [HL]          ;; 02:4dd1 $cb $f6
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:4dd3 $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                      ;; 02:4dd6 $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_STAND_OR_WALK   ;; 02:4dd8 $3e $24
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:4dda $ca $f9 $54
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:4ddd $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                    ;; 02:4de0 $fe $08
    ld   A, PLAYERACTION_KANGAROO_IDLE                ;; 02:4de2 $3e $30
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:4de4 $ca $f9 $54
    ld   C, PLAYERACTION_IDLE                         ;; 02:4de7 $0e $01
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:4de9 $fa $81 $dc
    and  A, PADF_LEFT | PADF_RIGHT                    ;; 02:4dec $e6 $30
    jr   Z, .jr_02_4df2                               ;; 02:4dee $28 $02
    ld   C, PLAYERACTION_WALK                         ;; 02:4df0 $0e $03
.jr_02_4df2:
    ld   A, C                                         ;; 02:4df2 $79
    jp   call_02_54f9_Player_RequestAction            ;; 02:4df3 $c3 $f9 $54

call_02_4df6_Player_LockBPress:
; Arms BTN_BLOCK_B_WHILE_RISING and clears the other three block bits, so B is
; ignored for as long as Gex is still going up.
;
; Called at the start of every jump. It is what makes the double jump require a
; fresh press: B stays blocked through the rise, and only the release-and-repress
; latch (BTN_BLOCK_B_REPRESS_LATCH) lets a second press through.
; gex2's call_02_4a3a_Player_LockBPress, same instructions
    ld   A, [wDC80_ButtonBlockingFlags]               ;; 02:4df6 $fa $80 $dc
    and  A, BTN_BLOCK_KEEP_MASK                       ;; 02:4df9 $e6 $0f
    or   A, BTN_BLOCK_B_WHILE_RISING                  ;; 02:4dfb $f6 $80
    ld   [wDC80_ButtonBlockingFlags], A               ;; 02:4dfd $ea $80 $dc
    ret                                               ;; 02:4e00 $c9

call_02_4e01_Player_EnsureMinXSpeed:
; Makes wDC87_PlayerXMaxVelocity at least 1, leaving it alone if it is already set.
;
; Called at the start of a jump and of the damage bounce, which is what gives Gex
; some air control even when he left the ground from a standstill - without it the
; speed ramp in call_02_5081_Player_UpdateFacing would have nothing to aim at
    ld   A, [wDC87_PlayerXMaxVelocity]                ;; 02:4e01 $fa $87 $dc
    and  A, A                                         ;; 02:4e04 $a7
    ret  NZ                                           ;; 02:4e05 $c0
    ld   A, $01                                       ;; 02:4e06 $3e $01
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:4e08 $ea $87 $dc
    ret                                               ;; 02:4e0b $c9

call_02_4e0c_Player_UpdateSnowboardSprite:
; Picks Gex's sprite on the snowboard, where the pose depends on the ground rather
; than on the animation. MAP_GEXTREME_SPORTS1 only.
;
; The terrain under him - wDC95_FloorTileType, falling back to the tile behind his
; lower body - is looked up in one of the two tables below to get a base sprite id,
; chosen for his facing direction. A frame counter on top of that cycles through the
; poses: eight of them during PLAYERACTION_SNOWBOARDING_TAIL_SPIN, after which the
; spin ends and he goes back to standing, and two otherwise.
;
; Writes wD80A_Player_SpriteId directly and raises GFX_XFER_PLAYER_GFX itself,
; because it is bypassing the normal animation player. It returns early when the
; sprite has not changed, so the transfer is only asked for on the frames it matters
    ld   a,[wDCA5_Player_SnowboardingRelated4]
    ld   [wDCA6_Player_SnowboardingRelated5],a
    ld   hl,wDC95_FloorTileType
    ld   e,[hl]
    call call_02_4e7a_Player_LookupSnowboardSprite
    inc  d
    dec  d
    jr   nz,.jr_02_4e24
    ld   hl,wDC93_TileTypeBehindGexsLowerBody
    ld   e,[hl]
    call call_02_4e7a_Player_LookupSnowboardSprite
.jr_02_4e24:
    ld   hl,wDCA5_Player_SnowboardingRelated4
    ld   [hl],d
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    jr   nz,.jr_02_4e57
    ld   hl,wDCA3_Player_SnowboardingRelated2
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_02_4e50
    ld   [hl],$03
    ld   hl,wDCA2_Player_SnowboardingRelated
    inc  [hl]
    ld   a,[hl]
    cp   a,$08
    jr   c,.jr_02_4e50
    xor  a
    ld   [wDC7F_Player_IsAttacking],a
    ld   hl,wDC80_ButtonBlockingFlags
    set  BTN_BLOCK_B_UNTIL_RELEASE_BIT,[hl]
    ld   a,PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    jp   call_02_54f9_Player_RequestAction
.jr_02_4e50:
    ld   a,[wDCA2_Player_SnowboardingRelated]
    and  a,$07
    jr   .jr_02_4e6a
.jr_02_4e57:
    ld   hl,wDCA3_Player_SnowboardingRelated2
    dec  [hl]
    bit  7,[hl]
    jr   z,.jr_02_4e65
    ld   [hl],$09
    ld   hl,wDCA2_Player_SnowboardingRelated
    inc  [hl]
.jr_02_4e65:
    ld   a,[wDCA2_Player_SnowboardingRelated]
    and  a,$01
.jr_02_4e6a:
    ld   hl,wDCA4_Player_SnowboardingRelated3
    add  [hl]
    ld   hl,wD80A_Player_SpriteId
    cp   [hl]
    ret  z
    ld   [hl],a
    ld   hl,wDB66_GfxTransferFlags
    set  GFX_XFER_PLAYER_GFX,[hl]
    ret  

call_02_4e7a_Player_LookupSnowboardSprite:
; Scans one of the two tables for tile type E and leaves the matching sprite id in
; wDCA4_Player_SnowboardingRelated3, choosing between the entry's two bytes by
; facing direction. D comes back as E on a hit and zero on a miss, which is how the
; caller knows to try its second tile.
;
; .data_02_4ec3_TailSpinSprites is used during the tail spin and
; .data_02_4ea3_SnowboardSprites the rest of the time; note the `- 2` on the second,
; which pre-compensates for the `inc hl / inc hl` at the top of the loop
    ld   d,$00
    ld   hl,.data_02_4ec3_TailSpinSprites
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    jr   z,.jr_02_4e89
    ld   hl,.data_02_4ea3_SnowboardSprites-2
.jr_02_4e89:
    inc  hl
    inc  hl
    ldi  a,[hl]
    cp   a,ENTITY_LIST_TERMINATOR
    ret  z
    cp   e
    jr   nz,.jr_02_4e89
    ld   d,e
    ld   c,[hl]
    inc  hl
    ld   b,[hl]
    ld   a,[wD80D_PlayerFacingDirection]
    cp   a,$00
    ld   a,c
    jr   z,.jr_02_4e9f
    ld   a,b
.jr_02_4e9f:
    ld   [wDCA4_Player_SnowboardingRelated3],a
    ret  
.data_02_4ea3_SnowboardSprites:
    db   $01                                          ;; 02:4e9c ????????
    db   $05, $05, $06, $09, $01, $0d, $09, $01       ;; 02:4ea4 ????????
    db   $05, $01, $09, $0e, $01, $09, $09, $07       ;; 02:4eac ????????
    db   $03, $0a, $07, $03, $0b, $03, $07, $0c       ;; 02:4eb4 ????????
    db   $03, $07, $0f, $03, $07, $10, $03
.data_02_4ec3_TailSpinSprites:
    db   $07                                          ;; 02:4ebc ????????
    db   $ff, $01, $0b, $0b, $06, $1b, $13, $0d       ;; 02:4ec4 ????????
    db   $1b, $13, $05, $13, $1b, $0e, $13, $1b       ;; 02:4ecc ????????
    db   $09, $2b, $23, $0a, $2b, $23, $0b, $23       ;; 02:4ed4 ????????
    db   $2b, $0c, $23, $2b, $0f, $23, $2b, $10       ;; 02:4edc ????????
    db   $23, $2b, $ff

call_02_4ee7_Player_GetDPadDirectionIndex:
; Turns the d-pad into a direction number 0-7, or $FF for no direction held.
;
; The eight-entry table below is (input byte, index) pairs covering the four
; cardinals and the four diagonals, and the match is on the whole d-pad nibble - so
; three keys held at once matches nothing and reads as $FF.
;
; Used by the top-down and swimming actions, which need a direction rather than the
; left/right facing the side-scrolling code works in
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
    jr   z,.jr_02_4efb
    ld   hl,.data_02_4f01_DPadToDirectionIndex
    ld   b,$08
.jr_02_4ef3:
    cp   [hl]
    jr   z,.jr_02_4efe
    inc  hl
    inc  hl
    dec  b
    jr   nz,.jr_02_4ef3
.jr_02_4efb:
    ld   a,DPAD_DIRECTION_NONE
    ret  
.jr_02_4efe:
    inc  hl
    ld   a,[hl]
    ret  
.data_02_4f01_DPadToDirectionIndex:
    db   $40, $00, $80, $04, $20, $06, $10, $02
    db   $60, $07, $a0, $05, $50, $01, $90, $03

call_02_4f11_Player_RequestFallAction:
; "Start falling" - one of the three places that has to pick an action by map
; because of the vehicle levels: the snowboard and kangaroo falls, or
; PLAYERACTION_FALL everywhere else.
;
; Returns without doing anything if bit 7 of either collision-flag byte is set,
; which is the "there is ground under him" bit - so this is safe to call
; unconditionally from an action that does not know whether he is airborne
    ld   A, [wDABD_CollisionFlagsPrev]                ;; 02:4f11 $fa $bd $da
    ld   HL, wDABE_CollisionFlags                     ;; 02:4f14 $21 $be $da
    or   A, [HL]                                      ;; 02:4f17 $b6
    bit  7, A                                         ;; 02:4f18 $cb $7f
    ret  NZ                                           ;; 02:4f1a $c0
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:4f1b $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                      ;; 02:4f1e $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_FALL            ;; 02:4f20 $3e $28
    jr   Z, .jr_02_4f2f                               ;; 02:4f22 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:4f24 $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                    ;; 02:4f27 $fe $08
    ld   A, PLAYERACTION_KANGAROO_FALL                ;; 02:4f29 $3e $35
    jr   Z, .jr_02_4f2f                               ;; 02:4f2b $28 $02
    ld   A, PLAYERACTION_FALL                         ;; 02:4f2d $3e $11
.jr_02_4f2f:
    jp   call_02_54f9_Player_RequestAction            ;; 02:4f2f $c3 $f9 $54

call_02_4f32_Player_UpdateMain:
; Gex's whole frame. See the header for the ordering; the parts that are not obvious
; from the call list are these.
;
; The input filter at the top is three separate blocks, one per block bit. A is
; cleared from the pad while BTN_BLOCK_A_BIT is set, and the bit itself clears the
; moment the player lets go. B has two mechanisms: BTN_BLOCK_B_UNTIL_RELEASE_BIT is
; the same idea, while BTN_BLOCK_B_WHILE_RISING_BIT suppresses B only while Y
; velocity is upward - and if the player lets go during that rise it latches
; BTN_BLOCK_B_REPRESS_LATCH_BIT, which lets exactly one fresh press through. That
; three-bit dance is the double jump.
;
; PLAYERACTION_UNK7 gets a fourth treatment: left and right are stripped out and
; replaced by whichever one matches his current facing, so the action moves him
; forward regardless of what the player does.
;
; The queued action is committed here rather than inside Player_RequestAction -
; read wDC79_Player_QueuedAction, put PLAYERACTION_NONE_PENDING back, and hand the
; id to call_02_72ac_Entity_SetAction only if it was not already none.
;
; Then the action's own function, reached through wD802_Player_ActionFunc and
; call_00_0f22_JumpHL. Note what comes AFTER it: the horizontal move, the tile
; coordinate cache and the animation tick all run once the action has had its say,
; which is why an action can set a speed and have it applied the same frame.
;
; gex2's call_02_4939_Player_UpdateMain is the same routine plus demo playback,
; which gex3 does not have
    ld   A, [wDAD7_RawInputs]                         ;; 02:4f32 $fa $d7 $da
    ld   C, A                                         ;; 02:4f35 $4f
    ld   E, A                                         ;; 02:4f36 $5f
    ld   HL, wDC80_ButtonBlockingFlags                ;; 02:4f37 $21 $80 $dc
    bit  BTN_BLOCK_A_BIT, [HL]                        ;; 02:4f3a $cb $46
    jr   Z, .jr_02_4f46                               ;; 02:4f3c $28 $08
    bit  PADF_A_BIT, E                                ;; 02:4f3e $cb $43
    jr   NZ, .jr_02_4f44                              ;; 02:4f40 $20 $02
    res  BTN_BLOCK_A_BIT, [HL]                        ;; 02:4f42 $cb $86
.jr_02_4f44:
    res  PADF_A_BIT, C                                ;; 02:4f44 $cb $81
.jr_02_4f46:
    bit  BTN_BLOCK_B_UNTIL_RELEASE_BIT, [HL]          ;; 02:4f46 $cb $76
    jr   Z, .jr_02_4f56                               ;; 02:4f48 $28 $0c
    bit  PADF_B_BIT, E                                ;; 02:4f4a $cb $4b
    jr   NZ, .jr_02_4f52                              ;; 02:4f4c $20 $04
    ld   A, [HL]                                      ;; 02:4f4e $7e
    and  A, BTN_BLOCK_KEEP_MASK                       ;; 02:4f4f $e6 $0f
    ld   [HL], A                                      ;; 02:4f51 $77
.jr_02_4f52:
    res  PADF_B_BIT, C                                ;; 02:4f52 $cb $89
    jr   .jr_02_4f71                                  ;; 02:4f54 $18 $1b
.jr_02_4f56:
    bit  BTN_BLOCK_B_WHILE_RISING_BIT, [HL]           ;; 02:4f56 $cb $7e
    jr   Z, .jr_02_4f71                               ;; 02:4f58 $28 $17
    res  PADF_B_BIT, C                                ;; 02:4f5a $cb $89
    ld   A, [wDC8C_PlayerYVelocity]                   ;; 02:4f5c $fa $8c $dc
    bit  7, A                                         ;; 02:4f5f $cb $7f
    jr   Z, .jr_02_4f71                               ;; 02:4f61 $28 $0e
    bit  PADF_B_BIT, E                                ;; 02:4f63 $cb $4b
    jr   NZ, .jr_02_4f6b                              ;; 02:4f65 $20 $04
    set  BTN_BLOCK_B_REPRESS_LATCH_BIT, [HL]          ;; 02:4f67 $cb $e6
    jr   .jr_02_4f71                                  ;; 02:4f69 $18 $06
.jr_02_4f6b:
    bit  BTN_BLOCK_B_REPRESS_LATCH_BIT, [HL]          ;; 02:4f6b $cb $66
    jr   Z, .jr_02_4f71                               ;; 02:4f6d $28 $02
    set  PADF_B_BIT, C                                ;; 02:4f6f $cb $c9
.jr_02_4f71:
    ld   A, [wD801_Player_ActionId]                   ;; 02:4f71 $fa $01 $d8
    cp   A, PLAYERACTION_UNK7                         ;; 02:4f74 $fe $07
    jr   NZ, .jr_02_4f89                              ;; 02:4f76 $20 $11
    res  PADF_RIGHT_BIT, C                            ;; 02:4f78 $cb $a1
    res  PADF_LEFT_BIT, C                             ;; 02:4f7a $cb $a9
    ld   A, [wD80D_PlayerFacingDirection]             ;; 02:4f7c $fa $0d $d8
    and  A, ENTITY_FACING_LEFT                        ;; 02:4f7f $e6 $20
    ld   A, PADF_LEFT                                 ;; 02:4f81 $3e $20
    jr   NZ, .jr_02_4f87                              ;; 02:4f83 $20 $02
    ld   A, PADF_RIGHT                                ;; 02:4f85 $3e $10
.jr_02_4f87:
    or   A, C                                         ;; 02:4f87 $b1
    ld   C, A                                         ;; 02:4f88 $4f
.jr_02_4f89:
    ld   HL, wDC81_Player_EffectiveInputs             ;; 02:4f89 $21 $81 $dc
    ld   [HL], C                                      ;; 02:4f8c $71
    ld   HL, wDC7E_Player_DamageCooldownTimer         ;; 02:4f8d $21 $7e $dc
    ld   A, [HL]                                      ;; 02:4f90 $7e
    and  A, A                                         ;; 02:4f91 $a7
    jr   Z, .jr_02_4f95                               ;; 02:4f92 $28 $01
    dec  [HL]                                         ;; 02:4f94 $35
.jr_02_4f95:
    ld   HL, wDCA9_FlyPowerup2_Timer                  ;; 02:4f95 $21 $a9 $dc
    call call_02_4ffb_Player_DecrementPowerupTimer    ;; 02:4f98 $cd $fb $4f
    ld   HL, wDCAA_FlyPowerup1_Timer                  ;; 02:4f9b $21 $aa $dc
    call call_02_4ffb_Player_DecrementPowerupTimer    ;; 02:4f9e $cd $fb $4f
    ld   HL, wDCAB_FlyPowerup5_Timer                  ;; 02:4fa1 $21 $ab $dc
    call call_02_4ffb_Player_DecrementPowerupTimer    ;; 02:4fa4 $cd $fb $4f
    farcall call_03_6567_FlyPowerup_LoadPalette
    call call_02_5081_Player_UpdateFacing             ;; 02:4fb2 $cd $81 $50
    farcall call_03_46e0_BgCollision_Update
    call call_02_5267_Player_ApplyYVelocity           ;; 02:4fc0 $cd $67 $52
    farcall call_03_4bb6_BgCollision_CacheNearbyTileTypes
    call call_02_5431_Player_CheckTileInteractions    ;; 02:4fce $cd $31 $54
    ld   HL, wDC79_Player_QueuedAction                ;; 02:4fd1 $21 $79 $dc
    ld   A, [HL]                                      ;; 02:4fd4 $7e
    ld   [HL], PLAYERACTION_NONE_PENDING              ;; 02:4fd5 $36 $ff
    cp   A, PLAYERACTION_NONE_PENDING                 ;; 02:4fd7 $fe $ff
    call NZ, call_02_72ac_Entity_SetAction            ;; 02:4fd9 $c4 $ac $72
    ld   HL, wD802_Player_ActionFunc                  ;; 02:4fdc $21 $02 $d8
    ld   A, [HL+]                                     ;; 02:4fdf $2a
    ld   H, [HL]                                      ;; 02:4fe0 $66
    ld   L, A                                         ;; 02:4fe1 $6f
    call call_00_0f22_JumpHL                          ;; 02:4fe2 $cd $22 $0f
    ld   HL, wDCAC_Player_CrouchLookDownRelated       ;; 02:4fe5 $21 $ac $dc
    ld   A, [HL]                                      ;; 02:4fe8 $7e
    and  A, A                                         ;; 02:4fe9 $a7
    jr   Z, .jr_02_4fed                               ;; 02:4fea $28 $01
    dec  [HL]                                         ;; 02:4fec $35
.jr_02_4fed:
    call call_02_5100_Player_ApplyXMovement           ;; 02:4fed $cd $00 $51
    call call_02_5047_CachePlayerTileCoords           ;; 02:4ff0 $cd $47 $50
    ld   HL, wD805_Player_ActionState                 ;; 02:4ff3 $21 $05 $d8
    res  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 02:4ff6 $cb $a6
    jp   call_02_724d_Entity_TickAction               ;; 02:4ff8 $c3 $4d $72

call_02_4ffb_Player_DecrementPowerupTimer:
; Counts the timer at HL down by one, but only once every TIMER_AMOUNT_60_FRAMES
; frames - so the fly power-up timers are in seconds, not frames.
;
; The frame counter wDCA8_FlyPowerup_FrameCounter is shared by all three timers and
; is decremented by whichever of them happens to be called first, then left alone by
; the others (they see it is not at its reload value and skip). Returns immediately
; if the timer is already zero, so an expired power-up does not keep the counter
; alive. gex2's call_02_4a30_Player_DecrementPowerupTimer counts 16-bit frames
; instead
    ld   A, [HL]                                      ;; 02:4ffb $7e
    and  A, A                                         ;; 02:4ffc $a7
    ret  Z                                            ;; 02:4ffd $c8
    ld   A, [wDCA8_FlyPowerup_FrameCounter]           ;; 02:4ffe $fa $a8 $dc
    dec  A                                            ;; 02:5001 $3d
    jr   NZ, .jr_02_5006                              ;; 02:5002 $20 $02
    ld   A, TIMER_AMOUNT_60_FRAMES                    ;; 02:5004 $3e $3c
.jr_02_5006:
    ld   [wDCA8_FlyPowerup_FrameCounter], A           ;; 02:5006 $ea $a8 $dc
    cp   A, TIMER_AMOUNT_60_FRAMES                    ;; 02:5009 $fe $3c
    ret  NZ                                           ;; 02:500b $c0
    dec  [HL]                                         ;; 02:500c $35
    ret                                               ;; 02:500d $c9

call_02_500e_Player_MoveByDPad:
; Moves Gex two pixels per frame in whatever directions are held, straight off the
; pad and with no collision, no facing and no speed ramp.
;
; Nothing in the game calls it. It reads as the free-movement helper it presumably
; was during development
    call call_00_0f6e_CheckInputRight
    ld   bc,$0002
    call nz,call_02_5033_Player_AddToXPosition
    call call_00_0f68_CheckInputLeft
    ld   bc,hFFFE
    call nz,call_02_5033_Player_AddToXPosition
    call call_00_0f7a_CheckInputDown
    ld   bc,$0002
    call nz,call_02_503d_Player_AddToYPosition
    call call_00_0f74_CheckInputUp
    ld   bc,hFFFE
    call nz,call_02_503d_Player_AddToYPosition
    ret  

call_02_5033_Player_AddToXPosition:
; Adds the signed 16-bit BC to wD80E_PlayerXPosition. gex2's
; call_02_4c0a_Player_AddToXPosition
    ld   hl,wD80E_PlayerXPosition
    ld   a,[hl]
    add  c
    ldi  [hl],a
    ld   a,[hl]
    adc  b
    ld   [hl],a
    ret  

call_02_503d_Player_AddToYPosition:
; Adds the signed 16-bit BC to wD810_PlayerYPosition. gex2's
; call_02_4c19_Player_AddToYPosition
    ld   hl,wD810_PlayerYPosition
    ld   a,[hl]
    add  c
    ldi  [hl],a
    ld   a,[hl]
    adc  b
    ld   [hl],a
    ret  

call_02_5047_CachePlayerTileCoords:
; Divides Gex's two 16-bit world positions by 16 and parks the results in
; wDC54_CachedTileXCoord and wDC56_CachedTileYCoord, so the collision code in bank 3
; does not have to redo the shift on every probe.
;
; Run at the very end of the frame, after everything that could have moved him. No
; gex2 equivalent - gex2 shifts at each use site
    ld   HL, wD80E_PlayerXPosition                    ;; 02:5047 $21 $0e $d8
    ld   A, [HL+]                                     ;; 02:504a $2a
    ld   E, A                                         ;; 02:504b $5f
    ld   D, [HL]                                      ;; 02:504c $56
    srl  D                                            ;; 02:504d $cb $3a
    rr   E                                            ;; 02:504f $cb $1b
    srl  D                                            ;; 02:5051 $cb $3a
    rr   E                                            ;; 02:5053 $cb $1b
    srl  D                                            ;; 02:5055 $cb $3a
    rr   E                                            ;; 02:5057 $cb $1b
    srl  D                                            ;; 02:5059 $cb $3a
    rr   E                                            ;; 02:505b $cb $1b
    ld   A, E                                         ;; 02:505d $7b
    ld   HL, wDC54_CachedTileXCoord                   ;; 02:505e $21 $54 $dc
    ld   A, E                                         ;; 02:5061 $7b
    ld   [HL+], A                                     ;; 02:5062 $22
    ld   [HL], D                                      ;; 02:5063 $72
    ld   HL, wD810_PlayerYPosition                    ;; 02:5064 $21 $10 $d8
    ld   A, [HL+]                                     ;; 02:5067 $2a
    ld   E, A                                         ;; 02:5068 $5f
    ld   D, [HL]                                      ;; 02:5069 $56
    srl  D                                            ;; 02:506a $cb $3a
    rr   E                                            ;; 02:506c $cb $1b
    srl  D                                            ;; 02:506e $cb $3a
    rr   E                                            ;; 02:5070 $cb $1b
    srl  D                                            ;; 02:5072 $cb $3a
    rr   E                                            ;; 02:5074 $cb $1b
    srl  D                                            ;; 02:5076 $cb $3a
    rr   E                                            ;; 02:5078 $cb $1b
    ld   HL, wDC56_CachedTileYCoord                   ;; 02:507a $21 $56 $dc
    ld   A, E                                         ;; 02:507d $7b
    ld   [HL+], A                                     ;; 02:507e $22
    ld   [HL], D                                      ;; 02:507f $72
    ret                                               ;; 02:5080 $c9

call_02_5081_Player_UpdateFacing:
; Turns held directions into a facing, and ramps Gex up to speed.
;
; Three exits before it does anything. An action flagged
; PLAYER_STATE_NO_INPUT_CONTROL steers itself, and so the speed is zeroed and the
; routine returns; the same happens on a side-scrolling map when no direction is
; held, or when the direction held is a reversal.
;
; On a top-down map, or while swimming or climbing, the d-pad also picks a direction
; index out of .data_02_50f0_TopDownDirectionTable into
; wDC89_BgCollision_TopDownDirection - that table is indexed by the whole d-pad
; nibble, so it covers the diagonals too.
;
; The ramp itself is the last four instructions and is what gives Gex his
; acceleration: wDC86_PlayerXVelocity moves one step per frame toward
; wDC87_PlayerXMaxVelocity and is reset to zero on a turn, so he always builds up
; from a standstill rather than snapping to full speed.
; gex2's call_02_4a45_Player_UpdateFacing
    ld   HL, wD801_Player_ActionId                    ;; 02:5081 $21 $01 $d8
    ld   L, [HL]                                      ;; 02:5084 $6e
    ld   H, $00                                       ;; 02:5085 $26 $00
    ld   DE, data_02_554d_PlayerStatesPerAction       ;; 02:5087 $11 $4d $55
    add  HL, DE                                       ;; 02:508a $19
    bit  PLAYER_STATE_NO_INPUT_CONTROL, [HL]          ;; 02:508b $cb $56
    jr   NZ, .jr_02_50db                              ;; 02:508d $20 $4c
    call call_02_5541_Player_GetActionStates          ;; 02:508f $cd $41 $55
    and  A, PLAYER_STATE_IN_WATER_MASK | PLAYER_STATE_CLIMBING_MASK ;; 02:5092 $e6 $a0
    jr   NZ, .jr_02_509d                              ;; 02:5094 $20 $07
    ld   A, [wDC1F_CurrentBgCollisionType]            ;; 02:5096 $fa $1f $dc
    cp   A, BG_COLLISION_TYPE_SIDESCROLLER            ;; 02:5099 $fe $00
    jr   Z, .jr_02_50c4                               ;; 02:509b $28 $27
.jr_02_509d:
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:509d $fa $81 $dc
    and  A, PADF_RIGHT | PADF_LEFT                    ;; 02:50a0 $e6 $30
    jr   Z, .jr_02_50b0                               ;; 02:50a2 $28 $0c
    ld   C, ENTITY_FACING_RIGHT                       ;; 02:50a4 $0e $00
    and  A, PADF_RIGHT                                ;; 02:50a6 $e6 $10
    jr   NZ, .jr_02_50ac                              ;; 02:50a8 $20 $02
    ld   C, ENTITY_FACING_LEFT                        ;; 02:50aa $0e $20
.jr_02_50ac:
    ld   HL, wD80D_PlayerFacingDirection              ;; 02:50ac $21 $0d $d8
    ld   [HL], C                                      ;; 02:50af $71
.jr_02_50b0:
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:50b0 $fa $81 $dc
    swap A                                            ;; 02:50b3 $cb $37
    and  A, PADF_A | PADF_B | PADF_SELECT | PADF_START ;; 02:50b5 $e6 $0f
    ld   L, A                                         ;; 02:50b7 $6f
    ld   H, $00                                       ;; 02:50b8 $26 $00
    ld   DE, .data_02_50f0_TopDownDirectionTable      ;; 02:50ba $11 $f0 $50
    add  HL, DE                                       ;; 02:50bd $19
    ld   A, [HL]                                      ;; 02:50be $7e
    ld   [wDC89_BgCollision_TopDownDirection], A      ;; 02:50bf $ea $89 $dc
    jr   .jr_02_50e0                                  ;; 02:50c2 $18 $1c
.jr_02_50c4:
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:50c4 $fa $81 $dc
    and  A, PADF_RIGHT | PADF_LEFT                    ;; 02:50c7 $e6 $30
    jr   Z, .jr_02_50db                               ;; 02:50c9 $28 $10
    ld   C, ENTITY_FACING_RIGHT                       ;; 02:50cb $0e $00
    and  A, PADF_RIGHT                                ;; 02:50cd $e6 $10
    jr   NZ, .jr_02_50d3                              ;; 02:50cf $20 $02
    ld   C, ENTITY_FACING_LEFT                        ;; 02:50d1 $0e $20
.jr_02_50d3:
    ld   HL, wD80D_PlayerFacingDirection              ;; 02:50d3 $21 $0d $d8
    ld   A, [HL]                                      ;; 02:50d6 $7e
    ld   [HL], C                                      ;; 02:50d7 $71
    cp   A, C                                         ;; 02:50d8 $b9
    jr   Z, .jr_02_50e0                               ;; 02:50d9 $28 $05
.jr_02_50db:
    xor  A, A                                         ;; 02:50db $af
    ld   [wDC86_PlayerXVelocity], A                   ;; 02:50dc $ea $86 $dc
    ret                                               ;; 02:50df $c9
.jr_02_50e0:
    ld   A, [wDC86_PlayerXVelocity]                   ;; 02:50e0 $fa $86 $dc
    ld   HL, wDC87_PlayerXMaxVelocity                 ;; 02:50e3 $21 $87 $dc
    cp   A, [HL]                                      ;; 02:50e6 $be
    jr   C, .jr_02_50eb                               ;; 02:50e7 $38 $02
    ld   A, [HL]                                      ;; 02:50e9 $7e
    dec  A                                            ;; 02:50ea $3d
.jr_02_50eb:
    inc  A                                            ;; 02:50eb $3c
    ld   [wDC86_PlayerXVelocity], A                   ;; 02:50ec $ea $86 $dc
    ret                                               ;; 02:50ef $c9
.data_02_50f0_TopDownDirectionTable:
    db   $00, $03, $07, $03, $01, $02, $08, $02       ;; 02:50f0 ????????
    db   $05, $04, $06, $04, $05, $04, $06, $04       ;; 02:50f8 ????????

call_02_5100_Player_ApplyXMovement:
; The horizontal move for the frame, and one of the two routines here that is
; genuinely two routines depending on the map.
;
; On a top-down map, or while swimming or climbing, the d-pad drives all four
; directions directly: right and left go through the two horizontal movers, down and
; up through call_02_53e7_Player_MoveYClampedToMap with the speed negated for up.
; Swimming is allowed in only two actions, so a swim in any other state moves
; nothing.
;
; On an ordinary side-scrolling map the delta is Gex's own speed - negated if he
; faces left - plus the two world deltas wDC84_PlayerXDeltaExtra and
; wDC85_PlayerXDeltaExtra2, which are whatever a platform, a walkway or a knockback
; is doing to him. Zero total means nothing to do. If the low nibble of
; wDABE_CollisionFlags is set he is on a slope, and an equal upward Y nudge is
; applied first so that walking up an incline does not clip him into it. Then the
; sign of the total picks which of the two movers runs.
;
; gex2's call_02_4a77_Player_ApplyXMovement, which has the slope nudge and the
; extra-delta sum but no top-down half
    call call_02_5541_Player_GetActionStates          ;; 02:5100 $cd $41 $55
    and  A, PLAYER_STATE_IN_WATER_MASK | PLAYER_STATE_CLIMBING_MASK ;; 02:5103 $e6 $a0
    jr   NZ, .jr_02_510e                              ;; 02:5105 $20 $07
    ld   A, [wDC1F_CurrentBgCollisionType]            ;; 02:5107 $fa $1f $dc
    cp   A, BG_COLLISION_TYPE_SIDESCROLLER            ;; 02:510a $fe $00
    jr   Z, .jr_02_5159                               ;; 02:510c $28 $4b
.jr_02_510e:
    ld   A, [wDC86_PlayerXVelocity]                   ;; 02:510e $fa $86 $dc
    and  A, A                                         ;; 02:5111 $a7
    ret  Z                                            ;; 02:5112 $c8
    ld   HL, wDC86_PlayerXVelocity                    ;; 02:5113 $21 $86 $dc
    ld   C, [HL]                                      ;; 02:5116 $4e
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:5117 $fa $81 $dc
    and  A, PADF_RIGHT                                ;; 02:511a $e6 $10
    call NZ, call_02_51f9_Player_MoveRight            ;; 02:511c $c4 $f9 $51
    ld   HL, wDC86_PlayerXVelocity                    ;; 02:511f $21 $86 $dc
    ld   C, [HL]                                      ;; 02:5122 $4e
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:5123 $fa $81 $dc
    and  A, PADF_LEFT                                 ;; 02:5126 $e6 $20
    call NZ, call_02_518a_Player_MoveLeft             ;; 02:5128 $c4 $8a $51
    call call_02_553b_Player_IsInWater                ;; 02:512b $cd $3b $55
    jr   Z, .jr_02_513a                               ;; 02:512e $28 $0a
    ld   A, [wD801_Player_ActionId]                   ;; 02:5130 $fa $01 $d8
    cp   A, PLAYERACTION_WATER_SWIMMING               ;; 02:5133 $fe $19
    jr   Z, .jr_02_513a                               ;; 02:5135 $28 $03
    cp   A, PLAYERACTION_WATER_TAIL_SPIN              ;; 02:5137 $fe $1f
    ret  NZ                                           ;; 02:5139 $c0
.jr_02_513a:
    ld   HL, wDC86_PlayerXVelocity                    ;; 02:513a $21 $86 $dc
    ld   C, [HL]                                      ;; 02:513d $4e
    ld   B, $00                                       ;; 02:513e $06 $00
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:5140 $fa $81 $dc
    and  A, PADF_DOWN                                 ;; 02:5143 $e6 $80
    call NZ, call_02_53e7_Player_MoveYClampedToMap    ;; 02:5145 $c4 $e7 $53
    ld   A, [wDC86_PlayerXVelocity]                   ;; 02:5148 $fa $86 $dc
    cpl                                               ;; 02:514b $2f
    inc  A                                            ;; 02:514c $3c
    ld   C, A                                         ;; 02:514d $4f
    ld   B, $ff                                       ;; 02:514e $06 $ff
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:5150 $fa $81 $dc
    and  A, PADF_UP                                   ;; 02:5153 $e6 $40
    call NZ, call_02_53e7_Player_MoveYClampedToMap    ;; 02:5155 $c4 $e7 $53
    ret                                               ;; 02:5158 $c9
.jr_02_5159:
    ld   A, [wDC86_PlayerXVelocity]                   ;; 02:5159 $fa $86 $dc
    ld   HL, wD80D_PlayerFacingDirection              ;; 02:515c $21 $0d $d8
    bit  ENTITY_FACING_LEFT_BIT, [HL]                 ;; 02:515f $cb $6e
    jr   Z, .jr_02_5165                               ;; 02:5161 $28 $02
    cpl                                               ;; 02:5163 $2f
    inc  A                                            ;; 02:5164 $3c
.jr_02_5165:
    ld   HL, wDC85_PlayerXDeltaExtra2                 ;; 02:5165 $21 $85 $dc
    add  A, [HL]                                      ;; 02:5168 $86
    ld   HL, wDC84_PlayerXDeltaExtra                  ;; 02:5169 $21 $84 $dc
    add  A, [HL]                                      ;; 02:516c $86
    ret  Z                                            ;; 02:516d $c8
    push AF                                           ;; 02:516e $f5
    ld   A, [wDABE_CollisionFlags]                    ;; 02:516f $fa $be $da
    and  A, BG_COLLISION_SLOPE_MASK                   ;; 02:5172 $e6 $0f
    jr   Z, .jr_02_517e                               ;; 02:5174 $28 $08
    cpl                                               ;; 02:5176 $2f
    inc  A                                            ;; 02:5177 $3c
    ld   C, A                                         ;; 02:5178 $4f
    ld   B, $ff                                       ;; 02:5179 $06 $ff
    call call_02_53e7_Player_MoveYClampedToMap        ;; 02:517b $cd $e7 $53
.jr_02_517e:
    pop  AF                                           ;; 02:517e $f1
    ld   C, A                                         ;; 02:517f $4f
    bit  7, A                                         ;; 02:5180 $cb $7f
    jr   Z, call_02_51f9_Player_MoveRight             ;; 02:5182 $28 $75
    cpl                                               ;; 02:5184 $2f
    inc  A                                            ;; 02:5185 $3c
    ld   C, A                                         ;; 02:5186 $4f
    jp   call_02_518a_Player_MoveLeft                 ;; 02:5187 $c3 $8a $51

call_02_518a_Player_MoveLeft:
; Move Gex C pixels left. The entry point that decides HOW: if
; wDC7C_PlayerCollisionUnusedFlag names an entity he is up against, the move is
; resolved against that entity; if he is pushing a moving platform the move is
; refused outright; otherwise it falls through to the plain map-clamped version
; below
    ld   A, [wDC7C_PlayerCollisionUnusedFlag]         ;; 02:518a $fa $7c $dc
    and  A, A                                         ;; 02:518d $a7
    jr   NZ, call_02_51cb_Player_MoveLeftAgainstEntity ;; 02:518e $20 $3b
    ld   A, [wDC7D_Player_PushedMovingPlatformLo]     ;; 02:5190 $fa $7d $dc
    and  A, A                                         ;; 02:5193 $a7
    ret  NZ                                           ;; 02:5194 $c0

call_02_5195_Player_MoveLeftClampedToMap:
; Move left, stopping at the map's left boundary
; (wDC3C_PlayerBoundaryXMinLo).
;
; Hitting it records MAP_EDGE_LEFT in wDC8A_MapEdgeTouched rather than just
; stopping, because in gex3 the edge of a map is usually the way into the next one -
; call_00_150f_Map_CheckEdgeTransition picks that up later in the frame.
;
; The last few instructions are the wrap case: on a map whose
; wDC2A_MapBoundaryIndex is MAP_WRAP_BOUNDARY_INDEX there is no left edge, so the
; clamped value is thrown away and the raw position is stored with its high byte
; masked to $0F - which is the wrap itself, done with an AND
    ld   HL, wDC3C_PlayerBoundaryXMinLo            ;; 02:5195 $21 $3c $dc
    ld   A, [HL+]                                     ;; 02:5198 $2a
    ld   D, [HL]                                      ;; 02:5199 $56
    ld   E, A                                         ;; 02:519a $5f
    ld   HL, wD80E_PlayerXPosition                    ;; 02:519b $21 $0e $d8
    ld   A, [HL+]                                     ;; 02:519e $2a
    sub  A, C                                         ;; 02:519f $91
    ld   C, A                                         ;; 02:51a0 $4f
    ld   A, [HL]                                      ;; 02:51a1 $7e
    sbc  A, $00                                       ;; 02:51a2 $de $00
    ld   B, A                                         ;; 02:51a4 $47
    jr   C, .jr_02_51b6                               ;; 02:51a5 $38 $0f
    ld   A, E                                         ;; 02:51a7 $7b
    sub  A, C                                         ;; 02:51a8 $91
    ld   A, D                                         ;; 02:51a9 $7a
    sbc  A, B                                         ;; 02:51aa $98
    jr   C, .jr_02_51b4                               ;; 02:51ab $38 $07
    ld   A, MAP_EDGE_LEFT                             ;; 02:51ad $3e $02
    ld   [wDC8A_MapEdgeTouched], A                    ;; 02:51af $ea $8a $dc
    jr   .jr_02_51b6                                  ;; 02:51b2 $18 $02
.jr_02_51b4:
    ld   E, C                                         ;; 02:51b4 $59
    ld   D, B                                         ;; 02:51b5 $50
.jr_02_51b6:
    ld   HL, wD80E_PlayerXPosition                    ;; 02:51b6 $21 $0e $d8
    ld   A, [wDC2A_MapBoundaryIndex]                  ;; 02:51b9 $fa $2a $dc
    cp   A, MAP_WRAP_BOUNDARY_INDEX                   ;; 02:51bc $fe $00
    jr   Z, .jr_02_51c4                               ;; 02:51be $28 $04
    ld   A, E                                         ;; 02:51c0 $7b
    ld   [HL+], A                                     ;; 02:51c1 $22
    ld   [HL], D                                      ;; 02:51c2 $72
    ret                                               ;; 02:51c3 $c9
.jr_02_51c4:
    ld   A, C                                         ;; 02:51c4 $79
    ld   [HL+], A                                     ;; 02:51c5 $22
    ld   A, B                                         ;; 02:51c6 $78
    and  A, MAP_WRAP_XPOS_MASK                        ;; 02:51c7 $e6 $0f
    ld   [HL], A                                      ;; 02:51c9 $77
    ret                                               ;; 02:51ca $c9

call_02_51cb_Player_MoveLeftAgainstEntity:
; Move left while standing against an entity, so that the entity's own position is
; kept up to date with his.
;
; A comes in holding the entity's slot base. If the slot's
; ENTITY_FIELD_COLLISION_TYPE carries COLLISION_TYPE_FLAG_IMMOVABLE the entity does
; not take part and the move is dropped - which is every platform in the game, so
; the rest of this routine is dead in practice. Otherwise the ordinary clamped move runs, and afterwards the gap
; between Gex and the entity is measured and written back into the entity's
; ENTITY_FIELD_X_VELOCITY pair - which is how a pushed block keeps its distance instead of
; drifting into him.
;
; The `xor $1c` walks L from ENTITY_FIELD_X_VELOCITY ($12 after the two decrements) to
; ENTITY_FIELD_WORLD_X ($0E)
    or   A, ENTITY_FIELD_COLLISION_TYPE               ;; 02:51cb $f6 $14
    ld   L, A                                         ;; 02:51cd $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:51ce $26 $d8
    bit  7, [HL]                                      ;; 02:51d0 $cb $7e
    ret  NZ                                           ;; 02:51d2 $c0
    dec  L                                            ;; 02:51d3 $2d
    dec  L                                            ;; 02:51d4 $2d
    ld   E, [HL]                                      ;; 02:51d5 $5e
    ld   A, L                                         ;; 02:51d6 $7d
    xor  A, $1c                                       ;; 02:51d7 $ee $1c
    ld   L, A                                         ;; 02:51d9 $6f
    ld   A, [wD80E_PlayerXPosition]                   ;; 02:51da $fa $0e $d8
    sub  A, [HL]                                      ;; 02:51dd $96
    inc  HL                                           ;; 02:51de $23
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 02:51df $fa $0f $d8
    sbc  A, [HL]                                      ;; 02:51e2 $9e
    jr   C, call_02_5195_Player_MoveLeftClampedToMap  ;; 02:51e3 $38 $b0
    push HL                                           ;; 02:51e5 $e5
    push DE                                           ;; 02:51e6 $d5
    call call_02_5195_Player_MoveLeftClampedToMap     ;; 02:51e7 $cd $95 $51
    pop  DE                                           ;; 02:51ea $d1
    pop  HL                                           ;; 02:51eb $e1
    dec  L                                            ;; 02:51ec $2d
    ld   A, [wD80E_PlayerXPosition]                   ;; 02:51ed $fa $0e $d8
    sub  A, E                                         ;; 02:51f0 $93
    ld   [HL+], A                                     ;; 02:51f1 $22
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 02:51f2 $fa $0f $d8
    sbc  A, $00                                       ;; 02:51f5 $de $00
    ld   [HL], A                                      ;; 02:51f7 $77
    ret                                               ;; 02:51f8 $c9

call_02_51f9_Player_MoveRight:
; The mirror of call_02_518a_Player_MoveLeft
    ld   A, [wDC7C_PlayerCollisionUnusedFlag]         ;; 02:51f9 $fa $7c $dc
    and  A, A                                         ;; 02:51fc $a7
    jr   NZ, call_02_5238_Player_MoveRightAgainstEntity ;; 02:51fd $20 $39
    ld   A, [wDC7D_Player_PushedMovingPlatformLo]     ;; 02:51ff $fa $7d $dc
    and  A, A                                         ;; 02:5202 $a7
    ret  NZ                                           ;; 02:5203 $c0

call_02_5204_Player_MoveRightClampedToMap:
; The mirror of call_02_5195_Player_MoveLeftClampedToMap, against
; wDC3E_PlayerBoundaryXMaxLo and recording MAP_EDGE_RIGHT
    ld   HL, wDC3E_PlayerBoundaryXMaxLo            ;; 02:5204 $21 $3e $dc
    ld   A, [HL+]                                     ;; 02:5207 $2a
    ld   D, [HL]                                      ;; 02:5208 $56
    ld   E, A                                         ;; 02:5209 $5f
    ld   HL, wD80E_PlayerXPosition                    ;; 02:520a $21 $0e $d8
    ld   A, [HL+]                                     ;; 02:520d $2a
    add  A, C                                         ;; 02:520e $81
    ld   C, A                                         ;; 02:520f $4f
    ld   A, [HL]                                      ;; 02:5210 $7e
    adc  A, $00                                       ;; 02:5211 $ce $00
    ld   B, A                                         ;; 02:5213 $47
    ld   A, E                                         ;; 02:5214 $7b
    sub  A, C                                         ;; 02:5215 $91
    ld   A, D                                         ;; 02:5216 $7a
    sbc  A, B                                         ;; 02:5217 $98
    jr   NC, .jr_02_5221                              ;; 02:5218 $30 $07
    ld   A, MAP_EDGE_RIGHT                            ;; 02:521a $3e $03
    ld   [wDC8A_MapEdgeTouched], A                    ;; 02:521c $ea $8a $dc
    jr   .jr_02_5223                                  ;; 02:521f $18 $02
.jr_02_5221:
    ld   E, C                                         ;; 02:5221 $59
    ld   D, B                                         ;; 02:5222 $50
.jr_02_5223:
    ld   HL, wD80E_PlayerXPosition                    ;; 02:5223 $21 $0e $d8
    ld   A, [wDC2A_MapBoundaryIndex]                  ;; 02:5226 $fa $2a $dc
    cp   A, MAP_WRAP_BOUNDARY_INDEX                   ;; 02:5229 $fe $00
    jr   Z, .jr_02_5231                               ;; 02:522b $28 $04
    ld   A, E                                         ;; 02:522d $7b
    ld   [HL+], A                                     ;; 02:522e $22
    ld   [HL], D                                      ;; 02:522f $72
    ret                                               ;; 02:5230 $c9
.jr_02_5231:
    ld   A, C                                         ;; 02:5231 $79
    ld   [HL+], A                                     ;; 02:5232 $22
    ld   A, B                                         ;; 02:5233 $78
    and  A, MAP_WRAP_XPOS_MASK                        ;; 02:5234 $e6 $0f
    ld   [HL], A                                      ;; 02:5236 $77
    ret                                               ;; 02:5237 $c9

call_02_5238_Player_MoveRightAgainstEntity:
; The mirror of call_02_51cb_Player_MoveLeftAgainstEntity, including its
; COLLISION_TYPE_FLAG_IMMOVABLE early out. The one asymmetry is the
; `inc E` on the entity's width - the right-hand gap is measured one pixel wider,
; which is what stops Gex and a block he is pushing rightward from overlapping by a
; pixel
    or   A, ENTITY_FIELD_COLLISION_TYPE               ;; 02:5238 $f6 $14
    ld   L, A                                         ;; 02:523a $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:523b $26 $d8
    bit  7, [HL]                                      ;; 02:523d $cb $7e
    ret  NZ                                           ;; 02:523f $c0
    dec  L                                            ;; 02:5240 $2d
    dec  L                                            ;; 02:5241 $2d
    ld   E, [HL]                                      ;; 02:5242 $5e
    inc  E                                            ;; 02:5243 $1c
    ld   A, L                                         ;; 02:5244 $7d
    xor  A, $1c                                       ;; 02:5245 $ee $1c
    ld   L, A                                         ;; 02:5247 $6f
    ld   A, [wD80E_PlayerXPosition]                   ;; 02:5248 $fa $0e $d8
    sub  A, [HL]                                      ;; 02:524b $96
    inc  HL                                           ;; 02:524c $23
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 02:524d $fa $0f $d8
    sbc  A, [HL]                                      ;; 02:5250 $9e
    jr   NC, call_02_5204_Player_MoveRightClampedToMap ;; 02:5251 $30 $b1
    push HL                                           ;; 02:5253 $e5
    push DE                                           ;; 02:5254 $d5
    call call_02_5204_Player_MoveRightClampedToMap    ;; 02:5255 $cd $04 $52
    pop  DE                                           ;; 02:5258 $d1
    pop  HL                                           ;; 02:5259 $e1
    dec  L                                            ;; 02:525a $2d
    ld   A, [wD80E_PlayerXPosition]                   ;; 02:525b $fa $0e $d8
    add  A, E                                         ;; 02:525e $83
    ld   [HL+], A                                     ;; 02:525f $22
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 02:5260 $fa $0f $d8
    adc  A, $00                                       ;; 02:5263 $ce $00
    ld   [HL], A                                      ;; 02:5265 $77
    ret                                               ;; 02:5266 $c9

call_02_5267_Player_ApplyYVelocity:
; Gravity and landing - the vertical half of the frame, and the routine with the
; most branches in the file.
;
; Y velocity is signed with positive meaning upward, so "still rising" and "falling
; or stopped" are just the sign bit. Swimming and climbing return immediately;
; top-down maps take the entirely separate path at the end.
;
; The falling step itself is the block at $5283: subtract
; PLAYER_GRAVITY_PER_FRAME, clamp at PLAYER_MAX_FALL_VELOCITY, and - only while
; pinned at that clamp - tick wDC8F_FallDistanceCounter, so the counter measures
; time at terminal velocity rather than total airtime. The velocity becomes a pixel
; delta by negating and swapping nibbles, after which bit 3 carries the sign.
;
; Which of the three landing states applies is decided from the two collision-flag
; bytes. Ground under him and a nonzero floor-snap velocity means there is still a
; gap to close, so he keeps falling; ground under him with no gap means he has
; landed; no ground and no ground last frame either means he has just walked off an
; edge, and the fall action is requested before falling resumes.
;
; The landing at $52f8 zeroes the velocity, takes the fall counter and clears it,
; and then reads it back: a death-in-pit action becomes the real death, below
; PLAYER_FALL_SHORT he keeps his footing, below PLAYER_FALL_LONG he lands in idle or
; walk, and at or above it he lands heavily - or in the matching vehicle action on
; the two vehicle maps.
;
; The top-down path is short and does something different: the same gravity step,
; but the delta is accumulated into wDC88_Player_HopYOffset instead of
; moving him, so on a top-down map a jump is a visual hop above a position that
; never actually leaves the ground.
;
; gex2's call_02_4b78_Player_ApplyYVelocity has the same gravity, clamp, fall
; counter and sign trick, and none of the vehicle or top-down branching
    call call_02_5541_Player_GetActionStates          ;; 02:5267 $cd $41 $55
    and  A, PLAYER_STATE_IN_WATER_MASK | PLAYER_STATE_CLIMBING_MASK ;; 02:526a $e6 $a0
    ret  NZ                                           ;; 02:526c $c0
    ld   A, [wDC1F_CurrentBgCollisionType]            ;; 02:526d $fa $1f $dc
    cp   A, BG_COLLISION_TYPE_TOPDOWN                 ;; 02:5270 $fe $01
    jp   Z, .jp_02_5348                               ;; 02:5272 $ca $48 $53
    ld   A, [wDC8C_PlayerYVelocity]                   ;; 02:5275 $fa $8c $dc
    bit  7, A                                         ;; 02:5278 $cb $7f
    jr   NZ, .jr_02_52b3                              ;; 02:527a $20 $37
    and  A, A                                         ;; 02:527c $a7
    jr   Z, .jr_02_52b3                               ;; 02:527d $28 $34
    xor  A, A                                         ;; 02:527f $af
    ld   [wDC8F_FallDistanceCounter], A               ;; 02:5280 $ea $8f $dc
.jp_02_5283:
    ld   A, [wDC8C_PlayerYVelocity]                   ;; 02:5283 $fa $8c $dc
    sub  A, PLAYER_GRAVITY_PER_FRAME                  ;; 02:5286 $d6 $02
    bit  7, A                                         ;; 02:5288 $cb $7f
    jr   Z, .jr_02_529b                               ;; 02:528a $28 $0f
    cp   A, PLAYER_MAX_FALL_VELOCITY                  ;; 02:528c $fe $c0
    jr   NC, .jr_02_529b                              ;; 02:528e $30 $0b
    ld   HL, wDC8F_FallDistanceCounter                ;; 02:5290 $21 $8f $dc
    ld   A, [HL]                                      ;; 02:5293 $7e
    cp   A, $7f                                       ;; 02:5294 $fe $7f
    adc  A, $00                                       ;; 02:5296 $ce $00
    ld   [HL], A                                      ;; 02:5298 $77
    ld   A, PLAYER_MAX_FALL_VELOCITY                  ;; 02:5299 $3e $c0
.jr_02_529b:
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:529b $ea $8c $dc
    cpl                                               ;; 02:529e $2f
    inc  A                                            ;; 02:529f $3c
    swap A                                            ;; 02:52a0 $cb $37
    and  A, PLAYER_YDELTA_MASK                        ;; 02:52a2 $e6 $0f
    ld   C, A                                         ;; 02:52a4 $4f
    ld   B, $00                                       ;; 02:52a5 $06 $00
    bit  3, A                                         ;; 02:52a7 $cb $5f
    jp   Z, call_02_53e7_Player_MoveYClampedToMap     ;; 02:52a9 $ca $e7 $53
    or   A, PLAYER_YDELTA_SIGN_EXTEND                 ;; 02:52ac $f6 $f0
    ld   C, A                                         ;; 02:52ae $4f
    dec  B                                            ;; 02:52af $05
    jp   call_02_53e7_Player_MoveYClampedToMap        ;; 02:52b0 $c3 $e7 $53
.jr_02_52b3:
    ld   A, [wDABE_CollisionFlags]                    ;; 02:52b3 $fa $be $da
    and  A, $80                                       ;; 02:52b6 $e6 $80
    jr   Z, .jr_02_52cf                               ;; 02:52b8 $28 $15
    ld   A, [wDC8D_Player_FloorSnapVelocity]          ;; 02:52ba $fa $8d $dc
    and  A, A                                         ;; 02:52bd $a7
    jr   Z, .jr_02_52f8                               ;; 02:52be $28 $38
    ld   HL, wDABD_CollisionFlagsPrev                 ;; 02:52c0 $21 $bd $da
    bit  7, [HL]                                      ;; 02:52c3 $cb $7e
    jr   NZ, .jr_02_529b                              ;; 02:52c5 $20 $d4
    ld   HL, wDC8C_PlayerYVelocity                    ;; 02:52c7 $21 $8c $dc
    cp   A, [HL]                                      ;; 02:52ca $be
    jr   NC, .jr_02_529b                              ;; 02:52cb $30 $ce
    jr   .jp_02_5283                                  ;; 02:52cd $18 $b4
.jr_02_52cf:
    ld   A, [wDABD_CollisionFlagsPrev]                ;; 02:52cf $fa $bd $da
    and  A, $80                                       ;; 02:52d2 $e6 $80
    jr   NZ, .jr_02_52de                              ;; 02:52d4 $20 $08
    ld   A, [wDC8F_FallDistanceCounter]               ;; 02:52d6 $fa $8f $dc
    cp   A, PLAYER_FALL_LONG                          ;; 02:52d9 $fe $10
    jp   C, .jp_02_5283                               ;; 02:52db $da $83 $52
.jr_02_52de:
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:52de $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                      ;; 02:52e1 $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_FALL            ;; 02:52e3 $3e $28
    jr   Z, .jr_02_52f2                               ;; 02:52e5 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:52e7 $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                    ;; 02:52ea $fe $08
    ld   A, PLAYERACTION_KANGAROO_FALL                ;; 02:52ec $3e $35
    jr   Z, .jr_02_52f2                               ;; 02:52ee $28 $02
    ld   A, PLAYERACTION_FALL                         ;; 02:52f0 $3e $11
.jr_02_52f2:
    call call_02_54f9_Player_RequestAction            ;; 02:52f2 $cd $f9 $54
    jp   .jp_02_5283                                  ;; 02:52f5 $c3 $83 $52
.jr_02_52f8:
    xor  A, A                                         ;; 02:52f8 $af
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:52f9 $ea $8c $dc
    ld   HL, wDC8F_FallDistanceCounter                ;; 02:52fc $21 $8f $dc
    ld   C, [HL]                                      ;; 02:52ff $4e
    ld   [HL], $00                                    ;; 02:5300 $36 $00
    ld   A, [wD801_Player_ActionId]                   ;; 02:5302 $fa $01 $d8
    cp   A, PLAYERACTION_DEATH_IN_PIT_ALT             ;; 02:5305 $fe $1a
    ld   A, PLAYERACTION_DEATH                        ;; 02:5307 $3e $0a
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:5309 $ca $f9 $54
    ld   A, [wD801_Player_ActionId]                   ;; 02:530c $fa $01 $d8
    cp   A, PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT ;; 02:530f $fe $2e
    ld   A, PLAYERACTION_SNOWBOARDING_DIE             ;; 02:5311 $3e $2a
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:5313 $ca $f9 $54
    ld   A, [wD801_Player_ActionId]                   ;; 02:5316 $fa $01 $d8
    cp   A, PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT    ;; 02:5319 $fe $3b
    ld   A, PLAYERACTION_KANGAROO_DEATH               ;; 02:531b $3e $37
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:531d $ca $f9 $54
    ld   A, C                                         ;; 02:5320 $79
    cp   A, PLAYER_FALL_SHORT                         ;; 02:5321 $fe $08
    jr   NC, .jr_02_532a                              ;; 02:5323 $30 $05
    xor  A, A                                         ;; 02:5325 $af
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:5326 $ea $8e $dc
    ret                                               ;; 02:5329 $c9
.jr_02_532a:
    cp   A, PLAYER_FALL_LONG                          ;; 02:532a $fe $10
    jp   C, call_02_4dce_Player_SetLandingAction      ;; 02:532c $da $ce $4d
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:532f $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                      ;; 02:5332 $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_STAND_OR_WALK   ;; 02:5334 $3e $24
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:5336 $ca $f9 $54
    ld   A, [wDB6C_CurrentMapId]                      ;; 02:5339 $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                    ;; 02:533c $fe $08
    ld   A, PLAYERACTION_KANGAROO_IDLE                ;; 02:533e $3e $30
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:5340 $ca $f9 $54
    ld   A, PLAYERACTION_LAND_FROM_FALL               ;; 02:5343 $3e $12
    jp   call_02_54f9_Player_RequestAction            ;; 02:5345 $c3 $f9 $54
.jp_02_5348:
    ld   A, [wDC8C_PlayerYVelocity]                   ;; 02:5348 $fa $8c $dc
    sub  A, PLAYER_GRAVITY_PER_FRAME                  ;; 02:534b $d6 $02
    bit  7, A                                         ;; 02:534d $cb $7f
    jr   Z, .jr_02_5357                               ;; 02:534f $28 $06
    cp   A, PLAYER_MAX_FALL_VELOCITY                  ;; 02:5351 $fe $c0
    jr   NC, .jr_02_5357                              ;; 02:5353 $30 $02
    ld   A, PLAYER_MAX_FALL_VELOCITY                  ;; 02:5355 $3e $c0
.jr_02_5357:
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:5357 $ea $8c $dc
    cpl                                               ;; 02:535a $2f
    inc  A                                            ;; 02:535b $3c
    swap A                                            ;; 02:535c $cb $37
    and  A, PLAYER_YDELTA_MASK                        ;; 02:535e $e6 $0f
    bit  3, A                                         ;; 02:5360 $cb $5f
    jr   Z, .jr_02_5366                               ;; 02:5362 $28 $02
    or   A, PLAYER_YDELTA_SIGN_EXTEND                 ;; 02:5364 $f6 $f0
.jr_02_5366:
    ld   HL, wDC88_Player_HopYOffset    ;; 02:5366 $21 $88 $dc
    add  A, [HL]                                      ;; 02:5369 $86
    bit  7, A                                         ;; 02:536a $cb $7f
    jr   NZ, .jr_02_5372                              ;; 02:536c $20 $04
    xor  A, A                                         ;; 02:536e $af
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:536f $ea $8e $dc
.jr_02_5372:
    ld   [HL], A                                      ;; 02:5372 $77
    ret                                               ;; 02:5373 $c9

call_02_5374_Player_CheckUpdraftTiles:
; The updraft tiles - the vents that blow Gex upwards - and the one place a level
; can gate a tile on progress.
;
; Only tile types TILE_TYPE_UPDRAFT_FIRST to TILE_TYPE_UPDRAFT_LAST count, and the
; tile's position in that run is an index. The current level picks a table out of
; .data_02_53bf_UpdraftTablePerLevel - a null pointer means this level has no
; updrafts - and the indexed entry is a (required count, trigger slot) pair. A
; trigger slot of UPDRAFT_NO_REQUIREMENT means the vent is always on; otherwise
; wDCB1_LevelTriggerBuffer must have reached the required count, which is how a vent
; stays off until the player has thrown enough switches.
;
; When it fires it adds PLAYER_UPDRAFT_ACCEL to Y velocity each frame, capped at
; PLAYER_UPDRAFT_MAX_YVEL, and requests PLAYERACTION_BLOWN_UPWARDS. Skipped
; entirely while he is dead. No gex2 equivalent
    call call_02_5541_Player_GetActionStates          ;; 02:5374 $cd $41 $55
    and  A, PLAYER_STATE_DEAD_MASK                    ;; 02:5377 $e6 $08
    ret  NZ                                           ;; 02:5379 $c0
    ld   A, [wDC93_TileTypeBehindGexsLowerBody]       ;; 02:537a $fa $93 $dc
    cp   A, TILE_TYPE_UPDRAFT_FIRST                   ;; 02:537d $fe $3e
    ret  C                                            ;; 02:537f $d8
    cp   A, TILE_TYPE_UPDRAFT_LAST                    ;; 02:5380 $fe $42
    ret  NC                                           ;; 02:5382 $d0
    sub  A, TILE_TYPE_UPDRAFT_FIRST                   ;; 02:5383 $d6 $3e
    ld   C, A                                         ;; 02:5385 $4f
    ld   HL, wDC1E_CurrentLevelID                     ;; 02:5386 $21 $1e $dc
    ld   L, [HL]                                      ;; 02:5389 $6e
    ld   H, $00                                       ;; 02:538a $26 $00
    add  HL, HL                                       ;; 02:538c $29
    ld   DE, .data_02_53bf_UpdraftTablePerLevel       ;; 02:538d $11 $bf $53
    add  HL, DE                                       ;; 02:5390 $19
    ld   A, [HL+]                                     ;; 02:5391 $2a
    ld   D, [HL]                                      ;; 02:5392 $56
    ld   E, A                                         ;; 02:5393 $5f
    or   A, D                                         ;; 02:5394 $b2
    ret  Z                                            ;; 02:5395 $c8
    ld   L, C                                         ;; 02:5396 $69
    ld   H, $00                                       ;; 02:5397 $26 $00
    add  HL, HL                                       ;; 02:5399 $29
    add  HL, DE                                       ;; 02:539a $19
    ld   C, [HL]                                      ;; 02:539b $4e
    inc  HL                                           ;; 02:539c $23
    ld   A, [HL]                                      ;; 02:539d $7e
    cp   A, UPDRAFT_NO_REQUIREMENT                    ;; 02:539e $fe $ff
    jr   Z, .jr_02_53ac                               ;; 02:53a0 $28 $0a
    ld   L, A                                         ;; 02:53a2 $6f
    ld   H, $00                                       ;; 02:53a3 $26 $00
    ld   DE, wDCB1_LevelTriggerBuffer                 ;; 02:53a5 $11 $b1 $dc
    add  HL, DE                                       ;; 02:53a8 $19
    ld   A, [HL]                                      ;; 02:53a9 $7e
    cp   A, C                                         ;; 02:53aa $b9
    ret  C                                            ;; 02:53ab $d8
.jr_02_53ac:
    ld   A, [wDC8C_PlayerYVelocity]                   ;; 02:53ac $fa $8c $dc
    add  A, PLAYER_UPDRAFT_ACCEL                      ;; 02:53af $c6 $03
    cp   A, PLAYER_UPDRAFT_MAX_YVEL                   ;; 02:53b1 $fe $20
    jr   C, .jr_02_53b7                               ;; 02:53b3 $38 $02
    ld   A, PLAYER_UPDRAFT_MAX_YVEL                   ;; 02:53b5 $3e $20
.jr_02_53b7:
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:53b7 $ea $8c $dc
    ld   A, PLAYERACTION_BLOWN_UPWARDS                ;; 02:53ba $3e $1d
    jp   call_02_54f9_Player_RequestAction            ;; 02:53bc $c3 $f9 $54
.data_02_53bf_UpdraftTablePerLevel:
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 02:53bf ????????
    db   $00, $00, $d7, $53, $df, $53, $00, $00       ;; 02:53c7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 02:53cf ????????
    db   $01, $06, $02, $06, $01, $01, $01, $04       ;; 02:53d7 ????????
    db   $00, $ff, $00, $ff, $00, $ff, $00, $ff       ;; 02:53df ????????

call_02_53e7_Player_MoveYClampedToMap:
; Add the signed 16-bit BC to Gex's Y, stopping at the map's top and bottom
; boundaries and recording which one he hit.
;
; PLAYERACTION_DEATH_IN_PIT is exempt - falling out of the bottom of the world is
; the point of it, so the clamp would defeat it.
;
; Otherwise the sign of the result picks which end to test: negative means he has
; gone off the top and is clamped to wDC40_PlayerBoundaryYMinLo with
; MAP_EDGE_TOP recorded, and past the bottom bound clamps to
; wDC42_PlayerBoundaryYMaxLo with MAP_EDGE_BOTTOM. As with the horizontal
; clamps, the record in wDC8A_MapEdgeTouched is what lets
; call_00_150f_Map_CheckEdgeTransition treat the edge as a way into the next map
    ld   HL, wD810_PlayerYPosition                    ;; 02:53e7 $21 $10 $d8
    ld   A, [HL]                                      ;; 02:53ea $7e
    add  A, C                                         ;; 02:53eb $81
    ld   [HL+], A                                     ;; 02:53ec $22
    ld   C, A                                         ;; 02:53ed $4f
    ld   A, [HL]                                      ;; 02:53ee $7e
    adc  A, B                                         ;; 02:53ef $88
    ld   [HL], A                                      ;; 02:53f0 $77
    ld   B, A                                         ;; 02:53f1 $47
    ld   A, [wD801_Player_ActionId]                   ;; 02:53f2 $fa $01 $d8
    cp   A, PLAYERACTION_DEATH_IN_PIT                 ;; 02:53f5 $fe $1b
    ret  Z                                            ;; 02:53f7 $c8
    bit  7, B                                         ;; 02:53f8 $cb $78
    jr   NZ, .jr_02_541f                              ;; 02:53fa $20 $23
    ld   HL, wDC40_PlayerBoundaryYMinLo            ;; 02:53fc $21 $40 $dc
    ld   A, C                                         ;; 02:53ff $79
    sub  A, [HL]                                      ;; 02:5400 $96
    inc  HL                                           ;; 02:5401 $23
    ld   A, B                                         ;; 02:5402 $78
    sbc  A, [HL]                                      ;; 02:5403 $9e
    jr   C, .jr_02_541f                               ;; 02:5404 $38 $19
    inc  HL                                           ;; 02:5406 $23
    ld   A, C                                         ;; 02:5407 $79
    sub  A, [HL]                                      ;; 02:5408 $96
    inc  HL                                           ;; 02:5409 $23
    ld   A, B                                         ;; 02:540a $78
    sbc  A, [HL]                                      ;; 02:540b $9e
    ret  C                                            ;; 02:540c $d8
    ld   A, [wDC42_PlayerBoundaryYMaxLo]           ;; 02:540d $fa $42 $dc
    ld   [wD810_PlayerYPosition], A                   ;; 02:5410 $ea $10 $d8
    ld   A, [wDC43_PlayerBoundaryYMaxHi]            ;; 02:5413 $fa $43 $dc
    ld   [wD810_PlayerYPosition+1], A                 ;; 02:5416 $ea $11 $d8
    ld   A, MAP_EDGE_BOTTOM                           ;; 02:5419 $3e $01
    ld   [wDC8A_MapEdgeTouched], A                    ;; 02:541b $ea $8a $dc
    ret                                               ;; 02:541e $c9
.jr_02_541f:
    ld   A, [wDC40_PlayerBoundaryYMinLo]           ;; 02:541f $fa $40 $dc
    ld   [wD810_PlayerYPosition], A                   ;; 02:5422 $ea $10 $d8
    ld   A, [wDC41_PlayerBoundaryYMinHi]           ;; 02:5425 $fa $41 $dc
    ld   [wD810_PlayerYPosition+1], A                 ;; 02:5428 $ea $11 $d8
    ld   A, MAP_EDGE_TOP                              ;; 02:542b $3e $00
    ld   [wDC8A_MapEdgeTouched], A                    ;; 02:542d $ea $8a $dc
    ret                                               ;; 02:5430 $c9

call_02_5431_Player_CheckTileInteractions:
; The bridge between the world and the action machine, and where nearly every action
; change starts. Four passes, in order.
;
; 1. Instant death. Skipped for an action flagged PLAYER_STATE_DEAD, and the pit
;    check alone is skipped for one flagged PLAYER_STATE_UNK10 - which no action
;    in the table actually is, so that branch never runs. Otherwise
;    tile type $28 under either body probe jumps to Player_DieInPit and $19 under
;    the lower one to Player_HitHazardTile.
;
; 2. The updraft tiles, through call_02_5374_Player_CheckUpdraftTiles.
;
; 3. Water. Tile type $36 at head height with UP held puts him into
;    PLAYERACTION_WATER_TREADING - from swimming, from the double jump on the way
;    down, or from any non-water action. This is the surface-break, which is why it
;    is a separate test from the in-water state that
;    call_02_553b_Player_IsInWater answers.
;
; 4. Climbing, then the input transition table. UP against a
;    TILE_TYPE_CLIMBABLE tile starts a climb with both velocities zeroed; failing
;    that, the current action's input list from
;    data_02_55c5_ActionInputTransitionTable is scanned against
;    wDC81_Player_EffectiveInputs masked to ACTION_INPUT_MASK. A null list means
;    the action ignores input, ACTION_INPUT_ANY matches any nonzero input, and
;    ACTION_INPUT_END terminates. The first match falls straight into
;    call_02_54f9_Player_RequestAction with the action id that follows it.
;
; gex2's call_02_4c4f_Player_CheckTileInteractions is the same three-pass shape
; without the water and updraft passes
    ld   HL, wD801_Player_ActionId                    ;; 02:5431 $21 $01 $d8
    ld   L, [HL]                                      ;; 02:5434 $6e
    ld   H, $00                                       ;; 02:5435 $26 $00
    ld   DE, data_02_554d_PlayerStatesPerAction       ;; 02:5437 $11 $4d $55
    add  HL, DE                                       ;; 02:543a $19
    bit  PLAYER_STATE_DEAD, [HL]                      ;; 02:543b $cb $5e
    jr   NZ, .jr_02_545b                              ;; 02:543d $20 $1c
    bit  PLAYER_STATE_UNK10, [HL]                     ;; 02:543f $cb $66
    jr   NZ, .jr_02_5453                              ;; 02:5441 $20 $10
    ld   A, [wDC92_TileTypeBehindGexsUpperBody]       ;; 02:5443 $fa $92 $dc
    cp   A, TILE_TYPE_INSTANT_KILL                    ;; 02:5446 $fe $28
    jp   Z, jp_00_06da_Player_DieInPit                ;; 02:5448 $ca $da $06
    ld   A, [wDC93_TileTypeBehindGexsLowerBody]       ;; 02:544b $fa $93 $dc
    cp   A, TILE_TYPE_INSTANT_KILL                    ;; 02:544e $fe $28
    jp   Z, jp_00_06da_Player_DieInPit                ;; 02:5450 $ca $da $06
.jr_02_5453:
    ld   A, [wDC93_TileTypeBehindGexsLowerBody]       ;; 02:5453 $fa $93 $dc
    cp   A, TILE_TYPE_HAZARD                          ;; 02:5456 $fe $19
    jp   Z, jp_00_06e8_Player_HitHazardTile           ;; 02:5458 $ca $e8 $06
.jr_02_545b:
    call call_02_5374_Player_CheckUpdraftTiles        ;; 02:545b $cd $74 $53
    call call_02_553b_Player_IsInWater                ;; 02:545e $cd $3b $55
    jr   Z, .jr_02_5488                               ;; 02:5461 $28 $25
    ld   A, [wD801_Player_ActionId]                   ;; 02:5463 $fa $01 $d8
    cp   A, PLAYERACTION_WATER_SWIMMING               ;; 02:5466 $fe $19
    jr   Z, .jr_02_546e                               ;; 02:5468 $28 $04
    cp   A, $1f                                       ;; 02:546a $fe $1f
    jr   NZ, .jr_02_54a7                              ;; 02:546c $20 $39
.jr_02_546e:
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:546e $fa $81 $dc
    and  A, PADF_UP                                   ;; 02:5471 $e6 $40
    jr   Z, .jr_02_54a7                               ;; 02:5473 $28 $32
    ld   A, [wDC92_TileTypeBehindGexsUpperBody]       ;; 02:5475 $fa $92 $dc
    cp   A, TILE_TYPE_WATER_SURFACE                   ;; 02:5478 $fe $36
    jr   NZ, .jr_02_54a7                              ;; 02:547a $20 $2b
    ld   A, $04                                       ;; 02:547c $3e $04
    ld   [wDC9D_Player_SwimmingRelated], A            ;; 02:547e $ea $9d $dc
    ld   A, PLAYERACTION_WATER_TREADING               ;; 02:5481 $3e $20
    call call_02_54f9_Player_RequestAction            ;; 02:5483 $cd $f9 $54
    jr   .jr_02_54a7                                  ;; 02:5486 $18 $1f
.jr_02_5488:
    ld   A, [wD801_Player_ActionId]                   ;; 02:5488 $fa $01 $d8
    cp   A, PLAYERACTION_DOUBLE_JUMP                  ;; 02:548b $fe $0f
    jr   NZ, .jr_02_5496                              ;; 02:548d $20 $07
    ld   A, [wDC8C_PlayerYVelocity]                   ;; 02:548f $fa $8c $dc
    bit  7, A                                         ;; 02:5492 $cb $7f
    jr   Z, .jr_02_54a7                               ;; 02:5494 $28 $11
.jr_02_5496:
    ld   A, [wDC92_TileTypeBehindGexsUpperBody]       ;; 02:5496 $fa $92 $dc
    cp   A, TILE_TYPE_WATER_SURFACE                   ;; 02:5499 $fe $36
    jr   NZ, .jr_02_54a7                              ;; 02:549b $20 $0a
    ld   A, $04                                       ;; 02:549d $3e $04
    ld   [wDC9D_Player_SwimmingRelated], A            ;; 02:549f $ea $9d $dc
    ld   A, PLAYERACTION_WATER_TREADING               ;; 02:54a2 $3e $20
    call call_02_54f9_Player_RequestAction            ;; 02:54a4 $cd $f9 $54
.jr_02_54a7:
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:54a7 $fa $81 $dc
    and  A, PADF_UP                                   ;; 02:54aa $e6 $40
    jr   Z, .jr_02_54d0                               ;; 02:54ac $28 $22
    ld   A, [wD801_Player_ActionId]                   ;; 02:54ae $fa $01 $d8
    cp   A, PLAYERACTION_CLIMBING                     ;; 02:54b1 $fe $22
    jr   Z, .jr_02_54d0                               ;; 02:54b3 $28 $1b
    farcall call_03_4c2e_BgCollision_IsTileClimbable
    jr   NZ, .jr_02_54d0                              ;; 02:54c0 $20 $0e
    xor  A, A                                         ;; 02:54c2 $af
    ld   [wDCA1_Player_ClimbingRelated4], A           ;; 02:54c3 $ea $a1 $dc
    ld   [wDC86_PlayerXVelocity], A                   ;; 02:54c6 $ea $86 $dc
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:54c9 $ea $8c $dc
    ld   A, PLAYERACTION_CLIMBING                     ;; 02:54cc $3e $22
    jr   call_02_54f9_Player_RequestAction            ;; 02:54ce $18 $29
.jr_02_54d0:
    ld   HL, wD801_Player_ActionId                    ;; 02:54d0 $21 $01 $d8
    ld   L, [HL]                                      ;; 02:54d3 $6e
    ld   H, $00                                       ;; 02:54d4 $26 $00
    add  HL, HL                                       ;; 02:54d6 $29
    ld   DE, data_02_55c5_ActionInputTransitionTable  ;; 02:54d7 $11 $c5 $55
    add  HL, DE                                       ;; 02:54da $19
    ld   A, [HL+]                                     ;; 02:54db $2a
    ld   H, [HL]                                      ;; 02:54dc $66
    ld   L, A                                         ;; 02:54dd $6f
    or   A, H                                         ;; 02:54de $b4
    ret  Z                                            ;; 02:54df $c8
    ld   A, [wDC81_Player_EffectiveInputs]            ;; 02:54e0 $fa $81 $dc
    and  A, ACTION_INPUT_MASK                         ;; 02:54e3 $e6 $f3
    ld   C, A                                         ;; 02:54e5 $4f
.jr_02_54e6:
    ld   A, [HL+]                                     ;; 02:54e6 $2a
    cp   A, ACTION_INPUT_END                          ;; 02:54e7 $fe $ff
    ret  Z                                            ;; 02:54e9 $c8
    cp   A, ACTION_INPUT_ANY                          ;; 02:54ea $fe $fe
    jr   NZ, .jr_02_54f2                              ;; 02:54ec $20 $04
    inc  C                                            ;; 02:54ee $0c
    dec  C                                            ;; 02:54ef $0d
    jr   NZ, .jr_02_54f8                              ;; 02:54f0 $20 $06
.jr_02_54f2:
    cp   A, C                                         ;; 02:54f2 $b9
    jr   Z, .jr_02_54f8                               ;; 02:54f3 $28 $03
    inc  HL                                           ;; 02:54f5 $23
    jr   .jr_02_54e6                                  ;; 02:54f6 $18 $ee
.jr_02_54f8:
    ld   A, [HL+]                                     ;; 02:54f8 $2a

call_02_54f9_Player_RequestAction:
; The only way anything changes Gex's action. The id goes in A.
;
; First the top-down fixup: on a BG_COLLISION_TYPE_TOPDOWN map every action below
; PLAYERACTION_TOPDOWN is shifted up by that offset, so a caller asks for
; "walk" and gets the top-down walk without knowing there are two. Actions already
; at or above the offset are passed through unchanged.
;
; Requesting the action that is already running is a no-op, which is what lets the
; per-frame actions call this unconditionally with their own id as a fallback.
;
; Then the permission check against data_02_554d_PlayerStatesPerAction. An action
; flagged PLAYER_STATE_ACTION_INSTANT is written through no matter what. Anything
; else has to get past whatever is already queued: the flags of the queued action
; are looked up - or of the current action if nothing is queued - and if that one is
; PLAYER_STATE_ACTION_LOCKED the request is silently dropped.
;
; A request that survives is parked in wDC79_Player_QueuedAction, not applied;
; call_02_4f32_Player_UpdateMain commits it at the top of the next frame. It also
; clears the attacking flag and the climb state, so any action change cancels a
; tail spin and a climb.
;
; gex2's call_02_4ccd_Player_RequestAction, with the same queue and the same
; instant/locked pair
    ld   L, A                                         ;; 02:54f9 $6f
    cp   A, PLAYERACTION_TOPDOWN                      ;; 02:54fa $fe $3c
    jr   NC, .jr_02_5509                              ;; 02:54fc $30 $0b
    ld   A, [wDC1F_CurrentBgCollisionType]            ;; 02:54fe $fa $1f $dc
    cp   A, BG_COLLISION_TYPE_TOPDOWN                 ;; 02:5501 $fe $01
    jr   NZ, .jr_02_5509                              ;; 02:5503 $20 $04
    ld   A, L                                         ;; 02:5505 $7d
    add  A, PLAYERACTION_TOPDOWN                      ;; 02:5506 $c6 $3c
    ld   L, A                                         ;; 02:5508 $6f
.jr_02_5509:
    ld   A, L                                         ;; 02:5509 $7d
    ld   HL, wD801_Player_ActionId                    ;; 02:550a $21 $01 $d8
    cp   A, [HL]                                      ;; 02:550d $be
    ret  Z                                            ;; 02:550e $c8
    ld   L, A                                         ;; 02:550f $6f
    ld   H, $00                                       ;; 02:5510 $26 $00
    ld   DE, data_02_554d_PlayerStatesPerAction       ;; 02:5512 $11 $4d $55
    add  HL, DE                                       ;; 02:5515 $19
    bit  PLAYER_STATE_ACTION_INSTANT, [HL]            ;; 02:5516 $cb $46
    jr   NZ, .jr_02_552e                              ;; 02:5518 $20 $14
    ld   HL, wDC79_Player_QueuedAction                ;; 02:551a $21 $79 $dc
    bit  7, [HL]                                      ;; 02:551d $cb $7e
    jr   Z, .jr_02_5524                               ;; 02:551f $28 $03
    ld   HL, wD801_Player_ActionId                    ;; 02:5521 $21 $01 $d8
.jr_02_5524:
    ld   L, [HL]                                      ;; 02:5524 $6e
    ld   H, $00                                       ;; 02:5525 $26 $00
    ld   DE, data_02_554d_PlayerStatesPerAction       ;; 02:5527 $11 $4d $55
    add  HL, DE                                       ;; 02:552a $19
    bit  PLAYER_STATE_ACTION_LOCKED, [HL]             ;; 02:552b $cb $4e
    ret  NZ                                           ;; 02:552d $c0
.jr_02_552e:
    ld   [wDC79_Player_QueuedAction], A               ;; 02:552e $ea $79 $dc
    xor  A, A                                         ;; 02:5531 $af
    ld   [wDC7F_Player_IsAttacking], A                ;; 02:5532 $ea $7f $dc
    ld   A, $00                                       ;; 02:5535 $3e $00
    ld   [wDC7A_PlayerClimbingOrSwimmingRelated], A   ;; 02:5537 $ea $7a $dc
    ret                                               ;; 02:553a $c9

call_02_553b_Player_IsInWater:
; NZ when the action Gex is in is a water action. Reads
; PLAYER_STATE_IN_WATER_MASK off the current action's entry rather than a flag, so
; it cannot go stale
    call call_02_5541_Player_GetActionStates          ;; 02:553b $cd $41 $55
    and  A, PLAYER_STATE_IN_WATER_MASK                ;; 02:553e $e6 $20
    ret                                               ;; 02:5540 $c9

call_02_5541_Player_GetActionStates:
; A = the PLAYER_STATE_* byte for Gex's current action, out of
; data_02_554d_PlayerStatesPerAction. Six routines in this file start with this
; call
    ld   HL, wD801_Player_ActionId                    ;; 02:5541 $21 $01 $d8
    ld   L, [HL]                                      ;; 02:5544 $6e
    ld   H, $00                                       ;; 02:5545 $26 $00
    ld   DE, data_02_554d_PlayerStatesPerAction       ;; 02:5547 $11 $4d $55
    add  HL, DE                                       ;; 02:554a $19
    ld   A, [HL]                                      ;; 02:554b $7e
    ret                                               ;; 02:554c $c9

data_02_554d_PlayerStatesPerAction:
; One PLAYER_STATE_* byte per player action id: both what the action is - dead, in
; water, climbing - and what the action machine is allowed to do to it.
;
; gex2 keeps the two transition bits in a table of their own,
; .data_02_4cf5_ActionTransitionFlagsTable, and the state bits elsewhere; gex3
; merged them into this one table. The pattern to read for is that the death, warp
; and tv actions carry ACTION_INSTANT and ACTION_LOCKED together, which is what
; makes them uninterruptible once entered
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SPAWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_IDLE
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_IDLE_ANIMATION
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_WALK
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_START_CROUCH
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_CROUCH_LOOK_DOWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_NONE_0
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_UNK7
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_EAT_FLY
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_TAKE_DAMAGE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH_SET_UP_WARP
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_STAND_ON_TV_BUTTON
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_ENTER_TV
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_DOUBLE_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_TAIL_SPIN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_FALL
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_LAND_FROM_FALL
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_UNK19
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_ENTER_IDLE
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_1
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_2
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_3
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_4
    db   PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_SWIMMING
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH_IN_PIT_ALT
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH_IN_PIT
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_NONE_5
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_BLOWN_UPWARDS
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_RIDING_ELEVATOR
    db   PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_TAIL_SPIN
    db   PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_TREADING
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_DIVING
    db   PLAYER_STATE_CLIMBING_MASK ; PLAYERACTION_CLIMBING
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_SPAWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_FALL
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_SNOWBOARDING_DIE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_SNOWBOARDING_DIE_WARP
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_SNOWBOARDING_ENTER_TV
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_SPAWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_IDLE
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_HOPPING
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_START_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_TAIL_SPIN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_FALL
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_KANGAROO_TAKE_DAMAGE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_KANGAROO_DEATH
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_KANGAROO_ENTER_TV
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SPAWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_IDLE
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_IDLE_ANIMATION
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_WALK
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_START_CROUCH
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_CROUCH_LOOK_DOWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_NONE_0
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_UNK7
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_EAT_FLY
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_TAKE_DAMAGE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH_SET_UP_WARP
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_STAND_ON_TV_BUTTON
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_ENTER_TV
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_DOUBLE_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_TAIL_SPIN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_FALL
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_LAND_FROM_FALL
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_UNK19
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_ENTER_IDLE
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_1
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_2
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_3
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_NONE_4
    db   PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_SWIMMING
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH_IN_PIT_ALT
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_DEATH_IN_PIT
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_NONE_5
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_BLOWN_UPWARDS
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_RIDING_ELEVATOR
    db   PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_TAIL_SPIN
    db   PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_TREADING
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_IN_WATER_MASK ; PLAYERACTION_WATER_DIVING
    db   PLAYER_STATE_CLIMBING_MASK ; PLAYERACTION_CLIMBING
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_SPAWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_SNOWBOARDING_FALL
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_SNOWBOARDING_DIE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_SNOWBOARDING_DIE_WARP
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_SNOWBOARDING_ENTER_TV
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_SPAWN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_IDLE
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_HOPPING
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_START_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_JUMP
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_TAIL_SPIN
    db   PLAYER_STATE_NONE_MASK ; PLAYERACTION_KANGAROO_FALL
    db   PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_KANGAROO_TAKE_DAMAGE
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_KANGAROO_DEATH
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK ; PLAYERACTION_KANGAROO_ENTER_TV
    db   PLAYER_STATE_ACTION_INSTANT_MASK | PLAYER_STATE_ACTION_LOCKED_MASK | PLAYER_STATE_NO_INPUT_CONTROL_MASK | PLAYER_STATE_DEAD_MASK ; PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT

data_02_55c5_ActionInputTransitionTable:
; Gex's control scheme, as data. One pointer per action id; each list is pairs of
; (input byte, action id) ending in ACTION_INPUT_END, scanned by
; call_02_5431_Player_CheckTileInteractions against the filtered pad in
; wDC81_Player_EffectiveInputs.
;
; The match is on the whole input byte, not on individual bits, which is why every
; direction combination is spelled out separately - right plus B and left plus B are
; two entries even though both mean "jump". ACTION_INPUT_ANY matches any nonzero
; input, and an input of $00 matches only an empty d-pad, which is how an action
; notices the player letting go.
;
; A null pointer means the action ignores input entirely. That - and nothing else -
; is what makes the death, damage and tv actions uninterruptible.
;
; gex2's data_02_4d15_ActionInputTransitionTable, same format down to the sentinels
    dw   .data_02_56b5 ; PLAYERACTION_SPAWN
    dw   .data_02_56b8 ; PLAYERACTION_IDLE
    dw   .data_02_56b8 ; PLAYERACTION_IDLE_ANIMATION
    dw   .data_02_56eb ; PLAYERACTION_WALK
    dw   .data_02_5712 ; PLAYERACTION_START_CROUCH
    dw   .data_02_5715 ; PLAYERACTION_CROUCH_LOOK_DOWN
    dw   $0000 ; PLAYERACTION_NONE_0
    dw   $0000 ; PLAYERACTION_UNK7
    dw   $0000 ; PLAYERACTION_EAT_FLY
    dw   $0000 ; PLAYERACTION_TAKE_DAMAGE
    dw   $0000 ; PLAYERACTION_DEATH
    dw   $0000 ; PLAYERACTION_DEATH_SET_UP_WARP
    dw   $0000 ; PLAYERACTION_STAND_ON_TV_BUTTON
    dw   $0000 ; PLAYERACTION_ENTER_TV
    dw   .data_02_5744 ; PLAYERACTION_JUMP
    dw   .data_02_5744 ; PLAYERACTION_DOUBLE_JUMP
    dw   $0000 ; PLAYERACTION_TAIL_SPIN
    dw   $0000 ; PLAYERACTION_FALL
    dw   $0000 ; PLAYERACTION_LAND_FROM_FALL
    dw   $0000 ; PLAYERACTION_UNK19
    dw   $0000 ; PLAYERACTION_ENTER_IDLE
    dw   $0000 ; PLAYERACTION_NONE_1
    dw   $0000 ; PLAYERACTION_NONE_2
    dw   $0000 ; PLAYERACTION_NONE_3
    dw   $0000 ; PLAYERACTION_NONE_4
    dw   .data_02_5757 ; PLAYERACTION_WATER_SWIMMING
    dw   $0000 ; PLAYERACTION_DEATH_IN_PIT_ALT
    dw   $0000 ; PLAYERACTION_DEATH_IN_PIT
    dw   $0000 ; PLAYERACTION_NONE_5
    dw   $0000 ; PLAYERACTION_BLOWN_UPWARDS
    dw   $0000 ; PLAYERACTION_RIDING_ELEVATOR
    dw   $0000 ; PLAYERACTION_WATER_TAIL_SPIN
    dw   .data_02_576a ; PLAYERACTION_WATER_TREADING
    dw   $0000 ; PLAYERACTION_WATER_DIVING
    dw   $0000 ; PLAYERACTION_CLIMBING
    dw   .data_02_578f ; PLAYERACTION_SNOWBOARDING_SPAWN
    dw   .data_02_5792 ; PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    dw   .data_02_57b7 ; PLAYERACTION_SNOWBOARDING_JUMP
    dw   .data_02_57b7 ; PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_FALL
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_DIE
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_DIE_WARP
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_ENTER_TV
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    dw   .data_02_5779 ; PLAYERACTION_KANGAROO_SPAWN
    dw   $0000 ; PLAYERACTION_KANGAROO_IDLE
    dw   .data_02_577c ; PLAYERACTION_KANGAROO_HOPPING
    dw   $0000 ; PLAYERACTION_KANGAROO_START_JUMP
    dw   .data_02_577c ; PLAYERACTION_KANGAROO_JUMP
    dw   $0000 ; PLAYERACTION_KANGAROO_TAIL_SPIN
    dw   $0000 ; PLAYERACTION_KANGAROO_FALL
    dw   $0000 ; PLAYERACTION_KANGAROO_TAKE_DAMAGE
    dw   $0000 ; PLAYERACTION_KANGAROO_DEATH
    dw   $0000 ; PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    dw   $0000 ; PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON
    dw   $0000 ; PLAYERACTION_KANGAROO_ENTER_TV
    dw   $0000 ; PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT
    dw   .data_02_57ca ; PLAYERACTION_SPAWN
    dw   .data_02_57cd ; PLAYERACTION_IDLE
    dw   .data_02_57cd ; PLAYERACTION_IDLE_ANIMATION
    dw   .data_02_57f2 ; PLAYERACTION_WALK
    dw   $0000 ; PLAYERACTION_START_CROUCH
    dw   $0000 ; PLAYERACTION_CROUCH_LOOK_DOWN
    dw   $0000 ; PLAYERACTION_NONE_0
    dw   $0000 ; PLAYERACTION_UNK7
    dw   $0000 ; PLAYERACTION_EAT_FLY
    dw   $0000 ; PLAYERACTION_TAKE_DAMAGE
    dw   $0000 ; PLAYERACTION_DEATH
    dw   $0000 ; PLAYERACTION_DEATH_SET_UP_WARP
    dw   $0000 ; PLAYERACTION_STAND_ON_TV_BUTTON
    dw   $0000 ; PLAYERACTION_ENTER_TV
    dw   .data_02_581b ; PLAYERACTION_JUMP
    dw   .data_02_581b ; PLAYERACTION_DOUBLE_JUMP
    dw   $0000 ; PLAYERACTION_TAIL_SPIN
    dw   $0000 ; PLAYERACTION_FALL
    dw   $0000 ; PLAYERACTION_LAND_FROM_FALL
    dw   $0000 ; PLAYERACTION_UNK19
    dw   $0000 ; PLAYERACTION_ENTER_IDLE
    dw   $0000 ; PLAYERACTION_NONE_1
    dw   $0000 ; PLAYERACTION_NONE_2
    dw   $0000 ; PLAYERACTION_NONE_3
    dw   $0000 ; PLAYERACTION_NONE_4
    dw   .data_02_5757 ; PLAYERACTION_WATER_SWIMMING
    dw   $0000 ; PLAYERACTION_DEATH_IN_PIT_ALT
    dw   $0000 ; PLAYERACTION_DEATH_IN_PIT
    dw   $0000 ; PLAYERACTION_NONE_5
    dw   $0000 ; PLAYERACTION_BLOWN_UPWARDS
    dw   $0000 ; PLAYERACTION_RIDING_ELEVATOR
    dw   $0000 ; PLAYERACTION_WATER_TAIL_SPIN
    dw   .data_02_576a ; PLAYERACTION_WATER_TREADING
    dw   $0000 ; PLAYERACTION_WATER_DIVING
    dw   $0000 ; PLAYERACTION_CLIMBING
    dw   .data_02_578f ; PLAYERACTION_SNOWBOARDING_SPAWN
    dw   .data_02_5792 ; PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    dw   .data_02_57b7 ; PLAYERACTION_SNOWBOARDING_JUMP
    dw   .data_02_57b7 ; PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_FALL
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_DIE
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_DIE_WARP
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_ENTER_TV
    dw   $0000 ; PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    dw   .data_02_5779 ; PLAYERACTION_KANGAROO_SPAWN
    dw   $0000 ; PLAYERACTION_KANGAROO_IDLE
    dw   .data_02_577c ; PLAYERACTION_KANGAROO_HOPPING
    dw   $0000 ; PLAYERACTION_KANGAROO_START_JUMP
    dw   .data_02_577c ; PLAYERACTION_KANGAROO_JUMP
    dw   $0000 ; PLAYERACTION_KANGAROO_TAIL_SPIN
    dw   $0000 ; PLAYERACTION_KANGAROO_FALL
    dw   $0000 ; PLAYERACTION_KANGAROO_TAKE_DAMAGE
    dw   $0000 ; PLAYERACTION_KANGAROO_DEATH
    dw   $0000 ; PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    dw   $0000 ; PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON
    dw   $0000 ; PLAYERACTION_KANGAROO_ENTER_TV
    dw   $0000 ; PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT
.data_02_56b5:
    db   $fe, $01, $ff
.data_02_56b8:
    db   $50, $03, $10, $03, $90, $04, $80, $04
    db   $a0, $04, $20, $03, $60, $03, $01, $10
    db   $41, $10, $51, $10, $11, $10, $91, $10
    db   $81, $10, $a1, $10, $21, $10, $61, $10
    db   $02, $0e, $42, $0e, $52, $0e, $12, $0e
    db   $92, $0e, $82, $0e, $a2, $0e, $22, $0e
    db   $62, $0e, $ff
.data_02_56eb:
    db   $01, $10, $41, $10, $51, $10, $11, $10
    db   $91, $10, $81, $10, $a1, $10, $21, $10
    db   $61, $10, $12, $0e, $22, $0e, $52, $0e
    db   $62, $0e, $80, $07, $90, $07, $a0, $07
    db   $40, $01, $03, $01, $00, $01, $ff
.data_02_5712:
    db   $00, $01, $ff
.data_02_5715:
    db   $82, $0e, $92, $0e, $a2, $0e, $12, $0e
    db   $22, $0e, $42, $0e, $52, $0e, $62, $0e
    db   $01, $10, $41, $10, $51, $10, $11, $10
    db   $91, $10, $81, $10, $a1, $10, $21, $10
    db   $61, $10, $40, $06, $50, $06, $60, $06
    db   $10, $03, $20, $03, $00, $06, $ff
.data_02_5744:
    db   $01, $10, $41, $10, $51, $10, $11, $10
    db   $91, $10, $81, $10, $a1, $10, $21, $10
    db   $61, $10, $ff
.data_02_5757:
    db   $01, $1f, $41, $1f, $51, $1f, $11, $1f
    db   $91, $1f, $81, $1f, $a1, $1f, $21, $1f
    db   $61, $1f, $ff
.data_02_576a:
    db   $02, $0f, $42, $0f, $52, $0f, $12, $0f
    db   $22, $0f, $62, $0f, $80, $21, $ff
.data_02_5779:
    db   $fe, $30, $ff
.data_02_577c:
    db   $01, $34, $41, $34, $51, $34, $11, $34
    db   $91, $34, $81, $34, $a1, $34, $21, $34
    db   $61, $34, $ff
.data_02_578f:
    db   $fe, $24, $ff
.data_02_5792:
    db   $01, $27, $41, $27, $51, $27, $11, $27
    db   $91, $27, $81, $27, $a1, $27, $21, $27
    db   $61, $27, $02, $25, $42, $25, $52, $25
    db   $12, $25, $92, $25, $82, $25, $a2, $25
    db   $22, $25, $62, $25, $ff
.data_02_57b7:
    db   $01, $27, $41, $27, $51, $27, $11, $27
    db   $91, $27, $81, $27, $a1, $27, $21, $27
    db   $61, $27, $ff
.data_02_57ca:
    db   $fe, $3d, $ff
.data_02_57cd:
    db   $40, $3f, $50, $3f, $10, $3f, $90, $3f
    db   $80, $3f, $a0, $3f, $20, $3f, $60, $3f
    db   $01, $4c, $02, $4a, $42, $4a, $52, $4a
    db   $12, $4a, $92, $4a, $82, $4a, $a2, $4a
    db   $22, $4a, $62, $4a, $ff
.data_02_57f2:
    db   $01, $4c, $41, $4c, $51, $4c, $11, $4c
    db   $91, $4c, $81, $4c, $a1, $4c, $21, $4c
    db   $61, $4c, $02, $4a, $42, $4a, $52, $4a
    db   $12, $4a, $92, $4a, $82, $4a, $a2, $4a
    db   $22, $4a, $62, $4a, $03, $3d, $00, $3d
    db   $ff
.data_02_581b:
    db   $01, $4c, $41, $4c, $51, $4c, $11, $4c
    db   $91, $4c, $81, $4c, $a1, $4c, $21, $4c
    db   $61, $4c, $ff
