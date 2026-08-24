call_01_43c3_Menu_HighlightTitleOption:
; The title screen's callback, and the only one in the game. Copies two OBJ palettes
; into wDD4A_ObjectPalettes, choosing between two sources eight bytes apart - so the
; two copies are the same pair of palettes in opposite order, and the effect is that
; the selected option is bright and the other dim.
;
; Reached only through call_01_43ba_Menu_OnSelectionChanged; nothing calls it by
; name
    ld   HL, .data_01_43d8                            ;; 01:43c3 $21 $d8 $43
    ld   A, [wDBEC_MenuRowSelected]                   ;; 01:43c6 $fa $ec $db
    and  A, A                                         ;; 01:43c9 $a7
    jr   Z, .jr_01_43cf                               ;; 01:43ca $28 $03
    ld   HL, .data_01_43e0                            ;; 01:43cc $21 $e0 $43
.jr_01_43cf:
    ld   DE, wDD4A_ObjectPalettes                     ;; 01:43cf $11 $4a $dd
    ld   BC, CGB_PALETTE_SIZE * 2                     ;; 01:43d2 $01 $10 $00
    jp   call_00_076e_MemCopy                         ;; 01:43d5 $c3 $6e $07
.data_01_43d8:
    db   $00, $00, $ff, $7f, $f7, $5e, $ef, $3d       ;; 01:43d8 ........
.data_01_43e0:
    db   $00, $00, $ef, $3d, $6b, $2d, $e7, $1c       ;; 01:43e0 ........
    db   $00, $00, $ff, $7f, $f7, $5e, $ef, $3d       ;; 01:43e8 ........

call_01_43f0_Menu_BuildScreen:
; Builds one menu screen and returns. Runs once per screen, not once per frame -
; the old "MainLoop" name was doubly wrong.
;
; Clears the video state, both screen planes and the tile staging buffer, declares no
; cursor and no sprite-hide timer, and installs LCD_ISR_MENU_GFX_STREAM. Then it runs
; the menu's script through call_01_445c_MenuScript_RunToEnd. A command may set
; wDBDD_Menu_ChainedScript, and if it did, the chosen script from
; data_01_5596_ChainedScriptTable is run too - so a screen can be assembled from a
; common part plus a variable part.
;
; Only when the chain is exhausted does anything reach VRAM: the attribute plane, then
; the tile-id plane, then the palette set unless MENU_PALETTE_NONE_BIT says this
; screen keeps the current one. Finally the per-menu callback, MENU_LCDC, and
; wDD6A_PalettesReadyFlag - which is what un-blanks the screen, so the whole build is
; invisible.
;
; gex2's call_01_446f_LoadMenuGraphics
    push HL                                           ;; 01:43f0 $e5
    call call_00_0e3b_ResetVideoState                 ;; 01:43f1 $cd $3b $0e
    call call_00_0e62_ClearShadowOamAndResetScroll    ;; 01:43f4 $cd $62 $0e
    call call_01_4f27_Menu_ClearScreenBuffers         ;; 01:43f7 $cd $27 $4f
    ld   A, MENU_CURSOR_NONE                          ;; 01:43fa $3e $ff
    ld   [wDBC7_Menu_CursorSpriteId], A               ;; 01:43fc $ea $c7 $db
    xor  A, A                                         ;; 01:43ff $af
    ld   [wDBDE_Menu_HideSpritesDelay], A             ;; 01:4400 $ea $de $db
    ld   [wDBE3_Menu_AnimateFlag], A                  ;; 01:4403 $ea $e3 $db
    ld   A, LCD_ISR_MENU_GFX_STREAM                   ;; 01:4406 $3e $0a
    call call_00_0c10_RequestLcdIsr                   ;; 01:4408 $cd $10 $0c
    pop  HL                                           ;; 01:440b $e1
.jr_01_440c:
    ld   A, L                                         ;; 01:440c $7d
    ld   [wDBB9_MenuScript_Ptr], A                    ;; 01:440d $ea $b9 $db
    ld   A, H                                         ;; 01:4410 $7c
    ld   [wDBB9_MenuScript_Ptr+1], A                  ;; 01:4411 $ea $ba $db
    ld   A, MENU_CHAINED_NONE                         ;; 01:4414 $3e $ff
    ld   [wDBDD_Menu_ChainedScript], A                ;; 01:4416 $ea $dd $db
    call call_01_445c_MenuScript_RunToEnd             ;; 01:4419 $cd $5c $44
    ld   A, [wDBDD_Menu_ChainedScript]                ;; 01:441c $fa $dd $db
    cp   A, MENU_CHAINED_NONE                         ;; 01:441f $fe $ff
    jr   Z, .jr_01_442b                               ;; 01:4421 $28 $08
    ld   DE, data_01_5596_ChainedScriptTable          ;; 01:4423 $11 $96 $55
    call call_00_0777_GetPointerFromTable             ;; 01:4426 $cd $77 $07
    jr   .jr_01_440c                                  ;; 01:4429 $18 $e1
.jr_01_442b:
    call call_01_4f51_Menu_UploadBgAttrMap            ;; 01:442b $cd $51 $4f
    call call_01_4f5c_Menu_UploadBgTileMap            ;; 01:442e $cd $5c $4f
    ld   HL, wDB9B_MenuType_PaletteId                 ;; 01:4431 $21 $9b $db
    bit  MENU_PALETTE_NONE_BIT, [HL]                  ;; 01:4434 $cb $7e
    jr   NZ, .jr_01_4444                              ;; 01:4436 $20 $0c
    ld   C, [HL]                                      ;; 01:4438 $4e
    farcall call_03_65c6_Palettes_LoadForScreen
.jr_01_4444:
    call call_01_43ba_Menu_OnSelectionChanged         ;; 01:4444 $cd $ba $43
    ld   A, MENU_LCDC                                 ;; 01:4447 $3e $d3
    call call_00_0e33_SetLCDCAndWait                  ;; 01:4449 $cd $33 $0e
    ld   A, $01                                       ;; 01:444c $3e $01
    ld   [wDD6A_PalettesReadyFlag], A                 ;; 01:444e $ea $6a $dd
    jp   call_00_0b92_WaitForInterrupt                ;; 01:4451 $c3 $92 $0b

