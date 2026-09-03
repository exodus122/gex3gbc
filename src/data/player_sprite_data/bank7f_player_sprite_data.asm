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
;   +1 +2  read by nothing. They are small - 3 to 41 and 4 to 48 across the game -
;          which is the right range for a width and a height in pixels, but they do
;          not match the frame's own piece extents, so what they described is unknown
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
;   palette 1   Gex's SECOND palette, and the only per-set colour in the file. A
;               piece's attribute byte is OR'd into wDC53_Player_OamAttributes on the
;               way into OAM, and across all 11005 pieces in the game the only value
;               other than zero is 1 - the CGB OBJ palette number. About 40% of his
;               pieces select it, which is how one silhouette gets a per-theme
;               recolour. Note that OBJ palette 1 is also what
;               call_03_687c_AssignEntityPalette hands to entity slot 1, so an entity
;               in that slot draws over it
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
    db   BANK(data_7c_4000_PlayerFrame_001)        ; set 0 base bank
    dw   data_7f_406a_PlayerFrames_GexCave
data_7f_4040_PlayerGfx_SetPalettes:
; The palette field of record 0, and the base every OBJ palette lookup adds its
; map offset to. Reached only by call_00_2cbf_Entity_LoadMapPalettes
    dw   data_7f_53f9_MapObjPalettes_GexCave        ; set 0 palettes
    player_gfx_set data_79_4000_PlayerFrame_001,                  data_7f_4331_PlayerFrames_HolidayTV,           data_7f_5439_MapObjPalettes_HolidayTV                  ; set 1 - Holiday TV 1-4, Gextreme Sports 2-4
    player_gfx_set data_76_4000_PlayerFrame_001,                  data_7f_4586_PlayerFrames_MysteryTV,           data_7f_5479_MapObjPalettes_MysteryTV                  ; set 2 - Mystery TV 1-10
    player_gfx_set data_72_4000_PlayerFrame_001,                  data_7f_47db_PlayerFrames_TutTV,               data_7f_54b9_MapObjPalettes_TutTV                          ; set 3 - Tut TV 1-7
    player_gfx_set data_6e_4000_PlayerFrame_001,                  data_7f_4a30_PlayerFrames_SuperheroShow,       data_7f_54f9_MapObjPalettes_SuperheroShow          ; set 4 - Superhero Show 1-6
    player_gfx_set data_6c_4000_PlayerFrame_001,                  data_7f_4cf7_PlayerFrames_GextremeSports1,     data_7f_5539_MapObjPalettes_GextremeSports1      ; set 5 - Gextreme Sports 1
    player_gfx_set data_67_4000_PlayerFrame_001,                  data_7f_4ded_PlayerFrames_WesternStation,      data_7f_5579_MapObjPalettes_WesternStation        ; set 6 - Western Station 1-9
    player_gfx_set data_66_4000_PlayerFrame_001,                  data_7f_50b4_PlayerFrames_MarsupialMadness1,   data_7f_55b9_MapObjPalettes_MarsupialMadness1  ; set 7 - Marsupial Madness 1
    player_gfx_set data_62_4000_PlayerFrame_001,                  data_7f_5132_PlayerFrames_AnimeChannel,        data_7f_55f9_MapObjPalettes_AnimeChannel            ; set 8 - Anime Channel 1-9

data_7f_406a_PlayerFrames_GexCave:
    DEF PLAYER_GFX_SET_BASE = BANK(data_7c_4000_PlayerFrame_001)
; PLAYER_GFX_SET_GEX_CAVE: 236 frames in banks $7c-$7e, directory $406a-$4330
; Used by Gex Cave 1-4, WW Gex Wrestling 1, Lizard of Oz 1, Channel Z 1-5
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_7c_4000_PlayerFrame_001                ; $01  bank $7c   7 pieces
    player_frame data_7c_4021_PlayerFrame_002                ; $02  bank $7c   7 pieces
    player_frame data_7c_4042_PlayerFrame_003                ; $03  bank $7c   6 pieces
    player_frame data_7c_405f_PlayerFrame_004                ; $04  bank $7c   7 pieces
    player_frame data_7c_4080_PlayerFrame_005                ; $05  bank $7c   7 pieces
    player_frame data_7c_40a1_PlayerFrame_006                ; $06  bank $7c   7 pieces
    player_frame data_7c_40c2_PlayerFrame_007                ; $07  bank $7c   7 pieces
    player_frame data_7c_40e3_PlayerFrame_008                ; $08  bank $7c   7 pieces
    player_frame data_7c_4104_PlayerFrame_009                ; $09  bank $7c   7 pieces
    player_frame data_7c_4125_PlayerFrame_010                ; $0a  bank $7c   7 pieces
    player_frame data_7c_4146_PlayerFrame_011                ; $0b  bank $7c   7 pieces
    player_frame data_7c_4167_PlayerFrame_012                ; $0c  bank $7c   7 pieces
    player_frame data_7c_4188_PlayerFrame_013                ; $0d  bank $7c   6 pieces
    player_frame data_7c_41a5_PlayerFrame_014                ; $0e  bank $7c   7 pieces
    player_frame data_7c_41c6_PlayerFrame_015                ; $0f  bank $7c   7 pieces
    player_frame data_7c_41e7_PlayerFrame_016                ; $10  bank $7c   7 pieces
    player_frame data_7c_4208_PlayerFrame_017                ; $11  bank $7c   7 pieces
    player_frame data_7c_4229_PlayerFrame_018                ; $12  bank $7c   6 pieces
    player_frame data_7c_4246_PlayerFrame_019                ; $13  bank $7c   7 pieces
    player_frame data_7c_4267_PlayerFrame_020                ; $14  bank $7c   8 pieces
    player_frame data_7c_428c_PlayerFrame_021                ; $15  bank $7c   8 pieces
    player_frame data_7c_42b1_PlayerFrame_022                ; $16  bank $7c   7 pieces
    player_frame data_7c_42d2_PlayerFrame_023                ; $17  bank $7c   7 pieces
    player_frame data_7c_42f3_PlayerFrame_024                ; $18  bank $7c   7 pieces
    player_frame data_7c_4314_PlayerFrame_025                ; $19  bank $7c   7 pieces
    player_frame data_7c_4335_PlayerFrame_026                ; $1a  bank $7c   7 pieces
    player_frame data_7c_4356_PlayerFrame_027                ; $1b  bank $7c   7 pieces
    player_frame data_7c_4377_PlayerFrame_028                ; $1c  bank $7c   6 pieces
    player_frame data_7c_4394_PlayerFrame_029                ; $1d  bank $7c   6 pieces
    player_frame data_7c_43b1_PlayerFrame_030                ; $1e  bank $7c   6 pieces
    player_frame data_7c_43ce_PlayerFrame_031                ; $1f  bank $7c   7 pieces
    player_frame data_7c_43ef_PlayerFrame_032                ; $20  bank $7c   7 pieces
    player_frame data_7c_4410_PlayerFrame_033                ; $21  bank $7c   6 pieces
    player_frame data_7c_442d_PlayerFrame_034                ; $22  bank $7c   6 pieces
    player_frame data_7c_444a_PlayerFrame_035                ; $23  bank $7c   6 pieces
    player_frame data_7c_4467_PlayerFrame_036                ; $24  bank $7c   6 pieces
    player_frame data_7c_4484_PlayerFrame_037                ; $25  bank $7c   5 pieces
    player_frame data_7c_449d_PlayerFrame_038                ; $26  bank $7c   5 pieces
    player_frame data_7c_44b6_PlayerFrame_039                ; $27  bank $7c   3 pieces
    player_frame data_7c_44c7_PlayerFrame_040                ; $28  bank $7c   3 pieces
    player_frame data_7c_44d8_PlayerFrame_041                ; $29  bank $7c   3 pieces
    player_frame data_7c_44e9_PlayerFrame_042                ; $2a  bank $7c   7 pieces
    player_frame data_7c_450a_PlayerFrame_043                ; $2b  bank $7c   6 pieces
    player_frame data_7c_4527_PlayerFrame_044                ; $2c  bank $7c   5 pieces
    player_frame data_7c_4540_PlayerFrame_045                ; $2d  bank $7c   6 pieces
    player_frame data_7c_455d_PlayerFrame_046                ; $2e  bank $7c   7 pieces
    player_frame data_7c_457e_PlayerFrame_047                ; $2f  bank $7c   7 pieces
    player_frame data_7c_459f_PlayerFrame_048                ; $30  bank $7c   6 pieces
    player_frame data_7c_45bc_PlayerFrame_049                ; $31  bank $7c   6 pieces
    player_frame data_7c_45d9_PlayerFrame_050                ; $32  bank $7c   6 pieces
    player_frame data_7c_45f6_PlayerFrame_051                ; $33  bank $7c   6 pieces
    player_frame data_7c_4613_PlayerFrame_052                ; $34  bank $7c   7 pieces
    player_frame data_7c_4634_PlayerFrame_053                ; $35  bank $7c   7 pieces
    player_frame data_7c_4655_PlayerFrame_054                ; $36  bank $7c   5 pieces
    player_frame data_7c_466e_PlayerFrame_055                ; $37  bank $7c   5 pieces
    player_frame data_7c_4687_PlayerFrame_056                ; $38  bank $7c   5 pieces
    player_frame data_7c_46a0_PlayerFrame_057                ; $39  bank $7c   6 pieces
    player_frame data_7c_46bd_PlayerFrame_058                ; $3a  bank $7c   5 pieces
    player_frame data_7c_46d6_PlayerFrame_059                ; $3b  bank $7c   5 pieces
    player_frame data_7c_46ef_PlayerFrame_060                ; $3c  bank $7c   5 pieces
    player_frame data_7c_4708_PlayerFrame_061                ; $3d  bank $7c   5 pieces
    player_frame data_7c_4721_PlayerFrame_062                ; $3e  bank $7c   5 pieces
    player_frame data_7c_473a_PlayerFrame_063                ; $3f  bank $7c   6 pieces
    player_frame data_7c_4757_PlayerFrame_064                ; $40  bank $7c   7 pieces
    player_frame data_7c_4778_PlayerFrame_065                ; $41  bank $7c   6 pieces
    player_frame data_7c_4795_PlayerFrame_066                ; $42  bank $7c   6 pieces
    player_frame data_7c_47b2_PlayerFrame_067                ; $43  bank $7c   5 pieces
    player_frame data_7c_47cb_PlayerFrame_068                ; $44  bank $7c   5 pieces
    player_frame data_7c_47e4_PlayerFrame_069                ; $45  bank $7c   5 pieces
    player_frame data_7c_47fd_PlayerFrame_070                ; $46  bank $7c   5 pieces
    player_frame data_7c_4816_PlayerFrame_071                ; $47  bank $7c   5 pieces
    player_frame data_7c_482f_PlayerFrame_072                ; $48  bank $7c   6 pieces
    player_frame data_7d_4000_PlayerFrame_073                ; $49  bank $7d   6 pieces
    player_frame data_7d_401d_PlayerFrame_074                ; $4a  bank $7d   5 pieces
    player_frame data_7d_4036_PlayerFrame_075                ; $4b  bank $7d   6 pieces
    player_frame data_7d_4053_PlayerFrame_076                ; $4c  bank $7d   5 pieces
    player_frame data_7d_406c_PlayerFrame_077                ; $4d  bank $7d   6 pieces
    player_frame data_7d_4089_PlayerFrame_078                ; $4e  bank $7d   6 pieces
    player_frame data_7d_40a6_PlayerFrame_079                ; $4f  bank $7d   7 pieces
    player_frame data_7d_40c7_PlayerFrame_080                ; $50  bank $7d   6 pieces
    player_frame data_7d_40e4_PlayerFrame_081                ; $51  bank $7d   6 pieces
    player_frame data_7d_4101_PlayerFrame_082                ; $52  bank $7d   7 pieces
    player_frame data_7d_4122_PlayerFrame_083                ; $53  bank $7d   7 pieces
    player_frame data_7d_4143_PlayerFrame_084                ; $54  bank $7d   5 pieces
    player_frame data_7d_415c_PlayerFrame_085                ; $55  bank $7d   5 pieces
    player_frame data_7d_4175_PlayerFrame_086                ; $56  bank $7d   6 pieces
    player_frame data_7d_4192_PlayerFrame_087                ; $57  bank $7d   6 pieces
    player_frame data_7d_41af_PlayerFrame_088                ; $58  bank $7d   6 pieces
    player_frame data_7d_41cc_PlayerFrame_089                ; $59  bank $7d   6 pieces
    player_frame data_7d_41e9_PlayerFrame_090                ; $5a  bank $7d   5 pieces
    player_frame data_7d_4202_PlayerFrame_091                ; $5b  bank $7d   4 pieces
    player_frame data_7d_4217_PlayerFrame_092                ; $5c  bank $7d   4 pieces
    player_frame data_7d_422c_PlayerFrame_093                ; $5d  bank $7d   6 pieces
    player_frame data_7d_4249_PlayerFrame_094                ; $5e  bank $7d   6 pieces
    player_frame data_7d_4266_PlayerFrame_095                ; $5f  bank $7d   6 pieces
    player_frame data_7d_4283_PlayerFrame_096                ; $60  bank $7d   5 pieces
    player_frame data_7d_429c_PlayerFrame_097                ; $61  bank $7d   5 pieces
    player_frame data_7d_42b5_PlayerFrame_098                ; $62  bank $7d   6 pieces
    player_frame data_7d_42d2_PlayerFrame_099                ; $63  bank $7d   6 pieces
    player_frame data_7d_42ef_PlayerFrame_100                ; $64  bank $7d   6 pieces
    player_frame data_7d_430c_PlayerFrame_101                ; $65  bank $7d   6 pieces
    player_frame data_7d_4329_PlayerFrame_102                ; $66  bank $7d   6 pieces
    player_frame data_7d_4346_PlayerFrame_103                ; $67  bank $7d   5 pieces
    player_frame data_7d_435f_PlayerFrame_104                ; $68  bank $7d   5 pieces
    player_frame data_7d_4378_PlayerFrame_105                ; $69  bank $7d   6 pieces
    player_frame data_7d_4395_PlayerFrame_106                ; $6a  bank $7d   6 pieces
    player_frame data_7d_43b2_PlayerFrame_107                ; $6b  bank $7d   6 pieces
    player_frame data_7d_43cf_PlayerFrame_108                ; $6c  bank $7d   5 pieces
    player_frame data_7d_43e8_PlayerFrame_109                ; $6d  bank $7d   6 pieces
    player_frame data_7d_4405_PlayerFrame_110                ; $6e  bank $7d   6 pieces
    player_frame data_7d_4422_PlayerFrame_111                ; $6f  bank $7d   6 pieces
    player_frame data_7d_443f_PlayerFrame_112                ; $70  bank $7d   4 pieces
    player_frame data_7d_4454_PlayerFrame_113                ; $71  bank $7d   6 pieces
    player_frame data_7d_4471_PlayerFrame_114                ; $72  bank $7d   6 pieces
    player_frame data_7d_448e_PlayerFrame_115                ; $73  bank $7d   6 pieces
    player_frame data_7d_44ab_PlayerFrame_116                ; $74  bank $7d   5 pieces
    player_frame data_7d_44c4_PlayerFrame_117                ; $75  bank $7d   6 pieces
    player_frame data_7d_44e1_PlayerFrame_118                ; $76  bank $7d   5 pieces
    player_frame data_7d_44fa_PlayerFrame_119                ; $77  bank $7d   6 pieces
    player_frame data_7d_4517_PlayerFrame_120                ; $78  bank $7d   5 pieces
    player_frame data_7d_4530_PlayerFrame_121                ; $79  bank $7d   5 pieces
    player_frame data_7d_4549_PlayerFrame_122                ; $7a  bank $7d   6 pieces
    player_frame data_7d_4566_PlayerFrame_123                ; $7b  bank $7d   5 pieces
    player_frame data_7d_457f_PlayerFrame_124                ; $7c  bank $7d   6 pieces
    player_frame data_7d_459c_PlayerFrame_125                ; $7d  bank $7d   4 pieces
    player_frame data_7d_45b1_PlayerFrame_126                ; $7e  bank $7d   4 pieces
    player_frame data_7d_45c6_PlayerFrame_127                ; $7f  bank $7d   4 pieces
    player_frame data_7d_45db_PlayerFrame_128                ; $80  bank $7d   4 pieces
    player_frame data_7d_45f0_PlayerFrame_129                ; $81  bank $7d   4 pieces
    player_frame data_7d_4605_PlayerFrame_130                ; $82  bank $7d   4 pieces
    player_frame data_7d_461a_PlayerFrame_131                ; $83  bank $7d   4 pieces
    player_frame data_7d_462f_PlayerFrame_132                ; $84  bank $7d   5 pieces
    player_frame data_7d_4648_PlayerFrame_133                ; $85  bank $7d   5 pieces
    player_frame data_7d_4661_PlayerFrame_134                ; $86  bank $7d   5 pieces
    player_frame data_7d_467a_PlayerFrame_135                ; $87  bank $7d   6 pieces
    player_frame data_7d_4697_PlayerFrame_136                ; $88  bank $7d   5 pieces
    player_frame data_7d_46b0_PlayerFrame_137                ; $89  bank $7d   5 pieces
    player_frame data_7d_46c9_PlayerFrame_138                ; $8a  bank $7d   6 pieces
    player_frame data_7d_46e6_PlayerFrame_139                ; $8b  bank $7d   5 pieces
    player_frame data_7d_46ff_PlayerFrame_140                ; $8c  bank $7d   5 pieces
    player_frame data_7d_4718_PlayerFrame_141                ; $8d  bank $7d   5 pieces
    player_frame data_7d_4731_PlayerFrame_142                ; $8e  bank $7d   5 pieces
    player_frame data_7d_474a_PlayerFrame_143                ; $8f  bank $7d   5 pieces
    player_frame data_7d_4763_PlayerFrame_144                ; $90  bank $7d   5 pieces
    player_frame data_7d_477c_PlayerFrame_145                ; $91  bank $7d   5 pieces
    player_frame data_7d_4795_PlayerFrame_146                ; $92  bank $7d   5 pieces
    player_frame data_7d_47ae_PlayerFrame_147                ; $93  bank $7d   5 pieces
    player_frame data_7d_47c7_PlayerFrame_148                ; $94  bank $7d   5 pieces
    player_frame data_7d_47e0_PlayerFrame_149                ; $95  bank $7d   4 pieces
    player_frame data_7d_47f5_PlayerFrame_150                ; $96  bank $7d   4 pieces
    player_frame data_7d_480a_PlayerFrame_151                ; $97  bank $7d   4 pieces
    player_frame data_7d_481f_PlayerFrame_152                ; $98  bank $7d   4 pieces
    player_frame data_7d_4834_PlayerFrame_153                ; $99  bank $7d   4 pieces
    player_frame data_7d_4849_PlayerFrame_154                ; $9a  bank $7d   4 pieces
    player_frame data_7d_485e_PlayerFrame_155                ; $9b  bank $7d   4 pieces
    player_frame data_7d_4873_PlayerFrame_156                ; $9c  bank $7d   4 pieces
    player_frame data_7e_4000_PlayerFrame_157                ; $9d  bank $7e   6 pieces
    player_frame data_7e_401d_PlayerFrame_158                ; $9e  bank $7e   5 pieces
    player_frame data_7e_4036_PlayerFrame_159                ; $9f  bank $7e   7 pieces
    player_frame data_7e_4057_PlayerFrame_160                ; $a0  bank $7e   7 pieces
    player_frame data_7e_4078_PlayerFrame_161                ; $a1  bank $7e   8 pieces
    player_frame data_7e_409d_PlayerFrame_162                ; $a2  bank $7e   9 pieces
    player_frame data_7e_40c6_PlayerFrame_163                ; $a3  bank $7e   8 pieces
    player_frame data_7e_40eb_PlayerFrame_164                ; $a4  bank $7e   7 pieces
    player_frame data_7e_410c_PlayerFrame_165                ; $a5  bank $7e   6 pieces
    player_frame data_7e_4129_PlayerFrame_166                ; $a6  bank $7e   4 pieces
    player_frame data_7e_413e_PlayerFrame_167                ; $a7  bank $7e   3 pieces
    player_frame data_7e_414f_PlayerFrame_168                ; $a8  bank $7e   2 pieces
    player_frame data_7e_415c_PlayerFrame_169                ; $a9  bank $7e   5 pieces
    player_frame data_7e_4175_PlayerFrame_170                ; $aa  bank $7e   5 pieces
    player_frame data_7e_418e_PlayerFrame_171                ; $ab  bank $7e   4 pieces
    player_frame data_7e_41a3_PlayerFrame_172                ; $ac  bank $7e   4 pieces
    player_frame data_7e_41b8_PlayerFrame_173                ; $ad  bank $7e   4 pieces
    player_frame data_7e_41cd_PlayerFrame_174                ; $ae  bank $7e   3 pieces
    player_frame data_7e_41de_PlayerFrame_175                ; $af  bank $7e   3 pieces
    player_frame data_7e_41ef_PlayerFrame_176                ; $b0  bank $7e   2 pieces
    player_frame data_7e_41fc_PlayerFrame_177                ; $b1  bank $7e   2 pieces
    player_frame data_7e_4209_PlayerFrame_178                ; $b2  bank $7e   5 pieces
    player_frame data_7e_4222_PlayerFrame_179                ; $b3  bank $7e   5 pieces
    player_frame data_7e_423b_PlayerFrame_180                ; $b4  bank $7e   5 pieces
    player_frame data_7e_4254_PlayerFrame_181                ; $b5  bank $7e   5 pieces
    player_frame data_7e_426d_PlayerFrame_182                ; $b6  bank $7e   6 pieces
    player_frame data_7e_428a_PlayerFrame_183                ; $b7  bank $7e   5 pieces
    player_frame data_7e_42a3_PlayerFrame_184                ; $b8  bank $7e   5 pieces
    player_frame data_7e_42bc_PlayerFrame_185                ; $b9  bank $7e   6 pieces
    player_frame data_7e_42d9_PlayerFrame_186                ; $ba  bank $7e   7 pieces
    player_frame data_7e_42fa_PlayerFrame_187                ; $bb  bank $7e   6 pieces
    player_frame data_7e_4317_PlayerFrame_188                ; $bc  bank $7e   6 pieces
    player_frame data_7e_4334_PlayerFrame_189                ; $bd  bank $7e   6 pieces
    player_frame data_7e_4351_PlayerFrame_190                ; $be  bank $7e   6 pieces
    player_frame data_7e_436e_PlayerFrame_191                ; $bf  bank $7e   6 pieces
    player_frame data_7e_438b_PlayerFrame_192                ; $c0  bank $7e   5 pieces
    player_frame data_7e_43a4_PlayerFrame_193                ; $c1  bank $7e   6 pieces
    player_frame data_7e_43c1_PlayerFrame_194                ; $c2  bank $7e   6 pieces
    player_frame data_7e_43de_PlayerFrame_195                ; $c3  bank $7e   7 pieces
    player_frame data_7e_43ff_PlayerFrame_196                ; $c4  bank $7e   4 pieces
    player_frame data_7e_4414_PlayerFrame_197                ; $c5  bank $7e   7 pieces
    player_frame data_7e_4435_PlayerFrame_198                ; $c6  bank $7e   6 pieces
    player_frame data_7e_4452_PlayerFrame_199                ; $c7  bank $7e   5 pieces
    player_frame data_7e_446b_PlayerFrame_200                ; $c8  bank $7e   5 pieces
    player_frame data_7e_4484_PlayerFrame_201                ; $c9  bank $7e   6 pieces
    player_frame data_7e_44a1_PlayerFrame_202                ; $ca  bank $7e   5 pieces
    player_frame data_7e_44ba_PlayerFrame_203                ; $cb  bank $7e   5 pieces
    player_frame data_7e_44d3_PlayerFrame_204                ; $cc  bank $7e   6 pieces
    player_frame data_7e_44f0_PlayerFrame_205                ; $cd  bank $7e   5 pieces
    player_frame data_7e_4509_PlayerFrame_206                ; $ce  bank $7e   5 pieces
    player_frame data_7e_4522_PlayerFrame_207                ; $cf  bank $7e   5 pieces
    player_frame data_7e_453b_PlayerFrame_208                ; $d0  bank $7e   5 pieces
    player_frame data_7e_4554_PlayerFrame_209                ; $d1  bank $7e   6 pieces
    player_frame data_7e_4571_PlayerFrame_210                ; $d2  bank $7e   5 pieces
    player_frame data_7e_458a_PlayerFrame_211                ; $d3  bank $7e   6 pieces
    player_frame data_7e_45a7_PlayerFrame_212                ; $d4  bank $7e   7 pieces
    player_frame data_7e_45c8_PlayerFrame_213                ; $d5  bank $7e   4 pieces
    player_frame data_7e_45dd_PlayerFrame_214                ; $d6  bank $7e   5 pieces
    player_frame data_7e_45f6_PlayerFrame_215                ; $d7  bank $7e   6 pieces
    player_frame data_7e_4613_PlayerFrame_216                ; $d8  bank $7e   6 pieces
    player_frame data_7e_4630_PlayerFrame_217                ; $d9  bank $7e   5 pieces
    player_frame data_7e_4649_PlayerFrame_218                ; $da  bank $7e   5 pieces
    player_frame data_7e_4662_PlayerFrame_219                ; $db  bank $7e   6 pieces
    player_frame data_7e_467f_PlayerFrame_220                ; $dc  bank $7e   5 pieces
    player_frame data_7e_4698_PlayerFrame_221                ; $dd  bank $7e   5 pieces
    player_frame data_7e_46b1_PlayerFrame_222                ; $de  bank $7e   5 pieces
    player_frame data_7e_46ca_PlayerFrame_223                ; $df  bank $7e   5 pieces
    player_frame data_7e_46e3_PlayerFrame_224                ; $e0  bank $7e   7 pieces
    player_frame data_7e_4704_PlayerFrame_225                ; $e1  bank $7e   5 pieces
    player_frame data_7e_471d_PlayerFrame_226                ; $e2  bank $7e   5 pieces
    player_frame data_7e_4736_PlayerFrame_227                ; $e3  bank $7e   5 pieces
    player_frame data_7e_474f_PlayerFrame_228                ; $e4  bank $7e   5 pieces
    player_frame data_7e_4768_PlayerFrame_229                ; $e5  bank $7e   6 pieces
    player_frame data_7e_4785_PlayerFrame_230                ; $e6  bank $7e   6 pieces
    player_frame data_7e_47a2_PlayerFrame_231                ; $e7  bank $7e   5 pieces
    player_frame data_7e_47bb_PlayerFrame_232                ; $e8  bank $7e   5 pieces
    player_frame data_7e_47d4_PlayerFrame_233                ; $e9  bank $7e   6 pieces
    player_frame data_7e_47f1_PlayerFrame_234                ; $ea  bank $7e   6 pieces
    player_frame data_7e_480e_PlayerFrame_235                ; $eb  bank $7e   5 pieces
    player_frame data_7e_4827_PlayerFrame_236                ; $ec  bank $7e   6 pieces

