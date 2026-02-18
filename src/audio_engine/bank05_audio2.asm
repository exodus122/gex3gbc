    db   $c3, $e3, $40, $c3, $7b, $48                  ;; 05:4000 ??????
    jp   jp_05_412b                                    ;; 05:4006 $c3 $2b $41
    jp   jp_05_402b                                    ;; 05:4009 $c3 $2b $40
    db   $c3, $cb, $41, $c3, $1e, $49, $c3, $65        ;; 05:400c ????????
    db   $40, $c3, $73, $40, $c3, $32, $40, $c3        ;; 05:4014 ????????
    db   $79, $40, $c3, $59, $40, $c3, $27, $40        ;; 05:401c ????????
    db   $c3, $af, $40, $ea, $78, $df, $c9             ;; 05:4024 ???????

jp_05_402b:
    call call_05_41cb                                  ;; 05:402b $cd $cb $41
    call call_05_491e                                  ;; 05:402e $cd $1e $49
    ret                                                ;; 05:4031 $c9
    db   $f0, $24, $e6, $07, $28, $07, $3d, $f6        ;; 05:4032 ????????
    db   $08, $47, $c3, $41, $40, $06, $00, $f0        ;; 05:403a ????????
    db   $24, $e6, $70, $28, $05, $d6, $10, $c3        ;; 05:4042 ????????
    db   $4e, $40, $3e, $00, $b0, $fe, $00, $20        ;; 05:404a ????????
    db   $03, $cd, $65, $40, $e0, $24, $c9, $af        ;; 05:4052 ????????
    db   $e0, $25, $ea, $79, $df, $e0, $24, $ea        ;; 05:405a ????????
    db   $76, $df, $c9, $3e, $00, $e0, $12, $e0        ;; 05:4062 ????????
    db   $17, $e0, $1c, $e0, $21, $ea, $76, $df        ;; 05:406a ????????
    db   $c9, $3e, $ff, $ea, $76, $df, $c9, $cd        ;; 05:4072 ????????
    db   $73, $40, $f0, $24, $fe, $00, $20, $05        ;; 05:407a ????????
    db   $3e, $88, $e0, $24, $c9, $e6, $07, $fe        ;; 05:4082 ????????
    db   $07, $28, $03, $c6, $01, $47, $f0, $24        ;; 05:408a ????????
    db   $e6, $70, $cb, $3f, $cb, $3f, $cb, $3f        ;; 05:4092 ????????
    db   $cb, $3f, $fe, $07, $c8, $c6, $01, $cb        ;; 05:409a ????????
    db   $27, $cb, $27, $cb, $27, $cb, $27, $b0        ;; 05:40a2 ????????
    db   $f6, $88, $e0, $24, $c9, $87, $87, $21        ;; 05:40aa ????????
    db   $59, $4a, $85, $6f, $30, $01, $24, $7e        ;; 05:40b2 ????????
    db   $fe, $ff, $28, $03, $cd, $dd, $40, $23        ;; 05:40ba ????????
    db   $7e, $fe, $ff, $28, $03, $cd, $dd, $40        ;; 05:40c2 ????????
    db   $23, $7e, $fe, $ff, $28, $03, $cd, $dd        ;; 05:40ca ????????
    db   $40, $23, $7e, $fe, $ff, $28, $03, $cd        ;; 05:40d2 ????????
    db   $dd, $40, $c9, $e5, $cd, $7b, $48, $e1        ;; 05:40da ????????
    db   $c9, $3e, $00, $e0, $26, $00, $e0, $26        ;; 05:40e2 ????????
    db   $ea, $68, $df, $ea, $69, $df, $ea, $6b        ;; 05:40ea ????????
    db   $df, $ea, $6c, $df, $ea, $6e, $df, $ea        ;; 05:40f2 ????????
    db   $6f, $df, $ea, $71, $df, $ea, $72, $df        ;; 05:40fa ????????
    db   $ea, $00, $df, $ea, $18, $df, $ea, $30        ;; 05:4102 ????????
    db   $df, $ea, $48, $df, $3e, $ff, $ea, $78        ;; 05:410a ????????
    db   $df, $3e, $01, $ea, $77, $df, $11, $30        ;; 05:4112 ????????
    db   $ff, $21, $dd, $49, $06, $10, $7e, $12        ;; 05:411a ????????
    db   $23, $13, $05, $20, $f9, $cd, $8b, $41        ;; 05:4122 ????????
    db   $c9                                           ;; 05:412a ?

jp_05_412b:
    ld   L, A                                          ;; 05:412b $6f
    ld   H, $00                                        ;; 05:412c $26 $00
    add  HL, HL                                        ;; 05:412e $29
    ld   D, H                                          ;; 05:412f $54
    ld   E, L                                          ;; 05:4130 $5d
    add  HL, HL                                        ;; 05:4131 $29
    add  HL, HL                                        ;; 05:4132 $29
    add  HL, DE                                        ;; 05:4133 $19
    ld   DE, data_05_717d                              ;; 05:4134 $11 $7d $71
    add  HL, DE                                        ;; 05:4137 $19
    ld   A, [HL+]                                      ;; 05:4138 $2a
    ld   [wDF02], A                                    ;; 05:4139 $ea $02 $df
    ld   A, [HL+]                                      ;; 05:413c $2a
    ld   [wDF03], A                                    ;; 05:413d $ea $03 $df
    ld   A, [HL+]                                      ;; 05:4140 $2a
    ld   [wDF1A], A                                    ;; 05:4141 $ea $1a $df
    ld   A, [HL+]                                      ;; 05:4144 $2a
    ld   [wDF1B], A                                    ;; 05:4145 $ea $1b $df
    ld   A, [HL+]                                      ;; 05:4148 $2a
    ld   [wDF32], A                                    ;; 05:4149 $ea $32 $df
    ld   A, [HL+]                                      ;; 05:414c $2a
    ld   [wDF33], A                                    ;; 05:414d $ea $33 $df
    ld   A, [HL+]                                      ;; 05:4150 $2a
    ld   [wDF4A], A                                    ;; 05:4151 $ea $4a $df
    ld   A, [HL+]                                      ;; 05:4154 $2a
    ld   [wDF4B], A                                    ;; 05:4155 $ea $4b $df
    ld   A, [HL+]                                      ;; 05:4158 $2a
    ld   [wDF60], A                                    ;; 05:4159 $ea $60 $df
    ld   A, [HL+]                                      ;; 05:415c $2a
    ld   [wDF61], A                                    ;; 05:415d $ea $61 $df
    ld   A, $01                                        ;; 05:4160 $3e $01
    ld   [wDF01], A                                    ;; 05:4162 $ea $01 $df
    ld   [wDF19], A                                    ;; 05:4165 $ea $19 $df
    ld   A, $02                                        ;; 05:4168 $3e $02
    ld   [wDF31], A                                    ;; 05:416a $ea $31 $df
    ld   [wDF49], A                                    ;; 05:416d $ea $49 $df
    ld   A, $03                                        ;; 05:4170 $3e $03
    ld   [wDF00], A                                    ;; 05:4172 $ea $00 $df
    ld   [wDF18], A                                    ;; 05:4175 $ea $18 $df
    ld   [wDF30], A                                    ;; 05:4178 $ea $30 $df
    ld   [wDF48], A                                    ;; 05:417b $ea $48 $df
    ld   [wDF76], A                                    ;; 05:417e $ea $76 $df
    ld   A, $ff                                        ;; 05:4181 $3e $ff
    ld   [wDF78], A                                    ;; 05:4183 $ea $78 $df
    ld   A, $01                                        ;; 05:4186 $3e $01
    ld   [wDF77], A                                    ;; 05:4188 $ea $77 $df
    ld   A, $8f                                        ;; 05:418b $3e $8f
    ldh  [rNR52], A                                    ;; 05:418d $e0 $26
    nop                                                ;; 05:418f $00
    nop                                                ;; 05:4190 $00
    ldh  [rNR52], A                                    ;; 05:4191 $e0 $26
    ld   A, $08                                        ;; 05:4193 $3e $08
    ldh  [rNR10], A                                    ;; 05:4195 $e0 $10
    ld   A, $ff                                        ;; 05:4197 $3e $ff
    ldh  [rNR51], A                                    ;; 05:4199 $e0 $25
    ld   [wDF79], A                                    ;; 05:419b $ea $79 $df
    ld   A, $77                                        ;; 05:419e $3e $77
    ldh  [rNR50], A                                    ;; 05:41a0 $e0 $24
    ld   A, $80                                        ;; 05:41a2 $3e $80
    ldh  [rNR30], A                                    ;; 05:41a4 $e0 $1a
    xor  A, A                                          ;; 05:41a6 $af
    ldh  [rNR12], A                                    ;; 05:41a7 $e0 $12
    ldh  [rNR22], A                                    ;; 05:41a9 $e0 $17
    ldh  [rNR32], A                                    ;; 05:41ab $e0 $1c
    ldh  [rNR42], A                                    ;; 05:41ad $e0 $21
    ld   [wDF14], A                                    ;; 05:41af $ea $14 $df
    ld   [wDF2C], A                                    ;; 05:41b2 $ea $2c $df
    ld   [wDF44], A                                    ;; 05:41b5 $ea $44 $df
    ld   [wDF5C], A                                    ;; 05:41b8 $ea $5c $df
    ld   [wDF15], A                                    ;; 05:41bb $ea $15 $df
    ld   [wDF2D], A                                    ;; 05:41be $ea $2d $df
    ld   [wDF45], A                                    ;; 05:41c1 $ea $45 $df
    ld   [wDF5D], A                                    ;; 05:41c4 $ea $5d $df
    ld   [wDF55], A                                    ;; 05:41c7 $ea $55 $df
    ret                                                ;; 05:41ca $c9

call_05_41cb:
    ld   A, [wDF76]                                    ;; 05:41cb $fa $76 $df
    and  A, A                                          ;; 05:41ce $a7
    ret  Z                                             ;; 05:41cf $c8
    ld   A, [wDF78]                                    ;; 05:41d0 $fa $78 $df
    ld   B, A                                          ;; 05:41d3 $47
    ld   A, [wDF77]                                    ;; 05:41d4 $fa $77 $df
    add  A, B                                          ;; 05:41d7 $80
    ld   [wDF77], A                                    ;; 05:41d8 $ea $77 $df
    ret  NC                                            ;; 05:41db $d0
.data_05_41dc:
    xor  A, A                                          ;; 05:41dc $af
    ld   [wDF7B], A                                    ;; 05:41dd $ea $7b $df
    ld   HL, wDF62                                     ;; 05:41e0 $21 $62 $df
    ld   DE, .data_05_41dc                             ;; 05:41e3 $11 $dc $41
    ld   [HL], E                                       ;; 05:41e6 $73
    inc  HL                                            ;; 05:41e7 $23
    ld   [HL], D                                       ;; 05:41e8 $72
    ld   A, [wDF14]                                    ;; 05:41e9 $fa $14 $df
    ld   [wDF65], A                                    ;; 05:41ec $ea $65 $df
    ld   HL, wDF00                                     ;; 05:41ef $21 $00 $df
    ld   DE, rNR11                                     ;; 05:41f2 $11 $11 $ff
    call call_05_44d4                                  ;; 05:41f5 $cd $d4 $44
    ld   A, [wDF00]                                    ;; 05:41f8 $fa $00 $df
    and  A, $01                                        ;; 05:41fb $e6 $01
    jp   Z, .jp_05_429b                                ;; 05:41fd $ca $9b $42
    ld   A, [wDF69]                                    ;; 05:4200 $fa $69 $df
    and  A, A                                          ;; 05:4203 $a7
    jp   NZ, .jp_05_429b                               ;; 05:4204 $c2 $9b $42
    ld   HL, wDF0A                                     ;; 05:4207 $21 $0a $df
    ld   DE, wDF0B                                     ;; 05:420a $11 $0b $df
    ld   A, [DE]                                       ;; 05:420d $1a
    ld   C, A                                          ;; 05:420e $4f
    inc  DE                                            ;; 05:420f $13
    ld   A, [DE]                                       ;; 05:4210 $1a
    ld   B, A                                          ;; 05:4211 $47
    ld   DE, rNR12                                     ;; 05:4212 $11 $12 $ff
    call call_05_446c                                  ;; 05:4215 $cd $6c $44
    ld   DE, wDF0B                                     ;; 05:4218 $11 $0b $df
    ld   A, C                                          ;; 05:421b $79
    ld   [DE], A                                       ;; 05:421c $12
    ld   A, B                                          ;; 05:421d $78
    inc  DE                                            ;; 05:421e $13
    ld   [DE], A                                       ;; 05:421f $12
    ld   HL, wDF00                                     ;; 05:4220 $21 $00 $df
    ld   DE, rNR13                                     ;; 05:4223 $11 $13 $ff
    call call_05_45a7                                  ;; 05:4226 $cd $a7 $45
    ld   HL, wDF0D                                     ;; 05:4229 $21 $0d $df
    ld   DE, wDF0E                                     ;; 05:422c $11 $0e $df
    ld   A, [DE]                                       ;; 05:422f $1a
    ld   C, A                                          ;; 05:4230 $4f
    inc  DE                                            ;; 05:4231 $13
    ld   A, [DE]                                       ;; 05:4232 $1a
    ld   B, A                                          ;; 05:4233 $47
    ld   DE, wDF05                                     ;; 05:4234 $11 $05 $df
    call call_05_4494                                  ;; 05:4237 $cd $94 $44
    ld   DE, wDF0E                                     ;; 05:423a $11 $0e $df
    ld   A, C                                          ;; 05:423d $79
    ld   [DE], A                                       ;; 05:423e $12
    ld   A, B                                          ;; 05:423f $78
    inc  DE                                            ;; 05:4240 $13
    ld   [DE], A                                       ;; 05:4241 $12
    ld   A, [wDF10]                                    ;; 05:4242 $fa $10 $df
    and  A, A                                          ;; 05:4245 $a7
    jr   Z, .jp_05_429b                                ;; 05:4246 $28 $53
    dec  A                                             ;; 05:4248 $3d
    ld   [wDF10], A                                    ;; 05:4249 $ea $10 $df
    and  A, A                                          ;; 05:424c $a7
    jr   NZ, .jp_05_429b                               ;; 05:424d $20 $4c
    ld   A, [wDF11]                                    ;; 05:424f $fa $11 $df
    ld   C, A                                          ;; 05:4252 $4f
    ld   A, [wDF12]                                    ;; 05:4253 $fa $12 $df
    ld   B, A                                          ;; 05:4256 $47
    ld   A, [BC]                                       ;; 05:4257 $0a
    cp   A, $ff                                        ;; 05:4258 $fe $ff
    jr   Z, .jr_05_428c                                ;; 05:425a $28 $30
    ld   [wDF10], A                                    ;; 05:425c $ea $10 $df
    inc  BC                                            ;; 05:425f $03
    ld   A, [BC]                                       ;; 05:4260 $0a
    ld   E, A                                          ;; 05:4261 $5f
    ld   A, [wDF7C]                                    ;; 05:4262 $fa $7c $df
    add  A, E                                          ;; 05:4265 $83
    push AF                                            ;; 05:4266 $f5
    ld   DE, data_05_481b                              ;; 05:4267 $11 $1b $48
    add  A, E                                          ;; 05:426a $83
    ld   E, A                                          ;; 05:426b $5f
    jr   NC, .jr_05_426f                               ;; 05:426c $30 $01
    inc  D                                             ;; 05:426e $14
.jr_05_426f:
    ld   A, [DE]                                       ;; 05:426f $1a
    ld   [wDF04], A                                    ;; 05:4270 $ea $04 $df
    pop  AF                                            ;; 05:4273 $f1
    ld   DE, data_05_47bb                              ;; 05:4274 $11 $bb $47
    add  A, E                                          ;; 05:4277 $83
    ld   E, A                                          ;; 05:4278 $5f
    jr   NC, .jr_05_427c                               ;; 05:4279 $30 $01
    inc  D                                             ;; 05:427b $14
.jr_05_427c:
    ld   A, [DE]                                       ;; 05:427c $1a
    ld   [wDF05], A                                    ;; 05:427d $ea $05 $df
    inc  BC                                            ;; 05:4280 $03
    ld   A, C                                          ;; 05:4281 $79
    ld   [wDF11], A                                    ;; 05:4282 $ea $11 $df
    ld   A, B                                          ;; 05:4285 $78
    ld   [wDF12], A                                    ;; 05:4286 $ea $12 $df
    jp   .jp_05_429b                                   ;; 05:4289 $c3 $9b $42
.jr_05_428c:
    ld   A, $01                                        ;; 05:428c $3e $01
    ld   [wDF10], A                                    ;; 05:428e $ea $10 $df
    inc  BC                                            ;; 05:4291 $03
    ld   A, [BC]                                       ;; 05:4292 $0a
    ld   [wDF11], A                                    ;; 05:4293 $ea $11 $df
    inc  BC                                            ;; 05:4296 $03
    ld   A, [BC]                                       ;; 05:4297 $0a
    ld   [wDF12], A                                    ;; 05:4298 $ea $12 $df
.jp_05_429b:
    ld   A, $01                                        ;; 05:429b $3e $01
    ld   [wDF7B], A                                    ;; 05:429d $ea $7b $df
    ld   HL, wDF62                                     ;; 05:42a0 $21 $62 $df
    ld   DE, .jp_05_429b                               ;; 05:42a3 $11 $9b $42
    ld   [HL], E                                       ;; 05:42a6 $73
    inc  HL                                            ;; 05:42a7 $23
    ld   [HL], D                                       ;; 05:42a8 $72
    ld   A, [wDF2C]                                    ;; 05:42a9 $fa $2c $df
    ld   [wDF65], A                                    ;; 05:42ac $ea $65 $df
    ld   HL, wDF18                                     ;; 05:42af $21 $18 $df
    ld   DE, rNR21                                     ;; 05:42b2 $11 $16 $ff
    call call_05_44d4                                  ;; 05:42b5 $cd $d4 $44
    ld   A, [wDF18]                                    ;; 05:42b8 $fa $18 $df
    and  A, $01                                        ;; 05:42bb $e6 $01
    jp   Z, .jp_05_435b                                ;; 05:42bd $ca $5b $43
    ld   A, [wDF6C]                                    ;; 05:42c0 $fa $6c $df
    and  A, A                                          ;; 05:42c3 $a7
    jp   NZ, .jp_05_435b                               ;; 05:42c4 $c2 $5b $43
    ld   HL, wDF22                                     ;; 05:42c7 $21 $22 $df
    ld   DE, wDF23                                     ;; 05:42ca $11 $23 $df
    ld   A, [DE]                                       ;; 05:42cd $1a
    ld   C, A                                          ;; 05:42ce $4f
    inc  DE                                            ;; 05:42cf $13
    ld   A, [DE]                                       ;; 05:42d0 $1a
    ld   B, A                                          ;; 05:42d1 $47
    ld   DE, rNR22                                     ;; 05:42d2 $11 $17 $ff
    call call_05_446c                                  ;; 05:42d5 $cd $6c $44
    ld   DE, wDF23                                     ;; 05:42d8 $11 $23 $df
    ld   A, C                                          ;; 05:42db $79
    ld   [DE], A                                       ;; 05:42dc $12
    ld   A, B                                          ;; 05:42dd $78
    inc  DE                                            ;; 05:42de $13
    ld   [DE], A                                       ;; 05:42df $12
    ld   HL, wDF18                                     ;; 05:42e0 $21 $18 $df
    ld   DE, rNR23                                     ;; 05:42e3 $11 $18 $ff
    call call_05_45a7                                  ;; 05:42e6 $cd $a7 $45
    ld   HL, wDF25                                     ;; 05:42e9 $21 $25 $df
    ld   DE, wDF26                                     ;; 05:42ec $11 $26 $df
    ld   A, [DE]                                       ;; 05:42ef $1a
    ld   C, A                                          ;; 05:42f0 $4f
    inc  DE                                            ;; 05:42f1 $13
    ld   A, [DE]                                       ;; 05:42f2 $1a
    ld   B, A                                          ;; 05:42f3 $47
    ld   DE, wDF1D                                     ;; 05:42f4 $11 $1d $df
    call call_05_4494                                  ;; 05:42f7 $cd $94 $44
    ld   DE, wDF26                                     ;; 05:42fa $11 $26 $df
    ld   A, C                                          ;; 05:42fd $79
    ld   [DE], A                                       ;; 05:42fe $12
    ld   A, B                                          ;; 05:42ff $78
    inc  DE                                            ;; 05:4300 $13
    ld   [DE], A                                       ;; 05:4301 $12
    ld   A, [wDF28]                                    ;; 05:4302 $fa $28 $df
    and  A, A                                          ;; 05:4305 $a7
    jr   Z, .jp_05_435b                                ;; 05:4306 $28 $53
    dec  A                                             ;; 05:4308 $3d
    ld   [wDF28], A                                    ;; 05:4309 $ea $28 $df
    and  A, A                                          ;; 05:430c $a7
    jr   NZ, .jp_05_435b                               ;; 05:430d $20 $4c
    ld   A, [wDF29]                                    ;; 05:430f $fa $29 $df
    ld   C, A                                          ;; 05:4312 $4f
    ld   A, [wDF2A]                                    ;; 05:4313 $fa $2a $df
    ld   B, A                                          ;; 05:4316 $47
    ld   A, [BC]                                       ;; 05:4317 $0a
    cp   A, $ff                                        ;; 05:4318 $fe $ff
    jr   Z, .jr_05_434c                                ;; 05:431a $28 $30
    ld   [wDF28], A                                    ;; 05:431c $ea $28 $df
    inc  BC                                            ;; 05:431f $03
    ld   A, [BC]                                       ;; 05:4320 $0a
    ld   E, A                                          ;; 05:4321 $5f
    ld   A, [wDF7D]                                    ;; 05:4322 $fa $7d $df
    add  A, E                                          ;; 05:4325 $83
    push AF                                            ;; 05:4326 $f5
    ld   DE, data_05_481b                              ;; 05:4327 $11 $1b $48
    add  A, E                                          ;; 05:432a $83
    ld   E, A                                          ;; 05:432b $5f
    jr   NC, .jr_05_432f                               ;; 05:432c $30 $01
    inc  D                                             ;; 05:432e $14
.jr_05_432f:
    ld   A, [DE]                                       ;; 05:432f $1a
    ld   [wDF1C], A                                    ;; 05:4330 $ea $1c $df
    pop  AF                                            ;; 05:4333 $f1
    ld   DE, data_05_47bb                              ;; 05:4334 $11 $bb $47
    add  A, E                                          ;; 05:4337 $83
    ld   E, A                                          ;; 05:4338 $5f
    jr   NC, .jr_05_433c                               ;; 05:4339 $30 $01
    inc  D                                             ;; 05:433b $14
.jr_05_433c:
    ld   A, [DE]                                       ;; 05:433c $1a
    ld   [wDF1D], A                                    ;; 05:433d $ea $1d $df
    inc  BC                                            ;; 05:4340 $03
    ld   A, C                                          ;; 05:4341 $79
    ld   [wDF29], A                                    ;; 05:4342 $ea $29 $df
    ld   A, B                                          ;; 05:4345 $78
    ld   [wDF2A], A                                    ;; 05:4346 $ea $2a $df
    jp   .jp_05_435b                                   ;; 05:4349 $c3 $5b $43
.jr_05_434c:
    ld   A, $01                                        ;; 05:434c $3e $01
    ld   [wDF28], A                                    ;; 05:434e $ea $28 $df
    inc  BC                                            ;; 05:4351 $03
    ld   A, [BC]                                       ;; 05:4352 $0a
    ld   [wDF29], A                                    ;; 05:4353 $ea $29 $df
    inc  BC                                            ;; 05:4356 $03
    ld   A, [BC]                                       ;; 05:4357 $0a
    ld   [wDF2A], A                                    ;; 05:4358 $ea $2a $df
.jp_05_435b:
    ld   A, $02                                        ;; 05:435b $3e $02
    ld   [wDF7B], A                                    ;; 05:435d $ea $7b $df
    ld   HL, wDF62                                     ;; 05:4360 $21 $62 $df
    ld   DE, .jp_05_435b                               ;; 05:4363 $11 $5b $43
    ld   [HL], E                                       ;; 05:4366 $73
    inc  HL                                            ;; 05:4367 $23
    ld   [HL], D                                       ;; 05:4368 $72
    ld   A, [wDF44]                                    ;; 05:4369 $fa $44 $df
    ld   [wDF65], A                                    ;; 05:436c $ea $65 $df
    ld   HL, wDF30                                     ;; 05:436f $21 $30 $df
    ld   DE, rNR31                                     ;; 05:4372 $11 $1b $ff
    call call_05_44d4                                  ;; 05:4375 $cd $d4 $44
    ld   A, [wDF30]                                    ;; 05:4378 $fa $30 $df
    and  A, $01                                        ;; 05:437b $e6 $01
    jp   Z, .jp_05_441b                                ;; 05:437d $ca $1b $44
    ld   A, [wDF6F]                                    ;; 05:4380 $fa $6f $df
    and  A, A                                          ;; 05:4383 $a7
    jp   NZ, .jp_05_441b                               ;; 05:4384 $c2 $1b $44
    ld   HL, wDF30                                     ;; 05:4387 $21 $30 $df
    ld   DE, rNR33                                     ;; 05:438a $11 $1d $ff
    call call_05_45a7                                  ;; 05:438d $cd $a7 $45
    ld   HL, wDF3A                                     ;; 05:4390 $21 $3a $df
    ld   DE, wDF3B                                     ;; 05:4393 $11 $3b $df
    ld   A, [DE]                                       ;; 05:4396 $1a
    ld   C, A                                          ;; 05:4397 $4f
    inc  DE                                            ;; 05:4398 $13
    ld   A, [DE]                                       ;; 05:4399 $1a
    ld   B, A                                          ;; 05:439a $47
    ld   DE, rNR32                                     ;; 05:439b $11 $1c $ff
    call call_05_446c                                  ;; 05:439e $cd $6c $44
    ld   DE, wDF3B                                     ;; 05:43a1 $11 $3b $df
    ld   A, C                                          ;; 05:43a4 $79
    ld   [DE], A                                       ;; 05:43a5 $12
    ld   A, B                                          ;; 05:43a6 $78
    inc  DE                                            ;; 05:43a7 $13
    ld   [DE], A                                       ;; 05:43a8 $12
    ld   HL, wDF3D                                     ;; 05:43a9 $21 $3d $df
    ld   DE, wDF3E                                     ;; 05:43ac $11 $3e $df
    ld   A, [DE]                                       ;; 05:43af $1a
    ld   C, A                                          ;; 05:43b0 $4f
    inc  DE                                            ;; 05:43b1 $13
    ld   A, [DE]                                       ;; 05:43b2 $1a
    ld   B, A                                          ;; 05:43b3 $47
    ld   DE, wDF35                                     ;; 05:43b4 $11 $35 $df
    call call_05_4494                                  ;; 05:43b7 $cd $94 $44
    ld   DE, wDF3E                                     ;; 05:43ba $11 $3e $df
    ld   A, C                                          ;; 05:43bd $79
    ld   [DE], A                                       ;; 05:43be $12
    ld   A, B                                          ;; 05:43bf $78
    inc  DE                                            ;; 05:43c0 $13
    ld   [DE], A                                       ;; 05:43c1 $12
    ld   A, [wDF40]                                    ;; 05:43c2 $fa $40 $df
    and  A, A                                          ;; 05:43c5 $a7
    jr   Z, .jp_05_441b                                ;; 05:43c6 $28 $53
    dec  A                                             ;; 05:43c8 $3d
    ld   [wDF40], A                                    ;; 05:43c9 $ea $40 $df
    and  A, A                                          ;; 05:43cc $a7
    jr   NZ, .jp_05_441b                               ;; 05:43cd $20 $4c
    ld   A, [wDF41]                                    ;; 05:43cf $fa $41 $df
    ld   C, A                                          ;; 05:43d2 $4f
    ld   A, [wDF42]                                    ;; 05:43d3 $fa $42 $df
    ld   B, A                                          ;; 05:43d6 $47
    ld   A, [BC]                                       ;; 05:43d7 $0a
    cp   A, $ff                                        ;; 05:43d8 $fe $ff
    jr   Z, .jr_05_440c                                ;; 05:43da $28 $30
    ld   [wDF40], A                                    ;; 05:43dc $ea $40 $df
    inc  BC                                            ;; 05:43df $03
    ld   A, [BC]                                       ;; 05:43e0 $0a
    ld   E, A                                          ;; 05:43e1 $5f
    ld   A, [wDF7E]                                    ;; 05:43e2 $fa $7e $df
    add  A, E                                          ;; 05:43e5 $83
    push AF                                            ;; 05:43e6 $f5
    ld   DE, data_05_481b                              ;; 05:43e7 $11 $1b $48
    add  A, E                                          ;; 05:43ea $83
    ld   E, A                                          ;; 05:43eb $5f
    jr   NC, .jr_05_43ef                               ;; 05:43ec $30 $01
    inc  D                                             ;; 05:43ee $14
