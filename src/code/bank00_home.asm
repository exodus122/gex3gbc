;; Disassembled with BadBoy Disassembler: https://github.com/daid/BadBoy

    reti                                               ;; 00:0000 ?

SECTION "isrVBlank", ROM0[$0040]
isrVBlank:
    jp   call_00_0b25_MainGameLoop_UpdateAndRenderFrame                                    ;; 00:0040 $c3 $25 $0b

SECTION "isrLCDC", ROM0[$0048]
isrLCDC:
    jp   wD9A0                                         ;; 00:0048 $c3 $a0 $d9

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
    nop                                                ;; 00:0100 $00
    jp   call_00_0150_Init                             ;; 00:0101 $c3 $50 $01
    ds   $30                                           ;; 00:0104
    db   "POCKET GEX3AXGE"                             ;; 00:0134
    db   CART_COMPATIBLE_GBC                           ;; 00:0143
    db   $34, $46                                      ;; 00:0144 ??
    db   CART_INDICATOR_GB                             ;; 00:0146
    db   CART_ROM_MBC5, CART_ROM_2048KB, CART_SRAM_NONE ;; 00:0147
    db   CART_DEST_NON_JAPANESE, $33, $00              ;; 00:014a $01 $33 $00
    ds   $03                                             ;; 00:014d

call_00_0150_Init:
    di                                                 ;; 00:0150 $f3
    ld   SP, hFFFE                                     ;; 00:0151 $31 $fe $ff
    push AF                                            ;; 00:0154 $f5
    cp   A, $11                                        ;; 00:0155 $fe $11
    jr   NZ, .jr_00_015d                               ;; 00:0157 $20 $04
    ld   A, $01                                        ;; 00:0159 $3e $01
    ldh  [rSVBK], A                                    ;; 00:015b $e0 $70
.jr_00_015d:
    ldh  A, [rLY]                                      ;; 00:015d $f0 $44
    cp   A, $91                                        ;; 00:015f $fe $91
    jr   NZ, .jr_00_015d                               ;; 00:0161 $20 $fa
    ldh  A, [rLCDC]                                    ;; 00:0163 $f0 $40
    and  A, $7f                                        ;; 00:0165 $e6 $7f
    ldh  [rLCDC], A                                    ;; 00:0167 $e0 $40
    xor  A, A                                          ;; 00:0169 $af
    ld   [MBC1SRamEnable], A                                    ;; 00:016a $ea $01 $00
    ld   [MBC1SRamBankingMode], A                                    ;; 00:016d $ea $01 $60
    ld   HL, wC000_BgMapTileIds                                     ;; 00:0170 $21 $00 $c0
    ld   DE, wC000_BgMapTileIds+1                                     ;; 00:0173 $11 $01 $c0 ; wC000_BgMapTileIds
    ld   BC, $1fff                                     ;; 00:0176 $01 $ff $1f
    ld   [HL], $00                                     ;; 00:0179 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:017b $cd $6e $07
    xor  A, A                                          ;; 00:017e $af
    ldh  [rSCX], A                                     ;; 00:017f $e0 $43
    ldh  [rSCY], A                                     ;; 00:0181 $e0 $42
    ld   A, $07                                        ;; 00:0183 $3e $07
    ld   [wDADB_WindowX], A                                    ;; 00:0185 $ea $db $da
    ldh  [rWX], A                                      ;; 00:0188 $e0 $4b
    ld   A, $80                                        ;; 00:018a $3e $80
    ld   [wDADC_WindowY], A                                    ;; 00:018c $ea $dc $da
    ldh  [rWY], A                                      ;; 00:018f $e0 $4a
    pop  AF                                            ;; 00:0191 $f1
    cp   A, $11                                        ;; 00:0192 $fe $11
    jr   Z, .jr_00_01d2                                ;; 00:0194 $28 $3c
    ld   A, Bank07                                        ;; 00:0196 $3e $07
    ld   [MBC1RomBank], A                                    ;; 00:0198 $ea $01 $20
    swap A                                             ;; 00:019b $cb $37
    rrca                                               ;; 00:019d $0f
    and  A, $00                                        ;; 00:019e $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:01a0 $ea $01 $40
    ld   HL, image_007_5b00                                     ;; 00:01a3 $21 $00 $5b
    ld   DE, _VRAM                                     ;; 00:01a6 $11 $00 $80
    ld   BC, $a00                                      ;; 00:01a9 $01 $00 $0a
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:01ac $cd $6e $07
    ld   HL, _SCRN0                                     ;; 00:01af $21 $00 $98
    ld   DE, image_007_5b00_bgmap_tile_ids                                     ;; 00:01b2 $11 $00 $65
    ld   C, $12                                        ;; 00:01b5 $0e $12
.jr_00_01b7:
    ld   B, $14                                        ;; 00:01b7 $06 $14
.jr_00_01b9:
    ld   A, [DE]                                       ;; 00:01b9 $1a
    ld   [HL+], A                                      ;; 00:01ba $22
    inc  DE                                            ;; 00:01bb $13
    dec  B                                             ;; 00:01bc $05
    jr   NZ, .jr_00_01b9                               ;; 00:01bd $20 $fa
    push BC                                            ;; 00:01bf $c5
    ld   BC, $0c                                       ;; 00:01c0 $01 $0c $00
    add  HL, BC                                        ;; 00:01c3 $09
    pop  BC                                            ;; 00:01c4 $c1
    dec  C                                             ;; 00:01c5 $0d
    jr   NZ, .jr_00_01b7                               ;; 00:01c6 $20 $ef
    ld   A, $d5                                        ;; 00:01c8 $3e $d5
    ldh  [rLCDC], A                                    ;; 00:01ca $e0 $40
    ld   A, $93                                        ;; 00:01cc $3e $93
    ldh  [rBGP], A                                     ;; 00:01ce $e0 $47
.jr_00_01d0:
    jr   .jr_00_01d0                                   ;; 00:01d0 $18 $fe
.jr_00_01d2:
    ld   A, $00                                        ;; 00:01d2 $3e $00
    ldh  [rVBK], A                                     ;; 00:01d4 $e0 $4f
    call call_00_0e81_LoadPalettesToHardware                                  ;; 00:01d6 $cd $81 $0e
    ld   HL, call_00_0e29_StartDMATransfer                                      ;; 00:01d9 $21 $29 $0e
    ld   DE, hFF80                                     ;; 00:01dc $11 $80 $ff
    ld   BC, $0a                                       ;; 00:01df $01 $0a $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:01e2 $cd $6e $07
    ld   A, $01                                        ;; 00:01e5 $3e $01
.jr_00_01e7:
    push AF                                            ;; 00:01e7 $f5
    ldh  [rVBK], A                                     ;; 00:01e8 $e0 $4f
    ld   HL, _VRAM                                     ;; 00:01ea $21 $00 $80
    ld   DE, _VRAM+$0001                                     ;; 00:01ed $11 $01 $80
    ld   BC, $1fff                                     ;; 00:01f0 $01 $ff $1f
    ld   [HL], $00                                     ;; 00:01f3 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:01f5 $cd $6e $07
    pop  AF                                            ;; 00:01f8 $f1
    dec  A                                             ;; 00:01f9 $3d
    bit  7, A                                          ;; 00:01fa $cb $7f
    jr   Z, .jr_00_01e7                                ;; 00:01fc $28 $e9
    ld   HL, wDAD3_PtrToBankStackPosition                                     ;; 00:01fe $21 $d3 $da
    ld   DE, wDAC3_BankStack                                     ;; 00:0201 $11 $c3 $da
    ld   A, BANK_01_MENU_CODE                                        ;; 00:0204 $3e $01
    ld   [HL], E                                       ;; 00:0206 $73
    inc  HL                                            ;; 00:0207 $23
    ld   [HL], D                                       ;; 00:0208 $72
    ld   [wDAD5_CurrentROMBank], A                                    ;; 00:0209 $ea $d5 $da
    ld   [DE], A                                       ;; 00:020c $12
    call call_00_0f25_AltSwitchBank                                  ;; 00:020d $cd $25 $0f
    ld   HL, rKEY1                                     ;; 00:0210 $21 $4d $ff
    bit  7, [HL]                                       ;; 00:0213 $cb $7e
    jr   NZ, .jr_00_0224                               ;; 00:0215 $20 $0d
    set  0, [HL]                                       ;; 00:0217 $cb $c6
    xor  A, A                                          ;; 00:0219 $af
    ldh  [rIF], A                                      ;; 00:021a $e0 $0f
    ldh  [rIE], A                                      ;; 00:021c $e0 $ff
    ld   A, $30                                        ;; 00:021e $3e $30
    ldh  [rP1], A                                      ;; 00:0220 $e0 $00
    stop                                               ;; 00:0222 $10 $00
.jr_00_0224:
    ld   A, $00                                        ;; 00:0224 $3e $00
    call call_00_0c1b_LCDInterrupt_Setup                                  ;; 00:0226 $cd $1b $0c
    xor  A, A                                          ;; 00:0229 $af
    ldh  [rIF], A                                      ;; 00:022a $e0 $0f
    ld   A, $08                                        ;; 00:022c $3e $08
    ldh  [rSTAT], A                                    ;; 00:022e $e0 $41
    ld   A, $03                                        ;; 00:0230 $3e $03
    ldh  [rIE], A                                      ;; 00:0232 $e0 $ff
    ld   A, BANK_04_AUDIO_CODE_1                                        ;; 00:0234 $3e $04
    call call_00_0eee_SwitchBank                                  ;; 00:0236 $cd $ee $0e
    call call_04_4000_Audio                                  ;; 00:0239 $cd $00 $40
    call call_00_0f08_RestoreBank                                  ;; 00:023c $cd $08 $0f
    xor  A, A                                          ;; 00:023f $af
    ld   [wDE60_AudioBankCurrent], A                                    ;; 00:0240 $ea $60 $de
    ld   [wDE5E_QueuedSoundEffectPriority], A                                    ;; 00:0243 $ea $5e $de
    ld   [wDE5F_CurrentSoundEffectPriority], A                                    ;; 00:0246 $ea $5f $de
    ld   A, $ff                                        ;; 00:0249 $3e $ff
    ld   [wDE5C_CurrentSong], A                                    ;; 00:024b $ea $5c $de
    ld   [wDE5D_QueuedSoundEffect], A                                    ;; 00:024e $ea $5d $de
    ld   A, $c7                                        ;; 00:0251 $3e $c7
    ld   [wDAD8_LCDControlMirror], A                                    ;; 00:0253 $ea $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0256 $e0 $40
    ei                                                 ;; 00:0258 $fb
    call call_00_0b92_WaitForInterrupt                                  ;; 00:0259 $cd $92 $0b
    farcall call_01_4f7e_SeedTileLookupTable
.jp_00_0267:
    ld   A, SONG_EMPTY                                        ;; 00:0267 $3e $00
    call call_00_0fa2_PlaySong                                  ;; 00:0269 $cd $a2 $0f
    ld   A, SFX_EMPTY                                        ;; 00:026c $3e $00
    call call_00_0fd7_TriggerSoundEffect                                  ;; 00:026e $cd $d7 $0f
    ld   A, MENU_OPENING_CREDITS_1                                        ;; 00:0271 $3e $11
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_OPENING_CREDITS_2                                        ;; 00:027e $3e $12
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_EIDOS_INTERACTIVE                                        ;; 00:028b $3e $14
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_OPENING_CRYSTAL_DYNAMICS                                        ;; 00:0298 $3e $13
    farcall call_01_4000_MenuHandler_LoadAndProcess
    ld   A, MENU_DAVID_A_PALMER                                        ;; 00:02a5 $3e $0f
    farcall call_01_4000_MenuHandler_LoadAndProcess
.jp_00_02b2:
    ld   A, SONG_UNK01                                        ;; 00:02b2 $3e $01
    call call_00_0fa2_PlaySong                                  ;; 00:02b4 $cd $a2 $0f
    ld   A, MENU_TITLE_SCREEN                                        ;; 00:02b7 $3e $00
    farcall call_01_4000_MenuHandler_LoadAndProcess
    cp   A, $20                                        ;; 00:02c4 $fe $20
    jr   Z, .jr_00_02ed                                ;; 00:02c6 $28 $25
    cp   A, $10                                        ;; 00:02c8 $fe $10
    jr   NZ, .jp_00_02b2                               ;; 00:02ca $20 $e6
.jp_00_02cc:
    ld   A, $04                                        ;; 00:02cc $3e $04
    ld   [wDC4E_PlayerLivesRemaining], A                                    ;; 00:02ce $ea $4e $dc
    xor  A, A                                          ;; 00:02d1 $af
    ld   [wDCAF_PawCoinCounter], A                                    ;; 00:02d2 $ea $af $dc
    ld   [wDC4F_PawCoinExtraHealth], A                                    ;; 00:02d5 $ea $4f $dc
    ld   HL, wDC5C_ProgressFlags                                     ;; 00:02d8 $21 $5c $dc
    ld   B, $0c                                        ;; 00:02db $06 $0c
    xor  A, A                                          ;; 00:02dd $af
.jr_00_02de:
    ld   [HL+], A                                      ;; 00:02de $22
    dec  B                                             ;; 00:02df $05
    jr   NZ, .jr_00_02de                               ;; 00:02e0 $20 $fc
    farcall call_01_4f8c_BuildPasswordBitfieldAndChecksum
.jr_00_02ed:
    xor  A, A                                          ;; 00:02ed $af
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:02ee $ea $6c $db
    ld   [wDC5B_TVButtonLevelMissionRelated], A                                    ;; 00:02f1 $ea $5b $dc
    ld   [wDC69_PlayerSpawnIdInLevel], A                                    ;; 00:02f4 $ea $69 $dc
    ld   [wDB6A], A                                    ;; 00:02f7 $ea $6a $db
    call call_00_0e3b_ClearGameStateVariables                                  ;; 00:02fa $cd $3b $0e
    call call_00_0e62_ResetFlagsAndVRAMState                                  ;; 00:02fd $cd $62 $0e
    ld   C, $00                                        ;; 00:0300 $0e $00
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:0302 $cd $6a $0a
    ld   C, $01                                        ;; 00:0305 $0e $01
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:0307 $cd $6a $0a
    ld   C, $02                                        ;; 00:030a $0e $02
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:030c $cd $6a $0a
    ld   A, $e7                                        ;; 00:030f $3e $e7
    call call_00_0e33_SetLCDControlRegister                                  ;; 00:0311 $cd $33 $0e
.jp_00_0314:
    ld   A, [wDB6A]                                    ;; 00:0314 $fa $6a $db
    and  A, $10                                        ;; 00:0317 $e6 $10
    jr   Z, .jr_00_0326                                ;; 00:0319 $28 $0b
    farcall call_01_435e_HandleLevelTransitionMenu