data_7f_4331_PlayerFrames_HolidayTV:
    DEF PLAYER_GFX_SET_BASE = BANK(data_79_4000_PlayerFrame_001)
; PLAYER_GFX_SET_HOLIDAY_TV: 198 frames in banks $79-$7b, directory $4331-$4585
; Used by Holiday TV 1-4, Gextreme Sports 2-4
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_79_4000_PlayerFrame_001                ; $01  bank $79   9 pieces
    player_frame data_79_4029_PlayerFrame_002                ; $02  bank $79  10 pieces
    player_frame data_79_4056_PlayerFrame_003                ; $03  bank $79   8 pieces
    player_frame data_79_407b_PlayerFrame_004                ; $04  bank $79   8 pieces
    player_frame data_79_40a0_PlayerFrame_005                ; $05  bank $79   8 pieces
    player_frame data_79_40c5_PlayerFrame_006                ; $06  bank $79   7 pieces
    player_frame data_79_40e6_PlayerFrame_007                ; $07  bank $79   8 pieces
    player_frame data_79_410b_PlayerFrame_008                ; $08  bank $79   9 pieces
    player_frame data_79_4134_PlayerFrame_009                ; $09  bank $79   9 pieces
    player_frame data_79_415d_PlayerFrame_010                ; $0a  bank $79  10 pieces
    player_frame data_79_418a_PlayerFrame_011                ; $0b  bank $79   9 pieces
    player_frame data_79_41b3_PlayerFrame_012                ; $0c  bank $79   8 pieces
    player_frame data_79_41d8_PlayerFrame_013                ; $0d  bank $79   8 pieces
    player_frame data_79_41fd_PlayerFrame_014                ; $0e  bank $79   7 pieces
    player_frame data_79_421e_PlayerFrame_015                ; $0f  bank $79   8 pieces
    player_frame data_79_4243_PlayerFrame_016                ; $10  bank $79  10 pieces
    player_frame data_79_4270_PlayerFrame_017                ; $11  bank $79  10 pieces
    player_frame data_79_429d_PlayerFrame_018                ; $12  bank $79   8 pieces
    player_frame data_79_42c2_PlayerFrame_019                ; $13  bank $79   9 pieces
    player_frame data_79_42eb_PlayerFrame_020                ; $14  bank $79  10 pieces
    player_frame data_79_4318_PlayerFrame_021                ; $15  bank $79  10 pieces
    player_frame data_79_4345_PlayerFrame_022                ; $16  bank $79   8 pieces
    player_frame data_79_436a_PlayerFrame_023                ; $17  bank $79   8 pieces
    player_frame data_79_438f_PlayerFrame_024                ; $18  bank $79   9 pieces
    player_frame data_79_43b8_PlayerFrame_025                ; $19  bank $79   8 pieces
    player_frame data_79_43dd_PlayerFrame_026                ; $1a  bank $79   8 pieces
    player_frame data_79_4402_PlayerFrame_027                ; $1b  bank $79   8 pieces
    player_frame data_79_4427_PlayerFrame_028                ; $1c  bank $79   9 pieces
    player_frame data_79_4450_PlayerFrame_029                ; $1d  bank $79   8 pieces
    player_frame data_79_4475_PlayerFrame_030                ; $1e  bank $79   8 pieces
    player_frame data_79_449a_PlayerFrame_031                ; $1f  bank $79   8 pieces
    player_frame data_79_44bf_PlayerFrame_032                ; $20  bank $79   7 pieces
    player_frame data_79_44e0_PlayerFrame_033                ; $21  bank $79   8 pieces
    player_frame data_79_4505_PlayerFrame_034                ; $22  bank $79   7 pieces
    player_frame data_79_4526_PlayerFrame_035                ; $23  bank $79   6 pieces
    player_frame data_79_4543_PlayerFrame_036                ; $24  bank $79   7 pieces
    player_frame data_79_4564_PlayerFrame_037                ; $25  bank $79   6 pieces
    player_frame data_79_4581_PlayerFrame_038                ; $26  bank $79   5 pieces
    player_frame data_79_459a_PlayerFrame_039                ; $27  bank $79   4 pieces
    player_frame data_79_45af_PlayerFrame_040                ; $28  bank $79   4 pieces
    player_frame data_79_45c4_PlayerFrame_041                ; $29  bank $79   4 pieces
    player_frame data_79_45d9_PlayerFrame_042                ; $2a  bank $79   8 pieces
    player_frame data_79_45fe_PlayerFrame_043                ; $2b  bank $79   7 pieces
    player_frame data_79_461f_PlayerFrame_044                ; $2c  bank $79   5 pieces
    player_frame data_79_4638_PlayerFrame_045                ; $2d  bank $79   8 pieces
    player_frame data_79_465d_PlayerFrame_046                ; $2e  bank $79   7 pieces
    player_frame data_79_467e_PlayerFrame_047                ; $2f  bank $79   8 pieces
    player_frame data_79_46a3_PlayerFrame_048                ; $30  bank $79   9 pieces
    player_frame data_79_46cc_PlayerFrame_049                ; $31  bank $79   9 pieces
    player_frame data_79_46f5_PlayerFrame_050                ; $32  bank $79   8 pieces
    player_frame data_79_471a_PlayerFrame_051                ; $33  bank $79   8 pieces
    player_frame data_79_473f_PlayerFrame_052                ; $34  bank $79   8 pieces
    player_frame data_79_4764_PlayerFrame_053                ; $35  bank $79   6 pieces
    player_frame data_79_4781_PlayerFrame_054                ; $36  bank $79   7 pieces
    player_frame data_79_47a2_PlayerFrame_055                ; $37  bank $79   7 pieces
    player_frame data_79_47c3_PlayerFrame_056                ; $38  bank $79   6 pieces
    player_frame data_79_47e0_PlayerFrame_057                ; $39  bank $79   7 pieces
    player_frame data_7a_4000_PlayerFrame_058                ; $3a  bank $7a   6 pieces
    player_frame data_7a_401d_PlayerFrame_059                ; $3b  bank $7a   7 pieces
    player_frame data_7a_403e_PlayerFrame_060                ; $3c  bank $7a   7 pieces
    player_frame data_7a_405f_PlayerFrame_061                ; $3d  bank $7a   7 pieces
    player_frame data_7a_4080_PlayerFrame_062                ; $3e  bank $7a   6 pieces
    player_frame data_7a_409d_PlayerFrame_063                ; $3f  bank $7a   6 pieces
    player_frame data_7a_40ba_PlayerFrame_064                ; $40  bank $7a   9 pieces
    player_frame data_7a_40e3_PlayerFrame_065                ; $41  bank $7a   8 pieces
    player_frame data_7a_4108_PlayerFrame_066                ; $42  bank $7a   6 pieces
    player_frame data_7a_4125_PlayerFrame_067                ; $43  bank $7a   6 pieces
    player_frame data_7a_4142_PlayerFrame_068                ; $44  bank $7a   7 pieces
    player_frame data_7a_4163_PlayerFrame_069                ; $45  bank $7a   7 pieces
    player_frame data_7a_4184_PlayerFrame_070                ; $46  bank $7a   7 pieces
    player_frame data_7a_41a5_PlayerFrame_071                ; $47  bank $7a   7 pieces
    player_frame data_7a_41c6_PlayerFrame_072                ; $48  bank $7a   5 pieces
    player_frame data_7a_41df_PlayerFrame_073                ; $49  bank $7a   5 pieces
    player_frame data_7a_41f8_PlayerFrame_074                ; $4a  bank $7a   5 pieces
    player_frame data_7a_4211_PlayerFrame_075                ; $4b  bank $7a   5 pieces
    player_frame data_7a_422a_PlayerFrame_076                ; $4c  bank $7a   4 pieces
    player_frame data_7a_423f_PlayerFrame_077                ; $4d  bank $7a   5 pieces
    player_frame data_7a_4258_PlayerFrame_078                ; $4e  bank $7a   6 pieces
    player_frame data_7a_4275_PlayerFrame_079                ; $4f  bank $7a   4 pieces
    player_frame data_7a_428a_PlayerFrame_080                ; $50  bank $7a   4 pieces
    player_frame data_7a_429f_PlayerFrame_081                ; $51  bank $7a   5 pieces
    player_frame data_7a_42b8_PlayerFrame_082                ; $52  bank $7a   6 pieces
    player_frame data_7a_42d5_PlayerFrame_083                ; $53  bank $7a   4 pieces
    player_frame data_7a_42ea_PlayerFrame_084                ; $54  bank $7a   5 pieces
    player_frame data_7a_4303_PlayerFrame_085                ; $55  bank $7a   5 pieces
    player_frame data_7a_431c_PlayerFrame_086                ; $56  bank $7a   5 pieces
    player_frame data_7a_4335_PlayerFrame_087                ; $57  bank $7a   4 pieces
    player_frame data_7a_434a_PlayerFrame_088                ; $58  bank $7a   4 pieces
    player_frame data_7a_435f_PlayerFrame_089                ; $59  bank $7a   5 pieces
    player_frame data_7a_4378_PlayerFrame_090                ; $5a  bank $7a   4 pieces
    player_frame data_7a_438d_PlayerFrame_091                ; $5b  bank $7a   4 pieces
    player_frame data_7a_43a2_PlayerFrame_092                ; $5c  bank $7a   4 pieces
    player_frame data_7a_43b7_PlayerFrame_093                ; $5d  bank $7a   7 pieces
    player_frame data_7a_43d8_PlayerFrame_094                ; $5e  bank $7a   7 pieces
    player_frame data_7a_43f9_PlayerFrame_095                ; $5f  bank $7a   8 pieces
    player_frame data_7a_441e_PlayerFrame_096                ; $60  bank $7a   6 pieces
    player_frame data_7a_443b_PlayerFrame_097                ; $61  bank $7a   7 pieces
    player_frame data_7a_445c_PlayerFrame_098                ; $62  bank $7a   8 pieces
    player_frame data_7a_4481_PlayerFrame_099                ; $63  bank $7a   8 pieces
    player_frame data_7a_44a6_PlayerFrame_100                ; $64  bank $7a   7 pieces
    player_frame data_7a_44c7_PlayerFrame_101                ; $65  bank $7a   7 pieces
    player_frame data_7a_44e8_PlayerFrame_102                ; $66  bank $7a   8 pieces
    player_frame data_7a_450d_PlayerFrame_103                ; $67  bank $7a   6 pieces
    player_frame data_7a_452a_PlayerFrame_104                ; $68  bank $7a   5 pieces
    player_frame data_7a_4543_PlayerFrame_105                ; $69  bank $7a   7 pieces
    player_frame data_7a_4564_PlayerFrame_106                ; $6a  bank $7a   7 pieces
    player_frame data_7a_4585_PlayerFrame_107                ; $6b  bank $7a   7 pieces
    player_frame data_7a_45a6_PlayerFrame_108                ; $6c  bank $7a   6 pieces
    player_frame data_7a_45c3_PlayerFrame_109                ; $6d  bank $7a   7 pieces
    player_frame data_7a_45e4_PlayerFrame_110                ; $6e  bank $7a   8 pieces
    player_frame data_7a_4609_PlayerFrame_111                ; $6f  bank $7a   7 pieces
    player_frame data_7a_462a_PlayerFrame_112                ; $70  bank $7a   6 pieces
    player_frame data_7a_4647_PlayerFrame_113                ; $71  bank $7a   6 pieces
    player_frame data_7a_4664_PlayerFrame_114                ; $72  bank $7a   8 pieces
    player_frame data_7a_4689_PlayerFrame_115                ; $73  bank $7a   7 pieces
    player_frame data_7a_46aa_PlayerFrame_116                ; $74  bank $7a   8 pieces
    player_frame data_7a_46cf_PlayerFrame_117                ; $75  bank $7a   7 pieces
    player_frame data_7a_46f0_PlayerFrame_118                ; $76  bank $7a   7 pieces
    player_frame data_7a_4711_PlayerFrame_119                ; $77  bank $7a   7 pieces
    player_frame data_7a_4732_PlayerFrame_120                ; $78  bank $7a   8 pieces
    player_frame data_7a_4757_PlayerFrame_121                ; $79  bank $7a   7 pieces
    player_frame data_7a_4778_PlayerFrame_122                ; $7a  bank $7a   7 pieces
    player_frame data_7a_4799_PlayerFrame_123                ; $7b  bank $7a   7 pieces
    player_frame data_7a_47ba_PlayerFrame_124                ; $7c  bank $7a   7 pieces
    player_frame data_7a_47db_PlayerFrame_125                ; $7d  bank $7a   4 pieces
    player_frame data_7a_47f0_PlayerFrame_126                ; $7e  bank $7a   4 pieces
    player_frame data_7a_4805_PlayerFrame_127                ; $7f  bank $7a   4 pieces
    player_frame data_7a_481a_PlayerFrame_128                ; $80  bank $7a   4 pieces
    player_frame data_7a_482f_PlayerFrame_129                ; $81  bank $7a   4 pieces
    player_frame data_7a_4844_PlayerFrame_130                ; $82  bank $7a   4 pieces
    player_frame data_7b_4000_PlayerFrame_131                ; $83  bank $7b   4 pieces
    player_frame data_7b_4015_PlayerFrame_132                ; $84  bank $7b   7 pieces
    player_frame data_7b_4036_PlayerFrame_133                ; $85  bank $7b   7 pieces
    player_frame data_7b_4057_PlayerFrame_134                ; $86  bank $7b   7 pieces
    player_frame data_7b_4078_PlayerFrame_135                ; $87  bank $7b   6 pieces
    player_frame data_7b_4095_PlayerFrame_136                ; $88  bank $7b   6 pieces
    player_frame data_7b_40b2_PlayerFrame_137                ; $89  bank $7b   6 pieces
    player_frame data_7b_40cf_PlayerFrame_138                ; $8a  bank $7b   6 pieces
    player_frame data_7b_40ec_PlayerFrame_139                ; $8b  bank $7b   6 pieces
    player_frame data_7b_4109_PlayerFrame_140                ; $8c  bank $7b   7 pieces
    player_frame data_7b_412a_PlayerFrame_141                ; $8d  bank $7b   6 pieces
    player_frame data_7b_4147_PlayerFrame_142                ; $8e  bank $7b   6 pieces
    player_frame data_7b_4164_PlayerFrame_143                ; $8f  bank $7b   5 pieces
    player_frame data_7b_417d_PlayerFrame_144                ; $90  bank $7b   7 pieces
    player_frame data_7b_419e_PlayerFrame_145                ; $91  bank $7b   6 pieces
    player_frame data_7b_41bb_PlayerFrame_146                ; $92  bank $7b   6 pieces
    player_frame data_7b_41d8_PlayerFrame_147                ; $93  bank $7b   5 pieces
    player_frame data_7b_41f1_PlayerFrame_148                ; $94  bank $7b   7 pieces
    player_frame data_7b_4212_PlayerFrame_149                ; $95  bank $7b   6 pieces
    player_frame data_7b_422f_PlayerFrame_150                ; $96  bank $7b   6 pieces
    player_frame data_7b_424c_PlayerFrame_151                ; $97  bank $7b   6 pieces
    player_frame data_7b_4269_PlayerFrame_152                ; $98  bank $7b   7 pieces
    player_frame data_7b_428a_PlayerFrame_153                ; $99  bank $7b   6 pieces
    player_frame data_7b_42a7_PlayerFrame_154                ; $9a  bank $7b   6 pieces
    player_frame data_7b_42c4_PlayerFrame_155                ; $9b  bank $7b   6 pieces
    player_frame data_7b_42e1_PlayerFrame_156                ; $9c  bank $7b   8 pieces
    player_frame data_7b_4306_PlayerFrame_157                ; $9d  bank $7b   9 pieces
    player_frame data_7b_432f_PlayerFrame_158                ; $9e  bank $7b   6 pieces
    player_frame data_7b_434c_PlayerFrame_159                ; $9f  bank $7b   7 pieces
    player_frame data_7b_436d_PlayerFrame_160                ; $a0  bank $7b   7 pieces
    player_frame data_7b_438e_PlayerFrame_161                ; $a1  bank $7b   7 pieces
    player_frame data_7b_43af_PlayerFrame_162                ; $a2  bank $7b   9 pieces
    player_frame data_7b_43d8_PlayerFrame_163                ; $a3  bank $7b   7 pieces
    player_frame data_7b_43f9_PlayerFrame_164                ; $a4  bank $7b   7 pieces
    player_frame data_7b_441a_PlayerFrame_165                ; $a5  bank $7b   6 pieces
    player_frame data_7b_4437_PlayerFrame_166                ; $a6  bank $7b   4 pieces
    player_frame data_7b_444c_PlayerFrame_167                ; $a7  bank $7b   3 pieces
    player_frame data_7b_445d_PlayerFrame_168                ; $a8  bank $7b   2 pieces
    player_frame data_7b_446a_PlayerFrame_169                ; $a9  bank $7b   8 pieces
    player_frame data_7b_448f_PlayerFrame_170                ; $aa  bank $7b   8 pieces
    player_frame data_7b_44b4_PlayerFrame_171                ; $ab  bank $7b   8 pieces
    player_frame data_7b_44d9_PlayerFrame_172                ; $ac  bank $7b   6 pieces
    player_frame data_7b_44f6_PlayerFrame_173                ; $ad  bank $7b   6 pieces
    player_frame data_7b_4513_PlayerFrame_174                ; $ae  bank $7b   5 pieces
    player_frame data_7b_452c_PlayerFrame_175                ; $af  bank $7b   3 pieces
    player_frame data_7b_453d_PlayerFrame_176                ; $b0  bank $7b   3 pieces
    player_frame data_7b_454e_PlayerFrame_177                ; $b1  bank $7b   3 pieces
    player_frame data_7b_455f_PlayerFrame_178                ; $b2  bank $7b   6 pieces
    player_frame data_7b_457c_PlayerFrame_179                ; $b3  bank $7b   1 pieces
    player_frame data_7b_4585_PlayerFrame_180                ; $b4  bank $7b   1 pieces
    player_frame data_7b_458e_PlayerFrame_181                ; $b5  bank $7b   1 pieces
    player_frame data_7b_4597_PlayerFrame_182                ; $b6  bank $7b   1 pieces
    player_frame data_7b_45a0_PlayerFrame_183                ; $b7  bank $7b   1 pieces
    player_frame data_7b_45a9_PlayerFrame_184                ; $b8  bank $7b   1 pieces
    player_frame data_7b_45b2_PlayerFrame_185                ; $b9  bank $7b   1 pieces
    player_frame data_7b_45bb_PlayerFrame_186                ; $ba  bank $7b   1 pieces
    player_frame data_7b_45c4_PlayerFrame_187                ; $bb  bank $7b   1 pieces
    player_frame data_7b_45cd_PlayerFrame_188                ; $bc  bank $7b   1 pieces
    player_frame data_7b_45d6_PlayerFrame_189                ; $bd  bank $7b   1 pieces
    player_frame data_7b_45df_PlayerFrame_190                ; $be  bank $7b   1 pieces
    player_frame data_7b_45e8_PlayerFrame_191                ; $bf  bank $7b   1 pieces
    player_frame data_7b_45f1_PlayerFrame_192                ; $c0  bank $7b   1 pieces
    player_frame data_7b_45fa_PlayerFrame_193                ; $c1  bank $7b   1 pieces
    player_frame data_7b_4603_PlayerFrame_194                ; $c2  bank $7b   1 pieces
    player_frame data_7b_460c_PlayerFrame_195                ; $c3  bank $7b   1 pieces
    player_frame data_7b_4615_PlayerFrame_196                ; $c4  bank $7b   1 pieces
    player_frame data_7b_461e_PlayerFrame_197                ; $c5  bank $7b   1 pieces
    player_frame data_7b_4627_PlayerFrame_198                ; $c6  bank $7b   1 pieces