.jr_05_43ef:
    ld   A, [DE]                                       ;; 05:43ef $1a
    ld   [wDF34], A                                    ;; 05:43f0 $ea $34 $df
    pop  AF                                            ;; 05:43f3 $f1
    ld   DE, data_05_47bb                              ;; 05:43f4 $11 $bb $47
    add  A, E                                          ;; 05:43f7 $83
    ld   E, A                                          ;; 05:43f8 $5f
    jr   NC, .jr_05_43fc                               ;; 05:43f9 $30 $01
    inc  D                                             ;; 05:43fb $14
.jr_05_43fc:
    ld   A, [DE]                                       ;; 05:43fc $1a
    ld   [wDF35], A                                    ;; 05:43fd $ea $35 $df
    inc  BC                                            ;; 05:4400 $03
    ld   A, C                                          ;; 05:4401 $79
    ld   [wDF41], A                                    ;; 05:4402 $ea $41 $df
    ld   A, B                                          ;; 05:4405 $78
    ld   [wDF42], A                                    ;; 05:4406 $ea $42 $df
    jp   .jp_05_441b                                   ;; 05:4409 $c3 $1b $44
.jr_05_440c:
    ld   A, $01                                        ;; 05:440c $3e $01
    ld   [wDF40], A                                    ;; 05:440e $ea $40 $df
    inc  BC                                            ;; 05:4411 $03
    ld   A, [BC]                                       ;; 05:4412 $0a
    ld   [wDF41], A                                    ;; 05:4413 $ea $41 $df
    inc  BC                                            ;; 05:4416 $03
    ld   A, [BC]                                       ;; 05:4417 $0a
    ld   [wDF42], A                                    ;; 05:4418 $ea $42 $df
.jp_05_441b:
    ld   A, $03                                        ;; 05:441b $3e $03
    ld   [wDF7B], A                                    ;; 05:441d $ea $7b $df
    ld   HL, wDF62                                     ;; 05:4420 $21 $62 $df
    ld   DE, .jp_05_441b                               ;; 05:4423 $11 $1b $44
    ld   [HL], E                                       ;; 05:4426 $73
    inc  HL                                            ;; 05:4427 $23
    ld   [HL], D                                       ;; 05:4428 $72
    ld   A, [wDF5C]                                    ;; 05:4429 $fa $5c $df
    ld   [wDF65], A                                    ;; 05:442c $ea $65 $df
    ld   HL, wDF48                                     ;; 05:442f $21 $48 $df
    ld   DE, rNR41                                     ;; 05:4432 $11 $20 $ff
    call call_05_44d4                                  ;; 05:4435 $cd $d4 $44
    ld   A, [wDF48]                                    ;; 05:4438 $fa $48 $df
    and  A, $01                                        ;; 05:443b $e6 $01
    jr   Z, .jp_05_4462                                ;; 05:443d $28 $23
    ld   A, [wDF72]                                    ;; 05:443f $fa $72 $df
    and  A, A                                          ;; 05:4442 $a7
    jp   NZ, .jp_05_4462                               ;; 05:4443 $c2 $62 $44
    ld   HL, wDF52                                     ;; 05:4446 $21 $52 $df
    ld   DE, wDF53                                     ;; 05:4449 $11 $53 $df
    ld   A, [DE]                                       ;; 05:444c $1a
    ld   C, A                                          ;; 05:444d $4f
    inc  DE                                            ;; 05:444e $13
    ld   A, [DE]                                       ;; 05:444f $1a
    ld   B, A                                          ;; 05:4450 $47
    ld   DE, rNR42                                     ;; 05:4451 $11 $21 $ff
    call call_05_446c                                  ;; 05:4454 $cd $6c $44
    ld   DE, wDF53                                     ;; 05:4457 $11 $53 $df
    ld   A, C                                          ;; 05:445a $79
    ld   [DE], A                                       ;; 05:445b $12
    ld   A, B                                          ;; 05:445c $78
    inc  DE                                            ;; 05:445d $13
    ld   [DE], A                                       ;; 05:445e $12
    call call_05_45de                                  ;; 05:445f $cd $de $45
.jp_05_4462:
    ld   HL, wDF48                                     ;; 05:4462 $21 $48 $df
    ld   DE, rNR43                                     ;; 05:4465 $11 $22 $ff
    call call_05_45a7                                  ;; 05:4468 $cd $a7 $45
    ret                                                ;; 05:446b $c9

call_05_446c:
    ld   A, [HL]                                       ;; 05:446c $7e
    and  A, A                                          ;; 05:446d $a7
    ret  Z                                             ;; 05:446e $c8
    dec  [HL]                                          ;; 05:446f $35
    ret  NZ                                            ;; 05:4470 $c0
    ld   A, [BC]                                       ;; 05:4471 $0a
    cp   A, $ff                                        ;; 05:4472 $fe $ff
    jr   NZ, .jr_05_447a                               ;; 05:4474 $20 $04
    ld   A, $00                                        ;; 05:4476 $3e $00
    ld   [HL], A                                       ;; 05:4478 $77
    ret                                                ;; 05:4479 $c9
.jr_05_447a:
    ld   [DE], A                                       ;; 05:447a $12
    inc  BC                                            ;; 05:447b $03
    ld   A, [BC]                                       ;; 05:447c $0a
    ld   [HL], A                                       ;; 05:447d $77
    ld   A, L                                          ;; 05:447e $7d
    sub  A, $06                                        ;; 05:447f $d6 $06
    ld   L, A                                          ;; 05:4481 $6f
    jr   NC, .jr_05_4485                               ;; 05:4482 $30 $01
    dec  H                                             ;; 05:4484 $25
.jr_05_4485:
    ld   A, [HL]                                       ;; 05:4485 $7e
    or   A, $80                                        ;; 05:4486 $f6 $80
    ld   [HL], A                                       ;; 05:4488 $77
    ld   A, L                                          ;; 05:4489 $7d
    add  A, $04                                        ;; 05:448a $c6 $04
    ld   L, A                                          ;; 05:448c $6f
    jr   NC, .jr_05_4490                               ;; 05:448d $30 $01
    inc  H                                             ;; 05:448f $24
.jr_05_4490:
    ld   A, [DE]                                       ;; 05:4490 $1a
    ld   [HL], A                                       ;; 05:4491 $77
    inc  BC                                            ;; 05:4492 $03
    ret                                                ;; 05:4493 $c9

call_05_4494:
    ld   A, [HL]                                       ;; 05:4494 $7e
    and  A, A                                          ;; 05:4495 $a7
    ret  Z                                             ;; 05:4496 $c8
    dec  [HL]                                          ;; 05:4497 $35
    ret  NZ                                            ;; 05:4498 $c0
    inc  BC                                            ;; 05:4499 $03
    ld   A, [BC]                                       ;; 05:449a $0a
    push HL                                            ;; 05:449b $e5
    ld   [HL], A                                       ;; 05:449c $77
    dec  BC                                            ;; 05:449d $0b
    ld   A, [DE]                                       ;; 05:449e $1a
    ld   L, A                                          ;; 05:449f $6f
    dec  DE                                            ;; 05:44a0 $1b
    ld   A, [DE]                                       ;; 05:44a1 $1a
    ld   H, A                                          ;; 05:44a2 $67
    ld   A, [BC]                                       ;; 05:44a3 $0a
    cp   A, $7e                                        ;; 05:44a4 $fe $7e
    jr   NZ, .jr_05_44aa                               ;; 05:44a6 $20 $02
    pop  HL                                            ;; 05:44a8 $e1
    ret                                                ;; 05:44a9 $c9
.jr_05_44aa:
    cp   A, $7d                                        ;; 05:44aa $fe $7d
    jr   Z, .jr_05_44c7                                ;; 05:44ac $28 $19
    cp   A, $7f                                        ;; 05:44ae $fe $7f
    jr   NC, .jr_05_44b9                               ;; 05:44b0 $30 $07
    add  A, L                                          ;; 05:44b2 $85
    ld   L, A                                          ;; 05:44b3 $6f
    jr   NC, .jr_05_44b7                               ;; 05:44b4 $30 $01
    inc  H                                             ;; 05:44b6 $24
.jr_05_44b7:
    jr   .jr_05_44be                                   ;; 05:44b7 $18 $05
.jr_05_44b9:
    add  A, L                                          ;; 05:44b9 $85
    ld   L, A                                          ;; 05:44ba $6f
    jr   C, .jr_05_44be                                ;; 05:44bb $38 $01
    dec  H                                             ;; 05:44bd $25
.jr_05_44be:
    ld   A, H                                          ;; 05:44be $7c
    ld   [DE], A                                       ;; 05:44bf $12
    inc  DE                                            ;; 05:44c0 $13
    ld   A, L                                          ;; 05:44c1 $7d
    ld   [DE], A                                       ;; 05:44c2 $12
    inc  BC                                            ;; 05:44c3 $03
    inc  BC                                            ;; 05:44c4 $03
    pop  HL                                            ;; 05:44c5 $e1
    ret                                                ;; 05:44c6 $c9
.jr_05_44c7:
    inc  BC                                            ;; 05:44c7 $03
    ld   A, [BC]                                       ;; 05:44c8 $0a
    push AF                                            ;; 05:44c9 $f5
    inc  BC                                            ;; 05:44ca $03
    ld   A, [BC]                                       ;; 05:44cb $0a
    ld   B, A                                          ;; 05:44cc $47
    pop  AF                                            ;; 05:44cd $f1
    ld   C, A                                          ;; 05:44ce $4f
    pop  HL                                            ;; 05:44cf $e1
    ld   A, $01                                        ;; 05:44d0 $3e $01
    ld   [HL], A                                       ;; 05:44d2 $77
    ret                                                ;; 05:44d3 $c9

call_05_44d4:
    ld   A, [HL]                                       ;; 05:44d4 $7e
    and  A, $02                                        ;; 05:44d5 $e6 $02
    ret  Z                                             ;; 05:44d7 $c8
    inc  HL                                            ;; 05:44d8 $23
    dec  [HL]                                          ;; 05:44d9 $35
    ret  NZ                                            ;; 05:44da $c0
    inc  HL                                            ;; 05:44db $23
    ld   C, [HL]                                       ;; 05:44dc $4e
    inc  HL                                            ;; 05:44dd $23
    ld   B, [HL]                                       ;; 05:44de $46
    ld   A, [BC]                                       ;; 05:44df $0a
    ld   [wDF66], A                                    ;; 05:44e0 $ea $66 $df
    and  A, $7f                                        ;; 05:44e3 $e6 $7f
    cp   A, $5f                                        ;; 05:44e5 $fe $5f
    jp   NC, jp_05_4637                                ;; 05:44e7 $d2 $37 $46
    push DE                                            ;; 05:44ea $d5
    ld   DE, wDF65                                     ;; 05:44eb $11 $65 $df
    ld   A, [DE]                                       ;; 05:44ee $1a
    ld   D, A                                          ;; 05:44ef $57
    ld   A, [BC]                                       ;; 05:44f0 $0a
    and  A, $7f                                        ;; 05:44f1 $e6 $7f
    add  A, D                                          ;; 05:44f3 $82
    ld   D, A                                          ;; 05:44f4 $57
    push AF                                            ;; 05:44f5 $f5
    ld   A, [wDF7B]                                    ;; 05:44f6 $fa $7b $df
    cp   A, $00                                        ;; 05:44f9 $fe $00
    jr   NZ, .jr_05_4501                               ;; 05:44fb $20 $04
    ld   A, D                                          ;; 05:44fd $7a
    ld   [wDF7C], A                                    ;; 05:44fe $ea $7c $df
.jr_05_4501:
    cp   A, $01                                        ;; 05:4501 $fe $01
    jr   NZ, .jr_05_4509                               ;; 05:4503 $20 $04
    ld   A, D                                          ;; 05:4505 $7a
    ld   [wDF7D], A                                    ;; 05:4506 $ea $7d $df
.jr_05_4509:
    cp   A, $02                                        ;; 05:4509 $fe $02
    jr   NZ, .jr_05_4511                               ;; 05:450b $20 $04
    ld   A, D                                          ;; 05:450d $7a
    ld   [wDF7E], A                                    ;; 05:450e $ea $7e $df
.jr_05_4511:
    pop  AF                                            ;; 05:4511 $f1
    ld   DE, data_05_481b                              ;; 05:4512 $11 $1b $48
    add  A, E                                          ;; 05:4515 $83
    ld   E, A                                          ;; 05:4516 $5f
    jp   NC, .jp_05_451b                               ;; 05:4517 $d2 $1b $45
    inc  D                                             ;; 05:451a $14
.jp_05_451b:
    ld   A, [DE]                                       ;; 05:451b $1a
    inc  HL                                            ;; 05:451c $23
    ld   [HL], A                                       ;; 05:451d $77
    ld   DE, wDF65                                     ;; 05:451e $11 $65 $df
    ld   A, [DE]                                       ;; 05:4521 $1a
    ld   D, A                                          ;; 05:4522 $57
    ld   A, [BC]                                       ;; 05:4523 $0a
    and  A, $7f                                        ;; 05:4524 $e6 $7f
    add  A, D                                          ;; 05:4526 $82
    ld   DE, data_05_47bb                              ;; 05:4527 $11 $bb $47
    add  A, E                                          ;; 05:452a $83
    ld   E, A                                          ;; 05:452b $5f
    jr   NC, .jr_05_452f                               ;; 05:452c $30 $01
    inc  D                                             ;; 05:452e $14
.jr_05_452f:
    ld   A, [DE]                                       ;; 05:452f $1a
    inc  HL                                            ;; 05:4530 $23
    ld   [HL], A                                       ;; 05:4531 $77
    inc  BC                                            ;; 05:4532 $03
    ld   A, [BC]                                       ;; 05:4533 $0a
    and  A, $0f                                        ;; 05:4534 $e6 $0f
    push HL                                            ;; 05:4536 $e5
    ld   HL, wDF61                                     ;; 05:4537 $21 $61 $df
    ld   D, [HL]                                       ;; 05:453a $56
    dec  HL                                            ;; 05:453b $2b
    ld   E, [HL]                                       ;; 05:453c $5e
    pop  HL                                            ;; 05:453d $e1
    add  A, E                                          ;; 05:453e $83
    ld   E, A                                          ;; 05:453f $5f
    jr   NC, .jr_05_4543                               ;; 05:4540 $30 $01
    inc  D                                             ;; 05:4542 $14
.jr_05_4543:
    ld   A, [DE]                                       ;; 05:4543 $1a
    ld   DE, hFFFC                                     ;; 05:4544 $11 $fc $ff
    add  HL, DE                                        ;; 05:4547 $19
    ld   [HL], A                                       ;; 05:4548 $77
    ld   A, [wDF66]                                    ;; 05:4549 $fa $66 $df
    and  A, $80                                        ;; 05:454c $e6 $80
    srl  A                                             ;; 05:454e $cb $3f
    srl  A                                             ;; 05:4550 $cb $3f
    ld   D, A                                          ;; 05:4552 $57
    ld   A, [BC]                                       ;; 05:4553 $0a
    and  A, $f0                                        ;; 05:4554 $e6 $f0
    srl  A                                             ;; 05:4556 $cb $3f
    srl  A                                             ;; 05:4558 $cb $3f
    srl  A                                             ;; 05:455a $cb $3f
    add  A, D                                          ;; 05:455c $82
    push HL                                            ;; 05:455d $e5
    ld   HL, data_05_71f1                              ;; 05:455e $21 $f1 $71
    add  A, L                                          ;; 05:4561 $85
    ld   L, A                                          ;; 05:4562 $6f
    jr   NC, .jr_05_4566                               ;; 05:4563 $30 $01
    inc  H                                             ;; 05:4565 $24
.jr_05_4566:
    ld   E, [HL]                                       ;; 05:4566 $5e
    inc  HL                                            ;; 05:4567 $23
    ld   D, [HL]                                       ;; 05:4568 $56
    pop  HL                                            ;; 05:4569 $e1
    inc  BC                                            ;; 05:456a $03
    inc  HL                                            ;; 05:456b $23
    ld   [HL], C                                       ;; 05:456c $71
    inc  HL                                            ;; 05:456d $23
    ld   [HL], B                                       ;; 05:456e $70
    ld   B, D                                          ;; 05:456f $42
    ld   C, E                                          ;; 05:4570 $4b
    pop  DE                                            ;; 05:4571 $d1
    inc  HL                                            ;; 05:4572 $23
    ld   A, [BC]                                       ;; 05:4573 $0a
    or   A, [HL]                                       ;; 05:4574 $b6
    ld   [HL], A                                       ;; 05:4575 $77
    inc  HL                                            ;; 05:4576 $23
    inc  HL                                            ;; 05:4577 $23
    inc  HL                                            ;; 05:4578 $23
    inc  BC                                            ;; 05:4579 $03
    ld   A, [BC]                                       ;; 05:457a $0a
    ld   [HL], A                                       ;; 05:457b $77
    inc  BC                                            ;; 05:457c $03
    inc  DE                                            ;; 05:457d $13
    inc  HL                                            ;; 05:457e $23
    ld   A, [BC]                                       ;; 05:457f $0a
    ld   [HL], A                                       ;; 05:4580 $77
    inc  HL                                            ;; 05:4581 $23
    inc  HL                                            ;; 05:4582 $23
    inc  BC                                            ;; 05:4583 $03
    ld   A, [BC]                                       ;; 05:4584 $0a
    ld   [HL], A                                       ;; 05:4585 $77
    inc  HL                                            ;; 05:4586 $23
    inc  BC                                            ;; 05:4587 $03
    ld   A, [BC]                                       ;; 05:4588 $0a
    ld   [HL], A                                       ;; 05:4589 $77
    inc  HL                                            ;; 05:458a $23
    inc  BC                                            ;; 05:458b $03
    ld   A, [BC]                                       ;; 05:458c $0a
    ld   [HL], A                                       ;; 05:458d $77
    inc  HL                                            ;; 05:458e $23
    inc  BC                                            ;; 05:458f $03
    ld   A, [BC]                                       ;; 05:4590 $0a
    ld   [HL], A                                       ;; 05:4591 $77
    inc  HL                                            ;; 05:4592 $23
    inc  BC                                            ;; 05:4593 $03
    ld   A, [BC]                                       ;; 05:4594 $0a
    ld   [HL], A                                       ;; 05:4595 $77
    inc  HL                                            ;; 05:4596 $23
    inc  BC                                            ;; 05:4597 $03
    ld   A, [BC]                                       ;; 05:4598 $0a
    ld   [HL], A                                       ;; 05:4599 $77
    inc  BC                                            ;; 05:459a $03
    inc  HL                                            ;; 05:459b $23
    ld   A, [BC]                                       ;; 05:459c $0a
    ld   [HL], A                                       ;; 05:459d $77
    inc  BC                                            ;; 05:459e $03
    inc  HL                                            ;; 05:459f $23
    ld   A, [BC]                                       ;; 05:45a0 $0a
    ld   [HL], A                                       ;; 05:45a1 $77
    inc  BC                                            ;; 05:45a2 $03
    inc  HL                                            ;; 05:45a3 $23
    ld   A, [BC]                                       ;; 05:45a4 $0a
    ld   [HL], A                                       ;; 05:45a5 $77
    ret                                                ;; 05:45a6 $c9

call_05_45a7:
    ld   A, [HL]                                       ;; 05:45a7 $7e
    and  A, $01                                        ;; 05:45a8 $e6 $01
    ret  Z                                             ;; 05:45aa $c8
    ld   BC, $05                                       ;; 05:45ab $01 $05 $00
    add  HL, BC                                        ;; 05:45ae $09
    ld   A, E                                          ;; 05:45af $7b
    cp   A, $22                                        ;; 05:45b0 $fe $22
    jp   Z, .jp_05_45d5                                ;; 05:45b2 $ca $d5 $45
    ld   A, [HL]                                       ;; 05:45b5 $7e
    ld   [DE], A                                       ;; 05:45b6 $12
.jr_05_45b7:
    dec  HL                                            ;; 05:45b7 $2b
    inc  DE                                            ;; 05:45b8 $13
    push DE                                            ;; 05:45b9 $d5
    push HL                                            ;; 05:45ba $e5
    ld   A, [HL]                                       ;; 05:45bb $7e
    and  A, $80                                        ;; 05:45bc $e6 $80
    jr   Z, .jr_05_45cd                                ;; 05:45be $28 $0d
    ld   BC, $03                                       ;; 05:45c0 $01 $03 $00
    add  HL, BC                                        ;; 05:45c3 $09
    dec  DE                                            ;; 05:45c4 $1b
    dec  DE                                            ;; 05:45c5 $1b
    dec  DE                                            ;; 05:45c6 $1b
    ld   A, [HL]                                       ;; 05:45c7 $7e
    ld   [DE], A                                       ;; 05:45c8 $12
    inc  HL                                            ;; 05:45c9 $23
    inc  DE                                            ;; 05:45ca $13
    ld   A, [HL]                                       ;; 05:45cb $7e
    ld   [DE], A                                       ;; 05:45cc $12
.jr_05_45cd:
    pop  HL                                            ;; 05:45cd $e1
    pop  DE                                            ;; 05:45ce $d1
    ld   A, [HL]                                       ;; 05:45cf $7e
    ld   [DE], A                                       ;; 05:45d0 $12
    and  A, $7f                                        ;; 05:45d1 $e6 $7f
    ld   [HL], A                                       ;; 05:45d3 $77
    ret                                                ;; 05:45d4 $c9
.jp_05_45d5:
    ld   A, [wDF64]                                    ;; 05:45d5 $fa $64 $df
    ld   [wDF4D], A                                    ;; 05:45d8 $ea $4d $df
    ld   [DE], A                                       ;; 05:45db $12
    jr   .jr_05_45b7                                   ;; 05:45dc $18 $d9

call_05_45de:
    ld   A, [wDF55]                                    ;; 05:45de $fa $55 $df
    and  A, A                                          ;; 05:45e1 $a7
    ret  Z                                             ;; 05:45e2 $c8
    dec  A                                             ;; 05:45e3 $3d
    ld   [wDF55], A                                    ;; 05:45e4 $ea $55 $df
    and  A, A                                          ;; 05:45e7 $a7
    ret  NZ                                            ;; 05:45e8 $c0
    ld   A, [wDF56]                                    ;; 05:45e9 $fa $56 $df
    ld   L, A                                          ;; 05:45ec $6f
    ld   A, [wDF57]                                    ;; 05:45ed $fa $57 $df
    ld   H, A                                          ;; 05:45f0 $67
    ld   A, [HL]                                       ;; 05:45f1 $7e
    cp   A, $7e                                        ;; 05:45f2 $fe $7e
    ret  Z                                             ;; 05:45f4 $c8
    cp   A, $7d                                        ;; 05:45f5 $fe $7d
    jr   Z, .jr_05_460b                                ;; 05:45f7 $28 $12
    ld   [wDF64], A                                    ;; 05:45f9 $ea $64 $df
    inc  HL                                            ;; 05:45fc $23
    ld   A, [HL]                                       ;; 05:45fd $7e
    ld   [wDF55], A                                    ;; 05:45fe $ea $55 $df
    inc  HL                                            ;; 05:4601 $23
    ld   A, L                                          ;; 05:4602 $7d
    ld   [wDF56], A                                    ;; 05:4603 $ea $56 $df
    ld   A, H                                          ;; 05:4606 $7c
    ld   [wDF57], A                                    ;; 05:4607 $ea $57 $df
    ret                                                ;; 05:460a $c9
.jr_05_460b:
    ld   A, $01                                        ;; 05:460b $3e $01
    ld   [wDF55], A                                    ;; 05:460d $ea $55 $df
    inc  HL                                            ;; 05:4610 $23
    ld   A, [HL]                                       ;; 05:4611 $7e
    ld   [wDF56], A                                    ;; 05:4612 $ea $56 $df
    inc  HL                                            ;; 05:4615 $23
    ld   A, [HL]                                       ;; 05:4616 $7e
    ld   [wDF57], A                                    ;; 05:4617 $ea $57 $df
    ret                                                ;; 05:461a $c9
    db   $4b                                           ;; 05:461b ?

data_05_461c:
    db   $46                                           ;; 05:461c ?
    dw   data_05_4667                                  ;; 05:461d pP
    db   $70, $46, $81, $46                            ;; 05:461f ????
    dw   data_05_4695                                  ;; 05:4623 pP
    db   $e0, $46, $19, $47                            ;; 05:4625 ????
    dw   data_05_472d                                  ;; 05:4629 pP
    db   $82, $47                                      ;; 05:462b ??
    dw   data_05_479a                                  ;; 05:462d pP
    db   $42, $47, $52, $47, $62, $47, $72, $47        ;; 05:462f ????????

jp_05_4637:
    sub  A, $60                                        ;; 05:4637 $d6 $60
    add  A, A                                          ;; 05:4639 $87
    push HL                                            ;; 05:463a $e5
    dec  HL                                            ;; 05:463b $2b
    dec  HL                                            ;; 05:463c $2b
    inc  [HL]                                          ;; 05:463d $34
    ld   HL, data_05_461c                              ;; 05:463e $21 $1c $46
    add  A, L                                          ;; 05:4641 $85
    ld   L, A                                          ;; 05:4642 $6f
    jr   NC, .jr_05_4646                               ;; 05:4643 $30 $01
    inc  H                                             ;; 05:4645 $24
.jr_05_4646:
    ld   A, [HL]                                       ;; 05:4646 $7e
    dec  HL                                            ;; 05:4647 $2b
    ld   L, [HL]                                       ;; 05:4648 $6e
    ld   H, A                                          ;; 05:4649 $67
    jp   HL                                            ;; 05:464a $e9
    db   $21, $61, $df, $7e, $2b, $6e, $67, $03        ;; 05:464b ????????
    db   $0a, $e6, $0f, $85, $6f, $18, $01, $24        ;; 05:4653 ????????
    db   $7e, $e1, $11, $fe, $ff, $19, $77, $03        ;; 05:465b ????????
    db   $23, $c3, $ad, $47                            ;; 05:4663 ????

data_05_4667:
    pop  HL                                            ;; 05:4667 $e1
    ld   BC, hFFFD                                     ;; 05:4668 $01 $fd $ff
    add  HL, BC                                        ;; 05:466b $09
    ld   A, $00                                        ;; 05:466c $3e $00
    ld   [HL], A                                       ;; 05:466e $77
    ret                                                ;; 05:466f $c9
    db   $e1, $11, $fe, $ff, $19, $3e, $01, $22        ;; 05:4670 ????????
    db   $03, $0a, $22, $03, $0a, $77, $c3, $b1        ;; 05:4678 ????????
    db   $47, $e1, $03, $0a, $ea, $64, $df, $11        ;; 05:4680 ????????
    db   $fe, $ff, $19, $3e, $01, $22, $03, $cd        ;; 05:4688 ????????
    db   $ad, $47, $c3, $b1, $47                       ;; 05:4690 ?????

data_05_4695:
    pop  HL                                            ;; 05:4695 $e1
    ld   DE, hFFFE                                     ;; 05:4696 $11 $fe $ff
    add  HL, DE                                        ;; 05:4699 $19
    ld   A, $01                                        ;; 05:469a $3e $01
    ld   [HL+], A                                      ;; 05:469c $22
    inc  BC                                            ;; 05:469d $03
    ld   A, [BC]                                       ;; 05:469e $0a
    sla  A                                             ;; 05:469f $cb $27
    jr   NC, .jr_05_46a9                               ;; 05:46a1 $30 $06
    ld   DE, data_05_777d                              ;; 05:46a3 $11 $7d $77
    inc  D                                             ;; 05:46a6 $14
    jr   .jr_05_46ac                                   ;; 05:46a7 $18 $03
.jr_05_46a9:
    ld   DE, data_05_777d                              ;; 05:46a9 $11 $7d $77
.jr_05_46ac:
    add  A, E                                          ;; 05:46ac $83
    ld   E, A                                          ;; 05:46ad $5f
    jr   NC, .jr_05_46b1                               ;; 05:46ae $30 $01
    inc  D                                             ;; 05:46b0 $14
.jr_05_46b1:
    ld   A, [DE]                                       ;; 05:46b1 $1a
    ld   [HL+], A                                      ;; 05:46b2 $22
    inc  DE                                            ;; 05:46b3 $13
    ld   A, [DE]                                       ;; 05:46b4 $1a
    ld   [HL+], A                                      ;; 05:46b5 $22
    ld   D, H                                          ;; 05:46b6 $54
    ld   E, L                                          ;; 05:46b7 $5d
    ld   A, $10                                        ;; 05:46b8 $3e $10
    add  A, E                                          ;; 05:46ba $83
    ld   E, A                                          ;; 05:46bb $5f
    jr   NC, .jr_05_46bf                               ;; 05:46bc $30 $01
    inc  D                                             ;; 05:46be $14
