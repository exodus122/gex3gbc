; Calls a function in a different bank
MACRO farcall
    ld   [wDAD6_ReturnBank], a
	ld   a, BANK(\1)
	ld   hl, \1
	call call_00_0edd_FarCall
ENDM

; Store an address and the associated bank.
macro farpointer
    db   BANK(\1)
    dw   \1
endm

; Load the address of a field in the current entity into certain registers
MACRO LOAD_OBJ_FIELD_TO_HL
    ld   h, HIGH(wD800_EntityMemory)
    ld   a, [wDA00_CurrentEntityAddrLo]
    or   a, \1
    ld   l, a
ENDM

MACRO LOAD_OBJ_FIELD_TO_HL_ALT
    ld   a, [wDA00_CurrentEntityAddrLo]
    or   a, \1
    ld   l, a
    ld   h, HIGH(wD800_EntityMemory)
ENDM

MACRO LOAD_OBJ_FIELD_TO_DE
    ld   d, HIGH(wD800_EntityMemory)
    ld   a, [wDA00_CurrentEntityAddrLo]
    or   a, \1
    ld   e, a
ENDM

MACRO LOAD_OBJ_FIELD_TO_DE_ALT
    ld   a, [wDA00_CurrentEntityAddrLo]
    or   a, \1
    ld   e, a
    ld   d, HIGH(wD800_EntityMemory)
ENDM

MACRO LOAD_OBJ_FIELD_TO_BC
    ld   b, HIGH(wD800_EntityMemory)
    ld   a, [wDA00_CurrentEntityAddrLo]
    or   a, \1
    ld   c, a
ENDM

MACRO EntityChildSpawnData
    db \1
    dw \2, \3
    db \4, 0, 0
ENDM

; ------------------------------------------------------------------
; Cutscene scripts - see code/bank00_cutscenes.asm
; ------------------------------------------------------------------
; One cutscene script header: which map the scene is set in, where Gex is
; teleported to, the movement command list to walk (or 0), and the animation
; script (always 0 - the runner reads the field and discards it)
; ------------------------------------------------------------------
; HDMA jobs - see .data_00_0aa9_HdmaConfigTable
; ------------------------------------------------------------------
; One canned HDMA transfer, selected by an HDMACFG_* id. A source bank of
; HDMACFG_BANK_MAP_TILESET means the source is an offset into the current map's
; tileset rather than a fixed address, and call_00_0a6a_Hdma_RunConfigEntry adds
; wDC08_TilesetBankOffset to it on the way past
MACRO hdma_config ; source, destination, bytes, source bank, destination VRAM bank
    dw   \1, \2, \3
    db   \4, \5
ENDM

; ------------------------------------------------------------------
; Oversized entity graphics - see .data_00_0973_BigEntityGfx
; ------------------------------------------------------------------
; One row of the table StageNextGfxTransfer uses for entities too big for the nine
; shared ENTITY_GFX_BASE_* size classes. Each gets an array to itself, so the row
; carries its own stride and its own base.
;
; The base is stored one stride BELOW the artwork: the reader adds a stride before
; it tests the loop counter, so frame 0 lands on the first byte of the sheet
MACRO entity_gfx_big ; ENTITY_*, image label, OBJs per frame
    db   \1
    dw   (\3) * OBJ_BYTES
    dw   \2 - (\3) * OBJ_BYTES
ENDM

; ------------------------------------------------------------------
; Entity animation frame ids - see code/bank02_entity_animation_data.asm
; ------------------------------------------------------------------
; A frame id is not a frame number: it is an index into the entity's own array of
; tiles, and call_00_08f8_StageNextGfxTransfer turns it back into an address as
;
;     ENTITY_GFX_BASE_n + sprite_id * n * OBJ_BYTES
;
; where n is the entity's size in OBJs. Entities of the same size share one array,
; so an id counts from the start of that shared array rather than from the entity's
; own artwork - which is why adding a frame to one entity would renumber every
; entity after it if these were written as bare numbers.
;
; Writing them as an offset from the artwork's own label undoes that: the id is
; computed back from wherever the sheet ended up, so a sprite bank can be re-laid-out
; and every id that names it follows.
MACRO entity_frames ; base image label, OBJs per frame, frame offsets...
    FOR _i, 3, _NARG + 1
        db   (\1 - ENTITY_GFX_BASE_\2) / (\2 * OBJ_BYTES) + (\<_i>)
    ENDR
ENDM

MACRO cutscene_script  ; map id, start X, start Y, movement list, animation script
    db   \1
    dw   \2, \3, \4, \5
