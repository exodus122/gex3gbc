SECTION "wram0", WRAM0[$c000]

wC000_BgMapTileIds:
    ds 1024                                            ;; c000

wC400_CollisionTilesetData: ; C400-CC00 is a copy of 03:4100-03:48FF but in a different order
; that is the collision tileset data, collectible sprites, and number sprites, and some code
    ds 1408                                            ;; c400

wC980_NumberSprites: ; this is the start of the number sprites copied from bank 3
    ds 896                                             ;; c980

wCD00_RowOffsetTableForMap:
    ds 512                                             ;; cd00

wCF00_TileScratchBuffers:
wCF00_MetatileScratchBuffer: ; where block ids from the map data get written temporarily. also where the extended map data is handled
    ds 64                                              ;; cf00
wCF40_TileColumnScratchBuffer:
    ds 64                                              ;; cf40
wCF80_MetatileScratchBuffer2:
    ds 64                                              ;; cf80
wCFC0_TileColumnScratchBuffer2:
    ds 64                                              ;; cfc0

wD000_CollectibleUnusedMemory: ; seems unused?
    ds 128                                             ;; d000
wD080_CollectibleMapNumbers: ; Collectible Map numbers
    ds 128                                             ;; d080
wD100_CollectibleXPositions:
    ds 128                                             ;; d100
wD180_CollectibleYPositions: ; Y coords are replaced by FF when collected
    ds 128
wD200_CollectiblesOrderedByX:
;Scans through wD100 (X table).
; Collectibles are sorted by X coordinate.
; Writes the indices (offsets back into wD100/wD180/wD000_CollectibleUnusedMemory) into wD200.
    ds 256                                             ;; d200
wD300_CollectibleBucketLookupTable:
; Groups collectibles into spatial buckets (~11 X units wide).
; So wD300 = quick lookup of “which collectibles live in this horizontal slice.”
    ds 256                                             ;; d300

wD400_TileBuffer:
    ds 376                                               ;; d400
wD578_TileBuffer2:
    ds 392                                               ;; d578

wD700_ObjectFlags:
; Each byte stores the current flags for each object in the object list for the level
    ds 256

; From D800 to D900 is the loaded objects space
; There are 8 instances of 0x20 bytes each. 
; Object Instance Struct is defined in constants.inc
wD800_ObjectMemory:
wD800_Player_Id:
    ds 1                                               ;; d800
wD801_Player_ActionId:
    ds 1                                               ;; d801
wD802_Player_ActionFunc:
    ds 3                                               ;; d802
wD805_Player_SpriteFlags:
    ds 4                                               ;; d805
wD809_Player_SpriteCounter:
    ds 1                                               ;; d809
wD80A_Player_SpriteId:
    ds 3                                               ;; d80a
wD80D_PlayerFacingDirection:
    ds 1                                               ;; d80d
wD80E_PlayerXPosition:
    ds 2                                               ;; d80e
wD810_PlayerYPosition:
    ds 2                                               ;; d810
    ds 14                                              ;; d811
wD820_ObjectMemoryAfterPlayer:
    ds 32                                              ;; d820
wD840_ObjectMemoryAfterPlayer: ; why does some code use this and not wDB20? maybe wD820 is reserved for a particular object
    ds 32                                              ;; d840
    ds 32 
    ds 32 
    ds 32 
    ds 32 
    ds 32 
; End of Loaded Objects space

wD900:
    ds 1                                               ;; d900

wD901:
    ds 3                                               ;; d901

wD904:
    ds 156                                             ;; d904

; Graphics/Rendering related memory
wD9A0: ; Interrupt code location?
    ds 93                                              ;; d9a0
wD9FD:
    ds 1                                               ;; d9fd
wD9FE:
    ds 1                                               ;; d9fe
wD9FF:
    ds 1                                               ;; d9ff

; DA00 through DA13 stores temporary information about the currently updating object, or used by that object
wDA00_CurrentObjectAddrLo:
; if the object instance starts at $D8E0, this value is E0, for example
    ds 1                                               ;; da00
wDA01_ObjectListIndexesForCurrentObjects:
; stores the entry number in the object list, of all the currently loaded objects
    ds 8                                               ;; da01
wDA09_LoadedObjectIdsBackupBuffer:
    ds 8                                               ;; da09
wDA11_ObjectXDistFromPlayer:
; The distance between the player and the current object
    ds 1                                               ;; da11
wDA12_ObjectDirectionRelativeToPlayer:
; The direction of the current object relative to the player
; 0x00 (OBJECT_LEFT_OF_GEX) = object is to the left of the player
; 0x20 (OBJECT_RIGHT_OF_GEX) = object is to the right of the player
    ds 1                                               ;; da12
