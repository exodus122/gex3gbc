; MBC1
DEF MBC1SRamEnable      EQU $0001
DEF MBC1RomBank         EQU $2001
DEF MBC1SRamBank        EQU $4001
DEF MBC1SRamBankingMode EQU $6001

; ROM Banks
DEF BANK_00_HOME_CODE         EQU $00
DEF BANK_01_MENU_CODE         EQU $01
DEF BANK_02_ENTITY_CODE       EQU $02
DEF BANK_03_COLLISION_AND_GRAPHICS_CODE EQU $03
DEF BANK_04_AUDIO_CODE_1      EQU $04
DEF BANK_05_AUDIO_CODE_2      EQU $05
DEF Bank06                    EQU $06
DEF Bank07                    EQU $07
DEF Bank08                    EQU $08
DEF Bank09                    EQU $09
DEF BANK_0A_ENTITY_SPRITES    EQU $0a
DEF Bank0b                    EQU $0b
DEF Bank0c                    EQU $0c
DEF Bank0d                    EQU $0d
DEF Bank0e                    EQU $0e
DEF Bank0f                    EQU $0f
DEF Bank10                    EQU $10
DEF Bank11                    EQU $11
DEF BANK_1C_TEXT              EQU $1c
DEF Bank1d                    EQU $1d
DEF Bank1e                    EQU $1e
DEF BANK_1F_SECONDARY_TILESETS EQU $1f
DEF Bank20                    EQU $20 ; unused
DEF Bank21_BgPalettesAndCollectibleLists EQU $21 ; bg palette data, and collectible lists for each map
DEF Bank22_EntitySpawnLists   EQU $22 ; entity spawn lists for each map
DEF Bank23_CollisionBlocksets EQU $23
DEF Bank24_BlocksetData       EQU $24
DEF Bank25_BlocksetData       EQU $25
DEF Bank26_BlocksetData       EQU $26
DEF Bank27_BlocksetData       EQU $27
DEF Bank28_BlocksetData       EQU $28
DEF Bank2e_ExtendedMapData    EQU $2e
DEF Bank2f_MapData            EQU $2f ; WesternStation, ChannelZ
DEF Bank30_MapCollision       EQU $30
DEF Bank31_ExtendedMapData    EQU $31
DEF Bank32_MapData            EQU $32 ; MysteryTV, HolidayTV, TutTV, GextremeSports
DEF Bank33_MapCollision       EQU $33
DEF Bank34_ExtendedMapData    EQU $34
DEF Bank35_MapData            EQU $35 ; HolidayTV, MarsupialMadness, WWGexWrestling
DEF Bank36_MapCollision       EQU $36
DEF Bank37_ExtendedMapData    EQU $37
DEF Bank38_MapData            EQU $38 ; AnimeChannel, LizardOfOz
DEF Bank39_MapCollision       EQU $39
DEF Bank3a_ExtendedMapData    EQU $3a
DEF Bank3b_MapData            EQU $3b ; SuperheroShow, GextremeSports
DEF Bank3c_MapCollision       EQU $3c
DEF Bank3d_ExtendedMapData    EQU $3d
DEF Bank3e_MapData            EQU $3e ; GexCave, SuperheroShow
DEF Bank3f_MapCollision       EQU $3f
DEF Bank40_Tileset            EQU $40 ; AnimeChannel, MarsupialMadness
DEF Bank41_Tileset            EQU $41 ; WesternStation, AnimeChannel, LizardOfOz
DEF Bank42_Tileset            EQU $42 ; WesternStation
DEF Bank43_Tileset            EQU $43 ; HolidayTV, GextremeSports
DEF Bank44_Tileset            EQU $44 ; MysteryTV
DEF Bank45_Tileset            EQU $45 ; HolidayTV, MysteryTV
DEF Bank46_Tileset            EQU $46 ; TutTV
DEF Bank47_Tileset            EQU $47 ; TutTV, SuperheroShow
DEF Bank48_Tileset            EQU $48 ; AnimeChannel
DEF Bank49_Tileset            EQU $49 ; SuperheroShow
DEF Bank4a_Tileset            EQU $4a ; TutTV, SuperheroShow
DEF Bank4b_Tileset            EQU $4b ; WesternStation
DEF Bank4c_Tileset            EQU $4c ; ChannelZ
DEF Bank4d_Tileset            EQU $4d ; GexCave, AnimeChannel, GextremeSports
DEF Bank4e_Tileset            EQU $4e ; GexCave
DEF Bank4f_Tileset            EQU $4f ; WesternStation, WWGexWrestling, ChannelZ

DEF BANK_7F_ENTITY_PALETTES   EQU $7f ; entity sprite and palette data

; Inputs (defined in hardware.inc)
; DEF PADF_DOWN   EQU $80
; DEF PADF_UP     EQU $40
; DEF PADF_LEFT   EQU $20
; DEF PADF_RIGHT  EQU $10
; DEF PADF_START  EQU $08
; DEF PADF_SELECT EQU $04
; DEF PADF_B      EQU $02
; DEF PADF_A      EQU $01
DEF PADF_DOWN_BIT   EQU 7
DEF PADF_UP_BIT     EQU 6
DEF PADF_LEFT_BIT   EQU 5
DEF PADF_RIGHT_BIT  EQU 4
DEF PADF_START_BIT  EQU 3
DEF PADF_SELECT_BIT EQU 2
DEF PADF_B_BIT      EQU 1
DEF PADF_A_BIT      EQU 0

; Levels
DEF LEVEL_GEX_CAVE                   EQU $00
DEF LEVEL_HOLIDAY_TV                 EQU $01
DEF LEVEL_MYSTERY_TV                 EQU $02
DEF LEVEL_TUT_TV                     EQU $03
DEF LEVEL_WESTERN_STATION            EQU $04
DEF LEVEL_ANIME_CHANNEL              EQU $05
DEF LEVEL_SUPERHERO_SHOW             EQU $06
DEF LEVEL_GEXTREME_SPORTS            EQU $07 ; if you touch a tv button with this level id, you go to credits
DEF LEVEL_MARSUPIAL_MADNESS          EQU $08
DEF LEVEL_WW_GEX_WRESTLING           EQU $09
DEF LEVEL_LIZARD_OF_OZ               EQU $0A
DEF LEVEL_CHANNEL_Z                  EQU $0B ; if you touch a tv button with this level id, you go to credits

; Maps
DEF MAP_GEX_CAVE1                  EQU $00
DEF MAP_HOLIDAY_TV1                EQU $01
DEF MAP_MYSTERY_TV1                EQU $02
DEF MAP_TUT_TV1                    EQU $03
DEF MAP_WESTERN_STATION1           EQU $04
DEF MAP_ANIME_CHANNEL1             EQU $05
DEF MAP_SUPERHERO_SHOW1            EQU $06
DEF MAP_GEXTREME_SPORTS1           EQU $07
DEF MAP_MARSUPIAL_MADNESS1         EQU $08
DEF MAP_WW_GEX_WRESTLING1          EQU $09
DEF MAP_LIZARD_OF_OZ1              EQU $0A
DEF MAP_CHANNEL_Z1                 EQU $0B
DEF MAP_GEX_CAVE2                  EQU $0C
DEF MAP_GEX_CAVE3                  EQU $0D
DEF MAP_GEX_CAVE4                  EQU $0E
DEF MAP_HOLIDAY_TV2                EQU $0F
DEF MAP_HOLIDAY_TV3                EQU $10
DEF MAP_HOLIDAY_TV4                EQU $11
DEF MAP_MYSTERY_TV2                EQU $12
DEF MAP_MYSTERY_TV3                EQU $13
DEF MAP_MYSTERY_TV4                EQU $14
DEF MAP_MYSTERY_TV5                EQU $15
DEF MAP_MYSTERY_TV6                EQU $16
DEF MAP_MYSTERY_TV7                EQU $17
DEF MAP_MYSTERY_TV8                EQU $18
DEF MAP_MYSTERY_TV9                EQU $19
DEF MAP_MYSTERY_TV10               EQU $1A
DEF MAP_TUT_TV2                    EQU $1B
DEF MAP_TUT_TV3                    EQU $1C
DEF MAP_TUT_TV4                    EQU $1D
DEF MAP_TUT_TV5                    EQU $1E
DEF MAP_TUT_TV6                    EQU $1F
DEF MAP_TUT_TV7                    EQU $20
DEF MAP_WESTERN_STATION2           EQU $21
DEF MAP_WESTERN_STATION3           EQU $22
DEF MAP_WESTERN_STATION4           EQU $23
DEF MAP_WESTERN_STATION5           EQU $24
DEF MAP_WESTERN_STATION6           EQU $25
DEF MAP_WESTERN_STATION7           EQU $26
DEF MAP_WESTERN_STATION8           EQU $27
DEF MAP_WESTERN_STATION9           EQU $28
DEF MAP_ANIME_CHANNEL2             EQU $29
DEF MAP_ANIME_CHANNEL3             EQU $2A
DEF MAP_ANIME_CHANNEL4             EQU $2B
DEF MAP_ANIME_CHANNEL5             EQU $2C
DEF MAP_ANIME_CHANNEL6             EQU $2D
DEF MAP_ANIME_CHANNEL7             EQU $2E
DEF MAP_ANIME_CHANNEL8             EQU $2F
DEF MAP_ANIME_CHANNEL9             EQU $30
DEF MAP_SUPERHERO_SHOW2            EQU $31
DEF MAP_SUPERHERO_SHOW3            EQU $32
DEF MAP_SUPERHERO_SHOW4            EQU $33
DEF MAP_SUPERHERO_SHOW5            EQU $34
DEF MAP_SUPERHERO_SHOW6            EQU $35
DEF MAP_GEXTREME_SPORTS2           EQU $36
DEF MAP_GEXTREME_SPORTS3           EQU $37
DEF MAP_GEXTREME_SPORTS4           EQU $38
DEF MAP_CHANNEL_Z2                 EQU $39
DEF MAP_CHANNEL_Z3                 EQU $3A
DEF MAP_CHANNEL_Z4                 EQU $3B
DEF MAP_CHANNEL_Z5                 EQU $3C