call_01_4454_MenuScript_RunFrom:
; Points the script cursor at HL and FALLS THROUGH into the runner below, so this
; runs the whole script rather than merely setting a pointer.
;
; Its one caller is the totals screen's page turn, which re-runs the same script after
; changing the page number. gex2's call_01_44cf_MenuScript_RunFrom, which is the same
; fall-through construct
    ld   A, L                                         ;; 01:4454 $7d
    ld   [wDBB9_MenuScript_Ptr], A                    ;; 01:4455 $ea $b9 $db
    ld   A, H                                         ;; 01:4458 $7c
    ld   [wDBB9_MenuScript_Ptr+1], A                  ;; 01:4459 $ea $ba $db

call_01_445c_MenuScript_RunToEnd:
; Runs commands until MENUSCRIPT_END. Note it reloads wDBB9_MenuScript_Ptr from WRAM
; on every iteration rather than keeping it in a register: a command is free to
; redirect the script, and this is what lets it. gex2's
; call_01_44d7_MenuScript_RunToEnd
    ld   HL, wDBB9_MenuScript_Ptr                     ;; 01:445c $21 $b9 $db
    ld   A, [HL+]                                     ;; 01:445f $2a
    ld   H, [HL]                                      ;; 01:4460 $66
    ld   L, A                                         ;; 01:4461 $6f
    ld   A, [HL]                                      ;; 01:4462 $7e
    cp   A, MENUSCRIPT_END                            ;; 01:4463 $fe $ff
    ret  Z                                            ;; 01:4465 $c8
    call call_01_446b_MenuScript_RunCommand           ;; 01:4466 $cd $6b $44
    jr   call_01_445c_MenuScript_RunToEnd             ;; 01:4469 $18 $f1

call_01_446b_MenuScript_RunCommand:
; One command. The heart of the file - the file header walks through what it can do.
;
; The opcode is consumed first and its shape copied out of
; data_01_512e_MenuCmd_Descriptors. Then the parameter-block loop, which is a real
; loop: blocks are processed until one carries MENUCMD_FLAG_LAST_BLOCK, so a single
; opcode can paint several places on the screen.
;
; The tilemap fill at the end is one piece of code writing two planes. It computes the
; destination once as wD400_ScreenDraw_TileIds + Y*20 + X, fills the attribute plane
; SCREEN_ATTR_PLANE_OFFSET above it, then fills the tile-id plane with consecutive ids
; from wDBA2_MenuCmd_FirstTileId. MENUCMD_FLAG_TRANSPOSED swaps the two loop counters
; and the SCREEN_FILL_STEP_* pair, which is the whole of "draw this block sideways".
;
; gex2's call_01_44e6_MenuScript_RunCommand
    ld   HL, wDBB9_MenuScript_Ptr                     ;; 01:446b $21 $b9 $db
    ld   E, [HL]                                      ;; 01:446e $5e
    inc  HL                                           ;; 01:446f $23
    ld   D, [HL]                                      ;; 01:4470 $56
    ld   A, [DE]                                      ;; 01:4471 $1a
    inc  DE                                           ;; 01:4472 $13
    ld   [HL], D                                      ;; 01:4473 $72
    dec  HL                                           ;; 01:4474 $2b
    ld   [HL], E                                      ;; 01:4475 $73
    ld   [wDBCA_MenuCmd_Id], A                        ;; 01:4476 $ea $ca $db
    ld   L, A                                         ;; 01:4479 $6f
    ld   H, $00                                       ;; 01:447a $26 $00
    add  HL, HL                                       ;; 01:447c $29
    add  HL, HL                                       ;; 01:447d $29
    add  HL, HL                                       ;; 01:447e $29
    ld   DE, data_01_512e_MenuCmd_Descriptors         ;; 01:447f $11 $2e $51
    add  HL, DE                                       ;; 01:4482 $19
    ld   DE, wDB9E_MenuCmd_WidthTiles                 ;; 01:4483 $11 $9e $db
    ld   BC, MENUCMD_DESCRIPTOR_COPY_BYTES            ;; 01:4486 $01 $06 $00
    call call_00_076e_MemCopy                         ;; 01:4489 $cd $6e $07
.jr_01_448c:
    ld   HL, wDBB9_MenuScript_Ptr                     ;; 01:448c $21 $b9 $db
    ld   A, [HL+]                                     ;; 01:448f $2a
    ld   H, [HL]                                      ;; 01:4490 $66
    ld   L, A                                         ;; 01:4491 $6f
    ld   DE, wDBA4_Text_PenX                          ;; 01:4492 $11 $a4 $db
    ld   BC, MENUCMD_PARAM_BYTES                      ;; 01:4495 $01 $07 $00
    call call_00_076e_MemCopy                         ;; 01:4498 $cd $6e $07
    ld   A, L                                         ;; 01:449b $7d
    ld   [wDBB9_MenuScript_Ptr], A                    ;; 01:449c $ea $b9 $db
    ld   A, H                                         ;; 01:449f $7c
    ld   [wDBB9_MenuScript_Ptr+1], A                  ;; 01:44a0 $ea $ba $db
    ld   A, [wDBA9_MenuCmd_OptionSlot]                ;; 01:44a3 $fa $a9 $db
    and  A, MENUCMD_OPTION_ROW_MASK                   ;; 01:44a6 $e6 $0f
    ld   L, A                                         ;; 01:44a8 $6f
    ld   H, $00                                       ;; 01:44a9 $26 $00
    ld   DE, wDBCB_Menu_OptionActions                 ;; 01:44ab $11 $cb $db
    add  HL, DE                                       ;; 01:44ae $19
    ld   A, [wDBA9_MenuCmd_OptionSlot]                ;; 01:44af $fa $a9 $db
    and  A, MENUCMD_OPTION_ACTION_MASK                ;; 01:44b2 $e6 $f0
    ld   [HL], A                                      ;; 01:44b4 $77
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44b5 $fa $aa $db
    and  A, MENUCMD_FLAG_CLEAR_BUFFER                 ;; 01:44b8 $e6 $01
    call NZ, call_01_499f_Text_ClearBuffer            ;; 01:44ba $c4 $9f $49
    ld   A, [wDBA8_MenuCmd_SrcPtrHi]                  ;; 01:44bd $fa $a8 $db
    sub  A, MENUCMD_HANDLER_BASE                      ;; 01:44c0 $d6 $e0
    jr   C, .jr_01_44cd                               ;; 01:44c2 $38 $09
    ld   DE, .data_01_456b_MenuCmd_SubHandlers        ;; 01:44c4 $11 $6b $45
    call call_00_0777_GetPointerFromTable             ;; 01:44c7 $cd $77 $07
    call call_00_0f22_JumpHL                          ;; 01:44ca $cd $22 $0f
