; ==================================================================
; Bank 3. Who gets which colours. Four routines that fill the CGB palette buffers,
; and the per-entity-type colour table they draw from.
;
; Nothing here touches hardware. Everything writes into one contiguous stretch of
; WRAM that call_00_0e81_UploadCgbPalettes pushes to rBCPD and rOCPD once per vblank:
;
;   wDCEA_BgPalettes .. wDD29    CGB_PALETTE_RAM_SIZE bytes - the eight BG palettes
;   wDD2A_EntityPalettes .. wDD69  and the same again - the eight OBJ palettes
;
; The four labels memory.asm gives that stretch are cosmetic. The upload walks HL
; straight through all $80 bytes, and the writers below cross the label boundaries
; freely - a menu load writes $40 bytes at wDCEA and another $40 immediately after,
; and an entity palette index of 4 or more lands past wDD2A_EntityPalettes.
;
; Who fills what
; --------------
;   the BG palettes   call_03_65c6_Palettes_LoadForScreen, once per screen. C picks
;                     between the current map's colours and one of eight menu sets
;   OBJ palette 0     the player's. Normally two palettes' worth arrives with the
;                     map through call_00_2cbf_Entity_LoadMapPalettes, but
;                     call_03_6567_FlyPowerup_LoadPalette overwrites the first eight
;                     bytes every frame while a fly power-up is held
;   OBJ palettes 1-7  one per entity slot, filled from
;                     data_03_68f9_EntityPalettes as entities spawn
;
; An entity's palette number is its SLOT number - see
; call_03_687c_AssignEntityPalette - so which colours an entity gets depends on where
; the spawner happened to put it, and the eight-slot entity array and the eight-palette
; OBJ palette ram are the same eight things. That is the whole allocation scheme: no
; sharing, no reference counting, and no way for a ninth entity to want a colour.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank0B_palettes.asm
; ------------------------------------------------------------------
; gex2's file is half again as big and covers more ground - it also holds the DMG
; palette path, the Media Dimension TV palettes and the per-tileset palette id table.
; The routines that do correspond:
;
;   the fly tint    gex2's call_0b_5f1b_FlyPowerup_LoadParticlePalette is the same
;                   idea with four entries instead of five, and writes OBJ palette 2
;                   rather than 0 - in gex2 the tint is on the particle, here it is on
;                   the palette the player and the orbiting fly share
;   entity colours  gex2's call_0b_5f57_Entity_LoadGBCPalette is close to
;                   instruction-for-instruction with call_03_687c_AssignEntityPalette,
;                   including the same unrolled eight-byte copy. The difference is
;                   where the palette NUMBER comes from: gex2 is handed it in C by the
;                   caller, gex3 derives it from the slot address and lets one action
;                   state override it to 0
;   the DMG path    every gex2 routine here starts with `ld A, [wD59E_OnGBCFlag]` and
;                   returns early on monochrome hardware. gex3 is CGB-only, so there
;                   is no such test anywhere in this file
;   the BG side     gex2's call_0b_561b_GBC_LoadLevelBgPalette builds its BG palettes
;                   from a per-tileset id table; gex3 stores a finished $40-byte block
;                   per map and memcpys it, which is why its BG loader is four
;                   instructions in bank 0 rather than a routine here
; ==================================================================

call_03_6567_FlyPowerup_LoadPalette:
; Tints OBJ palette 0 to match the fly power-up Gex is carrying, and is called every
; frame from the player update - right after the three power-up timers tick, so the
; colour tracks the timers without anything having to notice when one expires.
;
; Three outcomes, in priority order:
;
;   wDCAB_FlyPowerup5_Timer running   .data_03_658c_FlyPalette_Fly5Active wins
;                                     outright, whatever is being carried
;   no fly carried                    tail-jumps to
;                                     call_00_2cbf_Entity_LoadMapPalettes, which
;                                     restores SIXTEEN bytes - the map's own OBJ
;                                     palettes 0 and 1 - not eight
;   a fly carried                     that fly's eight bytes from
;                                     .data_03_6594_FlyPowerupPalettes
;
; Note the asymmetry in the middle case: the tint is one palette wide but undoing it
; costs two, because the map load is the only thing that knows the untinted colours.
;
; gex2's call_0b_5f1b_FlyPowerup_LoadParticlePalette does the same lookup into OBJ
; palette 2, and has no fallback at all - it simply returns if no fly is held
    ld   HL, .data_03_658c_FlyPalette_Fly5Active      ;; 03:6567 $21 $8c $65
    ld   A, [wDCAB_FlyPowerup5_Timer]                 ;; 03:656a $fa $ab $dc
    and  A, A                                         ;; 03:656d $a7
    jr   NZ, .jr_03_6583                              ;; 03:656e $20 $13
    ld   A, [wDC51_Player_CurrentFly]                 ;; 03:6570 $fa $51 $dc
    and  A, A                                         ;; 03:6573 $a7
    jp   Z, call_00_2cbf_Entity_LoadMapPalettes       ;; 03:6574 $ca $bf $2c
    dec  A                                            ;; 03:6577 $3d
    ld   L, A                                         ;; 03:6578 $6f
    ld   H, $00                                       ;; 03:6579 $26 $00
    add  HL, HL                                       ;; 03:657b $29
    ld   DE, .data_03_6594_FlyPowerupPalettes         ;; 03:657c $11 $94 $65
    add  HL, DE                                       ;; 03:657f $19
    ld   A, [HL+]                                     ;; 03:6580 $2a
    ld   H, [HL]                                      ;; 03:6581 $66
    ld   L, A                                         ;; 03:6582 $6f
