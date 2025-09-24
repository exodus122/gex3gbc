SECTION "bank04", ROMX[$4000], BANK[$04]

entry_04_4000_Audio:
    jp   call_04_40e3                                    ;; 04:4000 $c3 $e3 $40
    db   $c3, $7b, $48                                 ;; 04:4003 ???

entry_04_4006_Audio:
    jp   call_04_412b                                    ;; 04:4006 $c3 $2b $41

call_04_4009:
    jp   call_04_402b                                    ;; 04:4009 $c3 $2b $40
    db   $c3, $cb, $41, $c3, $1e, $49, $c3, $65        ;; 04:400c ????????
    db   $40, $c3, $73, $40, $c3, $32, $40, $c3        ;; 04:4014 ????????
    db   $79, $40, $c3, $59, $40, $c3, $27, $40        ;; 04:401c ????????

entry_04_4024_Audio:
    jp   call_04_40af                                    ;; 04:4024 $c3 $af $40
    db   $ea, $78, $df, $c9                            ;; 04:4027 ????

call_04_402b:
    call call_04_41cb                                  ;; 04:402b $cd $cb $41
    call call_04_491e                                  ;; 04:402e $cd $1e $49
    ret                                                ;; 04:4031 $c9
    db   $f0, $24, $e6, $07, $28, $07, $3d, $f6        ;; 04:4032 ????????
    db   $08, $47, $c3, $41, $40, $06, $00, $f0        ;; 04:403a ????????
    db   $24, $e6, $70, $28, $05, $d6, $10, $c3        ;; 04:4042 ????????
    db   $4e, $40, $3e, $00, $b0, $fe, $00, $20        ;; 04:404a ????????
    db   $03, $cd, $65, $40, $e0, $24, $c9, $af        ;; 04:4052 ????????
    db   $e0, $25, $ea, $79, $df, $e0, $24, $ea        ;; 04:405a ????????
    db   $76, $df, $c9, $3e, $00, $e0, $12, $e0        ;; 04:4062 ????????
    db   $17, $e0, $1c, $e0, $21, $ea, $76, $df        ;; 04:406a ????????
    db   $c9, $3e, $ff, $ea, $76, $df, $c9, $cd        ;; 04:4072 ????????
    db   $73, $40, $f0, $24, $fe, $00, $20, $05        ;; 04:407a ????????
    db   $3e, $88, $e0, $24, $c9, $e6, $07, $fe        ;; 04:4082 ????????
    db   $07, $28, $03, $c6, $01, $47, $f0, $24        ;; 04:408a ????????
    db   $e6, $70, $cb, $3f, $cb, $3f, $cb, $3f        ;; 04:4092 ????????
    db   $cb, $3f, $fe, $07, $c8, $c6, $01, $cb        ;; 04:409a ????????
    db   $27, $cb, $27, $cb, $27, $cb, $27, $b0        ;; 04:40a2 ????????
    db   $f6, $88, $e0, $24, $c9                       ;; 04:40aa ?????

call_04_40af:
    add  A, A                                          ;; 04:40af $87
    add  A, A                                          ;; 04:40b0 $87
    ld   HL, data_04_4a59                              ;; 04:40b1 $21 $59 $4a
    add  A, L                                          ;; 04:40b4 $85
    ld   L, A                                          ;; 04:40b5 $6f
    jr   NC, .jr_04_40b9                               ;; 04:40b6 $30 $01
    inc  H                                             ;; 04:40b8 $24
.jr_04_40b9:
    ld   A, [HL]                                       ;; 04:40b9 $7e
    cp   A, $ff                                        ;; 04:40ba $fe $ff
    jr   Z, .jr_04_40c1                                ;; 04:40bc $28 $03
    call call_04_40dd                                  ;; 04:40be $cd $dd $40
.jr_04_40c1:
    inc  HL                                            ;; 04:40c1 $23
    ld   A, [HL]                                       ;; 04:40c2 $7e
    cp   A, $ff                                        ;; 04:40c3 $fe $ff
    jr   Z, .jr_04_40ca                                ;; 04:40c5 $28 $03
    call call_04_40dd                                  ;; 04:40c7 $cd $dd $40
.jr_04_40ca:
    inc  HL                                            ;; 04:40ca $23
    ld   A, [HL]                                       ;; 04:40cb $7e
    cp   A, $ff                                        ;; 04:40cc $fe $ff
    jr   Z, .jr_04_40d3                                ;; 04:40ce $28 $03
    call call_04_40dd                                  ;; 04:40d0 $cd $dd $40
.jr_04_40d3:
    inc  HL                                            ;; 04:40d3 $23
    ld   A, [HL]                                       ;; 04:40d4 $7e
    cp   A, $ff                                        ;; 04:40d5 $fe $ff
    jr   Z, .jr_04_40dc                                ;; 04:40d7 $28 $03
    call call_04_40dd                                  ;; 04:40d9 $cd $dd $40
.jr_04_40dc:
    ret                                                ;; 04:40dc $c9

call_04_40dd:
    push HL                                            ;; 04:40dd $e5
    call call_04_487b                                  ;; 04:40de $cd $7b $48
    pop  HL                                            ;; 04:40e1 $e1
    ret                                                ;; 04:40e2 $c9

call_04_40e3:
    ld   A, $00                                        ;; 04:40e3 $3e $00
    ldh  [rNR52], A                                    ;; 04:40e5 $e0 $26
    nop                                                ;; 04:40e7 $00
    ldh  [rNR52], A                                    ;; 04:40e8 $e0 $26
    ld   [wDF68], A                                    ;; 04:40ea $ea $68 $df
    ld   [wDF69], A                                    ;; 04:40ed $ea $69 $df
    ld   [wDF6B], A                                    ;; 04:40f0 $ea $6b $df
    ld   [wDF6C], A                                    ;; 04:40f3 $ea $6c $df
    ld   [wDF6E], A                                    ;; 04:40f6 $ea $6e $df
    ld   [wDF6F], A                                    ;; 04:40f9 $ea $6f $df
    ld   [wDF71], A                                    ;; 04:40fc $ea $71 $df
    ld   [wDF72], A                                    ;; 04:40ff $ea $72 $df
    ld   [wDF00], A                                    ;; 04:4102 $ea $00 $df
    ld   [wDF18], A                                    ;; 04:4105 $ea $18 $df
    ld   [wDF30], A                                    ;; 04:4108 $ea $30 $df
    ld   [wDF48], A                                    ;; 04:410b $ea $48 $df
    ld   A, $ff                                        ;; 04:410e $3e $ff
    ld   [wDF78], A                                    ;; 04:4110 $ea $78 $df
    ld   A, $01                                        ;; 04:4113 $3e $01
    ld   [wDF77], A                                    ;; 04:4115 $ea $77 $df
    ld   DE, $ff30                                     ;; 04:4118 $11 $30 $ff
    ld   HL, data_04_49dd                              ;; 04:411b $21 $dd $49
    ld   B, $10                                        ;; 04:411e $06 $10
.jr_04_4120:
    ld   A, [HL]                                       ;; 04:4120 $7e
    ld   [DE], A                                       ;; 04:4121 $12
    inc  HL                                            ;; 04:4122 $23
    inc  DE                                            ;; 04:4123 $13
    dec  B                                             ;; 04:4124 $05
    jr   NZ, .jr_04_4120                               ;; 04:4125 $20 $f9
    call call_04_418b                                  ;; 04:4127 $cd $8b $41
    ret                                                ;; 04:412a $c9

call_04_412b:
    ld   L, A                                          ;; 04:412b $6f
    ld   H, $00                                        ;; 04:412c $26 $00
    add  HL, HL                                        ;; 04:412e $29
    ld   D, H                                          ;; 04:412f $54
    ld   E, L                                          ;; 04:4130 $5d
    add  HL, HL                                        ;; 04:4131 $29
    add  HL, HL                                        ;; 04:4132 $29
    add  HL, DE                                        ;; 04:4133 $19
    ld   DE, data_04_7085                              ;; 04:4134 $11 $85 $70
    add  HL, DE                                        ;; 04:4137 $19
    ld   A, [HL+]                                      ;; 04:4138 $2a
    ld   [wDF02], A                                    ;; 04:4139 $ea $02 $df
    ld   A, [HL+]                                      ;; 04:413c $2a
    ld   [wDF03], A                                    ;; 04:413d $ea $03 $df
    ld   A, [HL+]                                      ;; 04:4140 $2a
    ld   [wDF1A], A                                    ;; 04:4141 $ea $1a $df
    ld   A, [HL+]                                      ;; 04:4144 $2a
    ld   [wDF1B], A                                    ;; 04:4145 $ea $1b $df
    ld   A, [HL+]                                      ;; 04:4148 $2a
    ld   [wDF32], A                                    ;; 04:4149 $ea $32 $df
    ld   A, [HL+]                                      ;; 04:414c $2a
    ld   [wDF33], A                                    ;; 04:414d $ea $33 $df
    ld   A, [HL+]                                      ;; 04:4150 $2a
    ld   [wDF4A], A                                    ;; 04:4151 $ea $4a $df
    ld   A, [HL+]                                      ;; 04:4154 $2a
    ld   [wDF4B], A                                    ;; 04:4155 $ea $4b $df
    ld   A, [HL+]                                      ;; 04:4158 $2a
    ld   [wDF60], A                                    ;; 04:4159 $ea $60 $df
    ld   A, [HL+]                                      ;; 04:415c $2a
    ld   [wDF61], A                                    ;; 04:415d $ea $61 $df
    ld   A, $01                                        ;; 04:4160 $3e $01
    ld   [wDF01], A                                    ;; 04:4162 $ea $01 $df
    ld   [wDF19], A                                    ;; 04:4165 $ea $19 $df
    ld   A, $02                                        ;; 04:4168 $3e $02
    ld   [wDF31], A                                    ;; 04:416a $ea $31 $df
    ld   [wDF49], A                                    ;; 04:416d $ea $49 $df
    ld   A, $03                                        ;; 04:4170 $3e $03
    ld   [wDF00], A                                    ;; 04:4172 $ea $00 $df
    ld   [wDF18], A                                    ;; 04:4175 $ea $18 $df
    ld   [wDF30], A                                    ;; 04:4178 $ea $30 $df
    ld   [wDF48], A                                    ;; 04:417b $ea $48 $df
    ld   [wDF76], A                                    ;; 04:417e $ea $76 $df
    ld   A, $ff                                        ;; 04:4181 $3e $ff
    ld   [wDF78], A                                    ;; 04:4183 $ea $78 $df
    ld   A, $01                                        ;; 04:4186 $3e $01
    ld   [wDF77], A                                    ;; 04:4188 $ea $77 $df

call_04_418b:
    ld   A, $8f                                        ;; 04:418b $3e $8f
    ldh  [rNR52], A                                    ;; 04:418d $e0 $26
    nop                                                ;; 04:418f $00
    nop                                                ;; 04:4190 $00
    ldh  [rNR52], A                                    ;; 04:4191 $e0 $26
    ld   A, $08                                        ;; 04:4193 $3e $08
    ldh  [rNR10], A                                    ;; 04:4195 $e0 $10
    ld   A, $ff                                        ;; 04:4197 $3e $ff
    ldh  [rNR51], A                                    ;; 04:4199 $e0 $25
    ld   [wDF79], A                                    ;; 04:419b $ea $79 $df
    ld   A, $77                                        ;; 04:419e $3e $77
    ldh  [rNR50], A                                    ;; 04:41a0 $e0 $24
    ld   A, $80                                        ;; 04:41a2 $3e $80
    ldh  [rNR30], A                                    ;; 04:41a4 $e0 $1a
    xor  A, A                                          ;; 04:41a6 $af
    ldh  [rNR12], A                                    ;; 04:41a7 $e0 $12
    ldh  [rNR22], A                                    ;; 04:41a9 $e0 $17
    ldh  [rNR32], A                                    ;; 04:41ab $e0 $1c
    ldh  [rNR42], A                                    ;; 04:41ad $e0 $21
    ld   [wDF14], A                                    ;; 04:41af $ea $14 $df
    ld   [wDF2C], A                                    ;; 04:41b2 $ea $2c $df
    ld   [wDF44], A                                    ;; 04:41b5 $ea $44 $df
    ld   [wDF5C], A                                    ;; 04:41b8 $ea $5c $df
    ld   [wDF15], A                                    ;; 04:41bb $ea $15 $df
    ld   [wDF2D], A                                    ;; 04:41be $ea $2d $df
    ld   [wDF45], A                                    ;; 04:41c1 $ea $45 $df
    ld   [wDF5D], A                                    ;; 04:41c4 $ea $5d $df
    ld   [wDF55], A                                    ;; 04:41c7 $ea $55 $df
    ret                                                ;; 04:41ca $c9

call_04_41cb:
    ld   A, [wDF76]                                    ;; 04:41cb $fa $76 $df
    and  A, A                                          ;; 04:41ce $a7
    ret  Z                                             ;; 04:41cf $c8
    ld   A, [wDF78]                                    ;; 04:41d0 $fa $78 $df
    ld   B, A                                          ;; 04:41d3 $47
    ld   A, [wDF77]                                    ;; 04:41d4 $fa $77 $df
    add  A, B                                          ;; 04:41d7 $80
    ld   [wDF77], A                                    ;; 04:41d8 $ea $77 $df
    ret  NC                                            ;; 04:41db $d0
.jr_04_41dc:
    xor  A, A                                          ;; 04:41dc $af
    ld   [wDF7B], A                                    ;; 04:41dd $ea $7b $df
    ld   HL, wDF62                                     ;; 04:41e0 $21 $62 $df
    ld   DE, .jr_04_41dc                             ;; 04:41e3 $11 $dc $41
    ld   [HL], E                                       ;; 04:41e6 $73
    inc  HL                                            ;; 04:41e7 $23
    ld   [HL], D                                       ;; 04:41e8 $72
    ld   A, [wDF14]                                    ;; 04:41e9 $fa $14 $df
    ld   [wDF65], A                                    ;; 04:41ec $ea $65 $df
    ld   HL, wDF00                                     ;; 04:41ef $21 $00 $df
    ld   DE, rNR11                                     ;; 04:41f2 $11 $11 $ff
    call call_04_44d4                                  ;; 04:41f5 $cd $d4 $44
    ld   A, [wDF00]                                    ;; 04:41f8 $fa $00 $df
    and  A, $01                                        ;; 04:41fb $e6 $01
    jp   Z, .jp_04_429b                                ;; 04:41fd $ca $9b $42
    ld   A, [wDF69]                                    ;; 04:4200 $fa $69 $df
    and  A, A                                          ;; 04:4203 $a7
    jp   NZ, .jp_04_429b                               ;; 04:4204 $c2 $9b $42
    ld   HL, wDF0A                                     ;; 04:4207 $21 $0a $df
    ld   DE, wDF0B                                     ;; 04:420a $11 $0b $df
    ld   A, [DE]                                       ;; 04:420d $1a
    ld   C, A                                          ;; 04:420e $4f
    inc  DE                                            ;; 04:420f $13
    ld   A, [DE]                                       ;; 04:4210 $1a
    ld   B, A                                          ;; 04:4211 $47
    ld   DE, rNR12                                     ;; 04:4212 $11 $12 $ff
    call call_04_446c                                  ;; 04:4215 $cd $6c $44
    ld   DE, wDF0B                                     ;; 04:4218 $11 $0b $df
    ld   A, C                                          ;; 04:421b $79
    ld   [DE], A                                       ;; 04:421c $12
    ld   A, B                                          ;; 04:421d $78
    inc  DE                                            ;; 04:421e $13
    ld   [DE], A                                       ;; 04:421f $12
    ld   HL, wDF00                                     ;; 04:4220 $21 $00 $df
    ld   DE, rNR13                                     ;; 04:4223 $11 $13 $ff
    call call_04_45a7                                  ;; 04:4226 $cd $a7 $45
    ld   HL, wDF0D                                     ;; 04:4229 $21 $0d $df
    ld   DE, wDF0E                                     ;; 04:422c $11 $0e $df
    ld   A, [DE]                                       ;; 04:422f $1a
    ld   C, A                                          ;; 04:4230 $4f
    inc  DE                                            ;; 04:4231 $13
    ld   A, [DE]                                       ;; 04:4232 $1a
    ld   B, A                                          ;; 04:4233 $47
    ld   DE, wDF05                                     ;; 04:4234 $11 $05 $df
    call call_04_4494                                  ;; 04:4237 $cd $94 $44
    ld   DE, wDF0E                                     ;; 04:423a $11 $0e $df
    ld   A, C                                          ;; 04:423d $79
    ld   [DE], A                                       ;; 04:423e $12
    ld   A, B                                          ;; 04:423f $78
    inc  DE                                            ;; 04:4240 $13
    ld   [DE], A                                       ;; 04:4241 $12
    ld   A, [wDF10]                                    ;; 04:4242 $fa $10 $df
    and  A, A                                          ;; 04:4245 $a7
    jr   Z, .jp_04_429b                                ;; 04:4246 $28 $53
    dec  A                                             ;; 04:4248 $3d
    ld   [wDF10], A                                    ;; 04:4249 $ea $10 $df
    and  A, A                                          ;; 04:424c $a7
    jr   NZ, .jp_04_429b                               ;; 04:424d $20 $4c
    ld   A, [wDF11]                                    ;; 04:424f $fa $11 $df
    ld   C, A                                          ;; 04:4252 $4f
    ld   A, [wDF12]                                    ;; 04:4253 $fa $12 $df
    ld   B, A                                          ;; 04:4256 $47
    ld   A, [BC]                                       ;; 04:4257 $0a
    cp   A, $ff                                        ;; 04:4258 $fe $ff
    jr   Z, .jr_04_428c                                ;; 04:425a $28 $30
    ld   [wDF10], A                                    ;; 04:425c $ea $10 $df
    inc  BC                                            ;; 04:425f $03
    ld   A, [BC]                                       ;; 04:4260 $0a
    ld   E, A                                          ;; 04:4261 $5f
    ld   A, [wDF7C]                                    ;; 04:4262 $fa $7c $df
    add  A, E                                          ;; 04:4265 $83
    push AF                                            ;; 04:4266 $f5
    ld   DE, data_04_481b                              ;; 04:4267 $11 $1b $48
    add  A, E                                          ;; 04:426a $83
    ld   E, A                                          ;; 04:426b $5f
    jr   NC, .jr_04_426f                               ;; 04:426c $30 $01
    inc  D                                             ;; 04:426e $14
.jr_04_426f:
    ld   A, [DE]                                       ;; 04:426f $1a
    ld   [wDF04], A                                    ;; 04:4270 $ea $04 $df
    pop  AF                                            ;; 04:4273 $f1
    ld   DE, data_04_47bb                              ;; 04:4274 $11 $bb $47
    add  A, E                                          ;; 04:4277 $83
    ld   E, A                                          ;; 04:4278 $5f
    jr   NC, .jr_04_427c                               ;; 04:4279 $30 $01
    inc  D                                             ;; 04:427b $14
.jr_04_427c:
    ld   A, [DE]                                       ;; 04:427c $1a
    ld   [wDF05], A                                    ;; 04:427d $ea $05 $df
    inc  BC                                            ;; 04:4280 $03
    ld   A, C                                          ;; 04:4281 $79
    ld   [wDF11], A                                    ;; 04:4282 $ea $11 $df
    ld   A, B                                          ;; 04:4285 $78
    ld   [wDF12], A                                    ;; 04:4286 $ea $12 $df
    jp   .jp_04_429b                                   ;; 04:4289 $c3 $9b $42
.jr_04_428c:
    ld   A, $01                                        ;; 04:428c $3e $01
    ld   [wDF10], A                                    ;; 04:428e $ea $10 $df
    inc  BC                                            ;; 04:4291 $03
    ld   A, [BC]                                       ;; 04:4292 $0a
    ld   [wDF11], A                                    ;; 04:4293 $ea $11 $df
    inc  BC                                            ;; 04:4296 $03
    ld   A, [BC]                                       ;; 04:4297 $0a
    ld   [wDF12], A                                    ;; 04:4298 $ea $12 $df
.jp_04_429b:
    ld   A, $01                                        ;; 04:429b $3e $01
    ld   [wDF7B], A                                    ;; 04:429d $ea $7b $df
    ld   HL, wDF62                                     ;; 04:42a0 $21 $62 $df
    ld   DE, .jp_04_429b                               ;; 04:42a3 $11 $9b $42
    ld   [HL], E                                       ;; 04:42a6 $73
    inc  HL                                            ;; 04:42a7 $23
    ld   [HL], D                                       ;; 04:42a8 $72
    ld   A, [wDF2C]                                    ;; 04:42a9 $fa $2c $df
    ld   [wDF65], A                                    ;; 04:42ac $ea $65 $df
    ld   HL, wDF18                                     ;; 04:42af $21 $18 $df
    ld   DE, rNR21                                     ;; 04:42b2 $11 $16 $ff
    call call_04_44d4                                  ;; 04:42b5 $cd $d4 $44
    ld   A, [wDF18]                                    ;; 04:42b8 $fa $18 $df
    and  A, $01                                        ;; 04:42bb $e6 $01
    jp   Z, .jp_04_435b                                ;; 04:42bd $ca $5b $43
    ld   A, [wDF6C]                                    ;; 04:42c0 $fa $6c $df
    and  A, A                                          ;; 04:42c3 $a7
    jp   NZ, .jp_04_435b                               ;; 04:42c4 $c2 $5b $43
    ld   HL, wDF22                                     ;; 04:42c7 $21 $22 $df
    ld   DE, wDF23                                     ;; 04:42ca $11 $23 $df
    ld   A, [DE]                                       ;; 04:42cd $1a
    ld   C, A                                          ;; 04:42ce $4f
    inc  DE                                            ;; 04:42cf $13
    ld   A, [DE]                                       ;; 04:42d0 $1a
    ld   B, A                                          ;; 04:42d1 $47
    ld   DE, rNR22                                     ;; 04:42d2 $11 $17 $ff
    call call_04_446c                                  ;; 04:42d5 $cd $6c $44
    ld   DE, wDF23                                     ;; 04:42d8 $11 $23 $df
    ld   A, C                                          ;; 04:42db $79
    ld   [DE], A                                       ;; 04:42dc $12
    ld   A, B                                          ;; 04:42dd $78
    inc  DE                                            ;; 04:42de $13
    ld   [DE], A                                       ;; 04:42df $12
    ld   HL, wDF18                                     ;; 04:42e0 $21 $18 $df
    ld   DE, rNR23                                     ;; 04:42e3 $11 $18 $ff
    call call_04_45a7                                  ;; 04:42e6 $cd $a7 $45
    ld   HL, wDF25                                     ;; 04:42e9 $21 $25 $df
    ld   DE, wDF26                                     ;; 04:42ec $11 $26 $df
    ld   A, [DE]                                       ;; 04:42ef $1a
    ld   C, A                                          ;; 04:42f0 $4f
    inc  DE                                            ;; 04:42f1 $13
    ld   A, [DE]                                       ;; 04:42f2 $1a
    ld   B, A                                          ;; 04:42f3 $47
    ld   DE, wDF1D                                     ;; 04:42f4 $11 $1d $df
    call call_04_4494                                  ;; 04:42f7 $cd $94 $44
    ld   DE, wDF26                                     ;; 04:42fa $11 $26 $df
    ld   A, C                                          ;; 04:42fd $79
    ld   [DE], A                                       ;; 04:42fe $12
    ld   A, B                                          ;; 04:42ff $78
    inc  DE                                            ;; 04:4300 $13
    ld   [DE], A                                       ;; 04:4301 $12
    ld   A, [wDF28]                                    ;; 04:4302 $fa $28 $df
    and  A, A                                          ;; 04:4305 $a7
    jr   Z, .jp_04_435b                                ;; 04:4306 $28 $53
    dec  A                                             ;; 04:4308 $3d
    ld   [wDF28], A                                    ;; 04:4309 $ea $28 $df
    and  A, A                                          ;; 04:430c $a7
    jr   NZ, .jp_04_435b                               ;; 04:430d $20 $4c
    ld   A, [wDF29]                                    ;; 04:430f $fa $29 $df
    ld   C, A                                          ;; 04:4312 $4f
    ld   A, [wDF2A]                                    ;; 04:4313 $fa $2a $df
    ld   B, A                                          ;; 04:4316 $47
    ld   A, [BC]                                       ;; 04:4317 $0a
    cp   A, $ff                                        ;; 04:4318 $fe $ff
    jr   Z, .jr_04_434c                                ;; 04:431a $28 $30
    ld   [wDF28], A                                    ;; 04:431c $ea $28 $df
    inc  BC                                            ;; 04:431f $03
    ld   A, [BC]                                       ;; 04:4320 $0a
    ld   E, A                                          ;; 04:4321 $5f
    ld   A, [wDF7D]                                    ;; 04:4322 $fa $7d $df
    add  A, E                                          ;; 04:4325 $83
    push AF                                            ;; 04:4326 $f5
    ld   DE, data_04_481b                              ;; 04:4327 $11 $1b $48
    add  A, E                                          ;; 04:432a $83
    ld   E, A                                          ;; 04:432b $5f
    jr   NC, .jr_04_432f                               ;; 04:432c $30 $01
    inc  D                                             ;; 04:432e $14
.jr_04_432f:
    ld   A, [DE]                                       ;; 04:432f $1a
    ld   [wDF1C], A                                    ;; 04:4330 $ea $1c $df
    pop  AF                                            ;; 04:4333 $f1
    ld   DE, data_04_47bb                              ;; 04:4334 $11 $bb $47
    add  A, E                                          ;; 04:4337 $83
    ld   E, A                                          ;; 04:4338 $5f
    jr   NC, .jr_04_433c                               ;; 04:4339 $30 $01
    inc  D                                             ;; 04:433b $14
.jr_04_433c:
    ld   A, [DE]                                       ;; 04:433c $1a
    ld   [wDF1D], A                                    ;; 04:433d $ea $1d $df
    inc  BC                                            ;; 04:4340 $03
    ld   A, C                                          ;; 04:4341 $79
    ld   [wDF29], A                                    ;; 04:4342 $ea $29 $df
    ld   A, B                                          ;; 04:4345 $78
    ld   [wDF2A], A                                    ;; 04:4346 $ea $2a $df
    jp   .jp_04_435b                                   ;; 04:4349 $c3 $5b $43
.jr_04_434c:
    ld   A, $01                                        ;; 04:434c $3e $01
    ld   [wDF28], A                                    ;; 04:434e $ea $28 $df
    inc  BC                                            ;; 04:4351 $03
    ld   A, [BC]                                       ;; 04:4352 $0a
    ld   [wDF29], A                                    ;; 04:4353 $ea $29 $df
    inc  BC                                            ;; 04:4356 $03
    ld   A, [BC]                                       ;; 04:4357 $0a
    ld   [wDF2A], A                                    ;; 04:4358 $ea $2a $df
.jp_04_435b:
    ld   A, $02                                        ;; 04:435b $3e $02
    ld   [wDF7B], A                                    ;; 04:435d $ea $7b $df
    ld   HL, wDF62                                     ;; 04:4360 $21 $62 $df
    ld   DE, .jp_04_435b                               ;; 04:4363 $11 $5b $43
    ld   [HL], E                                       ;; 04:4366 $73
    inc  HL                                            ;; 04:4367 $23
    ld   [HL], D                                       ;; 04:4368 $72
    ld   A, [wDF44]                                    ;; 04:4369 $fa $44 $df
    ld   [wDF65], A                                    ;; 04:436c $ea $65 $df
    ld   HL, wDF30                                     ;; 04:436f $21 $30 $df
    ld   DE, rNR31                                     ;; 04:4372 $11 $1b $ff
    call call_04_44d4                                  ;; 04:4375 $cd $d4 $44
    ld   A, [wDF30]                                    ;; 04:4378 $fa $30 $df
    and  A, $01                                        ;; 04:437b $e6 $01
    jp   Z, .jp_04_441b                                ;; 04:437d $ca $1b $44
    ld   A, [wDF6F]                                    ;; 04:4380 $fa $6f $df
    and  A, A                                          ;; 04:4383 $a7
    jp   NZ, .jp_04_441b                               ;; 04:4384 $c2 $1b $44
    ld   HL, wDF30                                     ;; 04:4387 $21 $30 $df
    ld   DE, rNR33                                     ;; 04:438a $11 $1d $ff
    call call_04_45a7                                  ;; 04:438d $cd $a7 $45
    ld   HL, wDF3A                                     ;; 04:4390 $21 $3a $df
    ld   DE, wDF3B                                     ;; 04:4393 $11 $3b $df
    ld   A, [DE]                                       ;; 04:4396 $1a
    ld   C, A                                          ;; 04:4397 $4f
    inc  DE                                            ;; 04:4398 $13
    ld   A, [DE]                                       ;; 04:4399 $1a
    ld   B, A                                          ;; 04:439a $47
    ld   DE, rNR32                                     ;; 04:439b $11 $1c $ff
    call call_04_446c                                  ;; 04:439e $cd $6c $44
    ld   DE, wDF3B                                     ;; 04:43a1 $11 $3b $df
    ld   A, C                                          ;; 04:43a4 $79
    ld   [DE], A                                       ;; 04:43a5 $12
    ld   A, B                                          ;; 04:43a6 $78
    inc  DE                                            ;; 04:43a7 $13
    ld   [DE], A                                       ;; 04:43a8 $12
    ld   HL, wDF3D                                     ;; 04:43a9 $21 $3d $df
    ld   DE, wDF3E                                     ;; 04:43ac $11 $3e $df
    ld   A, [DE]                                       ;; 04:43af $1a
    ld   C, A                                          ;; 04:43b0 $4f
    inc  DE                                            ;; 04:43b1 $13
    ld   A, [DE]                                       ;; 04:43b2 $1a
    ld   B, A                                          ;; 04:43b3 $47
    ld   DE, wDF35                                     ;; 04:43b4 $11 $35 $df
    call call_04_4494                                  ;; 04:43b7 $cd $94 $44
    ld   DE, wDF3E                                     ;; 04:43ba $11 $3e $df
    ld   A, C                                          ;; 04:43bd $79
    ld   [DE], A                                       ;; 04:43be $12
    ld   A, B                                          ;; 04:43bf $78
    inc  DE                                            ;; 04:43c0 $13
    ld   [DE], A                                       ;; 04:43c1 $12
    ld   A, [wDF40]                                    ;; 04:43c2 $fa $40 $df
    and  A, A                                          ;; 04:43c5 $a7
    jr   Z, .jp_04_441b                                ;; 04:43c6 $28 $53
    dec  A                                             ;; 04:43c8 $3d
    ld   [wDF40], A                                    ;; 04:43c9 $ea $40 $df
    and  A, A                                          ;; 04:43cc $a7
    jr   NZ, .jp_04_441b                               ;; 04:43cd $20 $4c
    ld   A, [wDF41]                                    ;; 04:43cf $fa $41 $df
    ld   C, A                                          ;; 04:43d2 $4f
    ld   A, [wDF42]                                    ;; 04:43d3 $fa $42 $df
    ld   B, A                                          ;; 04:43d6 $47
    ld   A, [BC]                                       ;; 04:43d7 $0a
    cp   A, $ff                                        ;; 04:43d8 $fe $ff
    jr   Z, .jr_04_440c                                ;; 04:43da $28 $30
    ld   [wDF40], A                                    ;; 04:43dc $ea $40 $df
    inc  BC                                            ;; 04:43df $03
    ld   A, [BC]                                       ;; 04:43e0 $0a
    ld   E, A                                          ;; 04:43e1 $5f
    ld   A, [wDF7E]                                    ;; 04:43e2 $fa $7e $df
    add  A, E                                          ;; 04:43e5 $83
    push AF                                            ;; 04:43e6 $f5
    ld   DE, data_04_481b                              ;; 04:43e7 $11 $1b $48
    add  A, E                                          ;; 04:43ea $83
    ld   E, A                                          ;; 04:43eb $5f
    jr   NC, .jr_04_43ef                               ;; 04:43ec $30 $01
    inc  D                                             ;; 04:43ee $14
