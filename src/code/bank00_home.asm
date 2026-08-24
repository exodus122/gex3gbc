;; Disassembled with BadBoy Disassembler: https://github.com/daid/BadBoy

; ==================================================================
; Bank 0 (home). Interrupt vectors, boot, the outer game loop, and the shared
; video / banking / input / sfx helpers that every other bank calls into.
;
; How graphics reach VRAM
; -----------------------
; The game never writes VRAM directly from game logic. Instead:
;
;   1. Something fills in one of three sets of parameters and raises the
;      matching bit in wDB66_GfxTransferFlags (GFX_XFER_*), plus GFX_XFER_PENDING.
;   2. call_00_0c6a_VBlank_StartPendingHdma - the vblank hook - picks the
;      highest-priority pending request and programs rHDMA1..rHDMA5 from it.
;   3. The transfer is a general purpose DMA, so it completes inside that
;      vblank and the request bit is cleared.
;
; The exception is GFX_XFER_HDMA_CONFIG, which is a job struct
; (wDC2B_Hdma_SrcAddrLo) rather than a fixed-size copy. Only HDMA_MAX_BLOCKS
; blocks move per frame and the struct is advanced in place, so a big transfer -
; a tileset, a whole bg map - resumes over several frames.
; call_00_0a6a_Hdma_RunConfigEntry starts one from
; .data_00_0aa9_HdmaConfigTable and blocks until it has drained.
;
; Separately, call_00_0b9f_VBlank_UpdateVRAM performs exactly one "big" VRAM
; write per vblank - a bg map scroll row or column if one is waiting, otherwise
; the status bar and the menu animations.
;
; How the LCD STAT interrupt works
; --------------------------------
; isrLCDC at $0048 is a bare `jp wD9A0_LcdIsrCode`, because the handler is not
; fixed code: it is a template copied into WRAM out of
; .data_00_0c44_LcdIsrTable. Each entry carries its rSTAT and rLYC values, the
; template, and - immediately after the template, so the copy finds it for free -
; a vblank hook that belongs to that handler. Code asks for a handler with
; call_00_0c10_RequestLcdIsr, which stores the id with LCD_ISR_INSTALLED clear,
; and the next vblank installs it.
;
; There are only two real handlers. LCD_ISR_HUD_PALETTE counts hblanks in
; wDB67_LcdIsr_ScanlineCounter and swaps the background palettes for the status
; bar strip, across two scanlines because eight palette writes do not fit in one
; hblank; its vblank hook is the HDMA runner above. LCD_ISR_MENU_GFX_STREAM has
; an empty handler and exists only for its hook, which walks a menu graphics
; script one chunk per frame.
;
; How banking works
; -----------------
; call_00_0eee_SwitchBank PUSHES the new bank onto a stack in WRAM and
; call_00_0f08_RestoreBank POPS it, so the two must be matched or the stack
; pointer in wDAD3_PtrToBankStackPosition drifts. farcall is that pair wrapped
; around a `jp hl`. Interrupt-time code cannot use them - an interrupt landing
; between the two halves of SwitchBank would corrupt the stack - so the vblank
; handler writes the MBC registers through call_00_0f25_SetMbcBank and restores
; from wDAD5_CurrentROMBank instead.
;
; Map of this file
; ----------------
;   $0000-$014F  interrupt vectors, the entry point and the cartridge header
;   $0150-$04FA  call_00_0150_Init and the outer game loop
;   $04FB-$075E  level setup, the bonus timer, the fly power-up and damage
;   $075F-$08F7  memcopy, the screen loaders and the menu HDMA animations
;   $08F8-$0B24  the graphics transfer queue and the HDMA config table
;   $0B25-$0BCE  the vblank handler and its one VRAM write per frame
;   $0BCF-$0DF8  the LCD STAT handler table and the hud palette split
;   $0DF9-$0EDC  the gfx stream, OAM DMA, shadow OAM and CGB palette upload
;   $0EDD-$0FA1  banking, joypad reading and the CheckInput* helpers
;   $0FA2-$1055  music and sound effects
;   $1056-$3FFF  included from bank00_bg_map.asm and friends - see main.asm
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank00_home.asm
; ------------------------------------------------------------------
; The two files are the same file in outline - same boot sequence, same bank
; stack, same joypad reader, same CheckInput* helpers, same "wait for vblank"
; discipline, same outer loop written as one long fall-through chain - and most
; of the small helpers are instruction-for-instruction identical. The
; differences are structural:
;
;   hardware      gex2 ships on DMG and CGB and branches on wD59E_OnGBCFlag all
;                 over the ROM. gex3 is CGB-only: Init draws a
;                 "GAME BOY COLOR ONLY" screen out of bank $07 on a DMG and
;                 halts, and there is no colour flag anywhere in the game
;   transfers     gex2 has no HDMA. It stages a page into
;                 wD100_TilesToLoadBuffer and a self-patching LCD STAT handler
;                 dribbles it into VRAM four bytes per hblank. gex3 uses general
;                 purpose DMA for everything, so wDB66_GfxTransferFlags names
;                 sets of HDMA parameters rather than pages to stream
;   LCD STAT      the install mechanism is the same down to the "installed" bit.
;                 The handlers are not: gex2's second one does the hud window
;                 split and the tv-warp wobble, gex3's does a two-line
;                 background palette swap instead. gex3 leaves LCDCF_WINON set
;                 for the whole frame; gex2 keeps the window off in LCDC and
;                 switches it on mid-screen
;   fades         gex2 has a whole DMG palette fade engine, $0F38-$1077, and
;                 every screen change goes through it. gex3 has none. It hides a
;                 screen by clearing wDD6A_PalettesReadyFlag, which makes
;                 call_00_0e81_UploadCgbPalettes push grey until the screen is
;                 ready
;   level shape   a gex2 level is one map, so its warp flags only have to say
;                 "died", "entered a tv" and "entered a door". A gex3 level is
;                 many maps, so WARP_CHANGE_MAP moves between them and
;                 WARP_NEW_LEVEL leaves the level, and .jp_00_038e_LoadMap has
;                 to pick a spawn action per map from the map's collision type
;                 and the level's vehicle mode
;   demos         gex2's title screen times out into an attract demo, driven by
;                 a recorded input script. gex3 has no demo mode at all
;   flies         gex2 applies a fly the moment it is picked up. gex3 stores one
;                 and the player eats it with SELECT
;                 (call_00_05fd_Player_CheckEatFlyInput); in both, swapping the
;                 old fly out is what makes it take effect. gex2 has two shield
;                 timers as 16-bit frame counts, gex3 three as second counts off
;                 one shared frame counter
;   health        gex2's is a flat PLAYER_MAX_HEALTH. gex3's is
;                 PLAYER_BASE_HEALTH plus wDC4F_PawCoinExtraHealth, earned four
;                 paw coins at a time and kept across deaths
;   collectibles  gex2 walks a milestone table and then pays out every 50
;                 forever, and reuses the counter as a falling quota in bonus
;                 levels. gex3 has two fixed thresholds - a life at 50, the
;                 level's completion flag at 100 - and times its bonus stages
;                 instead of setting a quota
;   audio         same shape: a queued effect, a current song, an audio bank
;                 that follows the song. gex3 weighs requests against
;                 .data_00_1037_SFXPriorities and will interrupt a quieter
;                 effect; gex2 simply refuses to overwrite a full slot. gex2's
;                 songs are four driver tracks named by a table record, gex3's
;                 are one id whose nibbles are the bank and the track
;   absent here   block patches, secondary tileset streaming and animation, the
;                 hub tv attribute blocks and the password heading strip are all
;                 gex2-only, and take up most of the space between its
;                 $08B1 and $0E86 that gex3 spends on HDMA instead
; ==================================================================

    reti                                               ;; 00:0000 ?

; ------------------------------------------------------------------
; Interrupt vectors. Only two are ever enabled - Init writes
; IEF_VBLANK | IEF_STAT to rIE and nothing changes it afterwards - so the timer,
; serial and joypad entries are `reti` stubs that can never be reached.
;
; The LCD STAT vector is the unusual one: it jumps into RAM, because the handler
; is not fixed code but a template copied into wD9A0_LcdIsrCode. See
; call_00_0c1b_InstallLcdIsr and the templates at $0C53 and $0C55
; ------------------------------------------------------------------

SECTION "isrVBlank", ROM0[$0040]
isrVBlank:
    jp   call_00_0b25_VBlank_Handler                   ;; 00:0040 $c3 $25 $0b

SECTION "isrLCDC", ROM0[$0048]
isrLCDC:
    jp   wD9A0_LcdIsrCode                              ;; 00:0048 $c3 $a0 $d9

SECTION "isrTimer", ROM0[$0050]
isrTimer:
    reti                                               ;; 00:0050 $d9

SECTION "isrSerial", ROM0[$0058]
isrSerial:
    reti                                               ;; 00:0058 $d9

SECTION "isrJoypad", ROM0[$0060]
isrJoypad:
    reti                                               ;; 00:0060 $d9

SECTION "entry", ROM0[$0100]
entry:
; The cartridge entry point and header. The $30 bytes reserved at $0104 are the
; Nintendo logo, filled in by rgbfix rather than stored here.
;
; CART_COMPATIBLE_GBC, not gex2's CART_COMPATIBLE_DMG_GBC - this cartridge
; refuses to run on a DMG, and Init is where that refusal happens. Note the
; header claims CART_ROM_MBC5 while the code drives the cart as an MBC1 with the
; upper-bits trick, exactly as gex2 does
    nop                                                ;; 00:0100 $00
    jp   call_00_0150_Init                             ;; 00:0101 $c3 $50 $01
    ds   $30                                           ;; 00:0104
    db   "POCKET GEX3AXGE"                             ;; 00:0134
    db   CART_COMPATIBLE_GBC                           ;; 00:0143
    db   $34, $46                                      ;; 00:0144 ??
    db   CART_INDICATOR_GB                             ;; 00:0146
    db   CART_ROM_MBC5, CART_ROM_2048KB, CART_SRAM_NONE ;; 00:0147
    db   CART_DEST_NON_JAPANESE, $33, $00              ;; 00:014a $01 $33 $00
    ds   $03                                           ;; 00:014d

SECTION "bank00_0150", ROM0[$0150]

call_00_0150_Init:
; Cold boot. Runs once, from the entry point at $0100, and falls through into the
; outer game loop below - it never returns.
;
; gex3 is a CGB-only cartridge (CART_COMPATIBLE_GBC), and this is where that is
; enforced. The A register the boot ROM leaves behind is BOOT_A_CGB on a colour
; machine and something else on a DMG, and it is consulted twice: once
; immediately, to get WRAM bank 1 mapped before anything writes to $D000, and
; once after the RAM wipe to decide which of two completely different paths to
; take. On a DMG the second test jumps to .jr_00_01b7, which draws the
; "GAME BOY COLOR ONLY" screen out of bank $07 and then spins forever at
; .jr_00_01d0 with the interrupts still off.
;
; The CGB path, at .jr_00_01d2, does the real work: upload palettes, install the
; OAM DMA routine in HRAM, wipe both VRAM banks, seed the bank stack with
; BANK_01_MENU_CODE, switch to double speed, arm the vblank and LCD STAT
; interrupts, start the audio driver and turn the LCD on.
;
; gex2's call_00_0150_Init is the same routine with a DMG branch instead of a
; DMG refusal - it records wD59E_OnGBCFlag and every colour-specific piece of the
; ROM reads it. gex3 has no such flag anywhere, because there is nothing to
; branch on
    di                                                 ;; 00:0150 $f3
    ld   SP, hFFFE                                     ;; 00:0151 $31 $fe $ff
    push AF                                            ;; 00:0154 $f5
    cp   A, BOOT_A_CGB                                 ;; 00:0155 $fe $11
    jr   NZ, .jr_00_015d                               ;; 00:0157 $20 $04
    ld   A, WRAM_BANK_GAME_STATE                       ;; 00:0159 $3e $01
    ldh  [rSVBK], A                                    ;; 00:015b $e0 $70
.jr_00_015d:
    ldh  A, [rLY]                                      ;; 00:015d $f0 $44
    cp   A, LY_VBLANK_START                            ;; 00:015f $fe $91
    jr   NZ, .jr_00_015d                               ;; 00:0161 $20 $fa
    ldh  A, [rLCDC]                                    ;; 00:0163 $f0 $40
    and  A, ~LCDCF_ON & $FF                            ;; 00:0165 $e6 $7f
    ldh  [rLCDC], A                                    ;; 00:0167 $e0 $40
    xor  A, A                                          ;; 00:0169 $af
    ld   [MBC1SRamEnable], A                           ;; 00:016a $ea $01 $00
    ld   [MBC1SRamBankingMode], A                      ;; 00:016d $ea $01 $60
    ld   HL, wC000_BgMapTileIds                        ;; 00:0170 $21 $00 $c0
    ld   DE, wC000_BgMapTileIds+1                      ;; 00:0173 $11 $01 $c0 ; wC000_BgMapTileIds
    ld   BC, WRAM_CLEAR_SIZE                           ;; 00:0176 $01 $ff $1f
    ld   [HL], $00                                     ;; 00:0179 $36 $00
    call call_00_076e_MemCopy                          ;; 00:017b $cd $6e $07
    xor  A, A                                          ;; 00:017e $af
    ldh  [rSCX], A                                     ;; 00:017f $e0 $43
    ldh  [rSCY], A                                     ;; 00:0181 $e0 $42
    ld   A, WINDOW_X_FLUSH_LEFT                        ;; 00:0183 $3e $07
    ld   [wDADB_WindowX], A                            ;; 00:0185 $ea $db $da
    ldh  [rWX], A                                      ;; 00:0188 $e0 $4b
    ld   A, WINDOW_Y_OFFSCREEN                         ;; 00:018a $3e $80
    ld   [wDADC_WindowY], A                            ;; 00:018c $ea $dc $da
    ldh  [rWY], A                                      ;; 00:018f $e0 $4a
    pop  AF                                            ;; 00:0191 $f1
    cp   A, BOOT_A_CGB                                 ;; 00:0192 $fe $11
    jr   Z, .jr_00_01d2                                ;; 00:0194 $28 $3c
    ld   A, Bank07                                     ;; 00:0196 $3e $07
    ld   [MBC1RomBank], A                              ;; 00:0198 $ea $01 $20
    swap A                                             ;; 00:019b $cb $37
    rrca                                               ;; 00:019d $0f
    and  A, $00                                        ;; 00:019e $e6 $00
    ld   [MBC1SRamBank], A                             ;; 00:01a0 $ea $01 $40
    ld   HL, image_007_5b00                            ;; 00:01a3 $21 $00 $5b
    ld   DE, _VRAM                                     ;; 00:01a6 $11 $00 $80
    ld   BC, DMG_ERROR_TILES_SIZE                      ;; 00:01a9 $01 $00 $0a
    call call_00_076e_MemCopy                          ;; 00:01ac $cd $6e $07
    ld   HL, _SCRN0                                    ;; 00:01af $21 $00 $98
    ld   DE, image_007_5b00_bgmap_tile_ids             ;; 00:01b2 $11 $00 $65
    ld   C, SCRN_Y_B                                   ;; 00:01b5 $0e $12
.jr_00_01b7:
    ld   B, SCRN_X_B                                   ;; 00:01b7 $06 $14
.jr_00_01b9:
    ld   A, [DE]                                       ;; 00:01b9 $1a
    ld   [HL+], A                                      ;; 00:01ba $22
    inc  DE                                            ;; 00:01bb $13
    dec  B                                             ;; 00:01bc $05
    jr   NZ, .jr_00_01b9                               ;; 00:01bd $20 $fa
    push BC                                            ;; 00:01bf $c5
    ld   BC, SCRN_VX_B - SCRN_X_B                      ;; 00:01c0 $01 $0c $00
    add  HL, BC                                        ;; 00:01c3 $09
    pop  BC                                            ;; 00:01c4 $c1
    dec  C                                             ;; 00:01c5 $0d
    jr   NZ, .jr_00_01b7                               ;; 00:01c6 $20 $ef
    ld   A, LCDC_DMG_ERROR_SCREEN                      ;; 00:01c8 $3e $d5
    ldh  [rLCDC], A                                    ;; 00:01ca $e0 $40
    ld   A, BGP_DMG_ERROR_SCREEN                       ;; 00:01cc $3e $93
    ldh  [rBGP], A                                     ;; 00:01ce $e0 $47
.jr_00_01d0:
    jr   .jr_00_01d0                                   ;; 00:01d0 $18 $fe
.jr_00_01d2:
    ld   A, $00                                        ;; 00:01d2 $3e $00
    ldh  [rVBK], A                                     ;; 00:01d4 $e0 $4f
    call call_00_0e81_UploadCgbPalettes                ;; 00:01d6 $cd $81 $0e
    ld   HL, call_00_0e29_OamDmaRoutine                ;; 00:01d9 $21 $29 $0e
    ld   DE, hFF80_OamDmaRoutine                       ;; 00:01dc $11 $80 $ff
    ld   BC, OAM_DMA_ROUTINE_SIZE                      ;; 00:01df $01 $0a $00
    call call_00_076e_MemCopy                          ;; 00:01e2 $cd $6e $07
    ld   A, $01                                        ;; 00:01e5 $3e $01
.jr_00_01e7:
    push AF                                            ;; 00:01e7 $f5
    ldh  [rVBK], A                                     ;; 00:01e8 $e0 $4f
    ld   HL, _VRAM                                     ;; 00:01ea $21 $00 $80
    ld   DE, _VRAM+$0001                               ;; 00:01ed $11 $01 $80
    ld   BC, VRAM_CLEAR_SIZE                           ;; 00:01f0 $01 $ff $1f
    ld   [HL], $00                                     ;; 00:01f3 $36 $00
    call call_00_076e_MemCopy                          ;; 00:01f5 $cd $6e $07
    pop  AF                                            ;; 00:01f8 $f1
    dec  A                                             ;; 00:01f9 $3d
    bit  7, A                                          ;; 00:01fa $cb $7f
    jr   Z, .jr_00_01e7                                ;; 00:01fc $28 $e9
    ld   HL, wDAD3_PtrToBankStackPosition              ;; 00:01fe $21 $d3 $da
    ld   DE, wDAC3_BankStack                           ;; 00:0201 $11 $c3 $da
    ld   A, BANK_01_MENU_CODE                          ;; 00:0204 $3e $01
    ld   [HL], E                                       ;; 00:0206 $73
    inc  HL                                            ;; 00:0207 $23
    ld   [HL], D                                       ;; 00:0208 $72
    ld   [wDAD5_CurrentROMBank], A                     ;; 00:0209 $ea $d5 $da
    ld   [DE], A                                       ;; 00:020c $12
    call call_00_0f25_SetMbcBank                       ;; 00:020d $cd $25 $0f
    ld   HL, rKEY1                                     ;; 00:0210 $21 $4d $ff
    bit  7, [HL]                                       ;; 00:0213 $cb $7e
    jr   NZ, .jr_00_0224                               ;; 00:0215 $20 $0d
    set  0, [HL]                                       ;; 00:0217 $cb $c6
    xor  A, A                                          ;; 00:0219 $af
    ldh  [rIF], A                                      ;; 00:021a $e0 $0f
    ldh  [rIE], A                                      ;; 00:021c $e0 $ff
    ld   A, P1F_GET_NONE                               ;; 00:021e $3e $30
    ldh  [rP1], A                                      ;; 00:0220 $e0 $00
    stop                                               ;; 00:0222 $10 $00
.jr_00_0224:
    ld   A, LCD_ISR_NONE                               ;; 00:0224 $3e $00
    call call_00_0c1b_InstallLcdIsr                    ;; 00:0226 $cd $1b $0c
    xor  A, A                                          ;; 00:0229 $af
    ldh  [rIF], A                                      ;; 00:022a $e0 $0f
    ld   A, STATF_MODE00                               ;; 00:022c $3e $08
    ldh  [rSTAT], A                                    ;; 00:022e $e0 $41
    ld   A, IEF_VBLANK | IEF_STAT                      ;; 00:0230 $3e $03
    ldh  [rIE], A                                      ;; 00:0232 $e0 $ff
    ld   A, BANK_04_AUDIO_CODE_1                       ;; 00:0234 $3e $04
    call call_00_0eee_SwitchBank                       ;; 00:0236 $cd $ee $0e
    call call_04_4000_Audio                            ;; 00:0239 $cd $00 $40
    call call_00_0f08_RestoreBank                      ;; 00:023c $cd $08 $0f
    xor  A, A                                          ;; 00:023f $af
    ld   [wDE60_AudioBankCurrent], A                   ;; 00:0240 $ea $60 $de
    ld   [wDE5E_QueuedSoundEffectPriority], A          ;; 00:0243 $ea $5e $de
    ld   [wDE5F_CurrentSoundEffectPriority], A         ;; 00:0246 $ea $5f $de
    ld   A, $ff                                        ;; 00:0249 $3e $ff
    ld   [wDE5C_CurrentSong], A                        ;; 00:024b $ea $5c $de
    ld   [wDE5D_QueuedSoundEffect], A                  ;; 00:024e $ea $5d $de
    ld   A, LCDC_INIT                                  ;; 00:0251 $3e $c7
    ld   [wDAD8_LCDCValue], A                          ;; 00:0253 $ea $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0256 $e0 $40
    ei                                                 ;; 00:0258 $fb
    call call_00_0b92_WaitForInterrupt                 ;; 00:0259 $cd $92 $0b
    farcall call_01_4f7e_SeedTileLookupTable
; ==================================================================
; The outer game loop, $0267-$04FA.
;
; This is not a subroutine and there is no `ret` anywhere in it - it is one long
; chain of labels that Init falls into and that only ever jumps backwards into
; itself. Reading it as a state machine, the states are:
;
;   .jp_00_0267_SoftReset   the five title and credit screens, in order. Reached
;                           again from A+B+SELECT+START held during play
;   .jp_00_02b2_LoadMainMenu the title screen. MENU_RESULT_START_GAME falls into
;                           the new-game setup below; MENU_RESULT_PASSWORD_ACCEPTED
;                           skips it, because the password already decoded the
;                           progress; anything else redisplays the title
;   .jp_00_02cc_LoadMainMenuAfterGameOver  new game: PLAYER_STARTING_LIVES, no
;                           paw coins, and PROGRESS_FLAG_COUNT entries of
;                           wDC5C_ProgressFlags wiped, then a fresh password is
;                           built from that
;   .jp_00_0314_LoadNewMap  enter a level. WARP_NEW_LEVEL means the previous
;                           level chose where to go next, so
;                           call_01_435e_DetermineNextMapId runs first. Then the
;                           map pointers, health, the level's menu and palette,
;                           the collectible and entity tables, the music and the
;                           level's cutscene
;   .jp_00_0357_RespawnAfterDeath  per-life setup. Everything that must not
;                           survive a death is reset here - the carried fly and
;                           its three timers, health, the top-down facing - which
;                           is why losing a life re-enters at this label with the
;                           level intact
;   .jp_00_038e_LoadMap     per-map setup, and the interesting one: it decides
;                           which action Gex spawns with. LEVEL_GEXTREME_SPORTS
;                           and LEVEL_MARSUPIAL_MADNESS have vehicle actions of
;                           their own, and on a BG_COLLISION_TYPE_TOPDOWN map
;                           the action is shifted by PLAYERACTION_TOPDOWN
;                           so that the same walk or idle becomes its top-down
;                           counterpart. Then the bg map, the entities and the
;                           screen
;   .jp_00_0421_Unpaused    resume after a menu closed. The level is still
;                           loaded and the entities are still in their slots, so
;                           this only rebuilds what the menu overwrote
;   .jp_00_0443_MainGameplayLoop  the per-frame loop
;
; The per-frame loop is deliberately short: wait for vblank, check for the soft
; reset, check the three exit conditions in wDB6A_WarpFlags, check for pause,
; then run one pass of the entity update and the deferred VRAM work. Everything
; that actually draws happens either in the vblank handler or in the LCD STAT
; handler.
;
; gex2's outer loop is the same shape at $0220-$051E, with an attract demo state
; gex3 does not have and one fewer level of map nesting
; ==================================================================

