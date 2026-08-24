; ==================================================================
; Bank 0. Everything that runs once when a level starts, between the map data being
; located and the first frame being drawn.
;
; call_00_0314_LoadNewMap calls two of these back to back, and the death-respawn
; path calls the same pair again:
;
;   call_00_2f85_CollectibleList_LoadForCurrentLevel   builds the collectible tables
;   call_00_2ff8_Level_InitEntitiesAndState            everything else
;
; The second one is the interesting one. It marks every entry in the level's entity
; list as present, clears the sixteen collectible-and-boss counters, copies two small
; configuration tables into RAM, and then calls the three routines below it, which
; walk the entity list again to UNDO some of that marking - the bonus coin and the
; paw coins the player has already taken must not come back.
;
; So the shape of level setup is: mark everything, then unmark what the save file
; says is gone. The persistent state lives in wDC5C_ProgressFlags, one byte per
; level, and the per-list state it writes lives in wD700_EntityFlags.
;
; call_00_2f34_CountLevelCollectibleTotal sits here too but is not part of setup - it
; is a menu query, reached through a dispatch table in bank 1.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank0A/bank0B
; ------------------------------------------------------------------
; gex2 has no file that corresponds to this one, because gex2 has much less to set
; up. The pieces are scattered:
;
;   the collectibles  gex2's call_0b_4000_CollectibleList_LoadForCurrentLevel is the
;                     same three-pass build as the routine here, and even uses the
;                     same $0B-cell column window. The difference is a third byte:
;                     gex3's records carry a map id, because a gex3 level is many
;                     maps and a collectible belongs to one of them
;   the entity list   gex2's call_0a_4000_EntityList_LoadForCurrentLevel just points
;                     a cursor at the level's list. It has nothing to mark, because
;                     gex2 treats an absent flag as "may spawn" and only ever writes
;                     the flag to stop something respawning. gex3 marks every entry
;                     PRESENT up front and clears entries instead
;   the progress      gex2's equivalent of the TV-button work is
;                     call_00_3899_Entity_CheckRemoteTotalsUnlock, which asks the
;                     question every frame from the entity's own action rather than
;                     answering it once at level start
; ==================================================================

call_00_2f34_CountLevelCollectibleTotal:
; Returns in A how many collectibles this level contains in total - the number the
; HUD counts up to. Not part of level setup: bank 1's menu dispatch table calls it
; when it needs the denominator.
;
; Two passes, and the answer is the sum. First the collectible list itself, walked
; COLLECTIBLE_RECORD_SIZE bytes at a time until a zero byte, counting entries. Then
; the entity list, and for each entry the type's ENTITY_ATTR_DEFEAT_FLAGS byte out of
; data_00_325f_EntityAttributeTable_FlagsBase: an entity counts if that byte is not
; $FF and has ENTITY_DEFEAT_FLAG_DROPS_COLLECTIBLE_BIT set.
;
; So "collectibles in this level" means the coins lying around PLUS the enemies that
; drop one when defeated, and the two `cp a,$FF` below are different questions - the
; first is the entity list's terminator, the second is a type that drops nothing.
;
; Note the counter starts at $FF and is incremented before each test, which is how a
; loop that always overshoots by one lands on the right total
    ld   a,[wDC19_CollectibleListBank]
    call call_00_0eee_SwitchBank
    ld   hl,wDC1A_CollectibleListBankOffset
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    inc  hl
    ld   de,COLLECTIBLE_RECORD_SIZE
    ld   c,$FF
.jr_00_2F46:
    ld   a,[hl]
    add  hl,de
    inc  c
    and  a
    jr   nz,.jr_00_2F46
    push bc
    call call_00_0f08_RestoreBank
    ld   a,[wDC16_EntityListBank]
    call call_00_0eee_SwitchBank
    ld   hl,wDC17_EntityListBankOffset
    ldi  a,[hl]
    ld   h,[hl]
    ld   l,a
    pop  bc
