; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/map_boundary_records.bin
; by tools/render_map_asm.py, per the map_boundary_records layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; The map rectangles, in world pixels. The stored values are the CAMERA's travel and
; go into wDC34_MapBoundaryXMinLo..; the loader also adds the four
; PLAYER_BOUNDARY_*_INSET offsets and writes that wider rectangle into
; wDC3C_PlayerBoundaryXMinLo.., which is how far Gex may walk. The player rectangle
; is wider because the camera stops when its own corner reaches the limit while Gex
; still has most of a screen to cross.
;
; Record 0 is selected by no map, and is not a real rectangle either: X min and X max
; are both $0000, so it has no width.
;
; The note on each record is COMPUTED from the table, not authored, so it
; cannot go stale. Do not hand-correct it - fix the data or the generator.
;
; Record layout - 8 bytes:
;   +0   map_bounds  x_min, x_max, y_min, y_max   - X min, X max, Y min, Y max
;
; 59 records.
; ==================================================================

    map_bounds $0000, $0000, $0204, $0373      ; #$00  unused
    map_bounds $0000, $0140, $0000, $0090      ; #$01  MAP_GEX_CAVE1, MAP_GEX_CAVE2 +2 more
    map_bounds $0000, $0960, $0001, $047f      ; #$02  MAP_HOLIDAY_TV1
    map_bounds $0000, $00a0, $0001, $002f      ; #$03  MAP_HOLIDAY_TV2
    map_bounds $0000, $00a0, $00b1, $00df      ; #$04  MAP_HOLIDAY_TV3
    map_bounds $0000, $00a0, $0000, $0000      ; #$05  MAP_HOLIDAY_TV4
    map_bounds $0000, $0230, $0001, $024f      ; #$06  MAP_MYSTERY_TV1
    map_bounds $0000, $01e0, $0001, $01ef      ; #$07  MAP_MYSTERY_TV2
    map_bounds $0000, $0230, $0001, $015f      ; #$08  MAP_MYSTERY_TV3
    map_bounds $0000, $00a0, $0001, $002f      ; #$09  MAP_MYSTERY_TV4
    map_bounds $0000, $00a0, $00b1, $00df      ; #$0a  MAP_MYSTERY_TV5
    map_bounds $0000, $00a0, $0161, $018f      ; #$0b  MAP_MYSTERY_TV6
    map_bounds $0000, $0000, $0000, $0000      ; #$0c  MAP_MYSTERY_TV7
    map_bounds $0000, $0000, $0000, $0000      ; #$0d  MAP_MYSTERY_TV8
    map_bounds $0000, $00a0, $0211, $021f      ; #$0e  MAP_MYSTERY_TV9
    map_bounds $0000, $01e0, $0290, $02a0      ; #$0f  MAP_MYSTERY_TV10
    map_bounds $0000, $01d0, $0000, $00b0      ; #$10  MAP_TUT_TV1
    map_bounds $0000, $02a0, $0000, $02b0      ; #$11  MAP_TUT_TV2
    map_bounds $0000, $05a0, $0000, $00f0      ; #$12  MAP_TUT_TV3
    map_bounds $0000, $0400, $0000, $00b0      ; #$13  MAP_TUT_TV4
    map_bounds $0000, $0000, $0001, $000f      ; #$14  MAP_TUT_TV5
    map_bounds $0000, $00a0, $0000, $0010      ; #$15  MAP_TUT_TV6
    map_bounds $0000, $0280, $0000, $0110      ; #$16  MAP_TUT_TV7
    map_bounds $0000, $01e0, $0000, $00f0      ; #$17  MAP_WESTERN_STATION1
    map_bounds $0000, $01c0, $0000, $00e0      ; #$18  MAP_WESTERN_STATION2
    map_bounds $0000, $00a0, $0000, $0030      ; #$19  MAP_WESTERN_STATION3
    map_bounds $0000, $0000, $0000, $0010      ; #$1a  MAP_WESTERN_STATION4
    map_bounds $0000, $0460, $0000, $00a0      ; #$1b  MAP_WESTERN_STATION5
    map_bounds $0000, $0730, $0000, $02b0      ; #$1c  MAP_WESTERN_STATION6
    map_bounds $0000, $0000, $0000, $0010      ; #$1d  MAP_WESTERN_STATION7
    map_bounds $0000, $0000, $0090, $00a0      ; #$1e  MAP_WESTERN_STATION8
    map_bounds $0000, $0000, $0000, $0010      ; #$1f  MAP_WESTERN_STATION9
    map_bounds $0000, $0340, $0000, $0160      ; #$20  MAP_ANIME_CHANNEL1
    map_bounds $0000, $0260, $0000, $0160      ; #$21  MAP_ANIME_CHANNEL2
    map_bounds $0000, $02e0, $0000, $00b0      ; #$22  MAP_ANIME_CHANNEL3
    map_bounds $0000, $0540, $0000, $0220      ; #$23  MAP_ANIME_CHANNEL4
    map_bounds $03c0, $0eb0, $0000, $00e0      ; #$24  MAP_ANIME_CHANNEL5
    map_bounds $0000, $0140, $0000, $0090      ; #$25  MAP_ANIME_CHANNEL6
    map_bounds $0000, $0140, $0110, $01a0      ; #$26  MAP_ANIME_CHANNEL7
    map_bounds $0000, $0140, $0220, $02b0      ; #$27  MAP_ANIME_CHANNEL8
    map_bounds $0100, $0330, $0000, $00e0      ; #$28  MAP_ANIME_CHANNEL9
    map_bounds $0000, $0b50, $0000, $0160      ; #$29  MAP_SUPERHERO_SHOW1
    map_bounds $0000, $0b80, $0000, $03c0      ; #$2a  MAP_SUPERHERO_SHOW2
    map_bounds $0000, $0390, $0000, $0160      ; #$2b  MAP_SUPERHERO_SHOW3
    map_bounds $0000, $0560, $0000, $0160      ; #$2c  MAP_SUPERHERO_SHOW4
    map_bounds $0000, $0260, $0000, $01a0      ; #$2d  MAP_SUPERHERO_SHOW5
    map_bounds $0000, $0000, $0000, $0000      ; #$2e  MAP_SUPERHERO_SHOW6
    map_bounds $0000, $0260, $0000, $0280      ; #$2f  MAP_GEXTREME_SPORTS1
    map_bounds $0000, $00a0, $00b0, $00e0      ; #$30  MAP_GEXTREME_SPORTS2
    map_bounds $0000, $00a0, $00b0, $00e0      ; #$31  MAP_GEXTREME_SPORTS3
    map_bounds $0000, $00a0, $00b0, $00e0      ; #$32  MAP_GEXTREME_SPORTS4
    map_bounds $0000, $0160, $0000, $03a0      ; #$33  MAP_MARSUPIAL_MADNESS1
    map_bounds $0000, $00e0, $0000, $00a0      ; #$34  MAP_WW_GEX_WRESTLING1
    map_bounds $0028, $0028, $0000, $0000      ; #$35  MAP_LIZARD_OF_OZ1
    map_bounds $0000, $01e0, $0000, $0300      ; #$36  MAP_CHANNEL_Z1
    map_bounds $0000, $0150, $0000, $0090      ; #$37  MAP_CHANNEL_Z2
    map_bounds $0000, $01e0, $0000, $0180      ; #$38  MAP_CHANNEL_Z3
    map_bounds $0000, $01e0, $0000, $0180      ; #$39  MAP_CHANNEL_Z4
    map_bounds $0028, $0028, $0000, $0000      ; #$3a  MAP_CHANNEL_Z5
