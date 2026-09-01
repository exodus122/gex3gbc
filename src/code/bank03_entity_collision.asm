; ==================================================================
; ENTITY COLLISION
;
; Gex against everything else - enemies, coins, collectibles, switches, doors,
; platforms. Entity-against-entity collision does not exist as a system; only the
; player is ever tested, which is why every routine here talks about "the player"
; implicitly. The one exception is bolted onto a boss handler - see
; call_03_5406_CollisionHandler_BrainOfOz.
;
; Two levels of lookup:
;
;   COLLISION_TYPE (ENTITY_FIELD_COLLISION_TYPE, $14) picks a handler out of
;   .data_03_4c63_EntityCollisionJumpTable. It is a property of the entity
;   *instance*: data_00_3258_EntityAttributeTable gives each entity type a default
;   when it spawns, and a few actions rewrite it mid-life through
;   call_00_288c_Entity_SetCollisionType, so the same entity can be inert on one
;   frame and lethal on the next
;
;   ENTITY_INTERACT_* flags (.data_03_55ff_EntityInteractionFlagsTable, keyed by
;   entity TYPE rather than by collision type) say whether an attack or a stomp is
;   possible at all
;
; Almost every handler opens with call_03_550e_Entity_CheckPlayerInteraction,
; which does the box test once and reports back not just "did we touch" but
; *how*: PLAYER_TOUCHED_ENTITY, PLAYER_ATTACKED_ENTITY or PLAYER_STOMPED_ENTITY.
; Reading a handler is mostly a matter of reading its three cases.
;
; Two shared routines do the work behind almost all of them:
;
;   call_03_4cea_CollisionHandler_DamagePlayer  Gex loses a hit point and is
;       knocked back. Handlers `jp` here for the touch case
;   call_03_5671_HandleEntityHit                the ENTITY loses a hit point, and
;       dies when it runs out. Handlers `call` here for the attack/stomp case
;
; Everything is measured in WORLD coordinates - ENTITY_FIELD_WORLD_X/Y against
; wD80E_PlayerXPosition / wD810_PlayerYPosition - so nothing here depends on where
; the camera happens to be.
;
; Platforms are the exception: they do not use the shared test at all, because
; they care about which side Gex approached from and how fast. They live at the
; bottom of the file and maintain wDC7B_Player_EntityStoodOnLo and
; wDC7D_Player_PushedMovingPlatformLo, which is what the player code in bank 2
; reads to be carried or blocked.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank03_entity_collision.asm
; ------------------------------------------------------------------
; The two files have the same skeleton - a jump table of per-type handlers, one
; shared box test that classifies the contact three ways, an interaction-flags
; table keyed by entity type, and a pair of platform routines that bypass all of
; it. Several routines line up almost instruction for instruction. What changed:
;
;   coordinates   gex2 tests SCREEN positions (ENTITY_FIELD_SCREEN_X/Y against
;                 wD212/wD213), so an entity that is not on screen cannot be
;                 touched. gex3 tests WORLD positions in 16 bits, and the extra
;                 precision is why every comparison here is a sub/sbc pair
;   when it runs  gex2 tail-calls its dispatcher from inside the sprite builder,
;                 so an entity that is not drawn is never tested - its cheap way
;                 of culling offscreen collision. gex3 gives collision a sweep of
;                 its own at the end of call_03_5ec1_OAM_BuildFrame, over every
;                 occupied slot whether it was drawn or not
;   the box       gex2 hands each handler the collision box in DE. gex3 hands
;                 over nothing: the shared test reads ENTITY_FIELD_COLLISION_WIDTH
;                 and _HEIGHT itself, and the handlers that roll their own hitbox
;                 read them again. Both treat the two bytes as HALF extents
;   damage        gex2's handlers call a two-line wrapper that ends in
;                 Player_TakeDamage. gex3's call_03_4cea_CollisionHandler_DamagePlayer
;                 also writes wDC98_Player_DamageKnockbackX and requests one of
;                 three take-damage actions depending on the map, because Gex can
;                 be on a snowboard or a kangaroo
;   attacking     gex2 asks what action the player is in (tail spin, karate kick,
;                 a climbing spin). gex3 reads the one-shot flag
;                 wDC7F_Player_IsAttacking and CLEARS it on the entity it
;                 connects with, so one tail spin can only ever hit one thing
;   enemy health  gex2 keeps a hit counter in whichever MISC field an enemy
;                 happens to use, and each handler decrements its own. gex3 has
;                 ENTITY_FIELD_DAMAGE_STATE on every entity and one routine,
;                 call_03_5671_HandleEntityHit, that spends it - plus
;                 ENTITY_FIELD_COOLDOWN_TIMER, hit invulnerability the entity gets
;                 for free. gex2 has no equivalent of either
;   what dying    gex2's enemies turn into their own death burst through
;   looks like    Entity_ParticleBurstInit. gex3 looks up
;                 ENTITY_ATTR_DEFEAT_FLAGS and can send the entity to a death
;                 ACTION instead, or leave a fly coin behind
;   invincibility gex2 reports the touch and lets the damage wrapper drop it. gex3
;                 checks Player_IsInvincible inside the box test, so during the
;                 flicker after a hit a touch is reported as no contact at all
;   counters      gex3 has a whole class of handler gex2 does not: collect N of a
;                 thing, bump a counter, and call
;                 call_00_2c09_Entity_SpawnGoalCounter to put a pip on the HUD.
;                 A dozen of the handlers below are that shape
;   platforms     gex2 splits them three ways (stationary, moving, one-way). gex3
;                 has one COLLISION_TYPE_PLATFORM handler that covers all of it,
;                 plus a landing-only twin for tv buttons - the same relationship
;                 gex2's one-way platform has to its stationary one
; ==================================================================

call_03_4c38_UpdateEntityCollision_Dispatch:
; Entry point for all entity-player collision. Called once per occupied slot from
; the sweep at the end of call_03_5ec1_OAM_BuildFrame, after every position for
; the frame has been settled.
;
; Three things happen before the dispatch:
;
;   1. Nothing runs at all while Gex is not under his own control
;      (wDCA7_Player_UpdateFlag = 0, which is what a cutscene clears).
;   2. ENTITY_FIELD_COOLDOWN_TIMER is aged by one. This is the only place it ticks
;      down, and it is the entity's own invulnerability window - see
;      call_03_5671_HandleEntityHit, which arms it, and
;      call_03_550e_Entity_CheckPlayerInteraction, which refuses to report contact
;      while it is running.
;   3. ACTION_STATE_NO_COLLISION in the entity's ENTITY_FIELD_ACTION_STATE_FLAGS
;      skips the entity entirely. That bit comes from byte 2 of the action's data
;      block, so it is a property of the ACTION rather than of the entity - which
;      is how Rez, the ghost knight and the two remotes are intangible during
;      their intro actions without changing collision type.
;
; `res 7, L` then strips COLLISION_TYPE_FLAG_IMMOVABLE ($80) off the type before
; it is used as an index; the table has no row for it. That bit is not for this
; routine - call_02_51cb_Player_MoveLeftAgainstEntity reads it off the field to
; decide whether the thing Gex is walking into can be shoved along or is solid.
;
; Unlike gex2 this leaves nothing in the registers for the handler: the collision
; box is read again by whoever needs it
    ld   A, [wDCA7_Player_UpdateFlag]                                    ;; 03:4c38 $fa $a7 $dc
    and  A, A                                          ;; 03:4c3b $a7
    ret  Z                                             ;; 03:4c3c $c8
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   A, [HL]                                       ;; 03:4c45 $7e
    and  A, A                                          ;; 03:4c46 $a7
    jr   Z, .jr_03_4c4a                                ;; 03:4c47 $28 $01
    dec  [HL]                                          ;; 03:4c49 $35 ; the entity's hit invulnerability
.jr_03_4c4a:
    ld   A, L                                          ;; 03:4c4a $7d
    xor  A, $10                                        ;; 03:4c4b $ee $10 ; $15 -> $05 ACTION_STATE_FLAGS
    ld   L, A                                          ;; 03:4c4d $6f
    bit  ACTION_STATE_NO_COLLISION_BIT, [HL]           ;; 03:4c4e $cb $46
    ret  NZ                                            ;; 03:4c50 $c0 ; this action is intangible
    ld   A, L                                          ;; 03:4c51 $7d
    xor  A, $11                                        ;; 03:4c52 $ee $11 ; $05 -> $14 COLLISION_TYPE
    ld   L, A                                          ;; 03:4c54 $6f
    ld   L, [HL]                                       ;; 03:4c55 $6e
    res  7, L                                          ;; 03:4c56 $cb $bd ; drop COLLISION_TYPE_FLAG_IMMOVABLE
    ld   H, $00                                        ;; 03:4c58 $26 $00
    add  HL, HL                                        ;; 03:4c5a $29
    ld   BC, .data_03_4c63_EntityCollisionJumpTable    ;; 03:4c5b $01 $63 $4c
    add  HL, BC                                        ;; 03:4c5e $09
    ld   A, [HL+]                                      ;; 03:4c5f $2a
    ld   H, [HL]                                       ;; 03:4c60 $66
    ld   L, A                                          ;; 03:4c61 $6f
    jp   HL                                            ;; 03:4c62 $e9 ; load collision routine and jump