.jp_00_0267_SoftReset:
    ld   A, SONG_EMPTY                                 ;; 00:0267 $3e $00
    call call_00_0fa2_SetupMusic                       ;; 00:0269 $cd $a2 $0f
    ld   A, SFX_EMPTY                                  ;; 00:026c $3e $00
    call call_00_0fd7_PlaySFX                          ;; 00:026e $cd $d7 $0f
    ld   A, MENU_OPENING_CREDITS_1                     ;; 00:0271 $3e $11
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_OPENING_CREDITS_2                     ;; 00:027e $3e $12
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_EIDOS_INTERACTIVE                     ;; 00:028b $3e $14
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_OPENING_CRYSTAL_DYNAMICS              ;; 00:0298 $3e $13
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_DAVID_A_PALMER                        ;; 00:02a5 $3e $0f
    farcall call_01_4000_MenuHandler_LoadAndProcess
.jp_00_02b2_LoadMainMenu:
    ld   A, SONG_UNK01                                 ;; 00:02b2 $3e $01
    call call_00_0fa2_SetupMusic                       ;; 00:02b4 $cd $a2 $0f
    ld   A, MENU_TITLE_SCREEN                          ;; 00:02b7 $3e $00
    farcall call_01_4000_MenuHandler_LoadAndProcess
    cp   A, MENU_RESULT_PASSWORD_ACCEPTED              ;; 00:02c4 $fe $20
    jr   Z, .jr_00_02ed                                ;; 00:02c6 $28 $25
    cp   A, MENU_RESULT_START_GAME                     ;; 00:02c8 $fe $10
    jr   NZ, .jp_00_02b2_LoadMainMenu                  ;; 00:02ca $20 $e6
.jp_00_02cc_LoadMainMenuAfterGameOver:
    ld   A, PLAYER_STARTING_LIVES                      ;; 00:02cc $3e $04
    ld   [wDC4E_LivesRemaining], A                     ;; 00:02ce $ea $4e $dc
    xor  A, A                                          ;; 00:02d1 $af
    ld   [wDCAF_PawCoinCounter], A                     ;; 00:02d2 $ea $af $dc
    ld   [wDC4F_PawCoinExtraHealth], A                 ;; 00:02d5 $ea $4f $dc
    ld   HL, wDC5C_ProgressFlags                       ;; 00:02d8 $21 $5c $dc
    ld   B, PROGRESS_FLAG_COUNT                        ;; 00:02db $06 $0c
    xor  A, A                                          ;; 00:02dd $af
.jr_00_02de:
    ld   [HL+], A                                      ;; 00:02de $22
    dec  B                                             ;; 00:02df $05
    jr   NZ, .jr_00_02de                               ;; 00:02e0 $20 $fc
    farcall call_01_4f8c_BuildPasswordBitfieldAndChecksum
.jr_00_02ed:
    xor  A, A                                          ;; 00:02ed $af
    ld   [wDB6C_CurrentMapId], A                       ;; 00:02ee $ea $6c $db
    ld   [wDC5B_LevelIdFromTVButton], A                ;; 00:02f1 $ea $5b $dc
    ld   [wDC69_PlayerSpawnIdInLevel], A               ;; 00:02f4 $ea $69 $dc
    ld   [wDB6A_WarpFlags], A                          ;; 00:02f7 $ea $6a $db
    call call_00_0e3b_ResetVideoState                  ;; 00:02fa $cd $3b $0e
    call call_00_0e62_ClearShadowOamAndResetScroll     ;; 00:02fd $cd $62 $0e
    ld   C, HDMACFG_HUD_TILES                          ;; 00:0300 $0e $00
    call call_00_0a6a_Hdma_RunConfigEntry              ;; 00:0302 $cd $6a $0a
    ld   C, HDMACFG_HUD_ATTRIBUTES                     ;; 00:0305 $0e $01
    call call_00_0a6a_Hdma_RunConfigEntry              ;; 00:0307 $cd $6a $0a
    ld   C, HDMACFG_HUD_TILEMAP                        ;; 00:030a $0e $02
    call call_00_0a6a_Hdma_RunConfigEntry              ;; 00:030c $cd $6a $0a
    ld   A, LCDC_GAMEPLAY                              ;; 00:030f $3e $e7
    call call_00_0e33_SetLCDCAndWait                   ;; 00:0311 $cd $33 $0e
.jp_00_0314_LoadNewMap:
    ld   A, [wDB6A_WarpFlags]                          ;; 00:0314 $fa $6a $db
    and  A, WARP_NEW_LEVEL                             ;; 00:0317 $e6 $10
    jr   Z, .jr_00_0326                                ;; 00:0319 $28 $0b
    farcall call_01_435e_DetermineNextMapId
.jr_00_0326:
    farcall call_03_6c89_MapData_LoadForCurrentMap
    ld   A, [wDC4F_PawCoinExtraHealth]                 ;; 00:0331 $fa $4f $dc
    add  A, PLAYER_BASE_HEALTH                         ;; 00:0334 $c6 $04
    ld   [wDC50_Player_Health], A                      ;; 00:0336 $ea $50 $dc
    farcall call_01_432b_SetLevelMenuAndPalette
    call call_00_0e3b_ResetVideoState                  ;; 00:0344 $cd $3b $0e
    call call_00_2f85_CollectibleList_LoadForCurrentLevel       ;; 00:0347 $cd $85 $2f
    call call_00_2ff8_Level_InitEntitiesAndState       ;; 00:034a $cd $f8 $2f
    call call_00_0595_PlayMusicBasedOnLevel            ;; 00:034d $cd $95 $05
    call call_00_1ea0_Cutscene_LoadAndRun              ;; 00:0350 $cd $a0 $1e
    xor  A, A                                          ;; 00:0353 $af
    ld   [wDC69_PlayerSpawnIdInLevel], A               ;; 00:0354 $ea $69 $dc
.jp_00_0357_RespawnAfterDeath:
    ld   A, [wDC1E_CurrentLevelID]                     ;; 00:0357 $fa $1e $dc
    ld   [wDB6C_CurrentMapId], A                       ;; 00:035a $ea $6c $db
    farcall call_03_6c89_MapData_LoadForCurrentMap
    xor  A, A                                          ;; 00:0368 $af
    ld   [wDC51_Player_CurrentFly], A                  ;; 00:0369 $ea $51 $dc
    ld   [wDCA9_FlyPowerup2_Timer], A                  ;; 00:036c $ea $a9 $dc
    ld   [wDCAA_FlyPowerup1_Timer], A                  ;; 00:036f $ea $aa $dc
    ld   [wDCAB_FlyPowerup5_Timer], A                  ;; 00:0372 $ea $ab $dc
    ld   [wDC89_BgCollision_TopDownDirection], A       ;; 00:0375 $ea $89 $dc
    ld   A, [wDC4F_PawCoinExtraHealth]                 ;; 00:0378 $fa $4f $dc
    add  A, PLAYER_BASE_HEALTH                         ;; 00:037b $c6 $04
    ld   [wDC50_Player_Health], A                      ;; 00:037d $ea $50 $dc
    ld   A, PLAYERACTION_SPAWN                         ;; 00:0380 $3e $00
    ld   [wDC78_PlayerPendingActionId], A              ;; 00:0382 $ea $78 $dc
    call call_00_0e3b_ResetVideoState                  ;; 00:0385 $cd $3b $0e
    call call_00_2f85_CollectibleList_LoadForCurrentLevel       ;; 00:0388 $cd $85 $2f
    call call_00_2ff8_Level_InitEntitiesAndState       ;; 00:038b $cd $f8 $2f
.jp_00_038e_LoadMap:
    farcall call_03_6c89_MapData_LoadForCurrentMap
    ld   A, [wDC1E_CurrentLevelID]                     ;; 00:0399 $fa $1e $dc
    cp   A, LEVEL_GEXTREME_SPORTS                      ;; 00:039c $fe $07
    jr   NZ, .jr_00_03b6_NotInGextremeSports           ;; 00:039e $20 $16
    ld   A, [wDC78_PlayerPendingActionId]              ;; 00:03a0 $fa $78 $dc
    cp   A, PLAYERACTION_SPAWN                         ;; 00:03a3 $fe $00
    ld   A, PLAYERACTION_SNOWBOARDING_SPAWN ; entered gextreme sports level ;; 00:03a5 $3e $23
    jr   Z, .jr_00_03e8_SetPendingPlayerAction         ;; 00:03a7 $28 $3f
    ld   A, [wDB6C_CurrentMapId]                       ;; 00:03a9 $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                       ;; 00:03ac $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_STAND_OR_WALK ; left gextreme sports house ;; 00:03ae $3e $24
    jr   Z, .jr_00_03e8_SetPendingPlayerAction         ;; 00:03b0 $28 $36
    ld   A, PLAYERACTION_IDLE ; entered gextreme sports house ;; 00:03b2 $3e $01
    jr   .jr_00_03e8_SetPendingPlayerAction            ;; 00:03b4 $18 $32
.jr_00_03b6_NotInGextremeSports:
    ld   A, [wDC1E_CurrentLevelID]                     ;; 00:03b6 $fa $1e $dc
    cp   A, LEVEL_MARSUPIAL_MADNESS                    ;; 00:03b9 $fe $08
    ld   A, PLAYERACTION_KANGAROO_SPAWN ; entered marsupial madness ;; 00:03bb $3e $2f
    jr   Z, .jr_00_03e8_SetPendingPlayerAction         ;; 00:03bd $28 $29
    ld   A, [wDC1F_CurrentBgCollisionType]             ;; 00:03bf $fa $1f $dc
    cp   A, BG_COLLISION_TYPE_TOPDOWN                  ;; 00:03c2 $fe $01
    jr   Z, .jr_00_03d6_InTopDownCollision             ;; 00:03c4 $28 $10
    ld   A, [wDC78_PlayerPendingActionId]              ;; 00:03c6 $fa $78 $dc
    cp   A, PLAYERACTION_SPAWN ; entered sidescroller level ;; 00:03c9 $fe $00
    jr   Z, .jr_00_03e8_SetPendingPlayerAction         ;; 00:03cb $28 $1b
    ld   A, [wD801_Player_ActionId]                    ;; 00:03cd $fa $01 $d8
    sub  A, PLAYERACTION_TOPDOWN                ;; 00:03d0 $d6 $3c
    jr   C, .jr_00_03eb                                ;; 00:03d2 $38 $17
    jr   .jr_00_03e8_SetPendingPlayerAction            ;; 00:03d4 $18 $12
.jr_00_03d6_InTopDownCollision:
    ld   A, [wDC78_PlayerPendingActionId]              ;; 00:03d6 $fa $78 $dc
    cp   A, PLAYERACTION_SPAWN                         ;; 00:03d9 $fe $00
    ld   A, PLAYERACTION_TOPDOWN_SPAWN ; entered topdown collision map ;; 00:03db $3e $3c
    jr   Z, .jr_00_03e8_SetPendingPlayerAction         ;; 00:03dd $28 $09
    ld   A, [wD801_Player_ActionId]                    ;; 00:03df $fa $01 $d8
    cp   A, PLAYERACTION_TOPDOWN_SPAWN                 ;; 00:03e2 $fe $3c
    jr   NC, .jr_00_03eb                               ;; 00:03e4 $30 $05
    add  A, PLAYERACTION_TOPDOWN                ;; 00:03e6 $c6 $3c
.jr_00_03e8_SetPendingPlayerAction:
    ld   [wDC78_PlayerPendingActionId], A              ;; 00:03e8 $ea $78 $dc
.jr_00_03eb:
    xor  A, A                                          ;; 00:03eb $af
    ld   [wDC29_SkipMapWindowUpdateFlag], A            ;; 00:03ec $ea $29 $dc
    ld   A, $01                                        ;; 00:03ef $3e $01
    ld   [wDCA7_Player_UpdateFlag], A                  ;; 00:03f1 $ea $a7 $dc
    call call_00_04fb_ResetAudioAndVideoState          ;; 00:03f4 $cd $fb $04
    farcall call_03_647c_Map_SetSpawnPosition
    call call_00_1056_BgMap_LoadFull                   ;; 00:0402 $cd $56 $10
    farcall call_02_708f_Entities_InitAndSpawnAll
    call call_00_0513_Screen_PresentAndDrawEntities    ;; 00:0410 $cd $13 $05
    xor  A, A                                          ;; 00:0413 $af
    ld   [wDB6A_WarpFlags], A                          ;; 00:0414 $ea $6a $db
    ld   [wDCDB_EvilSantaHitByProjectileFlag], A       ;; 00:0417 $ea $db $dc
    ld   A, MAP_EDGE_NONE                              ;; 00:041a $3e $ff
    ld   [wDC8A_MapEdgeTouched], A                     ;; 00:041c $ea $8a $dc
    jr   .jp_00_0443_MainGameplayLoop                  ;; 00:041f $18 $22
.jp_00_0421_Unpaused:
    call call_00_0595_PlayMusicBasedOnLevel            ;; 00:0421 $cd $95 $05
    call call_00_04fb_ResetAudioAndVideoState          ;; 00:0424 $cd $fb $04
    call call_00_1056_BgMap_LoadFull                   ;; 00:0427 $cd $56 $10
    farcall call_02_7142_Entities_RestoreIdTable
    farcall call_03_68d9_AssignAllEntityPalettes
    call call_00_0513_Screen_PresentAndDrawEntities    ;; 00:0440 $cd $13 $05
.jp_00_0443_MainGameplayLoop:
    call call_00_0b92_WaitForInterrupt                 ;; 00:0443 $cd $92 $0b
    ld   A, [wDAD7_RawInputs]                          ;; 00:0446 $fa $d7 $da
    cp   A, PADF_A | PADF_B | PADF_SELECT | PADF_START ;; 00:0449 $fe $0f
    jp   Z, .jp_00_0267_SoftReset                      ;; 00:044b $ca $67 $02
    ld   HL, wDB6A_WarpFlags                           ;; 00:044e $21 $6a $db
    bit  WARP_CHANGE_MAP_BIT, [HL]                     ;; 00:0451 $cb $56
    jr   Z, .jr_00_045e_SkipLoadMap                    ;; 00:0453 $28 $09
    call call_00_1633_Map_LoadWarpDestination          ;; 00:0455 $cd $33 $16
    call call_00_2b3d_Entity_ClearAllSlots             ;; 00:0458 $cd $3d $2b
    jp   .jp_00_038e_LoadMap                           ;; 00:045b $c3 $8e $03
.jr_00_045e_SkipLoadMap:
    ld   HL, wDB6A_WarpFlags                           ;; 00:045e $21 $6a $db
    bit  WARP_NEW_LEVEL_BIT, [HL]                      ;; 00:0461 $cb $66
    jp   NZ, .jp_00_0314_LoadNewMap                    ;; 00:0463 $c2 $14 $03
    ld   HL, wDB6A_WarpFlags                           ;; 00:0466 $21 $6a $db
    bit  WARP_DIED_BIT, [HL]                           ;; 00:0469 $cb $4e
    jr   Z, .jr_00_0487                                ;; 00:046b $28 $1a
    ld   HL, wDC4E_LivesRemaining                      ;; 00:046d $21 $4e $dc
    dec  [HL]                                          ;; 00:0470 $35
    jp   NZ, .jp_00_0357_RespawnAfterDeath             ;; 00:0471 $c2 $57 $03
    farcall call_01_42fd_LoadMenu_GameOver
    cp   A, MENU_RESULT_CONTINUE                       ;; 00:047f $fe $40
    jp   Z, .jp_00_02cc_LoadMainMenuAfterGameOver      ;; 00:0481 $ca $cc $02
    jp   .jp_00_02b2_LoadMainMenu                      ;; 00:0484 $c3 $b2 $02
.jr_00_0487:
    farcall call_02_5541_Player_GetActionStates
    and  A, PLAYER_STATE_DEAD_MASK                     ;; 00:0492 $e6 $08
    jr   NZ, .jr_00_04d8_SkipPauseCheck                ;; 00:0494 $20 $42
    call call_00_0f80_CheckInputStart                  ;; 00:0496 $cd $80 $0f
    jr   Z, .jr_00_04d8_SkipPauseCheck                 ;; 00:0499 $28 $3d
    ld   A, SONG_EMPTY                                 ;; 00:049b $3e $00
    call call_00_0fa2_SetupMusic                       ;; 00:049d $cd $a2 $0f
    ld   A, SFX_EMPTY                                  ;; 00:04a0 $3e $00
    call call_00_0fd7_PlaySFX                          ;; 00:04a2 $cd $d7 $0f
    farcall call_02_7132_Entities_BackupIdTable
    ld   A, [wDC1E_CurrentLevelID]                     ;; 00:04b0 $fa $1e $dc
    and  A, A                                          ;; 00:04b3 $a7
    ld   A, MENU_PAUSE_IN_GEX_CAVE                     ;; 00:04b4 $3e $0b
    jr   Z, .jr_00_04ba_PausedInGexCave                ;; 00:04b6 $28 $02
    ld   A, MENU_PAUSE_IN_LEVEL                        ;; 00:04b8 $3e $0d
.jr_00_04ba_PausedInGexCave:
    farcall call_01_4000_MenuHandler_LoadAndProcess
    cp   A, MENU_RESULT_CONFIRM_QUIT                   ;; 00:04c5 $fe $60
    jp   NZ, .jp_00_0421_Unpaused                      ;; 00:04c7 $c2 $21 $04
    ld   A, [wDC1E_CurrentLevelID]                     ;; 00:04ca $fa $1e $dc
    and  A, A                                          ;; 00:04cd $a7
    jp   Z, .jp_00_02b2_LoadMainMenu                   ;; 00:04ce $ca $b2 $02
    xor  A, A                                          ;; 00:04d1 $af
    ld   [wDB6C_CurrentMapId], A                       ;; 00:04d2 $ea $6c $db
    jp   .jp_00_0314_LoadNewMap                        ;; 00:04d5 $c3 $14 $03
.jr_00_04d8_SkipPauseCheck:
    call call_00_05fd_Player_CheckEatFlyInput          ;; 00:04d8 $cd $fd $05
    call call_00_05c7_LevelTimer_Tick                  ;; 00:04db $cd $c7 $05
    farcall call_02_7152_Entities_UpdateAll
    call call_00_11c8_BgMap_LoadDirtyRegions           ;; 00:04e9 $cd $c8 $11
    call call_00_0fc8_PlayQueuedSFX                    ;; 00:04ec $cd $c8 $0f
    call call_00_150f_Map_CheckEdgeTransition          ;; 00:04ef $cd $0f $15
    call call_00_35fa_EntitySpawn_SpawnUntilScanline       ;; 00:04f2 $cd $fa $35
    call call_00_08f8_StageNextGfxTransfer             ;; 00:04f5 $cd $f8 $08
    jp   .jp_00_0443_MainGameplayLoop                  ;; 00:04f8 $c3 $43 $04

call_00_04fb_ResetAudioAndVideoState:
; Puts the engine back into a known state and turns the screen on for gameplay.
; Called on the way into a map and again on the way out of the pause menu.
;
; Silences the sfx side (there is no "stop" call - clearing the queue and both
; priorities is what stops a new effect being started), clears the per-map state
; and the entity table, wipes shadow OAM and the scroll registers, then hands
; LCDC_GAMEPLAY to call_00_0e33_SetLCDCAndWait.
;
; gex2's call_00_0f01_ResetVideoState is the same clearing pass, but it ends by
; switching the LCD OFF rather than on - there the screen comes back through the
; palette fade in call_00_0f56_SetLCDCAndFadeIn, which gex3 has no equivalent of
    xor  A, A                                          ;; 00:04fb $af
    ld   [wDE5E_QueuedSoundEffectPriority], A          ;; 00:04fc $ea $5e $de
    ld   [wDE5F_CurrentSoundEffectPriority], A         ;; 00:04ff $ea $5f $de
    ld   A, SFX_NONE                                   ;; 00:0502 $3e $ff
    ld   [wDE5D_QueuedSoundEffect], A                  ;; 00:0504 $ea $5d $de
    call call_00_0e3b_ResetVideoState                  ;; 00:0507 $cd $3b $0e
    call call_00_0e62_ClearShadowOamAndResetScroll     ;; 00:050a $cd $62 $0e
    ld   A, LCDC_GAMEPLAY                              ;; 00:050d $3e $e7
    call call_00_0e33_SetLCDCAndWait                   ;; 00:050f $cd $33 $0e
    ret                                                ;; 00:0512 $c9