wDA13_ObjectXVelocityDelta:
; How much the X Velocity of the current object has changed/(will change?) by
    ds 1                                               ;; da13

; Camera position
wDA14_CameraPos_Left:
    ds 2                                               ;; da14
wDA16_CameraPos_Right:
    ds 2                                               ;; da16
wDA18_CameraPos_Top:
    ds 2                                               ;; da18
wDA1A_CameraPos_Bottom:
    ds 2                                               ;; da1a

; DA1C through DA9B is memory storing constants for each loaded object (8 instances of size 0x10)
; 12 bytes are copied from the object spawn data, but in a different order
; 0x0 wDA1C_ObjectBoundingBoxXMax
; 0x2 wDA1E_ObjectBoundingBoxXMin
; 0x4 wDA20_ObjectBoundingBoxYMin
; 0x6 wDA22_ObjectBoundingBoxYMax
; 0x8 wDA24_ObjectInitialXPos
; 0xA wDA26_ObjectInitialYPos
; 0xC DA28 - unused
; 0xE DA2A - unused
wDA1C_ObjectBoundingBoxXMax:
    ds 2                                               ;; da1c
wDA1E_ObjectBoundingBoxXMin:
    ds 2                                               ;; da1e
wDA20_ObjectBoundingBoxYMin:
    ds 2                                               ;; da20
wDA22_ObjectBoundingBoxYMax:
    ds 2                                               ;; da22
wDA24_ObjectInitialXPos:
    ds 2                                               ;; da24
wDA26_ObjectInitialYPos:
    ds 2
    ds 4

    ds 16                                            ;; da26
    ds 16
    ds 16
    ds 16
    ds 16
    ds 16
    ds 16
; end extra object memory

wDA9C:
    ds 16                                              ;; da9c

wDAAC_CameraXHi: ; Camera X position related
    ds 1                                               ;; daac
wDAAD_CameraYHi: ; Camera Y position related
    ds 1                                               ;; daad

wDAAE_ObjectPaletteIds:
    ds 8                                               ;; daae
wDAB6_SpriteFlags:
    ds 1                                               ;; dab6
wDAB7_ParticleVelocity:
    ds 1                                               ;; dab7
wDAB8_ObjectCounter:
; this starts at 1 and goes up by 1 for each object in the object list for this level
    ds 1                                               ;; dab8
wDAB9_NextAvailableObjectSlot:
; starts at 7 if no objects are currently loaded, then goes to 6 if one is, and so on
    ds 1                                               ;; dab9
wDABA_ObjectCounterRelated:
    ds 1                                               ;; daba
wDABB_CurrentObjectId:
    ds 1                                               ;; dabb
wDABC_CurrentObjectFlags:
; from table at $D700(-$D7FF?)
; default value is $80 on initialization
    ds 1                                               ;; dabc

wDABD_UnkBGCollisionFlags:
    ds 1                                               ;; dabd
wDABE_UnkBGCollisionFlags2:
    ds 1                                               ;; dabe

wDABF_GexSpriteBank:
    ds 1                                               ;; dabf

wDAC0_GeneralPurposeDMASourceAddress:
    ds 2                                               ;; dac0
wDAC2_DMATransferLength:
    ds 1                                               ;; dac2

wDAC3_BankStack:
    ds 16                                              ;; dac3
wDAD3_PtrToBankStackPosition:
    ds 2                                               ;; dad3
wDAD5_CurrentROMBank:
    ds 1                                               ;; dad5
wDAD6_ReturnBank:
    ds 1                                               ;; dad6

wDAD7_CurrentInputs:
    ds 1                                               ;; dad7

wDAD8_LCDControlMirror:
    ds 1                                               ;; dad8
wDAD9_ScrollX:
    ds 1                                               ;; dad9
wDADA_ScrollY:
    ds 1                                               ;; dada
wDADB_WindowX:
    ds 1                                               ;; dadb
wDADC_WindowY:
    ds 1                                               ;; dadc

wDADD: ; menu related
    ds 1                                               ;; dadd

wDADE:
    ds 1                                               ;; dade

wDADF:
    ds 1                                               ;; dadf

wDAE0:
    ds 1                                               ;; dae0

wDAE1_TextBuffer:
    ds 128                                             ;; dae1

; HDMA Transfer related ram
wDB61_ActiveObjectSlot:
    ds 2                                               ;; db61
wDB63_ActiveObjectType:
    ds 1                                               ;; db63
wDB64_VRAMTransferSource:
    ds 2                                               ;; db64
