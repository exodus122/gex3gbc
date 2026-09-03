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
; call_01_4000_MenuLoad copies MENUTYPE_COPY_BYTES. This table plus the script each
; row points at is the whole definition of a menu screen - there is no per-screen code
; anywhere in the game.
;
;   +0  dw  the script that builds this screen
;   +2      MENU_FLAG_* behaviour bits              -> wDB94_MenuType_Flags
;   +3      how many selectable rows                -> wDB95_MenuType_OptionCount
;   +4  +5  cursor origin, X then Y                 -> wDB96 / wDB97
;   +6  +7  cursor step per column and per row      -> wDB98 / wDB99
;   +8      MENUTYPE_LCDC_UNREAD in all 29 records, and NOTHING READS IT -
;           call_01_43f0_Menu_BuildScreen hardcodes MENU_LCDC instead
;   +9      palette set, or MENU_PALETTE_NONE_BIT   -> wDB9B_MenuType_PaletteId
;   +$0A dw an optional per-menu callback           -> wDB9C_MenuType_OnSelectionChanged
;   +$0C    four dead bytes, never copied
;
; Byte +8 and the four dead bytes are emitted by the menu_type_record macro rather
; than written out on every row.
;
; Reading the flags column tells you how each screen is left. The four pause and
; confirm menus and the totals page are the interactive ones; everything with
; MENU_FLAG_HOLD or MENU_FLAG_HOLD_SKIPPABLE is a credit card or interstitial that
; times out; MENU_FLAG_WAIT_RELEASE is the "press anything" pair; and the handful with
; no flags at all are screens the caller tears down itself.
;
; Only one record sets a callback: the title screen's, which swaps two OBJ palettes to
; highlight the selected option.
;
; The three mission-select rows are the only ones with MENU_PALETTE_NONE_BIT set -
; they are drawn over the level's own palettes and must not disturb them.
;
; gex2's data_01_5574_MenuTypeRecords
    ; MENU_TITLE_SCREEN  - the only record with a callback
    menu_type_record data_01_559a_MenuScript_TitleScreen, $00, $02, $20, $54, $00, $10, $04, call_01_43c3_Menu_HighlightTitleOption
    ; MENU_ENTER_PASSWORD  - $12 = PASSWORD_CELL_COUNT cells
    menu_type_record data_01_55c3_MenuScript_EnterPassword, MENU_FLAG_GRID_INPUT, $12, $08, $20, $18, $18, $07, 0
    ; MENU_SEE_PASSWORD  - the grid again, but nothing to type
    menu_type_record data_01_55ec_MenuScript_SeePassword, MENU_FLAG_GRID_INPUT, $00, $00, $00, $00, $00, $07, 0
    ; MENU_GAME_OVER
    menu_type_record data_01_55fd_MenuScript_GameOver, MENU_FLAG_WAIT_RELEASE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_BAD_PASSWORD
    menu_type_record data_01_5606_MenuScript_BadPassword, MENU_FLAG_WAIT_RELEASE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_MISSION_SELECT_1_REMOTE  - keeps the map palettes
    menu_type_record data_01_560f_MenuScript_MissionSelect1Remote, $00, $01, $00, $50, $00, $18, 1 << MENU_PALETTE_NONE_BIT, 0
    ; MENU_UNK06  - script is a bare MENUSCRIPT_END
    menu_type_record data_01_5648_MenuScript_Unk06, $00, $02, $00, $40, $00, $20, 1 << MENU_PALETTE_NONE_BIT, 0
    ; MENU_MISSION_SELECT_3_REMOTES  - keeps the map palettes
    menu_type_record data_01_5649_MenuScript_MissionSelect3Remotes, $00, $03, $00, $38, $00, $18, 1 << MENU_PALETTE_NONE_BIT, 0
    ; MENU_TOTALS  - left/right page through the levels
    menu_type_record data_01_5692_MenuScript_Totals, MENU_FLAG_PAGED, $00, $00, $00, $00, $00, $01, 0
    ; MENU_CONGRATULATIONS_GOT_REMOTE
    menu_type_record data_01_571b_MenuScript_CongratulationsGotRemote, $00, $00, $00, $00, $00, $00, $01, 0
    ; MENU_TIME_UP
    menu_type_record data_01_57a4_MenuScript_TimeUp, $00, $00, $00, $00, $00, $00, $01, 0
    ; MENU_PAUSE_IN_GEX_CAVE  - four rows: the chained stats script adds three
    menu_type_record data_01_57ad_MenuScript_PauseInGexCave, $00, $04, $08, $20, $00, $10, $01, 0
    ; MENU_QUIT_GAME  - yes / no
    menu_type_record data_01_57be_MenuScript_QuitGame, $00, $02, $08, $30, $00, $10, $01, 0
    ; MENU_PAUSE_IN_LEVEL  - four rows, same chain
    menu_type_record data_01_57d7_MenuScript_PauseInLevel, $00, $04, $08, $20, $00, $10, $01, 0
    ; MENU_GO_TO_MAP  - yes / no
    menu_type_record data_01_57e8_MenuScript_GoToMap, $00, $02, $08, $30, $00, $10, $01, 0
    ; MENU_DAVID_A_PALMER
    menu_type_record data_01_5801_MenuScript_DavidAPalmer, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $02, 0
    ; MENU_LANGUAGE_SELECT  - one row per language. See code/menus/bank1c_text.asm
    menu_type_record data_01_580a_MenuScript_LanguageSelect, $00, $05, $18, $10, $00, $18, $03, 0
    ; MENU_OPENING_CREDITS_1  - the only MENU_FLAG_HOLD screen
    menu_type_record data_01_5843_MenuScript_OpeningCredits1, MENU_FLAG_HOLD, $00, $00, $00, $00, $00, $01, 0
    ; MENU_OPENING_CREDITS_2
    menu_type_record data_01_586c_MenuScript_OpeningCredits2, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_OPENING_CRYSTAL_DYNAMICS
    menu_type_record data_01_588d_MenuScript_OpeningCrystalDynamics, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $05, 0
    ; MENU_EIDOS_INTERACTIVE
    menu_type_record data_01_5896_MenuScript_EidosInteractive, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $06, 0
    ; MENU_END_CREDITS_1
    menu_type_record data_01_589f_MenuScript_EndCredits1, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_END_CREDITS_2
    menu_type_record data_01_58b8_MenuScript_EndCredits2, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_END_CREDITS_3
    menu_type_record data_01_5929_MenuScript_EndCredits3, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_END_CREDITS_4
    menu_type_record data_01_59a2_MenuScript_EndCredits4, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_END_CREDITS_5
    menu_type_record data_01_59c3_MenuScript_EndCredits5, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_END_CREDITS_6
    menu_type_record data_01_5a14_MenuScript_EndCredits6, MENU_FLAG_HOLD_SKIPPABLE, $00, $00, $00, $00, $00, $01, 0
    ; MENU_WELL_DONE  - no flags at all - falls straight through
    menu_type_record data_01_5a35_MenuScript_WellDone, $00, $00, $00, $00, $00, $00, $01, 0
    ; menu id $1c - no MENU_* constant  - a cursor base it never uses
    menu_type_record data_01_5a3e_MenuScript_Unk1C, MENU_FLAG_HOLD_SKIPPABLE, $00, $20, $54, $00, $10, $08, 0

data_01_5596_ChainedScriptTable:
; The two scripts a command can queue up behind the current one through
; call_01_47aa_MenuCmd_SetChainedScript: the password grid and the totals sub-screen.
; gex2's data_01_568c_ChainedScriptTable
    dw   data_01_5a47_MenuScript_PasswordGrid                                 ;; 01:5596 pP
    dw   data_01_5ad8_MenuScript_TotalsStats                                 ;; 01:5598 pP
