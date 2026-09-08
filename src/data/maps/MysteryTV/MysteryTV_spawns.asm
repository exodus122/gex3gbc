; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/MysteryTV/MysteryTV_spawns.bin
; by tools/render_map_asm.py, per the level_spawn_list layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; One level's spawn points, indexed by spawn id. A door, a map edge or a checkpoint
; names a spawn id; call_00_1633_Map_LoadWarpDestination turns it into a map and a
; position, and by the time bank03's Map_SetSpawnPosition runs the answer is already
; in wDC6A_WarpDestinationX / wDC6C_WarpDestinationY.
;
; That is the big structural difference from gex2, which searches a door list at
; spawn time in bank0B and can fail to match. Here the lookup already happened.
;
; Positions are world pixels, not blocks - no conversion anywhere.
;
; There is no terminator: nothing walks these lists, they are only indexed.
;
; Record layout - 8 bytes, MAP_SPAWN_ENTRY_SIZE:
;   +0   db  map_id   - destination map
;   +1   dw  x, y   - destination position, world pixels
;   +5   db  link, spare0, spare1   - linked spawn id, or the sentinel for a fixed position, then 2 spare
;
; 24 records.
; ==================================================================

    db   MAP_MYSTERY_TV2                       ; #$00
    dw   $00c0, $0260
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV4                       ; #$01
    dw   $0020, $0080
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV5                       ; #$02
    dw   $0120, $0130
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV6                       ; #$03
    dw   $0020, $01e0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV6                       ; #$04
    dw   $0120, $01e0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV7                       ; #$05
    dw   $0048, $0060
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$06
    dw   $0298, $02b0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV3                       ; #$07
    dw   $0018, $0068
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV3                       ; #$08
    dw   $02b8, $0068
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV2                       ; #$09
    dw   $0010, $00cc
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV2                       ; #$0a
    dw   $0238, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$0b
    dw   $0228, $02b0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$0c
    dw   $0268, $01d0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$0d
    dw   $00d8, $0140
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$0e
    dw   $01f8, $0080
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$0f
    dw   $0028, $0050
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV8                       ; #$10
    dw   $0050, $0070
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV7                       ; #$11
    dw   $0050, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV10                      ; #$12
    dw   $0010, $02d8
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV2                       ; #$13
    dw   $0270, $022c
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV9                       ; #$14
    dw   $00a0, $0280
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV4                       ; #$15
    dw   $00a0, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$16
    dw   $0108, $0250
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_MYSTERY_TV1                       ; #$17
    dw   $02a8, $01d0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00
