; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/HolidayTV/HolidayTV_entity_list.bin
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
; 24 records.
; ==================================================================

    db   ENTITY_TV_BUTTON                      ; #$00
    dw   $0850, $0110
    dw   $0860, $0840, $0120, $0100
    dw   $0001
    db   MAP_HOLIDAY_TV1

    db   ENTITY_TV_REMOTE                      ; #$01
    dw   $0850, $00f0
    dw   $0860, $0840, $0100, $00e0
    dw   $0001
    db   MAP_HOLIDAY_TV1

    db   ENTITY_TV_BUTTON                      ; #$02
    dw   $00f8, $0088
    dw   $0108, $00e8, $0098, $0078
    dw   $0002
    db   MAP_HOLIDAY_TV2

    db   ENTITY_TV_REMOTE                      ; #$03
    dw   $00f8, $0068
    dw   $0108, $00e8, $0078, $0058
    dw   $0002
    db   MAP_HOLIDAY_TV2

    db   ENTITY_TV_BUTTON                      ; #$04
    dw   $0028, $0070
    dw   $0038, $0018, $0080, $0060
    dw   $0003
    db   MAP_HOLIDAY_TV4

    db   ENTITY_TV_REMOTE                      ; #$05
    dw   $0028, $0050
    dw   $0038, $0018, $0060, $0040
    dw   $0003
    db   MAP_HOLIDAY_TV4

    db   ENTITY_PAW_COIN                       ; #$06
    dw   $0710, $0278
    dw   $0720, $0700, $0288, $0268
    dw   $0001
    db   MAP_HOLIDAY_TV1

    db   ENTITY_PAW_COIN                       ; #$07
    dw   $01e0, $01d0
    dw   $01f0, $01d0, $01e0, $01c0
    dw   $0002
    db   MAP_HOLIDAY_TV1

    db   ENTITY_PAW_COIN                       ; #$08
    dw   $00a0, $01a8
    dw   $00b0, $0090, $01b8, $0198
    dw   $0003
    db   MAP_HOLIDAY_TV1

    db   ENTITY_BONUS_COIN                     ; #$09
    dw   $00a0, $012c
    dw   $00b0, $0090, $013c, $011c
    dw   $0000
    db   MAP_HOLIDAY_TV3

    db   ENTITY_HOLIDAY_TV_ICE_SCULPTURE       ; #$0a
    dw   $0070, $02d0
    dw   $0080, $0060, $02e0, $02c0
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_ICE_SCULPTURE       ; #$0b
    dw   $0260, $0080
    dw   $0270, $0250, $0090, $0070
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_ICE_SCULPTURE       ; #$0c
    dw   $0440, $03f0
    dw   $0450, $0430, $0400, $03e0
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_ICE_SCULPTURE       ; #$0d
    dw   $0780, $02f0
    dw   $0790, $0770, $0300, $02e0
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_ICE_SCULPTURE       ; #$0e
    dw   $0130, $04c0
    dw   $0140, $0120, $04d0, $04b0
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_SKATING_ELF         ; #$0f
    dw   $02a0, $0170
    dw   $0330, $0230, $0180, $0160
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_SKATING_ELF         ; #$10
    dw   $0650, $0260
    dw   $06d0, $05d0, $0270, $0250
    dw   $0001
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_EVIL_SANTA          ; #$11
    dw   $0078, $0028
    dw   $00f0, $0060, $0038, $0018
    dw   $0000
    db   MAP_HOLIDAY_TV4

    db   ENTITY_HOLIDAY_TV_PENGUIN             ; #$12
    dw   $00a0, $04c8
    dw   $00d0, $0020, $04d8, $04b8
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_PENGUIN             ; #$13
    dw   $0590, $04c8
    dw   $0610, $0520, $04d8, $04b8
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_PENGUIN             ; #$14
    dw   $0960, $0408
    dw   $09b0, $0930, $0418, $03f8
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_PENGUIN             ; #$15
    dw   $01c0, $03e8
    dw   $0200, $01a0, $03f8, $03d8
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_PENGUIN             ; #$16
    dw   $0410, $0288
    dw   $0460, $03e0, $0298, $0278
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_HOLIDAY_TV_PENGUIN             ; #$17
    dw   $01c0, $00d8
    dw   $0200, $01a0, $00e8, $00c8
    dw   $0000
    db   MAP_HOLIDAY_TV1

    db   ENTITY_LIST_TERMINATOR