.jr_01_44cd:
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44cd $fa $aa $db
    and  A, MENUCMD_FLAG_DRAW_TEXT                    ;; 01:44d0 $e6 $02
    call NZ, call_01_4875_Text_Render                 ;; 01:44d2 $c4 $75 $48
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44d5 $fa $aa $db
    and  A, MENUCMD_FLAG_LAST_BLOCK                   ;; 01:44d8 $e6 $20
    jr   Z, .jr_01_448c                               ;; 01:44da $28 $b0
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44dc $fa $aa $db
    and  A, MENUCMD_FLAG_NO_TILE_FILL                 ;; 01:44df $e6 $40
    jp   NZ, .jp_01_4560                              ;; 01:44e1 $c2 $60 $45
    ld   HL, wDBA0_MenuCmd_DestTileX                  ;; 01:44e4 $21 $a0 $db
    ld   E, [HL]                                      ;; 01:44e7 $5e
    ld   D, $00                                       ;; 01:44e8 $16 $00
    inc  HL                                           ;; 01:44ea $23
    ld   L, [HL]                                      ;; 01:44eb $6e
    ld   H, D                                         ;; 01:44ec $62
    add  HL, HL                                       ;; 01:44ed $29
    add  HL, HL                                       ;; 01:44ee $29
    ld   C, L                                         ;; 01:44ef $4d
    ld   B, H                                         ;; 01:44f0 $44
    add  HL, HL                                       ;; 01:44f1 $29
    add  HL, HL                                       ;; 01:44f2 $29
    add  HL, BC                                       ;; 01:44f3 $09
    add  HL, DE                                       ;; 01:44f4 $19
    ld   DE, wD400_ScreenDraw_TileIds                 ;; 01:44f5 $11 $00 $d4
    add  HL, DE                                       ;; 01:44f8 $19
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:44f9 $fa $aa $db
    and  A, MENUCMD_FLAG_TRANSPOSED                   ;; 01:44fc $e6 $04
    jr   NZ, .jr_01_450d                              ;; 01:44fe $20 $0d
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:4500 $fa $9e $db
    ld   B, A                                         ;; 01:4503 $47
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:4504 $fa $9f $db
    ld   C, A                                         ;; 01:4507 $4f
    ld   DE, SCREEN_FILL_STEP_ROWS                    ;; 01:4508 $11 $01 $14
    jr   .jr_01_4518                                  ;; 01:450b $18 $0b
.jr_01_450d:
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:450d $fa $9e $db
    ld   C, A                                         ;; 01:4510 $4f
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:4511 $fa $9f $db
    ld   B, A                                         ;; 01:4514 $47
    ld   DE, SCREEN_FILL_STEP_COLUMNS                 ;; 01:4515 $11 $14 $01
.jr_01_4518:
    push HL                                           ;; 01:4518 $e5
    push BC                                           ;; 01:4519 $c5
    ld   BC, SCREEN_ATTR_PLANE_OFFSET                 ;; 01:451a $01 $78 $01
    add  HL, BC                                       ;; 01:451d $09
    pop  BC                                           ;; 01:451e $c1
    push BC                                           ;; 01:451f $c5
    ld   A, [wDBA3_MenuCmd_AttrByte]                  ;; 01:4520 $fa $a3 $db
    cp   A, MENUCMD_ATTR_TILESET_ROW                  ;; 01:4523 $fe $ff
    jr   NZ, .jr_01_452e                              ;; 01:4525 $20 $07
    call call_00_0800_Screen_LoadSecondaryTilesetRow  ;; 01:4527 $cd $00 $08
    pop  BC                                           ;; 01:452a $c1
    pop  HL                                           ;; 01:452b $e1
    jr   .jr_01_4546                                  ;; 01:452c $18 $18
.jr_01_452e:
    push BC                                           ;; 01:452e $c5
    push DE                                           ;; 01:452f $d5
    push DE                                           ;; 01:4530 $d5
    push HL                                           ;; 01:4531 $e5
    ld   D, $00                                       ;; 01:4532 $16 $00
.jr_01_4534:
    ld   [HL], A                                      ;; 01:4534 $77
    add  HL, DE                                       ;; 01:4535 $19
    dec  B                                            ;; 01:4536 $05
    jr   NZ, .jr_01_4534                              ;; 01:4537 $20 $fb
    pop  HL                                           ;; 01:4539 $e1
    pop  DE                                           ;; 01:453a $d1
    ld   E, D                                         ;; 01:453b $5a
    ld   D, $00                                       ;; 01:453c $16 $00
    add  HL, DE                                       ;; 01:453e $19
    pop  DE                                           ;; 01:453f $d1
    pop  BC                                           ;; 01:4540 $c1
    dec  C                                            ;; 01:4541 $0d
    jr   NZ, .jr_01_452e                              ;; 01:4542 $20 $ea
    pop  BC                                           ;; 01:4544 $c1
    pop  HL                                           ;; 01:4545 $e1
.jr_01_4546:
    ld   A, [wDBA2_MenuCmd_FirstTileId]               ;; 01:4546 $fa $a2 $db
.jr_01_4549:
    push BC                                           ;; 01:4549 $c5
    push DE                                           ;; 01:454a $d5
    push DE                                           ;; 01:454b $d5
    push HL                                           ;; 01:454c $e5
    ld   D, $00                                       ;; 01:454d $16 $00
.jr_01_454f:
    ld   [HL], A                                      ;; 01:454f $77
    inc  A                                            ;; 01:4550 $3c
    add  HL, DE                                       ;; 01:4551 $19
    dec  B                                            ;; 01:4552 $05
    jr   NZ, .jr_01_454f                              ;; 01:4553 $20 $fa
    pop  HL                                           ;; 01:4555 $e1
    pop  DE                                           ;; 01:4556 $d1
    ld   E, D                                         ;; 01:4557 $5a
    ld   D, $00                                       ;; 01:4558 $16 $00
    add  HL, DE                                       ;; 01:455a $19
    pop  DE                                           ;; 01:455b $d1
    pop  BC                                           ;; 01:455c $c1
    dec  C                                            ;; 01:455d $0d
    jr   NZ, .jr_01_4549                              ;; 01:455e $20 $e9
