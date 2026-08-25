; ==================================================================
; Bank $7F. The index to Gex's own graphics.
;
; Banks $62-$7E hold Gex's frames: the tile data, and the piece lists that say how to
; assemble each one out of 8x16 OBJs. This bank holds no graphics at all. It is the
; three tables that turn "which map am I on, and which frame do I want" into a bank
; and an address in those banks, plus the OBJ palettes each map draws him in.
;
; Nothing here is code. Three routines read it, and between them they touch every byte:
;
;   call_00_2ce2_Player_BuildSprites             once a frame, to place his OBJs
;   call_00_0513_Screen_PresentAndDrawEntities   once a map load, to queue his tiles
;   call_00_2cbf_Entity_LoadMapPalettes          for the colours - and far more often
;                                                than a map load, see below
;
; All three page this bank in, walk the tables with the current map id, and page it
; back out; only the first two go on to page in a graphics bank and read a frame.
;
; The third is worth a second look. call_03_6567_FlyPowerup_LoadPalette runs on every
; player update and tail-jumps to it whenever Gex is carrying no fly - which is most of
; the time - so the map-id lookup and the sixteen-byte copy below happen once a FRAME,
; not once a map. Nothing caches the result.
;
; The layout
; ----------
;   $4000  data_7f_4000_PlayerGfx_SetByMap   one byte per map, 61 of them
;   $403d  data_7f_403d_PlayerGfx_SetTable   9 records of PLAYER_GFX_SET_SIZE bytes
;   $406a  9 frame directories               PLAYER_FRAME_ENTRY_SIZE bytes per frame
;   $53f9  9 OBJ palette blocks              OBJ_PALETTE_BYTES each
;   $5639  end of the data - the rest of the bank is zero filler
;
; Between them the frame directories name every bank from $62 to $7e, with no gaps
;
; Graphics sets
; -------------
; Gex is re-drawn per level theme, and a THEME - a base bank, a frame directory and a
; pair of OBJ palettes - is what this file calls a graphics set. There are
; PLAYER_GFX_SET_COUNT of them and 61 maps, so the first table is the many-to-one
; lookup: every map of a level shares a set, and sometimes several levels do.
;
; The byte it stores is a BYTE OFFSET, not a set number. All three readers do
;
;     ld   HL, data_7f_4000_PlayerGfx_SetByMap
;     add  HL, DE                     ; DE = wDB6C_CurrentMapId
;     ld   E, [HL]                    ; -> DE, unscaled
;     ld   HL, data_7f_403d_PlayerGfx_SetTable
;     add  HL, DE
;
; with no shift or multiply between the two lookups, so every value in the first table
; is a multiple of PLAYER_GFX_SET_SIZE. The map_gfx_set macro does that multiply at
; assembly time, which is why the rows below read as set names.
;
; That is also the whole reason there are two labels three bytes apart.
; call_00_2cbf_Entity_LoadMapPalettes wants the palette pointer, which lives at +3 of a
; record, and it gets there by adding the same unscaled offset to a base three bytes
; further along. data_7f_4040_PlayerGfx_SetPalettes is not a second table - it is the
; palette field of record 0, used as the base of a strided read over the one table.
;
; A frame directory
; -----------------
; PLAYER_FRAME_ENTRY_SIZE bytes per frame, indexed by wD80A_Player_SpriteId:
;
;   +0     how many banks past the set's base bank the frame lives in
;   +1 +2  its address in that bank
;
; The reader adds +0 to the base bank in wDABF_PlayerGfx_SrcBank, then pages that in -
; hence the RestoreBank/SwitchBank pair in both readers, because the directory it just
; read and the frame it names are in different banks.
;
; Entry 0 of every directory is three zero bytes. Sprite id 0 has no frame.
;
; The entries of a directory only ever step forward, so the frames behind one are a
; single packed stream and an entry's successor gives its length. Checked here: every
; frame's length is PLAYER_FRAME_HEADER_SIZE + PLAYER_FRAME_PIECE_SIZE * pieces exactly,
; for all 9 directories, except where a frame is the last in its bank and the
; difference picks up that bank's tail padding.
;
; The frames themselves
; ---------------------
; Out of scope for this file - they are in banks $62-$7E - but the piece counts in the
; comments come from them, and one relationship is worth stating because it explains
; why a single count drives two unrelated pieces of hardware. A frame's header is
;
;   +0     piece count      -> wDAC2_PlayerGfx_TileCount
;   +1 +2  not read by anything; the values track the sprite's size in pixels
;   +3 +4  tile source      -> wDAC0_PlayerGfx_SrcAddr
;   +5...  PLAYER_FRAME_PIECE_SIZE bytes per piece
;
; A piece is one 8x16 OBJ, which is 32 bytes of tile data, and the tile data for a
; frame's pieces is contiguous from +3+4. So the HDMA that
; call_00_0c6a_VBlank_StartPendingHdma sets up - (count * 2 - 1) blocks of 16 bytes -
; moves exactly the frame's own tiles and no more, and the OAM
; loop stepping wDC52_Player_OamTileId by PLAYER_SPRITE_TILE_STRIDE walks the same
; bytes back out in the same order. One number, both jobs.
;
; The palettes
; ------------
; OBJ_PALETTE_BYTES per set - room for all eight CGB OBJ palettes - but
; call_00_2cbf_Entity_LoadMapPalettes copies only CGB_PALETTE_SIZE * 2 of them into
; wDD2A_EntityPalettes. Palettes 2-7 of every block are CGB_COLOR_UNUSED throughout, so
; three quarters of this region is reserved space that was never filled in - nothing
; would notice if it were gone, other than the OBJ_PALETTE_BYTES stride.
;
; Of the two that ARE read:
;
;   palette 0   Gex. Byte for byte the same in all 9 blocks - his colours do not
;               change with the theme, only his tiles do. This is the palette
;               call_03_6567_FlyPowerup_LoadPalette tints while he carries a fly, and
;               putting it back is why that routine jumps here on every frame he does
;               not
;   palette 1   differs per set, and is the only per-set colour in the file. It is the
;               default for entity slot 1; call_03_687c_AssignEntityPalette overwrites
;               it as soon as something occupies that slot
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2
; ------------------------------------------------------------------
; gex2 has no equivalent of this bank, because neither thing it indexes exists there:
;
;   the frames    gex2's Gex is always the same 32x32 rectangle, and
;                 call_03_5ca8_Player_BuildSprites picks one of eight fixed entries of
;                 .data_03_5d6f_PlayerSpriteShapeTable in bank 3. There is one Gex, so
;                 there is nothing to index. gex3 re-draws him per level theme, and a
;                 themed frame list is too big to sit next to the code that uses it
;   the palettes  gex2's call_0b_5f57_Entity_LoadGBCPalette looks colours up by ENTITY
;                 ID, from .data_entity_palettes in bank $0B, one entity type at a time
;                 and only on Colour hardware. gex3 stores a finished pair of palettes
;                 per map and memcpys them, the same trade it makes for BG palettes
;
; The one structure that does carry over is the map-indexed lookup itself, which is
; how gex2 finds a map's music, tileset and spawns too
; ==================================================================

data_7f_4000_PlayerGfx_SetByMap:
; The graphics set each map draws Gex with. See the file header for why the stored
; byte is an offset rather than a set number - the map_gfx_set macro applies the
; PLAYER_GFX_SET_SIZE scale, so the rows read as set names.
;
; Indexed by wDB6C_CurrentMapId, so this table has to stay exactly as long as the
; MAP_* list in constants.asm.
;
; Ids $00-$0b are the first map of each of the twelve levels, in the same order as
; .data_00_05a3_LevelMusic's levels - so for these, map id and level id agree. From
; $0c on the remaining maps follow level by level
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $00  MAP_GEX_CAVE1
    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $01  MAP_HOLIDAY_TV1
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $02  MAP_MYSTERY_TV1
    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $03  MAP_TUT_TV1
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $04  MAP_WESTERN_STATION1
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $05  MAP_ANIME_CHANNEL1
    map_gfx_set PLAYER_GFX_SET_SUPERHERO_SHOW     ; $06  MAP_SUPERHERO_SHOW1
    map_gfx_set PLAYER_GFX_SET_GEXTREME_SPORTS1   ; $07  MAP_GEXTREME_SPORTS1
    map_gfx_set PLAYER_GFX_SET_MARSUPIAL_MADNESS1 ; $08  MAP_MARSUPIAL_MADNESS1
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $09  MAP_WW_GEX_WRESTLING1
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $0a  MAP_LIZARD_OF_OZ1
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $0b  MAP_CHANNEL_Z1

    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $0c  MAP_GEX_CAVE2
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $0d  MAP_GEX_CAVE3
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $0e  MAP_GEX_CAVE4

    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $0f  MAP_HOLIDAY_TV2
    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $10  MAP_HOLIDAY_TV3
    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $11  MAP_HOLIDAY_TV4

    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $12  MAP_MYSTERY_TV2
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $13  MAP_MYSTERY_TV3
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $14  MAP_MYSTERY_TV4
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $15  MAP_MYSTERY_TV5
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $16  MAP_MYSTERY_TV6
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $17  MAP_MYSTERY_TV7
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $18  MAP_MYSTERY_TV8
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $19  MAP_MYSTERY_TV9
    map_gfx_set PLAYER_GFX_SET_MYSTERY_TV         ; $1a  MAP_MYSTERY_TV10

    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $1b  MAP_TUT_TV2
    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $1c  MAP_TUT_TV3
    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $1d  MAP_TUT_TV4
    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $1e  MAP_TUT_TV5
    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $1f  MAP_TUT_TV6
    map_gfx_set PLAYER_GFX_SET_TUT_TV             ; $20  MAP_TUT_TV7

    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $21  MAP_WESTERN_STATION2
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $22  MAP_WESTERN_STATION3
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $23  MAP_WESTERN_STATION4
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $24  MAP_WESTERN_STATION5
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $25  MAP_WESTERN_STATION6
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $26  MAP_WESTERN_STATION7
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $27  MAP_WESTERN_STATION8
    map_gfx_set PLAYER_GFX_SET_WESTERN_STATION    ; $28  MAP_WESTERN_STATION9

    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $29  MAP_ANIME_CHANNEL2
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $2a  MAP_ANIME_CHANNEL3
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $2b  MAP_ANIME_CHANNEL4
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $2c  MAP_ANIME_CHANNEL5
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $2d  MAP_ANIME_CHANNEL6
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $2e  MAP_ANIME_CHANNEL7
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $2f  MAP_ANIME_CHANNEL8
    map_gfx_set PLAYER_GFX_SET_ANIME_CHANNEL      ; $30  MAP_ANIME_CHANNEL9

    map_gfx_set PLAYER_GFX_SET_SUPERHERO_SHOW     ; $31  MAP_SUPERHERO_SHOW2
    map_gfx_set PLAYER_GFX_SET_SUPERHERO_SHOW     ; $32  MAP_SUPERHERO_SHOW3
    map_gfx_set PLAYER_GFX_SET_SUPERHERO_SHOW     ; $33  MAP_SUPERHERO_SHOW4
    map_gfx_set PLAYER_GFX_SET_SUPERHERO_SHOW     ; $34  MAP_SUPERHERO_SHOW5
    map_gfx_set PLAYER_GFX_SET_SUPERHERO_SHOW     ; $35  MAP_SUPERHERO_SHOW6

    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $36  MAP_GEXTREME_SPORTS2
    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $37  MAP_GEXTREME_SPORTS3
    map_gfx_set PLAYER_GFX_SET_HOLIDAY_TV         ; $38  MAP_GEXTREME_SPORTS4

    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $39  MAP_CHANNEL_Z2
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $3a  MAP_CHANNEL_Z3
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $3b  MAP_CHANNEL_Z4
    map_gfx_set PLAYER_GFX_SET_GEX_CAVE           ; $3c  MAP_CHANNEL_Z5

data_7f_403d_PlayerGfx_SetTable:
; PLAYER_GFX_SET_COUNT records of PLAYER_GFX_SET_SIZE bytes: the base bank the
; set's frames start in, the frame directory, and the OBJ palette block. Both
; pointers are addresses in THIS bank; the base bank is one of the graphics banks
;
; Record 0 is written out longhand so the second label can sit inside it - see the
; file header
    db   $7c                                       ; set 0 base bank
    dw   data_7f_406a_PlayerFrames_GexCave
data_7f_4040_PlayerGfx_SetPalettes:
; The palette field of record 0, and the base every OBJ palette lookup adds its
; map offset to. Reached only by call_00_2cbf_Entity_LoadMapPalettes
    dw   data_7f_53f9_MapObjPalettes_GexCave        ; set 0 palettes
    player_gfx_set $79, data_7f_4331_PlayerFrames_HolidayTV, data_7f_5439_MapObjPalettes_HolidayTV                  ; set 1 - Holiday TV 1-4, Gextreme Sports 2-4
    player_gfx_set $76, data_7f_4586_PlayerFrames_MysteryTV, data_7f_5479_MapObjPalettes_MysteryTV                  ; set 2 - Mystery TV 1-10
    player_gfx_set $72, data_7f_47db_PlayerFrames_TutTV, data_7f_54b9_MapObjPalettes_TutTV                          ; set 3 - Tut TV 1-7
    player_gfx_set $6e, data_7f_4a30_PlayerFrames_SuperheroShow, data_7f_54f9_MapObjPalettes_SuperheroShow          ; set 4 - Superhero Show 1-6
    player_gfx_set $6c, data_7f_4cf7_PlayerFrames_GextremeSports1, data_7f_5539_MapObjPalettes_GextremeSports1      ; set 5 - Gextreme Sports 1
    player_gfx_set $67, data_7f_4ded_PlayerFrames_WesternStation, data_7f_5579_MapObjPalettes_WesternStation        ; set 6 - Western Station 1-9
    player_gfx_set $66, data_7f_50b4_PlayerFrames_MarsupialMadness1, data_7f_55b9_MapObjPalettes_MarsupialMadness1  ; set 7 - Marsupial Madness 1
    player_gfx_set $62, data_7f_5132_PlayerFrames_AnimeChannel, data_7f_55f9_MapObjPalettes_AnimeChannel            ; set 8 - Anime Channel 1-9

