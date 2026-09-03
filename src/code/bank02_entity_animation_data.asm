; ==================================================================
; ENTITY AND PLAYER ANIMATION DATA
;
; One block per (entity, action) pair - the SECOND word of every row in the
; per-entity tables in bank02_entity_pointer_tables.asm, and of every row of Gex's
; own table. Nothing else in the ROM points into this file, and it is one
; contiguous run of 314 blocks from $739B to $7EF2 with no padding between them and
; no terminator after any of them.
;
; A block is a five-byte header followed by a list of sprite ids:
;
;   +0  the ROM bank this action's tiles live in, copied to
;       ENTITY_FIELD_SPRITE_BANK. Entity artwork is spread over banks $07-$1F, one
;       or two pages each, and call_00_08f8_StageNextGfxTransfer switches to this
;       bank when it streams a page in - so an entity's graphics can move between
;       banks as its action changes. $00 means "no tiles of my own": all 55 of
;       Gex's blocks (his tiles come through GFX_XFER_PLAYER_GFX instead) and
;       data_02_75c2, the shared Destroy block, which draws nothing
;   +1  ENTITY_FIELD_PENDING_ACTION. PENDING_ACTION_PRESENT plus an action id in
;       the low seven bits: when the animation runs out, go there. 103 of the 314
;       blocks set it
;   +2  ENTITY_FIELD_ACTION_STATE_FLAGS. Written verbatim, not OR'd into anything
;   +3  ticks per sprite, into both SPRITE_FRAME_COUNTER_MAX and the live
;       SPRITE_FRAME_COUNTER. SPRITE_FRAME_COUNTER_HOLD ($FF) is special - see
;       FROZEN BLOCKS below
;   +4  number of sprites in the list
;   +5  the sprite ids, one per frame. Byte +5 is also written straight into
;       ENTITY_FIELD_SPRITE_ID, so the entity is drawn correctly on its first frame
;       before the ticker has run once
;
; call_02_72ac_Entity_SetAction unpacks these in a different order from the one
; they are stored in - the bank is written last, through an `xor $1b` on the field
; pointer - and zeroes SPRITE_COUNTER on the way past, so an action always restarts
; at its first frame even when it is re-entered.
;
; THE FLAGS BYTE is a small vocabulary. ACTION_STATE_IS_FIRST_FRAME and
; ACTION_STATE_ID_CHANGED are set in all 314 blocks - they are the "prime this
; entity" bits, not a choice - so what actually varies is the rest, and only nine
; values occur:
;
;   $12   56: nothing else - the animation loops back to frame 0
;   $1a  193: LOOP_LAST_FRAME - play once, hold the last pose
;   $1b   13: the same, plus NO_COLLISION - intangible for this action only
;   $32    8: $12 plus UNK20
;   $33    2: $32 plus NO_COLLISION
;   $3a   37: $1a plus UNK20
;   $3b    1: $3a plus NO_COLLISION
;   $5a    1: $1a plus bit 6 - data_02_75c2 alone, and nothing reads bit 6
;   $9a    3: $1a plus UNK80 - ENTITY_UNK0E, _UNK0F and _UNK10 alone
;
; ACTION_STATE_UNK20 sends the entity's tiles to VRAM bank 1 at $8400 instead of
; bank 0, and 48 blocks across nine entity types use it - Evil Santa, Rock Hard,
; Rez, the Mad Bomber, the big silver robot, the two cactuses, the coffin and the
; bonus-stage timer. They are the biggest sprites in the game, and the second VRAM
; bank is where the room for them is.
;
; ACTION_STATE_NO_COLLISION is a gex3-only idea: it makes the entity intangible for
; the length of ONE ACTION without touching its collision type, and it is what the
; intro actions of Rez, the ghost knight and the two remotes use.
;
; HOW A BLOCK ENDS is declared here rather than decided by the ticker, and
; call_02_724d_Entity_TickAction reads the three cases in this order:
;
;   PENDING_ACTION_PRESENT        hand over to the action in the low bits. Slot 0
;                                 goes through Player_RequestAction, everyone else
;                                 through Entity_SetAction
;   ACTION_STATE_LOOP_LAST_FRAME  restart at SPRITE_COUNTER_MAX - 1, so the
;                                 animation plays once and sits on its final pose
;   neither                       restart at frame 0
;
; In all three cases ACTION_STATE_ANIM_ENDED is pulsed for one frame, and that
; pulse is what every call_00_2a5d_Entity_CheckAnimationEnded in
; bank02_entity_actions.asm is watching. A one-frame block at a real tick rate is
; therefore not a still image but a metronome: it re-pulses ANIM_ENDED every +3
; ticks, and 40 of the 145 one-frame blocks here are used that way.
;
; A FROZEN BLOCK IS THE OPPOSITE. 105 blocks set +3 to SPRITE_FRAME_COUNTER_HOLD.
; Entity_TickAction clears ANIM_ENDED and then returns on that test, before it can
; reach any of the wrap handling - so a frozen block holds its first sprite forever
; AND never pulses ANIM_ENDED at all, and Entity_CheckAnimationEnded can never
; succeed on one. Nothing outside the ticker writes SPRITE_COUNTER, so any sprite
; after the first in a frozen block is unreachable. No frozen block in this file
; carries a pending action, which is the consistency check for that: a hand-over
; declared on a frozen block could never fire, and none is.
;
; 42 of the 113 entity types with a table are frozen in EVERY action they have -
; the platforms, the switches, the goal-counter pips, the five flies, the blocks
; and most of the projectiles. Most of those have only one action; twelve have
; more than one and are frozen in all of them, which is the interesting set: the
; two mechs, the three switches, the ice sculpture, the water tower's tank and
; stand, the breakable block, the raft, the disappearing floor and the tv button.
; They still change pose when their action changes, because SetAction reloads byte
; +5 into SPRITE_ID; what they never do is animate within an action.
;
; BLOCKS ARE SHARED FREELY. 82 of them are named by more than one (entity, action)
; row, covering 237 rows between them, and 19 are shared across different entity
; types rather than between actions of one type. data_02_75c2 is the extreme case:
; 39 entity types point at it, because it is the single frozen frame every
; call_02_583c_EntityAction_Destroy row uses. Editing one block therefore changes
; every entity that points at it.
;
; THE ODDITIES, all of them visible in the byte counts:
;
;   two blocks are unreachable - $7A8B and $7EEB. Neither has a label in the ROM,
;   because each sits immediately behind a live block and the disassembler ran the
;   two together; the _Orphan names below exist only so they can be referred to.
;   Both are complete, well-formed blocks holding the next sprite id after their
;   neighbour's, so they read as poses cut late rather than as stray bytes
;
;   four blocks list more sprite ids than they declare - $74BD (three declared,
;   six listed) and $7763, $79B8 and $7E53 (five declared, six listed). All four
;   are walk or drift cycles, and the shape of the edit is the same in each: the
;   count was lowered and the ids were left where they were
;
;   data_02_7665 declares one frame and carries eleven ids on purpose. It is the
;   hub tv remote, and call_02_5af8_EntityAction_TVRemote_CheckUnlockRequirement
;   indexes those eleven by hand and writes SPRITE_ID itself
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank02_entity_action_data.asm
; ------------------------------------------------------------------
; The two files do the same job and are laid out the same way - one run of blocks
; in entity-table order, Gex first, no code, every block reached only through the
; second word of an action row. The differences are all in the header:
;
;   header size   gex2's is four bytes, gex3's is five. gex3 adds the ROM bank at
;                 +0 and splits gex2's single flags byte in two: the pending action
;                 gets its own byte at +1 and the state flags sit at +2. gex2 packs
;                 both into byte +0 - ACTION_STATE_HAS_PENDING, ACTION_STATE_ADVANCE_ON_END
;                 and a five-bit action id in one byte - and keeps the drawing bits
;                 in a separate SPRITE_FLAGS byte at +1
;   terminator    every gex2 block ends with a $00 that no code reads. gex3 has
;                 none at all; the blocks butt straight up against each other,
;                 which is why the two orphans above have no label
;   who hands on  the big one. In gex2 exactly eleven blocks have a nonzero byte
;                 +0 and all eleven are Gex's - no enemy ever hands over, they all
;                 change action from their own handler. In gex3, 103 blocks carry a
;                 pending action and 88 of those belong to entities. That is what
;                 makes gex3's "pure animation" rows possible: a table row whose
;                 function is call_02_582e_EntityAction_None and whose whole
;                 behaviour is this file's PENDING_ACTION byte. Long scripted
;                 sequences - a chest opening, the ghost knight vanishing and
;                 reappearing, Evil Santa's throw - are entirely table-driven here
;                 and would need code in gex2
;   where the     gex2 decides per block, with SPRITE_FLAG_STREAMS_OWN_GFX: set,
;   tiles are     the frame id is the high byte of a ROM address and writing it
;                 queues that page; clear, it is a frame number for
;                 bank03_sprite_frame_data.asm. gex3 always names the bank at +0
;                 and always streams, and the shape comes from
;                 data_03_58d2_EntitySpriteDescriptors - so gex3 has no equivalent
;                 of gex2's five drawing paths encoded in this file
;   requesting    a gex2 block change raises the graphics transfer immediately,
;   the tiles     from Entity_NotifyActionChanged. gex3 sets ACTION_STATE_ID_CHANGED
;                 and lets call_00_08f8_StageNextGfxTransfer poll for it - see the
;                 same note in bank02_update_entities.asm
;   VRAM banks    ACTION_STATE_UNK20 has no gex2 counterpart. gex2 has one entity
;                 tile window; gex3 can send an action's page to VRAM bank 1
;   intangible    ACTION_STATE_NO_COLLISION is gex3-only as well
;   size          232 blocks against 314, and most of the difference is Gex: 31
;                 blocks for gex2's 32 actions against 55 for gex3's 60, each of
;                 which is claimed twice for the side-scrolling and top-down halves
;                 of his table
;   frozen        87 of 232 in gex2, 105 of 314 in gex3 - the same third of the
;                 file either way, and the counts of entity types frozen in every
;                 action they have come out close too: 59 of gex2's 143 against 42
;                 of gex3's 113, or 13 against 12 counting only the types that have
;                 more than one action to be frozen in
;   leftovers     both files carry cut animation. gex2 has three unreachable blocks
;                 and two over-long zombie walks; gex3 has two unreachable blocks
;                 and four over-long cycles
; ==================================================================

; ------------------------------------------------------------------
; GEX
;
; Gex's own animation, and the only blocks in the file whose PENDING_ACTION byte
; names a PLAYERACTION_* rather than a bare number. Every one of these is claimed
; TWICE by data_02_4000_EntityActionJumpTable's first table - once at action N for
; a side-scrolling map and once at N + PLAYERACTION_TOPDOWN ($3C) for a top-down
; one - so only the side-scrolling id is named below.
;
; Read down the ones with a pending action and the shape of Gex's state machine is
; visible as data: spawn, the idle animation, the crouch and the fly-eating all
; hand back to PLAYERACTION_IDLE, and death hands to the death warp
; ------------------------------------------------------------------

data_02_739b:                                               ; ENTITY_GEX action $00 PLAYERACTION_SPAWN
    db   $00, PENDING_ACTION_PRESENT | $01, $1a, $08, $0b                   ; 11 frames at 8 ticks, then PLAYERACTION_IDLE
    db   $a8, $a7, $a6, $a5, $a4, $a3, $a2, $a1
    db   $a0, $9f, $9e

data_02_73ab:                                               ; ENTITY_GEX action $01 PLAYERACTION_IDLE
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $44

data_02_73b1:                                               ; ENTITY_GEX action $02 PLAYERACTION_IDLE_ANIMATION
    db   $00, PENDING_ACTION_PRESENT | $01, $1a, $04, $0f                   ; 15 frames at 4 ticks, then PLAYERACTION_IDLE
    db   $44, $45, $46, $47, $47, $47, $47, $47
    db   $47, $47, $47, $47, $46, $45, $44

data_02_73c5:                                               ; ENTITY_GEX action $03 PLAYERACTION_WALK
    db   $00, $00, $12, $04, $10                                            ; 16 frames at 4 ticks, looping
    db   $01, $02, $03, $04, $05, $06, $07, $08
    db   $09, $0a, $0b, $0c, $0d, $0e, $0f, $10