wDB66_HDMATransferFlags:
; Bit 0 set →
; Copy a fixed number of tiles from a general-purpose buffer (wDAC0–wDAC2).
; - Source bank = wDABF_GexSpriteBank.
; - Transfer length = wDAC2_DMATransferLength.
; - Always writes to VRAM bank 0.
; Bit 1 set →
; Copy tiles for the current interaction object.
; - Uses wDB64/65 as the source pointer.
; - Source bank depends on the object’s data (OBJECT_SPRITE_FLAGS_OFFSET, plus a VBK = 1 path if “extended” graphics).
; - Length depends on the object’s type (wDB63_ActiveObjectType).
; - This looks like sprite/animation tiles for NPCs or items.
; Bit 2 set →
; Perform a variable-length streaming transfer.
; - Uses wDC2B–wDC32 as a little “DMA job struct”: source address, destination, length, VRAM bank, and continuation fields.
; - After copying, it updates the struct so the next frame continues where this left off until finished.
; - When finished, clears bit 2.
; - Looks like it’s used for big transfers (maybe level backgrounds, cutscene art, or font pages).
    ds 1                                               ;; db66
wDB67_HDMATempScratch:
    ds 2                                               ;; db67

wDB69:
    ds 1                                               ;; db69

wDB6A:
    ds 1                                               ;; db6a

wDB6B_InterruptFlag:
; gets set when an interrupt occurs. used when waiting for an interrupt
    ds 1                                               ;; db6b

wDB6C_CurrentMapId: ; can freeze and enter level to get to another level
; also used for totals menu pages
    ds 1                                               ;; db6c

wDB6D:
    ds 1                                               ;; db6d

wDB6E:
    ds 1                                               ;; db6e

wDB6F:
    ds 1                                               ;; db6f

wDB70_CollectibleScreenRelativeXOffset:
    ds 1                                               ;; db70
wDB71_CollectibleScreenRelativeYOffset:
    ds 1                                               ;; db71

; Menu-related wRAM starts here
wDB72_PasswordEncodedBuffer:
    ds 1                                               ;; db72
wDB73_PasswordLivesRemaining:
    ds 1                                               ;; db73
wDB74_PasswordPawCoinCounter:
    ds 1                                               ;; db74
wDB75_PasswordPawCoinExtraHealth:
    ds 1                                               ;; db75
wDB76_PasswordEncodedBuffer:
    ds 8                                               ;; db76
wDB7E_PasswordValues:
    ds 18                                              ;; db7e
wDB90_PasswordCounter:
    ds 1                                               ;; db90
wDB91_PasswordCompletionFlag:
    ds 1                                               ;; db91
wDB92_MenuTypeDataPointer:
    ds 2                                               ;; db92
wDB94_MenuTypeData_Unk2:
    ds 1                                               ;; db94
wDB95_MenuTypeData_Unk3:
    ds 1                                               ;; db95
wDB96_MenuTypeData_Unk4:
    ds 1                                               ;; db96
wDB97_MenuTypeData_Unk5:
    ds 1                                               ;; db97
wDB98_MenuTypeData_Unk6:
    ds 1                                               ;; db98
wDB99_MenuTypeData_Unk7:
    ds 2                                               ;; db99
wDB9B_MenuTypeData_Unk9:
    ds 1                                               ;; db9b
wDB9C_MenuDynamicHandlerPtr:
    ds 2                                               ;; db9c
wDB9E_MenuCommandBuffer_Unk0:
    ds 1                                               ;; db9e
wDB9F_MenuCommandBuffer_Unk1:
    ds 1                                               ;; db9f
wDBA0_MenuCommandBuffer_Unk2:
    ds 1                                               ;; dba0
wDBA1_MenuCommandBuffer_Unk3:
    ds 1                                               ;; dba1
wDBA2_MenuCommandBuffer_Unk4:
    ds 1                                               ;; dba2
wDBA3_MenuCommandBuffer_Unk5:
    ds 1                                               ;; dba3
wDBA4_MenuCommandBuffer2_Unk0:
    ds 1                                               ;; dba4
wDBA5_MenuCommandBuffer2_Unk1:
    ds 1                                               ;; dba5
wDBA6_MenuCommandBuffer2_Unk2:
    ds 1                                               ;; dba6
wDBA7_MenuCommandBuffer2_Unk3:
    ds 1                                               ;; dba7
wDBA8_MenuCommandBuffer2_Unk4:
    ds 1                                               ;; dba8
wDBA9_MenuCommandBuffer2_Unk5:
    ds 1                                               ;; dba9
wDBAA_MenuCommandBuffer2_Unk6:
    ds 1                                               ;; dbaa
wDBAB_MenuCommandBuffer3_Unk0:
    ds 2                                               ;; dbab
wDBAD_MenuCommandBuffer3_Unk2:
    ds 2                                               ;; dbad
wDBAF_MenuCommandBuffer3_Unk4:
    ds 1                                               ;; dbaf
