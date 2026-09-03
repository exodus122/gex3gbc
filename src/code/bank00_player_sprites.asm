; ==================================================================
; Bank 0. Gex's own OAM entries, and the two small things that go with them.
;
; Every other sprite in the game is assembled by bank 3 from a shape in
; data_03_59ea_SpriteShapeTable - a rectangle of 8x16 OBJs, described once per size
; and shared by every entity that size. Gex is the exception. His frames are
; authored per map, live out in the graphics banks, and are variable-length lists of
; pieces, so this routine walks the list instead of picking a shape.
;
; That is why the code sits in bank 0 and not next to the rest of the OAM build:
; call_03_5ec1_OAM_BuildFrame has to reach it while a graphics bank is paged in, and
; bank 0 is the only bank always mapped.
;
; Finding the frame
; -----------------
; Three indirections, all keyed by the current map and the current sprite id, all in
; BANK_7F_PLAYER_GFX_INDEX. That file documents them in full; in short:
;
;   data_7f_4000_PlayerGfx_SetByMap[map]
;                     which graphics set this map draws Gex with, stored as a byte
;                     offset into the next table rather than as a set number - which is
;                     why the value goes into DE unscaled
;   data_7f_403d_PlayerGfx_SetTable + offset
;                     the set's base bank, then a pointer to its frame directory
;   directory[sprite id * PLAYER_FRAME_ENTRY_SIZE]
;                     how many banks past the base bank the frame lives, then its
;                     address in that bank
;
; and the frame itself is
;
;   +0     piece count, into wDAC2_PlayerGfx_TileCount
;   +1 +2  skipped, and read by nothing anywhere. Small numbers - 3 to 41 and 4 to 48
;          across the game - but they do not match the frame's piece extents, so what
;          they described is unknown
;   +3 +4  where the frame's tiles live, into wDAC0_PlayerGfx_SrcAddr for the VRAM
;          copy that call_00_098f_CopyPlayerGfxToVRAM does separately
;   +5...  PLAYER_FRAME_PIECE_SIZE bytes per piece: Y offset, X offset, attribute bits
;          OR'd into wDC53_Player_OamAttributes, and a fourth byte the build steps over
;          without reading. That fourth byte is $00 in all 11005 pieces in the game, and
;          the attribute byte is only ever PLAYER_PIECE_PAL0 or PLAYER_PIECE_PAL1 - so
;          in practice it picks which of Gex's two OBJ palettes the piece draws with
;
; A piece is one 8x16 OBJ, so it is 32 bytes of tile data, and a frame's pieces are
; contiguous from +3+4. That is why the piece count can also drive the HDMA: it is a
; count of OBJs here and a count of 32-byte tile pairs there, and both are the same
; number.
;
; Note what is NOT in a piece: its tile number. That is wDC52_Player_OamTileId, a
; counter that starts at zero and steps by two, so a frame's pieces always take
; consecutive tile pairs from the page the copy above just filled.
;
; The four variants
; -----------------
; wDC53_Player_OamAttributes is the facing byte OR'd with the climb/swim state byte,
; and it does two jobs at once. It is written into every OBJ's attribute byte, and
; its OAMB_XFLIP and OAMB_YFLIP bits also choose which of four copies of the draw
; loop runs. The two are the same bit deliberately: the attribute flips the tile,
; and the loop moves the piece to where the flipped tile has to go.
;
; Mirroring an offset is `cpl / inc A` - negate - followed by a subtraction of the
; sprite's own size, so the mirrored rectangle covers the pixels the unmirrored one
; did. X backs off by PLAYER_SPRITE_XFLIP_WIDTH, one OBJ; Y by
; PLAYER_SPRITE_YFLIP_HEIGHT, which is three, so Gex's frames are laid out in
; columns of three 8x16 pieces.
;
; The ROM has all four loops written out longhand. Here they are the player_oam_origin
; and player_oam_pieces macros from macros.asm with the mirror steps behind IF, which
; assembles to the same bytes.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank03_oam_build.asm
; ------------------------------------------------------------------
; gex2's call_03_5ca8_Player_BuildSprites is the same routine solving the same
; problem from the other end:
;
;   the frames     gex2 gives Gex a SHAPE like everything else, out of
;                  .data_03_5d6f_PlayerSpriteShapeTable, indexed by
;                  wD586_PlayerGfxVramPage plus 2 for facing left and 4 for the
;                  alternate climb frames. gex3 gives him per-map frame lists, which
;                  is what a game with several tilesets and two vehicle modes per
;                  level needs
;   the mirroring  gex2 has ONE loop and lets the OAM attribute bit do all the
;                  flipping, because a shape's pieces sit on a fixed grid. gex3's
;                  pieces are at arbitrary offsets, so the offsets have to be
;                  mirrored too - hence four loops instead of one
;   the bank       gex2 keeps it in bank 3 with the rest of the OAM build. gex3
;                  cannot, because the frame data is spread across the graphics
;                  banks and this routine pages them in itself
; ==================================================================

