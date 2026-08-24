; ==================================================================
; Bank 0. The entity helper library: the routines every entity action in bank 2
; and every collision check in bank 3 is built out of. Nothing here decides what
; an entity does - it is all "move me", "clamp me", "where is Gex", "am I still
; alive" - and almost every routine operates on THE CURRENT ENTITY rather than
; taking one as a parameter.
;
; What "the current entity" means
; -------------------------------
; There are eight entity slots of $20 bytes each at wD800_EntityMemory. Slot 0 is
; always Gex; slots $20..$E0 are everything else. wDA00_CurrentEntityAddrLo holds
; the low byte of the slot base being updated right now, so a field of the current
; entity is just `HIGH(wD800_EntityMemory)` in H and `wDA00 | ENTITY_FIELD_*` in L.
; That is exactly what the LOAD_OBJ_FIELD_TO_HL macro expands to, and it is why so
; many routines here are four instructions long.
;
; Two other tables are indexed off the same byte:
;
;   wDA01_EntityListIndexesForCurrentEntities  slot -> which entry of the level's
;       entity list is living in it (1-based). Reached with
;       `rlca rlca rlca / and $07`, which turns $20,$40,... into 1,2,...
;   wDA1C_EntityBoundingBoxXMax and friends    slot -> its 16-byte block of
;       spawn-time constants: patrol bounds and spawn position. Reached with
;       `rrca / and $70`, which turns $20,$40,... into $10,$20,...
;
; Those two idioms appear a dozen times each below and are never factored out.
;
; Subpixel movement
; -----------------
; Velocities are 1/16 of a pixel per frame and live in a single signed byte. A
; mover adds the velocity into an accumulator field (ENTITY_FIELD_XVEL_RELATED for
; X, ENTITY_FIELD_YVEL_RELATED for Y), keeps the low nibble as the unpaid fraction,
; and arithmetic-shifts the rest right four times to get whole pixels. The
; sign-extension that follows every one of those shifts is always spelled
;
;     cp A, $80 / ld A, $FF / adc A, $00
;
; which leaves B = $FF for a negative delta and $00 for a positive one, so BC is
; the signed 16-bit step. Recognising that five-instruction phrase is most of what
; it takes to read this file.
;
; Falling
; -------
; call_00_244a_Entity_ApplyGravityAndMoveY_Clamped and
; call_00_2475_Entity_ApplyGravityMoveY_WithFloorCollision both subtract
; ENTITY_GRAVITY_PER_FRAME from YVEL and clamp at ENTITY_TERMINAL_YVEL, and then
; differ by one `cpl / inc A`: the first negates the result and the second does
; not, so for the same stored YVEL they move the entity in OPPOSITE directions.
; gex2 has the same pair, at $30AF and $30DA, with the same trap.
;
; Map of this file
; ----------------
;   $21EF-$233D  the level's persistent entity-list state and trigger scratchpad
;   $233E-$240F  patterned movement along the canned arc table at $23B4
;   $2410-$2616  facing, gravity, subpixel movers and patrol turnarounds
;   $2617-$26C8  clamping against the patrol bounds
;   $26C9-$2765  carrying and pushing Gex
;   $2766-$2889  spawn position, camera-relative placement, the bounds getters
;   $288A-$299E  the one-line field accessors
;   $299F-$2A97  facing tests, slot searches and "where is Gex"
;   $2A98-$2C42  slot allocation, removal, the fly coin drop, palettes
;   $2C43-$2CBE  particle bursts
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank00_entity_utils.asm
; ------------------------------------------------------------------
; This is the file that changed least between the two games. The slot layout, the
; `wDA00 | field` addressing, the subpixel movers, the sign-extension idiom, the
; bounds getters, the one-line accessors and the "clear all slots / clear slot /
; deactivate self" trio are all recognisably the same code, and several routines
; are instruction-for-instruction identical to their gex2 counterparts. The
; differences that matter:
;
;   bounds        gex2 stores each patrol bound as ONE byte in block units and
;                 multiplies by 32 on every read, adding $30 to the low bound and
;                 subtracting $10 from the high one. gex3 stores all four as
;                 16-bit pixel positions computed once at spawn, so its getters
;                 are a table read and nothing else. Same four names either way -
;                 Entity_Get{Min,Max}{X,Y}Bound - and the same trap that MaxY is
;                 the floor because larger Y is further down
;   list state    gex2's wD000_EntityFlags is a three-value enum: absent, placed,
;                 never again. gex3's wD700_EntityFlags is a bitfield with a spawn
;                 action id in the low nibble, which is how a pressed tv button or
;                 a taken remote stays that way when you leave the map and come
;                 back. gex2 does not need this because a gex2 level is one map
;   never again   gex2 spells it $FF (ENTITY_LIST_FLAG_NEVER_AGAIN) and gex3
;                 spells it $00, so the two games' "is this entry dead" tests look
;                 like opposites even though they mean the same thing
;   fly coins     gex3 defeated enemies leave a coin behind:
;                 call_00_2ba9_Entity_MarkRespawnAsFlyCoin flips the list entry to
;                 ENTITY_LIST_FLAGS_DEFEATED and
;                 call_00_2bbe_Entity_TurnIntoFlyCoin rebuilds the live slot as
;                 ENTITY_FLY_COIN_SPAWN in place. gex2 has no equivalent -
;                 Entity_MarkNeverRespawn is where a defeated gex2 enemy ends
;   palettes      gex3 gives each slot its own eight-byte CGB palette through
;                 wDAAE_EntityPaletteIds and wDD2A_EntityPalettes. gex2, which has
;                 to run on a DMG too, only picks an OBJ palette number
;                 (Entity_SetOamAttrBase); gex3 has no such routine
;   triggers      the wDCB1_LevelTriggerBuffer helpers at $22D4-$230E are gex3
;                 only, and so is call_00_230f_Entity_GetParameterIntoC, which
;                 reads a spawn record back out of the entity list bank at
;                 runtime. gex2 entities carry what they need in their own fields
;   particles     the burst slots at $2C43-$2CBE have no gex2 counterpart
;   same helper   Entity_CheckAnimationEnded is the most-called routine in both
;                 games, but the flag moved: gex2 keeps it in SPRITE_FLAGS and
;                 gex3 in ACTION_STATE_FLAGS, so the gex3 constant is
;                 ACTION_STATE_ANIM_ENDED_BIT rather than SPRITE_FLAG_ANIM_ENDED_BIT
;   absent here   gex2's Entity_SaveWorldState / Entity_RestoreWorldState (the
;                 cutscene preview bracket), Entity_IsPlayerStandingOnSelf and the
;                 three tv/remote unlock predicates all live elsewhere in gex3 or
;                 do not exist. Conversely gex2 has no
;                 equivalent of the arc table at $23B4, which is a canned
;                 quarter-circle several gex3 enemies fly along
; ==================================================================

call_00_21ef_Entity_PlayRemoteSFX:
; Plays SFX_REMOTE and falls straight through into
; call_00_21f6_Entity_MarkTVButtonPressed - there is no `ret`. BC is preserved
; across the call because the routine below needs C
    push BC                                           ;; 00:21ef $c5
    ld   A, SFX_REMOTE                                ;; 00:21f0 $3e $1e
    call call_00_0ff5_QueueSFX                        ;; 00:21f2 $cd $f5 $0f
    pop  BC                                           ;; 00:21f5 $c1

call_00_21f6_Entity_MarkTVButtonPressed:
; "TV button C has been pressed" - written from outside the entity, into the
; level's entity list state, so that the button is still pressed when the player
; leaves the map and comes back.
;
; Walks the level's entity list in wDC16_EntityListBank looking for an
; ENTITY_TV_BUTTON whose spawn parameter (record byte $0D) equals C, counting list
; entries in B as it goes, and then writes the low nibble of TWO wD700_EntityFlags
; entries: this button's, and the one after it (`inc E`), which is the tv itself.
;
; The value written is ENTITY_LIST_STATE_TV_BUTTON_ON normally, or
; ENTITY_LIST_STATE_TV_BUTTON_LIT when the level's progress byte in
; wDC5C_ProgressFlags already has the bit this button owns - looked up from
; .data_00_225c_TVButtonProgressMasks - and the level is not the hub. So a button
; whose reward has already been claimed comes back in a different state from one
; that has only just been hit.
;
; The high nibble is preserved by the usual `and $F0 / or value` pair, so
; ENTITY_LIST_FLAG_PLACED and friends survive.
;
; gex2's counterpart is a reader rather than a writer - Entity_CheckTVButtonEnabled
; asks the block-patch tables whether a button is on. gex3 has to store the answer
; because its levels are made of several maps
    push BC                                           ;; 00:21f6 $c5
    ld   A, [wDC16_EntityListBank]                    ;; 00:21f7 $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:21fa $cd $ee $0e
    pop  BC                                           ;; 00:21fd $c1
    ld   HL, wDC17_EntityListBankOffset               ;; 00:21fe $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:2201 $2a
    ld   H, [HL]                                      ;; 00:2202 $66
    ld   L, A                                         ;; 00:2203 $6f
    ld   A, [HL]                                      ;; 00:2204 $7e
    cp   A, ENTITY_LIST_TERMINATOR                    ;; 00:2205 $fe $ff
    jp   Z, call_00_0f08_RestoreBank                  ;; 00:2207 $ca $08 $0f
    ld   B, $01                                       ;; 00:220a $06 $01
.jr_00_220c:
    push HL                                           ;; 00:220c $e5
    ld   A, [HL]                                      ;; 00:220d $7e
    cp   A, ENTITY_TV_BUTTON                          ;; 00:220e $fe $11
    jr   NZ, .jr_00_221a                              ;; 00:2210 $20 $08
    ld   DE, $0d                                      ;; 00:2212 $11 $0d $00
    add  HL, DE                                       ;; 00:2215 $19
    ld   A, [HL]                                      ;; 00:2216 $7e
    cp   A, C                                         ;; 00:2217 $b9
    jr   Z, .jr_00_2228                               ;; 00:2218 $28 $0e
.jr_00_221a:
    inc  B                                            ;; 00:221a $04
    pop  HL                                           ;; 00:221b $e1
    ld   DE, $10                                      ;; 00:221c $11 $10 $00
    add  HL, DE                                       ;; 00:221f $19
    ld   A, [HL]                                      ;; 00:2220 $7e
    cp   A, ENTITY_LIST_TERMINATOR                    ;; 00:2221 $fe $ff
    jr   NZ, .jr_00_220c                              ;; 00:2223 $20 $e7
    jp   call_00_0f08_RestoreBank                     ;; 00:2225 $c3 $08 $0f
.jr_00_2228:
    pop  HL                                           ;; 00:2228 $e1
    ld   E, B                                         ;; 00:2229 $58
    ld   D, HIGH(wD700_EntityFlags)                   ;; 00:222a $16 $d7
    ld   A, [DE]                                      ;; 00:222c $1a
    and  A, ENTITY_LIST_FLAG_MASK                     ;; 00:222d $e6 $f0
    or   A, ENTITY_LIST_STATE_TV_BUTTON_ON            ;; 00:222f $f6 $01
    ld   [DE], A                                      ;; 00:2231 $12
    inc  E                                            ;; 00:2232 $1c
    ld   L, C                                         ;; 00:2233 $69
    ld   H, $00                                       ;; 00:2234 $26 $00
    ld   BC, .data_00_225c_TVButtonProgressMasks      ;; 00:2236 $01 $5c $22
    add  HL, BC                                       ;; 00:2239 $09
    ld   A, [HL]                                      ;; 00:223a $7e
    push AF                                           ;; 00:223b $f5
    ld   HL, wDC1E_CurrentLevelID                     ;; 00:223c $21 $1e $dc
    ld   L, [HL]                                      ;; 00:223f $6e
    ld   H, $00                                       ;; 00:2240 $26 $00
    ld   BC, wDC5C_ProgressFlags                      ;; 00:2242 $01 $5c $dc
    add  HL, BC                                       ;; 00:2245 $09
    pop  AF                                           ;; 00:2246 $f1
    ld   C, ENTITY_LIST_STATE_TV_BUTTON_ON            ;; 00:2247 $0e $01
    and  A, [HL]                                      ;; 00:2249 $a6
    jr   Z, .jr_00_2254                               ;; 00:224a $28 $08
    ld   A, [wDC1E_CurrentLevelID]                    ;; 00:224c $fa $1e $dc
    and  A, A                                         ;; 00:224f $a7
    jr   Z, .jr_00_2254                               ;; 00:2250 $28 $02
    ld   C, ENTITY_LIST_STATE_TV_BUTTON_LIT           ;; 00:2252 $0e $02
.jr_00_2254:
    ld   A, [DE]                                      ;; 00:2254 $1a
    and  A, ENTITY_LIST_FLAG_MASK                     ;; 00:2255 $e6 $f0
    or   A, C                                         ;; 00:2257 $b1
    ld   [DE], A                                      ;; 00:2258 $12
    jp   call_00_0f08_RestoreBank                     ;; 00:2259 $c3 $08 $0f
