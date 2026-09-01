; ==================================================================
; Bank 2. Two levels of table between "this entity is doing action N" and the code
; that runs, plus the animation data blocks each action carries.
;
;   data_02_4000_EntityActionJumpTable  one word per entity id, pointing at that
;       entity type's own action table. Row order IS the ENTITY_* numbering
;   the per-type tables below  four bytes per action id: the action function, then
;       a pointer to that action's data block in bank02_entity_animation_data.asm
;
; call_02_72ac_Entity_SetAction does both lookups in one go - entity id doubled into
; the first table, action id times four into the result - so an entity's action ids
; are positions in its own table and mean nothing outside it. The data block it
; lands on carries the frame timings, the first sprite id, the pending action and
; the pointer to the sprite id list; see call_02_724d_Entity_TickAction for what
; happens to each field.
;
; Gex's table is the first one, .data_02_40e4, and it is the odd one out: 120 rows
; rather than a handful, because it holds the whole player action list TWICE.
; $00-$3B are the side-scrolling actions and $3C-$77 are the top-down ones, which is
; the PLAYERACTION_TOPDOWN offset that call_02_54f9_Player_RequestAction adds when
; the map's collision type is BG_COLLISION_TYPE_TOPDOWN.
;
; The second copy is identical to the first in 59 of its 60 rows. The exception is
; PLAYERACTION_CROUCH_LOOK_DOWN, which becomes call_02_582e_EntityAction_None -
; there is no looking down on a top-down map. Everything else that differs between
; the two modes differs inside the shared routine, not here.
;
; The per-type tables are named for the entity they belong to wherever that is
; known - .data_02_4354_EntityActions_HolidayTVIceSculpture and so on - and the
; rows carry the action id and a word on what that action is. Where two entity ids
; share one table, both are named on it: the two snakes and the two Ra statue
; shots each run one table and tell themselves apart with Entity_GetId.
;
; gex2's equivalent is data_02_4000_EntityActionJumpTable in
; bank02_update_entities.asm, with the same two-level layout and the same four-byte
; rows. It has no second player block, because gex2 has no top-down maps
; ==================================================================

data_02_4000_EntityActionJumpTable:
   dw   .data_02_40e4 ; ENTITY_GEX
   dw   .data_02_42c4 ; ENTITY_BONUS_COIN
   dw   .data_02_42cc ; ENTITY_FLY_COIN_SPAWN
   dw   .data_02_42d4 ; ENTITY_PAW_COIN
   dw   .data_02_42dc ; ENTITY_FLY_1
   dw   .data_02_42dc ; ENTITY_FLY_2
   dw   .data_02_42dc ; ENTITY_FLY_3
   dw   .data_02_42dc ; ENTITY_FLY_4
   dw   .data_02_42dc ; ENTITY_FLY_5
   dw   .data_02_42e0 ; ENTITY_GREEN_FLY_TV
   dw   .data_02_42e0 ; ENTITY_PURPLE_FLY_TV
   dw   .data_02_42e0 ; ENTITY_UNK_FLY_TV_3
   dw   .data_02_42e0 ; ENTITY_BLUE_FLY_TV
   dw   .data_02_42e0 ; ENTITY_UNK_FLY_TV_5
   dw   .data_02_42f4 ; ENTITY_UNK0E
   dw   .data_02_42f8 ; ENTITY_UNK0F
   dw   .data_02_42fc ; ENTITY_UNK10
   dw   .data_02_4300 ; ENTITY_TV_BUTTON
   dw   .data_02_4310 ; ENTITY_TV_REMOTE
   dw   .data_02_4324 ; ENTITY_UNK13
   dw   .data_02_4328 ; ENTITY_GOAL_COUNTER_1
   dw   .data_02_432c ; ENTITY_GOAL_COUNTER_2
   dw   .data_02_4330 ; ENTITY_GOAL_COUNTER_3
   dw   .data_02_4334 ; ENTITY_GOAL_COUNTER_4
   dw   .data_02_4338 ; ENTITY_GOAL_COUNTER_5
   dw   .data_02_433c ; ENTITY_GOAL_COUNTER_6
   dw   .data_02_4340 ; ENTITY_GOAL_COUNTER_7
   dw   .data_02_4344 ; ENTITY_BONUS_STAGE_TIMER
   dw   .data_02_4348 ; ENTITY_FREESTANDING_REMOTE
   dw   .data_02_4354_EntityActions_HolidayTVIceSculpture ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
   dw   .data_02_4360_EntityActions_HolidayTVEvilSanta ; ENTITY_HOLIDAY_TV_EVIL_SANTA
   dw   .data_02_437c_EntityActions_HolidayTVEvilSantaProjectile ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
   dw   .data_02_4398_EntityActions_HolidayTVSkatingElf ; ENTITY_HOLIDAY_TV_SKATING_ELF
   dw   .data_02_43b0_EntityActions_HolidayTVPenguin ; ENTITY_HOLIDAY_TV_PENGUIN
   dw   .data_02_43c0_EntityActions_MysteryTVRezling ; ENTITY_MYSTERY_TV_REZLING
   dw   .data_02_43d8_EntityActions_MysteryTVBloodCooler ; ENTITY_MYSTERY_TV_BLOOD_COOLER
   dw   .data_02_43e0_EntityActions_MysteryTVFish ; ENTITY_MYSTERY_TV_FISH
   dw   .data_02_43e8_EntityActions_MysteryTVMagicSword ; ENTITY_MYSTERY_TV_MAGIC_SWORD
   dw   .data_02_43f4_EntityActions_MysteryTVSafariSam ; ENTITY_MYSTERY_TV_SAFARI_SAM
   dw   .data_02_4408_EntityActions_MysteryTVSafariSamProjectile ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
   dw   .data_02_440c_EntityActions_MysteryTVGhostKnight ; ENTITY_MYSTERY_TV_GHOST_KNIGHT
   dw   .data_02_4424_EntityActions_MysteryTVGhostKnightProjectile ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
   dw   .data_02_4428_EntityActions_TutTVHand ; ENTITY_TUT_TV_HAND
   dw   .data_02_4440_EntityActions_TutTVLostArk ; ENTITY_TUT_TV_LOST_ARK
   dw   .data_02_4454_EntityActions_TutTVRisingPlatform ; ENTITY_TUT_TV_RISING_PLATFORM
   dw   .data_02_4458_EntityActions_TutTVSidewaysPlatform ; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
   dw   .data_02_445c_EntityActions_TutTVBee ; ENTITY_TUT_TV_BEE
   dw   .data_02_4470_EntityActions_TutTVRaft ; ENTITY_TUT_TV_RAFT
   dw   .data_02_447c_EntityActions_TutTVSnake ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
   dw   .data_02_447c_EntityActions_TutTVSnake ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
   dw   .data_02_4490_EntityActions_TutTVSnakeRightProjectile ; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
   dw   .data_02_4494_EntityActions_TutTVSnakeLeftProjectile ; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
   dw   .data_02_4498_EntityActions_TutTVRaStaff ; ENTITY_TUT_TV_RA_STAFF
   dw   .data_02_44a0_EntityActions_TutTVRaStatueProjectile ; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE
   dw   .data_02_44a0_EntityActions_TutTVRaStatueProjectile ; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
   dw   .data_02_44b0_EntityActions_TutTVBreakableBlock ; ENTITY_TUT_TV_BREAKABLE_BLOCK
   dw   .data_02_44c0_EntityActions_TutTVCoffin ; ENTITY_TUT_TV_COFFIN
   dw   .data_02_44cc ; ENTITY_WESTERN_STATION_ENEMY_CACTUS
   dw   .data_02_44e8 ; ENTITY_WESTERN_STATION_CACTUS
   dw   .data_02_44ec ; ENTITY_WESTERN_STATION_ROCK_PLATFORM
   dw   .data_02_44fc ; ENTITY_WESTERN_STATION_HARD_HAT
   dw   .data_02_4510 ; ENTITY_WESTERN_STATION_PLAYING_CARD
   dw   .data_02_4518 ; ENTITY_WESTERN_STATION_BAT
   dw   .data_02_452c ; ENTITY_WESTERN_STATION_RISING_PLATFORM
   dw   .data_02_4530 ; ENTITY_ANIME_CHANNEL_DOOR
   dw   .data_02_4540 ; ENTITY_ANIME_CHANNEL_DOOR2
   dw   .data_02_4550 ; ENTITY_ANIME_CHANNEL_FAN_LIFT
   dw   .data_02_4560 ; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT
   dw   .data_02_4568 ; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
   dw   .data_02_4570 ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR
   dw   .data_02_4578 ; ENTITY_ANIME_CHANNEL_ON_SWITCH2
   dw   .data_02_4580 ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
   dw   .data_02_458c ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER
   dw   .data_02_4594 ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM
   dw   .data_02_4598 ; ENTITY_ANIME_CHANNEL_ON_SWITCH
   dw   .data_02_45a0 ; ENTITY_ANIME_CHANNEL_OFF_SWITCH
   dw   .data_02_45a8 ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
   dw   .data_02_45c8 ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
   dw   .data_02_45d8 ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
   dw   .data_02_45e4 ; ENTITY_ANIME_CHANNEL_SECBOT
   dw   .data_02_45f8 ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
   dw   .data_02_45fc ; ENTITY_ANIME_CHANNEL_ELEVATOR
   dw   .data_02_4600 ; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY
   dw   .data_02_4604 ; ENTITY_ANIME_CHANNEL_GRENADE
   dw   .data_02_4610 ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
   dw   .data_02_4618 ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER
   dw   .data_02_4630 ; ENTITY_SUPERHERO_SHOW_BOMB
   dw   .data_02_4644 ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
   dw   .data_02_4650 ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
   dw   .data_02_4658 ; ENTITY_SUPERHERO_SHOW_CONVICT
   dw   .data_02_4668 ; ENTITY_SUPERHERO_SHOW_SPIDER
   dw   .data_02_4678 ; ENTITY_SUPERHERO_SHOW_STRAY_CAT
   dw   .data_02_4690 ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON
   dw   .data_02_46a0 ; ENTITY_SUPERHERO_SHOW_RAT
   dw   .data_02_46ac ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV
   dw   .data_02_46bc ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
   dw   .data_02_46c8 ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
   dw   .data_02_46cc ; ENTITY_GEXTREME_SPORTS_ELF
   dw   .data_02_46e4 ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
   dw   .data_02_46ec ; ENTITY_MARSUPIAL_MADNESS_BELL
   dw   .data_02_46f8 ; ENTITY_MARSUPIAL_MADNESS_BIRD
   dw   .data_02_46fc ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
   dw   .data_02_4704 ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD
   dw   .data_02_4720 ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
   dw   .data_02_4744 ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
   dw   .data_02_4748 ; ENTITY_LIZARD_OF_OZ_CANNON
   dw   .data_02_475c ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
   dw   .data_02_4760 ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2
   dw   .data_02_4764 ; ENTITY_CHANNEL_Z_GREEN_BLOCK
   dw   .data_02_4768 ; ENTITY_CHANNEL_Z_ORANGE_BLOCK
   dw   .data_02_476c ; ENTITY_CHANNEL_Z_REZ
   dw   .data_02_479c ; ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
   dw   .data_02_47a0 ; ENTITY_CHANNEL_Z_METEOR
   dw   .data_02_47ac ; ENTITY_CHANNEL_Z_REZ_PROJECTILE
