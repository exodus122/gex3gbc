SECTION "wram0", WRAM0[$c000]

wC000_BgMapTileIds:
; $C000-$C3FF is the 32x32-entry shadow of the BG tilemap at $9800, one byte per
; tile, addressed exactly like VRAM: the loaders take the tilemap address they
; are writing ($98xx-$9Bxx), mask the high byte with $03 and add $C0.
;
; During call_00_1056_BgMap_LoadFull this buffer is filled and flushed three
; times over, once per pass of call_00_1a22_BgMap_LoadAllRowsForPass - see
; wDC33_BgMap_InitialLoadPass. The first two passes are HDMA'd out to VRAM
; (attributes to bank 1, tile ids to bank 0) by config entries 7 and 8 of
; .data_00_0aa9_HdmaConfigTable; the third pass leaves the map's
; COLLISION tile ids sitting here, and they stay for the life of the map.
;
; So in gameplay this is the current collision map - the gex2 equivalent is
; wC800_CurrentCollisionData - and it is what call_03_4b4c_BgCollision_IsPixelSolid
; reads before indexing wC400_CollisionTilesetData. The scroll loaders keep it
; in step with the camera the same way they keep the tilemap in step.
; The menus reuse the same 1KB as a plain tilemap staging area, which is where
; the label's name comes from
    ds 1024                                            ;; c000

wC400_CollisionTilesetData: ; C400-CC00 is a copy of 03:4100-03:48FF but in a different order
; that is the collision tileset data, collectible sprites, and number sprites, and some code
    ds 1408                                            ;; c400

wC980_NumberSprites: ; this is the start of the number sprites copied from bank 3
    ds 896                                             ;; c980

wCD00_RowOffsetTableForMap:
; 256 entries of "byte offset of map row N", built by
; call_00_10c7_BgMap_BuildRowOffsetTable as N * wDC1C_CurrentMapWidthAndHeightInBlocks.
; Stored split, low bytes at $CD00+N and high bytes at $CE00+N, so a lookup is
; `ld L,row / ld H,HIGH(wCD00...) / ld E,[HL] / inc H / ld D,[HL]`.
;
; This table is the price of gex3's variable map sizes. gex2 hardcodes a
; 128-block-wide blockmap, so it can reach a row with three `add HL,HL` shifts;
; gex3 maps are each their own width, so every row start is precomputed once at
; load time and every strip loader indexes this instead of multiplying
    ds 512                                             ;; cd00

; ------------------------------------------------------------------
; BG map strip scratch, $CF00-$CFFF. The strip loaders never write VRAM
; directly - they assemble 11 blocks worth of tile ids and GBC attribute bytes
; here, then call_00_0b9f_VBlank_UpdateVRAM flushes the pair to the
; tilemap during vblank (call_03_75e3_VRAM_WriteBgMapRow for a row,
; call_03_7664_VRAM_WriteBgMapColumn for a column). gex2 has no
; equivalent - it writes tiles into VRAM inside the loader itself.
;
; The row halves are indexed by wDC25_BgMap_ScratchRowOffset and the column
; halves by wDC26_BgMap_ScratchColumnOffset; both wrap inside their own 32-byte
; window with `res 5`, so the buffers behave as rings that track the camera.
; ------------------------------------------------------------------
wCF00_TileScratchBuffers:
wCF00_BgMap_TempScratchRowTileIds:
; Row strip, tile ids. Filled twice per strip: first with the block ids
; themselves (low byte from the map data, high byte from the extended map data,
; interleaved as id-lo/id-hi pairs), then overwritten in place with the two tile
; ids the blockset expands each of those blocks into
    ds 64                                              ;; cf00
wCF40_BgMap_TempScratchColumnTileIds:
; Column strip, tile ids. Same two-stage use as the row buffer above
    ds 64                                              ;; cf40
wCF80_BgMap_TempScratchRowAttributes:
; Row strip, GBC attribute bytes (palette id, tile flips, VRAM bank) for the
; tile ids in wCF00_BgMap_TempScratchRowTileIds. Written from bytes 4-7 of the
; blockset entry while the ids come from bytes 0-3
    ds 64                                              ;; cf80
wCFC0_BgMap_TempScratchColumnAttributes:
; Column strip, GBC attribute bytes
    ds 64                                              ;; cfc0

; ------------------------------------------------------------------
; The current level's collectibles, built once by
; call_00_2f85_CollectibleList_LoadForCurrentLevel and read every frame by
; call_03_615d_Collectible_BuildSprites.
;
; Positions are in 16x16 grid cells, not pixels, which is why 128 entries per level
; is enough and why the draw multiplies by 16 with a `swap`. The three parallel
; arrays are indexed together; the two lookup tables below them are indexed by camera
; column instead, and exist so the draw never walks the list.
;
; gex2's equivalents are wC400_Collectible_GridX / wC500_Collectible_GridY /
; wC600_Collectible_ScanStartByColumn / wC700_Collectible_ScanCountByColumn. gex3
; adds the map id, because a gex3 level is many maps
; ------------------------------------------------------------------
wD000_CollectibleUnusedMemory:
; Never written and never read - the load pass fills from wD080 up
    ds 128                                             ;; d000
wD080_Collectible_MapIds:
; Which map of the level each collectible belongs to. The draw skips any entry whose
; id is not wDB6C_CurrentMapId
    ds 128                                             ;; d080
wD100_Collectible_GridX:
; Grid column, ascending - the lists are authored sorted, which is what makes the
; per-column index below correct. COLLECTIBLE_LIST_END marks the end
    ds 128                                             ;; d100
wD180_Collectible_GridY:
; Grid row. Set to COLLECTIBLE_TAKEN when picked up, which is also how a collected
; item stays collected for the rest of the level
    ds 128
wD200_Collectible_ScanStartByColumn:
; For each of the 256 camera columns, the index of the first collectible at or beyond
; it - a lower bound the draw starts scanning from
    ds 256                                             ;; d200
wD300_Collectible_ScanCountByColumn:
; And how many entries from there fall within COLLECTIBLE_COLUMNS_ON_SCREEN. Zero
; here means the draw returns immediately, which is the common case
    ds 256                                             ;; d300

wD400_ScreenDraw_TileIds:
    ds 376                                               ;; d400
wD578_ScreenDraw_PaletteIds:
    ds 392                                               ;; d578

wD700_EntityFlags:
; One byte per entry in the level's entity list - the persistent, per-list-entry
; state that survives an entity leaving its slot, and the thing that decides
; whether call_00_3618_EntitySpawn_SpawnNextFromList is allowed to place that entry at all.
; Indexed by the 1-based list index, so wD700 itself is never a real entry.
;
; The byte is split in two. The high nibble is flags:
;
;   ENTITY_LIST_FLAG_PRESENT  ($80)  written for every entry when the list is
;                                    loaded; just means "this entry exists"
;   ENTITY_LIST_FLAG_PLACED   ($40)  currently occupying one of the eight slots.
;                                    The spawner refuses to place an entry that
;                                    already has it, and call_00_2b5d_Entity_ClearSlot
;                                    clears it again when the slot is freed
;   ENTITY_LIST_FLAG_FLY_COIN ($10)  respawn this entry as ENTITY_FLY_COIN_SPAWN
;                                    instead of whatever the list says. Set by
;                                    call_00_2ba9_Entity_MarkRespawnAsFlyCoin when a
;                                    defeated enemy leaves a fly coin behind
;
; ENTITY_LIST_FLAG_ABSENT ($00) is the whole byte being zero, and it is the one
; the spawner tests first: a zeroed entry never comes back. That makes it gex3's
; equivalent of gex2's ENTITY_LIST_FLAG_NEVER_AGAIN ($FF) rather than of gex2's
; ENTITY_LIST_FLAG_ABSENT, and call_00_2b94_Entity_MarkNeverRespawn is what writes it.
;
; The low nibble (ENTITY_LIST_STATE_MASK) is a spawn action id: the spawner passes
; it straight to call_02_72ac_Entity_SetAction, so an entry can be brought back in a
; different state from the one it was first placed in. That is how a pressed tv
; button stays pressed and a collected remote stays collected across a map change -
; see call_00_21f6_Entity_MarkTVButtonPressed and
; call_00_2260_Entity_MarkRemoteCollected, which write it from outside the entity,
; and call_00_2299_Entity_SetListState, which writes it from the entity itself.
;
; gex2's equivalent is wD000_EntityFlags, which is a plain enum with three values
; and no state nibble
    ds 256

; From D800 to D900 is the loaded entities space
; There are 8 instances of 0x20 bytes each. 
; Entity Instance Struct is defined in constants.asm
wD800_EntityMemory:
wD800_Player_Id:
    ds 1                                               ;; d800
wD801_Player_ActionId:
    ds 1                                               ;; d801
wD802_Player_ActionFunc:
    ds 3                                               ;; d802
wD805_Player_ActionState:
    ds 4                                               ;; d805
wD809_Player_SpriteCounter:
    ds 1                                               ;; d809
wD80A_Player_SpriteId:
    ds 3                                               ;; d80a
wD80D_PlayerFacingDirection:
    ds 1                                               ;; d80d
wD80E_PlayerXPosition:
    ds 2                                               ;; d80e
wD810_PlayerYPosition:
    ds 2                                               ;; d810
    ds 14                                              ;; d811
; The seven non-player slots. Two labels point into this area because the code
; does not agree on where "not the player" starts: the slot clearers and the
; sprite builder begin at wD820, while the id searches in bank00_entity_utils.asm
; begin at wD840 and never look at slot 1
wD820_EntityMemoryAfterPlayer:
    ds 32                                              ;; d820
wD840_EntityMemoryAfterPlayer:
    ds 32                                              ;; d840
    ds 32 
    ds 32 
    ds 32 
    ds 32 
    ds 32 
; End of Loaded Entities space

; ------------------------------------------------------------------
; Shadow OAM. call_00_0e29_OamDmaRoutine, which runs from HRAM at
; hFF80_OamDmaRoutine, DMAs SHADOW_OAM_SIZE bytes from here into OAM at the top
; of every vblank, so this is the sprite list every drawing routine writes to.
; gex2 keeps the same thing at wCC00_ShadowOAM
; ------------------------------------------------------------------
wD900_ShadowOAM:
; sprite 0 - the first byte the DMA moves, and the one
; call_00_0e62_ClearShadowOamAndResetScroll seeds when it wipes the list
    ds 1                                               ;; d900
wD901_ShadowOAM_EntitySprites:
    ds 3                                               ;; d901
wD904:
    ds 156                                             ;; d904

; ------------------------------------------------------------------
; The LCD STAT handler, and the vblank hook that pairs with it.
;
; isrLCDC at $0048 is a bare `jp wD9A0_LcdIsrCode`, so the handler is not fixed
; code but a template copied here by call_00_0c1b_InstallLcdIsr out of
; .data_00_0c44_LcdIsrTable. The bytes just past the copied template are that
; handler's vblank hook, and land in wD9FE_VBlankHookPtrLo.
;
; Exactly gex2's arrangement at wCCA0_LcdIsrCode / wCCFD_LcdIsrId, except that
; gex3 never patches the installed template in place - it has no hblank tile
; streamer to arm and disarm, because HDMA does that work here
; ------------------------------------------------------------------
wD9A0_LcdIsrCode:
    ds 93                                              ;; d9a0
wD9FD_LcdIsrId:
; the installed handler, one of the LCD_ISR_* ids. Bit 7 (LCD_ISR_INSTALLED) is
; set once call_00_0c1b_InstallLcdIsr has copied it in; storing an id with that
; bit clear is how call_00_0c10_RequestLcdIsr asks for a different one
    ds 1                                               ;; d9fd
wD9FE_VBlankHookPtrLo:
; called once per vblank by call_00_0b25_VBlank_Handler - the routine that
; belongs to the installed handler
    ds 1                                               ;; d9fe
wD9FF_VBlankHookPtrHi:
    ds 1                                               ;; d9ff

; DA00 through DA13 stores temporary information about the currently updating entity, or used by that entity
wDA00_CurrentEntityAddrLo:
; if the entity instance starts at $D8E0, this value is E0, for example
    ds 1                                               ;; da00
wDA01_EntityListIndexesForCurrentEntities:
; stores the entry number in the entity list, of all the currently loaded entities
; the values stored here have 1 added to them though. so index 0 would have value 1 here
    ds 8                                               ;; da01
