; ==================================================================
; CUTSCENES
;
; The scripted fly-over shown when you pick a mission: a short camera move that
; starts somewhere in the level and pans to the objective, so you know where you
; are going before you are handed control.
;
; There is no camera. Gex himself is teleported to the start of the shot and
; then *walked* along a scripted path, with the normal map window logic
; following him as it always does. The script does this by writing canned d-pad
; values straight into wDC81_Player_EffectiveInputs, so from the map and entity code's
; point of view nothing unusual is happening. wDCA7_Player_UpdateFlag is cleared for
; the duration, which is what stops the real player update from fighting the
; script for control - and also why Gex is invisible during the preview.
;
; call_00_1ea0_Cutscene_LoadAndRun is the only entry point, called once from the
; level init path in call_00_0150_Init. It takes no arguments: the scene is
; chosen entirely by wDB6C_CurrentMapId and wDC5A_MissionNumberSelected, so
; picking a different mission on the menu is what picks a different preview.
;
; ------------------------------------------------------------------
; Scripts
; ------------------------------------------------------------------
; Two levels of lookup. (level id, mission number) gives a script index via
; .data_00_1fc0_CutsceneIndexLookupTable, and CUTSCENE_NONE there means that
; mission has no preview and the routine simply returns - which is the common
; case, since only six of the twelve levels have any at all. The index then
; selects a script from .data_00_1ff0_CutsceneScriptPointerTable.
;
; A script is nine bytes, emitted by the cutscene_script macro:
;
;   +0  db  map id to load                +5  dw  movement command list, or 0
;   +1  dw  Gex's start X                 +7  dw  animation script, or 0
;   +3  dw  Gex's start Y
;
; Because a level is many maps, a preview can be set in a map other than the one
; the player is about to start in - which is why the header carries a map id and
; the routine swaps wDB6C_CurrentMapId out and back around the whole scene.
;
; The animation field is read and then discarded, and every script in the table
; sets it to 0. See the dead branch at .jr_00_1f78.
;
; ------------------------------------------------------------------
; Running one
; ------------------------------------------------------------------
; The routine stashes the current map id and Gex's position, loads the script's
; map and start position, rebuilds the world for it
; (call_03_6c89_LoadMapDataPtrs, call_03_6203_LoadLevelBoundariesFromId,
; call_00_1056_BgMap_LoadFull, call_02_708f_Entities_InitAndSpawnAll), then
; runs two phases:
;
;   1. movement - walk the command list. Each command is 3 bytes emitted by
;      cutscene_move (direction bits, then a 16-bit frame count) and the list
;      ends with CUTSCENE_MOVE_END. The direction byte goes into
;      wDC81_Player_EffectiveInputs and call_00_217f_Cutscene_UpdateMovement does the
;      actual moving.
;   2. hold - CUTSCENE_HOLD_FRAMES of dwell so the objective stays on screen.
;
; Each phase runs its own cut-down game loop rather than the real one: vblank
; wait, the phase's own update, entity update, dirty-region load and the VRAM
; transfer setup. Any button press during either phase jumps straight to the
; restore code, so every preview is skippable.
;
; On the way out Gex's position and the original map id are popped back and
; call_03_6c89_LoadMapDataPtrs re-points the map data at the real starting map.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank00_cutscenes.asm
; ------------------------------------------------------------------
; The two files run on the same machinery - the same fake-input trick, the same
; three-byte movement commands, the same CUTSCENE_HOLD_FRAMES dwell - but gex3
; uses much less of it:
;
;   scene kinds   gex2 plays two: mission previews and the short "the exit tv is
;                 over there" clip shown when an objective is met. gex3 has only
;                 previews, which is why its lookup table is 4 columns wide
;                 rather than 16 and needs no CUTSCENE_SLOT_MISSION_BASE
;   animation     gex2's second phase hands the script's animation block to the
;                 block patch runner to permanently reveal scenery. gex3 has no
;                 block patch system, so the field is vestigial: it is read into
;                 HL, tested, and both sides of the branch fall through to the
;                 hold phase
;   world state   gex2 brackets the scene with Entity_SaveWorldState /
;                 Entity_RestoreWorldState because it plays scenes mid-level with
;                 entities already live. gex3 only ever runs one before the level
;                 starts, so it just re-inits entities and restores the position
;   map id        gex2 levels are a single map, so its script header has no map
;                 id field and no map swap around the scene
;   skipping      gex2 takes a skippable flag in B and stores it in
;                 wD775_Cutscene_Skippable, since its objective clips are not
;                 skippable. gex3 always polls the pad
;   speed ramp    gex2's mover has two dead acceleration branches that each
;                 compute a new speed and then overwrite it with a constant.
;                 gex3 writes the constant directly
;   count         gex2 has 67 scripts across 31 levels; gex3 has 18 across 12
; ==================================================================

