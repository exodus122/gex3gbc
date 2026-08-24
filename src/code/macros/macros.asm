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
    ld   A, [wDC88_CurrentEntity_UnkVerticalOffset]
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