.jr_00_0326:
    farcall call_03_6c89_LoadMapData
    ld   A, [wDC4F_PawCoinExtraHealth]                                    ;; 00:0331 $fa $4f $dc
    add  A, $04                                        ;; 00:0334 $c6 $04
    ld   [wDC50_PlayerHealth], A                                    ;; 00:0336 $ea $50 $dc
    farcall call_01_432b_SetLevelMenuAndPalette
    call call_00_0e3b_ClearGameStateVariables                                  ;; 00:0344 $cd $3b $0e
    call call_00_2f85_LoadAndSortCollectibleData                                  ;; 00:0347 $cd $85 $2f
    call call_00_2ff8_InitLevelObjectsAndConfig                                  ;; 00:034a $cd $f8 $2f
    call call_00_0595_PlaySongBasedOnLevel                                  ;; 00:034d $cd $95 $05
    call call_00_1ea0_LoadAndRunMissionPreviewCutscene                                  ;; 00:0350 $cd $a0 $1e
    xor  A, A                                          ;; 00:0353 $af
    ld   [wDC69_PlayerSpawnIdInLevel], A                                    ;; 00:0354 $ea $69 $dc
.jp_00_0357:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:0357 $fa $1e $dc
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:035a $ea $6c $db
    farcall call_03_6c89_LoadMapData
    xor  A, A                                          ;; 00:0368 $af
    ld   [wDC51_CurrentFlyRelated], A                                    ;; 00:0369 $ea $51 $dc
    ld   [wDCA9_FlyTimerOrFlags4], A                                    ;; 00:036c $ea $a9 $dc
    ld   [wDCAA_FlyTimerOrFlags1], A                                    ;; 00:036f $ea $aa $dc
    ld   [wDCAB_FlyTimerOrFlags2], A                                    ;; 00:0372 $ea $ab $dc
    ld   [wDC89], A                                    ;; 00:0375 $ea $89 $dc
    ld   A, [wDC4F_PawCoinExtraHealth]                                    ;; 00:0378 $fa $4f $dc
    add  A, $04                                        ;; 00:037b $c6 $04
    ld   [wDC50_PlayerHealth], A                                    ;; 00:037d $ea $50 $dc
    ld   A, $00                                        ;; 00:0380 $3e $00
    ld   [wDC78_PlayerActionIdRelated], A                                    ;; 00:0382 $ea $78 $dc
    call call_00_0e3b_ClearGameStateVariables                                  ;; 00:0385 $cd $3b $0e
    call call_00_2f85_LoadAndSortCollectibleData                                  ;; 00:0388 $cd $85 $2f
    call call_00_2ff8_InitLevelObjectsAndConfig                                  ;; 00:038b $cd $f8 $2f
.jp_00_038e:
    farcall call_03_6c89_LoadMapData
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:0399 $fa $1e $dc
    cp   A, $07                                        ;; 00:039c $fe $07
    jr   NZ, .jr_00_03b6                               ;; 00:039e $20 $16
    ld   A, [wDC78_PlayerActionIdRelated]                                    ;; 00:03a0 $fa $78 $dc
    cp   A, $00                                        ;; 00:03a3 $fe $00
    ld   A, $23                                        ;; 00:03a5 $3e $23
    jr   Z, .jr_00_03e8                                ;; 00:03a7 $28 $3f
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:03a9 $fa $6c $db
    cp   A, $07                                        ;; 00:03ac $fe $07
    ld   A, $24                                        ;; 00:03ae $3e $24
    jr   Z, .jr_00_03e8                                ;; 00:03b0 $28 $36
    ld   A, $01                                        ;; 00:03b2 $3e $01
    jr   .jr_00_03e8                                   ;; 00:03b4 $18 $32
.jr_00_03b6:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:03b6 $fa $1e $dc
    cp   A, $08                                        ;; 00:03b9 $fe $08
    ld   A, $2f                                        ;; 00:03bb $3e $2f
    jr   Z, .jr_00_03e8                                ;; 00:03bd $28 $29
    ld   A, [wDC1F]                                    ;; 00:03bf $fa $1f $dc
    cp   A, $01                                        ;; 00:03c2 $fe $01
    jr   Z, .jr_00_03d6                                ;; 00:03c4 $28 $10
    ld   A, [wDC78_PlayerActionIdRelated]                                    ;; 00:03c6 $fa $78 $dc
    cp   A, $00                                        ;; 00:03c9 $fe $00
    jr   Z, .jr_00_03e8                                ;; 00:03cb $28 $1b
    ld   A, [wD801_Player_ActionId]                                    ;; 00:03cd $fa $01 $d8
    sub  A, $3c                                        ;; 00:03d0 $d6 $3c
    jr   C, .jr_00_03eb                                ;; 00:03d2 $38 $17
    jr   .jr_00_03e8                                   ;; 00:03d4 $18 $12
.jr_00_03d6:
    ld   A, [wDC78_PlayerActionIdRelated]                                    ;; 00:03d6 $fa $78 $dc
    cp   A, $00                                        ;; 00:03d9 $fe $00
    ld   A, $3c                                        ;; 00:03db $3e $3c
    jr   Z, .jr_00_03e8                                ;; 00:03dd $28 $09
    ld   A, [wD801_Player_ActionId]                                    ;; 00:03df $fa $01 $d8
    cp   A, $3c                                        ;; 00:03e2 $fe $3c
    jr   NC, .jr_00_03eb                               ;; 00:03e4 $30 $05
    add  A, $3c                                        ;; 00:03e6 $c6 $3c
.jr_00_03e8:
    ld   [wDC78_PlayerActionIdRelated], A                                    ;; 00:03e8 $ea $78 $dc
.jr_00_03eb:
    xor  A, A                                          ;; 00:03eb $af
    ld   [wDC29_SkipMapWindowUpdateFlag], A                                    ;; 00:03ec $ea $29 $dc
    ld   A, $01                                        ;; 00:03ef $3e $01
    ld   [wDCA7_DrawGexFlag], A                                    ;; 00:03f1 $ea $a7 $dc
    call call_00_04fb                                  ;; 00:03f4 $cd $fb $04
    farcall call_03_647c_InitPlayerPositionAndLevel
    call call_00_1056_LoadFullMap                                  ;; 00:0402 $cd $56 $10
    farcall call_02_708f_InitObjectsAndSpawnPlayer
    call call_00_0513                                  ;; 00:0410 $cd $13 $05
    xor  A, A                                          ;; 00:0413 $af
    ld   [wDB6A], A                                    ;; 00:0414 $ea $6a $db
    ld   [wDCDB_EvilSantaHitByProjectileFlag], A                                    ;; 00:0417 $ea $db $dc
    ld   A, $ff                                        ;; 00:041a $3e $ff
    ld   [wDC8A], A                                    ;; 00:041c $ea $8a $dc
    jr   .jp_00_0443                                   ;; 00:041f $18 $22
.jp_00_0421:
    call call_00_0595_PlaySongBasedOnLevel                                  ;; 00:0421 $cd $95 $05
    call call_00_04fb                                  ;; 00:0424 $cd $fb $04
    call call_00_1056_LoadFullMap                                  ;; 00:0427 $cd $56 $10
    farcall call_02_7142_RestoreObjectTable
    farcall call_03_68d9_AssignAllObjectPalettes
    call call_00_0513                                  ;; 00:0440 $cd $13 $05
.jp_00_0443:
    call call_00_0b92_WaitForInterrupt                                  ;; 00:0443 $cd $92 $0b
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0446 $fa $d7 $da
    cp   A, $0f                                        ;; 00:0449 $fe $0f
    jp   Z, .jp_00_0267                                ;; 00:044b $ca $67 $02
    ld   HL, wDB6A                                     ;; 00:044e $21 $6a $db
    bit  2, [HL]                                       ;; 00:0451 $cb $56
    jr   Z, .jr_00_045e                                ;; 00:0453 $28 $09
    call call_00_1633_HandleLevelWarpOrExit                                  ;; 00:0455 $cd $33 $16
    call call_00_2b3d_SweepAndClearActiveObjects                                  ;; 00:0458 $cd $3d $2b
    jp   .jp_00_038e                                   ;; 00:045b $c3 $8e $03
.jr_00_045e:
    ld   HL, wDB6A                                     ;; 00:045e $21 $6a $db
    bit  4, [HL]                                       ;; 00:0461 $cb $66
    jp   NZ, .jp_00_0314                               ;; 00:0463 $c2 $14 $03
    ld   HL, wDB6A                                     ;; 00:0466 $21 $6a $db
    bit  1, [HL]                                       ;; 00:0469 $cb $4e
    jr   Z, .jr_00_0487                                ;; 00:046b $28 $1a
    ld   HL, wDC4E_PlayerLivesRemaining                                     ;; 00:046d $21 $4e $dc
    dec  [HL]                                          ;; 00:0470 $35
    jp   NZ, .jp_00_0357                               ;; 00:0471 $c2 $57 $03
    farcall call_01_42fd_LoadMenu03_InitSong15
    cp   A, $40                                        ;; 00:047f $fe $40
    jp   Z, .jp_00_02cc                                ;; 00:0481 $ca $cc $02
    jp   .jp_00_02b2                                   ;; 00:0484 $c3 $b2 $02
.jr_00_0487:
    farcall call_02_5541_GetActionPropertyByte
    and  A, $08                                        ;; 00:0492 $e6 $08
    jr   NZ, .jr_00_04d8                               ;; 00:0494 $20 $42
    call call_00_0f80_CheckInputStart                                  ;; 00:0496 $cd $80 $0f
    jr   Z, .jr_00_04d8                                ;; 00:0499 $28 $3d
    ld   A, SONG_EMPTY                                        ;; 00:049b $3e $00
    call call_00_0fa2_PlaySong                                  ;; 00:049d $cd $a2 $0f
    ld   A, SFX_EMPTY                                        ;; 00:04a0 $3e $00
    call call_00_0fd7_TriggerSoundEffect                                  ;; 00:04a2 $cd $d7 $0f
    farcall call_02_7132_BackupObjectTable
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:04b0 $fa $1e $dc
    and  A, A                                          ;; 00:04b3 $a7
    ld   A, MENU_PAUSE_IN_GEX_CAVE                                        ;; 00:04b4 $3e $0b
    jr   Z, .jr_00_04ba                                ;; 00:04b6 $28 $02
    ld   A, MENU_PAUSE_IN_LEVEL                                        ;; 00:04b8 $3e $0d
.jr_00_04ba:
    farcall call_01_4000_MenuHandler_LoadAndProcess
    cp   A, $60                                        ;; 00:04c5 $fe $60
    jp   NZ, .jp_00_0421                               ;; 00:04c7 $c2 $21 $04
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 00:04ca $fa $1e $dc
    and  A, A                                          ;; 00:04cd $a7
    jp   Z, .jp_00_02b2                                ;; 00:04ce $ca $b2 $02
    xor  A, A                                          ;; 00:04d1 $af
    ld   [wDB6C_CurrentMapId], A                                    ;; 00:04d2 $ea $6c $db
    jp   .jp_00_0314                                   ;; 00:04d5 $c3 $14 $03
.jr_00_04d8:
    call call_00_05fd_CheckForEatFly                                  ;; 00:04d8 $cd $fd $05
    call call_00_05c7                                  ;; 00:04db $cd $c7 $05
    farcall call_02_7152_UpdateObjects
    call call_00_11c8_LoadBgMapDirtyRegions                                  ;; 00:04e9 $cd $c8 $11
    call call_00_0fc8_ProcessQueuedSoundEffect                                  ;; 00:04ec $cd $c8 $0f
    call call_00_150f_CheckAndSetLevelTrigger                                  ;; 00:04ef $cd $0f $15
    call call_00_35fa_WaitForLineThenSpawnObject                                  ;; 00:04f2 $cd $fa $35
    call call_00_08f8_SetupObjectVRAMTransfer                                  ;; 00:04f5 $cd $f8 $08
    jp   .jp_00_0443                                   ;; 00:04f8 $c3 $43 $04

call_00_04fb:
    xor  A, A                                          ;; 00:04fb $af
    ld   [wDE5E_QueuedSoundEffectPriority], A                                    ;; 00:04fc $ea $5e $de
    ld   [wDE5F_CurrentSoundEffectPriority], A                                    ;; 00:04ff $ea $5f $de
    ld   A, $ff                                        ;; 00:0502 $3e $ff
    ld   [wDE5D_QueuedSoundEffect], A                                    ;; 00:0504 $ea $5d $de
    call call_00_0e3b_ClearGameStateVariables                                  ;; 00:0507 $cd $3b $0e
    call call_00_0e62_ResetFlagsAndVRAMState                                  ;; 00:050a $cd $62 $0e
    ld   A, $e7                                        ;; 00:050d $3e $e7
    call call_00_0e33_SetLCDControlRegister                                  ;; 00:050f $cd $33 $0e
    ret                                                ;; 00:0512 $c9

call_00_0513:
    ld   A, BANK_7F_OBJECT_PALETTES                                        ;; 00:0513 $3e $7f
    call call_00_0eee_SwitchBank                                  ;; 00:0515 $cd $ee $0e
    ld   HL, wDB6C_CurrentMapId                                     ;; 00:0518 $21 $6c $db
    ld   E, [HL]                                       ;; 00:051b $5e
    ld   D, $00                                        ;; 00:051c $16 $00
    ld   HL, data_7f_4000                                     ;; 00:051e $21 $00 $40
    add  HL, DE                                        ;; 00:0521 $19
    ld   E, [HL]                                       ;; 00:0522 $5e
    ld   HL, data_7f_403d                                     ;; 00:0523 $21 $3d $40
    add  HL, DE                                        ;; 00:0526 $19
    ld   A, [HL+]                                      ;; 00:0527 $2a
    ld   [wDABF_GexSpriteBank], A                                    ;; 00:0528 $ea $bf $da
    ld   A, [HL+]                                      ;; 00:052b $2a
    ld   H, [HL]                                       ;; 00:052c $66
    ld   L, A                                          ;; 00:052d $6f
    ld   A, [wD80A_Player_SpriteId]                                    ;; 00:052e $fa $0a $d8
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
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:053d $fa $bf $da
    add  A, C                                          ;; 00:0540 $81
    ld   [wDABF_GexSpriteBank], A                                    ;; 00:0541 $ea $bf $da
    call call_00_0f08_RestoreBank                                  ;; 00:0544 $cd $08 $0f
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:0547 $fa $bf $da
    call call_00_0eee_SwitchBank                                  ;; 00:054a $cd $ee $0e
    pop  HL                                            ;; 00:054d $e1
    ld   A, [HL+]                                      ;; 00:054e $2a
    ld   [wDAC2_DMATransferLength], A                                    ;; 00:054f $ea $c2 $da
    inc  HL                                            ;; 00:0552 $23
    inc  HL                                            ;; 00:0553 $23
    ld   A, [HL+]                                      ;; 00:0554 $2a
    ld   [wDAC0_GeneralPurposeDMASourceAddress], A                                    ;; 00:0555 $ea $c0 $da
    ld   A, [HL+]                                      ;; 00:0558 $2a
    ld   [wDAC0_GeneralPurposeDMASourceAddress+1], A                                    ;; 00:0559 $ea $c1 $da
    call call_00_0f08_RestoreBank                                  ;; 00:055c $cd $08 $0f
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:055f $21 $66 $db
    set  0, [HL]                                       ;; 00:0562 $cb $c6
    ld   A, $05                                        ;; 00:0564 $3e $05
    call call_00_0c10_QueueVRAMCopyRequest                                  ;; 00:0566 $cd $10 $0c
    ld   HL, wDB69                                     ;; 00:0569 $21 $69 $db
    ld   [HL], $17                                     ;; 00:056c $36 $17
