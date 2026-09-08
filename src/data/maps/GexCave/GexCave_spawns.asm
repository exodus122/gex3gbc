; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/GexCave/GexCave_spawns.bin
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
; 6 records.
; ==================================================================

    db   MAP_GEX_CAVE1                         ; #$00
    dw   $01b0, $00f0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_GEX_CAVE1                         ; #$01
    dw   $0050, $0070
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_GEX_CAVE1                         ; #$02
    dw   $0150, $0040
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_GEX_CAVE2                         ; #$03
    dw   $00f0, $0080
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_GEX_CAVE3                         ; #$04
    dw   $00f0, $00f0
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00

    db   MAP_GEX_CAVE4                         ; #$05
    dw   $0030, $0030
    db   MAP_SPAWN_LINK_ABSOLUTE, $00, $00
