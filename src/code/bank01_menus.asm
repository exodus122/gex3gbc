; ==================================================================
; Bank 1. Every menu in the game: the title screen, the mission select, the pause
; menu, the totals pages, the password screen and all fourteen credit and interstitial
; screens. One file, one engine, and almost none of it knows what it is drawing.
;
; The idea
; --------
; A menu is DATA. call_01_4000_MenuLoad takes a MENU_* id and never branches on it
; again; the id indexes data_01_53c6_MenuTypeRecords, whose record says how the screen
; behaves and which SCRIPT builds it. A script is a list of commands, and a command is
; an opcode plus one or more parameter blocks. Between them the two tables and the
; script decide the layout, the text, the cursor, the palette and what each selectable
; row returns to the caller.
;
; Nothing is drawn directly to VRAM. The engine composites into three WRAM areas and
; flushes them at the end:
;
;   wD400_ScreenDraw_TileIds       one byte per visible tile - the BG tile ids
;   wD578_ScreenDraw_PaletteIds    the matching BG attribute bytes. Exactly
;                                  SCREEN_ATTR_PLANE_OFFSET above the first, which is
;                                  what lets one loop fill both
;   wC000_BgMapTileIds             the map's tile buffer, borrowed while a menu is up
;                                  and used as raw 2bpp tile GRAPHICS - this is where
;                                  text is rendered
;
; Reading the script
; ------------------
; call_01_446b_MenuScript_RunCommand is the routine to understand first. It reads one
; opcode, copies that opcode's shape - width, height, destination tile, first tile id,
; attribute byte - out of data_01_512e_MenuCmd_Descriptors into wDB9E..wDBA3, and then
; loops over MENUCMD_PARAM_BYTES-byte parameter blocks until one has
; MENUCMD_FLAG_LAST_BLOCK set. Per block it can:
;
;   register a row      wDBA9's low nibble is a row number and its high nibble the
;                       MENU_RESULT_* that row returns; the pair goes into
;                       wDBCB_Menu_OptionActions. This is how a script, not code,
;                       decides what "QUIT" means on this screen
;   call a sub-handler  if the block's source-pointer high byte is at or above
;                       MENUCMD_HANDLER_BASE it is not a pointer at all: the excess
;                       indexes data_01_456b_MenuCmd_SubHandlers and the low byte is
;                       the handler's argument. That is where everything screen-
;                       specific lives - the seventeen MenuCmd_* routines below
;   draw text           MENUCMD_FLAG_DRAW_TEXT runs the renderer over the block
;   fill the tilemap    consecutive tile ids across the block and a constant attribute
;                       byte, or transposed with MENUCMD_FLAG_TRANSPOSED
;
; The text renderer
; -----------------
; call_01_4875_Text_Render and friends do NOT write a tilemap. They composite glyph
; PIXELS into the wC000 staging buffer, XOR-ing each glyph in, which is why the
; password keyboard's highlight can be drawn and undrawn by drawing it twice. Glyphs
; are proportional and may straddle a tile boundary, so a glyph row is shifted into a
; 16-bit window and its two halves land in two different tiles. That machinery is
; call_01_48cd_Text_DrawGlyph and it is the densest routine in the file.
;
; Strings themselves live in BANK_1C_TEXT. call_00_0835_Text_LoadStringToBuffer copies
; one into wDADD_MenuTextBuffer and repoints the script's source pointer at the copy,
; so everything downstream reads WRAM. Watch for two operands in this file that LOOK
; like bank 1 labels and are really bank $1C addresses - see MENUTEXT_COUNTER_STRINGS
; and MENUTEXT_COLLECTED_SUFFIX in constants.asm.
;
; What is worth knowing before editing
; ------------------------------------
;   * wDADD is two things. It is the decompressed string buffer AND, for the sprite
;     builders, the OAM Y byte of a sprite record. Both uses are inherited from gex2,
;     which overloads wD5A6 the same way
;   * byte +8 of every menu record is $d3 and nothing reads it. Screen LCDC is
;     hardcoded to MENU_LCDC instead
;   * call_01_4cc3_Menu_GetVramAddrForDestTile has no callers at all
;   * two of the seventeen sub-handlers are duplicates of each other, and two more are
;     bare `ret`
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's code/menus/
; ------------------------------------------------------------------
; gex2 splits the same engine across ten files and gex3 keeps it in one, but routine
; for routine they are close enough that gex2's names have been adopted here
; throughout. The correspondence:
;
;   bank01_menu_load.asm     call_01_4000_MenuLoad and the MenuLoad_* entry points
;   bank01_menu_script.asm   MenuScript_Run* and every MenuCmd_* sub-handler
;   bank01_text_render.asm   Text_Render, Text_DrawGlyph, Text_WrapAndAlign,
;                            Text_MeasureLine, Text_SelectGlyph, Text_ClearBuffer
;   bank01_menu_sprites.asm  Menu_DrawCursor, Menu_BuildSpriteBlock,
;                            Menu_WriteSpriteRect, Menu_TickHideSprites
;   bank01_password.asm      the Password_* family
;   bank01_menu_tables.asm   MenuCmd_Descriptors, MenuTypeRecords, ChainedScriptTable
;
; Where they differ:
;
;   the command flags   the bit assignments in wDBAA_MenuCmd_Flags are NOT gex2's.
;                       MENUCMD_FLAG_LAST_BLOCK is $20 here where gex2 uses $80, and
;                       $80 here means "HDMA the staging buffer". Do not carry gex2's
;                       values across
;   sprite size         gex2's menu sprites are 8x16, so its rectangle writer steps
;                       the tile id by 2 and Y by $10. gex3's are 8x8, stepping 1 and
;                       $08 - see call_01_4c7e_Menu_WriteSpriteRect
;   the password        gex2 encodes 3 bits per box through a 660-byte lookup table.
;                       gex3 uses PASSWORD_BITS_PER_CELL bits per cell over a 32-key
;                       alphabet and does it in a loop, which is both smaller and
;                       carries more state - see call_01_4f8c_Password_BuildPayload
;   the text source     gex2's strings are in the same bank as the menu code; gex3
;                       moved them to BANK_1C_TEXT, which is why gex3 has
;                       call_00_0835_Text_LoadStringToBuffer and gex2 does the copy
;                       inline
;   the fonts           both use a descriptor table, but gex3 carries a fourth font -
;                       the 2x2-tile password alphabet in data_01_66f9_PasswordFont
; ==================================================================

call_01_4000_MenuLoad:
; Shows one menu and blocks until the player leaves it, returning the MENU_RESULT_*
; of whatever row they chose. The only entry point into the menu engine.
;
; Set-up: the MENU_* id in A indexes data_01_53c6_MenuTypeRecords and
; MENUTYPE_COPY_BYTES of that record are copied to wDB92 onwards. The current map id
; is stashed in wDBE8_Menu_StoredMapId and replaced with the level id, because the
; menu tables are indexed by map and a menu wants the level's row - the totals screen
; then walks wDB6C_CurrentMapId across MENU_TOTALS_PAGES pages as its own page number.
; call_01_43f0_Menu_BuildScreen draws the screen once.
;
; After that, wDB94_MenuType_Flags picks one of four loops. Three of them are
; non-interactive - hold for a while, hold until B, hold until any button - and are
; what the fourteen credit and interstitial screens use. The fourth is the real menu
; loop, and it splits again on MENU_FLAG_GRID_INPUT:
;
;   ordinary   up/down move wDBEC_MenuRowSelected within wDB95_MenuType_OptionCount,
;              A or START commits, and the answer is wDBCB_Menu_OptionActions[row] -
;              the byte the SCRIPT put there
;   password   two cursors at once. The d-pad moves the PASSWORD_KEY_* keyboard
;              cursor, A plus a direction moves the PASSWORD_GRID_* cell cursor, B
;              commits the highlighted character into the cell, START validates
;
; Note the dead branch at the password validation: both arms of the success/failure
; test load SFX_NONE, so the jingle that was meant to distinguish them does not play.
;
; gex2's call_01_4000_MenuLoad
    ld   HL, wDBE9_MenuTypeRelated                    ;; 01:4000 $21 $e9 $db
    ld   [HL], $00                                    ;; 01:4003 $36 $00
.jp_01_4005:
    ld   [wDBEA_MenuType], A                          ;; 01:4005 $ea $ea $db
    ld   L, A                                         ;; 01:4008 $6f
    ld   H, $00                                       ;; 01:4009 $26 $00
    add  HL, HL                                       ;; 01:400b $29
    add  HL, HL                                       ;; 01:400c $29
    add  HL, HL                                       ;; 01:400d $29
    add  HL, HL                                       ;; 01:400e $29
    ld   DE, data_01_53c6_MenuTypeRecords             ;; 01:400f $11 $c6 $53
    add  HL, DE                                       ;; 01:4012 $19
    ld   DE, wDB92_MenuTypeDataPointer                ;; 01:4013 $11 $92 $db
    ld   BC, MENUTYPE_COPY_BYTES                      ;; 01:4016 $01 $0c $00
    call call_00_076e_MemCopy                         ;; 01:4019 $cd $6e $07
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:401c $fa $6c $db
    ld   [wDBE8_Menu_StoredMapId], A                  ;; 01:401f $ea $e8 $db
    ld   A, [wDC1E_CurrentLevelID]                    ;; 01:4022 $fa $1e $dc
    ld   [wDB6C_CurrentMapId], A                      ;; 01:4025 $ea $6c $db
    cp   A, LEVEL_GEXTREME_SPORTS                     ;; 01:4028 $fe $07
    jr   C, .jr_01_4037_SkipZeroingMapID              ;; 01:402a $38 $0b
    ld   A, [wDBEA_MenuType]                          ;; 01:402c $fa $ea $db
    cp   A, MENU_TOTALS                               ;; 01:402f $fe $08
    jr   NZ, .jr_01_4037_SkipZeroingMapID             ;; 01:4031 $20 $04
    xor  A, A                                         ;; 01:4033 $af
    ld   [wDB6C_CurrentMapId], A  ; if on totals screen, set mapid to 0 ;; 01:4034 $ea $6c $db
.jr_01_4037_SkipZeroingMapID:
    farcall call_03_6c89_MapData_LoadForCurrentMap
    xor  A, A                                         ;; 01:4042 $af
    ld   [wDBEB_MenuColumnSelected], A                ;; 01:4043 $ea $eb $db
    ld   [wDBEC_MenuRowSelected], A                   ;; 01:4046 $ea $ec $db
    ld   [wDBED_PasswordColumnSelected], A            ;; 01:4049 $ea $ed $db
    ld   [wDBEE_PasswordRowSelected], A               ;; 01:404c $ea $ee $db
    ld   HL, wDB92_MenuTypeDataPointer                ;; 01:404f $21 $92 $db
    ld   A, [HL+]                                     ;; 01:4052 $2a
    ld   H, [HL]                                      ;; 01:4053 $66
    ld   L, A                                         ;; 01:4054 $6f
    call call_01_43f0_Menu_BuildScreen                ;; 01:4055 $cd $f0 $43
    ld   A, [wDB94_MenuType_Flags]                    ;; 01:4058 $fa $94 $db
    and  A, MENU_FLAG_HOLD                            ;; 01:405b $e6 $02
    jp   NZ, .jp_01_42c2                              ;; 01:405d $c2 $c2 $42
    ld   A, [wDB94_MenuType_Flags]                    ;; 01:4060 $fa $94 $db
    and  A, MENU_FLAG_HOLD_SKIPPABLE                  ;; 01:4063 $e6 $04
    jp   NZ, .jp_01_42d0                              ;; 01:4065 $c2 $d0 $42
    ld   A, [wDB94_MenuType_Flags]                    ;; 01:4068 $fa $94 $db
    and  A, MENU_FLAG_WAIT_RELEASE                    ;; 01:406b $e6 $08
    jp   NZ, .jp_01_42e2                              ;; 01:406d $c2 $e2 $42
.jp_01_4070:
    ld   A, MENU_CURSOR_NONE                          ;; 01:4070 $3e $ff
    ld   [wDBDC_Menu_BlinkCounter], A                 ;; 01:4072 $ea $dc $db
    call call_01_4d2c_Menu_WaitForNoInput             ;; 01:4075 $cd $2c $4d
.jp_01_4078:
    call call_01_4bb8_Menu_DrawCursor                 ;; 01:4078 $cd $b8 $4b
    call call_00_0b92_WaitForInterrupt                ;; 01:407b $cd $92 $0b
    call call_01_4b6b_Menu_TickHideSprites            ;; 01:407e $cd $6b $4b
    ld   HL, wDBDC_Menu_BlinkCounter                  ;; 01:4081 $21 $dc $db
    dec  [HL]                                         ;; 01:4084 $35
    ld   A, [wDB94_MenuType_Flags]                    ;; 01:4085 $fa $94 $db
    and  A, MENU_FLAG_GRID_INPUT                      ;; 01:4088 $e6 $01
    jp   Z, .jp_01_41cb                               ;; 01:408a $ca $cb $41
    ld   HL, wDAD7_RawInputs                          ;; 01:408d $21 $d7 $da
    bit  PADF_SELECT_BIT, [HL] ;                      ;; 01:4090 $cb $56
    jr   Z, .jr_01_40ad                               ;; 01:4092 $28 $19
    ld   A, SFX_MENU_SCROLL                           ;; 01:4094 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:4096 $cd $d7 $0f
    ld   A, [wDBE8_Menu_StoredMapId]                  ;; 01:4099 $fa $e8 $db
    ld   [wDB6C_CurrentMapId], A                      ;; 01:409c $ea $6c $db
    farcall call_03_6c89_MapData_LoadForCurrentMap
    jp   .jp_01_4285                                  ;; 01:40aa $c3 $85 $42
.jr_01_40ad:
    ld   A, [wDB95_MenuType_OptionCount]              ;; 01:40ad $fa $95 $db
    and  A, A                                         ;; 01:40b0 $a7
    jr   Z, .jp_01_4078                               ;; 01:40b1 $28 $c5
    bit  1, [HL]                                      ;; 01:40b3 $cb $4e
    jr   NZ, .jr_01_4111                              ;; 01:40b5 $20 $5a
    bit  0, [HL]                                      ;; 01:40b7 $cb $46
    jp   NZ, .jp_01_4180                              ;; 01:40b9 $c2 $80 $41
    bit  3, [HL]                                      ;; 01:40bc $cb $5e
    jp   NZ, .jp_01_415b                              ;; 01:40be $c2 $5b $41
    ld   A, [HL]                                      ;; 01:40c1 $7e
    and  A, $f0                                       ;; 01:40c2 $e6 $f0
    jr   Z, .jp_01_4078                               ;; 01:40c4 $28 $b2
    call call_00_0f6e_CheckInputRight                 ;; 01:40c6 $cd $6e $0f
    jr   Z, .jr_01_40d7                               ;; 01:40c9 $28 $0c
    ld   HL, wDBED_PasswordColumnSelected             ;; 01:40cb $21 $ed $db
    inc  [HL]                                         ;; 01:40ce $34
    ld   A, [HL]                                      ;; 01:40cf $7e
    sub  A, PASSWORD_KEY_COLUMNS                      ;; 01:40d0 $d6 $10
    jr   NZ, .jr_01_4109                              ;; 01:40d2 $20 $35
    ld   [HL], A                                      ;; 01:40d4 $77
    jr   .jr_01_4109                                  ;; 01:40d5 $18 $32
.jr_01_40d7:
    call call_00_0f68_CheckInputLeft                  ;; 01:40d7 $cd $68 $0f
    jr   Z, .jr_01_40e8                               ;; 01:40da $28 $0c
    ld   HL, wDBED_PasswordColumnSelected             ;; 01:40dc $21 $ed $db
    dec  [HL]                                         ;; 01:40df $35
    bit  7, [HL]                                      ;; 01:40e0 $cb $7e
    jr   Z, .jr_01_4109                               ;; 01:40e2 $28 $25
    ld   [HL], $0f                                    ;; 01:40e4 $36 $0f
    jr   .jr_01_4109                                  ;; 01:40e6 $18 $21
.jr_01_40e8:
    call call_00_0f7a_CheckInputDown                  ;; 01:40e8 $cd $7a $0f
    jr   Z, .jr_01_40f9                               ;; 01:40eb $28 $0c
    ld   HL, wDBEE_PasswordRowSelected                ;; 01:40ed $21 $ee $db
    inc  [HL]                                         ;; 01:40f0 $34
    ld   A, [HL]                                      ;; 01:40f1 $7e
    sub  A, PASSWORD_KEY_ROWS                         ;; 01:40f2 $d6 $02
    jr   NZ, .jr_01_4109                              ;; 01:40f4 $20 $13
    ld   [HL], A                                      ;; 01:40f6 $77
    jr   .jr_01_4109                                  ;; 01:40f7 $18 $10
.jr_01_40f9:
    call call_00_0f74_CheckInputUp                    ;; 01:40f9 $cd $74 $0f
    jp   Z, .jp_01_4078                               ;; 01:40fc $ca $78 $40
    ld   HL, wDBEE_PasswordRowSelected                ;; 01:40ff $21 $ee $db
    dec  [HL]                                         ;; 01:4102 $35
    bit  7, [HL]                                      ;; 01:4103 $cb $7e
    jr   Z, .jr_01_4109                               ;; 01:4105 $28 $02
    ld   [HL], $01                                    ;; 01:4107 $36 $01
.jr_01_4109:
    ld   A, SFX_MENU_SCROLL                           ;; 01:4109 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:410b $cd $d7 $0f
    jp   .jp_01_4070                                  ;; 01:410e $c3 $70 $40
.jr_01_4111:
    ld   HL, wDBEE_PasswordRowSelected                ;; 01:4111 $21 $ee $db
    ld   B, [HL]                                      ;; 01:4114 $46
    ld   A, $f0                                       ;; 01:4115 $3e $f0
.jr_01_4117:
    add  A, PASSWORD_KEY_COLUMNS                      ;; 01:4117 $c6 $10
    dec  B                                            ;; 01:4119 $05
    bit  7, B                                         ;; 01:411a $cb $78
    jr   Z, .jr_01_4117                               ;; 01:411c $28 $f9
    ld   HL, wDBED_PasswordColumnSelected             ;; 01:411e $21 $ed $db
    add  A, [HL]                                      ;; 01:4121 $86
    ld   C, A                                         ;; 01:4122 $4f
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:4123 $21 $ec $db
    ld   B, [HL]                                      ;; 01:4126 $46
    ld   A, $fa                                       ;; 01:4127 $3e $fa
.jr_01_4129:
    add  A, PASSWORD_GRID_COLUMNS                     ;; 01:4129 $c6 $06
    dec  B                                            ;; 01:412b $05
    bit  7, B                                         ;; 01:412c $cb $78
    jr   Z, .jr_01_4129                               ;; 01:412e $28 $f9
    ld   HL, wDBEB_MenuColumnSelected                 ;; 01:4130 $21 $eb $db
    add  A, [HL]                                      ;; 01:4133 $86
    ld   L, A                                         ;; 01:4134 $6f
    ld   H, $00                                       ;; 01:4135 $26 $00
    ld   DE, wDB7E_PasswordValues                     ;; 01:4137 $11 $7e $db
    add  HL, DE                                       ;; 01:413a $19
    ld   [HL], C                                      ;; 01:413b $71
    call call_01_4d6e_Password_RefreshCellGfx         ;; 01:413c $cd $6e $4d
    ld   HL, wDBEB_MenuColumnSelected                 ;; 01:413f $21 $eb $db
    inc  [HL]                                         ;; 01:4142 $34
    ld   A, [HL]                                      ;; 01:4143 $7e
    sub  A, PASSWORD_GRID_COLUMNS                     ;; 01:4144 $d6 $06
    jr   NZ, .jr_01_4153                              ;; 01:4146 $20 $0b
    ld   [HL], A                                      ;; 01:4148 $77
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:4149 $21 $ec $db
    inc  [HL]                                         ;; 01:414c $34
    ld   A, [HL]                                      ;; 01:414d $7e
    sub  A, PASSWORD_GRID_ROWS                        ;; 01:414e $d6 $03
    jr   NZ, .jr_01_4153                              ;; 01:4150 $20 $01
    ld   [HL], A                                      ;; 01:4152 $77
.jr_01_4153:
    ld   A, SFX_MENU_SCROLL                           ;; 01:4153 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:4155 $cd $d7 $0f
    jp   .jp_01_4070                                  ;; 01:4158 $c3 $70 $40
.jp_01_415b:
    call call_01_505a_Password_DecodeAndApply         ;; 01:415b $cd $5a $50
    push AF                                           ;; 01:415e $f5
    cp   A, PASSWORD_VALID                            ;; 01:415f $fe $20
    ld   A, SFX_NONE                                  ;; 01:4161 $3e $ff
    jr   Z, .jr_01_4167                               ;; 01:4163 $28 $02
    ld   A, SFX_NONE                                  ;; 01:4165 $3e $ff
.jr_01_4167:
    call call_00_0fd7_PlaySFX                         ;; 01:4167 $cd $d7 $0f
    ld   B, FRAMES_PER_SECOND                         ;; 01:416a $06 $3c
.jr_01_416c:
    push BC                                           ;; 01:416c $c5
    call call_00_0b92_WaitForInterrupt                ;; 01:416d $cd $92 $0b
    pop  BC                                           ;; 01:4170 $c1
    dec  B                                            ;; 01:4171 $05
    jr   NZ, .jr_01_416c                              ;; 01:4172 $20 $f8
    pop  AF                                           ;; 01:4174 $f1
    cp   A, PASSWORD_VALID                            ;; 01:4175 $fe $20
    ret  Z                                            ;; 01:4177 $c8
    ld   A, MENU_BAD_PASSWORD                         ;; 01:4178 $3e $04
    call call_01_4000_MenuLoad                        ;; 01:417a $cd $00 $40
    jp   .jp_01_42a1                                  ;; 01:417d $c3 $a1 $42
.jp_01_4180:
    call call_00_0f6e_CheckInputRight                 ;; 01:4180 $cd $6e $0f
    jr   Z, .jr_01_4191                               ;; 01:4183 $28 $0c
    ld   HL, wDBEB_MenuColumnSelected                 ;; 01:4185 $21 $eb $db
    inc  [HL]                                         ;; 01:4188 $34
    ld   A, [HL]                                      ;; 01:4189 $7e
    sub  A, PASSWORD_GRID_COLUMNS                     ;; 01:418a $d6 $06
    jr   NZ, .jr_01_41c3                              ;; 01:418c $20 $35
    ld   [HL], A                                      ;; 01:418e $77
    jr   .jr_01_41c3                                  ;; 01:418f $18 $32
.jr_01_4191:
    call call_00_0f68_CheckInputLeft                  ;; 01:4191 $cd $68 $0f
    jr   Z, .jr_01_41a2                               ;; 01:4194 $28 $0c
    ld   HL, wDBEB_MenuColumnSelected                 ;; 01:4196 $21 $eb $db
    dec  [HL]                                         ;; 01:4199 $35
    bit  7, [HL]                                      ;; 01:419a $cb $7e
    jr   Z, .jr_01_41c3                               ;; 01:419c $28 $25
    ld   [HL], $05                                    ;; 01:419e $36 $05
    jr   .jr_01_41c3                                  ;; 01:41a0 $18 $21
.jr_01_41a2:
    call call_00_0f7a_CheckInputDown                  ;; 01:41a2 $cd $7a $0f
    jr   Z, .jr_01_41b3                               ;; 01:41a5 $28 $0c
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:41a7 $21 $ec $db
    inc  [HL]                                         ;; 01:41aa $34
    ld   A, [HL]                                      ;; 01:41ab $7e
    sub  A, PASSWORD_GRID_ROWS                        ;; 01:41ac $d6 $03
    jr   NZ, .jr_01_41c3                              ;; 01:41ae $20 $13
    ld   [HL], A                                      ;; 01:41b0 $77
    jr   .jr_01_41c3                                  ;; 01:41b1 $18 $10
.jr_01_41b3:
    call call_00_0f74_CheckInputUp                    ;; 01:41b3 $cd $74 $0f
    jp   Z, .jp_01_4078                               ;; 01:41b6 $ca $78 $40
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:41b9 $21 $ec $db
    dec  [HL]                                         ;; 01:41bc $35
    bit  7, [HL]                                      ;; 01:41bd $cb $7e
    jr   Z, .jr_01_41c3                               ;; 01:41bf $28 $02
    ld   [HL], $02                                    ;; 01:41c1 $36 $02
.jr_01_41c3:
    ld   A, SFX_MENU_SCROLL                           ;; 01:41c3 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:41c5 $cd $d7 $0f
    jp   .jp_01_4070                                  ;; 01:41c8 $c3 $70 $40
.jp_01_41cb:
    ld   A, [wDB95_MenuType_OptionCount]              ;; 01:41cb $fa $95 $db
    and  A, A                                         ;; 01:41ce $a7
    jp   Z, .jp_01_41fc                               ;; 01:41cf $ca $fc $41
    call call_00_0f74_CheckInputUp                    ;; 01:41d2 $cd $74 $0f
    jr   Z, .jr_01_41e1                               ;; 01:41d5 $28 $0a
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:41d7 $21 $ec $db
    ld   A, [HL]                                      ;; 01:41da $7e
    and  A, A                                         ;; 01:41db $a7
    jr   Z, .jp_01_41fc                               ;; 01:41dc $28 $1e
    dec  [HL]                                         ;; 01:41de $35
    jr   .jr_01_41f1                                  ;; 01:41df $18 $10
.jr_01_41e1:
    call call_00_0f7a_CheckInputDown                  ;; 01:41e1 $cd $7a $0f
    jr   Z, .jp_01_41fc                               ;; 01:41e4 $28 $16
    ld   A, [wDB95_MenuType_OptionCount]              ;; 01:41e6 $fa $95 $db
    dec  A                                            ;; 01:41e9 $3d
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:41ea $21 $ec $db
    cp   A, [HL]                                      ;; 01:41ed $be
    jr   Z, .jp_01_41fc                               ;; 01:41ee $28 $0c
    inc  [HL]                                         ;; 01:41f0 $34
.jr_01_41f1:
    ld   A, SFX_MENU_SCROLL                           ;; 01:41f1 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:41f3 $cd $d7 $0f
    call call_01_43ba_Menu_OnSelectionChanged         ;; 01:41f6 $cd $ba $43
    jp   .jp_01_4070                                  ;; 01:41f9 $c3 $70 $40
