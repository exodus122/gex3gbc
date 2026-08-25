; ==================================================================
; Bank 0. The spawner. One entity is placed per call, and there is no separate "is
; this entity due yet" pass - walking the list IS the streaming system.
;
; Every level has a flat list of $10-byte records in a data bank (see the
; ENTITY_SPAWN_RECORD_* constants). wDAB8_EntityCounter is a cursor into that list,
; 1-based, and call_00_3618_EntitySpawn_SpawnNextFromList considers exactly one
; record per call before returning. Most calls do nothing, and that is normal:
;
;   no free slot        all seven NPC slots are occupied
;   list terminator     rewind the cursor and stop for this call
;   flag already clear  the entry has been taken or defeated
;   already placed      ENTITY_LIST_FLAG_PLACED is set
;   wrong map           the record's map id is not the map on screen
;   out of the room     the record's room rectangle is outside the camera limits
;
; A rejected entry is not retried immediately; the cursor has already moved on and it
; comes back round on the next pass.
;
; Two tables decide what a placed entity becomes. The list record says WHERE it is -
; position, room rectangle, map. data_00_3258_EntityAttributeTable says what its TYPE
; is - size, collision type, health, and what it drops when it dies. Nothing about an
; entity's behaviour is in the list; nothing about its placement is in the table.
;
; Three bases into one table
; --------------------------
; The attribute table is read at three different labels, one byte apart:
;
;   data_00_3258_EntityAttributeTable                 record base + 0
;   data_00_3259_EntityAttributeTable_WidthBase       record base + 1
;   data_00_325f_EntityAttributeTable_FlagsBase       record base + 7
;
; All three index by id * ENTITY_ATTR_RECORD_SIZE. A reader that wants field +N of
; every record indexes from base + N and skips the arithmetic, which is why the
; ENTITY_GEX row below is written as three separate `db` runs with the extra labels
; between them, and why every later row looks shifted.
;
; Who calls what
; --------------
; call_00_35fa_EntitySpawn_SpawnUntilScanline and call_00_360c_EntitySpawn_SpawnNext
; are bank wrappers - they page in the entity list bank, call the worker, and page
; back. The first keeps calling until the raster passes
; ENTITY_SPAWN_SCANLINE_LIMIT, which is the per-frame time budget; the second does
; exactly one and is what the level-entry loop in bank 2 hammers until the cursor
; wraps. call_00_3792_EntitySpawn_SpawnChild is the same kind of wrapper around
; call_00_37a0_EntitySpawn_SpawnChildEntity.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank0A_entity_load.asm
; ------------------------------------------------------------------
; Same design, one entity per call, driven off the same two tables, and the child
; spawner is close to instruction-for-instruction. What differs:
;
;   the cursor       gex2 keeps a POINTER, wD336_CurrentEntityToLoadPtr, and a
;                    separate wD338_EntityLoadingFlag as the list index. gex3 keeps
;                    only wDAB8_EntityCounter and multiplies it out each time, which
;                    is slower but survives a bank switch
;   the room test    gex2 asks call_00_350c_Entity_CheckIfOnScreen whether the entry
;                    is visible. gex3 compares the record's own room rectangle
;                    against the camera's scroll limits, and checks a map id first -
;                    because a gex3 level is many maps and gex2's is one
;   the parameters   gex2's attribute record leads with a mask byte that scatters the
;                    list entry's three free bytes into entity fields $18..$1F. gex3
;                    has no such mechanism: its records carry one free byte at
;                    ENTITY_SPAWN_RECORD_PARAM and only the paw coins read it. What
;                    gex3 gained instead is the low nibble of wD700_EntityFlags,
;                    which names the action the entry spawns into
;   the list flags   gex2's flag byte is a three-value enum. gex3's is a bitfield,
;                    so one entry can be present, placed, and marked-as-fly-coin at
;                    once - see ENTITY_LIST_FLAG_* in constants.asm
;   the entity data  gex2 INCBINs the level lists into this same file. gex3's live in
;                    their own data banks, reached through wDC16_EntityListBank
; ==================================================================

call_00_3252_EntityList_RewindCursor:
; Points wDAB8_EntityCounter back at the first list entry. Called at level setup, and
; again by the spawner itself whenever it walks off the end of the list, which is
; what makes the walk cyclic rather than one-shot.
;
; Bank 2's level-entry loop uses the rewind as a signal: it calls
; call_00_360c_EntitySpawn_SpawnNext over and over and stops when the counter is back
; to ENTITY_LIST_FIRST_INDEX, so "spawn everything that fits" is written as "keep
; going until the cursor comes round". gex2's
; call_0a_4000_EntityList_LoadForCurrentLevel, which reloads a pointer instead
    ld   A, ENTITY_LIST_FIRST_INDEX                   ;; 00:3252 $3e $01
    ld   [wDAB8_EntityCounter], A                     ;; 00:3254 $ea $b8 $da
    ret                                               ;; 00:3257 $c9

; ------------------------------------------------------------------
; The per-entity-type template, ENTITY_ATTR_RECORD_SIZE bytes per ENTITY_* id, in
; entity id order - so a row's position IS its id. 114 rows.
;
;   +0  ENTITY_ATTR_IS_NPC          0 for ENTITY_GEX, 1 for everything else
;   +1  ENTITY_ATTR_WIDTH           into ENTITY_FIELD_COLLISION_WIDTH
;   +2  ENTITY_ATTR_HEIGHT          into ENTITY_FIELD_COLLISION_HEIGHT
;   +3  ENTITY_ATTR_COLLISION_TYPE  into ENTITY_FIELD_COLLISION_TYPE
;   +4  ENTITY_ATTR_DAMAGE_STATE    health plus one; the spawn decrements it
;   +5  ENTITY_ATTR_MISC_FLAGS      $00 in all 114 rows
;   +6  ENTITY_ATTR_UNUSED          $FF in all 114 rows, never read
;   +7  ENTITY_ATTR_DEFEAT_FLAGS    what the entity leaves behind when it dies
;
; THREE READERS, AT THREE BASES, one byte apart - see the file header. The spawn
; reads from data_00_3258_EntityAttributeTable and takes +0 then +1..+7; the child
; spawn reads from data_00_3259_EntityAttributeTable_WidthBase because it only wants
; +1 onwards; call_00_35e8_Entity_GetCollisionFlags reads from
; data_00_325f_EntityAttributeTable_FlagsBase because it only wants +7. That is why
; the ENTITY_GEX row below is broken into three `db` runs with the extra labels
; between them, and why every later row looks shifted by one.
;
; THE DEFEAT FLAGS are the interesting field. What is certain:
;
;   $FF                     64 rows. Clear the slot and drop nothing - flies,
;                           projectiles, platforms, doors, scenery
;   bit 7, PARTICLES        35 rows. Spawn a particle burst
;   bit 6, DROPS_COLLECTIBLE 20 rows. Counts towards the level total, which is what
;                           call_00_2f34_CountLevelCollectibleTotal is adding up when
;                           it tests this bit
;
; The low nibble takes the values 0-7 and $0A and tracks what kind of thing dies:
; every ordinary defeatable enemy is $C3 or $C4, the three coin types are all $81,
; the fly TVs are $01, and the bosses each have their own. It looks like an index
; rather than a bitfield, but nothing here proves that - the readers outside this
; file are the ones to check
data_00_3258_EntityAttributeTable:                                                      ; 00:3258 ???????? ; ENTITY_GEX
    db   $00
data_00_3259_EntityAttributeTable_WidthBase:
    db   $00, $00, COLLISION_TYPE_NONE, $00, $00, $00