wDA09_LoadedEntityIdsBackupBuffer:
    ds 8                                               ;; da09
wDA11_EntityXDistFromPlayer:
; The distance between the player and the current entity
    ds 1                                               ;; da11
wDA12_EntityDirectionRelativeToPlayer:
; The direction of the current entity relative to the player
; 0x00 (ENTITY_LEFT_OF_GEX) = entity is to the left of the player
; 0x20 (ENTITY_RIGHT_OF_GEX) = entity is to the right of the player
    ds 1                                               ;; da12
wDA13_EntityXVelocityDelta:
; How much the X Velocity of the current entity has changed/(will change?) by
    ds 1                                               ;; da13

; Camera position
wDA14_CameraPos_Left:
    ds 2                                               ;; da14
wDA16_CameraPos_Right:
    ds 2                                               ;; da16
wDA18_CameraPos_Top:
    ds 2                                               ;; da18
wDA1A_CameraPos_Bottom:
    ds 2                                               ;; da1a

; DA1C through DA9B is memory storing constants for each loaded entity (8 instances of size 0x10)
; 12 bytes are copied from the entity spawn data, but in a different order
; 0x0 wDA1C_EntityBoundingBoxXMax
; 0x2 wDA1E_EntityBoundingBoxXMin
; 0x4 wDA20_EntityBoundingBoxYMax
; 0x6 wDA22_EntityBoundingBoxYMin
; 0x8 wDA24_EntityInitialXPos
; 0xA wDA26_EntityInitialYPos
; 0xC DA28 - unused
; 0xE DA2A - unused
;
; This is the entity's patrol range, not its hitbox: it is the box the entity is
; allowed to move inside, and the bounds getters in bank00_entity_utils.asm read
; from here. Unlike gex2, which stores one byte per bound in block units and
; multiplies by 32 on every read, gex3 stores all four as 16-bit pixel positions
; already scaled, by the spawn-record copy inside
; call_00_3618_EntitySpawn_SpawnNextFromList.
;
; Note the Y pair: larger Y is lower on the screen, so wDA20 - the one the "move
; down until you stop" helpers clamp against - is the FLOOR and therefore the
; maximum. The ordering is XMax, XMin, YMax, YMin, exactly as in gex2's
; wD309_EntityBoundingBoxXMax..wD30C_EntityBoundingBoxYMin
wDA1C_EntityBoundingBoxXMax:
    ds 2                                               ;; da1c
wDA1E_EntityBoundingBoxXMin:
    ds 2                                               ;; da1e
wDA20_EntityBoundingBoxYMax:
    ds 2                                               ;; da20
wDA22_EntityBoundingBoxYMin:
    ds 2                                               ;; da22
wDA24_EntityInitialXPos:
    ds 2                                               ;; da24
wDA26_EntityInitialYPos:
    ds 2
    ds 4

    ds 16                                            ;; da26
    ds 16
    ds 16
    ds 16
    ds 16
    ds 16
    ds 16
; end extra entity memory

wDA9C_EntityScreenPos:
; Two bytes per entity slot - screen X then screen Y - written by
; call_03_5fc2_Entity_BuildSprites as it works out where the slot lands this frame,
; and zeroed for a slot it decides is off screen. The collision code in bank 3 reads
; it back rather than redoing the world-minus-camera subtraction
    ds 16                                              ;; da9c

wDAAC_CameraXHi: ; Camera X position related
    ds 1                                               ;; daac
wDAAD_CameraYHi: ; Camera Y position related
    ds 1                                               ;; daad

wDAAE_EntityPaletteIds:
; One byte per loaded slot: which of the eight-byte palettes in
; wDD2A_EntityPalettes this entity draws with. call_00_2c0f_Entity_AssignPaletteId
; writes it and call_00_2c20_Entity_CopyPaletteToBuffer uses it to find the palette
; to overwrite, so an entity can carry its own colours rather than borrowing the
; level's. gex2 has no equivalent - there the per-entity colour is just the OBJ
; palette number in wD32D_Entity_OamAttrBase
    ds 8                                               ;; daae
wDAB6_Oam_Attributes:
; The OAM attribute byte for the entity being drawn right now: its palette id from
; wDAAE_EntityPaletteIds OR'd with its own facing byte, so the facing bits double as
; the X and Y flip bits. Built once at the top of
; call_03_5fc2_Entity_BuildSprites and then OR'd into every attribute byte that
; entity writes. gex2 keeps the same thing in wD335_Entity_OamAttr
    ds 1                                               ;; dab6
wDAB7_Particle_TileId:
; The tile a particle burst is drawn with this frame, picked from its age through
; .data_03_6140_ParticleTileByAge - so the burst shrinks as it gets older without
; any per-particle animation state
    ds 1                                               ;; dab7
wDAB8_EntityCounter:
; this starts at 1 and goes up by 1 for each entity in the entity list for this level
    ds 1                                               ;; dab8
wDAB9_NextAvailableEntitySlot:
; starts at 7 if no entities are currently loaded, then goes to 6 if one is, and so on
    ds 1                                               ;; dab9
wDABA_EntityCounterRelated:
    ds 1                                               ;; daba
wDABB_CurrentEntityId:
    ds 1                                               ;; dabb
wDABC_CurrentEntityFlags:
; from table at $D700(-$D7FF?)
; default value is $80 on initialization
    ds 1                                               ;; dabc

; ------------------------------------------------------------------
; What background collision decided this frame. See code/bank03_bg_collision.asm
; ------------------------------------------------------------------
wDABD_CollisionFlagsPrev:
; last frame's wDABE_CollisionFlags, rolled over at the top of every handler so
; the player code can tell a landing from having already been grounded
    ds 1                                               ;; dabd
wDABE_CollisionFlags:
; BGCOLL_NO_COLLISION_BIT - grounded, or otherwise not to be corrected
; BGCOLL_WALL_BIT         - ran into a wall this frame
; BGCOLL_SLOPE_MASK       - low nibble, pixels of slope to step up
    ds 1                                               ;; dabe

; ------------------------------------------------------------------
; Gex's own tile graphics, as HDMA parameters. All three are filled in by
; call_00_0513_Screen_PresentAndDrawEntities and by the player action code out
; of the bank $7F sprite tables, and consumed by
; call_00_0c6a_VBlank_StartPendingHdma under GFX_XFER_PLAYER_GFX.
; gex2's equivalent is the GFX_XFER_PLAYER_GFX path in
; call_00_08fc_StageNextGfxTransfer, which reads wD208_Player_SpriteID instead
; ------------------------------------------------------------------
wDABF_PlayerGfx_SrcBank:
    ds 1                                               ;; dabf

wDAC0_PlayerGfx_SrcAddr:
    ds 2                                               ;; dac0
wDAC2_PlayerGfx_TileCount:
; in 32-byte units: the transfer is (count * 2 - 1) HDMA blocks of 16 bytes
    ds 1                                               ;; dac2

wDAC3_BankStack:
    ds 16                                              ;; dac3
wDAD3_PtrToBankStackPosition:
    ds 2                                               ;; dad3
wDAD5_CurrentROMBank:
    ds 1                                               ;; dad5
wDAD6_ReturnBank:
    ds 1                                               ;; dad6

wDAD7_RawInputs:
; buttons held this frame, active high, in PADF_* order - d-pad in the high
; nibble, buttons in the low one. Written once per vblank by
; call_00_0f31_ReadJoypadInput and read by every CheckInput* helper. This is a
; HELD state, not an edge; gex2 keeps the same thing in wD59F_RawInputs
    ds 1                                               ;; dad7

; ------------------------------------------------------------------
; Shadow copies of the four video registers. Nothing writes rLCDC / rSCX / rSCY
; / rWX / rWY directly during play - call_00_0b25_VBlank_Handler pushes these
; out once per frame instead, so a mid-frame change can never tear
; ------------------------------------------------------------------
wDAD8_LCDCValue:
; one of LCDC_GAMEPLAY / LCDC_INIT. call_00_0d8b_LcdIsr_LoadHudPalettesA also
; reads it to build the hud strip's variant
    ds 1                                               ;; dad8
wDAD9_BgMap_ScrollXLo:
    ds 1                                               ;; dad9
wDADA_BgMap_ScrollYLo:
    ds 1                                               ;; dada
wDADB_WindowX:
    ds 1                                               ;; dadb
wDADC_WindowY:
    ds 1                                               ;; dadc

wDADD_MenuTextBuffer:
; The string call_00_0835_Text_LoadStringToBuffer decompresses out of
; BANK_1C_TEXT, and that call_00_0865_Text_AppendStringToBuffer then appends to.
; Terminated by a byte with bit 7 set; the append routine finds the end by
; scanning forward from wDADC_WindowY + 1, which is this address
    ds 1                                               ;; dadd

wDADE:
    ds 1                                               ;; dade

wDADF:
    ds 1                                               ;; dadf

wDAE0:
    ds 1                                               ;; dae0

wDAE1_TextBuffer:
    ds 128                                             ;; dae1

; ------------------------------------------------------------------
; The graphics transfer queue. Nothing in the game writes VRAM from game logic:
; a routine fills in one of the three parameter sets below, raises its bit in
; wDB66_GfxTransferFlags, and call_00_0c6a_VBlank_StartPendingHdma programs the
; HDMA registers from it during the next vblank.
;
; gex2 has the same queue at wD60F_GfxTransferFlags, but no HDMA: there the
; bits mean "stage a page into wD100_TilesToLoadBuffer and let the LCD STAT
; handler dribble it out four bytes per hblank" instead
; ------------------------------------------------------------------
wDB61_EntityGfx_SlotOffset:
; low byte of the entity being uploaded, i.e. its offset within
; wD800_EntityMemory. Its top three bits also pick the destination VRAM page,
; which is why every entity slot draws from a page of its own
    ds 2                                               ;; db61
wDB63_EntityGfx_PageCount:
; the entity's graphics size, from the second byte of its data_03_58d2_EntitySpriteDescriptors record
; via call_03_59b6_Entity_GetSpriteTileBase. rHDMA5 gets (count * 2 - 1)
    ds 1                                               ;; db63
wDB64_EntityGfx_SrcAddr:
    ds 2                                               ;; db64
wDB66_GfxTransferFlags:
; GFX_XFER_PLAYER_GFX (bit 0)
;   Gex's tiles, from wDABF_PlayerGfx_SrcBank : wDAC0_PlayerGfx_SrcAddr, always
;   into VRAM bank 0 at $8000.
; GFX_XFER_ENTITY_GFX (bit 1)
;   one entity's tiles, from wDB64_EntityGfx_SrcAddr, banked in from the slot's
;   own ENTITY_FIELD_SPRITE_BANK. ACTION_STATE_UNK20_BIT sends it to VRAM
;   bank 1 at $8400 instead of bank 0 at the slot's page.
; GFX_XFER_HDMA_CONFIG (bit 2)
;   the wDC2B_Hdma_SrcAddrLo job struct - an arbitrary source, destination,
;   length and VRAM bank. Only HDMA_MAX_BLOCKS blocks move per frame and the
;   struct is advanced in place, so a big transfer resumes across frames and
;   the bit is only cleared when the length reaches zero.
; GFX_XFER_PENDING (bit 7)
;   set alongside any of the above; the handler returns immediately without it
    ds 1                                               ;; db66
wDB67_LcdIsr_ScanlineCounter:
; seeded from rLY at the end of every vblank and incremented once per hblank by
; the installed LCD STAT handler, so it tracks the scanline being drawn.
; LCD_ISR_HUD_PALETTE compares it against LCD_ISR_HUD_PALETTE_LINE_A / _B to
; decide which half of the hud palette swap to perform
    ds 2                                               ;; db67

wDB69_HUDDirtyFlags:
; What the status bar still has to redraw. Raised by whatever changed the value
; and cleared by call_03_747d_HUD_Update and friends once they have.
; See the HUD_DIRTY_* constants; gex2's is wD60E_HUDDirtyFlags
; bit 7 (80) =
; bit 6 (40) =
; bit 5 (20) =
; bit 4 (10) = HUD_DIRTY_FLY_COIN_ANIM - advance the spinning fly coin (in map)
; bit 3 (08) =
; bit 2 (04) = HUD_DIRTY_TIMER - bonus stage countdown
; bit 1 (02) = HUD_DIRTY_HEALTH - player damaged / ate a fly / collected a paw coin
; bit 0 (01) = HUD_DIRTY_COUNTERS - lives and fly coin digits
    ds 1                                               ;; db69