ENDM

; One movement command: which d-pad bits to fake into wDC81_Player_EffectiveInputs,
; and for how many frames. Two direction bits may be combined to pan diagonally
MACRO cutscene_move    ; PADF_* direction bits, frames
    db   \1
    dw   \2
ENDM

MACRO cutscene_move_end
    db   CUTSCENE_MOVE_END
ENDM

; ------------------------------------------------------------------
; Background collision probe scripts - see code/bank03_bg_collision.asm
; ------------------------------------------------------------------
; Header: which d-pad bits this script answers for, how many entries follow,
; and how big each one is
MACRO climb_script ; d-pad mask, number of entries, entry size
    db   \1
    db   \2
    dw   \3
ENDM

; Climbing entry: the input it matches, then the tile offset to probe
MACRO climb_script_entry ; input, X offset, Y offset
    db   \1, \2, \3
ENDM

; Swimming entry: same, but the offset is in pixels and pre-biased by
; PLAYER_FEET_OFFSET - 1 so the handler can subtract it back out. The trailing
; pair is the same direction in tiles and is never read
MACRO swim_script_entry ; input, X offset, Y offset, unread X, unread Y
    db   \1, \2, \3, \4, \5
ENDM

; ------------------------------------------------------------------
; Entity sprite shapes - see code/bank03_oam_build.asm
; ------------------------------------------------------------------
; One 8x16 OBJ of a sprite shape. The Y and X offsets are signed and relative to the
; entity's already-biased screen position; the tile is relative to the entity's tile
; base from data_03_58d2_EntitySpriteDescriptors; the attribute bits are OR'd on top
; of the entity's own, so a piece can only add to them
MACRO oam_piece ; Y offset, X offset, tile, OAMF_* bits
    db   \1, \2, \3, \4
ENDM

; ------------------------------------------------------------------
; Gex's OAM build - see code/bank00_player_sprites.asm
; ------------------------------------------------------------------
; Where Gex is on screen this frame, and whether he should be drawn at all. Leaves
; B = the Y origin for his pieces and C = the X origin, and jumps away to the
; shared tail when the damage flash is in its blank phase.
;
; \1 is 1 for the last of the four flip variants, which is close enough to the tail
; to reach it with a `jr`
MACRO player_oam_origin
    ld   A, [wDBF9_XPositionInMap]
    ld   C, A
    ld   A, [wD80E_PlayerXPosition]
    sub  A, C
    add  A, OAM_X_BIAS
    ld   [wDC90_Player_ScreenX], A
    ld   C, A
    ld   A, [wDBFB_YPositionInMap]
    ld   B, A
    ld   A, [wD810_PlayerYPosition]
    sub  A, B
    add  A, OAM_Y_BIAS
    ld   [wDC91_Player_ScreenY], A
    add  A, OAM_Y_BIAS
    ld   B, A
    ld   A, [wDC88_Player_HopYOffset]
    add  A, B
    ld   B, A
    call call_00_2f00_Player_IsDead
    jr   NZ, .draw\@
    ld   A, [wDC7E_Player_DamageCooldownTimer]
    and  A, A
    jr   Z, .draw\@
    ld   A, [wDC71_VBlankFrameCounter]
    and  A, PLAYER_DAMAGE_FLASH_MASK
IF \1
    jr   NZ, .jp_00_2ece
ELSE
    jp   NZ, .jp_00_2ece
ENDC
.draw\@:
    ld   A, [wDAC2_PlayerGfx_TileCount]
ENDM

; One OBJ per iteration, walking the frame list at HL: a Y offset, an X offset, then
; a byte of extra attributes and a byte the build skips.
;
; \1 mirrors vertically and \2 horizontally - `cpl / inc A` is the two's complement
; negate, and the subtraction that follows it moves the piece back by its own size so
; the mirrored rectangle lands where the unmirrored one did. \3 is 1 for the last
; variant, which falls through to the tail instead of jumping to it
MACRO player_oam_pieces
.piece\@:
    push AF
    ld   A, [HL+]
IF \1
    cpl
    inc  A
    sub  A, PLAYER_SPRITE_YFLIP_HEIGHT
ENDC
    add  A, B
    ld   [DE], A
    inc  E
    ld   A, [HL+]
IF \2
    cpl
    inc  A
    sub  A, PLAYER_SPRITE_XFLIP_WIDTH