wDBB0_MenuCommandBuffer3_Unk5:
    ds 1                                               ;; dbb0
wDBB1_MenuCommandBuffer4_Unk0:
    ds 1                                               ;; dbb1
wDBB2_MenuCommandBuffer4_Bank:
    ds 1                                               ;; dbb2
wDBB3_MenuCommandBuffer4_Unk2:
    ds 2                                               ;; dbb3
wDBB5_MenuCommandBuffer4_Unk4:
    ds 2                                               ;; dbb5
wDBB7_MenuCommandBuffer4_BankOffset:
    ds 2                                               ;; dbb7
wDBB9_MenuUnknownPtr:
    ds 2                                               ;; dbb9
wDBBB:
    ds 1                                               ;; dbbb
wDBBC:
    ds 1                                               ;; dbbc
wDBBD:
    ds 1                                               ;; dbbd
wDBBE:
    ds 1                                               ;; dbbe
wDBBF:
    ds 1                                               ;; dbbf
wDBC0:
    ds 1                                               ;; dbc0
wDBC1:
    ds 1                                               ;; dbc1
wDBC2:
    ds 1                                               ;; dbc2
wDBC3:
    ds 1                                               ;; dbc3
wDBC4:
    ds 1                                               ;; dbc4
wDBC5:
    ds 1                                               ;; dbc5
wDBC6:
    ds 1                                               ;; dbc6
wDBC7:
    ds 1                                               ;; dbc7
wDBC8:
    ds 1                                               ;; dbc8
wDBC9:
    ds 1                                               ;; dbc9
wDBCA:
    ds 1                                               ;; dbca
wDBCB:
    ds 16                                              ;; dbcb
wDBDB:
    ds 1                                               ;; dbdb
wDBDC:
    ds 1                                               ;; dbdc
wDBDD:
    ds 1                                               ;; dbdd
wDBDE:
    ds 1                                               ;; dbde
wDBDF:
    ds 2                                               ;; dbdf
wDBE1:
    ds 1                                               ;; dbe1
wDBE2:
    ds 1                                               ;; dbe2
wDBE3:
    ds 1                                               ;; dbe3
wDBE4:
    ds 1                                               ;; dbe4
wDBE5:
    ds 1                                               ;; dbe5
wDBE6:
    ds 1                                               ;; dbe6
wDBE7:
    ds 1                                               ;; dbe7
wDBE8:
    ds 1                                               ;; dbe8
wDBE9:
    ds 1                                               ;; dbe9
wDBEA_MenuType:
    ds 1                                               ;; dbea
wDBEB_MenuColumnSelected:
    ds 1                                               ;; dbeb
wDBEC_MenuRowSelected:
    ds 1                                               ;; dbec
wDBED_PasswordColumnSelected:
    ds 1                                               ;; dbed
wDBEE_PasswordRowSelected:
    ds 1                                               ;; dbee
wDBEF_UnkCounter:
    ds 1                                               ;; dbef
wDBF0:
    ds 1                                               ;; dbf0
wDBF1:
    ds 1                                               ;; dbf1
wDBF2:
    ds 1                                               ;; dbf2
wDBF3:
    ds 1                                               ;; dbf3
wDBF4:
    ds 1                                               ;; dbf4
wDBF5:
    ds 1                                               ;; dbf5
wDBF6:
    ds 1                                               ;; dbf6
wDBF7:
    ds 1                                               ;; dbf7

wDBF8: ; text related
    ds 1                                               ;; dbf8

; Map-related wRAM starts here
wDBF9_XPositionInMap:
    ds 2                                               ;; dbf9
wDBFB_YPositionInMap:
    ds 2                                               ;; dbfb
wDBFD_XPositionRelated:
    ds 2                                               ;; dbfd
wDBFF_YPositionRelated:
    ds 2                                               ;; dbff

wDC01_MapBank:
    ds 1                                               ;; dc01
wDC02_MapBankOffset:
    ds 2                                               ;; dc02
wDC04_MapExtendedBank:
    ds 1                                               ;; dc04
wDC05_MapExtendedBankOffset:
    ds 2                                               ;; dc05
wDC07_TilesetBank:
    ds 1                                               ;; dc07
wDC08_TilesetBankOffset:
    ds 2                                               ;; dc08
wDC0A_BlocksetBank: 
; also contains palette ids for each block and flags to flip tiles horizontally, vertically, or use second vRAM bank
    ds 1                                               ;; dc0a
wDC0B_BlocksetBankOffset:
    ds 2                                               ;; dc0b
wDC0D_MapCollisionBank:
    ds 1                                               ;; dc0d
wDC0E_MapCollisionBankOffset:
    ds 2                                               ;; dc0e
