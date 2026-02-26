; MBC1
DEF MBC1SRamEnable      EQU $0001
DEF MBC1RomBank         EQU $2001
DEF MBC1SRamBank        EQU $4001
DEF MBC1SRamBankingMode EQU $6001

; ROM Banks
DEF BANK_00_HOME_CODE         EQU $00
DEF BANK_01_MENU_CODE         EQU $01
DEF BANK_02_ENTITY_CODE       EQU $02
DEF BANK_03_COLLISION_AND_GRAPHICS_CODE EQU $03
DEF BANK_04_AUDIO_CODE_1      EQU $04
DEF BANK_05_AUDIO_CODE_2      EQU $05
DEF Bank06                    EQU $06
DEF Bank07                    EQU $07
DEF Bank08                    EQU $08
DEF Bank09                    EQU $09
DEF BANK_0A_ENTITY_SPRITES    EQU $0a
DEF Bank0b                    EQU $0b
DEF Bank0c                    EQU $0c
DEF Bank0d                    EQU $0d
DEF Bank0e                    EQU $0e
DEF Bank0f                    EQU $0f
DEF Bank10                    EQU $10
DEF Bank11                    EQU $11
DEF BANK_1C_TEXT              EQU $1c
DEF Bank1d                    EQU $1d
DEF Bank1e                    EQU $1e
DEF BANK_1F_SECONDARY_TILESETS EQU $1f
DEF Bank20                    EQU $20 ; unused
DEF Bank21_BgPalettesAndCollectibleLists EQU $21 ; bg palette data, and collectible lists for each map
DEF Bank22_EntitySpawnLists   EQU $22 ; entity spawn lists for each map
DEF Bank23_CollisionBlocksets EQU $23
DEF Bank24_BlocksetData       EQU $24
DEF Bank25_BlocksetData       EQU $25
DEF Bank26_BlocksetData       EQU $26
DEF Bank27_BlocksetData       EQU $27
DEF Bank28_BlocksetData       EQU $28
DEF Bank2e_ExtendedMapData    EQU $2e
DEF Bank2f_MapData            EQU $2f ; WesternStation, ChannelZ
DEF Bank30_MapCollision       EQU $30
DEF Bank31_ExtendedMapData    EQU $31
DEF Bank32_MapData            EQU $32 ; MysteryTV, HolidayTV, TutTV, GextremeSports
DEF Bank33_MapCollision       EQU $33
DEF Bank34_ExtendedMapData    EQU $34
DEF Bank35_MapData            EQU $35 ; HolidayTV, MarsupialMadness, WWGexWrestling
DEF Bank36_MapCollision       EQU $36
DEF Bank37_ExtendedMapData    EQU $37
DEF Bank38_MapData            EQU $38 ; AnimeChannel, LizardOfOz
DEF Bank39_MapCollision       EQU $39
DEF Bank3a_ExtendedMapData    EQU $3a
DEF Bank3b_MapData            EQU $3b ; SuperheroShow, GextremeSports
DEF Bank3c_MapCollision       EQU $3c
DEF Bank3d_ExtendedMapData    EQU $3d
DEF Bank3e_MapData            EQU $3e ; GexCave, SuperheroShow
DEF Bank3f_MapCollision       EQU $3f
DEF Bank40_Tileset            EQU $40 ; AnimeChannel, MarsupialMadness
DEF Bank41_Tileset            EQU $41 ; WesternStation, AnimeChannel, LizardOfOz
DEF Bank42_Tileset            EQU $42 ; WesternStation
DEF Bank43_Tileset            EQU $43 ; HolidayTV, GextremeSports
DEF Bank44_Tileset            EQU $44 ; MysteryTV
DEF Bank45_Tileset            EQU $45 ; HolidayTV, MysteryTV
DEF Bank46_Tileset            EQU $46 ; TutTV
DEF Bank47_Tileset            EQU $47 ; TutTV, SuperheroShow
DEF Bank48_Tileset            EQU $48 ; AnimeChannel
DEF Bank49_Tileset            EQU $49 ; SuperheroShow
DEF Bank4a_Tileset            EQU $4a ; TutTV, SuperheroShow
DEF Bank4b_Tileset            EQU $4b ; WesternStation
DEF Bank4c_Tileset            EQU $4c ; ChannelZ
DEF Bank4d_Tileset            EQU $4d ; GexCave, AnimeChannel, GextremeSports
DEF Bank4e_Tileset            EQU $4e ; GexCave
DEF Bank4f_Tileset            EQU $4f ; WesternStation, WWGexWrestling, ChannelZ

DEF BANK_7F_ENTITY_PALETTES   EQU $7f ; entity sprite and palette data

; Inputs (defined in hardware.inc)
; DEF PADF_DOWN   EQU $80
; DEF PADF_UP     EQU $40
; DEF PADF_LEFT   EQU $20
; DEF PADF_RIGHT  EQU $10
; DEF PADF_START  EQU $08
; DEF PADF_SELECT EQU $04
; DEF PADF_B      EQU $02
; DEF PADF_A      EQU $01

; Levels
DEF LEVEL_GEX_CAVE                   EQU $00
DEF LEVEL_HOLIDAY_TV                 EQU $01
DEF LEVEL_MYSTERY_TV                 EQU $02
DEF LEVEL_TUT_TV                     EQU $03
DEF LEVEL_WESTERN_STATION            EQU $04
DEF LEVEL_ANIME_CHANNEL              EQU $05
DEF LEVEL_SUPERHERO_SHOW             EQU $06
DEF LEVEL_GEXTREME_SPORTS            EQU $07 ; if you touch a tv button with this level id, you go to credits
DEF LEVEL_MARSUPIAL_MADNESS          EQU $08
DEF LEVEL_WW_GEX_WRESTLING           EQU $09
DEF LEVEL_LIZARD_OF_OZ               EQU $0A
DEF LEVEL_CHANNEL_Z                  EQU $0B ; if you touch a tv button with this level id, you go to credits