.jr_05_46bf:
    inc  BC                                            ;; 05:46bf $03
    ld   A, [BC]                                       ;; 05:46c0 $0a
    ld   [DE], A                                       ;; 05:46c1 $12
    inc  DE                                            ;; 05:46c2 $13
    ld   A, [DE]                                       ;; 05:46c3 $1a
    and  A, A                                          ;; 05:46c4 $a7
    jr   Z, .jr_05_46ca                                ;; 05:46c5 $28 $03
    inc  BC                                            ;; 05:46c7 $03
    jr   .jr_05_46d6                                   ;; 05:46c8 $18 $0c
.jr_05_46ca:
    ld   A, $01                                        ;; 05:46ca $3e $01
    ld   [DE], A                                       ;; 05:46cc $12
    dec  DE                                            ;; 05:46cd $1b
    dec  DE                                            ;; 05:46ce $1b
    inc  BC                                            ;; 05:46cf $03
    ld   A, [BC]                                       ;; 05:46d0 $0a
    sub  A, $01                                        ;; 05:46d1 $d6 $01
    ld   [DE], A                                       ;; 05:46d3 $12
    inc  DE                                            ;; 05:46d4 $13
    inc  DE                                            ;; 05:46d5 $13
.jr_05_46d6:
    inc  BC                                            ;; 05:46d6 $03
    inc  DE                                            ;; 05:46d7 $13
    ld   A, C                                          ;; 05:46d8 $79
    ld   [DE], A                                       ;; 05:46d9 $12
    inc  DE                                            ;; 05:46da $13
    ld   A, B                                          ;; 05:46db $78
    ld   [DE], A                                       ;; 05:46dc $12
    jp   jp_05_47b1                                    ;; 05:46dd $c3 $b1 $47
    db   $03, $e1, $11, $fe, $ff, $19, $3e, $01        ;; 05:46e0 ????????
    db   $22, $54, $5d, $3e, $11, $83, $5f, $30        ;; 05:46e8 ????????
    db   $01, $14, $1a, $a7, $28, $14, $d6, $01        ;; 05:46f0 ????????
    db   $12, $13, $13, $13, $1a, $d6, $04, $22        ;; 05:46f8 ????????
    db   $13, $1a, $30, $02, $d6, $01, $77, $c3        ;; 05:4700 ????????
    db   $b1, $47, $13, $3e, $00, $12, $13, $12        ;; 05:4708 ????????
    db   $13, $1a, $22, $13, $1a, $77, $c3, $b1        ;; 05:4710 ????????
    db   $47, $03, $0a, $ea, $67, $df, $e1, $11        ;; 05:4718 ????????
    db   $fe, $ff, $19, $3e, $01, $22, $03, $cd        ;; 05:4720 ????????
    db   $ad, $47, $c3, $b1, $47                       ;; 05:4728 ?????

data_05_472d:
    inc  BC                                            ;; 05:472d $03
    ld   A, [BC]                                       ;; 05:472e $0a
    ldh  [rNR51], A                                    ;; 05:472f $e0 $25
    ld   [wDF79], A                                    ;; 05:4731 $ea $79 $df
    inc  BC                                            ;; 05:4734 $03
    pop  HL                                            ;; 05:4735 $e1
    ld   DE, hFFFE                                     ;; 05:4736 $11 $fe $ff
    add  HL, DE                                        ;; 05:4739 $19
    ld   A, $01                                        ;; 05:473a $3e $01
    ld   [HL+], A                                      ;; 05:473c $22
    call call_05_47ad                                  ;; 05:473d $cd $ad $47
    jr   jp_05_47b1                                    ;; 05:4740 $18 $6f
    db   $03, $fa, $79, $df, $e6, $ee, $67, $0a        ;; 05:4742 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $e2        ;; 05:474a ????????
    db   $03, $fa, $79, $df, $e6, $dd, $67, $0a        ;; 05:4752 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $d2        ;; 05:475a ????????
    db   $03, $fa, $79, $df, $e6, $bb, $67, $0a        ;; 05:4762 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $c2        ;; 05:476a ????????
    db   $03, $fa, $79, $df, $e6, $77, $67, $0a        ;; 05:4772 ????????
    db   $b4, $ea, $79, $df, $e0, $25, $18, $b2        ;; 05:477a ????????
    db   $03, $0a, $ea, $60, $df, $03, $0a, $ea        ;; 05:4782 ????????
    db   $61, $df, $e1, $11, $fe, $ff, $19, $3e        ;; 05:478a ????????
    db   $01, $22, $03, $cd, $ad, $47, $18, $17        ;; 05:4792 ????????

data_05_479a:
    inc  BC                                            ;; 05:479a $03
    ld   A, [BC]                                       ;; 05:479b $0a
    ld   [wDF78], A                                    ;; 05:479c $ea $78 $df
    pop  HL                                            ;; 05:479f $e1
    ld   DE, hFFFE                                     ;; 05:47a0 $11 $fe $ff
    add  HL, DE                                        ;; 05:47a3 $19
    ld   A, $01                                        ;; 05:47a4 $3e $01
    ld   [HL+], A                                      ;; 05:47a6 $22
    inc  BC                                            ;; 05:47a7 $03
    call call_05_47ad                                  ;; 05:47a8 $cd $ad $47
    jr   jp_05_47b1                                    ;; 05:47ab $18 $04

call_05_47ad:
    ld   [HL], C                                       ;; 05:47ad $71
    inc  HL                                            ;; 05:47ae $23
    ld   [HL], B                                       ;; 05:47af $70
    ret                                                ;; 05:47b0 $c9

jp_05_47b1:
    pop  HL                                            ;; 05:47b1 $e1
    ld   DE, wDF62                                     ;; 05:47b2 $11 $62 $df
    ld   A, [DE]                                       ;; 05:47b5 $1a
    ld   L, A                                          ;; 05:47b6 $6f
    inc  DE                                            ;; 05:47b7 $13
    ld   A, [DE]                                       ;; 05:47b8 $1a
    ld   H, A                                          ;; 05:47b9 $67
    jp   HL                                            ;; 05:47ba $e9

data_05_47bb:
    db   $9d, $07, $6b, $ca, $23, $78, $c7, $12        ;; 05:47bb ????????
    db   $59, $9c, $db, $17, $4f, $84, $b6, $e5        ;; 05:47c3 ????????
    db   $12, $3c, $64, $89, $ad, $ce, $ee, $0c        ;; 05:47cb ???.????
    db   $28, $42, $5b, $73, $89, $9e, $b2, $c5        ;; 05:47d3 ????????
    db   $d7, $e7, $f7, $06, $14, $21, $2e, $3a        ;; 05:47db ????.???
    db   $45, $4f, $59, $63, $6c, $74, $7c, $83        ;; 05:47e3 ???.???.
    db   $8a, $91, $97, $9d, $a3, $a8, $ad, $b1        ;; 05:47eb ???.?.?.
    db   $b6, $ba, $be, $c2, $c5, $c9, $cc, $cf        ;; 05:47f3 ?.?.?.?.
    db   $d2, $d4, $d7, $d9, $db, $dd, $df, $e1        ;; 05:47fb ?.?.????
    db   $e3, $e5, $e6, $e8, $e9, $ea, $ec, $ed        ;; 05:4803 ????????
    db   $ee, $ef, $f0, $f1, $f2, $f3, $f3, $f4        ;; 05:480b ????????
    db   $f5, $f5, $f7, $f7, $f8, $f8, $fa, $fa        ;; 05:4813 ????????

data_05_481b:
    db   $00, $01, $01, $01, $02, $02, $02, $03        ;; 05:481b ????????
    db   $03, $03, $03, $04, $04, $04, $04, $04        ;; 05:4823 ????????
    db   $05, $05, $05, $05, $05, $05, $05, $06        ;; 05:482b ???.????
    db   $06, $06, $06, $06, $06, $06, $06, $06        ;; 05:4833 ????????
    db   $06, $06, $06, $07, $07, $07, $07, $07        ;; 05:483b ????.???
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:4843 ???.???.
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:484b ???.?.?.
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:4853 ?.?.?.?.
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:485b ?.?.????
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:4863 ????????
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:486b ????????
    db   $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:4873 ????????
    db   $21, $ed, $49, $cb, $27, $85, $6f, $30        ;; 05:487b ????????
    db   $01, $24, $7e, $4f, $23, $7e, $47, $3e        ;; 05:4883 ????????
    db   $8f, $e0, $26, $0a, $03, $fe, $01, $28        ;; 05:488b ????????
    db   $29, $fe, $02, $28, $46, $fe, $03, $28        ;; 05:4893 ????????
    db   $63, $fa, $79, $df, $57, $3e, $11, $b2        ;; 05:489b ????????
    db   $ea, $7a, $df, $fa, $00, $df, $e6, $fe        ;; 05:48a3 ????????
    db   $ea, $00, $df, $79, $ea, $68, $df, $78        ;; 05:48ab ????????
    db   $ea, $69, $df, $3e, $02, $ea, $6a, $df        ;; 05:48b3 ????????
    db   $18, $61, $fa, $79, $df, $57, $3e, $22        ;; 05:48bb ????????
    db   $b2, $ea, $7a, $df, $fa, $18, $df, $e6        ;; 05:48c3 ????????
    db   $fe, $ea, $18, $df, $79, $ea, $6b, $df        ;; 05:48cb ????????
    db   $78, $ea, $6c, $df, $3e, $02, $ea, $6d        ;; 05:48d3 ????????
    db   $df, $18, $40, $fa, $79, $df, $57, $3e        ;; 05:48db ????????
    db   $44, $b2, $ea, $7a, $df, $fa, $30, $df        ;; 05:48e3 ????????
    db   $e6, $fe, $ea, $30, $df, $79, $ea, $6e        ;; 05:48eb ????????
    db   $df, $78, $ea, $6f, $df, $3e, $02, $ea        ;; 05:48f3 ????????
    db   $70, $df, $18, $1f, $fa, $79, $df, $57        ;; 05:48fb ????????
    db   $3e, $88, $b2, $ea, $7a, $df, $fa, $48        ;; 05:4903 ????????
    db   $df, $e6, $fe, $ea, $48, $df, $79, $ea        ;; 05:490b ????????
    db   $71, $df, $78, $ea, $72, $df, $3e, $02        ;; 05:4913 ????????
    db   $ea, $73, $df                                 ;; 05:491b ???

call_05_491e:
    ld   HL, wDF00                                     ;; 05:491e $21 $00 $df
    ld   A, L                                          ;; 05:4921 $7d
    ld   [wDF74], A                                    ;; 05:4922 $ea $74 $df
    ld   A, H                                          ;; 05:4925 $7c
    ld   [wDF75], A                                    ;; 05:4926 $ea $75 $df
    ld   HL, wDF68                                     ;; 05:4929 $21 $68 $df
    ld   C, [HL]                                       ;; 05:492c $4e
    inc  HL                                            ;; 05:492d $23
    ld   B, [HL]                                       ;; 05:492e $46
    ld   A, B                                          ;; 05:492f $78
    or   A, C                                          ;; 05:4930 $b1
    jr   Z, .jr_05_4939                                ;; 05:4931 $28 $06
    ld   DE, rNR11                                     ;; 05:4933 $11 $11 $ff
    call call_05_498b                                  ;; 05:4936 $cd $8b $49
.jr_05_4939:
    ld   HL, wDF18                                     ;; 05:4939 $21 $18 $df
    ld   A, L                                          ;; 05:493c $7d
    ld   [wDF74], A                                    ;; 05:493d $ea $74 $df
    ld   A, H                                          ;; 05:4940 $7c
    ld   [wDF75], A                                    ;; 05:4941 $ea $75 $df
    ld   HL, wDF6B                                     ;; 05:4944 $21 $6b $df
    ld   C, [HL]                                       ;; 05:4947 $4e
    inc  HL                                            ;; 05:4948 $23
    ld   B, [HL]                                       ;; 05:4949 $46
    ld   A, B                                          ;; 05:494a $78
    or   A, C                                          ;; 05:494b $b1
    jr   Z, .jr_05_4954                                ;; 05:494c $28 $06
    ld   DE, rNR21                                     ;; 05:494e $11 $16 $ff
    call call_05_498b                                  ;; 05:4951 $cd $8b $49
.jr_05_4954:
    ld   HL, wDF30                                     ;; 05:4954 $21 $30 $df
    ld   A, L                                          ;; 05:4957 $7d
    ld   [wDF74], A                                    ;; 05:4958 $ea $74 $df
    ld   A, H                                          ;; 05:495b $7c
    ld   [wDF75], A                                    ;; 05:495c $ea $75 $df
    ld   HL, wDF6E                                     ;; 05:495f $21 $6e $df
    ld   C, [HL]                                       ;; 05:4962 $4e
    inc  HL                                            ;; 05:4963 $23
    ld   B, [HL]                                       ;; 05:4964 $46
    ld   A, B                                          ;; 05:4965 $78
    or   A, C                                          ;; 05:4966 $b1
    jr   Z, .jr_05_496f                                ;; 05:4967 $28 $06
    ld   DE, rNR31                                     ;; 05:4969 $11 $1b $ff
    call call_05_498b                                  ;; 05:496c $cd $8b $49
.jr_05_496f:
    ld   HL, wDF48                                     ;; 05:496f $21 $48 $df
    ld   A, L                                          ;; 05:4972 $7d
    ld   [wDF74], A                                    ;; 05:4973 $ea $74 $df
    ld   A, H                                          ;; 05:4976 $7c
    ld   [wDF75], A                                    ;; 05:4977 $ea $75 $df
    ld   HL, wDF71                                     ;; 05:497a $21 $71 $df
    ld   C, [HL]                                       ;; 05:497d $4e
    inc  HL                                            ;; 05:497e $23
    ld   B, [HL]                                       ;; 05:497f $46
    ld   A, B                                          ;; 05:4980 $78
    or   A, C                                          ;; 05:4981 $b1
    jr   Z, .jr_05_498a                                ;; 05:4982 $28 $06
    ld   DE, rNR41                                     ;; 05:4984 $11 $20 $ff
    call call_05_498b                                  ;; 05:4987 $cd $8b $49
.jr_05_498a:
    ret                                                ;; 05:498a $c9

call_05_498b:
    ld   A, [wDF7A]                                    ;; 05:498b $fa $7a $df
    ldh  [rNR51], A                                    ;; 05:498e $e0 $25
    inc  HL                                            ;; 05:4990 $23
    dec  [HL]                                          ;; 05:4991 $35
    jr   Z, .jr_05_4995                                ;; 05:4992 $28 $01
    ret                                                ;; 05:4994 $c9
.jr_05_4995:
    ld   A, [BC]                                       ;; 05:4995 $0a
    cp   A, $ff                                        ;; 05:4996 $fe $ff
    jr   Z, .jr_05_49b5                                ;; 05:4998 $28 $1b
    cp   A, $fe                                        ;; 05:499a $fe $fe
    jr   Z, .jr_05_49d1                                ;; 05:499c $28 $33
    ld   [HL], A                                       ;; 05:499e $77
    inc  BC                                            ;; 05:499f $03
    ld   A, [BC]                                       ;; 05:49a0 $0a
    ld   [DE], A                                       ;; 05:49a1 $12
    inc  BC                                            ;; 05:49a2 $03
    inc  DE                                            ;; 05:49a3 $13
    ld   A, [BC]                                       ;; 05:49a4 $0a
    ld   [DE], A                                       ;; 05:49a5 $12
    inc  BC                                            ;; 05:49a6 $03
    inc  DE                                            ;; 05:49a7 $13
    inc  DE                                            ;; 05:49a8 $13
    ld   A, [BC]                                       ;; 05:49a9 $0a
    ld   [DE], A                                       ;; 05:49aa $12
    inc  BC                                            ;; 05:49ab $03
    dec  DE                                            ;; 05:49ac $1b
    ld   A, [BC]                                       ;; 05:49ad $0a
    ld   [DE], A                                       ;; 05:49ae $12
    inc  BC                                            ;; 05:49af $03
.jr_05_49b0:
    dec  HL                                            ;; 05:49b0 $2b
    ld   [HL], B                                       ;; 05:49b1 $70
    dec  HL                                            ;; 05:49b2 $2b
    ld   [HL], C                                       ;; 05:49b3 $71
    ret                                                ;; 05:49b4 $c9
.jr_05_49b5:
    ld   A, $00                                        ;; 05:49b5 $3e $00
    dec  HL                                            ;; 05:49b7 $2b
    ld   [HL], A                                       ;; 05:49b8 $77
    dec  HL                                            ;; 05:49b9 $2b
    ld   [HL], A                                       ;; 05:49ba $77
    ld   HL, wDF74                                     ;; 05:49bb $21 $74 $df
    ld   C, [HL]                                       ;; 05:49be $4e
    inc  HL                                            ;; 05:49bf $23
    ld   B, [HL]                                       ;; 05:49c0 $46
    ld   A, [BC]                                       ;; 05:49c1 $0a
    and  A, $02                                        ;; 05:49c2 $e6 $02
    jp   Z, .jp_05_49cb                                ;; 05:49c4 $ca $cb $49
    ld   A, [BC]                                       ;; 05:49c7 $0a
    or   A, $01                                        ;; 05:49c8 $f6 $01
    ld   [BC], A                                       ;; 05:49ca $02
.jp_05_49cb:
    ld   A, [wDF79]                                    ;; 05:49cb $fa $79 $df
    ldh  [rNR51], A                                    ;; 05:49ce $e0 $25
    ret                                                ;; 05:49d0 $c9