data_7f_406a_PlayerFrames_GexCave:
; PLAYER_GFX_SET_GEX_CAVE: 236 frames in banks $7c-$7e, directory $406a-$4330
; Used by Gex Cave 1-4, WW Gex Wrestling 1, Lizard of Oz 1, Channel Z 1-5
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $7c   7 pieces
    player_frame $00, $4021                            ; $02  bank $7c   7 pieces
    player_frame $00, $4042                            ; $03  bank $7c   6 pieces
    player_frame $00, $405f                            ; $04  bank $7c   7 pieces
    player_frame $00, $4080                            ; $05  bank $7c   7 pieces
    player_frame $00, $40a1                            ; $06  bank $7c   7 pieces
    player_frame $00, $40c2                            ; $07  bank $7c   7 pieces
    player_frame $00, $40e3                            ; $08  bank $7c   7 pieces
    player_frame $00, $4104                            ; $09  bank $7c   7 pieces
    player_frame $00, $4125                            ; $0a  bank $7c   7 pieces
    player_frame $00, $4146                            ; $0b  bank $7c   7 pieces
    player_frame $00, $4167                            ; $0c  bank $7c   7 pieces
    player_frame $00, $4188                            ; $0d  bank $7c   6 pieces
    player_frame $00, $41a5                            ; $0e  bank $7c   7 pieces
    player_frame $00, $41c6                            ; $0f  bank $7c   7 pieces
    player_frame $00, $41e7                            ; $10  bank $7c   7 pieces
    player_frame $00, $4208                            ; $11  bank $7c   7 pieces
    player_frame $00, $4229                            ; $12  bank $7c   6 pieces
    player_frame $00, $4246                            ; $13  bank $7c   7 pieces
    player_frame $00, $4267                            ; $14  bank $7c   8 pieces
    player_frame $00, $428c                            ; $15  bank $7c   8 pieces
    player_frame $00, $42b1                            ; $16  bank $7c   7 pieces
    player_frame $00, $42d2                            ; $17  bank $7c   7 pieces
    player_frame $00, $42f3                            ; $18  bank $7c   7 pieces
    player_frame $00, $4314                            ; $19  bank $7c   7 pieces
    player_frame $00, $4335                            ; $1a  bank $7c   7 pieces
    player_frame $00, $4356                            ; $1b  bank $7c   7 pieces
    player_frame $00, $4377                            ; $1c  bank $7c   6 pieces
    player_frame $00, $4394                            ; $1d  bank $7c   6 pieces
    player_frame $00, $43b1                            ; $1e  bank $7c   6 pieces
    player_frame $00, $43ce                            ; $1f  bank $7c   7 pieces
    player_frame $00, $43ef                            ; $20  bank $7c   7 pieces
    player_frame $00, $4410                            ; $21  bank $7c   6 pieces
    player_frame $00, $442d                            ; $22  bank $7c   6 pieces
    player_frame $00, $444a                            ; $23  bank $7c   6 pieces
    player_frame $00, $4467                            ; $24  bank $7c   6 pieces
    player_frame $00, $4484                            ; $25  bank $7c   5 pieces
    player_frame $00, $449d                            ; $26  bank $7c   5 pieces
    player_frame $00, $44b6                            ; $27  bank $7c   3 pieces
    player_frame $00, $44c7                            ; $28  bank $7c   3 pieces
    player_frame $00, $44d8                            ; $29  bank $7c   3 pieces
    player_frame $00, $44e9                            ; $2a  bank $7c   7 pieces
    player_frame $00, $450a                            ; $2b  bank $7c   6 pieces
    player_frame $00, $4527                            ; $2c  bank $7c   5 pieces
    player_frame $00, $4540                            ; $2d  bank $7c   6 pieces
    player_frame $00, $455d                            ; $2e  bank $7c   7 pieces
    player_frame $00, $457e                            ; $2f  bank $7c   7 pieces
    player_frame $00, $459f                            ; $30  bank $7c   6 pieces
    player_frame $00, $45bc                            ; $31  bank $7c   6 pieces
    player_frame $00, $45d9                            ; $32  bank $7c   6 pieces
    player_frame $00, $45f6                            ; $33  bank $7c   6 pieces
    player_frame $00, $4613                            ; $34  bank $7c   7 pieces
    player_frame $00, $4634                            ; $35  bank $7c   7 pieces
    player_frame $00, $4655                            ; $36  bank $7c   5 pieces
    player_frame $00, $466e                            ; $37  bank $7c   5 pieces
    player_frame $00, $4687                            ; $38  bank $7c   5 pieces
    player_frame $00, $46a0                            ; $39  bank $7c   6 pieces
    player_frame $00, $46bd                            ; $3a  bank $7c   5 pieces
    player_frame $00, $46d6                            ; $3b  bank $7c   5 pieces
    player_frame $00, $46ef                            ; $3c  bank $7c   5 pieces
    player_frame $00, $4708                            ; $3d  bank $7c   5 pieces
    player_frame $00, $4721                            ; $3e  bank $7c   5 pieces
    player_frame $00, $473a                            ; $3f  bank $7c   6 pieces
    player_frame $00, $4757                            ; $40  bank $7c   7 pieces
    player_frame $00, $4778                            ; $41  bank $7c   6 pieces
    player_frame $00, $4795                            ; $42  bank $7c   6 pieces
    player_frame $00, $47b2                            ; $43  bank $7c   5 pieces
    player_frame $00, $47cb                            ; $44  bank $7c   5 pieces
    player_frame $00, $47e4                            ; $45  bank $7c   5 pieces
    player_frame $00, $47fd                            ; $46  bank $7c   5 pieces
    player_frame $00, $4816                            ; $47  bank $7c   5 pieces
    player_frame $00, $482f                            ; $48  bank $7c   6 pieces
    player_frame $01, $4000                            ; $49  bank $7d   6 pieces
    player_frame $01, $401d                            ; $4a  bank $7d   5 pieces
    player_frame $01, $4036                            ; $4b  bank $7d   6 pieces
    player_frame $01, $4053                            ; $4c  bank $7d   5 pieces
    player_frame $01, $406c                            ; $4d  bank $7d   6 pieces
    player_frame $01, $4089                            ; $4e  bank $7d   6 pieces
    player_frame $01, $40a6                            ; $4f  bank $7d   7 pieces
    player_frame $01, $40c7                            ; $50  bank $7d   6 pieces
    player_frame $01, $40e4                            ; $51  bank $7d   6 pieces
    player_frame $01, $4101                            ; $52  bank $7d   7 pieces
    player_frame $01, $4122                            ; $53  bank $7d   7 pieces
    player_frame $01, $4143                            ; $54  bank $7d   5 pieces
    player_frame $01, $415c                            ; $55  bank $7d   5 pieces
    player_frame $01, $4175                            ; $56  bank $7d   6 pieces
    player_frame $01, $4192                            ; $57  bank $7d   6 pieces
    player_frame $01, $41af                            ; $58  bank $7d   6 pieces
    player_frame $01, $41cc                            ; $59  bank $7d   6 pieces
    player_frame $01, $41e9                            ; $5a  bank $7d   5 pieces
    player_frame $01, $4202                            ; $5b  bank $7d   4 pieces
    player_frame $01, $4217                            ; $5c  bank $7d   4 pieces
    player_frame $01, $422c                            ; $5d  bank $7d   6 pieces
    player_frame $01, $4249                            ; $5e  bank $7d   6 pieces
    player_frame $01, $4266                            ; $5f  bank $7d   6 pieces
    player_frame $01, $4283                            ; $60  bank $7d   5 pieces
    player_frame $01, $429c                            ; $61  bank $7d   5 pieces
    player_frame $01, $42b5                            ; $62  bank $7d   6 pieces
    player_frame $01, $42d2                            ; $63  bank $7d   6 pieces
    player_frame $01, $42ef                            ; $64  bank $7d   6 pieces
    player_frame $01, $430c                            ; $65  bank $7d   6 pieces
    player_frame $01, $4329                            ; $66  bank $7d   6 pieces
    player_frame $01, $4346                            ; $67  bank $7d   5 pieces
    player_frame $01, $435f                            ; $68  bank $7d   5 pieces
    player_frame $01, $4378                            ; $69  bank $7d   6 pieces
    player_frame $01, $4395                            ; $6a  bank $7d   6 pieces
    player_frame $01, $43b2                            ; $6b  bank $7d   6 pieces
    player_frame $01, $43cf                            ; $6c  bank $7d   5 pieces
    player_frame $01, $43e8                            ; $6d  bank $7d   6 pieces
    player_frame $01, $4405                            ; $6e  bank $7d   6 pieces
    player_frame $01, $4422                            ; $6f  bank $7d   6 pieces
    player_frame $01, $443f                            ; $70  bank $7d   4 pieces
    player_frame $01, $4454                            ; $71  bank $7d   6 pieces
    player_frame $01, $4471                            ; $72  bank $7d   6 pieces
    player_frame $01, $448e                            ; $73  bank $7d   6 pieces
    player_frame $01, $44ab                            ; $74  bank $7d   5 pieces
    player_frame $01, $44c4                            ; $75  bank $7d   6 pieces
    player_frame $01, $44e1                            ; $76  bank $7d   5 pieces
    player_frame $01, $44fa                            ; $77  bank $7d   6 pieces
    player_frame $01, $4517                            ; $78  bank $7d   5 pieces
    player_frame $01, $4530                            ; $79  bank $7d   5 pieces
    player_frame $01, $4549                            ; $7a  bank $7d   6 pieces
    player_frame $01, $4566                            ; $7b  bank $7d   5 pieces
    player_frame $01, $457f                            ; $7c  bank $7d   6 pieces
    player_frame $01, $459c                            ; $7d  bank $7d   4 pieces
    player_frame $01, $45b1                            ; $7e  bank $7d   4 pieces
    player_frame $01, $45c6                            ; $7f  bank $7d   4 pieces
    player_frame $01, $45db                            ; $80  bank $7d   4 pieces
    player_frame $01, $45f0                            ; $81  bank $7d   4 pieces
    player_frame $01, $4605                            ; $82  bank $7d   4 pieces
    player_frame $01, $461a                            ; $83  bank $7d   4 pieces
    player_frame $01, $462f                            ; $84  bank $7d   5 pieces
    player_frame $01, $4648                            ; $85  bank $7d   5 pieces
    player_frame $01, $4661                            ; $86  bank $7d   5 pieces
    player_frame $01, $467a                            ; $87  bank $7d   6 pieces
    player_frame $01, $4697                            ; $88  bank $7d   5 pieces
    player_frame $01, $46b0                            ; $89  bank $7d   5 pieces
    player_frame $01, $46c9                            ; $8a  bank $7d   6 pieces
    player_frame $01, $46e6                            ; $8b  bank $7d   5 pieces
    player_frame $01, $46ff                            ; $8c  bank $7d   5 pieces
    player_frame $01, $4718                            ; $8d  bank $7d   5 pieces
    player_frame $01, $4731                            ; $8e  bank $7d   5 pieces
    player_frame $01, $474a                            ; $8f  bank $7d   5 pieces
    player_frame $01, $4763                            ; $90  bank $7d   5 pieces
    player_frame $01, $477c                            ; $91  bank $7d   5 pieces
    player_frame $01, $4795                            ; $92  bank $7d   5 pieces
    player_frame $01, $47ae                            ; $93  bank $7d   5 pieces
    player_frame $01, $47c7                            ; $94  bank $7d   5 pieces
    player_frame $01, $47e0                            ; $95  bank $7d   4 pieces
    player_frame $01, $47f5                            ; $96  bank $7d   4 pieces
    player_frame $01, $480a                            ; $97  bank $7d   4 pieces
    player_frame $01, $481f                            ; $98  bank $7d   4 pieces
    player_frame $01, $4834                            ; $99  bank $7d   4 pieces
    player_frame $01, $4849                            ; $9a  bank $7d   4 pieces
    player_frame $01, $485e                            ; $9b  bank $7d   4 pieces
    player_frame $01, $4873                            ; $9c  bank $7d   4 pieces
    player_frame $02, $4000                            ; $9d  bank $7e   6 pieces
    player_frame $02, $401d                            ; $9e  bank $7e   5 pieces
    player_frame $02, $4036                            ; $9f  bank $7e   7 pieces
    player_frame $02, $4057                            ; $a0  bank $7e   7 pieces
    player_frame $02, $4078                            ; $a1  bank $7e   8 pieces
    player_frame $02, $409d                            ; $a2  bank $7e   9 pieces
    player_frame $02, $40c6                            ; $a3  bank $7e   8 pieces
    player_frame $02, $40eb                            ; $a4  bank $7e   7 pieces
    player_frame $02, $410c                            ; $a5  bank $7e   6 pieces
    player_frame $02, $4129                            ; $a6  bank $7e   4 pieces
    player_frame $02, $413e                            ; $a7  bank $7e   3 pieces
    player_frame $02, $414f                            ; $a8  bank $7e   2 pieces
    player_frame $02, $415c                            ; $a9  bank $7e   5 pieces
    player_frame $02, $4175                            ; $aa  bank $7e   5 pieces
    player_frame $02, $418e                            ; $ab  bank $7e   4 pieces
    player_frame $02, $41a3                            ; $ac  bank $7e   4 pieces
    player_frame $02, $41b8                            ; $ad  bank $7e   4 pieces
    player_frame $02, $41cd                            ; $ae  bank $7e   3 pieces
    player_frame $02, $41de                            ; $af  bank $7e   3 pieces
    player_frame $02, $41ef                            ; $b0  bank $7e   2 pieces
    player_frame $02, $41fc                            ; $b1  bank $7e   2 pieces
    player_frame $02, $4209                            ; $b2  bank $7e   5 pieces
    player_frame $02, $4222                            ; $b3  bank $7e   5 pieces
    player_frame $02, $423b                            ; $b4  bank $7e   5 pieces
    player_frame $02, $4254                            ; $b5  bank $7e   5 pieces
    player_frame $02, $426d                            ; $b6  bank $7e   6 pieces
    player_frame $02, $428a                            ; $b7  bank $7e   5 pieces
    player_frame $02, $42a3                            ; $b8  bank $7e   5 pieces
    player_frame $02, $42bc                            ; $b9  bank $7e   6 pieces
    player_frame $02, $42d9                            ; $ba  bank $7e   7 pieces
    player_frame $02, $42fa                            ; $bb  bank $7e   6 pieces
    player_frame $02, $4317                            ; $bc  bank $7e   6 pieces
    player_frame $02, $4334                            ; $bd  bank $7e   6 pieces
    player_frame $02, $4351                            ; $be  bank $7e   6 pieces
    player_frame $02, $436e                            ; $bf  bank $7e   6 pieces
    player_frame $02, $438b                            ; $c0  bank $7e   5 pieces
    player_frame $02, $43a4                            ; $c1  bank $7e   6 pieces
    player_frame $02, $43c1                            ; $c2  bank $7e   6 pieces
    player_frame $02, $43de                            ; $c3  bank $7e   7 pieces
    player_frame $02, $43ff                            ; $c4  bank $7e   4 pieces
    player_frame $02, $4414                            ; $c5  bank $7e   7 pieces
    player_frame $02, $4435                            ; $c6  bank $7e   6 pieces
    player_frame $02, $4452                            ; $c7  bank $7e   5 pieces
    player_frame $02, $446b                            ; $c8  bank $7e   5 pieces
    player_frame $02, $4484                            ; $c9  bank $7e   6 pieces
    player_frame $02, $44a1                            ; $ca  bank $7e   5 pieces
    player_frame $02, $44ba                            ; $cb  bank $7e   5 pieces
    player_frame $02, $44d3                            ; $cc  bank $7e   6 pieces
    player_frame $02, $44f0                            ; $cd  bank $7e   5 pieces
    player_frame $02, $4509                            ; $ce  bank $7e   5 pieces
    player_frame $02, $4522                            ; $cf  bank $7e   5 pieces
    player_frame $02, $453b                            ; $d0  bank $7e   5 pieces
    player_frame $02, $4554                            ; $d1  bank $7e   6 pieces
    player_frame $02, $4571                            ; $d2  bank $7e   5 pieces
    player_frame $02, $458a                            ; $d3  bank $7e   6 pieces
    player_frame $02, $45a7                            ; $d4  bank $7e   7 pieces
    player_frame $02, $45c8                            ; $d5  bank $7e   4 pieces
    player_frame $02, $45dd                            ; $d6  bank $7e   5 pieces
    player_frame $02, $45f6                            ; $d7  bank $7e   6 pieces
    player_frame $02, $4613                            ; $d8  bank $7e   6 pieces
    player_frame $02, $4630                            ; $d9  bank $7e   5 pieces
    player_frame $02, $4649                            ; $da  bank $7e   5 pieces
    player_frame $02, $4662                            ; $db  bank $7e   6 pieces
    player_frame $02, $467f                            ; $dc  bank $7e   5 pieces
    player_frame $02, $4698                            ; $dd  bank $7e   5 pieces
    player_frame $02, $46b1                            ; $de  bank $7e   5 pieces
    player_frame $02, $46ca                            ; $df  bank $7e   5 pieces
    player_frame $02, $46e3                            ; $e0  bank $7e   7 pieces
    player_frame $02, $4704                            ; $e1  bank $7e   5 pieces
    player_frame $02, $471d                            ; $e2  bank $7e   5 pieces
    player_frame $02, $4736                            ; $e3  bank $7e   5 pieces
    player_frame $02, $474f                            ; $e4  bank $7e   5 pieces
    player_frame $02, $4768                            ; $e5  bank $7e   6 pieces
    player_frame $02, $4785                            ; $e6  bank $7e   6 pieces
    player_frame $02, $47a2                            ; $e7  bank $7e   5 pieces
    player_frame $02, $47bb                            ; $e8  bank $7e   5 pieces
    player_frame $02, $47d4                            ; $e9  bank $7e   6 pieces
    player_frame $02, $47f1                            ; $ea  bank $7e   6 pieces
    player_frame $02, $480e                            ; $eb  bank $7e   5 pieces
    player_frame $02, $4827                            ; $ec  bank $7e   6 pieces