data_7f_4586_PlayerFrames_MysteryTV:
    DEF PLAYER_GFX_SET_BASE = BANK(data_76_4000_PlayerFrame_001)
; PLAYER_GFX_SET_MYSTERY_TV: 198 frames in banks $76-$78, directory $4586-$47da
; Used by Mystery TV 1-10
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_76_4000_PlayerFrame_001                ; $01  bank $76   7 pieces
    player_frame data_76_4021_PlayerFrame_002                ; $02  bank $76   7 pieces
    player_frame data_76_4042_PlayerFrame_003                ; $03  bank $76   7 pieces
    player_frame data_76_4063_PlayerFrame_004                ; $04  bank $76   7 pieces
    player_frame data_76_4084_PlayerFrame_005                ; $05  bank $76   8 pieces
    player_frame data_76_40a9_PlayerFrame_006                ; $06  bank $76   6 pieces
    player_frame data_76_40c6_PlayerFrame_007                ; $07  bank $76   8 pieces
    player_frame data_76_40eb_PlayerFrame_008                ; $08  bank $76   8 pieces
    player_frame data_76_4110_PlayerFrame_009                ; $09  bank $76   8 pieces
    player_frame data_76_4135_PlayerFrame_010                ; $0a  bank $76   7 pieces
    player_frame data_76_4156_PlayerFrame_011                ; $0b  bank $76   7 pieces
    player_frame data_76_4177_PlayerFrame_012                ; $0c  bank $76   7 pieces
    player_frame data_76_4198_PlayerFrame_013                ; $0d  bank $76   6 pieces
    player_frame data_76_41b5_PlayerFrame_014                ; $0e  bank $76   7 pieces
    player_frame data_76_41d6_PlayerFrame_015                ; $0f  bank $76   8 pieces
    player_frame data_76_41fb_PlayerFrame_016                ; $10  bank $76   8 pieces
    player_frame data_76_4220_PlayerFrame_017                ; $11  bank $76   8 pieces
    player_frame data_76_4245_PlayerFrame_018                ; $12  bank $76   6 pieces
    player_frame data_76_4262_PlayerFrame_019                ; $13  bank $76   7 pieces
    player_frame data_76_4283_PlayerFrame_020                ; $14  bank $76   8 pieces
    player_frame data_76_42a8_PlayerFrame_021                ; $15  bank $76   8 pieces
    player_frame data_76_42cd_PlayerFrame_022                ; $16  bank $76   8 pieces
    player_frame data_76_42f2_PlayerFrame_023                ; $17  bank $76   8 pieces
    player_frame data_76_4317_PlayerFrame_024                ; $18  bank $76   8 pieces
    player_frame data_76_433c_PlayerFrame_025                ; $19  bank $76   8 pieces
    player_frame data_76_4361_PlayerFrame_026                ; $1a  bank $76   8 pieces
    player_frame data_76_4386_PlayerFrame_027                ; $1b  bank $76   8 pieces
    player_frame data_76_43ab_PlayerFrame_028                ; $1c  bank $76   7 pieces
    player_frame data_76_43cc_PlayerFrame_029                ; $1d  bank $76   6 pieces
    player_frame data_76_43e9_PlayerFrame_030                ; $1e  bank $76   8 pieces
    player_frame data_76_440e_PlayerFrame_031                ; $1f  bank $76   8 pieces
    player_frame data_76_4433_PlayerFrame_032                ; $20  bank $76   7 pieces
    player_frame data_76_4454_PlayerFrame_033                ; $21  bank $76   8 pieces
    player_frame data_76_4479_PlayerFrame_034                ; $22  bank $76   8 pieces
    player_frame data_76_449e_PlayerFrame_035                ; $23  bank $76   7 pieces
    player_frame data_76_44bf_PlayerFrame_036                ; $24  bank $76   6 pieces
    player_frame data_76_44dc_PlayerFrame_037                ; $25  bank $76   6 pieces
    player_frame data_76_44f9_PlayerFrame_038                ; $26  bank $76   6 pieces
    player_frame data_76_4516_PlayerFrame_039                ; $27  bank $76   5 pieces
    player_frame data_76_452f_PlayerFrame_040                ; $28  bank $76   5 pieces
    player_frame data_76_4548_PlayerFrame_041                ; $29  bank $76   5 pieces
    player_frame data_76_4561_PlayerFrame_042                ; $2a  bank $76   8 pieces
    player_frame data_76_4586_PlayerFrame_043                ; $2b  bank $76   7 pieces
    player_frame data_76_45a7_PlayerFrame_044                ; $2c  bank $76   6 pieces
    player_frame data_76_45c4_PlayerFrame_045                ; $2d  bank $76   7 pieces
    player_frame data_76_45e5_PlayerFrame_046                ; $2e  bank $76   8 pieces
    player_frame data_76_460a_PlayerFrame_047                ; $2f  bank $76   8 pieces
    player_frame data_76_462f_PlayerFrame_048                ; $30  bank $76   7 pieces
    player_frame data_76_4650_PlayerFrame_049                ; $31  bank $76   7 pieces
    player_frame data_76_4671_PlayerFrame_050                ; $32  bank $76   8 pieces
    player_frame data_76_4696_PlayerFrame_051                ; $33  bank $76   7 pieces
    player_frame data_76_46b7_PlayerFrame_052                ; $34  bank $76   8 pieces
    player_frame data_76_46dc_PlayerFrame_053                ; $35  bank $76   7 pieces
    player_frame data_76_46fd_PlayerFrame_054                ; $36  bank $76   6 pieces
    player_frame data_76_471a_PlayerFrame_055                ; $37  bank $76   6 pieces
    player_frame data_76_4737_PlayerFrame_056                ; $38  bank $76   7 pieces
    player_frame data_76_4758_PlayerFrame_057                ; $39  bank $76   6 pieces
    player_frame data_76_4775_PlayerFrame_058                ; $3a  bank $76   7 pieces
    player_frame data_76_4796_PlayerFrame_059                ; $3b  bank $76   6 pieces
    player_frame data_76_47b3_PlayerFrame_060                ; $3c  bank $76   7 pieces
    player_frame data_76_47d4_PlayerFrame_061                ; $3d  bank $76   6 pieces
    player_frame data_76_47f1_PlayerFrame_062                ; $3e  bank $76   6 pieces
    player_frame data_76_480e_PlayerFrame_063                ; $3f  bank $76   6 pieces
    player_frame data_77_4000_PlayerFrame_064                ; $40  bank $77   8 pieces
    player_frame data_77_4025_PlayerFrame_065                ; $41  bank $77   8 pieces
    player_frame data_77_404a_PlayerFrame_066                ; $42  bank $77   6 pieces
    player_frame data_77_4067_PlayerFrame_067                ; $43  bank $77   6 pieces
    player_frame data_77_4084_PlayerFrame_068                ; $44  bank $77   6 pieces
    player_frame data_77_40a1_PlayerFrame_069                ; $45  bank $77   6 pieces
    player_frame data_77_40be_PlayerFrame_070                ; $46  bank $77   7 pieces
    player_frame data_77_40df_PlayerFrame_071                ; $47  bank $77   7 pieces
    player_frame data_77_4100_PlayerFrame_072                ; $48  bank $77   6 pieces
    player_frame data_77_411d_PlayerFrame_073                ; $49  bank $77   6 pieces
    player_frame data_77_413a_PlayerFrame_074                ; $4a  bank $77   6 pieces
    player_frame data_77_4157_PlayerFrame_075                ; $4b  bank $77   6 pieces
    player_frame data_77_4174_PlayerFrame_076                ; $4c  bank $77   5 pieces
    player_frame data_77_418d_PlayerFrame_077                ; $4d  bank $77   6 pieces
    player_frame data_77_41aa_PlayerFrame_078                ; $4e  bank $77   7 pieces
    player_frame data_77_41cb_PlayerFrame_079                ; $4f  bank $77   6 pieces
    player_frame data_77_41e8_PlayerFrame_080                ; $50  bank $77   5 pieces
    player_frame data_77_4201_PlayerFrame_081                ; $51  bank $77   6 pieces
    player_frame data_77_421e_PlayerFrame_082                ; $52  bank $77   7 pieces
    player_frame data_77_423f_PlayerFrame_083                ; $53  bank $77   6 pieces
    player_frame data_77_425c_PlayerFrame_084                ; $54  bank $77   5 pieces
    player_frame data_77_4275_PlayerFrame_085                ; $55  bank $77   5 pieces
    player_frame data_77_428e_PlayerFrame_086                ; $56  bank $77   6 pieces
    player_frame data_77_42ab_PlayerFrame_087                ; $57  bank $77   5 pieces
    player_frame data_77_42c4_PlayerFrame_088                ; $58  bank $77   6 pieces
    player_frame data_77_42e1_PlayerFrame_089                ; $59  bank $77   6 pieces
    player_frame data_77_42fe_PlayerFrame_090                ; $5a  bank $77   6 pieces
    player_frame data_77_431b_PlayerFrame_091                ; $5b  bank $77   4 pieces
    player_frame data_77_4330_PlayerFrame_092                ; $5c  bank $77   4 pieces
    player_frame data_77_4345_PlayerFrame_093                ; $5d  bank $77   7 pieces
    player_frame data_77_4366_PlayerFrame_094                ; $5e  bank $77   7 pieces
    player_frame data_77_4387_PlayerFrame_095                ; $5f  bank $77   7 pieces
    player_frame data_77_43a8_PlayerFrame_096                ; $60  bank $77   6 pieces
    player_frame data_77_43c5_PlayerFrame_097                ; $61  bank $77   6 pieces
    player_frame data_77_43e2_PlayerFrame_098                ; $62  bank $77   7 pieces
    player_frame data_77_4403_PlayerFrame_099                ; $63  bank $77   7 pieces
    player_frame data_77_4424_PlayerFrame_100                ; $64  bank $77   7 pieces
    player_frame data_77_4445_PlayerFrame_101                ; $65  bank $77   6 pieces
    player_frame data_77_4462_PlayerFrame_102                ; $66  bank $77   7 pieces
    player_frame data_77_4483_PlayerFrame_103                ; $67  bank $77   6 pieces
    player_frame data_77_44a0_PlayerFrame_104                ; $68  bank $77   6 pieces
    player_frame data_77_44bd_PlayerFrame_105                ; $69  bank $77   7 pieces
    player_frame data_77_44de_PlayerFrame_106                ; $6a  bank $77   7 pieces
    player_frame data_77_44ff_PlayerFrame_107                ; $6b  bank $77   7 pieces
    player_frame data_77_4520_PlayerFrame_108                ; $6c  bank $77   6 pieces
    player_frame data_77_453d_PlayerFrame_109                ; $6d  bank $77   7 pieces
    player_frame data_77_455e_PlayerFrame_110                ; $6e  bank $77   8 pieces
    player_frame data_77_4583_PlayerFrame_111                ; $6f  bank $77   6 pieces
    player_frame data_77_45a0_PlayerFrame_112                ; $70  bank $77   6 pieces
    player_frame data_77_45bd_PlayerFrame_113                ; $71  bank $77   6 pieces
    player_frame data_77_45da_PlayerFrame_114                ; $72  bank $77   7 pieces
    player_frame data_77_45fb_PlayerFrame_115                ; $73  bank $77   7 pieces
    player_frame data_77_461c_PlayerFrame_116                ; $74  bank $77   8 pieces
    player_frame data_77_4641_PlayerFrame_117                ; $75  bank $77   8 pieces
    player_frame data_77_4666_PlayerFrame_118                ; $76  bank $77   7 pieces
    player_frame data_77_4687_PlayerFrame_119                ; $77  bank $77   7 pieces
    player_frame data_77_46a8_PlayerFrame_120                ; $78  bank $77   7 pieces
    player_frame data_77_46c9_PlayerFrame_121                ; $79  bank $77   7 pieces
    player_frame data_77_46ea_PlayerFrame_122                ; $7a  bank $77   7 pieces
    player_frame data_77_470b_PlayerFrame_123                ; $7b  bank $77   7 pieces
    player_frame data_77_472c_PlayerFrame_124                ; $7c  bank $77   7 pieces
    player_frame data_77_474d_PlayerFrame_125                ; $7d  bank $77   4 pieces
    player_frame data_77_4762_PlayerFrame_126                ; $7e  bank $77   4 pieces
    player_frame data_77_4777_PlayerFrame_127                ; $7f  bank $77   4 pieces
    player_frame data_77_478c_PlayerFrame_128                ; $80  bank $77   4 pieces
    player_frame data_77_47a1_PlayerFrame_129                ; $81  bank $77   4 pieces
    player_frame data_77_47b6_PlayerFrame_130                ; $82  bank $77   4 pieces
    player_frame data_77_47cb_PlayerFrame_131                ; $83  bank $77   4 pieces
    player_frame data_77_47e0_PlayerFrame_132                ; $84  bank $77   6 pieces
    player_frame data_77_47fd_PlayerFrame_133                ; $85  bank $77   6 pieces
    player_frame data_77_481a_PlayerFrame_134                ; $86  bank $77   6 pieces
    player_frame data_77_4837_PlayerFrame_135                ; $87  bank $77   7 pieces
    player_frame data_78_4000_PlayerFrame_136                ; $88  bank $78   5 pieces
    player_frame data_78_4019_PlayerFrame_137                ; $89  bank $78   5 pieces
    player_frame data_78_4032_PlayerFrame_138                ; $8a  bank $78   6 pieces
    player_frame data_78_404f_PlayerFrame_139                ; $8b  bank $78   5 pieces
    player_frame data_78_4068_PlayerFrame_140                ; $8c  bank $78   6 pieces
    player_frame data_78_4085_PlayerFrame_141                ; $8d  bank $78   7 pieces
    player_frame data_78_40a6_PlayerFrame_142                ; $8e  bank $78   7 pieces
    player_frame data_78_40c7_PlayerFrame_143                ; $8f  bank $78   6 pieces
    player_frame data_78_40e4_PlayerFrame_144                ; $90  bank $78   7 pieces
    player_frame data_78_4105_PlayerFrame_145                ; $91  bank $78   7 pieces
    player_frame data_78_4126_PlayerFrame_146                ; $92  bank $78   7 pieces
    player_frame data_78_4147_PlayerFrame_147                ; $93  bank $78   6 pieces
    player_frame data_78_4164_PlayerFrame_148                ; $94  bank $78   7 pieces
    player_frame data_78_4185_PlayerFrame_149                ; $95  bank $78   7 pieces
    player_frame data_78_41a6_PlayerFrame_150                ; $96  bank $78   7 pieces
    player_frame data_78_41c7_PlayerFrame_151                ; $97  bank $78   6 pieces
    player_frame data_78_41e4_PlayerFrame_152                ; $98  bank $78   7 pieces
    player_frame data_78_4205_PlayerFrame_153                ; $99  bank $78   7 pieces
    player_frame data_78_4226_PlayerFrame_154                ; $9a  bank $78   7 pieces
    player_frame data_78_4247_PlayerFrame_155                ; $9b  bank $78   6 pieces
    player_frame data_78_4264_PlayerFrame_156                ; $9c  bank $78   7 pieces
    player_frame data_78_4285_PlayerFrame_157                ; $9d  bank $78   7 pieces
    player_frame data_78_42a6_PlayerFrame_158                ; $9e  bank $78   7 pieces
    player_frame data_78_42c7_PlayerFrame_159                ; $9f  bank $78   8 pieces
    player_frame data_78_42ec_PlayerFrame_160                ; $a0  bank $78   8 pieces
    player_frame data_78_4311_PlayerFrame_161                ; $a1  bank $78   8 pieces
    player_frame data_78_4336_PlayerFrame_162                ; $a2  bank $78   9 pieces
    player_frame data_78_435f_PlayerFrame_163                ; $a3  bank $78   8 pieces
    player_frame data_78_4384_PlayerFrame_164                ; $a4  bank $78   8 pieces
    player_frame data_78_43a9_PlayerFrame_165                ; $a5  bank $78   6 pieces
    player_frame data_78_43c6_PlayerFrame_166                ; $a6  bank $78   4 pieces
    player_frame data_78_43db_PlayerFrame_167                ; $a7  bank $78   3 pieces
    player_frame data_78_43ec_PlayerFrame_168                ; $a8  bank $78   2 pieces
    player_frame data_78_43f9_PlayerFrame_169                ; $a9  bank $78   8 pieces
    player_frame data_78_441e_PlayerFrame_170                ; $aa  bank $78   6 pieces
    player_frame data_78_443b_PlayerFrame_171                ; $ab  bank $78   5 pieces
    player_frame data_78_4454_PlayerFrame_172                ; $ac  bank $78   5 pieces
    player_frame data_78_446d_PlayerFrame_173                ; $ad  bank $78   4 pieces
    player_frame data_78_4482_PlayerFrame_174                ; $ae  bank $78   4 pieces
    player_frame data_78_4497_PlayerFrame_175                ; $af  bank $78   4 pieces
    player_frame data_78_44ac_PlayerFrame_176                ; $b0  bank $78   3 pieces
    player_frame data_78_44bd_PlayerFrame_177                ; $b1  bank $78   2 pieces
    player_frame data_78_44ca_PlayerFrame_178                ; $b2  bank $78   6 pieces
    player_frame data_78_44e7_PlayerFrame_179                ; $b3  bank $78   6 pieces
    player_frame data_78_4504_PlayerFrame_180                ; $b4  bank $78   6 pieces
    player_frame data_78_4521_PlayerFrame_181                ; $b5  bank $78   6 pieces
    player_frame data_78_453e_PlayerFrame_182                ; $b6  bank $78   7 pieces
    player_frame data_78_455f_PlayerFrame_183                ; $b7  bank $78   7 pieces
    player_frame data_78_4580_PlayerFrame_184                ; $b8  bank $78   8 pieces
    player_frame data_78_45a5_PlayerFrame_185                ; $b9  bank $78   7 pieces
    player_frame data_78_45c6_PlayerFrame_186                ; $ba  bank $78   7 pieces
    player_frame data_78_45e7_PlayerFrame_187                ; $bb  bank $78   6 pieces
    player_frame data_78_4604_PlayerFrame_188                ; $bc  bank $78   5 pieces
    player_frame data_78_461d_PlayerFrame_189                ; $bd  bank $78   5 pieces
    player_frame data_78_4636_PlayerFrame_190                ; $be  bank $78   5 pieces
    player_frame data_78_464f_PlayerFrame_191                ; $bf  bank $78   6 pieces
    player_frame data_78_466c_PlayerFrame_192                ; $c0  bank $78   6 pieces
    player_frame data_78_4689_PlayerFrame_193                ; $c1  bank $78   6 pieces
    player_frame data_78_46a6_PlayerFrame_194                ; $c2  bank $78   6 pieces
    player_frame data_78_46c3_PlayerFrame_195                ; $c3  bank $78   7 pieces
    player_frame data_78_46e4_PlayerFrame_196                ; $c4  bank $78   5 pieces
    player_frame data_78_46fd_PlayerFrame_197                ; $c5  bank $78   8 pieces
    player_frame data_78_4722_PlayerFrame_198                ; $c6  bank $78   7 pieces