.jr_00_056e:
    call call_00_0b92_WaitForInterrupt                                  ;; 00:056e $cd $92 $0b
    call call_00_08f8_SetupObjectVRAMTransfer                                  ;; 00:0571 $cd $f8 $08
    ld   A, [wDB66_HDMATransferFlags]                                    ;; 00:0574 $fa $66 $db
    and  A, $ff                                        ;; 00:0577 $e6 $ff
    jr   NZ, .jr_00_056e                               ;; 00:0579 $20 $f3
    ld   A, [wDB69]                                    ;; 00:057b $fa $69 $db
    and  A, $2f                                        ;; 00:057e $e6 $2f
    jr   NZ, .jr_00_056e                               ;; 00:0580 $20 $ec
    farcall call_03_5ec1_UpdateAllObjectsGraphicsAndCollision
    ld   A, $01                                        ;; 00:058d $3e $01
    ld   [wDD6A_GameBoyColorPaletteFlag], A                                    ;; 00:058f $ea $6a $dd
    jp   call_00_0b92_WaitForInterrupt                                  ;; 00:0592 $c3 $92 $0b

call_00_0595_PlaySongBasedOnLevel:
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:0595 $21 $1e $dc
    ld   L, [HL]                                       ;; 00:0598 $6e
    ld   H, $00                                        ;; 00:0599 $26 $00
    ld   DE, .data_00_05a3                                      ;; 00:059b $11 $a3 $05
    add  HL, DE                                        ;; 00:059e $19
    ld   A, [HL]                                       ;; 00:059f $7e
    jp   call_00_0fa2_PlaySong                                  ;; 00:05a0 $c3 $a2 $0f
.data_00_05a3:
    db   SONG_GEX_CAVE, SONG_HOLIDAY_TV, SONG_MYSTERY_TV, SONG_TUT_TV
    db   SONG_WESTERN_STATION, SONG_ANIME_CHANNEL, SONG_SUPERHERO_SHOW
    db   SONG_BONUS_CHANNEL, SONG_BONUS_CHANNEL, SONG_BOSS, SONG_BOSS, SONG_CHANNEL_Z

call_00_05af_LoadMapPalettes:
    ld   A, [wDC13_BgPaletteBank]                                    ;; 00:05af $fa $13 $dc
    call call_00_0eee_SwitchBank                                  ;; 00:05b2 $cd $ee $0e
    ld   HL, wDC14_BgPaletteBankOffset                                     ;; 00:05b5 $21 $14 $dc
    ld   A, [HL+]                                      ;; 00:05b8 $2a
    ld   H, [HL]                                       ;; 00:05b9 $66
    ld   L, A                                          ;; 00:05ba $6f
    ld   DE, wDCEA_BgPalettes                                     ;; 00:05bb $11 $ea $dc
    ld   BC, $40                                       ;; 00:05be $01 $40 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:05c1 $cd $6e $07
    jp   call_00_0f08_RestoreBank                                  ;; 00:05c4 $c3 $08 $0f

call_00_05c7:
    ld   A, [wDB6D]                                    ;; 00:05c7 $fa $6d $db
    and  A, A                                          ;; 00:05ca $a7
    ret  Z                                             ;; 00:05cb $c8
    ld   HL, wDCD2_FreestandingRemoteHitFlags                                     ;; 00:05cc $21 $d2 $dc
    bit  7, [HL]                                       ;; 00:05cf $cb $7e
    jr   NZ, .jr_00_05f1                               ;; 00:05d1 $20 $1e
    ld   HL, wDB6F                                     ;; 00:05d3 $21 $6f $db
    dec  [HL]                                          ;; 00:05d6 $35
    ret  NZ                                            ;; 00:05d7 $c0
    ld   [HL], $3c                                     ;; 00:05d8 $36 $3c
    ld   HL, wDB69                                     ;; 00:05da $21 $69 $db
    set  2, [HL]                                       ;; 00:05dd $cb $d6
    ld   HL, wDB6E                                     ;; 00:05df $21 $6e $db
    ld   A, [HL]                                       ;; 00:05e2 $7e
    sub  A, $01                                        ;; 00:05e3 $d6 $01
    ld   [HL], A                                       ;; 00:05e5 $77
    ret  NC                                            ;; 00:05e6 $d0
    ld   [HL], $00                                     ;; 00:05e7 $36 $00
    ld   HL, wDB6A                                     ;; 00:05e9 $21 $6a $db
    set  4, [HL]                                       ;; 00:05ec $cb $e6
    set  5, [HL]                                       ;; 00:05ee $cb $ee
    ret                                                ;; 00:05f0 $c9
.jr_00_05f1:
    ld   C, $1c                                        ;; 00:05f1 $0e $1c
    call call_00_29ce_CheckObject_C_Exists                                  ;; 00:05f3 $cd $ce $29
    ret  Z                                             ;; 00:05f6 $c8
    ld   HL, wDB6A                                     ;; 00:05f7 $21 $6a $db
    set  4, [HL]                                       ;; 00:05fa $cb $e6
    ret                                                ;; 00:05fc $c9

call_00_05fd_CheckForEatFly:
    call call_00_0f8b_CheckInputSelect                                  ;; 00:05fd $cd $8b $0f
    ret  Z                                             ;; 00:0600 $c8
    ld   A, [wDC51_CurrentFlyRelated]                                    ;; 00:0601 $fa $51 $dc
    and  A, A                                          ;; 00:0604 $a7
    ret  Z                                             ;; 00:0605 $c8
    ld   A, [wD801_Player_ActionId]                                    ;; 00:0606 $fa $01 $d8
    cp   A, $01                                        ;; 00:0609 $fe $01
    ret  C                                             ;; 00:060b $d8
    cp   A, $03                                        ;; 00:060c $fe $03
    jr   C, .jr_00_0616                                ;; 00:060e $38 $06
    cp   A, $3d                                        ;; 00:0610 $fe $3d
    ret  C                                             ;; 00:0612 $d8
    cp   A, $3f                                        ;; 00:0613 $fe $3f
    ret  NC                                            ;; 00:0615 $d0
.jr_00_0616:
    ld   A, PLAYERACTION_UNK8                                        ;; 00:0616 $3e $08
    farcall call_02_54f9_SwitchPlayerAction
    ret                                                ;; 00:0623 $c9

call_00_0624_SetFly_TimersAndFlags:
; Acts like a state setter for variables around wDC5x–wDCAx.
; Reads current state from wDC51_CurrentFlyRelated, swaps with A, and depending on the old state (01–05) 
; initializes timers/flags (wDCAA_FlyTimerOrFlags1, wDCAB_FlyTimerOrFlags2, wDCA8_FlyTimerOrFlags3, 
; wDCA9_FlyTimerOrFlags4, wDCAE_FlyTimerOrFlags5).
; Special case for state 03: increments a counter, sets a flag in wDB69.
; Looks like it initializes different “modes” or “phases” (timers controlling durations).
    ld   hl,wDC51_CurrentFlyRelated
    ld   c,[hl]
    ld   [hl],a
    ld   a,c
    cp   a,$03
    jr   z,.jr_00_0682
    cp   a,$04
    jp   z,call_00_0723_IncrementCollectibleCount.jr_00_074b
    cp   a,$01
    jr   z,.jr_00_066C
    cp   a,$05
    jr   z,.jr_00_0655
    cp   a,$02
    ret  nz
    xor  a
    ld   [wDCAA_FlyTimerOrFlags1],a
    ld   [wDCAB_FlyTimerOrFlags2],a
    ld   a,$14
    ld   [wDCA9_FlyTimerOrFlags4],a
    ld   a,$3C
    ld   [wDCA8_FlyTimerOrFlags3],a
    ld   a,$02
    ld   [wDCAE_FlyTimerOrFlags5],a
    ret  
.jr_00_0655:
    xor  a
    ld   [wDCAA_FlyTimerOrFlags1],a
    ld   [wDCA9_FlyTimerOrFlags4],a
    ld   a,$14
    ld   [wDCAB_FlyTimerOrFlags2],a
    ld   a,$3C
    ld   [wDCA8_FlyTimerOrFlags3],a
    ld   a,$01
    ld   [wDCAE_FlyTimerOrFlags5],a
    ret  
.jr_00_066C:
    xor  a
    ld   [wDCA9_FlyTimerOrFlags4],a
    ld   [wDCAB_FlyTimerOrFlags2],a
    ld   a,$14
    ld   [wDCAA_FlyTimerOrFlags1],a
    ld   a,$3C
    ld   [wDCA8_FlyTimerOrFlags3],a
    xor  a
    ld   [wDCAE_FlyTimerOrFlags5],a
    ret  
.jr_00_0682:
    ld   a,[wDC4F_PawCoinExtraHealth]
    add  a,$04
    ld   hl,wDC50_PlayerHealth
    cp   [hl]
    ret  z
    inc  [hl]
    ld   hl,wDB69
    set  1,[hl]
    ret  

jp_00_0693:
    ld   HL, wDABE_UnkBGCollisionFlags2                                     ;; 00:0693 $21 $be $da
    bit  7, [HL]                                       ;; 00:0696 $cb $7e
    jr   NZ, .jr_00_06ba                               ;; 00:0698 $20 $20
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:069a $fa $6c $db
    cp   A, $07                                        ;; 00:069d $fe $07
    ld   A, PLAYERACTION_UNK26_2                                        ;; 00:069f $3e $2e
    jr   Z, .jr_00_06ae                                ;; 00:06a1 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:06a3 $fa $6c $db
    cp   A, $08                                        ;; 00:06a6 $fe $08
    ld   A, PLAYERACTION_UNK26_3                                        ;; 00:06a8 $3e $3b
    jr   Z, .jr_00_06ae                                ;; 00:06aa $28 $02
    ld   A, PLAYERACTION_UNK26                                        ;; 00:06ac $3e $1a
.jr_00_06ae:
    farcall call_02_54f9_SwitchPlayerAction
    ret                                                ;; 00:06b9 $c9
.jr_00_06ba:
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:06ba $fa $6c $db
    cp   A, $07                                        ;; 00:06bd $fe $07
    ld   A, PLAYERACTION_DIE_2                                        ;; 00:06bf $3e $2a
    jr   Z, .jr_00_06ce                                ;; 00:06c1 $28 $0b
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:06c3 $fa $6c $db
    cp   A, $08                                        ;; 00:06c6 $fe $08
    ld   A, PLAYERACTION_DIE_3                                        ;; 00:06c8 $3e $37
    jr   Z, .jr_00_06ce                                ;; 00:06ca $28 $02
    ld   A, PLAYERACTION_DIE                                        ;; 00:06cc $3e $0a
.jr_00_06ce:
    farcall call_02_54f9_SwitchPlayerAction
    ret                                                ;; 00:06d9 $c9

jp_00_06da:
    ld   A, PLAYERACTION_DIE_IN_PIT                                        ;; 00:06da $3e $1b
    farcall call_02_54f9_SwitchPlayerAction
    ret                                                ;; 00:06e7 $c9

jp_00_06e8:
    ld   A, PLAYERACTION_UNK19                                        ;; 00:06e8 $3e $13
    farcall call_02_54f9_SwitchPlayerAction
    ret                                                ;; 00:06f5 $c9

call_00_06f6_DealDamageToPlayer:
; Returns if player is currently in damage cooldown.
; If passes: sets timer wDC7E_PlayerDamageCooldownTimer=3C, sets flag bit1 in wDB69, plays sound 0A.
; Then manipulates wDC51_CurrentFlyRelated and wDC50_PlayerHealth counters, decrementing until zero. If it hits 0, jumps to jp_00_0693.
; This is a hit/interaction response handler with timers, sound, and state decrement.
    call call_00_0759_IsPlayerDamageCooldownActive                                  ;; 00:06f6 $cd $59 $07
    ret  NZ                                            ;; 00:06f9 $c0
    ld   A, $3c                                        ;; 00:06fa $3e $3c
    ld   [wDC7E_PlayerDamageCooldownTimer], A                                    ;; 00:06fc $ea $7e $dc
    ld   HL, wDB69                                     ;; 00:06ff $21 $69 $db
    set  1, [HL]                                       ;; 00:0702 $cb $ce
    ld   A, SFX_PLAYER_DAMAGED                                        ;; 00:0704 $3e $0a
    call call_00_0ff5_QueueSoundEffect                                  ;; 00:0706 $cd $f5 $0f
    ld   HL, wDC51_CurrentFlyRelated                                     ;; 00:0709 $21 $51 $dc
    ld   A, [HL]                                       ;; 00:070c $7e
    and  A, A                                          ;; 00:070d $a7
    jr   Z, .jr_00_0713                                ;; 00:070e $28 $03
    ld   [HL], $00                                     ;; 00:0710 $36 $00
    ret                                                ;; 00:0712 $c9
.jr_00_0713:
    ld   A, [wDC50_PlayerHealth]                                    ;; 00:0713 $fa $50 $dc
    sub  A, $01                                        ;; 00:0716 $d6 $01
    jr   NC, .jr_00_071b                               ;; 00:0718 $30 $01
    xor  A, A                                          ;; 00:071a $af
.jr_00_071b:
    ld   [wDC50_PlayerHealth], A                                    ;; 00:071b $ea $50 $dc
    and  A, A                                          ;; 00:071e $a7
    jp   Z, jp_00_0693                                 ;; 00:071f $ca $93 $06
    ret                                                ;; 00:0722 $c9