data_7f_4331_PlayerFrames_HolidayTV:
; PLAYER_GFX_SET_HOLIDAY_TV: 198 frames in banks $79-$7b, directory $4331-$4585
; Used by Holiday TV 1-4, Gextreme Sports 2-4
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $79   9 pieces
    player_frame $00, $4029                            ; $02  bank $79  10 pieces
    player_frame $00, $4056                            ; $03  bank $79   8 pieces
    player_frame $00, $407b                            ; $04  bank $79   8 pieces
    player_frame $00, $40a0                            ; $05  bank $79   8 pieces
    player_frame $00, $40c5                            ; $06  bank $79   7 pieces
    player_frame $00, $40e6                            ; $07  bank $79   8 pieces
    player_frame $00, $410b                            ; $08  bank $79   9 pieces
    player_frame $00, $4134                            ; $09  bank $79   9 pieces
    player_frame $00, $415d                            ; $0a  bank $79  10 pieces
    player_frame $00, $418a                            ; $0b  bank $79   9 pieces
    player_frame $00, $41b3                            ; $0c  bank $79   8 pieces
    player_frame $00, $41d8                            ; $0d  bank $79   8 pieces
    player_frame $00, $41fd                            ; $0e  bank $79   7 pieces
    player_frame $00, $421e                            ; $0f  bank $79   8 pieces
    player_frame $00, $4243                            ; $10  bank $79  10 pieces
    player_frame $00, $4270                            ; $11  bank $79  10 pieces
    player_frame $00, $429d                            ; $12  bank $79   8 pieces
    player_frame $00, $42c2                            ; $13  bank $79   9 pieces
    player_frame $00, $42eb                            ; $14  bank $79  10 pieces
    player_frame $00, $4318                            ; $15  bank $79  10 pieces
    player_frame $00, $4345                            ; $16  bank $79   8 pieces
    player_frame $00, $436a                            ; $17  bank $79   8 pieces
    player_frame $00, $438f                            ; $18  bank $79   9 pieces
    player_frame $00, $43b8                            ; $19  bank $79   8 pieces
    player_frame $00, $43dd                            ; $1a  bank $79   8 pieces
    player_frame $00, $4402                            ; $1b  bank $79   8 pieces
    player_frame $00, $4427                            ; $1c  bank $79   9 pieces
    player_frame $00, $4450                            ; $1d  bank $79   8 pieces
    player_frame $00, $4475                            ; $1e  bank $79   8 pieces
    player_frame $00, $449a                            ; $1f  bank $79   8 pieces
    player_frame $00, $44bf                            ; $20  bank $79   7 pieces
    player_frame $00, $44e0                            ; $21  bank $79   8 pieces
    player_frame $00, $4505                            ; $22  bank $79   7 pieces
    player_frame $00, $4526                            ; $23  bank $79   6 pieces
    player_frame $00, $4543                            ; $24  bank $79   7 pieces
    player_frame $00, $4564                            ; $25  bank $79   6 pieces
    player_frame $00, $4581                            ; $26  bank $79   5 pieces
    player_frame $00, $459a                            ; $27  bank $79   4 pieces
    player_frame $00, $45af                            ; $28  bank $79   4 pieces
    player_frame $00, $45c4                            ; $29  bank $79   4 pieces
    player_frame $00, $45d9                            ; $2a  bank $79   8 pieces
    player_frame $00, $45fe                            ; $2b  bank $79   7 pieces
    player_frame $00, $461f                            ; $2c  bank $79   5 pieces
    player_frame $00, $4638                            ; $2d  bank $79   8 pieces
    player_frame $00, $465d                            ; $2e  bank $79   7 pieces
    player_frame $00, $467e                            ; $2f  bank $79   8 pieces
    player_frame $00, $46a3                            ; $30  bank $79   9 pieces
    player_frame $00, $46cc                            ; $31  bank $79   9 pieces
    player_frame $00, $46f5                            ; $32  bank $79   8 pieces
    player_frame $00, $471a                            ; $33  bank $79   8 pieces
    player_frame $00, $473f                            ; $34  bank $79   8 pieces
    player_frame $00, $4764                            ; $35  bank $79   6 pieces
    player_frame $00, $4781                            ; $36  bank $79   7 pieces
    player_frame $00, $47a2                            ; $37  bank $79   7 pieces
    player_frame $00, $47c3                            ; $38  bank $79   6 pieces
    player_frame $00, $47e0                            ; $39  bank $79   7 pieces
    player_frame $01, $4000                            ; $3a  bank $7a   6 pieces
    player_frame $01, $401d                            ; $3b  bank $7a   7 pieces
    player_frame $01, $403e                            ; $3c  bank $7a   7 pieces
    player_frame $01, $405f                            ; $3d  bank $7a   7 pieces
    player_frame $01, $4080                            ; $3e  bank $7a   6 pieces
    player_frame $01, $409d                            ; $3f  bank $7a   6 pieces
    player_frame $01, $40ba                            ; $40  bank $7a   9 pieces
    player_frame $01, $40e3                            ; $41  bank $7a   8 pieces
    player_frame $01, $4108                            ; $42  bank $7a   6 pieces
    player_frame $01, $4125                            ; $43  bank $7a   6 pieces
    player_frame $01, $4142                            ; $44  bank $7a   7 pieces
    player_frame $01, $4163                            ; $45  bank $7a   7 pieces
    player_frame $01, $4184                            ; $46  bank $7a   7 pieces
    player_frame $01, $41a5                            ; $47  bank $7a   7 pieces
    player_frame $01, $41c6                            ; $48  bank $7a   5 pieces
    player_frame $01, $41df                            ; $49  bank $7a   5 pieces
    player_frame $01, $41f8                            ; $4a  bank $7a   5 pieces
    player_frame $01, $4211                            ; $4b  bank $7a   5 pieces
    player_frame $01, $422a                            ; $4c  bank $7a   4 pieces
    player_frame $01, $423f                            ; $4d  bank $7a   5 pieces
    player_frame $01, $4258                            ; $4e  bank $7a   6 pieces
    player_frame $01, $4275                            ; $4f  bank $7a   4 pieces
    player_frame $01, $428a                            ; $50  bank $7a   4 pieces
    player_frame $01, $429f                            ; $51  bank $7a   5 pieces
    player_frame $01, $42b8                            ; $52  bank $7a   6 pieces
    player_frame $01, $42d5                            ; $53  bank $7a   4 pieces
    player_frame $01, $42ea                            ; $54  bank $7a   5 pieces
    player_frame $01, $4303                            ; $55  bank $7a   5 pieces
    player_frame $01, $431c                            ; $56  bank $7a   5 pieces
    player_frame $01, $4335                            ; $57  bank $7a   4 pieces
    player_frame $01, $434a                            ; $58  bank $7a   4 pieces
    player_frame $01, $435f                            ; $59  bank $7a   5 pieces
    player_frame $01, $4378                            ; $5a  bank $7a   4 pieces
    player_frame $01, $438d                            ; $5b  bank $7a   4 pieces
    player_frame $01, $43a2                            ; $5c  bank $7a   4 pieces
    player_frame $01, $43b7                            ; $5d  bank $7a   7 pieces
    player_frame $01, $43d8                            ; $5e  bank $7a   7 pieces
    player_frame $01, $43f9                            ; $5f  bank $7a   8 pieces
    player_frame $01, $441e                            ; $60  bank $7a   6 pieces
    player_frame $01, $443b                            ; $61  bank $7a   7 pieces
    player_frame $01, $445c                            ; $62  bank $7a   8 pieces
    player_frame $01, $4481                            ; $63  bank $7a   8 pieces
    player_frame $01, $44a6                            ; $64  bank $7a   7 pieces
    player_frame $01, $44c7                            ; $65  bank $7a   7 pieces
    player_frame $01, $44e8                            ; $66  bank $7a   8 pieces
    player_frame $01, $450d                            ; $67  bank $7a   6 pieces
    player_frame $01, $452a                            ; $68  bank $7a   5 pieces
    player_frame $01, $4543                            ; $69  bank $7a   7 pieces
    player_frame $01, $4564                            ; $6a  bank $7a   7 pieces
    player_frame $01, $4585                            ; $6b  bank $7a   7 pieces
    player_frame $01, $45a6                            ; $6c  bank $7a   6 pieces
    player_frame $01, $45c3                            ; $6d  bank $7a   7 pieces
    player_frame $01, $45e4                            ; $6e  bank $7a   8 pieces
    player_frame $01, $4609                            ; $6f  bank $7a   7 pieces
    player_frame $01, $462a                            ; $70  bank $7a   6 pieces
    player_frame $01, $4647                            ; $71  bank $7a   6 pieces
    player_frame $01, $4664                            ; $72  bank $7a   8 pieces
    player_frame $01, $4689                            ; $73  bank $7a   7 pieces
    player_frame $01, $46aa                            ; $74  bank $7a   8 pieces
    player_frame $01, $46cf                            ; $75  bank $7a   7 pieces
    player_frame $01, $46f0                            ; $76  bank $7a   7 pieces
    player_frame $01, $4711                            ; $77  bank $7a   7 pieces
    player_frame $01, $4732                            ; $78  bank $7a   8 pieces
    player_frame $01, $4757                            ; $79  bank $7a   7 pieces
    player_frame $01, $4778                            ; $7a  bank $7a   7 pieces
    player_frame $01, $4799                            ; $7b  bank $7a   7 pieces
    player_frame $01, $47ba                            ; $7c  bank $7a   7 pieces
    player_frame $01, $47db                            ; $7d  bank $7a   4 pieces
    player_frame $01, $47f0                            ; $7e  bank $7a   4 pieces
    player_frame $01, $4805                            ; $7f  bank $7a   4 pieces
    player_frame $01, $481a                            ; $80  bank $7a   4 pieces
    player_frame $01, $482f                            ; $81  bank $7a   4 pieces
    player_frame $01, $4844                            ; $82  bank $7a   4 pieces
    player_frame $02, $4000                            ; $83  bank $7b   4 pieces
    player_frame $02, $4015                            ; $84  bank $7b   7 pieces
    player_frame $02, $4036                            ; $85  bank $7b   7 pieces
    player_frame $02, $4057                            ; $86  bank $7b   7 pieces
    player_frame $02, $4078                            ; $87  bank $7b   6 pieces
    player_frame $02, $4095                            ; $88  bank $7b   6 pieces
    player_frame $02, $40b2                            ; $89  bank $7b   6 pieces
    player_frame $02, $40cf                            ; $8a  bank $7b   6 pieces
    player_frame $02, $40ec                            ; $8b  bank $7b   6 pieces
    player_frame $02, $4109                            ; $8c  bank $7b   7 pieces
    player_frame $02, $412a                            ; $8d  bank $7b   6 pieces
    player_frame $02, $4147                            ; $8e  bank $7b   6 pieces
    player_frame $02, $4164                            ; $8f  bank $7b   5 pieces
    player_frame $02, $417d                            ; $90  bank $7b   7 pieces
    player_frame $02, $419e                            ; $91  bank $7b   6 pieces
    player_frame $02, $41bb                            ; $92  bank $7b   6 pieces
    player_frame $02, $41d8                            ; $93  bank $7b   5 pieces
    player_frame $02, $41f1                            ; $94  bank $7b   7 pieces
    player_frame $02, $4212                            ; $95  bank $7b   6 pieces
    player_frame $02, $422f                            ; $96  bank $7b   6 pieces
    player_frame $02, $424c                            ; $97  bank $7b   6 pieces
    player_frame $02, $4269                            ; $98  bank $7b   7 pieces
    player_frame $02, $428a                            ; $99  bank $7b   6 pieces
    player_frame $02, $42a7                            ; $9a  bank $7b   6 pieces
    player_frame $02, $42c4                            ; $9b  bank $7b   6 pieces
    player_frame $02, $42e1                            ; $9c  bank $7b   8 pieces
    player_frame $02, $4306                            ; $9d  bank $7b   9 pieces
    player_frame $02, $432f                            ; $9e  bank $7b   6 pieces
    player_frame $02, $434c                            ; $9f  bank $7b   7 pieces
    player_frame $02, $436d                            ; $a0  bank $7b   7 pieces
    player_frame $02, $438e                            ; $a1  bank $7b   7 pieces
    player_frame $02, $43af                            ; $a2  bank $7b   9 pieces
    player_frame $02, $43d8                            ; $a3  bank $7b   7 pieces
    player_frame $02, $43f9                            ; $a4  bank $7b   7 pieces
    player_frame $02, $441a                            ; $a5  bank $7b   6 pieces
    player_frame $02, $4437                            ; $a6  bank $7b   4 pieces
    player_frame $02, $444c                            ; $a7  bank $7b   3 pieces
    player_frame $02, $445d                            ; $a8  bank $7b   2 pieces
    player_frame $02, $446a                            ; $a9  bank $7b   8 pieces
    player_frame $02, $448f                            ; $aa  bank $7b   8 pieces
    player_frame $02, $44b4                            ; $ab  bank $7b   8 pieces
    player_frame $02, $44d9                            ; $ac  bank $7b   6 pieces
    player_frame $02, $44f6                            ; $ad  bank $7b   6 pieces
    player_frame $02, $4513                            ; $ae  bank $7b   5 pieces
    player_frame $02, $452c                            ; $af  bank $7b   3 pieces
    player_frame $02, $453d                            ; $b0  bank $7b   3 pieces
    player_frame $02, $454e                            ; $b1  bank $7b   3 pieces
    player_frame $02, $455f                            ; $b2  bank $7b   6 pieces
    player_frame $02, $457c                            ; $b3  bank $7b   1 pieces
    player_frame $02, $4585                            ; $b4  bank $7b   1 pieces
    player_frame $02, $458e                            ; $b5  bank $7b   1 pieces
    player_frame $02, $4597                            ; $b6  bank $7b   1 pieces
    player_frame $02, $45a0                            ; $b7  bank $7b   1 pieces
    player_frame $02, $45a9                            ; $b8  bank $7b   1 pieces
    player_frame $02, $45b2                            ; $b9  bank $7b   1 pieces
    player_frame $02, $45bb                            ; $ba  bank $7b   1 pieces
    player_frame $02, $45c4                            ; $bb  bank $7b   1 pieces
    player_frame $02, $45cd                            ; $bc  bank $7b   1 pieces
    player_frame $02, $45d6                            ; $bd  bank $7b   1 pieces
    player_frame $02, $45df                            ; $be  bank $7b   1 pieces
    player_frame $02, $45e8                            ; $bf  bank $7b   1 pieces
    player_frame $02, $45f1                            ; $c0  bank $7b   1 pieces
    player_frame $02, $45fa                            ; $c1  bank $7b   1 pieces
    player_frame $02, $4603                            ; $c2  bank $7b   1 pieces
    player_frame $02, $460c                            ; $c3  bank $7b   1 pieces
    player_frame $02, $4615                            ; $c4  bank $7b   1 pieces
    player_frame $02, $461e                            ; $c5  bank $7b   1 pieces
    player_frame $02, $4627                            ; $c6  bank $7b   1 pieces

