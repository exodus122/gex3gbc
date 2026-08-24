; ==================================================================
; Bank 2. The frame. Everything that has to happen once per frame to the world -
; set it up, tick it, animate it, and decide whether the camera moved - lives
; here, and the per-entity behaviour it dispatches into lives next door in
; bank02_entity_actions.asm.
;
; The per-frame order
; -------------------
; call_02_7152_Entities_UpdateAll is the routine the outer loop calls, and the
; order it does things in is the interesting part:
;
;   1. clear the two player X-delta accumulators and the first shadow OAM entry
;   2. if wDCA7_Player_UpdateFlag is clear, skip straight to step 6 - this is how
;      a cutscene freezes Gex while the rest of the world keeps running
;   3. apply whatever the tile Gex is standing in does to him: TILE_TYPE_PUSH_LEFT
;      and TILE_TYPE_PUSH_RIGHT add a delta, TILE_TYPE_PUSH_UP overwrites his Y
;      velocity outright. If he is mid-damage the knockback in
;      wDC98_Player_DamageKnockbackX takes that slot instead
;   4. run the action function of whatever he is STANDING ON, out of slot order and
;      before Gex himself, then snap him to sit on top of it. That one-frame
;      ordering is the only reason a moving platform does not appear to slide out
;      from under him
;   5. run the action function of whatever he is PUSHING INTO, then
;      call_02_4f32_Player_UpdateMain
;   6. call_02_72fb_MapWindow_Update - the camera follows him, and the two scroll
;      checks decide whether a new row or column has to be loaded
;   7. every slot from $20 upward: run its action function - unless it is one of
;      the two already run in steps 4 and 5 - and then tick its animation
;   8. call_03_5ec1_OAM_BuildFrame builds all the sprites
;
; How an entity's action works
; ----------------------------
; An entity has an id and an action id. call_02_72ac_Entity_SetAction turns the
; pair into a row of a table with two lookups - entity id x 2 into
; data_02_4000_EntityActionJumpTable to get that type's action table, then action
; id x 4 into that - and copies the row's action data block into the slot: the
; function pointer, the frame timings, the first sprite id, and the pointer to the
; sprite id list itself.
;
; call_02_724d_Entity_TickAction then walks that list one frame at a time.
; SPRITE_FRAME_COUNTER counts down and SPRITE_FRAME_COUNTER_HOLD means "stay on
; this frame forever"; when the list runs out, what happens next is declared by the
; data rather than decided here:
;
;   PENDING_ACTION_PRESENT        in ENTITY_FIELD_PENDING_ACTION - switch to the
;                                 action named in its low bits and stop
;   ACTION_STATE_LOOP_LAST_FRAME  restart ON the last frame, so the animation plays
;                                 once and then holds its final pose
;   otherwise                     restart at frame 0
;
; Map of this file
; ----------------
;   $708F-$7151  level start, the NPC slots, and the pause backup of the id table
;   $7152-$724C  the per-frame pass
;   $724D-$72A0  the animation player
;   $72A1-$72FA  setting an action, and asking for the graphics that go with it
;   $72FB-$739A  the camera window and the two scroll checks
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank02_update_entities.asm
; ------------------------------------------------------------------
; The two files line up routine for routine down the middle - init, the update
; pass, the animation player, SetAction, the map window and the two scroll checks
; are all here in the same order and mostly doing the same thing. gex2's file is
; twice the size because it also owns the entity graphics queue and the entity
; graphics/palette table, neither of which gex3 keeps here. The differences:
;
;   gfx requests  gex2's Entity_NotifyActionChanged really notifies: it works out
;                 the ROM bank and page for the entity's new sprite and raises
;                 GFX_XFER_ENTITY_GFX there and then. gex3's does almost nothing -
;                 it raises GFX_XFER_PLAYER_GFX for slot 0 and returns. Other
;                 entities are handled by polling instead:
;                 call_02_724d_Entity_TickAction sets ACTION_STATE_ID_CHANGED and
;                 call_00_08f8_StageNextGfxTransfer sweeps every slot for that bit
;                 once a frame. That is why gex3 has no graphics queue here
;   gfx queue     gex2's Entities_QueueGraphicsAndPalettes, EntityGfxQueue_Enqueue,
;                 EntityGfxQueue_StartNextTransfer, its 58 tile-streaming
;                 descriptors and the 144-row gfx/palette table are all gex2-only.
;                 gex3 streams one entity page per frame from the poll above and
;                 keeps per-entity palettes in wDD2A_EntityPalettes instead
;   the flags     the same animation bits live in different bytes. gex2 splits them
;                 between ACTION_STATE ($09) and SPRITE_FLAGS ($0A); gex3 keeps
;                 the pending action in ENTITY_FIELD_PENDING_ACTION ($04) and every
;                 flag in ENTITY_FIELD_ACTION_STATE_FLAGS ($05). The gex3 constants
;                 keep the ACTION_STATE_ prefix for all of them rather than
;                 inventing a split the hardware does not have; each one names its
;                 gex2 counterpart
;   pause         call_02_7132_Entities_BackupIdTable and its restore have no gex2
;                 counterpart in this file - gex2 saves and restores world state
;                 wholesale in bank00_entity_utils.asm instead. gex3 only needs the
;                 eight entity ids, because opening a menu overwrites entity memory
;                 but nothing else about the level
;   scrolling     the vertical check is the same routine in both games. The
;                 horizontal one is not: gex3 adds the MAP_WRAP_BOUNDARY_INDEX
;                 case, where a map joins its last column back to its first and the
;                 step across that seam has to be read as a one-column scroll
;                 rather than a jump across the whole map. gex2 levels do not wrap
;   bonus stages  gex3's init spawns SPAWN_CHILD_ENTITY_STAGE_TIMER when
;                 wDB6D_InBonusStage is set and ticks it once immediately, so the
;                 countdown is already on screen for the first frame. gex2 has no
;                 timed bonus stages - it uses a collectible quota instead
; ==================================================================

