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
; ASCII code -> glyph index, one entry for all 256 codes, read by
; call_01_4df4_Text_CharToGlyphIndex. Glyph $00 is the blank, so every unmapped code
; renders as a space - including a real space ($20), which is why the wrapper has to
; test for TEXT_SPACE itself rather than looking at the glyph.
;
; Reading the mapped entries back gives the font's own layout:
;
;   $00      blank
;   $01-$1a  the alphabet - reached from LOWER case ASCII
;   $1b-$24  digits 0-9
;   $25-$38  accented vowels, five per diacritic - reached from UPPER case A-T
;   $39-$3a  ? !
;   $3b-$3d  inverted !, sharp s, n-with-tilde - from U V W
;   $3e-$44  . , - / ( ) '
;   $45-$46  trade mark and copyright signs - from X Y
;
; THE FONT HAS NO CAPITALS. Its $01-$1a glyphs are drawn as capital letters and lower
; case ASCII is what selects them, which leaves the whole upper case range free for
; the accented characters the French, German, Spanish and Italian text needs.
; code/menus/bank1c_text.asm has the full character-by-character mapping and explains why
; a string there reads "paVwort".
;
; Z is the one letter with no entry: $5a maps to $00 like an unmapped code, because no
; accented character was assigned to it. That costs nothing - lower case z is glyph
; $1a and is what every string uses.
;
; TEXT_GLYPH_COUNT is $47, one past the last mapped glyph.
;
; gex2's .data_01_4f4c_CharToGlyph is a shorter table biased by $20 - gex2 is English
; only, so its upper case range really is upper case
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; $00-$07 control codes
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; $08-$0f
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; $10-$17
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; $18-$1f
    db   $00, $3a, $00, $00, $00, $00, $00, $44       ; $20 space and ! and ' are the only mapped ones here
    db   $42, $43, $00, $00, $3f, $40, $3e, $41       ; $28 ( ) * + , - . /
    db   $1b, $1c, $1d, $1e, $1f, $20, $21, $22       ; $30 digits 0-7
    db   $23, $24, $00, $00, $00, $00, $00, $39       ; $38 8 9 : ; < = > ?
    db   $00, $25, $26, $27, $28, $29, $2a, $2b       ; $40 @, then A-G
    db   $2c, $2d, $2e, $2f, $30, $31, $32, $33       ; $48 H-O
    db   $34, $35, $36, $37, $38, $3b, $3c, $3d       ; $50 P-T end the accents; U V W are inverted-!, sharp-s, n-tilde
    db   $45, $46, $00, $00, $00, $00, $00, $00       ; $58 X Y are (tm) and (c); Z has NO glyph; then [ to _
    db   $00, $01, $02, $03, $04, $05, $06, $07       ; $60 `, then a-g
    db   $08, $09, $0a, $0b, $0c, $0d, $0e, $0f       ; $68 h-o
    db   $10, $11, $12, $13, $14, $15, $16, $17       ; $70 p-w
    db   $18, $19, $1a, $00, $00, $00, $00, $00       ; $78 x y z, then { | } ~ DEL
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; $80-$ff are never used as text -
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; TEXT_TERMINATOR is $80, so a
    db   $00, $00, $00, $00, $00, $00, $00, $00       ; string ends before it can index
    db   $00, $00                                     ; this half of the table
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00

call_01_4efd:
; a small "index into the table below" routine - and then a 33-entry table
; mapping key index to ASCII, blank plus 'A'-'Z' plus '0'-'5', which is the
; PASSWORD_KEY_COLUMNS * PASSWORD_KEY_ROWS keyboard's alphabet. Nothing in the
; disassembly reaches this.
;
; Note that this LABEL is not what the two `ld HL, MENUTEXT_COUNTER_STRINGS`
; operands mean. They also hold $4E97, but they are dereferenced with BANK_1C_TEXT
; paged in - the collision is a coincidence of layout
    ld   e,a
    ld   d,$00
    ld   hl,.data_01_4f06_KeyToAscii
    add  hl,de
    ld   a,[hl]
    ret  
.data_01_4f06_KeyToAscii:
; Password value -> an ASCII character, 33 entries: PASSWORD_KEY_BLANK, then the 26
; letters, then the six digits 0-5. 33 is the same count as
; data_01_66f9_PasswordFont has glyphs, and $00-$1F is the range a
; PASSWORD_BITS_PER_CELL-bit cell can hold - but see below, the contents do not
; match the font.
;
; NOTHING CALLS call_01_4efd, so this table is dead in this build: the grid is drawn
; from the font directly by call_01_477c_MenuCmd_StagePasswordGlyph and never goes via
; ASCII.
;
; It also does not agree with the font. data_01_66f9_PasswordFont holds 21 CONSONANTS
; then the digits then ! and ?, with no blank and no vowels, so cell value $00 draws a
; B where this table calls it a space and $01 draws a C where this table says A. One
; of the two is left over from an earlier encoding; the font is the one the drawing
; code actually reads, so the font is the one to trust
    db   PASSWORD_KEY_BLANK                           ; key $00 - an empty cell
    db   $41, $42, $43, $44, $45, $46, $47, $48       ; A-H
    db   $49, $4a, $4b, $4c, $4d, $4e, $4f, $50       ; I-P
    db   $51, $52, $53, $54, $55, $56, $57, $58       ; Q-X
    db   $59, $5a, $30, $31, $32, $33, $34, $35       ; Y Z, then digits 0-5

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
; The same for the tile-id plane and HDMACFG_MENU_TILEMAP. Called immediately after
; the attribute upload, so the two planes reach VRAM one after the other
    ld   DE, wD400_ScreenDraw_TileIds                 ;; 01:4f5c $11 $00 $d4
    call call_01_4f67_Menu_StageScreenPlane           ;; 01:4f5f $cd $67 $4f
    ld   C, HDMACFG_MENU_TILEMAP                    ;; 01:4f62 $0e $08
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
; Which bits of each level's wDC5C_ProgressFlags byte are worth saving in a password.
; One mask per entry, PROGRESS_FLAG_COUNT entries, walked MSB first alongside the
; progress byte itself.
;
; A progress byte is three fields: bits 0-3 are the level's OBJECTIVES_PER_LEVEL
; objectives (the three mission remotes and PROGRESS_ALL_COLLECTIBLES_BIT), bit
; PROGRESS_BONUS_COIN_TAKEN_BIT is the bonus coin, and bits 5-7 are the remotes
; call_01_4b0a_CountHighBitsForLevel counts. The masks say which of those a given
; level actually has:
;
;   $f1  Gex's Cave - one objective, so bits 1-3 are dropped
;   $ff  the six main TV levels - everything
;   $01  the bonus and boss levels - a single remote each
;
; Add the set bits up and there are 58 of them. The password payload is
; PASSWORD_TOTAL_BITS bits, of which the first four bytes are the header, and
; 90 - 32 = 58. The masks are sized to the password, not the other way round: there is
; no spare room, which is why a level cannot gain a saved flag without one being taken
; from somewhere else
;
; call_01_50b5_Password_ApplyProgress has its own byte-for-byte copy at
; .data_01_511a_LevelProgressMasks; the two are never compared, so a change here must
; be made there too or saving and loading will disagree
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01       ; levels $00-$07
    db   $01, $01, $01, $01                           ; levels $08-$0b
.data_01_501f_BitMaskLut_80to01:
; Bit number (0-7, MSB first) -> its mask. Used to set one bit of the encoded buffer
; at a time: the running bit counter's low three bits index this and the rest of it
; picks the byte
    db   $80, $40, $20, $10, $08, $04, $02, $01

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
; Which bits of each level's wDC5C_ProgressFlags byte are worth saving in a password.
; One mask per entry, PROGRESS_FLAG_COUNT entries, walked MSB first alongside the
; progress byte itself.
;
; A progress byte is three fields: bits 0-3 are the level's OBJECTIVES_PER_LEVEL
; objectives (the three mission remotes and PROGRESS_ALL_COLLECTIBLES_BIT), bit
; PROGRESS_BONUS_COIN_TAKEN_BIT is the bonus coin, and bits 5-7 are the remotes
; call_01_4b0a_CountHighBitsForLevel counts. The masks say which of those a given
; level actually has:
;
;   $f1  Gex's Cave - one objective, so bits 1-3 are dropped
;   $ff  the six main TV levels - everything
;   $01  the bonus and boss levels - a single remote each
;
; Add the set bits up and there are 58 of them. The password payload is
; PASSWORD_TOTAL_BITS bits, of which the first four bytes are the header, and
; 90 - 32 = 58. The masks are sized to the password, not the other way round: there is
; no spare room, which is why a level cannot gain a saved flag without one being taken
; from somewhere else
;
; The decoding half of the pair - identical bytes to
; .data_01_5013_LevelProgressMasks above, duplicated in ROM rather than shared
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01       ; levels $00-$07
    db   $01, $01, $01, $01                           ; levels $08-$0b
.data_01_5126_BitMaskLut_80to01:
; Bit number (0-7, MSB first) -> its mask. Used to set one bit of the encoded buffer
; at a time: the running bit counter's low three bits index this and the rest of it
; picks the byte
; here, to read one bit of the decoded buffer back out. Also a duplicate of
; .data_01_501f_BitMaskLut_80to01
    db   $80, $40, $20, $10, $08, $04, $02, $01