call_00_1ea0_Cutscene_LoadAndRun:
; Plays the mission preview for the current level and mission, if there is one.
;
; wDB6C_CurrentMapId picks a row of .data_00_1fc0_CutsceneIndexLookupTable and
; wDC5A_MissionNumberSelected picks the column; CUTSCENE_NONE there means
; nothing to play and the routine returns immediately.
;
; Everything that has to survive the scene is pushed before it starts: the map
; id, then Gex's X and Y as they are read out of the script header. Those three
; are popped back at .jp_00_1f9f, which is also where every skip lands, so
; there is exactly one exit path and it always restores.
;
; The movement phase reads three-byte commands until CUTSCENE_MOVE_END: the
; direction byte goes to wDC81_Player_EffectiveInputs, the 16-bit frame count to
; wDCDE_Cutscene_MoveFramesRemaining, and the inner loop ticks a cut-down game
; loop until the count runs out. wDCE0_Cutscene_MoveSpeed and its sub-pixel
; partner are zeroed once, before the first command, so a scene accelerates from
; a standstill exactly once rather than at every corner.
;
; The hold phase then dwells for CUTSCENE_HOLD_FRAMES with the same cut-down
; loop but no movement update, leaving the objective on screen.
;
; A press of anything on wDAD7_RawInputs aborts either phase
    ld   HL, wDC1E_CurrentLevelID                                     ;; 00:1ea0 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:1ea3 $6e
    ld   H, $00                                        ;; 00:1ea4 $26 $00
    add  HL, HL                                        ;; 00:1ea6 $29
    add  HL, HL                                        ;; 00:1ea7 $29
    ld   DE, .data_00_1fc0_CutsceneIndexLookupTable                                     ;; 00:1ea8 $11 $c0 $1f
    add  HL, DE                                        ;; 00:1eab $19
    ld   A, [wDC5A_MissionNumberSelected]                                    ;; 00:1eac $fa $5a $dc
    ld   E, A                                          ;; 00:1eaf $5f
    ld   D, $00                                        ;; 00:1eb0 $16 $00
    add  HL, DE                                        ;; 00:1eb2 $19
    ld   A, [HL]                                       ;; 00:1eb3 $7e
    cp   A, CUTSCENE_NONE                              ;; 00:1eb4 $fe $ff
    ret  Z                                             ;; 00:1eb6 $c8
    ld   L, A                                          ;; 00:1eb7 $6f
    ld   H, $00                                        ;; 00:1eb8 $26 $00
    add  HL, HL                                        ;; 00:1eba $29
    ld   DE, .data_00_1ff0_CutsceneScriptPointerTable                                     ;; 00:1ebb $11 $f0 $1f
    add  HL, DE                                        ;; 00:1ebe $19
    ld   E, [HL]                                       ;; 00:1ebf $5e
    inc  HL                                            ;; 00:1ec0 $23
    ld   D, [HL]                                       ;; 00:1ec1 $56
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:1ec2 $fa $6c $db
    push AF                                            ;; 00:1ec5 $f5
    ld   A, [DE]                                       ;; 00:1ec6 $1a
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:1ec7 $ea $6c $db
    inc  DE                                            ;; 00:1eca $13
    ld   HL, wD80E_PlayerXPosition                                     ;; 00:1ecb $21 $0e $d8
    ld   C, [HL]                                       ;; 00:1ece $4e
    ld   A, [DE]                                       ;; 00:1ecf $1a
    ld   [HL+], A                                      ;; 00:1ed0 $22
    inc  DE                                            ;; 00:1ed1 $13
    ld   B, [HL]                                       ;; 00:1ed2 $46
    ld   A, [DE]                                       ;; 00:1ed3 $1a
    ld   [HL+], A                                      ;; 00:1ed4 $22
    inc  DE                                            ;; 00:1ed5 $13
    push BC                                            ;; 00:1ed6 $c5
    ld   C, [HL]                                       ;; 00:1ed7 $4e
    ld   A, [DE]                                       ;; 00:1ed8 $1a
    ld   [HL+], A                                      ;; 00:1ed9 $22
    inc  DE                                            ;; 00:1eda $13
    ld   B, [HL]                                       ;; 00:1edb $46
    ld   A, [DE]                                       ;; 00:1edc $1a
    ld   [HL], A                                       ;; 00:1edd $77
    inc  DE                                            ;; 00:1ede $13
    push BC                                            ;; 00:1edf $c5
    push DE                                            ;; 00:1ee0 $d5
    xor  A, A                                          ;; 00:1ee1 $af
    ld   [wDCA7_Player_UpdateFlag], A                                    ;; 00:1ee2 $ea $a7 $dc  ; hand Gex to the script, and stop drawing him
    ld   A, PLAYERACTION_SPAWN                                        ;; 00:1ee5 $3e $00
    ld   [wDC78_PlayerPendingActionId], A                                    ;; 00:1ee7 $ea $78 $dc
    call call_00_04fb_ResetAudioAndVideoState          ;; 00:1eea $cd $fb $04
    farcall call_03_6c89_LoadMapDataPtrs
    farcall call_03_6203_LoadLevelBoundariesFromId
    call call_00_10de_BgMap_UpdateWindowFromPlayerPos                                  ;; 00:1f03 $cd $de $10
    call call_00_1056_BgMap_LoadFull                                  ;; 00:1f06 $cd $56 $10
    farcall call_02_708f_Entities_InitAndSpawnAll
    call call_00_0513_Screen_PresentAndDrawEntities                                  ;; 00:1f14 $cd $13 $05
    pop  HL                                            ;; 00:1f17 $e1
    ld   E, [HL]                                       ;; 00:1f18 $5e
    inc  HL                                            ;; 00:1f19 $23
    ld   D, [HL]                                       ;; 00:1f1a $56
    inc  HL                                            ;; 00:1f1b $23
    ld   A, E                                          ;; 00:1f1c $7b
    or   A, D                                          ;; 00:1f1d $b2
    jr   Z, .jr_00_1f72                                ;; 00:1f1e $28 $52
    push HL                                            ;; 00:1f20 $e5
    ld   L, E                                          ;; 00:1f21 $6b
    ld   H, D                                          ;; 00:1f22 $62
    xor  A, A                                          ;; 00:1f23 $af
    ld   [wDCE0_Cutscene_MoveSpeed], A                                    ;; 00:1f24 $ea $e0 $dc
    ld   [wDCE1_Cutscene_MoveSubPixel], A                                    ;; 00:1f27 $ea $e1 $dc
    ld   A, [HL+]                                      ;; 00:1f2a $2a