data_7f_47db_PlayerFrames_TutTV:
    DEF PLAYER_GFX_SET_BASE = BANK(data_72_4000_PlayerFrame_001)
; PLAYER_GFX_SET_TUT_TV: 198 frames in banks $72-$75, directory $47db-$4a2f
; Used by Tut TV 1-7
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_72_4000_PlayerFrame_001                ; $01  bank $72   9 pieces
    player_frame data_72_4029_PlayerFrame_002                ; $02  bank $72  10 pieces
    player_frame data_72_4056_PlayerFrame_003                ; $03  bank $72   8 pieces
    player_frame data_72_407b_PlayerFrame_004                ; $04  bank $72   8 pieces
    player_frame data_72_40a0_PlayerFrame_005                ; $05  bank $72   9 pieces
    player_frame data_72_40c9_PlayerFrame_006                ; $06  bank $72   9 pieces
    player_frame data_72_40f2_PlayerFrame_007                ; $07  bank $72  11 pieces
    player_frame data_72_4123_PlayerFrame_008                ; $08  bank $72  10 pieces
    player_frame data_72_4150_PlayerFrame_009                ; $09  bank $72  10 pieces
    player_frame data_72_417d_PlayerFrame_010                ; $0a  bank $72  10 pieces
    player_frame data_72_41aa_PlayerFrame_011                ; $0b  bank $72  10 pieces
    player_frame data_72_41d7_PlayerFrame_012                ; $0c  bank $72   9 pieces
    player_frame data_72_4200_PlayerFrame_013                ; $0d  bank $72   8 pieces
    player_frame data_72_4225_PlayerFrame_014                ; $0e  bank $72  10 pieces
    player_frame data_72_4252_PlayerFrame_015                ; $0f  bank $72  10 pieces
    player_frame data_72_427f_PlayerFrame_016                ; $10  bank $72   9 pieces
    player_frame data_72_42a8_PlayerFrame_017                ; $11  bank $72  10 pieces
    player_frame data_72_42d5_PlayerFrame_018                ; $12  bank $72   8 pieces
    player_frame data_72_42fa_PlayerFrame_019                ; $13  bank $72   8 pieces
    player_frame data_72_431f_PlayerFrame_020                ; $14  bank $72  10 pieces
    player_frame data_72_434c_PlayerFrame_021                ; $15  bank $72  10 pieces
    player_frame data_72_4379_PlayerFrame_022                ; $16  bank $72  10 pieces
    player_frame data_72_43a6_PlayerFrame_023                ; $17  bank $72  10 pieces
    player_frame data_72_43d3_PlayerFrame_024                ; $18  bank $72   9 pieces
    player_frame data_72_43fc_PlayerFrame_025                ; $19  bank $72   8 pieces
    player_frame data_72_4421_PlayerFrame_026                ; $1a  bank $72   8 pieces
    player_frame data_72_4446_PlayerFrame_027                ; $1b  bank $72   9 pieces
    player_frame data_72_446f_PlayerFrame_028                ; $1c  bank $72   8 pieces
    player_frame data_72_4494_PlayerFrame_029                ; $1d  bank $72   7 pieces
    player_frame data_72_44b5_PlayerFrame_030                ; $1e  bank $72   8 pieces
    player_frame data_72_44da_PlayerFrame_031                ; $1f  bank $72   9 pieces
    player_frame data_72_4503_PlayerFrame_032                ; $20  bank $72  10 pieces
    player_frame data_72_4530_PlayerFrame_033                ; $21  bank $72   9 pieces
    player_frame data_72_4559_PlayerFrame_034                ; $22  bank $72   8 pieces
    player_frame data_72_457e_PlayerFrame_035                ; $23  bank $72   7 pieces
    player_frame data_72_459f_PlayerFrame_036                ; $24  bank $72   6 pieces
    player_frame data_72_45bc_PlayerFrame_037                ; $25  bank $72   6 pieces
    player_frame data_72_45d9_PlayerFrame_038                ; $26  bank $72   6 pieces
    player_frame data_72_45f6_PlayerFrame_039                ; $27  bank $72   4 pieces
    player_frame data_72_460b_PlayerFrame_040                ; $28  bank $72   4 pieces
    player_frame data_72_4620_PlayerFrame_041                ; $29  bank $72   4 pieces
    player_frame data_72_4635_PlayerFrame_042                ; $2a  bank $72   9 pieces
    player_frame data_72_465e_PlayerFrame_043                ; $2b  bank $72   7 pieces
    player_frame data_72_467f_PlayerFrame_044                ; $2c  bank $72   7 pieces
    player_frame data_72_46a0_PlayerFrame_045                ; $2d  bank $72   7 pieces
    player_frame data_72_46c1_PlayerFrame_046                ; $2e  bank $72   9 pieces
    player_frame data_72_46ea_PlayerFrame_047                ; $2f  bank $72  10 pieces
    player_frame data_72_4717_PlayerFrame_048                ; $30  bank $72   9 pieces
    player_frame data_72_4740_PlayerFrame_049                ; $31  bank $72   8 pieces
    player_frame data_72_4765_PlayerFrame_050                ; $32  bank $72   8 pieces
    player_frame data_72_478a_PlayerFrame_051                ; $33  bank $72   9 pieces
    player_frame data_72_47b3_PlayerFrame_052                ; $34  bank $72   8 pieces
    player_frame data_72_47d8_PlayerFrame_053                ; $35  bank $72   7 pieces
    player_frame data_73_4000_PlayerFrame_054                ; $36  bank $73   7 pieces
    player_frame data_73_4021_PlayerFrame_055                ; $37  bank $73   7 pieces
    player_frame data_73_4042_PlayerFrame_056                ; $38  bank $73   7 pieces
    player_frame data_73_4063_PlayerFrame_057                ; $39  bank $73   7 pieces
    player_frame data_73_4084_PlayerFrame_058                ; $3a  bank $73   7 pieces
    player_frame data_73_40a5_PlayerFrame_059                ; $3b  bank $73   7 pieces
    player_frame data_73_40c6_PlayerFrame_060                ; $3c  bank $73   7 pieces
    player_frame data_73_40e7_PlayerFrame_061                ; $3d  bank $73   7 pieces
    player_frame data_73_4108_PlayerFrame_062                ; $3e  bank $73   7 pieces
    player_frame data_73_4129_PlayerFrame_063                ; $3f  bank $73   8 pieces
    player_frame data_73_414e_PlayerFrame_064                ; $40  bank $73   8 pieces
    player_frame data_73_4173_PlayerFrame_065                ; $41  bank $73   9 pieces
    player_frame data_73_419c_PlayerFrame_066                ; $42  bank $73   8 pieces
    player_frame data_73_41c1_PlayerFrame_067                ; $43  bank $73   6 pieces
    player_frame data_73_41de_PlayerFrame_068                ; $44  bank $73   8 pieces
    player_frame data_73_4203_PlayerFrame_069                ; $45  bank $73   8 pieces
    player_frame data_73_4228_PlayerFrame_070                ; $46  bank $73   8 pieces
    player_frame data_73_424d_PlayerFrame_071                ; $47  bank $73   8 pieces
    player_frame data_73_4272_PlayerFrame_072                ; $48  bank $73   6 pieces
    player_frame data_73_428f_PlayerFrame_073                ; $49  bank $73   6 pieces
    player_frame data_73_42ac_PlayerFrame_074                ; $4a  bank $73   6 pieces
    player_frame data_73_42c9_PlayerFrame_075                ; $4b  bank $73   6 pieces
    player_frame data_73_42e6_PlayerFrame_076                ; $4c  bank $73   5 pieces
    player_frame data_73_42ff_PlayerFrame_077                ; $4d  bank $73   6 pieces
    player_frame data_73_431c_PlayerFrame_078                ; $4e  bank $73   7 pieces
    player_frame data_73_433d_PlayerFrame_079                ; $4f  bank $73   7 pieces
    player_frame data_73_435e_PlayerFrame_080                ; $50  bank $73   6 pieces
    player_frame data_73_437b_PlayerFrame_081                ; $51  bank $73   6 pieces
    player_frame data_73_4398_PlayerFrame_082                ; $52  bank $73   6 pieces
    player_frame data_73_43b5_PlayerFrame_083                ; $53  bank $73   7 pieces
    player_frame data_73_43d6_PlayerFrame_084                ; $54  bank $73   6 pieces
    player_frame data_73_43f3_PlayerFrame_085                ; $55  bank $73   6 pieces
    player_frame data_73_4410_PlayerFrame_086                ; $56  bank $73   6 pieces
    player_frame data_73_442d_PlayerFrame_087                ; $57  bank $73   6 pieces
    player_frame data_73_444a_PlayerFrame_088                ; $58  bank $73   6 pieces
    player_frame data_73_4467_PlayerFrame_089                ; $59  bank $73   6 pieces
    player_frame data_73_4484_PlayerFrame_090                ; $5a  bank $73   5 pieces
    player_frame data_73_449d_PlayerFrame_091                ; $5b  bank $73   5 pieces
    player_frame data_73_44b6_PlayerFrame_092                ; $5c  bank $73   6 pieces
    player_frame data_73_44d3_PlayerFrame_093                ; $5d  bank $73   8 pieces
    player_frame data_73_44f8_PlayerFrame_094                ; $5e  bank $73   8 pieces
    player_frame data_73_451d_PlayerFrame_095                ; $5f  bank $73   8 pieces
    player_frame data_73_4542_PlayerFrame_096                ; $60  bank $73   7 pieces
    player_frame data_73_4563_PlayerFrame_097                ; $61  bank $73   7 pieces
    player_frame data_73_4584_PlayerFrame_098                ; $62  bank $73   8 pieces
    player_frame data_73_45a9_PlayerFrame_099                ; $63  bank $73   8 pieces
    player_frame data_73_45ce_PlayerFrame_100                ; $64  bank $73   8 pieces
    player_frame data_73_45f3_PlayerFrame_101                ; $65  bank $73   8 pieces
    player_frame data_73_4618_PlayerFrame_102                ; $66  bank $73   8 pieces
    player_frame data_73_463d_PlayerFrame_103                ; $67  bank $73   7 pieces
    player_frame data_73_465e_PlayerFrame_104                ; $68  bank $73   7 pieces
    player_frame data_73_467f_PlayerFrame_105                ; $69  bank $73   8 pieces
    player_frame data_73_46a4_PlayerFrame_106                ; $6a  bank $73   8 pieces
    player_frame data_73_46c9_PlayerFrame_107                ; $6b  bank $73   8 pieces
    player_frame data_73_46ee_PlayerFrame_108                ; $6c  bank $73   6 pieces
    player_frame data_73_470b_PlayerFrame_109                ; $6d  bank $73   8 pieces
    player_frame data_73_4730_PlayerFrame_110                ; $6e  bank $73   9 pieces
    player_frame data_73_4759_PlayerFrame_111                ; $6f  bank $73   7 pieces
    player_frame data_73_477a_PlayerFrame_112                ; $70  bank $73   6 pieces
    player_frame data_73_4797_PlayerFrame_113                ; $71  bank $73   8 pieces
    player_frame data_73_47bc_PlayerFrame_114                ; $72  bank $73   9 pieces
    player_frame data_73_47e5_PlayerFrame_115                ; $73  bank $73   8 pieces
    player_frame data_73_480a_PlayerFrame_116                ; $74  bank $73   8 pieces
    player_frame data_74_4000_PlayerFrame_117                ; $75  bank $74   8 pieces
    player_frame data_74_4025_PlayerFrame_118                ; $76  bank $74   8 pieces
    player_frame data_74_404a_PlayerFrame_119                ; $77  bank $74   8 pieces
    player_frame data_74_406f_PlayerFrame_120                ; $78  bank $74   8 pieces
    player_frame data_74_4094_PlayerFrame_121                ; $79  bank $74   8 pieces
    player_frame data_74_40b9_PlayerFrame_122                ; $7a  bank $74   9 pieces
    player_frame data_74_40e2_PlayerFrame_123                ; $7b  bank $74   9 pieces
    player_frame data_74_410b_PlayerFrame_124                ; $7c  bank $74   9 pieces
    player_frame data_74_4134_PlayerFrame_125                ; $7d  bank $74   4 pieces
    player_frame data_74_4149_PlayerFrame_126                ; $7e  bank $74   4 pieces
    player_frame data_74_415e_PlayerFrame_127                ; $7f  bank $74   4 pieces
    player_frame data_74_4173_PlayerFrame_128                ; $80  bank $74   4 pieces
    player_frame data_74_4188_PlayerFrame_129                ; $81  bank $74   4 pieces
    player_frame data_74_419d_PlayerFrame_130                ; $82  bank $74   4 pieces
    player_frame data_74_41b2_PlayerFrame_131                ; $83  bank $74   4 pieces
    player_frame data_74_41c7_PlayerFrame_132                ; $84  bank $74   7 pieces
    player_frame data_74_41e8_PlayerFrame_133                ; $85  bank $74   7 pieces
    player_frame data_74_4209_PlayerFrame_134                ; $86  bank $74   6 pieces
    player_frame data_74_4226_PlayerFrame_135                ; $87  bank $74   8 pieces
    player_frame data_74_424b_PlayerFrame_136                ; $88  bank $74   8 pieces
    player_frame data_74_4270_PlayerFrame_137                ; $89  bank $74   6 pieces
    player_frame data_74_428d_PlayerFrame_138                ; $8a  bank $74   8 pieces
    player_frame data_74_42b2_PlayerFrame_139                ; $8b  bank $74   7 pieces
    player_frame data_74_42d3_PlayerFrame_140                ; $8c  bank $74   8 pieces
    player_frame data_74_42f8_PlayerFrame_141                ; $8d  bank $74   7 pieces
    player_frame data_74_4319_PlayerFrame_142                ; $8e  bank $74   7 pieces
    player_frame data_74_433a_PlayerFrame_143                ; $8f  bank $74   6 pieces
    player_frame data_74_4357_PlayerFrame_144                ; $90  bank $74   7 pieces
    player_frame data_74_4378_PlayerFrame_145                ; $91  bank $74   8 pieces
    player_frame data_74_439d_PlayerFrame_146                ; $92  bank $74   8 pieces
    player_frame data_74_43c2_PlayerFrame_147                ; $93  bank $74   7 pieces
    player_frame data_74_43e3_PlayerFrame_148                ; $94  bank $74   8 pieces
    player_frame data_74_4408_PlayerFrame_149                ; $95  bank $74   8 pieces
    player_frame data_74_442d_PlayerFrame_150                ; $96  bank $74   7 pieces
    player_frame data_74_444e_PlayerFrame_151                ; $97  bank $74   7 pieces
    player_frame data_74_446f_PlayerFrame_152                ; $98  bank $74   8 pieces
    player_frame data_74_4494_PlayerFrame_153                ; $99  bank $74   8 pieces
    player_frame data_74_44b9_PlayerFrame_154                ; $9a  bank $74   7 pieces
    player_frame data_74_44da_PlayerFrame_155                ; $9b  bank $74   7 pieces
    player_frame data_74_44fb_PlayerFrame_156                ; $9c  bank $74   8 pieces
    player_frame data_74_4520_PlayerFrame_157                ; $9d  bank $74   9 pieces
    player_frame data_74_4549_PlayerFrame_158                ; $9e  bank $74   8 pieces
    player_frame data_74_456e_PlayerFrame_159                ; $9f  bank $74   8 pieces
    player_frame data_74_4593_PlayerFrame_160                ; $a0  bank $74   8 pieces
    player_frame data_74_45b8_PlayerFrame_161                ; $a1  bank $74   8 pieces
    player_frame data_74_45dd_PlayerFrame_162                ; $a2  bank $74   9 pieces
    player_frame data_74_4606_PlayerFrame_163                ; $a3  bank $74   7 pieces
    player_frame data_74_4627_PlayerFrame_164                ; $a4  bank $74   8 pieces
    player_frame data_74_464c_PlayerFrame_165                ; $a5  bank $74   6 pieces
    player_frame data_74_4669_PlayerFrame_166                ; $a6  bank $74   4 pieces
    player_frame data_74_467e_PlayerFrame_167                ; $a7  bank $74   3 pieces
    player_frame data_74_468f_PlayerFrame_168                ; $a8  bank $74   2 pieces
    player_frame data_74_469c_PlayerFrame_169                ; $a9  bank $74   8 pieces
    player_frame data_74_46c1_PlayerFrame_170                ; $aa  bank $74   8 pieces
    player_frame data_74_46e6_PlayerFrame_171                ; $ab  bank $74   8 pieces
    player_frame data_74_470b_PlayerFrame_172                ; $ac  bank $74   6 pieces
    player_frame data_74_4728_PlayerFrame_173                ; $ad  bank $74   6 pieces
    player_frame data_74_4745_PlayerFrame_174                ; $ae  bank $74   4 pieces
    player_frame data_74_475a_PlayerFrame_175                ; $af  bank $74   4 pieces
    player_frame data_74_476f_PlayerFrame_176                ; $b0  bank $74   2 pieces
    player_frame data_74_477c_PlayerFrame_177                ; $b1  bank $74   2 pieces
    player_frame data_74_4789_PlayerFrame_178                ; $b2  bank $74   6 pieces
    player_frame data_74_47a6_PlayerFrame_179                ; $b3  bank $74   6 pieces
    player_frame data_74_47c3_PlayerFrame_180                ; $b4  bank $74   6 pieces
    player_frame data_74_47e0_PlayerFrame_181                ; $b5  bank $74   6 pieces
    player_frame data_74_47fd_PlayerFrame_182                ; $b6  bank $74   6 pieces
    player_frame data_74_481a_PlayerFrame_183                ; $b7  bank $74   5 pieces
    player_frame data_75_4000_PlayerFrame_184                ; $b8  bank $75   6 pieces
    player_frame data_75_401d_PlayerFrame_185                ; $b9  bank $75   6 pieces
    player_frame data_75_403a_PlayerFrame_186                ; $ba  bank $75   6 pieces
    player_frame data_75_4057_PlayerFrame_187                ; $bb  bank $75   6 pieces
    player_frame data_75_4074_PlayerFrame_188                ; $bc  bank $75   6 pieces
    player_frame data_75_4091_PlayerFrame_189                ; $bd  bank $75   6 pieces
    player_frame data_75_40ae_PlayerFrame_190                ; $be  bank $75   6 pieces
    player_frame data_75_40cb_PlayerFrame_191                ; $bf  bank $75   6 pieces
    player_frame data_75_40e8_PlayerFrame_192                ; $c0  bank $75   5 pieces
    player_frame data_75_4101_PlayerFrame_193                ; $c1  bank $75   6 pieces
    player_frame data_75_411e_PlayerFrame_194                ; $c2  bank $75   6 pieces
    player_frame data_75_413b_PlayerFrame_195                ; $c3  bank $75   7 pieces
    player_frame data_75_415c_PlayerFrame_196                ; $c4  bank $75   5 pieces
    player_frame data_75_4175_PlayerFrame_197                ; $c5  bank $75   7 pieces
    player_frame data_75_4196_PlayerFrame_198                ; $c6  bank $75   6 pieces