wDC10_CollisionBlockset:
    ds 1                                               ;; dc10
wDC11_CollisionBlocksetOffset:
    ds 2                                               ;; dc11
wDC13_BgPaletteBank:
   ds 1                                               ;; dc13
wDC14_BgPaletteBankOffset:
    ds 2                                               ;; dc14
wDC16_ObjectListBank:
    ds 1                                               ;; dc16
wDC17_ObjectListBankOffset:
    ds 2                                               ;; dc17
wDC19_CollectibleListBank:
    ds 1                                               ;; dc19
wDC1A_CollectibleListBankOffset:
    ds 2                                               ;; dc1a
wDC1C_CurrentMapWidthAndHeightInBlocks:
    ds 2                                               ;; dc1c
wDC1E_CurrentLevelNumber: ; all maps in the same level share the same value here
    ds 1                                               ;; dc1e

wDC1F:
    ds 1                                               ;; dc1f

wDC20:
    ds 1                                               ;; dc20

wDC21:
    ds 1                                               ;; dc21

wDC22:
    ds 1                                               ;; dc22

wDC23:
    ds 1                                               ;; dc23

wDC24:
    ds 1                                               ;; dc24

wDC25:
    ds 1                                               ;; dc25

wDC26:
    ds 1                                               ;; dc26

wDC27:
    ds 1                                               ;; dc27

wDC28:
    ds 1                                               ;; dc28

wDC29_SkipMapWindowUpdateFlag: ; if set to 1, don't update the player window map
    ds 1                                               ;; dc29

wDC2A_MapBoundaryIndex:
    ds 1                                               ;; dc2a

wDC2B:
    ds 1                                               ;; dc2b
wDC2C:
    ds 1                                               ;; dc2c
wDC2D:
    ds 1                                               ;; dc2d
wDC2E:
    ds 1                                               ;; dc2e
wDC2F:
    ds 2                                               ;; dc2f
wDC31_TilesetBankRelated:
    ds 1                                               ;; dc31
wDC32_VRAMBank:
    ds 1                                               ;; dc32

wDC33_BgMapRelated:
    ds 1                                               ;; dc33

; Map rectangle bounds, and extended ones
wDC34_MapBoundaryXMinLo:
    ds 1                                               ;; dc34
wDC35_MapBoundaryXMinHi:
    ds 1                                               ;; dc35
wDC36_MapBoundaryXMaxLo:
    ds 1                                               ;; dc36
wDC37_MapBoundaryXMaxHi:
    ds 1                                               ;; dc37
wDC38_MapBoundaryYMinLo:
    ds 1                                               ;; dc38
wDC39_MapBoundaryYMinHi:
    ds 1                                               ;; dc39
wDC3A_MapBoundaryYMaxLo:
    ds 1                                               ;; dc3a
wDC3B_MapBoundaryYMaxHi:
    ds 1                                               ;; dc3b
wDC3C_MapBoundaryXMinLoPlus10:
    ds 1                                               ;; dc3c
wDC3D_MapBoundaryXMinHiPlus0:
    ds 1                                               ;; dc3d
wDC3E_MapBoundaryXMaxLoPlus90:
    ds 1                                               ;; dc3e
wDC3F_MapBoundaryXMaxHiPlus0:
    ds 1                                               ;; dc3f
wDC40_MapBoundaryYMinLoPlus10:
    ds 1                                               ;; dc40
wDC41_MapBoundaryYMinHiPlus00:
    ds 1                                               ;; dc41
wDC42_MapBoundaryYMaxLoPlus78:
    ds 1                                               ;; dc42
wDC43_MapBoundaryYMaxHiPlus0:
    ds 1                                               ;; dc43

wDC44:
    ds 8                                               ;; dc44

wDC4C:
    ds 1                                               ;; dc4c

wDC4D:
    ds 1                                               ;; dc4d

wDC4E_PlayerLivesRemaining:
    ds 1                                               ;; dc4e

wDC4F_PawCoinExtraHealth:
    ds 1                                               ;; dc4f

wDC50_PlayerHealth:
    ds 1                                               ;; dc50

wDC51:
    ds 1                                               ;; dc51

wDC52:
    ds 1                                               ;; dc52

wDC53:
    ds 1                                               ;; dc53

wDC54:
    ds 2                                               ;; dc54

wDC56:
    ds 2                                               ;; dc56

wDC58:
    ds 1                                               ;; dc58

wDC59:
    ds 1                                               ;; dc59

wDC5A:
    ds 1                                               ;; dc5a

wDC5B:
    ds 1                                               ;; dc5b

wDC5C_ProgressFlags:
; these keep track of which remotes, paw coins, and bonus coins have been obtained
    ds 9                                               ;; dc5c
