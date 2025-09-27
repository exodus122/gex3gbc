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
DEF Bank36_MapCollision        EQU $36
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

; Inputs
DEF Input_A        EQU $01
DEF Input_B        EQU $02
DEF Input_Select   EQU $04
DEF Input_Start    EQU $08
DEF Input_Right    EQU $10
DEF Input_Left     EQU $20
DEF Input_Up       EQU $40
DEF Input_Down     EQU $80

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
DEF Object_MysteryTV_TVEnemy                           EQU $22
DEF Object_MysteryTV_BloodCooler                       EQU $23
DEF Object_MysteryTV_FishEnemy                         EQU $24
DEF Object_MysteryTV_MagicSword                        EQU $25
DEF Object_MysteryTV_GunnerEnemy                       EQU $26
DEF Object_MysteryTV_GunnerBullet                      EQU $27
DEF Object_MysteryTV_KnightBoss                        EQU $28
DEF Object_MysteryTV_KnightBossProjectile              EQU $29
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
DEF Object_WesternStation_WalkerEnemy                  EQU $3C
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
DEF Object_AnimeChannel_PinkGirl                       EQU $4C
DEF Object_AnimeChannel_BigSilverRobot                 EQU $4D
DEF Object_AnimeChannel_SmallBlueRobot                 EQU $4E
DEF Object_AnimeChannel_TankPlane                      EQU $4F
DEF Object_AnimeChannel_TankPlaneProjectile            EQU $50
DEF Object_AnimeChannel_Elevator                       EQU $51
DEF Object_AnimeChannel_FireWallEnemy                  EQU $52
DEF Object_AnimeChannel_FallingYellowEnemy             EQU $53
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
DEF Object_SuperheroShow_FlyingRobotHead               EQU $5E
DEF Object_SuperheroShow_FalseFloor                    EQU $5F
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
DEF Object_LizardOfOz_RockProjectile                   EQU $6A
DEF Object_unk6B                                       EQU $6B
DEF Object_unk6C                                       EQU $6C
DEF Object_unk6D                                       EQU $6D
DEF Object_ChannelZ_Rez                                EQU $6E
DEF Object_unk6F                                       EQU $6F
DEF Object_ChannelZ_Meteor                             EQU $70
DEF Object_ChannelZ_RockProjectile                     EQU $71

; Object Instance Struct
DEF OBJECT_ID_OFFSET                  EQU $00
DEF OBJECT_ACTIONID_OFFSET            EQU $01
DEF OBJECT_ACTIONPTR_OFFSET           EQU $02
DEF OBJECT_FLAGS_OFFSET               EQU $04
DEF OBJECT_UNK05_OFFSET               EQU $05
DEF OBJECT_UNK09_OFFSET               EQU $09
DEF OBJECT_UNK0A_OFFSET               EQU $0A
DEF OBJECT_FACINGDIRECTION_OFFSET     EQU $0D
DEF OBJECT_XPOS_OFFSET                EQU $0E
DEF OBJECT_YPOS_OFFSET                EQU $10
DEF OBJECT_WIDTH_OFFSET               EQU $12
DEF OBJECT_HEIGHT_OFFSET              EQU $13
DEF OBJECT_UNK14_OFFSET               EQU $14
DEF OBJECT_UNK15_OFFSET               EQU $15 ; collision related
DEF OBJECT_UNK16_OFFSET               EQU $16
DEF OBJECT_UNK19_OFFSET               EQU $19
DEF OBJECT_UNK1A_OFFSET               EQU $1A
DEF OBJECT_XVEL_OFFSET                EQU $1B
DEF OBJECT_YVEL_OFFSET                EQU $1D
DEF OBJECT_UNK1F_OFFSET               EQU $1F ; collision related

; Object Facing Direction values
DEF OBJECT_FACING_RIGHT      EQU $00
DEF OBJECT_FACING_LEFT       EQU $20
DEF OBJECT_FACING_UNK40      EQU $40

; Object position relative to Gex
DEF OBJECT_LEFT_OF_GEX       EQU $00
DEF OBJECT_RIGHT_OF_GEX      EQU $20
