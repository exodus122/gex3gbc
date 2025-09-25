SECTION "wram0", WRAM0[$c000]

wC000_BgMapTileIds:
    ds 1                                            ;; c000
wC001_BgMapTileIds:
    ds 1023                                         ;; c001

wC400: ; C400-CC00 is a copy of 03:4100-03:48FF but in a different order
; that is the collision tileset data, collectible sprites, and number sprites, and some code
    ds 1408                                            ;; c400

wC980_NumbersSprites: ; this is the start of the number sprites from bank 3
    ds 896                                             ;; c980

wCD00_RowOffsetTableForMap:
    ds 512                                             ;; cd00

wCF00: ; where block ids from the map data get written temporarily. also where the extended map data is handled
    ds 64                                              ;; cf00

wCF40:
    ds 64                                              ;; cf40

wCF80:
    ds 64                                              ;; cf80

wCFC0:
    ds 192                                            ;; cfc0

wD080: ; Collectible Map numbers
    ds 128

wD100: ; Collectible X and Y coordinates. 128 bytes of X, then 128 bytes of Y. Y coords are set to FF when collected
    ds 256                                             ;; d100

wD200:
    ds 512                                             ;; d200

wD400:
    ds 1                                               ;; d400

wD401:
    ds 375                                             ;; d401

wD578:
    ds 1                                               ;; d578

wD579:
    ds 647                                             ;; d579

; From D800 to D900 is the loaded objects space

wD800_PlayerObject_Id:
    ds 1                                               ;; d800

wD801_PlayerObject_ActionId:
    ds 1                                               ;; d801

wD802_PlayerObject_ActionFunc:
    ds 3                                               ;; d802

wD805:
    ds 4                                               ;; d805

wD809:
    ds 1                                               ;; d809

wD80A:
    ds 3                                               ;; d80a

wD80D_PlayerFacingDirection:
    ds 1                                               ;; d80d

wD80E_PlayerXPosition:
    ds 1                                               ;; d80e

wD80F_PlayerXPosition:
    ds 1                                               ;; d80f

wD810_PlayerYPosition:
    ds 1                                               ;; d810

wD811_PlayerYPosition:
    ds 15                                              ;; d811

wD820:
    ds 32                                              ;; d820

wD840:
    ds 192                                             ;; d840

; End of Loaded Objects space

wD900:
    ds 1                                               ;; d900

wD901:
    ds 3                                               ;; d901

wD904:
    ds 156                                             ;; d904

wD9A0:
; Interrupt code location?
    ds 93                                              ;; d9a0

wD9FD:
    ds 1                                               ;; d9fd

wD9FE:
    ds 1                                               ;; d9fe

wD9FF:
    ds 1                                               ;; d9ff

wDA00_CurrentObjectAddr:
    ds 1                                               ;; da00

wDA01:
    ds 8                                               ;; da01

wDA09:
    ds 8                                               ;; da09

wDA11:
    ds 1                                               ;; da11

wDA12:
    ds 1                                               ;; da12

wDA13:
    ds 1                                               ;; da13

wDA14:
    ds 1                                               ;; da14

wDA15:
    ds 1                                               ;; da15

wDA16:
    ds 1                                               ;; da16

wDA17:
    ds 1                                               ;; da17

wDA18:
    ds 1                                               ;; da18

wDA19:
    ds 1                                               ;; da19

wDA1A:
    ds 1                                               ;; da1a

wDA1B:
    ds 1                                               ;; da1b

wDA1C:
    ds 2                                               ;; da1c

wDA1E:
    ds 2                                               ;; da1e

wDA20:
    ds 2                                               ;; da20

wDA22:
    ds 2                                               ;; da22

wDA24:
    ds 2                                               ;; da24

wDA26:
    ds 118                                             ;; da26

wDA9C:
    ds 16                                              ;; da9c

wDAAC:
    ds 1                                               ;; daac

wDAAD:
    ds 1                                               ;; daad

wDAAE_ObjectPaletteIds:
    ds 8                                               ;; daae

wDAB6:
    ds 1                                               ;; dab6

wDAB7:
    ds 1                                               ;; dab7

wDAB8:
    ds 1                                               ;; dab8

