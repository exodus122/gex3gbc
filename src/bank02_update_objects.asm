entry_02_708f_InitObjectsAndSpawnPlayer:
; Purpose: Initializes core object-related state when entering a level or respawning the player.
; Details:
; Clears many object/flag variables (wDC84–wDC8F, wDABD_UnkBGCollisionFlags–wDABE_UnkBGCollisionFlags2, etc.).
; If a pending object ID exists in wDC78, spawns it using call_02_72ac_SetupNewAction.
; Resets player-facing direction and flags, calls entry_02_7123_ClearObjectSlotsExcludingPlayer to clear object slots, 
; and spawns required relative objects.
; Loops through call_00_360c_SpawnObjectOnceImmediate until the player object (wDAB8_ObjectCounter == 1) is spawned.
    xor  A, A                                          ;; 02:708f $af
    ld   [wDB6A], A                                    ;; 02:7090 $ea $6a $db
    ld   A, [wDC78]                                    ;; 02:7093 $fa $78 $dc
    cp   A, $ff                                        ;; 02:7096 $fe $ff
    jr   Z, .jr_02_70d1                                ;; 02:7098 $28 $37
    xor  A, A                                          ;; 02:709a $af
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:709b $ea $00 $da
    ld   A, $00                                        ;; 02:709e $3e $00
    ld   [wD800_PlayerObject_Id], A                                    ;; 02:70a0 $ea $00 $d8
    ld   A, [wDC78]                                    ;; 02:70a3 $fa $78 $dc
    call call_02_72ac_SetupNewAction                                  ;; 02:70a6 $cd $ac $72
    ld   A, $ff                                        ;; 02:70a9 $3e $ff
    ld   [wDC78], A                                    ;; 02:70ab $ea $78 $dc
    ld   A, $00                                        ;; 02:70ae $3e $00
    ld   [wDC7A], A                                    ;; 02:70b0 $ea $7a $dc
    ld   A, $00                                        ;; 02:70b3 $3e $00
    ld   [wD80D_PlayerFacingDirection], A                                    ;; 02:70b5 $ea $0d $d8
    xor  A, A                                          ;; 02:70b8 $af
    ld   [wDC86], A                                    ;; 02:70b9 $ea $86 $dc
    ld   [wDC87], A                                    ;; 02:70bc $ea $87 $dc
    ld   [wDC8C], A                                    ;; 02:70bf $ea $8c $dc
    ld   [wDC8D], A                                    ;; 02:70c2 $ea $8d $dc
    ld   [wDC8E], A                                    ;; 02:70c5 $ea $8e $dc
    ld   [wDC8F], A                                    ;; 02:70c8 $ea $8f $dc
    ld   [wDC88], A                                    ;; 02:70cb $ea $88 $dc
    ld   [wDC80], A                                    ;; 02:70ce $ea $80 $dc
.jr_02_70d1:
    xor  A, A                                          ;; 02:70d1 $af
    ld   [wDC85], A                                    ;; 02:70d2 $ea $85 $dc
    ld   [wDC84], A                                    ;; 02:70d5 $ea $84 $dc
    ld   [wDABE_UnkBGCollisionFlags2], A                                    ;; 02:70d8 $ea $be $da
    ld   [wDABD_UnkBGCollisionFlags], A                                    ;; 02:70db $ea $bd $da
    ld   A, $ff                                        ;; 02:70de $3e $ff
    ld   [wDC79], A                                    ;; 02:70e0 $ea $79 $dc
    xor  A, A                                          ;; 02:70e3 $af
    ld   [wDC7B], A                                    ;; 02:70e4 $ea $7b $dc
    ld   [wDC7C], A                                    ;; 02:70e7 $ea $7c $dc
    ld   [wDC7D], A                                    ;; 02:70ea $ea $7d $dc
    call call_02_7123_ClearObjectSlotsExcludingPlayer                                  ;; 02:70ed $cd $23 $71
    ld   A, [wDB6D]                                    ;; 02:70f0 $fa $6d $db
    and  A, A                                          ;; 02:70f3 $a7
    jr   Z, .jr_02_7115                                ;; 02:70f4 $28 $1f
    xor  A, A                                          ;; 02:70f6 $af
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:70f7 $ea $00 $da
    ld   C, $19                                        ;; 02:70fa $0e $19
    call call_00_3792_PrepareRelativeObjectSpawn                                  ;; 02:70fc $cd $92 $37
    ld   C, $1b                                        ;; 02:70ff $0e $1b
    call call_00_29ce_ObjectExistsCheck                                  ;; 02:7101 $cd $ce $29
    jr   NZ, .jr_02_7115                               ;; 02:7104 $20 $0f
    ld   A, L                                          ;; 02:7106 $7d
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:7107 $ea $00 $da
    farcall entry_02_5bb3_ObjectAction_UpdateBonusStageTimer