.jp_01_4560:
    ld   A, [wDBAA_MenuCmd_Flags]                     ;; 01:4560 $fa $aa $db
    and  A, MENUCMD_FLAG_UPLOAD_TILES                 ;; 01:4563 $e6 $80
    ret  Z                                            ;; 01:4565 $c8
    ld   C, HDMACFG_WRAM_TILES_BANK0                  ;; 01:4566 $0e $09
    jp   call_00_0a6a_Hdma_RunConfigEntry             ;; 01:4568 $c3 $6a $0a
.data_01_456b_MenuCmd_SubHandlers: ; probably menutype jump table
; Behavior:
; List of function pointers (call_01_458d_MenuCmd_StageImage1, call_01_4599_MenuCmd_StageImage2, etc.) for specific menu command handlers.
; Likely Purpose: Dispatch table for specialized menu drawing or behavior.
    dw   call_01_458d_MenuCmd_StageImage1             ;; 01:456b ??
    dw   call_01_4599_MenuCmd_StageImage2             ;; 01:456d pP
    dw   call_01_45a5_MenuCmd_StageTVScreen           ;; 01:456f pP
    dw   call_01_466f_MenuCmd_SetLevelText            ;; 01:4571 pP
    dw   call_01_4675_MenuCmd_SetTVNameText           ;; 01:4573 pP
    dw   call_01_467b_MenuCmd_SetMissionText          ;; 01:4575 pP
    dw   call_01_46d4_MenuCmd_DrawCursorSprite        ;; 01:4577 pP
    dw   call_01_46f9_MenuCmd_EnableSpriteAnimation   ;; 01:4579 pP
    dw   call_01_470c_MenuCmd_SetCounterText          ;; 01:457b pP
    dw   call_01_4760_MenuCmd_DrawSpriteGroup         ;; 01:457d pP
    dw   call_01_477b_MenuCmd_NoOp                    ;; 01:457f ??
    dw   call_01_477c_MenuCmd_StagePasswordGlyph      ;; 01:4581 pP
    dw   call_01_47aa_MenuCmd_SetChainedScript        ;; 01:4583 pP
    dw   call_01_47b1_MenuCmd_LoadFullscreenImage     ;; 01:4585 pP
    dw   call_01_480c_MenuCmd_SetCollectedCountText
    dw   call_01_4825_MenuCmd_NoOp2
    dw   call_01_4826_MenuCmd_DrawRemoteMarker

call_01_458d_MenuCmd_StageImage1:
; Sub-handler $E0. Stages one small image from data_01_6f39_ImageTable into the tile
; buffer.
;
; This routine and call_01_4599_MenuCmd_StageImage2 below are byte for byte the same -
; same table, same target. gex2's $E0 and $E1 handlers use two DIFFERENT image tables;
; gex3 collapsed them onto one and kept both slots, so the two opcodes are aliases.
; gex2's call_01_4653_MenuCmd_StageImage1
    ld   a,[wDBA7_MenuCmd_SrcPtr]
    ld   de,data_01_6f39_ImageTable
    call call_00_0777_GetPointerFromTable
    jp   call_01_4d03_Menu_StageTileData

call_01_4599_MenuCmd_StageImage2:
; Sub-handler $E1, and identical to the one above. This is the copy with a second
; caller: call_01_46d4_MenuCmd_DrawCursorSprite uses it directly to stage the cursor
; graphic. gex2's call_01_465f_MenuCmd_StageImage2
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:4599 $fa $a7 $db
    ld   DE, data_01_6f39_ImageTable                  ;; 01:459c $11 $39 $6f
    call call_00_0777_GetPointerFromTable             ;; 01:459f $cd $77 $07
    jp   call_01_4d03_Menu_StageTileData              ;; 01:45a2 $c3 $03 $4d

call_01_45a5_MenuCmd_StageTVScreen:
; Sub-handler $E2. Loads eight BG palettes from the inline table, overwrites the last
; four of them with the current map's own palettes out of BANK_1F_SECONDARY_TILESETS,
; and stages an 8x6 tile picture from that same tileset - the image inside the TV on
; the mission select screen.
;
; The `ld DE, $330` is the offset of the palette block inside a secondary tileset
; record and is otherwise unexplained; the `$c010` destination is
; wC000_BgMapTileIds one tile in.
;
; gex2's call_01_466b_MenuCmd_StageTVScreen does the same job with a 6x5 picture
    ld   HL, .data_01_45ef                            ;; 01:45a5 $21 $ef $45
    ld   DE, wDCEA_BgPalettes                         ;; 01:45a8 $11 $ea $dc
    ld   BC, $80                                      ;; 01:45ab $01 $80 $00
    call call_00_076e_MemCopy                         ;; 01:45ae $cd $6e $07
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:45b1 $fa $6c $db
    ld   DE, data_00_0b01_SecondaryTilesetPtrs        ;; 01:45b4 $11 $01 $0b
    call call_00_0777_GetPointerFromTable             ;; 01:45b7 $cd $77 $07
    ld   DE, $330                                     ;; 01:45ba $11 $30 $03
    add  HL, DE                                       ;; 01:45bd $19
    ld   DE, wDD0A_BgPalettes                         ;; 01:45be $11 $0a $dd
    ld   BC, $20                                      ;; 01:45c1 $01 $20 $00
    ld   A, BANK_1F_SECONDARY_TILESETS                ;; 01:45c4 $3e $1f
    call call_00_075f_FarMemCopy                      ;; 01:45c6 $cd $5f $07
    ld   A, [wDB6C_CurrentMapId]                      ;; 01:45c9 $fa $6c $db
    ld   DE, data_00_0b01_SecondaryTilesetPtrs        ;; 01:45cc $11 $01 $0b
    call call_00_0777_GetPointerFromTable             ;; 01:45cf $cd $77 $07
    ld   A, [wDBA6_MenuCmd_Arg2]                      ;; 01:45d2 $fa $a6 $db
    ld   [wDBA2_MenuCmd_FirstTileId], A               ;; 01:45d5 $ea $a2 $db
    ld   A, $08                                       ;; 01:45d8 $3e $08
    ld   [wDB9E_MenuCmd_WidthTiles], A                ;; 01:45da $ea $9e $db
    ld   A, $06                                       ;; 01:45dd $3e $06
    ld   [wDB9F_MenuCmd_HeightTiles], A               ;; 01:45df $ea $9f $db
    push HL                                           ;; 01:45e2 $e5
    call call_01_4ce5_Menu_GetTileDataSize            ;; 01:45e3 $cd $e5 $4c
    pop  HL                                           ;; 01:45e6 $e1
    ld   DE, $c010                                    ;; 01:45e7 $11 $10 $c0 ; wC000_BgMapTileIds
    ld   A, BANK_1F_SECONDARY_TILESETS                ;; 01:45ea $3e $1f
    jp   call_00_075f_FarMemCopy                      ;; 01:45ec $c3 $5f $07