.data_00_225c_TVButtonProgressMasks:
; Which bit of the level's wDC5C_ProgressFlags byte each tv button owns, indexed by
; the button's spawn parameter
    db   $00, $01, $02, $04                           ;; 00:225c ?...

call_00_2260_Entity_MarkRemoteCollected:
; The same walk as above for ENTITY_TV_REMOTE, writing
; ENTITY_LIST_STATE_REMOTE_TAKEN into the matching list entry so the remote does
; not come back. Only one entry this time, and no progress-flag lookup
    push BC                                           ;; 00:2260 $c5
    ld   A, [wDC16_EntityListBank]                    ;; 00:2261 $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:2264 $cd $ee $0e
    pop  BC                                           ;; 00:2267 $c1
    ld   HL, wDC17_EntityListBankOffset               ;; 00:2268 $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:226b $2a
    ld   H, [HL]                                      ;; 00:226c $66
    ld   L, A                                         ;; 00:226d $6f
    ld   B, $01                                       ;; 00:226e $06 $01
.jr_00_2270:
    push HL                                           ;; 00:2270 $e5
    ld   A, [HL]                                      ;; 00:2271 $7e
    cp   A, ENTITY_TV_REMOTE                          ;; 00:2272 $fe $12
    jr   NZ, .jr_00_227e                              ;; 00:2274 $20 $08
    ld   DE, $0d                                      ;; 00:2276 $11 $0d $00
    add  HL, DE                                       ;; 00:2279 $19
    ld   A, [HL]                                      ;; 00:227a $7e
    cp   A, C                                         ;; 00:227b $b9
    jr   Z, .jr_00_228c                               ;; 00:227c $28 $0e
.jr_00_227e:
    inc  B                                            ;; 00:227e $04
    pop  HL                                           ;; 00:227f $e1
    ld   DE, $10                                      ;; 00:2280 $11 $10 $00
    add  HL, DE                                       ;; 00:2283 $19
    ld   A, [HL]                                      ;; 00:2284 $7e
    cp   A, ENTITY_LIST_TERMINATOR                    ;; 00:2285 $fe $ff
    jr   NZ, .jr_00_2270                              ;; 00:2287 $20 $e7
    jp   call_00_0f08_RestoreBank                     ;; 00:2289 $c3 $08 $0f
.jr_00_228c:
    pop  HL                                           ;; 00:228c $e1
    ld   E, B                                         ;; 00:228d $58
    ld   D, HIGH(wD700_EntityFlags)                   ;; 00:228e $16 $d7
    ld   A, [DE]                                      ;; 00:2290 $1a
    and  A, ENTITY_LIST_FLAG_MASK                     ;; 00:2291 $e6 $f0
    or   A, ENTITY_LIST_STATE_REMOTE_TAKEN            ;; 00:2293 $f6 $04
    ld   [DE], A                                      ;; 00:2295 $12
    jp   call_00_0f08_RestoreBank                     ;; 00:2296 $c3 $08 $0f

call_00_2299_Entity_SetListState:
; The from-the-inside version: writes C into the low nibble of THIS entity's
; wD700_EntityFlags entry, leaving the flags nibble alone.
;
; The two-step lookup here is the one used all over this file - slot base to list
; index through wDA01_EntityListIndexesForCurrentEntities, list index into
; wD700_EntityFlags - and the `rlca rlca rlca / and $07` is just $20,$40,... turned
; into 0,1,2,...
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2299 $fa $00 $da
    rlca                                              ;; 00:229c $07
    rlca                                              ;; 00:229d $07
    rlca                                              ;; 00:229e $07
    and  A, $07                                       ;; 00:229f $e6 $07
    ld   L, A                                         ;; 00:22a1 $6f
    ld   H, $00                                       ;; 00:22a2 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:22a4 $11 $01 $da
    add  HL, DE                                       ;; 00:22a7 $19
    ld   L, [HL]                                      ;; 00:22a8 $6e
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:22a9 $26 $d7
    ld   A, [HL]                                      ;; 00:22ab $7e
    and  A, ENTITY_LIST_FLAG_MASK                     ;; 00:22ac $e6 $f0
    or   A, C                                         ;; 00:22ae $b1
    ld   [HL], A                                      ;; 00:22af $77
    ret                                               ;; 00:22b0 $c9

call_00_22b1_Entity_SetListStateAndAction:
; Same lookup, but this one compares first: if the stored state already equals C it
; returns, and otherwise it does NOT write the nibble at all - it calls
; call_02_72ac_SetEntityAction with C and lets the action change speak for itself.
;
; Worth reading twice, because the name the routine had before said it wrote the
; flags. It does not; only call_00_2299_Entity_SetListState does that
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:22b1 $fa $00 $da
    rlca                                              ;; 00:22b4 $07
    rlca                                              ;; 00:22b5 $07
    rlca                                              ;; 00:22b6 $07
    and  A, $07                                       ;; 00:22b7 $e6 $07
    ld   L, A                                         ;; 00:22b9 $6f
    ld   H, $00                                       ;; 00:22ba $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:22bc $11 $01 $da
    add  HL, DE                                       ;; 00:22bf $19
    ld   L, [HL]                                      ;; 00:22c0 $6e
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:22c1 $26 $d7
    ld   A, [HL]                                      ;; 00:22c3 $7e
    and  A, ENTITY_LIST_STATE_MASK                    ;; 00:22c4 $e6 $0f
    cp   A, C                                         ;; 00:22c6 $b9
    ret  Z                                            ;; 00:22c7 $c8
    farcall call_02_72ac_SetEntityAction
    ret                                               ;; 00:22d3 $c9
    
call_00_22d4_Entity_CheckTriggerFlag:
; The four routines here are a tiny scratchpad the level shares between entities:
; LEVEL_TRIGGER_COUNT bytes at wDCB1_LevelTriggerBuffer, indexed by an entity's
; spawn parameter, which is how a switch tells a door it has been thrown.
;
; This one reads: Z if the entity's slot is zero, NZ if it is set. Unlike the three
; below it does not range-check the parameter first
    call call_00_230f_Entity_GetParameterIntoC
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    ld   a,[hl]
    and  a
    ret  

call_00_22e0_Entity_IncrementTriggerFlag:
; Adds one to this entity's trigger slot, ignoring the request if the entity's
; parameter is not below LEVEL_TRIGGER_COUNT. Used for the doors that need several
; switches rather than one
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    cp   a,LEVEL_TRIGGER_COUNT
    ret  nc
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    inc  [hl]
    ret  

call_00_22ef_Entity_SetTriggerActive:
; Stores LEVEL_TRIGGER_SET in this entity's trigger slot
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    cp   a,LEVEL_TRIGGER_COUNT
    ret  nc
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    ld   [hl],LEVEL_TRIGGER_SET
    ret  

call_00_22ff_Entity_SetTriggerInactive:
; Stores LEVEL_TRIGGER_CLEAR in this entity's trigger slot
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,c
    cp   a,LEVEL_TRIGGER_COUNT
    ret  nc
    ld   b,$00
    ld   hl,wDCB1_LevelTriggerBuffer
    add  hl,bc
    ld   [hl],LEVEL_TRIGGER_CLEAR
    ret  

call_00_230f_Entity_GetParameterIntoC:
; C = this entity's spawn parameter, byte $0D of its record in the level's entity
; list.
;
; The record lives in a banked table, so this switches to wDC16_EntityListBank,
; walks from wDC17_EntityListBankOffset by (list index - 1) * 16, reads the byte,
; and switches back - pushing BC across call_00_0f08_RestoreBank because that
; routine does not preserve it.
;
; gex3 only. A gex2 entity keeps everything it needs in its own $20 bytes; gex3
; goes back to the spawn record at runtime, which is why so many helpers here start
; with a bank switch
    ld   A, [wDC16_EntityListBank]                    ;; 00:230f $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:2312 $cd $ee $0e
    ld   HL, wDC17_EntityListBankOffset               ;; 00:2315 $21 $17 $dc
    ld   C, [HL]                                      ;; 00:2318 $4e
    inc  HL                                           ;; 00:2319 $23
    ld   B, [HL]                                      ;; 00:231a $46
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:231b $fa $00 $da
    rlca                                              ;; 00:231e $07
    rlca                                              ;; 00:231f $07
    rlca                                              ;; 00:2320 $07
    and  A, $07                                       ;; 00:2321 $e6 $07
    ld   L, A                                         ;; 00:2323 $6f
    ld   H, $00                                       ;; 00:2324 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:2326 $11 $01 $da
    add  HL, DE                                       ;; 00:2329 $19
    ld   L, [HL]                                      ;; 00:232a $6e
    dec  L                                            ;; 00:232b $2d
    ld   H, $00                                       ;; 00:232c $26 $00
    add  HL, HL                                       ;; 00:232e $29
    add  HL, HL                                       ;; 00:232f $29
    add  HL, HL                                       ;; 00:2330 $29
    add  HL, HL                                       ;; 00:2331 $29
    add  HL, BC                                       ;; 00:2332 $09
    ld   DE, $0d                                      ;; 00:2333 $11 $0d $00
    add  HL, DE                                       ;; 00:2336 $19
    ld   C, [HL]                                      ;; 00:2337 $4e
    push BC                                           ;; 00:2338 $c5
    call call_00_0f08_RestoreBank                     ;; 00:2339 $cd $08 $0f
    pop  BC                                           ;; 00:233c $c1
    ret                                               ;; 00:233d $c9

call_00_233e_Entity_MoveAlongArcTable:
; Flies the entity along a canned quarter-circle instead of integrating a velocity.
;
; ENTITY_FIELD_XVEL is reused as a step counter: it advances one per frame and
; wraps at $2E, and on the wrap it bumps ENTITY_FIELD_XVEL_RELATED - the quadrant -
; and clears bit 2 of it, so the quadrant cycles 0,1,2,3,0,... The quadrant then
; decides how the (dx, dy) pair read out of .data_00_23b4_ArcTable is signed:
;
;   0   +dy, +dx      1   +dx, -dy
;   2   -dx, -dy      3 (default) -dx, +dy
;
; The signed pair is added to the entity's SPAWN position, not its current one, so
; the path is absolute and cannot drift - the entity traces the same loop forever.
; That also means anything else that writes XPOS or YPOS while this is running will
; be undone on the next frame
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
    ld   de,.data_00_23b4_ArcTable
    add  hl,de
    cp   a,$00
    jr   z,.jr_00_2381
    cp   a,$01
    jr   z,.jr_00_2379
    cp   a,$02
    jr   z,.jr_00_236f
    ldi  a,[hl]
    cpl  
    inc  a
    ld   c,a
    ld   e,[hl]
    jr   .jr_00_2384
.jr_00_236f:
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
.data_00_23b4_ArcTable:
; $2E (dy, dx) pairs tracing a quarter circle, walked by
; call_00_233e_Entity_MoveAlongArcTable and mirrored into the other three quadrants
; by the sign rules above. No gex2 equivalent
    db   $00, $e0                                     ;; 00:23ae ????????
    db   $01, $e0, $02, $e0, $03, $e0, $04, $e0       ;; 00:23b6 ????????
    db   $05, $e0, $06, $e1, $07, $e1, $08, $e1       ;; 00:23be ????????
    db   $09, $e1, $0a, $e2, $0b, $e2, $0c, $e2       ;; 00:23c6 ????????
    db   $0d, $e3, $0e, $e3, $0f, $e4, $10, $e5       ;; 00:23ce ????????
    db   $11, $e5, $12, $e6, $13, $e7, $14, $e8       ;; 00:23d6 ????????
    db   $15, $e8, $16, $e9, $17, $ea, $17, $eb       ;; 00:23de ????????
    db   $18, $ec, $19, $ed, $1a, $ee, $1a, $ef       ;; 00:23e6 ????????
    db   $1b, $f0, $1b, $f1, $1c, $f2, $1c, $f3       ;; 00:23ee ????????
    db   $1d, $f4, $1d, $f5, $1d, $f6, $1e, $f7       ;; 00:23f6 ????????
    db   $1e, $f8, $1e, $f9, $1e, $fa, $1f, $fb       ;; 00:23fe ????????
    db   $1f, $fc, $1f, $fd, $1f, $fe, $1f, $ff       ;; 00:2406 ????????
    db   $1f, $00

call_00_2410_Entity_FaceTowardsPlayer:
; Points the entity at Gex: ENTITY_FACING_LEFT if he is to the left, otherwise
; ENTITY_FACING_RIGHT.
;
; The `xor $02` on L is the trick worth noticing - L is at ENTITY_FIELD_XPOS + 1
; ($0F) by then, and $0F xor $02 = $0D = ENTITY_FIELD_FACING_DIRECTION, so it walks
; to the facing byte without reloading HL. The same idiom appears a dozen times
; below with different constants.
;
; Instruction-for-instruction gex2's call_00_36bd_Entity_FaceTowardsPlayer
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
; The same routine with the two facing constants swapped. gex2's
; call_00_36da_Entity_FaceAwayFromPlayer
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

