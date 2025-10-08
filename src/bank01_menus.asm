SECTION "bank01", ROMX[$4000], BANK[$01]

call_01_4000_MenuHandler_LoadAndProcess:
; Purpose:
; Initializes menu variables (wDBE9, wDBEA_MenuType, etc.) and copies menu-type–specific data into wDB92.
; Saves/restores the current level ID when transitioning to the menu.
; Loads map/VRAM data for menu backgrounds (call_03_6c89_LoadMapData).
; Handles multiple input modes:
; Navigation (up/down/left/right) through menu entries.
; Page wrapping, clamping, and cursor movement (wDBED, wDBEE, etc.).
; Sub-menu branching (jp_01_42c2, 42d0, etc.) and returning to game states.
; Calls tile loading and VRAM update routines between frames.
; Summary: Full menu controller—initializes, updates cursor positions, processes input, updates graphics, 
; and manages transitions between menu states.
;
; 1. Initialization Phase
; - Reset flags & menu state:
;   - Clears wDBE9 (menu state flags).
;   - Sets wDBEA_MenuType to the incoming menu ID.
;   - Saves the current level ID (wDB6C_CurrentMapId) so it can be restored after the menu closes.
;   - Copies a block of menu-specific data (pointer table or palette data) into wDB92—this acts as the active menu configuration.
; - Background setup:
;   - Calls call_03_6c89_CopyLevelData (or similar) to copy map data so the menu’s background appears.
;   - Loads background and object palettes for the menu screen.
;   - Resets the OAM pointer (wDC6F) and clears unused sprite slots.
;
; 2. Main Menu Loop
; - This loop runs each frame while the menu is active:
;
; A. Poll Input
; - Reads controller state into a working register.
; - Masks to check directional inputs (up, down, left, right), confirm/accept, and cancel/back.
;
; B. Update Cursor Position
; - Vertical movement (wDBED):
;   - If UP is pressed → decrements wDBED.
;   - If DOWN is pressed → increments wDBED.
;   - Wraps/clamps wDBED within valid menu entries (e.g., from 0 → max_index).
; - Horizontal/page movement (wDBEE):
;   - LEFT/RIGHT changes page or sub-option index.
;   - Also wrapped/clamped to prevent out-of-range pages.
;
; C. Handle Accept/Cancel
; - Accept/confirm button:
;   - Uses the cursor index (wDBED, wDBEE) to look up a jump table or handler routine for that menu option.
; - Calls routines like jp_01_42c2, jp_01_42d0, or others to branch to sub-menus, start a level, or change settings.
; - Cancel/back button:
;   - Restores the saved wDB6C_CurrentMapId.
;   - Exits the menu loop, returning control to the game world.
;
; D. Draw/Update Graphics
; - Loads menu option graphics or cursor sprites into VRAM each frame:
;   - Calls tile loading routines to update any changed options.
;   - Writes cursor sprite attributes to OAM.
;   - Clears any unused sprite slots to prevent flicker.
;
; E. Loop Continuation
; - Returns to Poll Input for the next frame until an accept or cancel action triggers an exit.
;
; 3. Exit Phase
; - Restores game state:
;   - Restores the saved level ID.
;   - Reinitializes map data if necessary.
;   - Passes control back to the main game loop or another state (like level select or intro).
;
; Summary
; MenuHandler_LoadAndProcess is essentially a menu state machine:
; 1. Initialize graphics and state.
; 2. Poll input each frame.
; 3. Adjust cursor/page indices (wDBED, wDBEE).
; 4. Handle confirm or cancel to branch or exit.
; 5. Update VRAM/OAM for smooth visuals.
; 6. On exit, restore level and resume gameplay.
    ld   HL, wDBE9                                     ;; 01:4000 $21 $e9 $db
    ld   [HL], $00                                     ;; 01:4003 $36 $00
.jp_01_4005:
    ld   [wDBEA_MenuType], A                                    ;; 01:4005 $ea $ea $db
    ld   L, A                                          ;; 01:4008 $6f
    ld   H, $00                                        ;; 01:4009 $26 $00
    add  HL, HL                                        ;; 01:400b $29
    add  HL, HL                                        ;; 01:400c $29
    add  HL, HL                                        ;; 01:400d $29
    add  HL, HL                                        ;; 01:400e $29
    ld   DE, data_01_53c6_MenuTypeData                              ;; 01:400f $11 $c6 $53
    add  HL, DE                                        ;; 01:4012 $19
    ld   DE, wDB92_MenuTypeDataPointer                                     ;; 01:4013 $11 $92 $db
    ld   BC, $0c                                       ;; 01:4016 $01 $0c $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4019 $cd $6e $07
    ld   A, [wDB6C_CurrentMapId]                                    ;; 01:401c $fa $6c $db
    ld   [wDBE8], A                                    ;; 01:401f $ea $e8 $db
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 01:4022 $fa $1e $dc
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:4025 $ea $6c $db
    cp   A, $07                                        ;; 01:4028 $fe $07
    jr   C, .jr_01_4037                                ;; 01:402a $38 $0b
    ld   A, [wDBEA_MenuType]                                    ;; 01:402c $fa $ea $db
    cp   A, $08                                        ;; 01:402f $fe $08
    jr   NZ, .jr_01_4037                               ;; 01:4031 $20 $04
    xor  A, A                                          ;; 01:4033 $af
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:4034 $ea $6c $db
.jr_01_4037:
    farcall call_03_6c89_LoadMapData
    xor  A, A                                          ;; 01:4042 $af
    ld   [wDBEB], A                                    ;; 01:4043 $ea $eb $db
    ld   [wDBEC], A                                    ;; 01:4046 $ea $ec $db
    ld   [wDBED], A                                    ;; 01:4049 $ea $ed $db
    ld   [wDBEE], A                                    ;; 01:404c $ea $ee $db
    ld   HL, wDB92_MenuTypeDataPointer                                     ;; 01:404f $21 $92 $db
    ld   A, [HL+]                                      ;; 01:4052 $2a
    ld   H, [HL]                                       ;; 01:4053 $66
    ld   L, A                                          ;; 01:4054 $6f
    call call_01_43f0_MenuEngine_MainLoop                                  ;; 01:4055 $cd $f0 $43
    ld   A, [wDB94]                                    ;; 01:4058 $fa $94 $db
    and  A, $02                                        ;; 01:405b $e6 $02
    jp   NZ, .jp_01_42c2                               ;; 01:405d $c2 $c2 $42
    ld   A, [wDB94]                                    ;; 01:4060 $fa $94 $db
    and  A, $04                                        ;; 01:4063 $e6 $04
    jp   NZ, .jp_01_42d0                               ;; 01:4065 $c2 $d0 $42
    ld   A, [wDB94]                                    ;; 01:4068 $fa $94 $db
    and  A, $08                                        ;; 01:406b $e6 $08
    jp   NZ, .jp_01_42e2                               ;; 01:406d $c2 $e2 $42
.jp_01_4070:
    ld   A, $ff                                        ;; 01:4070 $3e $ff
    ld   [wDBDC], A                                    ;; 01:4072 $ea $dc $db
    call call_01_4d2c_ProcessTileStreamingLoop                                  ;; 01:4075 $cd $2c $4d
.jp_01_4078:
    call call_01_4bb8_UpdateInterpolationStep                                  ;; 01:4078 $cd $b8 $4b
    call call_00_0b92_WaitForInterrupt                                  ;; 01:407b $cd $92 $0b
    call call_01_4b6b_StreamTileDataToBuffer                                  ;; 01:407e $cd $6b $4b
    ld   HL, wDBDC                                     ;; 01:4081 $21 $dc $db
    dec  [HL]                                          ;; 01:4084 $35
    ld   A, [wDB94]                                    ;; 01:4085 $fa $94 $db
    and  A, $01                                        ;; 01:4088 $e6 $01
    jp   Z, .jp_01_41cb                                ;; 01:408a $ca $cb $41
    ld   HL, wDAD7_CurrentInputs                                     ;; 01:408d $21 $d7 $da
    bit  2, [HL]                                       ;; 01:4090 $cb $56
    jr   Z, .jr_01_40ad                                ;; 01:4092 $28 $19
    ld   A, $01                                        ;; 01:4094 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:4096 $cd $d7 $0f
    ld   A, [wDBE8]                                    ;; 01:4099 $fa $e8 $db
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:409c $ea $6c $db
    farcall call_03_6c89_LoadMapData
    jp   .jp_01_4285                                   ;; 01:40aa $c3 $85 $42
.jr_01_40ad:
    ld   A, [wDB95]                                    ;; 01:40ad $fa $95 $db
    and  A, A                                          ;; 01:40b0 $a7
    jr   Z, .jp_01_4078                                ;; 01:40b1 $28 $c5
    bit  1, [HL]                                       ;; 01:40b3 $cb $4e
    jr   NZ, .jr_01_4111                               ;; 01:40b5 $20 $5a
    bit  0, [HL]                                       ;; 01:40b7 $cb $46
    jp   NZ, .jp_01_4180                               ;; 01:40b9 $c2 $80 $41
    bit  3, [HL]                                       ;; 01:40bc $cb $5e
    jp   NZ, .jp_01_415b                               ;; 01:40be $c2 $5b $41
    ld   A, [HL]                                       ;; 01:40c1 $7e
    and  A, $f0                                        ;; 01:40c2 $e6 $f0
    jr   Z, .jp_01_4078                                ;; 01:40c4 $28 $b2
    call call_00_0f6e_CheckInputRight                                  ;; 01:40c6 $cd $6e $0f
    jr   Z, .jr_01_40d7                                ;; 01:40c9 $28 $0c
    ld   HL, wDBED                                     ;; 01:40cb $21 $ed $db
    inc  [HL]                                          ;; 01:40ce $34
    ld   A, [HL]                                       ;; 01:40cf $7e
    sub  A, $10                                        ;; 01:40d0 $d6 $10
    jr   NZ, .jr_01_4109                               ;; 01:40d2 $20 $35
    ld   [HL], A                                       ;; 01:40d4 $77
    jr   .jr_01_4109                                   ;; 01:40d5 $18 $32
.jr_01_40d7:
    call call_00_0f68_CheckInputLeft                                  ;; 01:40d7 $cd $68 $0f
    jr   Z, .jr_01_40e8                                ;; 01:40da $28 $0c
    ld   HL, wDBED                                     ;; 01:40dc $21 $ed $db
    dec  [HL]                                          ;; 01:40df $35
    bit  7, [HL]                                       ;; 01:40e0 $cb $7e
    jr   Z, .jr_01_4109                                ;; 01:40e2 $28 $25
    ld   [HL], $0f                                     ;; 01:40e4 $36 $0f
    jr   .jr_01_4109                                   ;; 01:40e6 $18 $21
.jr_01_40e8:
    call call_00_0f7a_CheckInputDown                                  ;; 01:40e8 $cd $7a $0f
    jr   Z, .jr_01_40f9                                ;; 01:40eb $28 $0c
    ld   HL, wDBEE                                     ;; 01:40ed $21 $ee $db
    inc  [HL]                                          ;; 01:40f0 $34
    ld   A, [HL]                                       ;; 01:40f1 $7e
    sub  A, $02                                        ;; 01:40f2 $d6 $02
    jr   NZ, .jr_01_4109                               ;; 01:40f4 $20 $13
    ld   [HL], A                                       ;; 01:40f6 $77
    jr   .jr_01_4109                                   ;; 01:40f7 $18 $10
.jr_01_40f9:
    call call_00_0f74_CheckInputUp                                  ;; 01:40f9 $cd $74 $0f
    jp   Z, .jp_01_4078                                ;; 01:40fc $ca $78 $40
    ld   HL, wDBEE                                     ;; 01:40ff $21 $ee $db
    dec  [HL]                                          ;; 01:4102 $35
    bit  7, [HL]                                       ;; 01:4103 $cb $7e
    jr   Z, .jr_01_4109                                ;; 01:4105 $28 $02
    ld   [HL], $01                                     ;; 01:4107 $36 $01
.jr_01_4109:
    ld   A, $01                                        ;; 01:4109 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:410b $cd $d7 $0f
    jp   .jp_01_4070                                   ;; 01:410e $c3 $70 $40
.jr_01_4111:
    ld   HL, wDBEE                                     ;; 01:4111 $21 $ee $db
    ld   B, [HL]                                       ;; 01:4114 $46
    ld   A, $f0                                        ;; 01:4115 $3e $f0
.jr_01_4117:
    add  A, $10                                        ;; 01:4117 $c6 $10
    dec  B                                             ;; 01:4119 $05
    bit  7, B                                          ;; 01:411a $cb $78
    jr   Z, .jr_01_4117                                ;; 01:411c $28 $f9
    ld   HL, wDBED                                     ;; 01:411e $21 $ed $db
    add  A, [HL]                                       ;; 01:4121 $86
    ld   C, A                                          ;; 01:4122 $4f
    ld   HL, wDBEC                                     ;; 01:4123 $21 $ec $db
    ld   B, [HL]                                       ;; 01:4126 $46
    ld   A, $fa                                        ;; 01:4127 $3e $fa
.jr_01_4129:
    add  A, $06                                        ;; 01:4129 $c6 $06
    dec  B                                             ;; 01:412b $05
    bit  7, B                                          ;; 01:412c $cb $78
    jr   Z, .jr_01_4129                                ;; 01:412e $28 $f9
    ld   HL, wDBEB                                     ;; 01:4130 $21 $eb $db
    add  A, [HL]                                       ;; 01:4133 $86
    ld   L, A                                          ;; 01:4134 $6f
    ld   H, $00                                        ;; 01:4135 $26 $00
    ld   DE, wDB7E                                     ;; 01:4137 $11 $7e $db
    add  HL, DE                                        ;; 01:413a $19
    ld   [HL], C                                       ;; 01:413b $71
    call call_01_4d6e_PrepareStreamingPointers                                  ;; 01:413c $cd $6e $4d
    ld   HL, wDBEB                                     ;; 01:413f $21 $eb $db
    inc  [HL]                                          ;; 01:4142 $34
    ld   A, [HL]                                       ;; 01:4143 $7e
    sub  A, $06                                        ;; 01:4144 $d6 $06
    jr   NZ, .jr_01_4153                               ;; 01:4146 $20 $0b
    ld   [HL], A                                       ;; 01:4148 $77
    ld   HL, wDBEC                                     ;; 01:4149 $21 $ec $db
    inc  [HL]                                          ;; 01:414c $34
    ld   A, [HL]                                       ;; 01:414d $7e
    sub  A, $03                                        ;; 01:414e $d6 $03
    jr   NZ, .jr_01_4153                               ;; 01:4150 $20 $01
    ld   [HL], A                                       ;; 01:4152 $77
.jr_01_4153:
    ld   A, $01                                        ;; 01:4153 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:4155 $cd $d7 $0f
    jp   .jp_01_4070                                   ;; 01:4158 $c3 $70 $40
.jp_01_415b:
    call call_01_505a_ValidateTileBufferAndRebuildCollisionData                                  ;; 01:415b $cd $5a $50
    push AF                                            ;; 01:415e $f5
    cp   A, $20                                        ;; 01:415f $fe $20
    ld   A, $ff                                        ;; 01:4161 $3e $ff
    jr   Z, .jr_01_4167                                ;; 01:4163 $28 $02
    ld   A, $ff                                        ;; 01:4165 $3e $ff
.jr_01_4167:
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:4167 $cd $d7 $0f
    ld   B, $3c                                        ;; 01:416a $06 $3c
.jr_01_416c:
    push BC                                            ;; 01:416c $c5
    call call_00_0b92_WaitForInterrupt                                  ;; 01:416d $cd $92 $0b
    pop  BC                                            ;; 01:4170 $c1
    dec  B                                             ;; 01:4171 $05
    jr   NZ, .jr_01_416c                               ;; 01:4172 $20 $f8
    pop  AF                                            ;; 01:4174 $f1
    cp   A, $20                                        ;; 01:4175 $fe $20
    ret  Z                                             ;; 01:4177 $c8
    ld   A, $04                                        ;; 01:4178 $3e $04
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:417a $cd $00 $40
    jp   .jp_01_42a1                                   ;; 01:417d $c3 $a1 $42
.jp_01_4180:
    call call_00_0f6e_CheckInputRight                                  ;; 01:4180 $cd $6e $0f
    jr   Z, .jr_01_4191                                ;; 01:4183 $28 $0c
    ld   HL, wDBEB                                     ;; 01:4185 $21 $eb $db
    inc  [HL]                                          ;; 01:4188 $34
    ld   A, [HL]                                       ;; 01:4189 $7e
    sub  A, $06                                        ;; 01:418a $d6 $06
    jr   NZ, .jr_01_41c3                               ;; 01:418c $20 $35
    ld   [HL], A                                       ;; 01:418e $77
    jr   .jr_01_41c3                                   ;; 01:418f $18 $32
.jr_01_4191:
    call call_00_0f68_CheckInputLeft                                  ;; 01:4191 $cd $68 $0f
    jr   Z, .jr_01_41a2                                ;; 01:4194 $28 $0c
    ld   HL, wDBEB                                     ;; 01:4196 $21 $eb $db
    dec  [HL]                                          ;; 01:4199 $35
    bit  7, [HL]                                       ;; 01:419a $cb $7e
    jr   Z, .jr_01_41c3                                ;; 01:419c $28 $25
    ld   [HL], $05                                     ;; 01:419e $36 $05
    jr   .jr_01_41c3                                   ;; 01:41a0 $18 $21
.jr_01_41a2:
    call call_00_0f7a_CheckInputDown                                  ;; 01:41a2 $cd $7a $0f
    jr   Z, .jr_01_41b3                                ;; 01:41a5 $28 $0c
    ld   HL, wDBEC                                     ;; 01:41a7 $21 $ec $db
    inc  [HL]                                          ;; 01:41aa $34
    ld   A, [HL]                                       ;; 01:41ab $7e
    sub  A, $03                                        ;; 01:41ac $d6 $03
    jr   NZ, .jr_01_41c3                               ;; 01:41ae $20 $13
    ld   [HL], A                                       ;; 01:41b0 $77
    jr   .jr_01_41c3                                   ;; 01:41b1 $18 $10
.jr_01_41b3:
    call call_00_0f74_CheckInputUp                                  ;; 01:41b3 $cd $74 $0f
    jp   Z, .jp_01_4078                                ;; 01:41b6 $ca $78 $40
    ld   HL, wDBEC                                     ;; 01:41b9 $21 $ec $db
    dec  [HL]                                          ;; 01:41bc $35
    bit  7, [HL]                                       ;; 01:41bd $cb $7e
    jr   Z, .jr_01_41c3                                ;; 01:41bf $28 $02
    ld   [HL], $02                                     ;; 01:41c1 $36 $02
.jr_01_41c3:
    ld   A, $01                                        ;; 01:41c3 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:41c5 $cd $d7 $0f
    jp   .jp_01_4070                                   ;; 01:41c8 $c3 $70 $40
.jp_01_41cb:
    ld   A, [wDB95]                                    ;; 01:41cb $fa $95 $db
    and  A, A                                          ;; 01:41ce $a7
    jp   Z, .jp_01_41fc                                ;; 01:41cf $ca $fc $41
    call call_00_0f74_CheckInputUp                                  ;; 01:41d2 $cd $74 $0f
    jr   Z, .jr_01_41e1                                ;; 01:41d5 $28 $0a
    ld   HL, wDBEC                                     ;; 01:41d7 $21 $ec $db
    ld   A, [HL]                                       ;; 01:41da $7e
    and  A, A                                          ;; 01:41db $a7
    jr   Z, .jp_01_41fc                                ;; 01:41dc $28 $1e
    dec  [HL]                                          ;; 01:41de $35
    jr   .jr_01_41f1                                   ;; 01:41df $18 $10
.jr_01_41e1:
    call call_00_0f7a_CheckInputDown                                  ;; 01:41e1 $cd $7a $0f
    jr   Z, .jp_01_41fc                                ;; 01:41e4 $28 $16
    ld   A, [wDB95]                                    ;; 01:41e6 $fa $95 $db
    dec  A                                             ;; 01:41e9 $3d
    ld   HL, wDBEC                                     ;; 01:41ea $21 $ec $db
    cp   A, [HL]                                       ;; 01:41ed $be
    jr   Z, .jp_01_41fc                                ;; 01:41ee $28 $0c
    inc  [HL]                                          ;; 01:41f0 $34
.jr_01_41f1:
    ld   A, $01                                        ;; 01:41f1 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:41f3 $cd $d7 $0f
    call call_01_43ba_JumpToDynamicHandler                                  ;; 01:41f6 $cd $ba $43
    jp   .jp_01_4070                                   ;; 01:41f9 $c3 $70 $40
.jp_01_41fc:
    ld   A, [wDB94]                                    ;; 01:41fc $fa $94 $db
    and  A, $10                                        ;; 01:41ff $e6 $10
    jr   Z, .jr_01_423c                                ;; 01:4201 $28 $39
    call call_00_0f6e_CheckInputRight                                  ;; 01:4203 $cd $6e $0f
    jr   Z, .jr_01_4214                                ;; 01:4206 $28 $0c
    ld   HL, wDB6C_CurrentMapId                                     ;; 01:4208 $21 $6c $db
    inc  [HL]                                          ;; 01:420b $34
    ld   A, [HL]                                       ;; 01:420c $7e
    sub  A, $07                                        ;; 01:420d $d6 $07
    jr   NZ, .jr_01_4212                               ;; 01:420f $20 $01
    ld   [HL], A                                       ;; 01:4211 $77
.jr_01_4212:
    jr   .jr_01_4223                                   ;; 01:4212 $18 $0f
.jr_01_4214:
    call call_00_0f68_CheckInputLeft                                  ;; 01:4214 $cd $68 $0f
    jr   Z, .jr_01_423c                                ;; 01:4217 $28 $23
    ld   HL, wDB6C_CurrentMapId                                     ;; 01:4219 $21 $6c $db
    dec  [HL]                                          ;; 01:421c $35
    bit  7, [HL]                                       ;; 01:421d $cb $7e
    jr   Z, .jr_01_4223                                ;; 01:421f $28 $02
    ld   [HL], $06                                     ;; 01:4221 $36 $06
.jr_01_4223:
    farcall call_03_6c89_LoadMapData
    ld   HL, data_01_5692                              ;; 01:422e $21 $92 $56
    call call_01_4454_SetMenuPointer                                  ;; 01:4231 $cd $54 $44
    ld   A, $01                                        ;; 01:4234 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:4236 $cd $d7 $0f
    jp   .jp_01_4070                                   ;; 01:4239 $c3 $70 $40
.jr_01_423c:
    call call_00_0f9c_CheckInputB                                  ;; 01:423c $cd $9c $0f
    jp   Z, .jp_01_4078                                ;; 01:423f $ca $78 $40
    ld   A, $01                                        ;; 01:4242 $3e $01
    call call_00_0fd7_TriggerSoundEffect                                  ;; 01:4244 $cd $d7 $0f
    call call_00_0f5e_WaitUntilNoInputPressed                                  ;; 01:4247 $cd $5e $0f
    ld   A, [wDBE8]                                    ;; 01:424a $fa $e8 $db
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:424d $ea $6c $db
    farcall call_03_6c89_LoadMapData
    ld   A, [wDB95]                                    ;; 01:425b $fa $95 $db
    and  A, A                                          ;; 01:425e $a7
    jr   Z, .jp_01_4285                                ;; 01:425f $28 $24
    ld   HL, wDBEC                                     ;; 01:4261 $21 $ec $db
    ld   L, [HL]                                       ;; 01:4264 $6e
    ld   H, $00                                        ;; 01:4265 $26 $00
    ld   DE, wDBCB                                     ;; 01:4267 $11 $cb $db
    add  HL, DE                                        ;; 01:426a $19
    ld   A, [HL]                                       ;; 01:426b $7e
    cp   A, $10                                        ;; 01:426c $fe $10
    ret  Z                                             ;; 01:426e $c8
    cp   A, $60                                        ;; 01:426f $fe $60
    ret  Z                                             ;; 01:4271 $c8
    cp   A, $20                                        ;; 01:4272 $fe $20
    jr   Z, .jp_01_42a1                                ;; 01:4274 $28 $2b
    cp   A, $30                                        ;; 01:4276 $fe $30
    jr   Z, .jr_01_4290                                ;; 01:4278 $28 $16
    cp   A, $50                                        ;; 01:427a $fe $50
    jr   Z, .jr_01_42a9                                ;; 01:427c $28 $2b
    cp   A, $70                                        ;; 01:427e $fe $70
    jr   Z, .jr_01_42b7                                ;; 01:4280 $28 $35
    cp   A, $40                                        ;; 01:4282 $fe $40
    ret  Z                                             ;; 01:4284 $c8
.jp_01_4285:
    call call_00_0f5e_WaitUntilNoInputPressed                                  ;; 01:4285 $cd $5e $0f
    ld   A, [wDBE9]                                    ;; 01:4288 $fa $e9 $db
    and  A, A                                          ;; 01:428b $a7
    jp   NZ, call_01_4000_MenuHandler_LoadAndProcess                              ;; 01:428c $c2 $00 $40
    ret                                                ;; 01:428f $c9
.jr_01_4290:
    ld   A, [wDBEA_MenuType]                                    ;; 01:4290 $fa $ea $db
    ld   [wDBE9], A                                    ;; 01:4293 $ea $e9 $db
    call call_01_4f8c_BuildCollisionBitfieldAndChecksum                                  ;; 01:4296 $cd $8c $4f
    call call_01_5027_BuildTileFlagBufferFromBitfield                                  ;; 01:4299 $cd $27 $50
    ld   A, $02                                        ;; 01:429c $3e $02
    jp   .jp_01_4005                                   ;; 01:429e $c3 $05 $40
.jp_01_42a1:
    call call_01_4f7e_SeedTileLookupTable                                  ;; 01:42a1 $cd $7e $4f
    ld   A, $01                                        ;; 01:42a4 $3e $01
    jp   call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:42a6 $c3 $00 $40