.jr_02_7115:
    call call_00_3252_ResetObjectCounter                                  ;; 02:7115 $cd $52 $32
.jr_02_7118:
    call call_00_360c_SpawnObjectOnceImmediate                                  ;; 02:7118 $cd $0c $36
    ld   A, [wDAB8_ObjectCounter]                                    ;; 02:711b $fa $b8 $da
    cp   A, $01                                        ;; 02:711e $fe $01
    jr   NZ, .jr_02_7118                               ;; 02:7120 $20 $f6
    ret                                                ;; 02:7122 $c9

entry_02_7123_ClearObjectSlotsExcludingPlayer:
call_02_7123_ClearObjectSlotsExcludingPlayer:
; Purpose: Clears seven 32-byte object slots by filling them with $FF.
; Details:
; Starts at wD820_ObjectMemoryAfterPlayer, increments by $20 each time, repeats 7 times.
    ld   HL, wD820_ObjectMemoryAfterPlayer                                     ;; 02:7123 $21 $20 $d8
    ld   DE, $20                                       ;; 02:7126 $11 $20 $00
    ld   B, $07                                        ;; 02:7129 $06 $07
.jr_02_712b:
    ld   [HL], $ff                                     ;; 02:712b $36 $ff
    add  HL, DE                                        ;; 02:712d $19
    dec  B                                             ;; 02:712e $05
    jr   NZ, .jr_02_712b                               ;; 02:712f $20 $fa
    ret                                                ;; 02:7131 $c9

entry_02_7132_BackupObjectTable:
; Purpose: Copies all current object table entries from working memory (wD800) to a backup buffer 
; (wDA09_LoadedObjectIdsBackupBuffer).
; Details:
; Iterates through object slots in steps of $20, copying each byte until wrap-around.
; This is used when pausing
    ld   HL, wD800_PlayerObject_Id                                     ;; 02:7132 $21 $00 $d8
    ld   DE, wDA09_LoadedObjectIdsBackupBuffer                                     ;; 02:7135 $11 $09 $da
.jr_02_7138:
    ld   A, [HL]                                       ;; 02:7138 $7e
    ld   [DE], A                                       ;; 02:7139 $12
    inc  DE                                            ;; 02:713a $13
    ld   A, L                                          ;; 02:713b $7d
    add  A, $20                                        ;; 02:713c $c6 $20
    ld   L, A                                          ;; 02:713e $6f
    jr   NZ, .jr_02_7138                               ;; 02:713f $20 $f7
    ret                                                ;; 02:7141 $c9

entry_02_7142_RestoreObjectTable:
; Purpose: Restores object table entries from the backup buffer back to working memory.
; Details:
; Reverse of BackupObjectTable, writing from wDA09_LoadedObjectIdsBackupBuffer back to wD800.
; This is used when unpausing
    ld   HL, wD800_PlayerObject_Id                                     ;; 02:7142 $21 $00 $d8
    ld   DE, wDA09_LoadedObjectIdsBackupBuffer                                     ;; 02:7145 $11 $09 $da
.jr_02_7148:
    ld   A, [DE]                                       ;; 02:7148 $1a
    ld   [HL], A                                       ;; 02:7149 $77
    inc  DE                                            ;; 02:714a $13
    ld   A, L                                          ;; 02:714b $7d
    add  A, $20                                        ;; 02:714c $c6 $20
    ld   L, A                                          ;; 02:714e $6f
    jr   NZ, .jr_02_7148                               ;; 02:714f $20 $f7
    ret                                                ;; 02:7151 $c9