.data_03_4c63_EntityCollisionJumpTable:
; One handler address per COLLISION_TYPE_*, in value order. The two "_UNUSED"
; rows are dead: neither value appears in data_00_3258_EntityAttributeTable nor in
; any call_00_288c_Entity_SetCollisionType call.
;
; Most rows belong to exactly one entity type, which is why the names read like a
; cast list. The three that do not are COLLISION_TYPE_NONE (every invisible
; bookkeeping entity), COLLISION_TYPE_PLATFORM (fourteen kinds of thing to stand
; on) and COLLISION_TYPE_GENERIC_ENEMY (eighteen ordinary enemies)
    dw   call_03_4ccf_CollisionHandler_None                   ; COLLISION_TYPE_NONE
    dw   call_03_56c1_CollisionHandler_Platform               ; COLLISION_TYPE_PLATFORM
    dw   call_03_4cd0_CollisionHandler_InvulnerableEnemy      ; COLLISION_TYPE_INVULNERABLE_ENEMY
    dw   call_03_4cd7_CollisionHandler_Projectile             ; COLLISION_TYPE_PROJECTILE
    dw   call_03_4ce1_CollisionHandler_GenericEnemy           ; COLLISION_TYPE_GENERIC_ENEMY
    dw   call_03_4d38_CollisionHandler_GenericEnemyUnused     ; COLLISION_TYPE_GENERIC_ENEMY_UNUSED (never assigned)
    dw   call_03_4d44_CollisionHandler_DamagePlayerUnused     ; COLLISION_TYPE_DAMAGE_PLAYER_UNUSED (never assigned)
    dw   call_03_4d9b_CollisionHandler_BonusCoin              ; COLLISION_TYPE_BONUS_COIN
    dw   call_03_4db3_CollisionHandler_FlyCoin                ; COLLISION_TYPE_FLY_COIN
    dw   call_03_4dc2_CollisionHandler_PawCoin                ; COLLISION_TYPE_PAW_COIN
    dw   call_03_4e04_CollisionHandler_Fly                    ; COLLISION_TYPE_FLY
    dw   call_03_4e31_CollisionHandler_FlyTV                  ; COLLISION_TYPE_FLY_TV
    dw   call_03_4e4b_CollisionHandler_IceSculpture           ; COLLISION_TYPE_ICE_SCULPTURE
    dw   call_03_4e89_CollisionHandler_EvilSantaProjectile    ; COLLISION_TYPE_EVIL_SANTA_PROJECTILE
    dw   call_03_4f23_CollisionHandler_HolidayTV_Elf          ; COLLISION_TYPE_ELF
    dw   call_03_4f60_CollisionHandler_BloodCooler            ; COLLISION_TYPE_BLOOD_COOLER
    dw   call_03_4f8c_CollisionHandler_MagicSword             ; COLLISION_TYPE_MAGIC_SWORD
    dw   call_03_4f98_CollisionHandler_GhostKnight            ; COLLISION_TYPE_GHOST_KNIGHT
    dw   call_03_4fad_CollisionHandler_Hand                   ; COLLISION_TYPE_HAND
    dw   call_03_4fca_CollisionHandler_LostArk                ; COLLISION_TYPE_LOST_ARK
    dw   call_03_4ff1_CollisionHandler_RaStaff                ; COLLISION_TYPE_RA_STAFF
    dw   call_03_500d_CollisionHandler_Coffin                 ; COLLISION_TYPE_COFFIN
    dw   call_03_50b6_CollisionHandler_AlienCultureTube       ; COLLISION_TYPE_ALIEN_CULTURE_TUBE
    dw   call_03_50e0_CollisionHandler_OnSwitch               ; COLLISION_TYPE_ON_SWITCH
    dw   call_03_50ea_CollisionHandler_OffSwitch              ; COLLISION_TYPE_OFF_SWITCH
    dw   call_03_50f4_CollisionHandler_OnSwitch2              ; COLLISION_TYPE_ON_SWITCH_2
    dw   call_03_5116_CollisionHandler_Door                   ; COLLISION_TYPE_DOOR
    dw   call_03_5156_CollisionHandler_Door2                  ; COLLISION_TYPE_DOOR_2
    dw   call_03_5196_CollisionHandler_Secbot                 ; COLLISION_TYPE_SECBOT
    dw   call_03_51b8_CollisionHandler_SailorToonGirl         ; COLLISION_TYPE_SAILOR_TOON_GIRL
    dw   call_03_5201_CollisionHandler_BigSilverRobot         ; COLLISION_TYPE_BIG_SILVER_ROBOT
    dw   call_03_5231_CollisionHandler_Mech                   ; COLLISION_TYPE_MECH
    dw   call_03_5274_CollisionHandler_PlanetOBlast           ; COLLISION_TYPE_PLANET_O_BLAST
    dw   call_03_528c_CollisionHandler_StrayCat               ; COLLISION_TYPE_STRAY_CAT
    dw   call_03_52aa_CollisionHandler_Convict                ; COLLISION_TYPE_CONVICT
    dw   call_03_52c8_CollisionHandler_YellowGoon             ; COLLISION_TYPE_YELLOW_GOON
    dw   call_03_52da_CollisionHandler_ChomperTV              ; COLLISION_TYPE_CHOMPER_TV
    dw   call_03_52fa_CollisionHandler_Bomb                   ; COLLISION_TYPE_BOMB
    dw   call_03_531a_CollisionHandler_WaterTowerStand        ; COLLISION_TYPE_WATER_TOWER_STAND
    dw   call_03_532f_CollisionHandler_GextremeSports_Elf     ; COLLISION_TYPE_GEXTREME_SPORTS_ELF
    dw   call_03_537a_CollisionHandler_BonusTimeCoin          ; COLLISION_TYPE_BONUS_TIME_COIN
    dw   call_03_538e_CollisionHandler_Bell                   ; COLLISION_TYPE_BELL
    dw   call_03_53eb_CollisionHandler_Cannon                 ; COLLISION_TYPE_CANNON
    dw   call_03_5406_CollisionHandler_BrainOfOz              ; COLLISION_TYPE_BRAIN_OF_OZ
    dw   call_03_5469_CollisionHandler_BrainOfOzProjectile    ; COLLISION_TYPE_BRAIN_OF_OZ_PROJECTILE
    dw   call_03_5473_CollisionHandler_FreestandingRemote     ; COLLISION_TYPE_FREESTANDING_REMOTE
    dw   call_03_5028_CollisionHandler_Cactus                 ; COLLISION_TYPE_CACTUS
    dw   call_03_5069_CollisionHandler_PlayingCard            ; COLLISION_TYPE_PLAYING_CARD
    dw   call_03_5085_CollisionHandler_HardHat                ; COLLISION_TYPE_HARD_HAT
    dw   call_03_5483_CollisionHandler_Meteor                 ; COLLISION_TYPE_METEOR
    dw   call_03_54a8_CollisionHandler_Rez                    ; COLLISION_TYPE_REZ
    dw   call_03_581a_CollisionHandler_TVButton               ; COLLISION_TYPE_TV_BUTTON
    dw   call_03_54ee_CollisionHandler_RaStatueProjectile     ; COLLISION_TYPE_RA_STATUE_PROJECTILE
    dw   call_03_53c2_CollisionHandler_RockHard               ; COLLISION_TYPE_ROCK_HARD

call_03_4ccf_CollisionHandler_None:
; The default for anything Gex cannot interact with - the goal counters, the bonus
; stage timer, the invisible spawner entities - and what
; call_00_288a_Entity_SetCollisionTypeNone writes over an entity that has just
; been defeated but is still playing its death animation
    ret                                                ;; 03:4ccf $c9

call_03_4cd0_CollisionHandler_InvulnerableEnemy:
; ENTITY_MYSTERY_TV_FISH, the only user. It has no ENTITY_INTERACT_ATTACK or
; _STOMP flag, so the box test can only ever report a touch - which is why this
; damages Gex on carry without bothering to look at A.
;
; Note it goes straight to Player_TakeDamage rather than through
; call_03_4cea_CollisionHandler_DamagePlayer, so the fish costs a hit point but
; produces no knockback and no take-damage animation
    call call_03_550e_Entity_CheckPlayerInteraction
    jp   c,call_00_06f6_Player_TakeDamage
    ret  

call_03_4cd7_CollisionHandler_Projectile:
; The shots that are spent on contact: Safari Sam's, both snake projectiles and
; the secbot's. Damages Gex the full way - knockback and take-damage action - and
; then frees the slot, so the shot vanishes on the frame it lands.
;
; Entity_DeactivateSelf leaves the list entry alone, so the parent is free to fire
; again
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_03_4cea_CollisionHandler_DamagePlayer
    jp   call_00_2b80_Entity_DeactivateSelf

call_03_4ce1_CollisionHandler_GenericEnemy:
; The ordinary enemy, and by far the most used type - eighteen entity types share
; it, from the Holiday TV penguin to Rez's own projectiles.
;
; Touch hurts Gex; anything else spends one of the entity's hit points through
; HandleEntityHit. Note the fall-through: with no `ret` between them, the touch
; case runs straight into call_03_4cea_CollisionHandler_DamagePlayer below rather
; than jumping to it
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4ce1 $cd $0e $55
    ret  NC                                            ;; 03:4ce4 $d0
    cp   A, PLAYER_TOUCHED_ENTITY                                        ;; 03:4ce5 $fe $00
    jp   NZ, call_03_5671_HandleEntityHit                                ;; 03:4ce7 $c2 $71 $56
call_03_4cea_CollisionHandler_DamagePlayer:
; "Gex just got hurt" - the shared damage path, reached by a `jp` from most of the
; handlers in this file as well as by falling out of the one above.
;
; Three things happen, and only the first is conditional:
;
;   1. Player_TakeDamage, unless he is ALREADY in one of the four take-damage
;      actions. So being hit again while reeling costs nothing.
;   2. wDC98_Player_DamageKnockbackX = $01 or $FF, the side AWAY from the entity,
;      worked out from a 16-bit compare of the two world X positions.
;      call_02_7152_Entities_UpdateAll feeds that into wDC84_PlayerXDeltaExtra for
;      as long as the take-damage action runs, so the knockback plays out a pixel
;      at a time.
;   3. The take-damage action itself, picked by which map this is:
;      PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE on MAP_GEXTREME_SPORTS1,
;      PLAYERACTION_KANGAROO_TAKE_DAMAGE on MAP_MARSUPIAL_MADNESS1, and the plain
;      PLAYERACTION_TAKE_DAMAGE everywhere else. Player_RequestAction adds
;      PLAYERACTION_TOPDOWN on top of that for a top-down map.
;
; Steps 2 and 3 run even when step 1 was skipped, so a second hit re-aims the
; knockback and restarts the animation
    ld   A, [wD801_Player_ActionId]                                    ;; 03:4cea $fa $01 $d8
    cp   A, PLAYERACTION_TAKE_DAMAGE                                        ;; 03:4ced $fe $09
    jr   Z, .jr_03_4cfe                                ;; 03:4cef $28 $0d
    cp   A, PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE                                        ;; 03:4cf1 $fe $29
    jr   Z, .jr_03_4cfe                                ;; 03:4cf3 $28 $09
    cp   A, PLAYERACTION_KANGAROO_TAKE_DAMAGE                                        ;; 03:4cf5 $fe $36
    jr   Z, .jr_03_4cfe                                ;; 03:4cf7 $28 $05
    cp   A, PLAYERACTION_TOPDOWN_TAKE_DAMAGE                                        ;; 03:4cf9 $fe $45
    call NZ, call_00_06f6_Player_TakeDamage                              ;; 03:4cfb $c4 $f6 $06