.jr_00_1f2b:
    ld   [wDC81_Player_EffectiveInputs], A                                    ;; 00:1f2b $ea $81 $dc
    ld   A, [HL+]                                      ;; 00:1f2e $2a
    ld   [wDCDE_Cutscene_MoveFramesRemaining], A                                    ;; 00:1f2f $ea $de $dc
    ld   A, [HL+]                                      ;; 00:1f32 $2a
    ld   [wDCDE_Cutscene_MoveFramesRemaining+1], A                                    ;; 00:1f33 $ea $df $dc
    push HL                                            ;; 00:1f36 $e5
.jr_00_1f37:
    ld   A, [wDAD7_RawInputs]                                    ;; 00:1f37 $fa $d7 $da
    and  A, A                                          ;; 00:1f3a $a7
    jr   Z, .jr_00_1f42                                ;; 00:1f3b $28 $05
    pop  HL                                            ;; 00:1f3d $e1
    pop  HL                                            ;; 00:1f3e $e1
    jp   .jp_00_1f9f                                   ;; 00:1f3f $c3 $9f $1f
.jr_00_1f42:
    call call_00_0b92_WaitForInterrupt                                  ;; 00:1f42 $cd $92 $0b
    call call_00_217f_Cutscene_UpdateMovement                                  ;; 00:1f45 $cd $7f $21
    farcall call_02_7152_Entities_UpdateAll
    call call_00_11c8_BgMap_LoadDirtyRegions                                  ;; 00:1f53 $cd $c8 $11
    call call_00_35fa_WaitForLineThenSpawnEntity                                  ;; 00:1f56 $cd $fa $35
    call call_00_08f8_StageNextGfxTransfer                                  ;; 00:1f59 $cd $f8 $08
    ld   HL, wDCDE_Cutscene_MoveFramesRemaining                                     ;; 00:1f5c $21 $de $dc
    ld   A, [HL]                                       ;; 00:1f5f $7e
    sub  A, $01                                        ;; 00:1f60 $d6 $01
    ld   [HL+], A                                      ;; 00:1f62 $22
    ld   C, A                                          ;; 00:1f63 $4f
    ld   A, [HL]                                       ;; 00:1f64 $7e
    sbc  A, $00                                        ;; 00:1f65 $de $00
    ld   [HL], A                                       ;; 00:1f67 $77
    or   A, C                                          ;; 00:1f68 $b1
    jr   NZ, .jr_00_1f37                               ;; 00:1f69 $20 $cc
    pop  HL                                            ;; 00:1f6b $e1
    ld   A, [HL+]                                      ;; 00:1f6c $2a
    cp   A, CUTSCENE_MOVE_END                          ;; 00:1f6d $fe $ff
    jr   NZ, .jr_00_1f2b                               ;; 00:1f6f $20 $ba
    pop  HL                                            ;; 00:1f71 $e1
