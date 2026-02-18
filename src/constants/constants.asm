; MBC1
DEF MBC1SRamEnable      EQU $0001
DEF MBC1RomBank         EQU $2001
DEF MBC1SRamBank        EQU $4001
DEF MBC1SRamBankingMode EQU $6001

; ROM Banks
DEF Bank00_Home               EQU $00
DEF Bank01_Menus              EQU $01
DEF Bank02_Objects            EQU $02
DEF Bank03_CollisionGraphics  EQU $03
DEF Bank04_Audio1             EQU $04
DEF Bank05_Audio2             EQU $05
DEF Bank06                    EQU $06
DEF Bank07                    EQU $07
DEF Bank08                    EQU $08
DEF Bank09                    EQU $09
DEF Bank0a                    EQU $0a
DEF Bank0b                    EQU $0b
DEF Bank0c                    EQU $0c
DEF Bank0d                    EQU $0d
DEF Bank0e                    EQU $0e
DEF Bank0f                    EQU $0f
DEF Bank10                    EQU $10
DEF Bank11                    EQU $11
DEF Bank1c_Text               EQU $1c
DEF Bank1d                    EQU $1d
DEF Bank1e                    EQU $1e
DEF Bank1f                    EQU $1f
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

DEF Bank7f                    EQU $7f ; object sprite and palette data

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
DEF Map_GexCave1                  EQU $00
DEF Map_HolidayTV1                EQU $01
DEF Map_MysteryTV1                EQU $02
DEF Map_TutTV1                    EQU $03
DEF Map_WesternStation1           EQU $04
DEF Map_AnimeChannel1             EQU $05
DEF Map_SuperheroShow1            EQU $06
DEF Map_GextremeSports1           EQU $07
DEF Map_MarsupialMadness1         EQU $08
DEF Map_WWGexWrestling1           EQU $09
DEF Map_LizardOfOz1               EQU $0A
DEF Map_ChannelZ1                 EQU $0B
DEF Map_GexCave2                  EQU $0C
DEF Map_GexCave3                  EQU $0D
DEF Map_GexCave4                  EQU $0E
DEF Map_HolidayTV2                EQU $0F
DEF Map_HolidayTV3                EQU $10
DEF Map_HolidayTV4                EQU $11
DEF Map_MysteryTV2                EQU $12
DEF Map_MysteryTV3                EQU $13
DEF Map_MysteryTV4                EQU $14
DEF Map_MysteryTV5                EQU $15
DEF Map_MysteryTV6                EQU $16
DEF Map_MysteryTV7                EQU $17
DEF Map_MysteryTV8                EQU $18
DEF Map_MysteryTV9                EQU $19
DEF Map_MysteryTV10               EQU $1A
DEF Map_TutTV2                    EQU $1B
DEF Map_TutTV3                    EQU $1C
DEF Map_TutTV4                    EQU $1D
DEF Map_TutTV5                    EQU $1E
DEF Map_TutTV6                    EQU $1F
DEF Map_TutTV7                    EQU $20
DEF Map_WesternStation2           EQU $21
DEF Map_WesternStation3           EQU $22
DEF Map_WesternStation4           EQU $23
DEF Map_WesternStation5           EQU $24
DEF Map_WesternStation6           EQU $25
DEF Map_WesternStation7           EQU $26
DEF Map_WesternStation8           EQU $27
DEF Map_WesternStation9           EQU $28
DEF Map_AnimeChannel2             EQU $29
DEF Map_AnimeChannel3             EQU $2A
DEF Map_AnimeChannel4             EQU $2B
DEF Map_AnimeChannel5             EQU $2C
DEF Map_AnimeChannel6             EQU $2D
DEF Map_AnimeChannel7             EQU $2E
DEF Map_AnimeChannel8             EQU $2F
DEF Map_AnimeChannel9             EQU $30
DEF Map_SuperheroShow2            EQU $31
DEF Map_SuperheroShow3            EQU $32
DEF Map_SuperheroShow4            EQU $33
DEF Map_SuperheroShow5            EQU $34
DEF Map_SuperheroShow6            EQU $35
DEF Map_GextremeSports2           EQU $36
DEF Map_GextremeSports3           EQU $37
DEF Map_GextremeSports4           EQU $38
DEF Map_ChannelZ2                 EQU $39
DEF Map_ChannelZ3                 EQU $3A
DEF Map_ChannelZ4                 EQU $3B
DEF Map_ChannelZ5                 EQU $3C