.data_02_40e4:
; Gex's action table, and the only one here with two halves. Rows $00-$3B are the
; side-scrolling actions; rows $3C-$77 are the same 60 actions again for top-down
; maps, which is what the PLAYERACTION_TOPDOWN offset indexes.
;
; Verbatim duplicates except for one row: PLAYERACTION_CROUCH_LOOK_DOWN is
; call_02_582e_EntityAction_None in the second half, because looking down does
; nothing on a top-down map
    dw  call_02_47b4_PlayerAction_Spawn, data_02_739b ; PLAYERACTION_SPAWN
    dw  call_02_47ce_PlayerAction_Idle, data_02_73ab ; PLAYERACTION_IDLE
    dw  call_02_47fe_PlayerAction_IdleAnimation, data_02_73b1 ; PLAYERACTION_IDLE_ANIMATION
    dw  call_02_480a_PlayerAction_Walk, data_02_73c5 ; PLAYERACTION_WALK
    dw  call_02_481a_PlayerAction_StartCrouch, data_02_73da ; PLAYERACTION_START_CROUCH
    dw  call_02_481f_PlayerAction_CrouchLookDown, data_02_73e6 ; PLAYERACTION_CROUCH_LOOK_DOWN
    dw  call_02_582e_EntityAction_None, data_02_73ef ; PLAYERACTION_NONE_0
    dw  call_02_482e_PlayerAction_Unk7, data_02_73da ; PLAYERACTION_UNK7
    dw  call_02_483e_PlayerAction_EatFly, data_02_73fb ; PLAYERACTION_EAT_FLY
    dw  call_02_484d_PlayerAction_TakeDamage, data_02_7401 ; PLAYERACTION_TAKE_DAMAGE
    dw  call_02_4873_PlayerAction_Death, data_02_7408 ; PLAYERACTION_DEATH
    dw  call_02_4889_PlayerAction_DeathSetUpWarp, data_02_7411 ; PLAYERACTION_DEATH_SET_UP_WARP
    dw  call_02_48a1_PlayerAction_StandOnTVButton, data_02_7422 ; PLAYERACTION_STAND_ON_TV_BUTTON
    dw  call_02_48b0_PlayerAction_EnterTV, data_02_7428 ; PLAYERACTION_ENTER_TV
    dw  call_02_48bc_PlayerAction_Jump, data_02_7435 ; PLAYERACTION_JUMP
    dw  call_02_48e8_PlayerAction_DoubleJump, data_02_7442 ; PLAYERACTION_DOUBLE_JUMP
    dw  call_02_4911_PlayerAction_TailSpin, data_02_744e ; PLAYERACTION_TAIL_SPIN
    dw  call_02_4957_PlayerAction_Fall, data_02_745b ; PLAYERACTION_FALL
    dw  call_02_497a_PlayerAction_LandFromFall, data_02_746d ; PLAYERACTION_LAND_FROM_FALL
    dw  call_02_4989_PlayerAction_Unk19, data_02_7473 ; PLAYERACTION_UNK19
    dw  call_02_49a8_PlayerAction_EnterIdle, data_02_7473 ; PLAYERACTION_ENTER_IDLE
    dw  call_02_49b2_PlayerAction_None, data_02_7479 ; PLAYERACTION_NONE_1
    dw  call_02_49b2_PlayerAction_None, data_02_747f ; PLAYERACTION_NONE_2
    dw  call_02_49b2_PlayerAction_None, data_02_748f ; PLAYERACTION_NONE_3
    dw  call_02_49b2_PlayerAction_None, data_02_749f ; PLAYERACTION_NONE_4
    dw  call_02_49b3_PlayerAction_Water_Swimming, data_02_74a5 ; PLAYERACTION_WATER_SWIMMING
    dw  call_02_4a25_PlayerAction_DeathInPitAlt, data_02_745b ; PLAYERACTION_DEATH_IN_PIT_ALT
    dw  call_02_4a37_PlayerAction_DeathInPit, data_02_74ab ; PLAYERACTION_DEATH_IN_PIT
    dw  call_02_4a51_PlayerAction_None2, data_02_74bd ; PLAYERACTION_NONE_5
    dw  call_02_4a52_PlayerAction_BlownUpwards, data_02_74c8 ; PLAYERACTION_BLOWN_UPWARDS
    dw  call_02_4a69_PlayerAction_RidingElevator, data_02_74ce ; PLAYERACTION_RIDING_ELEVATOR
    dw  call_02_4a6e_PlayerAction_Water_TailSpin, data_02_74d4 ; PLAYERACTION_WATER_TAIL_SPIN
    dw  call_02_4a9b_PlayerAction_Water_Treading, data_02_74e1 ; PLAYERACTION_WATER_TREADING
    dw  call_02_4aa1_PlayerAction_Water_Diving, data_02_74ed ; PLAYERACTION_WATER_DIVING
    dw  call_02_4aac_PlayerAction_Climbing, data_02_74f7 ; PLAYERACTION_CLIMBING
    dw  call_02_47b4_PlayerAction_Spawn, data_02_74fd ; PLAYERACTION_SNOWBOARDING_SPAWN
    dw  call_02_4bb7_PlayerAction_Snowboarding_StandOrWalk, data_02_750d ; PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    dw  call_02_4c2c_PlayerAction_Snowboarding_Jump, data_02_753b ; PLAYERACTION_SNOWBOARDING_JUMP
    dw  call_02_4c58_PlayerAction_Snowboarding_DoubleJump, data_02_7543 ; PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    dw  call_02_4c7a_PlayerAction_Snowboarding_TailSpin, data_02_754b ; PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    dw  call_02_4ca4_PlayerAction_Snowboarding_Fall, data_02_7551 ; PLAYERACTION_SNOWBOARDING_FALL
    dw  call_02_4cbd_PlayerAction_Snowboarding_TakeDamage, data_02_7513 ; PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    dw  call_02_4873_PlayerAction_Death, data_02_7519 ; PLAYERACTION_SNOWBOARDING_DIE
    dw  call_02_4889_PlayerAction_DeathSetUpWarp, data_02_7522 ; PLAYERACTION_SNOWBOARDING_DIE_WARP
    dw  call_02_48a1_PlayerAction_StandOnTVButton, data_02_7528 ; PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON
    dw  call_02_48b0_PlayerAction_EnterTV, data_02_752e ; PLAYERACTION_SNOWBOARDING_ENTER_TV
    dw  call_02_4a25_PlayerAction_DeathInPitAlt, data_02_7551 ; PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
    dw  call_02_47b4_PlayerAction_Spawn, data_02_7559 ; PLAYERACTION_KANGAROO_SPAWN
    dw  call_02_4ce3_PlayerAction_Kangaroo_Idle, data_02_758e ; PLAYERACTION_KANGAROO_IDLE
    dw  call_02_4d02_PlayerAction_Kangaroo_Hopping, data_02_7594 ; PLAYERACTION_KANGAROO_HOPPING
    dw  call_02_4d14_PlayerAction_Kangaroo_StartJump, data_02_759f ; PLAYERACTION_KANGAROO_START_JUMP
    dw  call_02_4d33_PlayerAction_Kangaroo_Jump, data_02_75a5 ; PLAYERACTION_KANGAROO_JUMP
    dw  call_02_4d45_PlayerAction_Kangaroo_TailSpin, data_02_75ae ; PLAYERACTION_KANGAROO_TAIL_SPIN
    dw  call_02_4d72_PlayerAction_Kangaroo_Fall, data_02_75bb ; PLAYERACTION_KANGAROO_FALL
    dw  call_02_4d8b_PlayerAction_Kangaroo_TakeDamage, data_02_7569 ; PLAYERACTION_KANGAROO_TAKE_DAMAGE
    dw  call_02_4873_PlayerAction_Death, data_02_756f ; PLAYERACTION_KANGAROO_DEATH
    dw  call_02_4889_PlayerAction_DeathSetUpWarp, data_02_7576 ; PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    dw  call_02_48a1_PlayerAction_StandOnTVButton, data_02_757c ; PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON
    dw  call_02_48b0_PlayerAction_EnterTV, data_02_7582 ; PLAYERACTION_KANGAROO_ENTER_TV
    dw  call_02_4a25_PlayerAction_DeathInPitAlt, data_02_75bb ; PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT

    dw  call_02_47b4_PlayerAction_Spawn, data_02_739b ; PLAYERACTION_SPAWN + PLAYERACTION_TOPDOWN
    dw  call_02_47ce_PlayerAction_Idle, data_02_73ab ; PLAYERACTION_IDLE + PLAYERACTION_TOPDOWN
    dw  call_02_47fe_PlayerAction_IdleAnimation, data_02_73b1 ; PLAYERACTION_IDLE_ANIMATION + PLAYERACTION_TOPDOWN
    dw  call_02_480a_PlayerAction_Walk, data_02_73c5 ; PLAYERACTION_WALK + PLAYERACTION_TOPDOWN
    dw  call_02_481a_PlayerAction_StartCrouch, data_02_73da ; PLAYERACTION_START_CROUCH + PLAYERACTION_TOPDOWN
    dw  call_02_582e_EntityAction_None, data_02_73e6 ; PLAYERACTION_CROUCH_LOOK_DOWN + PLAYERACTION_TOPDOWN
    dw  call_02_582e_EntityAction_None, data_02_73ef ; PLAYERACTION_NONE_0 + PLAYERACTION_TOPDOWN
    dw  call_02_482e_PlayerAction_Unk7, data_02_73da ; PLAYERACTION_UNK7 + PLAYERACTION_TOPDOWN
    dw  call_02_483e_PlayerAction_EatFly, data_02_73fb ; PLAYERACTION_EAT_FLY + PLAYERACTION_TOPDOWN
    dw  call_02_484d_PlayerAction_TakeDamage, data_02_7401 ; PLAYERACTION_TAKE_DAMAGE + PLAYERACTION_TOPDOWN
    dw  call_02_4873_PlayerAction_Death, data_02_7408 ; PLAYERACTION_DEATH + PLAYERACTION_TOPDOWN
    dw  call_02_4889_PlayerAction_DeathSetUpWarp, data_02_7411 ; PLAYERACTION_DEATH_SET_UP_WARP + PLAYERACTION_TOPDOWN
    dw  call_02_48a1_PlayerAction_StandOnTVButton, data_02_7422 ; PLAYERACTION_STAND_ON_TV_BUTTON + PLAYERACTION_TOPDOWN
    dw  call_02_48b0_PlayerAction_EnterTV, data_02_7428 ; PLAYERACTION_ENTER_TV + PLAYERACTION_TOPDOWN
    dw  call_02_48bc_PlayerAction_Jump, data_02_7435 ; PLAYERACTION_JUMP + PLAYERACTION_TOPDOWN
    dw  call_02_48e8_PlayerAction_DoubleJump, data_02_7442 ; PLAYERACTION_DOUBLE_JUMP + PLAYERACTION_TOPDOWN
    dw  call_02_4911_PlayerAction_TailSpin, data_02_744e ; PLAYERACTION_TAIL_SPIN + PLAYERACTION_TOPDOWN
    dw  call_02_4957_PlayerAction_Fall, data_02_745b ; PLAYERACTION_FALL + PLAYERACTION_TOPDOWN
    dw  call_02_497a_PlayerAction_LandFromFall, data_02_746d ; PLAYERACTION_LAND_FROM_FALL + PLAYERACTION_TOPDOWN
    dw  call_02_4989_PlayerAction_Unk19, data_02_7473 ; PLAYERACTION_UNK19 + PLAYERACTION_TOPDOWN
    dw  call_02_49a8_PlayerAction_EnterIdle, data_02_7473 ; PLAYERACTION_ENTER_IDLE + PLAYERACTION_TOPDOWN
    dw  call_02_49b2_PlayerAction_None, data_02_7479 ; PLAYERACTION_NONE_1 + PLAYERACTION_TOPDOWN
    dw  call_02_49b2_PlayerAction_None, data_02_747f ; PLAYERACTION_NONE_2 + PLAYERACTION_TOPDOWN
    dw  call_02_49b2_PlayerAction_None, data_02_748f ; PLAYERACTION_NONE_3 + PLAYERACTION_TOPDOWN
    dw  call_02_49b2_PlayerAction_None, data_02_749f ; PLAYERACTION_NONE_4 + PLAYERACTION_TOPDOWN
    dw  call_02_49b3_PlayerAction_Water_Swimming, data_02_74a5 ; PLAYERACTION_WATER_SWIMMING + PLAYERACTION_TOPDOWN
    dw  call_02_4a25_PlayerAction_DeathInPitAlt, data_02_745b ; PLAYERACTION_DEATH_IN_PIT_ALT + PLAYERACTION_TOPDOWN
    dw  call_02_4a37_PlayerAction_DeathInPit, data_02_74ab ; PLAYERACTION_DEATH_IN_PIT + PLAYERACTION_TOPDOWN
    dw  call_02_4a51_PlayerAction_None2, data_02_74bd ; PLAYERACTION_NONE_5 + PLAYERACTION_TOPDOWN
    dw  call_02_4a52_PlayerAction_BlownUpwards, data_02_74c8 ; PLAYERACTION_BLOWN_UPWARDS + PLAYERACTION_TOPDOWN
    dw  call_02_4a69_PlayerAction_RidingElevator, data_02_74ce ; PLAYERACTION_RIDING_ELEVATOR + PLAYERACTION_TOPDOWN
    dw  call_02_4a6e_PlayerAction_Water_TailSpin, data_02_74d4 ; PLAYERACTION_WATER_TAIL_SPIN + PLAYERACTION_TOPDOWN
    dw  call_02_4a9b_PlayerAction_Water_Treading, data_02_74e1 ; PLAYERACTION_WATER_TREADING + PLAYERACTION_TOPDOWN
    dw  call_02_4aa1_PlayerAction_Water_Diving, data_02_74ed ; PLAYERACTION_WATER_DIVING + PLAYERACTION_TOPDOWN
    dw  call_02_4aac_PlayerAction_Climbing, data_02_74f7 ; PLAYERACTION_CLIMBING + PLAYERACTION_TOPDOWN
    dw  call_02_47b4_PlayerAction_Spawn, data_02_74fd ; PLAYERACTION_SNOWBOARDING_SPAWN + PLAYERACTION_TOPDOWN
    dw  call_02_4bb7_PlayerAction_Snowboarding_StandOrWalk, data_02_750d ; PLAYERACTION_SNOWBOARDING_STAND_OR_WALK + PLAYERACTION_TOPDOWN
    dw  call_02_4c2c_PlayerAction_Snowboarding_Jump, data_02_753b ; PLAYERACTION_SNOWBOARDING_JUMP + PLAYERACTION_TOPDOWN
    dw  call_02_4c58_PlayerAction_Snowboarding_DoubleJump, data_02_7543 ; PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP + PLAYERACTION_TOPDOWN
    dw  call_02_4c7a_PlayerAction_Snowboarding_TailSpin, data_02_754b ; PLAYERACTION_SNOWBOARDING_TAIL_SPIN + PLAYERACTION_TOPDOWN
    dw  call_02_4ca4_PlayerAction_Snowboarding_Fall, data_02_7551 ; PLAYERACTION_SNOWBOARDING_FALL + PLAYERACTION_TOPDOWN
    dw  call_02_4cbd_PlayerAction_Snowboarding_TakeDamage, data_02_7513 ; PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE + PLAYERACTION_TOPDOWN
    dw  call_02_4873_PlayerAction_Death, data_02_7519 ; PLAYERACTION_SNOWBOARDING_DIE + PLAYERACTION_TOPDOWN
    dw  call_02_4889_PlayerAction_DeathSetUpWarp, data_02_7522 ; PLAYERACTION_SNOWBOARDING_DIE_WARP + PLAYERACTION_TOPDOWN
    dw  call_02_48a1_PlayerAction_StandOnTVButton, data_02_7528 ; PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON + PLAYERACTION_TOPDOWN
    dw  call_02_48b0_PlayerAction_EnterTV, data_02_752e ; PLAYERACTION_SNOWBOARDING_ENTER_TV + PLAYERACTION_TOPDOWN
    dw  call_02_4a25_PlayerAction_DeathInPitAlt, data_02_7551 ; PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT + PLAYERACTION_TOPDOWN
    dw  call_02_47b4_PlayerAction_Spawn, data_02_7559 ; PLAYERACTION_KANGAROO_SPAWN + PLAYERACTION_TOPDOWN
    dw  call_02_4ce3_PlayerAction_Kangaroo_Idle, data_02_758e ; PLAYERACTION_KANGAROO_IDLE + PLAYERACTION_TOPDOWN
    dw  call_02_4d02_PlayerAction_Kangaroo_Hopping, data_02_7594 ; PLAYERACTION_KANGAROO_HOPPING + PLAYERACTION_TOPDOWN
    dw  call_02_4d14_PlayerAction_Kangaroo_StartJump, data_02_759f ; PLAYERACTION_KANGAROO_START_JUMP + PLAYERACTION_TOPDOWN
    dw  call_02_4d33_PlayerAction_Kangaroo_Jump, data_02_75a5 ; PLAYERACTION_KANGAROO_JUMP + PLAYERACTION_TOPDOWN
    dw  call_02_4d45_PlayerAction_Kangaroo_TailSpin, data_02_75ae ; PLAYERACTION_KANGAROO_TAIL_SPIN + PLAYERACTION_TOPDOWN
    dw  call_02_4d72_PlayerAction_Kangaroo_Fall, data_02_75bb ; PLAYERACTION_KANGAROO_FALL + PLAYERACTION_TOPDOWN
    dw  call_02_4d8b_PlayerAction_Kangaroo_TakeDamage, data_02_7569 ; PLAYERACTION_KANGAROO_TAKE_DAMAGE + PLAYERACTION_TOPDOWN
    dw  call_02_4873_PlayerAction_Death, data_02_756f ; PLAYERACTION_KANGAROO_DEATH + PLAYERACTION_TOPDOWN
    dw  call_02_4889_PlayerAction_DeathSetUpWarp, data_02_7576 ; PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP + PLAYERACTION_TOPDOWN
    dw  call_02_48a1_PlayerAction_StandOnTVButton, data_02_757c ; PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON + PLAYERACTION_TOPDOWN
    dw  call_02_48b0_PlayerAction_EnterTV, data_02_7582 ; PLAYERACTION_KANGAROO_ENTER_TV + PLAYERACTION_TOPDOWN
    dw  call_02_4a25_PlayerAction_DeathInPitAlt, data_02_75bb ; PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT + PLAYERACTION_TOPDOWN