.jr_03_4cfe:
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4d06 $fa $0e $d8
    sub  A, [HL]                                       ;; 03:4d09 $96
    inc  HL                                            ;; 03:4d0a $23
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 03:4d0b $fa $0f $d8
    sbc  A, [HL]                                       ;; 03:4d0e $9e
    ld   A, $ff                                        ;; 03:4d0f $3e $ff
    jr   C, .jr_03_4d15                                ;; 03:4d11 $38 $02
    ld   A, $01                                        ;; 03:4d13 $3e $01
.jr_03_4d15:
    ld   [wDC98_Player_DamageKnockbackX], A                                    ;; 03:4d15 $ea $98 $dc
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
    farcall call_02_54f9_Player_RequestAction
    ret                                                ;; 03:4d37 $c9

call_03_4d38_CollisionHandler_GenericEnemyUnused:
; COLLISION_TYPE_GENERIC_ENEMY_UNUSED. No entity type in
; data_00_3258_EntityAttributeTable carries it and nothing assigns it at runtime,
; so this handler is dead.
;
; It is the generic enemy above with the fall-through spelled out as a `jp`, and
; with the touch case going straight to Player_TakeDamage instead of through the
; knockback path - so it would hurt without staggering
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_TOUCHED_ENTITY
    jp   z,call_00_06f6_Player_TakeDamage
    jp   call_03_5671_HandleEntityHit

call_03_4d44_CollisionHandler_DamagePlayerUnused:
; COLLISION_TYPE_DAMAGE_PLAYER_UNUSED, also never assigned to anything.
;
; Close to call_03_4cea_CollisionHandler_DamagePlayer, with two differences: the
; four take-damage actions make it return outright rather than just skipping the
; damage, and it arms wDC7E_Player_DamageCooldownTimer itself instead of leaving
; that to Player_TakeDamage. An attack is handed to HandleEntityHit first, so
; unlike $4cea this one is a complete handler rather than a tail
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
    ld   [wDC7E_Player_DamageCooldownTimer],a
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   a,[wD80E_PlayerXPosition]
    sub  [hl]
    inc  hl
    ld   a,[wD80E_PlayerXPosition+1]
    sbc  [hl]
    ld   a,$FF
    jr   c,.jr_00_4D78
    ld   a,$01
.jr_00_4D78:
    ld   [wDC98_Player_DamageKnockbackX],a
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
    farcall call_02_54f9_Player_RequestAction
    ret  

call_03_4d9b_CollisionHandler_BonusCoin:
; ENTITY_BONUS_COIN, one per level. Sets PROGRESS_BONUS_COIN_TAKEN_BIT in this
; level's byte of wDC5C_ProgressFlags - which is save data, so the coin stays
; taken - plays SFX_ITEM_PICKUP, and then goes through HandleEntityHit rather than
; deactivating itself.
;
; That is deliberate. The coin's ENTITY_ATTR_DAMAGE_STATE is $02, which the spawn
; turns into a health of 1, so the first hit is fatal - and routing through
; HandleEntityHit is what lets its ENTITY_ATTR_DEFEAT_FLAGS ($81) pick the burst
; and the pickup animation
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4d9b $cd $0e $55
    ret  NC                                            ;; 03:4d9e $d0
    ld   HL, wDC1E_CurrentLevelID                                     ;; 03:4d9f $21 $1e $dc
    ld   L, [HL]                                       ;; 03:4da2 $6e
    ld   H, $00                                        ;; 03:4da3 $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 03:4da5 $11 $5c $dc
    add  HL, DE                                        ;; 03:4da8 $19
    set  4, [HL]                                       ;; 03:4da9 $cb $e6
    ld   A, SFX_ITEM_PICKUP                                        ;; 03:4dab $3e $02
    call call_00_0ff5_QueueSFX                                  ;; 03:4dad $cd $f5 $0f
    jp   call_03_5671_HandleEntityHit                                    ;; 03:4db0 $c3 $71 $56

call_03_4db3_CollisionHandler_FlyCoin:
; ENTITY_FLY_COIN_SPAWN, the ordinary collectible. Bumps wDC68_CollectibleAmount
; through Player_ObtainedCollectible - which is where the 50-coin extra life and
; the 100-coin level-complete flag are paid out - and then dies the same way the
; bonus coin does
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4db3 $cd $0e $55
    ret  NC                                            ;; 03:4db6 $d0
    call call_00_0723_Player_ObtainedCollectible                                  ;; 03:4db7 $cd $23 $07
    ld   A, SFX_ITEM_PICKUP                                        ;; 03:4dba $3e $02
    call call_00_0ff5_QueueSFX                                  ;; 03:4dbc $cd $f5 $0f
    jp   call_03_5671_HandleEntityHit                                    ;; 03:4dbf $c3 $71 $56

call_03_4dc2_CollisionHandler_PawCoin:
; ENTITY_PAW_COIN. Four per level, and the entity's spawn parameter (0-3) says
; which one this is: .data_03_4e00 turns it into a bit mask that is OR'd into this
; level's wDC5C_ProgressFlags byte, so collecting the same paw coin twice cannot
; count twice across saves.
;
; wDCAF_PawCoinCounter counts them within the run. Every fourth one raises
; wDC4F_PawCoinExtraHealth - a permanent extra health point, capped at four -
; resets the counter, and marks the health part of the status bar dirty.
;
; The `sub A, $04 / jr NZ` is an equality test that leaves A at zero on the match,
; which is why the counter reset below is a plain `xor A`
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
    ld   HL, wDB69_HUDDirtyFlags                                     ;; 03:4df3 $21 $69 $db
    set  1, [HL]                                       ;; 03:4df6 $cb $ce
.jr_03_4df8:
    ld   A, SFX_ITEM_PICKUP                                        ;; 03:4df8 $3e $02
    call call_00_0ff5_QueueSFX                                  ;; 03:4dfa $cd $f5 $0f
    jp   call_03_5671_HandleEntityHit                                    ;; 03:4dfd $c3 $71 $56
.data_03_4e00:
; Which bit of wDC5C_ProgressFlags[level] each of the four paw coins owns, indexed
; by the entity's spawn parameter. Bits 5-7; bits 0-4 belong to the remotes, the
; all-collectibles flag and the bonus coin
    db   $00, $20, $40, $80

call_03_4e04_CollisionHandler_Fly:
; ENTITY_FLY_1 through ENTITY_FLY_5, the power-up flies that come out of a fly TV.
;
; The entity id says which fly this is, and .data_03_4e2c turns that into a
; FLY_POWERUP_* id for Player_SwapFlyPowerup. Remember what swapping does: the
; argument becomes the fly Gex is now CARRYING, and it is the fly being displaced
; whose effect fires. Eating a fly cashes in the previous one.
;
; It then reaches through ENTITY_FIELD_PARENT into the fly TV's own
; wD700_EntityFlags entry and rewrites the low nibble to 3 - the action the TV
; respawns in - keeping the flags nibble. So the TV stays open after the player
; leaves the room and comes back
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_00_293a_Entity_GetId
    sub  a,04
    ld   l,a
    ld   h,00
    ld   de,.data_03_4e2c
    add  hl,de
    ld   a,[hl]
    call call_00_0624_Player_SwapFlyPowerup
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_PARENT
    ld   l,[hl]
    ld   h,HIGH(wD700_EntityFlags)
    ld   a,[hl]
    and  a,$F0
    or   a,$03
    ld   [hl],a
    jp   call_00_2b80_Entity_DeactivateSelf
.data_03_4e2c:
; FLY_POWERUP_* by fly entity id, indexed by (id - ENTITY_FLY_1):
; FLY_POWERUP_HEALTH, _EXTRA_LIFE, _1, _5, _2
    db   $03, $04, $01, $05, $02

call_03_4e31_CollisionHandler_FlyTV:
; The five fly TVs. ENTITY_INTERACT_ATTACK only, so they cannot hurt Gex and
; cannot be stomped open - the tail spin is the only way in.
;
; Action $00 is the closed TV; the guard means a TV that is already open ignores
; further hits. On a hit it plays SFX_FLY_TV and spends the TV's one hit point.
; HandleEntityHit reads ENTITY_ATTR_DEFEAT_FLAGS ($01) and sends it to action $01,
; the opening animation, whose data block carries a pending action of $02 - so
; when that animation ends the TV moves itself to FlyTV_SpawnFly and the fly comes
; out. List state 2 records all of that for a revisit
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,SFX_FLY_TV
    call call_00_0ff5_QueueSFX
    call call_03_5671_HandleEntityHit
    ld   c,$02
    jp   call_00_2299_Entity_SetListState