.jr_01_42a9:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 01:42a9 $fa $1e $dc
    and  A, A                                          ;; 01:42ac $a7
    ld   A, $0c                                        ;; 01:42ad $3e $0c
    jp   Z, .jp_01_4005                                ;; 01:42af $ca $05 $40
    ld   A, $0e                                        ;; 01:42b2 $3e $0e
    jp   .jp_01_4005                                   ;; 01:42b4 $c3 $05 $40
.jr_01_42b7:
    ld   A, [wDBEA_MenuType]                                    ;; 01:42b7 $fa $ea $db
    ld   [wDBE9], A                                    ;; 01:42ba $ea $e9 $db
    ld   A, $08                                        ;; 01:42bd $3e $08
    jp   .jp_01_4005                                   ;; 01:42bf $c3 $05 $40
.jp_01_42c2:
    ld   BC, $12c                                      ;; 01:42c2 $01 $2c $01
.jr_01_42c5:
    push BC                                            ;; 01:42c5 $c5
    call call_00_0b92_WaitForInterrupt                                  ;; 01:42c6 $cd $92 $0b
    pop  BC                                            ;; 01:42c9 $c1
    dec  BC                                            ;; 01:42ca $0b
    ld   A, B                                          ;; 01:42cb $78
    or   A, C                                          ;; 01:42cc $b1
    jr   NZ, .jr_01_42c5                               ;; 01:42cd $20 $f6
    ret                                                ;; 01:42cf $c9
.jp_01_42d0:
    ld   BC, $2d0                                      ;; 01:42d0 $01 $d0 $02
.jr_01_42d3:
    push BC                                            ;; 01:42d3 $c5
    call call_00_0b92_WaitForInterrupt                                  ;; 01:42d4 $cd $92 $0b
    call call_00_0f9c_CheckInputB                                  ;; 01:42d7 $cd $9c $0f
    pop  BC                                            ;; 01:42da $c1
    ret  NZ                                            ;; 01:42db $c0
    dec  BC                                            ;; 01:42dc $0b
    ld   A, B                                          ;; 01:42dd $78
    or   A, C                                          ;; 01:42de $b1
    jr   NZ, .jr_01_42d3                               ;; 01:42df $20 $f2
    ret                                                ;; 01:42e1 $c9
.jp_01_42e2:
    call call_01_4d2c_ProcessTileStreamingLoop                                  ;; 01:42e2 $cd $2c $4d
.jr_01_42e5:
    call call_01_4bb8_UpdateInterpolationStep                                  ;; 01:42e5 $cd $b8 $4b
    call call_00_0b92_WaitForInterrupt                                  ;; 01:42e8 $cd $92 $0b
    call call_01_4b6b_StreamTileDataToBuffer                                  ;; 01:42eb $cd $6b $4b
    ld   HL, wDBDC                                     ;; 01:42ee $21 $dc $db
    dec  [HL]                                          ;; 01:42f1 $35
    ld   A, [wDAD7_CurrentInputs]                                    ;; 01:42f2 $fa $d7 $da
    and  A, A                                          ;; 01:42f5 $a7
    jr   Z, .jr_01_42e5                                ;; 01:42f6 $28 $ed
    ld   A, $01                                        ;; 01:42f8 $3e $01
    jp   call_00_0fd7_TriggerSoundEffect                                  ;; 01:42fa $c3 $d7 $0f

call_01_42fd_LoadMenu03_InitSong15:
; Behavior:
; Requests song bank 15 and starts playback, then immediately jumps to LoadMenu with ID $03.
; Likely Purpose: Entry point to show a specific menu screen (e.g., pause/options).
    ld   A, $15                                        ;; 01:42fd $3e $15
    call call_00_0fa2_PlaySong                                  ;; 01:42ff $cd $a2 $0f
    ld   A, $03                                        ;; 01:4302 $3e $03
    jp   call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4304 $c3 $00 $40

call_01_4307_PreloadMenus_15to1A:
; Behavior:
; Requests song bank 19 and plays it, then sequentially loads menus $15–$1A.
; Likely Purpose: Preloads multiple menu assets into VRAM (like caching 
; graphics for level select or transitions).
    ld   A, $19                                        ;; 01:4307 $3e $19
    call call_00_0fa2_PlaySong                                  ;; 01:4309 $cd $a2 $0f
    ld   A, $15                                        ;; 01:430c $3e $15
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:430e $cd $00 $40
    ld   A, $16                                        ;; 01:4311 $3e $16
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4313 $cd $00 $40
    ld   A, $17                                        ;; 01:4316 $3e $17
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4318 $cd $00 $40
    ld   A, $18                                        ;; 01:431b $3e $18
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:431d $cd $00 $40
    ld   A, $19                                        ;; 01:4320 $3e $19
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4322 $cd $00 $40
    ld   A, $1a                                        ;; 01:4325 $3e $1a
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4327 $cd $00 $40
    ret                                                ;; 01:432a $c9

call_01_432b_SetLevelMenuAndPalette:
; Behavior:
; Checks wDB6C_CurrentMapId. If zero, returns. Otherwise requests song bank 04 and plays it, 
; compares level ID to $07, and:
; For ≥ $07: sets wDC59=1, loads menu $05, and stores a value into wDC5A.
; For < $07: sets wDC59=3, loads menu $07, and stores the same palette value.
; Likely Purpose: Chooses which menu/palette to display depending on current level group.
    ld   A, [wDB6C_CurrentMapId]                                    ;; 01:432b $fa $6c $db
    and  A, A                                          ;; 01:432e $a7
    ret  Z                                             ;; 01:432f $c8
    ld   A, $04                                        ;; 01:4330 $3e $04
    call call_00_0fa2_PlaySong                                  ;; 01:4332 $cd $a2 $0f
    ld   A, [wDB6C_CurrentMapId]                                    ;; 01:4335 $fa $6c $db
    cp   A, $07                                        ;; 01:4338 $fe $07
    jr   C, .jr_01_434d                                ;; 01:433a $38 $11
    ld   A, $01                                        ;; 01:433c $3e $01
    ld   [wDC59], A                                    ;; 01:433e $ea $59 $dc
    ld   A, $05                                        ;; 01:4341 $3e $05
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4343 $cd $00 $40
    ld   A, [wDBEC]                                    ;; 01:4346 $fa $ec $db
    ld   [wDC5A], A                                    ;; 01:4349 $ea $5a $dc
    ret                                                ;; 01:434c $c9
.jr_01_434d:
    ld   A, $03                                        ;; 01:434d $3e $03
    ld   [wDC59], A                                    ;; 01:434f $ea $59 $dc
    ld   A, $07                                        ;; 01:4352 $3e $07
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:4354 $cd $00 $40
    ld   A, [wDBEC]                                    ;; 01:4357 $fa $ec $db
    ld   [wDC5A], A                                    ;; 01:435a $ea $5a $dc
    ret                                                ;; 01:435d $c9

call_01_435e_HandleLevelTransitionMenu:
; Behavior:
; Clears a flag bit in wDB6A.
; Copies CurrentLevelNumber to CurrentLevelId.
; If that ID is 0, restores it from wDC5B and returns.
; Otherwise, branching logic:
;  - If [wDB6D] != 0:
;    - If bit 5 of wDB6A is set: clear it, request song 15, load menu 0A.
;  - Else: request song 13, load menu 1B.
;  - If [wDB6D] == 0:
;    - If LevelId ≥ 07 but not 09 or 0A → preload menus 15–1A.
;    - Else if LevelId < 07 → request song 13, load menu 09.
;    - Else (exact 09 or 0A) → same as above “song 13/menu 1B”.
; At the end, clears wDB6C_CurrentMapId (so the menu system takes over).
; Likely Purpose: Manages menu/graphics updates when transitioning between levels.
    ld   HL, wDB6A                                     ;; 01:435e $21 $6a $db
    res  4, [HL]                                       ;; 01:4361 $cb $a6
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 01:4363 $fa $1e $dc
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:4366 $ea $6c $db
    and  A, A                                          ;; 01:4369 $a7
    jr   Z, .jr_01_43b3                                ;; 01:436a $28 $47
    ld   A, [wDB6D]                                    ;; 01:436c $fa $6d $db
    and  A, A                                          ;; 01:436f $a7
    jr   Z, .jr_01_4390                                ;; 01:4370 $28 $1e
    bit  5, [HL]                                       ;; 01:4372 $cb $6e
    jr   Z, .jr_01_4384                                ;; 01:4374 $28 $0e
    res  5, [HL]                                       ;; 01:4376 $cb $ae
    ld   A, $15                                        ;; 01:4378 $3e $15
    call call_00_0fa2_PlaySong                                  ;; 01:437a $cd $a2 $0f
    ld   A, $0a                                        ;; 01:437d $3e $0a
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:437f $cd $00 $40
    jr   .jr_01_43ae                                   ;; 01:4382 $18 $2a
.jr_01_4384:
    ld   A, $13                                        ;; 01:4384 $3e $13
    call call_00_0fa2_PlaySong                                  ;; 01:4386 $cd $a2 $0f
    ld   A, $1b                                        ;; 01:4389 $3e $1b
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:438b $cd $00 $40
    jr   .jr_01_43ae                                   ;; 01:438e $18 $1e
.jr_01_4390:
    ld   A, [wDB6C_CurrentMapId]                                    ;; 01:4390 $fa $6c $db
    cp   A, $07                                        ;; 01:4393 $fe $07
    jr   C, .jr_01_43a4                                ;; 01:4395 $38 $0d
    cp   A, $09                                        ;; 01:4397 $fe $09
    jr   Z, .jr_01_4384                                ;; 01:4399 $28 $e9
    cp   A, $0a                                        ;; 01:439b $fe $0a
    jr   Z, .jr_01_4384                                ;; 01:439d $28 $e5
    call call_01_4307_PreloadMenus_15to1A                                  ;; 01:439f $cd $07 $43
    jr   .jr_01_43ae                                   ;; 01:43a2 $18 $0a
.jr_01_43a4:
    ld   A, $13                                        ;; 01:43a4 $3e $13
    call call_00_0fa2_PlaySong                                  ;; 01:43a6 $cd $a2 $0f
    ld   A, $09                                        ;; 01:43a9 $3e $09
    call call_01_4000_MenuHandler_LoadAndProcess                                  ;; 01:43ab $cd $00 $40
.jr_01_43ae:
    xor  A, A                                          ;; 01:43ae $af
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:43af $ea $6c $db
    ret                                                ;; 01:43b2 $c9
.jr_01_43b3:
    ld   A, [wDC5B]                                    ;; 01:43b3 $fa $5b $dc
    ld   [wDB6C_CurrentMapId], A                                    ;; 01:43b6 $ea $6c $db
    ret                                                ;; 01:43b9 $c9

call_01_43ba_JumpToDynamicHandler:
; Behavior:
; Reads a pointer from wDB9C/wDB9D; if nonzero, jumps there.
; Likely Purpose: Generic “execute callback” mechanism for menu or level-specific code.
    ld   HL, wDB9C                                     ;; 01:43ba $21 $9c $db
    ld   A, [HL+]                                      ;; 01:43bd $2a
    ld   H, [HL]                                       ;; 01:43be $66
    ld   L, A                                          ;; 01:43bf $6f
    or   A, H                                          ;; 01:43c0 $b4
    ret  Z                                             ;; 01:43c1 $c8
    jp   HL                                            ;; 01:43c2 $e9

call_01_43c3_LoadMenuObjectPalette:
; Behavior:
; Copies one of two 16-byte palette sets into wDD4A_ObjectPalettes depending on wDBEC.
; Likely Purpose: Sets object sprite palettes based on context (e.g., regular vs. alternate theme).
    ld   HL, .data_01_43d8                             ;; 01:43c3 $21 $d8 $43
    ld   A, [wDBEC]                                    ;; 01:43c6 $fa $ec $db
    and  A, A                                          ;; 01:43c9 $a7
    jr   Z, .jr_01_43cf                                ;; 01:43ca $28 $03
    ld   HL, .data_01_43e0                             ;; 01:43cc $21 $e0 $43
.jr_01_43cf:
    ld   DE, wDD4A_ObjectPalettes                                     ;; 01:43cf $11 $4a $dd
    ld   BC, $10                                       ;; 01:43d2 $01 $10 $00
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:43d5 $c3 $6e $07
.data_01_43d8:
    db   $00, $00, $ff, $7f, $f7, $5e, $ef, $3d        ;; 01:43d8 ........
.data_01_43e0:
    db   $00, $00, $ef, $3d, $6b, $2d, $e7, $1c        ;; 01:43e0 ........
    db   $00, $00, $ff, $7f, $f7, $5e, $ef, $3d        ;; 01:43e8 ........

call_01_43f0_MenuEngine_MainLoop:
; Behavior:
; Clears/reset game state and VRAM, loads resources, then:
; Saves HL as a pointer.
; Repeatedly processes a menu/script stream (call_01_445c_ProcessMenuScript and call_01_446b_ExecuteMenuCommand), 
; executing commands until $FF.
; Updates palettes and LCD control, then finalizes VRAM updates.
; Likely Purpose: Core loop for processing menu scripts or transitions.
    push HL                                            ;; 01:43f0 $e5
    call call_00_0e3b_ClearGameStateVariables                                  ;; 01:43f1 $cd $3b $0e
    call call_00_0e62_ResetFlagsAndVRAMState                                  ;; 01:43f4 $cd $62 $0e
    call call_01_4f27_ClearBgAndTileBuffers                                  ;; 01:43f7 $cd $27 $4f
    ld   A, $ff                                        ;; 01:43fa $3e $ff
    ld   [wDBC7], A                                    ;; 01:43fc $ea $c7 $db
    xor  A, A                                          ;; 01:43ff $af
    ld   [wDBDE], A                                    ;; 01:4400 $ea $de $db
    ld   [wDBE3], A                                    ;; 01:4403 $ea $e3 $db
    ld   A, $0a                                        ;; 01:4406 $3e $0a
    call call_00_0c10_QueueVRAMCopyRequest                                  ;; 01:4408 $cd $10 $0c
    pop  HL                                            ;; 01:440b $e1
.jr_01_440c:
    ld   A, L                                          ;; 01:440c $7d
    ld   [wDBB9], A                                    ;; 01:440d $ea $b9 $db
    ld   A, H                                          ;; 01:4410 $7c
    ld   [wDBBA], A                                    ;; 01:4411 $ea $ba $db
    ld   A, $ff                                        ;; 01:4414 $3e $ff
    ld   [wDBDD], A                                    ;; 01:4416 $ea $dd $db
    call call_01_445c_ProcessMenuScript                                  ;; 01:4419 $cd $5c $44
    ld   A, [wDBDD]                                    ;; 01:441c $fa $dd $db
    cp   A, $ff                                        ;; 01:441f $fe $ff
    jr   Z, .jr_01_442b                                ;; 01:4421 $28 $08
    ld   DE, data_01_5596                              ;; 01:4423 $11 $96 $55
    call call_00_0777                                  ;; 01:4426 $cd $77 $07
    jr   .jr_01_440c                                   ;; 01:4429 $18 $e1
.jr_01_442b:
    call call_01_4f51_UploadSecondaryTileLayer                                  ;; 01:442b $cd $51 $4f
    call call_01_4f5c_UploadPrimaryTileLayer                                  ;; 01:442e $cd $5c $4f
    ld   HL, wDB9B                                     ;; 01:4431 $21 $9b $db
    bit  7, [HL]                                       ;; 01:4434 $cb $7e
    jr   NZ, .jr_01_4444                               ;; 01:4436 $20 $0c
    ld   C, [HL]                                       ;; 01:4438 $4e
    farcall call_03_65c6_LoadMenuOrLevelPalettes
.jr_01_4444:
    call call_01_43ba_JumpToDynamicHandler                                  ;; 01:4444 $cd $ba $43
    ld   A, $d3                                        ;; 01:4447 $3e $d3
    call call_00_0e33_SetLCDControlRegister                                  ;; 01:4449 $cd $33 $0e
    ld   A, $01                                        ;; 01:444c $3e $01
    ld   [wDD6A], A                                    ;; 01:444e $ea $6a $dd
    jp   call_00_0b92_WaitForInterrupt                                  ;; 01:4451 $c3 $92 $0b

call_01_4454_SetMenuPointer:
; Behavior:
; Stores HL into wDBB9/wDBBA.
; Likely Purpose: Initializes the menu-script pointer for the engine.
    ld   A, L                                          ;; 01:4454 $7d
    ld   [wDBB9], A                                    ;; 01:4455 $ea $b9 $db
    ld   A, H                                          ;; 01:4458 $7c
    ld   [wDBBA], A                                    ;; 01:4459 $ea $ba $db

call_01_445c_ProcessMenuScript:
; Behavior:
; Dereferences wDBB9 pointer, fetches a byte, and, until $FF, calls call_01_446b_ExecuteMenuCommand 
; to process each command, looping through the script.
; Likely Purpose: Iterates through a menu script.
    ld   HL, wDBB9                                     ;; 01:445c $21 $b9 $db
    ld   A, [HL+]                                      ;; 01:445f $2a
    ld   H, [HL]                                       ;; 01:4460 $66
    ld   L, A                                          ;; 01:4461 $6f
    ld   A, [HL]                                       ;; 01:4462 $7e
    cp   A, $ff                                        ;; 01:4463 $fe $ff
    ret  Z                                             ;; 01:4465 $c8
    call call_01_446b_ExecuteMenuCommand                                  ;; 01:4466 $cd $6b $44
    jr   call_01_445c_ProcessMenuScript                                  ;; 01:4469 $18 $f1

call_01_446b_ExecuteMenuCommand:
; Behavior:
; Advances the script pointer, copies menu command parameters to working RAM (wDB9E, wDBA4), 
; updates tile maps, handles jump tables, checks flags (wDBAA), and may jump to specialized handlers in .data_01_456b_MenuCommandJumpTable.
; Likely Purpose: Decodes and executes individual menu commands, updating VRAM or branching to specialized routines.
    ld   HL, wDBB9                                     ;; 01:446b $21 $b9 $db
    ld   E, [HL]                                       ;; 01:446e $5e
    inc  HL                                            ;; 01:446f $23
    ld   D, [HL]                                       ;; 01:4470 $56
    ld   A, [DE]                                       ;; 01:4471 $1a
    inc  DE                                            ;; 01:4472 $13
    ld   [HL], D                                       ;; 01:4473 $72
    dec  HL                                            ;; 01:4474 $2b
    ld   [HL], E                                       ;; 01:4475 $73
    ld   [wDBCA], A                                    ;; 01:4476 $ea $ca $db
    ld   L, A                                          ;; 01:4479 $6f
    ld   H, $00                                        ;; 01:447a $26 $00
    add  HL, HL                                        ;; 01:447c $29
    add  HL, HL                                        ;; 01:447d $29
    add  HL, HL                                        ;; 01:447e $29
    ld   DE, data_01_512e                              ;; 01:447f $11 $2e $51
    add  HL, DE                                        ;; 01:4482 $19
    ld   DE, wDB9E                                     ;; 01:4483 $11 $9e $db
    ld   BC, $06                                       ;; 01:4486 $01 $06 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4489 $cd $6e $07
.jr_01_448c:
    ld   HL, wDBB9                                     ;; 01:448c $21 $b9 $db
    ld   A, [HL+]                                      ;; 01:448f $2a
    ld   H, [HL]                                       ;; 01:4490 $66
    ld   L, A                                          ;; 01:4491 $6f
    ld   DE, wDBA4                                     ;; 01:4492 $11 $a4 $db
    ld   BC, $07                                       ;; 01:4495 $01 $07 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4498 $cd $6e $07
    ld   A, L                                          ;; 01:449b $7d
    ld   [wDBB9], A                                    ;; 01:449c $ea $b9 $db
    ld   A, H                                          ;; 01:449f $7c
    ld   [wDBBA], A                                    ;; 01:44a0 $ea $ba $db
    ld   A, [wDBA9]                                    ;; 01:44a3 $fa $a9 $db
    and  A, $0f                                        ;; 01:44a6 $e6 $0f
    ld   L, A                                          ;; 01:44a8 $6f
    ld   H, $00                                        ;; 01:44a9 $26 $00
    ld   DE, wDBCB                                     ;; 01:44ab $11 $cb $db
    add  HL, DE                                        ;; 01:44ae $19
    ld   A, [wDBA9]                                    ;; 01:44af $fa $a9 $db
    and  A, $f0                                        ;; 01:44b2 $e6 $f0
    ld   [HL], A                                       ;; 01:44b4 $77
    ld   A, [wDBAA]                                    ;; 01:44b5 $fa $aa $db
    and  A, $01                                        ;; 01:44b8 $e6 $01
    call NZ, call_01_499f_ClearTilemapRegion                              ;; 01:44ba $c4 $9f $49
    ld   A, [wDBA8]                                    ;; 01:44bd $fa $a8 $db
    sub  A, $e0                                        ;; 01:44c0 $d6 $e0
    jr   C, .jr_01_44cd                                ;; 01:44c2 $38 $09
    ld   DE, .data_01_456b_MenuCommandJumpTable                             ;; 01:44c4 $11 $6b $45
    call call_00_0777                                  ;; 01:44c7 $cd $77 $07
    call call_00_0f22_JumpHL                                  ;; 01:44ca $cd $22 $0f
.jr_01_44cd:
    ld   A, [wDBAA]                                    ;; 01:44cd $fa $aa $db
    and  A, $02                                        ;; 01:44d0 $e6 $02
    call NZ, call_01_4875_ProcessTilemapOrCollectibles                              ;; 01:44d2 $c4 $75 $48
    ld   A, [wDBAA]                                    ;; 01:44d5 $fa $aa $db
    and  A, $20                                        ;; 01:44d8 $e6 $20
    jr   Z, .jr_01_448c                                ;; 01:44da $28 $b0
    ld   A, [wDBAA]                                    ;; 01:44dc $fa $aa $db
    and  A, $40                                        ;; 01:44df $e6 $40
    jp   NZ, .jp_01_4560                               ;; 01:44e1 $c2 $60 $45
    ld   HL, wDBA0                                     ;; 01:44e4 $21 $a0 $db
    ld   E, [HL]                                       ;; 01:44e7 $5e
    ld   D, $00                                        ;; 01:44e8 $16 $00
    inc  HL                                            ;; 01:44ea $23
    ld   L, [HL]                                       ;; 01:44eb $6e
    ld   H, D                                          ;; 01:44ec $62
    add  HL, HL                                        ;; 01:44ed $29
    add  HL, HL                                        ;; 01:44ee $29
    ld   C, L                                          ;; 01:44ef $4d
    ld   B, H                                          ;; 01:44f0 $44
    add  HL, HL                                        ;; 01:44f1 $29
    add  HL, HL                                        ;; 01:44f2 $29
    add  HL, BC                                        ;; 01:44f3 $09
    add  HL, DE                                        ;; 01:44f4 $19
    ld   DE, wD400_TileBuffer                                     ;; 01:44f5 $11 $00 $d4
    add  HL, DE                                        ;; 01:44f8 $19
    ld   A, [wDBAA]                                    ;; 01:44f9 $fa $aa $db
    and  A, $04                                        ;; 01:44fc $e6 $04
    jr   NZ, .jr_01_450d                               ;; 01:44fe $20 $0d
    ld   A, [wDB9E]                                    ;; 01:4500 $fa $9e $db
    ld   B, A                                          ;; 01:4503 $47
    ld   A, [wDB9F]                                    ;; 01:4504 $fa $9f $db
    ld   C, A                                          ;; 01:4507 $4f
    ld   DE, $1401                                     ;; 01:4508 $11 $01 $14
    jr   .jr_01_4518                                   ;; 01:450b $18 $0b
.jr_01_450d:
    ld   A, [wDB9E]                                    ;; 01:450d $fa $9e $db
    ld   C, A                                          ;; 01:4510 $4f
    ld   A, [wDB9F]                                    ;; 01:4511 $fa $9f $db
    ld   B, A                                          ;; 01:4514 $47
    ld   DE, $114                                      ;; 01:4515 $11 $14 $01
.jr_01_4518:
    push HL                                            ;; 01:4518 $e5
    push BC                                            ;; 01:4519 $c5
    ld   BC, $178                                      ;; 01:451a $01 $78 $01
    add  HL, BC                                        ;; 01:451d $09
    pop  BC                                            ;; 01:451e $c1
    push BC                                            ;; 01:451f $c5
    ld   A, [wDBA3]                                    ;; 01:4520 $fa $a3 $db
    cp   A, $ff                                        ;; 01:4523 $fe $ff
    jr   NZ, .jr_01_452e                               ;; 01:4525 $20 $07
    call call_00_0800                                  ;; 01:4527 $cd $00 $08
    pop  BC                                            ;; 01:452a $c1
    pop  HL                                            ;; 01:452b $e1
    jr   .jr_01_4546                                   ;; 01:452c $18 $18
.jr_01_452e:
    push BC                                            ;; 01:452e $c5
    push DE                                            ;; 01:452f $d5
    push DE                                            ;; 01:4530 $d5
    push HL                                            ;; 01:4531 $e5
    ld   D, $00                                        ;; 01:4532 $16 $00
.jr_01_4534:
    ld   [HL], A                                       ;; 01:4534 $77
    add  HL, DE                                        ;; 01:4535 $19
    dec  B                                             ;; 01:4536 $05
    jr   NZ, .jr_01_4534                               ;; 01:4537 $20 $fb
    pop  HL                                            ;; 01:4539 $e1
    pop  DE                                            ;; 01:453a $d1
    ld   E, D                                          ;; 01:453b $5a
    ld   D, $00                                        ;; 01:453c $16 $00
    add  HL, DE                                        ;; 01:453e $19
    pop  DE                                            ;; 01:453f $d1
    pop  BC                                            ;; 01:4540 $c1
    dec  C                                             ;; 01:4541 $0d
    jr   NZ, .jr_01_452e                               ;; 01:4542 $20 $ea
    pop  BC                                            ;; 01:4544 $c1
    pop  HL                                            ;; 01:4545 $e1
.jr_01_4546:
    ld   A, [wDBA2]                                    ;; 01:4546 $fa $a2 $db