call_00_0513_Screen_PresentAndDrawEntities:
; Makes a freshly built screen visible. Called after a map load and after a menu
; closes, and it blocks until everything it queued has actually reached VRAM.
;
; First it resolves Gex's tile graphics for this map. BANK_7F_ENTITY_PALETTES
; holds a per-map index (data_7f_4000) into a table of sprite banks and frame
; tables (data_7f_403d); wD80A_Player_SpriteId then picks a three-byte record
; from that table giving a bank offset and a pointer to the tile data. Those
; become wDABF_PlayerGfx_SrcBank / wDAC0_PlayerGfx_SrcAddr /
; wDAC2_PlayerGfx_TileCount, i.e. the GFX_XFER_PLAYER_GFX parameters, and the
; bit is raised.
;
; Then it asks for the hud palette LCD STAT handler, marks the whole status bar
; dirty, and spins - one frame at a time, restaging entity graphics as it goes -
; until wDB66_GfxTransferFlags is empty and every HUD_DIRTY_BLOCKING bit has been
; serviced. Only then does it draw the entities and raise
; wDD6A_PalettesReadyFlag, which is what lets the real colours reach the palette
; rams; until that point call_00_0e81_UploadCgbPalettes has been pushing grey,
; so none of the above is visible.
;
; That flag is gex3's whole transition effect. gex2's
; call_00_0521_Screen_PresentAndFadeIn ends with a DMG palette fade instead
    ld   A, BANK_7F_ENTITY_PALETTES                    ;; 00:0513 $3e $7f
    call call_00_0eee_SwitchBank                       ;; 00:0515 $cd $ee $0e
    ld   HL, wDB6C_CurrentMapId                        ;; 00:0518 $21 $6c $db
    ld   E, [HL]                                       ;; 00:051b $5e
    ld   D, $00                                        ;; 00:051c $16 $00
    ld   HL, data_7f_4000                              ;; 00:051e $21 $00 $40
    add  HL, DE                                        ;; 00:0521 $19
    ld   E, [HL]                                       ;; 00:0522 $5e
    ld   HL, data_7f_403d                              ;; 00:0523 $21 $3d $40
    add  HL, DE                                        ;; 00:0526 $19
    ld   A, [HL+]                                      ;; 00:0527 $2a
    ld   [wDABF_PlayerGfx_SrcBank], A                  ;; 00:0528 $ea $bf $da
    ld   A, [HL+]                                      ;; 00:052b $2a
    ld   H, [HL]                                       ;; 00:052c $66
    ld   L, A                                          ;; 00:052d $6f
    ld   A, [wD80A_Player_SpriteId]                    ;; 00:052e $fa $0a $d8
    ld   E, A                                          ;; 00:0531 $5f
    ld   D, $00                                        ;; 00:0532 $16 $00
    add  HL, DE                                        ;; 00:0534 $19
    add  HL, DE                                        ;; 00:0535 $19
    add  HL, DE                                        ;; 00:0536 $19
    ld   C, [HL]                                       ;; 00:0537 $4e
    inc  HL                                            ;; 00:0538 $23
    ld   A, [HL+]                                      ;; 00:0539 $2a
    ld   H, [HL]                                       ;; 00:053a $66
    ld   L, A                                          ;; 00:053b $6f
    push HL                                            ;; 00:053c $e5
    ld   A, [wDABF_PlayerGfx_SrcBank]                  ;; 00:053d $fa $bf $da
    add  A, C                                          ;; 00:0540 $81
    ld   [wDABF_PlayerGfx_SrcBank], A                  ;; 00:0541 $ea $bf $da
    call call_00_0f08_RestoreBank                      ;; 00:0544 $cd $08 $0f
    ld   A, [wDABF_PlayerGfx_SrcBank]                  ;; 00:0547 $fa $bf $da
    call call_00_0eee_SwitchBank                       ;; 00:054a $cd $ee $0e
    pop  HL                                            ;; 00:054d $e1
    ld   A, [HL+]                                      ;; 00:054e $2a
    ld   [wDAC2_PlayerGfx_TileCount], A                ;; 00:054f $ea $c2 $da
    inc  HL                                            ;; 00:0552 $23
    inc  HL                                            ;; 00:0553 $23
    ld   A, [HL+]                                      ;; 00:0554 $2a
    ld   [wDAC0_PlayerGfx_SrcAddr], A                  ;; 00:0555 $ea $c0 $da
    ld   A, [HL+]                                      ;; 00:0558 $2a
    ld   [wDAC0_PlayerGfx_SrcAddr+1], A                ;; 00:0559 $ea $c1 $da
    call call_00_0f08_RestoreBank                      ;; 00:055c $cd $08 $0f
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:055f $21 $66 $db
    set  GFX_XFER_PLAYER_GFX, [HL]                     ;; 00:0562 $cb $c6
    ld   A, LCD_ISR_HUD_PALETTE                        ;; 00:0564 $3e $05
    call call_00_0c10_RequestLcdIsr                    ;; 00:0566 $cd $10 $0c
    ld   HL, wDB69_HUDDirtyFlags                       ;; 00:0569 $21 $69 $db
    ld   [HL], HUD_DIRTY_ON_SCREEN_PRESENT             ;; 00:056c $36 $17
.jr_00_056e:
    call call_00_0b92_WaitForInterrupt                 ;; 00:056e $cd $92 $0b
    call call_00_08f8_StageNextGfxTransfer             ;; 00:0571 $cd $f8 $08
    ld   A, [wDB66_GfxTransferFlags]                   ;; 00:0574 $fa $66 $db
    and  A, $ff                                        ;; 00:0577 $e6 $ff
    jr   NZ, .jr_00_056e                               ;; 00:0579 $20 $f3
    ld   A, [wDB69_HUDDirtyFlags]                      ;; 00:057b $fa $69 $db
    and  A, HUD_DIRTY_BLOCKING                         ;; 00:057e $e6 $2f
    jr   NZ, .jr_00_056e                               ;; 00:0580 $20 $ec
    farcall call_03_5ec1_OAM_BuildFrame
    ld   A, $01                                        ;; 00:058d $3e $01
    ld   [wDD6A_PalettesReadyFlag], A                  ;; 00:058f $ea $6a $dd
    jp   call_00_0b92_WaitForInterrupt                 ;; 00:0592 $c3 $92 $0b

call_00_0595_PlayMusicBasedOnLevel:
; Looks up the current level's song in .data_00_05a3_LevelMusic and hands it to
; call_00_0fa2_SetupMusic, which no-ops if that song is already playing - so this
; is safe to call on every map load, not just level changes.
;
; gex2's call_00_11e0_PlayMusicBasedOnLevel is the same three instructions over
; the same shape of table, indexed by map id there rather than level id
    ld   HL, wDC1E_CurrentLevelID                      ;; 00:0595 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:0598 $6e
    ld   H, $00                                        ;; 00:0599 $26 $00
    ld   DE, .data_00_05a3_LevelMusic                  ;; 00:059b $11 $a3 $05
    add  HL, DE                                        ;; 00:059e $19
    ld   A, [HL]                                       ;; 00:059f $7e
    jp   call_00_0fa2_SetupMusic                       ;; 00:05a0 $c3 $a2 $0f
.data_00_05a3_LevelMusic:
; one song per level id, in level order
    db   SONG_GEX_CAVE, SONG_HOLIDAY_TV, SONG_MYSTERY_TV, SONG_TUT_TV
    db   SONG_WESTERN_STATION, SONG_ANIME_CHANNEL, SONG_SUPERHERO_SHOW
    db   SONG_BONUS_CHANNEL, SONG_BONUS_CHANNEL, SONG_BOSS, SONG_BOSS, SONG_CHANNEL_Z

call_00_05af_BgPalettes_LoadForMap:
; Copies this map's BG_PALETTE_BYTES of colour data out of the bank and offset
; the map header left in wDC13_BgPaletteBank / wDC14_BgPaletteBankOffset into
; wDCEA_BgPalettes. Nothing reaches hardware here - it is
; call_00_0e81_UploadCgbPalettes, once per vblank, that pushes the buffer out
    ld   A, [wDC13_BgPaletteBank]                      ;; 00:05af $fa $13 $dc
    call call_00_0eee_SwitchBank                       ;; 00:05b2 $cd $ee $0e
    ld   HL, wDC14_BgPaletteBankOffset                 ;; 00:05b5 $21 $14 $dc
    ld   A, [HL+]                                      ;; 00:05b8 $2a
    ld   H, [HL]                                       ;; 00:05b9 $66
    ld   L, A                                          ;; 00:05ba $6f
    ld   DE, wDCEA_BgPalettes                          ;; 00:05bb $11 $ea $dc
    ld   BC, BG_PALETTE_BYTES                          ;; 00:05be $01 $40 $00
    call call_00_076e_MemCopy                          ;; 00:05c1 $cd $6e $07
    jp   call_00_0f08_RestoreBank                      ;; 00:05c4 $c3 $08 $0f

call_00_05c7_LevelTimer_Tick:
; Per-frame tick of the bonus stage, and the only thing that ever ends one.
; Returns immediately outside a bonus stage (wDB6D_InBonusStage clear).
;
; There are two ways out and this routine owns both:
;
;   the remote was grabbed  bit 7 of wDCD2_FreestandingRemoteHitFlags. The exit
;                           still waits for the ENTITY_FREESTANDING_REMOTE slot
;                           to disappear, i.e. for its pickup animation to
;                           finish, and then raises WARP_NEW_LEVEL
;   the clock ran out       wDB6F_LevelTimer_FrameCounter counts down from
;                           FRAMES_PER_SECOND; every time it wraps, the status
;                           bar is marked dirty and
;                           wDB6E_LevelTimer_SecondsRemaining loses one. When
;                           that borrows, it is clamped to zero and
;                           WARP_NEW_LEVEL | WARP_TIME_UP go up together
;
; gex2's call_00_0598_LevelTimer_Tick is the countdown half of this, in BCD and
; with minutes as well as seconds, and it raises the same pair of warp bits. The
; remote half has no counterpart there - gex2's bonus levels end on a collectible
; quota instead, which it keeps in wD649_CollectibleAmount
    ld   A, [wDB6D_InBonusStage]                       ;; 00:05c7 $fa $6d $db
    and  A, A                                          ;; 00:05ca $a7
    ret  Z                                             ;; 00:05cb $c8
    ld   HL, wDCD2_FreestandingRemoteHitFlags          ;; 00:05cc $21 $d2 $dc
    bit  7, [HL]                                       ;; 00:05cf $cb $7e
    jr   NZ, .jr_00_05f1                               ;; 00:05d1 $20 $1e
    ld   HL, wDB6F_LevelTimer_FrameCounter             ;; 00:05d3 $21 $6f $db
    dec  [HL]                                          ;; 00:05d6 $35
    ret  NZ                                            ;; 00:05d7 $c0
    ld   [HL], FRAMES_PER_SECOND                       ;; 00:05d8 $36 $3c
    ld   HL, wDB69_HUDDirtyFlags                       ;; 00:05da $21 $69 $db
    set  HUD_DIRTY_TIMER, [HL]                         ;; 00:05dd $cb $d6
    ld   HL, wDB6E_LevelTimer_SecondsRemaining         ;; 00:05df $21 $6e $db
    ld   A, [HL]                                       ;; 00:05e2 $7e
    sub  A, $01                                        ;; 00:05e3 $d6 $01
    ld   [HL], A                                       ;; 00:05e5 $77
    ret  NC                                            ;; 00:05e6 $d0
    ld   [HL], $00                                     ;; 00:05e7 $36 $00
    ld   HL, wDB6A_WarpFlags                           ;; 00:05e9 $21 $6a $db
    set  WARP_NEW_LEVEL_BIT, [HL]                      ;; 00:05ec $cb $e6
    set  WARP_TIME_UP_BIT, [HL]                        ;; 00:05ee $cb $ee
    ret                                                ;; 00:05f0 $c9
.jr_00_05f1:
    ld   C, ENTITY_FREESTANDING_REMOTE                 ;; 00:05f1 $0e $1c
    call call_00_29ce_Entity_FindSlotById               ;; 00:05f3 $cd $ce $29
    ret  Z                                             ;; 00:05f6 $c8
    ld   HL, wDB6A_WarpFlags                           ;; 00:05f7 $21 $6a $db
    set  WARP_NEW_LEVEL_BIT, [HL]                      ;; 00:05fa $cb $e6
    ret                                                ;; 00:05fc $c9

call_00_05fd_Player_CheckEatFlyInput:
; SELECT eats the fly Gex is carrying. Requires a fly in wDC51_Player_CurrentFly
; and an action he can interrupt - PLAYERACTION_IDLE or PLAYERACTION_WALK, or one
; of the two top-down equivalents at $3d/$3e - and then requests
; PLAYERACTION_EAT_FLY, whose animation is what eventually calls
; call_00_0624_Player_SwapFlyPowerup.
;
; gex2 has nothing like this: there a fly takes effect the moment it is picked
; up. Storing one and spending it later is a gex3 idea, and it is why gex3's
; equivalent of gex2's swap routine is reached from an animation rather than
; from the collision code
    call call_00_0f8b_CheckInputSelect                 ;; 00:05fd $cd $8b $0f
    ret  Z                                             ;; 00:0600 $c8
    ld   A, [wDC51_Player_CurrentFly]                  ;; 00:0601 $fa $51 $dc
    and  A, A                                          ;; 00:0604 $a7
    ret  Z                                             ;; 00:0605 $c8
    ld   A, [wD801_Player_ActionId]                    ;; 00:0606 $fa $01 $d8
    cp   A, PLAYERACTION_IDLE                          ;; 00:0609 $fe $01
    ret  C                                             ;; 00:060b $d8
    cp   A, PLAYERACTION_WALK                          ;; 00:060c $fe $03
    jr   C, .jr_00_0616                                ;; 00:060e $38 $06
    cp   A, $3d                                        ;; 00:0610 $fe $3d
    ret  C                                             ;; 00:0612 $d8
    cp   A, $3f                                        ;; 00:0613 $fe $3f
    ret  NC                                            ;; 00:0615 $d0
.jr_00_0616:
    ld   A, PLAYERACTION_EAT_FLY                       ;; 00:0616 $3e $08
    farcall call_02_54f9_Player_RequestAction
    ret                                                ;; 00:0623 $c9

call_00_0624_Player_SwapFlyPowerup:
; Swaps the fly in A into wDC51_Player_CurrentFly and cashes the OLD one in. The
; old id is what everything below dispatches on, so eating a fly is what makes
; the PREVIOUS one take effect:
;
;   FLY_POWERUP_HEALTH      one health point back, capped at
;                           PLAYER_BASE_HEALTH + wDC4F_PawCoinExtraHealth
;   FLY_POWERUP_EXTRA_LIFE  falls into the extra-life tail of
;                           call_00_0723_Player_ObtainedCollectible
;   FLY_POWERUP_1 / _2 / _5 arm that power-up's own timer with
;                           FLY_POWERUP_SECONDS, clear the other two so they
;                           cannot overlap, reload the shared
;                           wDCA8_FlyPowerup_FrameCounter, and record which one
;                           is running in wDCAE_FlyPowerup_ActiveIndex
;
; Any other id, FLY_POWERUP_NONE included, returns having done nothing but store
; the new fly.
;
; gex2's call_00_0647_Player_SwapFlyPowerup dispatches on the outgoing fly in
; exactly the same way. Its two shield timers are 16-bit frame counts and its
; FLY_POWERUP_SHIELD_1 branch has a bug that leaves the other pair reading
; $0101; gex3's three branches are symmetric and count seconds off a shared
; frame counter instead
    ld   hl,wDC51_Player_CurrentFly
    ld   c,[hl]
    ld   [hl],a
    ld   a,c
    cp   a,FLY_POWERUP_HEALTH
    jr   z,.jr_00_0682
    cp   a,FLY_POWERUP_EXTRA_LIFE
    jp   z,call_00_0723_Player_ObtainedCollectible.jr_00_074b_GrantExtraLife
    cp   a,FLY_POWERUP_1
    jr   z,.jr_00_066C
    cp   a,FLY_POWERUP_5
    jr   z,.jr_00_0655
    cp   a,FLY_POWERUP_2
    ret  nz
    xor  a
    ld   [wDCAA_FlyPowerup1_Timer],a
    ld   [wDCAB_FlyPowerup5_Timer],a
    ld   a,FLY_POWERUP_SECONDS
    ld   [wDCA9_FlyPowerup2_Timer],a
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDCA8_FlyPowerup_FrameCounter],a
    ld   a,FLY_POWERUP_ACTIVE_2
    ld   [wDCAE_FlyPowerup_ActiveIndex],a
    ret  
.jr_00_0655:
    xor  a
    ld   [wDCAA_FlyPowerup1_Timer],a
    ld   [wDCA9_FlyPowerup2_Timer],a
    ld   a,FLY_POWERUP_SECONDS
    ld   [wDCAB_FlyPowerup5_Timer],a
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDCA8_FlyPowerup_FrameCounter],a
    ld   a,FLY_POWERUP_ACTIVE_5
    ld   [wDCAE_FlyPowerup_ActiveIndex],a
    ret  
.jr_00_066C:
    xor  a
    ld   [wDCA9_FlyPowerup2_Timer],a
    ld   [wDCAB_FlyPowerup5_Timer],a
    ld   a,FLY_POWERUP_SECONDS
    ld   [wDCAA_FlyPowerup1_Timer],a
    ld   a,TIMER_AMOUNT_60_FRAMES
    ld   [wDCA8_FlyPowerup_FrameCounter],a
    xor  a
    ld   [wDCAE_FlyPowerup_ActiveIndex],a
    ret  
.jr_00_0682:
    ld   a,[wDC4F_PawCoinExtraHealth]
    add  a,PLAYER_BASE_HEALTH
    ld   hl,wDC50_Player_Health
    cp   [hl]
    ret  z
    inc  [hl]
    ld   hl,wDB69_HUDDirtyFlags
    set  HUD_DIRTY_HEALTH,[hl]
    ret  

jp_00_0693_Player_Die:
; Starts the death animation. Reached when health hits zero in
; call_00_06f6_Player_TakeDamage, and from the player action code.
;
; Which animation depends on two things. Bit 7 of wDABE_CollisionFlags -
; BGCOLL_NO_COLLISION_BIT, i.e. "he is standing on something" - separates a
; normal death from falling into a pit, and the current map picks between Gex's
; own animation and the two vehicle ones:
;
;   MAP_GEXTREME_SPORTS1     the snowboard
;   MAP_MARSUPIAL_MADNESS1   the kangaroo
;
; Note this only requests the action. The life is not spent here - the death
; animation raises WARP_DIED when it finishes, and the outer game loop is what
; decrements wDC4E_LivesRemaining. gex2's call_00_0696_Player_Die is the other
; way round: it deducts the life itself and lets the loop test for zero
    ld   HL, wDABE_CollisionFlags                      ;; 00:0693 $21 $be $da
    bit  7, [HL]                                       ;; 00:0696 $cb $7e
    jr   NZ, .jr_00_06ba                               ;; 00:0698 $20 $20
    ld   A, [wDB6C_CurrentMapId]                       ;; 00:069a $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                       ;; 00:069d $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT ;; 00:069f $3e $2e
    jr   Z, .jr_00_06ae                                ;; 00:06a1 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                       ;; 00:06a3 $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                     ;; 00:06a6 $fe $08
    ld   A, PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT     ;; 00:06a8 $3e $3b
    jr   Z, .jr_00_06ae                                ;; 00:06aa $28 $02
    ld   A, PLAYERACTION_DEATH_IN_PIT_ALT              ;; 00:06ac $3e $1a
.jr_00_06ae:
    farcall call_02_54f9_Player_RequestAction
    ret                                                ;; 00:06b9 $c9
.jr_00_06ba:
    ld   A, [wDB6C_CurrentMapId]                       ;; 00:06ba $fa $6c $db
    cp   A, MAP_GEXTREME_SPORTS1                       ;; 00:06bd $fe $07
    ld   A, PLAYERACTION_SNOWBOARDING_DIE              ;; 00:06bf $3e $2a
    jr   Z, .jr_00_06ce                                ;; 00:06c1 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                       ;; 00:06c3 $fa $6c $db
    cp   A, MAP_MARSUPIAL_MADNESS1                     ;; 00:06c6 $fe $08
    ld   A, PLAYERACTION_KANGAROO_DEATH                ;; 00:06c8 $3e $37
    jr   Z, .jr_00_06ce                                ;; 00:06ca $28 $02
    ld   A, PLAYERACTION_DEATH                         ;; 00:06cc $3e $0a
.jr_00_06ce:
    farcall call_02_54f9_Player_RequestAction
    ret                                                ;; 00:06d9 $c9

jp_00_06da_Player_DieInPit:
; Instant death on tile type $28, the pit tile. Called from
; call_02_5431_Player_CheckTileInteractions when either of the two tiles behind
; Gex is one, and from the two pit-death actions themselves so that landing in a
; second pit re-triggers
    ld   A, PLAYERACTION_DEATH_IN_PIT                  ;; 00:06da $3e $1b
    farcall call_02_54f9_Player_RequestAction
    ret                                                ;; 00:06e7 $c9

jp_00_06e8_Player_HitHazardTile:
; Requests PLAYERACTION_UNK19 when tile type $19 is behind Gex's lower body.
; Reached only from call_02_5431_Player_CheckTileInteractions
    ld   A, PLAYERACTION_UNK19                         ;; 00:06e8 $3e $13
    farcall call_02_54f9_Player_RequestAction
    ret                                                ;; 00:06f5 $c9

call_00_06f6_Player_TakeDamage:
; One hit. Returns without doing anything while the invincibility window from the
; last hit is still open.
;
; A carried fly absorbs the hit entirely - wDC51_Player_CurrentFly is cleared and
; health is left alone - so the fly is effectively an extra hit point that is
; spent before the real ones. Without one, health goes down by one, is floored at
; zero rather than allowed to wrap, and reaching zero jumps to
; jp_00_0693_Player_Die.
;
; Either way the hit arms wDC7E_Player_DamageCooldownTimer for
; TIMER_AMOUNT_60_FRAMES, marks the health part of the status bar dirty and
; queues SFX_PLAYER_DAMAGED.
;
; gex2's call_00_06bf_Player_TakeDamage does all of the same things, and its fly
; works the same way; the difference is that it also requests
; PLAYER_ACTION_TAKE_DAMAGE, where gex3 leaves the reaction to the player code
    call call_00_0759_Player_IsInvincible              ;; 00:06f6 $cd $59 $07
    ret  NZ                                            ;; 00:06f9 $c0
    ld   A, TIMER_AMOUNT_60_FRAMES                     ;; 00:06fa $3e $3c
    ld   [wDC7E_Player_DamageCooldownTimer], A         ;; 00:06fc $ea $7e $dc
    ld   HL, wDB69_HUDDirtyFlags                       ;; 00:06ff $21 $69 $db
    set  HUD_DIRTY_HEALTH, [HL]                        ;; 00:0702 $cb $ce
    ld   A, SFX_PLAYER_DAMAGED                         ;; 00:0704 $3e $0a
    call call_00_0ff5_QueueSFX                         ;; 00:0706 $cd $f5 $0f
    ld   HL, wDC51_Player_CurrentFly                   ;; 00:0709 $21 $51 $dc
    ld   A, [HL]                                       ;; 00:070c $7e
    and  A, A                                          ;; 00:070d $a7
    jr   Z, .jr_00_0713                                ;; 00:070e $28 $03
    ld   [HL], $00                                     ;; 00:0710 $36 $00
    ret                                                ;; 00:0712 $c9
.jr_00_0713:
    ld   A, [wDC50_Player_Health]                      ;; 00:0713 $fa $50 $dc
    sub  A, $01                                        ;; 00:0716 $d6 $01
    jr   NC, .jr_00_071b                               ;; 00:0718 $30 $01
    xor  A, A                                          ;; 00:071a $af
