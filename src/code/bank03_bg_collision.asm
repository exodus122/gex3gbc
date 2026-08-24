; ==================================================================
; BACKGROUND COLLISION
;
; Gex against the level geometry - walls, floors, ceilings, slopes, water and
; climbable surfaces. Runs once per frame from bank02_update_player.asm, after
; the player's intended movement is known and before it is applied, so what this
; file produces is a set of corrections rather than a position.
;
; ------------------------------------------------------------------
; Three layers of lookup
; ------------------------------------------------------------------
; Nothing here reads the blockmap. It reads wC000_BgMapTileIds, a
; COLLISION_MAP_COLS x COLLISION_MAP_ROWS grid of collision tile ids that
; bank00_bg_map.asm keeps in step with the visible tilemap - so a lookup is
; (Y & $F8) and (X >> 3) into a 1KB buffer, no matter where in the level Gex is.
; The buffer wraps as it scrolls, which is what every `res 2, H` in this file is
; doing: keeping H inside $C0-$C3.
;
; A collision tile id is then resolved two different ways, and the difference
; matters:
;
;   wC400_CollisionTilesetData        eight pages, one per pixel row within a
;                                     tile, each a byte per tile id giving a
;                                     bitmask of which of the 8 pixel columns are
;                                     solid on that row. This is what makes
;                                     slopes work: a slope tile is solid in a
;                                     different set of columns on each of its 8
;                                     rows. It lives in WRAM because
;                                     call_00_1056_BgMap_LoadFull transposes it
;                                     out of ROM at load time, so that indexing
;                                     it is one page add.
;   data_03_4000_TileCollisionFlags   one byte per tile id. Whole-tile properties
;                                     - is it solid, is it a ceiling, can a
;                                     climber hold onto it. Cheap, and what most
;                                     checks use.
;
; So the floor scan walks DOWN pixel rows through the first table until it finds
; a row where Gex's column is solid, and the distance it walked is how far he
; still has to fall. That is the whole of the slope handling.
;
; ------------------------------------------------------------------
; Four handlers
; ------------------------------------------------------------------
; call_03_46e0_BgCollision_Update picks one each frame. Swimming and climbing win
; outright, from the player's own state bits; otherwise
; wDC1F_CurrentBgCollisionType picks between the two movement models a map can
; use:
;
;   Sidescroller  the full treatment - wall probe, slope scan, then floor or
;                 ceiling. The only handler that corrects a position.
;   Top-down      no gravity and no walls in the sidescrolling sense. Instead a
;                 direction (BGCOLL_DIR_*) is probed, diagonals falling back to
;                 a cardinal when blocked, and the answer is how many steps of
;                 that direction are clear.
;   Swimming      probe the direction being held; if it is solid, strip the d-pad
;                 so the movement code cannot act on it.
;   Climbing      the same, against tiles that still have TILECOLL_CLIMB_BACKING.
;
; The last three never correct anything. They answer "may he go that way", and
; they all say no the same way: by clearing the d-pad bits out of
; wDC81_Player_EffectiveInputs, leaving only A/B/Select/Start.
;
; Every handler starts by rolling wDABE_CollisionFlags into
; wDABD_CollisionFlagsPrev and starting a fresh set, and the three that do not
; correct anything immediately raise BGCOLL_NO_COLLISION_BIT to tell the player
; code so.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank03_bg_collision.asm
; ------------------------------------------------------------------
; The sidescrolling handler is close to a line-by-line match, and the probe
; helpers at the bottom of each file are the same routines. The differences are
; at the edges:
;
;   handlers      gex2 has two, walking and climbing, because every gex2 level is
;                 a sidescroller and there is no swimming. gex3 adds top-down and
;                 swimming, and dispatches on wDC1F_CurrentBgCollisionType
;   solidity      gex2 reads its solidity rows straight out of ROM in this bank;
;                 gex3 reads a transposed copy in WRAM, so the tables in this
;                 file are the flags only
;   climbing      gex2 drives climbing through CLIMB_STATE_*, with two probes per
;                 entry - a far one for the square being entered and a near one
;                 for the surface being held - and can transition between climb
;                 states from here. gex3 has one probe per entry and no states:
;                 the handler only ever permits or denies the move
;   push          gex2 folds outside horizontal movement into one value; gex3
;                 keeps two, wDC84_PlayerXDeltaExtra and its second, and sums
;                 both
; ==================================================================

call_03_46e0_BgCollision_Update:
; Entry point, called once a frame from bank02_update_player.asm. Picks which of
; the four handlers runs.
;
; The player's own state decides first: PLAYER_STATE_IN_WATER and
; PLAYER_STATE_CLIMBING each have a handler of their own and neither cares what
; kind of map it is. Otherwise wDC1F_CurrentBgCollisionType selects between the
; sidescrolling and top-down handlers through
; .data_03_4704_BgCollisionTypeHandlers, and the jump is a tail call - the chosen
; handler returns to this routine's caller
    farcall call_02_5541_GetPlayerStatesFromAction
    bit  PLAYER_STATE_IN_WATER, A                                          ;; 03:46eb $cb $6f
    jp   NZ, call_03_4a3f_BgCollision_SwimmingHandler            ;; 03:46ed $c2 $3f $4a
    bit  PLAYER_STATE_CLIMBING, A                                          ;; 03:46f0 $cb $7f
    jp   NZ, call_03_4ae4_BgCollision_ClimbingHandler      ;; 03:46f2 $c2 $e4 $4a
    ld   HL, wDC1F_CurrentBgCollisionType                                     ;; 03:46f5 $21 $1f $dc
    ld   L, [HL]                                       ;; 03:46f8 $6e
    ld   H, $00                                        ;; 03:46f9 $26 $00
    add  HL, HL                                        ;; 03:46fb $29
    ld   DE, .data_03_4704_BgCollisionTypeHandlers                             ;; 03:46fc $11 $04 $47
    add  HL, DE                                        ;; 03:46ff $19
    ld   A, [HL+]                                      ;; 03:4700 $2a
    ld   H, [HL]                                       ;; 03:4701 $66
    ld   L, A                                          ;; 03:4702 $6f
    jp   HL                                            ;; 03:4703 $e9
.data_03_4704_BgCollisionTypeHandlers:
    dw   call_03_4708_BgCollision_SidescrollerHandler  ; BGCOLL_TYPE_SIDESCROLLER
    dw   call_03_48ad_BgCollision_TopDownHandler       ; BGCOLL_TYPE_TOP_DOWN

call_03_4708_BgCollision_SidescrollerHandler:
; Collision for a sidescrolling map: walking, running, jumping, falling. The only
; handler that corrects a position rather than just permitting a move.
;
; One early out: standing on an entity (wDC7B_Player_EntityStoodOnLo nonzero - a
; moving platform) raises BGCOLL_NO_COLLISION_BIT, because the platform is
; already holding him up and the floor scan must not fight it.
;
; Then three passes, in order:
;
;   1. WALL. Only if Gex is actually moving horizontally - a zero predicted delta
;      skips straight to the floor check. Probes BGCOLL_WALL_PROBE_ROWS tile rows
;      at his leading edge, ORs their flags together, and a TILECOLL_SOLID bit
;      anywhere in that column means a wall: drop the accumulated X movement and
;      raise BGCOLL_WALL_BIT.
;   2. SLOPE. Walks pixel by pixel along the path he is about to take and counts
;      how many of those pixels are solid. That count goes into the low nibble of
;      the flags (BGCOLL_SLOPE_MASK), and the player code reads it as "step up
;      this many pixels" - which is how walking up a slope works without any
;      slope-specific code. A nonzero count also counts as grounded.
;   3. FLOOR and CEILING, at .jp_03_47f6.
;
; The vertical lookahead is computed once up front: Y velocity minus 2, clamped
; so a fast fall does not probe absurdly far, then >> 4 into
; wDC8B_BgCollision_WallProbeLookahead. Wall probing starts that far above his
; head, so a wall is caught on the frame he would enter it rather than after
    ld   HL, wDABE_CollisionFlags                                     ;; 03:4708 $21 $be $da
    ld   A, [HL]                                       ;; 03:470b $7e
    ld   [HL], $00                                     ;; 03:470c $36 $00
    ld   [wDABD_CollisionFlagsPrev], A                                    ;; 03:470e $ea $bd $da
    ld   A, [wDC7B_Player_EntityStoodOnLo]                                    ;; 03:4711 $fa $7b $dc
    and  A, A                                          ;; 03:4714 $a7
    jr   Z, .jr_03_471c                                ;; 03:4715 $28 $05
    ld   HL, wDABE_CollisionFlags                                     ;; 03:4717 $21 $be $da
    set  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:471a $cb $fe                ; a platform is holding him up