.jr_01_4549:
    push BC                                            ;; 01:4549 $c5
    push DE                                            ;; 01:454a $d5
    push DE                                            ;; 01:454b $d5
    push HL                                            ;; 01:454c $e5
    ld   D, $00                                        ;; 01:454d $16 $00
.jr_01_454f:
    ld   [HL], A                                       ;; 01:454f $77
    inc  A                                             ;; 01:4550 $3c
    add  HL, DE                                        ;; 01:4551 $19
    dec  B                                             ;; 01:4552 $05
    jr   NZ, .jr_01_454f                               ;; 01:4553 $20 $fa
    pop  HL                                            ;; 01:4555 $e1
    pop  DE                                            ;; 01:4556 $d1
    ld   E, D                                          ;; 01:4557 $5a
    ld   D, $00                                        ;; 01:4558 $16 $00
    add  HL, DE                                        ;; 01:455a $19
    pop  DE                                            ;; 01:455b $d1
    pop  BC                                            ;; 01:455c $c1
    dec  C                                             ;; 01:455d $0d
    jr   NZ, .jr_01_4549                               ;; 01:455e $20 $e9
.jp_01_4560:
    ld   A, [wDBAA]                                    ;; 01:4560 $fa $aa $db
    and  A, $80                                        ;; 01:4563 $e6 $80
    ret  Z                                             ;; 01:4565 $c8
    ld   C, $09                                        ;; 01:4566 $0e $09
    jp   call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 01:4568 $c3 $6a $0a
.data_01_456b_MenuCommandJumpTable: ; probably menutype jump table
; Behavior:
; List of function pointers (call_01_458d_MenuHandler_LoadAssetsAndJump, call_01_4599_MenuHandler_LoadAssetsAndJump, etc.) for specific menu command handlers.
; Likely Purpose: Dispatch table for specialized menu drawing or behavior.
    dw   call_01_458d_MenuHandler_LoadAssetsAndJump                                      ;; 01:456b ??
    dw   call_01_4599_MenuHandler_LoadAssetsAndJump                                  ;; 01:456d pP
    dw   call_01_45a5_MenuHandler_LoadBgPalettesAndMap                                  ;; 01:456f pP
    dw   call_01_466f_MenuState_LoadAndDrawA                                  ;; 01:4571 pP
    dw   call_01_4675_MenuState_LoadAndDrawB                                  ;; 01:4573 pP
    dw   call_01_467b_MenuState_UpdateLevelCursor                                  ;; 01:4575 pP
    dw   call_01_46d4_MenuState_InitSelectionScreen                                  ;; 01:4577 pP
    dw   call_01_46f9_ResetTemporaryFlags                                  ;; 01:4579 pP
    dw   call_01_470c_MenuState_DispatchAndDraw                                  ;; 01:457b pP
    dw   call_01_4760_MenuState_SubmenuHandler                                  ;; 01:457d pP
    dw   call_01_477b_MenuState_NoOp                                      ;; 01:457f ??
    dw   call_01_477c_DrawMenuNumberSprite                                  ;; 01:4581 pP
    dw   call_01_47aa_StoreCurrentMenuIndex                                  ;; 01:4583 pP
    dw   call_01_47b1_LoadMenuConfigData                                  ;; 01:4585 pP
    dw   call_01_480c_MenuState_DrawWithOffset
    dw   call_01_480c_MenuState_Empty
    dw   call_01_4826_MenuState_UpdateCursorAlt

call_01_458d_MenuHandler_LoadAssetsAndJump:
; Behavior:
; Copy data_01_6f39 to VRAM using wDBA7 and then jump to call_01_4d03_StreamTilemapBlockToBg.
; Likely Purpose: Load specific menu graphics and branch to a menu update routine.
    ld   a,[wDBA7]
    ld   de,data_01_6f39
    call call_00_0777
    jp   call_01_4d03_StreamTilemapBlockToBg

call_01_4599_MenuHandler_LoadAssetsAndJump:
; Behavior:
; same as above
    ld   A, [wDBA7]                                    ;; 01:4599 $fa $a7 $db
    ld   DE, data_01_6f39                              ;; 01:459c $11 $39 $6f
    call call_00_0777                                  ;; 01:459f $cd $77 $07
    jp   call_01_4d03_StreamTilemapBlockToBg                                    ;; 01:45a2 $c3 $03 $4d

call_01_45a5_MenuHandler_LoadBgPalettesAndMap:
; Behavior:
; Copies background palettes from .data_01_45ef to VRAM, uses wDB6C_CurrentMapId for 
; selecting additional data, then calls helper functions (call_01_4ce5_ComputeTilemapBlockOffset) to set up the background tile map.
; Likely Purpose: Initialize a menu’s background palettes and map tiles.
    ld   HL, .data_01_45ef                             ;; 01:45a5 $21 $ef $45
    ld   DE, wDCEA_BgPalettes                                     ;; 01:45a8 $11 $ea $dc
    ld   BC, $80                                       ;; 01:45ab $01 $80 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:45ae $cd $6e $07
    ld   A, [wDB6C_CurrentMapId]                                    ;; 01:45b1 $fa $6c $db
    ld   DE, $b01                                      ;; 01:45b4 $11 $01 $0b
    call call_00_0777                                  ;; 01:45b7 $cd $77 $07
    ld   DE, $330                                      ;; 01:45ba $11 $30 $03
    add  HL, DE                                        ;; 01:45bd $19
    ld   DE, wDD0A_BgPalettes                                     ;; 01:45be $11 $0a $dd
    ld   BC, $20                                       ;; 01:45c1 $01 $20 $00
    ld   A, $1f                                        ;; 01:45c4 $3e $1f
    call call_00_075f_SwitchBankAndCopyBCBytesFromHLToDE                                  ;; 01:45c6 $cd $5f $07
    ld   A, [wDB6C_CurrentMapId]                                    ;; 01:45c9 $fa $6c $db
    ld   DE, $b01                                      ;; 01:45cc $11 $01 $0b
    call call_00_0777                                  ;; 01:45cf $cd $77 $07
    ld   A, [wDBA6]                                    ;; 01:45d2 $fa $a6 $db
    ld   [wDBA2], A                                    ;; 01:45d5 $ea $a2 $db
    ld   A, $08                                        ;; 01:45d8 $3e $08
    ld   [wDB9E], A                                    ;; 01:45da $ea $9e $db
    ld   A, $06                                        ;; 01:45dd $3e $06
    ld   [wDB9F], A                                    ;; 01:45df $ea $9f $db
    push HL                                            ;; 01:45e2 $e5
    call call_01_4ce5_ComputeTilemapBlockOffset                                  ;; 01:45e3 $cd $e5 $4c
    pop  HL                                            ;; 01:45e6 $e1
    ld   DE, $c010                                     ;; 01:45e7 $11 $10 $c0 ; wC000_BgMapTileIds
    ld   A, $1f                                        ;; 01:45ea $3e $1f
    jp   call_00_075f_SwitchBankAndCopyBCBytesFromHLToDE                                  ;; 01:45ec $c3 $5f $07
.data_01_45ef:
    db   $00, $00, $00, $40, $ff, $03, $ff, $7f        ;; 01:45ef ........
    db   $00, $40, $ff, $03, $73, $02, $29, $01        ;; 01:45f7 ........
    db   $00, $40, $bf, $1e, $fa, $11, $2d, $11        ;; 01:45ff ........
    db   $00, $00, $00, $40, $ff, $7f, $80, $03        ;; 01:4607 ........
    db   $00, $40, $00, $00, $73, $4e, $1f, $00        ;; 01:460f ........
    db   $00, $40, $00, $00, $1f, $00, $ff, $03        ;; 01:4617 ........
    db   $00, $40, $00, $00, $60, $02, $9c, $03        ;; 01:461f ........
    db   $00, $40, $00, $00, $ff, $03, $e0, $03        ;; 01:4627 ........

    db   $00, $00, $80, $00, $20, $02, $20, $03        ;; 01:462f ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4637 ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:463f ........
    db   $00, $00, $00, $00, $73, $4e, $1f, $00        ;; 01:4647 ........
    db   $00, $00, $ef, $3d, $f7, $5e, $ff, $7f        ;; 01:464f ........
    db   $00, $00, $ef, $01, $f7, $02, $ff, $03        ;; 01:4657 ........
    db   $00, $00, $00, $00, $20, $03, $bf, $0b        ;; 01:465f ........
    db   $00, $00, $1f, $00, $ff, $01, $7f, $03        ;; 01:4667 ........

call_01_466f_MenuState_LoadAndDrawA:
; Description: Calls a subroutine at 4B22 to prepare or select some data, then jumps to a common 
; rendering/processing routine at 4CFA. Likely a simple wrapper for a specific menu/page state.
    call call_01_4b22_GetLevelDataBasePtr                                  ;; 01:466f $cd $22 $4b
    jp   call_01_4cfa_SetStreamPointerHL                                  ;; 01:4672 $c3 $fa $4c

call_01_4675_MenuState_LoadAndDrawB:
; Description: Same structure as above but uses 4B2A for setup. 
; Probably a different page/state initialization before rendering.
    call call_01_4b2a_GetLevelDataOffsetA                                  ;; 01:4675 $cd $2a $4b
    jp   call_01_4cfa_SetStreamPointerHL                                  ;; 01:4678 $c3 $fa $4c

call_01_467b_MenuState_UpdateLevelCursor:
; Description: Uses wDBA7 (likely current menu index) and wDB6C_CurrentMapId to compute bitmask checks, 
; updates several wDA?? variables (cursor positions, palette/offset values), calls 4C7E to draw, 
; then jumps to common rendering at 4CFA.
    ld   HL, wDBA7                                     ;; 01:467b $21 $a7 $db
    ld   L, [HL]                                       ;; 01:467e $6e
    ld   H, $00                                        ;; 01:467f $26 $00
    ld   DE, .data_01_46d1                             ;; 01:4681 $11 $d1 $46
    add  HL, DE                                        ;; 01:4684 $19
    ld   C, [HL]                                       ;; 01:4685 $4e
    ld   HL, wDB6C_CurrentMapId                                     ;; 01:4686 $21 $6c $db
    ld   L, [HL]                                       ;; 01:4689 $6e
    ld   H, $00                                        ;; 01:468a $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 01:468c $11 $5c $dc
    add  HL, DE                                        ;; 01:468f $19
    ld   A, [HL]                                       ;; 01:4690 $7e
    and  A, C                                          ;; 01:4691 $a1
    ld   C, $e4                                        ;; 01:4692 $0e $e4
    jr   NZ, .jr_01_4698                               ;; 01:4694 $20 $02
    ld   C, $e8                                        ;; 01:4696 $0e $e8
.jr_01_4698:
    ld   A, C                                          ;; 01:4698 $79
    ld   [wDADF], A                                    ;; 01:4699 $ea $df $da
    ld   A, [wDBA1]                                    ;; 01:469c $fa $a1 $db
    add  A, $02                                        ;; 01:469f $c6 $02
    add  A, A                                          ;; 01:46a1 $87
    add  A, A                                          ;; 01:46a2 $87
    add  A, A                                          ;; 01:46a3 $87
    ld   [wDADD], A                                    ;; 01:46a4 $ea $dd $da
    ld   A, [wDBA0]                                    ;; 01:46a7 $fa $a0 $db
    inc  A                                             ;; 01:46aa $3c
    sub  A, $02                                        ;; 01:46ab $d6 $02
    add  A, A                                          ;; 01:46ad $87
    add  A, A                                          ;; 01:46ae $87
    add  A, A                                          ;; 01:46af $87
    ld   [wDADE], A                                    ;; 01:46b0 $ea $de $da
    ld   A, $03                                        ;; 01:46b3 $3e $03
    ld   [wDAE0], A                                    ;; 01:46b5 $ea $e0 $da
    ld   A, [wDBA7]                                    ;; 01:46b8 $fa $a7 $db
    add  A, A                                          ;; 01:46bb $87
    add  A, A                                          ;; 01:46bc $87
    add  A, $04                                        ;; 01:46bd $c6 $04
    ld   [wDBDB], A                                    ;; 01:46bf $ea $db $db
    ld   BC, $202                                      ;; 01:46c2 $01 $02 $02
    call call_01_4c7e_CopyTextBlockToBuffer                                  ;; 01:46c5 $cd $7e $4c
    ld   A, [wDBA7]                                    ;; 01:46c8 $fa $a7 $db
    call call_01_4b32_GetLevelDataSubsectionPtr                                  ;; 01:46cb $cd $32 $4b
    jp   call_01_4cfa_SetStreamPointerHL                                  ;; 01:46ce $c3 $fa $4c
.data_01_46d1:
    db   $01, $02, $04                                 ;; 01:46d1 ...

call_01_46d4_MenuState_InitSelectionScreen:
; Description: Loads menu assets via call_01_4599, clears/sets wDBBF–wDBC7 control values, 
; then jumps to 4BB8 for rendering or state change. Likely initializes a menu selection.
    call call_01_4599_MenuHandler_LoadAssetsAndJump                                  ;; 01:46d4 $cd $99 $45
    xor  A, A                                          ;; 01:46d7 $af
    ld   [wDBBF], A                                    ;; 01:46d8 $ea $bf $db
    ld   A, [wDB9E]                                    ;; 01:46db $fa $9e $db
    ld   [wDBC4], A                                    ;; 01:46de $ea $c4 $db
    ld   A, [wDB9F]                                    ;; 01:46e1 $fa $9f $db
    ld   [wDBC5], A                                    ;; 01:46e4 $ea $c5 $db
    ld   A, $ff                                        ;; 01:46e7 $3e $ff
    ld   [wDBC6], A                                    ;; 01:46e9 $ea $c6 $db
    ld   A, [wDBA7]                                    ;; 01:46ec $fa $a7 $db
    sub  A, $00                                        ;; 01:46ef $d6 $00
    add  A, $00                                        ;; 01:46f1 $c6 $00
    ld   [wDBC7], A                                    ;; 01:46f3 $ea $c7 $db
    jp   call_01_4bb8_UpdateInterpolationStep                                  ;; 01:46f6 $c3 $b8 $4b

call_01_46f9_ResetTemporaryFlags:
; Description: Clears a block of wDBE3–wDBE7 flags and sets wDBE3=1. 
; Likely resets some state variables (e.g., reset counters or flags).
    xor  A, A                                          ;; 01:46f9 $af
    ld   [wDBE4], A                                    ;; 01:46fa $ea $e4 $db
    ld   [wDBE5], A                                    ;; 01:46fd $ea $e5 $db
    ld   [wDBE6], A                                    ;; 01:4700 $ea $e6 $db
    ld   [wDBE7], A                                    ;; 01:4703 $ea $e7 $db
    ld   A, $01                                        ;; 01:4706 $3e $01
    ld   [wDBE3], A                                    ;; 01:4708 $ea $e3 $db
    ret                                                ;; 01:470b $c9

call_01_470c_MenuState_DispatchAndDraw:
; Description: Writes $80 to wDADD, calls a state handler table (4722), conditionally triggers 4D49 if 
; a flag is set, then loads data_01_4e97 and jumps to 4CFA. Acts as a generic dispatcher.
    ld   HL, wDADD                                     ;; 01:470c $21 $dd $da
    ld   [HL], $80                                     ;; 01:470f $36 $80
    call call_01_4722_MenuStateHandlerTable                                  ;; 01:4711 $cd $22 $47
    ld   HL, wDADD                                     ;; 01:4714 $21 $dd $da
    bit  7, [HL]                                       ;; 01:4717 $cb $7e
    call NZ, call_01_4d49_FormatDecimalToAsciiDigits                              ;; 01:4719 $c4 $49 $4d
    ld   HL, data_01_4e97                              ;; 01:471c $21 $97 $4e
    jp   call_01_4cfa_SetStreamPointerHL                                  ;; 01:471f $c3 $fa $4c

call_01_4722_MenuStateHandlerTable:
; Description: Table-based dispatcher: uses wDBA7 as index to pick one of several subroutines (.data_01_472c). 
; Contains inline small handlers (.4744, .4748, .474c, etc.) that return values or constants.
    ld   A, [wDBA7]                                    ;; 01:4722 $fa $a7 $db
    ld   DE, .data_01_472c                             ;; 01:4725 $11 $2c $47
    call call_00_0777                                  ;; 01:4728 $cd $77 $07
    jp   HL                                            ;; 01:472b $e9
.data_01_472c:
    dw   call_01_4acf_CountCollectedBitsForLevel                                  ;; 01:472c pP
    dw   call_01_4b0a_CountLowBitsForLevel                                  ;; 01:472e pP
    dw   call_01_4af9_IsLevelFlag4Set                                  ;; 01:4730 pP
    dw   .call_01_4744                                 ;; 01:4732 pP
    dw   call_01_4ae7_CountLevelsWithFlag4                                  ;; 01:4734 pP
    dw   .call_01_4748                                 ;; 01:4736 pP
    dw   call_01_4ab9_CountSetBitsInFlags                                  ;; 01:4738 pP
    dw   .call_01_474c                                 ;; 01:473a pP
    dw   .call_01_4756                                 ;; 01:473c pP
    dw   .call_01_4759                                 ;; 01:473e pP
    dw   .call_01_475c                                 ;; 01:4740 pP
    dw   call_00_2f34_CountActiveCollectibles                                      ;; 01:4742 ??
.call_01_4744:
    ld   A, [wDC68_CollectibleCount]                                    ;; 01:4744 $fa $68 $dc
    ret                                                ;; 01:4747 $c9
.call_01_4748:
    ld   A, [wDCAF]                                    ;; 01:4748 $fa $af $dc
    ret                                                ;; 01:474b $c9
.call_01_474c:
    ld   A, [wDC1E_CurrentLevelNumber]                                    ;; 01:474c $fa $1e $dc
    and  A, A                                          ;; 01:474f $a7
    ld   A, $01                                        ;; 01:4750 $3e $01
    ret  Z                                             ;; 01:4752 $c8
    ld   A, $04                                        ;; 01:4753 $3e $04
    ret                                                ;; 01:4755 $c9
.call_01_4756:
    ld   A, $03                                        ;; 01:4756 $3e $03
    ret                                                ;; 01:4758 $c9
.call_01_4759:
    ld   A, $01                                        ;; 01:4759 $3e $01
    ret                                                ;; 01:475b $c9
.call_01_475c:
    ld   A, [wDC4E_PlayerLivesRemaining]                                    ;; 01:475c $fa $4e $dc
    ret                                                ;; 01:475f $c9

call_01_4760_MenuState_SubmenuHandler:
; Description: If wDBA6 is nonzero, copies it and wDBA7 to wDBDE/DBDF, 
; then dispatches via table at data_01_5b61 and jumps to 4C45. Likely another state handler for sub-menus.
    ld   A, [wDBA6]                                    ;; 01:4760 $fa $a6 $db
    and  A, A                                          ;; 01:4763 $a7
    jr   Z, .jr_01_476f                                ;; 01:4764 $28 $09
    ld   [wDBDE], A                                    ;; 01:4766 $ea $de $db
    ld   A, [wDBA7]                                    ;; 01:4769 $fa $a7 $db
    ld   [wDBDF], A                                    ;; 01:476c $ea $df $db
.jr_01_476f:
    ld   A, [wDBA7]                                    ;; 01:476f $fa $a7 $db
    ld   DE, data_01_5b61                              ;; 01:4772 $11 $61 $5b
    call call_00_0777                                  ;; 01:4775 $cd $77 $07
    jp   call_01_4c45_ParseAndLoadTextIntoBuffer                                  ;; 01:4778 $c3 $45 $4c

call_01_477b_MenuState_NoOp:
; Description: Empty ret. Likely a placeholder or unused state.
    ret                                           ;; 01:477b ?

call_01_477c_DrawMenuNumberSprite:
; Description: Uses wDBA7 to compute sprite data offsets into wC980_NumberSprites, 
;then uses wDB7E to pick a number graphic, combines with data_01_66f9, and jumps to jp_00_0bcf_CopyBlock16BytesLoop (sprite draw). Likely draws a numeric value (e.g., score).
    ld   HL, wDBA7                                     ;; 01:477c $21 $a7 $db
    ld   L, [HL]                                       ;; 01:477f $6e
    ld   H, $00                                        ;; 01:4780 $26 $00
    add  HL, HL                                        ;; 01:4782 $29
    add  HL, HL                                        ;; 01:4783 $29
    add  HL, HL                                        ;; 01:4784 $29
    add  HL, HL                                        ;; 01:4785 $29
    add  HL, HL                                        ;; 01:4786 $29
    add  HL, HL                                        ;; 01:4787 $29
    ld   DE, wC980_NumberSprites                                     ;; 01:4788 $11 $80 $c9
    add  HL, DE                                        ;; 01:478b $19
    ld   E, L                                          ;; 01:478c $5d
    ld   D, H                                          ;; 01:478d $54
    ld   HL, wDBA7                                     ;; 01:478e $21 $a7 $db
    ld   L, [HL]                                       ;; 01:4791 $6e
    ld   H, $00                                        ;; 01:4792 $26 $00
    ld   BC, wDB7E                                     ;; 01:4794 $01 $7e $db
    add  HL, BC                                        ;; 01:4797 $09
    ld   L, [HL]                                       ;; 01:4798 $6e
    ld   H, $00                                        ;; 01:4799 $26 $00
    add  HL, HL                                        ;; 01:479b $29
    add  HL, HL                                        ;; 01:479c $29
    add  HL, HL                                        ;; 01:479d $29
    add  HL, HL                                        ;; 01:479e $29
    add  HL, HL                                        ;; 01:479f $29
    add  HL, HL                                        ;; 01:47a0 $29
    ld   BC, data_01_66f9                              ;; 01:47a1 $01 $f9 $66
    add  HL, BC                                        ;; 01:47a4 $09
    ld   B, $04                                        ;; 01:47a5 $06 $04
    jp   jp_00_0bcf_CopyBlock16BytesLoop                                    ;; 01:47a7 $c3 $cf $0b

call_01_47aa_StoreCurrentMenuIndex:
; Description: Copies wDBA7 to wDBDD. Probably stores the current selection.
    ld   A, [wDBA7]                                    ;; 01:47aa $fa $a7 $db
    ld   [wDBDD], A                                    ;; 01:47ad $ea $dd $db
    ret                                                ;; 01:47b0 $c9

call_01_47b1_LoadMenuConfigData:
; Description: Uses a jump table (.data_01_47c6) to pick a configuration, 
; copies 8 bytes into wDBB1, then jumps to jp_00_0781 (likely continues processing).
    ld   A, [wDBA7]                                    ;; 01:47b1 $fa $a7 $db
    ld   DE, .data_01_47c6                             ;; 01:47b4 $11 $c6 $47
    call call_00_0777                                  ;; 01:47b7 $cd $77 $07
    ld   DE, wDBB1                                     ;; 01:47ba $11 $b1 $db
    ld   BC, $08                                       ;; 01:47bd $01 $08 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:47c0 $cd $6e $07
    jp   jp_00_0781                                    ;; 01:47c3 $c3 $81 $07
.data_01_47c6:
    db   $d4, $47, $dc, $47, $e4, $47, $ec, $47        ;; 01:47c6 ..??....
    db   $f4, $47, $fc, $47, $04, $48, $00, $06        ;; 01:47ce ....??..
    db   $e0, $45, $00, $40, $e0, $05, $00, $06        ;; 01:47d6 ......??
    db   $a6, $48, $a6, $47, $00, $01, $01, $06        ;; 01:47de ??????..
    db   $fe, $56, $1e, $4a, $e0, $0c, $00, $06        ;; 01:47e6 ........
    db   $06, $66, $86, $60, $80, $05, $00, $06        ;; 01:47ee ........
    db   $66, $6b, $c6, $67, $a0, $03, $00, $06        ;; 01:47f6 ........
    db   $ce, $5e, $ce, $59, $00, $05, $01, $11        ;; 01:47fe ......??
    db   $90, $51, $00, $40, $90, $11

call_01_480c_MenuState_DrawWithOffset:
; Description: Writes $80 to wDADD, performs some setup with call_01_4ab9_CountSetBitsInFlags and 4acf, 
; adjusts wDADD based on result, then prepares data_01_4e97 and jumps to 4CFA. Similar to 470c but with extra processing.
    ld   hl,wDADD
    ld   [hl],$80
    ld   de,call_01_4ab9_CountSetBitsInFlags.jr_01_4ac3
    call call_00_0865_LoadFromTextBank1C
    call call_01_4acf_CountCollectedBitsForLevel
    add  a,$30
    ld   [wDADD],a
    ld   hl,data_01_4e97
    jp   call_01_4cfa_SetStreamPointerHL

call_01_480c_MenuState_Empty:
; Description: Empty return. Likely another placeholder.
    ret  

call_01_4826_MenuState_UpdateCursorAlt:
; Description: Almost identical to 467b but uses a different mask table (.data_01_4871) 
; and sets wDAE0=1 instead of 3. Computes positions/offsets and calls 4C7E for drawing.
; Suggested Name: MenuState_UpdateCursorAlt
    ld   hl,wDBA7
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
    ld   c,$E4
    jr   nz,.label4843
    ld   c,$E8
.label4843:
    ld   a,c
    ld   [wDADF],a
    ld   a,[wDBA1]
    add  a,$02
    add  a
    add  a
    add  a
    ld   [wDADD],a
    ld   a,[wDBA0]
    inc  a
    add  a
    add  a
    add  a
    ld   [wDADE],a
    ld   a,$01
    ld   [wDAE0],a
    ld   a,[wDBA7]
    add  a
    add  a
    add  a,$04
    ld   [wDBDB],a
    ld   bc,$0202
    jp   call_01_4c7e_CopyTextBlockToBuffer
.data_01_4871:
    db   $01, $02, $04, $08             ;; 01:486e ???????