call_03_4e4b_CollisionHandler_IceSculpture:
; ENTITY_HOLIDAY_TV_ICE_SCULPTURE - five of them in the level, and the first of
; the "collect N of these" handlers.
;
; Each sculpture takes two hits: action $00 -> $01 -> $02, driven straight from
; here rather than by the entity's own action code. The action id doubles as the
; list state, so a half-broken sculpture is still half-broken when the player
; comes back.
;
; Reaching action $02 - fully broken - bumps wDCC3_IceSculptureCounter, and the
; fifth one plays SFX_REMOTE through Entity_PlayRemoteSFX. Either way the running
; total goes to Entity_SpawnGoalCounter, which puts the pips on screen.
;
; The two `push AF` are because Entity_SetListState and Entity_SetAction both want
; the new action id and neither preserves it
    call call_00_2962_Entity_GetActionId                                  ;; 03:4e4b $cd $62 $29
    cp   A, $02                                        ;; 03:4e4e $fe $02
    ret  NC                                            ;; 03:4e50 $d0
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4e51 $cd $0e $55
    ret  NC                                            ;; 03:4e54 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:4e55 $fe $01
    ret  NZ                                            ;; 03:4e57 $c0
    ld   A, SFX_SMALL_BANG                                        ;; 03:4e58 $3e $19
    call call_00_0ff5_QueueSFX                                  ;; 03:4e5a $cd $f5 $0f
    call call_00_2962_Entity_GetActionId                                  ;; 03:4e5d $cd $62 $29
    inc  A                                             ;; 03:4e60 $3c
    push AF                                            ;; 03:4e61 $f5
    push AF                                            ;; 03:4e62 $f5
    ld   C, A                                          ;; 03:4e63 $4f
    call call_00_2299_Entity_SetListState                                  ;; 03:4e64 $cd $99 $22
    pop  AF                                            ;; 03:4e67 $f1
    farcall call_02_72ac_Entity_SetAction
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
; The snowball Evil Santa throws, and the most involved handler in the file
; because the snowball can be volleyed back at him.
;
; Two guards: the snowball is inert while its Y velocity is negative, and while it
; is in action $05 or above (the states it uses once it has been returned or has
; landed).
;
; A TOUCH or a STOMP is the ordinary case: action $06, then the shared damage path.
;
; An ATTACK sends it back. It negates the Y velocity in place - Entity_GetYVelocity
; leaves HL on the field, which is what makes the `cpl / inc A / ld [HL], A` work -
; then looks for Santa. With no Santa loaded there is nowhere to send it, so the
; snowball just frees its slot.
;
; With Santa loaded it measures the 16-bit gap between them, takes the absolute
; value, clamps it to $A0 and divides by four to index .data_03_4efa, which turns
; that distance into an X velocity. Sign it toward Santa and the snowball arrives
; at him rather than sailing past - so the return speed is chosen by how far away
; he is standing
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
    call call_00_29ce_Entity_FindSlotById                                  ;; 03:4ea5 $cd $ce $29
    jp   NZ, call_00_2b80_Entity_DeactivateSelf                              ;; 03:4ea8 $c2 $80 $2b
    ld   A, L                                          ;; 03:4eab $7d
    or   A, ENTITY_FIELD_WORLD_X                                        ;; 03:4eac $f6 $0e
    ld   L, A                                          ;; 03:4eae $6f
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:4eaf $fa $00 $da
    or   A, ENTITY_FIELD_WORLD_X                                        ;; 03:4eb2 $f6 $0e
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
    farcall call_02_72ac_Entity_SetAction
    jp   call_03_4cea_CollisionHandler_DamagePlayer                                   ;; 03:4ef7 $c3 $ea $4c
.data_03_4efa:
; Return speed by distance, indexed by (clamped distance to Santa) >> 2. Almost
; the identity - it rises by one per step and skips a value every twelfth entry,
; so a snowball thrown from further away comes back proportionally faster
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 03:4efa ???.????
    db   $08, $09, $0a, $0b, $0d, $0e, $0f, $10        ;; 03:4f02 ????????
    db   $11, $12, $13, $14, $15, $16, $17, $18        ;; 03:4f0a ????????
    db   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21        ;; 03:4f12 ????????
    db   $22, $23, $24, $25, $27, $28, $29, $2a        ;; 03:4f1a ????????
    db   $2b                                           ;; 03:4f22 ?

call_03_4f23_CollisionHandler_HolidayTV_Elf:
; ENTITY_HOLIDAY_TV_SKATING_ELF. Touch hurts. An attack puts the elf into action
; $04 and takes one off its health.
;
; The health is not in the entity - it is wDCD5_ElfHealth1 and the four bytes
; after it, indexed by the elf's spawn parameter, so it survives the elf being
; despawned and respawned as the player skates past. That is also why nothing here
; calls HandleEntityHit: the elf's ENTITY_ATTR_DAMAGE_STATE is $00, which the
; spawn turns into $FF, and $FF means invulnerable. Reaching zero makes the elf
; harmless (COLLISION_TYPE_NONE), retires its list entry, and bumps
; wDCC8_ElfCounter for the goal display.
;
; The last three lines are the "all of them" test - if the first two health bytes
; are both zero it plays SFX_REMOTE. Note that only tests two of the five, unlike
; call_03_532f_CollisionHandler_GextremeSports_Elf below, which walks all five
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:4f23 $cd $0e $55
    ret  NC                                            ;; 03:4f26 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:4f27 $fe $01
    jp   NZ, call_03_4cea_CollisionHandler_DamagePlayer                               ;; 03:4f29 $c2 $ea $4c
    ld   A, $04                                        ;; 03:4f2c $3e $04
    farcall call_02_72ac_Entity_SetAction
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
    call call_00_2b8b_Entity_MarkDefeated                                  ;; 03:4f4a $cd $8b $2b
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
; ENTITY_MYSTERY_TV_BLOOD_COOLER, three per level. ENTITY_INTERACT_ATTACK only.
;
; One hit each: action $00 is the intact cooler, HandleEntityHit breaks it, and
; list state 1 records that for a revisit. wDCC5_BloodCoolerCounter counts them
; and the third plays SFX_REMOTE
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    ld   a,SFX_SMALL_BANG
    call call_00_0ff5_QueueSFX
    ld   c,$01
    call call_00_2299_Entity_SetListState
    ld   hl,wDCC5_BloodCoolerCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC5_BloodCoolerCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter

call_03_4f8c_CollisionHandler_MagicSword:
; ENTITY_MYSTERY_TV_MAGIC_SWORD, a one-off pickup. Any contact takes it: plays
; SFX_REMOTE with trigger 3 and spends its hit point.
;
; Entity_PlayRemoteSFX does two things despite the name - it plays the sound AND
; marks tv button C as pressed, which is how a collected item unlocks the tv
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    ld   c,$03
    call call_00_21ef_Entity_PlayRemoteSFX
    jp   call_03_5671_HandleEntityHit

call_03_4f98_CollisionHandler_GhostKnight:
; ENTITY_MYSTERY_TV_GHOST_KNIGHT. Touch hurts; an attack spends a hit point.
;
; The extra test at the end is the kill: action $05 is the state the knight is put
; into when HandleEntityHit runs it out of health, so seeing it means this hit was
; the last one, and the trigger goes up for whatever the level was waiting on
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
; ENTITY_TUT_TV_HAND, the mummy hand that comes out of the sand. Touch hurts; an
; attack in action $00 - dormant, still buried - sends it to action $01.
;
; It has no HandleEntityHit call, so the hand cannot be destroyed: whipping it only
; wakes it up
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_00_2995_Entity_GetActionId_Copy
    cp   a,$00
    ret  nz
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_4fca_CollisionHandler_LostArk:
; ENTITY_TUT_TV_LOST_ARK, three per level, and ENTITY_INTERACT_STOMP only - the
; one collectible in the game that has to be jumped on rather than whipped.
;
; Action $00 is the unopened ark. List state 4 records it as taken;
; wDCC6_LostArkCounter counts them and the third plays SFX_REMOTE
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_STOMPED_ENTITY
    ret  nz
    call call_03_5671_HandleEntityHit
    ld   c,$04
    call call_00_2299_Entity_SetListState
    ld   hl,wDCC6_LostArkCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$02
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC6_LostArkCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter
    
call_03_4ff1_CollisionHandler_RaStaff:
; ENTITY_TUT_TV_RA_STAFF, three per level, attack only. Same shape as the ark
; above without the action guard or the list state, so the staff relies on
; HandleEntityHit alone to remove itself
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
; ENTITY_TUT_TV_COFFIN. Attack only, action $00 only, and all it does is send the
; coffin to action $01 - the open one, which is where whatever was inside comes
; out. No damage either way
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    ret  
   
call_03_5028_CollisionHandler_Cactus:
; ENTITY_WESTERN_STATION_ENEMY_CACTUS - the cactus that springs up out of the
; ground. Three rules, and the routine runs all three every frame rather than
; returning early.
;
; WHO CAN HURT WHOM. A touch, or an attack with no fly power-up running, means the
; cactus is the dangerous one - but only in action $05, the sprung state. Attacking
; it WITH a power-up running (any of the three timers at
; wDCA9_FlyPowerup2_Timer) spends a hit point instead, and only in actions below
; $05. So an unpowered tail spin does nothing at all.
;
; WHEN IT SPRINGS. The tail at .jr_00_504C runs whatever happened above: in
; actions below $04 it measures the distance to Gex and jumps to action $05 the
; moment he is within $28. That is the only thing that triggers the cactus, so it
; is proximity rather than contact.
;
; The `ldi a,[hl] / or [hl] / inc hl / or [hl]` idiom is "is any fly power-up
; running", and it appears in three handlers in this file
    call call_03_550e_Entity_CheckPlayerInteraction
    jr   nc,.jr_00_504C
    cp   a,PLAYER_TOUCHED_ENTITY
    jr   z,.jr_00_5044
    ld   hl,wDCA9_FlyPowerup2_Timer
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
    farcall call_02_72ac_Entity_SetAction
    ret  

call_03_5069_CollisionHandler_PlayingCard:
; ENTITY_WESTERN_STATION_PLAYING_CARD, five per level. Attack or stomp, either
; works - a touch does nothing. wDCCF_PlayingCardCounter counts them and the fifth
; plays SFX_REMOTE
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
; ENTITY_WESTERN_STATION_HARD_HAT - the miner who ducks under his helmet.
;
; Touch hurts. What an attack does depends on what he is doing:
;
;   action $01  jumping, and the only state he is vulnerable in - HandleEntityHit
;   action $02  already ducked - the hit pops him back up into $01
;   otherwise   he ducks, into $02, and the hit is wasted
;
; So the fight is a timing puzzle: whip him while he is up, or all you do is make
; him hide
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
    farcall call_02_72ac_Entity_SetAction
    ret  
.jr_00_50A8:
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    ret  

call_03_50b6_CollisionHandler_AlienCultureTube:
; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE, three per level, attack only. Breaking
; one raises its level trigger as well as counting it, so a tube can be wired to a
; door; wDCC9_AlienCultureTubeCounter is the goal display and the third plays
; SFX_REMOTE
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
    call call_00_2299_Entity_SetListState
    ld   hl,wDCC9_AlienCultureTubeCounter
    inc  [hl]
    ld   a,[hl]
    cp   a,$03
    ld   c,$01
    call z,call_00_21ef_Entity_PlayRemoteSFX
    ld   a,[wDCC9_AlienCultureTubeCounter]
    jp   call_00_2c09_Entity_SpawnGoalCounter

call_03_50e0_CollisionHandler_OnSwitch:
; ENTITY_ANIME_CHANNEL_ON_SWITCH. A whip sets this entity's slot in
; wDCB1_LevelTriggerBuffer - the sixteen-byte scratchpad a level uses to wire
; switches to doors, indexed by the entity's spawn parameter. Nothing is damaged
; and nothing is consumed, so the switch can be thrown as often as you like
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   z,call_00_22ef_Entity_SetTriggerActive
    ret  
    