wDAB9:
    ds 1                                               ;; dab9

wDABA:
    ds 1                                               ;; daba

wDABB:
    ds 1                                               ;; dabb

wDABC:
    ds 1                                               ;; dabc

wDABD:
    ds 1                                               ;; dabd

wDABE:
    ds 1                                               ;; dabe

wDABF_GexSpriteBank:
    ds 1                                               ;; dabf

wDAC0:
    ds 1                                               ;; dac0

wDAC1:
    ds 1                                               ;; dac1

wDAC2:
    ds 1                                               ;; dac2

wDAC3:
    ds 16                                              ;; dac3

wDAD3:
    ds 2                                               ;; dad3

wDAD5:
    ds 1                                               ;; dad5

wDAD6_ReturnBank:
    ds 1                                               ;; dad6

wDAD7_CurrentInputs:
    ds 1                                               ;; dad7

wDAD8_LCDControlMirror:
    ds 1                                               ;; dad8

wDAD9:
    ds 1                                               ;; dad9

wDADA:
    ds 1                                               ;; dada

wDADB:
    ds 1                                               ;; dadb

wDADC:
    ds 1                                               ;; dadc

wDADD: ; text buffer
    ds 1                                               ;; dadd

wDADE:
    ds 1                                               ;; dade

wDADF:
    ds 1                                               ;; dadf

wDAE0:
    ds 1                                               ;; dae0

wDAE1:
    ds 128                                             ;; dae1

wDB61:
    ds 2                                               ;; db61

wDB63:
    ds 1                                               ;; db63

wDB64:
    ds 1                                               ;; db64

wDB65:
    ds 1                                               ;; db65

wDB66:
    ds 1                                               ;; db66

wDB67:
    ds 2                                               ;; db67

wDB69:
    ds 1                                               ;; db69

wDB6A:
    ds 1                                               ;; db6a

wDB6B_InterruptFlag:
    ds 1                                               ;; db6b

wDB6C_CurrentMapId: ; can freeze and enter level to get to another level
    ds 1                                               ;; db6c

wDB6D:
    ds 1                                               ;; db6d

wDB6E:
    ds 1                                               ;; db6e

wDB6F:
    ds 1                                               ;; db6f

wDB70:
    ds 1                                               ;; db70

wDB71:
    ds 1                                               ;; db71

wDB72:
    ds 1                                               ;; db72

wDB73:
    ds 1                                               ;; db73

wDB74:
    ds 1                                               ;; db74

wDB75:
    ds 1                                               ;; db75

wDB76:
    ds 8                                               ;; db76

wDB7E:
    ds 1                                               ;; db7e

wDB7F:
    ds 17                                              ;; db7f

wDB90:
    ds 1                                               ;; db90

wDB91:
    ds 1                                               ;; db91

wDB92_MenuTypeDataPointer:
    ds 2                                               ;; db92

wDB94:
    ds 1                                               ;; db94

wDB95:
    ds 1                                               ;; db95

wDB96:
    ds 1                                               ;; db96

wDB97:
    ds 1                                               ;; db97

wDB98:
    ds 1                                               ;; db98

wDB99:
    ds 2                                               ;; db99

wDB9B:
    ds 1                                               ;; db9b

wDB9C:
    ds 2                                               ;; db9c

wDB9E:
    ds 1                                               ;; db9e

wDB9F:
    ds 1                                               ;; db9f

wDBA0:
    ds 1                                               ;; dba0

wDBA1:
    ds 1                                               ;; dba1

wDBA2:
    ds 1                                               ;; dba2

wDBA3:
    ds 1                                               ;; dba3

wDBA4:
    ds 1                                               ;; dba4

wDBA5:
    ds 1                                               ;; dba5

wDBA6:
    ds 1                                               ;; dba6

wDBA7:
    ds 1                                               ;; dba7

wDBA8:
    ds 1                                               ;; dba8

wDBA9:
    ds 1                                               ;; dba9

wDBAA:
    ds 1                                               ;; dbaa

wDBAB:
    ds 2                                               ;; dbab

wDBAD:
    ds 2                                               ;; dbad

wDBAF:
    ds 1                                               ;; dbaf

wDBB0:
    ds 1                                               ;; dbb0