.jr_05_49d1:
    inc  BC                                            ;; 05:49d1 $03
    ld   A, [BC]                                       ;; 05:49d2 $0a
    ld   E, A                                          ;; 05:49d3 $5f
    inc  BC                                            ;; 05:49d4 $03
    ld   A, [BC]                                       ;; 05:49d5 $0a
    ld   B, A                                          ;; 05:49d6 $47
    ld   C, E                                          ;; 05:49d7 $4b
    ld   A, $01                                        ;; 05:49d8 $3e $01
    ld   [HL], A                                       ;; 05:49da $77
    jr   .jr_05_49b0                                   ;; 05:49db $18 $d3
    db   $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa        ;; 05:49dd ????????
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 05:49e5 ????????
    db   $1a, $54, $21, $54, $28, $54, $2f, $54        ;; 05:49ed ????????
    db   $d5, $4a, $de, $4a, $fa, $4a, $ec, $4a        ;; 05:49f5 ????????
    db   $35, $4b, $8e, $4b, $ce, $4b, $31, $4c        ;; 05:49fd ????????
    db   $94, $4c, $cf, $4c, $fb, $4c, $09, $4d        ;; 05:4a05 ????????
    db   $3f, $4d, $66, $4d, $b3, $4d, $97, $4d        ;; 05:4a0d ????????
    db   $a0, $4d, $15, $4f, $50, $4f, $8b, $4f        ;; 05:4a15 ????????
    db   $c1, $4f, $ca, $4f, $d3, $4f, $56, $50        ;; 05:4a1d ????????
    db   $40, $50, $64, $50, $9f, $50, $d5, $50        ;; 05:4a25 ????????
    db   $19, $51, $de, $50, $3a, $51, $22, $51        ;; 05:4a2d ????????
    db   $48, $51, $ba, $51, $c3, $51, $d1, $51        ;; 05:4a35 ????????
    db   $02, $52, $10, $52, $32, $52, $40, $52        ;; 05:4a3d ????????
    db   $4e, $52, $70, $52, $79, $52, $96, $52        ;; 05:4a45 ????????
    db   $a4, $52, $2f, $53, $3d, $53, $4b, $53        ;; 05:4a4d ????????
    db   $d6, $53, $df, $53, $00, $01, $02, $03        ;; 05:4a55 ????????
    db   $04, $ff, $ff, $ff, $05, $ff, $ff, $ff        ;; 05:4a5d ????????
    db   $07, $06, $ff, $ff, $08, $ff, $ff, $ff        ;; 05:4a65 ????????
    db   $09, $ff, $ff, $ff, $0a, $ff, $ff, $ff        ;; 05:4a6d ????????
    db   $0b, $0c, $ff, $ff, $0d, $ff, $ff, $ff        ;; 05:4a75 ????????
    db   $0e, $ff, $ff, $ff, $0f, $ff, $ff, $ff        ;; 05:4a7d ????????
    db   $10, $ff, $ff, $ff, $11, $ff, $ff, $ff        ;; 05:4a85 ????????
    db   $12, $13, $14, $ff, $15, $16, $ff, $ff        ;; 05:4a8d ????????
    db   $17, $18, $ff, $ff, $19, $1a, $ff, $ff        ;; 05:4a95 ????????
    db   $1b, $1c, $ff, $ff, $1d, $1e, $1f, $ff        ;; 05:4a9d ????????
    db   $20, $21, $ff, $ff, $22, $23, $ff, $ff        ;; 05:4aa5 ????????
    db   $24, $25, $ff, $ff, $26, $ff, $ff, $ff        ;; 05:4aad ????????
    db   $27, $28, $ff, $ff, $29, $2a, $ff, $ff        ;; 05:4ab5 ????????
    db   $2b, $ff, $ff, $ff, $2c, $2d, $ff, $ff        ;; 05:4abd ????????
    db   $2e, $ff, $ff, $ff, $2f, $ff, $ff, $ff        ;; 05:4ac5 ????????
    db   $30, $31, $32, $ff, $33, $34, $35, $ff        ;; 05:4acd ????????
    db   $01, $23, $80, $84, $87, $cf, $fe, $1b        ;; 05:4ad5 ?.....??
    db   $54, $01, $02, $80, $c1, $87, $8a, $0a        ;; 05:4add ????????
    db   $80, $c1, $87, $a8, $fe, $1b, $54, $03        ;; 05:4ae5 ????????
    db   $02, $00, $f0, $80, $62, $23, $00, $a3        ;; 05:4aed ????????
    db   $80, $47, $fe, $1b, $54, $01, $02, $80        ;; 05:4af5 ????????
    db   $f0, $80, $9d, $02, $80, $70, $87, $d9        ;; 05:4afd ????????
    db   $03, $80, $60, $87, $c5, $02, $80, $50        ;; 05:4b05 ????????
    db   $87, $e6, $01, $80, $40, $87, $d4, $05        ;; 05:4b0d ????????
    db   $80, $40, $87, $e8, $03, $80, $30, $87        ;; 05:4b15 ????????
    db   $ed, $01, $80, $30, $87, $dd, $06, $80        ;; 05:4b1d ????????
    db   $20, $87, $f1, $04, $80, $20, $87, $e3        ;; 05:4b25 ????????
    db   $04, $80, $10, $87, $d7, $fe, $1b, $54        ;; 05:4b2d ????????
    db   $03, $01, $00, $20, $80, $47, $01, $00        ;; 05:4b35 ????????
    db   $30, $80, $46, $01, $00, $40, $80, $45        ;; 05:4b3d ????????
    db   $01, $00, $50, $80, $44, $02, $00, $60        ;; 05:4b45 ????????
    db   $80, $43, $02, $00, $70, $80, $42, $02        ;; 05:4b4d ????????
    db   $00, $80, $80, $35, $02, $00, $80, $80        ;; 05:4b55 ????????
    db   $34, $02, $00, $80, $80, $33, $02, $00        ;; 05:4b5d ????????
    db   $00, $00, $00, $02, $00, $f0, $80, $24        ;; 05:4b65 ????????
    db   $02, $00, $70, $80, $23, $02, $00, $50        ;; 05:4b6d ????????
    db   $80, $24, $02, $00, $40, $80, $24, $02        ;; 05:4b75 ????????
    db   $00, $30, $80, $24, $03, $00, $20, $80        ;; 05:4b7d ????????
    db   $24, $03, $00, $10, $80, $24, $fe, $1b        ;; 05:4b85 ????????
    db   $54, $03, $02, $00, $50, $80, $06, $02        ;; 05:4b8d ????????
    db   $00, $60, $80, $14, $02, $00, $70, $80        ;; 05:4b95 ????????
    db   $21, $02, $00, $80, $80, $23, $02, $00        ;; 05:4b9d ????????
    db   $90, $80, $24, $02, $00, $a0, $80, $32        ;; 05:4ba5 ????????
    db   $02, $00, $b0, $80, $33, $02, $00, $c0        ;; 05:4bad ????????
    db   $80, $34, $01, $00, $00, $00, $00, $02        ;; 05:4bb5 ????????
    db   $00, $f0, $80, $44, $01, $00, $00, $00        ;; 05:4bbd ????????
    db   $00, $02, $00, $d0, $80, $47, $fe, $1b        ;; 05:4bc5 ????????
    db   $54, $01, $04, $80, $f0, $84, $50, $01        ;; 05:4bcd ????????
    db   $80, $f0, $84, $64, $01, $80, $f0, $84        ;; 05:4bd5 ????????
    db   $78, $01, $80, $f0, $84, $8c, $01, $80        ;; 05:4bdd ????????
    db   $f0, $84, $a0, $01, $80, $e0, $84, $b4        ;; 05:4be5 ????????
    db   $01, $80, $d0, $84, $c8, $01, $80, $c0        ;; 05:4bed ????????
    db   $84, $d2, $01, $80, $80, $84, $dc, $01        ;; 05:4bf5 ????????
    db   $80, $80, $84, $e6, $01, $80, $80, $84        ;; 05:4bfd ????????
    db   $f0, $01, $80, $70, $84, $fa, $01, $80        ;; 05:4c05 ????????
    db   $50, $85, $05, $02, $80, $30, $85, $0f        ;; 05:4c0d ????????
    db   $02, $80, $20, $85, $19, $03, $80, $20        ;; 05:4c15 ????????
    db   $85, $23, $03, $80, $10, $85, $2d, $03        ;; 05:4c1d ????????
    db   $80, $10, $85, $37, $03, $80, $10, $85        ;; 05:4c25 ????????
    db   $41, $fe, $1b, $54, $01, $04, $80, $f0        ;; 05:4c2d ????????
    db   $82, $00, $02, $80, $f0, $82, $1e, $02        ;; 05:4c35 ????????
    db   $80, $f0, $82, $3c, $02, $80, $f0, $82        ;; 05:4c3d ????????
    db   $5a, $02, $80, $f0, $82, $78, $02, $80        ;; 05:4c45 ????????
    db   $e0, $82, $96, $01, $80, $d0, $82, $b4        ;; 05:4c4d ????????
    db   $01, $80, $c0, $82, $d2, $01, $80, $80        ;; 05:4c55 ????????
    db   $82, $f0, $01, $80, $80, $83, $0f, $01        ;; 05:4c5d ????????
    db   $80, $80, $82, $2d, $01, $80, $70, $82        ;; 05:4c65 ????????
    db   $4b, $01, $80, $50, $82, $69, $02, $80        ;; 05:4c6d ????????
    db   $30, $82, $87, $02, $80, $20, $82, $a5        ;; 05:4c75 ????????
    db   $03, $80, $20, $82, $c3, $03, $80, $10        ;; 05:4c7d ????????
    db   $82, $e1, $03, $80, $10, $82, $fa, $03        ;; 05:4c85 ????????
    db   $80, $10, $82, $ff, $fe, $1b, $54, $00        ;; 05:4c8d ????????
    db   $04, $80, $f0, $82, $01, $02, $80, $f0        ;; 05:4c95 ????????
    db   $82, $1f, $02, $80, $f0, $82, $3d, $02        ;; 05:4c9d ????????
    db   $80, $f0, $82, $5b, $02, $80, $f0, $82        ;; 05:4ca5 ????????
    db   $79, $02, $80, $e0, $82, $97, $01, $80        ;; 05:4cad ????????
    db   $d0, $82, $b5, $01, $80, $c0, $82, $d3        ;; 05:4cb5 ????????
    db   $01, $80, $80, $82, $f1, $01, $80, $80        ;; 05:4cbd ????????
    db   $83, $10, $01, $80, $80, $82, $2e, $fe        ;; 05:4cc5 ????????
    db   $1b, $54, $03, $04, $00, $f0, $80, $61        ;; 05:4ccd ????????
    db   $01, $00, $70, $80, $35, $01, $00, $60        ;; 05:4cd5 ????????
    db   $80, $47, $01, $00, $50, $80, $34, $01        ;; 05:4cdd ????????
    db   $00, $40, $80, $46, $01, $00, $30, $80        ;; 05:4ce5 ????????
    db   $33, $01, $00, $20, $80, $45, $02, $00        ;; 05:4ced ????????
    db   $10, $80, $32, $fe, $1b, $54, $03, $14        ;; 05:4cf5 ????????
    db   $00, $1a, $80, $22, $3c, $00, $f4, $80        ;; 05:4cfd ????????
    db   $22, $fe, $1b, $54, $01, $02, $80, $f0        ;; 05:4d05 ????????
    db   $85, $c8, $01, $80, $f0, $85, $b4, $01        ;; 05:4d0d ????????
    db   $80, $f0, $85, $a0, $01, $80, $f0, $85        ;; 05:4d15 ????????
    db   $8c, $01, $80, $e0, $85, $78, $01, $80        ;; 05:4d1d ????????
    db   $e0, $85, $64, $01, $80, $d0, $85, $50        ;; 05:4d25 ????????
    db   $01, $80, $d0, $85, $3c, $01, $80, $c0        ;; 05:4d2d ????????
    db   $85, $28, $01, $80, $c0, $85, $14, $fe        ;; 05:4d35 ????????
    db   $1b, $54, $01, $02, $80, $f0, $87, $8c        ;; 05:4d3d ????????
    db   $01, $80, $e0, $87, $87, $01, $80, $c0        ;; 05:4d45 ????????
    db   $87, $82, $01, $80, $a0, $87, $7d, $01        ;; 05:4d4d ????????
    db   $80, $80, $87, $78, $01, $80, $50, $87        ;; 05:4d55 ????????
    db   $73, $01, $80, $30, $87, $6e, $fe, $1b        ;; 05:4d5d ????????
    db   $54, $03, $01, $00, $c0, $80, $44, $01        ;; 05:4d65 ????????
    db   $00, $d0, $80, $43, $01, $00, $e0, $80        ;; 05:4d6d ????????
    db   $44, $01, $00, $f0, $80, $43, $01, $00        ;; 05:4d75 ????????
    db   $f0, $80, $44, $01, $00, $f0, $80, $43        ;; 05:4d7d ????????
    db   $02, $00, $00, $00, $00, $01, $00, $f0        ;; 05:4d85 ????????
    db   $80, $23, $06, $00, $51, $80, $23, $fe        ;; 05:4d8d ????????
    db   $1b, $54, $00, $46, $80, $f4, $82, $23        ;; 05:4d95 ????????
    db   $fe, $1b, $54, $02, $1e, $00, $20, $84        ;; 05:4d9d ????????
    db   $e5, $1e, $00, $40, $84, $e5, $0a, $00        ;; 05:4da5 ????????
    db   $60, $84, $e5, $fe, $1b, $54, $01, $01        ;; 05:4dad ????????
    db   $80, $40, $87, $dc, $01, $80, $50, $87        ;; 05:4db5 ????????
    db   $dd, $01, $80, $60, $87, $de, $01, $80        ;; 05:4dbd ????????
    db   $70, $87, $df, $01, $80, $80, $87, $e0        ;; 05:4dc5 ????????
    db   $01, $80, $50, $87, $d9, $01, $80, $60        ;; 05:4dcd ????????
    db   $87, $da, $01, $80, $70, $87, $db, $01        ;; 05:4dd5 ????????
    db   $80, $80, $87, $dc, $01, $80, $90, $87        ;; 05:4ddd ????????
    db   $dd, $01, $80, $30, $87, $d6, $01, $80        ;; 05:4de5 ????????
    db   $40, $87, $d7, $01, $80, $50, $87, $d8        ;; 05:4ded ????????
    db   $01, $80, $60, $87, $d9, $01, $80, $70        ;; 05:4df5 ????????
    db   $87, $da, $01, $80, $40, $87, $df, $01        ;; 05:4dfd ????????
    db   $80, $50, $87, $e0, $01, $80, $60, $87        ;; 05:4e05 ????????
    db   $e1, $01, $80, $70, $87, $e2, $01, $80        ;; 05:4e0d ????????
    db   $80, $87, $e3, $01, $80, $20, $87, $d4        ;; 05:4e15 ????????
    db   $01, $80, $30, $87, $d5, $01, $80, $40        ;; 05:4e1d ????????
    db   $87, $d6, $01, $80, $50, $87, $d7, $01        ;; 05:4e25 ????????
    db   $80, $60, $87, $d8, $01, $80, $40, $87        ;; 05:4e2d ????????
    db   $da, $01, $80, $50, $87, $db, $01, $80        ;; 05:4e35 ????????
    db   $60, $87, $dc, $01, $80, $70, $87, $dd        ;; 05:4e3d ????????
    db   $01, $80, $80, $87, $de, $01, $80, $50        ;; 05:4e45 ????????
    db   $87, $df, $01, $80, $60, $87, $e0, $01        ;; 05:4e4d ????????
    db   $80, $70, $87, $e1, $01, $80, $80, $87        ;; 05:4e55 ????????
    db   $e2, $01, $80, $90, $87, $e3, $01, $80        ;; 05:4e5d ????????
    db   $20, $87, $d3, $01, $80, $30, $87, $d4        ;; 05:4e65 ????????
    db   $01, $80, $40, $87, $d5, $01, $80, $50        ;; 05:4e6d ????????
    db   $87, $d6, $01, $80, $60, $87, $d7, $01        ;; 05:4e75 ????????
    db   $80, $20, $87, $d9, $01, $80, $30, $87        ;; 05:4e7d ????????
    db   $da, $01, $80, $40, $87, $db, $01, $80        ;; 05:4e85 ????????
    db   $50, $87, $dc, $01, $80, $70, $87, $dd        ;; 05:4e8d ????????
    db   $01, $80, $20, $87, $d0, $01, $80, $30        ;; 05:4e95 ????????
    db   $87, $d1, $01, $80, $40, $87, $d2, $01        ;; 05:4e9d ????????
    db   $80, $50, $87, $d3, $01, $80, $60, $87        ;; 05:4ea5 ????????
    db   $d4, $01, $80, $40, $87, $d4, $01, $80        ;; 05:4ead ????????
    db   $50, $87, $d5, $01, $80, $60, $87, $d6        ;; 05:4eb5 ????????
    db   $01, $80, $50, $87, $d7, $01, $80, $40        ;; 05:4ebd ????????
    db   $87, $d8, $01, $80, $20, $87, $cd, $01        ;; 05:4ec5 ????????
    db   $80, $30, $87, $ce, $01, $80, $40, $87        ;; 05:4ecd ????????
    db   $cf, $01, $80, $50, $87, $d0, $01, $80        ;; 05:4ed5 ????????
    db   $60, $87, $d1, $01, $80, $20, $87, $d9        ;; 05:4edd ????????
    db   $01, $80, $30, $87, $da, $01, $80, $40        ;; 05:4ee5 ????????
    db   $87, $db, $01, $80, $50, $87, $dc, $01        ;; 05:4eed ????????
    db   $80, $60, $87, $dd, $01, $80, $20, $87        ;; 05:4ef5 ????????
    db   $c8, $01, $80, $30, $87, $c9, $01, $80        ;; 05:4efd ????????
    db   $40, $87, $ca, $01, $80, $50, $87, $cb        ;; 05:4f05 ????????
    db   $01, $80, $40, $87, $cc, $fe, $1b, $54        ;; 05:4f0d ????????
    db   $00, $05, $40, $10, $82, $37, $05, $40        ;; 05:4f15 ????????
    db   $20, $82, $3c, $05, $40, $40, $82, $41        ;; 05:4f1d ????????
    db   $05, $40, $80, $82, $46, $05, $40, $a0        ;; 05:4f25 ????????
    db   $82, $4b, $05, $40, $b0, $82, $50, $05        ;; 05:4f2d ????????
    db   $40, $c0, $82, $55, $05, $40, $d0, $82        ;; 05:4f35 ????????
    db   $5a, $05, $40, $e0, $82, $5f, $05, $40        ;; 05:4f3d ????????
    db   $f0, $82, $64, $5a, $40, $f7, $82, $69        ;; 05:4f45 ????????
    db   $fe, $1b, $54, $01, $05, $40, $10, $82        ;; 05:4f4d ????????
    db   $3a, $05, $40, $20, $82, $3f, $05, $40        ;; 05:4f55 ????????
    db   $40, $82, $44, $05, $40, $80, $82, $49        ;; 05:4f5d ????????
    db   $05, $40, $a0, $82, $4e, $05, $40, $b0        ;; 05:4f65 ????????
    db   $82, $53, $05, $40, $c0, $82, $58, $05        ;; 05:4f6d ????????
    db   $40, $d0, $82, $5d, $05, $40, $e0, $82        ;; 05:4f75 ????????
    db   $62, $05, $40, $f0, $82, $67, $5a, $40        ;; 05:4f7d ????????
    db   $f7, $82, $6c, $fe, $1b, $54, $01, $02        ;; 05:4f85 ????????
    db   $80, $f0, $85, $c8, $01, $80, $a0, $85        ;; 05:4f8d ????????
    db   $be, $01, $80, $90, $85, $b4, $01, $80        ;; 05:4f95 ????????
    db   $80, $85, $aa, $01, $80, $70, $85, $a0        ;; 05:4f9d ????????
    db   $01, $80, $60, $85, $96, $01, $80, $50        ;; 05:4fa5 ????????
    db   $85, $8c, $01, $80, $40, $85, $82, $01        ;; 05:4fad ????????
    db   $80, $30, $85, $78, $01, $80, $20, $85        ;; 05:4fb5 ????????
    db   $64, $fe, $1b, $54, $03, $0c, $00, $72        ;; 05:4fbd ????????
    db   $80, $47, $fe, $1b, $54, $00, $0a, $00        ;; 05:4fc5 ????????
    db   $00, $00, $00, $fe, $d4, $4f, $01, $05        ;; 05:4fcd ????????
    db   $80, $f0, $85, $c8, $05, $80, $f0, $85        ;; 05:4fd5 ????????
    db   $96, $05, $80, $e0, $85, $64, $05, $80        ;; 05:4fdd ????????
    db   $e0, $85, $32, $05, $80, $d0, $84, $fa        ;; 05:4fe5 ????????
    db   $05, $80, $d0, $84, $c8, $05, $80, $c0        ;; 05:4fed ????????
    db   $84, $96, $05, $80, $b0, $84, $64, $05        ;; 05:4ff5 ????????
    db   $80, $a0, $84, $32, $05, $80, $a0, $84        ;; 05:4ffd ????????
    db   $00, $05, $80, $90, $83, $c8, $05, $80        ;; 05:5005 ????????
    db   $80, $83, $96, $05, $80, $70, $83, $64        ;; 05:500d ????????
    db   $05, $80, $70, $83, $32, $05, $80, $60        ;; 05:5015 ????????
    db   $83, $00, $05, $80, $50, $82, $c8, $05        ;; 05:501d ????????
    db   $80, $40, $82, $96, $05, $80, $30, $82        ;; 05:5025 ????????
    db   $64, $05, $80, $20, $82, $32, $05, $80        ;; 05:502d ????????
    db   $20, $82, $00, $05, $80, $10, $81, $c8        ;; 05:5035 ????????
    db   $fe, $1b, $54, $03, $01, $00, $f0, $80        ;; 05:503d ????????
    db   $23, $01, $00, $20, $80, $23, $03, $00        ;; 05:5045 ????????
    db   $f1, $80, $61, $28, $00, $65, $80, $61        ;; 05:504d ????????
    db   $ff, $01, $02, $80, $f0, $80, $9d, $02        ;; 05:5055 ????????
    db   $80, $44, $80, $9d, $fe, $1b, $54, $00        ;; 05:505d ????????
    db   $01, $00, $00, $00, $00, $02, $40, $10        ;; 05:5065 ????????
    db   $80, $64, $02, $00, $10, $81, $c8, $02        ;; 05:506d ????????
    db   $40, $20, $80, $64, $02, $00, $40, $81        ;; 05:5075 ????????
    db   $c8, $02, $40, $60, $80, $64, $02, $00        ;; 05:507d ????????
    db   $80, $81, $c8, $02, $40, $a0, $80, $64        ;; 05:5085 ????????
    db   $02, $00, $c0, $81, $c8, $02, $40, $e0        ;; 05:508d ????????
    db   $80, $64, $14, $00, $f5, $80, $64, $fe        ;; 05:5095 ????????
    db   $1b, $54, $01, $02, $40, $10, $80, $67        ;; 05:509d ????????
    db   $02, $00, $10, $81, $cb, $02, $40, $20        ;; 05:50a5 ????????
    db   $80, $67, $02, $00, $40, $81, $cb, $02        ;; 05:50ad ????????
    db   $40, $60, $80, $67, $02, $00, $80, $81        ;; 05:50b5 ????????
    db   $cb, $02, $40, $a0, $80, $67, $02, $00        ;; 05:50bd ????????
    db   $c0, $81, $cb, $02, $40, $e0, $80, $67        ;; 05:50c5 ????????
    db   $14, $00, $f5, $80, $67, $fe, $1b, $54        ;; 05:50cd ????????
    db   $03, $08, $00, $f1, $80, $64, $fe, $1b        ;; 05:50d5 ????????
    db   $54, $03, $08, $00, $f0, $80, $62, $14        ;; 05:50dd ????????
    db   $00, $a5, $80, $61, $07, $00, $10, $80        ;; 05:50e5 ????????
    db   $5f, $06, $00, $20, $80, $60, $05, $00        ;; 05:50ed ????????
    db   $30, $80, $5f, $05, $00, $40, $80, $46        ;; 05:50f5 ????????
    db   $05, $00, $50, $80, $45, $04, $00, $60        ;; 05:50fd ????????
    db   $80, $44, $05, $00, $70, $80, $43, $06        ;; 05:5105 ????????
    db   $00, $80, $80, $42, $50, $00, $97, $80        ;; 05:510d ????????
    db   $41, $fe, $1b, $54, $01, $28, $80, $f5        ;; 05:5115 ????????
    db   $80, $9d, $fe, $1b, $54, $03, $01, $00        ;; 05:511d ????????
    db   $f0, $80, $44, $01, $00, $20, $80, $44        ;; 05:5125 ????????
    db   $03, $00, $f1, $80, $47, $50, $00, $67        ;; 05:512d ????????
    db   $80, $46, $fe, $1b, $54, $01, $02, $80        ;; 05:5135 ????????
    db   $f0, $80, $9d, $02, $80, $45, $80, $9d        ;; 05:513d ????????
    db   $fe, $1b, $54, $01, $02, $80, $f0, $80        ;; 05:5145 ????????
    db   $64, $01, $80, $e0, $87, $d7, $02, $80        ;; 05:514d ????????
    db   $d0, $87, $c8, $03, $80, $c0, $87, $b4        ;; 05:5155 ????????
    db   $02, $80, $b0, $87, $df, $02, $80, $a0        ;; 05:515d ????????
    db   $87, $d4, $01, $80, $90, $87, $e6, $01        ;; 05:5165 ????????
    db   $80, $80, $87, $cc, $02, $80, $70, $87        ;; 05:516d ????????
    db   $ba, $02, $80, $60, $87, $df, $01, $80        ;; 05:5175 ????????
    db   $50, $87, $c3, $02, $80, $40, $87, $e3        ;; 05:517d ????????
    db   $02, $80, $30, $87, $c3, $01, $80, $20        ;; 05:5185 ????????
    db   $87, $e3, $03, $80, $20, $87, $d1, $02        ;; 05:518d ????????
    db   $80, $20, $87, $de, $03, $80, $20, $87        ;; 05:5195 ????????
    db   $d7, $02, $80, $10, $87, $d4, $03, $80        ;; 05:519d ????????
    db   $10, $87, $e2, $01, $80, $10, $87, $d5        ;; 05:51a5 ????????
    db   $03, $80, $10, $87, $e5, $02, $80, $10        ;; 05:51ad ????????
    db   $87, $d3, $fe, $1b, $54, $00, $02, $80        ;; 05:51b5 ????????
    db   $f0, $80, $64, $fe, $1b, $54, $03, $01        ;; 05:51bd ????????
    db   $3c, $f0, $c0, $23, $01, $3c, $f0, $c0        ;; 05:51c5 ????????
    db   $21, $fe, $1b, $54, $03, $01, $00, $f0        ;; 05:51cd ????????
    db   $80, $45, $0a, $00, $92, $80, $62, $03        ;; 05:51d5 ????????
    db   $00, $00, $00, $00, $01, $00, $f0, $80        ;; 05:51dd ????????
    db   $44, $01, $00, $40, $80, $44, $01, $00        ;; 05:51e5 ????????
    db   $20, $80, $44, $01, $00, $20, $80, $44        ;; 05:51ed ????????
    db   $01, $00, $10, $80, $44, $06, $00, $10        ;; 05:51f5 ????????
    db   $80, $62, $fe, $1b, $54, $01, $01, $00        ;; 05:51fd ????????
    db   $00, $00, $00, $0a, $00, $0a, $87, $e3        ;; 05:5205 ????????
    db   $fe, $1b, $54, $03, $08, $00, $0b, $80        ;; 05:520d ????????
    db   $61, $01, $00, $f0, $80, $44, $0a, $00        ;; 05:5215 ????????
    db   $52, $80, $61, $03, $00, $00, $00, $00        ;; 05:521d ????????
    db   $14, $00, $0b, $80, $14, $28, $00, $67        ;; 05:5225 ????????
    db   $80, $14, $fe, $1b, $54, $01, $09, $00        ;; 05:522d ????????
    db   $00, $00, $00, $0a, $00, $0a, $87, $e3        ;; 05:5235 ????????
    db   $fe, $1b, $54, $03, $03, $00, $f1, $80        ;; 05:523d ????????
    db   $63, $1e, $00, $a3, $80, $62, $fe, $1b        ;; 05:5245 ????????
    db   $54, $03, $05, $00, $f2, $80, $62, $05        ;; 05:524d ????????
    db   $00, $f2, $80, $64, $05, $00, $f2, $80        ;; 05:5255 ????????
    db   $63, $05, $00, $f2, $80, $62, $64, $00        ;; 05:525d ????????
    db   $f7, $80, $62, $14, $00, $10, $80, $62        ;; 05:5265 ????????
    db   $fe, $1b, $54, $01, $03, $80, $f0, $81        ;; 05:526d ????????
    db   $c8, $fe, $1b, $54, $01, $01, $80, $50        ;; 05:5275 ????????
    db   $87, $c5, $01, $80, $a0, $87, $8a, $01        ;; 05:527d ????????
    db   $80, $50, $87, $c5, $01, $80, $a0, $87        ;; 05:5285 ????????
    db   $8a, $32, $80, $a6, $87, $be, $fe, $1b        ;; 05:528d ????????
    db   $54, $01, $02, $bc, $f0, $c7, $c5, $03        ;; 05:5295 ????????
    db   $bc, $f0, $c7, $8a, $fe, $1b, $54, $03        ;; 05:529d ????????
    db   $05, $00, $20, $80, $66, $05, $00, $30        ;; 05:52a5 ????????
    db   $80, $65, $05, $00, $40, $80, $64, $05        ;; 05:52ad ????????
    db   $00, $50, $80, $63, $05, $00, $60, $80        ;; 05:52b5 ????????
    db   $62, $05, $00, $70, $80, $61, $05, $00        ;; 05:52bd ????????
    db   $80, $80, $60, $05, $00, $90, $80, $47        ;; 05:52c5 ????????
    db   $05, $00, $a0, $80, $46, $05, $00, $b0        ;; 05:52cd ????????
    db   $80, $45, $05, $00, $c0, $80, $44, $05        ;; 05:52d5 ????????
    db   $00, $d0, $80, $43, $05, $00, $e0, $80        ;; 05:52dd ????????
    db   $42, $05, $00, $f0, $80, $35, $05, $00        ;; 05:52e5 ????????
    db   $e0, $80, $34, $05, $00, $d0, $80, $33        ;; 05:52ed ????????
    db   $05, $00, $c0, $80, $32, $05, $00, $b0        ;; 05:52f5 ????????
    db   $80, $24, $05, $00, $a0, $80, $23, $05        ;; 05:52fd ????????
    db   $00, $90, $80, $22, $06, $00, $80, $80        ;; 05:5305 ????????
    db   $21, $07, $00, $70, $80, $20, $07, $00        ;; 05:530d ????????
    db   $60, $80, $14, $07, $00, $40, $80, $07        ;; 05:5315 ????????
    db   $07, $00, $30, $80, $06, $07, $00, $20        ;; 05:531d ????????
    db   $80, $05, $07, $00, $10, $80, $04, $fe        ;; 05:5325 ????????
    db   $1b, $54, $01, $14, $00, $0a, $80, $32        ;; 05:532d ????????
    db   $5a, $00, $f7, $80, $32, $fe, $1b, $54        ;; 05:5335 ????????
    db   $00, $14, $00, $0a, $80, $37, $5a, $00        ;; 05:533d ????????
    db   $f7, $80, $37, $fe, $1b, $54, $00, $08        ;; 05:5345 ????????
    db   $80, $c1, $87, $8a, $08, $80, $c1, $87        ;; 05:534d ????????
    db   $a3, $08, $80, $c1, $87, $b1, $08, $80        ;; 05:5355 ????????
    db   $c1, $87, $be, $08, $80, $c1, $87, $a8        ;; 05:535d ????????
    db   $08, $80, $c1, $87, $97, $08, $80, $c1        ;; 05:5365 ????????
    db   $87, $6c, $08, $80, $c1, $87, $8a, $08        ;; 05:536d ????????
    db   $80, $c1, $87, $9d, $08, $80, $c1, $87        ;; 05:5375 ????????
    db   $97, $08, $80, $c1, $87, $83, $08, $80        ;; 05:537d ????????
    db   $c1, $87, $63, $08, $80, $c1, $87, $4f        ;; 05:5385 ????????
    db   $08, $80, $c1, $87, $74, $08, $80, $c1        ;; 05:538d ????????
    db   $87, $8a, $08, $80, $c1, $87, $7c, $08        ;; 05:5395 ????????
    db   $80, $c1, $87, $63, $08, $80, $c1, $87        ;; 05:539d ????????
    db   $3a, $08, $80, $c1, $87, $2e, $08, $80        ;; 05:53a5 ????????
    db   $c1, $87, $4f, $08, $80, $c1, $87, $74        ;; 05:53ad ????????
    db   $08, $80, $c1, $87, $63, $08, $80, $c1        ;; 05:53b5 ????????
    db   $87, $45, $08, $80, $c1, $87, $14, $18        ;; 05:53bd ????????
    db   $80, $c5, $84, $4f, $18, $80, $c5, $86        ;; 05:53c5 ????????
    db   $28, $3c, $80, $c7, $87, $14, $fe, $1b        ;; 05:53cd ????????
    db   $54, $01, $08, $00, $00, $00, $00, $fe        ;; 05:53d5 ????????
    db   $4c, $53, $02, $18, $00, $20, $86, $28        ;; 05:53dd ????????
    db   $18, $00, $20, $85, $ee, $18, $00, $20        ;; 05:53e5 ????????
    db   $85, $ad, $18, $00, $20, $85, $89, $18        ;; 05:53ed ????????
    db   $00, $20, $85, $3c, $18, $00, $20, $84        ;; 05:53f5 ????????
    db   $e5, $18, $00, $20, $84, $b6, $18, $00        ;; 05:53fd ????????
    db   $20, $84, $4f, $18, $00, $20, $80, $9d        ;; 05:5405 ????????
    db   $18, $00, $40, $84, $4f, $30, $00, $60        ;; 05:540d ????????
    db   $86, $28, $fe, $1b, $54, $00, $01, $00        ;; 05:5415 ????????
    db   $00, $00, $00, $ff, $01, $01, $00, $00        ;; 05:541d ???.????
    db   $00, $00, $ff, $02, $01, $00, $00, $00        ;; 05:5425 ????????
    db   $00, $ff, $03, $01, $00, $00, $00, $00        ;; 05:542d ????????
    db   $ff, $67, $ff, $69, $ff, $24, $00, $66        ;; 05:5435 .???????
    db   $01, $61, $24, $00, $61, $24, $00, $61        ;; 05:543d ????????
    db   $24, $00, $61, $67, $ff, $69, $cd, $64        ;; 05:5445 ????????
    db   $0b, $e5, $02, $64, $0c, $e5, $01, $64        ;; 05:544d ????????
    db   $0d, $e5, $02, $64, $0e, $e5, $01, $64        ;; 05:5455 ????????
    db   $00, $00, $02, $64, $0f, $e5, $02, $64        ;; 05:545d ????????
    db   $10, $e5, $01, $64, $11, $e5, $02, $64        ;; 05:5465 ????????
    db   $12, $e5, $02, $66, $01, $62, $48, $54        ;; 05:546d ????????
    db   $64, $13, $e5, $02, $64, $14, $e5, $01        ;; 05:5475 ????????
    db   $64, $15, $cd, $02, $64, $16, $e5, $04        ;; 05:547d ????????
    db   $64, $16, $e7, $07, $64, $17, $e5, $02        ;; 05:5485 ????????
    db   $64, $18, $e5, $06, $64, $19, $e5, $01        ;; 05:548d ????????
    db   $64, $18, $e5, $06, $64, $19, $e5, $01        ;; 05:5495 ????????
    db   $62, $75, $54, $64, $04, $f1, $02, $64        ;; 05:549d ????????
    db   $05, $f1, $01, $64, $06, $f1, $08, $64        ;; 05:54a5 ????????
    db   $07, $f1, $02, $64, $07, $f3, $03, $64        ;; 05:54ad ????????
    db   $08, $f3, $01, $64, $09, $f1, $02, $64        ;; 05:54b5 ????????
    db   $0a, $f1, $08, $62, $a0, $54, $64, $01        ;; 05:54bd ????????
    db   $00, $04, $64, $02, $00, $01, $64, $03        ;; 05:54c5 ????????
    db   $00, $18, $64, $01, $00, $01, $62, $c3        ;; 05:54cd ????????
    db   $54, $24, $0a, $65, $32, $88, $2e, $86        ;; 05:54d5 ????????
    db   $32, $86, $01, $84, $35, $82, $31, $82        ;; 05:54dd ????????
    db   $35, $84, $31, $84, $35, $84, $31, $84        ;; 05:54e5 ????????
    db   $35, $84, $31, $84, $32, $88, $2e, $86        ;; 05:54ed ????????
    db   $32, $86, $24, $04, $35, $82, $38, $82        ;; 05:54f5 ????????
    db   $35, $84, $38, $84, $35, $84, $38, $84        ;; 05:54fd ????????
    db   $35, $84, $38, $84, $65, $24, $0a, $24        ;; 05:5505 ????????
    db   $0a, $24, $84, $25, $84, $26, $85, $27        ;; 05:550d ????????
    db   $84, $28, $82, $29, $82, $2a, $82, $2b        ;; 05:5515 ????????
    db   $82, $2c, $82, $2d, $84, $24, $84, $25        ;; 05:551d ????????
    db   $84, $26, $84, $27, $84, $26, $82, $27        ;; 05:5525 ????????
    db   $82, $26, $84, $26, $84, $26, $84, $65        ;; 05:552d ????????
    db   $43, $d2, $42, $d2, $43, $d2, $45, $d2        ;; 05:5535 ????????
    db   $46, $d2, $45, $d2, $46, $d2, $48, $d2        ;; 05:553d ????????
    db   $49, $d2, $48, $d2, $49, $d2, $4b, $d2        ;; 05:5545 ????????
    db   $4c, $d2, $4b, $d2, $4c, $d2, $4e, $d2        ;; 05:554d ????????
    db   $4f, $d2, $4e, $d2, $4f, $d2, $51, $d2        ;; 05:5555 ????????
    db   $52, $d2, $51, $d2, $52, $d2, $54, $d2        ;; 05:555d ????????
    db   $55, $d2, $54, $d2, $55, $d2, $57, $d2        ;; 05:5565 ????????
    db   $58, $d2, $57, $d2, $58, $d2, $5a, $d2        ;; 05:556d ????????
    db   $5b, $d2, $5a, $d2, $5b, $d2, $5a, $d2        ;; 05:5575 ????????
    db   $58, $d2, $57, $d2, $58, $d2, $57, $d2        ;; 05:557d ????????
    db   $55, $d2, $54, $d2, $55, $d2, $54, $d2        ;; 05:5585 ????????
    db   $52, $d2, $54, $d2, $52, $d2, $51, $d2        ;; 05:558d ????????
    db   $4f, $d2, $4e, $d2, $4f, $d2, $4e, $d2        ;; 05:5595 ????????
    db   $4c, $d2, $4b, $d2, $4c, $d2, $4b, $d2        ;; 05:559d ????????
    db   $49, $d2, $48, $d2, $49, $d2, $48, $d2        ;; 05:55a5 ????????
    db   $46, $d2, $48, $d2, $46, $d2, $45, $d2        ;; 05:55ad ????????
    db   $65, $30, $d2, $31, $d2, $32, $d2, $33        ;; 05:55b5 ????????
    db   $d2, $34, $d2, $35, $d2, $36, $d2, $37        ;; 05:55bd ????????
    db   $d2, $38, $d2, $39, $d2, $3a, $d2, $3b        ;; 05:55c5 ????????
    db   $d2, $3c, $d2, $3b, $d2, $3c, $d2, $3b        ;; 05:55cd ????????
    db   $d2, $3c, $d2, $3b, $d2, $3a, $d2, $39        ;; 05:55d5 ????????
    db   $d2, $38, $d2, $37, $d2, $36, $d2, $35        ;; 05:55dd ????????
    db   $d2, $34, $d2, $33, $d2, $32, $d2, $33        ;; 05:55e5 ????????
    db   $d2, $34, $d2, $33, $d2, $32, $d2, $31        ;; 05:55ed ????????
    db   $d2, $65, $32, $d2, $32, $d4, $32, $d2        ;; 05:55f5 ????????
    db   $32, $d4, $32, $d2, $32, $d4, $32, $d2        ;; 05:55fd ????????
    db   $32, $d4, $33, $d4, $33, $d4, $32, $d2        ;; 05:5605 ????????
    db   $32, $d4, $32, $d2, $32, $d4, $32, $d2        ;; 05:560d ????????
    db   $32, $d4, $32, $d2, $32, $d4, $34, $d4        ;; 05:5615 ????????
    db   $34, $d4, $65, $37, $d2, $36, $d2, $37        ;; 05:561d ????????
    db   $d2, $38, $d2, $39, $d2, $3a, $d2, $39        ;; 05:5625 ????????
    db   $d2, $38, $d2, $37, $d2, $36, $d2, $37        ;; 05:562d ????????
    db   $d2, $38, $d2, $39, $d2, $3a, $d2, $39        ;; 05:5635 ????????
    db   $d2, $38, $d2, $65, $3a, $98, $3c, $96        ;; 05:563d ????????
    db   $3e, $96, $39, $9a, $65, $37, $98, $32        ;; 05:5645 ????????
    db   $96, $37, $96, $35, $9a, $37, $98, $32        ;; 05:564d ????????
    db   $96, $37, $96, $38, $9a, $65, $4f, $86        ;; 05:5655 ????????
    db   $37, $82, $37, $82, $37, $82, $37, $82        ;; 05:565d ????????
    db   $49, $88, $4f, $86, $37, $82, $37, $82        ;; 05:5665 ????????
    db   $37, $82, $37, $82, $4d, $88, $4f, $86        ;; 05:566d ????????
    db   $37, $82, $37, $82, $37, $82, $37, $82        ;; 05:5675 ????????
    db   $49, $88, $4f, $86, $37, $82, $37, $82        ;; 05:567d ????????
    db   $37, $82, $37, $82, $49, $88, $65, $43        ;; 05:5685 ????????
    db   $d2, $42, $d2, $43, $d2, $45, $d2, $46        ;; 05:568d ????????
    db   $d2, $45, $d2, $46, $d2, $48, $d2, $49        ;; 05:5695 ????????
    db   $d2, $48, $d2, $49, $d2, $4b, $d2, $4c        ;; 05:569d ????????
    db   $d2, $4b, $d2, $4c, $d2, $4b, $d2, $49        ;; 05:56a5 ????????
    db   $d2, $48, $d2, $49, $d2, $48, $d2, $46        ;; 05:56ad ????????
    db   $d2, $45, $d2, $46, $d2, $45, $d2, $43        ;; 05:56b5 ????????
    db   $d2, $42, $d2, $43, $d2, $42, $d2, $40        ;; 05:56bd ????????
    db   $d2, $3f, $d2, $3d, $d2, $3c, $d2, $3a        ;; 05:56c5 ????????
    db   $d2, $39, $d2, $3a, $d2, $3c, $d2, $3d        ;; 05:56cd ????????
    db   $d2, $3c, $d2, $3d, $d2, $3f, $d2, $40        ;; 05:56d5 ????????
    db   $d2, $3f, $d2, $40, $d2, $42, $d2, $43        ;; 05:56dd ????????
    db   $d2, $42, $d2, $43, $d2, $45, $d2, $46        ;; 05:56e5 ????????
    db   $d2, $45, $d2, $46, $d2, $45, $d2, $43        ;; 05:56ed ????????
    db   $d2, $42, $d2, $43, $d2, $42, $d2, $40        ;; 05:56f5 ????????
    db   $d2, $3f, $d2, $40, $d2, $3f, $d2, $3d        ;; 05:56fd ????????
    db   $d2, $3c, $d2, $3d, $d2, $3c, $d2, $65        ;; 05:5705 ????????
    db   $3c, $98, $3f, $96, $42, $96, $43, $98        ;; 05:570d ????????
    db   $3f, $96, $3b, $96, $3c, $98, $3f, $96        ;; 05:5715 ????????
    db   $42, $96, $44, $98, $43, $98, $48, $98        ;; 05:571d ????????
    db   $24, $04, $43, $94, $44, $94, $41, $94        ;; 05:5725 ????????
    db   $43, $98, $24, $04, $41, $94, $3f, $94        ;; 05:572d ????????
    db   $3e, $94, $3f, $96, $3c, $98, $3e, $94        ;; 05:5735 ????????
    db   $3f, $94, $3b, $9a, $65, $3e, $92, $45        ;; 05:573d ????????
    db   $94, $3e, $92, $45, $94, $3e, $92, $45        ;; 05:5745 ????????
    db   $94, $3e, $92, $41, $94, $45, $94, $3e        ;; 05:574d ????????
    db   $94, $46, $92, $45, $92, $44, $92, $43        ;; 05:5755 ????????
    db   $92, $42, $92, $41, $92, $40, $92, $3f        ;; 05:575d ????????
    db   $92, $3e, $92, $3f, $92, $40, $92, $3f        ;; 05:5765 ????????
    db   $92, $3e, $94, $3a, $94, $65, $32, $92        ;; 05:576d ????????
    db   $35, $92, $39, $92, $3e, $92, $41, $94        ;; 05:5775 ????????
    db   $45, $92, $4a, $94, $45, $92, $41, $92        ;; 05:577d ????????
    db   $3e, $92, $41, $94, $45, $94, $46, $95        ;; 05:5785 ????????
    db   $45, $92, $44, $92, $43, $92, $42, $92        ;; 05:578d ????????
    db   $41, $95, $3f, $94, $3a, $94, $37, $94        ;; 05:5795 ????????
    db   $32, $92, $35, $92, $39, $92, $3e, $92        ;; 05:579d ????????
    db   $41, $92, $45, $92, $4a, $94, $4d, $94        ;; 05:57a5 ????????
    db   $4c, $92, $4a, $94, $4c, $92, $4d, $94        ;; 05:57ad ????????
    db   $4b, $94, $46, $94, $43, $92, $46, $92        ;; 05:57b5 ????????
    db   $4b, $94, $4e, $96, $4b, $94, $46, $94        ;; 05:57bd ????????
    db   $4a, $94, $45, $92, $46, $94, $43, $92        ;; 05:57c5 ????????
    db   $45, $92, $41, $92, $43, $94, $40, $92        ;; 05:57cd ????????
    db   $41, $95, $3e, $94, $3f, $94, $3a, $94        ;; 05:57d5 ????????
    db   $37, $96, $24, $02, $3a, $92, $3f, $92        ;; 05:57dd ????????
    db   $43, $92, $46, $94, $4b, $94, $4a, $96        ;; 05:57e5 ????????
    db   $45, $95, $41, $95, $3e, $94, $41, $94        ;; 05:57ed ????????
    db   $45, $94, $3f, $96, $4b, $94, $3f, $92        ;; 05:57f5 ????????
    db   $4b, $94, $3f, $92, $4b, $94, $4b, $94        ;; 05:57fd ????????
    db   $3f, $94, $65, $39, $82, $39, $84, $39        ;; 05:5805 ????????
    db   $82, $39, $84, $39, $82, $39, $84, $39        ;; 05:580d ????????
    db   $82, $39, $84, $3a, $84, $3a, $84, $39        ;; 05:5815 ????????
    db   $82, $39, $84, $39, $82, $39, $84, $39        ;; 05:581d ????????
    db   $82, $39, $84, $39, $82, $39, $84, $38        ;; 05:5825 ????????
    db   $84, $38, $84, $65, $37, $97, $3a, $97        ;; 05:582d ????????
    db   $3e, $96, $3d, $98, $3a, $96, $36, $96        ;; 05:5835 ????????
    db   $37, $98, $3a, $96, $3e, $96, $3f, $9a        ;; 05:583d ????????
    db   $43, $98, $3e, $98, $3f, $96, $3e, $96        ;; 05:5845 ????????
    db   $3c, $96, $3a, $96, $37, $98, $39, $96        ;; 05:584d ????????
    db   $3a, $96, $36, $9a, $65, $9f, $14, $9f        ;; 05:5855 ????????
    db   $16, $9f, $14, $a6, $16, $9f, $16, $a5        ;; 05:585d ????????
    db   $14, $a5, $16, $a5, $14, $a5, $16, $a5        ;; 05:5865 ????????
    db   $16, $9f, $14, $9f, $16, $9f, $14, $a6        ;; 05:586d ????????
    db   $16, $9f, $16, $a5, $14, $a5, $16, $a5        ;; 05:5875 ????????
    db   $14, $a5, $16, $a0, $16, $65, $9f, $2a        ;; 05:587d ????????
    db   $9f, $2a, $24, $0a, $9f, $2a, $65, $98        ;; 05:5885 ????????
    db   $14, $99, $14, $9a, $15, $9b, $14, $9c        ;; 05:588d ????????
    db   $12, $9d, $12, $9e, $12, $9f, $12, $a0        ;; 05:5895 ????????
    db   $12, $a1, $14, $65, $98, $14, $98, $14        ;; 05:589d ????????
    db   $a4, $15, $98, $14, $98, $14, $98, $12        ;; 05:58a5 ????????
    db   $a4, $14, $98, $14, $99, $14, $99, $14        ;; 05:58ad ????????
    db   $a5, $15, $99, $14, $99, $14, $99, $12        ;; 05:58b5 ????????
    db   $a5, $12, $99, $12, $a5, $14, $98, $14        ;; 05:58bd ????????
    db   $98, $14, $a4, $15, $98, $14, $98, $14        ;; 05:58c5 ????????
    db   $98, $12, $a4, $12, $98, $12, $a4, $14        ;; 05:58cd ????????
    db   $99, $14, $99, $14, $a5, $14, $99, $12        ;; 05:58d5 ????????
    db   $a5, $14, $99, $12, $a5, $12, $99, $12        ;; 05:58dd ????????
    db   $a7, $14, $a5, $14, $65, $a6, $12, $a6        ;; 05:58e5 ????????
    db   $14, $a6, $12, $a6, $14, $a6, $12, $a6        ;; 05:58ed ????????
    db   $14, $a6, $12, $a6, $14, $a0, $14, $a0        ;; 05:58f5 ????????
    db   $14, $a6, $12, $a6, $14, $a6, $12, $a6        ;; 05:58fd ????????
    db   $14, $a6, $12, $a6, $14, $a6, $12, $a6        ;; 05:5905 ????????
    db   $14, $a5, $14, $a5, $14, $65, $9f, $12        ;; 05:590d ????????
    db   $ab, $14, $9f, $12, $ab, $14, $9f, $12        ;; 05:5915 ????????
    db   $ab, $14, $9f, $12, $ab, $14, $9a, $14        ;; 05:591d ????????
    db   $a6, $14, $9b, $12, $a7, $14, $9b, $12        ;; 05:5925 ????????
    db   $a7, $14, $9b, $12, $a7, $14, $9b, $12        ;; 05:592d ????????
    db   $a7, $14, $9e, $14, $aa, $14, $65, $18        ;; 05:5935 ????????
    db   $14, $1e, $32, $1e, $32, $1e, $34, $1e        ;; 05:593d ????????
    db   $34, $18, $14, $1e, $34, $18, $14, $1e        ;; 05:5945 ????????
    db   $34, $18, $14, $1e, $32, $1e, $32, $1e        ;; 05:594d ????????
    db   $34, $1e, $34, $18, $14, $1e, $34, $18        ;; 05:5955 ????????
    db   $14, $1e, $34, $65, $18, $16, $24, $07        ;; 05:595d ????????
    db   $1e, $32, $1e, $32, $1e, $34, $1e, $34        ;; 05:5965 ????????
    db   $18, $14, $18, $16, $18, $16, $1e, $32        ;; 05:596d ????????
    db   $1e, $32, $1e, $34, $1e, $34, $18, $14        ;; 05:5975 ????????
    db   $18, $16, $18, $16, $1e, $32, $1e, $32        ;; 05:597d ????????
    db   $1e, $34, $1e, $34, $18, $16, $1a, $25        ;; 05:5985 ????????
    db   $1a, $24, $1a, $22, $1a, $22, $1a, $22        ;; 05:598d ????????
    db   $1a, $24, $1a, $24, $65, $18, $12, $1e        ;; 05:5995 ????????
    db   $32, $18, $12, $1e, $32, $1a, $22, $1e        ;; 05:599d ????????
    db   $32, $1e, $32, $18, $12, $1e, $32, $18        ;; 05:59a5 ????????
    db   $12, $18, $12, $1e, $32, $1a, $22, $1e        ;; 05:59ad ????????
    db   $32, $1e, $32, $1e, $32, $18, $12, $1e        ;; 05:59b5 ????????
    db   $32, $1e, $32, $1e, $32, $1a, $22, $1e        ;; 05:59bd ????????
    db   $32, $1e, $32, $18, $12, $1e, $32, $18        ;; 05:59c5 ????????
    db   $12, $18, $12, $1e, $32, $1a, $22, $1a        ;; 05:59cd ????????
    db   $22, $1a, $22, $1e, $32, $65, $67, $ff        ;; 05:59d5 ????????
    db   $69, $b9, $64, $00, $00, $03, $64, $25        ;; 05:59dd ????????
    db   $e5, $01, $64, $26, $e5, $01, $64, $00        ;; 05:59e5 ????????
    db   $00, $08, $64, $27, $e5, $01, $64, $27        ;; 05:59ed ????????
    db   $e3, $01, $64, $28, $e5, $01, $64, $29        ;; 05:59f5 ????????
    db   $e5, $01, $64, $00, $00, $01, $24, $09        ;; 05:59fd ????????
    db   $24, $0d, $64, $2a, $e5, $01, $64, $2b        ;; 05:5a05 ????????
    db   $e5, $01, $64, $2c, $e5, $01, $66, $01        ;; 05:5a0d ????????
    db   $62, $db, $59, $64, $2d, $fd, $05, $64        ;; 05:5a15 ????????
    db   $2d, $02, $04, $64, $2e, $fd, $05, $64        ;; 05:5a1d ????????
    db   $2e, $fb, $01, $64, $2e, $02, $04, $64        ;; 05:5a25 ????????
    db   $2f, $fd, $02, $64, $30, $fd, $0e, $64        ;; 05:5a2d ????????
    db   $31, $fd, $01, $64, $32, $fd, $02, $62        ;; 05:5a35 ????????
    db   $18, $5a, $64, $1e, $f1, $05, $64, $1e        ;; 05:5a3d ????????
    db   $ea, $04, $64, $1f, $e5, $02, $64, $20        ;; 05:5a45 ????????
    db   $e5, $01, $64, $20, $e3, $01, $64, $20        ;; 05:5a4d ????????
    db   $ea, $04, $64, $21, $f1, $01, $64, $22        ;; 05:5a55 ????????
    db   $f1, $07, $64, $23, $f1, $01, $64, $24        ;; 05:5a5d ????????
    db   $f1, $02, $62, $3f, $5a, $64, $1a, $00        ;; 05:5a65 ????????
    db   $09, $64, $1b, $00, $01, $64, $1c, $00        ;; 05:5a6d ????????
    db   $08, $64, $1d, $00, $09, $64, $1a, $00        ;; 05:5a75 ????????
    db   $06, $62, $6a, $5a, $95, $86, $95, $84        ;; 05:5a7d ????????
    db   $95, $84, $95, $84, $95, $84, $95, $86        ;; 05:5a85 ????????
    db   $95, $84, $95, $84, $95, $84, $95, $84        ;; 05:5a8d ????????
    db   $9d, $66, $9d, $64, $9d, $64, $9d, $64        ;; 05:5a95 ????????
    db   $9d, $64, $9d, $66, $9d, $64, $9d, $64        ;; 05:5a9d ????????
    db   $9d, $64, $9d, $64, $65, $24, $04, $9a        ;; 05:5aa5 ????????
    db   $62, $9a, $62, $9a, $64, $9a, $64, $24        ;; 05:5aad ????????
    db   $06, $9a, $66, $24, $04, $9a, $62, $9a        ;; 05:5ab5 ????????
    db   $62, $9a, $64, $9a, $64, $24, $04, $9a        ;; 05:5abd ????????
    db   $64, $24, $04, $9a, $64, $65, $24, $06        ;; 05:5ac5 ????????
    db   $9f, $64, $9f, $64, $24, $06, $9f, $64        ;; 05:5acd ????????
    db   $9f, $64, $24, $06, $9e, $34, $9e, $34        ;; 05:5ad5 ????????
    db   $24, $06, $9e, $34, $9e, $34, $65, $9f        ;; 05:5add ????????
    db   $65, $9f, $62, $9f, $65, $9f, $62, $9a        ;; 05:5ae5 ????????
    db   $45, $9a, $42, $9a, $45, $9a, $42, $65        ;; 05:5aed ????????
    db   $9f, $64, $9f, $64, $9f, $64, $9f, $64        ;; 05:5af5 ????????
    db   $9f, $64, $9f, $64, $98, $84, $8c, $84        ;; 05:5afd ????????
    db   $98, $84, $8c, $84, $98, $84, $98, $84        ;; 05:5b05 ????????
    db   $9a, $54, $9a, $54, $9a, $54, $9a, $54        ;; 05:5b0d ????????
    db   $9a, $54, $9a, $54, $9f, $74, $9f, $74        ;; 05:5b15 ????????
    db   $9f, $74, $9f, $74, $9f, $74, $9f, $74        ;; 05:5b1d ????????
    db   $9c, $54, $9c, $54, $9c, $54, $9c, $54        ;; 05:5b25 ????????
    db   $9c, $54, $9c, $54, $a1, $74, $a1, $74        ;; 05:5b2d ????????
    db   $a1, $74, $a1, $74, $a1, $74, $a1, $74        ;; 05:5b35 ????????
    db   $9c, $54, $9c, $54, $9c, $54, $9c, $54        ;; 05:5b3d ????????
    db   $9c, $54, $9c, $54, $a1, $74, $a1, $74        ;; 05:5b45 ????????
    db   $a1, $74, $a1, $74, $a1, $74, $a1, $74        ;; 05:5b4d ????????
    db   $65, $24, $04, $9c, $34, $9c, $34, $9c        ;; 05:5b55 ????????
    db   $34, $9c, $36, $24, $04, $95, $84, $95        ;; 05:5b5d ????????
    db   $84, $95, $84, $95, $86, $24, $04, $9c        ;; 05:5b65 ????????
    db   $34, $9c, $34, $9c, $34, $9c, $36, $24        ;; 05:5b6d ????????
    db   $04, $9d, $34, $9d, $34, $9d, $34, $9d        ;; 05:5b75 ????????
    db   $36, $24, $04, $9a, $74, $9a, $74, $9a        ;; 05:5b7d ????????
    db   $74, $9a, $76, $24, $04, $9a, $74, $9a        ;; 05:5b85 ????????
    db   $74, $9a, $74, $9a, $76, $24, $04, $9c        ;; 05:5b8d ????????
    db   $34, $9c, $34, $9c, $34, $9c, $36, $24        ;; 05:5b95 ????????
    db   $04, $95, $84, $95, $84, $95, $84, $95        ;; 05:5b9d ????????
    db   $86, $65, $45, $b8, $48, $b6, $4d, $b8        ;; 05:5ba5 ????????
    db   $4c, $b6, $44, $b8, $43, $b6, $41, $b6        ;; 05:5bad ????????
    db   $43, $b6, $44, $b6, $45, $b8, $48, $b6        ;; 05:5bb5 ????????
    db   $4c, $b8, $4d, $b6, $50, $b9, $4d, $b9        ;; 05:5bbd ????????
    db   $51, $b8, $4c, $b6, $48, $b6, $45, $b6        ;; 05:5bc5 ????????
    db   $47, $b4, $48, $b4, $44, $b8, $41, $b6        ;; 05:5bcd ????????
    db   $3c, $b8, $38, $b6, $39, $b4, $3c, $b4        ;; 05:5bd5 ????????
    db   $40, $b6, $45, $b4, $47, $b4, $48, $b6        ;; 05:5bdd ????????
    db   $47, $b6, $45, $b6, $44, $bb, $65, $4a        ;; 05:5be5 ????????
    db   $b7, $45, $b4, $46, $b4, $43, $b4, $45        ;; 05:5bed ????????
    db   $b4, $41, $b4, $43, $b4, $40, $b4, $41        ;; 05:5bf5 ????????
    db   $b4, $3e, $b4, $3d, $b8, $3a, $b6, $35        ;; 05:5bfd ????????
    db   $b6, $3a, $b6, $3d, $b6, $32, $b4, $34        ;; 05:5c05 ????????
    db   $b4, $35, $b4, $39, $b4, $3e, $b4, $40        ;; 05:5c0d ????????
    db   $b4, $41, $b4, $45, $b4, $4a, $b4, $4c        ;; 05:5c15 ????????
    db   $b4, $4d, $b4, $4a, $b4, $49, $b8, $46        ;; 05:5c1d ????????
    db   $b6, $41, $b6, $46, $b6, $49, $b6, $4a        ;; 05:5c25 ????????
    db   $b4, $45, $b4, $46, $b4, $43, $b4, $45        ;; 05:5c2d ????????
    db   $b4, $41, $b4, $43, $b4, $40, $b4, $41        ;; 05:5c35 ????????
    db   $b4, $3e, $b4, $40, $b4, $3d, $b4, $3a        ;; 05:5c3d ????????
    db   $b8, $35, $b4, $3a, $b4, $3d, $b4, $3a        ;; 05:5c45 ????????
    db   $b4, $35, $b6, $31, $b6, $32, $b7, $34        ;; 05:5c4d ????????
    db   $b4, $35, $b4, $38, $b4, $39, $b6, $38        ;; 05:5c55 ????????
    db   $b6, $35, $b4, $32, $b4, $31, $bb, $65        ;; 05:5c5d ????????
    db   $3e, $86, $41, $86, $44, $86, $45, $86        ;; 05:5c65 ????????
    db   $24, $06, $46, $82, $45, $82, $44, $82        ;; 05:5c6d ????????
    db   $43, $82, $42, $82, $41, $82, $40, $82        ;; 05:5c75 ????????
    db   $3f, $82, $3e, $86, $65, $37, $86, $3a        ;; 05:5c7d ????????
    db   $86, $3d, $86, $3e, $86, $3f, $88, $3e        ;; 05:5c85 ????????
    db   $87, $3e, $82, $3f, $82, $41, $86, $3f        ;; 05:5c8d ????????
    db   $86, $3e, $86, $3d, $86, $3e, $8a, $3a        ;; 05:5c95 ????????
    db   $86, $37, $86, $3d, $86, $3e, $86, $36        ;; 05:5c9d ????????
    db   $87, $37, $82, $39, $82, $37, $86, $32        ;; 05:5ca5 ????????
    db   $86, $37, $86, $39, $86, $3a, $86, $33        ;; 05:5cad ????????
    db   $86, $32, $8a, $65, $37, $86, $3a, $86        ;; 05:5cb5 ????????
    db   $3d, $86, $3e, $86, $36, $86, $3a, $86        ;; 05:5cbd ????????
    db   $3d, $86, $3e, $86, $37, $86, $3a, $86        ;; 05:5cc5 ????????
    db   $3d, $86, $3e, $86, $3f, $87, $3e, $82        ;; 05:5ccd ????????
    db   $3d, $82, $3e, $88, $65, $43, $8d, $45        ;; 05:5cd5 ????????
    db   $8d, $46, $8e, $46, $8d, $45, $8d, $46        ;; 05:5cdd ????????
    db   $8d, $45, $8d, $43, $86, $24, $0e, $46        ;; 05:5ce5 ????????
    db   $8d, $45, $8e, $43, $8d, $42, $8e, $3f        ;; 05:5ced ????????
    db   $8d, $3e, $8e, $24, $0e, $3e, $8e, $43        ;; 05:5cf5 ????????
    db   $8e, $3f, $8d, $3e, $8e, $3c, $8d, $3e        ;; 05:5cfd ????????
    db   $8d, $3f, $8d, $3e, $8d, $3c, $8e, $3a        ;; 05:5d05 ????????
    db   $8d, $39, $86, $3a, $8e, $36, $8d, $3e        ;; 05:5d0d ????????
    db   $88, $37, $8d, $39, $8d, $3a, $8d, $3e        ;; 05:5d15 ????????
    db   $8d, $43, $8d, $45, $8d, $46, $86, $45        ;; 05:5d1d ????????
    db   $8e, $43, $8d, $46, $8e, $45, $8d, $43        ;; 05:5d25 ????????
    db   $8e, $42, $8d, $3f, $88, $3e, $86, $42        ;; 05:5d2d ????????
    db   $86, $43, $86, $3e, $86, $3c, $8e, $3a        ;; 05:5d35 ????????
    db   $8d, $39, $8d, $3a, $8d, $39, $8d, $37        ;; 05:5d3d ????????
    db   $88, $4a, $86, $4a, $86, $49, $8e, $46        ;; 05:5d45 ????????
    db   $8d, $43, $86, $4a, $86, $4a, $86, $49        ;; 05:5d4d ????????
    db   $8e, $46, $8d, $43, $86, $46, $86, $45        ;; 05:5d55 ????????
    db   $8e, $43, $8d, $42, $86, $43, $8e, $45        ;; 05:5d5d ????????
    db   $8d, $43, $8a, $65, $43, $88, $45, $84        ;; 05:5d65 ????????
    db   $46, $84, $48, $88, $46, $84, $45, $84        ;; 05:5d6d ????????
    db   $42, $88, $43, $84, $45, $84, $46, $84        ;; 05:5d75 ????????
    db   $45, $84, $43, $88, $47, $88, $4a, $84        ;; 05:5d7d ????????
    db   $4d, $84, $4c, $87, $4a, $84, $48, $86        ;; 05:5d85 ????????
    db   $47, $87, $45, $84, $44, $86, $45, $89        ;; 05:5d8d ????????
    db   $65, $4c, $84, $4d, $84, $4c, $84, $4a        ;; 05:5d95 ????????
    db   $84, $47, $84, $40, $84, $4a, $84, $4c        ;; 05:5d9d ????????
    db   $84, $4a, $84, $48, $84, $45, $84, $40        ;; 05:5da5 ????????
    db   $84, $48, $84, $4a, $84, $48, $84, $47        ;; 05:5dad ????????
    db   $84, $44, $84, $40, $84, $47, $84, $48        ;; 05:5db5 ????????
    db   $84, $47, $84, $45, $84, $41, $84, $3e        ;; 05:5dbd ????????
    db   $84, $39, $84, $3a, $84, $3b, $84, $3c        ;; 05:5dc5 ????????
    db   $84, $3d, $84, $3e, $84, $3f, $84, $40        ;; 05:5dcd ????????
    db   $84, $41, $84, $42, $84, $43, $84, $44        ;; 05:5dd5 ????????
    db   $84, $45, $84, $46, $84, $47, $84, $48        ;; 05:5ddd ????????
    db   $84, $4a, $84, $4b, $84, $4c, $89, $4c        ;; 05:5de5 ????????
    db   $84, $4d, $84, $4c, $84, $4a, $84, $47        ;; 05:5ded ????????
    db   $84, $40, $84, $4a, $84, $4c, $84, $4a        ;; 05:5df5 ????????
    db   $84, $48, $84, $45, $84, $40, $84, $48        ;; 05:5dfd ????????
    db   $84, $4a, $84, $48, $84, $47, $84, $44        ;; 05:5e05 ????????
    db   $84, $40, $84, $47, $84, $48, $84, $47        ;; 05:5e0d ????????
    db   $84, $45, $84, $41, $84, $3e, $84, $39        ;; 05:5e15 ????????
    db   $84, $3a, $84, $3b, $84, $3c, $84, $3d        ;; 05:5e1d ????????
    db   $84, $3e, $84, $3f, $84, $40, $84, $41        ;; 05:5e25 ????????
    db   $84, $42, $84, $43, $84, $44, $84, $45        ;; 05:5e2d ????????
    db   $84, $46, $84, $47, $84, $48, $84, $4a        ;; 05:5e35 ????????
    db   $84, $4c, $84, $51, $89, $65, $a1, $28        ;; 05:5e3d ????????
    db   $a8, $26, $ad, $28, $a1, $26, $9d, $28        ;; 05:5e45 ????????
    db   $a4, $26, $a9, $27, $a4, $24, $a0, $24        ;; 05:5e4d ????????
    db   $9d, $24, $65, $a6, $16, $a9, $16, $ac        ;; 05:5e55 ????????
    db   $16, $ad, $17, $a6, $14, $a9, $16, $ac        ;; 05:5e5d ????????
    db   $16, $ad, $14, $a1, $14, $a6, $16, $a9        ;; 05:5e65 ????????
    db   $16, $ac, $16, $ad, $17, $a6, $14, $a9        ;; 05:5e6d ????????
    db   $16, $ac, $16, $ad, $16, $65, $a6, $16        ;; 05:5e75 ????????
    db   $a9, $16, $ac, $16, $ad, $17, $a6, $14        ;; 05:5e7d ????????
    db   $a9, $16, $ac, $16, $ad, $16, $65, $9f        ;; 05:5e85 ????????
    db   $28, $a1, $26, $a2, $26, $9e, $28, $9f        ;; 05:5e8d ????????
    db   $26, $a1, $26, $9f, $28, $a1, $26, $a2        ;; 05:5e95 ????????
    db   $26, $9e, $28, $9a, $28, $65, $9f, $26        ;; 05:5e9d ????????
    db   $a2, $26, $9e, $26, $a1, $26, $9f, $26        ;; 05:5ea5 ????????
    db   $a2, $26, $9a, $26, $9e, $26, $65, $9f        ;; 05:5ead ????????
    db   $28, $a1, $24, $a2, $24, $a4, $27, $a6        ;; 05:5eb5 ????????
    db   $24, $a7, $24, $a4, $24, $9e, $28, $9f        ;; 05:5ebd ????????
    db   $24, $a1, $24, $9f, $27, $a2, $24, $a6        ;; 05:5ec5 ????????
    db   $26, $a8, $27, $aa, $24, $ac, $24, $a8        ;; 05:5ecd ????????
    db   $24, $ad, $26, $a8, $26, $a4, $24, $a1        ;; 05:5ed5 ????????
    db   $24, $a0, $27, $a1, $24, $a3, $24, $9c        ;; 05:5edd ????????
    db   $24, $a1, $29, $65, $9c, $28, $9e, $24        ;; 05:5ee5 ????????
    db   $a0, $24, $a1, $27, $a3, $24, $a4, $24        ;; 05:5eed ????????
    db   $a6, $24, $a8, $29, $a9, $27, $a8, $24        ;; 05:5ef5 ????????
    db   $a6, $24, $a4, $24, $a6, $29, $a8, $29        ;; 05:5efd ????????
    db   $a8, $27, $a6, $24, $a4, $24, $a3, $24        ;; 05:5f05 ????????
    db   $a1, $29, $65, $18, $16, $1e, $34, $1e        ;; 05:5f0d ????????
    db   $34, $1e, $34, $1e, $34, $18, $14, $1e        ;; 05:5f15 ????????
    db   $32, $1e, $32, $1e, $34, $1e, $34, $1e        ;; 05:5f1d ????????
    db   $34, $1e, $34, $18, $16, $1e, $34, $1e        ;; 05:5f25 ????????
    db   $34, $1e, $34, $1e, $34, $18, $16, $1e        ;; 05:5f2d ????????
    db   $34, $1e, $32, $1e, $32, $1e, $34, $1e        ;; 05:5f35 ????????
    db   $34, $65, $25, $69, $24, $04, $1e, $32        ;; 05:5f3d ????????
    db   $1e, $32, $1e, $37, $1e, $32, $1e, $32        ;; 05:5f45 ????????
    db   $1e, $34, $1e, $34, $1e, $34, $1e, $36        ;; 05:5f4d ????????
    db   $1e, $32, $1e, $32, $1e, $34, $1e, $36        ;; 05:5f55 ????????
    db   $1e, $32, $1e, $32, $1e, $34, $1e, $36        ;; 05:5f5d ????????
    db   $1e, $32, $1e, $32, $1e, $34, $1e, $36        ;; 05:5f65 ????????
    db   $1e, $32, $1e, $32, $1e, $32, $1e, $32        ;; 05:5f6d ????????
    db   $1e, $34, $65, $24, $04, $1e, $32, $1e        ;; 05:5f75 ????????
    db   $32, $1e, $34, $1e, $36, $1e, $32, $1e        ;; 05:5f7d ????????
    db   $32, $1e, $34, $1e, $36, $1e, $32, $1e        ;; 05:5f85 ????????
    db   $32, $1e, $34, $1e, $36, $1e, $32, $1e        ;; 05:5f8d ????????
    db   $32, $1e, $32, $1e, $32, $1e, $34, $65        ;; 05:5f95 ????????
    db   $18, $14, $1e, $32, $1e, $32, $1e, $34        ;; 05:5f9d ????????
    db   $1e, $34, $1a, $24, $1e, $32, $1e, $32        ;; 05:5fa5 ????????
    db   $1e, $34, $1e, $34, $18, $12, $1e, $32        ;; 05:5fad ????????
    db   $1e, $34, $1e, $34, $1e, $34, $1a, $24        ;; 05:5fb5 ????????
    db   $1e, $32, $1e, $32, $1e, $32, $1e, $32        ;; 05:5fbd ????????
    db   $1e, $34, $65, $67, $ff, $69, $ff, $64        ;; 05:5fc5 ????????
    db   $33, $f2, $01, $64, $34, $f2, $03, $24        ;; 05:5fcd ????????
    db   $00, $66, $01, $61, $64, $35, $f2, $01        ;; 05:5fd5 ????????
    db   $64, $36, $f2, $03, $24, $00, $61, $64        ;; 05:5fdd ????????
    db   $37, $fe, $01, $24, $00, $61, $24, $00        ;; 05:5fe5 ????????
    db   $61, $24, $04, $2a, $80, $2e, $80, $31        ;; 05:5fed ????????
    db   $80, $36, $80, $3a, $80, $2f, $80, $32        ;; 05:5ff5 ????????
    db   $80, $37, $80, $3b, $80, $30, $80, $33        ;; 05:5ffd ????????
    db   $80, $38, $80, $3c, $80, $31, $80, $34        ;; 05:6005 ????????
    db   $80, $39, $80, $3d, $80, $32, $80, $35        ;; 05:600d ????????
    db   $80, $3a, $80, $3e, $80, $33, $80, $36        ;; 05:6015 ????????
    db   $80, $3b, $80, $3f, $80, $34, $80, $37        ;; 05:601d ????????
    db   $80, $3c, $80, $40, $80, $35, $80, $38        ;; 05:6025 ????????
    db   $80, $3d, $80, $41, $80, $36, $80, $39        ;; 05:602d ????????
    db   $80, $3e, $80, $42, $80, $37, $80, $3a        ;; 05:6035 ????????
    db   $80, $3f, $80, $43, $80, $38, $80, $3b        ;; 05:603d ????????
    db   $80, $40, $80, $44, $80, $39, $80, $3c        ;; 05:6045 ????????
    db   $80, $41, $80, $45, $80, $3a, $80, $3d        ;; 05:604d ????????
    db   $80, $42, $80, $46, $80, $3b, $80, $3e        ;; 05:6055 ????????
    db   $80, $43, $80, $47, $80, $3c, $80, $3f        ;; 05:605d ????????
    db   $80, $44, $80, $65, $49, $80, $3d, $80        ;; 05:6065 ????????
    db   $40, $80, $45, $80, $49, $80, $3d, $80        ;; 05:606d ????????
    db   $40, $80, $45, $80, $49, $80, $3d, $80        ;; 05:6075 ????????
    db   $40, $80, $45, $80, $49, $80, $3d, $80        ;; 05:607d ????????
    db   $40, $80, $45, $80, $65, $2c, $8e, $2a        ;; 05:6085 ????????
    db   $80, $2e, $80, $31, $80, $36, $80, $3a        ;; 05:608d ????????
    db   $80, $2f, $80, $32, $80, $37, $80, $3b        ;; 05:6095 ????????
    db   $80, $30, $80, $33, $80, $38, $80, $3c        ;; 05:609d ????????
    db   $80, $31, $80, $34, $80, $39, $80, $3d        ;; 05:60a5 ????????
    db   $80, $32, $80, $35, $80, $3a, $80, $3e        ;; 05:60ad ????????
    db   $80, $33, $80, $36, $80, $3b, $80, $3f        ;; 05:60b5 ????????
    db   $8d, $24, $08, $24, $08, $65, $45, $80        ;; 05:60bd ????????
    db   $49, $80, $3d, $80, $40, $80, $45, $80        ;; 05:60c5 ????????
    db   $49, $80, $3d, $80, $40, $80, $45, $80        ;; 05:60cd ????????
    db   $49, $80, $3d, $80, $40, $80, $45, $80        ;; 05:60d5 ????????
    db   $49, $80, $3d, $80, $40, $80, $65, $24        ;; 05:60dd ????????
    db   $08, $ac, $15, $9c, $12, $9f, $14, $9c        ;; 05:60e5 ????????
    db   $14, $a4, $12, $a1, $12, $9f, $12, $9c        ;; 05:60ed ????????
    db   $15, $9f, $14, $98, $14, $9c, $14, $93        ;; 05:60f5 ????????
    db   $16, $95, $16, $24, $06, $24, $08, $95        ;; 05:60fd ????????
    db   $16, $24, $06, $65, $67, $ff, $69, $ab        ;; 05:6105 ????????
    db   $64, $45, $e5, $01, $64, $46, $e5, $02        ;; 05:610d ????????
    db   $64, $47, $e5, $01, $64, $47, $e7, $01        ;; 05:6115 ????????
    db   $64, $46, $e7, $01, $64, $48, $e5, $02        ;; 05:611d ????????
    db   $64, $47, $e7, $01, $64, $49, $e5, $02        ;; 05:6125 ????????
    db   $64, $48, $e3, $01, $64, $4a, $e5, $01        ;; 05:612d ????????
    db   $64, $45, $e5, $01, $66, $01, $62, $09        ;; 05:6135 ????????
    db   $61, $64, $3f, $e5, $01, $64, $40, $e5        ;; 05:613d ????????
    db   $02, $64, $41, $e5, $01, $64, $41, $e7        ;; 05:6145 ????????
    db   $01, $64, $40, $e7, $01, $64, $42, $e5        ;; 05:614d ????????
    db   $02, $64, $41, $e7, $01, $64, $43, $e5        ;; 05:6155 ????????
    db   $02, $64, $42, $e3, $01, $64, $44, $e5        ;; 05:615d ????????
    db   $01, $64, $3f, $e5, $01, $62, $3e, $61        ;; 05:6165 ????????
    db   $64, $39, $f1, $01, $64, $3a, $f1, $02        ;; 05:616d ????????
    db   $64, $3b, $f1, $01, $64, $3b, $f3, $01        ;; 05:6175 ????????
    db   $64, $3a, $f3, $01, $64, $3c, $f1, $02        ;; 05:617d ????????
    db   $64, $3b, $f3, $01, $64, $3d, $f1, $02        ;; 05:6185 ????????
    db   $64, $3c, $ef, $01, $64, $3e, $f1, $01        ;; 05:618d ????????
    db   $64, $39, $f1, $01, $62, $6d, $61, $64        ;; 05:6195 ????????
    db   $38, $00, $26, $62, $9c, $61, $3c, $9a        ;; 05:619d ????????
    db   $3b, $9a, $39, $9a, $37, $9a, $65, $24        ;; 05:61a5 ????????
    db   $06, $45, $c4, $43, $c4, $45, $c6, $48        ;; 05:61ad ????????
    db   $c6, $40, $c9, $3e, $c4, $3c, $c4, $3e        ;; 05:61b5 ????????
    db   $cc, $24, $06, $45, $c4, $43, $c4, $45        ;; 05:61bd ????????
    db   $c6, $48, $c6, $40, $c9, $48, $c4, $4c        ;; 05:61c5 ????????
    db   $c4, $4a, $cc, $65, $45, $84, $45, $82        ;; 05:61cd ????????
    db   $45, $82, $43, $84, $43, $84, $40, $84        ;; 05:61d5 ????????
    db   $40, $84, $3c, $84, $3c, $84, $3e, $82        ;; 05:61dd ????????
    db   $40, $82, $3e, $82, $3c, $82, $39, $84        ;; 05:61e5 ????????
    db   $37, $84, $39, $88, $45, $84, $45, $82        ;; 05:61ed ????????
    db   $45, $82, $43, $84, $43, $84, $40, $84        ;; 05:61f5 ????????
    db   $40, $84, $3c, $84, $3c, $84, $3e, $82        ;; 05:61fd ????????
    db   $40, $82, $3e, $82, $3c, $82, $3e, $84        ;; 05:6205 ????????
    db   $40, $84, $40, $88, $45, $84, $45, $82        ;; 05:620d ????????
    db   $45, $82, $48, $84, $48, $84, $47, $84        ;; 05:6215 ????????
    db   $47, $84, $43, $86, $45, $84, $45, $82        ;; 05:621d ????????
    db   $45, $82, $45, $84, $43, $84, $40, $88        ;; 05:6225 ????????
    db   $3e, $82, $40, $82, $3e, $82, $3c, $82        ;; 05:622d ????????
    db   $39, $84, $37, $84, $39, $84, $39, $82        ;; 05:6235 ????????
    db   $39, $82, $39, $84, $3c, $84, $3e, $84        ;; 05:623d ????????
    db   $3e, $82, $3e, $82, $3e, $84, $3c, $84        ;; 05:6245 ????????
    db   $39, $88, $65, $47, $86, $45, $86, $42        ;; 05:624d ????????
    db   $82, $43, $82, $42, $82, $40, $82, $42        ;; 05:6255 ????????
    db   $86, $40, $84, $40, $82, $40, $82, $40        ;; 05:625d ????????
    db   $84, $3e, $84, $42, $88, $47, $86, $45        ;; 05:6265 ????????
    db   $86, $42, $82, $43, $82, $42, $82, $3e        ;; 05:626d ????????
    db   $82, $42, $86, $40, $84, $40, $82, $40        ;; 05:6275 ????????
    db   $82, $40, $84, $3e, $84, $3b, $88, $65        ;; 05:627d ????????
    db   $3b, $85, $39, $82, $36, $84, $34, $84        ;; 05:6285 ????????
    db   $36, $86, $39, $86, $3b, $8a, $65, $3e        ;; 05:628d ????????
    db   $82, $40, $82, $3e, $82, $3c, $82, $39        ;; 05:6295 ????????
    db   $84, $37, $84, $39, $84, $3c, $84, $40        ;; 05:629d ????????
    db   $82, $40, $82, $40, $84, $3e, $82, $40        ;; 05:62a5 ????????
    db   $82, $3e, $82, $3c, $82, $39, $84, $3c        ;; 05:62ad ????????
    db   $84, $40, $88, $3e, $82, $40, $82, $3e        ;; 05:62b5 ????????
    db   $82, $3c, $82, $39, $84, $37, $82, $39        ;; 05:62bd ????????
    db   $82, $3c, $84, $39, $84, $37, $84, $34        ;; 05:62c5 ????????
    db   $84, $37, $82, $39, $82, $3c, $82, $39        ;; 05:62cd ????????
    db   $82, $37, $84, $34, $84, $39, $88, $65        ;; 05:62d5 ????????
    db   $34, $9a, $32, $9a, $30, $9a, $2f, $9a        ;; 05:62dd ????????
    db   $65, $24, $06, $3c, $f4, $3b, $f4, $3c        ;; 05:62e5 ????????
    db   $f6, $40, $f6, $39, $fa, $35, $f6, $37        ;; 05:62ed ????????
    db   $f6, $39, $f4, $37, $f4, $35, $f4, $34        ;; 05:62f5 ????????
    db   $f4, $35, $f6, $34, $f6, $32, $f6, $35        ;; 05:62fd ????????
    db   $f6, $24, $06, $3c, $f4, $3b, $f4, $3c        ;; 05:6305 ????????
    db   $f6, $40, $f6, $39, $fa, $41, $f6, $43        ;; 05:630d ????????
    db   $f6, $45, $f4, $43, $f4, $41, $f4, $40        ;; 05:6315 ????????
    db   $f4, $41, $f6, $40, $f6, $3e, $f6, $41        ;; 05:631d ????????
    db   $f6, $65, $40, $f4, $40, $f2, $40, $f2        ;; 05:6325 ????????
    db   $3e, $f4, $3e, $f4, $3c, $f4, $3c, $f4        ;; 05:632d ????????
    db   $39, $f4, $39, $f4, $39, $f6, $35, $f4        ;; 05:6335 ????????
    db   $34, $f4, $34, $f8, $40, $f4, $40, $f2        ;; 05:633d ????????
    db   $40, $f2, $3e, $f4, $3e, $f4, $3c, $f4        ;; 05:6345 ????????
    db   $3c, $f4, $39, $f4, $39, $f4, $39, $f6        ;; 05:634d ????????
    db   $39, $f4, $39, $f4, $38, $f8, $3c, $f4        ;; 05:6355 ????????
    db   $3c, $f2, $3c, $f2, $40, $f4, $40, $f4        ;; 05:635d ????????
    db   $3e, $f4, $3e, $f4, $3b, $f6, $40, $f4        ;; 05:6365 ????????
    db   $40, $f2, $40, $f2, $40, $f4, $3e, $f4        ;; 05:636d ????????
    db   $3c, $f8, $3b, $f5, $39, $f2, $34, $f4        ;; 05:6375 ????????
    db   $32, $f4, $34, $f4, $34, $f2, $34, $f2        ;; 05:637d ????????
    db   $34, $f4, $39, $f4, $39, $f4, $39, $f2        ;; 05:6385 ????????
    db   $39, $f2, $39, $f4, $37, $f4, $34, $f8        ;; 05:638d ????????
    db   $65, $42, $86, $40, $86, $3e, $86, $3d        ;; 05:6395 ????????
    db   $86, $3b, $84, $3b, $82, $3b, $82, $3b        ;; 05:639d ????????
    db   $84, $39, $84, $3a, $88, $42, $86, $40        ;; 05:63a5 ????????
    db   $86, $3e, $86, $3d, $86, $3b, $84, $3b        ;; 05:63ad ????????
    db   $82, $3b, $82, $3b, $84, $39, $84, $36        ;; 05:63b5 ????????
    db   $88, $65, $36, $85, $36, $82, $32, $84        ;; 05:63bd ????????
    db   $31, $84, $32, $86, $36, $86, $38, $8a        ;; 05:63c5 ????????
    db   $65, $35, $92, $37, $92, $35, $92, $34        ;; 05:63cd ????????
    db   $92, $32, $94, $30, $94, $34, $94, $39        ;; 05:63d5 ????????
    db   $94, $3c, $92, $3c, $92, $3c, $94, $35        ;; 05:63dd ????????
    db   $92, $37, $92, $35, $92, $32, $92, $35        ;; 05:63e5 ????????
    db   $94, $39, $94, $3c, $98, $35, $92, $37        ;; 05:63ed ????????
    db   $92, $35, $92, $34, $92, $30, $94, $2f        ;; 05:63f5 ????????
    db   $92, $30, $92, $39, $94, $34, $94, $30        ;; 05:63fd ????????
    db   $94, $2d, $94, $34, $92, $35, $92, $37        ;; 05:6405 ????????
    db   $92, $34, $92, $34, $94, $2f, $94, $30        ;; 05:640d ????????
    db   $98, $65, $ad, $27, $ab, $24, $a8, $26        ;; 05:6415 ????????
    db   $a6, $26, $a4, $24, $a6, $24, $a8, $24        ;; 05:641d ????????
    db   $a4, $24, $a1, $26, $9f, $26, $a1, $26        ;; 05:6425 ????????
    db   $9f, $26, $a1, $26, $a4, $26, $9c, $2a        ;; 05:642d ????????
    db   $65, $a1, $27, $a3, $24, $a4, $26, $a8        ;; 05:6435 ????????
    db   $26, $a1, $28, $a8, $26, $ad, $24, $a4        ;; 05:643d ????????
    db   $24, $a6, $27, $a4, $24, $a1, $26, $9d        ;; 05:6445 ????????
    db   $26, $9a, $28, $a1, $26, $a6, $26, $a1        ;; 05:644d ????????
    db   $27, $a3, $24, $a4, $26, $a8, $26, $ad        ;; 05:6455 ????????
    db   $28, $ab, $26, $a8, $24, $a4, $24, $a6        ;; 05:645d ????????
    db   $27, $a4, $24, $a1, $26, $9d, $26, $9a        ;; 05:6465 ????????
    db   $27, $9c, $24, $9d, $26, $a1, $26, $65        ;; 05:646d ????????
    db   $a1, $27, $9f, $24, $9c, $26, $9f, $26        ;; 05:6475 ????????
    db   $a1, $27, $9f, $24, $a1, $26, $9c, $26        ;; 05:647d ????????
    db   $a1, $28, $a4, $26, $a1, $26, $a1, $27        ;; 05:6485 ????????
    db   $9f, $24, $9c, $28, $a1, $28, $a6, $28        ;; 05:648d ????????
    db   $a8, $2a, $a6, $28, $a1, $24, $a1, $24        ;; 05:6495 ????????
    db   $a1, $26, $a6, $28, $a1, $28, $65, $a3        ;; 05:649d ????????
    db   $16, $a5, $16, $a6, $16, $aa, $16, $a8        ;; 05:64a5 ????????
    db   $14, $a8, $12, $a8, $12, $a8, $14, $a6        ;; 05:64ad ????????
    db   $14, $aa, $14, $a5, $14, $a2, $14, $9e        ;; 05:64b5 ????????
    db   $14, $a3, $16, $a5, $16, $a6, $16, $aa        ;; 05:64bd ????????
    db   $16, $a8, $14, $a8, $12, $a8, $12, $a8        ;; 05:64c5 ????????
    db   $14, $a6, $14, $a3, $14, $a1, $14, $a3        ;; 05:64cd ????????
    db   $16, $65, $a3, $15, $a3, $12, $a3, $14        ;; 05:64d5 ????????
    db   $a1, $14, $9e, $14, $a1, $14, $a3, $14        ;; 05:64dd ????????
    db   $a6, $14, $a8, $16, $a8, $14, $a8, $12        ;; 05:64e5 ????????
    db   $a8, $12, $a8, $14, $a8, $12, $a8, $12        ;; 05:64ed ????????
    db   $a8, $14, $a8, $14, $65, $a6, $28, $a4        ;; 05:64f5 ????????
    db   $24, $a4, $24, $a4, $26, $a3, $27, $a3        ;; 05:64fd ????????
    db   $24, $a1, $24, $a1, $24, $a1, $26, $a6        ;; 05:6505 ????????
    db   $28, $a4, $28, $9c, $27, $a3, $24, $a1        ;; 05:650d ????????
    db   $28, $65, $18, $14, $1e, $32, $1e, $32        ;; 05:6515 ????????
    db   $1e, $34, $1e, $34, $1a, $26, $1a, $26        ;; 05:651d ????????
    db   $18, $14, $18, $14, $1e, $32, $1e, $32        ;; 05:6525 ????????
    db   $1e, $32, $1e, $32, $1a, $24, $1a, $22        ;; 05:652d ????????
    db   $1a, $22, $1a, $24, $1a, $24, $65             ;; 05:6535 ???????