call_00_0723_IncrementCollectibleCount:
; Sets flag bit0 in wDB69, plays sound 02.
; Increments counter wDC68_CollectibleCount, triggers sound effects and sets a per-level 
; completion flag when it reaches 0x32 or 0x64.
; Also increments wDC4E_PlayerLivesRemaining but caps at 63.
; Looks like it manages collectible counters / progress milestones.
    ld   HL, wDB69                                     ;; 00:0723 $21 $69 $db
    set  0, [HL]                                       ;; 00:0726 $cb $c6
    ld   A, SFX_ITEM_PICKUP                                        ;; 00:0728 $3e $02
    call call_00_0ff5_QueueSoundEffect                                  ;; 00:072a $cd $f5 $0f
    ld   HL, wDC68_CollectibleCount                                     ;; 00:072d $21 $68 $dc
    inc  [HL]                                          ;; 00:0730 $34
    ld   A, [HL]                                       ;; 00:0731 $7e
    cp   A, $32                                        ;; 00:0732 $fe $32
    jr   Z, .jr_00_074b                                ;; 00:0734 $28 $15
    cp   A, $64                                        ;; 00:0736 $fe $64
    ret  NZ                                            ;; 00:0738 $c0
    ld   A, SFX_REMOTE                                        ;; 00:0739 $3e $1e
    call call_00_0ff5_QueueSoundEffect                                  ;; 00:073b $cd $f5 $0f
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 00:073e $21 $1e $dc
    ld   L, [HL]                                       ;; 00:0741 $6e
    ld   H, $00                                        ;; 00:0742 $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 00:0744 $11 $5c $dc
    add  HL, DE                                        ;; 00:0747 $19
    set  3, [HL]                                       ;; 00:0748 $cb $de
    ret                                                ;; 00:074a $c9
.jr_00_074b:
    ld   HL, wDC4E_PlayerLivesRemaining                                     ;; 00:074b $21 $4e $dc
    ld   A, [HL]                                       ;; 00:074e $7e
    cp   A, $63                                        ;; 00:074f $fe $63
    ret  NC                                            ;; 00:0751 $d0
    inc  [HL]                                          ;; 00:0752 $34
    ld   HL, wDB69                                     ;; 00:0753 $21 $69 $db
    set  0, [HL]                                       ;; 00:0756 $cb $c6
    ret                                                ;; 00:0758 $c9

call_00_0759_IsPlayerDamageCooldownActive:
    ld   A, [wDC7E_PlayerDamageCooldownTimer]                                    ;; 00:0759 $fa $7e $dc
    and  A, A                                          ;; 00:075c $a7
    ret  NZ                                            ;; 00:075d $c0
    ret                                                ;; 00:075e $c9

call_00_075f_SwitchBankAndCopyBCBytesFromHLToDE:
    push HL                                            ;; 00:075f $e5
    push DE                                            ;; 00:0760 $d5
    push BC                                            ;; 00:0761 $c5
    call call_00_0eee_SwitchBank                                  ;; 00:0762 $cd $ee $0e
    pop  BC                                            ;; 00:0765 $c1
    pop  DE                                            ;; 00:0766 $d1
    pop  HL                                            ;; 00:0767 $e1
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:0768 $cd $6e $07
    jp   call_00_0f08_RestoreBank                                  ;; 00:076b $c3 $08 $0f

call_00_076e_CopyBCBytesFromHLToDE:
    ld   A, [HL+]                                      ;; 00:076e $2a
    ld   [DE], A                                       ;; 00:076f $12
    inc  DE                                            ;; 00:0770 $13
    dec  BC                                            ;; 00:0771 $0b
    ld   A, B                                          ;; 00:0772 $78
    or   A, C                                          ;; 00:0773 $b1
    jr   NZ, call_00_076e_CopyBCBytesFromHLToDE                              ;; 00:0774 $20 $f8
    ret                                                ;; 00:0776 $c9

call_00_0777_LoadPointerIndexAFromTableDE:
    ld   L, A                                          ;; 00:0777 $6f
    ld   H, $00                                        ;; 00:0778 $26 $00
    add  HL, HL                                        ;; 00:077a $29
    add  HL, DE                                        ;; 00:077b $19
    ld   E, [HL]                                       ;; 00:077c $5e
    inc  HL                                            ;; 00:077d $23
    ld   H, [HL]                                       ;; 00:077e $66
    ld   L, E                                          ;; 00:077f $6b
    ret                                                ;; 00:0780 $c9

jp_00_0781:
    ld   A, [wDBB2_MenuCommandBuffer4_Bank]                                    ;; 00:0781 $fa $b2 $db
    call call_00_0eee_SwitchBank                                  ;; 00:0784 $cd $ee $0e
    ld   HL, wDBB7_MenuCommandBuffer4_BankOffset                                     ;; 00:0787 $21 $b7 $db
    ld   C, [HL]                                       ;; 00:078a $4e
    inc  HL                                            ;; 00:078b $23
    ld   B, [HL]                                       ;; 00:078c $46
    ld   HL, wDBB5_MenuCommandBuffer4_Unk4                                     ;; 00:078d $21 $b5 $db
    ld   A, [HL+]                                      ;; 00:0790 $2a
    ld   H, [HL]                                       ;; 00:0791 $66
    ld   L, A                                          ;; 00:0792 $6f
    ld   A, C                                          ;; 00:0793 $79
    sub  A, $00                                        ;; 00:0794 $d6 $00
    ld   E, A                                          ;; 00:0796 $5f
    ld   A, B                                          ;; 00:0797 $78
    sbc  A, $10                                        ;; 00:0798 $de $10
    jr   C, .jr_00_07b2                                ;; 00:079a $38 $16
    ld   B, A                                          ;; 00:079c $47
    ld   C, E                                          ;; 00:079d $4b
    push HL                                            ;; 00:079e $e5
    ld   DE, $1000                                     ;; 00:079f $11 $00 $10
    add  HL, DE                                        ;; 00:07a2 $19
    ld   DE, wC000_BgMapTileIds                                     ;; 00:07a3 $11 $00 $c0
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07a6 $cd $6e $07
    ld   C, $0a                                        ;; 00:07a9 $0e $0a
    call call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 00:07ab $cd $6a $0a
    pop  HL                                            ;; 00:07ae $e1
    ld   BC, $1000                                     ;; 00:07af $01 $00 $10
.jr_00_07b2:
    ld   DE, wC000_BgMapTileIds                                     ;; 00:07b2 $11 $00 $c0
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07b5 $cd $6e $07
    ld   HL, wDBB3_MenuCommandBuffer4_Unk2                                     ;; 00:07b8 $21 $b3 $db
    ld   A, [HL+]                                      ;; 00:07bb $2a
    ld   H, [HL]                                       ;; 00:07bc $66
    ld   L, A                                          ;; 00:07bd $6f
    ld   DE, wD400_TileBuffer                                     ;; 00:07be $11 $00 $d4
    ld   BC, $168                                      ;; 00:07c1 $01 $68 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07c4 $cd $6e $07
    ld   A, [wDBB1_MenuCommandBuffer4_Unk0]                                    ;; 00:07c7 $fa $b1 $db
    and  A, A                                          ;; 00:07ca $a7
    jr   Z, .jr_00_07d9                                ;; 00:07cb $28 $0c
    ld   DE, wD578_TileBuffer2                                     ;; 00:07cd $11 $78 $d5
    ld   BC, $168                                      ;; 00:07d0 $01 $68 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07d3 $cd $6e $07
    jp   call_00_0f08_RestoreBank                                  ;; 00:07d6 $c3 $08 $0f
.jr_00_07d9:
    push HL                                            ;; 00:07d9 $e5
    ld   HL, wD400_TileBuffer                                     ;; 00:07da $21 $00 $d4
    ld   DE, wD578_TileBuffer2                                     ;; 00:07dd $11 $78 $d5
    ld   BC, $168                                      ;; 00:07e0 $01 $68 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:07e3 $cd $6e $07
    pop  DE                                            ;; 00:07e6 $d1
    ld   HL, wD578_TileBuffer2                                     ;; 00:07e7 $21 $78 $d5
    ld   BC, $168                                      ;; 00:07ea $01 $68 $01
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
    jp   call_00_0f08_RestoreBank                                  ;; 00:07fd $c3 $08 $0f

call_00_0800:
    push HL                                            ;; 00:0800 $e5
    push DE                                            ;; 00:0801 $d5
    push BC                                            ;; 00:0802 $c5
    push HL                                            ;; 00:0803 $e5
    ld   A, BANK_1F_SECONDARY_TILESETS                                        ;; 00:0804 $3e $1f
    call call_00_0eee_SwitchBank                                  ;; 00:0806 $cd $ee $0e
    ld   A, [wDB6C_CurrentMapId]                                    ;; 00:0809 $fa $6c $db
    ld   DE, $b01                                      ;; 00:080c $11 $01 $0b
    call call_00_0777_LoadPointerIndexAFromTableDE                                  ;; 00:080f $cd $77 $07
    ld   DE, $300                                      ;; 00:0812 $11 $00 $03
    add  HL, DE                                        ;; 00:0815 $19
    ld   E, L                                          ;; 00:0816 $5d
    ld   D, H                                          ;; 00:0817 $54
    pop  HL                                            ;; 00:0818 $e1
    ld   C, $06                                        ;; 00:0819 $0e $06
.jr_00_081b:
    ld   B, $08                                        ;; 00:081b $06 $08
.jr_00_081d:
    ld   A, [DE]                                       ;; 00:081d $1a
    ld   [HL+], A                                      ;; 00:081e $22
    inc  DE                                            ;; 00:081f $13
    dec  B                                             ;; 00:0820 $05
    jr   NZ, .jr_00_081d                               ;; 00:0821 $20 $fa
    ld   A, L                                          ;; 00:0823 $7d
    add  A, $0c                                        ;; 00:0824 $c6 $0c
    ld   L, A                                          ;; 00:0826 $6f
    ld   A, H                                          ;; 00:0827 $7c
    adc  A, $00                                        ;; 00:0828 $ce $00
    ld   H, A                                          ;; 00:082a $67
    dec  C                                             ;; 00:082b $0d
    jr   NZ, .jr_00_081b                               ;; 00:082c $20 $ed
    call call_00_0f08_RestoreBank                                  ;; 00:082e $cd $08 $0f
    pop  BC                                            ;; 00:0831 $c1
    pop  DE                                            ;; 00:0832 $d1
    pop  HL                                            ;; 00:0833 $e1
    ret                                                ;; 00:0834 $c9

call_00_0835_LoadFromTextBank1C:
    ld   A, BANK_1C_TEXT                                        ;; 00:0835 $3e $1c
    call call_00_0eee_SwitchBank                                  ;; 00:0837 $cd $ee $0e
    ld   HL, wDBA7_MenuCommandBuffer2_Unk3                                     ;; 00:083a $21 $a7 $db
    ld   A, [HL+]                                      ;; 00:083d $2a
    ld   D, [HL]                                       ;; 00:083e $56
    ld   E, A                                          ;; 00:083f $5f
    ld   HL, wDBF8                                     ;; 00:0840 $21 $f8 $db
    ld   L, [HL]                                       ;; 00:0843 $6e
    ld   H, $00                                        ;; 00:0844 $26 $00
    add  HL, HL                                        ;; 00:0846 $29
    add  HL, DE                                        ;; 00:0847 $19
    ld   A, [HL+]                                      ;; 00:0848 $2a
    ld   H, [HL]                                       ;; 00:0849 $66
    ld   L, A                                          ;; 00:084a $6f
    ld   DE, wDADD                                     ;; 00:084b $11 $dd $da
.jr_00_084e:
    ld   A, [HL+]                                      ;; 00:084e $2a
    ld   [DE], A                                       ;; 00:084f $12
    inc  DE                                            ;; 00:0850 $13
    bit  7, A                                          ;; 00:0851 $cb $7f
    jr   Z, .jr_00_084e                                ;; 00:0853 $28 $f9
    xor  A, A                                          ;; 00:0855 $af
    ld   [DE], A                                       ;; 00:0856 $12
    ld   HL, wDADD                                     ;; 00:0857 $21 $dd $da
    ld   A, L                                          ;; 00:085a $7d
    ld   [wDBA7_MenuCommandBuffer2_Unk3], A                                    ;; 00:085b $ea $a7 $db
    ld   A, H                                          ;; 00:085e $7c
    ld   [wDBA8_MenuCommandBuffer2_Unk4], A                                    ;; 00:085f $ea $a8 $db
    jp   call_00_0f08_RestoreBank                                  ;; 00:0862 $c3 $08 $0f

call_00_0865_LoadFromTextBank1C_2:
    push de
    ld   a,BANK_1C_TEXT
    call call_00_0eee_SwitchBank
    pop  de
    ld   hl,wDBF8
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

call_00_088a_HDMA_BackgroundAnimator:
; Animated HDMA effect updater.
; Increments counters, steps through a small table of structs,
; and sets up rHDMA1–rHDMA5 for transfers.
; Used for per-frame wavy/gradient background effects.
; Purpose: This one handles HDMA-driven background animations (parallax, waves, etc.).
; It’s only called if wDBE3 is nonzero (animation active).
    ld   A, [wDBE3]                                    ;; 00:088a $fa $e3 $db
    and  A, A                                          ;; 00:088d $a7
    ret  Z                                             ;; 00:088e $c8
    ld   A, BANK_0A_OBJECT_SPRITES                                        ;; 00:088f $3e $0a
    call call_00_0eee_SwitchBank                                  ;; 00:0891 $cd $ee $0e
    ld   HL, wDC72_FrameCounter2                                     ;; 00:0894 $21 $72 $dc
    inc  [HL]                                          ;; 00:0897 $34
    ld   A, [HL]                                       ;; 00:0898 $7e
    sub  A, $0a                                        ;; 00:0899 $d6 $0a
    jr   NZ, .jr_00_089e                               ;; 00:089b $20 $01
    ld   [HL], A                                       ;; 00:089d $77
.jr_00_089e:
    ld   DE, .data_00_08dc                                      ;; 00:089e $11 $dc $08
    ld   B, $04                                        ;; 00:08a1 $06 $04
.jr_00_08a3:
    ld   A, [DE]                                       ;; 00:08a3 $1a
    inc  DE                                            ;; 00:08a4 $13
    ld   L, A                                          ;; 00:08a5 $6f
    ld   A, [DE]                                       ;; 00:08a6 $1a
    inc  DE                                            ;; 00:08a7 $13
    ld   H, A                                          ;; 00:08a8 $67
    ld   A, [wDC72_FrameCounter2]                                    ;; 00:08a9 $fa $72 $dc
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
    jp   call_00_0f08_RestoreBank                                  ;; 00:08d9 $c3 $08 $0f