call_00_2ce2_Player_BuildSprites:
; Writes Gex's OBJs into wD900_ShadowOAM at wDC6F_Oam_WriteOffset, and leaves the
; offset advanced past them.
;
; Runs in three parts. First the frame lookup: the facing and climb bytes are merged
; into wDC53_Player_OamAttributes, the map's graphics set is found in bank
; BANK_7F_PLAYER_GFX_INDEX, and the frame's own bank is paged in - note the bank
; dance, RestoreBank then SwitchBank, because the directory and the frame it names
; are in different banks.
;
; Then the pieces, through the four flip variants described in the file header. Each
; one recomputes Gex's screen position from wDBF9_XPositionInMap and his world
; position, biased by OAM_X_BIAS and OAM_Y_BIAS, and stores it in
; wDC90_Player_ScreenX and wDC91_Player_ScreenY - which the collectible pickup test
; over in bank 3 then reads, so this routine is also what tells the rest of the game
; where Gex is on screen. If he is alive and inside his damage cooldown he is drawn
; only when the low PLAYER_DAMAGE_FLASH_MASK bits of the frame counter are zero -
; one frame in eight, so the invulnerability blink is mostly invisible, not mostly
; visible.
;
; Last, the fly. If wDC51_Player_CurrentFly is set, one more OBJ is written for the
; captured fly circling him, its offset taken from data_00_2f14_FlyOrbitOffsets by
; the frame counter. gex2's call_03_5ca8_Player_BuildSprites
    ld   A, $01                                       ;; 00:2ce2 $3e $01
    ld   [wDAC2_PlayerGfx_TileCount], A               ;; 00:2ce4 $ea $c2 $da
    ld   A, [wD80D_PlayerFacingDirection]             ;; 00:2ce7 $fa $0d $d8
    ld   HL, wDC7A_PlayerClimbingOrSwimmingRelated    ;; 00:2cea $21 $7a $dc
    or   A, [HL]                                      ;; 00:2ced $b6
    ld   [wDC53_Player_OamAttributes], A              ;; 00:2cee $ea $53 $dc
    ld   A, BANK(data_7f_4000_PlayerGfx_SetByMap)                   ;; 00:2cf1 $3e $7f
    call call_00_0eee_SwitchBank                      ;; 00:2cf3 $cd $ee $0e
    ld   HL, wDB6C_CurrentMapId                       ;; 00:2cf6 $21 $6c $db
    ld   E, [HL]                                      ;; 00:2cf9 $5e
    ld   D, $00                                       ;; 00:2cfa $16 $00
    ld   HL, data_7f_4000_PlayerGfx_SetByMap                             ;; 00:2cfc $21 $00 $40
    add  HL, DE                                       ;; 00:2cff $19
    ld   E, [HL]                                      ;; 00:2d00 $5e
    ld   HL, data_7f_403d_PlayerGfx_SetTable                             ;; 00:2d01 $21 $3d $40
    add  HL, DE                                       ;; 00:2d04 $19
    ld   A, [HL+]                                     ;; 00:2d05 $2a
    ld   [wDABF_PlayerGfx_SrcBank], A                 ;; 00:2d06 $ea $bf $da
    ld   A, [HL+]                                     ;; 00:2d09 $2a
    ld   H, [HL]                                      ;; 00:2d0a $66
    ld   L, A                                         ;; 00:2d0b $6f
    ld   A, [wD80A_Player_SpriteId]                   ;; 00:2d0c $fa $0a $d8
    ld   E, A                                         ;; 00:2d0f $5f
    ld   D, $00                                       ;; 00:2d10 $16 $00
    add  HL, DE                                       ;; 00:2d12 $19
    add  HL, DE                                       ;; 00:2d13 $19
    add  HL, DE                                       ;; 00:2d14 $19
    ld   C, [HL]                                      ;; 00:2d15 $4e
    inc  HL                                           ;; 00:2d16 $23
    ld   A, [HL+]                                     ;; 00:2d17 $2a
    ld   H, [HL]                                      ;; 00:2d18 $66
    ld   L, A                                         ;; 00:2d19 $6f
    push HL                                           ;; 00:2d1a $e5
    ld   A, [wDABF_PlayerGfx_SrcBank]                 ;; 00:2d1b $fa $bf $da
    add  A, C                                         ;; 00:2d1e $81
    ld   [wDABF_PlayerGfx_SrcBank], A                 ;; 00:2d1f $ea $bf $da
    call call_00_0f08_RestoreBank                     ;; 00:2d22 $cd $08 $0f
    ld   A, [wDABF_PlayerGfx_SrcBank]                 ;; 00:2d25 $fa $bf $da
    call call_00_0eee_SwitchBank                      ;; 00:2d28 $cd $ee $0e
    pop  HL                                           ;; 00:2d2b $e1
    ld   A, [HL+]                                     ;; 00:2d2c $2a
    ld   [wDAC2_PlayerGfx_TileCount], A               ;; 00:2d2d $ea $c2 $da
    inc  HL                                           ;; 00:2d30 $23
    inc  HL                                           ;; 00:2d31 $23
    ld   A, [HL+]                                     ;; 00:2d32 $2a
    ld   [wDAC0_PlayerGfx_SrcAddr], A                 ;; 00:2d33 $ea $c0 $da
    ld   A, [HL+]                                     ;; 00:2d36 $2a
    ld   [wDAC0_PlayerGfx_SrcAddr+1], A               ;; 00:2d37 $ea $c1 $da
    xor  A, A                                         ;; 00:2d3a $af
    ld   [wDC52_Player_OamTileId], A                  ;; 00:2d3b $ea $52 $dc
    ld   A, [wDC6F_Oam_WriteOffset]                   ;; 00:2d3e $fa $6f $dc
    ld   E, A                                         ;; 00:2d41 $5f
    ld   D, HIGH(wD900_ShadowOAM)                     ;; 00:2d42 $16 $d9
    ld   A, [wDC53_Player_OamAttributes]              ;; 00:2d44 $fa $53 $dc
    bit  OAMB_YFLIP, A                                ;; 00:2d47 $cb $77
    jp   NZ, .jp_00_2e0b                              ;; 00:2d49 $c2 $0b $2e
    bit  OAMB_XFLIP, A                                ;; 00:2d4c $cb $6f
    jp   NZ, .jp_00_2dac                              ;; 00:2d4e $c2 $ac $2d
    player_oam_origin  0
    player_oam_pieces  0, 0, 0