data_7f_4586_PlayerFrames_MysteryTV:
; PLAYER_GFX_SET_MYSTERY_TV: 198 frames in banks $76-$78, directory $4586-$47da
; Used by Mystery TV 1-10
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $76   7 pieces
    player_frame $00, $4021                            ; $02  bank $76   7 pieces
    player_frame $00, $4042                            ; $03  bank $76   7 pieces
    player_frame $00, $4063                            ; $04  bank $76   7 pieces
    player_frame $00, $4084                            ; $05  bank $76   8 pieces
    player_frame $00, $40a9                            ; $06  bank $76   6 pieces
    player_frame $00, $40c6                            ; $07  bank $76   8 pieces
    player_frame $00, $40eb                            ; $08  bank $76   8 pieces
    player_frame $00, $4110                            ; $09  bank $76   8 pieces
    player_frame $00, $4135                            ; $0a  bank $76   7 pieces
    player_frame $00, $4156                            ; $0b  bank $76   7 pieces
    player_frame $00, $4177                            ; $0c  bank $76   7 pieces
    player_frame $00, $4198                            ; $0d  bank $76   6 pieces
    player_frame $00, $41b5                            ; $0e  bank $76   7 pieces
    player_frame $00, $41d6                            ; $0f  bank $76   8 pieces
    player_frame $00, $41fb                            ; $10  bank $76   8 pieces
    player_frame $00, $4220                            ; $11  bank $76   8 pieces
    player_frame $00, $4245                            ; $12  bank $76   6 pieces
    player_frame $00, $4262                            ; $13  bank $76   7 pieces
    player_frame $00, $4283                            ; $14  bank $76   8 pieces
    player_frame $00, $42a8                            ; $15  bank $76   8 pieces
    player_frame $00, $42cd                            ; $16  bank $76   8 pieces
    player_frame $00, $42f2                            ; $17  bank $76   8 pieces
    player_frame $00, $4317                            ; $18  bank $76   8 pieces
    player_frame $00, $433c                            ; $19  bank $76   8 pieces
    player_frame $00, $4361                            ; $1a  bank $76   8 pieces
    player_frame $00, $4386                            ; $1b  bank $76   8 pieces
    player_frame $00, $43ab                            ; $1c  bank $76   7 pieces
    player_frame $00, $43cc                            ; $1d  bank $76   6 pieces
    player_frame $00, $43e9                            ; $1e  bank $76   8 pieces
    player_frame $00, $440e                            ; $1f  bank $76   8 pieces
    player_frame $00, $4433                            ; $20  bank $76   7 pieces
    player_frame $00, $4454                            ; $21  bank $76   8 pieces
    player_frame $00, $4479                            ; $22  bank $76   8 pieces
    player_frame $00, $449e                            ; $23  bank $76   7 pieces
    player_frame $00, $44bf                            ; $24  bank $76   6 pieces
    player_frame $00, $44dc                            ; $25  bank $76   6 pieces
    player_frame $00, $44f9                            ; $26  bank $76   6 pieces
    player_frame $00, $4516                            ; $27  bank $76   5 pieces
    player_frame $00, $452f                            ; $28  bank $76   5 pieces
    player_frame $00, $4548                            ; $29  bank $76   5 pieces
    player_frame $00, $4561                            ; $2a  bank $76   8 pieces
    player_frame $00, $4586                            ; $2b  bank $76   7 pieces
    player_frame $00, $45a7                            ; $2c  bank $76   6 pieces
    player_frame $00, $45c4                            ; $2d  bank $76   7 pieces
    player_frame $00, $45e5                            ; $2e  bank $76   8 pieces
    player_frame $00, $460a                            ; $2f  bank $76   8 pieces
    player_frame $00, $462f                            ; $30  bank $76   7 pieces
    player_frame $00, $4650                            ; $31  bank $76   7 pieces
    player_frame $00, $4671                            ; $32  bank $76   8 pieces
    player_frame $00, $4696                            ; $33  bank $76   7 pieces
    player_frame $00, $46b7                            ; $34  bank $76   8 pieces
    player_frame $00, $46dc                            ; $35  bank $76   7 pieces
    player_frame $00, $46fd                            ; $36  bank $76   6 pieces
    player_frame $00, $471a                            ; $37  bank $76   6 pieces
    player_frame $00, $4737                            ; $38  bank $76   7 pieces
    player_frame $00, $4758                            ; $39  bank $76   6 pieces
    player_frame $00, $4775                            ; $3a  bank $76   7 pieces
    player_frame $00, $4796                            ; $3b  bank $76   6 pieces
    player_frame $00, $47b3                            ; $3c  bank $76   7 pieces
    player_frame $00, $47d4                            ; $3d  bank $76   6 pieces
    player_frame $00, $47f1                            ; $3e  bank $76   6 pieces
    player_frame $00, $480e                            ; $3f  bank $76   6 pieces
    player_frame $01, $4000                            ; $40  bank $77   8 pieces
    player_frame $01, $4025                            ; $41  bank $77   8 pieces
    player_frame $01, $404a                            ; $42  bank $77   6 pieces
    player_frame $01, $4067                            ; $43  bank $77   6 pieces
    player_frame $01, $4084                            ; $44  bank $77   6 pieces
    player_frame $01, $40a1                            ; $45  bank $77   6 pieces
    player_frame $01, $40be                            ; $46  bank $77   7 pieces
    player_frame $01, $40df                            ; $47  bank $77   7 pieces
    player_frame $01, $4100                            ; $48  bank $77   6 pieces
    player_frame $01, $411d                            ; $49  bank $77   6 pieces
    player_frame $01, $413a                            ; $4a  bank $77   6 pieces
    player_frame $01, $4157                            ; $4b  bank $77   6 pieces
    player_frame $01, $4174                            ; $4c  bank $77   5 pieces
    player_frame $01, $418d                            ; $4d  bank $77   6 pieces
    player_frame $01, $41aa                            ; $4e  bank $77   7 pieces
    player_frame $01, $41cb                            ; $4f  bank $77   6 pieces
    player_frame $01, $41e8                            ; $50  bank $77   5 pieces
    player_frame $01, $4201                            ; $51  bank $77   6 pieces
    player_frame $01, $421e                            ; $52  bank $77   7 pieces
    player_frame $01, $423f                            ; $53  bank $77   6 pieces
    player_frame $01, $425c                            ; $54  bank $77   5 pieces
    player_frame $01, $4275                            ; $55  bank $77   5 pieces
    player_frame $01, $428e                            ; $56  bank $77   6 pieces
    player_frame $01, $42ab                            ; $57  bank $77   5 pieces
    player_frame $01, $42c4                            ; $58  bank $77   6 pieces
    player_frame $01, $42e1                            ; $59  bank $77   6 pieces
    player_frame $01, $42fe                            ; $5a  bank $77   6 pieces
    player_frame $01, $431b                            ; $5b  bank $77   4 pieces
    player_frame $01, $4330                            ; $5c  bank $77   4 pieces
    player_frame $01, $4345                            ; $5d  bank $77   7 pieces
    player_frame $01, $4366                            ; $5e  bank $77   7 pieces
    player_frame $01, $4387                            ; $5f  bank $77   7 pieces
    player_frame $01, $43a8                            ; $60  bank $77   6 pieces
    player_frame $01, $43c5                            ; $61  bank $77   6 pieces
    player_frame $01, $43e2                            ; $62  bank $77   7 pieces
    player_frame $01, $4403                            ; $63  bank $77   7 pieces
    player_frame $01, $4424                            ; $64  bank $77   7 pieces
    player_frame $01, $4445                            ; $65  bank $77   6 pieces
    player_frame $01, $4462                            ; $66  bank $77   7 pieces
    player_frame $01, $4483                            ; $67  bank $77   6 pieces
    player_frame $01, $44a0                            ; $68  bank $77   6 pieces
    player_frame $01, $44bd                            ; $69  bank $77   7 pieces
    player_frame $01, $44de                            ; $6a  bank $77   7 pieces
    player_frame $01, $44ff                            ; $6b  bank $77   7 pieces
    player_frame $01, $4520                            ; $6c  bank $77   6 pieces
    player_frame $01, $453d                            ; $6d  bank $77   7 pieces
    player_frame $01, $455e                            ; $6e  bank $77   8 pieces
    player_frame $01, $4583                            ; $6f  bank $77   6 pieces
    player_frame $01, $45a0                            ; $70  bank $77   6 pieces
    player_frame $01, $45bd                            ; $71  bank $77   6 pieces
    player_frame $01, $45da                            ; $72  bank $77   7 pieces
    player_frame $01, $45fb                            ; $73  bank $77   7 pieces
    player_frame $01, $461c                            ; $74  bank $77   8 pieces
    player_frame $01, $4641                            ; $75  bank $77   8 pieces
    player_frame $01, $4666                            ; $76  bank $77   7 pieces
    player_frame $01, $4687                            ; $77  bank $77   7 pieces
    player_frame $01, $46a8                            ; $78  bank $77   7 pieces
    player_frame $01, $46c9                            ; $79  bank $77   7 pieces
    player_frame $01, $46ea                            ; $7a  bank $77   7 pieces
    player_frame $01, $470b                            ; $7b  bank $77   7 pieces
    player_frame $01, $472c                            ; $7c  bank $77   7 pieces
    player_frame $01, $474d                            ; $7d  bank $77   4 pieces
    player_frame $01, $4762                            ; $7e  bank $77   4 pieces
    player_frame $01, $4777                            ; $7f  bank $77   4 pieces
    player_frame $01, $478c                            ; $80  bank $77   4 pieces
    player_frame $01, $47a1                            ; $81  bank $77   4 pieces
    player_frame $01, $47b6                            ; $82  bank $77   4 pieces
    player_frame $01, $47cb                            ; $83  bank $77   4 pieces
    player_frame $01, $47e0                            ; $84  bank $77   6 pieces
    player_frame $01, $47fd                            ; $85  bank $77   6 pieces
    player_frame $01, $481a                            ; $86  bank $77   6 pieces
    player_frame $01, $4837                            ; $87  bank $77   7 pieces
    player_frame $02, $4000                            ; $88  bank $78   5 pieces
    player_frame $02, $4019                            ; $89  bank $78   5 pieces
    player_frame $02, $4032                            ; $8a  bank $78   6 pieces
    player_frame $02, $404f                            ; $8b  bank $78   5 pieces
    player_frame $02, $4068                            ; $8c  bank $78   6 pieces
    player_frame $02, $4085                            ; $8d  bank $78   7 pieces
    player_frame $02, $40a6                            ; $8e  bank $78   7 pieces
    player_frame $02, $40c7                            ; $8f  bank $78   6 pieces
    player_frame $02, $40e4                            ; $90  bank $78   7 pieces
    player_frame $02, $4105                            ; $91  bank $78   7 pieces
    player_frame $02, $4126                            ; $92  bank $78   7 pieces
    player_frame $02, $4147                            ; $93  bank $78   6 pieces
    player_frame $02, $4164                            ; $94  bank $78   7 pieces
    player_frame $02, $4185                            ; $95  bank $78   7 pieces
    player_frame $02, $41a6                            ; $96  bank $78   7 pieces
    player_frame $02, $41c7                            ; $97  bank $78   6 pieces
    player_frame $02, $41e4                            ; $98  bank $78   7 pieces
    player_frame $02, $4205                            ; $99  bank $78   7 pieces
    player_frame $02, $4226                            ; $9a  bank $78   7 pieces
    player_frame $02, $4247                            ; $9b  bank $78   6 pieces
    player_frame $02, $4264                            ; $9c  bank $78   7 pieces
    player_frame $02, $4285                            ; $9d  bank $78   7 pieces
    player_frame $02, $42a6                            ; $9e  bank $78   7 pieces
    player_frame $02, $42c7                            ; $9f  bank $78   8 pieces
    player_frame $02, $42ec                            ; $a0  bank $78   8 pieces
    player_frame $02, $4311                            ; $a1  bank $78   8 pieces
    player_frame $02, $4336                            ; $a2  bank $78   9 pieces
    player_frame $02, $435f                            ; $a3  bank $78   8 pieces
    player_frame $02, $4384                            ; $a4  bank $78   8 pieces
    player_frame $02, $43a9                            ; $a5  bank $78   6 pieces
    player_frame $02, $43c6                            ; $a6  bank $78   4 pieces
    player_frame $02, $43db                            ; $a7  bank $78   3 pieces
    player_frame $02, $43ec                            ; $a8  bank $78   2 pieces
    player_frame $02, $43f9                            ; $a9  bank $78   8 pieces
    player_frame $02, $441e                            ; $aa  bank $78   6 pieces
    player_frame $02, $443b                            ; $ab  bank $78   5 pieces
    player_frame $02, $4454                            ; $ac  bank $78   5 pieces
    player_frame $02, $446d                            ; $ad  bank $78   4 pieces
    player_frame $02, $4482                            ; $ae  bank $78   4 pieces
    player_frame $02, $4497                            ; $af  bank $78   4 pieces
    player_frame $02, $44ac                            ; $b0  bank $78   3 pieces
    player_frame $02, $44bd                            ; $b1  bank $78   2 pieces
    player_frame $02, $44ca                            ; $b2  bank $78   6 pieces
    player_frame $02, $44e7                            ; $b3  bank $78   6 pieces
    player_frame $02, $4504                            ; $b4  bank $78   6 pieces
    player_frame $02, $4521                            ; $b5  bank $78   6 pieces
    player_frame $02, $453e                            ; $b6  bank $78   7 pieces
    player_frame $02, $455f                            ; $b7  bank $78   7 pieces
    player_frame $02, $4580                            ; $b8  bank $78   8 pieces
    player_frame $02, $45a5                            ; $b9  bank $78   7 pieces
    player_frame $02, $45c6                            ; $ba  bank $78   7 pieces
    player_frame $02, $45e7                            ; $bb  bank $78   6 pieces
    player_frame $02, $4604                            ; $bc  bank $78   5 pieces
    player_frame $02, $461d                            ; $bd  bank $78   5 pieces
    player_frame $02, $4636                            ; $be  bank $78   5 pieces
    player_frame $02, $464f                            ; $bf  bank $78   6 pieces
    player_frame $02, $466c                            ; $c0  bank $78   6 pieces
    player_frame $02, $4689                            ; $c1  bank $78   6 pieces
    player_frame $02, $46a6                            ; $c2  bank $78   6 pieces
    player_frame $02, $46c3                            ; $c3  bank $78   7 pieces
    player_frame $02, $46e4                            ; $c4  bank $78   5 pieces
    player_frame $02, $46fd                            ; $c5  bank $78   8 pieces
    player_frame $02, $4722                            ; $c6  bank $78   7 pieces

data_7f_47db_PlayerFrames_TutTV:
; PLAYER_GFX_SET_TUT_TV: 198 frames in banks $72-$75, directory $47db-$4a2f
; Used by Tut TV 1-7
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $72   9 pieces
    player_frame $00, $4029                            ; $02  bank $72  10 pieces
    player_frame $00, $4056                            ; $03  bank $72   8 pieces
    player_frame $00, $407b                            ; $04  bank $72   8 pieces
    player_frame $00, $40a0                            ; $05  bank $72   9 pieces
    player_frame $00, $40c9                            ; $06  bank $72   9 pieces
    player_frame $00, $40f2                            ; $07  bank $72  11 pieces
    player_frame $00, $4123                            ; $08  bank $72  10 pieces
    player_frame $00, $4150                            ; $09  bank $72  10 pieces
    player_frame $00, $417d                            ; $0a  bank $72  10 pieces
    player_frame $00, $41aa                            ; $0b  bank $72  10 pieces
    player_frame $00, $41d7                            ; $0c  bank $72   9 pieces
    player_frame $00, $4200                            ; $0d  bank $72   8 pieces
    player_frame $00, $4225                            ; $0e  bank $72  10 pieces
    player_frame $00, $4252                            ; $0f  bank $72  10 pieces
    player_frame $00, $427f                            ; $10  bank $72   9 pieces
    player_frame $00, $42a8                            ; $11  bank $72  10 pieces
    player_frame $00, $42d5                            ; $12  bank $72   8 pieces
    player_frame $00, $42fa                            ; $13  bank $72   8 pieces
    player_frame $00, $431f                            ; $14  bank $72  10 pieces
    player_frame $00, $434c                            ; $15  bank $72  10 pieces
    player_frame $00, $4379                            ; $16  bank $72  10 pieces
    player_frame $00, $43a6                            ; $17  bank $72  10 pieces
    player_frame $00, $43d3                            ; $18  bank $72   9 pieces
    player_frame $00, $43fc                            ; $19  bank $72   8 pieces
    player_frame $00, $4421                            ; $1a  bank $72   8 pieces
    player_frame $00, $4446                            ; $1b  bank $72   9 pieces
    player_frame $00, $446f                            ; $1c  bank $72   8 pieces
    player_frame $00, $4494                            ; $1d  bank $72   7 pieces
    player_frame $00, $44b5                            ; $1e  bank $72   8 pieces
    player_frame $00, $44da                            ; $1f  bank $72   9 pieces
    player_frame $00, $4503                            ; $20  bank $72  10 pieces
    player_frame $00, $4530                            ; $21  bank $72   9 pieces
    player_frame $00, $4559                            ; $22  bank $72   8 pieces
    player_frame $00, $457e                            ; $23  bank $72   7 pieces
    player_frame $00, $459f                            ; $24  bank $72   6 pieces
    player_frame $00, $45bc                            ; $25  bank $72   6 pieces
    player_frame $00, $45d9                            ; $26  bank $72   6 pieces
    player_frame $00, $45f6                            ; $27  bank $72   4 pieces
    player_frame $00, $460b                            ; $28  bank $72   4 pieces
    player_frame $00, $4620                            ; $29  bank $72   4 pieces
    player_frame $00, $4635                            ; $2a  bank $72   9 pieces
    player_frame $00, $465e                            ; $2b  bank $72   7 pieces
    player_frame $00, $467f                            ; $2c  bank $72   7 pieces
    player_frame $00, $46a0                            ; $2d  bank $72   7 pieces
    player_frame $00, $46c1                            ; $2e  bank $72   9 pieces
    player_frame $00, $46ea                            ; $2f  bank $72  10 pieces
    player_frame $00, $4717                            ; $30  bank $72   9 pieces
    player_frame $00, $4740                            ; $31  bank $72   8 pieces
    player_frame $00, $4765                            ; $32  bank $72   8 pieces
    player_frame $00, $478a                            ; $33  bank $72   9 pieces
    player_frame $00, $47b3                            ; $34  bank $72   8 pieces
    player_frame $00, $47d8                            ; $35  bank $72   7 pieces
    player_frame $01, $4000                            ; $36  bank $73   7 pieces
    player_frame $01, $4021                            ; $37  bank $73   7 pieces
    player_frame $01, $4042                            ; $38  bank $73   7 pieces
    player_frame $01, $4063                            ; $39  bank $73   7 pieces
    player_frame $01, $4084                            ; $3a  bank $73   7 pieces
    player_frame $01, $40a5                            ; $3b  bank $73   7 pieces
    player_frame $01, $40c6                            ; $3c  bank $73   7 pieces
    player_frame $01, $40e7                            ; $3d  bank $73   7 pieces
    player_frame $01, $4108                            ; $3e  bank $73   7 pieces
    player_frame $01, $4129                            ; $3f  bank $73   8 pieces
    player_frame $01, $414e                            ; $40  bank $73   8 pieces
    player_frame $01, $4173                            ; $41  bank $73   9 pieces
    player_frame $01, $419c                            ; $42  bank $73   8 pieces
    player_frame $01, $41c1                            ; $43  bank $73   6 pieces
    player_frame $01, $41de                            ; $44  bank $73   8 pieces
    player_frame $01, $4203                            ; $45  bank $73   8 pieces
    player_frame $01, $4228                            ; $46  bank $73   8 pieces
    player_frame $01, $424d                            ; $47  bank $73   8 pieces
    player_frame $01, $4272                            ; $48  bank $73   6 pieces
    player_frame $01, $428f                            ; $49  bank $73   6 pieces
    player_frame $01, $42ac                            ; $4a  bank $73   6 pieces
    player_frame $01, $42c9                            ; $4b  bank $73   6 pieces
    player_frame $01, $42e6                            ; $4c  bank $73   5 pieces
    player_frame $01, $42ff                            ; $4d  bank $73   6 pieces
    player_frame $01, $431c                            ; $4e  bank $73   7 pieces
    player_frame $01, $433d                            ; $4f  bank $73   7 pieces
    player_frame $01, $435e                            ; $50  bank $73   6 pieces
    player_frame $01, $437b                            ; $51  bank $73   6 pieces
    player_frame $01, $4398                            ; $52  bank $73   6 pieces
    player_frame $01, $43b5                            ; $53  bank $73   7 pieces
    player_frame $01, $43d6                            ; $54  bank $73   6 pieces
    player_frame $01, $43f3                            ; $55  bank $73   6 pieces
    player_frame $01, $4410                            ; $56  bank $73   6 pieces
    player_frame $01, $442d                            ; $57  bank $73   6 pieces
    player_frame $01, $444a                            ; $58  bank $73   6 pieces
    player_frame $01, $4467                            ; $59  bank $73   6 pieces
    player_frame $01, $4484                            ; $5a  bank $73   5 pieces
    player_frame $01, $449d                            ; $5b  bank $73   5 pieces
    player_frame $01, $44b6                            ; $5c  bank $73   6 pieces
    player_frame $01, $44d3                            ; $5d  bank $73   8 pieces
    player_frame $01, $44f8                            ; $5e  bank $73   8 pieces
    player_frame $01, $451d                            ; $5f  bank $73   8 pieces
    player_frame $01, $4542                            ; $60  bank $73   7 pieces
    player_frame $01, $4563                            ; $61  bank $73   7 pieces
    player_frame $01, $4584                            ; $62  bank $73   8 pieces
    player_frame $01, $45a9                            ; $63  bank $73   8 pieces
    player_frame $01, $45ce                            ; $64  bank $73   8 pieces
    player_frame $01, $45f3                            ; $65  bank $73   8 pieces
    player_frame $01, $4618                            ; $66  bank $73   8 pieces
    player_frame $01, $463d                            ; $67  bank $73   7 pieces
    player_frame $01, $465e                            ; $68  bank $73   7 pieces
    player_frame $01, $467f                            ; $69  bank $73   8 pieces
    player_frame $01, $46a4                            ; $6a  bank $73   8 pieces
    player_frame $01, $46c9                            ; $6b  bank $73   8 pieces
    player_frame $01, $46ee                            ; $6c  bank $73   6 pieces
    player_frame $01, $470b                            ; $6d  bank $73   8 pieces
    player_frame $01, $4730                            ; $6e  bank $73   9 pieces
    player_frame $01, $4759                            ; $6f  bank $73   7 pieces
    player_frame $01, $477a                            ; $70  bank $73   6 pieces
    player_frame $01, $4797                            ; $71  bank $73   8 pieces
    player_frame $01, $47bc                            ; $72  bank $73   9 pieces
    player_frame $01, $47e5                            ; $73  bank $73   8 pieces
    player_frame $01, $480a                            ; $74  bank $73   8 pieces
    player_frame $02, $4000                            ; $75  bank $74   8 pieces
    player_frame $02, $4025                            ; $76  bank $74   8 pieces
    player_frame $02, $404a                            ; $77  bank $74   8 pieces
    player_frame $02, $406f                            ; $78  bank $74   8 pieces
    player_frame $02, $4094                            ; $79  bank $74   8 pieces
    player_frame $02, $40b9                            ; $7a  bank $74   9 pieces
    player_frame $02, $40e2                            ; $7b  bank $74   9 pieces
    player_frame $02, $410b                            ; $7c  bank $74   9 pieces
    player_frame $02, $4134                            ; $7d  bank $74   4 pieces
    player_frame $02, $4149                            ; $7e  bank $74   4 pieces
    player_frame $02, $415e                            ; $7f  bank $74   4 pieces
    player_frame $02, $4173                            ; $80  bank $74   4 pieces
    player_frame $02, $4188                            ; $81  bank $74   4 pieces
    player_frame $02, $419d                            ; $82  bank $74   4 pieces
    player_frame $02, $41b2                            ; $83  bank $74   4 pieces
    player_frame $02, $41c7                            ; $84  bank $74   7 pieces
    player_frame $02, $41e8                            ; $85  bank $74   7 pieces
    player_frame $02, $4209                            ; $86  bank $74   6 pieces
    player_frame $02, $4226                            ; $87  bank $74   8 pieces
    player_frame $02, $424b                            ; $88  bank $74   8 pieces
    player_frame $02, $4270                            ; $89  bank $74   6 pieces
    player_frame $02, $428d                            ; $8a  bank $74   8 pieces
    player_frame $02, $42b2                            ; $8b  bank $74   7 pieces
    player_frame $02, $42d3                            ; $8c  bank $74   8 pieces
    player_frame $02, $42f8                            ; $8d  bank $74   7 pieces
    player_frame $02, $4319                            ; $8e  bank $74   7 pieces
    player_frame $02, $433a                            ; $8f  bank $74   6 pieces
    player_frame $02, $4357                            ; $90  bank $74   7 pieces
    player_frame $02, $4378                            ; $91  bank $74   8 pieces
    player_frame $02, $439d                            ; $92  bank $74   8 pieces
    player_frame $02, $43c2                            ; $93  bank $74   7 pieces
    player_frame $02, $43e3                            ; $94  bank $74   8 pieces
    player_frame $02, $4408                            ; $95  bank $74   8 pieces
    player_frame $02, $442d                            ; $96  bank $74   7 pieces
    player_frame $02, $444e                            ; $97  bank $74   7 pieces
    player_frame $02, $446f                            ; $98  bank $74   8 pieces
    player_frame $02, $4494                            ; $99  bank $74   8 pieces
    player_frame $02, $44b9                            ; $9a  bank $74   7 pieces
    player_frame $02, $44da                            ; $9b  bank $74   7 pieces
    player_frame $02, $44fb                            ; $9c  bank $74   8 pieces
    player_frame $02, $4520                            ; $9d  bank $74   9 pieces
    player_frame $02, $4549                            ; $9e  bank $74   8 pieces
    player_frame $02, $456e                            ; $9f  bank $74   8 pieces
    player_frame $02, $4593                            ; $a0  bank $74   8 pieces
    player_frame $02, $45b8                            ; $a1  bank $74   8 pieces
    player_frame $02, $45dd                            ; $a2  bank $74   9 pieces
    player_frame $02, $4606                            ; $a3  bank $74   7 pieces
    player_frame $02, $4627                            ; $a4  bank $74   8 pieces
    player_frame $02, $464c                            ; $a5  bank $74   6 pieces
    player_frame $02, $4669                            ; $a6  bank $74   4 pieces
    player_frame $02, $467e                            ; $a7  bank $74   3 pieces
    player_frame $02, $468f                            ; $a8  bank $74   2 pieces
    player_frame $02, $469c                            ; $a9  bank $74   8 pieces
    player_frame $02, $46c1                            ; $aa  bank $74   8 pieces
    player_frame $02, $46e6                            ; $ab  bank $74   8 pieces
    player_frame $02, $470b                            ; $ac  bank $74   6 pieces
    player_frame $02, $4728                            ; $ad  bank $74   6 pieces
    player_frame $02, $4745                            ; $ae  bank $74   4 pieces
    player_frame $02, $475a                            ; $af  bank $74   4 pieces
    player_frame $02, $476f                            ; $b0  bank $74   2 pieces
    player_frame $02, $477c                            ; $b1  bank $74   2 pieces
    player_frame $02, $4789                            ; $b2  bank $74   6 pieces
    player_frame $02, $47a6                            ; $b3  bank $74   6 pieces
    player_frame $02, $47c3                            ; $b4  bank $74   6 pieces
    player_frame $02, $47e0                            ; $b5  bank $74   6 pieces
    player_frame $02, $47fd                            ; $b6  bank $74   6 pieces
    player_frame $02, $481a                            ; $b7  bank $74   5 pieces
    player_frame $03, $4000                            ; $b8  bank $75   6 pieces
    player_frame $03, $401d                            ; $b9  bank $75   6 pieces
    player_frame $03, $403a                            ; $ba  bank $75   6 pieces
    player_frame $03, $4057                            ; $bb  bank $75   6 pieces
    player_frame $03, $4074                            ; $bc  bank $75   6 pieces
    player_frame $03, $4091                            ; $bd  bank $75   6 pieces
    player_frame $03, $40ae                            ; $be  bank $75   6 pieces
    player_frame $03, $40cb                            ; $bf  bank $75   6 pieces
    player_frame $03, $40e8                            ; $c0  bank $75   5 pieces
    player_frame $03, $4101                            ; $c1  bank $75   6 pieces
    player_frame $03, $411e                            ; $c2  bank $75   6 pieces
    player_frame $03, $413b                            ; $c3  bank $75   7 pieces
    player_frame $03, $415c                            ; $c4  bank $75   5 pieces
    player_frame $03, $4175                            ; $c5  bank $75   7 pieces
    player_frame $03, $4196                            ; $c6  bank $75   6 pieces