.jr_00_2F5D:
    ld   a,[hl]
    cp   a,$FF
    jr   z,.jr_00_2F7E
    push hl
    ld   l,a
    ld   h,$00
    add  hl,hl
    add  hl,hl
    add  hl,hl
    ld   de,data_00_325f_EntityAttributeTable_FlagsBase
    add  hl,de
    ld   a,[hl]
    cp   a,$FF
    jr   z,.jr_00_2F77
    bit  ENTITY_DEFEAT_FLAG_DROPS_COLLECTIBLE_BIT,a
    jr   z,.jr_00_2F77
    inc  c
.jr_00_2F77:
    pop  hl
    ld   de,ENTITY_SPAWN_RECORD_SIZE
    add  hl,de
    jr   .jr_00_2F5D
.jr_00_2F7E:
    ld   a,c
    push af
    call call_00_0f08_RestoreBank
    pop  af
    ret  

call_00_2f85_CollectibleList_LoadForCurrentLevel:
; Builds the four collectible tables for the current level. Three passes, and the
; last two exist purely so that the per-frame draw never has to walk the list.
;
; 1. Clear. wD100_Collectible_GridX to COLLECTIBLE_LIST_END so an empty list is the
;    default, wD180_Collectible_GridY and both index tables to zero. Note the trick:
;    one loop over L with `bit 7, L` choosing the fill value, because the X and Y
;    tables are the two halves of one page.
;
; 2. Load. The level's list is COLLECTIBLE_RECORD_SIZE bytes per entry - grid X, grid
;    Y, map id - and is de-interleaved into wD100_Collectible_GridX,
;    wD180_Collectible_GridY and wD080_Collectible_MapIds. It ends at the first entry
;    whose Y is zero. The lists are authored sorted by ascending X, which is what
;    makes pass 3 valid.
;
; 3. Index. Two lookups keyed by camera cell column, so that drawing is two array
;    reads instead of a scan. For every column 0-255:
;      wD200_Collectible_ScanStartByColumn   walk the X table until an entry reaches
;        this column, and store that index - a lower bound
;      wD300_Collectible_ScanCountByColumn   from there, count entries whose X is
;        below column + COLLECTIBLE_COLUMNS_ON_SCREEN, stopping at the terminator
;
; The cost is 256 list walks at level load in exchange for a constant-time lookup in
; call_03_615d_Collectible_BuildSprites every frame. gex2's
; call_0b_4000_CollectibleList_LoadForCurrentLevel is the same three passes; the map
; id is the byte gex3 adds
    xor  A, A                                         ;; 00:2f85 $af
    ld   [wDC68_CollectibleAmount], A                 ;; 00:2f86 $ea $68 $dc
    ld   A, [wDC19_CollectibleListBank]               ;; 00:2f89 $fa $19 $dc
    call call_00_0eee_SwitchBank                      ;; 00:2f8c $cd $ee $0e
    ld   L, LOW(wD100_Collectible_GridX)              ;; 00:2f8f $2e $00
.jr_00_2f91:
    ld   H, HIGH(wD100_Collectible_GridX)             ;; 00:2f91 $26 $d1
    ld   A, COLLECTIBLE_LIST_END                      ;; 00:2f93 $3e $ff
    bit  7, L                                         ;; 00:2f95 $cb $7d
    jr   Z, .jr_00_2f9a                               ;; 00:2f97 $28 $01
    xor  A, A                                         ;; 00:2f99 $af
.jr_00_2f9a:
    ld   [HL], A                                      ;; 00:2f9a $77
    inc  H                                            ;; 00:2f9b $24
    ld   [HL], $00                                    ;; 00:2f9c $36 $00
    dec  H                                            ;; 00:2f9e $25
    inc  L                                            ;; 00:2f9f $2c
    jr   NZ, .jr_00_2f91                              ;; 00:2fa0 $20 $ef
    ld   HL, wDC1A_CollectibleListBankOffset          ;; 00:2fa2 $21 $1a $dc
    ld   A, [HL+]                                     ;; 00:2fa5 $2a
    ld   H, [HL]                                      ;; 00:2fa6 $66
    ld   L, A                                         ;; 00:2fa7 $6f
    ld   E, LOW(wD100_Collectible_GridX)              ;; 00:2fa8 $1e $00