call_00_244a_Entity_ApplyGravityAndMoveY_Clamped:
; One frame of falling. Subtracts ENTITY_GRAVITY_PER_FRAME from YVEL, clamps at
; ENTITY_TERMINAL_YVEL once it has gone negative, NEGATES the result, shifts it
; down four places into whole pixels and jumps into call_00_250d_Entity_MoveY.
;
; The negation is the whole difference between this and
; call_00_2475_Entity_ApplyGravityMoveY_WithFloorCollision below: here a positive
; YVEL moves the entity UP the screen. Note also that this one does not touch the
; subpixel accumulator - the fraction is simply discarded each frame.
;
; gex2's call_00_30af_Entity_ApplyGravityAndMoveY_Clamped, same instructions
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   A, [HL]                                      ;; 00:2452 $7e
    sub  A, ENTITY_GRAVITY_PER_FRAME                  ;; 00:2453 $d6 $02
    bit  7, A                                         ;; 00:2455 $cb $7f
    jr   Z, .jr_00_245f                               ;; 00:2457 $28 $06
    cp   A, ENTITY_TERMINAL_YVEL                      ;; 00:2459 $fe $c0
    jr   NC, .jr_00_245f                              ;; 00:245b $30 $02
    ld   A, ENTITY_TERMINAL_YVEL                      ;; 00:245d $3e $c0
.jr_00_245f:
    ld   [HL], A                                      ;; 00:245f $77
    cpl                                               ;; 00:2460 $2f
    inc  A                                            ;; 00:2461 $3c
    sra  A                                            ;; 00:2462 $cb $2f
    sra  A                                            ;; 00:2464 $cb $2f
    sra  A                                            ;; 00:2466 $cb $2f
    sra  A                                            ;; 00:2468 $cb $2f
    ld   C, A                                         ;; 00:246a $4f
    cp   A, $80                                       ;; 00:246b $fe $80
    ld   A, $ff                                       ;; 00:246d $3e $ff
    adc  A, $00                                       ;; 00:246f $ce $00
    ld   B, A                                         ;; 00:2471 $47
    jp   call_00_250d_Entity_MoveY                    ;; 00:2472 $c3 $0d $25

call_00_2475_Entity_ApplyGravityMoveY_WithFloorCollision:
; The other half of the pair: same gravity, same clamp, but no negation, so a
; positive YVEL moves the entity DOWN. It also adds the delta to YPOS inline rather
; than calling the mover, and then does the landing check.
;
; The floor is the entity's SPAWN Y (wDA26_EntityInitialYPos), not a bounding-box
; bound, so this is the helper for things that hop in place and come back to rest
; where they started. On landing it snaps YPOS to the spawn Y and zeroes YVEL - the
; `xor $0D` walks L from YPOS+1 ($11) to YVEL ($1D).
;
;   carry SET    still above the floor - airborne this frame
;   carry CLEAR  just snapped to the floor - it has landed
;
; That convention is why so many bank 2 hop actions are literally "call this,
; ret c". gex2's equivalent is call_00_30da_Entity_ApplyGravityMoveY_WithFloorCollision,
; which clamps to Entity_GetMinYBound instead
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   a,[hl]
    sub  a,ENTITY_GRAVITY_PER_FRAME
    bit  $7,a
    jr   z,.jr_00_248a
    cp   a,ENTITY_TERMINAL_YVEL
    jr   nc,.jr_00_248a
    ld   a,ENTITY_TERMINAL_YVEL
.jr_00_248a:
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

call_00_24c0_Entity_ApplyXVelocity_Subpixel:
; The plain X mover. Adds XVEL into the ENTITY_FIELD_XVEL_RELATED accumulator,
; keeps the low nibble there as the unpaid fraction, shifts the rest into whole
; pixels, sign-extends into B and falls through into call_00_24df_Entity_MoveX.
;
; gex2 does both axes at once in call_00_3559_Entity_ApplyVelocityXY_SubpixelBoth;
; gex3 split it in two so an action can move on one axis only
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   A, [HL+]                                     ;; 00:24c8 $2a
    add  A, [HL]                                      ;; 00:24c9 $86
    ld   C, A                                         ;; 00:24ca $4f
    and  A, ENTITY_SUBPIXEL_MASK                      ;; 00:24cb $e6 $0f
    ld   [HL], A                                      ;; 00:24cd $77
    ld   A, C                                         ;; 00:24ce $79
    sra  A                                            ;; 00:24cf $cb $2f
    sra  A                                            ;; 00:24d1 $cb $2f
    sra  A                                            ;; 00:24d3 $cb $2f
    sra  A                                            ;; 00:24d5 $cb $2f
    ld   C, A                                         ;; 00:24d7 $4f
    cp   A, $80                                       ;; 00:24d8 $fe $80
    ld   A, $ff                                       ;; 00:24da $3e $ff
    adc  A, $00                                       ;; 00:24dc $ce $00
    ld   B, A                                         ;; 00:24de $47
call_00_24df_Entity_MoveX:
; Adds the signed 16-bit BC to ENTITY_FIELD_XPOS. gex2's call_00_37c9_Entity_MoveX
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   A, [HL]                                      ;; 00:24e7 $7e
    add  A, C                                         ;; 00:24e8 $81
    ld   [HL+], A                                     ;; 00:24e9 $22
    ld   A, [HL]                                      ;; 00:24ea $7e
    adc  A, B                                         ;; 00:24eb $88
    ld   [HL], A                                      ;; 00:24ec $77
    ret                                               ;; 00:24ed $c9

call_00_24ee_Entity_ApplyYVelocity_Subpixel:
; The Y twin of call_00_24c0_Entity_ApplyXVelocity_Subpixel, accumulating into the
; byte after YVEL and falling through into call_00_250d_Entity_MoveY. No clamping
; and no floor check - this is for things that are steered rather than dropped
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   A, [HL+]                                     ;; 00:24f6 $2a
    add  A, [HL]                                      ;; 00:24f7 $86
    ld   C, A                                         ;; 00:24f8 $4f
    and  A, ENTITY_SUBPIXEL_MASK                      ;; 00:24f9 $e6 $0f
    ld   [HL], A                                      ;; 00:24fb $77
    ld   A, C                                         ;; 00:24fc $79
    sra  A                                            ;; 00:24fd $cb $2f
    sra  A                                            ;; 00:24ff $cb $2f
    sra  A                                            ;; 00:2501 $cb $2f
    sra  A                                            ;; 00:2503 $cb $2f
    ld   C, A                                         ;; 00:2505 $4f
    cp   A, $80                                       ;; 00:2506 $fe $80
    ld   A, $ff                                       ;; 00:2508 $3e $ff
    adc  A, $00                                       ;; 00:250a $ce $00
    ld   B, A                                         ;; 00:250c $47
call_00_250d_Entity_MoveY:
; Adds the signed 16-bit BC to ENTITY_FIELD_YPOS. gex2's call_00_37d8_Entity_MoveY
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   A, [HL]                                      ;; 00:2515 $7e
    add  A, C                                         ;; 00:2516 $81
    ld   [HL+], A                                     ;; 00:2517 $22
    ld   A, [HL]                                      ;; 00:2518 $7e
    adc  A, B                                         ;; 00:2519 $88
    ld   [HL], A                                      ;; 00:251a $77
    ret                                               ;; 00:251b $c9

call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked:
; The standard "pace back and forth", and the tail of most walking enemies in
; bank02_entity_actions.asm. Moves X one frame with
; call_00_254a_Entity_MoveXByFacingSpeed, then compares the new X against this
; entity's patrol span and turns it round at either end:
;
;   past wDA1C_EntityBoundingBoxXMax   face ENTITY_FACING_LEFT
;   past wDA1E_EntityBoundingBoxXMin   face ENTITY_FACING_RIGHT
;   inside                             A = 0, Z set, nothing changed
;
; When it does turn, it returns the comparison of the OLD facing against the new
; one, so NZ means "I just turned round this frame" and the caller can start a turn
; animation. gex2's call_00_36f7_Entity_MoveXByFacingMomentum_BoundsChecked
    call call_00_254a_Entity_MoveXByFacingSpeed       ;; 00:251c $cd $4a $25
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:251f $fa $00 $da
    rrca                                              ;; 00:2522 $0f
    and  A, $70                                       ;; 00:2523 $e6 $70
    ld   L, A                                         ;; 00:2525 $6f
    ld   H, $00                                       ;; 00:2526 $26 $00
    ld   BC, wDA1C_EntityBoundingBoxXMax              ;; 00:2528 $01 $1c $da
    add  HL, BC                                       ;; 00:252b $09
    ld   C, ENTITY_FACING_LEFT                        ;; 00:252c $0e $20
    ld   A, [HL+]                                     ;; 00:252e $2a
    sub  A, E                                         ;; 00:252f $93
    ld   A, [HL+]                                     ;; 00:2530 $2a
    sbc  A, D                                         ;; 00:2531 $9a
    jr   C, .jr_00_253e                               ;; 00:2532 $38 $0a
    ld   C, ENTITY_FACING_RIGHT                       ;; 00:2534 $0e $00
    ld   A, [HL+]                                     ;; 00:2536 $2a
    sub  A, E                                         ;; 00:2537 $93
    ld   A, [HL]                                      ;; 00:2538 $7e
    sbc  A, D                                         ;; 00:2539 $9a
    jr   NC, .jr_00_253e                              ;; 00:253a $30 $02
    xor  A, A                                         ;; 00:253c $af
    ret                                               ;; 00:253d $c9
.jr_00_253e:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                      ;; 00:2546 $7e
    ld   [HL], C                                      ;; 00:2547 $71
    cp   A, C                                         ;; 00:2548 $b9
    ret                                               ;; 00:2549 $c9

call_00_254a_Entity_MoveXByFacingSpeed:
; Moves X by XVEL in the direction ENTITY_FIELD_FACING_DIRECTION bit 5 says, with
; the usual subpixel accumulator, and leaves the new 16-bit X in DE for the caller
; to test.
;
; It also stashes the whole-pixel delta in wDA13_EntityXVelocityDelta, which is how
; the platform-carrying code downstream knows how far to drag Gex.
;
; gex2 splits the same work between call_00_3442_Entity_MoveXByFacingSpeed and
; call_00_3251_Entity_UpdateFacingMomentumAndMoveX
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   C, [HL]                                      ;; 00:2552 $4e
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   A, [HL+]                                     ;; 00:255b $2a
    bit  5, C                                         ;; 00:255c $cb $69
    jr   Z, .jr_00_2562                               ;; 00:255e $28 $02
    cpl                                               ;; 00:2560 $2f
    inc  A                                            ;; 00:2561 $3c
.jr_00_2562:
    add  A, [HL]                                      ;; 00:2562 $86 ; ENTITY_FIELD_XVEL_RELATED
    ld   C, A                                         ;; 00:2563 $4f
    and  A, ENTITY_SUBPIXEL_MASK                      ;; 00:2564 $e6 $0f
    ld   [HL], A                                      ;; 00:2566 $77
    ld   A, C                                         ;; 00:2567 $79
    sra  A                                            ;; 00:2568 $cb $2f
    sra  A                                            ;; 00:256a $cb $2f
    sra  A                                            ;; 00:256c $cb $2f
    sra  A                                            ;; 00:256e $cb $2f
    ld   C, A                                         ;; 00:2570 $4f
    ld   [wDA13_EntityXVelocityDelta], A              ;; 00:2571 $ea $13 $da
    cp   A, $80                                       ;; 00:2574 $fe $80
    ld   A, $ff                                       ;; 00:2576 $3e $ff
    adc  A, $00                                       ;; 00:2578 $ce $00
    ld   B, A                                         ;; 00:257a $47
    ld   A, L                                         ;; 00:257b $7d
    xor  A, $12                                       ;; 00:257c $ee $12
    ld   L, A                                         ;; 00:257e $6f
    ld   A, [HL]                                      ;; 00:257f $7e
    add  A, C                                         ;; 00:2580 $81
    ld   [HL+], A                                     ;; 00:2581 $22
    ld   E, A                                         ;; 00:2582 $5f
    ld   A, [HL]                                      ;; 00:2583 $7e
    adc  A, B                                         ;; 00:2584 $88
    ld   [HL], A                                      ;; 00:2585 $77
    ld   D, A                                         ;; 00:2586 $57
    ret                                               ;; 00:2587 $c9

call_00_2588_Entity_NudgeXVelocityTowardC:
; Moves XVEL one step toward C and returns the comparison of the new value against
; C, so Z means "arrived". One unit per frame, which is what gives the acceleration
; its ramp. gex2's call_00_32e1_Entity_NudgeXVelocityTowardC
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   A, [HL]                                      ;; 00:2590 $7e
    cp   A, C                                         ;; 00:2591 $b9
    ret  Z                                            ;; 00:2592 $c8
    jr   C, .jr_00_2599                               ;; 00:2593 $38 $04
    dec  [HL]                                         ;; 00:2595 $35
    ld   A, [HL]                                      ;; 00:2596 $7e
    cp   A, C                                         ;; 00:2597 $b9
    ret                                               ;; 00:2598 $c9