.data_02_42c4:
    dw   call_02_582e_EntityAction_None, data_02_75c8
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_42cc:
    dw   call_02_582e_EntityAction_None, data_02_75d1
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_42d4:
    dw   call_02_582e_EntityAction_None, data_02_75dc
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_42dc:
    dw   call_02_5918_EntityAction_Fly_Update, data_02_75e9
.data_02_42e0:
    dw   call_02_582e_EntityAction_None, data_02_75ef
    dw   call_02_582e_EntityAction_None, data_02_75f5
    dw   call_02_598f_EntityAction_FlyTV_SpawnFly, data_02_75ef
    dw   call_02_59aa_EntityAction_FlyTV_Reset, data_02_760b
    dw   call_02_582e_EntityAction_None, data_02_7611
.data_02_42f4:
    dw   call_02_59ed_EntityAction_Unk_unk, data_02_7627
.data_02_42f8:
    dw   call_02_59ed_EntityAction_Unk_unk, data_02_762d
.data_02_42fc:
    dw   call_02_59ed_EntityAction_Unk_unk, data_02_7633
.data_02_4300:
    dw   call_02_5a04_EntityAction_TVButton_unk, data_02_7639
    dw   call_02_5a1c_EntityAction_TVButton_unk2, data_02_7639
    dw   call_02_5a75_EntityAction_TVButton_unk3, data_02_763f
    dw   call_02_5a83_EntityAction_TVButton_unk4, data_02_7639