entry_02_7152_UpdateObjects:
call_02_7152_UpdateObjects:
; Purpose: Master routine for per-frame object updates and player-related checks.
; Details:
; Resets temporary flags and checks conditions in wDCA7.
; Handles special cases for player actions/IDs, adjusts player Y-position (wD810/wD811).
; Invokes object behavior routines (call_00_0f22_JumpHL) for special objects (wDC7B, wDC7D).
; Calls call_02_72fb_UpdateMapWindow to update the scrolling window and environment.
; Iterates through all objects (wDA00_CurrentObjectAddrLo) to run their update logic and 
; finally triggers graphics updates via banked call entry_03_5ec1_UpdateAllObjectsGraphicsAndCollision.
    xor  A, A                                          ;; 02:7152 $af
    ld   [wDC85], A                                    ;; 02:7153 $ea $85 $dc
    ld   [wDC84], A                                    ;; 02:7156 $ea $84 $dc
    ld   [wD900], A                                    ;; 02:7159 $ea $00 $d9
    ld   [wD904], A                                    ;; 02:715c $ea $04 $d9
    ld   A, [wDCA7]                                    ;; 02:715f $fa $a7 $dc
    and  A, A                                          ;; 02:7162 $a7
    jp   Z, .jp_02_7200                                ;; 02:7163 $ca $00 $72
    call call_02_5541_GetActionPropertyByte                                  ;; 02:7166 $cd $41 $55
    and  A, $08                                        ;; 02:7169 $e6 $08
    jr   NZ, .jr_02_717f                               ;; 02:716b $20 $12
    ld   A, [wDC93]                                    ;; 02:716d $fa $93 $dc
    cp   A, $15                                        ;; 02:7170 $fe $15
    jr   Z, .jr_02_7196                                ;; 02:7172 $28 $22
    cp   A, $16                                        ;; 02:7174 $fe $16
    jr   Z, .jr_02_719a                                ;; 02:7176 $28 $22
    ld   A, [wDC92]                                    ;; 02:7178 $fa $92 $dc
    cp   A, $17                                        ;; 02:717b $fe $17
    jr   Z, .jr_02_719e                                ;; 02:717d $28 $1f
.jr_02_717f:
    ld   HL, wDC98                                     ;; 02:717f $21 $98 $dc
    ld   C, [HL]                                       ;; 02:7182 $4e
    ld   A, [wD801_PlayerObject_ActionId]                                    ;; 02:7183 $fa $01 $d8
    cp   A, $09                                        ;; 02:7186 $fe $09
    jr   Z, .jr_02_71a5                                ;; 02:7188 $28 $1b
    cp   A, $29                                        ;; 02:718a $fe $29
    jr   Z, .jr_02_71a5                                ;; 02:718c $28 $17
    cp   A, $36                                        ;; 02:718e $fe $36
    jr   Z, .jr_02_71a5                                ;; 02:7190 $28 $13
    ld   C, $00                                        ;; 02:7192 $0e $00
    jr   .jr_02_71a5                                   ;; 02:7194 $18 $0f
.jr_02_7196:
    ld   C, $02                                        ;; 02:7196 $0e $02
    jr   .jr_02_71a5                                   ;; 02:7198 $18 $0b
.jr_02_719a:
    ld   C, $fe                                        ;; 02:719a $0e $fe
    jr   .jr_02_71a5                                   ;; 02:719c $18 $07
.jr_02_719e:
    ld   A, $20                                        ;; 02:719e $3e $20
    ld   [wDC8C], A                                    ;; 02:71a0 $ea $8c $dc
    jr   .jr_02_71a9                                   ;; 02:71a3 $18 $04
.jr_02_71a5:
    ld   HL, wDC84                                     ;; 02:71a5 $21 $84 $dc
    ld   [HL], C                                       ;; 02:71a8 $71
.jr_02_71a9:
    ld   A, [wDC7B]                                    ;; 02:71a9 $fa $7b $dc
    and  A, A                                          ;; 02:71ac $a7
    jr   Z, .jr_02_71e4                                ;; 02:71ad $28 $35
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:71af $ea $00 $da
    or   A, $02                                        ;; 02:71b2 $f6 $02
    ld   L, A                                          ;; 02:71b4 $6f
    ld   H, $d8                                        ;; 02:71b5 $26 $d8
    ld   A, [HL+]                                      ;; 02:71b7 $2a
    ld   H, [HL]                                       ;; 02:71b8 $66
    ld   L, A                                          ;; 02:71b9 $6f
    call call_00_0f22_JumpHL                                  ;; 02:71ba $cd $22 $0f
    ld   A, [wDC7B]                                    ;; 02:71bd $fa $7b $dc
    and  A, A                                          ;; 02:71c0 $a7
    jr   Z, .jr_02_71e4                                ;; 02:71c1 $28 $21
    ld   H, $d8                                        ;; 02:71c3 $26 $d8
    ld   A, [wDC7B]                                    ;; 02:71c5 $fa $7b $dc
    and  A, $e0                                        ;; 02:71c8 $e6 $e0
    or   A, $10                                        ;; 02:71ca $f6 $10
    ld   L, A                                          ;; 02:71cc $6f
    ld   A, [HL+]                                      ;; 02:71cd $2a
    sub  A, $10                                        ;; 02:71ce $d6 $10
    ld   E, A                                          ;; 02:71d0 $5f
    ld   A, [HL]                                       ;; 02:71d1 $7e
    sbc  A, $00                                        ;; 02:71d2 $de $00
    ld   D, A                                          ;; 02:71d4 $57
    ld   A, L                                          ;; 02:71d5 $7d
    xor  A, $02                                        ;; 02:71d6 $ee $02
    ld   L, A                                          ;; 02:71d8 $6f
    ld   A, E                                          ;; 02:71d9 $7b
    sub  A, [HL]                                       ;; 02:71da $96
    ld   [wD810_PlayerYPosition], A                                    ;; 02:71db $ea $10 $d8
    ld   A, D                                          ;; 02:71de $7a
    sbc  A, $00                                        ;; 02:71df $de $00
    ld   [wD811_PlayerYPosition], A                                    ;; 02:71e1 $ea $11 $d8