data_7f_4a30_PlayerFrames_SuperheroShow:
; PLAYER_GFX_SET_SUPERHERO_SHOW: 236 frames in banks $6e-$71, directory $4a30-$4cf6
; Used by Superhero Show 1-6
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $6e  10 pieces
    player_frame $00, $402d                            ; $02  bank $6e   9 pieces
    player_frame $00, $4056                            ; $03  bank $6e   9 pieces
    player_frame $00, $407f                            ; $04  bank $6e   8 pieces
    player_frame $00, $40a4                            ; $05  bank $6e   9 pieces
    player_frame $00, $40cd                            ; $06  bank $6e   9 pieces
    player_frame $00, $40f6                            ; $07  bank $6e   8 pieces
    player_frame $00, $411b                            ; $08  bank $6e   8 pieces
    player_frame $00, $4140                            ; $09  bank $6e   8 pieces
    player_frame $00, $4165                            ; $0a  bank $6e  10 pieces
    player_frame $00, $4192                            ; $0b  bank $6e  10 pieces
    player_frame $00, $41bf                            ; $0c  bank $6e  10 pieces
    player_frame $00, $41ec                            ; $0d  bank $6e   7 pieces
    player_frame $00, $420d                            ; $0e  bank $6e   8 pieces
    player_frame $00, $4232                            ; $0f  bank $6e   8 pieces
    player_frame $00, $4257                            ; $10  bank $6e  10 pieces
    player_frame $00, $4284                            ; $11  bank $6e   9 pieces
    player_frame $00, $42ad                            ; $12  bank $6e   9 pieces
    player_frame $00, $42d6                            ; $13  bank $6e   9 pieces
    player_frame $00, $42ff                            ; $14  bank $6e  10 pieces
    player_frame $00, $432c                            ; $15  bank $6e   8 pieces
    player_frame $00, $4351                            ; $16  bank $6e  11 pieces
    player_frame $00, $4382                            ; $17  bank $6e   9 pieces
    player_frame $00, $43ab                            ; $18  bank $6e   9 pieces
    player_frame $00, $43d4                            ; $19  bank $6e   9 pieces
    player_frame $00, $43fd                            ; $1a  bank $6e   9 pieces
    player_frame $00, $4426                            ; $1b  bank $6e   9 pieces
    player_frame $00, $444f                            ; $1c  bank $6e   8 pieces
    player_frame $00, $4474                            ; $1d  bank $6e   7 pieces
    player_frame $00, $4495                            ; $1e  bank $6e   9 pieces
    player_frame $00, $44be                            ; $1f  bank $6e   9 pieces
    player_frame $00, $44e7                            ; $20  bank $6e   9 pieces
    player_frame $00, $4510                            ; $21  bank $6e   9 pieces
    player_frame $00, $4539                            ; $22  bank $6e   9 pieces
    player_frame $00, $4562                            ; $23  bank $6e   8 pieces
    player_frame $00, $4587                            ; $24  bank $6e   6 pieces
    player_frame $00, $45a4                            ; $25  bank $6e   6 pieces
    player_frame $00, $45c1                            ; $26  bank $6e   6 pieces
    player_frame $00, $45de                            ; $27  bank $6e   4 pieces
    player_frame $00, $45f3                            ; $28  bank $6e   4 pieces
    player_frame $00, $4608                            ; $29  bank $6e   4 pieces
    player_frame $00, $461d                            ; $2a  bank $6e   7 pieces
    player_frame $00, $463e                            ; $2b  bank $6e   8 pieces
    player_frame $00, $4663                            ; $2c  bank $6e   7 pieces
    player_frame $00, $4684                            ; $2d  bank $6e   9 pieces
    player_frame $00, $46ad                            ; $2e  bank $6e   8 pieces
    player_frame $00, $46d2                            ; $2f  bank $6e  10 pieces
    player_frame $00, $46ff                            ; $30  bank $6e   8 pieces
    player_frame $00, $4724                            ; $31  bank $6e  10 pieces
    player_frame $00, $4751                            ; $32  bank $6e  10 pieces
    player_frame $00, $477e                            ; $33  bank $6e   9 pieces
    player_frame $00, $47a7                            ; $34  bank $6e   9 pieces
    player_frame $00, $47d0                            ; $35  bank $6e   9 pieces
    player_frame $01, $4000                            ; $36  bank $6f   8 pieces
    player_frame $01, $4025                            ; $37  bank $6f   7 pieces
    player_frame $01, $4046                            ; $38  bank $6f   7 pieces
    player_frame $01, $4067                            ; $39  bank $6f   8 pieces
    player_frame $01, $408c                            ; $3a  bank $6f   8 pieces
    player_frame $01, $40b1                            ; $3b  bank $6f   7 pieces
    player_frame $01, $40d2                            ; $3c  bank $6f   7 pieces
    player_frame $01, $40f3                            ; $3d  bank $6f   8 pieces
    player_frame $01, $4118                            ; $3e  bank $6f   7 pieces
    player_frame $01, $4139                            ; $3f  bank $6f   9 pieces
    player_frame $01, $4162                            ; $40  bank $6f   9 pieces
    player_frame $01, $418b                            ; $41  bank $6f   9 pieces
    player_frame $01, $41b4                            ; $42  bank $6f   8 pieces
    player_frame $01, $41d9                            ; $43  bank $6f   7 pieces
    player_frame $01, $41fa                            ; $44  bank $6f   7 pieces
    player_frame $01, $421b                            ; $45  bank $6f   8 pieces
    player_frame $01, $4240                            ; $46  bank $6f   7 pieces
    player_frame $01, $4261                            ; $47  bank $6f   8 pieces
    player_frame $01, $4286                            ; $48  bank $6f   5 pieces
    player_frame $01, $429f                            ; $49  bank $6f   5 pieces
    player_frame $01, $42b8                            ; $4a  bank $6f   4 pieces
    player_frame $01, $42cd                            ; $4b  bank $6f   5 pieces
    player_frame $01, $42e6                            ; $4c  bank $6f   4 pieces
    player_frame $01, $42fb                            ; $4d  bank $6f   5 pieces
    player_frame $01, $4314                            ; $4e  bank $6f   6 pieces
    player_frame $01, $4331                            ; $4f  bank $6f   6 pieces
    player_frame $01, $434e                            ; $50  bank $6f   5 pieces
    player_frame $01, $4367                            ; $51  bank $6f   5 pieces
    player_frame $01, $4380                            ; $52  bank $6f   6 pieces
    player_frame $01, $439d                            ; $53  bank $6f   6 pieces
    player_frame $01, $43ba                            ; $54  bank $6f   5 pieces
    player_frame $01, $43d3                            ; $55  bank $6f   5 pieces
    player_frame $01, $43ec                            ; $56  bank $6f   5 pieces
    player_frame $01, $4405                            ; $57  bank $6f   4 pieces
    player_frame $01, $441a                            ; $58  bank $6f   4 pieces
    player_frame $01, $442f                            ; $59  bank $6f   5 pieces
    player_frame $01, $4448                            ; $5a  bank $6f   4 pieces
    player_frame $01, $445d                            ; $5b  bank $6f   4 pieces
    player_frame $01, $4472                            ; $5c  bank $6f   4 pieces
    player_frame $01, $4487                            ; $5d  bank $6f   7 pieces
    player_frame $01, $44a8                            ; $5e  bank $6f   7 pieces
    player_frame $01, $44c9                            ; $5f  bank $6f   6 pieces
    player_frame $01, $44e6                            ; $60  bank $6f   6 pieces
    player_frame $01, $4503                            ; $61  bank $6f   8 pieces
    player_frame $01, $4528                            ; $62  bank $6f   8 pieces
    player_frame $01, $454d                            ; $63  bank $6f   8 pieces
    player_frame $01, $4572                            ; $64  bank $6f   7 pieces
    player_frame $01, $4593                            ; $65  bank $6f   7 pieces
    player_frame $01, $45b4                            ; $66  bank $6f   7 pieces
    player_frame $01, $45d5                            ; $67  bank $6f   7 pieces
    player_frame $01, $45f6                            ; $68  bank $6f   7 pieces
    player_frame $01, $4617                            ; $69  bank $6f   8 pieces
    player_frame $01, $463c                            ; $6a  bank $6f   8 pieces
    player_frame $01, $4661                            ; $6b  bank $6f   8 pieces
    player_frame $01, $4686                            ; $6c  bank $6f   7 pieces
    player_frame $01, $46a7                            ; $6d  bank $6f   7 pieces
    player_frame $01, $46c8                            ; $6e  bank $6f   8 pieces
    player_frame $01, $46ed                            ; $6f  bank $6f   6 pieces
    player_frame $01, $470a                            ; $70  bank $6f   6 pieces
    player_frame $01, $4727                            ; $71  bank $6f   7 pieces
    player_frame $01, $4748                            ; $72  bank $6f   8 pieces
    player_frame $01, $476d                            ; $73  bank $6f   9 pieces
    player_frame $01, $4796                            ; $74  bank $6f   8 pieces
    player_frame $01, $47bb                            ; $75  bank $6f   8 pieces
    player_frame $01, $47e0                            ; $76  bank $6f   8 pieces
    player_frame $01, $4805                            ; $77  bank $6f   8 pieces
    player_frame $02, $4000                            ; $78  bank $70   8 pieces
    player_frame $02, $4025                            ; $79  bank $70   8 pieces
    player_frame $02, $404a                            ; $7a  bank $70   8 pieces
    player_frame $02, $406f                            ; $7b  bank $70   8 pieces
    player_frame $02, $4094                            ; $7c  bank $70   8 pieces
    player_frame $02, $40b9                            ; $7d  bank $70   4 pieces
    player_frame $02, $40ce                            ; $7e  bank $70   4 pieces
    player_frame $02, $40e3                            ; $7f  bank $70   4 pieces
    player_frame $02, $40f8                            ; $80  bank $70   4 pieces
    player_frame $02, $410d                            ; $81  bank $70   4 pieces
    player_frame $02, $4122                            ; $82  bank $70   4 pieces
    player_frame $02, $4137                            ; $83  bank $70   4 pieces
    player_frame $02, $414c                            ; $84  bank $70   8 pieces
    player_frame $02, $4171                            ; $85  bank $70   8 pieces
    player_frame $02, $4196                            ; $86  bank $70   8 pieces
    player_frame $02, $41bb                            ; $87  bank $70   8 pieces
    player_frame $02, $41e0                            ; $88  bank $70   7 pieces
    player_frame $02, $4201                            ; $89  bank $70   7 pieces
    player_frame $02, $4222                            ; $8a  bank $70   8 pieces
    player_frame $02, $4247                            ; $8b  bank $70   8 pieces
    player_frame $02, $426c                            ; $8c  bank $70   8 pieces
    player_frame $02, $4291                            ; $8d  bank $70   7 pieces
    player_frame $02, $42b2                            ; $8e  bank $70   7 pieces
    player_frame $02, $42d3                            ; $8f  bank $70   7 pieces
    player_frame $02, $42f4                            ; $90  bank $70   7 pieces
    player_frame $02, $4315                            ; $91  bank $70   7 pieces
    player_frame $02, $4336                            ; $92  bank $70   7 pieces
    player_frame $02, $4357                            ; $93  bank $70   7 pieces
    player_frame $02, $4378                            ; $94  bank $70   7 pieces
    player_frame $02, $4399                            ; $95  bank $70   7 pieces
    player_frame $02, $43ba                            ; $96  bank $70   7 pieces
    player_frame $02, $43db                            ; $97  bank $70   7 pieces
    player_frame $02, $43fc                            ; $98  bank $70   7 pieces
    player_frame $02, $441d                            ; $99  bank $70   7 pieces
    player_frame $02, $443e                            ; $9a  bank $70   7 pieces
    player_frame $02, $445f                            ; $9b  bank $70   7 pieces
    player_frame $02, $4480                            ; $9c  bank $70   7 pieces
    player_frame $02, $44a1                            ; $9d  bank $70  11 pieces
    player_frame $02, $44d2                            ; $9e  bank $70   8 pieces
    player_frame $02, $44f7                            ; $9f  bank $70   8 pieces
    player_frame $02, $451c                            ; $a0  bank $70   8 pieces
    player_frame $02, $4541                            ; $a1  bank $70   8 pieces
    player_frame $02, $4566                            ; $a2  bank $70   9 pieces
    player_frame $02, $458f                            ; $a3  bank $70   8 pieces
    player_frame $02, $45b4                            ; $a4  bank $70   5 pieces
    player_frame $02, $45cd                            ; $a5  bank $70   6 pieces
    player_frame $02, $45ea                            ; $a6  bank $70   5 pieces
    player_frame $02, $4603                            ; $a7  bank $70   3 pieces
    player_frame $02, $4614                            ; $a8  bank $70   2 pieces
    player_frame $02, $4621                            ; $a9  bank $70   9 pieces
    player_frame $02, $464a                            ; $aa  bank $70   8 pieces
    player_frame $02, $466f                            ; $ab  bank $70   8 pieces
    player_frame $02, $4694                            ; $ac  bank $70   6 pieces
    player_frame $02, $46b1                            ; $ad  bank $70   4 pieces
    player_frame $02, $46c6                            ; $ae  bank $70   4 pieces
    player_frame $02, $46db                            ; $af  bank $70   3 pieces
    player_frame $02, $46ec                            ; $b0  bank $70   3 pieces
    player_frame $02, $46fd                            ; $b1  bank $70   3 pieces
    player_frame $02, $470e                            ; $b2  bank $70   7 pieces
    player_frame $02, $472f                            ; $b3  bank $70   4 pieces
    player_frame $02, $4744                            ; $b4  bank $70   4 pieces
    player_frame $02, $4759                            ; $b5  bank $70   4 pieces
    player_frame $02, $476e                            ; $b6  bank $70   5 pieces
    player_frame $02, $4787                            ; $b7  bank $70   4 pieces
    player_frame $02, $479c                            ; $b8  bank $70   5 pieces
    player_frame $02, $47b5                            ; $b9  bank $70   5 pieces
    player_frame $02, $47ce                            ; $ba  bank $70   5 pieces
    player_frame $02, $47e7                            ; $bb  bank $70   5 pieces
    player_frame $02, $4800                            ; $bc  bank $70   5 pieces
    player_frame $02, $4819                            ; $bd  bank $70   5 pieces
    player_frame $02, $4832                            ; $be  bank $70   5 pieces
    player_frame $03, $4000                            ; $bf  bank $71   6 pieces
    player_frame $03, $401d                            ; $c0  bank $71   5 pieces
    player_frame $03, $4036                            ; $c1  bank $71   6 pieces
    player_frame $03, $4053                            ; $c2  bank $71   5 pieces
    player_frame $03, $406c                            ; $c3  bank $71   6 pieces
    player_frame $03, $4089                            ; $c4  bank $71   5 pieces
    player_frame $03, $40a2                            ; $c5  bank $71   7 pieces
    player_frame $03, $40c3                            ; $c6  bank $71   6 pieces
    player_frame $03, $40e0                            ; $c7  bank $71  10 pieces
    player_frame $03, $410d                            ; $c8  bank $71   9 pieces
    player_frame $03, $4136                            ; $c9  bank $71   8 pieces
    player_frame $03, $415b                            ; $ca  bank $71   9 pieces
    player_frame $03, $4184                            ; $cb  bank $71   7 pieces
    player_frame $03, $41a5                            ; $cc  bank $71   8 pieces
    player_frame $03, $41ca                            ; $cd  bank $71   7 pieces
    player_frame $03, $41eb                            ; $ce  bank $71   6 pieces
    player_frame $03, $4208                            ; $cf  bank $71   8 pieces
    player_frame $03, $422d                            ; $d0  bank $71   8 pieces
    player_frame $03, $4252                            ; $d1  bank $71   9 pieces
    player_frame $03, $427b                            ; $d2  bank $71   9 pieces
    player_frame $03, $42a4                            ; $d3  bank $71   9 pieces
    player_frame $03, $42cd                            ; $d4  bank $71   9 pieces
    player_frame $03, $42f6                            ; $d5  bank $71   7 pieces
    player_frame $03, $4317                            ; $d6  bank $71  10 pieces
    player_frame $03, $4344                            ; $d7  bank $71  10 pieces
    player_frame $03, $4371                            ; $d8  bank $71   8 pieces
    player_frame $03, $4396                            ; $d9  bank $71   9 pieces
    player_frame $03, $43bf                            ; $da  bank $71   8 pieces
    player_frame $03, $43e4                            ; $db  bank $71   7 pieces
    player_frame $03, $4405                            ; $dc  bank $71   9 pieces
    player_frame $03, $442e                            ; $dd  bank $71   9 pieces
    player_frame $03, $4457                            ; $de  bank $71   9 pieces
    player_frame $03, $4480                            ; $df  bank $71   8 pieces
    player_frame $03, $44a5                            ; $e0  bank $71   9 pieces
    player_frame $03, $44ce                            ; $e1  bank $71   9 pieces
    player_frame $03, $44f7                            ; $e2  bank $71   9 pieces
    player_frame $03, $4520                            ; $e3  bank $71   9 pieces
    player_frame $03, $4549                            ; $e4  bank $71   8 pieces
    player_frame $03, $456e                            ; $e5  bank $71   8 pieces
    player_frame $03, $4593                            ; $e6  bank $71   9 pieces
    player_frame $03, $45bc                            ; $e7  bank $71   8 pieces
    player_frame $03, $45e1                            ; $e8  bank $71  10 pieces
    player_frame $03, $460e                            ; $e9  bank $71   8 pieces
    player_frame $03, $4633                            ; $ea  bank $71  10 pieces
    player_frame $03, $4660                            ; $eb  bank $71   8 pieces
    player_frame $03, $4685                            ; $ec  bank $71  10 pieces