.jp_01_41fc:
    ld   A, [wDB94_MenuType_Flags]                    ;; 01:41fc $fa $94 $db
    and  A, MENU_FLAG_PAGED                           ;; 01:41ff $e6 $10
    jr   Z, .jr_01_423c                               ;; 01:4201 $28 $39
    call call_00_0f6e_CheckInputRight                 ;; 01:4203 $cd $6e $0f
    jr   Z, .jr_01_4214                               ;; 01:4206 $28 $0c
    ld   HL, wDB6C_CurrentMapId                       ;; 01:4208 $21 $6c $db
    inc  [HL]                                         ;; 01:420b $34
    ld   A, [HL]                                      ;; 01:420c $7e
    sub  A, MENU_TOTALS_PAGES                         ;; 01:420d $d6 $07
    jr   NZ, .jr_01_4212                              ;; 01:420f $20 $01
    ld   [HL], A                                      ;; 01:4211 $77
.jr_01_4212:
    jr   .jr_01_4223                                  ;; 01:4212 $18 $0f
.jr_01_4214:
    call call_00_0f68_CheckInputLeft                  ;; 01:4214 $cd $68 $0f
    jr   Z, .jr_01_423c                               ;; 01:4217 $28 $23
    ld   HL, wDB6C_CurrentMapId                       ;; 01:4219 $21 $6c $db
    dec  [HL]                                         ;; 01:421c $35
    bit  7, [HL]                                      ;; 01:421d $cb $7e
    jr   Z, .jr_01_4223                               ;; 01:421f $28 $02
    ld   [HL], $06                                    ;; 01:4221 $36 $06
.jr_01_4223:
    farcall call_03_6c89_MapData_LoadForCurrentMap
    ld   HL, data_01_5692_MenuScript_Totals                             ;; 01:422e $21 $92 $56
    call call_01_4454_MenuScript_RunFrom              ;; 01:4231 $cd $54 $44
    ld   A, SFX_MENU_SCROLL                           ;; 01:4234 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:4236 $cd $d7 $0f
    jp   .jp_01_4070                                  ;; 01:4239 $c3 $70 $40
.jr_01_423c:
    call call_00_0f9c_CheckInputB                     ;; 01:423c $cd $9c $0f
    jp   Z, .jp_01_4078                               ;; 01:423f $ca $78 $40
    ld   A, SFX_MENU_SCROLL                           ;; 01:4242 $3e $01
    call call_00_0fd7_PlaySFX                         ;; 01:4244 $cd $d7 $0f
    call call_00_0f5e_WaitUntilNoInputPressed         ;; 01:4247 $cd $5e $0f
    ld   A, [wDBE8_Menu_StoredMapId]                  ;; 01:424a $fa $e8 $db
    ld   [wDB6C_CurrentMapId], A                      ;; 01:424d $ea $6c $db
    farcall call_03_6c89_MapData_LoadForCurrentMap
    ld   A, [wDB95_MenuType_OptionCount]              ;; 01:425b $fa $95 $db
    and  A, A                                         ;; 01:425e $a7
    jr   Z, .jp_01_4285                               ;; 01:425f $28 $24
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:4261 $21 $ec $db
    ld   L, [HL]                                      ;; 01:4264 $6e
    ld   H, $00                                       ;; 01:4265 $26 $00
    ld   DE, wDBCB_Menu_OptionActions                 ;; 01:4267 $11 $cb $db
    add  HL, DE                                       ;; 01:426a $19
    ld   A, [HL]                                      ;; 01:426b $7e
    cp   A, $10                                       ;; 01:426c $fe $10
    ret  Z                                            ;; 01:426e $c8
    cp   A, $60                                       ;; 01:426f $fe $60
    ret  Z                                            ;; 01:4271 $c8
    cp   A, $20                                       ;; 01:4272 $fe $20
    jr   Z, .jp_01_42a1                               ;; 01:4274 $28 $2b
    cp   A, $30                                       ;; 01:4276 $fe $30
    jr   Z, .jr_01_4290                               ;; 01:4278 $28 $16
    cp   A, $50                                       ;; 01:427a $fe $50
    jr   Z, .jr_01_42a9                               ;; 01:427c $28 $2b
    cp   A, $70                                       ;; 01:427e $fe $70
    jr   Z, .jr_01_42b7                               ;; 01:4280 $28 $35
    cp   A, $40                                       ;; 01:4282 $fe $40
    ret  Z                                            ;; 01:4284 $c8
.jp_01_4285:
    call call_00_0f5e_WaitUntilNoInputPressed         ;; 01:4285 $cd $5e $0f
    ld   A, [wDBE9_MenuTypeRelated]                   ;; 01:4288 $fa $e9 $db
    and  A, A                                         ;; 01:428b $a7
    jp   NZ, call_01_4000_MenuLoad                    ;; 01:428c $c2 $00 $40
    ret                                               ;; 01:428f $c9
.jr_01_4290:
    ld   A, [wDBEA_MenuType]                          ;; 01:4290 $fa $ea $db
    ld   [wDBE9_MenuTypeRelated], A                   ;; 01:4293 $ea $e9 $db
    call call_01_4f8c_Password_BuildPayload           ;; 01:4296 $cd $8c $4f
    call call_01_5027_Password_Encode                 ;; 01:4299 $cd $27 $50
    ld   A, MENU_SEE_PASSWORD                         ;; 01:429c $3e $02
    jp   .jp_01_4005                                  ;; 01:429e $c3 $05 $40
.jp_01_42a1:
    call call_01_4f7e_Password_ClearEntryGrid         ;; 01:42a1 $cd $7e $4f
    ld   A, MENU_ENTER_PASSWORD                       ;; 01:42a4 $3e $01
    jp   call_01_4000_MenuLoad                        ;; 01:42a6 $c3 $00 $40
.jr_01_42a9:
    ld   A, [wDC1E_CurrentLevelID]                    ;; 01:42a9 $fa $1e $dc
    and  A, A                                         ;; 01:42ac $a7
    ld   A, MENU_QUIT_GAME                            ;; 01:42ad $3e $0c
    jp   Z, .jp_01_4005                               ;; 01:42af $ca $05 $40
    ld   A, MENU_GO_TO_MAP                            ;; 01:42b2 $3e $0e
    jp   .jp_01_4005                                  ;; 01:42b4 $c3 $05 $40
.jr_01_42b7:
    ld   A, [wDBEA_MenuType]                          ;; 01:42b7 $fa $ea $db
    ld   [wDBE9_MenuTypeRelated], A                   ;; 01:42ba $ea $e9 $db
    ld   A, MENU_TOTALS                               ;; 01:42bd $3e $08
    jp   .jp_01_4005                                  ;; 01:42bf $c3 $05 $40
.jp_01_42c2:
    ld   BC, MENU_HOLD_FRAMES                         ;; 01:42c2 $01 $2c $01
.jr_01_42c5:
    push BC                                           ;; 01:42c5 $c5
    call call_00_0b92_WaitForInterrupt                ;; 01:42c6 $cd $92 $0b
    pop  BC                                           ;; 01:42c9 $c1
    dec  BC                                           ;; 01:42ca $0b
    ld   A, B                                         ;; 01:42cb $78
    or   A, C                                         ;; 01:42cc $b1
    jr   NZ, .jr_01_42c5                              ;; 01:42cd $20 $f6
    ret                                               ;; 01:42cf $c9
.jp_01_42d0:
    ld   BC, MENU_HOLD_SKIPPABLE_FRAMES               ;; 01:42d0 $01 $d0 $02
.jr_01_42d3:
    push BC                                           ;; 01:42d3 $c5
    call call_00_0b92_WaitForInterrupt                ;; 01:42d4 $cd $92 $0b
    call call_00_0f9c_CheckInputB                     ;; 01:42d7 $cd $9c $0f
    pop  BC                                           ;; 01:42da $c1
    ret  NZ                                           ;; 01:42db $c0
    dec  BC                                           ;; 01:42dc $0b
    ld   A, B                                         ;; 01:42dd $78
    or   A, C                                         ;; 01:42de $b1
    jr   NZ, .jr_01_42d3                              ;; 01:42df $20 $f2
    ret                                               ;; 01:42e1 $c9
.jp_01_42e2:
    call call_01_4d2c_Menu_WaitForNoInput             ;; 01:42e2 $cd $2c $4d
.jr_01_42e5:
    call call_01_4bb8_Menu_DrawCursor                 ;; 01:42e5 $cd $b8 $4b
    call call_00_0b92_WaitForInterrupt                ;; 01:42e8 $cd $92 $0b
    call call_01_4b6b_Menu_TickHideSprites            ;; 01:42eb $cd $6b $4b
    ld   HL, wDBDC_Menu_BlinkCounter                  ;; 01:42ee $21 $dc $db
    dec  [HL]                                         ;; 01:42f1 $35
    ld   A, [wDAD7_RawInputs]                         ;; 01:42f2 $fa $d7 $da
    and  A, A                                         ;; 01:42f5 $a7
    jr   Z, .jr_01_42e5                               ;; 01:42f6 $28 $ed
    ld   A, SFX_MENU_SCROLL                           ;; 01:42f8 $3e $01
    jp   call_00_0fd7_PlaySFX                         ;; 01:42fa $c3 $d7 $0f

call_01_42fd_MenuLoad_GameOver:
; Starts the game-over music and shows MENU_GAME_OVER. Three instructions; the
; caller in bank00_home.asm compares the result against MENU_RESULT_CONTINUE.
; gex2's call_01_43bd_MenuLoad_GameOver
    ld   A, SONG_GAME_OVER_OR_TIME_UP                 ;; 01:42fd $3e $15
    call call_00_0fa2_SetupMusic                      ;; 01:42ff $cd $a2 $0f
    ld   A, MENU_GAME_OVER                            ;; 01:4302 $3e $03
    jp   call_01_4000_MenuLoad                        ;; 01:4304 $c3 $00 $40

call_01_4307_MenuLoad_Credits:
; Plays the six end-credit screens back to back. Each of MENU_END_CREDITS_1 through
; _6 carries MENU_FLAG_HOLD_SKIPPABLE, so this is a straight run of six blocking
; calls with no logic of its own. It preloads nothing, whatever the old comment said.
; gex2's call_01_43c7_MenuLoad_Credits
    ld   A, SONG_CREDITS                              ;; 01:4307 $3e $19
    call call_00_0fa2_SetupMusic                      ;; 01:4309 $cd $a2 $0f
    ld   A, MENU_END_CREDITS_1                        ;; 01:430c $3e $15
    call call_01_4000_MenuLoad                        ;; 01:430e $cd $00 $40
    ld   A, MENU_END_CREDITS_2                        ;; 01:4311 $3e $16
    call call_01_4000_MenuLoad                        ;; 01:4313 $cd $00 $40
    ld   A, MENU_END_CREDITS_3                        ;; 01:4316 $3e $17
    call call_01_4000_MenuLoad                        ;; 01:4318 $cd $00 $40
    ld   A, MENU_END_CREDITS_4                        ;; 01:431b $3e $18
    call call_01_4000_MenuLoad                        ;; 01:431d $cd $00 $40
    ld   A, MENU_END_CREDITS_5                        ;; 01:4320 $3e $19
    call call_01_4000_MenuLoad                        ;; 01:4322 $cd $00 $40
    ld   A, MENU_END_CREDITS_6                        ;; 01:4325 $3e $1a
    call call_01_4000_MenuLoad                        ;; 01:4327 $cd $00 $40
    ret                                               ;; 01:432a $c9

call_01_432b_MenuLoad_MissionSelect:
; Shows the mission select for the TV the player just entered, and remembers which
; mission they picked in wDC5A_MissionNumberSelected.
;
; There are two versions of the screen and the map id chooses between them: the bonus
; and boss maps from MAP_GEXTREME_SPORTS1 up get MENU_MISSION_SELECT_1_REMOTE, and
; everything else gets MENU_MISSION_SELECT_3_REMOTES, with
; wDC59_NumRemotesOnMissionSelectMenu set to match. Returns immediately in Gex Cave,
; which has no missions.
;
; It touches no palette - the old name was wrong. gex2's
; call_01_4297_MenuLoad_MissionSelect
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:432b $fa $6c $db
    and  A, A                                         ;; 01:432e $a7
    ret  Z                                            ;; 01:432f $c8
    ld   A, SONG_GEX_CAVE                             ;; 01:4330 $3e $04
    call call_00_0fa2_SetupMusic                      ;; 01:4332 $cd $a2 $0f
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:4335 $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                      ;; 01:4338 $fe $07
    jr   C, .jr_01_434d                               ;; 01:433a $38 $11
    ld   A, $01                                       ;; 01:433c $3e $01
    ld   [wDC59_NumRemotesOnMissionSelectMenu], A     ;; 01:433e $ea $59 $dc
    ld   A, MENU_MISSION_SELECT_1_REMOTE              ;; 01:4341 $3e $05
    call call_01_4000_MenuLoad                        ;; 01:4343 $cd $00 $40
    ld   A, [wDBEC_MenuRowSelected]                   ;; 01:4346 $fa $ec $db
    ld   [wDC5A_MissionNumberSelected], A             ;; 01:4349 $ea $5a $dc
    ret                                               ;; 01:434c $c9
.jr_01_434d:
    ld   A, $03                                       ;; 01:434d $3e $03
    ld   [wDC59_NumRemotesOnMissionSelectMenu], A     ;; 01:434f $ea $59 $dc
    ld   A, MENU_MISSION_SELECT_3_REMOTES             ;; 01:4352 $3e $07
    call call_01_4000_MenuLoad                        ;; 01:4354 $cd $00 $40
    ld   A, [wDBEC_MenuRowSelected]                   ;; 01:4357 $fa $ec $db
    ld   [wDC5A_MissionNumberSelected], A             ;; 01:435a $ea $5a $dc
    ret                                               ;; 01:435d $c9

call_01_435e_MenuLoad_AfterLevel:
; Runs whatever screen belongs between finishing a level and being back in the cave,
; then leaves wDB6C_CurrentMapId at zero so the caller reloads the hub.
;
; The one branch that is not a menu comes first: in Gex Cave itself the level id is 0,
; and this routine simply copies wDC5B_LevelIdFromTVButton into wDB6C_CurrentMapId -
; that is the TV the player just walked into, and it is the only place the next
; destination is chosen. Everything else picks a screen:
;
;   bonus stage, timer expired   MENU_TIME_UP
;   bonus stage, won             MENU_WELL_DONE
;   an ordinary level            MENU_CONGRATULATIONS_GOT_REMOTE
;   the two boss levels          MENU_WELL_DONE
;   anything past those          the end credits
;
; So despite the old name, most of this routine is menu dispatch. gex2's
; call_01_42bd_HandleTVWarp covers the same ground
    ld   HL, wDB6A_WarpFlags                          ;; 01:435e $21 $6a $db
    res  4, [HL]                                      ;; 01:4361 $cb $a6
    ld   A, [wDC1E_CurrentLevelID]                    ;; 01:4363 $fa $1e $dc
    ld   [wDB6C_CurrentMapId], A                      ;; 01:4366 $ea $6c $db
    and  A, A                                         ;; 01:4369 $a7
    jr   Z, .jr_01_43b3_InGexCave1                    ;; 01:436a $28 $47
    ld   A, [wDB6D_InBonusStage]                      ;; 01:436c $fa $6d $db
    and  A, A                                         ;; 01:436f $a7
    jr   Z, .jr_01_4390_NotInBonusStage               ;; 01:4370 $28 $1e
    bit  5, [HL]                                      ;; 01:4372 $cb $6e
    jr   Z, .jr_01_4384                               ;; 01:4374 $28 $0e
    res  5, [HL]                                      ;; 01:4376 $cb $ae
    ld   A, SONG_GAME_OVER_OR_TIME_UP                 ;; 01:4378 $3e $15
    call call_00_0fa2_SetupMusic                      ;; 01:437a $cd $a2 $0f
    ld   A, MENU_TIME_UP                              ;; 01:437d $3e $0a
    call call_01_4000_MenuLoad                        ;; 01:437f $cd $00 $40
    jr   .jr_01_43ae                                  ;; 01:4382 $18 $2a
.jr_01_4384:
    ld   A, SONG_MISSION_SUCCESS                      ;; 01:4384 $3e $13
    call call_00_0fa2_SetupMusic                      ;; 01:4386 $cd $a2 $0f
    ld   A, MENU_WELL_DONE                            ;; 01:4389 $3e $1b
    call call_01_4000_MenuLoad                        ;; 01:438b $cd $00 $40
    jr   .jr_01_43ae                                  ;; 01:438e $18 $1e
.jr_01_4390_NotInBonusStage:
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:4390 $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                      ;; 01:4393 $fe $07
    jr   C, .jr_01_43a4_MapLessThan7 ; jump if map < gextremesports1 ;; 01:4395 $38 $0d
    cp   A, MAP_WW_GEX_WRESTLING1                     ;; 01:4397 $fe $09
    jr   Z, .jr_01_4384                               ;; 01:4399 $28 $e9
    cp   A, MAP_LIZARD_OF_OZ1                         ;; 01:439b $fe $0a
    jr   Z, .jr_01_4384                               ;; 01:439d $28 $e5
    call call_01_4307_MenuLoad_Credits                ;; 01:439f $cd $07 $43
    jr   .jr_01_43ae                                  ;; 01:43a2 $18 $0a
.jr_01_43a4_MapLessThan7:
    ld   A, SONG_MISSION_SUCCESS                      ;; 01:43a4 $3e $13
    call call_00_0fa2_SetupMusic                      ;; 01:43a6 $cd $a2 $0f
    ld   A, MENU_CONGRATULATIONS_GOT_REMOTE           ;; 01:43a9 $3e $09
    call call_01_4000_MenuLoad                        ;; 01:43ab $cd $00 $40
.jr_01_43ae:
    xor  A, A                                         ;; 01:43ae $af
    ld   [wDB6C_CurrentMapId], A                      ;; 01:43af $ea $6c $db
    ret                                               ;; 01:43b2 $c9
.jr_01_43b3_InGexCave1:
    ld   A, [wDC5B_LevelIdFromTVButton]               ;; 01:43b3 $fa $5b $dc
    ld   [wDB6C_CurrentMapId], A                      ;; 01:43b6 $ea $6c $db
    ret                                               ;; 01:43b9 $c9

call_01_43ba_Menu_OnSelectionChanged:
; Calls this menu's own callback, if it has one - the pointer in byte +$0A of its
; record. Returns quietly when the pointer is zero, which it is for all but one menu.
;
; It runs twice: once when the screen has been built, and again every time the row
; cursor moves. That is what makes it a "selection changed" hook rather than a general
; dispatcher. gex2's call_01_43e6_Menu_OnSelectionChanged
    ld   HL, wDB9C_MenuType_OnSelectionChanged        ;; 01:43ba $21 $9c $db
    ld   A, [HL+]                                     ;; 01:43bd $2a
    ld   H, [HL]                                      ;; 01:43be $66
    ld   L, A                                         ;; 01:43bf $6f
    or   A, H                                         ;; 01:43c0 $b4
    ret  Z                                            ;; 01:43c1 $c8
    jp   HL                                           ;; 01:43c2 $e9

call_01_43c3_Menu_HighlightTitleOption:
; The title screen's callback, and the only one in the game. Copies two OBJ palettes
; into wDD4A_ObjectPalettes, choosing between two sources eight bytes apart - so the
; two copies are the same pair of palettes in opposite order, and the effect is that
; the selected option is bright and the other dim.
;
; Reached only through call_01_43ba_Menu_OnSelectionChanged; nothing calls it by
; name
    ld   HL, .data_01_43d8                            ;; 01:43c3 $21 $d8 $43
    ld   A, [wDBEC_MenuRowSelected]                   ;; 01:43c6 $fa $ec $db
    and  A, A                                         ;; 01:43c9 $a7
    jr   Z, .jr_01_43cf                               ;; 01:43ca $28 $03
    ld   HL, .data_01_43e0                            ;; 01:43cc $21 $e0 $43
.jr_01_43cf:
    ld   DE, wDD4A_ObjectPalettes                     ;; 01:43cf $11 $4a $dd
    ld   BC, CGB_PALETTE_SIZE * 2                     ;; 01:43d2 $01 $10 $00
    jp   call_00_076e_MemCopy                         ;; 01:43d5 $c3 $6e $07
.data_01_43d8:
    db   $00, $00, $ff, $7f, $f7, $5e, $ef, $3d       ;; 01:43d8 ........
.data_01_43e0:
    db   $00, $00, $ef, $3d, $6b, $2d, $e7, $1c       ;; 01:43e0 ........
    db   $00, $00, $ff, $7f, $f7, $5e, $ef, $3d       ;; 01:43e8 ........

call_01_43f0_Menu_BuildScreen:
; Builds one menu screen and returns. Runs once per screen, not once per frame -
; the old "MainLoop" name was doubly wrong.
;
; Clears the video state, both screen planes and the tile staging buffer, declares no
; cursor and no sprite-hide timer, and installs LCD_ISR_MENU_GFX_STREAM. Then it runs
; the menu's script through call_01_445c_MenuScript_RunToEnd. A command may set
; wDBDD_Menu_ChainedScript, and if it did, the chosen script from
; data_01_5596_ChainedScriptTable is run too - so a screen can be assembled from a
; common part plus a variable part.
;
; Only when the chain is exhausted does anything reach VRAM: the attribute plane, then
; the tile-id plane, then the palette set unless MENU_PALETTE_NONE_BIT says this
; screen keeps the current one. Finally the per-menu callback, MENU_LCDC, and
; wDD6A_PalettesReadyFlag - which is what un-blanks the screen, so the whole build is
; invisible.
;
; gex2's call_01_446f_LoadMenuGraphics
    push HL                                           ;; 01:43f0 $e5
    call call_00_0e3b_ResetVideoState                 ;; 01:43f1 $cd $3b $0e
    call call_00_0e62_ClearShadowOamAndResetScroll    ;; 01:43f4 $cd $62 $0e
    call call_01_4f27_Menu_ClearScreenBuffers         ;; 01:43f7 $cd $27 $4f
    ld   A, MENU_CURSOR_NONE                          ;; 01:43fa $3e $ff
    ld   [wDBC7_Menu_CursorSpriteId], A               ;; 01:43fc $ea $c7 $db
    xor  A, A                                         ;; 01:43ff $af
    ld   [wDBDE_Menu_HideSpritesDelay], A             ;; 01:4400 $ea $de $db
    ld   [wDBE3_Menu_AnimateFlag], A                  ;; 01:4403 $ea $e3 $db
    ld   A, LCD_ISR_MENU_GFX_STREAM                   ;; 01:4406 $3e $0a
    call call_00_0c10_RequestLcdIsr                   ;; 01:4408 $cd $10 $0c
    pop  HL                                           ;; 01:440b $e1
.jr_01_440c:
    ld   A, L                                         ;; 01:440c $7d
    ld   [wDBB9_MenuScript_Ptr], A                    ;; 01:440d $ea $b9 $db
    ld   A, H                                         ;; 01:4410 $7c
    ld   [wDBB9_MenuScript_Ptr+1], A                  ;; 01:4411 $ea $ba $db
    ld   A, MENU_CHAINED_NONE                         ;; 01:4414 $3e $ff
    ld   [wDBDD_Menu_ChainedScript], A                ;; 01:4416 $ea $dd $db
    call call_01_445c_MenuScript_RunToEnd             ;; 01:4419 $cd $5c $44
    ld   A, [wDBDD_Menu_ChainedScript]                ;; 01:441c $fa $dd $db
    cp   A, MENU_CHAINED_NONE                         ;; 01:441f $fe $ff
    jr   Z, .jr_01_442b                               ;; 01:4421 $28 $08
    ld   DE, data_01_5596_ChainedScriptTable          ;; 01:4423 $11 $96 $55
    call call_00_0777_GetPointerFromTable             ;; 01:4426 $cd $77 $07
    jr   .jr_01_440c                                  ;; 01:4429 $18 $e1
.jr_01_442b:
    call call_01_4f51_Menu_UploadBgAttrMap            ;; 01:442b $cd $51 $4f
    call call_01_4f5c_Menu_UploadBgTileMap            ;; 01:442e $cd $5c $4f
    ld   HL, wDB9B_MenuType_PaletteId                 ;; 01:4431 $21 $9b $db
    bit  MENU_PALETTE_NONE_BIT, [HL]                  ;; 01:4434 $cb $7e
    jr   NZ, .jr_01_4444                              ;; 01:4436 $20 $0c
    ld   C, [HL]                                      ;; 01:4438 $4e
    farcall call_03_65c6_Palettes_LoadForScreen
.jr_01_4444:
    call call_01_43ba_Menu_OnSelectionChanged         ;; 01:4444 $cd $ba $43
    ld   A, MENU_LCDC                                 ;; 01:4447 $3e $d3
    call call_00_0e33_SetLCDCAndWait                  ;; 01:4449 $cd $33 $0e
    ld   A, $01                                       ;; 01:444c $3e $01
    ld   [wDD6A_PalettesReadyFlag], A                 ;; 01:444e $ea $6a $dd
    jp   call_00_0b92_WaitForInterrupt                ;; 01:4451 $c3 $92 $0b

call_01_4454_MenuScript_RunFrom:
; Points the script cursor at HL and FALLS THROUGH into the runner below, so this
; runs the whole script rather than merely setting a pointer.
;
; Its one caller is the totals screen's page turn, which re-runs the same script after
; changing the page number. gex2's call_01_44cf_MenuScript_RunFrom, which is the same
; fall-through construct
    ld   A, L                                         ;; 01:4454 $7d
    ld   [wDBB9_MenuScript_Ptr], A                    ;; 01:4455 $ea $b9 $db
    ld   A, H                                         ;; 01:4458 $7c
    ld   [wDBB9_MenuScript_Ptr+1], A                  ;; 01:4459 $ea $ba $db