.data_00_08dc:
    dw   wDBE4                                         ;; 00:08dc pP
    db   $08, $a0, $57, $80, $8f                       ;; 00:08de .....
    dw   wDBE5                                         ;; 00:08e3 pP
    db   $04, $a0, $4a, $c0, $8e                       ;; 00:08e5 .....
    dw   wDBE6                                         ;; 00:08ea pP
    db   $06, $a0, $4b, $00, $8f                       ;; 00:08ec .....
    dw   wDBE7                                         ;; 00:08f1 pP
    db   $08, $20, $4d, $40, $8f                       ;; 00:08f3 .....

call_00_08f8_SetupObjectVRAMTransfer:
; Prepares an object’s graphics for VRAM upload.
; Resolves the active object’s type and data pointer, stores the source address in wDB64/65, 
; and sets the appropriate wDB66_HDMATransferFlags so that HandlePendingHDMATransfers will 
; stream the tiles into VRAM on the next frame.
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:08f8 $21 $66 $db
    bit  7, [HL]                                       ;; 00:08fb $cb $7e
    jr   NZ, call_00_08f8_SetupObjectVRAMTransfer                              ;; 00:08fd $20 $f9
    bit  2, [HL]                                       ;; 00:08ff $cb $56
    jp   NZ, .jp_00_0a52                               ;; 00:0901 $c2 $52 $0a
    bit  0, [HL]                                       ;; 00:0904 $cb $46
    jp   NZ, .jp_00_0a52                               ;; 00:0906 $c2 $52 $0a
    bit  1, [HL]                                       ;; 00:0909 $cb $4e
    ret  NZ                                            ;; 00:090b $c0
    ld   HL, wD840_ObjectMemoryAfterPlayer                                     ;; 00:090c $21 $40 $d8
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
    add  A, $20                                        ;; 00:0924 $c6 $20
    ld   L, A                                          ;; 00:0926 $6f
    jr   NZ, .jr_00_090f                               ;; 00:0927 $20 $e6
    ret                                                ;; 00:0929 $c9
.jr_00_092a:
    res  1, [HL]                                       ;; 00:092a $cb $8e
    pop  HL                                            ;; 00:092c $e1
    ld   A, L                                          ;; 00:092d $7d
    ld   [wDB61_ActiveObjectSlot], A                                    ;; 00:092e $ea $61 $db
    or   A, $0a                                        ;; 00:0931 $f6 $0a
    ld   L, A                                          ;; 00:0933 $6f
    ld   C, [HL]                                       ;; 00:0934 $4e
    inc  C                                             ;; 00:0935 $0c
    ld   A, L                                          ;; 00:0936 $7d
    xor  A, $0a                                        ;; 00:0937 $ee $0a
    ld   L, A                                          ;; 00:0939 $6f
    ld   B, [HL]                                       ;; 00:093a $46
    ld   HL, .jr_00_096e                                      ;; 00:093b $21 $6e $09
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
    ld   [wDB64_VRAMTransferSource], A                                    ;; 00:0956 $ea $64 $db
    ld   A, H                                          ;; 00:0959 $7c
    ld   [wDB64_VRAMTransferSource+1], A                                    ;; 00:095a $ea $65 $db
    farcall call_03_59b6_LookupObjectPropertyFromType
    ld   [wDB63_ActiveObjectType], A                                    ;; 00:0968 $ea $63 $db
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:096b $21 $66 $db
.jr_00_096e:
    set  1, [HL]                                       ;; 00:096e $cb $ce
    set  7, [HL]                                       ;; 00:0970 $cb $fe
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
    ld   [wDB61_ActiveObjectSlot], A                                    ;; 00:09a0 $ea $61 $db
    or   A, $0a                                        ;; 00:09a3 $f6 $0a
    ld   L, A                                          ;; 00:09a5 $6f
    ld   A, [HL]                                       ;; 00:09a6 $7e
    push AF                                            ;; 00:09a7 $f5
    farcall call_03_59b6_LookupObjectPropertyFromType
    ld   [wDB63_ActiveObjectType], A                                    ;; 00:09b3 $ea $63 $db
    ld   L, A                                          ;; 00:09b6 $6f
    ld   H, $00                                        ;; 00:09b7 $26 $00
    add  HL, HL                                        ;; 00:09b9 $29
    ld   DE, .data_00_0a58_ObjectVRAMSourceResolvers                                      ;; 00:09ba $11 $58 $0a
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
    ld   DE, $4000                              ;; 00:09fb $11 $00 $40
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
    ld   HL, $4000                              ;; 00:0a23 $21 $00 $40
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
    ld   HL, $4000                              ;; 00:0a41 $21 $00 $40
    add  HL, DE                                        ;; 00:0a44 $19
.jr_00_0a45:
    ld   A, L                                          ;; 00:0a45 $7d
    ld   [wDB64_VRAMTransferSource], A                                    ;; 00:0a46 $ea $64 $db
    ld   A, H                                          ;; 00:0a49 $7c
    ld   [wDB64_VRAMTransferSource+1], A                                    ;; 00:0a4a $ea $65 $db
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0a4d $21 $66 $db
    set  1, [HL]                                       ;; 00:0a50 $cb $ce
.jp_00_0a52:
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0a52 $21 $66 $db
    set  7, [HL]                                       ;; 00:0a55 $cb $fe
    ret                                                ;; 00:0a57 $c9
.data_00_0a58_ObjectVRAMSourceResolvers:
; Used to resolve which function to run based on object type (wDB63_ActiveObjectType).
    dw   .jr_00_0a17, .jr_00_0a17, .jr_00_0a29        ;; 00:0a58 ??
    dw   .jr_00_09c6, .jr_00_0a37, .jr_00_09db        ;; 00:0a5e ??????
    dw   .jr_00_09f0, .jr_00_0a01, .jr_00_0a41        ;; 00:0a64 pP

call_00_0a6a_LoadMapConfigAndWaitVBlank:
; This function loads configuration data for a map or scene, stores it in working memory (wDC2B_HDMATransferRelated1), 
; adjusts tile bank offsets if needed, and waits for bit 2 of wDB66_HDMATransferFlags to clear, 
; likely indicating VBlank or scene loading finished.
;
; Key Actions:
; - Indexes into .data_00_0aa9_TilesetLoadConfigTable using a value in register C to get map/scene config.
; - Copies 8 bytes of data to wDC2B_HDMATransferRelated1.
; - If a certain flag is unset (wDC31_TilesetBankRelated == $FF), calculates and writes tile offsets and assigns tile bank (wDC07).
; - Sets bits 2 and 7 in wDB66_HDMATransferFlags.
; - Waits for VBlank or completion signal (bit 2 of wDB66_HDMATransferFlags cleared).
    ld   L, C                                          ;; 00:0a6a $69
    ld   H, $00                                        ;; 00:0a6b $26 $00
    add  HL, HL                                        ;; 00:0a6d $29
    add  HL, HL                                        ;; 00:0a6e $29
    add  HL, HL                                        ;; 00:0a6f $29
    ld   DE, .data_00_0aa9_TilesetLoadConfigTable                                      ;; 00:0a70 $11 $a9 $0a
    add  HL, DE                                        ;; 00:0a73 $19
    ld   DE, wDC2B_HDMATransferRelated1                                     ;; 00:0a74 $11 $2b $dc
    ld   BC, $08                                       ;; 00:0a77 $01 $08 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:0a7a $cd $6e $07
    ld   A, [wDC31_TilesetBankRelated]                                    ;; 00:0a7d $fa $31 $dc
    cp   A, $ff                                        ;; 00:0a80 $fe $ff
    jr   NZ, .jr_00_0a94                               ;; 00:0a82 $20 $10
    ld   HL, wDC2B_HDMATransferRelated1                                     ;; 00:0a84 $21 $2b $dc
    ld   A, [wDC08_TilesetBankOffset]                                    ;; 00:0a87 $fa $08 $dc
    add  A, [HL]                                       ;; 00:0a8a $86
    ld   [HL+], A                                      ;; 00:0a8b $22
    ld   A, [wDC08_TilesetBankOffset+1]                                    ;; 00:0a8c $fa $09 $dc
    adc  A, [HL]                                       ;; 00:0a8f $8e
    ld   [HL], A                                       ;; 00:0a90 $77
    ld   A, [wDC07_TilesetBank]                                    ;; 00:0a91 $fa $07 $dc
.jr_00_0a94:
    ld   [wDC31_TilesetBankRelated], A                                    ;; 00:0a94 $ea $31 $dc
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0a97 $21 $66 $db
    set  2, [HL]                                       ;; 00:0a9a $cb $d6
    set  7, [HL]                                       ;; 00:0a9c $cb $fe
.jr_00_0a9e:
    call call_00_0b92_WaitForInterrupt                                  ;; 00:0a9e $cd $92 $0b
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0aa1 $21 $66 $db
    bit  2, [HL]                                       ;; 00:0aa4 $cb $56
    jr   NZ, .jr_00_0a9e                               ;; 00:0aa6 $20 $f6
    ret                                                ;; 00:0aa8 $c9
.data_00_0aa9_TilesetLoadConfigTable:
; Each entry seems to have:
; - Source address
; - Destination address
; - Size
; - Mode/flags
; Likely defines how to load a tileset.
    dw   $7800, _VRAM, $03c0, $010c                    ;; 00:0aa9 $78 $00
    dw   $7c00, _SCRN1, $0040, $010c                    ;; 00:0ab1 $00 $0c
    dw   $7bc0, _SCRN1, $0040, $000c                    ;; 00:0ab9 $00 $0c
    dw   $0000, _VRAM+$1000, $0800, $00ff                    ;; 00:0ac1 ........
    dw   $0800, _VRAM+$800, $0800, $00ff                    ;; 00:0ac9 ........
    dw   $1000, _VRAM+$1000, $0800, $01ff                    ;; 00:0ad1 ........
    dw   $1800, _VRAM+$800, $0800, $01ff                    ;; 00:0ad9 ........
    dw   $c000, _SCRN0, $0400, $0101                    ;; 00:0ae1 ........
    dw   $c000, _SCRN0, $0400, $0001                    ;; 00:0ae9 ........
    dw   $c000, _VRAM, $1000, $0001                    ;; 00:0af1 ........
    dw   $c000, _VRAM, $1000, $0101                    ;; 00:0af9 .???????

    dw   $4000, $4000, $4350, $46a0                    ;; 00:0b01 .???????
    dw   $49f0, $4d40, $5090, $53e0                    ;; 00:0b09 .???????
    dw   $53e0, $5730, $5a80, $5dd0                    ;; 00:0b11 .???????
    dw   $0100, $0502, $0d09, $8312                    ;; 00:0b19 .???????
    dw   $0e87, $1713                                  ;; 00:0b21 .???????

call_00_0b25_MainGameLoop_UpdateAndRenderFrame:
; This function looks like the main game engine loop's frame handler, managing:
; - Logic processing
; - Rendering updates
; - Palette transfer
; - Scroll registers
; - Double-buffered bank switching
; It’s called each frame, updates the game state, handles the player/controller input, 
; and finally waits for a proper rendering time based on LY.
;
; Key Actions:
; - Saves registers.
; - Calls system update (hFF80, call_00_0b9f).
; - Runs frame callback from wD9FE.
; - Reads joypad input, updates palettes, writes scroll/window registers.
; - Loads palette data to hardware.
; - Increments frame counter.
; - Bank-switches and calls rendering code.
; - Sets interrupt flag and waits until scanline passes certain points before continuing.
; - Clears LCD interrupt flag and restores registers.
    push AF                                            ;; 00:0b25 $f5
    push BC                                            ;; 00:0b26 $c5
    push DE                                            ;; 00:0b27 $d5
    push HL                                            ;; 00:0b28 $e5
    call hFF80                                         ;; 00:0b29 $cd $80 $ff
    call call_00_0b9f_Frame_TilemapUpdateHandler                                  ;; 00:0b2c $cd $9f $0b
    ld   A, [wD9FD]                                    ;; 00:0b2f $fa $fd $d9
    bit  7, A                                          ;; 00:0b32 $cb $7f
    call Z, call_00_0c1b_LCDInterrupt_Setup                               ;; 00:0b34 $cc $1b $0c
    ld   HL, wD9FE                                     ;; 00:0b37 $21 $fe $d9
    ld   A, [HL+]                                      ;; 00:0b3a $2a
    ld   H, [HL]                                       ;; 00:0b3b $66
    ld   L, A                                          ;; 00:0b3c $6f
    call call_00_0f22_JumpHL                                  ;; 00:0b3d $cd $22 $0f
    call call_00_0f31_ReadJoypadInput                                  ;; 00:0b40 $cd $31 $0f
    call call_00_0e81_LoadPalettesToHardware                                  ;; 00:0b43 $cd $81 $0e
    ld   A, [wDAD8_LCDControlMirror]                                    ;; 00:0b46 $fa $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0b49 $e0 $40
    ld   A, [wDAD9_ScrollX]                                    ;; 00:0b4b $fa $d9 $da
    ldh  [rSCX], A                                     ;; 00:0b4e $e0 $43
    ld   A, [wDADA_ScrollY]                                    ;; 00:0b50 $fa $da $da
    ldh  [rSCY], A                                     ;; 00:0b53 $e0 $42
    ld   A, [wDADB_WindowX]                                    ;; 00:0b55 $fa $db $da
    ldh  [rWX], A                                      ;; 00:0b58 $e0 $4b
    ld   A, [wDADC_WindowY]                                    ;; 00:0b5a $fa $dc $da
    ldh  [rWY], A                                      ;; 00:0b5d $e0 $4a
    ld   HL, wDC71_FrameCounter                                     ;; 00:0b5f $21 $71 $dc
    inc  [HL]                                          ;; 00:0b62 $34
    ld   A, [wDE60_AudioBankCurrent]                                    ;; 00:0b63 $fa $60 $de
    add  A, BANK_04_AUDIO_CODE_1                                        ;; 00:0b66 $c6 $04
    call call_00_0f25_AltSwitchBank                                  ;; 00:0b68 $cd $25 $0f
    call call_04_4009                                  ;; 00:0b6b $cd $09 $40
    ld   A, [wDAD5_CurrentROMBank]                                    ;; 00:0b6e $fa $d5 $da
    call call_00_0f25_AltSwitchBank                                  ;; 00:0b71 $cd $25 $0f
    ld   A, $01                                        ;; 00:0b74 $3e $01
    ld   [wDB6B_InterruptFlag], A                                    ;; 00:0b76 $ea $6b $db
    ldh  A, [rLY]                                      ;; 00:0b79 $f0 $44
    cp   A, $90                                        ;; 00:0b7b $fe $90
    jr   NC, .jr_00_0b88                               ;; 00:0b7d $30 $09
    ld   C, A                                          ;; 00:0b7f $4f