call_01_4875_ProcessTilemapOrCollectibles:
; Description: Loads object/sprite data from a table into wDBAB, calls call_01_49bb_FormatAndPaginateText for setup, 
; iterates through tile data at wDBA7, performs collision/bitmask checks, updates wDBA4 and wDBA5, 
; and repeatedly calls call_01_48cd_TilemapXorCopy. Appears to process tilemap collisions or update collectible graphics.
    ld   HL, wDBA6                                     ;; 01:4875 $21 $a6 $db
    ld   L, [HL]                                       ;; 01:4878 $6e
    ld   H, $00                                        ;; 01:4879 $26 $00
    add  HL, HL                                        ;; 01:487b $29
    add  HL, HL                                        ;; 01:487c $29
    add  HL, HL                                        ;; 01:487d $29
    ld   DE, data_01_5b77                              ;; 01:487e $11 $77 $5b
    add  HL, DE                                        ;; 01:4881 $19
    ld   DE, wDBAB                                     ;; 01:4882 $11 $ab $db
    ld   BC, $06                                       ;; 01:4885 $01 $06 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4888 $cd $6e $07
    call call_01_49bb_FormatAndPaginateText                                  ;; 01:488b $cd $bb $49
.jr_01_488e:
    ld   HL, wDBA7                                     ;; 01:488e $21 $a7 $db
    ld   E, [HL]                                       ;; 01:4891 $5e
    inc  HL                                            ;; 01:4892 $23
    ld   D, [HL]                                       ;; 01:4893 $56
    ld   A, [DE]                                       ;; 01:4894 $1a
    cp   A, $80                                        ;; 01:4895 $fe $80
    ret  Z                                             ;; 01:4897 $c8
    and  A, A                                          ;; 01:4898 $a7
    ret  Z                                             ;; 01:4899 $c8
    ld   A, [wDBE1]                                    ;; 01:489a $fa $e1 $db
    cp   A, $fe                                        ;; 01:489d $fe $fe
    jr   NZ, .jr_01_48ac                               ;; 01:489f $20 $0b
    call call_01_4a55_MeasureTextWidth                                  ;; 01:48a1 $cd $55 $4a
    ld   A, [wDB9E]                                    ;; 01:48a4 $fa $9e $db
    add  A, A                                          ;; 01:48a7 $87
    add  A, A                                          ;; 01:48a8 $87
    srl  C                                             ;; 01:48a9 $cb $39
    sub  A, C                                          ;; 01:48ab $91
.jr_01_48ac:
    ld   [wDBA4], A                                    ;; 01:48ac $ea $a4 $db
    ld   HL, wDBA7                                     ;; 01:48af $21 $a7 $db
    ld   A, [HL+]                                      ;; 01:48b2 $2a
    ld   H, [HL]                                       ;; 01:48b3 $66
    ld   L, A                                          ;; 01:48b4 $6f
.jr_01_48b5:
    ld   A, [HL+]                                      ;; 01:48b5 $2a
    push HL                                            ;; 01:48b6 $e5
    call call_01_48cd_TilemapXorCopy                                  ;; 01:48b7 $cd $cd $48
    pop  HL                                            ;; 01:48ba $e1
    bit  7, [HL]                                       ;; 01:48bb $cb $7e
    jr   Z, .jr_01_48b5                                ;; 01:48bd $28 $f6
    inc  HL                                            ;; 01:48bf $23
    call call_01_4cfa_SetStreamPointerHL                                  ;; 01:48c0 $cd $fa $4c
    ld   HL, wDBA5                                     ;; 01:48c3 $21 $a5 $db
    ld   A, [wDBE2]                                    ;; 01:48c6 $fa $e2 $db
    add  A, [HL]                                       ;; 01:48c9 $86
    ld   [HL], A                                       ;; 01:48ca $77
    jr   .jr_01_488e                                   ;; 01:48cb $18 $c1

call_01_48cd_TilemapXorCopy:
; Description: Performs bit manipulation to combine map data (uses wDBA4, wDBA5, wDB9E) with tile memory. 
; Does multiple shifts and XOR writes—likely draws or updates tile graphics.
    call call_01_4a7f_GetCharTileAddress                                  ;; 01:48cd $cd $7f $4a
    ld   A, [wDBA4]                                    ;; 01:48d0 $fa $a4 $db
    and  A, $07                                        ;; 01:48d3 $e6 $07
    ld   C, A                                          ;; 01:48d5 $4f
    ld   A, $08                                        ;; 01:48d6 $3e $08
    sub  A, C                                          ;; 01:48d8 $91
    ld   [wDBC8], A                                    ;; 01:48d9 $ea $c8 $db
    ld   A, [wDBA4]                                    ;; 01:48dc $fa $a4 $db
    and  A, $f8                                        ;; 01:48df $e6 $f8
    ld   L, A                                          ;; 01:48e1 $6f
    ld   H, $00                                        ;; 01:48e2 $26 $00
    add  HL, HL                                        ;; 01:48e4 $29
    ld   A, [wDBA5]                                    ;; 01:48e5 $fa $a5 $db
    and  A, $07                                        ;; 01:48e8 $e6 $07
    add  A, A                                          ;; 01:48ea $87
    ld   E, A                                          ;; 01:48eb $5f
    ld   D, $00                                        ;; 01:48ec $16 $00
    add  HL, DE                                        ;; 01:48ee $19
    ld   A, [wDBA5]                                    ;; 01:48ef $fa $a5 $db
    srl  A                                             ;; 01:48f2 $cb $3f
    srl  A                                             ;; 01:48f4 $cb $3f
    srl  A                                             ;; 01:48f6 $cb $3f
    jr   Z, .jr_01_490c                                ;; 01:48f8 $28 $12
    ld   C, A                                          ;; 01:48fa $4f
    ld   A, [wDB9E]                                    ;; 01:48fb $fa $9e $db
    swap A                                             ;; 01:48fe $cb $37
    ld   D, A                                          ;; 01:4900 $57
    and  A, $f0                                        ;; 01:4901 $e6 $f0
    ld   E, A                                          ;; 01:4903 $5f
    ld   A, D                                          ;; 01:4904 $7a
    and  A, $0f                                        ;; 01:4905 $e6 $0f
    ld   D, A                                          ;; 01:4907 $57
.jr_01_4908:
    add  HL, DE                                        ;; 01:4908 $19
    dec  C                                             ;; 01:4909 $0d
    jr   NZ, .jr_01_4908                               ;; 01:490a $20 $fc
.jr_01_490c:
    push HL                                            ;; 01:490c $e5
    call call_01_4cd4_GetBgTilemapPtrFromIndex                                  ;; 01:490d $cd $d4 $4c
    pop  HL                                            ;; 01:4910 $e1
    add  HL, DE                                        ;; 01:4911 $19
    ld   A, [wDBAF]                                    ;; 01:4912 $fa $af $db
.jr_01_4915:
    push AF                                            ;; 01:4915 $f5
    push HL                                            ;; 01:4916 $e5
    ld   A, L                                          ;; 01:4917 $7d
    ld   [wDBBB], A                                    ;; 01:4918 $ea $bb $db
    ld   A, H                                          ;; 01:491b $7c
    ld   [wDBBC], A                                    ;; 01:491c $ea $bc $db
    ld   A, [wDBB0]                                    ;; 01:491f $fa $b0 $db
.jr_01_4922:
    push AF                                            ;; 01:4922 $f5
    ld   A, [wDBBD]                                    ;; 01:4923 $fa $bd $db
    ld   L, A                                          ;; 01:4926 $6f
    ld   A, [wDBBE]                                    ;; 01:4927 $fa $be $db
    ld   H, A                                          ;; 01:492a $67
    ld   E, [HL]                                       ;; 01:492b $5e
    inc  HL                                            ;; 01:492c $23
    ld   C, [HL]                                       ;; 01:492d $4e
    inc  HL                                            ;; 01:492e $23
    ld   A, L                                          ;; 01:492f $7d
    ld   [wDBBD], A                                    ;; 01:4930 $ea $bd $db
    ld   A, H                                          ;; 01:4933 $7c
    ld   [wDBBE], A                                    ;; 01:4934 $ea $be $db
    ld   D, $00                                        ;; 01:4937 $16 $00
    ld   B, $00                                        ;; 01:4939 $06 $00
    ld   A, [wDBC8]                                    ;; 01:493b $fa $c8 $db
.jr_01_493e:
    sla  E                                             ;; 01:493e $cb $23
    rl   D                                             ;; 01:4940 $cb $12
    sla  C                                             ;; 01:4942 $cb $21
    rl   B                                             ;; 01:4944 $cb $10
    dec  A                                             ;; 01:4946 $3d
    jr   NZ, .jr_01_493e                               ;; 01:4947 $20 $f5
    ld   A, [wDBBB]                                    ;; 01:4949 $fa $bb $db
    ld   L, A                                          ;; 01:494c $6f
    ld   A, [wDBBC]                                    ;; 01:494d $fa $bc $db
    ld   H, A                                          ;; 01:4950 $67
    ld   A, D                                          ;; 01:4951 $7a
    xor  A, [HL]                                       ;; 01:4952 $ae
    ld   [HL+], A                                      ;; 01:4953 $22
    ld   A, B                                          ;; 01:4954 $78
    xor  A, [HL]                                       ;; 01:4955 $ae
    ld   [HL], A                                       ;; 01:4956 $77
    ld   A, E                                          ;; 01:4957 $7b
    ld   DE, $0f                                       ;; 01:4958 $11 $0f $00
    add  HL, DE                                        ;; 01:495b $19
    xor  A, [HL]                                       ;; 01:495c $ae
    ld   [HL+], A                                      ;; 01:495d $22
    ld   A, C                                          ;; 01:495e $79
    xor  A, [HL]                                       ;; 01:495f $ae
    ld   [HL], A                                       ;; 01:4960 $77
    ld   HL, wDBBB                                     ;; 01:4961 $21 $bb $db
    ld   A, [HL+]                                      ;; 01:4964 $2a
    ld   H, [HL]                                       ;; 01:4965 $66
    ld   L, A                                          ;; 01:4966 $6f
    inc  HL                                            ;; 01:4967 $23
    inc  HL                                            ;; 01:4968 $23
    ld   A, L                                          ;; 01:4969 $7d
    and  A, $0f                                        ;; 01:496a $e6 $0f
    jr   NZ, .jr_01_4980                               ;; 01:496c $20 $12
    ld   A, [wDB9E]                                    ;; 01:496e $fa $9e $db
    swap A                                             ;; 01:4971 $cb $37
    ld   D, A                                          ;; 01:4973 $57
    and  A, $f0                                        ;; 01:4974 $e6 $f0
    ld   E, A                                          ;; 01:4976 $5f
    ld   A, D                                          ;; 01:4977 $7a
    and  A, $0f                                        ;; 01:4978 $e6 $0f
    ld   D, A                                          ;; 01:497a $57
    add  HL, DE                                        ;; 01:497b $19
    ld   DE, hFFF0                                     ;; 01:497c $11 $f0 $ff
    add  HL, DE                                        ;; 01:497f $19
.jr_01_4980:
    ld   A, L                                          ;; 01:4980 $7d
    ld   [wDBBB], A                                    ;; 01:4981 $ea $bb $db
    ld   A, H                                          ;; 01:4984 $7c
    ld   [wDBBC], A                                    ;; 01:4985 $ea $bc $db
    pop  AF                                            ;; 01:4988 $f1
    dec  A                                             ;; 01:4989 $3d
    jr   NZ, .jr_01_4922                               ;; 01:498a $20 $96
    pop  HL                                            ;; 01:498c $e1
    ld   DE, $10                                       ;; 01:498d $11 $10 $00
    add  HL, DE                                        ;; 01:4990 $19
    pop  AF                                            ;; 01:4991 $f1
    dec  A                                             ;; 01:4992 $3d
    jr   NZ, .jr_01_4915                               ;; 01:4993 $20 $80
    ld   HL, wDBA4                                     ;; 01:4995 $21 $a4 $db
    ld   A, [wDBC9]                                    ;; 01:4998 $fa $c9 $db
    add  A, [HL]                                       ;; 01:499b $86
    inc  A                                             ;; 01:499c $3c
    ld   [HL], A                                       ;; 01:499d $77
    ret                                                ;; 01:499e $c9

call_01_499f_ClearTilemapRegion:
; Description: Calls routines to get a tile pointer, clears a rectangular block of VRAM 
; (loops writing zero). Used to blank out an area before redrawing.
    call call_01_4ce5_ComputeTilemapBlockOffset                                  ;; 01:499f $cd $e5 $4c
    ld   B, A                                          ;; 01:49a2 $47
    call call_01_4cd4_GetBgTilemapPtrFromIndex                                  ;; 01:49a3 $cd $d4 $4c
    xor  A, A                                          ;; 01:49a6 $af
.jr_01_49a7:
    ld   [HL+], A                                      ;; 01:49a7 $22
    ld   [HL+], A                                      ;; 01:49a8 $22
    ld   [HL+], A                                      ;; 01:49a9 $22
    ld   [HL+], A                                      ;; 01:49aa $22
    ld   [HL+], A                                      ;; 01:49ab $22
    ld   [HL+], A                                      ;; 01:49ac $22
    ld   [HL+], A                                      ;; 01:49ad $22
    ld   [HL+], A                                      ;; 01:49ae $22
    ld   [HL+], A                                      ;; 01:49af $22
    ld   [HL+], A                                      ;; 01:49b0 $22
    ld   [HL+], A                                      ;; 01:49b1 $22
    ld   [HL+], A                                      ;; 01:49b2 $22
    ld   [HL+], A                                      ;; 01:49b3 $22
    ld   [HL+], A                                      ;; 01:49b4 $22
    ld   [HL+], A                                      ;; 01:49b5 $22
    ld   [HL+], A                                      ;; 01:49b6 $22
    dec  B                                             ;; 01:49b7 $05
    jr   NZ, .jr_01_49a7                               ;; 01:49b8 $20 $ed
    ret                                                ;; 01:49ba $c9

call_01_49bb_FormatAndPaginateText:
; Description:
; Main text/selection loop. Loads a text bank (via call_00_0835_LoadFromTextBank1C), 
; repeatedly checks available text width (call_01_4a55_MeasureTextWidth), compares the width against the text buffer, and either:
; Scans backward to replace the last space with a break marker ($80) if overfull.
; Scans forward, invoking call_01_4cfa_SetStreamPointerHL to process text entries.
; Also updates indices (wDBA5, wDBB0, etc.) and computes offsets for selecting the next text chunk.
    call call_00_0835_LoadFromTextBank1C                                  ;; 01:49bb $cd $35 $08
.jr_01_49be:
    call call_01_4a55_MeasureTextWidth                                  ;; 01:49be $cd $55 $4a
    ld   HL, wDB9E                                     ;; 01:49c1 $21 $9e $db
    ld   L, [HL]                                       ;; 01:49c4 $6e
    ld   H, $00                                        ;; 01:49c5 $26 $00
    add  HL, HL                                        ;; 01:49c7 $29
    add  HL, HL                                        ;; 01:49c8 $29
    add  HL, HL                                        ;; 01:49c9 $29
    ld   A, L                                          ;; 01:49ca $7d
    sub  A, C                                          ;; 01:49cb $91
    ld   A, H                                          ;; 01:49cc $7c
    sbc  A, B                                          ;; 01:49cd $98
    jr   NC, .jr_01_49e5                               ;; 01:49ce $30 $15
    ld   HL, wDBA7                                     ;; 01:49d0 $21 $a7 $db
    ld   A, [HL+]                                      ;; 01:49d3 $2a
    ld   H, [HL]                                       ;; 01:49d4 $66
    ld   L, A                                          ;; 01:49d5 $6f
.jr_01_49d6:
    inc  HL                                            ;; 01:49d6 $23
    bit  7, [HL]                                       ;; 01:49d7 $cb $7e
    jr   Z, .jr_01_49d6                                ;; 01:49d9 $28 $fb
.jr_01_49db:
    dec  HL                                            ;; 01:49db $2b
    ld   A, [HL]                                       ;; 01:49dc $7e
    cp   A, $20                                        ;; 01:49dd $fe $20
    jr   NZ, .jr_01_49db                               ;; 01:49df $20 $fa
    ld   [HL], $80                                     ;; 01:49e1 $36 $80
    jr   .jr_01_49be                                   ;; 01:49e3 $18 $d9
.jr_01_49e5:
    ld   HL, wDBA7                                     ;; 01:49e5 $21 $a7 $db
    ld   A, [HL+]                                      ;; 01:49e8 $2a
    ld   H, [HL]                                       ;; 01:49e9 $66
    ld   L, A                                          ;; 01:49ea $6f
.jr_01_49eb:
    ld   A, [HL+]                                      ;; 01:49eb $2a
    bit  7, A                                          ;; 01:49ec $cb $7f
    jr   Z, .jr_01_49eb                                ;; 01:49ee $28 $fb
    ld   A, [HL]                                       ;; 01:49f0 $7e
    and  A, A                                          ;; 01:49f1 $a7
    jr   Z, .jr_01_4a06                                ;; 01:49f2 $28 $12
    call call_01_4cfa_SetStreamPointerHL                                  ;; 01:49f4 $cd $fa $4c
.jr_01_49f7:
    ld   A, [HL+]                                      ;; 01:49f7 $2a
    bit  7, A                                          ;; 01:49f8 $cb $7f
    jr   Z, .jr_01_49f7                                ;; 01:49fa $28 $fb
    ld   A, [HL]                                       ;; 01:49fc $7e
    and  A, A                                          ;; 01:49fd $a7
    jr   Z, .jr_01_49be                                ;; 01:49fe $28 $be
    dec  HL                                            ;; 01:4a00 $2b
    ld   [HL], $20                                     ;; 01:4a01 $36 $20
    inc  HL                                            ;; 01:4a03 $23
    jr   .jr_01_49f7                                   ;; 01:4a04 $18 $f1
.jr_01_4a06:
    ld   A, [wDBA4]                                    ;; 01:4a06 $fa $a4 $db
    ld   [wDBE1], A                                    ;; 01:4a09 $ea $e1 $db
    ld   HL, wDADD                                     ;; 01:4a0c $21 $dd $da
    call call_01_4cfa_SetStreamPointerHL                                  ;; 01:4a0f $cd $fa $4c
    ld   A, [wDBB0]                                    ;; 01:4a12 $fa $b0 $db
    inc  A                                             ;; 01:4a15 $3c
    ld   [wDBE2], A                                    ;; 01:4a16 $ea $e2 $db
    ld   A, [wDBA5]                                    ;; 01:4a19 $fa $a5 $db
    cp   A, $fe                                        ;; 01:4a1c $fe $fe
    ret  NZ                                            ;; 01:4a1e $c0
    ld   HL, wDBA7                                     ;; 01:4a1f $21 $a7 $db
    ld   A, [HL+]                                      ;; 01:4a22 $2a
    ld   H, [HL]                                       ;; 01:4a23 $66
    ld   L, A                                          ;; 01:4a24 $6f
    ld   C, $00                                        ;; 01:4a25 $0e $00
.jr_01_4a27:
    ld   A, [HL+]                                      ;; 01:4a27 $2a
    bit  7, A                                          ;; 01:4a28 $cb $7f
    jr   Z, .jr_01_4a27                                ;; 01:4a2a $28 $fb
    inc  C                                             ;; 01:4a2c $0c
    ld   A, [HL]                                       ;; 01:4a2d $7e
    and  A, A                                          ;; 01:4a2e $a7
    jr   NZ, .jr_01_4a27                               ;; 01:4a2f $20 $f6
    push BC                                            ;; 01:4a31 $c5
    ld   A, [wDBB0]                                    ;; 01:4a32 $fa $b0 $db
    ld   B, A                                          ;; 01:4a35 $47
    ld   A, [wDB9F]                                    ;; 01:4a36 $fa $9f $db
    add  A, A                                          ;; 01:4a39 $87
    add  A, A                                          ;; 01:4a3a $87
    add  A, A                                          ;; 01:4a3b $87
.jr_01_4a3c:
    sub  A, B                                          ;; 01:4a3c $90
    dec  C                                             ;; 01:4a3d $0d
    jr   NZ, .jr_01_4a3c                               ;; 01:4a3e $20 $fc
    pop  BC                                            ;; 01:4a40 $c1
    inc  C                                             ;; 01:4a41 $0c
    ld   B, $ff                                        ;; 01:4a42 $06 $ff
.jr_01_4a44:
    inc  B                                             ;; 01:4a44 $04
    sub  A, C                                          ;; 01:4a45 $91
    jr   NC, .jr_01_4a44                               ;; 01:4a46 $30 $fc
    ld   A, B                                          ;; 01:4a48 $78
    ld   [wDBA5], A                                    ;; 01:4a49 $ea $a5 $db
    ld   HL, wDBB0                                     ;; 01:4a4c $21 $b0 $db
    add  A, [HL]                                       ;; 01:4a4f $86
    inc  A                                             ;; 01:4a50 $3c
    ld   [wDBE2], A                                    ;; 01:4a51 $ea $e2 $db
    ret                                                ;; 01:4a54 $c9

call_01_4a55_MeasureTextWidth:
; Description:
; Traverses a text buffer pointed to by wDBA7, uses call_01_4df4_LookupTileFromTranslationTable to decode characters, 
; and sums their widths (via wDBAD as a font-width table) into BC. Stops at a high-bit 
; terminator and returns the accumulated width minus 1.
    ld   HL, wDBA7                                     ;; 01:4a55 $21 $a7 $db
    ld   A, [HL+]                                      ;; 01:4a58 $2a
    ld   H, [HL]                                       ;; 01:4a59 $66
    ld   L, A                                          ;; 01:4a5a $6f
    ld   BC, $00                                       ;; 01:4a5b $01 $00 $00
    bit  7, [HL]                                       ;; 01:4a5e $cb $7e
    ret  NZ                                            ;; 01:4a60 $c0
.jr_01_4a61:
    ld   A, [HL+]                                      ;; 01:4a61 $2a
    push HL                                            ;; 01:4a62 $e5
    call call_01_4df4_LookupTileFromTranslationTable                                  ;; 01:4a63 $cd $f4 $4d
    ld   HL, wDBAD                                     ;; 01:4a66 $21 $ad $db
    ld   E, [HL]                                       ;; 01:4a69 $5e
    inc  HL                                            ;; 01:4a6a $23
    ld   D, [HL]                                       ;; 01:4a6b $56
    ld   L, A                                          ;; 01:4a6c $6f
    ld   H, $00                                        ;; 01:4a6d $26 $00
    add  HL, DE                                        ;; 01:4a6f $19
    ld   A, [HL]                                       ;; 01:4a70 $7e
    add  A, C                                          ;; 01:4a71 $81
    ld   C, A                                          ;; 01:4a72 $4f
    ld   A, $00                                        ;; 01:4a73 $3e $00
    adc  A, B                                          ;; 01:4a75 $88
    ld   B, A                                          ;; 01:4a76 $47
    inc  BC                                            ;; 01:4a77 $03
    pop  HL                                            ;; 01:4a78 $e1
    bit  7, [HL]                                       ;; 01:4a79 $cb $7e
    jr   Z, .jr_01_4a61                                ;; 01:4a7b $28 $e4
    dec  BC                                            ;; 01:4a7d $0b
    ret                                                ;; 01:4a7e $c9

call_01_4a7f_GetCharTileAddress:
; Description:
; Given a character index from call_01_4df4_LookupTileFromTranslationTable, looks up a pointer into a character tilemap: 
; multiplies tile height/width (wDBB0, wDBAF) to compute an offset and stores the final address in wDBBD/wDBBE.
    call call_01_4df4_LookupTileFromTranslationTable                                  ;; 01:4a7f $cd $f4 $4d
    push AF                                            ;; 01:4a82 $f5
    ld   HL, wDBAD                                     ;; 01:4a83 $21 $ad $db
    ld   E, [HL]                                       ;; 01:4a86 $5e
    inc  HL                                            ;; 01:4a87 $23
    ld   D, [HL]                                       ;; 01:4a88 $56
    ld   L, A                                          ;; 01:4a89 $6f
    ld   H, $00                                        ;; 01:4a8a $26 $00
    add  HL, DE                                        ;; 01:4a8c $19
    ld   A, [HL]                                       ;; 01:4a8d $7e
    ld   [wDBC9], A                                    ;; 01:4a8e $ea $c9 $db
    ld   A, [wDBB0]                                    ;; 01:4a91 $fa $b0 $db
    add  A, A                                          ;; 01:4a94 $87
    ld   C, A                                          ;; 01:4a95 $4f
    ld   A, [wDBAF]                                    ;; 01:4a96 $fa $af $db
    ld   B, A                                          ;; 01:4a99 $47
    xor  A, A                                          ;; 01:4a9a $af
.jr_01_4a9b:
    add  A, C                                          ;; 01:4a9b $81
    dec  B                                             ;; 01:4a9c $05
    jr   NZ, .jr_01_4a9b                               ;; 01:4a9d $20 $fc
    ld   E, A                                          ;; 01:4a9f $5f
    ld   D, $00                                        ;; 01:4aa0 $16 $00
    ld   HL, wDBAB                                     ;; 01:4aa2 $21 $ab $db
    ld   A, [HL+]                                      ;; 01:4aa5 $2a
    ld   H, [HL]                                       ;; 01:4aa6 $66
    ld   L, A                                          ;; 01:4aa7 $6f
    pop  AF                                            ;; 01:4aa8 $f1
    and  A, A                                          ;; 01:4aa9 $a7
    jr   Z, .jr_01_4ab0                                ;; 01:4aaa $28 $04
.jr_01_4aac:
    add  HL, DE                                        ;; 01:4aac $19
    dec  A                                             ;; 01:4aad $3d
    jr   NZ, .jr_01_4aac                               ;; 01:4aae $20 $fc
.jr_01_4ab0:
    ld   A, L                                          ;; 01:4ab0 $7d
    ld   [wDBBD], A                                    ;; 01:4ab1 $ea $bd $db
    ld   A, H                                          ;; 01:4ab4 $7c
    ld   [wDBBE], A                                    ;; 01:4ab5 $ea $be $db
    ret                                                ;; 01:4ab8 $c9

call_01_4ab9_CountSetBitsInFlags:
; Description:
; Counts the total number of set bits (1s) in the 12 bytes at wDC5C_ProgressFlags. 
; Likely used to count collected items or flags.
    ld   HL, wDC5C_ProgressFlags                                     ;; 01:4ab9 $21 $5c $dc
    ld   B, $0c                                        ;; 01:4abc $06 $0c
    ld   C, $00                                        ;; 01:4abe $0e $00
