; ------------------------------------------------------------------
; THE MENU SCRIPTS
;
; One script per screen, and between them they contain everything about how a menu
; looks. call_01_445c_MenuScript_RunToEnd walks a script;
; call_01_446b_MenuScript_RunCommand executes one command and the file header explains
; what a command can do.
;
; Every command here is an opcode plus exactly one parameter block, so each is
; MENUCMD_PARAM_BYTES + 1 bytes and the two macros below the interpreter emit them:
;
;   menu_cmd      opcode, pen X, pen Y, arg, string table, option, flags
;   menu_cmd_sub  opcode, pen X, pen Y, arg, sub-handler, handler arg, option, flags
;
; The two differ only in what goes in the source-pointer slot. menu_cmd puts a real
; address there - always a BANK_1C_TEXT string-pointer table, never a bank 1 address,
; which is why they are written as bare numbers. menu_cmd_sub puts
; MENUCMD_SUB_* in the high byte and its argument in the low byte, and the interpreter
; spots that because the high byte is at or above MENUCMD_HANDLER_BASE.
;
; The option field is what makes a row selectable: its low nibble is the row number
; and its high nibble the MENU_RESULT_* or MENU_ACTION_* that row produces. A command
; with $00 there draws something the player cannot choose.
;
; A sub-handler's argument means whatever that handler wants it to. Four of them take
; an index into a table and are written here as constants -
; MENUCMD_SUB_SET_COUNTER_TEXT takes MENU_COUNTER_*, MENUCMD_SUB_FULLSCREEN_IMAGE
; takes MENU_IMAGE_*, MENUCMD_SUB_DRAW_SPRITE_GROUP takes MENU_SPRITE_GROUP_*, and
; MENUCMD_SUB_SET_CHAINED_SCRIPT takes MENU_CHAINED_*. The rest are bare numbers
; because they mean something local: a cursor image, a mission number, a cell index.
;
; The counter commands come in pairs with a "/" string between them - a count, then
; the total it is out of - which is why the totals and congratulations screens read as
; alternating MENU_COUNTER_* and Text_Slash
; ------------------------------------------------------------------
data_01_559a_MenuScript_TitleScreen:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_TITLE_SCREEN,              MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd     $14, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_NewGame,                 MENU_RESULT_START_GAME | 0,        MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_DRAW_SPRITE_GROUP,  MENU_SPRITE_GROUP_TITLE_BANNER,       MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd     $15, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_Password,                MENU_RESULT_PASSWORD_ACCEPTED | 1, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_55c3_MenuScript_EnterPassword:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_PASSWORD,                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd     $12, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $02, Text_PasswordKeyRow1,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $13, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $02, Text_PasswordKeyRow2,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $01,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, MENU_CHAINED_PASSWORD_GRID,           MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_55ec_MenuScript_SeePassword:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_PASSWORD,                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, MENU_CHAINED_PASSWORD_GRID,           MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_55fd_MenuScript_GameOver:
    menu_cmd     $4c, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_GameOver,                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5606_MenuScript_BadPassword:
    menu_cmd     $2f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_BadPassword,             MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_560f_MenuScript_MissionSelect1Remote:
    menu_cmd_sub $1a,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT,   $00,                                  $00,                 MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $1c, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_PressBToContinue,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $17, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, MENUCMD_SUB_SET_LEVEL_TEXT,     $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1d, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_TV_NAME_TEXT,   $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $16,             $00,             $00, $01, MENUCMD_SUB_STAGE_TV_SCREEN,    $00,                                  MENUCMD_OPTION_NONE, 0
    menu_cmd_sub $00,             $00,             $00, $e4, MENUCMD_SUB_STAGE_IMAGE2,       $04,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5648_MenuScript_Unk06:
    db   MENUSCRIPT_END

