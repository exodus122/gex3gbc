; ==================================================================
; Bank 3. The status bar: the lives and collectible counters, the four health pips,
; the animated fly coin tiles and the bonus stage clock.
;
; gex3's HUD is NOT sprites. It is drawn into the window tilemap at $9C00, two rows
; of tiles that the window layer holds over the bottom of the screen, so the whole
; status bar costs zero OAM entries and never competes with the ten-sprites-per-line
; limit. That is the single biggest difference from gex2, whose status row is eight
; OAM sprites built in bank03_oam_build.asm.
;
; Nothing here runs every frame. call_03_747d_HUD_Update is driven entirely by
; wDB69_HUDDirtyFlags: whoever changes a value raises the matching HUD_DIRTY_* bit,
; and the update clears it as it services it. One bit per pass, and the passes are
; mutually exclusive - the counters pass returns before the health pass is reached -
; so a frame that dirties two things redraws them over two frames.
;
; Two of the four passes do not touch the tilemap at all. The fly coin animation and
; the bonus clock rewrite the PIXELS behind tiles that are already on screen, by
; HDMA into VRAM bank 1, which is why they can animate without the tilemap changing.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank03_hud_tiles.asm
; ------------------------------------------------------------------
; Both files answer "the HUD changed, put new pixels in VRAM", and both are driven
; by a dirty-flag byte. Past that they have little in common:
;
;   the medium    gex2's HUD is eight OAM sprites whose tile ids never change; this
;                 file's counterparts rewrite tilemap entries instead. gex2's file
;                 therefore only ever loads tile DATA, while this one writes tile
;                 NUMBERS as well
;   digits        gex2 loads digit glyphs into VRAM and the sprites point at them.
;                 gex3 converts the number to digits in
;                 call_03_74f5_HUD_DrawNumberOnStatusBar and writes four tilemap
;                 entries per digit - two rows of two - because a digit is 16x16
;   transfers     gex2 copies with MemCopy and a 32-byte VRAM helper. gex3 uses
;                 general purpose DMA straight into VRAM bank 1, the same mechanism
;                 the tileset loader uses
;   absent here   gex2's per-world collectible icon sets, its palette loader, its
;                 demo-mode banner and the whole tile-loading half of its file have
;                 no gex3 counterpart - gex3 loads the status bar's tiles once with
;                 the rest of the level's graphics
; ==================================================================

call_03_747d_HUD_Update:
; The status bar's dirty-flag pump, called once a frame.
;
; HUD_DIRTY_COUNTERS_BIT redraws the two numbers - lives at HUD_TILEMAP_LIVES and
; collectibles at HUD_TILEMAP_COLLECTIBLES - and RETURNS, so a frame never does more
; than one pass.
;
; HUD_DIRTY_HEALTH_BIT redraws the four health pips, and is the interesting half.
; Each pip is drawn in one of five states, chosen by building a three-bit index in E:
; bit 0 says this pip is within wDC50_Player_Health, bit 1 that it is within
; wDC4F_PawCoinExtraHealth, and bit 2 that it is within the health Gex would have
; WITHOUT the paw coin bonus (health minus HUD_HEALTH_PIP_COUNT, floored at zero).
; That index picks a tile from .data_03_74ed_HealthPipTiles, and the pip is written
; as four tilemap entries - two across, two down, consecutive tile ids - so the
; bonus health reads as a different colour rather than as extra pips.
;
; If neither bit is set it falls through to the bonus stage clock
    ld   HL, wDB69_HUDDirtyFlags                      ;; 03:747d $21 $69 $db
    bit  HUD_DIRTY_COUNTERS_BIT, [HL]                 ;; 03:7480 $cb $46
    jr   Z, .jr_03_749d                               ;; 03:7482 $28 $19
    res  HUD_DIRTY_COUNTERS_BIT, [HL]                 ;; 03:7484 $cb $86
    ld   A, [wDC4E_LivesRemaining]                    ;; 03:7486 $fa $4e $dc
    ld   HL, HUD_TILEMAP_LIVES                        ;; 03:7489 $21 $02 $9c
    ld   DE, HUD_TILEMAP_LIVES + HUD_TILEMAP_ROW_STRIDE ;; 03:748c $11 $22 $9c
    call call_03_74f5_HUD_DrawNumberOnStatusBar       ;; 03:748f $cd $f5 $74
    ld   A, [wDC68_CollectibleAmount]                 ;; 03:7492 $fa $68 $dc
    ld   HL, HUD_TILEMAP_COLLECTIBLES                 ;; 03:7495 $21 $11 $9c
    ld   DE, HUD_TILEMAP_COLLECTIBLES + HUD_TILEMAP_ROW_STRIDE ;; 03:7498 $11 $31 $9c
    jr   call_03_74f5_HUD_DrawNumberOnStatusBar       ;; 03:749b $18 $58