.data_01_45ef:
    db   $00, $00, $00, $40, $ff, $03, $ff, $7f       ;; 01:45ef ........
    db   $00, $40, $ff, $03, $73, $02, $29, $01       ;; 01:45f7 ........
    db   $00, $40, $bf, $1e, $fa, $11, $2d, $11       ;; 01:45ff ........
    db   $00, $00, $00, $40, $ff, $7f, $80, $03       ;; 01:4607 ........
    db   $00, $40, $00, $00, $73, $4e, $1f, $00       ;; 01:460f ........
    db   $00, $40, $00, $00, $1f, $00, $ff, $03       ;; 01:4617 ........
    db   $00, $40, $00, $00, $60, $02, $9c, $03       ;; 01:461f ........
    db   $00, $40, $00, $00, $ff, $03, $e0, $03       ;; 01:4627 ........

    db   $00, $00, $80, $00, $20, $02, $20, $03       ;; 01:462f ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:4637 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 01:463f ........
    db   $00, $00, $00, $00, $73, $4e, $1f, $00       ;; 01:4647 ........
    db   $00, $00, $ef, $3d, $f7, $5e, $ff, $7f       ;; 01:464f ........
    db   $00, $00, $ef, $01, $f7, $02, $ff, $03       ;; 01:4657 ........
    db   $00, $00, $00, $00, $20, $03, $bf, $0b       ;; 01:465f ........
    db   $00, $00, $1f, $00, $ff, $01, $7f, $03       ;; 01:4667 ........

call_01_466f_MenuCmd_SetLevelText:
; Sub-handler $E3. Points the text source at record 0 of this map's text block, i.e.
; the level name. Two calls and no logic; the offset lives in
; call_01_4b22_MenuText_GetLevelNameTable.
;
; It draws nothing - the DRAW_TEXT flag on this or a later block does that. gex2's
; call_01_4734_MenuCmd_SetLevelText
    call call_01_4b22_MenuText_GetLevelNameTable      ;; 01:466f $cd $22 $4b
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:4672 $c3 $fa $4c

call_01_4675_MenuCmd_SetTVNameText:
; Sub-handler $E4. The same for record 1 of the block, ten bytes further in - the TV's
; name. gex2's call_01_4728_MenuCmd_SetTVNameText
    call call_01_4b2a_MenuText_GetTVNameTable         ;; 01:4675 $cd $2a $4b
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:4678 $c3 $fa $4c

call_01_467b_MenuCmd_SetMissionText:
; Sub-handler $E5. Two jobs for one command: draw the little "remote collected" marker
; for mission wDBA7_MenuCmd_SrcPtr, and point the text source at that mission's
; description.
;
; The marker's tile is REMOTE_MARKER_TILE_TAKEN or _MISSING depending on the mission's
; bit in wDC5C_ProgressFlags, and its screen position is derived from the command
; block's OWN destination tile - two rows below and one column left - so the marker
; follows the text without the script having to place it. It lands in OAM slots
; 4, 8 and 12 (`arg * 4 + 4`), leaving the first four for the cursor.
;
; gex2's call_01_473a_MenuCmd_SetMissionText
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:467b $21 $a7 $db
    ld   L, [HL]                                      ;; 01:467e $6e
    ld   H, $00                                       ;; 01:467f $26 $00
    ld   DE, .data_01_46d1                            ;; 01:4681 $11 $d1 $46
    add  HL, DE                                       ;; 01:4684 $19
    ld   C, [HL]                                      ;; 01:4685 $4e
    ld   HL, wDB6C_CurrentMapId                       ;; 01:4686 $21 $6c $db
    ld   L, [HL]                                      ;; 01:4689 $6e
    ld   H, $00                                       ;; 01:468a $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 01:468c $11 $5c $dc
    add  HL, DE                                       ;; 01:468f $19
    ld   A, [HL]                                      ;; 01:4690 $7e
    and  A, C                                         ;; 01:4691 $a1
    ld   C, REMOTE_MARKER_TILE_TAKEN                  ;; 01:4692 $0e $e4
    jr   NZ, .jr_01_4698                              ;; 01:4694 $20 $02
    ld   C, REMOTE_MARKER_TILE_MISSING                ;; 01:4696 $0e $e8
.jr_01_4698:
    ld   A, C                                         ;; 01:4698 $79
    ld   [wDADF], A                                   ;; 01:4699 $ea $df $da
    ld   A, [wDBA1_MenuCmd_DestTileY]                 ;; 01:469c $fa $a1 $db
    add  A, $02                                       ;; 01:469f $c6 $02
    add  A, A                                         ;; 01:46a1 $87
    add  A, A                                         ;; 01:46a2 $87
    add  A, A                                         ;; 01:46a3 $87
    ld   [wDADD_MenuTextBuffer], A                    ;; 01:46a4 $ea $dd $da
    ld   A, [wDBA0_MenuCmd_DestTileX]                 ;; 01:46a7 $fa $a0 $db
    inc  A                                            ;; 01:46aa $3c
    sub  A, $02                                       ;; 01:46ab $d6 $02
    add  A, A                                         ;; 01:46ad $87
    add  A, A                                         ;; 01:46ae $87
    add  A, A                                         ;; 01:46af $87
    ld   [wDADE], A                                   ;; 01:46b0 $ea $de $da
    ld   A, $03                                       ;; 01:46b3 $3e $03
    ld   [wDAE0], A                                   ;; 01:46b5 $ea $e0 $da
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:46b8 $fa $a7 $db
    add  A, A                                         ;; 01:46bb $87
    add  A, A                                         ;; 01:46bc $87
    add  A, $04                                       ;; 01:46bd $c6 $04
    ld   [wDBDB_Menu_OamSlot], A                      ;; 01:46bf $ea $db $db
    ld   BC, $202                                     ;; 01:46c2 $01 $02 $02
    call call_01_4c7e_Menu_WriteSpriteRect            ;; 01:46c5 $cd $7e $4c
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:46c8 $fa $a7 $db
    call call_01_4b32_MenuText_GetMissionTable        ;; 01:46cb $cd $32 $4b
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:46ce $c3 $fa $4c
.data_01_46d1:
    db   $01, $02, $04                                ;; 01:46d1 ...

