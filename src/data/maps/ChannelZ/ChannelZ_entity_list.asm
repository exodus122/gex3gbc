; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/ChannelZ/ChannelZ_entity_list.bin
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
; 18 records.
; ==================================================================

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$00
    dw   $0260, $00c0
    dw   $0270, $0250, $00d0, $00b0
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH        ; #$01
    dw   $0148, $0038
    dw   $0158, $0138, $0048, $0028
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_CHANNEL_Z_METEOR               ; #$02
    dw   $01a8, $02a8
    dw   $01b8, $0198, $02b8, $0298
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_CHANNEL_Z_METEOR               ; #$03
    dw   $0188, $0278
    dw   $0198, $0178, $0288, $0268
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_CHANNEL_Z_METEOR               ; #$04
    dw   $00d8, $0228
    dw   $00e8, $00c8, $0238, $0218
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_CHANNEL_Z_METEOR               ; #$05
    dw   $0178, $0208
    dw   $0188, $0168, $0218, $01f8
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_CHANNEL_Z_METEOR               ; #$06
    dw   $0198, $0148
    dw   $01a8, $0188, $0158, $0138
    dw   $0000
    db   MAP_CHANNEL_Z1

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$07
    dw   $0030, $00f0
    dw   $0040, $0020, $0100, $00e0
    dw   $00ff
    db   MAP_CHANNEL_Z2

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$08
    dw   $0100, $00b0
    dw   $0110, $00f0, $00c0, $00a0
    dw   $00ff
    db   MAP_CHANNEL_Z2

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$09
    dw   $01c0, $00f0
    dw   $01d0, $01b0, $0100, $00e0
    dw   $0001
    db   MAP_CHANNEL_Z2

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$0a
    dw   $0100, $0020
    dw   $0110, $00f0, $0030, $0010
    dw   $0002
    db   MAP_CHANNEL_Z2

    db   ENTITY_PURPLE_FLY_TV                  ; #$0b
    dw   $0048, $0030
    dw   $0058, $0038, $0040, $0020
    dw   $0000
    db   MAP_CHANNEL_Z3

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$0c
    dw   $0138, $0180
    dw   $0148, $0128, $0190, $0170
    dw   $00ff
    db   MAP_CHANNEL_Z3

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH        ; #$0d
    dw   $0238, $0038
    dw   $0248, $0228, $0048, $0028
    dw   $0001
    db   MAP_CHANNEL_Z3

    db   ENTITY_PURPLE_FLY_TV                  ; #$0e
    dw   $0238, $0030
    dw   $0248, $0228, $0040, $0020
    dw   $0000
    db   MAP_CHANNEL_Z4

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$0f
    dw   $0138, $0180
    dw   $0148, $0128, $0190, $0170
    dw   $00ff
    db   MAP_CHANNEL_Z4

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH        ; #$10
    dw   $0048, $0038
    dw   $0058, $0038, $0048, $0028
    dw   $0002
    db   MAP_CHANNEL_Z4

    db   ENTITY_CHANNEL_Z_REZ                  ; #$11
    dw   $0078, $0024
    dw   $00d0, $0020, $0034, $0014
    dw   $0000
    db   MAP_CHANNEL_Z5

    db   ENTITY_LIST_TERMINATOR
    db   $00, $00, $00, $00                    ; unreachable, past the terminator