data_00_325f_EntityAttributeTable_FlagsBase:
    db   $ff        
    db   $01, $0c, $0c, COLLISION_TYPE_BONUS_COIN, $02, $00, $ff, $81 ; 00:3260 ......?? ; ENTITY_BONUS_COIN
    db   $01, $0c, $0c, COLLISION_TYPE_FLY_COIN, $02, $00, $ff, $81 ; 00:3268 ......?. ; ENTITY_FLY_COIN_SPAWN
    db   $01, $0c, $0c, COLLISION_TYPE_PAW_COIN, $02, $00, $ff, $81 ; 00:3270 ......?. ; ENTITY_PAW_COIN
    db   $01, $0c, $0c, COLLISION_TYPE_FLY, $00, $00, $ff, $ff ; 00:3278 ???????? ; ENTITY_FLY_1
    db   $01, $0c, $0c, COLLISION_TYPE_FLY, $00, $00, $ff, $ff ; 00:3280 ???????? ; ENTITY_FLY_2
    db   $01, $0c, $0c, COLLISION_TYPE_FLY, $00, $00, $ff, $ff ; 00:3288 ???????? ; ENTITY_FLY_3
    db   $01, $0c, $0c, COLLISION_TYPE_FLY, $00, $00, $ff, $ff ; 00:3290 ???????? ; ENTITY_FLY_4
    db   $01, $0c, $0c, COLLISION_TYPE_FLY, $00, $00, $ff, $ff ; 00:3298 ???????? ; ENTITY_FLY_5
    db   $01, $0c, $10, COLLISION_TYPE_FLY_TV, $02, $00, $ff, $01 ; 00:32a0 ???????? ; ENTITY_GREEN_FLY_TV
    db   $01, $0c, $10, COLLISION_TYPE_FLY_TV, $02, $00, $ff, $01 ; 00:32a8 ???????? ; ENTITY_PURPLE_FLY_TV
    db   $01, $0c, $10, COLLISION_TYPE_FLY_TV, $02, $00, $ff, $01 ; 00:32b0 ???????? ; ENTITY_UNK_FLY_TV_3
    db   $01, $0c, $10, COLLISION_TYPE_FLY_TV, $02, $00, $ff, $01 ; 00:32b8 ???????? ; ENTITY_BLUE_FLY_TV
    db   $01, $0c, $10, COLLISION_TYPE_FLY_TV, $02, $00, $ff, $01 ; 00:32c0 ???????? ; ENTITY_UNK_FLY_TV_5
    db   $01, $08, $08, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:32c8 ???????? ; ENTITY_UNK0E
    db   $01, $08, $08, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:32d0 ???????? ; ENTITY_UNK0F
    db   $01, $08, $08, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:32d8 ???????? ; ENTITY_UNK10
    db   $01, $08, $08, COLLISION_TYPE_TV_BUTTON, $00, $00, $ff, $ff ; 00:32e0 ......?? ; ENTITY_TV_BUTTON
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:32e8 ......?. ; ENTITY_TV_REMOTE
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:32f0 ???????? ; ENTITY_UNK13
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:32f8 ?.....?? ; ENTITY_GOAL_COUNTER_1
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3300 ?.....?? ; ENTITY_GOAL_COUNTER_2
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3308 ?.....?? ; ENTITY_GOAL_COUNTER_3
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3310 ?.....?? ; ENTITY_GOAL_COUNTER_4
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3318 ???????? ; ENTITY_GOAL_COUNTER_5
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3320 ???????? ; ENTITY_GOAL_COUNTER_6
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3328 ???????? ; ENTITY_GOAL_COUNTER_7
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3330 ???????? ; ENTITY_BONUS_STAGE_TIMER
    db   $01, $10, $10, COLLISION_TYPE_FREESTANDING_REMOTE, $02, $00, $ff, $82 ; 00:3338 ......?. ; ENTITY_FREESTANDING_REMOTE
    db   $01, $0c, $10, COLLISION_TYPE_ICE_SCULPTURE, $00, $00, $ff, $ff ; 00:3340 ......?? ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
    db   $01, $0c, $10, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3348 ......?? ; ENTITY_HOLIDAY_TV_EVIL_SANTA
    db   $01, $0c, $08, COLLISION_TYPE_EVIL_SANTA_PROJECTILE, $00, $00, $ff, $ff ; 00:3350 ?.....?? ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    db   $01, $0c, $10, COLLISION_TYPE_ELF, $00, $00, $ff, $c0 ; 00:3358 ......?. ; ENTITY_HOLIDAY_TV_SKATING_ELF
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c3 ; 00:3360 ......?. ; ENTITY_HOLIDAY_TV_PENGUIN
    db   $01, $10, $10, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c3 ; 00:3368 ???????? ; ENTITY_MYSTERY_TV_REZLING
    db   $01, $0c, $10, COLLISION_TYPE_BLOOD_COOLER, $02, $00, $ff, $01 ; 00:3370 ???????? ; ENTITY_MYSTERY_TV_BLOOD_COOLER
    db   $01, $0c, $0c, COLLISION_TYPE_INVULNERABLE_ENEMY, $00, $00, $ff, $ff ; 00:3378 ???????? ; ENTITY_MYSTERY_TV_FISH
    db   $01, $08, $10, COLLISION_TYPE_MAGIC_SWORD, $02, $00, $ff, $c2 ; 00:3380 ???????? ; ENTITY_MYSTERY_TV_MAGIC_SWORD
    db   $01, $10, $10, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c3 ; 00:3388 ???????? ; ENTITY_MYSTERY_TV_SAFARI_SAM
    db   $01, $0c, $10, COLLISION_TYPE_PROJECTILE, $00, $00, $ff, $ff ; 00:3390 ???????? ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    db   $01, $08, $08, COLLISION_TYPE_GHOST_KNIGHT, $04, $00, $ff, $85 ; 00:3398 ???????? ; ENTITY_MYSTERY_TV_GHOST_KNIGHT
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $00, $00, $ff, $ff ; 00:33a0 ???????? ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
    db   $01, $0c, $0c, COLLISION_TYPE_HAND, $00, $00, $ff, $ff ; 00:33a8 ???????? ; ENTITY_TUT_TV_HAND
    db   $01, $10, $08, COLLISION_TYPE_LOST_ARK, $02, $00, $ff, $01 ; 00:33b0 ???????? ; ENTITY_TUT_TV_LOST_ARK
    db   $01, $0c, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:33b8 ???????? ; ENTITY_TUT_TV_RISING_PLATFORM
    db   $01, $0c, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:33c0 ???????? ; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
    db   $01, $0c, $0c, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c4 ; 00:33c8 ???????? ; ENTITY_TUT_TV_BEE
    db   $01, $10, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:33d0 ???????? ; ENTITY_TUT_TV_RAFT
    db   $01, $08, $08, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c3 ; 00:33d8 ???????? ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
    db   $01, $08, $08, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c3 ; 00:33e0 ???????? ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
    db   $01, $06, $08, COLLISION_TYPE_PROJECTILE, $00, $00, $ff, $ff ; 00:33e8 ???????? ; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    db   $01, $06, $08, COLLISION_TYPE_PROJECTILE, $00, $00, $ff, $ff ; 00:33f0 ???????? ; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
    db   $01, $08, $10, COLLISION_TYPE_RA_STAFF, $02, $00, $ff, $81 ; 00:33f8 ???????? ; ENTITY_TUT_TV_RA_STAFF
    db   $01, $0a, $0a, COLLISION_TYPE_RA_STATUE_PROJECTILE, $00, $00, $ff, $ff ; 00:3400 ???????? ; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE
    db   $01, $0a, $0a, COLLISION_TYPE_RA_STATUE_PROJECTILE, $00, $00, $ff, $ff ; 00:3408 ???????? ; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
    db   $01, $12, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3410 ???????? ; ENTITY_TUT_TV_BREAKABLE_BLOCK
    db   $01, $10, $20, COLLISION_TYPE_COFFIN, $00, $00, $ff, $ff ; 00:3418 ???????? ; ENTITY_TUT_TV_COFFIN
    db   $01, $10, $18, COLLISION_TYPE_CACTUS, $03, $00, $ff, $46 ; 00:3420 ???????? ; ENTITY_WESTERN_STATION_ENEMY_CACTUS
    db   $01, $10, $18, COLLISION_TYPE_GENERIC_ENEMY, $00, $00, $ff, $ff ; 00:3428 ???????? ; ENTITY_WESTERN_STATION_CACTUS
    db   $01, $0a, $10, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3430 ???????? ; ENTITY_WESTERN_STATION_ROCK_PLATFORM
    db   $01, $0a, $0a, COLLISION_TYPE_HARD_HAT, $02, $00, $ff, $c4 ; 00:3438 ???????? ; ENTITY_WESTERN_STATION_HARD_HAT
    db   $01, $0a, $0a, COLLISION_TYPE_PLAYING_CARD, $02, $00, $ff, $81 ; 00:3440 ???????? ; ENTITY_WESTERN_STATION_PLAYING_CARD
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $84 ; 00:3448 ???????? ; ENTITY_WESTERN_STATION_BAT
    db   $01, $0c, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3450 ???????? ; ENTITY_WESTERN_STATION_RISING_PLATFORM
    db   $01, $08, $08, COLLISION_TYPE_DOOR, $00, $00, $ff, $ff ; 00:3458 ???????? ; ENTITY_ANIME_CHANNEL_DOOR
    db   $01, $08, $08, COLLISION_TYPE_DOOR_2, $00, $00, $ff, $ff ; 00:3460 ???????? ; ENTITY_ANIME_CHANNEL_DOOR2
    db   $01, $00, $00, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3468 ???????? ; ENTITY_ANIME_CHANNEL_FAN_LIFT
    db   $01, $10, $10, COLLISION_TYPE_MECH, $04, $00, $ff, $81 ; 00:3470 ???????? ; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT
    db   $01, $10, $10, COLLISION_TYPE_MECH, $04, $00, $ff, $81 ; 00:3478 ???????? ; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
    db   $01, $12, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3480 ???????? ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR
    db   $01, $08, $08, COLLISION_TYPE_ON_SWITCH_2, $00, $00, $ff, $ff ; 00:3488 ???????? ; ENTITY_ANIME_CHANNEL_ON_SWITCH2
    db   $01, $10, $20, COLLISION_TYPE_ALIEN_CULTURE_TUBE, $02, $00, $ff, $01 ; 00:3490 ???????? ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
    db   $01, $08, $40, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3498 ???????? ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER
    db   $01, $08, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:34a0 ???????? ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM
    db   $01, $08, $08, COLLISION_TYPE_ON_SWITCH, $00, $00, $ff, $ff ; 00:34a8 ???????? ; ENTITY_ANIME_CHANNEL_ON_SWITCH
    db   $01, $08, $08, COLLISION_TYPE_OFF_SWITCH, $00, $00, $ff, $ff ; 00:34b0 ???????? ; ENTITY_ANIME_CHANNEL_OFF_SWITCH
    db   $01, $10, $10, COLLISION_TYPE_SAILOR_TOON_GIRL, $04, $00, $ff, $42 ; 00:34b8 ???????? ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
    db   $01, $10, $20, COLLISION_TYPE_BIG_SILVER_ROBOT, $04, $00, $ff, $03 ; 00:34c0 ???????? ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $c2 ; 00:34c8 ???????? ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
    db   $01, $0a, $0a, COLLISION_TYPE_SECBOT, $03, $00, $ff, $c4 ; 00:34d0 ???????? ; ENTITY_ANIME_CHANNEL_SECBOT
    db   $01, $0a, $0a, COLLISION_TYPE_PROJECTILE, $00, $00, $ff, $ff ; 00:34d8 ???????? ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
    db   $01, $12, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:34e0 ???????? ; ENTITY_ANIME_CHANNEL_ELEVATOR
    db   $01, $0c, $0c, COLLISION_TYPE_GENERIC_ENEMY, $00, $00, $ff, $ff ; 00:34e8 ???????? ; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $00, $00, $ff, $ff ; 00:34f0 ???????? ; ENTITY_ANIME_CHANNEL_GRENADE
    db   $01, $14, $14, COLLISION_TYPE_PLANET_O_BLAST, $04, $00, $ff, $c1 ; 00:34f8 ???????? ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
    db   $01, $10, $18, COLLISION_TYPE_NONE, $06, $00, $ff, $05 ; 00:3500 ???????? ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    db   $01, $0a, $0a, COLLISION_TYPE_BOMB, $00, $00, $ff, $ff ; 00:3508 ???????? ; ENTITY_SUPERHERO_SHOW_BOMB
    db   $01, $10, $10, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3510 ???????? ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
    db   $01, $14, $18, COLLISION_TYPE_WATER_TOWER_STAND, $02, $00, $ff, $01 ; 00:3518 ???????? ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
    db   $01, $0c, $10, COLLISION_TYPE_CONVICT, $02, $00, $ff, $c3 ; 00:3520 ???????? ; ENTITY_SUPERHERO_SHOW_CONVICT
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $03, $00, $ff, $c3 ; 00:3528 ???????? ; ENTITY_SUPERHERO_SHOW_SPIDER
    db   $01, $0c, $0c, COLLISION_TYPE_STRAY_CAT, $02, $00, $ff, $c5 ; 00:3530 ???????? ; ENTITY_SUPERHERO_SHOW_STRAY_CAT
    db   $01, $0c, $10, COLLISION_TYPE_YELLOW_GOON, $04, $00, $ff, $c3 ; 00:3538 ???????? ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON
    db   $01, $0c, $0c, COLLISION_TYPE_GENERIC_ENEMY, $04, $00, $ff, $c2 ; 00:3540 ???????? ; ENTITY_SUPERHERO_SHOW_RAT
    db   $01, $0a, $0a, COLLISION_TYPE_CHOMPER_TV, $03, $00, $ff, $c3 ; 00:3548 ???????? ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV
    db   $01, $10, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:3550 ???????? ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $00, $00, $ff, $ff ; 00:3558 ???????? ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
    db   $01, $0c, $10, COLLISION_TYPE_GEXTREME_SPORTS_ELF, $00, $00, $ff, $80 ; 00:3560 ???????? ; ENTITY_GEXTREME_SPORTS_ELF
    db   $01, $10, $10, COLLISION_TYPE_BONUS_TIME_COIN, $02, $00, $ff, $81 ; 00:3568 ???????? ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
    db   $01, $10, $10, COLLISION_TYPE_BELL, $00, $00, $ff, $ff ; 00:3570 ???????? ; ENTITY_MARSUPIAL_MADNESS_BELL
    db   $01, $08, $08, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3578 ???????? ; ENTITY_MARSUPIAL_MADNESS_BIRD
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $81 ; 00:3580 ???????? ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
    db   $01, $10, $20, COLLISION_TYPE_ROCK_HARD, $04, $00, $ff, $05 ; 00:3588 ???????? ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD
    db   $01, $0c, $10, COLLISION_TYPE_BRAIN_OF_OZ, $08, $00, $ff, $87 ; 00:3590 ???????? ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
    db   $01, $10, $10, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:3598 ???????? ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    db   $01, $08, $08, COLLISION_TYPE_CANNON, $00, $00, $ff, $ff ; 00:35a0 ???????? ; ENTITY_LIZARD_OF_OZ_CANNON
    db   $01, $0a, $0a, COLLISION_TYPE_BRAIN_OF_OZ_PROJECTILE, $00, $00, $ff, $ff ; 00:35a8 ???????? ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
    db   $01, $10, $10, COLLISION_TYPE_NONE, $00, $00, $ff, $ff ; 00:35b0 ???????? ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2
    db   $01, $10, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:35b8 ???????? ; ENTITY_CHANNEL_Z_GREEN_BLOCK
    db   $01, $10, $08, COLLISION_TYPE_PLATFORM | COLLISION_TYPE_UNK_PLATFORM_FLAG, $00, $00, $ff, $ff ; 00:35c0 ???????? ; ENTITY_CHANNEL_Z_ORANGE_BLOCK
    db   $01, $1c, $20, COLLISION_TYPE_REZ, $10, $00, $ff, $8a ; 00:35c8 ???????? ; ENTITY_CHANNEL_Z_REZ
    db   $01, $0a, $40, COLLISION_TYPE_GENERIC_ENEMY, $00, $00, $ff, $ff ; 00:35d0 ???????? ; ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
    db   $01, $0c, $0c, COLLISION_TYPE_METEOR, $02, $00, $ff, $82 ; 00:35d8 ???????? ; ENTITY_CHANNEL_Z_METEOR
    db   $01, $0a, $0a, COLLISION_TYPE_GENERIC_ENEMY, $02, $00, $ff, $81 ; 00:35e0 ???????? ; ENTITY_CHANNEL_Z_REZ_PROJECTILE

