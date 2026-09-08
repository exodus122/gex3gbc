; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/TutTV/TutTV_collectible_list.bin
; by tools/render_map_asm.py, per the collectible_list layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; One level's collectibles, in 16x16-pixel grid cells. The third byte is the map
; id - a gex3 level is many maps, which is the whole difference from gex2's
; two-byte record.
;
; call_00_2f85_CollectibleList_LoadForCurrentLevel builds the same per-column
; index tables gex2 does, and call_00_2f34_CountLevelCollectibleTotal walks this
; list for the HUD denominator - counting until a record whose X is zero, then
; adding the entities whose type drops a collectible when defeated.
;
; The terminating record is $00 $00 COLLECTIBLE_LIST_END; anything after it is
; padding.
;
; Record layout - 3 bytes, COLLECTIBLE_RECORD_SIZE:
;   +0   db  grid_x, grid_y, map_id   - grid x, grid y, then the map it belongs to
;
; 91 records.
; ==================================================================

    db   $02, $2d, MAP_TUT_TV2                 ; #$00
    db   $04, $29, MAP_TUT_TV2                 ; #$01
    db   $05, $14, MAP_TUT_TV7                 ; #$02
    db   $06, $03, MAP_TUT_TV6                 ; #$03
    db   $06, $13, MAP_TUT_TV3                 ; #$04
    db   $06, $13, MAP_TUT_TV7                 ; #$05
    db   $06, $25, MAP_TUT_TV2                 ; #$06
    db   $07, $02, MAP_TUT_TV6                 ; #$07
    db   $07, $0f, MAP_TUT_TV1                 ; #$08
    db   $07, $12, MAP_TUT_TV3                 ; #$09
    db   $07, $12, MAP_TUT_TV7                 ; #$0a
    db   $08, $01, MAP_TUT_TV6                 ; #$0b
    db   $08, $11, MAP_TUT_TV3                 ; #$0c
    db   $08, $21, MAP_TUT_TV2                 ; #$0d
    db   $09, $10, MAP_TUT_TV3                 ; #$0e
    db   $09, $12, MAP_TUT_TV7                 ; #$0f
    db   $0a, $10, MAP_TUT_TV3                 ; #$10
    db   $0a, $13, MAP_TUT_TV7                 ; #$11
    db   $0a, $1d, MAP_TUT_TV2                 ; #$12
    db   $0b, $01, MAP_TUT_TV6                 ; #$13
    db   $0b, $05, MAP_TUT_TV3                 ; #$14
    db   $0b, $11, MAP_TUT_TV3                 ; #$15
    db   $0b, $14, MAP_TUT_TV7                 ; #$16
    db   $0c, $02, MAP_TUT_TV6                 ; #$17
    db   $0c, $12, MAP_TUT_TV3                 ; #$18
    db   $0c, $19, MAP_TUT_TV2                 ; #$19
    db   $0d, $03, MAP_TUT_TV6                 ; #$1a
    db   $0d, $13, MAP_TUT_TV3                 ; #$1b
    db   $0e, $15, MAP_TUT_TV2                 ; #$1c
    db   $0f, $04, MAP_TUT_TV3                 ; #$1d
    db   $10, $11, MAP_TUT_TV2                 ; #$1e
    db   $12, $04, MAP_TUT_TV3                 ; #$1f
    db   $12, $0d, MAP_TUT_TV2                 ; #$20
    db   $14, $09, MAP_TUT_TV2                 ; #$21
    db   $15, $13, MAP_TUT_TV3                 ; #$22
    db   $16, $03, MAP_TUT_TV3                 ; #$23
    db   $16, $12, MAP_TUT_TV3                 ; #$24
    db   $17, $11, MAP_TUT_TV3                 ; #$25
    db   $18, $10, MAP_TUT_TV3                 ; #$26
    db   $19, $03, MAP_TUT_TV3                 ; #$27
    db   $19, $10, MAP_TUT_TV3                 ; #$28
    db   $1a, $11, MAP_TUT_TV3                 ; #$29
    db   $1b, $12, MAP_TUT_TV3                 ; #$2a
    db   $1c, $13, MAP_TUT_TV3                 ; #$2b
    db   $1d, $04, MAP_TUT_TV3                 ; #$2c
    db   $20, $05, MAP_TUT_TV3                 ; #$2d
    db   $21, $09, MAP_TUT_TV2                 ; #$2e
    db   $23, $0d, MAP_TUT_TV2                 ; #$2f
    db   $24, $06, MAP_TUT_TV3                 ; #$30
    db   $25, $11, MAP_TUT_TV2                 ; #$31
    db   $27, $07, MAP_TUT_TV3                 ; #$32
    db   $27, $15, MAP_TUT_TV2                 ; #$33
    db   $29, $19, MAP_TUT_TV2                 ; #$34
    db   $2a, $08, MAP_TUT_TV3                 ; #$35
    db   $2b, $1d, MAP_TUT_TV2                 ; #$36
    db   $2d, $0a, MAP_TUT_TV3                 ; #$37
    db   $2d, $21, MAP_TUT_TV2                 ; #$38
    db   $2f, $25, MAP_TUT_TV2                 ; #$39
    db   $30, $0b, MAP_TUT_TV3                 ; #$3a
    db   $31, $10, MAP_TUT_TV3                 ; #$3b
    db   $32, $10, MAP_TUT_TV3                 ; #$3c
    db   $34, $09, MAP_TUT_TV3                 ; #$3d
    db   $37, $08, MAP_TUT_TV3                 ; #$3e
    db   $3a, $06, MAP_TUT_TV3                 ; #$3f
    db   $3d, $05, MAP_TUT_TV3                 ; #$40
    db   $41, $04, MAP_TUT_TV3                 ; #$41
    db   $44, $04, MAP_TUT_TV3                 ; #$42
    db   $47, $03, MAP_TUT_TV3                 ; #$43
    db   $47, $13, MAP_TUT_TV3                 ; #$44
    db   $48, $12, MAP_TUT_TV3                 ; #$45
    db   $49, $11, MAP_TUT_TV3                 ; #$46
    db   $4a, $10, MAP_TUT_TV3                 ; #$47
    db   $4b, $03, MAP_TUT_TV3                 ; #$48
    db   $4b, $10, MAP_TUT_TV3                 ; #$49
    db   $4c, $11, MAP_TUT_TV3                 ; #$4a
    db   $4d, $12, MAP_TUT_TV3                 ; #$4b
    db   $4e, $13, MAP_TUT_TV3                 ; #$4c
    db   $4f, $04, MAP_TUT_TV3                 ; #$4d
    db   $52, $05, MAP_TUT_TV3                 ; #$4e
    db   $55, $06, MAP_TUT_TV3                 ; #$4f
    db   $59, $07, MAP_TUT_TV3                 ; #$50
    db   $59, $13, MAP_TUT_TV3                 ; #$51
    db   $5a, $12, MAP_TUT_TV3                 ; #$52
    db   $5b, $11, MAP_TUT_TV3                 ; #$53
    db   $5c, $08, MAP_TUT_TV3                 ; #$54
    db   $5c, $10, MAP_TUT_TV3                 ; #$55
    db   $5d, $10, MAP_TUT_TV3                 ; #$56
    db   $5e, $11, MAP_TUT_TV3                 ; #$57
    db   $5f, $0a, MAP_TUT_TV3                 ; #$58
    db   $5f, $12, MAP_TUT_TV3                 ; #$59
    db   $60, $13, MAP_TUT_TV3                 ; #$5a
    db   $00
    db   $00, $ff                              ; unreachable, past the terminator
