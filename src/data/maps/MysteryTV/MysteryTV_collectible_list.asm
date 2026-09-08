; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/MysteryTV/MysteryTV_collectible_list.bin
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

    db   $03, $06, MAP_MYSTERY_TV8             ; #$00
    db   $03, $07, MAP_MYSTERY_TV2             ; #$01
    db   $03, $15, MAP_MYSTERY_TV2             ; #$02
    db   $03, $22, MAP_MYSTERY_TV9             ; #$03
    db   $03, $23, MAP_MYSTERY_TV2             ; #$04
    db   $04, $05, MAP_MYSTERY_TV4             ; #$05
    db   $04, $0c, MAP_MYSTERY_TV3             ; #$06
    db   $04, $0d, MAP_MYSTERY_TV5             ; #$07
    db   $04, $0e, MAP_MYSTERY_TV3             ; #$08
    db   $04, $0f, MAP_MYSTERY_TV1             ; #$09
    db   $04, $2e, MAP_MYSTERY_TV10            ; #$0a
    db   $05, $0d, MAP_MYSTERY_TV3             ; #$0b
    db   $05, $0f, MAP_MYSTERY_TV3             ; #$0c
    db   $05, $10, MAP_MYSTERY_TV1             ; #$0d
    db   $05, $1c, MAP_MYSTERY_TV1             ; #$0e
    db   $06, $06, MAP_MYSTERY_TV8             ; #$0f
    db   $06, $10, MAP_MYSTERY_TV5             ; #$10
    db   $06, $11, MAP_MYSTERY_TV1             ; #$11
    db   $06, $1b, MAP_MYSTERY_TV1             ; #$12
    db   $06, $1b, MAP_MYSTERY_TV6             ; #$13
    db   $07, $02, MAP_MYSTERY_TV4             ; #$14
    db   $07, $05, MAP_MYSTERY_TV2             ; #$15
    db   $07, $12, MAP_MYSTERY_TV2             ; #$16
    db   $07, $12, MAP_MYSTERY_TV1             ; #$17
    db   $07, $19, MAP_MYSTERY_TV2             ; #$18
    db   $07, $20, MAP_MYSTERY_TV2             ; #$19
    db   $08, $13, MAP_MYSTERY_TV1             ; #$1a
    db   $08, $2e, MAP_MYSTERY_TV10            ; #$1b
    db   $09, $01, MAP_MYSTERY_TV4             ; #$1c
    db   $09, $07, MAP_MYSTERY_TV1             ; #$1d
    db   $09, $0f, MAP_MYSTERY_TV5             ; #$1e
    db   $09, $17, MAP_MYSTERY_TV6             ; #$1f
    db   $0a, $01, MAP_MYSTERY_TV4             ; #$20
    db   $0a, $0f, MAP_MYSTERY_TV5             ; #$21
    db   $0a, $17, MAP_MYSTERY_TV6             ; #$22
    db   $0b, $14, MAP_MYSTERY_TV2             ; #$23
    db   $0b, $1f, MAP_MYSTERY_TV2             ; #$24
    db   $0c, $02, MAP_MYSTERY_TV4             ; #$25
    db   $0c, $2e, MAP_MYSTERY_TV10            ; #$26
    db   $0d, $10, MAP_MYSTERY_TV5             ; #$27
    db   $0d, $1b, MAP_MYSTERY_TV6             ; #$28
    db   $0e, $05, MAP_MYSTERY_TV2             ; #$29
    db   $0f, $05, MAP_MYSTERY_TV4             ; #$2a
    db   $0f, $0d, MAP_MYSTERY_TV5             ; #$2b
    db   $0f, $10, MAP_MYSTERY_TV2             ; #$2c
    db   $0f, $1b, MAP_MYSTERY_TV1             ; #$2d
    db   $10, $1c, MAP_MYSTERY_TV1             ; #$2e
    db   $10, $22, MAP_MYSTERY_TV9             ; #$2f
    db   $10, $2e, MAP_MYSTERY_TV10            ; #$30
    db   $12, $29, MAP_MYSTERY_TV1             ; #$31
    db   $13, $10, MAP_MYSTERY_TV3             ; #$32
    db   $13, $1e, MAP_MYSTERY_TV2             ; #$33
    db   $13, $22, MAP_MYSTERY_TV2             ; #$34
    db   $13, $28, MAP_MYSTERY_TV1             ; #$35
    db   $14, $05, MAP_MYSTERY_TV2             ; #$36
    db   $14, $0c, MAP_MYSTERY_TV2             ; #$37
    db   $14, $27, MAP_MYSTERY_TV1             ; #$38
    db   $14, $2e, MAP_MYSTERY_TV10            ; #$39
    db   $15, $26, MAP_MYSTERY_TV1             ; #$3a
    db   $17, $10, MAP_MYSTERY_TV2             ; #$3b
    db   $1a, $05, MAP_MYSTERY_TV2             ; #$3c
    db   $1b, $0b, MAP_MYSTERY_TV2             ; #$3d
    db   $1b, $11, MAP_MYSTERY_TV1             ; #$3e
    db   $1b, $14, MAP_MYSTERY_TV2             ; #$3f
    db   $1c, $10, MAP_MYSTERY_TV1             ; #$40
    db   $1d, $0f, MAP_MYSTERY_TV1             ; #$41
    db   $1d, $24, MAP_MYSTERY_TV1             ; #$42
    db   $1e, $1b, MAP_MYSTERY_TV1             ; #$43
    db   $1f, $05, MAP_MYSTERY_TV2             ; #$44
    db   $1f, $0c, MAP_MYSTERY_TV2             ; #$45
    db   $1f, $16, MAP_MYSTERY_TV2             ; #$46
    db   $1f, $1a, MAP_MYSTERY_TV1             ; #$47
    db   $1f, $20, MAP_MYSTERY_TV2             ; #$48
    db   $1f, $2f, MAP_MYSTERY_TV10            ; #$49
    db   $1f, $30, MAP_MYSTERY_TV10            ; #$4a
    db   $24, $13, MAP_MYSTERY_TV2             ; #$4b
    db   $24, $1c, MAP_MYSTERY_TV2             ; #$4c
    db   $24, $22, MAP_MYSTERY_TV2             ; #$4d
    db   $25, $14, MAP_MYSTERY_TV1             ; #$4e
    db   $26, $0c, MAP_MYSTERY_TV1             ; #$4f
    db   $26, $15, MAP_MYSTERY_TV1             ; #$50
    db   $26, $2f, MAP_MYSTERY_TV10            ; #$51
    db   $26, $30, MAP_MYSTERY_TV10            ; #$52
    db   $27, $0b, MAP_MYSTERY_TV1             ; #$53
    db   $27, $0d, MAP_MYSTERY_TV3             ; #$54
    db   $27, $0f, MAP_MYSTERY_TV3             ; #$55
    db   $27, $16, MAP_MYSTERY_TV1             ; #$56
    db   $28, $0a, MAP_MYSTERY_TV1             ; #$57
    db   $28, $0c, MAP_MYSTERY_TV3             ; #$58
    db   $28, $0e, MAP_MYSTERY_TV3             ; #$59
    db   $28, $17, MAP_MYSTERY_TV1             ; #$5a
    db   $00
    db   $00, $ff                              ; unreachable, past the terminator