call_03_50ea_CollisionHandler_OffSwitch:
; ENTITY_ANIME_CHANNEL_OFF_SWITCH, the mirror of the one above: a whip clears the
; trigger slot instead of setting it
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   z,call_00_22ff_Entity_SetTriggerInactive
    ret  
    
call_03_50f4_CollisionHandler_OnSwitch2:
; ENTITY_ANIME_CHANNEL_ON_SWITCH2, the one-shot switch. Action $00 is the unthrown
; one, so it can only fire once; throwing it records list state 1 (so it stays
; thrown on a revisit), moves it to action $01, and INCREMENTS its trigger slot
; rather than setting it.
;
; That is the difference from the plain on-switch, and it is what lets a door
; count several switches - see the `cp a,$02` in
; call_02_659d_EntityAction_AnimeDisappearingFloor_WaitForSwitches
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   c,$01
    call call_00_2299_Entity_SetListState
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    jp   call_00_22e0_Entity_IncrementTriggerFlag
    
call_03_5116_CollisionHandler_Door:
; ENTITY_ANIME_CHANNEL_DOOR. Not a collision so much as a "press up to enter"
; prompt, and it wants four things at once: the door closed (action $00), Gex
; overlapping it, Gex on the ground (BGCOLL_NO_COLLISION_BIT in
; wDABE_CollisionFlags), UP held, and his action between PLAYERACTION_IDLE and
; PLAYERACTION_WALK - so he has to be standing still.
;
; Then the lock. A spawn parameter of $FF means the door is not wired to anything
; and opens freely. Otherwise its trigger slot has to be set; when it is not, the
; door plays SFX_DOOR2 - the rattle - and returns without opening.
;
; Opening is SFX_DOOR1 and action $01
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    ld   hl,wDABE_CollisionFlags
    bit  7,[hl]
    ret  z
    ld   hl,wDC81_Player_EffectiveInputs
    bit  PADF_UP_BIT,[hl]
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
    jp   z,call_00_0ff5_QueueSFX
.jr_00_5143:
    ld   a,SFX_DOOR1
    call call_00_0ff5_QueueSFX
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    ret  

call_03_5156_CollisionHandler_Door2:
; ENTITY_ANIME_CHANNEL_DOOR2. The same routine again for the far side of a door
; pair: it waits in action $02 rather than $00, and opens into $03. Every other
; line is identical to the one above
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    ld   hl,wDABE_CollisionFlags
    bit  7,[hl]
    ret  z
    ld   hl,wDC81_Player_EffectiveInputs
    bit  PADF_UP_BIT,[hl]
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
    jp   z,call_00_0ff5_QueueSFX
.jr_00_5183:
    ld   a,SFX_DOOR1
    call call_00_0ff5_QueueSFX
    ld   a,$03
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_5196_CollisionHandler_Secbot:
; ENTITY_ANIME_CHANNEL_SECBOT. Touch hurts; an attack spends a hit point and then
; reads the action back to see what that left it in. Action $00 means it is still
; standing and gets knocked into $02; anything else raises its level trigger -
; which covers the death action $04 HandleEntityHit gives it, and also,
; incidentally, a survived hit landed while it was already in $02
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$00
    jp   nz,call_00_22ef_Entity_SetTriggerActive
    ld   a,$02
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_51b8_CollisionHandler_SailorToonGirl:
; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL. Touch hurts. An attack has two outcomes
; depending on whether she has already been beaten down to action $02:
;
;   not yet     spend a hit point; if that leaves her in $02 record it as list
;               state 2, otherwise knock her into action $03
;   action $02  the finish: raise her trigger, blank the collision type, reset the
;               facing, start a burst and send her to action $07
;
; ENTITY_FACING_RIGHT is passed to Entity_SetCollisionType as well as to
; Entity_SetFacingDirection - the two constants happen to share the value $00, so
; the first call is really "make her harmless"
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
    jp   z,call_00_2299_Entity_SetListState
    ld   a,$03
    farcall call_02_72ac_Entity_SetAction
    ret  
.jr_00_51E3:
    call call_00_22ef_Entity_SetTriggerActive
    ld   c,ENTITY_FACING_RIGHT
    call call_00_288c_Entity_SetCollisionType
    ld   c,ENTITY_FACING_RIGHT
    call call_00_2958_Entity_SetFacingDirection
    call call_00_2c67_Particle_InitBurst
    ld   a,$07
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_5201_CollisionHandler_BigSilverRobot:
; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT. Action $03 is its beaten state and is
; skipped entirely.
;
; An attack turns it to face Gex first and then spends a hit point, so the robot
; always dies facing him; if that leaves it in $03 its trigger goes up. A touch
; damages Gex, knocks the robot into action $02 and turns it to face him as well -
; so walking into it is what makes it round on you
    call call_00_2962_Entity_GetActionId
    cp   a,$03
    ret  z
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jr   z,.jr_00_5222
    call call_03_4cea_CollisionHandler_DamagePlayer
    ld   a,$02
    farcall call_02_72ac_Entity_SetAction
    jp   call_00_2410_Entity_FaceTowardsPlayer
.jr_00_5222:
    call call_00_2410_Entity_FaceTowardsPlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$03
    jp   z,call_00_22ef_Entity_SetTriggerActive
    ret  
    
call_03_5231_CollisionHandler_Mech:
; The two Anime Channel mechs. Touch hurts. An attack does nothing at all unless a
; fly power-up is running - the same three-timer test the cactus uses - which is
; what makes the mechs the level's power-up gate.
;
; A hit that lands spends a hit point and, if that left the mech in action $01,
; increments its trigger slot. On the two MAP_ANIME_CHANNEL rooms that have a
; goal display it also counts toward wDCCB_MechCounter, with the fourth playing
; SFX_REMOTE.
;
; The five instructions after the final `jp` are unreachable - a leftover copy of
; a plain touch-damage handler
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    ld   hl,wDCA9_FlyPowerup2_Timer
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
; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON, and ENTITY_INTERACT_STOMP only - it
; has to be landed on. Spends a hit point, and if that left it in action $01 plays
; SFX_REMOTE and CLEARS its trigger slot, which is the one place in this file a
; pickup turns a trigger off rather than on
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
; ENTITY_SUPERHERO_SHOW_STRAY_CAT, three per level. Touch hurts; an attack or a
; stomp - it is one of the few enemies that can be jumped on - spends a hit point
; and counts toward wDCCA_StrayCatCounter, with the third playing SFX_REMOTE
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
; ENTITY_SUPERHERO_SHOW_CONVICT, five per level. Touch hurts, attack counts, and
; the fifth plays SFX_REMOTE. Structurally the stray cat above without the stomp
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
; ENTITY_SUPERHERO_SHOW_YELLOW_GOON, and the only enemy in the game with a back.
;
; Entity_IsFacingPlayer returns Z when the goon is looking at Gex, and that case
; is routed to the damage path - so whipping him from the front hurts YOU. Come at
; him from behind and the same attack spends a hit point instead
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_00_29ac_Entity_IsFacingPlayer
    jp   z,call_03_4cea_CollisionHandler_DamagePlayer
    jp   call_03_5671_HandleEntityHit
    
call_03_52da_CollisionHandler_ChomperTV:
; ENTITY_SUPERHERO_SHOW_CHOMPER_TV. Touch hurts; an attack spends a hit point and
; then knocks it into action $02 unless it is already in $03, its beaten state
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    call call_00_2962_Entity_GetActionId
    cp   a,$03
    ret  z
    ld   a,$02
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_52fa_CollisionHandler_Bomb:
; ENTITY_SUPERHERO_SHOW_BOMB. Which of two handlers runs depends on the fuse:
;
;   action $04  already lit and lethal - hand the whole thing to the generic
;               enemy handler, so it hurts on contact and can be destroyed
;   action $02  unlit; an attack lights it, into action $03
;   otherwise   nothing
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
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_531a_CollisionHandler_WaterTowerStand:
; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND - the legs holding up the water tower.
; It cannot hurt Gex, and it can only be cut down with a fly power-up running (the
; same three-timer test as the cactus and the mechs). Spending its hit point
; raises its trigger, which is what drops the tank
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   hl,wDCA9_FlyPowerup2_Timer
    ldi  a,[hl]
    or   [hl]
    inc  hl
    or   [hl]
    ret  z
    call call_03_5671_HandleEntityHit
    jp   call_00_22ef_Entity_SetTriggerActive
    
call_03_532f_CollisionHandler_GextremeSports_Elf:
; ENTITY_GEXTREME_SPORTS_ELF, the snowboarding level's elves. Almost the same
; routine as call_03_4f23_CollisionHandler_HolidayTV_Elf - the same shared health
; bytes at wDCD5_ElfHealth1, the same action $04 on a hit, the same
; wDCC8_ElfCounter - with two changes:
;
;   it only runs in actions below $04, so an elf already reeling ignores further
;   hits
;   the "all of them beaten" test walks all five health bytes rather than two, and
;   sets wDCD2_FreestandingRemoteHitFlags instead of playing a sound - the level's
;   remote is what appears
    call call_00_2962_Entity_GetActionId
    cp   a,$04
    ret  nc
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    ld   a,$04
    farcall call_02_72ac_Entity_SetAction
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
    call call_00_2b8b_Entity_MarkDefeated
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
; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN. Attack only. Adds the entity's spawn
; parameter to wDB6E_LevelTimer_SecondsRemaining, so how much time each coin is
; worth is level data rather than code, and then takes the coin
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    call call_00_230f_Entity_GetParameterIntoC
    ld   a,[wDB6E_LevelTimer_SecondsRemaining]
    add  c
    ld   [wDB6E_LevelTimer_SecondsRemaining],a
    jp   call_03_5671_HandleEntityHit
    
call_03_538e_CollisionHandler_Bell:
; ENTITY_MARSUPIAL_MADNESS_BELL, seven of them, attack only.
;
; Only a bell in action $00 counts: it bumps wDCCC_BellCounter, updates the goal
; display, and the seventh sets wDCD2_FreestandingRemoteHitFlags to bring out the
; remote. Every hit, counted or not, still rings it - action $01 and list state 2 -
; so a bell already struck animates again without scoring twice
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
    farcall call_02_72ac_Entity_SetAction
    ld   c,$02
    jp   call_00_2299_Entity_SetListState