call_01_46d4_MenuCmd_DrawCursorSprite:
; Sub-handler $E6. Declares this screen's selection cursor, once. It stages the cursor
; graphic, fills in the sprite record at wDBBF_MenuCursor_OamSlot from the command's
; own width and height, and stores the cursor image id in
; wDBC7_Menu_CursorSpriteId - MENU_CURSOR_NONE meaning there is none.
;
; From then on call_01_4bb8_Menu_DrawCursor rebuilds the cursor from that record every
; frame, which is why a script declares it exactly once and never again. The
; `sub A, $00 / add A, $00` pair is dead: gex2's version adds a cursor id base there
; and gex3's base is zero.
;
; gex2's call_01_47c5_MenuCmd_DrawCursorSprite
    call call_01_4599_MenuCmd_StageImage2             ;; 01:46d4 $cd $99 $45
    xor  A, A                                         ;; 01:46d7 $af
    ld   [wDBBF_MenuCursor_OamSlot], A                ;; 01:46d8 $ea $bf $db
    ld   A, [wDB9E_MenuCmd_WidthTiles]                ;; 01:46db $fa $9e $db
    ld   [wDBC4_MenuCursor_WidthTiles], A             ;; 01:46de $ea $c4 $db
    ld   A, [wDB9F_MenuCmd_HeightTiles]               ;; 01:46e1 $fa $9f $db
    ld   [wDBC5_MenuCursor_HeightTiles], A            ;; 01:46e4 $ea $c5 $db
    ld   A, SPRITE_RECORD_END                         ;; 01:46e7 $3e $ff
    ld   [wDBC6_MenuCursor_RecordEnd], A              ;; 01:46e9 $ea $c6 $db
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:46ec $fa $a7 $db
    sub  A, $00                                       ;; 01:46ef $d6 $00
    add  A, $00                                       ;; 01:46f1 $c6 $00
    ld   [wDBC7_Menu_CursorSpriteId], A               ;; 01:46f3 $ea $c7 $db
    jp   call_01_4bb8_Menu_DrawCursor                 ;; 01:46f6 $c3 $b8 $4b

call_01_46f9_MenuCmd_EnableSpriteAnimation:
; Sub-handler $E7. Sets wDBE3_Menu_AnimateFlag and zeroes the four counters that go
; with it. Small, but it is the switch that makes a screen's sprites animate rather
; than sit still. No gex2 counterpart - gex2's slot in this position draws the remote
; icons instead
    xor  A, A                                         ;; 01:46f9 $af
    ld   [wDBE4], A                                   ;; 01:46fa $ea $e4 $db
    ld   [wDBE5], A                                   ;; 01:46fd $ea $e5 $db
    ld   [wDBE6], A                                   ;; 01:4700 $ea $e6 $db
    ld   [wDBE7], A                                   ;; 01:4703 $ea $e7 $db
    ld   A, $01                                       ;; 01:4706 $3e $01
    ld   [wDBE3_Menu_AnimateFlag], A                  ;; 01:4708 $ea $e3 $db
    ret                                               ;; 01:470b $c9

call_01_470c_MenuCmd_SetCounterText:
; Sub-handler $E8. Puts a NUMBER on the screen - lives remaining, coins collected,
; missions done.
;
; It writes TEXT_TERMINATOR into the buffer so the string starts empty, asks
; call_01_4722_MenuCmd_GetCounterValue for the value, and then checks whether the
; buffer is still empty: a counter handler is allowed to write its own text instead of
; returning a number, and only if it did not does this format A into digits. The text
; source is then pointed at the buffer.
;
; gex2's call_01_47ea_MenuCmd_SetCounterText
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:470c $21 $dd $da
    ld   [HL], TEXT_TERMINATOR                        ;; 01:470f $36 $80
    call call_01_4722_MenuCmd_GetCounterValue         ;; 01:4711 $cd $22 $47
    ld   HL, wDADD_MenuTextBuffer                     ;; 01:4714 $21 $dd $da
    bit  7, [HL]                                      ;; 01:4717 $cb $7e
    call NZ, call_01_4d49_Text_FormatByte             ;; 01:4719 $c4 $49 $4d
    ld   HL, MENUTEXT_COUNTER_STRINGS                 ;; 01:471c $21 $97 $4e
    jp   call_01_4cfa_Menu_SetScriptSrcPtr            ;; 01:471f $c3 $fa $4c

call_01_4722_MenuCmd_GetCounterValue:
; Returns one of twelve numbers in A, chosen by wDBA7_MenuCmd_SrcPtr. This is a
; ROUTINE with an embedded table, not a table - the old name read like a data label.
;
; The interesting half is that most of the entries are popcounts over
; wDC5C_ProgressFlags rather than stored totals: the game does not keep a "missions
; completed" counter anywhere, it counts the bits every time the screen is drawn. The
; rest are wDC68_CollectibleAmount, wDCAF_PawCoinCounter, wDC4E_LivesRemaining, the
; level's collectible total, and three hardcoded constants.
;
; gex2's call_01_47f6_MenuCmd_GetCounterValue
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:4722 $fa $a7 $db
    ld   DE, .data_01_472c                            ;; 01:4725 $11 $2c $47
    call call_00_0777_GetPointerFromTable             ;; 01:4728 $cd $77 $07
    jp   HL                                           ;; 01:472b $e9