.jr_00_071b:
    ld   [wDC50_Player_Health], A                      ;; 00:071b $ea $50 $dc
    and  A, A                                          ;; 00:071e $a7
    jp   Z, jp_00_0693_Player_Die                      ;; 00:071f $ca $93 $06
    ret                                                ;; 00:0722 $c9

call_00_0723_Player_ObtainedCollectible:
; One fly coin picked up. Marks the counters dirty, queues SFX_ITEM_PICKUP and
; increments wDC68_CollectibleAmount, which only ever rises.
;
; Two thresholds pay out, and they are exact equality tests rather than
; multiples, so each fires once per level:
;
;   COLLECTIBLE_EXTRA_LIFE      falls into .jr_00_074b_GrantExtraLife
;   COLLECTIBLE_LEVEL_COMPLETE  plays SFX_REMOTE and sets
;                               PROGRESS_ALL_COLLECTIBLES_BIT in this level's
;                               wDC5C_ProgressFlags entry
;
; gex2's call_00_06ec_Player_ObtainedCollectible walks a milestone table instead,
; and once it reaches the last entry every further multiple of 50 pays out. It
; also uses the same counter as a falling quota in its bonus levels, which gex3
; does not - gex3's bonus stages are timed, not quota'd
    ld   HL, wDB69_HUDDirtyFlags                       ;; 00:0723 $21 $69 $db
    set  HUD_DIRTY_COUNTERS, [HL]                      ;; 00:0726 $cb $c6
    ld   A, SFX_ITEM_PICKUP                            ;; 00:0728 $3e $02
    call call_00_0ff5_QueueSFX                         ;; 00:072a $cd $f5 $0f
    ld   HL, wDC68_CollectibleAmount                   ;; 00:072d $21 $68 $dc
    inc  [HL]                                          ;; 00:0730 $34
    ld   A, [HL]                                       ;; 00:0731 $7e
    cp   A, COLLECTIBLE_EXTRA_LIFE                     ;; 00:0732 $fe $32
    jr   Z, .jr_00_074b_GrantExtraLife                 ;; 00:0734 $28 $15
    cp   A, COLLECTIBLE_LEVEL_COMPLETE                 ;; 00:0736 $fe $64
    ret  NZ                                            ;; 00:0738 $c0
    ld   A, SFX_REMOTE                                 ;; 00:0739 $3e $1e
    call call_00_0ff5_QueueSFX                         ;; 00:073b $cd $f5 $0f
    ld   HL, wDC1E_CurrentLevelID                      ;; 00:073e $21 $1e $dc
    ld   L, [HL]                                       ;; 00:0741 $6e
    ld   H, $00                                        ;; 00:0742 $26 $00
    ld   DE, wDC5C_ProgressFlags                       ;; 00:0744 $11 $5c $dc
    add  HL, DE                                        ;; 00:0747 $19
    set  PROGRESS_ALL_COLLECTIBLES_BIT, [HL]           ;; 00:0748 $cb $de
    ret                                                ;; 00:074a $c9
.jr_00_074b_GrantExtraLife:
; Also the FLY_POWERUP_EXTRA_LIFE branch of call_00_0624_Player_SwapFlyPowerup,
; which jumps straight here. Clamped at PLAYER_MAX_LIVES because the counter is
; drawn as two digits
    ld   HL, wDC4E_LivesRemaining                      ;; 00:074b $21 $4e $dc
    ld   A, [HL]                                       ;; 00:074e $7e
    cp   A, PLAYER_MAX_LIVES                           ;; 00:074f $fe $63
    ret  NC                                            ;; 00:0751 $d0
    inc  [HL]                                          ;; 00:0752 $34
    ld   HL, wDB69_HUDDirtyFlags                       ;; 00:0753 $21 $69 $db
    set  HUD_DIRTY_COUNTERS, [HL]                      ;; 00:0756 $cb $c6
    ret                                                ;; 00:0758 $c9

call_00_0759_Player_IsInvincible:
; Returns NZ if Gex cannot be damaged right now and Z if he can, which is why
; callers read `call ... / ret NZ`. gex3 has only one source of it - the flicker
; window after a hit - so the routine is a plain load and test; gex2's
; call_00_075b_Player_IsInvincible has to check its two fly shield timers as well
    ld   A, [wDC7E_Player_DamageCooldownTimer]         ;; 00:0759 $fa $7e $dc
    and  A, A                                          ;; 00:075c $a7
    ret  NZ                                            ;; 00:075d $c0
    ret                                                ;; 00:075e $c9

call_00_075f_FarMemCopy:
; MemCopy from another bank: BC bytes from bank A:HL to DE. The three pushes are
; only there because SwitchBank clobbers HL, DE and BC on its way through the
; bank stack, so the arguments have to survive it. gex2's call_00_07a1_FarMemCopy
    push HL                                            ;; 00:075f $e5
    push DE                                            ;; 00:0760 $d5
    push BC                                            ;; 00:0761 $c5
    call call_00_0eee_SwitchBank                       ;; 00:0762 $cd $ee $0e
    pop  BC                                            ;; 00:0765 $c1
    pop  DE                                            ;; 00:0766 $d1
    pop  HL                                            ;; 00:0767 $e1
    call call_00_076e_MemCopy                          ;; 00:0768 $cd $6e $07
    jp   call_00_0f08_RestoreBank                      ;; 00:076b $c3 $08 $0f

call_00_076e_MemCopy:
; Copy BC bytes from HL to DE, ascending. BC = 0 copies $10000 bytes rather than
; none, since the count is tested after the decrement.
;
; Init uses it as a memset by pointing DE one byte past HL, so each write feeds
; the next read. There is no overlap check and no unrolling; the unrolled
; tile-sized version is call_00_0bcf_CopyTileRows. gex2's call_00_07b0_MemCopy
    ld   A, [HL+]                                      ;; 00:076e $2a
    ld   [DE], A                                       ;; 00:076f $12
    inc  DE                                            ;; 00:0770 $13
    dec  BC                                            ;; 00:0771 $0b
    ld   A, B                                          ;; 00:0772 $78
    or   A, C                                          ;; 00:0773 $b1
    jr   NZ, call_00_076e_MemCopy                      ;; 00:0774 $20 $f8
    ret                                                ;; 00:0776 $c9

call_00_0777_GetPointerFromTable:
; HL = word read from DE[A]. A is the entry index, DE points at a table of little
; endian pointers. Used all over the place for jump, frame and palette tables.
; gex2's call_00_07b9_GetPointerFromTable
    ld   L, A                                          ;; 00:0777 $6f
    ld   H, $00                                        ;; 00:0778 $26 $00
    add  HL, HL                                        ;; 00:077a $29
    add  HL, DE                                        ;; 00:077b $19
    ld   E, [HL]                                       ;; 00:077c $5e
    inc  HL                                            ;; 00:077d $23
    ld   H, [HL]                                       ;; 00:077e $66
    ld   L, E                                          ;; 00:077f $6b
    ret                                                ;; 00:0780 $c9

jp_00_0781_Screen_LoadFullscreenImage:
; Loads one fullscreen menu image - title screens, credits, the password grid -
; from the eight-byte record at wDBB1_ScreenDraw_HasPaletteIdMap that
; call_01_47b1_LoadMenuConfigData filled in. Entered with a `jp`, and returns
; through call_00_0f08_RestoreBank to whoever called that.
;
; The tile graphics go out through wC000_BgMapTileIds, which is free while a menu
; is up because there is no bg map to hold. Anything larger than
; SCREEN_TILE_CHUNK_BYTES is split: the tail is staged and flushed by
; HDMACFG_WRAM_TILES_BANK1 first, then the leading $1000 bytes are staged and
; left for the caller to flush.
;
; The tilemap is SCREEN_TILEMAP_BYTES of tile ids and lands in
; wD400_ScreenDraw_TileIds. What follows it in ROM depends on
; wDBB1_ScreenDraw_HasPaletteIdMap:
;
;   1  a second SCREEN_TILEMAP_BYTES block is the palette map, copied straight
;      into wD578_ScreenDraw_PaletteIds
;   0  a tile-id-indexed lookup table follows instead. The tilemap is copied into
;      wD578_ScreenDraw_PaletteIds and then rewritten in place, each entry
;      replaced by table[entry] - so an image with few distinct tiles pays for a
;      small table rather than a full-screen map
;
; gex2's call_00_084d_Screen_LoadFullscreenImage covers the same ground on the
; graphics side but generates its tilemap rather than storing one, and reads its
; GBC attributes as a plain 20x18 block with no lookup form
    ld   A, [wDBB2_ScreenDraw_Bank]                    ;; 00:0781 $fa $b2 $db
    call call_00_0eee_SwitchBank                       ;; 00:0784 $cd $ee $0e
    ld   HL, wDBB7_ScreenDraw_TileDataSize             ;; 00:0787 $21 $b7 $db
    ld   C, [HL]                                       ;; 00:078a $4e
    inc  HL                                            ;; 00:078b $23
    ld   B, [HL]                                       ;; 00:078c $46
    ld   HL, wDBB5_ScreenDraw_TileDataPtr              ;; 00:078d $21 $b5 $db
    ld   A, [HL+]                                      ;; 00:0790 $2a
    ld   H, [HL]                                       ;; 00:0791 $66
    ld   L, A                                          ;; 00:0792 $6f
    ld   A, C                                          ;; 00:0793 $79
    sub  A, $00                                        ;; 00:0794 $d6 $00
    ld   E, A                                          ;; 00:0796 $5f
    ld   A, B                                          ;; 00:0797 $78
    sbc  A, HIGH(SCREEN_TILE_CHUNK_BYTES)              ;; 00:0798 $de $10
    jr   C, .jr_00_07b2                                ;; 00:079a $38 $16
    ld   B, A                                          ;; 00:079c $47
    ld   C, E                                          ;; 00:079d $4b
    push HL                                            ;; 00:079e $e5
    ld   DE, SCREEN_TILE_CHUNK_BYTES                   ;; 00:079f $11 $00 $10
    add  HL, DE                                        ;; 00:07a2 $19
    ld   DE, wC000_BgMapTileIds                        ;; 00:07a3 $11 $00 $c0
    call call_00_076e_MemCopy                          ;; 00:07a6 $cd $6e $07
    ld   C, HDMACFG_WRAM_TILES_BANK1                   ;; 00:07a9 $0e $0a
    call call_00_0a6a_Hdma_RunConfigEntry              ;; 00:07ab $cd $6a $0a
    pop  HL                                            ;; 00:07ae $e1
    ld   BC, SCREEN_TILE_CHUNK_BYTES                   ;; 00:07af $01 $00 $10
.jr_00_07b2:
    ld   DE, wC000_BgMapTileIds                        ;; 00:07b2 $11 $00 $c0
    call call_00_076e_MemCopy                          ;; 00:07b5 $cd $6e $07
    ld   HL, wDBB3_ScreenDraw_TilemapPtr               ;; 00:07b8 $21 $b3 $db
    ld   A, [HL+]                                      ;; 00:07bb $2a
    ld   H, [HL]                                       ;; 00:07bc $66
    ld   L, A                                          ;; 00:07bd $6f
    ld   DE, wD400_ScreenDraw_TileIds                  ;; 00:07be $11 $00 $d4
    ld   BC, SCREEN_TILEMAP_BYTES                      ;; 00:07c1 $01 $68 $01
    call call_00_076e_MemCopy                          ;; 00:07c4 $cd $6e $07
    ld   A, [wDBB1_ScreenDraw_HasPaletteIdMap]         ;; 00:07c7 $fa $b1 $db
    and  A, A                                          ;; 00:07ca $a7
    jr   Z, .jr_00_07d9                                ;; 00:07cb $28 $0c
    ld   DE, wD578_ScreenDraw_PaletteIds               ;; 00:07cd $11 $78 $d5
    ld   BC, SCREEN_TILEMAP_BYTES                      ;; 00:07d0 $01 $68 $01
    call call_00_076e_MemCopy                          ;; 00:07d3 $cd $6e $07
    jp   call_00_0f08_RestoreBank                      ;; 00:07d6 $c3 $08 $0f
.jr_00_07d9:
    push HL                                            ;; 00:07d9 $e5
    ld   HL, wD400_ScreenDraw_TileIds                  ;; 00:07da $21 $00 $d4
    ld   DE, wD578_ScreenDraw_PaletteIds               ;; 00:07dd $11 $78 $d5
    ld   BC, SCREEN_TILEMAP_BYTES                      ;; 00:07e0 $01 $68 $01
    call call_00_076e_MemCopy                          ;; 00:07e3 $cd $6e $07
    pop  DE                                            ;; 00:07e6 $d1
    ld   HL, wD578_ScreenDraw_PaletteIds               ;; 00:07e7 $21 $78 $d5
    ld   BC, SCREEN_TILEMAP_BYTES                      ;; 00:07ea $01 $68 $01
.jr_00_07ed:
    push DE                                            ;; 00:07ed $d5
    ld   A, [HL]                                       ;; 00:07ee $7e
    add  A, E                                          ;; 00:07ef $83
    ld   E, A                                          ;; 00:07f0 $5f
    ld   A, $00                                        ;; 00:07f1 $3e $00
    adc  A, D                                          ;; 00:07f3 $8a
    ld   D, A                                          ;; 00:07f4 $57
    ld   A, [DE]                                       ;; 00:07f5 $1a
    ld   [HL+], A                                      ;; 00:07f6 $22
    pop  DE                                            ;; 00:07f7 $d1
    dec  BC                                            ;; 00:07f8 $0b
    ld   A, B                                          ;; 00:07f9 $78
    or   A, C                                          ;; 00:07fa $b1
    jr   NZ, .jr_00_07ed                               ;; 00:07fb $20 $f0
    jp   call_00_0f08_RestoreBank                      ;; 00:07fd $c3 $08 $0f

call_00_0800_Screen_LoadSecondaryTilesetRow:
; Lifts a SECONDARY_TILESET_MAP_ROWS x SECONDARY_TILESET_MAP_COLS block of tile
; ids out of the current map's bank $1F secondary tileset and writes it into the
; caller's buffer at HL, which is SCRN_X_B wide - hence the stride added at the
; end of each row. The block sits SECONDARY_TILESET_MAP_OFFSET past the start of
; the tileset, i.e. just after its tile data.
;
; Used by the level select menu to show a picture of the level being chosen.
; Preserves HL, DE and BC, which is why the caller can drop it into the middle of
; its own tilemap walk
    push HL                                            ;; 00:0800 $e5
    push DE                                            ;; 00:0801 $d5
    push BC                                            ;; 00:0802 $c5
    push HL                                            ;; 00:0803 $e5
    ld   A, BANK_1F_SECONDARY_TILESETS                 ;; 00:0804 $3e $1f
    call call_00_0eee_SwitchBank                       ;; 00:0806 $cd $ee $0e
    ld   A, [wDB6C_CurrentMapId]                       ;; 00:0809 $fa $6c $db
    ld   DE, data_00_0b01_SecondaryTilesetPtrs         ;; 00:080c $11 $01 $0b
    call call_00_0777_GetPointerFromTable              ;; 00:080f $cd $77 $07
    ld   DE, SECONDARY_TILESET_MAP_OFFSET              ;; 00:0812 $11 $00 $03
    add  HL, DE                                        ;; 00:0815 $19
    ld   E, L                                          ;; 00:0816 $5d
    ld   D, H                                          ;; 00:0817 $54
    pop  HL                                            ;; 00:0818 $e1
    ld   C, SECONDARY_TILESET_MAP_ROWS                 ;; 00:0819 $0e $06
.jr_00_081b:
    ld   B, SECONDARY_TILESET_MAP_COLS                 ;; 00:081b $06 $08
.jr_00_081d:
    ld   A, [DE]                                       ;; 00:081d $1a
    ld   [HL+], A                                      ;; 00:081e $22
    inc  DE                                            ;; 00:081f $13
    dec  B                                             ;; 00:0820 $05
    jr   NZ, .jr_00_081d                               ;; 00:0821 $20 $fa
    ld   A, L                                          ;; 00:0823 $7d
    add  A, SCRN_X_B - SECONDARY_TILESET_MAP_COLS      ;; 00:0824 $c6 $0c
    ld   L, A                                          ;; 00:0826 $6f
    ld   A, H                                          ;; 00:0827 $7c
    adc  A, $00                                        ;; 00:0828 $ce $00
    ld   H, A                                          ;; 00:082a $67
    dec  C                                             ;; 00:082b $0d
    jr   NZ, .jr_00_081b                               ;; 00:082c $20 $ed
    call call_00_0f08_RestoreBank                      ;; 00:082e $cd $08 $0f
    pop  BC                                            ;; 00:0831 $c1
    pop  DE                                            ;; 00:0832 $d1
    pop  HL                                            ;; 00:0833 $e1
    ret                                                ;; 00:0834 $c9

call_00_0835_Text_LoadStringToBuffer:
; Copies one string out of BANK_1C_TEXT into wDADD_MenuTextBuffer and repoints
; the menu's string pointer at the copy.
;
; wDBA7_MenuCommandBuffer2_Unk3 holds the address of a pointer table;
; wDBF8_TextStringIndex picks the entry. The string runs until a byte with bit 7
; set - which is copied too, as the terminator - and a zero is written after it.
; The pointer pair is then overwritten with wDADD_MenuTextBuffer, so the menu
; renderer reads the WRAM copy from here on
    ld   A, BANK_1C_TEXT                               ;; 00:0835 $3e $1c
    call call_00_0eee_SwitchBank                       ;; 00:0837 $cd $ee $0e
    ld   HL, wDBA7_MenuCommandBuffer2_Unk3             ;; 00:083a $21 $a7 $db
    ld   A, [HL+]                                      ;; 00:083d $2a
    ld   D, [HL]                                       ;; 00:083e $56
    ld   E, A                                          ;; 00:083f $5f
    ld   HL, wDBF8_TextStringIndex                     ;; 00:0840 $21 $f8 $db
    ld   L, [HL]                                       ;; 00:0843 $6e
    ld   H, $00                                        ;; 00:0844 $26 $00
    add  HL, HL                                        ;; 00:0846 $29
    add  HL, DE                                        ;; 00:0847 $19
    ld   A, [HL+]                                      ;; 00:0848 $2a
    ld   H, [HL]                                       ;; 00:0849 $66
    ld   L, A                                          ;; 00:084a $6f
    ld   DE, wDADD_MenuTextBuffer                      ;; 00:084b $11 $dd $da
.jr_00_084e:
    ld   A, [HL+]                                      ;; 00:084e $2a
    ld   [DE], A                                       ;; 00:084f $12
    inc  DE                                            ;; 00:0850 $13
    bit  7, A                                          ;; 00:0851 $cb $7f
    jr   Z, .jr_00_084e                                ;; 00:0853 $28 $f9
    xor  A, A                                          ;; 00:0855 $af
    ld   [DE], A                                       ;; 00:0856 $12
    ld   HL, wDADD_MenuTextBuffer                      ;; 00:0857 $21 $dd $da
    ld   A, L                                          ;; 00:085a $7d
    ld   [wDBA7_MenuCommandBuffer2_Unk3], A            ;; 00:085b $ea $a7 $db
    ld   A, H                                          ;; 00:085e $7c
    ld   [wDBA8_MenuCommandBuffer2_Unk4], A            ;; 00:085f $ea $a8 $db
    jp   call_00_0f08_RestoreBank                      ;; 00:0862 $c3 $08 $0f

call_00_0865_Text_AppendStringToBuffer:
; Same source, different destination: appends string wDBF8_TextStringIndex of the
; pointer table at DE onto whatever is already in wDADD_MenuTextBuffer.
;
; It finds the end of the existing text by scanning forward for a byte of $80
; starting at wDADC_WindowY + 1 - which is wDADD_MenuTextBuffer, reached that way
; because the address is one past a label the assembler already had - and then
; copies until it has written the new string's own $80
    push de
    ld   a,BANK_1C_TEXT
    call call_00_0eee_SwitchBank
    pop  de
    ld   hl,wDBF8_TextStringIndex
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,de
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    ld   de,wDADC_WindowY
.jr_00_087A:
    inc  de
    ld   a,[de]
    cp   a,$80
    jr   nz,.jr_00_087A
.jr_00_0880:
    ldi  a,[hl]
    ld   [de],a
    inc  de
    cp   a,$80
    jr   nz,.jr_00_0880
    jp   call_00_0f08_RestoreBank

call_00_088a_Menu_RunHdmaAnimations:
; Four independent background animations for the menus, run once per frame from
; call_00_0b9f_VBlank_UpdateVRAM and skipped entirely unless
; wDBE3_Menu_AnimateFlag is set.
;
; wDC72_AnimFrameCounter advances every frame and wraps at 10, and a frame is
; only stepped on the tick where it wraps - so all four animations share one
; ten-frame cadence. Each entry of .data_00_08dc_MenuHdmaAnimations is seven
; bytes: a pointer to that animation's own frame counter in WRAM, its frame
; count, then the HDMA source and destination. The frame number is scaled by
; $100 - `swap` plus two `add HL, HL` - so a frame is 256 bytes, and the
; resulting source is programmed straight into rHDMA1..rHDMA5 as a four-block
; general purpose DMA.
;
; This is the closest thing gex3 has to gex2's call_00_0d84_VBlank_RunGfxStream,
; but the two are not the same mechanism: gex2 walks a script of explicit
; (source, destination) pairs one chunk per frame, while this steps four
; independent frame counters over fixed strides
    ld   A, [wDBE3_Menu_AnimateFlag]                   ;; 00:088a $fa $e3 $db
    and  A, A                                          ;; 00:088d $a7
    ret  Z                                             ;; 00:088e $c8
    ld   A, BANK_0A_ENTITY_SPRITES                     ;; 00:088f $3e $0a
    call call_00_0eee_SwitchBank                       ;; 00:0891 $cd $ee $0e
    ld   HL, wDC72_AnimFrameCounter                    ;; 00:0894 $21 $72 $dc
    inc  [HL]                                          ;; 00:0897 $34
    ld   A, [HL]                                       ;; 00:0898 $7e
    sub  A, $0a                                        ;; 00:0899 $d6 $0a
    jr   NZ, .jr_00_089e                               ;; 00:089b $20 $01
    ld   [HL], A                                       ;; 00:089d $77
.jr_00_089e:
    ld   DE, .data_00_08dc_MenuHdmaAnimations          ;; 00:089e $11 $dc $08
    ld   B, $04                                        ;; 00:08a1 $06 $04
.jr_00_08a3:
    ld   A, [DE]                                       ;; 00:08a3 $1a
    inc  DE                                            ;; 00:08a4 $13
    ld   L, A                                          ;; 00:08a5 $6f
    ld   A, [DE]                                       ;; 00:08a6 $1a
    inc  DE                                            ;; 00:08a7 $13
    ld   H, A                                          ;; 00:08a8 $67
    ld   A, [wDC72_AnimFrameCounter]                   ;; 00:08a9 $fa $72 $dc
    and  A, A                                          ;; 00:08ac $a7
    jr   NZ, .jr_00_08b5                               ;; 00:08ad $20 $06
    inc  [HL]                                          ;; 00:08af $34
    ld   A, [DE]                                       ;; 00:08b0 $1a
    sub  A, [HL]                                       ;; 00:08b1 $96
    jr   NZ, .jr_00_08b5                               ;; 00:08b2 $20 $01
    ld   [HL], A                                       ;; 00:08b4 $77