data_7f_4a30_PlayerFrames_SuperheroShow:
    DEF PLAYER_GFX_SET_BASE = BANK(data_6e_4000_PlayerFrame_001)
; PLAYER_GFX_SET_SUPERHERO_SHOW: 236 frames in banks $6e-$71, directory $4a30-$4cf6
; Used by Superhero Show 1-6
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_6e_4000_PlayerFrame_001                ; $01  bank $6e  10 pieces
    player_frame data_6e_402d_PlayerFrame_002                ; $02  bank $6e   9 pieces
    player_frame data_6e_4056_PlayerFrame_003                ; $03  bank $6e   9 pieces
    player_frame data_6e_407f_PlayerFrame_004                ; $04  bank $6e   8 pieces
    player_frame data_6e_40a4_PlayerFrame_005                ; $05  bank $6e   9 pieces
    player_frame data_6e_40cd_PlayerFrame_006                ; $06  bank $6e   9 pieces
    player_frame data_6e_40f6_PlayerFrame_007                ; $07  bank $6e   8 pieces
    player_frame data_6e_411b_PlayerFrame_008                ; $08  bank $6e   8 pieces
    player_frame data_6e_4140_PlayerFrame_009                ; $09  bank $6e   8 pieces
    player_frame data_6e_4165_PlayerFrame_010                ; $0a  bank $6e  10 pieces
    player_frame data_6e_4192_PlayerFrame_011                ; $0b  bank $6e  10 pieces
    player_frame data_6e_41bf_PlayerFrame_012                ; $0c  bank $6e  10 pieces
    player_frame data_6e_41ec_PlayerFrame_013                ; $0d  bank $6e   7 pieces
    player_frame data_6e_420d_PlayerFrame_014                ; $0e  bank $6e   8 pieces
    player_frame data_6e_4232_PlayerFrame_015                ; $0f  bank $6e   8 pieces
    player_frame data_6e_4257_PlayerFrame_016                ; $10  bank $6e  10 pieces
    player_frame data_6e_4284_PlayerFrame_017                ; $11  bank $6e   9 pieces
    player_frame data_6e_42ad_PlayerFrame_018                ; $12  bank $6e   9 pieces
    player_frame data_6e_42d6_PlayerFrame_019                ; $13  bank $6e   9 pieces
    player_frame data_6e_42ff_PlayerFrame_020                ; $14  bank $6e  10 pieces
    player_frame data_6e_432c_PlayerFrame_021                ; $15  bank $6e   8 pieces
    player_frame data_6e_4351_PlayerFrame_022                ; $16  bank $6e  11 pieces
    player_frame data_6e_4382_PlayerFrame_023                ; $17  bank $6e   9 pieces
    player_frame data_6e_43ab_PlayerFrame_024                ; $18  bank $6e   9 pieces
    player_frame data_6e_43d4_PlayerFrame_025                ; $19  bank $6e   9 pieces
    player_frame data_6e_43fd_PlayerFrame_026                ; $1a  bank $6e   9 pieces
    player_frame data_6e_4426_PlayerFrame_027                ; $1b  bank $6e   9 pieces
    player_frame data_6e_444f_PlayerFrame_028                ; $1c  bank $6e   8 pieces
    player_frame data_6e_4474_PlayerFrame_029                ; $1d  bank $6e   7 pieces
    player_frame data_6e_4495_PlayerFrame_030                ; $1e  bank $6e   9 pieces
    player_frame data_6e_44be_PlayerFrame_031                ; $1f  bank $6e   9 pieces
    player_frame data_6e_44e7_PlayerFrame_032                ; $20  bank $6e   9 pieces
    player_frame data_6e_4510_PlayerFrame_033                ; $21  bank $6e   9 pieces
    player_frame data_6e_4539_PlayerFrame_034                ; $22  bank $6e   9 pieces
    player_frame data_6e_4562_PlayerFrame_035                ; $23  bank $6e   8 pieces
    player_frame data_6e_4587_PlayerFrame_036                ; $24  bank $6e   6 pieces
    player_frame data_6e_45a4_PlayerFrame_037                ; $25  bank $6e   6 pieces
    player_frame data_6e_45c1_PlayerFrame_038                ; $26  bank $6e   6 pieces
    player_frame data_6e_45de_PlayerFrame_039                ; $27  bank $6e   4 pieces
    player_frame data_6e_45f3_PlayerFrame_040                ; $28  bank $6e   4 pieces
    player_frame data_6e_4608_PlayerFrame_041                ; $29  bank $6e   4 pieces
    player_frame data_6e_461d_PlayerFrame_042                ; $2a  bank $6e   7 pieces
    player_frame data_6e_463e_PlayerFrame_043                ; $2b  bank $6e   8 pieces
    player_frame data_6e_4663_PlayerFrame_044                ; $2c  bank $6e   7 pieces
    player_frame data_6e_4684_PlayerFrame_045                ; $2d  bank $6e   9 pieces
    player_frame data_6e_46ad_PlayerFrame_046                ; $2e  bank $6e   8 pieces
    player_frame data_6e_46d2_PlayerFrame_047                ; $2f  bank $6e  10 pieces
    player_frame data_6e_46ff_PlayerFrame_048                ; $30  bank $6e   8 pieces
    player_frame data_6e_4724_PlayerFrame_049                ; $31  bank $6e  10 pieces
    player_frame data_6e_4751_PlayerFrame_050                ; $32  bank $6e  10 pieces
    player_frame data_6e_477e_PlayerFrame_051                ; $33  bank $6e   9 pieces
    player_frame data_6e_47a7_PlayerFrame_052                ; $34  bank $6e   9 pieces
    player_frame data_6e_47d0_PlayerFrame_053                ; $35  bank $6e   9 pieces
    player_frame data_6f_4000_PlayerFrame_054                ; $36  bank $6f   8 pieces
    player_frame data_6f_4025_PlayerFrame_055                ; $37  bank $6f   7 pieces
    player_frame data_6f_4046_PlayerFrame_056                ; $38  bank $6f   7 pieces
    player_frame data_6f_4067_PlayerFrame_057                ; $39  bank $6f   8 pieces
    player_frame data_6f_408c_PlayerFrame_058                ; $3a  bank $6f   8 pieces
    player_frame data_6f_40b1_PlayerFrame_059                ; $3b  bank $6f   7 pieces
    player_frame data_6f_40d2_PlayerFrame_060                ; $3c  bank $6f   7 pieces
    player_frame data_6f_40f3_PlayerFrame_061                ; $3d  bank $6f   8 pieces
    player_frame data_6f_4118_PlayerFrame_062                ; $3e  bank $6f   7 pieces
    player_frame data_6f_4139_PlayerFrame_063                ; $3f  bank $6f   9 pieces
    player_frame data_6f_4162_PlayerFrame_064                ; $40  bank $6f   9 pieces
    player_frame data_6f_418b_PlayerFrame_065                ; $41  bank $6f   9 pieces
    player_frame data_6f_41b4_PlayerFrame_066                ; $42  bank $6f   8 pieces
    player_frame data_6f_41d9_PlayerFrame_067                ; $43  bank $6f   7 pieces
    player_frame data_6f_41fa_PlayerFrame_068                ; $44  bank $6f   7 pieces
    player_frame data_6f_421b_PlayerFrame_069                ; $45  bank $6f   8 pieces
    player_frame data_6f_4240_PlayerFrame_070                ; $46  bank $6f   7 pieces
    player_frame data_6f_4261_PlayerFrame_071                ; $47  bank $6f   8 pieces
    player_frame data_6f_4286_PlayerFrame_072                ; $48  bank $6f   5 pieces
    player_frame data_6f_429f_PlayerFrame_073                ; $49  bank $6f   5 pieces
    player_frame data_6f_42b8_PlayerFrame_074                ; $4a  bank $6f   4 pieces
    player_frame data_6f_42cd_PlayerFrame_075                ; $4b  bank $6f   5 pieces
    player_frame data_6f_42e6_PlayerFrame_076                ; $4c  bank $6f   4 pieces
    player_frame data_6f_42fb_PlayerFrame_077                ; $4d  bank $6f   5 pieces
    player_frame data_6f_4314_PlayerFrame_078                ; $4e  bank $6f   6 pieces
    player_frame data_6f_4331_PlayerFrame_079                ; $4f  bank $6f   6 pieces
    player_frame data_6f_434e_PlayerFrame_080                ; $50  bank $6f   5 pieces
    player_frame data_6f_4367_PlayerFrame_081                ; $51  bank $6f   5 pieces
    player_frame data_6f_4380_PlayerFrame_082                ; $52  bank $6f   6 pieces
    player_frame data_6f_439d_PlayerFrame_083                ; $53  bank $6f   6 pieces
    player_frame data_6f_43ba_PlayerFrame_084                ; $54  bank $6f   5 pieces
    player_frame data_6f_43d3_PlayerFrame_085                ; $55  bank $6f   5 pieces
    player_frame data_6f_43ec_PlayerFrame_086                ; $56  bank $6f   5 pieces
    player_frame data_6f_4405_PlayerFrame_087                ; $57  bank $6f   4 pieces
    player_frame data_6f_441a_PlayerFrame_088                ; $58  bank $6f   4 pieces
    player_frame data_6f_442f_PlayerFrame_089                ; $59  bank $6f   5 pieces
    player_frame data_6f_4448_PlayerFrame_090                ; $5a  bank $6f   4 pieces
    player_frame data_6f_445d_PlayerFrame_091                ; $5b  bank $6f   4 pieces
    player_frame data_6f_4472_PlayerFrame_092                ; $5c  bank $6f   4 pieces
    player_frame data_6f_4487_PlayerFrame_093                ; $5d  bank $6f   7 pieces
    player_frame data_6f_44a8_PlayerFrame_094                ; $5e  bank $6f   7 pieces
    player_frame data_6f_44c9_PlayerFrame_095                ; $5f  bank $6f   6 pieces
    player_frame data_6f_44e6_PlayerFrame_096                ; $60  bank $6f   6 pieces
    player_frame data_6f_4503_PlayerFrame_097                ; $61  bank $6f   8 pieces
    player_frame data_6f_4528_PlayerFrame_098                ; $62  bank $6f   8 pieces
    player_frame data_6f_454d_PlayerFrame_099                ; $63  bank $6f   8 pieces
    player_frame data_6f_4572_PlayerFrame_100                ; $64  bank $6f   7 pieces
    player_frame data_6f_4593_PlayerFrame_101                ; $65  bank $6f   7 pieces
    player_frame data_6f_45b4_PlayerFrame_102                ; $66  bank $6f   7 pieces
    player_frame data_6f_45d5_PlayerFrame_103                ; $67  bank $6f   7 pieces
    player_frame data_6f_45f6_PlayerFrame_104                ; $68  bank $6f   7 pieces
    player_frame data_6f_4617_PlayerFrame_105                ; $69  bank $6f   8 pieces
    player_frame data_6f_463c_PlayerFrame_106                ; $6a  bank $6f   8 pieces
    player_frame data_6f_4661_PlayerFrame_107                ; $6b  bank $6f   8 pieces
    player_frame data_6f_4686_PlayerFrame_108                ; $6c  bank $6f   7 pieces
    player_frame data_6f_46a7_PlayerFrame_109                ; $6d  bank $6f   7 pieces
    player_frame data_6f_46c8_PlayerFrame_110                ; $6e  bank $6f   8 pieces
    player_frame data_6f_46ed_PlayerFrame_111                ; $6f  bank $6f   6 pieces
    player_frame data_6f_470a_PlayerFrame_112                ; $70  bank $6f   6 pieces
    player_frame data_6f_4727_PlayerFrame_113                ; $71  bank $6f   7 pieces
    player_frame data_6f_4748_PlayerFrame_114                ; $72  bank $6f   8 pieces
    player_frame data_6f_476d_PlayerFrame_115                ; $73  bank $6f   9 pieces
    player_frame data_6f_4796_PlayerFrame_116                ; $74  bank $6f   8 pieces
    player_frame data_6f_47bb_PlayerFrame_117                ; $75  bank $6f   8 pieces
    player_frame data_6f_47e0_PlayerFrame_118                ; $76  bank $6f   8 pieces
    player_frame data_6f_4805_PlayerFrame_119                ; $77  bank $6f   8 pieces
    player_frame data_70_4000_PlayerFrame_120                ; $78  bank $70   8 pieces
    player_frame data_70_4025_PlayerFrame_121                ; $79  bank $70   8 pieces
    player_frame data_70_404a_PlayerFrame_122                ; $7a  bank $70   8 pieces
    player_frame data_70_406f_PlayerFrame_123                ; $7b  bank $70   8 pieces
    player_frame data_70_4094_PlayerFrame_124                ; $7c  bank $70   8 pieces
    player_frame data_70_40b9_PlayerFrame_125                ; $7d  bank $70   4 pieces
    player_frame data_70_40ce_PlayerFrame_126                ; $7e  bank $70   4 pieces
    player_frame data_70_40e3_PlayerFrame_127                ; $7f  bank $70   4 pieces
    player_frame data_70_40f8_PlayerFrame_128                ; $80  bank $70   4 pieces
    player_frame data_70_410d_PlayerFrame_129                ; $81  bank $70   4 pieces
    player_frame data_70_4122_PlayerFrame_130                ; $82  bank $70   4 pieces
    player_frame data_70_4137_PlayerFrame_131                ; $83  bank $70   4 pieces
    player_frame data_70_414c_PlayerFrame_132                ; $84  bank $70   8 pieces
    player_frame data_70_4171_PlayerFrame_133                ; $85  bank $70   8 pieces
    player_frame data_70_4196_PlayerFrame_134                ; $86  bank $70   8 pieces
    player_frame data_70_41bb_PlayerFrame_135                ; $87  bank $70   8 pieces
    player_frame data_70_41e0_PlayerFrame_136                ; $88  bank $70   7 pieces
    player_frame data_70_4201_PlayerFrame_137                ; $89  bank $70   7 pieces
    player_frame data_70_4222_PlayerFrame_138                ; $8a  bank $70   8 pieces
    player_frame data_70_4247_PlayerFrame_139                ; $8b  bank $70   8 pieces
    player_frame data_70_426c_PlayerFrame_140                ; $8c  bank $70   8 pieces
    player_frame data_70_4291_PlayerFrame_141                ; $8d  bank $70   7 pieces
    player_frame data_70_42b2_PlayerFrame_142                ; $8e  bank $70   7 pieces
    player_frame data_70_42d3_PlayerFrame_143                ; $8f  bank $70   7 pieces
    player_frame data_70_42f4_PlayerFrame_144                ; $90  bank $70   7 pieces
    player_frame data_70_4315_PlayerFrame_145                ; $91  bank $70   7 pieces
    player_frame data_70_4336_PlayerFrame_146                ; $92  bank $70   7 pieces
    player_frame data_70_4357_PlayerFrame_147                ; $93  bank $70   7 pieces
    player_frame data_70_4378_PlayerFrame_148                ; $94  bank $70   7 pieces
    player_frame data_70_4399_PlayerFrame_149                ; $95  bank $70   7 pieces
    player_frame data_70_43ba_PlayerFrame_150                ; $96  bank $70   7 pieces
    player_frame data_70_43db_PlayerFrame_151                ; $97  bank $70   7 pieces
    player_frame data_70_43fc_PlayerFrame_152                ; $98  bank $70   7 pieces
    player_frame data_70_441d_PlayerFrame_153                ; $99  bank $70   7 pieces
    player_frame data_70_443e_PlayerFrame_154                ; $9a  bank $70   7 pieces
    player_frame data_70_445f_PlayerFrame_155                ; $9b  bank $70   7 pieces
    player_frame data_70_4480_PlayerFrame_156                ; $9c  bank $70   7 pieces
    player_frame data_70_44a1_PlayerFrame_157                ; $9d  bank $70  11 pieces
    player_frame data_70_44d2_PlayerFrame_158                ; $9e  bank $70   8 pieces
    player_frame data_70_44f7_PlayerFrame_159                ; $9f  bank $70   8 pieces
    player_frame data_70_451c_PlayerFrame_160                ; $a0  bank $70   8 pieces
    player_frame data_70_4541_PlayerFrame_161                ; $a1  bank $70   8 pieces
    player_frame data_70_4566_PlayerFrame_162                ; $a2  bank $70   9 pieces
    player_frame data_70_458f_PlayerFrame_163                ; $a3  bank $70   8 pieces
    player_frame data_70_45b4_PlayerFrame_164                ; $a4  bank $70   5 pieces
    player_frame data_70_45cd_PlayerFrame_165                ; $a5  bank $70   6 pieces
    player_frame data_70_45ea_PlayerFrame_166                ; $a6  bank $70   5 pieces
    player_frame data_70_4603_PlayerFrame_167                ; $a7  bank $70   3 pieces
    player_frame data_70_4614_PlayerFrame_168                ; $a8  bank $70   2 pieces
    player_frame data_70_4621_PlayerFrame_169                ; $a9  bank $70   9 pieces
    player_frame data_70_464a_PlayerFrame_170                ; $aa  bank $70   8 pieces
    player_frame data_70_466f_PlayerFrame_171                ; $ab  bank $70   8 pieces
    player_frame data_70_4694_PlayerFrame_172                ; $ac  bank $70   6 pieces
    player_frame data_70_46b1_PlayerFrame_173                ; $ad  bank $70   4 pieces
    player_frame data_70_46c6_PlayerFrame_174                ; $ae  bank $70   4 pieces
    player_frame data_70_46db_PlayerFrame_175                ; $af  bank $70   3 pieces
    player_frame data_70_46ec_PlayerFrame_176                ; $b0  bank $70   3 pieces
    player_frame data_70_46fd_PlayerFrame_177                ; $b1  bank $70   3 pieces
    player_frame data_70_470e_PlayerFrame_178                ; $b2  bank $70   7 pieces
    player_frame data_70_472f_PlayerFrame_179                ; $b3  bank $70   4 pieces
    player_frame data_70_4744_PlayerFrame_180                ; $b4  bank $70   4 pieces
    player_frame data_70_4759_PlayerFrame_181                ; $b5  bank $70   4 pieces
    player_frame data_70_476e_PlayerFrame_182                ; $b6  bank $70   5 pieces
    player_frame data_70_4787_PlayerFrame_183                ; $b7  bank $70   4 pieces
    player_frame data_70_479c_PlayerFrame_184                ; $b8  bank $70   5 pieces
    player_frame data_70_47b5_PlayerFrame_185                ; $b9  bank $70   5 pieces
    player_frame data_70_47ce_PlayerFrame_186                ; $ba  bank $70   5 pieces
    player_frame data_70_47e7_PlayerFrame_187                ; $bb  bank $70   5 pieces
    player_frame data_70_4800_PlayerFrame_188                ; $bc  bank $70   5 pieces
    player_frame data_70_4819_PlayerFrame_189                ; $bd  bank $70   5 pieces
    player_frame data_70_4832_PlayerFrame_190                ; $be  bank $70   5 pieces
    player_frame data_71_4000_PlayerFrame_191                ; $bf  bank $71   6 pieces
    player_frame data_71_401d_PlayerFrame_192                ; $c0  bank $71   5 pieces
    player_frame data_71_4036_PlayerFrame_193                ; $c1  bank $71   6 pieces
    player_frame data_71_4053_PlayerFrame_194                ; $c2  bank $71   5 pieces
    player_frame data_71_406c_PlayerFrame_195                ; $c3  bank $71   6 pieces
    player_frame data_71_4089_PlayerFrame_196                ; $c4  bank $71   5 pieces
    player_frame data_71_40a2_PlayerFrame_197                ; $c5  bank $71   7 pieces
    player_frame data_71_40c3_PlayerFrame_198                ; $c6  bank $71   6 pieces
    player_frame data_71_40e0_PlayerFrame_199                ; $c7  bank $71  10 pieces
    player_frame data_71_410d_PlayerFrame_200                ; $c8  bank $71   9 pieces
    player_frame data_71_4136_PlayerFrame_201                ; $c9  bank $71   8 pieces
    player_frame data_71_415b_PlayerFrame_202                ; $ca  bank $71   9 pieces
    player_frame data_71_4184_PlayerFrame_203                ; $cb  bank $71   7 pieces
    player_frame data_71_41a5_PlayerFrame_204                ; $cc  bank $71   8 pieces
    player_frame data_71_41ca_PlayerFrame_205                ; $cd  bank $71   7 pieces
    player_frame data_71_41eb_PlayerFrame_206                ; $ce  bank $71   6 pieces
    player_frame data_71_4208_PlayerFrame_207                ; $cf  bank $71   8 pieces
    player_frame data_71_422d_PlayerFrame_208                ; $d0  bank $71   8 pieces
    player_frame data_71_4252_PlayerFrame_209                ; $d1  bank $71   9 pieces
    player_frame data_71_427b_PlayerFrame_210                ; $d2  bank $71   9 pieces
    player_frame data_71_42a4_PlayerFrame_211                ; $d3  bank $71   9 pieces
    player_frame data_71_42cd_PlayerFrame_212                ; $d4  bank $71   9 pieces
    player_frame data_71_42f6_PlayerFrame_213                ; $d5  bank $71   7 pieces
    player_frame data_71_4317_PlayerFrame_214                ; $d6  bank $71  10 pieces
    player_frame data_71_4344_PlayerFrame_215                ; $d7  bank $71  10 pieces
    player_frame data_71_4371_PlayerFrame_216                ; $d8  bank $71   8 pieces
    player_frame data_71_4396_PlayerFrame_217                ; $d9  bank $71   9 pieces
    player_frame data_71_43bf_PlayerFrame_218                ; $da  bank $71   8 pieces
    player_frame data_71_43e4_PlayerFrame_219                ; $db  bank $71   7 pieces
    player_frame data_71_4405_PlayerFrame_220                ; $dc  bank $71   9 pieces
    player_frame data_71_442e_PlayerFrame_221                ; $dd  bank $71   9 pieces
    player_frame data_71_4457_PlayerFrame_222                ; $de  bank $71   9 pieces
    player_frame data_71_4480_PlayerFrame_223                ; $df  bank $71   8 pieces
    player_frame data_71_44a5_PlayerFrame_224                ; $e0  bank $71   9 pieces
    player_frame data_71_44ce_PlayerFrame_225                ; $e1  bank $71   9 pieces
    player_frame data_71_44f7_PlayerFrame_226                ; $e2  bank $71   9 pieces
    player_frame data_71_4520_PlayerFrame_227                ; $e3  bank $71   9 pieces
    player_frame data_71_4549_PlayerFrame_228                ; $e4  bank $71   8 pieces
    player_frame data_71_456e_PlayerFrame_229                ; $e5  bank $71   8 pieces
    player_frame data_71_4593_PlayerFrame_230                ; $e6  bank $71   9 pieces
    player_frame data_71_45bc_PlayerFrame_231                ; $e7  bank $71   8 pieces
    player_frame data_71_45e1_PlayerFrame_232                ; $e8  bank $71  10 pieces
    player_frame data_71_460e_PlayerFrame_233                ; $e9  bank $71   8 pieces
    player_frame data_71_4633_PlayerFrame_234                ; $ea  bank $71  10 pieces
    player_frame data_71_4660_PlayerFrame_235                ; $eb  bank $71   8 pieces
    player_frame data_71_4685_PlayerFrame_236                ; $ec  bank $71  10 pieces