; Objects
DEF Object_Gex                                         EQU $00
DEF Object_BonusCoin                                   EQU $01
DEF Object_FlyCoinSpawn                                EQU $02
DEF Object_PawCoin                                     EQU $03
DEF Object_unk04                                       EQU $04 ; probably tv fly
DEF Object_unk05                                       EQU $05 ; probably tv fly
DEF Object_unk06                                       EQU $06 ; probably tv fly
DEF Object_unk07                                       EQU $07 ; probably tv fly
DEF Object_unk08                                       EQU $08 ; probably tv fly
DEF Object_GreenFlyTV                                  EQU $09
DEF Object_PurpleFlyTV                                 EQU $0A
DEF Object_unk0B                                       EQU $0B
DEF Object_BlueFlyTV                                   EQU $0C
DEF Object_unk0D                                       EQU $0D
DEF Object_unk0E                                       EQU $0E
DEF Object_unk0F                                       EQU $0F
DEF Object_unk10                                       EQU $10
DEF Object_TVButton                                    EQU $11
DEF Object_TVRemote                                    EQU $12
DEF Object_unk13                                       EQU $13
DEF Object_GoalCounter                                 EQU $14
DEF Object_unk15                                       EQU $15
DEF Object_unk16                                       EQU $16
DEF Object_unk17                                       EQU $17
DEF Object_unk18                                       EQU $18
DEF Object_unk19                                       EQU $19
DEF Object_unk1A                                       EQU $1A
DEF Object_BonusStageTimer                             EQU $1B
DEF Object_FreestandingRemote                          EQU $1C
DEF Object_HolidayTV_IceSculpture                      EQU $1D
DEF Object_HolidayTV_EvilSanta                         EQU $1E
DEF Object_HolidayTV_EvilSantaProjectile               EQU $1F
DEF Object_HolidayTV_SkatingElf                        EQU $20
DEF Object_HolidayTV_Penguin                           EQU $21
DEF Object_MysteryTV_Rezling                           EQU $22
DEF Object_MysteryTV_BloodCooler                       EQU $23
DEF Object_MysteryTV_Fish                              EQU $24
DEF Object_MysteryTV_MagicSword                        EQU $25
DEF Object_MysteryTV_SafariSam                         EQU $26
DEF Object_MysteryTV_SafariSamProjectile               EQU $27
DEF Object_MysteryTV_GhostKnight                       EQU $28
DEF Object_MysteryTV_GhostKnightProjectile             EQU $29
DEF Object_TutTV_Hand                                  EQU $2A
DEF Object_TutTV_LostArk                               EQU $2B
DEF Object_TutTV_RisingPlatform                        EQU $2C
DEF Object_TutTV_SidewaysPlatform                      EQU $2D
DEF Object_TutTV_Bee                                   EQU $2E
DEF Object_TutTV_Raft                                  EQU $2F
DEF Object_TutTV_SnakeFacingRight                      EQU $30
DEF Object_TutTV_SnakeFacingLeft                       EQU $31
DEF Object_TutTV_SnakeRightProjectile                  EQU $32
DEF Object_TutTV_SnakeLeftProjectile                   EQU $33
DEF Object_TutTV_RaStaff                               EQU $34
DEF Object_TutTV_RaStatueHorizontalProjectile          EQU $35
DEF Object_TutTV_RaStatueDiagonalProjectile            EQU $36
DEF Object_TutTV_BreakableBlock                        EQU $37
DEF Object_TutTV_Coffin                                EQU $38
DEF Object_WesternStation_Cactus                       EQU $39
DEF Object_unk3A                                       EQU $3A
DEF Object_WesternStation_RockPlatform                 EQU $3B
DEF Object_WesternStation_HardHat                      EQU $3C
DEF Object_WesternStation_PlayingCard                  EQU $3D
DEF Object_WesternStation_Bat                          EQU $3E
DEF Object_WesternStation_RisingPlatform               EQU $3F
DEF Object_AnimeChannel_Door                           EQU $40
DEF Object_AnimeChannel_Door2                          EQU $41
DEF Object_AnimeChannel_FanLift                        EQU $42
DEF Object_AnimeChannel_MechFacingRight                EQU $43
DEF Object_AnimeChannel_MechFacingLeft                 EQU $44
DEF Object_AnimeChannel_DisappearingFloor              EQU $45
DEF Object_AnimeChannel_OnSwitch2                      EQU $46
DEF Object_AnimeChannel_AlienCultureTube               EQU $47
DEF Object_AnimeChannel_BlueBeamBarrier                EQU $48
DEF Object_AnimeChannel_RisingPlatform                 EQU $49
DEF Object_AnimeChannel_OnSwitch                       EQU $4A
DEF Object_AnimeChannel_OffSwitch                      EQU $4B
DEF Object_AnimeChannel_SailorToonGirl                 EQU $4C
DEF Object_AnimeChannel_BigSilverRobot                 EQU $4D
DEF Object_AnimeChannel_SmallBlueRobot                 EQU $4E
DEF Object_AnimeChannel_Secbot                         EQU $4F
DEF Object_AnimeChannel_SecbotProjectile               EQU $50
DEF Object_AnimeChannel_Elevator                       EQU $51
DEF Object_AnimeChannel_FireWallEnemy                  EQU $52
DEF Object_AnimeChannel_Grenade                        EQU $53
DEF Object_AnimeChannel_PlanetOBlastWeapon             EQU $54
DEF Object_SuperheroShow_MadBomber                     EQU $55
DEF Object_SuperheroShow_Bomb                          EQU $56
DEF Object_SuperheroShow_WaterTowerTank                EQU $57
DEF Object_SuperheroShow_WaterTowerStand               EQU $58
DEF Object_SuperheroShow_Convict                       EQU $59
DEF Object_SuperheroShow_Spider                        EQU $5A
DEF Object_SuperheroShow_StrayCat                      EQU $5B
DEF Object_SuperheroShow_YellowGoon                    EQU $5C
DEF Object_SuperheroShow_Rat                           EQU $5D
DEF Object_SuperheroShow_ChomperTV                     EQU $5E
DEF Object_SuperheroShow_CrumblingFloor                EQU $5F
DEF Object_SuperheroShow_ConvictProjectile             EQU $60
DEF Object_GextremeSports_Elf                          EQU $61
DEF Object_GextremeSports_BonusTimeCoin                EQU $62
DEF Object_MarsupialMadness_Bell                       EQU $63
DEF Object_MarsupialMadness_Bird                       EQU $64
DEF Object_MarsupialMadness_BirdProjectile             EQU $65
DEF Object_WWGexWrestling_RockHard                     EQU $66
DEF Object_LizardOfOz_BrainOfOz                        EQU $67
DEF Object_LizardOfOz_CannonProjectile                 EQU $68
DEF Object_LizardOfOz_Cannon                           EQU $69
DEF Object_LizardOfOz_BrainOfOzProjectile              EQU $6A
DEF Object_unk6B                                       EQU $6B
DEF Object_unk6C                                       EQU $6C
DEF Object_unk6D                                       EQU $6D
DEF Object_ChannelZ_Rez                                EQU $6E
DEF Object_unk6F                                       EQU $6F
DEF Object_ChannelZ_Meteor                             EQU $70
DEF Object_ChannelZ_RezProjectile                      EQU $71
DEF ObjectListTerminator                               EQU $FF

