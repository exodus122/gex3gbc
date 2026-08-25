; ==================================================================
; Bank 3. OAM BUILD - everything that writes wD900_ShadowOAM, in the order the
; frame uses it: the shape data first, then the builders that read it.
;
;   $58D2  data          one descriptor per entity id
;   $59EA  data          the shapes themselves
;   $5EC1  frame driver  the pass order, and the top-down depth sort
;   $5FC2  entities      cull, place, and write one entity's sprites
;   $60E6  particles     the burst effect, which is not shape-driven
;   $6148  frame end     blank whatever OAM the frame did not use
;   $615D  collectibles  the ones near the camera, and picking them up
;
; OAM is carved up by convention rather than allocated. Gex owns the first two
; entries; everything else is handed out in order from OAM_ENTITY_FIRST_BYTE through
; the single cursor wDC6F_Oam_WriteOffset, and each builder checks that cursor
; against its own limit and simply stops drawing when OAM is full. Nothing reserves
; anything, so the pass order below IS the priority scheme.
;
; Shapes, not artwork
; -------------------
; The data at the top of this file describes WHERE an entity's OAM entries go and
; which tiles inside its page they use. The picture is never here. An enemy animates
; by streaming a different page of tiles into VRAM while drawing the same handful of
; rectangles every frame, which is why a whole boss animation costs a couple of dozen
; bytes of layout shared with every other entity the same size.
;
; Two tables, read together:
;
;   data_03_58d2_EntitySpriteDescriptors  two bytes per ENTITY_* id
;       +0  SPRITE_DESC_IGNORE_FACING and SPRITE_DESC_DRAW_FIRST in the top two
;           bits, a shape index in SPRITE_DESC_SHAPE_MASK
;       +1  the tile id base added to every tile the shape names
;
;   data_03_59ea_SpriteShapeTable  a pointer per shape, but
;       SPRITE_SHAPES_PER_ENTITY of them in a row - one per facing direction. The
;       index is (shape index * 4) + facing, so turning around picks a different
;       layout rather than flipping the same one. An entity flagged
;       SPRITE_DESC_IGNORE_FACING drops the facing bit and has its X-flip cleared,
;       which is how the coins and flies draw identically both ways.
;
; Each shape is a count byte followed by that many 4-byte records - Y, X, tile,
; attributes - added to the entity's screen position, its tile base and its
; attribute byte as they are copied out.
;
; Where the artwork actually is
; -----------------------------
; Not in this bank. gex3 puts entity tiles in their own ROM banks, $07 through $1F,
; one or two pages each, and an entity names its bank in ENTITY_FIELD_SPRITE_BANK -
; a field of the action data block, so an entity's graphics can change with its
; action. call_00_08f8_StageNextGfxTransfer streams the page in when
; ACTION_STATE_ID_CHANGED says the sprite id moved.
;
; The frame
; ---------
; call_03_5ec1_OAM_BuildFrame runs one of two orders. On an ordinary map: the
; SPRITE_DESC_DRAW_FIRST entities, then Gex, then everyone else, then collectibles,
; then blank the rest, then the collision pass. On a top-down map (except
; MAP_MYSTERY_TV8 and MAP_MYSTERY_TV10, which opt out) the live slots go into
; wDC44_Oam_DrawOrderBuffer and bubble-sorted by Y first, so that entities lower on
; the screen draw later and therefore in front - the depth cue a top-down view needs
; and a side view does not.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank03_oam_build.asm
; ------------------------------------------------------------------
; The idea is the same and so is most of the vocabulary: a descriptor table indexed
; by entity id, shape tables that hold rectangles rather than pixels, one shared
; write cursor, and a final pass that blanks the unused entries. The differences:
;
;   the shape index  gex2's descriptor byte +0 means two different things depending
;                    on which of its five drawing paths the entity uses, and it
;                    indexes a pointer table with one entry per shape. gex3 has one
;                    drawing path and four entries per shape, one per facing, so its
;                    index is scaled by SPRITE_SHAPES_PER_ENTITY before use
;   backwards        gex2's builders read its descriptor table BACKWARDS, from
;                    +1 with `ld a,[hl-]`. gex3 reads forwards, and has two small
;                    helpers - Entity_SpriteIgnoresFacing and Entity_SpriteDrawsFirst -
;                    that exist only to test one bit of byte +0
;   depth            gex2 draws in slot order, always. The Y sort here is gex3 only,
;                    and only for top-down maps
;   the player       both games give Gex his own builder rather than a shape. gex2's
;                    is in this file (call_03_5ca8_Player_BuildSprites); gex3's is
;                    call_00_2ce2_Player_BuildSprites, over in bank 0
;   the HUD          gex2 builds its status row as eight OAM sprites, in this file.
;                    gex3's HUD is not sprites at all - it is tiles written into the
;                    window tilemap by bank03_hud_graphics.asm, so nothing about it
;                    appears here and it costs no OAM entries
;   particles        gex2 has six per-effect sprite builders in
;                    bank03_particle_sprites.asm. gex3 has one,
;                    call_03_60e6_Particle_BuildSprites, sitting in the middle of
;                    this file - it draws PARTICLE_SPRITE_COUNT sprites from the
;                    burst buffer and picks their tile from the burst's age. If this
;                    file is ever split, that routine and
;                    .data_03_6140_ParticleTileByAge are the piece that matches
;                    gex2's separate file
;   artwork         gex2 keeps all its entity tiles in two banks, $11 and $12, and
;                    picks pages out of them with a descriptor table. gex3 spreads
;                    them across banks $07-$1F and stores the bank in the entity's
;                    own action data, so it needs no such table
; ==================================================================

data_03_58d2_EntitySpriteDescriptors:
; Two bytes per ENTITY_* id, in entity id order - so a row's position IS its id,
; and every ENTITY_* constant is a line number in this table.
;
;   +0  SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | a SPRITE_SHAPE_*
;   +1  the tile id base added to every tile the chosen shape names
;
; The shape says how big the entity is and where its pieces sit; the tile base says
; where in its VRAM page the artwork starts. Two entities with the same shape and
; different bases are the same rectangle drawn from different tiles, which is why
; the shape list is eighteen entries long and this table is a hundred and fourteen.
;
; SPRITE_DESC_IGNORE_FACING marks the things that look the same both ways - the
; coins, the flies, the fly TVs, the tv button - and drops the facing from the shape
; lookup as well as clearing the X-flip. SPRITE_DESC_DRAW_FIRST marks the things Gex
; should pass in front of: the seven goal counters, the bonus stage timer and two
; cannon projectiles
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_GEX
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X16         , $02 ; ENTITY_BONUS_COIN
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X16         , $02 ; ENTITY_FLY_COIN_SPAWN
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X16         , $02 ; ENTITY_PAW_COIN
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_8X16          , $01 ; ENTITY_FLY_1
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_8X16          , $01 ; ENTITY_FLY_2
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_8X16          , $01 ; ENTITY_FLY_3
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_8X16          , $01 ; ENTITY_FLY_4
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_8X16          , $01 ; ENTITY_FLY_5
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_GREEN_FLY_TV
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_PURPLE_FLY_TV
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_UNK_FLY_TV_3
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_BLUE_FLY_TV
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_UNK_FLY_TV_5
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_UNK0E
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_UNK0F
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_UNK10
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X16         , $02 ; ENTITY_TV_BUTTON
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_TV_REMOTE
    db                                                      SPRITE_SHAPE_8X32          , $02 ; ENTITY_UNK13
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_1
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_2
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_3
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_4
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_5
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_6
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_GOAL_COUNTER_7
    db SPRITE_DESC_IGNORE_FACING | SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_32X16_BANK1   , $04 ; ENTITY_BONUS_STAGE_TIMER
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_FREESTANDING_REMOTE
    db                                                      SPRITE_SHAPE_24X32         , $06 ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_64X48_BANK1   , $18 ; ENTITY_HOLIDAY_TV_EVIL_SANTA
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X16         , $02 ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_HOLIDAY_TV_SKATING_ELF
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_HOLIDAY_TV_PENGUIN
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_MYSTERY_TV_REZLING
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_24X32         , $06 ; ENTITY_MYSTERY_TV_BLOOD_COOLER
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_MYSTERY_TV_FISH
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X32         , $04 ; ENTITY_MYSTERY_TV_MAGIC_SWORD
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_MYSTERY_TV_SAFARI_SAM
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    db                                                      SPRITE_SHAPE_24X32         , $06 ; ENTITY_MYSTERY_TV_GHOST_KNIGHT
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_TUT_TV_HAND
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_TUT_TV_LOST_ARK
    db                                                      SPRITE_SHAPE_24X16         , $03 ; ENTITY_TUT_TV_RISING_PLATFORM
    db                                                      SPRITE_SHAPE_24X16         , $03 ; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
    db                                                      SPRITE_SHAPE_24X32         , $06 ; ENTITY_TUT_TV_BEE
    db                                                      SPRITE_SHAPE_32X16         , $04 ; ENTITY_TUT_TV_RAFT
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
    db                                                      SPRITE_SHAPE_16X32         , $04 ; ENTITY_TUT_TV_RA_STAFF
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
    db                                                      SPRITE_SHAPE_32X16         , $04 ; ENTITY_TUT_TV_BREAKABLE_BLOCK
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_32X64_BANK1   , $10 ; ENTITY_TUT_TV_COFFIN
    db                                                      SPRITE_SHAPE_32X48_BANK1   , $0c ; ENTITY_WESTERN_STATION_ENEMY_CACTUS
    db                                                      SPRITE_SHAPE_32X48_BANK1   , $0c ; ENTITY_WESTERN_STATION_CACTUS
    db                                                      SPRITE_SHAPE_16X32         , $04 ; ENTITY_WESTERN_STATION_ROCK_PLATFORM
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_WESTERN_STATION_HARD_HAT
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_WESTERN_STATION_PLAYING_CARD
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_WESTERN_STATION_BAT
    db                                                      SPRITE_SHAPE_24X16         , $03 ; ENTITY_WESTERN_STATION_RISING_PLATFORM
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_ANIME_CHANNEL_DOOR
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_ANIME_CHANNEL_DOOR2
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_ANIME_CHANNEL_FAN_LIFT
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
    db                                                      SPRITE_SHAPE_32X16         , $04 ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_ANIME_CHANNEL_ON_SWITCH2
    db                                                      SPRITE_SHAPE_32X64_MIRRORED, $08 ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
    db                                                      SPRITE_SHAPE_8X128         , $01 ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_ANIME_CHANNEL_ON_SWITCH
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_ANIME_CHANNEL_OFF_SWITCH
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
    db                                                      SPRITE_SHAPE_32X48_BANK1   , $0c ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_ANIME_CHANNEL_SECBOT
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
    db                                                      SPRITE_SHAPE_32X16         , $04 ; ENTITY_ANIME_CHANNEL_ELEVATOR
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_ANIME_CHANNEL_GRENADE
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
    db                                                      SPRITE_SHAPE_48X48_BANK1   , $12 ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_SUPERHERO_SHOW_BOMB
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
    db                                                      SPRITE_SHAPE_16X48         , $06 ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
    db                                                      SPRITE_SHAPE_24X32         , $06 ; ENTITY_SUPERHERO_SHOW_CONVICT
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_16X16         , $02 ; ENTITY_SUPERHERO_SHOW_SPIDER
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_SUPERHERO_SHOW_STRAY_CAT
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_SUPERHERO_SHOW_RAT
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_GEXTREME_SPORTS_ELF
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_MARSUPIAL_MADNESS_BELL
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_MARSUPIAL_MADNESS_BIRD
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
    db                                                      SPRITE_SHAPE_32X64_BANK1   , $10 ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD
    db                                                      SPRITE_SHAPE_24X32         , $06 ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
    db                             SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_8X16          , $01 ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    db                                                      SPRITE_SHAPE_32X32         , $08 ; ENTITY_LIZARD_OF_OZ_CANNON
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
    db                             SPRITE_DESC_DRAW_FIRST | SPRITE_SHAPE_16X16         , $02 ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_CHANNEL_Z_GREEN_BLOCK
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_CHANNEL_Z_ORANGE_BLOCK
    db                          SPRITE_DESC_IGNORE_FACING | SPRITE_SHAPE_56X64_BANK1   , $1c ; ENTITY_CHANNEL_Z_REZ
    db                                                      SPRITE_SHAPE_8X128         , $01 ; ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
    db                                                      SPRITE_SHAPE_8X16          , $01 ; ENTITY_CHANNEL_Z_METEOR
    db                                                      SPRITE_SHAPE_16X16         , $02 ; ENTITY_CHANNEL_Z_REZ_PROJECTILE