wDB6A_WarpFlags:
; Why the map is about to be left. Tested in priority order at the top of the
; per-frame loop; see the WARP_* constants. gex2's wD621_WarpFlags holds the
; same idea, and its WARP_DIED / WARP_ENTERED_TV are these bits 1 and 2
; bit 7 (80) =
; bit 6 (40) =
; bit 5 (20) = WARP_TIME_UP - the bonus stage countdown expired
; bit 4 (10) = WARP_NEW_LEVEL - leave the level (entering a tv, minibosses defeated,
;              bonus tv remote collected). call_01_435e_MenuLoad_AfterLevel picks where to
; bit 3 (08) =
; bit 2 (04) = WARP_CHANGE_MAP - a door or a map edge chose another map in this level
; bit 1 (02) = WARP_DIED - the death animation finished
; bit 0 (01) =
    ds 1                                               ;; db6a

wDB6B_VBlankDoneFlag:
; Raised at the end of every vblank and cleared by
; call_00_0b92_WaitForInterrupt, which halts until it comes back - so this is
; what paces the whole game to 60fps. gex2's wD622_VBlankDoneFlag
    ds 1                                               ;; db6b

wDB6C_CurrentMapId: ; can freeze and enter level to get to another level
; also used for totals menu pages
    ds 1                                               ;; db6c

; ------------------------------------------------------------------
; The bonus stage countdown, ticked by call_00_05c7_LevelTimer_Tick. gex2's
; equivalent pair is wD76F_LevelTimer_Minutes / wD770_LevelTimer_SecondsBCD,
; which are BCD and count minutes as well; gex3 keeps a plain second count
; ------------------------------------------------------------------
wDB6D_InBonusStage: ; 1 = in gextreme sports or marsupial madness
    ds 1                                               ;; db6d
wDB6E_LevelTimer_SecondsRemaining:
; drawn by call_03_757e_HUD_AnimateBonusStageTimer. Reaching zero raises
; WARP_NEW_LEVEL | WARP_TIME_UP and boots the player out
    ds 1                                               ;; db6e
wDB6F_LevelTimer_FrameCounter:
; counts down from FRAMES_PER_SECOND, once per frame
    ds 1                                               ;; db6f

wDB70_CollectibleScreenRelativeXOffset:
    ds 1                                               ;; db70
wDB71_CollectibleScreenRelativeYOffset:
    ds 1                                               ;; db71

; Menu-related wRAM starts here
wDB72_PasswordEncodedBuffer:
    ds 1                                               ;; db72
wDB73_PasswordLivesRemaining:
    ds 1                                               ;; db73
wDB74_PasswordPawCoinCounter:
    ds 1                                               ;; db74
wDB75_PasswordPawCoinExtraHealth:
    ds 1                                               ;; db75
wDB76_PasswordEncodedBuffer:
    ds 8                                               ;; db76
wDB7E_PasswordValues:
    ds 18                                              ;; db7e
wDB90_PasswordCounter:
    ds 1                                               ;; db90
wDB91_PasswordCompletionFlag:
    ds 1                                               ;; db91

; Menu Type data
wDB92_MenuTypeDataPointer:
    ds 2                                               ;; db92
wDB94_MenuType_Flags:
    ds 1                                               ;; db94
wDB95_MenuType_OptionCount:
    ds 1                                               ;; db95
wDB96_MenuType_CursorBaseX:
    ds 1                                               ;; db96
wDB97_MenuType_CursorBaseY:
    ds 1                                               ;; db97
wDB98_MenuType_CursorStepX:
    ds 1                                               ;; db98
wDB99_MenuType_CursorStepY:
    ds 1                                               ;; db99
wDB9A_MenuType_Lcdc:
; $d3 in all 29 menu records and never read. call_01_43f0_Menu_BuildScreen sets
; MENU_LCDC directly instead, so a menu cannot in fact choose its own LCDC
    ds 1                                               ;; db9a
wDB9B_MenuType_PaletteId:
    ds 1                                               ;; db9b
wDB9C_MenuType_OnSelectionChanged:
    ds 2                                               ;; db9c

wDB9E_MenuCmd_WidthTiles:
    ds 1                                               ;; db9e
wDB9F_MenuCmd_HeightTiles:
    ds 1                                               ;; db9f
wDBA0_MenuCmd_DestTileX:
    ds 1                                               ;; dba0
wDBA1_MenuCmd_DestTileY:
    ds 1                                               ;; dba1
wDBA2_MenuCmd_FirstTileId:
    ds 1                                               ;; dba2
wDBA3_MenuCmd_AttrByte:
    ds 1                                               ;; dba3
wDBA4_Text_PenX:
    ds 1                                               ;; dba4
wDBA5_Text_PenY:
    ds 1                                               ;; dba5
wDBA6_MenuCmd_Arg2:
    ds 1                                               ;; dba6
wDBA7_MenuCmd_SrcPtr:
    ds 1                                               ;; dba7
wDBA8_MenuCmd_SrcPtrHi:
    ds 1                                               ;; dba8
wDBA9_MenuCmd_OptionSlot:
    ds 1                                               ;; dba9
wDBAA_MenuCmd_Flags:
    ds 1                                               ;; dbaa
wDBAB_Font_GlyphBase:
    ds 2                                               ;; dbab
wDBAD_Font_WidthTable:
    ds 2                                               ;; dbad
wDBAF_Font_GlyphWidthCols:
    ds 1                                               ;; dbaf
wDBB0_Font_GlyphHeightPx:
    ds 1                                               ;; dbb0
; ------------------------------------------------------------------
; The 8-byte record that describes one fullscreen image, copied here by
; call_01_47b1_MenuCmd_LoadFullscreenImage and consumed by
; jp_00_0781_Screen_LoadFullscreenImage. gex2's equivalent is the
; wD6A5_ScreenDraw_TileDataBank block behind
; call_00_07c3_Screen_LoadTilesAndTilemap
; ------------------------------------------------------------------
wDBB1_ScreenDraw_HasPaletteIdMap:
; 0 - the image has no per-tile palette map; build one by looking each tile id
;     up in the 256-entry table that follows the tilemap in ROM
; 1 - a second SCREEN_TILEMAP_BYTES block follows the tilemap and is the
;     palette map, one entry per visible tile
    ds 1                                               ;; dbb1
wDBB2_ScreenDraw_Bank:
    ds 1                                               ;; dbb2
wDBB3_ScreenDraw_TilemapPtr:
; SCREEN_TILEMAP_BYTES of tile ids -> wD400_ScreenDraw_TileIds
    ds 2                                               ;; dbb3
wDBB5_ScreenDraw_TileDataPtr:
; the tile graphics themselves, staged through wC000_BgMapTileIds
    ds 2                                               ;; dbb5
wDBB7_ScreenDraw_TileDataSize:
; in bytes. Anything past SCREEN_TILE_CHUNK_BYTES is uploaded as a second pass
    ds 2                                               ;; dbb7
wDBB9_MenuScript_Ptr:
    ds 2                                               ;; dbb9
; ------------------------------------------------------------------
; The text renderer's working state - code/bank01_menus.asm. Everything from here to
; wDBC9 is written by call_01_4875_Text_Render and the routines under it, and none of
; it survives a command
; ------------------------------------------------------------------
wDBBB_Text_DestPtr:
; where the next glyph's pixels go inside wC000_BgMapTileIds
    ds 1                                               ;; dbbb
wDBBC_Text_DestPtrHi:
    ds 1                                               ;; dbbc
wDBBD_Text_GlyphPtr:
; and where they are read from, inside the current font's bitmaps
    ds 1                                               ;; dbbd
wDBBE_Text_GlyphPtrHi:
    ds 1                                               ;; dbbe
; ------------------------------------------------------------------
; The selection cursor's sprite record, in the exact format
; call_01_4c45_Menu_BuildSpriteBlock reads out of ROM - which is why three entries of
; data_01_5b61_SpriteScriptTable point HERE instead of at a table.
; call_01_46d4_MenuCmd_DrawCursorSprite fills it in once when a script declares the
; cursor, and call_01_4bb8_Menu_DrawCursor rewrites the position half every frame.
; gex2's wD6B9 block, byte for byte
; ------------------------------------------------------------------
wDBBF_MenuCursor_OamSlot:
    ds 1                                               ;; dbbf
wDBC0_MenuCursor_Y:
    ds 1                                               ;; dbc0
wDBC1_MenuCursor_X:
    ds 1                                               ;; dbc1
wDBC2_MenuCursor_Tile:
    ds 1                                               ;; dbc2
wDBC3_MenuCursor_Attr:
    ds 1                                               ;; dbc3
wDBC4_MenuCursor_WidthTiles:
    ds 1                                               ;; dbc4
wDBC5_MenuCursor_HeightTiles:
    ds 1                                               ;; dbc5
wDBC6_MenuCursor_RecordEnd:
; SPRITE_RECORD_END - the record is one rectangle and stops here
    ds 1                                               ;; dbc6
wDBC7_Menu_CursorSpriteId:
; which cursor this screen uses: MENU_CURSOR_NONE, MENU_CURSOR_PASSWORD, or an
; image id
    ds 1                                               ;; dbc7
wDBC8_Text_ShiftCount:
; 8 minus the pen's sub-tile column - how far left a glyph row has to be shifted so
; it lands where the pen is
    ds 1                                               ;; dbc8
wDBC9_Text_GlyphAdvance:
; the current glyph's width, from the font's width table
    ds 1                                               ;; dbc9
wDBCA_MenuCmd_Id:
; the opcode call_01_446b_MenuScript_RunCommand is executing
    ds 1                                               ;; dbca
wDBCB_Menu_OptionActions:
; One byte per selectable row: the MENU_RESULT_* that row returns. Written by the
; SCRIPT, through the option nibbles of wDBA9_MenuCmd_OptionSlot, and read back by
; call_01_4000_MenuLoad when the player commits. Sixteen rows fit; no menu uses more
; than a handful
    ds 16                                              ;; dbcb
wDBDB_Menu_OamSlot:
; running OAM slot for the menu sprite builders
    ds 1                                               ;; dbdb
wDBDC_Menu_BlinkCounter:
; ticked once per frame by the idle loop; MENU_CURSOR_BLINK_MASK of it is what makes
; the password cursor flash
    ds 1                                               ;; dbdc
wDBDD_Menu_ChainedScript:
; a second script to run after this one, or MENU_CHAINED_NONE. Set by
; call_01_47aa_MenuCmd_SetChainedScript, consumed by call_01_43f0_Menu_BuildScreen
    ds 1                                               ;; dbdd
wDBDE_Menu_HideSpritesDelay:
; frames until the sprite group below is erased again. Any button press cuts it to
; its last frame
    ds 1                                               ;; dbde
wDBDF_Menu_HideSpritesGroup:
; which data_01_5b61_SpriteScriptTable entry that erase applies to
    ds 2                                               ;; dbdf
wDBE1_Text_RequestedX:
; pen X for the next line, or TEXT_AUTO_ALIGN to centre it
    ds 1                                               ;; dbe1
wDBE2_Text_LineAdvance:
; pixels between one line's pen Y and the next
    ds 1                                               ;; dbe2
wDBE3_Menu_AnimateFlag: ; set to 1 when a menu with animates sprites is open
    ds 1                                               ;; dbe3
wDBE4:
    ds 1                                               ;; dbe4
wDBE5:
    ds 1                                               ;; dbe5
wDBE6:
    ds 1                                               ;; dbe6
wDBE7:
    ds 1                                               ;; dbe7
wDBE8_Menu_StoredMapId:
    ds 1                                               ;; dbe8
wDBE9_MenuTypeRelated:
    ds 1                                               ;; dbe9
wDBEA_MenuType:
    ds 1                                               ;; dbea
wDBEB_MenuColumnSelected:
    ds 1                                               ;; dbeb
wDBEC_MenuRowSelected:
    ds 1                                               ;; dbec
wDBED_PasswordColumnSelected:
    ds 1                                               ;; dbed
wDBEE_PasswordRowSelected:
    ds 1                                               ;; dbee