.jr_03_471c:
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 03:471c $fa $8c $dc
    sub  A, $02                                        ;; 03:471f $d6 $02
    bit  7, A                                          ;; 03:4721 $cb $7f
    jr   Z, .jr_03_472b                                ;; 03:4723 $28 $06
    cp   A, $c0                                        ;; 03:4725 $fe $c0
    jr   NC, .jr_03_472b                               ;; 03:4727 $30 $02
    ld   A, $c0                                        ;; 03:4729 $3e $c0
.jr_03_472b:
    sra  A                                             ;; 03:472b $cb $2f
    sra  A                                             ;; 03:472d $cb $2f
    sra  A                                             ;; 03:472f $cb $2f
    sra  A                                             ;; 03:4731 $cb $2f
    ld   [wDC8B_BgCollision_WallProbeLookahead], A                                    ;; 03:4733 $ea $8b $dc
    call call_03_4b37_BgCollision_GetPredictedXDelta                                  ;; 03:4736 $cd $37 $4b
    jp   Z, .jp_03_47f6                                ;; 03:4739 $ca $f6 $47
    ld   E, A                                          ;; 03:473c $5f
    bit  7, E                                          ;; 03:473d $cb $7b
    jr   Z, .jr_03_474b                                ;; 03:473f $28 $0a
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4741 $fa $0e $d8
    and  A, $07                                        ;; 03:4744 $e6 $07
    add  A, E                                          ;; 03:4746 $83
    ld   C, $ff                                        ;; 03:4747 $0e $ff
    jr   .jr_03_4753                                   ;; 03:4749 $18 $08
.jr_03_474b:
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:474b $fa $0e $d8
    and  A, $07                                        ;; 03:474e $e6 $07
    add  A, E                                          ;; 03:4750 $83
    ld   C, $01                                        ;; 03:4751 $0e $01
.jr_03_4753:
    push DE                                            ;; 03:4753 $d5
    ld   A, E                                          ;; 03:4754 $7b
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:4755 $21 $0e $d8
    add  A, [HL]                                       ;; 03:4758 $86
    add  A, C                                          ;; 03:4759 $81
    ld   C, A                                          ;; 03:475a $4f
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:475b $fa $10 $d8
    sub  A, $09                                        ;; 03:475e $d6 $09
    ld   HL, wDC8B_BgCollision_WallProbeLookahead                                     ;; 03:4760 $21 $8b $dc
    and  A, $f8                                        ;; 03:4763 $e6 $f8
    ld   L, A                                          ;; 03:4765 $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:4766 $26 $30
    add  HL, HL                                        ;; 03:4768 $29
    add  HL, HL                                        ;; 03:4769 $29
    ld   A, C                                          ;; 03:476a $79
    rrca                                               ;; 03:476b $0f
    rrca                                               ;; 03:476c $0f
    rrca                                               ;; 03:476d $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:476e $e6 $1f
    or   A, L                                          ;; 03:4770 $b5
    ld   L, A                                          ;; 03:4771 $6f
    ld   D, HIGH(data_03_4000_TileCollisionFlags)      ;; 03:4772 $16 $40
    ld   C, $00                                        ;; 03:4774 $0e $00
    ld   B, BGCOLL_WALL_PROBE_ROWS                     ;; 03:4776 $06 $04
.jr_03_4778:
    ld   E, [HL]                                       ;; 03:4778 $5e
    ld   A, [DE]                                       ;; 03:4779 $1a
    or   A, C                                          ;; 03:477a $b1
    ld   C, A                                          ;; 03:477b $4f
    ld   A, L                                          ;; 03:477c $7d
    add  A, COLLISION_MAP_STRIDE                       ;; 03:477d $c6 $20                ; next tile row down
    ld   L, A                                          ;; 03:477f $6f
    ld   A, H                                          ;; 03:4780 $7c
    adc  A, $00                                        ;; 03:4781 $ce $00
    res  2, A                                          ;; 03:4783 $cb $97
    ld   H, A                                          ;; 03:4785 $67
    dec  B                                             ;; 03:4786 $05
    jr   NZ, .jr_03_4778                               ;; 03:4787 $20 $ef
    pop  DE                                            ;; 03:4789 $d1
    bit  TILECOLL_SOLID_BIT, C                         ;; 03:478a $cb $41
    jr   Z, .jr_03_47b0                                ;; 03:478c $28 $22
    ld   HL, wD80E_PlayerXPosition                                     ;; 03:478e $21 $0e $d8
    bit  7, E                                          ;; 03:4791 $cb $7b
    jr   NZ, .jr_03_479c                               ;; 03:4793 $20 $07
    ld   A, $07                                        ;; 03:4795 $3e $07
    sub  A, [HL]                                       ;; 03:4797 $96
    and  A, $07                                        ;; 03:4798 $e6 $07
    jr   .jr_03_47a1                                   ;; 03:479a $18 $05
.jr_03_479c:
    ld   A, [HL]                                       ;; 03:479c $7e
    and  A, $07                                        ;; 03:479d $e6 $07
    cpl                                                ;; 03:479f $2f
    inc  A                                             ;; 03:47a0 $3c
.jr_03_47a1:
    xor  A, A                                          ;; 03:47a1 $af
    ld   [wDC86_PlayerXVelocity], A                                    ;; 03:47a2 $ea $86 $dc
    ld   [wDC85_PlayerXDeltaExtra2], A                                    ;; 03:47a5 $ea $85 $dc
    ld   [wDC84_PlayerXDeltaExtra], A                                    ;; 03:47a8 $ea $84 $dc
    ld   HL, wDABE_CollisionFlags                                     ;; 03:47ab $21 $be $da
    set  BGCOLL_WALL_BIT, [HL]                         ;; 03:47ae $cb $f6
.jr_03_47b0:
    ld   HL, wDABE_CollisionFlags                                     ;; 03:47b0 $21 $be $da
    bit  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:47b3 $cb $7e
    jr   NZ, .jp_03_47f6                               ;; 03:47b5 $20 $3f
    call call_03_4b37_BgCollision_GetPredictedXDelta                                  ;; 03:47b7 $cd $37 $4b
    jr   Z, .jp_03_47f6                                ;; 03:47ba $28 $3a
    bit  7, A                                          ;; 03:47bc $cb $7f
    jr   NZ, .jr_03_47d5                               ;; 03:47be $20 $15
    ld   B, $00                                        ;; 03:47c0 $06 $00
    ld   C, $01                                        ;; 03:47c2 $0e $01