data_05_653c:
    db   $67, $ff, $69, $c4, $64, $4b, $ef, $01        ;; 05:653c ........
    db   $24, $00, $66, $01, $61                       ;; 05:6544 ?????

data_05_6549:
    db   $64, $4c, $ef, $01, $24, $00, $61             ;; 05:6549 ....???

data_05_6550:
    db   $64, $4d, $fb, $01, $24, $00, $61             ;; 05:6550 ....???

data_05_6557:
    db   $24, $00, $61                                 ;; 05:6557 ...

data_05_655a:
    db   $54, $82, $52, $82, $50, $82, $4e, $82        ;; 05:655a ........
    db   $4c, $82, $4a, $82, $48, $82, $46, $82        ;; 05:6562 ????????
    db   $44, $82, $42, $82, $40, $82, $3e, $82        ;; 05:656a ????????
    db   $3c, $82, $3a, $82, $38, $82, $36, $82        ;; 05:6572 ????????
    db   $34, $82, $32, $82, $30, $82, $2e, $82        ;; 05:657a ????????
    db   $2c, $82, $2a, $82, $28, $82, $26, $82        ;; 05:6582 ????????
    db   $24, $84, $27, $82, $2e, $82, $2d, $8d        ;; 05:658a ????????
    db   $33, $8d, $30, $8d, $36, $8d, $33, $8d        ;; 05:6592 ????????
    db   $39, $8d, $36, $84, $3c, $81, $39, $81        ;; 05:659a ????????
    db   $3c, $8d, $3f, $81, $3c, $81, $3f, $82        ;; 05:65a2 ????????
    db   $42, $82, $3f, $82, $42, $86, $65             ;; 05:65aa ???????