data_7f_4cf7_PlayerFrames_GextremeSports1:
    DEF PLAYER_GFX_SET_BASE = BANK(data_6c_4000_PlayerFrame_001)
; PLAYER_GFX_SET_GEXTREME_SPORTS1: 81 frames in banks $6c-$6d, directory $4cf7-$4dec
; Used by Gextreme Sports 1, and by nothing else. Its frame list is a fraction of the
; size of a walking set's - 81 frames against 236 - which is what a level with a
; restricted move set needs, and what a level where Gex walks around does not
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_6c_4000_PlayerFrame_001                ; $01  bank $6c   8 pieces
    player_frame data_6c_4025_PlayerFrame_002                ; $02  bank $6c   9 pieces
    player_frame data_6c_404e_PlayerFrame_003                ; $03  bank $6c   8 pieces
    player_frame data_6c_4073_PlayerFrame_004                ; $04  bank $6c   9 pieces
    player_frame data_6c_409c_PlayerFrame_005                ; $05  bank $6c   7 pieces
    player_frame data_6c_40bd_PlayerFrame_006                ; $06  bank $6c   8 pieces
    player_frame data_6c_40e2_PlayerFrame_007                ; $07  bank $6c  10 pieces
    player_frame data_6c_410f_PlayerFrame_008                ; $08  bank $6c  10 pieces
    player_frame data_6c_413c_PlayerFrame_009                ; $09  bank $6c   9 pieces
    player_frame data_6c_4165_PlayerFrame_010                ; $0a  bank $6c   9 pieces
    player_frame data_6c_418e_PlayerFrame_011                ; $0b  bank $6c   7 pieces
    player_frame data_6c_41af_PlayerFrame_012                ; $0c  bank $6c   6 pieces
    player_frame data_6c_41cc_PlayerFrame_013                ; $0d  bank $6c   6 pieces
    player_frame data_6c_41e9_PlayerFrame_014                ; $0e  bank $6c   7 pieces
    player_frame data_6c_420a_PlayerFrame_015                ; $0f  bank $6c   7 pieces
    player_frame data_6c_422b_PlayerFrame_016                ; $10  bank $6c   6 pieces
    player_frame data_6c_4248_PlayerFrame_017                ; $11  bank $6c   6 pieces
    player_frame data_6c_4265_PlayerFrame_018                ; $12  bank $6c   9 pieces
    player_frame data_6c_428e_PlayerFrame_019                ; $13  bank $6c   7 pieces
    player_frame data_6c_42af_PlayerFrame_020                ; $14  bank $6c   6 pieces
    player_frame data_6c_42cc_PlayerFrame_021                ; $15  bank $6c   8 pieces
    player_frame data_6c_42f1_PlayerFrame_022                ; $16  bank $6c   9 pieces
    player_frame data_6c_431a_PlayerFrame_023                ; $17  bank $6c   7 pieces
    player_frame data_6c_433b_PlayerFrame_024                ; $18  bank $6c   7 pieces
    player_frame data_6c_435c_PlayerFrame_025                ; $19  bank $6c   7 pieces
    player_frame data_6c_437d_PlayerFrame_026                ; $1a  bank $6c   8 pieces
    player_frame data_6c_43a2_PlayerFrame_027                ; $1b  bank $6c   7 pieces
    player_frame data_6c_43c3_PlayerFrame_028                ; $1c  bank $6c   6 pieces
    player_frame data_6c_43e0_PlayerFrame_029                ; $1d  bank $6c   7 pieces
    player_frame data_6c_4401_PlayerFrame_030                ; $1e  bank $6c   8 pieces
    player_frame data_6c_4426_PlayerFrame_031                ; $1f  bank $6c   7 pieces
    player_frame data_6c_4447_PlayerFrame_032                ; $20  bank $6c   6 pieces
    player_frame data_6c_4464_PlayerFrame_033                ; $21  bank $6c   7 pieces
    player_frame data_6c_4485_PlayerFrame_034                ; $22  bank $6c   9 pieces
    player_frame data_6c_44ae_PlayerFrame_035                ; $23  bank $6c   7 pieces
    player_frame data_6c_44cf_PlayerFrame_036                ; $24  bank $6c   6 pieces
    player_frame data_6c_44ec_PlayerFrame_037                ; $25  bank $6c   7 pieces
    player_frame data_6c_450d_PlayerFrame_038                ; $26  bank $6c   8 pieces
    player_frame data_6c_4532_PlayerFrame_039                ; $27  bank $6c   7 pieces
    player_frame data_6c_4553_PlayerFrame_040                ; $28  bank $6c   6 pieces
    player_frame data_6c_4570_PlayerFrame_041                ; $29  bank $6c   7 pieces
    player_frame data_6c_4591_PlayerFrame_042                ; $2a  bank $6c   8 pieces
    player_frame data_6c_45b6_PlayerFrame_043                ; $2b  bank $6c   6 pieces
    player_frame data_6c_45d3_PlayerFrame_044                ; $2c  bank $6c   5 pieces
    player_frame data_6c_45ec_PlayerFrame_045                ; $2d  bank $6c   7 pieces
    player_frame data_6c_460d_PlayerFrame_046                ; $2e  bank $6c   8 pieces
    player_frame data_6c_4632_PlayerFrame_047                ; $2f  bank $6c   7 pieces
    player_frame data_6c_4653_PlayerFrame_048                ; $30  bank $6c   6 pieces
    player_frame data_6c_4670_PlayerFrame_049                ; $31  bank $6c   7 pieces
    player_frame data_6c_4691_PlayerFrame_050                ; $32  bank $6c   8 pieces
    player_frame data_6c_46b6_PlayerFrame_051                ; $33  bank $6c   9 pieces
    player_frame data_6c_46df_PlayerFrame_052                ; $34  bank $6c   9 pieces
    player_frame data_6c_4708_PlayerFrame_053                ; $35  bank $6c   9 pieces
    player_frame data_6c_4731_PlayerFrame_054                ; $36  bank $6c   9 pieces
    player_frame data_6c_475a_PlayerFrame_055                ; $37  bank $6c  10 pieces
    player_frame data_6c_4787_PlayerFrame_056                ; $38  bank $6c  10 pieces
    player_frame data_6c_47b4_PlayerFrame_057                ; $39  bank $6c   9 pieces
    player_frame data_6c_47dd_PlayerFrame_058                ; $3a  bank $6c   7 pieces
    player_frame data_6c_47fe_PlayerFrame_059                ; $3b  bank $6c   4 pieces
    player_frame data_6c_4813_PlayerFrame_060                ; $3c  bank $6c   3 pieces
    player_frame data_6d_4000_PlayerFrame_061                ; $3d  bank $6d   2 pieces
    player_frame data_6d_400d_PlayerFrame_062                ; $3e  bank $6d   9 pieces
    player_frame data_6d_4036_PlayerFrame_063                ; $3f  bank $6d   9 pieces
    player_frame data_6d_405f_PlayerFrame_064                ; $40  bank $6d   9 pieces
    player_frame data_6d_4088_PlayerFrame_065                ; $41  bank $6d   7 pieces
    player_frame data_6d_40a9_PlayerFrame_066                ; $42  bank $6d   7 pieces
    player_frame data_6d_40ca_PlayerFrame_067                ; $43  bank $6d   4 pieces
    player_frame data_6d_40df_PlayerFrame_068                ; $44  bank $6d   3 pieces
    player_frame data_6d_40f0_PlayerFrame_069                ; $45  bank $6d   3 pieces
    player_frame data_6d_4101_PlayerFrame_070                ; $46  bank $6d   9 pieces
    player_frame data_6d_412a_PlayerFrame_071                ; $47  bank $6d   7 pieces
    player_frame data_6d_414b_PlayerFrame_072                ; $48  bank $6d   8 pieces
    player_frame data_6d_4170_PlayerFrame_073                ; $49  bank $6d   7 pieces
    player_frame data_6d_4191_PlayerFrame_074                ; $4a  bank $6d   7 pieces
    player_frame data_6d_41b2_PlayerFrame_075                ; $4b  bank $6d  11 pieces
    player_frame data_6d_41e3_PlayerFrame_076                ; $4c  bank $6d  10 pieces
    player_frame data_6d_4210_PlayerFrame_077                ; $4d  bank $6d   7 pieces
    player_frame data_6d_4231_PlayerFrame_078                ; $4e  bank $6d   9 pieces
    player_frame data_6d_425a_PlayerFrame_079                ; $4f  bank $6d   7 pieces
    player_frame data_6d_427b_PlayerFrame_080                ; $50  bank $6d   8 pieces
    player_frame data_6d_42a0_PlayerFrame_081                ; $51  bank $6d   8 pieces

data_7f_4ded_PlayerFrames_WesternStation:
    DEF PLAYER_GFX_SET_BASE = BANK(data_67_4000_PlayerFrame_001)