wDBB1:
    ds 1                                               ;; dbb1

wDBB2:
    ds 1                                               ;; dbb2

wDBB3:
    ds 2                                               ;; dbb3

wDBB5:
    ds 2                                               ;; dbb5

wDBB7:
    ds 2                                               ;; dbb7

wDBB9:
    ds 1                                               ;; dbb9

wDBBA:
    ds 1                                               ;; dbba

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

wDBEB:
    ds 1                                               ;; dbeb

wDBEC:
    ds 1                                               ;; dbec

wDBED:
    ds 1                                               ;; dbed

wDBEE:
    ds 1                                               ;; dbee

wDBEF:
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

wDBF8:
    ds 1                                               ;; dbf8

wDBF9_XPositionInMap:
    ds 1                                               ;; dbf9

wDBFA_XPositionInMap:
    ds 1                                               ;; dbfa

wDBFB_YPositionInMap:
    ds 1                                               ;; dbfb

wDBFC_YPositionInMap:
    ds 1                                               ;; dbfc

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
    ds 1                                               ;; dc08

wDC09_TilesetBankOffset:
    ds 1                                               ;; dc09

wDC0A_BlocksetBank: ; also contains palette ids for each block, and some other unknown flags?
    ds 1                                               ;; dc0a

wDC0B_BlocksetBankOffset:
    ds 1                                               ;; dc0b

wDC0C_BlocksetBankOffset:
    ds 1                                               ;; dc0c

wDC0D_MapCollisionBank:
    ds 1                                               ;; dc0d

wDC0E_MapCollisionBankOffset:
    ds 2                                               ;; dc0e

wDC10_CollisionBlockset:
    ds 1                                               ;; dc10

wDC11_CollisionBlocksetOffset:
    ds 1                                               ;; dc11

wDC12_CollisionBlocksetOffset:
    ds 1                                               ;; dc12

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

wDC29:
    ds 1                                               ;; dc29

wDC2A:
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

wDC31:
    ds 1                                               ;; dc31

wDC32_VRAMBank:
    ds 1                                               ;; dc32

wDC33:
    ds 1                                               ;; dc33

wDC34:
    ds 1                                               ;; dc34

wDC35:
    ds 1                                               ;; dc35

wDC36:
    ds 1                                               ;; dc36

wDC37:
    ds 1                                               ;; dc37

wDC38:
    ds 1                                               ;; dc38

wDC39:
    ds 1                                               ;; dc39

wDC3A:
    ds 1                                               ;; dc3a

wDC3B:
    ds 1                                               ;; dc3b

wDC3C:
    ds 1                                               ;; dc3c

wDC3D:
    ds 1                                               ;; dc3d

wDC3E:
    ds 1                                               ;; dc3e

wDC3F:
    ds 1                                               ;; dc3f

wDC40:
    ds 1                                               ;; dc40

wDC41:
    ds 1                                               ;; dc41

wDC42:
    ds 1                                               ;; dc42

wDC43:
    ds 1                                               ;; dc43

wDC44:
    ds 8                                               ;; dc44

wDC4C:
    ds 1                                               ;; dc4c

wDC4D:
    ds 1                                               ;; dc4d

wDC4E:
    ds 1                                               ;; dc4e

wDC4F:
    ds 1                                               ;; dc4f

wDC50:
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

wDC5C:
    ds 9                                              ;; dc5c

wDC65:
    ds 1                                               ;; dc65

wDC66:
    ds 1                                               ;; dc66

wDC67:
    ds 1                                               ;; dc67

wDC68:
    ds 1                                               ;; dc68

wDC69:
    ds 1                                               ;; dc69

wDC6A:
    ds 1                                               ;; dc6a

wDC6B:
    ds 1                                               ;; dc6b

wDC6C:
    ds 1                                               ;; dc6c

wDC6D:
    ds 2                                               ;; dc6d

wDC6F:
    ds 1                                               ;; dc6f

wDC70:
    ds 1                                               ;; dc70

wDC71:
    ds 1                                               ;; dc71

wDC72:
    ds 1                                               ;; dc72

wDC73:
    ds 5                                               ;; dc73

wDC78:
    ds 1                                               ;; dc78