.jr_03_6583:
    ld   DE, wDD2A_EntityPalettes                     ;; 03:6583 $11 $2a $dd
    ld   BC, CGB_PALETTE_SIZE                         ;; 03:6586 $01 $08 $00
    jp   call_00_076e_MemCopy                         ;; 03:6589 $c3 $6e $07
.data_03_658c_FlyPalette_Fly5Active:
; The same four colours as .data_03_65b6_FlyPalette_Fly5 below, duplicated so the
; "power-up currently running" test above needs no second index
    db   $00, $00, $00, $00, $00, $42, $e0, $7f      ; black, black, dark cyan, cyan
.data_03_6594_FlyPowerupPalettes:
; One pointer per FLY_POWERUP_* id, indexed by the carried fly minus one. The five
; entries are not in address order, and two pairs of them are the same colours
    dw   .data_03_65ae_FlyPalette_Fly1, .data_03_65be_FlyPalette_Fly2, .data_03_659e_FlyPalette_Health
    dw   .data_03_65a6_FlyPalette_ExtraLife, .data_03_65b6_FlyPalette_Fly5
.data_03_659e_FlyPalette_Health:
    db   $00, $00, $00, $00, $00, $02, $e0, $03      ; black, black, dark green, green
.data_03_65a6_FlyPalette_ExtraLife:
    db   $00, $00, $00, $00, $10, $40, $1f, $7c      ; black, black, dark magenta, magenta
.data_03_65ae_FlyPalette_Fly1:
; All black. Carrying FLY_POWERUP_1 or _2 puts four zero colours into OBJ palette 0
; rather than a tint - whether that is the intended look or an unfinished entry is
; not something the code says
    db   $00, $00, $00, $00, $00, $00, $00, $00
.data_03_65b6_FlyPalette_Fly5:
    db   $00, $00, $00, $00, $00, $42, $e0, $7f      ; black, black, dark cyan, cyan
.data_03_65be_FlyPalette_Fly2:
    db   $00, $00, $00, $00, $00, $00, $00, $00

call_03_65c6_Palettes_LoadForScreen:
; Loads a whole screen's worth of colour, both palette rams, picking the source from
; C. The `inc C / dec C` at the top is a zero test that leaves C intact.
;
;   C = 0            a level. Hands off to call_00_05af_BgPalettes_LoadForMap for the
;                    map's BG colours and call_00_2cbf_Entity_LoadMapPalettes for its
;                    OBJ pair, and does nothing else
;   MENU_PALETTE_NONE_BIT set   returns immediately, leaving whatever is loaded
;                    alone. The menu loader in bank 1 tests the same bit before it
;                    calls, so this check never actually fires from there
;   anything else    a menu. C indexes .data_03_65f1_MenuPalettes for a
;                    CGB_PALETTE_RAM_SIZE block of BG colours
;
; The menu path copies twice, and the second copy has no destination of its own -
; call_00_076e_MemCopy leaves DE one past the end, so the follow-up copy of
; .data_03_6803_MenuObjPalette lands exactly on wDD2A_EntityPalettes. Every menu
; therefore shares one OBJ palette set and only chooses its background.
;
; Called from call_00_1056_BgMap_LoadFull with C = 0 and from the menu loader in bank
; 1 with the menu's own id
    inc  C                                            ;; 03:65c6 $0c
    dec  C                                            ;; 03:65c7 $0d
    jr   NZ, .jr_03_65d1                              ;; 03:65c8 $20 $07
    call call_00_05af_BgPalettes_LoadForMap           ;; 03:65ca $cd $af $05
    call call_00_2cbf_Entity_LoadMapPalettes          ;; 03:65cd $cd $bf $2c
    ret                                               ;; 03:65d0 $c9
.jr_03_65d1:
    bit  MENU_PALETTE_NONE_BIT, C                     ;; 03:65d1 $cb $79
    ret  NZ                                           ;; 03:65d3 $c0
    ld   L, C                                         ;; 03:65d4 $69
    ld   H, $00                                       ;; 03:65d5 $26 $00
    add  HL, HL                                       ;; 03:65d7 $29
    ld   DE, .data_03_65f1_MenuPalettes               ;; 03:65d8 $11 $f1 $65
    add  HL, DE                                       ;; 03:65db $19
    ld   A, [HL+]                                     ;; 03:65dc $2a
    ld   H, [HL]                                      ;; 03:65dd $66
    ld   L, A                                         ;; 03:65de $6f
    ld   DE, wDCEA_BgPalettes                         ;; 03:65df $11 $ea $dc
    ld   BC, CGB_PALETTE_RAM_SIZE                     ;; 03:65e2 $01 $40 $00
    call call_00_076e_MemCopy                         ;; 03:65e5 $cd $6e $07
    ld   HL, .data_03_6803_MenuObjPalette             ;; 03:65e8 $21 $03 $68
    ld   BC, CGB_PALETTE_RAM_SIZE                     ;; 03:65eb $01 $40 $00
    jp   call_00_076e_MemCopy                         ;; 03:65ee $c3 $6e $07