; PLAYER_GFX_SET_WESTERN_STATION: 236 frames in banks $67-$6b, directory $4ded-$50b3
; Used by Western Station 1-9
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_67_4000_PlayerFrame_001                ; $01  bank $67  10 pieces
    player_frame data_67_402d_PlayerFrame_002                ; $02  bank $67  10 pieces
    player_frame data_67_405a_PlayerFrame_003                ; $03  bank $67   9 pieces
    player_frame data_67_4083_PlayerFrame_004                ; $04  bank $67   8 pieces
    player_frame data_67_40a8_PlayerFrame_005                ; $05  bank $67  10 pieces
    player_frame data_67_40d5_PlayerFrame_006                ; $06  bank $67  10 pieces
    player_frame data_67_4102_PlayerFrame_007                ; $07  bank $67  10 pieces
    player_frame data_67_412f_PlayerFrame_008                ; $08  bank $67  10 pieces
    player_frame data_67_415c_PlayerFrame_009                ; $09  bank $67  10 pieces
    player_frame data_67_4189_PlayerFrame_010                ; $0a  bank $67  10 pieces
    player_frame data_67_41b6_PlayerFrame_011                ; $0b  bank $67  10 pieces
    player_frame data_67_41e3_PlayerFrame_012                ; $0c  bank $67   9 pieces
    player_frame data_67_420c_PlayerFrame_013                ; $0d  bank $67   9 pieces
    player_frame data_67_4235_PlayerFrame_014                ; $0e  bank $67  10 pieces
    player_frame data_67_4262_PlayerFrame_015                ; $0f  bank $67  10 pieces
    player_frame data_67_428f_PlayerFrame_016                ; $10  bank $67  11 pieces
    player_frame data_67_42c0_PlayerFrame_017                ; $11  bank $67  10 pieces
    player_frame data_67_42ed_PlayerFrame_018                ; $12  bank $67   9 pieces
    player_frame data_67_4316_PlayerFrame_019                ; $13  bank $67   9 pieces
    player_frame data_67_433f_PlayerFrame_020                ; $14  bank $67  10 pieces
    player_frame data_67_436c_PlayerFrame_021                ; $15  bank $67  10 pieces
    player_frame data_67_4399_PlayerFrame_022                ; $16  bank $67  10 pieces
    player_frame data_67_43c6_PlayerFrame_023                ; $17  bank $67  10 pieces
    player_frame data_67_43f3_PlayerFrame_024                ; $18  bank $67  10 pieces
    player_frame data_67_4420_PlayerFrame_025                ; $19  bank $67  10 pieces
    player_frame data_67_444d_PlayerFrame_026                ; $1a  bank $67  10 pieces
    player_frame data_67_447a_PlayerFrame_027                ; $1b  bank $67  10 pieces
    player_frame data_67_44a7_PlayerFrame_028                ; $1c  bank $67   9 pieces
    player_frame data_67_44d0_PlayerFrame_029                ; $1d  bank $67   7 pieces
    player_frame data_67_44f1_PlayerFrame_030                ; $1e  bank $67   9 pieces
    player_frame data_67_451a_PlayerFrame_031                ; $1f  bank $67  10 pieces
    player_frame data_67_4547_PlayerFrame_032                ; $20  bank $67   9 pieces
    player_frame data_67_4570_PlayerFrame_033                ; $21  bank $67   9 pieces
    player_frame data_67_4599_PlayerFrame_034                ; $22  bank $67   9 pieces
    player_frame data_67_45c2_PlayerFrame_035                ; $23  bank $67   9 pieces
    player_frame data_67_45eb_PlayerFrame_036                ; $24  bank $67   7 pieces
    player_frame data_67_460c_PlayerFrame_037                ; $25  bank $67   6 pieces
    player_frame data_67_4629_PlayerFrame_038                ; $26  bank $67   6 pieces
    player_frame data_67_4646_PlayerFrame_039                ; $27  bank $67   6 pieces
    player_frame data_67_4663_PlayerFrame_040                ; $28  bank $67   6 pieces
    player_frame data_67_4680_PlayerFrame_041                ; $29  bank $67   6 pieces
    player_frame data_67_469d_PlayerFrame_042                ; $2a  bank $67  10 pieces
    player_frame data_67_46ca_PlayerFrame_043                ; $2b  bank $67   8 pieces
    player_frame data_67_46ef_PlayerFrame_044                ; $2c  bank $67   7 pieces
    player_frame data_67_4710_PlayerFrame_045                ; $2d  bank $67   9 pieces
    player_frame data_67_4739_PlayerFrame_046                ; $2e  bank $67  10 pieces
    player_frame data_67_4766_PlayerFrame_047                ; $2f  bank $67  10 pieces
    player_frame data_67_4793_PlayerFrame_048                ; $30  bank $67  10 pieces
    player_frame data_67_47c0_PlayerFrame_049                ; $31  bank $67   9 pieces
    player_frame data_68_4000_PlayerFrame_050                ; $32  bank $68  10 pieces
    player_frame data_68_402d_PlayerFrame_051                ; $33  bank $68  10 pieces
    player_frame data_68_405a_PlayerFrame_052                ; $34  bank $68   9 pieces
    player_frame data_68_4083_PlayerFrame_053                ; $35  bank $68   8 pieces
    player_frame data_68_40a8_PlayerFrame_054                ; $36  bank $68   7 pieces
    player_frame data_68_40c9_PlayerFrame_055                ; $37  bank $68   7 pieces
    player_frame data_68_40ea_PlayerFrame_056                ; $38  bank $68   8 pieces
    player_frame data_68_410f_PlayerFrame_057                ; $39  bank $68   7 pieces
    player_frame data_68_4130_PlayerFrame_058                ; $3a  bank $68   7 pieces
    player_frame data_68_4151_PlayerFrame_059                ; $3b  bank $68   7 pieces
    player_frame data_68_4172_PlayerFrame_060                ; $3c  bank $68   8 pieces
    player_frame data_68_4197_PlayerFrame_061                ; $3d  bank $68   7 pieces
    player_frame data_68_41b8_PlayerFrame_062                ; $3e  bank $68   7 pieces
    player_frame data_68_41d9_PlayerFrame_063                ; $3f  bank $68   9 pieces
    player_frame data_68_4202_PlayerFrame_064                ; $40  bank $68   9 pieces
    player_frame data_68_422b_PlayerFrame_065                ; $41  bank $68   9 pieces
    player_frame data_68_4254_PlayerFrame_066                ; $42  bank $68   9 pieces
    player_frame data_68_427d_PlayerFrame_067                ; $43  bank $68   8 pieces
    player_frame data_68_42a2_PlayerFrame_068                ; $44  bank $68   8 pieces
    player_frame data_68_42c7_PlayerFrame_069                ; $45  bank $68   8 pieces
    player_frame data_68_42ec_PlayerFrame_070                ; $46  bank $68   8 pieces
    player_frame data_68_4311_PlayerFrame_071                ; $47  bank $68   8 pieces
    player_frame data_68_4336_PlayerFrame_072                ; $48  bank $68   5 pieces
    player_frame data_68_434f_PlayerFrame_073                ; $49  bank $68   5 pieces
    player_frame data_68_4368_PlayerFrame_074                ; $4a  bank $68   5 pieces
    player_frame data_68_4381_PlayerFrame_075                ; $4b  bank $68   6 pieces
    player_frame data_68_439e_PlayerFrame_076                ; $4c  bank $68   6 pieces
    player_frame data_68_43bb_PlayerFrame_077                ; $4d  bank $68   6 pieces
    player_frame data_68_43d8_PlayerFrame_078                ; $4e  bank $68   6 pieces
    player_frame data_68_43f5_PlayerFrame_079                ; $4f  bank $68   7 pieces
    player_frame data_68_4416_PlayerFrame_080                ; $50  bank $68   7 pieces
    player_frame data_68_4437_PlayerFrame_081                ; $51  bank $68   5 pieces
    player_frame data_68_4450_PlayerFrame_082                ; $52  bank $68   7 pieces
    player_frame data_68_4471_PlayerFrame_083                ; $53  bank $68   7 pieces
    player_frame data_68_4492_PlayerFrame_084                ; $54  bank $68   6 pieces
    player_frame data_68_44af_PlayerFrame_085                ; $55  bank $68   6 pieces
    player_frame data_68_44cc_PlayerFrame_086                ; $56  bank $68   8 pieces
    player_frame data_68_44f1_PlayerFrame_087                ; $57  bank $68   6 pieces
    player_frame data_68_450e_PlayerFrame_088                ; $58  bank $68   6 pieces
    player_frame data_68_452b_PlayerFrame_089                ; $59  bank $68   7 pieces
    player_frame data_68_454c_PlayerFrame_090                ; $5a  bank $68   6 pieces
    player_frame data_68_4569_PlayerFrame_091                ; $5b  bank $68   5 pieces
    player_frame data_68_4582_PlayerFrame_092                ; $5c  bank $68   7 pieces
    player_frame data_68_45a3_PlayerFrame_093                ; $5d  bank $68   9 pieces
    player_frame data_68_45cc_PlayerFrame_094                ; $5e  bank $68   9 pieces
    player_frame data_68_45f5_PlayerFrame_095                ; $5f  bank $68   9 pieces
    player_frame data_68_461e_PlayerFrame_096                ; $60  bank $68   8 pieces
    player_frame data_68_4643_PlayerFrame_097                ; $61  bank $68   7 pieces
    player_frame data_68_4664_PlayerFrame_098                ; $62  bank $68   9 pieces
    player_frame data_68_468d_PlayerFrame_099                ; $63  bank $68   9 pieces
    player_frame data_68_46b6_PlayerFrame_100                ; $64  bank $68   9 pieces
    player_frame data_68_46df_PlayerFrame_101                ; $65  bank $68   8 pieces
    player_frame data_68_4704_PlayerFrame_102                ; $66  bank $68   9 pieces
    player_frame data_68_472d_PlayerFrame_103                ; $67  bank $68   7 pieces
    player_frame data_68_474e_PlayerFrame_104                ; $68  bank $68   8 pieces
    player_frame data_68_4773_PlayerFrame_105                ; $69  bank $68   9 pieces
    player_frame data_68_479c_PlayerFrame_106                ; $6a  bank $68   9 pieces
    player_frame data_68_47c5_PlayerFrame_107                ; $6b  bank $68   9 pieces
    player_frame data_68_47ee_PlayerFrame_108                ; $6c  bank $68   8 pieces
    player_frame data_69_4000_PlayerFrame_109                ; $6d  bank $69   9 pieces
    player_frame data_69_4029_PlayerFrame_110                ; $6e  bank $69   9 pieces
    player_frame data_69_4052_PlayerFrame_111                ; $6f  bank $69   8 pieces
    player_frame data_69_4077_PlayerFrame_112                ; $70  bank $69   6 pieces
    player_frame data_69_4094_PlayerFrame_113                ; $71  bank $69   8 pieces
    player_frame data_69_40b9_PlayerFrame_114                ; $72  bank $69   9 pieces
    player_frame data_69_40e2_PlayerFrame_115                ; $73  bank $69   8 pieces
    player_frame data_69_4107_PlayerFrame_116                ; $74  bank $69   8 pieces
    player_frame data_69_412c_PlayerFrame_117                ; $75  bank $69   8 pieces
    player_frame data_69_4151_PlayerFrame_118                ; $76  bank $69   8 pieces
    player_frame data_69_4176_PlayerFrame_119                ; $77  bank $69   8 pieces
    player_frame data_69_419b_PlayerFrame_120                ; $78  bank $69   7 pieces
    player_frame data_69_41bc_PlayerFrame_121                ; $79  bank $69   8 pieces
    player_frame data_69_41e1_PlayerFrame_122                ; $7a  bank $69   8 pieces
    player_frame data_69_4206_PlayerFrame_123                ; $7b  bank $69   8 pieces
    player_frame data_69_422b_PlayerFrame_124                ; $7c  bank $69   8 pieces
    player_frame data_69_4250_PlayerFrame_125                ; $7d  bank $69   4 pieces
    player_frame data_69_4265_PlayerFrame_126                ; $7e  bank $69   4 pieces
    player_frame data_69_427a_PlayerFrame_127                ; $7f  bank $69   4 pieces
    player_frame data_69_428f_PlayerFrame_128                ; $80  bank $69   4 pieces
    player_frame data_69_42a4_PlayerFrame_129                ; $81  bank $69   4 pieces
    player_frame data_69_42b9_PlayerFrame_130                ; $82  bank $69   4 pieces
    player_frame data_69_42ce_PlayerFrame_131                ; $83  bank $69   4 pieces
    player_frame data_69_42e3_PlayerFrame_132                ; $84  bank $69   8 pieces
    player_frame data_69_4308_PlayerFrame_133                ; $85  bank $69   8 pieces
    player_frame data_69_432d_PlayerFrame_134                ; $86  bank $69   9 pieces
    player_frame data_69_4356_PlayerFrame_135                ; $87  bank $69   9 pieces
    player_frame data_69_437f_PlayerFrame_136                ; $88  bank $69   6 pieces
    player_frame data_69_439c_PlayerFrame_137                ; $89  bank $69   6 pieces
    player_frame data_69_43b9_PlayerFrame_138                ; $8a  bank $69   9 pieces
    player_frame data_69_43e2_PlayerFrame_139                ; $8b  bank $69   8 pieces
    player_frame data_69_4407_PlayerFrame_140                ; $8c  bank $69   9 pieces
    player_frame data_69_4430_PlayerFrame_141                ; $8d  bank $69   8 pieces
    player_frame data_69_4455_PlayerFrame_142                ; $8e  bank $69   8 pieces
    player_frame data_69_447a_PlayerFrame_143                ; $8f  bank $69   7 pieces
    player_frame data_69_449b_PlayerFrame_144                ; $90  bank $69   8 pieces
    player_frame data_69_44c0_PlayerFrame_145                ; $91  bank $69   8 pieces
    player_frame data_69_44e5_PlayerFrame_146                ; $92  bank $69   8 pieces
    player_frame data_69_450a_PlayerFrame_147                ; $93  bank $69   7 pieces
    player_frame data_69_452b_PlayerFrame_148                ; $94  bank $69   8 pieces
    player_frame data_69_4550_PlayerFrame_149                ; $95  bank $69   6 pieces
    player_frame data_69_456d_PlayerFrame_150                ; $96  bank $69   6 pieces
    player_frame data_69_458a_PlayerFrame_151                ; $97  bank $69   6 pieces
    player_frame data_69_45a7_PlayerFrame_152                ; $98  bank $69   6 pieces
    player_frame data_69_45c4_PlayerFrame_153                ; $99  bank $69   6 pieces
    player_frame data_69_45e1_PlayerFrame_154                ; $9a  bank $69   6 pieces
    player_frame data_69_45fe_PlayerFrame_155                ; $9b  bank $69   6 pieces
    player_frame data_69_461b_PlayerFrame_156                ; $9c  bank $69   6 pieces
    player_frame data_69_4638_PlayerFrame_157                ; $9d  bank $69   9 pieces
    player_frame data_69_4661_PlayerFrame_158                ; $9e  bank $69   9 pieces
    player_frame data_69_468a_PlayerFrame_159                ; $9f  bank $69   9 pieces
    player_frame data_69_46b3_PlayerFrame_160                ; $a0  bank $69   9 pieces
    player_frame data_69_46dc_PlayerFrame_161                ; $a1  bank $69   8 pieces
    player_frame data_69_4701_PlayerFrame_162                ; $a2  bank $69   9 pieces
    player_frame data_69_472a_PlayerFrame_163                ; $a3  bank $69   8 pieces
    player_frame data_69_474f_PlayerFrame_164                ; $a4  bank $69   9 pieces
    player_frame data_69_4778_PlayerFrame_165                ; $a5  bank $69   6 pieces
    player_frame data_69_4795_PlayerFrame_166                ; $a6  bank $69   5 pieces
    player_frame data_69_47ae_PlayerFrame_167                ; $a7  bank $69   3 pieces
    player_frame data_69_47bf_PlayerFrame_168                ; $a8  bank $69   2 pieces
    player_frame data_69_47cc_PlayerFrame_169                ; $a9  bank $69   9 pieces
    player_frame data_69_47f5_PlayerFrame_170                ; $aa  bank $69   9 pieces
    player_frame data_6a_4000_PlayerFrame_171                ; $ab  bank $6a   9 pieces
    player_frame data_6a_4029_PlayerFrame_172                ; $ac  bank $6a   6 pieces
    player_frame data_6a_4046_PlayerFrame_173                ; $ad  bank $6a   5 pieces
    player_frame data_6a_405f_PlayerFrame_174                ; $ae  bank $6a   4 pieces
    player_frame data_6a_4074_PlayerFrame_175                ; $af  bank $6a   4 pieces
    player_frame data_6a_4089_PlayerFrame_176                ; $b0  bank $6a   3 pieces
    player_frame data_6a_409a_PlayerFrame_177                ; $b1  bank $6a   2 pieces
    player_frame data_6a_40a7_PlayerFrame_178                ; $b2  bank $6a   6 pieces
    player_frame data_6a_40c4_PlayerFrame_179                ; $b3  bank $6a   6 pieces
    player_frame data_6a_40e1_PlayerFrame_180                ; $b4  bank $6a   6 pieces
    player_frame data_6a_40fe_PlayerFrame_181                ; $b5  bank $6a   6 pieces
    player_frame data_6a_411b_PlayerFrame_182                ; $b6  bank $6a   7 pieces
    player_frame data_6a_413c_PlayerFrame_183                ; $b7  bank $6a   6 pieces
    player_frame data_6a_4159_PlayerFrame_184                ; $b8  bank $6a   7 pieces
    player_frame data_6a_417a_PlayerFrame_185                ; $b9  bank $6a   7 pieces
    player_frame data_6a_419b_PlayerFrame_186                ; $ba  bank $6a   6 pieces
    player_frame data_6a_41b8_PlayerFrame_187                ; $bb  bank $6a   7 pieces
    player_frame data_6a_41d9_PlayerFrame_188                ; $bc  bank $6a   6 pieces
    player_frame data_6a_41f6_PlayerFrame_189                ; $bd  bank $6a   5 pieces
    player_frame data_6a_420f_PlayerFrame_190                ; $be  bank $6a   5 pieces
    player_frame data_6a_4228_PlayerFrame_191                ; $bf  bank $6a   7 pieces
    player_frame data_6a_4249_PlayerFrame_192                ; $c0  bank $6a   5 pieces
    player_frame data_6a_4262_PlayerFrame_193                ; $c1  bank $6a   6 pieces
    player_frame data_6a_427f_PlayerFrame_194                ; $c2  bank $6a   6 pieces
    player_frame data_6a_429c_PlayerFrame_195                ; $c3  bank $6a   6 pieces
    player_frame data_6a_42b9_PlayerFrame_196                ; $c4  bank $6a   5 pieces
    player_frame data_6a_42d2_PlayerFrame_197                ; $c5  bank $6a   7 pieces
    player_frame data_6a_42f3_PlayerFrame_198                ; $c6  bank $6a   7 pieces
    player_frame data_6a_4314_PlayerFrame_199                ; $c7  bank $6a   8 pieces
    player_frame data_6a_4339_PlayerFrame_200                ; $c8  bank $6a   7 pieces
    player_frame data_6a_435a_PlayerFrame_201                ; $c9  bank $6a   8 pieces
    player_frame data_6a_437f_PlayerFrame_202                ; $ca  bank $6a   7 pieces
    player_frame data_6a_43a0_PlayerFrame_203                ; $cb  bank $6a   7 pieces
    player_frame data_6a_43c1_PlayerFrame_204                ; $cc  bank $6a   7 pieces
    player_frame data_6a_43e2_PlayerFrame_205                ; $cd  bank $6a   7 pieces
    player_frame data_6a_4403_PlayerFrame_206                ; $ce  bank $6a   8 pieces
    player_frame data_6a_4428_PlayerFrame_207                ; $cf  bank $6a   7 pieces
    player_frame data_6a_4449_PlayerFrame_208                ; $d0  bank $6a   7 pieces
    player_frame data_6a_446a_PlayerFrame_209                ; $d1  bank $6a   7 pieces
    player_frame data_6a_448b_PlayerFrame_210                ; $d2  bank $6a   8 pieces
    player_frame data_6a_44b0_PlayerFrame_211                ; $d3  bank $6a   9 pieces
    player_frame data_6a_44d9_PlayerFrame_212                ; $d4  bank $6a   9 pieces
    player_frame data_6a_4502_PlayerFrame_213                ; $d5  bank $6a   8 pieces
    player_frame data_6a_4527_PlayerFrame_214                ; $d6  bank $6a   8 pieces
    player_frame data_6a_454c_PlayerFrame_215                ; $d7  bank $6a   9 pieces
    player_frame data_6a_4575_PlayerFrame_216                ; $d8  bank $6a  10 pieces
    player_frame data_6a_45a2_PlayerFrame_217                ; $d9  bank $6a   9 pieces
    player_frame data_6a_45cb_PlayerFrame_218                ; $da  bank $6a   8 pieces
    player_frame data_6a_45f0_PlayerFrame_219                ; $db  bank $6a  11 pieces
    player_frame data_6a_4621_PlayerFrame_220                ; $dc  bank $6a   7 pieces
    player_frame data_6a_4642_PlayerFrame_221                ; $dd  bank $6a   7 pieces
    player_frame data_6a_4663_PlayerFrame_222                ; $de  bank $6a   8 pieces
    player_frame data_6a_4688_PlayerFrame_223                ; $df  bank $6a   8 pieces
    player_frame data_6a_46ad_PlayerFrame_224                ; $e0  bank $6a  10 pieces
    player_frame data_6a_46da_PlayerFrame_225                ; $e1  bank $6a   8 pieces
    player_frame data_6a_46ff_PlayerFrame_226                ; $e2  bank $6a   9 pieces
    player_frame data_6a_4728_PlayerFrame_227                ; $e3  bank $6a   8 pieces
    player_frame data_6a_474d_PlayerFrame_228                ; $e4  bank $6a   8 pieces
    player_frame data_6a_4772_PlayerFrame_229                ; $e5  bank $6a   9 pieces
    player_frame data_6a_479b_PlayerFrame_230                ; $e6  bank $6a  10 pieces
    player_frame data_6a_47c8_PlayerFrame_231                ; $e7  bank $6a   8 pieces
    player_frame data_6a_47ed_PlayerFrame_232                ; $e8  bank $6a   8 pieces
    player_frame data_6b_4000_PlayerFrame_233                ; $e9  bank $6b   9 pieces
    player_frame data_6b_4029_PlayerFrame_234                ; $ea  bank $6b   9 pieces
    player_frame data_6b_4052_PlayerFrame_235                ; $eb  bank $6b   8 pieces
    player_frame data_6b_4077_PlayerFrame_236                ; $ec  bank $6b  10 pieces

data_7f_50b4_PlayerFrames_MarsupialMadness1:
    DEF PLAYER_GFX_SET_BASE = BANK(data_66_4000_PlayerFrame_001)
; PLAYER_GFX_SET_MARSUPIAL_MADNESS1: 41 frames in bank $66, directory $50b4-$5131
; Used by Marsupial Madness 1, and by nothing else. Its frame list is a fraction of the
; size of a walking set's - 41 frames against 236 - which is what a level with a
; restricted move set needs, and what a level where Gex walks around does not
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_66_4000_PlayerFrame_001                ; $01  bank $66   8 pieces
    player_frame data_66_4025_PlayerFrame_002                ; $02  bank $66   9 pieces
    player_frame data_66_404e_PlayerFrame_003                ; $03  bank $66   9 pieces
    player_frame data_66_4077_PlayerFrame_004                ; $04  bank $66   9 pieces
    player_frame data_66_40a0_PlayerFrame_005                ; $05  bank $66   8 pieces
    player_frame data_66_40c5_PlayerFrame_006                ; $06  bank $66   9 pieces
    player_frame data_66_40ee_PlayerFrame_007                ; $07  bank $66   6 pieces
    player_frame data_66_410b_PlayerFrame_008                ; $08  bank $66   6 pieces
    player_frame data_66_4128_PlayerFrame_009                ; $09  bank $66   4 pieces
    player_frame data_66_413d_PlayerFrame_010                ; $0a  bank $66   3 pieces
    player_frame data_66_414e_PlayerFrame_011                ; $0b  bank $66   2 pieces
    player_frame data_66_415b_PlayerFrame_012                ; $0c  bank $66   8 pieces
    player_frame data_66_4180_PlayerFrame_013                ; $0d  bank $66   7 pieces
    player_frame data_66_41a1_PlayerFrame_014                ; $0e  bank $66   6 pieces
    player_frame data_66_41be_PlayerFrame_015                ; $0f  bank $66   7 pieces
    player_frame data_66_41df_PlayerFrame_016                ; $10  bank $66   7 pieces
    player_frame data_66_4200_PlayerFrame_017                ; $11  bank $66   3 pieces
    player_frame data_66_4211_PlayerFrame_018                ; $12  bank $66   2 pieces
    player_frame data_66_421e_PlayerFrame_019                ; $13  bank $66   9 pieces
    player_frame data_66_4247_PlayerFrame_020                ; $14  bank $66   7 pieces
    player_frame data_66_4268_PlayerFrame_021                ; $15  bank $66   7 pieces
    player_frame data_66_4289_PlayerFrame_022                ; $16  bank $66   7 pieces
    player_frame data_66_42aa_PlayerFrame_023                ; $17  bank $66   8 pieces
    player_frame data_66_42cf_PlayerFrame_024                ; $18  bank $66   7 pieces
    player_frame data_66_42f0_PlayerFrame_025                ; $19  bank $66   7 pieces
    player_frame data_66_4311_PlayerFrame_026                ; $1a  bank $66   7 pieces
    player_frame data_66_4332_PlayerFrame_027                ; $1b  bank $66   7 pieces
    player_frame data_66_4353_PlayerFrame_028                ; $1c  bank $66   7 pieces
    player_frame data_66_4374_PlayerFrame_029                ; $1d  bank $66   6 pieces
    player_frame data_66_4391_PlayerFrame_030                ; $1e  bank $66   7 pieces
    player_frame data_66_43b2_PlayerFrame_031                ; $1f  bank $66   7 pieces
    player_frame data_66_43d3_PlayerFrame_032                ; $20  bank $66   8 pieces
    player_frame data_66_43f8_PlayerFrame_033                ; $21  bank $66   8 pieces
    player_frame data_66_441d_PlayerFrame_034                ; $22  bank $66   7 pieces
    player_frame data_66_443e_PlayerFrame_035                ; $23  bank $66   6 pieces
    player_frame data_66_445b_PlayerFrame_036                ; $24  bank $66   6 pieces
    player_frame data_66_4478_PlayerFrame_037                ; $25  bank $66   6 pieces
    player_frame data_66_4495_PlayerFrame_038                ; $26  bank $66   8 pieces
    player_frame data_66_44ba_PlayerFrame_039                ; $27  bank $66   8 pieces
    player_frame data_66_44df_PlayerFrame_040                ; $28  bank $66   9 pieces
    player_frame data_66_4508_PlayerFrame_041                ; $29  bank $66   8 pieces

data_7f_5132_PlayerFrames_AnimeChannel:
    DEF PLAYER_GFX_SET_BASE = BANK(data_62_4000_PlayerFrame_001)
