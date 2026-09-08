; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/MysteryTV/MysteryTV_entity_list.bin
; by tools/render_map_asm.py, per the entity_list layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; One record per placed object, one list per LEVEL rather than per map - which is
; why every record carries the map id it belongs to at +15, a field gex2 has no
; equivalent of.
;
; Offsets are the ENTITY_SPAWN_RECORD_* / ENTITY_SPAWN_*_OFFSET constants in
; src/constants/constants.asm.
;
; NOTE: as in gex2, the two Y bound offsets look named the wrong way round in
; constants.asm. Every record has the value at +9 above the value at +11, matching
; +5 above +7 on the X axis, so both axes store max then min and
; ENTITY_SPAWN_BOUNDINGBOX_YMIN_OFFSET / _YMAX_OFFSET appear swapped. Renaming
; those two constants is cosmetic and would leave `make check` passing.
;
; Record layout - 16 bytes, ENTITY_SPAWN_RECORD_SIZE:
;   +0   db  id
;   +1   dw  x, y   - world position
;   +5   dw  bounds_x_max, bounds_x_min, bounds_y_max, bounds_y_min   - room rectangle, each axis max then min
;   +13  dw  param   - free parameter - collectible id, sometimes a timer
;   +15  db  map_id   - which map of the level this object is on
;
; 35 records.
; ==================================================================

    db   ENTITY_TV_BUTTON                      ; #$00
    dw   $0248, $02d0
    dw   $0258, $0238, $02e0, $02c0
    dw   $0001
    db   MAP_MYSTERY_TV10

    db   ENTITY_TV_REMOTE                      ; #$01
    dw   $0248, $02b0
    dw   $0258, $0238, $02c0, $02a0
    dw   $0001
    db   MAP_MYSTERY_TV10

    db   ENTITY_TV_BUTTON                      ; #$02
    dw   $0048, $0288
    dw   $0058, $0038, $0298, $0278
    dw   $0002
    db   MAP_MYSTERY_TV9

    db   ENTITY_TV_REMOTE                      ; #$03
    dw   $0048, $0268
    dw   $0058, $0038, $0278, $0258
    dw   $0002
    db   MAP_MYSTERY_TV9

    db   ENTITY_TV_BUTTON                      ; #$04
    dw   $0068, $0048
    dw   $0078, $0058, $0058, $0038
    dw   $0003
    db   MAP_MYSTERY_TV8

    db   ENTITY_TV_REMOTE                      ; #$05
    dw   $0068, $0028
    dw   $0078, $0058, $0038, $0018
    dw   $0003
    db   MAP_MYSTERY_TV8

    db   ENTITY_PAW_COIN                       ; #$06
    dw   $00aa, $01c8
    dw   $00ba, $009a, $01d8, $01b8
    dw   $0001
    db   MAP_MYSTERY_TV3

    db   ENTITY_PAW_COIN                       ; #$07
    dw   $0270, $0188
    dw   $0280, $0260, $0198, $0178
    dw   $0002
    db   MAP_MYSTERY_TV3

    db   ENTITY_PAW_COIN                       ; #$08
    dw   $01b8, $0130
    dw   $01c8, $01a8, $0140, $0120
    dw   $0003
    db   MAP_MYSTERY_TV3

    db   ENTITY_BONUS_COIN                     ; #$09
    dw   $01f2, $0148
    dw   $0202, $01e2, $0158, $0138
    dw   $0000
    db   MAP_MYSTERY_TV3

    db   ENTITY_MYSTERY_TV_BLOOD_COOLER        ; #$0a
    dw   $01ec, $0018
    dw   $01fc, $01dc, $0028, $0008
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_MYSTERY_TV_BLOOD_COOLER        ; #$0b
    dw   $00dc, $00b8
    dw   $00ec, $00cc, $00c8, $00a8
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_MYSTERY_TV_BLOOD_COOLER        ; #$0c
    dw   $00fc, $0260
    dw   $010c, $00ec, $0270, $0250
    dw   $0000
    db   MAP_MYSTERY_TV9

    db   ENTITY_MYSTERY_TV_MAGIC_SWORD         ; #$0d
    dw   $0068, $0038
    dw   $0078, $0058, $0048, $0028
    dw   $0000
    db   MAP_MYSTERY_TV8

    db   ENTITY_MYSTERY_TV_REZLING             ; #$0e
    dw   $0090, $02b0
    dw   $00d0, $0070, $02c0, $02a0
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_MYSTERY_TV_REZLING             ; #$0f
    dw   $01d0, $02b0
    dw   $0240, $01b0, $02c0, $02a0
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_MYSTERY_TV_REZLING             ; #$10
    dw   $01c0, $0080
    dw   $01e0, $01a0, $0090, $0070
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_MYSTERY_TV_SAFARI_SAM          ; #$11
    dw   $0210, $01d0
    dw   $02a0, $01b0, $01e0, $01c0
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_MYSTERY_TV_SAFARI_SAM          ; #$12
    dw   $00d0, $009c
    dw   $0120, $0060, $00ac, $008c
    dw   $0000
    db   MAP_MYSTERY_TV2

    db   ENTITY_MYSTERY_TV_SAFARI_SAM          ; #$13
    dw   $0170, $01cc
    dw   $01b0, $0130, $01dc, $01bc
    dw   $0000
    db   MAP_MYSTERY_TV2

    db   ENTITY_MYSTERY_TV_SAFARI_SAM          ; #$14
    dw   $01b0, $024c
    dw   $0200, $0170, $025c, $023c
    dw   $0000
    db   MAP_MYSTERY_TV2

    db   ENTITY_MYSTERY_TV_FISH                ; #$15
    dw   $0040, $0120
    dw   $0070, $0030, $0130, $0110
    dw   $0000
    db   MAP_MYSTERY_TV3

    db   ENTITY_MYSTERY_TV_FISH                ; #$16
    dw   $00b0, $01b0
    dw   $00f0, $0040, $01c0, $01a0
    dw   $0000
    db   MAP_MYSTERY_TV3

    db   ENTITY_MYSTERY_TV_FISH                ; #$17
    dw   $0160, $00e0
    dw   $0190, $0130, $00f0, $00d0
    dw   $0000
    db   MAP_MYSTERY_TV3

    db   ENTITY_MYSTERY_TV_FISH                ; #$18
    dw   $0280, $0120
    dw   $02a0, $0260, $0130, $0110
    dw   $0000
    db   MAP_MYSTERY_TV3

    db   ENTITY_MYSTERY_TV_GHOST_KNIGHT        ; #$19
    dw   $0058, $0013
    dw   $0068, $0048, $0023, $0003
    dw   $0000
    db   MAP_MYSTERY_TV7

    db   ENTITY_MYSTERY_TV_REZLING             ; #$1a
    dw   $00a0, $01e0
    dw   $0100, $0040, $01f0, $01d0
    dw   $0000
    db   MAP_MYSTERY_TV6

    db   ENTITY_GREEN_FLY_TV                   ; #$1b
    dw   $0020, $0230
    dw   $0030, $0010, $0240, $0220
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_GREEN_FLY_TV                   ; #$1c
    dw   $0128, $0110
    dw   $0138, $0118, $0120, $0100
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_GREEN_FLY_TV                   ; #$1d
    dw   $02a8, $0080
    dw   $02b8, $0298, $0090, $0070
    dw   $0000
    db   MAP_MYSTERY_TV1

    db   ENTITY_PURPLE_FLY_TV                  ; #$1e
    dw   $0038, $0038
    dw   $0048, $0028, $0048, $0028
    dw   $0000
    db   MAP_MYSTERY_TV2

    db   ENTITY_PURPLE_FLY_TV                  ; #$1f
    dw   $01b0, $0188
    dw   $01c0, $01a0, $0198, $0178
    dw   $0000
    db   MAP_MYSTERY_TV2

    db   ENTITY_PURPLE_FLY_TV                  ; #$20
    dw   $01f8, $0098
    dw   $0208, $01e8, $00a8, $0088
    dw   $0000
    db   MAP_MYSTERY_TV2

    db   ENTITY_GREEN_FLY_TV                   ; #$21
    dw   $0110, $0080
    dw   $0120, $0100, $0090, $0070
    dw   $0000
    db   MAP_MYSTERY_TV4

    db   ENTITY_GREEN_FLY_TV                   ; #$22
    dw   $0030, $0130
    dw   $0040, $0020, $0140, $0120
    dw   $0000
    db   MAP_MYSTERY_TV5

    db   ENTITY_LIST_TERMINATOR