call_02_708f_Entities_InitAndSpawnAll:
; Level start, and the start of each life. Puts the world back to a known state and
; then places entities until the spawner says it has come back round to the start.
;
; Three parts. The first only runs when wDC78_PlayerPendingActionId names an action
; - the outer loop in bank 0 sets it to say which action Gex should appear in, and
; that depends on the map's collision type and the level's vehicle mode - and it
; rebuilds Gex from scratch: slot 0, ENTITY_GEX, that action, and every velocity
; and state byte zeroed.
;
; The second part always runs and is the part that matters after a death: the
; carried-along X deltas, the collision flags, and the three "what is Gex touching"
; slot pointers, then call_02_7123_Entities_InitNPCSlots to free every other slot.
;
; The third is the spawn loop. In a bonus stage it first plants
; SPAWN_CHILD_ENTITY_STAGE_TIMER and ticks it once by hand so the countdown is
; already drawn on the first frame. Then it resets the entity counter and calls
; call_00_360c_SpawnEntityOnceImmediate until wDAB8_EntityCounter is back to 1,
; which is the spawner's way of saying it has wrapped past the end of the level's
; entity list - so "spawn everything that fits" is written as "keep going until the
; counter comes back round".
;
; gex2's call_02_6e17_Entities_InitAndSpawnAll, which loops on wD338_EntityLoadingFlag
; for the same reason
    xor  A, A                                         ;; 02:708f $af
    ld   [wDB6A_WarpFlags], A                         ;; 02:7090 $ea $6a $db
    ld   A, [wDC78_PlayerPendingActionId]             ;; 02:7093 $fa $78 $dc
    cp   A, PLAYERACTION_NONE_PENDING                 ;; 02:7096 $fe $ff
    jr   Z, .jr_02_70d1                               ;; 02:7098 $28 $37
    xor  A, A                                         ;; 02:709a $af
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:709b $ea $00 $da
    ld   A, ENTITY_GEX                                ;; 02:709e $3e $00
    ld   [wD800_Player_Id], A                         ;; 02:70a0 $ea $00 $d8
    ld   A, [wDC78_PlayerPendingActionId]             ;; 02:70a3 $fa $78 $dc
    call call_02_72ac_Entity_SetAction                ;; 02:70a6 $cd $ac $72
    ld   A, PLAYERACTION_NONE_PENDING                 ;; 02:70a9 $3e $ff
    ld   [wDC78_PlayerPendingActionId], A             ;; 02:70ab $ea $78 $dc
    ld   A, $00                                       ;; 02:70ae $3e $00
    ld   [wDC7A_PlayerClimbingOrSwimmingRelated], A   ;; 02:70b0 $ea $7a $dc
    ld   A, $00                                       ;; 02:70b3 $3e $00
    ld   [wD80D_PlayerFacingDirection], A             ;; 02:70b5 $ea $0d $d8
    xor  A, A                                         ;; 02:70b8 $af
    ld   [wDC86_PlayerXVelocity], A                   ;; 02:70b9 $ea $86 $dc
    ld   [wDC87_PlayerXMaxVelocity], A                ;; 02:70bc $ea $87 $dc
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:70bf $ea $8c $dc
    ld   [wDC8D_Player_FloorSnapVelocity], A          ;; 02:70c2 $ea $8d $dc
    ld   [wDC8E_InitialYVelocity], A                  ;; 02:70c5 $ea $8e $dc
    ld   [wDC8F_FallDistanceCounter], A               ;; 02:70c8 $ea $8f $dc
    ld   [wDC88_CurrentEntity_UnkVerticalOffset], A   ;; 02:70cb $ea $88 $dc
    ld   [wDC80_ButtonBlockingFlags], A               ;; 02:70ce $ea $80 $dc
.jr_02_70d1:
    xor  A, A                                         ;; 02:70d1 $af
    ld   [wDC85_PlayerXDeltaExtra2], A                ;; 02:70d2 $ea $85 $dc
    ld   [wDC84_PlayerXDeltaExtra], A                 ;; 02:70d5 $ea $84 $dc
    ld   [wDABE_CollisionFlags], A                    ;; 02:70d8 $ea $be $da
    ld   [wDABD_CollisionFlagsPrev], A                ;; 02:70db $ea $bd $da
    ld   A, PLAYERACTION_NONE_PENDING                 ;; 02:70de $3e $ff
    ld   [wDC79_Player_QueuedAction], A               ;; 02:70e0 $ea $79 $dc
    xor  A, A                                         ;; 02:70e3 $af
    ld   [wDC7B_Player_EntityStoodOnLo], A            ;; 02:70e4 $ea $7b $dc
    ld   [wDC7C_PlayerCollisionUnusedFlag], A         ;; 02:70e7 $ea $7c $dc
    ld   [wDC7D_Player_PushedMovingPlatformLo], A     ;; 02:70ea $ea $7d $dc
    call call_02_7123_Entities_InitNPCSlots           ;; 02:70ed $cd $23 $71
    ld   A, [wDB6D_InBonusStage]                      ;; 02:70f0 $fa $6d $db
    and  A, A                                         ;; 02:70f3 $a7
    jr   Z, .jr_02_7115                               ;; 02:70f4 $28 $1f
    xor  A, A                                         ;; 02:70f6 $af
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:70f7 $ea $00 $da
    ld   C, SPAWN_CHILD_ENTITY_STAGE_TIMER            ;; 02:70fa $0e $19
    call call_00_3792_PrepareRelativeEntitySpawn      ;; 02:70fc $cd $92 $37
    ld   C, ENTITY_BONUS_STAGE_TIMER                  ;; 02:70ff $0e $1b
    call call_00_29ce_Entity_FindSlotById             ;; 02:7101 $cd $ce $29
    jr   NZ, .jr_02_7115                              ;; 02:7104 $20 $0f
    ld   A, L                                         ;; 02:7106 $7d
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:7107 $ea $00 $da
    farcall call_02_5bb3_EntityAction_UpdateBonusStageTimer
.jr_02_7115:
    call call_00_3252_ResetEntityCounter              ;; 02:7115 $cd $52 $32
.jr_02_7118:
    call call_00_360c_SpawnEntityOnceImmediate        ;; 02:7118 $cd $0c $36
    ld   A, [wDAB8_EntityCounter]                     ;; 02:711b $fa $b8 $da
    cp   A, $01                                       ;; 02:711e $fe $01
    jr   NZ, .jr_02_7118                              ;; 02:7120 $20 $f6
    ret                                               ;; 02:7122 $c9