wDC65_ProgressFlags_WWGex:
    ds 1                                               ;; dc65
wDC66_ProgressFlags_LizardOfOz:
    ds 1                                               ;; dc66
wDC67_ProgressFlags_ChannelZ: ; 1 = got remote
    ds 1                                               ;; dc67

wDC68_CollectibleCount:
    ds 1                                               ;; dc68

wDC69_PlayerSpawnIdInLevel:
    ds 1                                               ;; dc69

wDC6A_CheckpointStoredX:
    ds 2                                               ;; dc6a
wDC6C_CheckpointStoredY:
    ds 2                                               ;; dc6c

; unused?
    ds 1                                               ;; dc6e

wDC6F:
    ds 1                                               ;; dc6f

wDC70:
    ds 1                                               ;; dc70

wDC71_FrameCounter:
    ds 1                                               ;; dc71

wDC72:
    ds 1                                               ;; dc72

wDC73:
    ds 5                                               ;; dc73

wDC78:
    ds 1                                               ;; dc78

; Misc player variables
wDC79:
    ds 1                                               ;; dc79

wDC7A:
    ds 1                                               ;; dc7a

wDC7B_CurrentObjectAddrLoAlt:
    ds 1                                               ;; dc7b

wDC7C_PlayerCollisionUnusedFlag:
    ds 1                                               ;; dc7c

wDC7D_PlayerCollisionUnkFlag:
    ds 1                                               ;; dc7d

wDC7E_PlayerDamageCooldownTimer:
    ds 1                                               ;; dc7e

wDC7F:
    ds 1                                               ;; dc7f

wDC80:
    ds 1                                               ;; dc80

wDC81_CurrentInputsAlt:
    ds 2                                               ;; dc81

wDC83:
    ds 1                                               ;; dc83

wDC84:
    ds 1                                               ;; dc84

wDC85:
    ds 1                                               ;; dc85

wDC86:
    ds 1                                               ;; dc86

wDC87:
    ds 1                                               ;; dc87

wDC88:
    ds 1                                               ;; dc88

wDC89:
    ds 1                                               ;; dc89

wDC8A:
    ds 1                                               ;; dc8a

wDC8B:
    ds 1                                               ;; dc8b

wDC8C_PlayerYVelocity: ; can freeze to levitate
    ds 1                                               ;; dc8c

wDC8D:
    ds 1                                               ;; dc8d

wDC8E:
    ds 1                                               ;; dc8e

wDC8F:
    ds 1                                               ;; dc8f

wDC90:
    ds 1                                               ;; dc90

wDC91:
    ds 1                                               ;; dc91

wDC92:
    ds 1                                               ;; dc92

wDC93:
    ds 1                                               ;; dc93

wDC94:
    ds 1                                               ;; dc94

wDC95:
    ds 2                                               ;; dc95

wDC97:
    ds 1                                               ;; dc97

wDC98:
    ds 3                                               ;; dc98

wDC9B:
    ds 1                                               ;; dc9b

wDC9C:
    ds 1                                               ;; dc9c

wDC9D:
    ds 1                                               ;; dc9d

wDC9E:
    ds 1                                               ;; dc9e

wDC9F:
    ds 1                                               ;; dc9f

wDCA0_PlayerUnk7:
    ds 1                                               ;; dca0

wDCA1_PlayerUnk6:
    ds 1                                               ;; dca1

wDCA2_PlayerUnk1:
    ds 1                                               ;; dca2
wDCA3_PlayerUnk2:
    ds 1                                               ;; dca3
wDCA4_PlayerUnk3:
    ds 1                                               ;; dca4
wDCA5_PlayerUnk4:
    ds 1                                               ;; dca5
wDCA6_PlayerUnk5:
    ds 1                                               ;; dca6

wDCA7_DrawGexFlag:
    ds 1                                               ;; dca7

wDCA8_FlyTimerOrFlags3:
    ds 1                                               ;; dca8
wDCA9_FlyTimerOrFlags4:
    ds 1                                               ;; dca9
wDCAA_FlyTimerOrFlags1:
    ds 1                                               ;; dcaa
wDCAB_FlyTimerOrFlags2:
    ds 1                                               ;; dcab

wDCAC:
    ds 1                                               ;; dcac
wDCAD:
    ds 1                                               ;; dcad

wDCAE_FlyTimerOrFlags5:
    ds 1                                               ;; dcae

wDCAF_PawCoinCounter: ; for every 4 collected, increment Gex's health
    ds 1                                               ;; dcaf

; unused?
    ds 1

wDCB1:
    ds 16                                              ;; dcb1

wDCC1_EnterDoorRelated1:
    ds 1                                               ;; dcc1
wDCC2_EnterDoorRelated2:
    ds 1                                               ;; dcc2