; ENTITY_GEX action $04 PLAYERACTION_START_CROUCH
; ENTITY_GEX action $07 PLAYERACTION_UNK7
data_02_73da:
    db   $00, PENDING_ACTION_PRESENT | $05, $1a, $02, $07                   ; 7 frames at 2 ticks, then PLAYERACTION_CROUCH_LOOK_DOWN
    db   $20, $21, $22, $23, $24, $25, $26

data_02_73e6:                                               ; ENTITY_GEX action $05 PLAYERACTION_CROUCH_LOOK_DOWN
    db   $00, $00, $12, $06, $04                                            ; 4 frames at 6 ticks, looping
    db   $27, $28, $29, $28

data_02_73ef:                                               ; ENTITY_GEX action $06 PLAYERACTION_NONE_0
    db   $00, PENDING_ACTION_PRESENT | $01, $1a, $02, $07                   ; 7 frames at 2 ticks, then PLAYERACTION_IDLE
    db   $26, $25, $24, $23, $22, $21, $20

data_02_73fb:                                               ; ENTITY_GEX action $08 PLAYERACTION_EAT_FLY
    db   $00, PENDING_ACTION_PRESENT | $01, $1a, $14, $01                   ; one frame, 20 ticks, then PLAYERACTION_IDLE
    db   $9d

data_02_7401:                                               ; ENTITY_GEX action $09 PLAYERACTION_TAKE_DAMAGE
    db   $00, $00, $1a, $06, $02                                            ; 2 frames at 6 ticks, then holds the last
    db   $84, $85

data_02_7408:                                               ; ENTITY_GEX action $0a PLAYERACTION_DEATH
    db   $00, PENDING_ACTION_PRESENT | $0b, $1a, $06, $04                   ; 4 frames at 6 ticks, then PLAYERACTION_DEATH_SET_UP_WARP
    db   $84, $85, $86, $87

data_02_7411:                                               ; ENTITY_GEX action $0b PLAYERACTION_DEATH_SET_UP_WARP
    db   $00, $00, $1a, $0c, $0c                                            ; 12 frames at 12 ticks, then holds the last
    db   $88, $89, $88, $89, $88, $89, $88, $89
    db   $88, $89, $88, $89

data_02_7422:                                               ; ENTITY_GEX action $0c PLAYERACTION_STAND_ON_TV_BUTTON
    db   $00, PENDING_ACTION_PRESENT | $0d, $1a, $3c, $01                   ; one frame, 60 ticks, then PLAYERACTION_ENTER_TV
    db   $aa

data_02_7428:                                               ; ENTITY_GEX action $0d PLAYERACTION_ENTER_TV
    db   $00, $00, $1a, $06, $08                                            ; 8 frames at 6 ticks, then holds the last
    db   $aa, $ab, $ac, $ad, $ae, $af, $b0, $b1

data_02_7435:                                               ; ENTITY_GEX action $0e PLAYERACTION_JUMP
    db   $00, $00, $1a, $04, $08                                            ; 8 frames at 4 ticks, then holds the last
    db   $11, $12, $13, $14, $15, $16, $17, $18

data_02_7442:                                               ; ENTITY_GEX action $0f PLAYERACTION_DOUBLE_JUMP
    db   $00, $00, $1a, $04, $07                                            ; 7 frames at 4 ticks, then holds the last
    db   $19, $1a, $1b, $1c, $1d, $1e, $1f

data_02_744e:                                               ; ENTITY_GEX action $10 PLAYERACTION_TAIL_SPIN
    db   $00, $00, $1a, $03, $08                                            ; 8 frames at 3 ticks, then holds the last
    db   $6b, $6c, $6d, $6e, $6f, $70, $71, $72

; ENTITY_GEX action $11 PLAYERACTION_FALL
; ENTITY_GEX action $1a PLAYERACTION_DEATH_IN_PIT_ALT
data_02_745b:
    db   $00, $00, $1a, $04, $0d                                            ; 13 frames at 4 ticks, then holds the last
    db   $37, $38, $39, $3a, $3b, $3c, $3d, $3e
    db   $3f, $40, $41, $42, $43

data_02_746d:                                               ; ENTITY_GEX action $12 PLAYERACTION_LAND_FROM_FALL
    db   $00, PENDING_ACTION_PRESENT | $01, $1a, $3c, $01                   ; one frame, 60 ticks, then PLAYERACTION_IDLE
    db   $b2

; ENTITY_GEX action $13 PLAYERACTION_UNK19
; ENTITY_GEX action $14 PLAYERACTION_ENTER_IDLE
data_02_7473:
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $a9

data_02_7479:                                               ; ENTITY_GEX action $15 PLAYERACTION_NONE_1
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $9e

data_02_747f:                                               ; ENTITY_GEX action $16 PLAYERACTION_NONE_2
    db   $00, $00, $1a, $08, $0b                                            ; 11 frames at 8 ticks, then holds the last
    db   $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5
    db   $a6, $a7, $a8

data_02_748f:                                               ; ENTITY_GEX action $17 PLAYERACTION_NONE_3
    db   $00, $00, $1a, $08, $0b                                            ; 11 frames at 8 ticks, then holds the last
    db   $a8, $a7, $a6, $a5, $a4, $a3, $a2, $a1
    db   $a0, $9f, $9e

data_02_749f:                                               ; ENTITY_GEX action $18 PLAYERACTION_NONE_4
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $9e

data_02_74a5:                                               ; ENTITY_GEX action $19 PLAYERACTION_WATER_SWIMMING
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $48

data_02_74ab:                                               ; ENTITY_GEX action $1b PLAYERACTION_DEATH_IN_PIT
    db   $00, $00, $1a, $04, $0d                                            ; 13 frames at 4 ticks, then holds the last
    db   $37, $38, $39, $3a, $3b, $3c, $3d, $3e
    db   $3f, $40, $41, $42, $43

; declares 3 frames but six ids follow - an animation trimmed by editing the count
data_02_74bd:                                               ; ENTITY_GEX action $1c PLAYERACTION_NONE_5
    db   $00, $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    db   $8a, $8b, $8c, $8c, $8c, $8c

data_02_74c8:                                               ; ENTITY_GEX action $1d PLAYERACTION_BLOWN_UPWARDS
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $43

data_02_74ce:                                               ; ENTITY_GEX action $1e PLAYERACTION_RIDING_ELEVATOR
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $44

data_02_74d4:                                               ; ENTITY_GEX action $1f PLAYERACTION_WATER_TAIL_SPIN
    db   $00, $00, $1a, $04, $08                                            ; 8 frames at 4 ticks, then holds the last
    db   $bf, $c0, $c1, $c2, $c3, $c4, $c5, $c6

data_02_74e1:                                               ; ENTITY_GEX action $20 PLAYERACTION_WATER_TREADING
    db   $00, $00, $12, $08, $07                                            ; 7 frames at 8 ticks, looping
    db   $b3, $b4, $b5, $b6, $b7, $b8, $b9

data_02_74ed:                                               ; ENTITY_GEX action $21 PLAYERACTION_WATER_DIVING
    db   $00, PENDING_ACTION_PRESENT | $19, $1a, $06, $05                   ; 5 frames at 6 ticks, then PLAYERACTION_WATER_SWIMMING
    db   $ba, $bb, $bc, $bd, $be

data_02_74f7:                                               ; ENTITY_GEX action $22 PLAYERACTION_CLIMBING
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $73

data_02_74fd:                                               ; ENTITY_GEX action $23 PLAYERACTION_SNOWBOARDING_SPAWN
    db   $00, PENDING_ACTION_PRESENT | $24, $1a, $08, $0b                   ; 11 frames at 8 ticks, then PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    db   $3d, $3c, $3b, $3a, $39, $38, $37, $36
    db   $35, $34, $33

data_02_750d:                                               ; ENTITY_GEX action $24 PLAYERACTION_SNOWBOARDING_STAND_OR_WALK
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $05

data_02_7513:                                               ; ENTITY_GEX action $29 PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $46

data_02_7519:                                               ; ENTITY_GEX action $2a PLAYERACTION_SNOWBOARDING_DIE
    db   $00, PENDING_ACTION_PRESENT | $2b, $1a, $06, $04                   ; 4 frames at 6 ticks, then PLAYERACTION_SNOWBOARDING_DIE_WARP
    db   $4d, $4e, $4f, $50

data_02_7522:                                               ; ENTITY_GEX action $2b PLAYERACTION_SNOWBOARDING_DIE_WARP
    db   $00, $00, $1a, $90, $01                                            ; one frame, 144 ticks, then holds the last
    db   $50

data_02_7528:                                               ; ENTITY_GEX action $2c PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON
    db   $00, PENDING_ACTION_PRESENT | $2d, $1a, $3c, $01                   ; one frame, 60 ticks, then PLAYERACTION_SNOWBOARDING_ENTER_TV
    db   $3e

data_02_752e:                                               ; ENTITY_GEX action $2d PLAYERACTION_SNOWBOARDING_ENTER_TV
    db   $00, $00, $1a, $06, $08                                            ; 8 frames at 6 ticks, then holds the last
    db   $3e, $3f, $40, $41, $42, $43, $44, $45

data_02_753b:                                               ; ENTITY_GEX action $25 PLAYERACTION_SNOWBOARDING_JUMP
    db   $00, $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    db   $47, $48, $49

data_02_7543:                                               ; ENTITY_GEX action $26 PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP
    db   $00, $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    db   $4a, $4b, $4c

data_02_754b:                                               ; ENTITY_GEX action $27 PLAYERACTION_SNOWBOARDING_TAIL_SPIN
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $0b

; ENTITY_GEX action $28 PLAYERACTION_SNOWBOARDING_FALL
; ENTITY_GEX action $2e PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT
data_02_7551:
    db   $00, $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    db   $47, $48, $49

data_02_7559:                                               ; ENTITY_GEX action $2f PLAYERACTION_KANGAROO_SPAWN
    db   $00, PENDING_ACTION_PRESENT | $30, $1a, $08, $0b                   ; 11 frames at 8 ticks, then PLAYERACTION_KANGAROO_IDLE
    db   $0b, $0a, $09, $08, $07, $06, $05, $04
    db   $03, $02, $01

data_02_7569:                                               ; ENTITY_GEX action $36 PLAYERACTION_KANGAROO_TAKE_DAMAGE
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $13

data_02_756f:                                               ; ENTITY_GEX action $37 PLAYERACTION_KANGAROO_DEATH
    db   $00, PENDING_ACTION_PRESENT | $38, $1a, $08, $02                   ; 2 frames at 8 ticks, then PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    db   $28, $29

data_02_7576:                                               ; ENTITY_GEX action $38 PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP
    db   $00, $00, $1a, $90, $01                                            ; one frame, 144 ticks, then holds the last
    db   $28

data_02_757c:                                               ; ENTITY_GEX action $39 PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON
    db   $00, PENDING_ACTION_PRESENT | $3a, $1a, $3c, $01                   ; one frame, 60 ticks, then PLAYERACTION_KANGAROO_ENTER_TV
    db   $0c

data_02_7582:                                               ; ENTITY_GEX action $3a PLAYERACTION_KANGAROO_ENTER_TV
    db   $00, $00, $1a, $06, $07                                            ; 7 frames at 6 ticks, then holds the last
    db   $0c, $0d, $0e, $0f, $10, $11, $12

data_02_758e:                                               ; ENTITY_GEX action $30 PLAYERACTION_KANGAROO_IDLE
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $14

data_02_7594:                                               ; ENTITY_GEX action $31 PLAYERACTION_KANGAROO_HOPPING
    db   $00, $00, $1a, $04, $06                                            ; 6 frames at 4 ticks, then holds the last
    db   $14, $15, $16, $17, $18, $19

data_02_759f:                                               ; ENTITY_GEX action $32 PLAYERACTION_KANGAROO_START_JUMP
    db   $00, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $1c

data_02_75a5:                                               ; ENTITY_GEX action $33 PLAYERACTION_KANGAROO_JUMP
    db   $00, $00, $1a, $04, $04                                            ; 4 frames at 4 ticks, then holds the last
    db   $1c, $1d, $1e, $1f

data_02_75ae:                                               ; ENTITY_GEX action $34 PLAYERACTION_KANGAROO_TAIL_SPIN
    db   $00, $00, $1a, $03, $08                                            ; 8 frames at 3 ticks, then holds the last
    db   $20, $21, $22, $23, $24, $25, $26, $27

; ENTITY_GEX action $35 PLAYERACTION_KANGAROO_FALL
; ENTITY_GEX action $3b PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT
data_02_75bb:
    db   $00, $00, $1a, $06, $02                                            ; 2 frames at 6 ticks, then holds the last
    db   $1a, $1b