call_02_7123_Entities_InitNPCSlots:
; Frees the seven non-player slots by writing ENTITY_ID_NONE into each one's id
; byte. Only the id byte - the rest of a slot is left holding whatever the last
; entity put there, because Entity_SetAction overwrites everything that matters
; when the slot is next used.
;
; Starts at wD820_EntityMemoryAfterPlayer, so slot 0 (Gex) survives. gex2's
; call_02_6e68_Entities_InitNPCSlots does the same seven slots
    ld   HL, wD820_EntityMemoryAfterPlayer            ;; 02:7123 $21 $20 $d8
    ld   DE, ENTITY_SLOT_SIZE                         ;; 02:7126 $11 $20 $00
    ld   B, ENTITY_NPC_SLOT_COUNT                     ;; 02:7129 $06 $07
.jr_02_712b:
    ld   [HL], ENTITY_ID_NONE                         ;; 02:712b $36 $ff
    add  HL, DE                                       ;; 02:712d $19
    dec  B                                            ;; 02:712e $05
    jr   NZ, .jr_02_712b                              ;; 02:712f $20 $fa
    ret                                               ;; 02:7131 $c9

call_02_7132_Entities_BackupIdTable:
; Copies the id byte of all eight slots into wDA09_LoadedEntityIdsBackupBuffer.
;
; This is the pause path: opening a menu reuses entity memory for the menu's own
; work, so the ids are parked here and put back on the way out. Only the ids -
; positions, velocities and timers are not saved, which is why an entity resumes
; wherever the menu left it rather than where it was.
;
; The walk is the usual `add A, $20 / jr NZ`, so it stops when the low byte wraps.
; gex2 has no equivalent here; it saves and restores far more state, in
; call_00_3628_Entity_SaveWorldState
    ld   HL, wD800_Player_Id                          ;; 02:7132 $21 $00 $d8
    ld   DE, wDA09_LoadedEntityIdsBackupBuffer        ;; 02:7135 $11 $09 $da
.jr_02_7138:
    ld   A, [HL]                                      ;; 02:7138 $7e
    ld   [DE], A                                      ;; 02:7139 $12
    inc  DE                                           ;; 02:713a $13
    ld   A, L                                         ;; 02:713b $7d
    add  A, ENTITY_SLOT_SIZE                          ;; 02:713c $c6 $20
    ld   L, A                                         ;; 02:713e $6f
    jr   NZ, .jr_02_7138                              ;; 02:713f $20 $f7
    ret                                               ;; 02:7141 $c9

call_02_7142_Entities_RestoreIdTable:
; The inverse of the above, run when a menu closes
    ld   HL, wD800_Player_Id                          ;; 02:7142 $21 $00 $d8
    ld   DE, wDA09_LoadedEntityIdsBackupBuffer        ;; 02:7145 $11 $09 $da
.jr_02_7148:
    ld   A, [DE]                                      ;; 02:7148 $1a
    ld   [HL], A                                      ;; 02:7149 $77
    inc  DE                                           ;; 02:714a $13
    ld   A, L                                         ;; 02:714b $7d
    add  A, ENTITY_SLOT_SIZE                          ;; 02:714c $c6 $20
    ld   L, A                                         ;; 02:714e $6f
    jr   NZ, .jr_02_7148                              ;; 02:714f $20 $f7
    ret                                               ;; 02:7151 $c9

call_02_7152_Entities_UpdateAll:
; One frame of the world. See the header for the full order; the parts worth
; reading twice are these.
;
; wDCA7_Player_UpdateFlag gates everything player-shaped. When it is clear the
; routine jumps straight to the map window and the entity loop, so a cutscene gets
; a live world with a Gex that neither moves nor collides.
;
; The tile pushes and the damage knockback share one destination,
; wDC84_PlayerXDeltaExtra, and are written as a chain of comparisons that all fall
; into the same store. TILE_TYPE_PUSH_UP is the exception: it writes
; wDC8C_PlayerYVelocity directly and skips the store entirely.
;
; Then the two special entities. Whatever Gex is standing on
; (wDC7B_Player_EntityStoodOnLo) has its action function called FIRST, before Gex
; and out of slot order, and then his Y is recomputed from the platform's: its YPOS
; minus $10 minus its ENTITY_FIELD_HEIGHT. Doing it in that order is what stops him
; visibly lagging a frame behind a platform he is riding. Whatever he is pushing
; into (wDC7D_Player_PushedMovingPlatformLo) is run next, and then
; call_02_4f32_Player_UpdateMain.
;
; The slot loop then skips those two - it compares each slot base against both
; pointers - so nothing is updated twice. An entity whose id is ENTITY_ID_NONE is
; skipped entirely; every other slot gets its action function and then
; call_02_724d_Entity_TickAction.
;
; Reaching the action function is the same three lines everywhere in this file:
; ENTITY_FIELD_ACTION_FUNC is a pointer stored in the slot, and
; call_00_0f22_JumpHL is a `jp hl` used as a call.
;
; gex2's call_02_6eba_Entities_UpdateAll, same shape and the same ordering trick
    xor  A, A                                         ;; 02:7152 $af
    ld   [wDC85_PlayerXDeltaExtra2], A                ;; 02:7153 $ea $85 $dc
    ld   [wDC84_PlayerXDeltaExtra], A                 ;; 02:7156 $ea $84 $dc
    ld   [wD900_ShadowOAM], A                         ;; 02:7159 $ea $00 $d9
    ld   [wD904], A                                   ;; 02:715c $ea $04 $d9
    ld   A, [wDCA7_Player_UpdateFlag]                 ;; 02:715f $fa $a7 $dc
    and  A, A                                         ;; 02:7162 $a7
    jp   Z, .jp_02_7200                               ;; 02:7163 $ca $00 $72
    call call_02_5541_Player_GetActionStates          ;; 02:7166 $cd $41 $55
    and  A, PLAYER_STATE_DEAD_MASK                    ;; 02:7169 $e6 $08
    jr   NZ, .jr_02_717f                              ;; 02:716b $20 $12
    ld   A, [wDC93_TileTypeBehindGexsLowerBody]       ;; 02:716d $fa $93 $dc
    cp   A, TILE_TYPE_PUSH_RIGHT                      ;; 02:7170 $fe $15
    jr   Z, .jr_02_7196                               ;; 02:7172 $28 $22
    cp   A, TILE_TYPE_PUSH_LEFT                       ;; 02:7174 $fe $16
    jr   Z, .jr_02_719a                               ;; 02:7176 $28 $22
    ld   A, [wDC92_TileTypeBehindGexsUpperBody]       ;; 02:7178 $fa $92 $dc
    cp   A, TILE_TYPE_PUSH_UP                         ;; 02:717b $fe $17
    jr   Z, .jr_02_719e                               ;; 02:717d $28 $1f