; ------------------------------------------------------------------
; BG map geometry (see code/bank00_bg_map.asm)
; ------------------------------------------------------------------
DEF BGMAP_BLOCK_SIZE_PX          EQU 16  ; one block is 16x16 pixels...
DEF BGMAP_BLOCK_SIZE_TILES       EQU 2   ; ...that is 2x2 tiles
DEF BGMAP_BLOCKSET_ENTRY_SIZE    EQU 8   ; 4 tile ids then 4 GBC attribute bytes
DEF BGMAP_COLLISION_ENTRY_SIZE   EQU 4   ; 4 collision tile ids, no attributes
DEF BGMAP_STRIP_BLOCKS           EQU $0b ; blocks per loaded strip: 11 * 16px = 176px,
                                         ; one block wider than the 160px screen
DEF BGMAP_INITIAL_ROWS           EQU $16 ; rows drawn per pass when a map is first loaded

; ------------------------------------------------------------------
; wDC20_BgMapLoadingFlags. Each scroll bit names the direction the camera moved,
; and therefore which edge of the screen has to be redrawn. Same bit assignments
; as gex2's wD6F9_BgMap_LoadingFlags
; ------------------------------------------------------------------
DEF MAP_PENDING_VRAM_TRANSFER    EQU 7   ; bit 7 - a strip is assembled and waiting on vblank
DEF MAP_SCROLL_UP                EQU $01 ; loads the row at camera Y - 1
DEF MAP_SCROLL_DOWN              EQU $02 ; loads the row at camera Y + $88
DEF MAP_SCROLL_LEFT              EQU $04 ; loads the column at camera X - 1
DEF MAP_SCROLL_RIGHT             EQU $08 ; loads the column at camera X + $A0

; ------------------------------------------------------------------
; wDC33_BgMap_InitialLoadPass. call_00_1056_BgMap_LoadFull runs
; call_00_1a22_BgMap_LoadAllRowsForPass once per value, in this order, flushing
; wC000_BgMapTileIds to VRAM between the first two
; ------------------------------------------------------------------
DEF BGMAP_PASS_ATTRIBUTES        EQU $04 ; blockset bytes 4-7 -> VRAM bank 1
DEF BGMAP_PASS_TILE_IDS          EQU $00 ; blockset bytes 0-3 -> VRAM bank 0
DEF BGMAP_PASS_COLLISION         EQU $80 ; collision blockset -> stays in wC000_BgMapTileIds

; ------------------------------------------------------------------
; wDC8A_MapEdgeTouched - which map boundary the player is clamped against, and
; the second index into .data_00_153f_MapEdgeSpawnIds
; ------------------------------------------------------------------
DEF MAP_EDGE_TOP                 EQU $00
DEF MAP_EDGE_BOTTOM              EQU $01
DEF MAP_EDGE_LEFT                EQU $02
DEF MAP_EDGE_RIGHT               EQU $03
DEF MAP_EDGE_NONE                EQU $ff ; any value with bit 7 set means "not touching an edge"

DEF MAP_EDGE_SPAWN_NONE          EQU $ff ; that edge does not lead anywhere
DEF MAP_EDGE_SPAWN_CONDITIONAL   EQU $fe ; use spawn $10, but only if wDCB1_LevelTriggerBuffer[0] is set

; ------------------------------------------------------------------
; Warp / door record layout (see call_00_1633_Map_LoadWarpDestination and
; call_00_1bbc_CheckForDoorAndEnter)
; ------------------------------------------------------------------
DEF MAP_SPAWN_ENTRY_SIZE         EQU 8   ; map id, X, Y, linked spawn id, 2 spare
DEF MAP_SPAWN_LINK_ABSOLUTE      EQU $ff ; spawn uses its own Y instead of the player's offset
DEF MAP_DOOR_ENTRY_SIZE          EQU 6   ; spawn id, required trigger, X, Y
DEF MAP_DOOR_LIST_END            EQU $ff ; terminates a map's door list
DEF MAP_DOOR_NO_TRIGGER          EQU $ff ; door has no wDCB1_LevelTriggerBuffer condition
DEF MAP_DOOR_X_TOLERANCE         EQU 8   ; player X must be within +/- 8 px of the door

; ------------------------------------------------------------------
; Background collision - see code/bank03_bg_collision.asm
; ------------------------------------------------------------------
DEF COLLISION_MAP_COLS           EQU 32
DEF COLLISION_MAP_ROWS           EQU 32
DEF COLLISION_MAP_STRIDE         EQU $20 ; bytes from one tile row to the next

; bits of a data_03_4000_TileCollisionFlags byte
DEF TILECOLL_SOLID_BIT           EQU 0   ; blocks movement
DEF TILECOLL_CEILING_BIT         EQU 1   ; bonks the head, zeroing Y velocity
DEF TILECOLL_CLIMB_BACKING_BIT   EQU 3   ; a climber can hold onto it

; bits of wDABE_CollisionFlags
DEF BGCOLL_SLOPE_MASK            EQU $0f ; low nibble: pixels to step up
DEF BGCOLL_WALL_BIT              EQU 6   ; ran into a wall this frame
DEF BGCOLL_NO_COLLISION_BIT      EQU 7   ; grounded, swimming, climbing or otherwise

DEF BGCOLL_WALL_PROBE_ROWS       EQU 4   ; tile rows sampled ahead of him
DEF BGCOLL_FLOOR_SEARCH_ROWS     EQU 5   ; pixel rows scanned down for floor
DEF PLAYER_FEET_OFFSET           EQU $10 ; from his origin down to his feet

; wDC1F_CurrentBgCollisionType - which handler a map uses
DEF BGCOLL_TYPE_SIDESCROLLER     EQU $00
DEF BGCOLL_TYPE_TOP_DOWN         EQU $01

; wDC89_BgCollision_TopDownDirection, and the index into
; .data_03_4a1b_TopDownStepOffsets. Odd values are the cardinals, which are
; stepped straight away; even values are the diagonals, which are probed first
DEF BGCOLL_DIR_NONE              EQU 0
DEF BGCOLL_DIR_UP                EQU 1
DEF BGCOLL_DIR_UP_RIGHT          EQU 2
DEF BGCOLL_DIR_RIGHT             EQU 3
DEF BGCOLL_DIR_DOWN_RIGHT        EQU 4
DEF BGCOLL_DIR_DOWN              EQU 5
DEF BGCOLL_DIR_DOWN_LEFT         EQU 6
DEF BGCOLL_DIR_LEFT              EQU 7
DEF BGCOLL_DIR_UP_LEFT           EQU 8

DEF CLIMB_SCRIPT_ENTRY_SIZE      EQU 3   ; input, X offset, Y offset
DEF SWIM_SCRIPT_ENTRY_SIZE       EQU 5   ; ...plus a second, unread offset pair

DEF TILE_TYPE_CLIMBABLE          EQU $3d ; the one type call_03_4c2e_BgCollision_IsTileClimbable tests for

; ------------------------------------------------------------------
; Cutscenes - see code/bank00_cutscenes.asm
; ------------------------------------------------------------------
DEF CUTSCENE_SLOTS_PER_LEVEL     EQU $04 ; entries per level in the index lookup table
DEF CUTSCENE_NONE                EQU $ff ; no cutscene for this level/mission
DEF CUTSCENE_MOVE_END            EQU $ff ; terminator in a movement command list
DEF CUTSCENE_MOVE_SPEED_MAX      EQU $10 ; 16/16ths = exactly one pixel per frame
DEF CUTSCENE_HOLD_FRAMES         EQU $b4 ; 180 frames (3s) of dwell before returning

; ==================================================================
; bank00_home.asm - boot, the outer game loop, and the shared video,
; banking, input and sfx helpers. Named to match gex2's own home-bank
; constants wherever the two engines do the same thing
; ==================================================================

; The A register the boot ROM hands to the cartridge entry point. $11 means a CGB
; started us. gex3 is CGB-only (CART_COMPATIBLE_GBC), so unlike gex2 this is not
; recorded anywhere - anything else drops into the "GAME BOY COLOR ONLY" screen
DEF BOOT_A_CGB                   EQU $11

; rLY value Init spins for before switching the LCD off: one line past the last
; visible scanline, i.e. the first line of vblank
DEF LY_VBLANK_START              EQU SCRN_Y + 1

; rSVBK. $D000-$DFFF holds game state, so WRAM bank 1 must always be the mapped one
DEF WRAM_BANK_GAME_STATE         EQU $01

; The three LCDC values this bank ever writes.
;
; gex3 leaves LCDCF_WINON set for the whole frame and pulls the hud's colours in
; mid-frame instead - see LCD_ISR_HUD_PALETTE. gex2 does the opposite: its window
; is off in LCDC and its raster handler switches it on at RASTER_SPLIT_SCANLINE
DEF LCDC_GAMEPLAY                EQU LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BLK21 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
DEF LCDC_INIT                    EQU LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BLK21 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
DEF LCDC_DMG_ERROR_SCREEN        EQU LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BLK01 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON

; What call_00_0d8b_LcdIsr_LoadHudPalettesA does to wDAD8_LCDCValue on its way to
; rLCDC: the hud strip is drawn out of the $8000 tile block and has no sprites
DEF LCDC_HUD_CLEAR_MASK          EQU ~LCDCF_OBJON & $FF
DEF LCDC_HUD_SET_MASK            EQU LCDCF_BLK01

; The DMG palette the "GAME BOY COLOR ONLY" screen is shown with
DEF BGP_DMG_ERROR_SCREEN         EQU $93

; Window position. gex3 parks the window one line below the screen at boot and
; the menu / hud code moves it; WX is flush left for the whole game
DEF WINDOW_X_FLUSH_LEFT          EQU $07
DEF WINDOW_Y_OFFSCREEN           EQU $80