.jr_00_0b80:
    ldh  A, [rLY]                                      ;; 00:0b80 $f0 $44
    cp   A, C                                          ;; 00:0b82 $b9
    jr   Z, .jr_00_0b80                                ;; 00:0b83 $28 $fb
    ld   [wDB67_HDMATempScratch], A                                    ;; 00:0b85 $ea $67 $db
.jr_00_0b88:
    ld   HL, rIF                                       ;; 00:0b88 $21 $0f $ff
    res  1, [HL]                                       ;; 00:0b8b $cb $8e
    pop  HL                                            ;; 00:0b8d $e1
    pop  DE                                            ;; 00:0b8e $d1
    pop  BC                                            ;; 00:0b8f $c1
    pop  AF                                            ;; 00:0b90 $f1
    reti                                               ;; 00:0b91 $d9

call_00_0b92_WaitForInterrupt:
; Waits until wDB6B_InterruptFlag is set to a non-zero value.
; Clears wDB6B_InterruptFlag, then halts repeatedly until it changes,
;
; Likely Purpose:
; WaitForInterrupt() is a function that halts execution until the next VBlank interrupt 
; (or possibly HBlank, depending on timing needs). It helps:
; Synchronize screen updates: Ensures that graphics updates happen between frames to avoid screen tearing.
; Pace execution: Prevents the game from running logic too fast.
; Wait for user input timing: Helps in detecting stable button states.
;
; In general:
; This is typical Game Boy programming practice, as VBlank occurs ~60 times/sec and is the best 
; moment to safely write to VRAM and OAM.
    xor  A, A                                          ;; 00:0b92 $af
    ld   [wDB6B_InterruptFlag], A                                    ;; 00:0b93 $ea $6b $db
.jr_00_0b96:
    halt                                               ;; 00:0b96 $76
    nop                                                ;; 00:0b97 $00
    ld   A, [wDB6B_InterruptFlag]                                    ;; 00:0b98 $fa $6b $db
    and  A, A                                          ;; 00:0b9b $a7
    jr   Z, .jr_00_0b96                                ;; 00:0b9c $28 $f8
    ret                                                ;; 00:0b9e $c9

call_00_0b9f_Frame_TilemapUpdateHandler:
;; Bank switch to 3.
; Checks wDC20 flags (bit 7 is a “dirty” flag).
; If set, applies queued tilemap updates:
;   - if low 2 bits set → update block (`75e3`)
;   - if bits 2–3 set  → update column (`7664`)
; Clears wDC20 afterwards.
; If no updates, calls status bar and animated background update.
; Purpose: This is the frame entry point for tilemap updates.
; It either processes pending updates (via buffers), or if nothing queued, it runs HUD/background effects.
    ld   A, BANK_03_COLLISION_AND_GRAPHICS_CODE                                        ;; 00:0b9f $3e $03
    call call_00_0f25_AltSwitchBank                                  ;; 00:0ba1 $cd $25 $0f
    ld   HL, wDC20                                     ;; 00:0ba4 $21 $20 $dc
    bit  7, [HL]                                       ;; 00:0ba7 $cb $7e
    jr   Z, .jr_00_0bc6                                ;; 00:0ba9 $28 $1b
    res  7, [HL]                                       ;; 00:0bab $cb $be
    ld   A, [wDC20]                                    ;; 00:0bad $fa $20 $dc
    and  A, $0f                                        ;; 00:0bb0 $e6 $0f
    jr   Z, .jr_00_0bc6                                ;; 00:0bb2 $28 $12
    and  A, $03                                        ;; 00:0bb4 $e6 $03
    call NZ, call_03_75e3_Tilemap_UpdateBlockFromBuffer                              ;; 00:0bb6 $c4 $e3 $75
    ld   A, [wDC20]                                    ;; 00:0bb9 $fa $20 $dc
    and  A, $0c                                        ;; 00:0bbc $e6 $0c
    call NZ, call_03_7664_Tilemap_UpdateColumnFromBuffer                              ;; 00:0bbe $c4 $64 $76
    xor  A, A                                          ;; 00:0bc1 $af
    ld   [wDC20], A                                    ;; 00:0bc2 $ea $20 $dc
    ret                                                ;; 00:0bc5 $c9
.jr_00_0bc6:
    call call_03_747d_StatusBar_UpdateOrTiles                                  ;; 00:0bc6 $cd $7d $74
    call call_03_753e_AnimatedBackground_HDMA                                  ;; 00:0bc9 $cd $3e $75
    jp   call_00_088a_HDMA_BackgroundAnimator                                    ;; 00:0bcc $c3 $8a $08

jp_00_0bcf_CopyBlock16BytesLoop:
; A tight copy loop: copies 16 bytes from [HL+] to [DE], decrements counter B, and repeats until zero.
; Generic block-copy routine used by the transfer queue.
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
    jr   NZ, jp_00_0bcf_CopyBlock16BytesLoop                                ;; 00:0c00 $20 $cd
    ret                                                ;; 00:0c02 $c9
    
call_00_0c03_WaitForVRAMCopyCompletion:
; Polls wD9FD masked with $7F. If zero, returns. Otherwise, 
; repeatedly calls call_00_0b92_WaitForInterrupt and loops.
; Essentially “wait until VRAM safe period ends.”
    ld   a,[wD9FD]
    and  a,$7F
    cp   a,$00
    ret  z
    call call_00_0b92_WaitForInterrupt
    jr   call_00_0c03_WaitForVRAMCopyCompletion

call_00_0c10_QueueVRAMCopyRequest:
; Ensures only one copy operation is queued at a time.
; Takes accumulator A, ORs $80, compares against wD9FD. If same, return. Otherwise mask to 7 bits and write.
; Likely a “request VRAM transfer” trigger.
    ld   HL, wD9FD                                     ;; 00:0c10 $21 $fd $d9
    or   A, $80                                        ;; 00:0c13 $f6 $80
    cp   A, [HL]                                       ;; 00:0c15 $be
    ret  Z                                             ;; 00:0c16 $c8
    and  A, $7f                                        ;; 00:0c17 $e6 $7f
    ld   [HL], A                                       ;; 00:0c19 $77
    ret                                                ;; 00:0c1a $c9

call_00_0c1b_LCDInterrupt_Setup:
; Sets up LCD STAT/LYC registers and DMA data.
; Loads parameters from a table (call_00_0c44_LCDInterrupt_Table),
; copies data into wD9A0, stores continuation pointer.
; Purpose: This sets up an LCD interrupt handler configuration (STAT/LYC compare values, data to load on match).
; Likely used for special scanline effects (split screen, color changes).
    ld   L, A                                          ;; 00:0c1b $6f
    or   A, $80                                        ;; 00:0c1c $f6 $80
    ld   [wD9FD], A                                    ;; 00:0c1e $ea $fd $d9
    ld   H, $00                                        ;; 00:0c21 $26 $00
    ld   DE, call_00_0c44_LCDInterrupt_Table                                      ;; 00:0c23 $11 $44 $0c
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
    ld   DE, wD9A0                                     ;; 00:0c32 $11 $a0 $d9
.jr_00_0c35:
    ld   A, [HL+]                                      ;; 00:0c35 $2a
    ld   [DE], A                                       ;; 00:0c36 $12
    inc  E                                             ;; 00:0c37 $1c
    dec  B                                             ;; 00:0c38 $05
    jr   NZ, .jr_00_0c35                               ;; 00:0c39 $20 $fa
    ld   A, L                                          ;; 00:0c3b $7d
    ld   [wD9FE], A                                    ;; 00:0c3c $ea $fe $d9
    ld   A, H                                          ;; 00:0c3f $7c
    ld   [wD9FF], A                                    ;; 00:0c40 $ea $ff $d9
    ret                                                ;; 00:0c43 $c9

call_00_0c44_LCDInterrupt_Table:
; Table of interrupt handlers and parameters.
; Contains a dispatcher that increments wDB67_HDMATempScratch and calls routines like 0d8b, 0dc6.
; Purpose: This is a vector table and handler dispatcher for the STAT/LYC interrupts.
; Different entries configure palette changes, etc.
    db   $08, $00, $01, $53, $0c, $08, $00, $15
    db   $55, $0c, $08, $00, $01, $f8, $0d, $d9

call_00_0c54:
    ret

call_00_0c55:
    push af
    push hl
    ld   a,[wDB67_HDMATempScratch]
    sub  a,$7F
    jp   z,call_00_0d8b_Palette_UpdateBG
    dec  a
    jp   z,call_00_0dc6_HBlankInterrupt_LoadPaletteSlice
    ld   hl,wDB67_HDMATempScratch
    inc  [hl]
    pop  hl
    pop  af
    reti 

call_00_0c6a_HandlePendingHDMATransfers:
; Clears wDB67_HDMATempScratch.
; Reads control flags from wDB66_HDMATransferFlags.
; Depending on bits, it sets up HDMA transfers from different sources:
; Bit 0 → copy tiles from wDAC0_GeneralPurposeDMASourceAddress–wDAC2_DMATransferLength.
; Bit 1 → copy tiles from wDB64_VRAMTransferSource–wDB64_VRAMTransferSource+1.
; Bit 2 → perform a variable-length transfer using wDC2B_HDMATransferRelated1–wDC32.
; Manages VBK for VRAM bank selection when needed.
; Clears the trigger bits after performing the transfer.
    xor  A, A                                          ;; 00:0c6a $af
    ld   [wDB67_HDMATempScratch], A                                    ;; 00:0c6b $ea $67 $db
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0c6e $21 $66 $db
    bit  7, [HL]                                       ;; 00:0c71 $cb $7e
    ret  Z                                             ;; 00:0c73 $c8
    bit  2, [HL]                                       ;; 00:0c74 $cb $56
    jp   NZ, .jp_00_0d14                               ;; 00:0c76 $c2 $14 $0d
    bit  0, [HL]                                       ;; 00:0c79 $cb $46
    jr   NZ, .jr_00_0c84                               ;; 00:0c7b $20 $07
    bit  1, [HL]                                       ;; 00:0c7d $cb $4e
    jr   NZ, .jr_00_0cab                               ;; 00:0c7f $20 $2a
    res  7, [HL]                                       ;; 00:0c81 $cb $be
    ret                                                ;; 00:0c83 $c9
.jr_00_0c84:
    ld   A, [wDABF_GexSpriteBank]                                    ;; 00:0c84 $fa $bf $da
    call call_00_0f25_AltSwitchBank                                  ;; 00:0c87 $cd $25 $0f
    ld   A, [wDAC0_GeneralPurposeDMASourceAddress+1]                                    ;; 00:0c8a $fa $c1 $da
    ldh  [rHDMA1], A                                   ;; 00:0c8d $e0 $51
    ld   A, [wDAC0_GeneralPurposeDMASourceAddress]                                    ;; 00:0c8f $fa $c0 $da
    ldh  [rHDMA2], A                                   ;; 00:0c92 $e0 $52
    ld   A, $80                                        ;; 00:0c94 $3e $80
    ldh  [rHDMA3], A                                   ;; 00:0c96 $e0 $53
    xor  A, A                                          ;; 00:0c98 $af
    ldh  [rHDMA4], A                                   ;; 00:0c99 $e0 $54
    ld   A, [wDAC2_DMATransferLength]                                    ;; 00:0c9b $fa $c2 $da
    add  A, A                                          ;; 00:0c9e $87
    sub  A, $01                                        ;; 00:0c9f $d6 $01
    ldh  [rHDMA5], A                                   ;; 00:0ca1 $e0 $55
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0ca3 $21 $66 $db
    res  0, [HL]                                       ;; 00:0ca6 $cb $86
    res  7, [HL]                                       ;; 00:0ca8 $cb $be
    ret                                                ;; 00:0caa $c9
.jr_00_0cab:
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 00:0cab $26 $d8
    ld   A, [wDB61_ActiveObjectSlot]                                    ;; 00:0cad $fa $61 $db
    or   A, OBJECT_SPRITE_BANK_OFFSET                                        ;; 00:0cb0 $f6 $17
    ld   L, A                                          ;; 00:0cb2 $6f
    ld   A, [HL]                                       ;; 00:0cb3 $7e
    call call_00_0f25_AltSwitchBank                                  ;; 00:0cb4 $cd $25 $0f
    ld   H, HIGH(wD800_ObjectMemory)                                        ;; 00:0cb7 $26 $d8
    ld   A, [wDB61_ActiveObjectSlot]                                    ;; 00:0cb9 $fa $61 $db
    or   A, OBJECT_MOVEMENT_FLAGS_OFFSET                                        ;; 00:0cbc $f6 $05
    ld   L, A                                          ;; 00:0cbe $6f
    bit  5, [HL]                                       ;; 00:0cbf $cb $6e
    jr   NZ, .jr_00_0ceb                               ;; 00:0cc1 $20 $28
    ld   A, [wDB64_VRAMTransferSource+1]                                    ;; 00:0cc3 $fa $65 $db
    ldh  [rHDMA1], A                                   ;; 00:0cc6 $e0 $51
    ld   A, [wDB64_VRAMTransferSource]                                    ;; 00:0cc8 $fa $64 $db
    ldh  [rHDMA2], A                                   ;; 00:0ccb $e0 $52
    ld   A, [wDB61_ActiveObjectSlot]                                    ;; 00:0ccd $fa $61 $db
    rlca                                               ;; 00:0cd0 $07
    rlca                                               ;; 00:0cd1 $07
    rlca                                               ;; 00:0cd2 $07
    and  A, $07                                        ;; 00:0cd3 $e6 $07
    add  A, $80                                        ;; 00:0cd5 $c6 $80
    ldh  [rHDMA3], A                                   ;; 00:0cd7 $e0 $53
    xor  A, A                                          ;; 00:0cd9 $af
    ldh  [rHDMA4], A                                   ;; 00:0cda $e0 $54
    ld   A, [wDB63_ActiveObjectType]                                    ;; 00:0cdc $fa $63 $db
    add  A, A                                          ;; 00:0cdf $87
    dec  A                                             ;; 00:0ce0 $3d
    ldh  [rHDMA5], A                                   ;; 00:0ce1 $e0 $55
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0ce3 $21 $66 $db
    res  1, [HL]                                       ;; 00:0ce6 $cb $8e
    res  7, [HL]                                       ;; 00:0ce8 $cb $be
    ret                                                ;; 00:0cea $c9