.jr_03_47c4:
    push AF                                            ;; 03:47c4 $f5
    push BC                                            ;; 03:47c5 $c5
    call call_03_4b4c_BgCollision_IsPixelSolid                                  ;; 03:47c6 $cd $4c $4b
    pop  BC                                            ;; 03:47c9 $c1
    and  A, A                                          ;; 03:47ca $a7
    jr   Z, .jr_03_47ce                                ;; 03:47cb $28 $01
    dec  B                                             ;; 03:47cd $05
.jr_03_47ce:
    inc  C                                             ;; 03:47ce $0c
    pop  AF                                            ;; 03:47cf $f1
    dec  A                                             ;; 03:47d0 $3d
    jr   NZ, .jr_03_47c4                               ;; 03:47d1 $20 $f1
    jr   .jr_03_47e8                                   ;; 03:47d3 $18 $13
.jr_03_47d5:
    ld   B, $00                                        ;; 03:47d5 $06 $00
    ld   C, $ff                                        ;; 03:47d7 $0e $ff
.jr_03_47d9:
    push AF                                            ;; 03:47d9 $f5
    push BC                                            ;; 03:47da $c5
    call call_03_4b4c_BgCollision_IsPixelSolid                                  ;; 03:47db $cd $4c $4b
    pop  BC                                            ;; 03:47de $c1
    and  A, A                                          ;; 03:47df $a7
    jr   Z, .jr_03_47e3                                ;; 03:47e0 $28 $01
    dec  B                                             ;; 03:47e2 $05
.jr_03_47e3:
    dec  C                                             ;; 03:47e3 $0d
    pop  AF                                            ;; 03:47e4 $f1
    inc  A                                             ;; 03:47e5 $3c
    jr   NZ, .jr_03_47d9                               ;; 03:47e6 $20 $f1
.jr_03_47e8:
    ld   A, B                                          ;; 03:47e8 $78
    cpl                                                ;; 03:47e9 $2f
    inc  A                                             ;; 03:47ea $3c
    ld   HL, wDABE_CollisionFlags                                     ;; 03:47eb $21 $be $da
    or   A, [HL]                                       ;; 03:47ee $b6
    ld   [HL], A                                       ;; 03:47ef $77
    and  A, BGCOLL_SLOPE_MASK                          ;; 03:47f0 $e6 $0f
    jr   Z, .jp_03_47f6                                ;; 03:47f2 $28 $02
    set  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:47f4 $cb $fe                ; standing on a slope counts as grounded
.jp_03_47f6:
    xor  A, A                                          ;; 03:47f6 $af
    ld   [wDC8D_Player_FloorSnapVelocity], A                                    ;; 03:47f7 $ea $8d $dc
    ld   HL, wDABE_CollisionFlags                                     ;; 03:47fa $21 $be $da
    bit  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:47fd $cb $7e
    ret  NZ                                            ;; 03:47ff $c0
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 03:4800 $fa $8c $dc
    and  A, A                                          ;; 03:4803 $a7
    jr   Z, .jr_03_480a                                ;; 03:4804 $28 $04
    bit  7, A                                          ;; 03:4806 $cb $7f
    jr   Z, .jr_03_4876                                ;; 03:4808 $28 $6c
.jr_03_480a:
    ld   A, [wD801_Player_ActionId]                                    ;; 03:480a $fa $01 $d8
    cp   A, PLAYERACTION_DEATH_IN_PIT                                        ;; 03:480d $fe $1b
    ld   A, BGCOLL_FLOOR_SEARCH_ROWS - 1               ;; 03:480f $3e $04                ; dying in a pit never lands
    jr   Z, .jr_03_486e                                ;; 03:4811 $28 $5b
    ld   B, $00                                        ;; 03:4813 $06 $00
    call call_03_4b37_BgCollision_GetPredictedXDelta                                  ;; 03:4815 $cd $37 $4b
    ld   C, A                                          ;; 03:4818 $4f
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:4819 $fa $10 $d8
    add  A, PLAYER_FEET_OFFSET                         ;; 03:481c $c6 $10
    add  A, B                                          ;; 03:481e $80
    ld   B, A                                          ;; 03:481f $47
    and  A, $f8                                        ;; 03:4820 $e6 $f8
    ld   L, A                                          ;; 03:4822 $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:4823 $26 $30
    add  HL, HL                                        ;; 03:4825 $29
    add  HL, HL                                        ;; 03:4826 $29
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4827 $fa $0e $d8
    add  A, C                                          ;; 03:482a $81
    ld   C, A                                          ;; 03:482b $4f
    rrca                                               ;; 03:482c $0f
    rrca                                               ;; 03:482d $0f
    rrca                                               ;; 03:482e $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:482f $e6 $1f
    or   A, L                                          ;; 03:4831 $b5
    ld   L, A                                          ;; 03:4832 $6f
    ld   A, [HL]                                       ;; 03:4833 $7e
    ld   DE, COLLISION_MAP_STRIDE                      ;; 03:4834 $11 $20 $00        ; the tile below, for the scan to continue into
    add  HL, DE                                        ;; 03:4837 $19
    res  2, H                                          ;; 03:4838 $cb $94
    ld   E, A                                          ;; 03:483a $5f
    ld   D, [HL]                                       ;; 03:483b $56
    ld   A, C                                          ;; 03:483c $79
    and  A, $07                                        ;; 03:483d $e6 $07
    add  A, LOW(.data_03_48a5_PixelColumnMasks)        ;; 03:483f $c6 $a5
    ld   L, A                                          ;; 03:4841 $6f
    ld   A, $00                                        ;; 03:4842 $3e $00
    adc  A, HIGH(.data_03_48a5_PixelColumnMasks)       ;; 03:4844 $ce $48
    ld   H, A                                          ;; 03:4846 $67
    ld   C, [HL]                                       ;; 03:4847 $4e
    ld   A, B                                          ;; 03:4848 $78
    and  A, $07                                        ;; 03:4849 $e6 $07
    add  A, HIGH(wC400_CollisionTilesetData)            ;; 03:484b $c6 $c4
    ld   H, A                                          ;; 03:484d $67
    ld   L, E                                          ;; 03:484e $6b
    ld   B, $00                                        ;; 03:484f $06 $00
.jr_03_4851:
    ld   A, [HL]                                       ;; 03:4851 $7e
    and  A, C                                          ;; 03:4852 $a1
    jr   NZ, .jr_03_4868                               ;; 03:4853 $20 $13
    inc  H                                             ;; 03:4855 $24
    ld   A, H                                          ;; 03:4856 $7c
    cp   A, HIGH(wC400_CollisionTilesetData) + 8       ;; 03:4857 $fe $cc                ; past pixel row 7?
    jr   NZ, .jr_03_485e                               ;; 03:4859 $20 $03
    ld   H, HIGH(wC400_CollisionTilesetData)                                        ;; 03:485b $26 $c4
    ld   L, D                                          ;; 03:485d $6a
.jr_03_485e:
    inc  B                                             ;; 03:485e $04
    ld   A, B                                          ;; 03:485f $78
    cp   A, BGCOLL_FLOOR_SEARCH_ROWS                   ;; 03:4860 $fe $05
    jr   NZ, .jr_03_4851                               ;; 03:4862 $20 $ed
    ld   A, BGCOLL_FLOOR_SEARCH_ROWS - 1               ;; 03:4864 $3e $04                ; no floor found - still falling
    jr   .jr_03_486e                                   ;; 03:4866 $18 $06
.jr_03_4868:
    ld   HL, wDABE_CollisionFlags                                     ;; 03:4868 $21 $be $da
    set  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:486b $cb $fe                ; grounded
    ld   A, B                                          ;; 03:486d $78