call_03_59b6_Entity_GetSpriteTileBase:
; A = byte +1 of the descriptor for the entity in wDB61_EntityGfx_SlotOffset - its
; tile id base. The only one of the three descriptor readers that uses a slot other
; than the current one, because the graphics streamer walks the table itself
    ld   HL, wDB61_EntityGfx_SlotOffset               ;; 03:59b6 $21 $61 $db
    ld   L, [HL]                                      ;; 03:59b9 $6e
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:59ba $26 $d8
    ld   L, [HL]                                      ;; 03:59bc $6e ; ENTITY_FIELD_ENTITY_ID
    ld   H, $00                                       ;; 03:59bd $26 $00
    add  HL, HL                                       ;; 03:59bf $29
    ld   DE, data_03_58d2_EntitySpriteDescriptors+1   ;; 03:59c0 $11 $d3 $58
    add  HL, DE                                       ;; 03:59c3 $19
    ld   A, [HL]                                      ;; 03:59c4 $7e
    ret                                               ;; 03:59c5 $c9

call_03_59c6_Entity_SpriteIgnoresFacing:
; NZ if the current entity's descriptor has SPRITE_DESC_IGNORE_FACING - one sprite
; for both directions. Reads byte +0 rather than +1
    ld   HL, wDA00_CurrentEntityAddrLo                ;; 03:59c6 $21 $00 $da
    ld   L, [HL]                                      ;; 03:59c9 $6e
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:59ca $26 $d8
    ld   L, [HL]                                      ;; 03:59cc $6e ; ENTITY_FIELD_ENTITY_ID
    ld   H, $00                                       ;; 03:59cd $26 $00
    add  HL, HL                                       ;; 03:59cf $29
    ld   DE, data_03_58d2_EntitySpriteDescriptors     ;; 03:59d0 $11 $d2 $58
    add  HL, DE                                       ;; 03:59d3 $19
    ld   A, [HL]                                      ;; 03:59d4 $7e
    and  A, SPRITE_DESC_IGNORE_FACING                 ;; 03:59d5 $e6 $80
    ret                                               ;; 03:59d7 $c9

call_03_59d8_Entity_SpriteDrawsFirst:
; NZ if the current entity's descriptor has SPRITE_DESC_DRAW_FIRST, which puts it in
; the pass BEFORE Gex so that he covers it. call_03_5ec1_OAM_BuildFrame calls this
; twice over the same eight slots, once with `call NZ` and once with `call Z`, which
; is how one flag becomes two passes
    ld   HL, wDA00_CurrentEntityAddrLo                ;; 03:59d8 $21 $00 $da
    ld   L, [HL]                                      ;; 03:59db $6e
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:59dc $26 $d8
    ld   L, [HL]                                      ;; 03:59de $6e ; ENTITY_FIELD_ENTITY_ID
    ld   H, $00                                       ;; 03:59df $26 $00
    add  HL, HL                                       ;; 03:59e1 $29
    ld   DE, data_03_58d2_EntitySpriteDescriptors     ;; 03:59e2 $11 $d2 $58
    add  HL, DE                                       ;; 03:59e5 $19
    ld   A, [HL]                                      ;; 03:59e6 $7e
    and  A, SPRITE_DESC_DRAW_FIRST                    ;; 03:59e7 $e6 $40
    ret                                               ;; 03:59e9 $c9

data_03_59ea_SpriteShapeTable:
; SPRITE_SHAPES_PER_ENTITY pointers per shape, so the index is
; (SPRITE_SHAPE_* * 4) + facing and each shape owns four consecutive rows.
;
; The facing number is built in call_03_5fc2_Entity_BuildSprites by swapping the
; entity's facing byte and keeping two bits, which puts ENTITY_FACING_LEFT in bit 0
; and ENTITY_FACING_VERTICAL_FLIP in bit 1:
;
;   +0  facing right          +1  facing left
;   +2  facing right, flipped +3  facing left, flipped
;
; No shape uses four different layouts. Almost all of them repeat rows 0 and 1 in
; rows 2 and 3 - so the vertical flip picks no layout of its own and only reaches OAM
; as an attribute bit - and a shape whose four rows are identical is one that does
; not mirror at all.
;
; SPRITE_SHAPE_8X128 is the one exception: its rows pair up as 0-1 and 2-3 instead,
; so the beam barrier ignores which way the entity faces and mirrors on the vertical
; flip. That is the only shape where bit 1 of the facing index changes the layout
    ; SPRITE_SHAPE_8X32 - ENTITY_UNK13
    dw   .shape_8x32
    dw   .shape_8x32_left
    dw   .shape_8x32
    dw   .shape_8x32_left
    ; SPRITE_SHAPE_16X32 - ENTITY_MYSTERY_TV_MAGIC_SWORD, ENTITY_TUT_TV_RA_STAFF, ENTITY_WESTERN_STATION_ROCK_PLATFORM
    dw   .shape_16x32
    dw   .shape_16x32_left
    dw   .shape_16x32
    dw   .shape_16x32_left
    ; SPRITE_SHAPE_24X32 - ENTITY_GREEN_FLY_TV, ENTITY_PURPLE_FLY_TV, ENTITY_UNK_FLY_TV_3 and 10 more
    dw   .shape_24x32
    dw   .shape_24x32_left
    dw   .shape_24x32
    dw   .shape_24x32_left
    ; SPRITE_SHAPE_32X32 - ENTITY_GEX, ENTITY_HOLIDAY_TV_SKATING_ELF, ENTITY_MYSTERY_TV_REZLING and 16 more
    dw   .shape_32x32
    dw   .shape_32x32_left
    dw   .shape_32x32
    dw   .shape_32x32_left
    ; SPRITE_SHAPE_8X16 - ENTITY_FLY_1, ENTITY_FLY_2, ENTITY_FLY_3 and 28 more
    dw   .shape_8x16
    dw   .shape_8x16_left
    dw   .shape_8x16
    dw   .shape_8x16_left
    ; SPRITE_SHAPE_16X16 - ENTITY_BONUS_COIN, ENTITY_FLY_COIN_SPAWN, ENTITY_PAW_COIN and 24 more
    dw   .shape_16x16
    dw   .shape_16x16_left
    dw   .shape_16x16
    dw   .shape_16x16_left
    ; SPRITE_SHAPE_24X16 - ENTITY_TUT_TV_RISING_PLATFORM, ENTITY_TUT_TV_SIDEWAYS_PLATFORM, ENTITY_WESTERN_STATION_RISING_PLATFORM
    dw   .shape_24x16
    dw   .shape_24x16_left
    dw   .shape_24x16
    dw   .shape_24x16_left
    ; SPRITE_SHAPE_32X16 - ENTITY_TUT_TV_RAFT, ENTITY_TUT_TV_BREAKABLE_BLOCK, ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR and 1 more
    dw   .shape_32x16
    dw   .shape_32x16_left
    dw   .shape_32x16
    dw   .shape_32x16_left
    ; SPRITE_SHAPE_64X48_BANK1 - ENTITY_HOLIDAY_TV_EVIL_SANTA
    dw   .shape_64x48_bank1
    dw   .shape_64x48_bank1
    dw   .shape_64x48_bank1
    dw   .shape_64x48_bank1
    ; SPRITE_SHAPE_8X128 - ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER, ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER
    dw   .shape_8x128
    dw   .shape_8x128
    dw   .shape_8x128_flipped
    dw   .shape_8x128_flipped
    ; SPRITE_SHAPE_32X64 - unused by any entity
    dw   .shape_32x64
    dw   .shape_32x64_left
    dw   .shape_32x64
    dw   .shape_32x64_left
    ; SPRITE_SHAPE_32X64_BANK1 - ENTITY_TUT_TV_COFFIN, ENTITY_WW_GEX_WRESTLING_ROCK_HARD
    dw   .shape_32x64_bank1
    dw   .shape_32x64_bank1_left
    dw   .shape_32x64_bank1
    dw   .shape_32x64_bank1_left
    ; SPRITE_SHAPE_16X48 - ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
    dw   .shape_16x48
    dw   .shape_16x48_left
    dw   .shape_16x48
    dw   .shape_16x48_left
    ; SPRITE_SHAPE_32X64_MIRRORED - ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
    dw   .shape_32x64_mirrored
    dw   .shape_32x64_mirrored
    dw   .shape_32x64_mirrored
    dw   .shape_32x64_mirrored
    ; SPRITE_SHAPE_32X48_BANK1 - ENTITY_WESTERN_STATION_ENEMY_CACTUS, ENTITY_WESTERN_STATION_CACTUS, ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
    dw   .shape_32x48_bank1
    dw   .shape_32x48_bank1_left
    dw   .shape_32x48_bank1
    dw   .shape_32x48_bank1_left
    ; SPRITE_SHAPE_48X48_BANK1 - ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    dw   .shape_48x48_bank1
    dw   .shape_48x48_bank1
    dw   .shape_48x48_bank1
    dw   .shape_48x48_bank1
    ; SPRITE_SHAPE_32X16_BANK1 - ENTITY_BONUS_STAGE_TIMER
    dw   .shape_32x16_bank1
    dw   .shape_32x16_bank1
    dw   .shape_32x16_bank1
    dw   .shape_32x16_bank1
    ; SPRITE_SHAPE_56X64_BANK1 - ENTITY_CHANNEL_Z_REZ
    dw   .shape_56x64_bank1
    dw   .shape_56x64_bank1
    dw   .shape_56x64_bank1
    dw   .shape_56x64_bank1

