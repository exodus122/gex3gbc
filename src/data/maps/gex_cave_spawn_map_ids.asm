; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/gex_cave_spawn_map_ids.bin
; by tools/render_map_asm.py, per the gex_cave_spawn_map_ids layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; Which cave map each level's TV sits on. Level 0 is the cave itself and maps to
; MAP_GEX_CAVE1; the rest are spread over the three later cave maps.
;
; Record layout - 1 bytes:
;   +0   db  map_id
;
; 12 records.
; ==================================================================

    db   MAP_GEX_CAVE1                         ; #$00  LEVEL_GEX_CAVE
    db   MAP_GEX_CAVE2                         ; #$01  LEVEL_HOLIDAY_TV
    db   MAP_GEX_CAVE2                         ; #$02  LEVEL_MYSTERY_TV
    db   MAP_GEX_CAVE3                         ; #$03  LEVEL_TUT_TV
    db   MAP_GEX_CAVE3                         ; #$04  LEVEL_WESTERN_STATION
    db   MAP_GEX_CAVE3                         ; #$05  LEVEL_ANIME_CHANNEL
    db   MAP_GEX_CAVE4                         ; #$06  LEVEL_SUPERHERO_SHOW
    db   MAP_GEX_CAVE3                         ; #$07  LEVEL_GEXTREME_SPORTS
    db   MAP_GEX_CAVE2                         ; #$08  LEVEL_MARSUPIAL_MADNESS
    db   MAP_GEX_CAVE3                         ; #$09  LEVEL_WW_GEX_WRESTLING
    db   MAP_GEX_CAVE4                         ; #$0a  LEVEL_LIZARD_OF_OZ
    db   MAP_GEX_CAVE4                         ; #$0b  LEVEL_CHANNEL_Z