.data_03_65f1_MenuPalettes:
; One BG palette set per menu id. Entry 0 is a null pointer and is unreachable -
; C = 0 is caught by the zero test at the top of the routine and never gets here
    dw   $0000                                       ; never indexed
    dw   .data_03_6603_palette, .data_03_6643_palette
    dw   .data_03_6683_palette, .data_03_66c3_palette
    dw   .data_03_6703_palette, .data_03_6743_palette
    dw   .data_03_6783_palette, .data_03_67c3_palette
.data_03_6603_palette: ; pause menus
    INCBIN "gfx/menus/palettes/pause_menu_palette.bin"
.data_03_6643_palette: ; david a palmer productions
    INCBIN "gfx/menus/palettes/david_a_palmer_palette.bin"
.data_03_6683_palette:
    INCBIN "gfx/menus/palettes/unk_menu_palette_6683.bin"
.data_03_66c3_palette: ; title screen
    INCBIN "gfx/menus/palettes/title_screen_palette.bin"
.data_03_6703_palette: ; eidos interactive
    INCBIN "gfx/menus/palettes/eidos_interactive_palette.bin"
.data_03_6743_palette: ; crystal dynamics (might be swapped with above)
    INCBIN "gfx/menus/palettes/crystal_dynamics_palette.bin"
.data_03_6783_palette: ; password screens
    INCBIN "gfx/menus/palettes/password_menu_palette.bin"
.data_03_67c3_palette:
    INCBIN "gfx/menus/palettes/unk_menu_palette_67c3.bin"
.data_03_6803_MenuObjPalette:
; The OBJ half of every menu's colours - the second of the two copies above lands on
; wDD2A_EntityPalettes, so this one set serves all eight menus
    INCBIN "gfx/menus/palettes/unk_menu_palette_6803.bin" 

call_03_6833_Entity_ApplyTypeDefaults:
; Rebuilds the current entity slot as type C from scratch: id, size, collision type,
; health, facing, colours and action 0.
;
; NOTHING IN THE DISASSEMBLY CALLS THIS. It is a working routine - the reads are
; consistent with the tables it uses - but no call site or pointer table reaches it,
; so it is either left over from development or reached by a path this disassembly
; does not model.
;
; The attributes come from data_00_3259_EntityAttributeTable_WidthBase, the base that
; starts at ENTITY_ATTR_WIDTH, so the four fields it reads are width, height,
; collision type and damage state - with the same `dec A` on the last one that the
; spawner uses, because the table stores health plus one. The colours come from
; data_03_68f9_EntityPalettes through call_00_2c20_Entity_CopyPaletteToBuffer, which
; writes into whichever palette the slot already owns rather than picking a new one.
;
; C is pushed across the attribute half and popped for the palette half; both halves
; index their table by the same entity id
    push bc
    call call_00_2930_Entity_SetId
    ld   l,c
    ld   h,$00
    add  hl,hl
    add  hl,hl
    add  hl,hl
    ld   de,data_00_3259_EntityAttributeTable_WidthBase
    add  hl,de
    ldi  a,[hl]
    push hl
    ld   c,a
    call call_00_2944_Entity_SetWidth
    pop  hl
    ldi  a,[hl]
    push hl
    ld   c,a
    call call_00_294e_Entity_SetHeight
    pop  hl
    ldi  a,[hl]
    push hl
    ld   c,a
    call call_00_288c_Entity_SetCollisionType
    pop  hl
    ldi  a,[hl]
    dec  a
    ld   c,a
    call call_00_28aa_Entity_SetDamageState
    ld   c,ENTITY_FACING_RIGHT
    call call_00_2958_Entity_SetFacingDirection
    pop  bc
    ld   l,c
    ld   h,$00
    add  hl,hl
    add  hl,hl
    add  hl,hl
    ld   de,data_03_68f9_EntityPalettes
    add  hl,de
    call call_00_2c20_Entity_CopyPaletteToBuffer
    xor  a
    farcall call_02_72ac_Entity_SetAction
    ret  