; ------------------------------------------------------------------
; LCD STAT interrupt handler ids, passed to call_00_0c10_RequestLcdIsr /
; call_00_0c1b_InstallLcdIsr and stored in the low 7 bits of wD9FD_LcdIsrId.
; Each id is a byte offset into .data_00_0c44_LcdIsrTable, and an entry there is
; five bytes - rSTAT value, rLYC value, template length, template pointer - so
; the ids run 0, 5, 10 rather than 0, 1, 2.
;
; Same mechanism as gex2's LCD_ISR_*, including the "installed" bit: the id is
; stored with bit 7 clear to request it, and the vblank handler installs it and
; sets bit 7. gex3's two real handlers do different jobs from gex2's, though -
; there is no hblank tile streamer here, because gex3 has HDMA
; ------------------------------------------------------------------
DEF LCD_ISR_NONE                 EQU $00 ; handler is just a reti
DEF LCD_ISR_HUD_PALETTE          EQU $05 ; two-scanline BG palette swap for the hud strip
DEF LCD_ISR_MENU_GFX_STREAM      EQU $0a ; reti handler; its vblank hook runs the menu gfx stream
DEF LCD_ISR_INSTALLED            EQU $80 ; bit 7 of wD9FD_LcdIsrId
DEF LCD_ISR_INSTALLED_BIT        EQU 7   ; the same, for `bit` / `set`
DEF LCD_ISR_ID_MASK              EQU $7F ; the id with that bit stripped off

; The scanline counter the hud palette handler works off. wDB67_LcdIsr_ScanlineCounter
; is seeded from rLY at the end of every vblank and then incremented once per
; hblank, so these are effectively scanline numbers
DEF LCD_ISR_HUD_PALETTE_LINE_A   EQU $7F ; first half of the swap
DEF LCD_ISR_HUD_PALETTE_LINE_B   EQU $80 ; second half, on the next line

; rBCPS indices the two halves write, with BCPSF_AUTOINC already set
DEF BCPS_HUD_PAL0_COLORS_01      EQU BCPSF_AUTOINC | $00
DEF BCPS_HUD_PAL1_COLORS_01      EQU BCPSF_AUTOINC | $08
DEF BCPS_HUD_PAL0_COLORS_23      EQU BCPSF_AUTOINC | $04
DEF BCPS_HUD_PAL1_COLORS_23      EQU BCPSF_AUTOINC | $0C

; Opcode the LCD STAT vector table's "do nothing" template is made of. gex3 never
; patches its handlers in place the way gex2 does, so this is the only one needed
DEF OPCODE_RETI                  EQU $D9

; ------------------------------------------------------------------
; wDB66_GfxTransferFlags - pending HDMA jobs, serviced by
; call_00_0c6a_VBlank_StartPendingHdma highest priority first. Plays the same
; role as gex2's wD60F_GfxTransferFlags, but each bit here names a source of
; HDMA parameters rather than a page to dribble out over hblanks
; ------------------------------------------------------------------
DEF GFX_XFER_PLAYER_GFX          EQU 0 ; wDAC0_PlayerGfx_SrcAddr / wDAC2_PlayerGfx_TileCount -> $8000
DEF GFX_XFER_ENTITY_GFX          EQU 1 ; wDB64_EntityGfx_SrcAddr -> the slot's own VRAM page
DEF GFX_XFER_HDMA_CONFIG         EQU 2 ; the wDC2B_Hdma_SrcAddrLo job struct, resumed across frames
DEF GFX_XFER_PENDING             EQU 7 ; at least one of the above is waiting on vblank

; ------------------------------------------------------------------
; wDB69_HUDDirtyFlags - what the status bar has to redraw, read by
; call_03_747d_HUD_Update and friends. gex2's wD60E_HUDDirtyFlags with the same
; idea and a different bit order
; ------------------------------------------------------------------
DEF HUD_DIRTY_COUNTERS           EQU 0 ; lives + fly coin digits
DEF HUD_DIRTY_HEALTH             EQU 1
DEF HUD_DIRTY_TIMER              EQU 2 ; bonus stage countdown
DEF HUD_DIRTY_FLY_COIN_ANIM      EQU 4 ; the spinning fly coin on the status bar
; call_00_0513_Screen_PresentAndDrawEntities raises these and then blocks until
; every bit of HUD_DIRTY_BLOCKING has been serviced
DEF HUD_DIRTY_ON_SCREEN_PRESENT  EQU $17
DEF HUD_DIRTY_BLOCKING           EQU $2f

; ------------------------------------------------------------------
; wDB6A_WarpFlags - the reasons to leave the map, tested in priority order at
; the top of the per-frame loop. Bits 1 and 2 line up with gex2's WARP_DIED and
; WARP_ENTERED_TV; the top two bits are gex3's, and are what the level-to-level
; structure needs that gex2's one-map levels did not
; ------------------------------------------------------------------
DEF WARP_DIED                    EQU $02 ; spend a life and respawn, or game over
DEF WARP_CHANGE_MAP              EQU $04 ; a door or map edge picked a new map in this level
DEF WARP_NEW_LEVEL               EQU $10 ; leave the level entirely - tv entered, boss beaten, bonus won
DEF WARP_TIME_UP                 EQU $20 ; the bonus stage countdown ran out
DEF WARP_DIED_BIT                EQU 1   ; the same four, for `bit` / `set`
DEF WARP_CHANGE_MAP_BIT          EQU 2
DEF WARP_NEW_LEVEL_BIT           EQU 4
DEF WARP_TIME_UP_BIT             EQU 5

; ------------------------------------------------------------------
; .data_00_0aa9_HdmaConfigTable indices, passed in C to
; call_00_0a6a_Hdma_RunConfigEntry. An entry whose bank byte is
; HDMACFG_BANK_MAP_TILESET is relocated against the current map's tileset
; ------------------------------------------------------------------
DEF HDMACFG_HUD_TILES            EQU 0  ; status bar tile graphics -> $8000, VRAM bank 1
DEF HDMACFG_HUD_ATTRIBUTES       EQU 1  ; status bar window attributes -> $9C00, VRAM bank 1
DEF HDMACFG_HUD_TILEMAP          EQU 2  ; status bar window tile ids -> $9C00, VRAM bank 0
DEF HDMACFG_TILESET_0            EQU 3  ; map tileset $0000 -> $9000, VRAM bank 0
DEF HDMACFG_TILESET_1            EQU 4  ; map tileset $0800 -> $8800, VRAM bank 0
DEF HDMACFG_TILESET_2            EQU 5  ; map tileset $1000 -> $9000, VRAM bank 1
DEF HDMACFG_TILESET_3            EQU 6  ; map tileset $1800 -> $8800, VRAM bank 1
DEF HDMACFG_BGMAP_ATTRIBUTES     EQU 7  ; wC000_BgMapTileIds -> $9800, VRAM bank 1
DEF HDMACFG_BGMAP_TILE_IDS       EQU 8  ; wC000_BgMapTileIds -> $9800, VRAM bank 0
DEF HDMACFG_WRAM_TILES_BANK0     EQU 9  ; wC000_BgMapTileIds -> $8000, VRAM bank 0
DEF HDMACFG_WRAM_TILES_BANK1     EQU 10 ; wC000_BgMapTileIds -> $8000, VRAM bank 1
DEF HDMACFG_ENTRY_SIZE           EQU 8  ; src, dest, length, then bank and VRAM bank
DEF HDMACFG_BANK_MAP_TILESET     EQU $ff ; use wDC07_TilesetBank + wDC08_TilesetBankOffset
DEF HDMA_MAX_BLOCKS              EQU $40 ; rHDMA5 counts 16-byte blocks, 64 at a time

; ------------------------------------------------------------------
; jp_00_0781_Screen_LoadFullscreenImage - the 8-byte record menus fill in at
; wDBB1_ScreenDraw_HasPaletteIdMap, and the two $168-byte buffers it produces
; ------------------------------------------------------------------
DEF SCREEN_TILEMAP_BYTES         EQU $168 ; SCRN_X_B * SCRN_Y_B, one byte per visible tile
DEF SCREEN_TILE_CHUNK_BYTES      EQU $1000 ; tile data is uploaded to VRAM one $1000 block at a time

; call_00_0800_Screen_LoadSecondaryTilesetRow - 6 rows of 8 tile ids lifted out
; of a bank $1F tileset's tilemap and written into a caller's 20-wide buffer
DEF SECONDARY_TILESET_MAP_OFFSET EQU $300 ; past the tile data, at the tilemap
DEF SECONDARY_TILESET_MAP_ROWS   EQU $06
DEF SECONDARY_TILESET_MAP_COLS   EQU $08

; ------------------------------------------------------------------
; Player state written once per continue / per life
; ------------------------------------------------------------------
DEF PLAYER_STARTING_LIVES        EQU $04
DEF PLAYER_MAX_LIVES             EQU 99  ; call_00_0723_Player_ObtainedCollectible clamps here
DEF PLAYER_BASE_HEALTH           EQU $04 ; plus wDC4F_PawCoinExtraHealth, four paw coins per point
DEF PROGRESS_FLAG_COUNT          EQU $0c ; entries of wDC5C_ProgressFlags wiped on a new game

; ------------------------------------------------------------------
; Fly coins. Unlike gex2 the counter only ever rises, and the payouts are two
; fixed thresholds rather than a milestone table plus a repeating interval
; ------------------------------------------------------------------
DEF COLLECTIBLE_EXTRA_LIFE       EQU 50  ; grants a life
DEF COLLECTIBLE_LEVEL_COMPLETE   EQU 100 ; sets PROGRESS_ALL_COLLECTIBLES_BIT for this level
DEF PROGRESS_ALL_COLLECTIBLES_BIT EQU 3  ; bit of wDC5C_ProgressFlags[level]