.jr_03_749d:
    bit  HUD_DIRTY_HEALTH_BIT, [HL]                   ;; 03:749d $cb $4e
    jp   Z, call_03_757e_HUD_AnimateBonusStageTimer   ;; 03:749f $ca $7e $75
    res  HUD_DIRTY_HEALTH_BIT, [HL]                   ;; 03:74a2 $cb $8e
    ld   B, $00                                       ;; 03:74a4 $06 $00
.jr_03_74a6:
    ld   A, [wDC50_Player_Health]                     ;; 03:74a6 $fa $50 $dc
    sub  A, HUD_HEALTH_PIP_COUNT                      ;; 03:74a9 $d6 $04
    jr   NC, .jr_03_74ae                              ;; 03:74ab $30 $01
    xor  A, A                                         ;; 03:74ad $af
.jr_03_74ae:
    ld   D, A                                         ;; 03:74ae $57
    ld   E, $00                                       ;; 03:74af $1e $00
    ld   A, B                                         ;; 03:74b1 $78
    ld   HL, wDC50_Player_Health                      ;; 03:74b2 $21 $50 $dc
    cp   A, [HL]                                      ;; 03:74b5 $be
    jr   NC, .jr_03_74ba                              ;; 03:74b6 $30 $02
    set  0, E                                         ;; 03:74b8 $cb $c3
.jr_03_74ba:
    ld   HL, wDC4F_PawCoinExtraHealth                 ;; 03:74ba $21 $4f $dc
    cp   A, [HL]                                      ;; 03:74bd $be
    jr   NC, .jr_03_74cb                              ;; 03:74be $30 $0b
    set  1, E                                         ;; 03:74c0 $cb $cb
    bit  0, E                                         ;; 03:74c2 $cb $43
    jr   Z, .jr_03_74cb                               ;; 03:74c4 $28 $05
    cp   A, D                                         ;; 03:74c6 $ba
    jr   NC, .jr_03_74cb                              ;; 03:74c7 $30 $02
    set  2, E                                         ;; 03:74c9 $cb $d3
.jr_03_74cb:
    ld   D, $00                                       ;; 03:74cb $16 $00
    ld   HL, .data_03_74ed_HealthPipTiles             ;; 03:74cd $21 $ed $74
    add  HL, DE                                       ;; 03:74d0 $19
    ld   A, [HL]                                      ;; 03:74d1 $7e
    ld   L, B                                         ;; 03:74d2 $68
    ld   H, $00                                       ;; 03:74d3 $26 $00
    add  HL, HL                                       ;; 03:74d5 $29
    ld   DE, HUD_TILEMAP_HEALTH                       ;; 03:74d6 $11 $05 $9c
    add  HL, DE                                       ;; 03:74d9 $19
    ld   [HL+], A                                     ;; 03:74da $22
    add  A, HUD_HEALTH_PIP_SPACING                    ;; 03:74db $c6 $02
    ld   [HL-], A                                     ;; 03:74dd $32
    ld   DE, HUD_TILEMAP_ROW_STRIDE                   ;; 03:74de $11 $20 $00
    add  HL, DE                                       ;; 03:74e1 $19
    dec  A                                            ;; 03:74e2 $3d
    ld   [HL+], A                                     ;; 03:74e3 $22
    add  A, HUD_HEALTH_PIP_SPACING                    ;; 03:74e4 $c6 $02
    ld   [HL], A                                      ;; 03:74e6 $77
    inc  B                                            ;; 03:74e7 $04
    bit  2, B                                         ;; 03:74e8 $cb $50
    jr   Z, .jr_03_74a6                               ;; 03:74ea $28 $ba
    ret                                               ;; 03:74ec $c9
.data_03_74ed_HealthPipTiles:
; Base tile id per pip state, indexed by the three-bit state built above. Only five
; of the eight combinations can occur; the rest repeat the empty pip
    db   $18, $14, $24, $20, $1c, $1c, $1c, $1c       ;; 03:74ed ....???.

