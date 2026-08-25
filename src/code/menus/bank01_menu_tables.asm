data_01_512e_MenuCmd_Descriptors:
; The shape of every menu command opcode: MENUCMD_DESCRIPTOR_SIZE bytes per id, of
; which call_01_446b_MenuScript_RunCommand copies MENUCMD_DESCRIPTOR_COPY_BYTES into
; wDB9E onwards. The last two bytes are $00 in all 83 records and are never read.
;
;   width and height  in tiles. They are the fill's two loop counters, and the text
;                     renderer's block size - a string is wrapped to width * 8 pixels
;   dest tile X, Y    where the block sits, indexed into wD400_ScreenDraw_TileIds as
;                     y * SCRN_X_B + x
;   first tile id     the fill writes consecutive ids from here; the text renderer
;                     stages its glyphs at this tile in wC000_BgMapTileIds
;   attribute         the BG attribute byte written across the block, or
;                     MENUCMD_ATTR_TILESET_ROW to pull a row from the secondary
;                     tileset instead
;
; So an opcode is a RECTANGLE, and the script's parameter block says what goes in it.
; Opcode $00 is the "shape does not matter" id used by every command that only calls a
; sub-handler, which is why eighteen different scripts share it.
;
; Ids $00-$11 are the password entry grid - PASSWORD_CELL_COUNT cells of 2x2 tiles at
; PASSWORD_GRID_COLUMNS x PASSWORD_GRID_ROWS positions, first tiles stepping by
; PASSWORD_CELL_TILES from PASSWORD_CELL_TILE_BASE. That is the same arithmetic
; call_01_4de3_Password_GetCellTileIndex does at runtime, so the two agree by
; construction. Ids $12 and $13 are the two PASSWORD_KEY_COLUMNS-wide keyboard rows.
;
; NOTE the rows below are on MENUCMD_DESCRIPTOR_SIZE boundaries. The raw disassembly's
; `db` lines were not - from $5316 on they drifted out of step - so anything that
; counted rows there was reading fields from two adjacent records.
;
; gex2's data_01_5324_MenuCmd_Descriptors, same layout
    menu_cmd_shape   2,   2,   1,   4, $98, $07                      ; $00  many
    menu_cmd_shape   2,   2,   4,   4, $9c, $07                      ; $01  PasswordGrid
    menu_cmd_shape   2,   2,   7,   4, $a0, $07                      ; $02  PasswordGrid
    menu_cmd_shape   2,   2,  10,   4, $a4, $07                      ; $03  PasswordGrid
    menu_cmd_shape   2,   2,  13,   4, $a8, $07                      ; $04  PasswordGrid
    menu_cmd_shape   2,   2,  16,   4, $ac, $07                      ; $05  PasswordGrid
    menu_cmd_shape   2,   2,   1,   7, $b0, $07                      ; $06  PasswordGrid
    menu_cmd_shape   2,   2,   4,   7, $b4, $07                      ; $07  PasswordGrid
    menu_cmd_shape   2,   2,   7,   7, $b8, $07                      ; $08  PasswordGrid
    menu_cmd_shape   2,   2,  10,   7, $bc, $07                      ; $09  PasswordGrid
    menu_cmd_shape   2,   2,  13,   7, $c0, $07                      ; $0a  PasswordGrid
    menu_cmd_shape   2,   2,  16,   7, $c4, $07                      ; $0b  PasswordGrid
    menu_cmd_shape   2,   2,   1,  10, $c8, $07                      ; $0c  PasswordGrid
    menu_cmd_shape   2,   2,   4,  10, $cc, $07                      ; $0d  PasswordGrid
    menu_cmd_shape   2,   2,   7,  10, $d0, $07                      ; $0e  PasswordGrid
    menu_cmd_shape   2,   2,  10,  10, $d4, $07                      ; $0f  PasswordGrid
    menu_cmd_shape   2,   2,  13,  10, $d8, $07                      ; $10  PasswordGrid
    menu_cmd_shape   2,   2,  16,  10, $dc, $07                      ; $11  PasswordGrid
    menu_cmd_shape  16,   1,   1,   1, $e0, $07                      ; $12  EnterPassword
    menu_cmd_shape  16,   1,   1,   2, $f0, $07                      ; $13  EnterPassword
    menu_cmd_shape   8,   1,   6,  11, $d0, $00                      ; $14  TitleScreen
    menu_cmd_shape   8,   1,   6,  13, $d8, $00                      ; $15  TitleScreen
    menu_cmd_shape   8,   6,   1,   0, $01, MENUCMD_ATTR_TILESET_ROW ; $16  MissionSelect1Remote, MissionSelect3Remotes
    menu_cmd_shape  11,   2,   9,   1, $31, $01                      ; $17  MissionSelect1Remote, MissionSelect3Remotes
    menu_cmd_shape  11,   2,   9,   4, $47, $02                      ; $18  MissionSelect3Remotes
    menu_cmd_shape  16,   2,   4,   7, $5d, $02                      ; $19  MissionSelect3Remotes
    menu_cmd_shape  16,   2,   4,  10, $7d, $02                      ; $1a  MissionSelect1Remote, MissionSelect3Remotes
    menu_cmd_shape  16,   2,   4,  13, $9d, $02                      ; $1b  MissionSelect3Remotes
    menu_cmd_shape  18,   2,   1,  16, $bd, $02                      ; $1c  MissionSelect1Remote, MissionSelect3Remotes
    menu_cmd_shape  11,   3,   9,   4, $47, $02                      ; $1d  MissionSelect1Remote
    menu_cmd_shape  12,   2,   4,   1, $01, $01                      ; $1e  Totals
    menu_cmd_shape  12,   2,   4,   3, $19, $02                      ; $1f  Totals
    menu_cmd_shape  20,   1,   0,  15, $31, $02                      ; $20  Totals
    menu_cmd_shape  20,   2,   0,  16, $45, $02                      ; $21  Totals
    menu_cmd_shape   1,   1,  11,   6, $6d, $02                      ; $22  Totals
    menu_cmd_shape   1,   2,  12,   6, $6e, $02                      ; $23  Totals
    menu_cmd_shape   1,   1,  13,   7, $70, $02                      ; $24  Totals
    menu_cmd_shape   1,   1,  11,   9, $71, $02                      ; $25  Totals
    menu_cmd_shape   1,   2,  12,   9, $72, $02                      ; $26  Totals
    menu_cmd_shape   1,   1,  13,  10, $74, $02                      ; $27  Totals
    menu_cmd_shape   1,   1,  11,  12, $75, $02                      ; $28  Totals
    menu_cmd_shape   1,   2,  12,  12, $76, $02                      ; $29  Totals
    menu_cmd_shape   1,   1,  13,  13, $78, $02                      ; $2a  Totals
    menu_cmd_shape   2,   2,   7,   6, $f8, $04                      ; $2b  Totals
    menu_cmd_shape   2,   2,   7,   9, $f4, $07                      ; $2c  Totals
    menu_cmd_shape   2,   2,   7,  12, $ec, $05                      ; $2d  Totals
    menu_cmd_shape  16,   2,   2,   0, $01, $01                      ; $2e  CongratulationsGotRemote
    menu_cmd_shape  18,   2,   1,   5, $21, $02                      ; $2f  BadPassword, CongratulationsGotRemote
    menu_cmd_shape  20,   2,   0,  16, $45, $02                      ; $30  CongratulationsGotRemote
    menu_cmd_shape   2,   1,   7,  10, $6d, $02                      ; $31  CongratulationsGotRemote
    menu_cmd_shape   2,   2,   9,  10, $6f, $02                      ; $32  CongratulationsGotRemote
    menu_cmd_shape   2,   1,  11,  11, $73, $02                      ; $33  CongratulationsGotRemote
    menu_cmd_shape   2,   2,   4,  14, $75, $02                      ; $34  CongratulationsGotRemote
    menu_cmd_shape   2,   2,  14,  14, $79, $02                      ; $35  CongratulationsGotRemote
    menu_cmd_shape   2,   2,   9,   8, $f0, $06                      ; $36  CongratulationsGotRemote
    menu_cmd_shape   2,   2,   4,  12, $ec, $05                      ; $37  CongratulationsGotRemote
    menu_cmd_shape   2,   2,  14,  12, $f4, $07                      ; $38  CongratulationsGotRemote
    menu_cmd_shape   2,   2,   3,   3, $7d, $03                      ; $39  CongratulationsGotRemote
    menu_cmd_shape   2,   2,   7,   3, $81, $03                      ; $3a  CongratulationsGotRemote
    menu_cmd_shape   2,   2,  11,   3, $85, $03                      ; $3b  CongratulationsGotRemote
    menu_cmd_shape   2,   2,  15,   3, $89, $03                      ; $3c  CongratulationsGotRemote
    menu_cmd_shape  14,   2,   3,   4, $01, $01                      ; $3d  TotalsStats
    menu_cmd_shape  14,   2,   3,   6, $1d, $01                      ; $3e  QuitGame, GoToMap, TotalsStats
    menu_cmd_shape  14,   2,   3,   8, $39, $01                      ; $3f  many
    menu_cmd_shape  14,   2,   3,  10, $55, $01                      ; $40  PauseInGexCave, PauseInLevel
    menu_cmd_shape   2,   2,   3,  16, $71, $02                      ; $41  TotalsStats
    menu_cmd_shape   2,   2,   7,  16, $75, $02                      ; $42  TotalsStats
    menu_cmd_shape   2,   2,  11,  16, $79, $02                      ; $43  TotalsStats
    menu_cmd_shape   2,   2,  15,  16, $7d, $02                      ; $44  TotalsStats
    menu_cmd_shape   2,   2,   3,   1, $81, $02                      ; $45  TotalsStats
    menu_cmd_shape   2,   2,   3,  14, $f0, $06                      ; $46  TotalsStats
    menu_cmd_shape   2,   2,   7,  14, $f4, $07                      ; $47  TotalsStats
    menu_cmd_shape   2,   2,  11,  14, $ec, $05                      ; $48  TotalsStats
    menu_cmd_shape   2,   2,  15,  14, $f8, $04                      ; $49  TotalsStats
    menu_cmd_shape   2,   1,   1,   1, $85, $03                      ; $4a  TotalsStats
    menu_cmd_shape   2,   1,   1,   2, $87, $00                      ; $4b  TotalsStats
    menu_cmd_shape  20,   3,   0,   8, $01, $01                      ; $4c  GameOver
    menu_cmd_shape  10,   2,  10,   2, $80, $03                      ; $4d  Unk10
    menu_cmd_shape  10,   2,  10,   5, $94, $03                      ; $4e  Unk10
    menu_cmd_shape  10,   2,  10,   8, $a8, $03                      ; $4f  Unk10
    menu_cmd_shape  10,   2,  10,  11, $bc, $03                      ; $50  Unk10
    menu_cmd_shape  10,   2,  10,  14, $d0, $03                      ; $51  Unk10
    menu_cmd_shape  16,  16,   2,   1, $01, $02                      ; $52  many