.jr_04_43ef:
    ld   A, [DE]                                       ;; 04:43ef $1a
    ld   [wDF34], A                                    ;; 04:43f0 $ea $34 $df
    pop  AF                                            ;; 04:43f3 $f1
    ld   DE, data_04_47bb                              ;; 04:43f4 $11 $bb $47
    add  A, E                                          ;; 04:43f7 $83
    ld   E, A                                          ;; 04:43f8 $5f
    jr   NC, .jr_04_43fc                               ;; 04:43f9 $30 $01
    inc  D                                             ;; 04:43fb $14
.jr_04_43fc:
    ld   A, [DE]                                       ;; 04:43fc $1a
    ld   [wDF35], A                                    ;; 04:43fd $ea $35 $df
    inc  BC                                            ;; 04:4400 $03
    ld   A, C                                          ;; 04:4401 $79
    ld   [wDF41], A                                    ;; 04:4402 $ea $41 $df
    ld   A, B                                          ;; 04:4405 $78
    ld   [wDF42], A                                    ;; 04:4406 $ea $42 $df
    jp   .jp_04_441b                                   ;; 04:4409 $c3 $1b $44
.jr_04_440c:
    ld   A, $01                                        ;; 04:440c $3e $01
    ld   [wDF40], A                                    ;; 04:440e $ea $40 $df
    inc  BC                                            ;; 04:4411 $03
    ld   A, [BC]                                       ;; 04:4412 $0a
    ld   [wDF41], A                                    ;; 04:4413 $ea $41 $df
    inc  BC                                            ;; 04:4416 $03
    ld   A, [BC]                                       ;; 04:4417 $0a
    ld   [wDF42], A                                    ;; 04:4418 $ea $42 $df
.jp_04_441b:
    ld   A, $03                                        ;; 04:441b $3e $03
    ld   [wDF7B], A                                    ;; 04:441d $ea $7b $df
    ld   HL, wDF62                                     ;; 04:4420 $21 $62 $df
    ld   DE, .jp_04_441b                               ;; 04:4423 $11 $1b $44
    ld   [HL], E                                       ;; 04:4426 $73
    inc  HL                                            ;; 04:4427 $23
    ld   [HL], D                                       ;; 04:4428 $72
    ld   A, [wDF5C]                                    ;; 04:4429 $fa $5c $df
    ld   [wDF65], A                                    ;; 04:442c $ea $65 $df
    ld   HL, wDF48                                     ;; 04:442f $21 $48 $df
    ld   DE, rNR41                                     ;; 04:4432 $11 $20 $ff
    call call_04_44d4                                  ;; 04:4435 $cd $d4 $44
    ld   A, [wDF48]                                    ;; 04:4438 $fa $48 $df
    and  A, $01                                        ;; 04:443b $e6 $01
    jr   Z, .jp_04_4462                                ;; 04:443d $28 $23
    ld   A, [wDF72]                                    ;; 04:443f $fa $72 $df
    and  A, A                                          ;; 04:4442 $a7
    jp   NZ, .jp_04_4462                               ;; 04:4443 $c2 $62 $44
    ld   HL, wDF52                                     ;; 04:4446 $21 $52 $df
    ld   DE, wDF53                                     ;; 04:4449 $11 $53 $df
    ld   A, [DE]                                       ;; 04:444c $1a
    ld   C, A                                          ;; 04:444d $4f
    inc  DE                                            ;; 04:444e $13
    ld   A, [DE]                                       ;; 04:444f $1a
    ld   B, A                                          ;; 04:4450 $47
    ld   DE, rNR42                                     ;; 04:4451 $11 $21 $ff
    call call_04_446c                                  ;; 04:4454 $cd $6c $44
    ld   DE, wDF53                                     ;; 04:4457 $11 $53 $df
    ld   A, C                                          ;; 04:445a $79
    ld   [DE], A                                       ;; 04:445b $12
    ld   A, B                                          ;; 04:445c $78
    inc  DE                                            ;; 04:445d $13
    ld   [DE], A                                       ;; 04:445e $12
    call call_04_45de                                  ;; 04:445f $cd $de $45
.jp_04_4462:
    ld   HL, wDF48                                     ;; 04:4462 $21 $48 $df
    ld   DE, rNR43                                     ;; 04:4465 $11 $22 $ff
    call call_04_45a7                                  ;; 04:4468 $cd $a7 $45
    ret                                                ;; 04:446b $c9

call_04_446c:
    ld   A, [HL]                                       ;; 04:446c $7e
    and  A, A                                          ;; 04:446d $a7
    ret  Z                                             ;; 04:446e $c8
    dec  [HL]                                          ;; 04:446f $35
    ret  NZ                                            ;; 04:4470 $c0
    ld   A, [BC]                                       ;; 04:4471 $0a
    cp   A, $ff                                        ;; 04:4472 $fe $ff
    jr   NZ, .jr_04_447a                               ;; 04:4474 $20 $04
    ld   A, $00                                        ;; 04:4476 $3e $00
    ld   [HL], A                                       ;; 04:4478 $77
    ret                                                ;; 04:4479 $c9
.jr_04_447a:
    ld   [DE], A                                       ;; 04:447a $12
    inc  BC                                            ;; 04:447b $03
    ld   A, [BC]                                       ;; 04:447c $0a
    ld   [HL], A                                       ;; 04:447d $77
    ld   A, L                                          ;; 04:447e $7d
    sub  A, $06                                        ;; 04:447f $d6 $06
    ld   L, A                                          ;; 04:4481 $6f
    jr   NC, .jr_04_4485                               ;; 04:4482 $30 $01
    dec  H                                             ;; 04:4484 $25
.jr_04_4485:
    ld   A, [HL]                                       ;; 04:4485 $7e
    or   A, $80                                        ;; 04:4486 $f6 $80
    ld   [HL], A                                       ;; 04:4488 $77
    ld   A, L                                          ;; 04:4489 $7d
    add  A, $04                                        ;; 04:448a $c6 $04
    ld   L, A                                          ;; 04:448c $6f
    jr   NC, .jr_04_4490                               ;; 04:448d $30 $01
    inc  H                                             ;; 04:448f $24
.jr_04_4490:
    ld   A, [DE]                                       ;; 04:4490 $1a
    ld   [HL], A                                       ;; 04:4491 $77
    inc  BC                                            ;; 04:4492 $03
    ret                                                ;; 04:4493 $c9

call_04_4494:
    ld   A, [HL]                                       ;; 04:4494 $7e
    and  A, A                                          ;; 04:4495 $a7
    ret  Z                                             ;; 04:4496 $c8
    dec  [HL]                                          ;; 04:4497 $35
    ret  NZ                                            ;; 04:4498 $c0
    inc  BC                                            ;; 04:4499 $03
    ld   A, [BC]                                       ;; 04:449a $0a
    push HL                                            ;; 04:449b $e5
    ld   [HL], A                                       ;; 04:449c $77
    dec  BC                                            ;; 04:449d $0b
    ld   A, [DE]                                       ;; 04:449e $1a
    ld   L, A                                          ;; 04:449f $6f
    dec  DE                                            ;; 04:44a0 $1b
    ld   A, [DE]                                       ;; 04:44a1 $1a
    ld   H, A                                          ;; 04:44a2 $67
    ld   A, [BC]                                       ;; 04:44a3 $0a
    cp   A, $7e                                        ;; 04:44a4 $fe $7e
    jr   NZ, .jr_04_44aa                               ;; 04:44a6 $20 $02
    pop  HL                                            ;; 04:44a8 $e1
    ret                                                ;; 04:44a9 $c9
.jr_04_44aa:
    cp   A, $7d                                        ;; 04:44aa $fe $7d
    jr   Z, .jr_04_44c7                                ;; 04:44ac $28 $19
    cp   A, $7f                                        ;; 04:44ae $fe $7f
    jr   NC, .jr_04_44b9                               ;; 04:44b0 $30 $07
    add  A, L                                          ;; 04:44b2 $85
    ld   L, A                                          ;; 04:44b3 $6f
    jr   NC, .jr_04_44b7                               ;; 04:44b4 $30 $01
    inc  H                                             ;; 04:44b6 $24
.jr_04_44b7:
    jr   .jr_04_44be                                   ;; 04:44b7 $18 $05
.jr_04_44b9:
    add  A, L                                          ;; 04:44b9 $85
    ld   L, A                                          ;; 04:44ba $6f
    jr   C, .jr_04_44be                                ;; 04:44bb $38 $01
    dec  H                                             ;; 04:44bd $25
.jr_04_44be:
    ld   A, H                                          ;; 04:44be $7c
    ld   [DE], A                                       ;; 04:44bf $12
    inc  DE                                            ;; 04:44c0 $13
    ld   A, L                                          ;; 04:44c1 $7d
    ld   [DE], A                                       ;; 04:44c2 $12
    inc  BC                                            ;; 04:44c3 $03
    inc  BC                                            ;; 04:44c4 $03
    pop  HL                                            ;; 04:44c5 $e1
    ret                                                ;; 04:44c6 $c9
.jr_04_44c7:
    inc  BC                                            ;; 04:44c7 $03
    ld   A, [BC]                                       ;; 04:44c8 $0a
    push AF                                            ;; 04:44c9 $f5
    inc  BC                                            ;; 04:44ca $03
    ld   A, [BC]                                       ;; 04:44cb $0a
    ld   B, A                                          ;; 04:44cc $47
    pop  AF                                            ;; 04:44cd $f1
    ld   C, A                                          ;; 04:44ce $4f
    pop  HL                                            ;; 04:44cf $e1
    ld   A, $01                                        ;; 04:44d0 $3e $01
    ld   [HL], A                                       ;; 04:44d2 $77
    ret                                                ;; 04:44d3 $c9

call_04_44d4:
    ld   A, [HL]                                       ;; 04:44d4 $7e
    and  A, $02                                        ;; 04:44d5 $e6 $02
    ret  Z                                             ;; 04:44d7 $c8
    inc  HL                                            ;; 04:44d8 $23
    dec  [HL]                                          ;; 04:44d9 $35
    ret  NZ                                            ;; 04:44da $c0
    inc  HL                                            ;; 04:44db $23
    ld   C, [HL]                                       ;; 04:44dc $4e
    inc  HL                                            ;; 04:44dd $23
    ld   B, [HL]                                       ;; 04:44de $46
    ld   A, [BC]                                       ;; 04:44df $0a
    ld   [wDF66], A                                    ;; 04:44e0 $ea $66 $df
    and  A, $7f                                        ;; 04:44e3 $e6 $7f
    cp   A, $5f                                        ;; 04:44e5 $fe $5f
    jp   NC, call_04_4637                                ;; 04:44e7 $d2 $37 $46
    push DE                                            ;; 04:44ea $d5
    ld   DE, wDF65                                     ;; 04:44eb $11 $65 $df
    ld   A, [DE]                                       ;; 04:44ee $1a
    ld   D, A                                          ;; 04:44ef $57
    ld   A, [BC]                                       ;; 04:44f0 $0a
    and  A, $7f                                        ;; 04:44f1 $e6 $7f
    add  A, D                                          ;; 04:44f3 $82
    ld   D, A                                          ;; 04:44f4 $57
    push AF                                            ;; 04:44f5 $f5
    ld   A, [wDF7B]                                    ;; 04:44f6 $fa $7b $df
    cp   A, $00                                        ;; 04:44f9 $fe $00
    jr   NZ, .jr_04_4501                               ;; 04:44fb $20 $04
    ld   A, D                                          ;; 04:44fd $7a
    ld   [wDF7C], A                                    ;; 04:44fe $ea $7c $df
.jr_04_4501:
    cp   A, $01                                        ;; 04:4501 $fe $01
    jr   NZ, .jr_04_4509                               ;; 04:4503 $20 $04
    ld   A, D                                          ;; 04:4505 $7a
    ld   [wDF7D], A                                    ;; 04:4506 $ea $7d $df
.jr_04_4509:
    cp   A, $02                                        ;; 04:4509 $fe $02
    jr   NZ, .jr_04_4511                               ;; 04:450b $20 $04
    ld   A, D                                          ;; 04:450d $7a
    ld   [wDF7E], A                                    ;; 04:450e $ea $7e $df
.jr_04_4511:
    pop  AF                                            ;; 04:4511 $f1
    ld   DE, data_04_481b                              ;; 04:4512 $11 $1b $48
    add  A, E                                          ;; 04:4515 $83
    ld   E, A                                          ;; 04:4516 $5f
    jp   NC, .jp_04_451b                               ;; 04:4517 $d2 $1b $45
    inc  D                                             ;; 04:451a $14
.jp_04_451b:
    ld   A, [DE]                                       ;; 04:451b $1a
    inc  HL                                            ;; 04:451c $23
    ld   [HL], A                                       ;; 04:451d $77
    ld   DE, wDF65                                     ;; 04:451e $11 $65 $df
    ld   A, [DE]                                       ;; 04:4521 $1a
    ld   D, A                                          ;; 04:4522 $57
    ld   A, [BC]                                       ;; 04:4523 $0a
    and  A, $7f                                        ;; 04:4524 $e6 $7f
    add  A, D                                          ;; 04:4526 $82
    ld   DE, data_04_47bb                              ;; 04:4527 $11 $bb $47
    add  A, E                                          ;; 04:452a $83
    ld   E, A                                          ;; 04:452b $5f
    jr   NC, .jr_04_452f                               ;; 04:452c $30 $01
    inc  D                                             ;; 04:452e $14
.jr_04_452f:
    ld   A, [DE]                                       ;; 04:452f $1a
    inc  HL                                            ;; 04:4530 $23
    ld   [HL], A                                       ;; 04:4531 $77
    inc  BC                                            ;; 04:4532 $03
    ld   A, [BC]                                       ;; 04:4533 $0a
    and  A, $0f                                        ;; 04:4534 $e6 $0f
    push HL                                            ;; 04:4536 $e5
    ld   HL, wDF61                                     ;; 04:4537 $21 $61 $df
    ld   D, [HL]                                       ;; 04:453a $56
    dec  HL                                            ;; 04:453b $2b
    ld   E, [HL]                                       ;; 04:453c $5e
    pop  HL                                            ;; 04:453d $e1
    add  A, E                                          ;; 04:453e $83
    ld   E, A                                          ;; 04:453f $5f
    jr   NC, .jr_04_4543                               ;; 04:4540 $30 $01
    inc  D                                             ;; 04:4542 $14
.jr_04_4543:
    ld   A, [DE]                                       ;; 04:4543 $1a
    ld   DE, hFFFC                                     ;; 04:4544 $11 $fc $ff
    add  HL, DE                                        ;; 04:4547 $19
    ld   [HL], A                                       ;; 04:4548 $77
    ld   A, [wDF66]                                    ;; 04:4549 $fa $66 $df
    and  A, $80                                        ;; 04:454c $e6 $80
    srl  A                                             ;; 04:454e $cb $3f
    srl  A                                             ;; 04:4550 $cb $3f
    ld   D, A                                          ;; 04:4552 $57
    ld   A, [BC]                                       ;; 04:4553 $0a
    and  A, $f0                                        ;; 04:4554 $e6 $f0
    srl  A                                             ;; 04:4556 $cb $3f
    srl  A                                             ;; 04:4558 $cb $3f
    srl  A                                             ;; 04:455a $cb $3f
    add  A, D                                          ;; 04:455c $82
    push HL                                            ;; 04:455d $e5
    ld   HL, data_04_70d1                              ;; 04:455e $21 $d1 $70
    add  A, L                                          ;; 04:4561 $85
    ld   L, A                                          ;; 04:4562 $6f
    jr   NC, .jr_04_4566                               ;; 04:4563 $30 $01
    inc  H                                             ;; 04:4565 $24
.jr_04_4566:
    ld   E, [HL]                                       ;; 04:4566 $5e
    inc  HL                                            ;; 04:4567 $23
    ld   D, [HL]                                       ;; 04:4568 $56
    pop  HL                                            ;; 04:4569 $e1
    inc  BC                                            ;; 04:456a $03
    inc  HL                                            ;; 04:456b $23
    ld   [HL], C                                       ;; 04:456c $71
    inc  HL                                            ;; 04:456d $23
    ld   [HL], B                                       ;; 04:456e $70
    ld   B, D                                          ;; 04:456f $42
    ld   C, E                                          ;; 04:4570 $4b
    pop  DE                                            ;; 04:4571 $d1
    inc  HL                                            ;; 04:4572 $23
    ld   A, [BC]                                       ;; 04:4573 $0a
    or   A, [HL]                                       ;; 04:4574 $b6
    ld   [HL], A                                       ;; 04:4575 $77
    inc  HL                                            ;; 04:4576 $23
    inc  HL                                            ;; 04:4577 $23
    inc  HL                                            ;; 04:4578 $23
    inc  BC                                            ;; 04:4579 $03
    ld   A, [BC]                                       ;; 04:457a $0a
    ld   [HL], A                                       ;; 04:457b $77
    inc  BC                                            ;; 04:457c $03
    inc  DE                                            ;; 04:457d $13
    inc  HL                                            ;; 04:457e $23
    ld   A, [BC]                                       ;; 04:457f $0a
    ld   [HL], A                                       ;; 04:4580 $77
    inc  HL                                            ;; 04:4581 $23
    inc  HL                                            ;; 04:4582 $23
    inc  BC                                            ;; 04:4583 $03
    ld   A, [BC]                                       ;; 04:4584 $0a
    ld   [HL], A                                       ;; 04:4585 $77
    inc  HL                                            ;; 04:4586 $23
    inc  BC                                            ;; 04:4587 $03
    ld   A, [BC]                                       ;; 04:4588 $0a
    ld   [HL], A                                       ;; 04:4589 $77
    inc  HL                                            ;; 04:458a $23
    inc  BC                                            ;; 04:458b $03
    ld   A, [BC]                                       ;; 04:458c $0a
    ld   [HL], A                                       ;; 04:458d $77
    inc  HL                                            ;; 04:458e $23
    inc  BC                                            ;; 04:458f $03
    ld   A, [BC]                                       ;; 04:4590 $0a
    ld   [HL], A                                       ;; 04:4591 $77
    inc  HL                                            ;; 04:4592 $23
    inc  BC                                            ;; 04:4593 $03
    ld   A, [BC]                                       ;; 04:4594 $0a
    ld   [HL], A                                       ;; 04:4595 $77
    inc  HL                                            ;; 04:4596 $23
    inc  BC                                            ;; 04:4597 $03
    ld   A, [BC]                                       ;; 04:4598 $0a
    ld   [HL], A                                       ;; 04:4599 $77
    inc  BC                                            ;; 04:459a $03
    inc  HL                                            ;; 04:459b $23
    ld   A, [BC]                                       ;; 04:459c $0a
    ld   [HL], A                                       ;; 04:459d $77
    inc  BC                                            ;; 04:459e $03
    inc  HL                                            ;; 04:459f $23
    ld   A, [BC]                                       ;; 04:45a0 $0a
    ld   [HL], A                                       ;; 04:45a1 $77
    inc  BC                                            ;; 04:45a2 $03
    inc  HL                                            ;; 04:45a3 $23
    ld   A, [BC]                                       ;; 04:45a4 $0a
    ld   [HL], A                                       ;; 04:45a5 $77
    ret                                                ;; 04:45a6 $c9

call_04_45a7:
    ld   A, [HL]                                       ;; 04:45a7 $7e
    and  A, $01                                        ;; 04:45a8 $e6 $01
    ret  Z                                             ;; 04:45aa $c8
    ld   BC, $05                                       ;; 04:45ab $01 $05 $00
    add  HL, BC                                        ;; 04:45ae $09
    ld   A, E                                          ;; 04:45af $7b
    cp   A, $22                                        ;; 04:45b0 $fe $22
    jp   Z, .jp_04_45d5                                ;; 04:45b2 $ca $d5 $45
    ld   A, [HL]                                       ;; 04:45b5 $7e
    ld   [DE], A                                       ;; 04:45b6 $12
.jr_04_45b7:
    dec  HL                                            ;; 04:45b7 $2b
    inc  DE                                            ;; 04:45b8 $13
    push DE                                            ;; 04:45b9 $d5
    push HL                                            ;; 04:45ba $e5
    ld   A, [HL]                                       ;; 04:45bb $7e
    and  A, $80                                        ;; 04:45bc $e6 $80
    jr   Z, .jr_04_45cd                                ;; 04:45be $28 $0d
    ld   BC, $03                                       ;; 04:45c0 $01 $03 $00
    add  HL, BC                                        ;; 04:45c3 $09
    dec  DE                                            ;; 04:45c4 $1b
    dec  DE                                            ;; 04:45c5 $1b
    dec  DE                                            ;; 04:45c6 $1b
    ld   A, [HL]                                       ;; 04:45c7 $7e
    ld   [DE], A                                       ;; 04:45c8 $12
    inc  HL                                            ;; 04:45c9 $23
    inc  DE                                            ;; 04:45ca $13
    ld   A, [HL]                                       ;; 04:45cb $7e
    ld   [DE], A                                       ;; 04:45cc $12
.jr_04_45cd:
    pop  HL                                            ;; 04:45cd $e1
    pop  DE                                            ;; 04:45ce $d1
    ld   A, [HL]                                       ;; 04:45cf $7e
    ld   [DE], A                                       ;; 04:45d0 $12
    and  A, $7f                                        ;; 04:45d1 $e6 $7f
    ld   [HL], A                                       ;; 04:45d3 $77
    ret                                                ;; 04:45d4 $c9
.jp_04_45d5:
    ld   A, [wDF64]                                    ;; 04:45d5 $fa $64 $df
    ld   [wDF4D], A                                    ;; 04:45d8 $ea $4d $df
    ld   [DE], A                                       ;; 04:45db $12
    jr   .jr_04_45b7                                   ;; 04:45dc $18 $d9

call_04_45de:
    ld   A, [wDF55]                                    ;; 04:45de $fa $55 $df
    and  A, A                                          ;; 04:45e1 $a7
    ret  Z                                             ;; 04:45e2 $c8
    dec  A                                             ;; 04:45e3 $3d
    ld   [wDF55], A                                    ;; 04:45e4 $ea $55 $df
    and  A, A                                          ;; 04:45e7 $a7
    ret  NZ                                            ;; 04:45e8 $c0
    ld   A, [wDF56]                                    ;; 04:45e9 $fa $56 $df
    ld   L, A                                          ;; 04:45ec $6f
    ld   A, [wDF57]                                    ;; 04:45ed $fa $57 $df
    ld   H, A                                          ;; 04:45f0 $67
    ld   A, [HL]                                       ;; 04:45f1 $7e
    cp   A, $7e                                        ;; 04:45f2 $fe $7e
    ret  Z                                             ;; 04:45f4 $c8
    cp   A, $7d                                        ;; 04:45f5 $fe $7d
    jr   Z, .jr_04_460b                                ;; 04:45f7 $28 $12
    ld   [wDF64], A                                    ;; 04:45f9 $ea $64 $df
    inc  HL                                            ;; 04:45fc $23
    ld   A, [HL]                                       ;; 04:45fd $7e
    ld   [wDF55], A                                    ;; 04:45fe $ea $55 $df
    inc  HL                                            ;; 04:4601 $23
    ld   A, L                                          ;; 04:4602 $7d
    ld   [wDF56], A                                    ;; 04:4603 $ea $56 $df
    ld   A, H                                          ;; 04:4606 $7c
    ld   [wDF57], A                                    ;; 04:4607 $ea $57 $df
    ret                                                ;; 04:460a $c9
.jr_04_460b:
    ld   A, $01                                        ;; 04:460b $3e $01
    ld   [wDF55], A                                    ;; 04:460d $ea $55 $df
    inc  HL                                            ;; 04:4610 $23
    ld   A, [HL]                                       ;; 04:4611 $7e
    ld   [wDF56], A                                    ;; 04:4612 $ea $56 $df
    inc  HL                                            ;; 04:4615 $23
    ld   A, [HL]                                       ;; 04:4616 $7e
    ld   [wDF57], A                                    ;; 04:4617 $ea $57 $df
    ret                                                ;; 04:461a $c9
    db   $4b                                           ;; 04:461b ?

data_04_461c:
    db   $46                                           ;; 04:461c ?
    dw   call_04_4667                                  ;; 04:461d pP
    dw   call_04_4670                                  ;; 04:461f pP
    db   $81, $46                                      ;; 04:4621 ??
    dw   call_04_4695                                  ;; 04:4623 pP
    dw   call_04_46e0                                  ;; 04:4625 pP
    dw   call_04_4719                                  ;; 04:4627 pP
    dw   call_04_472d                                  ;; 04:4629 pP
    db   $82, $47                                      ;; 04:462b ??
    dw   call_04_479a                                  ;; 04:462d pP
    db   $42, $47, $52, $47, $62, $47, $72, $47        ;; 04:462f ????????

call_04_4637:
    sub  A, $60                                        ;; 04:4637 $d6 $60
    add  A, A                                          ;; 04:4639 $87
    push HL                                            ;; 04:463a $e5
    dec  HL                                            ;; 04:463b $2b
    dec  HL                                            ;; 04:463c $2b
    inc  [HL]                                          ;; 04:463d $34
    ld   HL, data_04_461c                              ;; 04:463e $21 $1c $46
    add  A, L                                          ;; 04:4641 $85
    ld   L, A                                          ;; 04:4642 $6f
    jr   NC, .jr_04_4646                               ;; 04:4643 $30 $01
    inc  H                                             ;; 04:4645 $24
.jr_04_4646:
    ld   A, [HL]                                       ;; 04:4646 $7e
    dec  HL                                            ;; 04:4647 $2b
    ld   L, [HL]                                       ;; 04:4648 $6e
    ld   H, A                                          ;; 04:4649 $67
    jp   HL                                            ;; 04:464a $e9
    db   $21, $61, $df, $7e, $2b, $6e, $67, $03        ;; 04:464b ????????
    db   $0a, $e6, $0f, $85, $6f, $18, $01, $24        ;; 04:4653 ????????
    db   $7e, $e1, $11, $fe, $ff, $19, $77, $03        ;; 04:465b ????????
    db   $23, $c3, $ad, $47                            ;; 04:4663 ????

call_04_4667:
    pop  HL                                            ;; 04:4667 $e1
    ld   BC, hFFFD                                     ;; 04:4668 $01 $fd $ff
    add  HL, BC                                        ;; 04:466b $09
    ld   A, $00                                        ;; 04:466c $3e $00
    ld   [HL], A                                       ;; 04:466e $77
    ret                                                ;; 04:466f $c9

call_04_4670:
    pop  HL                                            ;; 04:4670 $e1
    ld   DE, hFFFE                                     ;; 04:4671 $11 $fe $ff
    add  HL, DE                                        ;; 04:4674 $19
    ld   A, $01                                        ;; 04:4675 $3e $01
    ld   [HL+], A                                      ;; 04:4677 $22
    inc  BC                                            ;; 04:4678 $03
    ld   A, [BC]                                       ;; 04:4679 $0a
    ld   [HL+], A                                      ;; 04:467a $22
    inc  BC                                            ;; 04:467b $03
    ld   A, [BC]                                       ;; 04:467c $0a
    ld   [HL], A                                       ;; 04:467d $77
    jp   call_04_47b1                                    ;; 04:467e $c3 $b1 $47
    db   $e1, $03, $0a, $ea, $64, $df, $11, $fe        ;; 04:4681 ????????
    db   $ff, $19, $3e, $01, $22, $03, $cd, $ad        ;; 04:4689 ????????
    db   $47, $c3, $b1, $47                            ;; 04:4691 ????

call_04_4695:
    pop  HL                                            ;; 04:4695 $e1
    ld   DE, hFFFE                                     ;; 04:4696 $11 $fe $ff
    add  HL, DE                                        ;; 04:4699 $19
    ld   A, $01                                        ;; 04:469a $3e $01
    ld   [HL+], A                                      ;; 04:469c $22
    inc  BC                                            ;; 04:469d $03
    ld   A, [BC]                                       ;; 04:469e $0a
    sla  A                                             ;; 04:469f $cb $27
    jr   NC, .jr_04_46a9                               ;; 04:46a1 $30 $06
    ld   DE, data_04_766f                              ;; 04:46a3 $11 $6f $76
    inc  D                                             ;; 04:46a6 $14
    jr   .jr_04_46ac                                   ;; 04:46a7 $18 $03
.jr_04_46a9:
    ld   DE, data_04_766f                              ;; 04:46a9 $11 $6f $76
.jr_04_46ac:
    add  A, E                                          ;; 04:46ac $83
    ld   E, A                                          ;; 04:46ad $5f
    jr   NC, .jr_04_46b1                               ;; 04:46ae $30 $01
    inc  D                                             ;; 04:46b0 $14
.jr_04_46b1:
    ld   A, [DE]                                       ;; 04:46b1 $1a
    ld   [HL+], A                                      ;; 04:46b2 $22
    inc  DE                                            ;; 04:46b3 $13
    ld   A, [DE]                                       ;; 04:46b4 $1a
    ld   [HL+], A                                      ;; 04:46b5 $22
    ld   D, H                                          ;; 04:46b6 $54
    ld   E, L                                          ;; 04:46b7 $5d
    ld   A, $10                                        ;; 04:46b8 $3e $10
    add  A, E                                          ;; 04:46ba $83
    ld   E, A                                          ;; 04:46bb $5f
    jr   NC, .jr_04_46bf                               ;; 04:46bc $30 $01
    inc  D                                             ;; 04:46be $14