.jr_00_2faa:
    ld   D, HIGH(wD100_Collectible_GridX)             ;; 00:2faa $16 $d1
    ld   A, [HL+]                                     ;; 00:2fac $2a
    ld   [DE], A                                      ;; 00:2fad $12
    set  7, E                                         ;; 00:2fae $cb $fb
    ld   A, [HL+]                                     ;; 00:2fb0 $2a
    ld   [DE], A                                      ;; 00:2fb1 $12
    push AF                                           ;; 00:2fb2 $f5
    ld   D, HIGH(wD000_CollectibleUnusedMemory)       ;; 00:2fb3 $16 $d0
    ld   A, [HL+]                                     ;; 00:2fb5 $2a
    ld   [DE], A                                      ;; 00:2fb6 $12
    pop  AF                                           ;; 00:2fb7 $f1
    res  7, E                                         ;; 00:2fb8 $cb $bb
    inc  E                                            ;; 00:2fba $1c
    and  A, A                                         ;; 00:2fbb $a7
    jr   NZ, .jr_00_2faa                              ;; 00:2fbc $20 $ec
    ld   DE, wD200_Collectible_ScanStartByColumn      ;; 00:2fbe $11 $00 $d2
.jr_00_2fc1:
    ld   HL, wD100_Collectible_GridX                  ;; 00:2fc1 $21 $00 $d1
.jr_00_2fc4:
    ld   A, [HL+]                                     ;; 00:2fc4 $2a
    cp   A, COLLECTIBLE_LIST_END                      ;; 00:2fc5 $fe $ff
    jr   Z, .jr_00_2fcc                               ;; 00:2fc7 $28 $03
    cp   A, E                                         ;; 00:2fc9 $bb
    jr   C, .jr_00_2fc4                               ;; 00:2fca $38 $f8
.jr_00_2fcc:
    ld   A, L                                         ;; 00:2fcc $7d
    dec  A                                            ;; 00:2fcd $3d
    ld   [DE], A                                      ;; 00:2fce $12
    inc  E                                            ;; 00:2fcf $1c
    jr   NZ, .jr_00_2fc1                              ;; 00:2fd0 $20 $ef
    ld   E, LOW(wD200_Collectible_ScanStartByColumn)  ;; 00:2fd2 $1e $00
.jr_00_2fd4:
    ld   D, HIGH(wD200_Collectible_ScanStartByColumn) ;; 00:2fd4 $16 $d2
    ld   A, [DE]                                      ;; 00:2fd6 $1a
    ld   L, A                                         ;; 00:2fd7 $6f
    ld   H, HIGH(wD100_Collectible_GridX)             ;; 00:2fd8 $26 $d1
    ld   B, $00                                       ;; 00:2fda $06 $00
    ld   C, $ff                                       ;; 00:2fdc $0e $ff
    ld   A, E                                         ;; 00:2fde $7b
    add  A, COLLECTIBLE_COLUMNS_ON_SCREEN             ;; 00:2fdf $c6 $0b
    jr   C, .jr_00_2fe4                               ;; 00:2fe1 $38 $01
    ld   C, A                                         ;; 00:2fe3 $4f
.jr_00_2fe4:
    inc  B                                            ;; 00:2fe4 $04
    ld   A, [HL+]                                     ;; 00:2fe5 $2a
    cp   A, COLLECTIBLE_LIST_END                      ;; 00:2fe6 $fe $ff
    jr   Z, .jr_00_2fed                               ;; 00:2fe8 $28 $03
    cp   A, C                                         ;; 00:2fea $b9
    jr   C, .jr_00_2fe4                               ;; 00:2feb $38 $f7
.jr_00_2fed:
    ld   D, HIGH(wD300_Collectible_ScanCountByColumn) ;; 00:2fed $16 $d3
    ld   A, B                                         ;; 00:2fef $78
    dec  A                                            ;; 00:2ff0 $3d
    ld   [DE], A                                      ;; 00:2ff1 $12
    inc  E                                            ;; 00:2ff2 $1c
    jr   NZ, .jr_00_2fd4                              ;; 00:2ff3 $20 $df
    jp   call_00_0f08_RestoreBank                     ;; 00:2ff5 $c3 $08 $0f