.jr_00_1f72:
    ; the script's animation script pointer. gex2 would hand a non-zero one to its
    ; block patch runner here; with that system gone the branch target is the very
    ; next instruction, so both sides fall through and the pointer is discarded.
    ; Every script in the table stores 0 in this field anyway
    ld   A, [HL+]                                      ;; 00:1f72 $2a
    ld   H, [HL]                                       ;; 00:1f73 $66
    ld   L, A                                          ;; 00:1f74 $6f
    or   A, H                                          ;; 00:1f75 $b4
    jr   Z, .jr_00_1f78                                ;; 00:1f76 $28 $00
.jr_00_1f78:
    ld   A, CUTSCENE_HOLD_FRAMES                       ;; 00:1f78 $3e $b4
.jr_00_1f7a:
    push AF                                            ;; 00:1f7a $f5
    call call_00_0b92_WaitForInterrupt                                  ;; 00:1f7b $cd $92 $0b
    farcall call_02_7152_Entities_UpdateAll
    call call_00_11c8_BgMap_LoadDirtyRegions                                  ;; 00:1f89 $cd $c8 $11
    call call_00_35fa_WaitForLineThenSpawnEntity                                  ;; 00:1f8c $cd $fa $35
    call call_00_08f8_StageNextGfxTransfer                                  ;; 00:1f8f $cd $f8 $08
    ld   A, [wDAD7_RawInputs]                                    ;; 00:1f92 $fa $d7 $da
    and  A, A                                          ;; 00:1f95 $a7
    jr   Z, .jr_00_1f9b                                ;; 00:1f96 $28 $03
    pop  AF                                            ;; 00:1f98 $f1
    jr   .jp_00_1f9f                                   ;; 00:1f99 $18 $04
.jr_00_1f9b:
    pop  AF                                            ;; 00:1f9b $f1
    dec  A                                             ;; 00:1f9c $3d
    jr   NZ, .jr_00_1f7a                               ;; 00:1f9d $20 $db
.jp_00_1f9f:
    ld   A, $01                                        ;; 00:1f9f $3e $01
    ld   [wDCA7_Player_UpdateFlag], A                                    ;; 00:1fa1 $ea $a7 $dc  ; give control back to the player update
    ld   HL, wD810_PlayerYPosition+1                                     ;; 00:1fa4 $21 $11 $d8
    pop  BC                                            ;; 00:1fa7 $c1
    ld   [HL], B                                       ;; 00:1fa8 $70
    dec  HL                                            ;; 00:1fa9 $2b
    ld   [HL], C                                       ;; 00:1faa $71
    dec  HL                                            ;; 00:1fab $2b
    pop  BC                                            ;; 00:1fac $c1
    ld   [HL], B                                       ;; 00:1fad $70
    dec  HL                                            ;; 00:1fae $2b
    ld   [HL], C                                       ;; 00:1faf $71
    pop  AF                                            ;; 00:1fb0 $f1
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:1fb1 $ea $6c $db
    farcall call_03_6c89_LoadMapDataPtrs
    ret                                                ;; 00:1fbf $c9
