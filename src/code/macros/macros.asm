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
