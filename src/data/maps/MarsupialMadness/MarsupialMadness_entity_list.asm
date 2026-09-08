; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/MarsupialMadness/MarsupialMadness_entity_list.bin
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
; 14 records.
; ==================================================================

    db   ENTITY_FREESTANDING_REMOTE            ; #$00
    dw   $01ec, $03a8
    dw   $01fc, $01dc, $03b8, $0398
    dw   $0008
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$01
    dw   $0044, $0030
    dw   $0054, $0034, $0040, $0020
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$02
    dw   $01a4, $0030
    dw   $01b4, $0194, $0040, $0020
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$03
    dw   $00fc, $0118
    dw   $010c, $00ec, $0128, $0108
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$04
    dw   $00ec, $01e0
    dw   $00fc, $00dc, $01f0, $01d0
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$05
    dw   $014c, $02e0
    dw   $015c, $013c, $02f0, $02d0
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$06
    dw   $0014, $03c0
    dw   $0024, $0004, $03d0, $03b0
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BELL         ; #$07
    dw   $00c8, $03e0
    dw   $00d8, $00b8, $03f0, $03d0
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BIRD         ; #$08
    dw   $0088, $0368
    dw   $0120, $0080, $0378, $0358
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BIRD         ; #$09
    dw   $0170, $0318
    dw   $0180, $00e0, $0328, $0308
    dw   $0020
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BIRD         ; #$0a
    dw   $0160, $0278
    dw   $0190, $00d0, $0288, $0268
    dw   $0020
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BIRD         ; #$0b
    dw   $0070, $0208
    dw   $0110, $0070, $0218, $01f8
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BIRD         ; #$0c
    dw   $0090, $0170
    dw   $0130, $0090, $0180, $0160
    dw   $0000
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_MARSUPIAL_MADNESS_BIRD         ; #$0d
    dw   $0158, $00a8
    dw   $0160, $00c0, $00b8, $0098
    dw   $0020
    db   MAP_MARSUPIAL_MADNESS1

    db   ENTITY_LIST_TERMINATOR