.jr_00_2599:
    inc  [HL]                                         ;; 00:2599 $34
    ld   A, [HL]                                      ;; 00:259a $7e
    cp   A, C                                         ;; 00:259b $b9
    ret                                               ;; 00:259c $c9

call_00_259d_Entity_PatrolY_FacingBased:
; The vertical twin of call_00_251c_Entity_MoveXByFacingMomentum_BoundsChecked:
; moves Y with
; call_00_25cb_Entity_MoveYByFacingSpeed, then flips
; ENTITY_FACING_VERTICAL_FLIP when the entity reaches either end of its Y span.
;
; Reads as upside down until you remember larger Y is further down the screen:
; wDA20_EntityBoundingBoxYMax is the bottom, and reaching it clears the flip bit so
; the entity starts moving back up. Falls into
; call_00_25bf_Entity_SetFacingDirectionAndCompare either way.
;
; gex2's call_00_3760_Entity_PatrolY_FacingBased
    call call_00_25cb_Entity_MoveYByFacingSpeed
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   bc,wDA20_EntityBoundingBoxYMax
    add  hl,bc
    ld   c,ENTITY_FACING_RIGHT
    ldi  a,[hl]
    sub  e
    ldi  a,[hl]
    sbc  d
    jr   c,call_00_25bf_Entity_SetFacingDirectionAndCompare
    ld   c,ENTITY_FACING_VERTICAL_FLIP
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    jr   nc,call_00_25bf_Entity_SetFacingDirectionAndCompare
    xor  a
    ret  

call_00_25bf_Entity_SetFacingDirectionAndCompare:
; Writes C into ENTITY_FIELD_FACING_DIRECTION and returns the comparison of the old
; value against the new one - Z if nothing changed, NZ if the entity just turned.
; gex2's call_00_3290_Entity_SetFacingDirection is the same routine without the
; compare
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   a,[hl]
    ld   [hl],c
    cp   c
    ret  

call_00_25cb_Entity_MoveYByFacingSpeed:
; The Y counterpart of call_00_254a_Entity_MoveXByFacingSpeed: moves Y by YVEL in
; the direction
; ENTITY_FACING_VERTICAL_FLIP says, accumulating the fraction in
; ENTITY_FIELD_YVEL_RELATED, and returns the new 16-bit Y in DE.
;
; This is the only routine in the game that uses that accumulator byte, which is
; why it was long assumed to be unused. The two `xor` walks on L are $0D -> $1D
; (facing to YVEL) and $1E -> $10 (accumulator to YPOS)
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   c,[hl]
    ld   a,l
    xor  a,$10
    ld   l,a
    ldi  a,[hl]
    bit  6,c
    jr   nz,.jr_00_25df
    cpl  
    inc  a
.jr_00_25df:
    add  [hl]
    ld   c,a
    and  a,ENTITY_SUBPIXEL_MASK
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

call_00_2602_Entity_NudgeYVelocityTowardC:
; One step of YVEL toward C, Z when it arrives. gex2's
; call_00_3316_Entity_NudgeYVelocityTowardC_Signed
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

call_00_2617_Entity_ClampXToBounds:
; Keeps the entity inside its X patrol span after something else has already moved
; it. Below wDA1E_EntityBoundingBoxXMin, or at or past
; wDA1C_EntityBoundingBoxXMax, it writes the bound back into XPOS and subtracts the
; correction it just made from wDA13_EntityXVelocityDelta - so a platform that gets
; stopped by its own bounds stops carrying Gex too.
;
; Returns A = 0 with Z set when it clamped, and plain carry when the entity was
; inside and nothing happened
    call call_00_2857_Entity_GetMinXBound
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ldi  a,[hl]
    sub  e
    ldd  a,[hl]
    sbc  d
    jr   c,.jr_00_2639
    call call_00_2846_Entity_GetMaxXBound
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

call_00_2645_Entity_MoveXClampedToBounds:
; Move X by the signed BC, but not past the patrol span. A holds the direction on
; entry - bit 7 set means leftwards - which picks whether the trip is checked
; against Entity_GetMinXBound or Entity_GetMaxXBound.
;
; Returns nonzero when the move was cut short, which is how the moving-block code
; knows it has hit the end of its rail
    bit  $7,a
    jr   nz,.jr_00_265b
    ld   b,$00
    call call_00_2846_Entity_GetMaxXBound
    call call_00_2678_Entity_GetXPosPlusOffset
    ld   a,c
    sub  e
    ld   a,b
    sbc  d
    jr   c,.jr_00_266e
    ld   c,e
    ld   b,d
    jr   .jr_00_266e
.jr_00_265b:
    xor  a
    sub  c
    ld   c,a
    ld   b,$FF
    call call_00_2857_Entity_GetMinXBound
    call call_00_2678_Entity_GetXPosPlusOffset
    ld   a,e
    sub  c
    ld   a,d
    sbc  b
    jr   c,.jr_00_266e
    ld   c,e
    ld   b,d
.jr_00_266e:
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

call_00_2678_Entity_GetXPosPlusOffset:
; BC = this entity's 16-bit X plus the signed offset already in BC, and HL left
; pointing at the X field so the caller can write the result back. Only used by
; call_00_2645_Entity_MoveXClampedToBounds above
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_XPOS
    ldi  a,[hl]
    add  c
    ld   c,a
    ld   a,[hl]
    adc  b
    ld   b,a
    ret  

call_00_2687_Entity_MoveYClampedToBounds:
; The Y version of call_00_2645. Same convention - bit 7 of A picks the direction -
; but remember which bound is which: downwards is checked against
; Entity_GetMaxYBound, the floor
    bit  $7,a
    jr   nz,.jr_00_269d
    ld   b,$00
    call call_00_2804_Entity_GetMaxYBound
    call call_00_26ba_Entity_GetYPosPlusOffset
    ld   a,c
    sub  e
    ld   a,b
    sbc  d
    jr   c,.jr_00_26b0
    ld   c,e
    ld   b,d
    jr   .jr_00_26b0
.jr_00_269d:
    xor  a
    sub  c
    ld   c,a
    ld   b,$FF
    call call_00_2815_Entity_GetMinYBound
    call call_00_26ba_Entity_GetYPosPlusOffset
    ld   a,e
    sub  c
    ld   a,d
    sbc  b
    jr   c,.jr_00_26b0
    ld   c,e
    ld   b,d
.jr_00_26b0:
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

call_00_26ba_Entity_GetYPosPlusOffset:
; BC = this entity's 16-bit Y plus the signed offset in BC, HL left at the Y field.
; The Y twin of call_00_2678_Entity_GetXPosPlusOffset
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_YPOS
    ldi  a,[hl]
    add  c
    ld   c,a
    ld   a,[hl]
    adc  b
    ld   b,a
    ret  

call_00_26c9_Entity_CarryOrPushPlayerX:
; Everything a moving platform does to Gex horizontally.
;
; Works out its own signed X step from XVEL and ENTITY_FACING_VERTICAL_FLIP, then
; compares its own slot base against wDC7B_Player_EntityStoodOnLo. If Gex is
; standing on it, the step goes into wDC85_PlayerXDeltaExtra2 and he is carried
; along; if not, it falls into call_00_26f1_Entity_PushPlayerX to see whether he is
; being walked into instead.
;
; gex2 does the same two things in call_00_35d5_Entity_MoveXAndPushPlayer, with the
; carry delta going to wD75C_PlayerXDeltaExtra
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
    jr   nz,.jr_00_26e3
    xor  a
    sub  c
    ld   c,a
.jr_00_26e3:
    ld   a,l
    and  a,$E0
    ld   hl,wDC7B_Player_EntityStoodOnLo
    cp   [hl]
    jr   nz,call_00_26f1_Entity_PushPlayerX
    ld   a,c
    ld   [wDC85_PlayerXDeltaExtra2],a
    ret  

call_00_26f1_Entity_PushPlayerX:
; Shoves Gex out of this entity - but only if wDC7D_Player_PushedMovingPlatformLo
; names this slot, which is what stops two blocks fighting over him.
;
; If he is to the right of the entity's leading edge he is placed at that edge plus
; ENTITY_FIELD_WIDTH; otherwise control drops into
; call_00_2714_Entity_PushPlayerXLeft for the other side
    ld   hl,wDC7D_Player_PushedMovingPlatformLo
    cp   [hl]
    ret  nz
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WIDTH
    ld   a,[wD80E_PlayerXPosition]
    sub  e
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  d
    jr   c,call_00_2714_Entity_PushPlayerXLeft
    ld   a,e
    add  [hl]
    ld   [wD80E_PlayerXPosition],a
    ld   a,d
    adc  a,$00
    ld   [wD80E_PlayerXPosition+1],a
    ret  

call_00_2714_Entity_PushPlayerXLeft:
; The left-hand half of the push: places Gex at the entity's edge minus its width
; plus one
    ld   c,[hl]
    inc  c
    ld   a,e
    sub  c
    ld   [wD80E_PlayerXPosition],a
    ld   a,d
    sbc  a,$00
    ld   [wD80E_PlayerXPosition+1],a
    ret  

call_00_2722_Entity_IsPlayerInsideBounds:
; "Is Gex on top of me?" - A = 1 with Z clear when he is, A = 0 otherwise.
;
; Two tests. First the vertical one, done entirely in 16-bit arithmetic on the
; difference between the entity's Y and Gex's: the entity's ENTITY_FIELD_HEIGHT
; (reached with `xor $02` off the Y field) is added to the difference and the
; result must be positive and within twice the height, which is a tolerance band
; rather than an exact overlap. Then the horizontal one, against the entity's X
; patrol bounds rather than its own width.
;
; Different from gex2's Entity_CheckPlayerXProximity, which is a symmetric window
; around the entity rather than a bounding-box test
    ld   HL, wD810_PlayerYPosition                    ;; 00:2722 $21 $10 $d8
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2725 $fa $00 $da
    or   A, ENTITY_FIELD_YPOS                         ;; 00:2728 $f6 $10
    ld   C, A                                         ;; 00:272a $4f
    ld   B, HIGH(wD800_EntityMemory)                  ;; 00:272b $06 $d8
    ld   A, [BC]                                      ;; 00:272d $0a
    sub  A, [HL]                                      ;; 00:272e $96
    ld   E, A                                         ;; 00:272f $5f
    inc  BC                                           ;; 00:2730 $03
    inc  HL                                           ;; 00:2731 $23
    ld   A, [BC]                                      ;; 00:2732 $0a
    sbc  A, [HL]                                      ;; 00:2733 $9e
    ld   D, A                                         ;; 00:2734 $57
    ld   A, C                                         ;; 00:2735 $79
    xor  A, $02                                       ;; 00:2736 $ee $02
    ld   C, A                                         ;; 00:2738 $4f
    ld   A, [BC]                                      ;; 00:2739 $0a
    add  A, E                                         ;; 00:273a $83
    ld   E, A                                         ;; 00:273b $5f
    ld   A, $00                                       ;; 00:273c $3e $00
    adc  A, D                                         ;; 00:273e $8a
    jr   NZ, .jr_00_2764                              ;; 00:273f $20 $23
    ld   A, [BC]                                      ;; 00:2741 $0a
    add  A, A                                         ;; 00:2742 $87
    cp   A, E                                         ;; 00:2743 $bb
    jr   C, .jr_00_2764                               ;; 00:2744 $38 $1e
    call call_00_2857_Entity_GetMinXBound             ;; 00:2746 $cd $57 $28
    ld   A, [wD80E_PlayerXPosition]                   ;; 00:2749 $fa $0e $d8
    sub  A, E                                         ;; 00:274c $93
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 00:274d $fa $0f $d8
    sbc  A, D                                         ;; 00:2750 $9a
    jr   C, .jr_00_2764                               ;; 00:2751 $38 $11
    call call_00_2846_Entity_GetMaxXBound             ;; 00:2753 $cd $46 $28
    ld   A, [wD80E_PlayerXPosition]                   ;; 00:2756 $fa $0e $d8
    sub  A, E                                         ;; 00:2759 $93
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 00:275a $fa $0f $d8
    sbc  A, D                                         ;; 00:275d $9a
    jr   NC, .jr_00_2764                              ;; 00:275e $30 $04
    ld   A, $01                                       ;; 00:2760 $3e $01
    and  A, A                                         ;; 00:2762 $a7
    ret                                               ;; 00:2763 $c9
.jr_00_2764:
    xor  A, A                                         ;; 00:2764 $af
    ret                                               ;; 00:2765 $c9