.jr_02_717f:
    ld   HL, wDC98_Player_DamageKnockbackX            ;; 02:717f $21 $98 $dc
    ld   C, [HL]                                      ;; 02:7182 $4e
    ld   A, [wD801_Player_ActionId]                   ;; 02:7183 $fa $01 $d8
    cp   A, PLAYERACTION_TAKE_DAMAGE                  ;; 02:7186 $fe $09
    jr   Z, .jr_02_71a5                               ;; 02:7188 $28 $1b
    cp   A, PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE     ;; 02:718a $fe $29
    jr   Z, .jr_02_71a5                               ;; 02:718c $28 $17
    cp   A, PLAYERACTION_KANGAROO_TAKE_DAMAGE         ;; 02:718e $fe $36
    jr   Z, .jr_02_71a5                               ;; 02:7190 $28 $13
    ld   C, $00                                       ;; 02:7192 $0e $00
    jr   .jr_02_71a5                                  ;; 02:7194 $18 $0f
.jr_02_7196:
    ld   C, TILE_PUSH_RIGHT_DELTA                     ;; 02:7196 $0e $02
    jr   .jr_02_71a5                                  ;; 02:7198 $18 $0b
.jr_02_719a:
    ld   C, TILE_PUSH_LEFT_DELTA                      ;; 02:719a $0e $fe
    jr   .jr_02_71a5                                  ;; 02:719c $18 $07
.jr_02_719e:
    ld   A, TILE_PUSH_UP_YVEL                         ;; 02:719e $3e $20
    ld   [wDC8C_PlayerYVelocity], A                   ;; 02:71a0 $ea $8c $dc
    jr   .jr_02_71a9                                  ;; 02:71a3 $18 $04
.jr_02_71a5:
    ld   HL, wDC84_PlayerXDeltaExtra                  ;; 02:71a5 $21 $84 $dc
    ld   [HL], C                                      ;; 02:71a8 $71
.jr_02_71a9:
    ld   A, [wDC7B_Player_EntityStoodOnLo]            ;; 02:71a9 $fa $7b $dc
    and  A, A                                         ;; 02:71ac $a7
    jr   Z, .jr_02_71e4                               ;; 02:71ad $28 $35
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:71af $ea $00 $da
    or   A, ENTITY_FIELD_ACTION_FUNC                  ;; 02:71b2 $f6 $02
    ld   L, A                                         ;; 02:71b4 $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:71b5 $26 $d8
    ld   A, [HL+]                                     ;; 02:71b7 $2a
    ld   H, [HL]                                      ;; 02:71b8 $66
    ld   L, A                                         ;; 02:71b9 $6f
    call call_00_0f22_JumpHL                          ;; 02:71ba $cd $22 $0f
    ld   A, [wDC7B_Player_EntityStoodOnLo]            ;; 02:71bd $fa $7b $dc
    and  A, A                                         ;; 02:71c0 $a7
    jr   Z, .jr_02_71e4                               ;; 02:71c1 $28 $21
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:71c3 $26 $d8
    ld   A, [wDC7B_Player_EntityStoodOnLo]            ;; 02:71c5 $fa $7b $dc
    and  A, ENTITY_SLOT_BASE_MASK                     ;; 02:71c8 $e6 $e0
    or   A, ENTITY_FIELD_YPOS                         ;; 02:71ca $f6 $10
    ld   L, A                                         ;; 02:71cc $6f
    ld   A, [HL+]                                     ;; 02:71cd $2a
    sub  A, ENTITY_FIELD_YPOS                         ;; 02:71ce $d6 $10
    ld   E, A                                         ;; 02:71d0 $5f
    ld   A, [HL]                                      ;; 02:71d1 $7e
    sbc  A, $00                                       ;; 02:71d2 $de $00
    ld   D, A                                         ;; 02:71d4 $57
    ld   A, L                                         ;; 02:71d5 $7d
    xor  A, $02                                       ;; 02:71d6 $ee $02
    ld   L, A                                         ;; 02:71d8 $6f
    ld   A, E                                         ;; 02:71d9 $7b
    sub  A, [HL]                                      ;; 02:71da $96
    ld   [wD810_PlayerYPosition], A                   ;; 02:71db $ea $10 $d8
    ld   A, D                                         ;; 02:71de $7a
    sbc  A, $00                                       ;; 02:71df $de $00
    ld   [wD810_PlayerYPosition+1], A                 ;; 02:71e1 $ea $11 $d8
.jr_02_71e4:
    ld   A, [wDC7D_Player_PushedMovingPlatformLo]     ;; 02:71e4 $fa $7d $dc
    and  A, A                                         ;; 02:71e7 $a7
    jr   Z, .jr_02_71f8                               ;; 02:71e8 $28 $0e
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:71ea $ea $00 $da
    or   A, ENTITY_FIELD_ACTION_FUNC                  ;; 02:71ed $f6 $02
    ld   L, A                                         ;; 02:71ef $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:71f0 $26 $d8
    ld   A, [HL+]                                     ;; 02:71f2 $2a
    ld   H, [HL]                                      ;; 02:71f3 $66
    ld   L, A                                         ;; 02:71f4 $6f
    call call_00_0f22_JumpHL                          ;; 02:71f5 $cd $22 $0f
.jr_02_71f8:
    ld   A, $00                                       ;; 02:71f8 $3e $00
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:71fa $ea $00 $da
    call call_02_4f32_Player_UpdateMain               ;; 02:71fd $cd $32 $4f