call_01_445c_MenuScript_RunToEnd:
; Runs commands until MENUSCRIPT_END. Note it reloads wDBB9_MenuScript_Ptr from WRAM
; on every iteration rather than keeping it in a register: a command is free to
; redirect the script, and this is what lets it. gex2's
; call_01_44d7_MenuScript_RunToEnd
    ld   HL, wDBB9_MenuScript_Ptr                     ;; 01:445c $21 $b9 $db
    ld   A, [HL+]                                     ;; 01:445f $2a
    ld   H, [HL]                                      ;; 01:4460 $66
    ld   L, A                                         ;; 01:4461 $6f
    ld   A, [HL]                                      ;; 01:4462 $7e
    cp   A, MENUSCRIPT_END                            ;; 01:4463 $fe $ff
    ret  Z                                            ;; 01:4465 $c8
    call call_01_446b_MenuScript_RunCommand           ;; 01:4466 $cd $6b $44
    jr   call_01_445c_MenuScript_RunToEnd             ;; 01:4469 $18 $f1

call_01_446b_MenuScript_RunCommand:
; One command. The heart of the file - the file header walks through what it can do.
;
; The opcode is consumed first and its shape copied out of
; data_01_512e_MenuCmd_Descriptors. Then the parameter-block loop, which is a real
; loop: blocks are processed until one carries MENUCMD_FLAG_LAST_BLOCK, so a single
; opcode can paint several places on the screen.
;
; The tilemap fill at the end is one piece of code writing two planes. It computes the
; destination once as wD400_ScreenDraw_TileIds + Y*20 + X, fills the attribute plane
; SCREEN_ATTR_PLANE_OFFSET above it, then fills the tile-id plane with consecutive ids
; from wDBA2_MenuCmd_FirstTileId. MENUCMD_FLAG_TRANSPOSED swaps the two loop counters
; and the SCREEN_FILL_STEP_* pair, which is the whole of "draw this block sideways".
;
; gex2's call_01_44e6_MenuScript_RunCommand
    ld   HL, wDBB9_MenuScript_Ptr                     ;; 01:446b $21 $b9 $db
    ld   E, [HL]                                      ;; 01:446e $5e
    inc  HL                                           ;; 01:446f $23
    ld   D, [HL]                                      ;; 01:4470 $56
    ld   A, [DE]                                      ;; 01:4471 $1a
    inc  DE                                           ;; 01:4472 $13
    ld   [HL], D                                      ;; 01:4473 $72
    dec  HL                                           ;; 01:4474 $2b
    ld   [HL], E                                      ;; 01:4475 $73
    ld   [wDBCA_MenuCmd_Id], A                        ;; 01:4476 $ea $ca $db
    ld   L, A                                         ;; 01:4479 $6f
    ld   H, $00                                       ;; 01:447a $26 $00
    add  HL, HL                                       ;; 01:447c $29
    add  HL, HL                                       ;; 01:447d $29
    add  HL, HL                                       ;; 01:447e $29
    ld   DE, data_01_512e_MenuCmd_Descriptors         ;; 01:447f $11 $2e $51
    add  HL, DE                                       ;; 01:4482 $19
    ld   DE, wDB9E_MenuCmd_WidthTiles                 ;; 01:4483 $11 $9e $db
    ld   BC, MENUCMD_DESCRIPTOR_COPY_BYTES            ;; 01:4486 $01 $06 $00
    call call_00_076e_MemCopy                         ;; 01:4489 $cd $6e $07
.jr_01_448c:
    ld   HL, wDBB9_MenuScript_Ptr                     ;; 01:448c $21 $b9 $db
    ld   A, [HL+]                                     ;; 01:448f $2a
    ld   H, [HL]                                      ;; 01:4490 $66
    ld   L, A                                         ;; 01:4491 $6f
    ld   DE, wDBA4_Text_PenX                          ;; 01:4492 $11 $a4 $db
    ld   BC, MENUCMD_PARAM_BYTES                      ;; 01:4495 $01 $07 $00
    call call_00_076e_MemCopy                         ;; 01:4498 $cd $6e $07
    ld   A, L                                         ;; 01:449b $7d
    ld   [wDBB9_MenuScript_Ptr], A                    ;; 01:449c $ea $b9 $db
    ld   A, H                                         ;; 01:449f $7c
    ld   [wDBB9_MenuScript_Ptr+1], A                  ;; 01:44a0 $ea $ba $db
    ld   A, [wDBA9_MenuCmd_OptionSlot]                ;; 01:44a3 $fa $a9 $db
    and  A, MENUCMD_OPTION_ROW_MASK                   ;; 01:44a6 $e6 $0f
    ld   L, A                                         ;; 01:44a8 $6f
    ld   H, $00                                       ;; 01:44a9 $26 $00
    ld   DE, wDBCB_Menu_OptionActions                 ;; 01:44ab $11 $cb $db
    add  HL, DE                                       ;; 01:44ae $19
    ld   A, [wDBA9_MenuCmd_OptionSlot]                ;; 01:44af $fa $a9 $db
    and  A, MENUCMD_OPTION_ACTION_MASK                ;; 01:44b2 $e6 $f0
    ld   [HL], A                                      ;; 01:44b4 $77
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44b5 $fa $aa $db
    and  A, MENUCMD_FLAG_CLEAR_BUFFER                 ;; 01:44b8 $e6 $01
    call NZ, call_01_499f_Text_ClearBuffer            ;; 01:44ba $c4 $9f $49
    ld   A, [wDBA8_MenuCmd_SrcPtrHi]                  ;; 01:44bd $fa $a8 $db
    sub  A, MENUCMD_HANDLER_BASE                      ;; 01:44c0 $d6 $e0
    jr   C, .jr_01_44cd                               ;; 01:44c2 $38 $09
    ld   DE, .data_01_456b_MenuCmd_SubHandlers        ;; 01:44c4 $11 $6b $45
    call call_00_0777_GetPointerFromTable             ;; 01:44c7 $cd $77 $07
    call call_00_0f22_JumpHL                          ;; 01:44ca $cd $22 $0f
.jr_01_44cd:
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44cd $fa $aa $db
    and  A, MENUCMD_FLAG_DRAW_TEXT                    ;; 01:44d0 $e6 $02
    call NZ, call_01_4875_Text_Render                 ;; 01:44d2 $c4 $75 $48
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44d5 $fa $aa $db
    and  A, MENUCMD_FLAG_LAST_BLOCK                   ;; 01:44d8 $e6 $20
    jr   Z, .jr_01_448c                               ;; 01:44da $28 $b0
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44dc $fa $aa $db
    and  A, MENUCMD_FLAG_NO_TILE_FILL                 ;; 01:44df $e6 $40
    jp   NZ, .jp_01_4560                              ;; 01:44e1 $c2 $60 $45
    ld   HL, wDBA0_MenuCmd_DestTileX                  ;; 01:44e4 $21 $a0 $db
    ld   E, [HL]                                      ;; 01:44e7 $5e
    ld   D, $00                                       ;; 01:44e8 $16 $00
    inc  HL                                           ;; 01:44ea $23
    ld   L, [HL]                                      ;; 01:44eb $6e
    ld   H, D                                         ;; 01:44ec $62
    add  HL, HL                                       ;; 01:44ed $29
    add  HL, HL                                       ;; 01:44ee $29
    ld   C, L                                         ;; 01:44ef $4d
    ld   B, H                                         ;; 01:44f0 $44
    add  HL, HL                                       ;; 01:44f1 $29
    add  HL, HL                                       ;; 01:44f2 $29
    add  HL, BC                                       ;; 01:44f3 $09
    add  HL, DE                                       ;; 01:44f4 $19
    ld   DE, wD400_ScreenDraw_TileIds                 ;; 01:44f5 $11 $00 $d4
    add  HL, DE                                       ;; 01:44f8 $19
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44f9 $fa $aa $db
    and  A, MENUCMD_FLAG_TRANSPOSED                   ;; 01:44fc $e6 $04
    jr   NZ, .jr_01_450d                              ;; 01:44fe $20 $0d
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:4500 $fa $9e $db
    ld   B, A                                         ;; 01:4503 $47
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:4504 $fa $9f $db
    ld   C, A                                         ;; 01:4507 $4f
    ld   DE, SCREEN_FILL_STEP_ROWS                    ;; 01:4508 $11 $01 $14
    jr   .jr_01_4518                                  ;; 01:450b $18 $0b
.jr_01_450d:
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:450d $fa $9e $db
    ld   C, A                                         ;; 01:4510 $4f
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:4511 $fa $9f $db
    ld   B, A                                         ;; 01:4514 $47
    ld   DE, SCREEN_FILL_STEP_COLUMNS                 ;; 01:4515 $11 $14 $01
.jr_01_4518:
    push HL                                           ;; 01:4518 $e5
    push BC                                           ;; 01:4519 $c5
    ld   BC, SCREEN_ATTR_PLANE_OFFSET                 ;; 01:451a $01 $78 $01
    add  HL, BC                                       ;; 01:451d $09
    pop  BC                                           ;; 01:451e $c1
    push BC                                           ;; 01:451f $c5
    ld   A, [wDBA3_MenuCmd_AttrByte]                  ;; 01:4520 $fa $a3 $db
    cp   A, MENUCMD_ATTR_TILESET_ROW                  ;; 01:4523 $fe $ff
    jr   NZ, .jr_01_452e                              ;; 01:4525 $20 $07
    call call_00_0800_Screen_LoadSecondaryTilesetRow  ;; 01:4527 $cd $00 $08
    pop  BC                                           ;; 01:452a $c1
    pop  HL                                           ;; 01:452b $e1
    jr   .jr_01_4546                                  ;; 01:452c $18 $18
.jr_01_452e:
    push BC                                           ;; 01:452e $c5
    push DE                                           ;; 01:452f $d5
    push DE                                           ;; 01:4530 $d5
    push HL                                           ;; 01:4531 $e5
    ld   D, $00                                       ;; 01:4532 $16 $00
.jr_01_4534:
    ld   [HL], A                                      ;; 01:4534 $77
    add  HL, DE                                       ;; 01:4535 $19
    dec  B                                            ;; 01:4536 $05
    jr   NZ, .jr_01_4534                              ;; 01:4537 $20 $fb
    pop  HL                                           ;; 01:4539 $e1
    pop  DE                                           ;; 01:453a $d1
    ld   E, D                                         ;; 01:453b $5a
    ld   D, $00                                       ;; 01:453c $16 $00
    add  HL, DE                                       ;; 01:453e $19
    pop  DE                                           ;; 01:453f $d1
    pop  BC                                           ;; 01:4540 $c1
    dec  C                                            ;; 01:4541 $0d
    jr   NZ, .jr_01_452e                              ;; 01:4542 $20 $ea
    pop  BC                                           ;; 01:4544 $c1
    pop  HL                                           ;; 01:4545 $e1
.jr_01_4546:
    ld   A, [wDBA2_MenuCmd_FirstTileId]               ;; 01:4546 $fa $a2 $db
.jr_01_4549:
    push BC                                           ;; 01:4549 $c5
    push DE                                           ;; 01:454a $d5
    push DE                                           ;; 01:454b $d5
    push HL                                           ;; 01:454c $e5
    ld   D, $00                                       ;; 01:454d $16 $00
.jr_01_454f:
    ld   [HL], A                                      ;; 01:454f $77
    inc  A                                            ;; 01:4550 $3c
    add  HL, DE                                       ;; 01:4551 $19
    dec  B                                            ;; 01:4552 $05
    jr   NZ, .jr_01_454f                              ;; 01:4553 $20 $fa
    pop  HL                                           ;; 01:4555 $e1
    pop  DE                                           ;; 01:4556 $d1
    ld   E, D                                         ;; 01:4557 $5a
    ld   D, $00                                       ;; 01:4558 $16 $00
    add  HL, DE                                       ;; 01:455a $19
    pop  DE                                           ;; 01:455b $d1
    pop  BC                                           ;; 01:455c $c1
    dec  C                                            ;; 01:455d $0d
    jr   NZ, .jr_01_4549                              ;; 01:455e $20 $e9
.jp_01_4560:
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:4560 $fa $aa $db
    and  A, MENUCMD_FLAG_UPLOAD_TILES                 ;; 01:4563 $e6 $80
    ret  Z                                            ;; 01:4565 $c8
    ld   C, HDMACFG_WRAM_TILES_BANK0                  ;; 01:4566 $0e $09
    jp   call_00_0a6a_Hdma_RunConfigEntry             ;; 01:4568 $c3 $6a $0a
.data_01_456b_MenuCmd_SubHandlers: ; probably menutype jump table
; Behavior:
; List of function pointers (call_01_458d_MenuCmd_StageImage1, call_01_4599_MenuCmd_StageImage2, etc.) for specific menu command handlers.
; Likely Purpose: Dispatch table for specialized menu drawing or behavior.
    dw   call_01_458d_MenuCmd_StageImage1             ;; 01:456b ??
    dw   call_01_4599_MenuCmd_StageImage2             ;; 01:456d pP
    dw   call_01_45a5_MenuCmd_StageTVScreen           ;; 01:456f pP
    dw   call_01_466f_MenuCmd_SetLevelText            ;; 01:4571 pP
    dw   call_01_4675_MenuCmd_SetTVNameText           ;; 01:4573 pP
    dw   call_01_467b_MenuCmd_SetMissionText          ;; 01:4575 pP
    dw   call_01_46d4_MenuCmd_DrawCursorSprite        ;; 01:4577 pP
    dw   call_01_46f9_MenuCmd_EnableSpriteAnimation   ;; 01:4579 pP
    dw   call_01_470c_MenuCmd_SetCounterText          ;; 01:457b pP
    dw   call_01_4760_MenuCmd_DrawSpriteGroup         ;; 01:457d pP
    dw   call_01_477b_MenuCmd_NoOp                    ;; 01:457f ??
    dw   call_01_477c_MenuCmd_StagePasswordGlyph      ;; 01:4581 pP
    dw   call_01_47aa_MenuCmd_SetChainedScript        ;; 01:4583 pP
    dw   call_01_47b1_MenuCmd_LoadFullscreenImage     ;; 01:4585 pP
    dw   call_01_480c_MenuCmd_SetCollectedCountText
    dw   call_01_4825_MenuCmd_NoOp2
    dw   call_01_4826_MenuCmd_DrawRemoteMarker

call_01_458d_MenuCmd_StageImage1:
; Sub-handler $E0. Stages one small image from data_01_6f39_ImageTable into the tile
; buffer.
;
; This routine and call_01_4599_MenuCmd_StageImage2 below are byte for byte the same -
; same table, same target. gex2's $E0 and $E1 handlers use two DIFFERENT image tables;
; gex3 collapsed them onto one and kept both slots, so the two opcodes are aliases.
; gex2's call_01_4653_MenuCmd_StageImage1
    ld   a,[wDBA7_MenuCmd_SrcPtr]
    ld   de,data_01_6f39_ImageTable
    call call_00_0777_GetPointerFromTable
    jp   call_01_4d03_Menu_StageTileData

call_01_4599_MenuCmd_StageImage2:
; Sub-handler $E1, and identical to the one above. This is the copy with a second
; caller: call_01_46d4_MenuCmd_DrawCursorSprite uses it directly to stage the cursor
; graphic. gex2's call_01_465f_MenuCmd_StageImage2
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:4599 $fa $a7 $db
    ld   DE, data_01_6f39_ImageTable                  ;; 01:459c $11 $39 $6f
    call call_00_0777_GetPointerFromTable             ;; 01:459f $cd $77 $07
    jp   call_01_4d03_Menu_StageTileData              ;; 01:45a2 $c3 $03 $4d

call_01_45a5_MenuCmd_StageTVScreen:
; Sub-handler $E2. Loads eight BG palettes from the inline table, overwrites the last
; four of them with the current map's own palettes out of BANK_1F_SECONDARY_TILESETS,
; and stages an 8x6 tile picture from that same tileset - the image inside the TV on
; the mission select screen.
;
; The `ld DE, $330` is the offset of the palette block inside a secondary tileset
; record and is otherwise unexplained; the `$c010` destination is
; wC000_BgMapTileIds one tile in.
;
; gex2's call_01_466b_MenuCmd_StageTVScreen does the same job with a 6x5 picture
    ld   HL, .data_01_45ef                            ;; 01:45a5 $21 $ef $45
    ld   DE, wDCEA_BgPalettes                         ;; 01:45a8 $11 $ea $dc
    ld   BC, $80                                      ;; 01:45ab $01 $80 $00
    call call_00_076e_MemCopy                         ;; 01:45ae $cd $6e $07
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:45b1 $fa $6c $db
    ld   DE, data_00_0b01_SecondaryTilesetPtrs        ;; 01:45b4 $11 $01 $0b
    call call_00_0777_GetPointerFromTable             ;; 01:45b7 $cd $77 $07
    ld   DE, $330                                     ;; 01:45ba $11 $30 $03
    add  HL, DE                                       ;; 01:45bd $19
    ld   DE, wDD0A_BgPalettes                         ;; 01:45be $11 $0a $dd
    ld   BC, $20                                      ;; 01:45c1 $01 $20 $00
    ld   A, BANK_1F_SECONDARY_TILESETS                ;; 01:45c4 $3e $1f
    call call_00_075f_FarMemCopy                      ;; 01:45c6 $cd $5f $07
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:45c9 $fa $6c $db
    ld   DE, data_00_0b01_SecondaryTilesetPtrs        ;; 01:45cc $11 $01 $0b
    call call_00_0777_GetPointerFromTable             ;; 01:45cf $cd $77 $07
    ld   A, [wDBA6_MenuCmd_Arg2]                      ;; 01:45d2 $fa $a6 $db
    ld   [wDBA2_MenuCmd_FirstTileId], A               ;; 01:45d5 $ea $a2 $db
    ld   A, $08                                       ;; 01:45d8 $3e $08
    ld   [wDB9E_MenuCmd_WidthTiles], A                ;; 01:45da $ea $9e $db
    ld   A, $06                                       ;; 01:45dd $3e $06
    ld   [wDB9F_MenuCmd_HeightTiles], A               ;; 01:45df $ea $9f $db
    push HL                                           ;; 01:45e2 $e5
    call call_01_4ce5_Menu_GetTileDataSize            ;; 01:45e3 $cd $e5 $4c
    pop  HL                                           ;; 01:45e6 $e1
    ld   DE, $c010                                    ;; 01:45e7 $11 $10 $c0 ; wC000_BgMapTileIds
    ld   A, BANK_1F_SECONDARY_TILESETS                ;; 01:45ea $3e $1f
    jp   call_00_075f_FarMemCopy                      ;; 01:45ec $c3 $5f $07
.data_01_45ef:
    db   $00, $00, $00, $40, $ff, $03, $ff, $7f       ;; 01:45ef ........
    db   $00, $40, $ff, $03, $73, $02, $29, $01       ;; 01:45f7 ........
    db   $00, $40, $bf, $1e, $fa, $11, $2d, $11       ;; 01:45ff ........
    db   $00, $00, $00, $40, $ff, $7f, $80, $03       ;; 01:4607 ........
    db   $00, $40, $00, $00, $73, $4e, $1f, $00       ;; 01:460f ........
    db   $00, $40, $00, $00, $1f, $00, $ff, $03       ;; 01:4617 ........
    db   $00, $40, $00, $00, $60, $02, $9c, $03       ;; 01:461f ........
    db   $00, $40, $00, $00, $ff, $03, $e0, $03       ;; 01:4627 ........

    db   $00, $00, $80, $00, $20, $02, $20, $03       ;; 01:462f ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4637 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:463f ........
    db   $00, $00, $00, $00, $73, $4e, $1f, $00       ;; 01:4647 ........
    db   $00, $00, $ef, $3d, $f7, $5e, $ff, $7f       ;; 01:464f ........
    db   $00, $00, $ef, $01, $f7, $02, $ff, $03       ;; 01:4657 ........
    db   $00, $00, $00, $00, $20, $03, $bf, $0b       ;; 01:465f ........
    db   $00, $00, $1f, $00, $ff, $01, $7f, $03       ;; 01:4667 ........

call_01_466f_MenuCmd_SetLevelText:
; Sub-handler $E3. Points the text source at record 0 of this map's text block, i.e.
; the level name. Two calls and no logic; the offset lives in
; call_01_4b22_MenuText_GetLevelNameTable.
;
; It draws nothing - the DRAW_TEXT flag on this or a later block does that. gex2's
; call_01_4734_MenuCmd_SetLevelText
    call call_01_4b22_MenuText_GetLevelNameTable      ;; 01:466f $cd $22 $4b
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:4672 $c3 $fa $4c

call_01_4675_MenuCmd_SetTVNameText:
; Sub-handler $E4. The same for record 1 of the block, ten bytes further in - the TV's
; name. gex2's call_01_4728_MenuCmd_SetTVNameText
    call call_01_4b2a_MenuText_GetTVNameTable         ;; 01:4675 $cd $2a $4b
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:4678 $c3 $fa $4c

call_01_467b_MenuCmd_SetMissionText:
; Sub-handler $E5. Two jobs for one command: draw the little "remote collected" marker
; for mission wDBA7_MenuCmd_SrcPtr, and point the text source at that mission's
; description.
;
; The marker's tile is REMOTE_MARKER_TILE_TAKEN or _MISSING depending on the mission's
; bit in wDC5C_ProgressFlags, and its screen position is derived from the command
; block's OWN destination tile - two rows below and one column left - so the marker
; follows the text without the script having to place it. It lands in OAM slots
; 4, 8 and 12 (`arg * 4 + 4`), leaving the first four for the cursor.
;
; gex2's call_01_473a_MenuCmd_SetMissionText
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:467b $21 $a7 $db
    ld   L, [HL]                                      ;; 01:467e $6e
    ld   H, $00                                       ;; 01:467f $26 $00
    ld   DE, .data_01_46d1                            ;; 01:4681 $11 $d1 $46
    add  HL, DE                                       ;; 01:4684 $19
    ld   C, [HL]                                      ;; 01:4685 $4e
    ld   HL, wDB6C_CurrentMapId                       ;; 01:4686 $21 $6c $db
    ld   L, [HL]                                      ;; 01:4689 $6e
    ld   H, $00                                       ;; 01:468a $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 01:468c $11 $5c $dc
    add  HL, DE                                       ;; 01:468f $19
    ld   A, [HL]                                      ;; 01:4690 $7e
    and  A, C                                         ;; 01:4691 $a1
    ld   C, REMOTE_MARKER_TILE_TAKEN                  ;; 01:4692 $0e $e4
    jr   NZ, .jr_01_4698                              ;; 01:4694 $20 $02
    ld   C, REMOTE_MARKER_TILE_MISSING                ;; 01:4696 $0e $e8
.jr_01_4698:
    ld   A, C                                         ;; 01:4698 $79
    ld   [wDADF], A                                   ;; 01:4699 $ea $df $da
    ld   A, [wDBA1_MenuCmd_DestTileY]                 ;; 01:469c $fa $a1 $db
    add  A, $02                                       ;; 01:469f $c6 $02
    add  A, A                                         ;; 01:46a1 $87
    add  A, A                                         ;; 01:46a2 $87
    add  A, A                                         ;; 01:46a3 $87
    ld   [wDADD_MenuTextBuffer], A                    ;; 01:46a4 $ea $dd $da
    ld   A, [wDBA0_MenuCmd_DestTileX]                 ;; 01:46a7 $fa $a0 $db
    inc  A                                            ;; 01:46aa $3c
    sub  A, $02                                       ;; 01:46ab $d6 $02
    add  A, A                                         ;; 01:46ad $87
    add  A, A                                         ;; 01:46ae $87
    add  A, A                                         ;; 01:46af $87
    ld   [wDADE], A                                   ;; 01:46b0 $ea $de $da
    ld   A, $03                                       ;; 01:46b3 $3e $03
    ld   [wDAE0], A                                   ;; 01:46b5 $ea $e0 $da
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:46b8 $fa $a7 $db
    add  A, A                                         ;; 01:46bb $87
    add  A, A                                         ;; 01:46bc $87
    add  A, $04                                       ;; 01:46bd $c6 $04
    ld   [wDBDB_Menu_OamSlot], A                      ;; 01:46bf $ea $db $db
    ld   BC, $202                                     ;; 01:46c2 $01 $02 $02
    call call_01_4c7e_Menu_WriteSpriteRect            ;; 01:46c5 $cd $7e $4c
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:46c8 $fa $a7 $db
    call call_01_4b32_MenuText_GetMissionTable        ;; 01:46cb $cd $32 $4b
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:46ce $c3 $fa $4c
.data_01_46d1:
    db   $01, $02, $04                                ;; 01:46d1 ...

call_01_46d4_MenuCmd_DrawCursorSprite:
; Sub-handler $E6. Declares this screen's selection cursor, once. It stages the cursor
; graphic, fills in the sprite record at wDBBF_MenuCursor_OamSlot from the command's
; own width and height, and stores the cursor image id in
; wDBC7_Menu_CursorSpriteId - MENU_CURSOR_NONE meaning there is none.
;
; From then on call_01_4bb8_Menu_DrawCursor rebuilds the cursor from that record every
; frame, which is why a script declares it exactly once and never again. The
; `sub A, $00 / add A, $00` pair is dead: gex2's version adds a cursor id base there
; and gex3's base is zero.
;
; gex2's call_01_47c5_MenuCmd_DrawCursorSprite
    call call_01_4599_MenuCmd_StageImage2             ;; 01:46d4 $cd $99 $45
    xor  A, A                                         ;; 01:46d7 $af
    ld   [wDBBF_MenuCursor_OamSlot], A                ;; 01:46d8 $ea $bf $db
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:46db $fa $9e $db
    ld   [wDBC4_MenuCursor_WidthTiles], A             ;; 01:46de $ea $c4 $db
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:46e1 $fa $9f $db
    ld   [wDBC5_MenuCursor_HeightTiles], A            ;; 01:46e4 $ea $c5 $db
    ld   A, SPRITE_RECORD_END                         ;; 01:46e7 $3e $ff
    ld   [wDBC6_MenuCursor_RecordEnd], A              ;; 01:46e9 $ea $c6 $db
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:46ec $fa $a7 $db
    sub  A, $00                                       ;; 01:46ef $d6 $00
    add  A, $00                                       ;; 01:46f1 $c6 $00
    ld   [wDBC7_Menu_CursorSpriteId], A               ;; 01:46f3 $ea $c7 $db
    jp   call_01_4bb8_Menu_DrawCursor                 ;; 01:46f6 $c3 $b8 $4b