data_7f_4cf7_PlayerFrames_GextremeSports1:
; PLAYER_GFX_SET_GEXTREME_SPORTS1: 81 frames in banks $6c-$6d, directory $4cf7-$4dec
; Used by Gextreme Sports 1, and by nothing else. Its frame list is a fraction of the
; size of a walking set's - 81 frames against 236 - which is what a level with a
; restricted move set needs, and what a level where Gex walks around does not
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $6c   8 pieces
    player_frame $00, $4025                            ; $02  bank $6c   9 pieces
    player_frame $00, $404e                            ; $03  bank $6c   8 pieces
    player_frame $00, $4073                            ; $04  bank $6c   9 pieces
    player_frame $00, $409c                            ; $05  bank $6c   7 pieces
    player_frame $00, $40bd                            ; $06  bank $6c   8 pieces
    player_frame $00, $40e2                            ; $07  bank $6c  10 pieces
    player_frame $00, $410f                            ; $08  bank $6c  10 pieces
    player_frame $00, $413c                            ; $09  bank $6c   9 pieces
    player_frame $00, $4165                            ; $0a  bank $6c   9 pieces
    player_frame $00, $418e                            ; $0b  bank $6c   7 pieces
    player_frame $00, $41af                            ; $0c  bank $6c   6 pieces
    player_frame $00, $41cc                            ; $0d  bank $6c   6 pieces
    player_frame $00, $41e9                            ; $0e  bank $6c   7 pieces
    player_frame $00, $420a                            ; $0f  bank $6c   7 pieces
    player_frame $00, $422b                            ; $10  bank $6c   6 pieces
    player_frame $00, $4248                            ; $11  bank $6c   6 pieces
    player_frame $00, $4265                            ; $12  bank $6c   9 pieces
    player_frame $00, $428e                            ; $13  bank $6c   7 pieces
    player_frame $00, $42af                            ; $14  bank $6c   6 pieces
    player_frame $00, $42cc                            ; $15  bank $6c   8 pieces
    player_frame $00, $42f1                            ; $16  bank $6c   9 pieces
    player_frame $00, $431a                            ; $17  bank $6c   7 pieces
    player_frame $00, $433b                            ; $18  bank $6c   7 pieces
    player_frame $00, $435c                            ; $19  bank $6c   7 pieces
    player_frame $00, $437d                            ; $1a  bank $6c   8 pieces
    player_frame $00, $43a2                            ; $1b  bank $6c   7 pieces
    player_frame $00, $43c3                            ; $1c  bank $6c   6 pieces
    player_frame $00, $43e0                            ; $1d  bank $6c   7 pieces
    player_frame $00, $4401                            ; $1e  bank $6c   8 pieces
    player_frame $00, $4426                            ; $1f  bank $6c   7 pieces
    player_frame $00, $4447                            ; $20  bank $6c   6 pieces
    player_frame $00, $4464                            ; $21  bank $6c   7 pieces
    player_frame $00, $4485                            ; $22  bank $6c   9 pieces
    player_frame $00, $44ae                            ; $23  bank $6c   7 pieces
    player_frame $00, $44cf                            ; $24  bank $6c   6 pieces
    player_frame $00, $44ec                            ; $25  bank $6c   7 pieces
    player_frame $00, $450d                            ; $26  bank $6c   8 pieces
    player_frame $00, $4532                            ; $27  bank $6c   7 pieces
    player_frame $00, $4553                            ; $28  bank $6c   6 pieces
    player_frame $00, $4570                            ; $29  bank $6c   7 pieces
    player_frame $00, $4591                            ; $2a  bank $6c   8 pieces
    player_frame $00, $45b6                            ; $2b  bank $6c   6 pieces
    player_frame $00, $45d3                            ; $2c  bank $6c   5 pieces
    player_frame $00, $45ec                            ; $2d  bank $6c   7 pieces
    player_frame $00, $460d                            ; $2e  bank $6c   8 pieces
    player_frame $00, $4632                            ; $2f  bank $6c   7 pieces
    player_frame $00, $4653                            ; $30  bank $6c   6 pieces
    player_frame $00, $4670                            ; $31  bank $6c   7 pieces
    player_frame $00, $4691                            ; $32  bank $6c   8 pieces
    player_frame $00, $46b6                            ; $33  bank $6c   9 pieces
    player_frame $00, $46df                            ; $34  bank $6c   9 pieces
    player_frame $00, $4708                            ; $35  bank $6c   9 pieces
    player_frame $00, $4731                            ; $36  bank $6c   9 pieces
    player_frame $00, $475a                            ; $37  bank $6c  10 pieces
    player_frame $00, $4787                            ; $38  bank $6c  10 pieces
    player_frame $00, $47b4                            ; $39  bank $6c   9 pieces
    player_frame $00, $47dd                            ; $3a  bank $6c   7 pieces
    player_frame $00, $47fe                            ; $3b  bank $6c   4 pieces
    player_frame $00, $4813                            ; $3c  bank $6c   3 pieces
    player_frame $01, $4000                            ; $3d  bank $6d   2 pieces
    player_frame $01, $400d                            ; $3e  bank $6d   9 pieces
    player_frame $01, $4036                            ; $3f  bank $6d   9 pieces
    player_frame $01, $405f                            ; $40  bank $6d   9 pieces
    player_frame $01, $4088                            ; $41  bank $6d   7 pieces
    player_frame $01, $40a9                            ; $42  bank $6d   7 pieces
    player_frame $01, $40ca                            ; $43  bank $6d   4 pieces
    player_frame $01, $40df                            ; $44  bank $6d   3 pieces
    player_frame $01, $40f0                            ; $45  bank $6d   3 pieces
    player_frame $01, $4101                            ; $46  bank $6d   9 pieces
    player_frame $01, $412a                            ; $47  bank $6d   7 pieces
    player_frame $01, $414b                            ; $48  bank $6d   8 pieces
    player_frame $01, $4170                            ; $49  bank $6d   7 pieces
    player_frame $01, $4191                            ; $4a  bank $6d   7 pieces
    player_frame $01, $41b2                            ; $4b  bank $6d  11 pieces
    player_frame $01, $41e3                            ; $4c  bank $6d  10 pieces
    player_frame $01, $4210                            ; $4d  bank $6d   7 pieces
    player_frame $01, $4231                            ; $4e  bank $6d   9 pieces
    player_frame $01, $425a                            ; $4f  bank $6d   7 pieces
    player_frame $01, $427b                            ; $50  bank $6d   8 pieces
    player_frame $01, $42a0                            ; $51  bank $6d   8 pieces