.jr_02_71e4:
    ld   A, [wDC7D]                                    ;; 02:71e4 $fa $7d $dc
    and  A, A                                          ;; 02:71e7 $a7
    jr   Z, .jr_02_71f8                                ;; 02:71e8 $28 $0e
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:71ea $ea $00 $da
    or   A, $02                                        ;; 02:71ed $f6 $02
    ld   L, A                                          ;; 02:71ef $6f
    ld   H, $d8                                        ;; 02:71f0 $26 $d8
    ld   A, [HL+]                                      ;; 02:71f2 $2a
    ld   H, [HL]                                       ;; 02:71f3 $66
    ld   L, A                                          ;; 02:71f4 $6f
    call call_00_0f22_JumpHL                                  ;; 02:71f5 $cd $22 $0f
.jr_02_71f8:
    ld   A, $00                                        ;; 02:71f8 $3e $00
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:71fa $ea $00 $da
    call call_02_4f32_PlayerUpdateMain                                  ;; 02:71fd $cd $32 $4f
.jp_02_7200:
    call call_02_72fb_UpdateMapWindow                                  ;; 02:7200 $cd $fb $72
    ld   A, $20                                        ;; 02:7203 $3e $20
.jr_02_7205:
    ld   [wDA00_CurrentObjectAddrLo], A                                    ;; 02:7205 $ea $00 $da
    or   A, $00                                        ;; 02:7208 $f6 $00
    ld   L, A                                          ;; 02:720a $6f
    ld   H, $d8                                        ;; 02:720b $26 $d8
    ld   A, [HL]                                       ;; 02:720d $7e
    cp   A, $ff                                        ;; 02:720e $fe $ff
    jr   Z, .jr_02_723a                                ;; 02:7210 $28 $28
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:7212 $fa $00 $da
    ld   HL, wDC7B                                     ;; 02:7215 $21 $7b $dc
    cp   A, [HL]                                       ;; 02:7218 $be
    jr   Z, .jr_02_722c                                ;; 02:7219 $28 $11
    ld   HL, wDC7D                                     ;; 02:721b $21 $7d $dc
    cp   A, [HL]                                       ;; 02:721e $be
    jr   Z, .jr_02_722c                                ;; 02:721f $28 $0b
    or   A, $02                                        ;; 02:7221 $f6 $02
    ld   L, A                                          ;; 02:7223 $6f
    ld   H, $d8                                        ;; 02:7224 $26 $d8
    ld   A, [HL+]                                      ;; 02:7226 $2a
    ld   H, [HL]                                       ;; 02:7227 $66
    ld   L, A                                          ;; 02:7228 $6f
    call call_00_0f22_JumpHL                                  ;; 02:7229 $cd $22 $0f
.jr_02_722c:
    ld   H, $d8                                        ;; 02:722c $26 $d8
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:722e $fa $00 $da
    or   A, OBJECT_ID_OFFSET                                        ;; 02:7231 $f6 $00
    ld   L, A                                          ;; 02:7233 $6f
    ld   A, [HL]                                       ;; 02:7234 $7e
    cp   A, $ff                                        ;; 02:7235 $fe $ff
    call NZ, call_02_724d_ProcessObjectTimerAndState                              ;; 02:7237 $c4 $4d $72
