; MBC1
DEF MBC1SRamEnable      EQU $0001
DEF MBC1RomBank         EQU $2001
DEF MBC1SRamBank        EQU $4001
DEF MBC1SRamBankingMode EQU $6001

; ROM Banks
DEF BANK_00_HOME_CODE         EQU $00
DEF BANK_01_MENU_CODE         EQU $01
DEF BANK_02_OBJECT_CODE       EQU $02
DEF BANK_03_COLLISION_AND_GRAPHICS_CODE EQU $03
DEF BANK_04_AUDIO_CODE_1      EQU $04
DEF BANK_05_AUDIO_CODE_2      EQU $05
DEF Bank06                    EQU $06
DEF Bank07                    EQU $07
DEF Bank08                    EQU $08
DEF Bank09                    EQU $09
DEF BANK_0A_OBJECT_SPRITES    EQU $0a
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
DEF Bank22_ObjectSpawnLists   EQU $22 ; object spawn lists for each map
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

DEF BANK_7F_OBJECT_PALETTES   EQU $7f ; object sprite and palette data

; Inputs (defined in hardware.inc)
; DEF PADF_DOWN   EQU $80
; DEF PADF_UP     EQU $40
; DEF PADF_LEFT   EQU $20
; DEF PADF_RIGHT  EQU $10
; DEF PADF_START  EQU $08
; DEF PADF_SELECT EQU $04
; DEF PADF_B      EQU $02
; DEF PADF_A      EQU $01

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