; ------------------------------------------------------------------
; Fly power-ups. Eating a fly with SELECT swaps it in and cashes the old one
; out - see call_00_0624_Player_SwapFlyPowerup, gex3's
; call_00_0647_Player_SwapFlyPowerup. Three of the five ids arm a timer, and
; each has a countdown byte of its own
; ------------------------------------------------------------------
DEF FLY_POWERUP_NONE             EQU $00
DEF FLY_POWERUP_1                EQU $01 ; arms wDCAA_FlyPowerup1_Timer
DEF FLY_POWERUP_2                EQU $02 ; arms wDCA9_FlyPowerup2_Timer
DEF FLY_POWERUP_HEALTH           EQU $03 ; one health point back, up to the paw coin maximum
DEF FLY_POWERUP_EXTRA_LIFE       EQU $04
DEF FLY_POWERUP_5                EQU $05 ; arms wDCAB_FlyPowerup5_Timer

; wDCAE_FlyPowerup_ActiveIndex - which of the three timed power-ups is running,
; read by the palette code to tint Gex
DEF FLY_POWERUP_ACTIVE_1         EQU $00
DEF FLY_POWERUP_ACTIVE_5         EQU $01
DEF FLY_POWERUP_ACTIVE_2         EQU $02

; A power-up lasts FLY_POWERUP_SECONDS ticks of wDCA8_FlyPowerup_FrameCounter,
; which call_02_4ffb_DecTimerEveryCycle reloads with TIMER_AMOUNT_60_FRAMES
DEF FLY_POWERUP_SECONDS          EQU $14

; ------------------------------------------------------------------
; Bonus stage countdown - call_00_05c7_LevelTimer_Tick. gex3 keeps a plain
; seconds count rather than gex2's BCD minutes and seconds
; ------------------------------------------------------------------
DEF FRAMES_PER_SECOND            EQU $3c

; ------------------------------------------------------------------
; Menu results. call_01_4000_MenuHandler_LoadAndProcess returns one of these in
; A, and the outer game loop branches on it
; ------------------------------------------------------------------
DEF MENU_RESULT_START_GAME       EQU $10 ; title screen: begin a new game
DEF MENU_RESULT_PASSWORD_ACCEPTED EQU $20 ; title screen: resume from a password, keep the decoded state
DEF MENU_RESULT_CONTINUE         EQU $40 ; game over screen: hand out a fresh set of lives
DEF MENU_RESULT_CONFIRM_QUIT     EQU $60 ; pause menu: leave the level

; ------------------------------------------------------------------
; Sizes of the fixed copies bank00_home performs
; ------------------------------------------------------------------
DEF WRAM_CLEAR_SIZE              EQU $1fff ; $C000-$DFFE, seeded and copied forward over itself
DEF VRAM_CLEAR_SIZE              EQU $1fff ; the same trick per VRAM bank
DEF SHADOW_OAM_SIZE              EQU $A0   ; 40 sprites x 4 bytes at wD900_ShadowOAM
DEF OAM_DMA_WAIT_LOOPS           EQU $28   ; busy-wait in call_00_0e29_OamDmaRoutine
DEF OAM_DMA_ROUTINE_SIZE         EQU $0a   ; bytes copied to hFF80_OamDmaRoutine at boot
DEF CGB_PALETTE_RAM_SIZE         EQU $40   ; 8 palettes x 4 colours x 2 bytes
DEF BG_PALETTE_BYTES             EQU $40   ; one map's worth, copied to wDCEA_BgPalettes
DEF ENTITY_SLOT_STRIDE           EQU $20   ; bytes per entity in wD800_EntityMemory

; The "GAME BOY COLOR ONLY" screen Init draws on a DMG, straight into VRAM with
; the interrupts still off
DEF DMG_ERROR_TILES_SIZE         EQU $a00
DEF SFX_PRIORITY_NONE            EQU $00   ; wDE5F_CurrentSoundEffectPriority when nothing is playing

; Entities
DEF ENTITY_GEX                                         EQU $00
DEF ENTITY_BONUS_COIN                                  EQU $01
DEF ENTITY_FLY_COIN_SPAWN                              EQU $02
DEF ENTITY_PAW_COIN                                    EQU $03
DEF ENTITY_FLY_1                                       EQU $04
DEF ENTITY_FLY_2                                       EQU $05
DEF ENTITY_FLY_3                                       EQU $06
DEF ENTITY_FLY_4                                       EQU $07
DEF ENTITY_FLY_5                                       EQU $08
DEF ENTITY_GREEN_FLY_TV                                EQU $09
DEF ENTITY_PURPLE_FLY_TV                               EQU $0A
DEF ENTITY_UNK_FLY_TV_3                                EQU $0B
DEF ENTITY_BLUE_FLY_TV                                 EQU $0C
DEF ENTITY_UNK_FLY_TV_5                                EQU $0D
DEF ENTITY_UNK0E                                       EQU $0E ; unknown if used or not
DEF ENTITY_UNK0F                                       EQU $0F ; unknown if used or not
DEF ENTITY_UNK10                                       EQU $10 ; unknown if used or not
DEF ENTITY_TV_BUTTON                                   EQU $11
DEF ENTITY_TV_REMOTE                                   EQU $12
DEF ENTITY_UNK13                                       EQU $13 ; unknown if used or not, instantly destroys itself
DEF ENTITY_GOAL_COUNTER_1                              EQU $14
DEF ENTITY_GOAL_COUNTER_2                              EQU $15
DEF ENTITY_GOAL_COUNTER_3                              EQU $16
DEF ENTITY_GOAL_COUNTER_4                              EQU $17
DEF ENTITY_GOAL_COUNTER_5                              EQU $18
DEF ENTITY_GOAL_COUNTER_6                              EQU $19
DEF ENTITY_GOAL_COUNTER_7                              EQU $1A
DEF ENTITY_BONUS_STAGE_TIMER                           EQU $1B
DEF ENTITY_FREESTANDING_REMOTE                         EQU $1C
DEF ENTITY_HOLIDAY_TV_ICE_SCULPTURE                    EQU $1D
DEF ENTITY_HOLIDAY_TV_EVIL_SANTA                       EQU $1E
DEF ENTITY_HOLIDAY_TV_EVIL_SANTA_PROJECTILE            EQU $1F
DEF ENTITY_HOLIDAY_TV_SKATING_ELF                      EQU $20
DEF ENTITY_HOLIDAY_TV_PENGUIN                          EQU $21
DEF ENTITY_MYSTERY_TV_REZLING                          EQU $22
DEF ENTITY_MYSTERY_TV_BLOOD_COOLER                     EQU $23
DEF ENTITY_MYSTERY_TV_FISH                             EQU $24
DEF ENTITY_MYSTERY_TV_MAGIC_SWORD                      EQU $25
DEF ENTITY_MYSTERY_TV_SAFARI_SAM                       EQU $26
DEF ENTITY_MYSTERY_TV_SAFARI_SAM_PROJECTILE            EQU $27
DEF ENTITY_MYSTERY_TV_GHOST_KNIGHT                     EQU $28
DEF ENTITY_MYSTERY_TV_GHOST_KNIGHT_PROJECTILE          EQU $29
DEF ENTITY_TUT_TV_HAND                                 EQU $2A
DEF ENTITY_TUT_TV_LOST_ARK                             EQU $2B
DEF ENTITY_TUT_TV_RISING_PLATFORM                      EQU $2C
DEF ENTITY_TUT_TV_SIDEWAYS_PLATFORM                    EQU $2D
DEF ENTITY_TUT_TV_BEE                                  EQU $2E
DEF ENTITY_TUT_TV_RAFT                                 EQU $2F
DEF ENTITY_TUT_TV_SNAKE_FACING_RIGHT                   EQU $30
DEF ENTITY_TUT_TV_SNAKE_FACING_LEFT                    EQU $31
DEF ENTITY_TUT_TV_SNAKE_RIGHT_PROJECTILE               EQU $32
DEF ENTITY_TUT_TV_SNAKE_LEFT_PROJECTILE                EQU $33
DEF ENTITY_TUT_TV_RA_STAFF                             EQU $34
DEF ENTITY_TUT_TV_RA_STATUE_HORIZONTAL_PROJECTILE      EQU $35
DEF ENTITY_TUT_TV_RA_STATUE_DIAGONAL_PROJECTILE        EQU $36
DEF ENTITY_TUT_TV_BREAKABLE_BLOCK                      EQU $37
DEF ENTITY_TUT_TV_COFFIN                               EQU $38
DEF ENTITY_WESTERN_STATION_ENEMY_CACTUS                EQU $39
DEF ENTITY_WESTERN_STATION_CACTUS                      EQU $3A ; unused?
DEF ENTITY_WESTERN_STATION_ROCK_PLATFORM               EQU $3B
DEF ENTITY_WESTERN_STATION_HARD_HAT                    EQU $3C
DEF ENTITY_WESTERN_STATION_PLAYING_CARD                EQU $3D
DEF ENTITY_WESTERN_STATION_BAT                         EQU $3E
DEF ENTITY_WESTERN_STATION_RISING_PLATFORM             EQU $3F
DEF ENTITY_ANIME_CHANNEL_DOOR                          EQU $40
DEF ENTITY_ANIME_CHANNEL_DOOR2                         EQU $41
DEF ENTITY_ANIME_CHANNEL_FAN_LIFT                      EQU $42
DEF ENTITY_ANIME_CHANNEL_MECH_FACING_RIGHT             EQU $43
DEF ENTITY_ANIME_CHANNEL_MECH_FACING_LEFT              EQU $44
DEF ENTITY_ANIME_CHANNEL_DISAPPEARING_FLOOR            EQU $45
DEF ENTITY_ANIME_CHANNEL_ON_SWITCH2                    EQU $46
DEF ENTITY_ANIME_CHANNEL_ALIEN_CULTURE_TUBE            EQU $47
DEF ENTITY_ANIME_CHANNEL_BLUE_BEAM_BARRIER             EQU $48
DEF ENTITY_ANIME_CHANNEL_RISING_PLATFORM               EQU $49
DEF ENTITY_ANIME_CHANNEL_ON_SWITCH                     EQU $4A
DEF ENTITY_ANIME_CHANNEL_OFF_SWITCH                    EQU $4B
DEF ENTITY_ANIME_CHANNEL_SAILOR_TOON_GIRL              EQU $4C
DEF ENTITY_ANIME_CHANNEL_BIG_SILVER_ROBOT              EQU $4D
DEF ENTITY_ANIME_CHANNEL_SMALL_BLUE_ROBOT              EQU $4E
DEF ENTITY_ANIME_CHANNEL_SECBOT                        EQU $4F
DEF ENTITY_ANIME_CHANNEL_SECBOT_PROJECTILE             EQU $50
DEF ENTITY_ANIME_CHANNEL_ELEVATOR                      EQU $51
DEF ENTITY_ANIME_CHANNEL_FIRE_WALL_ENEMY               EQU $52
DEF ENTITY_ANIME_CHANNEL_GRENADE                       EQU $53
DEF ENTITY_ANIME_CHANNEL_PLANET_O_BLAST_WEAPON         EQU $54
DEF ENTITY_SUPERHERO_SHOW_MAD_BOMBER                   EQU $55
DEF ENTITY_SUPERHERO_SHOW_BOMB                         EQU $56
DEF ENTITY_SUPERHERO_SHOW_WATER_TOWER_TANK             EQU $57
DEF ENTITY_SUPERHERO_SHOW_WATER_TOWER_STAND            EQU $58
DEF ENTITY_SUPERHERO_SHOW_CONVICT                      EQU $59
DEF ENTITY_SUPERHERO_SHOW_SPIDER                       EQU $5A
DEF ENTITY_SUPERHERO_SHOW_STRAY_CAT                    EQU $5B
DEF ENTITY_SUPERHERO_SHOW_YELLOW_GOON                  EQU $5C
DEF ENTITY_SUPERHERO_SHOW_RAT                          EQU $5D
DEF ENTITY_SUPERHERO_SHOW_CHOMPER_TV                   EQU $5E
DEF ENTITY_SUPERHERO_SHOW_CRUMBLING_FLOOR              EQU $5F
DEF ENTITY_SUPERHERO_SHOW_CONVICT_PROJECTILE           EQU $60
DEF ENTITY_GEXTREME_SPORTS_ELF                         EQU $61
DEF ENTITY_GEXTREME_SPORTS_BONUS_TIME_COIN             EQU $62
DEF ENTITY_MARSUPIAL_MADNESS_BELL                      EQU $63
DEF ENTITY_MARSUPIAL_MADNESS_BIRD                      EQU $64
DEF ENTITY_MARSUPIAL_MADNESS_BIRD_PROJECTILE           EQU $65
DEF ENTITY_WW_GEX_WRESTLING_ROCK_HARD                  EQU $66
DEF ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ                    EQU $67
DEF ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE              EQU $68
DEF ENTITY_LIZARD_OF_OZ_CANNON                         EQU $69
DEF ENTITY_LIZARD_OF_OZ_BRAIN_OF_OZ_PROJECTILE         EQU $6A
DEF ENTITY_LIZARD_OF_OZ_CANNON_PROJECTILE_2            EQU $6B
DEF ENTITY_CHANNEL_Z_GREEN_BLOCK                       EQU $6C ; unused?
DEF ENTITY_CHANNEL_Z_ORANGE_BLOCK                      EQU $6D ; unused?
DEF ENTITY_CHANNEL_Z_REZ                               EQU $6E
DEF ENTITY_CHANNEL_Z_BLUE_BEAM_BARRIER                 EQU $6F ; unused?
DEF ENTITY_CHANNEL_Z_METEOR                            EQU $70
DEF ENTITY_CHANNEL_Z_REZ_PROJECTILE                    EQU $71
DEF ENTITY_LIST_TERMINATOR                             EQU $FF
DEF ENTITY_ID_NONE                                     EQU $FF ; a free entity slot