.jr_04_46bf:
    inc  BC                                            ;; 04:46bf $03
    ld   A, [BC]                                       ;; 04:46c0 $0a
    ld   [DE], A                                       ;; 04:46c1 $12
    inc  DE                                            ;; 04:46c2 $13
    ld   A, [DE]                                       ;; 04:46c3 $1a
    and  A, A                                          ;; 04:46c4 $a7
    jr   Z, .jr_04_46ca                                ;; 04:46c5 $28 $03
    inc  BC                                            ;; 04:46c7 $03
    jr   .jr_04_46d6                                   ;; 04:46c8 $18 $0c
.jr_04_46ca:
    ld   A, $01                                        ;; 04:46ca $3e $01
    ld   [DE], A                                       ;; 04:46cc $12
    dec  DE                                            ;; 04:46cd $1b
    dec  DE                                            ;; 04:46ce $1b
    inc  BC                                            ;; 04:46cf $03
    ld   A, [BC]                                       ;; 04:46d0 $0a
    sub  A, $01                                        ;; 04:46d1 $d6 $01
    ld   [DE], A                                       ;; 04:46d3 $12
    inc  DE                                            ;; 04:46d4 $13
    inc  DE                                            ;; 04:46d5 $13
.jr_04_46d6:
    inc  BC                                            ;; 04:46d6 $03
    inc  DE                                            ;; 04:46d7 $13
    ld   A, C                                          ;; 04:46d8 $79
    ld   [DE], A                                       ;; 04:46d9 $12
    inc  DE                                            ;; 04:46da $13
    ld   A, B                                          ;; 04:46db $78
    ld   [DE], A                                       ;; 04:46dc $12
    jp   call_04_47b1                                    ;; 04:46dd $c3 $b1 $47

call_04_46e0:
    inc  BC                                            ;; 04:46e0 $03
    pop  HL                                            ;; 04:46e1 $e1
    ld   DE, hFFFE                                     ;; 04:46e2 $11 $fe $ff
    add  HL, DE                                        ;; 04:46e5 $19
    ld   A, $01                                        ;; 04:46e6 $3e $01
    ld   [HL+], A                                      ;; 04:46e8 $22
    ld   D, H                                          ;; 04:46e9 $54
    ld   E, L                                          ;; 04:46ea $5d
    ld   A, $11                                        ;; 04:46eb $3e $11
    add  A, E                                          ;; 04:46ed $83
    ld   E, A                                          ;; 04:46ee $5f
    jr   NC, .jr_04_46f2                               ;; 04:46ef $30 $01
    inc  D                                             ;; 04:46f1 $14
.jr_04_46f2:
    ld   A, [DE]                                       ;; 04:46f2 $1a
    and  A, A                                          ;; 04:46f3 $a7
    jr   Z, .jr_04_470a                                ;; 04:46f4 $28 $14
    sub  A, $01                                        ;; 04:46f6 $d6 $01
    ld   [DE], A                                       ;; 04:46f8 $12
    inc  DE                                            ;; 04:46f9 $13
    inc  DE                                            ;; 04:46fa $13
    inc  DE                                            ;; 04:46fb $13
    ld   A, [DE]                                       ;; 04:46fc $1a
    sub  A, $04                                        ;; 04:46fd $d6 $04
    ld   [HL+], A                                      ;; 04:46ff $22
    inc  DE                                            ;; 04:4700 $13
    ld   A, [DE]                                       ;; 04:4701 $1a
    jr   NC, .jr_04_4706                               ;; 04:4702 $30 $02
    sub  A, $01                                        ;; 04:4704 $d6 $01
.jr_04_4706:
    ld   [HL], A                                       ;; 04:4706 $77
    jp   call_04_47b1                                    ;; 04:4707 $c3 $b1 $47
.jr_04_470a:
    inc  DE                                            ;; 04:470a $13
    ld   A, $00                                        ;; 04:470b $3e $00
    ld   [DE], A                                       ;; 04:470d $12
    inc  DE                                            ;; 04:470e $13
    ld   [DE], A                                       ;; 04:470f $12
    inc  DE                                            ;; 04:4710 $13
    ld   A, [DE]                                       ;; 04:4711 $1a
    ld   [HL+], A                                      ;; 04:4712 $22
    inc  DE                                            ;; 04:4713 $13
    ld   A, [DE]                                       ;; 04:4714 $1a
    ld   [HL], A                                       ;; 04:4715 $77
    jp   call_04_47b1                                    ;; 04:4716 $c3 $b1 $47

call_04_4719:
    inc  BC                                            ;; 04:4719 $03
    ld   A, [BC]                                       ;; 04:471a $0a
    ld   [wDF67], A                                    ;; 04:471b $ea $67 $df
    pop  HL                                            ;; 04:471e $e1
    ld   DE, hFFFE                                     ;; 04:471f $11 $fe $ff
    add  HL, DE                                        ;; 04:4722 $19
    ld   A, $01                                        ;; 04:4723 $3e $01
    ld   [HL+], A                                      ;; 04:4725 $22
    inc  BC                                            ;; 04:4726 $03
    call call_04_47ad                                  ;; 04:4727 $cd $ad $47
    jp   call_04_47b1                                    ;; 04:472a $c3 $b1 $47

call_04_472d:
    inc  BC                                            ;; 04:472d $03
    ld   A, [BC]                                       ;; 04:472e $0a
    ldh  [rNR51], A                                    ;; 04:472f $e0 $25
    ld   [wDF79], A                                    ;; 04:4731 $ea $79 $df
    inc  BC                                            ;; 04:4734 $03
    pop  HL                                            ;; 04:4735 $e1
    ld   DE, hFFFE                                     ;; 04:4736 $11 $fe $ff
    add  HL, DE                                        ;; 04:4739 $19
    ld   A, $01                                        ;; 04:473a $3e $01
    ld   [HL+], A                                      ;; 04:473c $22
    call call_04_47ad                                  ;; 04:473d $cd $ad $47
    jr   call_04_47b1                                    ;; 04:4740 $18 $6f
    db   $03, $fa, $79, $df, $e6, $ee, $67, $0a        ;; 04:4742 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $e2        ;; 04:474a ????????
    db   $03, $fa, $79, $df, $e6, $dd, $67, $0a        ;; 04:4752 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $d2        ;; 04:475a ????????
    db   $03, $fa, $79, $df, $e6, $bb, $67, $0a        ;; 04:4762 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $c2        ;; 04:476a ????????
    db   $03, $fa, $79, $df, $e6, $77, $67, $0a        ;; 04:4772 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $b2        ;; 04:477a ????????
    db   $03, $0a, $ea, $60, $df, $03, $0a, $ea        ;; 04:4782 ????????
    db   $61, $df, $e1, $11, $fe, $ff, $19, $3e        ;; 04:478a ????????
    db   $01, $22, $03, $cd, $ad, $47, $18, $17        ;; 04:4792 ????????

call_04_479a:
    inc  BC                                            ;; 04:479a $03
    ld   A, [BC]                                       ;; 04:479b $0a
    ld   [wDF78], A                                    ;; 04:479c $ea $78 $df
    pop  HL                                            ;; 04:479f $e1
    ld   DE, hFFFE                                     ;; 04:47a0 $11 $fe $ff
    add  HL, DE                                        ;; 04:47a3 $19
    ld   A, $01                                        ;; 04:47a4 $3e $01
    ld   [HL+], A                                      ;; 04:47a6 $22
    inc  BC                                            ;; 04:47a7 $03
    call call_04_47ad                                  ;; 04:47a8 $cd $ad $47
    jr   call_04_47b1                                    ;; 04:47ab $18 $04

call_04_47ad:
    ld   [HL], C                                       ;; 04:47ad $71
    inc  HL                                            ;; 04:47ae $23
    ld   [HL], B                                       ;; 04:47af $70
    ret                                                ;; 04:47b0 $c9

call_04_47b1:
    pop  HL                                            ;; 04:47b1 $e1
    ld   DE, wDF62                                     ;; 04:47b2 $11 $62 $df
    ld   A, [DE]                                       ;; 04:47b5 $1a
    ld   L, A                                          ;; 04:47b6 $6f
    inc  DE                                            ;; 04:47b7 $13
    ld   A, [DE]                                       ;; 04:47b8 $1a
    ld   H, A                                          ;; 04:47b9 $67
    jp   HL                                            ;; 04:47ba $e9

data_04_47bb:
    db   $9d, $07, $6b, $ca, $23, $78, $c7, $12        ;; 04:47bb ????????
    db   $59, $9c, $db, $17, $4f, $84, $b6, $e5        ;; 04:47c3 ?.......
    db   $12, $3c, $64, $89, $ad, $ce, $ee, $0c        ;; 04:47cb ........
    db   $28, $42, $5b, $73, $89, $9e, $b2, $c5        ;; 04:47d3 ........
    db   $d7, $e7, $f7, $06, $14, $21, $2e, $3a        ;; 04:47db ........
    db   $45, $4f, $59, $63, $6c, $74, $7c, $83        ;; 04:47e3 ........
    db   $8a, $91, $97, $9d, $a3, $a8, $ad, $b1        ;; 04:47eb ...?....
    db   $b6, $ba, $be, $c2, $c5, $c9, $cc, $cf        ;; 04:47f3 .....?.?
    db   $d2, $d4, $d7, $d9, $db, $dd, $df, $e1        ;; 04:47fb ..??????
    db   $e3, $e5, $e6, $e8, $e9, $ea, $ec, $ed        ;; 04:4803 ????????
    db   $ee, $ef, $f0, $f1, $f2, $f3, $f3, $f4        ;; 04:480b ????????
    db   $f5, $f5, $f7, $f7, $f8, $f8, $fa, $fa        ;; 04:4813 ????????

data_04_481b:
    db   $00, $01, $01, $01, $02, $02, $02, $03        ;; 04:481b ????????
    db   $03, $03, $03, $04, $04, $04, $04, $04        ;; 04:4823 ?.......
    db   $05, $05, $05, $05, $05, $05, $05, $06        ;; 04:482b ........
    db   $06, $06, $06, $06, $06, $06, $06, $06        ;; 04:4833 ........
    db   $06, $06, $06, $07, $07, $07, $07, $07        ;; 04:483b ........
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:4843 ........
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:484b ...?....
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:4853 .....?.?
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:485b ..??????
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:4863 ????????
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:486b ????????
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:4873 ????????

call_04_487b:
    ld   HL, data_04_49ed                              ;; 04:487b $21 $ed $49
    sla  A                                             ;; 04:487e $cb $27
    add  A, L                                          ;; 04:4880 $85
    ld   L, A                                          ;; 04:4881 $6f
    jr   NC, .jr_04_4885                               ;; 04:4882 $30 $01
    inc  H                                             ;; 04:4884 $24
.jr_04_4885:
    ld   A, [HL]                                       ;; 04:4885 $7e
    ld   C, A                                          ;; 04:4886 $4f
    inc  HL                                            ;; 04:4887 $23
    ld   A, [HL]                                       ;; 04:4888 $7e
    ld   B, A                                          ;; 04:4889 $47
    ld   A, $8f                                        ;; 04:488a $3e $8f
    ldh  [rNR52], A                                    ;; 04:488c $e0 $26
    ld   A, [BC]                                       ;; 04:488e $0a
    inc  BC                                            ;; 04:488f $03
    cp   A, $01                                        ;; 04:4890 $fe $01
    jr   Z, .jr_04_48bd                                ;; 04:4892 $28 $29
    cp   A, $02                                        ;; 04:4894 $fe $02
    jr   Z, .jr_04_48de                                ;; 04:4896 $28 $46
    cp   A, $03                                        ;; 04:4898 $fe $03
    jr   Z, .jr_04_48ff                                ;; 04:489a $28 $63
    ld   A, [wDF79]                                    ;; 04:489c $fa $79 $df
    ld   D, A                                          ;; 04:489f $57
    ld   A, $11                                        ;; 04:48a0 $3e $11
    or   A, D                                          ;; 04:48a2 $b2
    ld   [wDF7A], A                                    ;; 04:48a3 $ea $7a $df
    ld   A, [wDF00]                                    ;; 04:48a6 $fa $00 $df
    and  A, $fe                                        ;; 04:48a9 $e6 $fe
    ld   [wDF00], A                                    ;; 04:48ab $ea $00 $df
    ld   A, C                                          ;; 04:48ae $79
    ld   [wDF68], A                                    ;; 04:48af $ea $68 $df
    ld   A, B                                          ;; 04:48b2 $78
    ld   [wDF69], A                                    ;; 04:48b3 $ea $69 $df
    ld   A, $02                                        ;; 04:48b6 $3e $02
    ld   [wDF6A], A                                    ;; 04:48b8 $ea $6a $df
    jr   call_04_491e                                  ;; 04:48bb $18 $61
.jr_04_48bd:
    ld   A, [wDF79]                                    ;; 04:48bd $fa $79 $df
    ld   D, A                                          ;; 04:48c0 $57
    ld   A, $22                                        ;; 04:48c1 $3e $22
    or   A, D                                          ;; 04:48c3 $b2
    ld   [wDF7A], A                                    ;; 04:48c4 $ea $7a $df
    ld   A, [wDF18]                                    ;; 04:48c7 $fa $18 $df
    and  A, $fe                                        ;; 04:48ca $e6 $fe
    ld   [wDF18], A                                    ;; 04:48cc $ea $18 $df
    ld   A, C                                          ;; 04:48cf $79
    ld   [wDF6B], A                                    ;; 04:48d0 $ea $6b $df
    ld   A, B                                          ;; 04:48d3 $78
    ld   [wDF6C], A                                    ;; 04:48d4 $ea $6c $df
    ld   A, $02                                        ;; 04:48d7 $3e $02
    ld   [wDF6D], A                                    ;; 04:48d9 $ea $6d $df
    jr   call_04_491e                                  ;; 04:48dc $18 $40
.jr_04_48de:
    ld   A, [wDF79]                                    ;; 04:48de $fa $79 $df
    ld   D, A                                          ;; 04:48e1 $57
    ld   A, $44                                        ;; 04:48e2 $3e $44
    or   A, D                                          ;; 04:48e4 $b2
    ld   [wDF7A], A                                    ;; 04:48e5 $ea $7a $df
    ld   A, [wDF30]                                    ;; 04:48e8 $fa $30 $df
    and  A, $fe                                        ;; 04:48eb $e6 $fe
    ld   [wDF30], A                                    ;; 04:48ed $ea $30 $df
    ld   A, C                                          ;; 04:48f0 $79
    ld   [wDF6E], A                                    ;; 04:48f1 $ea $6e $df
    ld   A, B                                          ;; 04:48f4 $78
    ld   [wDF6F], A                                    ;; 04:48f5 $ea $6f $df
    ld   A, $02                                        ;; 04:48f8 $3e $02
    ld   [wDF70], A                                    ;; 04:48fa $ea $70 $df
    jr   call_04_491e                                  ;; 04:48fd $18 $1f
.jr_04_48ff:
    ld   A, [wDF79]                                    ;; 04:48ff $fa $79 $df
    ld   D, A                                          ;; 04:4902 $57
    ld   A, $88                                        ;; 04:4903 $3e $88
    or   A, D                                          ;; 04:4905 $b2
    ld   [wDF7A], A                                    ;; 04:4906 $ea $7a $df
    ld   A, [wDF48]                                    ;; 04:4909 $fa $48 $df
    and  A, $fe                                        ;; 04:490c $e6 $fe
    ld   [wDF48], A                                    ;; 04:490e $ea $48 $df
    ld   A, C                                          ;; 04:4911 $79
    ld   [wDF71], A                                    ;; 04:4912 $ea $71 $df
    ld   A, B                                          ;; 04:4915 $78
    ld   [wDF72], A                                    ;; 04:4916 $ea $72 $df
    ld   A, $02                                        ;; 04:4919 $3e $02
    ld   [wDF73], A                                    ;; 04:491b $ea $73 $df

call_04_491e:
    ld   HL, wDF00                                     ;; 04:491e $21 $00 $df
    ld   A, L                                          ;; 04:4921 $7d
    ld   [wDF74], A                                    ;; 04:4922 $ea $74 $df
    ld   A, H                                          ;; 04:4925 $7c
    ld   [wDF75], A                                    ;; 04:4926 $ea $75 $df
    ld   HL, wDF68                                     ;; 04:4929 $21 $68 $df
    ld   C, [HL]                                       ;; 04:492c $4e
    inc  HL                                            ;; 04:492d $23
    ld   B, [HL]                                       ;; 04:492e $46
    ld   A, B                                          ;; 04:492f $78
    or   A, C                                          ;; 04:4930 $b1
    jr   Z, .jr_04_4939                                ;; 04:4931 $28 $06
    ld   DE, rNR11                                     ;; 04:4933 $11 $11 $ff
    call call_04_498b                                  ;; 04:4936 $cd $8b $49
.jr_04_4939:
    ld   HL, wDF18                                     ;; 04:4939 $21 $18 $df
    ld   A, L                                          ;; 04:493c $7d
    ld   [wDF74], A                                    ;; 04:493d $ea $74 $df
    ld   A, H                                          ;; 04:4940 $7c
    ld   [wDF75], A                                    ;; 04:4941 $ea $75 $df
    ld   HL, wDF6B                                     ;; 04:4944 $21 $6b $df
    ld   C, [HL]                                       ;; 04:4947 $4e
    inc  HL                                            ;; 04:4948 $23
    ld   B, [HL]                                       ;; 04:4949 $46
    ld   A, B                                          ;; 04:494a $78
    or   A, C                                          ;; 04:494b $b1
    jr   Z, .jr_04_4954                                ;; 04:494c $28 $06
    ld   DE, rNR21                                     ;; 04:494e $11 $16 $ff
    call call_04_498b                                  ;; 04:4951 $cd $8b $49
.jr_04_4954:
    ld   HL, wDF30                                     ;; 04:4954 $21 $30 $df
    ld   A, L                                          ;; 04:4957 $7d
    ld   [wDF74], A                                    ;; 04:4958 $ea $74 $df
    ld   A, H                                          ;; 04:495b $7c
    ld   [wDF75], A                                    ;; 04:495c $ea $75 $df
    ld   HL, wDF6E                                     ;; 04:495f $21 $6e $df
    ld   C, [HL]                                       ;; 04:4962 $4e
    inc  HL                                            ;; 04:4963 $23
    ld   B, [HL]                                       ;; 04:4964 $46
    ld   A, B                                          ;; 04:4965 $78
    or   A, C                                          ;; 04:4966 $b1
    jr   Z, .jr_04_496f                                ;; 04:4967 $28 $06
    ld   DE, rNR31                                     ;; 04:4969 $11 $1b $ff
    call call_04_498b                                  ;; 04:496c $cd $8b $49
.jr_04_496f:
    ld   HL, wDF48                                     ;; 04:496f $21 $48 $df
    ld   A, L                                          ;; 04:4972 $7d
    ld   [wDF74], A                                    ;; 04:4973 $ea $74 $df
    ld   A, H                                          ;; 04:4976 $7c
    ld   [wDF75], A                                    ;; 04:4977 $ea $75 $df
    ld   HL, wDF71                                     ;; 04:497a $21 $71 $df
    ld   C, [HL]                                       ;; 04:497d $4e
    inc  HL                                            ;; 04:497e $23
    ld   B, [HL]                                       ;; 04:497f $46
    ld   A, B                                          ;; 04:4980 $78
    or   A, C                                          ;; 04:4981 $b1
    jr   Z, .jr_04_498a                                ;; 04:4982 $28 $06
    ld   DE, rNR41                                     ;; 04:4984 $11 $20 $ff
    call call_04_498b                                  ;; 04:4987 $cd $8b $49
.jr_04_498a:
    ret                                                ;; 04:498a $c9

call_04_498b:
    ld   A, [wDF7A]                                    ;; 04:498b $fa $7a $df
    ldh  [rNR51], A                                    ;; 04:498e $e0 $25
    inc  HL                                            ;; 04:4990 $23
    dec  [HL]                                          ;; 04:4991 $35
    jr   Z, .jr_04_4995                                ;; 04:4992 $28 $01
    ret                                                ;; 04:4994 $c9
.jr_04_4995:
    ld   A, [BC]                                       ;; 04:4995 $0a
    cp   A, $ff                                        ;; 04:4996 $fe $ff
    jr   Z, .jr_04_49b5                                ;; 04:4998 $28 $1b
    cp   A, $fe                                        ;; 04:499a $fe $fe
    jr   Z, .jr_04_49d1                                ;; 04:499c $28 $33
    ld   [HL], A                                       ;; 04:499e $77
    inc  BC                                            ;; 04:499f $03
    ld   A, [BC]                                       ;; 04:49a0 $0a
    ld   [DE], A                                       ;; 04:49a1 $12
    inc  BC                                            ;; 04:49a2 $03
    inc  DE                                            ;; 04:49a3 $13
    ld   A, [BC]                                       ;; 04:49a4 $0a
    ld   [DE], A                                       ;; 04:49a5 $12
    inc  BC                                            ;; 04:49a6 $03
    inc  DE                                            ;; 04:49a7 $13
    inc  DE                                            ;; 04:49a8 $13
    ld   A, [BC]                                       ;; 04:49a9 $0a
    ld   [DE], A                                       ;; 04:49aa $12
    inc  BC                                            ;; 04:49ab $03
    dec  DE                                            ;; 04:49ac $1b
    ld   A, [BC]                                       ;; 04:49ad $0a
    ld   [DE], A                                       ;; 04:49ae $12
    inc  BC                                            ;; 04:49af $03
.jr_04_49b0:
    dec  HL                                            ;; 04:49b0 $2b
    ld   [HL], B                                       ;; 04:49b1 $70
    dec  HL                                            ;; 04:49b2 $2b
    ld   [HL], C                                       ;; 04:49b3 $71
    ret                                                ;; 04:49b4 $c9
.jr_04_49b5:
    ld   A, $00                                        ;; 04:49b5 $3e $00
    dec  HL                                            ;; 04:49b7 $2b
    ld   [HL], A                                       ;; 04:49b8 $77
    dec  HL                                            ;; 04:49b9 $2b
    ld   [HL], A                                       ;; 04:49ba $77
    ld   HL, wDF74                                     ;; 04:49bb $21 $74 $df
    ld   C, [HL]                                       ;; 04:49be $4e
    inc  HL                                            ;; 04:49bf $23
    ld   B, [HL]                                       ;; 04:49c0 $46
    ld   A, [BC]                                       ;; 04:49c1 $0a
    and  A, $02                                        ;; 04:49c2 $e6 $02
    jp   Z, .jp_04_49cb                                ;; 04:49c4 $ca $cb $49
    ld   A, [BC]                                       ;; 04:49c7 $0a
    or   A, $01                                        ;; 04:49c8 $f6 $01
    ld   [BC], A                                       ;; 04:49ca $02
.jp_04_49cb:
    ld   A, [wDF79]                                    ;; 04:49cb $fa $79 $df
    ldh  [rNR51], A                                    ;; 04:49ce $e0 $25
    ret                                                ;; 04:49d0 $c9
.jr_04_49d1:
    inc  BC                                            ;; 04:49d1 $03
    ld   A, [BC]                                       ;; 04:49d2 $0a
    ld   E, A                                          ;; 04:49d3 $5f
    inc  BC                                            ;; 04:49d4 $03
    ld   A, [BC]                                       ;; 04:49d5 $0a
    ld   B, A                                          ;; 04:49d6 $47
    ld   C, E                                          ;; 04:49d7 $4b
    ld   A, $01                                        ;; 04:49d8 $3e $01
    ld   [HL], A                                       ;; 04:49da $77
    jr   .jr_04_49b0                                   ;; 04:49db $18 $d3

data_04_49dd:
    db   $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa        ;; 04:49dd ........
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 04:49e5 ........

data_04_49ed:
    dw   data_04_541a                                  ;; 04:49ed pP
    dw   data_04_5421                                  ;; 04:49ef pP
    dw   data_04_5428                                  ;; 04:49f1 pP
    dw   data_04_542f                                  ;; 04:49f3 pP
    dw   data_04_4ad5                                  ;; 04:49f5 pP
    dw   data_04_4ade                                  ;; 04:49f7 pP
    db   $fa, $4a, $ec, $4a                            ;; 04:49f9 ????
    dw   data_04_4b35                                  ;; 04:49fd pP
    db   $8e, $4b                                      ;; 04:49ff ??
    dw   data_04_4bce                                  ;; 04:4a01 pP
    dw   data_04_4c31                                  ;; 04:4a03 pP
    dw   data_04_4c94                                  ;; 04:4a05 pP
    dw   data_04_4ccf                                  ;; 04:4a07 pP
    db   $fb, $4c                                      ;; 04:4a09 ??
    dw   data_04_4d09                                  ;; 04:4a0b pP
    db   $3f, $4d, $66, $4d                            ;; 04:4a0d ????
    dw   data_04_4db3                                  ;; 04:4a11 pP
    dw   data_04_4d97                                  ;; 04:4a13 pP
    dw   data_04_4da0                                  ;; 04:4a15 pP
    dw   data_04_4f15                                  ;; 04:4a17 pP
    dw   data_04_4f50                                  ;; 04:4a19 pP
    db   $8b, $4f, $c1, $4f                            ;; 04:4a1b ????
    dw   data_04_4fca                                  ;; 04:4a1f pP
    dw   data_04_4fd3                                  ;; 04:4a21 pP
    db   $56, $50, $40, $50, $64, $50, $9f, $50        ;; 04:4a23 ????????
    db   $d5, $50, $19, $51, $de, $50, $3a, $51        ;; 04:4a2b ????????
    db   $22, $51, $48, $51, $ba, $51, $c3, $51        ;; 04:4a33 ????????
    db   $d1, $51, $02, $52, $10, $52, $32, $52        ;; 04:4a3b ????????
    dw   data_04_5240                                  ;; 04:4a43 pP
    db   $4e, $52, $70, $52, $79, $52, $96, $52        ;; 04:4a45 ????????
    dw   data_04_52a4                                  ;; 04:4a4d pP
    dw   data_04_532f                                  ;; 04:4a4f pP
    dw   data_04_533d                                  ;; 04:4a51 pP
    dw   data_04_534b                                  ;; 04:4a53 pP
    dw   data_04_53d6                                  ;; 04:4a55 pP
    dw   data_04_53df                                  ;; 04:4a57 pP

data_04_4a59:
    db   $00, $01, $02, $03, $04, $ff, $ff, $ff        ;; 04:4a59 ........
    db   $05, $ff, $ff, $ff, $07, $06, $ff, $ff        ;; 04:4a61 ....????
    db   $08, $ff, $ff, $ff, $09, $ff, $ff, $ff        ;; 04:4a69 ....????
    db   $0a, $ff, $ff, $ff, $0b, $0c, $ff, $ff        ;; 04:4a71 ........
    db   $0d, $ff, $ff, $ff, $0e, $ff, $ff, $ff        ;; 04:4a79 ....????
    db   $0f, $ff, $ff, $ff, $10, $ff, $ff, $ff        ;; 04:4a81 ....????
    db   $11, $ff, $ff, $ff, $12, $13, $14, $ff        ;; 04:4a89 ????....
    db   $15, $16, $ff, $ff, $17, $18, $ff, $ff        ;; 04:4a91 ....????
    db   $19, $1a, $ff, $ff, $1b, $1c, $ff, $ff        ;; 04:4a99 ....????
    db   $1d, $1e, $1f, $ff, $20, $21, $ff, $ff        ;; 04:4aa1 ????????
    db   $22, $23, $ff, $ff, $24, $25, $ff, $ff        ;; 04:4aa9 ????????
    db   $26, $ff, $ff, $ff, $27, $28, $ff, $ff        ;; 04:4ab1 ????????
    db   $29, $2a, $ff, $ff, $2b, $ff, $ff, $ff        ;; 04:4ab9 ????....
    db   $2c, $2d, $ff, $ff, $2e, $ff, $ff, $ff        ;; 04:4ac1 ????????
    db   $2f, $ff, $ff, $ff, $30, $31, $32, $ff        ;; 04:4ac9 ????....
    db   $33, $34, $35, $ff                            ;; 04:4ad1 ....

data_04_4ad5:
    db   $01, $23, $80, $84, $87, $cf, $fe             ;; 04:4ad5 .......
    dw   data_04_541b                                  ;; 04:4adc pP

data_04_4ade:
    db   $01, $02, $80, $c1, $87, $8a, $0a, $80        ;; 04:4ade ........
    db   $c1, $87, $a8, $fe                            ;; 04:4ae6 ....
    dw   data_04_541b                                  ;; 04:4aea pP
    db   $03, $02, $00, $f0, $80, $62, $23, $00        ;; 04:4aec ????????
    db   $a3, $80, $47, $fe, $1b, $54, $01, $02        ;; 04:4af4 ????????
    db   $80, $f0, $80, $9d, $02, $80, $70, $87        ;; 04:4afc ????????
    db   $d9, $03, $80, $60, $87, $c5, $02, $80        ;; 04:4b04 ????????
    db   $50, $87, $e6, $01, $80, $40, $87, $d4        ;; 04:4b0c ????????
    db   $05, $80, $40, $87, $e8, $03, $80, $30        ;; 04:4b14 ????????
    db   $87, $ed, $01, $80, $30, $87, $dd, $06        ;; 04:4b1c ????????
    db   $80, $20, $87, $f1, $04, $80, $20, $87        ;; 04:4b24 ????????
    db   $e3, $04, $80, $10, $87, $d7, $fe, $1b        ;; 04:4b2c ????????
    db   $54                                           ;; 04:4b34 ?

data_04_4b35:
    db   $03, $01, $00, $20, $80, $47, $01, $00        ;; 04:4b35 ........
    db   $30, $80, $46, $01, $00, $40, $80, $45        ;; 04:4b3d ........
    db   $01, $00, $50, $80, $44, $02, $00, $60        ;; 04:4b45 ........
    db   $80, $43, $02, $00, $70, $80, $42, $02        ;; 04:4b4d ........
    db   $00, $80, $80, $35, $02, $00, $80, $80        ;; 04:4b55 ........
    db   $34, $02, $00, $80, $80, $33, $02, $00        ;; 04:4b5d ........
    db   $00, $00, $00, $02, $00, $f0, $80, $24        ;; 04:4b65 ........
    db   $02, $00, $70, $80, $23, $02, $00, $50        ;; 04:4b6d ........
    db   $80, $24, $02, $00, $40, $80, $24, $02        ;; 04:4b75 ........
    db   $00, $30, $80, $24, $03, $00, $20, $80        ;; 04:4b7d ........
    db   $24, $03, $00, $10, $80, $24, $fe             ;; 04:4b85 .......
    dw   data_04_541b                                  ;; 04:4b8c pP
    db   $03, $02, $00, $50, $80, $06, $02, $00        ;; 04:4b8e ????????
    db   $60, $80, $14, $02, $00, $70, $80, $21        ;; 04:4b96 ????????
    db   $02, $00, $80, $80, $23, $02, $00, $90        ;; 04:4b9e ????????
    db   $80, $24, $02, $00, $a0, $80, $32, $02        ;; 04:4ba6 ????????
    db   $00, $b0, $80, $33, $02, $00, $c0, $80        ;; 04:4bae ????????
    db   $34, $01, $00, $00, $00, $00, $02, $00        ;; 04:4bb6 ????????
    db   $f0, $80, $44, $01, $00, $00, $00, $00        ;; 04:4bbe ????????
    db   $02, $00, $d0, $80, $47, $fe, $1b, $54        ;; 04:4bc6 ????????