.jr_02_723a:
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:723a $fa $00 $da
    add  A, $20                                        ;; 02:723d $c6 $20
    jr   NZ, .jr_02_7205                               ;; 02:723f $20 $c4
    farcall entry_03_5ec1_UpdateAllObjectsGraphicsAndCollision
    ret                                                ;; 02:724c $c9

call_02_724d_ProcessObjectTimerAndState:
; Purpose: Handles countdown timers, state flags, and transitions for an individual object slot.
; Details:
; Decrements a timer; when it reaches zero, reloads counters, updates flags (set 2, set 1), and fetches new data from tables.
; Can trigger reinitialization via call_02_54f9_SwitchPlayerAction or call_02_72ac_SetupNewAction.
; Updates related memory locations with new object state values.
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:724d $fa $00 $da
    or   A, OBJECT_FLAGS_OFFSET                                        ;; 02:7250 $f6 $04
    ld   L, A                                          ;; 02:7252 $6f
    ld   H, $d8                                        ;; 02:7253 $26 $d8
    ld   E, [HL]                                       ;; 02:7255 $5e
    inc  L                                             ;; 02:7256 $2c
    res  2, [HL]                                       ;; 02:7257 $cb $96
    ld   B, [HL]                                       ;; 02:7259 $46
    inc  L                                             ;; 02:725a $2c
    ld   C, [HL]                                       ;; 02:725b $4e
    inc  L                                             ;; 02:725c $2c
    ld   A, [HL]                                       ;; 02:725d $7e
    cp   A, $ff                                        ;; 02:725e $fe $ff
    ret  Z                                             ;; 02:7260 $c8
    dec  [HL]                                          ;; 02:7261 $35
    ret  NZ                                            ;; 02:7262 $c0
    ld   [HL], C                                       ;; 02:7263 $71
    inc  L                                             ;; 02:7264 $2c
    ld   A, [HL+]                                      ;; 02:7265 $2a
    ld   C, A                                          ;; 02:7266 $4f
    inc  [HL]                                          ;; 02:7267 $34
    sub  A, [HL]                                       ;; 02:7268 $96
    jr   NZ, .jr_02_7288                               ;; 02:7269 $20 $1d
    bit  7, E                                          ;; 02:726b $cb $7b
    jr   Z, .jr_02_727c                                ;; 02:726d $28 $0d
    res  7, E                                          ;; 02:726f $cb $bb
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:7271 $fa $00 $da
    and  A, A                                          ;; 02:7274 $a7
    ld   A, E                                          ;; 02:7275 $7b
    jp   Z, call_02_54f9_SwitchPlayerAction                               ;; 02:7276 $ca $f9 $54
    jp   call_02_72ac_SetupNewAction                                  ;; 02:7279 $c3 $ac $72
.jr_02_727c:
    bit  3, B                                          ;; 02:727c $cb $58
    jr   Z, .jr_02_7282                                ;; 02:727e $28 $02
    ld   A, C                                          ;; 02:7280 $79
    dec  A                                             ;; 02:7281 $3d
.jr_02_7282:
    ld   [HL-], A                                      ;; 02:7282 $32
    dec  L                                             ;; 02:7283 $2d
    dec  L                                             ;; 02:7284 $2d
    dec  L                                             ;; 02:7285 $2d
    set  2, [HL]                                       ;; 02:7286 $cb $d6
.jr_02_7288:
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:7288 $fa $00 $da
    or   A, $05                                        ;; 02:728b $f6 $05
    ld   L, A                                          ;; 02:728d $6f
    set  1, [HL]                                       ;; 02:728e $cb $ce
    ld   A, L                                          ;; 02:7290 $7d
    xor  A, $0c                                        ;; 02:7291 $ee $0c
    ld   L, A                                          ;; 02:7293 $6f
    ld   E, [HL]                                       ;; 02:7294 $5e
    ld   D, $00                                        ;; 02:7295 $16 $00
    inc  L                                             ;; 02:7297 $2c
    push HL                                            ;; 02:7298 $e5
    inc  L                                             ;; 02:7299 $2c
    ld   A, [HL+]                                      ;; 02:729a $2a
    ld   H, [HL]                                       ;; 02:729b $66
    ld   L, A                                          ;; 02:729c $6f
    add  HL, DE                                        ;; 02:729d $19
    ld   A, [HL]                                       ;; 02:729e $7e
    pop  HL                                            ;; 02:729f $e1
    ld   [HL], A                                       ;; 02:72a0 $77