data_01_5649_MenuScript_MissionSelect3Remotes:
    menu_cmd_sub $19,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT,   $00,                                  $00,                 MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1a,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT,   $01,                                  $00 | 1,             MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1b,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT,   $02,                                  $00 | 2,             MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $1c, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_ChooseAHint,             MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $17, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, MENUCMD_SUB_SET_LEVEL_TEXT,     $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $18, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_TV_NAME_TEXT,   $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $16,             $00,             $00, $01, MENUCMD_SUB_STAGE_TV_SCREEN,    $00,                                  MENUCMD_OPTION_NONE, 0
    menu_cmd_sub $00,             $00,             $00, $e4, MENUCMD_SUB_STAGE_IMAGE2,       $04,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5692_MenuScript_Totals:
    menu_cmd_sub $1e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, MENUCMD_SUB_SET_LEVEL_TEXT,     $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_TV_NAME_TEXT,   $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $20, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_LeftRightToToggle,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $21, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_PressBToContinue,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $22, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_LEVEL_OBJECTIVES,        MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $23, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_Slash,                   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $24, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_LEVEL_OBJECTIVE_TOTAL,   MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $25, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_LEVEL_REMOTES,           MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $26, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_Slash,                   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $27, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_CONST_3,                 MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $28, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_LEVEL_BONUS_COIN,        MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $29, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_Slash,                   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $2a, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_CONST_1,                 MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $2b,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $2c,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $2d,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_ENABLE_ANIMATION,   $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_571b_MenuScript_CongratulationsGotRemote:
    menu_cmd     $2e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_Congratulations,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $2f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_COLLECTED_COUNT,    $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $30, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_PressBToContinue,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $31, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_COLLECTIBLES,            MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $32, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, Text_Slash,                   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $33, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_LEVEL_COLLECTIBLE_TOTAL, MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $34, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_BONUS_COINS,             MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $35, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_PAW_COINS,               MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $36,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $37,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $38,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $39,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $3a,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $01,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $3b,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $3c,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $03,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $e4, MENUCMD_SUB_STAGE_IMAGE2,       $04,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_ENABLE_ANIMATION,   $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_57a4_MenuScript_TimeUp:
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_TimeUp,                  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_57ad_MenuScript_PauseInGexCave:
    menu_cmd     $40, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_QuitGame,                MENU_ACTION_QUIT | 3,              MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, MENU_CHAINED_TOTALS_STATS,            MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_57be_MenuScript_QuitGame:
    menu_cmd     $3e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_QuitGame,                MENU_RESULT_CONFIRM_QUIT | 0,      MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_ForgetIt,                $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_57d7_MenuScript_PauseInLevel:
    menu_cmd     $40, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_GoToMap,                 MENU_ACTION_QUIT | 3,              MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, MENU_CHAINED_TOTALS_STATS,            MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_57e8_MenuScript_GoToMap:
    menu_cmd     $3e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_GoToMap,                 MENU_RESULT_CONFIRM_QUIT | 0,      MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_ForgetIt,                $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5801_MenuScript_DavidAPalmer:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_DAVID_A_PALMER,            MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_580a_MenuScript_LanguageSelect:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_LANGUAGE_SELECT,           MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    menu_cmd     $4d, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_LanguageEnglish,         $00,                               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $4e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_LanguageFrancais,        $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $4f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_LanguageDeutsch,         $00 | 2,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $50, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_LanguageEspanol,         $00 | 3,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $51, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_LanguageItaliano,        $00 | 4,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5843_MenuScript_OpeningCredits1:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, Text_TitleGexDeepPocketGecko, MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $17, $00, Text_PublishedByEidos,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $35, $00, Text_CrystalDynamicsRights,   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $53, $00, Text_NintendoLicenceLine,     MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $78, $00, Text_LicensedByNintendo,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_586c_MenuScript_OpeningCredits2:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $05, $00, Text_GexTrademarkNotice,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $29, $00, Text_CrystalSubsidiaryNotice, MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $45, $00, Text_EidosTrademarkNotice,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $69, $00, Text_EidosCopyright,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_588d_MenuScript_OpeningCrystalDynamics:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_CRYSTAL_DYNAMICS,          MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5896_MenuScript_EidosInteractive:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_EIDOS_INTERACTIVE,         MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_589f_MenuScript_EndCredits1:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, Text_HeadingCrystalEidos,     MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $36, $00, Text_HeadingExecProducer,     MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $40, $00, Text_NameSamPlayer,           MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_58b8_MenuScript_EndCredits2:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, Text_HeadingTestManager,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, Text_NameAlexNess,            MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $18, $00, Text_HeadingLeadTester,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $20, $00, Text_NameRichKrinock,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $31, $00, Text_HeadingTesters,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $39, $00, Text_NameBrianBecksted,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $41, $00, Text_NameChrisBruno,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $49, $00, Text_NameRolefConlan,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $51, $00, Text_NameJoeDamon,            MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $59, $00, Text_NameRyanEllison,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $61, $00, Text_NameMarkMedeiros,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $69, $00, Text_NameBillyMitchell,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $71, $00, Text_NameJacobRohrer,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $79, $00, Text_NameBenWalker,           MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5929_MenuScript_EndCredits3:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, Text_HeadingMarketingManager, MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, Text_NameChipBlundell,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $19, $00, Text_HeadingSpecialThanks,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $21, $00, Text_NameAndrewBennett,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $29, $00, Text_NamePatrickCowan,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $31, $00, Text_NameRobDyer,             MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $39, $00, Text_NameNickEarl,            MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $41, $00, Text_NameBrianKemp,           MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $49, $00, Text_NameRoseMontgomery,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $51, $00, Text_NameSimonOrams,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $59, $00, Text_NameReneePletka,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $61, $00, Text_NameJamesPoole,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $69, $00, Text_NameGregRizzer,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $71, $00, Text_NameGlenSchofield,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $79, $00, Text_NameFlaviaTimiani,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_59a2_MenuScript_EndCredits4:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, Text_HeadingProducedByPalmer, MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $18, $00, Text_HeadingSheffieldUk,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $36, $00, Text_HeadingProjectManager,   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $40, $00, Text_NameDavePalmer,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_59c3_MenuScript_EndCredits5:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, Text_HeadingProgramming,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, Text_NameRoo,                 MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $1a, $00, Text_HeadingMusicAndSfx,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $22, $00, Text_NameMarkCooksey,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $34, $00, Text_HeadingLeadArtist,       MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $3c, $00, Text_NameIanTerry,            MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $4e, $00, Text_HeadingSupportArtist,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $56, $00, Text_NameDaveGarrison,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $68, $00, Text_HeadingTesters2,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $70, $00, Text_NameNeilPalmer,          MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a14_MenuScript_EndCredits6:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $2e, $00, Text_HeadingSpecialThanks2,   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $36, $00, Text_NameDavidMBoyles,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $3e, $00, Text_NameGailOxley,           MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $46, $00, Text_NamePeterLeonard,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a35_MenuScript_WellDone:
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_WellDone,                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a3e_MenuScript_Unk1C:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE,   MENU_IMAGE_UNK1C,                     MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a47_MenuScript_PasswordGrid:
    menu_cmd_sub $00,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $01,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $01,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $02,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $03,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $03,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $04,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $04,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $05,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $05,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $06,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $06,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $07,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $07,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $08,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $08,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $09,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $09,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0a,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $0a,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0b,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $0b,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0c,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $0c,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0d,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $0d,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0e,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $0e,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0f,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $0f,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $10,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $10,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $11,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH,     $11,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_TRANSPOSED | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5ad8_MenuScript_TotalsStats:
    menu_cmd     $3d, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_Resume,                  $00,                               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_SeePassword,             MENU_ACTION_SEE_PASSWORD | 1,      MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, Text_Totals,                  MENU_ACTION_VIEW_TOTALS | 2,       MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $41, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_COLLECTIBLES,            MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $42, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_PAW_COINS,               MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $43, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_BONUS_COINS,             MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $44, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_ALL_OBJECTIVES,          MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $45, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT,   MENU_COUNTER_LIVES,                   MENUCMD_OPTION_NONE, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $46,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $47,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $48,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $49,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $4a,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER
    menu_cmd     $4b,             $00,             $00, $00, $0000,                        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER
    menu_cmd_sub $00,             $00,             $00, $85, MENUCMD_SUB_STAGE_IMAGE2,       $05,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_ENABLE_ANIMATION,   $00,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR,        $02,                                  MENUCMD_OPTION_NONE, MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END