.jr_03_486e:
    swap A                                             ;; 03:486e $cb $37
    cpl                                                ;; 03:4870 $2f
    inc  A                                             ;; 03:4871 $3c
    ld   [wDC8D_Player_FloorSnapVelocity], A                                    ;; 03:4872 $ea $8d $dc
    ret                                                ;; 03:4875 $c9
.jr_03_4876:
    call call_03_4b37_BgCollision_GetPredictedXDelta                                  ;; 03:4876 $cd $37 $4b
    ld   C, A                                          ;; 03:4879 $4f
    ld   A, [wDC8C_PlayerYVelocity]                                    ;; 03:487a $fa $8c $dc
    swap A                                             ;; 03:487d $cb $37
    and  A, $0f                                        ;; 03:487f $e6 $0f
    add  A, $11                                        ;; 03:4881 $c6 $11
    ld   B, A                                          ;; 03:4883 $47
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:4884 $fa $10 $d8
    sub  A, B                                          ;; 03:4887 $90
    and  A, $f8                                        ;; 03:4888 $e6 $f8
    ld   L, A                                          ;; 03:488a $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:488b $26 $30
    add  HL, HL                                        ;; 03:488d $29
    add  HL, HL                                        ;; 03:488e $29
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:488f $fa $0e $d8
    add  A, C                                          ;; 03:4892 $81
    rrca                                               ;; 03:4893 $0f
    rrca                                               ;; 03:4894 $0f
    rrca                                               ;; 03:4895 $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:4896 $e6 $1f
    or   A, L                                          ;; 03:4898 $b5
    ld   L, A                                          ;; 03:4899 $6f
    ld   L, [HL]                                       ;; 03:489a $6e
    ld   H, HIGH(data_03_4000_TileCollisionFlags)      ;; 03:489b $26 $40
    bit  TILECOLL_CEILING_BIT, [HL]                    ;; 03:489d $cb $4e
    ret  Z                                             ;; 03:489f $c8
    xor  A, A                                          ;; 03:48a0 $af
    ld   [wDC8C_PlayerYVelocity], A                                    ;; 03:48a1 $ea $8c $dc
    ret                                                ;; 03:48a4 $c9
.data_03_48a5_PixelColumnMasks:
; Pixel column X within a tile -> its bit in a solidity row byte, so column 0 is
; the high bit. There are three byte-for-byte identical copies of this table in
; the file; each routine carries its own rather than sharing one
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 03:48a5 ........

call_03_48ad_BgCollision_TopDownHandler:
; Collision for a top-down map. No gravity, no slopes and no floor: the question
; is only how far in the chosen direction he may go.
;
; wDC86_PlayerXVelocity carries how many steps he wants to take - zero means he
; is not moving and the handler returns at once - and
; wDC89_BgCollision_TopDownDirection carries which way, as a BGCOLL_DIR_*.
; .data_03_48cf_TopDownDirectionHandlers dispatches on it.
;
; The four cardinals go straight to .jp_03_49ED_AdvanceAlongPath. Each diagonal
; is probed first, and when it is blocked it falls back: the two right diagonals
; try their vertical component, then straight right, then give up; the two left
; diagonals do the same, ending at straight left. A fallback rewrites BOTH
; wDC81_Player_EffectiveInputs and wDC89_BgCollision_TopDownDirection, so the
; movement code and the stepper agree on the direction actually taken.
;
; BGCOLL_NO_COLLISION_BIT is raised unconditionally, because nothing here ever
; corrects a position
    ld   hl,wDABE_CollisionFlags
    ld   a,[hl]
    ld   [hl],00
    ld   [wDABD_CollisionFlagsPrev],a
    ld   hl,wDABE_CollisionFlags
    set  BGCOLL_NO_COLLISION_BIT,[hl]                  ; top-down movement is never corrected
    ld   a,[wDC86_PlayerXVelocity]
    and  a
    ret  z
    ld   hl,wDC89_BgCollision_TopDownDirection
    ld   l,[hl]
    ld   h,00
    add  hl,hl
    ld   de,.data_03_48cf_TopDownDirectionHandlers
    add  hl,de
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    jp   hl
.data_03_48cf_TopDownDirectionHandlers:
; One handler per BGCOLL_DIR_*. The four cardinals go straight to the stepper -
; nothing can be in the way that the wall probe has not already caught - while
; each diagonal is checked first, because it may have to fall back to a cardinal
    dw   .jp_03_48E1_ResetDirectionState               ; BGCOLL_DIR_NONE
    dw   .jp_03_49ED_AdvanceAlongPath                  ; BGCOLL_DIR_UP
    dw   .jp_03_48E6_CheckMove_UpRight                 ; BGCOLL_DIR_UP_RIGHT
    dw   .jp_03_49ED_AdvanceAlongPath                  ; BGCOLL_DIR_RIGHT
    dw   .jp_03_491B_CheckMove_DownRight               ; BGCOLL_DIR_DOWN_RIGHT
    dw   .jp_03_49ED_AdvanceAlongPath                  ; BGCOLL_DIR_DOWN
    dw   .jp_03_499F_CheckMove_DownLeft                ; BGCOLL_DIR_DOWN_LEFT
    dw   .jp_03_49ED_AdvanceAlongPath                  ; BGCOLL_DIR_LEFT
    dw   .jp_03_496B_CheckMove_UpLeft                  ; BGCOLL_DIR_UP_LEFT
.jp_03_48E1_ResetDirectionState:
; Nothing is clear that way: zero the step count so the player does not move
    xor  a
    ld   [wDC86_PlayerXVelocity],a
    ret  
.jp_03_48E6_CheckMove_UpRight:
;
; Probe one step up-right, and if he wants more than one step, two. A blocked
; first step falls back to straight up; a blocked second step clamps him to the
; single step he has already been cleared for
    ld   c,$01
    ld   b,$FF
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_4900_Fallback_UpRightBlocked
    ld   a,[wDC86_PlayerXVelocity]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$FE
    call call_03_4b4c_BgCollision_IsPixelSolid
    jp   nz,.jp_03_4A15_ForceSingleStep
    ret  
.jp_03_4900_Fallback_UpRightBlocked:
; Up-right was blocked - try straight up instead, and if that works rewrite both
; the input and the direction so the rest of the frame agrees
    ld   c,$00
    ld   b,$FF
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_4950_Fallback_Right
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A | PADF_B | PADF_SELECT | PADF_START
    or   a,PADF_UP
    ld   [wDC81_Player_EffectiveInputs],a
    ld   a,BGCOLL_DIR_UP
    ld   [wDC89_BgCollision_TopDownDirection],a
    jp   .jp_03_49ED_AdvanceAlongPath

.jp_03_491B_CheckMove_DownRight:
; Down-right, mirroring .jp_03_48E6_CheckMove_UpRight
    ld   c,$01
    ld   b,$01
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_4935_Fallback_DownRightBlocked
    ld   a,[wDC86_PlayerXVelocity]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$02
    call call_03_4b4c_BgCollision_IsPixelSolid
    jp   nz,.jp_03_4A15_ForceSingleStep
    ret  
.jp_03_4935_Fallback_DownRightBlocked:
; Down-right was blocked - try straight down
    ld   c,$00
    ld   b,$01
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_4950_Fallback_Right
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A | PADF_B | PADF_SELECT | PADF_START
    or   a,PADF_DOWN
    ld   [wDC81_Player_EffectiveInputs],a
    ld   a,BGCOLL_DIR_DOWN
    ld   [wDC89_BgCollision_TopDownDirection],a
    jp   .jp_03_49ED_AdvanceAlongPath