.data_02_4310:
    dw   call_02_5ada_EntityAction_TVRemote_unk, data_02_7645
    dw   call_02_5ae4_EntityAction_TVRemote_unk2, data_02_764b
    dw   call_02_5aee_EntityAction_TVRemote_unk3, data_02_7658
    dw   call_02_5af8_EntityAction_TVRemote_unk4, data_02_7665
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4324:
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4328:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_7675
.data_02_432c:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_767b
.data_02_4330:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_7681
.data_02_4334:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_7687
.data_02_4338:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_768d
.data_02_433c:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_7693
.data_02_4340:
    dw   call_02_5b9a_EntityAction_UpdateGoalCounter, data_02_7699
.data_02_4344:
    dw   call_02_5bb3_EntityAction_UpdateBonusStageTimer, data_02_769f
.data_02_4348:
    dw   call_02_5bd4_EntityAction_FreestandingRemote_unk0, data_02_76a5
    dw   call_02_5bef_EntityAction_FreestandingRemote_unk1, data_02_764b
    dw   call_02_5bfa_EntityAction_FreestandingRemote_unk2, data_02_75c2
; ------------------------------------------------------------------
; HOLIDAY TV
; ------------------------------------------------------------------
.data_02_4354_EntityActions_HolidayTVIceSculpture:                ;; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
    dw   call_02_582e_EntityAction_None, data_02_76ab                               ; action $00 - intact
    dw   call_02_582e_EntityAction_None, data_02_76b1                               ; action $01 - cracked
    dw   call_02_582e_EntityAction_None, data_02_76b7                               ; action $02 - shattered