; ------------------------------------------------------------------
; The menu graphics stream: a list of (source, destination) pairs walked one
; chunk per frame by call_00_0df9_VBlank_RunGfxStream, so a menu can redraw
; itself without blanking the screen. Byte for byte the same idea as gex2's
; wD6E2_GfxStream_ChunksRemaining block
; ------------------------------------------------------------------
wDBEF_GfxStream_ChunksRemaining:
; zero means idle; each frame copies one chunk and decrements it
    ds 1                                               ;; dbef
wDBF0_GfxStream_RowsPerChunk:
; tiles per chunk, passed to call_00_0bcf_CopyTileRows in B
    ds 1                                               ;; dbf0
wDBF1_GfxStream_SrcBank:
    ds 1                                               ;; dbf1
wDBF2:
    ds 1                                               ;; dbf2
wDBF3:
    ds 1                                               ;; dbf3
wDBF4:
    ds 1                                               ;; dbf4
wDBF5:
    ds 1                                               ;; dbf5
wDBF6_GfxStream_ListPtrLo:
; cursor into the (source, destination) list; advanced by four bytes per chunk
    ds 1                                               ;; dbf6
wDBF7_GfxStream_ListPtrHi:
    ds 1                                               ;; dbf7

wDBF8_TextStringIndex:
; THE LANGUAGE. Every text record in BANK_1C_TEXT is five pointers - English, French,
; German, Spanish, Italian - and this picks one, in
; call_00_0835_Text_LoadStringToBuffer and call_00_0865_Text_AppendStringToBuffer.
;
; NOTHING IN THE ROM WRITES IT. It is cleared with the rest of WRAM at boot and stays
; $00, so the game is permanently English and about two thirds of bank $1C is
; unreachable. MENU_LANGUAGE_SELECT is the screen that would have set it, and nothing
; opens that either - see data/bank_01c_text.asm
    ds 1                                               ;; dbf8

; Map-related wRAM starts here
wDBF9_XPositionInMap:
    ds 2                                               ;; dbf9
wDBFB_YPositionInMap:
    ds 2                                               ;; dbfb
wDBFD_BgMap_PrevColumn:
; The camera position as it was on the previous frame, in blocks rather than
; pixels - the two positions above shifted right three places.
; call_02_7337_MapScroll_CheckHorizontal and call_02_7305_MapScroll_CheckVertical
; read the old value, overwrite it with the new one and raise a MAP_SCROLL_* bit
; when the two differ, which is the whole scroll-detection mechanism: the strip
; loader never looks at pixels, only at whether the block coordinate ticked over.
; gex2's wD6F1_BgMap_PrevColumn and wD6F3_BgMap_PrevRow
    ds 2                                               ;; dbfd
wDBFF_BgMap_PrevRow:
    ds 2                                               ;; dbff

; ------------------------------------------------------------------
; Map Data Pointers, filled in for the current map by the bank 03 map init data
; (see code/bank03_map_init_data.asm). Every one is a bank byte followed by a
; 16-bit offset inside that bank, and the strip loaders in bank00_bg_map.asm
; switch through them one after another to build a single strip.
;
; gex2 keeps the same idea in wD6F5-wD700, but with far fewer layers: it has a
; blockmap, one "alt blockset" flag layer, a combined blockset+collision bank
; and a tileset. gex3 splits them into six independent streams - map, extended
; map, blockset, collision map, collision blockset, tileset - which is what lets
; a gex3 map be any size and use more than 256 distinct blocks.
; ------------------------------------------------------------------
wDC01_MapBank:
; Blockmap: one byte per 16x16 block, rows are wDC1C_CurrentMapWidthAndHeightInBlocks
; bytes apart. Supplies the LOW byte of the block id
    ds 1                                               ;; dc01
wDC02_MapBankOffset:
    ds 2                                               ;; dc02
wDC04_MapExtendedBank:
; Extended blockmap, laid out exactly like the blockmap above and read in the
; same sweep. Supplies the HIGH byte of the block id, so a map can address more
; than 256 blocks. gex2 has a same-shaped second layer but uses it as a one-bit
; "alt blockset" selector instead
    ds 1                                               ;; dc04
wDC05_MapExtendedBankOffset:
    ds 2                                               ;; dc05
wDC07_TilesetBank:
    ds 1                                               ;; dc07
wDC08_TilesetBankOffset:
    ds 2                                               ;; dc08
wDC0A_BlocksetBank:
; Blockset: 8 bytes per block id, indexed as (block id * 8) from
; wDC0B_BlocksetBankOffset. Bytes 0-3 are the four tile ids of the block's 2x2
; tiles in reading order; bytes 4-7 are the matching GBC attribute bytes
; (palette id, horizontal/vertical flip, VRAM bank)
    ds 1                                               ;; dc0a
wDC0B_BlocksetBankOffset:
    ds 2                                               ;; dc0b
wDC0D_MapCollisionBank:
; Collision map: a third layer over the same block grid, one byte per block,
; naming the collision block to use there. gex2 has no separate layer - its
; collision lives in the same bank as the blockset
    ds 1                                               ;; dc0d
wDC0E_MapCollisionBankOffset:
    ds 2                                               ;; dc0e
wDC10_CollisionBlockset:
; Collision blockset: 4 bytes per collision block id, the four collision tile
; ids of its 2x2 tiles. Expanded into wC000_BgMapTileIds, which is what
; call_03_4b4c_BgCollision_IsPixelSolid probes
    ds 1                                               ;; dc10
wDC11_CollisionBlocksetOffset:
    ds 2                                               ;; dc11
wDC13_BgPaletteBank:
   ds 1                                               ;; dc13
wDC14_BgPaletteBankOffset:
    ds 2                                               ;; dc14
wDC16_EntityListBank:
    ds 1                                               ;; dc16
wDC17_EntityListBankOffset:
    ds 2                                               ;; dc17
wDC19_CollectibleListBank:
    ds 1                                               ;; dc19
wDC1A_CollectibleListBankOffset:
    ds 2                                               ;; dc1a
wDC1C_CurrentMapWidthAndHeightInBlocks:
; +0 width in 16x16 blocks, +1 height in blocks. The width doubles as the map
; data row stride, and is what call_00_10c7_BgMap_BuildRowOffsetTable multiplies
; up into wCD00_RowOffsetTableForMap
    ds 2                                               ;; dc1c
wDC1E_CurrentLevelID: ; all maps in the same level share the same value here
    ds 1                                               ;; dc1e

wDC1F_CurrentBgCollisionType:
    ds 1                                               ;; dc1f

wDC20_BgMapLoadingFlags:
; Which edges the camera has uncovered since the last vblank, plus the busy bit.
; MAP_SCROLL_UP / MAP_SCROLL_DOWN ask for a row, MAP_SCROLL_LEFT /
; MAP_SCROLL_RIGHT ask for a column; call_02_7305_MapScroll_CheckVertical and
; call_02_7337_MapScroll_CheckHorizontal raise them, call_00_11c8_BgMap_LoadDirtyRegions
; services them and sets MAP_PENDING_VRAM_TRANSFER, and
; call_00_0b9f_VBlank_UpdateVRAM clears the whole byte after the
; vblank flush. Same bit assignments as gex2's wD6F9_BgMap_LoadingFlags
    ds 1                                               ;; dc20

wDC21_BgMap_RowWritePosLo:
; Tilemap address ($9800-$9BFF) that the pending ROW strip is flushed to, low
; byte. Read back by call_03_75e3_VRAM_WriteBgMapRow.
; gex2 calls the same thing wD6FA_BgMap_RowWritePosLo
    ds 1                                               ;; dc21

wDC22_BgMap_RowWritePosHi:
; High byte of the row's tilemap address. The loaders also reuse it to reach the
; matching slot of wC000_BgMapTileIds, via (value AND $03) + $C0
    ds 1                                               ;; dc22

wDC23_BgMap_ColumnWritePosLo:
; Tilemap address that the pending COLUMN strip is flushed to, low byte.
; Read back by call_03_7664_VRAM_WriteBgMapColumn
    ds 1                                               ;; dc23

wDC24_BgMap_ColumnWritePosHi:
; High byte of the column's tilemap address
    ds 1                                               ;; dc24

wDC25_BgMap_ScratchRowOffset:
; Where in wCF00_BgMap_TempScratchRowTileIds (and, +$80, in
; wCF80_BgMap_TempScratchRowAttributes) this row strip starts:
; (block X * 2) AND $1E, so the buffer rotates with the camera
    ds 1                                               ;; dc25

wDC26_BgMap_ScratchColumnOffset:
; Same idea for the column strip: ((block Y * 2) AND $1E) OR $40, which lands it
; in wCF40_BgMap_TempScratchColumnTileIds / wCFC0_BgMap_TempScratchColumnAttributes
    ds 1                                               ;; dc26

wDC27_BgMap_ScrollBlockX:
; Block X coordinate of the strip being loaded (camera X >> 4), written by
; call_00_14e2_BgMap_SetScrollBlockCoords. Added to the row start pulled out of
; wCD00_RowOffsetTableForMap to reach the first block of the strip.
; gex2 equivalent: wD779_BgMap_ScrollBlockX
    ds 1                                               ;; dc27

wDC28_BgMap_ScrollBlockY:
; Block Y coordinate of the strip being loaded (camera Y >> 4), and therefore
; the index into wCD00_RowOffsetTableForMap.
; gex2 equivalent: wD77A_BgMap_ScrollBlockY
    ds 1                                               ;; dc28

wDC29_SkipMapWindowUpdateFlag: ; if set to 1, don't update the player window map
    ds 1                                               ;; dc29

wDC2A_MapBoundaryIndex:
; Which of the map's boundary records is in force. The value
; MAP_WRAP_BOUNDARY_INDEX means the map wraps around horizontally, and
; call_02_7337_MapScroll_CheckHorizontal is the only code that cares: it turns the
; step across the seam - MAP_WRAP_LAST_COLUMN to column 0, or back - into an
; ordinary one-column scroll instead of a jump across the whole map
    ds 1                                               ;; dc2a

; ------------------------------------------------------------------
; The GFX_XFER_HDMA_CONFIG job struct: one entry of
; .data_00_0aa9_HdmaConfigTable copied here by
; call_00_0a6a_Hdma_RunConfigEntry, then advanced in place by
; call_00_0c6a_VBlank_StartPendingHdma until the length reaches zero. That is
; what lets a transfer larger than HDMA_MAX_BLOCKS resume across frames.
; gex2 has no counterpart - it streams through the LCD STAT handler instead
; ------------------------------------------------------------------
wDC2B_Hdma_SrcAddrLo:
    ds 1                                               ;; dc2b
wDC2C_Hdma_SrcAddrHi:
    ds 1                                               ;; dc2c
wDC2D_Hdma_DestAddrLo:
    ds 1                                               ;; dc2d
wDC2E_Hdma_DestAddrHi:
    ds 1                                               ;; dc2e
wDC2F_Hdma_BytesRemaining:
    ds 2                                               ;; dc2f
wDC31_Hdma_SrcBank:
; HDMACFG_BANK_MAP_TILESET in a table entry means "relocate against the current
; map's tileset", which call_00_0a6a_Hdma_RunConfigEntry resolves on the way in
    ds 1                                               ;; dc31
wDC32_Hdma_VramBank:
    ds 1                                               ;; dc32

wDC33_BgMap_InitialLoadPass:
; Which of the three initial-load passes call_00_1a46_BgMap_LoadInitialRow is
; running, one of BGMAP_PASS_TILE_IDS / BGMAP_PASS_ATTRIBUTES /
; BGMAP_PASS_COLLISION. Bit 7 picks the collision layer over the graphics
; layer; the low bits are added to the byte offset used inside each 8-byte
; blockset entry, which is how the same loop reads tile ids on one pass and
; attribute bytes on the next.
; Only ever set by call_00_1a22_BgMap_LoadAllRowsForPass; the per-frame scroll
; loaders do all three jobs in one visit and never look at it
    ds 1                                               ;; dc33

; Map rectangle bounds, and extended ones
wDC34_MapBoundaryXMinLo:
    ds 1                                               ;; dc34
wDC35_MapBoundaryXMinHi:
    ds 1                                               ;; dc35
wDC36_MapBoundaryXMaxLo:
    ds 1                                               ;; dc36