call_02_72a1_CheckIfPlayerActorUpdatedAction:
; Mark Object Slot Active
; Description:
; Checks if wDA00_CurrentObjectAddrLo is zero (no active object). If so, sets bit0 of 
; wDB66_HDMATransferFlags, likely to indicate that the player actor has changed it's action.
    ld   A, [wDA00_CurrentObjectAddrLo]                                    ;; 02:72a1 $fa $00 $da
    and  A, A                                          ;; 02:72a4 $a7
    ret  NZ                                            ;; 02:72a5 $c0
    ld   HL, wDB66_HDMATransferFlags                                     ;; 02:72a6 $21 $66 $db
    set  0, [HL]                                       ;; 02:72a9 $cb $c6
    ret                                                ;; 02:72ab $c9

entry_02_72ac_SetupNewAction:
call_02_72ac_SetupNewAction:
; Purpose: Loads an object's initialization data from a data table 
; (data_02_4000) into its slot in working memory.
; Details:
; Uses the object ID (masked with $7F) as an index into the object data table.
; Copies attributes like behavior pointers and timers into the object's memory slot.
; Sets auxiliary values and flags (wDB66_HDMATransferFlags bit 0) to indicate a new object was loaded.
    and  A, $7f                                        ;; 02:72ac $e6 $7f
    ld   HL, wDA00_CurrentObjectAddrLo                   ;; 02:72ae $21 $00 $da
    ld   L, [HL]                                       ;; 02:72b1 $6e
    inc  L                                             ;; 02:72b2 $2c
    ld   H, $d8                                        ;; 02:72b3 $26 $d8
    ld   [HL-], A                                      ;; 02:72b5 $32 ; writes new action id to object instance
    ld   L, [HL]                                       ;; 02:72b6 $6e
    ld   H, $00                                        ;; 02:72b7 $26 $00
    add  HL, HL                                        ;; 02:72b9 $29
    ld   DE, data_02_4000                              ;; 02:72ba $11 $00 $40
    add  HL, DE                                        ;; 02:72bd $19
    ld   E, [HL]                                       ;; 02:72be $5e
    inc  HL                                            ;; 02:72bf $23
    ld   D, [HL]                                       ;; 02:72c0 $56
    ld   L, A                                          ;; 02:72c1 $6f ; at this point, DE = ptr to the object's action table
    ld   H, $00                                        ;; 02:72c2 $26 $00
    add  HL, HL                                        ;; 02:72c4 $29
    add  HL, HL                                        ;; 02:72c5 $29
    add  HL, DE                                        ;; 02:72c6 $19
    ld   C, L                                          ;; 02:72c7 $4d
    ld   B, H                                          ;; 02:72c8 $44 ; HL and BC are ptrs to an object action table entry
    ld   A, [wDA00_CurrentObjectAddrLo]                  ;; 02:72c9 $fa $00 $da 
    or   A, OBJECT_ACTIONPTR_OFFSET                    ;; 02:72cc $f6 $02
    ld   L, A                                          ;; 02:72ce $6f
    ld   H, $d8                                        ;; 02:72cf $26 $d8
    ld   A, [BC]                                       ;; 02:72d1 $0a
    ld   [HL+], A                                      ;; 02:72d2 $22
    inc  BC                                            ;; 02:72d3 $03
    ld   A, [BC]                                       ;; 02:72d4 $0a
    ld   [HL+], A                                      ;; 02:72d5 $22 ; updates action func ptr in instance
    inc  BC                                            ;; 02:72d6 $03
    ld   A, [BC]                                       ;; 02:72d7 $0a
    ld   E, A                                          ;; 02:72d8 $5f
    inc  BC                                            ;; 02:72d9 $03
    ld   A, [BC]                                       ;; 02:72da $0a
    ld   D, A                                          ;; 02:72db $57
    ld   A, [DE]                                       ;; 02:72dc $1a ; at this point, DE is ptr to the data for this action
    ld   C, A                                          ;; 02:72dd $4f
    inc  DE                                            ;; 02:72de $13
    ld   A, [DE]                                       ;; 02:72df $1a
    ld   [HL+], A                                      ;; 02:72e0 $22
    inc  DE                                            ;; 02:72e1 $13
    ld   A, [DE]                                       ;; 02:72e2 $1a
    ld   [HL+], A                                      ;; 02:72e3 $22
    inc  DE                                            ;; 02:72e4 $13
    ld   A, [DE]                                       ;; 02:72e5 $1a
    ld   [HL+], A                                      ;; 02:72e6 $22
    ld   [HL+], A                                      ;; 02:72e7 $22
    inc  DE                                            ;; 02:72e8 $13
    ld   A, [DE]                                       ;; 02:72e9 $1a
    ld   [HL+], A                                      ;; 02:72ea $22
    inc  DE                                            ;; 02:72eb $13
    xor  A, A                                          ;; 02:72ec $af
    ld   [HL+], A                                      ;; 02:72ed $22
    ld   A, [DE]                                       ;; 02:72ee $1a
    ld   [HL+], A                                      ;; 02:72ef $22
    ld   [HL], E                                       ;; 02:72f0 $73
    inc  L                                             ;; 02:72f1 $2c
    ld   [HL], D                                       ;; 02:72f2 $72
    ld   A, L                                          ;; 02:72f3 $7d
    xor  A, $1b                                        ;; 02:72f4 $ee $1b
    ld   L, A                                          ;; 02:72f6 $6f
    ld   [HL], C                                       ;; 02:72f7 $71
    jp   call_02_72a1_CheckIfPlayerActorUpdatedAction             ;; 02:72f8 $c3 $a1 $72