.data_02_4360_EntityActions_HolidayTVEvilSanta:                   ;; ENTITY_HOLIDAY_TV_EVIL_SANTA
    dw   call_02_5c43_EntityAction_EvilSanta_Init, data_02_76bd                     ; action $00 - set health, load the palette, fall through to $01
    dw   call_02_5c50_EntityAction_EvilSanta_Jumping, data_02_76c3                  ; action $01 - hop across, turn round on landing
    dw   call_02_5c74_EntityAction_EvilSanta_PrepareThrow, data_02_76ca             ; action $02 - wind up and throw the snowball
    dw   call_02_582e_EntityAction_None, data_02_76d9                               ; action $03 - the throw pose - chains to $04
    dw   call_02_5c82_EntityAction_EvilSanta_Stand, data_02_76df                    ; action $04 - wait: take a hit, or jump again once the snowball is gone
    dw   call_02_5ca5_EntityAction_EvilSanta_Damaged, data_02_76e5                  ; action $05 - flash - chains back to $01
    dw   call_02_5cd0_EntityAction_EvilSanta_Death, data_02_76f2                    ; action $06 - launch backwards and expire
.data_02_437c_EntityActions_HolidayTVEvilSantaProjectile:         ;; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    dw   call_02_5d10_EntityAction_EvilSantaProjectile_Init, data_02_7701           ; action $00 - aim the throw from the distance to Gex
    dw   call_02_5d80_EntityAction_EvilSantaProjectile_UpdateTrajectory, data_02_7701; action $01 - the arc, sprite 1
    dw   call_02_5d80_EntityAction_EvilSantaProjectile_UpdateTrajectory, data_02_7707; action $02 - the arc, sprite 2
    dw   call_02_5d80_EntityAction_EvilSantaProjectile_UpdateTrajectory, data_02_770d; action $03 - the arc, sprite 3
    dw   call_02_5d80_EntityAction_EvilSantaProjectile_UpdateTrajectory, data_02_7713; action $04 - the arc, sprite 4
    dw   call_02_5dd7_EntityAction_EvilSantaProjectile_Destroy, data_02_7719        ; action $05 - burst - returned into Santa
    dw   call_02_5dd7_EntityAction_EvilSantaProjectile_Destroy, data_02_7721        ; action $06 - burst - hit Gex
.data_02_4398_EntityActions_HolidayTVSkatingElf:                  ;; ENTITY_HOLIDAY_TV_SKATING_ELF
    dw   call_02_5dde_EntityAction_SkatingElf_Skate, data_02_7729                   ; action $00 - skate, first half of the loop - chains to $01
    dw   call_02_5dde_EntityAction_SkatingElf_Skate, data_02_7738                   ; action $01 - skate, second half - chains back to $00
    dw   call_02_5e0d_EntityAction_SkatingElf_PrepareJump, data_02_7747             ; action $02 - accelerate to $28 and arm the jump
    dw   call_02_5e25_EntityAction_SkatingElf_Jump, data_02_7756                    ; action $03 - the jump
    dw   call_02_5e34_EntityAction_SkatingElf_Damaged, data_02_775c                 ; action $04 - hit: skid to the end of the patrol, then live or die
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $05 - defeated
.data_02_43b0_EntityActions_HolidayTVPenguin:                     ;; ENTITY_HOLIDAY_TV_PENGUIN
    dw   call_02_5e7c_EntityAction_Penguin_WalkOrRun, data_02_7763                  ; action $00 - amble, or run away and jump when cornered
    dw   call_02_5eb8_EntityAction_Penguin_Jump, data_02_776e                       ; action $01 - the jump
    dw   call_02_582e_EntityAction_None, data_02_7774                               ; action $02 - unreachable - defeat flags $C3 select $03 instead
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $03 - defeated

; ------------------------------------------------------------------
; MYSTERY TV
; ------------------------------------------------------------------
.data_02_43c0_EntityActions_MysteryTVRezling:                     ;; ENTITY_MYSTERY_TV_REZLING
    dw   call_02_5ecc_EntityAction_Rezling_Walk, data_02_777b                       ; action $00 - walk straight at Gex
    dw   call_02_5eda_EntityAction_Rezling_None, data_02_7788                       ; action $01 - unused hit reaction - chains to $02
    dw   call_02_5edb_EntityAction_Rezling_None, data_02_7790                       ; action $02 - unused hit reaction
    dw   call_02_5edc_EntityAction_Rezling_None, data_02_7796                       ; action $03 - death, from defeat flags $C3 - chains to $04
    dw   call_02_582e_EntityAction_None, data_02_779c                               ; action $04 - death burst - chains to $05
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $05 - defeated
.data_02_43d8_EntityActions_MysteryTVBloodCooler:                 ;; ENTITY_MYSTERY_TV_BLOOD_COOLER
    dw   call_02_582e_EntityAction_None, data_02_77ad                               ; action $00 - intact
    dw   call_02_582e_EntityAction_None, data_02_77b6                               ; action $01 - broken
.data_02_43e0_EntityActions_MysteryTVFish:                        ;; ENTITY_MYSTERY_TV_FISH
    dw   call_02_5edd_EntityAction_Fish_Cruise, data_02_77bc                        ; action $00 - cruise at $08
    dw   call_02_5ef9_EntityAction_Fish_Lunge, data_02_77c5                         ; action $01 - lunge at $20 - chains back to $00