call_01_46f9_MenuCmd_EnableSpriteAnimation:
; Sub-handler $E7. Sets wDBE3_Menu_AnimateFlag and zeroes the four counters that go
; with it. Small, but it is the switch that makes a screen's sprites animate rather
; than sit still. No gex2 counterpart - gex2's slot in this position draws the remote
; icons instead
    xor  A, A                                         ;; 01:46f9 $af
    ld   [wDBE4], A                                   ;; 01:46fa $ea $e4 $db
    ld   [wDBE5], A                                   ;; 01:46fd $ea $e5 $db
    ld   [wDBE6], A                                   ;; 01:4700 $ea $e6 $db
    ld   [wDBE7], A                                   ;; 01:4703 $ea $e7 $db
    ld   A, $01                                       ;; 01:4706 $3e $01
    ld   [wDBE3_Menu_AnimateFlag], A                  ;; 01:4708 $ea $e3 $db
    ret                                               ;; 01:470b $c9

call_01_470c_MenuCmd_SetCounterText:
; Sub-handler $E8. Puts a NUMBER on the screen - lives remaining, coins collected,
; missions done.
;
; It writes TEXT_TERMINATOR into the buffer so the string starts empty, asks
; call_01_4722_MenuCmd_GetCounterValue for the value, and then checks whether the
; buffer is still empty: a counter handler is allowed to write its own text instead of
; returning a number, and only if it did not does this format A into digits. The text
; source is then pointed at the buffer.
;
; gex2's call_01_47ea_MenuCmd_SetCounterText
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:470c $21 $dd $da
    ld   [HL], TEXT_TERMINATOR                        ;; 01:470f $36 $80
    call call_01_4722_MenuCmd_GetCounterValue         ;; 01:4711 $cd $22 $47
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:4714 $21 $dd $da
    bit  7, [HL]                                      ;; 01:4717 $cb $7e
    call NZ, call_01_4d49_Text_FormatByte             ;; 01:4719 $c4 $49 $4d
    ld   HL, MENUTEXT_COUNTER_STRINGS                 ;; 01:471c $21 $97 $4e
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:471f $c3 $fa $4c

call_01_4722_MenuCmd_GetCounterValue:
; Returns one of twelve numbers in A, chosen by wDBA7_MenuCmd_SrcPtr. This is a
; ROUTINE with an embedded table, not a table - the old name read like a data label.
;
; The interesting half is that most of the entries are popcounts over
; wDC5C_ProgressFlags rather than stored totals: the game does not keep a "missions
; completed" counter anywhere, it counts the bits every time the screen is drawn. The
; rest are wDC68_CollectibleAmount, wDCAF_PawCoinCounter, wDC4E_LivesRemaining, the
; level's collectible total, and three hardcoded constants.
;
; gex2's call_01_47f6_MenuCmd_GetCounterValue
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:4722 $fa $a7 $db
    ld   DE, .data_01_472c                            ;; 01:4725 $11 $2c $47
    call call_00_0777_GetPointerFromTable             ;; 01:4728 $cd $77 $07
    jp   HL                                           ;; 01:472b $e9
.data_01_472c:
    dw   call_01_4acf_CountCollectedBitsForLevel      ;; 01:472c pP
    dw   call_01_4b0a_CountHighBitsForLevel           ;; 01:472e pP
    dw   call_01_4af9_IsLevelBonusCoinTaken           ;; 01:4730 pP
    dw   .jp_01_4744                                  ;; 01:4732 pP
    dw   call_01_4ae7_CountLevelsWithBonusCoin        ;; 01:4734 pP
    dw   .jp_01_4748                                  ;; 01:4736 pP
    dw   call_01_4ab9_CountAllCollectedObjectives     ;; 01:4738 pP
    dw   .jp_01_474c                                  ;; 01:473a pP
    dw   .jp_01_4756                                  ;; 01:473c pP
    dw   .jp_01_4759                                  ;; 01:473e pP
    dw   .jp_01_475c                                  ;; 01:4740 pP
    dw   call_00_2f34_CountLevelCollectibleTotal      ;; 01:4742 ??
.jp_01_4744:
    ld   A, [wDC68_CollectibleAmount]                 ;; 01:4744 $fa $68 $dc
    ret                                               ;; 01:4747 $c9
.jp_01_4748:
    ld   A, [wDCAF_PawCoinCounter]                    ;; 01:4748 $fa $af $dc
    ret                                               ;; 01:474b $c9
.jp_01_474c:
    ld   A, [wDC1E_CurrentLevelID]                    ;; 01:474c $fa $1e $dc
    and  A, A                                         ;; 01:474f $a7
    ld   A, $01                                       ;; 01:4750 $3e $01
    ret  Z                                            ;; 01:4752 $c8
    ld   A, $04                                       ;; 01:4753 $3e $04
    ret                                               ;; 01:4755 $c9
.jp_01_4756:
    ld   A, $03                                       ;; 01:4756 $3e $03
    ret                                               ;; 01:4758 $c9
.jp_01_4759:
    ld   A, $01                                       ;; 01:4759 $3e $01
    ret                                               ;; 01:475b $c9
.jp_01_475c:
    ld   A, [wDC4E_LivesRemaining]                    ;; 01:475c $fa $4e $dc
    ret                                               ;; 01:475f $c9

call_01_4760_MenuCmd_DrawSpriteGroup:
; Sub-handler $E9. Draws a group of sprites from
; data_01_5b61_SpriteScriptTable, and optionally arms the timer that will erase them
; again: a non-zero wDBA6_MenuCmd_Arg2 becomes wDBDE_Menu_HideSpritesDelay and the
; group id is remembered in wDBDF_Menu_HideSpritesGroup for
; call_01_4b6b_Menu_TickHideSprites to undo later.
;
; Three of the four entries in that table point at wDBBF_MenuCursor_OamSlot - the
; cursor record in WRAM - rather than at ROM. gex2's
; call_01_4879_MenuCmd_DrawRemoteIcons
    ld   A, [wDBA6_MenuCmd_Arg2]                      ;; 01:4760 $fa $a6 $db
    and  A, A                                         ;; 01:4763 $a7
    jr   Z, .jr_01_476f                               ;; 01:4764 $28 $09
    ld   [wDBDE_Menu_HideSpritesDelay], A             ;; 01:4766 $ea $de $db
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:4769 $fa $a7 $db
    ld   [wDBDF_Menu_HideSpritesGroup], A             ;; 01:476c $ea $df $db
.jr_01_476f:
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:476f $fa $a7 $db
    ld   DE, data_01_5b61_SpriteScriptTable           ;; 01:4772 $11 $61 $5b
    call call_00_0777_GetPointerFromTable             ;; 01:4775 $cd $77 $07
    jp   call_01_4c45_Menu_BuildSpriteBlock           ;; 01:4778 $c3 $45 $4c

call_01_477b_MenuCmd_NoOp:
; Sub-handler $EA: a bare `ret`. gex2 uses this slot for the totals-page heading
; text; gex3 has no such command and left the slot filled with nothing
    ret                                               ;; 01:477b ?

call_01_477c_MenuCmd_StagePasswordGlyph:
; Sub-handler $EB. Stages the 2x2-tile glyph for one password cell.
;
; wDBA7_MenuCmd_SrcPtr is the cell number; wDB7E_PasswordValues[cell] is the key the
; player put there; that key indexes data_01_66f9_PasswordFont at
; PASSWORD_GLYPH_BYTES each. The destination is wC980_NumberSprites, also stepped by
; PASSWORD_GLYPH_BYTES, so the whole grid can be staged by one script running this
; command eighteen times - which is exactly what data_01_5a47_MenuScript_PasswordGrid does.
;
; It draws no number and writes no sprite; the old name was wrong on both. gex2's
; call_01_48fd_MenuCmd_SetPasswordCharText does the same job by pushing one character
; through the text renderer instead
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:477c $21 $a7 $db
    ld   L, [HL]                                      ;; 01:477f $6e
    ld   H, $00                                       ;; 01:4780 $26 $00
    add  HL, HL                                       ;; 01:4782 $29
    add  HL, HL                                       ;; 01:4783 $29
    add  HL, HL                                       ;; 01:4784 $29
    add  HL, HL                                       ;; 01:4785 $29
    add  HL, HL                                       ;; 01:4786 $29
    add  HL, HL                                       ;; 01:4787 $29
    ld   DE, wC980_NumberSprites                      ;; 01:4788 $11 $80 $c9
    add  HL, DE                                       ;; 01:478b $19
    ld   E, L                                         ;; 01:478c $5d
    ld   D, H                                         ;; 01:478d $54
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:478e $21 $a7 $db
    ld   L, [HL]                                      ;; 01:4791 $6e
    ld   H, $00                                       ;; 01:4792 $26 $00
    ld   BC, wDB7E_PasswordValues                     ;; 01:4794 $01 $7e $db
    add  HL, BC                                       ;; 01:4797 $09
    ld   L, [HL]                                      ;; 01:4798 $6e
    ld   H, $00                                       ;; 01:4799 $26 $00
    add  HL, HL                                       ;; 01:479b $29
    add  HL, HL                                       ;; 01:479c $29
    add  HL, HL                                       ;; 01:479d $29
    add  HL, HL                                       ;; 01:479e $29
    add  HL, HL                                       ;; 01:479f $29
    add  HL, HL                                       ;; 01:47a0 $29
    ld   BC, data_01_66f9_PasswordFont                ;; 01:47a1 $01 $f9 $66
    add  HL, BC                                       ;; 01:47a4 $09
    ld   B, $04                                       ;; 01:47a5 $06 $04
    jp   call_00_0bcf_CopyTileRows                    ;; 01:47a7 $c3 $cf $0b

call_01_47aa_MenuCmd_SetChainedScript:
; Sub-handler $EC. Stores the command's argument in wDBDD_Menu_ChainedScript, which
; call_01_43f0_Menu_BuildScreen picks up after the current script ends and uses to
; index data_01_5596_ChainedScriptTable. That is the whole of gex3's "run a second
; script after this one". gex2's call_01_4916_MenuCmd_SetChainedScript
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:47aa $fa $a7 $db
    ld   [wDBDD_Menu_ChainedScript], A                ;; 01:47ad $ea $dd $db
    ret                                               ;; 01:47b0 $c9

call_01_47b1_MenuCmd_LoadFullscreenImage:
; Sub-handler $ED. Copies one eight-byte image record from the inline table into
; wDBB1_ScreenDraw_HasPaletteIdMap and hands off to
; jp_00_0781_Screen_LoadFullscreenImage. The record's fields are named in memory.asm;
; this is how the title screen and the credit stills get on screen. gex2's
; call_01_491d_MenuCmd_LoadFullscreenImage
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:47b1 $fa $a7 $db
    ld   DE, .data_01_47c6                            ;; 01:47b4 $11 $c6 $47
    call call_00_0777_GetPointerFromTable             ;; 01:47b7 $cd $77 $07
    ld   DE, wDBB1_ScreenDraw_HasPaletteIdMap         ;; 01:47ba $11 $b1 $db
    ld   BC, $08                                      ;; 01:47bd $01 $08 $00
    call call_00_076e_MemCopy                         ;; 01:47c0 $cd $6e $07
    jp   jp_00_0781_Screen_LoadFullscreenImage        ;; 01:47c3 $c3 $81 $07
.data_01_47c6:
    dw   .data_01_47d4, .data_01_47dc, .data_01_47e4, .data_01_47ec ;; 01:47c6 ..??....
    dw   .data_01_47f4, .data_01_47fc, .data_01_4804
.data_01_47d4:
    db   $00, $06, $e0, $45, $00, $40, $e0, $05
.data_01_47dc:
    db   $00, $06, $a6, $48, $a6, $47, $00, $01
.data_01_47e4:
    db   $01, $06, $fe, $56, $1e, $4a, $e0, $0c
.data_01_47ec:
    db   $00, $06, $06, $66, $86, $60, $80, $05
.data_01_47f4:
    db   $00, $06, $66, $6b, $c6, $67, $a0, $03
.data_01_47fc:
    db   $00, $06, $ce, $5e, $ce, $59, $00, $05
.data_01_4804:
    db   $01, $11, $90, $51, $00, $40, $90, $11

call_01_480c_MenuCmd_SetCollectedCountText:
; Sub-handler $EE. Builds a short "n<something>" string: it appends a fixed suffix
; from BANK_1C_TEXT, counts this level's collected objectives, and then OVERWRITES the
; first character of the result with that count as an ASCII digit. So the digit is not
; appended - the suffix string is written first and the number is dropped on top of
; its first byte.
;
; Note the source operand MENUTEXT_COLLECTED_SUFFIX. As a raw number it is $4AC3, and
; the disassembler resolved that to a label inside this file's own bit-counting loop;
; it is really a bank $1C address and has nothing to do with bank 1
    ld   hl,wDADD_MenuTextBuffer
    ld   [hl],TEXT_TERMINATOR
    ld   de,MENUTEXT_COLLECTED_SUFFIX
    call call_00_0865_Text_AppendStringToBuffer
    call call_01_4acf_CountCollectedBitsForLevel
    add  a,ASCII_ZERO
    ld   [wDADD_MenuTextBuffer],a
    ld   hl,MENUTEXT_COUNTER_STRINGS
    jp   call_01_4cfa_Menu_SetScriptSrcPtr

call_01_4825_MenuCmd_NoOp2:
; Sub-handler $EF: another bare `ret`.
;
; This label used to claim address $480C, which is the routine above it - two top
; level labels for one address. It is really at $4825
    ret  

call_01_4826_MenuCmd_DrawRemoteMarker:
; Sub-handler $F0. The marker half of call_01_467b_MenuCmd_SetMissionText with no
; text: same collected/missing tile pair, same 2x2 rectangle, but a four-entry bit
; mask table instead of three and a different OAM attribute. The screen that uses four
; markers rather than three is what it exists for
    ld   hl,wDBA7_MenuCmd_SrcPtr
    ld   l,[hl]
    ld   h,$00
    ld   de,.data_01_4871
    add  hl,de
    ld   c,[hl]
    ld   hl,wDB6C_CurrentMapId
    ld   l,[hl]
    ld   h,$00
    ld   de,wDC5C_ProgressFlags
    add  hl,de
    ld   a,[hl]
    and  c
    ld   c,REMOTE_MARKER_TILE_TAKEN
    jr   nz,.jr_00_4843
    ld   c,REMOTE_MARKER_TILE_MISSING
.jr_00_4843:
    ld   a,c
    ld   [wDADF],a
    ld   a,[wDBA1_MenuCmd_DestTileY]
    add  a,$02
    add  a
    add  a
    add  a
    ld   [wDADD_MenuTextBuffer],a
    ld   a,[wDBA0_MenuCmd_DestTileX]
    inc  a
    add  a
    add  a
    add  a
    ld   [wDADE],a
    ld   a,$01
    ld   [wDAE0],a
    ld   a,[wDBA7_MenuCmd_SrcPtr]
    add  a
    add  a
    add  a,$04
    ld   [wDBDB_Menu_OamSlot],a
    ld   bc,$0202
    jp   call_01_4c7e_Menu_WriteSpriteRect
.data_01_4871:
    db   $01, $02, $04, $08                           ;; 01:486e ???????

call_01_4875_Text_Render:
; Draws a string into the tile staging buffer, one line at a time. The renderer
; proper - and it writes GRAPHICS, not a tilemap.
;
; It loads the font descriptor for wDBA6_MenuCmd_Arg2 out of
; data_01_5b77_FontDescriptors, has call_01_49bb_Text_WrapAndAlign break the text into
; lines that fit, and then walks lines until a blank one or the end of the string.
; Each line's characters go through call_01_48cd_Text_DrawGlyph; each line advances the
; pen by wDBE2_Text_LineAdvance.
;
; If wDBE1_Text_RequestedX is TEXT_AUTO_ALIGN the line is centred, by measuring it and
; starting at half the block width minus half the text width.
;
; gex2's call_01_4a8f_Text_Render
    ld   HL, wDBA6_MenuCmd_Arg2                       ;; 01:4875 $21 $a6 $db
    ld   L, [HL]                                      ;; 01:4878 $6e
    ld   H, $00                                       ;; 01:4879 $26 $00
    add  HL, HL                                       ;; 01:487b $29
    add  HL, HL                                       ;; 01:487c $29
    add  HL, HL                                       ;; 01:487d $29
    ld   DE, data_01_5b77_FontDescriptors             ;; 01:487e $11 $77 $5b
    add  HL, DE                                       ;; 01:4881 $19
    ld   DE, wDBAB_Font_GlyphBase                     ;; 01:4882 $11 $ab $db
    ld   BC, MENUCMD_DESCRIPTOR_COPY_BYTES            ;; 01:4885 $01 $06 $00
    call call_00_076e_MemCopy                         ;; 01:4888 $cd $6e $07
    call call_01_49bb_Text_WrapAndAlign               ;; 01:488b $cd $bb $49
.jr_01_488e:
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:488e $21 $a7 $db
    ld   E, [HL]                                      ;; 01:4891 $5e
    inc  HL                                           ;; 01:4892 $23
    ld   D, [HL]                                      ;; 01:4893 $56
    ld   A, [DE]                                      ;; 01:4894 $1a
    cp   A, $80                                       ;; 01:4895 $fe $80
    ret  Z                                            ;; 01:4897 $c8
    and  A, A                                         ;; 01:4898 $a7
    ret  Z                                            ;; 01:4899 $c8
    ld   A, [wDBE1_Text_RequestedX]                   ;; 01:489a $fa $e1 $db
    cp   A, TEXT_AUTO_ALIGN                           ;; 01:489d $fe $fe
    jr   NZ, .jr_01_48ac                              ;; 01:489f $20 $0b
    call call_01_4a55_Text_MeasureLine                ;; 01:48a1 $cd $55 $4a
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:48a4 $fa $9e $db
    add  A, A                                         ;; 01:48a7 $87
    add  A, A                                         ;; 01:48a8 $87
    srl  C                                            ;; 01:48a9 $cb $39
    sub  A, C                                         ;; 01:48ab $91
.jr_01_48ac:
    ld   [wDBA4_Text_PenX], A                         ;; 01:48ac $ea $a4 $db
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:48af $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:48b2 $2a
    ld   H, [HL]                                      ;; 01:48b3 $66
    ld   L, A                                         ;; 01:48b4 $6f
.jr_01_48b5:
    ld   A, [HL+]                                     ;; 01:48b5 $2a
    push HL                                           ;; 01:48b6 $e5
    call call_01_48cd_Text_DrawGlyph                  ;; 01:48b7 $cd $cd $48
    pop  HL                                           ;; 01:48ba $e1
    bit  7, [HL]                                      ;; 01:48bb $cb $7e
    jr   Z, .jr_01_48b5                               ;; 01:48bd $28 $f6
    inc  HL                                           ;; 01:48bf $23
    call call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:48c0 $cd $fa $4c
    ld   HL, wDBA5_Text_PenY                          ;; 01:48c3 $21 $a5 $db
    ld   A, [wDBE2_Text_LineAdvance]                  ;; 01:48c6 $fa $e2 $db
    add  A, [HL]                                      ;; 01:48c9 $86
    ld   [HL], A                                      ;; 01:48ca $77
    jr   .jr_01_488e                                  ;; 01:48cb $18 $c1

call_01_48cd_Text_DrawGlyph:
; One character, composited into the staging buffer at the pen, and the densest
; routine in the file.
;
; The problem it solves: glyphs are proportional, so a character does not begin on a
; tile boundary. wDBC8_Text_ShiftCount is 8 minus the pen's sub-tile column, and each
; eight-pixel glyph row is treated as the high byte of a 16-bit value shifted left by
; it - the high half lands in the current tile column and the low half in the next
; one. Both halves are XOR'd in rather than stored, so glyphs composite with whatever
; is already there and drawing the same glyph twice erases it. That is how the
; password keyboard's highlight blinks.
;
; The address arithmetic is worth reading slowly: the destination is the tile at
; (penX & $F8) plus the pixel row within it, plus whole tile rows for penY >> 3, all
; relative to the block's own base from
; call_01_4cd4_Menu_GetStagingAddrForDestTile. When the write cursor crosses a
; TILE_SIZE_BYTES boundary it jumps a whole block-row so the next pixel row lands in
; the tile directly below. The outer loop repeats for wide glyphs.
;
; gex2's call_01_4ae7_Text_DrawGlyph
    call call_01_4a7f_Text_SelectGlyph                ;; 01:48cd $cd $7f $4a
    ld   A, [wDBA4_Text_PenX]                         ;; 01:48d0 $fa $a4 $db
    and  A, $07                                       ;; 01:48d3 $e6 $07
    ld   C, A                                         ;; 01:48d5 $4f
    ld   A, $08                                       ;; 01:48d6 $3e $08
    sub  A, C                                         ;; 01:48d8 $91
    ld   [wDBC8_Text_ShiftCount], A                   ;; 01:48d9 $ea $c8 $db
    ld   A, [wDBA4_Text_PenX]                         ;; 01:48dc $fa $a4 $db
    and  A, $f8                                       ;; 01:48df $e6 $f8
    ld   L, A                                         ;; 01:48e1 $6f
    ld   H, $00                                       ;; 01:48e2 $26 $00
    add  HL, HL                                       ;; 01:48e4 $29
    ld   A, [wDBA5_Text_PenY]                         ;; 01:48e5 $fa $a5 $db
    and  A, $07                                       ;; 01:48e8 $e6 $07
    add  A, A                                         ;; 01:48ea $87
    ld   E, A                                         ;; 01:48eb $5f
    ld   D, $00                                       ;; 01:48ec $16 $00
    add  HL, DE                                       ;; 01:48ee $19
    ld   A, [wDBA5_Text_PenY]                         ;; 01:48ef $fa $a5 $db
    srl  A                                            ;; 01:48f2 $cb $3f
    srl  A                                            ;; 01:48f4 $cb $3f
    srl  A                                            ;; 01:48f6 $cb $3f
    jr   Z, .jr_01_490c                               ;; 01:48f8 $28 $12
    ld   C, A                                         ;; 01:48fa $4f
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:48fb $fa $9e $db
    swap A                                            ;; 01:48fe $cb $37
    ld   D, A                                         ;; 01:4900 $57
    and  A, $f0                                       ;; 01:4901 $e6 $f0
    ld   E, A                                         ;; 01:4903 $5f
    ld   A, D                                         ;; 01:4904 $7a
    and  A, $0f                                       ;; 01:4905 $e6 $0f
    ld   D, A                                         ;; 01:4907 $57
.jr_01_4908:
    add  HL, DE                                       ;; 01:4908 $19
    dec  C                                            ;; 01:4909 $0d
    jr   NZ, .jr_01_4908                              ;; 01:490a $20 $fc
.jr_01_490c:
    push HL                                           ;; 01:490c $e5
    call call_01_4cd4_Menu_GetStagingAddrForDestTile  ;; 01:490d $cd $d4 $4c
    pop  HL                                           ;; 01:4910 $e1
    add  HL, DE                                       ;; 01:4911 $19
    ld   A, [wDBAF_Font_GlyphWidthCols]               ;; 01:4912 $fa $af $db
.jr_01_4915:
    push AF                                           ;; 01:4915 $f5
    push HL                                           ;; 01:4916 $e5
    ld   A, L                                         ;; 01:4917 $7d
    ld   [wDBBB_Text_DestPtr], A                      ;; 01:4918 $ea $bb $db
    ld   A, H                                         ;; 01:491b $7c
    ld   [wDBBC_Text_DestPtrHi], A                                   ;; 01:491c $ea $bc $db
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:491f $fa $b0 $db
.jr_01_4922:
    push AF                                           ;; 01:4922 $f5
    ld   A, [wDBBD_Text_GlyphPtr]                     ;; 01:4923 $fa $bd $db
    ld   L, A                                         ;; 01:4926 $6f
    ld   A, [wDBBE_Text_GlyphPtrHi]                                   ;; 01:4927 $fa $be $db
    ld   H, A                                         ;; 01:492a $67
    ld   E, [HL]                                      ;; 01:492b $5e
    inc  HL                                           ;; 01:492c $23
    ld   C, [HL]                                      ;; 01:492d $4e
    inc  HL                                           ;; 01:492e $23
    ld   A, L                                         ;; 01:492f $7d
    ld   [wDBBD_Text_GlyphPtr], A                     ;; 01:4930 $ea $bd $db
    ld   A, H                                         ;; 01:4933 $7c
    ld   [wDBBE_Text_GlyphPtrHi], A                                   ;; 01:4934 $ea $be $db
    ld   D, $00                                       ;; 01:4937 $16 $00
    ld   B, $00                                       ;; 01:4939 $06 $00
    ld   A, [wDBC8_Text_ShiftCount]                   ;; 01:493b $fa $c8 $db
.jr_01_493e:
    sla  E                                            ;; 01:493e $cb $23
    rl   D                                            ;; 01:4940 $cb $12
    sla  C                                            ;; 01:4942 $cb $21
    rl   B                                            ;; 01:4944 $cb $10
    dec  A                                            ;; 01:4946 $3d
    jr   NZ, .jr_01_493e                              ;; 01:4947 $20 $f5
    ld   A, [wDBBB_Text_DestPtr]                      ;; 01:4949 $fa $bb $db
    ld   L, A                                         ;; 01:494c $6f
    ld   A, [wDBBC_Text_DestPtrHi]                                   ;; 01:494d $fa $bc $db
    ld   H, A                                         ;; 01:4950 $67
    ld   A, D                                         ;; 01:4951 $7a
    xor  A, [HL]                                      ;; 01:4952 $ae
    ld   [HL+], A                                     ;; 01:4953 $22
    ld   A, B                                         ;; 01:4954 $78
    xor  A, [HL]                                      ;; 01:4955 $ae
    ld   [HL], A                                      ;; 01:4956 $77
    ld   A, E                                         ;; 01:4957 $7b
    ld   DE, $0f                                      ;; 01:4958 $11 $0f $00
    add  HL, DE                                       ;; 01:495b $19
    xor  A, [HL]                                      ;; 01:495c $ae
    ld   [HL+], A                                     ;; 01:495d $22
    ld   A, C                                         ;; 01:495e $79
    xor  A, [HL]                                      ;; 01:495f $ae
    ld   [HL], A                                      ;; 01:4960 $77
    ld   HL, wDBBB_Text_DestPtr                       ;; 01:4961 $21 $bb $db
    ld   A, [HL+]                                     ;; 01:4964 $2a
    ld   H, [HL]                                      ;; 01:4965 $66
    ld   L, A                                         ;; 01:4966 $6f
    inc  HL                                           ;; 01:4967 $23
    inc  HL                                           ;; 01:4968 $23
    ld   A, L                                         ;; 01:4969 $7d
    and  A, $0f                                       ;; 01:496a $e6 $0f
    jr   NZ, .jr_01_4980                              ;; 01:496c $20 $12
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:496e $fa $9e $db
    swap A                                            ;; 01:4971 $cb $37
    ld   D, A                                         ;; 01:4973 $57
    and  A, $f0                                       ;; 01:4974 $e6 $f0
    ld   E, A                                         ;; 01:4976 $5f
    ld   A, D                                         ;; 01:4977 $7a
    and  A, $0f                                       ;; 01:4978 $e6 $0f
    ld   D, A                                         ;; 01:497a $57
    add  HL, DE                                       ;; 01:497b $19
    ld   DE, hFFF0                                    ;; 01:497c $11 $f0 $ff
    add  HL, DE                                       ;; 01:497f $19
