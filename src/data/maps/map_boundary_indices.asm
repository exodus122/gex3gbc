; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/map_boundary_indices.bin
; by tools/render_map_asm.py, per the map_boundary_indices layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; Which boundary record each map uses, one byte per map id. Several maps share a
; record - every Gex Cave map is the same rectangle, and so is every unused slot -
; which is why there are 59 records for 61 maps.
;
; Record MAP_WRAP_BOUNDARY_INDEX is the odd one out: a map pointed at it wraps
; horizontally. No map here uses it, so that path is reachable only if
; wDC2A_MapBoundaryIndex is set from somewhere else.
;
; gex2 has no equivalent of any of this - every gex2 map is the same size, so its
; camera clamps against constants baked into the code.
;
; Record layout - 1 bytes:
;   +0   db  record   - boundary record number
;
; 61 records.
; ==================================================================

    db   $01                                   ; #$00  MAP_GEX_CAVE1
    db   $02                                   ; #$01  MAP_HOLIDAY_TV1
    db   $06                                   ; #$02  MAP_MYSTERY_TV1
    db   $10                                   ; #$03  MAP_TUT_TV1
    db   $17                                   ; #$04  MAP_WESTERN_STATION1
    db   $20                                   ; #$05  MAP_ANIME_CHANNEL1
    db   $29                                   ; #$06  MAP_SUPERHERO_SHOW1
    db   $2f                                   ; #$07  MAP_GEXTREME_SPORTS1
    db   $33                                   ; #$08  MAP_MARSUPIAL_MADNESS1
    db   $34                                   ; #$09  MAP_WW_GEX_WRESTLING1
    db   $35                                   ; #$0a  MAP_LIZARD_OF_OZ1
    db   $36                                   ; #$0b  MAP_CHANNEL_Z1
    db   $01                                   ; #$0c  MAP_GEX_CAVE2
    db   $01                                   ; #$0d  MAP_GEX_CAVE3
    db   $01                                   ; #$0e  MAP_GEX_CAVE4
    db   $03                                   ; #$0f  MAP_HOLIDAY_TV2
    db   $04                                   ; #$10  MAP_HOLIDAY_TV3
    db   $05                                   ; #$11  MAP_HOLIDAY_TV4
    db   $07                                   ; #$12  MAP_MYSTERY_TV2
    db   $08                                   ; #$13  MAP_MYSTERY_TV3
    db   $09                                   ; #$14  MAP_MYSTERY_TV4
    db   $0a                                   ; #$15  MAP_MYSTERY_TV5
    db   $0b                                   ; #$16  MAP_MYSTERY_TV6
    db   $0c                                   ; #$17  MAP_MYSTERY_TV7
    db   $0d                                   ; #$18  MAP_MYSTERY_TV8
    db   $0e                                   ; #$19  MAP_MYSTERY_TV9
    db   $0f                                   ; #$1a  MAP_MYSTERY_TV10
    db   $11                                   ; #$1b  MAP_TUT_TV2
    db   $12                                   ; #$1c  MAP_TUT_TV3
    db   $13                                   ; #$1d  MAP_TUT_TV4
    db   $14                                   ; #$1e  MAP_TUT_TV5
    db   $15                                   ; #$1f  MAP_TUT_TV6
    db   $16                                   ; #$20  MAP_TUT_TV7
    db   $18                                   ; #$21  MAP_WESTERN_STATION2
    db   $19                                   ; #$22  MAP_WESTERN_STATION3
    db   $1a                                   ; #$23  MAP_WESTERN_STATION4
    db   $1b                                   ; #$24  MAP_WESTERN_STATION5
    db   $1c                                   ; #$25  MAP_WESTERN_STATION6
    db   $1d                                   ; #$26  MAP_WESTERN_STATION7
    db   $1e                                   ; #$27  MAP_WESTERN_STATION8
    db   $1f                                   ; #$28  MAP_WESTERN_STATION9
    db   $21                                   ; #$29  MAP_ANIME_CHANNEL2
    db   $22                                   ; #$2a  MAP_ANIME_CHANNEL3
    db   $23                                   ; #$2b  MAP_ANIME_CHANNEL4
    db   $24                                   ; #$2c  MAP_ANIME_CHANNEL5
    db   $25                                   ; #$2d  MAP_ANIME_CHANNEL6
    db   $26                                   ; #$2e  MAP_ANIME_CHANNEL7
    db   $27                                   ; #$2f  MAP_ANIME_CHANNEL8
    db   $28                                   ; #$30  MAP_ANIME_CHANNEL9
    db   $2a                                   ; #$31  MAP_SUPERHERO_SHOW2
    db   $2b                                   ; #$32  MAP_SUPERHERO_SHOW3
    db   $2c                                   ; #$33  MAP_SUPERHERO_SHOW4
    db   $2d                                   ; #$34  MAP_SUPERHERO_SHOW5
    db   $2e                                   ; #$35  MAP_SUPERHERO_SHOW6
    db   $30                                   ; #$36  MAP_GEXTREME_SPORTS2
    db   $31                                   ; #$37  MAP_GEXTREME_SPORTS3
    db   $32                                   ; #$38  MAP_GEXTREME_SPORTS4
    db   $37                                   ; #$39  MAP_CHANNEL_Z2
    db   $38                                   ; #$3a  MAP_CHANNEL_Z3
    db   $39                                   ; #$3b  MAP_CHANNEL_Z4
    db   $3a                                   ; #$3c  MAP_CHANNEL_Z5