.jr_01_4ac0:
    ld   A, [HL+]                                      ;; 01:4ac0 $2a
    ld   E, $04                                        ;; 01:4ac1 $1e $04
.jr_01_4ac3:
    rrca                                               ;; 01:4ac3 $0f
    jr   NC, .jr_01_4ac7                               ;; 01:4ac4 $30 $01
    inc  C                                             ;; 01:4ac6 $0c
.jr_01_4ac7:
    dec  E                                             ;; 01:4ac7 $1d
    jr   NZ, .jr_01_4ac3                               ;; 01:4ac8 $20 $f9
    dec  B                                             ;; 01:4aca $05
    jr   NZ, .jr_01_4ac0                               ;; 01:4acb $20 $f3
    ld   A, C                                          ;; 01:4acd $79
    ret                                                ;; 01:4ace $c9

call_01_4acf_CountCollectedBitsForLevel:
; Description:
; For the current level number, reads a byte from wDC5C_ProgressFlags + level, 
; counts how many of its low 4 bits are set.
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 01:4acf $21 $1e $dc
    ld   L, [HL]                                       ;; 01:4ad2 $6e
    ld   H, $00                                        ;; 01:4ad3 $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 01:4ad5 $11 $5c $dc
    add  HL, DE                                        ;; 01:4ad8 $19
    ld   A, [HL]                                       ;; 01:4ad9 $7e
    ld   C, $00                                        ;; 01:4ada $0e $00
    ld   B, $04                                        ;; 01:4adc $06 $04
.jr_01_4ade:
    rrca                                               ;; 01:4ade $0f
    jr   NC, .jr_01_4ae2                               ;; 01:4adf $30 $01
    inc  C                                             ;; 01:4ae1 $0c
.jr_01_4ae2:
    dec  B                                             ;; 01:4ae2 $05
    jr   NZ, .jr_01_4ade                               ;; 01:4ae3 $20 $f9
    ld   A, C                                          ;; 01:4ae5 $79
    ret                                                ;; 01:4ae6 $c9

call_01_4ae7_CountLevelsWithFlag4:
; Description:
; Counts how many of the first seven bytes in wDC5C_ProgressFlags have bit 4 set,
; probably counts levels with a specific completion flag.
    ld   HL, wDC5C_ProgressFlags                                     ;; 01:4ae7 $21 $5c $dc
    ld   B, $07                                        ;; 01:4aea $06 $07
    ld   C, $00                                        ;; 01:4aec $0e $00
.jr_01_4aee:
    ld   A, [HL+]                                      ;; 01:4aee $2a
    and  A, $10                                        ;; 01:4aef $e6 $10
    jr   Z, .jr_01_4af4                                ;; 01:4af1 $28 $01
    inc  C                                             ;; 01:4af3 $0c
.jr_01_4af4:
    dec  B                                             ;; 01:4af4 $05
    jr   NZ, .jr_01_4aee                               ;; 01:4af5 $20 $f7
    ld   A, C                                          ;; 01:4af7 $79
    ret                                                ;; 01:4af8 $c9

call_01_4af9_IsLevelFlag4Set:
; Description:
; Checks if the current level’s flag byte at wDC5C_ProgressFlags + level has bit 4 set, returning 1 if so.
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 01:4af9 $21 $1e $dc
    ld   L, [HL]                                       ;; 01:4afc $6e
    ld   H, $00                                        ;; 01:4afd $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 01:4aff $11 $5c $dc
    add  HL, DE                                        ;; 01:4b02 $19
    ld   A, [HL]                                       ;; 01:4b03 $7e
    and  A, $10                                        ;; 01:4b04 $e6 $10
    ret  Z                                             ;; 01:4b06 $c8
    ld   A, $01                                        ;; 01:4b07 $3e $01
    ret                                                ;; 01:4b09 $c9

call_01_4b0a_CountLowBitsForLevel:
; Description:
; Counts how many of the lowest three bits are set in the current level’s flag byte.
    ld   HL, wDC1E_CurrentLevelNumber                                     ;; 01:4b0a $21 $1e $dc
    ld   L, [HL]                                       ;; 01:4b0d $6e
    ld   H, $00                                        ;; 01:4b0e $26 $00
    ld   DE, wDC5C_ProgressFlags                                     ;; 01:4b10 $11 $5c $dc
    add  HL, DE                                        ;; 01:4b13 $19
    ld   A, [HL]                                       ;; 01:4b14 $7e
    ld   C, $00                                        ;; 01:4b15 $0e $00
    ld   B, $03                                        ;; 01:4b17 $06 $03
.jr_01_4b19:
    rlca                                               ;; 01:4b19 $07
    jr   NC, .jr_01_4b1d                               ;; 01:4b1a $30 $01
    inc  C                                             ;; 01:4b1c $0c
.jr_01_4b1d:
    dec  B                                             ;; 01:4b1d $05
    jr   NZ, .jr_01_4b19                               ;; 01:4b1e $20 $f9
    ld   A, C                                          ;; 01:4b20 $79
    ret                                                ;; 01:4b21 $c9

call_01_4b22_GetLevelDataBasePtr:
; Returns a pointer for a level’s base data.
    call call_01_4b43_LookupLevelBasePointer                                  ;; 01:4b22 $cd $43 $4b
    ld   DE, $00                                       ;; 01:4b25 $11 $00 $00
    add  HL, DE                                        ;; 01:4b28 $19
    ret                                                ;; 01:4b29 $c9

call_01_4b2a_GetLevelDataOffsetA:
; Returns pointer offset by $0A from base.
    call call_01_4b43_LookupLevelBasePointer                                  ;; 01:4b2a $cd $43 $4b
    ld   DE, $0a                                       ;; 01:4b2d $11 $0a $00
    add  HL, DE                                        ;; 01:4b30 $19
    ret                                                ;; 01:4b31 $c9

call_01_4b32_GetLevelDataSubsectionPtr:
; Returns pointer offset by $14 plus a scaled sub-offset based on A.
    call call_01_4b43_LookupLevelBasePointer                                  ;; 01:4b32 $cd $43 $4b
    ld   DE, $14                                       ;; 01:4b35 $11 $14 $00
    add  HL, DE                                        ;; 01:4b38 $19
    add  A, A                                          ;; 01:4b39 $87
    ld   E, A                                          ;; 01:4b3a $5f
    add  A, A                                          ;; 01:4b3b $87
    add  A, A                                          ;; 01:4b3c $87
    add  A, E                                          ;; 01:4b3d $83
    ld   E, A                                          ;; 01:4b3e $5f
    ld   D, $00                                        ;; 01:4b3f $16 $00
    add  HL, DE                                        ;; 01:4b41 $19
    ret                                                ;; 01:4b42 $c9

call_01_4b43_LookupLevelBasePointer:
; Description:
; Given wDB6C_CurrentMapId, doubles it and indexes into a table (.data_01_4b53) 
; to retrieve the base address of that level’s data.
    ld   HL, wDB6C_CurrentMapId                                     ;; 01:4b43 $21 $6c $db
    ld   L, [HL]                                       ;; 01:4b46 $6e
    ld   H, $00                                        ;; 01:4b47 $26 $00
    add  HL, HL                                        ;; 01:4b49 $29
    ld   DE, .data_01_4b53                             ;; 01:4b4a $11 $53 $4b
    add  HL, DE                                        ;; 01:4b4d $19
    ld   E, [HL]                                       ;; 01:4b4e $5e
    inc  HL                                            ;; 01:4b4f $23
    ld   H, [HL]                                       ;; 01:4b50 $66
    ld   L, E                                          ;; 01:4b51 $6b
    ret                                                ;; 01:4b52 $c9
.data_01_4b53:
    dw   $4ea1                                         ;; 01:4b53 wW
    dw   $4f69                                         ;; 01:4b55 wW
    dw   $51f7                                         ;; 01:4b57 wW
    dw   $54ef                                         ;; 01:4b59 wW
    dw   $57ba                                         ;; 01:4b5b wW
    dw   $5a5f                                         ;; 01:4b5d wW
    dw   $5d89                                         ;; 01:4b5f wW
    db   $06, $60, $4e, $61, $a4, $62, $a5, $64        ;; 01:4b61 ????????
    db   $3e, $66                                      ;; 01:4b69 ??

call_01_4b6b_StreamTileDataToBuffer:
; Description:
; Handles timed or input-triggered loading of map/tile data. Decrements a countdown (wDBDE), 
; checks input, fetches a data stream (data_01_5b61), and writes tile values into wD900 as a buffer.
    ld   HL, wDBDE                                     ;; 01:4b6b $21 $de $db
    ld   A, [HL]                                       ;; 01:4b6e $7e
    and  A, A                                          ;; 01:4b6f $a7
    ret  Z                                             ;; 01:4b70 $c8
    ld   A, [wDAD7_CurrentInputs]                                    ;; 01:4b71 $fa $d7 $da
    and  A, A                                          ;; 01:4b74 $a7
    jr   Z, .jr_01_4b79                                ;; 01:4b75 $28 $02
    ld   [HL], $01                                     ;; 01:4b77 $36 $01
.jr_01_4b79:
    dec  [HL]                                          ;; 01:4b79 $35
    ret  NZ                                            ;; 01:4b7a $c0
    ld   A, [wDBDF]                                    ;; 01:4b7b $fa $df $db
    jp   .jp_01_4b81                                   ;; 01:4b7e $c3 $81 $4b
.jp_01_4b81:
    ld   DE, data_01_5b61                              ;; 01:4b81 $11 $61 $5b
    call call_00_0777                                  ;; 01:4b84 $cd $77 $07
    ld   A, [HL+]                                      ;; 01:4b87 $2a
    cp   A, $ff                                        ;; 01:4b88 $fe $ff
    ret  Z                                             ;; 01:4b8a $c8
    push HL                                            ;; 01:4b8b $e5
    ld   L, A                                          ;; 01:4b8c $6f
    ld   H, $00                                        ;; 01:4b8d $26 $00
    add  HL, HL                                        ;; 01:4b8f $29
    add  HL, HL                                        ;; 01:4b90 $29
    ld   DE, wD900                                     ;; 01:4b91 $11 $00 $d9
    add  HL, DE                                        ;; 01:4b94 $19
    ld   E, L                                          ;; 01:4b95 $5d
    ld   D, H                                          ;; 01:4b96 $54
    pop  HL                                            ;; 01:4b97 $e1
.jr_01_4b98:
    ld   A, [HL+]                                      ;; 01:4b98 $2a
    cp   A, $ff                                        ;; 01:4b99 $fe $ff
    ret  Z                                             ;; 01:4b9b $c8
    ld   A, [HL+]                                      ;; 01:4b9c $2a
    ld   A, [HL+]                                      ;; 01:4b9d $2a
    ld   A, [HL+]                                      ;; 01:4b9e $2a
    ld   C, [HL]                                       ;; 01:4b9f $4e
    inc  HL                                            ;; 01:4ba0 $23
    ld   B, [HL]                                       ;; 01:4ba1 $46
    inc  HL                                            ;; 01:4ba2 $23
    srl  B                                             ;; 01:4ba3 $cb $38
    xor  A, A                                          ;; 01:4ba5 $af
.jr_01_4ba6:
    push BC                                            ;; 01:4ba6 $c5
.jr_01_4ba7:
    ld   [DE], A                                       ;; 01:4ba7 $12
    inc  DE                                            ;; 01:4ba8 $13
    ld   [DE], A                                       ;; 01:4ba9 $12
    inc  DE                                            ;; 01:4baa $13
    ld   [DE], A                                       ;; 01:4bab $12
    inc  DE                                            ;; 01:4bac $13
    ld   [DE], A                                       ;; 01:4bad $12
    inc  DE                                            ;; 01:4bae $13
    dec  B                                             ;; 01:4baf $05
    jr   NZ, .jr_01_4ba7                               ;; 01:4bb0 $20 $f5
    pop  BC                                            ;; 01:4bb2 $c1
    dec  C                                             ;; 01:4bb3 $0d
    jr   NZ, .jr_01_4ba6                               ;; 01:4bb4 $20 $f0
    jr   .jr_01_4b98                                   ;; 01:4bb6 $18 $e0

call_01_4bb8_UpdateInterpolationStep:
; Description:
; Calculates an interpolated point between two coordinates over time. Uses differences (wDB97–99, wDB96–98) 
; and step counts (wDBEC, wDBEB) to update wDBC0/wDBC1, stores control bytes (wDBC2/wDBC3), and handles 
; special cases when wDBC7 is $ff or $01.
    ld   A, [wDBC7]                                    ;; 01:4bb8 $fa $c7 $db
    cp   A, $ff                                        ;; 01:4bbb $fe $ff
    ret  Z                                             ;; 01:4bbd $c8
    ld   C, $fc                                        ;; 01:4bbe $0e $fc
    ld   B, $00                                        ;; 01:4bc0 $06 $00
    cp   A, $01                                        ;; 01:4bc2 $fe $01
    jr   NZ, .jr_01_4bd8                               ;; 01:4bc4 $20 $12
    call call_01_4de3_ComputeTilemapVramOffset                                  ;; 01:4bc6 $cd $e3 $4d
    ld   C, A                                          ;; 01:4bc9 $4f
    ld   A, [wDBDC]                                    ;; 01:4bca $fa $dc $db
    and  A, $10                                        ;; 01:4bcd $e6 $10
    jr   Z, .jr_01_4bd5                                ;; 01:4bcf $28 $04
    or   A, $03                                        ;; 01:4bd1 $f6 $03
    jr   .jr_01_4bd7                                   ;; 01:4bd3 $18 $02
.jr_01_4bd5:
    or   A, $02                                        ;; 01:4bd5 $f6 $02
.jr_01_4bd7:
    ld   B, A                                          ;; 01:4bd7 $47
.jr_01_4bd8:
    ld   HL, wDBC2                                     ;; 01:4bd8 $21 $c2 $db
    ld   [HL], C                                       ;; 01:4bdb $71
    ld   HL, wDBC3                                     ;; 01:4bdc $21 $c3 $db
    ld   [HL], B                                       ;; 01:4bdf $70
    ld   A, [wDBEC]                                    ;; 01:4be0 $fa $ec $db
    ld   C, A                                          ;; 01:4be3 $4f
    inc  C                                             ;; 01:4be4 $0c
    ld   A, [wDB99]                                    ;; 01:4be5 $fa $99 $db
    ld   B, A                                          ;; 01:4be8 $47
    ld   A, [wDB97]                                    ;; 01:4be9 $fa $97 $db
    sub  A, B                                          ;; 01:4bec $90
.jr_01_4bed:
    add  A, B                                          ;; 01:4bed $80
    dec  C                                             ;; 01:4bee $0d
    jr   NZ, .jr_01_4bed                               ;; 01:4bef $20 $fc
    ld   [wDBC0], A                                    ;; 01:4bf1 $ea $c0 $db
    ld   A, [wDBEB]                                    ;; 01:4bf4 $fa $eb $db
    ld   C, A                                          ;; 01:4bf7 $4f
    inc  C                                             ;; 01:4bf8 $0c
    ld   A, [wDB98]                                    ;; 01:4bf9 $fa $98 $db
    ld   B, A                                          ;; 01:4bfc $47
    ld   A, [wDB96]                                    ;; 01:4bfd $fa $96 $db
    sub  A, B                                          ;; 01:4c00 $90
.jr_01_4c01:
    add  A, B                                          ;; 01:4c01 $80
    dec  C                                             ;; 01:4c02 $0d
    jr   NZ, .jr_01_4c01                               ;; 01:4c03 $20 $fc
    ld   [wDBC1], A                                    ;; 01:4c05 $ea $c1 $db
    ld   HL, wDBBF                                     ;; 01:4c08 $21 $bf $db
    call call_01_4c45_ParseAndLoadTextIntoBuffer                                  ;; 01:4c0b $cd $45 $4c
    ld   A, [wDBC7]                                    ;; 01:4c0e $fa $c7 $db
    cp   A, $01                                        ;; 01:4c11 $fe $01
    ret  NZ                                            ;; 01:4c13 $c0
    ld   HL, wDBDB                                     ;; 01:4c14 $21 $db $db
    ld   A, [HL]                                       ;; 01:4c17 $7e
    inc  [HL]                                          ;; 01:4c18 $34
    ld   L, A                                          ;; 01:4c19 $6f
    ld   H, $00                                        ;; 01:4c1a $26 $00
    add  HL, HL                                        ;; 01:4c1c $29
    add  HL, HL                                        ;; 01:4c1d $29
    ld   DE, wD900                                     ;; 01:4c1e $11 $00 $d9
    add  HL, DE                                        ;; 01:4c21 $19
    ld   A, [wDBEE]                                    ;; 01:4c22 $fa $ee $db
    add  A, A                                          ;; 01:4c25 $87
    add  A, A                                          ;; 01:4c26 $87
    add  A, A                                          ;; 01:4c27 $87
    add  A, $18                                        ;; 01:4c28 $c6 $18
    ld   [HL+], A                                      ;; 01:4c2a $22
    ld   A, [wDBED]                                    ;; 01:4c2b $fa $ed $db
    ld   C, A                                          ;; 01:4c2e $4f
    add  A, A                                          ;; 01:4c2f $87
    add  A, A                                          ;; 01:4c30 $87
    add  A, A                                          ;; 01:4c31 $87
    add  A, $10                                        ;; 01:4c32 $c6 $10
    ld   [HL+], A                                      ;; 01:4c34 $22
    ld   A, [wDBEE]                                    ;; 01:4c35 $fa $ee $db
    add  A, A                                          ;; 01:4c38 $87
    add  A, A                                          ;; 01:4c39 $87
    add  A, A                                          ;; 01:4c3a $87
    add  A, A                                          ;; 01:4c3b $87
    add  A, C                                          ;; 01:4c3c $81
    add  A, $e0                                        ;; 01:4c3d $c6 $e0
    ld   [HL+], A                                      ;; 01:4c3f $22
    ld   A, [wDBC3]                                    ;; 01:4c40 $fa $c3 $db
    ld   [HL], A                                       ;; 01:4c43 $77
    ret                                                ;; 01:4c44 $c9

call_01_4c45_ParseAndLoadTextIntoBuffer:
; Description:
; Reads a sequence text records from memory until a $FF terminator. 
; For each record, extracts an ID, X/Y offsets (adjusted by $10/$08), attribute flags 
; (with optional lookup in wDAE1_TextBuffer), and a size (C,B). Calls call_01_4c7e_CopyTextBlockToBuffer to copy tile entries 
; into the staging buffer at wD900.
    ld   A, [HL+]                                      ;; 01:4c45 $2a
    cp   A, $ff                                        ;; 01:4c46 $fe $ff
    ret  Z                                             ;; 01:4c48 $c8
    ld   [wDBDB], A                                    ;; 01:4c49 $ea $db $db
.jr_01_4c4c:
    ld   A, [HL+]                                      ;; 01:4c4c $2a
    cp   A, $ff                                        ;; 01:4c4d $fe $ff
    ret  Z                                             ;; 01:4c4f $c8
    add  A, $10                                        ;; 01:4c50 $c6 $10
    ld   [wDADD], A                                    ;; 01:4c52 $ea $dd $da
    ld   A, [HL+]                                      ;; 01:4c55 $2a
    add  A, $08                                        ;; 01:4c56 $c6 $08
    ld   [wDADE], A                                    ;; 01:4c58 $ea $de $da
    ld   A, [HL+]                                      ;; 01:4c5b $2a
    bit  0, A                                          ;; 01:4c5c $cb $47
    jr   Z, .jr_01_4c6c                                ;; 01:4c5e $28 $0c
    push HL                                            ;; 01:4c60 $e5
    srl  A                                             ;; 01:4c61 $cb $3f
    ld   E, A                                          ;; 01:4c63 $5f
    ld   D, $00                                        ;; 01:4c64 $16 $00
    ld   HL, wDAE1_TextBuffer                                     ;; 01:4c66 $21 $e1 $da
    add  HL, DE                                        ;; 01:4c69 $19
    ld   A, [HL]                                       ;; 01:4c6a $7e
    pop  HL                                            ;; 01:4c6b $e1
.jr_01_4c6c:
    ld   [wDADF], A                                    ;; 01:4c6c $ea $df $da
    ld   A, [HL+]                                      ;; 01:4c6f $2a
    ld   [wDAE0], A                                    ;; 01:4c70 $ea $e0 $da
    ld   C, [HL]                                       ;; 01:4c73 $4e
    inc  HL                                            ;; 01:4c74 $23
    ld   B, [HL]                                       ;; 01:4c75 $46
    inc  HL                                            ;; 01:4c76 $23
    push HL                                            ;; 01:4c77 $e5
    call call_01_4c7e_CopyTextBlockToBuffer                                  ;; 01:4c78 $cd $7e $4c
    pop  HL                                            ;; 01:4c7b $e1
    jr   .jr_01_4c4c                                   ;; 01:4c7c $18 $ce

call_01_4c7e_CopyTextBlockToBuffer:
; Description:
; Copies a rectangular block of sprite/tile data into wD900. Uses wDBDB as a tile index, 
; increments coordinates, and fills multiple rows/columns according to width (B) and height (C).
    ld   HL, wDBDB                                     ;; 01:4c7e $21 $db $db
    ld   L, [HL]                                       ;; 01:4c81 $6e
    ld   H, $00                                        ;; 01:4c82 $26 $00
    add  HL, HL                                        ;; 01:4c84 $29
    add  HL, HL                                        ;; 01:4c85 $29
    ld   DE, wD900                                     ;; 01:4c86 $11 $00 $d9
    add  HL, DE                                        ;; 01:4c89 $19
    ld   A, [wDADD]                                    ;; 01:4c8a $fa $dd $da
.jr_01_4c8d:
    push BC                                            ;; 01:4c8d $c5
    push AF                                            ;; 01:4c8e $f5
    ld   [wDADD], A                                    ;; 01:4c8f $ea $dd $da
.jr_01_4c92:
    ld   A, [wDADD]                                    ;; 01:4c92 $fa $dd $da
    ld   [HL+], A                                      ;; 01:4c95 $22
    add  A, $08                                        ;; 01:4c96 $c6 $08
    ld   [wDADD], A                                    ;; 01:4c98 $ea $dd $da
    ld   A, [wDADE]                                    ;; 01:4c9b $fa $de $da
    ld   [HL+], A                                      ;; 01:4c9e $22
    ld   A, [wDADF]                                    ;; 01:4c9f $fa $df $da
    ld   [HL+], A                                      ;; 01:4ca2 $22
    inc  A                                             ;; 01:4ca3 $3c
    ld   [wDADF], A                                    ;; 01:4ca4 $ea $df $da
    ld   A, [wDAE0]                                    ;; 01:4ca7 $fa $e0 $da
    ld   [HL+], A                                      ;; 01:4caa $22
    ld   A, [wDBDB]                                    ;; 01:4cab $fa $db $db
    inc  A                                             ;; 01:4cae $3c
    ld   [wDBDB], A                                    ;; 01:4caf $ea $db $db
    dec  B                                             ;; 01:4cb2 $05
    jr   NZ, .jr_01_4c92                               ;; 01:4cb3 $20 $dd
    ld   A, [wDADE]                                    ;; 01:4cb5 $fa $de $da
    add  A, $08                                        ;; 01:4cb8 $c6 $08
    ld   [wDADE], A                                    ;; 01:4cba $ea $de $da
    pop  AF                                            ;; 01:4cbd $f1
    pop  BC                                            ;; 01:4cbe $c1
    dec  C                                             ;; 01:4cbf $0d
    jr   NZ, .jr_01_4c8d                               ;; 01:4cc0 $20 $cb
    ret                                                ;; 01:4cc2 $c9

call_01_4cc3_GetVramTilePtrFromIndex:
; Description:
; Computes a VRAM tile address by scaling wDBA2 by 16 (tile size in bytes) 
; and adding the base address $8000. Returns DE = tile address.
    ld   hl,wDBA2
    ld   l,[hl]
    ld   h,$00
    add  hl,hl
    add  hl,hl
    add  hl,hl
    add  hl,hl
    ld   de,_VRAM
    add  hl,de
    ld   e,l
    ld   d,h
    ret  

call_01_4cd4_GetBgTilemapPtrFromIndex:
; Description:
; Calculates a pointer into the background tilemap (wC000_BgMapTileIds) based on index wDBA2. 
; Performs several shifts to scale the index by tile size (×16) and returns DE = pointer.
    ld   HL, wDBA2                                     ;; 01:4cd4 $21 $a2 $db
    ld   L, [HL]                                       ;; 01:4cd7 $6e
    ld   H, $00                                        ;; 01:4cd8 $26 $00
    add  HL, HL                                        ;; 01:4cda $29
    add  HL, HL                                        ;; 01:4cdb $29
    add  HL, HL                                        ;; 01:4cdc $29
    add  HL, HL                                        ;; 01:4cdd $29
    ld   DE, wC000_BgMapTileIds                                     ;; 01:4cde $11 $00 $c0
    add  HL, DE                                        ;; 01:4ce1 $19
    ld   E, L                                          ;; 01:4ce2 $5d
    ld   D, H                                          ;; 01:4ce3 $54
    ret                                                ;; 01:4ce4 $c9

call_01_4ce5_ComputeTilemapBlockOffset:
; Description:
; Given width (C) and height (B) from wDB9E/wDB9F, computes a linear offset equal to width × height ×16 
; (via repeated addition and shifting) and returns BC = offset.
    ld   HL, wDB9E                                     ;; 01:4ce5 $21 $9e $db
    ld   C, [HL]                                       ;; 01:4ce8 $4e
    inc  HL                                            ;; 01:4ce9 $23
    ld   B, [HL]                                       ;; 01:4cea $46
    xor  A, A                                          ;; 01:4ceb $af