.jr_00_08b5:
    ld   A, [HL]                                       ;; 00:08b5 $7e
    swap A                                             ;; 00:08b6 $cb $37
    ld   L, A                                          ;; 00:08b8 $6f
    ld   H, $00                                        ;; 00:08b9 $26 $00
    add  HL, HL                                        ;; 00:08bb $29
    add  HL, HL                                        ;; 00:08bc $29
    inc  DE                                            ;; 00:08bd $13
    ld   A, [DE]                                       ;; 00:08be $1a
    inc  DE                                            ;; 00:08bf $13
    add  A, L                                          ;; 00:08c0 $85
    ld   L, A                                          ;; 00:08c1 $6f
    ld   A, [DE]                                       ;; 00:08c2 $1a
    inc  DE                                            ;; 00:08c3 $13
    adc  A, H                                          ;; 00:08c4 $8c
    ldh  [rHDMA1], A                                   ;; 00:08c5 $e0 $51
    ld   A, L                                          ;; 00:08c7 $7d
    ldh  [rHDMA2], A                                   ;; 00:08c8 $e0 $52
    ld   A, [DE]                                       ;; 00:08ca $1a
    inc  DE                                            ;; 00:08cb $13
    ldh  [rHDMA4], A                                   ;; 00:08cc $e0 $54
    ld   A, [DE]                                       ;; 00:08ce $1a
    inc  DE                                            ;; 00:08cf $13
    ldh  [rHDMA3], A                                   ;; 00:08d0 $e0 $53
    ld   A, $03                                        ;; 00:08d2 $3e $03
    ldh  [rHDMA5], A                                   ;; 00:08d4 $e0 $55
    dec  B                                             ;; 00:08d6 $05
    jr   NZ, .jr_00_08a3                               ;; 00:08d7 $20 $ca
    jp   call_00_0f08_RestoreBank                      ;; 00:08d9 $c3 $08 $0f
.data_00_08dc_MenuHdmaAnimations:
; Seven bytes per animation: the address of its frame counter, its frame count,
; then the low and high bytes of the HDMA source and destination. All four
; counters live in wDBE4..wDBE7
    dw   wDBE4                                         ;; 00:08dc pP
    db   $08, $a0, $57, $80, $8f                       ;; 00:08de .....
    dw   wDBE5                                         ;; 00:08e3 pP
    db   $04, $a0, $4a, $c0, $8e                       ;; 00:08e5 .....
    dw   wDBE6                                         ;; 00:08ea pP
    db   $06, $a0, $4b, $00, $8f                       ;; 00:08ec .....
    dw   wDBE7                                         ;; 00:08f1 pP
    db   $08, $20, $4d, $40, $8f                       ;; 00:08f3 .....

call_00_08f8_StageNextGfxTransfer:
; Finds the next entity that wants its graphics uploaded and fills in the
; GFX_XFER_ENTITY_GFX parameters for it. Called once per frame from the outer
; game loop, and again from call_00_0513_Screen_PresentAndDrawEntities while it
; waits.
;
; It spins while GFX_XFER_PENDING is set, then returns early if a player or
; config transfer is already queued - those outrank entity graphics - and only
; then walks the entity table from wD840_EntityMemoryAfterPlayer in
; ENTITY_SLOT_STRIDE steps, looking for a live slot whose
; ENTITY_FIELD_ACTION_STATE_FLAGS has bit 1 set, i.e. one whose animation frame
; changed.
;
; What happens next depends on ACTION_STATE_UNK20_BIT of that same byte, and the
; two paths are quite different:
;
;   set    the entity's tiles come from a small table built into this routine
;          (the bytes after .jr_00_096e_RaiseEntityGfxRequest), keyed by the entity's sprite id: five
;          bytes of (id, stride, base pointer), and the frame number multiplies
;          the stride
;   clear  the entity's type selects one of nine address resolvers through
;          .data_00_0a58_EntityVRAMSourceResolvers, each of which is a different
;          fixed-point multiply of the frame number by a tile count, added to
;          that type's base address
;
; Either way the answer lands in wDB64_EntityGfx_SrcAddr, the slot offset in
; wDB61_EntityGfx_SlotOffset and the size in wDB63_EntityGfx_PageCount, and the
; request bits go up.
;
; gex2's call_00_08fc_StageNextGfxTransfer is the same position in the frame and
; the same request byte, but it services five different sources - Gex, entities,
; the secondary tileset, a queue and the hub tv - and it stages 256 bytes into
; wD100_TilesToLoadBuffer rather than computing HDMA parameters, because gex2
; has no HDMA to hand the work to
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:08f8 $21 $66 $db
    bit  GFX_XFER_PENDING, [HL]                        ;; 00:08fb $cb $7e
    jr   NZ, call_00_08f8_StageNextGfxTransfer         ;; 00:08fd $20 $f9
    bit  GFX_XFER_HDMA_CONFIG, [HL]                    ;; 00:08ff $cb $56
    jp   NZ, .jp_00_0a52_RaisePendingBit               ;; 00:0901 $c2 $52 $0a
    bit  GFX_XFER_PLAYER_GFX, [HL]                     ;; 00:0904 $cb $46
    jp   NZ, .jp_00_0a52_RaisePendingBit               ;; 00:0906 $c2 $52 $0a
    bit  GFX_XFER_ENTITY_GFX, [HL]                     ;; 00:0909 $cb $4e
    ret  NZ                                            ;; 00:090b $c0
    ld   HL, wD840_EntityMemoryAfterPlayer             ;; 00:090c $21 $40 $d8
.jr_00_090f:
    push HL                                            ;; 00:090f $e5
    ld   A, [HL]                                       ;; 00:0910 $7e
    inc  A                                             ;; 00:0911 $3c
    jr   Z, .jr_00_0922                                ;; 00:0912 $28 $0e
    ld   A, L                                          ;; 00:0914 $7d
    or   A, $05                                        ;; 00:0915 $f6 $05
    ld   L, A                                          ;; 00:0917 $6f
    bit  1, [HL]                                       ;; 00:0918 $cb $4e
    jr   Z, .jr_00_0922                                ;; 00:091a $28 $06
    bit  5, [HL]                                       ;; 00:091c $cb $6e
    jr   NZ, .jr_00_092a                               ;; 00:091e $20 $0a
    jr   .jr_00_099c                                   ;; 00:0920 $18 $7a
.jr_00_0922:
    pop  HL                                            ;; 00:0922 $e1
    ld   A, L                                          ;; 00:0923 $7d
    add  A, ENTITY_SLOT_STRIDE                         ;; 00:0924 $c6 $20
    ld   L, A                                          ;; 00:0926 $6f
    jr   NZ, .jr_00_090f                               ;; 00:0927 $20 $e6
    ret                                                ;; 00:0929 $c9
.jr_00_092a:
    res  1, [HL]                                       ;; 00:092a $cb $8e
    pop  HL                                            ;; 00:092c $e1
    ld   A, L                                          ;; 00:092d $7d
    ld   [wDB61_EntityGfx_SlotOffset], A               ;; 00:092e $ea $61 $db
    or   A, $0a                                        ;; 00:0931 $f6 $0a
    ld   L, A                                          ;; 00:0933 $6f
    ld   C, [HL]                                       ;; 00:0934 $4e
    inc  C                                             ;; 00:0935 $0c
    ld   A, L                                          ;; 00:0936 $7d
    xor  A, $0a                                        ;; 00:0937 $ee $0a
    ld   L, A                                          ;; 00:0939 $6f
    ld   B, [HL]                                       ;; 00:093a $46
    ld   HL, .jr_00_096e_RaiseEntityGfxRequest         ;; 00:093b $21 $6e $09
    ld   DE, $05                                       ;; 00:093e $11 $05 $00
.jr_00_0941:
    add  HL, DE                                        ;; 00:0941 $19
    ld   A, [HL]                                       ;; 00:0942 $7e
    cp   A, $ff                                        ;; 00:0943 $fe $ff
    ret  Z                                             ;; 00:0945 $c8
    cp   A, B                                          ;; 00:0946 $b8
    jr   NZ, .jr_00_0941                               ;; 00:0947 $20 $f8
    ld   A, [HL+]                                      ;; 00:0949 $2a
    ld   A, [HL+]                                      ;; 00:094a $2a
    ld   E, A                                          ;; 00:094b $5f
    ld   A, [HL+]                                      ;; 00:094c $2a
    ld   D, A                                          ;; 00:094d $57
    ld   A, [HL+]                                      ;; 00:094e $2a
    ld   H, [HL]                                       ;; 00:094f $66
    ld   L, A                                          ;; 00:0950 $6f
.jr_00_0951:
    add  HL, DE                                        ;; 00:0951 $19
    dec  C                                             ;; 00:0952 $0d
    jr   NZ, .jr_00_0951                               ;; 00:0953 $20 $fc
    ld   A, L                                          ;; 00:0955 $7d
    ld   [wDB64_EntityGfx_SrcAddr], A                  ;; 00:0956 $ea $64 $db
    ld   A, H                                          ;; 00:0959 $7c
    ld   [wDB64_EntityGfx_SrcAddr+1], A                ;; 00:095a $ea $65 $db
    farcall call_03_59b6_Entity_GetSpriteTileBase
    ld   [wDB63_EntityGfx_PageCount], A                ;; 00:0968 $ea $63 $db
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:096b $21 $66 $db
.jr_00_096e_RaiseEntityGfxRequest:
    set  GFX_XFER_ENTITY_GFX, [HL]                     ;; 00:096e $cb $ce
    set  GFX_XFER_PENDING, [HL]                        ;; 00:0970 $cb $fe
    ret                                                ;; 00:0972 $c9
    db   $1e                                           ;; 00:0973 .
    dw   $0300                                         ;; 00:0974 wW
    dw   $3d00                                         ;; 00:0976 wW
    db   $38, $00, $02, $00, $77, $4d, $80, $01        ;; 00:0978 ????????
    db   $80, $3e, $55, $40, $02, $c0, $3d, $39        ;; 00:0980 ????????
    db   $80, $01, $80, $3e, $3a, $80, $01, $80        ;; 00:0988 ????????
    db   $3e, $6e, $80, $03, $80, $3c, $66, $00        ;; 00:0990 ????????
    db   $02, $00, $3e, $ff                            ;; 00:0998 ????
.jr_00_099c:
    res  1, [HL]                                       ;; 00:099c $cb $8e
    pop  HL                                            ;; 00:099e $e1
    ld   A, L                                          ;; 00:099f $7d
    ld   [wDB61_EntityGfx_SlotOffset], A               ;; 00:09a0 $ea $61 $db
    or   A, $0a                                        ;; 00:09a3 $f6 $0a
    ld   L, A                                          ;; 00:09a5 $6f
    ld   A, [HL]                                       ;; 00:09a6 $7e
    push AF                                            ;; 00:09a7 $f5
    farcall call_03_59b6_Entity_GetSpriteTileBase
    ld   [wDB63_EntityGfx_PageCount], A                ;; 00:09b3 $ea $63 $db
    ld   L, A                                          ;; 00:09b6 $6f
    ld   H, $00                                        ;; 00:09b7 $26 $00
    add  HL, HL                                        ;; 00:09b9 $29
    ld   DE, .data_00_0a58_EntityVRAMSourceResolvers   ;; 00:09ba $11 $58 $0a
    add  HL, DE                                        ;; 00:09bd $19
    ld   A, [HL+]                                      ;; 00:09be $2a
    ld   H, [HL]                                       ;; 00:09bf $66
    ld   L, A                                          ;; 00:09c0 $6f
    pop  AF                                            ;; 00:09c1 $f1
    ld   D, A                                          ;; 00:09c2 $57
    ld   E, $00                                        ;; 00:09c3 $1e $00
    jp   HL                                            ;; 00:09c5 $e9
.jr_00_09c6:
    srl  d
    rr   e
    srl  d
    rr   e
    ld   l,e
    ld   h,d
    srl  d
    rr   e
    add  hl,de
    ld   de,$79E0
    add  hl,de
    jr   .jr_00_0a45
.jr_00_09db:
    srl  d
    rr   e
    ld   l,e
    ld   h,d
    srl  d
    rr   e
    srl  d
    rr   e
    add  hl,de
    ld   de,$7AA0
    add  hl,de
    jr   .jr_00_0a45
.jr_00_09f0:
    srl  D                                             ;; 00:09f0 $cb $3a
    rr   E                                             ;; 00:09f2 $cb $1b
    ld   L, E                                          ;; 00:09f4 $6b
    ld   H, D                                          ;; 00:09f5 $62
    srl  D                                             ;; 00:09f6 $cb $3a
    rr   E                                             ;; 00:09f8 $cb $1b
    add  HL, DE                                        ;; 00:09fa $19
    ld   DE, $4000                                     ;; 00:09fb $11 $00 $40
    add  HL, DE                                        ;; 00:09fe $19
    jr   .jr_00_0a45                                   ;; 00:09ff $18 $44
.jr_00_0a01:
    srl  d
    rr   e
    ld   l,e
    ld   h,d
    srl  d
    rr   e
    add  hl,de
    srl  d
    rr   e
    add  hl,de
    ld   de,$7AA0
    add  hl,de
    jr   .jr_00_0a45
.jr_00_0a17:
    srl  D                                             ;; 00:0a17 $cb $3a
    rr   E                                             ;; 00:0a19 $cb $1b
    srl  D                                             ;; 00:0a1b $cb $3a
    rr   E                                             ;; 00:0a1d $cb $1b
    srl  D                                             ;; 00:0a1f $cb $3a
    rr   E                                             ;; 00:0a21 $cb $1b
    ld   HL, $4000                                     ;; 00:0a23 $21 $00 $40
    add  HL, DE                                        ;; 00:0a26 $19
    jr   .jr_00_0a45                                   ;; 00:0a27 $18 $1c
.jr_00_0a29:
    srl  D                                             ;; 00:0a29 $cb $3a
    rr   E                                             ;; 00:0a2b $cb $1b
    srl  D                                             ;; 00:0a2d $cb $3a
    rr   E                                             ;; 00:0a2f $cb $1b
    ld   HL, $4aa0                                     ;; 00:0a31 $21 $a0 $4a
    add  HL, DE                                        ;; 00:0a34 $19
    jr   .jr_00_0a45                                   ;; 00:0a35 $18 $0e
.jr_00_0a37:
    srl  d
    rr   e
    ld   hl, $4000
    add  hl,de
    jr   .jr_00_0a45
.jr_00_0a41:
    ld   HL, $4000                                     ;; 00:0a41 $21 $00 $40
    add  HL, DE                                        ;; 00:0a44 $19
.jr_00_0a45:
    ld   A, L                                          ;; 00:0a45 $7d
    ld   [wDB64_EntityGfx_SrcAddr], A                  ;; 00:0a46 $ea $64 $db
    ld   A, H                                          ;; 00:0a49 $7c
    ld   [wDB64_EntityGfx_SrcAddr+1], A                ;; 00:0a4a $ea $65 $db
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0a4d $21 $66 $db
    set  GFX_XFER_ENTITY_GFX, [HL]                     ;; 00:0a50 $cb $ce
.jp_00_0a52_RaisePendingBit:
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0a52 $21 $66 $db
    set  GFX_XFER_PENDING, [HL]                        ;; 00:0a55 $cb $fe
    ret                                                ;; 00:0a57 $c9
.data_00_0a58_EntityVRAMSourceResolvers:
; One resolver per entity graphics type, as returned by
; call_03_59b6_Entity_GetSpriteTileBase. Each computes
; base + frame * (tiles per frame) with shifts and adds, which is why there is
; one entry per distinct sprite size rather than a single multiply
    dw   .jr_00_0a17, .jr_00_0a17, .jr_00_0a29         ;; 00:0a58 ??
    dw   .jr_00_09c6, .jr_00_0a37, .jr_00_09db         ;; 00:0a5e ??????
    dw   .jr_00_09f0, .jr_00_0a01, .jr_00_0a41         ;; 00:0a64 pP

call_00_0a6a_Hdma_RunConfigEntry:
; Runs one entry of .data_00_0aa9_HdmaConfigTable, in C, and blocks until it has
; finished.
;
; The entry is copied into the wDC2B_Hdma_SrcAddrLo job struct and
; GFX_XFER_HDMA_CONFIG is raised; from there
; call_00_0c6a_VBlank_StartPendingHdma moves HDMA_MAX_BLOCKS blocks per vblank
; and advances the struct, so a transfer bigger than $400 bytes takes several
; frames. This routine simply waits a frame at a time for the bit to clear.
;
; The one piece of interpretation happens on the way in: an entry whose bank byte
; is HDMACFG_BANK_MAP_TILESET is not a fixed ROM address but an offset into the
; current map's tileset, so wDC08_TilesetBankOffset is added to the source and
; wDC07_TilesetBank replaces the bank. That is how the four HDMACFG_TILESET_*
; entries serve every map in the game
    ld   L, C                                          ;; 00:0a6a $69
    ld   H, $00                                        ;; 00:0a6b $26 $00
    add  HL, HL                                        ;; 00:0a6d $29
    add  HL, HL                                        ;; 00:0a6e $29
    add  HL, HL                                        ;; 00:0a6f $29
    ld   DE, .data_00_0aa9_HdmaConfigTable             ;; 00:0a70 $11 $a9 $0a
    add  HL, DE                                        ;; 00:0a73 $19
    ld   DE, wDC2B_Hdma_SrcAddrLo                      ;; 00:0a74 $11 $2b $dc
    ld   BC, HDMACFG_ENTRY_SIZE                        ;; 00:0a77 $01 $08 $00
    call call_00_076e_MemCopy                          ;; 00:0a7a $cd $6e $07
    ld   A, [wDC31_Hdma_SrcBank]                       ;; 00:0a7d $fa $31 $dc
    cp   A, HDMACFG_BANK_MAP_TILESET                   ;; 00:0a80 $fe $ff
    jr   NZ, .jr_00_0a94                               ;; 00:0a82 $20 $10
    ld   HL, wDC2B_Hdma_SrcAddrLo                      ;; 00:0a84 $21 $2b $dc
    ld   A, [wDC08_TilesetBankOffset]                  ;; 00:0a87 $fa $08 $dc
    add  A, [HL]                                       ;; 00:0a8a $86
    ld   [HL+], A                                      ;; 00:0a8b $22
    ld   A, [wDC08_TilesetBankOffset+1]                ;; 00:0a8c $fa $09 $dc
    adc  A, [HL]                                       ;; 00:0a8f $8e
    ld   [HL], A                                       ;; 00:0a90 $77
    ld   A, [wDC07_TilesetBank]                        ;; 00:0a91 $fa $07 $dc
.jr_00_0a94:
    ld   [wDC31_Hdma_SrcBank], A                       ;; 00:0a94 $ea $31 $dc
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0a97 $21 $66 $db
    set  GFX_XFER_HDMA_CONFIG, [HL]                    ;; 00:0a9a $cb $d6
    set  GFX_XFER_PENDING, [HL]                        ;; 00:0a9c $cb $fe
.jr_00_0a9e:
    call call_00_0b92_WaitForInterrupt                 ;; 00:0a9e $cd $92 $0b
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0aa1 $21 $66 $db
    bit  GFX_XFER_HDMA_CONFIG, [HL]                    ;; 00:0aa4 $cb $56
    jr   NZ, .jr_00_0a9e                               ;; 00:0aa6 $20 $f6
    ret                                                ;; 00:0aa8 $c9
.data_00_0aa9_HdmaConfigTable:
; Eight bytes per entry: source, destination, length, then the ROM bank and the
; destination VRAM bank. Indexed by the HDMACFG_* constants, and note the entries
; come in VRAM-bank pairs - the same bytes are written to bank 0 for tile ids and
; bank 1 for attributes, which is why the bg map is drawn twice over.
; HDMACFG_BANK_MAP_TILESET ($ff) in the bank byte means "relocate this against
; the map's own tileset"
    dw   $7800, _VRAM, $03c0, $010c                    ;; 00:0aa9 $78 $00
    dw   $7c00, _SCRN1, $0040, $010c                   ;; 00:0ab1 $00 $0c
    dw   $7bc0, _SCRN1, $0040, $000c                   ;; 00:0ab9 $00 $0c
    dw   $0000, _VRAM+$1000, $0800, $00ff              ;; 00:0ac1 ........
    dw   $0800, _VRAM+$800, $0800, $00ff               ;; 00:0ac9 ........
    dw   $1000, _VRAM+$1000, $0800, $01ff              ;; 00:0ad1 ........
    dw   $1800, _VRAM+$800, $0800, $01ff               ;; 00:0ad9 ........
    dw   $c000, _SCRN0, $0400, $0101                   ;; 00:0ae1 ........
    dw   $c000, _SCRN0, $0400, $0001                   ;; 00:0ae9 ........
    dw   $c000, _VRAM, $1000, $0001                    ;; 00:0af1 ........
    dw   $c000, _VRAM, $1000, $0101                    ;; 00:0af9 .???????

data_00_0b01_SecondaryTilesetPtrs:
; One bank $1F secondary tileset per map id, read by
; call_00_0800_Screen_LoadSecondaryTilesetRow
    dw   image_01f_00, image_01f_00, image_01f_01, image_01f_02 ;; 00:0b01 .???????
    dw   image_01f_03, image_01f_04, image_01f_05, image_01f_06 ;; 00:0b09 .???????
    dw   image_01f_06, image_01f_07, image_01f_08, image_01f_09 ;; 00:0b11 .???????

data_00_0b19_TvUnlockRequirements:
; How much progress each tv in the Gex Cave hub wants before it will let the
; player in, indexed by the tv entity's parameter. Read by
; call_02_5a83_EntityAction_TVButton_unk4 and
; call_02_5af8_EntityAction_TVRemote_unk4.
;
; Bit 7 changes what the low bits mean: set, they are a count of levels whose
; progress flag 4 is set, compared against
; call_01_4ae7_CountLevelsWithFlag4; clear, they are a plain remote total
    db   $00, $01, $02, $05, $09, $0d, $12, $83        ;; 00:0b19 .???????
    db   $87, $0e, $13, $17                            ;; 00:0b21 .???????