call_03_53c2_CollisionHandler_RockHard:
; ENTITY_WW_GEX_WRESTLING_ROCK_HARD, the wrestling boss. Actions $05 and up are
; his defeat sequence and are ignored.
;
; Action $03 is his body slam, and it is the one state where HE hurts GEX - but
; only once he has actually come down, which is what the wDC88_Player_HopYOffset
; test is: zero means the hop is over. Landing the slam sends him to action $01
; and damages Gex.
;
; In every other action an attack spends one of his hit points and a touch does
; nothing, so the fight is "whip him while he is not slamming"
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
    ld   a,[wDC88_Player_HopYOffset]
    and  a
    ret  nz
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    jp   call_03_4cea_CollisionHandler_DamagePlayer
    
call_03_53eb_CollisionHandler_Cannon:
; ENTITY_LIZARD_OF_OZ_CANNON. Attack only, action $02 only - the loaded cannon -
; and all it does is fire it, by moving it to action $03. The cannonball it
; produces is what actually hurts the boss; see the handler below
    call call_00_2962_Entity_GetActionId
    cp   a,$02
    ret  nz
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    ret  nz
    ld   a,$03
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_5406_CollisionHandler_BrainOfOz:
; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ, and the one place in either game where an
; entity is tested against another ENTITY rather than against Gex.
;
; It starts by running the generic enemy handler, so touching the brain hurts and
; a tail spin scores an ordinary hit. Then, in actions below $06, it looks for a
; live ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE, checks that it is still travelling
; (bit 7 of its Y velocity), and measures the brain against it in both axes with
; the same +$0C / < $18 pattern used everywhere in this file - a 24 by 24 box.
;
; A cannonball inside that box is a real hit: HandleEntityHit, and then action $06
; unless the brain is already in $07. So the cannon is how the boss is beaten, and
; this handler - not the cannonball's - is where that is decided.
;
; The `or a,$1D` and `xor a,$13` walk L from the cannonball's slot base to its
; Y_VELOCITY and then to its WORLD_X, with DE pointing at the brain's own
    call call_03_4ce1_CollisionHandler_GenericEnemy
    call call_00_2995_Entity_GetActionId_Copy
    cp   a,$06
    ret  nc
    ld   c,ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    call call_00_29ce_Entity_FindSlotById
    ret  nz
    ld   a,l
    or   a,$1D
    ld   l,a
    bit  7,[hl]
    ret  z
    ld   a,l
    xor  a,$13
    ld   l,a
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_X
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
    call call_00_2995_Entity_GetActionId_Copy
    cp   a,$07
    ret  z
    ld   a,$06
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_5469_CollisionHandler_BrainOfOzProjectile:
; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE. Any contact damages Gex and retires
; the shot for good - Entity_DeactivateAndMarkNeverRespawn, not the plain
; Deactivate the other projectiles use, so a shot the boss has spent does not come
; back when the room reloads
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_03_4cea_CollisionHandler_DamagePlayer
    jp   call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn

call_03_5473_CollisionHandler_FreestandingRemote:
; ENTITY_FREESTANDING_REMOTE - the remote sitting in the open at the end of a
; level. Attack only, and all it does is set wDCD2_FreestandingRemoteHitFlags to
; $81; the remote's own action code watches that byte and writes the progress
; flags.
;
; The Entity_GetActionId call above it is dead - A is overwritten on the next line
    call call_03_550e_Entity_CheckPlayerInteraction                                  ;; 03:5473 $cd $0e $55
    ret  NC                                            ;; 03:5476 $d0
    cp   A, PLAYER_ATTACKED_ENTITY                                        ;; 03:5477 $fe $01
    ret  NZ                                            ;; 03:5479 $c0
    call call_00_2962_Entity_GetActionId                                  ;; 03:547a $cd $62 $29
    ld   A, $81                                        ;; 03:547d $3e $81
    ld   [wDCD2_FreestandingRemoteHitFlags], A                                    ;; 03:547f $ea $d2 $dc
    ret                                                ;; 03:5482 $c9
    
call_03_5483_CollisionHandler_Meteor:
; ENTITY_CHANNEL_Z_METEOR. Touch only, and the action decides which way it goes:
;
;   action $00  the meteor is parked above the camera waiting for its turn -
;               Entity_SetYToAboveCameraTop puts it back at the top of the screen
;               and starts it falling, into action $01
;   action $01  falling, and now it hurts
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
    call call_00_27cb_Entity_SetYToAboveCameraTop
    ld   a,$01
    farcall call_02_72ac_Entity_SetAction
    ret                                          ;; 03:5482 $c9
    
call_03_54a8_CollisionHandler_Rez:
; ENTITY_CHANNEL_Z_REZ, the final boss. Only actions below $03 can be hit at all;
; his intro action is additionally marked ACTION_STATE_NO_COLLISION, so the
; dispatcher never even reaches this routine during it.
;
; Touch hurts. An attack spends a hit point and then zeroes
; ENTITY_FIELD_COOLDOWN_TIMER, undoing the invulnerability window HandleEntityHit
; had just armed - so Rez, alone among everything in the game, can be hit again
; immediately.
;
; What he does next comes from the health that is left: the multiples of three
; ($03, $06, $09, $0C) send him to action $03 and everything else to action $09.
; Action $0A is the one exception - that is the death HandleEntityHit has just
; given him (ENTITY_ATTR_DEFEAT_FLAGS is $8A), so the routine returns rather than
; choosing anything else
    call call_00_2995_Entity_GetActionId_Copy
    cp   a,$03
    ret  nc
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    cp   a,PLAYER_ATTACKED_ENTITY
    jp   nz,call_03_4cea_CollisionHandler_DamagePlayer
    call call_03_5671_HandleEntityHit
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COOLDOWN_TIMER
    ld   [hl],$00
    call call_00_2995_Entity_GetActionId_Copy
    cp   a,$0A
    ret  z
    call call_00_28b4_Entity_GetDamageState
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
    farcall call_02_72ac_Entity_SetAction
    ret  
    
call_03_54ee_CollisionHandler_RaStatueProjectile:
; The two Ra statue projectiles. Any contact damages Gex and then resets the shot
; to action $00 rather than freeing its slot - the statue fires the same entity
; over and over, so recycling it is cheaper than a respawn
    call call_03_550e_Entity_CheckPlayerInteraction
    ret  nc
    call call_03_4cea_CollisionHandler_DamagePlayer
    ld   a,$00
    farcall call_02_72ac_Entity_SetAction
    ret  

call_03_54f9_InitializeEntityCooldownTimer:
; Arms the current entity's post-hit invulnerability window by hand.
;
; Nothing calls it. HandleEntityHit writes the same value inline, which is
; presumably what this was factored out of
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_COOLDOWN_TIMER
    ld   [hl],TIMER_AMOUNT_60_FRAMES
    ret  

call_03_550e_Entity_CheckPlayerInteraction:
; The shared box test, called by nearly every handler as its first act. Everything
; is in world coordinates and 16 bits wide, which is why each comparison is a
; sub/sbc pair with the high byte checked for zero.
;
; Returns carry clear when there is no contact. On contact it returns carry set
; and, in A, *how* Gex made it:
;
;   PLAYER_TOUCHED_ENTITY   ($00) he ran into it
;   PLAYER_ATTACKED_ENTITY  ($01) he was tail spinning
;   PLAYER_STOMPED_ENTITY   ($02) he landed on it from above
;
; The order of the tests matters as much as the tests themselves:
;
;   1. COOLDOWN. An entity whose ENTITY_FIELD_COOLDOWN_TIMER is still running
;      reports no contact at all - it can neither be hit nor hurt Gex. That is
;      the whole of enemy hit invulnerability, and it is why a handler can call
;      HandleEntityHit without any state of its own.
;   2. The entity's ENTITY_INTERACT_* flags are cached in
;      wDC58_CurrentEntityInteractionFlags for the two tests further down.
;   3. VERTICAL: |entityY - playerY| <= ENTITY_FIELD_COLLISION_HEIGHT. The
;      player's tested Y is his world Y plus wDC88_Player_HopYOffset, and plus a
;      further 8 while he is in PLAYERACTION_CROUCH_LOOK_DOWN - which is what lets
;      ducking take him under something he would otherwise walk into.
;   4. A LOOSE HORIZONTAL box: |dx| <= width + 8, the 8 being Gex's own half
;      width.
;   5. ATTACK, if ENTITY_INTERACT_ATTACK is set and wDC7F_Player_IsAttacking is
;      raised. It CLEARS that flag on the way out, so one tail spin connects with
;      exactly one entity - the first one this sweep reaches, in slot order.
;   6. A TIGHT HORIZONTAL box, reached only when no attack registered: |dx| <=
;      width, with Gex's 8 pixels taken back off. An attack therefore has 8 pixels
;      more reach on each side than a touch or a stomp does.
;   7. STOMP, if ENTITY_INTERACT_STOMP is set, Gex is in one of the four jump
;      actions (two on foot, two on the snowboard) and his Y velocity is downward.
;      This is also where the bounce happens - it rewrites wDC8C_PlayerYVelocity
;      to PLAYER_JUMP_VELOCITY itself, so no handler has to.
;   8. Otherwise TOUCH - but only if Player_IsInvincible says he can be hurt.
;      During the flicker after a hit a touch is reported as no contact, which is
;      how gex3 stops a handler acting on a hit it did not actually land.
;
; ENTITY_INTERACT_TOUCH (bit 0) is never tested, here or anywhere else - it is
; documentation only. Whether a touch does anything is up to the handler.
;
; The `ld A,$FF / add A,n` endings load the result and set carry in two
; instructions, at the cost of the operand reading one higher than the value
; actually returned
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
    ld   A, [wDC88_Player_HopYOffset]                                    ;; 03:5542 $fa $88 $dc
    ld   E, A                                          ;; 03:5545 $5f
    ld   D, $00                                        ;; 03:5546 $16 $00
    bit  7, A                                          ;; 03:5548 $cb $7f
    jr   Z, .jr_03_554d                                ;; 03:554a $28 $01
    dec  D                                             ;; 03:554c $15