ENDC
    add  A, C
    ld   [DE], A
    inc  E
    ld   A, [wDC52_Player_OamTileId]
    ld   [DE], A
    add  A, PLAYER_SPRITE_TILE_STRIDE
    ld   [wDC52_Player_OamTileId], A
    inc  E
    ld   A, [wDC53_Player_OamAttributes]
    or   A, [HL]
    ld   [DE], A
    inc  E
    inc  HL
    inc  HL
    pop  AF
    dec  A
    jr   NZ, .piece\@
IF !\3
    jp   .jp_00_2ece
ENDC
ENDM

; ------------------------------------------------------------------
; Map descriptors and boundaries - see code/bank03_map_init_data.asm and
; code/bank03_map_boundaries_and_spawns.asm
; ------------------------------------------------------------------
; The last four bytes of a map's descriptor record: its size in 16x16 blocks, the
; level it belongs to, and which of the two movement models it uses. They land in
; wDC1C_CurrentMapWidthAndHeightInBlocks through wDC1F_CurrentBgCollisionType
MACRO map_geometry ; width in blocks, height in blocks, LEVEL_*, BG_COLLISION_TYPE_*
    db \1, \2, \3, \4
ENDM

; One map's rectangle, in world pixels
MACRO map_bounds ; X min, X max, Y min, Y max
    dw \1, \2, \3, \4
ENDM

; A player spawn position, in world pixels
MACRO spawn_pos ; X, Y
    dw \1, \2
ENDM

; ------------------------------------------------------------------
; Menu script commands - see code/bank01_menus.asm
; ------------------------------------------------------------------
; One command: an opcode byte then a MENUCMD_PARAM_BYTES parameter block. The opcode
; indexes data_01_512e_MenuCmd_Descriptors for the rectangle this command occupies;
; the block says what to put in it.
;
; These emit exactly ONE block, so MENUCMD_FLAG_LAST_BLOCK is OR'd in here rather than
; written out on all 181 command lines - and every command in the ROM does carry it. A
; command with a second block would have to be written out by hand
MACRO menu_cmd ; opcode, pen X, pen Y, arg, BANK_1C_TEXT string table, option, flags
    db   \1
    db   \2, \3, \4
    dw   \5
    db   \6, \7 | MENUCMD_FLAG_LAST_BLOCK
ENDM

; The same, for a command that calls a sub-handler instead of naming a string. The
; handler id lands in the HIGH byte of the source pointer, which is how
; call_01_446b_MenuScript_RunCommand tells the two apart
MACRO menu_cmd_sub ; opcode, pen X, pen Y, arg, MENUCMD_SUB_*, handler arg, option, flags
    db   \1
    db   \2, \3, \4
    dw   (\5 << 8) | \6
    db   \7, \8 | MENUCMD_FLAG_LAST_BLOCK
ENDM

; One record of data_01_53c6_MenuTypeRecords - the whole definition of one MENU_* id.
; The record is MENUTYPE_RECORD_SIZE bytes but call_01_4000_MenuLoad copies only
; MENUTYPE_COPY_BYTES of it, so the four trailing bytes are dead and are emitted here
; rather than written out on all 29 rows.
;
; The LCDC byte is baked in for the same reason: it is MENUTYPE_LCDC_UNREAD in every
; record and nothing reads it - call_01_43f0_Menu_BuildScreen hardcodes MENU_LCDC
MACRO menu_type_record ; script, MENU_FLAG_*, option count, cursor base X, base Y, step X, step Y, palette, callback (0 = none)
    dw   \1
    db   \2, \3, \4, \5, \6, \7, MENUTYPE_LCDC_UNREAD, \8
    dw   \9
    db   0, 0, 0, 0
ENDM

; One record of .data_01_47c6_FullscreenImages, copied verbatim into
; wDBB1_ScreenDraw_HasPaletteIdMap and consumed by
; jp_00_0781_Screen_LoadFullscreenImage. The three fields after the bank are the two
; halves of one contiguous ROM blob and its length: tile data first, then the tilemap
; immediately after it, so in every record tilemap = tile data + size
MACRO menu_fullscreen_image ; MENUIMG_PALETTE_MAP_* , source bank, tilemap address, tile data address, tile data bytes
    db   \1, \2
    dw   \3, \4, \5
ENDM

; The rectangle a menu command opcode occupies, in data_01_512e_MenuCmd_Descriptors.
; The two trailing bytes are padding to MENUCMD_DESCRIPTOR_SIZE and are never read
MACRO menu_cmd_shape ; width, height, dest tile X, dest tile Y, first tile id, attribute
    db   \1, \2, \3, \4, \5, \6, 0, 0
ENDM