call_03_74f5_HUD_DrawNumberOnStatusBar:
; Writes the number in A into the status bar as up to three 16x16 digits, at the
; tilemap addresses in HL (top row) and DE (bottom row).
;
; Blanks the three digit columns first with HUD_TILE_BLANK_TOP and
; HUD_TILE_BLANK_BOTTOM, so a number that shrinks does not leave its old leading
; digit behind. Then repeated subtraction pulls out hundreds and tens - skipping the
; hundreds entirely below 100 and the tens below 10, which is what right-aligns the
; number without any padding logic.
;
; Each digit costs four tile ids: digit*2 on the top row and digit*2+1 below, in
; both the left and right columns
    push HL                                           ;; 03:74f5 $e5
    ld   C, HUD_TILE_BLANK_TOP                        ;; 03:74f6 $0e $30
    ld   [HL], C                                      ;; 03:74f8 $71
    inc  L                                            ;; 03:74f9 $2c
    ld   [HL], C                                      ;; 03:74fa $71
    inc  L                                            ;; 03:74fb $2c
    ld   [HL], C                                      ;; 03:74fc $71
    ld   BC, $1e                                      ;; 03:74fd $01 $1e $00
    add  HL, BC                                       ;; 03:7500 $09
    ld   C, HUD_TILE_BLANK_BOTTOM                     ;; 03:7501 $0e $31
    ld   [HL], C                                      ;; 03:7503 $71
    inc  L                                            ;; 03:7504 $2c
    ld   [HL], C                                      ;; 03:7505 $71
    inc  L                                            ;; 03:7506 $2c
    ld   [HL], C                                      ;; 03:7507 $71
    pop  HL                                           ;; 03:7508 $e1
    cp   A, $0a                                       ;; 03:7509 $fe $0a
    jr   C, .jr_03_7537                               ;; 03:750b $38 $2a
    cp   A, $64                                       ;; 03:750d $fe $64
    jr   C, .jr_03_7524                               ;; 03:750f $38 $13
    ld   C, $ff                                       ;; 03:7511 $0e $ff
.jr_03_7513:
    inc  C                                            ;; 03:7513 $0c
    sub  A, $64                                       ;; 03:7514 $d6 $64
    jr   NC, .jr_03_7513                              ;; 03:7516 $30 $fb
    add  A, $64                                       ;; 03:7518 $c6 $64
    ld   B, A                                         ;; 03:751a $47
    ld   A, C                                         ;; 03:751b $79
    add  A, A                                         ;; 03:751c $87
    add  A, $00                                       ;; 03:751d $c6 $00
    ld   [HL+], A                                     ;; 03:751f $22
    inc  A                                            ;; 03:7520 $3c
    ld   [DE], A                                      ;; 03:7521 $12
    inc  E                                            ;; 03:7522 $1c
    ld   A, B                                         ;; 03:7523 $78
.jr_03_7524:
    ld   C, $ff                                       ;; 03:7524 $0e $ff
.jr_03_7526:
    inc  C                                            ;; 03:7526 $0c
    sub  A, $0a                                       ;; 03:7527 $d6 $0a
    jr   NC, .jr_03_7526                              ;; 03:7529 $30 $fb
    add  A, $0a                                       ;; 03:752b $c6 $0a
    ld   B, A                                         ;; 03:752d $47
    ld   A, C                                         ;; 03:752e $79
    add  A, A                                         ;; 03:752f $87
    add  A, $00                                       ;; 03:7530 $c6 $00
    ld   [HL+], A                                     ;; 03:7532 $22
    inc  A                                            ;; 03:7533 $3c
    ld   [DE], A                                      ;; 03:7534 $12
    inc  E                                            ;; 03:7535 $1c
    ld   A, B                                         ;; 03:7536 $78
.jr_03_7537:
    add  A, A                                         ;; 03:7537 $87
    add  A, $00                                       ;; 03:7538 $c6 $00
    ld   [HL], A                                      ;; 03:753a $77
    inc  A                                            ;; 03:753b $3c
    ld   [DE], A                                      ;; 03:753c $12
    ret                                               ;; 03:753d $c9