.jr_01_4cec:
    add  A, C                                          ;; 01:4cec $81
    dec  B                                             ;; 01:4ced $05
    jr   NZ, .jr_01_4cec                               ;; 01:4cee $20 $fc
    ld   L, A                                          ;; 01:4cf0 $6f
    ld   H, $00                                        ;; 01:4cf1 $26 $00
    add  HL, HL                                        ;; 01:4cf3 $29
    add  HL, HL                                        ;; 01:4cf4 $29
    add  HL, HL                                        ;; 01:4cf5 $29
    add  HL, HL                                        ;; 01:4cf6 $29
    ld   C, L                                          ;; 01:4cf7 $4d
    ld   B, H                                          ;; 01:4cf8 $44
    ret                                                ;; 01:4cf9 $c9

call_01_4cfa_SetStreamPointerHL:
; Description:
; Stores a pointer (HL) into wDBA7/wDBA8. Used by text or 
; sprite loaders to update the current stream position.
    ld   A, L                                          ;; 01:4cfa $7d
    ld   [wDBA7], A                                    ;; 01:4cfb $ea $a7 $db
    ld   A, H                                          ;; 01:4cfe $7c
    ld   [wDBA8], A                                    ;; 01:4cff $ea $a8 $db
    ret                                                ;; 01:4d02 $c9

call_01_4d03_StreamTilemapBlockToBg:
; Description:
; Loads width/height from a stream into wDB9E/F, computes a background tilemap address from wDBA6, 
; and copies a block of BC bytes from HL to DE if a nonzero flag is present. Handles staging of tilemap updates.
    ld   A, [wDBA6]                                    ;; 01:4d03 $fa $a6 $db
    ld   [wDBA2], A                                    ;; 01:4d06 $ea $a2 $db
    ld   A, [HL+]                                      ;; 01:4d09 $2a
    ld   [wDB9E], A                                    ;; 01:4d0a $ea $9e $db
    ld   A, [HL+]                                      ;; 01:4d0d $2a
    ld   [wDB9F], A                                    ;; 01:4d0e $ea $9f $db
    push HL                                            ;; 01:4d11 $e5
    call call_01_4ce5_ComputeTilemapBlockOffset                                  ;; 01:4d12 $cd $e5 $4c
    ld   HL, wDBA6                                     ;; 01:4d15 $21 $a6 $db
    ld   L, [HL]                                       ;; 01:4d18 $6e
    ld   H, $00                                        ;; 01:4d19 $26 $00
    add  HL, HL                                        ;; 01:4d1b $29
    add  HL, HL                                        ;; 01:4d1c $29
    add  HL, HL                                        ;; 01:4d1d $29
    add  HL, HL                                        ;; 01:4d1e $29
    ld   DE, wC000_BgMapTileIds                                     ;; 01:4d1f $11 $00 $c0
    add  HL, DE                                        ;; 01:4d22 $19
    ld   E, L                                          ;; 01:4d23 $5d
    ld   D, H                                          ;; 01:4d24 $54
    pop  HL                                            ;; 01:4d25 $e1
    ld   A, [HL+]                                      ;; 01:4d26 $2a
    and  A, A                                          ;; 01:4d27 $a7
    jp   Z, call_00_076e_CopyBCBytesFromHLToDE                               ;; 01:4d28 $ca $6e $07
    ret                                                ;; 01:4d2b $c9

call_01_4d2c_ProcessTileStreamingLoop:
; Description:
; Main tile-update loop: updates interpolation step, streams tile data to buffers, updates VRAM, 
; decrements wDBDC, filters inputs, and repeats until inputs clear.
    call call_01_4bb8_UpdateInterpolationStep                                  ;; 01:4d2c $cd $b8 $4b
    call call_01_4b6b_StreamTileDataToBuffer                                  ;; 01:4d2f $cd $6b $4b
    call call_00_0b92_WaitForInterrupt                                  ;; 01:4d32 $cd $92 $0b
    ld   HL, wDBDC                                     ;; 01:4d35 $21 $dc $db
    dec  [HL]                                          ;; 01:4d38 $35
    ld   A, [wDB94]                                    ;; 01:4d39 $fa $94 $db
    and  A, $01                                        ;; 01:4d3c $e6 $01
    ld   A, [wDAD7_CurrentInputs]                                    ;; 01:4d3e $fa $d7 $da
    jr   Z, .jr_01_4d45                                ;; 01:4d41 $28 $02
    and  A, $fe                                        ;; 01:4d43 $e6 $fe
.jr_01_4d45:
    and  A, A                                          ;; 01:4d45 $a7
    jr   NZ, call_01_4d2c_ProcessTileStreamingLoop                              ;; 01:4d46 $20 $e4
    ret                                                ;; 01:4d48 $c9

call_01_4d49_FormatDecimalToAsciiDigits:
; Description:
; Converts a value in A into three ASCII digits (hundreds, tens, ones), 
; writes them to wDADD (with $80 terminator), using $2F as prefill. 
; Essentially formats a decimal number for display.
    ld   HL, wDADD                                     ;; 01:4d49 $21 $dd $da
    cp   A, $0a                                        ;; 01:4d4c $fe $0a
    jr   C, .jr_01_4d68                                ;; 01:4d4e $38 $18
    cp   A, $64                                        ;; 01:4d50 $fe $64
    jr   C, .jr_01_4d5e                                ;; 01:4d52 $38 $0a
    ld   [HL], $2f                                     ;; 01:4d54 $36 $2f
.jr_01_4d56:
    inc  [HL]                                          ;; 01:4d56 $34
    sub  A, $64                                        ;; 01:4d57 $d6 $64
    jr   NC, .jr_01_4d56                               ;; 01:4d59 $30 $fb
    add  A, $64                                        ;; 01:4d5b $c6 $64
    inc  HL                                            ;; 01:4d5d $23
.jr_01_4d5e:
    ld   [HL], $2f                                     ;; 01:4d5e $36 $2f
.jr_01_4d60:
    inc  [HL]                                          ;; 01:4d60 $34
    sub  A, $0a                                        ;; 01:4d61 $d6 $0a
    jr   NC, .jr_01_4d60                               ;; 01:4d63 $30 $fb
    add  A, $0a                                        ;; 01:4d65 $c6 $0a
    inc  HL                                            ;; 01:4d67 $23
.jr_01_4d68:
    add  A, $30                                        ;; 01:4d68 $c6 $30
    ld   [HL+], A                                      ;; 01:4d6a $22
    ld   [HL], $80                                     ;; 01:4d6b $36 $80
    ret                                                ;; 01:4d6d $c9

call_01_4d6e_PrepareStreamingPointers:
; Description:
; Waits for wDBEF to clear, sets up several control flags (wDBEF–wDBF7), 
; calculates offsets into two data tables (data_01_66f9 and VRAM $8000), 
; and stores resulting pointers. Prepares for a rendering or data streaming operation.
    ld   A, [wDBEF]                                    ;; 01:4d6e $fa $ef $db
    and  A, A                                          ;; 01:4d71 $a7
    jr   NZ, call_01_4d6e_PrepareStreamingPointers                              ;; 01:4d72 $20 $fa
    ld   A, $01                                        ;; 01:4d74 $3e $01
    ld   [wDBEF], A                                    ;; 01:4d76 $ea $ef $db
    ld   A, $04                                        ;; 01:4d79 $3e $04
    ld   [wDBF0], A                                    ;; 01:4d7b $ea $f0 $db
    ld   A, $01                                        ;; 01:4d7e $3e $01
    ld   [wDBF1], A                                    ;; 01:4d80 $ea $f1 $db
    call call_01_4dc9_GetTileIdFromMapCoords                                  ;; 01:4d83 $cd $c9 $4d
    ld   L, A                                          ;; 01:4d86 $6f
    ld   H, $00                                        ;; 01:4d87 $26 $00
    add  HL, HL                                        ;; 01:4d89 $29
    add  HL, HL                                        ;; 01:4d8a $29
    add  HL, HL                                        ;; 01:4d8b $29
    add  HL, HL                                        ;; 01:4d8c $29
    add  HL, HL                                        ;; 01:4d8d $29
    add  HL, HL                                        ;; 01:4d8e $29
    ld   DE, data_01_66f9                              ;; 01:4d8f $11 $f9 $66
    add  HL, DE                                        ;; 01:4d92 $19
    ld   A, L                                          ;; 01:4d93 $7d
    ld   [wDBF2], A                                    ;; 01:4d94 $ea $f2 $db
    ld   A, H                                          ;; 01:4d97 $7c
    ld   [wDBF3], A                                    ;; 01:4d98 $ea $f3 $db
    call call_01_4de3_ComputeTilemapVramOffset                                  ;; 01:4d9b $cd $e3 $4d
    ld   L, A                                          ;; 01:4d9e $6f
    ld   H, $00                                        ;; 01:4d9f $26 $00
    add  HL, HL                                        ;; 01:4da1 $29
    add  HL, HL                                        ;; 01:4da2 $29
    add  HL, HL                                        ;; 01:4da3 $29
    add  HL, HL                                        ;; 01:4da4 $29
    ld   DE, _VRAM                                     ;; 01:4da5 $11 $00 $80
    add  HL, DE                                        ;; 01:4da8 $19
    ld   A, L                                          ;; 01:4da9 $7d
    ld   [wDBF4], A                                    ;; 01:4daa $ea $f4 $db
    ld   A, H                                          ;; 01:4dad $7c
    ld   [wDBF5], A                                    ;; 01:4dae $ea $f5 $db
    ld   HL, wDBEF                                     ;; 01:4db1 $21 $ef $db
    ld   A, [HL+]                                      ;; 01:4db4 $2a
    ld   [wDBEF], A                                    ;; 01:4db5 $ea $ef $db
    ld   A, [HL+]                                      ;; 01:4db8 $2a
    ld   [wDBF0], A                                    ;; 01:4db9 $ea $f0 $db
    ld   A, [HL+]                                      ;; 01:4dbc $2a
    ld   [wDBF1], A                                    ;; 01:4dbd $ea $f1 $db
    ld   A, L                                          ;; 01:4dc0 $7d
    ld   [wDBF6], A                                    ;; 01:4dc1 $ea $f6 $db
    ld   A, H                                          ;; 01:4dc4 $7c
    ld   [wDBF7], A                                    ;; 01:4dc5 $ea $f7 $db
    ret                                                ;; 01:4dc8 $c9

call_01_4dc9_GetTileIdFromMapCoords:
; Description:
; Derives a tile ID from row (wDBEC) and column (wDBEB) offsets, performs arithmetic 
; to locate the correct entry in wDB7E, and returns the byte at that position.
    ld   HL, wDBEC                                     ;; 01:4dc9 $21 $ec $db
    ld   B, [HL]                                       ;; 01:4dcc $46
    ld   A, $fa                                        ;; 01:4dcd $3e $fa
.jr_01_4dcf:
    add  A, $06                                        ;; 01:4dcf $c6 $06
    dec  B                                             ;; 01:4dd1 $05
    bit  7, B                                          ;; 01:4dd2 $cb $78
    jr   Z, .jr_01_4dcf                                ;; 01:4dd4 $28 $f9
    ld   HL, wDBEB                                     ;; 01:4dd6 $21 $eb $db
    add  A, [HL]                                       ;; 01:4dd9 $86
    ld   E, A                                          ;; 01:4dda $5f
    ld   D, $00                                        ;; 01:4ddb $16 $00
    ld   HL, wDB7E                                     ;; 01:4ddd $21 $7e $db
    add  HL, DE                                        ;; 01:4de0 $19
    ld   A, [HL]                                       ;; 01:4de1 $7e
    ret                                                ;; 01:4de2 $c9

call_01_4de3_ComputeTilemapVramOffset:
; Description:
; Computes an intermediate VRAM/tilemap offset from wDBEC and wDBEB using weighted sums and bit shifts, 
; then adds $98. Used as part of address calculations for map-to-VRAM conversions.
    ld   A, [wDBEC]                                    ;; 01:4de3 $fa $ec $db
    add  A, A                                          ;; 01:4de6 $87
    ld   L, A                                          ;; 01:4de7 $6f
    add  A, A                                          ;; 01:4de8 $87
    add  A, L                                          ;; 01:4de9 $85
    ld   L, A                                          ;; 01:4dea $6f
    ld   A, [wDBEB]                                    ;; 01:4deb $fa $eb $db
    add  A, L                                          ;; 01:4dee $85
    add  A, A                                          ;; 01:4def $87
    add  A, A                                          ;; 01:4df0 $87
    add  A, $98                                        ;; 01:4df1 $c6 $98
    ret                                                ;; 01:4df3 $c9

call_01_4df4_LookupTileFromTranslationTable:
; Description:
; Looks up a tile ID from a fixed translation table .data_01_4dfd based 
; on the index in A. Returns the mapped ID.
    ld   E, A                                          ;; 01:4df4 $5f
    ld   D, $00                                        ;; 01:4df5 $16 $00
    ld   HL, .data_01_4dfd                             ;; 01:4df7 $21 $fd $4d
    add  HL, DE                                        ;; 01:4dfa $19
    ld   A, [HL]                                       ;; 01:4dfb $7e
    ret                                                ;; 01:4dfc $c9
.data_01_4dfd:
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4dfd ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e05 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e0d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e15 ????????
    db   $00, $3a, $00, $00, $00, $00, $00, $44        ;; 01:4e1d ww??????
    db   $42, $43, $00, $00, $3f, $40, $3e, $41        ;; 01:4e25 ww??wwww
    db   $1b, $1c, $1d, $1e, $1f, $20, $21, $22        ;; 01:4e2d wwwwww??
    db   $23, $24, $00, $00, $00, $00, $00, $39        ;; 01:4e35 ?w??????
    db   $00, $25, $26, $27, $28, $29, $2a, $2b        ;; 01:4e3d ????????
    db   $2c, $2d, $2e, $2f, $30, $31, $32, $33        ;; 01:4e45 ????????
    db   $34, $35, $36, $37, $38, $3b, $3c, $3d        ;; 01:4e4d ????????
    db   $45, $46, $00, $00, $00, $00, $00, $00        ;; 01:4e55 ww??????
    db   $00, $01, $02, $03, $04, $05, $06, $07        ;; 01:4e5d wwwwwwww
    db   $08, $09, $0a, $0b, $0c, $0d, $0e, $0f        ;; 01:4e65 wwwwwwww
    db   $10, $11, $12, $13, $14, $15, $16, $17        ;; 01:4e6d wwwwwwww
    db   $18, $19, $1a, $00, $00, $00, $00, $00        ;; 01:4e75 www?????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e7d ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e85 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e8d ????????
    db   $00, $00                                      ;; 01:4e95 ??

data_01_4e97:
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e97 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4e9f ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4ea7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4eaf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4eb7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4ebf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4ec7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4ecf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4ed7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4edf ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4ee7 ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 01:4eef ????????
    db   $00, $00, $00, $00, $00, $00, $5f, $16        ;; 01:4ef7 ????????
    db   $00, $21, $06, $4f, $19, $7e, $c9, $20        ;; 01:4eff ????????
    db   $41, $42, $43, $44, $45, $46, $47, $48        ;; 01:4f07 ????????
    db   $49, $4a, $4b, $4c, $4d, $4e, $4f, $50        ;; 01:4f0f ????????
    db   $51, $52, $53, $54, $55, $56, $57, $58        ;; 01:4f17 ????????
    db   $59, $5a, $30, $31, $32, $33, $34, $35        ;; 01:4f1f ????????

call_01_4f27_ClearBgAndTileBuffers:
; Description:
; Clears and initializes background map (wC000), tile buffers (wD400_TileBuffer, wD578_TileBuffer2) 
; by filling them with zeros or $01. Uses CopyBCBytesFromHLToDE to perform block clears.
    ld   HL, wC000_BgMapTileIds                                     ;; 01:4f27 $21 $00 $c0
    ld   DE, wC000_BgMapTileIds+1                                     ;; 01:4f2a $11 $01 $c0 ; wC000_BgMapTileIds
    ld   [HL], $00                                     ;; 01:4f2d $36 $00
    ld   BC, $0f                                       ;; 01:4f2f $01 $0f $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4f32 $cd $6e $07
    ld   HL, wD400_TileBuffer                                     ;; 01:4f35 $21 $00 $d4
    ld   DE, wD400_TileBuffer+1                                     ;; 01:4f38 $11 $01 $d4
    ld   [HL], $00                                     ;; 01:4f3b $36 $00
    ld   BC, $167                                      ;; 01:4f3d $01 $67 $01
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4f40 $cd $6e $07
    ld   HL, wD578_TileBuffer2                                     ;; 01:4f43 $21 $78 $d5
    ld   DE, wD578_TileBuffer2+1                                     ;; 01:4f46 $11 $79 $d5
    ld   [HL], $01                                     ;; 01:4f49 $36 $01
    ld   BC, $167                                      ;; 01:4f4b $01 $67 $01
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4f4e $c3 $6e $07

call_01_4f51_UploadSecondaryTileLayer:
; Copies the contents of wD578_TileBuffer2 into the background tilemap using call_01_4f67_CopyTileBufferToBgMap, 
; then calls call_00_0a6a_LoadMapConfigAndWaitVBlank with C=$07 (likely triggers VRAM transfer).
    ld   DE, wD578_TileBuffer2                                     ;; 01:4f51 $11 $78 $d5
    call call_01_4f67_CopyTileBufferToBgMap                                  ;; 01:4f54 $cd $67 $4f
    ld   C, $07                                        ;; 01:4f57 $0e $07
    jp   call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 01:4f59 $c3 $6a $0a

call_01_4f5c_UploadPrimaryTileLayer:
; Description:
; Same as above but copies from wD400_TileBuffer instead of wD578_TileBuffer2 and uses C=$08.
    ld   DE, wD400_TileBuffer                                     ;; 01:4f5c $11 $00 $d4
    call call_01_4f67_CopyTileBufferToBgMap                                  ;; 01:4f5f $cd $67 $4f
    ld   C, $08                                        ;; 01:4f62 $0e $08
    jp   call_00_0a6a_LoadMapConfigAndWaitVBlank                                  ;; 01:4f64 $c3 $6a $0a

call_01_4f67_CopyTileBufferToBgMap:
; Description:
; Writes a 12×20 block of tiles from DE to HL, skipping 12 bytes each row to match map stride. 
; Core routine for transferring tile buffers to the BG map.
    ld   HL, wC000_BgMapTileIds                                     ;; 01:4f67 $21 $00 $c0
    ld   B, $12                                        ;; 01:4f6a $06 $12
.jr_01_4f6c:
    push BC                                            ;; 01:4f6c $c5
    ld   B, $14                                        ;; 01:4f6d $06 $14
.jr_01_4f6f:
    ld   A, [DE]                                       ;; 01:4f6f $1a
    ld   [HL+], A                                      ;; 01:4f70 $22
    inc  DE                                            ;; 01:4f71 $13
    dec  B                                             ;; 01:4f72 $05
    jr   NZ, .jr_01_4f6f                               ;; 01:4f73 $20 $fa
    ld   BC, $0c                                       ;; 01:4f75 $01 $0c $00
    add  HL, BC                                        ;; 01:4f78 $09
    pop  BC                                            ;; 01:4f79 $c1
    dec  B                                             ;; 01:4f7a $05
    jr   NZ, .jr_01_4f6c                               ;; 01:4f7b $20 $ef
    ret                                                ;; 01:4f7d $c9

call_01_4f7e_SeedTileLookupTable:
; Description:
; Initializes wDB7E with $20 and copies it forward 17 bytes, 
; clearing or seeding a lookup table used by map computations.
    ld   HL, wDB7E                                     ;; 01:4f7e $21 $7e $db
    ld   DE, wDB7F                                     ;; 01:4f81 $11 $7f $db
    ld   BC, $11                                       ;; 01:4f84 $01 $11 $00
    ld   [HL], $20                                     ;; 01:4f87 $36 $20
    jp   call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:4f89 $c3 $6e $07

call_01_4f8c_BuildCollisionBitfieldAndChecksum:
; Description:
; Clears wDB72–wDB7D, seeds wDB73–wDB75 from wDC4E_PlayerLivesRemaining/AF/4F, then iterates through DC5C/DC5D data, 
; checking bit masks (.data_01_5013 and .data_01_501f) to build bitfields in wDB76+. 
; Sums values for a checksum in wDB72 and sets a completion flag wDB91.
    ld   HL, wDB72                                     ;; 01:4f8c $21 $72 $db
    ld   B, $0c                                        ;; 01:4f8f $06 $0c
    xor  A, A                                          ;; 01:4f91 $af
.jr_01_4f92:
    ld   [HL+], A                                      ;; 01:4f92 $22
    dec  B                                             ;; 01:4f93 $05
    jr   NZ, .jr_01_4f92                               ;; 01:4f94 $20 $fc
    xor  A, A                                          ;; 01:4f96 $af
    ld   [wDB72], A                                    ;; 01:4f97 $ea $72 $db
    ld   A, [wDC4E_PlayerLivesRemaining]                                    ;; 01:4f9a $fa $4e $dc
    ld   [wDB73], A                                    ;; 01:4f9d $ea $73 $db
    ld   A, [wDCAF]                                    ;; 01:4fa0 $fa $af $dc
    ld   [wDB74], A                                    ;; 01:4fa3 $ea $74 $db
    ld   A, [wDC4F]                                    ;; 01:4fa6 $fa $4f $dc
    ld   [wDB75], A                                    ;; 01:4fa9 $ea $75 $db
    xor  A, A                                          ;; 01:4fac $af
    ld   [wDB90], A                                    ;; 01:4fad $ea $90 $db
    ld   DE, $00                                       ;; 01:4fb0 $11 $00 $00
.jr_01_4fb3:
    push DE                                            ;; 01:4fb3 $d5
    ld   HL, wDC5C_ProgressFlags                                     ;; 01:4fb4 $21 $5c $dc
    add  HL, DE                                        ;; 01:4fb7 $19
    ld   C, [HL]                                       ;; 01:4fb8 $4e
    ld   HL, .data_01_5013                             ;; 01:4fb9 $21 $13 $50
    add  HL, DE                                        ;; 01:4fbc $19
    ld   B, [HL]                                       ;; 01:4fbd $46
    ld   A, $08                                        ;; 01:4fbe $3e $08
.jr_01_4fc0:
    push AF                                            ;; 01:4fc0 $f5
    bit  7, B                                          ;; 01:4fc1 $cb $78
    jr   Z, .jr_01_4fee                                ;; 01:4fc3 $28 $29
    bit  7, C                                          ;; 01:4fc5 $cb $79
    jr   Z, .jr_01_4fea                                ;; 01:4fc7 $28 $21
    ld   A, [wDB90]                                    ;; 01:4fc9 $fa $90 $db
    srl  A                                             ;; 01:4fcc $cb $3f
    srl  A                                             ;; 01:4fce $cb $3f
    srl  A                                             ;; 01:4fd0 $cb $3f
    ld   E, A                                          ;; 01:4fd2 $5f
    ld   D, $00                                        ;; 01:4fd3 $16 $00
    ld   HL, wDB76                                     ;; 01:4fd5 $21 $76 $db
    add  HL, DE                                        ;; 01:4fd8 $19
    push HL                                            ;; 01:4fd9 $e5
    ld   A, [wDB90]                                    ;; 01:4fda $fa $90 $db
    and  A, $07                                        ;; 01:4fdd $e6 $07
    ld   E, A                                          ;; 01:4fdf $5f
    ld   D, $00                                        ;; 01:4fe0 $16 $00
    ld   HL, .data_01_501f                             ;; 01:4fe2 $21 $1f $50
    add  HL, DE                                        ;; 01:4fe5 $19
    ld   A, [HL]                                       ;; 01:4fe6 $7e
    pop  HL                                            ;; 01:4fe7 $e1
    or   A, [HL]                                       ;; 01:4fe8 $b6
    ld   [HL], A                                       ;; 01:4fe9 $77
.jr_01_4fea:
    ld   HL, wDB90                                     ;; 01:4fea $21 $90 $db
    inc  [HL]                                          ;; 01:4fed $34
.jr_01_4fee:
    sla  C                                             ;; 01:4fee $cb $21
    sla  B                                             ;; 01:4ff0 $cb $20
    pop  AF                                            ;; 01:4ff2 $f1
    dec  A                                             ;; 01:4ff3 $3d
    jr   NZ, .jr_01_4fc0                               ;; 01:4ff4 $20 $ca
    pop  DE                                            ;; 01:4ff6 $d1
    inc  E                                             ;; 01:4ff7 $1c
    ld   A, E                                          ;; 01:4ff8 $7b
    cp   A, $0c                                        ;; 01:4ff9 $fe $0c
    jr   C, .jr_01_4fb3                                ;; 01:4ffb $38 $b6
    ld   HL, wDB73                                     ;; 01:4ffd $21 $73 $db
    ld   B, $0b                                        ;; 01:5000 $06 $0b
    xor  A, A                                          ;; 01:5002 $af
.jr_01_5003:
    add  A, [HL]                                       ;; 01:5003 $86
    inc  HL                                            ;; 01:5004 $23
    dec  B                                             ;; 01:5005 $05
    jr   NZ, .jr_01_5003                               ;; 01:5006 $20 $fb
    xor  A, $b6                                        ;; 01:5008 $ee $b6
    ld   [wDB72], A                                    ;; 01:500a $ea $72 $db
    ld   A, $01                                        ;; 01:500d $3e $01
    ld   [wDB91], A                                    ;; 01:500f $ea $91 $db
    ret                                                ;; 01:5012 $c9
.data_01_5013:
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01        ;; 01:5013 ........
    db   $01, $01, $01, $01                            ;; 01:501b ....
.data_01_501f:
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 01:501f ??.?.???

call_01_5027_BuildTileFlagBufferFromBitfield:
; Description:
; Initializes the buffer at wDB7E to zeros, then iterates through bits in wDB72 to set flags in the buffer. 
; It scans wDB72 bitfields (masking with $80, $40, etc.) and for each set bit, ORs $10 into the corresponding 
; entry in wDB7E. Essentially, it maps a bitfield of collision/attribute flags into a tile-flag buffer.
    ld   HL, wDB7E                                     ;; 01:5027 $21 $7e $db
    ld   DE, wDB7F                                     ;; 01:502a $11 $7f $db
    ld   BC, $11                                       ;; 01:502d $01 $11 $00
    ld   [HL], $00                                     ;; 01:5030 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:5032 $cd $6e $07
    ld   HL, wDB72                                     ;; 01:5035 $21 $72 $db
    ld   B, $80                                        ;; 01:5038 $06 $80
    ld   DE, wDB7E                                     ;; 01:503a $11 $7e $db
    ld   C, $10                                        ;; 01:503d $0e $10
    ld   A, $5a                                        ;; 01:503f $3e $5a