.jr_00_0ceb:
    ld   A, $01                                        ;; 00:0ceb $3e $01
    ldh  [rVBK], A                                     ;; 00:0ced $e0 $4f
    ld   A, [wDB64_VRAMTransferSource+1]                                    ;; 00:0cef $fa $65 $db
    ldh  [rHDMA1], A                                   ;; 00:0cf2 $e0 $51
    ld   A, [wDB64_VRAMTransferSource]                                    ;; 00:0cf4 $fa $64 $db
    ldh  [rHDMA2], A                                   ;; 00:0cf7 $e0 $52
    ld   A, $84                                        ;; 00:0cf9 $3e $84
    ldh  [rHDMA3], A                                   ;; 00:0cfb $e0 $53
    ld   A, $00                                        ;; 00:0cfd $3e $00
    ldh  [rHDMA4], A                                   ;; 00:0cff $e0 $54
    ld   A, [wDB63_ActiveObjectType]                                    ;; 00:0d01 $fa $63 $db
    add  A, A                                          ;; 00:0d04 $87
    dec  A                                             ;; 00:0d05 $3d
    ldh  [rHDMA5], A                                   ;; 00:0d06 $e0 $55
    ld   A, $00                                        ;; 00:0d08 $3e $00
    ldh  [rVBK], A                                     ;; 00:0d0a $e0 $4f
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0d0c $21 $66 $db
    res  1, [HL]                                       ;; 00:0d0f $cb $8e
    res  7, [HL]                                       ;; 00:0d11 $cb $be
    ret                                                ;; 00:0d13 $c9
.jp_00_0d14:
    ld   A, [wDC31_TilesetBankRelated]                                    ;; 00:0d14 $fa $31 $dc
    call call_00_0f25_AltSwitchBank                                  ;; 00:0d17 $cd $25 $0f
    ld   A, [wDC32_VRAMBank]                                    ;; 00:0d1a $fa $32 $dc
    ldh  [rVBK], A                                     ;; 00:0d1d $e0 $4f
    ld   A, [wDC2C_HDMATransferRelated2]                                    ;; 00:0d1f $fa $2c $dc
    ldh  [rHDMA1], A                                   ;; 00:0d22 $e0 $51
    ld   A, [wDC2B_HDMATransferRelated1]                                    ;; 00:0d24 $fa $2b $dc
    ldh  [rHDMA2], A                                   ;; 00:0d27 $e0 $52
    ld   A, [wDC2E_HDMATransferRelated4]                                    ;; 00:0d29 $fa $2e $dc
    ldh  [rHDMA3], A                                   ;; 00:0d2c $e0 $53
    ld   A, [wDC2D_HDMATransferRelated3]                                    ;; 00:0d2e $fa $2d $dc
    ldh  [rHDMA4], A                                   ;; 00:0d31 $e0 $54
    ld   HL, wDC2F_HDMATransferRelated5                                     ;; 00:0d33 $21 $2f $dc
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
    cp   A, $40                                        ;; 00:0d4e $fe $40
    jr   C, .jr_00_0d54                                ;; 00:0d50 $38 $02
.jr_00_0d52:
    ld   E, $40                                        ;; 00:0d52 $1e $40
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
    ld   HL, wDC2B_HDMATransferRelated1                                     ;; 00:0d65 $21 $2b $dc
    ld   A, [HL]                                       ;; 00:0d68 $7e
    add  A, E                                          ;; 00:0d69 $83
    ld   [HL+], A                                      ;; 00:0d6a $22
    ld   A, [HL]                                       ;; 00:0d6b $7e
    adc  A, D                                          ;; 00:0d6c $8a
    ld   [HL], A                                       ;; 00:0d6d $77
    ld   HL, wDC2D_HDMATransferRelated3                                     ;; 00:0d6e $21 $2d $dc
    ld   A, [HL]                                       ;; 00:0d71 $7e
    add  A, E                                          ;; 00:0d72 $83
    ld   [HL+], A                                      ;; 00:0d73 $22
    ld   A, [HL]                                       ;; 00:0d74 $7e
    adc  A, D                                          ;; 00:0d75 $8a
    ld   [HL], A                                       ;; 00:0d76 $77
    ld   HL, wDC2F_HDMATransferRelated5                                     ;; 00:0d77 $21 $2f $dc
    ld   A, [HL]                                       ;; 00:0d7a $7e
    sub  A, E                                          ;; 00:0d7b $93
    ld   [HL+], A                                      ;; 00:0d7c $22
    ld   C, A                                          ;; 00:0d7d $4f
    ld   A, [HL]                                       ;; 00:0d7e $7e
    sbc  A, D                                          ;; 00:0d7f $9a
    ld   [HL], A                                       ;; 00:0d80 $77
    or   A, C                                          ;; 00:0d81 $b1
    ret  NZ                                            ;; 00:0d82 $c0
    ld   HL, wDB66_HDMATransferFlags                                     ;; 00:0d83 $21 $66 $db
    res  2, [HL]                                       ;; 00:0d86 $cb $96
    res  7, [HL]                                       ;; 00:0d88 $cb $be
    ret                                                ;; 00:0d8a $c9

call_00_0d8b_Palette_UpdateBG:
; Writes a set of palette data into rBCPS/BCPD (BG palettes).
; Loads from .data_00_0dbe.
; Purpose: Loads color data into background palettes.
; Likely triggered by the LCD interrupt system (0c44).
    ld   hl,.data_00_0dbe
    ld   a,$80
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   a,$88
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   a,[wDAD8_LCDControlMirror]
    and  a,$FD
    or   a,$10
    ldh  [rLCDC],a
    ld   hl,wDB67_HDMATempScratch
    inc  [hl]
    pop  hl
    pop  af
    reti 
.data_00_0dbe
    db   $00, $00, $e0, $01, $00, $00, $e0, $01
    
call_00_0dc6_HBlankInterrupt_LoadPaletteSlice:
; Writes a hardcoded set of 8 bytes (.data_00_0df0) into the CGB background palettes 
; registers (rBCPS/rBCPD) — two full palette entries.
; Then increments a counter at wDB67_HDMATempScratch (used as a “scanline mark” in the frame loop).
; Pops registers and reti. Clearly an interrupt handler, specifically updating palettes.
    ld   hl,.data_00_0df0
    ld   a,$84
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   a,$8C
    ldh  [rBCPS],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ldi  a,[hl]
    ldh  [rBCPD],a
    ld   hl,wDB67_HDMATempScratch
    inc  [hl]
    pop  hl
    pop  af
    reti 
.data_00_0df0:
    db   $ff, $7f, $80, $03, $ff, $03, $ff, $7f, $d9                  ;; 00:0df3 ?????.

call_00_0df9_ProcessVRAMTransferQueue:
; First calls call_00_0c6a_HandlePendingHDMATransfers (HDMA/VRAM copy handler).
; Then checks a counter at wDBEF_UnkCounter. If nonzero, decrements it and uses wDBF0..wDBF7 
; as a state structure to fetch source/destination pointers and a bank.
; Sets up a copy loop through jp_00_0bcf_CopyBlock16BytesLoop, which transfers a block of data from 
; ROM (after bank switching) into RAM/VRAM.
    call call_00_0c6a_HandlePendingHDMATransfers                                  ;; 00:0df9 $cd $6a $0c
    jp   .jp_00_0dff                                   ;; 00:0dfc $c3 $ff $0d
.jp_00_0dff:
    ld   HL, wDBEF_UnkCounter                                     ;; 00:0dff $21 $ef $db
    ld   A, [HL]                                       ;; 00:0e02 $7e
    and  A, A                                          ;; 00:0e03 $a7
    ret  Z                                             ;; 00:0e04 $c8
    dec  [HL]                                          ;; 00:0e05 $35
    inc  HL                                            ;; 00:0e06 $23
    ld   B, [HL]                                       ;; 00:0e07 $46
    inc  HL                                            ;; 00:0e08 $23
    ld   A, [HL]                                       ;; 00:0e09 $7e
    call call_00_0f25_AltSwitchBank                                  ;; 00:0e0a $cd $25 $0f
    ld   HL, wDBF6                                     ;; 00:0e0d $21 $f6 $db
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
    ld   [wDBF6], A                                    ;; 00:0e1d $ea $f6 $db
    ld   A, H                                          ;; 00:0e20 $7c
    ld   [wDBF7], A                                    ;; 00:0e21 $ea $f7 $db
    pop  HL                                            ;; 00:0e24 $e1
    jp   jp_00_0bcf_CopyBlock16BytesLoop                                    ;; 00:0e25 $c3 $cf $0b

call_00_0e28_Return:
; Empty routine—just returns.
    ret

call_00_0e29_StartDMATransfer:
; Initiates a sprite/OAM DMA transfer: writes $D9 to rDMA, 
; delays $28 cycles, then returns.
    ld   a,$D9
    ldh  [rDMA], a
    ld   a,$28
.jr_00_0E2F:
    dec  a
    jr   nz,.jr_00_0E2F
    ret                             ;; 00:0e30 ...

call_00_0e33_SetLCDControlRegister:
; Purpose: Writes a value to both a RAM mirror (wDAD8_LCDControlMirror) and the LCDC hardware register (rLCDC), 
; which controls screen enable, sprite settings, background, etc.
; Then: Waits for an interrupt.
; Use Case: Likely used when enabling/disabling the screen or adjusting rendering 
; settings before/after screen updates.
    ld   [wDAD8_LCDControlMirror], A                                    ;; 00:0e33 $ea $d8 $da
    ldh  [rLCDC], A                                    ;; 00:0e36 $e0 $40
    jp   call_00_0b92_WaitForInterrupt                                  ;; 00:0e38 $c3 $92 $0b

call_00_0e3b_ClearGameStateVariables:
; Purpose: Clears/reset various RAM variables related to the game state and objects.
; Then: Calls a function in bank 02 to clear object slots.
; Then: Waits for interrupt.
; Use Case: Prepares the game for a fresh state, probably at start of a level or menu.
    xor  A, A                                          ;; 00:0e3b $af
    ld   [wDC7E_PlayerDamageCooldownTimer], A                                    ;; 00:0e3c $ea $7e $dc
    ld   [wDC20], A                                    ;; 00:0e3f $ea $20 $dc
    ld   [wDB66_HDMATransferFlags], A                                    ;; 00:0e42 $ea $66 $db
    ld   [wDB69], A                                    ;; 00:0e45 $ea $69 $db
    ld   [wDBEF_UnkCounter], A                                    ;; 00:0e48 $ea $ef $db
    ld   [wDC72_FrameCounter2], A                                    ;; 00:0e4b $ea $72 $dc
    ld   [wDBE3], A                                    ;; 00:0e4e $ea $e3 $db
    ld   [wDD6B], A                                    ;; 00:0e51 $ea $6b $dd
    farcall call_02_7123_ClearObjectSlotsExcludingPlayer
    jp   call_00_0b92_WaitForInterrupt                                  ;; 00:0e5f $c3 $92 $0b

call_00_0e62_ResetFlagsAndVRAMState:
; Purpose: Resets some RAM variables (wDD6A_GameBoyColorPaletteFlag, wDAD9_ScrollX, wDADA_ScrollY) and clears a chunk of RAM (wD900 to wD99F).
; Then: Waits for interrupts at key points.
; Use Case: VRAM/object state reset before loading new assets or scenes.
    xor  A, A                                          ;; 00:0e62 $af
    ld   [wDD6A_GameBoyColorPaletteFlag], A                                    ;; 00:0e63 $ea $6a $dd
    call call_00_0b92_WaitForInterrupt                                  ;; 00:0e66 $cd $92 $0b
    xor  A, A                                          ;; 00:0e69 $af
    ld   [wDAD9_ScrollX], A                                    ;; 00:0e6a $ea $d9 $da
    ld   [wDADA_ScrollY], A                                    ;; 00:0e6d $ea $da $da
    ld   HL, wD900                                     ;; 00:0e70 $21 $00 $d9
    ld   DE, wD901                                     ;; 00:0e73 $11 $01 $d9
    ld   BC, $9f                                       ;; 00:0e76 $01 $9f $00
    ld   [HL], $00                                     ;; 00:0e79 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 00:0e7b $cd $6e $07
    jp   call_00_0b92_WaitForInterrupt                                  ;; 00:0e7e $c3 $92 $0b

call_00_0e81_LoadPalettesToHardware:
; If wDD6A_GameBoyColorPaletteFlag=0, fills BG/OBJ palettes with default gray values. 
; Otherwise, copies palette data from wDCEA_BgPalettes into hardware registers rBCPD/rOCPD.
    ld   A, [wDD6A_GameBoyColorPaletteFlag]                                    ;; 00:0e81 $fa $6a $dd
    and  A, A                                          ;; 00:0e84 $a7
    jr   NZ, .jr_00_0e97                               ;; 00:0e85 $20 $10
    ld   A, $80                                        ;; 00:0e87 $3e $80
    ldh  [rBCPS], A                                    ;; 00:0e89 $e0 $68
    ldh  [rOCPS], A                                    ;; 00:0e8b $e0 $6a
    ld   B, $40                                        ;; 00:0e8d $06 $40
.jr_00_0e8f:
    ldh  [rBCPD], A                                    ;; 00:0e8f $e0 $69
    ldh  [rOCPD], A                                    ;; 00:0e91 $e0 $6b
    dec  B                                             ;; 00:0e93 $05
    jr   NZ, .jr_00_0e8f                               ;; 00:0e94 $20 $f9
    ret                                                ;; 00:0e96 $c9
.jr_00_0e97:
    ld   HL, wDCEA_BgPalettes                                     ;; 00:0e97 $21 $ea $dc
    ld   A, $80                                        ;; 00:0e9a $3e $80
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
    ld   A, $80                                        ;; 00:0ebb $3e $80
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
; Switches to a new ROM bank (call_00_0eee_SwitchBank), 
; calls the function at HL in that bank, then restores 
; the previous bank (call_00_0f08_RestoreBank).
    push HL                                            ;; 00:0edd $e5
    call call_00_0eee_SwitchBank                                  ;; 00:0ede $cd $ee $0e
    pop  HL                                            ;; 00:0ee1 $e1
    ld   A, [wDAD6_ReturnBank]                                    ;; 00:0ee2 $fa $d6 $da
    call call_00_0f22_JumpHL                                  ;; 00:0ee5 $cd $22 $0f
    push AF                                            ;; 00:0ee8 $f5
    call call_00_0f08_RestoreBank                                  ;; 00:0ee9 $cd $08 $0f
    pop  AF                                            ;; 00:0eec $f1
    ret                                                ;; 00:0eed $c9