data_04_4bce:
    db   $01, $04, $80, $f0, $84, $50, $01, $80        ;; 04:4bce ........
    db   $f0, $84, $64, $01, $80, $f0, $84, $78        ;; 04:4bd6 ........
    db   $01, $80, $f0, $84, $8c, $01, $80, $f0        ;; 04:4bde ........
    db   $84, $a0, $01, $80, $e0, $84, $b4, $01        ;; 04:4be6 ........
    db   $80, $d0, $84, $c8, $01, $80, $c0, $84        ;; 04:4bee ........
    db   $d2, $01, $80, $80, $84, $dc, $01, $80        ;; 04:4bf6 ........
    db   $80, $84, $e6, $01, $80, $80, $84, $f0        ;; 04:4bfe ........
    db   $01, $80, $70, $84, $fa, $01, $80, $50        ;; 04:4c06 ........
    db   $85, $05, $02, $80, $30, $85, $0f, $02        ;; 04:4c0e ........
    db   $80, $20, $85, $19, $03, $80, $20, $85        ;; 04:4c16 ........
    db   $23, $03, $80, $10, $85, $2d, $03, $80        ;; 04:4c1e ........
    db   $10, $85, $37, $03, $80, $10, $85, $41        ;; 04:4c26 ........
    db   $fe                                           ;; 04:4c2e .
    dw   data_04_541b                                  ;; 04:4c2f pP

data_04_4c31:
    db   $01, $04, $80, $f0, $82, $00, $02, $80        ;; 04:4c31 ........
    db   $f0, $82, $1e, $02, $80, $f0, $82, $3c        ;; 04:4c39 ........
    db   $02, $80, $f0, $82, $5a, $02, $80, $f0        ;; 04:4c41 ........
    db   $82, $78, $02, $80, $e0, $82, $96, $01        ;; 04:4c49 ........
    db   $80, $d0, $82, $b4, $01, $80, $c0, $82        ;; 04:4c51 ........
    db   $d2, $01, $80, $80, $82, $f0, $01, $80        ;; 04:4c59 ........
    db   $80, $83, $0f, $01, $80, $80, $82, $2d        ;; 04:4c61 ........
    db   $01, $80, $70, $82, $4b, $01, $80, $50        ;; 04:4c69 ........
    db   $82, $69, $02, $80, $30, $82, $87, $02        ;; 04:4c71 ........
    db   $80, $20, $82, $a5, $03, $80, $20, $82        ;; 04:4c79 ........
    db   $c3, $03, $80, $10, $82, $e1, $03, $80        ;; 04:4c81 ........
    db   $10, $82, $fa, $03, $80, $10, $82, $ff        ;; 04:4c89 ........
    db   $fe                                           ;; 04:4c91 .
    dw   data_04_541b                                  ;; 04:4c92 pP

data_04_4c94:
    db   $00, $04, $80, $f0, $82, $01, $02, $80        ;; 04:4c94 ........
    db   $f0, $82, $1f, $02, $80, $f0, $82, $3d        ;; 04:4c9c ........
    db   $02, $80, $f0, $82, $5b, $02, $80, $f0        ;; 04:4ca4 ........
    db   $82, $79, $02, $80, $e0, $82, $97, $01        ;; 04:4cac ........
    db   $80, $d0, $82, $b5, $01, $80, $c0, $82        ;; 04:4cb4 ........
    db   $d3, $01, $80, $80, $82, $f1, $01, $80        ;; 04:4cbc ........
    db   $80, $83, $10, $01, $80, $80, $82, $2e        ;; 04:4cc4 ........
    db   $fe                                           ;; 04:4ccc .
    dw   data_04_541b                                  ;; 04:4ccd pP

data_04_4ccf:
    db   $03, $04, $00, $f0, $80, $61, $01, $00        ;; 04:4ccf ........
    db   $70, $80, $35, $01, $00, $60, $80, $47        ;; 04:4cd7 ........
    db   $01, $00, $50, $80, $34, $01, $00, $40        ;; 04:4cdf ........
    db   $80, $46, $01, $00, $30, $80, $33, $01        ;; 04:4ce7 ........
    db   $00, $20, $80, $45, $02, $00, $10, $80        ;; 04:4cef ........
    db   $32, $fe                                      ;; 04:4cf7 ..
    dw   data_04_541b                                  ;; 04:4cf9 pP
    db   $03, $14, $00, $1a, $80, $22, $3c, $00        ;; 04:4cfb ????????
    db   $f4, $80, $22, $fe, $1b, $54                  ;; 04:4d03 ??????

data_04_4d09:
    db   $01, $02, $80, $f0, $85, $c8, $01, $80        ;; 04:4d09 ........
    db   $f0, $85, $b4, $01, $80, $f0, $85, $a0        ;; 04:4d11 ........
    db   $01, $80, $f0, $85, $8c, $01, $80, $e0        ;; 04:4d19 ........
    db   $85, $78, $01, $80, $e0, $85, $64, $01        ;; 04:4d21 ........
    db   $80, $d0, $85, $50, $01, $80, $d0, $85        ;; 04:4d29 ........
    db   $3c, $01, $80, $c0, $85, $28, $01, $80        ;; 04:4d31 ........
    db   $c0, $85, $14, $fe                            ;; 04:4d39 ....
    dw   data_04_541b                                  ;; 04:4d3d pP
    db   $01, $02, $80, $f0, $87, $8c, $01, $80        ;; 04:4d3f ????????
    db   $e0, $87, $87, $01, $80, $c0, $87, $82        ;; 04:4d47 ????????
    db   $01, $80, $a0, $87, $7d, $01, $80, $80        ;; 04:4d4f ????????
    db   $87, $78, $01, $80, $50, $87, $73, $01        ;; 04:4d57 ????????
    db   $80, $30, $87, $6e, $fe, $1b, $54, $03        ;; 04:4d5f ????????
    db   $01, $00, $c0, $80, $44, $01, $00, $d0        ;; 04:4d67 ????????
    db   $80, $43, $01, $00, $e0, $80, $44, $01        ;; 04:4d6f ????????
    db   $00, $f0, $80, $43, $01, $00, $f0, $80        ;; 04:4d77 ????????
    db   $44, $01, $00, $f0, $80, $43, $02, $00        ;; 04:4d7f ????????
    db   $00, $00, $00, $01, $00, $f0, $80, $23        ;; 04:4d87 ????????
    db   $06, $00, $51, $80, $23, $fe, $1b, $54        ;; 04:4d8f ????????

data_04_4d97:
    db   $00, $46, $80, $f4, $82, $23, $fe             ;; 04:4d97 .......
    dw   data_04_541b                                  ;; 04:4d9e pP

data_04_4da0:
    db   $02, $1e, $00, $20, $84, $e5, $1e, $00        ;; 04:4da0 ........
    db   $40, $84, $e5, $0a, $00, $60, $84, $e5        ;; 04:4da8 ........
    db   $fe                                           ;; 04:4db0 .
    dw   data_04_541b                                  ;; 04:4db1 pP

data_04_4db3:
    db   $01, $01, $80, $40, $87, $dc, $01, $80        ;; 04:4db3 ........
    db   $50, $87, $dd, $01, $80, $60, $87, $de        ;; 04:4dbb ........
    db   $01, $80, $70, $87, $df, $01, $80, $80        ;; 04:4dc3 ........
    db   $87, $e0, $01, $80, $50, $87, $d9, $01        ;; 04:4dcb ........
    db   $80, $60, $87, $da, $01, $80, $70, $87        ;; 04:4dd3 ........
    db   $db, $01, $80, $80, $87, $dc, $01, $80        ;; 04:4ddb ........
    db   $90, $87, $dd, $01, $80, $30, $87, $d6        ;; 04:4de3 ........
    db   $01, $80, $40, $87, $d7, $01, $80, $50        ;; 04:4deb ........
    db   $87, $d8, $01, $80, $60, $87, $d9, $01        ;; 04:4df3 ........
    db   $80, $70, $87, $da, $01, $80, $40, $87        ;; 04:4dfb ........
    db   $df, $01, $80, $50, $87, $e0, $01, $80        ;; 04:4e03 ........
    db   $60, $87, $e1, $01, $80, $70, $87, $e2        ;; 04:4e0b ........
    db   $01, $80, $80, $87, $e3, $01, $80, $20        ;; 04:4e13 ........
    db   $87, $d4, $01, $80, $30, $87, $d5, $01        ;; 04:4e1b ........
    db   $80, $40, $87, $d6, $01, $80, $50, $87        ;; 04:4e23 ........
    db   $d7, $01, $80, $60, $87, $d8, $01, $80        ;; 04:4e2b ........
    db   $40, $87, $da, $01, $80, $50, $87, $db        ;; 04:4e33 ........
    db   $01, $80, $60, $87, $dc, $01, $80, $70        ;; 04:4e3b ........
    db   $87, $dd, $01, $80, $80, $87, $de, $01        ;; 04:4e43 ........
    db   $80, $50, $87, $df, $01, $80, $60, $87        ;; 04:4e4b ........
    db   $e0, $01, $80, $70, $87, $e1, $01, $80        ;; 04:4e53 ........
    db   $80, $87, $e2, $01, $80, $90, $87, $e3        ;; 04:4e5b ........
    db   $01, $80, $20, $87, $d3, $01, $80, $30        ;; 04:4e63 ........
    db   $87, $d4, $01, $80, $40, $87, $d5, $01        ;; 04:4e6b ........
    db   $80, $50, $87, $d6, $01, $80, $60, $87        ;; 04:4e73 ........
    db   $d7, $01, $80, $20, $87, $d9, $01, $80        ;; 04:4e7b ........
    db   $30, $87, $da, $01, $80, $40, $87, $db        ;; 04:4e83 ........
    db   $01, $80, $50, $87, $dc, $01, $80, $70        ;; 04:4e8b ........
    db   $87, $dd, $01, $80, $20, $87, $d0, $01        ;; 04:4e93 ........
    db   $80, $30, $87, $d1, $01, $80, $40, $87        ;; 04:4e9b ........
    db   $d2, $01, $80, $50, $87, $d3, $01, $80        ;; 04:4ea3 ........
    db   $60, $87, $d4, $01, $80, $40, $87, $d4        ;; 04:4eab ........
    db   $01, $80, $50, $87, $d5, $01, $80, $60        ;; 04:4eb3 ........
    db   $87, $d6, $01, $80, $50, $87, $d7, $01        ;; 04:4ebb ........
    db   $80, $40, $87, $d8, $01, $80, $20, $87        ;; 04:4ec3 ........
    db   $cd, $01, $80, $30, $87, $ce, $01, $80        ;; 04:4ecb ........
    db   $40, $87, $cf, $01, $80, $50, $87, $d0        ;; 04:4ed3 ........
    db   $01, $80, $60, $87, $d1, $01, $80, $20        ;; 04:4edb ........
    db   $87, $d9, $01, $80, $30, $87, $da, $01        ;; 04:4ee3 ........
    db   $80, $40, $87, $db, $01, $80, $50, $87        ;; 04:4eeb ........
    db   $dc, $01, $80, $60, $87, $dd, $01, $80        ;; 04:4ef3 ........
    db   $20, $87, $c8, $01, $80, $30, $87, $c9        ;; 04:4efb ........
    db   $01, $80, $40, $87, $ca, $01, $80, $50        ;; 04:4f03 ........
    db   $87, $cb, $01, $80, $40, $87, $cc, $fe        ;; 04:4f0b ........
    dw   data_04_541b                                  ;; 04:4f13 pP

data_04_4f15:
    db   $00, $05, $40, $10, $82, $37, $05, $40        ;; 04:4f15 ........
    db   $20, $82, $3c, $05, $40, $40, $82, $41        ;; 04:4f1d ........
    db   $05, $40, $80, $82, $46, $05, $40, $a0        ;; 04:4f25 ........
    db   $82, $4b, $05, $40, $b0, $82, $50, $05        ;; 04:4f2d ........
    db   $40, $c0, $82, $55, $05, $40, $d0, $82        ;; 04:4f35 ........
    db   $5a, $05, $40, $e0, $82, $5f, $05, $40        ;; 04:4f3d ........
    db   $f0, $82, $64, $5a, $40, $f7, $82, $69        ;; 04:4f45 ........
    db   $fe                                           ;; 04:4f4d .
    dw   data_04_541b                                  ;; 04:4f4e pP

data_04_4f50:
    db   $01, $05, $40, $10, $82, $3a, $05, $40        ;; 04:4f50 ........
    db   $20, $82, $3f, $05, $40, $40, $82, $44        ;; 04:4f58 ........
    db   $05, $40, $80, $82, $49, $05, $40, $a0        ;; 04:4f60 ........
    db   $82, $4e, $05, $40, $b0, $82, $53, $05        ;; 04:4f68 ........
    db   $40, $c0, $82, $58, $05, $40, $d0, $82        ;; 04:4f70 ........
    db   $5d, $05, $40, $e0, $82, $62, $05, $40        ;; 04:4f78 ........
    db   $f0, $82, $67, $5a, $40, $f7, $82, $6c        ;; 04:4f80 ........
    db   $fe                                           ;; 04:4f88 .
    dw   data_04_541b                                  ;; 04:4f89 pP
    db   $01, $02, $80, $f0, $85, $c8, $01, $80        ;; 04:4f8b ????????
    db   $a0, $85, $be, $01, $80, $90, $85, $b4        ;; 04:4f93 ????????
    db   $01, $80, $80, $85, $aa, $01, $80, $70        ;; 04:4f9b ????????
    db   $85, $a0, $01, $80, $60, $85, $96, $01        ;; 04:4fa3 ????????
    db   $80, $50, $85, $8c, $01, $80, $40, $85        ;; 04:4fab ????????
    db   $82, $01, $80, $30, $85, $78, $01, $80        ;; 04:4fb3 ????????
    db   $20, $85, $64, $fe, $1b, $54, $03, $0c        ;; 04:4fbb ????????
    db   $00, $72, $80, $47, $fe, $1b, $54             ;; 04:4fc3 ???????

data_04_4fca:
    db   $00, $0a, $00, $00, $00, $00, $fe             ;; 04:4fca .......
    dw   data_04_4fd4                                  ;; 04:4fd1 pP

data_04_4fd3:
    db   $01                                           ;; 04:4fd3 .

data_04_4fd4:
    db   $05, $80, $f0, $85, $c8, $05, $80, $f0        ;; 04:4fd4 ........
    db   $85, $96, $05, $80, $e0, $85, $64, $05        ;; 04:4fdc ........
    db   $80, $e0, $85, $32, $05, $80, $d0, $84        ;; 04:4fe4 ........
    db   $fa, $05, $80, $d0, $84, $c8, $05, $80        ;; 04:4fec ........
    db   $c0, $84, $96, $05, $80, $b0, $84, $64        ;; 04:4ff4 ........
    db   $05, $80, $a0, $84, $32, $05, $80, $a0        ;; 04:4ffc ........
    db   $84, $00, $05, $80, $90, $83, $c8, $05        ;; 04:5004 ........
    db   $80, $80, $83, $96, $05, $80, $70, $83        ;; 04:500c ........
    db   $64, $05, $80, $70, $83, $32, $05, $80        ;; 04:5014 ........
    db   $60, $83, $00, $05, $80, $50, $82, $c8        ;; 04:501c ........
    db   $05, $80, $40, $82, $96, $05, $80, $30        ;; 04:5024 ........
    db   $82, $64, $05, $80, $20, $82, $32, $05        ;; 04:502c ........
    db   $80, $20, $82, $00, $05, $80, $10, $81        ;; 04:5034 ........
    db   $c8, $fe                                      ;; 04:503c ..
    dw   data_04_541b                                  ;; 04:503e pP
    db   $03, $01, $00, $f0, $80, $23, $01, $00        ;; 04:5040 ????????
    db   $20, $80, $23, $03, $00, $f1, $80, $61        ;; 04:5048 ????????
    db   $28, $00, $65, $80, $61, $ff, $01, $02        ;; 04:5050 ????????
    db   $80, $f0, $80, $9d, $02, $80, $44, $80        ;; 04:5058 ????????
    db   $9d, $fe, $1b, $54, $00, $01, $00, $00        ;; 04:5060 ????????
    db   $00, $00, $02, $40, $10, $80, $64, $02        ;; 04:5068 ????????
    db   $00, $10, $81, $c8, $02, $40, $20, $80        ;; 04:5070 ????????
    db   $64, $02, $00, $40, $81, $c8, $02, $40        ;; 04:5078 ????????
    db   $60, $80, $64, $02, $00, $80, $81, $c8        ;; 04:5080 ????????
    db   $02, $40, $a0, $80, $64, $02, $00, $c0        ;; 04:5088 ????????
    db   $81, $c8, $02, $40, $e0, $80, $64, $14        ;; 04:5090 ????????
    db   $00, $f5, $80, $64, $fe, $1b, $54, $01        ;; 04:5098 ????????
    db   $02, $40, $10, $80, $67, $02, $00, $10        ;; 04:50a0 ????????
    db   $81, $cb, $02, $40, $20, $80, $67, $02        ;; 04:50a8 ????????
    db   $00, $40, $81, $cb, $02, $40, $60, $80        ;; 04:50b0 ????????
    db   $67, $02, $00, $80, $81, $cb, $02, $40        ;; 04:50b8 ????????
    db   $a0, $80, $67, $02, $00, $c0, $81, $cb        ;; 04:50c0 ????????
    db   $02, $40, $e0, $80, $67, $14, $00, $f5        ;; 04:50c8 ????????
    db   $80, $67, $fe, $1b, $54, $03, $08, $00        ;; 04:50d0 ????????
    db   $f1, $80, $64, $fe, $1b, $54, $03, $08        ;; 04:50d8 ????????
    db   $00, $f0, $80, $62, $14, $00, $a5, $80        ;; 04:50e0 ????????
    db   $61, $07, $00, $10, $80, $5f, $06, $00        ;; 04:50e8 ????????
    db   $20, $80, $60, $05, $00, $30, $80, $5f        ;; 04:50f0 ????????
    db   $05, $00, $40, $80, $46, $05, $00, $50        ;; 04:50f8 ????????
    db   $80, $45, $04, $00, $60, $80, $44, $05        ;; 04:5100 ????????
    db   $00, $70, $80, $43, $06, $00, $80, $80        ;; 04:5108 ????????
    db   $42, $50, $00, $97, $80, $41, $fe, $1b        ;; 04:5110 ????????
    db   $54, $01, $28, $80, $f5, $80, $9d, $fe        ;; 04:5118 ????????
    db   $1b, $54, $03, $01, $00, $f0, $80, $44        ;; 04:5120 ????????
    db   $01, $00, $20, $80, $44, $03, $00, $f1        ;; 04:5128 ????????
    db   $80, $47, $50, $00, $67, $80, $46, $fe        ;; 04:5130 ????????
    db   $1b, $54, $01, $02, $80, $f0, $80, $9d        ;; 04:5138 ????????
    db   $02, $80, $45, $80, $9d, $fe, $1b, $54        ;; 04:5140 ????????
    db   $01, $02, $80, $f0, $80, $64, $01, $80        ;; 04:5148 ????????
    db   $e0, $87, $d7, $02, $80, $d0, $87, $c8        ;; 04:5150 ????????
    db   $03, $80, $c0, $87, $b4, $02, $80, $b0        ;; 04:5158 ????????
    db   $87, $df, $02, $80, $a0, $87, $d4, $01        ;; 04:5160 ????????
    db   $80, $90, $87, $e6, $01, $80, $80, $87        ;; 04:5168 ????????
    db   $cc, $02, $80, $70, $87, $ba, $02, $80        ;; 04:5170 ????????
    db   $60, $87, $df, $01, $80, $50, $87, $c3        ;; 04:5178 ????????
    db   $02, $80, $40, $87, $e3, $02, $80, $30        ;; 04:5180 ????????
    db   $87, $c3, $01, $80, $20, $87, $e3, $03        ;; 04:5188 ????????
    db   $80, $20, $87, $d1, $02, $80, $20, $87        ;; 04:5190 ????????
    db   $de, $03, $80, $20, $87, $d7, $02, $80        ;; 04:5198 ????????
    db   $10, $87, $d4, $03, $80, $10, $87, $e2        ;; 04:51a0 ????????
    db   $01, $80, $10, $87, $d5, $03, $80, $10        ;; 04:51a8 ????????
    db   $87, $e5, $02, $80, $10, $87, $d3, $fe        ;; 04:51b0 ????????
    db   $1b, $54, $00, $02, $80, $f0, $80, $64        ;; 04:51b8 ????????
    db   $fe, $1b, $54, $03, $01, $3c, $f0, $c0        ;; 04:51c0 ????????
    db   $23, $01, $3c, $f0, $c0, $21, $fe, $1b        ;; 04:51c8 ????????
    db   $54, $03, $01, $00, $f0, $80, $45, $0a        ;; 04:51d0 ????????
    db   $00, $92, $80, $62, $03, $00, $00, $00        ;; 04:51d8 ????????
    db   $00, $01, $00, $f0, $80, $44, $01, $00        ;; 04:51e0 ????????
    db   $40, $80, $44, $01, $00, $20, $80, $44        ;; 04:51e8 ????????
    db   $01, $00, $20, $80, $44, $01, $00, $10        ;; 04:51f0 ????????
    db   $80, $44, $06, $00, $10, $80, $62, $fe        ;; 04:51f8 ????????
    db   $1b, $54, $01, $01, $00, $00, $00, $00        ;; 04:5200 ????????
    db   $0a, $00, $0a, $87, $e3, $fe, $1b, $54        ;; 04:5208 ????????
    db   $03, $08, $00, $0b, $80, $61, $01, $00        ;; 04:5210 ????????
    db   $f0, $80, $44, $0a, $00, $52, $80, $61        ;; 04:5218 ????????
    db   $03, $00, $00, $00, $00, $14, $00, $0b        ;; 04:5220 ????????
    db   $80, $14, $28, $00, $67, $80, $14, $fe        ;; 04:5228 ????????
    db   $1b, $54, $01, $09, $00, $00, $00, $00        ;; 04:5230 ????????
    db   $0a, $00, $0a, $87, $e3, $fe, $1b, $54        ;; 04:5238 ????????

data_04_5240:
    db   $03, $03, $00, $f1, $80, $63, $1e, $00        ;; 04:5240 ........
    db   $a3, $80, $62, $fe                            ;; 04:5248 ....
    dw   data_04_541b                                  ;; 04:524c pP
    db   $03, $05, $00, $f2, $80, $62, $05, $00        ;; 04:524e ????????
    db   $f2, $80, $64, $05, $00, $f2, $80, $63        ;; 04:5256 ????????
    db   $05, $00, $f2, $80, $62, $64, $00, $f7        ;; 04:525e ????????
    db   $80, $62, $14, $00, $10, $80, $62, $fe        ;; 04:5266 ????????
    db   $1b, $54, $01, $03, $80, $f0, $81, $c8        ;; 04:526e ????????
    db   $fe, $1b, $54, $01, $01, $80, $50, $87        ;; 04:5276 ????????
    db   $c5, $01, $80, $a0, $87, $8a, $01, $80        ;; 04:527e ????????
    db   $50, $87, $c5, $01, $80, $a0, $87, $8a        ;; 04:5286 ????????
    db   $32, $80, $a6, $87, $be, $fe, $1b, $54        ;; 04:528e ????????
    db   $01, $02, $bc, $f0, $c7, $c5, $03, $bc        ;; 04:5296 ????????
    db   $f0, $c7, $8a, $fe, $1b, $54                  ;; 04:529e ??????

data_04_52a4:
    db   $03, $05, $00, $20, $80, $66, $05, $00        ;; 04:52a4 ........
    db   $30, $80, $65, $05, $00, $40, $80, $64        ;; 04:52ac ........
    db   $05, $00, $50, $80, $63, $05, $00, $60        ;; 04:52b4 ........
    db   $80, $62, $05, $00, $70, $80, $61, $05        ;; 04:52bc ........
    db   $00, $80, $80, $60, $05, $00, $90, $80        ;; 04:52c4 ........
    db   $47, $05, $00, $a0, $80, $46, $05, $00        ;; 04:52cc ........
    db   $b0, $80, $45, $05, $00, $c0, $80, $44        ;; 04:52d4 ........
    db   $05, $00, $d0, $80, $43, $05, $00, $e0        ;; 04:52dc ........
    db   $80, $42, $05, $00, $f0, $80, $35, $05        ;; 04:52e4 ........
    db   $00, $e0, $80, $34, $05, $00, $d0, $80        ;; 04:52ec ........
    db   $33, $05, $00, $c0, $80, $32, $05, $00        ;; 04:52f4 ........
    db   $b0, $80, $24, $05, $00, $a0, $80, $23        ;; 04:52fc ........
    db   $05, $00, $90, $80, $22, $06, $00, $80        ;; 04:5304 ........
    db   $80, $21, $07, $00, $70, $80, $20, $07        ;; 04:530c ........
    db   $00, $60, $80, $14, $07, $00, $40, $80        ;; 04:5314 ........
    db   $07, $07, $00, $30, $80, $06, $07, $00        ;; 04:531c ........
    db   $20, $80, $05, $07, $00, $10, $80, $04        ;; 04:5324 ........
    db   $fe                                           ;; 04:532c .
    dw   data_04_541b                                  ;; 04:532d pP

data_04_532f:
    db   $01, $14, $00, $0a, $80, $32, $5a, $00        ;; 04:532f ........
    db   $f7, $80, $32, $fe                            ;; 04:5337 ....
    dw   data_04_541b                                  ;; 04:533b pP

data_04_533d:
    db   $00, $14, $00, $0a, $80, $37, $5a, $00        ;; 04:533d ........
    db   $f7, $80, $37, $fe                            ;; 04:5345 ....
    dw   data_04_541b                                  ;; 04:5349 pP

data_04_534b:
    db   $00                                           ;; 04:534b .

data_04_534c:
    db   $08, $80, $c1, $87, $8a, $08, $80, $c1        ;; 04:534c ........
    db   $87, $a3, $08, $80, $c1, $87, $b1, $08        ;; 04:5354 ........
    db   $80, $c1, $87, $be, $08, $80, $c1, $87        ;; 04:535c ........
    db   $a8, $08, $80, $c1, $87, $97, $08, $80        ;; 04:5364 ........
    db   $c1, $87, $6c, $08, $80, $c1, $87, $8a        ;; 04:536c ........
    db   $08, $80, $c1, $87, $9d, $08, $80, $c1        ;; 04:5374 ........
    db   $87, $97, $08, $80, $c1, $87, $83, $08        ;; 04:537c ........
    db   $80, $c1, $87, $63, $08, $80, $c1, $87        ;; 04:5384 ........
    db   $4f, $08, $80, $c1, $87, $74, $08, $80        ;; 04:538c ........
    db   $c1, $87, $8a, $08, $80, $c1, $87, $7c        ;; 04:5394 ........
    db   $08, $80, $c1, $87, $63, $08, $80, $c1        ;; 04:539c ........
    db   $87, $3a, $08, $80, $c1, $87, $2e, $08        ;; 04:53a4 ........
    db   $80, $c1, $87, $4f, $08, $80, $c1, $87        ;; 04:53ac ........
    db   $74, $08, $80, $c1, $87, $63, $08, $80        ;; 04:53b4 ........
    db   $c1, $87, $45, $08, $80, $c1, $87, $14        ;; 04:53bc ........
    db   $18, $80, $c5, $84, $4f, $18, $80, $c5        ;; 04:53c4 .....???
    db   $86, $28, $3c, $80, $c7, $87, $14, $fe        ;; 04:53cc ????????
    db   $1b, $54                                      ;; 04:53d4 ??

data_04_53d6:
    db   $01, $08, $00, $00, $00, $00, $fe             ;; 04:53d6 .......
    dw   data_04_534c                                  ;; 04:53dd pP

data_04_53df:
    db   $02, $18, $00, $20, $86, $28, $18, $00        ;; 04:53df ........
    db   $20, $85, $ee, $18, $00, $20, $85, $ad        ;; 04:53e7 ........
    db   $18, $00, $20, $85, $89, $18, $00, $20        ;; 04:53ef ........
    db   $85, $3c, $18, $00, $20, $84, $e5, $18        ;; 04:53f7 ........
    db   $00, $20, $84, $b6, $18, $00, $20, $84        ;; 04:53ff ........
    db   $4f, $18, $00, $20, $80, $9d, $18, $00        ;; 04:5407 ......??
    db   $40, $84, $4f, $30, $00, $60, $86, $28        ;; 04:540f ????????
    db   $fe, $1b, $54                                 ;; 04:5417 ???

data_04_541a:
    db   $00                                           ;; 04:541a .

data_04_541b:
    db   $01, $00, $00, $00, $00, $ff                  ;; 04:541b ......

data_04_5421:
    db   $01, $01, $00, $00, $00, $00, $ff             ;; 04:5421 .......

data_04_5428:
    db   $02, $01, $00, $00, $00, $00, $ff             ;; 04:5428 .......

data_04_542f:
    db   $03, $01, $00, $00, $00, $00, $ff             ;; 04:542f .......

data_04_5436:
    db   $67, $ff, $69, $ff, $24, $00, $66, $01        ;; 04:5436 ........
    db   $61                                           ;; 04:543e .

data_04_543f:
    db   $24, $00, $61                                 ;; 04:543f ...

data_04_5442:
    db   $24, $00, $61                                 ;; 04:5442 ...

data_04_5445:
    db   $24, $00, $61                                 ;; 04:5445 ...

data_04_5448:
    db   $67, $ff, $69, $ad, $64, $00, $00, $04        ;; 04:5448 ........
    db   $64, $09, $e5, $01, $64, $0a, $e5, $01        ;; 04:5450 ........
    db   $64, $0b, $e5, $01, $64, $0c, $e5, $01        ;; 04:5458 ........
    db   $64, $0d, $e5, $01, $64, $0a, $e5, $01        ;; 04:5460 ....????
    db   $64, $0b, $e5, $01, $66, $01, $62, $48        ;; 04:5468 ????????
    db   $54                                           ;; 04:5470 ?

