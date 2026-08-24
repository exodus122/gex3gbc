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