; Object Instance Struct
DEF OBJECT_ID_OFFSET                        EQU $00
DEF OBJECT_ACTIONID_OFFSET                  EQU $01
DEF OBJECT_ACTIONPTR_OFFSET                 EQU $02
DEF OBJECT_SPRITE_FLAGS2_OFFSET             EQU $04
DEF OBJECT_SPRITE_FLAGS_OFFSET              EQU $05
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
DEF OBJECT_UNK15_OFFSET                     EQU $15 ; collision related, starts as 0
DEF OBJECT_UNK16_OFFSET                     EQU $16 ; collision related, starts as [4] into data_00_3258, minus 1
DEF OBJECT_SPRITE_BANK_OFFSET               EQU $17
DEF OBJECT_UNK18_OFFSET                     EQU $18 ; starts as 0
DEF OBJECT_EXTRA_FLAGS_OFFSET               EQU $19 ; only used by moving platforms, skating elf health, and sec bot (?)
                                                    ; starts as [5] into data_00_3258
DEF OBJECT_TIMER1A_OFFSET                   EQU $1A
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
DEF OBJECTSPAWN_FLAGS_OFFSET                EQU $0D ; usually instance id, but sometimes contains other data
DEF OBJECTSPAWN_MAP_OFFSET                  EQU $0F

; Object Facing Direction values
DEF OBJECT_FACING_RIGHT      EQU $00
DEF OBJECT_FACING_LEFT       EQU $20
DEF OBJECT_FACING_UNK40      EQU $40