.data_01_472c:
    dw   call_01_4acf_CountCollectedBitsForLevel      ;; 01:472c pP
    dw   call_01_4b0a_CountHighBitsForLevel           ;; 01:472e pP
    dw   call_01_4af9_IsLevelBonusCoinTaken           ;; 01:4730 pP
    dw   .jp_01_4744                                  ;; 01:4732 pP
    dw   call_01_4ae7_CountLevelsWithBonusCoin        ;; 01:4734 pP
    dw   .jp_01_4748                                  ;; 01:4736 pP
    dw   call_01_4ab9_CountAllCollectedObjectives     ;; 01:4738 pP
    dw   .jp_01_474c                                  ;; 01:473a pP
    dw   .jp_01_4756                                  ;; 01:473c pP
    dw   .jp_01_4759                                  ;; 01:473e pP
    dw   .jp_01_475c                                  ;; 01:4740 pP
    dw   call_00_2f34_CountLevelCollectibleTotal      ;; 01:4742 ??
.jp_01_4744:
    ld   A, [wDC68_CollectibleAmount]                 ;; 01:4744 $fa $68 $dc
    ret                                               ;; 01:4747 $c9
.jp_01_4748:
    ld   A, [wDCAF_PawCoinCounter]                    ;; 01:4748 $fa $af $dc
    ret                                               ;; 01:474b $c9
.jp_01_474c:
    ld   A, [wDC1E_CurrentLevelID]                    ;; 01:474c $fa $1e $dc
    and  A, A                                         ;; 01:474f $a7
    ld   A, $01                                       ;; 01:4750 $3e $01
    ret  Z                                            ;; 01:4752 $c8
    ld   A, $04                                       ;; 01:4753 $3e $04
    ret                                               ;; 01:4755 $c9
.jp_01_4756:
    ld   A, $03                                       ;; 01:4756 $3e $03
    ret                                               ;; 01:4758 $c9
.jp_01_4759:
    ld   A, $01                                       ;; 01:4759 $3e $01
    ret                                               ;; 01:475b $c9
.jp_01_475c:
    ld   A, [wDC4E_LivesRemaining]                    ;; 01:475c $fa $4e $dc
    ret                                               ;; 01:475f $c9

call_01_4760_MenuCmd_DrawSpriteGroup:
; Sub-handler $E9. Draws a group of sprites from
; data_01_5b61_SpriteScriptTable, and optionally arms the timer that will erase them
; again: a non-zero wDBA6_MenuCmd_Arg2 becomes wDBDE_Menu_HideSpritesDelay and the
; group id is remembered in wDBDF_Menu_HideSpritesGroup for
; call_01_4b6b_Menu_TickHideSprites to undo later.
;
; Three of the four entries in that table point at wDBBF_MenuCursor_OamSlot - the
; cursor record in WRAM - rather than at ROM. gex2's
; call_01_4879_MenuCmd_DrawRemoteIcons
    ld   A, [wDBA6_MenuCmd_Arg2]                      ;; 01:4760 $fa $a6 $db
    and  A, A                                         ;; 01:4763 $a7
    jr   Z, .jr_01_476f                               ;; 01:4764 $28 $09
    ld   [wDBDE_Menu_HideSpritesDelay], A             ;; 01:4766 $ea $de $db
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:4769 $fa $a7 $db
    ld   [wDBDF_Menu_HideSpritesGroup], A             ;; 01:476c $ea $df $db
.jr_01_476f:
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:476f $fa $a7 $db
    ld   DE, data_01_5b61_SpriteScriptTable           ;; 01:4772 $11 $61 $5b
    call call_00_0777_GetPointerFromTable             ;; 01:4775 $cd $77 $07
    jp   call_01_4c45_Menu_BuildSpriteBlock           ;; 01:4778 $c3 $45 $4c

call_01_477b_MenuCmd_NoOp:
; Sub-handler $EA: a bare `ret`. gex2 uses this slot for the totals-page heading
; text; gex3 has no such command and left the slot filled with nothing
    ret                                               ;; 01:477b ?

call_01_477c_MenuCmd_StagePasswordGlyph:
; Sub-handler $EB. Stages the 2x2-tile glyph for one password cell.
;
; wDBA7_MenuCmd_SrcPtr is the cell number; wDB7E_PasswordValues[cell] is the key the
; player put there; that key indexes data_01_66f9_PasswordFont at
; PASSWORD_GLYPH_BYTES each. The destination is wC980_NumberSprites, also stepped by
; PASSWORD_GLYPH_BYTES, so the whole grid can be staged by one script running this
; command eighteen times - which is exactly what data_01_5a47_MenuScript_PasswordGrid does.
;
; It draws no number and writes no sprite; the old name was wrong on both. gex2's
; call_01_48fd_MenuCmd_SetPasswordCharText does the same job by pushing one character
; through the text renderer instead
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:477c $21 $a7 $db
    ld   L, [HL]                                      ;; 01:477f $6e
    ld   H, $00                                       ;; 01:4780 $26 $00
    add  HL, HL                                       ;; 01:4782 $29
    add  HL, HL                                       ;; 01:4783 $29
    add  HL, HL                                       ;; 01:4784 $29
    add  HL, HL                                       ;; 01:4785 $29
    add  HL, HL                                       ;; 01:4786 $29
    add  HL, HL                                       ;; 01:4787 $29
    ld   DE, wC980_NumberSprites                      ;; 01:4788 $11 $80 $c9
    add  HL, DE                                       ;; 01:478b $19
    ld   E, L                                         ;; 01:478c $5d
    ld   D, H                                         ;; 01:478d $54
    ld   HL, wDBA7_MenuCmd_SrcPtr                     ;; 01:478e $21 $a7 $db
    ld   L, [HL]                                      ;; 01:4791 $6e
    ld   H, $00                                       ;; 01:4792 $26 $00
    ld   BC, wDB7E_PasswordValues                     ;; 01:4794 $01 $7e $db
    add  HL, BC                                       ;; 01:4797 $09
    ld   L, [HL]                                      ;; 01:4798 $6e
    ld   H, $00                                       ;; 01:4799 $26 $00
    add  HL, HL                                       ;; 01:479b $29
    add  HL, HL                                       ;; 01:479c $29
    add  HL, HL                                       ;; 01:479d $29
    add  HL, HL                                       ;; 01:479e $29
    add  HL, HL                                       ;; 01:479f $29
    add  HL, HL                                       ;; 01:47a0 $29
    ld   BC, data_01_66f9_PasswordFont                ;; 01:47a1 $01 $f9 $66
    add  HL, BC                                       ;; 01:47a4 $09
    ld   B, $04                                       ;; 01:47a5 $06 $04
    jp   call_00_0bcf_CopyTileRows                    ;; 01:47a7 $c3 $cf $0b

