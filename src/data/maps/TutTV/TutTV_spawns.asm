; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/TutTV/TutTV_spawns.bin
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
; 13 records.
; ==================================================================

    db   MAP_TUT_TV2                           ; #$00
    dw   $0010, $0300
    db   $05, $00, $00

    db   MAP_TUT_TV4                           ; #$01
    dw   $0454, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_TUT_TV4                           ; #$02
    dw   $0454, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_TUT_TV3                           ; #$03
    dw   $0010, $0140
    db   $04, $00, $00

    db   MAP_TUT_TV2                           ; #$04
    dw   $0330, $0300
    db   $03, $00, $00

    db   MAP_TUT_TV1                           ; #$05
    dw   $0260, $00d0
    db   $00, $00, $00

    db   MAP_TUT_TV1                           ; #$06
    dw   $0048, $0110
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_TUT_TV5                           ; #$07
    dw   $0010, $0078
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_TUT_TV2                           ; #$08
    dw   $00ec, $0260
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_TUT_TV6                           ; #$09
    dw   $0008, $0070
    db   $0a, $00, $00

    db   MAP_TUT_TV3                           ; #$0a
    dw   $0630, $0140
    db   $09, $00, $00

    db   MAP_TUT_TV7                           ; #$0b
    dw   $0010, $0160
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_TUT_TV2                           ; #$0c
    dw   $027c, $0260
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00