call_00_35e8_Entity_GetCollisionFlags:
; Returns in A the ENTITY_ATTR_DEFEAT_FLAGS byte for the entity currently being
; processed - what it drops and what it leaves behind when it dies.
;
; Two hops: wDA00_CurrentEntityAddrLo names the slot, byte ENTITY_FIELD_ENTITY_ID of
; that slot names the type, and the type indexes
; data_00_325f_EntityAttributeTable_FlagsBase. That base is already field +7 of a
; record, so multiplying the id by ENTITY_ATTR_RECORD_SIZE is the whole address
; calculation
    ld   HL, wDA00_CurrentEntityAddrLo                ;; 00:35e8 $21 $00 $da
    ld   L, [HL]                                      ;; 00:35eb $6e
    ld   H, HIGH(wD800_EntityMemory)                  ;; 00:35ec $26 $d8
    ld   L, [HL]                                      ;; 00:35ee $6e
    ld   H, $00                                       ;; 00:35ef $26 $00
    add  HL, HL                                       ;; 00:35f1 $29
    add  HL, HL                                       ;; 00:35f2 $29
    add  HL, HL                                       ;; 00:35f3 $29
    ld   DE, data_00_325f_EntityAttributeTable_FlagsBase ;; 00:35f4 $11 $5f $32
    add  HL, DE                                       ;; 00:35f7 $19
    ld   A, [HL]                                      ;; 00:35f8 $7e
    ret                                               ;; 00:35f9 $c9