data_04_5471:
    db   $64, $0e, $fd, $02, $64, $0f, $fd, $02        ;; 04:5471 ........
    db   $64, $10, $fd, $01, $64, $11, $fd, $01        ;; 04:5479 ........
    db   $64, $10, $fd, $01, $64, $12, $fd, $01        ;; 04:5481 ........
    db   $64, $13, $fd, $02, $64, $14, $fd, $02        ;; 04:5489 ........
    db   $64, $15, $fd, $01, $64, $0f, $fd, $02        ;; 04:5491 ????????
    db   $64, $10, $fd, $01, $64, $11, $fd, $01        ;; 04:5499 ????????
    db   $64, $10, $fd, $01, $64, $12, $fd, $01        ;; 04:54a1 ????????
    db   $62, $71, $54                                 ;; 04:54a9 ???

data_04_54ac:
    db   $64, $02, $f1, $01, $64, $03, $f1, $01        ;; 04:54ac ........
    db   $64, $02, $f1, $01, $64, $03, $f1, $01        ;; 04:54b4 ........
    db   $64, $04, $f1, $02, $64, $05, $f1, $01        ;; 04:54bc ........
    db   $64, $06, $f1, $01, $64, $07, $f1, $01        ;; 04:54c4 ........
    db   $64, $04, $f1, $02, $64, $05, $f1, $01        ;; 04:54cc ????????
    db   $62, $ac, $54                                 ;; 04:54d4 ???

data_04_54d7:
    db   $64, $01, $00, $14, $64, $08, $00, $01        ;; 04:54d7 ....????
    db   $64, $01, $00, $08, $62, $d7, $54             ;; 04:54df ???????

data_04_54e6:
    db   $24, $0a, $65                                 ;; 04:54e6 ...

data_04_54e9:
    db   $a4, $34, $a4, $32, $a4, $32, $a4, $34        ;; 04:54e9 ........
    db   $a4, $32, $a4, $34, $a4, $34, $a4, $32        ;; 04:54f1 ........
    db   $a4, $34, $a4, $34, $9f, $44, $9f, $42        ;; 04:54f9 ........
    db   $9f, $42, $9f, $44, $9f, $42, $9f, $44        ;; 04:5501 ........
    db   $9f, $44, $9f, $42, $9f, $44, $9f, $44        ;; 04:5509 ........
    db   $9d, $44, $9d, $42, $9d, $42, $9d, $44        ;; 04:5511 ........
    db   $9d, $42, $9d, $44, $9d, $44, $9d, $42        ;; 04:5519 ........
    db   $9d, $44, $9d, $44, $9f, $44, $9f, $42        ;; 04:5521 ........
    db   $9f, $42, $9f, $44, $9f, $42, $9f, $44        ;; 04:5529 ........
    db   $9f, $44, $9f, $42, $9f, $44, $9f, $44        ;; 04:5531 ........
    db   $65                                           ;; 04:5539 .

data_04_553a:
    db   $9f, $44, $9f, $42, $9f, $42, $9f, $44        ;; 04:553a ........
    db   $9f, $42, $9f, $44, $9f, $44, $9f, $42        ;; 04:5542 ........
    db   $9f, $44, $9f, $44, $98, $54, $98, $52        ;; 04:554a ........
    db   $98, $52, $98, $54, $98, $52, $98, $54        ;; 04:5552 ........
    db   $98, $54, $98, $52, $98, $54, $98, $54        ;; 04:555a ........
    db   $9f, $34, $9f, $32, $9f, $32, $9f, $34        ;; 04:5562 ........
    db   $9f, $32, $9f, $34, $9f, $34, $9f, $32        ;; 04:556a ........
    db   $9f, $34, $9f, $34, $98, $54, $98, $52        ;; 04:5572 ........
    db   $98, $52, $98, $54, $98, $52, $98, $54        ;; 04:557a ........
    db   $98, $54, $98, $52, $98, $54, $98, $54        ;; 04:5582 ........
    db   $65                                           ;; 04:558a .

data_04_558b:
    db   $9d, $44, $9d, $42, $9d, $42, $9d, $44        ;; 04:558b ........
    db   $9d, $42, $9d, $44, $9d, $44, $9d, $42        ;; 04:5593 ........
    db   $9d, $44, $9d, $44, $98, $54, $98, $52        ;; 04:559b ........
    db   $98, $52, $98, $54, $98, $52, $98, $54        ;; 04:55a3 ........
    db   $98, $54, $98, $52, $98, $54, $98, $54        ;; 04:55ab ........
    db   $9f, $34, $9f, $32, $9f, $32, $9f, $34        ;; 04:55b3 ........
    db   $9f, $32, $9f, $34, $9f, $34, $9f, $32        ;; 04:55bb ........
    db   $9f, $34, $9f, $34, $65                       ;; 04:55c3 .....

data_04_55c8:
    db   $98, $54, $98, $52, $98, $52, $98, $54        ;; 04:55c8 ........
    db   $98, $52, $98, $54, $98, $54, $98, $52        ;; 04:55d0 ........
    db   $98, $54, $98, $54, $65                       ;; 04:55d8 .....

data_04_55dd:
    db   $98, $54, $98, $54, $9d, $42, $9d, $44        ;; 04:55dd ........
    db   $98, $54, $98, $54, $98, $52, $98, $54        ;; 04:55e5 ........
    db   $98, $54, $65                                 ;; 04:55ed ...

data_04_55f0:
    db   $9d, $44, $9d, $42, $9d, $42, $9d, $44        ;; 04:55f0 ........
    db   $9d, $42, $9d, $44, $9d, $44, $9d, $42        ;; 04:55f8 ........
    db   $9d, $44, $9d, $44, $98, $54, $98, $52        ;; 04:5600 ........
    db   $98, $52, $98, $54, $98, $52, $98, $54        ;; 04:5608 ........
    db   $98, $54, $98, $52, $98, $54, $98, $54        ;; 04:5610 ........
    db   $98, $54, $98, $52, $98, $52, $98, $54        ;; 04:5618 ........
    db   $98, $52, $98, $54, $98, $54, $98, $52        ;; 04:5620 ........
    db   $98, $54, $98, $54, $9d, $44, $9d, $42        ;; 04:5628 ........
    db   $9d, $42, $9d, $44, $9d, $42, $9d, $44        ;; 04:5630 ........
    db   $9d, $44, $9d, $42, $9d, $44, $9d, $44        ;; 04:5638 ........
    db   $65                                           ;; 04:5640 .

data_04_5641:
    db   $a2, $34, $a2, $32, $a2, $32, $a2, $34        ;; 04:5641 ........
    db   $a2, $32, $a2, $34, $a2, $34, $a2, $32        ;; 04:5649 ........
    db   $a2, $34, $a2, $34, $9d, $44, $9d, $42        ;; 04:5651 ........
    db   $9d, $42, $9d, $44, $9d, $42, $9d, $44        ;; 04:5659 ........
    db   $9d, $44, $9d, $42, $9d, $44, $9d, $44        ;; 04:5661 ........
    db   $98, $54, $98, $52, $98, $52, $98, $54        ;; 04:5669 ........
    db   $98, $52, $98, $54, $98, $54, $98, $52        ;; 04:5671 ........
    db   $98, $54, $98, $54, $9d, $44, $9d, $42        ;; 04:5679 ........
    db   $9d, $42, $9d, $44, $9d, $42, $9d, $44        ;; 04:5681 ........
    db   $9d, $44, $9d, $42, $9d, $44, $9d, $44        ;; 04:5689 ........
    db   $65, $9f, $44, $9f, $42, $9f, $42, $9f        ;; 04:5691 .???????
    db   $44, $9f, $42, $9f, $44, $9f, $44, $9f        ;; 04:5699 ????????
    db   $42, $9f, $44, $9f, $44, $65                  ;; 04:56a1 ??????

data_04_56a7:
    db   $18, $12, $1e, $32, $19, $52, $18, $12        ;; 04:56a7 ........
    db   $18, $12, $19, $52, $1e, $32, $18, $12        ;; 04:56af ........
    db   $18, $12, $1e, $32, $19, $52, $18, $12        ;; 04:56b7 ........
    db   $18, $12, $19, $52, $1e, $32, $18, $12        ;; 04:56bf ........
    db   $18, $12, $1e, $32, $19, $52, $18, $12        ;; 04:56c7 ........
    db   $18, $12, $19, $52, $1e, $32, $18, $12        ;; 04:56cf ........
    db   $18, $12, $1e, $32, $19, $52, $18, $12        ;; 04:56d7 ........
    db   $18, $12, $19, $52, $1e, $32, $18, $12        ;; 04:56df ........
    db   $65                                           ;; 04:56e7 .

data_04_56e8:
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:56e8 ........
    db   $a4, $14, $a4, $12, $9f, $16, $a4, $15        ;; 04:56f0 ........
    db   $a4, $12, $9f, $15, $a4, $14, $a4, $14        ;; 04:56f8 ........
    db   $a4, $12, $9f, $16, $65                       ;; 04:5700 .....

data_04_5705:
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5705 ........
    db   $a4, $14, $a4, $12, $9f, $16, $9f, $15        ;; 04:570d ........
    db   $9f, $12, $a6, $15, $9f, $14, $9f, $14        ;; 04:5715 ........
    db   $9f, $12, $a6, $16, $65                       ;; 04:571d .....

data_04_5722:
    db   $9f, $15, $9f, $12, $a6, $15, $9f, $14        ;; 04:5722 ........
    db   $9f, $14, $9f, $12, $a1, $14, $a3, $14        ;; 04:572a ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5732 ........
    db   $a4, $14, $a4, $12, $a3, $14, $a1, $14        ;; 04:573a ........
    db   $9f, $16, $a6, $15, $9f, $14, $9f, $14        ;; 04:5742 ........
    db   $9f, $12, $a1, $14, $a3, $14, $a4, $15        ;; 04:574a ........
    db   $a4, $12, $9f, $15, $a4, $14, $a4, $14        ;; 04:5752 ........
    db   $a4, $12, $a4, $12, $a3, $12, $a1, $14        ;; 04:575a ........
    db   $65                                           ;; 04:5762 .

data_04_5763:
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:5763 ........
    db   $9d, $14, $9d, $12, $a4, $14, $9d, $14        ;; 04:576b ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5773 ........
    db   $a4, $14, $a4, $12, $9f, $14, $a4, $14        ;; 04:577b ........
    db   $9f, $15, $9f, $12, $a6, $15, $9f, $14        ;; 04:5783 ........
    db   $9f, $14, $9f, $12, $a1, $14, $a3, $14        ;; 04:578b ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5793 ........
    db   $a4, $14, $a4, $12, $9f, $14, $a4, $14        ;; 04:579b ........
    db   $9d, $16, $a4, $15, $9d, $14, $9d, $14        ;; 04:57a3 ........
    db   $9d, $12, $a4, $14, $9d, $14, $a4, $15        ;; 04:57ab ........
    db   $a4, $12, $9f, $15, $a4, $14, $a4, $14        ;; 04:57b3 ........
    db   $a4, $12, $9f, $14, $a4, $14, $9f, $15        ;; 04:57bb ........
    db   $9f, $12, $a6, $15, $9f, $14, $9f, $14        ;; 04:57c3 ........
    db   $9f, $12, $a1, $14, $a3, $14, $a4, $14        ;; 04:57cb ........
    db   $a4, $14, $9d, $12, $9d, $14, $a4, $16        ;; 04:57d3 ........
    db   $a4, $12, $9f, $14, $a4, $14, $65             ;; 04:57db .......

data_04_57e2:
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:57e2 ........
    db   $9d, $14, $9d, $12, $a4, $14, $9d, $14        ;; 04:57ea ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:57f2 ........
    db   $a4, $14, $a4, $12, $9f, $14, $9f, $14        ;; 04:57fa ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5802 ........
    db   $a4, $14, $a4, $12, $9f, $14, $a4, $14        ;; 04:580a ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:5812 ........
    db   $9d, $14, $9d, $12, $a4, $14, $a4, $14        ;; 04:581a ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:5822 ........
    db   $9d, $14, $9d, $12, $a4, $14, $9d, $14        ;; 04:582a ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5832 ........
    db   $a4, $14, $a4, $12, $9f, $14, $9f, $14        ;; 04:583a ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5842 ........
    db   $a4, $14, $a4, $12, $9f, $14, $a4, $14        ;; 04:584a ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:5852 ........
    db   $9d, $14, $9d, $12, $9f, $14, $a1, $14        ;; 04:585a ........
    db   $65                                           ;; 04:5862 .

data_04_5863:
    db   $a2, $15, $a2, $12, $a9, $15, $a2, $14        ;; 04:5863 ........
    db   $a2, $14, $a2, $12, $a1, $14, $9f, $14        ;; 04:586b ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:5873 ........
    db   $9d, $14, $9d, $12, $a1, $14, $9d, $14        ;; 04:587b ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:5883 ........
    db   $a4, $14, $a4, $12, $9f, $14, $a4, $14        ;; 04:588b ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:5893 ........
    db   $9d, $14, $9d, $12, $9f, $14, $a1, $14        ;; 04:589b ........
    db   $a2, $15, $a2, $12, $a9, $15, $a2, $14        ;; 04:58a3 ........
    db   $a2, $14, $a2, $12, $a1, $14, $9f, $14        ;; 04:58ab ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:58b3 ........
    db   $9d, $14, $9d, $12, $a4, $14, $9d, $14        ;; 04:58bb ........
    db   $a4, $15, $a4, $12, $9f, $15, $a4, $14        ;; 04:58c3 ........
    db   $a4, $14, $a4, $12, $9f, $14, $a4, $14        ;; 04:58cb ........
    db   $9d, $15, $9d, $12, $a4, $15, $9d, $14        ;; 04:58d3 ........
    db   $9d, $14, $9d, $12, $a4, $14, $9d, $14        ;; 04:58db ????????
    db   $9f, $15, $9f, $12, $a6, $15, $9f, $14        ;; 04:58e3 ????????
    db   $9f, $14, $9f, $12, $9f, $14, $a6, $14        ;; 04:58eb ????????
    db   $65                                           ;; 04:58f3 ?

data_04_58f4:
    db   $24, $04, $43, $82, $43, $82, $43, $82        ;; 04:58f4 ........
    db   $45, $84, $43, $82, $24, $08, $24, $04        ;; 04:58fc ........
    db   $43, $82, $43, $82, $43, $82, $45, $84        ;; 04:5904 ........
    db   $43, $82, $24, $08, $24, $04, $41, $82        ;; 04:590c ........
    db   $41, $82, $41, $82, $43, $84, $41, $82        ;; 04:5914 ........
    db   $24, $08, $24, $04, $3e, $82, $3e, $82        ;; 04:591c ........
    db   $3e, $82, $40, $84, $3e, $82, $24, $06        ;; 04:5924 ........
    db   $24, $02, $43, $82, $43, $82, $44, $82        ;; 04:592c ........
    db   $65                                           ;; 04:5934 .

data_04_5935:
    db   $45, $84, $43, $84, $41, $82, $3e, $84        ;; 04:5935 ........
    db   $3b, $84, $37, $84, $37, $82, $39, $84        ;; 04:593d ........
    db   $3b, $84, $3c, $84, $3c, $82, $3c, $82        ;; 04:5945 ........
    db   $3c, $82, $3e, $84, $40, $84, $40, $84        ;; 04:594d ........
    db   $40, $82, $41, $84, $40, $84, $43, $84        ;; 04:5955 ........
    db   $43, $82, $43, $82, $43, $82, $41, $84        ;; 04:595d ........
    db   $40, $84, $3e, $84, $3e, $82, $3c, $84        ;; 04:5965 ........
    db   $3b, $84, $3c, $84, $3c, $82, $3c, $82        ;; 04:596d ........
    db   $3c, $82, $3e, $84, $3f, $84, $40, $84        ;; 04:5975 ........
    db   $43, $82, $43, $82, $43, $82, $43, $82        ;; 04:597d ........
    db   $44, $82, $45, $84, $43, $84, $41, $82        ;; 04:5985 ........
    db   $3e, $84, $3b, $84, $37, $84, $37, $82        ;; 04:598d ........
    db   $39, $84, $3b, $84, $3c, $84, $3c, $82        ;; 04:5995 ........
    db   $3c, $82, $3c, $82, $3e, $84, $40, $84        ;; 04:599d ........
    db   $40, $84, $40, $82, $41, $84, $43, $84        ;; 04:59a5 ........
    db   $41, $84, $41, $82, $41, $82, $41, $82        ;; 04:59ad ........
    db   $40, $84, $3e, $84, $3e, $84, $3e, $82        ;; 04:59b5 ........
    db   $3c, $84, $3b, $84, $3c, $84, $3c, $82        ;; 04:59bd ........
    db   $3c, $82, $3c, $82, $3e, $84, $3f, $84        ;; 04:59c5 ........
    db   $40, $84, $43, $82, $45, $84, $43, $84        ;; 04:59cd ........
    db   $65                                           ;; 04:59d5 .

data_04_59d6:
    db   $41, $84, $48, $82, $48, $82, $48, $84        ;; 04:59d6 ........
    db   $48, $82, $48, $84, $47, $84, $45, $82        ;; 04:59de ........
    db   $43, $84, $41, $84, $40, $84, $43, $82        ;; 04:59e6 ........
    db   $43, $82, $43, $82, $41, $84, $40, $84        ;; 04:59ee ........
    db   $40, $84, $40, $82, $3e, $84, $3c, $84        ;; 04:59f6 ........
    db   $3b, $84, $3b, $82, $3b, $82, $3b, $82        ;; 04:59fe ........
    db   $3c, $84, $3e, $84, $3e, $84, $3e, $82        ;; 04:5a06 ........
    db   $3c, $84, $3b, $84, $3c, $84, $3c, $82        ;; 04:5a0e ........
    db   $3c, $82, $3e, $82, $3f, $84, $40, $84        ;; 04:5a16 ........
    db   $43, $84, $43, $82, $45, $84, $43, $84        ;; 04:5a1e ........
    db   $41, $84, $48, $82, $48, $82, $48, $82        ;; 04:5a26 ........
    db   $48, $84, $47, $84, $45, $84, $43, $82        ;; 04:5a2e ........
    db   $41, $84, $40, $84, $3c, $84, $43, $82        ;; 04:5a36 ........
    db   $43, $82, $43, $82, $41, $84, $40, $84        ;; 04:5a3e ........
    db   $40, $84, $40, $82, $3e, $84, $3c, $84        ;; 04:5a46 ........
    db   $3b, $84, $3b, $82, $3b, $82, $3b, $82        ;; 04:5a4e ........
    db   $39, $84, $37, $84, $37, $84, $37, $82        ;; 04:5a56 ........
    db   $39, $84, $3b, $84, $3c, $84, $3c, $84        ;; 04:5a5e ........
    db   $3c, $82, $3c, $84, $3c, $88, $24, $02        ;; 04:5a66 ........
    db   $65                                           ;; 04:5a6e .

data_04_5a6f:
    db   $48, $84, $48, $82, $48, $82, $48, $82        ;; 04:5a6f ........
    db   $46, $84, $45, $84, $45, $84, $45, $82        ;; 04:5a77 ........
    db   $43, $84, $41, $84, $43, $82, $45, $82        ;; 04:5a7f ........
    db   $43, $82, $41, $82, $40, $82, $3e, $84        ;; 04:5a87 ........
    db   $3c, $84, $48, $82, $4a, $82, $4c, $82        ;; 04:5a8f ........
    db   $4a, $84, $48, $84, $46, $84, $46, $82        ;; 04:5a97 ........
    db   $46, $82, $46, $82, $45, $84, $43, $84        ;; 04:5a9f ........
    db   $43, $84, $43, $82, $41, $84, $40, $84        ;; 04:5aa7 ........
    db   $41, $84, $41, $82, $43, $82, $45, $82        ;; 04:5aaf ........
    db   $41, $84, $3c, $84, $48, $82, $4d, $82        ;; 04:5ab7 ........
    db   $4f, $82, $51, $84, $4d, $84, $48, $84        ;; 04:5abf ........
    db   $48, $82, $48, $82, $48, $82, $46, $84        ;; 04:5ac7 ........
    db   $45, $84, $45, $84, $45, $82, $43, $84        ;; 04:5acf ........
    db   $41, $84, $43, $82, $45, $82, $43, $82        ;; 04:5ad7 ........
    db   $41, $82, $40, $82, $3e, $84, $3c, $84        ;; 04:5adf ........
    db   $48, $82, $4a, $82, $4c, $82, $4a, $84        ;; 04:5ae7 ........
    db   $48, $84, $46, $84, $45, $82, $43, $84        ;; 04:5aef ........
    db   $41, $84, $40, $84, $40, $84, $40, $82        ;; 04:5af7 ........
    db   $41, $84, $43, $84, $41, $84, $41, $82        ;; 04:5aff ........
    db   $43, $82, $45, $82, $43, $84, $41, $84        ;; 04:5b07 ........
    db   $41, $84, $41, $82, $43, $84, $45, $84        ;; 04:5b0f ........
    db   $65                                           ;; 04:5b17 .

data_04_5b18:
    db   $46, $84, $3e, $84, $41, $84, $46, $82        ;; 04:5b18 ........
    db   $3e, $84, $3e, $84, $41, $82, $46, $84        ;; 04:5b20 ........
    db   $41, $84, $45, $84, $3c, $84, $41, $84        ;; 04:5b28 ........
    db   $45, $82, $3c, $84, $3c, $84, $41, $82        ;; 04:5b30 ........
    db   $45, $84, $41, $84, $43, $84, $3c, $84        ;; 04:5b38 ........
    db   $40, $84, $43, $82, $3c, $84, $3c, $84        ;; 04:5b40 ........
    db   $3c, $82, $40, $84, $43, $84, $41, $84        ;; 04:5b48 ........
    db   $40, $84, $41, $84, $43, $82, $45, $84        ;; 04:5b50 ........
    db   $3c, $84, $3c, $82, $41, $84, $45, $84        ;; 04:5b58 ........
    db   $46, $84, $3e, $84, $41, $84, $46, $82        ;; 04:5b60 ........
    db   $3e, $84, $3e, $84, $41, $82, $46, $84        ;; 04:5b68 ........
    db   $41, $84, $45, $84, $3c, $84, $41, $84        ;; 04:5b70 ........
    db   $45, $82, $3c, $84, $3c, $84, $41, $82        ;; 04:5b78 ........
    db   $45, $84, $41, $84, $43, $84, $3c, $84        ;; 04:5b80 ........
    db   $40, $84, $43, $82, $3c, $84, $3c, $84        ;; 04:5b88 ........
    db   $40, $82, $43, $84, $40, $84, $41, $84        ;; 04:5b90 ........
    db   $39, $84, $3c, $82, $41, $84, $41, $84        ;; 04:5b98 ........
    db   $41, $84, $39, $82, $3c, $84, $41, $84        ;; 04:5ba0 ????????
    db   $43, $84, $3b, $84, $3e, $84, $43, $82        ;; 04:5ba8 ????????
    db   $43, $84, $43, $84, $43, $82, $43, $84        ;; 04:5bb0 ????????
    db   $43, $82, $44, $82, $65                       ;; 04:5bb8 ?????

data_04_5bbd:
    db   $67, $ff, $69, $ca, $64, $23, $e1, $04        ;; 04:5bbd ........
    db   $64, $24, $e1, $01, $69, $ab, $64, $25        ;; 04:5bc5 ........
    db   $e1, $02, $64, $26, $e1, $01, $64, $25        ;; 04:5bcd ........
    db   $e1, $01, $64, $25, $e3, $01, $64, $26        ;; 04:5bd5 ........
    db   $e3, $01, $64, $25, $e3, $01, $64, $00        ;; 04:5bdd ........
    db   $00, $02, $64, $27, $e1, $02, $64, $28        ;; 04:5be5 ........
    db   $e1, $01, $64, $27, $e1, $01, $64, $24        ;; 04:5bed ........
    db   $e1, $01, $64, $29, $e1, $01, $64, $30        ;; 04:5bf5 ........
    db   $e1, $01, $64, $2a, $e1, $02, $66, $01        ;; 04:5bfd ........
    db   $62                                           ;; 04:5c05 .
    dw   data_04_5bbd                                  ;; 04:5c06 pP

data_04_5c08:
    db   $64, $23, $dc, $04, $64, $20, $e1, $01        ;; 04:5c08 ........
    db   $64, $21, $e1, $02, $64, $22, $e1, $01        ;; 04:5c10 ........
    db   $64, $21, $e1, $01, $64, $21, $e3, $01        ;; 04:5c18 ........
    db   $64, $22, $e3, $01, $64, $21, $e3, $01        ;; 04:5c20 ........
    db   $64, $2b, $05, $03, $64, $2c, $05, $01        ;; 04:5c28 ........
    db   $64, $2b, $05, $01, $64, $2c, $05, $01        ;; 04:5c30 ........
    db   $64, $2b, $05, $01, $64, $2c, $05, $01        ;; 04:5c38 ........
    db   $64, $2b, $05, $01, $64, $2c, $05, $01        ;; 04:5c40 ........
    db   $64, $2d, $0a, $01, $64, $2d, $05, $01        ;; 04:5c48 ........
    db   $64, $2d, $00, $01, $64, $2d, $05, $01        ;; 04:5c50 ........
    db   $64, $2d, $0a, $01, $64, $2d, $05, $01        ;; 04:5c58 ........
    db   $64, $2d, $00, $01, $64, $2d, $05, $01        ;; 04:5c60 ........
    db   $64, $2b, $05, $01, $64, $2c, $05, $01        ;; 04:5c68 ........
    db   $64, $2b, $05, $01, $64, $2c, $05, $01        ;; 04:5c70 ........
    db   $64, $20, $e1, $01, $64, $2e, $05, $01        ;; 04:5c78 ........
    db   $64, $2f, $05, $02, $62                       ;; 04:5c80 .....
    dw   data_04_5c08                                  ;; 04:5c85 pP

data_04_5c87:
    db   $64, $17, $ed, $01, $64, $18, $ed, $01        ;; 04:5c87 ........
    db   $64, $19, $ed, $02, $64, $1a, $ed, $01        ;; 04:5c8f ........
    db   $64, $19, $ed, $01, $64, $19, $ef, $01        ;; 04:5c97 ........
    db   $64, $1a, $ef, $01, $64, $19, $ef, $01        ;; 04:5c9f ........
    db   $64, $1b, $ed, $03, $64, $1c, $ed, $01        ;; 04:5ca7 ........
    db   $64, $1b, $ed, $01, $64, $1c, $ed, $01        ;; 04:5caf ........
    db   $64, $1b, $ed, $01, $64, $1c, $ed, $01        ;; 04:5cb7 ........
    db   $64, $1b, $ed, $01, $64, $1c, $ed, $01        ;; 04:5cbf ........
    db   $64, $1d, $f2, $01, $64, $1d, $ed, $01        ;; 04:5cc7 ........
    db   $64, $1d, $e8, $01, $64, $1d, $ed, $01        ;; 04:5ccf ........
    db   $64, $1d, $f2, $01, $64, $1d, $ed, $01        ;; 04:5cd7 ........
    db   $64, $1d, $e8, $01, $64, $1d, $ed, $01        ;; 04:5cdf ........
    db   $64, $1b, $ed, $01, $64, $1c, $ed, $01        ;; 04:5ce7 ........
    db   $64, $1b, $ed, $01, $64, $1c, $ed, $01        ;; 04:5cef ........
    db   $64, $18, $ed, $01, $64, $1e, $ed, $01        ;; 04:5cf7 ........
    db   $64, $1f, $ed, $02, $62                       ;; 04:5cff .....
    dw   data_04_5c87                                  ;; 04:5d04 pP

data_04_5d06:
    db   $64, $00, $00, $06, $64, $16, $00, $11        ;; 04:5d06 ........
    db   $62                                           ;; 04:5d0e .
    dw   data_04_5d06                                  ;; 04:5d0f pP

data_04_5d11:
    db   $24, $04, $a1, $36, $a1, $36, $9a, $76        ;; 04:5d11 ........
    db   $9a, $76, $9f, $36, $9f, $36, $98, $58        ;; 04:5d19 ........
    db   $a1, $36, $a1, $36, $9a, $76, $9a, $76        ;; 04:5d21 ........
    db   $9f, $36, $9f, $36, $98, $56, $98, $54        ;; 04:5d29 ........
    db   $65                                           ;; 04:5d31 .

data_04_5d32:
    db   $24, $04, $a4, $36, $a4, $36, $a4, $36        ;; 04:5d32 ........
    db   $a4, $34, $24, $04, $9d, $56, $9d, $56        ;; 04:5d3a ........
    db   $a4, $36, $a4, $34, $24, $04, $a4, $36        ;; 04:5d42 ........
    db   $a4, $36, $a4, $36, $a4, $34, $24, $04        ;; 04:5d4a ........
    db   $9a, $56, $9a, $56, $9f, $46, $9f, $44        ;; 04:5d52 ........
    db   $24, $04, $a4, $36, $a4, $36, $a4, $36        ;; 04:5d5a ........
    db   $a4, $34, $24, $04, $9d, $46, $9d, $46        ;; 04:5d62 ........
    db   $a8, $36, $a8, $34, $24, $04, $9d, $46        ;; 04:5d6a ........
    db   $9d, $46, $a4, $36, $a1, $34, $24, $04        ;; 04:5d72 ........
    db   $9a, $86, $9f, $46, $98, $56, $98, $54        ;; 04:5d7a ........
    db   $65                                           ;; 04:5d82 .

data_04_5d83:
    db   $24, $04, $9f, $36, $9f, $36, $9f, $36        ;; 04:5d83 ........
    db   $9e, $34, $65                                 ;; 04:5d8b ...

data_04_5d8e:
    db   $24, $04, $9f, $36, $9f, $36, $9a, $36        ;; 04:5d8e ........
    db   $9a, $34, $65                                 ;; 04:5d96 ...

data_04_5d99:
    db   $24, $04, $9f, $36, $9f, $36, $9f, $36        ;; 04:5d99 ........
    db   $9f, $34, $65                                 ;; 04:5da1 ...

data_04_5da4:
    db   $43, $b4, $4f, $b4, $4e, $b4, $4c, $b4        ;; 04:5da4 ........
    db   $4a, $b4, $48, $b4, $47, $b4, $45, $b4        ;; 04:5dac ........
    db   $65                                           ;; 04:5db4 .

data_04_5db5:
    db   $43, $b6, $43, $b4, $43, $b4, $43, $b6        ;; 04:5db5 ........
    db   $43, $b6, $43, $b8, $41, $b8, $65             ;; 04:5dbd .......