.jr_01_4980:
    ld   A, L                                         ;; 01:4980 $7d
    ld   [wDBBB_Text_DestPtr], A                      ;; 01:4981 $ea $bb $db
    ld   A, H                                         ;; 01:4984 $7c
    ld   [wDBBC_Text_DestPtrHi], A                                   ;; 01:4985 $ea $bc $db
    pop  AF                                           ;; 01:4988 $f1
    dec  A                                            ;; 01:4989 $3d
    jr   NZ, .jr_01_4922                              ;; 01:498a $20 $96
    pop  HL                                           ;; 01:498c $e1
    ld   DE, $10                                      ;; 01:498d $11 $10 $00
    add  HL, DE                                       ;; 01:4990 $19
    pop  AF                                           ;; 01:4991 $f1
    dec  A                                            ;; 01:4992 $3d
    jr   NZ, .jr_01_4915                              ;; 01:4993 $20 $80
    ld   HL, wDBA4_Text_PenX                          ;; 01:4995 $21 $a4 $db
    ld   A, [wDBC9_Text_GlyphAdvance]                 ;; 01:4998 $fa $c9 $db
    add  A, [HL]                                      ;; 01:499b $86
    inc  A                                            ;; 01:499c $3c
    ld   [HL], A                                      ;; 01:499d $77
    ret                                               ;; 01:499e $c9

call_01_499f_Text_ClearBuffer:
; Blanks the current block's tiles in the staging buffer, so the XOR compositing above
; starts from a clean page. Sixteen unrolled stores per tile, and the tile count comes
; back in A from call_01_4ce5_Menu_GetTileDataSize.
;
; Unlike gex2's call_01_4bb7_Text_ClearBuffer, which always clears from the start of
; the buffer, this one clears from the block's own base - so gex3 can blank one part
; of a screen without touching the rest
    call call_01_4ce5_Menu_GetTileDataSize            ;; 01:499f $cd $e5 $4c
    ld   B, A                                         ;; 01:49a2 $47
    call call_01_4cd4_Menu_GetStagingAddrForDestTile  ;; 01:49a3 $cd $d4 $4c
    xor  A, A                                         ;; 01:49a6 $af
.jr_01_49a7:
    ld   [HL+], A                                     ;; 01:49a7 $22
    ld   [HL+], A                                     ;; 01:49a8 $22
    ld   [HL+], A                                     ;; 01:49a9 $22
    ld   [HL+], A                                     ;; 01:49aa $22
    ld   [HL+], A                                     ;; 01:49ab $22
    ld   [HL+], A                                     ;; 01:49ac $22
    ld   [HL+], A                                     ;; 01:49ad $22
    ld   [HL+], A                                     ;; 01:49ae $22
    ld   [HL+], A                                     ;; 01:49af $22
    ld   [HL+], A                                     ;; 01:49b0 $22
    ld   [HL+], A                                     ;; 01:49b1 $22
    ld   [HL+], A                                     ;; 01:49b2 $22
    ld   [HL+], A                                     ;; 01:49b3 $22
    ld   [HL+], A                                     ;; 01:49b4 $22
    ld   [HL+], A                                     ;; 01:49b5 $22
    ld   [HL+], A                                     ;; 01:49b6 $22
    dec  B                                            ;; 01:49b7 $05
    jr   NZ, .jr_01_49a7                              ;; 01:49b8 $20 $ed
    ret                                               ;; 01:49ba $c9

call_01_49bb_Text_WrapAndAlign:
; Word-wraps a string to the block's width and, if asked, spreads the lines evenly
; down its height. Runs before any drawing.
;
; Wrapping is done in place and destructively: it measures a line, and if it is too
; wide it scans back to the nearest TEXT_SPACE and overwrites that space with a
; TEXT_TERMINATOR, turning it into a line break. Then it re-measures from the top,
; because the break may have changed everything after it. A second pass turns stray
; terminators back into spaces where the text continues.
;
; Vertical distribution kicks in when the pen Y is TEXT_AUTO_ALIGN: it counts the
; lines, works out the leftover height, and divides it by lines + 1 by repeated
; subtraction, so the gap above, between and below all match.
;
; The string it edits is the WRAM copy, not the ROM original -
; call_00_0835_Text_LoadStringToBuffer put it there first. gex2's
; call_01_4bd3_Text_WrapAndAlign
    call call_00_0835_Text_LoadStringToBuffer         ;; 01:49bb $cd $35 $08
.jr_01_49be:
    call call_01_4a55_Text_MeasureLine                ;; 01:49be $cd $55 $4a
    ld   HL, wDB9E_MenuCmd_WidthTiles                 ;; 01:49c1 $21 $9e $db
    ld   L, [HL]                                      ;; 01:49c4 $6e
    ld   H, $00                                       ;; 01:49c5 $26 $00
    add  HL, HL                                       ;; 01:49c7 $29
    add  HL, HL                                       ;; 01:49c8 $29
    add  HL, HL                                       ;; 01:49c9 $29
    ld   A, L                                         ;; 01:49ca $7d
    sub  A, C                                         ;; 01:49cb $91
    ld   A, H                                         ;; 01:49cc $7c
    sbc  A, B                                         ;; 01:49cd $98
    jr   NC, .jr_01_49e5                              ;; 01:49ce $30 $15
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:49d0 $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:49d3 $2a
    ld   H, [HL]                                      ;; 01:49d4 $66
    ld   L, A                                         ;; 01:49d5 $6f
.jr_01_49d6:
    inc  HL                                           ;; 01:49d6 $23
    bit  7, [HL]                                      ;; 01:49d7 $cb $7e
    jr   Z, .jr_01_49d6                               ;; 01:49d9 $28 $fb
.jr_01_49db:
    dec  HL                                           ;; 01:49db $2b
    ld   A, [HL]                                      ;; 01:49dc $7e
    cp   A, TEXT_SPACE                                ;; 01:49dd $fe $20
    jr   NZ, .jr_01_49db                              ;; 01:49df $20 $fa
    ld   [HL], TEXT_TERMINATOR                        ;; 01:49e1 $36 $80
    jr   .jr_01_49be                                  ;; 01:49e3 $18 $d9
.jr_01_49e5:
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:49e5 $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:49e8 $2a
    ld   H, [HL]                                      ;; 01:49e9 $66
    ld   L, A                                         ;; 01:49ea $6f
.jr_01_49eb:
    ld   A, [HL+]                                     ;; 01:49eb $2a
    bit  7, A                                         ;; 01:49ec $cb $7f
    jr   Z, .jr_01_49eb                               ;; 01:49ee $28 $fb
    ld   A, [HL]                                      ;; 01:49f0 $7e
    and  A, A                                         ;; 01:49f1 $a7
    jr   Z, .jr_01_4a06                               ;; 01:49f2 $28 $12
    call call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:49f4 $cd $fa $4c
.jr_01_49f7:
    ld   A, [HL+]                                     ;; 01:49f7 $2a
    bit  7, A                                         ;; 01:49f8 $cb $7f
    jr   Z, .jr_01_49f7                               ;; 01:49fa $28 $fb
    ld   A, [HL]                                      ;; 01:49fc $7e
    and  A, A                                         ;; 01:49fd $a7
    jr   Z, .jr_01_49be                               ;; 01:49fe $28 $be
    dec  HL                                           ;; 01:4a00 $2b
    ld   [HL], TEXT_SPACE                             ;; 01:4a01 $36 $20
    inc  HL                                           ;; 01:4a03 $23
    jr   .jr_01_49f7                                  ;; 01:4a04 $18 $f1
.jr_01_4a06:
    ld   A, [wDBA4_Text_PenX]                         ;; 01:4a06 $fa $a4 $db
    ld   [wDBE1_Text_RequestedX], A                   ;; 01:4a09 $ea $e1 $db
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:4a0c $21 $dd $da
    call call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:4a0f $cd $fa $4c
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:4a12 $fa $b0 $db
    inc  A                                            ;; 01:4a15 $3c
    ld   [wDBE2_Text_LineAdvance], A                  ;; 01:4a16 $ea $e2 $db
    ld   A, [wDBA5_Text_PenY]                         ;; 01:4a19 $fa $a5 $db
    cp   A, TEXT_AUTO_ALIGN                           ;; 01:4a1c $fe $fe
    ret  NZ                                           ;; 01:4a1e $c0
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:4a1f $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:4a22 $2a
    ld   H, [HL]                                      ;; 01:4a23 $66
    ld   L, A                                         ;; 01:4a24 $6f
    ld   C, $00                                       ;; 01:4a25 $0e $00
.jr_01_4a27:
    ld   A, [HL+]                                     ;; 01:4a27 $2a
    bit  7, A                                         ;; 01:4a28 $cb $7f
    jr   Z, .jr_01_4a27                               ;; 01:4a2a $28 $fb
    inc  C                                            ;; 01:4a2c $0c
    ld   A, [HL]                                      ;; 01:4a2d $7e
    and  A, A                                         ;; 01:4a2e $a7
    jr   NZ, .jr_01_4a27                              ;; 01:4a2f $20 $f6
    push BC                                           ;; 01:4a31 $c5
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:4a32 $fa $b0 $db
    ld   B, A                                         ;; 01:4a35 $47
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:4a36 $fa $9f $db
    add  A, A                                         ;; 01:4a39 $87
    add  A, A                                         ;; 01:4a3a $87
    add  A, A                                         ;; 01:4a3b $87
.jr_01_4a3c:
    sub  A, B                                         ;; 01:4a3c $90
    dec  C                                            ;; 01:4a3d $0d
    jr   NZ, .jr_01_4a3c                              ;; 01:4a3e $20 $fc
    pop  BC                                           ;; 01:4a40 $c1
    inc  C                                            ;; 01:4a41 $0c
    ld   B, $ff                                       ;; 01:4a42 $06 $ff
.jr_01_4a44:
    inc  B                                            ;; 01:4a44 $04
    sub  A, C                                         ;; 01:4a45 $91
    jr   NC, .jr_01_4a44                              ;; 01:4a46 $30 $fc
    ld   A, B                                         ;; 01:4a48 $78
    ld   [wDBA5_Text_PenY], A                         ;; 01:4a49 $ea $a5 $db
    ld   HL, wDBB0_Font_GlyphHeightPx                 ;; 01:4a4c $21 $b0 $db
    add  A, [HL]                                      ;; 01:4a4f $86
    inc  A                                            ;; 01:4a50 $3c
    ld   [wDBE2_Text_LineAdvance], A                  ;; 01:4a51 $ea $e2 $db
    ret                                               ;; 01:4a54 $c9

call_01_4a55_Text_MeasureLine:
; Width in pixels of the text up to the next line break, in BC. Each character's
; advance comes from the font's width table via the glyph index, plus one pixel of
; spacing per character - and the trailing space is removed with a single `dec BC` at
; the end rather than being special-cased in the loop. Returns 0 for an empty line.
; gex2's call_01_4c81_Text_MeasureLine
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:4a55 $21 $a7 $db
    ld   A, [HL+]                                     ;; 01:4a58 $2a
    ld   H, [HL]                                      ;; 01:4a59 $66
    ld   L, A                                         ;; 01:4a5a $6f
    ld   BC, $00                                      ;; 01:4a5b $01 $00 $00
    bit  7, [HL]                                      ;; 01:4a5e $cb $7e
    ret  NZ                                           ;; 01:4a60 $c0
.jr_01_4a61:
    ld   A, [HL+]                                     ;; 01:4a61 $2a
    push HL                                           ;; 01:4a62 $e5
    call call_01_4df4_Text_CharToGlyphIndex           ;; 01:4a63 $cd $f4 $4d
    ld   HL, wDBAD_Font_WidthTable                    ;; 01:4a66 $21 $ad $db
    ld   E, [HL]                                      ;; 01:4a69 $5e
    inc  HL                                           ;; 01:4a6a $23
    ld   D, [HL]                                      ;; 01:4a6b $56
    ld   L, A                                         ;; 01:4a6c $6f
    ld   H, $00                                       ;; 01:4a6d $26 $00
    add  HL, DE                                       ;; 01:4a6f $19
    ld   A, [HL]                                      ;; 01:4a70 $7e
    add  A, C                                         ;; 01:4a71 $81
    ld   C, A                                         ;; 01:4a72 $4f
    ld   A, $00                                       ;; 01:4a73 $3e $00
    adc  A, B                                         ;; 01:4a75 $88
    ld   B, A                                         ;; 01:4a76 $47
    inc  BC                                           ;; 01:4a77 $03
    pop  HL                                           ;; 01:4a78 $e1
    bit  7, [HL]                                      ;; 01:4a79 $cb $7e
    jr   Z, .jr_01_4a61                               ;; 01:4a7b $28 $e4
    dec  BC                                           ;; 01:4a7d $0b
    ret                                               ;; 01:4a7e $c9

call_01_4a7f_Text_SelectGlyph:
; Points wDBBD_Text_GlyphPtr at one character's bitmap and records its advance in
; wDBC9_Text_GlyphAdvance.
;
; The stride is computed rather than stored: height in pixels, times two bytes per row
; because the glyphs are 2bpp, times the glyph's width in tile columns. There is no
; special case for glyph 0, so a font blob has no header - the first glyph starts at
; byte zero. It returns nothing; both results are left in WRAM. gex2's
; call_01_4cab_Text_SelectGlyph
    call call_01_4df4_Text_CharToGlyphIndex           ;; 01:4a7f $cd $f4 $4d
    push AF                                           ;; 01:4a82 $f5
    ld   HL, wDBAD_Font_WidthTable                    ;; 01:4a83 $21 $ad $db
    ld   E, [HL]                                      ;; 01:4a86 $5e
    inc  HL                                           ;; 01:4a87 $23
    ld   D, [HL]                                      ;; 01:4a88 $56
    ld   L, A                                         ;; 01:4a89 $6f
    ld   H, $00                                       ;; 01:4a8a $26 $00
    add  HL, DE                                       ;; 01:4a8c $19
    ld   A, [HL]                                      ;; 01:4a8d $7e
    ld   [wDBC9_Text_GlyphAdvance], A                 ;; 01:4a8e $ea $c9 $db
    ld   A, [wDBB0_Font_GlyphHeightPx]                ;; 01:4a91 $fa $b0 $db
    add  A, A                                         ;; 01:4a94 $87
    ld   C, A                                         ;; 01:4a95 $4f
    ld   A, [wDBAF_Font_GlyphWidthCols]               ;; 01:4a96 $fa $af $db
    ld   B, A                                         ;; 01:4a99 $47
    xor  A, A                                         ;; 01:4a9a $af
.jr_01_4a9b:
    add  A, C                                         ;; 01:4a9b $81
    dec  B                                            ;; 01:4a9c $05
    jr   NZ, .jr_01_4a9b                              ;; 01:4a9d $20 $fc
    ld   E, A                                         ;; 01:4a9f $5f
    ld   D, $00                                       ;; 01:4aa0 $16 $00
    ld   HL, wDBAB_Font_GlyphBase                     ;; 01:4aa2 $21 $ab $db
    ld   A, [HL+]                                     ;; 01:4aa5 $2a
    ld   H, [HL]                                      ;; 01:4aa6 $66
    ld   L, A                                         ;; 01:4aa7 $6f
    pop  AF                                           ;; 01:4aa8 $f1
    and  A, A                                         ;; 01:4aa9 $a7
    jr   Z, .jr_01_4ab0                               ;; 01:4aaa $28 $04
.jr_01_4aac:
    add  HL, DE                                       ;; 01:4aac $19
    dec  A                                            ;; 01:4aad $3d
    jr   NZ, .jr_01_4aac                              ;; 01:4aae $20 $fc
.jr_01_4ab0:
    ld   A, L                                         ;; 01:4ab0 $7d
    ld   [wDBBD_Text_GlyphPtr], A                     ;; 01:4ab1 $ea $bd $db
    ld   A, H                                         ;; 01:4ab4 $7c
    ld   [wDBBE_Text_GlyphPtrHi], A                                   ;; 01:4ab5 $ea $be $db
    ret                                               ;; 01:4ab8 $c9

call_01_4ab9_CountAllCollectedObjectives:
; Counts every collected objective in the save file: PROGRESS_FLAG_COUNT bytes of
; wDC5C_ProgressFlags, OBJECTIVES_PER_LEVEL bits each.
;
; Only the LOW NIBBLE of each byte is examined - the loop rotates right four times per
; byte and stops. The old comment claiming it counts all set bits in twelve bytes was
; wrong; the high nibble holds other flags, including the bonus coin bit the two
; routines below test
    ld   HL, wDC5C_ProgressFlags                      ;; 01:4ab9 $21 $5c $dc
    ld   B, PROGRESS_FLAG_COUNT                       ;; 01:4abc $06 $0c
    ld   C, $00                                       ;; 01:4abe $0e $00
.jr_01_4ac0:
    ld   A, [HL+]                                     ;; 01:4ac0 $2a
    ld   E, OBJECTIVES_PER_LEVEL                      ;; 01:4ac1 $1e $04
.jr_01_4ac3:
    rrca                                              ;; 01:4ac3 $0f
    jr   NC, .jr_01_4ac7                              ;; 01:4ac4 $30 $01
    inc  C                                            ;; 01:4ac6 $0c
.jr_01_4ac7:
    dec  E                                            ;; 01:4ac7 $1d
    jr   NZ, .jr_01_4ac3                              ;; 01:4ac8 $20 $f9
    dec  B                                            ;; 01:4aca $05
    jr   NZ, .jr_01_4ac0                              ;; 01:4acb $20 $f3
    ld   A, C                                         ;; 01:4acd $79
    ret                                               ;; 01:4ace $c9

call_01_4acf_CountCollectedBitsForLevel:
; The same count for the current level only - the low nibble of its one progress
; byte
    ld   HL, wDC1E_CurrentLevelID                     ;; 01:4acf $21 $1e $dc
    ld   L, [HL]                                      ;; 01:4ad2 $6e
    ld   H, $00                                       ;; 01:4ad3 $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 01:4ad5 $11 $5c $dc
    add  HL, DE                                       ;; 01:4ad8 $19
    ld   A, [HL]                                      ;; 01:4ad9 $7e
    ld   C, $00                                       ;; 01:4ada $0e $00
    ld   B, OBJECTIVES_PER_LEVEL                      ;; 01:4adc $06 $04
.jr_01_4ade:
    rrca                                              ;; 01:4ade $0f
    jr   NC, .jr_01_4ae2                              ;; 01:4adf $30 $01
    inc  C                                            ;; 01:4ae1 $0c
.jr_01_4ae2:
    dec  B                                            ;; 01:4ae2 $05
    jr   NZ, .jr_01_4ade                              ;; 01:4ae3 $20 $f9
    ld   A, C                                         ;; 01:4ae5 $79
    ret                                               ;; 01:4ae6 $c9

call_01_4ae7_CountLevelsWithBonusCoin:
; How many of the MAIN_LEVEL_COUNT ordinary levels have had their bonus coin taken -
; PROGRESS_BONUS_COIN_TAKEN_BIT of each progress byte. The bonus and boss levels at
; the end of the list are not counted
    ld   HL, wDC5C_ProgressFlags                      ;; 01:4ae7 $21 $5c $dc
    ld   B, MAIN_LEVEL_COUNT                          ;; 01:4aea $06 $07
    ld   C, $00                                       ;; 01:4aec $0e $00
.jr_01_4aee:
    ld   A, [HL+]                                     ;; 01:4aee $2a
    and  A, 1 << PROGRESS_BONUS_COIN_TAKEN_BIT        ;; 01:4aef $e6 $10
    jr   Z, .jr_01_4af4                               ;; 01:4af1 $28 $01
    inc  C                                            ;; 01:4af3 $0c
.jr_01_4af4:
    dec  B                                            ;; 01:4af4 $05
    jr   NZ, .jr_01_4aee                              ;; 01:4af5 $20 $f7
    ld   A, C                                         ;; 01:4af7 $79
    ret                                               ;; 01:4af8 $c9

call_01_4af9_IsLevelBonusCoinTaken:
; 1 if the current level's bonus coin has been taken, 0 if not
    ld   HL, wDC1E_CurrentLevelID                     ;; 01:4af9 $21 $1e $dc
    ld   L, [HL]                                      ;; 01:4afc $6e
    ld   H, $00                                       ;; 01:4afd $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 01:4aff $11 $5c $dc
    add  HL, DE                                       ;; 01:4b02 $19
    ld   A, [HL]                                      ;; 01:4b03 $7e
    and  A, 1 << PROGRESS_BONUS_COIN_TAKEN_BIT        ;; 01:4b04 $e6 $10
    ret  Z                                            ;; 01:4b06 $c8
    ld   A, $01                                       ;; 01:4b07 $3e $01
    ret                                               ;; 01:4b09 $c9

call_01_4b0a_CountHighBitsForLevel:
; Counts the top three bits - 7, 6 and 5 - of the current level's progress byte. The
; loop rotates LEFT, so despite the old name it is the high bits, not the low ones,
; and it does not overlap with call_01_4acf_CountCollectedBitsForLevel above
    ld   HL, wDC1E_CurrentLevelID                     ;; 01:4b0a $21 $1e $dc
    ld   L, [HL]                                      ;; 01:4b0d $6e
    ld   H, $00                                       ;; 01:4b0e $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 01:4b10 $11 $5c $dc
    add  HL, DE                                       ;; 01:4b13 $19
    ld   A, [HL]                                      ;; 01:4b14 $7e
    ld   C, $00                                       ;; 01:4b15 $0e $00
    ld   B, $03                                       ;; 01:4b17 $06 $03
.jr_01_4b19:
    rlca                                              ;; 01:4b19 $07
    jr   NC, .jr_01_4b1d                              ;; 01:4b1a $30 $01
    inc  C                                            ;; 01:4b1c $0c
.jr_01_4b1d:
    dec  B                                            ;; 01:4b1d $05
    jr   NZ, .jr_01_4b19                              ;; 01:4b1e $20 $f9
    ld   A, C                                         ;; 01:4b20 $79
    ret                                               ;; 01:4b21 $c9

call_01_4b22_MenuText_GetLevelNameTable:
; The address of the current map's text block. The `ld DE, $00 / add HL, DE` is a
; no-op kept for symmetry with the two routines below it, which add real offsets -
; together the three are +0, +$0A and +$14 into a block whose first two records are
; the level name and the TV name and whose tail is an array of mission descriptions
    call call_01_4b43_MenuText_GetMapTextBlock        ;; 01:4b22 $cd $43 $4b
    ld   DE, $00                                      ;; 01:4b25 $11 $00 $00
    add  HL, DE                                       ;; 01:4b28 $19
    ret                                               ;; 01:4b29 $c9

call_01_4b2a_MenuText_GetTVNameTable:
; Ten bytes further in: the TV name record
    call call_01_4b43_MenuText_GetMapTextBlock        ;; 01:4b2a $cd $43 $4b
    ld   DE, $0a                                      ;; 01:4b2d $11 $0a $00
    add  HL, DE                                       ;; 01:4b30 $19
    ret                                               ;; 01:4b31 $c9

call_01_4b32_MenuText_GetMissionTable:
; Past both fixed records and into the mission array, ten bytes per entry, indexed by
; A. The multiply is the usual shift-and-add: A*2, then A*8, then add the two
    call call_01_4b43_MenuText_GetMapTextBlock        ;; 01:4b32 $cd $43 $4b
    ld   DE, $14                                      ;; 01:4b35 $11 $14 $00
    add  HL, DE                                       ;; 01:4b38 $19
    add  A, A                                         ;; 01:4b39 $87
    ld   E, A                                         ;; 01:4b3a $5f
    add  A, A                                         ;; 01:4b3b $87
    add  A, A                                         ;; 01:4b3c $87
    add  A, E                                         ;; 01:4b3d $83
    ld   E, A                                         ;; 01:4b3e $5f
    ld   D, $00                                       ;; 01:4b3f $16 $00
    add  HL, DE                                       ;; 01:4b41 $19
    ret                                               ;; 01:4b42 $c9

call_01_4b43_MenuText_GetMapTextBlock:
; Looks the current map's text block up in the twelve-entry pointer table below.
; Indexed by wDB6C_CurrentMapId, which on a menu screen is the level id or the totals
; page rather than a real map - see call_01_4000_MenuLoad.
;
; The addresses in the table are bank $1C addresses; they only look like bank 1
; because they are stored as bare words
    ld   HL, wDB6C_CurrentMapId                       ;; 01:4b43 $21 $6c $db
    ld   L, [HL]                                      ;; 01:4b46 $6e
    ld   H, $00                                       ;; 01:4b47 $26 $00
    add  HL, HL                                       ;; 01:4b49 $29
    ld   DE, .data_01_4b53                            ;; 01:4b4a $11 $53 $4b
    add  HL, DE                                       ;; 01:4b4d $19
    ld   E, [HL]                                      ;; 01:4b4e $5e
    inc  HL                                           ;; 01:4b4f $23
    ld   H, [HL]                                      ;; 01:4b50 $66
    ld   L, E                                         ;; 01:4b51 $6b
    ret                                               ;; 01:4b52 $c9