; ------------------------------------------------------------------
; The shapes themselves.
;
; A shape is a count byte followed by that many oam_piece records, each one an 8x16
; OBJ - the whole game runs in 8x16 sprite mode, which is why the tile numbers below
; step in twos and a piece is sixteen pixels tall.
;
; The offsets are relative to the entity's screen position, which
; call_03_5fc2_Entity_BuildSprites has already biased by OAM_X_BIAS and OAM_Y_BIAS,
; so they read as a rectangle drawn around the entity's own origin: the negative Y
; values put the artwork above that point and the negative X values to the left of
; it. Tile numbers are relative to the entity's tile base from the descriptor table,
; and the attribute bits here are OR'd with the entity's own - which carry its CGB
; palette and its facing flips - so a piece can only ADD to them.
;
; Most shapes are a plain grid: the first eight are 8, 16, 24 or 32 pixels wide by
; 16 or 32 tall, and account for a hundred of the hundred and fourteen entities. The
; rest are one-offs for particular bosses and scenery, and the interesting ones are
; SPRITE_SHAPE_8X128 - a column of eight pieces all drawing tile 0, which is how a
; beam barrier is one tile stretched down the screen - and
; SPRITE_SHAPE_32X64_MIRRORED, whose left half and right half are the same tiles
; with OAMF_XFLIP set, so it mirrors itself inside one shape rather than needing a
; left-facing twin
; ------------------------------------------------------------------
.shape_8x32:
    db   (.shape_8x32_end - .shape_8x32 - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,   -4, $00, 0
    oam_piece    0,   -4, $02, 0
.shape_8x32_end:
.shape_8x32_left:
    db   (.shape_8x32_left_end - .shape_8x32_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,   -4, $00, OAMF_XFLIP
    oam_piece    0,   -4, $02, OAMF_XFLIP
.shape_8x32_left_end:
.shape_16x32:
    db   (.shape_16x32_end - .shape_16x32 - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,   -8, $00, 0
    oam_piece  -16,    0, $04, 0
    oam_piece    0,   -8, $02, 0
    oam_piece    0,    0, $06, 0
.shape_16x32_end:
.shape_16x32_left:
    db   (.shape_16x32_left_end - .shape_16x32_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,    0, $00, OAMF_XFLIP
    oam_piece  -16,   -8, $04, OAMF_XFLIP
    oam_piece    0,    0, $02, OAMF_XFLIP
    oam_piece    0,   -8, $06, OAMF_XFLIP
.shape_16x32_left_end:
.shape_24x32:
    db   (.shape_24x32_end - .shape_24x32 - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,  -12, $00, 0
    oam_piece  -16,   -4, $04, 0
    oam_piece  -16,    4, $08, 0
    oam_piece    0,  -12, $02, 0
    oam_piece    0,   -4, $06, 0
    oam_piece    0,    4, $0a, 0
.shape_24x32_end:
.shape_24x32_left:
    db   (.shape_24x32_left_end - .shape_24x32_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,    4, $00, OAMF_XFLIP
    oam_piece  -16,   -4, $04, OAMF_XFLIP
    oam_piece  -16,  -12, $08, OAMF_XFLIP
    oam_piece    0,    4, $02, OAMF_XFLIP
    oam_piece    0,   -4, $06, OAMF_XFLIP
    oam_piece    0,  -12, $0a, OAMF_XFLIP
.shape_24x32_left_end:
.shape_32x32:
    db   (.shape_32x32_end - .shape_32x32 - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,  -16, $00, 0
    oam_piece  -16,   -8, $04, 0
    oam_piece  -16,    0, $08, 0
    oam_piece  -16,    8, $0c, 0
    oam_piece    0,  -16, $02, 0
    oam_piece    0,   -8, $06, 0
    oam_piece    0,    0, $0a, 0
    oam_piece    0,    8, $0e, 0
.shape_32x32_end:
.shape_32x32_left:
    db   (.shape_32x32_left_end - .shape_32x32_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -16,    8, $00, OAMF_XFLIP
    oam_piece  -16,    0, $04, OAMF_XFLIP
    oam_piece  -16,   -8, $08, OAMF_XFLIP
    oam_piece  -16,  -16, $0c, OAMF_XFLIP
    oam_piece    0,    8, $02, OAMF_XFLIP
    oam_piece    0,    0, $06, OAMF_XFLIP
    oam_piece    0,   -8, $0a, OAMF_XFLIP
    oam_piece    0,  -16, $0e, OAMF_XFLIP
.shape_32x32_left_end:
.shape_8x16:
    db   (.shape_8x16_end - .shape_8x16 - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,   -4, $00, 0
.shape_8x16_end:
.shape_8x16_left:
    db   (.shape_8x16_left_end - .shape_8x16_left - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,   -4, $00, OAMF_XFLIP
.shape_8x16_left_end:
.shape_16x16:
    db   (.shape_16x16_end - .shape_16x16 - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,   -8, $00, 0
    oam_piece   -8,    0, $02, 0
.shape_16x16_end:
.shape_16x16_left:
    db   (.shape_16x16_left_end - .shape_16x16_left - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,    0, $00, OAMF_XFLIP
    oam_piece   -8,   -8, $02, OAMF_XFLIP
.shape_16x16_left_end:
.shape_24x16:
    db   (.shape_24x16_end - .shape_24x16 - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,  -12, $00, 0
    oam_piece   -8,   -4, $02, 0
    oam_piece   -8,    4, $04, 0
.shape_24x16_end:
.shape_24x16_left:
    db   (.shape_24x16_left_end - .shape_24x16_left - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,    4, $00, OAMF_XFLIP
    oam_piece   -8,   -4, $02, OAMF_XFLIP
    oam_piece   -8,  -12, $04, OAMF_XFLIP
.shape_24x16_left_end:
.shape_32x16:
    db   (.shape_32x16_end - .shape_32x16 - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,  -16, $00, 0
    oam_piece   -8,   -8, $02, 0
    oam_piece   -8,    0, $04, 0
    oam_piece   -8,    8, $06, 0
.shape_32x16_end:
.shape_32x16_left:
    db   (.shape_32x16_left_end - .shape_32x16_left - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,    8, $00, OAMF_XFLIP
    oam_piece   -8,    0, $02, OAMF_XFLIP
    oam_piece   -8,   -8, $04, OAMF_XFLIP
    oam_piece   -8,  -16, $06, OAMF_XFLIP
.shape_32x16_left_end:
.shape_64x48_bank1:
    db   (.shape_64x48_bank1_end - .shape_64x48_bank1 - 1) / OAM_ENTRY_SIZE
    oam_piece  -24,  -32, $00, OAMF_BANK1
    oam_piece  -24,  -24, $06, OAMF_BANK1
    oam_piece  -24,  -16, $0c, OAMF_BANK1
    oam_piece  -24,   -8, $12, OAMF_BANK1
    oam_piece  -24,    0, $18, OAMF_BANK1
    oam_piece  -24,    8, $1e, OAMF_BANK1
    oam_piece  -24,   16, $24, OAMF_BANK1
    oam_piece  -24,   24, $2a, OAMF_BANK1
    oam_piece   -8,  -32, $02, OAMF_BANK1
    oam_piece   -8,  -24, $08, OAMF_BANK1
    oam_piece   -8,  -16, $0e, OAMF_BANK1
    oam_piece   -8,   -8, $14, OAMF_BANK1
    oam_piece   -8,    0, $1a, OAMF_BANK1
    oam_piece   -8,    8, $20, OAMF_BANK1
    oam_piece   -8,   16, $26, OAMF_BANK1
    oam_piece   -8,   24, $2c, OAMF_BANK1
    oam_piece    8,  -32, $04, OAMF_BANK1
    oam_piece    8,  -24, $0a, OAMF_BANK1
    oam_piece    8,  -16, $10, OAMF_BANK1
    oam_piece    8,   -8, $16, OAMF_BANK1
    oam_piece    8,    0, $1c, OAMF_BANK1
    oam_piece    8,    8, $22, OAMF_BANK1
    oam_piece    8,   16, $28, OAMF_BANK1
    oam_piece    8,   24, $2e, OAMF_BANK1
.shape_64x48_bank1_end:
.shape_8x128:
    db   (.shape_8x128_end - .shape_8x128 - 1) / OAM_ENTRY_SIZE
    oam_piece  -64,   -4, $00, 0
    oam_piece  -48,   -4, $00, 0
    oam_piece  -32,   -4, $00, 0
    oam_piece  -16,   -4, $00, 0
    oam_piece    0,   -4, $00, 0
    oam_piece   16,   -4, $00, 0
    oam_piece   32,   -4, $00, 0
    oam_piece   48,   -4, $00, 0
.shape_8x128_end:
.shape_8x128_flipped:
    db   (.shape_8x128_flipped_end - .shape_8x128_flipped - 1) / OAM_ENTRY_SIZE
    oam_piece  -64,   -4, $00, OAMF_XFLIP
    oam_piece  -48,   -4, $00, OAMF_XFLIP
    oam_piece  -32,   -4, $00, OAMF_XFLIP
    oam_piece  -16,   -4, $00, OAMF_XFLIP
    oam_piece    0,   -4, $00, OAMF_XFLIP
    oam_piece   16,   -4, $00, OAMF_XFLIP
    oam_piece   32,   -4, $00, OAMF_XFLIP
    oam_piece   48,   -4, $00, OAMF_XFLIP
.shape_8x128_flipped_end:
.shape_32x64:
    db   (.shape_32x64_end - .shape_32x64 - 1) / OAM_ENTRY_SIZE
    oam_piece  -32,  -16, $00, 0
    oam_piece  -32,   -8, $08, 0
    oam_piece  -32,    0, $10, 0
    oam_piece  -32,    8, $18, 0
    oam_piece  -16,  -16, $02, 0
    oam_piece  -16,   -8, $0a, 0
    oam_piece  -16,    0, $12, 0
    oam_piece  -16,    8, $1a, 0
    oam_piece    0,  -16, $04, 0
    oam_piece    0,   -8, $0c, 0
    oam_piece    0,    0, $14, 0
    oam_piece    0,    8, $1c, 0
    oam_piece   16,  -16, $06, 0
    oam_piece   16,   -8, $0e, 0
    oam_piece   16,    0, $16, 0
    oam_piece   16,    8, $1e, 0
.shape_32x64_end:
.shape_32x64_left:
    db   (.shape_32x64_left_end - .shape_32x64_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -32,    8, $00, OAMF_XFLIP
    oam_piece  -32,    0, $08, OAMF_XFLIP
    oam_piece  -32,   -8, $10, OAMF_XFLIP
    oam_piece  -32,  -16, $18, OAMF_XFLIP
    oam_piece  -16,    8, $02, OAMF_XFLIP
    oam_piece  -16,    0, $0a, OAMF_XFLIP
    oam_piece  -16,   -8, $12, OAMF_XFLIP
    oam_piece  -16,  -16, $1a, OAMF_XFLIP
    oam_piece    0,    8, $04, OAMF_XFLIP
    oam_piece    0,    0, $0c, OAMF_XFLIP
    oam_piece    0,   -8, $14, OAMF_XFLIP
    oam_piece    0,  -16, $1c, OAMF_XFLIP
    oam_piece   16,    8, $06, OAMF_XFLIP
    oam_piece   16,    0, $0e, OAMF_XFLIP
    oam_piece   16,   -8, $16, OAMF_XFLIP
    oam_piece   16,  -16, $1e, OAMF_XFLIP
.shape_32x64_left_end:
.shape_32x64_bank1:
    db   (.shape_32x64_bank1_end - .shape_32x64_bank1 - 1) / OAM_ENTRY_SIZE
    oam_piece  -32,  -16, $00, OAMF_BANK1
    oam_piece  -32,   -8, $08, OAMF_BANK1
    oam_piece  -32,    0, $10, OAMF_BANK1
    oam_piece  -32,    8, $18, OAMF_BANK1
    oam_piece  -16,  -16, $02, OAMF_BANK1
    oam_piece  -16,   -8, $0a, OAMF_BANK1
    oam_piece  -16,    0, $12, OAMF_BANK1
    oam_piece  -16,    8, $1a, OAMF_BANK1
    oam_piece    0,  -16, $04, OAMF_BANK1
    oam_piece    0,   -8, $0c, OAMF_BANK1
    oam_piece    0,    0, $14, OAMF_BANK1
    oam_piece    0,    8, $1c, OAMF_BANK1
    oam_piece   16,  -16, $06, OAMF_BANK1
    oam_piece   16,   -8, $0e, OAMF_BANK1
    oam_piece   16,    0, $16, OAMF_BANK1
    oam_piece   16,    8, $1e, OAMF_BANK1
.shape_32x64_bank1_end:
.shape_32x64_bank1_left:
    db   (.shape_32x64_bank1_left_end - .shape_32x64_bank1_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -32,    8, $00, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -32,    0, $08, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -32,   -8, $10, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -32,  -16, $18, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -16,    8, $02, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -16,    0, $0a, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -16,   -8, $12, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -16,  -16, $1a, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    0,    8, $04, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    0,    0, $0c, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    0,   -8, $14, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    0,  -16, $1c, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   16,    8, $06, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   16,    0, $0e, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   16,   -8, $16, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   16,  -16, $1e, OAMF_BANK1 | OAMF_XFLIP
.shape_32x64_bank1_left_end:
.shape_16x48:
    db   (.shape_16x48_end - .shape_16x48 - 1) / OAM_ENTRY_SIZE
    oam_piece  -24,   -8, $00, 0
    oam_piece  -24,    0, $06, 0
    oam_piece   -8,   -8, $02, 0
    oam_piece   -8,    0, $08, 0
    oam_piece    8,   -8, $04, 0
    oam_piece    8,    0, $0a, 0
.shape_16x48_end:
.shape_16x48_left:
    db   (.shape_16x48_left_end - .shape_16x48_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -24,    0, $00, OAMF_XFLIP
    oam_piece  -24,   -8, $06, OAMF_XFLIP
    oam_piece   -8,    0, $02, OAMF_XFLIP
    oam_piece   -8,   -8, $08, OAMF_XFLIP
    oam_piece    8,    0, $04, OAMF_XFLIP
    oam_piece    8,   -8, $0a, OAMF_XFLIP
.shape_16x48_left_end:
.shape_32x64_mirrored:
    db   (.shape_32x64_mirrored_end - .shape_32x64_mirrored - 1) / OAM_ENTRY_SIZE
    oam_piece  -32,  -16, $00, 0
    oam_piece  -32,   -8, $08, 0
    oam_piece  -32,    0, $08, OAMF_XFLIP
    oam_piece  -32,    8, $00, OAMF_XFLIP
    oam_piece  -16,  -16, $02, 0
    oam_piece  -16,   -8, $0a, 0
    oam_piece  -16,    0, $0a, OAMF_XFLIP
    oam_piece  -16,    8, $02, OAMF_XFLIP
    oam_piece    0,  -16, $04, 0
    oam_piece    0,   -8, $0c, 0
    oam_piece    0,    0, $0c, OAMF_XFLIP
    oam_piece    0,    8, $04, OAMF_XFLIP
    oam_piece   16,  -16, $06, 0
    oam_piece   16,   -8, $0e, 0
    oam_piece   16,    0, $0e, OAMF_XFLIP
    oam_piece   16,    8, $06, OAMF_XFLIP
.shape_32x64_mirrored_end:
.shape_32x48_bank1:
    db   (.shape_32x48_bank1_end - .shape_32x48_bank1 - 1) / OAM_ENTRY_SIZE
    oam_piece  -24,  -16, $00, OAMF_BANK1
    oam_piece  -24,   -8, $06, OAMF_BANK1
    oam_piece  -24,    0, $0c, OAMF_BANK1
    oam_piece  -24,    8, $12, OAMF_BANK1
    oam_piece   -8,  -16, $02, OAMF_BANK1
    oam_piece   -8,   -8, $08, OAMF_BANK1
    oam_piece   -8,    0, $0e, OAMF_BANK1
    oam_piece   -8,    8, $14, OAMF_BANK1
    oam_piece    8,  -16, $04, OAMF_BANK1
    oam_piece    8,   -8, $0a, OAMF_BANK1
    oam_piece    8,    0, $10, OAMF_BANK1
    oam_piece    8,    8, $16, OAMF_BANK1
.shape_32x48_bank1_end:
.shape_32x48_bank1_left:
    db   (.shape_32x48_bank1_left_end - .shape_32x48_bank1_left - 1) / OAM_ENTRY_SIZE
    oam_piece  -24,    8, $00, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -24,    0, $06, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -24,   -8, $0c, OAMF_BANK1 | OAMF_XFLIP
    oam_piece  -24,  -16, $12, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   -8,    8, $02, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   -8,    0, $08, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   -8,   -8, $0e, OAMF_BANK1 | OAMF_XFLIP
    oam_piece   -8,  -16, $14, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    8,    8, $04, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    8,    0, $0a, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    8,   -8, $10, OAMF_BANK1 | OAMF_XFLIP
    oam_piece    8,  -16, $16, OAMF_BANK1 | OAMF_XFLIP
.shape_32x48_bank1_left_end:
.shape_48x48_bank1:
    db   (.shape_48x48_bank1_end - .shape_48x48_bank1 - 1) / OAM_ENTRY_SIZE
    oam_piece  -24,  -24, $00, OAMF_BANK1
    oam_piece  -24,  -16, $06, OAMF_BANK1
    oam_piece  -24,   -8, $0c, OAMF_BANK1
    oam_piece  -24,    0, $12, OAMF_BANK1
    oam_piece  -24,    8, $18, OAMF_BANK1
    oam_piece  -24,   16, $1e, OAMF_BANK1
    oam_piece   -8,  -24, $02, OAMF_BANK1
    oam_piece   -8,  -16, $08, OAMF_BANK1
    oam_piece   -8,   -8, $0e, OAMF_BANK1
    oam_piece   -8,    0, $14, OAMF_BANK1
    oam_piece   -8,    8, $1a, OAMF_BANK1
    oam_piece   -8,   16, $20, OAMF_BANK1
    oam_piece    8,  -24, $04, OAMF_BANK1
    oam_piece    8,  -16, $0a, OAMF_BANK1
    oam_piece    8,   -8, $10, OAMF_BANK1
    oam_piece    8,    0, $16, OAMF_BANK1
    oam_piece    8,    8, $1c, OAMF_BANK1
    oam_piece    8,   16, $22, OAMF_BANK1
.shape_48x48_bank1_end:
.shape_32x16_bank1:
    db   (.shape_32x16_bank1_end - .shape_32x16_bank1 - 1) / OAM_ENTRY_SIZE
    oam_piece   -8,  -16, $00, OAMF_BANK1
    oam_piece   -8,   -8, $02, OAMF_BANK1
    oam_piece   -8,    0, $04, OAMF_BANK1
    oam_piece   -8,    8, $06, OAMF_BANK1
.shape_32x16_bank1_end:
.shape_56x64_bank1:
    db   (.shape_56x64_bank1_end - .shape_56x64_bank1 - 1) / OAM_ENTRY_SIZE
    oam_piece  -32,  -28, $00, OAMF_BANK1
    oam_piece  -32,  -20, $08, OAMF_BANK1
    oam_piece  -32,  -12, $10, OAMF_BANK1
    oam_piece  -32,   -4, $18, OAMF_BANK1
    oam_piece  -32,    4, $20, OAMF_BANK1
    oam_piece  -32,   12, $28, OAMF_BANK1
    oam_piece  -32,   20, $30, OAMF_BANK1
    oam_piece  -16,  -28, $02, OAMF_BANK1
    oam_piece  -16,  -20, $0a, OAMF_BANK1
    oam_piece  -16,  -12, $12, OAMF_BANK1
    oam_piece  -16,   -4, $1a, OAMF_BANK1
    oam_piece  -16,    4, $22, OAMF_BANK1
    oam_piece  -16,   12, $2a, OAMF_BANK1
    oam_piece  -16,   20, $32, OAMF_BANK1
    oam_piece    0,  -28, $04, OAMF_BANK1
    oam_piece    0,  -20, $0c, OAMF_BANK1
    oam_piece    0,  -12, $14, OAMF_BANK1
    oam_piece    0,   -4, $1c, OAMF_BANK1
    oam_piece    0,    4, $24, OAMF_BANK1
    oam_piece    0,   12, $2c, OAMF_BANK1
    oam_piece    0,   20, $34, OAMF_BANK1
    oam_piece   16,  -28, $06, OAMF_BANK1
    oam_piece   16,  -20, $0e, OAMF_BANK1
    oam_piece   16,  -12, $16, OAMF_BANK1
    oam_piece   16,   -4, $1e, OAMF_BANK1
    oam_piece   16,    4, $26, OAMF_BANK1
    oam_piece   16,   12, $2e, OAMF_BANK1
    oam_piece   16,   20, $36, OAMF_BANK1
.shape_56x64_bank1_end:

call_03_5ec1_OAM_BuildFrame:
; The frame's whole sprite pass, and the collision pass on the end of it.
;
; Seeds wDC6F_Oam_WriteOffset to OAM_ENTITY_FIRST_BYTE - Gex's two entries sit
; below it - and then takes one of two routes.
;
; The ordinary route is three sweeps of the eight slots: the entities flagged
; SPRITE_DESC_DRAW_FIRST, then Gex through call_00_2ce2_Player_BuildSprites, then
; everything else. Slot order within a sweep, so nothing is sorted.
;
; The top-down route (.jr_03_5f35, taken when the map's collision type is
; BG_COLLISION_TYPE_TOPDOWN and it is not one of the two MAP_MYSTERY_TV rooms that
; opt out) collects the live slot bases into wDC44_Oam_DrawOrderBuffer, bubble-sorts
; them by Y with wDC4C_Oam_SortSwapped as the "keep going" flag, and then draws in
; that order - so an entity lower down the screen is written later and appears in
; front. Slot 0 in that buffer means Gex, who is sorted along with everyone else.
;
; Both routes join at .jp_03_5f17: collectibles, blank the unused OAM entries, and
; then one more sweep running call_03_4c38_UpdateEntityCollision_Dispatch per slot.
; Collision last, after every position for the frame is settled
    ld   A, OAM_ENTITY_FIRST_BYTE                     ;; 03:5ec1 $3e $08
    ld   [wDC6F_Oam_WriteOffset], A                   ;; 03:5ec3 $ea $6f $dc
    ld   A, [wDC1F_CurrentBgCollisionType]            ;; 03:5ec6 $fa $1f $dc
    cp   A, BG_COLLISION_TYPE_TOPDOWN                 ;; 03:5ec9 $fe $01
    jr   NZ, .jr_03_5ed8                              ;; 03:5ecb $20 $0b
    ld   A, [wDB6C_CurrentMapId]                      ;; 03:5ecd $fa $6c $db
    cp   A, MAP_MYSTERY_TV8                           ;; 03:5ed0 $fe $18
    jr   Z, .jr_03_5ed8                               ;; 03:5ed2 $28 $04
    cp   A, MAP_MYSTERY_TV10                          ;; 03:5ed4 $fe $1a
    jr   NZ, .jr_03_5f35                              ;; 03:5ed6 $20 $5d
.jr_03_5ed8:
    ld   A, LOW(wD820_EntityMemoryAfterPlayer)        ;; 03:5ed8 $3e $20
.jr_03_5eda:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 03:5eda $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 03:5edd $f6 $00
    ld   L, A                                         ;; 03:5edf $6f
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:5ee0 $26 $d8
    ld   A, [HL]                                      ;; 03:5ee2 $7e
    cp   A, ENTITY_ID_NONE                            ;; 03:5ee3 $fe $ff
    jr   Z, .jr_03_5eed                               ;; 03:5ee5 $28 $06
    call call_03_59d8_Entity_SpriteDrawsFirst         ;; 03:5ee7 $cd $d8 $59
    call NZ, call_03_5fc2_Entity_BuildSprites         ;; 03:5eea $c4 $c2 $5f
.jr_03_5eed:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:5eed $fa $00 $da
    add  A, ENTITY_SLOT_SIZE                          ;; 03:5ef0 $c6 $20
    jr   NZ, .jr_03_5eda                              ;; 03:5ef2 $20 $e6
    ld   A, [wDCA7_Player_UpdateFlag]                 ;; 03:5ef4 $fa $a7 $dc
    and  A, A                                         ;; 03:5ef7 $a7
    call NZ, call_00_2ce2_Player_BuildSprites              ;; 03:5ef8 $c4 $e2 $2c
    ld   A, LOW(wD820_EntityMemoryAfterPlayer)        ;; 03:5efb $3e $20
.jr_03_5efd:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 03:5efd $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 03:5f00 $f6 $00
    ld   L, A                                         ;; 03:5f02 $6f
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:5f03 $26 $d8
    ld   A, [HL]                                      ;; 03:5f05 $7e
    cp   A, ENTITY_ID_NONE                            ;; 03:5f06 $fe $ff
    jr   Z, .jr_03_5f10                               ;; 03:5f08 $28 $06
    call call_03_59d8_Entity_SpriteDrawsFirst         ;; 03:5f0a $cd $d8 $59
    call Z, call_03_5fc2_Entity_BuildSprites          ;; 03:5f0d $cc $c2 $5f
.jr_03_5f10:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:5f10 $fa $00 $da
    add  A, ENTITY_SLOT_SIZE                          ;; 03:5f13 $c6 $20
    jr   NZ, .jr_03_5efd                              ;; 03:5f15 $20 $e6
.jp_03_5f17:
    call call_03_615d_Collectible_BuildSprites        ;; 03:5f17 $cd $5d $61
    call call_03_6148_OAM_ClearUnusedEntries          ;; 03:5f1a $cd $48 $61
    ld   A, LOW(wD820_EntityMemoryAfterPlayer)        ;; 03:5f1d $3e $20
.jr_03_5f1f:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 03:5f1f $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 03:5f22 $f6 $00
    ld   L, A                                         ;; 03:5f24 $6f
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:5f25 $26 $d8
    ld   A, [HL]                                      ;; 03:5f27 $7e
    cp   A, ENTITY_ID_NONE                            ;; 03:5f28 $fe $ff
    call NZ, call_03_4c38_UpdateEntityCollision_Dispatch ;; 03:5f2a $c4 $38 $4c
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:5f2d $fa $00 $da
    add  A, ENTITY_SLOT_SIZE                          ;; 03:5f30 $c6 $20
    jr   NZ, .jr_03_5f1f                              ;; 03:5f32 $20 $eb
    ret                                               ;; 03:5f34 $c9
.jr_03_5f35:
    ld   HL, wDC44_Oam_DrawOrderBuffer                ;; 03:5f35 $21 $44 $dc
    ld   D, HIGH(wD800_EntityMemory)                  ;; 03:5f38 $16 $d8
    ld   B, $00                                       ;; 03:5f3a $06 $00
    ld   A, $00                                       ;; 03:5f3c $3e $00
.jr_03_5f3e:
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 03:5f3e $f6 $00
    ld   E, A                                         ;; 03:5f40 $5f
    ld   A, [DE]                                      ;; 03:5f41 $1a
    cp   A, ENTITY_ID_NONE                            ;; 03:5f42 $fe $ff
    jr   Z, .jr_03_5f4b                               ;; 03:5f44 $28 $05
    ld   A, E                                         ;; 03:5f46 $7b
    and  A, ENTITY_SLOT_BASE_MASK                     ;; 03:5f47 $e6 $e0
    ld   [HL+], A                                     ;; 03:5f49 $22
    inc  B                                            ;; 03:5f4a $04
.jr_03_5f4b:
    ld   A, E                                         ;; 03:5f4b $7b
    and  A, ENTITY_SLOT_BASE_MASK                     ;; 03:5f4c $e6 $e0
    add  A, ENTITY_SLOT_SIZE                          ;; 03:5f4e $c6 $20
    jr   NZ, .jr_03_5f3e                              ;; 03:5f50 $20 $ec
    ld   A, B                                         ;; 03:5f52 $78
    ld   [wDC4D_Oam_DrawOrderCount], A                ;; 03:5f53 $ea $4d $dc
    dec  B                                            ;; 03:5f56 $05
    jr   Z, .jr_03_5f90                               ;; 03:5f57 $28 $37
    bit  7, B                                         ;; 03:5f59 $cb $78
    jr   NZ, .jr_03_5f90                              ;; 03:5f5b $20 $33
.jr_03_5f5d:
    xor  A, A                                         ;; 03:5f5d $af
    ld   [wDC4C_Oam_SortSwapped], A                   ;; 03:5f5e $ea $4c $dc
    ld   HL, wDC44_Oam_DrawOrderBuffer                ;; 03:5f61 $21 $44 $dc
    ld   D, HIGH(wD800_EntityMemory)                  ;; 03:5f64 $16 $d8
    push BC                                           ;; 03:5f66 $c5
.jr_03_5f67:
    push HL                                           ;; 03:5f67 $e5
    ld   A, [HL+]                                     ;; 03:5f68 $2a
    or   A, ENTITY_FIELD_WORLD_Y                         ;; 03:5f69 $f6 $10
    ld   E, A                                         ;; 03:5f6b $5f
    ld   A, [HL]                                      ;; 03:5f6c $7e
    or   A, ENTITY_FIELD_WORLD_Y                         ;; 03:5f6d $f6 $10
    ld   L, A                                         ;; 03:5f6f $6f
    ld   H, D                                         ;; 03:5f70 $62
    ld   A, [DE]                                      ;; 03:5f71 $1a
    sub  A, [HL]                                      ;; 03:5f72 $96
    inc  DE                                           ;; 03:5f73 $13
    inc  HL                                           ;; 03:5f74 $23
    ld   A, [DE]                                      ;; 03:5f75 $1a
    sbc  A, [HL]                                      ;; 03:5f76 $9e
    jr   NC, .jr_03_5f84                              ;; 03:5f77 $30 $0b
    pop  HL                                           ;; 03:5f79 $e1
    push HL                                           ;; 03:5f7a $e5
    ld   A, [HL+]                                     ;; 03:5f7b $2a
    ld   E, [HL]                                      ;; 03:5f7c $5e
    ld   [HL-], A                                     ;; 03:5f7d $32
    ld   [HL], E                                      ;; 03:5f7e $73
    ld   A, $01                                       ;; 03:5f7f $3e $01
    ld   [wDC4C_Oam_SortSwapped], A                   ;; 03:5f81 $ea $4c $dc
.jr_03_5f84:
    pop  HL                                           ;; 03:5f84 $e1
    inc  HL                                           ;; 03:5f85 $23
    dec  B                                            ;; 03:5f86 $05
    jr   NZ, .jr_03_5f67                              ;; 03:5f87 $20 $de
    pop  BC                                           ;; 03:5f89 $c1
    ld   A, [wDC4C_Oam_SortSwapped]                   ;; 03:5f8a $fa $4c $dc
    and  A, A                                         ;; 03:5f8d $a7
    jr   NZ, .jr_03_5f5d                              ;; 03:5f8e $20 $cd
.jr_03_5f90:
    ld   HL, wDC4D_Oam_DrawOrderCount                 ;; 03:5f90 $21 $4d $dc
    ld   B, [HL]                                      ;; 03:5f93 $46
    inc  B                                            ;; 03:5f94 $04
    dec  B                                            ;; 03:5f95 $05
    jp   Z, .jp_03_5f17                               ;; 03:5f96 $ca $17 $5f
    ld   HL, wDC44_Oam_DrawOrderBuffer                ;; 03:5f99 $21 $44 $dc
.jr_03_5f9c:
    push BC                                           ;; 03:5f9c $c5
    push HL                                           ;; 03:5f9d $e5
    ld   A, [HL]                                      ;; 03:5f9e $7e
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 03:5f9f $ea $00 $da
    and  A, A                                         ;; 03:5fa2 $a7
    jr   Z, .jr_03_5fb2                               ;; 03:5fa3 $28 $0d
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 03:5fa5 $f6 $00
    ld   L, A                                         ;; 03:5fa7 $6f
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:5fa8 $26 $d8
    ld   A, [HL]                                      ;; 03:5faa $7e
    cp   A, ENTITY_ID_NONE                            ;; 03:5fab $fe $ff
    call NZ, call_03_5fc2_Entity_BuildSprites         ;; 03:5fad $c4 $c2 $5f
    jr   .jr_03_5fb9                                  ;; 03:5fb0 $18 $07
.jr_03_5fb2:
    ld   A, [wDCA7_Player_UpdateFlag]                 ;; 03:5fb2 $fa $a7 $dc
    and  A, A                                         ;; 03:5fb5 $a7
    call NZ, call_00_2ce2_Player_BuildSprites              ;; 03:5fb6 $c4 $e2 $2c
.jr_03_5fb9:
    pop  HL                                           ;; 03:5fb9 $e1
    pop  BC                                           ;; 03:5fba $c1
    inc  HL                                           ;; 03:5fbb $23
    dec  B                                            ;; 03:5fbc $05
    jr   NZ, .jr_03_5f9c                              ;; 03:5fbd $20 $dd
    jp   .jp_03_5f17                                  ;; 03:5fbf $c3 $17 $5f

call_03_5fc2_Entity_BuildSprites:
; Draws one entity, and decides on the way whether it should still exist.
;
; The attribute byte is built first - the slot's palette from
; wDAAE_EntityPaletteIds OR'd with the entity's facing byte, whose bits double as
; the OAM flip bits - and kept in wDAB6_Oam_Attributes for the copy loop.
;
; Then the cull, which is two 16-bit compares done high-byte-first and is easy to
; misread. An entity whose distance from the camera has a nonzero high byte is off
; screen; one with a high byte of $00 has to be inside OAM_CULL_X_RIGHT, and one
; with $FF (just off the left) inside OAM_CULL_X_LEFT. A failure does not just skip
; drawing: it zeroes the slot's wDA9C_EntityScreenPos and then asks
; call_00_2a15_Entity_CheckIfOnScreen whether the entity's whole patrol box has left
; the camera, and frees the slot if it has. That is the despawn, and it is here
; rather than in the update because this is where the screen position is known.
;
; Surviving that, a damaged entity (nonzero cooldown timer) is drawn only on frames
; where the vblank counter passes OAM_DAMAGE_FLASH_MASK - the hit flash. The screen
; position is biased by OAM_X_BIAS and OAM_Y_BIAS and stored, and then bit 0 of the
; entity's collision type says "invisible", bit 6 diverts to
; call_03_60e6_Particle_BuildSprites, and bit 5 picks whether the tile base is a
; fixed $40 or the slot's own VRAM page.
;
; The copy loop itself is the last dozen lines: count byte, then Y+B, X+C,
; tile+wDC70_Oam_TileBase, attributes OR wDAB6_Oam_Attributes, stopping early if the
; cursor reaches OAM_FULL. gex2's call_03_5ebf_Entity_BuildSprites
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:5fc2 $fa $00 $da
    rlca                                              ;; 03:5fc5 $07
    rlca                                              ;; 03:5fc6 $07
    rlca                                              ;; 03:5fc7 $07
    and  A, $07                                       ;; 03:5fc8 $e6 $07
    ld   L, A                                         ;; 03:5fca $6f
    ld   H, $00                                       ;; 03:5fcb $26 $00
    ld   DE, wDAAE_EntityPaletteIds                   ;; 03:5fcd $11 $ae $da
    add  HL, DE                                       ;; 03:5fd0 $19
    ld   E, [HL]                                      ;; 03:5fd1 $5e
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION ;; 03:5fd9 $6f
    ld   A, [HL]                                      ;; 03:5fda $7e
    or   A, E                                         ;; 03:5fdb $b3
    ld   [wDAB6_Oam_Attributes], A                    ;; 03:5fdc $ea $b6 $da
    LOAD_OBJ_FIELD_TO_DE ENTITY_FIELD_WORLD_X
    ld   HL, wDBF9_XPositionInMap                     ;; 03:5fe7 $21 $f9 $db
    ld   A, [DE]                                      ;; 03:5fea $1a
    sub  A, [HL]                                      ;; 03:5feb $96
    ld   C, A                                         ;; 03:5fec $4f
    inc  HL                                           ;; 03:5fed $23
    inc  DE                                           ;; 03:5fee $13
    ld   A, [DE]                                      ;; 03:5fef $1a
    sbc  A, [HL]                                      ;; 03:5ff0 $9e
    jr   C, .jr_03_5ffd                               ;; 03:5ff1 $38 $0a
    and  A, A                                         ;; 03:5ff3 $a7
    jr   NZ, .jr_03_6026                              ;; 03:5ff4 $20 $30
    ld   A, C                                         ;; 03:5ff6 $79
    cp   A, OAM_CULL_X_RIGHT                          ;; 03:5ff7 $fe $b8
    jr   C, .jr_03_6006                               ;; 03:5ff9 $38 $0b
    jr   .jr_03_6026                                  ;; 03:5ffb $18 $29
.jr_03_5ffd:
    cp   A, $ff                                       ;; 03:5ffd $fe $ff
    jr   NZ, .jr_03_6026                              ;; 03:5fff $20 $25
    ld   A, C                                         ;; 03:6001 $79
    cp   A, OAM_CULL_X_LEFT                           ;; 03:6002 $fe $d8
    jr   C, .jr_03_6026                               ;; 03:6004 $38 $20
.jr_03_6006:
    inc  E                                            ;; 03:6006 $1c
    ld   HL, wDBFB_YPositionInMap                     ;; 03:6007 $21 $fb $db
    ld   A, [DE]                                      ;; 03:600a $1a
    sub  A, [HL]                                      ;; 03:600b $96
    ld   B, A                                         ;; 03:600c $47
    inc  HL                                           ;; 03:600d $23
    inc  DE                                           ;; 03:600e $13
    ld   A, [DE]                                      ;; 03:600f $1a
    sbc  A, [HL]                                      ;; 03:6010 $9e
    jr   C, .jr_03_601d                               ;; 03:6011 $38 $0a
    and  A, A                                         ;; 03:6013 $a7
    jr   NZ, .jr_03_6026                              ;; 03:6014 $20 $10
    ld   A, B                                         ;; 03:6016 $78
    cp   A, OAM_CULL_Y                                ;; 03:6017 $fe $f0
    jr   NC, .jr_03_6026                              ;; 03:6019 $30 $0b
    jr   .jr_03_603e                                  ;; 03:601b $18 $21
.jr_03_601d:
    cp   A, $ff                                       ;; 03:601d $fe $ff
    jr   NZ, .jr_03_6026                              ;; 03:601f $20 $05
    ld   A, B                                         ;; 03:6021 $78
    cp   A, OAM_CULL_Y                                ;; 03:6022 $fe $f0
    jr   NC, .jr_03_603e                              ;; 03:6024 $30 $18
.jr_03_6026:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:6026 $fa $00 $da
    swap A                                            ;; 03:6029 $cb $37
    and  A, ENTITY_SCREEN_POS_INDEX_MASK              ;; 03:602b $e6 $0e
    ld   L, A                                         ;; 03:602d $6f
    ld   H, $00                                       ;; 03:602e $26 $00
    ld   BC, wDA9C_EntityScreenPos                    ;; 03:6030 $01 $9c $da
    add  HL, BC                                       ;; 03:6033 $09
    xor  A, A                                         ;; 03:6034 $af
    ld   [HL+], A                                     ;; 03:6035 $22
    ld   [HL], A                                      ;; 03:6036 $77
    call call_00_2a15_Entity_CheckIfOnScreen          ;; 03:6037 $cd $15 $2a
    call C, call_00_2b5d_Entity_ClearSlot             ;; 03:603a $dc $5d $2b
    ret                                               ;; 03:603d $c9
.jr_03_603e:
    LOAD_OBJ_FIELD_TO_HL_ALT ENTITY_FIELD_COOLDOWN_TIMER
    ld   A, [HL]                                      ;; 03:6046 $7e
    and  A, A                                         ;; 03:6047 $a7
    jr   Z, .jr_03_6050                               ;; 03:6048 $28 $06
    ld   A, [wDC71_VBlankFrameCounter]                ;; 03:604a $fa $71 $dc
    and  A, OAM_DAMAGE_FLASH_MASK                     ;; 03:604d $e6 $07
    ret  NZ                                           ;; 03:604f $c0
.jr_03_6050:
    push BC                                           ;; 03:6050 $c5
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:6051 $fa $00 $da
    swap A                                            ;; 03:6054 $cb $37
    and  A, ENTITY_SCREEN_POS_INDEX_MASK              ;; 03:6056 $e6 $0e
    ld   L, A                                         ;; 03:6058 $6f
    ld   H, $00                                       ;; 03:6059 $26 $00
    ld   BC, wDA9C_EntityScreenPos                    ;; 03:605b $01 $9c $da
    add  HL, BC                                       ;; 03:605e $09
    pop  BC                                           ;; 03:605f $c1
    ld   A, C                                         ;; 03:6060 $79
    add  A, OAM_X_BIAS                                ;; 03:6061 $c6 $08
    ld   C, A                                         ;; 03:6063 $4f
    ld   [HL+], A                                     ;; 03:6064 $22
    ld   A, B                                         ;; 03:6065 $78
    add  A, OAM_Y_BIAS                                ;; 03:6066 $c6 $10
    ld   B, A                                         ;; 03:6068 $47
    ld   [HL], A                                      ;; 03:6069 $77
    ld   A, E                                         ;; 03:606a $7b
    xor  A, $14                                       ;; 03:606b $ee $14
    ld   E, A                                         ;; 03:606d $5f
    ld   A, [DE]                                      ;; 03:606e $1a
    bit  0, A                                         ;; 03:606f $cb $47
    ret  NZ                                           ;; 03:6071 $c0
    bit  6, A                                         ;; 03:6072 $cb $77
    jp   NZ, call_03_60e6_Particle_BuildSprites       ;; 03:6074 $c2 $e6 $60
    bit  5, A                                         ;; 03:6077 $cb $6f
    ld   A, $40                                       ;; 03:6079 $3e $40
    jr   NZ, .jr_03_6083                              ;; 03:607b $20 $06
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:607d $fa $00 $da
    rrca                                              ;; 03:6080 $0f
    and  A, $70                                       ;; 03:6081 $e6 $70
.jr_03_6083:
    ld   [wDC70_Oam_TileBase], A                      ;; 03:6083 $ea $70 $dc
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_FACING_DIRECTION
    ld   A, [HL]                                      ;; 03:608e $7e
    swap A                                            ;; 03:608f $cb $37
    rrca                                              ;; 03:6091 $0f
    and  A, SPRITE_FACING_MASK                        ;; 03:6092 $e6 $03
    push AF                                           ;; 03:6094 $f5
    ld   A, L                                         ;; 03:6095 $7d
    xor  A, $0d                                       ;; 03:6096 $ee $0d
    ld   L, A                                         ;; 03:6098 $6f
    ld   L, [HL]                                      ;; 03:6099 $6e
    ld   H, $00                                       ;; 03:609a $26 $00
    add  HL, HL                                       ;; 03:609c $29
    ld   DE, data_03_58d2_EntitySpriteDescriptors     ;; 03:609d $11 $d2 $58
    add  HL, DE                                       ;; 03:60a0 $19
    ld   A, [HL]                                      ;; 03:60a1 $7e
    and  A, SPRITE_DESC_SHAPE_MASK                    ;; 03:60a2 $e6 $3f
    add  A, A                                         ;; 03:60a4 $87
    add  A, A                                         ;; 03:60a5 $87
    ld   E, A                                         ;; 03:60a6 $5f
    pop  AF                                           ;; 03:60a7 $f1
    add  A, E                                         ;; 03:60a8 $83
    bit  SPRITE_DESC_IGNORE_FACING_BIT, [HL]          ;; 03:60a9 $cb $7e
    jr   Z, .jr_03_60b4                               ;; 03:60ab $28 $07
    and  A, $fe                                       ;; 03:60ad $e6 $fe
    ld   HL, wDAB6_Oam_Attributes                     ;; 03:60af $21 $b6 $da
    res  5, [HL]                                      ;; 03:60b2 $cb $ae
.jr_03_60b4:
    ld   DE, data_03_59ea_SpriteShapeTable            ;; 03:60b4 $11 $ea $59
    call call_00_0777_GetPointerFromTable             ;; 03:60b7 $cd $77 $07
    ld   A, [wDC6F_Oam_WriteOffset]                   ;; 03:60ba $fa $6f $dc
    ld   E, A                                         ;; 03:60bd $5f
    ld   D, $d9                                       ;; 03:60be $16 $d9
    ld   A, [HL+]                                     ;; 03:60c0 $2a
.jr_03_60c1:
    push AF                                           ;; 03:60c1 $f5
    ld   A, E                                         ;; 03:60c2 $7b
    cp   A, OAM_FULL                                  ;; 03:60c3 $fe $a0
    jr   NC, .jr_03_60dd                              ;; 03:60c5 $30 $16
    ld   A, [HL+]                                     ;; 03:60c7 $2a
    add  A, B                                         ;; 03:60c8 $80
    ld   [DE], A                                      ;; 03:60c9 $12
    inc  E                                            ;; 03:60ca $1c
    ld   A, [HL+]                                     ;; 03:60cb $2a
    add  A, C                                         ;; 03:60cc $81
    ld   [DE], A                                      ;; 03:60cd $12
    inc  E                                            ;; 03:60ce $1c
    ld   A, [wDC70_Oam_TileBase]                      ;; 03:60cf $fa $70 $dc
    add  A, [HL]                                      ;; 03:60d2 $86
    ld   [DE], A                                      ;; 03:60d3 $12
    inc  HL                                           ;; 03:60d4 $23
    inc  E                                            ;; 03:60d5 $1c
    ld   A, [wDAB6_Oam_Attributes]                    ;; 03:60d6 $fa $b6 $da
    or   A, [HL]                                      ;; 03:60d9 $b6
    ld   [DE], A                                      ;; 03:60da $12
    inc  HL                                           ;; 03:60db $23
    inc  E                                            ;; 03:60dc $1c
.jr_03_60dd:
    pop  AF                                           ;; 03:60dd $f1
    dec  A                                            ;; 03:60de $3d
    jr   NZ, .jr_03_60c1                              ;; 03:60df $20 $e0
    ld   A, E                                         ;; 03:60e1 $7b
    ld   [wDC6F_Oam_WriteOffset], A                   ;; 03:60e2 $ea $6f $dc
    ret                                               ;; 03:60e5 $c9

call_03_60e6_Particle_BuildSprites:
; The burst effect, which is drawn from its own buffer rather than from a shape.
;
; call_00_2c53_Particle_GetSlotPtr gives the slot's particle buffer; its first byte
; is the burst's remaining life, clamped to PARTICLE_AGE_CLAMP and shifted down
; three places into an index for .data_03_6140_ParticleTileByAge. That yields one
; tile id for the whole burst, so all PARTICLE_SPRITE_COUNT sprites change together
; as it ages.
;
; The three sprites are then read out of the buffer's x/y triples. Note the three
; consecutive `ld a,[hl+]` in each pair: only the third value is used, so the loop is
; walking past two bytes of subpixel accumulator to reach the whole-pixel position -
; the same layout call_00_2c89_Particle_UpdateBurst maintains.
;
; gex2 spreads the same job over six routines in bank03_particle_sprites.asm, one
; per effect. If this file is split, this routine and its table are the piece that
; corresponds
    call call_00_2c53_Particle_GetSlotPtr             ;; 03:60e6 $cd $53 $2c
    ld   L, E                                         ;; 03:60e9 $6b
    ld   H, D                                         ;; 03:60ea $62
    ld   A, [HL+]                                     ;; 03:60eb $2a
    push HL                                           ;; 03:60ec $e5
    cp   A, PARTICLE_AGE_MAX                          ;; 03:60ed $fe $40
    jr   C, .jr_03_60f3                               ;; 03:60ef $38 $02
    ld   A, PARTICLE_AGE_CLAMP                        ;; 03:60f1 $3e $3f
.jr_03_60f3:
    srl  A                                            ;; 03:60f3 $cb $3f
    srl  A                                            ;; 03:60f5 $cb $3f
    srl  A                                            ;; 03:60f7 $cb $3f
    ld   E, A                                         ;; 03:60f9 $5f
    ld   D, $00                                       ;; 03:60fa $16 $00
    ld   HL, .data_03_6140_ParticleTileByAge          ;; 03:60fc $21 $40 $61
    add  HL, DE                                       ;; 03:60ff $19
    ld   A, [HL]                                      ;; 03:6100 $7e
    ld   [wDAB7_Particle_TileId], A                   ;; 03:6101 $ea $b7 $da
    pop  HL                                           ;; 03:6104 $e1
    ld   A, [wDAB6_Oam_Attributes]                    ;; 03:6105 $fa $b6 $da
    or   A, OAMF_BANK1                    ;; 03:6108 $f6 $08
    ld   [wDAB6_Oam_Attributes], A                    ;; 03:610a $ea $b6 $da
    ld   A, [wDC6F_Oam_WriteOffset]                   ;; 03:610d $fa $6f $dc
    ld   E, A                                         ;; 03:6110 $5f
    ld   D, $d9                                       ;; 03:6111 $16 $d9
    ld   A, PARTICLE_SPRITE_COUNT                     ;; 03:6113 $3e $03
.jr_03_6115:
    push AF                                           ;; 03:6115 $f5
    ld   A, E                                         ;; 03:6116 $7b
    cp   A, OAM_FULL                                  ;; 03:6117 $fe $a0
    jr   NC, .jr_03_6137                              ;; 03:6119 $30 $1c
    ld   A, [HL+]                                     ;; 03:611b $2a
    ld   A, [HL+]                                     ;; 03:611c $2a
    ld   A, [HL+]                                     ;; 03:611d $2a
    cpl                                               ;; 03:611e $2f
    inc  A                                            ;; 03:611f $3c
    sub  A, $08                                       ;; 03:6120 $d6 $08
    add  A, B                                         ;; 03:6122 $80
    ld   [DE], A                                      ;; 03:6123 $12
    inc  E                                            ;; 03:6124 $1c
    ld   A, [HL+]                                     ;; 03:6125 $2a
    ld   A, [HL+]                                     ;; 03:6126 $2a
    ld   A, [HL+]                                     ;; 03:6127 $2a
    sub  A, $04                                       ;; 03:6128 $d6 $04
    add  A, C                                         ;; 03:612a $81
    ld   [DE], A                                      ;; 03:612b $12
    inc  E                                            ;; 03:612c $1c
    ld   A, [wDAB7_Particle_TileId]                   ;; 03:612d $fa $b7 $da
    ld   [DE], A                                      ;; 03:6130 $12
    inc  E                                            ;; 03:6131 $1c
    ld   A, [wDAB6_Oam_Attributes]                    ;; 03:6132 $fa $b6 $da
    ld   [DE], A                                      ;; 03:6135 $12
    inc  E                                            ;; 03:6136 $1c
.jr_03_6137:
    pop  AF                                           ;; 03:6137 $f1
    dec  A                                            ;; 03:6138 $3d
    jr   NZ, .jr_03_6115                              ;; 03:6139 $20 $da
    ld   A, E                                         ;; 03:613b $7b
    ld   [wDC6F_Oam_WriteOffset], A                   ;; 03:613c $ea $6f $dc
    ret                                               ;; 03:613f $c9
.data_03_6140_ParticleTileByAge:
; Tile id per burst age band, indexed by the burst timer shifted right three places.
; The values only rise, so a burst is drawn with progressively later tiles as it
; expires
    db   $34, $36, $38, $3a, $3a, $3a, $3a, $3a       ;; 03:6140 ........

call_03_6148_OAM_ClearUnusedEntries:
; Blanks every OAM entry from wDC6F_Oam_WriteOffset to OAM_LAST_BYTE by zeroing its
; Y byte, which puts the sprite off the top of the screen. Returns immediately when
; the frame filled OAM.
;
; This is what makes the shared cursor safe: nothing has to clean up after itself
; because whatever was not written this frame is wiped here. gex2's
; call_03_6484_OAM_ClearUnusedEntries
    ld   A, OAM_LAST_BYTE                             ;; 03:6148 $3e $9f
    ld   HL, wDC6F_Oam_WriteOffset                    ;; 03:614a $21 $6f $dc
    ld   L, [HL]                                      ;; 03:614d $6e
    cp   A, L                                         ;; 03:614e $bd
    ret  C                                            ;; 03:614f $d8
    ld   H, $d9                                       ;; 03:6150 $26 $d9
    ld   DE, OAM_ENTRY_SIZE                           ;; 03:6152 $11 $04 $00
    ld   C, $00                                       ;; 03:6155 $0e $00
.jr_03_6157:
    ld   [HL], C                                      ;; 03:6157 $71
    add  HL, DE                                       ;; 03:6158 $19
    cp   A, L                                         ;; 03:6159 $bd
    jr   NC, .jr_03_6157                              ;; 03:615a $30 $fb
    ret                                               ;; 03:615c $c9

call_03_615d_Collectible_BuildSprites:
; Draws the collectibles near the camera, and collects the one Gex is standing on.
;
; Collectibles live on a 16x16 cell grid, so the camera is split into a cell
; coordinate and the leftover sub-cell pixels, which become the fine biases in
; wDB70_CollectibleScreenRelativeXOffset and its Y twin. The column then indexes the
; per-column lists the level loader precomputed: the count comes from the $D3xx
; table and the entries from $D0xx/$D1xx, which hold the map id and the row of each
; collectible in that column.
;
; A collectible passes if its map id matches the current one and its row is within
; COLLECTIBLE_ROWS_ON_SCREEN of the camera. It is drawn, and then - only while
; wDCA7_Player_UpdateFlag says Gex is under his own control - tested against his
; screen position with the usual bias-and-single-compare trick over
; COLLECTIBLE_PICKUP_RANGE. A hit writes COLLECTIBLE_TAKEN into the entry so it is
; never drawn again, and calls call_00_0723_Player_ObtainedCollectible.
;
; So collection is a side effect of drawing: a collectible more than ten rows away
; is not merely invisible, it cannot be picked up. gex2's
; call_03_6499_Collectible_BuildSprites
    ld   A, [wDBF9_XPositionInMap]                    ;; 03:615d $fa $f9 $db
    and  A, COLLECTIBLE_CELL_MASK                     ;; 03:6160 $e6 $0f
    ld   B, A                                         ;; 03:6162 $47
    ld   A, COLLECTIBLE_ORIGIN_X                      ;; 03:6163 $3e $10
    sub  A, B                                         ;; 03:6165 $90
    ld   [wDB70_CollectibleScreenRelativeXOffset], A  ;; 03:6166 $ea $70 $db
    ld   A, [wDBFB_YPositionInMap]                    ;; 03:6169 $fa $fb $db
    and  A, COLLECTIBLE_CELL_MASK                     ;; 03:616c $e6 $0f
    ld   B, A                                         ;; 03:616e $47
    ld   A, COLLECTIBLE_ORIGIN_Y                      ;; 03:616f $3e $18
    sub  A, B                                         ;; 03:6171 $90
    ld   [wDB71_CollectibleScreenRelativeYOffset], A  ;; 03:6172 $ea $71 $db
    ld   HL, wDAAC_CameraXHi                          ;; 03:6175 $21 $ac $da
    ld   L, [HL]                                      ;; 03:6178 $6e
    ld   H, $d3                                       ;; 03:6179 $26 $d3
    ld   A, [HL]                                      ;; 03:617b $7e
    and  A, A                                         ;; 03:617c $a7
    ret  Z                                            ;; 03:617d $c8
    dec  H                                            ;; 03:617e $25
    ld   E, [HL]                                      ;; 03:617f $5e
    ld   HL, wDAAC_CameraXHi                          ;; 03:6180 $21 $ac $da
    ld   B, [HL]                                      ;; 03:6183 $46
    ld   HL, wDAAD_CameraYHi                          ;; 03:6184 $21 $ad $da
    ld   C, [HL]                                      ;; 03:6187 $4e
.jr_03_6188:
    push AF                                           ;; 03:6188 $f5
    push BC                                           ;; 03:6189 $c5
    set  7, E                                         ;; 03:618a $cb $fb
    ld   D, $d0                                       ;; 03:618c $16 $d0
    ld   HL, wDB6C_CurrentMapId                       ;; 03:618e $21 $6c $db
    ld   A, [DE]                                      ;; 03:6191 $1a
    cp   A, [HL]                                      ;; 03:6192 $be
    jr   NZ, .jr_03_61d4                              ;; 03:6193 $20 $3f
    ld   D, $d1                                       ;; 03:6195 $16 $d1
    ld   A, [DE]                                      ;; 03:6197 $1a
    sub  A, C                                         ;; 03:6198 $91
    cp   A, COLLECTIBLE_ROWS_ON_SCREEN                ;; 03:6199 $fe $0a
    jr   NC, .jr_03_61d4                              ;; 03:619b $30 $37
    swap A                                            ;; 03:619d $cb $37
    ld   HL, wDB71_CollectibleScreenRelativeYOffset   ;; 03:619f $21 $71 $db
    add  A, [HL]                                      ;; 03:61a2 $86
    ld   C, A                                         ;; 03:61a3 $4f
    dec  HL                                           ;; 03:61a4 $2b
    res  7, E                                         ;; 03:61a5 $cb $bb
    ld   A, [DE]                                      ;; 03:61a7 $1a
    sub  A, B                                         ;; 03:61a8 $90
    swap A                                            ;; 03:61a9 $cb $37
    add  A, [HL]                                      ;; 03:61ab $86
    ld   B, A                                         ;; 03:61ac $47
    call call_03_61db_Collectible_WriteOamPair        ;; 03:61ad $cd $db $61
    ld   A, [wDCA7_Player_UpdateFlag]                 ;; 03:61b0 $fa $a7 $dc
    and  A, A                                         ;; 03:61b3 $a7
    jr   Z, .jr_03_61d4                               ;; 03:61b4 $28 $1e
    ld   A, [wDC90_Player_ScreenX]                    ;; 03:61b6 $fa $90 $dc
    sub  A, B                                         ;; 03:61b9 $90
    add  A, COLLECTIBLE_PICKUP_BIAS                   ;; 03:61ba $c6 $09
    cp   A, COLLECTIBLE_PICKUP_RANGE                  ;; 03:61bc $fe $12
    jr   NC, .jr_03_61d4                              ;; 03:61be $30 $14
    ld   A, [wDC91_Player_ScreenY]                    ;; 03:61c0 $fa $91 $dc
    sub  A, C                                         ;; 03:61c3 $91
    add  A, COLLECTIBLE_PICKUP_BIAS                   ;; 03:61c4 $c6 $09
    cp   A, COLLECTIBLE_PICKUP_RANGE                  ;; 03:61c6 $fe $12
    jr   NC, .jr_03_61d4                              ;; 03:61c8 $30 $0a
    push DE                                           ;; 03:61ca $d5
    set  7, E                                         ;; 03:61cb $cb $fb
    ld   A, COLLECTIBLE_TAKEN                         ;; 03:61cd $3e $ff
    ld   [DE], A                                      ;; 03:61cf $12
    call call_00_0723_Player_ObtainedCollectible      ;; 03:61d0 $cd $23 $07
    pop  DE                                           ;; 03:61d3 $d1
.jr_03_61d4:
    inc  E                                            ;; 03:61d4 $1c
    pop  BC                                           ;; 03:61d5 $c1
    pop  AF                                           ;; 03:61d6 $f1
    dec  A                                            ;; 03:61d7 $3d
    jr   NZ, .jr_03_6188                              ;; 03:61d8 $20 $ae
    ret                                               ;; 03:61da $c9

call_03_61db_Collectible_WriteOamPair:
; Writes the two stacked 8x8 sprites that make one collectible, at (B, C) minus the
; OAM bias, using the fixed tiles COLLECTIBLE_TILE_TOP and COLLECTIBLE_TILE_BOTTOM.
;
; Returns without drawing if the cursor has passed OAM_COLLECTIBLE_LIMIT - four
; bytes tighter than the entity limit, because it needs two entries rather than one
    ld   A, [wDC6F_Oam_WriteOffset]                   ;; 03:61db $fa $6f $dc
    cp   A, OAM_COLLECTIBLE_LIMIT                     ;; 03:61de $fe $9c
    ret  NC                                           ;; 03:61e0 $d0
    ld   L, A                                         ;; 03:61e1 $6f
    ld   H, $d9                                       ;; 03:61e2 $26 $d9
    ld   A, C                                         ;; 03:61e4 $79
    sub  A, OAM_X_BIAS                                ;; 03:61e5 $d6 $08
    ld   [HL+], A                                     ;; 03:61e7 $22
    ld   A, B                                         ;; 03:61e8 $78
    sub  A, OAM_X_BIAS                                ;; 03:61e9 $d6 $08
    ld   [HL+], A                                     ;; 03:61eb $22
    ld   A, COLLECTIBLE_TILE_TOP                      ;; 03:61ec $3e $3c
    ld   [HL+], A                                     ;; 03:61ee $22
    ld   A, OAMF_BANK1                      ;; 03:61ef $3e $08
    ld   [HL+], A                                     ;; 03:61f1 $22
    ld   A, C                                         ;; 03:61f2 $79
    sub  A, OAM_X_BIAS                                ;; 03:61f3 $d6 $08
    ld   [HL+], A                                     ;; 03:61f5 $22
    ld   A, B                                         ;; 03:61f6 $78
    ld   [HL+], A                                     ;; 03:61f7 $22
    ld   A, COLLECTIBLE_TILE_BOTTOM                   ;; 03:61f8 $3e $3e
    ld   [HL+], A                                     ;; 03:61fa $22
    ld   A, OAMF_BANK1                      ;; 03:61fb $3e $08
    ld   [HL+], A                                     ;; 03:61fd $22
    ld   A, L                                         ;; 03:61fe $7d
    ld   [wDC6F_Oam_WriteOffset], A                   ;; 03:61ff $ea $6f $dc
    ret                                               ;; 03:6202 $c9
    