; One rectangle of 8x8 sprites in a menu sprite group - see
; data_01_5b61_SpriteScriptTable
MACRO sprite_rect ; Y, X, tile, OAM attributes, width in tiles, height in tiles
    db   \1, \2, \3, \4, \5, \6
ENDM

; ------------------------------------------------------------------
; Text records - see data/bank_01c_text.asm
; ------------------------------------------------------------------
; One string in five languages. call_00_0835_Text_LoadStringToBuffer indexes this
; with wDBF8_TextStringIndex, which nothing ever sets, so entry 0 is the only one
; this build can reach
MACRO text_langs ; English, French, German, Spanish, Italian
    dw   \1, \2, \3, \4, \5
ENDM

; The same record where every language shares one string - names, legal notices and
; anything else that was never translated. Written out as five pointers all the same,
; because the reader always takes five
MACRO text_all_langs ; the one string
    dw   \1, \1, \1, \1, \1
ENDM

; ------------------------------------------------------------------
; Bank $7F - the index to Gex's graphics. See data/sprite_data/bank7F.asm
; ------------------------------------------------------------------
; One row of data_7f_4000_PlayerGfx_SetByMap. The byte actually stored is a BYTE
; OFFSET into data_7f_403d_PlayerGfx_SetTable, not a set number: all three readers add
; it to the table base with no shift in between. The scale is applied here so the rows
; can read as set names
MACRO map_gfx_set ; PLAYER_GFX_SET_*
    db   \1 * PLAYER_GFX_SET_SIZE
ENDM

; One record of data_7f_403d_PlayerGfx_SetTable. Record 0 is written out longhand in
; the file, because data_7f_4040_PlayerGfx_SetPalettes labels its third byte
MACRO player_gfx_set ; any frame in the base graphics bank, frame directory, OBJ palettes
    db   BANK(\1)
    dw   \2
    dw   \3
ENDM

; One entry of a frame directory, indexed by wD80A_Player_SpriteId. The stored byte is
; a bank OFFSET, added to the set's base bank, which is why a frame can live several
; banks past it - a set's artwork runs over up to five consecutive banks.
;
; The offset is worked out from the frame's own bank against PLAYER_GFX_SET_BASE,
; which each directory sets to its own base before its rows, so moving a frame to
; another bank renumbers it here automatically
MACRO player_frame ; the frame
    db   BANK(\1) - PLAYER_GFX_SET_BASE
    dw   \1
ENDM

; The directory's row $00. Not a frame: sprite id 0 means "draw nothing", so the row
; is a null pointer and has no bank to take an offset from
MACRO player_frame_none
    db   $00
    dw   $0000
ENDM

; ------------------------------------------------------------------
; Gex's animation frames - see data/sprite_data/bankXX_frames.asm
; ------------------------------------------------------------------
; A frame header. The two middle bytes are stored for every frame in the game and read
; by nothing; they are small numbers in the right range for a size but they do not
; match the frame's piece extents, so what they meant is unknown
MACRO player_frame_header ; piece count, unread, unread, tile data
    db   \1, \2, \3
    dw   \4
ENDM

; One 8x16 OBJ of a frame. The offsets are relative to Gex's screen position and are
; mirrored by the build for the flipped variants. The attribute byte is OR'd into
; wDC53_Player_OamAttributes, and the only bit any frame in the game sets is palette 1.
; The fourth byte is $00 in all 11005 pieces and is stepped over without being read
MACRO player_piece ; Y offset, X offset, OBJ palette
    db   \1, \2, \3, 0
ENDM

; ------------------------------------------------------------------
; SOUND DRIVER DATA - banks $04 and $05
;
; The shapes the driver in code/audio/bank04_audio1.asm reads. See the AUDIO_* constants
; for what the individual values mean
; ------------------------------------------------------------------

; One record of the bank's song table: where each hardware channel starts, then the
; note-length table the song's notes index
MACRO audio_song ; channel 1 pattern, channel 2, channel 3, channel 4, note-length table
    dw   \1, \2, \3, \4, \5
ENDM

; One note. The instrument number is split across the two bytes: its low four bits are
; the parameter byte's high nibble, and bit 4 becomes AUDIO_NOTE_INSTRUMENT_BANK on the
; note byte itself
MACRO audio_note ; note index, instrument $00-$1F, note-length index $0-$F
    db   (\1) | (((\2) & $10) << 3), (((\2) & $0F) << 4) | (\3)
ENDM