call_00_2766_Entity_ClampYToSpawnFloor:
; The landing check on its own, without the gravity: if the entity has risen to or
; past its spawn Y it is snapped back to it and YVEL is zeroed.
;
;   carry SET    still below the spawn line, moving freely
;   carry CLEAR  clamped this frame
;
; This is the tail of call_00_2475_Entity_ApplyGravityMoveY_WithFloorCollision
; split out so it can be called after some other mover. gex2's equivalent pair is
; call_00_3125_Entity_SetYFloorToCurrentPos / call_00_3137_Entity_ClampYToStoredFloor,
; which remember a floor in a field instead of using the spawn position
    call call_00_27f3_Entity_GetInitialYPos           ;; 00:2766 $cd $f3 $27
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   A, [HL+]                                     ;; 00:2771 $2a
    sub  A, E                                         ;; 00:2772 $93
    ld   A, [HL]                                      ;; 00:2773 $7e
    sbc  A, D                                         ;; 00:2774 $9a
    ret  C                                            ;; 00:2775 $d8
    ld   [HL], D                                      ;; 00:2776 $72
    dec  L                                            ;; 00:2777 $2d
    ld   [HL], E                                      ;; 00:2778 $73
    ld   A, L                                         ;; 00:2779 $7d
    xor  A, $0d                                       ;; 00:277a $ee $0d
    ld   L, A                                         ;; 00:277c $6f
    xor  A, A                                         ;; 00:277d $af
    ld   [HL], A                                      ;; 00:277e $77
    ret                                               ;; 00:277f $c9

call_00_2780_Entity_IsBelowCameraBottom:
; Compares the entity's Y against the camera top plus ENTITY_BELOW_CAMERA_MARGIN,
; which is a little below the bottom of the screen. Carry set means the entity is
; still above that line; no carry means it has fallen off the bottom and the caller
; should get rid of it
    ld   hl,wDBFB_YPositionInMap
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    ld   de,ENTITY_BELOW_CAMERA_MARGIN
    add  hl,de
    ld   e,l
    ld   d,h
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ldi  a,[hl]
    sub  e
    ld   a,[hl]
    sbc  d
    ret  

call_00_2799_Entity_SetYFromXDistanceFromSpawn:
; Ties Y to X: takes the absolute horizontal distance the entity has travelled from
; its spawn point, halves it, and adds that to the spawn Y.
;
; The result is a straight V rather than a curve - everything that moves sideways
; also sinks at a fixed 1:2 slope - and because both ends are measured from the
; spawn position it cannot drift. Used for the things that arc away and down when
; they are knocked loose
    call call_00_2835_Entity_GetInitialXPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ldi  a,[hl]
    sub  e
    ld   e,a
    ld   a,[hl]
    sbc  d
    ld   d,a
    jr   nc,.jr_00_27b3
    xor  a
    sub  e
    ld   e,a
    ld   a,$00
    sbc  d
    ld   d,a
.jr_00_27b3:
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

call_00_27cb_Entity_SetYToAboveCameraTop:
; Places the entity ENTITY_ABOVE_CAMERA_MARGIN pixels above the top of the visible
; map, clamping to zero if that underflows. This is a setter, not a test - it is
; how an entity is parked just off the top of the screen before it drops in
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   a,[wDBFB_YPositionInMap]
    sub  a,ENTITY_ABOVE_CAMERA_MARGIN
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
; Puts YPOS back to the spawn Y
    call call_00_27f3_Entity_GetInitialYPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YPOS
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_27f3_Entity_GetInitialYPos:
; DE = this entity's spawn Y, from wDA26_EntityInitialYPos.
;
; The `rrca / and $70` is the other indexing idiom in this file: it turns the slot
; base $20,$40,... into $10,$20,..., the 16-byte stride of the per-slot constants
; block
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:27f3 $fa $00 $da
    rrca                                              ;; 00:27f6 $0f
    and  A, $70                                       ;; 00:27f7 $e6 $70
    ld   L, A                                         ;; 00:27f9 $6f
    ld   H, $00                                       ;; 00:27fa $26 $00
    ld   DE, wDA26_EntityInitialYPos                  ;; 00:27fc $11 $26 $da
    add  HL, DE                                       ;; 00:27ff $19
    ld   A, [HL+]                                     ;; 00:2800 $2a
    ld   E, A                                         ;; 00:2801 $5f
    ld   D, [HL]                                      ;; 00:2802 $56
    ret                                               ;; 00:2803 $c9

call_00_2804_Entity_GetMaxYBound:
; DE = the bottom of this entity's Y patrol span, wDA20_EntityBoundingBoxYMax.
;
; Larger Y is lower on the screen, so this is the FLOOR - which is why the
; "move down until you stop" helpers all call this one and not its neighbour. The
; label used to read YMin, purely because this is the first of the pair in memory.
;
; gex2's call_00_34ba_Entity_GetMaxYBound, which has to scale a block coordinate by
; 32 and subtract $10 because gex2 stores the bound as a single byte
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA20_EntityBoundingBoxYMax
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2815_Entity_GetMinYBound:
; DE = the top of the Y patrol span, wDA22_EntityBoundingBoxYMin - the CEILING,
; despite reading as the minimum. gex2's call_00_349c_Entity_GetMinYBound
    ld   a,[wDA00_CurrentEntityAddrLo]
    rrca 
    and  a,$70
    ld   l,a
    ld   h,$00
    ld   de,wDA22_EntityBoundingBoxYMin
    add  hl,de
    ldi  a,[hl]
    ld   e,a
    ld   d,[hl]
    ret  

call_00_2826_Entity_ResetToInitialXPos:
; Puts XPOS back to the spawn X
    call call_00_2835_Entity_GetInitialXPos
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   a,e
    ldi  [hl],a
    ld   [hl],d
    ret  

call_00_2835_Entity_GetInitialXPos:
; DE = this entity's spawn X, from wDA24_EntityInitialXPos
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

call_00_2846_Entity_GetMaxXBound:
; DE = the right-hand end of the X patrol span, wDA1C_EntityBoundingBoxXMax.
; gex2's call_00_347e_Entity_GetMaxXBound
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2846 $fa $00 $da
    rrca                                              ;; 00:2849 $0f
    and  A, $70                                       ;; 00:284a $e6 $70
    ld   L, A                                         ;; 00:284c $6f
    ld   H, $00                                       ;; 00:284d $26 $00
    ld   DE, wDA1C_EntityBoundingBoxXMax              ;; 00:284f $11 $1c $da
    add  HL, DE                                       ;; 00:2852 $19
    ld   A, [HL+]                                     ;; 00:2853 $2a
    ld   E, A                                         ;; 00:2854 $5f
    ld   D, [HL]                                      ;; 00:2855 $56
    ret                                               ;; 00:2856 $c9

call_00_2857_Entity_GetMinXBound:
; DE = the left-hand end of the X patrol span, wDA1E_EntityBoundingBoxXMin.
; gex2's call_00_3460_Entity_GetMinXBound
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2857 $fa $00 $da
    rrca                                              ;; 00:285a $0f
    and  A, $70                                       ;; 00:285b $e6 $70
    ld   L, A                                         ;; 00:285d $6f
    ld   H, $00                                       ;; 00:285e $26 $00
    ld   DE, wDA1E_EntityBoundingBoxXMin              ;; 00:2860 $11 $1e $da
    add  HL, DE                                       ;; 00:2863 $19
    ld   A, [HL+]                                     ;; 00:2864 $2a
    ld   E, A                                         ;; 00:2865 $5f
    ld   D, [HL]                                      ;; 00:2866 $56
    ret                                               ;; 00:2867 $c9

call_00_2868_Entity_SetMaxXBound:
; Writes DE into wDA1C_EntityBoundingBoxXMax for this slot. The bounds are normally
; filled in once at spawn from the entity's list record, so a setter means some
; action moves its own goalposts - the rails that extend as you ride them
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

call_00_2879_Entity_SetMinXBound:
; Writes DE into wDA1E_EntityBoundingBoxXMin for this slot
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
; Sets C to COLLISION_TYPE_NONE and falls into the setter below. Making an entity
; harmless without removing it is common enough to be worth two bytes
    ld   C, COLLISION_TYPE_NONE                       ;; 00:288a $0e $00
call_00_288c_Entity_SetCollisionType:
; ENTITY_FIELD_COLLISION_TYPE = C. gex2's call_00_3825_Entity_SetCollisionType
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COLLISION_TYPE
    ld   [HL], C                                      ;; 00:2894 $71
    ret                                               ;; 00:2895 $c9

call_00_2896_Entity_SetCooldownTimer:
; ENTITY_FIELD_COOLDOWN_TIMER = C
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   [hl],c
    ret  

call_00_28a0_Entity_GetCooldownTimer:
; A = ENTITY_FIELD_COOLDOWN_TIMER
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   a,[hl]
    ret  

call_00_28aa_Entity_SetDamageState:
; ENTITY_FIELD_DAMAGE_STATE = C. For most enemies that is a hit count; for the fly
; coin call_00_2bbe_Entity_TurnIntoFlyCoin leaves behind it is
; FLY_COIN_DAMAGE_STATE
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_DAMAGE_STATE
    ld   [HL], C
    ret  

call_00_28b4_Entity_GetDamageState:
; A = ENTITY_FIELD_DAMAGE_STATE
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_DAMAGE_STATE
    ld   a,[hl]
    ret  

call_00_28be_Entity_GetXVelocity:
; A = ENTITY_FIELD_XVEL
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   A, [HL]
    ret  

call_00_28c8_Entity_SetXVelocity:
; ENTITY_FIELD_XVEL = C. gex2's call_00_3350_Entity_SetXVelocity
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   [HL], C
    ret  

call_00_28d2_Entity_GetYVelocity:
; A = ENTITY_FIELD_YVEL
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   A, [HL]
    ret  

call_00_28dc_Entity_SetYVelocity:
; ENTITY_FIELD_YVEL = C. gex2's call_00_335a_Entity_SetYVelocity
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   [HL], C
    ret  

call_00_28e6_Entity_CheckIfXVelocityIsZero:
; Z when XVEL is zero. gex2's call_00_333a_Entity_CheckIfXVelocityIsZero
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XVEL
    ld   a,[hl]
    and  a
    ret  

call_00_28f1_Entity_CheckIfYVelocityIsZero:
; Z when YVEL is zero. gex2's call_00_3345_Entity_CheckIfYVelocityIsZero
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_YVEL
    ld   a,[hl]
    and  a
    ret  

call_00_28fc_Entity_SetMiscTimerFromCycleTable:
; Advances ENTITY_FIELD_MISC_FLAGS by one, takes the low two bits of the OLD value
; as an index into the four-entry table the caller passed in DE, and falls through
; into call_00_290d_Entity_SetMiscTimer with the byte it found.
;
; So the entity cycles through four canned timer lengths on successive calls - the
; enemies whose pauses are irregular on purpose
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_FLAGS
    ld   a,[hl]
    inc  [hl]
    and  a,$03
    ld   l,a
    ld   h,$00
    add  hl,de
    ld   c,[hl]

call_00_290d_Entity_SetMiscTimer:
; ENTITY_FIELD_MISC_TIMER = C. gex2's call_00_3802_Entity_SetMiscTimer
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_TIMER
    ld   [HL], C                                      ;; 00:2915 $71
    ret                                               ;; 00:2916 $c9

call_00_2917_Entity_CheckMiscTimerZero:
; Z when the misc timer has run out. gex2's call_00_380c_Entity_CheckMiscTimerZero
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_TIMER
    ld   a,[hl]
    and  a
    ret  

call_00_2922_Entity_DecrementMiscTimer:
; Counts the misc timer down by one unless it is already zero, and returns the new
; value in A. gex2's call_00_3817_Entity_DecrementMiscTimer
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_TIMER
    ld   A, [HL]                                      ;; 00:292a $7e
    and  A, A                                         ;; 00:292b $a7
    ret  Z                                            ;; 00:292c $c8
    dec  [HL]                                         ;; 00:292d $35
    ld   A, [HL]                                      ;; 00:292e $7e
    ret                                               ;; 00:292f $c9

call_00_2930_Entity_SetId:
; ENTITY_FIELD_ENTITY_ID = C. Writing this while the slot is live is how an entity
; becomes something else in place, as the fly coin drop does
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   [HL], C                                      ;; 00:2938 $71
    ret                                               ;; 00:2939 $c9

call_00_293a_Entity_GetId:
; A = ENTITY_FIELD_ENTITY_ID
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   a,[hl]
    ret  

call_00_2944_Entity_SetWidth:
; ENTITY_FIELD_WIDTH = C. gex2's call_00_382f_Entity_SetWidth
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WIDTH
    ld   [HL], C                                      ;; 00:294c $71
    ret                                               ;; 00:294d $c9

call_00_294e_Entity_SetHeight:
; ENTITY_FIELD_HEIGHT = C
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_HEIGHT
    ld   [HL], C                                      ;; 00:2956 $71
    ret                                               ;; 00:2957 $c9