call_00_35fa_EntitySpawn_SpawnUntilScanline:
; Spawns as many entities as fit in the time left, then restores the bank.
;
; Calls the worker in a loop until rLY has passed ENTITY_SPAWN_SCANLINE_LIMIT, so the
; budget is "however many we can do before the raster is halfway down the screen".
; Since each call places at most one entity and usually places none, this is how a
; freshly scrolled-into room fills up over a few frames rather than all at once
    ld   A, [wDC16_EntityListBank]                    ;; 00:35fa $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:35fd $cd $ee $0e
.jr_00_3600:
    call call_00_3618_EntitySpawn_SpawnNextFromList   ;; 00:3600 $cd $18 $36
    ldh  A, [rLY]                                     ;; 00:3603 $f0 $44
    cp   A, ENTITY_SPAWN_SCANLINE_LIMIT               ;; 00:3605 $fe $80
    jr   C, .jr_00_3600                               ;; 00:3607 $38 $f7
    jp   call_00_0f08_RestoreBank                     ;; 00:3609 $c3 $08 $0f

call_00_360c_EntitySpawn_SpawnNext:
; One spawn attempt with the entity list bank paged in, no time check. The form the
; level-entry loop in bank 2 uses, where the caller controls how many attempts to
; make rather than the raster
    ld   A, [wDC16_EntityListBank]                    ;; 00:360c $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:360f $cd $ee $0e
    call call_00_3618_EntitySpawn_SpawnNextFromList   ;; 00:3612 $cd $18 $36
    jp   call_00_0f08_RestoreBank                     ;; 00:3615 $c3 $08 $0f

call_00_3618_EntitySpawn_SpawnNextFromList:
; Considers one entity list record and places it if everything checks out. The heart
; of the file; the bail-out cases are listed in the file header.
;
; With no free slot it does nothing but advance the cursor - and note that even that
; path has to check for the terminator, so an empty run of the list still costs the
; pointer arithmetic. The `ld DE, -ENTITY_SPAWN_RECORD_SIZE` before the multiply is
; the 1-based cursor being turned into a 0-based offset.
;
; Once a record survives, the checks in order are: id is not ENTITY_LIST_END, the
; entry's wD700_EntityFlags byte is non-zero and not already PLACED, the record's map
; id matches wDB6C_CurrentMapId, and the record's room rectangle lies inside the
; camera limits in wDA14_CameraPos_Left and friends. ENTITY_LIST_FLAG_FLY_COIN is
; handled here too: an entry carrying it spawns as ENTITY_FLY_COIN_SPAWN rather than
; as the type the list names, which is how a defeated enemy leaves a coin behind that
; is still tied to its own list entry.
;
; Then the slot is filled from both sources - position and bounds from the record,
; size and collision and health from the attribute table - the entry is marked
; PLACED, and ENTITY_LIST_ACTION_MASK picks the action it starts in. gex2's
; call_0a_7a7c_EntitySpawn_SpawnNextFromList
    call call_00_2afc_Entity_FindFreeSlot             ;; 00:3618 $cd $fc $2a
    jr   NZ, .jr_00_3641                              ;; 00:361b $20 $24
    ld   HL, wDC17_EntityListBankOffset               ;; 00:361d $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:3620 $2a
    ld   H, [HL]                                      ;; 00:3621 $66
    ld   L, A                                         ;; 00:3622 $6f
    ld   DE, -ENTITY_SPAWN_RECORD_SIZE                ;; 00:3623 $11 $f0 $ff
    add  HL, DE                                       ;; 00:3626 $19
    ld   E, L                                         ;; 00:3627 $5d
    ld   D, H                                         ;; 00:3628 $54
    ld   HL, wDAB8_EntityCounter                      ;; 00:3629 $21 $b8 $da
    ld   L, [HL]                                      ;; 00:362c $6e
    ld   H, $00                                       ;; 00:362d $26 $00
    add  HL, HL                                       ;; 00:362f $29
    add  HL, HL                                       ;; 00:3630 $29
    add  HL, HL                                       ;; 00:3631 $29
    add  HL, HL                                       ;; 00:3632 $29
    add  HL, DE                                       ;; 00:3633 $19
    ld   E, L                                         ;; 00:3634 $5d
    ld   D, H                                         ;; 00:3635 $54
    ld   A, [DE]                                      ;; 00:3636 $1a
    cp   A, ENTITY_LIST_END                           ;; 00:3637 $fe $ff
    jp   Z, call_00_3252_EntityList_RewindCursor      ;; 00:3639 $ca $52 $32
    ld   HL, wDAB8_EntityCounter                      ;; 00:363c $21 $b8 $da
    inc  [HL]                                         ;; 00:363f $34
    ret                                               ;; 00:3640 $c9
.jr_00_3641:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 00:3641 $ea $00 $da
    rlca                                              ;; 00:3644 $07
    rlca                                              ;; 00:3645 $07
    rlca                                              ;; 00:3646 $07
    ld   [wDAB9_NextAvailableEntitySlot], A           ;; 00:3647 $ea $b9 $da
    ld   HL, wDC17_EntityListBankOffset               ;; 00:364a $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:364d $2a
    ld   H, [HL]                                      ;; 00:364e $66
    ld   L, A                                         ;; 00:364f $6f
    ld   DE, -ENTITY_SPAWN_RECORD_SIZE                ;; 00:3650 $11 $f0 $ff
    add  HL, DE                                       ;; 00:3653 $19
    ld   E, L                                         ;; 00:3654 $5d
    ld   D, H                                         ;; 00:3655 $54
    ld   HL, wDAB8_EntityCounter                      ;; 00:3656 $21 $b8 $da
    ld   L, [HL]                                      ;; 00:3659 $6e
    ld   H, $00                                       ;; 00:365a $26 $00
    add  HL, HL                                       ;; 00:365c $29
    add  HL, HL                                       ;; 00:365d $29
    add  HL, HL                                       ;; 00:365e $29
    add  HL, HL                                       ;; 00:365f $29
    add  HL, DE                                       ;; 00:3660 $19
    ld   E, L                                         ;; 00:3661 $5d
    ld   D, H                                         ;; 00:3662 $54
    ld   A, [DE]                                      ;; 00:3663 $1a
    cp   A, ENTITY_LIST_END                           ;; 00:3664 $fe $ff
    jp   Z, call_00_3252_EntityList_RewindCursor      ;; 00:3666 $ca $52 $32
    ld   [wDABB_CurrentEntityId], A                   ;; 00:3669 $ea $bb $da
    ld   HL, wDAB8_EntityCounter                      ;; 00:366c $21 $b8 $da
    ld   C, [HL]                                      ;; 00:366f $4e
    inc  [HL]                                         ;; 00:3670 $34
    ld   B, HIGH(wD700_EntityFlags)                   ;; 00:3671 $06 $d7
    ld   A, [BC]                                      ;; 00:3673 $0a
    and  A, A                                         ;; 00:3674 $a7
    ret  Z                                            ;; 00:3675 $c8
    bit  ENTITY_LIST_FLAG_PLACED_BIT, A               ;; 00:3676 $cb $77
    ret  NZ                                           ;; 00:3678 $c0
    ld   [wDABC_CurrentEntityFlags], A                ;; 00:3679 $ea $bc $da
    bit  ENTITY_LIST_FLAG_FLY_COIN_BIT, A             ;; 00:367c $cb $67
    jr   Z, .jr_00_3685                               ;; 00:367e $28 $05
    ld   A, ENTITY_FLY_COIN_SPAWN                     ;; 00:3680 $3e $02
    ld   [wDABB_CurrentEntityId], A                   ;; 00:3682 $ea $bb $da