.jp_00_2dac:
    player_oam_origin  0
    player_oam_pieces  0, 1, 0
.jp_00_2e0b:
    bit  OAMB_XFLIP, A                                ;; 00:2e0b $cb $6f
    jp   NZ, .jp_00_2e6f                              ;; 00:2e0d $c2 $6f $2e
    player_oam_origin  0
    player_oam_pieces  1, 0, 0
.jp_00_2e6f:
    player_oam_origin  1
    player_oam_pieces  1, 1, 1
.jp_00_2ece:
    ld   A, [wDC51_Player_CurrentFly]                 ;; 00:2ece $fa $51 $dc
    and  A, A                                         ;; 00:2ed1 $a7
    jr   Z, .jr_00_2ef9                               ;; 00:2ed2 $28 $25
    ld   A, [wDC71_VBlankFrameCounter]                ;; 00:2ed4 $fa $71 $dc
    rrca                                              ;; 00:2ed7 $0f
    and  A, PLAYER_FLY_ORBIT_MASK                     ;; 00:2ed8 $e6 $0f
    add  A, A                                         ;; 00:2eda $87
    ld   L, A                                         ;; 00:2edb $6f
    ld   H, $00                                       ;; 00:2edc $26 $00
    ld   BC, data_00_2f14_FlyOrbitOffsets             ;; 00:2ede $01 $14 $2f
    add  HL, BC                                       ;; 00:2ee1 $09
    ld   A, [wDC91_Player_ScreenY]                    ;; 00:2ee2 $fa $91 $dc
    add  A, [HL]                                      ;; 00:2ee5 $86
    sub  A, PLAYER_FLY_ORBIT_Y_BIAS                   ;; 00:2ee6 $d6 $20
    ld   [DE], A                                      ;; 00:2ee8 $12
    inc  E                                            ;; 00:2ee9 $1c
    inc  HL                                           ;; 00:2eea $23
    ld   A, [wDC90_Player_ScreenX]                    ;; 00:2eeb $fa $90 $dc
    add  A, [HL]                                      ;; 00:2eee $86
    ld   [DE], A                                      ;; 00:2eef $12
    inc  E                                            ;; 00:2ef0 $1c
    ld   A, PLAYER_FLY_OAM_TILE                       ;; 00:2ef1 $3e $32
    ld   [DE], A                                      ;; 00:2ef3 $12
    inc  E                                            ;; 00:2ef4 $1c
    ld   A, PLAYER_FLY_OAM_ATTRIBUTES                 ;; 00:2ef5 $3e $08
    ld   [DE], A                                      ;; 00:2ef7 $12
    inc  E                                            ;; 00:2ef8 $1c