.jp_02_7200:
    call call_02_72fb_MapWindow_Update                ;; 02:7200 $cd $fb $72
    ld   A, ENTITY_SLOT_SIZE                          ;; 02:7203 $3e $20
.jr_02_7205:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 02:7205 $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 02:7208 $f6 $00
    ld   L, A                                         ;; 02:720a $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:720b $26 $d8
    ld   A, [HL]                                      ;; 02:720d $7e
    cp   A, ENTITY_ID_NONE                            ;; 02:720e $fe $ff
    jr   Z, .jr_02_723a                               ;; 02:7210 $28 $28
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 02:7212 $fa $00 $da
    ld   HL, wDC7B_Player_EntityStoodOnLo             ;; 02:7215 $21 $7b $dc
    cp   A, [HL]                                      ;; 02:7218 $be
    jr   Z, .jr_02_722c                               ;; 02:7219 $28 $11
    ld   HL, wDC7D_Player_PushedMovingPlatformLo      ;; 02:721b $21 $7d $dc
    cp   A, [HL]                                      ;; 02:721e $be
    jr   Z, .jr_02_722c                               ;; 02:721f $28 $0b
    or   A, ENTITY_FIELD_ACTION_FUNC                  ;; 02:7221 $f6 $02
    ld   L, A                                         ;; 02:7223 $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:7224 $26 $d8
    ld   A, [HL+]                                     ;; 02:7226 $2a
    ld   H, [HL]                                      ;; 02:7227 $66
    ld   L, A                                         ;; 02:7228 $6f
    call call_00_0f22_JumpHL                          ;; 02:7229 $cd $22 $0f
.jr_02_722c:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   A, [HL]                                      ;; 02:7234 $7e
    cp   A, ENTITY_ID_NONE                            ;; 02:7235 $fe $ff
    call NZ, call_02_724d_Entity_TickAction           ;; 02:7237 $c4 $4d $72
.jr_02_723a:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 02:723a $fa $00 $da
    add  A, ENTITY_SLOT_SIZE                          ;; 02:723d $c6 $20
    jr   NZ, .jr_02_7205                              ;; 02:723f $20 $c4
    farcall call_03_5ec1_OAM_BuildFrame
    ret                                               ;; 02:724c $c9

call_02_724d_Entity_TickAction:
; The animation player, run once a frame for every live entity including Gex.
;
; ACTION_STATE_ANIM_ENDED is cleared first thing, so it is a one-frame pulse and
; whatever reads it later in the frame sees only this frame's wrap.
;
; SPRITE_FRAME_COUNTER counts down. SPRITE_FRAME_COUNTER_HOLD means hold this frame
; forever and is how an entity freezes its animation without a flag of its own.
; When the counter hits zero it reloads from SPRITE_FRAME_COUNTER_MAX and
; SPRITE_COUNTER steps on; when SPRITE_COUNTER reaches SPRITE_COUNTER_MAX the
; sequence has run out and one of three things happens:
;
;   PENDING_ACTION_PRESENT set   hand over to the action in the low bits of
;                                ENTITY_FIELD_PENDING_ACTION and stop. Slot 0 goes
;                                through call_02_54f9_Player_RequestAction, everyone
;                                else through call_02_72ac_Entity_SetAction
;   ACTION_STATE_LOOP_LAST_FRAME restart at SPRITE_COUNTER_MAX - 1, so the animation
;                                plays once and sits on its final pose
;   otherwise                    restart at frame 0
;
; Either way it then sets ACTION_STATE_ANIM_ENDED and ACTION_STATE_ID_CHANGED and
; reads the new sprite id out of the ENTITY_FIELD_SPRITE_IDS_PTR list.
;
; ACTION_STATE_ID_CHANGED is where gex3 and gex2 part company: gex3 sets the bit
; and lets call_00_08f8_StageNextGfxTransfer find it, while gex2 raises the
; transfer request from Entity_NotifyActionChanged directly.
;
; Falls through into call_02_72a1_Entity_NotifyActionChanged. gex2's
; call_02_6fda_Entity_TickAction
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_PENDING_ACTION               ; HL = ENTITY_FIELD_PENDING_ACTION
    ld   E, [HL]                                      ;; 02:7255 $5e
    inc  L                                            ;; 02:7256 $2c ; HL = ENTITY_FIELD_ACTION_STATE_FLAGS
    res  ACTION_STATE_ANIM_ENDED_BIT, [HL]            ;; 02:7257 $cb $96
    ld   B, [HL]                                      ;; 02:7259 $46 ; b = HL
    inc  L                                            ;; 02:725a $2c ; HL = ENTITY_FIELD_SPRITE_FRAME_COUNTER_MAX
    ld   C, [HL]                                      ;; 02:725b $4e ; c = HL
    inc  L                                            ;; 02:725c $2c ; HL = ENTITY_FIELD_SPRITE_FRAME_COUNTER
    ld   A, [HL]                                      ;; 02:725d $7e ; a = HL
    cp   A, SPRITE_FRAME_COUNTER_HOLD                 ;; 02:725e $fe $ff
    ret  Z                                            ;; 02:7260 $c8 ; return if == ff
    dec  [HL]                                         ;; 02:7261 $35 ; 
    ret  NZ                                           ;; 02:7262 $c0 ; return if ENTITY_FIELD_SPRITE_FRAME_COUNTER != 0
    ld   [HL], C                                      ;; 02:7263 $71 ; 
    inc  L                                            ;; 02:7264 $2c ; HL = ENTITY_FIELD_SPRITE_COUNTER_MAX
    ld   A, [HL+]                                     ;; 02:7265 $2a
    ld   C, A                                         ;; 02:7266 $4f ; HL = ENTITY_FIELD_SPRITE_COUNTER
    inc  [HL]                                         ;; 02:7267 $34
    sub  A, [HL]                                      ;; 02:7268 $96
    jr   NZ, .jr_02_7288                              ;; 02:7269 $20 $1d
    bit  PENDING_ACTION_PRESENT_BIT, E                ;; 02:726b $cb $7b
    jr   Z, .jr_02_727c                               ;; 02:726d $28 $0d
    res  PENDING_ACTION_PRESENT_BIT, E                ;; 02:726f $cb $bb
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 02:7271 $fa $00 $da
    and  A, A                                         ;; 02:7274 $a7
    ld   A, E                                         ;; 02:7275 $7b
    jp   Z, call_02_54f9_Player_RequestAction         ;; 02:7276 $ca $f9 $54
    jp   call_02_72ac_Entity_SetAction                ;; 02:7279 $c3 $ac $72