call_00_0b25_VBlank_Handler:
; The VBlank interrupt handler - isrVBlank at $0040 is a bare `jp` to here, and
; this ends in `reti`. The main loop is elsewhere and calls
; call_00_0b92_WaitForInterrupt to sync to it.
;
; In order: OAM DMA out of HRAM, the one VRAM update pass this frame is allowed,
; install a newly requested LCD STAT handler if wD9FD_LcdIsrId still has bit 7
; clear, run the vblank hook that pairs with the installed handler
; (wD9FE_VBlankHookPtrLo - this is where the HDMA and the gfx stream actually
; happen), read the joypad, push the shadow LCDC / scroll / window registers to
; hardware, then bank in the audio driver for its per-frame tick.
;
; The tail is gex3's own. After the audio call it raises
; wDB6B_VBlankDoneFlag, then - if rLY is still inside the visible frame - spins
; until the line changes and records that line in
; wDB67_LcdIsr_ScanlineCounter. That seeds the counter the hud palette handler
; counts hblanks from, which is why the split lands on the same scanline every
; frame however long the rest of this handler took.
;
; The audio call bypasses call_00_0eee_SwitchBank and uses
; call_00_0f25_SetMbcBank directly, restoring from wDAD5_CurrentROMBank rather
; than popping the bank stack - an interrupt landing between the two halves of
; SwitchBank would corrupt it. gex2's call_00_0a54_VBlank_Handler does the same
; thing with its SET_MBC_BANK macro, for the same reason
    push AF                                            ;; 00:0b25 $f5
    push BC                                            ;; 00:0b26 $c5
    push DE                                            ;; 00:0b27 $d5
    push HL                                            ;; 00:0b28 $e5
    call hFF80_OamDmaRoutine                           ;; 00:0b29 $cd $80 $ff
    call call_00_0b9f_VBlank_UpdateVRAM                ;; 00:0b2c $cd $9f $0b
    ld   A, [wD9FD_LcdIsrId]                           ;; 00:0b2f $fa $fd $d9
    bit  LCD_ISR_INSTALLED_BIT, A                      ;; 00:0b32 $cb $7f
    call Z, call_00_0c1b_InstallLcdIsr                 ;; 00:0b34 $cc $1b $0c
    ld   HL, wD9FE_VBlankHookPtrLo                     ;; 00:0b37 $21 $fe $d9
    ld   A, [HL+]                                      ;; 00:0b3a $2a
    ld   H, [HL]                                       ;; 00:0b3b $66
    ld   L, A                                          ;; 00:0b3c $6f
    call call_00_0f22_JumpHL                           ;; 00:0b3d $cd $22 $0f
    call call_00_0f31_ReadJoypadInput                  ;; 00:0b40 $cd $31 $0f
    call call_00_0e81_UploadCgbPalettes                ;; 00:0b43 $cd $81 $0e
    ld   A, [wDAD8_LCDCValue]                          ;; 00:0b46 $fa $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0b49 $e0 $40
    ld   A, [wDAD9_BgMap_ScrollXLo]                    ;; 00:0b4b $fa $d9 $da
    ldh  [rSCX], A                                     ;; 00:0b4e $e0 $43
    ld   A, [wDADA_BgMap_ScrollYLo]                    ;; 00:0b50 $fa $da $da
    ldh  [rSCY], A                                     ;; 00:0b53 $e0 $42
    ld   A, [wDADB_WindowX]                            ;; 00:0b55 $fa $db $da
    ldh  [rWX], A                                      ;; 00:0b58 $e0 $4b
    ld   A, [wDADC_WindowY]                            ;; 00:0b5a $fa $dc $da
    ldh  [rWY], A                                      ;; 00:0b5d $e0 $4a
    ld   HL, wDC71_VBlankFrameCounter                  ;; 00:0b5f $21 $71 $dc
    inc  [HL]                                          ;; 00:0b62 $34
    ld   A, [wDE60_AudioBankCurrent]                   ;; 00:0b63 $fa $60 $de
    add  A, BANK_04_AUDIO_CODE_1                       ;; 00:0b66 $c6 $04
    call call_00_0f25_SetMbcBank                       ;; 00:0b68 $cd $25 $0f
    call call_04_4009                                  ;; 00:0b6b $cd $09 $40
    ld   A, [wDAD5_CurrentROMBank]                     ;; 00:0b6e $fa $d5 $da
    call call_00_0f25_SetMbcBank                       ;; 00:0b71 $cd $25 $0f
    ld   A, $01                                        ;; 00:0b74 $3e $01
    ld   [wDB6B_VBlankDoneFlag], A                     ;; 00:0b76 $ea $6b $db
    ldh  A, [rLY]                                      ;; 00:0b79 $f0 $44
    cp   A, SCRN_Y                                     ;; 00:0b7b $fe $90
    jr   NC, .jr_00_0b88                               ;; 00:0b7d $30 $09
    ld   C, A                                          ;; 00:0b7f $4f
.jr_00_0b80:
    ldh  A, [rLY]                                      ;; 00:0b80 $f0 $44
    cp   A, C                                          ;; 00:0b82 $b9
    jr   Z, .jr_00_0b80                                ;; 00:0b83 $28 $fb
    ld   [wDB67_LcdIsr_ScanlineCounter], A             ;; 00:0b85 $ea $67 $db
.jr_00_0b88:
    ld   HL, rIF                                       ;; 00:0b88 $21 $0f $ff
    res  1, [HL]                                       ;; 00:0b8b $cb $8e
    pop  HL                                            ;; 00:0b8d $e1
    pop  DE                                            ;; 00:0b8e $d1
    pop  BC                                            ;; 00:0b8f $c1
    pop  AF                                            ;; 00:0b90 $f1
    reti                                               ;; 00:0b91 $d9

call_00_0b92_WaitForInterrupt:
; Clears wDB6B_VBlankDoneFlag and halts until the vblank handler sets it again,
; i.e. blocks until the start of the next frame. This is what paces the whole
; game. gex2's call_00_0ab4_WaitForInterrupt
    xor  A, A                                          ;; 00:0b92 $af
    ld   [wDB6B_VBlankDoneFlag], A                     ;; 00:0b93 $ea $6b $db
.jr_00_0b96:
    halt                                               ;; 00:0b96 $76
    nop                                                ;; 00:0b97 $00
    ld   A, [wDB6B_VBlankDoneFlag]                     ;; 00:0b98 $fa $6b $db
    and  A, A                                          ;; 00:0b9b $a7
    jr   Z, .jr_00_0b96                                ;; 00:0b9c $28 $f8
    ret                                                ;; 00:0b9e $c9

call_00_0b9f_VBlank_UpdateVRAM:
; The one VRAM update pass per vblank, banked into
; BANK_03_COLLISION_AND_GRAPHICS_CODE. Two mutually exclusive halves:
;
;   a bg map strip is waiting  MAP_PENDING_VRAM_TRANSFER in
;                              wDC20_BgMapLoadingFlags. Whichever of the four
;                              scroll bits are set decide whether a row
;                              (call_03_75e3_VRAM_WriteBgMapRow) or a column
;                              (call_03_7664_VRAM_WriteBgMapColumn) is
;                              flushed, and the flags are cleared afterwards.
;                              Nothing else runs this frame
;   nothing is waiting         the housekeeping instead: the status bar, the
;                              animated fly coin, and the menu HDMA animations
;
; gex2's call_00_0ac1_VBlank_UpdateVRAM has the same "exactly one big write per
; frame" rule and the same first case, but a longer priority list after it -
; block patches and its two tileset animation systems live there too
    ld   A, BANK_03_COLLISION_AND_GRAPHICS_CODE        ;; 00:0b9f $3e $03
    call call_00_0f25_SetMbcBank                       ;; 00:0ba1 $cd $25 $0f
    ld   HL, wDC20_BgMapLoadingFlags                   ;; 00:0ba4 $21 $20 $dc
    bit  7, [HL]                                       ;; 00:0ba7 $cb $7e
    jr   Z, .jr_00_0bc6                                ;; 00:0ba9 $28 $1b
    res  7, [HL]                                       ;; 00:0bab $cb $be
    ld   A, [wDC20_BgMapLoadingFlags]                  ;; 00:0bad $fa $20 $dc
    and  A, $0f                                        ;; 00:0bb0 $e6 $0f
    jr   Z, .jr_00_0bc6                                ;; 00:0bb2 $28 $12
    and  A, $03                                        ;; 00:0bb4 $e6 $03
    call NZ, call_03_75e3_VRAM_WriteBgMapRow          ;; 00:0bb6 $c4 $e3 $75
    ld   A, [wDC20_BgMapLoadingFlags]                  ;; 00:0bb9 $fa $20 $dc
    and  A, $0c                                        ;; 00:0bbc $e6 $0c
    call NZ, call_03_7664_VRAM_WriteBgMapColumn       ;; 00:0bbe $c4 $64 $76
    xor  A, A                                          ;; 00:0bc1 $af
    ld   [wDC20_BgMapLoadingFlags], A                  ;; 00:0bc2 $ea $20 $dc
    ret                                                ;; 00:0bc5 $c9
.jr_00_0bc6:
    call call_03_747d_HUD_Update                       ;; 00:0bc6 $cd $7d $74
    call call_03_753e_AnimateFlyCoinCollectibles       ;; 00:0bc9 $cd $3e $75
    jp   call_00_088a_Menu_RunHdmaAnimations           ;; 00:0bcc $c3 $8a $08

call_00_0bcf_CopyTileRows:
; Copies B tiles of TILE_SIZE_BYTES bytes each from HL to DE. The inner loop is
; fully unrolled because this is the hot copy in the graphics path.
;
; The unrolled body advances the destination with `inc E` rather than `inc DE`,
; which is why a tile must not straddle a $100 boundary: only the 16th byte uses
; `inc DE` and can carry. Every caller starts tile-aligned, so that holds.
; Byte for byte gex2's call_00_0b6d_CopyTileRows
    ld   A, [HL+]                                      ;; 00:0bcf $2a
    ld   [DE], A                                       ;; 00:0bd0 $12
    inc  E                                             ;; 00:0bd1 $1c
    ld   A, [HL+]                                      ;; 00:0bd2 $2a
    ld   [DE], A                                       ;; 00:0bd3 $12
    inc  E                                             ;; 00:0bd4 $1c
    ld   A, [HL+]                                      ;; 00:0bd5 $2a
    ld   [DE], A                                       ;; 00:0bd6 $12
    inc  E                                             ;; 00:0bd7 $1c
    ld   A, [HL+]                                      ;; 00:0bd8 $2a
    ld   [DE], A                                       ;; 00:0bd9 $12
    inc  E                                             ;; 00:0bda $1c
    ld   A, [HL+]                                      ;; 00:0bdb $2a
    ld   [DE], A                                       ;; 00:0bdc $12
    inc  E                                             ;; 00:0bdd $1c
    ld   A, [HL+]                                      ;; 00:0bde $2a
    ld   [DE], A                                       ;; 00:0bdf $12
    inc  E                                             ;; 00:0be0 $1c
    ld   A, [HL+]                                      ;; 00:0be1 $2a
    ld   [DE], A                                       ;; 00:0be2 $12
    inc  E                                             ;; 00:0be3 $1c
    ld   A, [HL+]                                      ;; 00:0be4 $2a
    ld   [DE], A                                       ;; 00:0be5 $12
    inc  E                                             ;; 00:0be6 $1c
    ld   A, [HL+]                                      ;; 00:0be7 $2a
    ld   [DE], A                                       ;; 00:0be8 $12
    inc  E                                             ;; 00:0be9 $1c
    ld   A, [HL+]                                      ;; 00:0bea $2a
    ld   [DE], A                                       ;; 00:0beb $12
    inc  E                                             ;; 00:0bec $1c
    ld   A, [HL+]                                      ;; 00:0bed $2a
    ld   [DE], A                                       ;; 00:0bee $12
    inc  E                                             ;; 00:0bef $1c
    ld   A, [HL+]                                      ;; 00:0bf0 $2a
    ld   [DE], A                                       ;; 00:0bf1 $12
    inc  E                                             ;; 00:0bf2 $1c
    ld   A, [HL+]                                      ;; 00:0bf3 $2a
    ld   [DE], A                                       ;; 00:0bf4 $12
    inc  E                                             ;; 00:0bf5 $1c
    ld   A, [HL+]                                      ;; 00:0bf6 $2a
    ld   [DE], A                                       ;; 00:0bf7 $12
    inc  E                                             ;; 00:0bf8 $1c
    ld   A, [HL+]                                      ;; 00:0bf9 $2a
    ld   [DE], A                                       ;; 00:0bfa $12
    inc  E                                             ;; 00:0bfb $1c
    ld   A, [HL+]                                      ;; 00:0bfc $2a
    ld   [DE], A                                       ;; 00:0bfd $12
    inc  DE                                            ;; 00:0bfe $13
    dec  B                                             ;; 00:0bff $05
    jr   NZ, call_00_0bcf_CopyTileRows                 ;; 00:0c00 $20 $cd
    ret                                                ;; 00:0c02 $c9
    
call_00_0c03_WaitUntilLcdIsrNone:
; Spins a frame at a time until the LCD STAT handler id is LCD_ISR_NONE, i.e.
; until the STAT interrupt has been switched off. Callers use it to make sure no
; handler is still touching palettes or VRAM before they tear the screen down.
;
; The `cp $00` is redundant - `and` has already set Z - and the masked id is only
; ever compared against zero, so this cannot wait for any other handler. Same
; routine, same redundancy, as gex2's call_00_0ba1_WaitUntilLcdIsrNone
    ld   a,[wD9FD_LcdIsrId]
    and  a,LCD_ISR_ID_MASK
    cp   a,LCD_ISR_NONE
    ret  z
    call call_00_0b92_WaitForInterrupt
    jr   call_00_0c03_WaitUntilLcdIsrNone

call_00_0c10_RequestLcdIsr:
; Requests LCD STAT handler A (one of the LCD_ISR_* ids). If that handler is
; already installed this is a no-op; otherwise the id is stored with
; LCD_ISR_INSTALLED clear, which makes the next vblank call
; call_00_0c1b_InstallLcdIsr. gex2's call_00_0bae_RequestLcdIsr
    ld   HL, wD9FD_LcdIsrId                            ;; 00:0c10 $21 $fd $d9
    or   A, LCD_ISR_INSTALLED                          ;; 00:0c13 $f6 $80
    cp   A, [HL]                                       ;; 00:0c15 $be
    ret  Z                                             ;; 00:0c16 $c8
    and  A, LCD_ISR_ID_MASK                            ;; 00:0c17 $e6 $7f
    ld   [HL], A                                       ;; 00:0c19 $77
    ret                                                ;; 00:0c1a $c9

call_00_0c1b_InstallLcdIsr:
; Copies LCD STAT handler A out of .data_00_0c44_LcdIsrTable into
; wD9A0_LcdIsrCode - which isrLCDC jumps straight into - and stores the address
; just past the copied code into wD9FE_VBlankHookPtrLo, which is the vblank-side
; routine that services that handler. Also programs the entry's rSTAT and rLYC
; values and sets LCD_ISR_INSTALLED in wD9FD_LcdIsrId.
;
; gex2's call_00_0bb9_InstallLcdIsr is the same routine over a three-byte table;
; gex3's entries are five bytes because they carry rSTAT and rLYC as well
    ld   L, A                                          ;; 00:0c1b $6f
    or   A, LCD_ISR_INSTALLED                          ;; 00:0c1c $f6 $80
    ld   [wD9FD_LcdIsrId], A                           ;; 00:0c1e $ea $fd $d9
    ld   H, $00                                        ;; 00:0c21 $26 $00
    ld   DE, .data_00_0c44_LcdIsrTable                 ;; 00:0c23 $11 $44 $0c
    add  HL, DE                                        ;; 00:0c26 $19
    ld   A, [HL+]                                      ;; 00:0c27 $2a
    ldh  [rSTAT], A                                    ;; 00:0c28 $e0 $41
    ld   A, [HL+]                                      ;; 00:0c2a $2a
    ldh  [rLYC], A                                     ;; 00:0c2b $e0 $45
    ld   B, [HL]                                       ;; 00:0c2d $46
    inc  HL                                            ;; 00:0c2e $23
    ld   A, [HL+]                                      ;; 00:0c2f $2a
    ld   H, [HL]                                       ;; 00:0c30 $66
    ld   L, A                                          ;; 00:0c31 $6f
    ld   DE, wD9A0_LcdIsrCode                          ;; 00:0c32 $11 $a0 $d9
.jr_00_0c35:
    ld   A, [HL+]                                      ;; 00:0c35 $2a
    ld   [DE], A                                       ;; 00:0c36 $12
    inc  E                                             ;; 00:0c37 $1c
    dec  B                                             ;; 00:0c38 $05
    jr   NZ, .jr_00_0c35                               ;; 00:0c39 $20 $fa
    ld   A, L                                          ;; 00:0c3b $7d
    ld   [wD9FE_VBlankHookPtrLo], A                    ;; 00:0c3c $ea $fe $d9
    ld   A, H                                          ;; 00:0c3f $7c
    ld   [wD9FF_VBlankHookPtrHi], A                    ;; 00:0c40 $ea $ff $d9
    ret                                                ;; 00:0c43 $c9
.data_00_0c44_LcdIsrTable:
; Five bytes per entry: rSTAT value, rLYC value, template length, template
; pointer. The vblank hook for an entry is whatever follows its template, so
; call_00_0c1b_InstallLcdIsr gets it for free from the end of the copy. Indexed
; by byte offset, which is why the LCD_ISR_* ids run 0, 5, 10
    db   STATF_MODE00, $00, $01
    dw   .data_00_0c53_LcdIsrTemplate_None
    db   STATF_MODE00, $00, $15
    dw   .data_00_0c55_LcdIsrTemplate_HudPalette
    db   STATF_MODE00, $00, $01
    dw   data_00_0df8_LcdIsrTemplate_GfxStream 
.data_00_0c53_LcdIsrTemplate_None:
; LCD_ISR_NONE: one reti, and a bare ret behind it as the vblank hook
    reti
    ret
.data_00_0c55_LcdIsrTemplate_HudPalette:
; LCD_ISR_HUD_PALETTE. Copied to wD9A0_LcdIsrCode and RUN FROM THERE, so as far
; as this bank is concerned the bytes below are data - the addresses in the
; right-hand column are where they are stored, not where they execute. It is
; safe to write as real code because every address in it is absolute and always
; mapped: WRAM and ROM0.
;
; It runs once per hblank and does nothing at all on most lines: it increments
; wDB67_LcdIsr_ScanlineCounter and returns. Only on the two lines where the
; counter reaches LCD_ISR_HUD_PALETTE_LINE_A and _B does it branch into the two
; halves of the palette swap. Splitting the work over two scanlines is not
; cosmetic - eight palette writes do not fit in one hblank.
;
; The counter is seeded from rLY at the end of every vblank, at the tail of
; call_00_0b25_VBlank_Handler, so "the counter reaches $7F" means "scanline
; $7F", which is where the status bar window begins.
;
; gex2's second handler, LCD_ISR_RASTER_EFFECT, occupies the same slot in its
; engine but does a different job: it switches the window on mid-frame and runs
; a horizontal wobble band. gex3's window is on for the whole frame and only its
; colours change
    push af
    push hl
    ld   a,[wDB67_LcdIsr_ScanlineCounter]
    sub  a,LCD_ISR_HUD_PALETTE_LINE_A
    jp   z,call_00_0d8b_LcdIsr_LoadHudPalettesA
    dec  a
    jp   z,call_00_0dc6_LcdIsr_LoadHudPalettesB
    ld   hl,wDB67_LcdIsr_ScanlineCounter
    inc  [hl]
    pop  hl
    pop  af
    reti 

call_00_0c6a_VBlank_StartPendingHdma:
; The vblank hook paired with LCD_ISR_HUD_PALETTE, and the only place in the game
; that programs the HDMA registers. Runs one pending transfer per frame, highest
; priority first, and clears that request bit when the transfer is done.
;
; It also zeroes wDB67_LcdIsr_ScanlineCounter on the way in, so the hud palette
; handler starts each frame from a known point.
;
; The three sources, in the order they are tested:
;
;   GFX_XFER_HDMA_CONFIG  the wDC2B_Hdma_SrcAddrLo job struct. Capped at
;                         HDMA_MAX_BLOCKS blocks per frame, and the struct is
;                         advanced in place - source and destination forward,
;                         length down - so a large transfer resumes next frame.
;                         Only when the length reaches zero is the bit cleared
;   GFX_XFER_PLAYER_GFX   Gex's tiles, always into VRAM bank 0 at $8000
;   GFX_XFER_ENTITY_GFX   one entity's tiles. The destination page comes from
;                         the slot offset itself - three left rotations of
;                         wDB61_EntityGfx_SlotOffset - so each slot owns a page.
;                         ACTION_STATE_UNK20_BIT diverts the whole thing to VRAM
;                         bank 1 at $8400 instead
;
; All three are general purpose DMAs (bit 7 of rHDMA5 clear), so the CPU is
; stopped for the duration - which is why this runs in vblank and why the config
; path caps itself rather than moving everything at once.
;
; There is no equivalent in gex2, which has no HDMA at all: its
; call_00_0c11_VBlank_ArmVramStreamIsr instead patches a source page into an
; hblank handler and lets it dribble four bytes at a time
    xor  A, A                                          ;; 00:0c6a $af
    ld   [wDB67_LcdIsr_ScanlineCounter], A             ;; 00:0c6b $ea $67 $db
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0c6e $21 $66 $db
    bit  GFX_XFER_PENDING, [HL]                        ;; 00:0c71 $cb $7e
    ret  Z                                             ;; 00:0c73 $c8
    bit  GFX_XFER_HDMA_CONFIG, [HL]                    ;; 00:0c74 $cb $56
    jp   NZ, .jp_00_0d14                               ;; 00:0c76 $c2 $14 $0d
    bit  GFX_XFER_PLAYER_GFX, [HL]                     ;; 00:0c79 $cb $46
    jr   NZ, .jr_00_0c84                               ;; 00:0c7b $20 $07
    bit  GFX_XFER_ENTITY_GFX, [HL]                     ;; 00:0c7d $cb $4e
    jr   NZ, .jr_00_0cab                               ;; 00:0c7f $20 $2a
    res  GFX_XFER_PENDING, [HL]                        ;; 00:0c81 $cb $be
    ret                                                ;; 00:0c83 $c9
.jr_00_0c84:
    ld   A, [wDABF_PlayerGfx_SrcBank]                  ;; 00:0c84 $fa $bf $da
    call call_00_0f25_SetMbcBank                       ;; 00:0c87 $cd $25 $0f
    ld   A, [wDAC0_PlayerGfx_SrcAddr+1]                ;; 00:0c8a $fa $c1 $da
    ldh  [rHDMA1], A                                   ;; 00:0c8d $e0 $51
    ld   A, [wDAC0_PlayerGfx_SrcAddr]                  ;; 00:0c8f $fa $c0 $da
    ldh  [rHDMA2], A                                   ;; 00:0c92 $e0 $52
    ld   A, $80                                        ;; 00:0c94 $3e $80
    ldh  [rHDMA3], A                                   ;; 00:0c96 $e0 $53
    xor  A, A                                          ;; 00:0c98 $af
    ldh  [rHDMA4], A                                   ;; 00:0c99 $e0 $54
    ld   A, [wDAC2_PlayerGfx_TileCount]                ;; 00:0c9b $fa $c2 $da
    add  A, A                                          ;; 00:0c9e $87
    sub  A, $01                                        ;; 00:0c9f $d6 $01
    ldh  [rHDMA5], A                                   ;; 00:0ca1 $e0 $55
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0ca3 $21 $66 $db
    res  GFX_XFER_PLAYER_GFX, [HL]                     ;; 00:0ca6 $cb $86
    res  GFX_XFER_PENDING, [HL]                        ;; 00:0ca8 $cb $be
    ret                                                ;; 00:0caa $c9