data_05_65b1:
    db   $4c, $8d, $48, $8d, $4a, $8d, $46, $8d        ;; 05:65b1 ......??
    db   $48, $8d, $44, $8d, $46, $8d, $42, $8d        ;; 05:65b9 ????????
    db   $44, $8d, $40, $8d, $42, $8d, $3e, $8d        ;; 05:65c1 ????????
    db   $40, $8d, $3c, $8d, $3e, $8d, $3a, $8d        ;; 05:65c9 ????????
    db   $3c, $8d, $38, $86, $24, $8d, $27, $8d        ;; 05:65d1 ????????
    db   $2e, $8d, $2d, $8d, $33, $8d, $30, $8d        ;; 05:65d9 ????????
    db   $36, $81, $33, $8d, $36, $81, $39, $81        ;; 05:65e1 ????????
    db   $36, $82, $39, $82, $3c, $82, $39, $82        ;; 05:65e9 ????????
    db   $3c, $82, $3f, $82, $3c, $82, $3f, $82        ;; 05:65f1 ????????
    db   $42, $82, $3f, $82, $42, $82, $42, $82        ;; 05:65f9 ????????
    db   $3f, $82, $42, $86, $65                       ;; 05:6601 ?????

data_05_6606:
    db   $98, $2b, $98, $2c, $65, $67, $ff, $69        ;; 05:6606 ..??????
    db   $cd, $64, $00, $00, $04, $64, $55, $e3        ;; 05:660e ????????
    db   $01, $64, $56, $e3, $01, $66, $01, $62        ;; 05:6616 ????????
    db   $0b, $66, $64, $52, $e3, $04, $64, $52        ;; 05:661e ????????
    db   $e8, $02, $64, $52, $e3, $01, $64, $52        ;; 05:6626 ????????
    db   $ea, $01, $64, $52, $e8, $01, $64, $52        ;; 05:662e ????????
    db   $e3, $01, $64, $53, $e3, $03, $64, $54        ;; 05:6636 ????????
    db   $e3, $01, $64, $52, $e3, $04, $62, $20        ;; 05:663e ????????
    db   $66, $64, $4f, $ef, $04, $64, $4f, $f4        ;; 05:6646 ????????
    db   $02, $64, $4f, $ef, $01, $64, $4f, $f6        ;; 05:664e ????????
    db   $01, $64, $4f, $f4, $01, $64, $4f, $ef        ;; 05:6656 ????????
    db   $01, $64, $50, $ef, $03, $64, $51, $ef        ;; 05:665e ????????
    db   $01, $64, $4f, $ef, $04, $62, $47, $66        ;; 05:6666 ????????
    db   $64, $4e, $00, $10, $62, $6e, $66, $43        ;; 05:666e ????????
    db   $94, $46, $94, $4a, $94, $4b, $92, $4a        ;; 05:6676 ????????
    db   $96, $48, $95, $46, $94, $48, $96, $46        ;; 05:667e ????????
    db   $94, $45, $94, $46, $96, $42, $96, $43        ;; 05:6686 ????????
    db   $96, $46, $94, $4a, $92, $4b, $96, $4a        ;; 05:668e ????????
    db   $95, $48, $94, $4a, $9a, $4f, $96, $4d        ;; 05:6696 ????????
    db   $95, $4b, $95, $4a, $94, $48, $94, $47        ;; 05:669e ????????
    db   $94, $48, $94, $43, $94, $44, $94, $41        ;; 05:66a6 ????????
    db   $92, $43, $95, $3f, $94, $41, $94, $3e        ;; 05:66ae ????????
    db   $94, $3f, $94, $3e, $94, $3c, $94, $3e        ;; 05:66b6 ????????
    db   $92, $3f, $95, $3e, $94, $3c, $94, $3f        ;; 05:66be ????????
    db   $94, $3e, $96, $3f, $95, $3c, $98, $24        ;; 05:66c6 ????????
    db   $02, $37, $92, $39, $92, $3a, $94, $3e        ;; 05:66ce ????????
    db   $94, $43, $92, $45, $94, $46, $92, $45        ;; 05:66d6 ????????
    db   $94, $43, $94, $46, $94, $45, $96, $43        ;; 05:66de ????????
    db   $95, $45, $92, $46, $96, $43, $96, $4a        ;; 05:66e6 ????????
    db   $97, $4b, $92, $4a, $95, $48, $94, $4a        ;; 05:66ee ????????
    db   $94, $4b, $94, $4a, $96, $48, $94, $4a        ;; 05:66f6 ????????
    db   $98, $01, $94, $48, $94, $43, $94, $48        ;; 05:66fe ????????
    db   $94, $4a, $92, $4b, $97, $24, $02, $4e        ;; 05:6706 ????????
    db   $94, $4f, $94, $4b, $94, $4a, $94, $48        ;; 05:670e ????????
    db   $92, $4b, $95, $4a, $94, $48, $96, $46        ;; 05:6716 ????????
    db   $96, $45, $94, $46, $94, $43, $97, $45        ;; 05:671e ????????
    db   $94, $46, $96, $48, $94, $46, $94, $48        ;; 05:6726 ????????
    db   $96, $46, $94, $45, $94, $4a, $97, $4d        ;; 05:672e ????????
    db   $94, $51, $96, $4d, $94, $51, $94, $4a        ;; 05:6736 ????????
    db   $96, $4d, $95, $51, $95, $4d, $94, $4a        ;; 05:673e ????????
    db   $94, $4d, $94, $4a, $96, $4d, $95, $51        ;; 05:6746 ????????
    db   $95, $4d, $94, $4a, $94, $4d, $94, $4a        ;; 05:674e ????????
    db   $98, $48, $96, $46, $94, $45, $94, $65        ;; 05:6756 ????????
    db   $37, $96, $3e, $96, $43, $96, $3e, $96        ;; 05:675e ????????
    db   $38, $96, $3f, $96, $44, $96, $3f, $96        ;; 05:6766 ????????
    db   $37, $96, $3e, $96, $43, $96, $3e, $94        ;; 05:676e ????????
    db   $37, $94, $38, $96, $3f, $96, $44, $94        ;; 05:6776 ????????
    db   $3f, $94, $38, $94, $3f, $94, $37, $96        ;; 05:677e ????????
    db   $3e, $96, $43, $96, $3e, $96, $38, $96        ;; 05:6786 ????????
    db   $3f, $96, $44, $96, $3f, $96, $37, $9c        ;; 05:678e ????????
    db   $65, $37, $d2, $38, $d2, $39, $d2, $3a        ;; 05:6796 ????????
    db   $d2, $3b, $d2, $3a, $d2, $39, $d2, $38        ;; 05:679e ????????
    db   $d2, $37, $d2, $38, $d2, $39, $d2, $3a        ;; 05:67a6 ????????
    db   $d2, $3b, $d2, $3a, $d2, $39, $d2, $38        ;; 05:67ae ????????
    db   $d2, $37, $d2, $38, $d2, $39, $d2, $3a        ;; 05:67b6 ????????
    db   $d2, $3b, $d2, $3a, $d2, $39, $d2, $38        ;; 05:67be ????????
    db   $d2, $37, $d2, $38, $d2, $39, $d2, $3a        ;; 05:67c6 ????????
    db   $d2, $3b, $d2, $3a, $d2, $39, $d2, $38        ;; 05:67ce ????????
    db   $d2, $65, $2d, $82, $2d, $84, $2d, $82        ;; 05:67d6 ????????
    db   $2d, $84, $2d, $82, $2d, $84, $2d, $82        ;; 05:67de ????????
    db   $2d, $84, $2b, $84, $2c, $84, $65, $2d        ;; 05:67e6 ????????
    db   $82, $2d, $84, $2d, $82, $2d, $84, $2d        ;; 05:67ee ????????
    db   $82, $2d, $84, $24, $82, $26, $82, $24        ;; 05:67f6 ????????
    db   $82, $26, $82, $24, $82, $21, $82, $1d        ;; 05:67fe ????????
    db   $82, $65, $9f, $14, $9f, $14, $9f, $12        ;; 05:6806 ????????
    db   $9d, $12, $9a, $12, $9f, $14, $9f, $14        ;; 05:680e ????????
    db   $9f, $12, $9f, $12, $9d, $12, $9a, $14        ;; 05:6816 ????????
    db   $9f, $14, $9f, $14, $9f, $12, $9d, $12        ;; 05:681e ????????
    db   $9a, $12, $9f, $14, $9f, $14, $9f, $12        ;; 05:6826 ????????
    db   $a2, $14, $9f, $14, $65, $a6, $12, $a6        ;; 05:682e ????????
    db   $14, $a6, $12, $a6, $14, $a6, $12, $a6        ;; 05:6836 ????????
    db   $14, $a6, $12, $a6, $14, $a4, $14, $a5        ;; 05:683e ????????
    db   $14, $65, $a6, $12, $a6, $14, $a6, $12        ;; 05:6846 ????????
    db   $a6, $14, $a6, $12, $a6, $14, $a4, $12        ;; 05:684e ????????
    db   $a6, $12, $a4, $12, $a6, $12, $a4, $12        ;; 05:6856 ????????
    db   $a1, $12, $9d, $12, $65, $18, $12, $1e        ;; 05:685e ????????
    db   $32, $18, $12, $1e, $32, $1a, $22, $22        ;; 05:6866 ????????
    db   $64, $18, $12, $1e, $32, $18, $12, $1e        ;; 05:686e ????????
    db   $32, $18, $12, $1a, $22, $1e, $32, $18        ;; 05:6876 ????????
    db   $12, $1e, $32, $18, $12, $1e, $32, $18        ;; 05:687e ????????
    db   $12, $1e, $32, $1a, $22, $1e, $32, $18        ;; 05:6886 ????????
    db   $12, $18, $12, $1e, $32, $18, $12, $1e        ;; 05:688e ????????
    db   $32, $18, $12, $1a, $22, $18, $12, $1a        ;; 05:6896 ????????
    db   $22, $22, $62, $65, $67, $ff, $69, $c8        ;; 05:689e ????????
    db   $64, $00, $00, $09, $64, $5c, $e4, $01        ;; 05:68a6 ????????
    db   $64, $5c, $e9, $01, $64, $5c, $e4, $01        ;; 05:68ae ????????
    db   $64, $5d, $e4, $01, $64, $5e, $f0, $02        ;; 05:68b6 ????????
    db   $64, $5f, $f0, $01, $64, $60, $f0, $02        ;; 05:68be ????????
    db   $24, $0a, $64, $5c, $e4, $01, $64, $5c        ;; 05:68c6 ????????
    db   $e9, $01, $64, $5c, $e4, $01, $64, $5d        ;; 05:68ce ????????
    db   $e4, $01, $64, $5e, $f0, $02, $64, $61        ;; 05:68d6 ????????
    db   $f0, $01, $66, $01, $62, $a2, $68, $64        ;; 05:68de ????????
    db   $5a, $fc, $02, $64, $5a, $01, $02, $64        ;; 05:68e6 ????????
    db   $5a, $fc, $02, $64, $5a, $03, $01, $64        ;; 05:68ee ????????
    db   $5a, $01, $01, $64, $5a, $fc, $05, $64        ;; 05:68f6 ????????
    db   $5a, $01, $04, $64, $5a, $fc, $04, $64        ;; 05:68fe ????????
    db   $5a, $03, $02, $64, $5a, $01, $02, $64        ;; 05:6906 ????????
    db   $5a, $fc, $02, $64, $5a, $03, $02, $64        ;; 05:690e ????????
    db   $5a, $fc, $08, $64, $5a, $01, $02, $64        ;; 05:6916 ????????
    db   $5b, $04, $02, $64, $5b, $ff, $02, $64        ;; 05:691e ????????
    db   $5a, $01, $04, $64, $5b, $04, $02, $64        ;; 05:6926 ????????
    db   $5b, $ff, $02, $64, $5a, $01, $02, $64        ;; 05:692e ????????
    db   $5a, $fc, $05, $64, $5a, $01, $04, $64        ;; 05:6936 ????????
    db   $5a, $fc, $04, $64, $5a, $03, $02, $64        ;; 05:693e ????????
    db   $5a, $01, $02, $64, $5a, $fc, $02, $64        ;; 05:6946 ????????
    db   $5a, $03, $02, $64, $5a, $fc, $04, $64        ;; 05:694e ????????
    db   $5a, $01, $01, $64, $5a, $03, $01, $64        ;; 05:6956 ????????
    db   $5a, $fc, $02, $64, $5a, $01, $01, $64        ;; 05:695e ????????
    db   $5a, $03, $01, $64, $5a, $fc, $02, $64        ;; 05:6966 ????????
    db   $5a, $01, $01, $64, $5a, $03, $01, $64        ;; 05:696e ????????
    db   $5b, $04, $01, $64, $5a, $03, $01, $64        ;; 05:6976 ????????
    db   $5a, $fc, $02, $62, $e5, $68, $64, $58        ;; 05:697e ????????
    db   $f0, $02, $64, $58, $f5, $02, $64, $58        ;; 05:6986 ????????
    db   $f0, $02, $64, $58, $f7, $01, $64, $58        ;; 05:698e ????????
    db   $f5, $01, $64, $58, $f0, $05, $64, $58        ;; 05:6996 ????????
    db   $f5, $04, $64, $58, $f0, $04, $64, $58        ;; 05:699e ????????
    db   $f7, $02, $64, $58, $f5, $02, $64, $58        ;; 05:69a6 ????????
    db   $f0, $02, $64, $58, $f7, $02, $64, $58        ;; 05:69ae ????????
    db   $f0, $08, $64, $58, $f5, $02, $64, $59        ;; 05:69b6 ????????
    db   $f8, $02, $64, $59, $f3, $02, $64, $58        ;; 05:69be ????????
    db   $f5, $04, $64, $59, $f8, $02, $64, $59        ;; 05:69c6 ????????
    db   $f3, $02, $64, $58, $f5, $02, $64, $58        ;; 05:69ce ????????
    db   $f0, $05, $64, $58, $f5, $04, $64, $58        ;; 05:69d6 ????????
    db   $f0, $04, $64, $58, $f7, $02, $64, $58        ;; 05:69de ????????
    db   $f5, $02, $64, $58, $f0, $02, $64, $58        ;; 05:69e6 ????????
    db   $f7, $02, $64, $58, $f0, $04, $64, $58        ;; 05:69ee ????????
    db   $f5, $01, $64, $58, $f7, $01, $64, $58        ;; 05:69f6 ????????
    db   $f0, $02, $64, $58, $f5, $01, $64, $58        ;; 05:69fe ????????
    db   $f7, $01, $64, $58, $f0, $02, $64, $58        ;; 05:6a06 ????????
    db   $f5, $01, $64, $58, $f7, $01, $64, $59        ;; 05:6a0e ????????
    db   $f8, $01, $64, $58, $f7, $01, $64, $58        ;; 05:6a16 ????????
    db   $f0, $02, $62, $84, $69, $64, $57, $00        ;; 05:6a1e ????????
    db   $2e, $62, $23, $6a, $24, $04, $39, $82        ;; 05:6a26 ????????
    db   $3c, $82, $3e, $84, $3f, $82, $40, $84        ;; 05:6a2e ????????
    db   $43, $82, $44, $84, $45, $84, $43, $84        ;; 05:6a36 ????????
    db   $45, $84, $43, $82, $45, $82, $48, $84        ;; 05:6a3e ????????
    db   $45, $82, $43, $84, $40, $82, $43, $82        ;; 05:6a46 ????????
    db   $44, $82, $45, $82, $48, $82, $4a, $82        ;; 05:6a4e ????????
    db   $4b, $82, $4c, $84, $4a, $84, $48, $82        ;; 05:6a56 ????????
    db   $45, $84, $43, $84, $45, $82, $43, $82        ;; 05:6a5e ????????
    db   $40, $82, $43, $84, $44, $84, $45, $86        ;; 05:6a66 ????????
    db   $45, $82, $43, $82, $40, $82, $45, $88        ;; 05:6a6e ????????
    db   $24, $02, $65, $24, $04, $4c, $82, $4f        ;; 05:6a76 ????????
    db   $82, $51, $82, $52, $84, $53, $84, $51        ;; 05:6a7e ????????
    db   $82, $4f, $82, $4c, $82, $4f, $82, $51        ;; 05:6a86 ????????
    db   $82, $52, $84, $53, $84, $51, $84, $4f        ;; 05:6a8e ????????
    db   $82, $4c, $84, $4f, $84, $4c, $82, $4a        ;; 05:6a96 ????????
    db   $82, $47, $82, $4a, $84, $4c, $86, $4d        ;; 05:6a9e ????????
    db   $82, $4c, $82, $4a, $84, $45, $82, $4a        ;; 05:6aa6 ????????
    db   $84, $4c, $82, $4d, $82, $50, $82, $51        ;; 05:6aae ????????
    db   $84, $4d, $84, $4a, $84, $4d, $82, $4a        ;; 05:6ab6 ????????
    db   $82, $45, $84, $4a, $82, $45, $82, $41        ;; 05:6abe ????????
    db   $84, $45, $82, $41, $82, $3e, $87, $39        ;; 05:6ac6 ????????
    db   $82, $3c, $82, $3e, $82, $3f, $82, $40        ;; 05:6ace ????????
    db   $82, $43, $82, $44, $82, $45, $82, $48        ;; 05:6ad6 ????????
    db   $82, $4a, $82, $4b, $84, $4c, $84, $4a        ;; 05:6ade ????????
    db   $82, $48, $84, $45, $84, $48, $82, $4a        ;; 05:6ae6 ????????
    db   $82, $4c, $82, $4a, $84, $48, $84, $45        ;; 05:6aee ????????
    db   $84, $48, $86, $51, $82, $52, $82, $53        ;; 05:6af6 ????????
    db   $82, $51, $82, $4f, $82, $4c, $82, $4a        ;; 05:6afe ????????
    db   $82, $4c, $82, $4f, $82, $4c, $82, $4a        ;; 05:6b06 ????????
    db   $82, $47, $82, $4a, $82, $4c, $82, $4a        ;; 05:6b0e ????????
    db   $82, $45, $82, $43, $82, $45, $82, $47        ;; 05:6b16 ????????
    db   $82, $45, $82, $43, $82, $40, $82, $43        ;; 05:6b1e ????????
    db   $84, $45, $84, $47, $84, $43, $84, $65        ;; 05:6b26 ????????
    db   $24, $04, $2d, $84, $34, $84, $2d, $82        ;; 05:6b2e ????????
    db   $34, $84, $2d, $82, $34, $84, $2d, $84        ;; 05:6b36 ????????
    db   $34, $84, $33, $84, $2d, $84, $33, $84        ;; 05:6b3e ????????
    db   $2d, $82, $33, $84, $2d, $82, $33, $82        ;; 05:6b46 ????????
    db   $2d, $82, $30, $82, $32, $82, $33, $82        ;; 05:6b4e ????????
    db   $34, $82, $65, $2d, $86, $30, $86, $34        ;; 05:6b56 ????????
    db   $86, $35, $86, $2d, $88, $24, $04, $2b        ;; 05:6b5e ????????
    db   $84, $28, $84, $2b, $84, $2d, $8b, $2e        ;; 05:6b66 ????????
    db   $80, $2f, $80, $30, $80, $31, $80, $32        ;; 05:6b6e ????????
    db   $80, $33, $80, $34, $80, $35, $80, $36        ;; 05:6b76 ????????
    db   $80, $37, $80, $38, $80, $39, $80, $3a        ;; 05:6b7e ????????
    db   $80, $3b, $80, $3c, $80, $3d, $80, $65        ;; 05:6b86 ????????
    db   $32, $82, $35, $82, $37, $82, $38, $82        ;; 05:6b8e ????????
    db   $39, $84, $3c, $82, $3e, $84, $41, $82        ;; 05:6b96 ????????
    db   $3e, $82, $3c, $82, $39, $82, $3c, $82        ;; 05:6b9e ????????
    db   $3d, $84, $3e, $84, $3c, $84, $39, $82        ;; 05:6ba6 ????????
    db   $37, $84, $39, $84, $37, $82, $35, $82        ;; 05:6bae ????????
    db   $34, $82, $35, $84, $37, $84, $35, $84        ;; 05:6bb6 ????????
    db   $37, $84, $39, $82, $3c, $84, $41, $84        ;; 05:6bbe ????????
    db   $43, $82, $45, $82, $43, $82, $45, $82        ;; 05:6bc6 ????????
    db   $43, $82, $41, $82, $3c, $82, $41, $84        ;; 05:6bce ????????
    db   $43, $84, $45, $82, $43, $84, $41, $84        ;; 05:6bd6 ????????
    db   $3c, $82, $41, $82, $43, $82, $45, $84        ;; 05:6bde ????????
    db   $43, $86, $34, $82, $37, $82, $38, $82        ;; 05:6be6 ????????
    db   $39, $82, $3c, $82, $3e, $82, $40, $84        ;; 05:6bee ????????
    db   $3e, $82, $3c, $84, $39, $82, $37, $82        ;; 05:6bf6 ????????
    db   $39, $82, $3c, $84, $39, $84, $37, $82        ;; 05:6bfe ????????
    db   $34, $84, $37, $85, $35, $84, $34, $87        ;; 05:6c06 ????????
    db   $32, $82, $35, $82, $37, $82, $38, $82        ;; 05:6c0e ????????
    db   $39, $82, $3c, $82, $3d, $82, $3e, $82        ;; 05:6c16 ????????
    db   $41, $82, $43, $82, $45, $84, $43, $84        ;; 05:6c1e ????????
    db   $45, $84, $43, $84, $41, $82, $3e, $84        ;; 05:6c26 ????????
    db   $41, $84, $3e, $82, $3c, $82, $39, $82        ;; 05:6c2e ????????
    db   $3c, $84, $3e, $84, $65, $32, $86, $35        ;; 05:6c36 ????????
    db   $86, $39, $86, $35, $86, $34, $86, $37        ;; 05:6c3e ????????
    db   $86, $3b, $86, $37, $87, $3c, $86, $3b        ;; 05:6c46 ????????
    db   $84, $39, $86, $37, $86, $39, $84, $37        ;; 05:6c4e ????????
    db   $84, $34, $84, $32, $84, $34, $88, $32        ;; 05:6c56 ????????
    db   $82, $35, $82, $37, $82, $38, $82, $39        ;; 05:6c5e ????????
    db   $84, $3c, $82, $3e, $84, $41, $85, $3e        ;; 05:6c66 ????????
    db   $84, $3c, $86, $34, $84, $37, $84, $3b        ;; 05:6c6e ????????
    db   $82, $40, $84, $43, $82, $45, $84, $47        ;; 05:6c76 ????????
    db   $84, $43, $87, $45, $84, $43, $82, $40        ;; 05:6c7e ????????
    db   $84, $3e, $82, $3c, $82, $3e, $82, $40        ;; 05:6c86 ????????
    db   $82, $3e, $82, $3c, $84, $39, $84, $37        ;; 05:6c8e ????????
    db   $84, $39, $82, $3c, $84, $39, $84, $37        ;; 05:6c96 ????????
    db   $82, $34, $82, $37, $82, $39, $84, $37        ;; 05:6c9e ????????
    db   $84, $32, $82, $35, $82, $37, $82, $38        ;; 05:6ca6 ????????
    db   $82, $39, $84, $3c, $82, $3e, $85, $3c        ;; 05:6cae ????????
    db   $84, $39, $84, $3c, $86, $40, $82, $43        ;; 05:6cb6 ????????
    db   $82, $45, $84, $47, $82, $45, $84, $43        ;; 05:6cbe ????????
    db   $82, $40, $82, $43, $82, $45, $84, $47        ;; 05:6cc6 ????????
    db   $84, $48, $84, $47, $84, $45, $84, $47        ;; 05:6cce ????????
    db   $82, $48, $84, $41, $82, $45, $84, $47        ;; 05:6cd6 ????????
    db   $84, $48, $84, $47, $84, $43, $84, $40        ;; 05:6cde ????????
    db   $84, $43, $82, $47, $84, $43, $82, $40        ;; 05:6ce6 ????????
    db   $84, $43, $84, $47, $86, $45, $82, $43        ;; 05:6cee ????????
    db   $82, $40, $84, $3e, $82, $3c, $84, $39        ;; 05:6cf6 ????????
    db   $82, $3c, $82, $3e, $82, $3f, $82, $40        ;; 05:6cfe ????????
    db   $82, $3e, $82, $3c, $82, $39, $8a, $65        ;; 05:6d06 ????????
    db   $24, $04, $a1, $64, $24, $02, $a1, $62        ;; 05:6d0e ????????
    db   $24, $04, $a1, $65, $a1, $62, $24, $04        ;; 05:6d16 ????????
    db   $a1, $64, $65, $24, $04, $a1, $34, $24        ;; 05:6d1e ????????
    db   $02, $a1, $32, $24, $04, $a1, $35, $a1        ;; 05:6d26 ????????
    db   $32, $24, $04, $a1, $34, $65, $a1, $16        ;; 05:6d2e ????????
    db   $9f, $15, $9c, $14, $9c, $12, $9c, $14        ;; 05:6d36 ????????
    db   $9f, $14, $a0, $14, $65, $a1, $16, $9f        ;; 05:6d3e ????????
    db   $15, $9c, $14, $9c, $12, $9c, $14, $9f        ;; 05:6d46 ????????
    db   $14, $a0, $14, $65, $18, $12, $1e, $32        ;; 05:6d4e ????????
    db   $1e, $32, $1e, $32, $1a, $22, $1e, $32        ;; 05:6d56 ????????
    db   $1e, $32, $18, $12, $1e, $32, $18, $12        ;; 05:6d5e ????????
    db   $18, $12, $1e, $32, $1a, $22, $1e, $32        ;; 05:6d66 ????????
    db   $18, $12, $1e, $32, $18, $12, $1e, $32        ;; 05:6d6e ????????
    db   $1e, $32, $1e, $32, $1a, $22, $1e, $32        ;; 05:6d76 ????????
    db   $22, $64, $1e, $32, $18, $12, $18, $12        ;; 05:6d7e ????????
    db   $1e, $32, $1a, $22, $18, $12, $18, $12        ;; 05:6d86 ????????
    db   $22, $62, $65, $67, $ff, $69, $f2, $64        ;; 05:6d8e ????????
    db   $00, $00, $08, $64, $65, $e5, $01, $64        ;; 05:6d96 ????????
    db   $66, $e5, $01, $64, $67, $e5, $01, $64        ;; 05:6d9e ????????
    db   $68, $e5, $01, $66, $01, $62, $91, $6d        ;; 05:6da6 ????????
    db   $64, $64, $e5, $02, $64, $64, $e1, $02        ;; 05:6dae ????????
    db   $64, $64, $e5, $04, $64, $64, $e1, $04        ;; 05:6db6 ????????
    db   $64, $64, $e8, $04, $64, $64, $e5, $01        ;; 05:6dbe ????????
    db   $64, $64, $e1, $02, $64, $64, $e5, $02        ;; 05:6dc6 ????????
    db   $64, $64, $e1, $02, $64, $64, $e5, $01        ;; 05:6dce ????????
    db   $62, $ae, $6d, $64, $63, $f1, $02, $64        ;; 05:6dd6 ????????
    db   $63, $ed, $02, $64, $63, $f1, $04, $64        ;; 05:6dde ????????
    db   $63, $ed, $04, $64, $63, $f4, $04, $64        ;; 05:6de6 ????????
    db   $63, $f1, $01, $64, $63, $ed, $02, $64        ;; 05:6dee ????????
    db   $63, $f1, $02, $64, $63, $ed, $02, $64        ;; 05:6df6 ????????
    db   $63, $f1, $01, $62, $d9, $6d, $64, $62        ;; 05:6dfe ????????
    db   $00, $0c, $62, $04, $6e, $24, $08, $40        ;; 05:6e06 ????????
    db   $98, $47, $98, $48, $9a, $47, $94, $48        ;; 05:6e0e ????????
    db   $96, $40, $94, $47, $9b, $45, $94, $47        ;; 05:6e16 ????????
    db   $96, $48, $94, $4c, $96, $4d, $94, $4c        ;; 05:6e1e ????????
    db   $96, $4a, $94, $48, $96, $4c, $98, $4a        ;; 05:6e26 ????????
    db   $96, $48, $96, $45, $9a, $65, $35, $98        ;; 05:6e2e ????????
    db   $36, $98, $37, $98, $36, $98, $35, $98        ;; 05:6e36 ????????
    db   $38, $98, $37, $98, $35, $98, $35, $98        ;; 05:6e3e ????????
    db   $36, $98, $37, $98, $36, $98, $35, $98        ;; 05:6e46 ????????
    db   $38, $98, $37, $98, $35, $98, $65, $37        ;; 05:6e4e ????????
    db   $96, $3c, $94, $3f, $94, $42, $97, $43        ;; 05:6e56 ????????
    db   $99, $24, $04, $44, $96, $45, $98, $44        ;; 05:6e5e ????????
    db   $97, $43, $99, $24, $04, $48, $94, $4a        ;; 05:6e66 ????????
    db   $94, $4b, $96, $48, $96, $4a, $94, $47        ;; 05:6e6e ????????
    db   $96, $48, $96, $43, $94, $44, $94, $41        ;; 05:6e76 ????????
    db   $94, $43, $94, $3f, $94, $41, $94, $3e        ;; 05:6e7e ????????
    db   $94, $3b, $99, $3c, $94, $3e, $94, $3c        ;; 05:6e86 ????????
    db   $9a, $65, $24, $08, $34, $94, $39, $96        ;; 05:6e8e ????????
    db   $3c, $94, $3f, $98, $40, $98, $35, $94        ;; 05:6e96 ????????
    db   $37, $94, $37, $94, $37, $96, $35, $94        ;; 05:6e9e ????????
    db   $35, $94, $35, $94, $35, $94, $38, $94        ;; 05:6ea6 ????????
    db   $38, $94, $38, $97, $37, $96, $35, $94        ;; 05:6eae ????????
    db   $38, $96, $3c, $97, $41, $94, $43, $94        ;; 05:6eb6 ????????
    db   $44, $96, $41, $96, $43, $96, $44, $96        ;; 05:6ebe ????????
    db   $45, $94, $48, $96, $4c, $97, $4b, $94        ;; 05:6ec6 ????????
    db   $4c, $96, $48, $94, $45, $96, $44, $96        ;; 05:6ece ????????
    db   $45, $96, $40, $96, $3e, $96, $40, $94        ;; 05:6ed6 ????????
    db   $3c, $96, $39, $96, $39, $94, $3b, $94        ;; 05:6ede ????????
    db   $3c, $96, $3e, $94, $40, $96, $41, $96        ;; 05:6ee6 ????????
    db   $43, $94, $43, $97, $41, $94, $41, $96        ;; 05:6eee ????????
    db   $44, $96, $44, $96, $43, $94, $41, $94        ;; 05:6ef6 ????????
    db   $40, $94, $41, $96, $3c, $96, $38, $94        ;; 05:6efe ????????
    db   $37, $96, $35, $96, $37, $96, $38, $96        ;; 05:6f06 ????????
    db   $35, $94, $38, $94, $3c, $94, $39, $9c        ;; 05:6f0e ????????
    db   $65, $40, $d4, $39, $d4, $3c, $d4, $40        ;; 05:6f16 ????????
    db   $d4, $41, $d4, $39, $d4, $3c, $d4, $41        ;; 05:6f1e ????????
    db   $d4, $42, $d4, $39, $d4, $3c, $d4, $42        ;; 05:6f26 ????????
    db   $d4, $41, $d4, $39, $d4, $3c, $d4, $41        ;; 05:6f2e ????????
    db   $d4, $65, $a1, $16, $a1, $16, $ad, $14        ;; 05:6f36 ????????
    db   $ab, $16, $a8, $16, $a6, $14, $a4, $14        ;; 05:6f3e ????????
    db   $a6, $14, $a7, $14, $a8, $14, $a6, $14        ;; 05:6f46 ????????
    db   $a4, $14, $65, $18, $12, $1e, $32, $18        ;; 05:6f4e ????????
    db   $12, $1e, $32, $22, $64, $18, $12, $1e        ;; 05:6f56 ????????
    db   $32, $1a, $22, $1e, $32, $1e, $32, $1e        ;; 05:6f5e ????????
    db   $32, $1e, $32, $1e, $32, $18, $12, $22        ;; 05:6f66 ????????
    db   $64, $1e, $32, $18, $12, $1e, $32, $18        ;; 05:6f6e ????????
    db   $12, $1e, $32, $1e, $34, $1a, $22, $1e        ;; 05:6f76 ????????
    db   $32, $18, $12, $1e, $32, $18, $12, $1e        ;; 05:6f7e ????????
    db   $32, $18, $12, $1e, $32, $18, $12, $1e        ;; 05:6f86 ????????
    db   $32, $1e, $32, $1e, $32, $18, $12, $22        ;; 05:6f8e ????????
    db   $62, $1e, $32, $1e, $32, $1a, $22, $1e        ;; 05:6f96 ????????
    db   $32, $1e, $32, $1e, $32, $22, $64, $18        ;; 05:6f9e ????????
    db   $12, $1e, $32, $1e, $32, $1e, $32, $18        ;; 05:6fa6 ????????
    db   $12, $1e, $32, $18, $12, $1e, $32, $18        ;; 05:6fae ????????
    db   $12, $1e, $32, $1a, $22, $1e, $32, $1e        ;; 05:6fb6 ????????
    db   $32, $1e, $32, $1a, $22, $1a, $22, $1a        ;; 05:6fbe ????????
    db   $22, $22, $62, $65, $67, $ff, $69, $be        ;; 05:6fc6 ????????
    db   $64, $69, $e4, $01, $66, $01, $62, $ca        ;; 05:6fce ????????
    db   $6f, $64, $6a, $e4, $01, $62, $d7, $6f        ;; 05:6fd6 ????????
    db   $64, $6b, $f0, $01, $62, $de, $6f, $1a        ;; 05:6fde ????????
    db   $26, $1a, $2d, $1a, $2d, $1a, $2d, $1a        ;; 05:6fe6 ????????
    db   $26, $1a, $2d, $1a, $2d, $1a, $2d, $1a        ;; 05:6fee ????????
    db   $26, $1a, $2d, $1a, $2d, $1a, $2d, $1a        ;; 05:6ff6 ????????
    db   $2d, $1a, $2d, $1a, $2d, $1a, $2d, $1a        ;; 05:6ffe ????????
    db   $2d, $1a, $2d, $62, $e5, $6f, $42, $86        ;; 05:7006 ????????
    db   $42, $8d, $40, $8d, $3e, $8d, $40, $86        ;; 05:700e ????????
    db   $40, $8d, $40, $8d, $40, $8d, $42, $86        ;; 05:7016 ????????
    db   $42, $8d, $40, $8d, $3e, $8d, $40, $86        ;; 05:701e ????????
    db   $40, $8d, $3c, $8d, $40, $8d, $42, $86        ;; 05:7026 ????????
    db   $42, $8d, $40, $8d, $42, $8d, $43, $86        ;; 05:702e ????????
    db   $43, $8d, $42, $8d, $43, $8d, $45, $86        ;; 05:7036 ????????
    db   $45, $8d, $43, $8d, $41, $8d, $43, $8e        ;; 05:703e ????????
    db   $40, $8e, $3c, $8e, $45, $86, $45, $8d        ;; 05:7046 ????????
    db   $43, $8d, $41, $8d, $43, $8e, $40, $8e        ;; 05:704e ????????
    db   $3c, $8e, $3e, $86, $3e, $8d, $3c, $8d        ;; 05:7056 ????????
    db   $3e, $8d, $40, $86, $44, $86, $47, $8d        ;; 05:705e ????????
    db   $47, $8d, $47, $8d, $44, $8d, $44, $8d        ;; 05:7066 ????????
    db   $44, $8d, $47, $8d, $47, $8d, $47, $8d        ;; 05:706e ????????
    db   $44, $8d, $40, $8d, $3b, $8d, $3b, $8d        ;; 05:7076 ????????
    db   $3b, $8d, $3b, $8d, $40, $8d, $3b, $8d        ;; 05:707e ????????
    db   $40, $8d, $40, $86, $40, $8d, $40, $8d        ;; 05:7086 ????????
    db   $40, $8d, $65, $39, $86, $39, $86, $3c        ;; 05:708e ????????
    db   $86, $3c, $8d, $3c, $8d, $3c, $8d, $39        ;; 05:7096 ????????
    db   $86, $39, $86, $3c, $86, $3c, $8d, $39        ;; 05:709e ????????
    db   $8d, $3c, $8d, $39, $86, $39, $86, $3b        ;; 05:70a6 ????????
    db   $86, $3b, $86, $3c, $86, $3c, $86, $40        ;; 05:70ae ????????
    db   $8e, $3c, $8e, $37, $8e, $3c, $86, $3c        ;; 05:70b6 ????????
    db   $86, $40, $8e, $3c, $8e, $37, $8e, $39        ;; 05:70be ????????
    db   $86, $39, $86, $3b, $86, $40, $86, $44        ;; 05:70c6 ????????
    db   $8d, $44, $8d, $44, $8d, $40, $8d, $40        ;; 05:70ce ????????
    db   $8d, $40, $8d, $44, $8d, $40, $8e, $40        ;; 05:70d6 ????????
    db   $8d, $3b, $8d, $38, $8d, $38, $8d, $38        ;; 05:70de ????????
    db   $8d, $38, $8d, $38, $8d, $38, $8d, $38        ;; 05:70e6 ????????
    db   $8d, $38, $86, $3c, $8d, $3c, $8d, $3c        ;; 05:70ee ????????
    db   $8d, $65, $a6, $16, $a6, $1d, $a4, $1d        ;; 05:70f6 ????????
    db   $a3, $1d, $a1, $16, $a1, $1d, $a1, $1d        ;; 05:70fe ????????
    db   $a1, $1d, $a6, $16, $a6, $1d, $a4, $1d        ;; 05:7106 ????????
    db   $a3, $1d, $a1, $16, $a1, $1d, $a1, $1d        ;; 05:710e ????????
    db   $a1, $1d, $a6, $16, $a6, $1d, $a6, $1d        ;; 05:7116 ????????
    db   $a6, $1d, $a8, $16, $a8, $1d, $a8, $1d        ;; 05:711e ????????
    db   $a8, $1d, $a9, $16, $a9, $1d, $a8, $1d        ;; 05:7126 ????????
    db   $a6, $1d, $a4, $1e, $a4, $1e, $a4, $1e        ;; 05:712e ????????
    db   $a9, $16, $a9, $1d, $a8, $1d, $a6, $1d        ;; 05:7136 ????????
    db   $a4, $1e, $a4, $1e, $a4, $1e, $a6, $16        ;; 05:713e ????????
    db   $a6, $1d, $a6, $1d, $a6, $1d, $a8, $16        ;; 05:7146 ????????
    db   $a8, $16, $a8, $1d, $a8, $1d, $a8, $1d        ;; 05:714e ????????
    db   $a8, $1d, $a8, $1d, $a8, $1d, $a8, $1d        ;; 05:7156 ????????
    db   $a8, $1d, $a8, $1d, $a8, $1d, $a8, $1d        ;; 05:715e ????????
    db   $a8, $1d, $a8, $1d, $a8, $1d, $a8, $1d        ;; 05:7166 ????????
    db   $a8, $1d, $a8, $1d, $a8, $1d, $a8, $16        ;; 05:716e ????????
    db   $a1, $1d, $a1, $1d, $a1, $1d, $65             ;; 05:7176 ???????