; Objects
DEF OBJECT_GEX                                         EQU $00
DEF OBJECT_BONUS_COIN                                  EQU $01
DEF OBJECT_FLY_COIN_SPAWN                              EQU $02
DEF OBJECT_PAW_COIN                                    EQU $03
DEF OBJECT_UNK04                                       EQU $04
DEF OBJECT_UNK05                                       EQU $05
DEF OBJECT_UNK06                                       EQU $06
DEF OBJECT_UNK07                                       EQU $07
DEF OBJECT_UNK08                                       EQU $08
DEF OBJECT_GREEN_FLY_TV                                EQU $09
DEF OBJECT_PURPLE_FLY_TV                               EQU $0A
DEF OBJECT_UNK0B                                       EQU $0B
DEF OBJECT_BLUE_FLY_TV                                 EQU $0C
DEF OBJECT_UNK0D                                       EQU $0D
DEF OBJECT_UNK0E                                       EQU $0E
DEF OBJECT_UNK0F                                       EQU $0F
DEF OBJECT_UNK10                                       EQU $10
DEF OBJECT_TV_BUTTON                                   EQU $11
DEF OBJECT_TV_REMOTE                                   EQU $12
DEF OBJECT_UNK13                                       EQU $13
DEF OBJECT_GOAL_COUNTER                                EQU $14
DEF OBJECT_UNK15                                       EQU $15
DEF OBJECT_UNK16                                       EQU $16
DEF OBJECT_UNK17                                       EQU $17
DEF OBJECT_UNK18                                       EQU $18
DEF OBJECT_UNK19                                       EQU $19
DEF OBJECT_UNK1A                                       EQU $1A
DEF OBJECT_BONUS_STAGE_TIMER                           EQU $1B
DEF OBJECT_FREESTANDING_REMOTE                         EQU $1C
DEF OBJECT_HOLIDAY_TV_ICE_SCULPTURE                    EQU $1D
DEF OBJECT_HOLIDAY_TV_EVIL_SANTA                       EQU $1E
DEF OBJECT_HOLIDAY_TV_EVIL_SANTA_PROJECTILE            EQU $1F
DEF OBJECT_HOLIDAY_TV_SKATING_ELF                      EQU $20
DEF OBJECT_HOLIDAY_TV_PENGUIN                          EQU $21
DEF OBJECT_MYSTERY_TV_REZLING                          EQU $22
DEF OBJECT_MYSTERY_TV_BLOOD_COOLER                     EQU $23
DEF OBJECT_MYSTERY_TV_FISH                             EQU $24
DEF OBJECT_MYSTERY_TV_MAGIC_SWORD                      EQU $25
DEF OBJECT_MYSTERY_TV_SAFARI_SAM                       EQU $26
DEF OBJECT_MYSTERY_TV_SAFARI_SAM_PROJECTILE            EQU $27
DEF OBJECT_MYSTERY_TV_GHOST_KNIGHT                     EQU $28
DEF OBJECT_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE          EQU $29
DEF OBJECT_TUT_TV_HAND                                 EQU $2A
DEF OBJECT_TUT_TV_LOST_ARK                             EQU $2B
DEF OBJECT_TUT_TV_RISING_PLATFORM                      EQU $2C
DEF OBJECT_TUT_TV_SIDEWAYS_PLATFORM                    EQU $2D
DEF OBJECT_TUT_TV_BEE                                  EQU $2E
DEF OBJECT_TUT_TV_RAFT                                 EQU $2F
DEF OBJECT_TUT_TV_SNAKE_FACING_RIGHT                   EQU $30
DEF OBJECT_TUT_TV_SNAKE_FACING_LEFT                    EQU $31
DEF OBJECT_TUT_TV_SNAKE_RIGHT_PROJECTILE               EQU $32
DEF OBJECT_TUT_TV_SNAKE_LEFT_PROJECTILE                EQU $33
DEF OBJECT_TUT_TV_RA_STAFF                             EQU $34
DEF OBJECT_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE      EQU $35
DEF OBJECT_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE        EQU $36
DEF OBJECT_TUT_TV_BREAKABLE_BLOCK                      EQU $37
DEF OBJECT_TUT_TV_COFFIN                               EQU $38
DEF OBJECT_WESTERN_STATION_CACTUS                      EQU $39
DEF OBJECT_UNK3A                                       EQU $3A
DEF OBJECT_WESTERN_STATION_ROCK_PLATFORM               EQU $3B
DEF OBJECT_WESTERN_STATION_HARD_HAT                    EQU $3C
DEF OBJECT_WESTERN_STATION_PLAYING_CARD                EQU $3D
DEF OBJECT_WESTERN_STATION_BAT                         EQU $3E
DEF OBJECT_WESTERN_STATION_RISING_PLATFORM             EQU $3F
DEF OBJECT_ANIME_CHANNEL_DOOR                          EQU $40
DEF OBJECT_ANIME_CHANNEL_DOOR2                         EQU $41
DEF OBJECT_ANIME_CHANNEL_FAN_LIFT                      EQU $42
DEF OBJECT_ANIME_CHANNEL_MECH_FACING_RIGHT             EQU $43
DEF OBJECT_ANIME_CHANNEL_MECH_FACING_LEFT              EQU $44
DEF OBJECT_ANIME_CHANNEL_DISAPPEARING_FLOOR            EQU $45
DEF OBJECT_ANIME_CHANNEL_ON_SWITCH2                    EQU $46
DEF OBJECT_ANIME_CHANNEL_ALIEN_CULTURE_TUBE            EQU $47
DEF OBJECT_ANIME_CHANNEL_BLUE_BEAM_BARRIER             EQU $48
DEF OBJECT_ANIME_CHANNEL_RISING_PLATFORM               EQU $49
DEF OBJECT_ANIME_CHANNEL_ON_SWITCH                     EQU $4A
DEF OBJECT_ANIME_CHANNEL_OFF_SWITCH                    EQU $4B
DEF OBJECT_ANIME_CHANNEL_SAILOR_TOON_GIRL              EQU $4C
DEF OBJECT_ANIME_CHANNEL_BIG_SILVER_ROBOT              EQU $4D
DEF OBJECT_ANIME_CHANNEL_SMALL_BLUE_ROBOT              EQU $4E
DEF OBJECT_ANIME_CHANNEL_SECBOT                        EQU $4F
DEF OBJECT_ANIME_CHANNEL_SECBOT_PROJECTILE             EQU $50
DEF OBJECT_ANIME_CHANNEL_ELEVATOR                      EQU $51
DEF OBJECT_ANIME_CHANNEL_FIRE_WALL_ENEMY               EQU $52
DEF OBJECT_ANIME_CHANNEL_GRENADE                       EQU $53
DEF OBJECT_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON         EQU $54
DEF OBJECT_SUPERHERO_SHOW_MAD_BOMBER                   EQU $55
DEF OBJECT_SUPERHERO_SHOW_BOMB                         EQU $56
DEF OBJECT_SUPERHERO_SHOW_WATER_TOWER_TANK             EQU $57
DEF OBJECT_SUPERHERO_SHOW_WATER_TOWER_STAND            EQU $58
DEF OBJECT_SUPERHERO_SHOW_CONVICT                      EQU $59
DEF OBJECT_SUPERHERO_SHOW_SPIDER                       EQU $5A
DEF OBJECT_SUPERHERO_SHOW_STRAY_CAT                    EQU $5B
DEF OBJECT_SUPERHERO_SHOW_YELLOW_GOON                  EQU $5C
DEF OBJECT_SUPERHERO_SHOW_RAT                          EQU $5D
DEF OBJECT_SUPERHERO_SHOW_CHOMPER_TV                   EQU $5E
DEF OBJECT_SUPERHERO_SHOW_CRUMBLING_FLOOR              EQU $5F
DEF OBJECT_SUPERHERO_SHOW_CONVICT_PROJECTILE           EQU $60
DEF OBJECT_GEXTREME_SPORTS_ELF                         EQU $61
DEF OBJECT_GEXTREME_SPORTS_BONUS_TIME_COIN             EQU $62
DEF OBJECT_MARSUPIAL_MADNESS_BELL                      EQU $63
DEF OBJECT_MARSUPIAL_MADNESS_BIRD                      EQU $64
DEF OBJECT_MARSUPIAL_MADNESS_BIRD_PROJECTILE           EQU $65
DEF OBJECT_WW_GEX_WRESTLING_ROCK_HARD                  EQU $66
DEF OBJECT_LIZARD_OF_OZ_BRAIN_OF_OZ                    EQU $67
DEF OBJECT_LIZARD_OF_OZ_CANNON_PROJECTILE              EQU $68
DEF OBJECT_LIZARD_OF_OZ_CANNON                         EQU $69
DEF OBJECT_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE         EQU $6A
DEF OBJECT_UNK6B                                       EQU $6B
DEF OBJECT_UNK6C                                       EQU $6C
DEF OBJECT_UNK6D                                       EQU $6D
DEF OBJECT_CHANNEL_Z_REZ                               EQU $6E
DEF OBJECT_UNK6F                                       EQU $6F
DEF OBJECT_CHANNEL_Z_METEOR                            EQU $70
DEF OBJECT_CHANNEL_Z_REZ_PROJECTILE                    EQU $71
DEF OBJECT_LIST_TERMINATOR                             EQU $FF