wDC37_MapBoundaryXMaxHi:
    ds 1                                               ;; dc37
wDC38_MapBoundaryYMinLo:
    ds 1                                               ;; dc38
wDC39_MapBoundaryYMinHi:
    ds 1                                               ;; dc39
wDC3A_MapBoundaryYMaxLo:
    ds 1                                               ;; dc3a
wDC3B_MapBoundaryYMaxHi:
    ds 1                                               ;; dc3b
wDC3C_PlayerBoundaryXMinLo:
    ds 1                                               ;; dc3c
wDC3D_PlayerBoundaryXMinHi:
    ds 1                                               ;; dc3d
wDC3E_PlayerBoundaryXMaxLo:
    ds 1                                               ;; dc3e
wDC3F_PlayerBoundaryXMaxHi:
    ds 1                                               ;; dc3f
wDC40_PlayerBoundaryYMinLo:
    ds 1                                               ;; dc40
wDC41_PlayerBoundaryYMinHi:
    ds 1                                               ;; dc41
wDC42_PlayerBoundaryYMaxLo:
    ds 1                                               ;; dc42
wDC43_PlayerBoundaryYMaxHi:
    ds 1                                               ;; dc43

; Sprite draw order, used only on the top-down maps that need it. The buffer is
; filled with the slot bases of every live entity, bubble-sorted by Y position, and
; then walked in order so that entities lower down the screen are drawn later and
; therefore appear in front. wDC4C_Oam_SortSwapped is the sort's "something moved"
; flag and wDC4D_Oam_DrawOrderCount is how many slots went in.
;
; Side-scrolling maps skip all of this and draw in slot order - see the two passes
; at the top of call_03_5ec1_OAM_BuildFrame
wDC44_Oam_DrawOrderBuffer:
    ds 8                                               ;; dc44
wDC4C_Oam_SortSwapped:
    ds 1                                               ;; dc4c
wDC4D_Oam_DrawOrderCount:
    ds 1                                               ;; dc4d

wDC4E_LivesRemaining:
    ds 1                                               ;; dc4e
wDC4F_PawCoinExtraHealth:
    ds 1                                               ;; dc4f
wDC50_Player_Health:
; PLAYER_BASE_HEALTH plus wDC4F_PawCoinExtraHealth on every spawn. gex2's is
; wD741_Player_Health, and is a flat PLAYER_MAX_HEALTH there
    ds 1                                               ;; dc50

wDC51_Player_CurrentFly:
; the FLY_POWERUP_* id being carried. Eating another fly swaps this and cashes
; the old one in - see call_00_0624_Player_SwapFlyPowerup. Taking a hit while
; holding one drops it instead of costing health, exactly as gex2's
; wD742_Player_CurrentFly does
    ds 1                                               ;; dc51

wDC52_Player_OamTileId:
; The running tile number call_00_2ce2_Player_BuildSprites hands out to Gex's OBJs.
; Zeroed at the top of the build and stepped by PLAYER_SPRITE_TILE_STRIDE per piece,
; so a frame's pieces always take consecutive tile pairs out of the page
; call_00_098f_CopyPlayerGfxToVRAM filled. A piece record does not carry a tile
; number of its own
    ds 1                                               ;; dc52
wDC53_Player_OamAttributes:
; wD80D_PlayerFacingDirection OR wDC7A_PlayerClimbingOrSwimmingRelated, and it does
; two jobs at once: it is OR'd into every one of Gex's OAM attribute bytes, and its
; OAMB_XFLIP / OAMB_YFLIP bits choose which of the four mirrored copies of the draw
; loop runs. Same bit, both meanings - the attribute flips the tile and the loop
; moves the piece to where the flipped tile belongs
    ds 1                                               ;; dc53

wDC54_CachedTileXCoord:
    ds 2                                               ;; dc54
wDC56_CachedTileYCoord:
    ds 2                                               ;; dc56

wDC58_CurrentEntityInteractionFlags:
    ds 1                                               ;; dc58

wDC59_NumRemotesOnMissionSelectMenu:
    ds 1                                               ;; dc59
wDC5A_MissionNumberSelected:
    ds 1                                               ;; dc5a
wDC5B_LevelIdFromTVButton:
    ds 1                                               ;; dc5b

wDC5C_ProgressFlags:
; these keep track of which remotes, paw coins, and bonus coins have been obtained
    ds 9                                               ;; dc5c
wDC65_ProgressFlags_WWGex:
    ds 1                                               ;; dc65
wDC66_ProgressFlags_LizardOfOz:
    ds 1                                               ;; dc66
wDC67_ProgressFlags_ChannelZ: ; 1 = got remote
    ds 1                                               ;; dc67

wDC68_CollectibleAmount:
; fly coins picked up in this level. Only ever rises: COLLECTIBLE_EXTRA_LIFE
; pays out a life and COLLECTIBLE_LEVEL_COMPLETE sets
; PROGRESS_ALL_COLLECTIBLES_BIT. gex2's wD649_CollectibleAmount doubles as a
; falling quota in its bonus levels; gex3 keeps the quota in the level timer
; instead
    ds 1                                               ;; dc68

wDC69_PlayerSpawnIdInLevel:
; Which spawn point of the current level to place the player at after a warp.
; Set by call_00_150f_Map_CheckEdgeTransition (walked off a map edge) or by
; call_00_1bbc_CheckForDoorAndEnter (pressed Up in a doorway), then consumed by
; call_00_1633_Map_LoadWarpDestination, which turns it into a map id and a
; position
    ds 1                                               ;; dc69

wDC6A_WarpDestinationX:
; World X the player is placed at after the pending warp, written by
; call_00_1633_Map_LoadWarpDestination
    ds 2                                               ;; dc6a
wDC6C_WarpDestinationY:
; World Y the player is placed at after the pending warp. For a spawn that links
; to another spawn record, this is the linked spawn's Y plus the player's offset
; from it, so walking off the side of a map keeps the player's height
    ds 2                                               ;; dc6c

; unused?
    ds 1                                               ;; dc6e

wDC6F_Oam_WriteOffset:
; The single write cursor into wD900_ShadowOAM, as a low byte. Seeded to
; OAM_ENTITY_FIRST_BYTE at the top of call_03_5ec1_OAM_BuildFrame and advanced by
; every builder that writes an entry, so entities, particles and collectibles all
; share one running allocation. Each of them checks it against a limit and simply
; stops when OAM is full. gex2's wD739_Entity_OamWriteOffset
    ds 1                                               ;; dc6f
wDC70_Oam_TileBase:
; The tile number added to every tile id the current entity's shape names. Usually
; derived from the slot base - so each slot draws from its own VRAM page - but $40
; for the entities whose descriptor says they share a page instead
    ds 1                                               ;; dc70

wDC71_VBlankFrameCounter:
; incremented by call_00_0b25_VBlank_Handler and by nothing else, so it keeps
; running while a menu or a cutscene has play suspended. Most entity animation
; timing is paced off it. gex2's wD73B_VBlankFrameCounter
    ds 1                                               ;; dc71
wDC72_AnimFrameCounter:
; shared by the two things that animate on a fixed cycle and never run at the
; same time: the hud's fly coin (wraps at 8, in call_03_753e) and the menu HDMA
; animations (wraps at 10, in call_00_088a_Menu_RunHdmaAnimations)
    ds 1                                               ;; dc72
wDC73_FrameCounter_FlyCoins:
    ds 5                                               ;; dc73
    
; Misc player variables
wDC78_PlayerPendingActionId:
    ds 1                                               ;; dc78
wDC79_Player_QueuedAction:
; The action Gex will switch to at the top of the next frame, or
; PLAYERACTION_NONE_PENDING for none.
;
; Nothing writes wD801_Player_ActionId directly. Every action change goes through
; call_02_54f9_Player_RequestAction, which parks the id here, and
; call_02_4f32_Player_UpdateMain reads it back, resets it to
; PLAYERACTION_NONE_PENDING and commits it through call_02_72ac_Entity_SetAction.
; That is what makes an action change always land on a frame boundary no matter how
; many things ask for one during the frame - the last request of the frame wins.
;
; gex2's wD745_Player_QueuedAction, with the same one-frame delay
    ds 1                                               ;; dc79
wDC7A_PlayerClimbingOrSwimmingRelated:
    ds 1                                               ;; dc7a

wDC7B_Player_EntityStoodOnLo:
; Low byte of the entity slot base ($20, $40 ... $E0) the player is currently
; standing on, or $00 for nothing. call_00_26c9_Entity_CarryOrPushPlayerX compares
; it against its own slot base to decide whether it is a moving platform carrying
; the player. gex2's wD74D_Player_EntityStoodOnLo
    ds 1                                               ;; dc7b

wDC7C_PlayerCollisionUnusedFlag:
    ds 1                                               ;; dc7c

wDC7D_Player_PushedMovingPlatformLo:
; Same idea, for the entity the player is walking INTO rather than standing on.
; call_00_26f1_Entity_PushPlayerX only shoves the player when this names its slot,
; which is what stops one moving block from pushing the player through another.
; gex2's wD74F_Player_PushedMovingPlatformLo
    ds 1                                               ;; dc7d

wDC7E_Player_DamageCooldownTimer:
; the invincibility window after a hit, in frames. While it is nonzero
; call_00_0759_Player_IsInvincible refuses further damage. gex2's
; wD750_Player_DamageCooldownTimer
    ds 1                                               ;; dc7e
wDC7F_Player_IsAttacking: ; set to 1 when using tail spin
    ds 1                                               ;; dc7f
wDC80_ButtonBlockingFlags:
; Which face buttons Gex is currently deaf to. The top of
; call_02_4f32_Player_UpdateMain filters the raw pad through this byte on its way
; into wDC81_Player_EffectiveInputs, and a blocked button stays blocked until the
; player physically lets go - which is why A and B read as one-frame events while
; the d-pad stays set for as long as it is held.
;
;   BTN_BLOCK_A_BIT (0)                 A is ignored until released. Set by the
;                                       tail spin so one press cannot chain
;   BTN_BLOCK_B_REPRESS_LATCH_BIT (4)   B was let go during the rise, so one fresh
;                                       press is allowed - this is what makes the
;                                       double jump need a new press rather than a
;                                       held button
;   BTN_BLOCK_B_UNTIL_RELEASE_BIT (6)   B is ignored until released. Set by idle,
;                                       swimming, climbing and the tail spin
;   BTN_BLOCK_B_WHILE_RISING_BIT (7)    B is ignored for as long as Y velocity is
;                                       upward. Set by call_02_4df6_Player_LockBPress
;                                       at the start of every jump
;
; Letting go of B clears everything above BTN_BLOCK_KEEP_MASK, so the three B bits
; reset together. Bits 1, 2, 3 and 5 are never set.
;
; gex2's wD759_ButtonBlockingFlags, same four bits in the same positions
    ds 1                                               ;; dc80

wDC81_Player_EffectiveInputs:
    ds 2                                               ;; dc81

wDC83_PlayerIdleTimer:
    ds 1                                               ;; dc83

; Entity collision related
; ------------------------------------------------------------------
; Horizontal movement the player did not ask for - moving platforms, walkways
; and the like. Both are cleared at the top of call_02_7152_Entities_UpdateAll and
; both are summed into the answer from call_03_4b37_BgCollision_GetPredictedXDelta,
; so between them they are what gex2 keeps in wD75C_PlayerXDeltaExtra
; ------------------------------------------------------------------
wDC84_PlayerXDeltaExtra:
    ds 1                                               ;; dc84
wDC85_PlayerXDeltaExtra2:
    ds 1                                               ;; dc85

wDC86_PlayerXVelocity:
; The horizontal speed actually in use this frame.
; call_02_5081_Player_UpdateFacing nudges it one step per frame toward
; wDC87_PlayerXMaxVelocity rather than snapping to it, and resets it to zero when
; Gex turns around or lets go of the d-pad - so he always accelerates from a
; standstill after a direction change. gex2's wD75D_PlayerXSpeedPrev
    ds 1                                               ;; dc86
wDC87_PlayerXMaxVelocity: ; if freeze this, gex can run faster
; The speed the current action is ramping toward. gex2's wD75E_PlayerXSpeed
    ds 1                                               ;; dc87