; ------------------------------------------------------------------
; COLLECTIBLES, FLY TVS AND THE GEX CAVE HUB
;
; The entity ids below ENTITY_HOLIDAY_TV_ICE_SCULPTURE. data_02_75c2 is here, and
; it is the most-shared block in either game - the single frozen frame every
; call_02_583c_EntityAction_Destroy row points at
; ------------------------------------------------------------------

; Shared by 39 action rows across 39 entity types
data_02_75c2:
    db   $00, $00, $5a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $00

data_02_75c8:                                               ; ENTITY_BONUS_COIN action $00
    db   BANK(image_bonus_coin_unk0e_and_2_more_00a_4aa0), $00, $12, $06, $04                                            ; 4 frames at 6 ticks, looping
    entity_frames image_bonus_coin_unk0e_and_2_more_00a_4aa0, 2, 0, 1, 2, 3

data_02_75d1:                                               ; ENTITY_FLY_COIN_SPAWN action $00
    db   BANK(image_fly_coin_spawn_00a_4ba0), $00, $12, $06, $06                                            ; 6 frames at 6 ticks, looping
    entity_frames image_fly_coin_spawn_00a_4ba0, 2, 0, 1, 2, 3, 4, 5

data_02_75dc:                                               ; ENTITY_PAW_COIN action $00
    db   BANK(image_paw_coin_00a_4d20), $00, $12, $0a, $08                                            ; 8 frames at 10 ticks, looping
    entity_frames image_paw_coin_00a_4d20, 2, 0, 1, 2, 3, 4, 5, 6, 7

; ENTITY_FLY_1 action $00
; ENTITY_FLY_2 action $00
; ENTITY_FLY_3 action $00
; ENTITY_FLY_4 action $00
; ENTITY_FLY_5 action $00
data_02_75e9:
    db   BANK(image_fly_1_fly_2_and_3_more_00a_4000), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_fly_1_fly_2_and_3_more_00a_4000, 1, 0

