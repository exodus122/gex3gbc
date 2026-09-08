; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/AnimeChannel/AnimeChannel_collectible_list.bin
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
; 83 records.
; ==================================================================

    db   $02, $0d, MAP_ANIME_CHANNEL3          ; #$00
    db   $02, $11, MAP_ANIME_CHANNEL3          ; #$01
    db   $03, $0e, MAP_ANIME_CHANNEL3          ; #$02
    db   $03, $10, MAP_ANIME_CHANNEL3          ; #$03
    db   $04, $0f, MAP_ANIME_CHANNEL3          ; #$04
    db   $05, $13, MAP_ANIME_CHANNEL7          ; #$05
    db   $06, $13, MAP_ANIME_CHANNEL7          ; #$06
    db   $08, $14, MAP_ANIME_CHANNEL2          ; #$07
    db   $09, $13, MAP_ANIME_CHANNEL2          ; #$08
    db   $0a, $13, MAP_ANIME_CHANNEL2          ; #$09
    db   $0b, $14, MAP_ANIME_CHANNEL2          ; #$0a
    db   $0c, $03, MAP_ANIME_CHANNEL6          ; #$0b
    db   $0d, $02, MAP_ANIME_CHANNEL2          ; #$0c
    db   $0d, $02, MAP_ANIME_CHANNEL6          ; #$0d
    db   $0d, $0c, MAP_ANIME_CHANNEL2          ; #$0e
    db   $0e, $01, MAP_ANIME_CHANNEL6          ; #$0f
    db   $0e, $02, MAP_ANIME_CHANNEL2          ; #$10
    db   $0e, $0b, MAP_ANIME_CHANNEL2          ; #$11
    db   $0f, $02, MAP_ANIME_CHANNEL6          ; #$12
    db   $0f, $0b, MAP_ANIME_CHANNEL2          ; #$13
    db   $10, $03, MAP_ANIME_CHANNEL6          ; #$14
    db   $10, $0c, MAP_ANIME_CHANNEL2          ; #$15
    db   $13, $02, MAP_ANIME_CHANNEL3          ; #$16
    db   $17, $13, MAP_ANIME_CHANNEL7          ; #$17
    db   $18, $13, MAP_ANIME_CHANNEL7          ; #$18
    db   $19, $05, MAP_ANIME_CHANNEL1          ; #$19
    db   $1a, $06, MAP_ANIME_CHANNEL1          ; #$1a
    db   $1b, $04, MAP_ANIME_CHANNEL3          ; #$1b
    db   $1b, $07, MAP_ANIME_CHANNEL1          ; #$1c
    db   $1c, $04, MAP_ANIME_CHANNEL3          ; #$1d
    db   $1e, $09, MAP_ANIME_CHANNEL4          ; #$1e
    db   $1f, $09, MAP_ANIME_CHANNEL4          ; #$1f
    db   $1f, $0c, MAP_ANIME_CHANNEL2          ; #$20
    db   $20, $0b, MAP_ANIME_CHANNEL2          ; #$21
    db   $20, $0b, MAP_ANIME_CHANNEL4          ; #$22
    db   $21, $02, MAP_ANIME_CHANNEL2          ; #$23
    db   $21, $0b, MAP_ANIME_CHANNEL2          ; #$24
    db   $21, $0b, MAP_ANIME_CHANNEL4          ; #$25
    db   $22, $02, MAP_ANIME_CHANNEL2          ; #$26
    db   $22, $07, MAP_ANIME_CHANNEL1          ; #$27
    db   $22, $0c, MAP_ANIME_CHANNEL2          ; #$28
    db   $22, $0c, MAP_ANIME_CHANNEL4          ; #$29
    db   $23, $06, MAP_ANIME_CHANNEL1          ; #$2a
    db   $23, $0c, MAP_ANIME_CHANNEL4          ; #$2b
    db   $23, $14, MAP_ANIME_CHANNEL2          ; #$2c
    db   $24, $02, MAP_ANIME_CHANNEL3          ; #$2d
    db   $24, $05, MAP_ANIME_CHANNEL1          ; #$2e
    db   $24, $0d, MAP_ANIME_CHANNEL4          ; #$2f
    db   $24, $13, MAP_ANIME_CHANNEL2          ; #$30
    db   $25, $0d, MAP_ANIME_CHANNEL4          ; #$31
    db   $25, $13, MAP_ANIME_CHANNEL2          ; #$32
    db   $26, $14, MAP_ANIME_CHANNEL2          ; #$33
    db   $27, $0a, MAP_ANIME_CHANNEL4          ; #$34
    db   $28, $0a, MAP_ANIME_CHANNEL4          ; #$35
    db   $2e, $04, MAP_ANIME_CHANNEL4          ; #$36
    db   $2f, $04, MAP_ANIME_CHANNEL4          ; #$37
    db   $33, $0f, MAP_ANIME_CHANNEL3          ; #$38
    db   $34, $0e, MAP_ANIME_CHANNEL3          ; #$39
    db   $34, $10, MAP_ANIME_CHANNEL3          ; #$3a
    db   $35, $0d, MAP_ANIME_CHANNEL3          ; #$3b
    db   $35, $11, MAP_ANIME_CHANNEL3          ; #$3c
    db   $3a, $0b, MAP_ANIME_CHANNEL9          ; #$3d
    db   $3b, $0b, MAP_ANIME_CHANNEL9          ; #$3e
    db   $3d, $04, MAP_ANIME_CHANNEL4          ; #$3f
    db   $41, $17, MAP_ANIME_CHANNEL4          ; #$40
    db   $43, $01, MAP_ANIME_CHANNEL4          ; #$41
    db   $44, $01, MAP_ANIME_CHANNEL4          ; #$42
    db   $4c, $02, MAP_ANIME_CHANNEL4          ; #$43
    db   $4c, $03, MAP_ANIME_CHANNEL4          ; #$44
    db   $50, $17, MAP_ANIME_CHANNEL4          ; #$45
    db   $54, $02, MAP_ANIME_CHANNEL4          ; #$46
    db   $54, $03, MAP_ANIME_CHANNEL4          ; #$47
    db   $5a, $0b, MAP_ANIME_CHANNEL4          ; #$48
    db   $5b, $0b, MAP_ANIME_CHANNEL4          ; #$49
    db   $8a, $07, MAP_ANIME_CHANNEL5          ; #$4a
    db   $97, $03, MAP_ANIME_CHANNEL5          ; #$4b
    db   $9c, $03, MAP_ANIME_CHANNEL5          ; #$4c
    db   $b3, $03, MAP_ANIME_CHANNEL5          ; #$4d
    db   $bc, $03, MAP_ANIME_CHANNEL5          ; #$4e
    db   $da, $0d, MAP_ANIME_CHANNEL5          ; #$4f
    db   $f2, $0b, MAP_ANIME_CHANNEL5          ; #$50
    db   $f2, $0e, MAP_ANIME_CHANNEL5          ; #$51
    db   $f3, $08, MAP_ANIME_CHANNEL5          ; #$52
    db   $00
    db   $00, $ff                              ; unreachable, past the terminator