wDC88_Player_HopYOffset:
; A signed vertical offset added to Gex's world Y everywhere he is drawn or tested,
; without ever moving him. It is how a top-down map does a jump: the gravity tail
; of call_02_5267_Player_ApplyYVelocity accumulates the fall step in here instead
; of into wD810_PlayerYPosition, so on a BG_COLLISION_TYPE_TOPDOWN map Gex hops
; visually above a position that never leaves the ground. On a sidescrolling map
; nothing writes it and it stays at zero.
;
; Four places read it back, and they agree that the offset is part of where he is:
; the player sprite macro, call_03_550e_Entity_CheckPlayerInteraction, and both
; platform handlers in bank 3. call_03_57e6_ResolveCollision_Reset zeroes it on a
; landing, which is what ends the hop.
;
; gex2 has no equivalent; every gex2 map is a sidescroller
    ds 1                                               ;; dc88

wDC89_BgCollision_TopDownDirection:
; Which way the player is trying to go in a top-down map, one of BGCOLL_DIR_*.
; call_03_48ad_BgCollision_TopDownHandler dispatches on it and indexes
; .data_03_4a1b_TopDownStepOffsets with it; when a diagonal is blocked the
; handler rewrites it to the cardinal it fell back to
    ds 1                                               ;; dc89

wDC8A_MapEdgeTouched:
; Which side of the current map the player was last clamped against, one of
; MAP_EDGE_TOP / MAP_EDGE_BOTTOM / MAP_EDGE_LEFT / MAP_EDGE_RIGHT, or
; MAP_EDGE_NONE ($FF) when the player is not touching an edge.
;
; The four map-boundary clamps in bank02_update_player.asm write it, the main
; loop resets it to MAP_EDGE_NONE each frame, and
; call_00_150f_Map_CheckEdgeTransition reads it as the second index into
; .data_00_153f_MapEdgeSpawnIds to decide which neighbouring map to warp to.
; MAP_EDGE_NONE is detected by testing bit 7, so any value with bit 7 set counts
; as "no edge".
;
; Nothing like this exists in gex2 - a gex2 level is one single map, so walking
; into the edge just stops the player
    ds 1                                               ;; dc8a

wDC8B_BgCollision_WallProbeLookahead:
; How far above his head the wall probe starts, derived from the Y velocity so
; that a wall is caught on the frame he would enter it rather than after
    ds 1                                               ;; dc8b

wDC8C_PlayerYVelocity: ; can freeze to levitate
    ds 1                                               ;; dc8c

wDC8D_Player_FloorSnapVelocity:
; The gap to the floor found by the floor scan, negated and scaled, for the
; player code to close. BGCOLL_FLOOR_SEARCH_ROWS - 1 rows (giving $c0) means no
; floor was found within range and he is still falling
    ds 1                                               ;; dc8d

wDC8E_InitialYVelocity: ; the y velocity gex had when he left the ground?
    ds 1                                               ;; dc8e

wDC8F_FallDistanceCounter:
; How long Gex has been falling, counted only in frames spent AT
; PLAYER_MAX_FALL_VELOCITY - so it measures time at terminal velocity rather than
; total airtime, and a short hop never touches it. It saturates rather than wrapping.
;
; call_02_5267_Player_ApplyYVelocity reads it back the moment he lands and picks
; the landing from it: below PLAYER_FALL_SHORT he keeps his footing, below
; PLAYER_FALL_LONG he lands in idle or walk, and at or above it he lands heavily.
; gex2's wD763_FallDistanceCounter
    ds 1                                               ;; dc8f

; Where Gex is on the SCREEN rather than in the map: his world position minus the
; camera, plus the sprite's own offset. Recomputed once a frame by the player sprite
; builder in bank00_entity_load.asm and used by everything that has to reason in
; screen space - the OAM rows themselves, and
; call_02_4a37_PlayerAction_DeathInPit, which waits for wDC91_Player_ScreenY to pass
; PLAYER_OFFSCREEN_BOTTOM_Y before asking for the respawn, so that the fall is seen
; to finish rather than cutting away mid-air
wDC90_Player_ScreenX:
    ds 1                                               ;; dc90

wDC91_Player_ScreenY:
    ds 1                                               ;; dc91

; ------------------------------------------------------------------
; Nearby collision tiles, refreshed once a frame by
; call_03_4bb6_BgCollision_CacheNearbyTileTypes so the player code can react to
; water, doors, springs and climbable surfaces without repeating the lookup.
; The first four are a straight column through the player, one tile row apart
; ------------------------------------------------------------------
wDC92_TileTypeBehindGexsUpperBody:
; his head
    ds 1                                               ;; dc92
wDC93_TileTypeBehindGexsLowerBody:
; one tile row down, his body
    ds 1                                               ;; dc93
wDC94_TileTypeBehindGexsFace:
; one row up and one tile ahead in the direction he faces - what he is looking at
    ds 1                                               ;; dc94
wDC95_FloorTileType:
; one row below his body: the tile he is standing on
    ds 2                                               ;; dc95
wDC97_TileTypeAboveGexsHead:
; one tile row above his head, where the column scan starts
    ds 1                                               ;; dc97

wDC98_Player_DamageKnockbackX:
; Which way Gex is thrown when something hurts him: $01 for right, $FF for left,
; written by call_03_4cea_CollisionHandler_DamagePlayer as the opposite of the
; direction the entity was on. call_02_7152_Entities_UpdateAll copies it into
; wDC84_PlayerXDeltaExtra for as long as he is in one of the take-damage actions,
; so the knockback is applied a pixel at a time rather than as one shove.
;
; Only the first of these three bytes has a known use
    ds 3                                               ;; dc98

wDC9B_Player_SwimmingRelated3:
    ds 1                                               ;; dc9b
wDC9C_Player_SwimmingRelated2:
    ds 1                                               ;; dc9c
wDC9D_Player_SwimmingRelated:
    ds 1                                               ;; dc9d

wDC9E_Player_ClimbSubState:
; Which half of PLAYERACTION_CLIMBING is running: CLIMB_SUBSTATE_NORMAL for the
; ordinary climb, CLIMB_SUBSTATE_TAIL_SPIN for the spin Gex can do while hanging on.
; It indexes data_02_4adb_ClimbSubStateTable, so one action id is really two routines
    ds 1                                               ;; dc9e
wDC9F_Player_ClimbingRelated:
    ds 1                                               ;; dc9f
wDCA0_Player_ClimbingRelated3:
    ds 1                                               ;; dca0
wDCA1_Player_ClimbingRelated4:
    ds 1                                               ;; dca1

wDCA2_Player_SnowboardingRelated:
    ds 1                                               ;; dca2
wDCA3_Player_SnowboardingRelated2:
    ds 1                                               ;; dca3
wDCA4_Player_SnowboardingRelated3:
    ds 1                                               ;; dca4
wDCA5_Player_SnowboardingRelated4:
    ds 1                                               ;; dca5
wDCA6_Player_SnowboardingRelated5:
    ds 1                                               ;; dca6

wDCA7_Player_UpdateFlag:
; Nonzero while Gex is under his own control. Clearing it makes
; call_02_7152_Entities_UpdateAll skip the whole player half of the frame - the
; tile pushes, the platform he is riding, and call_02_4f32_Player_UpdateMain - and
; makes the collision and sprite passes in bank 3 leave him out too, while the
; entity loop and the map window carry on as normal.
;
; That is exactly what a cutscene needs: call_00_1ea0_Cutscene_LoadAndRun clears
; it to hand Gex to the script, and gives him back when the script ends
    ds 1                                               ;; dca7

; ------------------------------------------------------------------
; Fly power-up timers. Three of the five flies grant a timed power-up, and each
; has a countdown of its own so that swapping one out cannot leave another
; running. All three are seconds, not frames: call_02_4ffb_Player_DecrementPowerupTimer
; only decrements one when the shared wDCA8_FlyPowerup_FrameCounter wraps.
;
; Any of the three being nonzero is what the entity collision handlers read as
; "Gex is powered up" and lets him destroy things he otherwise could not.
; gex2 splits the same job between wD753_FlyPowerup1_Timer and
; wD755_FlyPowerup2_Timer, which are 16-bit frame counts
; ------------------------------------------------------------------
wDCA8_FlyPowerup_FrameCounter:
; shared by all three timers; reloaded with TIMER_AMOUNT_60_FRAMES
    ds 1                                               ;; dca8
wDCA9_FlyPowerup2_Timer:
; armed by swapping out FLY_POWERUP_2
    ds 1                                               ;; dca9
wDCAA_FlyPowerup1_Timer:
; armed by swapping out FLY_POWERUP_1
    ds 1                                               ;; dcaa
wDCAB_FlyPowerup5_Timer:
; armed by swapping out FLY_POWERUP_5. Also what
; call_03_6567_FlyPowerup_LoadPalette checks first, so this power-up's tint wins
    ds 1                                               ;; dcab

wDCAC_Player_CrouchLookDownRelated:
    ds 1                                               ;; dcac
wDCAD:
    ds 1                                               ;; dcad

wDCAE_FlyPowerup_ActiveIndex:
; which of the three timed power-ups was armed last, one of FLY_POWERUP_ACTIVE_*
    ds 1                                               ;; dcae

wDCAF_PawCoinCounter: ; for every 4 collected, increment Gex's health
    ds 1                                               ;; dcaf

; unused?
    ds 1

wDCB1_LevelTriggerBuffer:
    ds 16                                              ;; dcb1

wDCC1_Door_TargetSpawnId:
; Spawn id of the door call_00_1bbc_CheckForDoorAndEnter is currently testing.
; On a hit it is copied to wDC69_PlayerSpawnIdInLevel and the warp is requested
    ds 1                                               ;; dcc1
wDCC2_Door_RequiredTriggerIndex:
; Index into wDCB1_LevelTriggerBuffer that must be non-zero for that door to
; open, or $FF for a door with no condition
    ds 1                                               ;; dcc2

; Entity counters and flags
wDCC3_IceSculptureCounter:
    ds 1                                               ;; dcc3
wDCC4_EvilSantaHealth:
    ds 1                                               ;; dcc4
wDCC5_BloodCoolerCounter:
    ds 1                                               ;; dcc5
wDCC6_LostArkCounter:
    ds 1                                               ;; dcc6
wDCC7_RaStaffCounter:
    ds 1                                               ;; dcc7
wDCC8_ElfCounter:
    ds 1                                               ;; dcc8
wDCC9_AlienCultureTubeCounter:
    ds 1                                               ;; dcc9
wDCCA_StrayCatCounter:
    ds 1                                               ;; dcca
wDCCB_MechCounter:
    ds 1                                               ;; dccb
wDCCC_BellCounter:
    ds 1                                               ;; dccc
wDCCD_ConvictCounter:
    ds 1                                               ;; dccd
wDCCE_BombCounter:
    ds 1                                               ;; dcce
wDCCF_PlayingCardCounter:
    ds 1                                               ;; dccf
wDCD0_MadBomberFlag:
    ds 1                                               ;; dcd0
wDCD1_BrainOfOzFlag:
    ds 1                                               ;; dcd1
wDCD2_FreestandingRemoteHitFlags:
; gets set when a collision occurs with a freestanding remote
; the remote entity checks for this flag and sets progressflags
    ds 1                                               ;; dcd2
wDCD3_GhostKnightDamageCounter1:
    ds 1                                               ;; dcd3
wDCD4_GhostKnightDamageCounter2:
    ds 1                                               ;; dcd4
wDCD5_ElfHealth1:
    ds 1                                               ;; dcd5
wDCD6_ElfHealth2:
    ds 1                                               ;; dcd6
wDCD7_ElfHealth3:
    ds 1                                               ;; dcd7
wDCD8_ElfHealth4:
    ds 1                                               ;; dcd8
wDCD9_ElfHealth5:
    ds 1                                               ;; dcd9
wDCDA_BrainOfOzAndRezCounter:
    ds 1                                               ;; dcda
wDCDB_EvilSantaHitByProjectileFlag:
    ds 1                                               ;; dcdb
wDCDC_HandEntityUnkFlag:
    ds 2                                               ;; dcdc

; ------------------------------------------------------------------
; Cutscene state. A mission preview is a scripted camera move over a level that
; has not started yet, driven by faking d-pad input into wDC81_Player_EffectiveInputs
; ------------------------------------------------------------------
wDCDE_Cutscene_MoveFramesRemaining:
; 16-bit countdown for the movement command currently running. Loaded from the
; script, decremented once per frame; at zero the next command is fetched
    ds 2                                                ;; dcde