call_03_687c_AssignEntityPalette:
; Gives the current entity its colours: picks which of the eight OBJ palettes it owns,
; records that number, and copies its type's eight bytes into it.
;
; The palette number is the SLOT number, recovered from wDA00_CurrentEntityAddrLo by
; rotating the top three bits down and masking with ENTITY_SLOT_INDEX_MASK - so slot
; two draws with OBJ palette two, and the mapping is fixed for as long as the entity
; occupies that slot. One exception: an entity with ACTION_STATE_UNK80_BIT set in
; ENTITY_FIELD_ACTION_STATE_FLAGS takes palette 0 instead, sharing whatever the player
; is using and, by writing there, changing it.
;
; The number is stored in wDAAE_EntityPaletteIds for the slot, which is where the OAM
; build reads it back as the attribute byte's palette bits.
;
; The eight-byte copy is unrolled rather than a MemCopy call, which is also true of
; gex2's call_0b_5f57_Entity_LoadGBCPalette - the routine this one otherwise matches
; almost instruction for instruction
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ACTION_STATE_FLAGS ;; 03:6883 $6f
    ld   C, $00                                       ;; 03:6884 $0e $00
    bit  ACTION_STATE_UNK80_BIT, [HL]                 ;; 03:6886 $cb $7e
    jr   NZ, .jr_03_6893                              ;; 03:6888 $20 $09
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:688a $fa $00 $da
    rlca                                              ;; 03:688d $07
    rlca                                              ;; 03:688e $07
    rlca                                              ;; 03:688f $07
    and  A, ENTITY_SLOT_INDEX_MASK                    ;; 03:6890 $e6 $07
    ld   C, A                                         ;; 03:6892 $4f
.jr_03_6893:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:6893 $fa $00 $da
    rlca                                              ;; 03:6896 $07
    rlca                                              ;; 03:6897 $07
    rlca                                              ;; 03:6898 $07
    and  A, ENTITY_SLOT_INDEX_MASK                    ;; 03:6899 $e6 $07
    ld   L, A                                         ;; 03:689b $6f
    ld   H, $00                                       ;; 03:689c $26 $00
    ld   DE, wDAAE_EntityPaletteIds                   ;; 03:689e $11 $ae $da
    add  HL, DE                                       ;; 03:68a1 $19
    ld   [HL], C                                      ;; 03:68a2 $71
    ld   L, C                                         ;; 03:68a3 $69
    ld   H, $00                                       ;; 03:68a4 $26 $00
    add  HL, HL                                       ;; 03:68a6 $29
    add  HL, HL                                       ;; 03:68a7 $29
    add  HL, HL                                       ;; 03:68a8 $29
    ld   DE, wDD2A_EntityPalettes                     ;; 03:68a9 $11 $2a $dd
    add  HL, DE                                       ;; 03:68ac $19
    ld   E, L                                         ;; 03:68ad $5d
    ld   D, H                                         ;; 03:68ae $54
    LOAD_OBJ_FIELD_TO_HL ENTITY_FIELD_ENTITY_ID
    ld   L, [HL]                                      ;; 03:68b7 $6e
    ld   H, $00                                       ;; 03:68b8 $26 $00
    add  HL, HL                                       ;; 03:68ba $29
    add  HL, HL                                       ;; 03:68bb $29
    add  HL, HL                                       ;; 03:68bc $29
    ld   BC, data_03_68f9_EntityPalettes              ;; 03:68bd $01 $f9 $68
    add  HL, BC                                       ;; 03:68c0 $09
    ld   A, [HL+]                                     ;; 03:68c1 $2a
    ld   [DE], A                                      ;; 03:68c2 $12
    inc  DE                                           ;; 03:68c3 $13
    ld   A, [HL+]                                     ;; 03:68c4 $2a
    ld   [DE], A                                      ;; 03:68c5 $12
    inc  DE                                           ;; 03:68c6 $13
    ld   A, [HL+]                                     ;; 03:68c7 $2a
    ld   [DE], A                                      ;; 03:68c8 $12
    inc  DE                                           ;; 03:68c9 $13
    ld   A, [HL+]                                     ;; 03:68ca $2a
    ld   [DE], A                                      ;; 03:68cb $12
    inc  DE                                           ;; 03:68cc $13
    ld   A, [HL+]                                     ;; 03:68cd $2a
    ld   [DE], A                                      ;; 03:68ce $12
    inc  DE                                           ;; 03:68cf $13
    ld   A, [HL+]                                     ;; 03:68d0 $2a
    ld   [DE], A                                      ;; 03:68d1 $12
    inc  DE                                           ;; 03:68d2 $13
    ld   A, [HL+]                                     ;; 03:68d3 $2a
    ld   [DE], A                                      ;; 03:68d4 $12
    inc  DE                                           ;; 03:68d5 $13
    ld   A, [HL]                                      ;; 03:68d6 $7e
    ld   [DE], A                                      ;; 03:68d7 $12
    ret                                               ;; 03:68d8 $c9