; Object counters and flags
wDCC3_IceSculptureCounter:
    ds 1                                               ;; dcc3
wDCC4_EvilSantaHealth:
    ds 1                                               ;; dcc4
wDCC5_BloodCoolerCounter:
    ds 1                                               ;; dcc5
wDCC6_LostArkCounter:
    ds 1                                               ;; dcc6
wDCC7_RaStaffCounter:
    ds 1                                               ;; dcc7
wDCC8_ElfCounter:
    ds 1                                               ;; dcc8
wDCC9_AlienCultureTubeCounter:
    ds 1                                               ;; dcc9
wDCCA_StrayCatCounter:
    ds 1                                               ;; dcca
wDCCB_MechCounter:
    ds 1                                               ;; dccb
wDCCC_BellCounter:
    ds 1                                               ;; dccc
wDCCD_ConvictCounter:
    ds 1                                               ;; dccd
wDCCE_BombCounter:
    ds 1                                               ;; dcce
wDCCF_PlayingCardCounter:
    ds 1                                               ;; dccf
wDCD0_MadBomberFlag:
    ds 1                                               ;; dcd0
wDCD1_BrainOfOzFlag:
    ds 1                                               ;; dcd1
wDCD2_FreestandingRemoteHitFlags:
; gets set when a collision occurs with a freestanding remote
; the remote object checks for this flag and sets progressflags
    ds 1                                               ;; dcd2
wDCD3_GhostKnightDamageCounter1:
    ds 1                                               ;; dcd3
wDCD4_GhostKnightDamageCounter2:
    ds 1                                               ;; dcd4
wDCD5_ElfHealth1:
    ds 1                                               ;; dcd5
wDCD6_ElfHealth2:
    ds 1                                               ;; dcd6
wDCD7_ElfHealth3:
    ds 1                                               ;; dcd7
wDCD8_ElfHealth4:
    ds 1                                               ;; dcd8
wDCD9_ElfHealth5:
    ds 1                                               ;; dcd9
wDCDA_BrainOfOzAndRezCounter:
    ds 1                                               ;; dcda
wDCDB_EvilSantaHitByProjectileFlag:
    ds 1                                               ;; dcdb
wDCDC_HandObjectUnkFlag:
    ds 2                                               ;; dcdc

; Mission Preview Cutscene flags
wDCDE_MissionPreviewCutsceneRelated:
    ds 2                                                ;; dcde
wDCE0_MissionPreviewCutsceneMovementFlags:
    ds 2                                               ;; dce0

; Elevator object data
wDCE2_ElevatorObjectUnkData:
    ds 6                                               ;; dce2

; Object spawning related flags
wDCE8:
    ds 1                                               ;; dce8
wDCE9:
    ds 1                                               ;; dce9

; Palletes and related flags
wDCEA_BgPalettes:
    ds 32                                              ;; dcea
wDD0A_BgPalettes:
    ds 32                                              ;; dd0a
wDD2A_ObjectPalettes:
    ds 32                                              ;; dd2a
wDD4A_ObjectPalettes:
    ds 32                                              ;; dd4a
wDD6A_GameBoyColorPaletteFlag: ; determines if colored palettes will be used
    ds 1                                               ;; dd6a

wDD6B: ; unused except set to 0?
    ds 1
    
; unused section?
    ds 88                                             ;; dd6b

; Particle buffer
wDDC4_ParticleSlot1Buffer:
    ds 19
wDDD7_ParticleSlot2Buffer:
    ds 19
wDDEA_ParticleSlot3Buffer:
    ds 19
wDDFD_ParticleSlot4Buffer:
    ds 19
wDE10_ParticleSlot5Buffer:
    ds 19
wDE23_ParticleSlot6Buffer:
    ds 19
wDE36_ParticleSlot7Buffer:
    ds 19
wDE49_ParticleSlot8Buffer:
    ds 19

; Start of Audio wRAM section
wDE5C_CurrentSong:
    ds 1                                               ;; de5c
wDE5D_QueuedSoundEffect:
    ds 1                                               ;; de5d
wDE5E_QueuedSoundEffectPriority:
    ds 1                                               ;; de5e
wDE5F_CurrentSoundEffectPriority:
    ds 1                                               ;; de5f
wDE60_AudioBankCurrent:
    ds 1                                               ;; de60
    
; unused section?
    ds 159                                             ;; de61

; Start of Bank 04-05 audio ram
wDF00:
    ds 1                                               ;; df00

wDF01:
    ds 1                                               ;; df01

wDF02:
    ds 1                                               ;; df02

wDF03:
    ds 1                                               ;; df03

wDF04:
    ds 1                                               ;; df04

wDF05:
    ds 5                                               ;; df05