wDCE0_Cutscene_MoveSpeed:
; movement speed in 1/16ths of a pixel per frame. Only ever $00 while a command
; holds no direction, or CUTSCENE_MOVE_SPEED_MAX while it holds one
    ds 1                                               ;; dce0
wDCE1_Cutscene_MoveSubPixel:
; sub-pixel accumulator. wDCE0_Cutscene_MoveSpeed is added to the low nibble
; each frame and the carry out of the high nibble becomes the whole-pixel step
    ds 1                                               ;; dce1

; Elevator entity data
wDCE2_ElevatorEntityUnkData:
    ds 6                                               ;; dce2

; Entity spawning related flags
wDCE8_CurrentEntity_ParentListIndex: ; used relative entity spawns, such as projectiles and flies
    ds 1                                               ;; dce8
wDCE9_EntitySpawnPosOffsetFlag:
    ds 1                                               ;; dce9

; Palletes and related flags
; ------------------------------------------------------------------
; The CGB palette buffers. Two blocks of CGB_PALETTE_RAM_SIZE bytes, back to back,
; and call_00_0e81_UploadCgbPalettes walks HL straight through all $80 of them - the
; first block to rBCPD, the second to rOCPD.
;
; The four labels below are a disassembly artifact, not a structure. Each block is
; eight palettes of CGB_PALETTE_SIZE bytes and the writers cross the halfway label
; freely: call_03_65c6_Palettes_LoadForScreen copies $40 bytes from wDCEA_BgPalettes
; and another $40 straight after, and an entity holding palette 4 or more has its
; colours written past wDD2A_EntityPalettes into wDD4A_ObjectPalettes
; ------------------------------------------------------------------
wDCEA_BgPalettes:
; BG palettes 0-3
    ds 32                                              ;; dcea
wDD0A_BgPalettes:
; BG palettes 4-7
    ds 32                                              ;; dd0a
wDD2A_EntityPalettes:
; OBJ palettes 0-3. Palette 0 is the player's - the map supplies it and
; call_03_6567_FlyPowerup_LoadPalette tints it - and 1 upwards are handed out one per
; entity slot by call_03_687c_AssignEntityPalette
    ds 32                                              ;; dd2a
wDD4A_ObjectPalettes:
; OBJ palettes 4-7, for entity slots 4 to 7. Nothing addresses this label directly
    ds 32                                              ;; dd4a
wDD6A_PalettesReadyFlag:
; 0 while a screen is being built: call_00_0e81_UploadCgbPalettes then fills
; both palette rams with $80 bytes instead of the real colours, which is what
; keeps a half-drawn screen from flashing. Raised once the screen is ready
    ds 1                                               ;; dd6a

wDD6B: ; unused except set to 0?
    ds 1
    
; unused section?
    ds 88                                             ;; dd6b

; Particle buffer
wDDC4_ParticleSlot1:
    ds 19
wDDD7_ParticleSlot2:
    ds 19
wDDEA_ParticleSlot3:
    ds 19
wDDFD_ParticleSlot4:
    ds 19
wDE10_ParticleSlot5:
    ds 19
wDE23_ParticleSlot6:
    ds 19
wDE36_ParticleSlot7:
    ds 19
wDE49_ParticleSlot8:
    ds 19

; Start of Audio wRAM section
wDE5C_CurrentSong:
    ds 1                                               ;; de5c
wDE5D_QueuedSFX:
    ds 1                                               ;; de5d
wDE5E_QueuedSFXPriority:
    ds 1                                               ;; de5e
wDE5F_CurrentSFXPriority:
    ds 1                                               ;; de5f
wDE60_CurrentAudioBank:
    ds 1                                               ;; de60
    
; unused section?
    ds 159                                             ;; de61

; ------------------------------------------------------------------
; SOUND DRIVER STATE
;
; Everything the driver in banks $04 and $05 owns. The first four blocks are one per
; hardware channel, AUDIO_CH_SIZE bytes each and identical in layout - see the
; AUDIO_CH_* constants for the offsets the code adds and subtracts.
;
; Unlike gex2 there is no second set of channels for sound effects. An effect takes a
; hardware channel away from the music by clearing that channel's AUDIO_CHF_ENABLED and
; hands it straight back when it ends, so nothing is ever saved or restored - compare
; gex2's wDFD2_Audio_SavedMusicRegs
; ------------------------------------------------------------------

; --- channel 1, pulse A ---

wDF00_Audio_Ch1_Flags:
; AUDIO_CHF_ENABLED while the music may write this channel's registers, and
; AUDIO_CHF_RUNNING while its pattern is still being read. A sound effect clears the
; first and leaves the second, which is how the music keeps its place while inaudible
    ds 1                                               ;; df00

wDF01_Audio_Ch1_NoteTimer:
; ticks left on the current note. Audio_RunSequence costs three instructions
; a frame until it reaches zero
    ds 1                                               ;; df01

wDF02_Audio_Ch1_SeqPtrLo:
; where this channel is in its pattern
    ds 1                                               ;; df02

wDF03_Audio_Ch1_SeqPtrHi:
    ds 1                                               ;; df03

wDF04_Audio_Ch1_NR14Shadow:
; frequency high bits, plus AUDIO_NRX4_TRIGGER while a retrigger is
; pending. Audio_StepPitchSlide treats this and the byte below as one 16-bit number, so a
; slide can carry from one into the other
    ds 1                                               ;; df04

wDF05_Audio_Ch1_NR13Shadow:
; frequency low byte
    ds 1                                               ;; df05

    ds 1                                               ;; df06 (unused)

wDF07_Audio_Ch1_NR11Shadow:
; duty and length, taken from the instrument
    ds 1                                               ;; df07

wDF08_Audio_Ch1_NR12Shadow:
; volume envelope register, kept in step with whatever the envelope last
; wrote so that a retrigger does not lose the current volume
    ds 1                                               ;; df08

    ds 1                                               ;; df09 (unused)

wDF0A_Audio_Ch1_EnvelopeTimer:
; frames left on this volume-envelope step; zero once the envelope has
; finished
    ds 1                                               ;; df0a

wDF0B_Audio_Ch1_EnvelopePtrLo:
; position in the instrument's volume envelope
    ds 1                                               ;; df0b

wDF0C_Audio_Ch1_EnvelopePtrHi:
    ds 1                                               ;; df0c

wDF0D_Audio_Ch1_PitchTimer:
; frames left on this pitch-slide step
    ds 1                                               ;; df0d

wDF0E_Audio_Ch1_PitchPtrLo:
; position in the instrument's pitch slide
    ds 1                                               ;; df0e

wDF0F_Audio_Ch1_PitchPtrHi:
    ds 1                                               ;; df0f

wDF10_Audio_Ch1_ArpTimer:
; frames left on this arpeggio step
    ds 1                                               ;; df10

wDF11_Audio_Ch1_ArpPtrLo:
; position in the instrument's arpeggio
    ds 1                                               ;; df11

wDF12_Audio_Ch1_ArpPtrHi:
    ds 1                                               ;; df12

wDF13_Audio_Ch1_LoopCounter:
; repeats left in the pattern AUDIO_CMD_CALL_PATTERN entered
    ds 1                                               ;; df13

wDF14_Audio_Ch1_Transpose:
; semitones added to every note this channel plays; set per pattern call and
; cleared by Audio_ResetHardware
    ds 1                                               ;; df14

wDF15_Audio_Ch1_LoopActive:
; non-zero once LoopCounter has been loaded, so re-entering a pattern that is
; already counting down does not restart the count
    ds 1                                               ;; df15

wDF16_Audio_Ch1_ReturnPtrLo:
; where AUDIO_CMD_END_PATTERN goes back to
    ds 1                                               ;; df16

wDF17_Audio_Ch1_ReturnPtrHi:
    ds 1                                               ;; df17

; --- channel 2, pulse B ---

wDF18_Audio_Ch2_Flags:
; AUDIO_CHF_ENABLED while the music may write this channel's registers, and
; AUDIO_CHF_RUNNING while its pattern is still being read. A sound effect clears the
; first and leaves the second, which is how the music keeps its place while inaudible
    ds 1                                               ;; df18

wDF19_Audio_Ch2_NoteTimer:
; ticks left on the current note. Audio_RunSequence costs three instructions
; a frame until it reaches zero
    ds 1                                               ;; df19

wDF1A_Audio_Ch2_SeqPtrLo:
; where this channel is in its pattern
    ds 1                                               ;; df1a

wDF1B_Audio_Ch2_SeqPtrHi:
    ds 1                                               ;; df1b

wDF1C_Audio_Ch2_NR24Shadow:
; frequency high bits, plus AUDIO_NRX4_TRIGGER while a retrigger is
; pending. Audio_StepPitchSlide treats this and the byte below as one 16-bit number, so a
; slide can carry from one into the other
    ds 1                                               ;; df1c

wDF1D_Audio_Ch2_NR23Shadow:
; frequency low byte
    ds 1                                               ;; df1d

    ds 1                                               ;; df1e (unused)

wDF1F_Audio_Ch2_NR21Shadow:
; duty and length, taken from the instrument
    ds 1                                               ;; df1f

wDF20_Audio_Ch2_NR22Shadow:
; volume envelope register, kept in step with whatever the envelope last
; wrote so that a retrigger does not lose the current volume
    ds 1                                               ;; df20

    ds 1                                               ;; df21 (unused)

wDF22_Audio_Ch2_EnvelopeTimer:
; frames left on this volume-envelope step; zero once the envelope has
; finished
    ds 1                                               ;; df22

wDF23_Audio_Ch2_EnvelopePtrLo:
; position in the instrument's volume envelope
    ds 1                                               ;; df23

wDF24_Audio_Ch2_EnvelopePtrHi:
    ds 1                                               ;; df24

wDF25_Audio_Ch2_PitchTimer:
; frames left on this pitch-slide step
    ds 1                                               ;; df25

wDF26_Audio_Ch2_PitchPtrLo:
; position in the instrument's pitch slide
    ds 1                                               ;; df26

wDF27_Audio_Ch2_PitchPtrHi:
    ds 1                                               ;; df27

wDF28_Audio_Ch2_ArpTimer:
; frames left on this arpeggio step
    ds 1                                               ;; df28

wDF29_Audio_Ch2_ArpPtrLo:
; position in the instrument's arpeggio
    ds 1                                               ;; df29

wDF2A_Audio_Ch2_ArpPtrHi:
    ds 1                                               ;; df2a

wDF2B_Audio_Ch2_LoopCounter:
; repeats left in the pattern AUDIO_CMD_CALL_PATTERN entered
    ds 1                                               ;; df2b

wDF2C_Audio_Ch2_Transpose:
; semitones added to every note this channel plays; set per pattern call and
; cleared by Audio_ResetHardware
    ds 1                                               ;; df2c

wDF2D_Audio_Ch2_LoopActive:
; non-zero once LoopCounter has been loaded, so re-entering a pattern that is
; already counting down does not restart the count
    ds 1                                               ;; df2d

wDF2E_Audio_Ch2_ReturnPtrLo:
; where AUDIO_CMD_END_PATTERN goes back to
    ds 1                                               ;; df2e

wDF2F_Audio_Ch2_ReturnPtrHi:
    ds 1                                               ;; df2f

; --- channel 3, wave ---

wDF30_Audio_Ch3_Flags:
; AUDIO_CHF_ENABLED while the music may write this channel's registers, and
; AUDIO_CHF_RUNNING while its pattern is still being read. A sound effect clears the
; first and leaves the second, which is how the music keeps its place while inaudible
    ds 1                                               ;; df30

wDF31_Audio_Ch3_NoteTimer:
; ticks left on the current note. Audio_RunSequence costs three instructions
; a frame until it reaches zero
    ds 1                                               ;; df31

wDF32_Audio_Ch3_SeqPtrLo:
; where this channel is in its pattern
    ds 1                                               ;; df32

wDF33_Audio_Ch3_SeqPtrHi:
    ds 1                                               ;; df33