; Object position relative to Gex
DEF OBJECT_LEFT_OF_GEX       EQU $00
DEF OBJECT_RIGHT_OF_GEX      EQU $20

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
DEF SFX_UNK00                              EQU $00
DEF SFX_UNK01                              EQU $01
DEF SFX_ITEM_PICKUP                        EQU $02 ; fly coins, paw coins, bonus coins
DEF SFX_FLY_TV                             EQU $03
DEF SFX_UNK04                              EQU $04
DEF SFX_UNK05                              EQU $05
DEF SFX_UNK06                              EQU $06
DEF SFX_UNK07                              EQU $07
DEF SFX_UNK08                              EQU $08
DEF SFX_UNK09                              EQU $09
DEF SFX_PLAYER_DAMAGED                     EQU $0A
DEF SFX_UNK0B                              EQU $0B
DEF SFX_UNK0C                              EQU $0C
DEF SFX_UNK0D                              EQU $0D
DEF SFX_GEX_SPAWN                          EQU $0E
DEF SFX_GEX_HIT1                           EQU $0F
DEF SFX_GEX_HIT2                           EQU $10
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

; Collision Types
DEF CollisionType_None                    EQU $00
DEF CollisionType_Platform                EQU $01
DEF CollisionType_DamageUnderwater        EQU $02 ; player is damaged, but do not change player's action or position
DEF CollisionType_DamageAndDestroy        EQU $03 ; player is damaged, and the object is destroyed
DEF CollisionType_DamageAndRemain         EQU $04 ; player is damaged, but the object remains loaded
DEF CollisionType_unk05                   EQU $05 ; seems unused
DEF CollisionType_unk06                   EQU $06 ; seems unused
DEF CollisionType_BonusCoin               EQU $07
DEF CollisionType_FlyCoin                 EQU $08
DEF CollisionType_PawCoin                 EQU $09
DEF CollisionType_Fly                     EQU $0A
DEF CollisionType_FlyTV                   EQU $0B
DEF CollisionType_IceSculpture            EQU $0C
DEF CollisionType_EvilSantaProjectile     EQU $0D
DEF CollisionType_HolidayTV_Elf           EQU $0E
DEF CollisionType_BloodCooler             EQU $0F
DEF CollisionType_MagicSword              EQU $10
DEF CollisionType_GhostKnight             EQU $11
DEF CollisionType_Hand                    EQU $12
DEF CollisionType_LostArk                 EQU $13
DEF CollisionType_RaStaff                 EQU $14
DEF CollisionType_Coffin                  EQU $15
DEF CollisionType_AlienCultureTube        EQU $16
DEF CollisionType_OnSwitch                EQU $17
DEF CollisionType_OffSwitch               EQU $18
DEF CollisionType_OnSwitch2               EQU $19
DEF CollisionType_Door                    EQU $1A
DEF CollisionType_Door2                   EQU $1B
DEF CollisionType_Secbot                  EQU $1C
DEF CollisionType_SailorToonGirl          EQU $1D
DEF CollisionType_BigSilverRobot          EQU $1E
DEF CollisionType_Mech                    EQU $1F
DEF CollisionType_PlanetOBlast            EQU $20
DEF CollisionType_StrayCat                EQU $21
DEF CollisionType_Convict                 EQU $22
DEF CollisionType_YellowGoon              EQU $23
DEF CollisionType_ChomperTV               EQU $24
DEF CollisionType_Bomb                    EQU $25
DEF CollisionType_WaterTowerStand         EQU $26
DEF CollisionType_GextremeSports_Elf      EQU $27
DEF CollisionType_BonusTimeCoin           EQU $28
DEF CollisionType_Bell                    EQU $29
DEF CollisionType_Cannon                  EQU $2A
DEF CollisionType_BrainOfOz               EQU $2B
DEF CollisionType_BrainOfOzProjectile     EQU $2C
DEF CollisionType_FreestandingRemote      EQU $2D
DEF CollisionType_Cactus                  EQU $2E
DEF CollisionType_PlayingCard             EQU $2F
DEF CollisionType_HardHat                 EQU $30
DEF CollisionType_Meteor                  EQU $31
DEF CollisionType_Rez                     EQU $32
DEF CollisionType_TVButton                EQU $33
DEF CollisionType_RaStatueProjectile      EQU $34
DEF CollisionType_RockHard                EQU $35
DEF CollisionType_PlatformWithFlag        EQU $81