.jr_00_0cab:
    ld   H, HIGH(wD800_EntityMemory)                   ;; 00:0cab $26 $d8
    ld   A, [wDB61_EntityGfx_SlotOffset]               ;; 00:0cad $fa $61 $db
    or   A, ENTITY_FIELD_SPRITE_BANK                   ;; 00:0cb0 $f6 $17
    ld   L, A                                          ;; 00:0cb2 $6f
    ld   A, [HL]                                       ;; 00:0cb3 $7e
    call call_00_0f25_SetMbcBank                       ;; 00:0cb4 $cd $25 $0f
    ld   H, HIGH(wD800_EntityMemory)                   ;; 00:0cb7 $26 $d8
    ld   A, [wDB61_EntityGfx_SlotOffset]               ;; 00:0cb9 $fa $61 $db
    or   A, ENTITY_FIELD_ACTION_STATE_FLAGS            ;; 00:0cbc $f6 $05
    ld   L, A                                          ;; 00:0cbe $6f
    bit  ACTION_STATE_UNK20_BIT, [HL]                  ;; 00:0cbf $cb $6e
    jr   NZ, .jr_00_0ceb                               ;; 00:0cc1 $20 $28
    ld   A, [wDB64_EntityGfx_SrcAddr+1]                ;; 00:0cc3 $fa $65 $db
    ldh  [rHDMA1], A                                   ;; 00:0cc6 $e0 $51
    ld   A, [wDB64_EntityGfx_SrcAddr]                  ;; 00:0cc8 $fa $64 $db
    ldh  [rHDMA2], A                                   ;; 00:0ccb $e0 $52
    ld   A, [wDB61_EntityGfx_SlotOffset]               ;; 00:0ccd $fa $61 $db
    rlca                                               ;; 00:0cd0 $07
    rlca                                               ;; 00:0cd1 $07
    rlca                                               ;; 00:0cd2 $07
    and  A, $07                                        ;; 00:0cd3 $e6 $07
    add  A, $80                                        ;; 00:0cd5 $c6 $80
    ldh  [rHDMA3], A                                   ;; 00:0cd7 $e0 $53
    xor  A, A                                          ;; 00:0cd9 $af
    ldh  [rHDMA4], A                                   ;; 00:0cda $e0 $54
    ld   A, [wDB63_EntityGfx_PageCount]                ;; 00:0cdc $fa $63 $db
    add  A, A                                          ;; 00:0cdf $87
    dec  A                                             ;; 00:0ce0 $3d
    ldh  [rHDMA5], A                                   ;; 00:0ce1 $e0 $55
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0ce3 $21 $66 $db
    res  GFX_XFER_ENTITY_GFX, [HL]                     ;; 00:0ce6 $cb $8e
    res  GFX_XFER_PENDING, [HL]                        ;; 00:0ce8 $cb $be
    ret                                                ;; 00:0cea $c9
.jr_00_0ceb:
    ld   A, $01                                        ;; 00:0ceb $3e $01
    ldh  [rVBK], A                                     ;; 00:0ced $e0 $4f
    ld   A, [wDB64_EntityGfx_SrcAddr+1]                ;; 00:0cef $fa $65 $db
    ldh  [rHDMA1], A                                   ;; 00:0cf2 $e0 $51
    ld   A, [wDB64_EntityGfx_SrcAddr]                  ;; 00:0cf4 $fa $64 $db
    ldh  [rHDMA2], A                                   ;; 00:0cf7 $e0 $52
    ld   A, $84                                        ;; 00:0cf9 $3e $84
    ldh  [rHDMA3], A                                   ;; 00:0cfb $e0 $53
    ld   A, $00                                        ;; 00:0cfd $3e $00
    ldh  [rHDMA4], A                                   ;; 00:0cff $e0 $54
    ld   A, [wDB63_EntityGfx_PageCount]                ;; 00:0d01 $fa $63 $db
    add  A, A                                          ;; 00:0d04 $87
    dec  A                                             ;; 00:0d05 $3d
    ldh  [rHDMA5], A                                   ;; 00:0d06 $e0 $55
    ld   A, $00                                        ;; 00:0d08 $3e $00
    ldh  [rVBK], A                                     ;; 00:0d0a $e0 $4f
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0d0c $21 $66 $db
    res  GFX_XFER_ENTITY_GFX, [HL]                     ;; 00:0d0f $cb $8e
    res  GFX_XFER_PENDING, [HL]                        ;; 00:0d11 $cb $be
    ret                                                ;; 00:0d13 $c9
.jp_00_0d14:
    ld   A, [wDC31_Hdma_SrcBank]                       ;; 00:0d14 $fa $31 $dc
    call call_00_0f25_SetMbcBank                       ;; 00:0d17 $cd $25 $0f
    ld   A, [wDC32_Hdma_VramBank]                      ;; 00:0d1a $fa $32 $dc
    ldh  [rVBK], A                                     ;; 00:0d1d $e0 $4f
    ld   A, [wDC2C_Hdma_SrcAddrHi]                     ;; 00:0d1f $fa $2c $dc
    ldh  [rHDMA1], A                                   ;; 00:0d22 $e0 $51
    ld   A, [wDC2B_Hdma_SrcAddrLo]                     ;; 00:0d24 $fa $2b $dc
    ldh  [rHDMA2], A                                   ;; 00:0d27 $e0 $52
    ld   A, [wDC2E_Hdma_DestAddrHi]                    ;; 00:0d29 $fa $2e $dc
    ldh  [rHDMA3], A                                   ;; 00:0d2c $e0 $53
    ld   A, [wDC2D_Hdma_DestAddrLo]                    ;; 00:0d2e $fa $2d $dc
    ldh  [rHDMA4], A                                   ;; 00:0d31 $e0 $54
    ld   HL, wDC2F_Hdma_BytesRemaining                 ;; 00:0d33 $21 $2f $dc
    ld   A, [HL+]                                      ;; 00:0d36 $2a
    ld   E, A                                          ;; 00:0d37 $5f
    ld   D, [HL]                                       ;; 00:0d38 $56
    srl  D                                             ;; 00:0d39 $cb $3a
    rr   E                                             ;; 00:0d3b $cb $1b
    srl  D                                             ;; 00:0d3d $cb $3a
    rr   E                                             ;; 00:0d3f $cb $1b
    srl  D                                             ;; 00:0d41 $cb $3a
    rr   E                                             ;; 00:0d43 $cb $1b
    srl  D                                             ;; 00:0d45 $cb $3a
    rr   E                                             ;; 00:0d47 $cb $1b
    inc  D                                             ;; 00:0d49 $14
    dec  D                                             ;; 00:0d4a $15
    jr   NZ, .jr_00_0d52                               ;; 00:0d4b $20 $05
    ld   A, E                                          ;; 00:0d4d $7b
    cp   A, HDMA_MAX_BLOCKS                            ;; 00:0d4e $fe $40
    jr   C, .jr_00_0d54                                ;; 00:0d50 $38 $02
.jr_00_0d52:
    ld   E, HDMA_MAX_BLOCKS                            ;; 00:0d52 $1e $40
.jr_00_0d54:
    ld   A, E                                          ;; 00:0d54 $7b
    dec  A                                             ;; 00:0d55 $3d
    ldh  [rHDMA5], A                                   ;; 00:0d56 $e0 $55
    ld   A, $00                                        ;; 00:0d58 $3e $00
    ldh  [rVBK], A                                     ;; 00:0d5a $e0 $4f
    ld   L, E                                          ;; 00:0d5c $6b
    ld   H, $00                                        ;; 00:0d5d $26 $00
    add  HL, HL                                        ;; 00:0d5f $29
    add  HL, HL                                        ;; 00:0d60 $29
    add  HL, HL                                        ;; 00:0d61 $29
    add  HL, HL                                        ;; 00:0d62 $29
    ld   E, L                                          ;; 00:0d63 $5d
    ld   D, H                                          ;; 00:0d64 $54
    ld   HL, wDC2B_Hdma_SrcAddrLo                      ;; 00:0d65 $21 $2b $dc
    ld   A, [HL]                                       ;; 00:0d68 $7e
    add  A, E                                          ;; 00:0d69 $83
    ld   [HL+], A                                      ;; 00:0d6a $22
    ld   A, [HL]                                       ;; 00:0d6b $7e
    adc  A, D                                          ;; 00:0d6c $8a
    ld   [HL], A                                       ;; 00:0d6d $77
    ld   HL, wDC2D_Hdma_DestAddrLo                     ;; 00:0d6e $21 $2d $dc
    ld   A, [HL]                                       ;; 00:0d71 $7e
    add  A, E                                          ;; 00:0d72 $83
    ld   [HL+], A                                      ;; 00:0d73 $22
    ld   A, [HL]                                       ;; 00:0d74 $7e
    adc  A, D                                          ;; 00:0d75 $8a
    ld   [HL], A                                       ;; 00:0d76 $77
    ld   HL, wDC2F_Hdma_BytesRemaining                 ;; 00:0d77 $21 $2f $dc
    ld   A, [HL]                                       ;; 00:0d7a $7e
    sub  A, E                                          ;; 00:0d7b $93
    ld   [HL+], A                                      ;; 00:0d7c $22
    ld   C, A                                          ;; 00:0d7d $4f
    ld   A, [HL]                                       ;; 00:0d7e $7e
    sbc  A, D                                          ;; 00:0d7f $9a
    ld   [HL], A                                       ;; 00:0d80 $77
    or   A, C                                          ;; 00:0d81 $b1
    ret  NZ                                            ;; 00:0d82 $c0
    ld   HL, wDB66_GfxTransferFlags                    ;; 00:0d83 $21 $66 $db
    res  GFX_XFER_HDMA_CONFIG, [HL]                    ;; 00:0d86 $cb $96
    res  GFX_XFER_PENDING, [HL]                        ;; 00:0d88 $cb $be
    ret                                                ;; 00:0d8a $c9

call_00_0d8b_LcdIsr_LoadHudPalettesA:
; First half of the hud palette swap, entered from the LCD_ISR_HUD_PALETTE
; template at scanline LCD_ISR_HUD_PALETTE_LINE_A and returning with `reti`.
;
; Writes colours 0 and 1 of BG palettes 0 and 1 from .data_00_0dbe_HudPalettesA,
; then rewrites rLCDC: the status bar is drawn out of the $8000 tile block
; (LCDC_HUD_SET_MASK) and has no sprites over it (LCDC_HUD_CLEAR_MASK). The
; register is written directly rather than through wDAD8_LCDCValue, so the next
; vblank puts the gameplay value back without this having to undo anything.
;
; The `pop hl / pop af` before the reti balance the pushes the template did
    ld   hl,.data_00_0dbe_HudPalettesA
    ld   a,BCPS_HUD_PAL0_COLORS_01
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   a,BCPS_HUD_PAL1_COLORS_01
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   a,[wDAD8_LCDCValue]
    and  a,LCDC_HUD_CLEAR_MASK
    or   a,LCDC_HUD_SET_MASK
    ldh  [rLCDC],a
    ld   hl,wDB67_LcdIsr_ScanlineCounter
    inc  [hl]
    pop  hl
    pop  af
    reti 
.data_00_0dbe_HudPalettesA
    db   $00, $00, $e0, $01, $00, $00, $e0, $01
    
call_00_0dc6_LcdIsr_LoadHudPalettesB:
; Second half, one scanline later: colours 2 and 3 of the same two palettes, from
; .data_00_0df0_HudPalettesB. No LCDC change this time - the first half already
; made it
    ld   hl,.data_00_0df0_HudPalettesB
    ld   a,BCPS_HUD_PAL0_COLORS_23
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   a,BCPS_HUD_PAL1_COLORS_23
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   hl,wDB67_LcdIsr_ScanlineCounter
    inc  [hl]
    pop  hl
    pop  af
    reti 
.data_00_0df0_HudPalettesB:
    db   $ff, $7f, $80, $03, $ff, $03, $ff, $7f        ;; 00:0df3 ?????.

data_00_0df8_LcdIsrTemplate_GfxStream:
; LCD_ISR_MENU_GFX_STREAM. The handler itself does nothing - menus want no
; per-scanline effect - so the template is a single reti and the point of the
; entry is the vblank hook that follows it
   reti

call_00_0df9_VBlank_RunGfxStream:
; VBlank hook paired with LCD_ISR_MENU_GFX_STREAM. Starts the frame's HDMA like
; every other hook, then copies one chunk of a graphics stream script:
; decrements wDBEF_GfxStream_ChunksRemaining, banks in
; wDBF1_GfxStream_SrcBank, reads the next (source, destination) pair from the
; cursor at wDBF6_GfxStream_ListPtrLo, advances that cursor by four bytes and
; copies wDBF0_GfxStream_RowsPerChunk tiles.
;
; Spreading the copy over frames is what lets a menu redraw itself with the
; screen still on. gex2's call_00_0d84_VBlank_RunGfxStream is the same routine
; over the same layout
    call call_00_0c6a_VBlank_StartPendingHdma          ;; 00:0df9 $cd $6a $0c
    jp   .jp_00_0dff                                   ;; 00:0dfc $c3 $ff $0d
.jp_00_0dff:
    ld   HL, wDBEF_GfxStream_ChunksRemaining           ;; 00:0dff $21 $ef $db
    ld   A, [HL]                                       ;; 00:0e02 $7e
    and  A, A                                          ;; 00:0e03 $a7
    ret  Z                                             ;; 00:0e04 $c8
    dec  [HL]                                          ;; 00:0e05 $35
    inc  HL                                            ;; 00:0e06 $23
    ld   B, [HL]                                       ;; 00:0e07 $46
    inc  HL                                            ;; 00:0e08 $23
    ld   A, [HL]                                       ;; 00:0e09 $7e
    call call_00_0f25_SetMbcBank                       ;; 00:0e0a $cd $25 $0f
    ld   HL, wDBF6_GfxStream_ListPtrLo                 ;; 00:0e0d $21 $f6 $db
    ld   A, [HL+]                                      ;; 00:0e10 $2a
    ld   H, [HL]                                       ;; 00:0e11 $66
    ld   L, A                                          ;; 00:0e12 $6f
    ld   E, [HL]                                       ;; 00:0e13 $5e
    inc  HL                                            ;; 00:0e14 $23
    ld   D, [HL]                                       ;; 00:0e15 $56
    inc  HL                                            ;; 00:0e16 $23
    push DE                                            ;; 00:0e17 $d5
    ld   E, [HL]                                       ;; 00:0e18 $5e
    inc  HL                                            ;; 00:0e19 $23
    ld   D, [HL]                                       ;; 00:0e1a $56
    inc  HL                                            ;; 00:0e1b $23
    ld   A, L                                          ;; 00:0e1c $7d
    ld   [wDBF6_GfxStream_ListPtrLo], A                ;; 00:0e1d $ea $f6 $db
    ld   A, H                                          ;; 00:0e20 $7c
    ld   [wDBF7_GfxStream_ListPtrHi], A                ;; 00:0e21 $ea $f7 $db
    pop  HL                                            ;; 00:0e24 $e1
    jp   call_00_0bcf_CopyTileRows                     ;; 00:0e25 $c3 $cf $0b

call_00_0e28_Return:
; A bare ret, used as a do-nothing callback
    ret

call_00_0e29_OamDmaRoutine:
; Copied to hFF80_OamDmaRoutine at boot and called from vblank. Kicks off an OAM
; DMA from wD900_ShadowOAM and busy-waits the required cycles. It has to run out
; of HRAM because the CPU can reach nothing else while the transfer is in
; progress. gex2's call_00_0ef7_OamDmaRoutine, with the same
; OAM_DMA_WAIT_LOOPS wait
    ld   a,HIGH(wD900_ShadowOAM)
    ldh  [rDMA], a
    ld   a,OAM_DMA_WAIT_LOOPS
.jr_00_0E2F:
    dec  a
    jr   nz,.jr_00_0E2F
    ret                                                ;; 00:0e30 ...

call_00_0e33_SetLCDCAndWait:
; Writes A to both the shadow copy (wDAD8_LCDCValue) and the real rLCDC, then
; blocks for a frame so the change has taken effect by the time it returns.
; gex2's call_00_0f32_SetLCDC does the first half only; its callers do the
; waiting, usually as part of a fade
    ld   [wDAD8_LCDCValue], A                          ;; 00:0e33 $ea $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0e36 $e0 $40
    jp   call_00_0b92_WaitForInterrupt                 ;; 00:0e38 $c3 $92 $0b

call_00_0e3b_ResetVideoState:
; Tears down everything that could still write to VRAM or the status bar, clears
; the entity table, and waits a frame for it all to settle.
;
; That is: the damage cooldown, the bg map's pending strip, the graphics transfer
; queue, the hud dirty flags, the menu gfx stream, the shared animation counter
; and the menu animation flag. Called on every screen change, from both this bank
; and the menu code.
;
; gex2's call_00_0f01_ResetVideoState clears the same categories and also selects
; LCD_ISR_NONE and turns the LCD off; gex3 leaves both of those to its callers
    xor  A, A                                          ;; 00:0e3b $af
    ld   [wDC7E_Player_DamageCooldownTimer], A         ;; 00:0e3c $ea $7e $dc
    ld   [wDC20_BgMapLoadingFlags], A                  ;; 00:0e3f $ea $20 $dc
    ld   [wDB66_GfxTransferFlags], A                   ;; 00:0e42 $ea $66 $db
    ld   [wDB69_HUDDirtyFlags], A                      ;; 00:0e45 $ea $69 $db
    ld   [wDBEF_GfxStream_ChunksRemaining], A          ;; 00:0e48 $ea $ef $db
    ld   [wDC72_AnimFrameCounter], A                   ;; 00:0e4b $ea $72 $dc
    ld   [wDBE3_Menu_AnimateFlag], A                   ;; 00:0e4e $ea $e3 $db
    ld   [wDD6B], A                                    ;; 00:0e51 $ea $6b $dd
    farcall call_02_7123_Entities_InitNPCSlots
    jp   call_00_0b92_WaitForInterrupt                 ;; 00:0e5f $c3 $92 $0b

call_00_0e62_ClearShadowOamAndResetScroll:
; Hides the screen and empties the sprite list. Clearing
; wDD6A_PalettesReadyFlag is what actually hides it - from the next vblank
; call_00_0e81_UploadCgbPalettes pushes grey instead of the real colours - and
; the frame of waiting either side of the wipe is there so that the palette
; change lands before shadow OAM is disturbed and after it has settled.
;
; The wipe itself is the same seed-and-copy trick Init uses on WRAM: one byte is
; written and then copied forward over itself, SHADOW_OAM_SIZE - 1 times.
;
; gex2's call_00_0e87_ClearVRAMAndResetScroll goes further and clears VRAM too,
; because on a DMG it cannot hide anything by touching palette ram
    xor  A, A                                          ;; 00:0e62 $af
    ld   [wDD6A_PalettesReadyFlag], A                  ;; 00:0e63 $ea $6a $dd
    call call_00_0b92_WaitForInterrupt                 ;; 00:0e66 $cd $92 $0b
    xor  A, A                                          ;; 00:0e69 $af
    ld   [wDAD9_BgMap_ScrollXLo], A                    ;; 00:0e6a $ea $d9 $da
    ld   [wDADA_BgMap_ScrollYLo], A                    ;; 00:0e6d $ea $da $da
    ld   HL, wD900_ShadowOAM                           ;; 00:0e70 $21 $00 $d9
    ld   DE, wD901_ShadowOAM_EntitySprites             ;; 00:0e73 $11 $01 $d9
    ld   BC, SHADOW_OAM_SIZE - 1                       ;; 00:0e76 $01 $9f $00
    ld   [HL], $00                                     ;; 00:0e79 $36 $00
    call call_00_076e_MemCopy                          ;; 00:0e7b $cd $6e $07
    jp   call_00_0b92_WaitForInterrupt                 ;; 00:0e7e $c3 $92 $0b

call_00_0e81_UploadCgbPalettes:
; Pushes both CGB palette rams to hardware, once per vblank.
;
; While wDD6A_PalettesReadyFlag is clear it writes $80 to every entry of both
; instead - a mid-grey - which is how the game hides a screen that is still being
; built. Otherwise it copies CGB_PALETTE_RAM_SIZE bytes of background palette
; from wDCEA_BgPalettes through rBCPS/rBCPD and the same again of sprite palette
; through rOCPS/rOCPD, both unrolled eight bytes at a time.
;
; gex2's call_00_0f9d_UploadCgbPalettes is the same upload; the grey path is
; gex3's own, standing in for the DMG fade gex2 uses to cover the same moments
    ld   A, [wDD6A_PalettesReadyFlag]                  ;; 00:0e81 $fa $6a $dd
    and  A, A                                          ;; 00:0e84 $a7
    jr   NZ, .jr_00_0e97                               ;; 00:0e85 $20 $10
    ld   A, BCPSF_AUTOINC                              ;; 00:0e87 $3e $80
    ldh  [rBCPS], A                                    ;; 00:0e89 $e0 $68
    ldh  [rOCPS], A                                    ;; 00:0e8b $e0 $6a
    ld   B, CGB_PALETTE_RAM_SIZE                       ;; 00:0e8d $06 $40
.jr_00_0e8f:
    ldh  [rBCPD], A                                    ;; 00:0e8f $e0 $69
    ldh  [rOCPD], A                                    ;; 00:0e91 $e0 $6b
    dec  B                                             ;; 00:0e93 $05
    jr   NZ, .jr_00_0e8f                               ;; 00:0e94 $20 $f9
    ret                                                ;; 00:0e96 $c9
.jr_00_0e97:
    ld   HL, wDCEA_BgPalettes                          ;; 00:0e97 $21 $ea $dc
    ld   A, BCPSF_AUTOINC                              ;; 00:0e9a $3e $80
    ldh  [rBCPS], A                                    ;; 00:0e9c $e0 $68
    ld   B, $08                                        ;; 00:0e9e $06 $08
