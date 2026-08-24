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

data_01_5b61_SpriteScriptTable:
; Four sprite groups a script can draw through MENUCMD_SUB_DRAW_SPRITE_GROUP.
;
; A group is one byte - the OAM slot to start writing at - then six-byte records, and
; SPRITE_RECORD_END ends both the header and the record list:
;
;   Y, X            screen position; call_01_4c45_Menu_BuildSpriteBlock adds
;                   OAM_Y_BIAS and OAM_X_BIAS on the way into OAM
;   tile            a tile id, unless bit 0 is set - then the rest of the byte is an
;                   index into wDAE1_TextBuffer and the tile is looked up at draw
;                   time, which is how one static group can show a changing number
;   attributes      the OAM attribute byte
;   width, height   in 8x8 sprites; call_01_4c7e_Menu_WriteSpriteRect emits the
;                   rectangle column by column
;
; The first three entries are not ROM addresses at all - they point at
; wDBBF_MenuCursor_OamSlot, the cursor record built in WRAM by
; call_01_46d4_MenuCmd_DrawCursorSprite. Only entry 3 is a static group, and only one
; command in the whole game draws it: the title screen's.
;
; call_01_4b6b_Menu_TickHideSprites can erase a group again after a delay, and gex2
; uses that for its "press B to continue" prompts. In gex3 it is DEAD CODE: the only
; MENUCMD_SUB_DRAW_SPRITE_GROUP command passes 0 as its delay, and nothing else ever
; writes wDBDE_Menu_HideSpritesDelay with a non-zero value, so the countdown is never
; armed. Worth knowing before trusting that routine - its erase loop halves the height
; where the draw does not, so on a one-row group it would run 256 times, not zero
;
; gex2 keeps its equivalents in bank01_sprite_scripts.asm
    dw   wDBBF_MenuCursor_OamSlot                     ; 0 - the live cursor, in WRAM
    dw   wDBBF_MenuCursor_OamSlot                     ; 1 - the live cursor, in WRAM
    dw   wDBBF_MenuCursor_OamSlot                     ; 2 - the live cursor, in WRAM
    dw   .data_01_5b69_TitleScreenBanner              ; 3
.data_01_5b69_TitleScreenBanner:
; Two 8x1 rows of sprites under the title logo, at OAM slot 4
    db   $04                                      ; first OAM slot
    sprite_rect $58, $34, $d0, $04,  8,  1
    sprite_rect $68, $34, $d8, $05,  8,  1
    db   SPRITE_RECORD_END

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
