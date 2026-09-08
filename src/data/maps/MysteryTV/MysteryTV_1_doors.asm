; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/MysteryTV/MysteryTV_1_doors.bin
; by tools/render_map_asm.py, per the door_list layout in tools/map_formats.json.
;
; The .bin is the editable source of truth for the bytes; this file is a
; generated view of it that happens to be what gets assembled. To change the
; data, edit the .bin (a map editor writes it). To change what a field MEANS,
; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits
; are overwritten on the next build.
;
; One map's doors. Each names the spawn id to warp to, so a door here is a pointer
; into its level's spawn list rather than gex2's self-contained from/to block pair.
;
; A door fires when the player is within MAP_DOOR_X_TOLERANCE of its X, and its
; trigger byte - when it is not MAP_DOOR_NO_TRIGGER - gates it on a
; wDCB1_LevelTriggerBuffer flag, which gex2 has no equivalent of at all.
;
; Positions are world pixels. The list ends in MAP_DOOR_LIST_END.
;
; Record layout - 6 bytes, MAP_DOOR_ENTRY_SIZE:
;   +0   db  spawn_id, trigger   - spawn id to warp to, then the trigger that gates it
;   +2   dw  x, y   - door position, world pixels
;
; 8 records.
; ==================================================================

    db   $00, MAP_DOOR_NO_TRIGGER              ; #$00
    dw   $0298, $02b0

    db   $01, MAP_DOOR_NO_TRIGGER              ; #$01
    dw   $0228, $02b0

    db   $02, MAP_DOOR_NO_TRIGGER              ; #$02
    dw   $0268, $01d0

    db   $03, MAP_DOOR_NO_TRIGGER              ; #$03
    dw   $00d8, $0140

    db   $04, MAP_DOOR_NO_TRIGGER              ; #$04
    dw   $01f8, $0080

    db   $05, MAP_DOOR_NO_TRIGGER              ; #$05
    dw   $0028, $0050

    db   $17, MAP_DOOR_NO_TRIGGER              ; #$06
    dw   $0108, $0250

    db   $16, MAP_DOOR_NO_TRIGGER              ; #$07
    dw   $02a8, $01d0

    db   MAP_DOOR_LIST_END