; Maps
DEF MAP_GEX_CAVE1                  EQU $00
DEF MAP_HOLIDAY_TV1                EQU $01
DEF MAP_MYSTERY_TV1                EQU $02
DEF MAP_TUT_TV1                    EQU $03
DEF MAP_WESTERN_STATION1           EQU $04
DEF MAP_ANIME_CHANNEL1             EQU $05
DEF MAP_SUPERHERO_SHOW1            EQU $06
DEF MAP_GEXTREME_SPORTS1           EQU $07
DEF MAP_MARSUPIAL_MADNESS1         EQU $08
DEF MAP_WW_GEX_WRESTLING1          EQU $09
DEF MAP_LIZARD_OF_OZ1              EQU $0A
DEF MAP_CHANNEL_Z1                 EQU $0B
DEF MAP_GEX_CAVE2                  EQU $0C
DEF MAP_GEX_CAVE3                  EQU $0D
DEF MAP_GEX_CAVE4                  EQU $0E
DEF MAP_HOLIDAY_TV2                EQU $0F
DEF MAP_HOLIDAY_TV3                EQU $10
DEF MAP_HOLIDAY_TV4                EQU $11
DEF MAP_MYSTERY_TV2                EQU $12
DEF MAP_MYSTERY_TV3                EQU $13
DEF MAP_MYSTERY_TV4                EQU $14
DEF MAP_MYSTERY_TV5                EQU $15
DEF MAP_MYSTERY_TV6                EQU $16
DEF MAP_MYSTERY_TV7                EQU $17
DEF MAP_MYSTERY_TV8                EQU $18
DEF MAP_MYSTERY_TV9                EQU $19
DEF MAP_MYSTERY_TV10               EQU $1A
DEF MAP_TUT_TV2                    EQU $1B
DEF MAP_TUT_TV3                    EQU $1C
DEF MAP_TUT_TV4                    EQU $1D
DEF MAP_TUT_TV5                    EQU $1E
DEF MAP_TUT_TV6                    EQU $1F
DEF MAP_TUT_TV7                    EQU $20
DEF MAP_WESTERN_STATION2           EQU $21
DEF MAP_WESTERN_STATION3           EQU $22
DEF MAP_WESTERN_STATION4           EQU $23
DEF MAP_WESTERN_STATION5           EQU $24
DEF MAP_WESTERN_STATION6           EQU $25
DEF MAP_WESTERN_STATION7           EQU $26
DEF MAP_WESTERN_STATION8           EQU $27
DEF MAP_WESTERN_STATION9           EQU $28
DEF MAP_ANIME_CHANNEL2             EQU $29
DEF MAP_ANIME_CHANNEL3             EQU $2A
DEF MAP_ANIME_CHANNEL4             EQU $2B
DEF MAP_ANIME_CHANNEL5             EQU $2C
DEF MAP_ANIME_CHANNEL6             EQU $2D
DEF MAP_ANIME_CHANNEL7             EQU $2E
DEF MAP_ANIME_CHANNEL8             EQU $2F
DEF MAP_ANIME_CHANNEL9             EQU $30
DEF MAP_SUPERHERO_SHOW2            EQU $31
DEF MAP_SUPERHERO_SHOW3            EQU $32
DEF MAP_SUPERHERO_SHOW4            EQU $33
DEF MAP_SUPERHERO_SHOW5            EQU $34
DEF MAP_SUPERHERO_SHOW6            EQU $35
DEF MAP_GEXTREME_SPORTS2           EQU $36
DEF MAP_GEXTREME_SPORTS3           EQU $37
DEF MAP_GEXTREME_SPORTS4           EQU $38
DEF MAP_CHANNEL_Z2                 EQU $39
DEF MAP_CHANNEL_Z3                 EQU $3A
DEF MAP_CHANNEL_Z4                 EQU $3B
DEF MAP_CHANNEL_Z5                 EQU $3C