.jr_00_3685:
    ld   A, C                                         ;; 00:3685 $79
    ld   [wDABA_EntityCounterRelated], A              ;; 00:3686 $ea $ba $da
    ld   HL, ENTITY_SPAWN_RECORD_MAP_ID               ;; 00:3689 $21 $0f $00
    add  HL, DE                                       ;; 00:368c $19
    ld   A, [wDB6C_CurrentMapId]                      ;; 00:368d $fa $6c $db
    cp   A, [HL]                                      ;; 00:3690 $be
    ret  NZ                                           ;; 00:3691 $c0
    inc  DE                                           ;; 00:3692 $13
    ld   HL, ENTITY_SPAWN_RECORD_BOUNDS - ENTITY_SPAWN_RECORD_XPOS ;; 00:3693 $21 $04 $00
    add  HL, DE                                       ;; 00:3696 $19
    ld   C, L                                         ;; 00:3697 $4d
    ld   B, H                                         ;; 00:3698 $44
    ld   HL, wDA14_CameraPos_Left                     ;; 00:3699 $21 $14 $da
    ld   A, [BC]                                      ;; 00:369c $0a
    sub  A, [HL]                                      ;; 00:369d $96
    inc  HL                                           ;; 00:369e $23
    inc  BC                                           ;; 00:369f $03
    ld   A, [BC]                                      ;; 00:36a0 $0a
    sbc  A, [HL]                                      ;; 00:36a1 $9e
    ret  C                                            ;; 00:36a2 $d8
    inc  BC                                           ;; 00:36a3 $03
    ld   L, C                                         ;; 00:36a4 $69
    ld   H, B                                         ;; 00:36a5 $60
    ld   A, [wDA16_CameraPos_Right]                   ;; 00:36a6 $fa $16 $da
    sub  A, [HL]                                      ;; 00:36a9 $96
    inc  HL                                           ;; 00:36aa $23
    ld   A, [wDA16_CameraPos_Right+1]                 ;; 00:36ab $fa $17 $da
    sbc  A, [HL]                                      ;; 00:36ae $9e
    ret  C                                            ;; 00:36af $d8
    inc  HL                                           ;; 00:36b0 $23
    ld   C, L                                         ;; 00:36b1 $4d
    ld   B, H                                         ;; 00:36b2 $44
    ld   HL, wDA18_CameraPos_Top                      ;; 00:36b3 $21 $18 $da
    ld   A, [BC]                                      ;; 00:36b6 $0a
    sub  A, [HL]                                      ;; 00:36b7 $96
    inc  HL                                           ;; 00:36b8 $23
    inc  BC                                           ;; 00:36b9 $03
    ld   A, [BC]                                      ;; 00:36ba $0a
    sbc  A, [HL]                                      ;; 00:36bb $9e
    ret  C                                            ;; 00:36bc $d8
    inc  BC                                           ;; 00:36bd $03
    ld   L, C                                         ;; 00:36be $69
    ld   H, B                                         ;; 00:36bf $60
    ld   A, [wDA1A_CameraPos_Bottom]                  ;; 00:36c0 $fa $1a $da
    sub  A, [HL]                                      ;; 00:36c3 $96
    inc  HL                                           ;; 00:36c4 $23
    ld   A, [wDA1A_CameraPos_Bottom+1]                ;; 00:36c5 $fa $1b $da
    sbc  A, [HL]                                      ;; 00:36c8 $9e
    ret  C                                            ;; 00:36c9 $d8
    ld   HL, wDAB9_NextAvailableEntitySlot            ;; 00:36ca $21 $b9 $da
    ld   L, [HL]                                      ;; 00:36cd $6e
    ld   H, $00                                       ;; 00:36ce $26 $00
    add  HL, HL                                       ;; 00:36d0 $29
    add  HL, HL                                       ;; 00:36d1 $29
    add  HL, HL                                       ;; 00:36d2 $29
    add  HL, HL                                       ;; 00:36d3 $29
    ld   BC, wDA24_EntityInitialXPos                  ;; 00:36d4 $01 $24 $da
    add  HL, BC                                       ;; 00:36d7 $09
    ld   C, L                                         ;; 00:36d8 $4d
    ld   B, H                                         ;; 00:36d9 $44
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_WORLD_X
    ld   A, [DE]                                      ;; 00:36e2 $1a
    ld   [HL+], A                                     ;; 00:36e3 $22
    ld   [BC], A                                      ;; 00:36e4 $02
    inc  BC                                           ;; 00:36e5 $03
    inc  DE                                           ;; 00:36e6 $13
    ld   A, [DE]                                      ;; 00:36e7 $1a
    ld   [HL+], A                                     ;; 00:36e8 $22
    ld   [BC], A                                      ;; 00:36e9 $02
    inc  BC                                           ;; 00:36ea $03
    inc  DE                                           ;; 00:36eb $13
    ld   A, [DE]                                      ;; 00:36ec $1a
    ld   [HL+], A                                     ;; 00:36ed $22
    ld   [BC], A                                      ;; 00:36ee $02
    inc  BC                                           ;; 00:36ef $03
    inc  DE                                           ;; 00:36f0 $13
    ld   A, [DE]                                      ;; 00:36f1 $1a
    ld   [HL], A                                      ;; 00:36f2 $77
    ld   [BC], A                                      ;; 00:36f3 $02
    inc  DE                                           ;; 00:36f4 $13
    ld   HL, wDAB9_NextAvailableEntitySlot            ;; 00:36f5 $21 $b9 $da
    ld   L, [HL]                                      ;; 00:36f8 $6e
    ld   H, $00                                       ;; 00:36f9 $26 $00
    add  HL, HL                                       ;; 00:36fb $29
    add  HL, HL                                       ;; 00:36fc $29
    add  HL, HL                                       ;; 00:36fd $29
    add  HL, HL                                       ;; 00:36fe $29
    ld   BC, wDA1C_EntityBoundingBoxXMax              ;; 00:36ff $01 $1c $da
    add  HL, BC                                       ;; 00:3702 $09
    ld   A, [DE]                                      ;; 00:3703 $1a
    ld   [HL+], A                                     ;; 00:3704 $22
    inc  DE                                           ;; 00:3705 $13
    ld   A, [DE]                                      ;; 00:3706 $1a
    ld   [HL+], A                                     ;; 00:3707 $22
    inc  DE                                           ;; 00:3708 $13
    ld   A, [DE]                                      ;; 00:3709 $1a
    ld   [HL+], A                                     ;; 00:370a $22
    inc  DE                                           ;; 00:370b $13
    ld   A, [DE]                                      ;; 00:370c $1a
    ld   [HL+], A                                     ;; 00:370d $22
    inc  DE                                           ;; 00:370e $13
    ld   A, [DE]                                      ;; 00:370f $1a
    ld   [HL+], A                                     ;; 00:3710 $22
    inc  DE                                           ;; 00:3711 $13
    ld   A, [DE]                                      ;; 00:3712 $1a
    ld   [HL+], A                                     ;; 00:3713 $22
    inc  DE                                           ;; 00:3714 $13
    ld   A, [DE]                                      ;; 00:3715 $1a
    ld   [HL+], A                                     ;; 00:3716 $22
    inc  DE                                           ;; 00:3717 $13
    ld   A, [DE]                                      ;; 00:3718 $1a
    ld   [HL], A                                      ;; 00:3719 $77
    ld   HL, wDABB_CurrentEntityId                    ;; 00:371a $21 $bb $da
    ld   L, [HL]                                      ;; 00:371d $6e
    ld   H, $00                                       ;; 00:371e $26 $00
    add  HL, HL                                       ;; 00:3720 $29
    add  HL, HL                                       ;; 00:3721 $29
    add  HL, HL                                       ;; 00:3722 $29
    ld   BC, data_00_3258_EntityAttributeTable        ;; 00:3723 $01 $58 $32
    add  HL, BC                                       ;; 00:3726 $09
    ld   A, [HL+]                                     ;; 00:3727 $2a
    LOAD_OBJ_FIELD_TO_DE_ALT ENTITY_FIELD_ENTITY_ID
    ld   A, [wDABB_CurrentEntityId]                   ;; 00:3730 $fa $bb $da
    ld   [DE], A                                      ;; 00:3733 $12
    ld   A, E                                         ;; 00:3734 $7b
    xor  A, $12                                       ;; 00:3735 $ee $12
    ld   E, A                                         ;; 00:3737 $5f
    ld   A, [HL+]                                     ;; 00:3738 $2a
    ld   [DE], A                                      ;; 00:3739 $12
    inc  E                                            ;; 00:373a $1c
    ld   A, [HL+]                                     ;; 00:373b $2a
    ld   [DE], A                                      ;; 00:373c $12
    inc  E                                            ;; 00:373d $1c
    ld   A, [HL+]                                     ;; 00:373e $2a
    ld   [DE], A                                      ;; 00:373f $12
    inc  E                                            ;; 00:3740 $1c
    xor  A, A                                         ;; 00:3741 $af
    ld   [DE], A                                      ;; 00:3742 $12
    inc  E                                            ;; 00:3743 $1c
    ld   A, [HL+]                                     ;; 00:3744 $2a
    dec  A                                            ;; 00:3745 $3d
    ld   [DE], A                                      ;; 00:3746 $12
    inc  E                                            ;; 00:3747 $1c
    inc  E                                            ;; 00:3748 $1c
    xor  A, A                                         ;; 00:3749 $af
    ld   [DE], A                                      ;; 00:374a $12
    inc  E                                            ;; 00:374b $1c
    ld   A, [HL]                                      ;; 00:374c $7e
    ld   [DE], A                                      ;; 00:374d $12
    inc  E                                            ;; 00:374e $1c
    xor  A, A                                         ;; 00:374f $af
    ld   [DE], A                                      ;; 00:3750 $12
    inc  E                                            ;; 00:3751 $1c
    ld   [DE], A                                      ;; 00:3752 $12
    inc  E                                            ;; 00:3753 $1c
    ld   [DE], A                                      ;; 00:3754 $12
    inc  E                                            ;; 00:3755 $1c
    ld   [DE], A                                      ;; 00:3756 $12
    inc  E                                            ;; 00:3757 $1c
    ld   [DE], A                                      ;; 00:3758 $12
    inc  E                                            ;; 00:3759 $1c
    ld   [DE], A                                      ;; 00:375a $12
    ld   A, E                                         ;; 00:375b $7b
    xor  A, $12                                       ;; 00:375c $ee $12
    ld   E, A                                         ;; 00:375e $5f
    ld   A, $00                                       ;; 00:375f $3e $00
    ld   [DE], A                                      ;; 00:3761 $12
    ld   HL, wDAB9_NextAvailableEntitySlot            ;; 00:3762 $21 $b9 $da
    ld   L, [HL]                                      ;; 00:3765 $6e
    ld   H, $00                                       ;; 00:3766 $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:3768 $11 $01 $da
    add  HL, DE                                       ;; 00:376b $19
    ld   A, [wDABA_EntityCounterRelated]              ;; 00:376c $fa $ba $da
    ld   [HL], A                                      ;; 00:376f $77
    ld   L, A                                         ;; 00:3770 $6f
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:3771 $26 $d7
    ld   A, [wDABC_CurrentEntityFlags]                ;; 00:3773 $fa $bc $da
    or   A, ENTITY_LIST_FLAG_PLACED                   ;; 00:3776 $f6 $40
    ld   [HL], A                                      ;; 00:3778 $77
    and  A, ENTITY_LIST_ACTION_MASK                   ;; 00:3779 $e6 $0f
    farcall call_02_72ac_Entity_SetAction
    farcall call_03_687c_AssignEntityPalette
    ret                                               ;; 00:3791 $c9