.jr_03_554d:
    add  HL, DE                                        ;; 03:554d $19
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:554e $fa $00 $da
    or   A, ENTITY_FIELD_WORLD_Y                                        ;; 03:5551 $f6 $10
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
    ld   A, [BC]                                       ;; 03:555f $0a ; loads ENTITY_FIELD_COLLISION_HEIGHT
    add  A, E                                          ;; 03:5560 $83
    ld   E, A                                          ;; 03:5561 $5f
    ld   A, $00                                        ;; 03:5562 $3e $00
    adc  A, D                                          ;; 03:5564 $8a
    jp   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:5565 $c2 $fd $55
    ld   A, [BC]                                       ;; 03:5568 $0a ; loads ENTITY_FIELD_COLLISION_HEIGHT
    add  A, A                                          ;; 03:5569 $87
    cp   A, E                                          ;; 03:556a $bb
    jp   C, .jr_03_55fd_ReturnNoInteraction                                 ;; 03:556b $da $fd $55
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:556e $21 $0e $d8
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:5571 $fa $00 $da
    or   A, ENTITY_FIELD_WORLD_X                                        ;; 03:5574 $f6 $0e
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
    ld   A, [BC]                                       ;; 03:5583 $0a ; loads ENTITY_FIELD_COLLISION_WIDTH
    add  A, $08                                        ;; 03:5584 $c6 $08
    add  A, E                                          ;; 03:5586 $83
    ld   E, A                                          ;; 03:5587 $5f
    ld   A, $00                                        ;; 03:5588 $3e $00
    adc  A, D                                          ;; 03:558a $8a
    jr   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:558b $20 $70
    ld   A, [BC]                                       ;; 03:558d $0a ; loads ENTITY_FIELD_COLLISION_WIDTH
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
    or   A, ENTITY_FIELD_WORLD_X                                        ;; 03:55af $f6 $0e
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
    call call_00_0759_Player_IsInvincible                                  ;; 03:55f3 $cd $59 $07
    jr   NZ, .jr_03_55fd_ReturnNoInteraction                                ;; 03:55f6 $20 $05
    ld   A, $ff                                        ;; 03:55f8 $3e $ff
    add  A, $01                                        ;; 03:55fa $c6 $01
    ret                                                ;; 03:55fc $c9
.jr_03_55fd_ReturnNoInteraction:
; The shared "nothing happened" exit: A = 0 and carry clear, which is what every
; caller's `ret nc` is looking at
    xor  A, A                                          ;; 03:55fd $af
    ret                                                ;; 03:55fe $c9
.data_03_55ff_EntityInteractionFlagsTable:
; One flags byte per entity TYPE, in ENTITY_* order, saying which kinds of contact
; that type reacts to. Read only by call_03_550e_Entity_CheckPlayerInteraction,
; which caches it in wDC58_CurrentEntityInteractionFlags:
;   bit 0 ($01) ENTITY_INTERACT_TOUCH  - never tested; documentation only
;   bit 1 ($02) ENTITY_INTERACT_ATTACK - a tail spin connects
;   bit 2 ($04) ENTITY_INTERACT_STOMP  - landing on it connects, and bounces Gex
;
; An entity with neither ATTACK nor STOMP can still report a touch, so
; ENTITY_INTERACT_NONE means "reports touches and nothing else" rather than "is
; not tested"
    db   ENTITY_INTERACT_NONE ; ENTITY_GEX
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_BONUS_COIN
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_FLY_COIN_SPAWN
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_PAW_COIN
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_FLY_1
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_FLY_2
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_FLY_3
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_FLY_4
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_FLY_5
    db   ENTITY_INTERACT_ATTACK ; ENTITY_GREEN_FLY_TV
    db   ENTITY_INTERACT_ATTACK ; ENTITY_PURPLE_FLY_TV
    db   ENTITY_INTERACT_ATTACK ; ENTITY_UNK_FLY_TV_3
    db   ENTITY_INTERACT_ATTACK ; ENTITY_BLUE_FLY_TV
    db   ENTITY_INTERACT_ATTACK ; ENTITY_UNK_FLY_TV_5
    db   ENTITY_INTERACT_NONE ; ENTITY_UNK0E
    db   ENTITY_INTERACT_NONE ; ENTITY_UNK0F
    db   ENTITY_INTERACT_NONE ; ENTITY_UNK10
    db   ENTITY_INTERACT_TOUCH ; ENTITY_TV_BUTTON
    db   ENTITY_INTERACT_NONE ; ENTITY_TV_REMOTE
    db   ENTITY_INTERACT_NONE ; ENTITY_UNK13
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_1
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_2
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_3
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_4
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_5
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_6
    db   ENTITY_INTERACT_NONE ; ENTITY_GOAL_COUNTER_7
    db   ENTITY_INTERACT_NONE ; ENTITY_BONUS_STAGE_TIMER
    db   ENTITY_INTERACT_ATTACK ; ENTITY_FREESTANDING_REMOTE
    db   ENTITY_INTERACT_ATTACK ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
    db   ENTITY_INTERACT_TOUCH ; ENTITY_HOLIDAY_TV_EVIL_SANTA
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_HOLIDAY_TV_SKATING_ELF
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK | ENTITY_INTERACT_STOMP ; ENTITY_HOLIDAY_TV_PENGUIN
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK | ENTITY_INTERACT_STOMP ; ENTITY_MYSTERY_TV_REZLING
    db   ENTITY_INTERACT_ATTACK ; ENTITY_MYSTERY_TV_BLOOD_COOLER
    db   ENTITY_INTERACT_TOUCH ; ENTITY_MYSTERY_TV_FISH
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_MYSTERY_TV_MAGIC_SWORD
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_MYSTERY_TV_SAFARI_SAM
    db   ENTITY_INTERACT_TOUCH ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_MYSTERY_TV_GHOST_KNIGHT
    db   ENTITY_INTERACT_TOUCH ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_TUT_TV_HAND
    db   ENTITY_INTERACT_STOMP ; ENTITY_TUT_TV_LOST_ARK
    db   ENTITY_INTERACT_NONE ; ENTITY_TUT_TV_RISING_PLATFORM
    db   ENTITY_INTERACT_NONE ; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_TUT_TV_BEE
    db   ENTITY_INTERACT_NONE ; ENTITY_TUT_TV_RAFT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_STOMP ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_STOMP ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
    db   ENTITY_INTERACT_TOUCH ; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    db   ENTITY_INTERACT_TOUCH ; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
    db   ENTITY_INTERACT_ATTACK ; ENTITY_TUT_TV_RA_STAFF
    db   ENTITY_INTERACT_TOUCH ; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE
    db   ENTITY_INTERACT_TOUCH ; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
    db   ENTITY_INTERACT_NONE ; ENTITY_TUT_TV_BREAKABLE_BLOCK
    db   ENTITY_INTERACT_ATTACK ; ENTITY_TUT_TV_COFFIN
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_WESTERN_STATION_ENEMY_CACTUS
    db   ENTITY_INTERACT_TOUCH ; ENTITY_WESTERN_STATION_CACTUS
    db   ENTITY_INTERACT_NONE ; ENTITY_WESTERN_STATION_ROCK_PLATFORM
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_WESTERN_STATION_HARD_HAT
    db   ENTITY_INTERACT_ATTACK | ENTITY_INTERACT_STOMP ; ENTITY_WESTERN_STATION_PLAYING_CARD
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_WESTERN_STATION_BAT
    db   ENTITY_INTERACT_NONE ; ENTITY_WESTERN_STATION_RISING_PLATFORM
    db   ENTITY_INTERACT_TOUCH ; ENTITY_ANIME_CHANNEL_DOOR
    db   ENTITY_INTERACT_TOUCH ; ENTITY_ANIME_CHANNEL_DOOR2
    db   ENTITY_INTERACT_NONE ; ENTITY_ANIME_CHANNEL_FAN_LIFT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
    db   ENTITY_INTERACT_NONE ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR
    db   ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_ON_SWITCH2
    db   ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
    db   ENTITY_INTERACT_TOUCH ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER
    db   ENTITY_INTERACT_NONE ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM
    db   ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_ON_SWITCH
    db   ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_OFF_SWITCH
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_STOMP ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_ANIME_CHANNEL_SECBOT
    db   ENTITY_INTERACT_TOUCH ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
    db   ENTITY_INTERACT_NONE ; ENTITY_ANIME_CHANNEL_ELEVATOR
    db   ENTITY_INTERACT_NONE ; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY
    db   ENTITY_INTERACT_TOUCH ; ENTITY_ANIME_CHANNEL_GRENADE
    db   ENTITY_INTERACT_STOMP ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
    db   ENTITY_INTERACT_NONE ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_BOMB
    db   ENTITY_INTERACT_NONE ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_CONVICT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_SPIDER
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK | ENTITY_INTERACT_STOMP ; ENTITY_SUPERHERO_SHOW_STRAY_CAT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_RAT
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV
    db   ENTITY_INTERACT_NONE ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
    db   ENTITY_INTERACT_TOUCH ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_GEXTREME_SPORTS_ELF
    db   ENTITY_INTERACT_ATTACK ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
    db   ENTITY_INTERACT_ATTACK ; ENTITY_MARSUPIAL_MADNESS_BELL
    db   ENTITY_INTERACT_TOUCH ; ENTITY_MARSUPIAL_MADNESS_BIRD
    db   ENTITY_INTERACT_TOUCH ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD
    db   ENTITY_INTERACT_TOUCH ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
    db   ENTITY_INTERACT_NONE ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    db   ENTITY_INTERACT_ATTACK ; ENTITY_LIZARD_OF_OZ_CANNON
    db   ENTITY_INTERACT_TOUCH ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
    db   ENTITY_INTERACT_NONE ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2
    db   ENTITY_INTERACT_NONE ; ENTITY_CHANNEL_Z_GREEN_BLOCK
    db   ENTITY_INTERACT_NONE ; ENTITY_CHANNEL_Z_ORANGE_BLOCK
    db   ENTITY_INTERACT_TOUCH | ENTITY_INTERACT_ATTACK ; ENTITY_CHANNEL_Z_REZ
    db   ENTITY_INTERACT_TOUCH ; ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
    db   ENTITY_INTERACT_TOUCH ; ENTITY_CHANNEL_Z_METEOR
    db   ENTITY_INTERACT_TOUCH ; ENTITY_CHANNEL_Z_REZ_PROJECTILE

