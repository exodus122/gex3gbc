; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/WesternStation/WesternStation_entity_list.bin
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
; 59 records.
; ==================================================================

    db   ENTITY_TV_BUTTON                      ; #$00
    dw   $04b8, $0090
    dw   $04c8, $04a8, $00a0, $0080
    dw   $0001
    db   MAP_WESTERN_STATION5

    db   ENTITY_TV_REMOTE                      ; #$01
    dw   $04b8, $0070
    dw   $04c8, $04a8, $0080, $0060
    dw   $0001
    db   MAP_WESTERN_STATION5

    db   ENTITY_TV_BUTTON                      ; #$02
    dw   $0048, $02d0
    dw   $0058, $0038, $02e0, $02c0
    dw   $0002
    db   MAP_WESTERN_STATION6

    db   ENTITY_TV_REMOTE                      ; #$03
    dw   $0048, $02b0
    dw   $0058, $0038, $02c0, $02a0
    dw   $0002
    db   MAP_WESTERN_STATION6

    db   ENTITY_TV_BUTTON                      ; #$04
    dw   $07a0, $0260
    dw   $07b0, $0790, $0270, $0250
    dw   $0003
    db   MAP_WESTERN_STATION6

    db   ENTITY_TV_REMOTE                      ; #$05
    dw   $07a0, $0240
    dw   $07b0, $0790, $0250, $0230
    dw   $0003
    db   MAP_WESTERN_STATION6

    db   ENTITY_PAW_COIN                       ; #$06
    dw   $0030, $0020
    dw   $0040, $0020, $0030, $0010
    dw   $0001
    db   MAP_WESTERN_STATION1

    db   ENTITY_PAW_COIN                       ; #$07
    dw   $01e0, $00c0
    dw   $01f0, $01d0, $00d0, $00b0
    dw   $0002
    db   MAP_WESTERN_STATION5

    db   ENTITY_PAW_COIN                       ; #$08
    dw   $0790, $00d0
    dw   $07a0, $0780, $00e0, $00c0
    dw   $0003
    db   MAP_WESTERN_STATION6

    db   ENTITY_BONUS_COIN                     ; #$09
    dw   $00e0, $0030
    dw   $00f0, $00d0, $0040, $0020
    dw   $0000
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_ENEMY_CACTUS   ; #$0a
    dw   $00f0, $0148
    dw   $0240, $0030, $0158, $0138
    dw   $0000
    db   MAP_WESTERN_STATION1

    db   ENTITY_BLUE_FLY_TV                    ; #$0b
    dw   $0150, $0078
    dw   $0160, $0140, $0088, $0068
    dw   $0014
    db   MAP_WESTERN_STATION1

    db   ENTITY_GREEN_FLY_TV                   ; #$0c
    dw   $01e0, $00a0
    dw   $01f0, $01d0, $00b0, $0090
    dw   $0000
    db   MAP_WESTERN_STATION1

    db   ENTITY_PURPLE_FLY_TV                  ; #$0d
    dw   $0248, $0038
    dw   $0258, $0238, $0048, $0028
    dw   $0000
    db   MAP_WESTERN_STATION1

    db   ENTITY_WESTERN_STATION_PLAYING_CARD   ; #$0e
    dw   $0260, $0020
    dw   $0270, $0250, $0030, $0010
    dw   $0000
    db   MAP_WESTERN_STATION1

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$0f
    dw   $0028, $0108
    dw   $0030, $0010, $0118, $00f8
    dw   $003c
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$10
    dw   $0058, $00e0
    dw   $0060, $0030, $00f0, $00d0
    dw   $004b
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$11
    dw   $0098, $00b8
    dw   $00a0, $0070, $00c8, $00a8
    dw   $005a
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$12
    dw   $00c8, $0098
    dw   $00d0, $00a0, $00a8, $0088
    dw   $0069
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$13
    dw   $005e, $0150
    dw   $0100, $0050, $0160, $0140
    dw   $0078
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$14
    dw   $00a3, $0150
    dw   $0100, $0050, $0160, $0140
    dw   $0078
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$15
    dw   $00e8, $0150
    dw   $0100, $0050, $0160, $0140
    dw   $0078
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_PLAYING_CARD   ; #$16
    dw   $0130, $0140
    dw   $0140, $0120, $0150, $0130
    dw   $0000
    db   MAP_WESTERN_STATION2

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$17
    dw   $0230, $00a8
    dw   $0240, $0220, $00b8, $0098
    dw   $0078
    db   MAP_WESTERN_STATION2

    db   ENTITY_GREEN_FLY_TV                   ; #$18
    dw   $0170, $0098
    dw   $0180, $0160, $00a8, $0088
    dw   $0000
    db   MAP_WESTERN_STATION2

    db   ENTITY_TUT_TV_SNAKE_FACING_RIGHT      ; #$19
    dw   $0014, $0065
    dw   $0024, $0004, $0075, $0055
    dw   $0000
    db   MAP_WESTERN_STATION3

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$1a
    dw   $0060, $0098
    dw   $0090, $0050, $00a8, $0088
    dw   $003c
    db   MAP_WESTERN_STATION3

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$1b
    dw   $00d0, $0098
    dw   $0100, $00c0, $00a8, $0088
    dw   $003c
    db   MAP_WESTERN_STATION3

    db   ENTITY_WESTERN_STATION_PLAYING_CARD   ; #$1c
    dw   $0020, $0030
    dw   $0030, $0010, $0040, $0020
    dw   $0000
    db   MAP_WESTERN_STATION3

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$1d
    dw   $0075, $0110
    dw   $0150, $0070, $0120, $0100
    dw   $003c
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_BAT            ; #$1e
    dw   $00aa, $00a8
    dw   $0120, $00a0, $00b8, $0098
    dw   $0000
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$1f
    dw   $00e0, $0110
    dw   $0150, $0070, $0120, $0100
    dw   $003c
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_BAT            ; #$20
    dw   $0115, $00a8
    dw   $0120, $00a0, $00b8, $0098
    dw   $0000
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$21
    dw   $0149, $0110
    dw   $0150, $0070, $0120, $0100
    dw   $003c
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$22
    dw   $0278, $0110
    dw   $0360, $0270, $0120, $0100
    dw   $001e
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_BAT            ; #$23
    dw   $02a8, $00a8
    dw   $0330, $02a0, $00b8, $0098
    dw   $0000
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$24
    dw   $02e8, $0110
    dw   $0360, $0270, $0120, $0100
    dw   $001e
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_BAT            ; #$25
    dw   $0320, $00a8
    dw   $0330, $02a0, $00b8, $0098
    dw   $0000
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_ROCK_PLATFORM  ; #$26
    dw   $0358, $0110
    dw   $0360, $0270, $0120, $0100
    dw   $001e
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$27
    dw   $03c0, $0108
    dw   $03e0, $03c0, $0118, $00f8
    dw   $005a
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$28
    dw   $0400, $0108
    dw   $0420, $0400, $0118, $00f8
    dw   $005a
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_PLAYING_CARD   ; #$29
    dw   $0440, $00a0
    dw   $0450, $0430, $00b0, $0090
    dw   $0000
    db   MAP_WESTERN_STATION5

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$2a
    dw   $0058, $0090
    dw   $0060, $0040, $00a0, $0080
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$2b
    dw   $00c8, $0090
    dw   $00d0, $00b0, $00a0, $0080
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$2c
    dw   $0128, $0300
    dw   $0130, $0110, $0310, $02f0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$2d
    dw   $0188, $0300
    dw   $0190, $0170, $0310, $02f0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$2e
    dw   $0348, $0200
    dw   $0350, $0330, $0210, $01f0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$2f
    dw   $0688, $0050
    dw   $0690, $0670, $0060, $0040
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$30
    dw   $06e8, $0190
    dw   $06f0, $06d0, $01a0, $0180
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$31
    dw   $0698, $0190
    dw   $06a0, $0680, $01a0, $0180
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$32
    dw   $04e8, $0240
    dw   $04f0, $04d0, $0250, $0230
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$33
    dw   $0388, $02e0
    dw   $0390, $0370, $02f0, $02d0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$34
    dw   $03f8, $02e0
    dw   $0400, $03e0, $02f0, $02d0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$35
    dw   $0488, $02e0
    dw   $0490, $0470, $02f0, $02d0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$36
    dw   $0508, $02e0
    dw   $0510, $04f0, $02f0, $02d0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_HARD_HAT       ; #$37
    dw   $0558, $02e0
    dw   $0560, $0540, $02f0, $02d0
    dw   $003c
    db   MAP_WESTERN_STATION6

    db   ENTITY_GREEN_FLY_TV                   ; #$38
    dw   $06f8, $0248
    dw   $0708, $06e8, $0258, $0238
    dw   $0000
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_PLAYING_CARD   ; #$39
    dw   $0410, $0290
    dw   $0420, $0400, $02a0, $0280
    dw   $0000
    db   MAP_WESTERN_STATION6

    db   ENTITY_WESTERN_STATION_RISING_PLATFORM  ; #$3a
    dw   $0768, $00b8
    dw   $0778, $0758, $0130, $00b0
    dw   $0080
    db   MAP_WESTERN_STATION6

    db   ENTITY_LIST_TERMINATOR