call_00_3792_EntitySpawn_SpawnChild:
; The banked entry point for spawning a child entity: pages in the entity list bank
; around the worker below, preserving C, which is the SPAWN_CHILD_ENTITY_* index.
; This is the one the action code in bank 2 calls, twenty-odd times over
    push BC                                           ;; 00:3792 $c5
    ld   A, [wDC16_EntityListBank]                    ;; 00:3793 $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:3796 $cd $ee $0e
    pop  BC                                           ;; 00:3799 $c1
    call call_00_37a0_EntitySpawn_SpawnChildEntity    ;; 00:379a $cd $a0 $37
    jp   call_00_0f08_RestoreBank                     ;; 00:379d $c3 $08 $0f

call_00_37a0_EntitySpawn_SpawnChildEntity:
; Spawns one entity at an offset from the entity currently being processed - a
; projectile leaving a gun, a fly leaving a TV, a boss's separate head.
;
; C selects a row of .data_00_38b6_EntityChildSpawnData, which carries the signed X
; and Y offsets and the child's ENTITY_* id. The child first inherits the parent's
; facing byte, and then two things decide the sign of the X offset: if bank 3 says
; this sprite ignores facing - wDCE9_EntitySpawnPosOffsetFlag, set from
; call_03_59c6_Entity_SpriteIgnoresFacing - the offset is added as written, and
; otherwise it is subtracted when ENTITY_FACING_LEFT_BIT is set. So one row serves
; both ways a parent can face. Y is always added.
;
; The child's fields come from data_00_3259_EntityAttributeTable_WidthBase - the
; width base, so the copy starts at ENTITY_ATTR_WIDTH and runs forward - and the rest
; of its slot is zeroed by hand. ENTITY_FIELD_PARENT is set to the parent's list
; index, which is how a projectile can still be traced back to the enemy that fired
; it after that enemy is gone.
;
; The parent's slot address is saved on the stack and put back at the end, because
; everything in between runs with wDA00_CurrentEntityAddrLo pointing at the CHILD -
; the action set-up and the palette assignment both read it. The last thing it does
; is copy the parent's room bounds into the child's, so a projectile inherits the
; room it was fired in. gex2's call_0a_7b9a_EntitySpawn_SpawnChildEntity
    call call_00_2afc_Entity_FindFreeSlot             ;; 00:37a0 $cd $fc $2a
    ret  Z                                            ;; 00:37a3 $c8
    push DE                                           ;; 00:37a4 $d5
    farcall call_03_59c6_Entity_SpriteIgnoresFacing
    ld   [wDCE9_EntitySpawnPosOffsetFlag], A          ;; 00:37b0 $ea $e9 $dc
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:37b3 $fa $00 $da
    rlca                                              ;; 00:37b6 $07
    rlca                                              ;; 00:37b7 $07
    rlca                                              ;; 00:37b8 $07
    and  A, ENTITY_SLOT_INDEX_MASK                    ;; 00:37b9 $e6 $07
    ld   L, A                                         ;; 00:37bb $6f
    ld   H, $00                                       ;; 00:37bc $26 $00
    ld   DE, wDA01_EntityListIndexesForCurrentEntities ;; 00:37be $11 $01 $da
    add  HL, DE                                       ;; 00:37c1 $19
    ld   A, [HL]                                      ;; 00:37c2 $7e
    ld   [wDCE8_CurrentEntity_ParentListIndex], A     ;; 00:37c3 $ea $e8 $dc
    pop  DE                                           ;; 00:37c6 $d1
    ld   L, C                                         ;; 00:37c7 $69
    ld   H, $00                                       ;; 00:37c8 $26 $00
    add  HL, HL                                       ;; 00:37ca $29
    add  HL, HL                                       ;; 00:37cb $29
    add  HL, HL                                       ;; 00:37cc $29
    ld   BC, .data_00_38b6_EntityChildSpawnData       ;; 00:37cd $01 $b6 $38
    add  HL, BC                                       ;; 00:37d0 $09
    ld   A, [HL+]                                     ;; 00:37d1 $2a
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 00:37d2 $fa $00 $da
    push AF                                           ;; 00:37d5 $f5
    or   A, ENTITY_FIELD_FACING_DIRECTION             ;; 00:37d6 $f6 $0d
    ld   C, A                                         ;; 00:37d8 $4f
    ld   B, HIGH(wD800_EntityMemory)                  ;; 00:37d9 $06 $d8
    ld   A, D                                         ;; 00:37db $7a
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 00:37dc $ea $00 $da
    or   A, ENTITY_FIELD_FACING_DIRECTION             ;; 00:37df $f6 $0d
    ld   E, A                                         ;; 00:37e1 $5f
    ld   D, B                                         ;; 00:37e2 $50
    ld   A, [BC]                                      ;; 00:37e3 $0a
    ld   [DE], A                                      ;; 00:37e4 $12
    ld   A, [wDCE9_EntitySpawnPosOffsetFlag]          ;; 00:37e5 $fa $e9 $dc
    and  A, A                                         ;; 00:37e8 $a7
    jr   NZ, .jr_00_37f0                              ;; 00:37e9 $20 $05
    ld   A, [DE]                                      ;; 00:37eb $1a
    bit  ENTITY_FACING_LEFT_BIT, A                    ;; 00:37ec $cb $6f
    jr   NZ, .jr_00_37fd                              ;; 00:37ee $20 $0d
