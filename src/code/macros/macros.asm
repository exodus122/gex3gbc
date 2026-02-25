; Calls a function in a different bank
MACRO farcall
    ld   [wDAD6_ReturnBank], a
	ld   a, BANK(\1)
	ld   hl, \1
	call call_00_0edd_FarCall
ENDM

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