data_05_717d:
    db   $36, $54, $3f, $54, $42, $54, $45, $54        ;; 05:717d ????????
    db   $e1, $71, $48, $54, $75, $54, $a0, $54        ;; 05:7185 ????????
    db   $c3, $54, $e1, $71, $db, $59, $18, $5a        ;; 05:718d ????????
    db   $3f, $5a, $6a, $5a, $e1, $71, $c8, $5f        ;; 05:7195 ????????
    db   $d9, $5f, $e4, $5f, $eb, $5f, $e1, $71        ;; 05:719d ????????
    db   $09, $61, $3e, $61, $6d, $61, $9c, $61        ;; 05:71a5 ????????
    db   $e1, $71                                      ;; 05:71ad ??
    dw   data_05_653c                                  ;; 05:71af pP
    dw   data_05_6549                                  ;; 05:71b1 pP
    dw   data_05_6550                                  ;; 05:71b3 pP
    dw   data_05_6557                                  ;; 05:71b5 pP
    db   $e1, $71, $0b, $66, $20, $66, $47, $66        ;; 05:71b7 .P??????
    db   $6e, $66, $e1, $71, $a2, $68, $e5, $68        ;; 05:71bf ????????
    db   $84, $69, $23, $6a, $e1, $71, $91, $6d        ;; 05:71c7 ????????
    db   $ae, $6d, $d9, $6d, $04, $6e, $e1, $71        ;; 05:71cf ????????
    db   $ca, $6f, $d7, $6f, $de, $6f, $e5, $6f        ;; 05:71d7 ????????
    db   $e1, $71, $03, $04, $06, $09, $0c, $12        ;; 05:71df ??.?.???
    db   $18, $24, $30, $48, $60, $90, $c0, $08        ;; 05:71e7 ?????.?.
    db   $10, $20                                      ;; 05:71ef ??