call_03_68d9_AssignAllEntityPalettes:
; Re-assigns every loaded entity's palette, and is called on exactly one occasion:
; leaving the pause menu, right after call_02_7142_Entities_RestoreIdTable. The pause
; screen loaded its own colours over OBJ palette ram, so all of them have to be put
; back before the level is drawn again.
;
; Walks the slots from wD840_EntityMemoryAfterPlayer up, adding ENTITY_SLOT_SIZE until
; the address wraps to zero - so slots two through seven, skipping the player and slot
; one. Any slot holding ENTITY_ID_NONE is passed over.
;
; Before each call it sets ACTION_STATE_ID_CHANGED_BIT on the entity, reaching the
; flags byte with `xor A, ENTITY_FIELD_ACTION_STATE_FLAGS` because L is still sitting
; on field 0. That is the "your sprite changed" pulse the OAM build watches, and
; setting it here is what forces every entity to be rebuilt on the first frame back
; rather than keeping whatever the pause screen left in OAM
    ld   A, LOW(wD840_EntityMemoryAfterPlayer)        ;; 03:68d9 $3e $40
.jr_03_68db:
    ld   [wDA00_CurrentEntityAddrLo], A               ;; 03:68db $ea $00 $da
    or   A, ENTITY_FIELD_ENTITY_ID                    ;; 03:68de $f6 $00
    ld   L, A                                         ;; 03:68e0 $6f
    ld   h, HIGH(wD800_EntityMemory)                  ;; 03:68e1 $26 $d8
    ld   A, [HL]                                      ;; 03:68e3 $7e
    cp   A, ENTITY_ID_NONE                            ;; 03:68e4 $fe $ff
    jr   Z, .jr_03_68f1                               ;; 03:68e6 $28 $09
    ld   A, L                                         ;; 03:68e8 $7d
    xor  A, ENTITY_FIELD_ACTION_STATE_FLAGS           ;; 03:68e9 $ee $05
    ld   L, A                                         ;; 03:68eb $6f
    set  ACTION_STATE_ID_CHANGED_BIT, [HL]            ;; 03:68ec $cb $ce
    call call_03_687c_AssignEntityPalette             ;; 03:68ee $cd $7c $68
.jr_03_68f1:
    ld   A, [wDA00_CurrentEntityAddrLo]               ;; 03:68f1 $fa $00 $da
    add  A, ENTITY_SLOT_SIZE                          ;; 03:68f4 $c6 $20
    jr   NZ, .jr_03_68db                              ;; 03:68f6 $20 $e3
    ret                                               ;; 03:68f8 $c9