.data_02_43e8_EntityActions_MysteryTVMagicSword:                  ;; ENTITY_MYSTERY_TV_MAGIC_SWORD
    dw   call_02_582e_EntityAction_None, data_02_77cb                               ; action $00 - shimmer - chains to $01
    dw   call_02_582e_EntityAction_None, data_02_77d8                               ; action $01 - still, 120 frames - chains back to $00
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $02 - taken
.data_02_43f4_EntityActions_MysteryTVSafariSam:                   ;; ENTITY_MYSTERY_TV_SAFARI_SAM
    dw   call_02_5f01_EntityAction_SafariSam_Patrol, data_02_77de                   ; action $00 - patrol and count down to a shot
    dw   call_02_582e_EntityAction_None, data_02_77f0                               ; action $01 - raise the rifle - chains to $02
    dw   call_02_5f39_EntityAction_SafariSam_Fire, data_02_77fb                     ; action $02 - fire, then the recoil chains back to $00
    dw   call_02_5f42_EntityAction_SafariSam_Death, data_02_7806                    ; action $03 - death hop - chains to $04
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $04 - defeated
.data_02_4408_EntityActions_MysteryTVSafariSamProjectile:         ;; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    dw   call_02_5f50_EntityAction_SafariSamProjectile_Update, data_02_780c
.data_02_440c_EntityActions_MysteryTVGhostKnight:                 ;; ENTITY_MYSTERY_TV_GHOST_KNIGHT
    dw   call_02_5f69_EntityAction_GhostKnight_Init, data_02_7812                   ; action $00 - place at post 0
    dw   call_02_5f78_EntityAction_GhostKnight_Attack, data_02_7818                 ; action $01 - fire a shot every 16 frames
    dw   call_02_582e_EntityAction_None, data_02_7821                               ; action $02 - vanish - chains to $03
    dw   call_02_5f91_EntityAction_GhostKnight_Relocate, data_02_782a               ; action $03 - step to the next post - chains to $04
    dw   call_02_582e_EntityAction_None, data_02_7830                               ; action $04 - reappear - chains back to $01
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $05 - defeated
.data_02_4424_EntityActions_MysteryTVGhostKnightProjectile:       ;; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
    dw   call_02_60c7_EntityAction_GhostKnightProjectile_Update, data_02_7838

; ------------------------------------------------------------------
; TUT TV
; ------------------------------------------------------------------
.data_02_4428_EntityActions_TutTVHand:                            ;; ENTITY_TUT_TV_HAND
    dw   call_02_613f_EntityAction_Hand_Crawl, data_02_783e                         ; action $00 - crawl to the end of the patrol
    dw   call_02_614d_EntityAction_Hand_Rise, data_02_7849                          ; action $01 - rise
    dw   call_02_6163_EntityAction_Hand_Fall, data_02_7852                          ; action $02 - fall
    dw   call_02_616f_EntityAction_Hand_Slam, data_02_785b                          ; action $03 - slam - may break a block
    dw   call_02_582e_EntityAction_None, data_02_7861                               ; action $04 - rest - chains back to $00
    dw   call_02_61b2_EntityAction_Hand_Settle, data_02_7867                        ; action $05 - unreachable
.data_02_4440_EntityActions_TutTVLostArk:                         ;; ENTITY_TUT_TV_LOST_ARK
    dw   call_02_582e_EntityAction_None, data_02_7874                               ; action $00 - closed
    dw   call_02_582e_EntityAction_None, data_02_787a                               ; action $01 - opening - chains to $02
    dw   call_02_61b8_EntityAction_LostArk_Flash, data_02_7883                      ; action $02 - the flash - chains to $03
    dw   call_02_582e_EntityAction_None, data_02_7889                               ; action $03 - the burst - chains to $04
    dw   call_02_582e_EntityAction_None, data_02_7895                               ; action $04 - emptied
.data_02_4454_EntityActions_TutTVRisingPlatform:                  ;; ENTITY_TUT_TV_RISING_PLATFORM
    dw   call_02_58bd_EntityAction_MovePlatformVertically, data_02_789b
.data_02_4458_EntityActions_TutTVSidewaysPlatform:                ;; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
    dw   call_02_585f_EntityAction_MovePlatformHorizontally, data_02_789b
.data_02_445c_EntityActions_TutTVBee:                             ;; ENTITY_TUT_TV_BEE
    dw   call_02_61c6_EntityAction_Bee_Hover, data_02_78a1                          ; action $00 - hover and watch for Gex
    dw   call_02_61ee_EntityAction_Bee_Dive, data_02_78a8                           ; action $01 - dive, climbing
    dw   call_02_61ee_EntityAction_Bee_Dive, data_02_78ae                           ; action $02 - dive, at the top of the arc
    dw   call_02_61ee_EntityAction_Bee_Dive, data_02_78b4                           ; action $03 - dive, coming down
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $04 - defeated
.data_02_4470_EntityActions_TutTVRaft:                            ;; ENTITY_TUT_TV_RAFT
    dw   call_02_6214_EntityAction_Raft_ResetAndWait, data_02_78ba                  ; action $00 - reset and surface
    dw   call_02_624e_EntityAction_Raft_MoveRightAndCarryPlayer, data_02_78ba       ; action $01 - ferry Gex right
    dw   call_02_6293_EntityAction_Raft_DriftDown, data_02_78ba                     ; action $02 - sink, then back to $00
.data_02_447c_EntityActions_TutTVSnake:                           ;; ENTITY_TUT_TV_SNAKE_FACING_RIGHT / _LEFT
    dw   call_02_62bc_EntityAction_Snake_Coiled, data_02_78c0                       ; action $00 - coiled
    dw   call_02_62f9_EntityAction_Snake_Strike, data_02_78c6                       ; action $01 - strike and spit
    dw   call_02_6315_EntityAction_Snake_Recoil, data_02_78ce                       ; action $02 - recoil - chains back to $00
    dw   call_02_582e_EntityAction_None, data_02_78db                               ; action $03 - death, from defeat flags $C3 - chains to $04
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $04 - defeated
.data_02_4490_EntityActions_TutTVSnakeRightProjectile:            ;; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    dw   call_02_631a_EntityAction_SnakeRightProjectile_Update, data_02_78e1
.data_02_4494_EntityActions_TutTVSnakeLeftProjectile:             ;; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
    dw   call_02_6333_EntityAction_SnakeLeftProjectile_Update, data_02_78e1
.data_02_4498_EntityActions_TutTVRaStaff:                         ;; ENTITY_TUT_TV_RA_STAFF
    dw   call_02_582e_EntityAction_None, data_02_78e7                               ; action $00 - idle
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2                            ; action $01 - taken
.data_02_44a0_EntityActions_TutTVRaStatueProjectile:              ;; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE / _DIAGONAL_
    dw   call_02_634c_EntityAction_RaStatue_Reset, data_02_78f4                     ; action $00 - re-park at the statue
    dw   call_02_6361_EntityAction_RaStatue_WaitForPlayer, data_02_78fa             ; action $01 - wait for Gex in the hotspot
    dw   call_02_582e_EntityAction_None, data_02_7913                               ; action $02 - launch - chains to $03
    dw   call_02_6399_EntityAction_RaStatue_Fly, data_02_7926                       ; action $03 - fly until the timer runs out, then back to $00
.data_02_44b0_EntityActions_TutTVBreakableBlock:                  ;; ENTITY_TUT_TV_BREAKABLE_BLOCK
    dw   call_02_63a8_EntityAction_BreakableBlock_TakeHit, data_02_792d             ; action $00 - undamaged
    dw   call_02_63a8_EntityAction_BreakableBlock_TakeHit, data_02_7933             ; action $01 - one slam taken
    dw   call_02_63a8_EntityAction_BreakableBlock_TakeHit, data_02_7939             ; action $02 - two slams taken
    dw   call_02_63c0_EntityAction_BreakableBlock_Shatter, data_02_793f             ; action $03 - shatter