; Entity Instance Struct
DEF ENTITY_FIELD_ENTITY_ID                  EQU $00
DEF ENTITY_FIELD_ACTION_ID                  EQU $01
DEF ENTITY_FIELD_ACTION_FUNC                EQU $02
DEF ENTITY_FIELD_SPRITE_FLAGS2              EQU $04
DEF ENTITY_FIELD_ACTION_STATE_FLAGS         EQU $05
    DEF ACTION_STATE_UNK80_BIT             EQU 7
    DEF ACTION_STATE_UNK20_BIT             EQU 5
    DEF ACTION_STATE_IS_FIRST_FRAME_BIT    EQU 4
    DEF ACTION_STATE_ANIM_ENDED_BIT        EQU 2 ; set on the one frame an action's animation wraps,
                                                 ; cleared at the top of every sprite update.
                                                 ; call_00_2a5d_Entity_CheckAnimationEnded reads it and
                                                 ; it is how most actions hand off to the next one.
                                                 ; gex2's SPRITE_FLAG_ANIM_ENDED_BIT
    DEF ACTION_STATE_UNK80                 EQU $80
    DEF ACTION_STATE_UNK20                 EQU $20
    DEF ACTION_STATE_IS_FIRST_FRAME        EQU $10
    DEF ACTION_STATE_ANIM_ENDED                 EQU $04