.jp_03_4950_Fallback_Right:
; Last resort for both right-hand diagonals: straight right. Blocked here means
; nothing in that quadrant is clear, so give up entirely
    ld   c,$01
    ld   b,$00
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_48E1_ResetDirectionState
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A | PADF_B | PADF_SELECT | PADF_START
    or   a,PADF_RIGHT
    ld   [wDC81_Player_EffectiveInputs],a
    ld   a,BGCOLL_DIR_RIGHT
    ld   [wDC89_BgCollision_TopDownDirection],a
    jp   .jp_03_49ED_AdvanceAlongPath
.jp_03_496B_CheckMove_UpLeft:
; Up-left, mirroring the right-hand diagonals
    ld   c,$FF
    ld   b,$FF
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_4985_Fallback_UpLeftBlocked
    ld   a,[wDC86_PlayerXVelocity]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$FE
    call call_03_4b4c_BgCollision_IsPixelSolid
    jp   nz,.jp_03_4A15_ForceSingleStep
    ret  
.jp_03_4985_Fallback_UpLeftBlocked:
; Up-left was blocked - try straight up
    ld   c,$00
    ld   b,$FF
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_49D2_Fallback_Left
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A | PADF_B | PADF_SELECT | PADF_START
    or   a,PADF_UP
    ld   [wDC81_Player_EffectiveInputs],a
    ld   a,BGCOLL_DIR_UP
    ld   [wDC89_BgCollision_TopDownDirection],a
    jr   .jp_03_49ED_AdvanceAlongPath
.jp_03_499F_CheckMove_DownLeft:
; Down-left
    ld   c,$FF
    ld   b,$01
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_49B8_Fallback_DownLeftBlocked
    ld   a,[wDC86_PlayerXVelocity]
    cp   a,$02
    ret  c
    ld   c,$02
    ld   b,$02
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_4A15_ForceSingleStep
    ret  
.jp_03_49B8_Fallback_DownLeftBlocked:
; Down-left was blocked - try straight down
    ld   c,$00
    ld   b,$01
    call call_03_4b4c_BgCollision_IsPixelSolid
    jr   nz,.jp_03_49D2_Fallback_Left
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A | PADF_B | PADF_SELECT | PADF_START
    or   a,PADF_DOWN
    ld   [wDC81_Player_EffectiveInputs],a
    ld   a,BGCOLL_DIR_DOWN
    ld   [wDC89_BgCollision_TopDownDirection],a
    jr   .jp_03_49ED_AdvanceAlongPath
.jp_03_49D2_Fallback_Left:
; Last resort for both left-hand diagonals: straight left
    ld   c,$FF
    ld   b,$00
    call call_03_4b4c_BgCollision_IsPixelSolid
    jp   nz,.jp_03_48E1_ResetDirectionState
    ld   a,[wDC81_Player_EffectiveInputs]
    and  a,PADF_A | PADF_B | PADF_SELECT | PADF_START
    or   a,PADF_LEFT
    ld   [wDC81_Player_EffectiveInputs],a
    ld   a,BGCOLL_DIR_LEFT
    ld   [wDC89_BgCollision_TopDownDirection],a
    jr   .jp_03_49ED_AdvanceAlongPath
.jp_03_49ED_AdvanceAlongPath:
; How many steps of wDC89_BgCollision_TopDownDirection are actually clear.
; Walks the offset pairs at .data_03_4a1b_TopDownStepOffsets, probing each and
; counting, and stops at the first solid one. The count replaces
; wDC86_PlayerXVelocity, so a partly blocked move becomes a shorter one rather
; than no move at all
    ld   hl,wDC89_BgCollision_TopDownDirection
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,hl
    ld   de,.data_03_4a1b_TopDownStepOffsets
    add  hl,de
    ld   e,$00
    ld   a,[wDC86_PlayerXVelocity]
    ld   d,a
.jp_03_49FF_PathStepLoop_CheckTiles:
; One probe per iteration: E counts the clear ones, D the steps still wanted
    ldi  a,[hl]
    ld   c,a
    ldi  a,[hl]
    ld   b,a
    push hl
    push de
    call call_03_4b4c_BgCollision_IsPixelSolid
    pop  de
    pop  hl
    jr   nz,.jp_03_4A10_CommitStepCount
    inc  e
    dec  d
    jr   nz,.jp_03_49FF_PathStepLoop_CheckTiles
.jp_03_4A10_CommitStepCount:
; Blocked, or out of steps: commit however many were clear
    ld   a,e
    ld   [wDC86_PlayerXVelocity],a
    ret  
.jp_03_4A15_ForceSingleStep:
; The second probe of a diagonal was blocked but the first was clear, so let him
; take exactly one step
    ld   a,$01
    ld   [wDC86_PlayerXVelocity],a
    ret  
.data_03_4a1b_TopDownStepOffsets:
; Four bytes per BGCOLL_DIR_*: two (X, Y) tile offsets, one step out and then
; two. .jp_03_49ED_AdvanceAlongPath reads pairs from here until a probe comes
; back solid or it runs out of steps, so a move of more than two steps walks on
; into the next direction's entry
    db   $00, $00, $00, $00                            ; BGCOLL_DIR_NONE
    db   $00, $ff, $00, $fe                            ; BGCOLL_DIR_UP
    db   $01, $ff, $02, $fe                            ; BGCOLL_DIR_UP_RIGHT
    db   $01, $00, $02, $00                            ; BGCOLL_DIR_RIGHT
    db   $01, $01, $02, $02                            ; BGCOLL_DIR_DOWN_RIGHT
    db   $00, $01, $00, $02                            ; BGCOLL_DIR_DOWN
    db   $ff, $01, $fe, $02                            ; BGCOLL_DIR_DOWN_LEFT
    db   $ff, $00, $fe, $00                            ; BGCOLL_DIR_LEFT
    db   $ff, $ff, $fe, $fe                            ; BGCOLL_DIR_UP_LEFT

call_03_4a3f_BgCollision_SwimmingHandler:
; Collision while Gex is in water. Nothing here corrects a position - swimming
; moves him directly in bank 2 - so this only ever answers "may he go that way",
; and it starts by raising BGCOLL_NO_COLLISION_BIT to switch the walking
; corrections off for the frame.
;
; wD801_Player_ActionId picks one of four scripts out of
; .data_03_4a98_SwimScriptTable. The script's mask byte says which d-pad bits it
; answers for at all; anything outside it returns immediately with the input
; untouched, and the movement code then acts on that press with no collision
; check behind it. Inside the mask, the held direction is matched against the
; entries by an exact `cp`, so pressing three directions at once matches nothing.
;
; A matched entry gives one probe offset. If that pixel is solid - or if no entry
; matched - .jr_03_4a7e strips every d-pad bit out of
; wDC81_Player_EffectiveInputs, leaving only A/B/Select/Start, which is what
; stops him swimming into scenery
    ld   HL, wDABE_CollisionFlags                                     ;; 03:4a3f $21 $be $da
    ld   A, [HL]                                       ;; 03:4a42 $7e
    ld   [HL], $00                                     ;; 03:4a43 $36 $00
    ld   [wDABD_CollisionFlagsPrev], A                                    ;; 03:4a45 $ea $bd $da
    set  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:4a48 $cb $fe                ; swimming is never corrected
    ld   A, [wD801_Player_ActionId]                                    ;; 03:4a4a $fa $01 $d8
    ld   L, $03                                        ;; 03:4a4d $2e $03
    cp   A, PLAYERACTION_WATER_TAIL_SPIN                                        ;; 03:4a4f $fe $1f
    jr   Z, .jr_03_4a61                                ;; 03:4a51 $28 $0e
    ld   L, $02                                        ;; 03:4a53 $2e $02
    cp   A, PLAYERACTION_WATER_DIVING                                        ;; 03:4a55 $fe $21
    jr   Z, .jr_03_4a61                                ;; 03:4a57 $28 $08
    ld   L, $01                                        ;; 03:4a59 $2e $01
    cp   A, PLAYERACTION_WATER_TREADING                                        ;; 03:4a5b $fe $20
    jr   Z, .jr_03_4a61                                ;; 03:4a5d $28 $02
    ld   L, $00                                        ;; 03:4a5f $2e $00
