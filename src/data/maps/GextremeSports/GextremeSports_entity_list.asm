; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/GextremeSports/GextremeSports_entity_list.bin
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
; 9 records.
; ==================================================================

    db   ENTITY_FREESTANDING_REMOTE            ; #$00
    dw   $02e8, $02b0
    dw   $02f8, $02d8, $02c0, $02a0
    dw   $0007
    db   MAP_GEXTREME_SPORTS1

    db   ENTITY_GEXTREME_SPORTS_ELF            ; #$01
    dw   $0180, $02a9
    dw   $0190, $0020, $02b9, $0299
    dw   $0000
    db   MAP_GEXTREME_SPORTS1

    db   ENTITY_GEXTREME_SPORTS_ELF            ; #$02
    dw   $0150, $0209
    dw   $02b0, $0150, $0219, $01f9
    dw   $0001
    db   MAP_GEXTREME_SPORTS1

    db   ENTITY_GEXTREME_SPORTS_ELF            ; #$03
    dw   $00f0, $0179
    dw   $0110, $0020, $0189, $0169
    dw   $0002
    db   MAP_GEXTREME_SPORTS1

    db   ENTITY_GEXTREME_SPORTS_ELF            ; #$04
    dw   $01b0, $00f9
    dw   $02b0, $0160, $0109, $00e9
    dw   $0003
    db   MAP_GEXTREME_SPORTS1

    db   ENTITY_GEXTREME_SPORTS_ELF            ; #$05
    dw   $0140, $0079
    dw   $0150, $0020, $0089, $0069
    dw   $0004
    db   MAP_GEXTREME_SPORTS1

    db   ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN  ; #$06
    dw   $00a0, $00f8
    dw   $00b0, $0090, $0108, $00e8
    dw   $000a
    db   MAP_GEXTREME_SPORTS2

    db   ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN  ; #$07
    dw   $00a0, $00f8
    dw   $00b0, $0090, $0108, $00e8
    dw   $000a
    db   MAP_GEXTREME_SPORTS3

    db   ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN  ; #$08
    dw   $00a0, $00f8
    dw   $00b0, $0090, $0108, $00e8
    dw   $000a
    db   MAP_GEXTREME_SPORTS4

    db   ENTITY_LIST_TERMINATOR