call_03_753e_AnimateFlyCoinCollectibles:
; Animates the fly coin tiles by rewriting the pixels behind them - the tilemap is
; never touched, so this costs nothing on the map side.
;
; Two counters: wDC72_AnimFrameCounter divides the frame rate by
; HUD_FLY_COIN_FRAME_DELAY, and wDC73_FrameCounter_FlyCoins cycles
; HUD_FLY_COIN_FRAME_COUNT frames. The frame number indexes image_003_4400 in
; $100-byte steps, and a general purpose DMA moves that page into VRAM bank 1 with
; rVBK switched around the transfer.
;
; Only runs while HUD_DIRTY_FLY_COINS_BIT is set - which here means "this level has
; animated coins" rather than "something changed", since nothing ever clears it
    ld   HL, wDB69_HUDDirtyFlags                      ;; 03:753e $21 $69 $db
    bit  HUD_DIRTY_FLY_COINS_BIT, [HL]                ;; 03:7541 $cb $66
    ret  Z                                            ;; 03:7543 $c8
    ld   HL, wDC72_AnimFrameCounter                   ;; 03:7544 $21 $72 $dc
    inc  [HL]                                         ;; 03:7547 $34
    ld   A, [HL]                                      ;; 03:7548 $7e
    sub  A, HUD_FLY_COIN_FRAME_DELAY                  ;; 03:7549 $d6 $08
    ret  NZ                                           ;; 03:754b $c0
    ld   [HL], A                                      ;; 03:754c $77
    ld   HL, wDC73_FrameCounter_FlyCoins              ;; 03:754d $21 $73 $dc
    inc  [HL]                                         ;; 03:7550 $34
    ld   A, [HL]                                      ;; 03:7551 $7e
    sub  A, HUD_FLY_COIN_FRAME_COUNT                  ;; 03:7552 $d6 $06
    jr   NZ, .jr_03_7557                              ;; 03:7554 $20 $01
    ld   [HL], A                                      ;; 03:7556 $77
.jr_03_7557:
    ld   A, [HL]                                      ;; 03:7557 $7e
    swap A                                            ;; 03:7558 $cb $37
    ld   L, A                                         ;; 03:755a $6f
    ld   H, $00                                       ;; 03:755b $26 $00
    add  HL, HL                                       ;; 03:755d $29
    add  HL, HL                                       ;; 03:755e $29
    ld   DE, image_003_4400                           ;; 03:755f $11 $00 $44
    add  HL, DE                                       ;; 03:7562 $19
    ld   A, $01                                       ;; 03:7563 $3e $01
    ldh  [rVBK], A                                    ;; 03:7565 $e0 $4f
    ld   A, H                                         ;; 03:7567 $7c
    ldh  [rHDMA1], A                                  ;; 03:7568 $e0 $51
    ld   A, L                                         ;; 03:756a $7d
    ldh  [rHDMA2], A                                  ;; 03:756b $e0 $52
    ld   A, $83                                       ;; 03:756d $3e $83
    ldh  [rHDMA3], A                                  ;; 03:756f $e0 $53
    ld   A, $c0                                       ;; 03:7571 $3e $c0
    ldh  [rHDMA4], A                                  ;; 03:7573 $e0 $54
    ld   A, $03                                       ;; 03:7575 $3e $03
    ldh  [rHDMA5], A                                  ;; 03:7577 $e0 $55
    ld   A, $00                                       ;; 03:7579 $3e $00
    ldh  [rVBK], A                                    ;; 03:757b $e0 $4f
    ret                                               ;; 03:757d $c9

call_03_757e_HUD_AnimateBonusStageTimer:
; Redraws the bonus stage clock. Runs only when HUD_DIRTY_TIMER_BIT is set AND
; wDB6D_InBonusStage says there is a clock, and clears the bit either way.
;
; wDB6E_LevelTimer_SecondsRemaining is split into minutes and seconds by repeated
; subtraction of SECONDS_PER_MINUTE and then 10, giving three digits plus the colon.
; Four glyphs are then HDMA'd into consecutive VRAM slots at $8400: the minutes
; digit, the colon (HUD_TIMER_GLYPH_COLON, which is just index 10 of the same digit
; strip), the tens and the units.
;
; Falls through into the loader below with the last glyph's parameters already set
; up, which is why there is no fourth call
    ld   HL, wDB69_HUDDirtyFlags                      ;; 03:757e $21 $69 $db
    bit  HUD_DIRTY_TIMER_BIT, [HL]                    ;; 03:7581 $cb $56
    ret  Z                                            ;; 03:7583 $c8
    res  HUD_DIRTY_TIMER_BIT, [HL]                    ;; 03:7584 $cb $96
    ld   A, [wDB6D_InBonusStage]                      ;; 03:7586 $fa $6d $db
    and  A, A                                         ;; 03:7589 $a7
    ret  Z                                            ;; 03:758a $c8
    ld   A, [wDB6E_LevelTimer_SecondsRemaining]       ;; 03:758b $fa $6e $db
    ld   C, $ff                                       ;; 03:758e $0e $ff
