; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/SuperheroShow/SuperheroShow_collectible_list.bin
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
; 53 records.
; ==================================================================

    db   $02, $36, MAP_SUPERHERO_SHOW2         ; #$00
    db   $02, $3b, MAP_SUPERHERO_SHOW2         ; #$01
    db   $07, $0a, MAP_SUPERHERO_SHOW3         ; #$02
    db   $08, $0e, MAP_SUPERHERO_SHOW3         ; #$03
    db   $08, $12, MAP_SUPERHERO_SHOW3         ; #$04
    db   $09, $16, MAP_SUPERHERO_SHOW3         ; #$05
    db   $11, $05, MAP_SUPERHERO_SHOW1         ; #$06
    db   $13, $14, MAP_SUPERHERO_SHOW2         ; #$07
    db   $13, $1e, MAP_SUPERHERO_SHOW2         ; #$08
    db   $13, $28, MAP_SUPERHERO_SHOW2         ; #$09
    db   $13, $32, MAP_SUPERHERO_SHOW2         ; #$0a
    db   $13, $3c, MAP_SUPERHERO_SHOW2         ; #$0b
    db   $18, $19, MAP_SUPERHERO_SHOW2         ; #$0c
    db   $18, $23, MAP_SUPERHERO_SHOW2         ; #$0d
    db   $18, $2d, MAP_SUPERHERO_SHOW2         ; #$0e
    db   $18, $37, MAP_SUPERHERO_SHOW2         ; #$0f
    db   $20, $05, MAP_SUPERHERO_SHOW1         ; #$10
    db   $25, $08, MAP_SUPERHERO_SHOW5         ; #$11
    db   $26, $3c, MAP_SUPERHERO_SHOW2         ; #$12
    db   $27, $19, MAP_SUPERHERO_SHOW1         ; #$13
    db   $29, $11, MAP_SUPERHERO_SHOW5         ; #$14
    db   $29, $16, MAP_SUPERHERO_SHOW5         ; #$15
    db   $2a, $11, MAP_SUPERHERO_SHOW5         ; #$16
    db   $2a, $16, MAP_SUPERHERO_SHOW5         ; #$17
    db   $2c, $19, MAP_SUPERHERO_SHOW1         ; #$18
    db   $2e, $08, MAP_SUPERHERO_SHOW5         ; #$19
    db   $34, $07, MAP_SUPERHERO_SHOW4         ; #$1a
    db   $37, $3f, MAP_SUPERHERO_SHOW2         ; #$1b
    db   $3b, $07, MAP_SUPERHERO_SHOW4         ; #$1c
    db   $3b, $0e, MAP_SUPERHERO_SHOW3         ; #$1d
    db   $3b, $15, MAP_SUPERHERO_SHOW3         ; #$1e
    db   $3e, $0e, MAP_SUPERHERO_SHOW3         ; #$1f
    db   $3e, $15, MAP_SUPERHERO_SHOW3         ; #$20
    db   $3e, $2c, MAP_SUPERHERO_SHOW2         ; #$21
    db   $3f, $0e, MAP_SUPERHERO_SHOW1         ; #$22
    db   $47, $16, MAP_SUPERHERO_SHOW1         ; #$23
    db   $53, $38, MAP_SUPERHERO_SHOW2         ; #$24
    db   $54, $0b, MAP_SUPERHERO_SHOW2         ; #$25
    db   $66, $3a, MAP_SUPERHERO_SHOW2         ; #$26
    db   $68, $11, MAP_SUPERHERO_SHOW1         ; #$27
    db   $68, $1a, MAP_SUPERHERO_SHOW1         ; #$28
    db   $81, $0c, MAP_SUPERHERO_SHOW1         ; #$29
    db   $82, $0c, MAP_SUPERHERO_SHOW1         ; #$2a
    db   $8a, $0c, MAP_SUPERHERO_SHOW1         ; #$2b
    db   $8b, $0c, MAP_SUPERHERO_SHOW1         ; #$2c
    db   $95, $16, MAP_SUPERHERO_SHOW1         ; #$2d
    db   $99, $0c, MAP_SUPERHERO_SHOW1         ; #$2e
    db   $9a, $1a, MAP_SUPERHERO_SHOW1         ; #$2f
    db   $9e, $15, MAP_SUPERHERO_SHOW1         ; #$30
    db   $a1, $0f, MAP_SUPERHERO_SHOW2         ; #$31
    db   $a1, $22, MAP_SUPERHERO_SHOW2         ; #$32
    db   $a3, $0f, MAP_SUPERHERO_SHOW2         ; #$33
    db   $a3, $22, MAP_SUPERHERO_SHOW2         ; #$34
    db   $00
    db   $00, $ff                              ; unreachable, past the terminator