; Entities
DEF ENTITY_GEX                                         EQU $00
DEF ENTITY_BONUS_COIN                                  EQU $01
DEF ENTITY_FLY_COIN_SPAWN                              EQU $02
DEF ENTITY_PAW_COIN                                    EQU $03
DEF ENTITY_FLY_1                                       EQU $04
DEF ENTITY_FLY_2                                       EQU $05
DEF ENTITY_FLY_3                                       EQU $06
DEF ENTITY_FLY_4                                       EQU $07
DEF ENTITY_FLY_5                                       EQU $08
DEF ENTITY_GREEN_FLY_TV                                EQU $09
DEF ENTITY_PURPLE_FLY_TV                               EQU $0A
DEF ENTITY_UNK_FLY_TV_3                                EQU $0B
DEF ENTITY_BLUE_FLY_TV                                 EQU $0C
DEF ENTITY_UNK_FLY_TV_5                                EQU $0D
DEF ENTITY_UNK0E                                       EQU $0E
DEF ENTITY_UNK0F                                       EQU $0F
DEF ENTITY_UNK10                                       EQU $10
DEF ENTITY_TV_BUTTON                                   EQU $11
DEF ENTITY_TV_REMOTE                                   EQU $12
DEF ENTITY_UNK13                                       EQU $13
DEF ENTITY_GOAL_COUNTER_1                              EQU $14
DEF ENTITY_GOAL_COUNTER_2                              EQU $15
DEF ENTITY_GOAL_COUNTER_3                              EQU $16
DEF ENTITY_GOAL_COUNTER_4                              EQU $17
DEF ENTITY_GOAL_COUNTER_5                              EQU $18
DEF ENTITY_GOAL_COUNTER_6                              EQU $19
DEF ENTITY_GOAL_COUNTER_7                              EQU $1A
DEF ENTITY_BONUS_STAGE_TIMER                           EQU $1B
DEF ENTITY_FREESTANDING_REMOTE                         EQU $1C
DEF ENTITY_HOLIDAY_TV_ICE_SCULPTURE                    EQU $1D
DEF ENTITY_HOLIDAY_TV_EVIL_SANTA                       EQU $1E
DEF ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE            EQU $1F
DEF ENTITY_HOLIDAY_TV_SKATING_ELF                      EQU $20
DEF ENTITY_HOLIDAY_TV_PENGUIN                          EQU $21
DEF ENTITY_MYSTERY_TV_REZLING                          EQU $22
DEF ENTITY_MYSTERY_TV_BLOOD_COOLER                     EQU $23
DEF ENTITY_MYSTERY_TV_FISH                             EQU $24
DEF ENTITY_MYSTERY_TV_MAGIC_SWORD                      EQU $25
DEF ENTITY_MYSTERY_TV_SAFARI_SAM                       EQU $26
DEF ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE            EQU $27
DEF ENTITY_MYSTERY_TV_GHOST_KNIGHT                     EQU $28
DEF ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE          EQU $29
DEF ENTITY_TUT_TV_HAND                                 EQU $2A
DEF ENTITY_TUT_TV_LOST_ARK                             EQU $2B
DEF ENTITY_TUT_TV_RISING_PLATFORM                      EQU $2C
DEF ENTITY_TUT_TV_SIDEWAYS_PLATFORM                    EQU $2D
DEF ENTITY_TUT_TV_BEE                                  EQU $2E
DEF ENTITY_TUT_TV_RAFT                                 EQU $2F
DEF ENTITY_TUT_TV_SNAKE_FACING_RIGHT                   EQU $30
DEF ENTITY_TUT_TV_SNAKE_FACING_LEFT                    EQU $31
DEF ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE               EQU $32
DEF ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE                EQU $33
DEF ENTITY_TUT_TV_RA_STAFF                             EQU $34
DEF ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE      EQU $35
DEF ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE        EQU $36
DEF ENTITY_TUT_TV_BREAKABLE_BLOCK                      EQU $37
DEF ENTITY_TUT_TV_COFFIN                               EQU $38
DEF ENTITY_WESTERN_STATION_CACTUS                      EQU $39
DEF ENTITY_UNK3A                                       EQU $3A
DEF ENTITY_WESTERN_STATION_ROCK_PLATFORM               EQU $3B
DEF ENTITY_WESTERN_STATION_HARD_HAT                    EQU $3C
DEF ENTITY_WESTERN_STATION_PLAYING_CARD                EQU $3D
DEF ENTITY_WESTERN_STATION_BAT                         EQU $3E
DEF ENTITY_WESTERN_STATION_RISING_PLATFORM             EQU $3F
DEF ENTITY_ANIME_CHANNEL_DOOR                          EQU $40
DEF ENTITY_ANIME_CHANNEL_DOOR2                         EQU $41
DEF ENTITY_ANIME_CHANNEL_FAN_LIFT                      EQU $42
DEF ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT             EQU $43
DEF ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT              EQU $44
DEF ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR            EQU $45
DEF ENTITY_ANIME_CHANNEL_ON_SWITCH2                    EQU $46
DEF ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE            EQU $47
DEF ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER             EQU $48
DEF ENTITY_ANIME_CHANNEL_RISING_PLATFORM               EQU $49
DEF ENTITY_ANIME_CHANNEL_ON_SWITCH                     EQU $4A
DEF ENTITY_ANIME_CHANNEL_OFF_SWITCH                    EQU $4B
DEF ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL              EQU $4C
DEF ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT              EQU $4D
DEF ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT              EQU $4E
DEF ENTITY_ANIME_CHANNEL_SECBOT                        EQU $4F
DEF ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE             EQU $50
DEF ENTITY_ANIME_CHANNEL_ELEVATOR                      EQU $51
DEF ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY               EQU $52
DEF ENTITY_ANIME_CHANNEL_GRENADE                       EQU $53
DEF ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON         EQU $54
DEF ENTITY_SUPERHERO_SHOW_MAD_BOMBER                   EQU $55
DEF ENTITY_SUPERHERO_SHOW_BOMB                         EQU $56
DEF ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK             EQU $57
DEF ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND            EQU $58
DEF ENTITY_SUPERHERO_SHOW_CONVICT                      EQU $59
DEF ENTITY_SUPERHERO_SHOW_SPIDER                       EQU $5A
DEF ENTITY_SUPERHERO_SHOW_STRAY_CAT                    EQU $5B
DEF ENTITY_SUPERHERO_SHOW_YELLOW_GOON                  EQU $5C
DEF ENTITY_SUPERHERO_SHOW_RAT                          EQU $5D
DEF ENTITY_SUPERHERO_SHOW_CHOMPER_TV                   EQU $5E
DEF ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR              EQU $5F
DEF ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE           EQU $60
DEF ENTITY_GEXTREME_SPORTS_ELF                         EQU $61
DEF ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN             EQU $62
DEF ENTITY_MARSUPIAL_MADNESS_BELL                      EQU $63
DEF ENTITY_MARSUPIAL_MADNESS_BIRD                      EQU $64
DEF ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE           EQU $65
DEF ENTITY_WW_GEX_WRESTLING_ROCK_HARD                  EQU $66
DEF ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ                    EQU $67
DEF ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE              EQU $68
DEF ENTITY_LIZARD_OF_OZ_CANNON                         EQU $69
DEF ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE         EQU $6A
DEF ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2            EQU $6B
DEF ENTITY_UNK6C                                       EQU $6C
DEF ENTITY_UNK6D                                       EQU $6D
DEF ENTITY_CHANNEL_Z_REZ                               EQU $6E
DEF ENTITY_UNK6F                                       EQU $6F
DEF ENTITY_CHANNEL_Z_METEOR                            EQU $70
DEF ENTITY_CHANNEL_Z_REZ_PROJECTILE                    EQU $71
DEF ENTITY_LIST_TERMINATOR                             EQU $FF