entry_02_72fb_UpdateMapWindow:
call_02_72fb_UpdateMapWindow:
; Purpose: Updates player’s map window and handles scrolling or window movement triggers.
; Details:
; Calls call_00_10de_UpdatePlayerMapWindow.
; Delegates Y-position checks to call_02_7305_CheckVerticalMapScroll and X-position checks to call_02_7337_CheckHorizontalMapScroll.
    call call_00_10de_UpdatePlayerMapWindow                                  ;; 02:72fb $cd $de $10
    call call_02_7305_CheckVerticalMapScroll                                  ;; 02:72fe $cd $05 $73
    call call_02_7337_CheckHorizontalMapScroll                                  ;; 02:7301 $cd $37 $73
    ret                                                ;; 02:7304 $c9

call_02_7305_CheckVerticalMapScroll:
; Purpose: Compares current Y-position against previous to determine vertical scrolling needs.
; Details:
; Stores the fine Y-position (wDADA_ScrollY).
; Shifts and subtracts to compute movement delta.
; Sets flags in wDC20 for upward or downward scroll events.
    ld   HL, wDBFB_YPositionInMapLo                                     ;; 02:7305 $21 $fb $db
    ld   A, [HL+]                                      ;; 02:7308 $2a
    ld   D, [HL]                                       ;; 02:7309 $56
    ld   [wDADA_ScrollY], A                                    ;; 02:730a $ea $da $da
    srl  D                                             ;; 02:730d $cb $3a
    rra                                                ;; 02:730f $1f
    srl  D                                             ;; 02:7310 $cb $3a
    rra                                                ;; 02:7312 $1f
    srl  D                                             ;; 02:7313 $cb $3a
    rra                                                ;; 02:7315 $1f
    ld   E, A                                          ;; 02:7316 $5f
    ld   HL, wDBFF_YPositionRelated                                     ;; 02:7317 $21 $ff $db
    ld   A, [HL]                                       ;; 02:731a $7e
    ld   [HL], E                                       ;; 02:731b $73
    sub  A, E                                          ;; 02:731c $93
    ld   E, A                                          ;; 02:731d $5f
    inc  HL                                            ;; 02:731e $23
    ld   A, [HL]                                       ;; 02:731f $7e
    ld   [HL], D                                       ;; 02:7320 $72
    sbc  A, D                                          ;; 02:7321 $9a
    ld   D, A                                          ;; 02:7322 $57
    jr   C, .jr_02_732f                                ;; 02:7323 $38 $0a
    or   A, E                                          ;; 02:7325 $b3
    ret  Z                                             ;; 02:7326 $c8
    ld   HL, wDC20                                     ;; 02:7327 $21 $20 $dc
    ld   A, [HL]                                       ;; 02:732a $7e
    or   A, $01                                        ;; 02:732b $f6 $01
    ld   [HL], A                                       ;; 02:732d $77
    ret                                                ;; 02:732e $c9
.jr_02_732f:
    ld   HL, wDC20                                     ;; 02:732f $21 $20 $dc
    ld   A, [HL]                                       ;; 02:7332 $7e
    or   A, $02                                        ;; 02:7333 $f6 $02
    ld   [HL], A                                       ;; 02:7335 $77
    ret                                                ;; 02:7336 $c9