.jr_02_727c:
    bit  ACTION_STATE_LOOP_LAST_FRAME_BIT, B          ;; 02:727c $cb $58
    jr   Z, .jr_02_7282                               ;; 02:727e $28 $02
    ld   A, C                                         ;; 02:7280 $79
    dec  A                                            ;; 02:7281 $3d
.jr_02_7282:
    ld   [HL-], A                                     ;; 02:7282 $32
    dec  L                                            ;; 02:7283 $2d
    dec  L                                            ;; 02:7284 $2d
    dec  L                                            ;; 02:7285 $2d ; HL = ENTITY_FIELD_ACTION_STATE_FLAGS
    set  ACTION_STATE_ANIM_ENDED_BIT, [HL]            ;; 02:7286 $cb $d6 
.jr_02_7288:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 02:7288 $fa $00 $da
    or   A, ENTITY_FIELD_ACTION_STATE_FLAGS           ;; 02:728b $f6 $05
    ld   L, A                                         ;; 02:728d $6f
    set  ACTION_STATE_ID_CHANGED_BIT, [HL]            ;; 02:728e $cb $ce
    ld   A, L                                         ;; 02:7290 $7d
    xor  A, $0c                                       ;; 02:7291 $ee $0c
    ld   L, A                                         ;; 02:7293 $6f ; HL = ENTITY_FIELD_SPRITE_COUNTER
    ld   E, [HL]                                      ;; 02:7294 $5e
    ld   D, $00                                       ;; 02:7295 $16 $00
    inc  L                                            ;; 02:7297 $2c ; HL = ENTITY_FIELD_SPRITE_ID
    push HL                                           ;; 02:7298 $e5
    inc  L                                            ;; 02:7299 $2c ; HL = ENTITY_FIELD_SPRITE_IDS_PTR
    ld   A, [HL+]                                     ;; 02:729a $2a ; HL = ENTITY_FIELD_SPRITE_IDS_PTR 2nd byte
    ld   H, [HL]                                      ;; 02:729b $66
    ld   L, A                                         ;; 02:729c $6f
    add  HL, DE                                       ;; 02:729d $19
    ld   A, [HL]                                      ;; 02:729e $7e
    pop  HL                                           ;; 02:729f $e1 ; HL = ENTITY_FIELD_SPRITE_ID
    ld   [HL], A                                      ;; 02:72a0 $77

call_02_72a1_Entity_NotifyActionChanged:
; Asks for the graphics that go with an action the entity just changed into - which
; in gex3 means one bit, for one entity.
;
; If the current slot is not Gex it returns. If it is, it raises
; GFX_XFER_PLAYER_GFX and the vblank handler streams his new frame into VRAM.
;
; Everything else gets its tiles by the polling route described above, which is why
; this routine is four instructions against the seventy-odd of gex2's
; call_02_7030_Entity_NotifyActionChanged
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 02:72a1 $fa $00 $da
    and  A, A                                         ;; 02:72a4 $a7
    ret  NZ                                           ;; 02:72a5 $c0
    ld   HL, wDB66_GfxTransferFlags                   ;; 02:72a6 $21 $66 $db
    set  GFX_XFER_PLAYER_GFX, [HL]                    ;; 02:72a9 $cb $c6
    ret                                               ;; 02:72ab $c9