.data_01_4b53:
    dw   $4ea1                                        ;; 01:4b53 wW
    dw   $4f69                                        ;; 01:4b55 wW
    dw   $51f7                                        ;; 01:4b57 wW
    dw   $54ef                                        ;; 01:4b59 wW
    dw   $57ba                                        ;; 01:4b5b wW
    dw   $5a5f                                        ;; 01:4b5d wW
    dw   $5d89                                        ;; 01:4b5f wW
    dw   $6006, $614e, $62a4, $64a5                   ;; 01:4b61 ????????
    dw   $663e                                        ;; 01:4b69 ??

call_01_4b6b_Menu_TickHideSprites:
; Counts down wDBDE_Menu_HideSpritesDelay and, when it expires, erases the sprite
; group wDBDF_Menu_HideSpritesGroup by writing zeroes over the OAM entries the script
; wrote. Called once per frame from the menu idle loops.
;
; Pressing anything forces the countdown to its last frame, so a "press B to continue"
; prompt disappears the moment the player does.
;
; It streams no tile data; the old name was wrong. gex2 splits the same work between
; call_01_4d25_Menu_TickHideSprites and call_01_4d3b_Menu_EraseSpriteGroup
    ld   HL, wDBDE_Menu_HideSpritesDelay              ;; 01:4b6b $21 $de $db
    ld   A, [HL]                                      ;; 01:4b6e $7e
    and  A, A                                         ;; 01:4b6f $a7
    ret  Z                                            ;; 01:4b70 $c8
    ld   A, [wDAD7_RawInputs]                         ;; 01:4b71 $fa $d7 $da
    and  A, A                                         ;; 01:4b74 $a7
    jr   Z, .jr_01_4b79                               ;; 01:4b75 $28 $02
    ld   [HL], $01                                    ;; 01:4b77 $36 $01
.jr_01_4b79:
    dec  [HL]                                         ;; 01:4b79 $35
    ret  NZ                                           ;; 01:4b7a $c0
    ld   A, [wDBDF_Menu_HideSpritesGroup]             ;; 01:4b7b $fa $df $db
    jp   .jp_01_4b81                                  ;; 01:4b7e $c3 $81 $4b
.jp_01_4b81:
    ld   DE, data_01_5b61_SpriteScriptTable           ;; 01:4b81 $11 $61 $5b
    call call_00_0777_GetPointerFromTable             ;; 01:4b84 $cd $77 $07
    ld   A, [HL+]                                     ;; 01:4b87 $2a
    cp   A, SPRITE_RECORD_END                         ;; 01:4b88 $fe $ff
    ret  Z                                            ;; 01:4b8a $c8
    push HL                                           ;; 01:4b8b $e5
    ld   L, A                                         ;; 01:4b8c $6f
    ld   H, $00                                       ;; 01:4b8d $26 $00
    add  HL, HL                                       ;; 01:4b8f $29
    add  HL, HL                                       ;; 01:4b90 $29
    ld   DE, wD900_ShadowOAM                          ;; 01:4b91 $11 $00 $d9
    add  HL, DE                                       ;; 01:4b94 $19
    ld   E, L                                         ;; 01:4b95 $5d
    ld   D, H                                         ;; 01:4b96 $54
    pop  HL                                           ;; 01:4b97 $e1
.jr_01_4b98:
    ld   A, [HL+]                                     ;; 01:4b98 $2a
    cp   A, SPRITE_RECORD_END                         ;; 01:4b99 $fe $ff
    ret  Z                                            ;; 01:4b9b $c8
    ld   A, [HL+]                                     ;; 01:4b9c $2a
    ld   A, [HL+]                                     ;; 01:4b9d $2a
    ld   A, [HL+]                                     ;; 01:4b9e $2a
    ld   C, [HL]                                      ;; 01:4b9f $4e
    inc  HL                                           ;; 01:4ba0 $23
    ld   B, [HL]                                      ;; 01:4ba1 $46
    inc  HL                                           ;; 01:4ba2 $23
    srl  B                                            ;; 01:4ba3 $cb $38
    xor  A, A                                         ;; 01:4ba5 $af
.jr_01_4ba6:
    push BC                                           ;; 01:4ba6 $c5
.jr_01_4ba7:
    ld   [DE], A                                      ;; 01:4ba7 $12
    inc  DE                                           ;; 01:4ba8 $13
    ld   [DE], A                                      ;; 01:4ba9 $12
    inc  DE                                           ;; 01:4baa $13
    ld   [DE], A                                      ;; 01:4bab $12
    inc  DE                                           ;; 01:4bac $13
    ld   [DE], A                                      ;; 01:4bad $12
    inc  DE                                           ;; 01:4bae $13
    dec  B                                            ;; 01:4baf $05
    jr   NZ, .jr_01_4ba7                              ;; 01:4bb0 $20 $f5
    pop  BC                                           ;; 01:4bb2 $c1
    dec  C                                            ;; 01:4bb3 $0d
    jr   NZ, .jr_01_4ba6                              ;; 01:4bb4 $20 $f0
    jr   .jr_01_4b98                                  ;; 01:4bb6 $18 $e0

call_01_4bb8_Menu_DrawCursor:
; Rebuilds the selection cursor into shadow OAM, every frame. Returns at once when
; wDBC7_Menu_CursorSpriteId is MENU_CURSOR_NONE.
;
; The position is the menu record's cursor base plus its step times the selected row
; and column - both computed by repeated addition, which is a multiply, not the
; interpolation the old name suggested. The record built once by
; call_01_46d4_MenuCmd_DrawCursorSprite is then run through
; call_01_4c45_Menu_BuildSpriteBlock like any other sprite group.
;
; MENU_CURSOR_PASSWORD gets two extras: the cursor tile is whatever character is under
; it rather than MENU_CURSOR_TILE, and it alternates between MENU_CURSOR_ATTR_BRIGHT
; and _DIM on MENU_CURSOR_BLINK_MASK of the frame counter. gex3 then appends one more
; OAM entry by hand for the highlighted key on the keyboard, which gex2 has no
; equivalent of. gex2's call_01_4d72_Menu_DrawCursor
    ld   A, [wDBC7_Menu_CursorSpriteId]               ;; 01:4bb8 $fa $c7 $db
    cp   A, MENU_CURSOR_NONE                          ;; 01:4bbb $fe $ff
    ret  Z                                            ;; 01:4bbd $c8
    ld   C, MENU_CURSOR_TILE                          ;; 01:4bbe $0e $fc
    ld   B, $00                                       ;; 01:4bc0 $06 $00
    cp   A, MENU_CURSOR_PASSWORD                      ;; 01:4bc2 $fe $01
    jr   NZ, .jr_01_4bd8                              ;; 01:4bc4 $20 $12
    call call_01_4de3_Password_GetCellTileIndex       ;; 01:4bc6 $cd $e3 $4d
    ld   C, A                                         ;; 01:4bc9 $4f
    ld   A, [wDBDC_Menu_BlinkCounter]                 ;; 01:4bca $fa $dc $db
    and  A, MENU_CURSOR_BLINK_MASK                    ;; 01:4bcd $e6 $10
    jr   Z, .jr_01_4bd5                               ;; 01:4bcf $28 $04
    or   A, MENU_CURSOR_ATTR_BRIGHT                   ;; 01:4bd1 $f6 $03
    jr   .jr_01_4bd7                                  ;; 01:4bd3 $18 $02
.jr_01_4bd5:
    or   A, MENU_CURSOR_ATTR_DIM                      ;; 01:4bd5 $f6 $02
.jr_01_4bd7:
    ld   B, A                                         ;; 01:4bd7 $47
.jr_01_4bd8:
    ld   HL, wDBC2_MenuCursor_Tile                    ;; 01:4bd8 $21 $c2 $db
    ld   [HL], C                                      ;; 01:4bdb $71
    ld   HL, wDBC3_MenuCursor_Attr                    ;; 01:4bdc $21 $c3 $db
    ld   [HL], B                                      ;; 01:4bdf $70
    ld   A, [wDBEC_MenuRowSelected]                   ;; 01:4be0 $fa $ec $db
    ld   C, A                                         ;; 01:4be3 $4f
    inc  C                                            ;; 01:4be4 $0c
    ld   A, [wDB99_MenuType_CursorStepY]              ;; 01:4be5 $fa $99 $db
    ld   B, A                                         ;; 01:4be8 $47
    ld   A, [wDB97_MenuType_CursorBaseY]              ;; 01:4be9 $fa $97 $db
    sub  A, B                                         ;; 01:4bec $90
.jr_01_4bed:
    add  A, B                                         ;; 01:4bed $80
    dec  C                                            ;; 01:4bee $0d
    jr   NZ, .jr_01_4bed                              ;; 01:4bef $20 $fc
    ld   [wDBC0_MenuCursor_Y], A                      ;; 01:4bf1 $ea $c0 $db
    ld   A, [wDBEB_MenuColumnSelected]                ;; 01:4bf4 $fa $eb $db
    ld   C, A                                         ;; 01:4bf7 $4f
    inc  C                                            ;; 01:4bf8 $0c
    ld   A, [wDB98_MenuType_CursorStepX]              ;; 01:4bf9 $fa $98 $db
    ld   B, A                                         ;; 01:4bfc $47
    ld   A, [wDB96_MenuType_CursorBaseX]              ;; 01:4bfd $fa $96 $db
    sub  A, B                                         ;; 01:4c00 $90
.jr_01_4c01:
    add  A, B                                         ;; 01:4c01 $80
    dec  C                                            ;; 01:4c02 $0d
    jr   NZ, .jr_01_4c01                              ;; 01:4c03 $20 $fc
    ld   [wDBC1_MenuCursor_X], A                      ;; 01:4c05 $ea $c1 $db
    ld   HL, wDBBF_MenuCursor_OamSlot                 ;; 01:4c08 $21 $bf $db
    call call_01_4c45_Menu_BuildSpriteBlock           ;; 01:4c0b $cd $45 $4c
    ld   A, [wDBC7_Menu_CursorSpriteId]               ;; 01:4c0e $fa $c7 $db
    cp   A, MENU_CURSOR_PASSWORD                      ;; 01:4c11 $fe $01
    ret  NZ                                           ;; 01:4c13 $c0
    ld   HL, wDBDB_Menu_OamSlot                       ;; 01:4c14 $21 $db $db
    ld   A, [HL]                                      ;; 01:4c17 $7e
    inc  [HL]                                         ;; 01:4c18 $34
    ld   L, A                                         ;; 01:4c19 $6f
    ld   H, $00                                       ;; 01:4c1a $26 $00
    add  HL, HL                                       ;; 01:4c1c $29
    add  HL, HL                                       ;; 01:4c1d $29
    ld   DE, wD900_ShadowOAM                          ;; 01:4c1e $11 $00 $d9
    add  HL, DE                                       ;; 01:4c21 $19
    ld   A, [wDBEE_PasswordRowSelected]               ;; 01:4c22 $fa $ee $db
    add  A, A                                         ;; 01:4c25 $87
    add  A, A                                         ;; 01:4c26 $87
    add  A, A                                         ;; 01:4c27 $87
    add  A, $18                                       ;; 01:4c28 $c6 $18
    ld   [HL+], A                                     ;; 01:4c2a $22
    ld   A, [wDBED_PasswordColumnSelected]            ;; 01:4c2b $fa $ed $db
    ld   C, A                                         ;; 01:4c2e $4f
    add  A, A                                         ;; 01:4c2f $87
    add  A, A                                         ;; 01:4c30 $87
    add  A, A                                         ;; 01:4c31 $87
    add  A, $10                                       ;; 01:4c32 $c6 $10
    ld   [HL+], A                                     ;; 01:4c34 $22
    ld   A, [wDBEE_PasswordRowSelected]               ;; 01:4c35 $fa $ee $db
    add  A, A                                         ;; 01:4c38 $87
    add  A, A                                         ;; 01:4c39 $87
    add  A, A                                         ;; 01:4c3a $87
    add  A, A                                         ;; 01:4c3b $87
    add  A, C                                         ;; 01:4c3c $81
    add  A, $e0                                       ;; 01:4c3d $c6 $e0
    ld   [HL+], A                                     ;; 01:4c3f $22
    ld   A, [wDBC3_MenuCursor_Attr]                   ;; 01:4c40 $fa $c3 $db
    ld   [HL], A                                      ;; 01:4c43 $77
    ret                                               ;; 01:4c44 $c9

call_01_4c45_Menu_BuildSpriteBlock:
; Walks a sprite script and emits its rectangles into shadow OAM. The script is a
; starting OAM slot, then six-byte records - Y, X, tile, attributes, width in tiles,
; height in tiles - terminated by SPRITE_RECORD_END.
;
; Coordinates in a script are screen-relative and get OAM_Y_BIAS and OAM_X_BIAS added
; here. One flag is worth knowing: if bit 0 of the tile byte is set, the rest of the
; byte is an INDEX into wDAE1_TextBuffer rather than a tile id, which is how one
; static script can draw a digit that changes.
;
; It parses no text and fills no text buffer - the old name was wrong twice over.
; gex2's call_01_4dc8_Menu_BuildSpriteBlock
    ld   A, [HL+]                                     ;; 01:4c45 $2a
    cp   A, SPRITE_RECORD_END                         ;; 01:4c46 $fe $ff
    ret  Z                                            ;; 01:4c48 $c8
    ld   [wDBDB_Menu_OamSlot], A                      ;; 01:4c49 $ea $db $db
.jr_01_4c4c:
    ld   A, [HL+]                                     ;; 01:4c4c $2a
    cp   A, SPRITE_RECORD_END                         ;; 01:4c4d $fe $ff
    ret  Z                                            ;; 01:4c4f $c8
    add  A, OAM_Y_BIAS                                ;; 01:4c50 $c6 $10
    ld   [wDADD_MenuTextBuffer], A                    ;; 01:4c52 $ea $dd $da
    ld   A, [HL+]                                     ;; 01:4c55 $2a
    add  A, OAM_X_BIAS                                ;; 01:4c56 $c6 $08
    ld   [wDADE], A                                   ;; 01:4c58 $ea $de $da
    ld   A, [HL+]                                     ;; 01:4c5b $2a
    bit  0, A                                         ;; 01:4c5c $cb $47
    jr   Z, .jr_01_4c6c                               ;; 01:4c5e $28 $0c
    push HL                                           ;; 01:4c60 $e5
    srl  A                                            ;; 01:4c61 $cb $3f
    ld   E, A                                         ;; 01:4c63 $5f
    ld   D, $00                                       ;; 01:4c64 $16 $00
    ld   HL, wDAE1_TextBuffer                         ;; 01:4c66 $21 $e1 $da
    add  HL, DE                                       ;; 01:4c69 $19
    ld   A, [HL]                                      ;; 01:4c6a $7e
    pop  HL                                           ;; 01:4c6b $e1
.jr_01_4c6c:
    ld   [wDADF], A                                   ;; 01:4c6c $ea $df $da
    ld   A, [HL+]                                     ;; 01:4c6f $2a
    ld   [wDAE0], A                                   ;; 01:4c70 $ea $e0 $da
    ld   C, [HL]                                      ;; 01:4c73 $4e
    inc  HL                                           ;; 01:4c74 $23
    ld   B, [HL]                                      ;; 01:4c75 $46
    inc  HL                                           ;; 01:4c76 $23
    push HL                                           ;; 01:4c77 $e5
    call call_01_4c7e_Menu_WriteSpriteRect            ;; 01:4c78 $cd $7e $4c
    pop  HL                                           ;; 01:4c7b $e1
    jr   .jr_01_4c4c                                  ;; 01:4c7c $18 $ce

call_01_4c7e_Menu_WriteSpriteRect:
; Emits one rectangle of 8x8 sprites into wD900_ShadowOAM, C columns by B rows,
; advancing wDBDB_Menu_OamSlot as it goes. Column-major: the tile id increments down a
; column, then X steps across and Y is restored from the stack.
;
; gex2's call_01_4e01_Menu_WriteSpriteRect is the same routine for 8x16 sprites, so
; its tile step is 2 and its Y step $10 where these are 1 and 8
    ld   HL, wDBDB_Menu_OamSlot                       ;; 01:4c7e $21 $db $db
    ld   L, [HL]                                      ;; 01:4c81 $6e
    ld   H, $00                                       ;; 01:4c82 $26 $00
    add  HL, HL                                       ;; 01:4c84 $29
    add  HL, HL                                       ;; 01:4c85 $29
    ld   DE, wD900_ShadowOAM                          ;; 01:4c86 $11 $00 $d9
    add  HL, DE                                       ;; 01:4c89 $19
    ld   A, [wDADD_MenuTextBuffer]                    ;; 01:4c8a $fa $dd $da
.jr_01_4c8d:
    push BC                                           ;; 01:4c8d $c5
    push AF                                           ;; 01:4c8e $f5
    ld   [wDADD_MenuTextBuffer], A                    ;; 01:4c8f $ea $dd $da
.jr_01_4c92:
    ld   A, [wDADD_MenuTextBuffer]                    ;; 01:4c92 $fa $dd $da
    ld   [HL+], A                                     ;; 01:4c95 $22
    add  A, $08                                       ;; 01:4c96 $c6 $08
    ld   [wDADD_MenuTextBuffer], A                    ;; 01:4c98 $ea $dd $da
    ld   A, [wDADE]                                   ;; 01:4c9b $fa $de $da
    ld   [HL+], A                                     ;; 01:4c9e $22
    ld   A, [wDADF]                                   ;; 01:4c9f $fa $df $da
    ld   [HL+], A                                     ;; 01:4ca2 $22
    inc  A                                            ;; 01:4ca3 $3c
    ld   [wDADF], A                                   ;; 01:4ca4 $ea $df $da
    ld   A, [wDAE0]                                   ;; 01:4ca7 $fa $e0 $da
    ld   [HL+], A                                     ;; 01:4caa $22
    ld   A, [wDBDB_Menu_OamSlot]                      ;; 01:4cab $fa $db $db
    inc  A                                            ;; 01:4cae $3c
    ld   [wDBDB_Menu_OamSlot], A                      ;; 01:4caf $ea $db $db
    dec  B                                            ;; 01:4cb2 $05
    jr   NZ, .jr_01_4c92                              ;; 01:4cb3 $20 $dd
    ld   A, [wDADE]                                   ;; 01:4cb5 $fa $de $da
    add  A, $08                                       ;; 01:4cb8 $c6 $08
    ld   [wDADE], A                                   ;; 01:4cba $ea $de $da
    pop  AF                                           ;; 01:4cbd $f1
    pop  BC                                           ;; 01:4cbe $c1
    dec  C                                            ;; 01:4cbf $0d
    jr   NZ, .jr_01_4c8d                              ;; 01:4cc0 $20 $cb
    ret                                               ;; 01:4cc2 $c9

call_01_4cc3_Menu_GetVramAddrForDestTile:
; The VRAM address of the block's first tile - _VRAM plus
; wDBA2_MenuCmd_FirstTileId tiles.
;
; NOTHING CALLS THIS. It is the pair to
; call_01_4cd4_Menu_GetStagingAddrForDestTile below, which is live; the VRAM half is
; dead in this build, though gex2's equivalent is used
    ld   hl,wDBA2_MenuCmd_FirstTileId
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,hl
    add  hl,hl
    add  hl,hl
    ld   de,_VRAM
    add  hl,de
    ld   e,l
    ld   d,h
    ret  

call_01_4cd4_Menu_GetStagingAddrForDestTile:
; The same address in the staging buffer instead of VRAM: wC000_BgMapTileIds plus
; wDBA2_MenuCmd_FirstTileId tiles, returned in both DE and HL.
;
; This is what ties a menu command's tile id to the bytes the text renderer writes.
; gex2 has no such routine - it hardcodes the buffer base inside the renderer, which
; is why gex2 can only render from the start of the buffer and gex3 can render into a
; sub-block
    ld   HL, wDBA2_MenuCmd_FirstTileId                ;; 01:4cd4 $21 $a2 $db
    ld   L, [HL]                                      ;; 01:4cd7 $6e
    ld   H, $00                                       ;; 01:4cd8 $26 $00
    add  HL, HL                                       ;; 01:4cda $29
    add  HL, HL                                       ;; 01:4cdb $29
    add  HL, HL                                       ;; 01:4cdc $29
    add  HL, HL                                       ;; 01:4cdd $29
    ld   DE, wC000_BgMapTileIds                       ;; 01:4cde $11 $00 $c0
    add  HL, DE                                       ;; 01:4ce1 $19
    ld   E, L                                         ;; 01:4ce2 $5d
    ld   D, H                                         ;; 01:4ce3 $54
    ret                                               ;; 01:4ce4 $c9

call_01_4ce5_Menu_GetTileDataSize:
; BC = the block's size in bytes, width times height times TILE_SIZE_BYTES, by
; repeated addition.
;
; It also leaves the plain tile COUNT in A, which
; call_01_499f_Text_ClearBuffer depends on as its loop counter - an undocumented
; second return value worth knowing before editing either. gex2's
; call_01_4e5a_Menu_GetTileDataSize
    ld   HL, wDB9E_MenuCmd_WidthTiles                 ;; 01:4ce5 $21 $9e $db
    ld   C, [HL]                                      ;; 01:4ce8 $4e
    inc  HL                                           ;; 01:4ce9 $23
    ld   B, [HL]                                      ;; 01:4cea $46
    xor  A, A                                         ;; 01:4ceb $af
.jr_01_4cec:
    add  A, C                                         ;; 01:4cec $81
    dec  B                                            ;; 01:4ced $05
    jr   NZ, .jr_01_4cec                              ;; 01:4cee $20 $fc
    ld   L, A                                         ;; 01:4cf0 $6f
    ld   H, $00                                       ;; 01:4cf1 $26 $00
    add  HL, HL                                       ;; 01:4cf3 $29
    add  HL, HL                                       ;; 01:4cf4 $29
    add  HL, HL                                       ;; 01:4cf5 $29
    add  HL, HL                                       ;; 01:4cf6 $29
    ld   C, L                                         ;; 01:4cf7 $4d
    ld   B, H                                         ;; 01:4cf8 $44
    ret                                               ;; 01:4cf9 $c9

call_01_4cfa_Menu_SetScriptSrcPtr:
; Stores HL as the current text source pointer. Four instructions, nine callers - it
; is how every MenuCmd_Set*Text handler hands its string to the renderer. gex2's
; call_01_4e6f_Menu_SetScriptSrcPtr
    ld   A, L                                         ;; 01:4cfa $7d
    ld   [wDBA7_MenuCmd_SrcPtr], A                    ;; 01:4cfb $ea $a7 $db
    ld   A, H                                         ;; 01:4cfe $7c
    ld   [wDBA8_MenuCmd_SrcPtrHi], A                  ;; 01:4cff $ea $a8 $db
    ret                                               ;; 01:4d02 $c9

call_01_4d03_Menu_StageTileData:
; Copies a block of tile graphics into the staging buffer. HL points at a three-byte
; header - width in tiles, height in tiles, mode - followed by the data.
;
; Mode $00 copies; anything else returns without copying, which reserves the block and
; leaves whatever was there. gex2's call_01_4e78_Menu_StageTileData
    ld   A, [wDBA6_MenuCmd_Arg2]                      ;; 01:4d03 $fa $a6 $db
    ld   [wDBA2_MenuCmd_FirstTileId], A               ;; 01:4d06 $ea $a2 $db
    ld   A, [HL+]                                     ;; 01:4d09 $2a
    ld   [wDB9E_MenuCmd_WidthTiles], A                ;; 01:4d0a $ea $9e $db
    ld   A, [HL+]                                     ;; 01:4d0d $2a
    ld   [wDB9F_MenuCmd_HeightTiles], A               ;; 01:4d0e $ea $9f $db
    push HL                                           ;; 01:4d11 $e5
    call call_01_4ce5_Menu_GetTileDataSize            ;; 01:4d12 $cd $e5 $4c
    ld   HL, wDBA6_MenuCmd_Arg2                       ;; 01:4d15 $21 $a6 $db
    ld   L, [HL]                                      ;; 01:4d18 $6e
    ld   H, $00                                       ;; 01:4d19 $26 $00
    add  HL, HL                                       ;; 01:4d1b $29
    add  HL, HL                                       ;; 01:4d1c $29
    add  HL, HL                                       ;; 01:4d1d $29
    add  HL, HL                                       ;; 01:4d1e $29
    ld   DE, wC000_BgMapTileIds                       ;; 01:4d1f $11 $00 $c0
    add  HL, DE                                       ;; 01:4d22 $19
    ld   E, L                                         ;; 01:4d23 $5d
    ld   D, H                                         ;; 01:4d24 $54
    pop  HL                                           ;; 01:4d25 $e1
    ld   A, [HL+]                                     ;; 01:4d26 $2a
    and  A, A                                         ;; 01:4d27 $a7
    jp   Z, call_00_076e_MemCopy                      ;; 01:4d28 $ca $6e $07
    ret                                               ;; 01:4d2b $c9

call_01_4d2c_Menu_WaitForNoInput:
; The menu idle loop: redraw the cursor, tick the sprite-hide timer, wait for vblank,
; advance the blink counter, and repeat for as long as any button is held. So it is a
; wait-for-RELEASE, which is what stops one press being read by two screens in a row.
;
; MENU_FLAG_GRID_INPUT screens mask the A button out of the test, because on the
; password keyboard A is held down while the d-pad moves the cell cursor. gex2's
; call_01_4e94_Menu_WaitForNoInput
    call call_01_4bb8_Menu_DrawCursor                 ;; 01:4d2c $cd $b8 $4b
    call call_01_4b6b_Menu_TickHideSprites            ;; 01:4d2f $cd $6b $4b
    call call_00_0b92_WaitForInterrupt                ;; 01:4d32 $cd $92 $0b
    ld   HL, wDBDC_Menu_BlinkCounter                  ;; 01:4d35 $21 $dc $db
    dec  [HL]                                         ;; 01:4d38 $35
    ld   A, [wDB94_MenuType_Flags]                    ;; 01:4d39 $fa $94 $db
    and  A, $01                                       ;; 01:4d3c $e6 $01
    ld   A, [wDAD7_RawInputs]                         ;; 01:4d3e $fa $d7 $da
    jr   Z, .jr_01_4d45                               ;; 01:4d41 $28 $02
    and  A, PADF_B | PADF_SELECT | PADF_START | PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN ;; 01:4d43 $e6 $fe