.jr_00_37f0:
    inc  C                                            ;; 00:37f0 $0c
    inc  E                                            ;; 00:37f1 $1c
    ld   A, [BC]                                      ;; 00:37f2 $0a ; load parent entity x position (lo)
    add  A, [HL]                                      ;; 00:37f3 $86 ; add offset from table below
    ld   [DE], A                                      ;; 00:37f4 $12 ; set new entity x position (lo)
    inc  BC                                           ;; 00:37f5 $03
    inc  DE                                           ;; 00:37f6 $13
    inc  HL                                           ;; 00:37f7 $23
    ld   A, [BC]                                      ;; 00:37f8 $0a ; load parent entity x position (hi)
    adc  A, [HL]                                      ;; 00:37f9 $8e ; add different offset from table below
    ld   [DE], A                                      ;; 00:37fa $12 ; set new entity x position (hi)
    jr   .jr_00_3808                                  ;; 00:37fb $18 $0b
.jr_00_37fd:
    inc  C                                            ;; 00:37fd $0c
    inc  E                                            ;; 00:37fe $1c
    ld   A, [BC]                                      ;; 00:37ff $0a
    sub  A, [HL]                                      ;; 00:3800 $96 ; same as above but subtracts instead of adds
    ld   [DE], A                                      ;; 00:3801 $12
    inc  BC                                           ;; 00:3802 $03
    inc  DE                                           ;; 00:3803 $13
    inc  HL                                           ;; 00:3804 $23
    ld   A, [BC]                                      ;; 00:3805 $0a
    sbc  A, [HL]                                      ;; 00:3806 $9e
    ld   [DE], A                                      ;; 00:3807 $12
.jr_00_3808:
    inc  C                                            ;; 00:3808 $0c
    inc  E                                            ;; 00:3809 $1c
    inc  HL                                           ;; 00:380a $23
    ld   A, [BC]                                      ;; 00:380b $0a
    add  A, [HL]                                      ;; 00:380c $86
    ld   [DE], A                                      ;; 00:380d $12 ; same thing as above but for y position lo
    inc  BC                                           ;; 00:380e $03
    inc  DE                                           ;; 00:380f $13
    inc  HL                                           ;; 00:3810 $23
    ld   A, [BC]                                      ;; 00:3811 $0a ; now hl points to entity id in table below
    adc  A, [HL]                                      ;; 00:3812 $8e
    ld   [DE], A                                      ;; 00:3813 $12 ;
    inc  HL                                           ;; 00:3814 $23
    ld   A, E                                         ;; 00:3815 $7b
    xor  A, $11                                       ;; 00:3816 $ee $11
    ld   E, A                                         ;; 00:3818 $5f
    ld   A, [HL+]                                     ;; 00:3819 $2a
    ld   [DE], A                                      ;; 00:381a $12
    ld   L, A                                         ;; 00:381b $6f
    ld   H, $00                                       ;; 00:381c $26 $00
    add  HL, HL                                       ;; 00:381e $29
    add  HL, HL                                       ;; 00:381f $29
    add  HL, HL                                       ;; 00:3820 $29
    ld   BC, data_00_3259_EntityAttributeTable_WidthBase ;; 00:3821 $01 $59 $32
    add  HL, BC                                       ;; 00:3824 $09
    ld   A, E                                         ;; 00:3825 $7b
    xor  A, $12                                       ;; 00:3826 $ee $12
    ld   E, A                                         ;; 00:3828 $5f
    ld   A, [HL+]                                     ;; 00:3829 $2a
    ld   [DE], A                                      ;; 00:382a $12
    inc  E                                            ;; 00:382b $1c ; ENTITY_FIELD_COLLISION_HEIGHT
    ld   A, [HL+]                                     ;; 00:382c $2a
    ld   [DE], A                                      ;; 00:382d $12
    inc  E                                            ;; 00:382e $1c ; ENTITY_FIELD_COLLISION_TYPE
    ld   A, [HL+]                                     ;; 00:382f $2a
    ld   [DE], A                                      ;; 00:3830 $12
    inc  E                                            ;; 00:3831 $1c ; ENTITY_FIELD_COOLDOWN_TIMER
    xor  A, A                                         ;; 00:3832 $af
    ld   [DE], A                                      ;; 00:3833 $12
    inc  E                                            ;; 00:3834 $1c ; ENTITY_FIELD_DAMAGE_STATE
    ld   A, [HL+]                                     ;; 00:3835 $2a
    dec  A                                            ;; 00:3836 $3d
    ld   [DE], A                                      ;; 00:3837 $12
    inc  E                                            ;; 00:3838 $1c ; ENTITY_FIELD_SPRITE_BANK
    inc  E                                            ;; 00:3839 $1c ; ENTITY_FIELD_UNK18
    xor  A, A                                         ;; 00:383a $af
    ld   [DE], A                                      ;; 00:383b $12
    inc  E                                            ;; 00:383c $1c ; ENTITY_FIELD_MISC_FLAGS
    ld   A, [HL+]                                     ;; 00:383d $2a
    ld   [DE], A                                      ;; 00:383e $12
    inc  E                                            ;; 00:383f $1c ; ENTITY_FIELD_MISC_TIMER
    xor  A, A                                         ;; 00:3840 $af
    ld   [DE], A                                      ;; 00:3841 $12
    inc  E                                            ;; 00:3842 $1c ; ENTITY_FIELD_X_VELOCITY
    ld   [DE], A                                      ;; 00:3843 $12
    inc  E                                            ;; 00:3844 $1c ; ENTITY_FIELD_X_SUBPIXEL
    ld   [DE], A                                      ;; 00:3845 $12
    inc  E                                            ;; 00:3846 $1c ; ENTITY_FIELD_Y_VELOCITY
    ld   [DE], A                                      ;; 00:3847 $12
    inc  E                                            ;; 00:3848 $1c ; ENTITY_FIELD_Y_SUBPIXEL
    ld   [DE], A                                      ;; 00:3849 $12
    inc  E                                            ;; 00:384a $1c ; ENTITY_FIELD_PARENT
    ld   A, [wDCE8_CurrentEntity_ParentListIndex]     ;; 00:384b $fa $e8 $dc
    ld   [DE], A                                      ;; 00:384e $12 
    call call_00_2a03_Entity_ResetEntityListIndex     ;; 00:384f $cd $03 $2a
    xor  A, A                                         ;; 00:3852 $af
    farcall call_02_72ac_Entity_SetAction
    farcall call_03_687c_AssignEntityPalette
    pop  AF                                           ;; 00:3869 $f1
    ld   HL, wDA00_CurrentEntityAddrLo                ;; 00:386a $21 $00 $da
    ld   C, [HL]                                      ;; 00:386d $4e
    ld   [HL], A                                      ;; 00:386e $77
    rrca                                              ;; 00:386f $0f
    and  A, ENTITY_BOUNDS_INDEX_MASK                  ;; 00:3870 $e6 $70
    ld   L, A                                         ;; 00:3872 $6f
    ld   H, $00                                       ;; 00:3873 $26 $00
    ld   DE, wDA1C_EntityBoundingBoxXMax              ;; 00:3875 $11 $1c $da
    add  HL, DE                                       ;; 00:3878 $19
    ld   E, L                                         ;; 00:3879 $5d
    ld   D, H                                         ;; 00:387a $54
    ld   A, C                                         ;; 00:387b $79
    rrca                                              ;; 00:387c $0f
    and  A, ENTITY_BOUNDS_INDEX_MASK                  ;; 00:387d $e6 $70
    ld   L, A                                         ;; 00:387f $6f
    ld   H, $00                                       ;; 00:3880 $26 $00
    ld   BC, wDA1C_EntityBoundingBoxXMax              ;; 00:3882 $01 $1c $da
    add  HL, BC                                       ;; 00:3885 $09
    ld   A, [DE]                                      ;; 00:3886 $1a
    ld   [HL+], A                                     ;; 00:3887 $22
    inc  DE                                           ;; 00:3888 $13
    ld   A, [DE]                                      ;; 00:3889 $1a
    ld   [HL+], A                                     ;; 00:388a $22
    inc  DE                                           ;; 00:388b $13
    ld   A, [DE]                                      ;; 00:388c $1a
    ld   [HL+], A                                     ;; 00:388d $22
    inc  DE                                           ;; 00:388e $13
    ld   A, [DE]                                      ;; 00:388f $1a
    ld   [HL+], A                                     ;; 00:3890 $22
    inc  DE                                           ;; 00:3891 $13
    ld   A, [DE]                                      ;; 00:3892 $1a
    ld   [HL+], A                                     ;; 00:3893 $22
    inc  DE                                           ;; 00:3894 $13
    ld   A, [DE]                                      ;; 00:3895 $1a
    ld   [HL+], A                                     ;; 00:3896 $22
    inc  DE                                           ;; 00:3897 $13
    ld   A, [DE]                                      ;; 00:3898 $1a
    ld   [HL+], A                                     ;; 00:3899 $22
    inc  DE                                           ;; 00:389a $13
    ld   A, [DE]                                      ;; 00:389b $1a
    ld   [HL+], A                                     ;; 00:389c $22
    inc  DE                                           ;; 00:389d $13
    ld   A, [DE]                                      ;; 00:389e $1a
    ld   [HL+], A                                     ;; 00:389f $22
    inc  DE                                           ;; 00:38a0 $13
    ld   A, [DE]                                      ;; 00:38a1 $1a
    ld   [HL+], A                                     ;; 00:38a2 $22
    inc  DE                                           ;; 00:38a3 $13
    ld   A, [DE]                                      ;; 00:38a4 $1a
    ld   [HL+], A                                     ;; 00:38a5 $22
    inc  DE                                           ;; 00:38a6 $13
    ld   A, [DE]                                      ;; 00:38a7 $1a
    ld   [HL+], A                                     ;; 00:38a8 $22
    inc  DE                                           ;; 00:38a9 $13
    ld   A, [DE]                                      ;; 00:38aa $1a
    ld   [HL+], A                                     ;; 00:38ab $22
    inc  DE                                           ;; 00:38ac $13
    ld   A, [DE]                                      ;; 00:38ad $1a
    ld   [HL+], A                                     ;; 00:38ae $22
    inc  DE                                           ;; 00:38af $13
    ld   A, [DE]                                      ;; 00:38b0 $1a
    ld   [HL+], A                                     ;; 00:38b1 $22
    inc  DE                                           ;; 00:38b2 $13
    ld   A, [DE]                                      ;; 00:38b3 $1a
    ld   [HL], A                                      ;; 00:38b4 $77
    ret                                               ;; 00:38b5 $c9
