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
DEF Bank23_PlayerSpawns       EQU $23 ; where to spawn gex in each map
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

; Levels
DEF Level_GexCave                             EQU $00
DEF Level_HolidayTV                           EQU $01
DEF Level_MysteryTV                           EQU $02
DEF Level_TutTV                               EQU $03
DEF Level_WesternStation                      EQU $04
DEF Level_AnimeChannel                        EQU $05
DEF Level_SuperheroShow                       EQU $06
DEF Level_GextremeSports                      EQU $07
DEF Level_MarsupialMadness                    EQU $08
DEF Level_WWGexWrestling                      EQU $09
DEF Level_LizardOfOz                          EQU $0A
DEF Level_ChannelZ                            EQU $0B
DEF Level_GexCave2                            EQU $0C
; every other value counts as gex cave