.data_00_1fc0_CutsceneIndexLookupTable:
; 12 rows of CUTSCENE_SLOTS_PER_LEVEL bytes, indexed by (level id, mission number).
; The value is an index into .data_00_1ff0_CutsceneScriptPointerTable, or
; CUTSCENE_NONE when that mission has no preview - which is every slot of the six
; levels with no entries, and the fourth slot of every level, since no level has
; more than three missions
;  mission: 1    2    3    -
    db   $ff, $ff, $ff, $ff        ; LEVEL_GEX_CAVE
    db   $00, $01, $02, $ff        ; LEVEL_HOLIDAY_TV
    db   $03, $04, $05, $ff        ; LEVEL_MYSTERY_TV
    db   $06, $07, $08, $ff        ; LEVEL_TUT_TV
    db   $09, $0a, $0b, $ff        ; LEVEL_WESTERN_STATION
    db   $0c, $0d, $0e, $ff        ; LEVEL_ANIME_CHANNEL
    db   $0f, $10, $11, $ff        ; LEVEL_SUPERHERO_SHOW
    db   $ff, $ff, $ff, $ff        ; LEVEL_GEXTREME_SPORTS
    db   $ff, $ff, $ff, $ff        ; LEVEL_MARSUPIAL_MADNESS
    db   $ff, $ff, $ff, $ff        ; LEVEL_WW_GEX_WRESTLING
    db   $ff, $ff, $ff, $ff        ; LEVEL_LIZARD_OF_OZ
    db   $ff, $ff, $ff, $ff        ; LEVEL_CHANNEL_Z
.data_00_1ff0_CutsceneScriptPointerTable:
; 18 scripts, one per mission that has a preview, followed by the scripts
; themselves. A script header and its movement list sit next to each other, so each
; script is one contiguous run and the whole region is written in address order.
;
; The trailing comment on each line is which mission refers to it, read back out of
; .data_00_1fc0_CutsceneIndexLookupTable
    dw   .script_00     ; $00  holiday tv, mission 1
    dw   .script_01     ; $01  holiday tv, mission 2
    dw   .script_02     ; $02  holiday tv, mission 3
    dw   .script_03     ; $03  mystery tv, mission 1
    dw   .script_04     ; $04  mystery tv, mission 2
    dw   .script_05     ; $05  mystery tv, mission 3
    dw   .script_06     ; $06  tut tv, mission 1
    dw   .script_07     ; $07  tut tv, mission 2
    dw   .script_08     ; $08  tut tv, mission 3
    dw   .script_09     ; $09  western station, mission 1
    dw   .script_0A     ; $0a  western station, mission 2
    dw   .script_0B     ; $0b  western station, mission 3
    dw   .script_0C     ; $0c  anime channel, mission 1
    dw   .script_0D     ; $0d  anime channel, mission 2
    dw   .script_0E     ; $0e  anime channel, mission 3
    dw   .script_0F     ; $0f  superhero show, mission 1
    dw   .script_10     ; $10  superhero show, mission 2
    dw   .script_11     ; $11  superhero show, mission 3
; ------------------------------------------------------------------
; $00   holiday tv, mission 1
; ------------------------------------------------------------------
.script_00:
    cutscene_script MAP_HOLIDAY_TV1, $0780, $02f0, .script_00_move, 0

.script_00_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $00d0
    cutscene_move PADF_UP,                    $01e0
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $01   holiday tv, mission 2
; ------------------------------------------------------------------
.script_01:
    cutscene_script MAP_HOLIDAY_TV1, $0650, $0260, .script_01_move, 0

.script_01_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT | PADF_DOWN,     $01a0
    cutscene_move PADF_RIGHT,                 $0170
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $02   holiday tv, mission 3
; ------------------------------------------------------------------
.script_02:
    cutscene_script MAP_HOLIDAY_TV4, $0130, $0060, .script_02_move, 0

.script_02_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_LEFT,                  $00e0
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $03   mystery tv, mission 1
; ------------------------------------------------------------------
.script_03:
    cutscene_script MAP_MYSTERY_TV2, $00c0, $0240, .script_03_move, 0

.script_03_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT | PADF_UP,       $0170
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $04   mystery tv, mission 2
; ------------------------------------------------------------------
.script_04:
    cutscene_script MAP_MYSTERY_TV1, $00dc, $02a0, .script_04_move, 0