.jr_03_7590:
    inc  C                                            ;; 03:7590 $0c
    sub  A, SECONDS_PER_MINUTE                        ;; 03:7591 $d6 $3c
    jr   NC, .jr_03_7590                              ;; 03:7593 $30 $fb
    add  A, SECONDS_PER_MINUTE                        ;; 03:7595 $c6 $3c
    ld   D, $ff                                       ;; 03:7597 $16 $ff
.jr_03_7599:
    inc  D                                            ;; 03:7599 $14
    sub  A, $0a                                       ;; 03:759a $d6 $0a
    jr   NC, .jr_03_7599                              ;; 03:759c $30 $fb
    add  A, $0a                                       ;; 03:759e $c6 $0a
    ld   E, A                                         ;; 03:75a0 $5f
    push DE                                           ;; 03:75a1 $d5
    push DE                                           ;; 03:75a2 $d5
    ld   DE, _VRAM+$0400                              ;; 03:75a3 $11 $00 $84
    call call_03_75be_HUD_LoadBonusStageTimerSprite   ;; 03:75a6 $cd $be $75
    ld   C, HUD_TIMER_GLYPH_COLON                     ;; 03:75a9 $0e $0a
    ld   DE, _VRAM+$0420                              ;; 03:75ab $11 $20 $84
    call call_03_75be_HUD_LoadBonusStageTimerSprite   ;; 03:75ae $cd $be $75
    pop  DE                                           ;; 03:75b1 $d1
    ld   C, D                                         ;; 03:75b2 $4a
    ld   DE, _VRAM+$0440                              ;; 03:75b3 $11 $40 $84
    call call_03_75be_HUD_LoadBonusStageTimerSprite   ;; 03:75b6 $cd $be $75
    pop  DE                                           ;; 03:75b9 $d1
    ld   C, E                                         ;; 03:75ba $4b
    ld   DE, _VRAM+$0460                              ;; 03:75bb $11 $60 $84

call_03_75be_HUD_LoadBonusStageTimerSprite:
; HDMAs one 16x16 glyph - $20 bytes, index C shifted five places into
; image_003_4580 - into VRAM bank 1 at DE. rVBK is switched to bank 1 and back
; around the transfer, because the clock's pixels live in the CGB's second tile bank
    ld   L, C                                         ;; 03:75be $69
    ld   H, $00                                       ;; 03:75bf $26 $00
    add  HL, HL                                       ;; 03:75c1 $29
    add  HL, HL                                       ;; 03:75c2 $29
    add  HL, HL                                       ;; 03:75c3 $29
    add  HL, HL                                       ;; 03:75c4 $29
    add  HL, HL                                       ;; 03:75c5 $29
    ld   BC, image_003_4580                           ;; 03:75c6 $01 $80 $45
    add  HL, BC                                       ;; 03:75c9 $09
    ld   A, $01                                       ;; 03:75ca $3e $01
    ldh  [rVBK], A                                    ;; 03:75cc $e0 $4f
    ld   A, H                                         ;; 03:75ce $7c
    ldh  [rHDMA1], A                                  ;; 03:75cf $e0 $51
    ld   A, L                                         ;; 03:75d1 $7d
    ldh  [rHDMA2], A                                  ;; 03:75d2 $e0 $52
    ld   A, D                                         ;; 03:75d4 $7a
    ldh  [rHDMA3], A                                  ;; 03:75d5 $e0 $53
    ld   A, E                                         ;; 03:75d7 $7b
    ldh  [rHDMA4], A                                  ;; 03:75d8 $e0 $54
    ld   A, $01                                       ;; 03:75da $3e $01
    ldh  [rHDMA5], A                                  ;; 03:75dc $e0 $55
    ld   A, $00                                       ;; 03:75de $3e $00
    ldh  [rVBK], A                                    ;; 03:75e0 $e0 $4f
    ret                                               ;; 03:75e2 $c9