call_02_72ac_Entity_SetAction:
; Puts the current entity into action A. This and Entity_TickAction are the two
; halves of the animation system.
;
; The action id is masked with PENDING_ACTION_ID_MASK - the caller may still be
; holding the pending-action byte with its top bit set - and written into
; ENTITY_FIELD_ACTION_ID. Then two lookups: the entity id doubled into
; data_02_4000_EntityActionJumpTable gives that entity type's action table, and the
; action id times four indexes a row of it. A row is an action function pointer and
; a pointer to an action data block.
;
; The data block is then unpacked into the slot, and the order is not the order it
; is stored in:
;
;   byte 0  -> ENTITY_FIELD_SPRITE_BANK      (written last, via the `xor $1b`)
;   byte 1  -> ENTITY_FIELD_PENDING_ACTION
;   byte 2  -> ENTITY_FIELD_ACTION_STATE_FLAGS
;   byte 3  -> SPRITE_FRAME_COUNTER_MAX and SPRITE_FRAME_COUNTER, both
;   byte 4  -> ENTITY_FIELD_SPRITE_COUNTER_MAX
;   byte 5  -> ENTITY_FIELD_SPRITE_ID
;   the block's own address + 6 -> ENTITY_FIELD_SPRITE_IDS_PTR
;
; ENTITY_FIELD_SPRITE_COUNTER is zeroed on the way past, so the new action always
; starts on its first frame. Falls into
; call_02_72a1_Entity_NotifyActionChanged. gex2's call_02_7102_Entity_SetAction
    and  A, PENDING_ACTION_ID_MASK                    ;; 02:72ac $e6 $7f
    ld   HL, wDA00_CurrentEntityAddrLo                ;; 02:72ae $21 $00 $da
    ld   L, [HL]                                      ;; 02:72b1 $6e
    inc  L                                            ;; 02:72b2 $2c
    ld   H, HIGH(wD800_EntityMemory)                  ;; 02:72b3 $26 $d8
    ld   [HL-], A                                     ;; 02:72b5 $32 ; writes new action id to entity instance
    ld   L, [HL]                                      ;; 02:72b6 $6e
    ld   H, $00                                       ;; 02:72b7 $26 $00
    add  HL, HL                                       ;; 02:72b9 $29
    ld   DE, data_02_4000_EntityActionJumpTable       ;; 02:72ba $11 $00 $40
    add  HL, DE                                       ;; 02:72bd $19
    ld   E, [HL]                                      ;; 02:72be $5e
    inc  HL                                           ;; 02:72bf $23
    ld   D, [HL]                                      ;; 02:72c0 $56
    ld   L, A                                         ;; 02:72c1 $6f ; at this point, DE = ptr to the entity's action table
    ld   H, $00                                       ;; 02:72c2 $26 $00
    add  HL, HL                                       ;; 02:72c4 $29
    add  HL, HL                                       ;; 02:72c5 $29
    add  HL, DE                                       ;; 02:72c6 $19
    ld   C, L                                         ;; 02:72c7 $4d
    ld   B, H                                         ;; 02:72c8 $44 ; HL and BC are ptrs to an entity action table entry
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_ACTION_FUNC
    ld   A, [BC]                                      ;; 02:72d1 $0a
    ld   [HL+], A                                     ;; 02:72d2 $22
    inc  BC                                           ;; 02:72d3 $03
    ld   A, [BC]                                      ;; 02:72d4 $0a
    ld   [HL+], A                                     ;; 02:72d5 $22 ; updates action func ptr in instance
    inc  BC                                           ;; 02:72d6 $03
    ld   A, [BC]                                      ;; 02:72d7 $0a
    ld   E, A                                         ;; 02:72d8 $5f
    inc  BC                                           ;; 02:72d9 $03
    ld   A, [BC]                                      ;; 02:72da $0a
    ld   D, A                                         ;; 02:72db $57
    ld   A, [DE]                                      ;; 02:72dc $1a ; at this point, DE is ptr to the data for this action
    ld   C, A                                         ;; 02:72dd $4f
    inc  DE                                           ;; 02:72de $13
    ld   A, [DE]                                      ;; 02:72df $1a
    ld   [HL+], A                                     ;; 02:72e0 $22
    inc  DE                                           ;; 02:72e1 $13
    ld   A, [DE]                                      ;; 02:72e2 $1a
    ld   [HL+], A                                     ;; 02:72e3 $22
    inc  DE                                           ;; 02:72e4 $13
    ld   A, [DE]                                      ;; 02:72e5 $1a
    ld   [HL+], A                                     ;; 02:72e6 $22
    ld   [HL+], A                                     ;; 02:72e7 $22
    inc  DE                                           ;; 02:72e8 $13
    ld   A, [DE]                                      ;; 02:72e9 $1a
    ld   [HL+], A                                     ;; 02:72ea $22
    inc  DE                                           ;; 02:72eb $13
    xor  A, A                                         ;; 02:72ec $af
    ld   [HL+], A                                     ;; 02:72ed $22
    ld   A, [DE]                                      ;; 02:72ee $1a
    ld   [HL+], A                                     ;; 02:72ef $22
    ld   [HL], E                                      ;; 02:72f0 $73
    inc  L                                            ;; 02:72f1 $2c
    ld   [HL], D                                      ;; 02:72f2 $72
    ld   A, L                                         ;; 02:72f3 $7d
    xor  A, $1b                                       ;; 02:72f4 $ee $1b
    ld   L, A                                         ;; 02:72f6 $6f
    ld   [HL], C                                      ;; 02:72f7 $71
    jp   call_02_72a1_Entity_NotifyActionChanged      ;; 02:72f8 $c3 $a1 $72

call_02_72fb_MapWindow_Update:
; Moves the camera to follow Gex and then works out whether that uncovered a new
; row or column. Three calls and a `ret`; gex2's call_02_715a_MapWindow_Update is
; the same routine
    call call_00_10de_BgMap_UpdateWindowFromPlayerPos ;; 02:72fb $cd $de $10
    call call_02_7305_MapScroll_CheckVertical         ;; 02:72fe $cd $05 $73
    call call_02_7337_MapScroll_CheckHorizontal       ;; 02:7301 $cd $37 $73
    ret                                               ;; 02:7304 $c9

call_02_7305_MapScroll_CheckVertical:
; Did the camera cross a block boundary vertically this frame?
;
; Takes wDBFB_YPositionInMap, saves its low byte for the hardware scroll register,
; and shifts the 16-bit value right three places to get a block row. Compares that
; against wDBFF_BgMap_PrevRow, overwriting it on the way past, and raises
; MAP_SCROLL_UP or MAP_SCROLL_DOWN in wDC20_BgMapLoadingFlags if the two differ.
;
; Nothing is loaded here - the flags are a request, serviced later by
; call_00_11c8_BgMap_LoadDirtyRegions. gex2's call_02_7164_MapScroll_CheckVertical,
; instruction for instruction
    ld   HL, wDBFB_YPositionInMap                     ;; 02:7305 $21 $fb $db
    ld   A, [HL+]                                     ;; 02:7308 $2a
    ld   D, [HL]                                      ;; 02:7309 $56
    ld   [wDADA_BgMap_ScrollYLo], A                   ;; 02:730a $ea $da $da
    srl  D                                            ;; 02:730d $cb $3a
    rra                                               ;; 02:730f $1f
    srl  D                                            ;; 02:7310 $cb $3a
    rra                                               ;; 02:7312 $1f
    srl  D                                            ;; 02:7313 $cb $3a
    rra                                               ;; 02:7315 $1f
    ld   E, A                                         ;; 02:7316 $5f
    ld   HL, wDBFF_BgMap_PrevRow                      ;; 02:7317 $21 $ff $db
    ld   A, [HL]                                      ;; 02:731a $7e
    ld   [HL], E                                      ;; 02:731b $73
    sub  A, E                                         ;; 02:731c $93
    ld   E, A                                         ;; 02:731d $5f
    inc  HL                                           ;; 02:731e $23
    ld   A, [HL]                                      ;; 02:731f $7e
    ld   [HL], D                                      ;; 02:7320 $72
    sbc  A, D                                         ;; 02:7321 $9a
    ld   D, A                                         ;; 02:7322 $57
    jr   C, .jr_02_732f                               ;; 02:7323 $38 $0a
    or   A, E                                         ;; 02:7325 $b3
    ret  Z                                            ;; 02:7326 $c8
    ld   HL, wDC20_BgMapLoadingFlags                  ;; 02:7327 $21 $20 $dc
    ld   A, [HL]                                      ;; 02:732a $7e
    or   A, MAP_SCROLL_UP                             ;; 02:732b $f6 $01
    ld   [HL], A                                      ;; 02:732d $77
    ret                                               ;; 02:732e $c9