data_03_68f9_EntityPalettes:
; One CGB_PALETTE_SIZE-byte OBJ palette per ENTITY_* id, in entity id order, so a
; row's position IS its id. Four little-endian BGR555 colours each.
;
; Colour 0 is transparent for an OBJ and is $0000 in every row. Most rows leave colour
; 1 at $0000 too and carry the entity in two colours, which is why so many of them
; start with four zero bytes - the sprites are drawn in colours 2 and 3 with a black
; outline.
;
; The ENTITY_GEX row is all zeros and is never read: the player's colours come from
; the map through call_00_2cbf_Entity_LoadMapPalettes, or from the fly tint above.
;
; gex2 keeps the same table as a separate binary, gfx/entity_sprites/entity_palettes.bin,
; INCBIN'd at the end of call_0b_5f57_Entity_LoadGBCPalette
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 03:68f9 ???????? ; ENTITY_GEX
    db   $00, $00, $00, $00, $1f, $00, $ff, $03       ;; 03:6901 ........ ; ENTITY_BONUS_COIN
    db   $00, $00, $00, $00, $60, $02, $9c, $03       ;; 03:6909 ........ ; ENTITY_FLY_COIN_SPAWN
    db   $00, $00, $00, $00, $ff, $03, $e0, $03       ;; 03:6911 ........ ; ENTITY_PAW_COIN
    db   $00, $00, $00, $00, $10, $42, $e0, $03       ;; 03:6919 ???????? ; ENTITY_FLY_1
    db   $00, $00, $00, $00, $10, $42, $13, $7c       ;; 03:6921 ???????? ; ENTITY_FLY_2
    db   $00, $00, $00, $00, $10, $42, $52, $7e       ;; 03:6929 ???????? ; ENTITY_FLY_3
    db   $00, $00, $00, $00, $10, $42, $e0, $7f       ;; 03:6931 ???????? ; ENTITY_FLY_4
    db   $00, $00, $00, $00, $10, $42, $1f, $00       ;; 03:6939 ???????? ; ENTITY_FLY_5
    db   $00, $00, $00, $00, $10, $42, $e0, $03       ;; 03:6941 ???????? ; ENTITY_GREEN_FLY_TV
    db   $00, $00, $00, $00, $10, $42, $13, $7c       ;; 03:6949 ???????? ; ENTITY_PURPLE_FLY_TV
    db   $00, $00, $00, $00, $10, $42, $52, $7e       ;; 03:6951 ???????? ; ENTITY_UNK_FLY_TV_3
    db   $00, $00, $00, $00, $10, $42, $e0, $7f       ;; 03:6959 ???????? ; ENTITY_BLUE_FLY_TV
    db   $00, $00, $00, $00, $10, $42, $1f, $00       ;; 03:6961 ???????? ; ENTITY_UNK_FLY_TV_5
    db   $00, $00, $00, $00, $10, $42, $52, $7e       ;; 03:6969 ???????? ; ENTITY_UNK0E
    db   $00, $00, $00, $00, $10, $42, $6b, $0a       ;; 03:6971 ???????? ; ENTITY_UNK0F
    db   $00, $00, $00, $00, $10, $42, $1f, $00       ;; 03:6979 ???????? ; ENTITY_UNK10
    db   $00, $00, $00, $00, $73, $4e, $1f, $00       ;; 03:6981 ........ ; ENTITY_TV_BUTTON
    db   $00, $00, $00, $00, $73, $4e, $1f, $00       ;; 03:6989 ........ ; ENTITY_TV_REMOTE
    db   $00, $00, $00, $34, $ff, $03, $80, $02       ;; 03:6991 ???????? ; ENTITY_UNK13
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:6999 ........ ; ENTITY_GOAL_COUNTER_1
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:69a1 ........ ; ENTITY_GOAL_COUNTER_2
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:69a9 ........ ; ENTITY_GOAL_COUNTER_3
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:69b1 ........ ; ENTITY_GOAL_COUNTER_4
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:69b9 ???????? ; ENTITY_GOAL_COUNTER_5
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:69c1 ???????? ; ENTITY_GOAL_COUNTER_6
    db   $00, $00, $ff, $03, $1f, $02, $ec, $00       ;; 03:69c9 ???????? ; ENTITY_GOAL_COUNTER_7
    db   $00, $00, $2d, $19, $7b, $09, $9f, $47       ;; 03:69d1 ???????? ; ENTITY_BONUS_STAGE_TIMER
    db   $00, $00, $00, $01, $e0, $03, $ff, $7f       ;; 03:69d9 ........ ; ENTITY_FREESTANDING_REMOTE
    db   $00, $00, $b3, $7f, $85, $7e, $a4, $7c       ;; 03:69e1 ........ ; ENTITY_HOLIDAY_TV_ICE_SCULPTURE
    db   $00, $00, $00, $00, $1f, $00, $ff, $7f       ;; 03:69e9 ........ ; ENTITY_HOLIDAY_TV_EVIL_SANTA
    db   $00, $00, $4a, $29, $b5, $56, $ff, $7f       ;; 03:69f1 ........ ; ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE
    db   $00, $00, $7d, $42, $20, $03, $00, $00       ;; 03:69f9 ........ ; ENTITY_HOLIDAY_TV_SKATING_ELF
    db   $00, $00, $00, $00, $ff, $7f, $1f, $02       ;; 03:6a01 ........ ; ENTITY_HOLIDAY_TV_PENGUIN
    db   $00, $00, $00, $00, $10, $42, $ec, $7f       ;; 03:6a09 ???????? ; ENTITY_MYSTERY_TV_REZLING
    db   $00, $00, $00, $00, $ff, $7f, $1f, $00       ;; 03:6a11 ???????? ; ENTITY_MYSTERY_TV_BLOOD_COOLER
    db   $00, $00, $00, $00, $ff, $7f, $80, $02       ;; 03:6a19 ???????? ; ENTITY_MYSTERY_TV_FISH
    db   $00, $00, $00, $00, $ff, $7f, $ff, $03       ;; 03:6a21 ???????? ; ENTITY_MYSTERY_TV_MAGIC_SWORD
    db   $00, $00, $00, $00, $00, $03, $ff, $7f       ;; 03:6a29 ???????? ; ENTITY_MYSTERY_TV_SAFARI_SAM
    db   $00, $00, $00, $00, $68, $77, $ff, $7f       ;; 03:6a31 ???????? ; ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE
    db   $00, $00, $00, $00, $ff, $7f, $10, $42       ;; 03:6a39 ???????? ; ENTITY_MYSTERY_TV_GHOST_KNIGHT
    db   $00, $00, $00, $00, $28, $7e, $f1, $7e       ;; 03:6a41 ???????? ; ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE
    db   $00, $00, $00, $00, $10, $42, $ff, $7f       ;; 03:6a49 ???????? ; ENTITY_TUT_TV_HAND
    db   $00, $00, $00, $00, $00, $7c, $ff, $03       ;; 03:6a51 ???????? ; ENTITY_TUT_TV_LOST_ARK
    db   $00, $00, $8e, $00, $00, $7c, $ff, $03       ;; 03:6a59 ???????? ; ENTITY_TUT_TV_RISING_PLATFORM
    db   $00, $00, $8e, $00, $00, $7c, $ff, $03       ;; 03:6a61 ???????? ; ENTITY_TUT_TV_SIDEWAYS_PLATFORM
    db   $00, $00, $00, $00, $ff, $03, $ce, $01       ;; 03:6a69 ???????? ; ENTITY_TUT_TV_BEE
    db   $00, $00, $00, $00, $10, $01, $57, $02       ;; 03:6a71 ???????? ; ENTITY_TUT_TV_RAFT
    db   $00, $00, $00, $00, $c0, $02, $ff, $03       ;; 03:6a79 ???????? ; ENTITY_TUT_TV_SNAKE_FACING_RIGHT
    db   $00, $00, $00, $00, $c0, $02, $ff, $03       ;; 03:6a81 ???????? ; ENTITY_TUT_TV_SNAKE_FACING_LEFT
    db   $00, $00, $ff, $03, $10, $02, $00, $00       ;; 03:6a89 ???????? ; ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE
    db   $00, $00, $ff, $03, $10, $02, $00, $00       ;; 03:6a91 ???????? ; ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE
    db   $00, $00, $8c, $01, $94, $02, $ff, $03       ;; 03:6a99 ???????? ; ENTITY_TUT_TV_RA_STAFF
    db   $00, $00, $1f, $00, $1f, $02, $ff, $03       ;; 03:6aa1 ???????? ; ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE
    db   $00, $00, $1f, $00, $1f, $02, $ff, $03       ;; 03:6aa9 ???????? ; ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE
    db   $00, $00, $00, $00, $36, $02, $3c, $4f       ;; 03:6ab1 ???????? ; ENTITY_TUT_TV_BREAKABLE_BLOCK
    db   $00, $00, $00, $7c, $d7, $01, $ff, $03       ;; 03:6ab9 ???????? ; ENTITY_TUT_TV_COFFIN
    db   $00, $00, $00, $00, $20, $03, $ff, $7f       ;; 03:6ac1 ???????? ; ENTITY_WESTERN_STATION_CACTUS
    db   $00, $00, $00, $00, $20, $03, $ff, $7f       ;; 03:6ac9 ???????? ; ENTITY_UNK3A
    db   $00, $00, $00, $00, $4a, $29, $52, $4a       ;; 03:6ad1 ???????? ; ENTITY_WESTERN_STATION_ROCK_PLATFORM
    db   $00, $00, $ff, $03, $00, $00, $52, $4a       ;; 03:6ad9 ???????? ; ENTITY_WESTERN_STATION_HARD_HAT
    db   $00, $00, $00, $00, $7e, $00, $bf, $6b       ;; 03:6ae1 ???????? ; ENTITY_WESTERN_STATION_PLAYING_CARD
    db   $00, $00, $1f, $00, $08, $21, $18, $63       ;; 03:6ae9 ???????? ; ENTITY_WESTERN_STATION_BAT
    db   $00, $00, $8e, $00, $00, $7c, $ff, $03       ;; 03:6af1 ???????? ; ENTITY_WESTERN_STATION_RISING_PLATFORM
    db   $00, $00, $00, $00, $10, $42, $ff, $7f       ;; 03:6af9 ???????? ; ENTITY_ANIME_CHANNEL_DOOR
    db   $00, $00, $00, $00, $10, $42, $ff, $7f       ;; 03:6b01 ???????? ; ENTITY_ANIME_CHANNEL_DOOR2
    db   $00, $00, $00, $00, $ef, $54, $15, $72       ;; 03:6b09 ???????? ; ENTITY_ANIME_CHANNEL_FAN_LIFT
    db   $00, $00, $1f, $00, $ce, $39, $00, $00       ;; 03:6b11 ???????? ; ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT
    db   $00, $00, $1f, $00, $ce, $39, $00, $00       ;; 03:6b19 ???????? ; ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT
    db   $00, $00, $fc, $16, $94, $52, $00, $00       ;; 03:6b21 ???????? ; ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR
    db   $00, $00, $00, $00, $10, $01, $57, $02       ;; 03:6b29 ???????? ; ENTITY_ANIME_CHANNEL_ON_SWITCH2
    db   $00, $00, $00, $02, $2b, $2f, $fa, $47       ;; 03:6b31 ???????? ; ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE
    db   $00, $00, $00, $7c, $e0, $7f, $ff, $7f       ;; 03:6b39 ???????? ; ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER
    db   $00, $00, $00, $00, $ff, $02, $ff, $03       ;; 03:6b41 ???????? ; ENTITY_ANIME_CHANNEL_RISING_PLATFORM
    db   $00, $00, $00, $00, $1f, $00, $7f, $4e       ;; 03:6b49 ???????? ; ENTITY_ANIME_CHANNEL_ON_SWITCH
    db   $00, $00, $00, $00, $1f, $00, $7f, $4e       ;; 03:6b51 ???????? ; ENTITY_ANIME_CHANNEL_OFF_SWITCH
    db   $00, $00, $00, $00, $bc, $45, $ff, $7f       ;; 03:6b59 ???????? ; ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL
    db   $00, $00, $00, $00, $73, $4e, $ff, $7f       ;; 03:6b61 ???????? ; ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT
    db   $00, $00, $00, $00, $69, $66, $c9, $7f       ;; 03:6b69 ???????? ; ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT
    db   $00, $00, $00, $00, $6b, $3e, $3c, $00       ;; 03:6b71 ???????? ; ENTITY_ANIME_CHANNEL_SECBOT
    db   $00, $00, $00, $7c, $e0, $7f, $ff, $7f       ;; 03:6b79 ???????? ; ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE
    db   $00, $00, $fc, $16, $94, $52, $00, $00       ;; 03:6b81 ???????? ; ENTITY_ANIME_CHANNEL_ELEVATOR
    db   $00, $00, $00, $00, $dc, $08, $1f, $0e       ;; 03:6b89 ???????? ; ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY
    db   $00, $00, $00, $00, $ff, $03, $ff, $7f       ;; 03:6b91 ???????? ; ENTITY_ANIME_CHANNEL_GRENADE
    db   $00, $00, $ff, $7f, $e0, $03, $1f, $00       ;; 03:6b99 ???????? ; ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON
    db   $00, $00, $00, $00, $53, $68, $bf, $57       ;; 03:6ba1 ???????? ; ENTITY_SUPERHERO_SHOW_MAD_BOMBER
    db   $00, $00, $00, $00, $df, $00, $7f, $53       ;; 03:6ba9 ???????? ; ENTITY_SUPERHERO_SHOW_BOMB
    db   $00, $00, $00, $00, $11, $09, $76, $09       ;; 03:6bb1 ???????? ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK
    db   $00, $00, $00, $00, $11, $09, $76, $09       ;; 03:6bb9 ???????? ; ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND
    db   $00, $00, $00, $00, $10, $42, $ff, $7f       ;; 03:6bc1 ???????? ; ENTITY_SUPERHERO_SHOW_CONVICT
    db   $00, $00, $00, $00, $35, $65, $bf, $7a       ;; 03:6bc9 ???????? ; ENTITY_SUPERHERO_SHOW_SPIDER
    db   $00, $00, $00, $00, $f7, $5e, $ff, $7f       ;; 03:6bd1 ???????? ; ENTITY_SUPERHERO_SHOW_STRAY_CAT
    db   $00, $00, $00, $00, $1f, $03, $ff, $03       ;; 03:6bd9 ???????? ; ENTITY_SUPERHERO_SHOW_YELLOW_GOON
    db   $00, $00, $00, $00, $f4, $21, $bb, $42       ;; 03:6be1 ???????? ; ENTITY_SUPERHERO_SHOW_RAT
    db   $00, $00, $00, $00, $a9, $1e, $95, $47       ;; 03:6be9 ???????? ; ENTITY_SUPERHERO_SHOW_CHOMPER_TV
    db   $00, $00, $08, $21, $10, $42, $5a, $6b       ;; 03:6bf1 ???????? ; ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR
    db   $00, $00, $00, $00, $df, $00, $ff, $7f       ;; 03:6bf9 ???????? ; ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE
    db   $00, $00, $7d, $42, $20, $03, $00, $00       ;; 03:6c01 ???????? ; ENTITY_GEXTREME_SPORTS_ELF
    db   $00, $00, $00, $00, $96, $01, $5e, $03       ;; 03:6c09 ???????? ; ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN
    db   $00, $00, $dd, $13, $19, $02, $00, $00       ;; 03:6c11 ???????? ; ENTITY_MARSUPIAL_MADNESS_BELL
    db   $00, $00, $00, $00, $10, $42, $9c, $73       ;; 03:6c19 ???????? ; ENTITY_MARSUPIAL_MADNESS_BIRD
    db   $00, $00, $00, $00, $10, $42, $9c, $73       ;; 03:6c21 ???????? ; ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE
    db   $00, $00, $00, $00, $58, $2a, $3e, $87       ;; 03:6c29 ???????? ; ENTITY_WW_GEX_WRESTLING_ROCK_HARD
    db   $00, $00, $00, $00, $f8, $71, $7d, $7f       ;; 03:6c31 ???????? ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ
    db   $00, $00, $00, $00, $08, $21, $10, $06       ;; 03:6c39 ???????? ; ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE
    db   $00, $00, $00, $00, $b7, $01, $1f, $1b       ;; 03:6c41 ???????? ; ENTITY_LIZARD_OF_OZ_CANNON
    db   $00, $00, $00, $00, $dc, $08, $1f, $0e       ;; 03:6c49 ???????? ; ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE
    db   $00, $00, $00, $00, $dc, $00, $1f, $43       ;; 03:6c51 ???????? ; ENTITY_UNK6B
    db   $00, $00, $00, $02, $2b, $2f, $fa, $47       ;; 03:6c59 ???????? ; ENTITY_UNK6C
    db   $00, $00, $d0, $04, $d6, $09, $fc, $16       ;; 03:6c61 ???????? ; ENTITY_UNK6D
    db   $00, $00, $00, $00, $10, $42, $18, $63       ;; 03:6c69 ???????? ; ENTITY_CHANNEL_Z_REZ
    db   $00, $00, $00, $7c, $e0, $7f, $ff, $7f       ;; 03:6c71 ???????? ; ENTITY_UNK6F
    db   $00, $00, $00, $00, $dc, $08, $1f, $0e       ;; 03:6c79 ???????? ; ENTITY_CHANNEL_Z_METEOR
    db   $00, $00, $00, $00, $dc, $08, $1f, $0e       ;; 03:6c81 ???????? ; ENTITY_CHANNEL_Z_REZ_PROJECTILE
