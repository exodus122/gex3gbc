; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/WesternStation/WesternStation_spawns.bin
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
; 17 records.
; ==================================================================

    db   MAP_WESTERN_STATION4                  ; #$00
    dw   $0010, $0070
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION1                  ; #$01
    dw   $00c0, $0150
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION7                  ; #$02
    dw   $0010, $0070
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION1                  ; #$03
    dw   $0110, $0150
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION8                  ; #$04
    dw   $0010, $0100
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION1                  ; #$05
    dw   $0198, $00a0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION9                  ; #$06
    dw   $0010, $0070
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION1                  ; #$07
    dw   $01f0, $0150
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION3                  ; #$08
    dw   $0130, $0090
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION2                  ; #$09
    dw   $01aa, $0098
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION2                  ; #$0a
    dw   $0010, $0140
    db   $0b, $00, $00

    db   MAP_WESTERN_STATION1                  ; #$0b
    dw   $0270, $0150
    db   $0a, $00, $00

    db   MAP_WESTERN_STATION5                  ; #$0c
    dw   $0010, $0100
    db   $0d, $00, $00

    db   MAP_WESTERN_STATION6                  ; #$0d
    dw   $07c0, $0248
    db   $0c, $00, $00

    db   MAP_WESTERN_STATION6                  ; #$0e
    dw   $0028, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION6                  ; #$0f
    dw   $0368, $0010
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_WESTERN_STATION8                  ; #$10
    dw   $0060, $0110
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00
