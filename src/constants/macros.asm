MACRO ld_long_load
db $FA
dw \2
ENDM
MACRO ld_long_store
db $EA
dw \1
ENDM
MACRO short_stop
db $10
ENDM

; Calls a function in a different bank
MACRO farcall
    ld   [wDAD6_ReturnBank], a
	ld   a, BANK(\1)
	ld   hl, \1
	call call_00_0edd_FarCall
ENDM
