; ==================================================================
; GENERATED FILE - do not edit by hand.
;
; Rendered from data/maps/AnimeChannel/AnimeChannel_4_doors.bin
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
; 1 record.
; ==================================================================

    db   $03, MAP_DOOR_NO_TRIGGER              ; #$00
    dw   $0030, $0280

    db   MAP_DOOR_LIST_END