.jr_03_4a61:
    ld   H, $00                                        ;; 03:4a61 $26 $00
    add  HL, HL                                        ;; 03:4a63 $29
    ld   DE, .data_03_4a98_SwimScriptTable                             ;; 03:4a64 $11 $98 $4a
    add  HL, DE                                        ;; 03:4a67 $19
    ld   A, [HL+]                                      ;; 03:4a68 $2a
    ld   H, [HL]                                       ;; 03:4a69 $66
    ld   L, A                                          ;; 03:4a6a $6f
    ld   A, [wDC81_Player_EffectiveInputs]                                    ;; 03:4a6b $fa $81 $dc
    and  A, [HL]                                       ;; 03:4a6e $a6
    ret  Z                                             ;; 03:4a6f $c8
    inc  HL                                            ;; 03:4a70 $23
    ld   B, [HL]                                       ;; 03:4a71 $46
    inc  HL                                            ;; 03:4a72 $23
    ld   E, [HL]                                       ;; 03:4a73 $5e
    inc  HL                                            ;; 03:4a74 $23
    ld   D, [HL]                                       ;; 03:4a75 $56
    inc  HL                                            ;; 03:4a76 $23
.jr_03_4a77:
    cp   A, [HL]                                       ;; 03:4a77 $be
    jr   Z, .jr_03_4a87                                ;; 03:4a78 $28 $0d
    add  HL, DE                                        ;; 03:4a7a $19
    dec  B                                             ;; 03:4a7b $05
    jr   NZ, .jr_03_4a77                               ;; 03:4a7c $20 $f9
.jr_03_4a7e:
    ld   A, [wDC81_Player_EffectiveInputs]                                    ;; 03:4a7e $fa $81 $dc
    and  A, PADF_A | PADF_B | PADF_SELECT | PADF_START                                        ;; 03:4a81 $e6 $0f
    ld   [wDC81_Player_EffectiveInputs], A                                    ;; 03:4a83 $ea $81 $dc
    ret                                                ;; 03:4a86 $c9
.jr_03_4a87:
    inc  HL                                            ;; 03:4a87 $23
    ld   A, [HL+]                                      ;; 03:4a88 $2a
    ld   C, A                                          ;; 03:4a89 $4f
    ld   A, [HL]                                       ;; 03:4a8a $7e
    sub  A, PLAYER_FEET_OFFSET - 1                     ;; 03:4a8b $d6 $0f                ; cancel the bias the probe adds back
    ld   B, A                                          ;; 03:4a8d $47
    push BC                                            ;; 03:4a8e $c5
    push HL                                            ;; 03:4a8f $e5
    call call_03_4b4c_BgCollision_IsPixelSolid                                  ;; 03:4a90 $cd $4c $4b
    pop  HL                                            ;; 03:4a93 $e1
    pop  BC                                            ;; 03:4a94 $c1
    jr   NZ, .jr_03_4a7e                               ;; 03:4a95 $20 $e7
    ret                                                ;; 03:4a97 $c9
.data_03_4a98_SwimScriptTable:
; One script per swimming action. Ordinary swimming and tail spinning share the
; eight-direction script; treading gets a two-direction one.
;
; The entries have the same five-byte shape the climbing tables use elsewhere,
; but only the first three bytes are ever read - input, X offset, Y offset - and
; the Y offset is stored pre-biased by PLAYER_FEET_OFFSET - 1, which the handler
; subtracts back out so the probe lands relative to the player's origin rather
; than his feet. The trailing pair is the same direction in whole tiles and is
; dead
    dw   .swim_script_swimming                         ; any other water action
    dw   .swim_script_treading                         ; PLAYERACTION_WATER_TREADING
    dw   .swim_script_diving                           ; PLAYERACTION_WATER_DIVING
    dw   .swim_script_swimming                         ; PLAYERACTION_WATER_TAIL_SPIN
.swim_script_swimming:
; All eight directions, so a swim can be aimed anywhere
    climb_script PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT, 8, SWIM_SCRIPT_ENTRY_SIZE
    swim_script_entry PADF_UP,                    $00, $ef, $00, $ff   ; probes 32 px up
    swim_script_entry PADF_DOWN,                  $00, $10, $00, $01   ; 1 px down
    swim_script_entry PADF_LEFT,                  $f7, $00, $ff, $00   ; 9 px left, 15 up
    swim_script_entry PADF_RIGHT,                 $09, $00, $01, $00
    swim_script_entry PADF_UP | PADF_LEFT,        $f7, $ef, $ff, $ff
    swim_script_entry PADF_DOWN | PADF_LEFT,      $f7, $10, $ff, $01
    swim_script_entry PADF_UP | PADF_RIGHT,       $09, $ef, $01, $ff
    swim_script_entry PADF_DOWN | PADF_RIGHT,     $09, $10, $01, $01
.swim_script_treading:
; Treading water answers for left and right only - bobbing up and down at the
; surface is never collision checked
    climb_script PADF_LEFT | PADF_RIGHT, 2, SWIM_SCRIPT_ENTRY_SIZE
    swim_script_entry PADF_LEFT,                  $f7, $00, $ff, $00
    swim_script_entry PADF_RIGHT,                 $09, $00, $01, $00
.swim_script_diving:
; Diving is never collision checked at all: the mask byte is $00, so the
; handler's `and A, [HL]` can never be nonzero and it returns before reading
; anything else. The rest of these bytes are the wreckage of a script that would
; have followed - a count of 1 and a stride of $0500 are not a usable header, and
; nothing reads them
    db   $00                                           ; input mask - matches nothing
    db   $01, $00, $05, $00, $80, $00, $10, $00, $01   ; never read

call_03_4ae4_BgCollision_ClimbingHandler:
; Collision while Gex is on a climbable surface. Same shape as the swimming
; handler above and the same three ways out, but with one script rather than
; four, and the probe offsets are whole tiles rather than pixels.
;
; The test is inverted from the others: a climber may only move into a tile that
; still has TILECOLL_CLIMB_BACKING set - something to hold onto - so a clear
; probe is what denies the move here. Failing it strips the d-pad the same way.
;
; Unlike gex2 this handler holds no state of its own: it permits or denies, and
; the climb itself is entirely the player code's business
    ld   HL, wDABE_CollisionFlags                                     ;; 03:4ae4 $21 $be $da
    ld   A, [HL]                                       ;; 03:4ae7 $7e
    ld   [HL], $00                                     ;; 03:4ae8 $36 $00
    ld   [wDABD_CollisionFlagsPrev], A                                    ;; 03:4aea $ea $bd $da
    set  BGCOLL_NO_COLLISION_BIT, [HL]                 ;; 03:4aed $cb $fe                ; climbing is never corrected
    ld   HL, .data_03_4b1b_ClimbScript                             ;; 03:4aef $21 $1b $4b
    ld   A, [wDC81_Player_EffectiveInputs]                                    ;; 03:4af2 $fa $81 $dc
    and  A, [HL]                                       ;; 03:4af5 $a6
    ret  Z                                             ;; 03:4af6 $c8
    inc  HL                                            ;; 03:4af7 $23
    ld   B, [HL]                                       ;; 03:4af8 $46
    inc  HL                                            ;; 03:4af9 $23
    ld   E, [HL]                                       ;; 03:4afa $5e
    inc  HL                                            ;; 03:4afb $23
    ld   D, [HL]                                       ;; 03:4afc $56
    inc  HL                                            ;; 03:4afd $23
