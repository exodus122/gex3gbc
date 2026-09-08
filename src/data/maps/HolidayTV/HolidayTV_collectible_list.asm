; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/HolidayTV/HolidayTV_collectible_list.bin
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
; 92 records.
; ==================================================================

    db   $01, $4b, MAP_HOLIDAY_TV1             ; #$00
    db   $02, $3d, MAP_HOLIDAY_TV1             ; #$01
    db   $02, $4a, MAP_HOLIDAY_TV1             ; #$02
    db   $03, $49, MAP_HOLIDAY_TV1             ; #$03
    db   $04, $48, MAP_HOLIDAY_TV1             ; #$04
    db   $05, $02, MAP_HOLIDAY_TV2             ; #$05
    db   $05, $0d, MAP_HOLIDAY_TV3             ; #$06
    db   $05, $48, MAP_HOLIDAY_TV1             ; #$07
    db   $06, $28, MAP_HOLIDAY_TV1             ; #$08
    db   $06, $49, MAP_HOLIDAY_TV1             ; #$09
    db   $07, $04, MAP_HOLIDAY_TV2             ; #$0a
    db   $07, $0f, MAP_HOLIDAY_TV3             ; #$0b
    db   $07, $28, MAP_HOLIDAY_TV1             ; #$0c
    db   $07, $4a, MAP_HOLIDAY_TV1             ; #$0d
    db   $08, $4b, MAP_HOLIDAY_TV1             ; #$0e
    db   $09, $3a, MAP_HOLIDAY_TV1             ; #$0f
    db   $0a, $13, MAP_HOLIDAY_TV1             ; #$10
    db   $0b, $30, MAP_HOLIDAY_TV1             ; #$11
    db   $0c, $04, MAP_HOLIDAY_TV2             ; #$12
    db   $0c, $0f, MAP_HOLIDAY_TV3             ; #$13
    db   $0c, $21, MAP_HOLIDAY_TV1             ; #$14
    db   $0e, $02, MAP_HOLIDAY_TV2             ; #$15
    db   $0e, $0d, MAP_HOLIDAY_TV3             ; #$16
    db   $11, $10, MAP_HOLIDAY_TV1             ; #$17
    db   $11, $36, MAP_HOLIDAY_TV1             ; #$18
    db   $16, $47, MAP_HOLIDAY_TV1             ; #$19
    db   $16, $3c, MAP_HOLIDAY_TV1             ; #$1a
    db   $17, $2f, MAP_HOLIDAY_TV1             ; #$1b
    db   $19, $0d, MAP_HOLIDAY_TV1             ; #$1c
    db   $19, $19, MAP_HOLIDAY_TV1             ; #$1d
    db   $1b, $42, MAP_HOLIDAY_TV1             ; #$1e
    db   $1c, $26, MAP_HOLIDAY_TV1             ; #$1f
    db   $1c, $29, MAP_HOLIDAY_TV1             ; #$20
    db   $1e, $14, MAP_HOLIDAY_TV1             ; #$21
    db   $22, $4b, MAP_HOLIDAY_TV1             ; #$22
    db   $23, $2b, MAP_HOLIDAY_TV1             ; #$23
    db   $23, $4a, MAP_HOLIDAY_TV1             ; #$24
    db   $24, $49, MAP_HOLIDAY_TV1             ; #$25
    db   $25, $3c, MAP_HOLIDAY_TV1             ; #$26
    db   $25, $48, MAP_HOLIDAY_TV1             ; #$27
    db   $26, $48, MAP_HOLIDAY_TV1             ; #$28
    db   $27, $49, MAP_HOLIDAY_TV1             ; #$29
    db   $28, $4a, MAP_HOLIDAY_TV1             ; #$2a
    db   $29, $4b, MAP_HOLIDAY_TV1             ; #$2b
    db   $33, $08, MAP_HOLIDAY_TV1             ; #$2c
    db   $33, $38, MAP_HOLIDAY_TV1             ; #$2d
    db   $36, $45, MAP_HOLIDAY_TV1             ; #$2e
    db   $38, $31, MAP_HOLIDAY_TV1             ; #$2f
    db   $39, $0e, MAP_HOLIDAY_TV1             ; #$30
    db   $39, $17, MAP_HOLIDAY_TV1             ; #$31
    db   $3d, $3c, MAP_HOLIDAY_TV1             ; #$32
    db   $3f, $10, MAP_HOLIDAY_TV1             ; #$33
    db   $41, $31, MAP_HOLIDAY_TV1             ; #$34
    db   $42, $23, MAP_HOLIDAY_TV1             ; #$35
    db   $45, $13, MAP_HOLIDAY_TV1             ; #$36
    db   $4b, $16, MAP_HOLIDAY_TV1             ; #$37
    db   $4d, $2a, MAP_HOLIDAY_TV1             ; #$38
    db   $51, $33, MAP_HOLIDAY_TV1             ; #$39
    db   $51, $3c, MAP_HOLIDAY_TV1             ; #$3a
    db   $53, $1a, MAP_HOLIDAY_TV1             ; #$3b
    db   $53, $4c, MAP_HOLIDAY_TV1             ; #$3c
    db   $57, $2e, MAP_HOLIDAY_TV1             ; #$3d
    db   $58, $1f, MAP_HOLIDAY_TV1             ; #$3e
    db   $59, $47, MAP_HOLIDAY_TV1             ; #$3f
    db   $5b, $39, MAP_HOLIDAY_TV1             ; #$40
    db   $5d, $20, MAP_HOLIDAY_TV1             ; #$41
    db   $5d, $22, MAP_HOLIDAY_TV1             ; #$42
    db   $5e, $21, MAP_HOLIDAY_TV1             ; #$43
    db   $63, $34, MAP_HOLIDAY_TV1             ; #$44
    db   $6c, $1b, MAP_HOLIDAY_TV1             ; #$45
    db   $6d, $31, MAP_HOLIDAY_TV1             ; #$46
    db   $6f, $18, MAP_HOLIDAY_TV1             ; #$47
    db   $72, $15, MAP_HOLIDAY_TV1             ; #$48
    db   $74, $30, MAP_HOLIDAY_TV1             ; #$49
    db   $75, $12, MAP_HOLIDAY_TV1             ; #$4a
    db   $76, $28, MAP_HOLIDAY_TV1             ; #$4b
    db   $77, $48, MAP_HOLIDAY_TV1             ; #$4c
    db   $78, $39, MAP_HOLIDAY_TV1             ; #$4d
    db   $7b, $0b, MAP_HOLIDAY_TV1             ; #$4e
    db   $7b, $24, MAP_HOLIDAY_TV1             ; #$4f
    db   $80, $20, MAP_HOLIDAY_TV1             ; #$50
    db   $80, $29, MAP_HOLIDAY_TV1             ; #$51
    db   $81, $43, MAP_HOLIDAY_TV1             ; #$52
    db   $84, $2d, MAP_HOLIDAY_TV1             ; #$53
    db   $84, $39, MAP_HOLIDAY_TV1             ; #$54
    db   $85, $1c, MAP_HOLIDAY_TV1             ; #$55
    db   $89, $13, MAP_HOLIDAY_TV1             ; #$56
    db   $8b, $18, MAP_HOLIDAY_TV1             ; #$57
    db   $8c, $26, MAP_HOLIDAY_TV1             ; #$58
    db   $8c, $3d, MAP_HOLIDAY_TV1             ; #$59
    db   $8f, $1c, MAP_HOLIDAY_TV1             ; #$5a
    db   $97, $3b, MAP_HOLIDAY_TV1             ; #$5b
    db   $00
    db   $00, $ff                              ; unreachable, past the terminator