.jr_01_5041:
    push AF                                            ;; 01:5041 $f5
    ld   A, [HL]                                       ;; 01:5042 $7e
    and  A, B                                          ;; 01:5043 $a0
    jr   Z, .jr_01_5049                                ;; 01:5044 $28 $03
    ld   A, [DE]                                       ;; 01:5046 $1a
    or   A, C                                          ;; 01:5047 $b1
    ld   [DE], A                                       ;; 01:5048 $12
.jr_01_5049:
    rrc  C                                             ;; 01:5049 $cb $09
    jr   NC, .jr_01_5050                               ;; 01:504b $30 $03
    inc  DE                                            ;; 01:504d $13
    ld   C, $10                                        ;; 01:504e $0e $10
.jr_01_5050:
    rrc  B                                             ;; 01:5050 $cb $08
    jr   NC, .jr_01_5055                               ;; 01:5052 $30 $01
    inc  HL                                            ;; 01:5054 $23
.jr_01_5055:
    pop  AF                                            ;; 01:5055 $f1
    dec  A                                             ;; 01:5056 $3d
    jr   NZ, .jr_01_5041                               ;; 01:5057 $20 $e8
    ret                                                ;; 01:5059 $c9

call_01_505a_ValidateTileBufferAndRebuildCollisionData:
; Description:
; Checks wDB7E for any tile flagged $20. If found early, returns 0. If not found after scanning $12 entries, 
; it resets buffers (wDB72–wDB7D), then reconstructs bitfields from wDB7E back into wDB72. It sums these values, 
; XORs with $B6, and compares to wDB72 as a checksum. On match, it calls call_01_50b5_GenerateCollisionTableFromMasks 
; (which rebuilds DC5C/DC4E tile collision data) and returns $20; otherwise, returns 0.
    ld   HL, wDB7E                                     ;; 01:505a $21 $7e $db
    ld   B, $12                                        ;; 01:505d $06 $12
.jr_01_505f:
    ld   A, [HL+]                                      ;; 01:505f $2a
    cp   A, $20                                        ;; 01:5060 $fe $20
    jr   Z, .jr_01_50b2                                ;; 01:5062 $28 $4e
    dec  B                                             ;; 01:5064 $05
    jr   NZ, .jr_01_505f                               ;; 01:5065 $20 $f8
    ld   HL, wDB72                                     ;; 01:5067 $21 $72 $db
    ld   DE, wDB73                                     ;; 01:506a $11 $73 $db
    ld   BC, $0b                                       ;; 01:506d $01 $0b $00
    ld   [HL], $00                                     ;; 01:5070 $36 $00
    call call_00_076e_CopyBCBytesFromHLToDE                                  ;; 01:5072 $cd $6e $07
    ld   HL, wDB72                                     ;; 01:5075 $21 $72 $db
    ld   B, $80                                        ;; 01:5078 $06 $80
    ld   DE, wDB7E                                     ;; 01:507a $11 $7e $db
    ld   C, $10                                        ;; 01:507d $0e $10
    ld   A, $5a                                        ;; 01:507f $3e $5a
.jr_01_5081:
    push AF                                            ;; 01:5081 $f5
    ld   A, [DE]                                       ;; 01:5082 $1a
    and  A, C                                          ;; 01:5083 $a1
    jr   Z, .jr_01_5089                                ;; 01:5084 $28 $03
    ld   A, [HL]                                       ;; 01:5086 $7e
    or   A, B                                          ;; 01:5087 $b0
    ld   [HL], A                                       ;; 01:5088 $77
.jr_01_5089:
    rrc  C                                             ;; 01:5089 $cb $09
    jr   NC, .jr_01_5090                               ;; 01:508b $30 $03
    inc  DE                                            ;; 01:508d $13
    ld   C, $10                                        ;; 01:508e $0e $10
.jr_01_5090:
    rrc  B                                             ;; 01:5090 $cb $08
    jr   NC, .jr_01_5095                               ;; 01:5092 $30 $01
    inc  HL                                            ;; 01:5094 $23
.jr_01_5095:
    pop  AF                                            ;; 01:5095 $f1
    dec  A                                             ;; 01:5096 $3d
    jr   NZ, .jr_01_5081                               ;; 01:5097 $20 $e8
    ld   HL, wDB73                                     ;; 01:5099 $21 $73 $db
    ld   B, $0b                                        ;; 01:509c $06 $0b
    xor  A, A                                          ;; 01:509e $af
.jr_01_509f:
    add  A, [HL]                                       ;; 01:509f $86
    inc  HL                                            ;; 01:50a0 $23
    dec  B                                             ;; 01:50a1 $05
    jr   NZ, .jr_01_509f                               ;; 01:50a2 $20 $fb
    xor  A, $b6                                        ;; 01:50a4 $ee $b6
    ld   HL, wDB72                                     ;; 01:50a6 $21 $72 $db
    cp   A, [HL]                                       ;; 01:50a9 $be
    jr   NZ, .jr_01_50b2                               ;; 01:50aa $20 $06
    call call_01_50b5_GenerateCollisionTableFromMasks                                  ;; 01:50ac $cd $b5 $50
    ld   A, $20                                        ;; 01:50af $3e $20
    ret                                                ;; 01:50b1 $c9
.jr_01_50b2:
    ld   A, $00                                        ;; 01:50b2 $3e $00
    ret                                                ;; 01:50b4 $c9

call_01_50b5_GenerateCollisionTableFromMasks:
; Description:
; Builds a collision lookup table (wDC5C_ProgressFlags) from static mask tables .data_01_511a_CollisionColumnMaskTable and .data_01_5126_BitMaskLut_80to01. 
; It iterates through each mask byte, rotates bits, checks wDB76 bitfields, and sets collision bits 
; in a temporary register (C). Once a row is processed, it stores the result into wDC5C_ProgressFlags, repeating 
; for 12 entries. Finally, it updates wDC4E_PlayerLivesRemaining/AF/4F with values from wDB73–wDB75.
    xor  A, A                                          ;; 01:50b5 $af
    ld   [wDB90], A                                    ;; 01:50b6 $ea $90 $db
    ld   DE, $00                                       ;; 01:50b9 $11 $00 $00
.jr_01_50bc:
    push DE                                            ;; 01:50bc $d5
    ld   HL, .data_01_511a_CollisionColumnMaskTable                             ;; 01:50bd $21 $1a $51
    add  HL, DE                                        ;; 01:50c0 $19
    ld   B, [HL]                                       ;; 01:50c1 $46
    ld   C, $00                                        ;; 01:50c2 $0e $00
    ld   A, $08                                        ;; 01:50c4 $3e $08
.jr_01_50c6:
    push AF                                            ;; 01:50c6 $f5
    bit  7, B                                          ;; 01:50c7 $cb $78
    jr   Z, .jr_01_50f3                                ;; 01:50c9 $28 $28
    ld   A, [wDB90]                                    ;; 01:50cb $fa $90 $db
    srl  A                                             ;; 01:50ce $cb $3f
    srl  A                                             ;; 01:50d0 $cb $3f
    srl  A                                             ;; 01:50d2 $cb $3f
    ld   E, A                                          ;; 01:50d4 $5f
    ld   D, $00                                        ;; 01:50d5 $16 $00
    ld   HL, wDB76                                     ;; 01:50d7 $21 $76 $db
    add  HL, DE                                        ;; 01:50da $19
    push HL                                            ;; 01:50db $e5
    ld   A, [wDB90]                                    ;; 01:50dc $fa $90 $db
    and  A, $07                                        ;; 01:50df $e6 $07
    ld   E, A                                          ;; 01:50e1 $5f
    ld   D, $00                                        ;; 01:50e2 $16 $00
    ld   HL, .data_01_5126_BitMaskLut_80to01                             ;; 01:50e4 $21 $26 $51
    add  HL, DE                                        ;; 01:50e7 $19
    ld   A, [HL]                                       ;; 01:50e8 $7e
    pop  HL                                            ;; 01:50e9 $e1
    and  A, [HL]                                       ;; 01:50ea $a6
    jr   Z, .jr_01_50ef                                ;; 01:50eb $28 $02
    set  7, C                                          ;; 01:50ed $cb $f9
.jr_01_50ef:
    ld   HL, wDB90                                     ;; 01:50ef $21 $90 $db
    inc  [HL]                                          ;; 01:50f2 $34
.jr_01_50f3:
    rlc  C                                             ;; 01:50f3 $cb $01
    sla  B                                             ;; 01:50f5 $cb $20
    pop  AF                                            ;; 01:50f7 $f1
    dec  A                                             ;; 01:50f8 $3d
    jr   NZ, .jr_01_50c6                               ;; 01:50f9 $20 $cb
    pop  DE                                            ;; 01:50fb $d1
    ld   HL, wDC5C_ProgressFlags                                     ;; 01:50fc $21 $5c $dc
    add  HL, DE                                        ;; 01:50ff $19
    ld   [HL], C                                       ;; 01:5100 $71
    inc  E                                             ;; 01:5101 $1c
    ld   A, E                                          ;; 01:5102 $7b
    cp   A, $0c                                        ;; 01:5103 $fe $0c
    jr   C, .jr_01_50bc                                ;; 01:5105 $38 $b5
    ld   A, [wDB73]                                    ;; 01:5107 $fa $73 $db
    ld   [wDC4E_PlayerLivesRemaining], A                                    ;; 01:510a $ea $4e $dc
    ld   A, [wDB74]                                    ;; 01:510d $fa $74 $db
    ld   [wDCAF], A                                    ;; 01:5110 $ea $af $dc
    ld   A, [wDB75]                                    ;; 01:5113 $fa $75 $db
    ld   [wDC4F], A                                    ;; 01:5116 $ea $4f $dc
    ret                                                ;; 01:5119 $c9
.data_01_511a_CollisionColumnMaskTable:
; Description:
; A static table of bit masks used by call_01_50b5 to control which collision checks 
; to perform for each column. Likely a column mask pattern for map rows.
    db   $f1, $ff, $ff, $ff, $ff, $ff, $ff, $01        ;; 01:511a ????????
    db   $01, $01, $01, $01                            ;; 01:5122 ????
.data_01_5126_BitMaskLut_80to01:
; Description:
; A standard bitmask lookup table for individual bits ($80, $40, $20 … $01). 
; Used for testing individual tile bits in wDB76.
    db   $80, $40, $20, $10, $08, $04, $02, $01        ;; 01:5126 ????????

data_01_512e:
    db   $02, $02, $01, $04, $98, $07, $00, $00        ;; 01:512e ..ww..??
    db   $02, $02, $04, $04, $9c, $07, $00, $00        ;; 01:5136 ..ww..??
    db   $02, $02, $07, $04, $a0, $07, $00, $00        ;; 01:513e ..ww..??
    db   $02, $02, $0a, $04, $a4, $07, $00, $00        ;; 01:5146 ..ww..??
    db   $02, $02, $0d, $04, $a8, $07, $00, $00        ;; 01:514e ..ww..??
    db   $02, $02, $10, $04, $ac, $07, $00, $00        ;; 01:5156 ..ww..??
    db   $02, $02, $01, $07, $b0, $07, $00, $00        ;; 01:515e ..ww..??
    db   $02, $02, $04, $07, $b4, $07, $00, $00        ;; 01:5166 ..ww..??
    db   $02, $02, $07, $07, $b8, $07, $00, $00        ;; 01:516e ..ww..??
    db   $02, $02, $0a, $07, $bc, $07, $00, $00        ;; 01:5176 ..ww..??
    db   $02, $02, $0d, $07, $c0, $07, $00, $00        ;; 01:517e ..ww..??
    db   $02, $02, $10, $07, $c4, $07, $00, $00        ;; 01:5186 ..ww..??
    db   $02, $02, $01, $0a, $c8, $07, $00, $00        ;; 01:518e ..ww..??
    db   $02, $02, $04, $0a, $cc, $07, $00, $00        ;; 01:5196 ..ww..??
    db   $02, $02, $07, $0a, $d0, $07, $00, $00        ;; 01:519e ..ww..??
    db   $02, $02, $0a, $0a, $d4, $07, $00, $00        ;; 01:51a6 ..ww..??
    db   $02, $02, $0d, $0a, $d8, $07, $00, $00        ;; 01:51ae ..ww..??
    db   $02, $02, $10, $0a, $dc, $07, $00, $00        ;; 01:51b6 ..ww..??
    db   $10, $01, $01, $01, $e0, $07, $00, $00        ;; 01:51be w.www.??
    db   $10, $01, $01, $02, $f0, $07, $00, $00        ;; 01:51c6 w.www.??
    db   $08, $01, $06, $0b, $d0, $00, $00, $00        ;; 01:51ce w...w.??
    db   $08, $01, $06, $0d, $d8, $00, $00, $00        ;; 01:51d6 w...w.??
    db   $08, $06, $01, $00, $01, $ff, $00, $00        ;; 01:51de ..ww..??
    db   $0b, $02, $09, $01, $31, $01, $00, $00        ;; 01:51e6 w.www.??
    db   $0b, $02, $09, $04, $47, $02, $00, $00        ;; 01:51ee w.www.??
    db   $10, $02, $04, $07, $5d, $02, $00, $00        ;; 01:51f6 w.www.??
    db   $10, $02, $04, $0a, $7d, $02, $00, $00        ;; 01:51fe w.www.??
    db   $10, $02, $04, $0d, $9d, $02, $00, $00        ;; 01:5206 w.www.??
    db   $12, $02, $01, $10, $bd, $02, $00, $00        ;; 01:520e w.www.??
    db   $0b, $03, $09, $04, $47, $02, $00, $00        ;; 01:5216 ????????
    db   $0c, $02, $04, $01, $01, $01, $00, $00        ;; 01:521e w.www.??
    db   $0c, $02, $04, $03, $19, $02, $00, $00        ;; 01:5226 w.www.??
    db   $14, $01, $00, $0f, $31, $02, $00, $00        ;; 01:522e w.www.??
    db   $14, $02, $00, $10, $45, $02, $00, $00        ;; 01:5236 w.www.??
    db   $01, $01, $0b, $06, $6d, $02, $00, $00        ;; 01:523e w.www.??
    db   $01, $02, $0c, $06, $6e, $02, $00, $00        ;; 01:5246 w.www.??
    db   $01, $01, $0d, $07, $70, $02, $00, $00        ;; 01:524e w.www.??
    db   $01, $01, $0b, $09, $71, $02, $00, $00        ;; 01:5256 w.www.??
    db   $01, $02, $0c, $09, $72, $02, $00, $00        ;; 01:525e w.www.??
    db   $01, $01, $0d, $0a, $74, $02, $00, $00        ;; 01:5266 w.www.??
    db   $01, $01, $0b, $0c, $75, $02, $00, $00        ;; 01:526e w.www.??
    db   $01, $02, $0c, $0c, $76, $02, $00, $00        ;; 01:5276 w.www.??
    db   $01, $01, $0d, $0d, $78, $02, $00, $00        ;; 01:527e w.www.??
    db   $02, $02, $07, $06, $f8, $04, $00, $00        ;; 01:5286 ..www.??
    db   $02, $02, $07, $09, $f4, $07, $00, $00        ;; 01:528e ..www.??
    db   $02, $02, $07, $0c, $ec, $05, $00, $00        ;; 01:5296 ..www.??
    db   $10, $02, $02, $00, $01, $01, $00, $00        ;; 01:529e ????????
    db   $12, $02, $01, $05, $21, $02, $00, $00        ;; 01:52a6 w.www.??
    db   $14, $02, $00, $10, $45, $02, $00, $00        ;; 01:52ae ????????
    db   $02, $01, $07, $0a, $6d, $02, $00, $00        ;; 01:52b6 ????????
    db   $02, $02, $09, $0a, $6f, $02, $00, $00        ;; 01:52be ????????
    db   $02, $01, $0b, $0b, $73, $02, $00, $00        ;; 01:52c6 ????????
    db   $02, $02, $04, $0e, $75, $02, $00, $00        ;; 01:52ce ????????
    db   $02, $02, $0e, $0e, $79, $02, $00, $00        ;; 01:52d6 ????????
    db   $02, $02, $09, $08, $f0, $06, $00, $00        ;; 01:52de ????????
    db   $02, $02, $04, $0c, $ec, $05, $00, $00        ;; 01:52e6 ????????
    db   $02, $02, $0e, $0c, $f4, $07, $00, $00        ;; 01:52ee ????????
    db   $02, $02, $03, $03, $7d, $03, $00, $00        ;; 01:52f6 ????????
    db   $02, $02, $07, $03, $81, $03, $00, $00        ;; 01:52fe ????????
    db   $02, $02, $0b, $03, $85, $03, $00, $00        ;; 01:5306 ????????
    db   $02, $02, $0f, $03, $89, $03, $00, $00        ;; 01:530e ????????
    db   $0e, $02, $03, $04                            ;; 01:5316 w.ww
    db   %00000001                                     ;; 01:531a $01

    db   $01, $00, $00, $0e, $02, $03, $06, $1d        ;; 01:531b .??w.www
    db   $01, $00, $00, $0e, $02, $03, $08, $39        ;; 01:5323 .??w.www
    db   $01, $00, $00, $0e, $02, $03, $0a             ;; 01:532b .??w.ww
    db   %01010101                                     ;; 01:5332 $55

    db   $01, $00, $00, $02, $02, $03, $10, $71        ;; 01:5333 .??w.www
    db   $02, $00, $00, $02, $02, $07, $10, $75        ;; 01:533b .??w.www
    db   $02, $00, $00, $02, $02, $0b, $10, $79        ;; 01:5343 .??w.www
    db   $02, $00, $00, $02, $02, $0f, $10, $7d        ;; 01:534b .??w.www
    db   $02, $00, $00, $02, $02, $03, $01             ;; 01:5353 .??w.ww
    db   %10000001                                     ;; 01:535a $81

    db   $02, $00, $00, $02, $02, $03, $0e             ;; 01:535b .??..ww
    db   %11110000                                     ;; 01:5362 $f0

    db   $06, $00, $00, $02, $02, $07, $0e             ;; 01:5363 .??..ww
    db   %11110100                                     ;; 01:536a $f4

    db   $07, $00, $00, $02, $02, $0b, $0e             ;; 01:536b .??..ww
    db   %11101100                                     ;; 01:5372 $ec

    db   $05, $00, $00, $02, $02, $0f, $0e             ;; 01:5373 .??..ww
    db   %11111000                                     ;; 01:537a $f8

    db   $04, $00, $00, $02, $01, $01, $01             ;; 01:537b .??..ww
    db   %10000101                                     ;; 01:5382 $85

    db   $03, $00, $00, $02, $01, $01, $02             ;; 01:5383 .??..ww
    db   %10000111                                     ;; 01:538a $87

    db   $00, $00, $00, $14, $03, $00, $08, $01        ;; 01:538b .??w.www
    db   $01, $00, $00, $0a, $02, $0a, $02, $80        ;; 01:5393 .???????
    db   $03, $00, $00, $0a, $02, $0a, $05, $94        ;; 01:539b ????????
    db   $03, $00, $00, $0a, $02, $0a, $08, $a8        ;; 01:53a3 ????????
    db   $03, $00, $00, $0a, $02, $0a, $0b, $bc        ;; 01:53ab ????????
    db   $03, $00, $00, $0a, $02, $0a, $0e, $d0        ;; 01:53b3 ????????
    db   $03, $00, $00, $10, $10, $02, $01, $01        ;; 01:53bb ???w.www
    db   $02, $00, $00                                 ;; 01:53c3 .??

data_01_53c6_MenuTypeData:
    dw   data_01_559a                                  ;; 01:53c6 pP
    db   $00, $02, $20, $54, $00, $10, $d3, $04        ;; 01:53c8 ........
    dw   call_01_43c3_LoadMenuObjectPalette                                  ;; 01:53d0 pP
    db   $00, $00, $00, $00                            ;; 01:53d2 ????
    dw   data_01_55c3                                  ;; 01:53d6 pP
    db   $01, $12, $08, $20, $18, $18, $d3, $07        ;; 01:53d8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:53e0 ..????
    dw   data_01_55ec                                  ;; 01:53e6 pP
    db   $01, $00, $00, $00, $00, $00, $d3, $07        ;; 01:53e8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:53f0 ..????
    dw   data_01_55fd                                  ;; 01:53f6 pP
    db   $08, $00, $00, $00, $00, $00, $d3, $01        ;; 01:53f8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:5400 ..????
    dw   data_01_5606                                  ;; 01:5406 pP
    db   $08, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5408 ........
    db   $00, $00, $00, $00, $00, $00, $0f, $56        ;; 01:5410 ..??????
    db   $00, $01, $00, $50, $00, $18, $d3, $80        ;; 01:5418 ????????
    db   $00, $00, $00, $00, $00, $00, $48, $56        ;; 01:5420 ????????
    db   $00, $02, $00, $40, $00, $20, $d3, $80        ;; 01:5428 ????????
    db   $00, $00, $00, $00, $00, $00                  ;; 01:5430 ??????
    dw   data_01_5649                                  ;; 01:5436 pP
    db   $00, $03, $00, $38, $00, $18, $d3, $80        ;; 01:5438 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:5440 ..????
    dw   data_01_5692                                  ;; 01:5446 pP
    db   $10, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5448 ........
    db   $00, $00, $00, $00, $00, $00, $1b, $57        ;; 01:5450 ..??????
    db   $00, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5458 ????????
    db   $00, $00, $00, $00, $00, $00, $a4, $57        ;; 01:5460 ????????
    db   $00, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5468 ????????
    db   $00, $00, $00, $00, $00, $00, $ad, $57        ;; 01:5470 ????????
    db   $00, $04, $08, $20, $00, $10, $d3, $01        ;; 01:5478 ????????
    db   $00, $00, $00, $00, $00, $00, $be, $57        ;; 01:5480 ????????
    db   $00, $02, $08, $30, $00, $10, $d3, $01        ;; 01:5488 ????????
    db   $00, $00, $00, $00, $00, $00                  ;; 01:5490 ??????
    dw   data_01_57d7                                  ;; 01:5496 pP
    db   $00, $04, $08, $20, $00, $10, $d3, $01        ;; 01:5498 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:54a0 ..????
    dw   data_01_57e8                                  ;; 01:54a6 pP
    db   $00, $02, $08, $30, $00, $10, $d3, $01        ;; 01:54a8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:54b0 ..????
    dw   data_01_5801                                  ;; 01:54b6 pP
    db   $04, $00, $00, $00, $00, $00, $d3, $02        ;; 01:54b8 ........
    db   $00, $00, $00, $00, $00, $00, $0a, $58        ;; 01:54c0 ..??????
    db   $00, $05, $18, $10, $00, $18, $d3, $03        ;; 01:54c8 ????????
    db   $00, $00, $00, $00, $00, $00                  ;; 01:54d0 ??????
    dw   data_01_5843                                  ;; 01:54d6 pP
    db   $02, $00, $00, $00, $00, $00, $d3, $01        ;; 01:54d8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:54e0 ..????
    dw   data_01_586c                                  ;; 01:54e6 pP
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:54e8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:54f0 ..????
    dw   data_01_588d                                  ;; 01:54f6 pP
    db   $04, $00, $00, $00, $00, $00, $d3, $05        ;; 01:54f8 ........
    db   $00, $00, $00, $00, $00, $00                  ;; 01:5500 ..????
    dw   data_01_5896                                  ;; 01:5506 pP
    db   $04, $00, $00, $00, $00, $00, $d3, $06        ;; 01:5508 ........
    db   $00, $00, $00, $00, $00, $00, $9f, $58        ;; 01:5510 ..??????
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5518 ????????
    db   $00, $00, $00, $00, $00, $00, $b8, $58        ;; 01:5520 ????????
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5528 ????????
    db   $00, $00, $00, $00, $00, $00, $29, $59        ;; 01:5530 ????????
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5538 ????????
    db   $00, $00, $00, $00, $00, $00, $a2, $59        ;; 01:5540 ????????
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5548 ????????
    db   $00, $00, $00, $00, $00, $00, $c3, $59        ;; 01:5550 ????????
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5558 ????????
    db   $00, $00, $00, $00, $00, $00, $14, $5a        ;; 01:5560 ????????
    db   $04, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5568 ????????
    db   $00, $00, $00, $00, $00, $00, $35, $5a        ;; 01:5570 ????????
    db   $00, $00, $00, $00, $00, $00, $d3, $01        ;; 01:5578 ????????
    db   $00, $00, $00, $00, $00, $00, $3e, $5a        ;; 01:5580 ????????
    db   $04, $00, $20, $54, $00, $10, $d3, $08        ;; 01:5588 ????????
    db   $00, $00, $00, $00, $00, $00                  ;; 01:5590 ??????

data_01_5596:
    dw   data_01_5a47                                  ;; 01:5596 pP
    dw   data_01_5ad8                                  ;; 01:5598 pP

data_01_559a:
    db   $00, $00, $00, $00, $02, $ed, $0f, $60        ;; 01:559a w...w...
    db   $14, $fe, $fe, $00                            ;; 01:55a2 w..w
    dw   $477c                                         ;; 01:55a6 wW
    db   $10, $63, $00, $00, $00, $00, $03, $e9        ;; 01:55a8 ..w...w.
    db   $0f, $60, $15, $fe, $fe, $00                  ;; 01:55b0 ..w..w
    dw   $47c7                                         ;; 01:55b6 wW
    db   $21, $63, $00, $00, $00, $fc, $02, $e6        ;; 01:55b8 ..w..ww.
    db   $0f, $e0, $ff                                 ;; 01:55c0 ...