wDC79:
    ds 1                                               ;; dc79

wDC7A:
    ds 1                                               ;; dc7a

wDC7B:
    ds 1                                               ;; dc7b

wDC7C:
    ds 1                                               ;; dc7c

wDC7D:
    ds 1                                               ;; dc7d

wDC7E:
    ds 1                                               ;; dc7e

wDC7F:
    ds 1                                               ;; dc7f

wDC80:
    ds 1                                               ;; dc80

wDC81_CurrentInputs:
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

wDC8C:
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

wDCA0:
    ds 1                                               ;; dca0

wDCA1:
    ds 1                                               ;; dca1

wDCA2:
    ds 1                                               ;; dca2

wDCA3:
    ds 1                                               ;; dca3

wDCA4:
    ds 1                                               ;; dca4

wDCA5:
    ds 1                                               ;; dca5

wDCA6:
    ds 1                                               ;; dca6

wDCA7:
    ds 1                                               ;; dca7

wDCA8:
    ds 1                                               ;; dca8

wDCA9:
    ds 1                                               ;; dca9

wDCAA:
    ds 1                                               ;; dcaa

wDCAB:
    ds 1                                               ;; dcab

wDCAC:
    ds 1                                               ;; dcac

wDCAD:
    ds 1                                               ;; dcad

wDCAE:
    ds 1                                               ;; dcae

wDCAF:
    ds 2                                               ;; dcaf

wDCB1:
    ds 16                                              ;; dcb1

wDCC1:
    ds 1                                               ;; dcc1

wDCC2:
    ds 1                                               ;; dcc2

wDCC3:
    ds 1                                               ;; dcc3

wDCC4:
    ds 1                                               ;; dcc4

wDCC5:
    ds 1                                               ;; dcc5

wDCC6:
    ds 1                                               ;; dcc6

wDCC7:
    ds 1                                               ;; dcc7

wDCC8:
    ds 1                                               ;; dcc8

wDCC9:
    ds 1                                               ;; dcc9

wDCCA:
    ds 1                                               ;; dcca

wDCCB:
    ds 1                                               ;; dccb

wDCCC:
    ds 1                                               ;; dccc

wDCCD:
    ds 1                                               ;; dccd

wDCCE:
    ds 1                                               ;; dcce

wDCCF:
    ds 1                                               ;; dccf

wDCD0:
    ds 1                                               ;; dcd0

wDCD1:
    ds 1                                               ;; dcd1

wDCD2:
    ds 1                                               ;; dcd2

wDCD3:
    ds 1                                               ;; dcd3

wDCD4:
    ds 1                                               ;; dcd4

wDCD5:
    ds 1                                               ;; dcd5

wDCD6:
    ds 1                                               ;; dcd6

wDCD7:
    ds 1                                               ;; dcd7

wDCD8:
    ds 1                                               ;; dcd8

wDCD9:
    ds 1                                               ;; dcd9

wDCDA:
    ds 1                                               ;; dcda

wDCDB:
    ds 1                                               ;; dcdb

wDCDC:
    ds 2                                               ;; dcdc

wDCDE:
    ds 1                                               ;; dcde

wDCDF:
    ds 1                                               ;; dcdf

wDCE0:
    ds 1                                               ;; dce0

wDCE1:
    ds 1                                               ;; dce1

wDCE2:
    ds 6                                               ;; dce2

wDCE8:
    ds 1                                               ;; dce8

wDCE9:
    ds 1                                               ;; dce9

wDCEA_BgPalettes:
    ds 32                                              ;; dcea

wDD0A_BgPalettes:
    ds 32                                              ;; dd0a

wDD2A_ObjectPalettes:
    ds 32                                              ;; dd2a

wDD4A_ObjectPalettes:
    ds 32                                              ;; dd4a

wDD6A:
    ds 1                                               ;; dd6a

wDD6B: ; this section seems to be unused
    ds 89                                             ;; dd6b

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
wDE5C:
    ds 1                                               ;; de5c

wDE5D:
    ds 1                                               ;; de5d

wDE5E:
    ds 1                                               ;; de5e

wDE5F:
    ds 1                                               ;; de5f

wDE60:
    ds 160                                             ;; de60

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
