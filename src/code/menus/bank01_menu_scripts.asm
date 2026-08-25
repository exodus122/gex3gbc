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
; with $00 there draws something the player cannot choose
; ------------------------------------------------------------------
data_01_559a_MenuScript_TitleScreen:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $02,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd     $14, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $477c,                                MENU_RESULT_START_GAME | 0,        MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_DRAW_SPRITE_GROUP, $03,   MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd     $15, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $47c7,                                MENU_RESULT_PASSWORD_ACCEPTED | 1, MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $02,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_55c3_MenuScript_EnterPassword:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $05,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd     $12, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $02, $4e62,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $13, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $02, $4e7d,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $01,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, $00,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_55ec_MenuScript_SeePassword:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $05,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, $00,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_55fd_MenuScript_GameOver:
    menu_cmd     $4c, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4c09,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5606_MenuScript_BadPassword:
    menu_cmd     $2f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4e03,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_560f_MenuScript_MissionSelect1Remote:
    menu_cmd_sub $1a,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT, $00,    $00,                               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $1c, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4916,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $17, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, MENUCMD_SUB_SET_LEVEL_TEXT, $00,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1d, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_TV_NAME_TEXT, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $16,             $00,             $00, $01, MENUCMD_SUB_STAGE_TV_SCREEN, $00,     MENUCMD_OPTION_NONE,               0
    menu_cmd_sub $00,             $00,             $00, $e4, MENUCMD_SUB_STAGE_IMAGE2, $04,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $02,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5648_MenuScript_Unk06:
    db   MENUSCRIPT_END

data_01_5649_MenuScript_MissionSelect3Remotes:
    menu_cmd_sub $19,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT, $00,    $00,                               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1a,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT, $01,    $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1b,             $00, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_MISSION_TEXT, $02,    $00 | 2,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $1c, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4803,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $17, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, MENUCMD_SUB_SET_LEVEL_TEXT, $00,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $18, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_TV_NAME_TEXT, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $16,             $00,             $00, $01, MENUCMD_SUB_STAGE_TV_SCREEN, $00,     MENUCMD_OPTION_NONE,               0
    menu_cmd_sub $00,             $00,             $00, $e4, MENUCMD_SUB_STAGE_IMAGE2, $04,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $02,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5692_MenuScript_Totals:
    menu_cmd_sub $1e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, MENUCMD_SUB_SET_LEVEL_TEXT, $00,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $1f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_TV_NAME_TEXT, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $20, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $49cb,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $21, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4916,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $22, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $23, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4a63,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $24, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $07,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $25, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $01,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $26, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4a63,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $27, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $08,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $28, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $02,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $29, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4a63,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $2a, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $09,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $2b,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $2c,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $2d,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_ENABLE_ANIMATION, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_571b_MenuScript_CongratulationsGotRemote:
    menu_cmd     $2e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4a6f,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $2f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_COLLECTED_COUNT, $00,     MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $30, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4916,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $31, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $03,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $32, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, $4a63,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $33, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $0b,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $34, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $04,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $35, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $05,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $36,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $37,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $38,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $39,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $00,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $3a,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $01,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $3b,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $02,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $3c,             $00,             $00, $00, MENUCMD_SUB_DRAW_REMOTE_MARKER, $03,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $e4, MENUCMD_SUB_STAGE_IMAGE2, $04,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_ENABLE_ANIMATION, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_57a4_MenuScript_TimeUp:
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4b79,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_57ad_MenuScript_PauseInGexCave:
    menu_cmd     $40, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4cbf,                                MENU_ACTION_QUIT | 3,              MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, $01,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_57be_MenuScript_QuitGame:
    menu_cmd     $3e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4cbf,                                MENU_RESULT_CONFIRM_QUIT | 0,      MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4db6,                                $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $02,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_57d7_MenuScript_PauseInLevel:
    menu_cmd     $40, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4d63,                                MENU_ACTION_QUIT | 3,              MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_SET_CHAINED_SCRIPT, $01,  MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    db   MENUSCRIPT_END