data_04_5dc4:
    db   $40, $84, $40, $84, $43, $84, $43, $84        ;; 04:5dc4 ........
    db   $41, $84, $41, $84, $45, $86, $47, $84        ;; 04:5dcc ........
    db   $45, $84, $43, $84, $41, $84, $40, $84        ;; 04:5dd4 ........
    db   $3e, $84, $3c, $86, $40, $84, $40, $84        ;; 04:5ddc ........
    db   $43, $84, $40, $84, $41, $84, $41, $84        ;; 04:5de4 ........
    db   $45, $86, $47, $85, $45, $82, $43, $84        ;; 04:5dec ........
    db   $41, $84, $40, $84, $3e, $84, $3c, $86        ;; 04:5df4 ........
    db   $65                                           ;; 04:5dfc .

data_04_5dfd:
    db   $45, $84, $45, $84, $48, $82, $47, $82        ;; 04:5dfd ........
    db   $45, $84, $43, $84, $43, $84, $46, $82        ;; 04:5e05 ........
    db   $45, $82, $43, $84, $41, $84, $41, $84        ;; 04:5e0d ........
    db   $45, $82, $43, $82, $41, $84, $40, $84        ;; 04:5e15 ........
    db   $41, $84, $43, $86, $41, $84, $40, $82        ;; 04:5e1d ........
    db   $3e, $82, $3c, $84, $3b, $84, $3c, $84        ;; 04:5e25 ........
    db   $3e, $84, $40, $86, $42, $85, $43, $82        ;; 04:5e2d ........
    db   $45, $84, $42, $84, $43, $84, $41, $84        ;; 04:5e35 ........
    db   $40, $84, $3e, $84, $65                       ;; 04:5e3d .....

data_04_5e42:
    db   $47, $92, $45, $92, $43, $94, $3e, $94        ;; 04:5e42 ........
    db   $3e, $94, $47, $92, $45, $92, $43, $94        ;; 04:5e4a ........
    db   $3e, $94, $3e, $94, $47, $92, $45, $92        ;; 04:5e52 ........
    db   $43, $94, $47, $92, $45, $92, $43, $94        ;; 04:5e5a ........
    db   $45, $94, $42, $94, $3e, $96, $47, $92        ;; 04:5e62 ........
    db   $45, $92, $43, $94, $3e, $94, $3e, $94        ;; 04:5e6a ........
    db   $43, $92, $45, $92, $47, $92, $48, $92        ;; 04:5e72 ........
    db   $4a, $96, $4a, $92, $48, $92, $47, $92        ;; 04:5e7a ........
    db   $48, $92, $4a, $94, $48, $92, $47, $92        ;; 04:5e82 ........
    db   $48, $94, $45, $94, $42, $94, $3e, $94        ;; 04:5e8a ........
    db   $65                                           ;; 04:5e92 .

data_04_5e93:
    db   $54, $95, $53, $92, $51, $94, $4f, $94        ;; 04:5e93 ........
    db   $4c, $94, $4a, $94, $48, $96, $53, $95        ;; 04:5e9b ........
    db   $51, $92, $4f, $94, $4a, $94, $47, $94        ;; 04:5ea3 ........
    db   $45, $94, $43, $96, $3e, $92, $40, $92        ;; 04:5eab ........
    db   $42, $92, $43, $92, $45, $94, $45, $94        ;; 04:5eb3 ........
    db   $3e, $92, $40, $92, $42, $92, $43, $92        ;; 04:5ebb ........
    db   $45, $94, $45, $94, $47, $92, $45, $92        ;; 04:5ec3 ........
    db   $43, $92, $45, $92, $47, $94, $48, $94        ;; 04:5ecb ........
    db   $4a, $94, $47, $94, $4f, $96, $54, $95        ;; 04:5ed3 ........
    db   $53, $92, $51, $94, $4f, $94, $4c, $94        ;; 04:5edb ........
    db   $4a, $94, $48, $96, $53, $95, $51, $92        ;; 04:5ee3 ........
    db   $4f, $94, $4a, $94, $47, $94, $45, $94        ;; 04:5eeb ........
    db   $43, $96, $3e, $92, $40, $92, $42, $92        ;; 04:5ef3 ........
    db   $43, $92, $45, $94, $45, $94, $45, $92        ;; 04:5efb ........
    db   $47, $92, $48, $94, $4a, $94, $48, $94        ;; 04:5f03 ........
    db   $47, $94, $45, $94, $43, $94, $45, $94        ;; 04:5f0b ........
    db   $47, $94, $4a, $94, $4f, $96, $65             ;; 04:5f13 .......

data_04_5f1a:
    db   $4f, $92, $4d, $92, $4c, $92, $4a, $92        ;; 04:5f1a ........
    db   $48, $94, $4c, $94, $43, $94, $43, $94        ;; 04:5f22 ........
    db   $43, $96, $45, $92, $41, $92, $45, $92        ;; 04:5f2a ........
    db   $48, $92, $4d, $94, $4d, $94, $4c, $95        ;; 04:5f32 ........
    db   $4a, $92, $48, $96, $4f, $92, $4d, $92        ;; 04:5f3a ........
    db   $4c, $92, $4a, $92, $48, $94, $4c, $94        ;; 04:5f42 ........
    db   $43, $94, $43, $94, $43, $96, $45, $92        ;; 04:5f4a ........
    db   $43, $92, $42, $92, $43, $92, $45, $94        ;; 04:5f52 ........
    db   $48, $94, $47, $94, $45, $94, $43, $96        ;; 04:5f5a ........
    db   $65                                           ;; 04:5f62 .

data_04_5f63:
    db   $4f, $92, $4d, $92, $4c, $92, $4a, $92        ;; 04:5f63 ........
    db   $48, $94, $4c, $94, $43, $94, $43, $94        ;; 04:5f6b ........
    db   $43, $96, $45, $92, $41, $92, $45, $92        ;; 04:5f73 ........
    db   $48, $92, $4d, $94, $4d, $94, $4c, $98        ;; 04:5f7b ........
    db   $4a, $95, $48, $92, $47, $94, $45, $94        ;; 04:5f83 ........
    db   $43, $94, $41, $94, $40, $96, $41, $95        ;; 04:5f8b ........
    db   $40, $92, $3e, $94, $3b, $94, $3c, $98        ;; 04:5f93 ........
    db   $65                                           ;; 04:5f9b .

data_04_5f9c:
    db   $39, $95, $3d, $92, $40, $94, $43, $94        ;; 04:5f9c ........
    db   $41, $94, $40, $94, $3e, $94, $3c, $94        ;; 04:5fa4 ........
    db   $3b, $95, $39, $92, $37, $92, $3b, $92        ;; 04:5fac ........
    db   $3e, $92, $41, $92, $40, $94, $3e, $94        ;; 04:5fb4 ........
    db   $3c, $96, $39, $95, $3d, $92, $40, $94        ;; 04:5fbc ........
    db   $43, $94, $41, $94, $40, $94, $3e, $94        ;; 04:5fc4 ........
    db   $3c, $94, $3b, $95, $39, $92, $37, $94        ;; 04:5fcc ........
    db   $35, $94, $34, $94, $32, $94, $30, $96        ;; 04:5fd4 ........
    db   $65                                           ;; 04:5fdc .

data_04_5fdd:
    db   $3b, $b6, $3b, $b4, $3b, $b4, $3b, $b6        ;; 04:5fdd ........
    db   $3b, $b6, $3b, $ba, $65                       ;; 04:5fe5 .....

data_04_5fea:
    db   $3c, $84, $3c, $84, $40, $84, $40, $84        ;; 04:5fea ........
    db   $3c, $84, $3c, $84, $42, $86, $3e, $84        ;; 04:5ff2 ........
    db   $3c, $84, $3b, $84, $39, $84, $37, $84        ;; 04:5ffa ........
    db   $35, $84, $34, $86, $3c, $84, $3c, $84        ;; 04:6002 ........
    db   $40, $84, $3c, $84, $3c, $84, $3c, $84        ;; 04:600a ........
    db   $42, $86, $3e, $85, $3c, $82, $3b, $84        ;; 04:6012 ........
    db   $39, $84, $37, $84, $35, $84, $34, $86        ;; 04:601a ........
    db   $65                                           ;; 04:6022 .

data_04_6023:
    db   $41, $84, $41, $84, $42, $86, $40, $84        ;; 04:6023 ........
    db   $40, $84, $3d, $86, $3e, $84, $3e, $84        ;; 04:602b ........
    db   $3b, $86, $3c, $84, $3e, $84, $40, $86        ;; 04:6033 ........
    db   $39, $86, $39, $84, $38, $84, $39, $84        ;; 04:603b ........
    db   $3b, $84, $3c, $86, $3e, $85, $40, $82        ;; 04:6043 ........
    db   $42, $84, $3e, $84, $3b, $84, $39, $84        ;; 04:604b ........
    db   $37, $84, $35, $84, $65                       ;; 04:6053 .....

data_04_6058:
    db   $ab, $28, $aa, $28, $a8, $28, $a6, $28        ;; 04:6058 ........
    db   $a4, $28, $a3, $28, $a1, $28, $9f, $28        ;; 04:6060 ........
    db   $65                                           ;; 04:6068 .

data_04_6069:
    db   $9f, $26, $9f, $24, $9f, $24, $9f, $26        ;; 04:6069 ........
    db   $9f, $26, $9f, $2a, $65                       ;; 04:6071 .....

data_04_6076:
    db   $a4, $16, $a8, $16, $a9, $16, $aa, $16        ;; 04:6076 ........
    db   $ab, $16, $9f, $16, $a4, $16, $9f, $16        ;; 04:607e ........
    db   $a4, $16, $a8, $16, $a9, $16, $aa, $16        ;; 04:6086 ........
    db   $ab, $16, $9f, $16, $a4, $16, $a4, $16        ;; 04:608e ........
    db   $65                                           ;; 04:6096 .

data_04_6097:
    db   $a9, $16, $aa, $16, $ab, $16, $ad, $16        ;; 04:6097 ........
    db   $a6, $16, $ab, $16, $a4, $16, $a4, $16        ;; 04:609f ........
    db   $a6, $16, $a8, $16, $ad, $16, $ad, $16        ;; 04:60a7 ........
    db   $a6, $16, $a6, $16, $ab, $14, $a9, $14        ;; 04:60af ........
    db   $a8, $14, $a6, $14, $65                       ;; 04:60b7 .....

data_04_60bc:
    db   $ab, $16, $a6, $16, $ab, $16, $a6, $16        ;; 04:60bc ........
    db   $65                                           ;; 04:60c4 .

data_04_60c5:
    db   $ab, $16, $a6, $16, $ad, $16, $a6, $16        ;; 04:60c5 ........
    db   $65                                           ;; 04:60cd .

data_04_60ce:
    db   $ab, $16, $a6, $16, $ab, $16, $a6, $16        ;; 04:60ce ........
    db   $65                                           ;; 04:60d6 .

data_04_60d7:
    db   $a4, $16, $9f, $16, $a4, $16, $a4, $16        ;; 04:60d7 ........
    db   $a9, $16, $a9, $16, $a4, $16, $9f, $16        ;; 04:60df ........
    db   $a4, $16, $9f, $16, $a4, $16, $9f, $16        ;; 04:60e7 ........
    db   $a6, $16, $a1, $16, $ab, $16, $a6, $16        ;; 04:60ef ........
    db   $a4, $16, $9f, $16, $a4, $16, $a8, $16        ;; 04:60f7 ........
    db   $a9, $16, $a9, $16, $a8, $16, $a8, $16        ;; 04:60ff ........
    db   $a9, $16, $a9, $16, $a4, $16, $a1, $16        ;; 04:6107 ........
    db   $a6, $16, $ab, $16, $a4, $16, $9f, $16        ;; 04:610f ........
    db   $65                                           ;; 04:6117 .

data_04_6118:
    db   $a1, $16, $a8, $16, $a6, $16, $a6, $16        ;; 04:6118 ........
    db   $9f, $16, $a6, $16, $a4, $16, $9f, $14        ;; 04:6120 ........
    db   $a3, $14, $a1, $16, $a1, $16, $a6, $16        ;; 04:6128 ........
    db   $a6, $16, $9f, $16, $9f, $16, $a4, $16        ;; 04:6130 ........
    db   $9f, $16, $65                                 ;; 04:6138 ...

data_04_613b:
    db   $18, $12, $1e, $32, $1e, $32, $18, $12        ;; 04:613b ........
    db   $1a, $24, $1e, $34, $18, $12, $1e, $32        ;; 04:6143 ........
    db   $18, $12, $1e, $32, $1a, $24, $22, $64        ;; 04:614b ........
    db   $18, $12, $1e, $32, $1e, $32, $18, $12        ;; 04:6153 ........
    db   $1a, $24, $1e, $34, $18, $12, $1e, $32        ;; 04:615b ........
    db   $18, $12, $1e, $32, $1a, $22, $1e, $32        ;; 04:6163 ........
    db   $18, $12, $1e, $32, $18, $12, $1e, $32        ;; 04:616b ........
    db   $1e, $32, $18, $12, $1a, $24, $18, $12        ;; 04:6173 ........
    db   $1e, $32, $18, $14, $1e, $32, $1e, $32        ;; 04:617b ........
    db   $1a, $24, $1e, $32, $1e, $32, $18, $12        ;; 04:6183 ........
    db   $1e, $32, $1e, $32, $18, $12, $1a, $22        ;; 04:618b ........
    db   $1e, $32, $18, $12, $1e, $32, $18, $14        ;; 04:6193 ........
    db   $1e, $32, $1e, $32, $1a, $24, $22, $64        ;; 04:619b ........
    db   $65, $67, $ff, $69, $a4, $64, $00, $00        ;; 04:61a3 .???????
    db   $04, $64, $3d, $e3, $02, $64, $3e, $e3        ;; 04:61ab ????????
    db   $01, $64, $3d, $e3, $01, $64, $3d, $e5        ;; 04:61b3 ????????
    db   $01, $64, $3e, $e5, $01, $64, $3f, $ef        ;; 04:61bb ????????
    db   $01, $64, $40, $e3, $01, $64, $41, $e3        ;; 04:61c3 ????????
    db   $01, $64, $3e, $e3, $01, $64, $42, $e3        ;; 04:61cb ????????
    db   $01, $66, $01, $62, $a4, $61, $64, $43        ;; 04:61d3 ????????
    db   $fb, $03, $64, $44, $fb, $02, $64, $45        ;; 04:61db ????????
    db   $fb, $01, $64, $46, $fb, $01, $64, $45        ;; 04:61e3 ????????
    db   $fb, $01, $64, $47, $fb, $01, $64, $45        ;; 04:61eb ????????
    db   $fb, $02, $64, $43, $fb, $01, $64, $43        ;; 04:61f3 ????????
    db   $fd, $01, $64, $44, $fd, $02, $64, $45        ;; 04:61fb ????????
    db   $fd, $01, $64, $46, $fd, $01, $64, $45        ;; 04:6203 ????????
    db   $fd, $01, $64, $47, $fd, $01, $64, $45        ;; 04:620b ????????
    db   $fd, $02, $64, $48, $07, $02, $64, $49        ;; 04:6213 ????????
    db   $fb, $02, $64, $4a, $fb, $03, $64, $44        ;; 04:621b ????????
    db   $fb, $02, $64, $45, $fb, $01, $64, $46        ;; 04:6223 ????????
    db   $fb, $01, $64, $45, $fb, $01, $64, $47        ;; 04:622b ????????
    db   $fb, $01, $64, $45, $fb, $02, $64, $4b        ;; 04:6233 ????????
    db   $fb, $02, $62, $d9, $61, $64, $37, $ef        ;; 04:623b ????????
    db   $03, $64, $38, $ef, $01, $64, $37, $ef        ;; 04:6243 ????????
    db   $01, $64, $37, $f1, $01, $64, $38, $f1        ;; 04:624b ????????
    db   $01, $64, $39, $ef, $02, $64, $3a, $ef        ;; 04:6253 ????????
    db   $02, $64, $3b, $ef, $03, $64, $38, $ef        ;; 04:625b ????????
    db   $01, $64, $3c, $ef, $02, $62, $40, $62        ;; 04:6263 ????????
    db   $64, $36, $00, $26, $62, $6b, $62, $a1        ;; 04:626b ????????
    db   $85, $a1, $84, $a1, $82, $a1, $85, $a1        ;; 04:6273 ????????
    db   $82, $a1, $84, $a1, $84, $a1, $84, $9f        ;; 04:627b ????????
    db   $55, $9f, $54, $9f, $52, $9f, $55, $9f        ;; 04:6283 ????????
    db   $52, $9f, $54, $9f, $54, $9f, $54, $9d        ;; 04:628b ????????
    db   $55, $9d, $54, $9d, $52, $9d, $55, $9d        ;; 04:6293 ????????
    db   $52, $9d, $54, $9d, $54, $9d, $54, $a8        ;; 04:629b ????????
    db   $65, $a8, $64, $a8, $62, $a8, $65, $a8        ;; 04:62a3 ????????
    db   $62, $a8, $64, $a8, $64, $a8, $64, $65        ;; 04:62ab ????????
    db   $a1, $84, $a1, $82, $a1, $84, $a1, $82        ;; 04:62b3 ????????
    db   $a1, $85, $a1, $82, $a1, $84, $a1, $84        ;; 04:62bb ????????
    db   $a1, $84, $a4, $44, $a4, $42, $a4, $44        ;; 04:62c3 ????????
    db   $a4, $42, $a4, $45, $a4, $42, $a4, $44        ;; 04:62cb ????????
    db   $a4, $44, $a4, $44, $65, $a8, $64, $a8        ;; 04:62d3 ????????
    db   $62, $a8, $64, $a8, $62, $a8, $65, $a8        ;; 04:62db ????????
    db   $62, $a8, $64, $a8, $64, $a8, $64, $65        ;; 04:62e3 ????????
    db   $a9, $34, $a9, $32, $a9, $34, $a9, $32        ;; 04:62eb ????????
    db   $a9, $35, $a9, $32, $a9, $34, $a9, $34        ;; 04:62f3 ????????
    db   $a9, $34, $65, $a1, $84, $a1, $82, $a1        ;; 04:62fb ????????
    db   $84, $a1, $82, $a1, $85, $a1, $82, $a1        ;; 04:6303 ????????
    db   $84, $a1, $84, $a1, $84, $65, $9a, $45        ;; 04:630b ????????
    db   $9a, $44, $9a, $42, $9a, $45, $9a, $42        ;; 04:6313 ????????
    db   $9a, $42, $9a, $42, $9a, $44, $9a, $44        ;; 04:631b ????????
    db   $9e, $65, $9e, $64, $9e, $62, $9e, $65        ;; 04:6323 ????????
    db   $9e, $62, $9e, $62, $9e, $62, $9e, $64        ;; 04:632b ????????
    db   $9e, $64, $99, $75, $99, $74, $99, $72        ;; 04:6333 ????????
    db   $99, $75, $99, $72, $99, $72, $99, $72        ;; 04:633b ????????
    db   $99, $74, $99, $74, $9e, $65, $9e, $64        ;; 04:6343 ????????
    db   $9e, $62, $9e, $65, $9e, $62, $9e, $62        ;; 04:634b ????????
    db   $9e, $62, $9e, $64, $9e, $64, $65, $a3        ;; 04:6353 ????????
    db   $85, $a3, $84, $a3, $82, $a3, $85, $a3        ;; 04:635b ????????
    db   $82, $a3, $82, $a3, $b2, $a3, $84, $a3        ;; 04:6363 ????????
    db   $84, $a8, $35, $a8, $34, $a8, $32, $a8        ;; 04:636b ????????
    db   $35, $a8, $32, $a8, $32, $a8, $32, $a8        ;; 04:6373 ????????
    db   $34, $a8, $34, $65, $a1, $85, $a1, $84        ;; 04:637b ????????
    db   $a1, $82, $a1, $85, $a1, $82, $a1, $82        ;; 04:6383 ????????
    db   $a1, $b2, $a1, $84, $a1, $84, $a8, $65        ;; 04:638b ????????
    db   $a8, $64, $a8, $62, $a8, $65, $a8, $62        ;; 04:6393 ????????
    db   $a8, $62, $a8, $62, $a8, $64, $a8, $64        ;; 04:639b ????????
    db   $a6, $35, $a6, $34, $a6, $32, $a6, $35        ;; 04:63a3 ????????
    db   $a6, $32, $a6, $32, $a6, $32, $a6, $34        ;; 04:63ab ????????
    db   $a6, $34, $a8, $35, $a8, $34, $a8, $32        ;; 04:63b3 ????????
    db   $a8, $35, $a8, $32, $a8, $32, $a8, $32        ;; 04:63bb ????????
    db   $a8, $34, $a8, $34, $65, $a1, $85, $a1        ;; 04:63c3 ????????
    db   $84, $a1, $82, $a1, $85, $a1, $82, $a1        ;; 04:63cb ????????
    db   $84, $a1, $84, $a1, $84, $65, $51, $f2        ;; 04:63d3 ????????
    db   $4c, $f2, $51, $f2, $4c, $f2, $51, $f8        ;; 04:63db ????????
    db   $54, $f6, $53, $f5, $51, $f2, $4f, $f9        ;; 04:63e3 ????????
    db   $51, $f2, $4d, $f2, $51, $f2, $4d, $f2        ;; 04:63eb ????????
    db   $51, $f8, $54, $f6, $53, $f5, $51, $f2        ;; 04:63f3 ????????
    db   $4f, $f8, $4c, $f6, $65, $45, $f6, $4c        ;; 04:63fb ????????
    db   $f8, $48, $f6, $4f, $f9, $40, $f6, $45        ;; 04:6403 ????????
    db   $f5, $4c, $f8, $24, $02, $48, $f6, $4f        ;; 04:640b ????????
    db   $f5, $4d, $f2, $4c, $f7, $4c, $f6, $4f        ;; 04:6413 ????????
    db   $f4, $53, $f5, $51, $f2, $4f, $f7, $4c        ;; 04:641b ????????
    db   $f4, $4f, $f4, $53, $f4, $54, $f5, $53        ;; 04:6423 ????????
    db   $f2, $51, $f8, $53, $f4, $54, $f4, $53        ;; 04:642b ????????
    db   $f5, $51, $f2, $4f, $f7, $4c, $f4, $4f        ;; 04:6433 ????????
    db   $f4, $53, $f4, $51, $f9, $4f, $f6, $4c        ;; 04:643b ????????
    db   $fa, $4f, $f6, $4c, $f6, $47, $f6, $43        ;; 04:6443 ????????
    db   $f6, $65, $4e, $f2, $47, $f2, $4e, $f2        ;; 04:644b ????????
    db   $47, $f2, $4e, $f8, $4c, $f4, $4a, $f4        ;; 04:6453 ????????
    db   $49, $f7, $47, $f4, $45, $f8, $44, $f2        ;; 04:645b ????????
    db   $40, $f2, $44, $f2, $40, $f2, $44, $f8        ;; 04:6463 ????????
    db   $45, $f4, $47, $f4, $45, $f4, $42, $f4        ;; 04:646b ????????
    db   $45, $f4, $49, $f4, $4e, $f4, $49, $f4        ;; 04:6473 ????????
    db   $4e, $f4, $51, $f4, $53, $f8, $51, $f6        ;; 04:647b ????????
    db   $50, $f6, $51, $f2, $50, $f2, $4e, $f8        ;; 04:6483 ????????
    db   $24, $04, $50, $f4, $51, $f4, $50, $f4        ;; 04:648b ????????
    db   $4e, $f4, $4c, $f6, $49, $f6, $4c, $f6        ;; 04:6493 ????????
    db   $4e, $f4, $49, $f4, $4e, $f2, $49, $f2        ;; 04:649b ????????
    db   $4e, $f2, $49, $f2, $4e, $f8, $65, $56        ;; 04:64a3 ????????
    db   $f2, $53, $f2, $56, $f2, $53, $f2, $56        ;; 04:64ab ????????
    db   $f7, $53, $f4, $56, $f4, $53, $f4, $58        ;; 04:64b3 ????????
    db   $f4, $53, $f4, $50, $f4, $4c, $f6, $50        ;; 04:64bb ????????
    db   $f4, $53, $f4, $50, $f4, $53, $f2, $56        ;; 04:64c3 ????????
    db   $f2, $53, $f2, $56, $f2, $53, $f2, $56        ;; 04:64cb ????????
    db   $f2, $53, $f2, $56, $f2, $53, $f7, $56        ;; 04:64d3 ????????
    db   $f4, $58, $f4, $53, $f4, $50, $f4, $4c        ;; 04:64db ????????
    db   $f6, $50, $f4, $53, $f6, $65, $54, $f2        ;; 04:64e3 ????????
    db   $51, $f2, $54, $f2, $51, $f2, $58, $f8        ;; 04:64eb ????????
    db   $56, $f4, $54, $f4, $58, $f4, $53, $f4        ;; 04:64f3 ????????
    db   $4f, $f6, $4c, $f8, $4e, $f2, $4a, $f2        ;; 04:64fb ????????
    db   $4e, $f2, $51, $f2, $56, $f8, $51, $f6        ;; 04:6503 ????????
    db   $53, $fa, $51, $f2, $4c, $f2, $51, $f2        ;; 04:650b ????????
    db   $54, $f2, $58, $f9, $5d, $f6, $5b, $f6        ;; 04:6513 ????????
    db   $58, $f8, $5a, $f2, $58, $f2, $56, $f8        ;; 04:651b ????????
    db   $51, $f4, $56, $f4, $5a, $f4, $58, $fa        ;; 04:6523 ????????
    db   $51, $f9, $4f, $f4, $51, $f2, $4f, $f2        ;; 04:652b ????????
    db   $4c, $fa, $4e, $f2, $4a, $f2, $4e, $f2        ;; 04:6533 ????????
    db   $4a, $f2, $4e, $f2, $4a, $f2, $4e, $f2        ;; 04:653b ????????
    db   $4a, $f2, $51, $f6, $4e, $f4, $4a, $f4        ;; 04:6543 ????????
    db   $4c, $f6, $50, $f6, $53, $f6, $50, $f6        ;; 04:654b ????????
    db   $65, $45, $fc, $65, $a1, $15, $a1, $14        ;; 04:6553 ????????
    db   $a1, $12, $a1, $15, $a1, $12, $a1, $14        ;; 04:655b ????????
    db   $a1, $14, $a1, $14, $9f, $15, $9f, $14        ;; 04:6563 ????????
    db   $9f, $12, $9f, $15, $9f, $12, $9f, $14        ;; 04:656b ????????
    db   $9f, $14, $9f, $14, $9d, $15, $9d, $14        ;; 04:6573 ????????
    db   $9d, $12, $9d, $15, $9d, $12, $9d, $14        ;; 04:657b ????????
    db   $9d, $14, $9d, $14, $9c, $15, $9c, $14        ;; 04:6583 ????????
    db   $9c, $12, $9c, $15, $9c, $12, $9c, $14        ;; 04:658b ????????
    db   $9c, $14, $9c, $14, $65, $a1, $14, $a1        ;; 04:6593 ????????
    db   $12, $a1, $14, $a1, $12, $a1, $15, $a1        ;; 04:659b ????????
    db   $12, $a1, $14, $a1, $14, $a1, $14, $a4        ;; 04:65a3 ????????
    db   $14, $a4, $12, $a4, $14, $a4, $12, $a4        ;; 04:65ab ????????
    db   $15, $a4, $12, $a4, $14, $a4, $14, $a4        ;; 04:65b3 ????????
    db   $14, $a1, $14, $a1, $12, $a1, $14, $a1        ;; 04:65bb ????????
    db   $12, $a1, $15, $a1, $12, $a1, $14, $a1        ;; 04:65c3 ????????
    db   $14, $a1, $14, $a4, $14, $a4, $12, $a4        ;; 04:65cb ????????
    db   $14, $a4, $12, $a4, $15, $a4, $12, $a4        ;; 04:65d3 ????????
    db   $14, $a4, $14, $a4, $14, $9c, $14, $9c        ;; 04:65db ????????
    db   $12, $9c, $14, $9c, $12, $9c, $15, $9c        ;; 04:65e3 ????????
    db   $12, $9c, $14, $9c, $14, $9c, $14, $9d        ;; 04:65eb ????????
    db   $14, $9d, $12, $9d, $14, $9d, $12, $9d        ;; 04:65f3 ????????
    db   $15, $9d, $12, $9d, $14, $9d, $14, $9d        ;; 04:65fb ????????
    db   $14, $9c, $14, $9c, $12, $9c, $14, $9c        ;; 04:6603 ????????
    db   $12, $9c, $15, $9c, $12, $9c, $14, $9c        ;; 04:660b ????????
    db   $14, $9c, $14, $a1, $14, $a1, $12, $a1        ;; 04:6613 ????????
    db   $14, $a1, $12, $a1, $15, $a1, $12, $a1        ;; 04:661b ????????
    db   $14, $a1, $14, $a1, $14, $9c, $14, $9c        ;; 04:6623 ????????
    db   $12, $9c, $14, $9c, $12, $9c, $15, $9c        ;; 04:662b ????????
    db   $12, $9c, $14, $9c, $14, $9c, $14, $9c        ;; 04:6633 ????????
    db   $14, $9c, $12, $9c, $14, $9c, $12, $9c        ;; 04:663b ????????
    db   $15, $9c, $12, $9c, $14, $9c, $14, $9c        ;; 04:6643 ????????
    db   $14, $65, $a3, $15, $a3, $14, $a3, $12        ;; 04:664b ????????
    db   $a3, $15, $a3, $12, $a3, $12, $a3, $12        ;; 04:6653 ????????
    db   $a3, $14, $a3, $14, $9e, $15, $9e, $14        ;; 04:665b ????????
    db   $9e, $12, $9e, $15, $9e, $12, $9e, $12        ;; 04:6663 ????????
    db   $9e, $12, $9e, $14, $9e, $14, $a5, $15        ;; 04:666b ????????
    db   $a5, $14, $a5, $12, $a5, $15, $a5, $12        ;; 04:6673 ????????
    db   $a5, $12, $a5, $12, $a5, $14, $a5, $14        ;; 04:667b ????????
    db   $9e, $15, $9e, $14, $9e, $12, $9e, $15        ;; 04:6683 ????????
    db   $9e, $12, $9e, $12, $9e, $12, $9e, $14        ;; 04:668b ????????
    db   $9e, $14, $65, $a3, $15, $a3, $14, $a3        ;; 04:6693 ????????
    db   $12, $a3, $15, $a3, $12, $a3, $12, $a3        ;; 04:669b ????????
    db   $12, $a3, $14, $a3, $14, $9c, $15, $9c        ;; 04:66a3 ????????
    db   $14, $9c, $12, $9c, $15, $9c, $12, $9c        ;; 04:66ab ????????
    db   $12, $9c, $12, $9c, $14, $9c, $14, $65        ;; 04:66b3 ????????
    db   $a1, $15, $a1, $14, $a1, $12, $a1, $15        ;; 04:66bb ????????
    db   $a1, $12, $a1, $12, $a1, $12, $a1, $14        ;; 04:66c3 ????????
    db   $a1, $14, $a8, $15, $a8, $14, $a8, $12        ;; 04:66cb ????????
    db   $a8, $15, $a8, $12, $a8, $12, $a8, $12        ;; 04:66d3 ????????
    db   $a8, $14, $a8, $14, $a6, $15, $a6, $14        ;; 04:66db ????????
    db   $a6, $12, $a6, $15, $a6, $12, $a6, $12        ;; 04:66e3 ????????
    db   $a6, $12, $a6, $14, $a6, $14, $a8, $15        ;; 04:66eb ????????
    db   $a8, $14, $a8, $12, $a8, $15, $a8, $12        ;; 04:66f3 ????????
    db   $a8, $12, $a8, $12, $a8, $14, $a8, $14        ;; 04:66fb ????????
    db   $65, $a1, $15, $a1, $14, $a1, $12, $a1        ;; 04:6703 ????????
    db   $15, $a1, $12, $a1, $14, $a1, $14, $a1        ;; 04:670b ????????
    db   $14, $65, $1a, $54, $1a, $52, $1a, $54        ;; 04:6713 ????????
    db   $1a, $52, $1a, $55, $1a, $52, $1a, $52        ;; 04:671b ????????
    db   $1a, $52, $1a, $52, $1a, $52, $1a, $52        ;; 04:6723 ????????
    db   $1a, $52, $1a, $54, $1a, $52, $1a, $54        ;; 04:672b ????????
    db   $1a, $52, $1a, $54, $1a, $51, $1a, $51        ;; 04:6733 ????????
    db   $1a, $51, $1a, $52, $1a, $52, $1a, $52        ;; 04:673b ????????
    db   $1a, $52, $1a, $52, $1a, $52, $65             ;; 04:6743 ???????

