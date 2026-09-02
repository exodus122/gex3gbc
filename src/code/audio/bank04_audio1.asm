; ==================================================================
; SOUND DRIVER
;
; Banks $04 and $05 each hold a byte-for-byte identical copy of this driver followed by
; their own song, instrument and sound effect data. Only three bytes differ between the
; two copies - the operands of the three instructions that point at this bank's own song
; table, instrument table and pattern table. A song is addressed as (bank, id) and the
; bank is switched by wDE60_CurrentAudioBank before any entry point here is called.
;
; gex2 splits its driver across four banks the same way, but there the whole $4000-$445f
; block is identical and every bank-local address is reached through one WRAM pointer -
; see gex2's code/audio/bank21_audio1.asm.
;
; THE JUMP TABLE at $4000 is the driver's whole public interface: thirteen three-byte
; vectors, so bank 0 can call a fixed address without caring where anything moved.
; Only four are ever used:
;
;   $4000 Audio_Init      once, at boot                       (call_00_0150_Init)
;   $4006 Audio_PlayMusic start song A of this bank           (call_00_0fa2_SetupMusic)
;   $4009 Audio_Update    once per frame, from vblank         (call_00_0b25_VBlank_Handler)
;   $4024 Audio_PlaySfx   start sound effect id A             (call_00_0fd7_PlaySFX)
;
; The other nine - update one half only, pause, resume, master volume up and down, stop,
; set tempo, start a single sfx track - are reachable but dead. gex2 exposes only four
; entry points and has no vector table at all.
;
; FOUR CHANNEL BLOCKS, ONE PER HARDWARE CHANNEL. wDF00, wDF18, wDF30 and wDF48 are
; 24-byte structures with identical layout - see AUDIO_CH_* and the wDF00 block in
; memory.asm. Everything a channel is doing lives there: where it is in its pattern, the
; shadow copies of its four NRxy registers, and the three per-instrument sub-sequences
; (volume envelope, pitch slide, arpeggio) that run underneath the notes.
;
; This is the big difference from gex2. gex2 has two parallel sets of four channels, one
; for music and one for sfx, and swaps hardware registers between them; gex3 has one set
; of four, and a sound effect simply takes a channel away from the music by clearing
; AUDIO_CHF_ENABLED - the music keeps running, silently, and is audible again the moment
; the effect ends. Nothing is saved or restored.
;
; A SONG IS FIVE POINTERS in data_04_7085_SongTable: one starting pattern per channel,
; then the note-length table the song's low nibbles index. Audio_StartSong copies them
; into the four channel blocks and sets every channel running.
;
; A PATTERN is the byte stream Audio_RunSequence walks:
;
;   $00-$5E, $80-$DE   a note. Bits 0-6 index the frequency tables; bit 7 picks the
;                      second half of the instrument table. One parameter byte follows:
;                      high nibble = instrument, low nibble = index into the song's
;                      note-length table
;   $60-$6D, $E0-$ED   a command - see the AUDIO_CMD_* constants and
;                      data_04_461b_AudioCommandTable
;
; Commands re-enter the channel's update block through Audio_ResumeChannel when they
; finish, so any number of them can run before the note they precede; only
; AUDIO_CMD_SET_NOTE_LENGTH and a note end the channel's turn for this tick.
;
; AN INSTRUMENT is twelve bytes in data_04_70d1_InstrumentPointers' targets: the three
; register values a note starts from, and three (timer, pointer) pairs naming a volume
; envelope, a pitch slide and an arpeggio. Those three run once per tick for as long as
; the note lasts, which is where the driver's character comes from - gex2 has nothing
; like it and gets the same effects by writing registers straight from the sequence.
;
; TEMPO is a phase accumulator, not a counter: wDF78_Audio_TempoRate is added to
; wDF77_Audio_TempoAccumulator every frame and the four channels only advance on the
; frames that carry out of it.
;
; SOUND EFFECTS are a separate, much simpler player. One SFX_* id maps through
; data_04_4a59_SfxTrackIds to up to four tracks; each track names the hardware channel it
; wants and is then a flat list of five-byte rows - duration, NRx1, NRx2, NRx4, NRx3 -
; with $FF ending it and $FE jumping backwards. No instruments, no envelopes: the effect
; writes the registers itself.
; ==================================================================

; ------------------------------------------------------------------
; ENTRY VECTORS
;
; Thirteen jumps at a fixed address so bank 0 never has to know where the driver's code
; actually sits. The four the game uses are marked; the rest are dead
; ------------------------------------------------------------------
call_04_4000_Audio_Init:
    jp   call_04_40e3_Audio_ResetDriver                 ;; 04:4000 $c3 $e3 $40

call_04_4003_Audio_PlaySfxTrack:
; unused - starts one sfx track directly, bypassing data_04_4a59_SfxTrackIds
    jp   call_04_487b_Audio_StartSfxTrack               ;; 04:4003 $c3 $7b $48

call_04_4006_Audio_PlayMusic:
    jp   call_04_412b_Audio_StartSong                   ;; 04:4006 $c3 $2b $41

call_04_4009_Audio_Update:
    jp   call_04_402b_Audio_UpdateAll                   ;; 04:4009 $c3 $2b $40

call_04_400c_Audio_UpdateMusicOnly:
; unused
    jp   call_04_41cb_Audio_UpdateMusic                 ;; 04:400c $c3 $cb $41

call_04_400f_Audio_UpdateSfxOnly:
; unused
    jp   call_04_491e_Audio_UpdateSfx                   ;; 04:400f $c3 $1e $49

call_04_4012_Audio_Pause:
; unused
    jp   call_04_4065_Audio_SilenceAndPause             ;; 04:4012 $c3 $65 $40

call_04_4015_Audio_Resume:
; unused
    jp   call_04_4073_Audio_ResumeMusic                 ;; 04:4015 $c3 $73 $40

call_04_4018_Audio_VolumeDown:
; unused
    jp   call_04_4032_Audio_MasterVolumeDown            ;; 04:4018 $c3 $32 $40

call_04_401b_Audio_VolumeUp:
; unused
    jp   call_04_4079_Audio_MasterVolumeUp              ;; 04:401b $c3 $79 $40

call_04_401e_Audio_Stop:
; unused
    jp   call_04_4059_Audio_StopAll                     ;; 04:401e $c3 $59 $40

call_04_4021_Audio_SetTempo:
; unused
    jp   call_04_4027_Audio_SetTempoRate                ;; 04:4021 $c3 $27 $40

call_04_4024_Audio_PlaySfx:
    jp   call_04_40af_Audio_StartSfx                    ;; 04:4024 $c3 $af $40

call_04_4027_Audio_SetTempoRate:
; Sets how much wDF77_Audio_TempoAccumulator gains per frame. $FF - what
; Audio_StartSong installs - carries every frame, so the music runs at one tick per
; frame; smaller values drop ticks in proportion. AUDIO_CMD_SET_TEMPO does the same
; thing from inside a pattern
    ld   [wDF78_Audio_TempoRate], A                    ;; 04:4027 $ea $78 $df
    ret                                                ;; 04:402a $c9

call_04_402b_Audio_UpdateAll:
; The per-frame tick, called from the vblank handler with this bank mapped in. Music
; first so that a sound effect started this frame writes its registers last and wins
    call call_04_41cb_Audio_UpdateMusic                 ;; 04:402b $cd $cb $41
    call call_04_491e_Audio_UpdateSfx                  ;; 04:402e $cd $1e $49
    ret                                                ;; 04:4031 $c9

call_04_4032_Audio_MasterVolumeDown:
; Unused. Drops both halves of rNR50 by one step, and silences all four envelopes once
; both reach zero. Note the right half is rebuilt with AUDIO_NR50_VIN_RIGHT set but the
; left half is not, so a fade started from the $77 that Audio_ResetHardware writes ends
; up asymmetric
    ldh  A, [rNR50]                                    ;; 04:4032 $f0 $24
    and  A, AUDIO_NR50_VOLUME_RIGHT                    ;; 04:4034 $e6 $07
    jr   Z, .jr_04_403f                                ;; 04:4036 $28 $07
    dec  A                                             ;; 04:4038 $3d
    or   A, AUDIO_NR50_VIN_RIGHT                       ;; 04:4039 $f6 $08
    ld   B, A                                          ;; 04:403b $47
    jp   .jp_04_4041                                   ;; 04:403c $c3 $41 $40
.jr_04_403f:
    ld   B, $00                                        ;; 04:403f $06 $00
.jp_04_4041:
    ldh  A, [rNR50]                                    ;; 04:4041 $f0 $24
    and  A, AUDIO_NR50_VOLUME_LEFT                     ;; 04:4043 $e6 $70
    jr   Z, .jr_04_404c                                ;; 04:4045 $28 $05
    sub  A, $10                                        ;; 04:4047 $d6 $10
    jp   .jp_04_404e                                   ;; 04:4049 $c3 $4e $40
.jr_04_404c:
    ld   A, $00                                        ;; 04:404c $3e $00
.jp_04_404e:
    or   A, B                                          ;; 04:404e $b0
    cp   A, $00                                        ;; 04:404f $fe $00
    jr   NZ, .jr_04_4056                               ;; 04:4051 $20 $03
    call call_04_4065_Audio_SilenceAndPause            ;; 04:4053 $cd $65 $40
.jr_04_4056:
    ldh  [rNR50], A                                    ;; 04:4056 $e0 $24
    ret                                                ;; 04:4058 $c9

call_04_4059_Audio_StopAll:
; Unused. Kills panning and master volume outright and clears
; wDF76_Audio_MusicEnabled, so Audio_UpdateMusic returns immediately from then on. The
; channel blocks keep their state - a later Audio_ResumeMusic picks the song back up
; where it stopped
    xor  A, A                                          ;; 04:4059 $af
    ldh  [rNR51], A                                    ;; 04:405a $e0 $25
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:405c $ea $79 $df
    ldh  [rNR50], A                                    ;; 04:405f $e0 $24
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 04:4061 $ea $76 $df
    ret                                                ;; 04:4064 $c9

call_04_4065_Audio_SilenceAndPause:
; Unused on its own; Audio_MasterVolumeDown calls it when a fade bottoms out. Zeroes
; every channel's volume-envelope register and stops the music from advancing, without
; touching rNR50 or rNR51
    ld   A, $00                                        ;; 04:4065 $3e $00
    ldh  [rNR12], A                                    ;; 04:4067 $e0 $12
    ldh  [rNR22], A                                    ;; 04:4069 $e0 $17
    ldh  [rNR32], A                                    ;; 04:406b $e0 $1c
    ldh  [rNR42], A                                    ;; 04:406d $e0 $21
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 04:406f $ea $76 $df
    ret                                                ;; 04:4072 $c9

call_04_4073_Audio_ResumeMusic:
; Unused. Lets Audio_UpdateMusic run again. Audio_MasterVolumeUp calls it first, so a
; fade back in also un-pauses
    ld   A, $ff                                        ;; 04:4073 $3e $ff
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 04:4075 $ea $76 $df
    ret                                                ;; 04:4078 $c9

call_04_4079_Audio_MasterVolumeUp:
; Unused, and does not survive close reading. From silence it jumps straight to $88 -
; both VIN bits, both volumes zero - which is not audible; from anywhere else it raises
; each half by one step. Two bugs: when the right half is already $07 the `jr Z` skips
; the `ld B, A` that was supposed to carry it, so B holds whatever the last caller left
; there, and when the left half is already $07 the `ret Z` leaves rNR50 unwritten and
; the right half's increment is thrown away
    call call_04_4073_Audio_ResumeMusic                ;; 04:4079 $cd $73 $40
    ldh  A, [rNR50]                                    ;; 04:407c $f0 $24
    cp   A, $00                                        ;; 04:407e $fe $00
    jr   NZ, .jr_04_4087                               ;; 04:4080 $20 $05
    ld   A, AUDIO_NR50_VIN_LEFT | AUDIO_NR50_VIN_RIGHT ;; 04:4082 $3e $88
    ldh  [rNR50], A                                    ;; 04:4084 $e0 $24
    ret                                                ;; 04:4086 $c9
.jr_04_4087:
    and  A, AUDIO_NR50_VOLUME_RIGHT                    ;; 04:4087 $e6 $07
    cp   A, AUDIO_NR50_VOLUME_RIGHT                    ;; 04:4089 $fe $07
    jr   Z, .jr_04_4090                                ;; 04:408b $28 $03
    add  A, $01                                        ;; 04:408d $c6 $01
    ld   B, A                                          ;; 04:408f $47
.jr_04_4090:
    ldh  A, [rNR50]                                    ;; 04:4090 $f0 $24
    and  A, AUDIO_NR50_VOLUME_LEFT                     ;; 04:4092 $e6 $70
    srl  A                                             ;; 04:4094 $cb $3f
    srl  A                                             ;; 04:4096 $cb $3f
    srl  A                                             ;; 04:4098 $cb $3f
    srl  A                                             ;; 04:409a $cb $3f
    cp   A, AUDIO_NR50_VOLUME_RIGHT                    ;; 04:409c $fe $07
    ret  Z                                             ;; 04:409e $c8
    add  A, $01                                        ;; 04:409f $c6 $01
    sla  A                                             ;; 04:40a1 $cb $27
    sla  A                                             ;; 04:40a3 $cb $27
    sla  A                                             ;; 04:40a5 $cb $27
    sla  A                                             ;; 04:40a7 $cb $27
    or   A, B                                          ;; 04:40a9 $b0
    or   A, AUDIO_NR50_VIN_LEFT | AUDIO_NR50_VIN_RIGHT ;; 04:40aa $f6 $88
    ldh  [rNR50], A                                    ;; 04:40ac $e0 $24
    ret                                                ;; 04:40ae $c9

call_04_40af_Audio_StartSfx:
; Start sound effect id A. One SFX_* id is up to four driver tracks - a crash that wants
; noise and a pulse channel at once is two of them - so this reads that id's four-byte
; row out of data_04_4a59_SfxTrackIds and starts every entry that is not
; AUDIO_SFX_TRACK_NONE.
;
; The four tests are written out rather than looped, which is why the row is a fixed
; four bytes wide however few tracks an effect actually uses.
;
; gex2's call_00_113e_PlaySFX does the same fan-out, but in bank 0 rather than in the
; driver, and its driver tracks are one per hardware channel by construction
    add  A, A                                          ;; 04:40af $87
    add  A, A                                          ;; 04:40b0 $87
    ld   HL, data_04_4a59_SfxTrackIds                  ;; 04:40b1 $21 $59 $4a
    add  A, L                                          ;; 04:40b4 $85
    ld   L, A                                          ;; 04:40b5 $6f
    jr   NC, .jr_04_40b9                               ;; 04:40b6 $30 $01
    inc  H                                             ;; 04:40b8 $24
.jr_04_40b9:
    ld   A, [HL]                                       ;; 04:40b9 $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 04:40ba $fe $ff
    jr   Z, .jr_04_40c1                                ;; 04:40bc $28 $03
    call call_04_40dd_Audio_StartSfxTrackKeepHL        ;; 04:40be $cd $dd $40
.jr_04_40c1:
    inc  HL                                            ;; 04:40c1 $23
    ld   A, [HL]                                       ;; 04:40c2 $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 04:40c3 $fe $ff
    jr   Z, .jr_04_40ca                                ;; 04:40c5 $28 $03
    call call_04_40dd_Audio_StartSfxTrackKeepHL        ;; 04:40c7 $cd $dd $40
.jr_04_40ca:
    inc  HL                                            ;; 04:40ca $23
    ld   A, [HL]                                       ;; 04:40cb $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 04:40cc $fe $ff
    jr   Z, .jr_04_40d3                                ;; 04:40ce $28 $03
    call call_04_40dd_Audio_StartSfxTrackKeepHL        ;; 04:40d0 $cd $dd $40
.jr_04_40d3:
    inc  HL                                            ;; 04:40d3 $23
    ld   A, [HL]                                       ;; 04:40d4 $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 04:40d5 $fe $ff
    jr   Z, .jr_04_40dc                                ;; 04:40d7 $28 $03
    call call_04_40dd_Audio_StartSfxTrackKeepHL        ;; 04:40d9 $cd $dd $40
.jr_04_40dc:
    ret                                                ;; 04:40dc $c9

call_04_40dd_Audio_StartSfxTrackKeepHL:
; Audio_StartSfxTrack destroys HL, and the caller is walking the id row with it
    push HL                                            ;; 04:40dd $e5
    call call_04_487b_Audio_StartSfxTrack              ;; 04:40de $cd $7b $48
    pop  HL                                            ;; 04:40e1 $e1
    ret                                                ;; 04:40e2 $c9

call_04_40e3_Audio_ResetDriver:
; Boot-time reset, called once from call_00_0150_Init.
;
; Turns the APU off and on to clear every register, drops the four sfx track pointers
; and the four channels' flag bytes, sets the tempo to full speed, loads the default
; wave pattern and then hands off to Audio_ResetHardware for the rest.
;
; Nothing here starts a song - the caller does that separately
    ld   A, $00                                        ;; 04:40e3 $3e $00
    ldh  [rNR52], A                                    ;; 04:40e5 $e0 $26
    nop                                                ;; 04:40e7 $00
    ldh  [rNR52], A                                    ;; 04:40e8 $e0 $26
    ld   [wDF68_Audio_Ch1_SfxPtrLo], A                 ;; 04:40ea $ea $68 $df
    ld   [wDF69_Audio_Ch1_SfxPtrHi], A                 ;; 04:40ed $ea $69 $df
    ld   [wDF6B_Audio_Ch2_SfxPtrLo], A                 ;; 04:40f0 $ea $6b $df
    ld   [wDF6C_Audio_Ch2_SfxPtrHi], A                 ;; 04:40f3 $ea $6c $df
    ld   [wDF6E_Audio_Ch3_SfxPtrLo], A                 ;; 04:40f6 $ea $6e $df
    ld   [wDF6F_Audio_Ch3_SfxPtrHi], A                 ;; 04:40f9 $ea $6f $df
    ld   [wDF71_Audio_Ch4_SfxPtrLo], A                 ;; 04:40fc $ea $71 $df
    ld   [wDF72_Audio_Ch4_SfxPtrHi], A                 ;; 04:40ff $ea $72 $df
    ld   [wDF00_Audio_Ch1_Flags], A                    ;; 04:4102 $ea $00 $df
    ld   [wDF18_Audio_Ch2_Flags], A                    ;; 04:4105 $ea $18 $df
    ld   [wDF30_Audio_Ch3_Flags], A                    ;; 04:4108 $ea $30 $df
    ld   [wDF48_Audio_Ch4_Flags], A                    ;; 04:410b $ea $48 $df
    ld   A, $ff                                        ;; 04:410e $3e $ff
    ld   [wDF78_Audio_TempoRate], A                    ;; 04:4110 $ea $78 $df
    ld   A, $01                                        ;; 04:4113 $3e $01
    ld   [wDF77_Audio_TempoAccumulator], A             ;; 04:4115 $ea $77 $df
    ld   DE, _AUD3WAVERAM                              ;; 04:4118 $11 $30 $ff
    ld   HL, data_04_49dd_InitialWaveRam               ;; 04:411b $21 $dd $49
    ld   B, $10                                        ;; 04:411e $06 $10
.jr_04_4120:
    ld   A, [HL]                                       ;; 04:4120 $7e
    ld   [DE], A                                       ;; 04:4121 $12
    inc  HL                                            ;; 04:4122 $23
    inc  DE                                            ;; 04:4123 $13
    dec  B                                             ;; 04:4124 $05
    jr   NZ, .jr_04_4120                               ;; 04:4125 $20 $f9
    call call_04_418b_Audio_ResetHardware              ;; 04:4127 $cd $8b $41
    ret                                                ;; 04:412a $c9

call_04_412b_Audio_StartSong:
; Start song A of this bank - the low nibble of a SONG_* id, the high nibble having
; already chosen the bank in call_00_0fa2_SetupMusic.
;
; A song record is AUDIO_SONG_SIZE bytes: four starting pattern pointers, one per
; hardware channel, then the note-length table the song's notes index. The multiply is
; done by hand as 8A + 2A rather than with a table.
;
; The four channels are then armed: AUDIO_CH_LOOP_ACTIVE is cleared on channels 1 and 2
; but set to $02 on 3 and 4, which is not a value AUDIO_CMD_CALL_PATTERN ever writes and
; simply means "already in a loop, don't re-arm" - the wave and noise parts of every song
; open with their own AUDIO_CMD_CALL_PATTERN and this stops it counting repeats.
;
; Both flag bits go up on all four channels, the tempo goes back to full speed, and the
; first tick of Audio_UpdateMusic reads the first byte of each pattern.
;
; gex2 starts a song by calling Audio_PlayMusic four times, once per track; here one call
; does all four because the song table holds them together
    ld   L, A                                          ;; 04:412b $6f
    ld   H, $00                                        ;; 04:412c $26 $00
    add  HL, HL                                        ;; 04:412e $29
    ld   D, H                                          ;; 04:412f $54
    ld   E, L                                          ;; 04:4130 $5d
    add  HL, HL                                        ;; 04:4131 $29
    add  HL, HL                                        ;; 04:4132 $29
    add  HL, DE                                        ;; 04:4133 $19
    ld   DE, data_04_7085_SongTable                    ;; 04:4134 $11 $85 $70
    add  HL, DE                                        ;; 04:4137 $19
    ld   A, [HL+]                                      ;; 04:4138 $2a
    ld   [wDF02_Audio_Ch1_SeqPtrLo], A                 ;; 04:4139 $ea $02 $df
    ld   A, [HL+]                                      ;; 04:413c $2a
    ld   [wDF03_Audio_Ch1_SeqPtrHi], A                 ;; 04:413d $ea $03 $df
    ld   A, [HL+]                                      ;; 04:4140 $2a
    ld   [wDF1A_Audio_Ch2_SeqPtrLo], A                 ;; 04:4141 $ea $1a $df
    ld   A, [HL+]                                      ;; 04:4144 $2a
    ld   [wDF1B_Audio_Ch2_SeqPtrHi], A                 ;; 04:4145 $ea $1b $df
    ld   A, [HL+]                                      ;; 04:4148 $2a
    ld   [wDF32_Audio_Ch3_SeqPtrLo], A                 ;; 04:4149 $ea $32 $df
    ld   A, [HL+]                                      ;; 04:414c $2a
    ld   [wDF33_Audio_Ch3_SeqPtrHi], A                 ;; 04:414d $ea $33 $df
    ld   A, [HL+]                                      ;; 04:4150 $2a
    ld   [wDF4A_Audio_Ch4_SeqPtrLo], A                 ;; 04:4151 $ea $4a $df
    ld   A, [HL+]                                      ;; 04:4154 $2a
    ld   [wDF4B_Audio_Ch4_SeqPtrHi], A                 ;; 04:4155 $ea $4b $df
    ld   A, [HL+]                                      ;; 04:4158 $2a
    ld   [wDF60_Audio_NoteLengthTablePtrLo], A         ;; 04:4159 $ea $60 $df
    ld   A, [HL+]                                      ;; 04:415c $2a
    ld   [wDF61_Audio_NoteLengthTablePtrHi], A         ;; 04:415d $ea $61 $df
    ld   A, $01                                        ;; 04:4160 $3e $01
    ld   [wDF01_Audio_Ch1_NoteTimer], A                ;; 04:4162 $ea $01 $df
    ld   [wDF19_Audio_Ch2_NoteTimer], A                ;; 04:4165 $ea $19 $df
    ld   A, $02                                        ;; 04:4168 $3e $02
    ld   [wDF31_Audio_Ch3_NoteTimer], A                ;; 04:416a $ea $31 $df
    ld   [wDF49_Audio_Ch4_NoteTimer], A                ;; 04:416d $ea $49 $df
    ld   A, AUDIO_CHF_ENABLED | AUDIO_CHF_RUNNING      ;; 04:4170 $3e $03
    ld   [wDF00_Audio_Ch1_Flags], A                    ;; 04:4172 $ea $00 $df
    ld   [wDF18_Audio_Ch2_Flags], A                    ;; 04:4175 $ea $18 $df
    ld   [wDF30_Audio_Ch3_Flags], A                    ;; 04:4178 $ea $30 $df
    ld   [wDF48_Audio_Ch4_Flags], A                    ;; 04:417b $ea $48 $df
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 04:417e $ea $76 $df
    ld   A, $ff                                        ;; 04:4181 $3e $ff
    ld   [wDF78_Audio_TempoRate], A                    ;; 04:4183 $ea $78 $df
    ld   A, $01                                        ;; 04:4186 $3e $01
    ld   [wDF77_Audio_TempoAccumulator], A             ;; 04:4188 $ea $77 $df

call_04_418b_Audio_ResetHardware:
; Falls out of Audio_StartSong, so every song change rebuilds the APU from scratch.
;
; Master enable, sweep off, everything panned to both sides, master volume $77, the wave
; channel's DAC on, all four volume envelopes silent, and the per-channel transpose and
; pattern-loop state cleared. Notes are inaudible until the first instrument writes a
; real envelope value, which is what stops the register clear from being heard
    ld   A, AUDIO_NR52_ALL_ON                          ;; 04:418b $3e $8f
    ldh  [rNR52], A                                    ;; 04:418d $e0 $26
    nop                                                ;; 04:418f $00
    nop                                                ;; 04:4190 $00
    ldh  [rNR52], A                                    ;; 04:4191 $e0 $26
    ld   A, $08                                        ;; 04:4193 $3e $08
    ldh  [rNR10], A                                    ;; 04:4195 $e0 $10
    ld   A, $ff                                        ;; 04:4197 $3e $ff
    ldh  [rNR51], A                                    ;; 04:4199 $e0 $25
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:419b $ea $79 $df
    ld   A, $77                                        ;; 04:419e $3e $77
    ldh  [rNR50], A                                    ;; 04:41a0 $e0 $24
    ld   A, $80                                        ;; 04:41a2 $3e $80
    ldh  [rNR30], A                                    ;; 04:41a4 $e0 $1a
    xor  A, A                                          ;; 04:41a6 $af
    ldh  [rNR12], A                                    ;; 04:41a7 $e0 $12
    ldh  [rNR22], A                                    ;; 04:41a9 $e0 $17
    ldh  [rNR32], A                                    ;; 04:41ab $e0 $1c
    ldh  [rNR42], A                                    ;; 04:41ad $e0 $21
    ld   [wDF14_Audio_Ch1_Transpose], A                ;; 04:41af $ea $14 $df
    ld   [wDF2C_Audio_Ch2_Transpose], A                ;; 04:41b2 $ea $2c $df
    ld   [wDF44_Audio_Ch3_Transpose], A                ;; 04:41b5 $ea $44 $df
    ld   [wDF5C_Audio_Ch4_Transpose], A                ;; 04:41b8 $ea $5c $df
    ld   [wDF15_Audio_Ch1_LoopActive], A               ;; 04:41bb $ea $15 $df
    ld   [wDF2D_Audio_Ch2_LoopActive], A               ;; 04:41be $ea $2d $df
    ld   [wDF45_Audio_Ch3_LoopActive], A               ;; 04:41c1 $ea $45 $df
    ld   [wDF5D_Audio_Ch4_LoopActive], A               ;; 04:41c4 $ea $5d $df
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 04:41c7 $ea $55 $df
    ret                                                ;; 04:41ca $c9

call_04_41cb_Audio_UpdateMusic:
; One music tick, or none: wDF78_Audio_TempoRate is added to
; wDF77_Audio_TempoAccumulator and the rest of the routine only runs on the frames that
; carry out of the byte. At the $FF a song installs that is every frame; a smaller rate
; skips frames in proportion, which is the whole of the tempo system.
;
; What follows is the same block of code four times over, once per hardware channel,
; written out rather than looped because almost every address in it is a different
; absolute WRAM byte or a different NRxy register. Each copy:
;
;   - records which channel it is in wDF7B_Audio_ChannelIndex, and its own address in
;     wDF62_Audio_ChannelResumePtr so a command handler can jump back into it
;   - loads the channel's transpose into wDF65_Audio_CurrentTranspose
;   - calls Audio_RunSequence to advance the pattern
;   - gives up on this channel if AUDIO_CHF_ENABLED is clear, or if the channel's sfx
;     pointer is non-zero, which is how a sound effect keeps the music silent without
;     stopping it
;   - steps the volume envelope, the pitch slide and the arpeggio, and writes the
;     shadow registers out
;
; Channel 3 writes its registers before its envelope rather than after, and channel 4
; has no arpeggio and takes its period from Audio_StepNoisePeriod instead of a pitch
; slide. Those two differences aside the four copies are the same
    ld   A, [wDF76_Audio_MusicEnabled]                 ;; 04:41cb $fa $76 $df
    and  A, A                                          ;; 04:41ce $a7
    ret  Z                                             ;; 04:41cf $c8
    ld   A, [wDF78_Audio_TempoRate]                    ;; 04:41d0 $fa $78 $df
    ld   B, A                                          ;; 04:41d3 $47
    ld   A, [wDF77_Audio_TempoAccumulator]             ;; 04:41d4 $fa $77 $df
    add  A, B                                          ;; 04:41d7 $80
    ld   [wDF77_Audio_TempoAccumulator], A             ;; 04:41d8 $ea $77 $df
    ret  NC                                            ;; 04:41db $d0

.jr_04_41dc:
; --- channel 1, pulse A ---
    xor  A, A                                          ;; 04:41dc $af
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 04:41dd $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 04:41e0 $21 $62 $df
    ld   DE, .jr_04_41dc                               ;; 04:41e3 $11 $dc $41
    ld   [HL], E                                       ;; 04:41e6 $73
    inc  HL                                            ;; 04:41e7 $23
    ld   [HL], D                                       ;; 04:41e8 $72
    ld   A, [wDF14_Audio_Ch1_Transpose]                ;; 04:41e9 $fa $14 $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 04:41ec $ea $65 $df
    ld   HL, wDF00_Audio_Ch1_Flags                     ;; 04:41ef $21 $00 $df
    ld   DE, rNR11                                     ;; 04:41f2 $11 $11 $ff
    call call_04_44d4_Audio_RunSequence                ;; 04:41f5 $cd $d4 $44
    ld   A, [wDF00_Audio_Ch1_Flags]                    ;; 04:41f8 $fa $00 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 04:41fb $e6 $01
    jp   Z, .jp_04_429b                                ;; 04:41fd $ca $9b $42
    ld   A, [wDF69_Audio_Ch1_SfxPtrHi]                 ;; 04:4200 $fa $69 $df
    and  A, A                                          ;; 04:4203 $a7
    jp   NZ, .jp_04_429b                               ;; 04:4204 $c2 $9b $42
    ld   HL, wDF0A_Audio_Ch1_EnvelopeTimer             ;; 04:4207 $21 $0a $df
    ld   DE, wDF0B_Audio_Ch1_EnvelopePtrLo             ;; 04:420a $11 $0b $df
    ld   A, [DE]                                       ;; 04:420d $1a
    ld   C, A                                          ;; 04:420e $4f
    inc  DE                                            ;; 04:420f $13
    ld   A, [DE]                                       ;; 04:4210 $1a
    ld   B, A                                          ;; 04:4211 $47
    ld   DE, rNR12                                     ;; 04:4212 $11 $12 $ff
    call call_04_446c_Audio_StepVolumeEnvelope         ;; 04:4215 $cd $6c $44
    ld   DE, wDF0B_Audio_Ch1_EnvelopePtrLo             ;; 04:4218 $11 $0b $df
    ld   A, C                                          ;; 04:421b $79
    ld   [DE], A                                       ;; 04:421c $12
    ld   A, B                                          ;; 04:421d $78
    inc  DE                                            ;; 04:421e $13
    ld   [DE], A                                       ;; 04:421f $12
    ld   HL, wDF00_Audio_Ch1_Flags                     ;; 04:4220 $21 $00 $df
    ld   DE, rNR13                                     ;; 04:4223 $11 $13 $ff
    call call_04_45a7_Audio_WriteChannelRegs           ;; 04:4226 $cd $a7 $45
    ld   HL, wDF0D_Audio_Ch1_PitchTimer                ;; 04:4229 $21 $0d $df
    ld   DE, wDF0E_Audio_Ch1_PitchPtrLo                ;; 04:422c $11 $0e $df
    ld   A, [DE]                                       ;; 04:422f $1a
    ld   C, A                                          ;; 04:4230 $4f
    inc  DE                                            ;; 04:4231 $13
    ld   A, [DE]                                       ;; 04:4232 $1a
    ld   B, A                                          ;; 04:4233 $47
    ld   DE, wDF05_Audio_Ch1_NR13Shadow                ;; 04:4234 $11 $05 $df
    call call_04_4494_Audio_StepPitchSlide             ;; 04:4237 $cd $94 $44
    ld   DE, wDF0E_Audio_Ch1_PitchPtrLo                ;; 04:423a $11 $0e $df
    ld   A, C                                          ;; 04:423d $79
    ld   [DE], A                                       ;; 04:423e $12
    ld   A, B                                          ;; 04:423f $78
    inc  DE                                            ;; 04:4240 $13
    ld   [DE], A                                       ;; 04:4241 $12
    ld   A, [wDF10_Audio_Ch1_ArpTimer]                 ;; 04:4242 $fa $10 $df
    and  A, A                                          ;; 04:4245 $a7
    jr   Z, .jp_04_429b                                ;; 04:4246 $28 $53
    dec  A                                             ;; 04:4248 $3d
    ld   [wDF10_Audio_Ch1_ArpTimer], A                 ;; 04:4249 $ea $10 $df
    and  A, A                                          ;; 04:424c $a7
    jr   NZ, .jp_04_429b                               ;; 04:424d $20 $4c
    ld   A, [wDF11_Audio_Ch1_ArpPtrLo]                 ;; 04:424f $fa $11 $df
    ld   C, A                                          ;; 04:4252 $4f
    ld   A, [wDF12_Audio_Ch1_ArpPtrHi]                 ;; 04:4253 $fa $12 $df
    ld   B, A                                          ;; 04:4256 $47
    ld   A, [BC]                                       ;; 04:4257 $0a
    cp   A, AUDIO_ARP_LOOP                             ;; 04:4258 $fe $ff
    jr   Z, .jr_04_428c                                ;; 04:425a $28 $30
    ld   [wDF10_Audio_Ch1_ArpTimer], A                 ;; 04:425c $ea $10 $df
    inc  BC                                            ;; 04:425f $03
    ld   A, [BC]                                       ;; 04:4260 $0a
    ld   E, A                                          ;; 04:4261 $5f
    ld   A, [wDF7C_Audio_Ch1_CurrentNote]              ;; 04:4262 $fa $7c $df
    add  A, E                                          ;; 04:4265 $83
    push AF                                            ;; 04:4266 $f5
    ld   DE, data_04_481b_NoteFrequenciesHi            ;; 04:4267 $11 $1b $48
    add  A, E                                          ;; 04:426a $83
    ld   E, A                                          ;; 04:426b $5f
    jr   NC, .jr_04_426f                               ;; 04:426c $30 $01
    inc  D                                             ;; 04:426e $14
.jr_04_426f:
    ld   A, [DE]                                       ;; 04:426f $1a
    ld   [wDF04_Audio_Ch1_NR14Shadow], A               ;; 04:4270 $ea $04 $df
    pop  AF                                            ;; 04:4273 $f1
    ld   DE, data_04_47bb_NoteFrequenciesLo            ;; 04:4274 $11 $bb $47
    add  A, E                                          ;; 04:4277 $83
    ld   E, A                                          ;; 04:4278 $5f
    jr   NC, .jr_04_427c                               ;; 04:4279 $30 $01
    inc  D                                             ;; 04:427b $14
.jr_04_427c:
    ld   A, [DE]                                       ;; 04:427c $1a
    ld   [wDF05_Audio_Ch1_NR13Shadow], A               ;; 04:427d $ea $05 $df
    inc  BC                                            ;; 04:4280 $03
    ld   A, C                                          ;; 04:4281 $79
    ld   [wDF11_Audio_Ch1_ArpPtrLo], A                 ;; 04:4282 $ea $11 $df
    ld   A, B                                          ;; 04:4285 $78
    ld   [wDF12_Audio_Ch1_ArpPtrHi], A                 ;; 04:4286 $ea $12 $df
    jp   .jp_04_429b                                   ;; 04:4289 $c3 $9b $42
.jr_04_428c:
    ld   A, $01                                        ;; 04:428c $3e $01
    ld   [wDF10_Audio_Ch1_ArpTimer], A                 ;; 04:428e $ea $10 $df
    inc  BC                                            ;; 04:4291 $03
    ld   A, [BC]                                       ;; 04:4292 $0a
    ld   [wDF11_Audio_Ch1_ArpPtrLo], A                 ;; 04:4293 $ea $11 $df
    inc  BC                                            ;; 04:4296 $03
    ld   A, [BC]                                       ;; 04:4297 $0a
    ld   [wDF12_Audio_Ch1_ArpPtrHi], A                 ;; 04:4298 $ea $12 $df

.jp_04_429b:
; --- channel 2, pulse B ---
    ld   A, $01                                        ;; 04:429b $3e $01
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 04:429d $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 04:42a0 $21 $62 $df
    ld   DE, .jp_04_429b                               ;; 04:42a3 $11 $9b $42
    ld   [HL], E                                       ;; 04:42a6 $73
    inc  HL                                            ;; 04:42a7 $23
    ld   [HL], D                                       ;; 04:42a8 $72
    ld   A, [wDF2C_Audio_Ch2_Transpose]                ;; 04:42a9 $fa $2c $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 04:42ac $ea $65 $df
    ld   HL, wDF18_Audio_Ch2_Flags                     ;; 04:42af $21 $18 $df
    ld   DE, rNR21                                     ;; 04:42b2 $11 $16 $ff
    call call_04_44d4_Audio_RunSequence                ;; 04:42b5 $cd $d4 $44
    ld   A, [wDF18_Audio_Ch2_Flags]                    ;; 04:42b8 $fa $18 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 04:42bb $e6 $01
    jp   Z, .jp_04_435b                                ;; 04:42bd $ca $5b $43
    ld   A, [wDF6C_Audio_Ch2_SfxPtrHi]                 ;; 04:42c0 $fa $6c $df
    and  A, A                                          ;; 04:42c3 $a7
    jp   NZ, .jp_04_435b                               ;; 04:42c4 $c2 $5b $43
    ld   HL, wDF22_Audio_Ch2_EnvelopeTimer             ;; 04:42c7 $21 $22 $df
    ld   DE, wDF23_Audio_Ch2_EnvelopePtrLo             ;; 04:42ca $11 $23 $df
    ld   A, [DE]                                       ;; 04:42cd $1a
    ld   C, A                                          ;; 04:42ce $4f
    inc  DE                                            ;; 04:42cf $13
    ld   A, [DE]                                       ;; 04:42d0 $1a
    ld   B, A                                          ;; 04:42d1 $47
    ld   DE, rNR22                                     ;; 04:42d2 $11 $17 $ff
    call call_04_446c_Audio_StepVolumeEnvelope         ;; 04:42d5 $cd $6c $44
    ld   DE, wDF23_Audio_Ch2_EnvelopePtrLo             ;; 04:42d8 $11 $23 $df
    ld   A, C                                          ;; 04:42db $79
    ld   [DE], A                                       ;; 04:42dc $12
    ld   A, B                                          ;; 04:42dd $78
    inc  DE                                            ;; 04:42de $13
    ld   [DE], A                                       ;; 04:42df $12
    ld   HL, wDF18_Audio_Ch2_Flags                     ;; 04:42e0 $21 $18 $df
    ld   DE, rNR23                                     ;; 04:42e3 $11 $18 $ff
    call call_04_45a7_Audio_WriteChannelRegs           ;; 04:42e6 $cd $a7 $45
    ld   HL, wDF25_Audio_Ch2_PitchTimer                ;; 04:42e9 $21 $25 $df
    ld   DE, wDF26_Audio_Ch2_PitchPtrLo                ;; 04:42ec $11 $26 $df
    ld   A, [DE]                                       ;; 04:42ef $1a
    ld   C, A                                          ;; 04:42f0 $4f
    inc  DE                                            ;; 04:42f1 $13
    ld   A, [DE]                                       ;; 04:42f2 $1a
    ld   B, A                                          ;; 04:42f3 $47
    ld   DE, wDF1D_Audio_Ch2_NR23Shadow                ;; 04:42f4 $11 $1d $df
    call call_04_4494_Audio_StepPitchSlide             ;; 04:42f7 $cd $94 $44
    ld   DE, wDF26_Audio_Ch2_PitchPtrLo                ;; 04:42fa $11 $26 $df
    ld   A, C                                          ;; 04:42fd $79
    ld   [DE], A                                       ;; 04:42fe $12
    ld   A, B                                          ;; 04:42ff $78
    inc  DE                                            ;; 04:4300 $13
    ld   [DE], A                                       ;; 04:4301 $12
    ld   A, [wDF28_Audio_Ch2_ArpTimer]                 ;; 04:4302 $fa $28 $df
    and  A, A                                          ;; 04:4305 $a7
    jr   Z, .jp_04_435b                                ;; 04:4306 $28 $53
    dec  A                                             ;; 04:4308 $3d
    ld   [wDF28_Audio_Ch2_ArpTimer], A                 ;; 04:4309 $ea $28 $df
    and  A, A                                          ;; 04:430c $a7
    jr   NZ, .jp_04_435b                               ;; 04:430d $20 $4c
    ld   A, [wDF29_Audio_Ch2_ArpPtrLo]                 ;; 04:430f $fa $29 $df
    ld   C, A                                          ;; 04:4312 $4f
    ld   A, [wDF2A_Audio_Ch2_ArpPtrHi]                 ;; 04:4313 $fa $2a $df
    ld   B, A                                          ;; 04:4316 $47
    ld   A, [BC]                                       ;; 04:4317 $0a
    cp   A, AUDIO_ARP_LOOP                             ;; 04:4318 $fe $ff
    jr   Z, .jr_04_434c                                ;; 04:431a $28 $30
    ld   [wDF28_Audio_Ch2_ArpTimer], A                 ;; 04:431c $ea $28 $df
    inc  BC                                            ;; 04:431f $03
    ld   A, [BC]                                       ;; 04:4320 $0a
    ld   E, A                                          ;; 04:4321 $5f
    ld   A, [wDF7D_Audio_Ch2_CurrentNote]              ;; 04:4322 $fa $7d $df
    add  A, E                                          ;; 04:4325 $83
    push AF                                            ;; 04:4326 $f5
    ld   DE, data_04_481b_NoteFrequenciesHi            ;; 04:4327 $11 $1b $48
    add  A, E                                          ;; 04:432a $83
    ld   E, A                                          ;; 04:432b $5f
    jr   NC, .jr_04_432f                               ;; 04:432c $30 $01
    inc  D                                             ;; 04:432e $14
.jr_04_432f:
    ld   A, [DE]                                       ;; 04:432f $1a
    ld   [wDF1C_Audio_Ch2_NR24Shadow], A               ;; 04:4330 $ea $1c $df
    pop  AF                                            ;; 04:4333 $f1
    ld   DE, data_04_47bb_NoteFrequenciesLo            ;; 04:4334 $11 $bb $47
    add  A, E                                          ;; 04:4337 $83
    ld   E, A                                          ;; 04:4338 $5f
    jr   NC, .jr_04_433c                               ;; 04:4339 $30 $01
    inc  D                                             ;; 04:433b $14
.jr_04_433c:
    ld   A, [DE]                                       ;; 04:433c $1a
    ld   [wDF1D_Audio_Ch2_NR23Shadow], A               ;; 04:433d $ea $1d $df
    inc  BC                                            ;; 04:4340 $03
    ld   A, C                                          ;; 04:4341 $79
    ld   [wDF29_Audio_Ch2_ArpPtrLo], A                 ;; 04:4342 $ea $29 $df
    ld   A, B                                          ;; 04:4345 $78
    ld   [wDF2A_Audio_Ch2_ArpPtrHi], A                 ;; 04:4346 $ea $2a $df
    jp   .jp_04_435b                                   ;; 04:4349 $c3 $5b $43
.jr_04_434c:
    ld   A, $01                                        ;; 04:434c $3e $01
    ld   [wDF28_Audio_Ch2_ArpTimer], A                 ;; 04:434e $ea $28 $df
    inc  BC                                            ;; 04:4351 $03
    ld   A, [BC]                                       ;; 04:4352 $0a
    ld   [wDF29_Audio_Ch2_ArpPtrLo], A                 ;; 04:4353 $ea $29 $df
    inc  BC                                            ;; 04:4356 $03
    ld   A, [BC]                                       ;; 04:4357 $0a
    ld   [wDF2A_Audio_Ch2_ArpPtrHi], A                 ;; 04:4358 $ea $2a $df

.jp_04_435b:
; --- channel 3, wave. Writes its registers before stepping its envelope, the reverse
; of channels 1 and 2 ---
    ld   A, $02                                        ;; 04:435b $3e $02
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 04:435d $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 04:4360 $21 $62 $df
    ld   DE, .jp_04_435b                               ;; 04:4363 $11 $5b $43
    ld   [HL], E                                       ;; 04:4366 $73
    inc  HL                                            ;; 04:4367 $23
    ld   [HL], D                                       ;; 04:4368 $72
    ld   A, [wDF44_Audio_Ch3_Transpose]                ;; 04:4369 $fa $44 $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 04:436c $ea $65 $df
    ld   HL, wDF30_Audio_Ch3_Flags                     ;; 04:436f $21 $30 $df
    ld   DE, rNR31                                     ;; 04:4372 $11 $1b $ff
    call call_04_44d4_Audio_RunSequence                ;; 04:4375 $cd $d4 $44
    ld   A, [wDF30_Audio_Ch3_Flags]                    ;; 04:4378 $fa $30 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 04:437b $e6 $01
    jp   Z, .jp_04_441b                                ;; 04:437d $ca $1b $44
    ld   A, [wDF6F_Audio_Ch3_SfxPtrHi]                 ;; 04:4380 $fa $6f $df
    and  A, A                                          ;; 04:4383 $a7
    jp   NZ, .jp_04_441b                               ;; 04:4384 $c2 $1b $44
    ld   HL, wDF30_Audio_Ch3_Flags                     ;; 04:4387 $21 $30 $df
    ld   DE, rNR33                                     ;; 04:438a $11 $1d $ff
    call call_04_45a7_Audio_WriteChannelRegs           ;; 04:438d $cd $a7 $45
    ld   HL, wDF3A_Audio_Ch3_EnvelopeTimer             ;; 04:4390 $21 $3a $df
    ld   DE, wDF3B_Audio_Ch3_EnvelopePtrLo             ;; 04:4393 $11 $3b $df
    ld   A, [DE]                                       ;; 04:4396 $1a
    ld   C, A                                          ;; 04:4397 $4f
    inc  DE                                            ;; 04:4398 $13
    ld   A, [DE]                                       ;; 04:4399 $1a
    ld   B, A                                          ;; 04:439a $47
    ld   DE, rNR32                                     ;; 04:439b $11 $1c $ff
    call call_04_446c_Audio_StepVolumeEnvelope         ;; 04:439e $cd $6c $44
    ld   DE, wDF3B_Audio_Ch3_EnvelopePtrLo             ;; 04:43a1 $11 $3b $df
    ld   A, C                                          ;; 04:43a4 $79
    ld   [DE], A                                       ;; 04:43a5 $12
    ld   A, B                                          ;; 04:43a6 $78
    inc  DE                                            ;; 04:43a7 $13
    ld   [DE], A                                       ;; 04:43a8 $12
    ld   HL, wDF3D_Audio_Ch3_PitchTimer                ;; 04:43a9 $21 $3d $df
    ld   DE, wDF3E_Audio_Ch3_PitchPtrLo                ;; 04:43ac $11 $3e $df
    ld   A, [DE]                                       ;; 04:43af $1a
    ld   C, A                                          ;; 04:43b0 $4f
    inc  DE                                            ;; 04:43b1 $13
    ld   A, [DE]                                       ;; 04:43b2 $1a
    ld   B, A                                          ;; 04:43b3 $47
    ld   DE, wDF35_Audio_Ch3_NR33Shadow                ;; 04:43b4 $11 $35 $df
    call call_04_4494_Audio_StepPitchSlide             ;; 04:43b7 $cd $94 $44
    ld   DE, wDF3E_Audio_Ch3_PitchPtrLo                ;; 04:43ba $11 $3e $df
    ld   A, C                                          ;; 04:43bd $79
    ld   [DE], A                                       ;; 04:43be $12
    ld   A, B                                          ;; 04:43bf $78
    inc  DE                                            ;; 04:43c0 $13
    ld   [DE], A                                       ;; 04:43c1 $12
    ld   A, [wDF40_Audio_Ch3_ArpTimer]                 ;; 04:43c2 $fa $40 $df
    and  A, A                                          ;; 04:43c5 $a7
    jr   Z, .jp_04_441b                                ;; 04:43c6 $28 $53
    dec  A                                             ;; 04:43c8 $3d
    ld   [wDF40_Audio_Ch3_ArpTimer], A                 ;; 04:43c9 $ea $40 $df
    and  A, A                                          ;; 04:43cc $a7
    jr   NZ, .jp_04_441b                               ;; 04:43cd $20 $4c
    ld   A, [wDF41_Audio_Ch3_ArpPtrLo]                 ;; 04:43cf $fa $41 $df
    ld   C, A                                          ;; 04:43d2 $4f
    ld   A, [wDF42_Audio_Ch3_ArpPtrHi]                 ;; 04:43d3 $fa $42 $df
    ld   B, A                                          ;; 04:43d6 $47
    ld   A, [BC]                                       ;; 04:43d7 $0a
    cp   A, AUDIO_ARP_LOOP                             ;; 04:43d8 $fe $ff
    jr   Z, .jr_04_440c                                ;; 04:43da $28 $30
    ld   [wDF40_Audio_Ch3_ArpTimer], A                 ;; 04:43dc $ea $40 $df
    inc  BC                                            ;; 04:43df $03
    ld   A, [BC]                                       ;; 04:43e0 $0a
    ld   E, A                                          ;; 04:43e1 $5f
    ld   A, [wDF7E_Audio_Ch3_CurrentNote]              ;; 04:43e2 $fa $7e $df
    add  A, E                                          ;; 04:43e5 $83
    push AF                                            ;; 04:43e6 $f5
    ld   DE, data_04_481b_NoteFrequenciesHi            ;; 04:43e7 $11 $1b $48
    add  A, E                                          ;; 04:43ea $83
    ld   E, A                                          ;; 04:43eb $5f
    jr   NC, .jr_04_43ef                               ;; 04:43ec $30 $01
    inc  D                                             ;; 04:43ee $14
.jr_04_43ef:
    ld   A, [DE]                                       ;; 04:43ef $1a
    ld   [wDF34_Audio_Ch3_NR34Shadow], A               ;; 04:43f0 $ea $34 $df
    pop  AF                                            ;; 04:43f3 $f1
    ld   DE, data_04_47bb_NoteFrequenciesLo            ;; 04:43f4 $11 $bb $47
    add  A, E                                          ;; 04:43f7 $83
    ld   E, A                                          ;; 04:43f8 $5f
    jr   NC, .jr_04_43fc                               ;; 04:43f9 $30 $01
    inc  D                                             ;; 04:43fb $14
.jr_04_43fc:
    ld   A, [DE]                                       ;; 04:43fc $1a
    ld   [wDF35_Audio_Ch3_NR33Shadow], A               ;; 04:43fd $ea $35 $df
    inc  BC                                            ;; 04:4400 $03
    ld   A, C                                          ;; 04:4401 $79
    ld   [wDF41_Audio_Ch3_ArpPtrLo], A                 ;; 04:4402 $ea $41 $df
    ld   A, B                                          ;; 04:4405 $78
    ld   [wDF42_Audio_Ch3_ArpPtrHi], A                 ;; 04:4406 $ea $42 $df
    jp   .jp_04_441b                                   ;; 04:4409 $c3 $1b $44
.jr_04_440c:
    ld   A, $01                                        ;; 04:440c $3e $01
    ld   [wDF40_Audio_Ch3_ArpTimer], A                 ;; 04:440e $ea $40 $df
    inc  BC                                            ;; 04:4411 $03
    ld   A, [BC]                                       ;; 04:4412 $0a
    ld   [wDF41_Audio_Ch3_ArpPtrLo], A                 ;; 04:4413 $ea $41 $df
    inc  BC                                            ;; 04:4416 $03
    ld   A, [BC]                                       ;; 04:4417 $0a
    ld   [wDF42_Audio_Ch3_ArpPtrHi], A                 ;; 04:4418 $ea $42 $df

.jp_04_441b:
; --- channel 4, noise. No arpeggio; its period comes from Audio_StepNoisePeriod and
; the register write happens whether or not a sound effect owns the channel, because
; Audio_WriteChannelRegs tests AUDIO_CHF_ENABLED for itself ---
    ld   A, $03                                        ;; 04:441b $3e $03
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 04:441d $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 04:4420 $21 $62 $df
    ld   DE, .jp_04_441b                               ;; 04:4423 $11 $1b $44
    ld   [HL], E                                       ;; 04:4426 $73
    inc  HL                                            ;; 04:4427 $23
    ld   [HL], D                                       ;; 04:4428 $72
    ld   A, [wDF5C_Audio_Ch4_Transpose]                ;; 04:4429 $fa $5c $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 04:442c $ea $65 $df
    ld   HL, wDF48_Audio_Ch4_Flags                     ;; 04:442f $21 $48 $df
    ld   DE, rNR41                                     ;; 04:4432 $11 $20 $ff
    call call_04_44d4_Audio_RunSequence                ;; 04:4435 $cd $d4 $44
    ld   A, [wDF48_Audio_Ch4_Flags]                    ;; 04:4438 $fa $48 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 04:443b $e6 $01
    jr   Z, .jp_04_4462                                ;; 04:443d $28 $23
    ld   A, [wDF72_Audio_Ch4_SfxPtrHi]                 ;; 04:443f $fa $72 $df
    and  A, A                                          ;; 04:4442 $a7
    jp   NZ, .jp_04_4462                               ;; 04:4443 $c2 $62 $44
    ld   HL, wDF52_Audio_Ch4_EnvelopeTimer             ;; 04:4446 $21 $52 $df
    ld   DE, wDF53_Audio_Ch4_EnvelopePtrLo             ;; 04:4449 $11 $53 $df
    ld   A, [DE]                                       ;; 04:444c $1a
    ld   C, A                                          ;; 04:444d $4f
    inc  DE                                            ;; 04:444e $13
    ld   A, [DE]                                       ;; 04:444f $1a
    ld   B, A                                          ;; 04:4450 $47
    ld   DE, rNR42                                     ;; 04:4451 $11 $21 $ff
    call call_04_446c_Audio_StepVolumeEnvelope         ;; 04:4454 $cd $6c $44
    ld   DE, wDF53_Audio_Ch4_EnvelopePtrLo             ;; 04:4457 $11 $53 $df
    ld   A, C                                          ;; 04:445a $79
    ld   [DE], A                                       ;; 04:445b $12
    ld   A, B                                          ;; 04:445c $78
    inc  DE                                            ;; 04:445d $13
    ld   [DE], A                                       ;; 04:445e $12
    call call_04_45de_Audio_StepNoisePeriod            ;; 04:445f $cd $de $45
.jp_04_4462:
    ld   HL, wDF48_Audio_Ch4_Flags                     ;; 04:4462 $21 $48 $df
    ld   DE, rNR43                                     ;; 04:4465 $11 $22 $ff
    call call_04_45a7_Audio_WriteChannelRegs           ;; 04:4468 $cd $a7 $45
    ret                                                ;; 04:446b $c9

call_04_446c_Audio_StepVolumeEnvelope:
; One tick of a channel's volume envelope. HL points at its AUDIO_CH_ENV_TIMER byte, BC
; at its position in the envelope, DE at the channel's NRx2 register.
;
; An envelope is pairs of (register value, frames to hold it) ending in
; AUDIO_ENV_END. Writing NRx2 alone does not make the new volume audible - the hardware
; only latches it on a trigger - so each step also sets the trigger bit in the channel's
; NRx4 shadow and copies the value into the NRx2 shadow, and the next
; Audio_WriteChannelRegs retriggers the note at the new volume.
;
; The two `sub $06` / `add $04` hops are how it walks from AUDIO_CH_ENV_TIMER back to
; AUDIO_CH_NRX4_SHADOW and forward to AUDIO_CH_NRX2_SHADOW without a second pointer
    ld   A, [HL]                                       ;; 04:446c $7e
    and  A, A                                          ;; 04:446d $a7
    ret  Z                                             ;; 04:446e $c8
    dec  [HL]                                          ;; 04:446f $35
    ret  NZ                                            ;; 04:4470 $c0
    ld   A, [BC]                                       ;; 04:4471 $0a
    cp   A, AUDIO_ENV_END                              ;; 04:4472 $fe $ff
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
    sub  A, AUDIO_CH_ENV_TIMER - AUDIO_CH_NRX4_SHADOW  ;; 04:447f $d6 $06
    ld   L, A                                          ;; 04:4481 $6f
    jr   NC, .jr_04_4485                               ;; 04:4482 $30 $01
    dec  H                                             ;; 04:4484 $25
.jr_04_4485:
    ld   A, [HL]                                       ;; 04:4485 $7e
    or   A, AUDIO_NRX4_TRIGGER                         ;; 04:4486 $f6 $80
    ld   [HL], A                                       ;; 04:4488 $77
    ld   A, L                                          ;; 04:4489 $7d
    add  A, AUDIO_CH_NRX2_SHADOW - AUDIO_CH_NRX4_SHADOW ;; 04:448a $c6 $04
    ld   L, A                                          ;; 04:448c $6f
    jr   NC, .jr_04_4490                               ;; 04:448d $30 $01
    inc  H                                             ;; 04:448f $24
.jr_04_4490:
    ld   A, [DE]                                       ;; 04:4490 $1a
    ld   [HL], A                                       ;; 04:4491 $77
    inc  BC                                            ;; 04:4492 $03
    ret                                                ;; 04:4493 $c9

call_04_4494_Audio_StepPitchSlide:
; One tick of a channel's pitch slide - vibrato, bends, drops, whatever the instrument
; asks for. HL points at AUDIO_CH_PITCH_TIMER, BC at the position in the slide, DE at
; the channel's AUDIO_CH_NRX3_SHADOW.
;
; A slide is pairs of (signed offset, frames to hold), and the offset is added to the
; channel's NRx4:NRx3 shadow pair read as one 16-bit number - so a slide that pushes the
; frequency past $FF carries into the register that also holds the trigger bit, which is
; exactly what the bigger bends rely on. AUDIO_PITCH_END stops; AUDIO_PITCH_LOOP takes a
; two-byte address and jumps
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
    cp   A, AUDIO_PITCH_END                            ;; 04:44a4 $fe $7e
    jr   NZ, .jr_04_44aa                               ;; 04:44a6 $20 $02
    pop  HL                                            ;; 04:44a8 $e1
    ret                                                ;; 04:44a9 $c9
.jr_04_44aa:
    cp   A, AUDIO_PITCH_LOOP                           ;; 04:44aa $fe $7d
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

call_04_44d4_Audio_RunSequence:
; Advances one channel's pattern by one tick. HL points at the channel block, DE at that
; channel's NRx1 register. This is gex3's answer to gex2's
; call_21_4199_Audio_RunSequence, and it works the same way - run commands until
; something produces a note, then stop - but the note's duration is stored back into the
; channel block rather than returned.
;
; It does nothing at all unless AUDIO_CHF_RUNNING is set and the note timer has just run
; out, so a held note costs three instructions per frame.
;
; A byte with bits 0-6 at $5F or above is a command and goes to
; Audio_DispatchCommand. Anything else is a note, and what follows is the whole of
; starting one:
;
;   - bits 0-6 plus wDF65_Audio_CurrentTranspose index the two frequency tables, and the
;     result is remembered in wDF7C/7D/7E so an arpeggio can work relative to it
;   - the parameter byte's low nibble indexes the song's note-length table for the
;     duration, and its high nibble - plus 16 if bit 7 of the note byte was set - picks
;     one of the 32 instruments
;   - the instrument's twelve bytes are copied into the channel block: the NRx4 base is
;     OR'd onto the frequency high bits, NRx1 and NRx2 are set outright, and the three
;     (timer, pointer) pairs arm the envelope, the pitch slide and the arpeggio
    ld   A, [HL]                                       ;; 04:44d4 $7e
    and  A, AUDIO_CHF_RUNNING                          ;; 04:44d5 $e6 $02
    ret  Z                                             ;; 04:44d7 $c8
    inc  HL                                            ;; 04:44d8 $23
    dec  [HL]                                          ;; 04:44d9 $35
    ret  NZ                                            ;; 04:44da $c0
    inc  HL                                            ;; 04:44db $23
    ld   C, [HL]                                       ;; 04:44dc $4e
    inc  HL                                            ;; 04:44dd $23
    ld   B, [HL]                                       ;; 04:44de $46
    ld   A, [BC]                                       ;; 04:44df $0a
    ld   [wDF66_Audio_CurrentNoteByte], A              ;; 04:44e0 $ea $66 $df
    and  A, AUDIO_NOTE_INDEX_MASK                      ;; 04:44e3 $e6 $7f
    cp   A, AUDIO_CMD_FIRST - 1                        ;; 04:44e5 $fe $5f
    jp   NC, call_04_4637_Audio_DispatchCommand        ;; 04:44e7 $d2 $37 $46
    push DE                                            ;; 04:44ea $d5
    ld   DE, wDF65_Audio_CurrentTranspose              ;; 04:44eb $11 $65 $df
    ld   A, [DE]                                       ;; 04:44ee $1a
    ld   D, A                                          ;; 04:44ef $57
    ld   A, [BC]                                       ;; 04:44f0 $0a
    and  A, AUDIO_NOTE_INDEX_MASK                      ;; 04:44f1 $e6 $7f
    add  A, D                                          ;; 04:44f3 $82
    ld   D, A                                          ;; 04:44f4 $57
    push AF                                            ;; 04:44f5 $f5
    ld   A, [wDF7B_Audio_ChannelIndex]                 ;; 04:44f6 $fa $7b $df
    cp   A, $00                                        ;; 04:44f9 $fe $00
    jr   NZ, .jr_04_4501                               ;; 04:44fb $20 $04
    ld   A, D                                          ;; 04:44fd $7a
    ld   [wDF7C_Audio_Ch1_CurrentNote], A              ;; 04:44fe $ea $7c $df
.jr_04_4501:
    cp   A, $01                                        ;; 04:4501 $fe $01
    jr   NZ, .jr_04_4509                               ;; 04:4503 $20 $04
    ld   A, D                                          ;; 04:4505 $7a
    ld   [wDF7D_Audio_Ch2_CurrentNote], A              ;; 04:4506 $ea $7d $df
.jr_04_4509:
    cp   A, $02                                        ;; 04:4509 $fe $02
    jr   NZ, .jr_04_4511                               ;; 04:450b $20 $04
    ld   A, D                                          ;; 04:450d $7a
    ld   [wDF7E_Audio_Ch3_CurrentNote], A              ;; 04:450e $ea $7e $df
.jr_04_4511:
    pop  AF                                            ;; 04:4511 $f1
    ld   DE, data_04_481b_NoteFrequenciesHi            ;; 04:4512 $11 $1b $48
    add  A, E                                          ;; 04:4515 $83
    ld   E, A                                          ;; 04:4516 $5f
    jp   NC, .jp_04_451b                               ;; 04:4517 $d2 $1b $45
    inc  D                                             ;; 04:451a $14
.jp_04_451b:
    ld   A, [DE]                                       ;; 04:451b $1a
    inc  HL                                            ;; 04:451c $23
    ld   [HL], A                                       ;; 04:451d $77
    ld   DE, wDF65_Audio_CurrentTranspose              ;; 04:451e $11 $65 $df
    ld   A, [DE]                                       ;; 04:4521 $1a
    ld   D, A                                          ;; 04:4522 $57
    ld   A, [BC]                                       ;; 04:4523 $0a
    and  A, AUDIO_NOTE_INDEX_MASK                      ;; 04:4524 $e6 $7f
    add  A, D                                          ;; 04:4526 $82
    ld   DE, data_04_47bb_NoteFrequenciesLo            ;; 04:4527 $11 $bb $47
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
    and  A, AUDIO_NOTE_LENGTH_MASK                     ;; 04:4534 $e6 $0f
    push HL                                            ;; 04:4536 $e5
    ld   HL, wDF61_Audio_NoteLengthTablePtrHi          ;; 04:4537 $21 $61 $df
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
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_NRX3_SHADOW ;; 04:4544 $11 $fc $ff
    add  HL, DE                                        ;; 04:4547 $19
    ld   [HL], A                                       ;; 04:4548 $77
    ld   A, [wDF66_Audio_CurrentNoteByte]              ;; 04:4549 $fa $66 $df
    and  A, AUDIO_NOTE_INSTRUMENT_BANK                 ;; 04:454c $e6 $80
    srl  A                                             ;; 04:454e $cb $3f
    srl  A                                             ;; 04:4550 $cb $3f
    ld   D, A                                          ;; 04:4552 $57
    ld   A, [BC]                                       ;; 04:4553 $0a
    and  A, AUDIO_NOTE_INSTRUMENT_MASK                 ;; 04:4554 $e6 $f0
    srl  A                                             ;; 04:4556 $cb $3f
    srl  A                                             ;; 04:4558 $cb $3f
    srl  A                                             ;; 04:455a $cb $3f
    add  A, D                                          ;; 04:455c $82
    push HL                                            ;; 04:455d $e5
    ld   HL, data_04_70d1_InstrumentPointers           ;; 04:455e $21 $d1 $70
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

call_04_45a7_Audio_WriteChannelRegs:
; Pushes a channel's shadow registers out to the hardware. HL points at the channel
; block, DE at its NRx3 register.
;
; NRx3 always goes out. NRx4 only takes its trigger bit along if AUDIO_NRX4_TRIGGER is
; still set in the shadow, and when it is, NRx1 and NRx2 are written first so the note
; starts with the right duty and volume. The trigger bit is then cleared in the shadow,
; so a note fires once and later ticks only slide its pitch.
;
; The noise channel has no frequency: its NR43 comes from
; wDF64_Audio_NoisePeriod instead, which Audio_StepNoisePeriod and
; AUDIO_CMD_SET_NOISE_PERIOD maintain
    ld   A, [HL]                                       ;; 04:45a7 $7e
    and  A, AUDIO_CHF_ENABLED                          ;; 04:45a8 $e6 $01
    ret  Z                                             ;; 04:45aa $c8
    ld   BC, AUDIO_CH_NRX3_SHADOW                      ;; 04:45ab $01 $05 $00
    add  HL, BC                                        ;; 04:45ae $09
    ld   A, E                                          ;; 04:45af $7b
    cp   A, LOW(rNR43)                                 ;; 04:45b0 $fe $22
    jp   Z, .jp_04_45d5                                ;; 04:45b2 $ca $d5 $45
    ld   A, [HL]                                       ;; 04:45b5 $7e
    ld   [DE], A                                       ;; 04:45b6 $12
.jr_04_45b7:
    dec  HL                                            ;; 04:45b7 $2b
    inc  DE                                            ;; 04:45b8 $13
    push DE                                            ;; 04:45b9 $d5
    push HL                                            ;; 04:45ba $e5
    ld   A, [HL]                                       ;; 04:45bb $7e
    and  A, AUDIO_NRX4_TRIGGER                         ;; 04:45bc $e6 $80
    jr   Z, .jr_04_45cd                                ;; 04:45be $28 $0d
    ld   BC, AUDIO_CH_NRX1_SHADOW - AUDIO_CH_NRX4_SHADOW ;; 04:45c0 $01 $03 $00
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
    and  A, ~AUDIO_NRX4_TRIGGER & $ff                  ;; 04:45d1 $e6 $7f
    ld   [HL], A                                       ;; 04:45d3 $77
    ret                                                ;; 04:45d4 $c9
.jp_04_45d5:
    ld   A, [wDF64_Audio_NoisePeriod]                  ;; 04:45d5 $fa $64 $df
    ld   [wDF4D_Audio_Ch4_NR43Shadow], A               ;; 04:45d8 $ea $4d $df
    ld   [DE], A                                       ;; 04:45db $12
    jr   .jr_04_45b7                                   ;; 04:45dc $18 $d9

call_04_45de_Audio_StepNoisePeriod:
; The noise channel's stand-in for a pitch slide. It reuses channel 4's
; AUDIO_CH_PITCH_TIMER and AUDIO_CH_PITCH_PTR slots, but the data is absolute NR43
; values rather than signed offsets, because a polynomial counter setting has nothing to
; add to.
;
; Pairs of (NR43 value, frames to hold), with AUDIO_PITCH_END stopping and
; AUDIO_PITCH_LOOP taking a two-byte address - the same two terminators
; Audio_StepPitchSlide uses. The value lands in wDF64_Audio_NoisePeriod, which
; Audio_WriteChannelRegs picks up
    ld   A, [wDF55_Audio_Ch4_PitchTimer]               ;; 04:45de $fa $55 $df
    and  A, A                                          ;; 04:45e1 $a7
    ret  Z                                             ;; 04:45e2 $c8
    dec  A                                             ;; 04:45e3 $3d
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 04:45e4 $ea $55 $df
    and  A, A                                          ;; 04:45e7 $a7
    ret  NZ                                            ;; 04:45e8 $c0
    ld   A, [wDF56_Audio_Ch4_PitchPtrLo]               ;; 04:45e9 $fa $56 $df
    ld   L, A                                          ;; 04:45ec $6f
    ld   A, [wDF57_Audio_Ch4_PitchPtrHi]               ;; 04:45ed $fa $57 $df
    ld   H, A                                          ;; 04:45f0 $67
    ld   A, [HL]                                       ;; 04:45f1 $7e
    cp   A, AUDIO_PITCH_END                            ;; 04:45f2 $fe $7e
    ret  Z                                             ;; 04:45f4 $c8
    cp   A, AUDIO_PITCH_LOOP                           ;; 04:45f5 $fe $7d
    jr   Z, .jr_04_460b                                ;; 04:45f7 $28 $12
    ld   [wDF64_Audio_NoisePeriod], A                  ;; 04:45f9 $ea $64 $df
    inc  HL                                            ;; 04:45fc $23
    ld   A, [HL]                                       ;; 04:45fd $7e
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 04:45fe $ea $55 $df
    inc  HL                                            ;; 04:4601 $23
    ld   A, L                                          ;; 04:4602 $7d
    ld   [wDF56_Audio_Ch4_PitchPtrLo], A               ;; 04:4603 $ea $56 $df
    ld   A, H                                          ;; 04:4606 $7c
    ld   [wDF57_Audio_Ch4_PitchPtrHi], A               ;; 04:4607 $ea $57 $df
    ret                                                ;; 04:460a $c9
.jr_04_460b:
    ld   A, $01                                        ;; 04:460b $3e $01
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 04:460d $ea $55 $df
    inc  HL                                            ;; 04:4610 $23
    ld   A, [HL]                                       ;; 04:4611 $7e
    ld   [wDF56_Audio_Ch4_PitchPtrLo], A               ;; 04:4612 $ea $56 $df
    inc  HL                                            ;; 04:4615 $23
    ld   A, [HL]                                       ;; 04:4616 $7e
    ld   [wDF57_Audio_Ch4_PitchPtrHi], A               ;; 04:4617 $ea $57 $df
    ret                                                ;; 04:461a $c9

data_04_461b_AudioCommandTable:
; One address per AUDIO_CMD_*, in opcode order from AUDIO_CMD_SET_NOTE_LENGTH. The
; dispatcher indexes it from its second byte and reads the high byte first, which is why
; every reference to it in code is written as `+ 1`
    dw   call_04_464b_AudioCmd_SetNoteLength           ; $60
    dw   call_04_4667_AudioCmd_End                     ; $61
    dw   call_04_4670_AudioCmd_Goto                    ; $62
    dw   call_04_4681_AudioCmd_SetNoisePeriod          ; $63
    dw   call_04_4695_AudioCmd_CallPattern             ; $64
    dw   call_04_46e0_AudioCmd_EndPattern              ; $65
    dw   call_04_4719_AudioCmd_SetMarker               ; $66
    dw   call_04_472d_AudioCmd_SetPanning              ; $67
    dw   call_04_4782_AudioCmd_SetNoteLengthTable      ; $68
    dw   call_04_479a_AudioCmd_SetTempo                ; $69
    dw   call_04_4742_AudioCmd_SetPanningCh1           ; $6A
    dw   call_04_4752_AudioCmd_SetPanningCh2           ; $6B
    dw   call_04_4762_AudioCmd_SetPanningCh3           ; $6C
    dw   call_04_4772_AudioCmd_SetPanningCh4           ; $6D

call_04_4637_Audio_DispatchCommand:
; Reached by `jp` from Audio_RunSequence with A holding the command byte's low seven
; bits, BC on the command in the pattern and HL on AUDIO_CH_SEQ_PTR_HI.
;
; The note timer, which Audio_RunSequence has just decremented to zero, is put back to 1
; so that the channel comes round again on the very next tick if the handler does not
; set a real duration itself.
;
; HL is pushed for the handler to pop - which is also what lets a handler discard the
; return address by jumping to Audio_ResumeChannel instead of returning
    sub  A, AUDIO_CMD_SET_NOTE_LENGTH                  ;; 04:4637 $d6 $60
    add  A, A                                          ;; 04:4639 $87
    push HL                                            ;; 04:463a $e5
    dec  HL                                            ;; 04:463b $2b
    dec  HL                                            ;; 04:463c $2b
    inc  [HL]                                          ;; 04:463d $34
    ld   HL, data_04_461b_AudioCommandTable + 1        ;; 04:463e $21 $1c $46
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

call_04_464b_AudioCmd_SetNoteLength:
; $60 nn - hold the channel for note-length nn.
;
; The low nibble of the argument indexes the song's note-length table and the result
; becomes the note timer directly, so this is a rest at whatever the last note's pitch
; and volume were - nothing is retriggered. It is the one command that ends the
; channel's turn, because it returns rather than jumping to Audio_ResumeChannel.
;
; The `jr` over the `inc H` is unconditional, so a note-length table that straddles a
; page boundary would read from the wrong page; every table in both banks sits well
; inside one
    ld   HL, wDF61_Audio_NoteLengthTablePtrHi          ;; 04:464b $21 $61 $df
    ld   A, [HL]                                       ;; 04:464e $7e
    dec  HL                                            ;; 04:464f $2b
    ld   L, [HL]                                       ;; 04:4650 $6e
    ld   H, A                                          ;; 04:4651 $67
    inc  BC                                            ;; 04:4652 $03
    ld   A, [BC]                                       ;; 04:4653 $0a
    and  A, AUDIO_NOTE_LENGTH_MASK                     ;; 04:4654 $e6 $0f
    add  A, L                                          ;; 04:4656 $85
    ld   L, A                                          ;; 04:4657 $6f
    jr   .jr_04_465b                                   ;; 04:4658 $18 $01
    inc  H                                             ;; 04:465a $24
.jr_04_465b:
    ld   A, [HL]                                       ;; 04:465b $7e
    pop  HL                                            ;; 04:465c $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:465d $11 $fe $ff
    add  HL, DE                                        ;; 04:4660 $19
    ld   [HL], A                                       ;; 04:4661 $77
    inc  BC                                            ;; 04:4662 $03
    inc  HL                                            ;; 04:4663 $23
    jp   call_04_47ad_Audio_StoreSeqPtr                ;; 04:4664 $c3 $ad $47

call_04_4667_AudioCmd_End:
; $61 - stop the channel. Clearing the flag byte drops both AUDIO_CHF_ENABLED and
; AUDIO_CHF_RUNNING, so nothing reads the pattern again and nothing writes the
; registers again; whatever note was sounding decays on its own.
;
; gex2's AUDIO_CMD_END also hands the channel back to the music when a sound effect ends;
; here that is Audio_StepSfxTrack's job instead
    pop  HL                                            ;; 04:4667 $e1
    ld   BC, AUDIO_CH_FLAGS - AUDIO_CH_SEQ_PTR_HI      ;; 04:4668 $01 $fd $ff
    add  HL, BC                                        ;; 04:466b $09
    ld   A, $00                                        ;; 04:466c $3e $00
    ld   [HL], A                                       ;; 04:466e $77
    ret                                                ;; 04:466f $c9

call_04_4670_AudioCmd_Goto:
; $62 ll hh - jump to an absolute address. Unlike gex2's AUDIO_CMD_LOOP, which stores a
; backwards distance, gex3 writes the target out in full, so a pattern can be jumped to
; from anywhere. The note timer is set to 1 so the new position is read on the next tick
    pop  HL                                            ;; 04:4670 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:4671 $11 $fe $ff
    add  HL, DE                                        ;; 04:4674 $19
    ld   A, $01                                        ;; 04:4675 $3e $01
    ld   [HL+], A                                      ;; 04:4677 $22
    inc  BC                                            ;; 04:4678 $03
    ld   A, [BC]                                       ;; 04:4679 $0a
    ld   [HL+], A                                      ;; 04:467a $22
    inc  BC                                            ;; 04:467b $03
    ld   A, [BC]                                       ;; 04:467c $0a
    ld   [HL], A                                       ;; 04:467d $77
    jp   call_04_47b1_Audio_ResumeChannel              ;; 04:467e $c3 $b1 $47

call_04_4681_AudioCmd_SetNoisePeriod:
; $63 nn - set the noise channel's NR43 outright. Only channel 4 has any use for it, but
; nothing stops another channel from running it, in which case it changes the noise
; behind that channel's back
    pop  HL                                            ;; 04:4681 $e1
    inc  BC                                            ;; 04:4682 $03
    ld   A, [BC]                                       ;; 04:4683 $0a
    ld   [wDF64_Audio_NoisePeriod], A                  ;; 04:4684 $ea $64 $df
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:4687 $11 $fe $ff
    add  HL, DE                                        ;; 04:468a $19
    ld   A, $01                                        ;; 04:468b $3e $01
    ld   [HL+], A                                      ;; 04:468d $22
    inc  BC                                            ;; 04:468e $03
    call call_04_47ad_Audio_StoreSeqPtr                ;; 04:468f $cd $ad $47
    jp   call_04_47b1_Audio_ResumeChannel              ;; 04:4692 $c3 $b1 $47

call_04_4695_AudioCmd_CallPattern:
; $64 pp tt rr - play pattern pp, transposed by tt, rr times.
;
; This is the song form: a channel's top-level stream is almost entirely these, and the
; patterns they name are the reusable phrases. pp is an index into
; data_04_766f_PatternPointers - eight bits of index plus the carry out of the doubling,
; so 256 patterns are reachable through two 256-byte halves of the table.
;
; The repeat counter is only loaded when AUDIO_CH_LOOP_ACTIVE is clear, so re-entering a
; block that is already counting down does not restart the count. Audio_StartSong presets
; that flag on channels 3 and 4 to keep their opening pattern from being counted.
;
; gex2 has no equivalent - its tracks are flat, and a whole song channel is one long
; stream with a single backwards jump at the end
    pop  HL                                            ;; 04:4695 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:4696 $11 $fe $ff
    add  HL, DE                                        ;; 04:4699 $19
    ld   A, $01                                        ;; 04:469a $3e $01
    ld   [HL+], A                                      ;; 04:469c $22
    inc  BC                                            ;; 04:469d $03
    ld   A, [BC]                                       ;; 04:469e $0a
    sla  A                                             ;; 04:469f $cb $27
    jr   NC, .jr_04_46a9                               ;; 04:46a1 $30 $06
    ld   DE, data_04_766f_PatternPointers              ;; 04:46a3 $11 $6f $76
    inc  D                                             ;; 04:46a6 $14
    jr   .jr_04_46ac                                   ;; 04:46a7 $18 $03
.jr_04_46a9:
    ld   DE, data_04_766f_PatternPointers              ;; 04:46a9 $11 $6f $76
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
    ld   A, AUDIO_CH_TRANSPOSE - AUDIO_CH_NRX4_SHADOW  ;; 04:46b8 $3e $10
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
    jp   call_04_47b1_Audio_ResumeChannel              ;; 04:46dd $c3 $b1 $47

call_04_46e0_AudioCmd_EndPattern:
; $65 - end of the pattern AUDIO_CMD_CALL_PATTERN entered.
;
; While the repeat counter is above zero it decrements and jumps back to four bytes
; before the saved return address - the width of the call that got here - so the whole
; command runs again, transpose and all. When it hits zero the loop state is cleared and
; the channel carries on from the saved address
    inc  BC                                            ;; 04:46e0 $03
    pop  HL                                            ;; 04:46e1 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:46e2 $11 $fe $ff
    add  HL, DE                                        ;; 04:46e5 $19
    ld   A, $01                                        ;; 04:46e6 $3e $01
    ld   [HL+], A                                      ;; 04:46e8 $22
    ld   D, H                                          ;; 04:46e9 $54
    ld   E, L                                          ;; 04:46ea $5d
    ld   A, AUDIO_CH_LOOP_COUNTER - AUDIO_CH_SEQ_PTR_LO ;; 04:46eb $3e $11
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
    sub  A, AUDIO_CALL_PATTERN_SIZE                    ;; 04:46fd $d6 $04
    ld   [HL+], A                                      ;; 04:46ff $22
    inc  DE                                            ;; 04:4700 $13
    ld   A, [DE]                                       ;; 04:4701 $1a
    jr   NC, .jr_04_4706                               ;; 04:4702 $30 $02
    sub  A, $01                                        ;; 04:4704 $d6 $01
.jr_04_4706:
    ld   [HL], A                                       ;; 04:4706 $77
    jp   call_04_47b1_Audio_ResumeChannel              ;; 04:4707 $c3 $b1 $47
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
    jp   call_04_47b1_Audio_ResumeChannel              ;; 04:4716 $c3 $b1 $47

call_04_4719_AudioCmd_SetMarker:
; $66 nn - store nn in wDF67_Audio_Marker, which nothing ever reads. Presumably a
; sequencer feature that never grew a runtime meaning; the patterns still carry it
    inc  BC                                            ;; 04:4719 $03
    ld   A, [BC]                                       ;; 04:471a $0a
    ld   [wDF67_Audio_Marker], A                       ;; 04:471b $ea $67 $df
    pop  HL                                            ;; 04:471e $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:471f $11 $fe $ff
    add  HL, DE                                        ;; 04:4722 $19
    ld   A, $01                                        ;; 04:4723 $3e $01
    ld   [HL+], A                                      ;; 04:4725 $22
    inc  BC                                            ;; 04:4726 $03
    call call_04_47ad_Audio_StoreSeqPtr                ;; 04:4727 $cd $ad $47
    jp   call_04_47b1_Audio_ResumeChannel              ;; 04:472a $c3 $b1 $47

call_04_472d_AudioCmd_SetPanning:
; $67 nn - set rNR51 for all four channels at once. The four per-channel forms below
; share this one's tail
    inc  BC                                            ;; 04:472d $03
    ld   A, [BC]                                       ;; 04:472e $0a
    ldh  [rNR51], A                                    ;; 04:472f $e0 $25
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:4731 $ea $79 $df

jr_04_4734_AudioCmd_StorePtrAndResume:
; Shared tail of the five panning commands: step past the argument, set the note timer
; to 1, save the pattern position and go round again
    inc  BC                                            ;; 04:4734 $03
    pop  HL                                            ;; 04:4735 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:4736 $11 $fe $ff
    add  HL, DE                                        ;; 04:4739 $19
    ld   A, $01                                        ;; 04:473a $3e $01
    ld   [HL+], A                                      ;; 04:473c $22
    call call_04_47ad_Audio_StoreSeqPtr                ;; 04:473d $cd $ad $47
    jr   call_04_47b1_Audio_ResumeChannel              ;; 04:4740 $18 $6f

call_04_4742_AudioCmd_SetPanningCh1:
; $6A nn - replace only channel 1's two bits of rNR51, keeping the other three channels
; where they are
    inc  BC                                            ;; 04:4742 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:4743 $fa $79 $df
    and  A, ~AUDIO_NR51_CH1 & $ff                      ;; 04:4746 $e6 $ee
    ld   H, A                                          ;; 04:4748 $67
    ld   A, [BC]                                       ;; 04:4749 $0a
    or   A, H                                          ;; 04:474a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:474b $ea $79 $df
    ldh  [rNR51], A                                    ;; 04:474e $e0 $25
    jr   jr_04_4734_AudioCmd_StorePtrAndResume         ;; 04:4750 $18 $e2

call_04_4752_AudioCmd_SetPanningCh2:
; $6B nn
    inc  BC                                            ;; 04:4752 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:4753 $fa $79 $df
    and  A, ~AUDIO_NR51_CH2 & $ff                      ;; 04:4756 $e6 $dd
    ld   H, A                                          ;; 04:4758 $67
    ld   A, [BC]                                       ;; 04:4759 $0a
    or   A, H                                          ;; 04:475a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:475b $ea $79 $df
    ldh  [rNR51], A                                    ;; 04:475e $e0 $25
    jr   jr_04_4734_AudioCmd_StorePtrAndResume         ;; 04:4760 $18 $d2

call_04_4762_AudioCmd_SetPanningCh3:
; $6C nn
    inc  BC                                            ;; 04:4762 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:4763 $fa $79 $df
    and  A, ~AUDIO_NR51_CH3 & $ff                      ;; 04:4766 $e6 $bb
    ld   H, A                                          ;; 04:4768 $67
    ld   A, [BC]                                       ;; 04:4769 $0a
    or   A, H                                          ;; 04:476a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:476b $ea $79 $df
    ldh  [rNR51], A                                    ;; 04:476e $e0 $25
    jr   jr_04_4734_AudioCmd_StorePtrAndResume         ;; 04:4770 $18 $c2

call_04_4772_AudioCmd_SetPanningCh4:
; $6D nn
    inc  BC                                            ;; 04:4772 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:4773 $fa $79 $df
    and  A, ~AUDIO_NR51_CH4 & $ff                      ;; 04:4776 $e6 $77
    ld   H, A                                          ;; 04:4778 $67
    ld   A, [BC]                                       ;; 04:4779 $0a
    or   A, H                                          ;; 04:477a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 04:477b $ea $79 $df
    ldh  [rNR51], A                                    ;; 04:477e $e0 $25
    jr   jr_04_4734_AudioCmd_StorePtrAndResume         ;; 04:4780 $18 $b2

call_04_4782_AudioCmd_SetNoteLengthTable:
; $68 ll hh - point the note-length lookup somewhere else, so a section can change its
; rhythmic grid without touching the tempo. Overrides the table the song table named
    inc  BC                                            ;; 04:4782 $03
    ld   A, [BC]                                       ;; 04:4783 $0a
    ld   [wDF60_Audio_NoteLengthTablePtrLo], A         ;; 04:4784 $ea $60 $df
    inc  BC                                            ;; 04:4787 $03
    ld   A, [BC]                                       ;; 04:4788 $0a
    ld   [wDF61_Audio_NoteLengthTablePtrHi], A         ;; 04:4789 $ea $61 $df
    pop  HL                                            ;; 04:478c $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:478d $11 $fe $ff
    add  HL, DE                                        ;; 04:4790 $19
    ld   A, $01                                        ;; 04:4791 $3e $01
    ld   [HL+], A                                      ;; 04:4793 $22
    inc  BC                                            ;; 04:4794 $03
    call call_04_47ad_Audio_StoreSeqPtr                ;; 04:4795 $cd $ad $47
    jr   call_04_47b1_Audio_ResumeChannel              ;; 04:4798 $18 $17

call_04_479a_AudioCmd_SetTempo:
; $69 nn - set wDF78_Audio_TempoRate from inside a pattern. Global, not per channel, so
; whichever channel reaches it first changes the speed of all four
    inc  BC                                            ;; 04:479a $03
    ld   A, [BC]                                       ;; 04:479b $0a
    ld   [wDF78_Audio_TempoRate], A                    ;; 04:479c $ea $78 $df
    pop  HL                                            ;; 04:479f $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 04:47a0 $11 $fe $ff
    add  HL, DE                                        ;; 04:47a3 $19
    ld   A, $01                                        ;; 04:47a4 $3e $01
    ld   [HL+], A                                      ;; 04:47a6 $22
    inc  BC                                            ;; 04:47a7 $03
    call call_04_47ad_Audio_StoreSeqPtr                ;; 04:47a8 $cd $ad $47
    jr   call_04_47b1_Audio_ResumeChannel              ;; 04:47ab $18 $04

call_04_47ad_Audio_StoreSeqPtr:
; Writes BC back into AUDIO_CH_SEQ_PTR, which HL is pointing at
    ld   [HL], C                                       ;; 04:47ad $71
    inc  HL                                            ;; 04:47ae $23
    ld   [HL], B                                       ;; 04:47af $70
    ret                                                ;; 04:47b0 $c9

call_04_47b1_Audio_ResumeChannel:
; How a command handler gets back to work. The `pop` throws away Audio_RunSequence's
; return address and the jump lands at the top of whichever channel block
; Audio_UpdateMusic is in the middle of, so the channel is processed again from the
; start and the next pattern byte is read immediately. That is why any number of
; commands can sit in front of a note without costing a tick
    pop  HL                                            ;; 04:47b1 $e1
    ld   DE, wDF62_Audio_ChannelResumePtrLo            ;; 04:47b2 $11 $62 $df
    ld   A, [DE]                                       ;; 04:47b5 $1a
    ld   L, A                                          ;; 04:47b6 $6f
    inc  DE                                            ;; 04:47b7 $13
    ld   A, [DE]                                       ;; 04:47b8 $1a
    ld   H, A                                          ;; 04:47b9 $67
    jp   HL                                            ;; 04:47ba $e9

data_04_47bb_NoteFrequenciesLo:
; The low byte of each note's 11-bit frequency, indexed by the
; AUDIO_NOTE_INDEX_MASK bits of a pattern byte plus the channel's transpose. Index
; $00 is C#2 and the table climbs a semitone at a time to AUDIO_NOTE_LAST; the top
; three bits of each value live in the table below. The last octave and a half is
; past anything the hardware resolves and is only reachable by transposing an
; already high note further.
;
; gex2 keeps the same thing as one table of little-endian words in
; data_21_43ce_NoteFrequencies
    db   $9d, $07, $6b, $ca, $23, $78, $c7, $12, $59, $9c, $db, $17        ;; 04:47bb  ; C#2-C3
    db   $4f, $84, $b6, $e5, $12, $3c, $64, $89, $ad, $ce, $ee, $0c        ;; 04:47c7  ; C#3-C4
    db   $28, $42, $5b, $73, $89, $9e, $b2, $c5, $d7, $e7, $f7, $06        ;; 04:47d3  ; C#4-C5
    db   $14, $21, $2e, $3a, $45, $4f, $59, $63, $6c, $74, $7c, $83        ;; 04:47df  ; C#5-C6
    db   $8a, $91, $97, $9d, $a3, $a8, $ad, $b1, $b6, $ba, $be, $c2        ;; 04:47eb  ; C#6-C7
    db   $c5, $c9, $cc, $cf, $d2, $d4, $d7, $d9, $db, $dd, $df, $e1        ;; 04:47f7  ; C#7-C8
    db   $e3, $e5, $e6, $e8, $e9, $ea, $ec, $ed, $ee, $ef, $f0, $f1        ;; 04:4803  ; C#8-C9
    db   $f2, $f3, $f3, $f4, $f5, $f5, $f7, $f7, $f8, $f8, $fa, $fa        ;; 04:480f  ; C#9-C10

data_04_481b_NoteFrequenciesHi:
; The high three bits of each note's frequency, ORed with the instrument's
; AUDIO_INS_NRX4_BASE on the way into the NRx4 shadow
    db   $00, $01, $01, $01, $02, $02, $02, $03, $03, $03, $03, $04        ;; 04:481b  ; C#2-C3
    db   $04, $04, $04, $04, $05, $05, $05, $05, $05, $05, $05, $06        ;; 04:4827  ; C#3-C4
    db   $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $07        ;; 04:4833  ; C#4-C5
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:483f  ; C#5-C6
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:484b  ; C#6-C7
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:4857  ; C#7-C8
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:4863  ; C#8-C9
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 04:486f  ; C#9-C10
call_04_487b_Audio_StartSfxTrack:
; Start one sound-effect track, id A - an index into
; data_04_49ed_SfxTrackPointers, not an SFX_* id. Audio_StartSfx turns one of those into
; up to four of these.
;
; The first byte of a track says which hardware channel it wants. That channel's
; AUDIO_CHF_ENABLED is cleared, so the music stops writing its registers but keeps
; reading its pattern, and wDF7A_Audio_SfxPanning is built from the current music
; panning with that channel forced to both sides - an effect is always heard centred
; however the song had the channel panned.
;
; The timer starts at 2 rather than 1 because Audio_StepSfxTrack decrements before
; testing, so the first row is read on the very next tick.
;
; The four channel cases are written out because each one owns a different set of WRAM
; bytes; they differ in nothing else. Falling through into Audio_UpdateSfx at the end
; means the effect's first row is written this frame instead of the next
    ld   HL, data_04_49ed_SfxTrackPointers             ;; 04:487b $21 $ed $49
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
    ld   A, AUDIO_NR52_ALL_ON                          ;; 04:488a $3e $8f
    ldh  [rNR52], A                                    ;; 04:488c $e0 $26
    ld   A, [BC]                                       ;; 04:488e $0a
    inc  BC                                            ;; 04:488f $03
    cp   A, $01                                        ;; 04:4890 $fe $01
    jr   Z, .jr_04_48bd                                ;; 04:4892 $28 $29
    cp   A, $02                                        ;; 04:4894 $fe $02
    jr   Z, .jr_04_48de                                ;; 04:4896 $28 $46
    cp   A, $03                                        ;; 04:4898 $fe $03
    jr   Z, .jr_04_48ff                                ;; 04:489a $28 $63
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:489c $fa $79 $df
    ld   D, A                                          ;; 04:489f $57
    ld   A, AUDIO_NR51_CH1                             ;; 04:48a0 $3e $11
    or   A, D                                          ;; 04:48a2 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 04:48a3 $ea $7a $df
    ld   A, [wDF00_Audio_Ch1_Flags]                    ;; 04:48a6 $fa $00 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 04:48a9 $e6 $fe
    ld   [wDF00_Audio_Ch1_Flags], A                    ;; 04:48ab $ea $00 $df
    ld   A, C                                          ;; 04:48ae $79
    ld   [wDF68_Audio_Ch1_SfxPtrLo], A                 ;; 04:48af $ea $68 $df
    ld   A, B                                          ;; 04:48b2 $78
    ld   [wDF69_Audio_Ch1_SfxPtrHi], A                 ;; 04:48b3 $ea $69 $df
    ld   A, $02                                        ;; 04:48b6 $3e $02
    ld   [wDF6A_Audio_Ch1_SfxTimer], A                 ;; 04:48b8 $ea $6a $df
    jr   call_04_491e_Audio_UpdateSfx                  ;; 04:48bb $18 $61
.jr_04_48bd:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:48bd $fa $79 $df
    ld   D, A                                          ;; 04:48c0 $57
    ld   A, AUDIO_NR51_CH2                             ;; 04:48c1 $3e $22
    or   A, D                                          ;; 04:48c3 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 04:48c4 $ea $7a $df
    ld   A, [wDF18_Audio_Ch2_Flags]                    ;; 04:48c7 $fa $18 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 04:48ca $e6 $fe
    ld   [wDF18_Audio_Ch2_Flags], A                    ;; 04:48cc $ea $18 $df
    ld   A, C                                          ;; 04:48cf $79
    ld   [wDF6B_Audio_Ch2_SfxPtrLo], A                 ;; 04:48d0 $ea $6b $df
    ld   A, B                                          ;; 04:48d3 $78
    ld   [wDF6C_Audio_Ch2_SfxPtrHi], A                 ;; 04:48d4 $ea $6c $df
    ld   A, $02                                        ;; 04:48d7 $3e $02
    ld   [wDF6D_Audio_Ch2_SfxTimer], A                 ;; 04:48d9 $ea $6d $df
    jr   call_04_491e_Audio_UpdateSfx                  ;; 04:48dc $18 $40
.jr_04_48de:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:48de $fa $79 $df
    ld   D, A                                          ;; 04:48e1 $57
    ld   A, AUDIO_NR51_CH3                             ;; 04:48e2 $3e $44
    or   A, D                                          ;; 04:48e4 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 04:48e5 $ea $7a $df
    ld   A, [wDF30_Audio_Ch3_Flags]                    ;; 04:48e8 $fa $30 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 04:48eb $e6 $fe
    ld   [wDF30_Audio_Ch3_Flags], A                    ;; 04:48ed $ea $30 $df
    ld   A, C                                          ;; 04:48f0 $79
    ld   [wDF6E_Audio_Ch3_SfxPtrLo], A                 ;; 04:48f1 $ea $6e $df
    ld   A, B                                          ;; 04:48f4 $78
    ld   [wDF6F_Audio_Ch3_SfxPtrHi], A                 ;; 04:48f5 $ea $6f $df
    ld   A, $02                                        ;; 04:48f8 $3e $02
    ld   [wDF70_Audio_Ch3_SfxTimer], A                 ;; 04:48fa $ea $70 $df
    jr   call_04_491e_Audio_UpdateSfx                  ;; 04:48fd $18 $1f
.jr_04_48ff:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:48ff $fa $79 $df
    ld   D, A                                          ;; 04:4902 $57
    ld   A, AUDIO_NR51_CH4                             ;; 04:4903 $3e $88
    or   A, D                                          ;; 04:4905 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 04:4906 $ea $7a $df
    ld   A, [wDF48_Audio_Ch4_Flags]                    ;; 04:4909 $fa $48 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 04:490c $e6 $fe
    ld   [wDF48_Audio_Ch4_Flags], A                    ;; 04:490e $ea $48 $df
    ld   A, C                                          ;; 04:4911 $79
    ld   [wDF71_Audio_Ch4_SfxPtrLo], A                 ;; 04:4912 $ea $71 $df
    ld   A, B                                          ;; 04:4915 $78
    ld   [wDF72_Audio_Ch4_SfxPtrHi], A                 ;; 04:4916 $ea $72 $df
    ld   A, $02                                        ;; 04:4919 $3e $02
    ld   [wDF73_Audio_Ch4_SfxTimer], A                 ;; 04:491b $ea $73 $df

call_04_491e_Audio_UpdateSfx:
; One tick of each of the four sound-effect slots. Sound effects are not on the music's
; tempo clock - they run once per frame regardless, so an effect sounds the same however
; fast or slow the song is.
;
; A slot is idle when both bytes of its pointer are zero, which is the state
; Audio_ResetDriver and the end of a track leave behind. The channel block's address goes
; into wDF74_Audio_SfxOwnerChannelPtr first so that Audio_StepSfxTrack can find the flags
; byte to restore when the effect finishes
    ld   HL, wDF00_Audio_Ch1_Flags                     ;; 04:491e $21 $00 $df
    ld   A, L                                          ;; 04:4921 $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 04:4922 $ea $74 $df
    ld   A, H                                          ;; 04:4925 $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 04:4926 $ea $75 $df
    ld   HL, wDF68_Audio_Ch1_SfxPtrLo                  ;; 04:4929 $21 $68 $df
    ld   C, [HL]                                       ;; 04:492c $4e
    inc  HL                                            ;; 04:492d $23
    ld   B, [HL]                                       ;; 04:492e $46
    ld   A, B                                          ;; 04:492f $78
    or   A, C                                          ;; 04:4930 $b1
    jr   Z, .jr_04_4939                                ;; 04:4931 $28 $06
    ld   DE, rNR11                                     ;; 04:4933 $11 $11 $ff
    call call_04_498b_Audio_StepSfxTrack               ;; 04:4936 $cd $8b $49
.jr_04_4939:
    ld   HL, wDF18_Audio_Ch2_Flags                     ;; 04:4939 $21 $18 $df
    ld   A, L                                          ;; 04:493c $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 04:493d $ea $74 $df
    ld   A, H                                          ;; 04:4940 $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 04:4941 $ea $75 $df
    ld   HL, wDF6B_Audio_Ch2_SfxPtrLo                  ;; 04:4944 $21 $6b $df
    ld   C, [HL]                                       ;; 04:4947 $4e
    inc  HL                                            ;; 04:4948 $23
    ld   B, [HL]                                       ;; 04:4949 $46
    ld   A, B                                          ;; 04:494a $78
    or   A, C                                          ;; 04:494b $b1
    jr   Z, .jr_04_4954                                ;; 04:494c $28 $06
    ld   DE, rNR21                                     ;; 04:494e $11 $16 $ff
    call call_04_498b_Audio_StepSfxTrack               ;; 04:4951 $cd $8b $49
.jr_04_4954:
    ld   HL, wDF30_Audio_Ch3_Flags                     ;; 04:4954 $21 $30 $df
    ld   A, L                                          ;; 04:4957 $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 04:4958 $ea $74 $df
    ld   A, H                                          ;; 04:495b $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 04:495c $ea $75 $df
    ld   HL, wDF6E_Audio_Ch3_SfxPtrLo                  ;; 04:495f $21 $6e $df
    ld   C, [HL]                                       ;; 04:4962 $4e
    inc  HL                                            ;; 04:4963 $23
    ld   B, [HL]                                       ;; 04:4964 $46
    ld   A, B                                          ;; 04:4965 $78
    or   A, C                                          ;; 04:4966 $b1
    jr   Z, .jr_04_496f                                ;; 04:4967 $28 $06
    ld   DE, rNR31                                     ;; 04:4969 $11 $1b $ff
    call call_04_498b_Audio_StepSfxTrack               ;; 04:496c $cd $8b $49
.jr_04_496f:
    ld   HL, wDF48_Audio_Ch4_Flags                     ;; 04:496f $21 $48 $df
    ld   A, L                                          ;; 04:4972 $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 04:4973 $ea $74 $df
    ld   A, H                                          ;; 04:4976 $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 04:4977 $ea $75 $df
    ld   HL, wDF71_Audio_Ch4_SfxPtrLo                  ;; 04:497a $21 $71 $df
    ld   C, [HL]                                       ;; 04:497d $4e
    inc  HL                                            ;; 04:497e $23
    ld   B, [HL]                                       ;; 04:497f $46
    ld   A, B                                          ;; 04:4980 $78
    or   A, C                                          ;; 04:4981 $b1
    jr   Z, .jr_04_498a                                ;; 04:4982 $28 $06
    ld   DE, rNR41                                     ;; 04:4984 $11 $20 $ff
    call call_04_498b_Audio_StepSfxTrack               ;; 04:4987 $cd $8b $49
.jr_04_498a:
    ret                                                ;; 04:498a $c9

call_04_498b_Audio_StepSfxTrack:
; One tick of one sound effect. BC is where the track is, DE is the channel's NRx1
; register, and HL points at the slot's pointer low byte - so HL+1 is the high byte and
; HL+2 the timer.
;
; rNR51 is forced to wDF7A_Audio_SfxPanning every tick, not just at the start, because
; the music's panning commands are still running underneath and would otherwise pan the
; effect away.
;
; A row is AUDIO_SFX_ROW_SIZE bytes and goes straight to the hardware, no instruments and
; no envelopes: frames, NRx1, NRx2, NRx4, NRx3. NRx4 is written before NRx3, so the note
; is triggered with the previous row's low byte and only then given its own - audible as
; a very short chirp at the start of each row, and part of how these effects sound.
;
; AUDIO_SFX_END frees the channel: the pointer is zeroed and, if the music still has
; AUDIO_CHF_RUNNING there, AUDIO_CHF_ENABLED goes back on and the song is audible again
; from wherever it has got to. AUDIO_SFX_LOOP takes a two-byte address and jumps
    ld   A, [wDF7A_Audio_SfxPanning]                   ;; 04:498b $fa $7a $df
    ldh  [rNR51], A                                    ;; 04:498e $e0 $25
    inc  HL                                            ;; 04:4990 $23
    dec  [HL]                                          ;; 04:4991 $35
    jr   Z, .jr_04_4995                                ;; 04:4992 $28 $01
    ret                                                ;; 04:4994 $c9
.jr_04_4995:
    ld   A, [BC]                                       ;; 04:4995 $0a
    cp   A, AUDIO_SFX_END                              ;; 04:4996 $fe $ff
    jr   Z, .jr_04_49b5                                ;; 04:4998 $28 $1b
    cp   A, AUDIO_SFX_LOOP                             ;; 04:499a $fe $fe
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
    ld   HL, wDF74_Audio_SfxOwnerChannelPtrLo          ;; 04:49bb $21 $74 $df
    ld   C, [HL]                                       ;; 04:49be $4e
    inc  HL                                            ;; 04:49bf $23
    ld   B, [HL]                                       ;; 04:49c0 $46
    ld   A, [BC]                                       ;; 04:49c1 $0a
    and  A, AUDIO_CHF_RUNNING                          ;; 04:49c2 $e6 $02
    jp   Z, .jp_04_49cb                                ;; 04:49c4 $ca $cb $49
    ld   A, [BC]                                       ;; 04:49c7 $0a
    or   A, AUDIO_CHF_ENABLED                          ;; 04:49c8 $f6 $01
    ld   [BC], A                                       ;; 04:49ca $02
.jp_04_49cb:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 04:49cb $fa $79 $df
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

data_04_49dd_InitialWaveRam:
; The wave pattern Audio_ResetDriver loads once at boot: eight bytes of $AA -
; alternating maximum and minimum samples - then eight of silence, which is a square
; wave at half duty. Nothing ever replaces it, so every wave-channel note in the game
; is this shape. gex2 has AUDIO_CMD_LOAD_WAVE and swaps the pattern per track
    db   $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa        ;; 04:49dd
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 04:49e5

data_04_49ed_SfxTrackPointers:
; One entry per sound-effect track. Audio_StartSfxTrack indexes this directly;
; data_04_4a59_SfxTrackIds is what maps an SFX_* id onto these
    dw   audio_04_541a_SfxTrack00                      ;; 04:49ed  ; track $00
    dw   audio_04_5421_SfxTrack01                      ;; 04:49ef  ; track $01
    dw   audio_04_5428_SfxTrack02                      ;; 04:49f1  ; track $02
    dw   audio_04_542f_SfxTrack03                      ;; 04:49f3  ; track $03
    dw   audio_04_4ad5_SfxTrack04                      ;; 04:49f5  ; track $04
    dw   audio_04_4ade_SfxTrack05                      ;; 04:49f7  ; track $05
    dw   audio_04_4afa_SfxTrack06                      ;; 04:49f9  ; track $06
    dw   audio_04_4aec_SfxTrack07                      ;; 04:49fb  ; track $07
    dw   audio_04_4b35_SfxTrack08                      ;; 04:49fd  ; track $08
    dw   audio_04_4b8e_SfxTrack09                      ;; 04:49ff  ; track $09
    dw   audio_04_4bce_SfxTrack0A                      ;; 04:4a01  ; track $0A
    dw   audio_04_4c31_SfxTrack0B                      ;; 04:4a03  ; track $0B
    dw   audio_04_4c94_SfxTrack0C                      ;; 04:4a05  ; track $0C
    dw   audio_04_4ccf_SfxTrack0D                      ;; 04:4a07  ; track $0D
    dw   audio_04_4cfb_SfxTrack0E                      ;; 04:4a09  ; track $0E
    dw   audio_04_4d09_SfxTrack0F                      ;; 04:4a0b  ; track $0F
    dw   audio_04_4d3f_SfxTrack10                      ;; 04:4a0d  ; track $10
    dw   audio_04_4d66_SfxTrack11                      ;; 04:4a0f  ; track $11
    dw   audio_04_4db3_SfxTrack12                      ;; 04:4a11  ; track $12
    dw   audio_04_4d97_SfxTrack13                      ;; 04:4a13  ; track $13
    dw   audio_04_4da0_SfxTrack14                      ;; 04:4a15  ; track $14
    dw   audio_04_4f15_SfxTrack15                      ;; 04:4a17  ; track $15
    dw   audio_04_4f50_SfxTrack16                      ;; 04:4a19  ; track $16
    dw   audio_04_4f8b_SfxTrack17                      ;; 04:4a1b  ; track $17
    dw   audio_04_4fc1_SfxTrack18                      ;; 04:4a1d  ; track $18
    dw   audio_04_4fca_SfxTrack19                      ;; 04:4a1f  ; track $19
    dw   audio_04_4fd3_SfxTrack1A                      ;; 04:4a21  ; track $1A
    dw   audio_04_5056_SfxTrack1B                      ;; 04:4a23  ; track $1B
    dw   audio_04_5040_SfxTrack1C                      ;; 04:4a25  ; track $1C
    dw   audio_04_5064_SfxTrack1D                      ;; 04:4a27  ; track $1D
    dw   audio_04_509f_SfxTrack1E                      ;; 04:4a29  ; track $1E
    dw   audio_04_50d5_SfxTrack1F                      ;; 04:4a2b  ; track $1F
    dw   audio_04_5119_SfxTrack20                      ;; 04:4a2d  ; track $20
    dw   audio_04_50de_SfxTrack21                      ;; 04:4a2f  ; track $21
    dw   audio_04_513a_SfxTrack22                      ;; 04:4a31  ; track $22
    dw   audio_04_5122_SfxTrack23                      ;; 04:4a33  ; track $23
    dw   audio_04_5148_SfxTrack24                      ;; 04:4a35  ; track $24
    dw   audio_04_51ba_SfxTrack25                      ;; 04:4a37  ; track $25
    dw   audio_04_51c3_SfxTrack26                      ;; 04:4a39  ; track $26
    dw   audio_04_51d1_SfxTrack27                      ;; 04:4a3b  ; track $27
    dw   audio_04_5202_SfxTrack28                      ;; 04:4a3d  ; track $28
    dw   audio_04_5210_SfxTrack29                      ;; 04:4a3f  ; track $29
    dw   audio_04_5232_SfxTrack2A                      ;; 04:4a41  ; track $2A
    dw   audio_04_5240_SfxTrack2B                      ;; 04:4a43  ; track $2B
    dw   audio_04_524e_SfxTrack2C                      ;; 04:4a45  ; track $2C
    dw   audio_04_5270_SfxTrack2D                      ;; 04:4a47  ; track $2D
    dw   audio_04_5279_SfxTrack2E                      ;; 04:4a49  ; track $2E
    dw   audio_04_5296_SfxTrack2F                      ;; 04:4a4b  ; track $2F
    dw   audio_04_52a4_SfxTrack30                      ;; 04:4a4d  ; track $30
    dw   audio_04_532f_SfxTrack31                      ;; 04:4a4f  ; track $31
    dw   audio_04_533d_SfxTrack32                      ;; 04:4a51  ; track $32
    dw   audio_04_534b_SfxTrack33                      ;; 04:4a53  ; track $33
    dw   audio_04_53d6_SfxTrack34                      ;; 04:4a55  ; track $34
    dw   audio_04_53df_SfxTrack35                      ;; 04:4a57  ; track $35

data_04_4a59_SfxTrackIds:
; AUDIO_SFX_TRACKS_PER_ID track ids per SFX_* id - the tracks Audio_StartSfx
; launches together - padded with AUDIO_SFX_TRACK_NONE. There are only 31 rows, so
; an SFX_* id above $1E reads whatever follows the table
    sfx_tracks $00, $01, $02, $03                      ;; 04:4a59  ; SFX_EMPTY
    sfx_tracks $04, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a5d  ; SFX_MENU_SCROLL
    sfx_tracks $05, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a61  ; SFX_ITEM_PICKUP
    sfx_tracks $07, $06, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a65  ; SFX_FLY_TV
    sfx_tracks $08, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a69  ; SFX_GEX_TAIL_SPIN
    sfx_tracks $09, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a6d  ; SFX_UNK05
    sfx_tracks $0A, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a71  ; SFX_GEX_JUMP
    sfx_tracks $0B, $0C, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a75  ; SFX_GEX_DOUBLE_JUMP
    sfx_tracks $0D, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a79  ; SFX_UNK08
    sfx_tracks $0E, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a7d  ; SFX_UNK09
    sfx_tracks $0F, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a81  ; SFX_PLAYER_DAMAGED
    sfx_tracks $10, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a85  ; SFX_UNK0B
    sfx_tracks $11, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a89  ; SFX_UNK0C
    sfx_tracks $12, $13, $14, AUDIO_SFX_TRACK_NONE     ;; 04:4a8d  ; SFX_UNK0D
    sfx_tracks $15, $16, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a91  ; SFX_GEX_SPAWN
    sfx_tracks $17, $18, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a95  ; SFX_ENEMY_DAMAGED
    sfx_tracks $19, $1A, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a99  ; SFX_ENEMY_KILLED
    sfx_tracks $1B, $1C, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4a9d  ; SFX_UNK11
    sfx_tracks $1D, $1E, $1F, AUDIO_SFX_TRACK_NONE     ;; 04:4aa1  ; SFX_UNK12
    sfx_tracks $20, $21, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4aa5  ; SFX_METEOR
    sfx_tracks $22, $23, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4aa9  ; SFX_CANNON
    sfx_tracks $24, $25, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4aad  ; SFX_BRAIN_OF_OZ
    sfx_tracks $26, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4ab1  ; SFX_UNK16
    sfx_tracks $27, $28, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4ab5  ; SFX_UNK17
    sfx_tracks $29, $2A, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4ab9  ; SFX_DOOR1
    sfx_tracks $2B, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4abd  ; SFX_SMALL_BANG
    sfx_tracks $2C, $2D, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4ac1  ; SFX_LOUD_BANG
    sfx_tracks $2E, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4ac5  ; SFX_DOOR2
    sfx_tracks $2F, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 04:4ac9  ; SFX_BOMB
    sfx_tracks $30, $31, $32, AUDIO_SFX_TRACK_NONE     ;; 04:4acd  ; SFX_UNK1D
    sfx_tracks $33, $34, $35, AUDIO_SFX_TRACK_NONE     ;; 04:4ad1  ; SFX_REMOTE

audio_04_4ad5_SfxTrack04:
; sfx track $04
    sfx_channel 1                                      ;; 04:4ad5  ; pulse B
    sfx_row $23, $80, $84, $87, $CF                    ;; 04:4ad6
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4adb

audio_04_4ade_SfxTrack05:
; sfx track $05
    sfx_channel 1                                      ;; 04:4ade  ; pulse B
    sfx_row $02, $80, $C1, $87, $8A                    ;; 04:4adf
    sfx_row $0A, $80, $C1, $87, $A8                    ;; 04:4ae4
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4ae9

audio_04_4aec_SfxTrack07:
; sfx track $07
    sfx_channel 3                                      ;; 04:4aec  ; noise
    sfx_row $02, $00, $F0, $80, $62                    ;; 04:4aed
    sfx_row $23, $00, $A3, $80, $47                    ;; 04:4af2
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4af7

audio_04_4afa_SfxTrack06:
; sfx track $06
    sfx_channel 1                                      ;; 04:4afa  ; pulse B
    sfx_row $02, $80, $F0, $80, $9D                    ;; 04:4afb
    sfx_row $02, $80, $70, $87, $D9                    ;; 04:4b00
    sfx_row $03, $80, $60, $87, $C5                    ;; 04:4b05
    sfx_row $02, $80, $50, $87, $E6                    ;; 04:4b0a
    sfx_row $01, $80, $40, $87, $D4                    ;; 04:4b0f
    sfx_row $05, $80, $40, $87, $E8                    ;; 04:4b14
    sfx_row $03, $80, $30, $87, $ED                    ;; 04:4b19
    sfx_row $01, $80, $30, $87, $DD                    ;; 04:4b1e
    sfx_row $06, $80, $20, $87, $F1                    ;; 04:4b23
    sfx_row $04, $80, $20, $87, $E3                    ;; 04:4b28
    sfx_row $04, $80, $10, $87, $D7                    ;; 04:4b2d
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4b32

audio_04_4b35_SfxTrack08:
; sfx track $08
    sfx_channel 3                                      ;; 04:4b35  ; noise
    sfx_row $01, $00, $20, $80, $47                    ;; 04:4b36
    sfx_row $01, $00, $30, $80, $46                    ;; 04:4b3b
    sfx_row $01, $00, $40, $80, $45                    ;; 04:4b40
    sfx_row $01, $00, $50, $80, $44                    ;; 04:4b45
    sfx_row $02, $00, $60, $80, $43                    ;; 04:4b4a
    sfx_row $02, $00, $70, $80, $42                    ;; 04:4b4f
    sfx_row $02, $00, $80, $80, $35                    ;; 04:4b54
    sfx_row $02, $00, $80, $80, $34                    ;; 04:4b59
    sfx_row $02, $00, $80, $80, $33                    ;; 04:4b5e
    sfx_row $02, $00, $00, $00, $00                    ;; 04:4b63
    sfx_row $02, $00, $F0, $80, $24                    ;; 04:4b68
    sfx_row $02, $00, $70, $80, $23                    ;; 04:4b6d
    sfx_row $02, $00, $50, $80, $24                    ;; 04:4b72
    sfx_row $02, $00, $40, $80, $24                    ;; 04:4b77
    sfx_row $02, $00, $30, $80, $24                    ;; 04:4b7c
    sfx_row $03, $00, $20, $80, $24                    ;; 04:4b81
    sfx_row $03, $00, $10, $80, $24                    ;; 04:4b86
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4b8b

audio_04_4b8e_SfxTrack09:
; sfx track $09
    sfx_channel 3                                      ;; 04:4b8e  ; noise
    sfx_row $02, $00, $50, $80, $06                    ;; 04:4b8f
    sfx_row $02, $00, $60, $80, $14                    ;; 04:4b94
    sfx_row $02, $00, $70, $80, $21                    ;; 04:4b99
    sfx_row $02, $00, $80, $80, $23                    ;; 04:4b9e
    sfx_row $02, $00, $90, $80, $24                    ;; 04:4ba3
    sfx_row $02, $00, $A0, $80, $32                    ;; 04:4ba8
    sfx_row $02, $00, $B0, $80, $33                    ;; 04:4bad
    sfx_row $02, $00, $C0, $80, $34                    ;; 04:4bb2
    sfx_row $01, $00, $00, $00, $00                    ;; 04:4bb7
    sfx_row $02, $00, $F0, $80, $44                    ;; 04:4bbc
    sfx_row $01, $00, $00, $00, $00                    ;; 04:4bc1
    sfx_row $02, $00, $D0, $80, $47                    ;; 04:4bc6
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4bcb

audio_04_4bce_SfxTrack0A:
; sfx track $0A
    sfx_channel 1                                      ;; 04:4bce  ; pulse B
    sfx_row $04, $80, $F0, $84, $50                    ;; 04:4bcf
    sfx_row $01, $80, $F0, $84, $64                    ;; 04:4bd4
    sfx_row $01, $80, $F0, $84, $78                    ;; 04:4bd9
    sfx_row $01, $80, $F0, $84, $8C                    ;; 04:4bde
    sfx_row $01, $80, $F0, $84, $A0                    ;; 04:4be3
    sfx_row $01, $80, $E0, $84, $B4                    ;; 04:4be8
    sfx_row $01, $80, $D0, $84, $C8                    ;; 04:4bed
    sfx_row $01, $80, $C0, $84, $D2                    ;; 04:4bf2
    sfx_row $01, $80, $80, $84, $DC                    ;; 04:4bf7
    sfx_row $01, $80, $80, $84, $E6                    ;; 04:4bfc
    sfx_row $01, $80, $80, $84, $F0                    ;; 04:4c01
    sfx_row $01, $80, $70, $84, $FA                    ;; 04:4c06
    sfx_row $01, $80, $50, $85, $05                    ;; 04:4c0b
    sfx_row $02, $80, $30, $85, $0F                    ;; 04:4c10
    sfx_row $02, $80, $20, $85, $19                    ;; 04:4c15
    sfx_row $03, $80, $20, $85, $23                    ;; 04:4c1a
    sfx_row $03, $80, $10, $85, $2D                    ;; 04:4c1f
    sfx_row $03, $80, $10, $85, $37                    ;; 04:4c24
    sfx_row $03, $80, $10, $85, $41                    ;; 04:4c29
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4c2e

audio_04_4c31_SfxTrack0B:
; sfx track $0B
    sfx_channel 1                                      ;; 04:4c31  ; pulse B
    sfx_row $04, $80, $F0, $82, $00                    ;; 04:4c32
    sfx_row $02, $80, $F0, $82, $1E                    ;; 04:4c37
    sfx_row $02, $80, $F0, $82, $3C                    ;; 04:4c3c
    sfx_row $02, $80, $F0, $82, $5A                    ;; 04:4c41
    sfx_row $02, $80, $F0, $82, $78                    ;; 04:4c46
    sfx_row $02, $80, $E0, $82, $96                    ;; 04:4c4b
    sfx_row $01, $80, $D0, $82, $B4                    ;; 04:4c50
    sfx_row $01, $80, $C0, $82, $D2                    ;; 04:4c55
    sfx_row $01, $80, $80, $82, $F0                    ;; 04:4c5a
    sfx_row $01, $80, $80, $83, $0F                    ;; 04:4c5f
    sfx_row $01, $80, $80, $82, $2D                    ;; 04:4c64
    sfx_row $01, $80, $70, $82, $4B                    ;; 04:4c69
    sfx_row $01, $80, $50, $82, $69                    ;; 04:4c6e
    sfx_row $02, $80, $30, $82, $87                    ;; 04:4c73
    sfx_row $02, $80, $20, $82, $A5                    ;; 04:4c78
    sfx_row $03, $80, $20, $82, $C3                    ;; 04:4c7d
    sfx_row $03, $80, $10, $82, $E1                    ;; 04:4c82
    sfx_row $03, $80, $10, $82, $FA                    ;; 04:4c87
    sfx_row $03, $80, $10, $82, $FF                    ;; 04:4c8c
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4c91

audio_04_4c94_SfxTrack0C:
; sfx track $0C
    sfx_channel 0                                      ;; 04:4c94  ; pulse A
    sfx_row $04, $80, $F0, $82, $01                    ;; 04:4c95
    sfx_row $02, $80, $F0, $82, $1F                    ;; 04:4c9a
    sfx_row $02, $80, $F0, $82, $3D                    ;; 04:4c9f
    sfx_row $02, $80, $F0, $82, $5B                    ;; 04:4ca4
    sfx_row $02, $80, $F0, $82, $79                    ;; 04:4ca9
    sfx_row $02, $80, $E0, $82, $97                    ;; 04:4cae
    sfx_row $01, $80, $D0, $82, $B5                    ;; 04:4cb3
    sfx_row $01, $80, $C0, $82, $D3                    ;; 04:4cb8
    sfx_row $01, $80, $80, $82, $F1                    ;; 04:4cbd
    sfx_row $01, $80, $80, $83, $10                    ;; 04:4cc2
    sfx_row $01, $80, $80, $82, $2E                    ;; 04:4cc7
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4ccc

audio_04_4ccf_SfxTrack0D:
; sfx track $0D
    sfx_channel 3                                      ;; 04:4ccf  ; noise
    sfx_row $04, $00, $F0, $80, $61                    ;; 04:4cd0
    sfx_row $01, $00, $70, $80, $35                    ;; 04:4cd5
    sfx_row $01, $00, $60, $80, $47                    ;; 04:4cda
    sfx_row $01, $00, $50, $80, $34                    ;; 04:4cdf
    sfx_row $01, $00, $40, $80, $46                    ;; 04:4ce4
    sfx_row $01, $00, $30, $80, $33                    ;; 04:4ce9
    sfx_row $01, $00, $20, $80, $45                    ;; 04:4cee
    sfx_row $02, $00, $10, $80, $32                    ;; 04:4cf3
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4cf8

audio_04_4cfb_SfxTrack0E:
; sfx track $0E
    sfx_channel 3                                      ;; 04:4cfb  ; noise
    sfx_row $14, $00, $1A, $80, $22                    ;; 04:4cfc
    sfx_row $3C, $00, $F4, $80, $22                    ;; 04:4d01
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4d06

audio_04_4d09_SfxTrack0F:
; sfx track $0F
    sfx_channel 1                                      ;; 04:4d09  ; pulse B
    sfx_row $02, $80, $F0, $85, $C8                    ;; 04:4d0a
    sfx_row $01, $80, $F0, $85, $B4                    ;; 04:4d0f
    sfx_row $01, $80, $F0, $85, $A0                    ;; 04:4d14
    sfx_row $01, $80, $F0, $85, $8C                    ;; 04:4d19
    sfx_row $01, $80, $E0, $85, $78                    ;; 04:4d1e
    sfx_row $01, $80, $E0, $85, $64                    ;; 04:4d23
    sfx_row $01, $80, $D0, $85, $50                    ;; 04:4d28
    sfx_row $01, $80, $D0, $85, $3C                    ;; 04:4d2d
    sfx_row $01, $80, $C0, $85, $28                    ;; 04:4d32
    sfx_row $01, $80, $C0, $85, $14                    ;; 04:4d37
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4d3c

audio_04_4d3f_SfxTrack10:
; sfx track $10
    sfx_channel 1                                      ;; 04:4d3f  ; pulse B
    sfx_row $02, $80, $F0, $87, $8C                    ;; 04:4d40
    sfx_row $01, $80, $E0, $87, $87                    ;; 04:4d45
    sfx_row $01, $80, $C0, $87, $82                    ;; 04:4d4a
    sfx_row $01, $80, $A0, $87, $7D                    ;; 04:4d4f
    sfx_row $01, $80, $80, $87, $78                    ;; 04:4d54
    sfx_row $01, $80, $50, $87, $73                    ;; 04:4d59
    sfx_row $01, $80, $30, $87, $6E                    ;; 04:4d5e
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4d63

audio_04_4d66_SfxTrack11:
; sfx track $11
    sfx_channel 3                                      ;; 04:4d66  ; noise
    sfx_row $01, $00, $C0, $80, $44                    ;; 04:4d67
    sfx_row $01, $00, $D0, $80, $43                    ;; 04:4d6c
    sfx_row $01, $00, $E0, $80, $44                    ;; 04:4d71
    sfx_row $01, $00, $F0, $80, $43                    ;; 04:4d76
    sfx_row $01, $00, $F0, $80, $44                    ;; 04:4d7b
    sfx_row $01, $00, $F0, $80, $43                    ;; 04:4d80
    sfx_row $02, $00, $00, $00, $00                    ;; 04:4d85
    sfx_row $01, $00, $F0, $80, $23                    ;; 04:4d8a
    sfx_row $06, $00, $51, $80, $23                    ;; 04:4d8f
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4d94

audio_04_4d97_SfxTrack13:
; sfx track $13
    sfx_channel 0                                      ;; 04:4d97  ; pulse A
    sfx_row $46, $80, $F4, $82, $23                    ;; 04:4d98
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4d9d

audio_04_4da0_SfxTrack14:
; sfx track $14
    sfx_channel 2                                      ;; 04:4da0  ; wave
    sfx_row $1E, $00, $20, $84, $E5                    ;; 04:4da1
    sfx_row $1E, $00, $40, $84, $E5                    ;; 04:4da6
    sfx_row $0A, $00, $60, $84, $E5                    ;; 04:4dab
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4db0

audio_04_4db3_SfxTrack12:
; sfx track $12
    sfx_channel 1                                      ;; 04:4db3  ; pulse B
    sfx_row $01, $80, $40, $87, $DC                    ;; 04:4db4
    sfx_row $01, $80, $50, $87, $DD                    ;; 04:4db9
    sfx_row $01, $80, $60, $87, $DE                    ;; 04:4dbe
    sfx_row $01, $80, $70, $87, $DF                    ;; 04:4dc3
    sfx_row $01, $80, $80, $87, $E0                    ;; 04:4dc8
    sfx_row $01, $80, $50, $87, $D9                    ;; 04:4dcd
    sfx_row $01, $80, $60, $87, $DA                    ;; 04:4dd2
    sfx_row $01, $80, $70, $87, $DB                    ;; 04:4dd7
    sfx_row $01, $80, $80, $87, $DC                    ;; 04:4ddc
    sfx_row $01, $80, $90, $87, $DD                    ;; 04:4de1
    sfx_row $01, $80, $30, $87, $D6                    ;; 04:4de6
    sfx_row $01, $80, $40, $87, $D7                    ;; 04:4deb
    sfx_row $01, $80, $50, $87, $D8                    ;; 04:4df0
    sfx_row $01, $80, $60, $87, $D9                    ;; 04:4df5
    sfx_row $01, $80, $70, $87, $DA                    ;; 04:4dfa
    sfx_row $01, $80, $40, $87, $DF                    ;; 04:4dff
    sfx_row $01, $80, $50, $87, $E0                    ;; 04:4e04
    sfx_row $01, $80, $60, $87, $E1                    ;; 04:4e09
    sfx_row $01, $80, $70, $87, $E2                    ;; 04:4e0e
    sfx_row $01, $80, $80, $87, $E3                    ;; 04:4e13
    sfx_row $01, $80, $20, $87, $D4                    ;; 04:4e18
    sfx_row $01, $80, $30, $87, $D5                    ;; 04:4e1d
    sfx_row $01, $80, $40, $87, $D6                    ;; 04:4e22
    sfx_row $01, $80, $50, $87, $D7                    ;; 04:4e27
    sfx_row $01, $80, $60, $87, $D8                    ;; 04:4e2c
    sfx_row $01, $80, $40, $87, $DA                    ;; 04:4e31
    sfx_row $01, $80, $50, $87, $DB                    ;; 04:4e36
    sfx_row $01, $80, $60, $87, $DC                    ;; 04:4e3b
    sfx_row $01, $80, $70, $87, $DD                    ;; 04:4e40
    sfx_row $01, $80, $80, $87, $DE                    ;; 04:4e45
    sfx_row $01, $80, $50, $87, $DF                    ;; 04:4e4a
    sfx_row $01, $80, $60, $87, $E0                    ;; 04:4e4f
    sfx_row $01, $80, $70, $87, $E1                    ;; 04:4e54
    sfx_row $01, $80, $80, $87, $E2                    ;; 04:4e59
    sfx_row $01, $80, $90, $87, $E3                    ;; 04:4e5e
    sfx_row $01, $80, $20, $87, $D3                    ;; 04:4e63
    sfx_row $01, $80, $30, $87, $D4                    ;; 04:4e68
    sfx_row $01, $80, $40, $87, $D5                    ;; 04:4e6d
    sfx_row $01, $80, $50, $87, $D6                    ;; 04:4e72
    sfx_row $01, $80, $60, $87, $D7                    ;; 04:4e77
    sfx_row $01, $80, $20, $87, $D9                    ;; 04:4e7c
    sfx_row $01, $80, $30, $87, $DA                    ;; 04:4e81
    sfx_row $01, $80, $40, $87, $DB                    ;; 04:4e86
    sfx_row $01, $80, $50, $87, $DC                    ;; 04:4e8b
    sfx_row $01, $80, $70, $87, $DD                    ;; 04:4e90
    sfx_row $01, $80, $20, $87, $D0                    ;; 04:4e95
    sfx_row $01, $80, $30, $87, $D1                    ;; 04:4e9a
    sfx_row $01, $80, $40, $87, $D2                    ;; 04:4e9f
    sfx_row $01, $80, $50, $87, $D3                    ;; 04:4ea4
    sfx_row $01, $80, $60, $87, $D4                    ;; 04:4ea9
    sfx_row $01, $80, $40, $87, $D4                    ;; 04:4eae
    sfx_row $01, $80, $50, $87, $D5                    ;; 04:4eb3
    sfx_row $01, $80, $60, $87, $D6                    ;; 04:4eb8
    sfx_row $01, $80, $50, $87, $D7                    ;; 04:4ebd
    sfx_row $01, $80, $40, $87, $D8                    ;; 04:4ec2
    sfx_row $01, $80, $20, $87, $CD                    ;; 04:4ec7
    sfx_row $01, $80, $30, $87, $CE                    ;; 04:4ecc
    sfx_row $01, $80, $40, $87, $CF                    ;; 04:4ed1
    sfx_row $01, $80, $50, $87, $D0                    ;; 04:4ed6
    sfx_row $01, $80, $60, $87, $D1                    ;; 04:4edb
    sfx_row $01, $80, $20, $87, $D9                    ;; 04:4ee0
    sfx_row $01, $80, $30, $87, $DA                    ;; 04:4ee5
    sfx_row $01, $80, $40, $87, $DB                    ;; 04:4eea
    sfx_row $01, $80, $50, $87, $DC                    ;; 04:4eef
    sfx_row $01, $80, $60, $87, $DD                    ;; 04:4ef4
    sfx_row $01, $80, $20, $87, $C8                    ;; 04:4ef9
    sfx_row $01, $80, $30, $87, $C9                    ;; 04:4efe
    sfx_row $01, $80, $40, $87, $CA                    ;; 04:4f03
    sfx_row $01, $80, $50, $87, $CB                    ;; 04:4f08
    sfx_row $01, $80, $40, $87, $CC                    ;; 04:4f0d
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4f12

audio_04_4f15_SfxTrack15:
; sfx track $15
    sfx_channel 0                                      ;; 04:4f15  ; pulse A
    sfx_row $05, $40, $10, $82, $37                    ;; 04:4f16
    sfx_row $05, $40, $20, $82, $3C                    ;; 04:4f1b
    sfx_row $05, $40, $40, $82, $41                    ;; 04:4f20
    sfx_row $05, $40, $80, $82, $46                    ;; 04:4f25
    sfx_row $05, $40, $A0, $82, $4B                    ;; 04:4f2a
    sfx_row $05, $40, $B0, $82, $50                    ;; 04:4f2f
    sfx_row $05, $40, $C0, $82, $55                    ;; 04:4f34
    sfx_row $05, $40, $D0, $82, $5A                    ;; 04:4f39
    sfx_row $05, $40, $E0, $82, $5F                    ;; 04:4f3e
    sfx_row $05, $40, $F0, $82, $64                    ;; 04:4f43
    sfx_row $5A, $40, $F7, $82, $69                    ;; 04:4f48
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4f4d

audio_04_4f50_SfxTrack16:
; sfx track $16
    sfx_channel 1                                      ;; 04:4f50  ; pulse B
    sfx_row $05, $40, $10, $82, $3A                    ;; 04:4f51
    sfx_row $05, $40, $20, $82, $3F                    ;; 04:4f56
    sfx_row $05, $40, $40, $82, $44                    ;; 04:4f5b
    sfx_row $05, $40, $80, $82, $49                    ;; 04:4f60
    sfx_row $05, $40, $A0, $82, $4E                    ;; 04:4f65
    sfx_row $05, $40, $B0, $82, $53                    ;; 04:4f6a
    sfx_row $05, $40, $C0, $82, $58                    ;; 04:4f6f
    sfx_row $05, $40, $D0, $82, $5D                    ;; 04:4f74
    sfx_row $05, $40, $E0, $82, $62                    ;; 04:4f79
    sfx_row $05, $40, $F0, $82, $67                    ;; 04:4f7e
    sfx_row $5A, $40, $F7, $82, $6C                    ;; 04:4f83
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4f88

audio_04_4f8b_SfxTrack17:
; sfx track $17
    sfx_channel 1                                      ;; 04:4f8b  ; pulse B
    sfx_row $02, $80, $F0, $85, $C8                    ;; 04:4f8c
    sfx_row $01, $80, $A0, $85, $BE                    ;; 04:4f91
    sfx_row $01, $80, $90, $85, $B4                    ;; 04:4f96
    sfx_row $01, $80, $80, $85, $AA                    ;; 04:4f9b
    sfx_row $01, $80, $70, $85, $A0                    ;; 04:4fa0
    sfx_row $01, $80, $60, $85, $96                    ;; 04:4fa5
    sfx_row $01, $80, $50, $85, $8C                    ;; 04:4faa
    sfx_row $01, $80, $40, $85, $82                    ;; 04:4faf
    sfx_row $01, $80, $30, $85, $78                    ;; 04:4fb4
    sfx_row $01, $80, $20, $85, $64                    ;; 04:4fb9
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4fbe

audio_04_4fc1_SfxTrack18:
; sfx track $18
    sfx_channel 3                                      ;; 04:4fc1  ; noise
    sfx_row $0C, $00, $72, $80, $47                    ;; 04:4fc2
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:4fc7

audio_04_4fca_SfxTrack19:
; sfx track $19
    sfx_channel 0                                      ;; 04:4fca  ; pulse A
    sfx_row $0A, $00, $00, $00, $00                    ;; 04:4fcb
    sfx_loop audio_04_4fd4_SfxTrackPart                ;; 04:4fd0

audio_04_4fd3_SfxTrack1A:
; sfx track $1A
    sfx_channel 1                                      ;; 04:4fd3  ; pulse B

audio_04_4fd4_SfxTrackPart:
    sfx_channel 5                                      ;; 04:4fd4  ; pulse B
    sfx_row $80, $F0, $85, $C8, $05                    ;; 04:4fd5
    sfx_row $80, $F0, $85, $96, $05                    ;; 04:4fda
    sfx_row $80, $E0, $85, $64, $05                    ;; 04:4fdf
    sfx_row $80, $E0, $85, $32, $05                    ;; 04:4fe4
    sfx_row $80, $D0, $84, $FA, $05                    ;; 04:4fe9
    sfx_row $80, $D0, $84, $C8, $05                    ;; 04:4fee
    sfx_row $80, $C0, $84, $96, $05                    ;; 04:4ff3
    sfx_row $80, $B0, $84, $64, $05                    ;; 04:4ff8
    sfx_row $80, $A0, $84, $32, $05                    ;; 04:4ffd
    sfx_row $80, $A0, $84, $00, $05                    ;; 04:5002
    sfx_row $80, $90, $83, $C8, $05                    ;; 04:5007
    sfx_row $80, $80, $83, $96, $05                    ;; 04:500c
    sfx_row $80, $70, $83, $64, $05                    ;; 04:5011
    sfx_row $80, $70, $83, $32, $05                    ;; 04:5016
    sfx_row $80, $60, $83, $00, $05                    ;; 04:501b
    sfx_row $80, $50, $82, $C8, $05                    ;; 04:5020
    sfx_row $80, $40, $82, $96, $05                    ;; 04:5025
    sfx_row $80, $30, $82, $64, $05                    ;; 04:502a
    sfx_row $80, $20, $82, $32, $05                    ;; 04:502f
    sfx_row $80, $20, $82, $00, $05                    ;; 04:5034
    sfx_row $80, $10, $81, $C8, $FE                    ;; 04:5039
    db   $1b, $54                                      ;; 04:503e

audio_04_5040_SfxTrack1C:
; sfx track $1C
    sfx_channel 3                                      ;; 04:5040  ; noise
    sfx_row $01, $00, $F0, $80, $23                    ;; 04:5041
    sfx_row $01, $00, $20, $80, $23                    ;; 04:5046
    sfx_row $03, $00, $F1, $80, $61                    ;; 04:504b
    sfx_row $28, $00, $65, $80, $61                    ;; 04:5050
    sfx_end                                            ;; 04:5055

audio_04_5056_SfxTrack1B:
; sfx track $1B
    sfx_channel 1                                      ;; 04:5056  ; pulse B
    sfx_row $02, $80, $F0, $80, $9D                    ;; 04:5057
    sfx_row $02, $80, $44, $80, $9D                    ;; 04:505c
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5061

audio_04_5064_SfxTrack1D:
; sfx track $1D
    sfx_channel 0                                      ;; 04:5064  ; pulse A
    sfx_row $01, $00, $00, $00, $00                    ;; 04:5065
    sfx_row $02, $40, $10, $80, $64                    ;; 04:506a
    sfx_row $02, $00, $10, $81, $C8                    ;; 04:506f
    sfx_row $02, $40, $20, $80, $64                    ;; 04:5074
    sfx_row $02, $00, $40, $81, $C8                    ;; 04:5079
    sfx_row $02, $40, $60, $80, $64                    ;; 04:507e
    sfx_row $02, $00, $80, $81, $C8                    ;; 04:5083
    sfx_row $02, $40, $A0, $80, $64                    ;; 04:5088
    sfx_row $02, $00, $C0, $81, $C8                    ;; 04:508d
    sfx_row $02, $40, $E0, $80, $64                    ;; 04:5092
    sfx_row $14, $00, $F5, $80, $64                    ;; 04:5097
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:509c

audio_04_509f_SfxTrack1E:
; sfx track $1E
    sfx_channel 1                                      ;; 04:509f  ; pulse B
    sfx_row $02, $40, $10, $80, $67                    ;; 04:50a0
    sfx_row $02, $00, $10, $81, $CB                    ;; 04:50a5
    sfx_row $02, $40, $20, $80, $67                    ;; 04:50aa
    sfx_row $02, $00, $40, $81, $CB                    ;; 04:50af
    sfx_row $02, $40, $60, $80, $67                    ;; 04:50b4
    sfx_row $02, $00, $80, $81, $CB                    ;; 04:50b9
    sfx_row $02, $40, $A0, $80, $67                    ;; 04:50be
    sfx_row $02, $00, $C0, $81, $CB                    ;; 04:50c3
    sfx_row $02, $40, $E0, $80, $67                    ;; 04:50c8
    sfx_row $14, $00, $F5, $80, $67                    ;; 04:50cd
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:50d2

audio_04_50d5_SfxTrack1F:
; sfx track $1F
    sfx_channel 3                                      ;; 04:50d5  ; noise
    sfx_row $08, $00, $F1, $80, $64                    ;; 04:50d6
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:50db

audio_04_50de_SfxTrack21:
; sfx track $21
    sfx_channel 3                                      ;; 04:50de  ; noise
    sfx_row $08, $00, $F0, $80, $62                    ;; 04:50df
    sfx_row $14, $00, $A5, $80, $61                    ;; 04:50e4
    sfx_row $07, $00, $10, $80, $5F                    ;; 04:50e9
    sfx_row $06, $00, $20, $80, $60                    ;; 04:50ee
    sfx_row $05, $00, $30, $80, $5F                    ;; 04:50f3
    sfx_row $05, $00, $40, $80, $46                    ;; 04:50f8
    sfx_row $05, $00, $50, $80, $45                    ;; 04:50fd
    sfx_row $04, $00, $60, $80, $44                    ;; 04:5102
    sfx_row $05, $00, $70, $80, $43                    ;; 04:5107
    sfx_row $06, $00, $80, $80, $42                    ;; 04:510c
    sfx_row $50, $00, $97, $80, $41                    ;; 04:5111
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5116

audio_04_5119_SfxTrack20:
; sfx track $20
    sfx_channel 1                                      ;; 04:5119  ; pulse B
    sfx_row $28, $80, $F5, $80, $9D                    ;; 04:511a
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:511f

audio_04_5122_SfxTrack23:
; sfx track $23
    sfx_channel 3                                      ;; 04:5122  ; noise
    sfx_row $01, $00, $F0, $80, $44                    ;; 04:5123
    sfx_row $01, $00, $20, $80, $44                    ;; 04:5128
    sfx_row $03, $00, $F1, $80, $47                    ;; 04:512d
    sfx_row $50, $00, $67, $80, $46                    ;; 04:5132
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5137

audio_04_513a_SfxTrack22:
; sfx track $22
    sfx_channel 1                                      ;; 04:513a  ; pulse B
    sfx_row $02, $80, $F0, $80, $9D                    ;; 04:513b
    sfx_row $02, $80, $45, $80, $9D                    ;; 04:5140
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5145

audio_04_5148_SfxTrack24:
; sfx track $24
    sfx_channel 1                                      ;; 04:5148  ; pulse B
    sfx_row $02, $80, $F0, $80, $64                    ;; 04:5149
    sfx_row $01, $80, $E0, $87, $D7                    ;; 04:514e
    sfx_row $02, $80, $D0, $87, $C8                    ;; 04:5153
    sfx_row $03, $80, $C0, $87, $B4                    ;; 04:5158
    sfx_row $02, $80, $B0, $87, $DF                    ;; 04:515d
    sfx_row $02, $80, $A0, $87, $D4                    ;; 04:5162
    sfx_row $01, $80, $90, $87, $E6                    ;; 04:5167
    sfx_row $01, $80, $80, $87, $CC                    ;; 04:516c
    sfx_row $02, $80, $70, $87, $BA                    ;; 04:5171
    sfx_row $02, $80, $60, $87, $DF                    ;; 04:5176
    sfx_row $01, $80, $50, $87, $C3                    ;; 04:517b
    sfx_row $02, $80, $40, $87, $E3                    ;; 04:5180
    sfx_row $02, $80, $30, $87, $C3                    ;; 04:5185
    sfx_row $01, $80, $20, $87, $E3                    ;; 04:518a
    sfx_row $03, $80, $20, $87, $D1                    ;; 04:518f
    sfx_row $02, $80, $20, $87, $DE                    ;; 04:5194
    sfx_row $03, $80, $20, $87, $D7                    ;; 04:5199
    sfx_row $02, $80, $10, $87, $D4                    ;; 04:519e
    sfx_row $03, $80, $10, $87, $E2                    ;; 04:51a3
    sfx_row $01, $80, $10, $87, $D5                    ;; 04:51a8
    sfx_row $03, $80, $10, $87, $E5                    ;; 04:51ad
    sfx_row $02, $80, $10, $87, $D3                    ;; 04:51b2
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:51b7

audio_04_51ba_SfxTrack25:
; sfx track $25
    sfx_channel 0                                      ;; 04:51ba  ; pulse A
    sfx_row $02, $80, $F0, $80, $64                    ;; 04:51bb
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:51c0

audio_04_51c3_SfxTrack26:
; sfx track $26
    sfx_channel 3                                      ;; 04:51c3  ; noise
    sfx_row $01, $3C, $F0, $C0, $23                    ;; 04:51c4
    sfx_row $01, $3C, $F0, $C0, $21                    ;; 04:51c9
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:51ce

audio_04_51d1_SfxTrack27:
; sfx track $27
    sfx_channel 3                                      ;; 04:51d1  ; noise
    sfx_row $01, $00, $F0, $80, $45                    ;; 04:51d2
    sfx_row $0A, $00, $92, $80, $62                    ;; 04:51d7
    sfx_row $03, $00, $00, $00, $00                    ;; 04:51dc
    sfx_row $01, $00, $F0, $80, $44                    ;; 04:51e1
    sfx_row $01, $00, $40, $80, $44                    ;; 04:51e6
    sfx_row $01, $00, $20, $80, $44                    ;; 04:51eb
    sfx_row $01, $00, $20, $80, $44                    ;; 04:51f0
    sfx_row $01, $00, $10, $80, $44                    ;; 04:51f5
    sfx_row $06, $00, $10, $80, $62                    ;; 04:51fa
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:51ff

audio_04_5202_SfxTrack28:
; sfx track $28
    sfx_channel 1                                      ;; 04:5202  ; pulse B
    sfx_row $01, $00, $00, $00, $00                    ;; 04:5203
    sfx_row $0A, $00, $0A, $87, $E3                    ;; 04:5208
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:520d

audio_04_5210_SfxTrack29:
; sfx track $29
    sfx_channel 3                                      ;; 04:5210  ; noise
    sfx_row $08, $00, $0B, $80, $61                    ;; 04:5211
    sfx_row $01, $00, $F0, $80, $44                    ;; 04:5216
    sfx_row $0A, $00, $52, $80, $61                    ;; 04:521b
    sfx_row $03, $00, $00, $00, $00                    ;; 04:5220
    sfx_row $14, $00, $0B, $80, $14                    ;; 04:5225
    sfx_row $28, $00, $67, $80, $14                    ;; 04:522a
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:522f

audio_04_5232_SfxTrack2A:
; sfx track $2A
    sfx_channel 1                                      ;; 04:5232  ; pulse B
    sfx_row $09, $00, $00, $00, $00                    ;; 04:5233
    sfx_row $0A, $00, $0A, $87, $E3                    ;; 04:5238
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:523d

audio_04_5240_SfxTrack2B:
; sfx track $2B
    sfx_channel 3                                      ;; 04:5240  ; noise
    sfx_row $03, $00, $F1, $80, $63                    ;; 04:5241
    sfx_row $1E, $00, $A3, $80, $62                    ;; 04:5246
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:524b

audio_04_524e_SfxTrack2C:
; sfx track $2C
    sfx_channel 3                                      ;; 04:524e  ; noise
    sfx_row $05, $00, $F2, $80, $62                    ;; 04:524f
    sfx_row $05, $00, $F2, $80, $64                    ;; 04:5254
    sfx_row $05, $00, $F2, $80, $63                    ;; 04:5259
    sfx_row $05, $00, $F2, $80, $62                    ;; 04:525e
    sfx_row $64, $00, $F7, $80, $62                    ;; 04:5263
    sfx_row $14, $00, $10, $80, $62                    ;; 04:5268
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:526d

audio_04_5270_SfxTrack2D:
; sfx track $2D
    sfx_channel 1                                      ;; 04:5270  ; pulse B
    sfx_row $03, $80, $F0, $81, $C8                    ;; 04:5271
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5276

audio_04_5279_SfxTrack2E:
; sfx track $2E
    sfx_channel 1                                      ;; 04:5279  ; pulse B
    sfx_row $01, $80, $50, $87, $C5                    ;; 04:527a
    sfx_row $01, $80, $A0, $87, $8A                    ;; 04:527f
    sfx_row $01, $80, $50, $87, $C5                    ;; 04:5284
    sfx_row $01, $80, $A0, $87, $8A                    ;; 04:5289
    sfx_row $32, $80, $A6, $87, $BE                    ;; 04:528e
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5293

audio_04_5296_SfxTrack2F:
; sfx track $2F
    sfx_channel 1                                      ;; 04:5296  ; pulse B
    sfx_row $02, $BC, $F0, $C7, $C5                    ;; 04:5297
    sfx_row $03, $BC, $F0, $C7, $8A                    ;; 04:529c
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:52a1

audio_04_52a4_SfxTrack30:
; sfx track $30
    sfx_channel 3                                      ;; 04:52a4  ; noise
    sfx_row $05, $00, $20, $80, $66                    ;; 04:52a5
    sfx_row $05, $00, $30, $80, $65                    ;; 04:52aa
    sfx_row $05, $00, $40, $80, $64                    ;; 04:52af
    sfx_row $05, $00, $50, $80, $63                    ;; 04:52b4
    sfx_row $05, $00, $60, $80, $62                    ;; 04:52b9
    sfx_row $05, $00, $70, $80, $61                    ;; 04:52be
    sfx_row $05, $00, $80, $80, $60                    ;; 04:52c3
    sfx_row $05, $00, $90, $80, $47                    ;; 04:52c8
    sfx_row $05, $00, $A0, $80, $46                    ;; 04:52cd
    sfx_row $05, $00, $B0, $80, $45                    ;; 04:52d2
    sfx_row $05, $00, $C0, $80, $44                    ;; 04:52d7
    sfx_row $05, $00, $D0, $80, $43                    ;; 04:52dc
    sfx_row $05, $00, $E0, $80, $42                    ;; 04:52e1
    sfx_row $05, $00, $F0, $80, $35                    ;; 04:52e6
    sfx_row $05, $00, $E0, $80, $34                    ;; 04:52eb
    sfx_row $05, $00, $D0, $80, $33                    ;; 04:52f0
    sfx_row $05, $00, $C0, $80, $32                    ;; 04:52f5
    sfx_row $05, $00, $B0, $80, $24                    ;; 04:52fa
    sfx_row $05, $00, $A0, $80, $23                    ;; 04:52ff
    sfx_row $05, $00, $90, $80, $22                    ;; 04:5304
    sfx_row $06, $00, $80, $80, $21                    ;; 04:5309
    sfx_row $07, $00, $70, $80, $20                    ;; 04:530e
    sfx_row $07, $00, $60, $80, $14                    ;; 04:5313
    sfx_row $07, $00, $40, $80, $07                    ;; 04:5318
    sfx_row $07, $00, $30, $80, $06                    ;; 04:531d
    sfx_row $07, $00, $20, $80, $05                    ;; 04:5322
    sfx_row $07, $00, $10, $80, $04                    ;; 04:5327
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:532c

audio_04_532f_SfxTrack31:
; sfx track $31
    sfx_channel 1                                      ;; 04:532f  ; pulse B
    sfx_row $14, $00, $0A, $80, $32                    ;; 04:5330
    sfx_row $5A, $00, $F7, $80, $32                    ;; 04:5335
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:533a

audio_04_533d_SfxTrack32:
; sfx track $32
    sfx_channel 0                                      ;; 04:533d  ; pulse A
    sfx_row $14, $00, $0A, $80, $37                    ;; 04:533e
    sfx_row $5A, $00, $F7, $80, $37                    ;; 04:5343
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5348

audio_04_534b_SfxTrack33:
; sfx track $33
    sfx_channel 0                                      ;; 04:534b  ; pulse A

audio_04_534c_SfxTrackPart:
    sfx_channel 8                                      ;; 04:534c  ; pulse A
    sfx_row $80, $C1, $87, $8A, $08                    ;; 04:534d
    sfx_row $80, $C1, $87, $A3, $08                    ;; 04:5352
    sfx_row $80, $C1, $87, $B1, $08                    ;; 04:5357
    sfx_row $80, $C1, $87, $BE, $08                    ;; 04:535c
    sfx_row $80, $C1, $87, $A8, $08                    ;; 04:5361
    sfx_row $80, $C1, $87, $97, $08                    ;; 04:5366
    sfx_row $80, $C1, $87, $6C, $08                    ;; 04:536b
    sfx_row $80, $C1, $87, $8A, $08                    ;; 04:5370
    sfx_row $80, $C1, $87, $9D, $08                    ;; 04:5375
    sfx_row $80, $C1, $87, $97, $08                    ;; 04:537a
    sfx_row $80, $C1, $87, $83, $08                    ;; 04:537f
    sfx_row $80, $C1, $87, $63, $08                    ;; 04:5384
    sfx_row $80, $C1, $87, $4F, $08                    ;; 04:5389
    sfx_row $80, $C1, $87, $74, $08                    ;; 04:538e
    sfx_row $80, $C1, $87, $8A, $08                    ;; 04:5393
    sfx_row $80, $C1, $87, $7C, $08                    ;; 04:5398
    sfx_row $80, $C1, $87, $63, $08                    ;; 04:539d
    sfx_row $80, $C1, $87, $3A, $08                    ;; 04:53a2
    sfx_row $80, $C1, $87, $2E, $08                    ;; 04:53a7
    sfx_row $80, $C1, $87, $4F, $08                    ;; 04:53ac
    sfx_row $80, $C1, $87, $74, $08                    ;; 04:53b1
    sfx_row $80, $C1, $87, $63, $08                    ;; 04:53b6
    sfx_row $80, $C1, $87, $45, $08                    ;; 04:53bb
    sfx_row $80, $C1, $87, $14, $18                    ;; 04:53c0
    sfx_row $80, $C5, $84, $4F, $18                    ;; 04:53c5
    sfx_row $80, $C5, $86, $28, $3C                    ;; 04:53ca
    sfx_row $80, $C7, $87, $14, $FE                    ;; 04:53cf
    db   $1b, $54                                      ;; 04:53d4

audio_04_53d6_SfxTrack34:
; sfx track $34
    sfx_channel 1                                      ;; 04:53d6  ; pulse B
    sfx_row $08, $00, $00, $00, $00                    ;; 04:53d7
    sfx_loop audio_04_534c_SfxTrackPart                ;; 04:53dc

audio_04_53df_SfxTrack35:
; sfx track $35
    sfx_channel 2                                      ;; 04:53df  ; wave
    sfx_row $18, $00, $20, $86, $28                    ;; 04:53e0
    sfx_row $18, $00, $20, $85, $EE                    ;; 04:53e5
    sfx_row $18, $00, $20, $85, $AD                    ;; 04:53ea
    sfx_row $18, $00, $20, $85, $89                    ;; 04:53ef
    sfx_row $18, $00, $20, $85, $3C                    ;; 04:53f4
    sfx_row $18, $00, $20, $84, $E5                    ;; 04:53f9
    sfx_row $18, $00, $20, $84, $B6                    ;; 04:53fe
    sfx_row $18, $00, $20, $84, $4F                    ;; 04:5403
    sfx_row $18, $00, $20, $80, $9D                    ;; 04:5408
    sfx_row $18, $00, $40, $84, $4F                    ;; 04:540d
    sfx_row $30, $00, $60, $86, $28                    ;; 04:5412
    sfx_loop audio_04_541b_SfxTrackPart                ;; 04:5417

audio_04_541a_SfxTrack00:
; sfx track $00
    sfx_channel 0                                      ;; 04:541a  ; pulse A

audio_04_541b_SfxTrackPart:
    sfx_channel 1                                      ;; 04:541b  ; pulse B
    sfx_row $00, $00, $00, $00, $FF                    ;; 04:541c

audio_04_5421_SfxTrack01:
; sfx track $01
    sfx_channel 1                                      ;; 04:5421  ; pulse B
    sfx_row $01, $00, $00, $00, $00                    ;; 04:5422
    sfx_end                                            ;; 04:5427

audio_04_5428_SfxTrack02:
; sfx track $02
    sfx_channel 2                                      ;; 04:5428  ; wave
    sfx_row $01, $00, $00, $00, $00                    ;; 04:5429
    sfx_end                                            ;; 04:542e

audio_04_542f_SfxTrack03:
; sfx track $03
    sfx_channel 3                                      ;; 04:542f  ; noise
    sfx_row $01, $00, $00, $00, $00                    ;; 04:5430
    sfx_end                                            ;; 04:5435

audio_04_5436_Song_Empty_Ch1:
; SONG_EMPTY (song $00) channel 1
    audio_panning $FF                                  ;; 04:5436
    audio_tempo $FF                                    ;; 04:5438
    audio_note $24, $00, $0                            ;; 04:543a  ; C#5
    audio_marker $01                                   ;; 04:543c
    audio_end                                          ;; 04:543e

audio_04_543f_Song_Empty_Ch2:
; SONG_EMPTY (song $00) channel 2
    audio_note $24, $00, $0                            ;; 04:543f  ; C#5
    audio_end                                          ;; 04:5441

audio_04_5442_Song_Empty_Ch3:
; SONG_EMPTY (song $00) channel 3
    audio_note $24, $00, $0                            ;; 04:5442  ; C#5
    audio_end                                          ;; 04:5444

audio_04_5445_Song_Empty_Ch4:
; SONG_EMPTY (song $00) channel 4
    audio_note $24, $00, $0                            ;; 04:5445  ; C#5
    audio_end                                          ;; 04:5447

audio_04_5448_Song_Unk01_Ch1:
; SONG_UNK01 (song $01) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 04:5448
    audio_tempo $AD                                    ;; 04:544a
    audio_call $00, $00, 4                             ;; 04:544c
    audio_call $09, $E5, 1                             ;; 04:5450
    audio_call $0A, $E5, 1                             ;; 04:5454
    audio_call $0B, $E5, 1                             ;; 04:5458
    audio_call $0C, $E5, 1                             ;; 04:545c
    audio_call $0D, $E5, 1                             ;; 04:5460
    audio_call $0A, $E5, 1                             ;; 04:5464
    audio_call $0B, $E5, 1                             ;; 04:5468
    audio_marker $01                                   ;; 04:546c
    audio_goto audio_04_5448_Song_Unk01_Ch1            ;; 04:546e

audio_04_5471_Song_Unk01_Ch2:
; SONG_UNK01 (song $01) channel 2
; AUDIO_CMD_GOTO target
    audio_call $0E, $FD, 2                             ;; 04:5471
    audio_call $0F, $FD, 2                             ;; 04:5475
    audio_call $10, $FD, 1                             ;; 04:5479
    audio_call $11, $FD, 1                             ;; 04:547d
    audio_call $10, $FD, 1                             ;; 04:5481
    audio_call $12, $FD, 1                             ;; 04:5485
    audio_call $13, $FD, 2                             ;; 04:5489
    audio_call $14, $FD, 2                             ;; 04:548d
    audio_call $15, $FD, 1                             ;; 04:5491
    audio_call $0F, $FD, 2                             ;; 04:5495
    audio_call $10, $FD, 1                             ;; 04:5499
    audio_call $11, $FD, 1                             ;; 04:549d
    audio_call $10, $FD, 1                             ;; 04:54a1
    audio_call $12, $FD, 1                             ;; 04:54a5
    audio_goto audio_04_5471_Song_Unk01_Ch2            ;; 04:54a9

audio_04_54ac_Song_Unk01_Ch3:
; SONG_UNK01 (song $01) channel 3
; AUDIO_CMD_GOTO target
    audio_call $02, $F1, 1                             ;; 04:54ac
    audio_call $03, $F1, 1                             ;; 04:54b0
    audio_call $02, $F1, 1                             ;; 04:54b4
    audio_call $03, $F1, 1                             ;; 04:54b8
    audio_call $04, $F1, 2                             ;; 04:54bc
    audio_call $05, $F1, 1                             ;; 04:54c0
    audio_call $06, $F1, 1                             ;; 04:54c4
    audio_call $07, $F1, 1                             ;; 04:54c8
    audio_call $04, $F1, 2                             ;; 04:54cc
    audio_call $05, $F1, 1                             ;; 04:54d0
    audio_goto audio_04_54ac_Song_Unk01_Ch3            ;; 04:54d4

audio_04_54d7_Song_Unk01_Ch4:
; SONG_UNK01 (song $01) channel 4
; AUDIO_CMD_GOTO target
    audio_call $01, $00, 20                            ;; 04:54d7
    audio_call $08, $00, 1                             ;; 04:54db
    audio_call $01, $00, 8                             ;; 04:54df
    audio_goto audio_04_54d7_Song_Unk01_Ch4            ;; 04:54e3

audio_04_54e6_Pattern00:
; pattern $00
    audio_note $24, $00, $A                            ;; 04:54e6  ; C#5
    audio_end_pattern                                  ;; 04:54e8

audio_04_54e9_Pattern0E:
; pattern $0E
    audio_note $24, $13, $4                            ;; 04:54e9  ; C#5
    audio_note $24, $13, $2                            ;; 04:54eb  ; C#5
    audio_note $24, $13, $2                            ;; 04:54ed  ; C#5
    audio_note $24, $13, $4                            ;; 04:54ef  ; C#5
    audio_note $24, $13, $2                            ;; 04:54f1  ; C#5
    audio_note $24, $13, $4                            ;; 04:54f3  ; C#5
    audio_note $24, $13, $4                            ;; 04:54f5  ; C#5
    audio_note $24, $13, $2                            ;; 04:54f7  ; C#5
    audio_note $24, $13, $4                            ;; 04:54f9  ; C#5
    audio_note $24, $13, $4                            ;; 04:54fb  ; C#5
    audio_note $1F, $14, $4                            ;; 04:54fd  ; G#4
    audio_note $1F, $14, $2                            ;; 04:54ff  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5501  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5503  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5505  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5507  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5509  ; G#4
    audio_note $1F, $14, $2                            ;; 04:550b  ; G#4
    audio_note $1F, $14, $4                            ;; 04:550d  ; G#4
    audio_note $1F, $14, $4                            ;; 04:550f  ; G#4
    audio_note $1D, $14, $4                            ;; 04:5511  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5513  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5515  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5517  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5519  ; F#4
    audio_note $1D, $14, $4                            ;; 04:551b  ; F#4
    audio_note $1D, $14, $4                            ;; 04:551d  ; F#4
    audio_note $1D, $14, $2                            ;; 04:551f  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5521  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5523  ; F#4
    audio_note $1F, $14, $4                            ;; 04:5525  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5527  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5529  ; G#4
    audio_note $1F, $14, $4                            ;; 04:552b  ; G#4
    audio_note $1F, $14, $2                            ;; 04:552d  ; G#4
    audio_note $1F, $14, $4                            ;; 04:552f  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5531  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5533  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5535  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5537  ; G#4
    audio_end_pattern                                  ;; 04:5539

audio_04_553a_Pattern0F:
; pattern $0F
    audio_note $1F, $14, $4                            ;; 04:553a  ; G#4
    audio_note $1F, $14, $2                            ;; 04:553c  ; G#4
    audio_note $1F, $14, $2                            ;; 04:553e  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5540  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5542  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5544  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5546  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5548  ; G#4
    audio_note $1F, $14, $4                            ;; 04:554a  ; G#4
    audio_note $1F, $14, $4                            ;; 04:554c  ; G#4
    audio_note $18, $15, $4                            ;; 04:554e  ; C#4
    audio_note $18, $15, $2                            ;; 04:5550  ; C#4
    audio_note $18, $15, $2                            ;; 04:5552  ; C#4
    audio_note $18, $15, $4                            ;; 04:5554  ; C#4
    audio_note $18, $15, $2                            ;; 04:5556  ; C#4
    audio_note $18, $15, $4                            ;; 04:5558  ; C#4
    audio_note $18, $15, $4                            ;; 04:555a  ; C#4
    audio_note $18, $15, $2                            ;; 04:555c  ; C#4
    audio_note $18, $15, $4                            ;; 04:555e  ; C#4
    audio_note $18, $15, $4                            ;; 04:5560  ; C#4
    audio_note $1F, $13, $4                            ;; 04:5562  ; G#4
    audio_note $1F, $13, $2                            ;; 04:5564  ; G#4
    audio_note $1F, $13, $2                            ;; 04:5566  ; G#4
    audio_note $1F, $13, $4                            ;; 04:5568  ; G#4
    audio_note $1F, $13, $2                            ;; 04:556a  ; G#4
    audio_note $1F, $13, $4                            ;; 04:556c  ; G#4
    audio_note $1F, $13, $4                            ;; 04:556e  ; G#4
    audio_note $1F, $13, $2                            ;; 04:5570  ; G#4
    audio_note $1F, $13, $4                            ;; 04:5572  ; G#4
    audio_note $1F, $13, $4                            ;; 04:5574  ; G#4
    audio_note $18, $15, $4                            ;; 04:5576  ; C#4
    audio_note $18, $15, $2                            ;; 04:5578  ; C#4
    audio_note $18, $15, $2                            ;; 04:557a  ; C#4
    audio_note $18, $15, $4                            ;; 04:557c  ; C#4
    audio_note $18, $15, $2                            ;; 04:557e  ; C#4
    audio_note $18, $15, $4                            ;; 04:5580  ; C#4
    audio_note $18, $15, $4                            ;; 04:5582  ; C#4
    audio_note $18, $15, $2                            ;; 04:5584  ; C#4
    audio_note $18, $15, $4                            ;; 04:5586  ; C#4
    audio_note $18, $15, $4                            ;; 04:5588  ; C#4
    audio_end_pattern                                  ;; 04:558a

audio_04_558b_Pattern10:
; pattern $10
    audio_note $1D, $14, $4                            ;; 04:558b  ; F#4
    audio_note $1D, $14, $2                            ;; 04:558d  ; F#4
    audio_note $1D, $14, $2                            ;; 04:558f  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5591  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5593  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5595  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5597  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5599  ; F#4
    audio_note $1D, $14, $4                            ;; 04:559b  ; F#4
    audio_note $1D, $14, $4                            ;; 04:559d  ; F#4
    audio_note $18, $15, $4                            ;; 04:559f  ; C#4
    audio_note $18, $15, $2                            ;; 04:55a1  ; C#4
    audio_note $18, $15, $2                            ;; 04:55a3  ; C#4
    audio_note $18, $15, $4                            ;; 04:55a5  ; C#4
    audio_note $18, $15, $2                            ;; 04:55a7  ; C#4
    audio_note $18, $15, $4                            ;; 04:55a9  ; C#4
    audio_note $18, $15, $4                            ;; 04:55ab  ; C#4
    audio_note $18, $15, $2                            ;; 04:55ad  ; C#4
    audio_note $18, $15, $4                            ;; 04:55af  ; C#4
    audio_note $18, $15, $4                            ;; 04:55b1  ; C#4
    audio_note $1F, $13, $4                            ;; 04:55b3  ; G#4
    audio_note $1F, $13, $2                            ;; 04:55b5  ; G#4
    audio_note $1F, $13, $2                            ;; 04:55b7  ; G#4
    audio_note $1F, $13, $4                            ;; 04:55b9  ; G#4
    audio_note $1F, $13, $2                            ;; 04:55bb  ; G#4
    audio_note $1F, $13, $4                            ;; 04:55bd  ; G#4
    audio_note $1F, $13, $4                            ;; 04:55bf  ; G#4
    audio_note $1F, $13, $2                            ;; 04:55c1  ; G#4
    audio_note $1F, $13, $4                            ;; 04:55c3  ; G#4
    audio_note $1F, $13, $4                            ;; 04:55c5  ; G#4
    audio_end_pattern                                  ;; 04:55c7

audio_04_55c8_Pattern11:
; pattern $11
    audio_note $18, $15, $4                            ;; 04:55c8  ; C#4
    audio_note $18, $15, $2                            ;; 04:55ca  ; C#4
    audio_note $18, $15, $2                            ;; 04:55cc  ; C#4
    audio_note $18, $15, $4                            ;; 04:55ce  ; C#4
    audio_note $18, $15, $2                            ;; 04:55d0  ; C#4
    audio_note $18, $15, $4                            ;; 04:55d2  ; C#4
    audio_note $18, $15, $4                            ;; 04:55d4  ; C#4
    audio_note $18, $15, $2                            ;; 04:55d6  ; C#4
    audio_note $18, $15, $4                            ;; 04:55d8  ; C#4
    audio_note $18, $15, $4                            ;; 04:55da  ; C#4
    audio_end_pattern                                  ;; 04:55dc

audio_04_55dd_Pattern12:
; pattern $12
    audio_note $18, $15, $4                            ;; 04:55dd  ; C#4
    audio_note $18, $15, $4                            ;; 04:55df  ; C#4
    audio_note $1D, $14, $2                            ;; 04:55e1  ; F#4
    audio_note $1D, $14, $4                            ;; 04:55e3  ; F#4
    audio_note $18, $15, $4                            ;; 04:55e5  ; C#4
    audio_note $18, $15, $4                            ;; 04:55e7  ; C#4
    audio_note $18, $15, $2                            ;; 04:55e9  ; C#4
    audio_note $18, $15, $4                            ;; 04:55eb  ; C#4
    audio_note $18, $15, $4                            ;; 04:55ed  ; C#4
    audio_end_pattern                                  ;; 04:55ef

audio_04_55f0_Pattern13:
; pattern $13
    audio_note $1D, $14, $4                            ;; 04:55f0  ; F#4
    audio_note $1D, $14, $2                            ;; 04:55f2  ; F#4
    audio_note $1D, $14, $2                            ;; 04:55f4  ; F#4
    audio_note $1D, $14, $4                            ;; 04:55f6  ; F#4
    audio_note $1D, $14, $2                            ;; 04:55f8  ; F#4
    audio_note $1D, $14, $4                            ;; 04:55fa  ; F#4
    audio_note $1D, $14, $4                            ;; 04:55fc  ; F#4
    audio_note $1D, $14, $2                            ;; 04:55fe  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5600  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5602  ; F#4
    audio_note $18, $15, $4                            ;; 04:5604  ; C#4
    audio_note $18, $15, $2                            ;; 04:5606  ; C#4
    audio_note $18, $15, $2                            ;; 04:5608  ; C#4
    audio_note $18, $15, $4                            ;; 04:560a  ; C#4
    audio_note $18, $15, $2                            ;; 04:560c  ; C#4
    audio_note $18, $15, $4                            ;; 04:560e  ; C#4
    audio_note $18, $15, $4                            ;; 04:5610  ; C#4
    audio_note $18, $15, $2                            ;; 04:5612  ; C#4
    audio_note $18, $15, $4                            ;; 04:5614  ; C#4
    audio_note $18, $15, $4                            ;; 04:5616  ; C#4
    audio_note $18, $15, $4                            ;; 04:5618  ; C#4
    audio_note $18, $15, $2                            ;; 04:561a  ; C#4
    audio_note $18, $15, $2                            ;; 04:561c  ; C#4
    audio_note $18, $15, $4                            ;; 04:561e  ; C#4
    audio_note $18, $15, $2                            ;; 04:5620  ; C#4
    audio_note $18, $15, $4                            ;; 04:5622  ; C#4
    audio_note $18, $15, $4                            ;; 04:5624  ; C#4
    audio_note $18, $15, $2                            ;; 04:5626  ; C#4
    audio_note $18, $15, $4                            ;; 04:5628  ; C#4
    audio_note $18, $15, $4                            ;; 04:562a  ; C#4
    audio_note $1D, $14, $4                            ;; 04:562c  ; F#4
    audio_note $1D, $14, $2                            ;; 04:562e  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5630  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5632  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5634  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5636  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5638  ; F#4
    audio_note $1D, $14, $2                            ;; 04:563a  ; F#4
    audio_note $1D, $14, $4                            ;; 04:563c  ; F#4
    audio_note $1D, $14, $4                            ;; 04:563e  ; F#4
    audio_end_pattern                                  ;; 04:5640

audio_04_5641_Pattern14:
; pattern $14
    audio_note $22, $13, $4                            ;; 04:5641  ; B4
    audio_note $22, $13, $2                            ;; 04:5643  ; B4
    audio_note $22, $13, $2                            ;; 04:5645  ; B4
    audio_note $22, $13, $4                            ;; 04:5647  ; B4
    audio_note $22, $13, $2                            ;; 04:5649  ; B4
    audio_note $22, $13, $4                            ;; 04:564b  ; B4
    audio_note $22, $13, $4                            ;; 04:564d  ; B4
    audio_note $22, $13, $2                            ;; 04:564f  ; B4
    audio_note $22, $13, $4                            ;; 04:5651  ; B4
    audio_note $22, $13, $4                            ;; 04:5653  ; B4
    audio_note $1D, $14, $4                            ;; 04:5655  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5657  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5659  ; F#4
    audio_note $1D, $14, $4                            ;; 04:565b  ; F#4
    audio_note $1D, $14, $2                            ;; 04:565d  ; F#4
    audio_note $1D, $14, $4                            ;; 04:565f  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5661  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5663  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5665  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5667  ; F#4
    audio_note $18, $15, $4                            ;; 04:5669  ; C#4
    audio_note $18, $15, $2                            ;; 04:566b  ; C#4
    audio_note $18, $15, $2                            ;; 04:566d  ; C#4
    audio_note $18, $15, $4                            ;; 04:566f  ; C#4
    audio_note $18, $15, $2                            ;; 04:5671  ; C#4
    audio_note $18, $15, $4                            ;; 04:5673  ; C#4
    audio_note $18, $15, $4                            ;; 04:5675  ; C#4
    audio_note $18, $15, $2                            ;; 04:5677  ; C#4
    audio_note $18, $15, $4                            ;; 04:5679  ; C#4
    audio_note $18, $15, $4                            ;; 04:567b  ; C#4
    audio_note $1D, $14, $4                            ;; 04:567d  ; F#4
    audio_note $1D, $14, $2                            ;; 04:567f  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5681  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5683  ; F#4
    audio_note $1D, $14, $2                            ;; 04:5685  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5687  ; F#4
    audio_note $1D, $14, $4                            ;; 04:5689  ; F#4
    audio_note $1D, $14, $2                            ;; 04:568b  ; F#4
    audio_note $1D, $14, $4                            ;; 04:568d  ; F#4
    audio_note $1D, $14, $4                            ;; 04:568f  ; F#4
    audio_end_pattern                                  ;; 04:5691

audio_04_5692_Pattern15:
; pattern $15
    audio_note $1F, $14, $4                            ;; 04:5692  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5694  ; G#4
    audio_note $1F, $14, $2                            ;; 04:5696  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5698  ; G#4
    audio_note $1F, $14, $2                            ;; 04:569a  ; G#4
    audio_note $1F, $14, $4                            ;; 04:569c  ; G#4
    audio_note $1F, $14, $4                            ;; 04:569e  ; G#4
    audio_note $1F, $14, $2                            ;; 04:56a0  ; G#4
    audio_note $1F, $14, $4                            ;; 04:56a2  ; G#4
    audio_note $1F, $14, $4                            ;; 04:56a4  ; G#4
    audio_end_pattern                                  ;; 04:56a6

audio_04_56a7_Pattern01:
; pattern $01
    audio_note $18, $01, $2                            ;; 04:56a7  ; C#4
    audio_note $1E, $03, $2                            ;; 04:56a9  ; G4
    audio_note $19, $05, $2                            ;; 04:56ab  ; D4
    audio_note $18, $01, $2                            ;; 04:56ad  ; C#4
    audio_note $18, $01, $2                            ;; 04:56af  ; C#4
    audio_note $19, $05, $2                            ;; 04:56b1  ; D4
    audio_note $1E, $03, $2                            ;; 04:56b3  ; G4
    audio_note $18, $01, $2                            ;; 04:56b5  ; C#4
    audio_note $18, $01, $2                            ;; 04:56b7  ; C#4
    audio_note $1E, $03, $2                            ;; 04:56b9  ; G4
    audio_note $19, $05, $2                            ;; 04:56bb  ; D4
    audio_note $18, $01, $2                            ;; 04:56bd  ; C#4
    audio_note $18, $01, $2                            ;; 04:56bf  ; C#4
    audio_note $19, $05, $2                            ;; 04:56c1  ; D4
    audio_note $1E, $03, $2                            ;; 04:56c3  ; G4
    audio_note $18, $01, $2                            ;; 04:56c5  ; C#4

audio_04_56c7_Pattern08:
; pattern $08
    audio_note $18, $01, $2                            ;; 04:56c7  ; C#4
    audio_note $1E, $03, $2                            ;; 04:56c9  ; G4
    audio_note $19, $05, $2                            ;; 04:56cb  ; D4
    audio_note $18, $01, $2                            ;; 04:56cd  ; C#4
    audio_note $18, $01, $2                            ;; 04:56cf  ; C#4
    audio_note $19, $05, $2                            ;; 04:56d1  ; D4
    audio_note $1E, $03, $2                            ;; 04:56d3  ; G4
    audio_note $18, $01, $2                            ;; 04:56d5  ; C#4
    audio_note $18, $01, $2                            ;; 04:56d7  ; C#4
    audio_note $1E, $03, $2                            ;; 04:56d9  ; G4
    audio_note $19, $05, $2                            ;; 04:56db  ; D4
    audio_note $18, $01, $2                            ;; 04:56dd  ; C#4
    audio_note $18, $01, $2                            ;; 04:56df  ; C#4
    audio_note $19, $05, $2                            ;; 04:56e1  ; D4
    audio_note $1E, $03, $2                            ;; 04:56e3  ; G4
    audio_note $18, $01, $2                            ;; 04:56e5  ; C#4
    audio_end_pattern                                  ;; 04:56e7

audio_04_56e8_Pattern02:
; pattern $02
    audio_note $24, $11, $5                            ;; 04:56e8  ; C#5
    audio_note $24, $11, $2                            ;; 04:56ea  ; C#5
    audio_note $1F, $11, $5                            ;; 04:56ec  ; G#4
    audio_note $24, $11, $4                            ;; 04:56ee  ; C#5
    audio_note $24, $11, $4                            ;; 04:56f0  ; C#5
    audio_note $24, $11, $2                            ;; 04:56f2  ; C#5
    audio_note $1F, $11, $6                            ;; 04:56f4  ; G#4
    audio_note $24, $11, $5                            ;; 04:56f6  ; C#5
    audio_note $24, $11, $2                            ;; 04:56f8  ; C#5
    audio_note $1F, $11, $5                            ;; 04:56fa  ; G#4
    audio_note $24, $11, $4                            ;; 04:56fc  ; C#5
    audio_note $24, $11, $4                            ;; 04:56fe  ; C#5
    audio_note $24, $11, $2                            ;; 04:5700  ; C#5
    audio_note $1F, $11, $6                            ;; 04:5702  ; G#4
    audio_end_pattern                                  ;; 04:5704

audio_04_5705_Pattern03:
; pattern $03
    audio_note $24, $11, $5                            ;; 04:5705  ; C#5
    audio_note $24, $11, $2                            ;; 04:5707  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5709  ; G#4
    audio_note $24, $11, $4                            ;; 04:570b  ; C#5
    audio_note $24, $11, $4                            ;; 04:570d  ; C#5
    audio_note $24, $11, $2                            ;; 04:570f  ; C#5
    audio_note $1F, $11, $6                            ;; 04:5711  ; G#4
    audio_note $1F, $11, $5                            ;; 04:5713  ; G#4
    audio_note $1F, $11, $2                            ;; 04:5715  ; G#4
    audio_note $26, $11, $5                            ;; 04:5717  ; D#5
    audio_note $1F, $11, $4                            ;; 04:5719  ; G#4
    audio_note $1F, $11, $4                            ;; 04:571b  ; G#4
    audio_note $1F, $11, $2                            ;; 04:571d  ; G#4
    audio_note $26, $11, $6                            ;; 04:571f  ; D#5
    audio_end_pattern                                  ;; 04:5721

audio_04_5722_Pattern04:
; pattern $04
    audio_note $1F, $11, $5                            ;; 04:5722  ; G#4
    audio_note $1F, $11, $2                            ;; 04:5724  ; G#4
    audio_note $26, $11, $5                            ;; 04:5726  ; D#5
    audio_note $1F, $11, $4                            ;; 04:5728  ; G#4
    audio_note $1F, $11, $4                            ;; 04:572a  ; G#4
    audio_note $1F, $11, $2                            ;; 04:572c  ; G#4
    audio_note $21, $11, $4                            ;; 04:572e  ; A#4
    audio_note $23, $11, $4                            ;; 04:5730  ; C5
    audio_note $24, $11, $5                            ;; 04:5732  ; C#5
    audio_note $24, $11, $2                            ;; 04:5734  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5736  ; G#4
    audio_note $24, $11, $4                            ;; 04:5738  ; C#5
    audio_note $24, $11, $4                            ;; 04:573a  ; C#5
    audio_note $24, $11, $2                            ;; 04:573c  ; C#5
    audio_note $23, $11, $4                            ;; 04:573e  ; C5
    audio_note $21, $11, $4                            ;; 04:5740  ; A#4
    audio_note $1F, $11, $6                            ;; 04:5742  ; G#4
    audio_note $26, $11, $5                            ;; 04:5744  ; D#5
    audio_note $1F, $11, $4                            ;; 04:5746  ; G#4
    audio_note $1F, $11, $4                            ;; 04:5748  ; G#4
    audio_note $1F, $11, $2                            ;; 04:574a  ; G#4
    audio_note $21, $11, $4                            ;; 04:574c  ; A#4
    audio_note $23, $11, $4                            ;; 04:574e  ; C5
    audio_note $24, $11, $5                            ;; 04:5750  ; C#5
    audio_note $24, $11, $2                            ;; 04:5752  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5754  ; G#4
    audio_note $24, $11, $4                            ;; 04:5756  ; C#5
    audio_note $24, $11, $4                            ;; 04:5758  ; C#5
    audio_note $24, $11, $2                            ;; 04:575a  ; C#5
    audio_note $24, $11, $2                            ;; 04:575c  ; C#5
    audio_note $23, $11, $2                            ;; 04:575e  ; C5
    audio_note $21, $11, $4                            ;; 04:5760  ; A#4
    audio_end_pattern                                  ;; 04:5762

audio_04_5763_Pattern05:
; pattern $05
    audio_note $1D, $11, $5                            ;; 04:5763  ; F#4
    audio_note $1D, $11, $2                            ;; 04:5765  ; F#4
    audio_note $24, $11, $5                            ;; 04:5767  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5769  ; F#4
    audio_note $1D, $11, $4                            ;; 04:576b  ; F#4
    audio_note $1D, $11, $2                            ;; 04:576d  ; F#4
    audio_note $24, $11, $4                            ;; 04:576f  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5771  ; F#4
    audio_note $24, $11, $5                            ;; 04:5773  ; C#5
    audio_note $24, $11, $2                            ;; 04:5775  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5777  ; G#4
    audio_note $24, $11, $4                            ;; 04:5779  ; C#5
    audio_note $24, $11, $4                            ;; 04:577b  ; C#5
    audio_note $24, $11, $2                            ;; 04:577d  ; C#5
    audio_note $1F, $11, $4                            ;; 04:577f  ; G#4
    audio_note $24, $11, $4                            ;; 04:5781  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5783  ; G#4
    audio_note $1F, $11, $2                            ;; 04:5785  ; G#4
    audio_note $26, $11, $5                            ;; 04:5787  ; D#5
    audio_note $1F, $11, $4                            ;; 04:5789  ; G#4
    audio_note $1F, $11, $4                            ;; 04:578b  ; G#4
    audio_note $1F, $11, $2                            ;; 04:578d  ; G#4
    audio_note $21, $11, $4                            ;; 04:578f  ; A#4
    audio_note $23, $11, $4                            ;; 04:5791  ; C5
    audio_note $24, $11, $5                            ;; 04:5793  ; C#5
    audio_note $24, $11, $2                            ;; 04:5795  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5797  ; G#4
    audio_note $24, $11, $4                            ;; 04:5799  ; C#5
    audio_note $24, $11, $4                            ;; 04:579b  ; C#5
    audio_note $24, $11, $2                            ;; 04:579d  ; C#5
    audio_note $1F, $11, $4                            ;; 04:579f  ; G#4
    audio_note $24, $11, $4                            ;; 04:57a1  ; C#5
    audio_note $1D, $11, $6                            ;; 04:57a3  ; F#4
    audio_note $24, $11, $5                            ;; 04:57a5  ; C#5
    audio_note $1D, $11, $4                            ;; 04:57a7  ; F#4
    audio_note $1D, $11, $4                            ;; 04:57a9  ; F#4
    audio_note $1D, $11, $2                            ;; 04:57ab  ; F#4
    audio_note $24, $11, $4                            ;; 04:57ad  ; C#5
    audio_note $1D, $11, $4                            ;; 04:57af  ; F#4
    audio_note $24, $11, $5                            ;; 04:57b1  ; C#5
    audio_note $24, $11, $2                            ;; 04:57b3  ; C#5
    audio_note $1F, $11, $5                            ;; 04:57b5  ; G#4
    audio_note $24, $11, $4                            ;; 04:57b7  ; C#5
    audio_note $24, $11, $4                            ;; 04:57b9  ; C#5
    audio_note $24, $11, $2                            ;; 04:57bb  ; C#5
    audio_note $1F, $11, $4                            ;; 04:57bd  ; G#4
    audio_note $24, $11, $4                            ;; 04:57bf  ; C#5
    audio_note $1F, $11, $5                            ;; 04:57c1  ; G#4
    audio_note $1F, $11, $2                            ;; 04:57c3  ; G#4
    audio_note $26, $11, $5                            ;; 04:57c5  ; D#5
    audio_note $1F, $11, $4                            ;; 04:57c7  ; G#4
    audio_note $1F, $11, $4                            ;; 04:57c9  ; G#4
    audio_note $1F, $11, $2                            ;; 04:57cb  ; G#4
    audio_note $21, $11, $4                            ;; 04:57cd  ; A#4
    audio_note $23, $11, $4                            ;; 04:57cf  ; C5
    audio_note $24, $11, $4                            ;; 04:57d1  ; C#5
    audio_note $24, $11, $4                            ;; 04:57d3  ; C#5
    audio_note $1D, $11, $2                            ;; 04:57d5  ; F#4
    audio_note $1D, $11, $4                            ;; 04:57d7  ; F#4
    audio_note $24, $11, $6                            ;; 04:57d9  ; C#5
    audio_note $24, $11, $2                            ;; 04:57db  ; C#5
    audio_note $1F, $11, $4                            ;; 04:57dd  ; G#4
    audio_note $24, $11, $4                            ;; 04:57df  ; C#5
    audio_end_pattern                                  ;; 04:57e1

audio_04_57e2_Pattern06:
; pattern $06
    audio_note $1D, $11, $5                            ;; 04:57e2  ; F#4
    audio_note $1D, $11, $2                            ;; 04:57e4  ; F#4
    audio_note $24, $11, $5                            ;; 04:57e6  ; C#5
    audio_note $1D, $11, $4                            ;; 04:57e8  ; F#4
    audio_note $1D, $11, $4                            ;; 04:57ea  ; F#4
    audio_note $1D, $11, $2                            ;; 04:57ec  ; F#4
    audio_note $24, $11, $4                            ;; 04:57ee  ; C#5
    audio_note $1D, $11, $4                            ;; 04:57f0  ; F#4
    audio_note $24, $11, $5                            ;; 04:57f2  ; C#5
    audio_note $24, $11, $2                            ;; 04:57f4  ; C#5
    audio_note $1F, $11, $5                            ;; 04:57f6  ; G#4
    audio_note $24, $11, $4                            ;; 04:57f8  ; C#5
    audio_note $24, $11, $4                            ;; 04:57fa  ; C#5
    audio_note $24, $11, $2                            ;; 04:57fc  ; C#5
    audio_note $1F, $11, $4                            ;; 04:57fe  ; G#4
    audio_note $1F, $11, $4                            ;; 04:5800  ; G#4
    audio_note $24, $11, $5                            ;; 04:5802  ; C#5
    audio_note $24, $11, $2                            ;; 04:5804  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5806  ; G#4
    audio_note $24, $11, $4                            ;; 04:5808  ; C#5
    audio_note $24, $11, $4                            ;; 04:580a  ; C#5
    audio_note $24, $11, $2                            ;; 04:580c  ; C#5
    audio_note $1F, $11, $4                            ;; 04:580e  ; G#4
    audio_note $24, $11, $4                            ;; 04:5810  ; C#5
    audio_note $1D, $11, $5                            ;; 04:5812  ; F#4
    audio_note $1D, $11, $2                            ;; 04:5814  ; F#4
    audio_note $24, $11, $5                            ;; 04:5816  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5818  ; F#4
    audio_note $1D, $11, $4                            ;; 04:581a  ; F#4
    audio_note $1D, $11, $2                            ;; 04:581c  ; F#4
    audio_note $24, $11, $4                            ;; 04:581e  ; C#5
    audio_note $24, $11, $4                            ;; 04:5820  ; C#5
    audio_note $1D, $11, $5                            ;; 04:5822  ; F#4
    audio_note $1D, $11, $2                            ;; 04:5824  ; F#4
    audio_note $24, $11, $5                            ;; 04:5826  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5828  ; F#4
    audio_note $1D, $11, $4                            ;; 04:582a  ; F#4
    audio_note $1D, $11, $2                            ;; 04:582c  ; F#4
    audio_note $24, $11, $4                            ;; 04:582e  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5830  ; F#4
    audio_note $24, $11, $5                            ;; 04:5832  ; C#5
    audio_note $24, $11, $2                            ;; 04:5834  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5836  ; G#4
    audio_note $24, $11, $4                            ;; 04:5838  ; C#5
    audio_note $24, $11, $4                            ;; 04:583a  ; C#5
    audio_note $24, $11, $2                            ;; 04:583c  ; C#5
    audio_note $1F, $11, $4                            ;; 04:583e  ; G#4
    audio_note $1F, $11, $4                            ;; 04:5840  ; G#4
    audio_note $24, $11, $5                            ;; 04:5842  ; C#5
    audio_note $24, $11, $2                            ;; 04:5844  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5846  ; G#4
    audio_note $24, $11, $4                            ;; 04:5848  ; C#5
    audio_note $24, $11, $4                            ;; 04:584a  ; C#5
    audio_note $24, $11, $2                            ;; 04:584c  ; C#5
    audio_note $1F, $11, $4                            ;; 04:584e  ; G#4
    audio_note $24, $11, $4                            ;; 04:5850  ; C#5
    audio_note $1D, $11, $5                            ;; 04:5852  ; F#4
    audio_note $1D, $11, $2                            ;; 04:5854  ; F#4
    audio_note $24, $11, $5                            ;; 04:5856  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5858  ; F#4
    audio_note $1D, $11, $4                            ;; 04:585a  ; F#4
    audio_note $1D, $11, $2                            ;; 04:585c  ; F#4
    audio_note $1F, $11, $4                            ;; 04:585e  ; G#4
    audio_note $21, $11, $4                            ;; 04:5860  ; A#4
    audio_end_pattern                                  ;; 04:5862

audio_04_5863_Pattern07:
; pattern $07
    audio_note $22, $11, $5                            ;; 04:5863  ; B4
    audio_note $22, $11, $2                            ;; 04:5865  ; B4
    audio_note $29, $11, $5                            ;; 04:5867  ; F#5
    audio_note $22, $11, $4                            ;; 04:5869  ; B4
    audio_note $22, $11, $4                            ;; 04:586b  ; B4
    audio_note $22, $11, $2                            ;; 04:586d  ; B4
    audio_note $21, $11, $4                            ;; 04:586f  ; A#4
    audio_note $1F, $11, $4                            ;; 04:5871  ; G#4
    audio_note $1D, $11, $5                            ;; 04:5873  ; F#4
    audio_note $1D, $11, $2                            ;; 04:5875  ; F#4
    audio_note $24, $11, $5                            ;; 04:5877  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5879  ; F#4
    audio_note $1D, $11, $4                            ;; 04:587b  ; F#4
    audio_note $1D, $11, $2                            ;; 04:587d  ; F#4
    audio_note $21, $11, $4                            ;; 04:587f  ; A#4
    audio_note $1D, $11, $4                            ;; 04:5881  ; F#4
    audio_note $24, $11, $5                            ;; 04:5883  ; C#5
    audio_note $24, $11, $2                            ;; 04:5885  ; C#5
    audio_note $1F, $11, $5                            ;; 04:5887  ; G#4
    audio_note $24, $11, $4                            ;; 04:5889  ; C#5
    audio_note $24, $11, $4                            ;; 04:588b  ; C#5
    audio_note $24, $11, $2                            ;; 04:588d  ; C#5
    audio_note $1F, $11, $4                            ;; 04:588f  ; G#4
    audio_note $24, $11, $4                            ;; 04:5891  ; C#5
    audio_note $1D, $11, $5                            ;; 04:5893  ; F#4
    audio_note $1D, $11, $2                            ;; 04:5895  ; F#4
    audio_note $24, $11, $5                            ;; 04:5897  ; C#5
    audio_note $1D, $11, $4                            ;; 04:5899  ; F#4
    audio_note $1D, $11, $4                            ;; 04:589b  ; F#4
    audio_note $1D, $11, $2                            ;; 04:589d  ; F#4
    audio_note $1F, $11, $4                            ;; 04:589f  ; G#4
    audio_note $21, $11, $4                            ;; 04:58a1  ; A#4
    audio_note $22, $11, $5                            ;; 04:58a3  ; B4
    audio_note $22, $11, $2                            ;; 04:58a5  ; B4
    audio_note $29, $11, $5                            ;; 04:58a7  ; F#5
    audio_note $22, $11, $4                            ;; 04:58a9  ; B4
    audio_note $22, $11, $4                            ;; 04:58ab  ; B4
    audio_note $22, $11, $2                            ;; 04:58ad  ; B4
    audio_note $21, $11, $4                            ;; 04:58af  ; A#4
    audio_note $1F, $11, $4                            ;; 04:58b1  ; G#4
    audio_note $1D, $11, $5                            ;; 04:58b3  ; F#4
    audio_note $1D, $11, $2                            ;; 04:58b5  ; F#4
    audio_note $24, $11, $5                            ;; 04:58b7  ; C#5
    audio_note $1D, $11, $4                            ;; 04:58b9  ; F#4
    audio_note $1D, $11, $4                            ;; 04:58bb  ; F#4
    audio_note $1D, $11, $2                            ;; 04:58bd  ; F#4
    audio_note $24, $11, $4                            ;; 04:58bf  ; C#5
    audio_note $1D, $11, $4                            ;; 04:58c1  ; F#4
    audio_note $24, $11, $5                            ;; 04:58c3  ; C#5
    audio_note $24, $11, $2                            ;; 04:58c5  ; C#5
    audio_note $1F, $11, $5                            ;; 04:58c7  ; G#4
    audio_note $24, $11, $4                            ;; 04:58c9  ; C#5
    audio_note $24, $11, $4                            ;; 04:58cb  ; C#5
    audio_note $24, $11, $2                            ;; 04:58cd  ; C#5
    audio_note $1F, $11, $4                            ;; 04:58cf  ; G#4
    audio_note $24, $11, $4                            ;; 04:58d1  ; C#5
    audio_note $1D, $11, $5                            ;; 04:58d3  ; F#4
    audio_note $1D, $11, $2                            ;; 04:58d5  ; F#4
    audio_note $24, $11, $5                            ;; 04:58d7  ; C#5
    audio_note $1D, $11, $4                            ;; 04:58d9  ; F#4
    audio_note $1D, $11, $4                            ;; 04:58db  ; F#4
    audio_note $1D, $11, $2                            ;; 04:58dd  ; F#4
    audio_note $24, $11, $4                            ;; 04:58df  ; C#5
    audio_note $1D, $11, $4                            ;; 04:58e1  ; F#4
    audio_note $1F, $11, $5                            ;; 04:58e3  ; G#4
    audio_note $1F, $11, $2                            ;; 04:58e5  ; G#4
    audio_note $26, $11, $5                            ;; 04:58e7  ; D#5
    audio_note $1F, $11, $4                            ;; 04:58e9  ; G#4
    audio_note $1F, $11, $4                            ;; 04:58eb  ; G#4
    audio_note $1F, $11, $2                            ;; 04:58ed  ; G#4
    audio_note $1F, $11, $4                            ;; 04:58ef  ; G#4
    audio_note $26, $11, $4                            ;; 04:58f1  ; D#5
    audio_end_pattern                                  ;; 04:58f3

audio_04_58f4_Pattern09:
; pattern $09
    audio_note $24, $00, $4                            ;; 04:58f4  ; C#5
    audio_note $43, $08, $2                            ;; 04:58f6  ; G#7
    audio_note $43, $08, $2                            ;; 04:58f8  ; G#7
    audio_note $43, $08, $2                            ;; 04:58fa  ; G#7
    audio_note $45, $08, $4                            ;; 04:58fc  ; A#7
    audio_note $43, $08, $2                            ;; 04:58fe  ; G#7
    audio_note $24, $00, $8                            ;; 04:5900  ; C#5
    audio_note $24, $00, $4                            ;; 04:5902  ; C#5
    audio_note $43, $08, $2                            ;; 04:5904  ; G#7
    audio_note $43, $08, $2                            ;; 04:5906  ; G#7
    audio_note $43, $08, $2                            ;; 04:5908  ; G#7
    audio_note $45, $08, $4                            ;; 04:590a  ; A#7
    audio_note $43, $08, $2                            ;; 04:590c  ; G#7
    audio_note $24, $00, $8                            ;; 04:590e  ; C#5
    audio_note $24, $00, $4                            ;; 04:5910  ; C#5
    audio_note $41, $08, $2                            ;; 04:5912  ; F#7
    audio_note $41, $08, $2                            ;; 04:5914  ; F#7
    audio_note $41, $08, $2                            ;; 04:5916  ; F#7
    audio_note $43, $08, $4                            ;; 04:5918  ; G#7
    audio_note $41, $08, $2                            ;; 04:591a  ; F#7
    audio_note $24, $00, $8                            ;; 04:591c  ; C#5
    audio_note $24, $00, $4                            ;; 04:591e  ; C#5
    audio_note $3E, $08, $2                            ;; 04:5920  ; D#7
    audio_note $3E, $08, $2                            ;; 04:5922  ; D#7
    audio_note $3E, $08, $2                            ;; 04:5924  ; D#7
    audio_note $40, $08, $4                            ;; 04:5926  ; F7
    audio_note $3E, $08, $2                            ;; 04:5928  ; D#7
    audio_note $24, $00, $6                            ;; 04:592a  ; C#5
    audio_note $24, $00, $2                            ;; 04:592c  ; C#5
    audio_note $43, $08, $2                            ;; 04:592e  ; G#7
    audio_note $43, $08, $2                            ;; 04:5930  ; G#7
    audio_note $44, $08, $2                            ;; 04:5932  ; A7
    audio_end_pattern                                  ;; 04:5934

audio_04_5935_Pattern0A:
; pattern $0A
    audio_note $45, $08, $4                            ;; 04:5935  ; A#7
    audio_note $43, $08, $4                            ;; 04:5937  ; G#7
    audio_note $41, $08, $2                            ;; 04:5939  ; F#7
    audio_note $3E, $08, $4                            ;; 04:593b  ; D#7
    audio_note $3B, $08, $4                            ;; 04:593d  ; C7
    audio_note $37, $08, $4                            ;; 04:593f  ; G#6
    audio_note $37, $08, $2                            ;; 04:5941  ; G#6
    audio_note $39, $08, $4                            ;; 04:5943  ; A#6
    audio_note $3B, $08, $4                            ;; 04:5945  ; C7
    audio_note $3C, $08, $4                            ;; 04:5947  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5949  ; C#7
    audio_note $3C, $08, $2                            ;; 04:594b  ; C#7
    audio_note $3C, $08, $2                            ;; 04:594d  ; C#7
    audio_note $3E, $08, $4                            ;; 04:594f  ; D#7
    audio_note $40, $08, $4                            ;; 04:5951  ; F7
    audio_note $40, $08, $4                            ;; 04:5953  ; F7
    audio_note $40, $08, $2                            ;; 04:5955  ; F7
    audio_note $41, $08, $4                            ;; 04:5957  ; F#7
    audio_note $40, $08, $4                            ;; 04:5959  ; F7
    audio_note $43, $08, $4                            ;; 04:595b  ; G#7
    audio_note $43, $08, $2                            ;; 04:595d  ; G#7
    audio_note $43, $08, $2                            ;; 04:595f  ; G#7
    audio_note $43, $08, $2                            ;; 04:5961  ; G#7
    audio_note $41, $08, $4                            ;; 04:5963  ; F#7
    audio_note $40, $08, $4                            ;; 04:5965  ; F7
    audio_note $3E, $08, $4                            ;; 04:5967  ; D#7
    audio_note $3E, $08, $2                            ;; 04:5969  ; D#7
    audio_note $3C, $08, $4                            ;; 04:596b  ; C#7
    audio_note $3B, $08, $4                            ;; 04:596d  ; C7
    audio_note $3C, $08, $4                            ;; 04:596f  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5971  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5973  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5975  ; C#7
    audio_note $3E, $08, $4                            ;; 04:5977  ; D#7
    audio_note $3F, $08, $4                            ;; 04:5979  ; E7
    audio_note $40, $08, $4                            ;; 04:597b  ; F7
    audio_note $43, $08, $2                            ;; 04:597d  ; G#7
    audio_note $43, $08, $2                            ;; 04:597f  ; G#7
    audio_note $43, $08, $2                            ;; 04:5981  ; G#7
    audio_note $43, $08, $2                            ;; 04:5983  ; G#7
    audio_note $44, $08, $2                            ;; 04:5985  ; A7
    audio_note $45, $08, $4                            ;; 04:5987  ; A#7
    audio_note $43, $08, $4                            ;; 04:5989  ; G#7
    audio_note $41, $08, $2                            ;; 04:598b  ; F#7
    audio_note $3E, $08, $4                            ;; 04:598d  ; D#7
    audio_note $3B, $08, $4                            ;; 04:598f  ; C7
    audio_note $37, $08, $4                            ;; 04:5991  ; G#6
    audio_note $37, $08, $2                            ;; 04:5993  ; G#6
    audio_note $39, $08, $4                            ;; 04:5995  ; A#6
    audio_note $3B, $08, $4                            ;; 04:5997  ; C7
    audio_note $3C, $08, $4                            ;; 04:5999  ; C#7
    audio_note $3C, $08, $2                            ;; 04:599b  ; C#7
    audio_note $3C, $08, $2                            ;; 04:599d  ; C#7
    audio_note $3C, $08, $2                            ;; 04:599f  ; C#7
    audio_note $3E, $08, $4                            ;; 04:59a1  ; D#7
    audio_note $40, $08, $4                            ;; 04:59a3  ; F7
    audio_note $40, $08, $4                            ;; 04:59a5  ; F7
    audio_note $40, $08, $2                            ;; 04:59a7  ; F7
    audio_note $41, $08, $4                            ;; 04:59a9  ; F#7
    audio_note $43, $08, $4                            ;; 04:59ab  ; G#7
    audio_note $41, $08, $4                            ;; 04:59ad  ; F#7
    audio_note $41, $08, $2                            ;; 04:59af  ; F#7
    audio_note $41, $08, $2                            ;; 04:59b1  ; F#7
    audio_note $41, $08, $2                            ;; 04:59b3  ; F#7
    audio_note $40, $08, $4                            ;; 04:59b5  ; F7
    audio_note $3E, $08, $4                            ;; 04:59b7  ; D#7
    audio_note $3E, $08, $4                            ;; 04:59b9  ; D#7
    audio_note $3E, $08, $2                            ;; 04:59bb  ; D#7
    audio_note $3C, $08, $4                            ;; 04:59bd  ; C#7
    audio_note $3B, $08, $4                            ;; 04:59bf  ; C7
    audio_note $3C, $08, $4                            ;; 04:59c1  ; C#7
    audio_note $3C, $08, $2                            ;; 04:59c3  ; C#7
    audio_note $3C, $08, $2                            ;; 04:59c5  ; C#7
    audio_note $3C, $08, $2                            ;; 04:59c7  ; C#7
    audio_note $3E, $08, $4                            ;; 04:59c9  ; D#7
    audio_note $3F, $08, $4                            ;; 04:59cb  ; E7
    audio_note $40, $08, $4                            ;; 04:59cd  ; F7
    audio_note $43, $08, $2                            ;; 04:59cf  ; G#7
    audio_note $45, $08, $4                            ;; 04:59d1  ; A#7
    audio_note $43, $08, $4                            ;; 04:59d3  ; G#7
    audio_end_pattern                                  ;; 04:59d5

audio_04_59d6_Pattern0B:
; pattern $0B
    audio_note $41, $08, $4                            ;; 04:59d6  ; F#7
    audio_note $48, $08, $2                            ;; 04:59d8  ; C#8
    audio_note $48, $08, $2                            ;; 04:59da  ; C#8
    audio_note $48, $08, $4                            ;; 04:59dc  ; C#8
    audio_note $48, $08, $2                            ;; 04:59de  ; C#8
    audio_note $48, $08, $4                            ;; 04:59e0  ; C#8
    audio_note $47, $08, $4                            ;; 04:59e2  ; C8
    audio_note $45, $08, $2                            ;; 04:59e4  ; A#7
    audio_note $43, $08, $4                            ;; 04:59e6  ; G#7
    audio_note $41, $08, $4                            ;; 04:59e8  ; F#7
    audio_note $40, $08, $4                            ;; 04:59ea  ; F7
    audio_note $43, $08, $2                            ;; 04:59ec  ; G#7
    audio_note $43, $08, $2                            ;; 04:59ee  ; G#7
    audio_note $43, $08, $2                            ;; 04:59f0  ; G#7
    audio_note $41, $08, $4                            ;; 04:59f2  ; F#7
    audio_note $40, $08, $4                            ;; 04:59f4  ; F7
    audio_note $40, $08, $4                            ;; 04:59f6  ; F7
    audio_note $40, $08, $2                            ;; 04:59f8  ; F7
    audio_note $3E, $08, $4                            ;; 04:59fa  ; D#7
    audio_note $3C, $08, $4                            ;; 04:59fc  ; C#7
    audio_note $3B, $08, $4                            ;; 04:59fe  ; C7
    audio_note $3B, $08, $2                            ;; 04:5a00  ; C7
    audio_note $3B, $08, $2                            ;; 04:5a02  ; C7
    audio_note $3B, $08, $2                            ;; 04:5a04  ; C7
    audio_note $3C, $08, $4                            ;; 04:5a06  ; C#7
    audio_note $3E, $08, $4                            ;; 04:5a08  ; D#7
    audio_note $3E, $08, $4                            ;; 04:5a0a  ; D#7
    audio_note $3E, $08, $2                            ;; 04:5a0c  ; D#7
    audio_note $3C, $08, $4                            ;; 04:5a0e  ; C#7
    audio_note $3B, $08, $4                            ;; 04:5a10  ; C7
    audio_note $3C, $08, $4                            ;; 04:5a12  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5a14  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5a16  ; C#7
    audio_note $3E, $08, $2                            ;; 04:5a18  ; D#7
    audio_note $3F, $08, $4                            ;; 04:5a1a  ; E7
    audio_note $40, $08, $4                            ;; 04:5a1c  ; F7
    audio_note $43, $08, $4                            ;; 04:5a1e  ; G#7
    audio_note $43, $08, $2                            ;; 04:5a20  ; G#7
    audio_note $45, $08, $4                            ;; 04:5a22  ; A#7
    audio_note $43, $08, $4                            ;; 04:5a24  ; G#7
    audio_note $41, $08, $4                            ;; 04:5a26  ; F#7
    audio_note $48, $08, $2                            ;; 04:5a28  ; C#8
    audio_note $48, $08, $2                            ;; 04:5a2a  ; C#8
    audio_note $48, $08, $2                            ;; 04:5a2c  ; C#8
    audio_note $48, $08, $4                            ;; 04:5a2e  ; C#8
    audio_note $47, $08, $4                            ;; 04:5a30  ; C8
    audio_note $45, $08, $4                            ;; 04:5a32  ; A#7
    audio_note $43, $08, $2                            ;; 04:5a34  ; G#7
    audio_note $41, $08, $4                            ;; 04:5a36  ; F#7
    audio_note $40, $08, $4                            ;; 04:5a38  ; F7
    audio_note $3C, $08, $4                            ;; 04:5a3a  ; C#7
    audio_note $43, $08, $2                            ;; 04:5a3c  ; G#7
    audio_note $43, $08, $2                            ;; 04:5a3e  ; G#7
    audio_note $43, $08, $2                            ;; 04:5a40  ; G#7
    audio_note $41, $08, $4                            ;; 04:5a42  ; F#7
    audio_note $40, $08, $4                            ;; 04:5a44  ; F7
    audio_note $40, $08, $4                            ;; 04:5a46  ; F7
    audio_note $40, $08, $2                            ;; 04:5a48  ; F7
    audio_note $3E, $08, $4                            ;; 04:5a4a  ; D#7
    audio_note $3C, $08, $4                            ;; 04:5a4c  ; C#7
    audio_note $3B, $08, $4                            ;; 04:5a4e  ; C7
    audio_note $3B, $08, $2                            ;; 04:5a50  ; C7
    audio_note $3B, $08, $2                            ;; 04:5a52  ; C7
    audio_note $3B, $08, $2                            ;; 04:5a54  ; C7
    audio_note $39, $08, $4                            ;; 04:5a56  ; A#6
    audio_note $37, $08, $4                            ;; 04:5a58  ; G#6
    audio_note $37, $08, $4                            ;; 04:5a5a  ; G#6
    audio_note $37, $08, $2                            ;; 04:5a5c  ; G#6
    audio_note $39, $08, $4                            ;; 04:5a5e  ; A#6
    audio_note $3B, $08, $4                            ;; 04:5a60  ; C7
    audio_note $3C, $08, $4                            ;; 04:5a62  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5a64  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5a66  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5a68  ; C#7
    audio_note $3C, $08, $8                            ;; 04:5a6a  ; C#7
    audio_note $24, $00, $2                            ;; 04:5a6c  ; C#5
    audio_end_pattern                                  ;; 04:5a6e

audio_04_5a6f_Pattern0C:
; pattern $0C
    audio_note $48, $08, $4                            ;; 04:5a6f  ; C#8
    audio_note $48, $08, $2                            ;; 04:5a71  ; C#8
    audio_note $48, $08, $2                            ;; 04:5a73  ; C#8
    audio_note $48, $08, $2                            ;; 04:5a75  ; C#8
    audio_note $46, $08, $4                            ;; 04:5a77  ; B7
    audio_note $45, $08, $4                            ;; 04:5a79  ; A#7
    audio_note $45, $08, $4                            ;; 04:5a7b  ; A#7
    audio_note $45, $08, $2                            ;; 04:5a7d  ; A#7
    audio_note $43, $08, $4                            ;; 04:5a7f  ; G#7
    audio_note $41, $08, $4                            ;; 04:5a81  ; F#7
    audio_note $43, $08, $2                            ;; 04:5a83  ; G#7
    audio_note $45, $08, $2                            ;; 04:5a85  ; A#7
    audio_note $43, $08, $2                            ;; 04:5a87  ; G#7
    audio_note $41, $08, $2                            ;; 04:5a89  ; F#7
    audio_note $40, $08, $2                            ;; 04:5a8b  ; F7
    audio_note $3E, $08, $4                            ;; 04:5a8d  ; D#7
    audio_note $3C, $08, $4                            ;; 04:5a8f  ; C#7
    audio_note $48, $08, $2                            ;; 04:5a91  ; C#8
    audio_note $4A, $08, $2                            ;; 04:5a93  ; D#8
    audio_note $4C, $08, $2                            ;; 04:5a95  ; F8
    audio_note $4A, $08, $4                            ;; 04:5a97  ; D#8
    audio_note $48, $08, $4                            ;; 04:5a99  ; C#8
    audio_note $46, $08, $4                            ;; 04:5a9b  ; B7
    audio_note $46, $08, $2                            ;; 04:5a9d  ; B7
    audio_note $46, $08, $2                            ;; 04:5a9f  ; B7
    audio_note $46, $08, $2                            ;; 04:5aa1  ; B7
    audio_note $45, $08, $4                            ;; 04:5aa3  ; A#7
    audio_note $43, $08, $4                            ;; 04:5aa5  ; G#7
    audio_note $43, $08, $4                            ;; 04:5aa7  ; G#7
    audio_note $43, $08, $2                            ;; 04:5aa9  ; G#7
    audio_note $41, $08, $4                            ;; 04:5aab  ; F#7
    audio_note $40, $08, $4                            ;; 04:5aad  ; F7
    audio_note $41, $08, $4                            ;; 04:5aaf  ; F#7
    audio_note $41, $08, $2                            ;; 04:5ab1  ; F#7
    audio_note $43, $08, $2                            ;; 04:5ab3  ; G#7
    audio_note $45, $08, $2                            ;; 04:5ab5  ; A#7
    audio_note $41, $08, $4                            ;; 04:5ab7  ; F#7
    audio_note $3C, $08, $4                            ;; 04:5ab9  ; C#7
    audio_note $48, $08, $2                            ;; 04:5abb  ; C#8
    audio_note $4D, $08, $2                            ;; 04:5abd  ; F#8
    audio_note $4F, $08, $2                            ;; 04:5abf  ; G#8
    audio_note $51, $08, $4                            ;; 04:5ac1  ; A#8
    audio_note $4D, $08, $4                            ;; 04:5ac3  ; F#8
    audio_note $48, $08, $4                            ;; 04:5ac5  ; C#8
    audio_note $48, $08, $2                            ;; 04:5ac7  ; C#8
    audio_note $48, $08, $2                            ;; 04:5ac9  ; C#8
    audio_note $48, $08, $2                            ;; 04:5acb  ; C#8
    audio_note $46, $08, $4                            ;; 04:5acd  ; B7
    audio_note $45, $08, $4                            ;; 04:5acf  ; A#7
    audio_note $45, $08, $4                            ;; 04:5ad1  ; A#7
    audio_note $45, $08, $2                            ;; 04:5ad3  ; A#7
    audio_note $43, $08, $4                            ;; 04:5ad5  ; G#7
    audio_note $41, $08, $4                            ;; 04:5ad7  ; F#7
    audio_note $43, $08, $2                            ;; 04:5ad9  ; G#7
    audio_note $45, $08, $2                            ;; 04:5adb  ; A#7
    audio_note $43, $08, $2                            ;; 04:5add  ; G#7
    audio_note $41, $08, $2                            ;; 04:5adf  ; F#7
    audio_note $40, $08, $2                            ;; 04:5ae1  ; F7
    audio_note $3E, $08, $4                            ;; 04:5ae3  ; D#7
    audio_note $3C, $08, $4                            ;; 04:5ae5  ; C#7
    audio_note $48, $08, $2                            ;; 04:5ae7  ; C#8
    audio_note $4A, $08, $2                            ;; 04:5ae9  ; D#8
    audio_note $4C, $08, $2                            ;; 04:5aeb  ; F8
    audio_note $4A, $08, $4                            ;; 04:5aed  ; D#8
    audio_note $48, $08, $4                            ;; 04:5aef  ; C#8
    audio_note $46, $08, $4                            ;; 04:5af1  ; B7
    audio_note $45, $08, $2                            ;; 04:5af3  ; A#7
    audio_note $43, $08, $4                            ;; 04:5af5  ; G#7
    audio_note $41, $08, $4                            ;; 04:5af7  ; F#7
    audio_note $40, $08, $4                            ;; 04:5af9  ; F7
    audio_note $40, $08, $4                            ;; 04:5afb  ; F7
    audio_note $40, $08, $2                            ;; 04:5afd  ; F7
    audio_note $41, $08, $4                            ;; 04:5aff  ; F#7
    audio_note $43, $08, $4                            ;; 04:5b01  ; G#7
    audio_note $41, $08, $4                            ;; 04:5b03  ; F#7
    audio_note $41, $08, $2                            ;; 04:5b05  ; F#7
    audio_note $43, $08, $2                            ;; 04:5b07  ; G#7
    audio_note $45, $08, $2                            ;; 04:5b09  ; A#7
    audio_note $43, $08, $4                            ;; 04:5b0b  ; G#7
    audio_note $41, $08, $4                            ;; 04:5b0d  ; F#7
    audio_note $41, $08, $4                            ;; 04:5b0f  ; F#7
    audio_note $41, $08, $2                            ;; 04:5b11  ; F#7
    audio_note $43, $08, $4                            ;; 04:5b13  ; G#7
    audio_note $45, $08, $4                            ;; 04:5b15  ; A#7
    audio_end_pattern                                  ;; 04:5b17

audio_04_5b18_Pattern0D:
; pattern $0D
    audio_note $46, $08, $4                            ;; 04:5b18  ; B7
    audio_note $3E, $08, $4                            ;; 04:5b1a  ; D#7
    audio_note $41, $08, $4                            ;; 04:5b1c  ; F#7
    audio_note $46, $08, $2                            ;; 04:5b1e  ; B7
    audio_note $3E, $08, $4                            ;; 04:5b20  ; D#7
    audio_note $3E, $08, $4                            ;; 04:5b22  ; D#7
    audio_note $41, $08, $2                            ;; 04:5b24  ; F#7
    audio_note $46, $08, $4                            ;; 04:5b26  ; B7
    audio_note $41, $08, $4                            ;; 04:5b28  ; F#7
    audio_note $45, $08, $4                            ;; 04:5b2a  ; A#7
    audio_note $3C, $08, $4                            ;; 04:5b2c  ; C#7
    audio_note $41, $08, $4                            ;; 04:5b2e  ; F#7
    audio_note $45, $08, $2                            ;; 04:5b30  ; A#7
    audio_note $3C, $08, $4                            ;; 04:5b32  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5b34  ; C#7
    audio_note $41, $08, $2                            ;; 04:5b36  ; F#7
    audio_note $45, $08, $4                            ;; 04:5b38  ; A#7
    audio_note $41, $08, $4                            ;; 04:5b3a  ; F#7
    audio_note $43, $08, $4                            ;; 04:5b3c  ; G#7
    audio_note $3C, $08, $4                            ;; 04:5b3e  ; C#7
    audio_note $40, $08, $4                            ;; 04:5b40  ; F7
    audio_note $43, $08, $2                            ;; 04:5b42  ; G#7
    audio_note $3C, $08, $4                            ;; 04:5b44  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5b46  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5b48  ; C#7
    audio_note $40, $08, $4                            ;; 04:5b4a  ; F7
    audio_note $43, $08, $4                            ;; 04:5b4c  ; G#7
    audio_note $41, $08, $4                            ;; 04:5b4e  ; F#7
    audio_note $40, $08, $4                            ;; 04:5b50  ; F7
    audio_note $41, $08, $4                            ;; 04:5b52  ; F#7
    audio_note $43, $08, $2                            ;; 04:5b54  ; G#7
    audio_note $45, $08, $4                            ;; 04:5b56  ; A#7
    audio_note $3C, $08, $4                            ;; 04:5b58  ; C#7
    audio_note $3C, $08, $2                            ;; 04:5b5a  ; C#7
    audio_note $41, $08, $4                            ;; 04:5b5c  ; F#7
    audio_note $45, $08, $4                            ;; 04:5b5e  ; A#7
    audio_note $46, $08, $4                            ;; 04:5b60  ; B7
    audio_note $3E, $08, $4                            ;; 04:5b62  ; D#7
    audio_note $41, $08, $4                            ;; 04:5b64  ; F#7
    audio_note $46, $08, $2                            ;; 04:5b66  ; B7
    audio_note $3E, $08, $4                            ;; 04:5b68  ; D#7
    audio_note $3E, $08, $4                            ;; 04:5b6a  ; D#7
    audio_note $41, $08, $2                            ;; 04:5b6c  ; F#7
    audio_note $46, $08, $4                            ;; 04:5b6e  ; B7
    audio_note $41, $08, $4                            ;; 04:5b70  ; F#7
    audio_note $45, $08, $4                            ;; 04:5b72  ; A#7
    audio_note $3C, $08, $4                            ;; 04:5b74  ; C#7
    audio_note $41, $08, $4                            ;; 04:5b76  ; F#7
    audio_note $45, $08, $2                            ;; 04:5b78  ; A#7
    audio_note $3C, $08, $4                            ;; 04:5b7a  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5b7c  ; C#7
    audio_note $41, $08, $2                            ;; 04:5b7e  ; F#7
    audio_note $45, $08, $4                            ;; 04:5b80  ; A#7
    audio_note $41, $08, $4                            ;; 04:5b82  ; F#7
    audio_note $43, $08, $4                            ;; 04:5b84  ; G#7
    audio_note $3C, $08, $4                            ;; 04:5b86  ; C#7
    audio_note $40, $08, $4                            ;; 04:5b88  ; F7
    audio_note $43, $08, $2                            ;; 04:5b8a  ; G#7
    audio_note $3C, $08, $4                            ;; 04:5b8c  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5b8e  ; C#7
    audio_note $40, $08, $2                            ;; 04:5b90  ; F7
    audio_note $43, $08, $4                            ;; 04:5b92  ; G#7
    audio_note $40, $08, $4                            ;; 04:5b94  ; F7
    audio_note $41, $08, $4                            ;; 04:5b96  ; F#7
    audio_note $39, $08, $4                            ;; 04:5b98  ; A#6
    audio_note $3C, $08, $2                            ;; 04:5b9a  ; C#7
    audio_note $41, $08, $4                            ;; 04:5b9c  ; F#7
    audio_note $41, $08, $4                            ;; 04:5b9e  ; F#7
    audio_note $41, $08, $4                            ;; 04:5ba0  ; F#7
    audio_note $39, $08, $2                            ;; 04:5ba2  ; A#6
    audio_note $3C, $08, $4                            ;; 04:5ba4  ; C#7
    audio_note $41, $08, $4                            ;; 04:5ba6  ; F#7
    audio_note $43, $08, $4                            ;; 04:5ba8  ; G#7
    audio_note $3B, $08, $4                            ;; 04:5baa  ; C7
    audio_note $3E, $08, $4                            ;; 04:5bac  ; D#7
    audio_note $43, $08, $2                            ;; 04:5bae  ; G#7
    audio_note $43, $08, $4                            ;; 04:5bb0  ; G#7
    audio_note $43, $08, $4                            ;; 04:5bb2  ; G#7
    audio_note $43, $08, $2                            ;; 04:5bb4  ; G#7
    audio_note $43, $08, $4                            ;; 04:5bb6  ; G#7
    audio_note $43, $08, $2                            ;; 04:5bb8  ; G#7
    audio_note $44, $08, $2                            ;; 04:5bba  ; A7
    audio_end_pattern                                  ;; 04:5bbc

audio_04_5bbd_Song_HolidayTv_Ch1:
; SONG_HOLIDAY_TV (song $02) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 04:5bbd
    audio_tempo $CA                                    ;; 04:5bbf
    audio_call $23, $E1, 4                             ;; 04:5bc1
    audio_call $24, $E1, 1                             ;; 04:5bc5
    audio_tempo $AB                                    ;; 04:5bc9
    audio_call $25, $E1, 2                             ;; 04:5bcb
    audio_call $26, $E1, 1                             ;; 04:5bcf
    audio_call $25, $E1, 1                             ;; 04:5bd3
    audio_call $25, $E3, 1                             ;; 04:5bd7
    audio_call $26, $E3, 1                             ;; 04:5bdb
    audio_call $25, $E3, 1                             ;; 04:5bdf
    audio_call $00, $00, 2                             ;; 04:5be3
    audio_call $27, $E1, 2                             ;; 04:5be7
    audio_call $28, $E1, 1                             ;; 04:5beb
    audio_call $27, $E1, 1                             ;; 04:5bef
    audio_call $24, $E1, 1                             ;; 04:5bf3
    audio_call $29, $E1, 1                             ;; 04:5bf7
    audio_call $30, $E1, 1                             ;; 04:5bfb
    audio_call $2A, $E1, 2                             ;; 04:5bff
    audio_marker $01                                   ;; 04:5c03
    audio_goto audio_04_5bbd_Song_HolidayTv_Ch1        ;; 04:5c05

audio_04_5c08_Song_HolidayTv_Ch2:
; SONG_HOLIDAY_TV (song $02) channel 2
; AUDIO_CMD_GOTO target
    audio_call $23, $DC, 4                             ;; 04:5c08
    audio_call $20, $E1, 1                             ;; 04:5c0c
    audio_call $21, $E1, 2                             ;; 04:5c10
    audio_call $22, $E1, 1                             ;; 04:5c14
    audio_call $21, $E1, 1                             ;; 04:5c18
    audio_call $21, $E3, 1                             ;; 04:5c1c
    audio_call $22, $E3, 1                             ;; 04:5c20
    audio_call $21, $E3, 1                             ;; 04:5c24
    audio_call $2B, $05, 3                             ;; 04:5c28
    audio_call $2C, $05, 1                             ;; 04:5c2c
    audio_call $2B, $05, 1                             ;; 04:5c30
    audio_call $2C, $05, 1                             ;; 04:5c34
    audio_call $2B, $05, 1                             ;; 04:5c38
    audio_call $2C, $05, 1                             ;; 04:5c3c
    audio_call $2B, $05, 1                             ;; 04:5c40
    audio_call $2C, $05, 1                             ;; 04:5c44
    audio_call $2D, $0A, 1                             ;; 04:5c48
    audio_call $2D, $05, 1                             ;; 04:5c4c
    audio_call $2D, $00, 1                             ;; 04:5c50
    audio_call $2D, $05, 1                             ;; 04:5c54
    audio_call $2D, $0A, 1                             ;; 04:5c58
    audio_call $2D, $05, 1                             ;; 04:5c5c
    audio_call $2D, $00, 1                             ;; 04:5c60
    audio_call $2D, $05, 1                             ;; 04:5c64
    audio_call $2B, $05, 1                             ;; 04:5c68
    audio_call $2C, $05, 1                             ;; 04:5c6c
    audio_call $2B, $05, 1                             ;; 04:5c70
    audio_call $2C, $05, 1                             ;; 04:5c74
    audio_call $20, $E1, 1                             ;; 04:5c78
    audio_call $2E, $05, 1                             ;; 04:5c7c
    audio_call $2F, $05, 2                             ;; 04:5c80
    audio_goto audio_04_5c08_Song_HolidayTv_Ch2        ;; 04:5c84

audio_04_5c87_Song_HolidayTv_Ch3:
; SONG_HOLIDAY_TV (song $02) channel 3
; AUDIO_CMD_GOTO target
    audio_call $17, $ED, 1                             ;; 04:5c87
    audio_call $18, $ED, 1                             ;; 04:5c8b
    audio_call $19, $ED, 2                             ;; 04:5c8f
    audio_call $1A, $ED, 1                             ;; 04:5c93
    audio_call $19, $ED, 1                             ;; 04:5c97
    audio_call $19, $EF, 1                             ;; 04:5c9b
    audio_call $1A, $EF, 1                             ;; 04:5c9f
    audio_call $19, $EF, 1                             ;; 04:5ca3
    audio_call $1B, $ED, 3                             ;; 04:5ca7
    audio_call $1C, $ED, 1                             ;; 04:5cab
    audio_call $1B, $ED, 1                             ;; 04:5caf
    audio_call $1C, $ED, 1                             ;; 04:5cb3
    audio_call $1B, $ED, 1                             ;; 04:5cb7
    audio_call $1C, $ED, 1                             ;; 04:5cbb
    audio_call $1B, $ED, 1                             ;; 04:5cbf
    audio_call $1C, $ED, 1                             ;; 04:5cc3
    audio_call $1D, $F2, 1                             ;; 04:5cc7
    audio_call $1D, $ED, 1                             ;; 04:5ccb
    audio_call $1D, $E8, 1                             ;; 04:5ccf
    audio_call $1D, $ED, 1                             ;; 04:5cd3
    audio_call $1D, $F2, 1                             ;; 04:5cd7
    audio_call $1D, $ED, 1                             ;; 04:5cdb
    audio_call $1D, $E8, 1                             ;; 04:5cdf
    audio_call $1D, $ED, 1                             ;; 04:5ce3
    audio_call $1B, $ED, 1                             ;; 04:5ce7
    audio_call $1C, $ED, 1                             ;; 04:5ceb
    audio_call $1B, $ED, 1                             ;; 04:5cef
    audio_call $1C, $ED, 1                             ;; 04:5cf3
    audio_call $18, $ED, 1                             ;; 04:5cf7
    audio_call $1E, $ED, 1                             ;; 04:5cfb
    audio_call $1F, $ED, 2                             ;; 04:5cff
    audio_goto audio_04_5c87_Song_HolidayTv_Ch3        ;; 04:5d03

audio_04_5d06_Song_HolidayTv_Ch4:
; SONG_HOLIDAY_TV (song $02) channel 4
; AUDIO_CMD_GOTO target
    audio_call $00, $00, 6                             ;; 04:5d06
    audio_call $16, $00, 17                            ;; 04:5d0a
    audio_goto audio_04_5d06_Song_HolidayTv_Ch4        ;; 04:5d0e

audio_04_5d11_Pattern2F:
; pattern $2F
; pattern $31
; pattern $32
; pattern $33
; pattern $34
; pattern $35
    audio_note $24, $00, $4                            ;; 04:5d11  ; C#5
    audio_note $21, $13, $6                            ;; 04:5d13  ; A#4
    audio_note $21, $13, $6                            ;; 04:5d15  ; A#4
    audio_note $1A, $17, $6                            ;; 04:5d17  ; D#4
    audio_note $1A, $17, $6                            ;; 04:5d19  ; D#4
    audio_note $1F, $13, $6                            ;; 04:5d1b  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d1d  ; G#4
    audio_note $18, $15, $8                            ;; 04:5d1f  ; C#4
    audio_note $21, $13, $6                            ;; 04:5d21  ; A#4
    audio_note $21, $13, $6                            ;; 04:5d23  ; A#4
    audio_note $1A, $17, $6                            ;; 04:5d25  ; D#4
    audio_note $1A, $17, $6                            ;; 04:5d27  ; D#4
    audio_note $1F, $13, $6                            ;; 04:5d29  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d2b  ; G#4
    audio_note $18, $15, $6                            ;; 04:5d2d  ; C#4
    audio_note $18, $15, $4                            ;; 04:5d2f  ; C#4
    audio_end_pattern                                  ;; 04:5d31

audio_04_5d32_Pattern2E:
; pattern $2E
    audio_note $24, $00, $4                            ;; 04:5d32  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d34  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d36  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d38  ; C#5
    audio_note $24, $13, $4                            ;; 04:5d3a  ; C#5
    audio_note $24, $00, $4                            ;; 04:5d3c  ; C#5
    audio_note $1D, $15, $6                            ;; 04:5d3e  ; F#4
    audio_note $1D, $15, $6                            ;; 04:5d40  ; F#4
    audio_note $24, $13, $6                            ;; 04:5d42  ; C#5
    audio_note $24, $13, $4                            ;; 04:5d44  ; C#5
    audio_note $24, $00, $4                            ;; 04:5d46  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d48  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d4a  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d4c  ; C#5
    audio_note $24, $13, $4                            ;; 04:5d4e  ; C#5
    audio_note $24, $00, $4                            ;; 04:5d50  ; C#5
    audio_note $1A, $15, $6                            ;; 04:5d52  ; D#4
    audio_note $1A, $15, $6                            ;; 04:5d54  ; D#4
    audio_note $1F, $14, $6                            ;; 04:5d56  ; G#4
    audio_note $1F, $14, $4                            ;; 04:5d58  ; G#4
    audio_note $24, $00, $4                            ;; 04:5d5a  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d5c  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d5e  ; C#5
    audio_note $24, $13, $6                            ;; 04:5d60  ; C#5
    audio_note $24, $13, $4                            ;; 04:5d62  ; C#5
    audio_note $24, $00, $4                            ;; 04:5d64  ; C#5
    audio_note $1D, $14, $6                            ;; 04:5d66  ; F#4
    audio_note $1D, $14, $6                            ;; 04:5d68  ; F#4
    audio_note $28, $13, $6                            ;; 04:5d6a  ; F5
    audio_note $28, $13, $4                            ;; 04:5d6c  ; F5
    audio_note $24, $00, $4                            ;; 04:5d6e  ; C#5
    audio_note $1D, $14, $6                            ;; 04:5d70  ; F#4
    audio_note $1D, $14, $6                            ;; 04:5d72  ; F#4
    audio_note $24, $13, $6                            ;; 04:5d74  ; C#5
    audio_note $21, $13, $4                            ;; 04:5d76  ; A#4
    audio_note $24, $00, $4                            ;; 04:5d78  ; C#5
    audio_note $1A, $18, $6                            ;; 04:5d7a  ; D#4
    audio_note $1F, $14, $6                            ;; 04:5d7c  ; G#4
    audio_note $18, $15, $6                            ;; 04:5d7e  ; C#4
    audio_note $18, $15, $4                            ;; 04:5d80  ; C#4
    audio_end_pattern                                  ;; 04:5d82

audio_04_5d83_Pattern2B:
; pattern $2B
    audio_note $24, $00, $4                            ;; 04:5d83  ; C#5
    audio_note $1F, $13, $6                            ;; 04:5d85  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d87  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d89  ; G#4
    audio_note $1E, $13, $4                            ;; 04:5d8b  ; G4
    audio_end_pattern                                  ;; 04:5d8d

audio_04_5d8e_Pattern2C:
; pattern $2C
    audio_note $24, $00, $4                            ;; 04:5d8e  ; C#5
    audio_note $1F, $13, $6                            ;; 04:5d90  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d92  ; G#4
    audio_note $1A, $13, $6                            ;; 04:5d94  ; D#4
    audio_note $1A, $13, $4                            ;; 04:5d96  ; D#4
    audio_end_pattern                                  ;; 04:5d98

audio_04_5d99_Pattern2D:
; pattern $2D
    audio_note $24, $00, $4                            ;; 04:5d99  ; C#5
    audio_note $1F, $13, $6                            ;; 04:5d9b  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d9d  ; G#4
    audio_note $1F, $13, $6                            ;; 04:5d9f  ; G#4
    audio_note $1F, $13, $4                            ;; 04:5da1  ; G#4
    audio_end_pattern                                  ;; 04:5da3

audio_04_5da4_Pattern23:
; pattern $23
    audio_note $43, $0B, $4                            ;; 04:5da4  ; G#7
    audio_note $4F, $0B, $4                            ;; 04:5da6  ; G#8
    audio_note $4E, $0B, $4                            ;; 04:5da8  ; G8
    audio_note $4C, $0B, $4                            ;; 04:5daa  ; F8
    audio_note $4A, $0B, $4                            ;; 04:5dac  ; D#8
    audio_note $48, $0B, $4                            ;; 04:5dae  ; C#8
    audio_note $47, $0B, $4                            ;; 04:5db0  ; C8
    audio_note $45, $0B, $4                            ;; 04:5db2  ; A#7
    audio_end_pattern                                  ;; 04:5db4

audio_04_5db5_Pattern24:
; pattern $24
    audio_note $43, $0B, $6                            ;; 04:5db5  ; G#7
    audio_note $43, $0B, $4                            ;; 04:5db7  ; G#7
    audio_note $43, $0B, $4                            ;; 04:5db9  ; G#7
    audio_note $43, $0B, $6                            ;; 04:5dbb  ; G#7
    audio_note $43, $0B, $6                            ;; 04:5dbd  ; G#7
    audio_note $43, $0B, $8                            ;; 04:5dbf  ; G#7
    audio_note $41, $0B, $8                            ;; 04:5dc1  ; F#7
    audio_end_pattern                                  ;; 04:5dc3

audio_04_5dc4_Pattern25:
; pattern $25
    audio_note $40, $08, $4                            ;; 04:5dc4  ; F7
    audio_note $40, $08, $4                            ;; 04:5dc6  ; F7
    audio_note $43, $08, $4                            ;; 04:5dc8  ; G#7
    audio_note $43, $08, $4                            ;; 04:5dca  ; G#7
    audio_note $41, $08, $4                            ;; 04:5dcc  ; F#7
    audio_note $41, $08, $4                            ;; 04:5dce  ; F#7
    audio_note $45, $08, $6                            ;; 04:5dd0  ; A#7
    audio_note $47, $08, $4                            ;; 04:5dd2  ; C8
    audio_note $45, $08, $4                            ;; 04:5dd4  ; A#7
    audio_note $43, $08, $4                            ;; 04:5dd6  ; G#7
    audio_note $41, $08, $4                            ;; 04:5dd8  ; F#7
    audio_note $40, $08, $4                            ;; 04:5dda  ; F7
    audio_note $3E, $08, $4                            ;; 04:5ddc  ; D#7
    audio_note $3C, $08, $6                            ;; 04:5dde  ; C#7
    audio_note $40, $08, $4                            ;; 04:5de0  ; F7
    audio_note $40, $08, $4                            ;; 04:5de2  ; F7
    audio_note $43, $08, $4                            ;; 04:5de4  ; G#7
    audio_note $40, $08, $4                            ;; 04:5de6  ; F7
    audio_note $41, $08, $4                            ;; 04:5de8  ; F#7
    audio_note $41, $08, $4                            ;; 04:5dea  ; F#7
    audio_note $45, $08, $6                            ;; 04:5dec  ; A#7
    audio_note $47, $08, $5                            ;; 04:5dee  ; C8
    audio_note $45, $08, $2                            ;; 04:5df0  ; A#7
    audio_note $43, $08, $4                            ;; 04:5df2  ; G#7
    audio_note $41, $08, $4                            ;; 04:5df4  ; F#7
    audio_note $40, $08, $4                            ;; 04:5df6  ; F7
    audio_note $3E, $08, $4                            ;; 04:5df8  ; D#7
    audio_note $3C, $08, $6                            ;; 04:5dfa  ; C#7
    audio_end_pattern                                  ;; 04:5dfc

audio_04_5dfd_Pattern26:
; pattern $26
    audio_note $45, $08, $4                            ;; 04:5dfd  ; A#7
    audio_note $45, $08, $4                            ;; 04:5dff  ; A#7
    audio_note $48, $08, $2                            ;; 04:5e01  ; C#8
    audio_note $47, $08, $2                            ;; 04:5e03  ; C8
    audio_note $45, $08, $4                            ;; 04:5e05  ; A#7
    audio_note $43, $08, $4                            ;; 04:5e07  ; G#7
    audio_note $43, $08, $4                            ;; 04:5e09  ; G#7
    audio_note $46, $08, $2                            ;; 04:5e0b  ; B7
    audio_note $45, $08, $2                            ;; 04:5e0d  ; A#7
    audio_note $43, $08, $4                            ;; 04:5e0f  ; G#7
    audio_note $41, $08, $4                            ;; 04:5e11  ; F#7
    audio_note $41, $08, $4                            ;; 04:5e13  ; F#7
    audio_note $45, $08, $2                            ;; 04:5e15  ; A#7
    audio_note $43, $08, $2                            ;; 04:5e17  ; G#7
    audio_note $41, $08, $4                            ;; 04:5e19  ; F#7
    audio_note $40, $08, $4                            ;; 04:5e1b  ; F7
    audio_note $41, $08, $4                            ;; 04:5e1d  ; F#7
    audio_note $43, $08, $6                            ;; 04:5e1f  ; G#7
    audio_note $41, $08, $4                            ;; 04:5e21  ; F#7
    audio_note $40, $08, $2                            ;; 04:5e23  ; F7
    audio_note $3E, $08, $2                            ;; 04:5e25  ; D#7
    audio_note $3C, $08, $4                            ;; 04:5e27  ; C#7
    audio_note $3B, $08, $4                            ;; 04:5e29  ; C7
    audio_note $3C, $08, $4                            ;; 04:5e2b  ; C#7
    audio_note $3E, $08, $4                            ;; 04:5e2d  ; D#7
    audio_note $40, $08, $6                            ;; 04:5e2f  ; F7
    audio_note $42, $08, $5                            ;; 04:5e31  ; G7
    audio_note $43, $08, $2                            ;; 04:5e33  ; G#7
    audio_note $45, $08, $4                            ;; 04:5e35  ; A#7
    audio_note $42, $08, $4                            ;; 04:5e37  ; G7
    audio_note $43, $08, $4                            ;; 04:5e39  ; G#7
    audio_note $41, $08, $4                            ;; 04:5e3b  ; F#7
    audio_note $40, $08, $4                            ;; 04:5e3d  ; F7
    audio_note $3E, $08, $4                            ;; 04:5e3f  ; D#7
    audio_end_pattern                                  ;; 04:5e41

audio_04_5e42_Pattern27:
; pattern $27
    audio_note $47, $09, $2                            ;; 04:5e42  ; C8
    audio_note $45, $09, $2                            ;; 04:5e44  ; A#7
    audio_note $43, $09, $4                            ;; 04:5e46  ; G#7
    audio_note $3E, $09, $4                            ;; 04:5e48  ; D#7
    audio_note $3E, $09, $4                            ;; 04:5e4a  ; D#7
    audio_note $47, $09, $2                            ;; 04:5e4c  ; C8
    audio_note $45, $09, $2                            ;; 04:5e4e  ; A#7
    audio_note $43, $09, $4                            ;; 04:5e50  ; G#7
    audio_note $3E, $09, $4                            ;; 04:5e52  ; D#7
    audio_note $3E, $09, $4                            ;; 04:5e54  ; D#7
    audio_note $47, $09, $2                            ;; 04:5e56  ; C8
    audio_note $45, $09, $2                            ;; 04:5e58  ; A#7
    audio_note $43, $09, $4                            ;; 04:5e5a  ; G#7
    audio_note $47, $09, $2                            ;; 04:5e5c  ; C8
    audio_note $45, $09, $2                            ;; 04:5e5e  ; A#7
    audio_note $43, $09, $4                            ;; 04:5e60  ; G#7
    audio_note $45, $09, $4                            ;; 04:5e62  ; A#7
    audio_note $42, $09, $4                            ;; 04:5e64  ; G7
    audio_note $3E, $09, $6                            ;; 04:5e66  ; D#7
    audio_note $47, $09, $2                            ;; 04:5e68  ; C8
    audio_note $45, $09, $2                            ;; 04:5e6a  ; A#7
    audio_note $43, $09, $4                            ;; 04:5e6c  ; G#7
    audio_note $3E, $09, $4                            ;; 04:5e6e  ; D#7
    audio_note $3E, $09, $4                            ;; 04:5e70  ; D#7
    audio_note $43, $09, $2                            ;; 04:5e72  ; G#7
    audio_note $45, $09, $2                            ;; 04:5e74  ; A#7
    audio_note $47, $09, $2                            ;; 04:5e76  ; C8
    audio_note $48, $09, $2                            ;; 04:5e78  ; C#8
    audio_note $4A, $09, $6                            ;; 04:5e7a  ; D#8
    audio_note $4A, $09, $2                            ;; 04:5e7c  ; D#8
    audio_note $48, $09, $2                            ;; 04:5e7e  ; C#8
    audio_note $47, $09, $2                            ;; 04:5e80  ; C8
    audio_note $48, $09, $2                            ;; 04:5e82  ; C#8
    audio_note $4A, $09, $4                            ;; 04:5e84  ; D#8
    audio_note $48, $09, $2                            ;; 04:5e86  ; C#8
    audio_note $47, $09, $2                            ;; 04:5e88  ; C8
    audio_note $48, $09, $4                            ;; 04:5e8a  ; C#8
    audio_note $45, $09, $4                            ;; 04:5e8c  ; A#7
    audio_note $42, $09, $4                            ;; 04:5e8e  ; G7
    audio_note $3E, $09, $4                            ;; 04:5e90  ; D#7
    audio_end_pattern                                  ;; 04:5e92

audio_04_5e93_Pattern28:
; pattern $28
    audio_note $54, $09, $5                            ;; 04:5e93  ; C#9
    audio_note $53, $09, $2                            ;; 04:5e95  ; C9
    audio_note $51, $09, $4                            ;; 04:5e97  ; A#8
    audio_note $4F, $09, $4                            ;; 04:5e99  ; G#8
    audio_note $4C, $09, $4                            ;; 04:5e9b  ; F8
    audio_note $4A, $09, $4                            ;; 04:5e9d  ; D#8
    audio_note $48, $09, $6                            ;; 04:5e9f  ; C#8
    audio_note $53, $09, $5                            ;; 04:5ea1  ; C9
    audio_note $51, $09, $2                            ;; 04:5ea3  ; A#8
    audio_note $4F, $09, $4                            ;; 04:5ea5  ; G#8
    audio_note $4A, $09, $4                            ;; 04:5ea7  ; D#8
    audio_note $47, $09, $4                            ;; 04:5ea9  ; C8
    audio_note $45, $09, $4                            ;; 04:5eab  ; A#7
    audio_note $43, $09, $6                            ;; 04:5ead  ; G#7
    audio_note $3E, $09, $2                            ;; 04:5eaf  ; D#7
    audio_note $40, $09, $2                            ;; 04:5eb1  ; F7
    audio_note $42, $09, $2                            ;; 04:5eb3  ; G7
    audio_note $43, $09, $2                            ;; 04:5eb5  ; G#7
    audio_note $45, $09, $4                            ;; 04:5eb7  ; A#7
    audio_note $45, $09, $4                            ;; 04:5eb9  ; A#7
    audio_note $3E, $09, $2                            ;; 04:5ebb  ; D#7
    audio_note $40, $09, $2                            ;; 04:5ebd  ; F7
    audio_note $42, $09, $2                            ;; 04:5ebf  ; G7
    audio_note $43, $09, $2                            ;; 04:5ec1  ; G#7
    audio_note $45, $09, $4                            ;; 04:5ec3  ; A#7
    audio_note $45, $09, $4                            ;; 04:5ec5  ; A#7
    audio_note $47, $09, $2                            ;; 04:5ec7  ; C8
    audio_note $45, $09, $2                            ;; 04:5ec9  ; A#7
    audio_note $43, $09, $2                            ;; 04:5ecb  ; G#7
    audio_note $45, $09, $2                            ;; 04:5ecd  ; A#7
    audio_note $47, $09, $4                            ;; 04:5ecf  ; C8
    audio_note $48, $09, $4                            ;; 04:5ed1  ; C#8
    audio_note $4A, $09, $4                            ;; 04:5ed3  ; D#8
    audio_note $47, $09, $4                            ;; 04:5ed5  ; C8
    audio_note $4F, $09, $6                            ;; 04:5ed7  ; G#8
    audio_note $54, $09, $5                            ;; 04:5ed9  ; C#9
    audio_note $53, $09, $2                            ;; 04:5edb  ; C9
    audio_note $51, $09, $4                            ;; 04:5edd  ; A#8
    audio_note $4F, $09, $4                            ;; 04:5edf  ; G#8
    audio_note $4C, $09, $4                            ;; 04:5ee1  ; F8
    audio_note $4A, $09, $4                            ;; 04:5ee3  ; D#8
    audio_note $48, $09, $6                            ;; 04:5ee5  ; C#8
    audio_note $53, $09, $5                            ;; 04:5ee7  ; C9
    audio_note $51, $09, $2                            ;; 04:5ee9  ; A#8
    audio_note $4F, $09, $4                            ;; 04:5eeb  ; G#8
    audio_note $4A, $09, $4                            ;; 04:5eed  ; D#8
    audio_note $47, $09, $4                            ;; 04:5eef  ; C8
    audio_note $45, $09, $4                            ;; 04:5ef1  ; A#7
    audio_note $43, $09, $6                            ;; 04:5ef3  ; G#7
    audio_note $3E, $09, $2                            ;; 04:5ef5  ; D#7
    audio_note $40, $09, $2                            ;; 04:5ef7  ; F7
    audio_note $42, $09, $2                            ;; 04:5ef9  ; G7
    audio_note $43, $09, $2                            ;; 04:5efb  ; G#7
    audio_note $45, $09, $4                            ;; 04:5efd  ; A#7
    audio_note $45, $09, $4                            ;; 04:5eff  ; A#7
    audio_note $45, $09, $2                            ;; 04:5f01  ; A#7
    audio_note $47, $09, $2                            ;; 04:5f03  ; C8
    audio_note $48, $09, $4                            ;; 04:5f05  ; C#8
    audio_note $4A, $09, $4                            ;; 04:5f07  ; D#8
    audio_note $48, $09, $4                            ;; 04:5f09  ; C#8
    audio_note $47, $09, $4                            ;; 04:5f0b  ; C8
    audio_note $45, $09, $4                            ;; 04:5f0d  ; A#7
    audio_note $43, $09, $4                            ;; 04:5f0f  ; G#7
    audio_note $45, $09, $4                            ;; 04:5f11  ; A#7
    audio_note $47, $09, $4                            ;; 04:5f13  ; C8
    audio_note $4A, $09, $4                            ;; 04:5f15  ; D#8
    audio_note $4F, $09, $6                            ;; 04:5f17  ; G#8
    audio_end_pattern                                  ;; 04:5f19

audio_04_5f1a_Pattern29:
; pattern $29
    audio_note $4F, $09, $2                            ;; 04:5f1a  ; G#8
    audio_note $4D, $09, $2                            ;; 04:5f1c  ; F#8
    audio_note $4C, $09, $2                            ;; 04:5f1e  ; F8
    audio_note $4A, $09, $2                            ;; 04:5f20  ; D#8
    audio_note $48, $09, $4                            ;; 04:5f22  ; C#8
    audio_note $4C, $09, $4                            ;; 04:5f24  ; F8
    audio_note $43, $09, $4                            ;; 04:5f26  ; G#7
    audio_note $43, $09, $4                            ;; 04:5f28  ; G#7
    audio_note $43, $09, $6                            ;; 04:5f2a  ; G#7
    audio_note $45, $09, $2                            ;; 04:5f2c  ; A#7
    audio_note $41, $09, $2                            ;; 04:5f2e  ; F#7
    audio_note $45, $09, $2                            ;; 04:5f30  ; A#7
    audio_note $48, $09, $2                            ;; 04:5f32  ; C#8
    audio_note $4D, $09, $4                            ;; 04:5f34  ; F#8
    audio_note $4D, $09, $4                            ;; 04:5f36  ; F#8
    audio_note $4C, $09, $5                            ;; 04:5f38  ; F8
    audio_note $4A, $09, $2                            ;; 04:5f3a  ; D#8
    audio_note $48, $09, $6                            ;; 04:5f3c  ; C#8
    audio_note $4F, $09, $2                            ;; 04:5f3e  ; G#8
    audio_note $4D, $09, $2                            ;; 04:5f40  ; F#8
    audio_note $4C, $09, $2                            ;; 04:5f42  ; F8
    audio_note $4A, $09, $2                            ;; 04:5f44  ; D#8
    audio_note $48, $09, $4                            ;; 04:5f46  ; C#8
    audio_note $4C, $09, $4                            ;; 04:5f48  ; F8
    audio_note $43, $09, $4                            ;; 04:5f4a  ; G#7
    audio_note $43, $09, $4                            ;; 04:5f4c  ; G#7
    audio_note $43, $09, $6                            ;; 04:5f4e  ; G#7
    audio_note $45, $09, $2                            ;; 04:5f50  ; A#7
    audio_note $43, $09, $2                            ;; 04:5f52  ; G#7
    audio_note $42, $09, $2                            ;; 04:5f54  ; G7
    audio_note $43, $09, $2                            ;; 04:5f56  ; G#7
    audio_note $45, $09, $4                            ;; 04:5f58  ; A#7
    audio_note $48, $09, $4                            ;; 04:5f5a  ; C#8
    audio_note $47, $09, $4                            ;; 04:5f5c  ; C8
    audio_note $45, $09, $4                            ;; 04:5f5e  ; A#7
    audio_note $43, $09, $6                            ;; 04:5f60  ; G#7
    audio_end_pattern                                  ;; 04:5f62

audio_04_5f63_Pattern30:
; pattern $30
    audio_note $4F, $09, $2                            ;; 04:5f63  ; G#8
    audio_note $4D, $09, $2                            ;; 04:5f65  ; F#8
    audio_note $4C, $09, $2                            ;; 04:5f67  ; F8
    audio_note $4A, $09, $2                            ;; 04:5f69  ; D#8
    audio_note $48, $09, $4                            ;; 04:5f6b  ; C#8
    audio_note $4C, $09, $4                            ;; 04:5f6d  ; F8
    audio_note $43, $09, $4                            ;; 04:5f6f  ; G#7
    audio_note $43, $09, $4                            ;; 04:5f71  ; G#7
    audio_note $43, $09, $6                            ;; 04:5f73  ; G#7
    audio_note $45, $09, $2                            ;; 04:5f75  ; A#7
    audio_note $41, $09, $2                            ;; 04:5f77  ; F#7
    audio_note $45, $09, $2                            ;; 04:5f79  ; A#7
    audio_note $48, $09, $2                            ;; 04:5f7b  ; C#8
    audio_note $4D, $09, $4                            ;; 04:5f7d  ; F#8
    audio_note $4D, $09, $4                            ;; 04:5f7f  ; F#8
    audio_note $4C, $09, $8                            ;; 04:5f81  ; F8
    audio_note $4A, $09, $5                            ;; 04:5f83  ; D#8
    audio_note $48, $09, $2                            ;; 04:5f85  ; C#8
    audio_note $47, $09, $4                            ;; 04:5f87  ; C8
    audio_note $45, $09, $4                            ;; 04:5f89  ; A#7
    audio_note $43, $09, $4                            ;; 04:5f8b  ; G#7
    audio_note $41, $09, $4                            ;; 04:5f8d  ; F#7
    audio_note $40, $09, $6                            ;; 04:5f8f  ; F7
    audio_note $41, $09, $5                            ;; 04:5f91  ; F#7
    audio_note $40, $09, $2                            ;; 04:5f93  ; F7
    audio_note $3E, $09, $4                            ;; 04:5f95  ; D#7
    audio_note $3B, $09, $4                            ;; 04:5f97  ; C7
    audio_note $3C, $09, $8                            ;; 04:5f99  ; C#7
    audio_end_pattern                                  ;; 04:5f9b

audio_04_5f9c_Pattern2A:
; pattern $2A
    audio_note $39, $09, $5                            ;; 04:5f9c  ; A#6
    audio_note $3D, $09, $2                            ;; 04:5f9e  ; D7
    audio_note $40, $09, $4                            ;; 04:5fa0  ; F7
    audio_note $43, $09, $4                            ;; 04:5fa2  ; G#7
    audio_note $41, $09, $4                            ;; 04:5fa4  ; F#7
    audio_note $40, $09, $4                            ;; 04:5fa6  ; F7
    audio_note $3E, $09, $4                            ;; 04:5fa8  ; D#7
    audio_note $3C, $09, $4                            ;; 04:5faa  ; C#7
    audio_note $3B, $09, $5                            ;; 04:5fac  ; C7
    audio_note $39, $09, $2                            ;; 04:5fae  ; A#6
    audio_note $37, $09, $2                            ;; 04:5fb0  ; G#6
    audio_note $3B, $09, $2                            ;; 04:5fb2  ; C7
    audio_note $3E, $09, $2                            ;; 04:5fb4  ; D#7
    audio_note $41, $09, $2                            ;; 04:5fb6  ; F#7
    audio_note $40, $09, $4                            ;; 04:5fb8  ; F7
    audio_note $3E, $09, $4                            ;; 04:5fba  ; D#7
    audio_note $3C, $09, $6                            ;; 04:5fbc  ; C#7
    audio_note $39, $09, $5                            ;; 04:5fbe  ; A#6
    audio_note $3D, $09, $2                            ;; 04:5fc0  ; D7
    audio_note $40, $09, $4                            ;; 04:5fc2  ; F7
    audio_note $43, $09, $4                            ;; 04:5fc4  ; G#7
    audio_note $41, $09, $4                            ;; 04:5fc6  ; F#7
    audio_note $40, $09, $4                            ;; 04:5fc8  ; F7
    audio_note $3E, $09, $4                            ;; 04:5fca  ; D#7
    audio_note $3C, $09, $4                            ;; 04:5fcc  ; C#7
    audio_note $3B, $09, $5                            ;; 04:5fce  ; C7
    audio_note $39, $09, $2                            ;; 04:5fd0  ; A#6
    audio_note $37, $09, $4                            ;; 04:5fd2  ; G#6
    audio_note $35, $09, $4                            ;; 04:5fd4  ; F#6
    audio_note $34, $09, $4                            ;; 04:5fd6  ; F6
    audio_note $32, $09, $4                            ;; 04:5fd8  ; D#6
    audio_note $30, $09, $6                            ;; 04:5fda  ; C#6
    audio_end_pattern                                  ;; 04:5fdc

audio_04_5fdd_Pattern20:
; pattern $20
    audio_note $3B, $0B, $6                            ;; 04:5fdd  ; C7
    audio_note $3B, $0B, $4                            ;; 04:5fdf  ; C7
    audio_note $3B, $0B, $4                            ;; 04:5fe1  ; C7
    audio_note $3B, $0B, $6                            ;; 04:5fe3  ; C7
    audio_note $3B, $0B, $6                            ;; 04:5fe5  ; C7
    audio_note $3B, $0B, $A                            ;; 04:5fe7  ; C7
    audio_end_pattern                                  ;; 04:5fe9

audio_04_5fea_Pattern21:
; pattern $21
    audio_note $3C, $08, $4                            ;; 04:5fea  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5fec  ; C#7
    audio_note $40, $08, $4                            ;; 04:5fee  ; F7
    audio_note $40, $08, $4                            ;; 04:5ff0  ; F7
    audio_note $3C, $08, $4                            ;; 04:5ff2  ; C#7
    audio_note $3C, $08, $4                            ;; 04:5ff4  ; C#7
    audio_note $42, $08, $6                            ;; 04:5ff6  ; G7
    audio_note $3E, $08, $4                            ;; 04:5ff8  ; D#7
    audio_note $3C, $08, $4                            ;; 04:5ffa  ; C#7
    audio_note $3B, $08, $4                            ;; 04:5ffc  ; C7
    audio_note $39, $08, $4                            ;; 04:5ffe  ; A#6
    audio_note $37, $08, $4                            ;; 04:6000  ; G#6
    audio_note $35, $08, $4                            ;; 04:6002  ; F#6
    audio_note $34, $08, $6                            ;; 04:6004  ; F6
    audio_note $3C, $08, $4                            ;; 04:6006  ; C#7
    audio_note $3C, $08, $4                            ;; 04:6008  ; C#7
    audio_note $40, $08, $4                            ;; 04:600a  ; F7
    audio_note $3C, $08, $4                            ;; 04:600c  ; C#7
    audio_note $3C, $08, $4                            ;; 04:600e  ; C#7
    audio_note $3C, $08, $4                            ;; 04:6010  ; C#7
    audio_note $42, $08, $6                            ;; 04:6012  ; G7
    audio_note $3E, $08, $5                            ;; 04:6014  ; D#7
    audio_note $3C, $08, $2                            ;; 04:6016  ; C#7
    audio_note $3B, $08, $4                            ;; 04:6018  ; C7
    audio_note $39, $08, $4                            ;; 04:601a  ; A#6
    audio_note $37, $08, $4                            ;; 04:601c  ; G#6
    audio_note $35, $08, $4                            ;; 04:601e  ; F#6
    audio_note $34, $08, $6                            ;; 04:6020  ; F6
    audio_end_pattern                                  ;; 04:6022

audio_04_6023_Pattern22:
; pattern $22
    audio_note $41, $08, $4                            ;; 04:6023  ; F#7
    audio_note $41, $08, $4                            ;; 04:6025  ; F#7
    audio_note $42, $08, $6                            ;; 04:6027  ; G7
    audio_note $40, $08, $4                            ;; 04:6029  ; F7
    audio_note $40, $08, $4                            ;; 04:602b  ; F7
    audio_note $3D, $08, $6                            ;; 04:602d  ; D7
    audio_note $3E, $08, $4                            ;; 04:602f  ; D#7
    audio_note $3E, $08, $4                            ;; 04:6031  ; D#7
    audio_note $3B, $08, $6                            ;; 04:6033  ; C7
    audio_note $3C, $08, $4                            ;; 04:6035  ; C#7
    audio_note $3E, $08, $4                            ;; 04:6037  ; D#7
    audio_note $40, $08, $6                            ;; 04:6039  ; F7
    audio_note $39, $08, $6                            ;; 04:603b  ; A#6
    audio_note $39, $08, $4                            ;; 04:603d  ; A#6
    audio_note $38, $08, $4                            ;; 04:603f  ; A6
    audio_note $39, $08, $4                            ;; 04:6041  ; A#6
    audio_note $3B, $08, $4                            ;; 04:6043  ; C7
    audio_note $3C, $08, $6                            ;; 04:6045  ; C#7
    audio_note $3E, $08, $5                            ;; 04:6047  ; D#7
    audio_note $40, $08, $2                            ;; 04:6049  ; F7
    audio_note $42, $08, $4                            ;; 04:604b  ; G7
    audio_note $3E, $08, $4                            ;; 04:604d  ; D#7
    audio_note $3B, $08, $4                            ;; 04:604f  ; C7
    audio_note $39, $08, $4                            ;; 04:6051  ; A#6
    audio_note $37, $08, $4                            ;; 04:6053  ; G#6
    audio_note $35, $08, $4                            ;; 04:6055  ; F#6
    audio_end_pattern                                  ;; 04:6057

audio_04_6058_Pattern17:
; pattern $17
    audio_note $2B, $12, $8                            ;; 04:6058  ; G#5
    audio_note $2A, $12, $8                            ;; 04:605a  ; G5
    audio_note $28, $12, $8                            ;; 04:605c  ; F5
    audio_note $26, $12, $8                            ;; 04:605e  ; D#5
    audio_note $24, $12, $8                            ;; 04:6060  ; C#5
    audio_note $23, $12, $8                            ;; 04:6062  ; C5
    audio_note $21, $12, $8                            ;; 04:6064  ; A#4
    audio_note $1F, $12, $8                            ;; 04:6066  ; G#4
    audio_end_pattern                                  ;; 04:6068

audio_04_6069_Pattern18:
; pattern $18
    audio_note $1F, $12, $6                            ;; 04:6069  ; G#4
    audio_note $1F, $12, $4                            ;; 04:606b  ; G#4
    audio_note $1F, $12, $4                            ;; 04:606d  ; G#4
    audio_note $1F, $12, $6                            ;; 04:606f  ; G#4
    audio_note $1F, $12, $6                            ;; 04:6071  ; G#4
    audio_note $1F, $12, $A                            ;; 04:6073  ; G#4
    audio_end_pattern                                  ;; 04:6075

audio_04_6076_Pattern19:
; pattern $19
    audio_note $24, $11, $6                            ;; 04:6076  ; C#5
    audio_note $28, $11, $6                            ;; 04:6078  ; F5
    audio_note $29, $11, $6                            ;; 04:607a  ; F#5
    audio_note $2A, $11, $6                            ;; 04:607c  ; G5
    audio_note $2B, $11, $6                            ;; 04:607e  ; G#5
    audio_note $1F, $11, $6                            ;; 04:6080  ; G#4
    audio_note $24, $11, $6                            ;; 04:6082  ; C#5
    audio_note $1F, $11, $6                            ;; 04:6084  ; G#4
    audio_note $24, $11, $6                            ;; 04:6086  ; C#5
    audio_note $28, $11, $6                            ;; 04:6088  ; F5
    audio_note $29, $11, $6                            ;; 04:608a  ; F#5
    audio_note $2A, $11, $6                            ;; 04:608c  ; G5
    audio_note $2B, $11, $6                            ;; 04:608e  ; G#5
    audio_note $1F, $11, $6                            ;; 04:6090  ; G#4
    audio_note $24, $11, $6                            ;; 04:6092  ; C#5
    audio_note $24, $11, $6                            ;; 04:6094  ; C#5
    audio_end_pattern                                  ;; 04:6096

audio_04_6097_Pattern1A:
; pattern $1A
    audio_note $29, $11, $6                            ;; 04:6097  ; F#5
    audio_note $2A, $11, $6                            ;; 04:6099  ; G5
    audio_note $2B, $11, $6                            ;; 04:609b  ; G#5
    audio_note $2D, $11, $6                            ;; 04:609d  ; A#5
    audio_note $26, $11, $6                            ;; 04:609f  ; D#5
    audio_note $2B, $11, $6                            ;; 04:60a1  ; G#5
    audio_note $24, $11, $6                            ;; 04:60a3  ; C#5
    audio_note $24, $11, $6                            ;; 04:60a5  ; C#5
    audio_note $26, $11, $6                            ;; 04:60a7  ; D#5
    audio_note $28, $11, $6                            ;; 04:60a9  ; F5
    audio_note $2D, $11, $6                            ;; 04:60ab  ; A#5
    audio_note $2D, $11, $6                            ;; 04:60ad  ; A#5
    audio_note $26, $11, $6                            ;; 04:60af  ; D#5
    audio_note $26, $11, $6                            ;; 04:60b1  ; D#5
    audio_note $2B, $11, $4                            ;; 04:60b3  ; G#5
    audio_note $29, $11, $4                            ;; 04:60b5  ; F#5
    audio_note $28, $11, $4                            ;; 04:60b7  ; F5
    audio_note $26, $11, $4                            ;; 04:60b9  ; D#5
    audio_end_pattern                                  ;; 04:60bb

audio_04_60bc_Pattern1B:
; pattern $1B
    audio_note $2B, $11, $6                            ;; 04:60bc  ; G#5
    audio_note $26, $11, $6                            ;; 04:60be  ; D#5
    audio_note $2B, $11, $6                            ;; 04:60c0  ; G#5
    audio_note $26, $11, $6                            ;; 04:60c2  ; D#5
    audio_end_pattern                                  ;; 04:60c4

audio_04_60c5_Pattern1C:
; pattern $1C
    audio_note $2B, $11, $6                            ;; 04:60c5  ; G#5
    audio_note $26, $11, $6                            ;; 04:60c7  ; D#5
    audio_note $2D, $11, $6                            ;; 04:60c9  ; A#5
    audio_note $26, $11, $6                            ;; 04:60cb  ; D#5
    audio_end_pattern                                  ;; 04:60cd

audio_04_60ce_Pattern1D:
; pattern $1D
    audio_note $2B, $11, $6                            ;; 04:60ce  ; G#5
    audio_note $26, $11, $6                            ;; 04:60d0  ; D#5
    audio_note $2B, $11, $6                            ;; 04:60d2  ; G#5
    audio_note $26, $11, $6                            ;; 04:60d4  ; D#5
    audio_end_pattern                                  ;; 04:60d6

audio_04_60d7_Pattern1E:
; pattern $1E
    audio_note $24, $11, $6                            ;; 04:60d7  ; C#5
    audio_note $1F, $11, $6                            ;; 04:60d9  ; G#4
    audio_note $24, $11, $6                            ;; 04:60db  ; C#5
    audio_note $24, $11, $6                            ;; 04:60dd  ; C#5
    audio_note $29, $11, $6                            ;; 04:60df  ; F#5
    audio_note $29, $11, $6                            ;; 04:60e1  ; F#5
    audio_note $24, $11, $6                            ;; 04:60e3  ; C#5
    audio_note $1F, $11, $6                            ;; 04:60e5  ; G#4
    audio_note $24, $11, $6                            ;; 04:60e7  ; C#5
    audio_note $1F, $11, $6                            ;; 04:60e9  ; G#4
    audio_note $24, $11, $6                            ;; 04:60eb  ; C#5
    audio_note $1F, $11, $6                            ;; 04:60ed  ; G#4
    audio_note $26, $11, $6                            ;; 04:60ef  ; D#5
    audio_note $21, $11, $6                            ;; 04:60f1  ; A#4
    audio_note $2B, $11, $6                            ;; 04:60f3  ; G#5
    audio_note $26, $11, $6                            ;; 04:60f5  ; D#5
    audio_note $24, $11, $6                            ;; 04:60f7  ; C#5
    audio_note $1F, $11, $6                            ;; 04:60f9  ; G#4
    audio_note $24, $11, $6                            ;; 04:60fb  ; C#5
    audio_note $28, $11, $6                            ;; 04:60fd  ; F5
    audio_note $29, $11, $6                            ;; 04:60ff  ; F#5
    audio_note $29, $11, $6                            ;; 04:6101  ; F#5
    audio_note $28, $11, $6                            ;; 04:6103  ; F5
    audio_note $28, $11, $6                            ;; 04:6105  ; F5
    audio_note $29, $11, $6                            ;; 04:6107  ; F#5
    audio_note $29, $11, $6                            ;; 04:6109  ; F#5
    audio_note $24, $11, $6                            ;; 04:610b  ; C#5
    audio_note $21, $11, $6                            ;; 04:610d  ; A#4
    audio_note $26, $11, $6                            ;; 04:610f  ; D#5
    audio_note $2B, $11, $6                            ;; 04:6111  ; G#5
    audio_note $24, $11, $6                            ;; 04:6113  ; C#5
    audio_note $1F, $11, $6                            ;; 04:6115  ; G#4
    audio_end_pattern                                  ;; 04:6117

audio_04_6118_Pattern1F:
; pattern $1F
    audio_note $21, $11, $6                            ;; 04:6118  ; A#4
    audio_note $28, $11, $6                            ;; 04:611a  ; F5
    audio_note $26, $11, $6                            ;; 04:611c  ; D#5
    audio_note $26, $11, $6                            ;; 04:611e  ; D#5
    audio_note $1F, $11, $6                            ;; 04:6120  ; G#4
    audio_note $26, $11, $6                            ;; 04:6122  ; D#5
    audio_note $24, $11, $6                            ;; 04:6124  ; C#5
    audio_note $1F, $11, $4                            ;; 04:6126  ; G#4
    audio_note $23, $11, $4                            ;; 04:6128  ; C5
    audio_note $21, $11, $6                            ;; 04:612a  ; A#4
    audio_note $21, $11, $6                            ;; 04:612c  ; A#4
    audio_note $26, $11, $6                            ;; 04:612e  ; D#5
    audio_note $26, $11, $6                            ;; 04:6130  ; D#5
    audio_note $1F, $11, $6                            ;; 04:6132  ; G#4
    audio_note $1F, $11, $6                            ;; 04:6134  ; G#4
    audio_note $24, $11, $6                            ;; 04:6136  ; C#5
    audio_note $1F, $11, $6                            ;; 04:6138  ; G#4
    audio_end_pattern                                  ;; 04:613a

audio_04_613b_Pattern16:
; pattern $16
    audio_note $18, $01, $2                            ;; 04:613b  ; C#4
    audio_note $1E, $03, $2                            ;; 04:613d  ; G4
    audio_note $1E, $03, $2                            ;; 04:613f  ; G4
    audio_note $18, $01, $2                            ;; 04:6141  ; C#4
    audio_note $1A, $02, $4                            ;; 04:6143  ; D#4
    audio_note $1E, $03, $4                            ;; 04:6145  ; G4
    audio_note $18, $01, $2                            ;; 04:6147  ; C#4
    audio_note $1E, $03, $2                            ;; 04:6149  ; G4
    audio_note $18, $01, $2                            ;; 04:614b  ; C#4
    audio_note $1E, $03, $2                            ;; 04:614d  ; G4
    audio_note $1A, $02, $4                            ;; 04:614f  ; D#4
    audio_note $22, $06, $4                            ;; 04:6151  ; B4
    audio_note $18, $01, $2                            ;; 04:6153  ; C#4
    audio_note $1E, $03, $2                            ;; 04:6155  ; G4
    audio_note $1E, $03, $2                            ;; 04:6157  ; G4
    audio_note $18, $01, $2                            ;; 04:6159  ; C#4
    audio_note $1A, $02, $4                            ;; 04:615b  ; D#4
    audio_note $1E, $03, $4                            ;; 04:615d  ; G4
    audio_note $18, $01, $2                            ;; 04:615f  ; C#4
    audio_note $1E, $03, $2                            ;; 04:6161  ; G4
    audio_note $18, $01, $2                            ;; 04:6163  ; C#4
    audio_note $1E, $03, $2                            ;; 04:6165  ; G4
    audio_note $1A, $02, $2                            ;; 04:6167  ; D#4
    audio_note $1E, $03, $2                            ;; 04:6169  ; G4
    audio_note $18, $01, $2                            ;; 04:616b  ; C#4
    audio_note $1E, $03, $2                            ;; 04:616d  ; G4
    audio_note $18, $01, $2                            ;; 04:616f  ; C#4
    audio_note $1E, $03, $2                            ;; 04:6171  ; G4
    audio_note $1E, $03, $2                            ;; 04:6173  ; G4
    audio_note $18, $01, $2                            ;; 04:6175  ; C#4
    audio_note $1A, $02, $4                            ;; 04:6177  ; D#4
    audio_note $18, $01, $2                            ;; 04:6179  ; C#4
    audio_note $1E, $03, $2                            ;; 04:617b  ; G4
    audio_note $18, $01, $4                            ;; 04:617d  ; C#4
    audio_note $1E, $03, $2                            ;; 04:617f  ; G4
    audio_note $1E, $03, $2                            ;; 04:6181  ; G4
    audio_note $1A, $02, $4                            ;; 04:6183  ; D#4
    audio_note $1E, $03, $2                            ;; 04:6185  ; G4
    audio_note $1E, $03, $2                            ;; 04:6187  ; G4
    audio_note $18, $01, $2                            ;; 04:6189  ; C#4
    audio_note $1E, $03, $2                            ;; 04:618b  ; G4
    audio_note $1E, $03, $2                            ;; 04:618d  ; G4
    audio_note $18, $01, $2                            ;; 04:618f  ; C#4
    audio_note $1A, $02, $2                            ;; 04:6191  ; D#4
    audio_note $1E, $03, $2                            ;; 04:6193  ; G4
    audio_note $18, $01, $2                            ;; 04:6195  ; C#4
    audio_note $1E, $03, $2                            ;; 04:6197  ; G4
    audio_note $18, $01, $4                            ;; 04:6199  ; C#4
    audio_note $1E, $03, $2                            ;; 04:619b  ; G4
    audio_note $1E, $03, $2                            ;; 04:619d  ; G4
    audio_note $1A, $02, $4                            ;; 04:619f  ; D#4
    audio_note $22, $06, $4                            ;; 04:61a1  ; B4
    audio_end_pattern                                  ;; 04:61a3

audio_04_61a4_Song_WesternStation_Ch1:
; SONG_WESTERN_STATION (song $03) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 04:61a4
    audio_tempo $A4                                    ;; 04:61a6
    audio_call $00, $00, 4                             ;; 04:61a8
    audio_call $3D, $E3, 2                             ;; 04:61ac
    audio_call $3E, $E3, 1                             ;; 04:61b0
    audio_call $3D, $E3, 1                             ;; 04:61b4
    audio_call $3D, $E5, 1                             ;; 04:61b8
    audio_call $3E, $E5, 1                             ;; 04:61bc
    audio_call $3F, $EF, 1                             ;; 04:61c0
    audio_call $40, $E3, 1                             ;; 04:61c4
    audio_call $41, $E3, 1                             ;; 04:61c8
    audio_call $3E, $E3, 1                             ;; 04:61cc
    audio_call $42, $E3, 1                             ;; 04:61d0
    audio_marker $01                                   ;; 04:61d4
    audio_goto audio_04_61a4_Song_WesternStation_Ch1   ;; 04:61d6

audio_04_61d9_Song_WesternStation_Ch2:
; SONG_WESTERN_STATION (song $03) channel 2
; AUDIO_CMD_GOTO target
    audio_call $43, $FB, 3                             ;; 04:61d9
    audio_call $44, $FB, 2                             ;; 04:61dd
    audio_call $45, $FB, 1                             ;; 04:61e1
    audio_call $46, $FB, 1                             ;; 04:61e5
    audio_call $45, $FB, 1                             ;; 04:61e9
    audio_call $47, $FB, 1                             ;; 04:61ed
    audio_call $45, $FB, 2                             ;; 04:61f1
    audio_call $43, $FB, 1                             ;; 04:61f5
    audio_call $43, $FD, 1                             ;; 04:61f9
    audio_call $44, $FD, 2                             ;; 04:61fd
    audio_call $45, $FD, 1                             ;; 04:6201
    audio_call $46, $FD, 1                             ;; 04:6205
    audio_call $45, $FD, 1                             ;; 04:6209
    audio_call $47, $FD, 1                             ;; 04:620d
    audio_call $45, $FD, 2                             ;; 04:6211
    audio_call $48, $07, 2                             ;; 04:6215
    audio_call $49, $FB, 2                             ;; 04:6219
    audio_call $4A, $FB, 3                             ;; 04:621d
    audio_call $44, $FB, 2                             ;; 04:6221
    audio_call $45, $FB, 1                             ;; 04:6225
    audio_call $46, $FB, 1                             ;; 04:6229
    audio_call $45, $FB, 1                             ;; 04:622d
    audio_call $47, $FB, 1                             ;; 04:6231
    audio_call $45, $FB, 2                             ;; 04:6235
    audio_call $4B, $FB, 2                             ;; 04:6239
    audio_goto audio_04_61d9_Song_WesternStation_Ch2   ;; 04:623d

audio_04_6240_Song_WesternStation_Ch3:
; SONG_WESTERN_STATION (song $03) channel 3
; AUDIO_CMD_GOTO target
    audio_call $37, $EF, 3                             ;; 04:6240
    audio_call $38, $EF, 1                             ;; 04:6244
    audio_call $37, $EF, 1                             ;; 04:6248
    audio_call $37, $F1, 1                             ;; 04:624c
    audio_call $38, $F1, 1                             ;; 04:6250
    audio_call $39, $EF, 2                             ;; 04:6254
    audio_call $3A, $EF, 2                             ;; 04:6258
    audio_call $3B, $EF, 3                             ;; 04:625c
    audio_call $38, $EF, 1                             ;; 04:6260
    audio_call $3C, $EF, 2                             ;; 04:6264
    audio_goto audio_04_6240_Song_WesternStation_Ch3   ;; 04:6268

audio_04_626b_Song_WesternStation_Ch4:
; SONG_WESTERN_STATION (song $03) channel 4
; AUDIO_CMD_GOTO target
    audio_call $36, $00, 38                            ;; 04:626b
    audio_goto audio_04_626b_Song_WesternStation_Ch4   ;; 04:626f

audio_04_6272_Pattern43:
; pattern $43
    audio_note $21, $18, $5                            ;; 04:6272  ; A#4
    audio_note $21, $18, $4                            ;; 04:6274  ; A#4
    audio_note $21, $18, $2                            ;; 04:6276  ; A#4
    audio_note $21, $18, $5                            ;; 04:6278  ; A#4
    audio_note $21, $18, $2                            ;; 04:627a  ; A#4
    audio_note $21, $18, $4                            ;; 04:627c  ; A#4
    audio_note $21, $18, $4                            ;; 04:627e  ; A#4
    audio_note $21, $18, $4                            ;; 04:6280  ; A#4
    audio_note $1F, $15, $5                            ;; 04:6282  ; G#4
    audio_note $1F, $15, $4                            ;; 04:6284  ; G#4
    audio_note $1F, $15, $2                            ;; 04:6286  ; G#4
    audio_note $1F, $15, $5                            ;; 04:6288  ; G#4
    audio_note $1F, $15, $2                            ;; 04:628a  ; G#4
    audio_note $1F, $15, $4                            ;; 04:628c  ; G#4
    audio_note $1F, $15, $4                            ;; 04:628e  ; G#4
    audio_note $1F, $15, $4                            ;; 04:6290  ; G#4
    audio_note $1D, $15, $5                            ;; 04:6292  ; F#4
    audio_note $1D, $15, $4                            ;; 04:6294  ; F#4
    audio_note $1D, $15, $2                            ;; 04:6296  ; F#4
    audio_note $1D, $15, $5                            ;; 04:6298  ; F#4
    audio_note $1D, $15, $2                            ;; 04:629a  ; F#4
    audio_note $1D, $15, $4                            ;; 04:629c  ; F#4
    audio_note $1D, $15, $4                            ;; 04:629e  ; F#4
    audio_note $1D, $15, $4                            ;; 04:62a0  ; F#4
    audio_note $28, $16, $5                            ;; 04:62a2  ; F5
    audio_note $28, $16, $4                            ;; 04:62a4  ; F5
    audio_note $28, $16, $2                            ;; 04:62a6  ; F5
    audio_note $28, $16, $5                            ;; 04:62a8  ; F5
    audio_note $28, $16, $2                            ;; 04:62aa  ; F5
    audio_note $28, $16, $4                            ;; 04:62ac  ; F5
    audio_note $28, $16, $4                            ;; 04:62ae  ; F5
    audio_note $28, $16, $4                            ;; 04:62b0  ; F5
    audio_end_pattern                                  ;; 04:62b2

audio_04_62b3_Pattern44:
; pattern $44
    audio_note $21, $18, $4                            ;; 04:62b3  ; A#4
    audio_note $21, $18, $2                            ;; 04:62b5  ; A#4
    audio_note $21, $18, $4                            ;; 04:62b7  ; A#4
    audio_note $21, $18, $2                            ;; 04:62b9  ; A#4
    audio_note $21, $18, $5                            ;; 04:62bb  ; A#4
    audio_note $21, $18, $2                            ;; 04:62bd  ; A#4
    audio_note $21, $18, $4                            ;; 04:62bf  ; A#4
    audio_note $21, $18, $4                            ;; 04:62c1  ; A#4
    audio_note $21, $18, $4                            ;; 04:62c3  ; A#4
    audio_note $24, $14, $4                            ;; 04:62c5  ; C#5
    audio_note $24, $14, $2                            ;; 04:62c7  ; C#5
    audio_note $24, $14, $4                            ;; 04:62c9  ; C#5
    audio_note $24, $14, $2                            ;; 04:62cb  ; C#5
    audio_note $24, $14, $5                            ;; 04:62cd  ; C#5
    audio_note $24, $14, $2                            ;; 04:62cf  ; C#5
    audio_note $24, $14, $4                            ;; 04:62d1  ; C#5
    audio_note $24, $14, $4                            ;; 04:62d3  ; C#5
    audio_note $24, $14, $4                            ;; 04:62d5  ; C#5
    audio_end_pattern                                  ;; 04:62d7

audio_04_62d8_Pattern45:
; pattern $45
    audio_note $28, $16, $4                            ;; 04:62d8  ; F5
    audio_note $28, $16, $2                            ;; 04:62da  ; F5
    audio_note $28, $16, $4                            ;; 04:62dc  ; F5
    audio_note $28, $16, $2                            ;; 04:62de  ; F5
    audio_note $28, $16, $5                            ;; 04:62e0  ; F5
    audio_note $28, $16, $2                            ;; 04:62e2  ; F5
    audio_note $28, $16, $4                            ;; 04:62e4  ; F5
    audio_note $28, $16, $4                            ;; 04:62e6  ; F5
    audio_note $28, $16, $4                            ;; 04:62e8  ; F5
    audio_end_pattern                                  ;; 04:62ea

audio_04_62eb_Pattern46:
; pattern $46
    audio_note $29, $13, $4                            ;; 04:62eb  ; F#5
    audio_note $29, $13, $2                            ;; 04:62ed  ; F#5
    audio_note $29, $13, $4                            ;; 04:62ef  ; F#5
    audio_note $29, $13, $2                            ;; 04:62f1  ; F#5
    audio_note $29, $13, $5                            ;; 04:62f3  ; F#5
    audio_note $29, $13, $2                            ;; 04:62f5  ; F#5
    audio_note $29, $13, $4                            ;; 04:62f7  ; F#5
    audio_note $29, $13, $4                            ;; 04:62f9  ; F#5
    audio_note $29, $13, $4                            ;; 04:62fb  ; F#5
    audio_end_pattern                                  ;; 04:62fd

audio_04_62fe_Pattern47:
; pattern $47
    audio_note $21, $18, $4                            ;; 04:62fe  ; A#4
    audio_note $21, $18, $2                            ;; 04:6300  ; A#4
    audio_note $21, $18, $4                            ;; 04:6302  ; A#4
    audio_note $21, $18, $2                            ;; 04:6304  ; A#4
    audio_note $21, $18, $5                            ;; 04:6306  ; A#4
    audio_note $21, $18, $2                            ;; 04:6308  ; A#4
    audio_note $21, $18, $4                            ;; 04:630a  ; A#4
    audio_note $21, $18, $4                            ;; 04:630c  ; A#4
    audio_note $21, $18, $4                            ;; 04:630e  ; A#4
    audio_end_pattern                                  ;; 04:6310

audio_04_6311_Pattern48:
; pattern $48
    audio_note $1A, $14, $5                            ;; 04:6311  ; D#4
    audio_note $1A, $14, $4                            ;; 04:6313  ; D#4
    audio_note $1A, $14, $2                            ;; 04:6315  ; D#4
    audio_note $1A, $14, $5                            ;; 04:6317  ; D#4
    audio_note $1A, $14, $2                            ;; 04:6319  ; D#4
    audio_note $1A, $14, $2                            ;; 04:631b  ; D#4
    audio_note $1A, $14, $2                            ;; 04:631d  ; D#4
    audio_note $1A, $14, $4                            ;; 04:631f  ; D#4
    audio_note $1A, $14, $4                            ;; 04:6321  ; D#4
    audio_note $1E, $16, $5                            ;; 04:6323  ; G4
    audio_note $1E, $16, $4                            ;; 04:6325  ; G4
    audio_note $1E, $16, $2                            ;; 04:6327  ; G4
    audio_note $1E, $16, $5                            ;; 04:6329  ; G4
    audio_note $1E, $16, $2                            ;; 04:632b  ; G4
    audio_note $1E, $16, $2                            ;; 04:632d  ; G4
    audio_note $1E, $16, $2                            ;; 04:632f  ; G4
    audio_note $1E, $16, $4                            ;; 04:6331  ; G4
    audio_note $1E, $16, $4                            ;; 04:6333  ; G4
    audio_note $19, $17, $5                            ;; 04:6335  ; D4
    audio_note $19, $17, $4                            ;; 04:6337  ; D4
    audio_note $19, $17, $2                            ;; 04:6339  ; D4
    audio_note $19, $17, $5                            ;; 04:633b  ; D4
    audio_note $19, $17, $2                            ;; 04:633d  ; D4
    audio_note $19, $17, $2                            ;; 04:633f  ; D4
    audio_note $19, $17, $2                            ;; 04:6341  ; D4
    audio_note $19, $17, $4                            ;; 04:6343  ; D4
    audio_note $19, $17, $4                            ;; 04:6345  ; D4
    audio_note $1E, $16, $5                            ;; 04:6347  ; G4
    audio_note $1E, $16, $4                            ;; 04:6349  ; G4
    audio_note $1E, $16, $2                            ;; 04:634b  ; G4
    audio_note $1E, $16, $5                            ;; 04:634d  ; G4
    audio_note $1E, $16, $2                            ;; 04:634f  ; G4
    audio_note $1E, $16, $2                            ;; 04:6351  ; G4
    audio_note $1E, $16, $2                            ;; 04:6353  ; G4
    audio_note $1E, $16, $4                            ;; 04:6355  ; G4
    audio_note $1E, $16, $4                            ;; 04:6357  ; G4
    audio_end_pattern                                  ;; 04:6359

audio_04_635a_Pattern49:
; pattern $49
    audio_note $23, $18, $5                            ;; 04:635a  ; C5
    audio_note $23, $18, $4                            ;; 04:635c  ; C5
    audio_note $23, $18, $2                            ;; 04:635e  ; C5
    audio_note $23, $18, $5                            ;; 04:6360  ; C5
    audio_note $23, $18, $2                            ;; 04:6362  ; C5
    audio_note $23, $18, $2                            ;; 04:6364  ; C5
    audio_note $23, $1B, $2                            ;; 04:6366  ; C5
    audio_note $23, $18, $4                            ;; 04:6368  ; C5
    audio_note $23, $18, $4                            ;; 04:636a  ; C5
    audio_note $28, $13, $5                            ;; 04:636c  ; F5
    audio_note $28, $13, $4                            ;; 04:636e  ; F5
    audio_note $28, $13, $2                            ;; 04:6370  ; F5
    audio_note $28, $13, $5                            ;; 04:6372  ; F5
    audio_note $28, $13, $2                            ;; 04:6374  ; F5
    audio_note $28, $13, $2                            ;; 04:6376  ; F5
    audio_note $28, $13, $2                            ;; 04:6378  ; F5
    audio_note $28, $13, $4                            ;; 04:637a  ; F5
    audio_note $28, $13, $4                            ;; 04:637c  ; F5
    audio_end_pattern                                  ;; 04:637e

audio_04_637f_Pattern4A:
; pattern $4A
    audio_note $21, $18, $5                            ;; 04:637f  ; A#4
    audio_note $21, $18, $4                            ;; 04:6381  ; A#4
    audio_note $21, $18, $2                            ;; 04:6383  ; A#4
    audio_note $21, $18, $5                            ;; 04:6385  ; A#4
    audio_note $21, $18, $2                            ;; 04:6387  ; A#4
    audio_note $21, $18, $2                            ;; 04:6389  ; A#4
    audio_note $21, $1B, $2                            ;; 04:638b  ; A#4
    audio_note $21, $18, $4                            ;; 04:638d  ; A#4
    audio_note $21, $18, $4                            ;; 04:638f  ; A#4
    audio_note $28, $16, $5                            ;; 04:6391  ; F5
    audio_note $28, $16, $4                            ;; 04:6393  ; F5
    audio_note $28, $16, $2                            ;; 04:6395  ; F5
    audio_note $28, $16, $5                            ;; 04:6397  ; F5
    audio_note $28, $16, $2                            ;; 04:6399  ; F5
    audio_note $28, $16, $2                            ;; 04:639b  ; F5
    audio_note $28, $16, $2                            ;; 04:639d  ; F5
    audio_note $28, $16, $4                            ;; 04:639f  ; F5
    audio_note $28, $16, $4                            ;; 04:63a1  ; F5
    audio_note $26, $13, $5                            ;; 04:63a3  ; D#5
    audio_note $26, $13, $4                            ;; 04:63a5  ; D#5
    audio_note $26, $13, $2                            ;; 04:63a7  ; D#5
    audio_note $26, $13, $5                            ;; 04:63a9  ; D#5
    audio_note $26, $13, $2                            ;; 04:63ab  ; D#5
    audio_note $26, $13, $2                            ;; 04:63ad  ; D#5
    audio_note $26, $13, $2                            ;; 04:63af  ; D#5
    audio_note $26, $13, $4                            ;; 04:63b1  ; D#5
    audio_note $26, $13, $4                            ;; 04:63b3  ; D#5
    audio_note $28, $13, $5                            ;; 04:63b5  ; F5
    audio_note $28, $13, $4                            ;; 04:63b7  ; F5
    audio_note $28, $13, $2                            ;; 04:63b9  ; F5
    audio_note $28, $13, $5                            ;; 04:63bb  ; F5
    audio_note $28, $13, $2                            ;; 04:63bd  ; F5
    audio_note $28, $13, $2                            ;; 04:63bf  ; F5
    audio_note $28, $13, $2                            ;; 04:63c1  ; F5
    audio_note $28, $13, $4                            ;; 04:63c3  ; F5
    audio_note $28, $13, $4                            ;; 04:63c5  ; F5
    audio_end_pattern                                  ;; 04:63c7

audio_04_63c8_Pattern4B:
; pattern $4B
    audio_note $21, $18, $5                            ;; 04:63c8  ; A#4
    audio_note $21, $18, $4                            ;; 04:63ca  ; A#4
    audio_note $21, $18, $2                            ;; 04:63cc  ; A#4
    audio_note $21, $18, $5                            ;; 04:63ce  ; A#4
    audio_note $21, $18, $2                            ;; 04:63d0  ; A#4
    audio_note $21, $18, $4                            ;; 04:63d2  ; A#4
    audio_note $21, $18, $4                            ;; 04:63d4  ; A#4
    audio_note $21, $18, $4                            ;; 04:63d6  ; A#4
    audio_end_pattern                                  ;; 04:63d8

audio_04_63d9_Pattern3D:
; pattern $3D
    audio_note $51, $0F, $2                            ;; 04:63d9  ; A#8
    audio_note $4C, $0F, $2                            ;; 04:63db  ; F8
    audio_note $51, $0F, $2                            ;; 04:63dd  ; A#8
    audio_note $4C, $0F, $2                            ;; 04:63df  ; F8
    audio_note $51, $0F, $8                            ;; 04:63e1  ; A#8
    audio_note $54, $0F, $6                            ;; 04:63e3  ; C#9
    audio_note $53, $0F, $5                            ;; 04:63e5  ; C9
    audio_note $51, $0F, $2                            ;; 04:63e7  ; A#8
    audio_note $4F, $0F, $9                            ;; 04:63e9  ; G#8
    audio_note $51, $0F, $2                            ;; 04:63eb  ; A#8
    audio_note $4D, $0F, $2                            ;; 04:63ed  ; F#8
    audio_note $51, $0F, $2                            ;; 04:63ef  ; A#8
    audio_note $4D, $0F, $2                            ;; 04:63f1  ; F#8
    audio_note $51, $0F, $8                            ;; 04:63f3  ; A#8
    audio_note $54, $0F, $6                            ;; 04:63f5  ; C#9
    audio_note $53, $0F, $5                            ;; 04:63f7  ; C9
    audio_note $51, $0F, $2                            ;; 04:63f9  ; A#8
    audio_note $4F, $0F, $8                            ;; 04:63fb  ; G#8
    audio_note $4C, $0F, $6                            ;; 04:63fd  ; F8
    audio_end_pattern                                  ;; 04:63ff

audio_04_6400_Pattern3E:
; pattern $3E
    audio_note $45, $0F, $6                            ;; 04:6400  ; A#7
    audio_note $4C, $0F, $8                            ;; 04:6402  ; F8
    audio_note $48, $0F, $6                            ;; 04:6404  ; C#8
    audio_note $4F, $0F, $9                            ;; 04:6406  ; G#8
    audio_note $40, $0F, $6                            ;; 04:6408  ; F7
    audio_note $45, $0F, $5                            ;; 04:640a  ; A#7
    audio_note $4C, $0F, $8                            ;; 04:640c  ; F8
    audio_note $24, $00, $2                            ;; 04:640e  ; C#5
    audio_note $48, $0F, $6                            ;; 04:6410  ; C#8
    audio_note $4F, $0F, $5                            ;; 04:6412  ; G#8
    audio_note $4D, $0F, $2                            ;; 04:6414  ; F#8
    audio_note $4C, $0F, $7                            ;; 04:6416  ; F8
    audio_note $4C, $0F, $6                            ;; 04:6418  ; F8
    audio_note $4F, $0F, $4                            ;; 04:641a  ; G#8
    audio_note $53, $0F, $5                            ;; 04:641c  ; C9
    audio_note $51, $0F, $2                            ;; 04:641e  ; A#8
    audio_note $4F, $0F, $7                            ;; 04:6420  ; G#8
    audio_note $4C, $0F, $4                            ;; 04:6422  ; F8
    audio_note $4F, $0F, $4                            ;; 04:6424  ; G#8
    audio_note $53, $0F, $4                            ;; 04:6426  ; C9
    audio_note $54, $0F, $5                            ;; 04:6428  ; C#9
    audio_note $53, $0F, $2                            ;; 04:642a  ; C9
    audio_note $51, $0F, $8                            ;; 04:642c  ; A#8
    audio_note $53, $0F, $4                            ;; 04:642e  ; C9
    audio_note $54, $0F, $4                            ;; 04:6430  ; C#9
    audio_note $53, $0F, $5                            ;; 04:6432  ; C9
    audio_note $51, $0F, $2                            ;; 04:6434  ; A#8
    audio_note $4F, $0F, $7                            ;; 04:6436  ; G#8
    audio_note $4C, $0F, $4                            ;; 04:6438  ; F8
    audio_note $4F, $0F, $4                            ;; 04:643a  ; G#8
    audio_note $53, $0F, $4                            ;; 04:643c  ; C9
    audio_note $51, $0F, $9                            ;; 04:643e  ; A#8
    audio_note $4F, $0F, $6                            ;; 04:6440  ; G#8
    audio_note $4C, $0F, $A                            ;; 04:6442  ; F8
    audio_note $4F, $0F, $6                            ;; 04:6444  ; G#8
    audio_note $4C, $0F, $6                            ;; 04:6446  ; F8
    audio_note $47, $0F, $6                            ;; 04:6448  ; C8
    audio_note $43, $0F, $6                            ;; 04:644a  ; G#7
    audio_end_pattern                                  ;; 04:644c

audio_04_644d_Pattern3F:
; pattern $3F
    audio_note $4E, $0F, $2                            ;; 04:644d  ; G8
    audio_note $47, $0F, $2                            ;; 04:644f  ; C8
    audio_note $4E, $0F, $2                            ;; 04:6451  ; G8
    audio_note $47, $0F, $2                            ;; 04:6453  ; C8
    audio_note $4E, $0F, $8                            ;; 04:6455  ; G8
    audio_note $4C, $0F, $4                            ;; 04:6457  ; F8
    audio_note $4A, $0F, $4                            ;; 04:6459  ; D#8
    audio_note $49, $0F, $7                            ;; 04:645b  ; D8
    audio_note $47, $0F, $4                            ;; 04:645d  ; C8
    audio_note $45, $0F, $8                            ;; 04:645f  ; A#7
    audio_note $44, $0F, $2                            ;; 04:6461  ; A7
    audio_note $40, $0F, $2                            ;; 04:6463  ; F7
    audio_note $44, $0F, $2                            ;; 04:6465  ; A7
    audio_note $40, $0F, $2                            ;; 04:6467  ; F7
    audio_note $44, $0F, $8                            ;; 04:6469  ; A7
    audio_note $45, $0F, $4                            ;; 04:646b  ; A#7
    audio_note $47, $0F, $4                            ;; 04:646d  ; C8
    audio_note $45, $0F, $4                            ;; 04:646f  ; A#7
    audio_note $42, $0F, $4                            ;; 04:6471  ; G7
    audio_note $45, $0F, $4                            ;; 04:6473  ; A#7
    audio_note $49, $0F, $4                            ;; 04:6475  ; D8
    audio_note $4E, $0F, $4                            ;; 04:6477  ; G8
    audio_note $49, $0F, $4                            ;; 04:6479  ; D8
    audio_note $4E, $0F, $4                            ;; 04:647b  ; G8
    audio_note $51, $0F, $4                            ;; 04:647d  ; A#8
    audio_note $53, $0F, $8                            ;; 04:647f  ; C9
    audio_note $51, $0F, $6                            ;; 04:6481  ; A#8
    audio_note $50, $0F, $6                            ;; 04:6483  ; A8
    audio_note $51, $0F, $2                            ;; 04:6485  ; A#8
    audio_note $50, $0F, $2                            ;; 04:6487  ; A8
    audio_note $4E, $0F, $8                            ;; 04:6489  ; G8
    audio_note $24, $00, $4                            ;; 04:648b  ; C#5
    audio_note $50, $0F, $4                            ;; 04:648d  ; A8
    audio_note $51, $0F, $4                            ;; 04:648f  ; A#8
    audio_note $50, $0F, $4                            ;; 04:6491  ; A8
    audio_note $4E, $0F, $4                            ;; 04:6493  ; G8
    audio_note $4C, $0F, $6                            ;; 04:6495  ; F8
    audio_note $49, $0F, $6                            ;; 04:6497  ; D8
    audio_note $4C, $0F, $6                            ;; 04:6499  ; F8
    audio_note $4E, $0F, $4                            ;; 04:649b  ; G8
    audio_note $49, $0F, $4                            ;; 04:649d  ; D8
    audio_note $4E, $0F, $2                            ;; 04:649f  ; G8
    audio_note $49, $0F, $2                            ;; 04:64a1  ; D8
    audio_note $4E, $0F, $2                            ;; 04:64a3  ; G8
    audio_note $49, $0F, $2                            ;; 04:64a5  ; D8
    audio_note $4E, $0F, $8                            ;; 04:64a7  ; G8
    audio_end_pattern                                  ;; 04:64a9

audio_04_64aa_Pattern40:
; pattern $40
    audio_note $56, $0F, $2                            ;; 04:64aa  ; D#9
    audio_note $53, $0F, $2                            ;; 04:64ac  ; C9
    audio_note $56, $0F, $2                            ;; 04:64ae  ; D#9
    audio_note $53, $0F, $2                            ;; 04:64b0  ; C9
    audio_note $56, $0F, $7                            ;; 04:64b2  ; D#9
    audio_note $53, $0F, $4                            ;; 04:64b4  ; C9
    audio_note $56, $0F, $4                            ;; 04:64b6  ; D#9
    audio_note $53, $0F, $4                            ;; 04:64b8  ; C9
    audio_note $58, $0F, $4                            ;; 04:64ba  ; F9
    audio_note $53, $0F, $4                            ;; 04:64bc  ; C9
    audio_note $50, $0F, $4                            ;; 04:64be  ; A8
    audio_note $4C, $0F, $6                            ;; 04:64c0  ; F8
    audio_note $50, $0F, $4                            ;; 04:64c2  ; A8
    audio_note $53, $0F, $4                            ;; 04:64c4  ; C9
    audio_note $50, $0F, $4                            ;; 04:64c6  ; A8
    audio_note $53, $0F, $2                            ;; 04:64c8  ; C9
    audio_note $56, $0F, $2                            ;; 04:64ca  ; D#9
    audio_note $53, $0F, $2                            ;; 04:64cc  ; C9
    audio_note $56, $0F, $2                            ;; 04:64ce  ; D#9
    audio_note $53, $0F, $2                            ;; 04:64d0  ; C9
    audio_note $56, $0F, $2                            ;; 04:64d2  ; D#9
    audio_note $53, $0F, $2                            ;; 04:64d4  ; C9
    audio_note $56, $0F, $2                            ;; 04:64d6  ; D#9
    audio_note $53, $0F, $7                            ;; 04:64d8  ; C9
    audio_note $56, $0F, $4                            ;; 04:64da  ; D#9
    audio_note $58, $0F, $4                            ;; 04:64dc  ; F9
    audio_note $53, $0F, $4                            ;; 04:64de  ; C9
    audio_note $50, $0F, $4                            ;; 04:64e0  ; A8
    audio_note $4C, $0F, $6                            ;; 04:64e2  ; F8
    audio_note $50, $0F, $4                            ;; 04:64e4  ; A8
    audio_note $53, $0F, $6                            ;; 04:64e6  ; C9
    audio_end_pattern                                  ;; 04:64e8

audio_04_64e9_Pattern41:
; pattern $41
    audio_note $54, $0F, $2                            ;; 04:64e9  ; C#9
    audio_note $51, $0F, $2                            ;; 04:64eb  ; A#8
    audio_note $54, $0F, $2                            ;; 04:64ed  ; C#9
    audio_note $51, $0F, $2                            ;; 04:64ef  ; A#8
    audio_note $58, $0F, $8                            ;; 04:64f1  ; F9
    audio_note $56, $0F, $4                            ;; 04:64f3  ; D#9
    audio_note $54, $0F, $4                            ;; 04:64f5  ; C#9
    audio_note $58, $0F, $4                            ;; 04:64f7  ; F9
    audio_note $53, $0F, $4                            ;; 04:64f9  ; C9
    audio_note $4F, $0F, $6                            ;; 04:64fb  ; G#8
    audio_note $4C, $0F, $8                            ;; 04:64fd  ; F8
    audio_note $4E, $0F, $2                            ;; 04:64ff  ; G8
    audio_note $4A, $0F, $2                            ;; 04:6501  ; D#8
    audio_note $4E, $0F, $2                            ;; 04:6503  ; G8
    audio_note $51, $0F, $2                            ;; 04:6505  ; A#8
    audio_note $56, $0F, $8                            ;; 04:6507  ; D#9
    audio_note $51, $0F, $6                            ;; 04:6509  ; A#8
    audio_note $53, $0F, $A                            ;; 04:650b  ; C9
    audio_note $51, $0F, $2                            ;; 04:650d  ; A#8
    audio_note $4C, $0F, $2                            ;; 04:650f  ; F8
    audio_note $51, $0F, $2                            ;; 04:6511  ; A#8
    audio_note $54, $0F, $2                            ;; 04:6513  ; C#9
    audio_note $58, $0F, $9                            ;; 04:6515  ; F9
    audio_note $5D, $0F, $6                            ;; 04:6517  ; A#9
    audio_note $5B, $0F, $6                            ;; 04:6519  ; G#9
    audio_note $58, $0F, $8                            ;; 04:651b  ; F9
    audio_note $5A, $0F, $2                            ;; 04:651d  ; G9
    audio_note $58, $0F, $2                            ;; 04:651f  ; F9
    audio_note $56, $0F, $8                            ;; 04:6521  ; D#9
    audio_note $51, $0F, $4                            ;; 04:6523  ; A#8
    audio_note $56, $0F, $4                            ;; 04:6525  ; D#9
    audio_note $5A, $0F, $4                            ;; 04:6527  ; G9
    audio_note $58, $0F, $A                            ;; 04:6529  ; F9
    audio_note $51, $0F, $9                            ;; 04:652b  ; A#8
    audio_note $4F, $0F, $4                            ;; 04:652d  ; G#8
    audio_note $51, $0F, $2                            ;; 04:652f  ; A#8
    audio_note $4F, $0F, $2                            ;; 04:6531  ; G#8
    audio_note $4C, $0F, $A                            ;; 04:6533  ; F8
    audio_note $4E, $0F, $2                            ;; 04:6535  ; G8
    audio_note $4A, $0F, $2                            ;; 04:6537  ; D#8
    audio_note $4E, $0F, $2                            ;; 04:6539  ; G8
    audio_note $4A, $0F, $2                            ;; 04:653b  ; D#8
    audio_note $4E, $0F, $2                            ;; 04:653d  ; G8
    audio_note $4A, $0F, $2                            ;; 04:653f  ; D#8
    audio_note $4E, $0F, $2                            ;; 04:6541  ; G8
    audio_note $4A, $0F, $2                            ;; 04:6543  ; D#8
    audio_note $51, $0F, $6                            ;; 04:6545  ; A#8
    audio_note $4E, $0F, $4                            ;; 04:6547  ; G8
    audio_note $4A, $0F, $4                            ;; 04:6549  ; D#8
    audio_note $4C, $0F, $6                            ;; 04:654b  ; F8
    audio_note $50, $0F, $6                            ;; 04:654d  ; A8
    audio_note $53, $0F, $6                            ;; 04:654f  ; C9
    audio_note $50, $0F, $6                            ;; 04:6551  ; A8
    audio_end_pattern                                  ;; 04:6553

audio_04_6554_Pattern42:
; pattern $42
    audio_note $45, $0F, $C                            ;; 04:6554  ; A#7
    audio_end_pattern                                  ;; 04:6556

audio_04_6557_Pattern37:
; pattern $37
    audio_note $21, $11, $5                            ;; 04:6557  ; A#4
    audio_note $21, $11, $4                            ;; 04:6559  ; A#4
    audio_note $21, $11, $2                            ;; 04:655b  ; A#4
    audio_note $21, $11, $5                            ;; 04:655d  ; A#4
    audio_note $21, $11, $2                            ;; 04:655f  ; A#4
    audio_note $21, $11, $4                            ;; 04:6561  ; A#4
    audio_note $21, $11, $4                            ;; 04:6563  ; A#4
    audio_note $21, $11, $4                            ;; 04:6565  ; A#4
    audio_note $1F, $11, $5                            ;; 04:6567  ; G#4
    audio_note $1F, $11, $4                            ;; 04:6569  ; G#4
    audio_note $1F, $11, $2                            ;; 04:656b  ; G#4
    audio_note $1F, $11, $5                            ;; 04:656d  ; G#4
    audio_note $1F, $11, $2                            ;; 04:656f  ; G#4
    audio_note $1F, $11, $4                            ;; 04:6571  ; G#4
    audio_note $1F, $11, $4                            ;; 04:6573  ; G#4
    audio_note $1F, $11, $4                            ;; 04:6575  ; G#4
    audio_note $1D, $11, $5                            ;; 04:6577  ; F#4
    audio_note $1D, $11, $4                            ;; 04:6579  ; F#4
    audio_note $1D, $11, $2                            ;; 04:657b  ; F#4
    audio_note $1D, $11, $5                            ;; 04:657d  ; F#4
    audio_note $1D, $11, $2                            ;; 04:657f  ; F#4
    audio_note $1D, $11, $4                            ;; 04:6581  ; F#4
    audio_note $1D, $11, $4                            ;; 04:6583  ; F#4
    audio_note $1D, $11, $4                            ;; 04:6585  ; F#4
    audio_note $1C, $11, $5                            ;; 04:6587  ; F4
    audio_note $1C, $11, $4                            ;; 04:6589  ; F4
    audio_note $1C, $11, $2                            ;; 04:658b  ; F4
    audio_note $1C, $11, $5                            ;; 04:658d  ; F4
    audio_note $1C, $11, $2                            ;; 04:658f  ; F4
    audio_note $1C, $11, $4                            ;; 04:6591  ; F4
    audio_note $1C, $11, $4                            ;; 04:6593  ; F4
    audio_note $1C, $11, $4                            ;; 04:6595  ; F4
    audio_end_pattern                                  ;; 04:6597

audio_04_6598_Pattern38:
; pattern $38
    audio_note $21, $11, $4                            ;; 04:6598  ; A#4
    audio_note $21, $11, $2                            ;; 04:659a  ; A#4
    audio_note $21, $11, $4                            ;; 04:659c  ; A#4
    audio_note $21, $11, $2                            ;; 04:659e  ; A#4
    audio_note $21, $11, $5                            ;; 04:65a0  ; A#4
    audio_note $21, $11, $2                            ;; 04:65a2  ; A#4
    audio_note $21, $11, $4                            ;; 04:65a4  ; A#4
    audio_note $21, $11, $4                            ;; 04:65a6  ; A#4
    audio_note $21, $11, $4                            ;; 04:65a8  ; A#4
    audio_note $24, $11, $4                            ;; 04:65aa  ; C#5
    audio_note $24, $11, $2                            ;; 04:65ac  ; C#5
    audio_note $24, $11, $4                            ;; 04:65ae  ; C#5
    audio_note $24, $11, $2                            ;; 04:65b0  ; C#5
    audio_note $24, $11, $5                            ;; 04:65b2  ; C#5
    audio_note $24, $11, $2                            ;; 04:65b4  ; C#5
    audio_note $24, $11, $4                            ;; 04:65b6  ; C#5
    audio_note $24, $11, $4                            ;; 04:65b8  ; C#5
    audio_note $24, $11, $4                            ;; 04:65ba  ; C#5
    audio_note $21, $11, $4                            ;; 04:65bc  ; A#4
    audio_note $21, $11, $2                            ;; 04:65be  ; A#4
    audio_note $21, $11, $4                            ;; 04:65c0  ; A#4
    audio_note $21, $11, $2                            ;; 04:65c2  ; A#4
    audio_note $21, $11, $5                            ;; 04:65c4  ; A#4
    audio_note $21, $11, $2                            ;; 04:65c6  ; A#4
    audio_note $21, $11, $4                            ;; 04:65c8  ; A#4
    audio_note $21, $11, $4                            ;; 04:65ca  ; A#4
    audio_note $21, $11, $4                            ;; 04:65cc  ; A#4
    audio_note $24, $11, $4                            ;; 04:65ce  ; C#5
    audio_note $24, $11, $2                            ;; 04:65d0  ; C#5
    audio_note $24, $11, $4                            ;; 04:65d2  ; C#5
    audio_note $24, $11, $2                            ;; 04:65d4  ; C#5
    audio_note $24, $11, $5                            ;; 04:65d6  ; C#5
    audio_note $24, $11, $2                            ;; 04:65d8  ; C#5
    audio_note $24, $11, $4                            ;; 04:65da  ; C#5
    audio_note $24, $11, $4                            ;; 04:65dc  ; C#5
    audio_note $24, $11, $4                            ;; 04:65de  ; C#5
    audio_note $1C, $11, $4                            ;; 04:65e0  ; F4
    audio_note $1C, $11, $2                            ;; 04:65e2  ; F4
    audio_note $1C, $11, $4                            ;; 04:65e4  ; F4
    audio_note $1C, $11, $2                            ;; 04:65e6  ; F4
    audio_note $1C, $11, $5                            ;; 04:65e8  ; F4
    audio_note $1C, $11, $2                            ;; 04:65ea  ; F4
    audio_note $1C, $11, $4                            ;; 04:65ec  ; F4
    audio_note $1C, $11, $4                            ;; 04:65ee  ; F4
    audio_note $1C, $11, $4                            ;; 04:65f0  ; F4
    audio_note $1D, $11, $4                            ;; 04:65f2  ; F#4
    audio_note $1D, $11, $2                            ;; 04:65f4  ; F#4
    audio_note $1D, $11, $4                            ;; 04:65f6  ; F#4
    audio_note $1D, $11, $2                            ;; 04:65f8  ; F#4
    audio_note $1D, $11, $5                            ;; 04:65fa  ; F#4
    audio_note $1D, $11, $2                            ;; 04:65fc  ; F#4
    audio_note $1D, $11, $4                            ;; 04:65fe  ; F#4
    audio_note $1D, $11, $4                            ;; 04:6600  ; F#4
    audio_note $1D, $11, $4                            ;; 04:6602  ; F#4
    audio_note $1C, $11, $4                            ;; 04:6604  ; F4
    audio_note $1C, $11, $2                            ;; 04:6606  ; F4
    audio_note $1C, $11, $4                            ;; 04:6608  ; F4
    audio_note $1C, $11, $2                            ;; 04:660a  ; F4
    audio_note $1C, $11, $5                            ;; 04:660c  ; F4
    audio_note $1C, $11, $2                            ;; 04:660e  ; F4
    audio_note $1C, $11, $4                            ;; 04:6610  ; F4
    audio_note $1C, $11, $4                            ;; 04:6612  ; F4
    audio_note $1C, $11, $4                            ;; 04:6614  ; F4
    audio_note $21, $11, $4                            ;; 04:6616  ; A#4
    audio_note $21, $11, $2                            ;; 04:6618  ; A#4
    audio_note $21, $11, $4                            ;; 04:661a  ; A#4
    audio_note $21, $11, $2                            ;; 04:661c  ; A#4
    audio_note $21, $11, $5                            ;; 04:661e  ; A#4
    audio_note $21, $11, $2                            ;; 04:6620  ; A#4
    audio_note $21, $11, $4                            ;; 04:6622  ; A#4
    audio_note $21, $11, $4                            ;; 04:6624  ; A#4
    audio_note $21, $11, $4                            ;; 04:6626  ; A#4
    audio_note $1C, $11, $4                            ;; 04:6628  ; F4
    audio_note $1C, $11, $2                            ;; 04:662a  ; F4
    audio_note $1C, $11, $4                            ;; 04:662c  ; F4
    audio_note $1C, $11, $2                            ;; 04:662e  ; F4
    audio_note $1C, $11, $5                            ;; 04:6630  ; F4
    audio_note $1C, $11, $2                            ;; 04:6632  ; F4
    audio_note $1C, $11, $4                            ;; 04:6634  ; F4
    audio_note $1C, $11, $4                            ;; 04:6636  ; F4
    audio_note $1C, $11, $4                            ;; 04:6638  ; F4
    audio_note $1C, $11, $4                            ;; 04:663a  ; F4
    audio_note $1C, $11, $2                            ;; 04:663c  ; F4
    audio_note $1C, $11, $4                            ;; 04:663e  ; F4
    audio_note $1C, $11, $2                            ;; 04:6640  ; F4
    audio_note $1C, $11, $5                            ;; 04:6642  ; F4
    audio_note $1C, $11, $2                            ;; 04:6644  ; F4
    audio_note $1C, $11, $4                            ;; 04:6646  ; F4
    audio_note $1C, $11, $4                            ;; 04:6648  ; F4
    audio_note $1C, $11, $4                            ;; 04:664a  ; F4
    audio_end_pattern                                  ;; 04:664c

audio_04_664d_Pattern39:
; pattern $39
    audio_note $23, $11, $5                            ;; 04:664d  ; C5
    audio_note $23, $11, $4                            ;; 04:664f  ; C5
    audio_note $23, $11, $2                            ;; 04:6651  ; C5
    audio_note $23, $11, $5                            ;; 04:6653  ; C5
    audio_note $23, $11, $2                            ;; 04:6655  ; C5
    audio_note $23, $11, $2                            ;; 04:6657  ; C5
    audio_note $23, $11, $2                            ;; 04:6659  ; C5
    audio_note $23, $11, $4                            ;; 04:665b  ; C5
    audio_note $23, $11, $4                            ;; 04:665d  ; C5
    audio_note $1E, $11, $5                            ;; 04:665f  ; G4
    audio_note $1E, $11, $4                            ;; 04:6661  ; G4
    audio_note $1E, $11, $2                            ;; 04:6663  ; G4
    audio_note $1E, $11, $5                            ;; 04:6665  ; G4
    audio_note $1E, $11, $2                            ;; 04:6667  ; G4
    audio_note $1E, $11, $2                            ;; 04:6669  ; G4
    audio_note $1E, $11, $2                            ;; 04:666b  ; G4
    audio_note $1E, $11, $4                            ;; 04:666d  ; G4
    audio_note $1E, $11, $4                            ;; 04:666f  ; G4
    audio_note $25, $11, $5                            ;; 04:6671  ; D5
    audio_note $25, $11, $4                            ;; 04:6673  ; D5
    audio_note $25, $11, $2                            ;; 04:6675  ; D5
    audio_note $25, $11, $5                            ;; 04:6677  ; D5
    audio_note $25, $11, $2                            ;; 04:6679  ; D5
    audio_note $25, $11, $2                            ;; 04:667b  ; D5
    audio_note $25, $11, $2                            ;; 04:667d  ; D5
    audio_note $25, $11, $4                            ;; 04:667f  ; D5
    audio_note $25, $11, $4                            ;; 04:6681  ; D5
    audio_note $1E, $11, $5                            ;; 04:6683  ; G4
    audio_note $1E, $11, $4                            ;; 04:6685  ; G4
    audio_note $1E, $11, $2                            ;; 04:6687  ; G4
    audio_note $1E, $11, $5                            ;; 04:6689  ; G4
    audio_note $1E, $11, $2                            ;; 04:668b  ; G4
    audio_note $1E, $11, $2                            ;; 04:668d  ; G4
    audio_note $1E, $11, $2                            ;; 04:668f  ; G4
    audio_note $1E, $11, $4                            ;; 04:6691  ; G4
    audio_note $1E, $11, $4                            ;; 04:6693  ; G4
    audio_end_pattern                                  ;; 04:6695

audio_04_6696_Pattern3A:
; pattern $3A
    audio_note $23, $11, $5                            ;; 04:6696  ; C5
    audio_note $23, $11, $4                            ;; 04:6698  ; C5
    audio_note $23, $11, $2                            ;; 04:669a  ; C5
    audio_note $23, $11, $5                            ;; 04:669c  ; C5
    audio_note $23, $11, $2                            ;; 04:669e  ; C5
    audio_note $23, $11, $2                            ;; 04:66a0  ; C5
    audio_note $23, $11, $2                            ;; 04:66a2  ; C5
    audio_note $23, $11, $4                            ;; 04:66a4  ; C5
    audio_note $23, $11, $4                            ;; 04:66a6  ; C5
    audio_note $1C, $11, $5                            ;; 04:66a8  ; F4
    audio_note $1C, $11, $4                            ;; 04:66aa  ; F4
    audio_note $1C, $11, $2                            ;; 04:66ac  ; F4
    audio_note $1C, $11, $5                            ;; 04:66ae  ; F4
    audio_note $1C, $11, $2                            ;; 04:66b0  ; F4
    audio_note $1C, $11, $2                            ;; 04:66b2  ; F4
    audio_note $1C, $11, $2                            ;; 04:66b4  ; F4
    audio_note $1C, $11, $4                            ;; 04:66b6  ; F4
    audio_note $1C, $11, $4                            ;; 04:66b8  ; F4
    audio_end_pattern                                  ;; 04:66ba

audio_04_66bb_Pattern3B:
; pattern $3B
    audio_note $21, $11, $5                            ;; 04:66bb  ; A#4
    audio_note $21, $11, $4                            ;; 04:66bd  ; A#4
    audio_note $21, $11, $2                            ;; 04:66bf  ; A#4
    audio_note $21, $11, $5                            ;; 04:66c1  ; A#4
    audio_note $21, $11, $2                            ;; 04:66c3  ; A#4
    audio_note $21, $11, $2                            ;; 04:66c5  ; A#4
    audio_note $21, $11, $2                            ;; 04:66c7  ; A#4
    audio_note $21, $11, $4                            ;; 04:66c9  ; A#4
    audio_note $21, $11, $4                            ;; 04:66cb  ; A#4
    audio_note $28, $11, $5                            ;; 04:66cd  ; F5
    audio_note $28, $11, $4                            ;; 04:66cf  ; F5
    audio_note $28, $11, $2                            ;; 04:66d1  ; F5
    audio_note $28, $11, $5                            ;; 04:66d3  ; F5
    audio_note $28, $11, $2                            ;; 04:66d5  ; F5
    audio_note $28, $11, $2                            ;; 04:66d7  ; F5
    audio_note $28, $11, $2                            ;; 04:66d9  ; F5
    audio_note $28, $11, $4                            ;; 04:66db  ; F5
    audio_note $28, $11, $4                            ;; 04:66dd  ; F5
    audio_note $26, $11, $5                            ;; 04:66df  ; D#5
    audio_note $26, $11, $4                            ;; 04:66e1  ; D#5
    audio_note $26, $11, $2                            ;; 04:66e3  ; D#5
    audio_note $26, $11, $5                            ;; 04:66e5  ; D#5
    audio_note $26, $11, $2                            ;; 04:66e7  ; D#5
    audio_note $26, $11, $2                            ;; 04:66e9  ; D#5
    audio_note $26, $11, $2                            ;; 04:66eb  ; D#5
    audio_note $26, $11, $4                            ;; 04:66ed  ; D#5
    audio_note $26, $11, $4                            ;; 04:66ef  ; D#5
    audio_note $28, $11, $5                            ;; 04:66f1  ; F5
    audio_note $28, $11, $4                            ;; 04:66f3  ; F5
    audio_note $28, $11, $2                            ;; 04:66f5  ; F5
    audio_note $28, $11, $5                            ;; 04:66f7  ; F5
    audio_note $28, $11, $2                            ;; 04:66f9  ; F5
    audio_note $28, $11, $2                            ;; 04:66fb  ; F5
    audio_note $28, $11, $2                            ;; 04:66fd  ; F5
    audio_note $28, $11, $4                            ;; 04:66ff  ; F5
    audio_note $28, $11, $4                            ;; 04:6701  ; F5
    audio_end_pattern                                  ;; 04:6703

audio_04_6704_Pattern3C:
; pattern $3C
    audio_note $21, $11, $5                            ;; 04:6704  ; A#4
    audio_note $21, $11, $4                            ;; 04:6706  ; A#4
    audio_note $21, $11, $2                            ;; 04:6708  ; A#4
    audio_note $21, $11, $5                            ;; 04:670a  ; A#4
    audio_note $21, $11, $2                            ;; 04:670c  ; A#4
    audio_note $21, $11, $4                            ;; 04:670e  ; A#4
    audio_note $21, $11, $4                            ;; 04:6710  ; A#4
    audio_note $21, $11, $4                            ;; 04:6712  ; A#4
    audio_end_pattern                                  ;; 04:6714

audio_04_6715_Pattern36:
; pattern $36
    audio_note $1A, $05, $4                            ;; 04:6715  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6717  ; D#4
    audio_note $1A, $05, $4                            ;; 04:6719  ; D#4
    audio_note $1A, $05, $2                            ;; 04:671b  ; D#4
    audio_note $1A, $05, $5                            ;; 04:671d  ; D#4
    audio_note $1A, $05, $2                            ;; 04:671f  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6721  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6723  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6725  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6727  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6729  ; D#4
    audio_note $1A, $05, $2                            ;; 04:672b  ; D#4
    audio_note $1A, $05, $4                            ;; 04:672d  ; D#4
    audio_note $1A, $05, $2                            ;; 04:672f  ; D#4
    audio_note $1A, $05, $4                            ;; 04:6731  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6733  ; D#4
    audio_note $1A, $05, $4                            ;; 04:6735  ; D#4
    audio_note $1A, $05, $1                            ;; 04:6737  ; D#4
    audio_note $1A, $05, $1                            ;; 04:6739  ; D#4
    audio_note $1A, $05, $1                            ;; 04:673b  ; D#4
    audio_note $1A, $05, $2                            ;; 04:673d  ; D#4
    audio_note $1A, $05, $2                            ;; 04:673f  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6741  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6743  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6745  ; D#4
    audio_note $1A, $05, $2                            ;; 04:6747  ; D#4
    audio_end_pattern                                  ;; 04:6749

audio_04_674a_Song_GexCave_Ch1:
; SONG_GEX_CAVE (song $04) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 04:674a
    audio_tempo $A0                                    ;; 04:674c
    audio_call $00, $00, 2                             ;; 04:674e
    audio_call $54, $EF, 1                             ;; 04:6752
    audio_call $55, $EF, 1                             ;; 04:6756
    audio_call $56, $E3, 1                             ;; 04:675a
    audio_call $57, $E3, 2                             ;; 04:675e
    audio_call $57, $E1, 2                             ;; 04:6762
    audio_call $58, $E3, 1                             ;; 04:6766
    audio_call $59, $E3, 2                             ;; 04:676a
    audio_call $59, $E5, 2                             ;; 04:676e
    audio_marker $01                                   ;; 04:6772
    audio_goto audio_04_674a_Song_GexCave_Ch1          ;; 04:6774

audio_04_6777_Song_GexCave_Ch2:
; SONG_GEX_CAVE (song $04) channel 2
; AUDIO_CMD_GOTO target
    audio_call $50, $D7, 6                             ;; 04:6777
    audio_call $50, $D5, 8                             ;; 04:677b
    audio_call $51, $E3, 2                             ;; 04:677f
    audio_call $51, $E1, 2                             ;; 04:6783
    audio_call $52, $E3, 1                             ;; 04:6787
    audio_call $53, $E3, 2                             ;; 04:678b
    audio_call $53, $E5, 2                             ;; 04:678f
    audio_goto audio_04_6777_Song_GexCave_Ch2          ;; 04:6793

audio_04_6796_Song_GexCave_Ch3:
; SONG_GEX_CAVE (song $04) channel 3
; AUDIO_CMD_GOTO target
    audio_call $4C, $EF, 3                             ;; 04:6796
    audio_call $4C, $ED, 4                             ;; 04:679a
    audio_call $4D, $EF, 2                             ;; 04:679e
    audio_call $4D, $ED, 2                             ;; 04:67a2
    audio_call $4E, $EF, 1                             ;; 04:67a6
    audio_call $4F, $EF, 2                             ;; 04:67aa
    audio_call $4F, $F1, 2                             ;; 04:67ae
    audio_goto audio_04_6796_Song_GexCave_Ch3          ;; 04:67b2

audio_04_67b5_Song_GexCave_Ch4:
; SONG_GEX_CAVE (song $04) channel 4
; AUDIO_CMD_GOTO target
    audio_note $18, $01, $4                            ;; 04:67b5  ; C#4
    audio_note $1E, $03, $4                            ;; 04:67b7  ; G4
    audio_note $1E, $03, $4                            ;; 04:67b9  ; G4
    audio_note $1E, $03, $4                            ;; 04:67bb  ; G4
    audio_note $1A, $02, $4                            ;; 04:67bd  ; D#4
    audio_note $1E, $03, $4                            ;; 04:67bf  ; G4
    audio_note $18, $01, $4                            ;; 04:67c1  ; C#4
    audio_note $1E, $03, $4                            ;; 04:67c3  ; G4
    audio_goto audio_04_67b5_Song_GexCave_Ch4          ;; 04:67c5

audio_04_67c8_Pattern54:
; pattern $54
    audio_note $3F, $0A, $6                            ;; 04:67c8  ; E7
    audio_note $40, $0A, $6                            ;; 04:67ca  ; F7
    audio_note $39, $0A, $7                            ;; 04:67cc  ; A#6
    audio_note $39, $0A, $2                            ;; 04:67ce  ; A#6
    audio_note $3B, $0A, $2                            ;; 04:67d0  ; C7
    audio_note $3C, $0A, $6                            ;; 04:67d2  ; C#7
    audio_note $39, $0A, $6                            ;; 04:67d4  ; A#6
    audio_note $3B, $0A, $6                            ;; 04:67d6  ; C7
    audio_note $38, $0A, $6                            ;; 04:67d8  ; A6
    audio_note $39, $0A, $6                            ;; 04:67da  ; A#6
    audio_note $34, $0A, $6                            ;; 04:67dc  ; F6
    audio_note $35, $0A, $6                            ;; 04:67de  ; F#6
    audio_note $33, $0A, $6                            ;; 04:67e0  ; E6
    audio_note $34, $0A, $A                            ;; 04:67e2  ; F6
    audio_end_pattern                                  ;; 04:67e4

audio_04_67e5_Pattern55:
; pattern $55
    audio_note $3E, $0B, $4                            ;; 04:67e5  ; D#7
    audio_note $3D, $0B, $4                            ;; 04:67e7  ; D7
    audio_note $3E, $0B, $4                            ;; 04:67e9  ; D#7
    audio_note $39, $0B, $4                            ;; 04:67eb  ; A#6
    audio_note $3C, $0B, $6                            ;; 04:67ed  ; C#7
    audio_note $3A, $0B, $6                            ;; 04:67ef  ; B6
    audio_note $36, $0B, $6                            ;; 04:67f1  ; G6
    audio_note $39, $0B, $6                            ;; 04:67f3  ; A#6
    audio_note $37, $0B, $7                            ;; 04:67f5  ; G#6
    audio_note $37, $0B, $2                            ;; 04:67f7  ; G#6
    audio_note $39, $0B, $2                            ;; 04:67f9  ; A#6
    audio_note $3A, $0B, $6                            ;; 04:67fb  ; B6
    audio_note $37, $0B, $6                            ;; 04:67fd  ; G#6
    audio_note $39, $0B, $6                            ;; 04:67ff  ; A#6
    audio_note $36, $0B, $6                            ;; 04:6801  ; G6
    audio_note $37, $0B, $4                            ;; 04:6803  ; G#6
    audio_note $39, $0B, $4                            ;; 04:6805  ; A#6
    audio_note $3A, $0B, $4                            ;; 04:6807  ; B6
    audio_note $3E, $0B, $4                            ;; 04:6809  ; D#7
    audio_note $43, $0B, $8                            ;; 04:680b  ; G#7
    audio_end_pattern                                  ;; 04:680d

audio_04_680e_Pattern56:
; pattern $56
    audio_note $4B, $0B, $7                            ;; 04:680e  ; E8
    audio_note $4A, $0B, $2                            ;; 04:6810  ; D#8
    audio_note $49, $0B, $2                            ;; 04:6812  ; D8
    audio_note $4A, $0B, $6                            ;; 04:6814  ; D#8
    audio_note $43, $0B, $6                            ;; 04:6816  ; G#7
    audio_note $46, $0B, $7                            ;; 04:6818  ; B7
    audio_note $45, $0B, $2                            ;; 04:681a  ; A#7
    audio_note $43, $0B, $2                            ;; 04:681c  ; G#7
    audio_note $45, $0B, $6                            ;; 04:681e  ; A#7
    audio_note $42, $0B, $6                            ;; 04:6820  ; G7
    audio_note $43, $0B, $6                            ;; 04:6822  ; G#7
    audio_note $3E, $0B, $6                            ;; 04:6824  ; D#7
    audio_note $3F, $0B, $6                            ;; 04:6826  ; E7
    audio_note $3C, $0B, $6                            ;; 04:6828  ; C#7
    audio_note $3E, $0B, $A                            ;; 04:682a  ; D#7
    audio_end_pattern                                  ;; 04:682c

audio_04_682d_Pattern57:
; pattern $57
    audio_note $40, $0A, $4                            ;; 04:682d  ; F7
    audio_note $40, $0A, $4                            ;; 04:682f  ; F7
    audio_note $40, $0A, $4                            ;; 04:6831  ; F7
    audio_note $40, $0A, $4                            ;; 04:6833  ; F7
    audio_note $40, $0A, $4                            ;; 04:6835  ; F7
    audio_note $40, $0A, $4                            ;; 04:6837  ; F7
    audio_note $40, $0A, $4                            ;; 04:6839  ; F7
    audio_note $40, $0A, $4                            ;; 04:683b  ; F7
    audio_note $3F, $0A, $4                            ;; 04:683d  ; E7
    audio_note $3F, $0A, $4                            ;; 04:683f  ; E7
    audio_note $42, $0A, $4                            ;; 04:6841  ; G7
    audio_note $42, $0A, $4                            ;; 04:6843  ; G7
    audio_note $45, $0A, $4                            ;; 04:6845  ; A#7
    audio_note $45, $0A, $4                            ;; 04:6847  ; A#7
    audio_note $42, $0A, $4                            ;; 04:6849  ; G7
    audio_note $42, $0A, $4                            ;; 04:684b  ; G7
    audio_end_pattern                                  ;; 04:684d

audio_04_684e_Pattern58:
; pattern $58
    audio_note $3F, $0A, $4                            ;; 04:684e  ; E7
    audio_note $3F, $0A, $4                            ;; 04:6850  ; E7
    audio_note $3E, $0A, $4                            ;; 04:6852  ; D#7
    audio_note $3E, $0A, $4                            ;; 04:6854  ; D#7
    audio_note $39, $0A, $4                            ;; 04:6856  ; A#6
    audio_note $39, $0A, $4                            ;; 04:6858  ; A#6
    audio_note $3C, $0A, $4                            ;; 04:685a  ; C#7
    audio_note $39, $0A, $4                            ;; 04:685c  ; A#6
    audio_note $3A, $0A, $4                            ;; 04:685e  ; B6
    audio_note $3A, $0A, $4                            ;; 04:6860  ; B6
    audio_note $39, $0A, $4                            ;; 04:6862  ; A#6
    audio_note $39, $0A, $4                            ;; 04:6864  ; A#6
    audio_note $36, $0A, $4                            ;; 04:6866  ; G6
    audio_note $36, $0A, $4                            ;; 04:6868  ; G6
    audio_note $39, $0A, $4                            ;; 04:686a  ; A#6
    audio_note $36, $0A, $4                            ;; 04:686c  ; G6
    audio_end_pattern                                  ;; 04:686e

audio_04_686f_Pattern59:
; pattern $59
    audio_note $3A, $0A, $4                            ;; 04:686f  ; B6
    audio_note $3A, $0A, $4                            ;; 04:6871  ; B6
    audio_note $3E, $0A, $4                            ;; 04:6873  ; D#7
    audio_note $3E, $0A, $4                            ;; 04:6875  ; D#7
    audio_note $3D, $0A, $4                            ;; 04:6877  ; D7
    audio_note $3D, $0A, $4                            ;; 04:6879  ; D7
    audio_note $40, $0A, $4                            ;; 04:687b  ; F7
    audio_note $40, $0A, $4                            ;; 04:687d  ; F7
    audio_note $3E, $0A, $4                            ;; 04:687f  ; D#7
    audio_note $3E, $0A, $4                            ;; 04:6881  ; D#7
    audio_note $41, $0A, $4                            ;; 04:6883  ; F#7
    audio_note $41, $0A, $4                            ;; 04:6885  ; F#7
    audio_note $40, $0A, $4                            ;; 04:6887  ; F7
    audio_note $40, $0A, $4                            ;; 04:6889  ; F7
    audio_note $3D, $0A, $4                            ;; 04:688b  ; D7
    audio_note $40, $0A, $4                            ;; 04:688d  ; F7
    audio_end_pattern                                  ;; 04:688f

audio_04_6890_Pattern50:
; pattern $50
    audio_note $40, $09, $4                            ;; 04:6890  ; F7
    audio_note $39, $09, $4                            ;; 04:6892  ; A#6
    audio_note $3C, $09, $4                            ;; 04:6894  ; C#7
    audio_note $40, $09, $4                            ;; 04:6896  ; F7
    audio_note $3F, $09, $4                            ;; 04:6898  ; E7
    audio_note $39, $09, $4                            ;; 04:689a  ; A#6
    audio_note $3C, $09, $4                            ;; 04:689c  ; C#7
    audio_note $3F, $09, $4                            ;; 04:689e  ; E7
    audio_end_pattern                                  ;; 04:68a0

audio_04_68a1_Pattern51:
; pattern $51
    audio_note $3C, $08, $4                            ;; 04:68a1  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68a3  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68a5  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68a7  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68a9  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68ab  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68ad  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68af  ; C#7
    audio_note $3B, $08, $4                            ;; 04:68b1  ; C7
    audio_note $3B, $08, $4                            ;; 04:68b3  ; C7
    audio_note $3F, $08, $4                            ;; 04:68b5  ; E7
    audio_note $3F, $08, $4                            ;; 04:68b7  ; E7
    audio_note $42, $08, $4                            ;; 04:68b9  ; G7
    audio_note $42, $08, $4                            ;; 04:68bb  ; G7
    audio_note $3F, $08, $4                            ;; 04:68bd  ; E7
    audio_note $3F, $08, $4                            ;; 04:68bf  ; E7
    audio_end_pattern                                  ;; 04:68c1

audio_04_68c2_Pattern52:
; pattern $52
    audio_note $3C, $08, $4                            ;; 04:68c2  ; C#7
    audio_note $3C, $08, $4                            ;; 04:68c4  ; C#7
    audio_note $39, $08, $4                            ;; 04:68c6  ; A#6
    audio_note $39, $08, $4                            ;; 04:68c8  ; A#6
    audio_note $36, $08, $4                            ;; 04:68ca  ; G6
    audio_note $36, $08, $4                            ;; 04:68cc  ; G6
    audio_note $39, $08, $4                            ;; 04:68ce  ; A#6
    audio_note $36, $08, $4                            ;; 04:68d0  ; G6
    audio_note $37, $08, $4                            ;; 04:68d2  ; G#6
    audio_note $37, $08, $4                            ;; 04:68d4  ; G#6
    audio_note $36, $08, $4                            ;; 04:68d6  ; G6
    audio_note $36, $08, $4                            ;; 04:68d8  ; G6
    audio_note $33, $08, $4                            ;; 04:68da  ; E6
    audio_note $33, $08, $4                            ;; 04:68dc  ; E6
    audio_note $36, $08, $4                            ;; 04:68de  ; G6
    audio_note $33, $08, $4                            ;; 04:68e0  ; E6
    audio_end_pattern                                  ;; 04:68e2

audio_04_68e3_Pattern53:
; pattern $53
    audio_note $37, $08, $4                            ;; 04:68e3  ; G#6
    audio_note $37, $08, $4                            ;; 04:68e5  ; G#6
    audio_note $3A, $08, $4                            ;; 04:68e7  ; B6
    audio_note $3A, $08, $4                            ;; 04:68e9  ; B6
    audio_note $39, $08, $4                            ;; 04:68eb  ; A#6
    audio_note $39, $08, $4                            ;; 04:68ed  ; A#6
    audio_note $3D, $08, $4                            ;; 04:68ef  ; D7
    audio_note $3D, $08, $4                            ;; 04:68f1  ; D7
    audio_note $3A, $08, $4                            ;; 04:68f3  ; B6
    audio_note $3A, $08, $4                            ;; 04:68f5  ; B6
    audio_note $3E, $08, $4                            ;; 04:68f7  ; D#7
    audio_note $3E, $08, $4                            ;; 04:68f9  ; D#7
    audio_note $3D, $08, $4                            ;; 04:68fb  ; D7
    audio_note $3D, $08, $4                            ;; 04:68fd  ; D7
    audio_note $39, $08, $4                            ;; 04:68ff  ; A#6
    audio_note $3D, $08, $4                            ;; 04:6901  ; D7
    audio_end_pattern                                  ;; 04:6903

audio_04_6904_Pattern4C:
; pattern $4C
    audio_note $21, $11, $7                            ;; 04:6904  ; A#4
    audio_note $28, $11, $6                            ;; 04:6906  ; F5
    audio_note $1C, $11, $6                            ;; 04:6908  ; F4
    audio_note $1F, $11, $4                            ;; 04:690a  ; G#4
    audio_note $21, $11, $7                            ;; 04:690c  ; A#4
    audio_note $28, $11, $6                            ;; 04:690e  ; F5
    audio_note $1C, $11, $4                            ;; 04:6910  ; F4
    audio_note $1F, $11, $4                            ;; 04:6912  ; G#4
    audio_note $20, $11, $4                            ;; 04:6914  ; A4
    audio_end_pattern                                  ;; 04:6916

audio_04_6917_Pattern4D:
; pattern $4D
    audio_note $21, $11, $7                            ;; 04:6917  ; A#4
    audio_note $21, $11, $6                            ;; 04:6919  ; A#4
    audio_note $21, $11, $6                            ;; 04:691b  ; A#4
    audio_note $21, $11, $4                            ;; 04:691d  ; A#4
    audio_note $21, $11, $7                            ;; 04:691f  ; A#4
    audio_note $21, $11, $6                            ;; 04:6921  ; A#4
    audio_note $21, $11, $4                            ;; 04:6923  ; A#4
    audio_note $21, $11, $4                            ;; 04:6925  ; A#4
    audio_note $21, $11, $4                            ;; 04:6927  ; A#4
    audio_end_pattern                                  ;; 04:6929

audio_04_692a_Pattern4E:
; pattern $4E
    audio_note $26, $11, $7                            ;; 04:692a  ; D#5
    audio_note $26, $11, $4                            ;; 04:692c  ; D#5
    audio_note $26, $11, $7                            ;; 04:692e  ; D#5
    audio_note $26, $11, $4                            ;; 04:6930  ; D#5
    audio_note $26, $11, $7                            ;; 04:6932  ; D#5
    audio_note $26, $11, $4                            ;; 04:6934  ; D#5
    audio_note $26, $11, $6                            ;; 04:6936  ; D#5
    audio_note $26, $11, $6                            ;; 04:6938  ; D#5
    audio_end_pattern                                  ;; 04:693a

audio_04_693b_Pattern4F:
; pattern $4F
    audio_note $1F, $11, $7                            ;; 04:693b  ; G#4
    audio_note $1F, $11, $6                            ;; 04:693d  ; G#4
    audio_note $1F, $11, $4                            ;; 04:693f  ; G#4
    audio_note $1A, $11, $4                            ;; 04:6941  ; D#4
    audio_note $1D, $11, $4                            ;; 04:6943  ; F#4
    audio_note $1F, $11, $7                            ;; 04:6945  ; G#4
    audio_note $1F, $11, $6                            ;; 04:6947  ; G#4
    audio_note $1F, $11, $4                            ;; 04:6949  ; G#4
    audio_note $1A, $11, $4                            ;; 04:694b  ; D#4
    audio_note $1D, $11, $4                            ;; 04:694d  ; F#4
    audio_end_pattern                                  ;; 04:694f

audio_04_6950_Song_TutTv_Ch1:
; SONG_TUT_TV (song $05) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 04:6950
    audio_tempo $AE                                    ;; 04:6952
    audio_call $00, $00, 2                             ;; 04:6954
    audio_call $65, $EF, 1                             ;; 04:6958
    audio_call $66, $EF, 1                             ;; 04:695c
    audio_call $65, $EF, 1                             ;; 04:6960
    audio_call $66, $EF, 1                             ;; 04:6964
    audio_call $67, $EF, 1                             ;; 04:6968
    audio_call $68, $EF, 1                             ;; 04:696c
    audio_call $69, $EF, 2                             ;; 04:6970
    audio_call $69, $F2, 2                             ;; 04:6974
    audio_call $6A, $EF, 1                             ;; 04:6978
    audio_call $65, $EF, 1                             ;; 04:697c
    audio_call $66, $EF, 1                             ;; 04:6980
    audio_call $65, $EF, 1                             ;; 04:6984
    audio_call $66, $EF, 1                             ;; 04:6988
    audio_call $6B, $EF, 1                             ;; 04:698c
    audio_call $67, $EF, 1                             ;; 04:6990
    audio_call $68, $EF, 1                             ;; 04:6994
    audio_call $6C, $EF, 2                             ;; 04:6998
    audio_call $6D, $E3, 1                             ;; 04:699c
    audio_marker $01                                   ;; 04:69a0
    audio_goto audio_04_6950_Song_TutTv_Ch1            ;; 04:69a2

audio_04_69a5_Song_TutTv_Ch2:
; SONG_TUT_TV (song $05) channel 2
; AUDIO_CMD_GOTO target
    audio_call $00, $00, 10                            ;; 04:69a5
    audio_call $6E, $E3, 1                             ;; 04:69a9
    audio_call $6F, $EF, 1                             ;; 04:69ad
    audio_call $70, $EF, 1                             ;; 04:69b1
    audio_call $74, $07, 4                             ;; 04:69b5
    audio_call $71, $EF, 2                             ;; 04:69b9
    audio_call $71, $F2, 2                             ;; 04:69bd
    audio_call $72, $EF, 1                             ;; 04:69c1
    audio_call $6E, $E3, 1                             ;; 04:69c5
    audio_call $6F, $EF, 1                             ;; 04:69c9
    audio_call $6E, $E3, 1                             ;; 04:69cd
    audio_call $6F, $EF, 1                             ;; 04:69d1
    audio_call $75, $07, 2                             ;; 04:69d5
    audio_call $70, $EF, 1                             ;; 04:69d9
    audio_call $74, $07, 4                             ;; 04:69dd
    audio_call $76, $07, 4                             ;; 04:69e1
    audio_call $73, $EF, 1                             ;; 04:69e5
    audio_goto audio_04_69a5_Song_TutTv_Ch2            ;; 04:69e9

audio_04_69ec_Song_TutTv_Ch3:
; SONG_TUT_TV (song $05) channel 3
; AUDIO_CMD_GOTO target
    audio_call $5C, $EF, 3                             ;; 04:69ec
    audio_call $5D, $EF, 1                             ;; 04:69f0
    audio_call $5C, $EF, 2                             ;; 04:69f4
    audio_call $5D, $EF, 1                             ;; 04:69f8
    audio_call $5E, $EF, 1                             ;; 04:69fc
    audio_call $5F, $EF, 4                             ;; 04:6a00
    audio_call $60, $EF, 2                             ;; 04:6a04
    audio_call $60, $F2, 2                             ;; 04:6a08
    audio_call $61, $EF, 1                             ;; 04:6a0c
    audio_call $5C, $EF, 2                             ;; 04:6a10
    audio_call $5D, $EF, 1                             ;; 04:6a14
    audio_call $5C, $EF, 2                             ;; 04:6a18
    audio_call $5D, $EF, 1                             ;; 04:6a1c
    audio_call $62, $EF, 2                             ;; 04:6a20
    audio_call $5E, $EF, 1                             ;; 04:6a24
    audio_call $5F, $EF, 4                             ;; 04:6a28
    audio_call $63, $EF, 2                             ;; 04:6a2c
    audio_call $64, $EF, 2                             ;; 04:6a30
    audio_goto audio_04_69ec_Song_TutTv_Ch3            ;; 04:6a34

audio_04_6a37_Song_TutTv_Ch4:
; SONG_TUT_TV (song $05) channel 4
; AUDIO_CMD_GOTO target
    audio_call $5A, $00, 4                             ;; 04:6a37
    audio_call $5B, $00, 1                             ;; 04:6a3b
    audio_call $5A, $00, 3                             ;; 04:6a3f
    audio_call $5B, $00, 1                             ;; 04:6a43
    audio_call $5A, $00, 4                             ;; 04:6a47
    audio_call $5B, $00, 1                             ;; 04:6a4b
    audio_call $5A, $00, 1                             ;; 04:6a4f
    audio_call $5B, $00, 1                             ;; 04:6a53
    audio_call $5A, $00, 2                             ;; 04:6a57
    audio_call $5B, $00, 1                             ;; 04:6a5b
    audio_call $5A, $00, 3                             ;; 04:6a5f
    audio_call $5B, $00, 1                             ;; 04:6a63
    audio_call $5A, $00, 3                             ;; 04:6a67
    audio_call $5B, $00, 1                             ;; 04:6a6b
    audio_call $5A, $00, 1                             ;; 04:6a6f
    audio_call $5B, $00, 1                             ;; 04:6a73
    audio_call $5A, $00, 1                             ;; 04:6a77
    audio_call $5B, $00, 1                             ;; 04:6a7b
    audio_call $5A, $00, 4                             ;; 04:6a7f
    audio_call $5B, $00, 1                             ;; 04:6a83
    audio_call $5A, $00, 3                             ;; 04:6a87
    audio_call $5B, $00, 1                             ;; 04:6a8b
    audio_call $5A, $00, 1                             ;; 04:6a8f
    audio_call $5B, $00, 1                             ;; 04:6a93
    audio_goto audio_04_6a37_Song_TutTv_Ch4            ;; 04:6a97

audio_04_6a9a_Pattern76:
; pattern $76
    audio_note $1C, $13, $2                            ;; 04:6a9a  ; F4
    audio_note $1C, $13, $4                            ;; 04:6a9c  ; F4
    audio_note $1C, $13, $2                            ;; 04:6a9e  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aa0  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aa2  ; F4
    audio_note $1C, $13, $2                            ;; 04:6aa4  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aa6  ; F4
    audio_note $1C, $13, $2                            ;; 04:6aa8  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aaa  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aac  ; F4
    audio_note $15, $13, $2                            ;; 04:6aae  ; A#3
    audio_note $15, $13, $4                            ;; 04:6ab0  ; A#3
    audio_note $15, $13, $2                            ;; 04:6ab2  ; A#3
    audio_note $15, $13, $4                            ;; 04:6ab4  ; A#3
    audio_note $15, $13, $4                            ;; 04:6ab6  ; A#3
    audio_note $15, $13, $2                            ;; 04:6ab8  ; A#3
    audio_note $15, $13, $4                            ;; 04:6aba  ; A#3
    audio_note $15, $13, $2                            ;; 04:6abc  ; A#3
    audio_note $15, $13, $4                            ;; 04:6abe  ; A#3
    audio_note $15, $13, $4                            ;; 04:6ac0  ; A#3
    audio_end_pattern                                  ;; 04:6ac2

audio_04_6ac3_Pattern75:
; pattern $75
    audio_note $15, $18, $6                            ;; 04:6ac3  ; A#3
    audio_note $15, $18, $4                            ;; 04:6ac5  ; A#3
    audio_note $15, $18, $4                            ;; 04:6ac7  ; A#3
    audio_note $15, $18, $6                            ;; 04:6ac9  ; A#3
    audio_note $15, $18, $4                            ;; 04:6acb  ; A#3
    audio_note $15, $18, $4                            ;; 04:6acd  ; A#3
    audio_note $13, $15, $6                            ;; 04:6acf  ; G#3
    audio_note $13, $15, $4                            ;; 04:6ad1  ; G#3
    audio_note $13, $15, $4                            ;; 04:6ad3  ; G#3
    audio_note $13, $15, $6                            ;; 04:6ad5  ; G#3
    audio_note $13, $15, $4                            ;; 04:6ad7  ; G#3
    audio_note $13, $15, $4                            ;; 04:6ad9  ; G#3
    audio_note $1D, $13, $6                            ;; 04:6adb  ; F#4
    audio_note $1D, $13, $4                            ;; 04:6add  ; F#4
    audio_note $1D, $13, $4                            ;; 04:6adf  ; F#4
    audio_note $1D, $13, $6                            ;; 04:6ae1  ; F#4
    audio_note $1D, $13, $4                            ;; 04:6ae3  ; F#4
    audio_note $1D, $13, $4                            ;; 04:6ae5  ; F#4
    audio_note $1C, $13, $6                            ;; 04:6ae7  ; F4
    audio_note $1C, $13, $4                            ;; 04:6ae9  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aeb  ; F4
    audio_note $1C, $13, $6                            ;; 04:6aed  ; F4
    audio_note $1C, $13, $4                            ;; 04:6aef  ; F4
    audio_note $1C, $13, $4                            ;; 04:6af1  ; F4
    audio_end_pattern                                  ;; 04:6af3

audio_04_6af4_Pattern74:
; pattern $74
    audio_note $1D, $16, $2                            ;; 04:6af4  ; F#4
    audio_note $1D, $16, $4                            ;; 04:6af6  ; F#4
    audio_note $1D, $16, $2                            ;; 04:6af8  ; F#4
    audio_note $1D, $16, $4                            ;; 04:6afa  ; F#4
    audio_note $1D, $16, $4                            ;; 04:6afc  ; F#4
    audio_note $1D, $16, $2                            ;; 04:6afe  ; F#4
    audio_note $1D, $16, $4                            ;; 04:6b00  ; F#4
    audio_note $1D, $16, $2                            ;; 04:6b02  ; F#4
    audio_note $1D, $16, $4                            ;; 04:6b04  ; F#4
    audio_note $1D, $16, $4                            ;; 04:6b06  ; F#4
    audio_note $15, $18, $2                            ;; 04:6b08  ; A#3
    audio_note $15, $18, $4                            ;; 04:6b0a  ; A#3
    audio_note $15, $18, $2                            ;; 04:6b0c  ; A#3
    audio_note $15, $18, $4                            ;; 04:6b0e  ; A#3
    audio_note $15, $18, $4                            ;; 04:6b10  ; A#3
    audio_note $15, $18, $2                            ;; 04:6b12  ; A#3
    audio_note $15, $18, $4                            ;; 04:6b14  ; A#3
    audio_note $15, $18, $2                            ;; 04:6b16  ; A#3
    audio_note $15, $18, $4                            ;; 04:6b18  ; A#3
    audio_note $15, $18, $4                            ;; 04:6b1a  ; A#3
    audio_end_pattern                                  ;; 04:6b1c

audio_04_6b1d_Pattern6E:
; pattern $6E
    audio_note $3E, $0F, $5                            ;; 04:6b1d  ; D#7
    audio_note $41, $0F, $2                            ;; 04:6b1f  ; F#7
    audio_note $41, $0F, $4                            ;; 04:6b21  ; F#7
    audio_note $44, $0F, $4                            ;; 04:6b23  ; A7
    audio_note $41, $0F, $4                            ;; 04:6b25  ; F#7
    audio_note $41, $0F, $4                            ;; 04:6b27  ; F#7
    audio_note $3E, $0F, $4                            ;; 04:6b29  ; D#7
    audio_note $3E, $0F, $4                            ;; 04:6b2b  ; D#7
    audio_note $38, $0F, $7                            ;; 04:6b2d  ; A6
    audio_note $4C, $08, $2                            ;; 04:6b2f  ; F8
    audio_note $4D, $08, $2                            ;; 04:6b31  ; F#8
    audio_note $50, $08, $2                            ;; 04:6b33  ; A8
    audio_note $51, $08, $2                            ;; 04:6b35  ; A#8
    audio_note $50, $08, $2                            ;; 04:6b37  ; A8
    audio_note $4D, $08, $2                            ;; 04:6b39  ; F#8
    audio_note $4C, $08, $6                            ;; 04:6b3b  ; F8
    audio_note $3E, $0F, $5                            ;; 04:6b3d  ; D#7
    audio_note $41, $0F, $2                            ;; 04:6b3f  ; F#7
    audio_note $41, $0F, $4                            ;; 04:6b41  ; F#7
    audio_note $44, $0F, $4                            ;; 04:6b43  ; A7
    audio_note $41, $0F, $4                            ;; 04:6b45  ; F#7
    audio_note $41, $0F, $4                            ;; 04:6b47  ; F#7
    audio_note $3E, $0F, $4                            ;; 04:6b49  ; D#7
    audio_note $3E, $0F, $4                            ;; 04:6b4b  ; D#7
    audio_note $44, $0F, $7                            ;; 04:6b4d  ; A7
    audio_note $54, $08, $2                            ;; 04:6b4f  ; C#9
    audio_note $53, $08, $2                            ;; 04:6b51  ; C9
    audio_note $51, $08, $2                            ;; 04:6b53  ; A#8
    audio_note $50, $08, $2                            ;; 04:6b55  ; A8
    audio_note $4D, $08, $2                            ;; 04:6b57  ; F#8
    audio_note $50, $08, $2                            ;; 04:6b59  ; A8
    audio_note $4C, $08, $6                            ;; 04:6b5b  ; F8
    audio_end_pattern                                  ;; 04:6b5d

audio_04_6b5e_Pattern6F:
; pattern $6F
    audio_note $39, $0F, $4                            ;; 04:6b5e  ; A#6
    audio_note $37, $0F, $2                            ;; 04:6b60  ; G#6
    audio_note $39, $0F, $2                            ;; 04:6b62  ; A#6
    audio_note $37, $0F, $4                            ;; 04:6b64  ; G#6
    audio_note $35, $0F, $2                            ;; 04:6b66  ; F#6
    audio_note $37, $0F, $2                            ;; 04:6b68  ; G#6
    audio_note $35, $0F, $4                            ;; 04:6b6a  ; F#6
    audio_note $34, $0F, $2                            ;; 04:6b6c  ; F6
    audio_note $35, $0F, $2                            ;; 04:6b6e  ; F#6
    audio_note $34, $0F, $4                            ;; 04:6b70  ; F6
    audio_note $32, $0F, $4                            ;; 04:6b72  ; D#6
    audio_note $38, $0F, $4                            ;; 04:6b74  ; A6
    audio_note $3E, $08, $2                            ;; 04:6b76  ; D#7
    audio_note $40, $08, $2                            ;; 04:6b78  ; F7
    audio_note $41, $08, $2                            ;; 04:6b7a  ; F#7
    audio_note $44, $08, $2                            ;; 04:6b7c  ; A7
    audio_note $45, $08, $2                            ;; 04:6b7e  ; A#7
    audio_note $47, $08, $2                            ;; 04:6b80  ; C8
    audio_note $45, $08, $2                            ;; 04:6b82  ; A#7
    audio_note $44, $08, $2                            ;; 04:6b84  ; A7
    audio_note $41, $08, $2                            ;; 04:6b86  ; F#7
    audio_note $44, $08, $2                            ;; 04:6b88  ; A7
    audio_note $40, $08, $6                            ;; 04:6b8a  ; F7
    audio_note $35, $0F, $4                            ;; 04:6b8c  ; F#6
    audio_note $34, $0F, $2                            ;; 04:6b8e  ; F6
    audio_note $35, $0F, $2                            ;; 04:6b90  ; F#6
    audio_note $34, $0F, $4                            ;; 04:6b92  ; F6
    audio_note $32, $0F, $2                            ;; 04:6b94  ; D#6
    audio_note $34, $0F, $2                            ;; 04:6b96  ; F6
    audio_note $33, $0F, $4                            ;; 04:6b98  ; E6
    audio_note $31, $0F, $2                            ;; 04:6b9a  ; D6
    audio_note $33, $0F, $2                            ;; 04:6b9c  ; E6
    audio_note $31, $0F, $4                            ;; 04:6b9e  ; D6
    audio_note $33, $0F, $4                            ;; 04:6ba0  ; E6
    audio_note $38, $0F, $4                            ;; 04:6ba2  ; A6
    audio_note $53, $08, $2                            ;; 04:6ba4  ; C9
    audio_note $50, $08, $2                            ;; 04:6ba6  ; A8
    audio_note $4D, $08, $2                            ;; 04:6ba8  ; F#8
    audio_note $4A, $08, $2                            ;; 04:6baa  ; D#8
    audio_note $53, $08, $2                            ;; 04:6bac  ; C9
    audio_note $4A, $08, $2                            ;; 04:6bae  ; D#8
    audio_note $47, $08, $2                            ;; 04:6bb0  ; C8
    audio_note $44, $08, $2                            ;; 04:6bb2  ; A7
    audio_note $41, $08, $2                            ;; 04:6bb4  ; F#7
    audio_note $44, $08, $2                            ;; 04:6bb6  ; A7
    audio_note $40, $08, $6                            ;; 04:6bb8  ; F7
    audio_end_pattern                                  ;; 04:6bba

audio_04_6bbb_Pattern70:
; pattern $70
    audio_note $34, $0F, $5                            ;; 04:6bbb  ; F6
    audio_note $35, $0F, $2                            ;; 04:6bbd  ; F#6
    audio_note $32, $0F, $4                            ;; 04:6bbf  ; D#6
    audio_note $35, $0F, $4                            ;; 04:6bc1  ; F#6
    audio_note $30, $0F, $B                            ;; 04:6bc3  ; C#6
    audio_end_pattern                                  ;; 04:6bc5

audio_04_6bc6_Pattern71:
; pattern $71
    audio_note $3B, $08, $2                            ;; 04:6bc6  ; C7
    audio_note $3B, $08, $2                            ;; 04:6bc8  ; C7
    audio_note $3B, $08, $2                            ;; 04:6bca  ; C7
    audio_note $3B, $08, $2                            ;; 04:6bcc  ; C7
    audio_note $3B, $08, $4                            ;; 04:6bce  ; C7
    audio_note $39, $08, $2                            ;; 04:6bd0  ; A#6
    audio_note $3B, $08, $4                            ;; 04:6bd2  ; C7
    audio_note $3B, $08, $2                            ;; 04:6bd4  ; C7
    audio_note $3B, $08, $4                            ;; 04:6bd6  ; C7
    audio_note $3B, $08, $4                            ;; 04:6bd8  ; C7
    audio_note $39, $08, $4                            ;; 04:6bda  ; A#6
    audio_note $3B, $08, $2                            ;; 04:6bdc  ; C7
    audio_note $3B, $08, $2                            ;; 04:6bde  ; C7
    audio_note $3B, $08, $2                            ;; 04:6be0  ; C7
    audio_note $3B, $08, $2                            ;; 04:6be2  ; C7
    audio_note $3B, $08, $4                            ;; 04:6be4  ; C7
    audio_note $39, $08, $2                            ;; 04:6be6  ; A#6
    audio_note $3B, $08, $4                            ;; 04:6be8  ; C7
    audio_note $3B, $08, $2                            ;; 04:6bea  ; C7
    audio_note $3B, $08, $4                            ;; 04:6bec  ; C7
    audio_note $3B, $08, $4                            ;; 04:6bee  ; C7
    audio_note $3C, $08, $4                            ;; 04:6bf0  ; C#7
    audio_end_pattern                                  ;; 04:6bf2

audio_04_6bf3_Pattern72:
; pattern $72
    audio_note $47, $08, $4                            ;; 04:6bf3  ; C8
    audio_note $45, $08, $2                            ;; 04:6bf5  ; A#7
    audio_note $44, $08, $4                            ;; 04:6bf7  ; A7
    audio_note $44, $08, $2                            ;; 04:6bf9  ; A7
    audio_note $41, $08, $4                            ;; 04:6bfb  ; F#7
    audio_note $41, $08, $2                            ;; 04:6bfd  ; F#7
    audio_note $3E, $08, $2                            ;; 04:6bff  ; D#7
    audio_note $41, $08, $2                            ;; 04:6c01  ; F#7
    audio_note $3E, $08, $2                            ;; 04:6c03  ; D#7
    audio_note $3B, $08, $6                            ;; 04:6c05  ; C7
    audio_note $2F, $08, $5                            ;; 04:6c07  ; C6
    audio_note $32, $08, $2                            ;; 04:6c09  ; D#6
    audio_note $35, $08, $4                            ;; 04:6c0b  ; F#6
    audio_note $32, $08, $4                            ;; 04:6c0d  ; D#6
    audio_note $2F, $08, $8                            ;; 04:6c0f  ; C6
    audio_end_pattern                                  ;; 04:6c11

audio_04_6c12_Pattern73:
; pattern $73
    audio_note $47, $08, $2                            ;; 04:6c12  ; C8
    audio_note $47, $08, $2                            ;; 04:6c14  ; C8
    audio_note $47, $08, $2                            ;; 04:6c16  ; C8
    audio_note $47, $08, $2                            ;; 04:6c18  ; C8
    audio_note $44, $08, $4                            ;; 04:6c1a  ; A7
    audio_note $41, $08, $4                            ;; 04:6c1c  ; F#7
    audio_note $47, $08, $2                            ;; 04:6c1e  ; C8
    audio_note $47, $08, $2                            ;; 04:6c20  ; C8
    audio_note $47, $08, $2                            ;; 04:6c22  ; C8
    audio_note $47, $08, $2                            ;; 04:6c24  ; C8
    audio_note $44, $08, $4                            ;; 04:6c26  ; A7
    audio_note $41, $08, $5                            ;; 04:6c28  ; F#7
    audio_note $48, $08, $2                            ;; 04:6c2a  ; C#8
    audio_note $48, $08, $2                            ;; 04:6c2c  ; C#8
    audio_note $48, $08, $2                            ;; 04:6c2e  ; C#8
    audio_note $45, $08, $4                            ;; 04:6c30  ; A#7
    audio_note $40, $08, $4                            ;; 04:6c32  ; F7
    audio_note $48, $08, $2                            ;; 04:6c34  ; C#8
    audio_note $48, $08, $2                            ;; 04:6c36  ; C#8
    audio_note $48, $08, $2                            ;; 04:6c38  ; C#8
    audio_note $48, $08, $2                            ;; 04:6c3a  ; C#8
    audio_note $45, $08, $4                            ;; 04:6c3c  ; A#7
    audio_note $40, $08, $4                            ;; 04:6c3e  ; F7
    audio_note $47, $08, $2                            ;; 04:6c40  ; C8
    audio_note $47, $08, $2                            ;; 04:6c42  ; C8
    audio_note $47, $08, $2                            ;; 04:6c44  ; C8
    audio_note $47, $08, $2                            ;; 04:6c46  ; C8
    audio_note $44, $08, $4                            ;; 04:6c48  ; A7
    audio_note $41, $08, $5                            ;; 04:6c4a  ; F#7
    audio_note $47, $08, $2                            ;; 04:6c4c  ; C8
    audio_note $47, $08, $2                            ;; 04:6c4e  ; C8
    audio_note $47, $08, $2                            ;; 04:6c50  ; C8
    audio_note $44, $08, $4                            ;; 04:6c52  ; A7
    audio_note $41, $08, $4                            ;; 04:6c54  ; F#7
    audio_note $3C, $08, $A                            ;; 04:6c56  ; C#7
    audio_end_pattern                                  ;; 04:6c58

audio_04_6c59_Pattern65:
; pattern $65
    audio_note $35, $0F, $5                            ;; 04:6c59  ; F#6
    audio_note $38, $0F, $2                            ;; 04:6c5b  ; A6
    audio_note $39, $0F, $4                            ;; 04:6c5d  ; A#6
    audio_note $3B, $0F, $4                            ;; 04:6c5f  ; C7
    audio_note $39, $0F, $4                            ;; 04:6c61  ; A#6
    audio_note $38, $0F, $4                            ;; 04:6c63  ; A6
    audio_note $35, $0F, $4                            ;; 04:6c65  ; F#6
    audio_note $38, $0F, $4                            ;; 04:6c67  ; A6
    audio_note $34, $0F, $A                            ;; 04:6c69  ; F6
    audio_note $35, $0F, $5                            ;; 04:6c6b  ; F#6
    audio_note $38, $0F, $2                            ;; 04:6c6d  ; A6
    audio_note $39, $0F, $4                            ;; 04:6c6f  ; A#6
    audio_note $3B, $0F, $4                            ;; 04:6c71  ; C7
    audio_note $39, $0F, $4                            ;; 04:6c73  ; A#6
    audio_note $38, $0F, $4                            ;; 04:6c75  ; A6
    audio_note $35, $0F, $4                            ;; 04:6c77  ; F#6
    audio_note $38, $0F, $4                            ;; 04:6c79  ; A6
    audio_note $40, $0F, $A                            ;; 04:6c7b  ; F7
    audio_end_pattern                                  ;; 04:6c7d

audio_04_6c7e_Pattern66:
; pattern $66
    audio_note $41, $0F, $4                            ;; 04:6c7e  ; F#7
    audio_note $40, $0F, $2                            ;; 04:6c80  ; F7
    audio_note $41, $0F, $2                            ;; 04:6c82  ; F#7
    audio_note $40, $0F, $4                            ;; 04:6c84  ; F7
    audio_note $3E, $0F, $2                            ;; 04:6c86  ; D#7
    audio_note $40, $0F, $2                            ;; 04:6c88  ; F7
    audio_note $3E, $0F, $4                            ;; 04:6c8a  ; D#7
    audio_note $3C, $0F, $2                            ;; 04:6c8c  ; C#7
    audio_note $3E, $0F, $2                            ;; 04:6c8e  ; D#7
    audio_note $3C, $0F, $4                            ;; 04:6c90  ; C#7
    audio_note $3B, $0F, $4                            ;; 04:6c92  ; C7
    audio_note $3B, $0F, $A                            ;; 04:6c94  ; C7
    audio_note $3E, $0F, $4                            ;; 04:6c96  ; D#7
    audio_note $3C, $0F, $2                            ;; 04:6c98  ; C#7
    audio_note $3E, $0F, $2                            ;; 04:6c9a  ; D#7
    audio_note $3C, $0F, $4                            ;; 04:6c9c  ; C#7
    audio_note $3B, $0F, $2                            ;; 04:6c9e  ; C7
    audio_note $3C, $0F, $2                            ;; 04:6ca0  ; C#7
    audio_note $3B, $0F, $4                            ;; 04:6ca2  ; C7
    audio_note $39, $0F, $2                            ;; 04:6ca4  ; A#6
    audio_note $3B, $0F, $2                            ;; 04:6ca6  ; C7
    audio_note $39, $0F, $4                            ;; 04:6ca8  ; A#6
    audio_note $3B, $0F, $4                            ;; 04:6caa  ; C7
    audio_note $3B, $0F, $A                            ;; 04:6cac  ; C7
    audio_end_pattern                                  ;; 04:6cae

audio_04_6caf_Pattern67:
; pattern $67
    audio_note $39, $0F, $5                            ;; 04:6caf  ; A#6
    audio_note $38, $0F, $2                            ;; 04:6cb1  ; A6
    audio_note $35, $0F, $4                            ;; 04:6cb3  ; F#6
    audio_note $38, $0F, $4                            ;; 04:6cb5  ; A6
    audio_note $34, $0F, $B                            ;; 04:6cb7  ; F6
    audio_end_pattern                                  ;; 04:6cb9

audio_04_6cba_Pattern68:
; pattern $68
    audio_note $48, $08, $5                            ;; 04:6cba  ; C#8
    audio_note $47, $08, $2                            ;; 04:6cbc  ; C8
    audio_note $45, $08, $4                            ;; 04:6cbe  ; A#7
    audio_note $44, $08, $4                            ;; 04:6cc0  ; A7
    audio_note $41, $08, $2                            ;; 04:6cc2  ; F#7
    audio_note $40, $08, $2                            ;; 04:6cc4  ; F7
    audio_note $41, $08, $2                            ;; 04:6cc6  ; F#7
    audio_note $40, $08, $2                            ;; 04:6cc8  ; F7
    audio_note $3E, $08, $4                            ;; 04:6cca  ; D#7
    audio_note $3C, $08, $4                            ;; 04:6ccc  ; C#7
    audio_note $40, $08, $5                            ;; 04:6cce  ; F7
    audio_note $41, $08, $2                            ;; 04:6cd0  ; F#7
    audio_note $40, $08, $2                            ;; 04:6cd2  ; F7
    audio_note $3E, $08, $2                            ;; 04:6cd4  ; D#7
    audio_note $3C, $08, $2                            ;; 04:6cd6  ; C#7
    audio_note $3E, $08, $2                            ;; 04:6cd8  ; D#7
    audio_note $40, $08, $4                            ;; 04:6cda  ; F7
    audio_note $3C, $08, $4                            ;; 04:6cdc  ; C#7
    audio_note $39, $08, $4                            ;; 04:6cde  ; A#6
    audio_note $37, $08, $4                            ;; 04:6ce0  ; G#6
    audio_note $35, $08, $2                            ;; 04:6ce2  ; F#6
    audio_note $37, $08, $2                            ;; 04:6ce4  ; G#6
    audio_note $38, $08, $2                            ;; 04:6ce6  ; A6
    audio_note $3C, $08, $2                            ;; 04:6ce8  ; C#7
    audio_note $41, $08, $4                            ;; 04:6cea  ; F#7
    audio_note $43, $08, $2                            ;; 04:6cec  ; G#7
    audio_note $44, $08, $2                            ;; 04:6cee  ; A7
    audio_note $47, $08, $4                            ;; 04:6cf0  ; C8
    audio_note $45, $08, $4                            ;; 04:6cf2  ; A#7
    audio_note $44, $08, $4                            ;; 04:6cf4  ; A7
    audio_note $41, $08, $4                            ;; 04:6cf6  ; F#7
    audio_note $40, $08, $A                            ;; 04:6cf8  ; F7
    audio_note $4D, $08, $5                            ;; 04:6cfa  ; F#8
    audio_note $4C, $08, $2                            ;; 04:6cfc  ; F8
    audio_note $4A, $08, $4                            ;; 04:6cfe  ; D#8
    audio_note $48, $08, $4                            ;; 04:6d00  ; C#8
    audio_note $44, $08, $5                            ;; 04:6d02  ; A7
    audio_note $43, $08, $2                            ;; 04:6d04  ; G#7
    audio_note $41, $08, $4                            ;; 04:6d06  ; F#7
    audio_note $44, $08, $4                            ;; 04:6d08  ; A7
    audio_note $48, $08, $4                            ;; 04:6d0a  ; C#8
    audio_note $45, $08, $4                            ;; 04:6d0c  ; A#7
    audio_note $40, $08, $4                            ;; 04:6d0e  ; F7
    audio_note $3E, $08, $4                            ;; 04:6d10  ; D#7
    audio_note $3C, $08, $2                            ;; 04:6d12  ; C#7
    audio_note $3E, $08, $2                            ;; 04:6d14  ; D#7
    audio_note $3C, $08, $2                            ;; 04:6d16  ; C#7
    audio_note $3B, $08, $2                            ;; 04:6d18  ; C7
    audio_note $39, $08, $6                            ;; 04:6d1a  ; A#6
    audio_note $35, $08, $2                            ;; 04:6d1c  ; F#6
    audio_note $37, $08, $2                            ;; 04:6d1e  ; G#6
    audio_note $38, $08, $2                            ;; 04:6d20  ; A6
    audio_note $3C, $08, $2                            ;; 04:6d22  ; C#7
    audio_note $41, $08, $2                            ;; 04:6d24  ; F#7
    audio_note $43, $08, $2                            ;; 04:6d26  ; G#7
    audio_note $44, $08, $4                            ;; 04:6d28  ; A7
    audio_note $47, $08, $6                            ;; 04:6d2a  ; C8
    audio_note $44, $08, $4                            ;; 04:6d2c  ; A7
    audio_note $41, $08, $4                            ;; 04:6d2e  ; F#7
    audio_note $45, $08, $A                            ;; 04:6d30  ; A#7
    audio_end_pattern                                  ;; 04:6d32

audio_04_6d33_Pattern69:
; pattern $69
    audio_note $40, $08, $2                            ;; 04:6d33  ; F7
    audio_note $40, $08, $2                            ;; 04:6d35  ; F7
    audio_note $40, $08, $2                            ;; 04:6d37  ; F7
    audio_note $40, $08, $2                            ;; 04:6d39  ; F7
    audio_note $40, $08, $4                            ;; 04:6d3b  ; F7
    audio_note $3E, $08, $2                            ;; 04:6d3d  ; D#7
    audio_note $40, $08, $4                            ;; 04:6d3f  ; F7
    audio_note $40, $08, $2                            ;; 04:6d41  ; F7
    audio_note $40, $08, $4                            ;; 04:6d43  ; F7
    audio_note $40, $08, $4                            ;; 04:6d45  ; F7
    audio_note $3E, $08, $4                            ;; 04:6d47  ; D#7
    audio_note $40, $08, $2                            ;; 04:6d49  ; F7
    audio_note $40, $08, $2                            ;; 04:6d4b  ; F7
    audio_note $40, $08, $2                            ;; 04:6d4d  ; F7
    audio_note $40, $08, $2                            ;; 04:6d4f  ; F7
    audio_note $40, $08, $4                            ;; 04:6d51  ; F7
    audio_note $3E, $08, $2                            ;; 04:6d53  ; D#7
    audio_note $40, $08, $4                            ;; 04:6d55  ; F7
    audio_note $40, $08, $2                            ;; 04:6d57  ; F7
    audio_note $40, $08, $4                            ;; 04:6d59  ; F7
    audio_note $40, $08, $4                            ;; 04:6d5b  ; F7
    audio_note $41, $08, $4                            ;; 04:6d5d  ; F#7
    audio_end_pattern                                  ;; 04:6d5f

audio_04_6d60_Pattern6A:
; pattern $6A
    audio_note $4C, $08, $4                            ;; 04:6d60  ; F8
    audio_note $4A, $08, $2                            ;; 04:6d62  ; D#8
    audio_note $48, $08, $4                            ;; 04:6d64  ; C#8
    audio_note $47, $08, $2                            ;; 04:6d66  ; C8
    audio_note $45, $08, $4                            ;; 04:6d68  ; A#7
    audio_note $44, $08, $2                            ;; 04:6d6a  ; A7
    audio_note $41, $08, $2                            ;; 04:6d6c  ; F#7
    audio_note $44, $08, $2                            ;; 04:6d6e  ; A7
    audio_note $41, $08, $2                            ;; 04:6d70  ; F#7
    audio_note $40, $08, $6                            ;; 04:6d72  ; F7
    audio_note $34, $08, $5                            ;; 04:6d74  ; F6
    audio_note $35, $08, $2                            ;; 04:6d76  ; F#6
    audio_note $38, $08, $4                            ;; 04:6d78  ; A6
    audio_note $35, $08, $4                            ;; 04:6d7a  ; F#6
    audio_note $34, $08, $8                            ;; 04:6d7c  ; F6
    audio_end_pattern                                  ;; 04:6d7e

audio_04_6d7f_Pattern6B:
; pattern $6B
    audio_note $45, $08, $5                            ;; 04:6d7f  ; A#7
    audio_note $44, $08, $2                            ;; 04:6d81  ; A7
    audio_note $41, $08, $4                            ;; 04:6d83  ; F#7
    audio_note $44, $08, $4                            ;; 04:6d85  ; A7
    audio_note $40, $08, $2                            ;; 04:6d87  ; F7
    audio_note $3E, $08, $2                            ;; 04:6d89  ; D#7
    audio_note $40, $08, $2                            ;; 04:6d8b  ; F7
    audio_note $41, $08, $2                            ;; 04:6d8d  ; F#7
    audio_note $40, $08, $6                            ;; 04:6d8f  ; F7
    audio_note $3E, $08, $5                            ;; 04:6d91  ; D#7
    audio_note $3C, $08, $2                            ;; 04:6d93  ; C#7
    audio_note $3B, $08, $4                            ;; 04:6d95  ; C7
    audio_note $39, $08, $4                            ;; 04:6d97  ; A#6
    audio_note $37, $08, $2                            ;; 04:6d99  ; G#6
    audio_note $39, $08, $2                            ;; 04:6d9b  ; A#6
    audio_note $37, $08, $2                            ;; 04:6d9d  ; G#6
    audio_note $35, $08, $2                            ;; 04:6d9f  ; F#6
    audio_note $37, $08, $6                            ;; 04:6da1  ; G#6
    audio_note $35, $08, $5                            ;; 04:6da3  ; F#6
    audio_note $37, $08, $2                            ;; 04:6da5  ; G#6
    audio_note $39, $08, $4                            ;; 04:6da7  ; A#6
    audio_note $3C, $08, $4                            ;; 04:6da9  ; C#7
    audio_note $41, $08, $2                            ;; 04:6dab  ; F#7
    audio_note $43, $08, $2                            ;; 04:6dad  ; G#7
    audio_note $45, $08, $2                            ;; 04:6daf  ; A#7
    audio_note $43, $08, $2                            ;; 04:6db1  ; G#7
    audio_note $41, $08, $4                            ;; 04:6db3  ; F#7
    audio_note $3C, $08, $4                            ;; 04:6db5  ; C#7
    audio_note $40, $08, $2                            ;; 04:6db7  ; F7
    audio_note $41, $08, $2                            ;; 04:6db9  ; F#7
    audio_note $44, $08, $2                            ;; 04:6dbb  ; A7
    audio_note $45, $08, $2                            ;; 04:6dbd  ; A#7
    audio_note $47, $08, $2                            ;; 04:6dbf  ; C8
    audio_note $48, $08, $2                            ;; 04:6dc1  ; C#8
    audio_note $4A, $08, $2                            ;; 04:6dc3  ; D#8
    audio_note $48, $08, $2                            ;; 04:6dc5  ; C#8
    audio_note $47, $08, $2                            ;; 04:6dc7  ; C8
    audio_note $45, $08, $2                            ;; 04:6dc9  ; A#7
    audio_note $44, $08, $2                            ;; 04:6dcb  ; A7
    audio_note $41, $08, $2                            ;; 04:6dcd  ; F#7
    audio_note $40, $08, $6                            ;; 04:6dcf  ; F7
    audio_note $3C, $08, $5                            ;; 04:6dd1  ; C#7
    audio_note $40, $08, $2                            ;; 04:6dd3  ; F7
    audio_note $41, $08, $4                            ;; 04:6dd5  ; F#7
    audio_note $44, $08, $4                            ;; 04:6dd7  ; A7
    audio_note $41, $08, $2                            ;; 04:6dd9  ; F#7
    audio_note $40, $08, $2                            ;; 04:6ddb  ; F7
    audio_note $3E, $08, $2                            ;; 04:6ddd  ; D#7
    audio_note $40, $08, $2                            ;; 04:6ddf  ; F7
    audio_note $3C, $08, $6                            ;; 04:6de1  ; C#7
    audio_note $3E, $08, $5                            ;; 04:6de3  ; D#7
    audio_note $43, $08, $2                            ;; 04:6de5  ; G#7
    audio_note $45, $08, $4                            ;; 04:6de7  ; A#7
    audio_note $47, $08, $4                            ;; 04:6de9  ; C8
    audio_note $45, $08, $2                            ;; 04:6deb  ; A#7
    audio_note $47, $08, $2                            ;; 04:6ded  ; C8
    audio_note $45, $08, $2                            ;; 04:6def  ; A#7
    audio_note $47, $08, $2                            ;; 04:6df1  ; C8
    audio_note $4A, $08, $6                            ;; 04:6df3  ; D#8
    audio_note $48, $08, $5                            ;; 04:6df5  ; C#8
    audio_note $47, $08, $2                            ;; 04:6df7  ; C8
    audio_note $45, $08, $4                            ;; 04:6df9  ; A#7
    audio_note $43, $08, $4                            ;; 04:6dfb  ; G#7
    audio_note $45, $08, $4                            ;; 04:6dfd  ; A#7
    audio_note $41, $08, $4                            ;; 04:6dff  ; F#7
    audio_note $43, $08, $4                            ;; 04:6e01  ; G#7
    audio_note $45, $08, $4                            ;; 04:6e03  ; A#7
    audio_note $40, $08, $2                            ;; 04:6e05  ; F7
    audio_note $41, $08, $2                            ;; 04:6e07  ; F#7
    audio_note $44, $08, $2                            ;; 04:6e09  ; A7
    audio_note $45, $08, $2                            ;; 04:6e0b  ; A#7
    audio_note $47, $08, $4                            ;; 04:6e0d  ; C8
    audio_note $45, $08, $4                            ;; 04:6e0f  ; A#7
    audio_note $44, $08, $4                            ;; 04:6e11  ; A7
    audio_note $41, $08, $4                            ;; 04:6e13  ; F#7
    audio_note $40, $08, $6                            ;; 04:6e15  ; F7
    audio_end_pattern                                  ;; 04:6e17

audio_04_6e18_Pattern6C:
; pattern $6C
    audio_note $4A, $08, $5                            ;; 04:6e18  ; D#8
    audio_note $48, $08, $2                            ;; 04:6e1a  ; C#8
    audio_note $47, $08, $4                            ;; 04:6e1c  ; C8
    audio_note $45, $08, $4                            ;; 04:6e1e  ; A#7
    audio_note $44, $08, $2                            ;; 04:6e20  ; A7
    audio_note $41, $08, $2                            ;; 04:6e22  ; F#7
    audio_note $44, $08, $2                            ;; 04:6e24  ; A7
    audio_note $41, $08, $2                            ;; 04:6e26  ; F#7
    audio_note $40, $08, $6                            ;; 04:6e28  ; F7
    audio_note $48, $08, $5                            ;; 04:6e2a  ; C#8
    audio_note $47, $08, $2                            ;; 04:6e2c  ; C8
    audio_note $45, $08, $4                            ;; 04:6e2e  ; A#7
    audio_note $44, $08, $4                            ;; 04:6e30  ; A7
    audio_note $45, $08, $4                            ;; 04:6e32  ; A#7
    audio_note $40, $08, $4                            ;; 04:6e34  ; F7
    audio_note $3C, $08, $6                            ;; 04:6e36  ; C#7
    audio_note $47, $08, $5                            ;; 04:6e38  ; C8
    audio_note $45, $08, $2                            ;; 04:6e3a  ; A#7
    audio_note $44, $08, $4                            ;; 04:6e3c  ; A7
    audio_note $41, $08, $4                            ;; 04:6e3e  ; F#7
    audio_note $40, $08, $2                            ;; 04:6e40  ; F7
    audio_note $41, $08, $2                            ;; 04:6e42  ; F#7
    audio_note $40, $08, $2                            ;; 04:6e44  ; F7
    audio_note $3E, $08, $2                            ;; 04:6e46  ; D#7
    audio_note $40, $08, $4                            ;; 04:6e48  ; F7
    audio_note $41, $08, $4                            ;; 04:6e4a  ; F#7
    audio_note $40, $08, $5                            ;; 04:6e4c  ; F7
    audio_note $3E, $08, $2                            ;; 04:6e4e  ; D#7
    audio_note $3C, $08, $4                            ;; 04:6e50  ; C#7
    audio_note $3E, $08, $4                            ;; 04:6e52  ; D#7
    audio_note $40, $08, $4                            ;; 04:6e54  ; F7
    audio_note $3C, $08, $4                            ;; 04:6e56  ; C#7
    audio_note $39, $08, $6                            ;; 04:6e58  ; A#6
    audio_end_pattern                                  ;; 04:6e5a

audio_04_6e5b_Pattern6D:
; pattern $6D
    audio_note $3E, $09, $2                            ;; 04:6e5b  ; D#7
    audio_note $40, $09, $2                            ;; 04:6e5d  ; F7
    audio_note $3E, $09, $2                            ;; 04:6e5f  ; D#7
    audio_note $3C, $09, $2                            ;; 04:6e61  ; C#7
    audio_note $3B, $09, $4                            ;; 04:6e63  ; C7
    audio_note $39, $09, $4                            ;; 04:6e65  ; A#6
    audio_note $38, $09, $4                            ;; 04:6e67  ; A6
    audio_note $35, $09, $4                            ;; 04:6e69  ; F#6
    audio_note $34, $09, $4                            ;; 04:6e6b  ; F6
    audio_note $38, $09, $4                            ;; 04:6e6d  ; A6
    audio_note $39, $09, $A                            ;; 04:6e6f  ; A#6
    audio_note $3E, $09, $5                            ;; 04:6e71  ; D#7
    audio_note $3C, $09, $2                            ;; 04:6e73  ; C#7
    audio_note $3B, $09, $4                            ;; 04:6e75  ; C7
    audio_note $39, $09, $4                            ;; 04:6e77  ; A#6
    audio_note $38, $09, $2                            ;; 04:6e79  ; A6
    audio_note $35, $09, $2                            ;; 04:6e7b  ; F#6
    audio_note $34, $09, $2                            ;; 04:6e7d  ; F6
    audio_note $35, $09, $2                            ;; 04:6e7f  ; F#6
    audio_note $38, $09, $2                            ;; 04:6e81  ; A6
    audio_note $39, $09, $2                            ;; 04:6e83  ; A#6
    audio_note $3B, $09, $2                            ;; 04:6e85  ; C7
    audio_note $3C, $09, $2                            ;; 04:6e87  ; C#7
    audio_note $39, $09, $A                            ;; 04:6e89  ; A#6
    audio_end_pattern                                  ;; 04:6e8b

audio_04_6e8c_Pattern5C:
; pattern $5C
    audio_note $26, $11, $5                            ;; 04:6e8c  ; D#5
    audio_note $24, $11, $2                            ;; 04:6e8e  ; C#5
    audio_note $21, $11, $4                            ;; 04:6e90  ; A#4
    audio_note $24, $11, $4                            ;; 04:6e92  ; C#5
    audio_note $26, $11, $5                            ;; 04:6e94  ; D#5
    audio_note $24, $11, $2                            ;; 04:6e96  ; C#5
    audio_note $21, $11, $4                            ;; 04:6e98  ; A#4
    audio_note $26, $11, $4                            ;; 04:6e9a  ; D#5
    audio_note $28, $11, $5                            ;; 04:6e9c  ; F5
    audio_note $26, $11, $2                            ;; 04:6e9e  ; D#5
    audio_note $23, $11, $4                            ;; 04:6ea0  ; C5
    audio_note $26, $11, $4                            ;; 04:6ea2  ; D#5
    audio_note $28, $11, $5                            ;; 04:6ea4  ; F5
    audio_note $26, $11, $2                            ;; 04:6ea6  ; D#5
    audio_note $23, $11, $4                            ;; 04:6ea8  ; C5
    audio_note $26, $11, $4                            ;; 04:6eaa  ; D#5
    audio_end_pattern                                  ;; 04:6eac

audio_04_6ead_Pattern5D:
; pattern $5D
    audio_note $29, $11, $5                            ;; 04:6ead  ; F#5
    audio_note $26, $11, $5                            ;; 04:6eaf  ; D#5
    audio_note $24, $11, $4                            ;; 04:6eb1  ; C#5
    audio_note $29, $11, $5                            ;; 04:6eb3  ; F#5
    audio_note $26, $11, $5                            ;; 04:6eb5  ; D#5
    audio_note $24, $11, $4                            ;; 04:6eb7  ; C#5
    audio_note $28, $11, $5                            ;; 04:6eb9  ; F5
    audio_note $26, $11, $5                            ;; 04:6ebb  ; D#5
    audio_note $23, $11, $4                            ;; 04:6ebd  ; C5
    audio_note $28, $11, $5                            ;; 04:6ebf  ; F5
    audio_note $26, $11, $5                            ;; 04:6ec1  ; D#5
    audio_note $23, $11, $4                            ;; 04:6ec3  ; C5
    audio_note $26, $11, $5                            ;; 04:6ec5  ; D#5
    audio_note $24, $11, $5                            ;; 04:6ec7  ; C#5
    audio_note $21, $11, $4                            ;; 04:6ec9  ; A#4
    audio_note $27, $11, $5                            ;; 04:6ecb  ; E5
    audio_note $23, $11, $5                            ;; 04:6ecd  ; C5
    audio_note $27, $11, $4                            ;; 04:6ecf  ; E5
    audio_note $28, $11, $5                            ;; 04:6ed1  ; F5
    audio_note $26, $11, $5                            ;; 04:6ed3  ; D#5
    audio_note $23, $11, $4                            ;; 04:6ed5  ; C5
    audio_note $28, $11, $5                            ;; 04:6ed7  ; F5
    audio_note $26, $11, $5                            ;; 04:6ed9  ; D#5
    audio_note $23, $11, $4                            ;; 04:6edb  ; C5
    audio_end_pattern                                  ;; 04:6edd

audio_04_6ede_Pattern5E:
; pattern $5E
    audio_note $21, $11, $5                            ;; 04:6ede  ; A#4
    audio_note $1F, $11, $2                            ;; 04:6ee0  ; G#4
    audio_note $1C, $11, $4                            ;; 04:6ee2  ; F4
    audio_note $1F, $11, $4                            ;; 04:6ee4  ; G#4
    audio_note $21, $11, $5                            ;; 04:6ee6  ; A#4
    audio_note $1F, $11, $2                            ;; 04:6ee8  ; G#4
    audio_note $1C, $11, $4                            ;; 04:6eea  ; F4
    audio_note $1F, $11, $4                            ;; 04:6eec  ; G#4
    audio_note $21, $11, $4                            ;; 04:6eee  ; A#4
    audio_note $22, $11, $4                            ;; 04:6ef0  ; B4
    audio_note $23, $11, $4                            ;; 04:6ef2  ; C5
    audio_note $24, $11, $4                            ;; 04:6ef4  ; C#5
    audio_note $25, $11, $4                            ;; 04:6ef6  ; D5
    audio_note $26, $11, $4                            ;; 04:6ef8  ; D#5
    audio_note $27, $11, $4                            ;; 04:6efa  ; E5
    audio_note $28, $11, $4                            ;; 04:6efc  ; F5
    audio_end_pattern                                  ;; 04:6efe

audio_04_6eff_Pattern5F:
; pattern $5F
    audio_note $29, $11, $5                            ;; 04:6eff  ; F#5
    audio_note $26, $11, $5                            ;; 04:6f01  ; D#5
    audio_note $24, $11, $4                            ;; 04:6f03  ; C#5
    audio_note $29, $11, $5                            ;; 04:6f05  ; F#5
    audio_note $26, $11, $5                            ;; 04:6f07  ; D#5
    audio_note $24, $11, $4                            ;; 04:6f09  ; C#5
    audio_note $21, $11, $5                            ;; 04:6f0b  ; A#4
    audio_note $1F, $11, $2                            ;; 04:6f0d  ; G#4
    audio_note $1C, $11, $4                            ;; 04:6f0f  ; F4
    audio_note $1F, $11, $4                            ;; 04:6f11  ; G#4
    audio_note $21, $11, $5                            ;; 04:6f13  ; A#4
    audio_note $1F, $11, $2                            ;; 04:6f15  ; G#4
    audio_note $1C, $11, $4                            ;; 04:6f17  ; F4
    audio_note $1F, $11, $4                            ;; 04:6f19  ; G#4
    audio_end_pattern                                  ;; 04:6f1b

audio_04_6f1c_Pattern60:
; pattern $60
    audio_note $1C, $11, $2                            ;; 04:6f1c  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f1e  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f20  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f22  ; F4
    audio_note $1C, $11, $4                            ;; 04:6f24  ; F4
    audio_note $28, $11, $2                            ;; 04:6f26  ; F5
    audio_note $1C, $11, $4                            ;; 04:6f28  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f2a  ; F4
    audio_note $1C, $11, $4                            ;; 04:6f2c  ; F4
    audio_note $1C, $11, $4                            ;; 04:6f2e  ; F4
    audio_note $1A, $11, $4                            ;; 04:6f30  ; D#4
    audio_note $1C, $11, $2                            ;; 04:6f32  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f34  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f36  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f38  ; F4
    audio_note $1C, $11, $4                            ;; 04:6f3a  ; F4
    audio_note $28, $11, $2                            ;; 04:6f3c  ; F5
    audio_note $1C, $11, $4                            ;; 04:6f3e  ; F4
    audio_note $1C, $11, $2                            ;; 04:6f40  ; F4
    audio_note $1C, $11, $4                            ;; 04:6f42  ; F4
    audio_note $1C, $11, $4                            ;; 04:6f44  ; F4
    audio_note $1D, $11, $4                            ;; 04:6f46  ; F#4
    audio_end_pattern                                  ;; 04:6f48

audio_04_6f49_Pattern61:
; pattern $61
    audio_note $1C, $11, $5                            ;; 04:6f49  ; F4
    audio_note $1D, $11, $2                            ;; 04:6f4b  ; F#4
    audio_note $20, $11, $4                            ;; 04:6f4d  ; A4
    audio_note $21, $11, $4                            ;; 04:6f4f  ; A#4
    audio_note $23, $11, $2                            ;; 04:6f51  ; C5
    audio_note $21, $11, $2                            ;; 04:6f53  ; A#4
    audio_note $20, $11, $2                            ;; 04:6f55  ; A4
    audio_note $1D, $11, $2                            ;; 04:6f57  ; F#4
    audio_note $1C, $11, $6                            ;; 04:6f59  ; F4
    audio_note $28, $11, $5                            ;; 04:6f5b  ; F5
    audio_note $26, $11, $2                            ;; 04:6f5d  ; D#5
    audio_note $23, $11, $4                            ;; 04:6f5f  ; C5
    audio_note $26, $11, $4                            ;; 04:6f61  ; D#5
    audio_note $28, $11, $6                            ;; 04:6f63  ; F5
    audio_note $1C, $11, $6                            ;; 04:6f65  ; F4
    audio_end_pattern                                  ;; 04:6f67

audio_04_6f68_Pattern62:
; pattern $62
    audio_note $21, $11, $5                            ;; 04:6f68  ; A#4
    audio_note $24, $11, $2                            ;; 04:6f6a  ; C#5
    audio_note $1C, $11, $4                            ;; 04:6f6c  ; F4
    audio_note $1F, $11, $4                            ;; 04:6f6e  ; G#4
    audio_note $21, $11, $5                            ;; 04:6f70  ; A#4
    audio_note $24, $11, $2                            ;; 04:6f72  ; C#5
    audio_note $1C, $11, $4                            ;; 04:6f74  ; F4
    audio_note $21, $11, $4                            ;; 04:6f76  ; A#4
    audio_note $1F, $11, $5                            ;; 04:6f78  ; G#4
    audio_note $23, $11, $2                            ;; 04:6f7a  ; C5
    audio_note $1A, $11, $4                            ;; 04:6f7c  ; D#4
    audio_note $1C, $11, $4                            ;; 04:6f7e  ; F4
    audio_note $1F, $11, $5                            ;; 04:6f80  ; G#4
    audio_note $23, $11, $2                            ;; 04:6f82  ; C5
    audio_note $1A, $11, $4                            ;; 04:6f84  ; D#4
    audio_note $1C, $11, $4                            ;; 04:6f86  ; F4
    audio_note $1D, $11, $5                            ;; 04:6f88  ; F#4
    audio_note $21, $11, $2                            ;; 04:6f8a  ; A#4
    audio_note $18, $11, $4                            ;; 04:6f8c  ; C#4
    audio_note $1A, $11, $4                            ;; 04:6f8e  ; D#4
    audio_note $1D, $11, $5                            ;; 04:6f90  ; F#4
    audio_note $21, $11, $2                            ;; 04:6f92  ; A#4
    audio_note $18, $11, $4                            ;; 04:6f94  ; C#4
    audio_note $1A, $11, $4                            ;; 04:6f96  ; D#4
    audio_note $1C, $11, $5                            ;; 04:6f98  ; F4
    audio_note $1D, $11, $2                            ;; 04:6f9a  ; F#4
    audio_note $20, $11, $4                            ;; 04:6f9c  ; A4
    audio_note $23, $11, $4                            ;; 04:6f9e  ; C5
    audio_note $20, $11, $4                            ;; 04:6fa0  ; A4
    audio_note $1D, $11, $4                            ;; 04:6fa2  ; F#4
    audio_note $1C, $11, $6                            ;; 04:6fa4  ; F4
    audio_end_pattern                                  ;; 04:6fa6

audio_04_6fa7_Pattern63:
; pattern $63
    audio_note $1C, $11, $5                            ;; 04:6fa7  ; F4
    audio_note $1C, $11, $2                            ;; 04:6fa9  ; F4
    audio_note $20, $11, $4                            ;; 04:6fab  ; A4
    audio_note $23, $11, $6                            ;; 04:6fad  ; C5
    audio_note $1C, $11, $4                            ;; 04:6faf  ; F4
    audio_note $20, $11, $4                            ;; 04:6fb1  ; A4
    audio_note $23, $11, $4                            ;; 04:6fb3  ; C5
    audio_note $21, $11, $5                            ;; 04:6fb5  ; A#4
    audio_note $21, $11, $2                            ;; 04:6fb7  ; A#4
    audio_note $24, $11, $4                            ;; 04:6fb9  ; C#5
    audio_note $28, $11, $6                            ;; 04:6fbb  ; F5
    audio_note $21, $11, $4                            ;; 04:6fbd  ; A#4
    audio_note $24, $11, $4                            ;; 04:6fbf  ; C#5
    audio_note $28, $11, $4                            ;; 04:6fc1  ; F5
    audio_note $1C, $11, $5                            ;; 04:6fc3  ; F4
    audio_note $1C, $11, $2                            ;; 04:6fc5  ; F4
    audio_note $20, $11, $4                            ;; 04:6fc7  ; A4
    audio_note $23, $11, $6                            ;; 04:6fc9  ; C5
    audio_note $1C, $11, $4                            ;; 04:6fcb  ; F4
    audio_note $20, $11, $4                            ;; 04:6fcd  ; A4
    audio_note $23, $11, $4                            ;; 04:6fcf  ; C5
    audio_note $21, $11, $5                            ;; 04:6fd1  ; A#4
    audio_note $23, $11, $2                            ;; 04:6fd3  ; C5
    audio_note $24, $11, $4                            ;; 04:6fd5  ; C#5
    audio_note $23, $11, $4                            ;; 04:6fd7  ; C5
    audio_note $21, $11, $4                            ;; 04:6fd9  ; A#4
    audio_note $28, $11, $4                            ;; 04:6fdb  ; F5
    audio_note $24, $11, $4                            ;; 04:6fdd  ; C#5
    audio_note $21, $11, $4                            ;; 04:6fdf  ; A#4
    audio_end_pattern                                  ;; 04:6fe1

audio_04_6fe2_Pattern64:
; pattern $64
    audio_note $28, $11, $5                            ;; 04:6fe2  ; F5
    audio_note $26, $11, $2                            ;; 04:6fe4  ; D#5
    audio_note $23, $11, $4                            ;; 04:6fe6  ; C5
    audio_note $26, $11, $4                            ;; 04:6fe8  ; D#5
    audio_note $28, $11, $5                            ;; 04:6fea  ; F5
    audio_note $26, $11, $2                            ;; 04:6fec  ; D#5
    audio_note $23, $11, $4                            ;; 04:6fee  ; C5
    audio_note $26, $11, $4                            ;; 04:6ff0  ; D#5
    audio_note $21, $11, $5                            ;; 04:6ff2  ; A#4
    audio_note $1F, $11, $2                            ;; 04:6ff4  ; G#4
    audio_note $1C, $11, $4                            ;; 04:6ff6  ; F4
    audio_note $1F, $11, $4                            ;; 04:6ff8  ; G#4
    audio_note $21, $11, $5                            ;; 04:6ffa  ; A#4
    audio_note $1F, $11, $2                            ;; 04:6ffc  ; G#4
    audio_note $1C, $11, $4                            ;; 04:6ffe  ; F4
    audio_note $1F, $11, $4                            ;; 04:7000  ; G#4
    audio_end_pattern                                  ;; 04:7002

audio_04_7003_Pattern5A:
; pattern $5A
    audio_note $18, $01, $2                            ;; 04:7003  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7005  ; G4
    audio_note $1E, $03, $2                            ;; 04:7007  ; G4
    audio_note $18, $01, $2                            ;; 04:7009  ; C#4
    audio_note $1A, $02, $2                            ;; 04:700b  ; D#4
    audio_note $1E, $03, $2                            ;; 04:700d  ; G4
    audio_note $18, $01, $2                            ;; 04:700f  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7011  ; G4
    audio_note $18, $01, $2                            ;; 04:7013  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7015  ; G4
    audio_note $1E, $03, $2                            ;; 04:7017  ; G4
    audio_note $18, $01, $2                            ;; 04:7019  ; C#4
    audio_note $1A, $02, $2                            ;; 04:701b  ; D#4
    audio_note $1E, $03, $2                            ;; 04:701d  ; G4
    audio_note $18, $01, $2                            ;; 04:701f  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7021  ; G4
    audio_note $18, $01, $2                            ;; 04:7023  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7025  ; G4
    audio_note $1E, $03, $2                            ;; 04:7027  ; G4
    audio_note $18, $01, $2                            ;; 04:7029  ; C#4
    audio_note $1A, $02, $2                            ;; 04:702b  ; D#4
    audio_note $1E, $03, $2                            ;; 04:702d  ; G4
    audio_note $18, $01, $2                            ;; 04:702f  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7031  ; G4
    audio_note $18, $01, $2                            ;; 04:7033  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7035  ; G4
    audio_note $1E, $03, $2                            ;; 04:7037  ; G4
    audio_note $18, $01, $2                            ;; 04:7039  ; C#4
    audio_note $1A, $02, $2                            ;; 04:703b  ; D#4
    audio_note $1E, $03, $2                            ;; 04:703d  ; G4
    audio_note $18, $01, $2                            ;; 04:703f  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7041  ; G4
    audio_end_pattern                                  ;; 04:7043

audio_04_7044_Pattern5B:
; pattern $5B
    audio_note $18, $01, $2                            ;; 04:7044  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7046  ; G4
    audio_note $1E, $03, $2                            ;; 04:7048  ; G4
    audio_note $18, $01, $2                            ;; 04:704a  ; C#4
    audio_note $1A, $02, $2                            ;; 04:704c  ; D#4
    audio_note $1E, $03, $2                            ;; 04:704e  ; G4
    audio_note $18, $01, $2                            ;; 04:7050  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7052  ; G4
    audio_note $18, $01, $2                            ;; 04:7054  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7056  ; G4
    audio_note $1E, $03, $2                            ;; 04:7058  ; G4
    audio_note $18, $01, $2                            ;; 04:705a  ; C#4
    audio_note $1A, $02, $2                            ;; 04:705c  ; D#4
    audio_note $1E, $03, $2                            ;; 04:705e  ; G4
    audio_note $18, $01, $2                            ;; 04:7060  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7062  ; G4
    audio_note $18, $01, $2                            ;; 04:7064  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7066  ; G4
    audio_note $1E, $03, $2                            ;; 04:7068  ; G4
    audio_note $18, $01, $2                            ;; 04:706a  ; C#4
    audio_note $1A, $02, $2                            ;; 04:706c  ; D#4
    audio_note $1E, $03, $2                            ;; 04:706e  ; G4
    audio_note $18, $01, $2                            ;; 04:7070  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7072  ; G4
    audio_note $18, $01, $2                            ;; 04:7074  ; C#4
    audio_note $1E, $03, $2                            ;; 04:7076  ; G4
    audio_note $1E, $03, $2                            ;; 04:7078  ; G4
    audio_note $18, $01, $2                            ;; 04:707a  ; C#4
    audio_note $1A, $02, $2                            ;; 04:707c  ; D#4
    audio_note $1A, $02, $2                            ;; 04:707e  ; D#4
    audio_note $1A, $02, $2                            ;; 04:7080  ; D#4
    audio_note $1E, $03, $2                            ;; 04:7082  ; G4
    audio_end_pattern                                  ;; 04:7084

data_04_7085_SongTable:
; 6 songs, AUDIO_SONG_SIZE bytes each: one starting pattern per hardware
; channel, then the note-length table those patterns index. The low nibble of a
; SONG_* id picks the row; the high nibble already picked this bank
    ; SONG_EMPTY
    audio_song audio_04_5436_Song_Empty_Ch1, audio_04_543f_Song_Empty_Ch2, audio_04_5442_Song_Empty_Ch3, audio_04_5445_Song_Empty_Ch4, audio_04_70c1_NoteLengths  ;; 04:7085
    ; SONG_UNK01
    audio_song audio_04_5448_Song_Unk01_Ch1, audio_04_5471_Song_Unk01_Ch2, audio_04_54ac_Song_Unk01_Ch3, audio_04_54d7_Song_Unk01_Ch4, audio_04_70c1_NoteLengths  ;; 04:708f
    ; SONG_HOLIDAY_TV
    audio_song audio_04_5bbd_Song_HolidayTv_Ch1, audio_04_5c08_Song_HolidayTv_Ch2, audio_04_5c87_Song_HolidayTv_Ch3, audio_04_5d06_Song_HolidayTv_Ch4, audio_04_70c1_NoteLengths  ;; 04:7099
    ; SONG_WESTERN_STATION
    audio_song audio_04_61a4_Song_WesternStation_Ch1, audio_04_61d9_Song_WesternStation_Ch2, audio_04_6240_Song_WesternStation_Ch3, audio_04_626b_Song_WesternStation_Ch4, audio_04_70c1_NoteLengths  ;; 04:70a3
    ; SONG_GEX_CAVE
    audio_song audio_04_674a_Song_GexCave_Ch1, audio_04_6777_Song_GexCave_Ch2, audio_04_6796_Song_GexCave_Ch3, audio_04_67b5_Song_GexCave_Ch4, audio_04_70c1_NoteLengths  ;; 04:70ad
    ; SONG_TUT_TV
    audio_song audio_04_6950_Song_TutTv_Ch1, audio_04_69a5_Song_TutTv_Ch2, audio_04_69ec_Song_TutTv_Ch3, audio_04_6a37_Song_TutTv_Ch4, audio_04_70c1_NoteLengths  ;; 04:70b7

audio_04_70c1_NoteLengths:
; note lengths for song $00
; note lengths for song $01
; note lengths for song $02
; note lengths for song $03
; note lengths for song $04
; note lengths for song $05
    db   $03, $04, $06, $09, $0c, $12, $18, $24        ;; 04:70c1  ; ticks per note-length index $0-$F
    db   $30, $48, $60, $90, $c0, $08, $10, $20        ;; 04:70c9

data_04_70d1_InstrumentPointers:
; AUDIO_INSTRUMENT_COUNT instruments. A note's parameter byte names one of the
; first 16; AUDIO_NOTE_INSTRUMENT_BANK on the note byte reaches the other 16
    dw   audio_04_7111_Instrument00                    ;; 04:70d1  ; instrument $00
    dw   audio_04_711d_Instrument01                    ;; 04:70d3  ; instrument $01
    dw   audio_04_7129_Instrument02                    ;; 04:70d5  ; instrument $02
    dw   audio_04_7135_Instrument03                    ;; 04:70d7  ; instrument $03
    dw   audio_04_7141_Instrument04                    ;; 04:70d9  ; instrument $04
    dw   audio_04_714d_Instrument05                    ;; 04:70db  ; instrument $05
    dw   audio_04_7159_Instrument06                    ;; 04:70dd  ; instrument $06
    dw   audio_04_7165_Instrument07                    ;; 04:70df  ; instrument $07
    dw   audio_04_7171_Instrument08                    ;; 04:70e1  ; instrument $08
    dw   audio_04_717d_Instrument09                    ;; 04:70e3  ; instrument $09
    dw   audio_04_7189_Instrument0A                    ;; 04:70e5  ; instrument $0A
    dw   audio_04_7195_Instrument0B                    ;; 04:70e7  ; instrument $0B
    dw   audio_04_71a1_Instrument0C                    ;; 04:70e9  ; instrument $0C
    dw   audio_04_71ad_Instrument0D                    ;; 04:70eb  ; instrument $0D
    dw   audio_04_71b9_Instrument0E                    ;; 04:70ed  ; instrument $0E
    dw   audio_04_71c5_Instrument0F                    ;; 04:70ef  ; instrument $0F
    dw   audio_04_71d1_Instrument10                    ;; 04:70f1  ; instrument $10
    dw   audio_04_71dd_Instrument11                    ;; 04:70f3  ; instrument $11
    dw   audio_04_71e9_Instrument12                    ;; 04:70f5  ; instrument $12
    dw   audio_04_71f5_Instrument13                    ;; 04:70f7  ; instrument $13
    dw   audio_04_7201_Instrument14                    ;; 04:70f9  ; instrument $14
    dw   audio_04_720d_Instrument15                    ;; 04:70fb  ; instrument $15
    dw   audio_04_7219_Instrument16                    ;; 04:70fd  ; instrument $16
    dw   audio_04_7225_Instrument17                    ;; 04:70ff  ; instrument $17
    dw   audio_04_7231_Instrument18                    ;; 04:7101  ; instrument $18
    dw   audio_04_723d_Instrument19                    ;; 04:7103  ; instrument $19
    dw   audio_04_7249_Instrument1A                    ;; 04:7105  ; instrument $1A
    dw   audio_04_7255_Instrument1B                    ;; 04:7107  ; instrument $1B
    dw   audio_04_7261_Instrument1C                    ;; 04:7109  ; instrument $1C
    dw   audio_04_726d_Instrument1D                    ;; 04:710b  ; instrument $1D
    dw   audio_04_7279_Instrument1E                    ;; 04:710d  ; instrument $1E
    dw   audio_04_7285_Instrument1F                    ;; 04:710f  ; instrument $1F

audio_04_7111_Instrument00:
; instrument $00
    audio_instrument $80, $00, $02, $00, $0000, $00, $0000, $00, $0000  ;; 04:7111

audio_04_711d_Instrument01:
; instrument $01
    audio_instrument $C0, $BD, $00, $01, audio_04_7291_Envelope, $01, audio_04_7438_PitchSlide, $00, $0000  ;; 04:711d

audio_04_7129_Instrument02:
; instrument $02
    audio_instrument $80, $80, $00, $01, audio_04_729a_Envelope, $01, audio_04_743b_PitchSlide, $00, $0000  ;; 04:7129

audio_04_7135_Instrument03:
; instrument $03
    audio_instrument $C0, $BB, $61, $00, $0000, $01, audio_04_745c_PitchSlide, $00, $0000  ;; 04:7135

audio_04_7141_Instrument04:
; instrument $04
    audio_instrument $80, $80, $00, $01, audio_04_72a7_Envelope, $00, $0000, $01, audio_04_74dd_Arpeggio  ;; 04:7141

audio_04_714d_Instrument05:
; instrument $05
    audio_instrument $80, $00, $00, $01, audio_04_72b4_Envelope, $01, audio_04_745f_PitchSlide, $00, $0000  ;; 04:714d

audio_04_7159_Instrument06:
; instrument $06
    audio_instrument $80, $80, $00, $01, audio_04_72c1_Envelope, $01, audio_04_7464_PitchSlide, $00, $0000  ;; 04:7159

audio_04_7165_Instrument07:
; instrument $07
    audio_instrument $80, $80, $00, $01, audio_04_72cc_Envelope, $00, $0000, $01, audio_04_7540_Arpeggio  ;; 04:7165

audio_04_7171_Instrument08:
; instrument $08
    audio_instrument $80, $80, $00, $01, audio_04_72db_Envelope, $00, $0000, $01, audio_04_755f_Arpeggio  ;; 04:7171

audio_04_717d_Instrument09:
; instrument $09
    audio_instrument $80, $80, $00, $01, audio_04_7303_Envelope, $00, $0000, $01, audio_04_75b1_Arpeggio  ;; 04:717d

audio_04_7189_Instrument0A:
; instrument $0A
    audio_instrument $80, $80, $00, $01, audio_04_7364_Envelope, $04, audio_04_747b_PitchSlide, $00, $0000  ;; 04:7189

audio_04_7195_Instrument0B:
; instrument $0B
    audio_instrument $80, $40, $00, $01, audio_04_7371_Envelope, $00, $0000, $01, audio_04_75b1_Arpeggio  ;; 04:7195

audio_04_71a1_Instrument0C:
; instrument $0C
    audio_instrument $80, $80, $00, $01, audio_04_7380_Envelope, $0C, audio_04_7486_PitchSlide, $00, $0000  ;; 04:71a1

audio_04_71ad_Instrument0D:
; instrument $0D
    audio_instrument $80, $40, $00, $01, audio_04_7397_Envelope, $01, audio_04_747b_PitchSlide, $00, $0000  ;; 04:71ad

audio_04_71b9_Instrument0E:
; instrument $0E
    audio_instrument $80, $40, $00, $01, audio_04_73aa_Envelope, $02, audio_04_74b1_PitchSlide, $00, $0000  ;; 04:71b9

audio_04_71c5_Instrument0F:
; instrument $0F
    audio_instrument $80, $80, $00, $01, audio_04_73b9_Envelope, $0C, audio_04_7486_PitchSlide, $00, $0000  ;; 04:71c5

audio_04_71d1_Instrument10:
; instrument $10
    audio_instrument $C0, $00, $00, $01, audio_04_73cc_Envelope, $01, audio_04_74bc_PitchSlide, $00, $0000  ;; 04:71d1

audio_04_71dd_Instrument11:
; instrument $11
    audio_instrument $C0, $00, $00, $01, audio_04_73d5_Envelope, $01, audio_04_74bc_PitchSlide, $00, $0000  ;; 04:71dd

audio_04_71e9_Instrument12:
; instrument $12
    audio_instrument $C0, $00, $00, $01, audio_04_73de_Envelope, $01, audio_04_74bc_PitchSlide, $00, $0000  ;; 04:71e9

audio_04_71f5_Instrument13:
; instrument $13
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_04_75c0_Arpeggio  ;; 04:71f5

audio_04_7201_Instrument14:
; instrument $14
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_04_75cf_Arpeggio  ;; 04:7201

audio_04_720d_Instrument15:
; instrument $15
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_04_75de_Arpeggio  ;; 04:720d

audio_04_7219_Instrument16:
; instrument $16
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_04_75ed_Arpeggio  ;; 04:7219

audio_04_7225_Instrument17:
; instrument $17
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_04_75fc_Arpeggio  ;; 04:7225

audio_04_7231_Instrument18:
; instrument $18
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_04_760b_Arpeggio  ;; 04:7231

audio_04_723d_Instrument19:
; instrument $19
    audio_instrument $C0, $00, $00, $01, audio_04_73e9_Envelope, $01, audio_04_74bc_PitchSlide, $00, $0000  ;; 04:723d

audio_04_7249_Instrument1A:
; instrument $1A
    audio_instrument $80, $40, $00, $01, audio_04_73fb_Envelope, $00, $0000, $01, audio_04_761a_Arpeggio  ;; 04:7249

audio_04_7255_Instrument1B:
; instrument $1B
    audio_instrument $80, $80, $00, $01, audio_04_7408_Envelope, $01, audio_04_74c7_PitchSlide, $00, $0000  ;; 04:7255

audio_04_7261_Instrument1C:
; instrument $1C
    audio_instrument $80, $00, $30, $00, $0000, $01, audio_04_7486_PitchSlide, $01, audio_04_7629_Arpeggio  ;; 04:7261

audio_04_726d_Instrument1D:
; instrument $1D
    audio_instrument $80, $00, $30, $00, $0000, $01, audio_04_7486_PitchSlide, $01, audio_04_764c_Arpeggio  ;; 04:726d

audio_04_7279_Instrument1E:
; instrument $1E
    audio_instrument $C0, $80, $00, $01, audio_04_7429_Envelope, $00, $0000, $01, audio_04_75c0_Arpeggio  ;; 04:7279

audio_04_7285_Instrument1F:
; instrument $1F
    audio_instrument $80, $80, $00, $01, audio_04_7429_Envelope, $00, $0000, $01, audio_04_75ed_Arpeggio  ;; 04:7285

audio_04_7291_Envelope:
; volume envelope of instrument $01
    audio_env $F0, 1                                   ;; 04:7291
    audio_env $00, 1                                   ;; 04:7293
    audio_env $70, 1                                   ;; 04:7295
    audio_env $00, 1                                   ;; 04:7297
    audio_env_end                                      ;; 04:7299

audio_04_729a_Envelope:
; volume envelope of instrument $02
    audio_env $C0, 1                                   ;; 04:729a
    audio_env $40, 2                                   ;; 04:729c
    audio_env $30, 1                                   ;; 04:729e
    audio_env $20, 2                                   ;; 04:72a0
    audio_env $10, 5                                   ;; 04:72a2
    audio_env $00, 1                                   ;; 04:72a4
    audio_env_end                                      ;; 04:72a6

audio_04_72a7_Envelope:
; volume envelope of instrument $04
    audio_env $20, 8                                   ;; 04:72a7
    audio_env $50, 8                                   ;; 04:72a9
    audio_env $90, 4                                   ;; 04:72ab
    audio_env $40, 64                                  ;; 04:72ad
    audio_env $20, 32                                  ;; 04:72af
    audio_env $00, 1                                   ;; 04:72b1
    audio_env_end                                      ;; 04:72b3

audio_04_72b4_Envelope:
; volume envelope of instrument $05
    audio_env $50, 2                                   ;; 04:72b4
    audio_env $30, 4                                   ;; 04:72b6
    audio_env $20, 8                                   ;; 04:72b8
    audio_env $10, 2                                   ;; 04:72ba
    audio_env $10, 2                                   ;; 04:72bc
    audio_env $00, 1                                   ;; 04:72be
    audio_env_end                                      ;; 04:72c0

audio_04_72c1_Envelope:
; volume envelope of instrument $06
    audio_env $50, 2                                   ;; 04:72c1
    audio_env $30, 40                                  ;; 04:72c3
    audio_env $20, 60                                  ;; 04:72c5
    audio_env $10, 190                                 ;; 04:72c7
    audio_env $00, 1                                   ;; 04:72c9
    audio_env_end                                      ;; 04:72cb

audio_04_72cc_Envelope:
; volume envelope of instrument $07
    audio_env $F0, 2                                   ;; 04:72cc
    audio_env $80, 2                                   ;; 04:72ce
    audio_env $60, 2                                   ;; 04:72d0
    audio_env $30, 1                                   ;; 04:72d2
    audio_env $20, 2                                   ;; 04:72d4
    audio_env $10, 2                                   ;; 04:72d6
    audio_env $00, 1                                   ;; 04:72d8
    audio_env_end                                      ;; 04:72da

audio_04_72db_Envelope:
; volume envelope of instrument $08
    audio_env $70, 1                                   ;; 04:72db
    audio_env $30, 2                                   ;; 04:72dd
    audio_env $60, 1                                   ;; 04:72df
    audio_env $30, 2                                   ;; 04:72e1
    audio_env $50, 1                                   ;; 04:72e3
    audio_env $20, 2                                   ;; 04:72e5
    audio_env $40, 1                                   ;; 04:72e7
    audio_env $20, 2                                   ;; 04:72e9
    audio_env $30, 1                                   ;; 04:72eb
    audio_env $10, 2                                   ;; 04:72ed
    audio_env $20, 1                                   ;; 04:72ef
    audio_env $10, 2                                   ;; 04:72f1
    audio_env $10, 40                                  ;; 04:72f3
    audio_env $00, 1                                   ;; 04:72f5
    audio_env_end                                      ;; 04:72f7

data_04_72f8_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $80, $01, $40, $01, $00, $02, $10, $01        ;; 04:72f8
    db   $00, $01, $ff                                 ;; 04:7300

audio_04_7303_Envelope:
; volume envelope of instrument $09
    audio_env $40, 4                                   ;; 04:7303
    audio_env $00, 4                                   ;; 04:7305
    audio_env $40, 4                                   ;; 04:7307
    audio_env $00, 4                                   ;; 04:7309
    audio_env $50, 4                                   ;; 04:730b
    audio_env $00, 4                                   ;; 04:730d
    audio_env $50, 4                                   ;; 04:730f
    audio_env $00, 4                                   ;; 04:7311
    audio_env $40, 4                                   ;; 04:7313
    audio_env $00, 4                                   ;; 04:7315
    audio_env $40, 4                                   ;; 04:7317
    audio_env $00, 4                                   ;; 04:7319
    audio_env $00, 4                                   ;; 04:731b
    audio_env $30, 4                                   ;; 04:731d
    audio_env $00, 4                                   ;; 04:731f
    audio_env $30, 4                                   ;; 04:7321
    audio_env $00, 4                                   ;; 04:7323
    audio_env $30, 4                                   ;; 04:7325
    audio_env $00, 4                                   ;; 04:7327
    audio_env $30, 4                                   ;; 04:7329
    audio_env $00, 4                                   ;; 04:732b
    audio_env $30, 4                                   ;; 04:732d
    audio_env $00, 4                                   ;; 04:732f
    audio_env $30, 4                                   ;; 04:7331
    audio_env $00, 4                                   ;; 04:7333
    audio_env $20, 4                                   ;; 04:7335
    audio_env $00, 4                                   ;; 04:7337
    audio_env $20, 4                                   ;; 04:7339
    audio_env $00, 5                                   ;; 04:733b
    audio_env $20, 5                                   ;; 04:733d
    audio_env $00, 5                                   ;; 04:733f
    audio_env $20, 5                                   ;; 04:7341
    audio_env $00, 5                                   ;; 04:7343
    audio_env $10, 5                                   ;; 04:7345
    audio_env $00, 5                                   ;; 04:7347
    audio_env $10, 5                                   ;; 04:7349
    audio_env $00, 6                                   ;; 04:734b
    audio_env $10, 6                                   ;; 04:734d
    audio_env $00, 6                                   ;; 04:734f
    audio_env $10, 6                                   ;; 04:7351
    audio_env $00, 6                                   ;; 04:7353
    audio_env $10, 6                                   ;; 04:7355
    audio_env $00, 6                                   ;; 04:7357
    audio_env $10, 6                                   ;; 04:7359
    audio_env $00, 6                                   ;; 04:735b
    audio_env $10, 6                                   ;; 04:735d
    audio_env $00, 6                                   ;; 04:735f
    audio_env $10, 6                                   ;; 04:7361
    audio_env_end                                      ;; 04:7363

audio_04_7364_Envelope:
; volume envelope of instrument $0A
    audio_env $60, 1                                   ;; 04:7364
    audio_env $40, 4                                   ;; 04:7366
    audio_env $30, 20                                  ;; 04:7368
    audio_env $20, 60                                  ;; 04:736a
    audio_env $10, 60                                  ;; 04:736c
    audio_env $00, 1                                   ;; 04:736e
    audio_env_end                                      ;; 04:7370

audio_04_7371_Envelope:
; volume envelope of instrument $0B
    audio_env $30, 2                                   ;; 04:7371
    audio_env $30, 4                                   ;; 04:7373
    audio_env $30, 8                                   ;; 04:7375
    audio_env $20, 16                                  ;; 04:7377
    audio_env $10, 32                                  ;; 04:7379
    audio_env $10, 64                                  ;; 04:737b
    audio_env $00, 1                                   ;; 04:737d
    audio_env_end                                      ;; 04:737f

audio_04_7380_Envelope:
; volume envelope of instrument $0C
    audio_env $10, 2                                   ;; 04:7380
    audio_env $20, 1                                   ;; 04:7382
    audio_env $30, 1                                   ;; 04:7384
    audio_env $60, 3                                   ;; 04:7386
    audio_env $50, 50                                  ;; 04:7388
    audio_env $50, 10                                  ;; 04:738a
    audio_env $40, 10                                  ;; 04:738c
    audio_env $30, 10                                  ;; 04:738e
    audio_env $20, 30                                  ;; 04:7390
    audio_env $10, 30                                  ;; 04:7392
    audio_env $00, 1                                   ;; 04:7394
    audio_env_end                                      ;; 04:7396

audio_04_7397_Envelope:
; volume envelope of instrument $0D
    audio_env $70, 2                                   ;; 04:7397
    audio_env $60, 4                                   ;; 04:7399
    audio_env $50, 7                                   ;; 04:739b
    audio_env $40, 8                                   ;; 04:739d
    audio_env $30, 20                                  ;; 04:739f
    audio_env $20, 20                                  ;; 04:73a1
    audio_env $10, 60                                  ;; 04:73a3
    audio_env $10, 60                                  ;; 04:73a5
    audio_env $00, 1                                   ;; 04:73a7
    audio_env_end                                      ;; 04:73a9

audio_04_73aa_Envelope:
; volume envelope of instrument $0E
    audio_env $60, 2                                   ;; 04:73aa
    audio_env $50, 2                                   ;; 04:73ac
    audio_env $40, 3                                   ;; 04:73ae
    audio_env $30, 10                                  ;; 04:73b0
    audio_env $20, 40                                  ;; 04:73b2
    audio_env $10, 40                                  ;; 04:73b4
    audio_env $00, 1                                   ;; 04:73b6
    audio_env_end                                      ;; 04:73b8

audio_04_73b9_Envelope:
; volume envelope of instrument $0F
    audio_env $10, 2                                   ;; 04:73b9
    audio_env $20, 1                                   ;; 04:73bb
    audio_env $30, 1                                   ;; 04:73bd
    audio_env $40, 20                                  ;; 04:73bf
    audio_env $30, 80                                  ;; 04:73c1
    audio_env $20, 10                                  ;; 04:73c3
    audio_env $10, 10                                  ;; 04:73c5
    audio_env $10, 10                                  ;; 04:73c7
    audio_env $00, 1                                   ;; 04:73c9
    audio_env_end                                      ;; 04:73cb

audio_04_73cc_Envelope:
; volume envelope of instrument $10
    audio_env $20, 10                                  ;; 04:73cc
    audio_env $40, 90                                  ;; 04:73ce
    audio_env $60, 240                                 ;; 04:73d0
    audio_env $00, 1                                   ;; 04:73d2
    audio_env_end                                      ;; 04:73d4

audio_04_73d5_Envelope:
; volume envelope of instrument $11
    audio_env $20, 4                                   ;; 04:73d5
    audio_env $40, 20                                  ;; 04:73d7
    audio_env $60, 10                                  ;; 04:73d9
    audio_env $00, 1                                   ;; 04:73db
    audio_env_end                                      ;; 04:73dd

audio_04_73de_Envelope:
; volume envelope of instrument $12
    audio_env $20, 10                                  ;; 04:73de
    audio_env $40, 240                                 ;; 04:73e0
    audio_env $60, 240                                 ;; 04:73e2
    audio_env $60, 240                                 ;; 04:73e4
    audio_env $00, 1                                   ;; 04:73e6
    audio_env_end                                      ;; 04:73e8

audio_04_73e9_Envelope:
; volume envelope of instrument $19
    audio_env $20, 1                                   ;; 04:73e9
    audio_env $40, 20                                  ;; 04:73eb
    audio_env $60, 100                                 ;; 04:73ed
    audio_env $00, 1                                   ;; 04:73ef
    audio_env_end                                      ;; 04:73f1

data_04_73f2_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $20, $04, $40, $c8, $40, $64, $60, $28        ;; 04:73f2
    db   $ff                                           ;; 04:73fa

audio_04_73fb_Envelope:
; volume envelope of instrument $1A
    audio_env $50, 4                                   ;; 04:73fb
    audio_env $40, 10                                  ;; 04:73fd
    audio_env $30, 20                                  ;; 04:73ff
    audio_env $20, 40                                  ;; 04:7401
    audio_env $10, 30                                  ;; 04:7403
    audio_env $00, 1                                   ;; 04:7405
    audio_env_end                                      ;; 04:7407

audio_04_7408_Envelope:
; volume envelope of instrument $1B
    audio_env $60, 1                                   ;; 04:7408
    audio_env $40, 58                                  ;; 04:740a
    audio_env $20, 50                                  ;; 04:740c
    audio_env $00, 1                                   ;; 04:740e
    audio_env_end                                      ;; 04:7410

data_04_7411_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $20, $05, $30, $05, $40, $05, $70, $c8        ;; 04:7411
    db   $50, $c8, $30, $c8, $00, $01, $ff, $c0        ;; 04:7419
    db   $01, $00, $01, $30, $01, $00, $01, $ff        ;; 04:7421

audio_04_7429_Envelope:
; volume envelope of instrument $1E
; volume envelope of instrument $1F
    audio_env $20, 10                                  ;; 04:7429
    audio_env $10, 10                                  ;; 04:742b
    audio_env $20, 10                                  ;; 04:742d
    audio_env $30, 10                                  ;; 04:742f
    audio_env $40, 20                                  ;; 04:7431
    audio_env $50, 100                                 ;; 04:7433
    audio_env $60, 100                                 ;; 04:7435
    audio_env_end                                      ;; 04:7437

audio_04_7438_PitchSlide:
; pitch slide of instrument $01
    audio_pitch 97, 200                                ;; 04:7438
    audio_pitch_end                                    ;; 04:743a

audio_04_743b_PitchSlide:
; pitch slide of instrument $02
    audio_pitch 55, 2                                  ;; 04:743b
    audio_pitch 100, 2                                 ;; 04:743d
    audio_pitch 34, 1                                  ;; 04:743f
    audio_pitch 55, 1                                  ;; 04:7441
    audio_pitch 34, 1                                  ;; 04:7443
    audio_pitch 55, 1                                  ;; 04:7445
    audio_pitch 34, 1                                  ;; 04:7447
    audio_pitch 34, 1                                  ;; 04:7449
    audio_pitch 55, 1                                  ;; 04:744b
    audio_pitch 34, 1                                  ;; 04:744d
    audio_pitch 55, 1                                  ;; 04:744f
    audio_pitch 34, 1                                  ;; 04:7451
    audio_pitch 55, 1                                  ;; 04:7453
    audio_pitch 34, 1                                  ;; 04:7455
    audio_pitch 55, 1                                  ;; 04:7457
    audio_pitch 34, 16                                 ;; 04:7459
    audio_pitch_end                                    ;; 04:745b

audio_04_745c_PitchSlide:
; pitch slide of instrument $03
    audio_pitch 18, 200                                ;; 04:745c
    audio_pitch_end                                    ;; 04:745e

audio_04_745f_PitchSlide:
; pitch slide of instrument $05
    audio_pitch 34, 1                                  ;; 04:745f
    audio_pitch 16, 200                                ;; 04:7461
    audio_pitch_end                                    ;; 04:7463

audio_04_7464_PitchSlide:
; pitch slide of instrument $06
    audio_pitch 33, 10                                 ;; 04:7464
    audio_pitch 34, 10                                 ;; 04:7466
    audio_pitch 35, 10                                 ;; 04:7468
    audio_pitch 36, 10                                 ;; 04:746a
    audio_pitch 50, 10                                 ;; 04:746c
    audio_pitch 51, 10                                 ;; 04:746e
    audio_pitch 52, 10                                 ;; 04:7470
    audio_pitch 53, 10                                 ;; 04:7472
    audio_pitch 66, 10                                 ;; 04:7474
    audio_pitch 67, 10                                 ;; 04:7476
    audio_pitch 68, 200                                ;; 04:7478
    audio_pitch_end                                    ;; 04:747a

audio_04_747b_PitchSlide:
; pitch slide of instrument $0A
; pitch slide of instrument $0D
    audio_pitch 2, 3                                   ;; 04:747b
    audio_pitch -2, 3                                  ;; 04:747d
    audio_pitch -2, 3                                  ;; 04:747f
    audio_pitch 2, 3                                   ;; 04:7481
    audio_pitch_loop audio_04_747b_PitchSlide          ;; 04:7483

audio_04_7486_PitchSlide:
; pitch slide of instrument $0C
; pitch slide of instrument $0F
; pitch slide of instrument $1C
; pitch slide of instrument $1D
    audio_pitch 1, 3                                   ;; 04:7486
    audio_pitch -1, 3                                  ;; 04:7488
    audio_pitch -1, 3                                  ;; 04:748a
    audio_pitch 1, 3                                   ;; 04:748c
    audio_pitch 1, 3                                   ;; 04:748e
    audio_pitch -1, 3                                  ;; 04:7490
    audio_pitch -1, 3                                  ;; 04:7492
    audio_pitch 1, 3                                   ;; 04:7494
    audio_pitch 1, 3                                   ;; 04:7496
    audio_pitch -1, 3                                  ;; 04:7498
    audio_pitch -1, 3                                  ;; 04:749a
    audio_pitch 1, 3                                   ;; 04:749c
    audio_pitch 1, 3                                   ;; 04:749e
    audio_pitch -1, 3                                  ;; 04:74a0
    audio_pitch -1, 3                                  ;; 04:74a2
    audio_pitch 1, 3                                   ;; 04:74a4

audio_04_74a6_PitchSlide:
    audio_pitch 2, 3                                   ;; 04:74a6
    audio_pitch -2, 3                                  ;; 04:74a8
    audio_pitch -2, 3                                  ;; 04:74aa
    audio_pitch 2, 3                                   ;; 04:74ac
    audio_pitch_loop audio_04_74a6_PitchSlide          ;; 04:74ae

audio_04_74b1_PitchSlide:
; pitch slide of instrument $0E
    audio_pitch 1, 2                                   ;; 04:74b1
    audio_pitch -1, 2                                  ;; 04:74b3
    audio_pitch 1, 2                                   ;; 04:74b5
    audio_pitch -1, 2                                  ;; 04:74b7
    audio_pitch_loop audio_04_747b_PitchSlide          ;; 04:74b9

audio_04_74bc_PitchSlide:
; pitch slide of instrument $10
; pitch slide of instrument $11
; pitch slide of instrument $12
; pitch slide of instrument $19
    audio_pitch 6, 2                                   ;; 04:74bc
    audio_pitch -6, 2                                  ;; 04:74be
    audio_pitch -6, 2                                  ;; 04:74c0
    audio_pitch 6, 2                                   ;; 04:74c2
    audio_pitch_loop audio_04_74bc_PitchSlide          ;; 04:74c4

audio_04_74c7_PitchSlide:
; pitch slide of instrument $1B
    audio_pitch -3, 2                                  ;; 04:74c7
    audio_pitch 3, 2                                   ;; 04:74c9
    audio_pitch 3, 2                                   ;; 04:74cb
    audio_pitch -3, 2                                  ;; 04:74cd
    audio_pitch_loop audio_04_74c7_PitchSlide          ;; 04:74cf

data_04_74d2_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $0d, $03, $f3, $03, $f3, $03, $0d, $03        ;; 04:74d2
    db   $7d, $7b, $74                                 ;; 04:74da

audio_04_74dd_Arpeggio:
; arpeggio of instrument $04
    audio_arp 3, 36                                    ;; 04:74dd
    audio_arp 1, 0                                     ;; 04:74df
    audio_arp 3, 35                                    ;; 04:74e1
    audio_arp 1, 0                                     ;; 04:74e3
    audio_arp 3, 34                                    ;; 04:74e5
    audio_arp 1, 0                                     ;; 04:74e7
    audio_arp 3, 33                                    ;; 04:74e9
    audio_arp 1, 0                                     ;; 04:74eb
    audio_arp 3, 31                                    ;; 04:74ed
    audio_arp 1, 0                                     ;; 04:74ef
    audio_arp 3, 30                                    ;; 04:74f1
    audio_arp 1, 0                                     ;; 04:74f3
    audio_arp 3, 29                                    ;; 04:74f5
    audio_arp 1, 0                                     ;; 04:74f7
    audio_arp 3, 28                                    ;; 04:74f9
    audio_arp 1, 0                                     ;; 04:74fb
    audio_arp 3, 27                                    ;; 04:74fd
    audio_arp 1, 0                                     ;; 04:74ff
    audio_arp 3, 26                                    ;; 04:7501
    audio_arp 1, 0                                     ;; 04:7503
    audio_arp 3, 25                                    ;; 04:7505
    audio_arp 1, 0                                     ;; 04:7507
    audio_arp 3, 24                                    ;; 04:7509
    audio_arp 1, 0                                     ;; 04:750b
    audio_arp 3, 23                                    ;; 04:750d
    audio_arp 1, 0                                     ;; 04:750f
    audio_arp 3, 22                                    ;; 04:7511
    audio_arp 1, 0                                     ;; 04:7513
    audio_arp 3, 21                                    ;; 04:7515
    audio_arp 1, 0                                     ;; 04:7517
    audio_arp 3, 20                                    ;; 04:7519
    audio_arp 1, 0                                     ;; 04:751b
    audio_arp 3, 19                                    ;; 04:751d
    audio_arp 1, 0                                     ;; 04:751f
    audio_arp 3, 18                                    ;; 04:7521
    audio_arp 1, 0                                     ;; 04:7523
    audio_arp 3, 17                                    ;; 04:7525
    audio_arp 1, 0                                     ;; 04:7527
    audio_arp 3, 16                                    ;; 04:7529
    audio_arp 1, 0                                     ;; 04:752b
    audio_arp 3, 15                                    ;; 04:752d
    audio_arp 1, 0                                     ;; 04:752f
    audio_arp 3, 14                                    ;; 04:7531
    audio_arp 1, 0                                     ;; 04:7533
    audio_arp 3, 13                                    ;; 04:7535
    audio_arp 1, 0                                     ;; 04:7537
    audio_arp 3, 12                                    ;; 04:7539
    audio_arp 1, 0                                     ;; 04:753b
    audio_arp_loop audio_04_74dd_Arpeggio              ;; 04:753d

audio_04_7540_Arpeggio:
; arpeggio of instrument $07
    audio_arp 1, -1                                    ;; 04:7540
    audio_arp 1, -2                                    ;; 04:7542
    audio_arp 1, -3                                    ;; 04:7544
    audio_arp 1, -4                                    ;; 04:7546
    audio_arp 1, -5                                    ;; 04:7548
    audio_arp 1, -6                                    ;; 04:754a
    audio_arp 1, -7                                    ;; 04:754c
    audio_arp 1, -8                                    ;; 04:754e
    audio_arp 1, -9                                    ;; 04:7550
    audio_arp 1, -10                                   ;; 04:7552
    audio_arp 1, -11                                   ;; 04:7554
    audio_arp 1, -12                                   ;; 04:7556
    audio_arp 1, -13                                   ;; 04:7558
    audio_arp 200, -13                                 ;; 04:755a
    audio_arp_loop audio_04_7540_Arpeggio              ;; 04:755c

audio_04_755f_Arpeggio:
; arpeggio of instrument $08
    audio_arp 3, 0                                     ;; 04:755f
    audio_arp 3, -12                                   ;; 04:7561
    audio_arp 3, 0                                     ;; 04:7563
    audio_arp 3, -12                                   ;; 04:7565
    audio_arp 3, 0                                     ;; 04:7567
    audio_arp 3, -12                                   ;; 04:7569
    audio_arp 3, 0                                     ;; 04:756b
    audio_arp 3, -12                                   ;; 04:756d
    audio_arp 3, 0                                     ;; 04:756f
    audio_arp 3, -12                                   ;; 04:7571
    audio_arp 3, 0                                     ;; 04:7573
    audio_arp 3, -12                                   ;; 04:7575
    audio_arp 3, 0                                     ;; 04:7577
    audio_arp 3, -12                                   ;; 04:7579
    audio_arp 3, 0                                     ;; 04:757b
    audio_arp 3, -12                                   ;; 04:757d
    audio_arp 3, 0                                     ;; 04:757f
    audio_arp 3, -12                                   ;; 04:7581
    audio_arp 3, 0                                     ;; 04:7583
    audio_arp 3, -12                                   ;; 04:7585
    audio_arp 3, 0                                     ;; 04:7587
    audio_arp 3, -12                                   ;; 04:7589
    audio_arp 3, 0                                     ;; 04:758b
    audio_arp 3, -12                                   ;; 04:758d
    audio_arp 3, 0                                     ;; 04:758f
    audio_arp 3, -12                                   ;; 04:7591
    audio_arp 3, 0                                     ;; 04:7593
    audio_arp 3, -12                                   ;; 04:7595
    audio_arp 3, 0                                     ;; 04:7597
    audio_arp 3, -12                                   ;; 04:7599
    audio_arp 3, 0                                     ;; 04:759b
    audio_arp 3, -12                                   ;; 04:759d
    audio_arp_loop audio_04_755f_Arpeggio              ;; 04:759f

data_04_75a2_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $03, $00, $03, $0c, $03, $00, $03, $0c        ;; 04:75a2
    db   $03, $00, $03, $0c, $ff, $a2, $75             ;; 04:75aa

audio_04_75b1_Arpeggio:
; arpeggio of instrument $09
; arpeggio of instrument $0B
    audio_arp 4, 12                                    ;; 04:75b1
    audio_arp 4, 0                                     ;; 04:75b3
    audio_arp 4, 12                                    ;; 04:75b5
    audio_arp 4, 0                                     ;; 04:75b7
    audio_arp 4, 12                                    ;; 04:75b9
    audio_arp 4, 0                                     ;; 04:75bb
    audio_arp_loop audio_04_75b1_Arpeggio              ;; 04:75bd

audio_04_75c0_Arpeggio:
; arpeggio of instrument $13
; arpeggio of instrument $1E
    audio_arp 1, 0                                     ;; 04:75c0
    audio_arp 1, 4                                     ;; 04:75c2
    audio_arp 1, 7                                     ;; 04:75c4
    audio_arp 1, 0                                     ;; 04:75c6
    audio_arp 1, 4                                     ;; 04:75c8
    audio_arp 1, 7                                     ;; 04:75ca
    audio_arp_loop audio_04_75c0_Arpeggio              ;; 04:75cc

audio_04_75cf_Arpeggio:
; arpeggio of instrument $14
    audio_arp 1, 4                                     ;; 04:75cf
    audio_arp 1, 7                                     ;; 04:75d1
    audio_arp 1, 12                                    ;; 04:75d3
    audio_arp 1, 4                                     ;; 04:75d5
    audio_arp 1, 7                                     ;; 04:75d7
    audio_arp 1, 12                                    ;; 04:75d9
    audio_arp_loop audio_04_75cf_Arpeggio              ;; 04:75db

audio_04_75de_Arpeggio:
; arpeggio of instrument $15
    audio_arp 1, 7                                     ;; 04:75de
    audio_arp 1, 12                                    ;; 04:75e0
    audio_arp 1, 16                                    ;; 04:75e2
    audio_arp 1, 7                                     ;; 04:75e4
    audio_arp 1, 12                                    ;; 04:75e6
    audio_arp 1, 16                                    ;; 04:75e8
    audio_arp_loop audio_04_75de_Arpeggio              ;; 04:75ea

audio_04_75ed_Arpeggio:
; arpeggio of instrument $16
; arpeggio of instrument $1F
    audio_arp 1, 0                                     ;; 04:75ed
    audio_arp 1, 3                                     ;; 04:75ef
    audio_arp 1, 7                                     ;; 04:75f1
    audio_arp 1, 0                                     ;; 04:75f3
    audio_arp 1, 3                                     ;; 04:75f5
    audio_arp 1, 7                                     ;; 04:75f7
    audio_arp_loop audio_04_75ed_Arpeggio              ;; 04:75f9

audio_04_75fc_Arpeggio:
; arpeggio of instrument $17
    audio_arp 1, 3                                     ;; 04:75fc
    audio_arp 1, 7                                     ;; 04:75fe
    audio_arp 1, 12                                    ;; 04:7600
    audio_arp 1, 3                                     ;; 04:7602
    audio_arp 1, 7                                     ;; 04:7604
    audio_arp 1, 12                                    ;; 04:7606
    audio_arp_loop audio_04_75fc_Arpeggio              ;; 04:7608

audio_04_760b_Arpeggio:
; arpeggio of instrument $18
    audio_arp 1, 7                                     ;; 04:760b
    audio_arp 1, 12                                    ;; 04:760d
    audio_arp 1, 15                                    ;; 04:760f
    audio_arp 1, 7                                     ;; 04:7611
    audio_arp 1, 12                                    ;; 04:7613
    audio_arp 1, 15                                    ;; 04:7615
    audio_arp_loop audio_04_760b_Arpeggio              ;; 04:7617

audio_04_761a_Arpeggio:
; arpeggio of instrument $1A
    audio_arp 2, 12                                    ;; 04:761a
    audio_arp 2, 0                                     ;; 04:761c
    audio_arp 2, 12                                    ;; 04:761e
    audio_arp 2, 0                                     ;; 04:7620
    audio_arp 2, 12                                    ;; 04:7622
    audio_arp 2, 0                                     ;; 04:7624
    audio_arp_loop audio_04_761a_Arpeggio              ;; 04:7626

audio_04_7629_Arpeggio:
; arpeggio of instrument $1C
    audio_arp 6, 0                                     ;; 04:7629
    audio_arp 6, 2                                     ;; 04:762b
    audio_arp 6, 3                                     ;; 04:762d
    audio_arp 6, 7                                     ;; 04:762f
    audio_arp 6, 12                                    ;; 04:7631
    audio_arp 6, 14                                    ;; 04:7633
    audio_arp 6, 15                                    ;; 04:7635
    audio_arp 6, 19                                    ;; 04:7637
    audio_arp 6, 24                                    ;; 04:7639
    audio_arp 6, 19                                    ;; 04:763b
    audio_arp 6, 15                                    ;; 04:763d
    audio_arp 6, 14                                    ;; 04:763f
    audio_arp 6, 12                                    ;; 04:7641
    audio_arp 6, 7                                     ;; 04:7643
    audio_arp 6, 3                                     ;; 04:7645
    audio_arp 6, 2                                     ;; 04:7647
    audio_arp_loop audio_04_7629_Arpeggio              ;; 04:7649

audio_04_764c_Arpeggio:
; arpeggio of instrument $1D
    audio_arp 6, 0                                     ;; 04:764c
    audio_arp 6, 2                                     ;; 04:764e
    audio_arp 6, 4                                     ;; 04:7650
    audio_arp 6, 7                                     ;; 04:7652
    audio_arp 6, 12                                    ;; 04:7654
    audio_arp 6, 14                                    ;; 04:7656
    audio_arp 6, 16                                    ;; 04:7658
    audio_arp 6, 19                                    ;; 04:765a
    audio_arp 6, 24                                    ;; 04:765c
    audio_arp 6, 19                                    ;; 04:765e
    audio_arp 6, 16                                    ;; 04:7660
    audio_arp 6, 14                                    ;; 04:7662
    audio_arp 6, 12                                    ;; 04:7664
    audio_arp 6, 7                                     ;; 04:7666
    audio_arp 6, 4                                     ;; 04:7668
    audio_arp 6, 2                                     ;; 04:766a
    audio_arp_loop audio_04_764c_Arpeggio              ;; 04:766c

data_04_766f_PatternPointers:
; The patterns AUDIO_CMD_CALL_PATTERN can name. Its argument is doubled into a
; byte offset and the carry out of that doubling picks the second 256-byte half
; of the table, which is how one byte reaches 256 patterns. This bank stops at
; $76
    dw   audio_04_54e6_Pattern00                       ;; 04:766f  ; pattern $00
    dw   audio_04_56a7_Pattern01                       ;; 04:7671  ; pattern $01
    dw   audio_04_56e8_Pattern02                       ;; 04:7673  ; pattern $02
    dw   audio_04_5705_Pattern03                       ;; 04:7675  ; pattern $03
    dw   audio_04_5722_Pattern04                       ;; 04:7677  ; pattern $04
    dw   audio_04_5763_Pattern05                       ;; 04:7679  ; pattern $05
    dw   audio_04_57e2_Pattern06                       ;; 04:767b  ; pattern $06
    dw   audio_04_5863_Pattern07                       ;; 04:767d  ; pattern $07
    dw   audio_04_56c7_Pattern08                       ;; 04:767f  ; pattern $08
    dw   audio_04_58f4_Pattern09                       ;; 04:7681  ; pattern $09
    dw   audio_04_5935_Pattern0A                       ;; 04:7683  ; pattern $0A
    dw   audio_04_59d6_Pattern0B                       ;; 04:7685  ; pattern $0B
    dw   audio_04_5a6f_Pattern0C                       ;; 04:7687  ; pattern $0C
    dw   audio_04_5b18_Pattern0D                       ;; 04:7689  ; pattern $0D
    dw   audio_04_54e9_Pattern0E                       ;; 04:768b  ; pattern $0E
    dw   audio_04_553a_Pattern0F                       ;; 04:768d  ; pattern $0F
    dw   audio_04_558b_Pattern10                       ;; 04:768f  ; pattern $10
    dw   audio_04_55c8_Pattern11                       ;; 04:7691  ; pattern $11
    dw   audio_04_55dd_Pattern12                       ;; 04:7693  ; pattern $12
    dw   audio_04_55f0_Pattern13                       ;; 04:7695  ; pattern $13
    dw   audio_04_5641_Pattern14                       ;; 04:7697  ; pattern $14
    dw   audio_04_5692_Pattern15                       ;; 04:7699  ; pattern $15
    dw   audio_04_613b_Pattern16                       ;; 04:769b  ; pattern $16
    dw   audio_04_6058_Pattern17                       ;; 04:769d  ; pattern $17
    dw   audio_04_6069_Pattern18                       ;; 04:769f  ; pattern $18
    dw   audio_04_6076_Pattern19                       ;; 04:76a1  ; pattern $19
    dw   audio_04_6097_Pattern1A                       ;; 04:76a3  ; pattern $1A
    dw   audio_04_60bc_Pattern1B                       ;; 04:76a5  ; pattern $1B
    dw   audio_04_60c5_Pattern1C                       ;; 04:76a7  ; pattern $1C
    dw   audio_04_60ce_Pattern1D                       ;; 04:76a9  ; pattern $1D
    dw   audio_04_60d7_Pattern1E                       ;; 04:76ab  ; pattern $1E
    dw   audio_04_6118_Pattern1F                       ;; 04:76ad  ; pattern $1F
    dw   audio_04_5fdd_Pattern20                       ;; 04:76af  ; pattern $20
    dw   audio_04_5fea_Pattern21                       ;; 04:76b1  ; pattern $21
    dw   audio_04_6023_Pattern22                       ;; 04:76b3  ; pattern $22
    dw   audio_04_5da4_Pattern23                       ;; 04:76b5  ; pattern $23
    dw   audio_04_5db5_Pattern24                       ;; 04:76b7  ; pattern $24
    dw   audio_04_5dc4_Pattern25                       ;; 04:76b9  ; pattern $25
    dw   audio_04_5dfd_Pattern26                       ;; 04:76bb  ; pattern $26
    dw   audio_04_5e42_Pattern27                       ;; 04:76bd  ; pattern $27
    dw   audio_04_5e93_Pattern28                       ;; 04:76bf  ; pattern $28
    dw   audio_04_5f1a_Pattern29                       ;; 04:76c1  ; pattern $29
    dw   audio_04_5f9c_Pattern2A                       ;; 04:76c3  ; pattern $2A
    dw   audio_04_5d83_Pattern2B                       ;; 04:76c5  ; pattern $2B
    dw   audio_04_5d8e_Pattern2C                       ;; 04:76c7  ; pattern $2C
    dw   audio_04_5d99_Pattern2D                       ;; 04:76c9  ; pattern $2D
    dw   audio_04_5d32_Pattern2E                       ;; 04:76cb  ; pattern $2E
    dw   audio_04_5d11_Pattern2F                       ;; 04:76cd  ; pattern $2F
    dw   audio_04_5f63_Pattern30                       ;; 04:76cf  ; pattern $30
    dw   audio_04_5d11_Pattern2F                       ;; 04:76d1  ; pattern $31
    dw   audio_04_5d11_Pattern2F                       ;; 04:76d3  ; pattern $32
    dw   audio_04_5d11_Pattern2F                       ;; 04:76d5  ; pattern $33
    dw   audio_04_5d11_Pattern2F                       ;; 04:76d7  ; pattern $34
    dw   audio_04_5d11_Pattern2F                       ;; 04:76d9  ; pattern $35
    dw   audio_04_6715_Pattern36                       ;; 04:76db  ; pattern $36
    dw   audio_04_6557_Pattern37                       ;; 04:76dd  ; pattern $37
    dw   audio_04_6598_Pattern38                       ;; 04:76df  ; pattern $38
    dw   audio_04_664d_Pattern39                       ;; 04:76e1  ; pattern $39
    dw   audio_04_6696_Pattern3A                       ;; 04:76e3  ; pattern $3A
    dw   audio_04_66bb_Pattern3B                       ;; 04:76e5  ; pattern $3B
    dw   audio_04_6704_Pattern3C                       ;; 04:76e7  ; pattern $3C
    dw   audio_04_63d9_Pattern3D                       ;; 04:76e9  ; pattern $3D
    dw   audio_04_6400_Pattern3E                       ;; 04:76eb  ; pattern $3E
    dw   audio_04_644d_Pattern3F                       ;; 04:76ed  ; pattern $3F
    dw   audio_04_64aa_Pattern40                       ;; 04:76ef  ; pattern $40
    dw   audio_04_64e9_Pattern41                       ;; 04:76f1  ; pattern $41
    dw   audio_04_6554_Pattern42                       ;; 04:76f3  ; pattern $42
    dw   audio_04_6272_Pattern43                       ;; 04:76f5  ; pattern $43
    dw   audio_04_62b3_Pattern44                       ;; 04:76f7  ; pattern $44
    dw   audio_04_62d8_Pattern45                       ;; 04:76f9  ; pattern $45
    dw   audio_04_62eb_Pattern46                       ;; 04:76fb  ; pattern $46
    dw   audio_04_62fe_Pattern47                       ;; 04:76fd  ; pattern $47
    dw   audio_04_6311_Pattern48                       ;; 04:76ff  ; pattern $48
    dw   audio_04_635a_Pattern49                       ;; 04:7701  ; pattern $49
    dw   audio_04_637f_Pattern4A                       ;; 04:7703  ; pattern $4A
    dw   audio_04_63c8_Pattern4B                       ;; 04:7705  ; pattern $4B
    dw   audio_04_6904_Pattern4C                       ;; 04:7707  ; pattern $4C
    dw   audio_04_6917_Pattern4D                       ;; 04:7709  ; pattern $4D
    dw   audio_04_692a_Pattern4E                       ;; 04:770b  ; pattern $4E
    dw   audio_04_693b_Pattern4F                       ;; 04:770d  ; pattern $4F
    dw   audio_04_6890_Pattern50                       ;; 04:770f  ; pattern $50
    dw   audio_04_68a1_Pattern51                       ;; 04:7711  ; pattern $51
    dw   audio_04_68c2_Pattern52                       ;; 04:7713  ; pattern $52
    dw   audio_04_68e3_Pattern53                       ;; 04:7715  ; pattern $53
    dw   audio_04_67c8_Pattern54                       ;; 04:7717  ; pattern $54
    dw   audio_04_67e5_Pattern55                       ;; 04:7719  ; pattern $55
    dw   audio_04_680e_Pattern56                       ;; 04:771b  ; pattern $56
    dw   audio_04_682d_Pattern57                       ;; 04:771d  ; pattern $57
    dw   audio_04_684e_Pattern58                       ;; 04:771f  ; pattern $58
    dw   audio_04_686f_Pattern59                       ;; 04:7721  ; pattern $59
    dw   audio_04_7003_Pattern5A                       ;; 04:7723  ; pattern $5A
    dw   audio_04_7044_Pattern5B                       ;; 04:7725  ; pattern $5B
    dw   audio_04_6e8c_Pattern5C                       ;; 04:7727  ; pattern $5C
    dw   audio_04_6ead_Pattern5D                       ;; 04:7729  ; pattern $5D
    dw   audio_04_6ede_Pattern5E                       ;; 04:772b  ; pattern $5E
    dw   audio_04_6eff_Pattern5F                       ;; 04:772d  ; pattern $5F
    dw   audio_04_6f1c_Pattern60                       ;; 04:772f  ; pattern $60
    dw   audio_04_6f49_Pattern61                       ;; 04:7731  ; pattern $61
    dw   audio_04_6f68_Pattern62                       ;; 04:7733  ; pattern $62
    dw   audio_04_6fa7_Pattern63                       ;; 04:7735  ; pattern $63
    dw   audio_04_6fe2_Pattern64                       ;; 04:7737  ; pattern $64
    dw   audio_04_6c59_Pattern65                       ;; 04:7739  ; pattern $65
    dw   audio_04_6c7e_Pattern66                       ;; 04:773b  ; pattern $66
    dw   audio_04_6caf_Pattern67                       ;; 04:773d  ; pattern $67
    dw   audio_04_6cba_Pattern68                       ;; 04:773f  ; pattern $68
    dw   audio_04_6d33_Pattern69                       ;; 04:7741  ; pattern $69
    dw   audio_04_6d60_Pattern6A                       ;; 04:7743  ; pattern $6A
    dw   audio_04_6d7f_Pattern6B                       ;; 04:7745  ; pattern $6B
    dw   audio_04_6e18_Pattern6C                       ;; 04:7747  ; pattern $6C
    dw   audio_04_6e5b_Pattern6D                       ;; 04:7749  ; pattern $6D
    dw   audio_04_6b1d_Pattern6E                       ;; 04:774b  ; pattern $6E
    dw   audio_04_6b5e_Pattern6F                       ;; 04:774d  ; pattern $6F
    dw   audio_04_6bbb_Pattern70                       ;; 04:774f  ; pattern $70
    dw   audio_04_6bc6_Pattern71                       ;; 04:7751  ; pattern $71
    dw   audio_04_6bf3_Pattern72                       ;; 04:7753  ; pattern $72
    dw   audio_04_6c12_Pattern73                       ;; 04:7755  ; pattern $73
    dw   audio_04_6af4_Pattern74                       ;; 04:7757  ; pattern $74
    dw   audio_04_6ac3_Pattern75                       ;; 04:7759  ; pattern $75
    dw   audio_04_6a9a_Pattern76                       ;; 04:775b  ; pattern $76
