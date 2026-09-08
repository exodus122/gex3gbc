; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/LizardOfOz/LizardOfOz_entity_list.bin
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
; 2 records.
; ==================================================================

    db   ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ       ; #$00
    dw   $0078, $0020
    dw   $00e0, $0020, $0030, $0010
    dw   $0000
    db   MAP_LIZARD_OF_OZ1

    db   ENTITY_LIZARD_OF_OZ_CANNON            ; #$01
    dw   $0078, $0060
    dw   $00e0, $0020, $0070, $0050
    dw   $0000
    db   MAP_LIZARD_OF_OZ1

    db   ENTITY_LIST_TERMINATOR