call_00_2ff8_Level_InitEntitiesAndState:
; Sets up everything the level needs that is not the map itself, and is called both
; on entering a level and on respawning after a death.
;
; In order:
;
;   mark      every entry in the level's entity list gets ENTITY_LIST_FLAG_PRESENT
;             in wD700_EntityFlags, walking until ENTITY_LIST_END. This is the pass
;             that makes wDAB8_EntityCounter meaningful as a list index
;   clear     the sixteen counters and flags from wDCC3_IceSculptureCounter to
;             wDCDA_BrainOfOzAndRezCounter - the per-level collectible tallies and
;             boss progress
;   copy      LEVEL_TRIGGER_COUNT bytes of this level's row from
;             .data_00_30ba_LevelTriggerInitialData into wDCB1_LevelTriggerBuffer,
;             and six bytes of elevator state into wDCE2_ElevatorEntityUnkData
;   defaults  ELF_HEALTH_MAX into the five skating elves
;   bonus     LEVEL_GEXTREME_SPORTS and LEVEL_MARSUPIAL_MADNESS set wDB6D_InBonusStage
;             and start the countdown - BONUS_STAGE_SECONDS_GEXTREME or
;             BONUS_STAGE_SECONDS_MARSUPIAL, with FRAMES_PER_SECOND in the tick
;   undo      the three routines below, which clear the entries the save file says
;             are already gone, and then a final cursor rewind
;
; The trigger table is almost entirely zero: only the anime channel row has anything
; in it. It is a full LEVEL_TRIGGER_COUNT-byte row per level anyway, so a level that
; wants a trigger pre-set has somewhere to say so
    ld   A, [wDC16_EntityListBank]                    ;; 00:2ff8 $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:2ffb $cd $ee $0e
    call call_00_3252_EntityList_RewindCursor         ;; 00:2ffe $cd $52 $32
    ld   HL, wDC17_EntityListBankOffset               ;; 00:3001 $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:3004 $2a
    ld   H, [HL]                                      ;; 00:3005 $66
    ld   L, A                                         ;; 00:3006 $6f
    ld   A, [HL]                                      ;; 00:3007 $7e
    cp   A, ENTITY_LIST_END                           ;; 00:3008 $fe $ff
    jr   Z, .jr_00_3021                               ;; 00:300a $28 $15
.jr_00_300c:
    push HL                                           ;; 00:300c $e5
    ld   HL, wDAB8_EntityCounter                      ;; 00:300d $21 $b8 $da
    ld   A, [HL]                                      ;; 00:3010 $7e
    inc  [HL]                                         ;; 00:3011 $34
    ld   L, A                                         ;; 00:3012 $6f
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:3013 $26 $d7
    ld   [HL], ENTITY_LIST_FLAG_PRESENT               ;; 00:3015 $36 $80
    pop  HL                                           ;; 00:3017 $e1
    ld   DE, ENTITY_SPAWN_RECORD_SIZE                 ;; 00:3018 $11 $10 $00
    add  HL, DE                                       ;; 00:301b $19
    ld   A, [HL]                                      ;; 00:301c $7e
    cp   A, ENTITY_LIST_END                           ;; 00:301d $fe $ff
    jr   NZ, .jr_00_300c                              ;; 00:301f $20 $eb