.data_02_44c0_EntityActions_TutTVCoffin:                          ;; ENTITY_TUT_TV_COFFIN
    dw   call_02_582e_EntityAction_None, data_02_7945                               ; action $00 - closed
    dw   call_02_582e_EntityAction_None, data_02_794b                               ; action $01 - opening - chains to $02
    dw   call_02_63d3_EntityAction_Coffin_Opened, data_02_7952                      ; action $02 - open: raise the trigger
.data_02_44cc:
    dw   call_02_63db_EntityAction_EnemyCactus_Unk0, data_02_7958
    dw   call_02_63f0_EntityAction_EnemyCactus_Unk1, data_02_7961
    dw   call_02_582e_EntityAction_None, data_02_796a
    dw   call_02_582e_EntityAction_None, data_02_7971
    dw   call_02_6415_EntityAction_EnemyCactus_Unk4, data_02_7979
    dw   call_02_582e_EntityAction_None, data_02_7980
    dw   call_02_582f_EntityAction_DestroyWithoutParticles, data_02_7986
.data_02_44e8:
    dw   call_02_582e_EntityAction_None, data_02_798c
.data_02_44ec:
    dw   call_02_642e_EntityAction_Rock_Unk0, data_02_7992
    dw   call_02_6459_EntityAction_Rock_Unk1, data_02_7998
    dw   call_02_646f_EntityAction_Rock_Unk2, data_02_79a5
    dw   call_02_647b_EntityAction_Rock_Unk3, data_02_79ab
.data_02_44fc:
    dw   call_02_6491_EntityAction_HardHat_Walk, data_02_79b8
    dw   call_02_64cd_EntityAction_HardHat_Jump, data_02_79c3
    dw   call_02_582e_EntityAction_None, data_02_79c9
    dw   call_02_582e_EntityAction_None, data_02_79de
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4510:
    dw   call_02_582e_EntityAction_None, data_02_79e4
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4518:
    dw   call_02_64e9_EntityAction_Bat_Unk0, data_02_79f3
    dw   call_02_582e_EntityAction_None, data_02_79f9
    dw   call_02_6502_EntityAction_Bat_Unk2, data_02_7a06
    dw   call_02_652e_EntityAction_Bat_Unk3, data_02_7a0c
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_452c:
    dw   call_02_58bd_EntityAction_MovePlatformVertically, data_02_7a12
.data_02_4530:
    dw   call_02_582e_EntityAction_None, data_02_7a18
    dw   call_02_653d_EntityAction_Door1_Unk1, data_02_7a1e
    dw   call_02_6549_EntityAction_Door1_Unk2, data_02_7a26
    dw   call_02_582e_EntityAction_None, data_02_7a2c
.data_02_4540:
    dw   call_02_6553_EntityAction_Door2_Unk0, data_02_7a34
    dw   call_02_582e_EntityAction_None, data_02_7a3a
    dw   call_02_582e_EntityAction_None, data_02_7a42
    dw   call_02_655d_EntityAction_Door2_Unk3, data_02_7a48
.data_02_4550:
    dw   call_02_6569_EntityAction_FanLift_Unk0, data_02_7a50
    dw   call_02_582e_EntityAction_None, data_02_7a56
    dw   call_02_6577_EntityAction_FanLift_Unk2, data_02_7a61
    dw   call_02_582e_EntityAction_None, data_02_7a7a
.data_02_4560:
    dw   call_02_659c_EntityAction_MechRight_Unk0, data_02_7a85
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4568:
    dw   call_02_6597_EntityAction_MechLeft_Unk0, data_02_7a85
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4570:
    dw   call_02_659d_EntityAction_AnimeDisappearingFloor_Unk0, data_02_7a91
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4578:
    dw   call_02_582e_EntityAction_None, data_02_7a97
    dw   call_02_65b3_EntityAction_Onswitch2_Unk1, data_02_7a9d
.data_02_4580:
    dw   call_02_582e_EntityAction_None, data_02_7aa3
    dw   call_02_582e_EntityAction_None, data_02_7aac
    dw   call_02_582e_EntityAction_None, data_02_7ab3
.data_02_458c:
    dw   call_02_65c9_EntityAction_BlueBeamBarrier_Unk0, data_02_7ab9
    dw   call_02_582e_EntityAction_None, data_02_7ac2
.data_02_4594:
    dw   call_02_65d7_EntityAction_AnimeRisingPlatform_Update, data_02_7ac8
.data_02_4598:
    dw   call_02_659d_EntityAction_OnSwitch_Unk0, data_02_7ace
    dw   call_02_6617_EntityAction_OnSwitch_Unk1, data_02_7ad4
.data_02_45a0:
    dw   call_02_6617_EntityAction_OffSwitch_Unk0, data_02_7ada
    dw   call_02_6633_EntityAction_OffSwitch_Unk1, data_02_7ae0
.data_02_45a8:
    dw   call_02_6641_EntityAction_SailorToonGirl_Unk0, data_02_7ae6
    dw   call_02_582e_EntityAction_None, data_02_7aef
    dw   call_02_6687_EntityAction_SailorToonGirl_Unk2, data_02_7afb
    dw   call_02_668d_EntityAction_SailorToonGirl_Unk3, data_02_7b07
    dw   call_02_582e_EntityAction_None, data_02_7b0d
    dw   call_02_669d_EntityAction_SailorToonGirl_Unk5, data_02_7b14
    dw   call_02_582e_EntityAction_None, data_02_7b1c
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_45c8:
    dw   call_02_66bb_EntityAction_BigSilverRobot_Unk0, data_02_7b22
    dw   call_02_66cc_EntityAction_BigSilverRobot_Unk1, data_02_7b28
    dw   call_02_66e0_EntityAction_BigSilverRobot_Unk2, data_02_7b33
    dw   call_02_66ef_EntityAction_BigSilverRobot_Unk3, data_02_7b5a
.data_02_45d8:
    dw   call_02_66f6_EntityAction_SmallBlueRobot_Unk0, data_02_7b6a
    dw   call_02_6732_EntityAction_SmallBlueRobot_Unk1, data_02_7b77
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_45e4:
    dw   call_02_6746_EntityAction_Secbot_Unk0, data_02_7b80
    dw   call_02_6768_EntityAction_Secbot_Unk1, data_02_7b89
    dw   call_02_582e_EntityAction_None, data_02_7b8f
    dw   call_02_582e_EntityAction_None, data_02_7b98
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_45f8:
    dw   call_02_679b_EntityAction_SecbotProjectile_Update, data_02_7ba1
.data_02_45fc:
    dw   call_02_67c2_EntityAction_Elevator_Update, data_02_7ba7
.data_02_4600:
    dw   call_02_68af_EntityAction_FireWallEnemy_Update, data_02_7bad
.data_02_4604:
    dw   call_02_68b2_EntityAction_Grenade_Unk0, data_02_7bb8
    dw   call_02_68ed_EntityAction_Grenade_Unk1, data_02_7bbe
    dw   call_02_6928_EntityAction_Grenade_Unk2, data_02_7bcd
.data_02_4610:
    dw   call_02_582e_EntityAction_None, data_02_7bd8
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4618:
    dw   call_02_6947_EntityAction_MadBomber_Unk0, data_02_7be3
    dw   call_02_6947_EntityAction_MadBomber_Unk0, data_02_7bf8
    dw   call_02_693f_EntityAction_MadBomber_Unk2, data_02_7c02
    dw   call_02_6947_EntityAction_MadBomber_Unk0, data_02_7c0b
    dw   call_02_582e_EntityAction_None, data_02_7c13
    dw   call_02_6965_EntityAction_MadBomber_Unk5, data_02_7c19
.data_02_4630:
    dw   call_02_6971_EntityAction_Bomb_Unk0, data_02_7c1f
    dw   call_02_69af_EntityAction_Bomb_Unk1, data_02_7c1f
    dw   call_02_6a04_EntityAction_Bomb_Unk2, data_02_7c1f
    dw   call_02_6a13_EntityAction_Bomb_Unk3, data_02_7c1f
    dw   call_02_6a4c_EntityAction_Bomb_Unk4, data_02_7c27