wDF0A:
    ds 1                                               ;; df0a

wDF0B:
    ds 2                                               ;; df0b

wDF0D:
    ds 1                                               ;; df0d

wDF0E:
    ds 2                                               ;; df0e

wDF10:
    ds 1                                               ;; df10

wDF11:
    ds 1                                               ;; df11

wDF12:
    ds 2                                               ;; df12

wDF14:
    ds 1                                               ;; df14

wDF15:
    ds 3                                               ;; df15

wDF18:
    ds 1                                               ;; df18

wDF19:
    ds 1                                               ;; df19

wDF1A:
    ds 1                                               ;; df1a

wDF1B:
    ds 1                                               ;; df1b

wDF1C:
    ds 1                                               ;; df1c

wDF1D:
    ds 5                                               ;; df1d

wDF22:
    ds 1                                               ;; df22

wDF23:
    ds 2                                               ;; df23

wDF25:
    ds 1                                               ;; df25

wDF26:
    ds 2                                               ;; df26

wDF28:
    ds 1                                               ;; df28

wDF29:
    ds 1                                               ;; df29

wDF2A:
    ds 2                                               ;; df2a

wDF2C:
    ds 1                                               ;; df2c

wDF2D:
    ds 3                                               ;; df2d

wDF30:
    ds 1                                               ;; df30

wDF31:
    ds 1                                               ;; df31

wDF32:
    ds 1                                               ;; df32

wDF33:
    ds 1                                               ;; df33

wDF34:
    ds 1                                               ;; df34

wDF35:
    ds 5                                               ;; df35

wDF3A:
    ds 1                                               ;; df3a

wDF3B:
    ds 2                                               ;; df3b

wDF3D:
    ds 1                                               ;; df3d

wDF3E:
    ds 2                                               ;; df3e

wDF40:
    ds 1                                               ;; df40

wDF41:
    ds 1                                               ;; df41

wDF42:
    ds 2                                               ;; df42

wDF44:
    ds 1                                               ;; df44

wDF45:
    ds 3                                               ;; df45

wDF48:
    ds 1                                               ;; df48

wDF49:
    ds 1                                               ;; df49

wDF4A:
    ds 1                                               ;; df4a

wDF4B:
    ds 2                                               ;; df4b

wDF4D:
    ds 5                                               ;; df4d

wDF52:
    ds 1                                               ;; df52

wDF53:
    ds 2                                               ;; df53

wDF55:
    ds 1                                               ;; df55

wDF56:
    ds 1                                               ;; df56

wDF57:
    ds 5                                               ;; df57

wDF5C:
    ds 1                                               ;; df5c

wDF5D:
    ds 3                                               ;; df5d

wDF60:
    ds 1                                               ;; df60

wDF61:
    ds 1                                               ;; df61

wDF62:
    ds 2                                               ;; df62

wDF64:
    ds 1                                               ;; df64

wDF65:
    ds 1                                               ;; df65

wDF66:
    ds 1                                               ;; df66

wDF67:
    ds 1                                               ;; df67

wDF68:
    ds 1                                               ;; df68

wDF69:
    ds 1                                               ;; df69

wDF6A:
    ds 1                                               ;; df6a

wDF6B:
    ds 1                                               ;; df6b

wDF6C:
    ds 1                                               ;; df6c

wDF6D:
    ds 1                                               ;; df6d

wDF6E:
    ds 1                                               ;; df6e

wDF6F:
    ds 1                                               ;; df6f

wDF70:
    ds 1                                               ;; df70

wDF71:
    ds 1                                               ;; df71

wDF72:
    ds 1                                               ;; df72

wDF73:
    ds 1                                               ;; df73

wDF74:
    ds 1                                               ;; df74

wDF75:
    ds 1                                               ;; df75

wDF76:
    ds 1                                               ;; df76

wDF77:
    ds 1                                               ;; df77

wDF78:
    ds 1                                               ;; df78

wDF79:
    ds 1                                               ;; df79

wDF7A:
    ds 1                                               ;; df7a

wDF7B:
    ds 1                                               ;; df7b

wDF7C:
    ds 1                                               ;; df7c

wDF7D:
    ds 1                                               ;; df7d

wDF7E:
    ds 130                                             ;; df7e

SECTION "hram", HRAM[$ff80]

hFF80:
    ds 112                                             ;; ff80
hFFF0:
    ds 12                                              ;; fff0
hFFFC:
    ds 1                                               ;; fffc
hFFFD:
    ds 1                                               ;; fffd
hFFFE:
    ds 1                                               ;; fffe

SECTION "vram", VRAM[$8000]
    ds 8192                                            ;; 8000

SECTION "sram", SRAM[$a000]
    ds 8192                                            ;; a000