call_00_2958_Entity_SetFacingDirection:
; ENTITY_FIELD_FACING_DIRECTION = C, without the compare that
; call_00_25bf_Entity_SetFacingDirectionAndCompare does. gex2's
; call_00_3290_Entity_SetFacingDirection
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   [HL], C                                      ;; 00:2960 $71
    ret                                               ;; 00:2961 $c9

call_00_2962_Entity_GetActionId:
; A = ENTITY_FIELD_ACTION_ID, the action the entity is currently running
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_ID
    ld   A, [HL]                                      ;; 00:296a $7e
    ret                                               ;; 00:296b $c9

call_00_296c_Entity_GetSpriteCounter:
; A = ENTITY_FIELD_SPRITE_COUNTER, how far through the current action's frame list
; the entity is. gex2's call_00_3839_Entity_GetSpriteCounter
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_SPRITE_COUNTER
    ld   a,[hl]
    ret  

call_00_2976_Entity_GetFacingDirection:
; A = ENTITY_FIELD_FACING_DIRECTION
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                      ;; 00:297e $7e
    ret                                               ;; 00:297f $c9

call_00_2980_Entity_SetMiscFlags:
; ENTITY_FIELD_MISC_FLAGS = C. gex2's call_00_37f8_Entity_SetMiscFlags
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_FLAGS
    ld   [HL], C                                      ;; 00:2988 $71
    ret                                               ;; 00:2989 $c9

call_00_298a_Entity_GetMiscFlags:
; A = ENTITY_FIELD_MISC_FLAGS, with the flags set from it so a caller can branch on
; zero straight away
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_MISC_FLAGS
    ld   A, [HL]                                      ;; 00:2992 $7e
    and  A, A                                         ;; 00:2993 $a7
    ret                                               ;; 00:2994 $c9

call_00_2995_Entity_GetActionId_Copy:
; Byte-for-byte the same routine as call_00_2962_Entity_GetActionId - the assembler
; laid the same four instructions down twice. Only
; call_03_4fad_CollisionHandler_Hand reaches this copy; everything else calls
; the one at $2962
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_ID
    ld   a,[hl]
    ret  

call_00_299f_Entity_TurnAround:
; Flips ENTITY_FACING_LEFT in the facing byte, leaving the other bits alone
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                      ;; 00:29a7 $7e
    xor  A, ENTITY_FACING_LEFT                        ;; 00:29a8 $ee $20
    ld   [HL], A                                      ;; 00:29aa $77
    ret                                               ;; 00:29ab $c9

call_00_29ac_Entity_IsFacingPlayer:
; Z when the entity is facing Gex. Runs
; call_00_2a68_Entity_ComputeXDistanceFromPlayer for its side effects and compares
; the facing byte against the direction it left in
; wDA12_EntityDirectionRelativeToPlayer
    call call_00_2a68_Entity_ComputeXDistanceFromPlayer
    call call_00_2976_Entity_GetFacingDirection
    ld   hl,wDA12_EntityDirectionRelativeToPlayer
    cp   [hl]
    ret  

call_00_29b7_Entity_FindSlotByIdAndGetActionId:
; Searches for a slot holding entity id C and returns that entity's action id, also
; in C, or $FF if there is none.
;
; The scan is the usual `add A, $20 / jr NZ` walk over slot bases, stopping when the
; low byte wraps to $00. It starts at wD840_EntityMemoryAfterPlayer rather than at
; $D820, so the first two slots are skipped - the same window
; call_00_2afc_Entity_FindFreeSlot allocates out of. Falls into
; call_00_29c8_Entity_GetActionIdAtSlot on a hit
    ld   h, HIGH(wD840_EntityMemoryAfterPlayer)
    ld   l, LOW(wD840_EntityMemoryAfterPlayer)
.jr_00_29bb:
    ld   a,[hl]
    cp   c
    jr   z,call_00_29c8_Entity_GetActionIdAtSlot
    ld   a,l
    add  a,$20
    ld   l,a
    jr   nz,.jr_00_29bb
    ld   c,$FF
    ret  

call_00_29c8_Entity_GetActionIdAtSlot:
; C = the action id of the slot HL points into. The `or $01` snaps L from the slot
; base to ENTITY_FIELD_ACTION_ID
    ld   a,l
    or   a,$01
    ld   l,a
    ld   c,[hl]
    ret  

call_00_29ce_Entity_FindSlotById:
; The same scan without the action lookup: Z with HL pointing at the slot if an
; entity of id C exists, NZ if none does. This is the "is the boss still alive"
; test
    ld   H, HIGH(wD840_EntityMemoryAfterPlayer)       ;; 00:29ce $26 $d8
    ld   L, LOW(wD840_EntityMemoryAfterPlayer)        ;; 00:29d0 $2e $40
.jr_00_29d2:
    ld   A, [HL]                                      ;; 00:29d2 $7e
    cp   A, C                                         ;; 00:29d3 $b9
    ret  Z                                            ;; 00:29d4 $c8
    ld   A, L                                         ;; 00:29d5 $7d
    add  A, $20                                       ;; 00:29d6 $c6 $20
    ld   L, A                                         ;; 00:29d8 $6f
    jr   NZ, .jr_00_29d2                              ;; 00:29d9 $20 $f7
    ld   A, $01                                       ;; 00:29db $3e $01
    and  A, A                                         ;; 00:29dd $a7
    ret                                               ;; 00:29de $c9
    
call_00_29df_Entity_SetFacingUnkFlag:
; Sets ENTITY_FACING_UNK_FLAG (bit 7 of the facing byte)
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    set  7,[hl]
    ret  

call_00_29ea_Entity_ClearFacingUnkFlag:
; Clears ENTITY_FACING_UNK_FLAG
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    res  7,[hl]
    ret  

call_00_29f5_Entity_IsFirstFrameOfActionAndClear:
; Reads and then clears ACTION_STATE_IS_FIRST_FRAME, returning NZ if this is the
; first frame since the action changed.
;
; Reading it consumes it, which is what makes it safe as an initialise-once gate at
; the top of an action. gex2's call_00_34ea_Entity_IsFirstFrameOfAction tests bit 5
; instead and does not clear it
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_STATE_FLAGS
    ld   A, [HL]                                      ;; 00:29fd $7e
    res  ACTION_STATE_IS_FIRST_FRAME_BIT, [HL]        ;; 00:29fe $cb $a6
    bit  ACTION_STATE_IS_FIRST_FRAME_BIT, A           ;; 00:2a00 $cb $67
    ret                                               ;; 00:2a02 $c9

call_00_2a03_Entity_ResetEntityListIndex:
; Zeroes this slot's entry in wDA01_EntityListIndexesForCurrentEntities, cutting the
; link from the slot back to the level's entity list.
;
; After this the slot can still be updated and drawn, but nothing that follows the
; link - Entity_ClearSlot, Entity_MarkNeverRespawn, the trigger helpers - will find
; the right list entry any more, which is exactly the point for entities spawned at
; runtime that were never in the list. gex2's call_00_34d8_Entity_ResetEntityListIndex
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2a03 $fa $00 $da
    rlca                                              ;; 00:2a06 $07
    rlca                                              ;; 00:2a07 $07
    rlca                                              ;; 00:2a08 $07
    and  A, $07                                       ;; 00:2a09 $e6 $07
    ld   L, A                                         ;; 00:2a0b $6f
    ld   H, $00                                       ;; 00:2a0c $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:2a0e $11 $01 $da
    add  HL, DE                                       ;; 00:2a11 $19
    ld   [HL], $00                                    ;; 00:2a12 $36 $00
    ret                                               ;; 00:2a14 $c9

call_00_2a15_Entity_CheckIfOnScreen:
; Carry set when the entity's patrol box does not overlap the camera, clear when it
; does. Four 16-bit comparisons, X pair first, and any failure returns early - which
; is why the routine reads as a chain of `ret c`.
;
; It tests the PATROL box, not the sprite, so an entity whose span reaches onto the
; screen counts as visible even when the entity itself is not. gex2's
; call_00_350c_Entity_CheckIfOnScreen
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2a15 $fa $00 $da
    rrca                                              ;; 00:2a18 $0f
    and  A, $70                                       ;; 00:2a19 $e6 $70
    ld   L, A                                         ;; 00:2a1b $6f
    ld   H, $00                                       ;; 00:2a1c $26 $00
    ld   DE, wDA1C_EntityBoundingBoxXMax              ;; 00:2a1e $11 $1c $da
    add  HL, DE                                       ;; 00:2a21 $19
    ld   A, [HL+]                                     ;; 00:2a22 $2a
    ld   E, A                                         ;; 00:2a23 $5f
    ld   A, [HL+]                                     ;; 00:2a24 $2a
    ld   D, A                                         ;; 00:2a25 $57
    ld   A, [HL+]                                     ;; 00:2a26 $2a
    ld   C, A                                         ;; 00:2a27 $4f
    ld   A, [HL+]                                     ;; 00:2a28 $2a
    ld   B, A                                         ;; 00:2a29 $47
    ld   HL, wDA14_CameraPos_Left                     ;; 00:2a2a $21 $14 $da
    ld   A, E                                         ;; 00:2a2d $7b
    sub  A, [HL]                                      ;; 00:2a2e $96
    inc  HL                                           ;; 00:2a2f $23
    ld   A, D                                         ;; 00:2a30 $7a
    sbc  A, [HL]                                      ;; 00:2a31 $9e
    ret  C                                            ;; 00:2a32 $d8
    inc  HL                                           ;; 00:2a33 $23
    ld   A, [HL+]                                     ;; 00:2a34 $2a
    sub  A, C                                         ;; 00:2a35 $91
    ld   A, [HL]                                      ;; 00:2a36 $7e
    sbc  A, B                                         ;; 00:2a37 $98
    ret  C                                            ;; 00:2a38 $d8
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2a39 $fa $00 $da
    rrca                                              ;; 00:2a3c $0f
    and  A, $70                                       ;; 00:2a3d $e6 $70
    ld   L, A                                         ;; 00:2a3f $6f
    ld   H, $00                                       ;; 00:2a40 $26 $00
    ld   DE, wDA20_EntityBoundingBoxYMax              ;; 00:2a42 $11 $20 $da
    add  HL, DE                                       ;; 00:2a45 $19
    ld   A, [HL+]                                     ;; 00:2a46 $2a
    ld   E, A                                         ;; 00:2a47 $5f
    ld   A, [HL+]                                     ;; 00:2a48 $2a
    ld   D, A                                         ;; 00:2a49 $57
    ld   A, [HL+]                                     ;; 00:2a4a $2a
    ld   C, A                                         ;; 00:2a4b $4f
    ld   A, [HL+]                                     ;; 00:2a4c $2a
    ld   B, A                                         ;; 00:2a4d $47
    ld   HL, wDA18_CameraPos_Top                      ;; 00:2a4e $21 $18 $da
    ld   A, E                                         ;; 00:2a51 $7b
    sub  A, [HL]                                      ;; 00:2a52 $96
    inc  HL                                           ;; 00:2a53 $23
    ld   A, D                                         ;; 00:2a54 $7a
    sbc  A, [HL]                                      ;; 00:2a55 $9e
    ret  C                                            ;; 00:2a56 $d8
    inc  HL                                           ;; 00:2a57 $23
    ld   A, [HL+]                                     ;; 00:2a58 $2a
    sub  A, C                                         ;; 00:2a59 $91
    ld   A, [HL]                                      ;; 00:2a5a $7e
    sbc  A, B                                         ;; 00:2a5b $98
    ret                                               ;; 00:2a5c $c9

call_00_2a5d_Entity_CheckAnimationEnded:
; NZ on the single frame the current action's animation wraps.
;
; call_02_724d_Entity_UpdateSpriteFields clears ACTION_STATE_ANIM_ENDED at the top
; of every entity's sprite update and sets it again only when the frame index
; reaches ENTITY_FIELD_SPRITE_COUNTER_MAX, so this is a one-frame pulse and reading
; it twice in a frame is safe.
;
; Sixteen call sites in bank02_entity_actions.asm, nearly all of the same shape -
; "call this, ret z" - which makes it the usual way an action hands off to the next
; one. gex2's call_00_3843_Entity_CheckAnimationEnded, where the same flag
; lives in SPRITE_FLAGS rather than ACTION_STATE_FLAGS
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_STATE_FLAGS
    bit  ACTION_STATE_ANIM_ENDED_BIT, [HL]            ;; 00:2a65 $cb $56
    ret                                               ;; 00:2a67 $c9