data_05_71f1:
    dw   data_05_7231                                  ;; 05:71f1 pP
    db   $3d, $72, $49, $72, $55, $72, $61, $72        ;; 05:71f3 ????????
    db   $6d, $72, $79, $72, $85, $72                  ;; 05:71fb ??????
    dw   data_05_7291                                  ;; 05:7201 pP
    db   $9d, $72, $a9, $72, $b5, $72, $c1, $72        ;; 05:7203 ????????
    db   $cd, $72, $d9, $72, $e5, $72, $f1, $72        ;; 05:720b ????????
    db   $fd, $72                                      ;; 05:7213 ??
    dw   data_05_7309                                  ;; 05:7215 pP
    db   $15, $73, $21, $73, $2d, $73, $39, $73        ;; 05:7217 ????????
    db   $45, $73, $51, $73, $5d, $73, $69, $73        ;; 05:721f ????????
    db   $75, $73, $81, $73, $8d, $73, $99, $73        ;; 05:7227 ????????
    db   $a5, $73                                      ;; 05:722f ??

data_05_7231:
    db   $80, $00, $02, $00, $00, $00, $00, $00        ;; 05:7231 ........
    db   $00, $00, $00, $00, $c0, $bd, $00, $01        ;; 05:7239 ....????
    db   $b1, $73, $01, $52, $75, $00, $00, $00        ;; 05:7241 ????????
    db   $80, $80, $00, $01, $ba, $73, $01, $55        ;; 05:7249 ????????
    db   $75, $00, $00, $00, $c0, $bb, $61, $00        ;; 05:7251 ????????
    db   $00, $00, $01, $76, $75, $00, $00, $00        ;; 05:7259 ????????
    db   $80, $80, $00, $01, $c7, $73, $00, $00        ;; 05:7261 ????????
    db   $00, $01, $eb, $75, $80, $00, $00, $01        ;; 05:7269 ????????
    db   $d4, $73, $01, $79, $75, $00, $00, $00        ;; 05:7271 ????????
    db   $80, $80, $00, $01, $e1, $73, $01, $7e        ;; 05:7279 ????????
    db   $75, $00, $00, $00, $80, $80, $00, $01        ;; 05:7281 ????????
    db   $ec, $73, $00, $00, $00, $01, $4e, $76        ;; 05:7289 ????????

data_05_7291:
    db   $80, $80, $00, $01                            ;; 05:7291 ....
    dw   data_05_73fb                                  ;; 05:7295 pP
    db   $00, $00, $00, $01                            ;; 05:7297 ....
    dw   data_05_766d                                  ;; 05:729b pP
    db   $80, $80, $00, $01, $23, $74, $00, $00        ;; 05:729d ????????
    db   $00, $01, $bf, $76, $80, $80, $00, $01        ;; 05:72a5 ????????
    db   $84, $74, $04, $89, $75, $00, $00, $00        ;; 05:72ad ????????
    db   $80, $40, $00, $01, $91, $74, $04, $89        ;; 05:72b5 ????????
    db   $75, $05, $bf, $76, $80, $80, $00, $01        ;; 05:72bd ????????
    db   $a0, $74, $0c, $94, $75, $00, $00, $00        ;; 05:72c5 ????????
    db   $80, $00, $00, $01, $b7, $74, $01, $89        ;; 05:72cd ????????
    db   $75, $00, $00, $00, $80, $40, $00, $01        ;; 05:72d5 ????????
    db   $c4, $74, $02, $bf, $75, $00, $00, $00        ;; 05:72dd ????????
    db   $80, $80, $00, $01, $d3, $74, $0c, $94        ;; 05:72e5 ????????
    db   $75, $00, $00, $00, $c0, $00, $00, $01        ;; 05:72ed ????????
    db   $e6, $74, $01, $ca, $75, $00, $00, $00        ;; 05:72f5 ????????
    db   $c0, $00, $00, $01, $ef, $74, $01, $ca        ;; 05:72fd ????????
    db   $75, $00, $00, $00                            ;; 05:7305 ????

data_05_7309:
    db   $c0, $00, $00, $01                            ;; 05:7309 ....
    dw   data_05_74f8                                  ;; 05:730d pP
    db   $01                                           ;; 05:730f .
    dw   $75ca                                         ;; 05:7310 wP
    db   $00, $00, $00, $80, $40, $47, $00, $00        ;; 05:7312 ...?????
    db   $00, $00, $00, $00, $01, $ce, $76, $80        ;; 05:731a ????????
    db   $40, $47, $00, $00, $00, $00, $00, $00        ;; 05:7322 ????????
    db   $01, $dd, $76, $80, $40, $47, $00, $00        ;; 05:732a ????????
    db   $00, $00, $00, $00, $01, $ec, $76, $80        ;; 05:7332 ????????
    db   $40, $47, $00, $00, $00, $00, $00, $00        ;; 05:733a ????????
    db   $01, $fb, $76, $80, $40, $47, $00, $00        ;; 05:7342 ????????
    db   $00, $00, $00, $00, $01, $0a, $77, $80        ;; 05:734a ????????
    db   $40, $47, $00, $00, $00, $00, $00, $00        ;; 05:7352 ????????
    db   $01, $19, $77, $c0, $00, $00, $01, $03        ;; 05:735a ????????
    db   $75, $01, $ca, $75, $00, $00, $00, $80        ;; 05:7362 ????????
    db   $40, $00, $01, $15, $75, $00, $00, $00        ;; 05:736a ????????
    db   $01, $28, $77, $80, $80, $00, $01, $22        ;; 05:7372 ????????
    db   $75, $01, $d5, $75, $00, $00, $00, $80        ;; 05:737a ????????
    db   $00, $30, $00, $00, $00, $01, $94, $75        ;; 05:7382 ????????
    db   $01, $37, $77, $80, $00, $30, $00, $00        ;; 05:738a ????????
    db   $00, $01, $94, $75, $01, $5a, $77, $c0        ;; 05:7392 ????????
    db   $80, $00, $01, $43, $75, $00, $00, $00        ;; 05:739a ????????
    db   $01, $ce, $76, $80, $80, $00, $01, $43        ;; 05:73a2 ????????
    db   $75, $00, $00, $00, $01, $fb, $76, $f0        ;; 05:73aa ????????
    db   $01, $00, $01, $70, $01, $00, $01, $ff        ;; 05:73b2 ????????
    db   $c0, $01, $40, $02, $30, $01, $20, $02        ;; 05:73ba ????????
    db   $10, $05, $00, $01, $ff, $20, $08, $50        ;; 05:73c2 ????????
    db   $08, $90, $04, $40, $40, $20, $20, $00        ;; 05:73ca ????????
    db   $01, $ff, $50, $02, $30, $04, $20, $08        ;; 05:73d2 ????????
    db   $10, $02, $10, $02, $00, $01, $ff, $40        ;; 05:73da ????????
    db   $01, $30, $0a, $20, $0a, $10, $0a, $00        ;; 05:73e2 ????????
    db   $01, $ff, $f0, $02, $80, $02, $60, $02        ;; 05:73ea ????????
    db   $30, $01, $20, $02, $10, $02, $00, $01        ;; 05:73f2 ????????
    db   $ff                                           ;; 05:73fa ?

data_05_73fb:
    db   $70, $01, $30, $02, $60, $01, $30, $02        ;; 05:73fb ........
    db   $50, $01, $20, $02, $40, $01, $20, $02        ;; 05:7403 ....????
    db   $30, $01, $10, $02, $20, $01, $10, $02        ;; 05:740b ????????
    db   $10, $28, $00, $01, $ff, $80, $01, $40        ;; 05:7413 ????????
    db   $01, $00, $02, $10, $01, $00, $01, $ff        ;; 05:741b ????????
    db   $40, $04, $00, $04, $40, $04, $00, $04        ;; 05:7423 ????????
    db   $50, $04, $00, $04, $50, $04, $00, $04        ;; 05:742b ????????
    db   $40, $04, $00, $04, $40, $04, $00, $04        ;; 05:7433 ????????
    db   $00, $04, $30, $04, $00, $04, $30, $04        ;; 05:743b ????????
    db   $00, $04, $30, $04, $00, $04, $30, $04        ;; 05:7443 ????????
    db   $00, $04, $30, $04, $00, $04, $30, $04        ;; 05:744b ????????
    db   $00, $04, $20, $04, $00, $04, $20, $04        ;; 05:7453 ????????
    db   $00, $05, $20, $05, $00, $05, $20, $05        ;; 05:745b ????????
    db   $00, $05, $10, $05, $00, $05, $10, $05        ;; 05:7463 ????????
    db   $00, $06, $10, $06, $00, $06, $10, $06        ;; 05:746b ????????
    db   $00, $06, $10, $06, $00, $06, $10, $06        ;; 05:7473 ????????
    db   $00, $06, $10, $06, $00, $06, $10, $06        ;; 05:747b ????????
    db   $ff, $60, $01, $40, $04, $30, $14, $20        ;; 05:7483 ????????
    db   $3c, $10, $3c, $00, $01, $ff, $50, $02        ;; 05:748b ????????
    db   $40, $06, $30, $1e, $20, $24, $10, $20        ;; 05:7493 ????????
    db   $10, $40, $00, $01, $ff, $10, $02, $20        ;; 05:749b ????????
    db   $01, $30, $01, $60, $03, $50, $32, $50        ;; 05:74a3 ????????
    db   $0a, $40, $0a, $30, $0a, $20, $1e, $10        ;; 05:74ab ????????
    db   $1e, $00, $01, $ff, $40, $01, $30, $0c        ;; 05:74b3 ????????
    db   $20, $14, $10, $3c, $10, $3c, $00, $01        ;; 05:74bb ????????
    db   $ff, $60, $02, $50, $02, $40, $03, $30        ;; 05:74c3 ????????
    db   $0a, $20, $28, $10, $28, $00, $01, $ff        ;; 05:74cb ????????
    db   $10, $02, $20, $01, $30, $01, $40, $14        ;; 05:74d3 ????????
    db   $30, $50, $20, $0a, $10, $0a, $10, $0a        ;; 05:74db ????????
    db   $00, $01, $ff, $20, $0a, $40, $5a, $60        ;; 05:74e3 ????????
    db   $f0, $00, $01, $ff, $20, $04, $40, $14        ;; 05:74eb ????????
    db   $60, $0a, $00, $01, $ff                       ;; 05:74f3 ?????

data_05_74f8:
    db   $20, $04, $40, $50, $60, $f0, $60, $f0        ;; 05:74f8 ....????
    db   $00, $01, $ff, $20, $01, $40, $14, $60        ;; 05:7500 ????????
    db   $64, $00, $01, $ff, $20, $04, $40, $c8        ;; 05:7508 ????????
    db   $40, $64, $60, $28, $ff, $50, $04, $40        ;; 05:7510 ????????
    db   $0a, $30, $14, $20, $28, $10, $1e, $00        ;; 05:7518 ????????
    db   $01, $ff, $60, $01, $40, $3a, $20, $32        ;; 05:7520 ????????
    db   $00, $01, $ff, $20, $05, $30, $05, $40        ;; 05:7528 ????????
    db   $05, $70, $c8, $50, $c8, $30, $c8, $00        ;; 05:7530 ????????
    db   $01, $ff, $c0, $01, $00, $01, $30, $01        ;; 05:7538 ????????
    db   $00, $01, $ff, $20, $0a, $10, $0a, $20        ;; 05:7540 ????????
    db   $0a, $30, $0a, $40, $14, $50, $64, $60        ;; 05:7548 ????????
    db   $64, $ff, $61, $c8, $7e, $37, $02, $64        ;; 05:7550 ????????
    db   $02, $22, $01, $37, $01, $22, $01, $37        ;; 05:7558 ????????
    db   $01, $22, $01, $22, $01, $37, $01, $22        ;; 05:7560 ????????
    db   $01, $37, $01, $22, $01, $37, $01, $22        ;; 05:7568 ????????
    db   $01, $37, $01, $22, $10, $7e, $12, $c8        ;; 05:7570 ????????
    db   $7e, $22, $01, $10, $c8, $7e, $21, $c8        ;; 05:7578 ????????
    db   $22, $c8, $23, $0a, $43, $0a, $44, $c8        ;; 05:7580 ????????
    db   $7e, $02, $03, $fe, $03, $fe, $03, $02        ;; 05:7588 ????????
    db   $03, $7d, $89, $75, $01, $03, $ff, $03        ;; 05:7590 ????????
    db   $ff, $03, $01, $03, $01, $03, $ff, $03        ;; 05:7598 ????????
    db   $ff, $03, $01, $03, $01, $03, $ff, $03        ;; 05:75a0 ????????
    db   $ff, $03, $01, $03, $01, $03, $ff, $03        ;; 05:75a8 ????????
    db   $ff, $03, $01, $03, $02, $03, $fe, $03        ;; 05:75b0 ????????
    db   $fe, $03, $02, $03, $7d, $b4, $75, $01        ;; 05:75b8 ????????
    db   $02, $ff, $02, $01, $02, $ff, $02, $7d        ;; 05:75c0 ????????
    db   $89, $75, $06, $02, $fa, $02, $fa, $02        ;; 05:75c8 ??......
    db   $06, $02, $7d                                 ;; 05:75d0 ...
    dw   $75ca                                         ;; 05:75d3 wP
    db   $fd, $02, $03, $02, $03, $02, $fd, $02        ;; 05:75d5 ????????
    db   $7d, $d5, $75, $0d, $03, $f3, $03, $f3        ;; 05:75dd ????????
    db   $03, $0d, $03, $7d, $89, $75, $03, $24        ;; 05:75e5 ????????
    db   $01, $00, $03, $23, $01, $00, $03, $22        ;; 05:75ed ????????
    db   $01, $00, $03, $21, $01, $00, $03, $1f        ;; 05:75f5 ????????
    db   $01, $00, $03, $1e, $01, $00, $03, $1d        ;; 05:75fd ????????
    db   $01, $00, $03, $1c, $01, $00, $03, $1b        ;; 05:7605 ????????
    db   $01, $00, $03, $1a, $01, $00, $03, $19        ;; 05:760d ????????
    db   $01, $00, $03, $18, $01, $00, $03, $17        ;; 05:7615 ????????
    db   $01, $00, $03, $16, $01, $00, $03, $15        ;; 05:761d ????????
    db   $01, $00, $03, $14, $01, $00, $03, $13        ;; 05:7625 ????????
    db   $01, $00, $03, $12, $01, $00, $03, $11        ;; 05:762d ????????
    db   $01, $00, $03, $10, $01, $00, $03, $0f        ;; 05:7635 ????????
    db   $01, $00, $03, $0e, $01, $00, $03, $0d        ;; 05:763d ????????
    db   $01, $00, $03, $0c, $01, $00, $ff, $eb        ;; 05:7645 ????????
    db   $75, $01, $ff, $01, $fe, $01, $fd, $01        ;; 05:764d ????????
    db   $fc, $01, $fb, $01, $fa, $01, $f9, $01        ;; 05:7655 ????????
    db   $f8, $01, $f7, $01, $f6, $01, $f5, $01        ;; 05:765d ????????
    db   $f4, $01, $f3, $c8, $f3, $ff, $4e, $76        ;; 05:7665 ????????

data_05_766d:
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:766d ......??
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:7675 ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:767d ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:7685 ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:768d ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:7695 ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:769d ????????
    db   $03, $00, $03, $f4, $03, $00, $03, $f4        ;; 05:76a5 ????????
    db   $ff, $6d, $76, $03, $00, $03, $0c, $03        ;; 05:76ad ????????
    db   $00, $03, $0c, $03, $00, $03, $0c, $ff        ;; 05:76b5 ????????
    db   $b0, $76, $04, $0c, $04, $00, $04, $0c        ;; 05:76bd ????????
    db   $04, $00, $04, $0c, $04, $00, $ff, $bf        ;; 05:76c5 ????????
    db   $76, $01, $00, $01, $04, $01, $07, $01        ;; 05:76cd ????????
    db   $00, $01, $04, $01, $07, $ff, $ce, $76        ;; 05:76d5 ????????
    db   $01, $04, $01, $07, $01, $0c, $01, $04        ;; 05:76dd ????????
    db   $01, $07, $01, $0c, $ff, $dd, $76, $01        ;; 05:76e5 ????????
    db   $07, $01, $0c, $01, $10, $01, $07, $01        ;; 05:76ed ????????
    db   $0c, $01, $10, $ff, $ec, $76, $01, $00        ;; 05:76f5 ????????
    db   $01, $03, $01, $07, $01, $00, $01, $03        ;; 05:76fd ????????
    db   $01, $07, $ff, $fb, $76, $01, $03, $01        ;; 05:7705 ????????
    db   $07, $01, $0c, $01, $03, $01, $07, $01        ;; 05:770d ????????
    db   $0c, $ff, $0a, $77, $01, $07, $01, $0c        ;; 05:7715 ????????
    db   $01, $0f, $01, $07, $01, $0c, $01, $0f        ;; 05:771d ????????
    db   $ff, $19, $77, $02, $0c, $02, $00, $02        ;; 05:7725 ????????
    db   $0c, $02, $00, $02, $0c, $02, $00, $ff        ;; 05:772d ????????
    db   $28, $77, $06, $00, $06, $02, $06, $03        ;; 05:7735 ????????
    db   $06, $07, $06, $0c, $06, $0e, $06, $0f        ;; 05:773d ????????
    db   $06, $13, $06, $18, $06, $13, $06, $0f        ;; 05:7745 ????????
    db   $06, $0e, $06, $0c, $06, $07, $06, $03        ;; 05:774d ????????
    db   $06, $02, $ff, $37, $77, $06, $00, $06        ;; 05:7755 ????????
    db   $02, $06, $04, $06, $07, $06, $0c, $06        ;; 05:775d ????????
    db   $0e, $06, $10, $06, $13, $06, $18, $06        ;; 05:7765 ????????
    db   $13, $06, $10, $06, $0e, $06, $0c, $06        ;; 05:776d ????????
    db   $07, $06, $04, $06, $02, $ff, $5a, $77        ;; 05:7775 ????????

data_05_777d:
    db   $d6, $54, $3c, $59, $61, $59, $9a, $59        ;; 05:777d ????????
    db   $5a, $58, $83, $58, $8c, $58, $a1, $58        ;; 05:7785 ????????
    db   $c3, $58, $ea, $58, $13, $59, $4a, $56        ;; 05:778d ????????
    db   $5b, $56, $8c, $56, $0d, $57, $42, $57        ;; 05:7795 ????????
    db   $73, $57, $08, $58, $31, $58, $d9, $54        ;; 05:779d ????????
    db   $0a, $55, $35, $55, $b6, $55, $f7, $55        ;; 05:77a5 ????????
    db   $20, $56, $41, $56, $10, $5f, $3f, $5f        ;; 05:77ad ????????
    db   $78, $5f, $9d, $5f, $43, $5e, $58, $5e        ;; 05:77b5 ????????
    db   $7b, $5e, $8c, $5e, $a3, $5e, $b4, $5e        ;; 05:77bd ????????
    db   $e9, $5e, $a7, $5b, $ec, $5b, $65, $5c        ;; 05:77c5 ????????
    db   $82, $5c, $b9, $5c, $da, $5c, $69, $5d        ;; 05:77cd ????????
    db   $96, $5d, $81, $5a, $aa, $5a, $cb, $5a        ;; 05:77d5 ????????
    db   $e4, $5a, $f5, $5a, $56, $5b, $ee, $5f        ;; 05:77dd ????????
    db   $69, $60, $8a, $60, $c3, $60, $e4, $60        ;; 05:77e5 ????????
    db   $17, $65, $17, $64, $36, $64, $75, $64        ;; 05:77ed ????????
    db   $a4, $64, $d7, $64, $fa, $64, $dd, $62        ;; 05:77f5 ????????
    db   $e6, $62, $27, $63, $96, $63, $bf, $63        ;; 05:77fd ????????
    db   $ce, $63, $a3, $61, $ac, $61, $d1, $61        ;; 05:7805 ????????
    db   $50, $62, $85, $62, $94, $62                  ;; 05:780d ??????
    dw   data_05_655a                                  ;; 05:7813 pP
    dw   data_05_65b1                                  ;; 05:7815 pP
    dw   data_05_6606                                  ;; 05:7817 pP
    db   $63, $68, $08, $68, $33, $68, $48, $68        ;; 05:7819 ????????
    db   $97, $67, $d8, $67, $ed, $67, $75, $66        ;; 05:7821 ????????
    db   $5e, $67, $52, $6d, $34, $6d, $43, $6d        ;; 05:7829 ????????
    db   $0e, $6d, $21, $6d, $2a, $6a, $79, $6a        ;; 05:7831 ????????
    db   $2e, $6b, $59, $6b, $8e, $6b, $3b, $6c        ;; 05:7839 ????????
    db   $51, $6f, $38, $6f, $17, $6f, $0b, $6e        ;; 05:7841 ????????
    db   $34, $6e, $55, $6e, $90, $6e, $0c, $70        ;; 05:7849 ????????
    db   $91, $70, $f8, $70                            ;; 05:7851 ????