data_01_53c6_MenuTypeRecords:
; One record per MENU_* id, MENUTYPE_RECORD_SIZE bytes, of which
; call_01_4000_MenuLoad copies MENUTYPE_COPY_BYTES:
;
;   +0  dw  the script that builds this screen
;   +2      MENU_FLAG_* behaviour bits              -> wDB94_MenuType_Flags
;   +3      how many selectable rows                -> wDB95_MenuType_OptionCount
;   +4  +5  cursor origin, X then Y                 -> wDB96 / wDB97
;   +6  +7  cursor step per column and per row      -> wDB98 / wDB99
;   +8      an LCDC value. $d3 in all 29 records, and NOTHING READS IT -
;           call_01_43f0_Menu_BuildScreen hardcodes MENU_LCDC instead
;   +9      palette set, or MENU_PALETTE_NONE_BIT   -> wDB9B_MenuType_PaletteId
;   +$0A dw an optional per-menu callback           -> wDB9C_MenuType_OnSelectionChanged
;   +$0C    four dead bytes, never copied
;
; Only one record sets a callback: the title screen's, which swaps two OBJ palettes to
; highlight the selected option.
;
; gex2's data_01_5574_MenuTypeRecords
    dw   data_01_559a_MenuScript_TitleScreen                    ; MENU_TITLE_SCREEN
    db   $00, $02, $20, $54, $00, $10, $d3, $04       ;; 01:53c8 ........
    dw   call_01_43c3_Menu_HighlightTitleOption       ;; 01:53d0 pP
    db   $00, $00, $00, $00                           ;; 01:53d2 ????

    dw   data_01_55c3_MenuScript_EnterPassword                  ; MENU_ENTER_PASSWORD
    db   $01, $12, $08, $20, $18, $18, $d3, $07       ;; 01:53d8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:53e0 ..????

    dw   data_01_55ec_MenuScript_SeePassword                    ; MENU_SEE_PASSWORD
    db   $01, $00, $00, $00, $00, $00, $d3, $07       ;; 01:53e8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:53f0 ..????

    dw   data_01_55fd_MenuScript_GameOver                       ; MENU_GAME_OVER
    db   $08, $00, $00, $00, $00, $00, $d3, $01       ;; 01:53f8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5400 ..????

    dw   data_01_5606_MenuScript_BadPassword                    ; MENU_BAD_PASSWORD
    db   $08, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5408 ........
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_560f_MenuScript_MissionSelect1Remote           ; MENU_MISSION_SELECT_1_REMOTE
    db   $00, $01, $00, $50, $00, $18, $d3, $80       ;; 01:5418 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_5648_MenuScript_Unk06                          ; MENU_UNK06
    db   $00, $02, $00, $40, $00, $20, $d3, $80       ;; 01:5428 ????????
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5430 ??????

    dw   data_01_5649_MenuScript_MissionSelect3Remotes          ; MENU_MISSION_SELECT_3_REMOTES
    db   $00, $03, $00, $38, $00, $18, $d3, $80       ;; 01:5438 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5440 ..????

    dw   data_01_5692_MenuScript_Totals                         ; MENU_TOTALS
    db   $10, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5448 ........
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_571b_MenuScript_CongratulationsGotRemote       ; MENU_CONGRATULATIONS_GOT_REMOTE
    db   $00, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5458 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_57a4_MenuScript_TimeUp                         ; MENU_TIME_UP
    db   $00, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5468 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_57ad_MenuScript_PauseInGexCave                 ; MENU_PAUSE_IN_GEX_CAVE
    db   $00, $04, $08, $20, $00, $10, $d3, $01       ;; 01:5478 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_57be_MenuScript_QuitGame                       ; MENU_QUIT_GAME
    db   $00, $02, $08, $30, $00, $10, $d3, $01       ;; 01:5488 ????????
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5490 ??????

    dw   data_01_57d7_MenuScript_PauseInLevel                   ; MENU_PAUSE_IN_LEVEL
    db   $00, $04, $08, $20, $00, $10, $d3, $01       ;; 01:5498 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:54a0 ..????

    dw   data_01_57e8_MenuScript_GoToMap                        ; MENU_GO_TO_MAP
    db   $00, $02, $08, $30, $00, $10, $d3, $01       ;; 01:54a8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:54b0 ..????

    dw   data_01_5801_MenuScript_DavidAPalmer                   ; MENU_DAVID_A_PALMER
    db   $04, $00, $00, $00, $00, $00, $d3, $02       ;; 01:54b8 ........
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_580a_MenuScript_Unk10                          ; MENU_UNK10
    db   $00, $05, $18, $10, $00, $18, $d3, $03       ;; 01:54c8 ????????
    db   $00, $00, $00, $00, $00, $00                 ;; 01:54d0 ??????

    ; MENU_OPENING_CREDITS_1
    dw   data_01_5843_MenuScript_OpeningCredits1                ; MENU_OPENING_CREDITS_1
    db   $02, $00, $00, $00, $00, $00, $d3, $01       ;; 01:54d8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:54e0 ..????

    dw   data_01_586c_MenuScript_OpeningCredits2                ; MENU_OPENING_CREDITS_2
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:54e8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:54f0 ..????

    dw   data_01_588d_MenuScript_OpeningCrystalDynamics         ; MENU_OPENING_CRYSTAL_DYNAMICS
    db   $04, $00, $00, $00, $00, $00, $d3, $05       ;; 01:54f8 ........
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5500 ..????

    dw   data_01_5896_MenuScript_EidosInteractive               ; MENU_EIDOS_INTERACTIVE
    db   $04, $00, $00, $00, $00, $00, $d3, $06       ;; 01:5508 ........
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_589f_MenuScript_EndCredits1                    ; MENU_END_CREDITS_1
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5518 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_58b8_MenuScript_EndCredits2                    ; MENU_END_CREDITS_2
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5528 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_5929_MenuScript_EndCredits3                    ; MENU_END_CREDITS_3
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5538 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_59a2_MenuScript_EndCredits4                    ; MENU_END_CREDITS_4
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5548 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_59c3_MenuScript_EndCredits5                    ; MENU_END_CREDITS_5
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5558 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_5a14_MenuScript_EndCredits6                    ; MENU_END_CREDITS_6
    db   $04, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5568 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_5a35_MenuScript_WellDone                       ; MENU_WELL_DONE
    db   $00, $00, $00, $00, $00, $00, $d3, $01       ;; 01:5578 ????????
    db   $00, $00, $00, $00, $00, $00
    
    dw   data_01_5a3e_MenuScript_Unk1C                              ; menu id $1c - no MENU_* constant
    db   $04, $00, $20, $54, $00, $10, $d3, $08       ;; 01:5588 ????????
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5590 ??????

data_01_5596_ChainedScriptTable:
; The two scripts a command can queue up behind the current one through
; call_01_47aa_MenuCmd_SetChainedScript: the password grid and the totals sub-screen.
; gex2's data_01_568c_ChainedScriptTable
    dw   data_01_5a47_MenuScript_PasswordGrid                                 ;; 01:5596 pP
    dw   data_01_5ad8_MenuScript_TotalsStats                                 ;; 01:5598 pP
