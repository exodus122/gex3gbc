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
    ld   DE, .data_01_4b53_MapTextBlocks              ;; 01:4b4a $11 $53 $4b
    add  HL, DE                                       ;; 01:4b4d $19
    ld   E, [HL]                                      ;; 01:4b4e $5e
    inc  HL                                           ;; 01:4b4f $23
    ld   H, [HL]                                      ;; 01:4b50 $66
    ld   L, E                                         ;; 01:4b51 $6b
    ret                                               ;; 01:4b52 $c9
.data_01_4b53_MapTextBlocks:
; One text block per level, PROGRESS_FLAG_COUNT entries, indexed by
; wDB6C_CurrentMapId - which on a menu screen holds the LEVEL id, not a map id, because
; call_01_4000_MenuLoad swaps it before drawing and puts the real map back afterwards.
;
; A block starts with two ten-byte records - the level name, then the TV's name - and
; the rest is an array of ten-byte mission descriptions. The three accessors above are
; just +0, +$0A and +$14 into it.
;
; THESE ARE BANK $1C ADDRESSES, stored as bare words - the dereference happens with
; BANK_1C_TEXT paged in, so the disassembler read them as bank 1 and any label it
; invented for them was wrong. They now name the real blocks in
; data/bank_01c_text.asm, which is also where the block layout is documented
    dw   MapText_GexCave                          ; LEVEL_GEX_CAVE
    dw   MapText_HolidayTv                        ; LEVEL_HOLIDAY_TV
    dw   MapText_MysteryTv                        ; LEVEL_MYSTERY_TV
    dw   MapText_TutTv                            ; LEVEL_TUT_TV
    dw   MapText_WesternStation                   ; LEVEL_WESTERN_STATION
    dw   MapText_AnimeChannel                     ; LEVEL_ANIME_CHANNEL
    dw   MapText_SuperheroShow                    ; LEVEL_SUPERHERO_SHOW
    dw   MapText_GextremeSports                   ; LEVEL_GEXTREME_SPORTS
    dw   MapText_MarsupialMadness                 ; LEVEL_MARSUPIAL_MADNESS
    dw   MapText_WwGexWrestling                   ; LEVEL_WW_GEX_WRESTLING
    dw   MapText_LizardOfOz                       ; LEVEL_LIZARD_OF_OZ
    dw   MapText_ChannelZ                         ; LEVEL_CHANNEL_Z

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