call_00_0eee_SwitchBank:
; Core bank-switch: stores new bank in wDAD5_CurrentROMBank and MBC1RomBank, 
; updates bookkeeping pointers (wDAD3_PtrToBankStackPosition), sets SRAM bank.
    ld   HL, wDAD3_PtrToBankStackPosition                                     ;; 00:0eee $21 $d3 $da
    ld   E, [HL]                                       ;; 00:0ef1 $5e
    inc  HL                                            ;; 00:0ef2 $23
    ld   D, [HL]                                       ;; 00:0ef3 $56
    inc  DE                                            ;; 00:0ef4 $13
    ld   [DE], A                                       ;; 00:0ef5 $12
    ld   [HL], D                                       ;; 00:0ef6 $72
    dec  HL                                            ;; 00:0ef7 $2b
    ld   [HL], E                                       ;; 00:0ef8 $73
    ld   [wDAD5_CurrentROMBank], A                                    ;; 00:0ef9 $ea $d5 $da
    ld   [MBC1RomBank], A                                    ;; 00:0efc $ea $01 $20
    swap A                                             ;; 00:0eff $cb $37
    rrca                                               ;; 00:0f01 $0f
    and  A, $00                                        ;; 00:0f02 $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:0f04 $ea $01 $40
    ret                                                ;; 00:0f07 $c9

call_00_0f08_RestoreBank:
; Restores the previously saved ROM bank by reading from 
; wDAD3_PtrToBankStackPosition bookkeeping pointers and writing to MBC1RomBank.
    ld   HL, wDAD3_PtrToBankStackPosition                                     ;; 00:0f08 $21 $d3 $da
    ld   E, [HL]                                       ;; 00:0f0b $5e
    inc  HL                                            ;; 00:0f0c $23
    ld   D, [HL]                                       ;; 00:0f0d $56
    dec  DE                                            ;; 00:0f0e $1b
    ld   A, [DE]                                       ;; 00:0f0f $1a
    ld   [HL], D                                       ;; 00:0f10 $72
    dec  HL                                            ;; 00:0f11 $2b
    ld   [HL], E                                       ;; 00:0f12 $73
    ld   [wDAD5_CurrentROMBank], A                                    ;; 00:0f13 $ea $d5 $da
    ld   [MBC1RomBank], A                                    ;; 00:0f16 $ea $01 $20
    swap A                                             ;; 00:0f19 $cb $37
    rrca                                               ;; 00:0f1b $0f
    and  A, $00                                        ;; 00:0f1c $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:0f1e $ea $01 $40
    ret                                                ;; 00:0f21 $c9

call_00_0f22_JumpHL:
; Jumps to the address in HL (tail-call helper).
    jp   HL                                            ;; 00:0f22 $e9

    ld   a, $03                                      ;; 00:0f23 ??
call_00_0f25_AltSwitchBank:
; Lightweight bank switch: writes A directly to MBC1RomBank 
; and SRAM bank. Used for quick bank changes.
    ld   [MBC1RomBank], A                                    ;; 00:0f25 $ea $01 $20
    swap A                                             ;; 00:0f28 $cb $37
    rrca                                               ;; 00:0f2a $0f
    and  A, $00                                        ;; 00:0f2b $e6 $00
    ld   [MBC1SRamBank], A                                    ;; 00:0f2d $ea $01 $40
    ret                                                ;; 00:0f30 $c9

call_00_0f31_ReadJoypadInput:
; Performs joypad polling using hardware port $20: latches directions/buttons, 
; masks and merges results, stores in wDAD7_CurrentInputs.
    ld   C, $00                                        ;; 00:0f31 $0e $00
    ld   A, $20                                        ;; 00:0f33 $3e $20
    ldh  [C], A                                        ;; 00:0f35 $e2
    ldh  A, [C]                                        ;; 00:0f36 $f2
    ldh  A, [C]                                        ;; 00:0f37 $f2
    ldh  A, [C]                                        ;; 00:0f38 $f2
    ld   B, A                                          ;; 00:0f39 $47
    ld   A, $10                                        ;; 00:0f3a $3e $10
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
    ld   A, $30                                        ;; 00:0f56 $3e $30
    ldh  [C], A                                        ;; 00:0f58 $e2
    ld   A, B                                          ;; 00:0f59 $78
    ld   [wDAD7_CurrentInputs], A                                    ;; 00:0f5a $ea $d7 $da
    ret                                                ;; 00:0f5d $c9

call_00_0f5e_WaitUntilNoInputPressed:
; Purpose: Waits until all buttons are released (wDAD7_CurrentInputs == 0).
; Use Case: Used after menus or cutscenes to avoid unintended input carryover.
    call call_00_0b92_WaitForInterrupt                                  ;; 00:0f5e $cd $92 $0b
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f61 $fa $d7 $da
    and  A, A                                          ;; 00:0f64 $a7
    jr   NZ, call_00_0f5e_WaitUntilNoInputPressed                              ;; 00:0f65 $20 $f7
    ret                                                ;; 00:0f67 $c9

call_00_0f68_CheckInputLeft:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f68 $fa $d7 $da
    and  A, PADF_LEFT                                        ;; 00:0f6b $e6 $20
    ret                                                ;; 00:0f6d $c9

call_00_0f6e_CheckInputRight:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f6e $fa $d7 $da
    and  A, PADF_RIGHT                                        ;; 00:0f71 $e6 $10
    ret                                                ;; 00:0f73 $c9

call_00_0f74_CheckInputUp:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f74 $fa $d7 $da
    and  A, PADF_UP                                        ;; 00:0f77 $e6 $40
    ret                                                ;; 00:0f79 $c9

call_00_0f7a_CheckInputDown:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f7a $fa $d7 $da
    and  A, PADF_DOWN                                        ;; 00:0f7d $e6 $80
    ret                                                ;; 00:0f7f $c9

call_00_0f80_CheckInputStart:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f80 $fa $d7 $da
    cp   A, PADF_START                                        ;; 00:0f83 $fe $08
    jr   Z, .jr_00_0f89                                ;; 00:0f85 $28 $02
    xor  A, A                                          ;; 00:0f87 $af
    ret                                                ;; 00:0f88 $c9
.jr_00_0f89:
    and  A, A                                          ;; 00:0f89 $a7
    ret                                                ;; 00:0f8a $c9

call_00_0f8b_CheckInputSelect:
; Purpose: Tests if the current input state (wDAD7_CurrentInputs) equals $04. 
; If so, returns A unchanged; otherwise clears A.
; Usage: Likely a quick check for a specific button press (e.g., “Right” or a single button).
; Behavior:
; A == $04 → returns immediately.
; Otherwise sets A=0 and returns.
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f8b $fa $d7 $da
    cp   A, PADF_SELECT                                        ;; 00:0f8e $fe $04
    jr   Z, .jr_00_0f94                                ;; 00:0f90 $28 $02
    xor  A, A                                          ;; 00:0f92 $af
    ret                                                ;; 00:0f93 $c9
.jr_00_0f94:
    and  A, A                                          ;; 00:0f94 $a7
    ret                                                ;; 00:0f95 $c9

call_00_0f96_CheckInputA:
    ld   a, [wDAD7_CurrentInputs]
    and  a, PADF_A
    ret  

call_00_0f9c_CheckInputB:
    ld   A, [wDAD7_CurrentInputs]                                    ;; 00:0f9c $fa $d7 $da
    and  A, PADF_B                                        ;; 00:0f9f $e6 $02
    ret                                                ;; 00:0fa1 $c9

call_00_0fa2_PlaySong:
; Accepts a song ID in A.
; If SONG_NONE (no song) or equal to the current song (wDE5C_CurrentSong), it does nothing.
; Otherwise, it stores the new code in wDE5C_CurrentSong.
; Waits for an interrupt (call_00_0b92_WaitForInterrupt)—this syncs playback changes to a safe frame.
; Derives wDE60_AudioBankCurrent as (wDE5C_CurrentSong >> 4) & $0F (bank group) and uses it +4 to switch to the appropriate ROM bank.
; Then isolates the lower nibble and calls call_04_4006_Audio in bank 04 to start the track.
; Finally restores the original bank (call_00_0f08_RestoreBank).
; Summary: Changes music track safely by switching banks and calling the main audio engine.
    cp   A, SONG_NONE                                        ;; 00:0fa2 $fe $ff
    ret  Z                                             ;; 00:0fa4 $c8
    ld   HL, wDE5C_CurrentSong                                     ;; 00:0fa5 $21 $5c $de
    cp   A, [HL]                                       ;; 00:0fa8 $be
    ret  Z                                             ;; 00:0fa9 $c8
    ld   [HL], A                                       ;; 00:0faa $77
    call call_00_0b92_WaitForInterrupt                                  ;; 00:0fab $cd $92 $0b
    ld   A, [wDE5C_CurrentSong]                                    ;; 00:0fae $fa $5c $de
    swap A                                             ;; 00:0fb1 $cb $37
    and  A, $0f                                        ;; 00:0fb3 $e6 $0f
    ld   [wDE60_AudioBankCurrent], A                                    ;; 00:0fb5 $ea $60 $de
    add  A, BANK_04_AUDIO_CODE_1                                        ;; 00:0fb8 $c6 $04
    call call_00_0eee_SwitchBank                                  ;; 00:0fba $cd $ee $0e
    ld   A, [wDE5C_CurrentSong]                                    ;; 00:0fbd $fa $5c $de
    and  A, $0f                                        ;; 00:0fc0 $e6 $0f
    call call_04_4006_Audio                                  ;; 00:0fc2 $cd $06 $40
    jp   call_00_0f08_RestoreBank                                  ;; 00:0fc5 $c3 $08 $0f

call_00_0fc8_ProcessQueuedSoundEffect:
; Loads the queued effect ID from wDE5D_QueuedSoundEffect and clears that slot to SFX_NONE.
; If it was SFX_NONE (none queued), clears wDE5E_QueuedSoundEffectPriority (priority) and exits.
; Otherwise branches to call_00_0fd7_TriggerSoundEffect.
    ld   HL, wDE5D_QueuedSoundEffect                                     ;; 00:0fc8 $21 $5d $de
    ld   A, [HL]                                       ;; 00:0fcb $7e
    ld   [HL], SFX_NONE                                     ;; 00:0fcc $36 $ff
    cp   A, SFX_NONE                                        ;; 00:0fce $fe $ff
    jr   NZ, call_00_0fd7_TriggerSoundEffect                              ;; 00:0fd0 $20 $05
    xor  A, A                                          ;; 00:0fd2 $af
    ld   [wDE5E_QueuedSoundEffectPriority], A                                    ;; 00:0fd3 $ea $5e $de
    ret                                                ;; 00:0fd6 $c9

call_00_0fd7_TriggerSoundEffect:
; Re-validates ID (not SFX_NONE).
; Bank-switches to 04, calls call_04_4024_Audio twice:
; First with A=$00 (resets/flushes channels?),
; Then with A=effect ID (plays the new effect).
; Moves wDE5E_QueuedSoundEffectPriority (effect priority) into wDE5F_CurrentSoundEffectPriority after zeroing wDE5E_QueuedSoundEffectPriority.
; Restores bank and exits.
; Summary: Handles actually starting a queued sound effect in the audio engine.
    cp   A, SFX_NONE                                        ;; 00:0fd7 $fe $ff
    ret  Z                                             ;; 00:0fd9 $c8
    push AF                                            ;; 00:0fda $f5
    ld   A, BANK_04_AUDIO_CODE_1                                        ;; 00:0fdb $3e $04
    call call_00_0eee_SwitchBank                                  ;; 00:0fdd $cd $ee $0e
    ld   A, $00                                        ;; 00:0fe0 $3e $00
    call call_04_4024_Audio                                  ;; 00:0fe2 $cd $24 $40
    pop  AF                                            ;; 00:0fe5 $f1
    call call_04_4024_Audio                                  ;; 00:0fe6 $cd $24 $40
    ld   HL, wDE5E_QueuedSoundEffectPriority                                     ;; 00:0fe9 $21 $5e $de
    ld   A, [HL]                                       ;; 00:0fec $7e
    ld   [HL], $00                                     ;; 00:0fed $36 $00
    ld   [wDE5F_CurrentSoundEffectPriority], A                                    ;; 00:0fef $ea $5f $de
    jp   call_00_0f08_RestoreBank                                  ;; 00:0ff2 $c3 $08 $0f

call_00_0ff5_QueueSoundEffect:
; Accepts a sound effect code in A. If $FF, returns.
; Uses .data_00_1037_SFXPriorities as a priority lookup table: B = priorityTable[A].
; Checks multiple channel-status bytes (wDF68–wDF72) to see if the sound hardware is busy.
; If any channel active, compares B against wDE5F_CurrentSoundEffectPriority (currently playing effect priority) 
; and returns early if the new effect is lower priority.
; If no channels active or priority is higher/equal, also compares against
; wDE5E_QueuedSoundEffectPriority (last queued priority) when a sound is already queued.
; If it passes priority checks, stores the effect code in wDE5D_QueuedSoundEffect and its priority in wDE5E_QueuedSoundEffectPriority.
; Summary: Decides whether a new effect should replace the current/queued effect based on priority.
    cp   A, SFX_NONE                                        ;; 00:0ff5 $fe $ff
    ret  Z                                             ;; 00:0ff7 $c8
    ld   C, A                                          ;; 00:0ff8 $4f
    ld   B, $00                                        ;; 00:0ff9 $06 $00
    ld   HL, .data_00_1037_SFXPriorities                                     ;; 00:0ffb $21 $37 $10
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
    ld   HL, wDE5F_CurrentSoundEffectPriority                                     ;; 00:101c $21 $5f $de
    cp   A, [HL]                                       ;; 00:101f $be
    ret  C                                             ;; 00:1020 $d8
.jr_00_1021:
    ld   A, [wDE5D_QueuedSoundEffect]                                    ;; 00:1021 $fa $5d $de
    cp   A, $ff                                        ;; 00:1024 $fe $ff
    jr   Z, .jr_00_102e                                ;; 00:1026 $28 $06
    ld   A, B                                          ;; 00:1028 $78
    ld   HL, wDE5E_QueuedSoundEffectPriority                                     ;; 00:1029 $21 $5e $de
    cp   A, [HL]                                       ;; 00:102c $be
    ret  C                                             ;; 00:102d $d8
.jr_00_102e:
    ld   HL, wDE5D_QueuedSoundEffect                                     ;; 00:102e $21 $5d $de
    ld   [HL], C                                       ;; 00:1031 $71
    ld   HL, wDE5E_QueuedSoundEffectPriority                                     ;; 00:1032 $21 $5e $de
    ld   [HL], B                                       ;; 00:1035 $70
    ret                                                ;; 00:1036 $c9
.data_00_1037_SFXPriorities:
    db   $11, $01, $08, $08, $01, $01, $01, $01        ;; 00:1037 ??.?.?..
    db   $01, $01, $01, $01, $01, $10, $10, $07        ;; 00:103f .?.??..?
    db   $07, $01, $01, $01, $08, $08, $01, $08        ;; 00:1047 .???????
    db   $08, $0e, $0f, $08, $08, $10, $10             ;; 00:104f ?.???..
