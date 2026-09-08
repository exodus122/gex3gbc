; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/TutTV/TutTV_entity_list.bin
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
; 51 records.
; ==================================================================

    db   ENTITY_TV_BUTTON                      ; #$00
    dw   $02e0, $0170
    dw   $02f0, $02d0, $0180, $0160
    dw   $0001
    db   MAP_TUT_TV7

    db   ENTITY_TV_REMOTE                      ; #$01
    dw   $02e0, $0150
    dw   $02f0, $02d0, $0160, $0140
    dw   $0001
    db   MAP_TUT_TV7

    db   ENTITY_TV_BUTTON                      ; #$02
    dw   $0070, $0088
    dw   $0080, $0060, $0098, $0078
    dw   $0002
    db   MAP_TUT_TV5

    db   ENTITY_TV_REMOTE                      ; #$03
    dw   $0070, $0068
    dw   $0080, $0060, $0078, $0058
    dw   $0002
    db   MAP_TUT_TV5

    db   ENTITY_TV_BUTTON                      ; #$04
    dw   $00a0, $0068
    dw   $00b0, $0090, $0078, $0058
    dw   $0003
    db   MAP_TUT_TV6

    db   ENTITY_TV_REMOTE                      ; #$05
    dw   $00a0, $0048
    dw   $00b0, $0090, $0058, $0038
    dw   $0003
    db   MAP_TUT_TV6

    db   ENTITY_PAW_COIN                       ; #$06
    dw   $004c, $0040
    dw   $005c, $003c, $0050, $0030
    dw   $0001
    db   MAP_TUT_TV1

    db   ENTITY_PAW_COIN                       ; #$07
    dw   $0088, $00f8
    dw   $0098, $0078, $0108, $00e8
    dw   $0002
    db   MAP_TUT_TV3

    db   ENTITY_PAW_COIN                       ; #$08
    dw   $0454, $00c0
    dw   $0464, $0444, $00d0, $00b0
    dw   $0003
    db   MAP_TUT_TV4

    db   ENTITY_BONUS_COIN                     ; #$09
    dw   $0074, $0058
    dw   $0084, $0064, $0068, $0048
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_TUT_TV_LOST_ARK                ; #$0a
    dw   $013c, $0050
    dw   $014c, $012c, $0060, $0040
    dw   $0000
    db   MAP_TUT_TV1

    db   ENTITY_TUT_TV_LOST_ARK                ; #$0b
    dw   $00dc, $02e8
    dw   $00ec, $00cc, $02f8, $02d8
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_TUT_TV_LOST_ARK                ; #$0c
    dw   $0034, $0060
    dw   $0044, $0024, $0070, $0050
    dw   $0000
    db   MAP_TUT_TV5

    db   ENTITY_TUT_TV_RA_STAFF                ; #$0d
    dw   $01c0, $0038
    dw   $01d0, $01b0, $0048, $0028
    dw   $0000
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RA_STAFF                ; #$0e
    dw   $0190, $0120
    dw   $01a0, $0180, $0130, $0110
    dw   $0000
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RA_STAFF                ; #$0f
    dw   $0290, $00e0
    dw   $02a0, $0280, $00f0, $00d0
    dw   $0000
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_SNAKE_FACING_RIGHT      ; #$10
    dw   $0080, $0110
    dw   $0090, $0070, $0120, $0100
    dw   $0000
    db   MAP_TUT_TV1

    db   ENTITY_TUT_TV_SNAKE_FACING_RIGHT      ; #$11
    dw   $0218, $0110
    dw   $0228, $0208, $0120, $0100
    dw   $0000
    db   MAP_TUT_TV1

    db   ENTITY_TUT_TV_SNAKE_FACING_RIGHT      ; #$12
    dw   $0170, $0088
    dw   $0180, $0160, $0098, $0078
    dw   $0000
    db   MAP_TUT_TV1

    db   ENTITY_TUT_TV_SNAKE_FACING_LEFT       ; #$13
    dw   $01a0, $00f0
    dw   $01b0, $0190, $0100, $00e0
    dw   $0000
    db   MAP_TUT_TV1

    db   ENTITY_TUT_TV_SNAKE_FACING_LEFT       ; #$14
    dw   $0240, $00f0
    dw   $0250, $0230, $0100, $00e0
    dw   $0000
    db   MAP_TUT_TV1

    db   ENTITY_TUT_TV_RISING_PLATFORM         ; #$15
    dw   $0620, $00f8
    dw   $0630, $0610, $0140, $0100
    dw   $0040
    db   MAP_TUT_TV3

    db   ENTITY_TUT_TV_RISING_PLATFORM         ; #$16
    dw   $01b0, $01c8
    dw   $01c0, $01a0, $0280, $0200
    dw   $00c0
    db   MAP_TUT_TV2

    db   ENTITY_TUT_TV_RISING_PLATFORM         ; #$17
    dw   $01c0, $0078
    dw   $01d0, $01b0, $0100, $0070
    dw   $0088
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RISING_PLATFORM         ; #$18
    dw   $0250, $0100
    dw   $0260, $0240, $0180, $0100
    dw   $0078
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_SIDEWAYS_PLATFORM       ; #$19
    dw   $0170, $0180
    dw   $01e0, $0150, $0190, $0170
    dw   $0040
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RISING_PLATFORM         ; #$1a
    dw   $0090, $02b8
    dw   $00a0, $0080, $02e0, $02b0
    dw   $0030
    db   MAP_TUT_TV2

    db   ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE  ; #$1b
    dw   $0174, $0026
    dw   $0200, $0180, $0036, $0016
    dw   $0000
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE  ; #$1c
    dw   $020c, $0026
    dw   $0200, $0180, $0036, $0016
    dw   $0001
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE  ; #$1d
    dw   $0134, $012e
    dw   $01e0, $0140, $013e, $011e
    dw   $0002
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE  ; #$1e
    dw   $01ec, $012e
    dw   $01e0, $0140, $013e, $011e
    dw   $0003
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE  ; #$1f
    dw   $02ac, $012e
    dw   $02bc, $029c, $013e, $011e
    dw   $0004
    db   MAP_TUT_TV7

    db   ENTITY_TUT_TV_HAND                    ; #$20
    dw   $01a0, $0048
    dw   $01e0, $0180, $0058, $0038
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_TUT_TV_BREAKABLE_BLOCK         ; #$21
    dw   $01b0, $0058
    dw   $01c0, $01a0, $0068, $0048
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_TUT_TV_RAFT                    ; #$22
    dw   $0070, $0158
    dw   $0600, $0030, $0168, $0148
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_TUT_TV_BEE                     ; #$23
    dw   $0210, $0120
    dw   $0260, $01e0, $0130, $0110
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_TUT_TV_BEE                     ; #$24
    dw   $02b0, $0120
    dw   $0300, $0280, $0130, $0110
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_TUT_TV_BEE                     ; #$25
    dw   $0370, $0120
    dw   $03c0, $0340, $0130, $0110
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_TUT_TV_BEE                     ; #$26
    dw   $0410, $0120
    dw   $0460, $03e0, $0130, $0110
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_MYSTERY_TV_FISH                ; #$27
    dw   $0050, $00f0
    dw   $0070, $0040, $0100, $00e0
    dw   $0000
    db   MAP_TUT_TV4

    db   ENTITY_MYSTERY_TV_FISH                ; #$28
    dw   $0100, $0100
    dw   $0120, $00f0, $0110, $00f0
    dw   $0000
    db   MAP_TUT_TV4

    db   ENTITY_MYSTERY_TV_FISH                ; #$29
    dw   $0180, $0110
    dw   $01a0, $0170, $0120, $0100
    dw   $0000
    db   MAP_TUT_TV4

    db   ENTITY_MYSTERY_TV_FISH                ; #$2a
    dw   $01f0, $0100
    dw   $0210, $01e0, $0110, $00f0
    dw   $0000
    db   MAP_TUT_TV4

    db   ENTITY_MYSTERY_TV_FISH                ; #$2b
    dw   $0280, $00f0
    dw   $02a0, $0270, $0100, $00e0
    dw   $0000
    db   MAP_TUT_TV4

    db   ENTITY_MYSTERY_TV_FISH                ; #$2c
    dw   $0370, $0100
    dw   $0390, $0360, $0110, $00f0
    dw   $0000
    db   MAP_TUT_TV4

    db   ENTITY_TUT_TV_COFFIN                  ; #$2d
    dw   $00ed, $0250
    dw   $00fd, $00dd, $0260, $0240
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_TUT_TV_COFFIN                  ; #$2e
    dw   $027d, $0250
    dw   $028d, $026d, $0260, $0240
    dw   $0001
    db   MAP_TUT_TV2

    db   ENTITY_GREEN_FLY_TV                   ; #$2f
    dw   $0320, $02a0
    dw   $0330, $0310, $02b0, $0290
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_GREEN_FLY_TV                   ; #$30
    dw   $00f0, $0200
    dw   $0100, $00e0, $0210, $01f0
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_GREEN_FLY_TV                   ; #$31
    dw   $0220, $0170
    dw   $0230, $0210, $0180, $0160
    dw   $0000
    db   MAP_TUT_TV2

    db   ENTITY_PURPLE_FLY_TV                  ; #$32
    dw   $0320, $0140
    dw   $0330, $0310, $0150, $0130
    dw   $0000
    db   MAP_TUT_TV3

    db   ENTITY_LIST_TERMINATOR
