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
; The four width tables. Fonts 0 and 1 carry a full TEXT_GLYPH_COUNT entries, so every
; index .data_01_4dfd_CharToGlyph can produce is covered. Fonts 2 and 3 carry only 42,
; which is more than their 33 glyphs but less than TEXT_GLYPH_COUNT - they are only
; ever asked for password characters, so the gap never comes up
.data_01_5b97: ; font 0 widths - $47 entries
    INCBIN "gfx/text/image_001_5c79_data.bin"
.data_01_5bde: ; font 1 widths - $47 entries
    INCBIN "gfx/text/image_001_6069_data.bin"
.data_01_5c25: ; font 2 widths - $2a entries
    INCBIN "gfx/text/image_001_64e9_data.bin"
.data_01_5c4f: ; font 3 widths - $2a entries, all $10 (it is fixed pitch)
    INCBIN "gfx/text/image_001_66f9_data.bin"

; The glyph bitmaps. A glyph's stride is width in tiles * height in pixels * 2 bytes
; per row, computed rather than stored, so these blobs have no header and glyph 0
; starts at byte zero. Their sizes are not multiples of TILE_SIZE_BYTES, which is why
; rgbgfx cannot round-trip them and they are checked in as raw .bin
.data_01_5c79: ; font 0 - 8x7, stride $0e, $3f0 bytes = 72 glyphs
    INCBIN ".gfx/text/image_001_5c79.bin"
.data_01_6069: ; font 1 - 8x8, stride $10, $480 bytes = 72 glyphs
    INCBIN ".gfx/text/image_001_6069.bin"
.data_01_64e9: ; font 2 - 8x8, stride $10, $210 bytes = 33 glyphs, the small password set
    INCBIN ".gfx/text/image_001_64e9.bin"
data_01_66f9_PasswordFont:
; The large password alphabet: 33 glyphs of PASSWORD_GLYPH_BYTES, one blank plus the
; 32 keys. Read two ways - as font 3 of data_01_5b77_FontDescriptors, and directly by
; call_01_477c_MenuCmd_StagePasswordGlyph and
; call_01_4d6e_Password_RefreshCellGfx, which index it by the raw key value
    INCBIN ".gfx/text/image_001_66f9.bin"

data_01_6f39_ImageTable:
; Six small images for call_01_4d03_Menu_StageTileData, each a three-byte header -
; width in tiles, height in tiles, mode - followed by that many tiles of data. Mode
; $00 copies; anything else returns having only reserved the block.
;
; Ids $00-$02 are what MENUCMD_SUB_DRAW_CURSOR passes, so they are the three cursor
; images, and the arrangement is deliberate: $00 and $02 are the SAME address, and $01
; is header-only. $01 belongs to the password screens, where MENU_CURSOR_PASSWORD
; draws whatever character is under the cursor instead of a fixed tile - so there is
; nothing to copy, and the entry exists only to reserve the tiles.
;
; Ids $03-$05 are passed to MENUCMD_SUB_STAGE_IMAGE1 / _IMAGE2 as ordinary pictures.
;
; gex2 splits this into data_01_74e9_ImageTable1 and data_01_74ed_ImageTable2, two
; overlapping windows onto one list
    dw   .data_01_6f45, .data_01_6f88, .data_01_6f45  ; $00-$02 cursors
    dw   .data_01_6f8b, .data_01_6fce, .data_01_7051  ; $03-$05 pictures
.data_01_6f45: ; $00 and $02 - 2x2 tiles of cursor
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6f48.bin"
.data_01_6f88: ; $01 - 2x2 tiles reserved, nothing copied. The password cursor
    db   $02, $02, $ff
.data_01_6f8b: ; $03 - 2x2 tiles
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6f8e.bin"
.data_01_6fce: ; $04 - 4x2 tiles, the widest of the six
    db   $04, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6fd1.bin"
.data_01_7051: ; $05 - 2x2 tiles, stored row-major rather than column-major
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites_horizontal/image_001_7054.bin"
