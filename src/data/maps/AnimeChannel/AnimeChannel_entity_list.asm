; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/AnimeChannel/AnimeChannel_entity_list.bin
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
; 119 records.
; ==================================================================

    db   ENTITY_TV_BUTTON                      ; #$00
    dw   $00c0, $0130
    dw   $00d0, $00b0, $0140, $0120
    dw   $0001
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_TV_REMOTE                      ; #$01
    dw   $00c0, $0110
    dw   $00d0, $00b0, $0120, $0100
    dw   $0001
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_TV_BUTTON                      ; #$02
    dw   $01f0, $0130
    dw   $0200, $01e0, $0140, $0120
    dw   $0002
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_TV_REMOTE                      ; #$03
    dw   $01f0, $0110
    dw   $0200, $01e0, $0120, $0100
    dw   $0002
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_TV_BUTTON                      ; #$04
    dw   $0320, $0130
    dw   $0330, $0310, $0140, $0120
    dw   $0003
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_TV_REMOTE                      ; #$05
    dw   $0320, $0110
    dw   $0330, $0310, $0120, $0100
    dw   $0003
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_PAW_COIN                       ; #$06
    dw   $00b0, $00c0
    dw   $00c0, $00a0, $00d0, $00b0
    dw   $0001
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_PAW_COIN                       ; #$07
    dw   $02d0, $00c0
    dw   $02e0, $02c0, $00d0, $00b0
    dw   $0002
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_PAW_COIN                       ; #$08
    dw   $0770, $00d0
    dw   $0780, $0760, $00e0, $00c0
    dw   $0003
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_BONUS_COIN                     ; #$09
    dw   $0180, $0040
    dw   $0190, $0170, $0050, $0030
    dw   $0000
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$0a
    dw   $00c0, $01c0
    dw   $00d0, $00b0, $01d0, $01b0
    dw   $00ff
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$0b
    dw   $01f0, $01c0
    dw   $0200, $01e0, $01d0, $01b0
    dw   $00ff
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$0c
    dw   $0320, $01c0
    dw   $0330, $0310, $01d0, $01b0
    dw   $00ff
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$0d
    dw   $0048, $00a8
    dw   $0070, $0020, $00b8, $0098
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$0e
    dw   $0128, $0048
    dw   $0160, $00f0, $0058, $0038
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$0f
    dw   $02b8, $0048
    dw   $02f0, $0280, $0058, $0038
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$10
    dw   $0398, $00a8
    dw   $03c0, $0370, $00b8, $0098
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_GREEN_FLY_TV                   ; #$11
    dw   $0120, $00c0
    dw   $0130, $0110, $00d0, $00b0
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_GREEN_FLY_TV                   ; #$12
    dw   $02c0, $00c0
    dw   $02d0, $02b0, $00d0, $00b0
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_GREEN_FLY_TV                   ; #$13
    dw   $0120, $0160
    dw   $0130, $0110, $0170, $0150
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_GREEN_FLY_TV                   ; #$14
    dw   $02c0, $0160
    dw   $02d0, $02b0, $0170, $0150
    dw   $0000
    db   MAP_ANIME_CHANNEL1

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$15
    dw   $09a0, $0080
    dw   $09b0, $0990, $0090, $0070
    dw   $00ff
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$16
    dw   $0a98, $0038
    dw   $0ad0, $0a50, $0048, $0028
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL ; #$17
    dw   $0b80, $0080
    dw   $0bc0, $0b40, $0090, $0070
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER  ; #$18
    dw   $0ca8, $0050
    dw   $0cb8, $0c98, $0080, $0030
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$19
    dw   $0cf0, $0088
    dw   $0d00, $0ce0, $0098, $0078
    dw   $00d0
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$1a
    dw   $0d40, $0088
    dw   $0d50, $0d30, $0098, $0078
    dw   $00d0
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$1b
    dw   $0d80, $0088
    dw   $0d90, $0d70, $0098, $0078
    dw   $00d0
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$1c
    dw   $0dc0, $0088
    dw   $0dd0, $0db0, $0098, $0078
    dw   $00d0
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_OFF_SWITCH       ; #$1d
    dw   $0d28, $0038
    dw   $0d38, $0d18, $0048, $0028
    dw   $0001
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$1e
    dw   $0e78, $0148
    dw   $0e80, $0e60, $0158, $0138
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH        ; #$1f
    dw   $0eb8, $0148
    dw   $0ec8, $0ea8, $0158, $0138
    dw   $0001
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_FAN_LIFT         ; #$20
    dw   $0ef0, $0138
    dw   $0f00, $0ee0, $0148, $0128
    dw   $0001
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL ; #$21
    dw   $0d70, $0140
    dw   $0dc0, $0d30, $0150, $0130
    dw   $00ff
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$22
    dw   $0cf8, $00e8
    dw   $0d10, $0cd0, $00f8, $00d8
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT ; #$23
    dw   $0b20, $0138
    dw   $0b80, $0ad0, $0148, $0128
    dw   $0002
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$24
    dw   $0a38, $0108
    dw   $0a40, $0a20, $0118, $00f8
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$25
    dw   $0b88, $0108
    dw   $0b90, $0b70, $0118, $00f8
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER  ; #$26
    dw   $09e8, $0110
    dw   $09f8, $09d8, $0140, $00f0
    dw   $0002
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_GREEN_FLY_TV                   ; #$27
    dw   $08f0, $00f0
    dw   $0900, $08e0, $0100, $00e0
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL ; #$28
    dw   $08a0, $0140
    dw   $08d0, $0870, $0150, $0130
    dw   $00ff
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_RISING_PLATFORM  ; #$29
    dw   $07c8, $0140
    dw   $07d8, $07b8, $0150, $0060
    dw   $0000
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_RISING_PLATFORM  ; #$2a
    dw   $07e8, $0140
    dw   $07f8, $07d8, $0150, $0060
    dw   $0001
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT ; #$2b
    dw   $06e0, $0078
    dw   $0780, $06d0, $0088, $0068
    dw   $0003
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER  ; #$2c
    dw   $05f8, $0050
    dw   $0608, $05e8, $0080, $0030
    dw   $0003
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_OFF_SWITCH       ; #$2d
    dw   $05c0, $0048
    dw   $05d0, $05b0, $0058, $0038
    dw   $0004
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH        ; #$2e
    dw   $05f8, $0148
    dw   $0608, $05e8, $0158, $0138
    dw   $0004
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_FAN_LIFT         ; #$2f
    dw   $05c0, $0138
    dw   $05d0, $05b0, $0148, $0128
    dw   $0004
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT ; #$30
    dw   $04b8, $00d8
    dw   $04f0, $0480, $00e8, $00c8
    dw   $0005
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$31
    dw   $03e0, $0140
    dw   $03f0, $03d0, $0150, $0130
    dw   $0005
    db   MAP_ANIME_CHANNEL5

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$32
    dw   $0170, $0148
    dw   $0180, $0160, $0158, $0138
    dw   $0090
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT  ; #$33
    dw   $0160, $0110
    dw   $0170, $0150, $0120, $0100
    dw   $000a
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$34
    dw   $03b0, $0140
    dw   $03c0, $03a0, $0150, $0130
    dw   $000d
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$35
    dw   $0170, $00a0
    dw   $0180, $0160, $00b0, $0090
    dw   $000a
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$36
    dw   $0250, $0030
    dw   $0260, $0240, $0040, $0020
    dw   $000b
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$37
    dw   $0330, $00a0
    dw   $0340, $0320, $00b0, $0090
    dw   $000c
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_GREEN_FLY_TV                   ; #$38
    dw   $0140, $0040
    dw   $0150, $0130, $0050, $0030
    dw   $0000
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_GREEN_FLY_TV                   ; #$39
    dw   $0360, $0040
    dw   $0370, $0350, $0050, $0030
    dw   $0000
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_BLUE_FLY_TV                    ; #$3a
    dw   $0250, $0070
    dw   $0260, $0240, $0080, $0060
    dw   $0001
    db   MAP_ANIME_CHANNEL9

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$3b
    dw   $01a0, $00f0
    dw   $01b0, $0190, $0100, $00e0
    dw   $00ff
    db   MAP_ANIME_CHANNEL6

    db   ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE  ; #$3c
    dw   $0050, $00e0
    dw   $0060, $0040, $00f0, $00d0
    dw   $000b
    db   MAP_ANIME_CHANNEL6

    db   ENTITY_PURPLE_FLY_TV                  ; #$3d
    dw   $0030, $0040
    dw   $0040, $0020, $0050, $0030
    dw   $0000
    db   MAP_ANIME_CHANNEL6

    db   ENTITY_GREEN_FLY_TV                   ; #$3e
    dw   $01a0, $0040
    dw   $01b0, $0190, $0050, $0030
    dw   $0000
    db   MAP_ANIME_CHANNEL6

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$3f
    dw   $00f0, $0200
    dw   $0100, $00e0, $0210, $01f0
    dw   $00ff
    db   MAP_ANIME_CHANNEL7

    db   ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE  ; #$40
    dw   $00f0, $0170
    dw   $0100, $00e0, $0180, $0160
    dw   $000c
    db   MAP_ANIME_CHANNEL7

    db   ENTITY_GREEN_FLY_TV                   ; #$41
    dw   $0020, $0180
    dw   $0030, $0010, $0190, $0170
    dw   $0000
    db   MAP_ANIME_CHANNEL7

    db   ENTITY_PURPLE_FLY_TV                  ; #$42
    dw   $01c0, $0180
    dw   $01d0, $01b0, $0190, $0170
    dw   $0000
    db   MAP_ANIME_CHANNEL7

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$43
    dw   $0050, $0310
    dw   $0060, $0040, $0320, $0300
    dw   $00ff
    db   MAP_ANIME_CHANNEL8

    db   ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE  ; #$44
    dw   $01c0, $0300
    dw   $01d0, $01b0, $0310, $02f0
    dw   $000d
    db   MAP_ANIME_CHANNEL8

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$45
    dw   $0160, $0298
    dw   $01b0, $0120, $02a8, $0288
    dw   $0000
    db   MAP_ANIME_CHANNEL8

    db   ENTITY_PURPLE_FLY_TV                  ; #$46
    dw   $0020, $0290
    dw   $0030, $0010, $02a0, $0280
    dw   $0000
    db   MAP_ANIME_CHANNEL8

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$47
    dw   $0030, $0280
    dw   $0040, $0020, $0290, $0270
    dw   $00ff
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH        ; #$48
    dw   $0038, $0198
    dw   $0048, $0028, $01a8, $0188
    dw   $0008
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_ELEVATOR         ; #$49
    dw   $01a0, $0298
    dw   $01b0, $0190, $0290, $0110
    dw   $0008
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_ELEVATOR         ; #$4a
    dw   $0340, $0158
    dw   $0350, $0330, $01d0, $0160
    dw   $0008
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_ELEVATOR         ; #$4b
    dw   $05c0, $01d8
    dw   $05d0, $05b0, $0240, $01e0
    dw   $0008
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH2       ; #$4c
    dw   $0358, $0248
    dw   $0368, $0348, $0258, $0238
    dw   $0008
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT ; #$4d
    dw   $0410, $00e8
    dw   $0450, $03e0, $00f8, $00d8
    dw   $0009
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER  ; #$4e
    dw   $0498, $0050
    dw   $04a8, $0488, $0080, $0030
    dw   $0009
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$4f
    dw   $03e0, $0088
    dw   $0410, $03c0, $0098, $0078
    dw   $0000
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT ; #$50
    dw   $0500, $0048
    dw   $0530, $04e0, $0058, $0038
    dw   $0000
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON  ; #$51
    dw   $05a8, $0080
    dw   $05b8, $0598, $0090, $0070
    dw   $0008
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY  ; #$52
    dw   $0158, $0198
    dw   $0168, $0148, $01a8, $0188
    dw   $0000
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY  ; #$53
    dw   $0098, $01c8
    dw   $00a8, $0088, $01d8, $01b8
    dw   $0000
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY  ; #$54
    dw   $0158, $01f8
    dw   $0168, $0148, $0208, $01e8
    dw   $0000
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY  ; #$55
    dw   $0058, $0228
    dw   $0068, $0048, $0238, $0218
    dw   $0000
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$56
    dw   $0230, $0148
    dw   $0240, $0220, $0158, $0138
    dw   $00d0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$57
    dw   $0278, $0148
    dw   $0288, $0268, $0158, $0138
    dw   $00d0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$58
    dw   $02c0, $0148
    dw   $02d0, $02b0, $0158, $0138
    dw   $00d0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$59
    dw   $03e0, $01c8
    dw   $03f0, $03d0, $01d8, $01b8
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$5a
    dw   $0430, $01c8
    dw   $0440, $0420, $01d8, $01b8
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$5b
    dw   $03e0, $01c8
    dw   $03f0, $03d0, $01d8, $01b8
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$5c
    dw   $04d0, $01c8
    dw   $04e0, $04c0, $01d8, $01b8
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$5d
    dw   $0520, $01c8
    dw   $0530, $0510, $01d8, $01b8
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$5e
    dw   $03a0, $0248
    dw   $03b0, $0390, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$5f
    dw   $03e0, $0248
    dw   $03f0, $03d0, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$60
    dw   $0420, $0248
    dw   $0430, $0410, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$61
    dw   $0460, $0248
    dw   $0470, $0450, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$62
    dw   $04a0, $0248
    dw   $04b0, $0490, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$63
    dw   $04e0, $0248
    dw   $04f0, $04d0, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$64
    dw   $0520, $0248
    dw   $0530, $0510, $0258, $0238
    dw   $00a0
    db   MAP_ANIME_CHANNEL4

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$65
    dw   $0030, $01c0
    dw   $0040, $0020, $01d0, $01b0
    dw   $00ff
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_SECBOT           ; #$66
    dw   $01d0, $01c8
    dw   $01e0, $0130, $01d8, $01b8
    dw   $0006
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_FAN_LIFT         ; #$67
    dw   $0180, $01c8
    dw   $0190, $0170, $01d8, $01b8
    dw   $0006
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_DOOR             ; #$68
    dw   $02e0, $0100
    dw   $02f0, $02d0, $0110, $00f0
    dw   $00ff
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$69
    dw   $0070, $0088
    dw   $0080, $0060, $0098, $0078
    dw   $0090
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT  ; #$6a
    dw   $0060, $0050
    dw   $0070, $0050, $0060, $0040
    dw   $00ff
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$6b
    dw   $0280, $0088
    dw   $0290, $0270, $0098, $0078
    dw   $0090
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT ; #$6c
    dw   $02a0, $0050
    dw   $02b0, $0290, $0060, $0040
    dw   $00ff
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_BLUE_FLY_TV                    ; #$6d
    dw   $02d0, $01c0
    dw   $02e0, $02c0, $01d0, $01b0
    dw   $0001
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_PURPLE_FLY_TV                  ; #$6e
    dw   $0020, $0100
    dw   $0030, $0010, $0110, $00f0
    dw   $0000
    db   MAP_ANIME_CHANNEL2

    db   ENTITY_ANIME_CHANNEL_DOOR2            ; #$6f
    dw   $01c0, $0080
    dw   $01d0, $01b0, $0090, $0070
    dw   $00ff
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$70
    dw   $0070, $0088
    dw   $0080, $0060, $0098, $0078
    dw   $0090
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT  ; #$71
    dw   $0050, $0050
    dw   $0060, $0040, $0060, $0040
    dw   $0007
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_GRENADE          ; #$72
    dw   $0310, $0088
    dw   $0320, $0300, $0098, $0078
    dw   $0090
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT ; #$73
    dw   $0330, $0050
    dw   $0340, $0320, $0060, $0040
    dw   $0007
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR  ; #$74
    dw   $00e0, $0098
    dw   $00f0, $00d0, $00a8, $0088
    dw   $0007
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR  ; #$75
    dw   $02a0, $0098
    dw   $02b0, $0290, $00a8, $0088
    dw   $0007
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_ANIME_CHANNEL_ON_SWITCH2       ; #$76
    dw   $01c0, $0118
    dw   $01d0, $01b0, $0128, $0108
    dw   $0006
    db   MAP_ANIME_CHANNEL3

    db   ENTITY_LIST_TERMINATOR