data_04_674a:
    db   $67, $ff, $69, $a0, $64, $00, $00, $02        ;; 04:674a ........
    db   $64, $54, $ef, $01, $64, $55, $ef, $01        ;; 04:6752 ........
    db   $64, $56, $e3, $01, $64, $57, $e3, $02        ;; 04:675a ........
    db   $64, $57, $e1, $02, $64, $58, $e3, $01        ;; 04:6762 ........
    db   $64, $59, $e3, $02, $64, $59, $e5, $02        ;; 04:676a ....????
    db   $66, $01, $62, $4a, $67                       ;; 04:6772 ?????

data_04_6777:
    db   $64, $50, $d7, $06, $64, $50, $d5, $08        ;; 04:6777 ........
    db   $64, $51, $e3, $02, $64, $51, $e1, $02        ;; 04:677f ........
    db   $64, $52, $e3, $01, $64, $53, $e3, $02        ;; 04:6787 ........
    db   $64, $53, $e5, $02, $62, $77, $67             ;; 04:678f ???????

data_04_6796:
    db   $64, $4c, $ef, $03, $64, $4c, $ed, $04        ;; 04:6796 ........
    db   $64, $4d, $ef, $02, $64, $4d, $ed, $02        ;; 04:679e ........
    db   $64, $4e, $ef, $01, $64, $4f, $ef, $02        ;; 04:67a6 ........
    db   $64, $4f, $f1, $02, $62, $96, $67             ;; 04:67ae ???????

data_04_67b5:
    db   $18, $14, $1e, $34, $1e, $34, $1e, $34        ;; 04:67b5 ........
    db   $1a, $24, $1e, $34, $18, $14, $1e, $34        ;; 04:67bd ........
    db   $62                                           ;; 04:67c5 .
    dw   data_04_67b5                                  ;; 04:67c6 pP

data_04_67c8:
    db   $3f, $a6, $40, $a6, $39, $a7, $39, $a2        ;; 04:67c8 ........
    db   $3b, $a2, $3c, $a6, $39, $a6, $3b, $a6        ;; 04:67d0 ........
    db   $38, $a6, $39, $a6, $34, $a6, $35, $a6        ;; 04:67d8 ........
    db   $33, $a6, $34, $aa, $65                       ;; 04:67e0 .....

data_04_67e5:
    db   $3e, $b4, $3d, $b4, $3e, $b4, $39, $b4        ;; 04:67e5 ........
    db   $3c, $b6, $3a, $b6, $36, $b6, $39, $b6        ;; 04:67ed ........
    db   $37, $b7, $37, $b2, $39, $b2, $3a, $b6        ;; 04:67f5 ........
    db   $37, $b6, $39, $b6, $36, $b6, $37, $b4        ;; 04:67fd ........
    db   $39, $b4, $3a, $b4, $3e, $b4, $43, $b8        ;; 04:6805 ........
    db   $65                                           ;; 04:680d .

data_04_680e:
    db   $4b, $b7, $4a, $b2, $49, $b2, $4a, $b6        ;; 04:680e ........
    db   $43, $b6, $46, $b7, $45, $b2, $43, $b2        ;; 04:6816 ........
    db   $45, $b6, $42, $b6, $43, $b6, $3e, $b6        ;; 04:681e ........
    db   $3f, $b6, $3c, $b6, $3e, $ba, $65             ;; 04:6826 .......

data_04_682d:
    db   $40, $a4, $40, $a4, $40, $a4, $40, $a4        ;; 04:682d ........
    db   $40, $a4, $40, $a4, $40, $a4, $40, $a4        ;; 04:6835 ........
    db   $3f, $a4, $3f, $a4, $42, $a4, $42, $a4        ;; 04:683d ........
    db   $45, $a4, $45, $a4, $42, $a4, $42, $a4        ;; 04:6845 ........
    db   $65                                           ;; 04:684d .

data_04_684e:
    db   $3f, $a4, $3f, $a4, $3e, $a4, $3e, $a4        ;; 04:684e ........
    db   $39, $a4, $39, $a4, $3c, $a4, $39, $a4        ;; 04:6856 ........
    db   $3a, $a4, $3a, $a4, $39, $a4, $39, $a4        ;; 04:685e ........
    db   $36, $a4, $36, $a4, $39, $a4, $36, $a4        ;; 04:6866 ........
    db   $65                                           ;; 04:686e .

data_04_686f:
    db   $3a, $a4, $3a, $a4, $3e, $a4, $3e, $a4        ;; 04:686f ........
    db   $3d, $a4, $3d, $a4, $40, $a4, $40, $a4        ;; 04:6877 ........
    db   $3e, $a4, $3e, $a4, $41, $a4, $41, $a4        ;; 04:687f ........
    db   $40, $a4, $40, $a4, $3d, $a4, $40, $a4        ;; 04:6887 ........
    db   $65                                           ;; 04:688f .

data_04_6890:
    db   $40, $94, $39, $94, $3c, $94, $40, $94        ;; 04:6890 ........
    db   $3f, $94, $39, $94, $3c, $94, $3f, $94        ;; 04:6898 ........
    db   $65                                           ;; 04:68a0 .

data_04_68a1:
    db   $3c, $84, $3c, $84, $3c, $84, $3c, $84        ;; 04:68a1 ........
    db   $3c, $84, $3c, $84, $3c, $84, $3c, $84        ;; 04:68a9 ........
    db   $3b, $84, $3b, $84, $3f, $84, $3f, $84        ;; 04:68b1 ........
    db   $42, $84, $42, $84, $3f, $84, $3f, $84        ;; 04:68b9 ........
    db   $65                                           ;; 04:68c1 .

data_04_68c2:
    db   $3c, $84, $3c, $84, $39, $84, $39, $84        ;; 04:68c2 ........
    db   $36, $84, $36, $84, $39, $84, $36, $84        ;; 04:68ca ........
    db   $37, $84, $37, $84, $36, $84, $36, $84        ;; 04:68d2 ........
    db   $33, $84, $33, $84, $36, $84, $33, $84        ;; 04:68da ........
    db   $65                                           ;; 04:68e2 .

data_04_68e3:
    db   $37, $84, $37, $84, $3a, $84, $3a, $84        ;; 04:68e3 ........
    db   $39, $84, $39, $84, $3d, $84, $3d, $84        ;; 04:68eb ........
    db   $3a, $84, $3a, $84, $3e, $84, $3e, $84        ;; 04:68f3 ........
    db   $3d, $84, $3d, $84, $39, $84, $3d, $84        ;; 04:68fb ........
    db   $65                                           ;; 04:6903 .

data_04_6904:
    db   $a1, $17, $a8, $16, $9c, $16, $9f, $14        ;; 04:6904 ........
    db   $a1, $17, $a8, $16, $9c, $14, $9f, $14        ;; 04:690c ........
    db   $a0, $14, $65                                 ;; 04:6914 ...

data_04_6917:
    db   $a1, $17, $a1, $16, $a1, $16, $a1, $14        ;; 04:6917 ........
    db   $a1, $17, $a1, $16, $a1, $14, $a1, $14        ;; 04:691f ........
    db   $a1, $14, $65                                 ;; 04:6927 ...

data_04_692a:
    db   $a6, $17, $a6, $14, $a6, $17, $a6, $14        ;; 04:692a ........
    db   $a6, $17, $a6, $14, $a6, $16, $a6, $16        ;; 04:6932 ........
    db   $65                                           ;; 04:693a .

data_04_693b:
    db   $9f, $17, $9f, $16, $9f, $14, $9a, $14        ;; 04:693b ........
    db   $9d, $14, $9f, $17, $9f, $16, $9f, $14        ;; 04:6943 ........
    db   $9a, $14, $9d, $14, $65, $67, $ff, $69        ;; 04:694b .....???
    db   $ae, $64, $00, $00, $02, $64, $65, $ef        ;; 04:6953 ????????
    db   $01, $64, $66, $ef, $01, $64, $65, $ef        ;; 04:695b ????????
    db   $01, $64, $66, $ef, $01, $64, $67, $ef        ;; 04:6963 ????????
    db   $01, $64, $68, $ef, $01, $64, $69, $ef        ;; 04:696b ????????
    db   $02, $64, $69, $f2, $02, $64, $6a, $ef        ;; 04:6973 ????????
    db   $01, $64, $65, $ef, $01, $64, $66, $ef        ;; 04:697b ????????
    db   $01, $64, $65, $ef, $01, $64, $66, $ef        ;; 04:6983 ????????
    db   $01, $64, $6b, $ef, $01, $64, $67, $ef        ;; 04:698b ????????
    db   $01, $64, $68, $ef, $01, $64, $6c, $ef        ;; 04:6993 ????????
    db   $02, $64, $6d, $e3, $01, $66, $01, $62        ;; 04:699b ????????
    db   $50, $69, $64, $00, $00, $0a, $64, $6e        ;; 04:69a3 ????????
    db   $e3, $01, $64, $6f, $ef, $01, $64, $70        ;; 04:69ab ????????
    db   $ef, $01, $64, $74, $07, $04, $64, $71        ;; 04:69b3 ????????
    db   $ef, $02, $64, $71, $f2, $02, $64, $72        ;; 04:69bb ????????
    db   $ef, $01, $64, $6e, $e3, $01, $64, $6f        ;; 04:69c3 ????????
    db   $ef, $01, $64, $6e, $e3, $01, $64, $6f        ;; 04:69cb ????????
    db   $ef, $01, $64, $75, $07, $02, $64, $70        ;; 04:69d3 ????????
    db   $ef, $01, $64, $74, $07, $04, $64, $76        ;; 04:69db ????????
    db   $07, $04, $64, $73, $ef, $01, $62, $a5        ;; 04:69e3 ????????
    db   $69, $64, $5c, $ef, $03, $64, $5d, $ef        ;; 04:69eb ????????
    db   $01, $64, $5c, $ef, $02, $64, $5d, $ef        ;; 04:69f3 ????????
    db   $01, $64, $5e, $ef, $01, $64, $5f, $ef        ;; 04:69fb ????????
    db   $04, $64, $60, $ef, $02, $64, $60, $f2        ;; 04:6a03 ????????
    db   $02, $64, $61, $ef, $01, $64, $5c, $ef        ;; 04:6a0b ????????
    db   $02, $64, $5d, $ef, $01, $64, $5c, $ef        ;; 04:6a13 ????????
    db   $02, $64, $5d, $ef, $01, $64, $62, $ef        ;; 04:6a1b ????????
    db   $02, $64, $5e, $ef, $01, $64, $5f, $ef        ;; 04:6a23 ????????
    db   $04, $64, $63, $ef, $02, $64, $64, $ef        ;; 04:6a2b ????????
    db   $02, $62, $ec, $69, $64, $5a, $00, $04        ;; 04:6a33 ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $03        ;; 04:6a3b ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $04        ;; 04:6a43 ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $01        ;; 04:6a4b ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $02        ;; 04:6a53 ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $03        ;; 04:6a5b ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $03        ;; 04:6a63 ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $01        ;; 04:6a6b ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $01        ;; 04:6a73 ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $04        ;; 04:6a7b ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $03        ;; 04:6a83 ????????
    db   $64, $5b, $00, $01, $64, $5a, $00, $01        ;; 04:6a8b ????????
    db   $64, $5b, $00, $01, $62, $37, $6a, $9c        ;; 04:6a93 ????????
    db   $32, $9c, $34, $9c, $32, $9c, $34, $9c        ;; 04:6a9b ????????
    db   $34, $9c, $32, $9c, $34, $9c, $32, $9c        ;; 04:6aa3 ????????
    db   $34, $9c, $34, $95, $32, $95, $34, $95        ;; 04:6aab ????????
    db   $32, $95, $34, $95, $34, $95, $32, $95        ;; 04:6ab3 ????????
    db   $34, $95, $32, $95, $34, $95, $34, $65        ;; 04:6abb ????????
    db   $95, $86, $95, $84, $95, $84, $95, $86        ;; 04:6ac3 ????????
    db   $95, $84, $95, $84, $93, $56, $93, $54        ;; 04:6acb ????????
    db   $93, $54, $93, $56, $93, $54, $93, $54        ;; 04:6ad3 ????????
    db   $9d, $36, $9d, $34, $9d, $34, $9d, $36        ;; 04:6adb ????????
    db   $9d, $34, $9d, $34, $9c, $36, $9c, $34        ;; 04:6ae3 ????????
    db   $9c, $34, $9c, $36, $9c, $34, $9c, $34        ;; 04:6aeb ????????
    db   $65, $9d, $62, $9d, $64, $9d, $62, $9d        ;; 04:6af3 ????????
    db   $64, $9d, $64, $9d, $62, $9d, $64, $9d        ;; 04:6afb ????????
    db   $62, $9d, $64, $9d, $64, $95, $82, $95        ;; 04:6b03 ????????
    db   $84, $95, $82, $95, $84, $95, $84, $95        ;; 04:6b0b ????????
    db   $82, $95, $84, $95, $82, $95, $84, $95        ;; 04:6b13 ????????
    db   $84, $65, $3e, $f5, $41, $f2, $41, $f4        ;; 04:6b1b ????????
    db   $44, $f4, $41, $f4, $41, $f4, $3e, $f4        ;; 04:6b23 ????????
    db   $3e, $f4, $38, $f7, $4c, $82, $4d, $82        ;; 04:6b2b ????????
    db   $50, $82, $51, $82, $50, $82, $4d, $82        ;; 04:6b33 ????????
    db   $4c, $86, $3e, $f5, $41, $f2, $41, $f4        ;; 04:6b3b ????????
    db   $44, $f4, $41, $f4, $41, $f4, $3e, $f4        ;; 04:6b43 ????????
    db   $3e, $f4, $44, $f7, $54, $82, $53, $82        ;; 04:6b4b ????????
    db   $51, $82, $50, $82, $4d, $82, $50, $82        ;; 04:6b53 ????????
    db   $4c, $86, $65, $39, $f4, $37, $f2, $39        ;; 04:6b5b ????????
    db   $f2, $37, $f4, $35, $f2, $37, $f2, $35        ;; 04:6b63 ????????
    db   $f4, $34, $f2, $35, $f2, $34, $f4, $32        ;; 04:6b6b ????????
    db   $f4, $38, $f4, $3e, $82, $40, $82, $41        ;; 04:6b73 ????????
    db   $82, $44, $82, $45, $82, $47, $82, $45        ;; 04:6b7b ????????
    db   $82, $44, $82, $41, $82, $44, $82, $40        ;; 04:6b83 ????????
    db   $86, $35, $f4, $34, $f2, $35, $f2, $34        ;; 04:6b8b ????????
    db   $f4, $32, $f2, $34, $f2, $33, $f4, $31        ;; 04:6b93 ????????
    db   $f2, $33, $f2, $31, $f4, $33, $f4, $38        ;; 04:6b9b ????????
    db   $f4, $53, $82, $50, $82, $4d, $82, $4a        ;; 04:6ba3 ????????
    db   $82, $53, $82, $4a, $82, $47, $82, $44        ;; 04:6bab ????????
    db   $82, $41, $82, $44, $82, $40, $86, $65        ;; 04:6bb3 ????????
    db   $34, $f5, $35, $f2, $32, $f4, $35, $f4        ;; 04:6bbb ????????
    db   $30, $fb, $65, $3b, $82, $3b, $82, $3b        ;; 04:6bc3 ????????
    db   $82, $3b, $82, $3b, $84, $39, $82, $3b        ;; 04:6bcb ????????
    db   $84, $3b, $82, $3b, $84, $3b, $84, $39        ;; 04:6bd3 ????????
    db   $84, $3b, $82, $3b, $82, $3b, $82, $3b        ;; 04:6bdb ????????
    db   $82, $3b, $84, $39, $82, $3b, $84, $3b        ;; 04:6be3 ????????
    db   $82, $3b, $84, $3b, $84, $3c, $84, $65        ;; 04:6beb ????????
    db   $47, $84, $45, $82, $44, $84, $44, $82        ;; 04:6bf3 ????????
    db   $41, $84, $41, $82, $3e, $82, $41, $82        ;; 04:6bfb ????????
    db   $3e, $82, $3b, $86, $2f, $85, $32, $82        ;; 04:6c03 ????????
    db   $35, $84, $32, $84, $2f, $88, $65, $47        ;; 04:6c0b ????????
    db   $82, $47, $82, $47, $82, $47, $82, $44        ;; 04:6c13 ????????
    db   $84, $41, $84, $47, $82, $47, $82, $47        ;; 04:6c1b ????????
    db   $82, $47, $82, $44, $84, $41, $85, $48        ;; 04:6c23 ????????
    db   $82, $48, $82, $48, $82, $45, $84, $40        ;; 04:6c2b ????????
    db   $84, $48, $82, $48, $82, $48, $82, $48        ;; 04:6c33 ????????
    db   $82, $45, $84, $40, $84, $47, $82, $47        ;; 04:6c3b ????????
    db   $82, $47, $82, $47, $82, $44, $84, $41        ;; 04:6c43 ????????
    db   $85, $47, $82, $47, $82, $47, $82, $44        ;; 04:6c4b ????????
    db   $84, $41, $84, $3c, $8a, $65, $35, $f5        ;; 04:6c53 ????????
    db   $38, $f2, $39, $f4, $3b, $f4, $39, $f4        ;; 04:6c5b ????????
    db   $38, $f4, $35, $f4, $38, $f4, $34, $fa        ;; 04:6c63 ????????
    db   $35, $f5, $38, $f2, $39, $f4, $3b, $f4        ;; 04:6c6b ????????
    db   $39, $f4, $38, $f4, $35, $f4, $38, $f4        ;; 04:6c73 ????????
    db   $40, $fa, $65, $41, $f4, $40, $f2, $41        ;; 04:6c7b ????????
    db   $f2, $40, $f4, $3e, $f2, $40, $f2, $3e        ;; 04:6c83 ????????
    db   $f4, $3c, $f2, $3e, $f2, $3c, $f4, $3b        ;; 04:6c8b ????????
    db   $f4, $3b, $fa, $3e, $f4, $3c, $f2, $3e        ;; 04:6c93 ????????
    db   $f2, $3c, $f4, $3b, $f2, $3c, $f2, $3b        ;; 04:6c9b ????????
    db   $f4, $39, $f2, $3b, $f2, $39, $f4, $3b        ;; 04:6ca3 ????????
    db   $f4, $3b, $fa, $65, $39, $f5, $38, $f2        ;; 04:6cab ????????
    db   $35, $f4, $38, $f4, $34, $fb, $65, $48        ;; 04:6cb3 ????????
    db   $85, $47, $82, $45, $84, $44, $84, $41        ;; 04:6cbb ????????
    db   $82, $40, $82, $41, $82, $40, $82, $3e        ;; 04:6cc3 ????????
    db   $84, $3c, $84, $40, $85, $41, $82, $40        ;; 04:6ccb ????????
    db   $82, $3e, $82, $3c, $82, $3e, $82, $40        ;; 04:6cd3 ????????
    db   $84, $3c, $84, $39, $84, $37, $84, $35        ;; 04:6cdb ????????
    db   $82, $37, $82, $38, $82, $3c, $82, $41        ;; 04:6ce3 ????????
    db   $84, $43, $82, $44, $82, $47, $84, $45        ;; 04:6ceb ????????
    db   $84, $44, $84, $41, $84, $40, $8a, $4d        ;; 04:6cf3 ????????
    db   $85, $4c, $82, $4a, $84, $48, $84, $44        ;; 04:6cfb ????????
    db   $85, $43, $82, $41, $84, $44, $84, $48        ;; 04:6d03 ????????
    db   $84, $45, $84, $40, $84, $3e, $84, $3c        ;; 04:6d0b ????????
    db   $82, $3e, $82, $3c, $82, $3b, $82, $39        ;; 04:6d13 ????????
    db   $86, $35, $82, $37, $82, $38, $82, $3c        ;; 04:6d1b ????????
    db   $82, $41, $82, $43, $82, $44, $84, $47        ;; 04:6d23 ????????
    db   $86, $44, $84, $41, $84, $45, $8a, $65        ;; 04:6d2b ????????
    db   $40, $82, $40, $82, $40, $82, $40, $82        ;; 04:6d33 ????????
    db   $40, $84, $3e, $82, $40, $84, $40, $82        ;; 04:6d3b ????????
    db   $40, $84, $40, $84, $3e, $84, $40, $82        ;; 04:6d43 ????????
    db   $40, $82, $40, $82, $40, $82, $40, $84        ;; 04:6d4b ????????
    db   $3e, $82, $40, $84, $40, $82, $40, $84        ;; 04:6d53 ????????
    db   $40, $84, $41, $84, $65, $4c, $84, $4a        ;; 04:6d5b ????????
    db   $82, $48, $84, $47, $82, $45, $84, $44        ;; 04:6d63 ????????
    db   $82, $41, $82, $44, $82, $41, $82, $40        ;; 04:6d6b ????????
    db   $86, $34, $85, $35, $82, $38, $84, $35        ;; 04:6d73 ????????
    db   $84, $34, $88, $65, $45, $85, $44, $82        ;; 04:6d7b ????????
    db   $41, $84, $44, $84, $40, $82, $3e, $82        ;; 04:6d83 ????????
    db   $40, $82, $41, $82, $40, $86, $3e, $85        ;; 04:6d8b ????????
    db   $3c, $82, $3b, $84, $39, $84, $37, $82        ;; 04:6d93 ????????
    db   $39, $82, $37, $82, $35, $82, $37, $86        ;; 04:6d9b ????????
    db   $35, $85, $37, $82, $39, $84, $3c, $84        ;; 04:6da3 ????????
    db   $41, $82, $43, $82, $45, $82, $43, $82        ;; 04:6dab ????????
    db   $41, $84, $3c, $84, $40, $82, $41, $82        ;; 04:6db3 ????????
    db   $44, $82, $45, $82, $47, $82, $48, $82        ;; 04:6dbb ????????
    db   $4a, $82, $48, $82, $47, $82, $45, $82        ;; 04:6dc3 ????????
    db   $44, $82, $41, $82, $40, $86, $3c, $85        ;; 04:6dcb ????????
    db   $40, $82, $41, $84, $44, $84, $41, $82        ;; 04:6dd3 ????????
    db   $40, $82, $3e, $82, $40, $82, $3c, $86        ;; 04:6ddb ????????
    db   $3e, $85, $43, $82, $45, $84, $47, $84        ;; 04:6de3 ????????
    db   $45, $82, $47, $82, $45, $82, $47, $82        ;; 04:6deb ????????
    db   $4a, $86, $48, $85, $47, $82, $45, $84        ;; 04:6df3 ????????
    db   $43, $84, $45, $84, $41, $84, $43, $84        ;; 04:6dfb ????????
    db   $45, $84, $40, $82, $41, $82, $44, $82        ;; 04:6e03 ????????
    db   $45, $82, $47, $84, $45, $84, $44, $84        ;; 04:6e0b ????????
    db   $41, $84, $40, $86, $65, $4a, $85, $48        ;; 04:6e13 ????????
    db   $82, $47, $84, $45, $84, $44, $82, $41        ;; 04:6e1b ????????
    db   $82, $44, $82, $41, $82, $40, $86, $48        ;; 04:6e23 ????????
    db   $85, $47, $82, $45, $84, $44, $84, $45        ;; 04:6e2b ????????
    db   $84, $40, $84, $3c, $86, $47, $85, $45        ;; 04:6e33 ????????
    db   $82, $44, $84, $41, $84, $40, $82, $41        ;; 04:6e3b ????????
    db   $82, $40, $82, $3e, $82, $40, $84, $41        ;; 04:6e43 ????????
    db   $84, $40, $85, $3e, $82, $3c, $84, $3e        ;; 04:6e4b ????????
    db   $84, $40, $84, $3c, $84, $39, $86, $65        ;; 04:6e53 ????????
    db   $3e, $92, $40, $92, $3e, $92, $3c, $92        ;; 04:6e5b ????????
    db   $3b, $94, $39, $94, $38, $94, $35, $94        ;; 04:6e63 ????????
    db   $34, $94, $38, $94, $39, $9a, $3e, $95        ;; 04:6e6b ????????
    db   $3c, $92, $3b, $94, $39, $94, $38, $92        ;; 04:6e73 ????????
    db   $35, $92, $34, $92, $35, $92, $38, $92        ;; 04:6e7b ????????
    db   $39, $92, $3b, $92, $3c, $92, $39, $9a        ;; 04:6e83 ????????
    db   $65, $a6, $15, $a4, $12, $a1, $14, $a4        ;; 04:6e8b ????????
    db   $14, $a6, $15, $a4, $12, $a1, $14, $a6        ;; 04:6e93 ????????
    db   $14, $a8, $15, $a6, $12, $a3, $14, $a6        ;; 04:6e9b ????????
    db   $14, $a8, $15, $a6, $12, $a3, $14, $a6        ;; 04:6ea3 ????????
    db   $14, $65, $a9, $15, $a6, $15, $a4, $14        ;; 04:6eab ????????
    db   $a9, $15, $a6, $15, $a4, $14, $a8, $15        ;; 04:6eb3 ????????
    db   $a6, $15, $a3, $14, $a8, $15, $a6, $15        ;; 04:6ebb ????????
    db   $a3, $14, $a6, $15, $a4, $15, $a1, $14        ;; 04:6ec3 ????????
    db   $a7, $15, $a3, $15, $a7, $14, $a8, $15        ;; 04:6ecb ????????
    db   $a6, $15, $a3, $14, $a8, $15, $a6, $15        ;; 04:6ed3 ????????
    db   $a3, $14, $65, $a1, $15, $9f, $12, $9c        ;; 04:6edb ????????
    db   $14, $9f, $14, $a1, $15, $9f, $12, $9c        ;; 04:6ee3 ????????
    db   $14, $9f, $14, $a1, $14, $a2, $14, $a3        ;; 04:6eeb ????????
    db   $14, $a4, $14, $a5, $14, $a6, $14, $a7        ;; 04:6ef3 ????????
    db   $14, $a8, $14, $65, $a9, $15, $a6, $15        ;; 04:6efb ????????
    db   $a4, $14, $a9, $15, $a6, $15, $a4, $14        ;; 04:6f03 ????????
    db   $a1, $15, $9f, $12, $9c, $14, $9f, $14        ;; 04:6f0b ????????
    db   $a1, $15, $9f, $12, $9c, $14, $9f, $14        ;; 04:6f13 ????????
    db   $65, $9c, $12, $9c, $12, $9c, $12, $9c        ;; 04:6f1b ????????
    db   $12, $9c, $14, $a8, $12, $9c, $14, $9c        ;; 04:6f23 ????????
    db   $12, $9c, $14, $9c, $14, $9a, $14, $9c        ;; 04:6f2b ????????
    db   $12, $9c, $12, $9c, $12, $9c, $12, $9c        ;; 04:6f33 ????????
    db   $14, $a8, $12, $9c, $14, $9c, $12, $9c        ;; 04:6f3b ????????
    db   $14, $9c, $14, $9d, $14, $65, $9c, $15        ;; 04:6f43 ????????
    db   $9d, $12, $a0, $14, $a1, $14, $a3, $12        ;; 04:6f4b ????????
    db   $a1, $12, $a0, $12, $9d, $12, $9c, $16        ;; 04:6f53 ????????
    db   $a8, $15, $a6, $12, $a3, $14, $a6, $14        ;; 04:6f5b ????????
    db   $a8, $16, $9c, $16, $65, $a1, $15, $a4        ;; 04:6f63 ????????
    db   $12, $9c, $14, $9f, $14, $a1, $15, $a4        ;; 04:6f6b ????????
    db   $12, $9c, $14, $a1, $14, $9f, $15, $a3        ;; 04:6f73 ????????
    db   $12, $9a, $14, $9c, $14, $9f, $15, $a3        ;; 04:6f7b ????????
    db   $12, $9a, $14, $9c, $14, $9d, $15, $a1        ;; 04:6f83 ????????
    db   $12, $98, $14, $9a, $14, $9d, $15, $a1        ;; 04:6f8b ????????
    db   $12, $98, $14, $9a, $14, $9c, $15, $9d        ;; 04:6f93 ????????
    db   $12, $a0, $14, $a3, $14, $a0, $14, $9d        ;; 04:6f9b ????????
    db   $14, $9c, $16, $65, $9c, $15, $9c, $12        ;; 04:6fa3 ????????
    db   $a0, $14, $a3, $16, $9c, $14, $a0, $14        ;; 04:6fab ????????
    db   $a3, $14, $a1, $15, $a1, $12, $a4, $14        ;; 04:6fb3 ????????
    db   $a8, $16, $a1, $14, $a4, $14, $a8, $14        ;; 04:6fbb ????????
    db   $9c, $15, $9c, $12, $a0, $14, $a3, $16        ;; 04:6fc3 ????????
    db   $9c, $14, $a0, $14, $a3, $14, $a1, $15        ;; 04:6fcb ????????
    db   $a3, $12, $a4, $14, $a3, $14, $a1, $14        ;; 04:6fd3 ????????
    db   $a8, $14, $a4, $14, $a1, $14, $65, $a8        ;; 04:6fdb ????????
    db   $15, $a6, $12, $a3, $14, $a6, $14, $a8        ;; 04:6fe3 ????????
    db   $15, $a6, $12, $a3, $14, $a6, $14, $a1        ;; 04:6feb ????????
    db   $15, $9f, $12, $9c, $14, $9f, $14, $a1        ;; 04:6ff3 ????????
    db   $15, $9f, $12, $9c, $14, $9f, $14, $65        ;; 04:6ffb ????????
    db   $18, $12, $1e, $32, $1e, $32, $18, $12        ;; 04:7003 ????????
    db   $1a, $22, $1e, $32, $18, $12, $1e, $32        ;; 04:700b ????????
    db   $18, $12, $1e, $32, $1e, $32, $18, $12        ;; 04:7013 ????????
    db   $1a, $22, $1e, $32, $18, $12, $1e, $32        ;; 04:701b ????????
    db   $18, $12, $1e, $32, $1e, $32, $18, $12        ;; 04:7023 ????????
    db   $1a, $22, $1e, $32, $18, $12, $1e, $32        ;; 04:702b ????????
    db   $18, $12, $1e, $32, $1e, $32, $18, $12        ;; 04:7033 ????????
    db   $1a, $22, $1e, $32, $18, $12, $1e, $32        ;; 04:703b ????????
    db   $65, $18, $12, $1e, $32, $1e, $32, $18        ;; 04:7043 ????????
    db   $12, $1a, $22, $1e, $32, $18, $12, $1e        ;; 04:704b ????????
    db   $32, $18, $12, $1e, $32, $1e, $32, $18        ;; 04:7053 ????????
    db   $12, $1a, $22, $1e, $32, $18, $12, $1e        ;; 04:705b ????????
    db   $32, $18, $12, $1e, $32, $1e, $32, $18        ;; 04:7063 ????????
    db   $12, $1a, $22, $1e, $32, $18, $12, $1e        ;; 04:706b ????????
    db   $32, $18, $12, $1e, $32, $1e, $32, $18        ;; 04:7073 ????????
    db   $12, $1a, $22, $1a, $22, $1a, $22, $1e        ;; 04:707b ????????
    db   $32, $65                                      ;; 04:7083 ??