call_00_2a68_Entity_ComputeXDistanceFromPlayer:
; Works out how far Gex is horizontally and on which side, and leaves both in the
; scratch pair wDA11_EntityXDistFromPlayer / wDA12_EntityDirectionRelativeToPlayer
; for whatever called it.
;
; The distance is saturated: anything with a nonzero high byte is stored as $FF, so
; "very far away" and "off the map" look the same to the callers. The direction is
; ENTITY_LEFT_OF_GEX or ENTITY_RIGHT_OF_GEX, which are the same two values as the
; facing constants - that is what lets call_00_29ac_Entity_IsFacingPlayer compare
; them directly
    ld   C, ENTITY_LEFT_OF_GEX                        ;; 00:2a68 $0e $00
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_XPOS
    ld   A, [wD80E_PlayerXPosition]                   ;; 00:2a72 $fa $0e $d8
    sub  A, [HL]                                      ;; 00:2a75 $96
    ld   E, A                                         ;; 00:2a76 $5f
    inc  HL                                           ;; 00:2a77 $23
    ld   A, [wD80E_PlayerXPosition+1]                 ;; 00:2a78 $fa $0f $d8
    sbc  A, [HL]                                      ;; 00:2a7b $9e
    ld   D, A                                         ;; 00:2a7c $57
    jr   NC, .jr_00_2a88                              ;; 00:2a7d $30 $09
    xor  A, A                                         ;; 00:2a7f $af
    sub  A, E                                         ;; 00:2a80 $93
    ld   E, A                                         ;; 00:2a81 $5f
    ld   A, $00                                       ;; 00:2a82 $3e $00
    sbc  A, D                                         ;; 00:2a84 $9a
    ld   D, A                                         ;; 00:2a85 $57
    ld   C, ENTITY_RIGHT_OF_GEX                       ;; 00:2a86 $0e $20
.jr_00_2a88:
    ld   A, D                                         ;; 00:2a88 $7a
    and  A, A                                         ;; 00:2a89 $a7
    ld   A, E                                         ;; 00:2a8a $7b
    jr   Z, .jr_00_2a8f                               ;; 00:2a8b $28 $02
    ld   A, $ff                                       ;; 00:2a8d $3e $ff
.jr_00_2a8f:
    ld   [wDA11_EntityXDistFromPlayer], A             ;; 00:2a8f $ea $11 $da
    ld   B, A                                         ;; 00:2a92 $47
    ld   A, C                                         ;; 00:2a93 $79
    ld   [wDA12_EntityDirectionRelativeToPlayer], A   ;; 00:2a94 $ea $12 $da
    ret                                               ;; 00:2a97 $c9

call_00_2a98_Entity_CheckPlayerInHotspotAndSetAction:
; The generic "walk into this and something happens" check, used by the scenery
; that reacts to Gex rather than chasing him - the Ra statue among others.
;
; HL comes in pointing at a table of ten-byte hotspot records and this entity's
; spawn parameter picks which one (index * 10, built as x2 then x8 plus the x2).
; Each record is an X centre and half-width, a Y centre and half-width, then five
; bytes of payload. Both axis tests are the same trick: form the signed difference,
; add the half-width, and require the result to be positive and below twice the
; half-width - one compare per axis instead of two.
;
; On a hit the payload is copied into ENTITY_FIELD_MISC_TIMER onwards and the fifth
; byte is passed to call_02_72ac_SetEntityAction, so the table decides both the
; entity's new state and the action that shows it
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

call_00_2afc_Entity_FindFreeSlot:
; A = the base of a free entity slot, or 0 if there is none.
;
; Walks the slots from $40 upward - so not only Gex at $00 but the slot at $20 is
; passed over, the same six-slot window the other searches here use - and remembers
; the LAST free one rather than the first, which spreads repeated spawns across the
; table instead of reusing one slot. Free means ENTITY_ID_NONE, which is what the
; `inc A / jr NZ` is testing
    ld   H, HIGH(wD800_EntityMemory)                  ;; 00:2afc $26 $d8
    ld   A, $40                                       ;; 00:2afe $3e $40
    ld   D, $00                                       ;; 00:2b00 $16 $00
.jr_00_2b02:
    ld   L, A                                         ;; 00:2b02 $6f
    ld   A, [HL]                                      ;; 00:2b03 $7e
    inc  A                                            ;; 00:2b04 $3c
    jr   NZ, .jr_00_2b08                              ;; 00:2b05 $20 $01
    ld   D, L                                         ;; 00:2b07 $55
.jr_00_2b08:
    ld   A, L                                         ;; 00:2b08 $7d
    add  A, $20                                       ;; 00:2b09 $c6 $20
    jr   NZ, .jr_00_2b02                              ;; 00:2b0b $20 $f5
    ld   A, D                                         ;; 00:2b0d $7a
    and  A, A                                         ;; 00:2b0e $a7
    ret                                               ;; 00:2b0f $c9

call_00_2b10_Entity_FindDuplicateInstance:
; "Is another copy of me already loaded?" - A = 1 with Z clear if some slot holds
; entity id C AND is linked to the same entity-list entry as this one.
;
; Both halves matter: two of the same enemy from different list entries are fine,
; the same list entry placed twice is not. The list index is read from the slot's
; own ENTITY_FIELD_PARENT ($1F, reached with `or $1F`) rather than from
; wDA01_EntityListIndexesForCurrentEntities.
;
; Used by the spawners to keep a map transition from placing an entity that is
; already on screen
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2b10 $fa $00 $da
    rlca                                              ;; 00:2b13 $07
    rlca                                              ;; 00:2b14 $07
    rlca                                              ;; 00:2b15 $07
    and  A, $07                                       ;; 00:2b16 $e6 $07
    ld   L, A                                         ;; 00:2b18 $6f
    ld   H, $00                                       ;; 00:2b19 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:2b1b $11 $01 $da
    add  HL, DE                                       ;; 00:2b1e $19
    ld   B, [HL]                                      ;; 00:2b1f $46
    ld   H, HIGH(wD800_EntityMemory)                  ;; 00:2b20 $26 $d8
    ld   A, $40                                       ;; 00:2b22 $3e $40
.jr_00_2b24:
    ld   L, A                                         ;; 00:2b24 $6f
    ld   A, [HL]                                      ;; 00:2b25 $7e
    cp   A, C                                         ;; 00:2b26 $b9
    jr   NZ, .jr_00_2b31                              ;; 00:2b27 $20 $08
    ld   A, L                                         ;; 00:2b29 $7d
    or   A, $1f                                       ;; 00:2b2a $f6 $1f
    ld   L, A                                         ;; 00:2b2c $6f
    ld   A, [HL]                                      ;; 00:2b2d $7e
    cp   A, B                                         ;; 00:2b2e $b8
    jr   Z, .jr_00_2b39                               ;; 00:2b2f $28 $08
.jr_00_2b31:
    ld   A, L                                         ;; 00:2b31 $7d
    and  A, $e0                                       ;; 00:2b32 $e6 $e0
    add  A, $20                                       ;; 00:2b34 $c6 $20
    jr   NZ, .jr_00_2b24                              ;; 00:2b36 $20 $ec
    ret                                               ;; 00:2b38 $c9
.jr_00_2b39:
    ld   A, $01                                       ;; 00:2b39 $3e $01
    and  A, A                                         ;; 00:2b3b $a7
    ret                                               ;; 00:2b3c $c9

call_00_2b3d_Entity_ClearAllSlots:
; Frees every non-player slot, saving and restoring wDA00_CurrentEntityAddrLo
; around the sweep because call_00_2b5d_Entity_ClearSlot works on "the current
; entity" and the loop has to keep repointing it.
;
; Starts at $20 and stops when the low byte wraps, so slot 0 - Gex - is never
; touched, exactly as in gex2's call_00_38f0_Entity_ClearAllSlots
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2b3d $fa $00 $da
    push AF                                           ;; 00:2b40 $f5
    ld   A, $20                                       ;; 00:2b41 $3e $20
.jr_00_2b43:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 00:2b43 $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 00:2b46 $f6 $00
    ld   L, A                                         ;; 00:2b48 $6f
    ld   H, HIGH(wD800_EntityMemory)                  ;; 00:2b49 $26 $d8
    ld   A, [HL]                                      ;; 00:2b4b $7e
    cp   A, ENTITY_ID_NONE                            ;; 00:2b4c $fe $ff
    call NZ, call_00_2b5d_Entity_ClearSlot            ;; 00:2b4e $c4 $5d $2b
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2b51 $fa $00 $da
    add  A, $20                                       ;; 00:2b54 $c6 $20
    jr   NZ, .jr_00_2b43                              ;; 00:2b56 $20 $eb
    pop  AF                                           ;; 00:2b58 $f1
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 00:2b59 $ea $00 $da
    ret                                               ;; 00:2b5c $c9

call_00_2b5d_Entity_ClearSlot:
; Releases the current slot and lets its list entry be placed again.
;
; Two writes: ENTITY_ID_NONE into ENTITY_FIELD_ENTITY_ID, which is what actually
; frees the slot, and then ENTITY_LIST_FLAG_PLACED_BIT cleared in the entry's
; wD700_EntityFlags byte, following the slot -> list-entry link.
;
; Only that one bit is cleared, so a list entry that was marked
; ENTITY_LIST_FLAG_FLY_COIN by a defeat keeps that mark and comes back as a coin.
; gex2's call_00_3910_Entity_ClearSlot does the same job with its three-value enum
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_ENTITY_ID
    ld   [HL], ENTITY_ID_NONE                         ;; 00:2b65 $36 $ff
    ld   A, L                                         ;; 00:2b67 $7d
    rlca                                              ;; 00:2b68 $07
    rlca                                              ;; 00:2b69 $07
    rlca                                              ;; 00:2b6a $07
    and  A, $07                                       ;; 00:2b6b $e6 $07
    ld   L, A                                         ;; 00:2b6d $6f
    ld   H, $00                                       ;; 00:2b6e $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:2b70 $11 $01 $da
    add  HL, DE                                       ;; 00:2b73 $19
    ld   L, [HL]                                      ;; 00:2b74 $6e
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:2b75 $26 $d7
    res  ENTITY_LIST_FLAG_PLACED_BIT, [HL]            ;; 00:2b77 $cb $b6
    ret                                               ;; 00:2b79 $c9

call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn:
; Free the slot AND retire the list entry for good: calls
; call_00_2b80_Entity_DeactivateSelf then jumps into
; call_00_2b94_Entity_MarkNeverRespawn. Both halves of what
; call_00_2bbe_Entity_TurnIntoFlyCoin does when it decides there is no coin to drop
    call call_00_2b80_Entity_DeactivateSelf           ;; 00:2b7a $cd $80 $2b
    jp   call_00_2b94_Entity_MarkNeverRespawn         ;; 00:2b7d $c3 $94 $2b

call_00_2b80_Entity_DeactivateSelf:
; Writes ENTITY_ID_NONE into this slot's id field. Frees the slot without touching
; the list entry, so the entity can be placed again next time the map loads.
; gex2's call_00_3931_Entity_DeactivateSelf
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   [HL], ENTITY_ID_NONE                         ;; 00:2b88 $36 $ff
    ret                                               ;; 00:2b8a $c9

call_00_2b8b_Entity_MarkDefeated:
; Decides what a defeated entity leaves behind. Reads the entity's collision flags
; and branches on bit 6:
;
;   clear   call_00_2b94_Entity_MarkNeverRespawn - gone for good
;   set     call_00_2ba9_Entity_MarkRespawnAsFlyCoin - comes back as a coin
;
; Both are jumps, not calls, so this routine never returns on its own
    call call_00_35e8_GetEntityCollisionFlags         ;; 00:2b8b $cd $e8 $35
    bit  6, A                                         ;; 00:2b8e $cb $77
    jr   Z, call_00_2b94_Entity_MarkNeverRespawn      ;; 00:2b90 $28 $02
    jr   call_00_2ba9_Entity_MarkRespawnAsFlyCoin     ;; 00:2b92 $18 $15

call_00_2b94_Entity_MarkNeverRespawn:
; Writes ENTITY_LIST_FLAG_ABSENT over this entity's whole wD700_EntityFlags entry.
;
; Because the spawner's first test is "is the byte zero", zeroing it retires the
; entry permanently - this is gex3's version of gex2's
; call_00_393c_Entity_MarkNeverRespawn, which spells the same idea $FF.
;
; It does NOT free the slot; the entity carries on until something calls
; Entity_DeactivateSelf or Entity_ClearSlot
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2b94 $fa $00 $da
    rlca                                              ;; 00:2b97 $07
    rlca                                              ;; 00:2b98 $07
    rlca                                              ;; 00:2b99 $07
    and  A, $07                                       ;; 00:2b9a $e6 $07
    ld   L, A                                         ;; 00:2b9c $6f
    ld   H, $00                                       ;; 00:2b9d $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:2b9f $11 $01 $da
    add  HL, DE                                       ;; 00:2ba2 $19
    ld   L, [HL]                                      ;; 00:2ba3 $6e
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:2ba4 $26 $d7
    ld   [HL], ENTITY_LIST_FLAG_ABSENT                ;; 00:2ba6 $36 $00
    ret                                               ;; 00:2ba8 $c9