.script_04_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_UP,                    $01d8
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $05   mystery tv, mission 3
; ------------------------------------------------------------------
.script_05:
    cutscene_script MAP_MYSTERY_TV8, $0050, $0070, .script_05_move, 0

.script_05_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $06   tut tv, mission 1
; ------------------------------------------------------------------
.script_06:
    cutscene_script MAP_TUT_TV7, $0190, $0160, .script_06_move, 0

.script_06_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $00f0
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $07   tut tv, mission 2
; ------------------------------------------------------------------
.script_07:
    cutscene_script MAP_TUT_TV1, $00e0, $0110, .script_07_move, 0

.script_07_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $0058
    cutscene_move PADF_UP,                    $00a8
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $08   tut tv, mission 3
; ------------------------------------------------------------------
.script_08:
    cutscene_script MAP_TUT_TV3, $0050, $0140, .script_08_move, 0

.script_08_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $02d0
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $09   western station, mission 1
; ------------------------------------------------------------------
.script_09:
    cutscene_script MAP_WESTERN_STATION5, $0278, $00e8, .script_09_move, 0

.script_09_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $01d8
    cutscene_move PADF_RIGHT | PADF_UP,       $0068
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $0a   western station, mission 2
; ------------------------------------------------------------------
.script_0A:
    cutscene_script MAP_WESTERN_STATION2, $0050, $0128, .script_0A_move, 0

.script_0A_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $00e0
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $0b   western station, mission 3
; ------------------------------------------------------------------
.script_0B:
    cutscene_script MAP_WESTERN_STATION6, $06f8, $0250, .script_0B_move, 0

.script_0B_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $0088
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $0c   anime channel, mission 1
; ------------------------------------------------------------------
.script_0C:
    cutscene_script MAP_ANIME_CHANNEL9, $0170, $0110, .script_0C_move, 0

.script_0C_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_UP,                    $0070
    cutscene_move PADF_RIGHT | PADF_UP,       $0050
    cutscene_move PADF_RIGHT,                 $0120
    cutscene_move PADF_RIGHT | PADF_DOWN,     $0050
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $0d   anime channel, mission 2
; ------------------------------------------------------------------
.script_0D:
    cutscene_script MAP_ANIME_CHANNEL4, $05a8, $0080, .script_0D_move, 0

.script_0D_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $0e   anime channel, mission 3
; ------------------------------------------------------------------
.script_0E:
    cutscene_script MAP_ANIME_CHANNEL2, $0180, $01a0, .script_0E_move, 0

.script_0E_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_UP,                    $0130
    cutscene_move PADF_LEFT,                  $0110
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $0f   superhero show, mission 1
; ------------------------------------------------------------------
.script_0F:
    cutscene_script MAP_SUPERHERO_SHOW6, $0050, $0060, .script_0F_move, 0

.script_0F_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $10   superhero show, mission 2
; ------------------------------------------------------------------
.script_10:
    cutscene_script MAP_SUPERHERO_SHOW3, $0350, $0040, .script_10_move, 0

.script_10_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_DOWN,                  $0100
    cutscene_move PADF_LEFT,                  $01d0
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

; ------------------------------------------------------------------
; $11   superhero show, mission 3
; ------------------------------------------------------------------
.script_11:
    cutscene_script MAP_SUPERHERO_SHOW4, $0050, $0180, .script_11_move, 0

.script_11_move:
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move PADF_RIGHT,                 $0220
    cutscene_move PADF_RIGHT | PADF_UP,       $0040
    cutscene_move 0,                          $003c   ; stand still
    cutscene_move_end

call_00_217f_Cutscene_UpdateMovement:
; Moves Gex one step along the scripted path, once per frame.
;
; The speed is kept in 1/16ths of a pixel. wDCE0_Cutscene_MoveSpeed is set to
; CUTSCENE_MOVE_SPEED_MAX while any direction bit is held and 0 when the command
; is a pause, then added into the low nibble of wDCE1_Cutscene_MoveSubPixel each
; frame; whatever carries into the high nibble is the whole-pixel step. At
; CUTSCENE_MOVE_SPEED_MAX that works out to exactly one pixel per frame.
;
; The direction bits in wDC81_Player_EffectiveInputs then decide which axis it goes
; on, and nothing stops two of them being set - which is how a script pans
; diagonally with PADF_RIGHT | PADF_UP or PADF_RIGHT | PADF_DOWN
    ld   A, [wDC81_Player_EffectiveInputs]                                    ;; 00:217f $fa $81 $dc
    and  A, A                                          ;; 00:2182 $a7
    jr   NZ, .jr_00_218c                               ;; 00:2183 $20 $07
    ld   HL, wDCE0_Cutscene_MoveSpeed                                     ;; 00:2185 $21 $e0 $dc
    ld   [HL], $00                                     ;; 00:2188 $36 $00
    jr   .jr_00_2191                                   ;; 00:218a $18 $05
