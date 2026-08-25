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