wDF34_Audio_Ch3_NR34Shadow:
; frequency high bits, plus AUDIO_NRX4_TRIGGER while a retrigger is
; pending. Audio_StepPitchSlide treats this and the byte below as one 16-bit number, so a
; slide can carry from one into the other
    ds 1                                               ;; df34

wDF35_Audio_Ch3_NR33Shadow:
; frequency low byte
    ds 1                                               ;; df35

    ds 1                                               ;; df36 (unused)

wDF37_Audio_Ch3_NR31Shadow:
; duty and length, taken from the instrument
    ds 1                                               ;; df37

wDF38_Audio_Ch3_NR32Shadow:
; volume envelope register, kept in step with whatever the envelope last
; wrote so that a retrigger does not lose the current volume
    ds 1                                               ;; df38

    ds 1                                               ;; df39 (unused)

wDF3A_Audio_Ch3_EnvelopeTimer:
; frames left on this volume-envelope step; zero once the envelope has
; finished
    ds 1                                               ;; df3a

wDF3B_Audio_Ch3_EnvelopePtrLo:
; position in the instrument's volume envelope
    ds 1                                               ;; df3b

wDF3C_Audio_Ch3_EnvelopePtrHi:
    ds 1                                               ;; df3c

wDF3D_Audio_Ch3_PitchTimer:
; frames left on this pitch-slide step
    ds 1                                               ;; df3d

wDF3E_Audio_Ch3_PitchPtrLo:
; position in the instrument's pitch slide
    ds 1                                               ;; df3e

wDF3F_Audio_Ch3_PitchPtrHi:
    ds 1                                               ;; df3f

wDF40_Audio_Ch3_ArpTimer:
; frames left on this arpeggio step
    ds 1                                               ;; df40

wDF41_Audio_Ch3_ArpPtrLo:
; position in the instrument's arpeggio
    ds 1                                               ;; df41

wDF42_Audio_Ch3_ArpPtrHi:
    ds 1                                               ;; df42

wDF43_Audio_Ch3_LoopCounter:
; repeats left in the pattern AUDIO_CMD_CALL_PATTERN entered
    ds 1                                               ;; df43

wDF44_Audio_Ch3_Transpose:
; semitones added to every note this channel plays; set per pattern call and
; cleared by Audio_ResetHardware
    ds 1                                               ;; df44

wDF45_Audio_Ch3_LoopActive:
; non-zero once LoopCounter has been loaded, so re-entering a pattern that is
; already counting down does not restart the count
    ds 1                                               ;; df45

wDF46_Audio_Ch3_ReturnPtrLo:
; where AUDIO_CMD_END_PATTERN goes back to
    ds 1                                               ;; df46

wDF47_Audio_Ch3_ReturnPtrHi:
    ds 1                                               ;; df47

; --- channel 4, noise ---

wDF48_Audio_Ch4_Flags:
; AUDIO_CHF_ENABLED while the music may write this channel's registers, and
; AUDIO_CHF_RUNNING while its pattern is still being read. A sound effect clears the
; first and leaves the second, which is how the music keeps its place while inaudible
    ds 1                                               ;; df48

wDF49_Audio_Ch4_NoteTimer:
; ticks left on the current note. Audio_RunSequence costs three instructions
; a frame until it reaches zero
    ds 1                                               ;; df49

wDF4A_Audio_Ch4_SeqPtrLo:
; where this channel is in its pattern
    ds 1                                               ;; df4a

wDF4B_Audio_Ch4_SeqPtrHi:
    ds 1                                               ;; df4b

wDF4C_Audio_Ch4_NR44Shadow:
; frequency high bits, plus AUDIO_NRX4_TRIGGER while a retrigger is
; pending. Audio_StepPitchSlide treats this and the byte below as one 16-bit number, so a
; slide can carry from one into the other
    ds 1                                               ;; df4c

wDF4D_Audio_Ch4_NR43Shadow:
; the noise channel has no frequency - this holds the last rNR43 value
; Audio_WriteChannelRegs copied out of wDF64_Audio_NoisePeriod
    ds 1                                               ;; df4d

    ds 1                                               ;; df4e (unused)

wDF4F_Audio_Ch4_NR41Shadow:
; duty and length, taken from the instrument
    ds 1                                               ;; df4f

wDF50_Audio_Ch4_NR42Shadow:
; volume envelope register, kept in step with whatever the envelope last
; wrote so that a retrigger does not lose the current volume
    ds 1                                               ;; df50

    ds 1                                               ;; df51 (unused)

wDF52_Audio_Ch4_EnvelopeTimer:
; frames left on this volume-envelope step; zero once the envelope has
; finished
    ds 1                                               ;; df52

wDF53_Audio_Ch4_EnvelopePtrLo:
; position in the instrument's volume envelope
    ds 1                                               ;; df53

wDF54_Audio_Ch4_EnvelopePtrHi:
    ds 1                                               ;; df54

wDF55_Audio_Ch4_PitchTimer:
; frames left on this step of the noise-period sequence. Channel 4 runs
; Audio_StepNoisePeriod over these three fields instead of a pitch slide
    ds 1                                               ;; df55

wDF56_Audio_Ch4_PitchPtrLo:
; position in the noise-period sequence
    ds 1                                               ;; df56

wDF57_Audio_Ch4_PitchPtrHi:
    ds 1                                               ;; df57

wDF58_Audio_Ch4_ArpTimer:
; unused - Audio_UpdateMusic has no arpeggio pass for channel 4
    ds 1                                               ;; df58

wDF59_Audio_Ch4_ArpPtrLo:
; unused
    ds 1                                               ;; df59

wDF5A_Audio_Ch4_ArpPtrHi:
    ds 1                                               ;; df5a

wDF5B_Audio_Ch4_LoopCounter:
; repeats left in the pattern AUDIO_CMD_CALL_PATTERN entered
    ds 1                                               ;; df5b

wDF5C_Audio_Ch4_Transpose:
; semitones added to every note this channel plays; set per pattern call and
; cleared by Audio_ResetHardware
    ds 1                                               ;; df5c

wDF5D_Audio_Ch4_LoopActive:
; non-zero once LoopCounter has been loaded, so re-entering a pattern that is
; already counting down does not restart the count
    ds 1                                               ;; df5d

wDF5E_Audio_Ch4_ReturnPtrLo:
; where AUDIO_CMD_END_PATTERN goes back to
    ds 1                                               ;; df5e

wDF5F_Audio_Ch4_ReturnPtrHi:
    ds 1                                               ;; df5f

; --- driver globals ---

wDF60_Audio_NoteLengthTablePtrLo:
; The note-length table the current song's low nibbles index. Set from the song record
; and overridable per section by AUDIO_CMD_SET_NOTE_LENGTH_TABLE
    ds 1                                               ;; df60

wDF61_Audio_NoteLengthTablePtrHi:
    ds 1                                               ;; df61

wDF62_Audio_ChannelResumePtrLo:
; The address in Audio_UpdateMusic of the channel block currently being serviced.
; Audio_ResumeChannel jumps here, which is how a pattern command hands control back and
; gets the next byte read on the same tick
    ds 1                                               ;; df62

wDF63_Audio_ChannelResumePtrHi:
    ds 1                                               ;; df63

wDF64_Audio_NoisePeriod:
; The rNR43 value channel 4 will play, from AUDIO_CMD_SET_NOISE_PERIOD or from its
; noise-period sequence. Audio_WriteChannelRegs copies it out and into
; wDF4D_Audio_Ch4_NR43Shadow
    ds 1                                               ;; df64

wDF65_Audio_CurrentTranspose:
; The AUDIO_CH_TRANSPOSE of the channel being serviced, copied here so
; Audio_RunSequence can reach it without the channel block
    ds 1                                               ;; df65

wDF66_Audio_CurrentNoteByte:
; The raw pattern byte of the note being started, kept whole so its
; AUDIO_NOTE_INSTRUMENT_BANK bit survives the masking that follows
    ds 1                                               ;; df66

wDF67_Audio_Marker:
; What AUDIO_CMD_SET_MARKER stores. Nothing in either bank reads it - it looks like a
; sequencer annotation that was never given a runtime meaning
    ds 1                                               ;; df67

wDF68_Audio_Ch1_SfxPtrLo:
; Where the sound effect on channel 1 is, or zero if there is none. Audio_UpdateMusic
; tests the high byte to decide whether the music may touch the hardware, and
; call_00_0ff5_QueueSFX ORs all four pairs together to ask whether anything is audible
    ds 1                                               ;; df68

wDF69_Audio_Ch1_SfxPtrHi:
    ds 1                                               ;; df69

wDF6A_Audio_Ch1_SfxTimer:
; frames left on the current row of channel 1's sound effect
    ds 1                                               ;; df6a

wDF6B_Audio_Ch2_SfxPtrLo:
    ds 1                                               ;; df6b

wDF6C_Audio_Ch2_SfxPtrHi:
    ds 1                                               ;; df6c

wDF6D_Audio_Ch2_SfxTimer:
    ds 1                                               ;; df6d

wDF6E_Audio_Ch3_SfxPtrLo:
    ds 1                                               ;; df6e

wDF6F_Audio_Ch3_SfxPtrHi:
    ds 1                                               ;; df6f

wDF70_Audio_Ch3_SfxTimer:
    ds 1                                               ;; df70

wDF71_Audio_Ch4_SfxPtrLo:
    ds 1                                               ;; df71

wDF72_Audio_Ch4_SfxPtrHi:
    ds 1                                               ;; df72

wDF73_Audio_Ch4_SfxTimer:
    ds 1                                               ;; df73

wDF74_Audio_SfxOwnerChannelPtrLo:
; The channel block Audio_UpdateSfx is working on, so Audio_StepSfxTrack can set
; AUDIO_CHF_ENABLED again when the effect ends
    ds 1                                               ;; df74

wDF75_Audio_SfxOwnerChannelPtrHi:
    ds 1                                               ;; df75

wDF76_Audio_MusicEnabled:
; Non-zero while Audio_UpdateMusic is allowed to run. Audio_StartSong sets it, and the
; unused pause and stop vectors clear it. Sound effects ignore it entirely
    ds 1                                               ;; df76

wDF77_Audio_TempoAccumulator:
; wDF78_Audio_TempoRate is added to this every frame and the music only advances on the
; frames that carry out of the byte - a phase accumulator rather than a countdown
    ds 1                                               ;; df77

wDF78_Audio_TempoRate:
; How much the accumulator gains per frame. $FF, which every song starts at, carries
; every frame; AUDIO_CMD_SET_TEMPO and the unused $4021 vector change it
    ds 1                                               ;; df78

wDF79_Audio_PanningShadow:
; What rNR51 should be while only music is playing. The five panning commands maintain
; it, and Audio_StepSfxTrack puts it back when an effect ends
    ds 1                                               ;; df79

wDF7A_Audio_SfxPanning:
; wDF79 with the effect's own channel forced on, written to rNR51 on every tick of a
; sound effect
    ds 1                                               ;; df7a

wDF7B_Audio_ChannelIndex:
; 0-3, the channel Audio_UpdateMusic is currently working on. gex2 keeps the same thing
; in wDFB8_Audio_ChannelIndex
    ds 1                                               ;; df7b

wDF7C_Audio_Ch1_CurrentNote:
; The transposed note index channel 1 is playing, so its arpeggio has something to work
; relative to. There is no channel 4 entry because channel 4 has no arpeggio
    ds 1                                               ;; df7c

wDF7D_Audio_Ch2_CurrentNote:
    ds 1                                               ;; df7d

wDF7E_Audio_Ch3_CurrentNote:
    ds 1                                               ;; df7e

; unused to the end of wram
    ds 129                                             ;; df7f

SECTION "hram", HRAM[$ff80]

hFF80_OamDmaRoutine:
; call_00_0e29_OamDmaRoutine is copied here at boot and called from vblank. It
; has to run out of HRAM because the CPU can reach nothing else while an OAM
; DMA is in progress. gex2 does the same at hFF80_OamDmaRoutine
    ds 112                                             ;; ff80
hFFF0:
    ds 12                                              ;; fff0
hFFFC:
    ds 1                                               ;; fffc
hFFFD:
    ds 1                                               ;; fffd
hFFFE:
    ds 1                                               ;; fffe

SECTION "vram", VRAM[$8000]
    ds 8192                                            ;; 8000

SECTION "sram", SRAM[$a000]
    ds 8192                                            ;; a000