call_03_5671_HandleEntityHit:
; "The entity just took a hit" - the counterpart to
; call_03_4cea_CollisionHandler_DamagePlayer, and the only routine that spends
; ENTITY_FIELD_DAMAGE_STATE. Handlers `call` it for the attack and stomp cases;
; a few entity actions in bank 2 farcall it as well.
;
; DAMAGE_STATE is health PLUS ONE, so the values mean:
;
;   $FF     invulnerable - never takes a hit
;   $00     already dead
;   $01     this hit kills it
;   >$01    this hit wounds it: store one less, arm ENTITY_FIELD_COOLDOWN_TIMER
;           for TIMER_AMOUNT_60_FRAMES, and play SFX_ENEMY_DAMAGED
;
; The cooldown is what makes the wound case safe to call every frame - see
; Entity_CheckPlayerInteraction, which reports no contact while it is running, and
; the dispatcher, which is what ages it.
;
; The kill path asks ENTITY_ATTR_DEFEAT_FLAGS what this type leaves behind:
;
;   $FF          nothing at all - free the slot and retire the list entry
;   bit 7 set    a visible death: blank the collision type, reset the facing and
;                start a particle burst
;   low 6 bits   the ACTION the entity dies into, whether or not bit 7 was set
;
; That last line is where gex3 differs most from gex2. gex2 rewrites a defeated
; enemy into a generic burst entity; gex3 sends it to a death action of its own,
; so an enemy can have a scripted death - and bit 6, which
; call_00_2b8b_Entity_MarkDefeated reads separately, decides whether it leaves a
; fly coin behind
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
    call call_00_35e8_Entity_GetCollisionFlags                                  ;; 03:568b $cd $e8 $35
    cp   A, $ff                                        ;; 03:568e $fe $ff
    jp   Z, call_00_2b7a_Entity_DeactivateAndMarkNeverRespawn                                 ;; 03:5690 $ca $7a $2b
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
    farcall call_02_72ac_Entity_SetAction
    ld   A, SFX_ENEMY_KILLED                                        ;; 03:56b3 $3e $10
    jp   call_00_0ff5_QueueSFX                                  ;; 03:56b5 $c3 $f5 $0f
.jr_03_56b8:
    ld   [HL], A                                       ;; 03:56b8 $77
    dec  L                                             ;; 03:56b9 $2d ; HL = ENTITY_FIELD_COOLDOWN_TIMER
    ld   [HL], TIMER_AMOUNT_60_FRAMES                                     ;; 03:56ba $36 $3c
    ld   A, SFX_ENEMY_DAMAGED                                        ;; 03:56bc $3e $0f
    jp   call_00_0ff5_QueueSFX                                  ;; 03:56be $c3 $f5 $0f

call_03_56c1_CollisionHandler_Platform:
; Everything Gex can stand on: rafts, elevators, rising and sideways platforms,
; breakable blocks, the water tower tank. One handler covers what gex2 splits
; between its stationary, moving and one-way platform handlers.
;
; None of the shared box test is used. A platform does not "hit" Gex, it carries
; him or blocks him, and which one it is depends on the side he arrived from and
; how fast he was going. The four death-in-pit actions are dropped up front,
; because a falling corpse must not land on anything.
;
; The vertical convention here is not the one the shared test uses: this compares
; against the platform's own ENTITY_FIELD_WORLD_Y and treats
; ENTITY_FIELD_COLLISION_HEIGHT as the reach above and below it, and it measures
; Gex from his FEET - world Y plus wDC88_Player_HopYOffset plus $10.
;
; Three outcomes, and every path ends in one of them:
;
;   .jr_00_577C   he is well above the platform: the LANDING test. Inside the full
;                 width, the gap between the top edge and his feet under $10, and
;                 then predictive - this frame's fall step (Y velocity / 16) added
;                 to the gap. Negative means he would pass through the surface
;                 before the next frame, under $02 means he is already resting on
;                 it, and either counts as standing.
;   .jr_00_571F   he overlaps it vertically: the SIDE-PUSH test. Work out which
;                 side he is on and how far outside the full width he is, reject
;                 anything more than 8 pixels away, then ask
;                 call_03_58a9_ComputeCollisionOffset whether the platform's step
;                 and his own close that gap this frame.
;   otherwise     no contact.
;
; The `ldd a,[hl]` in both vertical branches reads COLLISION_HEIGHT and leaves HL
; on COLLISION_WIDTH, which is what the branches below it expect
    ld   a,[wD801_Player_ActionId]
    cp   a,PLAYERACTION_DEATH_IN_PIT_ALT
    jp   z,call_03_57f8_ClearCollisionForEntity
    cp   a,PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    jp   z,call_03_57f8_ClearCollisionForEntity
    cp   a,PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT
    jp   z,call_03_57f8_ClearCollisionForEntity
    cp   a,PLAYERACTION_DEATH_IN_PIT
    jp   z,call_03_57f8_ClearCollisionForEntity
    ld   a,[wDC88_Player_HopYOffset]
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
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_Y
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
    ld   a,[wDC88_Player_HopYOffset]
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
; "Gex is standing on this one." Zeroes wDC88_Player_HopYOffset - the landing ends
; the hop - claims wDC7B_Player_EntityStoodOnLo, and releases
; wDC7D_Player_PushedMovingPlatformLo if it named this same entity, so he is never
; recorded as shoving something he is standing on.
;
; gex2's .jr_03_533f inside call_03_5314_Platform_LandingCheck
    xor  A, A                                          ;; 03:57e6 $af
    ld   [wDC88_Player_HopYOffset], A                                    ;; 03:57e7 $ea $88 $dc
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:57ea $fa $00 $da
    ld   [wDC7B_Player_EntityStoodOnLo], A                                    ;; 03:57ed $ea $7b $dc
    ld   HL, wDC7D_Player_PushedMovingPlatformLo                                     ;; 03:57f0 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:57f3 $be
    ret  NZ                                            ;; 03:57f4 $c0
    ld   [HL], $00                                     ;; 03:57f5 $36 $00
    ret                                                ;; 03:57f7 $c9

call_03_57f8_ClearCollisionForEntity:
; "No contact with this one." Releases both links, but only if they still name
; THIS entity - another platform may legitimately own them.
;
; Several actions in bank 2 farcall it directly: a disappearing floor or a
; crumbling block calls it as it vanishes, so Gex stops being carried by something
; that is no longer there. gex2's call_03_534d_Platform_ClearPlayerInteraction
    ld   A, [wDA00_CurrentEntityAddrLo]                                    ;; 03:57f8 $fa $00 $da
    ld   HL, wDC7B_Player_EntityStoodOnLo                                     ;; 03:57fb $21 $7b $dc
    cp   A, [HL]                                       ;; 03:57fe $be
    jr   NZ, .jr_03_5803                               ;; 03:57ff $20 $02
    ld   [HL], $00                                     ;; 03:5801 $36 $00
.jr_03_5803:
    ld   HL, wDC7D_Player_PushedMovingPlatformLo                                     ;; 03:5803 $21 $7d $dc
    cp   A, [HL]                                       ;; 03:5806 $be
    ret  NZ                                            ;; 03:5807 $c0
    ld   [HL], $00                                     ;; 03:5808 $36 $00
    ret                                                ;; 03:580a $c9

call_03_580b_RegisterSecondaryCollision:
; "Gex is walking into the side of this one." Releases wDC7B if he was standing on
; this same entity, then claims wDC7D_Player_PushedMovingPlatformLo - the link
; call_02_51cb_Player_MoveLeftAgainstEntity reads to stop him walking through it,
; or to drag it along with him.
;
; gex2's call_03_5360_Platform_SetPushInteraction
    ld   a,[wDA00_CurrentEntityAddrLo]
    ld   hl,wDC7B_Player_EntityStoodOnLo
    cp   [hl]
    jr   nz,.jr_00_5816
    ld   [hl],$00
.jr_00_5816:
    ld   [wDC7D_Player_PushedMovingPlatformLo],a
    ret  

call_03_581a_CollisionHandler_TVButton:
; ENTITY_TV_BUTTON - the pad in front of a tv that Gex has to stand on.
;
; The platform handler above with the side-push half removed: land on it from
; above and it carries you, approach it from anywhere else and it is not there.
; Same death-action guards, same top-edge-minus-height, same predictive landing
; test, and it shares all three outcome routines.
;
; That is exactly the relationship gex2's call_03_5304_CollisionHandler_OneWayPlatform
; has to its stationary platform handler, except that gex2 shares the landing code
; and gex3 has a second copy of it
    ld   A, [wD801_Player_ActionId]                                    ;; 03:581a $fa $01 $d8
    cp   A, PLAYERACTION_DEATH_IN_PIT_ALT                                        ;; 03:581d $fe $1a
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:581f $ca $f8 $57
    cp   A, PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT                                        ;; 03:5822 $fe $2e
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:5824 $ca $f8 $57
    cp   A, PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT                                        ;; 03:5827 $fe $3b
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:5829 $ca $f8 $57
    cp   A, PLAYERACTION_DEATH_IN_PIT                                        ;; 03:582c $fe $1b
    jp   Z, call_03_57f8_ClearCollisionForEntity                                 ;; 03:582e $ca $f8 $57
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_COLLISION_WIDTH
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
    ld   A, [wDC88_Player_HopYOffset]                                    ;; 03:5860 $fa $88 $dc
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
; Gathers the three numbers the platform's side-push test needs - how fast the two
; are closing on each other this frame.
;
;   B = the platform's ENTITY_FIELD_X_VELOCITY, negated when bit 7 of its
;       ENTITY_FIELD_MISC_FLAGS says it is travelling left. Platforms keep their
;       direction in that flag, so the velocity byte itself is a magnitude
;   D = wDC84_PlayerXDeltaExtra plus wDC85_PlayerXDeltaExtra2, everything else
;       carrying or shoving Gex this frame
;   E = wDC86_PlayerXVelocity, his own walking step, NEGATED when he is facing
;       left, so the caller can combine both sides without caring about direction
;
; gex2's call_03_5427_MovingPlatform_GetRelativeXSpeed does the same job with one
; extra byte instead of two, and reads the platform's direction from the sign of
; the velocity rather than from a flag
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_X_VELOCITY
    ld   b,[hl]
    dec  l
    dec  l
    bit  7,[hl]
    jr   z,.jr_00_58BB
    xor  a
    sub  b
    ld   b,a
    .jr_00_58BB:
    ld   a,[wDC84_PlayerXDeltaExtra]
    ld   d,a
    ld   a,[wDC85_PlayerXDeltaExtra2]
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