.data_00_38b6_EntityChildSpawnData:
; One record per SPAWN_CHILD_ENTITY_* id, ENTITY_ATTR_RECORD_SIZE bytes each:
;
;   +0     read and thrown away. The `ld A, [HL+]` that fetches it exists only to
;          step HL past it - the value never reaches anything. It is $00 or $01 in
;          the data, so it looks like a direction flag that was replaced by the
;          ENTITY_FACING_LEFT test and left behind
;   +1 +2  signed X offset from the parent
;   +3 +4  signed Y offset, always added
;   +5     the child's ENTITY_* id
;   +6 +7  padding, never read
;
; The first 31 records are the ones SPAWN_CHILD_ENTITY_* names. What follows them is
; two loose bytes and then a second copy of the last eight records, sitting at an
; offset no index reaches - dead data at the very end of bank 0.
;
; gex2's .data_0a_7c92_EntityChildSpawnData is the same table without the direction
; flag: there the parent's facing alone decides the sign
    EntityChildSpawnData $01, $0000, -$0020, ENTITY_FLY_1                              ; SPAWN_CHILD_ENTITY_FLY_1
    EntityChildSpawnData $01, $0000, -$0020, ENTITY_FLY_2                              ; SPAWN_CHILD_ENTITY_FLY_2
    EntityChildSpawnData $01, $0000, -$0020, ENTITY_FLY_3                              ; SPAWN_CHILD_ENTITY_FLY_3
    EntityChildSpawnData $01, $0000, -$0020, ENTITY_FLY_4                              ; SPAWN_CHILD_ENTITY_FLY_4
    EntityChildSpawnData $01, $0000, -$0020, ENTITY_FLY_5                              ; SPAWN_CHILD_ENTITY_FLY_5
    EntityChildSpawnData $01, -$000D, -$0003, ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE  ; SPAWN_CHILD_ENTITY_EVIL_SANTA_PROJECTILE
    EntityChildSpawnData $01, $000E, -$0005, ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE   ; SPAWN_CHILD_ENTITY_SAFARI_SAM_PROJECTILE
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_1                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_1
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_2                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_2
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_3                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_3
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_4                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_4
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_5                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_5
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_6                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_6
    EntityChildSpawnData $01, $0000, $0000, ENTITY_GOAL_COUNTER_7                      ; SPAWN_CHILD_ENTITY_GOAL_COUNTER_7
    EntityChildSpawnData $01, $0007, $0007, ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE       ; SPAWN_CHILD_ENTITY_SNAKE_RIGHT_PROJECTILE
    EntityChildSpawnData $01, $0007, $0007, ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE        ; SPAWN_CHILD_ENTITY_SNAKE_LEFT_PROJECTILE
    EntityChildSpawnData $01, $000C, $0000, ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE     ; SPAWN_CHILD_ENTITY_SECBOT_PROJECTILE
    EntityChildSpawnData $00, $0000, $0000, ENTITY_UNK0E                               ; SPAWN_CHILD_ENTITY_UNK0E
    EntityChildSpawnData $00, $0000, $0000, ENTITY_UNK0F                               ; SPAWN_CHILD_ENTITY_UNK0F
    EntityChildSpawnData $00, $0000, $0000, ENTITY_UNK10                               ; SPAWN_CHILD_ENTITY_UNK10
    EntityChildSpawnData $00, $0000, $0008, ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE   ; SPAWN_CHILD_ENTITY_CONVICT_PROJECTILE
    EntityChildSpawnData $00, -$0010, $0004, ENTITY_SUPERHERO_SHOW_BOMB                ; SPAWN_CHILD_ENTITY_BOMB
    EntityChildSpawnData $00, $0001, -$0010, ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE     ; SPAWN_CHILD_ENTITY_CANNON_PROJECTILE
    EntityChildSpawnData $00, $0000, $0000, ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2    ; SPAWN_CHILD_ENTITY_CANNON_PROJECTILE_2
    EntityChildSpawnData $00, $0000, $0008, ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE ; SPAWN_CHILD_ENTITY_BRAIN_OF_OZ_PROJECTILE
    EntityChildSpawnData $00, $0000, $0000, ENTITY_BONUS_STAGE_TIMER                   ; SPAWN_CHILD_ENTITY_STAGE_TIMER
    EntityChildSpawnData $01, $0000, $0000, ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE     ; SPAWN_CHILD_ENTITY_SECBOT_PROJECTILE_2
    EntityChildSpawnData $01, $0004, -$000E, ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE ; SPAWN_CHILD_ENTITY_GHOST_KNIGHT_PROJECTILE
    EntityChildSpawnData $00, -$0001, $000B, ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE  ; SPAWN_CHILD_ENTITY_BIRD_PROJECTILE
    EntityChildSpawnData $00, -$0040, $0050, ENTITY_CHANNEL_Z_REZ_PROJECTILE           ; SPAWN_CHILD_ENTITY_REZ_PROJECTILE
    EntityChildSpawnData $00, $0040, $0050, ENTITY_CHANNEL_Z_REZ_PROJECTILE            ; SPAWN_CHILD_ENTITY_REZ_PROJECTILE_2
    db   $00, $00                                                                      ; two stray bytes - the rows below are a copy of
                                                                                       ; the last eight, at an offset nothing indexes
    EntityChildSpawnData $00, $0000, $0000, ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2    ; unreachable
    EntityChildSpawnData $00, $0000, $0008, ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE ; unreachable
    EntityChildSpawnData $00, $0000, $0000, ENTITY_BONUS_STAGE_TIMER                   ; unreachable
    EntityChildSpawnData $01, $0000, $0000, ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE     ; unreachable
    EntityChildSpawnData $01, $0004, -$000E, ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE ; unreachable
    EntityChildSpawnData $00, -$0001, $000B, ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE  ; unreachable
    EntityChildSpawnData $00, -$0040, $0050, ENTITY_CHANNEL_Z_REZ_PROJECTILE           ; unreachable
    EntityChildSpawnData $00, $0040, $0050, ENTITY_CHANNEL_Z_REZ_PROJECTILE            ; unreachable
