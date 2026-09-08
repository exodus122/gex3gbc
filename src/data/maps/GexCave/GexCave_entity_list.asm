; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/GexCave/GexCave_entity_list.bin
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
; 27 records.
; ==================================================================

    db   ENTITY_TV_BUTTON                      ; #$00
    dw   $01b0, $0060
    dw   $01c0, $01a0, $0070, $0050
    dw   $0001
    db   MAP_GEX_CAVE2

    db   ENTITY_TV_REMOTE                      ; #$01
    dw   $01b0, $0040
    dw   $01c0, $01a0, $0050, $0030
    dw   $0001
    db   MAP_GEX_CAVE2

    db   ENTITY_TV_BUTTON                      ; #$02
    dw   $0030, $0060
    dw   $0040, $0020, $0070, $0050
    dw   $0002
    db   MAP_GEX_CAVE2

    db   ENTITY_TV_REMOTE                      ; #$03
    dw   $0030, $0040
    dw   $0040, $0020, $0050, $0030
    dw   $0002
    db   MAP_GEX_CAVE2

    db   ENTITY_TV_BUTTON                      ; #$04
    dw   $0060, $0100
    dw   $0070, $0050, $0110, $00f0
    dw   $0003
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_REMOTE                      ; #$05
    dw   $0060, $00e0
    dw   $0070, $0050, $00f0, $00d0
    dw   $0003
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_BUTTON                      ; #$06
    dw   $0180, $0100
    dw   $0190, $0170, $0110, $00f0
    dw   $0004
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_REMOTE                      ; #$07
    dw   $0180, $00e0
    dw   $0190, $0170, $00f0, $00d0
    dw   $0004
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_BUTTON                      ; #$08
    dw   $00f0, $0090
    dw   $0100, $00e0, $00a0, $0080
    dw   $0005
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_REMOTE                      ; #$09
    dw   $00f0, $0070
    dw   $0100, $00e0, $0080, $0060
    dw   $0005
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_BUTTON                      ; #$0a
    dw   $0100, $0050
    dw   $0110, $00f0, $0060, $0040
    dw   $0006
    db   MAP_GEX_CAVE4

    db   ENTITY_TV_REMOTE                      ; #$0b
    dw   $0100, $0030
    dw   $0110, $00f0, $0040, $0020
    dw   $0006
    db   MAP_GEX_CAVE4

    db   ENTITY_TV_BUTTON                      ; #$0c
    dw   $0030, $0040
    dw   $0040, $0020, $0050, $0030
    dw   $0007
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_REMOTE                      ; #$0d
    dw   $0030, $0020
    dw   $0040, $0020, $0030, $0010
    dw   $0007
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_BUTTON                      ; #$0e
    dw   $0050, $0100
    dw   $0060, $0040, $0110, $00f0
    dw   $0008
    db   MAP_GEX_CAVE2

    db   ENTITY_TV_REMOTE                      ; #$0f
    dw   $0050, $00e0
    dw   $0060, $0040, $00f0, $00d0
    dw   $0008
    db   MAP_GEX_CAVE2

    db   ENTITY_TV_BUTTON                      ; #$10
    dw   $01b0, $0040
    dw   $01c0, $01a0, $0050, $0030
    dw   $0009
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_REMOTE                      ; #$11
    dw   $01b0, $0020
    dw   $01c0, $01a0, $0030, $0010
    dw   $0009
    db   MAP_GEX_CAVE3

    db   ENTITY_TV_BUTTON                      ; #$12
    dw   $0114, $0100
    dw   $0124, $0104, $0110, $00f0
    dw   $000a
    db   MAP_GEX_CAVE4

    db   ENTITY_TV_REMOTE                      ; #$13
    dw   $0114, $00e0
    dw   $0124, $0104, $00f0, $00d0
    dw   $000a
    db   MAP_GEX_CAVE4

    db   ENTITY_TV_BUTTON                      ; #$14
    dw   $01b0, $0040
    dw   $01c0, $01a0, $0050, $0030
    dw   $000b
    db   MAP_GEX_CAVE4

    db   ENTITY_TV_REMOTE                      ; #$15
    dw   $01b0, $0020
    dw   $01c0, $01a0, $0030, $0010
    dw   $000b
    db   MAP_GEX_CAVE4

    db   ENTITY_FREESTANDING_REMOTE            ; #$16
    dw   $01b2, $00c0
    dw   $01c2, $01a2, $00d0, $00b0
    dw   $0000
    db   MAP_GEX_CAVE1

    db   ENTITY_PAW_COIN                       ; #$17
    dw   $0038, $00a8
    dw   $0048, $0028, $00b8, $0098
    dw   $0001
    db   MAP_GEX_CAVE1

    db   ENTITY_PAW_COIN                       ; #$18
    dw   $00f0, $00b0
    dw   $0100, $00e0, $00c0, $00a0
    dw   $0002
    db   MAP_GEX_CAVE3

    db   ENTITY_PAW_COIN                       ; #$19
    dw   $0018, $00b0
    dw   $0028, $0008, $00c0, $00a0
    dw   $0003
    db   MAP_GEX_CAVE4

    db   ENTITY_BONUS_COIN                     ; #$1a
    dw   $0020, $0020
    dw   $0030, $0010, $0030, $0010
    dw   $0000
    db   MAP_GEX_CAVE1

    db   ENTITY_LIST_TERMINATOR