; Shared by 10 action rows across 5 entity types
data_02_75ef:
    db   BANK(image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000, 6, 1

; ENTITY_GREEN_FLY_TV action $01
; ENTITY_PURPLE_FLY_TV action $01
; ENTITY_UNK_FLY_TV_3 action $01
; ENTITY_BLUE_FLY_TV action $01
; ENTITY_UNK_FLY_TV_5 action $01
data_02_75f5:
    db   BANK(image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000), PENDING_ACTION_PRESENT | $02, $1a, $03, $11                   ; 17 frames at 3 ticks, then action $02
    entity_frames image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000, 6, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1

; ENTITY_GREEN_FLY_TV action $03
; ENTITY_PURPLE_FLY_TV action $03
; ENTITY_UNK_FLY_TV_3 action $03
; ENTITY_BLUE_FLY_TV action $03
; ENTITY_UNK_FLY_TV_5 action $03
data_02_760b:
    db   BANK(image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000, 6, 0

; ENTITY_GREEN_FLY_TV action $04
; ENTITY_PURPLE_FLY_TV action $04
; ENTITY_UNK_FLY_TV_3 action $04
; ENTITY_BLUE_FLY_TV action $04
; ENTITY_UNK_FLY_TV_5 action $04
data_02_7611:
    db   BANK(image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000), PENDING_ACTION_PRESENT | $00, $1a, $03, $11                   ; 17 frames at 3 ticks, then action $00
    entity_frames image_green_fly_tv_purple_fly_tv_and_3_more_00d_4000, 6, 1, 8, 7, 6, 5, 4, 3, 2, 1, 8, 7, 6, 5, 4, 3, 2, 1

data_02_7627:                                               ; ENTITY_UNK0E action $00
    db   BANK(image_bonus_coin_unk0e_and_2_more_00a_4aa0), $00, $9a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_bonus_coin_unk0e_and_2_more_00a_4aa0, 1, 0

data_02_762d:                                               ; ENTITY_UNK0F action $00
    db   BANK(image_bonus_coin_unk0e_and_2_more_00a_4aa0), $00, $9a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_bonus_coin_unk0e_and_2_more_00a_4aa0, 1, 0

data_02_7633:                                               ; ENTITY_UNK10 action $00
    db   BANK(image_bonus_coin_unk0e_and_2_more_00a_4aa0), $00, $9a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_bonus_coin_unk0e_and_2_more_00a_4aa0, 1, 0

; ENTITY_TV_BUTTON action $00
; ENTITY_TV_BUTTON action $01
; ENTITY_TV_BUTTON action $03
data_02_7639:
    db   BANK(image_tv_button_00a_4f20), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tv_button_00a_4f20, 2, 0

data_02_763f:                                               ; ENTITY_TV_BUTTON action $02
    db   BANK(image_tv_button_00a_4f20), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tv_button_00a_4f20, 2, 0

data_02_7645:                                               ; ENTITY_TV_REMOTE action $00
    db   BANK(image_tv_remote_freestanding_remote_00d_5200), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tv_remote_freestanding_remote_00d_5200, 6, 0

; ENTITY_TV_REMOTE action $01
; ENTITY_FREESTANDING_REMOTE action $01
data_02_764b:
    db   BANK(image_tv_remote_freestanding_remote_00d_5200), $00, $12, $0a, $08                                            ; 8 frames at 10 ticks, looping
    entity_frames image_tv_remote_freestanding_remote_00d_5200, 6, 0, 1, 2, 3, 4, 5, 6, 7

data_02_7658:                                               ; ENTITY_TV_REMOTE action $02
    db   BANK(image_tv_remote_00d_5800), $00, $12, $0a, $08                                            ; 8 frames at 10 ticks, looping
    entity_frames image_tv_remote_00d_5800, 6, 0, 1, 2, 3, 4, 5, 6, 7

; declares one frame; the eleven ids are indexed by hand in TVRemote_CheckUnlockRequirement
data_02_7665:                                               ; ENTITY_TV_REMOTE action $03
    db   BANK(image_tv_remote_00d_7000), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tv_remote_00d_7000, 6, 0
    db   $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a                       ; spare frames past the declared count

data_02_7675:                                               ; ENTITY_GOAL_COUNTER_1 action $00
    db   BANK(image_goal_counter_1_00a_4120), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_1_00a_4120, 1, 0

data_02_767b:                                               ; ENTITY_GOAL_COUNTER_2 action $00
    db   BANK(image_goal_counter_2_00a_4140), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_2_00a_4140, 1, 0

data_02_7681:                                               ; ENTITY_GOAL_COUNTER_3 action $00
    db   BANK(image_goal_counter_3_00a_4160), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_3_00a_4160, 1, 0

data_02_7687:                                               ; ENTITY_GOAL_COUNTER_4 action $00
    db   BANK(image_goal_counter_4_00a_4180), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_4_00a_4180, 1, 0

data_02_768d:                                               ; ENTITY_GOAL_COUNTER_5 action $00
    db   BANK(image_goal_counter_5_00a_41a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_5_00a_41a0, 1, 0

data_02_7693:                                               ; ENTITY_GOAL_COUNTER_6 action $00
    db   BANK(image_goal_counter_6_00a_41c0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_6_00a_41c0, 1, 0

data_02_7699:                                               ; ENTITY_GOAL_COUNTER_7 action $00
    db   BANK(image_goal_counter_7_00a_41e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_goal_counter_7_00a_41e0, 1, 0

data_02_769f:                                               ; ENTITY_BONUS_STAGE_TIMER action $00
; The bank byte stays a literal. It names bank $03, whose $4000 is
; call_03_46e0_BgCollision_Update - so this entity's one frame resolves onto CODE,
; not artwork, and there is no label to write BANK() of. Nothing spawns the timer,
; so nothing ever performs the transfer
    db   $03, $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $00

data_02_76a5:                                               ; ENTITY_FREESTANDING_REMOTE action $00
    db   BANK(image_tv_remote_freestanding_remote_00d_5200), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tv_remote_freestanding_remote_00d_5200, 6, 0


; ------------------------------------------------------------------
; HOLIDAY TV
; ------------------------------------------------------------------

data_02_76ab:                                               ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE action $00
    db   BANK(image_holiday_tv_ice_sculpture_00d_5e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_ice_sculpture_00d_5e00, 6, 0

data_02_76b1:                                               ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE action $01
    db   BANK(image_holiday_tv_ice_sculpture_00d_5e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_ice_sculpture_00d_5e00, 6, 1

data_02_76b7:                                               ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE action $02
    db   BANK(image_holiday_tv_ice_sculpture_00d_5e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_ice_sculpture_00d_5e00, 6, 2

data_02_76bd:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $00
    db   BANK(image_holiday_tv_evil_santa_009_4000), $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $00

data_02_76c3:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $01
    db   BANK(image_holiday_tv_evil_santa_009_4000), $00, $3a, $08, $02                                            ; 2 frames at 8 ticks, then holds the last
    db   $00, $01

data_02_76ca:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $02
    db   BANK(image_holiday_tv_evil_santa_009_4000), $00, $3a, $04, $0a                                            ; 10 frames at 4 ticks, then holds the last
    db   $08, $08, $08, $08, $04, $04, $04, $04
    db   $05, $06

data_02_76d9:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $03
    db   BANK(image_holiday_tv_evil_santa_009_4000), PENDING_ACTION_PRESENT | $04, $3a, $0c, $01                   ; one frame, 12 ticks, then action $04
    db   $07

data_02_76df:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $04
    db   BANK(image_holiday_tv_evil_santa_009_4000), $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $08

data_02_76e5:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $05
    db   BANK(image_holiday_tv_evil_santa_009_4000), PENDING_ACTION_PRESENT | $01, $3a, $06, $08                   ; 8 frames at 6 ticks, then action $01
    db   $02, $03, $03, $03, $03, $03, $03, $02

data_02_76f2:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA action $06
    db   BANK(image_holiday_tv_evil_santa_009_4000), $00, $3a, $05, $0a                                            ; 10 frames at 5 ticks, then holds the last
    db   $09, $0a, $0b, $0c, $0d, $0e, $0f, $10
    db   $11, $12

; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $00
; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $01
data_02_7701:
    db   BANK(image_holiday_tv_evil_santa_projectile_00a_4fa0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_evil_santa_projectile_00a_4fa0, 2, 0

data_02_7707:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $02
    db   BANK(image_holiday_tv_evil_santa_projectile_00a_4fa0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_evil_santa_projectile_00a_4fa0, 2, 1

data_02_770d:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $03
    db   BANK(image_holiday_tv_evil_santa_projectile_00a_4fa0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_evil_santa_projectile_00a_4fa0, 2, 2

data_02_7713:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $04
    db   BANK(image_holiday_tv_evil_santa_projectile_00a_4fa0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_evil_santa_projectile_00a_4fa0, 2, 3

data_02_7719:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $05
    db   BANK(image_holiday_tv_evil_santa_projectile_00a_4fa0), $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    entity_frames image_holiday_tv_evil_santa_projectile_00a_4fa0, 2, 4, 5, 6

data_02_7721:                                               ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE action $06
    db   BANK(image_holiday_tv_evil_santa_projectile_00a_4fa0), $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    entity_frames image_holiday_tv_evil_santa_projectile_00a_4fa0, 2, 7, 5, 6

data_02_7729:                                               ; ENTITY_HOLIDAY_TV_SKATING_ELF action $00
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), PENDING_ACTION_PRESENT | $01, $1a, $05, $0a                   ; 10 frames at 5 ticks, then action $01
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 1, 2, 3, 4, 5, 5, 5, 5, 5, 5

data_02_7738:                                               ; ENTITY_HOLIDAY_TV_SKATING_ELF action $01
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), PENDING_ACTION_PRESENT | $00, $1a, $05, $0a                   ; 10 frames at 5 ticks, then action $00
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0

data_02_7747:                                               ; ENTITY_HOLIDAY_TV_SKATING_ELF action $02
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), $00, $12, $05, $0a                                            ; 10 frames at 5 ticks, looping
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

data_02_7756:                                               ; ENTITY_HOLIDAY_TV_SKATING_ELF action $03
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 0

data_02_775c:                                               ; ENTITY_HOLIDAY_TV_SKATING_ELF action $04
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), $00, $12, $05, $02                                            ; 2 frames at 5 ticks, looping
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 10, 11

; declares 5 frames but six ids follow - trimmed by editing the count
data_02_7763:                                               ; ENTITY_HOLIDAY_TV_PENGUIN action $00
    db   BANK(image_holiday_tv_penguin_00a_55a0), $00, $12, $05, $05                                            ; 5 frames at 5 ticks, looping
    entity_frames image_holiday_tv_penguin_00a_55a0, 2, 0, 1, 2, 3, 4
    db   $31                       ; spare frames past the declared count

data_02_776e:                                               ; ENTITY_HOLIDAY_TV_PENGUIN action $01
    db   BANK(image_holiday_tv_penguin_00a_55a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_holiday_tv_penguin_00a_55a0, 2, 4

data_02_7774:                                               ; ENTITY_HOLIDAY_TV_PENGUIN action $02
    db   BANK(image_holiday_tv_penguin_00a_5720), PENDING_ACTION_PRESENT | $00, $1a, $05, $02                   ; 2 frames at 5 ticks, then action $00
    entity_frames image_holiday_tv_penguin_00a_5720, 2, 0, 1


; ------------------------------------------------------------------
; MYSTERY TV
; ------------------------------------------------------------------

data_02_777b:                                               ; ENTITY_MYSTERY_TV_REZLING action $00
    db   BANK(image_mystery_tv_rezling_00c_4000), $00, $12, $08, $08                                            ; 8 frames at 8 ticks, looping
    entity_frames image_mystery_tv_rezling_00c_4000, 8, 0, 1, 2, 3, 4, 5, 6, 7

data_02_7788:                                               ; ENTITY_MYSTERY_TV_REZLING action $01
    db   BANK(image_mystery_tv_rezling_00c_4000), PENDING_ACTION_PRESENT | $02, $12, $04, $03                   ; 3 frames at 4 ticks, then action $02
    entity_frames image_mystery_tv_rezling_00c_4000, 8, 8, 9, 10

data_02_7790:                                               ; ENTITY_MYSTERY_TV_REZLING action $02
    db   BANK(image_mystery_tv_rezling_00c_4000), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_mystery_tv_rezling_00c_4000, 8, 11

data_02_7796:                                               ; ENTITY_MYSTERY_TV_REZLING action $03
    db   BANK(image_mystery_tv_rezling_00c_4000), PENDING_ACTION_PRESENT | $04, $1a, $04, $01                   ; one frame, 4 ticks, then action $04
    entity_frames image_mystery_tv_rezling_00c_4000, 8, 12

data_02_779c:                                               ; ENTITY_MYSTERY_TV_REZLING action $04
    db   BANK(image_mystery_tv_rezling_00c_4000), PENDING_ACTION_PRESENT | $05, $1a, $04, $0c                   ; 12 frames at 4 ticks, then action $05
    entity_frames image_mystery_tv_rezling_00c_4000, 8, 12, 13, 14, 15, 16, 17, 15, 16, 17, 15, 16, 17

data_02_77ad:                                               ; ENTITY_MYSTERY_TV_BLOOD_COOLER action $00
    db   BANK(image_mystery_tv_blood_cooler_00d_46c0), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_mystery_tv_blood_cooler_00d_46c0, 6, 0, 1, 2, 3

data_02_77b6:                                               ; ENTITY_MYSTERY_TV_BLOOD_COOLER action $01
    db   BANK(image_mystery_tv_blood_cooler_00d_46c0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_mystery_tv_blood_cooler_00d_46c0, 6, 4

data_02_77bc:                                               ; ENTITY_MYSTERY_TV_FISH action $00
    db   BANK(image_mystery_tv_fish_00a_51a0), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_mystery_tv_fish_00a_51a0, 2, 0, 2, 1, 2

data_02_77c5:                                               ; ENTITY_MYSTERY_TV_FISH action $01
    db   BANK(image_mystery_tv_fish_00a_51a0), PENDING_ACTION_PRESENT | $00, $1a, $1e, $01                   ; one frame, 30 ticks, then action $00
    entity_frames image_mystery_tv_fish_00a_51a0, 2, 3

data_02_77cb:                                               ; ENTITY_MYSTERY_TV_MAGIC_SWORD action $00
    db   BANK(image_mystery_tv_magic_sword_00f_4000), PENDING_ACTION_PRESENT | $01, $1a, $06, $08                   ; 8 frames at 6 ticks, then action $01
    entity_frames image_mystery_tv_magic_sword_00f_4000, 4, 1, 2, 3, 4, 5, 6, 7, 8

data_02_77d8:                                               ; ENTITY_MYSTERY_TV_MAGIC_SWORD action $01
    db   BANK(image_mystery_tv_magic_sword_00f_4000), PENDING_ACTION_PRESENT | $00, $1a, $78, $01                   ; one frame, 120 ticks, then action $00
    entity_frames image_mystery_tv_magic_sword_00f_4000, 4, 0

data_02_77de:                                               ; ENTITY_MYSTERY_TV_SAFARI_SAM action $00
    db   BANK(image_mystery_tv_safari_sam_00c_5200), $00, $12, $08, $0d                                            ; 13 frames at 8 ticks, looping
    entity_frames image_mystery_tv_safari_sam_00c_5200, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

data_02_77f0:                                               ; ENTITY_MYSTERY_TV_SAFARI_SAM action $01
    db   BANK(image_mystery_tv_safari_sam_00c_5200), PENDING_ACTION_PRESENT | $02, $1a, $08, $06                   ; 6 frames at 8 ticks, then action $02
    entity_frames image_mystery_tv_safari_sam_00c_5200, 8, 13, 14, 14, 14, 14, 14

data_02_77fb:                                               ; ENTITY_MYSTERY_TV_SAFARI_SAM action $02
    db   BANK(image_mystery_tv_safari_sam_00c_5200), PENDING_ACTION_PRESENT | $00, $1a, $08, $06                   ; 6 frames at 8 ticks, then action $00
    entity_frames image_mystery_tv_safari_sam_00c_5200, 8, 15, 15, 15, 15, 14, 13

data_02_7806:                                               ; ENTITY_MYSTERY_TV_SAFARI_SAM action $03
    db   BANK(image_mystery_tv_safari_sam_00c_5200), PENDING_ACTION_PRESENT | $04, $1a, $3c, $01                   ; one frame, 60 ticks, then action $04
    entity_frames image_mystery_tv_safari_sam_00c_5200, 8, 16

data_02_780c:                                               ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE action $00
    db   BANK(image_mystery_tv_safari_sam_projectile_00a_4020), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_mystery_tv_safari_sam_projectile_00a_4020, 1, 0

data_02_7812:                                               ; ENTITY_MYSTERY_TV_GHOST_KNIGHT action $00
    db   BANK(image_mystery_tv_ghost_knight_00d_4a80), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_mystery_tv_ghost_knight_00d_4a80, 6, 0

data_02_7818:                                               ; ENTITY_MYSTERY_TV_GHOST_KNIGHT action $01
    db   BANK(image_mystery_tv_ghost_knight_00d_4a80), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_mystery_tv_ghost_knight_00d_4a80, 6, 0, 1, 2, 1

data_02_7821:                                               ; ENTITY_MYSTERY_TV_GHOST_KNIGHT action $02
    db   BANK(image_mystery_tv_ghost_knight_00d_4a80), PENDING_ACTION_PRESENT | $03, $1a, $08, $04                   ; 4 frames at 8 ticks, then action $03
    entity_frames image_mystery_tv_ghost_knight_00d_4a80, 6, 0
    entity_frames image_mystery_tv_ghost_knight_00d_4fc0, 6, 0, 1, 2

data_02_782a:                                               ; ENTITY_MYSTERY_TV_GHOST_KNIGHT action $03
    db   BANK(image_mystery_tv_ghost_knight_00d_4fc0), PENDING_ACTION_PRESENT | $04, $1b, $78, $01                   ; one frame, 120 ticks, then action $04
    entity_frames image_mystery_tv_ghost_knight_00d_4fc0, 6, 2

data_02_7830:                                               ; ENTITY_MYSTERY_TV_GHOST_KNIGHT action $04
    db   BANK(image_mystery_tv_ghost_knight_00d_4fc0), PENDING_ACTION_PRESENT | $01, $1a, $08, $03                   ; 3 frames at 8 ticks, then action $01
    entity_frames image_mystery_tv_ghost_knight_00d_4fc0, 6, 2, 1, 0

data_02_7838:                                               ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE action $00
    db   BANK(image_mystery_tv_ghost_knight_projectile_00a_4780), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_mystery_tv_ghost_knight_projectile_00a_4780, 1, 0


; ------------------------------------------------------------------
; TUT TV
; ------------------------------------------------------------------

data_02_783e:                                               ; ENTITY_TUT_TV_HAND action $00
    db   BANK(image_tut_tv_hand_00a_52a0), $00, $12, $08, $06                                            ; 6 frames at 8 ticks, looping
    entity_frames image_tut_tv_hand_00a_52a0, 2, 0, 1, 2, 3, 4, 5

data_02_7849:                                               ; ENTITY_TUT_TV_HAND action $01
    db   BANK(image_tut_tv_hand_00a_5460), $00, $1a, $04, $04                                            ; 4 frames at 4 ticks, then holds the last
    entity_frames image_tut_tv_hand_00a_5460, 2, 0, 1, 2, 3

data_02_7852:                                               ; ENTITY_TUT_TV_HAND action $02
    db   BANK(image_tut_tv_hand_00a_5460), $00, $1a, $04, $04                                            ; 4 frames at 4 ticks, then holds the last
    entity_frames image_tut_tv_hand_00a_5460, 2, 3, 3, 2, 1

data_02_785b:                                               ; ENTITY_TUT_TV_HAND action $03
    db   BANK(image_tut_tv_hand_00a_5460), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_hand_00a_5460, 2, 1

data_02_7861:                                               ; ENTITY_TUT_TV_HAND action $04
    db   BANK(image_tut_tv_hand_00a_5460), PENDING_ACTION_PRESENT | $00, $1a, $28, $01                   ; one frame, 40 ticks, then action $00
    entity_frames image_tut_tv_hand_00a_5460, 2, 1

data_02_7867:                                               ; ENTITY_TUT_TV_HAND action $05
    db   BANK(image_tut_tv_hand_00a_5460), PENDING_ACTION_PRESENT | $00, $12, $3c, $08                   ; 8 frames at 60 ticks, then action $00
    entity_frames image_tut_tv_hand_00a_5460, 2, 4, 4, 4, 4, 4, 4, 4, 4

data_02_7874:                                               ; ENTITY_TUT_TV_LOST_ARK action $00
    db   BANK(image_tut_tv_lost_ark_00b_4000), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_lost_ark_00b_4000, 8, 0

data_02_787a:                                               ; ENTITY_TUT_TV_LOST_ARK action $01
    db   BANK(image_tut_tv_lost_ark_00b_4300), PENDING_ACTION_PRESENT | $02, $1a, $06, $04                   ; 4 frames at 6 ticks, then action $02
    entity_frames image_tut_tv_lost_ark_00b_4300, 8, 0, 1, 2, 3

data_02_7883:                                               ; ENTITY_TUT_TV_LOST_ARK action $02
    db   BANK(image_tut_tv_lost_ark_00b_4300), PENDING_ACTION_PRESENT | $03, $1b, $0f, $01                   ; one frame, 15 ticks, then action $03
    entity_frames image_tut_tv_lost_ark_00b_4300, 8, 4

data_02_7889:                                               ; ENTITY_TUT_TV_LOST_ARK action $03
    db   BANK(image_tut_tv_lost_ark_00b_4300), PENDING_ACTION_PRESENT | $04, $1a, $0a, $07                   ; 7 frames at 10 ticks, then action $04
    entity_frames image_tut_tv_lost_ark_00b_4300, 8, 4, 5, 6, 7, 8, 9, 10

data_02_7895:                                               ; ENTITY_TUT_TV_LOST_ARK action $04
    db   BANK(image_tut_tv_lost_ark_00b_4000), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_lost_ark_00b_4000, 8, 0

; ENTITY_TUT_TV_RISING_PLATFORM action $00
; ENTITY_TUT_TV_SIDEWAYS_PLATFORM action $00
data_02_789b:
    db   BANK(image_tut_tv_rising_platform_tut_tv_sideways_platform_00a_79e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_rising_platform_tut_tv_sideways_platform_00a_79e0, 3, 0

data_02_78a1:                                               ; ENTITY_TUT_TV_BEE action $00
    db   BANK(image_tut_tv_bee_00d_6040), $00, $12, $03, $02                                            ; 2 frames at 3 ticks, looping
    entity_frames image_tut_tv_bee_00d_6040, 6, 0, 1

data_02_78a8:                                               ; ENTITY_TUT_TV_BEE action $01
    db   BANK(image_tut_tv_bee_00d_6040), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_bee_00d_6040, 6, 2

data_02_78ae:                                               ; ENTITY_TUT_TV_BEE action $02
    db   BANK(image_tut_tv_bee_00d_6040), PENDING_ACTION_PRESENT | $03, $1a, $14, $01                   ; one frame, 20 ticks, then action $03
    entity_frames image_tut_tv_bee_00d_6040, 6, 3

data_02_78b4:                                               ; ENTITY_TUT_TV_BEE action $03
    db   BANK(image_tut_tv_bee_00d_6040), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_bee_00d_6040, 6, 4

; ENTITY_TUT_TV_RAFT action $00
; ENTITY_TUT_TV_RAFT action $01
; ENTITY_TUT_TV_RAFT action $02
data_02_78ba:
    db   BANK(image_tut_tv_raft_00f_4480), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_raft_00f_4480, 4, 0

; ENTITY_TUT_TV_SNAKE_FACING_RIGHT action $00
; ENTITY_TUT_TV_SNAKE_FACING_LEFT action $00
data_02_78c0:
    db   BANK(image_tut_tv_snake_facing_right_and_1_more_00c_6f00), $00, $1a, $1e, $01                                            ; one frame, 30 ticks, then holds the last
    entity_frames image_tut_tv_snake_facing_right_and_1_more_00c_6f00, 8, 0

; ENTITY_TUT_TV_SNAKE_FACING_RIGHT action $01
; ENTITY_TUT_TV_SNAKE_FACING_LEFT action $01
data_02_78c6:
    db   BANK(image_tut_tv_snake_facing_right_and_1_more_00c_6f00), $00, $1a, $08, $03                                            ; 3 frames at 8 ticks, then holds the last
    entity_frames image_tut_tv_snake_facing_right_and_1_more_00c_6f00, 8, 1, 2, 3

; ENTITY_TUT_TV_SNAKE_FACING_RIGHT action $02
; ENTITY_TUT_TV_SNAKE_FACING_LEFT action $02
data_02_78ce:
    db   BANK(image_tut_tv_snake_facing_right_and_1_more_00c_6f00), PENDING_ACTION_PRESENT | $00, $1a, $08, $08                   ; 8 frames at 8 ticks, then action $00
    entity_frames image_tut_tv_snake_facing_right_and_1_more_00c_6f00, 8, 4, 4, 4, 4, 4, 5, 6, 7

; ENTITY_TUT_TV_SNAKE_FACING_RIGHT action $03
; ENTITY_TUT_TV_SNAKE_FACING_LEFT action $03
data_02_78db:
    db   BANK(image_tut_tv_snake_facing_right_and_1_more_00c_6f00), PENDING_ACTION_PRESENT | $04, $1a, $1e, $01                   ; one frame, 30 ticks, then action $04
    entity_frames image_tut_tv_snake_facing_right_and_1_more_00c_6f00, 8, 8

; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE action $00
; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE action $00
data_02_78e1:
    db   BANK(image_tut_tv_snake_right_projectile_and_1_more_00a_4220), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_snake_right_projectile_and_1_more_00a_4220, 1, 0

data_02_78e7:                                               ; ENTITY_TUT_TV_RA_STAFF action $00
    db   BANK(image_tut_tv_ra_staff_00f_4500), $00, $12, $0a, $08                                            ; 8 frames at 10 ticks, looping
    entity_frames image_tut_tv_ra_staff_00f_4500, 4, 0, 1, 2, 3, 4, 5, 6, 7

; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE action $00
; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE action $00
data_02_78f4:
    db   BANK(image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040, 1, 0

; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE action $01
; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE action $01
data_02_78fa:
    db   BANK(image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040), $00, $12, $06, $14                                            ; 20 frames at 6 ticks, looping
    entity_frames image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1

; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE action $02
; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE action $02
data_02_7913:
    db   BANK(image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040), PENDING_ACTION_PRESENT | $03, $1a, $06, $0e                   ; 14 frames at 6 ticks, then action $03
    entity_frames image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040, 1, 0, 1, 2, 3, 4, 4, 3, 2, 1, 0, 1, 2, 3, 4

; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE action $03
; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE action $03
data_02_7926:
    db   BANK(image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040), $00, $12, $0f, $02                                            ; 2 frames at 15 ticks, looping
    entity_frames image_tut_tv_ra_statue_horizontal_projectile_and_1_more_00a_4040, 1, 5, 6

data_02_792d:                                               ; ENTITY_TUT_TV_BREAKABLE_BLOCK action $00
    db   BANK(image_tut_tv_breakable_block_00f_4900), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_breakable_block_00f_4900, 4, 0

data_02_7933:                                               ; ENTITY_TUT_TV_BREAKABLE_BLOCK action $01
    db   BANK(image_tut_tv_breakable_block_00f_4900), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_breakable_block_00f_4900, 4, 1

data_02_7939:                                               ; ENTITY_TUT_TV_BREAKABLE_BLOCK action $02
    db   BANK(image_tut_tv_breakable_block_00f_4900), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_breakable_block_00f_4900, 4, 2

data_02_793f:                                               ; ENTITY_TUT_TV_BREAKABLE_BLOCK action $03
    db   BANK(image_tut_tv_breakable_block_00f_4900), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_tut_tv_breakable_block_00f_4900, 4, 2

data_02_7945:                                               ; ENTITY_TUT_TV_COFFIN action $00
    db   BANK(image_tut_tv_coffin_009_7900), $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $02

data_02_794b:                                               ; ENTITY_TUT_TV_COFFIN action $01
    db   BANK(image_tut_tv_coffin_009_7900), PENDING_ACTION_PRESENT | $02, $3a, $0a, $02                   ; 2 frames at 10 ticks, then action $02
    db   $01, $00

data_02_7952:                                               ; ENTITY_TUT_TV_COFFIN action $02
    db   BANK(image_tut_tv_coffin_009_7900), $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $00


; ------------------------------------------------------------------
; WESTERN STATION
; ------------------------------------------------------------------

data_02_7958:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $00
    db   BANK(image_western_station_enemy_cactus_01d_4000), $00, $32, $0f, $04                                            ; 4 frames at 15 ticks, looping
    db   $0b, $0c, $0d, $0c

data_02_7961:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $01
    db   BANK(image_western_station_enemy_cactus_01d_4000), $00, $3a, $06, $04                                            ; 4 frames at 6 ticks, then holds the last
    db   $00, $01, $02, $03

data_02_796a:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $02
    db   BANK(image_western_station_enemy_cactus_01d_4000), PENDING_ACTION_PRESENT | $03, $3a, $06, $02                   ; 2 frames at 6 ticks, then action $03
    db   $04, $05

data_02_7971:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $03
    db   BANK(image_western_station_enemy_cactus_01d_4000), PENDING_ACTION_PRESENT | $04, $3a, $06, $03                   ; 3 frames at 6 ticks, then action $04
    db   $08, $09, $0a

data_02_7979:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $04
    db   BANK(image_western_station_enemy_cactus_01d_4000), $00, $3a, $06, $02                                            ; 2 frames at 6 ticks, then holds the last
    db   $06, $07

data_02_7980:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $05
    db   BANK(image_western_station_enemy_cactus_and_1_more_01d_5500), PENDING_ACTION_PRESENT | $00, $3a, $1e, $01                   ; one frame, 30 ticks, then action $00
    db   $0e

data_02_7986:                                               ; ENTITY_WESTERN_STATION_ENEMY_CACTUS action $06
    db   BANK(image_western_station_enemy_cactus_and_1_more_01d_5500), $00, $3a, $1e, $01                                            ; one frame, 30 ticks, then holds the last
    db   $0e

data_02_798c:                                               ; ENTITY_WESTERN_STATION_CACTUS action $00
    db   BANK(image_western_station_enemy_cactus_and_1_more_01d_5500), PENDING_ACTION_PRESENT | $00, $3a, $1e, $01                   ; one frame, 30 ticks, then action $00
    db   $0e

data_02_7992:                                               ; ENTITY_WESTERN_STATION_ROCK_PLATFORM action $00
    db   BANK(image_western_station_rock_platform_00f_4b00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_western_station_rock_platform_00f_4b00, 4, 0

data_02_7998:                                               ; ENTITY_WESTERN_STATION_ROCK_PLATFORM action $01
    db   BANK(image_western_station_rock_platform_00f_4b00), PENDING_ACTION_PRESENT | $02, $1a, $04, $08                   ; 8 frames at 4 ticks, then action $02
    entity_frames image_western_station_rock_platform_00f_4b00, 4, 0, 1, 2, 3, 4, 5, 6, 7

data_02_79a5:                                               ; ENTITY_WESTERN_STATION_ROCK_PLATFORM action $02
    db   BANK(image_western_station_rock_platform_00f_4b00), PENDING_ACTION_PRESENT | $03, $1b, $78, $01                   ; one frame, 120 ticks, then action $03
    entity_frames image_western_station_rock_platform_00f_4b00, 4, 7

data_02_79ab:                                               ; ENTITY_WESTERN_STATION_ROCK_PLATFORM action $03
    db   BANK(image_western_station_rock_platform_00f_4b00), PENDING_ACTION_PRESENT | $00, $1a, $04, $08                   ; 8 frames at 4 ticks, then action $00
    entity_frames image_western_station_rock_platform_00f_4b00, 4, 7, 6, 5, 4, 3, 2, 1, 0

; declares 5 frames but six ids follow - trimmed by editing the count
data_02_79b8:                                               ; ENTITY_WESTERN_STATION_HARD_HAT action $00
    db   BANK(image_western_station_hard_hat_00a_6ca0), $00, $12, $05, $05                                            ; 5 frames at 5 ticks, looping
    entity_frames image_western_station_hard_hat_00a_6ca0, 2, 3, 4, 5, 6, 7
    db   $90                       ; spare frames past the declared count

data_02_79c3:                                               ; ENTITY_WESTERN_STATION_HARD_HAT action $01
    db   BANK(image_western_station_hard_hat_00a_7360), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_western_station_hard_hat_00a_7360, 2, 0

data_02_79c9:                                               ; ENTITY_WESTERN_STATION_HARD_HAT action $02
    db   BANK(image_western_station_hard_hat_00a_6ca0), PENDING_ACTION_PRESENT | $00, $1a, $05, $10                   ; 16 frames at 5 ticks, then action $00
    entity_frames image_western_station_hard_hat_00a_6ca0, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2

data_02_79de:                                               ; ENTITY_WESTERN_STATION_HARD_HAT action $03
    db   BANK(image_western_station_hard_hat_00a_7360), PENDING_ACTION_PRESENT | $00, $1a, $0a, $01                   ; one frame, 10 ticks, then action $00
    entity_frames image_western_station_hard_hat_00a_7360, 2, 0

data_02_79e4:                                               ; ENTITY_WESTERN_STATION_PLAYING_CARD action $00
    db   BANK(image_western_station_playing_card_00a_7760), $00, $12, $08, $0a                                            ; 10 frames at 8 ticks, looping
    entity_frames image_western_station_playing_card_00a_7760, 2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

data_02_79f3:                                               ; ENTITY_WESTERN_STATION_BAT action $00
    db   BANK(image_western_station_bat_00a_73a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_western_station_bat_00a_73a0, 2, 0

data_02_79f9:                                               ; ENTITY_WESTERN_STATION_BAT action $01
    db   BANK(image_western_station_bat_00a_73a0), PENDING_ACTION_PRESENT | $02, $1a, $04, $08                   ; 8 frames at 4 ticks, then action $02
    entity_frames image_western_station_bat_00a_73a0, 2, 1, 2, 3, 3, 2, 1, 1, 1

data_02_7a06:                                               ; ENTITY_WESTERN_STATION_BAT action $02
    db   BANK(image_western_station_bat_00a_73a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_western_station_bat_00a_73a0, 2, 4

data_02_7a0c:                                               ; ENTITY_WESTERN_STATION_BAT action $03
    db   BANK(image_western_station_bat_00a_73a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_western_station_bat_00a_73a0, 2, 5

data_02_7a12:                                               ; ENTITY_WESTERN_STATION_RISING_PLATFORM action $00
    db   BANK(image_western_station_rising_platform_00a_7a40), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_western_station_rising_platform_00a_7a40, 3, 0


; ------------------------------------------------------------------
; ANIME CHANNEL
; ------------------------------------------------------------------

data_02_7a18:                                               ; ENTITY_ANIME_CHANNEL_DOOR action $00
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 0

data_02_7a1e:                                               ; ENTITY_ANIME_CHANNEL_DOOR action $01
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 1, 2, 3

data_02_7a26:                                               ; ENTITY_ANIME_CHANNEL_DOOR action $02
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 3

data_02_7a2c:                                               ; ENTITY_ANIME_CHANNEL_DOOR action $03
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), PENDING_ACTION_PRESENT | $00, $1a, $06, $03                   ; 3 frames at 6 ticks, then action $00
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 2, 1, 0

data_02_7a34:                                               ; ENTITY_ANIME_CHANNEL_DOOR2 action $00
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 3

data_02_7a3a:                                               ; ENTITY_ANIME_CHANNEL_DOOR2 action $01
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), PENDING_ACTION_PRESENT | $02, $1a, $06, $03                   ; 3 frames at 6 ticks, then action $02
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 2, 1, 0

data_02_7a42:                                               ; ENTITY_ANIME_CHANNEL_DOOR2 action $02
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 0

data_02_7a48:                                               ; ENTITY_ANIME_CHANNEL_DOOR2 action $03
    db   BANK(image_anime_channel_door_anime_channel_door2_00b_4e00), $00, $1a, $06, $03                                            ; 3 frames at 6 ticks, then holds the last
    entity_frames image_anime_channel_door_anime_channel_door2_00b_4e00, 8, 1, 2, 3

data_02_7a50:                                               ; ENTITY_ANIME_CHANNEL_FAN_LIFT action $00
    db   BANK(image_anime_channel_fan_lift_00a_4500), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_fan_lift_00a_4500, 1, 0

data_02_7a56:                                               ; ENTITY_ANIME_CHANNEL_FAN_LIFT action $01
    db   BANK(image_anime_channel_fan_lift_00a_4500), PENDING_ACTION_PRESENT | $02, $1a, $06, $06                   ; 6 frames at 6 ticks, then action $02
    entity_frames image_anime_channel_fan_lift_00a_4500, 1, 0, 1, 2, 3, 4, 5

data_02_7a61:                                               ; ENTITY_ANIME_CHANNEL_FAN_LIFT action $02
    db   BANK(image_anime_channel_fan_lift_00a_4500), $00, $12, $06, $14                                            ; 20 frames at 6 ticks, looping
    entity_frames image_anime_channel_fan_lift_00a_4500, 1, 11, 8, 10, 6, 9, 8, 11, 9, 7, 6, 10, 7, 6, 9, 11, 7, 8, 7, 9, 10

data_02_7a7a:                                               ; ENTITY_ANIME_CHANNEL_FAN_LIFT action $03
    db   BANK(image_anime_channel_fan_lift_00a_4500), PENDING_ACTION_PRESENT | $00, $1a, $06, $06                   ; 6 frames at 6 ticks, then action $00
    entity_frames image_anime_channel_fan_lift_00a_4500, 1, 5, 4, 3, 2, 1, 0

; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT action $00
; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT action $00
data_02_7a85:
    db   BANK(image_anime_channel_mech_facing_right_and_1_more_00b_7e00), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_mech_facing_right_and_1_more_00b_7e00, 8, 0

; Unreachable - no action table row points here, and in the ROM it has no label
; at all. It is a complete block: the same header as the one above with the next
; sprite id, so it reads as a second pose that was cut rather than as stray data
data_02_7a8b_Orphan:
    db   $0b, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $3f

data_02_7a91:                                               ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR action $00
    db   BANK(image_anime_channel_disappearing_floor_and_1_more_00f_4a80), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_disappearing_floor_and_1_more_00f_4a80, 4, 0

data_02_7a97:                                               ; ENTITY_ANIME_CHANNEL_ON_SWITCH2 action $00
    db   BANK(image_anime_channel_on_switch2_and_2_more_00a_42e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_on_switch2_and_2_more_00a_42e0, 1, 1

data_02_7a9d:                                               ; ENTITY_ANIME_CHANNEL_ON_SWITCH2 action $01
    db   BANK(image_anime_channel_on_switch2_and_2_more_00a_42e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_on_switch2_and_2_more_00a_42e0, 1, 0

data_02_7aa3:                                               ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE action $00
    db   BANK(image_anime_channel_alien_culture_tube_00b_5200), $00, $12, $0a, $04                                            ; 4 frames at 10 ticks, looping
    entity_frames image_anime_channel_alien_culture_tube_00b_5200, 8, 0, 1, 2, 1

data_02_7aac:                                               ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE action $01
    db   BANK(image_anime_channel_alien_culture_tube_00b_5200), PENDING_ACTION_PRESENT | $02, $1a, $0a, $02                   ; 2 frames at 10 ticks, then action $02
    entity_frames image_anime_channel_alien_culture_tube_00b_5200, 8, 3, 4

data_02_7ab3:                                               ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE action $02
    db   BANK(image_anime_channel_alien_culture_tube_00b_5200), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_alien_culture_tube_00b_5200, 8, 5

data_02_7ab9:                                               ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER action $00
    db   BANK(image_anime_channel_blue_beam_barrier_and_1_more_00a_4260), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_anime_channel_blue_beam_barrier_and_1_more_00a_4260, 1, 0, 1, 2, 3

data_02_7ac2:                                               ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER action $01
    db   BANK(image_anime_channel_blue_beam_barrier_and_1_more_00a_4260), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_blue_beam_barrier_and_1_more_00a_4260, 1, 0

data_02_7ac8:                                               ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM action $00
    db   BANK(image_anime_channel_rising_platform_00a_59a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_rising_platform_00a_59a0, 2, 0

data_02_7ace:                                               ; ENTITY_ANIME_CHANNEL_ON_SWITCH action $00
    db   BANK(image_anime_channel_on_switch2_and_2_more_00a_42e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_on_switch2_and_2_more_00a_42e0, 1, 1

data_02_7ad4:                                               ; ENTITY_ANIME_CHANNEL_ON_SWITCH action $01
    db   BANK(image_anime_channel_on_switch2_and_2_more_00a_42e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_on_switch2_and_2_more_00a_42e0, 1, 0

data_02_7ada:                                               ; ENTITY_ANIME_CHANNEL_OFF_SWITCH action $00
    db   BANK(image_anime_channel_on_switch2_and_2_more_00a_42e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_on_switch2_and_2_more_00a_42e0, 1, 1

data_02_7ae0:                                               ; ENTITY_ANIME_CHANNEL_OFF_SWITCH action $01
    db   BANK(image_anime_channel_on_switch2_and_2_more_00a_42e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_on_switch2_and_2_more_00a_42e0, 1, 0

data_02_7ae6:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $00
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 0, 8, 9, 8

data_02_7aef:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $01
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), PENDING_ACTION_PRESENT | $00, $1a, $06, $07                   ; 7 frames at 6 ticks, then action $00
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 0, 10, 11, 12, 13, 14, 0

data_02_7afb:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $02
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), $00, $12, $08, $07                                            ; 7 frames at 8 ticks, looping
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 1, 2, 3, 4, 2, 3, 4

data_02_7b07:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $03
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), $00, $1a, $1e, $01                                            ; one frame, 30 ticks, then holds the last
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 1

data_02_7b0d:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $04
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), PENDING_ACTION_PRESENT | $05, $1a, $08, $02                   ; 2 frames at 8 ticks, then action $05
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 0, 1

data_02_7b14:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $05
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), $00, $1a, $08, $03                                            ; 3 frames at 8 ticks, then holds the last
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 6, 6, 5

data_02_7b1c:                                               ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL action $06
    db   BANK(image_anime_channel_sailor_toon_girl_00b_6700), PENDING_ACTION_PRESENT | $00, $1a, $0f, $01                   ; one frame, 15 ticks, then action $00
    entity_frames image_anime_channel_sailor_toon_girl_00b_6700, 8, 7

data_02_7b22:                                               ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT action $00
    db   BANK(image_anime_channel_big_silver_robot_008_4000), $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $00

data_02_7b28:                                               ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT action $01
    db   BANK(image_anime_channel_big_silver_robot_008_4000), $00, $32, $08, $06                                            ; 6 frames at 8 ticks, looping
    db   $10, $11, $12, $13, $14, $15

data_02_7b33:                                               ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT action $02
    db   BANK(image_anime_channel_big_silver_robot_008_4000), $00, $3a, $04, $22                                            ; 34 frames at 4 ticks, then holds the last
    db   $01, $02, $02, $03, $02, $03, $02, $03
    db   $04, $05, $04, $05, $04, $05, $0d, $0e
    db   $0f, $0f, $0e, $06, $07, $08, $07, $06
    db   $07, $08, $07, $06, $07, $08, $09, $0a
    db   $0b, $0c

data_02_7b5a:                                               ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT action $03
    db   BANK(image_anime_channel_big_silver_robot_008_4000), $00, $3a, $08, $0b                                            ; 11 frames at 8 ticks, then holds the last
    db   $00, $16, $17, $18, $19, $1a, $1b, $1b
    db   $1c, $1c, $1c

data_02_7b6a:                                               ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT action $00
    db   BANK(image_anime_channel_small_blue_robot_00a_61a0), $00, $12, $08, $08                                            ; 8 frames at 8 ticks, looping
    entity_frames image_anime_channel_small_blue_robot_00a_61a0, 2, 0, 1, 2, 3, 4, 5, 6, 7

data_02_7b77:                                               ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT action $01
    db   BANK(image_anime_channel_small_blue_robot_00a_61a0), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_anime_channel_small_blue_robot_00a_61a0, 2, 8, 9, 10, 11

data_02_7b80:                                               ; ENTITY_ANIME_CHANNEL_SECBOT action $00
    db   BANK(image_anime_channel_secbot_00a_64a0), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_anime_channel_secbot_00a_64a0, 2, 0, 1, 0, 2

data_02_7b89:                                               ; ENTITY_ANIME_CHANNEL_SECBOT action $01
    db   BANK(image_anime_channel_secbot_00a_64a0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_secbot_00a_64a0, 2, 5

data_02_7b8f:                                               ; ENTITY_ANIME_CHANNEL_SECBOT action $02
    db   BANK(image_anime_channel_secbot_00a_64a0), PENDING_ACTION_PRESENT | $01, $1a, $0c, $04                   ; 4 frames at 12 ticks, then action $01
    entity_frames image_anime_channel_secbot_00a_64a0, 2, 0, 3, 4, 5

data_02_7b98:                                               ; ENTITY_ANIME_CHANNEL_SECBOT action $03
    db   BANK(image_anime_channel_secbot_00a_64a0), PENDING_ACTION_PRESENT | $00, $1a, $0c, $04                   ; 4 frames at 12 ticks, then action $00
    entity_frames image_anime_channel_secbot_00a_64a0, 2, 5, 4, 3, 0

data_02_7ba1:                                               ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE action $00
    db   BANK(image_anime_channel_secbot_projectile_00a_4320), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_secbot_projectile_00a_4320, 1, 0

data_02_7ba7:                                               ; ENTITY_ANIME_CHANNEL_ELEVATOR action $00
    db   BANK(image_anime_channel_disappearing_floor_and_1_more_00f_4a80), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_anime_channel_disappearing_floor_and_1_more_00f_4a80, 4, 0

; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY action $00
; ENTITY_CHANNEL_Z_REZ_PROJECTILE action $00
data_02_7bad:
    db   BANK(image_anime_channel_fire_wall_enemy_and_1_more_00a_6b20), $00, $12, $06, $06                                            ; 6 frames at 6 ticks, looping
    entity_frames image_anime_channel_fire_wall_enemy_and_1_more_00a_6b20, 2, 0, 1, 2, 3, 4, 5

data_02_7bb8:                                               ; ENTITY_ANIME_CHANNEL_GRENADE action $00
    db   BANK(image_anime_channel_grenade_00a_48a0), PENDING_ACTION_PRESENT | $01, $1b, $05, $01                   ; one frame, 5 ticks, then action $01
    entity_frames image_anime_channel_grenade_00a_48a0, 1, 0

data_02_7bbe:                                               ; ENTITY_ANIME_CHANNEL_GRENADE action $01
    db   BANK(image_anime_channel_grenade_00a_48a0), $00, $12, $06, $0a                                            ; 10 frames at 6 ticks, looping
    entity_frames image_anime_channel_grenade_00a_48a0, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

data_02_7bcd:                                               ; ENTITY_ANIME_CHANNEL_GRENADE action $02
    db   BANK(image_anime_channel_grenade_00a_48a0), PENDING_ACTION_PRESENT | $00, $1a, $05, $06                   ; 6 frames at 5 ticks, then action $00
    entity_frames image_anime_channel_grenade_00a_48a0, 1, 10, 11, 12, 13, 14, 15

data_02_7bd8:                                               ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON action $00
    db   BANK(image_anime_channel_planet_o_blast_weapon_00e_4e00), $00, $12, $08, $06                                            ; 6 frames at 8 ticks, looping
    entity_frames image_anime_channel_planet_o_blast_weapon_00e_4e00, 8, 0, 1, 2, 2, 2, 1


; ------------------------------------------------------------------
; SUPERHERO SHOW
; ------------------------------------------------------------------

data_02_7be3:                                               ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER action $00
    db   BANK(image_superhero_show_mad_bomber_007_4000), PENDING_ACTION_PRESENT | $01, $3a, $06, $10                   ; 16 frames at 6 ticks, then action $01
    db   $00, $01, $02, $01, $00, $01, $02, $01
    db   $00, $01, $02, $01, $00, $01, $02, $01

data_02_7bf8:                                               ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER action $01
    db   BANK(image_superhero_show_mad_bomber_007_4000), PENDING_ACTION_PRESENT | $02, $3a, $06, $05                   ; 5 frames at 6 ticks, then action $02
    db   $03, $04, $05, $06, $07

data_02_7c02:                                               ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER action $02
    db   BANK(image_superhero_show_mad_bomber_007_4000), PENDING_ACTION_PRESENT | $03, $3a, $08, $04                   ; 4 frames at 8 ticks, then action $03
    db   $08, $08, $08, $09

data_02_7c0b:                                               ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER action $03
    db   BANK(image_superhero_show_mad_bomber_007_4000), PENDING_ACTION_PRESENT | $00, $3a, $08, $03                   ; 3 frames at 8 ticks, then action $00
    db   $09, $08, $00

data_02_7c13:                                               ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER action $04
    db   BANK(image_superhero_show_mad_bomber_007_58c0), PENDING_ACTION_PRESENT | $00, $3a, $3c, $01                   ; one frame, 60 ticks, then action $00
    db   $0b

data_02_7c19:                                               ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER action $05
    db   BANK(image_superhero_show_mad_bomber_007_58c0), $00, $3a, $0f, $01                                            ; one frame, 15 ticks, then holds the last
    db   $0b

; ENTITY_SUPERHERO_SHOW_BOMB action $00
; ENTITY_SUPERHERO_SHOW_BOMB action $01
; ENTITY_SUPERHERO_SHOW_BOMB action $02
; ENTITY_SUPERHERO_SHOW_BOMB action $03
data_02_7c1f:
    db   BANK(image_superhero_show_bomb_00a_59e0), $00, $12, $04, $03                                            ; 3 frames at 4 ticks, looping
    entity_frames image_superhero_show_bomb_00a_59e0, 2, 0, 1, 2

data_02_7c27:                                               ; ENTITY_SUPERHERO_SHOW_BOMB action $04
    db   BANK(image_superhero_show_bomb_00a_6020), $00, $1a, $04, $06                                            ; 6 frames at 4 ticks, then holds the last
    entity_frames image_superhero_show_bomb_00a_6020, 2, 0, 1, 2, 3, 4, 5

; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK action $00
; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK action $01
; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK action $02
data_02_7c32:
    db   BANK(image_superhero_show_water_tower_tank_00b_5800), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_superhero_show_water_tower_tank_00b_5800, 8, 0

data_02_7c38:                                               ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND action $00
    db   BANK(image_superhero_show_water_tower_stand_00d_6400), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_superhero_show_water_tower_stand_00d_6400, 6, 0

data_02_7c3e:                                               ; ENTITY_SUPERHERO_SHOW_CONVICT action $00
    db   BANK(image_superhero_show_convict_00d_64c0), PENDING_ACTION_PRESENT | $01, $12, $06, $0e                   ; 14 frames at 6 ticks, then action $01
    entity_frames image_superhero_show_convict_00d_64c0, 6, 0, 1, 1, 1, 2, 0, 3, 3, 3, 0, 1, 1, 1, 2

data_02_7c51:                                               ; ENTITY_SUPERHERO_SHOW_CONVICT action $01
    db   BANK(image_superhero_show_convict_00d_64c0), PENDING_ACTION_PRESENT | $02, $1a, $06, $08                   ; 8 frames at 6 ticks, then action $02
    entity_frames image_superhero_show_convict_00d_64c0, 6, 0, 3, 5, 5, 4, 7, 7, 7

data_02_7c5e:                                               ; ENTITY_SUPERHERO_SHOW_CONVICT action $02
    db   BANK(image_superhero_show_convict_00d_64c0), PENDING_ACTION_PRESENT | $00, $1a, $06, $07                   ; 7 frames at 6 ticks, then action $00
    entity_frames image_superhero_show_convict_00d_64c0, 6, 6, 6, 6, 7, 1, 1, 0

; ENTITY_SUPERHERO_SHOW_SPIDER action $00
; ENTITY_SUPERHERO_SHOW_SPIDER action $01
; ENTITY_SUPERHERO_SHOW_SPIDER action $02
data_02_7c6a:
    db   BANK(image_superhero_show_spider_00a_5aa0), $00, $12, $06, $03                                            ; 3 frames at 6 ticks, looping
    entity_frames image_superhero_show_spider_00a_5aa0, 2, 0, 1, 2

data_02_7c72:                                               ; ENTITY_SUPERHERO_SHOW_STRAY_CAT action $00
    db   BANK(image_superhero_show_stray_cat_00a_5b60), $00, $12, $0a, $02                                            ; 2 frames at 10 ticks, looping
    entity_frames image_superhero_show_stray_cat_00a_5b60, 2, 0, 1

data_02_7c79:                                               ; ENTITY_SUPERHERO_SHOW_STRAY_CAT action $01
    db   BANK(image_superhero_show_stray_cat_00a_5b60), PENDING_ACTION_PRESENT | $02, $1a, $78, $01                   ; one frame, 120 ticks, then action $02
    entity_frames image_superhero_show_stray_cat_00a_5b60, 2, 4

data_02_7c7f:                                               ; ENTITY_SUPERHERO_SHOW_STRAY_CAT action $02
    db   BANK(image_superhero_show_stray_cat_00a_5b60), PENDING_ACTION_PRESENT | $03, $1a, $08, $07                   ; 7 frames at 8 ticks, then action $03
    entity_frames image_superhero_show_stray_cat_00a_5b60, 2, 4, 2, 3, 2, 3, 2, 3

data_02_7c8b:                                               ; ENTITY_SUPERHERO_SHOW_STRAY_CAT action $03
    db   BANK(image_superhero_show_stray_cat_00a_5b60), PENDING_ACTION_PRESENT | $04, $1a, $1e, $02                   ; 2 frames at 30 ticks, then action $04
    entity_frames image_superhero_show_stray_cat_00a_5b60, 2, 4
    entity_frames image_superhero_show_stray_cat_00a_5ce0, 2, 1

data_02_7c92:                                               ; ENTITY_SUPERHERO_SHOW_STRAY_CAT action $04
    db   BANK(image_superhero_show_stray_cat_00a_5ce0), PENDING_ACTION_PRESENT | $00, $1a, $14, $0a                   ; 10 frames at 20 ticks, then action $00
    entity_frames image_superhero_show_stray_cat_00a_5ce0, 2, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1

data_02_7ca1:                                               ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON action $00
    db   BANK(image_superhero_show_yellow_goon_00b_5c00), $00, $12, $0a, $04                                            ; 4 frames at 10 ticks, looping
    entity_frames image_superhero_show_yellow_goon_00b_5c00, 8, 0, 1, 0, 2

data_02_7caa:                                               ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON action $01
    db   BANK(image_superhero_show_yellow_goon_00b_5c00), PENDING_ACTION_PRESENT | $00, $1a, $0a, $05                   ; 5 frames at 10 ticks, then action $00
    entity_frames image_superhero_show_yellow_goon_00b_5c00, 8, 3, 4, 5, 4, 3

data_02_7cb4:                                               ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON action $02
    db   BANK(image_superhero_show_yellow_goon_00b_5c00), PENDING_ACTION_PRESENT | $00, $1a, $0a, $0b                   ; 11 frames at 10 ticks, then action $00
    entity_frames image_superhero_show_yellow_goon_00b_5c00, 8, 0, 6, 7, 8, 9, 10, 9, 8, 7, 6, 0

data_02_7cc4:                                               ; ENTITY_SUPERHERO_SHOW_RAT action $00
    db   BANK(image_superhero_show_rat_00a_5d60), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_superhero_show_rat_00a_5d60, 2, 0, 1, 0, 2

data_02_7ccd:                                               ; ENTITY_SUPERHERO_SHOW_RAT action $01
    db   BANK(image_superhero_show_rat_00a_5d60), PENDING_ACTION_PRESENT | $00, $1a, $08, $04                   ; 4 frames at 8 ticks, then action $00
    entity_frames image_superhero_show_rat_00a_5d60, 2, 0, 1, 2, 2

; ENTITY_SUPERHERO_SHOW_CHOMPER_TV action $00
; ENTITY_SUPERHERO_SHOW_CHOMPER_TV action $01
data_02_7cd6:
    db   BANK(image_superhero_show_chomper_tv_00a_5e20), $00, $12, $0a, $04                                            ; 4 frames at 10 ticks, looping
    entity_frames image_superhero_show_chomper_tv_00a_5e20, 2, 0, 1, 0, 2

data_02_7cdf:                                               ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV action $02
    db   BANK(image_superhero_show_chomper_tv_00a_5e20), $00, $12, $0a, $02                                            ; 2 frames at 10 ticks, looping
    entity_frames image_superhero_show_chomper_tv_00a_5e20, 2, 3, 4

data_02_7ce6:                                               ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR action $00
    db   BANK(image_superhero_show_crumbling_floor_00a_5f60), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_superhero_show_crumbling_floor_00a_5f60, 2, 0

data_02_7cec:                                               ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR action $01
    db   BANK(image_superhero_show_crumbling_floor_00a_5f60), PENDING_ACTION_PRESENT | $02, $1a, $02, $02                   ; 2 frames at 2 ticks, then action $02
    entity_frames image_superhero_show_crumbling_floor_00a_5f60, 2, 1, 2

data_02_7cf3:                                               ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR action $02
    db   BANK(image_superhero_show_crumbling_floor_00a_5f60), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_superhero_show_crumbling_floor_00a_5f60, 2, 2

data_02_7cf9:                                               ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE action $00
    db   BANK(image_superhero_show_convict_projectile_00a_43a0), $00, $12, $06, $0a                                            ; 10 frames at 6 ticks, looping
    entity_frames image_superhero_show_convict_projectile_00a_43a0, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9


; ------------------------------------------------------------------
; GEXTREME SPORTS
; ------------------------------------------------------------------

data_02_7d08:                                               ; ENTITY_GEXTREME_SPORTS_ELF action $00
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), PENDING_ACTION_PRESENT | $01, $1a, $05, $0a                   ; 10 frames at 5 ticks, then action $01
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 1, 2, 3, 4, 5, 5, 5, 5, 5, 5

data_02_7d17:                                               ; ENTITY_GEXTREME_SPORTS_ELF action $01
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), PENDING_ACTION_PRESENT | $00, $1a, $05, $0a                   ; 10 frames at 5 ticks, then action $00
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0

data_02_7d26:                                               ; ENTITY_GEXTREME_SPORTS_ELF action $02
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), $00, $12, $05, $0a                                            ; 10 frames at 5 ticks, looping
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

data_02_7d35:                                               ; ENTITY_GEXTREME_SPORTS_ELF action $03
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 0

data_02_7d3b:                                               ; ENTITY_GEXTREME_SPORTS_ELF action $04
    db   BANK(image_slot_stride_gextreme_sports_elf_00c_6300), $00, $12, $05, $02                                            ; 2 frames at 5 ticks, looping
    entity_frames image_slot_stride_gextreme_sports_elf_00c_6300, 8, 10, 11

data_02_7d42:                                               ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN action $00
    db   BANK(image_gextreme_sports_bonus_time_coin_00b_7600), $00, $12, $08, $08                                            ; 8 frames at 8 ticks, looping
    entity_frames image_gextreme_sports_bonus_time_coin_00b_7600, 8, 0, 1, 2, 3, 4, 5, 6, 7


; ------------------------------------------------------------------
; MARSUPIAL MADNESS
; ------------------------------------------------------------------

; ENTITY_MARSUPIAL_MADNESS_BELL action $00
; ENTITY_MARSUPIAL_MADNESS_BELL action $02
data_02_7d4f:
    db   BANK(image_marsupial_madness_bell_00b_5900), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_marsupial_madness_bell_00b_5900, 8, 1

data_02_7d55:                                               ; ENTITY_MARSUPIAL_MADNESS_BELL action $01
    db   BANK(image_marsupial_madness_bell_00b_5900), PENDING_ACTION_PRESENT | $02, $1a, $06, $0b                   ; 11 frames at 6 ticks, then action $02
    entity_frames image_marsupial_madness_bell_00b_5900, 8, 0, 1, 2, 1, 0, 1, 2, 1, 0, 1, 2

data_02_7d65:                                               ; ENTITY_MARSUPIAL_MADNESS_BIRD action $00
    db   BANK(image_marsupial_madness_bird_00a_7520), $00, $12, $0a, $09                                            ; 9 frames at 10 ticks, looping
    entity_frames image_marsupial_madness_bird_00a_7520, 2, 0, 1, 2, 3, 4, 5, 6, 7, 8

data_02_7d73:                                               ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE action $00
    db   BANK(image_marsupial_madness_bird_projectile_00a_47c0), $00, $12, $06, $04                                            ; 4 frames at 6 ticks, looping
    entity_frames image_marsupial_madness_bird_projectile_00a_47c0, 1, 0, 1, 2, 3


; ------------------------------------------------------------------
; WW GEX WRESTLING
; ------------------------------------------------------------------

data_02_7d7c:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $01
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), PENDING_ACTION_PRESENT | $00, $3a, $05, $19                   ; 25 frames at 5 ticks, then action $00
    db   $11, $10, $0d, $0c, $0b, $0a, $09, $00
    db   $01, $02, $03, $04, $05, $06, $07, $08
    db   $08, $07, $06, $05, $04, $03, $02, $01
    db   $00

data_02_7d9a:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $00
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), PENDING_ACTION_PRESENT | $02, $3a, $0a, $04                   ; 4 frames at 10 ticks, then action $02
    db   $13, $14, $13, $15

data_02_7da3:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $02
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), $00, $3a, $05, $09                                            ; 9 frames at 5 ticks, then holds the last
    db   $09, $0a, $0b, $0c, $0d, $0e, $0f, $10
    db   $11

data_02_7db1:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $03
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), PENDING_ACTION_PRESENT | $04, $3a, $28, $01                   ; one frame, 40 ticks, then action $04
    db   $12

data_02_7db7:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $04
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), PENDING_ACTION_PRESENT | $00, $3a, $05, $07                   ; 7 frames at 5 ticks, then action $00
    db   $11, $10, $0d, $0c, $0b, $0a, $09

data_02_7dc3:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $05
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), $00, $3a, $0a, $05                                            ; 5 frames at 10 ticks, then holds the last
    db   $16, $17, $18, $19, $1a

data_02_7dcd:                                               ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD action $06
    db   BANK(image_ww_gex_wrestling_rock_hard_010_4000), $00, $32, $06, $03                                            ; 3 frames at 6 ticks, looping
    db   $1b, $1c, $1d


; ------------------------------------------------------------------
; LIZARD OF OZ
; ------------------------------------------------------------------

data_02_7dd5:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $00
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), PENDING_ACTION_PRESENT | $01, $1b, $06, $01                   ; one frame, 6 ticks, then action $01
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 0

data_02_7ddb:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $01
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), PENDING_ACTION_PRESENT | $00, $1a, $06, $01                   ; one frame, 6 ticks, then action $00
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 0

data_02_7de1:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $02
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), $00, $12, $06, $05                                            ; 5 frames at 6 ticks, looping
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 0, 1, 2, 1, 0

data_02_7deb:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $03
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), $00, $12, $06, $09                                            ; 9 frames at 6 ticks, looping
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 0, 1, 2, 1, 2, 1, 2, 1, 0

data_02_7df9:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $04
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), PENDING_ACTION_PRESENT | $05, $1a, $06, $02                   ; 2 frames at 6 ticks, then action $05
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 3, 4

data_02_7e00:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $05
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), PENDING_ACTION_PRESENT | $03, $1a, $06, $04                   ; 4 frames at 6 ticks, then action $03
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 5, 5, 4, 3

data_02_7e09:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $06
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), PENDING_ACTION_PRESENT | $02, $1a, $28, $01                   ; one frame, 40 ticks, then action $02
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 6

data_02_7e0f:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ action $07
    db   BANK(image_lizard_of_oz_brain_of_oz_00d_6ac0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_lizard_of_oz_brain_of_oz_00d_6ac0, 6, 6

data_02_7e15:                                               ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE action $00
    db   BANK(image_lizard_of_oz_cannon_projectile_00a_44e0), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_lizard_of_oz_cannon_projectile_00a_44e0, 1, 0

data_02_7e1b:                                               ; ENTITY_LIZARD_OF_OZ_CANNON action $00
    db   BANK(image_lizard_of_oz_cannon_00e_4000), $00, $1b, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_lizard_of_oz_cannon_00e_4000, 8, 0

data_02_7e21:                                               ; ENTITY_LIZARD_OF_OZ_CANNON action $01
    db   BANK(image_lizard_of_oz_cannon_00e_4000), PENDING_ACTION_PRESENT | $02, $1a, $03, $0e                   ; 14 frames at 3 ticks, then action $02
    entity_frames image_lizard_of_oz_cannon_00e_4000, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13

data_02_7e34:                                               ; ENTITY_LIZARD_OF_OZ_CANNON action $02
    db   BANK(image_lizard_of_oz_cannon_00e_4000), $00, $1a, $10, $01                                            ; one frame, 16 ticks, then holds the last
    entity_frames image_lizard_of_oz_cannon_00e_4000, 8, 13

data_02_7e3a:                                               ; ENTITY_LIZARD_OF_OZ_CANNON action $03
    db   BANK(image_lizard_of_oz_cannon_00e_4000), PENDING_ACTION_PRESENT | $04, $1a, $3c, $01                   ; one frame, 60 ticks, then action $04
    entity_frames image_lizard_of_oz_cannon_00e_4000, 8, 13

data_02_7e40:                                               ; ENTITY_LIZARD_OF_OZ_CANNON action $04
    db   BANK(image_lizard_of_oz_cannon_00e_4000), PENDING_ACTION_PRESENT | $00, $1a, $03, $0e                   ; 14 frames at 3 ticks, then action $00
    entity_frames image_lizard_of_oz_cannon_00e_4000, 8, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

; declares 5 frames but six ids follow - trimmed by editing the count
data_02_7e53:                                               ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE action $00
    db   BANK(image_lizard_of_oz_brain_of_oz_projectile_00a_66a0), $00, $12, $08, $05                                            ; 5 frames at 8 ticks, looping
    entity_frames image_lizard_of_oz_brain_of_oz_projectile_00a_66a0, 2, 0, 1, 2, 3, 4
    db   $75                       ; spare frames past the declared count

data_02_7e5e:                                               ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2 action $00
    db   BANK(image_lizard_of_oz_cannon_projectile_2_00a_6820), $00, $1a, $08, $04                                            ; 4 frames at 8 ticks, then holds the last
    entity_frames image_lizard_of_oz_cannon_projectile_2_00a_6820, 2, 0, 1, 2, 3


; ------------------------------------------------------------------
; CHANNEL Z
; ------------------------------------------------------------------

data_02_7e67:                                               ; ENTITY_CHANNEL_Z_GREEN_BLOCK action $00
    db   BANK(image_channel_z_green_block_00a_6920), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_channel_z_green_block_00a_6920, 2, 0

data_02_7e6d:                                               ; ENTITY_CHANNEL_Z_ORANGE_BLOCK action $00
    db   BANK(image_channel_z_orange_block_00a_6a20), $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_channel_z_orange_block_00a_6a20, 2, 0

data_02_7e73:                                               ; ENTITY_CHANNEL_Z_REZ action $00
    db   BANK(image_channel_z_rez_01e_4000), PENDING_ACTION_PRESENT | $01, $33, $06, $01                   ; one frame, 6 ticks, then action $01
    db   $00

data_02_7e79:                                               ; ENTITY_CHANNEL_Z_REZ action $01
    db   BANK(image_channel_z_rez_01e_4000), PENDING_ACTION_PRESENT | $00, $32, $06, $01                   ; one frame, 6 ticks, then action $00
    db   $00

data_02_7e7f:                                               ; ENTITY_CHANNEL_Z_REZ action $02
    db   BANK(image_channel_z_rez_01e_4000), $00, $32, $08, $06                                            ; 6 frames at 8 ticks, looping
    db   $00, $01, $02, $02, $01, $00

data_02_7e8a:                                               ; ENTITY_CHANNEL_Z_REZ action $03
    db   BANK(image_channel_z_rez_01e_4000), $00, $32, $08, $06                                            ; 6 frames at 8 ticks, looping
    db   $03, $01, $02, $02, $01, $03

data_02_7e95:                                               ; ENTITY_CHANNEL_Z_REZ action $04
    db   BANK(image_channel_z_rez_01e_4000), PENDING_ACTION_PRESENT | $05, $32, $28, $01                   ; one frame, 40 ticks, then action $05
    db   $05

data_02_7e9b:                                               ; ENTITY_CHANNEL_Z_REZ action $05
    db   BANK(image_channel_z_rez_01e_4000), $00, $32, $08, $04                                            ; 4 frames at 8 ticks, looping
    db   $04, $03, $03, $03

data_02_7ea4:                                               ; ENTITY_CHANNEL_Z_REZ action $06
    db   BANK(image_channel_z_rez_01e_4000), PENDING_ACTION_PRESENT | $07, $3b, $04, $01                   ; one frame, 4 ticks, then action $07
    db   $05

data_02_7eaa:                                               ; ENTITY_CHANNEL_Z_REZ action $07
    db   BANK(image_channel_z_rez_01e_4000), PENDING_ACTION_PRESENT | $06, $3a, $04, $01                   ; one frame, 4 ticks, then action $06
    db   $05

data_02_7eb0:                                               ; ENTITY_CHANNEL_Z_REZ action $08
    db   BANK(image_channel_z_rez_01e_4000), $00, $33, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $00

data_02_7eb6:                                               ; ENTITY_CHANNEL_Z_REZ action $09
    db   BANK(image_channel_z_rez_01e_4000), PENDING_ACTION_PRESENT | $02, $3a, $08, $07                   ; 7 frames at 8 ticks, then action $02
    db   $03, $04, $05, $05, $05, $05, $05

data_02_7ec2:                                               ; ENTITY_CHANNEL_Z_REZ action $0a
    db   BANK(image_channel_z_rez_01e_5880), $00, $3a, $08, $04                                            ; 4 frames at 8 ticks, then holds the last
    db   $07, $08, $09, $0a

data_02_7ecb:                                               ; ENTITY_CHANNEL_Z_REZ action $0b
    db   BANK(image_channel_z_rez_01e_5880), $00, $3a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $0a

data_02_7ed1:                                               ; ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER action $00
    db   BANK(image_anime_channel_blue_beam_barrier_and_1_more_00a_4260), $00, $12, $08, $04                                            ; 4 frames at 8 ticks, looping
    entity_frames image_anime_channel_blue_beam_barrier_and_1_more_00a_4260, 1, 0, 1, 2, 3

data_02_7eda:                                               ; ENTITY_CHANNEL_Z_METEOR action $00
    db   BANK(image_channel_z_meteor_00a_47a0), $00, $12, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    entity_frames image_channel_z_meteor_00a_47a0, 1, 0

data_02_7ee0:                                               ; ENTITY_CHANNEL_Z_METEOR action $01
    db   BANK(image_channel_z_meteor_00a_4680), $00, $12, $08, $06                                            ; 6 frames at 8 ticks, looping
    entity_frames image_channel_z_meteor_00a_4680, 1, 0, 1, 2, 3, 4, 5

; Unreachable - no action table row points here, and in the ROM it has no label
; at all. It is a complete block: the same header as the one above with the next
; sprite id, so it reads as a second pose that was cut rather than as stray data
data_02_7eeb_Orphan:
    db   $0a, $00, $1a, SPRITE_FRAME_COUNTER_HOLD, $01                      ; one frame, never ticks
    db   $3a, $3a                                                           ; and one id more than it declares - the last byte in the file