.jr_00_3021:
    xor  A, A                                         ;; 00:3021 $af
    ld   [wDCC5_BloodCoolerCounter], A                ;; 00:3022 $ea $c5 $dc
    ld   [wDCC3_IceSculptureCounter], A               ;; 00:3025 $ea $c3 $dc
    ld   [wDCC6_LostArkCounter], A                    ;; 00:3028 $ea $c6 $dc
    ld   [wDCC7_RaStaffCounter], A                    ;; 00:302b $ea $c7 $dc
    ld   [wDCC8_ElfCounter], A                        ;; 00:302e $ea $c8 $dc
    ld   [wDCC9_AlienCultureTubeCounter], A           ;; 00:3031 $ea $c9 $dc
    ld   [wDCCA_StrayCatCounter], A                   ;; 00:3034 $ea $ca $dc
    ld   [wDCCB_MechCounter], A                       ;; 00:3037 $ea $cb $dc
    ld   [wDCCC_BellCounter], A                       ;; 00:303a $ea $cc $dc
    ld   [wDCCD_ConvictCounter], A                    ;; 00:303d $ea $cd $dc
    ld   [wDCCE_BombCounter], A                       ;; 00:3040 $ea $ce $dc
    ld   [wDCCF_PlayingCardCounter], A                ;; 00:3043 $ea $cf $dc
    ld   [wDCD0_MadBomberFlag], A                     ;; 00:3046 $ea $d0 $dc
    ld   [wDCD1_BrainOfOzFlag], A                     ;; 00:3049 $ea $d1 $dc
    ld   [wDCD2_FreestandingRemoteHitFlags], A        ;; 00:304c $ea $d2 $dc
    ld   [wDCDA_BrainOfOzAndRezCounter], A            ;; 00:304f $ea $da $dc
    ld   HL, wDC1E_CurrentLevelID                     ;; 00:3052 $21 $1e $dc
    ld   L, [HL]                                      ;; 00:3055 $6e
    ld   H, $00                                       ;; 00:3056 $26 $00
    add  HL, HL                                       ;; 00:3058 $29
    add  HL, HL                                       ;; 00:3059 $29
    add  HL, HL                                       ;; 00:305a $29
    add  HL, HL                                       ;; 00:305b $29
    ld   DE, .data_00_30ba_LevelTriggerInitialData    ;; 00:305c $11 $ba $30
    add  HL, DE                                       ;; 00:305f $19
    ld   DE, wDCB1_LevelTriggerBuffer                 ;; 00:3060 $11 $b1 $dc
    ld   BC, LEVEL_TRIGGER_COUNT                      ;; 00:3063 $01 $10 $00
    call call_00_076e_MemCopy                         ;; 00:3066 $cd $6e $07
    ld   HL, .data_00_317a_ElevatorEntityInitialData  ;; 00:3069 $21 $7a $31
    ld   DE, wDCE2_ElevatorEntityUnkData              ;; 00:306c $11 $e2 $dc
    ld   BC, $06                                      ;; 00:306f $01 $06 $00
    call call_00_076e_MemCopy                         ;; 00:3072 $cd $6e $07
    ld   A, ELF_HEALTH_MAX                            ;; 00:3075 $3e $02
    ld   [wDCD5_ElfHealth1], A                        ;; 00:3077 $ea $d5 $dc
    ld   [wDCD6_ElfHealth2], A                        ;; 00:307a $ea $d6 $dc
    ld   [wDCD7_ElfHealth3], A                        ;; 00:307d $ea $d7 $dc
    ld   [wDCD8_ElfHealth4], A                        ;; 00:3080 $ea $d8 $dc
    ld   [wDCD9_ElfHealth5], A                        ;; 00:3083 $ea $d9 $dc
    ld   HL, wDB6D_InBonusStage                       ;; 00:3086 $21 $6d $db
    ld   [HL], $00                                    ;; 00:3089 $36 $00
    ld   A, [wDC1E_CurrentLevelID]                    ;; 00:308b $fa $1e $dc
    cp   A, LEVEL_GEXTREME_SPORTS                     ;; 00:308e $fe $07
    jr   Z, .jr_00_3096_InBonusStage                  ;; 00:3090 $28 $04
    cp   A, LEVEL_MARSUPIAL_MADNESS                   ;; 00:3092 $fe $08
    jr   NZ, .jr_00_30ab                              ;; 00:3094 $20 $15