.data_02_4644:
    dw   call_02_6a91_EntityAction_WaterTowerTank_Unk0, data_02_7c32
    dw   call_02_6ab4_EntityAction_WaterTowerTank_Unk1, data_02_7c32
    dw   call_02_582e_EntityAction_None, data_02_7c32
.data_02_4650:
    dw   call_02_582e_EntityAction_None, data_02_7c38
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4658:
    dw   call_02_6acd_EntityAction_Convict_Unk0, data_02_7c3e
    dw   call_02_582e_EntityAction_None, data_02_7c51
    dw   call_02_6ad4_EntityAction_Convict_Unk2, data_02_7c5e
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4668:
    dw   call_02_6b03_EntityAction_Spider_Unk0, data_02_7c6a
    dw   call_02_6b20_EntityAction_Spider_Unk1, data_02_7c6a
    dw   call_02_6b35_EntityAction_Spider_Unk2, data_02_7c6a
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4678:
    dw   call_02_6b53_EntityAction_StrayCat_Unk0, data_02_7c72
    dw   call_02_582e_EntityAction_None, data_02_7c79
    dw   call_02_582e_EntityAction_None, data_02_7c7f
    dw   call_02_582e_EntityAction_None, data_02_7c8b
    dw   call_02_582e_EntityAction_None, data_02_7c92
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4690:
    dw   call_02_6b69_EntityAction_YellowGoon_Unk0, data_02_7ca1
    dw   call_02_582e_EntityAction_None, data_02_7caa
    dw   call_02_582e_EntityAction_None, data_02_7cb4
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_46a0:
    dw   call_02_6b9b_EntityAction_Rat_Unk0, data_02_7cc4
    dw   call_02_582e_EntityAction_None, data_02_7ccd
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_46ac:
    dw   call_02_6ba3_EntityAction_ChomperTV_Unk0, data_02_7cd6
    dw   call_02_6be4_EntityAction_ChomperTV_Unk1, data_02_7cd6
    dw   call_02_6bc8_EntityAction_ChomperTV_Unk2, data_02_7cdf
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_46bc:
    dw   call_02_6bfb_EntityAction_CrumblingFloor_Unk0, data_02_7ce6
    dw   call_02_582e_EntityAction_None, data_02_7cec
    dw   call_02_6c08_EntityAction_CrumblingFloor_Unk2, data_02_7cf3
.data_02_46c8:
    dw   call_02_6add_EntityAction_ConvictProjectile_Update, data_02_7cf9
.data_02_46cc:
    dw   call_02_6c1d_EntityAction_GextremeSportsElf_Unk0, data_02_7d08
    dw   call_02_6c1d_EntityAction_GextremeSportsElf_Unk0, data_02_7d17
    dw   call_02_6c4c_EntityAction_GextremeSportsElf_Unk2, data_02_7d26
    dw   call_02_6c64_EntityAction_GextremeSportsElf_Unk3, data_02_7d35
    dw   call_02_6c73_EntityAction_GextremeSportsElf_Unk4, data_02_7d3b
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_46e4:
    dw   call_02_582e_EntityAction_None, data_02_7d42
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_46ec:
    dw   call_02_582e_EntityAction_None, data_02_7d4f
    dw   call_02_582e_EntityAction_None, data_02_7d55
    dw   call_02_582e_EntityAction_None, data_02_7d4f
.data_02_46f8:
    dw   call_02_6cbb_EntityAction_Bird_Update, data_02_7d65
.data_02_46fc:
    dw   call_02_6cdd_EntityAction_BirdProjectile_Update, data_02_7d73
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_4704:
    dw   call_02_6d3a_EntityAction_RockHard_Unk0, data_02_7d9a
    dw   call_02_6d39_EntityAction_RockHard_Unk1, data_02_7d7c
    dw   call_02_6d3b_EntityAction_RockHard_Unk2, data_02_7da3
    dw   call_02_582e_EntityAction_None, data_02_7db1
    dw   call_02_582e_EntityAction_None, data_02_7db7
    dw   call_02_6d49_EntityAction_RockHard_Unk5, data_02_7dc3
    dw   call_02_6d52_EntityAction_RockHard_Unk6, data_02_7dcd
.data_02_4720:
    dw   call_02_6d6d_EntityAction_BrainOfOz_Unk0, data_02_7dd5
    dw   call_02_6d6d_EntityAction_BrainOfOz_Unk0, data_02_7ddb
    dw   call_02_6d85_EntityAction_BrainOfOz_Unk2, data_02_7de1
    dw   call_02_6dba_EntityAction_BrainOfOz_Unk3, data_02_7deb
    dw   call_02_6dda_EntityAction_BrainOfOz_Unk4, data_02_7df9
    dw   call_02_6ddd_EntityAction_BrainOfOz_Unk5, data_02_7e00
    dw   call_02_582e_EntityAction_None, data_02_7e09
    dw   call_02_6dee_EntityAction_BrainOfOz_Unk7, data_02_7e0f
    dw   call_02_6e09_EntityAction_BrainOfOz_Unk8, data_02_75c2
.data_02_4744:
    dw   call_02_6ec7_EntityAction_CannonProjectile_Update, data_02_7e15
.data_02_4748:
    dw   call_02_6e88_EntityAction_Cannon_Unk0, data_02_7e1b
    dw   call_02_582e_EntityAction_None, data_02_7e21
    dw   call_02_6ea8_EntityAction_Cannon_Unk2, data_02_7e34
    dw   call_02_6eb9_EntityAction_Cannon_Unk3, data_02_7e3a
    dw   call_02_582e_EntityAction_None, data_02_7e40
.data_02_475c:
    dw   call_02_6e44_EntityAction_BrainOfOzProjectile_Update, data_02_7e53
.data_02_4760:
    dw   call_02_6f07_EntityAction_CannonProjectile2_Update, data_02_7e5e
.data_02_4764:
    dw   call_02_6f0e_EntityAction_Unk_None, data_02_7e67
.data_02_4768:
    dw   call_02_6f0e_EntityAction_Unk_None, data_02_7e6d
.data_02_476c:
    dw   call_02_6f0f_EntityAction_Rez_Unk0, data_02_7e73
    dw   call_02_6f0f_EntityAction_Rez_Unk0, data_02_7e79
    dw   call_02_6f29_EntityAction_Rez_Unk2, data_02_7e7f
    dw   call_02_6f35_EntityAction_Rez_Unk3, data_02_7e8a
    dw   call_02_582e_EntityAction_None, data_02_7e95
    dw   call_02_6f3e_EntityAction_Rez_Unk5, data_02_7e9b
    dw   call_02_6f54_EntityAction_Rez_Unk6, data_02_7ea4
    dw   call_02_6f54_EntityAction_Rez_Unk6, data_02_7eaa
    dw   call_02_6f64_EntityAction_Rez_Unk8, data_02_7eb0
    dw   call_02_6f9e_EntityAction_Rez_Unk9, data_02_7eb6
    dw   call_02_6fa1_EntityAction_Rez_Unk10, data_02_7ec2
    dw   call_02_6faa_EntityAction_Rez_Unk11, data_02_7ecb
.data_02_479c:
    dw   call_02_7019_EntityAction_Unk_None, data_02_7ed1
.data_02_47a0:
    dw   call_02_582e_EntityAction_None, data_02_7eda
    dw   call_02_701a_EntityAction_Meteor_Update, data_02_7ee0
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
.data_02_47ac:
    dw   call_02_702e_EntityAction_RezProjectile_Update, data_02_7bad
    dw   call_02_583c_EntityAction_Destroy, data_02_75c2
