; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/gex_cave_spawn_points.bin
; by tools/render_map_asm.py, per the gex_cave_spawn_points layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; Where Gex stands in the cave after coming back out of a TV, one record per level,
; indexed by wDC5B_LevelIdFromTVButton. Paired with gex_cave_spawn_map_ids: that
; table says which cave map, this one says where on it.
;
; gex2's equivalent is one table, because its hub is a single map; gex3 needs two
; because the cave is four.
;
; Record layout - 4 bytes:
;   +0   spawn_pos  x, y   - world X, world Y
;
; 12 records.
; ==================================================================

    spawn_pos $0100, $00f0                     ; #$00  LEVEL_GEX_CAVE
    spawn_pos $01b0, $0050                     ; #$01  LEVEL_HOLIDAY_TV
    spawn_pos $0030, $0050                     ; #$02  LEVEL_MYSTERY_TV
    spawn_pos $0060, $00f0                     ; #$03  LEVEL_TUT_TV
    spawn_pos $0180, $00f0                     ; #$04  LEVEL_WESTERN_STATION
    spawn_pos $00f0, $0080                     ; #$05  LEVEL_ANIME_CHANNEL
    spawn_pos $0100, $0040                     ; #$06  LEVEL_SUPERHERO_SHOW
    spawn_pos $0030, $0030                     ; #$07  LEVEL_GEXTREME_SPORTS
    spawn_pos $0050, $00f0                     ; #$08  LEVEL_MARSUPIAL_MADNESS
    spawn_pos $01b0, $0030                     ; #$09  LEVEL_WW_GEX_WRESTLING
    spawn_pos $0114, $00f0                     ; #$0a  LEVEL_LIZARD_OF_OZ
    spawn_pos $01b0, $0030                     ; #$0b  LEVEL_CHANNEL_Z