.jr_00_3096_InBonusStage:
    ld   [HL], $01                                    ;; 00:3096 $36 $01
    ld   A, [wDC1E_CurrentLevelID]                    ;; 00:3098 $fa $1e $dc
    cp   A, LEVEL_GEXTREME_SPORTS                     ;; 00:309b $fe $07
    ld   A, BONUS_STAGE_SECONDS_GEXTREME              ;; 00:309d $3e $3c
    jr   Z, .jr_00_30a3                               ;; 00:309f $28 $02
    ld   A, BONUS_STAGE_SECONDS_MARSUPIAL             ;; 00:30a1 $3e $69
.jr_00_30a3:
    ld   [wDB6E_LevelTimer_SecondsRemaining], A       ;; 00:30a3 $ea $6e $db
    ld   A, FRAMES_PER_SECOND                         ;; 00:30a6 $3e $3c
    ld   [wDB6F_LevelTimer_FrameCounter], A           ;; 00:30a8 $ea $6f $db
.jr_00_30ab:
    call call_00_3180_Level_MarkPressedTVButtons      ;; 00:30ab $cd $80 $31
    call call_00_31d9_Level_ClearCollectedBonusCoinFlag ;; 00:30ae $cd $d9 $31
    call call_00_320d_Level_ClearCollectedPawCoinFlags ;; 00:30b1 $cd $0d $32
    call call_00_3252_EntityList_RewindCursor         ;; 00:30b4 $cd $52 $32
    jp   call_00_0f08_RestoreBank                     ;; 00:30b7 $c3 $08 $0f
.data_00_30ba_LevelTriggerInitialData:
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30ba ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30c2 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30ca ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30d2 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30da ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30e2 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30ea ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30f2 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:30fa ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3102 ????????
    db   $00, $01, $00, $00, $01, $00, $00, $00       ;; 00:310a ???????? ; anime channel
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3112 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:311a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3122 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:312a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3132 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:313a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3142 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:314a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3152 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:315a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3162 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:316a ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:3172 ????????
.data_00_317a_ElevatorEntityInitialData:
    db   $98, $02, $58, $01, $d8, $01                 ;; 00:317a ......

call_00_3180_Level_MarkPressedTVButtons:
; Marks the TV buttons that should already be lit when the level starts, by calling
; call_00_21f6_Entity_MarkTVButtonPressed once per button that qualifies.
;
; Two completely different rules, chosen by whether this is the hub:
;
;   in a level   .data_00_31c1_TVButtonsPressedPerLevel is a bitmask per level and
;                the three TV_BUTTONS_PER_LEVEL buttons are marked from its low bits.
;                Only three levels have a non-zero mask
;   in the hub   for each of the PROGRESS_FLAG_COUNT levels, bank 1 counts the
;                player's set progress bits and the button is marked when that count
;                reaches the threshold in .data_00_31cd_HubTVUnlockThresholds
;
; .data_00_31cd_HubTVUnlockThresholds is all zero in this build, so the hub rule
; marks every button - `cp A, [HL]` against zero is never carry. The mechanism is
; there and the data is not, which is worth knowing before reading meaning into it
    ld   A, [wDC1E_CurrentLevelID]                    ;; 00:3180 $fa $1e $dc
    and  A, A                                         ;; 00:3183 $a7
    jr   Z, .jr_00_31a0                               ;; 00:3184 $28 $1a
    ld   L, A                                         ;; 00:3186 $6f
    ld   H, $00                                       ;; 00:3187 $26 $00
    ld   DE, .data_00_31c1_TVButtonsPressedPerLevel   ;; 00:3189 $11 $c1 $31
    add  HL, DE                                       ;; 00:318c $19
    ld   B, [HL]                                      ;; 00:318d $46
    ld   C, $01                                       ;; 00:318e $0e $01
.jr_00_3190:
    push BC                                           ;; 00:3190 $c5
    bit  0, B                                         ;; 00:3191 $cb $40
    call NZ, call_00_21f6_Entity_MarkTVButtonPressed  ;; 00:3193 $c4 $f6 $21
    pop  BC                                           ;; 00:3196 $c1
    rr   B                                            ;; 00:3197 $cb $18
    inc  C                                            ;; 00:3199 $0c
    ld   A, C                                         ;; 00:319a $79
    cp   A, TV_BUTTONS_PER_LEVEL + 1                  ;; 00:319b $fe $04
    jr   C, .jr_00_3190                               ;; 00:319d $38 $f1
    ret                                               ;; 00:319f $c9