data_04_7085:
    dw   data_04_5436                                  ;; 04:7085 pP
    dw   data_04_543f                                  ;; 04:7087 pP
    dw   data_04_5442                                  ;; 04:7089 pP
    dw   data_04_5445                                  ;; 04:708b pP
    db   $c1, $70                                      ;; 04:708d .P
    dw   data_04_5448                                  ;; 04:708f pP
    dw   data_04_5471                                  ;; 04:7091 pP
    dw   data_04_54ac                                  ;; 04:7093 pP
    dw   data_04_54d7                                  ;; 04:7095 pP
    db   $c1, $70                                      ;; 04:7097 .P
    dw   data_04_5bbd                                  ;; 04:7099 pP
    dw   data_04_5c08                                  ;; 04:709b pP
    dw   data_04_5c87                                  ;; 04:709d pP
    dw   data_04_5d06                                  ;; 04:709f pP
    db   $c1, $70, $a4, $61, $d9, $61, $40, $62        ;; 04:70a1 .P??????
    db   $6b, $62, $c1, $70                            ;; 04:70a9 ????
    dw   data_04_674a                                  ;; 04:70ad pP
    dw   data_04_6777                                  ;; 04:70af pP
    dw   data_04_6796                                  ;; 04:70b1 pP
    dw   data_04_67b5                                  ;; 04:70b3 pP
    db   $c1, $70, $50, $69, $a5, $69, $ec, $69        ;; 04:70b5 .P??????
    db   $37, $6a, $c1, $70, $03, $04, $06, $09        ;; 04:70bd ????.?.?
    db   $0c, $12, $18, $24, $30, $48, $60, $90        ;; 04:70c5 .....?.?
    db   $c0, $08, $10, $20                            ;; 04:70cd ????

data_04_70d1:
    dw   data_04_7111                                  ;; 04:70d1 pP
    dw   data_04_711d                                  ;; 04:70d3 pP
    dw   data_04_7129                                  ;; 04:70d5 pP
    dw   data_04_7135                                  ;; 04:70d7 pP
    db   $41, $71                                      ;; 04:70d9 ??
    dw   data_04_714d                                  ;; 04:70db pP
    dw   data_04_7159                                  ;; 04:70dd pP
    db   $65, $71                                      ;; 04:70df ??
    dw   data_04_7171                                  ;; 04:70e1 pP
    dw   data_04_717d                                  ;; 04:70e3 pP
    dw   data_04_7189                                  ;; 04:70e5 pP
    dw   data_04_7195                                  ;; 04:70e7 pP
    db   $a1, $71, $ad, $71, $b9, $71, $c5, $71        ;; 04:70e9 ????????
    db   $d1, $71                                      ;; 04:70f1 ??
    dw   data_04_71dd                                  ;; 04:70f3 pP
    dw   data_04_71e9                                  ;; 04:70f5 pP
    dw   data_04_71f5                                  ;; 04:70f7 pP
    dw   data_04_7201                                  ;; 04:70f9 pP
    dw   data_04_720d                                  ;; 04:70fb pP
    db   $19, $72                                      ;; 04:70fd ??
    dw   data_04_7225                                  ;; 04:70ff pP
    dw   data_04_7231                                  ;; 04:7101 pP
    db   $3d, $72, $49, $72, $55, $72, $61, $72        ;; 04:7103 ????????
    db   $6d, $72, $79, $72, $85, $72                  ;; 04:710b ??????

data_04_7111:
    db   $80, $00, $02, $00, $00, $00, $00, $00        ;; 04:7111 ........
    db   $00, $00, $00, $00                            ;; 04:7119 ....

data_04_711d:
    db   $c0, $bd, $00, $01                            ;; 04:711d ....
    dw   data_04_7291                                  ;; 04:7121 pP
    db   $01                                           ;; 04:7123 .
    dw   data_04_7438                                  ;; 04:7124 pP
    db   $00, $00, $00                                 ;; 04:7126 ...

data_04_7129:
    db   $80, $80, $00, $01                            ;; 04:7129 ....
    dw   data_04_729a                                  ;; 04:712d pP
    db   $01                                           ;; 04:712f .
    dw   data_04_743b                                  ;; 04:7130 pP
    db   $00, $00, $00                                 ;; 04:7132 ...

data_04_7135:
    db   $c0, $bb, $61, $00, $00, $00, $01             ;; 04:7135 .......
    dw   data_04_745c                                  ;; 04:713c pP
    db   $00, $00, $00, $80, $80, $00, $01, $a7        ;; 04:713e ...?????
    db   $72, $00, $00, $00, $01, $dd, $74             ;; 04:7146 ???????

data_04_714d:
    db   $80, $00, $00, $01                            ;; 04:714d ....
    dw   data_04_72b4                                  ;; 04:7151 pP
    db   $01                                           ;; 04:7153 .
    dw   data_04_745f                                  ;; 04:7154 pP
    db   $00, $00, $00                                 ;; 04:7156 ...

data_04_7159:
    db   $80, $80, $00, $01                            ;; 04:7159 ....
    dw   data_04_72c1                                  ;; 04:715d pP
    db   $01                                           ;; 04:715f .
    dw   data_04_7464                                  ;; 04:7160 pP
    db   $00, $00, $00, $80, $80, $00, $01, $cc        ;; 04:7162 ...?????
    db   $72, $00, $00, $00, $01, $40, $75             ;; 04:716a ???????

data_04_7171:
    db   $80, $80, $00, $01                            ;; 04:7171 ....
    dw   data_04_72db                                  ;; 04:7175 pP
    db   $00, $00, $00, $01                            ;; 04:7177 ....
    dw   data_04_755f                                  ;; 04:717b pP

data_04_717d:
    db   $80, $80, $00, $01                            ;; 04:717d ....
    dw   data_04_7303                                  ;; 04:7181 pP
    db   $00, $00, $00, $01                            ;; 04:7183 ....
    dw   data_04_75b1                                  ;; 04:7187 pP

data_04_7189:
    db   $80, $80, $00, $01                            ;; 04:7189 ....
    dw   data_04_7364                                  ;; 04:718d pP
    db   $04                                           ;; 04:718f .
    dw   $747b                                         ;; 04:7190 wP
    db   $00, $00, $00                                 ;; 04:7192 ...

data_04_7195:
    db   $80, $40, $00, $01                            ;; 04:7195 ....
    dw   data_04_7371                                  ;; 04:7199 pP
    db   $00, $00, $00, $01                            ;; 04:719b ....
    dw   data_04_75b1                                  ;; 04:719f pP
    db   $80, $80, $00, $01, $80, $73, $0c, $86        ;; 04:71a1 ????????
    db   $74, $00, $00, $00, $80, $40, $00, $01        ;; 04:71a9 ????????
    db   $97, $73, $01, $7b, $74, $00, $00, $00        ;; 04:71b1 ????????
    db   $80, $40, $00, $01, $aa, $73, $02, $b1        ;; 04:71b9 ????????
    db   $74, $00, $00, $00, $80, $80, $00, $01        ;; 04:71c1 ????????
    db   $b9, $73, $0c, $86, $74, $00, $00, $00        ;; 04:71c9 ????????
    db   $c0, $00, $00, $01, $cc, $73, $01, $bc        ;; 04:71d1 ????????
    db   $74, $00, $00, $00                            ;; 04:71d9 ????

data_04_71dd:
    db   $c0, $00, $00, $01                            ;; 04:71dd ....
    dw   data_04_73d5                                  ;; 04:71e1 pP
    db   $01                                           ;; 04:71e3 .
    dw   $74bc                                         ;; 04:71e4 wP
    db   $00, $00, $00                                 ;; 04:71e6 ...

data_04_71e9:
    db   $c0, $00, $00, $01                            ;; 04:71e9 ....
    dw   data_04_73de                                  ;; 04:71ed pP
    db   $01                                           ;; 04:71ef .
    dw   $74bc                                         ;; 04:71f0 wP
    db   $00, $00, $00                                 ;; 04:71f2 ...

data_04_71f5:
    db   $80, $40, $47, $00, $00, $00, $00, $00        ;; 04:71f5 ........
    db   $00, $01                                      ;; 04:71fd ..
    dw   data_04_75c0                                  ;; 04:71ff pP

data_04_7201:
    db   $80, $40, $47, $00, $00, $00, $00, $00        ;; 04:7201 ........
    db   $00, $01                                      ;; 04:7209 ..
    dw   data_04_75cf                                  ;; 04:720b pP

data_04_720d:
    db   $80, $40, $47, $00, $00, $00, $00, $00        ;; 04:720d ........
    db   $00, $01                                      ;; 04:7215 ..
    dw   data_04_75de                                  ;; 04:7217 pP
    db   $80, $40, $47, $00, $00, $00, $00, $00        ;; 04:7219 ????????
    db   $00, $01, $ed, $75                            ;; 04:7221 ????

data_04_7225:
    db   $80, $40, $47, $00, $00, $00, $00, $00        ;; 04:7225 ........
    db   $00, $01                                      ;; 04:722d ..
    dw   data_04_75fc                                  ;; 04:722f pP

data_04_7231:
    db   $80, $40, $47, $00, $00, $00, $00, $00        ;; 04:7231 ........
    db   $00, $01                                      ;; 04:7239 ..
    dw   data_04_760b                                  ;; 04:723b pP
    db   $c0, $00, $00, $01, $e9, $73, $01, $bc        ;; 04:723d ????????
    db   $74, $00, $00, $00, $80, $40, $00, $01        ;; 04:7245 ????????
    db   $fb, $73, $00, $00, $00, $01, $1a, $76        ;; 04:724d ????????
    db   $80, $80, $00, $01, $08, $74, $01, $c7        ;; 04:7255 ????????
    db   $74, $00, $00, $00, $80, $00, $30, $00        ;; 04:725d ????????
    db   $00, $00, $01, $86, $74, $01, $29, $76        ;; 04:7265 ????????
    db   $80, $00, $30, $00, $00, $00, $01, $86        ;; 04:726d ????????
    db   $74, $01, $4c, $76, $c0, $80, $00, $01        ;; 04:7275 ????????
    db   $29, $74, $00, $00, $00, $01, $c0, $75        ;; 04:727d ????????
    db   $80, $80, $00, $01, $29, $74, $00, $00        ;; 04:7285 ????????
    db   $00, $01, $ed, $75                            ;; 04:728d ????

data_04_7291:
    db   $f0, $01, $00, $01, $70, $01, $00, $01        ;; 04:7291 ........
    db   $ff                                           ;; 04:7299 .

data_04_729a:
    db   $c0, $01, $40, $02, $30, $01, $20, $02        ;; 04:729a ........
    db   $10, $05, $00, $01, $ff, $20, $08, $50        ;; 04:72a2 ....????
    db   $08, $90, $04, $40, $40, $20, $20, $00        ;; 04:72aa ????????
    db   $01, $ff                                      ;; 04:72b2 ??

data_04_72b4:
    db   $50, $02, $30, $04, $20, $08, $10, $02        ;; 04:72b4 ....????
    db   $10, $02, $00, $01, $ff                       ;; 04:72bc ?????

data_04_72c1:
    db   $50, $02, $30, $28, $20, $3c, $10, $be        ;; 04:72c1 ....????
    db   $00, $01, $ff, $f0, $02, $80, $02, $60        ;; 04:72c9 ????????
    db   $02, $30, $01, $20, $02, $10, $02, $00        ;; 04:72d1 ????????
    db   $01, $ff                                      ;; 04:72d9 ??

data_04_72db:
    db   $70, $01, $30, $02, $60, $01, $30, $02        ;; 04:72db ........
    db   $50, $01, $20, $02, $40, $01, $20, $02        ;; 04:72e3 ........
    db   $30, $01, $10, $02, $20, $01, $10, $02        ;; 04:72eb ........
    db   $10, $28, $00, $01, $ff, $80, $01, $40        ;; 04:72f3 ..??????
    db   $01, $00, $02, $10, $01, $00, $01, $ff        ;; 04:72fb ????????

data_04_7303:
    db   $40, $04, $00, $04, $40, $04, $00, $04        ;; 04:7303 ........
    db   $50, $04, $00, $04, $50, $04, $00, $04        ;; 04:730b ........
    db   $40, $04, $00, $04, $40, $04, $00, $04        ;; 04:7313 ........
    db   $00, $04, $30, $04, $00, $04, $30, $04        ;; 04:731b ????????
    db   $00, $04, $30, $04, $00, $04, $30, $04        ;; 04:7323 ????????
    db   $00, $04, $30, $04, $00, $04, $30, $04        ;; 04:732b ????????
    db   $00, $04, $20, $04, $00, $04, $20, $04        ;; 04:7333 ????????
    db   $00, $05, $20, $05, $00, $05, $20, $05        ;; 04:733b ????????
    db   $00, $05, $10, $05, $00, $05, $10, $05        ;; 04:7343 ????????
    db   $00, $06, $10, $06, $00, $06, $10, $06        ;; 04:734b ????????
    db   $00, $06, $10, $06, $00, $06, $10, $06        ;; 04:7353 ????????
    db   $00, $06, $10, $06, $00, $06, $10, $06        ;; 04:735b ????????
    db   $ff                                           ;; 04:7363 ?

data_04_7364:
    db   $60, $01, $40, $04, $30, $14, $20, $3c        ;; 04:7364 ........
    db   $10, $3c, $00, $01, $ff                       ;; 04:736c ..???

data_04_7371:
    db   $30, $02, $30, $04, $30, $08, $20, $10        ;; 04:7371 ........
    db   $10, $20, $10, $40, $00, $01, $ff, $10        ;; 04:7379 ....????
    db   $02, $20, $01, $30, $01, $60, $03, $50        ;; 04:7381 ????????
    db   $32, $50, $0a, $40, $0a, $30, $0a, $20        ;; 04:7389 ????????
    db   $1e, $10, $1e, $00, $01, $ff, $70, $02        ;; 04:7391 ????????
    db   $60, $04, $50, $07, $40, $08, $30, $14        ;; 04:7399 ????????
    db   $20, $14, $10, $3c, $10, $3c, $00, $01        ;; 04:73a1 ????????
    db   $ff, $60, $02, $50, $02, $40, $03, $30        ;; 04:73a9 ????????
    db   $0a, $20, $28, $10, $28, $00, $01, $ff        ;; 04:73b1 ????????
    db   $10, $02, $20, $01, $30, $01, $40, $14        ;; 04:73b9 ????????
    db   $30, $50, $20, $0a, $10, $0a, $10, $0a        ;; 04:73c1 ????????
    db   $00, $01, $ff, $20, $0a, $40, $5a, $60        ;; 04:73c9 ????????
    db   $f0, $00, $01, $ff                            ;; 04:73d1 ????

data_04_73d5:
    db   $20, $04, $40, $14, $60, $0a, $00, $01        ;; 04:73d5 ........
    db   $ff                                           ;; 04:73dd .

data_04_73de:
    db   $20, $0a, $40, $f0, $60, $f0, $60, $f0        ;; 04:73de ....????
    db   $00, $01, $ff, $20, $01, $40, $14, $60        ;; 04:73e6 ????????
    db   $64, $00, $01, $ff, $20, $04, $40, $c8        ;; 04:73ee ????????
    db   $40, $64, $60, $28, $ff, $50, $04, $40        ;; 04:73f6 ????????
    db   $0a, $30, $14, $20, $28, $10, $1e, $00        ;; 04:73fe ????????
    db   $01, $ff, $60, $01, $40, $3a, $20, $32        ;; 04:7406 ????????
    db   $00, $01, $ff, $20, $05, $30, $05, $40        ;; 04:740e ????????
    db   $05, $70, $c8, $50, $c8, $30, $c8, $00        ;; 04:7416 ????????
    db   $01, $ff, $c0, $01, $00, $01, $30, $01        ;; 04:741e ????????
    db   $00, $01, $ff, $20, $0a, $10, $0a, $20        ;; 04:7426 ????????
    db   $0a, $30, $0a, $40, $14, $50, $64, $60        ;; 04:742e ????????
    db   $64, $ff                                      ;; 04:7436 ??

data_04_7438:
    db   $61, $c8, $7e                                 ;; 04:7438 ..?

data_04_743b:
    db   $37, $02, $64, $02, $22, $01, $37, $01        ;; 04:743b ........
    db   $22, $01, $37, $01, $22, $01, $22, $01        ;; 04:7443 ........
    db   $37, $01, $22, $01, $37, $01, $22, $01        ;; 04:744b ....????
    db   $37, $01, $22, $01, $37, $01, $22, $10        ;; 04:7453 ????????
    db   $7e                                           ;; 04:745b ?

data_04_745c:
    db   $12, $c8, $7e                                 ;; 04:745c ..?

data_04_745f:
    db   $22, $01, $10, $c8, $7e                       ;; 04:745f ....?

data_04_7464:
    db   $21, $0a, $22, $0a, $23, $0a, $24, $0a        ;; 04:7464 ....????
    db   $32, $0a, $33, $0a, $34, $0a, $35, $0a        ;; 04:746c ????????
    db   $42, $0a, $43, $0a, $44, $c8, $7e, $02        ;; 04:7474 ???????.
    db   $03, $fe, $03, $fe, $03, $02, $03, $7d        ;; 04:747c ........
    dw   $747b                                         ;; 04:7484 wP
    db   $01, $03, $ff, $03, $ff, $03, $01, $03        ;; 04:7486 ????????
    db   $01, $03, $ff, $03, $ff, $03, $01, $03        ;; 04:748e ????????
    db   $01, $03, $ff, $03, $ff, $03, $01, $03        ;; 04:7496 ????????
    db   $01, $03, $ff, $03, $ff, $03, $01, $03        ;; 04:749e ????????
    db   $02, $03, $fe, $03, $fe, $03, $02, $03        ;; 04:74a6 ????????
    db   $7d, $a6, $74, $01, $02, $ff, $02, $01        ;; 04:74ae ????????
    db   $02, $ff, $02, $7d, $7b, $74, $06, $02        ;; 04:74b6 ??????..
    db   $fa, $02, $fa, $02, $06, $02, $7d             ;; 04:74be .......
    dw   $74bc                                         ;; 04:74c5 wP
    db   $fd, $02, $03, $02, $03, $02, $fd, $02        ;; 04:74c7 ????????
    db   $7d, $c7, $74, $0d, $03, $f3, $03, $f3        ;; 04:74cf ????????
    db   $03, $0d, $03, $7d, $7b, $74, $03, $24        ;; 04:74d7 ????????
    db   $01, $00, $03, $23, $01, $00, $03, $22        ;; 04:74df ????????
    db   $01, $00, $03, $21, $01, $00, $03, $1f        ;; 04:74e7 ????????
    db   $01, $00, $03, $1e, $01, $00, $03, $1d        ;; 04:74ef ????????
    db   $01, $00, $03, $1c, $01, $00, $03, $1b        ;; 04:74f7 ????????
    db   $01, $00, $03, $1a, $01, $00, $03, $19        ;; 04:74ff ????????
    db   $01, $00, $03, $18, $01, $00, $03, $17        ;; 04:7507 ????????
    db   $01, $00, $03, $16, $01, $00, $03, $15        ;; 04:750f ????????
    db   $01, $00, $03, $14, $01, $00, $03, $13        ;; 04:7517 ????????
    db   $01, $00, $03, $12, $01, $00, $03, $11        ;; 04:751f ????????
    db   $01, $00, $03, $10, $01, $00, $03, $0f        ;; 04:7527 ????????
    db   $01, $00, $03, $0e, $01, $00, $03, $0d        ;; 04:752f ????????
    db   $01, $00, $03, $0c, $01, $00, $ff, $dd        ;; 04:7537 ????????
    db   $74, $01, $ff, $01, $fe, $01, $fd, $01        ;; 04:753f ????????
    db   $fc, $01, $fb, $01, $fa, $01, $f9, $01        ;; 04:7547 ????????
    db   $f8, $01, $f7, $01, $f6, $01, $f5, $01        ;; 04:754f ????????
    db   $f4, $01, $f3, $c8, $f3, $ff, $40, $75        ;; 04:7557 ????????

data_04_755f:
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:755f ........
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:7567 ........
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:756f ........
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:7577 ........
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:757f ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:7587 ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:758f ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 04:7597 ????????
    db   $ff, $5f, $75, $03, $00, $03, $0c, $03        ;; 04:759f ????????
    db   $00, $03, $0c, $03, $00, $03, $0c, $ff        ;; 04:75a7 ????????
    db   $a2, $75                                      ;; 04:75af ??

data_04_75b1:
    db   $04, $0c, $04, $00, $04, $0c, $04, $00        ;; 04:75b1 ........
    db   $04, $0c, $04, $00, $ff                       ;; 04:75b9 .....
    dw   data_04_75b1                                  ;; 04:75be pP

data_04_75c0:
    db   $01, $00, $01, $04, $01, $07, $01, $00        ;; 04:75c0 ........
    db   $01, $04, $01, $07, $ff                       ;; 04:75c8 .....
    dw   data_04_75c0                                  ;; 04:75cd pP

data_04_75cf:
    db   $01, $04, $01, $07, $01, $0c, $01, $04        ;; 04:75cf ........
    db   $01, $07, $01, $0c, $ff                       ;; 04:75d7 .....
    dw   data_04_75cf                                  ;; 04:75dc pP

data_04_75de:
    db   $01, $07, $01, $0c, $01, $10, $01, $07        ;; 04:75de ........
    db   $01, $0c, $01, $10, $ff                       ;; 04:75e6 .....
    dw   data_04_75de                                  ;; 04:75eb pP
    db   $01, $00, $01, $03, $01, $07, $01, $00        ;; 04:75ed ????????
    db   $01, $03, $01, $07, $ff, $ed, $75             ;; 04:75f5 ???????

data_04_75fc:
    db   $01, $03, $01, $07, $01, $0c, $01, $03        ;; 04:75fc ........
    db   $01, $07, $01, $0c, $ff                       ;; 04:7604 .....
    dw   data_04_75fc                                  ;; 04:7609 pP

data_04_760b:
    db   $01, $07, $01, $0c, $01, $0f, $01, $07        ;; 04:760b ........
    db   $01, $0c, $01, $0f, $ff                       ;; 04:7613 .....
    dw   data_04_760b                                  ;; 04:7618 pP
    db   $02, $0c, $02, $00, $02, $0c, $02, $00        ;; 04:761a ????????
    db   $02, $0c, $02, $00, $ff, $1a, $76, $06        ;; 04:7622 ????????
    db   $00, $06, $02, $06, $03, $06, $07, $06        ;; 04:762a ????????
    db   $0c, $06, $0e, $06, $0f, $06, $13, $06        ;; 04:7632 ????????
    db   $18, $06, $13, $06, $0f, $06, $0e, $06        ;; 04:763a ????????
    db   $0c, $06, $07, $06, $03, $06, $02, $ff        ;; 04:7642 ????????
    db   $29, $76, $06, $00, $06, $02, $06, $04        ;; 04:764a ????????
    db   $06, $07, $06, $0c, $06, $0e, $06, $10        ;; 04:7652 ????????
    db   $06, $13, $06, $18, $06, $13, $06, $10        ;; 04:765a ????????
    db   $06, $0e, $06, $0c, $06, $07, $06, $04        ;; 04:7662 ????????
    db   $06, $02, $ff, $4c, $76                       ;; 04:766a ?????

data_04_766f:
    dw   data_04_54e6                                  ;; 04:766f pP
    dw   data_04_56a7                                  ;; 04:7671 pP
    dw   data_04_56e8                                  ;; 04:7673 pP
    dw   data_04_5705                                  ;; 04:7675 pP
    dw   data_04_5722                                  ;; 04:7677 pP
    dw   data_04_5763                                  ;; 04:7679 pP
    dw   data_04_57e2                                  ;; 04:767b pP
    dw   data_04_5863                                  ;; 04:767d pP
    db   $c7, $56                                      ;; 04:767f ??
    dw   data_04_58f4                                  ;; 04:7681 pP
    dw   data_04_5935                                  ;; 04:7683 pP
    dw   data_04_59d6                                  ;; 04:7685 pP
    dw   data_04_5a6f                                  ;; 04:7687 pP
    dw   data_04_5b18                                  ;; 04:7689 pP
    dw   data_04_54e9                                  ;; 04:768b pP
    dw   data_04_553a                                  ;; 04:768d pP
    dw   data_04_558b                                  ;; 04:768f pP
    dw   data_04_55c8                                  ;; 04:7691 pP
    dw   data_04_55dd                                  ;; 04:7693 pP
    dw   data_04_55f0                                  ;; 04:7695 pP
    dw   data_04_5641                                  ;; 04:7697 pP
    db   $92, $56                                      ;; 04:7699 ??
    dw   data_04_613b                                  ;; 04:769b pP
    dw   data_04_6058                                  ;; 04:769d pP
    dw   data_04_6069                                  ;; 04:769f pP
    dw   data_04_6076                                  ;; 04:76a1 pP
    dw   data_04_6097                                  ;; 04:76a3 pP
    dw   data_04_60bc                                  ;; 04:76a5 pP
    dw   data_04_60c5                                  ;; 04:76a7 pP
    dw   data_04_60ce                                  ;; 04:76a9 pP
    dw   data_04_60d7                                  ;; 04:76ab pP
    dw   data_04_6118                                  ;; 04:76ad pP
    dw   data_04_5fdd                                  ;; 04:76af pP
    dw   data_04_5fea                                  ;; 04:76b1 pP
    dw   data_04_6023                                  ;; 04:76b3 pP
    dw   data_04_5da4                                  ;; 04:76b5 pP
    dw   data_04_5db5                                  ;; 04:76b7 pP
    dw   data_04_5dc4                                  ;; 04:76b9 pP
    dw   data_04_5dfd                                  ;; 04:76bb pP
    dw   data_04_5e42                                  ;; 04:76bd pP
    dw   data_04_5e93                                  ;; 04:76bf pP
    dw   data_04_5f1a                                  ;; 04:76c1 pP
    dw   data_04_5f9c                                  ;; 04:76c3 pP
    dw   data_04_5d83                                  ;; 04:76c5 pP
    dw   data_04_5d8e                                  ;; 04:76c7 pP
    dw   data_04_5d99                                  ;; 04:76c9 pP
    dw   data_04_5d32                                  ;; 04:76cb pP
    dw   data_04_5d11                                  ;; 04:76cd pP
    dw   data_04_5f63                                  ;; 04:76cf pP
    db   $11, $5d, $11, $5d, $11, $5d, $11, $5d        ;; 04:76d1 ????????
    db   $11, $5d, $15, $67, $57, $65, $98, $65        ;; 04:76d9 ????????
    db   $4d, $66, $96, $66, $bb, $66, $04, $67        ;; 04:76e1 ????????
    db   $d9, $63, $00, $64, $4d, $64, $aa, $64        ;; 04:76e9 ????????
    db   $e9, $64, $54, $65, $72, $62, $b3, $62        ;; 04:76f1 ????????
    db   $d8, $62, $eb, $62, $fe, $62, $11, $63        ;; 04:76f9 ????????
    db   $5a, $63, $7f, $63, $c8, $63                  ;; 04:7701 ??????
    dw   data_04_6904                                  ;; 04:7707 pP
    dw   data_04_6917                                  ;; 04:7709 pP
    dw   data_04_692a                                  ;; 04:770b pP
    dw   data_04_693b                                  ;; 04:770d pP
    dw   data_04_6890                                  ;; 04:770f pP
    dw   data_04_68a1                                  ;; 04:7711 pP
    dw   data_04_68c2                                  ;; 04:7713 pP
    dw   data_04_68e3                                  ;; 04:7715 pP
    dw   data_04_67c8                                  ;; 04:7717 pP
    dw   data_04_67e5                                  ;; 04:7719 pP
    dw   data_04_680e                                  ;; 04:771b pP
    dw   data_04_682d                                  ;; 04:771d pP
    dw   data_04_684e                                  ;; 04:771f pP
    dw   data_04_686f                                  ;; 04:7721 pP
    db   $03, $70, $44, $70, $8c, $6e, $ad, $6e        ;; 04:7723 ????????
    db   $de, $6e, $ff, $6e, $1c, $6f, $49, $6f        ;; 04:772b ????????
    db   $68, $6f, $a7, $6f, $e2, $6f, $59, $6c        ;; 04:7733 ????????
    db   $7e, $6c, $af, $6c, $ba, $6c, $33, $6d        ;; 04:773b ????????
    db   $60, $6d, $7f, $6d, $18, $6e, $5b, $6e        ;; 04:7743 ????????
    db   $1d, $6b, $5e, $6b, $bb, $6b, $c6, $6b        ;; 04:774b ????????
    db   $f3, $6b, $12, $6c, $f4, $6a, $c3, $6a        ;; 04:7753 ????????
    db   $9a, $6a                                      ;; 04:775b ??