data_7f_4ded_PlayerFrames_WesternStation:
; PLAYER_GFX_SET_WESTERN_STATION: 236 frames in banks $67-$6b, directory $4ded-$50b3
; Used by Western Station 1-9
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $67  10 pieces
    player_frame $00, $402d                            ; $02  bank $67  10 pieces
    player_frame $00, $405a                            ; $03  bank $67   9 pieces
    player_frame $00, $4083                            ; $04  bank $67   8 pieces
    player_frame $00, $40a8                            ; $05  bank $67  10 pieces
    player_frame $00, $40d5                            ; $06  bank $67  10 pieces
    player_frame $00, $4102                            ; $07  bank $67  10 pieces
    player_frame $00, $412f                            ; $08  bank $67  10 pieces
    player_frame $00, $415c                            ; $09  bank $67  10 pieces
    player_frame $00, $4189                            ; $0a  bank $67  10 pieces
    player_frame $00, $41b6                            ; $0b  bank $67  10 pieces
    player_frame $00, $41e3                            ; $0c  bank $67   9 pieces
    player_frame $00, $420c                            ; $0d  bank $67   9 pieces
    player_frame $00, $4235                            ; $0e  bank $67  10 pieces
    player_frame $00, $4262                            ; $0f  bank $67  10 pieces
    player_frame $00, $428f                            ; $10  bank $67  11 pieces
    player_frame $00, $42c0                            ; $11  bank $67  10 pieces
    player_frame $00, $42ed                            ; $12  bank $67   9 pieces
    player_frame $00, $4316                            ; $13  bank $67   9 pieces
    player_frame $00, $433f                            ; $14  bank $67  10 pieces
    player_frame $00, $436c                            ; $15  bank $67  10 pieces
    player_frame $00, $4399                            ; $16  bank $67  10 pieces
    player_frame $00, $43c6                            ; $17  bank $67  10 pieces
    player_frame $00, $43f3                            ; $18  bank $67  10 pieces
    player_frame $00, $4420                            ; $19  bank $67  10 pieces
    player_frame $00, $444d                            ; $1a  bank $67  10 pieces
    player_frame $00, $447a                            ; $1b  bank $67  10 pieces
    player_frame $00, $44a7                            ; $1c  bank $67   9 pieces
    player_frame $00, $44d0                            ; $1d  bank $67   7 pieces
    player_frame $00, $44f1                            ; $1e  bank $67   9 pieces
    player_frame $00, $451a                            ; $1f  bank $67  10 pieces
    player_frame $00, $4547                            ; $20  bank $67   9 pieces
    player_frame $00, $4570                            ; $21  bank $67   9 pieces
    player_frame $00, $4599                            ; $22  bank $67   9 pieces
    player_frame $00, $45c2                            ; $23  bank $67   9 pieces
    player_frame $00, $45eb                            ; $24  bank $67   7 pieces
    player_frame $00, $460c                            ; $25  bank $67   6 pieces
    player_frame $00, $4629                            ; $26  bank $67   6 pieces
    player_frame $00, $4646                            ; $27  bank $67   6 pieces
    player_frame $00, $4663                            ; $28  bank $67   6 pieces
    player_frame $00, $4680                            ; $29  bank $67   6 pieces
    player_frame $00, $469d                            ; $2a  bank $67  10 pieces
    player_frame $00, $46ca                            ; $2b  bank $67   8 pieces
    player_frame $00, $46ef                            ; $2c  bank $67   7 pieces
    player_frame $00, $4710                            ; $2d  bank $67   9 pieces
    player_frame $00, $4739                            ; $2e  bank $67  10 pieces
    player_frame $00, $4766                            ; $2f  bank $67  10 pieces
    player_frame $00, $4793                            ; $30  bank $67  10 pieces
    player_frame $00, $47c0                            ; $31  bank $67   9 pieces
    player_frame $01, $4000                            ; $32  bank $68  10 pieces
    player_frame $01, $402d                            ; $33  bank $68  10 pieces
    player_frame $01, $405a                            ; $34  bank $68   9 pieces
    player_frame $01, $4083                            ; $35  bank $68   8 pieces
    player_frame $01, $40a8                            ; $36  bank $68   7 pieces
    player_frame $01, $40c9                            ; $37  bank $68   7 pieces
    player_frame $01, $40ea                            ; $38  bank $68   8 pieces
    player_frame $01, $410f                            ; $39  bank $68   7 pieces
    player_frame $01, $4130                            ; $3a  bank $68   7 pieces
    player_frame $01, $4151                            ; $3b  bank $68   7 pieces
    player_frame $01, $4172                            ; $3c  bank $68   8 pieces
    player_frame $01, $4197                            ; $3d  bank $68   7 pieces
    player_frame $01, $41b8                            ; $3e  bank $68   7 pieces
    player_frame $01, $41d9                            ; $3f  bank $68   9 pieces
    player_frame $01, $4202                            ; $40  bank $68   9 pieces
    player_frame $01, $422b                            ; $41  bank $68   9 pieces
    player_frame $01, $4254                            ; $42  bank $68   9 pieces
    player_frame $01, $427d                            ; $43  bank $68   8 pieces
    player_frame $01, $42a2                            ; $44  bank $68   8 pieces
    player_frame $01, $42c7                            ; $45  bank $68   8 pieces
    player_frame $01, $42ec                            ; $46  bank $68   8 pieces
    player_frame $01, $4311                            ; $47  bank $68   8 pieces
    player_frame $01, $4336                            ; $48  bank $68   5 pieces
    player_frame $01, $434f                            ; $49  bank $68   5 pieces
    player_frame $01, $4368                            ; $4a  bank $68   5 pieces
    player_frame $01, $4381                            ; $4b  bank $68   6 pieces
    player_frame $01, $439e                            ; $4c  bank $68   6 pieces
    player_frame $01, $43bb                            ; $4d  bank $68   6 pieces
    player_frame $01, $43d8                            ; $4e  bank $68   6 pieces
    player_frame $01, $43f5                            ; $4f  bank $68   7 pieces
    player_frame $01, $4416                            ; $50  bank $68   7 pieces
    player_frame $01, $4437                            ; $51  bank $68   5 pieces
    player_frame $01, $4450                            ; $52  bank $68   7 pieces
    player_frame $01, $4471                            ; $53  bank $68   7 pieces
    player_frame $01, $4492                            ; $54  bank $68   6 pieces
    player_frame $01, $44af                            ; $55  bank $68   6 pieces
    player_frame $01, $44cc                            ; $56  bank $68   8 pieces
    player_frame $01, $44f1                            ; $57  bank $68   6 pieces
    player_frame $01, $450e                            ; $58  bank $68   6 pieces
    player_frame $01, $452b                            ; $59  bank $68   7 pieces
    player_frame $01, $454c                            ; $5a  bank $68   6 pieces
    player_frame $01, $4569                            ; $5b  bank $68   5 pieces
    player_frame $01, $4582                            ; $5c  bank $68   7 pieces
    player_frame $01, $45a3                            ; $5d  bank $68   9 pieces
    player_frame $01, $45cc                            ; $5e  bank $68   9 pieces
    player_frame $01, $45f5                            ; $5f  bank $68   9 pieces
    player_frame $01, $461e                            ; $60  bank $68   8 pieces
    player_frame $01, $4643                            ; $61  bank $68   7 pieces
    player_frame $01, $4664                            ; $62  bank $68   9 pieces
    player_frame $01, $468d                            ; $63  bank $68   9 pieces
    player_frame $01, $46b6                            ; $64  bank $68   9 pieces
    player_frame $01, $46df                            ; $65  bank $68   8 pieces
    player_frame $01, $4704                            ; $66  bank $68   9 pieces
    player_frame $01, $472d                            ; $67  bank $68   7 pieces
    player_frame $01, $474e                            ; $68  bank $68   8 pieces
    player_frame $01, $4773                            ; $69  bank $68   9 pieces
    player_frame $01, $479c                            ; $6a  bank $68   9 pieces
    player_frame $01, $47c5                            ; $6b  bank $68   9 pieces
    player_frame $01, $47ee                            ; $6c  bank $68   8 pieces
    player_frame $02, $4000                            ; $6d  bank $69   9 pieces
    player_frame $02, $4029                            ; $6e  bank $69   9 pieces
    player_frame $02, $4052                            ; $6f  bank $69   8 pieces
    player_frame $02, $4077                            ; $70  bank $69   6 pieces
    player_frame $02, $4094                            ; $71  bank $69   8 pieces
    player_frame $02, $40b9                            ; $72  bank $69   9 pieces
    player_frame $02, $40e2                            ; $73  bank $69   8 pieces
    player_frame $02, $4107                            ; $74  bank $69   8 pieces
    player_frame $02, $412c                            ; $75  bank $69   8 pieces
    player_frame $02, $4151                            ; $76  bank $69   8 pieces
    player_frame $02, $4176                            ; $77  bank $69   8 pieces
    player_frame $02, $419b                            ; $78  bank $69   7 pieces
    player_frame $02, $41bc                            ; $79  bank $69   8 pieces
    player_frame $02, $41e1                            ; $7a  bank $69   8 pieces
    player_frame $02, $4206                            ; $7b  bank $69   8 pieces
    player_frame $02, $422b                            ; $7c  bank $69   8 pieces
    player_frame $02, $4250                            ; $7d  bank $69   4 pieces
    player_frame $02, $4265                            ; $7e  bank $69   4 pieces
    player_frame $02, $427a                            ; $7f  bank $69   4 pieces
    player_frame $02, $428f                            ; $80  bank $69   4 pieces
    player_frame $02, $42a4                            ; $81  bank $69   4 pieces
    player_frame $02, $42b9                            ; $82  bank $69   4 pieces
    player_frame $02, $42ce                            ; $83  bank $69   4 pieces
    player_frame $02, $42e3                            ; $84  bank $69   8 pieces
    player_frame $02, $4308                            ; $85  bank $69   8 pieces
    player_frame $02, $432d                            ; $86  bank $69   9 pieces
    player_frame $02, $4356                            ; $87  bank $69   9 pieces
    player_frame $02, $437f                            ; $88  bank $69   6 pieces
    player_frame $02, $439c                            ; $89  bank $69   6 pieces
    player_frame $02, $43b9                            ; $8a  bank $69   9 pieces
    player_frame $02, $43e2                            ; $8b  bank $69   8 pieces
    player_frame $02, $4407                            ; $8c  bank $69   9 pieces
    player_frame $02, $4430                            ; $8d  bank $69   8 pieces
    player_frame $02, $4455                            ; $8e  bank $69   8 pieces
    player_frame $02, $447a                            ; $8f  bank $69   7 pieces
    player_frame $02, $449b                            ; $90  bank $69   8 pieces
    player_frame $02, $44c0                            ; $91  bank $69   8 pieces
    player_frame $02, $44e5                            ; $92  bank $69   8 pieces
    player_frame $02, $450a                            ; $93  bank $69   7 pieces
    player_frame $02, $452b                            ; $94  bank $69   8 pieces
    player_frame $02, $4550                            ; $95  bank $69   6 pieces
    player_frame $02, $456d                            ; $96  bank $69   6 pieces
    player_frame $02, $458a                            ; $97  bank $69   6 pieces
    player_frame $02, $45a7                            ; $98  bank $69   6 pieces
    player_frame $02, $45c4                            ; $99  bank $69   6 pieces
    player_frame $02, $45e1                            ; $9a  bank $69   6 pieces
    player_frame $02, $45fe                            ; $9b  bank $69   6 pieces
    player_frame $02, $461b                            ; $9c  bank $69   6 pieces
    player_frame $02, $4638                            ; $9d  bank $69   9 pieces
    player_frame $02, $4661                            ; $9e  bank $69   9 pieces
    player_frame $02, $468a                            ; $9f  bank $69   9 pieces
    player_frame $02, $46b3                            ; $a0  bank $69   9 pieces
    player_frame $02, $46dc                            ; $a1  bank $69   8 pieces
    player_frame $02, $4701                            ; $a2  bank $69   9 pieces
    player_frame $02, $472a                            ; $a3  bank $69   8 pieces
    player_frame $02, $474f                            ; $a4  bank $69   9 pieces
    player_frame $02, $4778                            ; $a5  bank $69   6 pieces
    player_frame $02, $4795                            ; $a6  bank $69   5 pieces
    player_frame $02, $47ae                            ; $a7  bank $69   3 pieces
    player_frame $02, $47bf                            ; $a8  bank $69   2 pieces
    player_frame $02, $47cc                            ; $a9  bank $69   9 pieces
    player_frame $02, $47f5                            ; $aa  bank $69   9 pieces
    player_frame $03, $4000                            ; $ab  bank $6a   9 pieces
    player_frame $03, $4029                            ; $ac  bank $6a   6 pieces
    player_frame $03, $4046                            ; $ad  bank $6a   5 pieces
    player_frame $03, $405f                            ; $ae  bank $6a   4 pieces
    player_frame $03, $4074                            ; $af  bank $6a   4 pieces
    player_frame $03, $4089                            ; $b0  bank $6a   3 pieces
    player_frame $03, $409a                            ; $b1  bank $6a   2 pieces
    player_frame $03, $40a7                            ; $b2  bank $6a   6 pieces
    player_frame $03, $40c4                            ; $b3  bank $6a   6 pieces
    player_frame $03, $40e1                            ; $b4  bank $6a   6 pieces
    player_frame $03, $40fe                            ; $b5  bank $6a   6 pieces
    player_frame $03, $411b                            ; $b6  bank $6a   7 pieces
    player_frame $03, $413c                            ; $b7  bank $6a   6 pieces
    player_frame $03, $4159                            ; $b8  bank $6a   7 pieces
    player_frame $03, $417a                            ; $b9  bank $6a   7 pieces
    player_frame $03, $419b                            ; $ba  bank $6a   6 pieces
    player_frame $03, $41b8                            ; $bb  bank $6a   7 pieces
    player_frame $03, $41d9                            ; $bc  bank $6a   6 pieces
    player_frame $03, $41f6                            ; $bd  bank $6a   5 pieces
    player_frame $03, $420f                            ; $be  bank $6a   5 pieces
    player_frame $03, $4228                            ; $bf  bank $6a   7 pieces
    player_frame $03, $4249                            ; $c0  bank $6a   5 pieces
    player_frame $03, $4262                            ; $c1  bank $6a   6 pieces
    player_frame $03, $427f                            ; $c2  bank $6a   6 pieces
    player_frame $03, $429c                            ; $c3  bank $6a   6 pieces
    player_frame $03, $42b9                            ; $c4  bank $6a   5 pieces
    player_frame $03, $42d2                            ; $c5  bank $6a   7 pieces
    player_frame $03, $42f3                            ; $c6  bank $6a   7 pieces
    player_frame $03, $4314                            ; $c7  bank $6a   8 pieces
    player_frame $03, $4339                            ; $c8  bank $6a   7 pieces
    player_frame $03, $435a                            ; $c9  bank $6a   8 pieces
    player_frame $03, $437f                            ; $ca  bank $6a   7 pieces
    player_frame $03, $43a0                            ; $cb  bank $6a   7 pieces
    player_frame $03, $43c1                            ; $cc  bank $6a   7 pieces
    player_frame $03, $43e2                            ; $cd  bank $6a   7 pieces
    player_frame $03, $4403                            ; $ce  bank $6a   8 pieces
    player_frame $03, $4428                            ; $cf  bank $6a   7 pieces
    player_frame $03, $4449                            ; $d0  bank $6a   7 pieces
    player_frame $03, $446a                            ; $d1  bank $6a   7 pieces
    player_frame $03, $448b                            ; $d2  bank $6a   8 pieces
    player_frame $03, $44b0                            ; $d3  bank $6a   9 pieces
    player_frame $03, $44d9                            ; $d4  bank $6a   9 pieces
    player_frame $03, $4502                            ; $d5  bank $6a   8 pieces
    player_frame $03, $4527                            ; $d6  bank $6a   8 pieces
    player_frame $03, $454c                            ; $d7  bank $6a   9 pieces
    player_frame $03, $4575                            ; $d8  bank $6a  10 pieces
    player_frame $03, $45a2                            ; $d9  bank $6a   9 pieces
    player_frame $03, $45cb                            ; $da  bank $6a   8 pieces
    player_frame $03, $45f0                            ; $db  bank $6a  11 pieces
    player_frame $03, $4621                            ; $dc  bank $6a   7 pieces
    player_frame $03, $4642                            ; $dd  bank $6a   7 pieces
    player_frame $03, $4663                            ; $de  bank $6a   8 pieces
    player_frame $03, $4688                            ; $df  bank $6a   8 pieces
    player_frame $03, $46ad                            ; $e0  bank $6a  10 pieces
    player_frame $03, $46da                            ; $e1  bank $6a   8 pieces
    player_frame $03, $46ff                            ; $e2  bank $6a   9 pieces
    player_frame $03, $4728                            ; $e3  bank $6a   8 pieces
    player_frame $03, $474d                            ; $e4  bank $6a   8 pieces
    player_frame $03, $4772                            ; $e5  bank $6a   9 pieces
    player_frame $03, $479b                            ; $e6  bank $6a  10 pieces
    player_frame $03, $47c8                            ; $e7  bank $6a   8 pieces
    player_frame $03, $47ed                            ; $e8  bank $6a   8 pieces
    player_frame $04, $4000                            ; $e9  bank $6b   9 pieces
    player_frame $04, $4029                            ; $ea  bank $6b   9 pieces
    player_frame $04, $4052                            ; $eb  bank $6b   8 pieces
    player_frame $04, $4077                            ; $ec  bank $6b  10 pieces

data_7f_50b4_PlayerFrames_MarsupialMadness1:
; PLAYER_GFX_SET_MARSUPIAL_MADNESS1: 41 frames in bank $66, directory $50b4-$5131
; Used by Marsupial Madness 1, and by nothing else. Its frame list is a fraction of the
; size of a walking set's - 41 frames against 236 - which is what a level with a
; restricted move set needs, and what a level where Gex walks around does not
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $66   8 pieces
    player_frame $00, $4025                            ; $02  bank $66   9 pieces
    player_frame $00, $404e                            ; $03  bank $66   9 pieces
    player_frame $00, $4077                            ; $04  bank $66   9 pieces
    player_frame $00, $40a0                            ; $05  bank $66   8 pieces
    player_frame $00, $40c5                            ; $06  bank $66   9 pieces
    player_frame $00, $40ee                            ; $07  bank $66   6 pieces
    player_frame $00, $410b                            ; $08  bank $66   6 pieces
    player_frame $00, $4128                            ; $09  bank $66   4 pieces
    player_frame $00, $413d                            ; $0a  bank $66   3 pieces
    player_frame $00, $414e                            ; $0b  bank $66   2 pieces
    player_frame $00, $415b                            ; $0c  bank $66   8 pieces
    player_frame $00, $4180                            ; $0d  bank $66   7 pieces
    player_frame $00, $41a1                            ; $0e  bank $66   6 pieces
    player_frame $00, $41be                            ; $0f  bank $66   7 pieces
    player_frame $00, $41df                            ; $10  bank $66   7 pieces
    player_frame $00, $4200                            ; $11  bank $66   3 pieces
    player_frame $00, $4211                            ; $12  bank $66   2 pieces
    player_frame $00, $421e                            ; $13  bank $66   9 pieces
    player_frame $00, $4247                            ; $14  bank $66   7 pieces
    player_frame $00, $4268                            ; $15  bank $66   7 pieces
    player_frame $00, $4289                            ; $16  bank $66   7 pieces
    player_frame $00, $42aa                            ; $17  bank $66   8 pieces
    player_frame $00, $42cf                            ; $18  bank $66   7 pieces
    player_frame $00, $42f0                            ; $19  bank $66   7 pieces
    player_frame $00, $4311                            ; $1a  bank $66   7 pieces
    player_frame $00, $4332                            ; $1b  bank $66   7 pieces
    player_frame $00, $4353                            ; $1c  bank $66   7 pieces
    player_frame $00, $4374                            ; $1d  bank $66   6 pieces
    player_frame $00, $4391                            ; $1e  bank $66   7 pieces
    player_frame $00, $43b2                            ; $1f  bank $66   7 pieces
    player_frame $00, $43d3                            ; $20  bank $66   8 pieces
    player_frame $00, $43f8                            ; $21  bank $66   8 pieces
    player_frame $00, $441d                            ; $22  bank $66   7 pieces
    player_frame $00, $443e                            ; $23  bank $66   6 pieces
    player_frame $00, $445b                            ; $24  bank $66   6 pieces
    player_frame $00, $4478                            ; $25  bank $66   6 pieces
    player_frame $00, $4495                            ; $26  bank $66   8 pieces
    player_frame $00, $44ba                            ; $27  bank $66   8 pieces
    player_frame $00, $44df                            ; $28  bank $66   9 pieces
    player_frame $00, $4508                            ; $29  bank $66   8 pieces