.jr_01_4d45:
    and  A, A                                         ;; 01:4d45 $a7
    jr   NZ, call_01_4d2c_Menu_WaitForNoInput         ;; 01:4d46 $20 $e4
    ret                                               ;; 01:4d48 $c9

call_01_4d49_Text_FormatByte:
; A as one to three ASCII digits in wDADD_MenuTextBuffer, TEXT_TERMINATOR after
; them, leading zeros suppressed. Repeated subtraction of 100 then 10, with each
; counter seeded at ASCII_ZERO - 1 so the first increment lands on '0'. gex2's
; call_01_4ce5_Text_FormatByte
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:4d49 $21 $dd $da
    cp   A, $0a                                       ;; 01:4d4c $fe $0a
    jr   C, .jr_01_4d68                               ;; 01:4d4e $38 $18
    cp   A, $64                                       ;; 01:4d50 $fe $64
    jr   C, .jr_01_4d5e                               ;; 01:4d52 $38 $0a
    ld   [HL], ASCII_ZERO - 1                         ;; 01:4d54 $36 $2f
.jr_01_4d56:
    inc  [HL]                                         ;; 01:4d56 $34
    sub  A, $64                                       ;; 01:4d57 $d6 $64
    jr   NC, .jr_01_4d56                              ;; 01:4d59 $30 $fb
    add  A, $64                                       ;; 01:4d5b $c6 $64
    inc  HL                                           ;; 01:4d5d $23
.jr_01_4d5e:
    ld   [HL], ASCII_ZERO - 1                         ;; 01:4d5e $36 $2f
.jr_01_4d60:
    inc  [HL]                                         ;; 01:4d60 $34
    sub  A, $0a                                       ;; 01:4d61 $d6 $0a
    jr   NC, .jr_01_4d60                              ;; 01:4d63 $30 $fb
    add  A, $0a                                       ;; 01:4d65 $c6 $0a
    inc  HL                                           ;; 01:4d67 $23
.jr_01_4d68:
    add  A, ASCII_ZERO                                ;; 01:4d68 $c6 $30
    ld   [HL+], A                                     ;; 01:4d6a $22
    ld   [HL], TEXT_TERMINATOR                        ;; 01:4d6b $36 $80
    ret                                               ;; 01:4d6d $c9

call_01_4d6e_Password_RefreshCellGfx:
; Redraws the one password cell the player just typed into, rather than the whole
; grid.
;
; It waits for any in-flight graphics stream to finish, then sets up a one-chunk,
; PASSWORD_CELL_TILES-tile transfer: source is the glyph for whatever key is now in
; the cell, destination is that cell's tiles in VRAM. The LCD interrupt handler does
; the actual copy.
;
; gex2's call_01_4ecf_Password_RefreshCellGfx
    ld   A, [wDBEF_GfxStream_ChunksRemaining]         ;; 01:4d6e $fa $ef $db
    and  A, A                                         ;; 01:4d71 $a7
    jr   NZ, call_01_4d6e_Password_RefreshCellGfx     ;; 01:4d72 $20 $fa
    ld   A, $01                                       ;; 01:4d74 $3e $01
    ld   [wDBEF_GfxStream_ChunksRemaining], A         ;; 01:4d76 $ea $ef $db
    ld   A, PASSWORD_CELL_TILES                       ;; 01:4d79 $3e $04
    ld   [wDBF0_GfxStream_RowsPerChunk], A            ;; 01:4d7b $ea $f0 $db
    ld   A, $01                                       ;; 01:4d7e $3e $01
    ld   [wDBF1_GfxStream_SrcBank], A                 ;; 01:4d80 $ea $f1 $db
    call call_01_4dc9_Password_GetCellUnderCursor     ;; 01:4d83 $cd $c9 $4d
    ld   L, A                                         ;; 01:4d86 $6f
    ld   H, $00                                       ;; 01:4d87 $26 $00
    add  HL, HL                                       ;; 01:4d89 $29
    add  HL, HL                                       ;; 01:4d8a $29
    add  HL, HL                                       ;; 01:4d8b $29
    add  HL, HL                                       ;; 01:4d8c $29
    add  HL, HL                                       ;; 01:4d8d $29
    add  HL, HL                                       ;; 01:4d8e $29
    ld   DE, data_01_66f9_PasswordFont                ;; 01:4d8f $11 $f9 $66
    add  HL, DE                                       ;; 01:4d92 $19
    ld   A, L                                         ;; 01:4d93 $7d
    ld   [wDBF2], A                                   ;; 01:4d94 $ea $f2 $db
    ld   A, H                                         ;; 01:4d97 $7c
    ld   [wDBF3], A                                   ;; 01:4d98 $ea $f3 $db
    call call_01_4de3_Password_GetCellTileIndex       ;; 01:4d9b $cd $e3 $4d
    ld   L, A                                         ;; 01:4d9e $6f
    ld   H, $00                                       ;; 01:4d9f $26 $00
    add  HL, HL                                       ;; 01:4da1 $29
    add  HL, HL                                       ;; 01:4da2 $29
    add  HL, HL                                       ;; 01:4da3 $29
    add  HL, HL                                       ;; 01:4da4 $29
    ld   DE, _VRAM                                    ;; 01:4da5 $11 $00 $80
    add  HL, DE                                       ;; 01:4da8 $19
    ld   A, L                                         ;; 01:4da9 $7d
    ld   [wDBF4], A                                   ;; 01:4daa $ea $f4 $db
    ld   A, H                                         ;; 01:4dad $7c
    ld   [wDBF5], A                                   ;; 01:4dae $ea $f5 $db
    ld   HL, wDBEF_GfxStream_ChunksRemaining          ;; 01:4db1 $21 $ef $db
    ld   A, [HL+]                                     ;; 01:4db4 $2a
    ld   [wDBEF_GfxStream_ChunksRemaining], A         ;; 01:4db5 $ea $ef $db
    ld   A, [HL+]                                     ;; 01:4db8 $2a
    ld   [wDBF0_GfxStream_RowsPerChunk], A            ;; 01:4db9 $ea $f0 $db
    ld   A, [HL+]                                     ;; 01:4dbc $2a
    ld   [wDBF1_GfxStream_SrcBank], A                 ;; 01:4dbd $ea $f1 $db
    ld   A, L                                         ;; 01:4dc0 $7d
    ld   [wDBF6_GfxStream_ListPtrLo], A               ;; 01:4dc1 $ea $f6 $db
    ld   A, H                                         ;; 01:4dc4 $7c
    ld   [wDBF7_GfxStream_ListPtrHi], A               ;; 01:4dc5 $ea $f7 $db
    ret                                               ;; 01:4dc8 $c9

call_01_4dc9_Password_GetCellUnderCursor:
; The key value stored in the cell the grid cursor is on - row times
; PASSWORD_GRID_COLUMNS plus column, into wDB7E_PasswordValues. Returns a key index or
; PASSWORD_KEY_BLANK, not a tile id. gex2's call_01_4f1b_Password_GetCellUnderCursor
    ld   HL, wDBEC_MenuRowSelected                    ;; 01:4dc9 $21 $ec $db
    ld   B, [HL]                                      ;; 01:4dcc $46
    ld   A, $fa                                       ;; 01:4dcd $3e $fa
.jr_01_4dcf:
    add  A, PASSWORD_GRID_COLUMNS                     ;; 01:4dcf $c6 $06
    dec  B                                            ;; 01:4dd1 $05
    bit  7, B                                         ;; 01:4dd2 $cb $78
    jr   Z, .jr_01_4dcf                               ;; 01:4dd4 $28 $f9
    ld   HL, wDBEB_MenuColumnSelected                 ;; 01:4dd6 $21 $eb $db
    add  A, [HL]                                      ;; 01:4dd9 $86
    ld   E, A                                         ;; 01:4dda $5f
    ld   D, $00                                       ;; 01:4ddb $16 $00
    ld   HL, wDB7E_PasswordValues                     ;; 01:4ddd $21 $7e $db
    add  HL, DE                                       ;; 01:4de0 $19
    ld   A, [HL]                                      ;; 01:4de1 $7e
    ret                                               ;; 01:4de2 $c9

call_01_4de3_Password_GetCellTileIndex:
; The VRAM tile id of the first of that cell's four tiles: the cell number times
; PASSWORD_CELL_TILES, plus PASSWORD_CELL_TILE_BASE.
;
; That base matches the first-tile column of descriptor ids $00 to $11 in
; data_01_512e_MenuCmd_Descriptors exactly, which is an independent check on both
; tables. gex2's call_01_4f30_Password_GetCellTileIndex
    ld   A, [wDBEC_MenuRowSelected]                   ;; 01:4de3 $fa $ec $db
    add  A, A                                         ;; 01:4de6 $87
    ld   L, A                                         ;; 01:4de7 $6f
    add  A, A                                         ;; 01:4de8 $87
    add  A, L                                         ;; 01:4de9 $85
    ld   L, A                                         ;; 01:4dea $6f
    ld   A, [wDBEB_MenuColumnSelected]                ;; 01:4deb $fa $eb $db
    add  A, L                                         ;; 01:4dee $85
    add  A, A                                         ;; 01:4def $87
    add  A, A                                         ;; 01:4df0 $87
    add  A, PASSWORD_CELL_TILE_BASE                   ;; 01:4df1 $c6 $98
    ret                                               ;; 01:4df3 $c9

call_01_4df4_Text_CharToGlyphIndex:
; Character code to glyph index, straight through .data_01_4dfd_CharToGlyph. gex2's
; call_01_4f41_Text_CharToGlyphIndex biases its table by $20; gex3's is indexed by the
; raw code
    ld   E, A                                         ;; 01:4df4 $5f
    ld   D, $00                                       ;; 01:4df5 $16 $00
    ld   HL, .data_01_4dfd_CharToGlyph                ;; 01:4df7 $21 $fd $4d
    add  HL, DE                                       ;; 01:4dfa $19
    ld   A, [HL]                                      ;; 01:4dfb $7e
    ret                                               ;; 01:4dfc $c9
.data_01_4dfd_CharToGlyph:
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4dfd ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e05 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e0d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e15 ????????
    db   $00, $3a, $00, $00, $00, $00, $00, $44       ;; 01:4e1d ww??????
    db   $42, $43, $00, $00, $3f, $40, $3e, $41       ;; 01:4e25 ww??wwww
    db   $1b, $1c, $1d, $1e, $1f, $20, $21, $22       ;; 01:4e2d wwwwww??
    db   $23, $24, $00, $00, $00, $00, $00, $39       ;; 01:4e35 ?w??????
    db   $00, $25, $26, $27, $28, $29, $2a, $2b       ;; 01:4e3d ????????
    db   $2c, $2d, $2e, $2f, $30, $31, $32, $33       ;; 01:4e45 ????????
    db   $34, $35, $36, $37, $38, $3b, $3c, $3d       ;; 01:4e4d ????????
    db   $45, $46, $00, $00, $00, $00, $00, $00       ;; 01:4e55 ww??????
    db   $00, $01, $02, $03, $04, $05, $06, $07       ;; 01:4e5d wwwwwwww
    db   $08, $09, $0a, $0b, $0c, $0d, $0e, $0f       ;; 01:4e65 wwwwwwww
    db   $10, $11, $12, $13, $14, $15, $16, $17       ;; 01:4e6d wwwwwwww
    db   $18, $19, $1a, $00, $00, $00, $00, $00       ;; 01:4e75 www?????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e7d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e85 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e8d ????????
    db   $00, $00                                     ;; 01:4e95 ??

data_01_4e97_Padding:
; Padding, and then two things that are not padding.
;
; The bytes from here to $4EFC are zero. What follows them at $4EFD is nine bytes of
; CODE - a small "index into the table below" routine - and then a 33-entry table
; mapping key index to ASCII, blank plus 'A'-'Z' plus '0'-'5', which is the
; PASSWORD_KEY_COLUMNS * PASSWORD_KEY_ROWS keyboard's alphabet. Nothing in the
; disassembly reaches either.
;
; Note that this LABEL is not what the two `ld HL, MENUTEXT_COUNTER_STRINGS`
; operands mean. They also hold $4E97, but they are dereferenced with BANK_1C_TEXT
; paged in - the collision is a coincidence of layout
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e97 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4e9f ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4ea7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4eaf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4eb7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4ebf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4ec7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4ecf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4ed7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4edf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4ee7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4eef ????????
    db   $00, $00, $00, $00, $00, $00, $5f, $16       ;; 01:4ef7 ????????
    db   $00, $21, $06, $4f, $19, $7e, $c9, $20       ;; 01:4eff ????????
    db   $41, $42, $43, $44, $45, $46, $47, $48       ;; 01:4f07 ????????
    db   $49, $4a, $4b, $4c, $4d, $4e, $4f, $50       ;; 01:4f0f ????????
    db   $51, $52, $53, $54, $55, $56, $57, $58       ;; 01:4f17 ????????
    db   $59, $5a, $30, $31, $32, $33, $34, $35       ;; 01:4f1f ????????

call_01_4f27_Menu_ClearScreenBuffers:
; Blanks everything a screen build writes into: one tile of the staging buffer, the
; tile-id plane to zero, and the attribute plane to palette 1. All three are
; overlapping-copy fills - MemCopy with the destination one byte past the source, so
; each write feeds the next read
    ld   HL, wC000_BgMapTileIds                       ;; 01:4f27 $21 $00 $c0
    ld   DE, wC000_BgMapTileIds+1                     ;; 01:4f2a $11 $01 $c0 ; wC000_BgMapTileIds
    ld   [HL], $00                                    ;; 01:4f2d $36 $00
    ld   BC, $0f                                      ;; 01:4f2f $01 $0f $00
    call call_00_076e_MemCopy                         ;; 01:4f32 $cd $6e $07
    ld   HL, wD400_ScreenDraw_TileIds                 ;; 01:4f35 $21 $00 $d4
    ld   DE, wD400_ScreenDraw_TileIds+1               ;; 01:4f38 $11 $01 $d4
    ld   [HL], $00                                    ;; 01:4f3b $36 $00
    ld   BC, SCREEN_TILEMAP_BYTES - 1                 ;; 01:4f3d $01 $67 $01
    call call_00_076e_MemCopy                         ;; 01:4f40 $cd $6e $07
    ld   HL, wD578_ScreenDraw_PaletteIds              ;; 01:4f43 $21 $78 $d5
    ld   DE, wD578_ScreenDraw_PaletteIds+1            ;; 01:4f46 $11 $79 $d5
    ld   [HL], $01                                    ;; 01:4f49 $36 $01
    ld   BC, SCREEN_TILEMAP_BYTES - 1                 ;; 01:4f4b $01 $67 $01
    jp   call_00_076e_MemCopy                         ;; 01:4f4e $c3 $6e $07

call_01_4f51_Menu_UploadBgAttrMap:
; Stages the attribute plane into the tile buffer and fires
; HDMACFG_BGMAP_ATTRIBUTES. The old "secondary tile layer" name described neither
; end of it
    ld   DE, wD578_ScreenDraw_PaletteIds              ;; 01:4f51 $11 $78 $d5
    call call_01_4f67_Menu_StageScreenPlane           ;; 01:4f54 $cd $67 $4f
    ld   C, HDMACFG_BGMAP_ATTRIBUTES                  ;; 01:4f57 $0e $07
    jp   call_00_0a6a_Hdma_RunConfigEntry             ;; 01:4f59 $c3 $6a $0a

call_01_4f5c_Menu_UploadBgTileMap:
; The same for the tile-id plane and HDMACFG_BGMAP_TILE_IDS. Called immediately after
; the attribute upload, so the two planes reach VRAM one after the other
    ld   DE, wD400_ScreenDraw_TileIds                 ;; 01:4f5c $11 $00 $d4
    call call_01_4f67_Menu_StageScreenPlane           ;; 01:4f5f $cd $67 $4f
    ld   C, HDMACFG_BGMAP_TILE_IDS                    ;; 01:4f62 $0e $08
    jp   call_00_0a6a_Hdma_RunConfigEntry             ;; 01:4f64 $c3 $6a $0a

call_01_4f67_Menu_StageScreenPlane:
; Copies one SCRN_X_B by SCRN_Y_B plane into wC000_BgMapTileIds, adding
; SCRN_VX_B - SCRN_X_B to the destination after every row - because the BG map is 32
; tiles wide and only 20 of them are on screen. The old comment had the block as
; 12x20; the 12 is the stride remainder, not a dimension
    ld   HL, wC000_BgMapTileIds                       ;; 01:4f67 $21 $00 $c0
    ld   B, SCRN_Y_B                                  ;; 01:4f6a $06 $12
.jr_01_4f6c:
    push BC                                           ;; 01:4f6c $c5
    ld   B, SCRN_X_B                                  ;; 01:4f6d $06 $14
.jr_01_4f6f:
    ld   A, [DE]                                      ;; 01:4f6f $1a
    ld   [HL+], A                                     ;; 01:4f70 $22
    inc  DE                                           ;; 01:4f71 $13
    dec  B                                            ;; 01:4f72 $05
    jr   NZ, .jr_01_4f6f                              ;; 01:4f73 $20 $fa
    ld   BC, SCRN_VX_B - SCRN_X_B                     ;; 01:4f75 $01 $0c $00
    add  HL, BC                                       ;; 01:4f78 $09
    pop  BC                                           ;; 01:4f79 $c1
    dec  B                                            ;; 01:4f7a $05
    jr   NZ, .jr_01_4f6c                              ;; 01:4f7b $20 $ef
    ret                                               ;; 01:4f7d $c9
    
call_01_4f7e_Password_ClearEntryGrid:
; Fills all PASSWORD_CELL_COUNT cells with PASSWORD_KEY_BLANK. Called when the
; password screen opens and again after a rejected password, so the player never types
; over someone else's leftovers. gex2's call_01_4f87_Password_ClearEntryGrid
    ld   HL, wDB7E_PasswordValues                     ;; 01:4f7e $21 $7e $db
    ld   DE, wDB7E_PasswordValues+1                   ;; 01:4f81 $11 $7f $db
    ld   BC, PASSWORD_CELL_COUNT - 1                  ;; 01:4f84 $01 $11 $00
    ld   [HL], PASSWORD_KEY_BLANK                     ;; 01:4f87 $36 $20
    jp   call_00_076e_MemCopy                         ;; 01:4f89 $c3 $6e $07

call_01_4f8c_Password_BuildPayload:
; Packs the save file into the PASSWORD_PAYLOAD_BYTES payload that
; call_01_5027_Password_Encode will spread across the grid.
;
; Three header bytes first - lives, paw coins, paw-coin extra health. Then the
; progress bits: each of the PROGRESS_FLAG_COUNT levels has a mask in
; .data_01_5013_LevelProgressMasks saying which of its bits are worth saving, and
; every surviving bit is appended to a bit stream, most significant first, using
; wDB90_PasswordCounter as the running bit position. The masks pass 58 bits in total.
;
; Four header bits plus 58 progress bits is exactly PASSWORD_TOTAL_BITS, which is why
; PASSWORD_CELL_COUNT cells of PASSWORD_BITS_PER_CELL bits fit with nothing left over.
;
; The checksum is the sum of the other PASSWORD_CHECKSUM_BYTES bytes XOR
; PASSWORD_CHECKSUM_XOR, stored in the first byte. gex2's
; call_01_4349_Password_BuildPayload
    ld   HL, wDB72_PasswordEncodedBuffer              ;; 01:4f8c $21 $72 $db
    ld   B, PASSWORD_PAYLOAD_BYTES                    ;; 01:4f8f $06 $0c
    xor  A, A                                         ;; 01:4f91 $af
.jr_01_4f92:
    ld   [HL+], A                                     ;; 01:4f92 $22
    dec  B                                            ;; 01:4f93 $05
    jr   NZ, .jr_01_4f92                              ;; 01:4f94 $20 $fc
    xor  A, A                                         ;; 01:4f96 $af
    ld   [wDB72_PasswordEncodedBuffer], A             ;; 01:4f97 $ea $72 $db
    ld   A, [wDC4E_LivesRemaining]                    ;; 01:4f9a $fa $4e $dc
    ld   [wDB73_PasswordLivesRemaining], A            ;; 01:4f9d $ea $73 $db
    ld   A, [wDCAF_PawCoinCounter]                    ;; 01:4fa0 $fa $af $dc
    ld   [wDB74_PasswordPawCoinCounter], A            ;; 01:4fa3 $ea $74 $db
    ld   A, [wDC4F_PawCoinExtraHealth]                ;; 01:4fa6 $fa $4f $dc
    ld   [wDB75_PasswordPawCoinExtraHealth], A        ;; 01:4fa9 $ea $75 $db
    xor  A, A                                         ;; 01:4fac $af
    ld   [wDB90_PasswordCounter], A                   ;; 01:4fad $ea $90 $db
    ld   DE, $00                                      ;; 01:4fb0 $11 $00 $00
.jr_01_4fb3:
    push DE                                           ;; 01:4fb3 $d5
    ld   HL, wDC5C_ProgressFlags                      ;; 01:4fb4 $21 $5c $dc
    add  HL, DE                                       ;; 01:4fb7 $19
    ld   C, [HL]                                      ;; 01:4fb8 $4e
    ld   HL, .data_01_5013_LevelProgressMasks         ;; 01:4fb9 $21 $13 $50
    add  HL, DE                                       ;; 01:4fbc $19
    ld   B, [HL]                                      ;; 01:4fbd $46
    ld   A, $08                                       ;; 01:4fbe $3e $08
.jr_01_4fc0:
    push AF                                           ;; 01:4fc0 $f5
    bit  7, B                                         ;; 01:4fc1 $cb $78
    jr   Z, .jr_01_4fee                               ;; 01:4fc3 $28 $29
    bit  7, C                                         ;; 01:4fc5 $cb $79
    jr   Z, .jr_01_4fea                               ;; 01:4fc7 $28 $21
    ld   A, [wDB90_PasswordCounter]                   ;; 01:4fc9 $fa $90 $db
    srl  A                                            ;; 01:4fcc $cb $3f
    srl  A                                            ;; 01:4fce $cb $3f
    srl  A                                            ;; 01:4fd0 $cb $3f
    ld   E, A                                         ;; 01:4fd2 $5f
    ld   D, $00                                       ;; 01:4fd3 $16 $00
    ld   HL, wDB76_PasswordEncodedBuffer              ;; 01:4fd5 $21 $76 $db
    add  HL, DE                                       ;; 01:4fd8 $19
    push HL                                           ;; 01:4fd9 $e5
    ld   A, [wDB90_PasswordCounter]                   ;; 01:4fda $fa $90 $db
    and  A, $07                                       ;; 01:4fdd $e6 $07
    ld   E, A                                         ;; 01:4fdf $5f
    ld   D, $00                                       ;; 01:4fe0 $16 $00
    ld   HL, .data_01_501f_BitMaskLut_80to01          ;; 01:4fe2 $21 $1f $50
    add  HL, DE                                       ;; 01:4fe5 $19
    ld   A, [HL]                                      ;; 01:4fe6 $7e
    pop  HL                                           ;; 01:4fe7 $e1
    or   A, [HL]                                      ;; 01:4fe8 $b6
    ld   [HL], A                                      ;; 01:4fe9 $77
.jr_01_4fea:
    ld   HL, wDB90_PasswordCounter                    ;; 01:4fea $21 $90 $db
    inc  [HL]                                         ;; 01:4fed $34
.jr_01_4fee:
    sla  C                                            ;; 01:4fee $cb $21
    sla  B                                            ;; 01:4ff0 $cb $20
    pop  AF                                           ;; 01:4ff2 $f1
    dec  A                                            ;; 01:4ff3 $3d
    jr   NZ, .jr_01_4fc0                              ;; 01:4ff4 $20 $ca
    pop  DE                                           ;; 01:4ff6 $d1
    inc  E                                            ;; 01:4ff7 $1c
    ld   A, E                                         ;; 01:4ff8 $7b
    cp   A, PROGRESS_FLAG_COUNT                       ;; 01:4ff9 $fe $0c
    jr   C, .jr_01_4fb3                               ;; 01:4ffb $38 $b6
    ld   HL, wDB73_PasswordLivesRemaining             ;; 01:4ffd $21 $73 $db
    ld   B, PASSWORD_CHECKSUM_BYTES                   ;; 01:5000 $06 $0b
    xor  A, A                                         ;; 01:5002 $af
.jr_01_5003:
    add  A, [HL]                                      ;; 01:5003 $86
    inc  HL                                           ;; 01:5004 $23
    dec  B                                            ;; 01:5005 $05
    jr   NZ, .jr_01_5003                              ;; 01:5006 $20 $fb
    xor  A, PASSWORD_CHECKSUM_XOR                     ;; 01:5008 $ee $b6
    ld   [wDB72_PasswordEncodedBuffer], A             ;; 01:500a $ea $72 $db
    ld   A, $01                                       ;; 01:500d $3e $01
    ld   [wDB91_PasswordCompletionFlag], A            ;; 01:500f $ea $91 $db
    ret                                               ;; 01:5012 $c9
.data_01_5013_LevelProgressMasks:
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01       ;; 01:5013 ........
    db   $01, $01, $01, $01                           ;; 01:501b ....
.data_01_501f_BitMaskLut_80to01:
    db   $80, $40, $20, $10, $08, $04, $02, $01       ;; 01:501f ??.?.???

call_01_5027_Password_Encode:
; Spreads the payload's PASSWORD_TOTAL_BITS bits across the eighteen display cells,
; PASSWORD_BITS_PER_CELL each.
;
; Two mask walks in step: B slides $80 down to $01 over the payload bytes, C slides
; PASSWORD_CELL_MASK_START down to $01 over the cells. Because C cycles every five
; bits and B every eight, the two advance independently and the loop just runs ninety
; times.
;
; gex2's call_01_4fa5_Password_Encode does the same job through a 660-byte lookup
; table and only three bits per box; gex3's loop is smaller and its alphabet wider
    ld   HL, wDB7E_PasswordValues                     ;; 01:5027 $21 $7e $db
    ld   DE, wDB7E_PasswordValues+1                   ;; 01:502a $11 $7f $db
    ld   BC, PASSWORD_CELL_COUNT - 1                  ;; 01:502d $01 $11 $00
    ld   [HL], $00                                    ;; 01:5030 $36 $00
    call call_00_076e_MemCopy                         ;; 01:5032 $cd $6e $07
    ld   HL, wDB72_PasswordEncodedBuffer              ;; 01:5035 $21 $72 $db
    ld   B, $80                                       ;; 01:5038 $06 $80
    ld   DE, wDB7E_PasswordValues                     ;; 01:503a $11 $7e $db
    ld   C, PASSWORD_CELL_MASK_START                  ;; 01:503d $0e $10
    ld   A, PASSWORD_TOTAL_BITS                       ;; 01:503f $3e $5a