; Holds the channel for one note length without retriggering anything - so it keeps
; whatever pitch and volume the last note left. The only command that ends a channel's
; turn for the tick
MACRO audio_rest ; note-length index $0-$F
    db   AUDIO_CMD_SET_NOTE_LENGTH, \1
ENDM

MACRO audio_end
    db   AUDIO_CMD_END
ENDM

MACRO audio_goto ; address
    db   AUDIO_CMD_GOTO
    dw   \1
ENDM

MACRO audio_noise_period ; rNR43 value
    db   AUDIO_CMD_SET_NOISE_PERIOD, \1
ENDM

; Plays a pattern from the bank's pattern table and comes back afterwards. Every song
; channel is mostly a list of these
MACRO audio_call ; pattern id, transpose in semitones, repeat count
    db   AUDIO_CMD_CALL_PATTERN, \1, \2, \3
ENDM

MACRO audio_end_pattern
    db   AUDIO_CMD_END_PATTERN
ENDM

; Stores a byte nothing reads
MACRO audio_marker ; value
    db   AUDIO_CMD_SET_MARKER, \1
ENDM

MACRO audio_panning ; rNR51 value for all four channels
    db   AUDIO_CMD_SET_PANNING, \1
ENDM

MACRO audio_panning_ch1 ; AUDIO_NR51_CH1 bits
    db   AUDIO_CMD_SET_PANNING_CH1, \1
ENDM

MACRO audio_panning_ch2 ; AUDIO_NR51_CH2 bits
    db   AUDIO_CMD_SET_PANNING_CH2, \1
ENDM

MACRO audio_panning_ch3 ; AUDIO_NR51_CH3 bits
    db   AUDIO_CMD_SET_PANNING_CH3, \1
ENDM

MACRO audio_panning_ch4 ; AUDIO_NR51_CH4 bits
    db   AUDIO_CMD_SET_PANNING_CH4, \1
ENDM

MACRO audio_note_length_table ; address of 16 tick counts
    db   AUDIO_CMD_SET_NOTE_LENGTH_TABLE
    dw   \1
ENDM

MACRO audio_tempo ; amount added to wDF77_Audio_TempoAccumulator each frame
    db   AUDIO_CMD_SET_TEMPO, \1
ENDM

; One instrument: the registers a note starts from, then the three sub-sequences that
; run underneath it. A timer of $00 with a $0000 pointer means that sub-sequence is unused
MACRO audio_instrument ; NRx4 base, NRx1, NRx2, envelope timer, envelope, pitch timer, pitch slide, arpeggio timer, arpeggio
    db   \1, \2, \3
    db   \4
    dw   \5
    db   \6
    dw   \7
    db   \8
    dw   \9
ENDM

MACRO audio_env ; rNRx2 value, frames to hold it
    db   \1, \2
ENDM

MACRO audio_env_end
    db   AUDIO_ENV_END
ENDM

; Added to the channel's NRx4:NRx3 pair as one 16-bit number, so a large enough slide
; carries into the register that also holds the trigger bit
MACRO audio_pitch ; signed offset, frames to hold it
    db   (\1) & $ff, \2
ENDM

MACRO audio_pitch_end
    db   AUDIO_PITCH_END
ENDM

MACRO audio_pitch_loop ; address
    db   AUDIO_PITCH_LOOP
    dw   \1
ENDM

; Channel 4 reads the same fields as a pitch slide, but its values are absolute rNR43
; settings rather than offsets
MACRO audio_noise_step ; rNR43 value, frames to hold it
    db   \1, \2
ENDM

; Retunes the channel relative to the note it is playing, without retriggering it
MACRO audio_arp ; frames, signed semitones
    db   \1, (\2) & $ff
ENDM

MACRO audio_arp_loop ; address
    db   AUDIO_ARP_LOOP
    dw   \1
ENDM

; The first byte of a sound-effect track: which hardware channel it takes, 0-3
MACRO sfx_channel ; 0-3
    db   \1
ENDM

; One row of a sound effect. The registers go straight to the hardware in this order -
; NRx4 before NRx3, so the note is triggered a moment before it is given its own
; frequency low byte
MACRO sfx_row ; frames, NRx1, NRx2, NRx4, NRx3
    db   \1, \2, \3, \4, \5
ENDM

MACRO sfx_end
    db   AUDIO_SFX_END
ENDM

MACRO sfx_loop ; address
    db   AUDIO_SFX_LOOP
    dw   \1
ENDM

; One row of the sfx id table - the tracks one SFX_* id starts together
MACRO sfx_tracks ; four track ids, AUDIO_SFX_TRACK_NONE where unused
    db   \1, \2, \3, \4
ENDM