.jr_03_4afe:
    cp   A, [HL]                                       ;; 03:4afe $be
    jr   Z, .jr_03_4b0e                                ;; 03:4aff $28 $0d
    add  HL, DE                                        ;; 03:4b01 $19
    dec  B                                             ;; 03:4b02 $05
    jr   NZ, .jr_03_4afe                               ;; 03:4b03 $20 $f9
.jr_03_4b05:
    ld   A, [wDC81_Player_EffectiveInputs]                                    ;; 03:4b05 $fa $81 $dc
    and  A, PADF_A | PADF_B | PADF_SELECT | PADF_START                                        ;; 03:4b08 $e6 $0f
    ld   [wDC81_Player_EffectiveInputs], A                                    ;; 03:4b0a $ea $81 $dc
    ret                                                ;; 03:4b0d $c9
.jr_03_4b0e:
    inc  HL                                            ;; 03:4b0e $23
    ld   A, [HL+]                                      ;; 03:4b0f $2a
    ld   C, A                                          ;; 03:4b10 $4f
    ld   A, [HL]                                       ;; 03:4b11 $7e
    ld   B, A                                          ;; 03:4b12 $47
    call call_03_4c12_BgCollision_GetTileAndFlags                                  ;; 03:4b13 $cd $12 $4c
    bit  TILECOLL_CLIMB_BACKING_BIT, B                 ;; 03:4b16 $cb $58
    jr   Z, .jr_03_4b05                                ;; 03:4b18 $28 $eb
    ret                                                ;; 03:4b1a $c9
.data_03_4b1b_ClimbScript:
; The single climbing script. All eight directions, one probe each, offsets in
; whole tiles - a climber may only move into a tile that still has
; TILECOLL_CLIMB_BACKING set
    climb_script PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT, 8, CLIMB_SCRIPT_ENTRY_SIZE
    climb_script_entry PADF_UP,                   0,   -1
    climb_script_entry PADF_DOWN,                 0,    1
    climb_script_entry PADF_LEFT,                -1,    0
    climb_script_entry PADF_RIGHT,                1,    0
    climb_script_entry PADF_UP | PADF_LEFT,      -1,   -1
    climb_script_entry PADF_DOWN | PADF_LEFT,    -1,    1
    climb_script_entry PADF_UP | PADF_RIGHT,      1,   -1
    climb_script_entry PADF_DOWN | PADF_RIGHT,    1,    1

call_03_4b37_BgCollision_GetPredictedXDelta:
; A = how far Gex is about to move horizontally this frame, signed: his own
; speed with the sign of his facing, plus whatever a platform or walkway is
; adding through wDC84_PlayerXDeltaExtra and wDC85_PlayerXDeltaExtra2.
;
; Every probe in the sidescrolling handler is aimed with this, which is why
; collision is checked against where he is going rather than where he is. A zero
; result also sets Z, and the callers use that to skip the wall and slope passes
; entirely - not moving sideways means there is nothing to hit
    ld   A, [wDC86_PlayerXVelocity]                                    ;; 03:4b37 $fa $86 $dc
    ld   HL, wD80D_PlayerFacingDirection                                     ;; 03:4b3a $21 $0d $d8
    bit  ENTITY_FACING_LEFT_BIT, [HL]                  ;; 03:4b3d $cb $6e
    jr   Z, .jr_03_4b43                                ;; 03:4b3f $28 $02
    cpl                                                ;; 03:4b41 $2f
    inc  A                                             ;; 03:4b42 $3c
.jr_03_4b43:
    ld   HL, wDC84_PlayerXDeltaExtra                                     ;; 03:4b43 $21 $84 $dc
    add  A, [HL]                                       ;; 03:4b46 $86
    ld   HL, wDC85_PlayerXDeltaExtra2                                     ;; 03:4b47 $21 $85 $dc
    add  A, [HL]                                       ;; 03:4b4a $86
    ret                                                ;; 03:4b4b $c9

call_03_4b4c_BgCollision_IsPixelSolid:
; Is one single pixel solid? B and C are Y and X offsets from the player, taken
; from his feet (PLAYER_FEET_OFFSET - 1); A comes back nonzero if that pixel is
; inside geometry.
;
; The pixel, not the tile - it looks the collision tile id up in
; wC000_BgMapTileIds, then takes the solidity row for (Y & 7) out of
; wC400_CollisionTilesetData and tests the one bit for (X & 7). That per-pixel
; resolution is what lets the slope scan count an exact rise rather than snapping
; to whole tiles
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:4b4c $fa $10 $d8
    add  A, PLAYER_FEET_OFFSET - 1                     ;; 03:4b4f $c6 $0f
    add  A, B                                          ;; 03:4b51 $80
    ld   B, A                                          ;; 03:4b52 $47
    and  A, $f8                                        ;; 03:4b53 $e6 $f8
    ld   L, A                                          ;; 03:4b55 $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:4b56 $26 $30
    add  HL, HL                                        ;; 03:4b58 $29
    add  HL, HL                                        ;; 03:4b59 $29
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4b5a $fa $0e $d8
    add  A, C                                          ;; 03:4b5d $81
    ld   C, A                                          ;; 03:4b5e $4f
    rrca                                               ;; 03:4b5f $0f
    rrca                                               ;; 03:4b60 $0f
    rrca                                               ;; 03:4b61 $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:4b62 $e6 $1f
    or   A, L                                          ;; 03:4b64 $b5
    ld   L, A                                          ;; 03:4b65 $6f
    ld   E, [HL]                                       ;; 03:4b66 $5e
    ld   A, B                                          ;; 03:4b67 $78
    and  A, $07                                        ;; 03:4b68 $e6 $07
    add  A, HIGH(wC400_CollisionTilesetData)            ;; 03:4b6a $c6 $c4
    ld   D, A                                          ;; 03:4b6c $57
    ld   A, C                                          ;; 03:4b6d $79
    and  A, $07                                        ;; 03:4b6e $e6 $07
    ld   L, A                                          ;; 03:4b70 $6f
    ld   H, $00                                        ;; 03:4b71 $26 $00
    ld   BC, .data_03_4b7a_PixelColumnMasks                             ;; 03:4b73 $01 $7a $4b
    add  HL, BC                                        ;; 03:4b76 $09
    ld   A, [DE]                                       ;; 03:4b77 $1a
    and  A, [HL]                                       ;; 03:4b78 $a6
    ret                                                ;; 03:4b79 $c9
.data_03_4b7a_PixelColumnMasks:
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 03:4b7a ????????

call_03_4b82_BgCollision_IsPixelSolidNoFeetOffset:
; The same probe as above without the PLAYER_FEET_OFFSET bias, so B is measured
; from the player's origin instead of his feet. Nothing calls it
    ld   a,[wD810_PlayerYPosition]
    add  b
    ld   b,a
    and  a,$F8
    ld   l,a
    ld   h,HIGH(wC000_BgMapTileIds) >> 2
    add  hl,hl
    add  hl,hl
    ld   a,[wD80E_PlayerXPosition]
    add  c
    ld   c,a
    rrca 
    rrca 
    rrca 
    and  a,COLLISION_MAP_COLS - 1
    or   l
    ld   l,a
    ld   e,[hl]
    ld   a,b
    and  a,$07
    add  a,HIGH(wC400_CollisionTilesetData)
    ld   d,a
    ld   a,c
    and  a,$07
    ld   l,a
    ld   h,$00
    ld   bc,.data_03_4bae_PixelColumnMasks
    add  hl,bc
    ld   a,[de]
    and  [hl]
    ret