data_01_57e8_MenuScript_GoToMap:
    menu_cmd     $3e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4d63,                                MENU_RESULT_CONFIRM_QUIT | 0,      MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4db6,                                $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $02,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5801_MenuScript_DavidAPalmer:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_580a_MenuScript_Unk10:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $01,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    menu_cmd     $4d, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4720,                                $00,                               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $4e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4732,                                $00 | 1,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $4f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4745,                                $00 | 2,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $50, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4757,                                $00 | 3,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $51, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4769,                                $00 | 4,                           MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $00,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5843_MenuScript_OpeningCredits1:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, $4000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $17, $00, $4022,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $35, $00, $404f,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $53, $00, $4082,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $78, $00, $40d9,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_586c_MenuScript_OpeningCredits2:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $05, $00, $40f8,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $29, $00, $4171,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $45, $00, $41bf,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $69, $00, $422a,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_588d_MenuScript_OpeningCrystalDynamics:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $03,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5896_MenuScript_EidosInteractive:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $04,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_589f_MenuScript_EndCredits1:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, $4269,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $36, $00, $428c,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $40, $00, $42a9,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_58b8_MenuScript_EndCredits2:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, $42be,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, $42d5,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $18, $00, $42e9,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $20, $00, $42ff,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $31, $00, $4316,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $39, $00, $4328,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $41, $00, $4341,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $49, $00, $4357,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $51, $00, $436e,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $59, $00, $4382,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $61, $00, $4399,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $69, $00, $43b1,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $71, $00, $43ca,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $79, $00, $43e1,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5929_MenuScript_EndCredits3:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, $43f6,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, $441a,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $19, $00, $4432,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $21, $00, $444e,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $29, $00, $4467,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $31, $00, $447f,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $39, $00, $4492,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $41, $00, $44a6,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $49, $00, $44bb,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $51, $00, $44d5,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $59, $00, $44eb,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $61, $00, $4502,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $69, $00, $4518,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $71, $00, $452e,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $79, $00, $4547,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_59a2_MenuScript_EndCredits4:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, $4560,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $18, $00, $4592,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $36, $00, $45ac,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $40, $00, $45d1,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_59c3_MenuScript_EndCredits5:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $00, $00, $45e7,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $08, $00, $45fd,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $1a, $00, $460b,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $22, $00, $4623,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $34, $00, $463a,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $3c, $00, $4650,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $4e, $00, $4664,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $56, $00, $467d,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $68, $00, $4695,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $70, $00, $46a7,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a14_MenuScript_EndCredits6:
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $2e, $00, $46bd,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $36, $00, $46d9,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $3e, $00, $46f3,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $52, TEXT_AUTO_ALIGN,             $46, $00, $4708,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a35_MenuScript_WellDone:
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4bc5,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a3e_MenuScript_Unk1C:
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_FULLSCREEN_IMAGE, $06,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5a47_MenuScript_PasswordGrid:
    menu_cmd_sub $00,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $00,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $01,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $01,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $02,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $02,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $03,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $03,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $04,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $04,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $05,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $05,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $06,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $06,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $07,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $07,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $08,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $08,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $09,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $09,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0a,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $0a,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0b,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $0b,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0c,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $0c,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0d,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $0d,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0e,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $0e,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $0f,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $0f,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $10,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $10,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED
    menu_cmd_sub $11,             $00,             $00, $03, MENUCMD_SUB_PASSWORD_GLYPH, $11,      MENUCMD_OPTION_NONE,               MENUCMD_FLAG_TRANSPOSED | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END

data_01_5ad8_MenuScript_TotalsStats:
    menu_cmd     $3d, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4c56,                                $00,                               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3e, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4d0f,                                MENU_ACTION_SEE_PASSWORD | 1,      MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $3f, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $01, $4c8f,                                MENU_ACTION_VIEW_TOTALS | 2,       MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $41, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $03,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $42, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $05,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $43, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $04,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $44, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $06,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd_sub $45, TEXT_AUTO_ALIGN, TEXT_AUTO_ALIGN, $00, MENUCMD_SUB_SET_COUNTER_TEXT, $0a,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_DRAW_TEXT
    menu_cmd     $46,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $47,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $48,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $49,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER | MENUCMD_FLAG_TRANSPOSED
    menu_cmd     $4a,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER
    menu_cmd     $4b,             $00,             $00, $00, $0000,                                MENUCMD_OPTION_NONE,               MENUCMD_FLAG_CLEAR_BUFFER
    menu_cmd_sub $00,             $00,             $00, $85, MENUCMD_SUB_STAGE_IMAGE2, $05,        MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $00, MENUCMD_SUB_ENABLE_ANIMATION, $00,    MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL
    menu_cmd_sub $00,             $00,             $00, $fc, MENUCMD_SUB_DRAW_CURSOR, $02,         MENUCMD_OPTION_NONE,               MENUCMD_FLAG_NO_TILE_FILL | MENUCMD_FLAG_UPLOAD_TILES
    db   MENUSCRIPT_END