data_01_55c3:
    db   $00, $00, $00, $00, $05, $ed, $0f, $60        ;; 01:55c3 w...w...
    db   $12, $fe, $fe, $02                            ;; 01:55cb w..w
    dw   $4e62                                         ;; 01:55cf wW
    db   $0f, $23, $13, $fe, $fe, $02                  ;; 01:55d1 ..w..w
    dw   $4e7d                                         ;; 01:55d7 wW
    db   $0f, $23, $00, $00, $00, $fc, $01, $e6        ;; 01:55d9 ..w..ww.
    db   $0f, $60, $00, $00, $00, $00, $00, $ec        ;; 01:55e1 ..w...w.
    db   $0f, $60, $ff                                 ;; 01:55e9 ...

data_01_55ec:
    db   $00, $00, $00, $00, $05, $ed, $0f, $60        ;; 01:55ec w...w...
    db   $00, $00, $00, $00, $00, $ec, $0f, $60        ;; 01:55f4 w...w...
    db   $ff                                           ;; 01:55fc .

data_01_55fd:
    db   $4c, $fe, $fe, $01                            ;; 01:55fd w..w
    dw   $4c09                                         ;; 01:5601 wW
    db   $0f, $a3, $ff                                 ;; 01:5603 ...

data_01_5606:
    db   $2f, $fe, $fe, $00                            ;; 01:5606 w..w
    dw   $4e03                                         ;; 01:560a wW
    db   $0f, $a3, $ff, $1a, $00, $fe, $00, $00        ;; 01:560c ...?????
    db   $e5, $00, $23, $1c, $fe, $fe, $00, $16        ;; 01:5614 ????????
    db   $49, $0f, $23, $17, $fe, $fe, $01, $00        ;; 01:561c ????????
    db   $e3, $0f, $23, $1d, $fe, $fe, $00, $00        ;; 01:5624 ????????
    db   $e4, $0f, $23, $16, $00, $00, $01, $00        ;; 01:562c ????????
    db   $e2, $0f, $20, $00, $00, $00, $e4, $04        ;; 01:5634 ????????
    db   $e1, $0f, $60, $00, $00, $00, $fc, $02        ;; 01:563c ????????
    db   $e6, $0f, $e0, $ff, $ff                       ;; 01:5644 ?????

data_01_5649:
    db   $19, $00, $fe, $00, $00, $e5, $00, $23        ;; 01:5649 w..ww...
    db   $1a, $00, $fe, $00, $01, $e5, $01, $23        ;; 01:5651 w..ww...
    db   $1b, $00, $fe, $00, $02, $e5, $02, $23        ;; 01:5659 w..ww...
    db   $1c, $fe, $fe, $00                            ;; 01:5661 w..w
    dw   $4803                                         ;; 01:5665 wW
    db   $0f, $23, $17, $fe, $fe, $01, $00, $e3        ;; 01:5667 ..w..w..
    db   $0f, $23, $18, $fe, $fe, $00, $00, $e4        ;; 01:566f ..w..w..
    db   $0f, $23, $16, $00, $00, $01, $00, $e2        ;; 01:5677 ..w.....
    db   $0f, $20, $00, $00, $00, $e4, $04, $e1        ;; 01:567f ..w..ww.
    db   $0f, $60, $00, $00, $00, $fc, $02, $e6        ;; 01:5687 ..w..ww.
    db   $0f, $e0, $ff                                 ;; 01:568f ...

data_01_5692:
    db   $1e, $fe, $fe, $01, $00, $e3, $0f, $23        ;; 01:5692 w..w....
    db   $1f, $fe, $fe, $00, $00, $e4, $0f, $23        ;; 01:569a w..w....
    db   $20, $fe, $fe, $00                            ;; 01:56a2 w..w
    dw   $49cb                                         ;; 01:56a6 wW
    db   $0f, $23, $21, $fe, $fe, $00                  ;; 01:56a8 ..w..w
    dw   $4916                                         ;; 01:56ae wW
    db   $0f, $23, $22, $fe, $fe, $00, $00, $e8        ;; 01:56b0 ..w..ww.
    db   $0f, $23, $23, $fe, $fe, $00                  ;; 01:56b8 ..w..w
    dw   $4a63                                         ;; 01:56be wW
    db   $0f, $23, $24, $fe, $fe, $00, $07, $e8        ;; 01:56c0 ..w..ww.
    db   $0f, $23, $25, $fe, $fe, $00, $01, $e8        ;; 01:56c8 ..w..ww.
    db   $0f, $23, $26, $fe, $fe, $00                  ;; 01:56d0 ..w..w
    dw   $4a63                                         ;; 01:56d6 wW
    db   $0f, $23, $27, $fe, $fe, $00, $08, $e8        ;; 01:56d8 ..w..ww.
    db   $0f, $23, $28, $fe, $fe, $00, $02, $e8        ;; 01:56e0 ..w..ww.
    db   $0f, $23, $29, $fe, $fe, $00                  ;; 01:56e8 ..w..w
    dw   $4a63                                         ;; 01:56ee wW
    db   $0f, $23, $2a, $fe, $fe, $00, $09, $e8        ;; 01:56f0 ..w..ww.
    db   $0f, $23, $2b, $00, $00, $00, $00, $00        ;; 01:56f8 ..w.....
    db   $0f, $25, $2c, $00, $00, $00, $00, $00        ;; 01:5700 ..w.....
    db   $0f, $25, $2d, $00, $00, $00, $00, $00        ;; 01:5708 ..w.....
    db   $0f, $25, $00, $00, $00, $00, $00, $e7        ;; 01:5710 ..w.....
    db   $0f, $e0, $ff, $2e, $fe, $fe, $01, $6f        ;; 01:5718 ...?????
    db   $4a, $0f, $23, $2f, $fe, $fe, $00, $00        ;; 01:5720 ????????
    db   $ee, $0f, $23, $30, $fe, $fe, $00, $16        ;; 01:5728 ????????
    db   $49, $0f, $23, $31, $fe, $fe, $00, $03        ;; 01:5730 ????????
    db   $e8, $0f, $23, $32, $fe, $fe, $00, $63        ;; 01:5738 ????????
    db   $4a, $0f, $23, $33, $fe, $fe, $00, $0b        ;; 01:5740 ????????
    db   $e8, $0f, $23, $34, $fe, $fe, $00, $04        ;; 01:5748 ????????
    db   $e8, $0f, $23, $35, $fe, $fe, $00, $05        ;; 01:5750 ????????
    db   $e8, $0f, $23, $36, $00, $00, $00, $00        ;; 01:5758 ????????
    db   $00, $0f, $25, $37, $00, $00, $00, $00        ;; 01:5760 ????????
    db   $00, $0f, $25, $38, $00, $00, $00, $00        ;; 01:5768 ????????
    db   $00, $0f, $25, $39, $00, $00, $00, $00        ;; 01:5770 ????????
    db   $f0, $0f, $60, $3a, $00, $00, $00, $01        ;; 01:5778 ????????
    db   $f0, $0f, $60, $3b, $00, $00, $00, $02        ;; 01:5780 ????????
    db   $f0, $0f, $60, $3c, $00, $00, $00, $03        ;; 01:5788 ????????
    db   $f0, $0f, $60, $00, $00, $00, $e4, $04        ;; 01:5790 ????????
    db   $e1, $0f, $60, $00, $00, $00, $00, $00        ;; 01:5798 ????????
    db   $e7, $0f, $e0, $ff, $3f, $fe, $fe, $01        ;; 01:57a0 ????????
    db   $79, $4b, $0f, $a3, $ff, $40, $fe, $fe        ;; 01:57a8 ????????
    db   $01, $bf, $4c, $53, $23, $00, $00, $00        ;; 01:57b0 ????????
    db   $00, $01, $ec, $0f, $60, $ff, $3e, $fe        ;; 01:57b8 ????????
    db   $fe, $01, $bf, $4c, $60, $23, $3f, $fe        ;; 01:57c0 ????????
    db   $fe, $01, $b6, $4d, $01, $23, $00, $00        ;; 01:57c8 ????????
    db   $00, $fc, $02, $e6, $0f, $e0, $ff             ;; 01:57d0 ???????

data_01_57d7:
    db   $40, $fe, $fe, $01                            ;; 01:57d7 w..w
    dw   $4d63                                         ;; 01:57db wW
    db   $53, $23, $00, $00, $00, $00, $01, $ec        ;; 01:57dd ..w...w.
    db   $0f, $60, $ff                                 ;; 01:57e5 ...

data_01_57e8:
    db   $3e, $fe, $fe, $01                            ;; 01:57e8 w..w
    dw   $4d63                                         ;; 01:57ec wW
    db   $60, $23, $3f, $fe, $fe, $01                  ;; 01:57ee ..w..w
    dw   $4db6                                         ;; 01:57f4 wW
    db   $01, $23, $00, $00, $00, $fc, $02, $e6        ;; 01:57f6 ..w..ww.
    db   $0f, $e0, $ff                                 ;; 01:57fe ...

data_01_5801:
    db   $00, $00, $00, $00, $00, $ed, $0f, $e0        ;; 01:5801 w...w...
    db   $ff, $00, $00, $00, $00, $01, $ed, $0f        ;; 01:5809 .???????
    db   $e0, $4d, $fe, $fe, $01, $20, $47, $00        ;; 01:5811 ????????
    db   $23, $4e, $fe, $fe, $01, $32, $47, $01        ;; 01:5819 ????????
    db   $23, $4f, $fe, $fe, $01, $45, $47, $02        ;; 01:5821 ????????
    db   $23, $50, $fe, $fe, $01, $57, $47, $03        ;; 01:5829 ????????
    db   $23, $51, $fe, $fe, $01, $69, $47, $04        ;; 01:5831 ????????
    db   $23, $00, $00, $00, $fc, $00, $e6, $0f        ;; 01:5839 ????????
    db   $e0, $ff                                      ;; 01:5841 ??

data_01_5843:
    db   $52, $fe, $00, $00                            ;; 01:5843 w..w
    dw   $4000                                         ;; 01:5847 wW
    db   $0f, $23, $52, $fe, $17, $00                  ;; 01:5849 ..w..w
    dw   $4022                                         ;; 01:584f wW
    db   $0f, $22, $52, $fe, $35, $00                  ;; 01:5851 ..w..w
    dw   $404f                                         ;; 01:5857 wW
    db   $0f, $22, $52, $fe, $53, $00                  ;; 01:5859 ..w..w
    dw   $4082                                         ;; 01:585f wW
    db   $0f, $22, $52, $fe, $78, $00                  ;; 01:5861 ..w..w
    dw   $40d9                                         ;; 01:5867 wW
    db   $0f, $a2, $ff                                 ;; 01:5869 ...

data_01_586c:
    db   $52, $fe, $05, $00                            ;; 01:586c w..w
    dw   $40f8                                         ;; 01:5870 wW
    db   $0f, $23, $52, $fe, $29, $00                  ;; 01:5872 ..w..w
    dw   $4171                                         ;; 01:5878 wW
    db   $0f, $22, $52, $fe, $45, $00                  ;; 01:587a ..w..w
    dw   $41bf                                         ;; 01:5880 wW
    db   $0f, $22, $52, $fe, $69, $00                  ;; 01:5882 ..w..w
    dw   $422a                                         ;; 01:5888 wW
    db   $0f, $a2, $ff                                 ;; 01:588a ...

data_01_588d:
    db   $00, $00, $00, $00, $03, $ed, $0f, $e0        ;; 01:588d w...w...
    db   $ff                                           ;; 01:5895 .

data_01_5896:
    db   $00, $00, $00, $00, $04, $ed, $0f, $e0        ;; 01:5896 w...w...
    db   $ff, $52, $fe, $08, $00, $69, $42, $0f        ;; 01:589e .???????
    db   $23, $52, $fe, $36, $00, $8c, $42, $0f        ;; 01:58a6 ????????
    db   $22, $52, $fe, $40, $00, $a9, $42, $0f        ;; 01:58ae ????????
    db   $a2, $ff, $52, $fe, $00, $00, $be, $42        ;; 01:58b6 ????????
    db   $0f, $23, $52, $fe, $08, $00, $d5, $42        ;; 01:58be ????????
    db   $0f, $22, $52, $fe, $18, $00, $e9, $42        ;; 01:58c6 ????????
    db   $0f, $22, $52, $fe, $20, $00, $ff, $42        ;; 01:58ce ????????
    db   $0f, $22, $52, $fe, $31, $00, $16, $43        ;; 01:58d6 ????????
    db   $0f, $22, $52, $fe, $39, $00, $28, $43        ;; 01:58de ????????
    db   $0f, $22, $52, $fe, $41, $00, $41, $43        ;; 01:58e6 ????????
    db   $0f, $22, $52, $fe, $49, $00, $57, $43        ;; 01:58ee ????????
    db   $0f, $22, $52, $fe, $51, $00, $6e, $43        ;; 01:58f6 ????????
    db   $0f, $22, $52, $fe, $59, $00, $82, $43        ;; 01:58fe ????????
    db   $0f, $22, $52, $fe, $61, $00, $99, $43        ;; 01:5906 ????????
    db   $0f, $22, $52, $fe, $69, $00, $b1, $43        ;; 01:590e ????????
    db   $0f, $22, $52, $fe, $71, $00, $ca, $43        ;; 01:5916 ????????
    db   $0f, $22, $52, $fe, $79, $00, $e1, $43        ;; 01:591e ????????
    db   $0f, $a2, $ff, $52, $fe, $00, $00, $f6        ;; 01:5926 ????????
    db   $43, $0f, $23, $52, $fe, $08, $00, $1a        ;; 01:592e ????????
    db   $44, $0f, $22, $52, $fe, $19, $00, $32        ;; 01:5936 ????????
    db   $44, $0f, $22, $52, $fe, $21, $00, $4e        ;; 01:593e ????????
    db   $44, $0f, $22, $52, $fe, $29, $00, $67        ;; 01:5946 ????????
    db   $44, $0f, $22, $52, $fe, $31, $00, $7f        ;; 01:594e ????????
    db   $44, $0f, $22, $52, $fe, $39, $00, $92        ;; 01:5956 ????????
    db   $44, $0f, $22, $52, $fe, $41, $00, $a6        ;; 01:595e ????????
    db   $44, $0f, $22, $52, $fe, $49, $00, $bb        ;; 01:5966 ????????
    db   $44, $0f, $22, $52, $fe, $51, $00, $d5        ;; 01:596e ????????
    db   $44, $0f, $22, $52, $fe, $59, $00, $eb        ;; 01:5976 ????????
    db   $44, $0f, $22, $52, $fe, $61, $00, $02        ;; 01:597e ????????
    db   $45, $0f, $22, $52, $fe, $69, $00, $18        ;; 01:5986 ????????
    db   $45, $0f, $22, $52, $fe, $71, $00, $2e        ;; 01:598e ????????
    db   $45, $0f, $22, $52, $fe, $79, $00, $47        ;; 01:5996 ????????
    db   $45, $0f, $a2, $ff, $52, $fe, $08, $00        ;; 01:599e ????????
    db   $60, $45, $0f, $23, $52, $fe, $18, $00        ;; 01:59a6 ????????
    db   $92, $45, $0f, $22, $52, $fe, $36, $00        ;; 01:59ae ????????
    db   $ac, $45, $0f, $22, $52, $fe, $40, $00        ;; 01:59b6 ????????
    db   $d1, $45, $0f, $a2, $ff, $52, $fe, $00        ;; 01:59be ????????
    db   $00, $e7, $45, $0f, $23, $52, $fe, $08        ;; 01:59c6 ????????
    db   $00, $fd, $45, $0f, $22, $52, $fe, $1a        ;; 01:59ce ????????
    db   $00, $0b, $46, $0f, $22, $52, $fe, $22        ;; 01:59d6 ????????
    db   $00, $23, $46, $0f, $22, $52, $fe, $34        ;; 01:59de ????????
    db   $00, $3a, $46, $0f, $22, $52, $fe, $3c        ;; 01:59e6 ????????
    db   $00, $50, $46, $0f, $22, $52, $fe, $4e        ;; 01:59ee ????????
    db   $00, $64, $46, $0f, $22, $52, $fe, $56        ;; 01:59f6 ????????
    db   $00, $7d, $46, $0f, $22, $52, $fe, $68        ;; 01:59fe ????????
    db   $00, $95, $46, $0f, $22, $52, $fe, $70        ;; 01:5a06 ????????
    db   $00, $a7, $46, $0f, $a2, $ff, $52, $fe        ;; 01:5a0e ????????
    db   $2e, $00, $bd, $46, $0f, $23, $52, $fe        ;; 01:5a16 ????????
    db   $36, $00, $d9, $46, $0f, $22, $52, $fe        ;; 01:5a1e ????????
    db   $3e, $00, $f3, $46, $0f, $22, $52, $fe        ;; 01:5a26 ????????
    db   $46, $00, $08, $47, $0f, $a2, $ff, $3f        ;; 01:5a2e ????????
    db   $fe, $fe, $01, $c5, $4b, $0f, $a3, $ff        ;; 01:5a36 ????????
    db   $00, $00, $00, $00, $06, $ed, $0f, $e0        ;; 01:5a3e ????????
    db   $ff                                           ;; 01:5a46 ?

data_01_5a47:
    db   $00, $00, $00, $03, $00, $eb, $0f, $24        ;; 01:5a47 w...w...
    db   $01, $00, $00, $03, $01, $eb, $0f, $24        ;; 01:5a4f w...w...
    db   $02, $00, $00, $03, $02, $eb, $0f, $24        ;; 01:5a57 w...w...
    db   $03, $00, $00, $03, $03, $eb, $0f, $24        ;; 01:5a5f w...w...
    db   $04, $00, $00, $03, $04, $eb, $0f, $24        ;; 01:5a67 w...w...
    db   $05, $00, $00, $03, $05, $eb, $0f, $24        ;; 01:5a6f w...w...
    db   $06, $00, $00, $03, $06, $eb, $0f, $24        ;; 01:5a77 w...w...
    db   $07, $00, $00, $03, $07, $eb, $0f, $24        ;; 01:5a7f w...w...
    db   $08, $00, $00, $03, $08, $eb, $0f, $24        ;; 01:5a87 w...w...
    db   $09, $00, $00, $03, $09, $eb, $0f, $24        ;; 01:5a8f w...w...
    db   $0a, $00, $00, $03, $0a, $eb, $0f, $24        ;; 01:5a97 w...w...
    db   $0b, $00, $00, $03, $0b, $eb, $0f, $24        ;; 01:5a9f w...w...
    db   $0c, $00, $00, $03, $0c, $eb, $0f, $24        ;; 01:5aa7 w...w...
    db   $0d, $00, $00, $03, $0d, $eb, $0f, $24        ;; 01:5aaf w...w...
    db   $0e, $00, $00, $03, $0e, $eb, $0f, $24        ;; 01:5ab7 w...w...
    db   $0f, $00, $00, $03, $0f, $eb, $0f, $24        ;; 01:5abf w...w...
    db   $10, $00, $00, $03, $10, $eb, $0f, $24        ;; 01:5ac7 w...w...
    db   $11, $00, $00, $03, $11, $eb, $0f, $a4        ;; 01:5acf w...w...
    db   $ff                                           ;; 01:5ad7 .

data_01_5ad8:
    db   $3d, $fe, $fe, $01                            ;; 01:5ad8 w..w
    dw   $4c56                                         ;; 01:5adc wW
    db   $00, $23, $3e, $fe, $fe, $01                  ;; 01:5ade ..w..w
    dw   $4d0f                                         ;; 01:5ae4 wW
    db   $31, $23, $3f, $fe, $fe, $01                  ;; 01:5ae6 ..w..w
    dw   $4c8f                                         ;; 01:5aec wW
    db   $72, $23, $41, $fe, $fe, $00, $03, $e8        ;; 01:5aee ..w..ww.
    db   $0f, $23, $42, $fe, $fe, $00, $05, $e8        ;; 01:5af6 ..w..ww.
    db   $0f, $23, $43, $fe, $fe, $00, $04, $e8        ;; 01:5afe ..w..ww.
    db   $0f, $23, $44, $fe, $fe, $00, $06, $e8        ;; 01:5b06 ..w..ww.
    db   $0f, $23, $45, $fe, $fe, $00, $0a, $e8        ;; 01:5b0e ..w..ww.
    db   $0f, $23, $46, $00, $00, $00, $00, $00        ;; 01:5b16 ..w.....
    db   $0f, $25, $47, $00, $00, $00, $00, $00        ;; 01:5b1e ..w.....
    db   $0f, $25, $48, $00, $00, $00, $00, $00        ;; 01:5b26 ..w.....
    db   $0f, $25, $49, $00, $00, $00, $00, $00        ;; 01:5b2e ..w.....
    db   $0f, $25, $4a, $00, $00, $00, $00, $00        ;; 01:5b36 ..w.....
    db   $0f, $21, $4b, $00, $00, $00, $00, $00        ;; 01:5b3e ..w.....
    db   $0f, $21, $00, $00, $00, $85, $05, $e1        ;; 01:5b46 ..w..ww.
    db   $0f, $60, $00, $00, $00, $00, $00, $e7        ;; 01:5b4e ..w.....
    db   $0f, $60, $00, $00, $00, $fc, $02, $e6        ;; 01:5b56 ..w..ww.
    db   $0f, $e0, $ff                                 ;; 01:5b5e ...

data_01_5b61:
    db   $bf, $db, $bf, $db, $bf, $db, $69, $5b        ;; 01:5b61 ??????..
    db   $04, $58, $34, $d0, $04, $08, $01, $68        ;; 01:5b69 w.......
    db   $34, $d8, $05, $08, $01, $ff                  ;; 01:5b71 ......

data_01_5b77:
    dw   data_01_5c79                                  ;; 01:5b77 pP
    dw   data_01_5b97                                         ;; 01:5b79 wW
    db   $01, $07, $00, $00                            ;; 01:5b7b ..??

    dw   data_01_6069                                  ;; 01:5b7f pP
    dw   data_01_5bde                                         ;; 01:5b81 wW
    db   $01, $08, $00, $00                            ;; 01:5b83 ..??

    dw   data_01_64e9                                  ;; 01:5b87 pP
    dw   data_01_5c25                                         ;; 01:5b89 wW
    db   $01, $08, $00, $00

    dw   data_01_66f9
    dw   data_01_5c4f        ;; 01:5b8b ..??????
    db   $02, $10, $00, $00
data_01_5b97:
    db   $01, $03, $03, $03        ;; 01:5b97 ????..ww
    db   $03, $03, $03, $03, $03, $01, $03, $03        ;; 01:5b9b ww.www?.
    db   $03, $05, $04, $03, $03, $04, $03, $03        ;; 01:5ba3 wwwww?ww
    db   $03, $03, $05, $05, $03, $03, $03, $03        ;; 01:5bab w.ww...w
    db   $03, $03, $03, $03, $03, $03, $03, $03        ;; 01:5bb3 wwww.???
    db   $03, $03, $03, $03, $03, $03, $03, $03        ;; 01:5bbb .???????
    db   $02, $03, $03, $03, $03, $03, $03, $03        ;; 01:5bc3 ????????
    db   $03, $03, $03, $03, $03, $03, $02, $02        ;; 01:5bcb ??????.?
    db   $03, $04, $01, $02, $03, $03, $02, $02        ;; 01:5bd3 ??...w..
    db   $02, $08, $06
data_01_5bde:
    db   $06, $06, $06, $06, $06        ;; 01:5bde ?.w.w?..
    db   $06, $06, $06, $06, $02, $05, $06, $06        ;; 01:5be3 .www.??.
    db   $07, $07, $06, $06, $06, $06, $06, $06        ;; 01:5beb w...?www
    db   $06, $07, $07, $07, $08, $06, $07, $03        ;; 01:5bf3 ..w..???
    db   $06, $06, $06, $06, $06, $06, $06, $06        ;; 01:5bfb ????????
    db   $08, $05, $05, $06, $06, $07, $05, $04        ;; 01:5c03 ????????
    db   $06, $06, $07, $05, $04, $06, $06, $07        ;; 01:5c0b ????????
    db   $05, $03, $06, $06, $06, $02, $02, $06        ;; 01:5c13 ?????.??
    db   $06, $02, $03, $04, $04, $03, $03, $03        ;; 01:5c1b ????????
    db   $08, $07
data_01_5c25:
    db   $07, $07, $07, $07, $07, $07        ;; 01:5c25 ??w.....
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 01:5c2b ........
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 01:5c33 ..w.....
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 01:5c3b ........
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 01:5c43 ..??????
    db   $07, $07, $07, $07
data_01_5c4f:
    db   $10, $10, $10, $10        ;; 01:5c4f ????????
    db   $10, $10, $10, $10, $10, $10, $10, $10        ;; 01:5c53 ????????
    db   $10, $10, $10, $10, $10, $10, $10, $10        ;; 01:5c5b ????????
    db   $10, $10, $10, $10, $10, $10, $10, $10        ;; 01:5c63 ????????
    db   $10, $10, $10, $10, $10, $10, $10, $10        ;; 01:5c6b ????????
    db   $10, $10, $10, $10, $10, $10                  ;; 01:5c73 ??????

data_01_5c79:
    INCBIN ".gfx/misc_sprites/image_001_5c79.bin"

data_01_6069:
    INCBIN ".gfx/misc_sprites/image_001_6069.bin"

data_01_64e9:
    INCBIN ".gfx/misc_sprites/image_001_64e9.bin"

data_01_66f9:
    INCBIN ".gfx/misc_sprites/image_001_66f9.bin"

data_01_6f39:
    dw   .data_01_6f45, .data_01_6f88, .data_01_6f45, .data_01_6f8b
    dw   .data_01_6fce, .data_01_7051
.data_01_6f45:
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6f48.bin"
.data_01_6f88:
    db   $02, $02, $ff
.data_01_6f8b:
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6f8e.bin"
.data_01_6fce:
    db   $04, $02, $00
    INCBIN ".gfx/misc_sprites/image_001_6fd1.bin"
.data_01_7051:
    db   $02, $02, $00
    INCBIN ".gfx/misc_sprites_horizontal/image_001_7054.bin"