.jr_00_218c:
    ld   HL, wDCE0_Cutscene_MoveSpeed                                     ;; 00:218c $21 $e0 $dc
    ld   [HL], CUTSCENE_MOVE_SPEED_MAX                 ;; 00:218f $36 $10
.jr_00_2191:
    ld   HL, wDCE0_Cutscene_MoveSpeed                                     ;; 00:2191 $21 $e0 $dc
    ld   A, [HL+]                                      ;; 00:2194 $2a                ; speed, then the sub-pixel accumulator
    ld   C, A                                          ;; 00:2195 $4f
    ld   A, [HL]                                       ;; 00:2196 $7e
    and  A, $0f                                        ;; 00:2197 $e6 $0f
    add  A, C                                          ;; 00:2199 $81
    ld   [HL], A                                       ;; 00:219a $77
    swap A                                             ;; 00:219b $cb $37
    and  A, $0f                                        ;; 00:219d $e6 $0f                ; carry out of the low nibble...
    ld   C, A                                          ;; 00:219f $4f                ; ...is this frame's whole-pixel step
    ld   HL, wDC81_Player_EffectiveInputs                                     ;; 00:21a0 $21 $81 $dc
    bit  PADF_RIGHT_BIT, [HL]                                       ;; 00:21a3 $cb $66
    jr   Z, .jr_00_21b6                                ;; 00:21a5 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21a7 $fa $0e $d8
    add  A, C                                          ;; 00:21aa $81
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21ab $ea $0e $d8
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:21ae $fa $0f $d8
    adc  A, $00                                        ;; 00:21b1 $ce $00
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 00:21b3 $ea $0f $d8
.jr_00_21b6:
    bit  PADF_LEFT_BIT, [HL]                                       ;; 00:21b6 $cb $6e
    jr   Z, .jr_00_21c9                                ;; 00:21b8 $28 $0f
    ld   A, [wD80E_PlayerXPosition]                                    ;; 00:21ba $fa $0e $d8
    sub  A, C                                          ;; 00:21bd $91
    ld   [wD80E_PlayerXPosition], A                                    ;; 00:21be $ea $0e $d8
    ld   A, [wD80E_PlayerXPosition+1]                                    ;; 00:21c1 $fa $0f $d8
    sbc  A, $00                                        ;; 00:21c4 $de $00
    ld   [wD80E_PlayerXPosition+1], A                                    ;; 00:21c6 $ea $0f $d8
.jr_00_21c9:
    bit  PADF_DOWN_BIT, [HL]                                       ;; 00:21c9 $cb $7e
    jr   Z, .jr_00_21dc                                ;; 00:21cb $28 $0f
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21cd $fa $10 $d8
    add  A, C                                          ;; 00:21d0 $81
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21d1 $ea $10 $d8
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:21d4 $fa $11 $d8
    adc  A, $00                                        ;; 00:21d7 $ce $00
    ld   [wD810_PlayerYPosition+1], A                                    ;; 00:21d9 $ea $11 $d8
.jr_00_21dc:
    bit  PADF_UP_BIT, [HL]                                       ;; 00:21dc $cb $76
    ret  Z                                             ;; 00:21de $c8
    ld   A, [wD810_PlayerYPosition]                                    ;; 00:21df $fa $10 $d8
    sub  A, C                                          ;; 00:21e2 $91
    ld   [wD810_PlayerYPosition], A                                    ;; 00:21e3 $ea $10 $d8
    ld   A, [wD810_PlayerYPosition+1]                                    ;; 00:21e6 $fa $11 $d8
    sbc  A, $00                                        ;; 00:21e9 $de $00
    ld   [wD810_PlayerYPosition+1], A                                    ;; 00:21eb $ea $11 $d8
    ret                                                ;; 00:21ee $c9