call_01_47aa_MenuCmd_SetChainedScript:
; Sub-handler $EC. Stores the command's argument in wDBDD_Menu_ChainedScript, which
; call_01_43f0_Menu_BuildScreen picks up after the current script ends and uses to
; index data_01_5596_ChainedScriptTable. That is the whole of gex3's "run a second
; script after this one". gex2's call_01_4916_MenuCmd_SetChainedScript
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:47aa $fa $a7 $db
    ld   [wDBDD_Menu_ChainedScript], A                ;; 01:47ad $ea $dd $db
    ret                                               ;; 01:47b0 $c9

call_01_47b1_MenuCmd_LoadFullscreenImage:
; Sub-handler $ED. Copies one eight-byte image record from the inline table into
; wDBB1_ScreenDraw_HasPaletteIdMap and hands off to
; jp_00_0781_Screen_LoadFullscreenImage. The record's fields are named in memory.asm;
; this is how the title screen and the credit stills get on screen. gex2's
; call_01_491d_MenuCmd_LoadFullscreenImage
    ld   A, [wDBA7_MenuCmd_SrcPtr]                    ;; 01:47b1 $fa $a7 $db
    ld   DE, .data_01_47c6                            ;; 01:47b4 $11 $c6 $47
    call call_00_0777_GetPointerFromTable             ;; 01:47b7 $cd $77 $07
    ld   DE, wDBB1_ScreenDraw_HasPaletteIdMap         ;; 01:47ba $11 $b1 $db
    ld   BC, $08                                      ;; 01:47bd $01 $08 $00
    call call_00_076e_MemCopy                         ;; 01:47c0 $cd $6e $07
    jp   jp_00_0781_Screen_LoadFullscreenImage        ;; 01:47c3 $c3 $81 $07
.data_01_47c6:
    dw   .data_01_47d4, .data_01_47dc, .data_01_47e4, .data_01_47ec ;; 01:47c6 ..??....
    dw   .data_01_47f4, .data_01_47fc, .data_01_4804
.data_01_47d4:
    db   $00, $06, $e0, $45, $00, $40, $e0, $05
.data_01_47dc:
    db   $00, $06, $a6, $48, $a6, $47, $00, $01
.data_01_47e4:
    db   $01, $06, $fe, $56, $1e, $4a, $e0, $0c
.data_01_47ec:
    db   $00, $06, $06, $66, $86, $60, $80, $05
.data_01_47f4:
    db   $00, $06, $66, $6b, $c6, $67, $a0, $03
.data_01_47fc:
    db   $00, $06, $ce, $5e, $ce, $59, $00, $05
.data_01_4804:
    db   $01, $11, $90, $51, $00, $40, $90, $11

call_01_480c_MenuCmd_SetCollectedCountText:
; Sub-handler $EE. Builds a short "n<something>" string: it appends a fixed suffix
; from BANK_1C_TEXT, counts this level's collected objectives, and then OVERWRITES the
; first character of the result with that count as an ASCII digit. So the digit is not
; appended - the suffix string is written first and the number is dropped on top of
; its first byte.
;
; Note the source operand MENUTEXT_COLLECTED_SUFFIX. As a raw number it is $4AC3, and
; the disassembler resolved that to a label inside this file's own bit-counting loop;
; it is really a bank $1C address and has nothing to do with bank 1
    ld   hl,wDADD_MenuTextBuffer
    ld   [hl],TEXT_TERMINATOR
    ld   de,MENUTEXT_COLLECTED_SUFFIX
    call call_00_0865_Text_AppendStringToBuffer
    call call_01_4acf_CountCollectedBitsForLevel
    add  a,ASCII_ZERO
    ld   [wDADD_MenuTextBuffer],a
    ld   hl,MENUTEXT_COUNTER_STRINGS
    jp   call_01_4cfa_Menu_SetScriptSrcPtr

call_01_4825_MenuCmd_NoOp2:
; Sub-handler $EF: another bare `ret`.
;
; This label used to claim address $480C, which is the routine above it - two top
; level labels for one address. It is really at $4825
    ret  

call_01_4826_MenuCmd_DrawRemoteMarker:
; Sub-handler $F0. The marker half of call_01_467b_MenuCmd_SetMissionText with no
; text: same collected/missing tile pair, same 2x2 rectangle, but a four-entry bit
; mask table instead of three and a different OAM attribute. The screen that uses four
; markers rather than three is what it exists for
    ld   hl,wDBA7_MenuCmd_SrcPtr
    ld   l,[hl]
    ld   h,$00
    ld   de,.data_01_4871
    add  hl,de
    ld   c,[hl]
    ld   hl,wDB6C_CurrentMapId
    ld   l,[hl]
    ld   h,$00
    ld   de,wDC5C_ProgressFlags
    add  hl,de
    ld   a,[hl]
    and  c
    ld   c,REMOTE_MARKER_TILE_TAKEN
    jr   nz,.jr_00_4843
    ld   c,REMOTE_MARKER_TILE_MISSING
.jr_00_4843:
    ld   a,c
    ld   [wDADF],a
    ld   a,[wDBA1_MenuCmd_DestTileY]
    add  a,$02
    add  a
    add  a
    add  a
    ld   [wDADD_MenuTextBuffer],a
    ld   a,[wDBA0_MenuCmd_DestTileX]
    inc  a
    add  a
    add  a
    add  a
    ld   [wDADE],a
    ld   a,$01
    ld   [wDAE0],a
    ld   a,[wDBA7_MenuCmd_SrcPtr]
    add  a
    add  a
    add  a,$04
    ld   [wDBDB_Menu_OamSlot],a
    ld   bc,$0202
    jp   call_01_4c7e_Menu_WriteSpriteRect
.data_01_4871:
    db   $01, $02, $04, $08                           ;; 01:486e ???????