.jr_02_732f:
    ld   HL, wDC20_BgMapLoadingFlags                  ;; 02:732f $21 $20 $dc
    ld   A, [HL]                                      ;; 02:7332 $7e
    or   A, MAP_SCROLL_DOWN                           ;; 02:7333 $f6 $02
    ld   [HL], A                                      ;; 02:7335 $77
    ret                                               ;; 02:7336 $c9

call_02_7337_MapScroll_CheckHorizontal:
; The same test on the X axis, plus the wrap-around case gex2 does not have.
;
; On a map whose wDC2A_MapBoundaryIndex is MAP_WRAP_BOUNDARY_INDEX the last column
; joins back onto the first, so the one-column step across that seam looks to the
; subtraction like a jump across the entire map. Both directions are special-cased:
; a move that reads as a huge step left, from column 0 to MAP_WRAP_LAST_COLUMN, is
; a MAP_SCROLL_LEFT, and the mirror of it is a MAP_SCROLL_RIGHT. Everything else
; falls through to the plain comparison.
;
; The two guard tests are why the previous column is kept in BC as well as being
; written back - the routine needs both the old and the new value after the store.
; gex2's call_02_7196_MapScroll_CheckHorizontal has the plain half only
    ld   HL, wDBF9_XPositionInMap                     ;; 02:7337 $21 $f9 $db
    ld   A, [HL+]                                     ;; 02:733a $2a
    ld   D, [HL]                                      ;; 02:733b $56
    ld   [wDAD9_BgMap_ScrollXLo], A                   ;; 02:733c $ea $d9 $da
    srl  D                                            ;; 02:733f $cb $3a
    rra                                               ;; 02:7341 $1f
    srl  D                                            ;; 02:7342 $cb $3a
    rra                                               ;; 02:7344 $1f
    srl  D                                            ;; 02:7345 $cb $3a
    rra                                               ;; 02:7347 $1f
    ld   E, A                                         ;; 02:7348 $5f
    ld   HL, wDBFD_BgMap_PrevColumn                   ;; 02:7349 $21 $fd $db
    ld   A, [HL]                                      ;; 02:734c $7e
    ld   [HL], E                                      ;; 02:734d $73
    ld   C, A                                         ;; 02:734e $4f
    sub  A, E                                         ;; 02:734f $93
    ld   E, A                                         ;; 02:7350 $5f
    inc  HL                                           ;; 02:7351 $23
    ld   A, [HL]                                      ;; 02:7352 $7e
    ld   [HL], D                                      ;; 02:7353 $72
    ld   B, A                                         ;; 02:7354 $47
    sbc  A, D                                         ;; 02:7355 $9a
    ld   D, A                                         ;; 02:7356 $57
    jr   C, .jr_02_737b                               ;; 02:7357 $38 $22
    or   A, E                                         ;; 02:7359 $b3
    ret  Z                                            ;; 02:735a $c8
    ld   A, [wDC2A_MapBoundaryIndex]                  ;; 02:735b $fa $2a $dc
    cp   A, MAP_WRAP_BOUNDARY_INDEX                   ;; 02:735e $fe $00
    jr   NZ, .jr_02_7373                              ;; 02:7360 $20 $11
    ld   HL, wDBFD_BgMap_PrevColumn                   ;; 02:7362 $21 $fd $db
    ld   A, [HL+]                                     ;; 02:7365 $2a
    or   A, [HL]                                      ;; 02:7366 $b6
    jr   NZ, .jr_02_7373                              ;; 02:7367 $20 $0a
    ld   A, C                                         ;; 02:7369 $79
    sub  A, LOW(MAP_WRAP_LAST_COLUMN)                 ;; 02:736a $d6 $ff
    ld   C, A                                         ;; 02:736c $4f
    ld   A, B                                         ;; 02:736d $78
    sbc  A, HIGH(MAP_WRAP_LAST_COLUMN)                ;; 02:736e $de $01
    or   A, C                                         ;; 02:7370 $b1
    jr   Z, .jr_02_7393                               ;; 02:7371 $28 $20
.jr_02_7373:
    ld   HL, wDC20_BgMapLoadingFlags                  ;; 02:7373 $21 $20 $dc
    ld   A, [HL]                                      ;; 02:7376 $7e
    or   A, MAP_SCROLL_LEFT                           ;; 02:7377 $f6 $04
    ld   [HL], A                                      ;; 02:7379 $77
    ret                                               ;; 02:737a $c9
.jr_02_737b:
    ld   A, [wDC2A_MapBoundaryIndex]                  ;; 02:737b $fa $2a $dc
    cp   A, MAP_WRAP_BOUNDARY_INDEX                   ;; 02:737e $fe $00
    jr   NZ, .jr_02_7393                              ;; 02:7380 $20 $11
    ld   A, C                                         ;; 02:7382 $79
    or   A, B                                         ;; 02:7383 $b0
    jr   NZ, .jr_02_7393                              ;; 02:7384 $20 $0d
    ld   HL, wDBFD_BgMap_PrevColumn                   ;; 02:7386 $21 $fd $db
    ld   A, [HL+]                                     ;; 02:7389 $2a
    sub  A, LOW(MAP_WRAP_LAST_COLUMN)                 ;; 02:738a $d6 $ff
    ld   C, A                                         ;; 02:738c $4f
    ld   A, [HL]                                      ;; 02:738d $7e
    sbc  A, HIGH(MAP_WRAP_LAST_COLUMN)                ;; 02:738e $de $01
    or   A, C                                         ;; 02:7390 $b1
    jr   Z, .jr_02_7373                               ;; 02:7391 $28 $e0
.jr_02_7393:
    ld   HL, wDC20_BgMapLoadingFlags                  ;; 02:7393 $21 $20 $dc
    ld   A, [HL]                                      ;; 02:7396 $7e
    or   A, MAP_SCROLL_RIGHT                          ;; 02:7397 $f6 $08
    ld   [HL], A                                      ;; 02:7399 $77
    ret                                               ;; 02:739a $c9
