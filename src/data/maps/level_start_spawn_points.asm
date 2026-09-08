; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/level_start_spawn_points.bin
; by tools/render_map_asm.py, per the level_start_spawn_points layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; Where Gex starts a level, one record per level. Indexed by wDB6C_CurrentMapId,
; which at this point in a level load holds the LEVEL id - home.asm copies
; wDC1E_CurrentLevelID into it just before calling - and the first map of every level
; happens to share its level's id. So twelve records cover every index this can
; produce, and a real map id above $0B never reaches here.
;
; gex2 stores several checkpoints per level here; gex3 stores one start and handles
; checkpoints through the warp path instead.
;
; Record layout - 4 bytes:
;   +0   spawn_pos  x, y   - world X, world Y
;
; 12 records.
; ==================================================================

    spawn_pos $0100, $00f0                     ; #$00  LEVEL_GEX_CAVE
    spawn_pos $0050, $04c0                     ; #$01  LEVEL_HOLIDAY_TV
    spawn_pos $0048, $02b0                     ; #$02  LEVEL_MYSTERY_TV
    spawn_pos $00f0, $0110                     ; #$03  LEVEL_TUT_TV
    spawn_pos $0038, $0150                     ; #$04  LEVEL_WESTERN_STATION
    spawn_pos $01f0, $0080                     ; #$05  LEVEL_ANIME_CHANNEL
    spawn_pos $0ad8, $0120                     ; #$06  LEVEL_SUPERHERO_SHOW
    spawn_pos $0298, $02b8                     ; #$07  LEVEL_GEXTREME_SPORTS
    spawn_pos $01a8, $03f8                     ; #$08  LEVEL_MARSUPIAL_MADNESS
    spawn_pos $00c0, $0080                     ; #$09  LEVEL_WW_GEX_WRESTLING
    spawn_pos $0078, $0060                     ; #$0a  LEVEL_LIZARD_OF_OZ
    spawn_pos $00c8, $0320                     ; #$0b  LEVEL_CHANNEL_Z