call_00_2ba9_Entity_MarkRespawnAsFlyCoin:
; The same write with ENTITY_LIST_FLAGS_DEFEATED instead of zero: still placed,
; and flagged to come back as ENTITY_FLY_COIN_SPAWN rather than as itself.
;
; ENTITY_LIST_FLAG_PLACED here is what keeps the spawner from immediately putting
; the coin down a second time; call_00_2b5d_Entity_ClearSlot clears it when the
; slot is genuinely released. No gex2 equivalent
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2ba9 $fa $00 $da
    rlca                                              ;; 00:2bac $07
    rlca                                              ;; 00:2bad $07
    rlca                                              ;; 00:2bae $07
    and  A, $07                                       ;; 00:2baf $e6 $07
    ld   L, A                                         ;; 00:2bb1 $6f
    ld   H, $00                                       ;; 00:2bb2 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:2bb4 $11 $01 $da
    add  HL, DE                                       ;; 00:2bb7 $19
    ld   L, [HL]                                      ;; 00:2bb8 $6e
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:2bb9 $26 $d7
    ld   [HL], ENTITY_LIST_FLAGS_DEFEATED             ;; 00:2bbb $36 $50
    ret                                               ;; 00:2bbd $c9

call_00_2bbe_Entity_TurnIntoFlyCoin:
; Turns a defeated enemy into the fly coin it drops, in place, without freeing and
; reallocating the slot.
;
; Refuses twice first: collision flags of $FF, or bit 6 clear, both send it to
; call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn and no coin appears. Otherwise
; it rewrites the live slot field by field - id, collision type, size, facing,
; damage state - resets the list entry's state nibble, marks the entry
; ENTITY_LIST_FLAGS_DEFEATED, hands the new action to call_02_72ac_SetEntityAction
; and finally copies .data_00_2c01_FlyCoinPalette over the slot's palette.
;
; The palette copy is why the coin looks right immediately rather than a frame
; late. gex2 has nothing like this - a defeated gex2 enemy simply ends
    call call_00_35e8_GetEntityCollisionFlags         ;; 00:2bbe $cd $e8 $35
    cp   A, $ff                                       ;; 00:2bc1 $fe $ff
    jr   Z, call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn ;; 00:2bc3 $28 $b5
    bit  6, A                                         ;; 00:2bc5 $cb $77
    jr   Z, call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn ;; 00:2bc7 $28 $b1
    ld   C, ENTITY_FLY_COIN_SPAWN                     ;; 00:2bc9 $0e $02
    call call_00_2930_Entity_SetId                    ;; 00:2bcb $cd $30 $29
    ld   C, COLLISION_TYPE_FLY_COIN                   ;; 00:2bce $0e $08
    call call_00_288c_Entity_SetCollisionType         ;; 00:2bd0 $cd $8c $28
    ld   C, FLY_COIN_SIZE                             ;; 00:2bd3 $0e $12
    call call_00_2944_Entity_SetWidth                 ;; 00:2bd5 $cd $44 $29
    ld   C, FLY_COIN_SIZE                             ;; 00:2bd8 $0e $12
    call call_00_294e_Entity_SetHeight                ;; 00:2bda $cd $4e $29
    ld   C, ENTITY_FACING_RIGHT                       ;; 00:2bdd $0e $00
    call call_00_2958_Entity_SetFacingDirection       ;; 00:2bdf $cd $58 $29
    ld   C, FLY_COIN_DAMAGE_STATE                     ;; 00:2be2 $0e $01
    call call_00_28aa_Entity_SetDamageState           ;; 00:2be4 $cd $aa $28
    ld   C, ENTITY_LIST_STATE_DEFAULT                 ;; 00:2be7 $0e $00
    call call_00_2299_Entity_SetListState             ;; 00:2be9 $cd $99 $22
    call call_00_2ba9_Entity_MarkRespawnAsFlyCoin     ;; 00:2bec $cd $a9 $2b
    xor  A, A                                         ;; 00:2bef $af
    farcall call_02_72ac_SetEntityAction
    ld   HL, .data_00_2c01_FlyCoinPalette             ;; 00:2bfb $21 $01 $2c
    jp   call_00_2c20_Entity_CopyPaletteToBuffer      ;; 00:2bfe $c3 $20 $2c
.data_00_2c01_FlyCoinPalette:
; The four CGB colours a dropped fly coin is drawn in, copied into this slot's
; entry of wDD2A_EntityPalettes
    db   $00, $00, $00, $00, $60, $02, $9c, $03       ;; 00:2c01 ........

call_00_2c09_Entity_SpawnGoalCounter:
; Adds 6 to the child-entity index in A and jumps into
; call_00_3792_PrepareRelativeEntitySpawn, so the six SPAWN_CHILD_ENTITY_* slots
; below that offset stay available for ordinary projectiles
    add  A, $06                                       ;; 00:2c09 $c6 $06
    ld   C, A                                         ;; 00:2c0b $4f
    jp   call_00_3792_PrepareRelativeEntitySpawn      ;; 00:2c0c $c3 $92 $37

call_00_2c0f_Entity_AssignPaletteId:
; wDAAE_EntityPaletteIds for this slot = C: which of the eight-byte palettes in
; wDD2A_EntityPalettes the entity is drawn with.
;
; gex2's nearest relative is call_00_37e7_Entity_SetOamAttrBase, but that only
; picks one of the hardware OBJ palettes; gex3 gives the slot a palette of its own
; because it never has to run on a DMG
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
; Copies the eight bytes at HL into this entity's slot of wDD2A_EntityPalettes -
; four CGB colours, the palette id coming from wDAAE_EntityPaletteIds.
;
; Writing the buffer is all this does; the upload to hardware happens later, in the
; vblank palette pass
    push HL                                           ;; 00:2c20 $e5
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2c21 $fa $00 $da
    rlca                                              ;; 00:2c24 $07
    rlca                                              ;; 00:2c25 $07
    rlca                                              ;; 00:2c26 $07
    and  A, $07                                       ;; 00:2c27 $e6 $07
    ld   L, A                                         ;; 00:2c29 $6f
    ld   H, $00                                       ;; 00:2c2a $26 $00
    ld   DE, wDAAE_EntityPaletteIds                   ;; 00:2c2c $11 $ae $da
    add  HL, DE                                       ;; 00:2c2f $19
    ld   L, [HL]                                      ;; 00:2c30 $6e
    ld   H, $00                                       ;; 00:2c31 $26 $00
    add  HL, HL                                       ;; 00:2c33 $29
    add  HL, HL                                       ;; 00:2c34 $29
    add  HL, HL                                       ;; 00:2c35 $29
    ld   DE, wDD2A_EntityPalettes                     ;; 00:2c36 $11 $2a $dd
    add  HL, DE                                       ;; 00:2c39 $19
    ld   E, L                                         ;; 00:2c3a $5d
    ld   D, H                                         ;; 00:2c3b $54
    pop  HL                                           ;; 00:2c3c $e1
    ld   BC, ENTITY_PALETTE_SIZE                      ;; 00:2c3d $01 $08 $00
    jp   call_00_076e_MemCopy                         ;; 00:2c40 $c3 $6e $07

data_00_2c43_ParticleSlotPointerTable:
; PARTICLE_SLOT_COUNT pointers, one particle buffer per entity slot
    dw   wDDC4_ParticleSlot1, wDDD7_ParticleSlot2
    dw   wDDEA_ParticleSlot3, wDDFD_ParticleSlot4     ;; 00:2c43 ????????
    dw   wDE10_ParticleSlot5, wDE23_ParticleSlot6
    dw   wDE36_ParticleSlot7, wDE49_ParticleSlot8     ;; 00:2c51 pP

call_00_2c53_Particle_GetSlotPtr:
; DE = the particle buffer belonging to the current entity, out of
; data_00_2c43_ParticleSlotPointerTable. Same slot-to-index idiom as everywhere
; else, then doubled for the pointer table
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:2c53 $fa $00 $da
    rlca                                              ;; 00:2c56 $07
    rlca                                              ;; 00:2c57 $07
    rlca                                              ;; 00:2c58 $07
    and  A, $07                                       ;; 00:2c59 $e6 $07
    ld   L, A                                         ;; 00:2c5b $6f
    ld   H, $00                                       ;; 00:2c5c $26 $00
    add  HL, HL                                       ;; 00:2c5e $29
    ld   DE, data_00_2c43_ParticleSlotPointerTable    ;; 00:2c5f $11 $43 $2c
    add  HL, DE                                       ;; 00:2c62 $19
    ld   E, [HL]                                      ;; 00:2c63 $5e
    inc  HL                                           ;; 00:2c64 $23
    ld   D, [HL]                                      ;; 00:2c65 $56
    ret                                               ;; 00:2c66 $c9

call_00_2c67_Particle_InitBurst:
; Starts a burst on this entity's particle slot: PARTICLE_BURST_DURATION into the
; timer byte, then PARTICLE_TEMPLATE_SIZE bytes of
; .data_00_2c77_DefaultBurstTemplate over the rest.
;
; Every burst starts from the same template, so the variety comes from the update
; below rather than from the seed
    call call_00_2c53_Particle_GetSlotPtr             ;; 00:2c67 $cd $53 $2c
    ld   A, PARTICLE_BURST_DURATION                   ;; 00:2c6a $3e $40
    ld   [DE], A                                      ;; 00:2c6c $12
    inc  DE                                           ;; 00:2c6d $13
    ld   HL, .data_00_2c77_DefaultBurstTemplate       ;; 00:2c6e $21 $77 $2c
    ld   BC, PARTICLE_TEMPLATE_SIZE                   ;; 00:2c71 $01 $12 $00
    jp   call_00_076e_MemCopy                         ;; 00:2c74 $c3 $6e $07
.data_00_2c77_DefaultBurstTemplate:
; PARTICLE_TEMPLATE_SIZE bytes: PARTICLE_BURST_PAIRS groups of (velocity,
; subpixel, position) for X and then Y, the initial spread of one burst
    db   $0b, $00, $00, $f5, $00, $00, $10, $00       ;; 00:2c77 ........
    db   $00, $00, $00, $00, $0b, $00, $00, $0b       ;; 00:2c7f ........
    db   $00, $00                                     ;; 00:2c87 ..

call_00_2c89_Particle_UpdateBurst:
; One frame of a burst. Counts the timer down (stopping at zero rather than
; wrapping) and then runs the same subpixel step as the entity movers over
; PARTICLE_BURST_PAIRS x/y pairs: add the velocity into the accumulator, keep the
; low nibble, shift the rest into the position.
;
; Returns the timer value from BEFORE the decrement, with the flags set from it, so
; Z means the burst had already finished and the caller can drop the entity.
; gex3 only - gex2 has no particle system
    call call_00_2c53_Particle_GetSlotPtr             ;; 00:2c89 $cd $53 $2c
    ld   L, E                                         ;; 00:2c8c $6b
    ld   H, D                                         ;; 00:2c8d $62
    ld   A, [HL]                                      ;; 00:2c8e $7e
    and  A, A                                         ;; 00:2c8f $a7
    jr   Z, .jr_00_2c93                               ;; 00:2c90 $28 $01
    dec  [HL]                                         ;; 00:2c92 $35
.jr_00_2c93:
    ld   A, [HL+]                                     ;; 00:2c93 $2a
    push AF                                           ;; 00:2c94 $f5
    ld   B, PARTICLE_BURST_PAIRS                      ;; 00:2c95 $06 $03
.jr_00_2c97:
    ld   C, [HL]                                      ;; 00:2c97 $4e
    inc  HL                                           ;; 00:2c98 $23
    ld   A, [HL]                                      ;; 00:2c99 $7e
    and  A, ENTITY_SUBPIXEL_MASK                      ;; 00:2c9a $e6 $0f
    add  A, C                                         ;; 00:2c9c $81
    ld   [HL+], A                                     ;; 00:2c9d $22
    sra  A                                            ;; 00:2c9e $cb $2f
    sra  A                                            ;; 00:2ca0 $cb $2f
    sra  A                                            ;; 00:2ca2 $cb $2f
    sra  A                                            ;; 00:2ca4 $cb $2f
    add  A, [HL]                                      ;; 00:2ca6 $86
    ld   [HL+], A                                     ;; 00:2ca7 $22
    ld   C, [HL]                                      ;; 00:2ca8 $4e
    inc  HL                                           ;; 00:2ca9 $23
    ld   A, [HL]                                      ;; 00:2caa $7e
    and  A, ENTITY_SUBPIXEL_MASK                      ;; 00:2cab $e6 $0f
    add  A, C                                         ;; 00:2cad $81
    ld   [HL+], A                                     ;; 00:2cae $22
    sra  A                                            ;; 00:2caf $cb $2f
    sra  A                                            ;; 00:2cb1 $cb $2f
    sra  A                                            ;; 00:2cb3 $cb $2f
    sra  A                                            ;; 00:2cb5 $cb $2f
    add  A, [HL]                                      ;; 00:2cb7 $86
    ld   [HL+], A                                     ;; 00:2cb8 $22
    dec  B                                            ;; 00:2cb9 $05
    jr   NZ, .jr_00_2c97                              ;; 00:2cba $20 $db
    pop  AF                                           ;; 00:2cbc $f1
    and  A, A                                         ;; 00:2cbd $a7
    ret                                               ;; 00:2cbe $c9