.jr_01_5041:
    push AF                                           ;; 01:5041 $f5
    ld   A, [HL]                                      ;; 01:5042 $7e
    and  A, B                                         ;; 01:5043 $a0
    jr   Z, .jr_01_5049                               ;; 01:5044 $28 $03
    ld   A, [DE]                                      ;; 01:5046 $1a
    or   A, C                                         ;; 01:5047 $b1
    ld   [DE], A                                      ;; 01:5048 $12
.jr_01_5049:
    rrc  C                                            ;; 01:5049 $cb $09
    jr   NC, .jr_01_5050                              ;; 01:504b $30 $03
    inc  DE                                           ;; 01:504d $13
    ld   C, PASSWORD_CELL_MASK_START                  ;; 01:504e $0e $10
.jr_01_5050:
    rrc  B                                            ;; 01:5050 $cb $08
    jr   NC, .jr_01_5055                              ;; 01:5052 $30 $01
    inc  HL                                           ;; 01:5054 $23
.jr_01_5055:
    pop  AF                                           ;; 01:5055 $f1
    dec  A                                            ;; 01:5056 $3d
    jr   NZ, .jr_01_5041                              ;; 01:5057 $20 $e8
    ret                                               ;; 01:5059 $c9

call_01_505a_Password_DecodeAndApply:
; Validates what the player typed and, if it checks out, applies it. Three stages.
;
; First, reject outright if any cell is still PASSWORD_KEY_BLANK. Then run the inverse
; of the encoder - the same two mask walks, gathering cell bits back into the payload.
; Then recompute the checksum and compare.
;
; On success it calls call_01_50b5_Password_ApplyPayload, so despite the old name this
; routine COMMITS: by the time it returns PASSWORD_VALID the save state has already
; been overwritten. gex2's call_01_5271_Password_DecodeAndApply is the same
    ld   HL, wDB7E_PasswordValues                     ;; 01:505a $21 $7e $db
    ld   B, PASSWORD_CELL_COUNT                       ;; 01:505d $06 $12
.jr_01_505f:
    ld   A, [HL+]                                     ;; 01:505f $2a
    cp   A, PASSWORD_KEY_BLANK                        ;; 01:5060 $fe $20
    jr   Z, .jr_01_50b2                               ;; 01:5062 $28 $4e
    dec  B                                            ;; 01:5064 $05
    jr   NZ, .jr_01_505f                              ;; 01:5065 $20 $f8
    ld   HL, wDB72_PasswordEncodedBuffer              ;; 01:5067 $21 $72 $db
    ld   DE, wDB73_PasswordLivesRemaining             ;; 01:506a $11 $73 $db
    ld   BC, PASSWORD_CHECKSUM_BYTES                  ;; 01:506d $01 $0b $00
    ld   [HL], $00                                    ;; 01:5070 $36 $00
    call call_00_076e_MemCopy                         ;; 01:5072 $cd $6e $07
    ld   HL, wDB72_PasswordEncodedBuffer              ;; 01:5075 $21 $72 $db
    ld   B, $80                                       ;; 01:5078 $06 $80
    ld   DE, wDB7E_PasswordValues                     ;; 01:507a $11 $7e $db
    ld   C, PASSWORD_CELL_MASK_START                  ;; 01:507d $0e $10
    ld   A, PASSWORD_TOTAL_BITS                       ;; 01:507f $3e $5a
.jr_01_5081:
    push AF                                           ;; 01:5081 $f5
    ld   A, [DE]                                      ;; 01:5082 $1a
    and  A, C                                         ;; 01:5083 $a1
    jr   Z, .jr_01_5089                               ;; 01:5084 $28 $03
    ld   A, [HL]                                      ;; 01:5086 $7e
    or   A, B                                         ;; 01:5087 $b0
    ld   [HL], A                                      ;; 01:5088 $77
.jr_01_5089:
    rrc  C                                            ;; 01:5089 $cb $09
    jr   NC, .jr_01_5090                              ;; 01:508b $30 $03
    inc  DE                                           ;; 01:508d $13
    ld   C, PASSWORD_CELL_MASK_START                  ;; 01:508e $0e $10
.jr_01_5090:
    rrc  B                                            ;; 01:5090 $cb $08
    jr   NC, .jr_01_5095                              ;; 01:5092 $30 $01
    inc  HL                                           ;; 01:5094 $23
.jr_01_5095:
    pop  AF                                           ;; 01:5095 $f1
    dec  A                                            ;; 01:5096 $3d
    jr   NZ, .jr_01_5081                              ;; 01:5097 $20 $e8
    ld   HL, wDB73_PasswordLivesRemaining             ;; 01:5099 $21 $73 $db
    ld   B, PASSWORD_CHECKSUM_BYTES                   ;; 01:509c $06 $0b
    xor  A, A                                         ;; 01:509e $af
.jr_01_509f:
    add  A, [HL]                                      ;; 01:509f $86
    inc  HL                                           ;; 01:50a0 $23
    dec  B                                            ;; 01:50a1 $05
    jr   NZ, .jr_01_509f                              ;; 01:50a2 $20 $fb
    xor  A, PASSWORD_CHECKSUM_XOR                     ;; 01:50a4 $ee $b6
    ld   HL, wDB72_PasswordEncodedBuffer              ;; 01:50a6 $21 $72 $db
    cp   A, [HL]                                      ;; 01:50a9 $be
    jr   NZ, .jr_01_50b2                              ;; 01:50aa $20 $06
    call call_01_50b5_Password_ApplyPayload           ;; 01:50ac $cd $b5 $50
    ld   A, PASSWORD_VALID                            ;; 01:50af $3e $20
    ret                                               ;; 01:50b1 $c9
.jr_01_50b2:
    ld   A, PASSWORD_INVALID                          ;; 01:50b2 $3e $00
    ret                                               ;; 01:50b4 $c9

call_01_50b5_Password_ApplyPayload:
; Expands the decoded payload back into wDC5C_ProgressFlags and the three header
; counters - the exact inverse of call_01_4f8c_Password_BuildPayload.
;
; Per level it walks that level's mask from data_01_511a_LevelProgressMasks and, for
; every set mask bit, pulls the next payload bit into the top of C; rotating C left
; once per iteration lands each recovered bit back in the position it was taken from.
; Bits the mask does not cover come back as zero
    xor  A, A                                         ;; 01:50b5 $af
    ld   [wDB90_PasswordCounter], A                   ;; 01:50b6 $ea $90 $db
    ld   DE, $00                                      ;; 01:50b9 $11 $00 $00
.jr_01_50bc:
    push DE                                           ;; 01:50bc $d5
    ld   HL, .data_01_511a_LevelProgressMasks         ;; 01:50bd $21 $1a $51
    add  HL, DE                                       ;; 01:50c0 $19
    ld   B, [HL]                                      ;; 01:50c1 $46
    ld   C, $00                                       ;; 01:50c2 $0e $00
    ld   A, $08                                       ;; 01:50c4 $3e $08
.jr_01_50c6:
    push AF                                           ;; 01:50c6 $f5
    bit  7, B                                         ;; 01:50c7 $cb $78
    jr   Z, .jr_01_50f3                               ;; 01:50c9 $28 $28
    ld   A, [wDB90_PasswordCounter]                   ;; 01:50cb $fa $90 $db
    srl  A                                            ;; 01:50ce $cb $3f
    srl  A                                            ;; 01:50d0 $cb $3f
    srl  A                                            ;; 01:50d2 $cb $3f
    ld   E, A                                         ;; 01:50d4 $5f
    ld   D, $00                                       ;; 01:50d5 $16 $00
    ld   HL, wDB76_PasswordEncodedBuffer              ;; 01:50d7 $21 $76 $db
    add  HL, DE                                       ;; 01:50da $19
    push HL                                           ;; 01:50db $e5
    ld   A, [wDB90_PasswordCounter]                   ;; 01:50dc $fa $90 $db
    and  A, $07                                       ;; 01:50df $e6 $07
    ld   E, A                                         ;; 01:50e1 $5f
    ld   D, $00                                       ;; 01:50e2 $16 $00
    ld   HL, .data_01_5126_BitMaskLut_80to01          ;; 01:50e4 $21 $26 $51
    add  HL, DE                                       ;; 01:50e7 $19
    ld   A, [HL]                                      ;; 01:50e8 $7e
    pop  HL                                           ;; 01:50e9 $e1
    and  A, [HL]                                      ;; 01:50ea $a6
    jr   Z, .jr_01_50ef                               ;; 01:50eb $28 $02
    set  7, C                                         ;; 01:50ed $cb $f9
.jr_01_50ef:
    ld   HL, wDB90_PasswordCounter                    ;; 01:50ef $21 $90 $db
    inc  [HL]                                         ;; 01:50f2 $34
.jr_01_50f3:
    rlc  C                                            ;; 01:50f3 $cb $01
    sla  B                                            ;; 01:50f5 $cb $20
    pop  AF                                           ;; 01:50f7 $f1
    dec  A                                            ;; 01:50f8 $3d
    jr   NZ, .jr_01_50c6                              ;; 01:50f9 $20 $cb
    pop  DE                                           ;; 01:50fb $d1
    ld   HL, wDC5C_ProgressFlags                      ;; 01:50fc $21 $5c $dc
    add  HL, DE                                       ;; 01:50ff $19
    ld   [HL], C                                      ;; 01:5100 $71
    inc  E                                            ;; 01:5101 $1c
    ld   A, E                                         ;; 01:5102 $7b
    cp   A, PROGRESS_FLAG_COUNT                       ;; 01:5103 $fe $0c
    jr   C, .jr_01_50bc                               ;; 01:5105 $38 $b5
    ld   A, [wDB73_PasswordLivesRemaining]            ;; 01:5107 $fa $73 $db
    ld   [wDC4E_LivesRemaining], A                    ;; 01:510a $ea $4e $dc
    ld   A, [wDB74_PasswordPawCoinCounter]            ;; 01:510d $fa $74 $db
    ld   [wDCAF_PawCoinCounter], A                    ;; 01:5110 $ea $af $dc
    ld   A, [wDB75_PasswordPawCoinExtraHealth]        ;; 01:5113 $fa $75 $db
    ld   [wDC4F_PawCoinExtraHealth], A                ;; 01:5116 $ea $4f $dc
    ret                                               ;; 01:5119 $c9
.data_01_511a_LevelProgressMasks:
; Description:
; A static table of bit masks used by call_01_50b5 to control which password checks 
; to perform for each column. Likely a column mask pattern for map rows.
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01       ;; 01:511a ????????
    db   $01, $01, $01, $01                           ;; 01:5122 ????
.data_01_5126_BitMaskLut_80to01:
; Description:
; A standard bitmask lookup table for individual bits ($80, $40, $20 … $01). 
; Used for testing individual tile bits in wDB76_PasswordEncodedBuffer.
    db   $80, $40, $20, $10, $08, $04, $02, $01       ;; 01:5126 ????????

data_01_512e_MenuCmd_Descriptors:
; The shape of every menu command opcode: MENUCMD_DESCRIPTOR_SIZE bytes per id, of
; which call_01_446b_MenuScript_RunCommand copies MENUCMD_DESCRIPTOR_COPY_BYTES into
; wDB9E onwards. The trailing two bytes are $00 in all 83 records.
;
;   +0  width in tiles       +1  height in tiles
;   +2  destination tile X   +3  destination tile Y
;   +4  first tile id        +5  attribute byte, or MENUCMD_ATTR_TILESET_ROW
;
; So an opcode is a rectangle on the screen, and the parameter block that follows it
; says what to put there. Opcode $00 doubles as the "shape does not matter" id for
; commands that only call a sub-handler.
;
; Ids $00-$11 are the eighteen password cells - 2x2 tiles at six X positions across
; three rows, first tiles stepping by PASSWORD_CELL_TILES from
; PASSWORD_CELL_TILE_BASE, which is what call_01_4de3_Password_GetCellTileIndex
; recomputes. Ids $12 and $13 are the two PASSWORD_KEY_COLUMNS-wide keyboard rows.
;
; gex2's data_01_5324_MenuCmd_Descriptors, same layout
    db   $02, $02, $01, $04, $98, $07, $00, $00       ;; 01:512e ..ww..??
    db   $02, $02, $04, $04, $9c, $07, $00, $00       ;; 01:5136 ..ww..??
    db   $02, $02, $07, $04, $a0, $07, $00, $00       ;; 01:513e ..ww..??
    db   $02, $02, $0a, $04, $a4, $07, $00, $00       ;; 01:5146 ..ww..??
    db   $02, $02, $0d, $04, $a8, $07, $00, $00       ;; 01:514e ..ww..??
    db   $02, $02, $10, $04, $ac, $07, $00, $00       ;; 01:5156 ..ww..??
    db   $02, $02, $01, $07, $b0, $07, $00, $00       ;; 01:515e ..ww..??
    db   $02, $02, $04, $07, $b4, $07, $00, $00       ;; 01:5166 ..ww..??
    db   $02, $02, $07, $07, $b8, $07, $00, $00       ;; 01:516e ..ww..??
    db   $02, $02, $0a, $07, $bc, $07, $00, $00       ;; 01:5176 ..ww..??
    db   $02, $02, $0d, $07, $c0, $07, $00, $00       ;; 01:517e ..ww..??
    db   $02, $02, $10, $07, $c4, $07, $00, $00       ;; 01:5186 ..ww..??
    db   $02, $02, $01, $0a, $c8, $07, $00, $00       ;; 01:518e ..ww..??
    db   $02, $02, $04, $0a, $cc, $07, $00, $00       ;; 01:5196 ..ww..??
    db   $02, $02, $07, $0a, $d0, $07, $00, $00       ;; 01:519e ..ww..??
    db   $02, $02, $0a, $0a, $d4, $07, $00, $00       ;; 01:51a6 ..ww..??
    db   $02, $02, $0d, $0a, $d8, $07, $00, $00       ;; 01:51ae ..ww..??
    db   $02, $02, $10, $0a, $dc, $07, $00, $00       ;; 01:51b6 ..ww..??
    db   $10, $01, $01, $01, $e0, $07, $00, $00       ;; 01:51be w.www.??
    db   $10, $01, $01, $02, $f0, $07, $00, $00       ;; 01:51c6 w.www.??
    db   $08, $01, $06, $0b, $d0, $00, $00, $00       ;; 01:51ce w...w.??
    db   $08, $01, $06, $0d, $d8, $00, $00, $00       ;; 01:51d6 w...w.??
    db   $08, $06, $01, $00, $01, $ff, $00, $00       ;; 01:51de ..ww..??
    db   $0b, $02, $09, $01, $31, $01, $00, $00       ;; 01:51e6 w.www.??
    db   $0b, $02, $09, $04, $47, $02, $00, $00       ;; 01:51ee w.www.??
    db   $10, $02, $04, $07, $5d, $02, $00, $00       ;; 01:51f6 w.www.??
    db   $10, $02, $04, $0a, $7d, $02, $00, $00       ;; 01:51fe w.www.??
    db   $10, $02, $04, $0d, $9d, $02, $00, $00       ;; 01:5206 w.www.??
    db   $12, $02, $01, $10, $bd, $02, $00, $00       ;; 01:520e w.www.??
    db   $0b, $03, $09, $04, $47, $02, $00, $00       ;; 01:5216 ????????
    db   $0c, $02, $04, $01, $01, $01, $00, $00       ;; 01:521e w.www.??
    db   $0c, $02, $04, $03, $19, $02, $00, $00       ;; 01:5226 w.www.??
    db   $14, $01, $00, $0f, $31, $02, $00, $00       ;; 01:522e w.www.??
    db   $14, $02, $00, $10, $45, $02, $00, $00       ;; 01:5236 w.www.??
    db   $01, $01, $0b, $06, $6d, $02, $00, $00       ;; 01:523e w.www.??
    db   $01, $02, $0c, $06, $6e, $02, $00, $00       ;; 01:5246 w.www.??
    db   $01, $01, $0d, $07, $70, $02, $00, $00       ;; 01:524e w.www.??
    db   $01, $01, $0b, $09, $71, $02, $00, $00       ;; 01:5256 w.www.??
    db   $01, $02, $0c, $09, $72, $02, $00, $00       ;; 01:525e w.www.??
    db   $01, $01, $0d, $0a, $74, $02, $00, $00       ;; 01:5266 w.www.??
    db   $01, $01, $0b, $0c, $75, $02, $00, $00       ;; 01:526e w.www.??
    db   $01, $02, $0c, $0c, $76, $02, $00, $00       ;; 01:5276 w.www.??
    db   $01, $01, $0d, $0d, $78, $02, $00, $00       ;; 01:527e w.www.??
    db   $02, $02, $07, $06, $f8, $04, $00, $00       ;; 01:5286 ..www.??
    db   $02, $02, $07, $09, $f4, $07, $00, $00       ;; 01:528e ..www.??
    db   $02, $02, $07, $0c, $ec, $05, $00, $00       ;; 01:5296 ..www.??
    db   $10, $02, $02, $00, $01, $01, $00, $00       ;; 01:529e ????????
    db   $12, $02, $01, $05, $21, $02, $00, $00       ;; 01:52a6 w.www.??
    db   $14, $02, $00, $10, $45, $02, $00, $00       ;; 01:52ae ????????
    db   $02, $01, $07, $0a, $6d, $02, $00, $00       ;; 01:52b6 ????????
    db   $02, $02, $09, $0a, $6f, $02, $00, $00       ;; 01:52be ????????
    db   $02, $01, $0b, $0b, $73, $02, $00, $00       ;; 01:52c6 ????????
    db   $02, $02, $04, $0e, $75, $02, $00, $00       ;; 01:52ce ????????
    db   $02, $02, $0e, $0e, $79, $02, $00, $00       ;; 01:52d6 ????????
    db   $02, $02, $09, $08, $f0, $06, $00, $00       ;; 01:52de ????????
    db   $02, $02, $04, $0c, $ec, $05, $00, $00       ;; 01:52e6 ????????
    db   $02, $02, $0e, $0c, $f4, $07, $00, $00       ;; 01:52ee ????????
    db   $02, $02, $03, $03, $7d, $03, $00, $00       ;; 01:52f6 ????????
    db   $02, $02, $07, $03, $81, $03, $00, $00       ;; 01:52fe ????????
    db   $02, $02, $0b, $03, $85, $03, $00, $00       ;; 01:5306 ????????
    db   $02, $02, $0f, $03, $89, $03, $00, $00       ;; 01:530e ????????
    db   $0e, $02, $03, $04                           ;; 01:5316 w.ww
    db   %00000001                                    ;; 01:531a $01

    db   $01, $00, $00, $0e, $02, $03, $06, $1d       ;; 01:531b .??w.www
    db   $01, $00, $00, $0e, $02, $03, $08, $39       ;; 01:5323 .??w.www
    db   $01, $00, $00, $0e, $02, $03, $0a            ;; 01:532b .??w.ww
    db   %01010101                                    ;; 01:5332 $55

    db   $01, $00, $00, $02, $02, $03, $10, $71       ;; 01:5333 .??w.www
    db   $02, $00, $00, $02, $02, $07, $10, $75       ;; 01:533b .??w.www
    db   $02, $00, $00, $02, $02, $0b, $10, $79       ;; 01:5343 .??w.www
    db   $02, $00, $00, $02, $02, $0f, $10, $7d       ;; 01:534b .??w.www
    db   $02, $00, $00, $02, $02, $03, $01            ;; 01:5353 .??w.ww
    db   %10000001                                    ;; 01:535a $81

    db   $02, $00, $00, $02, $02, $03, $0e            ;; 01:535b .??..ww
    db   %11110000                                    ;; 01:5362 $f0

    db   $06, $00, $00, $02, $02, $07, $0e            ;; 01:5363 .??..ww
    db   %11110100                                    ;; 01:536a $f4

    db   $07, $00, $00, $02, $02, $0b, $0e            ;; 01:536b .??..ww
    db   %11101100                                    ;; 01:5372 $ec

    db   $05, $00, $00, $02, $02, $0f, $0e            ;; 01:5373 .??..ww
    db   %11111000                                    ;; 01:537a $f8

    db   $04, $00, $00, $02, $01, $01, $01            ;; 01:537b .??..ww
    db   %10000101                                    ;; 01:5382 $85

    db   $03, $00, $00, $02, $01, $01, $02            ;; 01:5383 .??..ww
    db   %10000111                                    ;; 01:538a $87

    db   $00, $00, $00, $14, $03, $00, $08, $01       ;; 01:538b .??w.www
    db   $01, $00, $00, $0a, $02, $0a, $02, $80       ;; 01:5393 .???????
    db   $03, $00, $00, $0a, $02, $0a, $05, $94       ;; 01:539b ????????
    db   $03, $00, $00, $0a, $02, $0a, $08, $a8       ;; 01:53a3 ????????
    db   $03, $00, $00, $0a, $02, $0a, $0b, $bc       ;; 01:53ab ????????
    db   $03, $00, $00, $0a, $02, $0a, $0e, $d0       ;; 01:53b3 ????????
    db   $03, $00, $00, $10, $10, $02, $01, $01       ;; 01:53bb ???w.www
    db   $02, $00, $00                                ;; 01:53c3 .??

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
    
    dw   data_01_5a3e_MenuScript_C                              ; menu id $1c - no MENU_* constant
    db   $04, $00, $20, $54, $00, $10, $d3, $08       ;; 01:5588 ????????
    db   $00, $00, $00, $00, $00, $00                 ;; 01:5590 ??????

data_01_5596_ChainedScriptTable:
; The two scripts a command can queue up behind the current one through
; call_01_47aa_MenuCmd_SetChainedScript: the password grid and the totals sub-screen.
; gex2's data_01_568c_ChainedScriptTable
    dw   data_01_5a47_MenuScript_PasswordGrid                                 ;; 01:5596 pP
    dw   data_01_5ad8_MenuScript_TotalsStats                                 ;; 01:5598 pP

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

data_01_5a3e_MenuScript_C:
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

data_01_5b61_SpriteScriptTable:
; Four sprite scripts. A script is a starting OAM slot, then six-byte records - Y, X,
; tile, attributes, width, height - terminated by SPRITE_RECORD_END;
; call_01_4c45_Menu_BuildSpriteBlock draws them and
; call_01_4b6b_Menu_TickHideSprites erases them again.
;
; The first three entries point at wDBBF_MenuCursor_OamSlot - the cursor record built
; in WRAM at runtime by call_01_46d4_MenuCmd_DrawCursorSprite - rather than at ROM.
; Only the last is a static script. gex2 keeps its equivalents in
; bank01_sprite_scripts.asm
    db   $bf, $db, $bf, $db, $bf, $db, $69, $5b       ;; 01:5b61 ??????..
    db   $04, $58, $34, $d0, $04, $08, $01, $68       ;; 01:5b69 w.......
    db   $34, $d8, $05, $08, $01, $ff                 ;; 01:5b71 ......

data_01_5b77_FontDescriptors:
; Four fonts, eight bytes each, of which call_01_4875_Text_Render copies six:
;
;   +0  dw  the glyph bitmaps          +2  dw  per-glyph pixel widths
;   +4      glyph width in TILES       +5      glyph height in pixels
;
; A glyph's stride is computed rather than stored - height times two bytes per row
; times width in tiles - so the bitmap blob has no header and glyph 0 starts at byte
; zero. The width tables are TEXT_GLYPH_COUNT entries, matching the largest index
; .data_01_4dfd_CharToGlyph can produce.
;
; Fonts 0 and 1 are the proportional text faces, 7 and 8 pixels tall. Fonts 2 and 3
; are the password alphabet, small and large; font 3 is the 2x2-tile
; data_01_66f9_PasswordFont that the grid is drawn from.
;
; gex2's data_01_65fe_FontDescriptors
    dw   .data_01_5c79, .data_01_5b97
    db   $01, $07, $00, $00
    
    dw   .data_01_6069, .data_01_5bde
    db   $01, $08, $00, $00

    dw   .data_01_64e9, .data_01_5c25
    db   $01, $08, $00, $00

    dw   data_01_66f9_PasswordFont, .data_01_5c4f
    db   $02, $10, $00, $00
.data_01_5b97:
    INCBIN "gfx/text/image_001_5c79_data.bin"
.data_01_5bde:
    INCBIN "gfx/text/image_001_6069_data.bin"
.data_01_5c25:
    INCBIN "gfx/text/image_001_64e9_data.bin"
.data_01_5c4f:
    INCBIN "gfx/text/image_001_66f9_data.bin"
.data_01_5c79:
    INCBIN ".gfx/text/image_001_5c79.bin"
.data_01_6069:
    INCBIN ".gfx/text/image_001_6069.bin"
.data_01_64e9:
    INCBIN ".gfx/text/image_001_64e9.bin"
data_01_66f9_PasswordFont:
; The large password alphabet: 33 glyphs of PASSWORD_GLYPH_BYTES, one blank plus the
; 32 keys. Read two ways - as font 3 of data_01_5b77_FontDescriptors, and directly by
; call_01_477c_MenuCmd_StagePasswordGlyph and
; call_01_4d6e_Password_RefreshCellGfx, which index it by the raw key value
    INCBIN ".gfx/text/image_001_66f9.bin"

data_01_6f39_ImageTable:
; Six small images for call_01_4d03_Menu_StageTileData, each a three-byte header -
; width, height, mode - followed by tile data. Entry 2 is a duplicate of entry 0, and
; entry 1 is header-only with a non-zero mode, which reserves its block without
; copying anything into it
    dw   .data_01_6f45, .data_01_6f88, .data_01_6f45
    dw   .data_01_6f8b, .data_01_6fce, .data_01_7051
.data_01_6f45:
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6f48.bin"
.data_01_6f88:
    db   $02, $02, $ff
.data_01_6f8b:
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6f8e.bin"
.data_01_6fce:
    db   $04, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6fd1.bin"
.data_01_7051:
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites_horizontal/image_001_7054.bin"