; Object Instance Struct
DEF OBJECT_ID_OFFSET                        EQU $00
DEF OBJECT_ACTIONID_OFFSET                  EQU $01
DEF OBJECT_ACTIONPTR_OFFSET                 EQU $02
DEF OBJECT_SPRITE_FLAGS2_OFFSET             EQU $04
DEF OBJECT_MOVEMENT_FLAGS_OFFSET            EQU $05
DEF OBJECT_SPRITE_FRAME_COUNTER_MAX_OFFSET  EQU $06 ; how many frames to use this sprite
DEF OBJECT_SPRITE_FRAME_COUNTER_OFFSET      EQU $07 ; counter for the above
DEF OBJECT_SPRITE_COUNTER_MAX_OFFSET        EQU $08 ; total sprite frames for current action
DEF OBJECT_SPRITE_COUNTER_OFFSET            EQU $09 ; counter for above
DEF OBJECT_SPRITE_ID_OFFSET                 EQU $0A ; current sprite id
DEF OBJECT_SPRITE_IDS_PTR_OFFSET            EQU $0B ; ptr to sprite data (in object_animation_data.asm)
DEF OBJECT_FACINGDIRECTION_OFFSET           EQU $0D
DEF OBJECT_XPOS_OFFSET                      EQU $0E
DEF OBJECT_YPOS_OFFSET                      EQU $10
DEF OBJECT_WIDTH_OFFSET                     EQU $12 ; set to [1] into data_00_3258
DEF OBJECT_HEIGHT_OFFSET                    EQU $13 ; set to [2] into data_00_3258
DEF OBJECT_COLLISION_TYPE_OFFSET            EQU $14 ; set to [3] into data_00_3258
DEF OBJECT_COOLDOWN_TIMER_OFFSET            EQU $15 ; defaults to 0, but might get set to $3c (same value as gex's cooldown timer)
DEF OBJECT_UNK16_OFFSET                     EQU $16 ; collision related, starts as [4] into data_00_3258, minus 1
DEF OBJECT_SPRITE_BANK_OFFSET               EQU $17
DEF OBJECT_UNK18_OFFSET                     EQU $18 ; starts as 0
DEF OBJECT_EXTRA_FLAGS_OFFSET               EQU $19 ; only used by moving platforms, skating elf health, and sec bot (?)
                                                    ; starts as [5] into data_00_3258
DEF OBJECT_MISC_TIMER_OFFSET                EQU $1A ; timer which can be used for varying purposes
DEF OBJECT_XVEL_OFFSET                      EQU $1B
DEF OBJECT_UNK1C_OFFSET                     EQU $1C
DEF OBJECT_YVEL_OFFSET                      EQU $1D
DEF OBJECT_UNK1E_OFFSET                     EQU $1E
DEF OBJECT_UNK1F_OFFSET                     EQU $1F ; collision related

; Object Spawn Struct
DEF OBJECTSPAWN_ID_OFFSET                   EQU $00
DEF OBJECTSPAWN_XPOS_OFFSET                 EQU $01
DEF OBJECTSPAWN_YPOS_OFFSET                 EQU $03
DEF OBJECTSPAWN_BOUNDINGBOX_XMAX_OFFSET     EQU $05
DEF OBJECTSPAWN_BOUNDINGBOX_XMIN_OFFSET     EQU $07
DEF OBJECTSPAWN_BOUNDINGBOX_YMIN_OFFSET     EQU $09
DEF OBJECTSPAWN_BOUNDINGBOX_YMAX_OFFSET     EQU $0B
DEF OBJECTSPAWN_PARAMETER_OFFSET            EQU $0D ; usually id used for collectibles, but sometimes contains a timer value
DEF OBJECTSPAWN_MAP_OFFSET                  EQU $0F

; Object Facing Direction values
DEF OBJECT_FACING_RIGHT      EQU $00
DEF OBJECT_FACING_LEFT       EQU $20
DEF OBJECT_FACING_UNK40      EQU $40

; Object position relative to Gex
DEF OBJECT_LEFT_OF_GEX       EQU $00
DEF OBJECT_RIGHT_OF_GEX      EQU $20

; Object flags, used in wD700_ObjectFlags
DEF OBJECT_FLAG_80_ACTIVE                  EQU $80

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

; Object Action Ids
DEF OBJECTACTION_PENGUIN_WALK_OR_RUN      EQU $00
DEF OBJECTACTION_PENGUIN_JUMP             EQU $01

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
DEF MENU_UNK09                            EQU $09 ; used but unknown
DEF MENU_UNK0A                            EQU $0A ; used but unknown
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
DEF MENU_UNK1B                            EQU $1B ; used but unknown

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
DEF SONG_UNK06                             EQU $06
DEF SONG_UNK07                             EQU $07
DEF SONG_UNK08                             EQU $08
DEF SONG_UNK09                             EQU $09
DEF SONG_UNK0A                             EQU $0A
DEF SONG_UNK0B                             EQU $0B
DEF SONG_UNK0C                             EQU $0C
DEF SONG_UNK0D                             EQU $0D
DEF SONG_UNK0E                             EQU $0E
DEF SONG_UNK0F                             EQU $0F
DEF SONG_UNK10                             EQU $10
DEF SONG_BOSS                              EQU $11
DEF SONG_MYSTERY_TV                        EQU $12
DEF SONG_UNK13                             EQU $13
DEF SONG_ANIME_CHANNEL                     EQU $14
DEF SONG_UNK15                             EQU $15
DEF SONG_BONUS_CHANNEL                     EQU $16
DEF SONG_SUPERHERO_SHOW                    EQU $17
DEF SONG_CHANNEL_Z                         EQU $18
DEF SONG_UNK19                             EQU $19
DEF SONG_NONE                              EQU $FF

; Collision Types
DEF COLLISION_TYPE_NONE                      EQU $00
DEF COLLISION_TYPE_PLATFORM                  EQU $01
DEF COLLISION_TYPE_DAMAGE_UNDERWATER         EQU $02 ; player is damaged, but do not change player's action or position
DEF COLLISION_TYPE_DAMAGE_AND_DESTROY        EQU $03 ; player is damaged, and the object is destroyed
DEF COLLISION_TYPE_DAMAGE_AND_REMAIN         EQU $04 ; player is damaged, but the object remains loaded
DEF COLLISION_TYPE_UNK_05                    EQU $05 ; seems unused
DEF COLLISION_TYPE_UNK_06                    EQU $06 ; seems unused
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
DEF COLLISION_TYPE_PLATFORM_WITH_FLAG        EQU $81

; Player Actions
DEF PLAYERACTION_SPAWN                          EQU $00
DEF PLAYERACTION_IDLE                           EQU $01
DEF PLAYERACTION_IDLE_ANIMATION                 EQU $02
DEF PLAYERACTION_WALK                           EQU $03
DEF PLAYERACTION_START_CROUCH                   EQU $04
DEF PLAYERACTION_CROUCH_LOOK_DOWN               EQU $05
DEF PLAYERACTION_OBJECT_NONE_1                  EQU $06
DEF PLAYERACTION_UNK7                           EQU $07
DEF PLAYERACTION_UNK8                           EQU $08
DEF PLAYERACTION_TAKE_DAMAGE                    EQU $09
DEF PLAYERACTION_DIE                            EQU $0A
DEF PLAYERACTION_DIE_WARP                       EQU $0B
DEF PLAYERACTION_STAND_ON_TV_BUTTON             EQU $0C
DEF PLAYERACTION_ENTER_TV                       EQU $0D
DEF PLAYERACTION_JUMP                           EQU $0E
DEF PLAYERACTION_DOUBLE_JUMP                    EQU $0F
DEF PLAYERACTION_TAIL_SPIN                      EQU $10
DEF PLAYERACTION_FALL                           EQU $11
DEF PLAYERACTION_FALLING_LAND                   EQU $12
DEF PLAYERACTION_UNK19                          EQU $13
DEF PLAYERACTION_UNK20                          EQU $14
DEF PLAYERACTION_UNK21_TO_24_1                  EQU $15
DEF PLAYERACTION_UNK21_TO_24_2                  EQU $16
DEF PLAYERACTION_UNK21_TO_24_3                  EQU $17
DEF PLAYERACTION_UNK21_TO_24_4                  EQU $18
DEF PLAYERACTION_UNK25                          EQU $19
DEF PLAYERACTION_UNK26                          EQU $1A
DEF PLAYERACTION_DIE_IN_PIT                     EQU $1B
DEF PLAYERACTION_UNK28                          EQU $1C
DEF PLAYERACTION_UNK29                          EQU $1D
DEF PLAYERACTION_UNK30                          EQU $1E
DEF PLAYERACTION_UNK31                          EQU $1F
DEF PLAYERACTION_UNK32                          EQU $20
DEF PLAYERACTION_UNK33                          EQU $21
DEF PLAYERACTION_UNK34                          EQU $22
DEF PLAYERACTION_SPAWN_2                        EQU $23
DEF PLAYERACTION_UNK36                          EQU $24
DEF PLAYERACTION_UNK37                          EQU $25
DEF PLAYERACTION_UNK38                          EQU $26
DEF PLAYERACTION_UNK39                          EQU $27
DEF PLAYERACTION_UNK40                          EQU $28
DEF PLAYERACTION_UNK41                          EQU $29
DEF PLAYERACTION_DIE_2                          EQU $2A
DEF PLAYERACTION_DIE_WARP_2                     EQU $2B
DEF PLAYERACTION_STAND_ON_TV_BUTTON_2           EQU $2C
DEF PLAYERACTION_ENTER_TV_2                     EQU $2D
DEF PLAYERACTION_UNK26_2                        EQU $2E
DEF PLAYERACTION_SPAWN_3                        EQU $2F
DEF PLAYERACTION_UNK48                          EQU $30
DEF PLAYERACTION_UNK49                          EQU $31
DEF PLAYERACTION_UNK50                          EQU $32
DEF PLAYERACTION_UNK51                          EQU $33
DEF PLAYERACTION_UNK52                          EQU $34
DEF PLAYERACTION_UNK53                          EQU $35
DEF PLAYERACTION_UNK54                          EQU $36
DEF PLAYERACTION_DIE_3                          EQU $37
DEF PLAYERACTION_DIE_WARP_3                     EQU $38
DEF PLAYERACTION_STAND_ON_TV_BUTTON_3           EQU $39
DEF PLAYERACTION_ENTER_TV_3                     EQU $3A
DEF PLAYERACTION_UNK26_3                        EQU $3B
DEF PLAYERACTION_SPAWN_4                        EQU $3C
DEF PLAYERACTION_IDLE_2                         EQU $3D
DEF PLAYERACTION_IDLE_ANIMATION_2               EQU $3E
DEF PLAYERACTION_WALK_2                         EQU $3F
DEF PLAYERACTION_START_CROUCH_2                 EQU $40
DEF PLAYERACTION_OBJECT_NONE_2                  EQU $41
DEF PLAYERACTION_OBJECT_NONE_3                  EQU $42
DEF PLAYERACTION_UNK7_2                         EQU $43
DEF PLAYERACTION_UNK8_2                         EQU $44
DEF PLAYERACTION_TAKE_DAMAGE_2                  EQU $45
DEF PLAYERACTION_DIE_4                          EQU $46
DEF PLAYERACTION_DIE_WARP_4                     EQU $47
DEF PLAYERACTION_STAND_ON_TV_BUTTON_4           EQU $48
DEF PLAYERACTION_ENTER_TV_4                     EQU $49
DEF PLAYERACTION_JUMP_2                         EQU $4A
DEF PLAYERACTION_DOUBLE_JUMP_2                  EQU $4B
DEF PLAYERACTION_TAIL_SPIN_2                    EQU $4C
DEF PLAYERACTION_FALL_2                         EQU $4D
DEF PLAYERACTION_FALLING_LAND_2                 EQU $4E
DEF PLAYERACTION_UNK19_2                        EQU $4F
DEF PLAYERACTION_UNK20_2                        EQU $50
DEF PLAYERACTION_UNK21_TO_24_5                  EQU $51
DEF PLAYERACTION_UNK21_TO_24_6                  EQU $52
DEF PLAYERACTION_UNK21_TO_24_7                  EQU $53
DEF PLAYERACTION_UNK21_TO_24_8                  EQU $54
DEF PLAYERACTION_UNK25_2                        EQU $55
DEF PLAYERACTION_UNK26_4                        EQU $56
DEF PLAYERACTION_DIE_IN_PIT_2                   EQU $57
DEF PLAYERACTION_UNK28_2                        EQU $58
DEF PLAYERACTION_UNK29_2                        EQU $59
DEF PLAYERACTION_UNK30_2                        EQU $5A
DEF PLAYERACTION_UNK31_2                        EQU $5B
DEF PLAYERACTION_UNK32_2                        EQU $5C
DEF PLAYERACTION_UNK33_2                        EQU $5D
DEF PLAYERACTION_UNK34_2                        EQU $5E
DEF PLAYERACTION_SPAWN_5                        EQU $5F
DEF PLAYERACTION_UNK36_2                        EQU $60
DEF PLAYERACTION_UNK37_2                        EQU $61
DEF PLAYERACTION_UNK38_2                        EQU $62
DEF PLAYERACTION_UNK39_2                        EQU $63
DEF PLAYERACTION_UNK40_2                        EQU $64
DEF PLAYERACTION_UNK41_2                        EQU $65
DEF PLAYERACTION_DIE_5                          EQU $66
DEF PLAYERACTION_DIE_WARP_5                     EQU $67
DEF PLAYERACTION_STAND_ON_TV_BUTTON_5           EQU $68
DEF PLAYERACTION_ENTER_TV_5                     EQU $69
DEF PLAYERACTION_UNK26_5                        EQU $6A
DEF PLAYERACTION_SPAWN_6                        EQU $6B
DEF PLAYERACTION_UNK48_2                        EQU $6C
DEF PLAYERACTION_UNK49_2                        EQU $6D
DEF PLAYERACTION_UNK50_2                        EQU $6E
DEF PLAYERACTION_UNK51_2                        EQU $6F
DEF PLAYERACTION_UNK52_2                        EQU $70
DEF PLAYERACTION_UNK53_2                        EQU $71
DEF PLAYERACTION_UNK54_2                        EQU $72
DEF PLAYERACTION_DIE_6                          EQU $73
DEF PLAYERACTION_DIE_WARP_6                     EQU $74
DEF PLAYERACTION_STAND_ON_TV_BUTTON_6           EQU $75
DEF PLAYERACTION_ENTER_TV_6                     EQU $76
DEF PLAYERACTION_UNK26_6                        EQU $77