.jr_00_31a0:
    ld   BC, $01                                      ;; 00:31a0 $01 $01 $00
.jr_00_31a3:
    push BC                                           ;; 00:31a3 $c5
    push BC                                           ;; 00:31a4 $c5
    farcall call_01_4ab9_CountSetBitsInFlags
    pop  BC                                           ;; 00:31b0 $c1
    ld   HL, .data_00_31cd_HubTVUnlockThresholds      ;; 00:31b1 $21 $cd $31
    add  HL, BC                                       ;; 00:31b4 $09
    cp   A, [HL]                                      ;; 00:31b5 $be
    call NC, call_00_21f6_Entity_MarkTVButtonPressed  ;; 00:31b6 $d4 $f6 $21
    pop  BC                                           ;; 00:31b9 $c1
    inc  C                                            ;; 00:31ba $0c
    ld   A, C                                         ;; 00:31bb $79
    cp   A, PROGRESS_FLAG_COUNT                       ;; 00:31bc $fe $0c
    jr   C, .jr_00_31a3                               ;; 00:31be $38 $e3
    ret                                               ;; 00:31c0 $c9
.data_00_31c1_TVButtonsPressedPerLevel:
    db   $00, $00, $01, $04, $05, $00, $00, $00       ;; 00:31c1 ?.??????
    db   $00, $00, $00, $00
.data_00_31cd_HubTVUnlockThresholds:
    db   $00, $00, $00, $00                           ;; 00:31c9 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00       ;; 00:31d1 ????????

call_00_31d9_Level_ClearCollectedBonusCoinFlag:
; If the player has already taken this level's bonus coin, stop it coming back.
;
; PROGRESS_BONUS_COIN_TAKEN_BIT of this level's byte in wDC5C_ProgressFlags is the
; save flag. When it is set, the entity list is scanned for the first
; ENTITY_BONUS_COIN and that entry's wD700_EntityFlags byte is zeroed, which takes it
; out of ENTITY_LIST_FLAG_PRESENT and so out of the spawner's reach for the rest of
; the level.
;
; One coin only - the scan stops at the first match
    ld   HL, wDC1E_CurrentLevelID                     ;; 00:31d9 $21 $1e $dc
    ld   L, [HL]                                      ;; 00:31dc $6e
    ld   H, $00                                       ;; 00:31dd $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 00:31df $11 $5c $dc
    add  HL, DE                                       ;; 00:31e2 $19
    bit  PROGRESS_BONUS_COIN_TAKEN_BIT, [HL]          ;; 00:31e3 $cb $66
    ret  Z                                            ;; 00:31e5 $c8
    ld   A, [wDC16_EntityListBank]                    ;; 00:31e6 $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:31e9 $cd $ee $0e
    ld   HL, wDC17_EntityListBankOffset               ;; 00:31ec $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:31ef $2a
    ld   H, [HL]                                      ;; 00:31f0 $66
    ld   L, A                                         ;; 00:31f1 $6f
    ld   DE, ENTITY_SPAWN_RECORD_SIZE                 ;; 00:31f2 $11 $10 $00
    ld   C, $01                                       ;; 00:31f5 $0e $01
    ld   A, [HL]                                      ;; 00:31f7 $7e
.jr_00_31f8:
    cp   A, ENTITY_BONUS_COIN                         ;; 00:31f8 $fe $01
    jr   Z, .jr_00_3206                               ;; 00:31fa $28 $0a
    add  HL, DE                                       ;; 00:31fc $19
    inc  C                                            ;; 00:31fd $0c
    ld   A, [HL]                                      ;; 00:31fe $7e
    cp   A, ENTITY_LIST_END                           ;; 00:31ff $fe $ff
    jr   NZ, .jr_00_31f8                              ;; 00:3201 $20 $f5
    jp   call_00_0f08_RestoreBank                     ;; 00:3203 $c3 $08 $0f