.jr_00_2ef9:
    ld   A, E                                         ;; 00:2ef9 $7b
    ld   [wDC6F_Oam_WriteOffset], A                   ;; 00:2efa $ea $6f $dc
    jp   call_00_0f08_RestoreBank                     ;; 00:2efd $c3 $08 $0f

call_00_2f00_Player_IsDead:
; Z if Gex is dead. Asks bank 2 for the current action's state flags and keeps
; PLAYER_STATE_DEAD_MASK, saving every register but A because the OAM build calls it
; in the middle of walking a frame list with HL and DE loaded
    push HL                                           ;; 00:2f00 $e5
    push DE                                           ;; 00:2f01 $d5
    push BC                                           ;; 00:2f02 $c5
    farcall call_02_5541_Player_GetActionStates
    pop  BC                                           ;; 00:2f0e $c1
    pop  DE                                           ;; 00:2f0f $d1
    pop  HL                                           ;; 00:2f10 $e1
    and  A, PLAYER_STATE_DEAD_MASK                    ;; 00:2f11 $e6 $08
    ret                                               ;; 00:2f13 $c9

data_00_2f14_FlyOrbitOffsets:
; Sixteen (Y, X) pairs, the circle the captured fly flies around Gex. Indexed by
; wDC71_VBlankFrameCounter shifted right one and masked, so the fly advances one step
; every two frames and goes round once every thirty-two
    db   $00, $fe, $fe, $fc, $fc, $fe, $fc, $00       ;; 00:2f14 ????????
    db   $fa, $02, $fc, $04, $fe, $02, $00, $04       ;; 00:2f1c ????????
    db   $00, $02, $fe, $00, $fe, $fe, $fc, $fc       ;; 00:2f24 ????????
    db   $fa, $fa, $fc, $f8, $fe, $fa, $00, $fc       ;; 00:2f2c ????????