; PLAYER_GFX_SET_ANIME_CHANNEL: 236 frames in banks $62-$65, directory $5132-$53f8
; Used by Anime Channel 1-9
;
; The piece counts in the comments are read out of the frames themselves, over in
; the graphics banks - nothing in this file carries them
    player_frame_none                                       ; $00  no frame
    player_frame data_62_4000_PlayerFrame_001                ; $01  bank $62   7 pieces
    player_frame data_62_4021_PlayerFrame_002                ; $02  bank $62   7 pieces
    player_frame data_62_4042_PlayerFrame_003                ; $03  bank $62   7 pieces
    player_frame data_62_4063_PlayerFrame_004                ; $04  bank $62   7 pieces
    player_frame data_62_4084_PlayerFrame_005                ; $05  bank $62   7 pieces
    player_frame data_62_40a5_PlayerFrame_006                ; $06  bank $62   6 pieces
    player_frame data_62_40c2_PlayerFrame_007                ; $07  bank $62   7 pieces
    player_frame data_62_40e3_PlayerFrame_008                ; $08  bank $62   7 pieces
    player_frame data_62_4104_PlayerFrame_009                ; $09  bank $62   7 pieces
    player_frame data_62_4125_PlayerFrame_010                ; $0a  bank $62   7 pieces
    player_frame data_62_4146_PlayerFrame_011                ; $0b  bank $62   7 pieces
    player_frame data_62_4167_PlayerFrame_012                ; $0c  bank $62   7 pieces
    player_frame data_62_4188_PlayerFrame_013                ; $0d  bank $62   6 pieces
    player_frame data_62_41a5_PlayerFrame_014                ; $0e  bank $62   6 pieces
    player_frame data_62_41c2_PlayerFrame_015                ; $0f  bank $62   7 pieces
    player_frame data_62_41e3_PlayerFrame_016                ; $10  bank $62   7 pieces
    player_frame data_62_4204_PlayerFrame_017                ; $11  bank $62   7 pieces
    player_frame data_62_4225_PlayerFrame_018                ; $12  bank $62   7 pieces
    player_frame data_62_4246_PlayerFrame_019                ; $13  bank $62   7 pieces
    player_frame data_62_4267_PlayerFrame_020                ; $14  bank $62   8 pieces
    player_frame data_62_428c_PlayerFrame_021                ; $15  bank $62   8 pieces
    player_frame data_62_42b1_PlayerFrame_022                ; $16  bank $62   7 pieces
    player_frame data_62_42d2_PlayerFrame_023                ; $17  bank $62   7 pieces
    player_frame data_62_42f3_PlayerFrame_024                ; $18  bank $62   7 pieces
    player_frame data_62_4314_PlayerFrame_025                ; $19  bank $62   8 pieces
    player_frame data_62_4339_PlayerFrame_026                ; $1a  bank $62   8 pieces
    player_frame data_62_435e_PlayerFrame_027                ; $1b  bank $62   8 pieces
    player_frame data_62_4383_PlayerFrame_028                ; $1c  bank $62   7 pieces
    player_frame data_62_43a4_PlayerFrame_029                ; $1d  bank $62   6 pieces
    player_frame data_62_43c1_PlayerFrame_030                ; $1e  bank $62   7 pieces
    player_frame data_62_43e2_PlayerFrame_031                ; $1f  bank $62   8 pieces
    player_frame data_62_4407_PlayerFrame_032                ; $20  bank $62   6 pieces
    player_frame data_62_4424_PlayerFrame_033                ; $21  bank $62   8 pieces
    player_frame data_62_4449_PlayerFrame_034                ; $22  bank $62   7 pieces
    player_frame data_62_446a_PlayerFrame_035                ; $23  bank $62   7 pieces
    player_frame data_62_448b_PlayerFrame_036                ; $24  bank $62   6 pieces
    player_frame data_62_44a8_PlayerFrame_037                ; $25  bank $62   5 pieces
    player_frame data_62_44c1_PlayerFrame_038                ; $26  bank $62   5 pieces
    player_frame data_62_44da_PlayerFrame_039                ; $27  bank $62   4 pieces
    player_frame data_62_44ef_PlayerFrame_040                ; $28  bank $62   4 pieces
    player_frame data_62_4504_PlayerFrame_041                ; $29  bank $62   4 pieces
    player_frame data_62_4519_PlayerFrame_042                ; $2a  bank $62   7 pieces
    player_frame data_62_453a_PlayerFrame_043                ; $2b  bank $62   6 pieces
    player_frame data_62_4557_PlayerFrame_044                ; $2c  bank $62   6 pieces
    player_frame data_62_4574_PlayerFrame_045                ; $2d  bank $62   6 pieces
    player_frame data_62_4591_PlayerFrame_046                ; $2e  bank $62   7 pieces
    player_frame data_62_45b2_PlayerFrame_047                ; $2f  bank $62   8 pieces
    player_frame data_62_45d7_PlayerFrame_048                ; $30  bank $62   6 pieces
    player_frame data_62_45f4_PlayerFrame_049                ; $31  bank $62   6 pieces
    player_frame data_62_4611_PlayerFrame_050                ; $32  bank $62   8 pieces
    player_frame data_62_4636_PlayerFrame_051                ; $33  bank $62   8 pieces
    player_frame data_62_465b_PlayerFrame_052                ; $34  bank $62   9 pieces
    player_frame data_62_4684_PlayerFrame_053                ; $35  bank $62   8 pieces
    player_frame data_62_46a9_PlayerFrame_054                ; $36  bank $62   6 pieces
    player_frame data_62_46c6_PlayerFrame_055                ; $37  bank $62   5 pieces
    player_frame data_62_46df_PlayerFrame_056                ; $38  bank $62   6 pieces
    player_frame data_62_46fc_PlayerFrame_057                ; $39  bank $62   6 pieces
    player_frame data_62_4719_PlayerFrame_058                ; $3a  bank $62   5 pieces
    player_frame data_62_4732_PlayerFrame_059                ; $3b  bank $62   6 pieces
    player_frame data_62_474f_PlayerFrame_060                ; $3c  bank $62   6 pieces
    player_frame data_62_476c_PlayerFrame_061                ; $3d  bank $62   5 pieces
    player_frame data_62_4785_PlayerFrame_062                ; $3e  bank $62   5 pieces
    player_frame data_62_479e_PlayerFrame_063                ; $3f  bank $62   6 pieces
    player_frame data_62_47bb_PlayerFrame_064                ; $40  bank $62   7 pieces
    player_frame data_62_47dc_PlayerFrame_065                ; $41  bank $62   8 pieces
    player_frame data_62_4801_PlayerFrame_066                ; $42  bank $62   5 pieces
    player_frame data_62_481a_PlayerFrame_067                ; $43  bank $62   6 pieces
    player_frame data_63_4000_PlayerFrame_068                ; $44  bank $63   6 pieces
    player_frame data_63_401d_PlayerFrame_069                ; $45  bank $63   6 pieces
    player_frame data_63_403a_PlayerFrame_070                ; $46  bank $63   6 pieces
    player_frame data_63_4057_PlayerFrame_071                ; $47  bank $63   6 pieces
    player_frame data_63_4074_PlayerFrame_072                ; $48  bank $63   6 pieces
    player_frame data_63_4091_PlayerFrame_073                ; $49  bank $63   6 pieces
    player_frame data_63_40ae_PlayerFrame_074                ; $4a  bank $63   5 pieces
    player_frame data_63_40c7_PlayerFrame_075                ; $4b  bank $63   6 pieces
    player_frame data_63_40e4_PlayerFrame_076                ; $4c  bank $63   5 pieces
    player_frame data_63_40fd_PlayerFrame_077                ; $4d  bank $63   6 pieces
    player_frame data_63_411a_PlayerFrame_078                ; $4e  bank $63   6 pieces
    player_frame data_63_4137_PlayerFrame_079                ; $4f  bank $63   5 pieces
    player_frame data_63_4150_PlayerFrame_080                ; $50  bank $63   5 pieces
    player_frame data_63_4169_PlayerFrame_081                ; $51  bank $63   6 pieces
    player_frame data_63_4186_PlayerFrame_082                ; $52  bank $63   6 pieces
    player_frame data_63_41a3_PlayerFrame_083                ; $53  bank $63   5 pieces
    player_frame data_63_41bc_PlayerFrame_084                ; $54  bank $63   5 pieces
    player_frame data_63_41d5_PlayerFrame_085                ; $55  bank $63   5 pieces
    player_frame data_63_41ee_PlayerFrame_086                ; $56  bank $63   6 pieces
    player_frame data_63_420b_PlayerFrame_087                ; $57  bank $63   6 pieces
    player_frame data_63_4228_PlayerFrame_088                ; $58  bank $63   6 pieces
    player_frame data_63_4245_PlayerFrame_089                ; $59  bank $63   6 pieces
    player_frame data_63_4262_PlayerFrame_090                ; $5a  bank $63   5 pieces
    player_frame data_63_427b_PlayerFrame_091                ; $5b  bank $63   4 pieces
    player_frame data_63_4290_PlayerFrame_092                ; $5c  bank $63   4 pieces
    player_frame data_63_42a5_PlayerFrame_093                ; $5d  bank $63   6 pieces
    player_frame data_63_42c2_PlayerFrame_094                ; $5e  bank $63   7 pieces
    player_frame data_63_42e3_PlayerFrame_095                ; $5f  bank $63   7 pieces
    player_frame data_63_4304_PlayerFrame_096                ; $60  bank $63   6 pieces
    player_frame data_63_4321_PlayerFrame_097                ; $61  bank $63   5 pieces
    player_frame data_63_433a_PlayerFrame_098                ; $62  bank $63   7 pieces
    player_frame data_63_435b_PlayerFrame_099                ; $63  bank $63   7 pieces
    player_frame data_63_437c_PlayerFrame_100                ; $64  bank $63   7 pieces
    player_frame data_63_439d_PlayerFrame_101                ; $65  bank $63   7 pieces
    player_frame data_63_43be_PlayerFrame_102                ; $66  bank $63   6 pieces
    player_frame data_63_43db_PlayerFrame_103                ; $67  bank $63   5 pieces
    player_frame data_63_43f4_PlayerFrame_104                ; $68  bank $63   5 pieces
    player_frame data_63_440d_PlayerFrame_105                ; $69  bank $63   6 pieces
    player_frame data_63_442a_PlayerFrame_106                ; $6a  bank $63   6 pieces
    player_frame data_63_4447_PlayerFrame_107                ; $6b  bank $63   6 pieces
    player_frame data_63_4464_PlayerFrame_108                ; $6c  bank $63   5 pieces
    player_frame data_63_447d_PlayerFrame_109                ; $6d  bank $63   6 pieces
    player_frame data_63_449a_PlayerFrame_110                ; $6e  bank $63   6 pieces
    player_frame data_63_44b7_PlayerFrame_111                ; $6f  bank $63   6 pieces
    player_frame data_63_44d4_PlayerFrame_112                ; $70  bank $63   4 pieces
    player_frame data_63_44e9_PlayerFrame_113                ; $71  bank $63   6 pieces
    player_frame data_63_4506_PlayerFrame_114                ; $72  bank $63   6 pieces
    player_frame data_63_4523_PlayerFrame_115                ; $73  bank $63   7 pieces
    player_frame data_63_4544_PlayerFrame_116                ; $74  bank $63   7 pieces
    player_frame data_63_4565_PlayerFrame_117                ; $75  bank $63   7 pieces
    player_frame data_63_4586_PlayerFrame_118                ; $76  bank $63   7 pieces
    player_frame data_63_45a7_PlayerFrame_119                ; $77  bank $63   7 pieces
    player_frame data_63_45c8_PlayerFrame_120                ; $78  bank $63   7 pieces
    player_frame data_63_45e9_PlayerFrame_121                ; $79  bank $63   7 pieces
    player_frame data_63_460a_PlayerFrame_122                ; $7a  bank $63   7 pieces
    player_frame data_63_462b_PlayerFrame_123                ; $7b  bank $63   7 pieces
    player_frame data_63_464c_PlayerFrame_124                ; $7c  bank $63   8 pieces
    player_frame data_63_4671_PlayerFrame_125                ; $7d  bank $63   4 pieces
    player_frame data_63_4686_PlayerFrame_126                ; $7e  bank $63   4 pieces
    player_frame data_63_469b_PlayerFrame_127                ; $7f  bank $63   4 pieces
    player_frame data_63_46b0_PlayerFrame_128                ; $80  bank $63   4 pieces
    player_frame data_63_46c5_PlayerFrame_129                ; $81  bank $63   4 pieces
    player_frame data_63_46da_PlayerFrame_130                ; $82  bank $63   4 pieces
    player_frame data_63_46ef_PlayerFrame_131                ; $83  bank $63   4 pieces
    player_frame data_63_4704_PlayerFrame_132                ; $84  bank $63   6 pieces
    player_frame data_63_4721_PlayerFrame_133                ; $85  bank $63   6 pieces
    player_frame data_63_473e_PlayerFrame_134                ; $86  bank $63   6 pieces
    player_frame data_63_475b_PlayerFrame_135                ; $87  bank $63   6 pieces
    player_frame data_63_4778_PlayerFrame_136                ; $88  bank $63   5 pieces
    player_frame data_63_4791_PlayerFrame_137                ; $89  bank $63   5 pieces
    player_frame data_63_47aa_PlayerFrame_138                ; $8a  bank $63   6 pieces
    player_frame data_63_47c7_PlayerFrame_139                ; $8b  bank $63   6 pieces
    player_frame data_63_47e4_PlayerFrame_140                ; $8c  bank $63   5 pieces
    player_frame data_63_47fd_PlayerFrame_141                ; $8d  bank $63   6 pieces
    player_frame data_63_481a_PlayerFrame_142                ; $8e  bank $63   6 pieces
    player_frame data_63_4837_PlayerFrame_143                ; $8f  bank $63   5 pieces
    player_frame data_63_4850_PlayerFrame_144                ; $90  bank $63   5 pieces
    player_frame data_64_4000_PlayerFrame_145                ; $91  bank $64   6 pieces
    player_frame data_64_401d_PlayerFrame_146                ; $92  bank $64   6 pieces
    player_frame data_64_403a_PlayerFrame_147                ; $93  bank $64   5 pieces
    player_frame data_64_4053_PlayerFrame_148                ; $94  bank $64   6 pieces
    player_frame data_64_4070_PlayerFrame_149                ; $95  bank $64   6 pieces
    player_frame data_64_408d_PlayerFrame_150                ; $96  bank $64   5 pieces
    player_frame data_64_40a6_PlayerFrame_151                ; $97  bank $64   5 pieces
    player_frame data_64_40bf_PlayerFrame_152                ; $98  bank $64   6 pieces
    player_frame data_64_40dc_PlayerFrame_153                ; $99  bank $64   6 pieces
    player_frame data_64_40f9_PlayerFrame_154                ; $9a  bank $64   5 pieces
    player_frame data_64_4112_PlayerFrame_155                ; $9b  bank $64   5 pieces
    player_frame data_64_412b_PlayerFrame_156                ; $9c  bank $64   6 pieces
    player_frame data_64_4148_PlayerFrame_157                ; $9d  bank $64   7 pieces
    player_frame data_64_4169_PlayerFrame_158                ; $9e  bank $64   6 pieces
    player_frame data_64_4186_PlayerFrame_159                ; $9f  bank $64   8 pieces
    player_frame data_64_41ab_PlayerFrame_160                ; $a0  bank $64   8 pieces
    player_frame data_64_41d0_PlayerFrame_161                ; $a1  bank $64   8 pieces
    player_frame data_64_41f5_PlayerFrame_162                ; $a2  bank $64   9 pieces
    player_frame data_64_421e_PlayerFrame_163                ; $a3  bank $64   8 pieces
    player_frame data_64_4243_PlayerFrame_164                ; $a4  bank $64   7 pieces
    player_frame data_64_4264_PlayerFrame_165                ; $a5  bank $64   5 pieces
    player_frame data_64_427d_PlayerFrame_166                ; $a6  bank $64   4 pieces
    player_frame data_64_4292_PlayerFrame_167                ; $a7  bank $64   3 pieces
    player_frame data_64_42a3_PlayerFrame_168                ; $a8  bank $64   2 pieces
    player_frame data_64_42b0_PlayerFrame_169                ; $a9  bank $64   5 pieces
    player_frame data_64_42c9_PlayerFrame_170                ; $aa  bank $64   6 pieces
    player_frame data_64_42e6_PlayerFrame_171                ; $ab  bank $64   5 pieces
    player_frame data_64_42ff_PlayerFrame_172                ; $ac  bank $64   5 pieces
    player_frame data_64_4318_PlayerFrame_173                ; $ad  bank $64   4 pieces
    player_frame data_64_432d_PlayerFrame_174                ; $ae  bank $64   4 pieces
    player_frame data_64_4342_PlayerFrame_175                ; $af  bank $64   3 pieces
    player_frame data_64_4353_PlayerFrame_176                ; $b0  bank $64   2 pieces
    player_frame data_64_4360_PlayerFrame_177                ; $b1  bank $64   2 pieces
    player_frame data_64_436d_PlayerFrame_178                ; $b2  bank $64   5 pieces
    player_frame data_64_4386_PlayerFrame_179                ; $b3  bank $64   5 pieces
    player_frame data_64_439f_PlayerFrame_180                ; $b4  bank $64   5 pieces
    player_frame data_64_43b8_PlayerFrame_181                ; $b5  bank $64   5 pieces
    player_frame data_64_43d1_PlayerFrame_182                ; $b6  bank $64   6 pieces
    player_frame data_64_43ee_PlayerFrame_183                ; $b7  bank $64   4 pieces
    player_frame data_64_4403_PlayerFrame_184                ; $b8  bank $64   5 pieces
    player_frame data_64_441c_PlayerFrame_185                ; $b9  bank $64   5 pieces
    player_frame data_64_4435_PlayerFrame_186                ; $ba  bank $64   6 pieces
    player_frame data_64_4452_PlayerFrame_187                ; $bb  bank $64   5 pieces
    player_frame data_64_446b_PlayerFrame_188                ; $bc  bank $64   6 pieces
    player_frame data_64_4488_PlayerFrame_189                ; $bd  bank $64   6 pieces
    player_frame data_64_44a5_PlayerFrame_190                ; $be  bank $64   6 pieces
    player_frame data_64_44c2_PlayerFrame_191                ; $bf  bank $64   6 pieces
    player_frame data_64_44df_PlayerFrame_192                ; $c0  bank $64   5 pieces
    player_frame data_64_44f8_PlayerFrame_193                ; $c1  bank $64   6 pieces
    player_frame data_64_4515_PlayerFrame_194                ; $c2  bank $64   6 pieces
    player_frame data_64_4532_PlayerFrame_195                ; $c3  bank $64   7 pieces
    player_frame data_64_4553_PlayerFrame_196                ; $c4  bank $64   4 pieces
    player_frame data_64_4568_PlayerFrame_197                ; $c5  bank $64   7 pieces
    player_frame data_64_4589_PlayerFrame_198                ; $c6  bank $64   6 pieces
    player_frame data_64_45a6_PlayerFrame_199                ; $c7  bank $64   6 pieces
    player_frame data_64_45c3_PlayerFrame_200                ; $c8  bank $64   5 pieces
    player_frame data_64_45dc_PlayerFrame_201                ; $c9  bank $64   6 pieces
    player_frame data_64_45f9_PlayerFrame_202                ; $ca  bank $64   5 pieces
    player_frame data_64_4612_PlayerFrame_203                ; $cb  bank $64   6 pieces
    player_frame data_64_462f_PlayerFrame_204                ; $cc  bank $64   6 pieces
    player_frame data_64_464c_PlayerFrame_205                ; $cd  bank $64   5 pieces
    player_frame data_64_4665_PlayerFrame_206                ; $ce  bank $64   6 pieces
    player_frame data_64_4682_PlayerFrame_207                ; $cf  bank $64   5 pieces
    player_frame data_64_469b_PlayerFrame_208                ; $d0  bank $64   5 pieces
    player_frame data_64_46b4_PlayerFrame_209                ; $d1  bank $64   5 pieces
    player_frame data_64_46cd_PlayerFrame_210                ; $d2  bank $64   6 pieces
    player_frame data_64_46ea_PlayerFrame_211                ; $d3  bank $64   9 pieces
    player_frame data_64_4713_PlayerFrame_212                ; $d4  bank $64   8 pieces
    player_frame data_64_4738_PlayerFrame_213                ; $d5  bank $64   6 pieces
    player_frame data_64_4755_PlayerFrame_214                ; $d6  bank $64   5 pieces
    player_frame data_64_476e_PlayerFrame_215                ; $d7  bank $64   7 pieces
    player_frame data_64_478f_PlayerFrame_216                ; $d8  bank $64   8 pieces
    player_frame data_64_47b4_PlayerFrame_217                ; $d9  bank $64   7 pieces
    player_frame data_64_47d5_PlayerFrame_218                ; $da  bank $64   7 pieces
    player_frame data_64_47f6_PlayerFrame_219                ; $db  bank $64   7 pieces
    player_frame data_64_4817_PlayerFrame_220                ; $dc  bank $64   7 pieces
    player_frame data_64_4838_PlayerFrame_221                ; $dd  bank $64   6 pieces
    player_frame data_64_4855_PlayerFrame_222                ; $de  bank $64   6 pieces
    player_frame data_65_4000_PlayerFrame_223                ; $df  bank $65   7 pieces
    player_frame data_65_4021_PlayerFrame_224                ; $e0  bank $65   8 pieces
    player_frame data_65_4046_PlayerFrame_225                ; $e1  bank $65   7 pieces
    player_frame data_65_4067_PlayerFrame_226                ; $e2  bank $65   6 pieces
    player_frame data_65_4084_PlayerFrame_227                ; $e3  bank $65   6 pieces
    player_frame data_65_40a1_PlayerFrame_228                ; $e4  bank $65   7 pieces
    player_frame data_65_40c2_PlayerFrame_229                ; $e5  bank $65   8 pieces
    player_frame data_65_40e7_PlayerFrame_230                ; $e6  bank $65   7 pieces
    player_frame data_65_4108_PlayerFrame_231                ; $e7  bank $65   6 pieces
    player_frame data_65_4125_PlayerFrame_232                ; $e8  bank $65   8 pieces
    player_frame data_65_414a_PlayerFrame_233                ; $e9  bank $65   8 pieces
    player_frame data_65_416f_PlayerFrame_234                ; $ea  bank $65   7 pieces
    player_frame data_65_4190_PlayerFrame_235                ; $eb  bank $65   6 pieces
    player_frame data_65_41ad_PlayerFrame_236                ; $ec  bank $65   8 pieces

data_7f_53f9_MapObjPalettes_GexCave:
; OBJ palettes for Gex Cave 1-4, WW Gex Wrestling 1, Lizard of Oz 1, Channel Z 1-5
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $7fff, CGB_COLOR_UNUSED, CGB_COLOR_UNUSED   ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
; Palettes 2-7. Never read: call_00_2cbf_Entity_LoadMapPalettes stops after
; CGB_PALETTE_SIZE * 2 bytes, and every block in the file has the same six
; unfilled palettes here
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5439_MapObjPalettes_HolidayTV:
; OBJ palettes for Holiday TV 1-4, Gextreme Sports 2-4
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $7fff, $0000, $7d8a                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5479_MapObjPalettes_MysteryTV:
; OBJ palettes for Mystery TV 1-10
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $7fff, $0180, $0000                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_54b9_MapObjPalettes_TutTV:
; OBJ palettes for Tut TV 1-7
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $03ff, $0000, $7ca0                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_54f9_MapObjPalettes_SuperheroShow:
; OBJ palettes for Superhero Show 1-6
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $0000, $211f, $7d6b                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5539_MapObjPalettes_GextremeSports1:
; OBJ palettes for Gextreme Sports 1
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $7fff, $0000, $7d8a                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_5579_MapObjPalettes_WesternStation:
; OBJ palettes for Western Station 1-9
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $0174, $0000, $001f                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_55b9_MapObjPalettes_MarsupialMadness1:
; OBJ palettes for Marsupial Madness 1
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $0000, $0151, $027b                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR

data_7f_55f9_MapObjPalettes_AnimeChannel:
; OBJ palettes for Anime Channel 1-9
    dw   $56b5, $0000, $0320, $035a                                    ; palette 0 - Gex's body
    dw   CGB_COLOR_UNUSED, $7e0f, $0000, $7f7a                         ; palette 1 - the pieces that set PLAYER_PIECE_PAL1
    REPT (OBJ_PALETTE_BYTES - CGB_PALETTE_SIZE * 2) / 2
    dw   CGB_COLOR_UNUSED
    ENDR
