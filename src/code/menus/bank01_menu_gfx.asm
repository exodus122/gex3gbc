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