.data_03_4bae_PixelColumnMasks:
    db   $80, $40, $20, $10, $08, $04, $02, $01                            ;; 03:4bb2 ????

call_03_4bb6_BgCollision_CacheNearbyTileTypes:
; Caches the collision tile ids around Gex so the player code in bank 2 can react
; to them without repeating the lookup - water, doors, springs and climbable
; surfaces are all decided from these bytes. Called once a frame, straight after
; call_03_46e0_BgCollision_Update.
;
;   wDC97_TileTypeAboveGexsHead        one tile row above his head
;   wDC92_TileTypeBehindGexsUpperBody  his head
;   wDC93_TileTypeBehindGexsLowerBody  his body
;   wDC95_FloorTileType                the tile he is standing on
;   wDC94_TileTypeBehindGexsFace       one row up and one tile ahead in the
;                                      direction he faces - what he is looking at
;
; The first four are a straight column, so they walk by COLLISION_MAP_STRIDE with
; the usual wrap. Only the last depends on facing
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:4bb6 $fa $10 $d8
    sub  A, PLAYER_FEET_OFFSET                         ;; 03:4bb9 $d6 $10                ; start one tile row above his head
    and  A, $f8                                        ;; 03:4bbb $e6 $f8
    ld   L, A                                          ;; 03:4bbd $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:4bbe $26 $30
    add  HL, HL                                        ;; 03:4bc0 $29
    add  HL, HL                                        ;; 03:4bc1 $29
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4bc2 $fa $0e $d8
    rrca                                               ;; 03:4bc5 $0f
    rrca                                               ;; 03:4bc6 $0f
    rrca                                               ;; 03:4bc7 $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:4bc8 $e6 $1f
    or   A, L                                          ;; 03:4bca $b5
    ld   L, A                                          ;; 03:4bcb $6f
    ld   A, [HL]                                       ;; 03:4bcc $7e
    ld   [wDC97_TileTypeAboveGexsHead], A                                    ;; 03:4bcd $ea $97 $dc
    ld   DE, COLLISION_MAP_STRIDE * 2                  ;; 03:4bd0 $11 $40 $00        ; down to his head
    add  HL, DE                                        ;; 03:4bd3 $19
    res  2, H                                          ;; 03:4bd4 $cb $94
    ld   A, [HL]                                       ;; 03:4bd6 $7e
    ld   [wDC92_TileTypeBehindGexsUpperBody], A                                    ;; 03:4bd7 $ea $92 $dc
    ld   DE, COLLISION_MAP_STRIDE                      ;; 03:4bda $11 $20 $00
    add  HL, DE                                        ;; 03:4bdd $19
    res  2, H                                          ;; 03:4bde $cb $94
    ld   A, [HL]                                       ;; 03:4be0 $7e
    ld   [wDC93_TileTypeBehindGexsLowerBody], A                                    ;; 03:4be1 $ea $93 $dc
    add  HL, DE                                        ;; 03:4be4 $19
    res  2, H                                          ;; 03:4be5 $cb $94
    ld   A, [HL]                                       ;; 03:4be7 $7e
    ld   [wDC95_FloorTileType], A                                    ;; 03:4be8 $ea $95 $dc
    ld   C, $09                                        ;; 03:4beb $0e $09
    ld   A, [wD80D_PlayerFacingDirection]                                    ;; 03:4bed $fa $0d $d8
    cp   A, ENTITY_FACING_RIGHT                        ;; 03:4bf0 $fe $00
    jr   Z, .jr_03_4bf6                                ;; 03:4bf2 $28 $02
    ld   C, $f7                                        ;; 03:4bf4 $0e $f7
.jr_03_4bf6:
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:4bf6 $fa $10 $d8
    sub  A, $08                                        ;; 03:4bf9 $d6 $08
    and  A, $f8                                        ;; 03:4bfb $e6 $f8
    ld   L, A                                          ;; 03:4bfd $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:4bfe $26 $30
    add  HL, HL                                        ;; 03:4c00 $29
    add  HL, HL                                        ;; 03:4c01 $29
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4c02 $fa $0e $d8
    add  A, C                                          ;; 03:4c05 $81
    rrca                                               ;; 03:4c06 $0f
    rrca                                               ;; 03:4c07 $0f
    rrca                                               ;; 03:4c08 $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:4c09 $e6 $1f
    or   A, L                                          ;; 03:4c0b $b5
    ld   L, A                                          ;; 03:4c0c $6f
    ld   A, [HL]                                       ;; 03:4c0d $7e
    ld   [wDC94_TileTypeBehindGexsFace], A                                    ;; 03:4c0e $ea $94 $dc
    ret                                                ;; 03:4c11 $c9

call_03_4c12_BgCollision_GetTileAndFlags:
; Looks up one whole tile at B, C offsets from the player and returns BOTH
; halves:
;   B = its data_03_4000_TileCollisionFlags byte
;   C = the collision tile id itself
;
; Unlike call_03_4b4c_BgCollision_IsPixelSolid this is whole-tile, with no
; per-pixel detail - which is all the climbing handler needs, since a climbable
; surface is a property of the tile rather than of one pixel of it
    ld   A, [wD810_PlayerYPosition]                                    ;; 03:4c12 $fa $10 $d8
    add  A, B                                          ;; 03:4c15 $80
    and  A, $f8                                        ;; 03:4c16 $e6 $f8
    ld   L, A                                          ;; 03:4c18 $6f
    ld   H, HIGH(wC000_BgMapTileIds) >> 2               ;; 03:4c19 $26 $30
    add  HL, HL                                        ;; 03:4c1b $29
    add  HL, HL                                        ;; 03:4c1c $29
    ld   A, [wD80E_PlayerXPosition]                                    ;; 03:4c1d $fa $0e $d8
    add  A, C                                          ;; 03:4c20 $81
    rrca                                               ;; 03:4c21 $0f
    rrca                                               ;; 03:4c22 $0f
    rrca                                               ;; 03:4c23 $0f
    and  A, COLLISION_MAP_COLS - 1                      ;; 03:4c24 $e6 $1f
    or   A, L                                          ;; 03:4c26 $b5
    ld   L, A                                          ;; 03:4c27 $6f
    ld   C, [HL]                                       ;; 03:4c28 $4e
    ld   B, HIGH(data_03_4000_TileCollisionFlags)      ;; 03:4c29 $06 $40
    ld   A, [BC]                                       ;; 03:4c2b $0a
    ld   B, A                                          ;; 03:4c2c $47
    ret                                                ;; 03:4c2d $c9

call_03_4c2e_BgCollision_IsTileClimbable:
; Is the tile Gex is standing in TILE_TYPE_CLIMBABLE? Returns Z when it is.
;
; A thin wrapper over call_03_4c12_BgCollision_GetTileAndFlags with zero offsets
; that ignores the flags byte and compares the id, because this one type is
; identified by id rather than by a flag bit
    ld   BC, $00                                       ;; 03:4c2e $01 $00 $00
    call call_03_4c12_BgCollision_GetTileAndFlags                                  ;; 03:4c31 $cd $12 $4c
    ld   A, C                                          ;; 03:4c34 $79
    cp   A, TILE_TYPE_CLIMBABLE                        ;; 03:4c35 $fe $3d
    ret                                                ;; 03:4c37 $c9
    