DEF ENTITY_FIELD_SPRITE_FRAME_COUNTER_MAX   EQU $06 ; how many frames to use this sprite
DEF ENTITY_FIELD_SPRITE_FRAME_COUNTER       EQU $07 ; counter for the above
DEF ENTITY_FIELD_SPRITE_COUNTER_MAX         EQU $08 ; total sprite frames for current action
DEF ENTITY_FIELD_SPRITE_COUNTER             EQU $09 ; counter for above
DEF ENTITY_FIELD_SPRITE_ID                  EQU $0A ; current sprite id
DEF ENTITY_FIELD_SPRITE_IDS_PTR             EQU $0B ; ptr to sprite data (in entity_animation_data.asm)
DEF ENTITY_FIELD_FACING_DIRECTION           EQU $0D
DEF ENTITY_FIELD_XPOS                       EQU $0E
DEF ENTITY_FIELD_YPOS                       EQU $10
DEF ENTITY_FIELD_WIDTH                      EQU $12 ; set to [1] into data_00_3258
DEF ENTITY_FIELD_HEIGHT                     EQU $13 ; set to [2] into data_00_3258
DEF ENTITY_FIELD_COLLISION_TYPE             EQU $14 ; set to [3] into data_00_3258
DEF ENTITY_FIELD_COOLDOWN_TIMER             EQU $15 ; defaults to 0, but might get set to $3c (same value as gex's cooldown timer)
DEF ENTITY_FIELD_DAMAGE_STATE               EQU $16 ; stores current health or other damage states
DEF ENTITY_FIELD_SPRITE_BANK                EQU $17
DEF ENTITY_FIELD_UNK18                      EQU $18 ; seems unused
DEF ENTITY_FIELD_MISC_FLAGS                 EQU $19 ; only used by moving platforms, skating elf health, and sec bot?
                                                    ; initially set to data_00_3258[entity_id*8][5]
DEF ENTITY_FIELD_MISC_TIMER                 EQU $1A ; timer which can be used for various purposes
DEF ENTITY_FIELD_XVEL                       EQU $1B
DEF ENTITY_FIELD_XVEL_RELATED               EQU $1C ; subpixel accumulator: the low nibble carries the
                                                    ; fraction of a pixel XVEL has not paid out yet
DEF ENTITY_FIELD_YVEL                       EQU $1D
DEF ENTITY_FIELD_YVEL_RELATED               EQU $1E ; the same accumulator for YVEL. Only the facing-based
                                                    ; mover call_00_25cb_Entity_MoveYByFacingSpeed uses it;
                                                    ; call_00_24ee_Entity_ApplyYVelocity_Subpixel accumulates
                                                    ; into $1E's neighbour instead, so most entities leave
                                                    ; this byte at zero
DEF ENTITY_FIELD_PARENT                     EQU $1F ; stores entity list index of this entity's parent (used for projectiles, flies)

; Entity Spawn Struct
DEF ENTITY_SPAWN_ID_OFFSET                  EQU $00
DEF ENTITY_SPAWN_XPOS_OFFSET                EQU $01
DEF ENTITY_SPAWN_YPOS_OFFSET                EQU $03
DEF ENTITY_SPAWN_BOUNDINGBOX_XMAX_OFFSET    EQU $05
DEF ENTITY_SPAWN_BOUNDINGBOX_XMIN_OFFSET    EQU $07
DEF ENTITY_SPAWN_BOUNDINGBOX_YMIN_OFFSET    EQU $09
DEF ENTITY_SPAWN_BOUNDINGBOX_YMAX_OFFSET    EQU $0B
DEF ENTITY_SPAWN_PARAMETER_OFFSET           EQU $0D ; usually id used for collectibles, but sometimes contains a timer value
DEF ENTITY_SPAWN_MAP_OFFSET                 EQU $0F

; Entity child spawn id's
DEF SPAWN_CHILD_ENTITY_FLY_1                      EQU $00
DEF SPAWN_CHILD_ENTITY_FLY_2                      EQU $01
DEF SPAWN_CHILD_ENTITY_FLY_3                      EQU $02
DEF SPAWN_CHILD_ENTITY_FLY_4                      EQU $03
DEF SPAWN_CHILD_ENTITY_FLY_5                      EQU $04
DEF SPAWN_CHILD_ENTITY_EVIL_SANTA_PROJECTILE      EQU $05
DEF SPAWN_CHILD_ENTITY_SAFARI_SAM_PROJECTILE      EQU $06
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_1             EQU $07
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_2             EQU $08
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_3             EQU $09
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_4             EQU $0A
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_5             EQU $0B
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_6             EQU $0C
DEF SPAWN_CHILD_ENTITY_GOAL_COUNTER_7             EQU $0D
DEF SPAWN_CHILD_ENTITY_SNAKE_RIGHT_PROJECTILE     EQU $0E
DEF SPAWN_CHILD_ENTITY_SNAKE_LEFT_PROJECTILE      EQU $0F
DEF SPAWN_CHILD_ENTITY_SECBOT_PROJECTILE          EQU $10
DEF SPAWN_CHILD_ENTITY_UNK0E                      EQU $11
DEF SPAWN_CHILD_ENTITY_UNK0F                      EQU $12
DEF SPAWN_CHILD_ENTITY_UNK10                      EQU $13
DEF SPAWN_CHILD_ENTITY_CONVICT_PROJECTILE         EQU $14
DEF SPAWN_CHILD_ENTITY_BOMB                       EQU $15
DEF SPAWN_CHILD_ENTITY_CANNON_PROJECTILE          EQU $16
DEF SPAWN_CHILD_ENTITY_CANNON_PROJECTILE_2        EQU $17
DEF SPAWN_CHILD_ENTITY_BRAIN_OF_OZ_PROJECTILE     EQU $18
DEF SPAWN_CHILD_ENTITY_STAGE_TIMER                EQU $19
DEF SPAWN_CHILD_ENTITY_SECBOT_PROJECTILE_2        EQU $1A
DEF SPAWN_CHILD_ENTITY_GHOST_KNIGHT_PROJECTILE    EQU $1B
DEF SPAWN_CHILD_ENTITY_BIRD_PROJECTILE            EQU $1C
DEF SPAWN_CHILD_ENTITY_REZ_PROJECTILE             EQU $1D
DEF SPAWN_CHILD_ENTITY_REZ_PROJECTILE_2           EQU $1E

; Entity Facing Direction values
; really these seem to be sprite x flip flags...
DEF ENTITY_FACING_RIGHT                 EQU $00 ; also facing up
DEF ENTITY_FACING_LEFT                  EQU $20 ; also facing down
DEF ENTITY_FACING_VERTICAL_FLIP         EQU $40
DEF ENTITY_FACING_UNK_FLAG              EQU $80
DEF ENTITY_FACING_LEFT_BIT              EQU 5

; Entity position relative to Gex
DEF ENTITY_LEFT_OF_GEX       EQU $00
DEF ENTITY_RIGHT_OF_GEX      EQU $20

; Entity list flags, used in wD700_EntityFlags - one byte per entry in the level's
; entity list. High nibble = flags, low nibble = the action id the entry respawns
; with. See the wD700_EntityFlags block in memory.asm for the full story.
;
; gex2's equivalents are ENTITY_LIST_FLAG_ABSENT / _PLACED / _NEVER_AGAIN, which
; are a plain three-value enum; gex3 turned the same idea into a bitfield and gave
; $00 the "never again" meaning that gex2 spells $FF
DEF ENTITY_LIST_FLAG_ABSENT     EQU $00 ; zeroed - never spawns again (gex2: _NEVER_AGAIN)
DEF ENTITY_LIST_FLAG_PRESENT    EQU $80 ; entry exists; written for every entry when the list loads
DEF ENTITY_LIST_FLAG_PLACED     EQU $40 ; currently occupying one of the eight entity slots
DEF ENTITY_LIST_FLAG_FLY_COIN   EQU $10 ; respawn as ENTITY_FLY_COIN_SPAWN, not as the listed entity
DEF ENTITY_LIST_FLAG_MASK       EQU $F0
DEF ENTITY_LIST_STATE_MASK      EQU $0F ; the respawn action id
    DEF ENTITY_LIST_FLAG_PLACED_BIT   EQU 6
    DEF ENTITY_LIST_FLAG_FLY_COIN_BIT EQU 4

; What a defeated entity's list entry is left as when it drops a fly coin:
; still placed, and marked to come back as the coin rather than as itself
DEF ENTITY_LIST_FLAGS_DEFEATED  EQU ENTITY_LIST_FLAG_PLACED | ENTITY_LIST_FLAG_FLY_COIN

; Respawn action ids written into the low nibble from outside the entity, so that
; scenery the player has already dealt with comes back in the state it was left in
DEF ENTITY_LIST_STATE_DEFAULT       EQU $00
DEF ENTITY_LIST_STATE_TV_BUTTON_ON  EQU $01 ; tv button already pressed
DEF ENTITY_LIST_STATE_TV_BUTTON_LIT EQU $02 ; pressed, and this level's progress flag is already set
DEF ENTITY_LIST_STATE_REMOTE_TAKEN  EQU $04 ; remote already collected

; Per-level trigger scratchpad, wDCB1_LevelTriggerBuffer. The trigger helpers in
; bank00_entity_utils.asm index it with an entity's spawn parameter and ignore
; anything that does not fit
DEF LEVEL_TRIGGER_COUNT         EQU $10
DEF LEVEL_TRIGGER_SET           EQU $01
DEF LEVEL_TRIGGER_CLEAR         EQU $00

; Entity physics, as used by the movement helpers in bank00_entity_utils.asm.
; Velocities are 1/16 pixel per frame, so the movers accumulate a subpixel
; fraction and shift right four times to get whole pixels
DEF ENTITY_SUBPIXEL_SHIFT       EQU 4
DEF ENTITY_SUBPIXEL_MASK        EQU $0F
DEF ENTITY_GRAVITY_PER_FRAME    EQU $02 ; subtracted from YVEL each frame
DEF ENTITY_TERMINAL_YVEL        EQU $C0 ; -64/16 px per frame, the fastest an entity may fall

; Margins used when an entity is placed relative to the camera rather than the map
DEF ENTITY_BELOW_CAMERA_MARGIN  EQU $B0 ; call_00_2780_Entity_IsBelowCameraBottom
DEF ENTITY_ABOVE_CAMERA_MARGIN  EQU $14 ; call_00_27cb_Entity_SetYToAboveCameraTop

; The fly coin a defeated enemy leaves behind (call_00_2bbe_Entity_TurnIntoFlyCoin)
DEF FLY_COIN_SIZE               EQU $12
DEF FLY_COIN_DAMAGE_STATE       EQU $01

; Particle burst slots, wDDC4_ParticleSlot1 onwards
DEF PARTICLE_SLOT_COUNT         EQU 8
DEF PARTICLE_BURST_DURATION     EQU $40 ; frames
DEF PARTICLE_TEMPLATE_SIZE      EQU $12 ; bytes copied after the timer byte
DEF PARTICLE_BURST_PAIRS        EQU 3   ; x/y pairs stepped per frame

; One entity's CGB palette in wDD2A_EntityPalettes: four colours, two bytes each
DEF ENTITY_PALETTE_SIZE         EQU 8

; Player vs Entity interaction events
DEF PLAYER_TOUCHED_ENTITY   EQU $00
DEF PLAYER_ATTACKED_ENTITY  EQU $01
DEF PLAYER_STOMPED_ENTITY   EQU $02

; Player interactions supported by an entity
DEF ENTITY_INTERACT_NONE   EQU $00
DEF ENTITY_INTERACT_TOUCH  EQU $01
DEF ENTITY_INTERACT_ATTACK EQU $02
DEF ENTITY_INTERACT_STOMP  EQU $04

; Frame timer values
DEF TIMER_AMOUNT_0_FRAMES                  EQU $00
DEF TIMER_AMOUNT_60_FRAMES                 EQU $3C
DEF TIMER_AMOUNT_120_FRAMES                EQU $78
DEF TIMER_AMOUNT_180_FRAMES                EQU $B4
DEF TIMER_AMOUNT_240_FRAMES                EQU $F0
DEF TIMER_AMOUNT_GHOST_KNIGHT              EQU $41
DEF TIMER_AMOUNT_GHOST_KNIGHT_PROJECTILE   EQU $5A
DEF TIMER_AMOUNT_RAFT                      EQU $28
DEF TIMER_AMOUNT_SNAKE_PROJECTILE          EQU $40
DEF TIMER_AMOUNT_SECBOT                    EQU $C1
DEF TIMER_AMOUNT_SECBOT_2                  EQU $02
DEF TIMER_AMOUNT_GRENADE                   EQU $04
DEF TIMER_AMOUNT_BOMB                      EQU $2D
DEF TIMER_AMOUNT_SPIDER                    EQU $08
DEF TIMER_AMOUNT_BIRD_PROJECTILE           EQU $03
DEF TIMER_AMOUNT_BRAINOFOZ1                EQU $49
DEF TIMER_AMOUNT_BRAINOFOZ2                EQU $39
DEF TIMER_AMOUNT_BRAINOFOZ3                EQU $29
DEF TIMER_AMOUNT_CANNON                    EQU $FF
DEF TIMER_AMOUNT_REZ                       EQU $06

; Menu Types
DEF MENU_TITLE_SCREEN                     EQU $00
DEF MENU_ENTER_PASSWORD                   EQU $01
DEF MENU_SEE_PASSWORD                     EQU $02
DEF MENU_GAME_OVER                        EQU $03
DEF MENU_BAD_PASSWORD                     EQU $04
DEF MENU_MISSION_SELECT_1_REMOTE          EQU $05
DEF MENU_UNK06                            EQU $06 ; unused?
DEF MENU_MISSION_SELECT_3_REMOTES         EQU $07
DEF MENU_TOTALS                           EQU $08
DEF MENU_CONGRATULATIONS_GOT_REMOTE       EQU $09
DEF MENU_TIME_UP                          EQU $0A
DEF MENU_PAUSE_IN_GEX_CAVE                EQU $0B
DEF MENU_QUIT_GAME                        EQU $0C
DEF MENU_PAUSE_IN_LEVEL                   EQU $0D
DEF MENU_GO_TO_MAP                        EQU $0E
DEF MENU_DAVID_A_PALMER                   EQU $0F
DEF MENU_UNK10                            EQU $10 ; unused?
DEF MENU_OPENING_CREDITS_1                EQU $11
DEF MENU_OPENING_CREDITS_2                EQU $12
DEF MENU_OPENING_CRYSTAL_DYNAMICS         EQU $13
DEF MENU_EIDOS_INTERACTIVE                EQU $14
DEF MENU_END_CREDITS_1                    EQU $15
DEF MENU_END_CREDITS_2                    EQU $16
DEF MENU_END_CREDITS_3                    EQU $17
DEF MENU_END_CREDITS_4                    EQU $18
DEF MENU_END_CREDITS_5                    EQU $19
DEF MENU_END_CREDITS_6                    EQU $1A
DEF MENU_WELL_DONE                        EQU $1B

; Password validity
DEF PASSWORD_INVALID                      EQU $00
DEF PASSWORD_VALID                        EQU $20

; Sound Effects
DEF SFX_EMPTY                              EQU $00
DEF SFX_MENU_SCROLL                        EQU $01
DEF SFX_ITEM_PICKUP                        EQU $02 ; fly coins, paw coins, bonus coins
DEF SFX_FLY_TV                             EQU $03
DEF SFX_GEX_TAIL_SPIN                      EQU $04
DEF SFX_UNK05                              EQU $05 ; unknown, but sounds similar to tail spin?
DEF SFX_GEX_JUMP                           EQU $06
DEF SFX_GEX_DOUBLE_JUMP                    EQU $07
DEF SFX_UNK08                              EQU $08 ; hit something with tail maybe?
DEF SFX_UNK09                              EQU $09
DEF SFX_PLAYER_DAMAGED                     EQU $0A
DEF SFX_UNK0B                              EQU $0B
DEF SFX_UNK0C                              EQU $0C
DEF SFX_UNK0D                              EQU $0D
DEF SFX_GEX_SPAWN                          EQU $0E
DEF SFX_ENEMY_DAMAGED                      EQU $0F
DEF SFX_ENEMY_KILLED                       EQU $10
DEF SFX_UNK11                              EQU $11
DEF SFX_UNK12                              EQU $12
DEF SFX_METEOR                             EQU $13
DEF SFX_CANNON                             EQU $14
DEF SFX_BRAIN_OF_OZ                        EQU $15
DEF SFX_UNK16                              EQU $16
DEF SFX_UNK17                              EQU $17
DEF SFX_DOOR1                              EQU $18
DEF SFX_SMALL_BANG                         EQU $19 ; misc
DEF SFX_LOUD_BANG                          EQU $1A ; boss deaths, TutTV block
DEF SFX_DOOR2                              EQU $1B ; also used by cannon?
DEF SFX_BOMB                               EQU $1C
DEF SFX_UNK1D                              EQU $1D
DEF SFX_REMOTE                             EQU $1E
DEF SFX_UNK1F                              EQU $1F
DEF SFX_NONE                               EQU $FF ; no sfx queued

; Songs
DEF SONG_EMPTY                             EQU $00
DEF SONG_UNK01                             EQU $01
DEF SONG_HOLIDAY_TV                        EQU $02
DEF SONG_WESTERN_STATION                   EQU $03
DEF SONG_GEX_CAVE                          EQU $04
DEF SONG_TUT_TV                            EQU $05
DEF SONG_UNK06                             EQU $06 ; unused?
DEF SONG_UNK07                             EQU $07 ; unused?
DEF SONG_UNK08                             EQU $08 ; unused?
DEF SONG_UNK09                             EQU $09 ; unused?
DEF SONG_UNK0A                             EQU $0A ; unused?
DEF SONG_UNK0B                             EQU $0B ; unused?
DEF SONG_UNK0C                             EQU $0C ; unused?
DEF SONG_UNK0D                             EQU $0D ; unused?
DEF SONG_UNK0E                             EQU $0E ; unused?
DEF SONG_UNK0F                             EQU $0F ; unused?
DEF SONG_UNK10                             EQU $10 ; unused?
DEF SONG_BOSS                              EQU $11
DEF SONG_MYSTERY_TV                        EQU $12
DEF SONG_MISSION_SUCCESS                   EQU $13 ; used when you get a remote or complete a bonus level
DEF SONG_ANIME_CHANNEL                     EQU $14
DEF SONG_GAME_OVER_OR_TIME_UP              EQU $15
DEF SONG_BONUS_CHANNEL                     EQU $16
DEF SONG_SUPERHERO_SHOW                    EQU $17
DEF SONG_CHANNEL_Z                         EQU $18
DEF SONG_CREDITS                           EQU $19
DEF SONG_NONE                              EQU $FF

; Entity Collision Types
DEF COLLISION_TYPE_NONE                      EQU $00
DEF COLLISION_TYPE_PLATFORM                  EQU $01
DEF COLLISION_TYPE_INVULNERABLE_ENEMY        EQU $02 ; player can be damaged by this entity, but cannot damage it
DEF COLLISION_TYPE_PROJECTILE                EQU $03 ; the entity is destroyed after damaging player 
DEF COLLISION_TYPE_GENERIC_ENEMY             EQU $04 ; the entity remains after damaging player. player can damage this enemy.
DEF COLLISION_TYPE_GENERIC_ENEMY_UNUSED      EQU $05 ; seems unused
DEF COLLISION_TYPE_DAMAGE_PLAYER_UNUSED      EQU $06 ; seems unused
DEF COLLISION_TYPE_BONUS_COIN                EQU $07
DEF COLLISION_TYPE_FLY_COIN                  EQU $08
DEF COLLISION_TYPE_PAW_COIN                  EQU $09
DEF COLLISION_TYPE_FLY                       EQU $0A
DEF COLLISION_TYPE_FLY_TV                    EQU $0B
DEF COLLISION_TYPE_ICE_SCULPTURE             EQU $0C
DEF COLLISION_TYPE_EVIL_SANTA_PROJECTILE     EQU $0D
DEF COLLISION_TYPE_ELF            EQU $0E
DEF COLLISION_TYPE_BLOOD_COOLER              EQU $0F
DEF COLLISION_TYPE_MAGIC_SWORD               EQU $10
DEF COLLISION_TYPE_GHOST_KNIGHT              EQU $11
DEF COLLISION_TYPE_HAND                      EQU $12
DEF COLLISION_TYPE_LOST_ARK                  EQU $13
DEF COLLISION_TYPE_RA_STAFF                  EQU $14
DEF COLLISION_TYPE_COFFIN                    EQU $15
DEF COLLISION_TYPE_ALIEN_CULTURE_TUBE        EQU $16
DEF COLLISION_TYPE_ON_SWITCH                 EQU $17
DEF COLLISION_TYPE_OFF_SWITCH                EQU $18
DEF COLLISION_TYPE_ON_SWITCH_2               EQU $19
DEF COLLISION_TYPE_DOOR                      EQU $1A
DEF COLLISION_TYPE_DOOR_2                    EQU $1B
DEF COLLISION_TYPE_SECBOT                    EQU $1C
DEF COLLISION_TYPE_SAILOR_TOON_GIRL          EQU $1D
DEF COLLISION_TYPE_BIG_SILVER_ROBOT          EQU $1E
DEF COLLISION_TYPE_MECH                      EQU $1F
DEF COLLISION_TYPE_PLANET_O_BLAST            EQU $20
DEF COLLISION_TYPE_STRAY_CAT                 EQU $21
DEF COLLISION_TYPE_CONVICT                   EQU $22
DEF COLLISION_TYPE_YELLOW_GOON               EQU $23
DEF COLLISION_TYPE_CHOMPER_TV                EQU $24
DEF COLLISION_TYPE_BOMB                      EQU $25
DEF COLLISION_TYPE_WATER_TOWER_STAND         EQU $26
DEF COLLISION_TYPE_GEXTREME_SPORTS_ELF       EQU $27
DEF COLLISION_TYPE_BONUS_TIME_COIN           EQU $28
DEF COLLISION_TYPE_BELL                      EQU $29
DEF COLLISION_TYPE_CANNON                    EQU $2A
DEF COLLISION_TYPE_BRAIN_OF_OZ               EQU $2B
DEF COLLISION_TYPE_BRAIN_OF_OZ_PROJECTILE    EQU $2C
DEF COLLISION_TYPE_FREESTANDING_REMOTE       EQU $2D
DEF COLLISION_TYPE_CACTUS                    EQU $2E
DEF COLLISION_TYPE_PLAYING_CARD              EQU $2F
DEF COLLISION_TYPE_HARD_HAT                  EQU $30
DEF COLLISION_TYPE_METEOR                    EQU $31
DEF COLLISION_TYPE_REZ                       EQU $32
DEF COLLISION_TYPE_TV_BUTTON                 EQU $33
DEF COLLISION_TYPE_RA_STATUE_PROJECTILE      EQU $34
DEF COLLISION_TYPE_ROCK_HARD                 EQU $35
DEF COLLISION_TYPE_UNK_PLATFORM_FLAG         EQU $80

; Bg Collision Types
DEF BG_COLLISION_TYPE_SIDESCROLLER  EQU $00
DEF BG_COLLISION_TYPE_TOPDOWN       EQU $01

; Player Actions
DEF PLAYERACTION_SPAWN                                   EQU $00
DEF PLAYERACTION_IDLE                                    EQU $01
DEF PLAYERACTION_IDLE_ANIMATION                          EQU $02
DEF PLAYERACTION_WALK                                    EQU $03
DEF PLAYERACTION_START_CROUCH                            EQU $04
DEF PLAYERACTION_CROUCH_LOOK_DOWN                        EQU $05
DEF PLAYERACTION_NONE_0                                  EQU $06
DEF PLAYERACTION_UNK7                                    EQU $07
DEF PLAYERACTION_EAT_FLY                                 EQU $08
DEF PLAYERACTION_TAKE_DAMAGE                             EQU $09
DEF PLAYERACTION_DEATH                                   EQU $0A
DEF PLAYERACTION_DEATH_SET_UP_WARP                       EQU $0B
DEF PLAYERACTION_STAND_ON_TV_BUTTON                      EQU $0C
DEF PLAYERACTION_ENTER_TV                                EQU $0D
DEF PLAYERACTION_JUMP                                    EQU $0E
DEF PLAYERACTION_DOUBLE_JUMP                             EQU $0F
DEF PLAYERACTION_TAIL_SPIN                               EQU $10
DEF PLAYERACTION_FALL                                    EQU $11
DEF PLAYERACTION_LAND_FROM_FALL                          EQU $12
DEF PLAYERACTION_UNK19                                   EQU $13
DEF PLAYERACTION_ENTER_IDLE                              EQU $14
DEF PLAYERACTION_NONE_1                                  EQU $15
DEF PLAYERACTION_NONE_2                                  EQU $16
DEF PLAYERACTION_NONE_3                                  EQU $17
DEF PLAYERACTION_NONE_4                                  EQU $18
DEF PLAYERACTION_WATER_SWIMMING                          EQU $19
DEF PLAYERACTION_DEATH_IN_PIT_ALT                        EQU $1A
DEF PLAYERACTION_DEATH_IN_PIT                            EQU $1B
DEF PLAYERACTION_NONE_5                                  EQU $1C
DEF PLAYERACTION_BLOWN_UPWARDS                           EQU $1D
DEF PLAYERACTION_RIDING_ELEVATOR                         EQU $1E
DEF PLAYERACTION_WATER_TAIL_SPIN                         EQU $1F
DEF PLAYERACTION_WATER_TREADING                          EQU $20
DEF PLAYERACTION_WATER_DIVING                            EQU $21
DEF PLAYERACTION_CLIMBING                                EQU $22
DEF PLAYERACTION_SNOWBOARDING_SPAWN                      EQU $23
DEF PLAYERACTION_SNOWBOARDING_STAND_OR_WALK              EQU $24
DEF PLAYERACTION_SNOWBOARDING_JUMP                       EQU $25
DEF PLAYERACTION_SNOWBOARDING_DOUBLE_JUMP                EQU $26
DEF PLAYERACTION_SNOWBOARDING_TAIL_SPIN                  EQU $27
DEF PLAYERACTION_SNOWBOARDING_FALL                       EQU $28
DEF PLAYERACTION_SNOWBOARDING_TAKE_DAMAGE                EQU $29
DEF PLAYERACTION_SNOWBOARDING_DIE                        EQU $2A
DEF PLAYERACTION_SNOWBOARDING_DIE_WARP                   EQU $2B
DEF PLAYERACTION_SNOWBOARDING_STAND_ON_TV_BUTTON         EQU $2C
DEF PLAYERACTION_SNOWBOARDING_ENTER_TV                   EQU $2D
DEF PLAYERACTION_SNOWBOARDING_DEATH_IN_PIT_ALT           EQU $2E
DEF PLAYERACTION_KANGAROO_SPAWN                          EQU $2F
DEF PLAYERACTION_KANGAROO_IDLE                           EQU $30
DEF PLAYERACTION_KANGAROO_HOPPING                        EQU $31
DEF PLAYERACTION_KANGAROO_START_JUMP                     EQU $32
DEF PLAYERACTION_KANGAROO_JUMP                           EQU $33
DEF PLAYERACTION_KANGAROO_TAIL_SPIN                      EQU $34
DEF PLAYERACTION_KANGAROO_FALL                           EQU $35
DEF PLAYERACTION_KANGAROO_TAKE_DAMAGE                    EQU $36
DEF PLAYERACTION_KANGAROO_DEATH                          EQU $37
DEF PLAYERACTION_KANGAROO_DEATH_SET_UP_WARP              EQU $38
DEF PLAYERACTION_KANGAROO_STAND_ON_TV_BUTTON             EQU $39
DEF PLAYERACTION_KANGAROO_ENTER_TV                       EQU $3A
DEF PLAYERACTION_KANGAROO_DEATH_IN_PIT_ALT               EQU $3B
DEF PLAYERACTION_TOPDOWN_SPAWN                           EQU $3C
DEF PLAYERACTION_TOPDOWN_IDLE                            EQU $3D
DEF PLAYERACTION_TOPDOWN_IDLE_ANIMATION                  EQU $3E
DEF PLAYERACTION_TOPDOWN_WALK                            EQU $3F
DEF PLAYERACTION_TOPDOWN_START_CROUCH                    EQU $40
DEF PLAYERACTION_TOPDOWN_NONE_CROUCH                     EQU $41
DEF PLAYERACTION_TOPDOWN_NONE_0                          EQU $42
DEF PLAYERACTION_TOPDOWN_UNK7                            EQU $43
DEF PLAYERACTION_TOPDOWN_EAT_FLY                         EQU $44
DEF PLAYERACTION_TOPDOWN_TAKE_DAMAGE                     EQU $45
DEF PLAYERACTION_TOPDOWN_DEATH                           EQU $46
DEF PLAYERACTION_TOPDOWN_DEATH_SET_UP_WARP               EQU $47
DEF PLAYERACTION_TOPDOWN_STAND_ON_TV_BUTTON              EQU $48
DEF PLAYERACTION_TOPDOWN_ENTER_TV                        EQU $49
DEF PLAYERACTION_TOPDOWN_JUMP                            EQU $4A
DEF PLAYERACTION_TOPDOWN_DOUBLE_JUMP                     EQU $4B
DEF PLAYERACTION_TOPDOWN_TAIL_SPIN                       EQU $4C
DEF PLAYERACTION_TOPDOWN_FALL                            EQU $4D
DEF PLAYERACTION_TOPDOWN_LAND_FROM_FALL                  EQU $4E
DEF PLAYERACTION_TOPDOWN_UNK19                           EQU $4F
DEF PLAYERACTION_TOPDOWN_ENTER_IDLE                      EQU $50
DEF PLAYERACTION_TOPDOWN_NONE_1                          EQU $51
DEF PLAYERACTION_TOPDOWN_NONE_2                          EQU $52
DEF PLAYERACTION_TOPDOWN_NONE_3                          EQU $53
DEF PLAYERACTION_TOPDOWN_NONE_4                          EQU $54
DEF PLAYERACTION_TOPDOWN_WATER_SWIMMING                  EQU $55
DEF PLAYERACTION_TOPDOWN_DEATH_IN_PIT_ALT                EQU $56
DEF PLAYERACTION_TOPDOWN_DEATH_IN_PIT                    EQU $57
DEF PLAYERACTION_TOPDOWN_NONE_5                          EQU $58
DEF PLAYERACTION_TOPDOWN_BLOWN_UPWARDS                   EQU $59
DEF PLAYERACTION_TOPDOWN_RIDING_ELEVATOR                 EQU $5A
DEF PLAYERACTION_TOPDOWN_WATER_TAIL_SPIN                 EQU $5B
DEF PLAYERACTION_TOPDOWN_WATER_TREADING                  EQU $5C
DEF PLAYERACTION_TOPDOWN_WATER_DIVING                    EQU $5D
DEF PLAYERACTION_TOPDOWN_CLIMBING                        EQU $5E
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_SPAWN              EQU $5F
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_STAND_OR_WALK      EQU $60
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_JUMP               EQU $61
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DOUBLE_JUMP        EQU $62
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_TAIL_SPIN          EQU $63
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_FALL               EQU $64
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_TAKE_DAMAGE        EQU $65
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DIE                EQU $66
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DIE_WARP           EQU $67
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_STAND_ON_TV_BUTTON EQU $68
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_ENTER_TV           EQU $69
DEF PLAYERACTION_TOPDOWN_SNOWBOARDING_DEATH_IN_PIT_ALT   EQU $6A
DEF PLAYERACTION_TOPDOWN_KANGAROO_SPAWN                  EQU $6B
DEF PLAYERACTION_TOPDOWN_KANGAROO_IDLE                   EQU $6C
DEF PLAYERACTION_TOPDOWN_KANGAROO_HOPPING                EQU $6D
DEF PLAYERACTION_TOPDOWN_KANGAROO_START_JUMP             EQU $6E
DEF PLAYERACTION_TOPDOWN_KANGAROO_JUMP                   EQU $6F
DEF PLAYERACTION_TOPDOWN_KANGAROO_TAIL_SPIN              EQU $70
DEF PLAYERACTION_TOPDOWN_KANGAROO_FALL                   EQU $71
DEF PLAYERACTION_TOPDOWN_KANGAROO_TAKE_DAMAGE            EQU $72
DEF PLAYERACTION_TOPDOWN_KANGAROO_DEATH                  EQU $73
DEF PLAYERACTION_TOPDOWN_KANGAROO_DEATH_SET_UP_WARP      EQU $74
DEF PLAYERACTION_TOPDOWN_KANGAROO_STAND_ON_TV_BUTTON     EQU $75
DEF PLAYERACTION_TOPDOWN_KANGAROO_ENTER_TV               EQU $76
DEF PLAYERACTION_TOPDOWN_KANGAROO_DEATH_IN_PIT_ALT       EQU $77
DEF PLAYERACTION_NONE_PENDING                            EQU $FF
DEF PLAYERACTION_OFFSET_TOPDOWN                          EQU $3C

; Player Action State flags
DEF PLAYER_STATE_UNK01      EQU 0
DEF PLAYER_STATE_UNK02      EQU 1
DEF PLAYER_STATE_UNK04      EQU 2
DEF PLAYER_STATE_DEAD       EQU 3
DEF PLAYER_STATE_UNK10      EQU 4 ; unused?
DEF PLAYER_STATE_IN_WATER   EQU 5
DEF PLAYER_STATE_UNK40      EQU 6 ; unused?
DEF PLAYER_STATE_CLIMBING   EQU 7

DEF PLAYER_STATE_NONE_MASK      EQU $00
DEF PLAYER_STATE_UNK01_MASK     EQU $01
DEF PLAYER_STATE_UNK02_MASK     EQU $02
DEF PLAYER_STATE_UNK04_MASK     EQU $04
DEF PLAYER_STATE_DEAD_MASK      EQU $08
DEF PLAYER_STATE_UNK10_MASK     EQU $10 ; unused?
DEF PLAYER_STATE_IN_WATER_MASK  EQU $20
DEF PLAYER_STATE_UNK40_MASK     EQU $40 ; unused?
DEF PLAYER_STATE_CLIMBING_MASK  EQU $80

; Entity Action Ids
DEF ENTITYACTION_PENGUIN_WALK_OR_RUN             EQU $00
DEF ENTITYACTION_PENGUIN_JUMP                    EQU $01