.jr_00_0ea0:
    ld   A, [HL+]                                      ;; 00:0ea0 $2a
    ldh  [rBCPD], A                                    ;; 00:0ea1 $e0 $69
    ld   A, [HL+]                                      ;; 00:0ea3 $2a
    ldh  [rBCPD], A                                    ;; 00:0ea4 $e0 $69
    ld   A, [HL+]                                      ;; 00:0ea6 $2a
    ldh  [rBCPD], A                                    ;; 00:0ea7 $e0 $69
    ld   A, [HL+]                                      ;; 00:0ea9 $2a
    ldh  [rBCPD], A                                    ;; 00:0eaa $e0 $69
    ld   A, [HL+]                                      ;; 00:0eac $2a
    ldh  [rBCPD], A                                    ;; 00:0ead $e0 $69
    ld   A, [HL+]                                      ;; 00:0eaf $2a
    ldh  [rBCPD], A                                    ;; 00:0eb0 $e0 $69
    ld   A, [HL+]                                      ;; 00:0eb2 $2a
    ldh  [rBCPD], A                                    ;; 00:0eb3 $e0 $69
    ld   A, [HL+]                                      ;; 00:0eb5 $2a
    ldh  [rBCPD], A                                    ;; 00:0eb6 $e0 $69
    dec  B                                             ;; 00:0eb8 $05
    jr   NZ, .jr_00_0ea0                               ;; 00:0eb9 $20 $e5
    ld   A, OCPSF_AUTOINC                              ;; 00:0ebb $3e $80
    ldh  [rOCPS], A                                    ;; 00:0ebd $e0 $6a
    ld   B, $08                                        ;; 00:0ebf $06 $08
.jr_00_0ec1:
    ld   A, [HL+]                                      ;; 00:0ec1 $2a
    ldh  [rOCPD], A                                    ;; 00:0ec2 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ec4 $2a
    ldh  [rOCPD], A                                    ;; 00:0ec5 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ec7 $2a
    ldh  [rOCPD], A                                    ;; 00:0ec8 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0eca $2a
    ldh  [rOCPD], A                                    ;; 00:0ecb $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ecd $2a
    ldh  [rOCPD], A                                    ;; 00:0ece $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ed0 $2a
    ldh  [rOCPD], A                                    ;; 00:0ed1 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ed3 $2a
    ldh  [rOCPD], A                                    ;; 00:0ed4 $e0 $6b
    ld   A, [HL+]                                      ;; 00:0ed6 $2a
    ldh  [rOCPD], A                                    ;; 00:0ed7 $e0 $6b
    dec  B                                             ;; 00:0ed9 $05
    jr   NZ, .jr_00_0ec1                               ;; 00:0eda $20 $e5
    ret                                                ;; 00:0edc $c9

call_00_0edd_FarCall:
; Calls HL in bank A and comes back to the caller's bank. The farcall macro is
; what sets up A and HL; this is its body.
;
; Note it loads wDAD6_ReturnBank into A immediately before jumping, so the callee
; is entered with A holding the bank to return to rather than anything the caller
; chose - worth knowing before assuming A is a free argument register across a
; farcall. The callee's return value in A does survive, since it is pushed around
; RestoreBank. Identical to gex2's call_00_1078_FarCall
    push HL                                            ;; 00:0edd $e5
    call call_00_0eee_SwitchBank                       ;; 00:0ede $cd $ee $0e
    pop  HL                                            ;; 00:0ee1 $e1
    ld   A, [wDAD6_ReturnBank]                         ;; 00:0ee2 $fa $d6 $da
    call call_00_0f22_JumpHL                           ;; 00:0ee5 $cd $22 $0f
    push AF                                            ;; 00:0ee8 $f5
    call call_00_0f08_RestoreBank                      ;; 00:0ee9 $cd $08 $0f
    pop  AF                                            ;; 00:0eec $f1
    ret                                                ;; 00:0eed $c9

call_00_0eee_SwitchBank:
; Switches to ROM bank A and PUSHES it onto the bank stack that
; wDAD3_PtrToBankStackPosition walks, so nesting works: every SwitchBank must be
; matched by a call_00_0f08_RestoreBank or the stack pointer drifts.
;
; Interrupt-time code cannot use this pair - an interrupt landing between the
; stack update and the register write would corrupt it - which is why
; call_00_0b25_VBlank_Handler uses call_00_0f25_SetMbcBank instead.
; gex2's call_00_1089_SwitchBank
    ld   HL, wDAD3_PtrToBankStackPosition              ;; 00:0eee $21 $d3 $da
    ld   E, [HL]                                       ;; 00:0ef1 $5e
    inc  HL                                            ;; 00:0ef2 $23
    ld   D, [HL]                                       ;; 00:0ef3 $56
    inc  DE                                            ;; 00:0ef4 $13
    ld   [DE], A                                       ;; 00:0ef5 $12
    ld   [HL], D                                       ;; 00:0ef6 $72
    dec  HL                                            ;; 00:0ef7 $2b
    ld   [HL], E                                       ;; 00:0ef8 $73
    ld   [wDAD5_CurrentROMBank], A                     ;; 00:0ef9 $ea $d5 $da
    ld   [MBC1RomBank], A                              ;; 00:0efc $ea $01 $20
    swap A                                             ;; 00:0eff $cb $37
    rrca                                               ;; 00:0f01 $0f
    and  A, $00                                        ;; 00:0f02 $e6 $00
    ld   [MBC1SRamBank], A                             ;; 00:0f04 $ea $01 $40
    ret                                                ;; 00:0f07 $c9

call_00_0f08_RestoreBank:
; POPS the bank stack and switches back to whatever was underneath, mirroring
; call_00_0eee_SwitchBank exactly - `dec DE` here against its `inc DE`. Clobbers
; A with the restored bank number. gex2's call_00_10a3_RestoreBank
    ld   HL, wDAD3_PtrToBankStackPosition              ;; 00:0f08 $21 $d3 $da
    ld   E, [HL]                                       ;; 00:0f0b $5e
    inc  HL                                            ;; 00:0f0c $23
    ld   D, [HL]                                       ;; 00:0f0d $56
    dec  DE                                            ;; 00:0f0e $1b
    ld   A, [DE]                                       ;; 00:0f0f $1a
    ld   [HL], D                                       ;; 00:0f10 $72
    dec  HL                                            ;; 00:0f11 $2b
    ld   [HL], E                                       ;; 00:0f12 $73
    ld   [wDAD5_CurrentROMBank], A                     ;; 00:0f13 $ea $d5 $da
    ld   [MBC1RomBank], A                              ;; 00:0f16 $ea $01 $20
    swap A                                             ;; 00:0f19 $cb $37
    rrca                                               ;; 00:0f1b $0f
    and  A, $00                                        ;; 00:0f1c $e6 $00
    ld   [MBC1SRamBank], A                             ;; 00:0f1e $ea $01 $40
    ret                                                ;; 00:0f21 $c9

call_00_0f22_JumpHL:
; `call call_00_0f22_JumpHL` is how this codebase does an indirect CALL - the
; `jp hl` here leaves the return address of the CALL on the stack, so the routine
; at HL returns to the caller. gex2's call_00_10bd_JumpHL
    jp   HL                                            ;; 00:0f22 $e9

    ld   a, $03                                        ;; 00:0f23 ??
call_00_0f25_SetMbcBank:
; Writes bank A to the MBC without touching the bank stack, and moves the SRAM
; bank register with it - the cartridge is driven as an MBC1 in the upper-bits
; mode, so the two have to stay in step even though there is no SRAM
; (CART_SRAM_NONE).
;
; This is the form interrupt-time code has to use. gex2 has the same thing as the
; SET_MBC_BANK macro, expanded inline at each site rather than being a routine.
;
; The `ld a, $03` immediately above the entry point is unreachable - it is the
; tail of the previous routine's `jp hl` and nothing branches to it
    ld   [MBC1RomBank], A                              ;; 00:0f25 $ea $01 $20
    swap A                                             ;; 00:0f28 $cb $37
    rrca                                               ;; 00:0f2a $0f
    and  A, $00                                        ;; 00:0f2b $e6 $00
    ld   [MBC1SRamBank], A                             ;; 00:0f2d $ea $01 $40
    ret                                                ;; 00:0f30 $c9

call_00_0f31_ReadJoypadInput:
; Reads both halves of the pad and leaves the buttons in wDAD7_RawInputs, active
; high, in PADF_* order: d-pad in the high nibble, buttons in the low one.
;
; The repeated `ldh a, [C]` reads are the standard settle delay after switching
; the selector line - the pad matrix is slow to respond. The button half gets
; fourteen reads against the d-pad's three, because it is switched to while the
; previous result is still being shifted about and needs longer.
;
; C is the low byte of rP1 throughout, which is what lets `ldh [C], a` address
; it. Instruction for instruction gex2's call_00_10be_ReadJoypadInput
    ld   C, LOW(rP1)                                   ;; 00:0f31 $0e $00
    ld   A, P1F_GET_DPAD                               ;; 00:0f33 $3e $20
    ldh  [C], A                                        ;; 00:0f35 $e2
    ldh  A, [C]                                        ;; 00:0f36 $f2
    ldh  A, [C]                                        ;; 00:0f37 $f2
    ldh  A, [C]                                        ;; 00:0f38 $f2
    ld   B, A                                          ;; 00:0f39 $47
    ld   A, P1F_GET_BTN                                ;; 00:0f3a $3e $10
    ldh  [C], A                                        ;; 00:0f3c $e2
    ld   A, B                                          ;; 00:0f3d $78
    and  A, $0f                                        ;; 00:0f3e $e6 $0f
    swap A                                             ;; 00:0f40 $cb $37
    ld   B, A                                          ;; 00:0f42 $47
    ldh  A, [C]                                        ;; 00:0f43 $f2
    ldh  A, [C]                                        ;; 00:0f44 $f2
    ldh  A, [C]                                        ;; 00:0f45 $f2
    ldh  A, [C]                                        ;; 00:0f46 $f2
    ldh  A, [C]                                        ;; 00:0f47 $f2
    ldh  A, [C]                                        ;; 00:0f48 $f2
    ldh  A, [C]                                        ;; 00:0f49 $f2
    ldh  A, [C]                                        ;; 00:0f4a $f2
    ldh  A, [C]                                        ;; 00:0f4b $f2
    ldh  A, [C]                                        ;; 00:0f4c $f2
    ldh  A, [C]                                        ;; 00:0f4d $f2
    ldh  A, [C]                                        ;; 00:0f4e $f2
    ldh  A, [C]                                        ;; 00:0f4f $f2
    ldh  A, [C]                                        ;; 00:0f50 $f2
    and  A, $0f                                        ;; 00:0f51 $e6 $0f
    or   A, B                                          ;; 00:0f53 $b0
    cpl                                                ;; 00:0f54 $2f
    ld   B, A                                          ;; 00:0f55 $47
    ld   A, P1F_GET_NONE                               ;; 00:0f56 $3e $30
    ldh  [C], A                                        ;; 00:0f58 $e2
    ld   A, B                                          ;; 00:0f59 $78
    ld   [wDAD7_RawInputs], A                          ;; 00:0f5a $ea $d7 $da
    ret                                                ;; 00:0f5d $c9

call_00_0f5e_WaitUntilNoInputPressed:
; Blocks, a frame at a time, until nothing is held. Used before a screen that
; reacts to a button, so a press left over from the previous screen does not
; carry into it. gex2's call_00_10eb_WaitUntilNoInputPressed
    call call_00_0b92_WaitForInterrupt                 ;; 00:0f5e $cd $92 $0b
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f61 $fa $d7 $da
    and  A, A                                          ;; 00:0f64 $a7
    jr   NZ, call_00_0f5e_WaitUntilNoInputPressed      ;; 00:0f65 $20 $f7
    ret                                                ;; 00:0f67 $c9

call_00_0f68_CheckInputLeft:
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f68 $fa $d7 $da
    and  A, PADF_LEFT                                  ;; 00:0f6b $e6 $20
    ret                                                ;; 00:0f6d $c9

call_00_0f6e_CheckInputRight:
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f6e $fa $d7 $da
    and  A, PADF_RIGHT                                 ;; 00:0f71 $e6 $10
    ret                                                ;; 00:0f73 $c9

call_00_0f74_CheckInputUp:
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f74 $fa $d7 $da
    and  A, PADF_UP                                    ;; 00:0f77 $e6 $40
    ret                                                ;; 00:0f79 $c9

call_00_0f7a_CheckInputDown:
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f7a $fa $d7 $da
    and  A, PADF_DOWN                                  ;; 00:0f7d $e6 $80
    ret                                                ;; 00:0f7f $c9

call_00_0f80_CheckInputStart:
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f80 $fa $d7 $da
    cp   A, PADF_START                                 ;; 00:0f83 $fe $08
    jr   Z, .jr_00_0f89                                ;; 00:0f85 $28 $02
    xor  A, A                                          ;; 00:0f87 $af
    ret                                                ;; 00:0f88 $c9
.jr_00_0f89:
    and  A, A                                          ;; 00:0f89 $a7
    ret                                                ;; 00:0f8a $c9

call_00_0f8b_CheckInputSelect:
; Purpose: Tests if the current input state (wDAD7_RawInputs) equals $04. 
; If so, returns A unchanged; otherwise clears A.
; Usage: Likely a quick check for a specific button press (e.g., "Right" or a single button).
; Behavior:
; A == $04 → returns immediately.
; Otherwise sets A=0 and returns.
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f8b $fa $d7 $da
    cp   A, PADF_SELECT                                ;; 00:0f8e $fe $04
    jr   Z, .jr_00_0f94                                ;; 00:0f90 $28 $02
    xor  A, A                                          ;; 00:0f92 $af
    ret                                                ;; 00:0f93 $c9
.jr_00_0f94:
    and  A, A                                          ;; 00:0f94 $a7
    ret                                                ;; 00:0f95 $c9

call_00_0f96_CheckInputA:
    ld   a, [wDAD7_RawInputs]
    and  a, PADF_A
    ret  

call_00_0f9c_CheckInputB:
    ld   A, [wDAD7_RawInputs]                          ;; 00:0f9c $fa $d7 $da
    and  A, PADF_B                                     ;; 00:0f9f $e6 $02
    ret                                                ;; 00:0fa1 $c9

call_00_0fa2_SetupMusic:
; Starts song A, or returns immediately if it is already the one playing
; (wDE5C_CurrentSong) or if A is SONG_NONE. Syncs to vblank first so the swap
; does not land mid-frame.
;
; A song id packs two things: the high nibble selects the audio bank, as an
; offset from BANK_04_AUDIO_CODE_1, and the low nibble is the track within it.
; The bank is remembered in wDE60_AudioBankCurrent and stays there until the next
; song change, which is how sound effects find a bank of their own -
; call_00_0b25_VBlank_Handler banks the same one in for the driver's per-frame
; tick.
;
; gex2's call_00_120c_SetupMusic does the same job through a table of records
; instead, and starts four driver tracks per song because its driver is one track
; per hardware channel
    cp   A, SONG_NONE                                  ;; 00:0fa2 $fe $ff
    ret  Z                                             ;; 00:0fa4 $c8
    ld   HL, wDE5C_CurrentSong                         ;; 00:0fa5 $21 $5c $de
    cp   A, [HL]                                       ;; 00:0fa8 $be
    ret  Z                                             ;; 00:0fa9 $c8
    ld   [HL], A                                       ;; 00:0faa $77
    call call_00_0b92_WaitForInterrupt                 ;; 00:0fab $cd $92 $0b
    ld   A, [wDE5C_CurrentSong]                        ;; 00:0fae $fa $5c $de
    swap A                                             ;; 00:0fb1 $cb $37
    and  A, $0f                                        ;; 00:0fb3 $e6 $0f
    ld   [wDE60_AudioBankCurrent], A                   ;; 00:0fb5 $ea $60 $de
    add  A, BANK_04_AUDIO_CODE_1                       ;; 00:0fb8 $c6 $04
    call call_00_0eee_SwitchBank                       ;; 00:0fba $cd $ee $0e
    ld   A, [wDE5C_CurrentSong]                        ;; 00:0fbd $fa $5c $de
    and  A, $0f                                        ;; 00:0fc0 $e6 $0f
    call call_04_4006_Audio                            ;; 00:0fc2 $cd $06 $40
    jp   call_00_0f08_RestoreBank                      ;; 00:0fc5 $c3 $08 $0f

call_00_0fc8_PlayQueuedSFX:
; Plays whatever call_00_0ff5_QueueSFX left pending and empties the slot. If
; nothing was queued it also clears wDE5E_QueuedSoundEffectPriority, so a
; priority can never outlive the effect it belonged to. Called once per frame
; from the outer game loop. gex2's call_00_1138_PlayQueuedSFX
    ld   HL, wDE5D_QueuedSoundEffect                   ;; 00:0fc8 $21 $5d $de
    ld   A, [HL]                                       ;; 00:0fcb $7e
    ld   [HL], SFX_NONE                                ;; 00:0fcc $36 $ff
    cp   A, SFX_NONE                                   ;; 00:0fce $fe $ff
    jr   NZ, call_00_0fd7_PlaySFX                      ;; 00:0fd0 $20 $05
    xor  A, A                                          ;; 00:0fd2 $af
    ld   [wDE5E_QueuedSoundEffectPriority], A          ;; 00:0fd3 $ea $5e $de
    ret                                                ;; 00:0fd6 $c9

call_00_0fd7_PlaySFX:
; Plays SFX_* id A immediately, out of BANK_04_AUDIO_CODE_1.
;
; The driver is called twice: once with $00, which stops whatever was playing,
; and then with the effect id. The queued priority is moved into
; wDE5F_CurrentSoundEffectPriority and the queued one cleared, so from here on
; the effect that is actually sounding is the one new requests are weighed
; against.
;
; gex2's call_00_113e_PlaySFX translates through a table into one or more driver
; tracks; gex3's ids are the driver's own
    cp   A, SFX_NONE                                   ;; 00:0fd7 $fe $ff
    ret  Z                                             ;; 00:0fd9 $c8
    push AF                                            ;; 00:0fda $f5
    ld   A, BANK_04_AUDIO_CODE_1                       ;; 00:0fdb $3e $04
    call call_00_0eee_SwitchBank                       ;; 00:0fdd $cd $ee $0e
    ld   A, $00                                        ;; 00:0fe0 $3e $00
    call call_04_4024_Audio                            ;; 00:0fe2 $cd $24 $40
    pop  AF                                            ;; 00:0fe5 $f1
    call call_04_4024_Audio                            ;; 00:0fe6 $cd $24 $40
    ld   HL, wDE5E_QueuedSoundEffectPriority           ;; 00:0fe9 $21 $5e $de
    ld   A, [HL]                                       ;; 00:0fec $7e
    ld   [HL], $00                                     ;; 00:0fed $36 $00
    ld   [wDE5F_CurrentSoundEffectPriority], A         ;; 00:0fef $ea $5f $de
    jp   call_00_0f08_RestoreBank                      ;; 00:0ff2 $c3 $08 $0f

call_00_0ff5_QueueSFX:
; Offers SFX_* id A for the next call_00_0fc8_PlayQueuedSFX, if it outranks what
; is already sounding.
;
; The priority comes from .data_00_1037_SFXPriorities. The four channel status
; bytes at wDF68, wDF6B, wDF6E and wDF71 are ORed together to ask "is anything
; audible right now"; if so, a lower priority than
; wDE5F_CurrentSoundEffectPriority is dropped on the spot. A request that gets
; past that is then weighed against anything already queued this frame, and only
; replaces it if it is at least as important.
;
; gex2's call_00_112f_QueueSFX has no priorities at all - it simply refuses to
; overwrite a slot that is already full, so the first request of a frame wins
    cp   A, SFX_NONE                                   ;; 00:0ff5 $fe $ff
    ret  Z                                             ;; 00:0ff7 $c8
    ld   C, A                                          ;; 00:0ff8 $4f
    ld   B, $00                                        ;; 00:0ff9 $06 $00
    ld   HL, .data_00_1037_SFXPriorities               ;; 00:0ffb $21 $37 $10
    add  HL, BC                                        ;; 00:0ffe $09
    ld   B, [HL]                                       ;; 00:0fff $46
    xor  A, A                                          ;; 00:1000 $af
    ld   HL, wDF68                                     ;; 00:1001 $21 $68 $df
    or   A, [HL]                                       ;; 00:1004 $b6
    inc  HL                                            ;; 00:1005 $23
    or   A, [HL]                                       ;; 00:1006 $b6
    ld   HL, wDF6B                                     ;; 00:1007 $21 $6b $df
    or   A, [HL]                                       ;; 00:100a $b6
    inc  HL                                            ;; 00:100b $23
    or   A, [HL]                                       ;; 00:100c $b6
    ld   HL, wDF6E                                     ;; 00:100d $21 $6e $df
    or   A, [HL]                                       ;; 00:1010 $b6
    inc  HL                                            ;; 00:1011 $23
    or   A, [HL]                                       ;; 00:1012 $b6
    ld   HL, wDF71                                     ;; 00:1013 $21 $71 $df
    or   A, [HL]                                       ;; 00:1016 $b6
    inc  HL                                            ;; 00:1017 $23
    or   A, [HL]                                       ;; 00:1018 $b6
    jr   Z, .jr_00_1021                                ;; 00:1019 $28 $06
    ld   A, B                                          ;; 00:101b $78
    ld   HL, wDE5F_CurrentSoundEffectPriority          ;; 00:101c $21 $5f $de
    cp   A, [HL]                                       ;; 00:101f $be
    ret  C                                             ;; 00:1020 $d8
.jr_00_1021:
    ld   A, [wDE5D_QueuedSoundEffect]                  ;; 00:1021 $fa $5d $de
    cp   A, SFX_NONE                                   ;; 00:1024 $fe $ff
    jr   Z, .jr_00_102e                                ;; 00:1026 $28 $06
    ld   A, B                                          ;; 00:1028 $78
    ld   HL, wDE5E_QueuedSoundEffectPriority           ;; 00:1029 $21 $5e $de
    cp   A, [HL]                                       ;; 00:102c $be
    ret  C                                             ;; 00:102d $d8
.jr_00_102e:
    ld   HL, wDE5D_QueuedSoundEffect                   ;; 00:102e $21 $5d $de
    ld   [HL], C                                       ;; 00:1031 $71
    ld   HL, wDE5E_QueuedSoundEffectPriority           ;; 00:1032 $21 $5e $de
    ld   [HL], B                                       ;; 00:1035 $70
    ret                                                ;; 00:1036 $c9
.data_00_1037_SFXPriorities:
; One priority per SFX_* id, higher wins. Most effects are $01; the loud
; one-offs - SFX_EMPTY's $11, the two $10s and $0e/$0f - are what can interrupt
; something already playing
    db   $11, $01, $08, $08, $01, $01, $01, $01        ;; 00:1037 ??.?.?..
    db   $01, $01, $01, $01, $01, $10, $10, $07        ;; 00:103f .?.??..?
    db   $07, $01, $01, $01, $08, $08, $01, $08        ;; 00:1047 .???????
    db   $08, $0e, $0f, $08, $08, $10, $10             ;; 00:104f ?.???..