.jr_00_3206:
    ld   B, HIGH(wD700_EntityFlags)                   ;; 00:3206 $06 $d7
    xor  A, A                                         ;; 00:3208 $af
    ld   [BC], A                                      ;; 00:3209 $02
    jp   call_00_0f08_RestoreBank                     ;; 00:320a $c3 $08 $0f

call_00_320d_Level_ClearCollectedPawCoinFlags:
; The same for the paw coins, of which a level has up to four.
;
; Each ENTITY_PAW_COIN record carries its coin number in ENTITY_SPAWN_RECORD_PARAM,
; and .data_00_324e_PawCoinProgressBits turns that number into a bit of the level's
; wDC5C_ProgressFlags byte. Any coin whose bit is set has its wD700_EntityFlags entry
; zeroed.
;
; The table is $00, $20, $40, $80 - so coin number 0 maps to no bit at all and can
; never be cleared this way, and only coins 1 to 3 are covered. Whether that is a
; deliberate 1-based numbering or an off-by-one is not something the code says.
;
; Unlike the bonus coin above this walks the whole list, because all four coins have
; to be checked
    ld   A, [wDC16_EntityListBank]                    ;; 00:320d $fa $16 $dc
    call call_00_0eee_SwitchBank                      ;; 00:3210 $cd $ee $0e
    ld   HL, wDC1E_CurrentLevelID                     ;; 00:3213 $21 $1e $dc
    ld   L, [HL]                                      ;; 00:3216 $6e
    ld   H, $00                                       ;; 00:3217 $26 $00
    ld   DE, wDC5C_ProgressFlags                      ;; 00:3219 $11 $5c $dc
    add  HL, DE                                       ;; 00:321c $19
    ld   C, [HL]                                      ;; 00:321d $4e
    ld   HL, wDC17_EntityListBankOffset               ;; 00:321e $21 $17 $dc
    ld   A, [HL+]                                     ;; 00:3221 $2a
    ld   H, [HL]                                      ;; 00:3222 $66
    ld   L, A                                         ;; 00:3223 $6f
    ld   B, $01                                       ;; 00:3224 $06 $01
.jr_00_3226:
    push HL                                           ;; 00:3226 $e5
    ld   A, [HL]                                      ;; 00:3227 $7e
    cp   A, ENTITY_PAW_COIN                           ;; 00:3228 $fe $03
    jr   NZ, .jr_00_3240                              ;; 00:322a $20 $14
    ld   DE, ENTITY_SPAWN_RECORD_PARAM                ;; 00:322c $11 $0d $00
    add  HL, DE                                       ;; 00:322f $19
    ld   L, [HL]                                      ;; 00:3230 $6e
    ld   H, $00                                       ;; 00:3231 $26 $00
    ld   DE, .data_00_324e_PawCoinProgressBits        ;; 00:3233 $11 $4e $32
    add  HL, DE                                       ;; 00:3236 $19
    ld   A, [HL]                                      ;; 00:3237 $7e
    and  A, C                                         ;; 00:3238 $a1
    jr   Z, .jr_00_3240                               ;; 00:3239 $28 $05
    ld   H, HIGH(wD700_EntityFlags)                   ;; 00:323b $26 $d7
    ld   L, B                                         ;; 00:323d $68
    ld   [HL], $00                                    ;; 00:323e $36 $00
.jr_00_3240:
    inc  B                                            ;; 00:3240 $04
    pop  HL                                           ;; 00:3241 $e1
    ld   DE, ENTITY_SPAWN_RECORD_SIZE                 ;; 00:3242 $11 $10 $00
    add  HL, DE                                       ;; 00:3245 $19
    ld   A, [HL]                                      ;; 00:3246 $7e
    cp   A, ENTITY_LIST_END                           ;; 00:3247 $fe $ff
    jr   NZ, .jr_00_3226                              ;; 00:3249 $20 $db
    jp   call_00_0f08_RestoreBank                     ;; 00:324b $c3 $08 $0f
.data_00_324e_PawCoinProgressBits:
    db   $00, $20, $40, $80                           ;; 00:324e ?...