; Entity Instance Struct
DEF ENTITY_FIELD_ENTITY_ID                  EQU $00
DEF ENTITY_FIELD_ACTION_ID                  EQU $01
DEF ENTITY_FIELD_ACTION_FUNC                EQU $02
DEF ENTITY_FIELD_SPRITE_FLAGS2              EQU $04
DEF ENTITY_FIELD_GRAPHICS_FLAGS             EQU $05
DEF ENTITY_FIELD_SPRITE_FRAME_COUNTER_MAX   EQU $06 ; how many frames to use this sprite
DEF ENTITY_FIELD_SPRITE_FRAME_COUNTER       EQU $07 ; counter for the above
DEF ENTITY_FIELD_SPRITE_COUNTER_MAX         EQU $08 ; total sprite frames for current action
DEF ENTITY_FIELD_SPRITE_COUNTER             EQU $09 ; counter for above
DEF ENTITY_FIELD_SPRITE_ID                  EQU $0A ; current sprite id
DEF ENTITY_FIELD_SPRITE_IDS_PTR             EQU $0B ; ptr to sprite data (in entity_animation_data.asm)
DEF ENTITY_FIELD_FACING_DIRECTION           EQU $0D
DEF ENTITY_FIELD_XPOS                       EQU $0E
DEF ENTITY_FIELD_YPOS                       EQU $10
DEF ENTITY_FIELD_WIDTH                      EQU $12 ; set to [1] into data_00_3258
DEF ENTITY_FIELD_HEIGHT                     EQU $13 ; set to [2] into data_00_3258
DEF ENTITY_FIELD_COLLISION_TYPE             EQU $14 ; set to [3] into data_00_3258
DEF ENTITY_FIELD_COOLDOWN_TIMER             EQU $15 ; defaults to 0, but might get set to $3c (same value as gex's cooldown timer)
DEF ENTITY_FIELD_DAMAGE_STATE               EQU $16 ; stores current health or other damage states
DEF ENTITY_FIELD_SPRITE_BANK                EQU $17
DEF ENTITY_FIELD_UNK18                      EQU $18 ; seems unused
DEF ENTITY_FIELD_MISC_FLAGS                 EQU $19 ; only used by moving platforms, skating elf health, and sec bot?
                                                    ; initially set to data_00_3258[entity_id*8][5]
DEF ENTITY_FIELD_MISC_TIMER                 EQU $1A ; timer which can be used for various purposes
DEF ENTITY_FIELD_XVEL                       EQU $1B
DEF ENTITY_FIELD_XVEL_RELATED               EQU $1C ; used with XVEL to calculate X delta
DEF ENTITY_FIELD_YVEL                       EQU $1D
DEF ENTITY_FIELD_UNK1E                      EQU $1E ; seems unused, likely would have been used for Y velocity delta
DEF ENTITY_FIELD_PARENT                     EQU $1F ; stores entity list index of this entity's parent (used for projectiles, flies)

; Entity Spawn Struct
DEF ENTITY_SPAWN_ID_OFFSET                  EQU $00
DEF ENTITY_SPAWN_XPOS_OFFSET                EQU $01
DEF ENTITY_SPAWN_YPOS_OFFSET                EQU $03
DEF ENTITY_SPAWN_BOUNDINGBOX_XMAX_OFFSET    EQU $05
DEF ENTITY_SPAWN_BOUNDINGBOX_XMIN_OFFSET    EQU $07
DEF ENTITY_SPAWN_BOUNDINGBOX_YMIN_OFFSET    EQU $09
DEF ENTITY_SPAWN_BOUNDINGBOX_YMAX_OFFSET    EQU $0B
DEF ENTITY_SPAWN_PARAMETER_OFFSET           EQU $0D ; usually id used for collectibles, but sometimes contains a timer value
DEF ENTITY_SPAWN_MAP_OFFSET                 EQU $0F

; Entity relative spawn parameters
DEF RELATIVE_ENTITY_SPAWN_FLY_1                      EQU $00
DEF RELATIVE_ENTITY_SPAWN_FLY_2                      EQU $01
DEF RELATIVE_ENTITY_SPAWN_FLY_3                      EQU $02
DEF RELATIVE_ENTITY_SPAWN_FLY_4                      EQU $03
DEF RELATIVE_ENTITY_SPAWN_FLY_5                      EQU $04
DEF RELATIVE_ENTITY_SPAWN_EVIL_SANTA_PROJECTILE      EQU $05
DEF RELATIVE_ENTITY_SPAWN_SAFARI_SAM_PROJECTILE      EQU $06
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_1             EQU $07
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_2             EQU $08
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_3             EQU $09
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_4             EQU $0A
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_5             EQU $0B
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_6             EQU $0C
DEF RELATIVE_ENTITY_SPAWN_GOAL_COUNTER_7             EQU $0D
DEF RELATIVE_ENTITY_SPAWN_SNAKE_RIGHT_PROJECTILE     EQU $0E
DEF RELATIVE_ENTITY_SPAWN_SNAKE_LEFT_PROJECTILE      EQU $0F
DEF RELATIVE_ENTITY_SPAWN_SECBOT_PROJECTILE          EQU $10
DEF RELATIVE_ENTITY_SPAWN_UNK0E                      EQU $11
DEF RELATIVE_ENTITY_SPAWN_UNK0F                      EQU $12
DEF RELATIVE_ENTITY_SPAWN_UNK10                      EQU $13
DEF RELATIVE_ENTITY_SPAWN_CONVICT_PROJECTILE         EQU $14
DEF RELATIVE_ENTITY_SPAWN_BOMB                       EQU $15
DEF RELATIVE_ENTITY_SPAWN_CANNON_PROJECTILE          EQU $16
DEF RELATIVE_ENTITY_SPAWN_CANNON_PROJECTILE_2        EQU $17
DEF RELATIVE_ENTITY_SPAWN_BRAIN_OF_OZ_PROJECTILE     EQU $18
DEF RELATIVE_ENTITY_SPAWN_STAGE_TIMER                EQU $19
DEF RELATIVE_ENTITY_SPAWN_SECBOT_PROJECTILE_2        EQU $1A
DEF RELATIVE_ENTITY_SPAWN_GHOST_KNIGHT_PROJECTILE    EQU $1B
DEF RELATIVE_ENTITY_SPAWN_BIRD_PROJECTILE            EQU $1C
DEF RELATIVE_ENTITY_SPAWN_REZ_PROJECTILE             EQU $1D
DEF RELATIVE_ENTITY_SPAWN_REZ_PROJECTILE_2           EQU $1e

; Entity Facing Direction values
; really these seem to be sprite x flip flags...
DEF ENTITY_FACING_RIGHT                 EQU $00 ; also facing up
DEF ENTITY_FACING_LEFT                  EQU $20 ; also facing down
DEF ENTITY_FACING_VERTICAL_FLIP         EQU $40
DEF ENTITY_FACING_UNK_FLAG              EQU $80

; Entity position relative to Gex
DEF ENTITY_LEFT_OF_GEX       EQU $00
DEF ENTITY_RIGHT_OF_GEX      EQU $20

; Entity flags, used in wD700_EntityFlags
DEF ENTITY_FLAG_80_ACTIVE    EQU $80

; Player vs Entity interactions
DEF PLAYER_TOUCHED_ENTITY    EQU $00
DEF PLAYER_ATTACKED_ENTITY   EQU $01
DEF PLAYER_STOMPED_ENTITY    EQU $02

; Frame timer values
DEF TIMER_AMOUNT_0_FRAMES                  EQU $00
DEF TIMER_AMOUNT_60_FRAMES                 EQU $3C
DEF TIMER_AMOUNT_120_FRAMES                EQU $78
DEF TIMER_AMOUNT_180_FRAMES                EQU $B4
DEF TIMER_AMOUNT_240_FRAMES                EQU $F0
DEF TIMER_AMOUNT_GHOST_KNIGHT              EQU $41
DEF TIMER_AMOUNT_GHOST_KNIGHT_PROJECTILE   EQU $5A
DEF TIMER_AMOUNT_RAFT                      EQU $28
DEF TIMER_AMOUNT_SNAKE_PROJECTILE          EQU $40
DEF TIMER_AMOUNT_SECBOT                    EQU $C1
DEF TIMER_AMOUNT_SECBOT_2                  EQU $02
DEF TIMER_AMOUNT_GRENADE                   EQU $04
DEF TIMER_AMOUNT_BOMB                      EQU $2D
DEF TIMER_AMOUNT_SPIDER                    EQU $08
DEF TIMER_AMOUNT_BIRD_PROJECTILE           EQU $03
DEF TIMER_AMOUNT_BRAINOFOZ1                EQU $49
DEF TIMER_AMOUNT_BRAINOFOZ2                EQU $39
DEF TIMER_AMOUNT_BRAINOFOZ3                EQU $29
DEF TIMER_AMOUNT_CANNON                    EQU $FF
DEF TIMER_AMOUNT_REZ                       EQU $06

; Menu Types
DEF MENU_TITLE_SCREEN                     EQU $00
DEF MENU_ENTER_PASSWORD                   EQU $01
DEF MENU_SEE_PASSWORD                     EQU $02
DEF MENU_GAME_OVER                        EQU $03
DEF MENU_BAD_PASSWORD                     EQU $04
DEF MENU_MISSION_SELECT_1_REMOTE          EQU $05
DEF MENU_UNK06                            EQU $06 ; unused?
DEF MENU_MISSION_SELECT_3_REMOTES         EQU $07
DEF MENU_TOTALS                           EQU $08
DEF MENU_CONGRATULATIONS_GOT_REMOTE       EQU $09
DEF MENU_TIME_UP                          EQU $0A
DEF MENU_PAUSE_IN_GEX_CAVE                EQU $0B
DEF MENU_QUIT_GAME                        EQU $0C
DEF MENU_PAUSE_IN_LEVEL                   EQU $0D
DEF MENU_GO_TO_MAP                        EQU $0E
DEF MENU_DAVID_A_PALMER                   EQU $0F
DEF MENU_UNK10                            EQU $10 ; unused?
DEF MENU_OPENING_CREDITS_1                EQU $11
DEF MENU_OPENING_CREDITS_2                EQU $12
DEF MENU_OPENING_CRYSTAL_DYNAMICS         EQU $13
DEF MENU_EIDOS_INTERACTIVE                EQU $14
DEF MENU_END_CREDITS_1                    EQU $15
DEF MENU_END_CREDITS_2                    EQU $16
DEF MENU_END_CREDITS_3                    EQU $17
DEF MENU_END_CREDITS_4                    EQU $18
DEF MENU_END_CREDITS_5                    EQU $19
DEF MENU_END_CREDITS_6                    EQU $1A
DEF MENU_WELL_DONE                        EQU $1B

; Password validity
DEF PASSWORD_INVALID                      EQU $00
DEF PASSWORD_VALID                        EQU $20

; Sound Effects
DEF SFX_EMPTY                              EQU $00
DEF SFX_MENU_SCROLL                        EQU $01
DEF SFX_ITEM_PICKUP                        EQU $02 ; fly coins, paw coins, bonus coins
DEF SFX_FLY_TV                             EQU $03
DEF SFX_GEX_TAIL_SPIN                      EQU $04
DEF SFX_UNK05                              EQU $05 ; unknown, but sounds similar to tail spin?
DEF SFX_GEX_JUMP                           EQU $06
DEF SFX_GEX_DOUBLE_JUMP                    EQU $07
DEF SFX_UNK08                              EQU $08 ; hit something with tail maybe?
DEF SFX_UNK09                              EQU $09
DEF SFX_PLAYER_DAMAGED                     EQU $0A
DEF SFX_UNK0B                              EQU $0B
DEF SFX_UNK0C                              EQU $0C
DEF SFX_UNK0D                              EQU $0D
DEF SFX_GEX_SPAWN                          EQU $0E
DEF SFX_ENEMY_DAMAGED                      EQU $0F
DEF SFX_ENEMY_KILLED                       EQU $10
DEF SFX_UNK11                              EQU $11
DEF SFX_UNK12                              EQU $12
DEF SFX_METEOR                             EQU $13
DEF SFX_CANNON                             EQU $14
DEF SFX_BRAIN_OF_OZ                        EQU $15
DEF SFX_UNK16                              EQU $16
DEF SFX_UNK17                              EQU $17
DEF SFX_DOOR1                              EQU $18
DEF SFX_SMALL_BANG                         EQU $19 ; misc
DEF SFX_LOUD_BANG                          EQU $1A ; boss deaths, TutTV block
DEF SFX_DOOR2                              EQU $1B ; also used by cannon?
DEF SFX_BOMB                               EQU $1C
DEF SFX_UNK1D                              EQU $1D
DEF SFX_REMOTE                             EQU $1E
DEF SFX_UNK1F                              EQU $1F
DEF SFX_NONE                               EQU $FF ; no sfx queued

; Songs
DEF SONG_EMPTY                             EQU $00
DEF SONG_UNK01                             EQU $01
DEF SONG_HOLIDAY_TV                        EQU $02
DEF SONG_WESTERN_STATION                   EQU $03
DEF SONG_GEX_CAVE                          EQU $04
DEF SONG_TUT_TV                            EQU $05
DEF SONG_UNK06                             EQU $06 ; unused?
DEF SONG_UNK07                             EQU $07 ; unused?
DEF SONG_UNK08                             EQU $08 ; unused?
DEF SONG_UNK09                             EQU $09 ; unused?
DEF SONG_UNK0A                             EQU $0A ; unused?
DEF SONG_UNK0B                             EQU $0B ; unused?
DEF SONG_UNK0C                             EQU $0C ; unused?
DEF SONG_UNK0D                             EQU $0D ; unused?
DEF SONG_UNK0E                             EQU $0E ; unused?
DEF SONG_UNK0F                             EQU $0F ; unused?
DEF SONG_UNK10                             EQU $10 ; unused?
DEF SONG_BOSS                              EQU $11
DEF SONG_MYSTERY_TV                        EQU $12
DEF SONG_MISSION_SUCCESS                   EQU $13 ; used when you get a remote or complete a bonus level
DEF SONG_ANIME_CHANNEL                     EQU $14
DEF SONG_GAME_OVER_OR_TIME_UP              EQU $15
DEF SONG_BONUS_CHANNEL                     EQU $16
DEF SONG_SUPERHERO_SHOW                    EQU $17
DEF SONG_CHANNEL_Z                         EQU $18
DEF SONG_CREDITS                           EQU $19
DEF SONG_NONE                              EQU $FF

; Entity Collision Types
DEF COLLISION_TYPE_NONE                      EQU $00
DEF COLLISION_TYPE_PLATFORM                  EQU $01
DEF COLLISION_TYPE_INVULNERABLE_ENEMY        EQU $02 ; player can be damaged by this entity, but cannot damage it
DEF COLLISION_TYPE_PROJECTILE                EQU $03 ; the entity is destroyed after damaging player 
DEF COLLISION_TYPE_GENERIC_ENEMY             EQU $04 ; the entity remains after damaging player. player can damage this enemy.
DEF COLLISION_TYPE_GENERIC_ENEMY_UNUSED      EQU $05 ; seems unused
DEF COLLISION_TYPE_DAMAGE_PLAYER_UNUSED      EQU $06 ; seems unused
DEF COLLISION_TYPE_BONUS_COIN                EQU $07
DEF COLLISION_TYPE_FLY_COIN                  EQU $08
DEF COLLISION_TYPE_PAW_COIN                  EQU $09
DEF COLLISION_TYPE_FLY                       EQU $0A
DEF COLLISION_TYPE_FLY_TV                    EQU $0B
DEF COLLISION_TYPE_ICE_SCULPTURE             EQU $0C
DEF COLLISION_TYPE_EVIL_SANTA_PROJECTILE     EQU $0D
DEF COLLISION_TYPE_HOLIDAY_TV_ELF            EQU $0E
DEF COLLISION_TYPE_BLOOD_COOLER              EQU $0F
DEF COLLISION_TYPE_MAGIC_SWORD               EQU $10
DEF COLLISION_TYPE_GHOST_KNIGHT              EQU $11
DEF COLLISION_TYPE_HAND                      EQU $12
DEF COLLISION_TYPE_LOST_ARK                  EQU $13
DEF COLLISION_TYPE_RA_STAFF                  EQU $14
DEF COLLISION_TYPE_COFFIN                    EQU $15
DEF COLLISION_TYPE_ALIEN_CULTURE_TUBE        EQU $16
DEF COLLISION_TYPE_ON_SWITCH                 EQU $17
DEF COLLISION_TYPE_OFF_SWITCH                EQU $18
DEF COLLISION_TYPE_ON_SWITCH_2               EQU $19
DEF COLLISION_TYPE_DOOR                      EQU $1A
DEF COLLISION_TYPE_DOOR_2                    EQU $1B
DEF COLLISION_TYPE_SECBOT                    EQU $1C
DEF COLLISION_TYPE_SAILOR_TOON_GIRL          EQU $1D
DEF COLLISION_TYPE_BIG_SILVER_ROBOT          EQU $1E
DEF COLLISION_TYPE_MECH                      EQU $1F
DEF COLLISION_TYPE_PLANET_O_BLAST            EQU $20
DEF COLLISION_TYPE_STRAY_CAT                 EQU $21
DEF COLLISION_TYPE_CONVICT                   EQU $22
DEF COLLISION_TYPE_YELLOW_GOON               EQU $23
DEF COLLISION_TYPE_CHOMPER_TV                EQU $24
DEF COLLISION_TYPE_BOMB                      EQU $25
DEF COLLISION_TYPE_WATER_TOWER_STAND         EQU $26
DEF COLLISION_TYPE_GEXTREME_SPORTS_ELF       EQU $27
DEF COLLISION_TYPE_BONUS_TIME_COIN           EQU $28
DEF COLLISION_TYPE_BELL                      EQU $29
DEF COLLISION_TYPE_CANNON                    EQU $2A
DEF COLLISION_TYPE_BRAIN_OF_OZ               EQU $2B
DEF COLLISION_TYPE_BRAIN_OF_OZ_PROJECTILE    EQU $2C
DEF COLLISION_TYPE_FREESTANDING_REMOTE       EQU $2D
DEF COLLISION_TYPE_CACTUS                    EQU $2E
DEF COLLISION_TYPE_PLAYING_CARD              EQU $2F
DEF COLLISION_TYPE_HARD_HAT                  EQU $30
DEF COLLISION_TYPE_METEOR                    EQU $31
DEF COLLISION_TYPE_REZ                       EQU $32
DEF COLLISION_TYPE_TV_BUTTON                 EQU $33
DEF COLLISION_TYPE_RA_STATUE_PROJECTILE      EQU $34
DEF COLLISION_TYPE_ROCK_HARD                 EQU $35
DEF COLLISION_TYPE_UNK_PLATFORM_FLAG         EQU $80

; Bg Collision Types
DEF BG_COLLISION_TYPE_SIDESCROLLER  EQU $00
DEF BG_COLLISION_TYPE_TOPDOWN       EQU $01

; Player Actions
DEF PLAYERACTION_SPAWN                                   EQU $00
DEF PLAYERACTION_IDLE                                    EQU $01
DEF PLAYERACTION_IDLE_ANIMATION                          EQU $02
DEF PLAYERACTION_WALK                                    EQU $03
DEF PLAYERACTION_START_CROUCH                            EQU $04
DEF PLAYERACTION_CROUCH_LOOK_DOWN                        EQU $05
DEF PLAYERACTION_NONE_0                                  EQU $06
DEF PLAYERACTION_UNK7                                    EQU $07
DEF PLAYERACTION_EAT_FLY                                 EQU $08
DEF PLAYERACTION_TAKE_DAMAGE                             EQU $09
DEF PLAYERACTION_DEATH                                   EQU $0A
DEF PLAYERACTION_DEATH_SET_UP_WARP                       EQU $0B
DEF PLAYERACTION_STAND_ON_TV_BUTTON                      EQU $0C
DEF PLAYERACTION_ENTER_TV                                EQU $0D
DEF PLAYERACTION_JUMP                                    EQU $0E
DEF PLAYERACTION_DOUBLE_JUMP                             EQU $0F
DEF PLAYERACTION_TAIL_SPIN                               EQU $10
DEF PLAYERACTION_FALL                                    EQU $11
DEF PLAYERACTION_LAND_FROM_FALL                          EQU $12
DEF PLAYERACTION_UNK19                                   EQU $13
DEF PLAYERACTION_ENTER_IDLE                              EQU $14
DEF PLAYERACTION_NONE_1                                  EQU $15
DEF PLAYERACTION_NONE_2                                  EQU $16
DEF PLAYERACTION_NONE_3                                  EQU $17
DEF PLAYERACTION_NONE_4                                  EQU $18
DEF PLAYERACTION_WATER_SWIMMING                          EQU $19
DEF PLAYERACTION_DEATH_IN_PIT_ALT                        EQU $1A
DEF PLAYERACTION_DEATH_IN_PIT                            EQU $1B
DEF PLAYERACTION_NONE_5                                  EQU $1C
DEF PLAYERACTION_BLOWN_UPWARDS                           EQU $1D
DEF PLAYERACTION_RIDING_ELEVATOR                         EQU $1E
DEF PLAYERACTION_WATER_TAIL_SPIN                         EQU $1F
DEF PLAYERACTION_WATER_TREADING                          EQU $20
DEF PLAYERACTION_WATER_DIVING                            EQU $21
DEF PLAYERACTION_CLIMBING                                EQU $22
DEF PLAYERACTION_SNOWBOARDING_SPAWN                      EQU $23
DEF PLAYERACTION_SNOWBOARDING_STAND_OR_WALK              EQU $24
DEF PLAYERACTION_SNOWBOARDING_JUMP                       EQU $25
DEF PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP                EQU $26
DEF PLAYERACTION_SNOWBOARDING_TAIL_SPIN                  EQU $27
DEF PLAYERACTION_SNOWBOARDING_FALL                       EQU $28
DEF PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE                EQU $29
DEF PLAYERACTION_SNOWBOARDING_DIE                        EQU $2A
DEF PLAYERACTION_SNOWBOARDING_DIE_WARP                   EQU $2B
DEF PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON         EQU $2C
DEF PLAYERACTION_SNOWBOARDING_ENTER_TV                   EQU $2D
DEF PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT           EQU $2E
DEF PLAYERACTION_KANGAROO_SPAWN                          EQU $2F
DEF PLAYERACTION_KANGAROO_IDLE                           EQU $30
DEF PLAYERACTION_KANGAROO_HOPPING                        EQU $31
DEF PLAYERACTION_KANGAROO_START_JUMP                     EQU $32
DEF PLAYERACTION_KANGAROO_JUMP                           EQU $33
DEF PLAYERACTION_KANGAROO_TAIL_SPIN                      EQU $34
DEF PLAYERACTION_KANGAROO_FALL                           EQU $35
DEF PLAYERACTION_KANGAROO_TAKE_DAMAGE                    EQU $36
DEF PLAYERACTION_KANGAROO_DEATH                          EQU $37
DEF PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP              EQU $38
DEF PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON             EQU $39
DEF PLAYERACTION_KANGAROO_ENTER_TV                       EQU $3A
DEF PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT               EQU $3B
DEF PLAYERACTION_TOPDOWN_SPAWN                           EQU $3C
DEF PLAYERACTION_TOPDOWN_IDLE                            EQU $3D
DEF PLAYERACTION_TOPDOWN_IDLE_ANIMATION                  EQU $3E
DEF PLAYERACTION_TOPDOWN_WALK                            EQU $3F
DEF PLAYERACTION_TOPDOWN_START_CROUCH                    EQU $40
DEF PLAYERACTION_TOPDOWN_NONE_CROUCH                     EQU $41
DEF PLAYERACTION_TOPDOWN_NONE_0                          EQU $42
DEF PLAYERACTION_TOPDOWN_UNK7                            EQU $43
DEF PLAYERACTION_TOPDOWN_EAT_FLY                         EQU $44
DEF PLAYERACTION_TOPDOWN_TAKE_DAMAGE                     EQU $45
DEF PLAYERACTION_TOPDOWN_DEATH                           EQU $46
DEF PLAYERACTION_TOPDOWN_DEATH_SET_UP_WARP               EQU $47
DEF PLAYERACTION_TOPDOWN_STAND_ON_TV_BUTTON              EQU $48
DEF PLAYERACTION_TOPDOWN_ENTER_TV                        EQU $49
DEF PLAYERACTION_TOPDOWN_JUMP                            EQU $4A
DEF PLAYERACTION_TOPDOWN_DOUBLE_JUMP                     EQU $4B
DEF PLAYERACTION_TOPDOWN_TAIL_SPIN                       EQU $4C
DEF PLAYERACTION_TOPDOWN_FALL                            EQU $4D
DEF PLAYERACTION_TOPDOWN_LAND_FROM_FALL                  EQU $4E
DEF PLAYERACTION_TOPDOWN_UNK19                           EQU $4F
DEF PLAYERACTION_TOPDOWN_ENTER_IDLE                      EQU $50
DEF PLAYERACTION_TOPDOWN_NONE_1                          EQU $51
DEF PLAYERACTION_TOPDOWN_NONE_2                          EQU $52
DEF PLAYERACTION_TOPDOWN_NONE_3                          EQU $53
DEF PLAYERACTION_TOPDOWN_NONE_4                          EQU $54
DEF PLAYERACTION_TOPDOWN_WATER_SWIMMING                  EQU $55
DEF PLAYERACTION_TOPDOWN_DEATH_IN_PIT_ALT                EQU $56
DEF PLAYERACTION_TOPDOWN_DEATH_IN_PIT                    EQU $57
DEF PLAYERACTION_TOPDOWN_NONE_5                          EQU $58
DEF PLAYERACTION_TOPDOWN_BLOWN_UPWARDS                   EQU $59
DEF PLAYERACTION_TOPDOWN_RIDING_ELEVATOR                 EQU $5A
DEF PLAYERACTION_TOPDOWN_WATER_TAIL_SPIN                 EQU $5B
DEF PLAYERACTION_TOPDOWN_WATER_TREADING                  EQU $5C
DEF PLAYERACTION_TOPDOWN_WATER_DIVING                    EQU $5D
DEF PLAYERACTION_TOPDOWN_CLIMBING                        EQU $5E
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_SPAWN              EQU $5F
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_STAND_OR_WALK      EQU $60
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_JUMP               EQU $61
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DOUBLE_JUMP        EQU $62
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_TAIL_SPIN          EQU $63
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_FALL               EQU $64
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_TAKE_DAMAGE        EQU $65
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DIE                EQU $66
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DIE_WARP           EQU $67
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_STAND_ON_TV_BUTTON EQU $68
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_ENTER_TV           EQU $69
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DEATH_IN_PIT_ALT   EQU $6A
DEF PLAYERACTION_TOPDOWN_KANGAROO_SPAWN                  EQU $6B
DEF PLAYERACTION_TOPDOWN_KANGAROO_IDLE                   EQU $6C
DEF PLAYERACTION_TOPDOWN_KANGAROO_HOPPING                EQU $6D
DEF PLAYERACTION_TOPDOWN_KANGAROO_START_JUMP             EQU $6E
DEF PLAYERACTION_TOPDOWN_KANGAROO_JUMP                   EQU $6F
DEF PLAYERACTION_TOPDOWN_KANGAROO_TAIL_SPIN              EQU $70
DEF PLAYERACTION_TOPDOWN_KANGAROO_FALL                   EQU $71
DEF PLAYERACTION_TOPDOWN_KANGAROO_TAKE_DAMAGE            EQU $72
DEF PLAYERACTION_TOPDOWN_KANGAROO_DEATH                  EQU $73
DEF PLAYERACTION_TOPDOWN_KANGAROO_DEATH_SET_UP_WARP      EQU $74
DEF PLAYERACTION_TOPDOWN_KANGAROO_STAND_ON_TV_BUTTON     EQU $75
DEF PLAYERACTION_TOPDOWN_KANGAROO_ENTER_TV               EQU $76
DEF PLAYERACTION_TOPDOWN_KANGAROO_DEATH_IN_PIT_ALT       EQU $77
DEF PLAYERACTION_NONE_PENDING                            EQU $FF
DEF PLAYERACTION_OFFSET_TOPDOWN                          EQU $3C

; Player Action State flags
DEF PLAYER_DEFAULT           EQU $00
DEF PLAYER_UNK01             EQU $01
DEF PLAYER_UNK02             EQU $02
DEF PLAYER_UNK04             EQU $04
DEF PLAYER_DEAD              EQU $08
DEF PLAYER_UNK10             EQU $10 ; unused?
DEF PLAYER_IN_WATER          EQU $20
DEF PLAYER_UNK40             EQU $40 ; unused?
DEF PLAYER_CLIMBING          EQU $80

; Entity Action Ids
DEF ENTITYACTION_PENGUIN_WALK_OR_RUN             EQU $00
DEF ENTITYACTION_PENGUIN_JUMP                    EQU $01