call_02_7337_CheckHorizontalMapScroll:
; Purpose: Analogous to CheckVerticalMapScroll, but for the X-axis.
; Details:
; Uses wDBF9_XPositionInMapLo and related values.
; Updates horizontal scroll flags in wDC20.
    ld   HL, wDBF9_XPositionInMapLo                                     ;; 02:7337 $21 $f9 $db
    ld   A, [HL+]                                      ;; 02:733a $2a
    ld   D, [HL]                                       ;; 02:733b $56
    ld   [wDAD9_ScrollX], A                                    ;; 02:733c $ea $d9 $da
    srl  D                                             ;; 02:733f $cb $3a
    rra                                                ;; 02:7341 $1f
    srl  D                                             ;; 02:7342 $cb $3a
    rra                                                ;; 02:7344 $1f
    srl  D                                             ;; 02:7345 $cb $3a
    rra                                                ;; 02:7347 $1f
    ld   E, A                                          ;; 02:7348 $5f
    ld   HL, wDBFD_XPositionRelated                                     ;; 02:7349 $21 $fd $db
    ld   A, [HL]                                       ;; 02:734c $7e
    ld   [HL], E                                       ;; 02:734d $73
    ld   C, A                                          ;; 02:734e $4f
    sub  A, E                                          ;; 02:734f $93
    ld   E, A                                          ;; 02:7350 $5f
    inc  HL                                            ;; 02:7351 $23
    ld   A, [HL]                                       ;; 02:7352 $7e
    ld   [HL], D                                       ;; 02:7353 $72
    ld   B, A                                          ;; 02:7354 $47
    sbc  A, D                                          ;; 02:7355 $9a
    ld   D, A                                          ;; 02:7356 $57
    jr   C, .jr_02_737b                                ;; 02:7357 $38 $22
    or   A, E                                          ;; 02:7359 $b3
    ret  Z                                             ;; 02:735a $c8
    ld   A, [wDC2A]                                    ;; 02:735b $fa $2a $dc
    cp   A, $00                                        ;; 02:735e $fe $00
    jr   NZ, .jr_02_7373                               ;; 02:7360 $20 $11
    ld   HL, wDBFD_XPositionRelated                                     ;; 02:7362 $21 $fd $db
    ld   A, [HL+]                                      ;; 02:7365 $2a
    or   A, [HL]                                       ;; 02:7366 $b6
    jr   NZ, .jr_02_7373                               ;; 02:7367 $20 $0a
    ld   A, C                                          ;; 02:7369 $79
    sub  A, $ff                                        ;; 02:736a $d6 $ff
    ld   C, A                                          ;; 02:736c $4f
    ld   A, B                                          ;; 02:736d $78
    sbc  A, $01                                        ;; 02:736e $de $01
    or   A, C                                          ;; 02:7370 $b1
    jr   Z, .jr_02_7393                                ;; 02:7371 $28 $20
.jr_02_7373:
    ld   HL, wDC20                                     ;; 02:7373 $21 $20 $dc
    ld   A, [HL]                                       ;; 02:7376 $7e
    or   A, $04                                        ;; 02:7377 $f6 $04
    ld   [HL], A                                       ;; 02:7379 $77
    ret                                                ;; 02:737a $c9
.jr_02_737b:
    ld   A, [wDC2A]                                    ;; 02:737b $fa $2a $dc
    cp   A, $00                                        ;; 02:737e $fe $00
    jr   NZ, .jr_02_7393                               ;; 02:7380 $20 $11
    ld   A, C                                          ;; 02:7382 $79
    or   A, B                                          ;; 02:7383 $b0
    jr   NZ, .jr_02_7393                               ;; 02:7384 $20 $0d
    ld   HL, wDBFD_XPositionRelated                                     ;; 02:7386 $21 $fd $db
    ld   A, [HL+]                                      ;; 02:7389 $2a
    sub  A, $ff                                        ;; 02:738a $d6 $ff
    ld   C, A                                          ;; 02:738c $4f
    ld   A, [HL]                                       ;; 02:738d $7e
    sbc  A, $01                                        ;; 02:738e $de $01
    or   A, C                                          ;; 02:7390 $b1
    jr   Z, .jr_02_7373                                ;; 02:7391 $28 $e0
.jr_02_7393:
    ld   HL, wDC20                                     ;; 02:7393 $21 $20 $dc
    ld   A, [HL]                                       ;; 02:7396 $7e
    or   A, $08                                        ;; 02:7397 $f6 $08
    ld   [HL], A                                       ;; 02:7399 $77
    ret                                                ;; 02:739a $c9
