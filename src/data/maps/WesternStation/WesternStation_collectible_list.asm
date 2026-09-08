; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/WesternStation/WesternStation_collectible_list.bin
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
; 75 records.
; ==================================================================

    db   $01, $04, MAP_WESTERN_STATION6        ; #$00
    db   $01, $05, MAP_WESTERN_STATION6        ; #$01
    db   $01, $06, MAP_WESTERN_STATION6        ; #$02
    db   $02, $05, MAP_WESTERN_STATION4        ; #$03
    db   $02, $05, MAP_WESTERN_STATION7        ; #$04
    db   $02, $05, MAP_WESTERN_STATION9        ; #$05
    db   $02, $0f, MAP_WESTERN_STATION8        ; #$06
    db   $03, $04, MAP_WESTERN_STATION4        ; #$07
    db   $03, $04, MAP_WESTERN_STATION7        ; #$08
    db   $03, $04, MAP_WESTERN_STATION9        ; #$09
    db   $03, $0e, MAP_WESTERN_STATION8        ; #$0a
    db   $04, $03, MAP_WESTERN_STATION4        ; #$0b
    db   $04, $03, MAP_WESTERN_STATION7        ; #$0c
    db   $04, $03, MAP_WESTERN_STATION9        ; #$0d
    db   $04, $0d, MAP_WESTERN_STATION8        ; #$0e
    db   $05, $03, MAP_WESTERN_STATION4        ; #$0f
    db   $05, $03, MAP_WESTERN_STATION7        ; #$10
    db   $05, $03, MAP_WESTERN_STATION9        ; #$11
    db   $05, $0d, MAP_WESTERN_STATION8        ; #$12
    db   $06, $04, MAP_WESTERN_STATION4        ; #$13
    db   $06, $04, MAP_WESTERN_STATION7        ; #$14
    db   $06, $04, MAP_WESTERN_STATION9        ; #$15
    db   $06, $0e, MAP_WESTERN_STATION8        ; #$16
    db   $07, $04, MAP_WESTERN_STATION1        ; #$17
    db   $07, $05, MAP_WESTERN_STATION3        ; #$18
    db   $07, $05, MAP_WESTERN_STATION4        ; #$19
    db   $07, $05, MAP_WESTERN_STATION7        ; #$1a
    db   $07, $05, MAP_WESTERN_STATION9        ; #$1b
    db   $07, $0f, MAP_WESTERN_STATION8        ; #$1c
    db   $08, $04, MAP_WESTERN_STATION3        ; #$1d
    db   $09, $03, MAP_WESTERN_STATION3        ; #$1e
    db   $0a, $04, MAP_WESTERN_STATION3        ; #$1f
    db   $0a, $04, MAP_WESTERN_STATION1        ; #$20
    db   $0b, $05, MAP_WESTERN_STATION3        ; #$21
    db   $0e, $07, MAP_WESTERN_STATION1        ; #$22
    db   $0f, $0b, MAP_WESTERN_STATION1        ; #$23
    db   $0f, $10, MAP_WESTERN_STATION1        ; #$24
    db   $11, $07, MAP_WESTERN_STATION1        ; #$25
    db   $14, $0b, MAP_WESTERN_STATION1        ; #$26
    db   $14, $10, MAP_WESTERN_STATION1        ; #$27
    db   $1b, $0f, MAP_WESTERN_STATION5        ; #$28
    db   $1c, $0e, MAP_WESTERN_STATION5        ; #$29
    db   $1d, $0d, MAP_WESTERN_STATION5        ; #$2a
    db   $1e, $0d, MAP_WESTERN_STATION5        ; #$2b
    db   $1f, $05, MAP_WESTERN_STATION1        ; #$2c
    db   $1f, $0e, MAP_WESTERN_STATION5        ; #$2d
    db   $20, $0f, MAP_WESTERN_STATION5        ; #$2e
    db   $22, $05, MAP_WESTERN_STATION1        ; #$2f
    db   $22, $0a, MAP_WESTERN_STATION1        ; #$30
    db   $22, $10, MAP_WESTERN_STATION1        ; #$31
    db   $29, $27, MAP_WESTERN_STATION6        ; #$32
    db   $2a, $26, MAP_WESTERN_STATION6        ; #$33
    db   $2b, $25, MAP_WESTERN_STATION6        ; #$34
    db   $2c, $24, MAP_WESTERN_STATION6        ; #$35
    db   $2d, $23, MAP_WESTERN_STATION6        ; #$36
    db   $2e, $22, MAP_WESTERN_STATION6        ; #$37
    db   $2f, $21, MAP_WESTERN_STATION6        ; #$38
    db   $30, $20, MAP_WESTERN_STATION6        ; #$39
    db   $33, $2e, MAP_WESTERN_STATION6        ; #$3a
    db   $35, $04, MAP_WESTERN_STATION6        ; #$3b
    db   $37, $05, MAP_WESTERN_STATION6        ; #$3c
    db   $35, $06, MAP_WESTERN_STATION6        ; #$3d
    db   $37, $07, MAP_WESTERN_STATION6        ; #$3e
    db   $35, $08, MAP_WESTERN_STATION6        ; #$3f
    db   $37, $09, MAP_WESTERN_STATION6        ; #$40
    db   $35, $0a, MAP_WESTERN_STATION6        ; #$41
    db   $37, $0b, MAP_WESTERN_STATION6        ; #$42
    db   $51, $12, MAP_WESTERN_STATION6        ; #$43
    db   $52, $11, MAP_WESTERN_STATION6        ; #$44
    db   $53, $10, MAP_WESTERN_STATION6        ; #$45
    db   $54, $0f, MAP_WESTERN_STATION6        ; #$46
    db   $55, $0e, MAP_WESTERN_STATION6        ; #$47
    db   $56, $0d, MAP_WESTERN_STATION6        ; #$48
    db   $57, $0c, MAP_WESTERN_STATION6        ; #$49
    db   $58, $0b, MAP_WESTERN_STATION6        ; #$4a
    db   $00
    db   $00, $ff                              ; unreachable, past the terminator