data_7f_5132_PlayerFrames_AnimeChannel:
; PLAYER_GFX_SET_ANIME_CHANNEL: 236 frames in banks $62-$65, directory $5132-$53f8
; Used by Anime Channel 1-9
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame $00, $0000                            ; $00  no frame
    player_frame $00, $4000                            ; $01  bank $62   7 pieces
    player_frame $00, $4021                            ; $02  bank $62   7 pieces
    player_frame $00, $4042                            ; $03  bank $62   7 pieces
    player_frame $00, $4063                            ; $04  bank $62   7 pieces
    player_frame $00, $4084                            ; $05  bank $62   7 pieces
    player_frame $00, $40a5                            ; $06  bank $62   6 pieces
    player_frame $00, $40c2                            ; $07  bank $62   7 pieces
    player_frame $00, $40e3                            ; $08  bank $62   7 pieces
    player_frame $00, $4104                            ; $09  bank $62   7 pieces
    player_frame $00, $4125                            ; $0a  bank $62   7 pieces
    player_frame $00, $4146                            ; $0b  bank $62   7 pieces
    player_frame $00, $4167                            ; $0c  bank $62   7 pieces
    player_frame $00, $4188                            ; $0d  bank $62   6 pieces
    player_frame $00, $41a5                            ; $0e  bank $62   6 pieces
    player_frame $00, $41c2                            ; $0f  bank $62   7 pieces
    player_frame $00, $41e3                            ; $10  bank $62   7 pieces
    player_frame $00, $4204                            ; $11  bank $62   7 pieces
    player_frame $00, $4225                            ; $12  bank $62   7 pieces
    player_frame $00, $4246                            ; $13  bank $62   7 pieces
    player_frame $00, $4267                            ; $14  bank $62   8 pieces
    player_frame $00, $428c                            ; $15  bank $62   8 pieces
    player_frame $00, $42b1                            ; $16  bank $62   7 pieces
    player_frame $00, $42d2                            ; $17  bank $62   7 pieces
    player_frame $00, $42f3                            ; $18  bank $62   7 pieces
    player_frame $00, $4314                            ; $19  bank $62   8 pieces
    player_frame $00, $4339                            ; $1a  bank $62   8 pieces
    player_frame $00, $435e                            ; $1b  bank $62   8 pieces
    player_frame $00, $4383                            ; $1c  bank $62   7 pieces
    player_frame $00, $43a4                            ; $1d  bank $62   6 pieces
    player_frame $00, $43c1                            ; $1e  bank $62   7 pieces
    player_frame $00, $43e2                            ; $1f  bank $62   8 pieces
    player_frame $00, $4407                            ; $20  bank $62   6 pieces
    player_frame $00, $4424                            ; $21  bank $62   8 pieces
    player_frame $00, $4449                            ; $22  bank $62   7 pieces
    player_frame $00, $446a                            ; $23  bank $62   7 pieces
    player_frame $00, $448b                            ; $24  bank $62   6 pieces
    player_frame $00, $44a8                            ; $25  bank $62   5 pieces
    player_frame $00, $44c1                            ; $26  bank $62   5 pieces
    player_frame $00, $44da                            ; $27  bank $62   4 pieces
    player_frame $00, $44ef                            ; $28  bank $62   4 pieces
    player_frame $00, $4504                            ; $29  bank $62   4 pieces
    player_frame $00, $4519                            ; $2a  bank $62   7 pieces
    player_frame $00, $453a                            ; $2b  bank $62   6 pieces
    player_frame $00, $4557                            ; $2c  bank $62   6 pieces
    player_frame $00, $4574                            ; $2d  bank $62   6 pieces
    player_frame $00, $4591                            ; $2e  bank $62   7 pieces
    player_frame $00, $45b2                            ; $2f  bank $62   8 pieces
    player_frame $00, $45d7                            ; $30  bank $62   6 pieces
    player_frame $00, $45f4                            ; $31  bank $62   6 pieces
    player_frame $00, $4611                            ; $32  bank $62   8 pieces
    player_frame $00, $4636                            ; $33  bank $62   8 pieces
    player_frame $00, $465b                            ; $34  bank $62   9 pieces
    player_frame $00, $4684                            ; $35  bank $62   8 pieces
    player_frame $00, $46a9                            ; $36  bank $62   6 pieces
    player_frame $00, $46c6                            ; $37  bank $62   5 pieces
    player_frame $00, $46df                            ; $38  bank $62   6 pieces
    player_frame $00, $46fc                            ; $39  bank $62   6 pieces
    player_frame $00, $4719                            ; $3a  bank $62   5 pieces
    player_frame $00, $4732                            ; $3b  bank $62   6 pieces
    player_frame $00, $474f                            ; $3c  bank $62   6 pieces
    player_frame $00, $476c                            ; $3d  bank $62   5 pieces
    player_frame $00, $4785                            ; $3e  bank $62   5 pieces
    player_frame $00, $479e                            ; $3f  bank $62   6 pieces
    player_frame $00, $47bb                            ; $40  bank $62   7 pieces
    player_frame $00, $47dc                            ; $41  bank $62   8 pieces
    player_frame $00, $4801                            ; $42  bank $62   5 pieces
    player_frame $00, $481a                            ; $43  bank $62   6 pieces
    player_frame $01, $4000                            ; $44  bank $63   6 pieces
    player_frame $01, $401d                            ; $45  bank $63   6 pieces
    player_frame $01, $403a                            ; $46  bank $63   6 pieces
    player_frame $01, $4057                            ; $47  bank $63   6 pieces
    player_frame $01, $4074                            ; $48  bank $63   6 pieces
    player_frame $01, $4091                            ; $49  bank $63   6 pieces
    player_frame $01, $40ae                            ; $4a  bank $63   5 pieces
    player_frame $01, $40c7                            ; $4b  bank $63   6 pieces
    player_frame $01, $40e4                            ; $4c  bank $63   5 pieces
    player_frame $01, $40fd                            ; $4d  bank $63   6 pieces
    player_frame $01, $411a                            ; $4e  bank $63   6 pieces
    player_frame $01, $4137                            ; $4f  bank $63   5 pieces
    player_frame $01, $4150                            ; $50  bank $63   5 pieces
    player_frame $01, $4169                            ; $51  bank $63   6 pieces
    player_frame $01, $4186                            ; $52  bank $63   6 pieces
    player_frame $01, $41a3                            ; $53  bank $63   5 pieces
    player_frame $01, $41bc                            ; $54  bank $63   5 pieces
    player_frame $01, $41d5                            ; $55  bank $63   5 pieces
    player_frame $01, $41ee                            ; $56  bank $63   6 pieces
    player_frame $01, $420b                            ; $57  bank $63   6 pieces
    player_frame $01, $4228                            ; $58  bank $63   6 pieces
    player_frame $01, $4245                            ; $59  bank $63   6 pieces
    player_frame $01, $4262                            ; $5a  bank $63   5 pieces
    player_frame $01, $427b                            ; $5b  bank $63   4 pieces
    player_frame $01, $4290                            ; $5c  bank $63   4 pieces
    player_frame $01, $42a5                            ; $5d  bank $63   6 pieces
    player_frame $01, $42c2                            ; $5e  bank $63   7 pieces
    player_frame $01, $42e3                            ; $5f  bank $63   7 pieces
    player_frame $01, $4304                            ; $60  bank $63   6 pieces
    player_frame $01, $4321                            ; $61  bank $63   5 pieces
    player_frame $01, $433a                            ; $62  bank $63   7 pieces
    player_frame $01, $435b                            ; $63  bank $63   7 pieces
    player_frame $01, $437c                            ; $64  bank $63   7 pieces
    player_frame $01, $439d                            ; $65  bank $63   7 pieces
    player_frame $01, $43be                            ; $66  bank $63   6 pieces
    player_frame $01, $43db                            ; $67  bank $63   5 pieces
    player_frame $01, $43f4                            ; $68  bank $63   5 pieces
    player_frame $01, $440d                            ; $69  bank $63   6 pieces
    player_frame $01, $442a                            ; $6a  bank $63   6 pieces
    player_frame $01, $4447                            ; $6b  bank $63   6 pieces
    player_frame $01, $4464                            ; $6c  bank $63   5 pieces
    player_frame $01, $447d                            ; $6d  bank $63   6 pieces
    player_frame $01, $449a                            ; $6e  bank $63   6 pieces
    player_frame $01, $44b7                            ; $6f  bank $63   6 pieces
    player_frame $01, $44d4                            ; $70  bank $63   4 pieces
    player_frame $01, $44e9                            ; $71  bank $63   6 pieces
    player_frame $01, $4506                            ; $72  bank $63   6 pieces
    player_frame $01, $4523                            ; $73  bank $63   7 pieces
    player_frame $01, $4544                            ; $74  bank $63   7 pieces
    player_frame $01, $4565                            ; $75  bank $63   7 pieces
    player_frame $01, $4586                            ; $76  bank $63   7 pieces
    player_frame $01, $45a7                            ; $77  bank $63   7 pieces
    player_frame $01, $45c8                            ; $78  bank $63   7 pieces
    player_frame $01, $45e9                            ; $79  bank $63   7 pieces
    player_frame $01, $460a                            ; $7a  bank $63   7 pieces
    player_frame $01, $462b                            ; $7b  bank $63   7 pieces
    player_frame $01, $464c                            ; $7c  bank $63   8 pieces
    player_frame $01, $4671                            ; $7d  bank $63   4 pieces
    player_frame $01, $4686                            ; $7e  bank $63   4 pieces
    player_frame $01, $469b                            ; $7f  bank $63   4 pieces
    player_frame $01, $46b0                            ; $80  bank $63   4 pieces
    player_frame $01, $46c5                            ; $81  bank $63   4 pieces
    player_frame $01, $46da                            ; $82  bank $63   4 pieces
    player_frame $01, $46ef                            ; $83  bank $63   4 pieces
    player_frame $01, $4704                            ; $84  bank $63   6 pieces
    player_frame $01, $4721                            ; $85  bank $63   6 pieces
    player_frame $01, $473e                            ; $86  bank $63   6 pieces
    player_frame $01, $475b                            ; $87  bank $63   6 pieces
    player_frame $01, $4778                            ; $88  bank $63   5 pieces
    player_frame $01, $4791                            ; $89  bank $63   5 pieces
    player_frame $01, $47aa                            ; $8a  bank $63   6 pieces
    player_frame $01, $47c7                            ; $8b  bank $63   6 pieces
    player_frame $01, $47e4                            ; $8c  bank $63   5 pieces
    player_frame $01, $47fd                            ; $8d  bank $63   6 pieces
    player_frame $01, $481a                            ; $8e  bank $63   6 pieces
    player_frame $01, $4837                            ; $8f  bank $63   5 pieces
    player_frame $01, $4850                            ; $90  bank $63   5 pieces
    player_frame $02, $4000                            ; $91  bank $64   6 pieces
    player_frame $02, $401d                            ; $92  bank $64   6 pieces
    player_frame $02, $403a                            ; $93  bank $64   5 pieces
    player_frame $02, $4053                            ; $94  bank $64   6 pieces
    player_frame $02, $4070                            ; $95  bank $64   6 pieces
    player_frame $02, $408d                            ; $96  bank $64   5 pieces
    player_frame $02, $40a6                            ; $97  bank $64   5 pieces
    player_frame $02, $40bf                            ; $98  bank $64   6 pieces
    player_frame $02, $40dc                            ; $99  bank $64   6 pieces
    player_frame $02, $40f9                            ; $9a  bank $64   5 pieces
    player_frame $02, $4112                            ; $9b  bank $64   5 pieces
    player_frame $02, $412b                            ; $9c  bank $64   6 pieces
    player_frame $02, $4148                            ; $9d  bank $64   7 pieces
    player_frame $02, $4169                            ; $9e  bank $64   6 pieces
    player_frame $02, $4186                            ; $9f  bank $64   8 pieces
    player_frame $02, $41ab                            ; $a0  bank $64   8 pieces
    player_frame $02, $41d0                            ; $a1  bank $64   8 pieces
    player_frame $02, $41f5                            ; $a2  bank $64   9 pieces
    player_frame $02, $421e                            ; $a3  bank $64   8 pieces
    player_frame $02, $4243                            ; $a4  bank $64   7 pieces
    player_frame $02, $4264                            ; $a5  bank $64   5 pieces
    player_frame $02, $427d                            ; $a6  bank $64   4 pieces
    player_frame $02, $4292                            ; $a7  bank $64   3 pieces
    player_frame $02, $42a3                            ; $a8  bank $64   2 pieces
    player_frame $02, $42b0                            ; $a9  bank $64   5 pieces
    player_frame $02, $42c9                            ; $aa  bank $64   6 pieces
    player_frame $02, $42e6                            ; $ab  bank $64   5 pieces
    player_frame $02, $42ff                            ; $ac  bank $64   5 pieces
    player_frame $02, $4318                            ; $ad  bank $64   4 pieces
    player_frame $02, $432d                            ; $ae  bank $64   4 pieces
    player_frame $02, $4342                            ; $af  bank $64   3 pieces
    player_frame $02, $4353                            ; $b0  bank $64   2 pieces
    player_frame $02, $4360                            ; $b1  bank $64   2 pieces
    player_frame $02, $436d                            ; $b2  bank $64   5 pieces
    player_frame $02, $4386                            ; $b3  bank $64   5 pieces
    player_frame $02, $439f                            ; $b4  bank $64   5 pieces
    player_frame $02, $43b8                            ; $b5  bank $64   5 pieces
    player_frame $02, $43d1                            ; $b6  bank $64   6 pieces
    player_frame $02, $43ee                            ; $b7  bank $64   4 pieces
    player_frame $02, $4403                            ; $b8  bank $64   5 pieces
    player_frame $02, $441c                            ; $b9  bank $64   5 pieces
    player_frame $02, $4435                            ; $ba  bank $64   6 pieces
    player_frame $02, $4452                            ; $bb  bank $64   5 pieces
    player_frame $02, $446b                            ; $bc  bank $64   6 pieces
    player_frame $02, $4488                            ; $bd  bank $64   6 pieces
    player_frame $02, $44a5                            ; $be  bank $64   6 pieces
    player_frame $02, $44c2                            ; $bf  bank $64   6 pieces
    player_frame $02, $44df                            ; $c0  bank $64   5 pieces
    player_frame $02, $44f8                            ; $c1  bank $64   6 pieces
    player_frame $02, $4515                            ; $c2  bank $64   6 pieces
    player_frame $02, $4532                            ; $c3  bank $64   7 pieces
    player_frame $02, $4553                            ; $c4  bank $64   4 pieces
    player_frame $02, $4568                            ; $c5  bank $64   7 pieces
    player_frame $02, $4589                            ; $c6  bank $64   6 pieces
    player_frame $02, $45a6                            ; $c7  bank $64   6 pieces
    player_frame $02, $45c3                            ; $c8  bank $64   5 pieces
    player_frame $02, $45dc                            ; $c9  bank $64   6 pieces
    player_frame $02, $45f9                            ; $ca  bank $64   5 pieces
    player_frame $02, $4612                            ; $cb  bank $64   6 pieces
    player_frame $02, $462f                            ; $cc  bank $64   6 pieces
    player_frame $02, $464c                            ; $cd  bank $64   5 pieces
    player_frame $02, $4665                            ; $ce  bank $64   6 pieces
    player_frame $02, $4682                            ; $cf  bank $64   5 pieces
    player_frame $02, $469b                            ; $d0  bank $64   5 pieces
    player_frame $02, $46b4                            ; $d1  bank $64   5 pieces
    player_frame $02, $46cd                            ; $d2  bank $64   6 pieces
    player_frame $02, $46ea                            ; $d3  bank $64   9 pieces
    player_frame $02, $4713                            ; $d4  bank $64   8 pieces
    player_frame $02, $4738                            ; $d5  bank $64   6 pieces
    player_frame $02, $4755                            ; $d6  bank $64   5 pieces
    player_frame $02, $476e                            ; $d7  bank $64   7 pieces
    player_frame $02, $478f                            ; $d8  bank $64   8 pieces
    player_frame $02, $47b4                            ; $d9  bank $64   7 pieces
    player_frame $02, $47d5                            ; $da  bank $64   7 pieces
    player_frame $02, $47f6                            ; $db  bank $64   7 pieces
    player_frame $02, $4817                            ; $dc  bank $64   7 pieces
    player_frame $02, $4838                            ; $dd  bank $64   6 pieces
    player_frame $02, $4855                            ; $de  bank $64   6 pieces
    player_frame $03, $4000                            ; $df  bank $65   7 pieces
    player_frame $03, $4021                            ; $e0  bank $65   8 pieces
    player_frame $03, $4046                            ; $e1  bank $65   7 pieces
    player_frame $03, $4067                            ; $e2  bank $65   6 pieces
    player_frame $03, $4084                            ; $e3  bank $65   6 pieces
    player_frame $03, $40a1                            ; $e4  bank $65   7 pieces
    player_frame $03, $40c2                            ; $e5  bank $65   8 pieces
    player_frame $03, $40e7                            ; $e6  bank $65   7 pieces
    player_frame $03, $4108                            ; $e7  bank $65   6 pieces
    player_frame $03, $4125                            ; $e8  bank $65   8 pieces
    player_frame $03, $414a                            ; $e9  bank $65   8 pieces
    player_frame $03, $416f                            ; $ea  bank $65   7 pieces
    player_frame $03, $4190                            ; $eb  bank $65   6 pieces
    player_frame $03, $41ad                            ; $ec  bank $65   8 pieces

data_7f_53f9_MapObjPalettes_GexCave:
; OBJ palettes for Gex Cave 1-4, WW Gex Wrestling 1, Lizard of Oz 1, Channel Z 1-5
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $7fff, CGB_COLOR_UNUSED, CGB_COLOR_UNUSED   ; palette 1 - entity slot 1's default
; Palettes 2-7. Never read: call_00_2cbf_Entity_LoadMapPalettes stops after
; CGB_PALETTE_SIZE * 2 bytes, and every block in the file has the same six
; unfilled palettes here
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5439_MapObjPalettes_HolidayTV:
; OBJ palettes for Holiday TV 1-4, Gextreme Sports 2-4
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $7fff, $0000, $7d8a                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5479_MapObjPalettes_MysteryTV:
; OBJ palettes for Mystery TV 1-10
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $7fff, $0180, $0000                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_54b9_MapObjPalettes_TutTV:
; OBJ palettes for Tut TV 1-7
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $03ff, $0000, $7ca0                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_54f9_MapObjPalettes_SuperheroShow:
; OBJ palettes for Superhero Show 1-6
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $0000, $211f, $7d6b                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5539_MapObjPalettes_GextremeSports1:
; OBJ palettes for Gextreme Sports 1
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $7fff, $0000, $7d8a                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5579_MapObjPalettes_WesternStation:
; OBJ palettes for Western Station 1-9
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $0174, $0000, $001f                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_55b9_MapObjPalettes_MarsupialMadness1:
; OBJ palettes for Marsupial Madness 1
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $0000, $0151, $027b                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_55f9_MapObjPalettes_AnimeChannel:
; OBJ palettes for Anime Channel 1-9
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex
    dw   CGB_COLOR_UNUSED, $7e0f, $0000, $7f7a                         ; palette 1 - entity slot 1's default
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR
