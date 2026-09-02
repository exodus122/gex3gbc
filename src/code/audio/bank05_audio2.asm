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
; A SONG IS FIVE POINTERS in data_05_717d_SongTable: one starting pattern per channel,
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
;                      data_05_461b_AudioCommandTable
;
; Commands re-enter the channel's update block through Audio_ResumeChannel when they
; finish, so any number of them can run before the note they precede; only
; AUDIO_CMD_SET_NOTE_LENGTH and a note end the channel's turn for this tick.
;
; AN INSTRUMENT is twelve bytes in data_05_71f1_InstrumentPointers' targets: the three
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
; data_05_4a59_SfxTrackIds to up to four tracks; each track names the hardware channel it
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
call_05_4000_Audio_Init:
    jp   call_05_40e3_Audio_ResetDriver                 ;; 05:4000 $c3 $e3 $40

call_05_4003_Audio_PlaySfxTrack:
; unused - starts one sfx track directly, bypassing data_05_4a59_SfxTrackIds
    jp   call_05_487b_Audio_StartSfxTrack               ;; 05:4003 $c3 $7b $48

call_05_4006_Audio_PlayMusic:
    jp   call_05_412b_Audio_StartSong                   ;; 05:4006 $c3 $2b $41

call_05_4009_Audio_Update:
    jp   call_05_402b_Audio_UpdateAll                   ;; 05:4009 $c3 $2b $40

call_05_400c_Audio_UpdateMusicOnly:
; unused
    jp   call_05_41cb_Audio_UpdateMusic                 ;; 05:400c $c3 $cb $41

call_05_400f_Audio_UpdateSfxOnly:
; unused
    jp   call_05_491e_Audio_UpdateSfx                   ;; 05:400f $c3 $1e $49

call_05_4012_Audio_Pause:
; unused
    jp   call_05_4065_Audio_SilenceAndPause             ;; 05:4012 $c3 $65 $40

call_05_4015_Audio_Resume:
; unused
    jp   call_05_4073_Audio_ResumeMusic                 ;; 05:4015 $c3 $73 $40

call_05_4018_Audio_VolumeDown:
; unused
    jp   call_05_4032_Audio_MasterVolumeDown            ;; 05:4018 $c3 $32 $40

call_05_401b_Audio_VolumeUp:
; unused
    jp   call_05_4079_Audio_MasterVolumeUp              ;; 05:401b $c3 $79 $40

call_05_401e_Audio_Stop:
; unused
    jp   call_05_4059_Audio_StopAll                     ;; 05:401e $c3 $59 $40

call_05_4021_Audio_SetTempo:
; unused
    jp   call_05_4027_Audio_SetTempoRate                ;; 05:4021 $c3 $27 $40

call_05_4024_Audio_PlaySfx:
    jp   call_05_40af_Audio_StartSfx                    ;; 05:4024 $c3 $af $40

call_05_4027_Audio_SetTempoRate:
; Sets how much wDF77_Audio_TempoAccumulator gains per frame. $FF - what
; Audio_StartSong installs - carries every frame, so the music runs at one tick per
; frame; smaller values drop ticks in proportion. AUDIO_CMD_SET_TEMPO does the same
; thing from inside a pattern
    ld   [wDF78_Audio_TempoRate], A                    ;; 05:4027 $ea $78 $df
    ret                                                ;; 05:402a $c9

call_05_402b_Audio_UpdateAll:
; The per-frame tick, called from the vblank handler with this bank mapped in. Music
; first so that a sound effect started this frame writes its registers last and wins
    call call_05_41cb_Audio_UpdateMusic                 ;; 05:402b $cd $cb $41
    call call_05_491e_Audio_UpdateSfx                  ;; 05:402e $cd $1e $49
    ret                                                ;; 05:4031 $c9

call_05_4032_Audio_MasterVolumeDown:
; Unused. Drops both halves of rNR50 by one step, and silences all four envelopes once
; both reach zero. Note the right half is rebuilt with AUDIO_NR50_VIN_RIGHT set but the
; left half is not, so a fade started from the $77 that Audio_ResetHardware writes ends
; up asymmetric
    ldh  A, [rNR50]                                    ;; 05:4032 $f0 $24
    and  A, AUDIO_NR50_VOLUME_RIGHT                    ;; 05:4034 $e6 $07
    jr   Z, .jr_05_403f                                ;; 05:4036 $28 $07
    dec  A                                             ;; 05:4038 $3d
    or   A, AUDIO_NR50_VIN_RIGHT                       ;; 05:4039 $f6 $08
    ld   B, A                                          ;; 05:403b $47
    jp   .jp_05_4041                                   ;; 05:403c $c3 $41 $40
.jr_05_403f:
    ld   B, $00                                        ;; 05:403f $06 $00
.jp_05_4041:
    ldh  A, [rNR50]                                    ;; 05:4041 $f0 $24
    and  A, AUDIO_NR50_VOLUME_LEFT                     ;; 05:4043 $e6 $70
    jr   Z, .jr_05_404c                                ;; 05:4045 $28 $05
    sub  A, $10                                        ;; 05:4047 $d6 $10
    jp   .jp_05_404e                                   ;; 05:4049 $c3 $4e $40
.jr_05_404c:
    ld   A, $00                                        ;; 05:404c $3e $00
.jp_05_404e:
    or   A, B                                          ;; 05:404e $b0
    cp   A, $00                                        ;; 05:404f $fe $00
    jr   NZ, .jr_05_4056                               ;; 05:4051 $20 $03
    call call_05_4065_Audio_SilenceAndPause            ;; 05:4053 $cd $65 $40
.jr_05_4056:
    ldh  [rNR50], A                                    ;; 05:4056 $e0 $24
    ret                                                ;; 05:4058 $c9

call_05_4059_Audio_StopAll:
; Unused. Kills panning and master volume outright and clears
; wDF76_Audio_MusicEnabled, so Audio_UpdateMusic returns immediately from then on. The
; channel blocks keep their state - a later Audio_ResumeMusic picks the song back up
; where it stopped
    xor  A, A                                          ;; 05:4059 $af
    ldh  [rNR51], A                                    ;; 05:405a $e0 $25
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:405c $ea $79 $df
    ldh  [rNR50], A                                    ;; 05:405f $e0 $24
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 05:4061 $ea $76 $df
    ret                                                ;; 05:4064 $c9

call_05_4065_Audio_SilenceAndPause:
; Unused on its own; Audio_MasterVolumeDown calls it when a fade bottoms out. Zeroes
; every channel's volume-envelope register and stops the music from advancing, without
; touching rNR50 or rNR51
    ld   A, $00                                        ;; 05:4065 $3e $00
    ldh  [rNR12], A                                    ;; 05:4067 $e0 $12
    ldh  [rNR22], A                                    ;; 05:4069 $e0 $17
    ldh  [rNR32], A                                    ;; 05:406b $e0 $1c
    ldh  [rNR42], A                                    ;; 05:406d $e0 $21
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 05:406f $ea $76 $df
    ret                                                ;; 05:4072 $c9

call_05_4073_Audio_ResumeMusic:
; Unused. Lets Audio_UpdateMusic run again. Audio_MasterVolumeUp calls it first, so a
; fade back in also un-pauses
    ld   A, $ff                                        ;; 05:4073 $3e $ff
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 05:4075 $ea $76 $df
    ret                                                ;; 05:4078 $c9

call_05_4079_Audio_MasterVolumeUp:
; Unused, and does not survive close reading. From silence it jumps straight to $88 -
; both VIN bits, both volumes zero - which is not audible; from anywhere else it raises
; each half by one step. Two bugs: when the right half is already $07 the `jr Z` skips
; the `ld B, A` that was supposed to carry it, so B holds whatever the last caller left
; there, and when the left half is already $07 the `ret Z` leaves rNR50 unwritten and
; the right half's increment is thrown away
    call call_05_4073_Audio_ResumeMusic                ;; 05:4079 $cd $73 $40
    ldh  A, [rNR50]                                    ;; 05:407c $f0 $24
    cp   A, $00                                        ;; 05:407e $fe $00
    jr   NZ, .jr_05_4087                               ;; 05:4080 $20 $05
    ld   A, AUDIO_NR50_VIN_LEFT | AUDIO_NR50_VIN_RIGHT ;; 05:4082 $3e $88
    ldh  [rNR50], A                                    ;; 05:4084 $e0 $24
    ret                                                ;; 05:4086 $c9
.jr_05_4087:
    and  A, AUDIO_NR50_VOLUME_RIGHT                    ;; 05:4087 $e6 $07
    cp   A, AUDIO_NR50_VOLUME_RIGHT                    ;; 05:4089 $fe $07
    jr   Z, .jr_05_4090                                ;; 05:408b $28 $03
    add  A, $01                                        ;; 05:408d $c6 $01
    ld   B, A                                          ;; 05:408f $47
.jr_05_4090:
    ldh  A, [rNR50]                                    ;; 05:4090 $f0 $24
    and  A, AUDIO_NR50_VOLUME_LEFT                     ;; 05:4092 $e6 $70
    srl  A                                             ;; 05:4094 $cb $3f
    srl  A                                             ;; 05:4096 $cb $3f
    srl  A                                             ;; 05:4098 $cb $3f
    srl  A                                             ;; 05:409a $cb $3f
    cp   A, AUDIO_NR50_VOLUME_RIGHT                    ;; 05:409c $fe $07
    ret  Z                                             ;; 05:409e $c8
    add  A, $01                                        ;; 05:409f $c6 $01
    sla  A                                             ;; 05:40a1 $cb $27
    sla  A                                             ;; 05:40a3 $cb $27
    sla  A                                             ;; 05:40a5 $cb $27
    sla  A                                             ;; 05:40a7 $cb $27
    or   A, B                                          ;; 05:40a9 $b0
    or   A, AUDIO_NR50_VIN_LEFT | AUDIO_NR50_VIN_RIGHT ;; 05:40aa $f6 $88
    ldh  [rNR50], A                                    ;; 05:40ac $e0 $24
    ret                                                ;; 05:40ae $c9

call_05_40af_Audio_StartSfx:
; Start sound effect id A. One SFX_* id is up to four driver tracks - a crash that wants
; noise and a pulse channel at once is two of them - so this reads that id's four-byte
; row out of data_05_4a59_SfxTrackIds and starts every entry that is not
; AUDIO_SFX_TRACK_NONE.
;
; The four tests are written out rather than looped, which is why the row is a fixed
; four bytes wide however few tracks an effect actually uses.
;
; gex2's call_00_113e_PlaySFX does the same fan-out, but in bank 0 rather than in the
; driver, and its driver tracks are one per hardware channel by construction
    add  A, A                                          ;; 05:40af $87
    add  A, A                                          ;; 05:40b0 $87
    ld   HL, data_05_4a59_SfxTrackIds                  ;; 05:40b1 $21 $59 $4a
    add  A, L                                          ;; 05:40b4 $85
    ld   L, A                                          ;; 05:40b5 $6f
    jr   NC, .jr_05_40b9                               ;; 05:40b6 $30 $01
    inc  H                                             ;; 05:40b8 $24
.jr_05_40b9:
    ld   A, [HL]                                       ;; 05:40b9 $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 05:40ba $fe $ff
    jr   Z, .jr_05_40c1                                ;; 05:40bc $28 $03
    call call_05_40dd_Audio_StartSfxTrackKeepHL        ;; 05:40be $cd $dd $40
.jr_05_40c1:
    inc  HL                                            ;; 05:40c1 $23
    ld   A, [HL]                                       ;; 05:40c2 $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 05:40c3 $fe $ff
    jr   Z, .jr_05_40ca                                ;; 05:40c5 $28 $03
    call call_05_40dd_Audio_StartSfxTrackKeepHL        ;; 05:40c7 $cd $dd $40
.jr_05_40ca:
    inc  HL                                            ;; 05:40ca $23
    ld   A, [HL]                                       ;; 05:40cb $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 05:40cc $fe $ff
    jr   Z, .jr_05_40d3                                ;; 05:40ce $28 $03
    call call_05_40dd_Audio_StartSfxTrackKeepHL        ;; 05:40d0 $cd $dd $40
.jr_05_40d3:
    inc  HL                                            ;; 05:40d3 $23
    ld   A, [HL]                                       ;; 05:40d4 $7e
    cp   A, AUDIO_SFX_TRACK_NONE                       ;; 05:40d5 $fe $ff
    jr   Z, .jr_05_40dc                                ;; 05:40d7 $28 $03
    call call_05_40dd_Audio_StartSfxTrackKeepHL        ;; 05:40d9 $cd $dd $40
.jr_05_40dc:
    ret                                                ;; 05:40dc $c9

call_05_40dd_Audio_StartSfxTrackKeepHL:
; Audio_StartSfxTrack destroys HL, and the caller is walking the id row with it
    push HL                                            ;; 05:40dd $e5
    call call_05_487b_Audio_StartSfxTrack              ;; 05:40de $cd $7b $48
    pop  HL                                            ;; 05:40e1 $e1
    ret                                                ;; 05:40e2 $c9

call_05_40e3_Audio_ResetDriver:
; Boot-time reset, called once from call_00_0150_Init.
;
; Turns the APU off and on to clear every register, drops the four sfx track pointers
; and the four channels' flag bytes, sets the tempo to full speed, loads the default
; wave pattern and then hands off to Audio_ResetHardware for the rest.
;
; Nothing here starts a song - the caller does that separately
    ld   A, $00                                        ;; 05:40e3 $3e $00
    ldh  [rNR52], A                                    ;; 05:40e5 $e0 $26
    nop                                                ;; 05:40e7 $00
    ldh  [rNR52], A                                    ;; 05:40e8 $e0 $26
    ld   [wDF68_Audio_Ch1_SfxPtrLo], A                 ;; 05:40ea $ea $68 $df
    ld   [wDF69_Audio_Ch1_SfxPtrHi], A                 ;; 05:40ed $ea $69 $df
    ld   [wDF6B_Audio_Ch2_SfxPtrLo], A                 ;; 05:40f0 $ea $6b $df
    ld   [wDF6C_Audio_Ch2_SfxPtrHi], A                 ;; 05:40f3 $ea $6c $df
    ld   [wDF6E_Audio_Ch3_SfxPtrLo], A                 ;; 05:40f6 $ea $6e $df
    ld   [wDF6F_Audio_Ch3_SfxPtrHi], A                 ;; 05:40f9 $ea $6f $df
    ld   [wDF71_Audio_Ch4_SfxPtrLo], A                 ;; 05:40fc $ea $71 $df
    ld   [wDF72_Audio_Ch4_SfxPtrHi], A                 ;; 05:40ff $ea $72 $df
    ld   [wDF00_Audio_Ch1_Flags], A                    ;; 05:4102 $ea $00 $df
    ld   [wDF18_Audio_Ch2_Flags], A                    ;; 05:4105 $ea $18 $df
    ld   [wDF30_Audio_Ch3_Flags], A                    ;; 05:4108 $ea $30 $df
    ld   [wDF48_Audio_Ch4_Flags], A                    ;; 05:410b $ea $48 $df
    ld   A, $ff                                        ;; 05:410e $3e $ff
    ld   [wDF78_Audio_TempoRate], A                    ;; 05:4110 $ea $78 $df
    ld   A, $01                                        ;; 05:4113 $3e $01
    ld   [wDF77_Audio_TempoAccumulator], A             ;; 05:4115 $ea $77 $df
    ld   DE, _AUD3WAVERAM                              ;; 05:4118 $11 $30 $ff
    ld   HL, data_05_49dd_InitialWaveRam               ;; 05:411b $21 $dd $49
    ld   B, $10                                        ;; 05:411e $06 $10
.jr_05_4120:
    ld   A, [HL]                                       ;; 05:4120 $7e
    ld   [DE], A                                       ;; 05:4121 $12
    inc  HL                                            ;; 05:4122 $23
    inc  DE                                            ;; 05:4123 $13
    dec  B                                             ;; 05:4124 $05
    jr   NZ, .jr_05_4120                               ;; 05:4125 $20 $f9
    call call_05_418b_Audio_ResetHardware              ;; 05:4127 $cd $8b $41
    ret                                                ;; 05:412a $c9

call_05_412b_Audio_StartSong:
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
    ld   L, A                                          ;; 05:412b $6f
    ld   H, $00                                        ;; 05:412c $26 $00
    add  HL, HL                                        ;; 05:412e $29
    ld   D, H                                          ;; 05:412f $54
    ld   E, L                                          ;; 05:4130 $5d
    add  HL, HL                                        ;; 05:4131 $29
    add  HL, HL                                        ;; 05:4132 $29
    add  HL, DE                                        ;; 05:4133 $19
    ld   DE, data_05_717d_SongTable                    ;; 05:4134 $11 $85 $70
    add  HL, DE                                        ;; 05:4137 $19
    ld   A, [HL+]                                      ;; 05:4138 $2a
    ld   [wDF02_Audio_Ch1_SeqPtrLo], A                 ;; 05:4139 $ea $02 $df
    ld   A, [HL+]                                      ;; 05:413c $2a
    ld   [wDF03_Audio_Ch1_SeqPtrHi], A                 ;; 05:413d $ea $03 $df
    ld   A, [HL+]                                      ;; 05:4140 $2a
    ld   [wDF1A_Audio_Ch2_SeqPtrLo], A                 ;; 05:4141 $ea $1a $df
    ld   A, [HL+]                                      ;; 05:4144 $2a
    ld   [wDF1B_Audio_Ch2_SeqPtrHi], A                 ;; 05:4145 $ea $1b $df
    ld   A, [HL+]                                      ;; 05:4148 $2a
    ld   [wDF32_Audio_Ch3_SeqPtrLo], A                 ;; 05:4149 $ea $32 $df
    ld   A, [HL+]                                      ;; 05:414c $2a
    ld   [wDF33_Audio_Ch3_SeqPtrHi], A                 ;; 05:414d $ea $33 $df
    ld   A, [HL+]                                      ;; 05:4150 $2a
    ld   [wDF4A_Audio_Ch4_SeqPtrLo], A                 ;; 05:4151 $ea $4a $df
    ld   A, [HL+]                                      ;; 05:4154 $2a
    ld   [wDF4B_Audio_Ch4_SeqPtrHi], A                 ;; 05:4155 $ea $4b $df
    ld   A, [HL+]                                      ;; 05:4158 $2a
    ld   [wDF60_Audio_NoteLengthTablePtrLo], A         ;; 05:4159 $ea $60 $df
    ld   A, [HL+]                                      ;; 05:415c $2a
    ld   [wDF61_Audio_NoteLengthTablePtrHi], A         ;; 05:415d $ea $61 $df
    ld   A, $01                                        ;; 05:4160 $3e $01
    ld   [wDF01_Audio_Ch1_NoteTimer], A                ;; 05:4162 $ea $01 $df
    ld   [wDF19_Audio_Ch2_NoteTimer], A                ;; 05:4165 $ea $19 $df
    ld   A, $02                                        ;; 05:4168 $3e $02
    ld   [wDF31_Audio_Ch3_NoteTimer], A                ;; 05:416a $ea $31 $df
    ld   [wDF49_Audio_Ch4_NoteTimer], A                ;; 05:416d $ea $49 $df
    ld   A, AUDIO_CHF_ENABLED | AUDIO_CHF_RUNNING      ;; 05:4170 $3e $03
    ld   [wDF00_Audio_Ch1_Flags], A                    ;; 05:4172 $ea $00 $df
    ld   [wDF18_Audio_Ch2_Flags], A                    ;; 05:4175 $ea $18 $df
    ld   [wDF30_Audio_Ch3_Flags], A                    ;; 05:4178 $ea $30 $df
    ld   [wDF48_Audio_Ch4_Flags], A                    ;; 05:417b $ea $48 $df
    ld   [wDF76_Audio_MusicEnabled], A                 ;; 05:417e $ea $76 $df
    ld   A, $ff                                        ;; 05:4181 $3e $ff
    ld   [wDF78_Audio_TempoRate], A                    ;; 05:4183 $ea $78 $df
    ld   A, $01                                        ;; 05:4186 $3e $01
    ld   [wDF77_Audio_TempoAccumulator], A             ;; 05:4188 $ea $77 $df

call_05_418b_Audio_ResetHardware:
; Falls out of Audio_StartSong, so every song change rebuilds the APU from scratch.
;
; Master enable, sweep off, everything panned to both sides, master volume $77, the wave
; channel's DAC on, all four volume envelopes silent, and the per-channel transpose and
; pattern-loop state cleared. Notes are inaudible until the first instrument writes a
; real envelope value, which is what stops the register clear from being heard
    ld   A, AUDIO_NR52_ALL_ON                          ;; 05:418b $3e $8f
    ldh  [rNR52], A                                    ;; 05:418d $e0 $26
    nop                                                ;; 05:418f $00
    nop                                                ;; 05:4190 $00
    ldh  [rNR52], A                                    ;; 05:4191 $e0 $26
    ld   A, $08                                        ;; 05:4193 $3e $08
    ldh  [rNR10], A                                    ;; 05:4195 $e0 $10
    ld   A, $ff                                        ;; 05:4197 $3e $ff
    ldh  [rNR51], A                                    ;; 05:4199 $e0 $25
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:419b $ea $79 $df
    ld   A, $77                                        ;; 05:419e $3e $77
    ldh  [rNR50], A                                    ;; 05:41a0 $e0 $24
    ld   A, $80                                        ;; 05:41a2 $3e $80
    ldh  [rNR30], A                                    ;; 05:41a4 $e0 $1a
    xor  A, A                                          ;; 05:41a6 $af
    ldh  [rNR12], A                                    ;; 05:41a7 $e0 $12
    ldh  [rNR22], A                                    ;; 05:41a9 $e0 $17
    ldh  [rNR32], A                                    ;; 05:41ab $e0 $1c
    ldh  [rNR42], A                                    ;; 05:41ad $e0 $21
    ld   [wDF14_Audio_Ch1_Transpose], A                ;; 05:41af $ea $14 $df
    ld   [wDF2C_Audio_Ch2_Transpose], A                ;; 05:41b2 $ea $2c $df
    ld   [wDF44_Audio_Ch3_Transpose], A                ;; 05:41b5 $ea $44 $df
    ld   [wDF5C_Audio_Ch4_Transpose], A                ;; 05:41b8 $ea $5c $df
    ld   [wDF15_Audio_Ch1_LoopActive], A               ;; 05:41bb $ea $15 $df
    ld   [wDF2D_Audio_Ch2_LoopActive], A               ;; 05:41be $ea $2d $df
    ld   [wDF45_Audio_Ch3_LoopActive], A               ;; 05:41c1 $ea $45 $df
    ld   [wDF5D_Audio_Ch4_LoopActive], A               ;; 05:41c4 $ea $5d $df
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 05:41c7 $ea $55 $df
    ret                                                ;; 05:41ca $c9

call_05_41cb_Audio_UpdateMusic:
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
    ld   A, [wDF76_Audio_MusicEnabled]                 ;; 05:41cb $fa $76 $df
    and  A, A                                          ;; 05:41ce $a7
    ret  Z                                             ;; 05:41cf $c8
    ld   A, [wDF78_Audio_TempoRate]                    ;; 05:41d0 $fa $78 $df
    ld   B, A                                          ;; 05:41d3 $47
    ld   A, [wDF77_Audio_TempoAccumulator]             ;; 05:41d4 $fa $77 $df
    add  A, B                                          ;; 05:41d7 $80
    ld   [wDF77_Audio_TempoAccumulator], A             ;; 05:41d8 $ea $77 $df
    ret  NC                                            ;; 05:41db $d0

.jr_05_41dc:
; --- channel 1, pulse A ---
    xor  A, A                                          ;; 05:41dc $af
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 05:41dd $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 05:41e0 $21 $62 $df
    ld   DE, .jr_05_41dc                               ;; 05:41e3 $11 $dc $41
    ld   [HL], E                                       ;; 05:41e6 $73
    inc  HL                                            ;; 05:41e7 $23
    ld   [HL], D                                       ;; 05:41e8 $72
    ld   A, [wDF14_Audio_Ch1_Transpose]                ;; 05:41e9 $fa $14 $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 05:41ec $ea $65 $df
    ld   HL, wDF00_Audio_Ch1_Flags                     ;; 05:41ef $21 $00 $df
    ld   DE, rNR11                                     ;; 05:41f2 $11 $11 $ff
    call call_05_44d4_Audio_RunSequence                ;; 05:41f5 $cd $d4 $44
    ld   A, [wDF00_Audio_Ch1_Flags]                    ;; 05:41f8 $fa $00 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 05:41fb $e6 $01
    jp   Z, .jp_05_429b                                ;; 05:41fd $ca $9b $42
    ld   A, [wDF69_Audio_Ch1_SfxPtrHi]                 ;; 05:4200 $fa $69 $df
    and  A, A                                          ;; 05:4203 $a7
    jp   NZ, .jp_05_429b                               ;; 05:4204 $c2 $9b $42
    ld   HL, wDF0A_Audio_Ch1_EnvelopeTimer             ;; 05:4207 $21 $0a $df
    ld   DE, wDF0B_Audio_Ch1_EnvelopePtrLo             ;; 05:420a $11 $0b $df
    ld   A, [DE]                                       ;; 05:420d $1a
    ld   C, A                                          ;; 05:420e $4f
    inc  DE                                            ;; 05:420f $13
    ld   A, [DE]                                       ;; 05:4210 $1a
    ld   B, A                                          ;; 05:4211 $47
    ld   DE, rNR12                                     ;; 05:4212 $11 $12 $ff
    call call_05_446c_Audio_StepVolumeEnvelope         ;; 05:4215 $cd $6c $44
    ld   DE, wDF0B_Audio_Ch1_EnvelopePtrLo             ;; 05:4218 $11 $0b $df
    ld   A, C                                          ;; 05:421b $79
    ld   [DE], A                                       ;; 05:421c $12
    ld   A, B                                          ;; 05:421d $78
    inc  DE                                            ;; 05:421e $13
    ld   [DE], A                                       ;; 05:421f $12
    ld   HL, wDF00_Audio_Ch1_Flags                     ;; 05:4220 $21 $00 $df
    ld   DE, rNR13                                     ;; 05:4223 $11 $13 $ff
    call call_05_45a7_Audio_WriteChannelRegs           ;; 05:4226 $cd $a7 $45
    ld   HL, wDF0D_Audio_Ch1_PitchTimer                ;; 05:4229 $21 $0d $df
    ld   DE, wDF0E_Audio_Ch1_PitchPtrLo                ;; 05:422c $11 $0e $df
    ld   A, [DE]                                       ;; 05:422f $1a
    ld   C, A                                          ;; 05:4230 $4f
    inc  DE                                            ;; 05:4231 $13
    ld   A, [DE]                                       ;; 05:4232 $1a
    ld   B, A                                          ;; 05:4233 $47
    ld   DE, wDF05_Audio_Ch1_NR13Shadow                ;; 05:4234 $11 $05 $df
    call call_05_4494_Audio_StepPitchSlide             ;; 05:4237 $cd $94 $44
    ld   DE, wDF0E_Audio_Ch1_PitchPtrLo                ;; 05:423a $11 $0e $df
    ld   A, C                                          ;; 05:423d $79
    ld   [DE], A                                       ;; 05:423e $12
    ld   A, B                                          ;; 05:423f $78
    inc  DE                                            ;; 05:4240 $13
    ld   [DE], A                                       ;; 05:4241 $12
    ld   A, [wDF10_Audio_Ch1_ArpTimer]                 ;; 05:4242 $fa $10 $df
    and  A, A                                          ;; 05:4245 $a7
    jr   Z, .jp_05_429b                                ;; 05:4246 $28 $53
    dec  A                                             ;; 05:4248 $3d
    ld   [wDF10_Audio_Ch1_ArpTimer], A                 ;; 05:4249 $ea $10 $df
    and  A, A                                          ;; 05:424c $a7
    jr   NZ, .jp_05_429b                               ;; 05:424d $20 $4c
    ld   A, [wDF11_Audio_Ch1_ArpPtrLo]                 ;; 05:424f $fa $11 $df
    ld   C, A                                          ;; 05:4252 $4f
    ld   A, [wDF12_Audio_Ch1_ArpPtrHi]                 ;; 05:4253 $fa $12 $df
    ld   B, A                                          ;; 05:4256 $47
    ld   A, [BC]                                       ;; 05:4257 $0a
    cp   A, AUDIO_ARP_LOOP                             ;; 05:4258 $fe $ff
    jr   Z, .jr_05_428c                                ;; 05:425a $28 $30
    ld   [wDF10_Audio_Ch1_ArpTimer], A                 ;; 05:425c $ea $10 $df
    inc  BC                                            ;; 05:425f $03
    ld   A, [BC]                                       ;; 05:4260 $0a
    ld   E, A                                          ;; 05:4261 $5f
    ld   A, [wDF7C_Audio_Ch1_CurrentNote]              ;; 05:4262 $fa $7c $df
    add  A, E                                          ;; 05:4265 $83
    push AF                                            ;; 05:4266 $f5
    ld   DE, data_05_481b_NoteFrequenciesHi            ;; 05:4267 $11 $1b $48
    add  A, E                                          ;; 05:426a $83
    ld   E, A                                          ;; 05:426b $5f
    jr   NC, .jr_05_426f                               ;; 05:426c $30 $01
    inc  D                                             ;; 05:426e $14
.jr_05_426f:
    ld   A, [DE]                                       ;; 05:426f $1a
    ld   [wDF04_Audio_Ch1_NR14Shadow], A               ;; 05:4270 $ea $04 $df
    pop  AF                                            ;; 05:4273 $f1
    ld   DE, data_05_47bb_NoteFrequenciesLo            ;; 05:4274 $11 $bb $47
    add  A, E                                          ;; 05:4277 $83
    ld   E, A                                          ;; 05:4278 $5f
    jr   NC, .jr_05_427c                               ;; 05:4279 $30 $01
    inc  D                                             ;; 05:427b $14
.jr_05_427c:
    ld   A, [DE]                                       ;; 05:427c $1a
    ld   [wDF05_Audio_Ch1_NR13Shadow], A               ;; 05:427d $ea $05 $df
    inc  BC                                            ;; 05:4280 $03
    ld   A, C                                          ;; 05:4281 $79
    ld   [wDF11_Audio_Ch1_ArpPtrLo], A                 ;; 05:4282 $ea $11 $df
    ld   A, B                                          ;; 05:4285 $78
    ld   [wDF12_Audio_Ch1_ArpPtrHi], A                 ;; 05:4286 $ea $12 $df
    jp   .jp_05_429b                                   ;; 05:4289 $c3 $9b $42
.jr_05_428c:
    ld   A, $01                                        ;; 05:428c $3e $01
    ld   [wDF10_Audio_Ch1_ArpTimer], A                 ;; 05:428e $ea $10 $df
    inc  BC                                            ;; 05:4291 $03
    ld   A, [BC]                                       ;; 05:4292 $0a
    ld   [wDF11_Audio_Ch1_ArpPtrLo], A                 ;; 05:4293 $ea $11 $df
    inc  BC                                            ;; 05:4296 $03
    ld   A, [BC]                                       ;; 05:4297 $0a
    ld   [wDF12_Audio_Ch1_ArpPtrHi], A                 ;; 05:4298 $ea $12 $df

.jp_05_429b:
; --- channel 2, pulse B ---
    ld   A, $01                                        ;; 05:429b $3e $01
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 05:429d $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 05:42a0 $21 $62 $df
    ld   DE, .jp_05_429b                               ;; 05:42a3 $11 $9b $42
    ld   [HL], E                                       ;; 05:42a6 $73
    inc  HL                                            ;; 05:42a7 $23
    ld   [HL], D                                       ;; 05:42a8 $72
    ld   A, [wDF2C_Audio_Ch2_Transpose]                ;; 05:42a9 $fa $2c $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 05:42ac $ea $65 $df
    ld   HL, wDF18_Audio_Ch2_Flags                     ;; 05:42af $21 $18 $df
    ld   DE, rNR21                                     ;; 05:42b2 $11 $16 $ff
    call call_05_44d4_Audio_RunSequence                ;; 05:42b5 $cd $d4 $44
    ld   A, [wDF18_Audio_Ch2_Flags]                    ;; 05:42b8 $fa $18 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 05:42bb $e6 $01
    jp   Z, .jp_05_435b                                ;; 05:42bd $ca $5b $43
    ld   A, [wDF6C_Audio_Ch2_SfxPtrHi]                 ;; 05:42c0 $fa $6c $df
    and  A, A                                          ;; 05:42c3 $a7
    jp   NZ, .jp_05_435b                               ;; 05:42c4 $c2 $5b $43
    ld   HL, wDF22_Audio_Ch2_EnvelopeTimer             ;; 05:42c7 $21 $22 $df
    ld   DE, wDF23_Audio_Ch2_EnvelopePtrLo             ;; 05:42ca $11 $23 $df
    ld   A, [DE]                                       ;; 05:42cd $1a
    ld   C, A                                          ;; 05:42ce $4f
    inc  DE                                            ;; 05:42cf $13
    ld   A, [DE]                                       ;; 05:42d0 $1a
    ld   B, A                                          ;; 05:42d1 $47
    ld   DE, rNR22                                     ;; 05:42d2 $11 $17 $ff
    call call_05_446c_Audio_StepVolumeEnvelope         ;; 05:42d5 $cd $6c $44
    ld   DE, wDF23_Audio_Ch2_EnvelopePtrLo             ;; 05:42d8 $11 $23 $df
    ld   A, C                                          ;; 05:42db $79
    ld   [DE], A                                       ;; 05:42dc $12
    ld   A, B                                          ;; 05:42dd $78
    inc  DE                                            ;; 05:42de $13
    ld   [DE], A                                       ;; 05:42df $12
    ld   HL, wDF18_Audio_Ch2_Flags                     ;; 05:42e0 $21 $18 $df
    ld   DE, rNR23                                     ;; 05:42e3 $11 $18 $ff
    call call_05_45a7_Audio_WriteChannelRegs           ;; 05:42e6 $cd $a7 $45
    ld   HL, wDF25_Audio_Ch2_PitchTimer                ;; 05:42e9 $21 $25 $df
    ld   DE, wDF26_Audio_Ch2_PitchPtrLo                ;; 05:42ec $11 $26 $df
    ld   A, [DE]                                       ;; 05:42ef $1a
    ld   C, A                                          ;; 05:42f0 $4f
    inc  DE                                            ;; 05:42f1 $13
    ld   A, [DE]                                       ;; 05:42f2 $1a
    ld   B, A                                          ;; 05:42f3 $47
    ld   DE, wDF1D_Audio_Ch2_NR23Shadow                ;; 05:42f4 $11 $1d $df
    call call_05_4494_Audio_StepPitchSlide             ;; 05:42f7 $cd $94 $44
    ld   DE, wDF26_Audio_Ch2_PitchPtrLo                ;; 05:42fa $11 $26 $df
    ld   A, C                                          ;; 05:42fd $79
    ld   [DE], A                                       ;; 05:42fe $12
    ld   A, B                                          ;; 05:42ff $78
    inc  DE                                            ;; 05:4300 $13
    ld   [DE], A                                       ;; 05:4301 $12
    ld   A, [wDF28_Audio_Ch2_ArpTimer]                 ;; 05:4302 $fa $28 $df
    and  A, A                                          ;; 05:4305 $a7
    jr   Z, .jp_05_435b                                ;; 05:4306 $28 $53
    dec  A                                             ;; 05:4308 $3d
    ld   [wDF28_Audio_Ch2_ArpTimer], A                 ;; 05:4309 $ea $28 $df
    and  A, A                                          ;; 05:430c $a7
    jr   NZ, .jp_05_435b                               ;; 05:430d $20 $4c
    ld   A, [wDF29_Audio_Ch2_ArpPtrLo]                 ;; 05:430f $fa $29 $df
    ld   C, A                                          ;; 05:4312 $4f
    ld   A, [wDF2A_Audio_Ch2_ArpPtrHi]                 ;; 05:4313 $fa $2a $df
    ld   B, A                                          ;; 05:4316 $47
    ld   A, [BC]                                       ;; 05:4317 $0a
    cp   A, AUDIO_ARP_LOOP                             ;; 05:4318 $fe $ff
    jr   Z, .jr_05_434c                                ;; 05:431a $28 $30
    ld   [wDF28_Audio_Ch2_ArpTimer], A                 ;; 05:431c $ea $28 $df
    inc  BC                                            ;; 05:431f $03
    ld   A, [BC]                                       ;; 05:4320 $0a
    ld   E, A                                          ;; 05:4321 $5f
    ld   A, [wDF7D_Audio_Ch2_CurrentNote]              ;; 05:4322 $fa $7d $df
    add  A, E                                          ;; 05:4325 $83
    push AF                                            ;; 05:4326 $f5
    ld   DE, data_05_481b_NoteFrequenciesHi            ;; 05:4327 $11 $1b $48
    add  A, E                                          ;; 05:432a $83
    ld   E, A                                          ;; 05:432b $5f
    jr   NC, .jr_05_432f                               ;; 05:432c $30 $01
    inc  D                                             ;; 05:432e $14
.jr_05_432f:
    ld   A, [DE]                                       ;; 05:432f $1a
    ld   [wDF1C_Audio_Ch2_NR24Shadow], A               ;; 05:4330 $ea $1c $df
    pop  AF                                            ;; 05:4333 $f1
    ld   DE, data_05_47bb_NoteFrequenciesLo            ;; 05:4334 $11 $bb $47
    add  A, E                                          ;; 05:4337 $83
    ld   E, A                                          ;; 05:4338 $5f
    jr   NC, .jr_05_433c                               ;; 05:4339 $30 $01
    inc  D                                             ;; 05:433b $14
.jr_05_433c:
    ld   A, [DE]                                       ;; 05:433c $1a
    ld   [wDF1D_Audio_Ch2_NR23Shadow], A               ;; 05:433d $ea $1d $df
    inc  BC                                            ;; 05:4340 $03
    ld   A, C                                          ;; 05:4341 $79
    ld   [wDF29_Audio_Ch2_ArpPtrLo], A                 ;; 05:4342 $ea $29 $df
    ld   A, B                                          ;; 05:4345 $78
    ld   [wDF2A_Audio_Ch2_ArpPtrHi], A                 ;; 05:4346 $ea $2a $df
    jp   .jp_05_435b                                   ;; 05:4349 $c3 $5b $43
.jr_05_434c:
    ld   A, $01                                        ;; 05:434c $3e $01
    ld   [wDF28_Audio_Ch2_ArpTimer], A                 ;; 05:434e $ea $28 $df
    inc  BC                                            ;; 05:4351 $03
    ld   A, [BC]                                       ;; 05:4352 $0a
    ld   [wDF29_Audio_Ch2_ArpPtrLo], A                 ;; 05:4353 $ea $29 $df
    inc  BC                                            ;; 05:4356 $03
    ld   A, [BC]                                       ;; 05:4357 $0a
    ld   [wDF2A_Audio_Ch2_ArpPtrHi], A                 ;; 05:4358 $ea $2a $df

.jp_05_435b:
; --- channel 3, wave. Writes its registers before stepping its envelope, the reverse
; of channels 1 and 2 ---
    ld   A, $02                                        ;; 05:435b $3e $02
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 05:435d $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 05:4360 $21 $62 $df
    ld   DE, .jp_05_435b                               ;; 05:4363 $11 $5b $43
    ld   [HL], E                                       ;; 05:4366 $73
    inc  HL                                            ;; 05:4367 $23
    ld   [HL], D                                       ;; 05:4368 $72
    ld   A, [wDF44_Audio_Ch3_Transpose]                ;; 05:4369 $fa $44 $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 05:436c $ea $65 $df
    ld   HL, wDF30_Audio_Ch3_Flags                     ;; 05:436f $21 $30 $df
    ld   DE, rNR31                                     ;; 05:4372 $11 $1b $ff
    call call_05_44d4_Audio_RunSequence                ;; 05:4375 $cd $d4 $44
    ld   A, [wDF30_Audio_Ch3_Flags]                    ;; 05:4378 $fa $30 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 05:437b $e6 $01
    jp   Z, .jp_05_441b                                ;; 05:437d $ca $1b $44
    ld   A, [wDF6F_Audio_Ch3_SfxPtrHi]                 ;; 05:4380 $fa $6f $df
    and  A, A                                          ;; 05:4383 $a7
    jp   NZ, .jp_05_441b                               ;; 05:4384 $c2 $1b $44
    ld   HL, wDF30_Audio_Ch3_Flags                     ;; 05:4387 $21 $30 $df
    ld   DE, rNR33                                     ;; 05:438a $11 $1d $ff
    call call_05_45a7_Audio_WriteChannelRegs           ;; 05:438d $cd $a7 $45
    ld   HL, wDF3A_Audio_Ch3_EnvelopeTimer             ;; 05:4390 $21 $3a $df
    ld   DE, wDF3B_Audio_Ch3_EnvelopePtrLo             ;; 05:4393 $11 $3b $df
    ld   A, [DE]                                       ;; 05:4396 $1a
    ld   C, A                                          ;; 05:4397 $4f
    inc  DE                                            ;; 05:4398 $13
    ld   A, [DE]                                       ;; 05:4399 $1a
    ld   B, A                                          ;; 05:439a $47
    ld   DE, rNR32                                     ;; 05:439b $11 $1c $ff
    call call_05_446c_Audio_StepVolumeEnvelope         ;; 05:439e $cd $6c $44
    ld   DE, wDF3B_Audio_Ch3_EnvelopePtrLo             ;; 05:43a1 $11 $3b $df
    ld   A, C                                          ;; 05:43a4 $79
    ld   [DE], A                                       ;; 05:43a5 $12
    ld   A, B                                          ;; 05:43a6 $78
    inc  DE                                            ;; 05:43a7 $13
    ld   [DE], A                                       ;; 05:43a8 $12
    ld   HL, wDF3D_Audio_Ch3_PitchTimer                ;; 05:43a9 $21 $3d $df
    ld   DE, wDF3E_Audio_Ch3_PitchPtrLo                ;; 05:43ac $11 $3e $df
    ld   A, [DE]                                       ;; 05:43af $1a
    ld   C, A                                          ;; 05:43b0 $4f
    inc  DE                                            ;; 05:43b1 $13
    ld   A, [DE]                                       ;; 05:43b2 $1a
    ld   B, A                                          ;; 05:43b3 $47
    ld   DE, wDF35_Audio_Ch3_NR33Shadow                ;; 05:43b4 $11 $35 $df
    call call_05_4494_Audio_StepPitchSlide             ;; 05:43b7 $cd $94 $44
    ld   DE, wDF3E_Audio_Ch3_PitchPtrLo                ;; 05:43ba $11 $3e $df
    ld   A, C                                          ;; 05:43bd $79
    ld   [DE], A                                       ;; 05:43be $12
    ld   A, B                                          ;; 05:43bf $78
    inc  DE                                            ;; 05:43c0 $13
    ld   [DE], A                                       ;; 05:43c1 $12
    ld   A, [wDF40_Audio_Ch3_ArpTimer]                 ;; 05:43c2 $fa $40 $df
    and  A, A                                          ;; 05:43c5 $a7
    jr   Z, .jp_05_441b                                ;; 05:43c6 $28 $53
    dec  A                                             ;; 05:43c8 $3d
    ld   [wDF40_Audio_Ch3_ArpTimer], A                 ;; 05:43c9 $ea $40 $df
    and  A, A                                          ;; 05:43cc $a7
    jr   NZ, .jp_05_441b                               ;; 05:43cd $20 $4c
    ld   A, [wDF41_Audio_Ch3_ArpPtrLo]                 ;; 05:43cf $fa $41 $df
    ld   C, A                                          ;; 05:43d2 $4f
    ld   A, [wDF42_Audio_Ch3_ArpPtrHi]                 ;; 05:43d3 $fa $42 $df
    ld   B, A                                          ;; 05:43d6 $47
    ld   A, [BC]                                       ;; 05:43d7 $0a
    cp   A, AUDIO_ARP_LOOP                             ;; 05:43d8 $fe $ff
    jr   Z, .jr_05_440c                                ;; 05:43da $28 $30
    ld   [wDF40_Audio_Ch3_ArpTimer], A                 ;; 05:43dc $ea $40 $df
    inc  BC                                            ;; 05:43df $03
    ld   A, [BC]                                       ;; 05:43e0 $0a
    ld   E, A                                          ;; 05:43e1 $5f
    ld   A, [wDF7E_Audio_Ch3_CurrentNote]              ;; 05:43e2 $fa $7e $df
    add  A, E                                          ;; 05:43e5 $83
    push AF                                            ;; 05:43e6 $f5
    ld   DE, data_05_481b_NoteFrequenciesHi            ;; 05:43e7 $11 $1b $48
    add  A, E                                          ;; 05:43ea $83
    ld   E, A                                          ;; 05:43eb $5f
    jr   NC, .jr_05_43ef                               ;; 05:43ec $30 $01
    inc  D                                             ;; 05:43ee $14
.jr_05_43ef:
    ld   A, [DE]                                       ;; 05:43ef $1a
    ld   [wDF34_Audio_Ch3_NR34Shadow], A               ;; 05:43f0 $ea $34 $df
    pop  AF                                            ;; 05:43f3 $f1
    ld   DE, data_05_47bb_NoteFrequenciesLo            ;; 05:43f4 $11 $bb $47
    add  A, E                                          ;; 05:43f7 $83
    ld   E, A                                          ;; 05:43f8 $5f
    jr   NC, .jr_05_43fc                               ;; 05:43f9 $30 $01
    inc  D                                             ;; 05:43fb $14
.jr_05_43fc:
    ld   A, [DE]                                       ;; 05:43fc $1a
    ld   [wDF35_Audio_Ch3_NR33Shadow], A               ;; 05:43fd $ea $35 $df
    inc  BC                                            ;; 05:4400 $03
    ld   A, C                                          ;; 05:4401 $79
    ld   [wDF41_Audio_Ch3_ArpPtrLo], A                 ;; 05:4402 $ea $41 $df
    ld   A, B                                          ;; 05:4405 $78
    ld   [wDF42_Audio_Ch3_ArpPtrHi], A                 ;; 05:4406 $ea $42 $df
    jp   .jp_05_441b                                   ;; 05:4409 $c3 $1b $44
.jr_05_440c:
    ld   A, $01                                        ;; 05:440c $3e $01
    ld   [wDF40_Audio_Ch3_ArpTimer], A                 ;; 05:440e $ea $40 $df
    inc  BC                                            ;; 05:4411 $03
    ld   A, [BC]                                       ;; 05:4412 $0a
    ld   [wDF41_Audio_Ch3_ArpPtrLo], A                 ;; 05:4413 $ea $41 $df
    inc  BC                                            ;; 05:4416 $03
    ld   A, [BC]                                       ;; 05:4417 $0a
    ld   [wDF42_Audio_Ch3_ArpPtrHi], A                 ;; 05:4418 $ea $42 $df

.jp_05_441b:
; --- channel 4, noise. No arpeggio; its period comes from Audio_StepNoisePeriod and
; the register write happens whether or not a sound effect owns the channel, because
; Audio_WriteChannelRegs tests AUDIO_CHF_ENABLED for itself ---
    ld   A, $03                                        ;; 05:441b $3e $03
    ld   [wDF7B_Audio_ChannelIndex], A                 ;; 05:441d $ea $7b $df
    ld   HL, wDF62_Audio_ChannelResumePtrLo            ;; 05:4420 $21 $62 $df
    ld   DE, .jp_05_441b                               ;; 05:4423 $11 $1b $44
    ld   [HL], E                                       ;; 05:4426 $73
    inc  HL                                            ;; 05:4427 $23
    ld   [HL], D                                       ;; 05:4428 $72
    ld   A, [wDF5C_Audio_Ch4_Transpose]                ;; 05:4429 $fa $5c $df
    ld   [wDF65_Audio_CurrentTranspose], A             ;; 05:442c $ea $65 $df
    ld   HL, wDF48_Audio_Ch4_Flags                     ;; 05:442f $21 $48 $df
    ld   DE, rNR41                                     ;; 05:4432 $11 $20 $ff
    call call_05_44d4_Audio_RunSequence                ;; 05:4435 $cd $d4 $44
    ld   A, [wDF48_Audio_Ch4_Flags]                    ;; 05:4438 $fa $48 $df
    and  A, AUDIO_CHF_ENABLED                          ;; 05:443b $e6 $01
    jr   Z, .jp_05_4462                                ;; 05:443d $28 $23
    ld   A, [wDF72_Audio_Ch4_SfxPtrHi]                 ;; 05:443f $fa $72 $df
    and  A, A                                          ;; 05:4442 $a7
    jp   NZ, .jp_05_4462                               ;; 05:4443 $c2 $62 $44
    ld   HL, wDF52_Audio_Ch4_EnvelopeTimer             ;; 05:4446 $21 $52 $df
    ld   DE, wDF53_Audio_Ch4_EnvelopePtrLo             ;; 05:4449 $11 $53 $df
    ld   A, [DE]                                       ;; 05:444c $1a
    ld   C, A                                          ;; 05:444d $4f
    inc  DE                                            ;; 05:444e $13
    ld   A, [DE]                                       ;; 05:444f $1a
    ld   B, A                                          ;; 05:4450 $47
    ld   DE, rNR42                                     ;; 05:4451 $11 $21 $ff
    call call_05_446c_Audio_StepVolumeEnvelope         ;; 05:4454 $cd $6c $44
    ld   DE, wDF53_Audio_Ch4_EnvelopePtrLo             ;; 05:4457 $11 $53 $df
    ld   A, C                                          ;; 05:445a $79
    ld   [DE], A                                       ;; 05:445b $12
    ld   A, B                                          ;; 05:445c $78
    inc  DE                                            ;; 05:445d $13
    ld   [DE], A                                       ;; 05:445e $12
    call call_05_45de_Audio_StepNoisePeriod            ;; 05:445f $cd $de $45
.jp_05_4462:
    ld   HL, wDF48_Audio_Ch4_Flags                     ;; 05:4462 $21 $48 $df
    ld   DE, rNR43                                     ;; 05:4465 $11 $22 $ff
    call call_05_45a7_Audio_WriteChannelRegs           ;; 05:4468 $cd $a7 $45
    ret                                                ;; 05:446b $c9

call_05_446c_Audio_StepVolumeEnvelope:
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
    ld   A, [HL]                                       ;; 05:446c $7e
    and  A, A                                          ;; 05:446d $a7
    ret  Z                                             ;; 05:446e $c8
    dec  [HL]                                          ;; 05:446f $35
    ret  NZ                                            ;; 05:4470 $c0
    ld   A, [BC]                                       ;; 05:4471 $0a
    cp   A, AUDIO_ENV_END                              ;; 05:4472 $fe $ff
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
    sub  A, AUDIO_CH_ENV_TIMER - AUDIO_CH_NRX4_SHADOW  ;; 05:447f $d6 $06
    ld   L, A                                          ;; 05:4481 $6f
    jr   NC, .jr_05_4485                               ;; 05:4482 $30 $01
    dec  H                                             ;; 05:4484 $25
.jr_05_4485:
    ld   A, [HL]                                       ;; 05:4485 $7e
    or   A, AUDIO_NRX4_TRIGGER                         ;; 05:4486 $f6 $80
    ld   [HL], A                                       ;; 05:4488 $77
    ld   A, L                                          ;; 05:4489 $7d
    add  A, AUDIO_CH_NRX2_SHADOW - AUDIO_CH_NRX4_SHADOW ;; 05:448a $c6 $04
    ld   L, A                                          ;; 05:448c $6f
    jr   NC, .jr_05_4490                               ;; 05:448d $30 $01
    inc  H                                             ;; 05:448f $24
.jr_05_4490:
    ld   A, [DE]                                       ;; 05:4490 $1a
    ld   [HL], A                                       ;; 05:4491 $77
    inc  BC                                            ;; 05:4492 $03
    ret                                                ;; 05:4493 $c9

call_05_4494_Audio_StepPitchSlide:
; One tick of a channel's pitch slide - vibrato, bends, drops, whatever the instrument
; asks for. HL points at AUDIO_CH_PITCH_TIMER, BC at the position in the slide, DE at
; the channel's AUDIO_CH_NRX3_SHADOW.
;
; A slide is pairs of (signed offset, frames to hold), and the offset is added to the
; channel's NRx4:NRx3 shadow pair read as one 16-bit number - so a slide that pushes the
; frequency past $FF carries into the register that also holds the trigger bit, which is
; exactly what the bigger bends rely on. AUDIO_PITCH_END stops; AUDIO_PITCH_LOOP takes a
; two-byte address and jumps
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
    cp   A, AUDIO_PITCH_END                            ;; 05:44a4 $fe $7e
    jr   NZ, .jr_05_44aa                               ;; 05:44a6 $20 $02
    pop  HL                                            ;; 05:44a8 $e1
    ret                                                ;; 05:44a9 $c9
.jr_05_44aa:
    cp   A, AUDIO_PITCH_LOOP                           ;; 05:44aa $fe $7d
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

call_05_44d4_Audio_RunSequence:
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
    ld   A, [HL]                                       ;; 05:44d4 $7e
    and  A, AUDIO_CHF_RUNNING                          ;; 05:44d5 $e6 $02
    ret  Z                                             ;; 05:44d7 $c8
    inc  HL                                            ;; 05:44d8 $23
    dec  [HL]                                          ;; 05:44d9 $35
    ret  NZ                                            ;; 05:44da $c0
    inc  HL                                            ;; 05:44db $23
    ld   C, [HL]                                       ;; 05:44dc $4e
    inc  HL                                            ;; 05:44dd $23
    ld   B, [HL]                                       ;; 05:44de $46
    ld   A, [BC]                                       ;; 05:44df $0a
    ld   [wDF66_Audio_CurrentNoteByte], A              ;; 05:44e0 $ea $66 $df
    and  A, AUDIO_NOTE_INDEX_MASK                      ;; 05:44e3 $e6 $7f
    cp   A, AUDIO_CMD_FIRST - 1                        ;; 05:44e5 $fe $5f
    jp   NC, call_05_4637_Audio_DispatchCommand        ;; 05:44e7 $d2 $37 $46
    push DE                                            ;; 05:44ea $d5
    ld   DE, wDF65_Audio_CurrentTranspose              ;; 05:44eb $11 $65 $df
    ld   A, [DE]                                       ;; 05:44ee $1a
    ld   D, A                                          ;; 05:44ef $57
    ld   A, [BC]                                       ;; 05:44f0 $0a
    and  A, AUDIO_NOTE_INDEX_MASK                      ;; 05:44f1 $e6 $7f
    add  A, D                                          ;; 05:44f3 $82
    ld   D, A                                          ;; 05:44f4 $57
    push AF                                            ;; 05:44f5 $f5
    ld   A, [wDF7B_Audio_ChannelIndex]                 ;; 05:44f6 $fa $7b $df
    cp   A, $00                                        ;; 05:44f9 $fe $00
    jr   NZ, .jr_05_4501                               ;; 05:44fb $20 $04
    ld   A, D                                          ;; 05:44fd $7a
    ld   [wDF7C_Audio_Ch1_CurrentNote], A              ;; 05:44fe $ea $7c $df
.jr_05_4501:
    cp   A, $01                                        ;; 05:4501 $fe $01
    jr   NZ, .jr_05_4509                               ;; 05:4503 $20 $04
    ld   A, D                                          ;; 05:4505 $7a
    ld   [wDF7D_Audio_Ch2_CurrentNote], A              ;; 05:4506 $ea $7d $df
.jr_05_4509:
    cp   A, $02                                        ;; 05:4509 $fe $02
    jr   NZ, .jr_05_4511                               ;; 05:450b $20 $04
    ld   A, D                                          ;; 05:450d $7a
    ld   [wDF7E_Audio_Ch3_CurrentNote], A              ;; 05:450e $ea $7e $df
.jr_05_4511:
    pop  AF                                            ;; 05:4511 $f1
    ld   DE, data_05_481b_NoteFrequenciesHi            ;; 05:4512 $11 $1b $48
    add  A, E                                          ;; 05:4515 $83
    ld   E, A                                          ;; 05:4516 $5f
    jp   NC, .jp_05_451b                               ;; 05:4517 $d2 $1b $45
    inc  D                                             ;; 05:451a $14
.jp_05_451b:
    ld   A, [DE]                                       ;; 05:451b $1a
    inc  HL                                            ;; 05:451c $23
    ld   [HL], A                                       ;; 05:451d $77
    ld   DE, wDF65_Audio_CurrentTranspose              ;; 05:451e $11 $65 $df
    ld   A, [DE]                                       ;; 05:4521 $1a
    ld   D, A                                          ;; 05:4522 $57
    ld   A, [BC]                                       ;; 05:4523 $0a
    and  A, AUDIO_NOTE_INDEX_MASK                      ;; 05:4524 $e6 $7f
    add  A, D                                          ;; 05:4526 $82
    ld   DE, data_05_47bb_NoteFrequenciesLo            ;; 05:4527 $11 $bb $47
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
    and  A, AUDIO_NOTE_LENGTH_MASK                     ;; 05:4534 $e6 $0f
    push HL                                            ;; 05:4536 $e5
    ld   HL, wDF61_Audio_NoteLengthTablePtrHi          ;; 05:4537 $21 $61 $df
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
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_NRX3_SHADOW ;; 05:4544 $11 $fc $ff
    add  HL, DE                                        ;; 05:4547 $19
    ld   [HL], A                                       ;; 05:4548 $77
    ld   A, [wDF66_Audio_CurrentNoteByte]              ;; 05:4549 $fa $66 $df
    and  A, AUDIO_NOTE_INSTRUMENT_BANK                 ;; 05:454c $e6 $80
    srl  A                                             ;; 05:454e $cb $3f
    srl  A                                             ;; 05:4550 $cb $3f
    ld   D, A                                          ;; 05:4552 $57
    ld   A, [BC]                                       ;; 05:4553 $0a
    and  A, AUDIO_NOTE_INSTRUMENT_MASK                 ;; 05:4554 $e6 $f0
    srl  A                                             ;; 05:4556 $cb $3f
    srl  A                                             ;; 05:4558 $cb $3f
    srl  A                                             ;; 05:455a $cb $3f
    add  A, D                                          ;; 05:455c $82
    push HL                                            ;; 05:455d $e5
    ld   HL, data_05_71f1_InstrumentPointers           ;; 05:455e $21 $d1 $70
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

call_05_45a7_Audio_WriteChannelRegs:
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
    ld   A, [HL]                                       ;; 05:45a7 $7e
    and  A, AUDIO_CHF_ENABLED                          ;; 05:45a8 $e6 $01
    ret  Z                                             ;; 05:45aa $c8
    ld   BC, AUDIO_CH_NRX3_SHADOW                      ;; 05:45ab $01 $05 $00
    add  HL, BC                                        ;; 05:45ae $09
    ld   A, E                                          ;; 05:45af $7b
    cp   A, LOW(rNR43)                                 ;; 05:45b0 $fe $22
    jp   Z, .jp_05_45d5                                ;; 05:45b2 $ca $d5 $45
    ld   A, [HL]                                       ;; 05:45b5 $7e
    ld   [DE], A                                       ;; 05:45b6 $12
.jr_05_45b7:
    dec  HL                                            ;; 05:45b7 $2b
    inc  DE                                            ;; 05:45b8 $13
    push DE                                            ;; 05:45b9 $d5
    push HL                                            ;; 05:45ba $e5
    ld   A, [HL]                                       ;; 05:45bb $7e
    and  A, AUDIO_NRX4_TRIGGER                         ;; 05:45bc $e6 $80
    jr   Z, .jr_05_45cd                                ;; 05:45be $28 $0d
    ld   BC, AUDIO_CH_NRX1_SHADOW - AUDIO_CH_NRX4_SHADOW ;; 05:45c0 $01 $03 $00
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
    and  A, ~AUDIO_NRX4_TRIGGER & $ff                  ;; 05:45d1 $e6 $7f
    ld   [HL], A                                       ;; 05:45d3 $77
    ret                                                ;; 05:45d4 $c9
.jp_05_45d5:
    ld   A, [wDF64_Audio_NoisePeriod]                  ;; 05:45d5 $fa $64 $df
    ld   [wDF4D_Audio_Ch4_NR43Shadow], A               ;; 05:45d8 $ea $4d $df
    ld   [DE], A                                       ;; 05:45db $12
    jr   .jr_05_45b7                                   ;; 05:45dc $18 $d9

call_05_45de_Audio_StepNoisePeriod:
; The noise channel's stand-in for a pitch slide. It reuses channel 4's
; AUDIO_CH_PITCH_TIMER and AUDIO_CH_PITCH_PTR slots, but the data is absolute NR43
; values rather than signed offsets, because a polynomial counter setting has nothing to
; add to.
;
; Pairs of (NR43 value, frames to hold), with AUDIO_PITCH_END stopping and
; AUDIO_PITCH_LOOP taking a two-byte address - the same two terminators
; Audio_StepPitchSlide uses. The value lands in wDF64_Audio_NoisePeriod, which
; Audio_WriteChannelRegs picks up
    ld   A, [wDF55_Audio_Ch4_PitchTimer]               ;; 05:45de $fa $55 $df
    and  A, A                                          ;; 05:45e1 $a7
    ret  Z                                             ;; 05:45e2 $c8
    dec  A                                             ;; 05:45e3 $3d
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 05:45e4 $ea $55 $df
    and  A, A                                          ;; 05:45e7 $a7
    ret  NZ                                            ;; 05:45e8 $c0
    ld   A, [wDF56_Audio_Ch4_PitchPtrLo]               ;; 05:45e9 $fa $56 $df
    ld   L, A                                          ;; 05:45ec $6f
    ld   A, [wDF57_Audio_Ch4_PitchPtrHi]               ;; 05:45ed $fa $57 $df
    ld   H, A                                          ;; 05:45f0 $67
    ld   A, [HL]                                       ;; 05:45f1 $7e
    cp   A, AUDIO_PITCH_END                            ;; 05:45f2 $fe $7e
    ret  Z                                             ;; 05:45f4 $c8
    cp   A, AUDIO_PITCH_LOOP                           ;; 05:45f5 $fe $7d
    jr   Z, .jr_05_460b                                ;; 05:45f7 $28 $12
    ld   [wDF64_Audio_NoisePeriod], A                  ;; 05:45f9 $ea $64 $df
    inc  HL                                            ;; 05:45fc $23
    ld   A, [HL]                                       ;; 05:45fd $7e
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 05:45fe $ea $55 $df
    inc  HL                                            ;; 05:4601 $23
    ld   A, L                                          ;; 05:4602 $7d
    ld   [wDF56_Audio_Ch4_PitchPtrLo], A               ;; 05:4603 $ea $56 $df
    ld   A, H                                          ;; 05:4606 $7c
    ld   [wDF57_Audio_Ch4_PitchPtrHi], A               ;; 05:4607 $ea $57 $df
    ret                                                ;; 05:460a $c9
.jr_05_460b:
    ld   A, $01                                        ;; 05:460b $3e $01
    ld   [wDF55_Audio_Ch4_PitchTimer], A               ;; 05:460d $ea $55 $df
    inc  HL                                            ;; 05:4610 $23
    ld   A, [HL]                                       ;; 05:4611 $7e
    ld   [wDF56_Audio_Ch4_PitchPtrLo], A               ;; 05:4612 $ea $56 $df
    inc  HL                                            ;; 05:4615 $23
    ld   A, [HL]                                       ;; 05:4616 $7e
    ld   [wDF57_Audio_Ch4_PitchPtrHi], A               ;; 05:4617 $ea $57 $df
    ret                                                ;; 05:461a $c9

data_05_461b_AudioCommandTable:
; One address per AUDIO_CMD_*, in opcode order from AUDIO_CMD_SET_NOTE_LENGTH. The
; dispatcher indexes it from its second byte and reads the high byte first, which is why
; every reference to it in code is written as `+ 1`
    dw   call_05_464b_AudioCmd_SetNoteLength           ; $60
    dw   call_05_4667_AudioCmd_End                     ; $61
    dw   call_05_4670_AudioCmd_Goto                    ; $62
    dw   call_05_4681_AudioCmd_SetNoisePeriod          ; $63
    dw   call_05_4695_AudioCmd_CallPattern             ; $64
    dw   call_05_46e0_AudioCmd_EndPattern              ; $65
    dw   call_05_4719_AudioCmd_SetMarker               ; $66
    dw   call_05_472d_AudioCmd_SetPanning              ; $67
    dw   call_05_4782_AudioCmd_SetNoteLengthTable      ; $68
    dw   call_05_479a_AudioCmd_SetTempo                ; $69
    dw   call_05_4742_AudioCmd_SetPanningCh1           ; $6A
    dw   call_05_4752_AudioCmd_SetPanningCh2           ; $6B
    dw   call_05_4762_AudioCmd_SetPanningCh3           ; $6C
    dw   call_05_4772_AudioCmd_SetPanningCh4           ; $6D

call_05_4637_Audio_DispatchCommand:
; Reached by `jp` from Audio_RunSequence with A holding the command byte's low seven
; bits, BC on the command in the pattern and HL on AUDIO_CH_SEQ_PTR_HI.
;
; The note timer, which Audio_RunSequence has just decremented to zero, is put back to 1
; so that the channel comes round again on the very next tick if the handler does not
; set a real duration itself.
;
; HL is pushed for the handler to pop - which is also what lets a handler discard the
; return address by jumping to Audio_ResumeChannel instead of returning
    sub  A, AUDIO_CMD_SET_NOTE_LENGTH                  ;; 05:4637 $d6 $60
    add  A, A                                          ;; 05:4639 $87
    push HL                                            ;; 05:463a $e5
    dec  HL                                            ;; 05:463b $2b
    dec  HL                                            ;; 05:463c $2b
    inc  [HL]                                          ;; 05:463d $34
    ld   HL, data_05_461b_AudioCommandTable + 1        ;; 05:463e $21 $1c $46
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

call_05_464b_AudioCmd_SetNoteLength:
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
    ld   HL, wDF61_Audio_NoteLengthTablePtrHi          ;; 05:464b $21 $61 $df
    ld   A, [HL]                                       ;; 05:464e $7e
    dec  HL                                            ;; 05:464f $2b
    ld   L, [HL]                                       ;; 05:4650 $6e
    ld   H, A                                          ;; 05:4651 $67
    inc  BC                                            ;; 05:4652 $03
    ld   A, [BC]                                       ;; 05:4653 $0a
    and  A, AUDIO_NOTE_LENGTH_MASK                     ;; 05:4654 $e6 $0f
    add  A, L                                          ;; 05:4656 $85
    ld   L, A                                          ;; 05:4657 $6f
    jr   .jr_05_465b                                   ;; 05:4658 $18 $01
    inc  H                                             ;; 05:465a $24
.jr_05_465b:
    ld   A, [HL]                                       ;; 05:465b $7e
    pop  HL                                            ;; 05:465c $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:465d $11 $fe $ff
    add  HL, DE                                        ;; 05:4660 $19
    ld   [HL], A                                       ;; 05:4661 $77
    inc  BC                                            ;; 05:4662 $03
    inc  HL                                            ;; 05:4663 $23
    jp   call_05_47ad_Audio_StoreSeqPtr                ;; 05:4664 $c3 $ad $47

call_05_4667_AudioCmd_End:
; $61 - stop the channel. Clearing the flag byte drops both AUDIO_CHF_ENABLED and
; AUDIO_CHF_RUNNING, so nothing reads the pattern again and nothing writes the
; registers again; whatever note was sounding decays on its own.
;
; gex2's AUDIO_CMD_END also hands the channel back to the music when a sound effect ends;
; here that is Audio_StepSfxTrack's job instead
    pop  HL                                            ;; 05:4667 $e1
    ld   BC, AUDIO_CH_FLAGS - AUDIO_CH_SEQ_PTR_HI      ;; 05:4668 $01 $fd $ff
    add  HL, BC                                        ;; 05:466b $09
    ld   A, $00                                        ;; 05:466c $3e $00
    ld   [HL], A                                       ;; 05:466e $77
    ret                                                ;; 05:466f $c9

call_05_4670_AudioCmd_Goto:
; $62 ll hh - jump to an absolute address. Unlike gex2's AUDIO_CMD_LOOP, which stores a
; backwards distance, gex3 writes the target out in full, so a pattern can be jumped to
; from anywhere. The note timer is set to 1 so the new position is read on the next tick
    pop  HL                                            ;; 05:4670 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:4671 $11 $fe $ff
    add  HL, DE                                        ;; 05:4674 $19
    ld   A, $01                                        ;; 05:4675 $3e $01
    ld   [HL+], A                                      ;; 05:4677 $22
    inc  BC                                            ;; 05:4678 $03
    ld   A, [BC]                                       ;; 05:4679 $0a
    ld   [HL+], A                                      ;; 05:467a $22
    inc  BC                                            ;; 05:467b $03
    ld   A, [BC]                                       ;; 05:467c $0a
    ld   [HL], A                                       ;; 05:467d $77
    jp   call_05_47b1_Audio_ResumeChannel              ;; 05:467e $c3 $b1 $47

call_05_4681_AudioCmd_SetNoisePeriod:
; $63 nn - set the noise channel's NR43 outright. Only channel 4 has any use for it, but
; nothing stops another channel from running it, in which case it changes the noise
; behind that channel's back
    pop  HL                                            ;; 05:4681 $e1
    inc  BC                                            ;; 05:4682 $03
    ld   A, [BC]                                       ;; 05:4683 $0a
    ld   [wDF64_Audio_NoisePeriod], A                  ;; 05:4684 $ea $64 $df
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:4687 $11 $fe $ff
    add  HL, DE                                        ;; 05:468a $19
    ld   A, $01                                        ;; 05:468b $3e $01
    ld   [HL+], A                                      ;; 05:468d $22
    inc  BC                                            ;; 05:468e $03
    call call_05_47ad_Audio_StoreSeqPtr                ;; 05:468f $cd $ad $47
    jp   call_05_47b1_Audio_ResumeChannel              ;; 05:4692 $c3 $b1 $47

call_05_4695_AudioCmd_CallPattern:
; $64 pp tt rr - play pattern pp, transposed by tt, rr times.
;
; This is the song form: a channel's top-level stream is almost entirely these, and the
; patterns they name are the reusable phrases. pp is an index into
; data_05_777d_PatternPointers - eight bits of index plus the carry out of the doubling,
; so 256 patterns are reachable through two 256-byte halves of the table.
;
; The repeat counter is only loaded when AUDIO_CH_LOOP_ACTIVE is clear, so re-entering a
; block that is already counting down does not restart the count. Audio_StartSong presets
; that flag on channels 3 and 4 to keep their opening pattern from being counted.
;
; gex2 has no equivalent - its tracks are flat, and a whole song channel is one long
; stream with a single backwards jump at the end
    pop  HL                                            ;; 05:4695 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:4696 $11 $fe $ff
    add  HL, DE                                        ;; 05:4699 $19
    ld   A, $01                                        ;; 05:469a $3e $01
    ld   [HL+], A                                      ;; 05:469c $22
    inc  BC                                            ;; 05:469d $03
    ld   A, [BC]                                       ;; 05:469e $0a
    sla  A                                             ;; 05:469f $cb $27
    jr   NC, .jr_05_46a9                               ;; 05:46a1 $30 $06
    ld   DE, data_05_777d_PatternPointers              ;; 05:46a3 $11 $6f $76
    inc  D                                             ;; 05:46a6 $14
    jr   .jr_05_46ac                                   ;; 05:46a7 $18 $03
.jr_05_46a9:
    ld   DE, data_05_777d_PatternPointers              ;; 05:46a9 $11 $6f $76
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
    ld   A, AUDIO_CH_TRANSPOSE - AUDIO_CH_NRX4_SHADOW  ;; 05:46b8 $3e $10
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
    jp   call_05_47b1_Audio_ResumeChannel              ;; 05:46dd $c3 $b1 $47

call_05_46e0_AudioCmd_EndPattern:
; $65 - end of the pattern AUDIO_CMD_CALL_PATTERN entered.
;
; While the repeat counter is above zero it decrements and jumps back to four bytes
; before the saved return address - the width of the call that got here - so the whole
; command runs again, transpose and all. When it hits zero the loop state is cleared and
; the channel carries on from the saved address
    inc  BC                                            ;; 05:46e0 $03
    pop  HL                                            ;; 05:46e1 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:46e2 $11 $fe $ff
    add  HL, DE                                        ;; 05:46e5 $19
    ld   A, $01                                        ;; 05:46e6 $3e $01
    ld   [HL+], A                                      ;; 05:46e8 $22
    ld   D, H                                          ;; 05:46e9 $54
    ld   E, L                                          ;; 05:46ea $5d
    ld   A, AUDIO_CH_LOOP_COUNTER - AUDIO_CH_SEQ_PTR_LO ;; 05:46eb $3e $11
    add  A, E                                          ;; 05:46ed $83
    ld   E, A                                          ;; 05:46ee $5f
    jr   NC, .jr_05_46f2                               ;; 05:46ef $30 $01
    inc  D                                             ;; 05:46f1 $14
.jr_05_46f2:
    ld   A, [DE]                                       ;; 05:46f2 $1a
    and  A, A                                          ;; 05:46f3 $a7
    jr   Z, .jr_05_470a                                ;; 05:46f4 $28 $14
    sub  A, $01                                        ;; 05:46f6 $d6 $01
    ld   [DE], A                                       ;; 05:46f8 $12
    inc  DE                                            ;; 05:46f9 $13
    inc  DE                                            ;; 05:46fa $13
    inc  DE                                            ;; 05:46fb $13
    ld   A, [DE]                                       ;; 05:46fc $1a
    sub  A, AUDIO_CALL_PATTERN_SIZE                    ;; 05:46fd $d6 $04
    ld   [HL+], A                                      ;; 05:46ff $22
    inc  DE                                            ;; 05:4700 $13
    ld   A, [DE]                                       ;; 05:4701 $1a
    jr   NC, .jr_05_4706                               ;; 05:4702 $30 $02
    sub  A, $01                                        ;; 05:4704 $d6 $01
.jr_05_4706:
    ld   [HL], A                                       ;; 05:4706 $77
    jp   call_05_47b1_Audio_ResumeChannel              ;; 05:4707 $c3 $b1 $47
.jr_05_470a:
    inc  DE                                            ;; 05:470a $13
    ld   A, $00                                        ;; 05:470b $3e $00
    ld   [DE], A                                       ;; 05:470d $12
    inc  DE                                            ;; 05:470e $13
    ld   [DE], A                                       ;; 05:470f $12
    inc  DE                                            ;; 05:4710 $13
    ld   A, [DE]                                       ;; 05:4711 $1a
    ld   [HL+], A                                      ;; 05:4712 $22
    inc  DE                                            ;; 05:4713 $13
    ld   A, [DE]                                       ;; 05:4714 $1a
    ld   [HL], A                                       ;; 05:4715 $77
    jp   call_05_47b1_Audio_ResumeChannel              ;; 05:4716 $c3 $b1 $47

call_05_4719_AudioCmd_SetMarker:
; $66 nn - store nn in wDF67_Audio_Marker, which nothing ever reads. Presumably a
; sequencer feature that never grew a runtime meaning; the patterns still carry it
    inc  BC                                            ;; 05:4719 $03
    ld   A, [BC]                                       ;; 05:471a $0a
    ld   [wDF67_Audio_Marker], A                       ;; 05:471b $ea $67 $df
    pop  HL                                            ;; 05:471e $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:471f $11 $fe $ff
    add  HL, DE                                        ;; 05:4722 $19
    ld   A, $01                                        ;; 05:4723 $3e $01
    ld   [HL+], A                                      ;; 05:4725 $22
    inc  BC                                            ;; 05:4726 $03
    call call_05_47ad_Audio_StoreSeqPtr                ;; 05:4727 $cd $ad $47
    jp   call_05_47b1_Audio_ResumeChannel              ;; 05:472a $c3 $b1 $47

call_05_472d_AudioCmd_SetPanning:
; $67 nn - set rNR51 for all four channels at once. The four per-channel forms below
; share this one's tail
    inc  BC                                            ;; 05:472d $03
    ld   A, [BC]                                       ;; 05:472e $0a
    ldh  [rNR51], A                                    ;; 05:472f $e0 $25
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:4731 $ea $79 $df

jr_05_4734_AudioCmd_StorePtrAndResume:
; Shared tail of the five panning commands: step past the argument, set the note timer
; to 1, save the pattern position and go round again
    inc  BC                                            ;; 05:4734 $03
    pop  HL                                            ;; 05:4735 $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:4736 $11 $fe $ff
    add  HL, DE                                        ;; 05:4739 $19
    ld   A, $01                                        ;; 05:473a $3e $01
    ld   [HL+], A                                      ;; 05:473c $22
    call call_05_47ad_Audio_StoreSeqPtr                ;; 05:473d $cd $ad $47
    jr   call_05_47b1_Audio_ResumeChannel              ;; 05:4740 $18 $6f

call_05_4742_AudioCmd_SetPanningCh1:
; $6A nn - replace only channel 1's two bits of rNR51, keeping the other three channels
; where they are
    inc  BC                                            ;; 05:4742 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:4743 $fa $79 $df
    and  A, ~AUDIO_NR51_CH1 & $ff                      ;; 05:4746 $e6 $ee
    ld   H, A                                          ;; 05:4748 $67
    ld   A, [BC]                                       ;; 05:4749 $0a
    or   A, H                                          ;; 05:474a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:474b $ea $79 $df
    ldh  [rNR51], A                                    ;; 05:474e $e0 $25
    jr   jr_05_4734_AudioCmd_StorePtrAndResume         ;; 05:4750 $18 $e2

call_05_4752_AudioCmd_SetPanningCh2:
; $6B nn
    inc  BC                                            ;; 05:4752 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:4753 $fa $79 $df
    and  A, ~AUDIO_NR51_CH2 & $ff                      ;; 05:4756 $e6 $dd
    ld   H, A                                          ;; 05:4758 $67
    ld   A, [BC]                                       ;; 05:4759 $0a
    or   A, H                                          ;; 05:475a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:475b $ea $79 $df
    ldh  [rNR51], A                                    ;; 05:475e $e0 $25
    jr   jr_05_4734_AudioCmd_StorePtrAndResume         ;; 05:4760 $18 $d2

call_05_4762_AudioCmd_SetPanningCh3:
; $6C nn
    inc  BC                                            ;; 05:4762 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:4763 $fa $79 $df
    and  A, ~AUDIO_NR51_CH3 & $ff                      ;; 05:4766 $e6 $bb
    ld   H, A                                          ;; 05:4768 $67
    ld   A, [BC]                                       ;; 05:4769 $0a
    or   A, H                                          ;; 05:476a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:476b $ea $79 $df
    ldh  [rNR51], A                                    ;; 05:476e $e0 $25
    jr   jr_05_4734_AudioCmd_StorePtrAndResume         ;; 05:4770 $18 $c2

call_05_4772_AudioCmd_SetPanningCh4:
; $6D nn
    inc  BC                                            ;; 05:4772 $03
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:4773 $fa $79 $df
    and  A, ~AUDIO_NR51_CH4 & $ff                      ;; 05:4776 $e6 $77
    ld   H, A                                          ;; 05:4778 $67
    ld   A, [BC]                                       ;; 05:4779 $0a
    or   A, H                                          ;; 05:477a $b4
    ld   [wDF79_Audio_PanningShadow], A                ;; 05:477b $ea $79 $df
    ldh  [rNR51], A                                    ;; 05:477e $e0 $25
    jr   jr_05_4734_AudioCmd_StorePtrAndResume         ;; 05:4780 $18 $b2

call_05_4782_AudioCmd_SetNoteLengthTable:
; $68 ll hh - point the note-length lookup somewhere else, so a section can change its
; rhythmic grid without touching the tempo. Overrides the table the song table named
    inc  BC                                            ;; 05:4782 $03
    ld   A, [BC]                                       ;; 05:4783 $0a
    ld   [wDF60_Audio_NoteLengthTablePtrLo], A         ;; 05:4784 $ea $60 $df
    inc  BC                                            ;; 05:4787 $03
    ld   A, [BC]                                       ;; 05:4788 $0a
    ld   [wDF61_Audio_NoteLengthTablePtrHi], A         ;; 05:4789 $ea $61 $df
    pop  HL                                            ;; 05:478c $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:478d $11 $fe $ff
    add  HL, DE                                        ;; 05:4790 $19
    ld   A, $01                                        ;; 05:4791 $3e $01
    ld   [HL+], A                                      ;; 05:4793 $22
    inc  BC                                            ;; 05:4794 $03
    call call_05_47ad_Audio_StoreSeqPtr                ;; 05:4795 $cd $ad $47
    jr   call_05_47b1_Audio_ResumeChannel              ;; 05:4798 $18 $17

call_05_479a_AudioCmd_SetTempo:
; $69 nn - set wDF78_Audio_TempoRate from inside a pattern. Global, not per channel, so
; whichever channel reaches it first changes the speed of all four
    inc  BC                                            ;; 05:479a $03
    ld   A, [BC]                                       ;; 05:479b $0a
    ld   [wDF78_Audio_TempoRate], A                    ;; 05:479c $ea $78 $df
    pop  HL                                            ;; 05:479f $e1
    ld   DE, AUDIO_CH_NOTE_TIMER - AUDIO_CH_SEQ_PTR_HI ;; 05:47a0 $11 $fe $ff
    add  HL, DE                                        ;; 05:47a3 $19
    ld   A, $01                                        ;; 05:47a4 $3e $01
    ld   [HL+], A                                      ;; 05:47a6 $22
    inc  BC                                            ;; 05:47a7 $03
    call call_05_47ad_Audio_StoreSeqPtr                ;; 05:47a8 $cd $ad $47
    jr   call_05_47b1_Audio_ResumeChannel              ;; 05:47ab $18 $04

call_05_47ad_Audio_StoreSeqPtr:
; Writes BC back into AUDIO_CH_SEQ_PTR, which HL is pointing at
    ld   [HL], C                                       ;; 05:47ad $71
    inc  HL                                            ;; 05:47ae $23
    ld   [HL], B                                       ;; 05:47af $70
    ret                                                ;; 05:47b0 $c9

call_05_47b1_Audio_ResumeChannel:
; How a command handler gets back to work. The `pop` throws away Audio_RunSequence's
; return address and the jump lands at the top of whichever channel block
; Audio_UpdateMusic is in the middle of, so the channel is processed again from the
; start and the next pattern byte is read immediately. That is why any number of
; commands can sit in front of a note without costing a tick
    pop  HL                                            ;; 05:47b1 $e1
    ld   DE, wDF62_Audio_ChannelResumePtrLo            ;; 05:47b2 $11 $62 $df
    ld   A, [DE]                                       ;; 05:47b5 $1a
    ld   L, A                                          ;; 05:47b6 $6f
    inc  DE                                            ;; 05:47b7 $13
    ld   A, [DE]                                       ;; 05:47b8 $1a
    ld   H, A                                          ;; 05:47b9 $67
    jp   HL                                            ;; 05:47ba $e9

data_05_47bb_NoteFrequenciesLo:
; The low byte of each note's 11-bit frequency, indexed by the
; AUDIO_NOTE_INDEX_MASK bits of a pattern byte plus the channel's transpose. Index
; $00 is C#2 and the table climbs a semitone at a time to AUDIO_NOTE_LAST; the top
; three bits of each value live in the table below. The last octave and a half is
; past anything the hardware resolves and is only reachable by transposing an
; already high note further.
;
; gex2 keeps the same thing as one table of little-endian words in
; data_21_43ce_NoteFrequencies
    db   $9d, $07, $6b, $ca, $23, $78, $c7, $12, $59, $9c, $db, $17        ;; 05:47bb  ; C#2-C3
    db   $4f, $84, $b6, $e5, $12, $3c, $64, $89, $ad, $ce, $ee, $0c        ;; 05:47c7  ; C#3-C4
    db   $28, $42, $5b, $73, $89, $9e, $b2, $c5, $d7, $e7, $f7, $06        ;; 05:47d3  ; C#4-C5
    db   $14, $21, $2e, $3a, $45, $4f, $59, $63, $6c, $74, $7c, $83        ;; 05:47df  ; C#5-C6
    db   $8a, $91, $97, $9d, $a3, $a8, $ad, $b1, $b6, $ba, $be, $c2        ;; 05:47eb  ; C#6-C7
    db   $c5, $c9, $cc, $cf, $d2, $d4, $d7, $d9, $db, $dd, $df, $e1        ;; 05:47f7  ; C#7-C8
    db   $e3, $e5, $e6, $e8, $e9, $ea, $ec, $ed, $ee, $ef, $f0, $f1        ;; 05:4803  ; C#8-C9
    db   $f2, $f3, $f3, $f4, $f5, $f5, $f7, $f7, $f8, $f8, $fa, $fa        ;; 05:480f  ; C#9-C10

data_05_481b_NoteFrequenciesHi:
; The high three bits of each note's frequency, ORed with the instrument's
; AUDIO_INS_NRX4_BASE on the way into the NRx4 shadow
    db   $00, $01, $01, $01, $02, $02, $02, $03, $03, $03, $03, $04        ;; 05:481b  ; C#2-C3
    db   $04, $04, $04, $04, $05, $05, $05, $05, $05, $05, $05, $06        ;; 05:4827  ; C#3-C4
    db   $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $07        ;; 05:4833  ; C#4-C5
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:483f  ; C#5-C6
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:484b  ; C#6-C7
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:4857  ; C#7-C8
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:4863  ; C#8-C9
    db   $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07        ;; 05:486f  ; C#9-C10
call_05_487b_Audio_StartSfxTrack:
; Start one sound-effect track, id A - an index into
; data_05_49ed_SfxTrackPointers, not an SFX_* id. Audio_StartSfx turns one of those into
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
    ld   HL, data_05_49ed_SfxTrackPointers             ;; 05:487b $21 $ed $49
    sla  A                                             ;; 05:487e $cb $27
    add  A, L                                          ;; 05:4880 $85
    ld   L, A                                          ;; 05:4881 $6f
    jr   NC, .jr_05_4885                               ;; 05:4882 $30 $01
    inc  H                                             ;; 05:4884 $24
.jr_05_4885:
    ld   A, [HL]                                       ;; 05:4885 $7e
    ld   C, A                                          ;; 05:4886 $4f
    inc  HL                                            ;; 05:4887 $23
    ld   A, [HL]                                       ;; 05:4888 $7e
    ld   B, A                                          ;; 05:4889 $47
    ld   A, AUDIO_NR52_ALL_ON                          ;; 05:488a $3e $8f
    ldh  [rNR52], A                                    ;; 05:488c $e0 $26
    ld   A, [BC]                                       ;; 05:488e $0a
    inc  BC                                            ;; 05:488f $03
    cp   A, $01                                        ;; 05:4890 $fe $01
    jr   Z, .jr_05_48bd                                ;; 05:4892 $28 $29
    cp   A, $02                                        ;; 05:4894 $fe $02
    jr   Z, .jr_05_48de                                ;; 05:4896 $28 $46
    cp   A, $03                                        ;; 05:4898 $fe $03
    jr   Z, .jr_05_48ff                                ;; 05:489a $28 $63
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:489c $fa $79 $df
    ld   D, A                                          ;; 05:489f $57
    ld   A, AUDIO_NR51_CH1                             ;; 05:48a0 $3e $11
    or   A, D                                          ;; 05:48a2 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 05:48a3 $ea $7a $df
    ld   A, [wDF00_Audio_Ch1_Flags]                    ;; 05:48a6 $fa $00 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 05:48a9 $e6 $fe
    ld   [wDF00_Audio_Ch1_Flags], A                    ;; 05:48ab $ea $00 $df
    ld   A, C                                          ;; 05:48ae $79
    ld   [wDF68_Audio_Ch1_SfxPtrLo], A                 ;; 05:48af $ea $68 $df
    ld   A, B                                          ;; 05:48b2 $78
    ld   [wDF69_Audio_Ch1_SfxPtrHi], A                 ;; 05:48b3 $ea $69 $df
    ld   A, $02                                        ;; 05:48b6 $3e $02
    ld   [wDF6A_Audio_Ch1_SfxTimer], A                 ;; 05:48b8 $ea $6a $df
    jr   call_05_491e_Audio_UpdateSfx                  ;; 05:48bb $18 $61
.jr_05_48bd:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:48bd $fa $79 $df
    ld   D, A                                          ;; 05:48c0 $57
    ld   A, AUDIO_NR51_CH2                             ;; 05:48c1 $3e $22
    or   A, D                                          ;; 05:48c3 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 05:48c4 $ea $7a $df
    ld   A, [wDF18_Audio_Ch2_Flags]                    ;; 05:48c7 $fa $18 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 05:48ca $e6 $fe
    ld   [wDF18_Audio_Ch2_Flags], A                    ;; 05:48cc $ea $18 $df
    ld   A, C                                          ;; 05:48cf $79
    ld   [wDF6B_Audio_Ch2_SfxPtrLo], A                 ;; 05:48d0 $ea $6b $df
    ld   A, B                                          ;; 05:48d3 $78
    ld   [wDF6C_Audio_Ch2_SfxPtrHi], A                 ;; 05:48d4 $ea $6c $df
    ld   A, $02                                        ;; 05:48d7 $3e $02
    ld   [wDF6D_Audio_Ch2_SfxTimer], A                 ;; 05:48d9 $ea $6d $df
    jr   call_05_491e_Audio_UpdateSfx                  ;; 05:48dc $18 $40
.jr_05_48de:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:48de $fa $79 $df
    ld   D, A                                          ;; 05:48e1 $57
    ld   A, AUDIO_NR51_CH3                             ;; 05:48e2 $3e $44
    or   A, D                                          ;; 05:48e4 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 05:48e5 $ea $7a $df
    ld   A, [wDF30_Audio_Ch3_Flags]                    ;; 05:48e8 $fa $30 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 05:48eb $e6 $fe
    ld   [wDF30_Audio_Ch3_Flags], A                    ;; 05:48ed $ea $30 $df
    ld   A, C                                          ;; 05:48f0 $79
    ld   [wDF6E_Audio_Ch3_SfxPtrLo], A                 ;; 05:48f1 $ea $6e $df
    ld   A, B                                          ;; 05:48f4 $78
    ld   [wDF6F_Audio_Ch3_SfxPtrHi], A                 ;; 05:48f5 $ea $6f $df
    ld   A, $02                                        ;; 05:48f8 $3e $02
    ld   [wDF70_Audio_Ch3_SfxTimer], A                 ;; 05:48fa $ea $70 $df
    jr   call_05_491e_Audio_UpdateSfx                  ;; 05:48fd $18 $1f
.jr_05_48ff:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:48ff $fa $79 $df
    ld   D, A                                          ;; 05:4902 $57
    ld   A, AUDIO_NR51_CH4                             ;; 05:4903 $3e $88
    or   A, D                                          ;; 05:4905 $b2
    ld   [wDF7A_Audio_SfxPanning], A                   ;; 05:4906 $ea $7a $df
    ld   A, [wDF48_Audio_Ch4_Flags]                    ;; 05:4909 $fa $48 $df
    and  A, ~AUDIO_CHF_ENABLED & $ff                   ;; 05:490c $e6 $fe
    ld   [wDF48_Audio_Ch4_Flags], A                    ;; 05:490e $ea $48 $df
    ld   A, C                                          ;; 05:4911 $79
    ld   [wDF71_Audio_Ch4_SfxPtrLo], A                 ;; 05:4912 $ea $71 $df
    ld   A, B                                          ;; 05:4915 $78
    ld   [wDF72_Audio_Ch4_SfxPtrHi], A                 ;; 05:4916 $ea $72 $df
    ld   A, $02                                        ;; 05:4919 $3e $02
    ld   [wDF73_Audio_Ch4_SfxTimer], A                 ;; 05:491b $ea $73 $df

call_05_491e_Audio_UpdateSfx:
; One tick of each of the four sound-effect slots. Sound effects are not on the music's
; tempo clock - they run once per frame regardless, so an effect sounds the same however
; fast or slow the song is.
;
; A slot is idle when both bytes of its pointer are zero, which is the state
; Audio_ResetDriver and the end of a track leave behind. The channel block's address goes
; into wDF74_Audio_SfxOwnerChannelPtr first so that Audio_StepSfxTrack can find the flags
; byte to restore when the effect finishes
    ld   HL, wDF00_Audio_Ch1_Flags                     ;; 05:491e $21 $00 $df
    ld   A, L                                          ;; 05:4921 $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 05:4922 $ea $74 $df
    ld   A, H                                          ;; 05:4925 $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 05:4926 $ea $75 $df
    ld   HL, wDF68_Audio_Ch1_SfxPtrLo                  ;; 05:4929 $21 $68 $df
    ld   C, [HL]                                       ;; 05:492c $4e
    inc  HL                                            ;; 05:492d $23
    ld   B, [HL]                                       ;; 05:492e $46
    ld   A, B                                          ;; 05:492f $78
    or   A, C                                          ;; 05:4930 $b1
    jr   Z, .jr_05_4939                                ;; 05:4931 $28 $06
    ld   DE, rNR11                                     ;; 05:4933 $11 $11 $ff
    call call_05_498b_Audio_StepSfxTrack               ;; 05:4936 $cd $8b $49
.jr_05_4939:
    ld   HL, wDF18_Audio_Ch2_Flags                     ;; 05:4939 $21 $18 $df
    ld   A, L                                          ;; 05:493c $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 05:493d $ea $74 $df
    ld   A, H                                          ;; 05:4940 $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 05:4941 $ea $75 $df
    ld   HL, wDF6B_Audio_Ch2_SfxPtrLo                  ;; 05:4944 $21 $6b $df
    ld   C, [HL]                                       ;; 05:4947 $4e
    inc  HL                                            ;; 05:4948 $23
    ld   B, [HL]                                       ;; 05:4949 $46
    ld   A, B                                          ;; 05:494a $78
    or   A, C                                          ;; 05:494b $b1
    jr   Z, .jr_05_4954                                ;; 05:494c $28 $06
    ld   DE, rNR21                                     ;; 05:494e $11 $16 $ff
    call call_05_498b_Audio_StepSfxTrack               ;; 05:4951 $cd $8b $49
.jr_05_4954:
    ld   HL, wDF30_Audio_Ch3_Flags                     ;; 05:4954 $21 $30 $df
    ld   A, L                                          ;; 05:4957 $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 05:4958 $ea $74 $df
    ld   A, H                                          ;; 05:495b $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 05:495c $ea $75 $df
    ld   HL, wDF6E_Audio_Ch3_SfxPtrLo                  ;; 05:495f $21 $6e $df
    ld   C, [HL]                                       ;; 05:4962 $4e
    inc  HL                                            ;; 05:4963 $23
    ld   B, [HL]                                       ;; 05:4964 $46
    ld   A, B                                          ;; 05:4965 $78
    or   A, C                                          ;; 05:4966 $b1
    jr   Z, .jr_05_496f                                ;; 05:4967 $28 $06
    ld   DE, rNR31                                     ;; 05:4969 $11 $1b $ff
    call call_05_498b_Audio_StepSfxTrack               ;; 05:496c $cd $8b $49
.jr_05_496f:
    ld   HL, wDF48_Audio_Ch4_Flags                     ;; 05:496f $21 $48 $df
    ld   A, L                                          ;; 05:4972 $7d
    ld   [wDF74_Audio_SfxOwnerChannelPtrLo], A         ;; 05:4973 $ea $74 $df
    ld   A, H                                          ;; 05:4976 $7c
    ld   [wDF75_Audio_SfxOwnerChannelPtrHi], A         ;; 05:4977 $ea $75 $df
    ld   HL, wDF71_Audio_Ch4_SfxPtrLo                  ;; 05:497a $21 $71 $df
    ld   C, [HL]                                       ;; 05:497d $4e
    inc  HL                                            ;; 05:497e $23
    ld   B, [HL]                                       ;; 05:497f $46
    ld   A, B                                          ;; 05:4980 $78
    or   A, C                                          ;; 05:4981 $b1
    jr   Z, .jr_05_498a                                ;; 05:4982 $28 $06
    ld   DE, rNR41                                     ;; 05:4984 $11 $20 $ff
    call call_05_498b_Audio_StepSfxTrack               ;; 05:4987 $cd $8b $49
.jr_05_498a:
    ret                                                ;; 05:498a $c9

call_05_498b_Audio_StepSfxTrack:
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
    ld   A, [wDF7A_Audio_SfxPanning]                   ;; 05:498b $fa $7a $df
    ldh  [rNR51], A                                    ;; 05:498e $e0 $25
    inc  HL                                            ;; 05:4990 $23
    dec  [HL]                                          ;; 05:4991 $35
    jr   Z, .jr_05_4995                                ;; 05:4992 $28 $01
    ret                                                ;; 05:4994 $c9
.jr_05_4995:
    ld   A, [BC]                                       ;; 05:4995 $0a
    cp   A, AUDIO_SFX_END                              ;; 05:4996 $fe $ff
    jr   Z, .jr_05_49b5                                ;; 05:4998 $28 $1b
    cp   A, AUDIO_SFX_LOOP                             ;; 05:499a $fe $fe
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
    ld   HL, wDF74_Audio_SfxOwnerChannelPtrLo          ;; 05:49bb $21 $74 $df
    ld   C, [HL]                                       ;; 05:49be $4e
    inc  HL                                            ;; 05:49bf $23
    ld   B, [HL]                                       ;; 05:49c0 $46
    ld   A, [BC]                                       ;; 05:49c1 $0a
    and  A, AUDIO_CHF_RUNNING                          ;; 05:49c2 $e6 $02
    jp   Z, .jp_05_49cb                                ;; 05:49c4 $ca $cb $49
    ld   A, [BC]                                       ;; 05:49c7 $0a
    or   A, AUDIO_CHF_ENABLED                          ;; 05:49c8 $f6 $01
    ld   [BC], A                                       ;; 05:49ca $02
.jp_05_49cb:
    ld   A, [wDF79_Audio_PanningShadow]                ;; 05:49cb $fa $79 $df
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

data_05_49dd_InitialWaveRam:
; The wave pattern Audio_ResetDriver loads once at boot: eight bytes of $AA -
; alternating maximum and minimum samples - then eight of silence, which is a square
; wave at half duty. Nothing ever replaces it, so every wave-channel note in the game
; is this shape. gex2 has AUDIO_CMD_LOAD_WAVE and swaps the pattern per track
    db   $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa        ;; 05:49dd
    db   $00, $00, $00, $00, $00, $00, $00, $00        ;; 05:49e5

data_05_49ed_SfxTrackPointers:
; One entry per sound-effect track. Audio_StartSfxTrack indexes this directly;
; data_05_4a59_SfxTrackIds is what maps an SFX_* id onto these
    dw   audio_05_541a_SfxTrack00                      ;; 05:49ed  ; track $00
    dw   audio_05_5421_SfxTrack01                      ;; 05:49ef  ; track $01
    dw   audio_05_5428_SfxTrack02                      ;; 05:49f1  ; track $02
    dw   audio_05_542f_SfxTrack03                      ;; 05:49f3  ; track $03
    dw   audio_05_4ad5_SfxTrack04                      ;; 05:49f5  ; track $04
    dw   audio_05_4ade_SfxTrack05                      ;; 05:49f7  ; track $05
    dw   audio_05_4afa_SfxTrack06                      ;; 05:49f9  ; track $06
    dw   audio_05_4aec_SfxTrack07                      ;; 05:49fb  ; track $07
    dw   audio_05_4b35_SfxTrack08                      ;; 05:49fd  ; track $08
    dw   audio_05_4b8e_SfxTrack09                      ;; 05:49ff  ; track $09
    dw   audio_05_4bce_SfxTrack0A                      ;; 05:4a01  ; track $0A
    dw   audio_05_4c31_SfxTrack0B                      ;; 05:4a03  ; track $0B
    dw   audio_05_4c94_SfxTrack0C                      ;; 05:4a05  ; track $0C
    dw   audio_05_4ccf_SfxTrack0D                      ;; 05:4a07  ; track $0D
    dw   audio_05_4cfb_SfxTrack0E                      ;; 05:4a09  ; track $0E
    dw   audio_05_4d09_SfxTrack0F                      ;; 05:4a0b  ; track $0F
    dw   audio_05_4d3f_SfxTrack10                      ;; 05:4a0d  ; track $10
    dw   audio_05_4d66_SfxTrack11                      ;; 05:4a0f  ; track $11
    dw   audio_05_4db3_SfxTrack12                      ;; 05:4a11  ; track $12
    dw   audio_05_4d97_SfxTrack13                      ;; 05:4a13  ; track $13
    dw   audio_05_4da0_SfxTrack14                      ;; 05:4a15  ; track $14
    dw   audio_05_4f15_SfxTrack15                      ;; 05:4a17  ; track $15
    dw   audio_05_4f50_SfxTrack16                      ;; 05:4a19  ; track $16
    dw   audio_05_4f8b_SfxTrack17                      ;; 05:4a1b  ; track $17
    dw   audio_05_4fc1_SfxTrack18                      ;; 05:4a1d  ; track $18
    dw   audio_05_4fca_SfxTrack19                      ;; 05:4a1f  ; track $19
    dw   audio_05_4fd3_SfxTrack1A                      ;; 05:4a21  ; track $1A
    dw   audio_05_5056_SfxTrack1B                      ;; 05:4a23  ; track $1B
    dw   audio_05_5040_SfxTrack1C                      ;; 05:4a25  ; track $1C
    dw   audio_05_5064_SfxTrack1D                      ;; 05:4a27  ; track $1D
    dw   audio_05_509f_SfxTrack1E                      ;; 05:4a29  ; track $1E
    dw   audio_05_50d5_SfxTrack1F                      ;; 05:4a2b  ; track $1F
    dw   audio_05_5119_SfxTrack20                      ;; 05:4a2d  ; track $20
    dw   audio_05_50de_SfxTrack21                      ;; 05:4a2f  ; track $21
    dw   audio_05_513a_SfxTrack22                      ;; 05:4a31  ; track $22
    dw   audio_05_5122_SfxTrack23                      ;; 05:4a33  ; track $23
    dw   audio_05_5148_SfxTrack24                      ;; 05:4a35  ; track $24
    dw   audio_05_51ba_SfxTrack25                      ;; 05:4a37  ; track $25
    dw   audio_05_51c3_SfxTrack26                      ;; 05:4a39  ; track $26
    dw   audio_05_51d1_SfxTrack27                      ;; 05:4a3b  ; track $27
    dw   audio_05_5202_SfxTrack28                      ;; 05:4a3d  ; track $28
    dw   audio_05_5210_SfxTrack29                      ;; 05:4a3f  ; track $29
    dw   audio_05_5232_SfxTrack2A                      ;; 05:4a41  ; track $2A
    dw   audio_05_5240_SfxTrack2B                      ;; 05:4a43  ; track $2B
    dw   audio_05_524e_SfxTrack2C                      ;; 05:4a45  ; track $2C
    dw   audio_05_5270_SfxTrack2D                      ;; 05:4a47  ; track $2D
    dw   audio_05_5279_SfxTrack2E                      ;; 05:4a49  ; track $2E
    dw   audio_05_5296_SfxTrack2F                      ;; 05:4a4b  ; track $2F
    dw   audio_05_52a4_SfxTrack30                      ;; 05:4a4d  ; track $30
    dw   audio_05_532f_SfxTrack31                      ;; 05:4a4f  ; track $31
    dw   audio_05_533d_SfxTrack32                      ;; 05:4a51  ; track $32
    dw   audio_05_534b_SfxTrack33                      ;; 05:4a53  ; track $33
    dw   audio_05_53d6_SfxTrack34                      ;; 05:4a55  ; track $34
    dw   audio_05_53df_SfxTrack35                      ;; 05:4a57  ; track $35

data_05_4a59_SfxTrackIds:
; AUDIO_SFX_TRACKS_PER_ID track ids per SFX_* id - the tracks Audio_StartSfx
; launches together - padded with AUDIO_SFX_TRACK_NONE. There are only 31 rows, so
; an SFX_* id above $1E reads whatever follows the table
    sfx_tracks $00, $01, $02, $03                      ;; 05:4a59  ; SFX_EMPTY
    sfx_tracks $04, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a5d  ; SFX_MENU_SCROLL
    sfx_tracks $05, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a61  ; SFX_ITEM_PICKUP
    sfx_tracks $07, $06, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a65  ; SFX_FLY_TV
    sfx_tracks $08, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a69  ; SFX_GEX_TAIL_SPIN
    sfx_tracks $09, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a6d  ; SFX_UNK05
    sfx_tracks $0A, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a71  ; SFX_GEX_JUMP
    sfx_tracks $0B, $0C, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a75  ; SFX_GEX_DOUBLE_JUMP
    sfx_tracks $0D, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a79  ; SFX_UNK08
    sfx_tracks $0E, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a7d  ; SFX_UNK09
    sfx_tracks $0F, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a81  ; SFX_PLAYER_DAMAGED
    sfx_tracks $10, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a85  ; SFX_UNK0B
    sfx_tracks $11, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a89  ; SFX_UNK0C
    sfx_tracks $12, $13, $14, AUDIO_SFX_TRACK_NONE     ;; 05:4a8d  ; SFX_UNK0D
    sfx_tracks $15, $16, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a91  ; SFX_GEX_SPAWN
    sfx_tracks $17, $18, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a95  ; SFX_ENEMY_DAMAGED
    sfx_tracks $19, $1A, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a99  ; SFX_ENEMY_KILLED
    sfx_tracks $1B, $1C, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4a9d  ; SFX_UNK11
    sfx_tracks $1D, $1E, $1F, AUDIO_SFX_TRACK_NONE     ;; 05:4aa1  ; SFX_UNK12
    sfx_tracks $20, $21, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4aa5  ; SFX_METEOR
    sfx_tracks $22, $23, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4aa9  ; SFX_CANNON
    sfx_tracks $24, $25, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4aad  ; SFX_BRAIN_OF_OZ
    sfx_tracks $26, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4ab1  ; SFX_UNK16
    sfx_tracks $27, $28, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4ab5  ; SFX_UNK17
    sfx_tracks $29, $2A, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4ab9  ; SFX_DOOR1
    sfx_tracks $2B, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4abd  ; SFX_SMALL_BANG
    sfx_tracks $2C, $2D, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4ac1  ; SFX_LOUD_BANG
    sfx_tracks $2E, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4ac5  ; SFX_DOOR2
    sfx_tracks $2F, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE, AUDIO_SFX_TRACK_NONE  ;; 05:4ac9  ; SFX_BOMB
    sfx_tracks $30, $31, $32, AUDIO_SFX_TRACK_NONE     ;; 05:4acd  ; SFX_UNK1D
    sfx_tracks $33, $34, $35, AUDIO_SFX_TRACK_NONE     ;; 05:4ad1  ; SFX_REMOTE

audio_05_4ad5_SfxTrack04:
; sfx track $04
    sfx_channel 1                                      ;; 05:4ad5  ; pulse B
    sfx_row $23, $80, $84, $87, $CF                    ;; 05:4ad6
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4adb

audio_05_4ade_SfxTrack05:
; sfx track $05
    sfx_channel 1                                      ;; 05:4ade  ; pulse B
    sfx_row $02, $80, $C1, $87, $8A                    ;; 05:4adf
    sfx_row $0A, $80, $C1, $87, $A8                    ;; 05:4ae4
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4ae9

audio_05_4aec_SfxTrack07:
; sfx track $07
    sfx_channel 3                                      ;; 05:4aec  ; noise
    sfx_row $02, $00, $F0, $80, $62                    ;; 05:4aed
    sfx_row $23, $00, $A3, $80, $47                    ;; 05:4af2
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4af7

audio_05_4afa_SfxTrack06:
; sfx track $06
    sfx_channel 1                                      ;; 05:4afa  ; pulse B
    sfx_row $02, $80, $F0, $80, $9D                    ;; 05:4afb
    sfx_row $02, $80, $70, $87, $D9                    ;; 05:4b00
    sfx_row $03, $80, $60, $87, $C5                    ;; 05:4b05
    sfx_row $02, $80, $50, $87, $E6                    ;; 05:4b0a
    sfx_row $01, $80, $40, $87, $D4                    ;; 05:4b0f
    sfx_row $05, $80, $40, $87, $E8                    ;; 05:4b14
    sfx_row $03, $80, $30, $87, $ED                    ;; 05:4b19
    sfx_row $01, $80, $30, $87, $DD                    ;; 05:4b1e
    sfx_row $06, $80, $20, $87, $F1                    ;; 05:4b23
    sfx_row $04, $80, $20, $87, $E3                    ;; 05:4b28
    sfx_row $04, $80, $10, $87, $D7                    ;; 05:4b2d
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4b32

audio_05_4b35_SfxTrack08:
; sfx track $08
    sfx_channel 3                                      ;; 05:4b35  ; noise
    sfx_row $01, $00, $20, $80, $47                    ;; 05:4b36
    sfx_row $01, $00, $30, $80, $46                    ;; 05:4b3b
    sfx_row $01, $00, $40, $80, $45                    ;; 05:4b40
    sfx_row $01, $00, $50, $80, $44                    ;; 05:4b45
    sfx_row $02, $00, $60, $80, $43                    ;; 05:4b4a
    sfx_row $02, $00, $70, $80, $42                    ;; 05:4b4f
    sfx_row $02, $00, $80, $80, $35                    ;; 05:4b54
    sfx_row $02, $00, $80, $80, $34                    ;; 05:4b59
    sfx_row $02, $00, $80, $80, $33                    ;; 05:4b5e
    sfx_row $02, $00, $00, $00, $00                    ;; 05:4b63
    sfx_row $02, $00, $F0, $80, $24                    ;; 05:4b68
    sfx_row $02, $00, $70, $80, $23                    ;; 05:4b6d
    sfx_row $02, $00, $50, $80, $24                    ;; 05:4b72
    sfx_row $02, $00, $40, $80, $24                    ;; 05:4b77
    sfx_row $02, $00, $30, $80, $24                    ;; 05:4b7c
    sfx_row $03, $00, $20, $80, $24                    ;; 05:4b81
    sfx_row $03, $00, $10, $80, $24                    ;; 05:4b86
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4b8b

audio_05_4b8e_SfxTrack09:
; sfx track $09
    sfx_channel 3                                      ;; 05:4b8e  ; noise
    sfx_row $02, $00, $50, $80, $06                    ;; 05:4b8f
    sfx_row $02, $00, $60, $80, $14                    ;; 05:4b94
    sfx_row $02, $00, $70, $80, $21                    ;; 05:4b99
    sfx_row $02, $00, $80, $80, $23                    ;; 05:4b9e
    sfx_row $02, $00, $90, $80, $24                    ;; 05:4ba3
    sfx_row $02, $00, $A0, $80, $32                    ;; 05:4ba8
    sfx_row $02, $00, $B0, $80, $33                    ;; 05:4bad
    sfx_row $02, $00, $C0, $80, $34                    ;; 05:4bb2
    sfx_row $01, $00, $00, $00, $00                    ;; 05:4bb7
    sfx_row $02, $00, $F0, $80, $44                    ;; 05:4bbc
    sfx_row $01, $00, $00, $00, $00                    ;; 05:4bc1
    sfx_row $02, $00, $D0, $80, $47                    ;; 05:4bc6
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4bcb

audio_05_4bce_SfxTrack0A:
; sfx track $0A
    sfx_channel 1                                      ;; 05:4bce  ; pulse B
    sfx_row $04, $80, $F0, $84, $50                    ;; 05:4bcf
    sfx_row $01, $80, $F0, $84, $64                    ;; 05:4bd4
    sfx_row $01, $80, $F0, $84, $78                    ;; 05:4bd9
    sfx_row $01, $80, $F0, $84, $8C                    ;; 05:4bde
    sfx_row $01, $80, $F0, $84, $A0                    ;; 05:4be3
    sfx_row $01, $80, $E0, $84, $B4                    ;; 05:4be8
    sfx_row $01, $80, $D0, $84, $C8                    ;; 05:4bed
    sfx_row $01, $80, $C0, $84, $D2                    ;; 05:4bf2
    sfx_row $01, $80, $80, $84, $DC                    ;; 05:4bf7
    sfx_row $01, $80, $80, $84, $E6                    ;; 05:4bfc
    sfx_row $01, $80, $80, $84, $F0                    ;; 05:4c01
    sfx_row $01, $80, $70, $84, $FA                    ;; 05:4c06
    sfx_row $01, $80, $50, $85, $05                    ;; 05:4c0b
    sfx_row $02, $80, $30, $85, $0F                    ;; 05:4c10
    sfx_row $02, $80, $20, $85, $19                    ;; 05:4c15
    sfx_row $03, $80, $20, $85, $23                    ;; 05:4c1a
    sfx_row $03, $80, $10, $85, $2D                    ;; 05:4c1f
    sfx_row $03, $80, $10, $85, $37                    ;; 05:4c24
    sfx_row $03, $80, $10, $85, $41                    ;; 05:4c29
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4c2e

audio_05_4c31_SfxTrack0B:
; sfx track $0B
    sfx_channel 1                                      ;; 05:4c31  ; pulse B
    sfx_row $04, $80, $F0, $82, $00                    ;; 05:4c32
    sfx_row $02, $80, $F0, $82, $1E                    ;; 05:4c37
    sfx_row $02, $80, $F0, $82, $3C                    ;; 05:4c3c
    sfx_row $02, $80, $F0, $82, $5A                    ;; 05:4c41
    sfx_row $02, $80, $F0, $82, $78                    ;; 05:4c46
    sfx_row $02, $80, $E0, $82, $96                    ;; 05:4c4b
    sfx_row $01, $80, $D0, $82, $B4                    ;; 05:4c50
    sfx_row $01, $80, $C0, $82, $D2                    ;; 05:4c55
    sfx_row $01, $80, $80, $82, $F0                    ;; 05:4c5a
    sfx_row $01, $80, $80, $83, $0F                    ;; 05:4c5f
    sfx_row $01, $80, $80, $82, $2D                    ;; 05:4c64
    sfx_row $01, $80, $70, $82, $4B                    ;; 05:4c69
    sfx_row $01, $80, $50, $82, $69                    ;; 05:4c6e
    sfx_row $02, $80, $30, $82, $87                    ;; 05:4c73
    sfx_row $02, $80, $20, $82, $A5                    ;; 05:4c78
    sfx_row $03, $80, $20, $82, $C3                    ;; 05:4c7d
    sfx_row $03, $80, $10, $82, $E1                    ;; 05:4c82
    sfx_row $03, $80, $10, $82, $FA                    ;; 05:4c87
    sfx_row $03, $80, $10, $82, $FF                    ;; 05:4c8c
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4c91

audio_05_4c94_SfxTrack0C:
; sfx track $0C
    sfx_channel 0                                      ;; 05:4c94  ; pulse A
    sfx_row $04, $80, $F0, $82, $01                    ;; 05:4c95
    sfx_row $02, $80, $F0, $82, $1F                    ;; 05:4c9a
    sfx_row $02, $80, $F0, $82, $3D                    ;; 05:4c9f
    sfx_row $02, $80, $F0, $82, $5B                    ;; 05:4ca4
    sfx_row $02, $80, $F0, $82, $79                    ;; 05:4ca9
    sfx_row $02, $80, $E0, $82, $97                    ;; 05:4cae
    sfx_row $01, $80, $D0, $82, $B5                    ;; 05:4cb3
    sfx_row $01, $80, $C0, $82, $D3                    ;; 05:4cb8
    sfx_row $01, $80, $80, $82, $F1                    ;; 05:4cbd
    sfx_row $01, $80, $80, $83, $10                    ;; 05:4cc2
    sfx_row $01, $80, $80, $82, $2E                    ;; 05:4cc7
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4ccc

audio_05_4ccf_SfxTrack0D:
; sfx track $0D
    sfx_channel 3                                      ;; 05:4ccf  ; noise
    sfx_row $04, $00, $F0, $80, $61                    ;; 05:4cd0
    sfx_row $01, $00, $70, $80, $35                    ;; 05:4cd5
    sfx_row $01, $00, $60, $80, $47                    ;; 05:4cda
    sfx_row $01, $00, $50, $80, $34                    ;; 05:4cdf
    sfx_row $01, $00, $40, $80, $46                    ;; 05:4ce4
    sfx_row $01, $00, $30, $80, $33                    ;; 05:4ce9
    sfx_row $01, $00, $20, $80, $45                    ;; 05:4cee
    sfx_row $02, $00, $10, $80, $32                    ;; 05:4cf3
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4cf8

audio_05_4cfb_SfxTrack0E:
; sfx track $0E
    sfx_channel 3                                      ;; 05:4cfb  ; noise
    sfx_row $14, $00, $1A, $80, $22                    ;; 05:4cfc
    sfx_row $3C, $00, $F4, $80, $22                    ;; 05:4d01
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4d06

audio_05_4d09_SfxTrack0F:
; sfx track $0F
    sfx_channel 1                                      ;; 05:4d09  ; pulse B
    sfx_row $02, $80, $F0, $85, $C8                    ;; 05:4d0a
    sfx_row $01, $80, $F0, $85, $B4                    ;; 05:4d0f
    sfx_row $01, $80, $F0, $85, $A0                    ;; 05:4d14
    sfx_row $01, $80, $F0, $85, $8C                    ;; 05:4d19
    sfx_row $01, $80, $E0, $85, $78                    ;; 05:4d1e
    sfx_row $01, $80, $E0, $85, $64                    ;; 05:4d23
    sfx_row $01, $80, $D0, $85, $50                    ;; 05:4d28
    sfx_row $01, $80, $D0, $85, $3C                    ;; 05:4d2d
    sfx_row $01, $80, $C0, $85, $28                    ;; 05:4d32
    sfx_row $01, $80, $C0, $85, $14                    ;; 05:4d37
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4d3c

audio_05_4d3f_SfxTrack10:
; sfx track $10
    sfx_channel 1                                      ;; 05:4d3f  ; pulse B
    sfx_row $02, $80, $F0, $87, $8C                    ;; 05:4d40
    sfx_row $01, $80, $E0, $87, $87                    ;; 05:4d45
    sfx_row $01, $80, $C0, $87, $82                    ;; 05:4d4a
    sfx_row $01, $80, $A0, $87, $7D                    ;; 05:4d4f
    sfx_row $01, $80, $80, $87, $78                    ;; 05:4d54
    sfx_row $01, $80, $50, $87, $73                    ;; 05:4d59
    sfx_row $01, $80, $30, $87, $6E                    ;; 05:4d5e
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4d63

audio_05_4d66_SfxTrack11:
; sfx track $11
    sfx_channel 3                                      ;; 05:4d66  ; noise
    sfx_row $01, $00, $C0, $80, $44                    ;; 05:4d67
    sfx_row $01, $00, $D0, $80, $43                    ;; 05:4d6c
    sfx_row $01, $00, $E0, $80, $44                    ;; 05:4d71
    sfx_row $01, $00, $F0, $80, $43                    ;; 05:4d76
    sfx_row $01, $00, $F0, $80, $44                    ;; 05:4d7b
    sfx_row $01, $00, $F0, $80, $43                    ;; 05:4d80
    sfx_row $02, $00, $00, $00, $00                    ;; 05:4d85
    sfx_row $01, $00, $F0, $80, $23                    ;; 05:4d8a
    sfx_row $06, $00, $51, $80, $23                    ;; 05:4d8f
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4d94

audio_05_4d97_SfxTrack13:
; sfx track $13
    sfx_channel 0                                      ;; 05:4d97  ; pulse A
    sfx_row $46, $80, $F4, $82, $23                    ;; 05:4d98
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4d9d

audio_05_4da0_SfxTrack14:
; sfx track $14
    sfx_channel 2                                      ;; 05:4da0  ; wave
    sfx_row $1E, $00, $20, $84, $E5                    ;; 05:4da1
    sfx_row $1E, $00, $40, $84, $E5                    ;; 05:4da6
    sfx_row $0A, $00, $60, $84, $E5                    ;; 05:4dab
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4db0

audio_05_4db3_SfxTrack12:
; sfx track $12
    sfx_channel 1                                      ;; 05:4db3  ; pulse B
    sfx_row $01, $80, $40, $87, $DC                    ;; 05:4db4
    sfx_row $01, $80, $50, $87, $DD                    ;; 05:4db9
    sfx_row $01, $80, $60, $87, $DE                    ;; 05:4dbe
    sfx_row $01, $80, $70, $87, $DF                    ;; 05:4dc3
    sfx_row $01, $80, $80, $87, $E0                    ;; 05:4dc8
    sfx_row $01, $80, $50, $87, $D9                    ;; 05:4dcd
    sfx_row $01, $80, $60, $87, $DA                    ;; 05:4dd2
    sfx_row $01, $80, $70, $87, $DB                    ;; 05:4dd7
    sfx_row $01, $80, $80, $87, $DC                    ;; 05:4ddc
    sfx_row $01, $80, $90, $87, $DD                    ;; 05:4de1
    sfx_row $01, $80, $30, $87, $D6                    ;; 05:4de6
    sfx_row $01, $80, $40, $87, $D7                    ;; 05:4deb
    sfx_row $01, $80, $50, $87, $D8                    ;; 05:4df0
    sfx_row $01, $80, $60, $87, $D9                    ;; 05:4df5
    sfx_row $01, $80, $70, $87, $DA                    ;; 05:4dfa
    sfx_row $01, $80, $40, $87, $DF                    ;; 05:4dff
    sfx_row $01, $80, $50, $87, $E0                    ;; 05:4e04
    sfx_row $01, $80, $60, $87, $E1                    ;; 05:4e09
    sfx_row $01, $80, $70, $87, $E2                    ;; 05:4e0e
    sfx_row $01, $80, $80, $87, $E3                    ;; 05:4e13
    sfx_row $01, $80, $20, $87, $D4                    ;; 05:4e18
    sfx_row $01, $80, $30, $87, $D5                    ;; 05:4e1d
    sfx_row $01, $80, $40, $87, $D6                    ;; 05:4e22
    sfx_row $01, $80, $50, $87, $D7                    ;; 05:4e27
    sfx_row $01, $80, $60, $87, $D8                    ;; 05:4e2c
    sfx_row $01, $80, $40, $87, $DA                    ;; 05:4e31
    sfx_row $01, $80, $50, $87, $DB                    ;; 05:4e36
    sfx_row $01, $80, $60, $87, $DC                    ;; 05:4e3b
    sfx_row $01, $80, $70, $87, $DD                    ;; 05:4e40
    sfx_row $01, $80, $80, $87, $DE                    ;; 05:4e45
    sfx_row $01, $80, $50, $87, $DF                    ;; 05:4e4a
    sfx_row $01, $80, $60, $87, $E0                    ;; 05:4e4f
    sfx_row $01, $80, $70, $87, $E1                    ;; 05:4e54
    sfx_row $01, $80, $80, $87, $E2                    ;; 05:4e59
    sfx_row $01, $80, $90, $87, $E3                    ;; 05:4e5e
    sfx_row $01, $80, $20, $87, $D3                    ;; 05:4e63
    sfx_row $01, $80, $30, $87, $D4                    ;; 05:4e68
    sfx_row $01, $80, $40, $87, $D5                    ;; 05:4e6d
    sfx_row $01, $80, $50, $87, $D6                    ;; 05:4e72
    sfx_row $01, $80, $60, $87, $D7                    ;; 05:4e77
    sfx_row $01, $80, $20, $87, $D9                    ;; 05:4e7c
    sfx_row $01, $80, $30, $87, $DA                    ;; 05:4e81
    sfx_row $01, $80, $40, $87, $DB                    ;; 05:4e86
    sfx_row $01, $80, $50, $87, $DC                    ;; 05:4e8b
    sfx_row $01, $80, $70, $87, $DD                    ;; 05:4e90
    sfx_row $01, $80, $20, $87, $D0                    ;; 05:4e95
    sfx_row $01, $80, $30, $87, $D1                    ;; 05:4e9a
    sfx_row $01, $80, $40, $87, $D2                    ;; 05:4e9f
    sfx_row $01, $80, $50, $87, $D3                    ;; 05:4ea4
    sfx_row $01, $80, $60, $87, $D4                    ;; 05:4ea9
    sfx_row $01, $80, $40, $87, $D4                    ;; 05:4eae
    sfx_row $01, $80, $50, $87, $D5                    ;; 05:4eb3
    sfx_row $01, $80, $60, $87, $D6                    ;; 05:4eb8
    sfx_row $01, $80, $50, $87, $D7                    ;; 05:4ebd
    sfx_row $01, $80, $40, $87, $D8                    ;; 05:4ec2
    sfx_row $01, $80, $20, $87, $CD                    ;; 05:4ec7
    sfx_row $01, $80, $30, $87, $CE                    ;; 05:4ecc
    sfx_row $01, $80, $40, $87, $CF                    ;; 05:4ed1
    sfx_row $01, $80, $50, $87, $D0                    ;; 05:4ed6
    sfx_row $01, $80, $60, $87, $D1                    ;; 05:4edb
    sfx_row $01, $80, $20, $87, $D9                    ;; 05:4ee0
    sfx_row $01, $80, $30, $87, $DA                    ;; 05:4ee5
    sfx_row $01, $80, $40, $87, $DB                    ;; 05:4eea
    sfx_row $01, $80, $50, $87, $DC                    ;; 05:4eef
    sfx_row $01, $80, $60, $87, $DD                    ;; 05:4ef4
    sfx_row $01, $80, $20, $87, $C8                    ;; 05:4ef9
    sfx_row $01, $80, $30, $87, $C9                    ;; 05:4efe
    sfx_row $01, $80, $40, $87, $CA                    ;; 05:4f03
    sfx_row $01, $80, $50, $87, $CB                    ;; 05:4f08
    sfx_row $01, $80, $40, $87, $CC                    ;; 05:4f0d
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4f12

audio_05_4f15_SfxTrack15:
; sfx track $15
    sfx_channel 0                                      ;; 05:4f15  ; pulse A
    sfx_row $05, $40, $10, $82, $37                    ;; 05:4f16
    sfx_row $05, $40, $20, $82, $3C                    ;; 05:4f1b
    sfx_row $05, $40, $40, $82, $41                    ;; 05:4f20
    sfx_row $05, $40, $80, $82, $46                    ;; 05:4f25
    sfx_row $05, $40, $A0, $82, $4B                    ;; 05:4f2a
    sfx_row $05, $40, $B0, $82, $50                    ;; 05:4f2f
    sfx_row $05, $40, $C0, $82, $55                    ;; 05:4f34
    sfx_row $05, $40, $D0, $82, $5A                    ;; 05:4f39
    sfx_row $05, $40, $E0, $82, $5F                    ;; 05:4f3e
    sfx_row $05, $40, $F0, $82, $64                    ;; 05:4f43
    sfx_row $5A, $40, $F7, $82, $69                    ;; 05:4f48
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4f4d

audio_05_4f50_SfxTrack16:
; sfx track $16
    sfx_channel 1                                      ;; 05:4f50  ; pulse B
    sfx_row $05, $40, $10, $82, $3A                    ;; 05:4f51
    sfx_row $05, $40, $20, $82, $3F                    ;; 05:4f56
    sfx_row $05, $40, $40, $82, $44                    ;; 05:4f5b
    sfx_row $05, $40, $80, $82, $49                    ;; 05:4f60
    sfx_row $05, $40, $A0, $82, $4E                    ;; 05:4f65
    sfx_row $05, $40, $B0, $82, $53                    ;; 05:4f6a
    sfx_row $05, $40, $C0, $82, $58                    ;; 05:4f6f
    sfx_row $05, $40, $D0, $82, $5D                    ;; 05:4f74
    sfx_row $05, $40, $E0, $82, $62                    ;; 05:4f79
    sfx_row $05, $40, $F0, $82, $67                    ;; 05:4f7e
    sfx_row $5A, $40, $F7, $82, $6C                    ;; 05:4f83
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4f88

audio_05_4f8b_SfxTrack17:
; sfx track $17
    sfx_channel 1                                      ;; 05:4f8b  ; pulse B
    sfx_row $02, $80, $F0, $85, $C8                    ;; 05:4f8c
    sfx_row $01, $80, $A0, $85, $BE                    ;; 05:4f91
    sfx_row $01, $80, $90, $85, $B4                    ;; 05:4f96
    sfx_row $01, $80, $80, $85, $AA                    ;; 05:4f9b
    sfx_row $01, $80, $70, $85, $A0                    ;; 05:4fa0
    sfx_row $01, $80, $60, $85, $96                    ;; 05:4fa5
    sfx_row $01, $80, $50, $85, $8C                    ;; 05:4faa
    sfx_row $01, $80, $40, $85, $82                    ;; 05:4faf
    sfx_row $01, $80, $30, $85, $78                    ;; 05:4fb4
    sfx_row $01, $80, $20, $85, $64                    ;; 05:4fb9
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4fbe

audio_05_4fc1_SfxTrack18:
; sfx track $18
    sfx_channel 3                                      ;; 05:4fc1  ; noise
    sfx_row $0C, $00, $72, $80, $47                    ;; 05:4fc2
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:4fc7

audio_05_4fca_SfxTrack19:
; sfx track $19
    sfx_channel 0                                      ;; 05:4fca  ; pulse A
    sfx_row $0A, $00, $00, $00, $00                    ;; 05:4fcb
    sfx_loop audio_05_4fd4_SfxTrackPart                ;; 05:4fd0

audio_05_4fd3_SfxTrack1A:
; sfx track $1A
    sfx_channel 1                                      ;; 05:4fd3  ; pulse B

audio_05_4fd4_SfxTrackPart:
    sfx_channel 5                                      ;; 05:4fd4  ; pulse B
    sfx_row $80, $F0, $85, $C8, $05                    ;; 05:4fd5
    sfx_row $80, $F0, $85, $96, $05                    ;; 05:4fda
    sfx_row $80, $E0, $85, $64, $05                    ;; 05:4fdf
    sfx_row $80, $E0, $85, $32, $05                    ;; 05:4fe4
    sfx_row $80, $D0, $84, $FA, $05                    ;; 05:4fe9
    sfx_row $80, $D0, $84, $C8, $05                    ;; 05:4fee
    sfx_row $80, $C0, $84, $96, $05                    ;; 05:4ff3
    sfx_row $80, $B0, $84, $64, $05                    ;; 05:4ff8
    sfx_row $80, $A0, $84, $32, $05                    ;; 05:4ffd
    sfx_row $80, $A0, $84, $00, $05                    ;; 05:5002
    sfx_row $80, $90, $83, $C8, $05                    ;; 05:5007
    sfx_row $80, $80, $83, $96, $05                    ;; 05:500c
    sfx_row $80, $70, $83, $64, $05                    ;; 05:5011
    sfx_row $80, $70, $83, $32, $05                    ;; 05:5016
    sfx_row $80, $60, $83, $00, $05                    ;; 05:501b
    sfx_row $80, $50, $82, $C8, $05                    ;; 05:5020
    sfx_row $80, $40, $82, $96, $05                    ;; 05:5025
    sfx_row $80, $30, $82, $64, $05                    ;; 05:502a
    sfx_row $80, $20, $82, $32, $05                    ;; 05:502f
    sfx_row $80, $20, $82, $00, $05                    ;; 05:5034
    sfx_row $80, $10, $81, $C8, $FE                    ;; 05:5039
    db   $1b, $54                                      ;; 05:503e

audio_05_5040_SfxTrack1C:
; sfx track $1C
    sfx_channel 3                                      ;; 05:5040  ; noise
    sfx_row $01, $00, $F0, $80, $23                    ;; 05:5041
    sfx_row $01, $00, $20, $80, $23                    ;; 05:5046
    sfx_row $03, $00, $F1, $80, $61                    ;; 05:504b
    sfx_row $28, $00, $65, $80, $61                    ;; 05:5050
    sfx_end                                            ;; 05:5055

audio_05_5056_SfxTrack1B:
; sfx track $1B
    sfx_channel 1                                      ;; 05:5056  ; pulse B
    sfx_row $02, $80, $F0, $80, $9D                    ;; 05:5057
    sfx_row $02, $80, $44, $80, $9D                    ;; 05:505c
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5061

audio_05_5064_SfxTrack1D:
; sfx track $1D
    sfx_channel 0                                      ;; 05:5064  ; pulse A
    sfx_row $01, $00, $00, $00, $00                    ;; 05:5065
    sfx_row $02, $40, $10, $80, $64                    ;; 05:506a
    sfx_row $02, $00, $10, $81, $C8                    ;; 05:506f
    sfx_row $02, $40, $20, $80, $64                    ;; 05:5074
    sfx_row $02, $00, $40, $81, $C8                    ;; 05:5079
    sfx_row $02, $40, $60, $80, $64                    ;; 05:507e
    sfx_row $02, $00, $80, $81, $C8                    ;; 05:5083
    sfx_row $02, $40, $A0, $80, $64                    ;; 05:5088
    sfx_row $02, $00, $C0, $81, $C8                    ;; 05:508d
    sfx_row $02, $40, $E0, $80, $64                    ;; 05:5092
    sfx_row $14, $00, $F5, $80, $64                    ;; 05:5097
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:509c

audio_05_509f_SfxTrack1E:
; sfx track $1E
    sfx_channel 1                                      ;; 05:509f  ; pulse B
    sfx_row $02, $40, $10, $80, $67                    ;; 05:50a0
    sfx_row $02, $00, $10, $81, $CB                    ;; 05:50a5
    sfx_row $02, $40, $20, $80, $67                    ;; 05:50aa
    sfx_row $02, $00, $40, $81, $CB                    ;; 05:50af
    sfx_row $02, $40, $60, $80, $67                    ;; 05:50b4
    sfx_row $02, $00, $80, $81, $CB                    ;; 05:50b9
    sfx_row $02, $40, $A0, $80, $67                    ;; 05:50be
    sfx_row $02, $00, $C0, $81, $CB                    ;; 05:50c3
    sfx_row $02, $40, $E0, $80, $67                    ;; 05:50c8
    sfx_row $14, $00, $F5, $80, $67                    ;; 05:50cd
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:50d2

audio_05_50d5_SfxTrack1F:
; sfx track $1F
    sfx_channel 3                                      ;; 05:50d5  ; noise
    sfx_row $08, $00, $F1, $80, $64                    ;; 05:50d6
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:50db

audio_05_50de_SfxTrack21:
; sfx track $21
    sfx_channel 3                                      ;; 05:50de  ; noise
    sfx_row $08, $00, $F0, $80, $62                    ;; 05:50df
    sfx_row $14, $00, $A5, $80, $61                    ;; 05:50e4
    sfx_row $07, $00, $10, $80, $5F                    ;; 05:50e9
    sfx_row $06, $00, $20, $80, $60                    ;; 05:50ee
    sfx_row $05, $00, $30, $80, $5F                    ;; 05:50f3
    sfx_row $05, $00, $40, $80, $46                    ;; 05:50f8
    sfx_row $05, $00, $50, $80, $45                    ;; 05:50fd
    sfx_row $04, $00, $60, $80, $44                    ;; 05:5102
    sfx_row $05, $00, $70, $80, $43                    ;; 05:5107
    sfx_row $06, $00, $80, $80, $42                    ;; 05:510c
    sfx_row $50, $00, $97, $80, $41                    ;; 05:5111
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5116

audio_05_5119_SfxTrack20:
; sfx track $20
    sfx_channel 1                                      ;; 05:5119  ; pulse B
    sfx_row $28, $80, $F5, $80, $9D                    ;; 05:511a
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:511f

audio_05_5122_SfxTrack23:
; sfx track $23
    sfx_channel 3                                      ;; 05:5122  ; noise
    sfx_row $01, $00, $F0, $80, $44                    ;; 05:5123
    sfx_row $01, $00, $20, $80, $44                    ;; 05:5128
    sfx_row $03, $00, $F1, $80, $47                    ;; 05:512d
    sfx_row $50, $00, $67, $80, $46                    ;; 05:5132
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5137

audio_05_513a_SfxTrack22:
; sfx track $22
    sfx_channel 1                                      ;; 05:513a  ; pulse B
    sfx_row $02, $80, $F0, $80, $9D                    ;; 05:513b
    sfx_row $02, $80, $45, $80, $9D                    ;; 05:5140
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5145

audio_05_5148_SfxTrack24:
; sfx track $24
    sfx_channel 1                                      ;; 05:5148  ; pulse B
    sfx_row $02, $80, $F0, $80, $64                    ;; 05:5149
    sfx_row $01, $80, $E0, $87, $D7                    ;; 05:514e
    sfx_row $02, $80, $D0, $87, $C8                    ;; 05:5153
    sfx_row $03, $80, $C0, $87, $B4                    ;; 05:5158
    sfx_row $02, $80, $B0, $87, $DF                    ;; 05:515d
    sfx_row $02, $80, $A0, $87, $D4                    ;; 05:5162
    sfx_row $01, $80, $90, $87, $E6                    ;; 05:5167
    sfx_row $01, $80, $80, $87, $CC                    ;; 05:516c
    sfx_row $02, $80, $70, $87, $BA                    ;; 05:5171
    sfx_row $02, $80, $60, $87, $DF                    ;; 05:5176
    sfx_row $01, $80, $50, $87, $C3                    ;; 05:517b
    sfx_row $02, $80, $40, $87, $E3                    ;; 05:5180
    sfx_row $02, $80, $30, $87, $C3                    ;; 05:5185
    sfx_row $01, $80, $20, $87, $E3                    ;; 05:518a
    sfx_row $03, $80, $20, $87, $D1                    ;; 05:518f
    sfx_row $02, $80, $20, $87, $DE                    ;; 05:5194
    sfx_row $03, $80, $20, $87, $D7                    ;; 05:5199
    sfx_row $02, $80, $10, $87, $D4                    ;; 05:519e
    sfx_row $03, $80, $10, $87, $E2                    ;; 05:51a3
    sfx_row $01, $80, $10, $87, $D5                    ;; 05:51a8
    sfx_row $03, $80, $10, $87, $E5                    ;; 05:51ad
    sfx_row $02, $80, $10, $87, $D3                    ;; 05:51b2
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:51b7

audio_05_51ba_SfxTrack25:
; sfx track $25
    sfx_channel 0                                      ;; 05:51ba  ; pulse A
    sfx_row $02, $80, $F0, $80, $64                    ;; 05:51bb
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:51c0

audio_05_51c3_SfxTrack26:
; sfx track $26
    sfx_channel 3                                      ;; 05:51c3  ; noise
    sfx_row $01, $3C, $F0, $C0, $23                    ;; 05:51c4
    sfx_row $01, $3C, $F0, $C0, $21                    ;; 05:51c9
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:51ce

audio_05_51d1_SfxTrack27:
; sfx track $27
    sfx_channel 3                                      ;; 05:51d1  ; noise
    sfx_row $01, $00, $F0, $80, $45                    ;; 05:51d2
    sfx_row $0A, $00, $92, $80, $62                    ;; 05:51d7
    sfx_row $03, $00, $00, $00, $00                    ;; 05:51dc
    sfx_row $01, $00, $F0, $80, $44                    ;; 05:51e1
    sfx_row $01, $00, $40, $80, $44                    ;; 05:51e6
    sfx_row $01, $00, $20, $80, $44                    ;; 05:51eb
    sfx_row $01, $00, $20, $80, $44                    ;; 05:51f0
    sfx_row $01, $00, $10, $80, $44                    ;; 05:51f5
    sfx_row $06, $00, $10, $80, $62                    ;; 05:51fa
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:51ff

audio_05_5202_SfxTrack28:
; sfx track $28
    sfx_channel 1                                      ;; 05:5202  ; pulse B
    sfx_row $01, $00, $00, $00, $00                    ;; 05:5203
    sfx_row $0A, $00, $0A, $87, $E3                    ;; 05:5208
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:520d

audio_05_5210_SfxTrack29:
; sfx track $29
    sfx_channel 3                                      ;; 05:5210  ; noise
    sfx_row $08, $00, $0B, $80, $61                    ;; 05:5211
    sfx_row $01, $00, $F0, $80, $44                    ;; 05:5216
    sfx_row $0A, $00, $52, $80, $61                    ;; 05:521b
    sfx_row $03, $00, $00, $00, $00                    ;; 05:5220
    sfx_row $14, $00, $0B, $80, $14                    ;; 05:5225
    sfx_row $28, $00, $67, $80, $14                    ;; 05:522a
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:522f

audio_05_5232_SfxTrack2A:
; sfx track $2A
    sfx_channel 1                                      ;; 05:5232  ; pulse B
    sfx_row $09, $00, $00, $00, $00                    ;; 05:5233
    sfx_row $0A, $00, $0A, $87, $E3                    ;; 05:5238
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:523d

audio_05_5240_SfxTrack2B:
; sfx track $2B
    sfx_channel 3                                      ;; 05:5240  ; noise
    sfx_row $03, $00, $F1, $80, $63                    ;; 05:5241
    sfx_row $1E, $00, $A3, $80, $62                    ;; 05:5246
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:524b

audio_05_524e_SfxTrack2C:
; sfx track $2C
    sfx_channel 3                                      ;; 05:524e  ; noise
    sfx_row $05, $00, $F2, $80, $62                    ;; 05:524f
    sfx_row $05, $00, $F2, $80, $64                    ;; 05:5254
    sfx_row $05, $00, $F2, $80, $63                    ;; 05:5259
    sfx_row $05, $00, $F2, $80, $62                    ;; 05:525e
    sfx_row $64, $00, $F7, $80, $62                    ;; 05:5263
    sfx_row $14, $00, $10, $80, $62                    ;; 05:5268
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:526d

audio_05_5270_SfxTrack2D:
; sfx track $2D
    sfx_channel 1                                      ;; 05:5270  ; pulse B
    sfx_row $03, $80, $F0, $81, $C8                    ;; 05:5271
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5276

audio_05_5279_SfxTrack2E:
; sfx track $2E
    sfx_channel 1                                      ;; 05:5279  ; pulse B
    sfx_row $01, $80, $50, $87, $C5                    ;; 05:527a
    sfx_row $01, $80, $A0, $87, $8A                    ;; 05:527f
    sfx_row $01, $80, $50, $87, $C5                    ;; 05:5284
    sfx_row $01, $80, $A0, $87, $8A                    ;; 05:5289
    sfx_row $32, $80, $A6, $87, $BE                    ;; 05:528e
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5293

audio_05_5296_SfxTrack2F:
; sfx track $2F
    sfx_channel 1                                      ;; 05:5296  ; pulse B
    sfx_row $02, $BC, $F0, $C7, $C5                    ;; 05:5297
    sfx_row $03, $BC, $F0, $C7, $8A                    ;; 05:529c
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:52a1

audio_05_52a4_SfxTrack30:
; sfx track $30
    sfx_channel 3                                      ;; 05:52a4  ; noise
    sfx_row $05, $00, $20, $80, $66                    ;; 05:52a5
    sfx_row $05, $00, $30, $80, $65                    ;; 05:52aa
    sfx_row $05, $00, $40, $80, $64                    ;; 05:52af
    sfx_row $05, $00, $50, $80, $63                    ;; 05:52b4
    sfx_row $05, $00, $60, $80, $62                    ;; 05:52b9
    sfx_row $05, $00, $70, $80, $61                    ;; 05:52be
    sfx_row $05, $00, $80, $80, $60                    ;; 05:52c3
    sfx_row $05, $00, $90, $80, $47                    ;; 05:52c8
    sfx_row $05, $00, $A0, $80, $46                    ;; 05:52cd
    sfx_row $05, $00, $B0, $80, $45                    ;; 05:52d2
    sfx_row $05, $00, $C0, $80, $44                    ;; 05:52d7
    sfx_row $05, $00, $D0, $80, $43                    ;; 05:52dc
    sfx_row $05, $00, $E0, $80, $42                    ;; 05:52e1
    sfx_row $05, $00, $F0, $80, $35                    ;; 05:52e6
    sfx_row $05, $00, $E0, $80, $34                    ;; 05:52eb
    sfx_row $05, $00, $D0, $80, $33                    ;; 05:52f0
    sfx_row $05, $00, $C0, $80, $32                    ;; 05:52f5
    sfx_row $05, $00, $B0, $80, $24                    ;; 05:52fa
    sfx_row $05, $00, $A0, $80, $23                    ;; 05:52ff
    sfx_row $05, $00, $90, $80, $22                    ;; 05:5304
    sfx_row $06, $00, $80, $80, $21                    ;; 05:5309
    sfx_row $07, $00, $70, $80, $20                    ;; 05:530e
    sfx_row $07, $00, $60, $80, $14                    ;; 05:5313
    sfx_row $07, $00, $40, $80, $07                    ;; 05:5318
    sfx_row $07, $00, $30, $80, $06                    ;; 05:531d
    sfx_row $07, $00, $20, $80, $05                    ;; 05:5322
    sfx_row $07, $00, $10, $80, $04                    ;; 05:5327
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:532c

audio_05_532f_SfxTrack31:
; sfx track $31
    sfx_channel 1                                      ;; 05:532f  ; pulse B
    sfx_row $14, $00, $0A, $80, $32                    ;; 05:5330
    sfx_row $5A, $00, $F7, $80, $32                    ;; 05:5335
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:533a

audio_05_533d_SfxTrack32:
; sfx track $32
    sfx_channel 0                                      ;; 05:533d  ; pulse A
    sfx_row $14, $00, $0A, $80, $37                    ;; 05:533e
    sfx_row $5A, $00, $F7, $80, $37                    ;; 05:5343
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5348

audio_05_534b_SfxTrack33:
; sfx track $33
    sfx_channel 0                                      ;; 05:534b  ; pulse A

audio_05_534c_SfxTrackPart:
    sfx_channel 8                                      ;; 05:534c  ; pulse A
    sfx_row $80, $C1, $87, $8A, $08                    ;; 05:534d
    sfx_row $80, $C1, $87, $A3, $08                    ;; 05:5352
    sfx_row $80, $C1, $87, $B1, $08                    ;; 05:5357
    sfx_row $80, $C1, $87, $BE, $08                    ;; 05:535c
    sfx_row $80, $C1, $87, $A8, $08                    ;; 05:5361
    sfx_row $80, $C1, $87, $97, $08                    ;; 05:5366
    sfx_row $80, $C1, $87, $6C, $08                    ;; 05:536b
    sfx_row $80, $C1, $87, $8A, $08                    ;; 05:5370
    sfx_row $80, $C1, $87, $9D, $08                    ;; 05:5375
    sfx_row $80, $C1, $87, $97, $08                    ;; 05:537a
    sfx_row $80, $C1, $87, $83, $08                    ;; 05:537f
    sfx_row $80, $C1, $87, $63, $08                    ;; 05:5384
    sfx_row $80, $C1, $87, $4F, $08                    ;; 05:5389
    sfx_row $80, $C1, $87, $74, $08                    ;; 05:538e
    sfx_row $80, $C1, $87, $8A, $08                    ;; 05:5393
    sfx_row $80, $C1, $87, $7C, $08                    ;; 05:5398
    sfx_row $80, $C1, $87, $63, $08                    ;; 05:539d
    sfx_row $80, $C1, $87, $3A, $08                    ;; 05:53a2
    sfx_row $80, $C1, $87, $2E, $08                    ;; 05:53a7
    sfx_row $80, $C1, $87, $4F, $08                    ;; 05:53ac
    sfx_row $80, $C1, $87, $74, $08                    ;; 05:53b1
    sfx_row $80, $C1, $87, $63, $08                    ;; 05:53b6
    sfx_row $80, $C1, $87, $45, $08                    ;; 05:53bb
    sfx_row $80, $C1, $87, $14, $18                    ;; 05:53c0
    sfx_row $80, $C5, $84, $4F, $18                    ;; 05:53c5
    sfx_row $80, $C5, $86, $28, $3C                    ;; 05:53ca
    sfx_row $80, $C7, $87, $14, $FE                    ;; 05:53cf
    db   $1b, $54                                      ;; 05:53d4

audio_05_53d6_SfxTrack34:
; sfx track $34
    sfx_channel 1                                      ;; 05:53d6  ; pulse B
    sfx_row $08, $00, $00, $00, $00                    ;; 05:53d7
    sfx_loop audio_05_534c_SfxTrackPart                ;; 05:53dc

audio_05_53df_SfxTrack35:
; sfx track $35
    sfx_channel 2                                      ;; 05:53df  ; wave
    sfx_row $18, $00, $20, $86, $28                    ;; 05:53e0
    sfx_row $18, $00, $20, $85, $EE                    ;; 05:53e5
    sfx_row $18, $00, $20, $85, $AD                    ;; 05:53ea
    sfx_row $18, $00, $20, $85, $89                    ;; 05:53ef
    sfx_row $18, $00, $20, $85, $3C                    ;; 05:53f4
    sfx_row $18, $00, $20, $84, $E5                    ;; 05:53f9
    sfx_row $18, $00, $20, $84, $B6                    ;; 05:53fe
    sfx_row $18, $00, $20, $84, $4F                    ;; 05:5403
    sfx_row $18, $00, $20, $80, $9D                    ;; 05:5408
    sfx_row $18, $00, $40, $84, $4F                    ;; 05:540d
    sfx_row $30, $00, $60, $86, $28                    ;; 05:5412
    sfx_loop audio_05_541b_SfxTrackPart                ;; 05:5417

audio_05_541a_SfxTrack00:
; sfx track $00
    sfx_channel 0                                      ;; 05:541a  ; pulse A

audio_05_541b_SfxTrackPart:
    sfx_channel 1                                      ;; 05:541b  ; pulse B
    sfx_row $00, $00, $00, $00, $FF                    ;; 05:541c

audio_05_5421_SfxTrack01:
; sfx track $01
    sfx_channel 1                                      ;; 05:5421  ; pulse B
    sfx_row $01, $00, $00, $00, $00                    ;; 05:5422
    sfx_end                                            ;; 05:5427

audio_05_5428_SfxTrack02:
; sfx track $02
    sfx_channel 2                                      ;; 05:5428  ; wave
    sfx_row $01, $00, $00, $00, $00                    ;; 05:5429
    sfx_end                                            ;; 05:542e

audio_05_542f_SfxTrack03:
; sfx track $03
    sfx_channel 3                                      ;; 05:542f  ; noise
    sfx_row $01, $00, $00, $00, $00                    ;; 05:5430
    sfx_end                                            ;; 05:5435

audio_05_5436_Song_Unk10_Ch1:
; SONG_UNK10 (song $10) channel 1
    audio_panning $FF                                  ;; 05:5436
    audio_tempo $FF                                    ;; 05:5438
    audio_note $24, $00, $0                            ;; 05:543a  ; C#5
    audio_marker $01                                   ;; 05:543c
    audio_end                                          ;; 05:543e

audio_05_543f_Song_Unk10_Ch2:
; SONG_UNK10 (song $10) channel 2
    audio_note $24, $00, $0                            ;; 05:543f  ; C#5
    audio_end                                          ;; 05:5441

audio_05_5442_Song_Unk10_Ch3:
; SONG_UNK10 (song $10) channel 3
    audio_note $24, $00, $0                            ;; 05:5442  ; C#5
    audio_end                                          ;; 05:5444

audio_05_5445_Song_Unk10_Ch4:
; SONG_UNK10 (song $10) channel 4
    audio_note $24, $00, $0                            ;; 05:5445  ; C#5
    audio_end                                          ;; 05:5447

audio_05_5448_Song_Boss_Ch1:
; SONG_BOSS (song $11) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:5448
    audio_tempo $CD                                    ;; 05:544a
    audio_call $0B, $E5, 2                             ;; 05:544c
    audio_call $0C, $E5, 1                             ;; 05:5450
    audio_call $0D, $E5, 2                             ;; 05:5454
    audio_call $0E, $E5, 1                             ;; 05:5458
    audio_call $00, $00, 2                             ;; 05:545c
    audio_call $0F, $E5, 2                             ;; 05:5460
    audio_call $10, $E5, 1                             ;; 05:5464
    audio_call $11, $E5, 2                             ;; 05:5468
    audio_call $12, $E5, 2                             ;; 05:546c
    audio_marker $01                                   ;; 05:5470
    audio_goto audio_05_5448_Song_Boss_Ch1             ;; 05:5472

audio_05_5475_Song_Boss_Ch2:
; SONG_BOSS (song $11) channel 2
; AUDIO_CMD_GOTO target
    audio_call $13, $E5, 2                             ;; 05:5475
    audio_call $14, $E5, 1                             ;; 05:5479
    audio_call $15, $CD, 2                             ;; 05:547d
    audio_call $16, $E5, 4                             ;; 05:5481
    audio_call $16, $E7, 7                             ;; 05:5485
    audio_call $17, $E5, 2                             ;; 05:5489
    audio_call $18, $E5, 6                             ;; 05:548d
    audio_call $19, $E5, 1                             ;; 05:5491
    audio_call $18, $E5, 6                             ;; 05:5495
    audio_call $19, $E5, 1                             ;; 05:5499
    audio_goto audio_05_5475_Song_Boss_Ch2             ;; 05:549d

audio_05_54a0_Song_Boss_Ch3:
; SONG_BOSS (song $11) channel 3
; AUDIO_CMD_GOTO target
    audio_call $04, $F1, 2                             ;; 05:54a0
    audio_call $05, $F1, 1                             ;; 05:54a4
    audio_call $06, $F1, 8                             ;; 05:54a8
    audio_call $07, $F1, 2                             ;; 05:54ac
    audio_call $07, $F3, 3                             ;; 05:54b0
    audio_call $08, $F3, 1                             ;; 05:54b4
    audio_call $09, $F1, 2                             ;; 05:54b8
    audio_call $0A, $F1, 8                             ;; 05:54bc
    audio_goto audio_05_54a0_Song_Boss_Ch3             ;; 05:54c0

audio_05_54c3_Song_Boss_Ch4:
; SONG_BOSS (song $11) channel 4
; AUDIO_CMD_GOTO target
    audio_call $01, $00, 4                             ;; 05:54c3
    audio_call $02, $00, 1                             ;; 05:54c7
    audio_call $03, $00, 24                            ;; 05:54cb
    audio_call $01, $00, 1                             ;; 05:54cf
    audio_goto audio_05_54c3_Song_Boss_Ch4             ;; 05:54d3

audio_05_54d6_Pattern00:
; pattern $00
    audio_note $24, $00, $A                            ;; 05:54d6  ; C#5
    audio_end_pattern                                  ;; 05:54d8

audio_05_54d9_Pattern13:
; pattern $13
    audio_note $32, $08, $8                            ;; 05:54d9  ; D#6
    audio_note $2E, $08, $6                            ;; 05:54db  ; B5
    audio_note $32, $08, $6                            ;; 05:54dd  ; D#6
    audio_note $01, $08, $4                            ;; 05:54df  ; D2
    audio_note $35, $08, $2                            ;; 05:54e1  ; F#6
    audio_note $31, $08, $2                            ;; 05:54e3  ; D6
    audio_note $35, $08, $4                            ;; 05:54e5  ; F#6
    audio_note $31, $08, $4                            ;; 05:54e7  ; D6
    audio_note $35, $08, $4                            ;; 05:54e9  ; F#6
    audio_note $31, $08, $4                            ;; 05:54eb  ; D6
    audio_note $35, $08, $4                            ;; 05:54ed  ; F#6
    audio_note $31, $08, $4                            ;; 05:54ef  ; D6
    audio_note $32, $08, $8                            ;; 05:54f1  ; D#6
    audio_note $2E, $08, $6                            ;; 05:54f3  ; B5
    audio_note $32, $08, $6                            ;; 05:54f5  ; D#6
    audio_note $24, $00, $4                            ;; 05:54f7  ; C#5
    audio_note $35, $08, $2                            ;; 05:54f9  ; F#6
    audio_note $38, $08, $2                            ;; 05:54fb  ; A6
    audio_note $35, $08, $4                            ;; 05:54fd  ; F#6
    audio_note $38, $08, $4                            ;; 05:54ff  ; A6
    audio_note $35, $08, $4                            ;; 05:5501  ; F#6
    audio_note $38, $08, $4                            ;; 05:5503  ; A6
    audio_note $35, $08, $4                            ;; 05:5505  ; F#6
    audio_note $38, $08, $4                            ;; 05:5507  ; A6
    audio_end_pattern                                  ;; 05:5509

audio_05_550a_Pattern14:
; pattern $14
    audio_note $24, $00, $A                            ;; 05:550a  ; C#5
    audio_note $24, $00, $A                            ;; 05:550c  ; C#5
    audio_note $24, $08, $4                            ;; 05:550e  ; C#5
    audio_note $25, $08, $4                            ;; 05:5510  ; D5
    audio_note $26, $08, $5                            ;; 05:5512  ; D#5
    audio_note $27, $08, $4                            ;; 05:5514  ; E5
    audio_note $28, $08, $2                            ;; 05:5516  ; F5
    audio_note $29, $08, $2                            ;; 05:5518  ; F#5
    audio_note $2A, $08, $2                            ;; 05:551a  ; G5
    audio_note $2B, $08, $2                            ;; 05:551c  ; G#5
    audio_note $2C, $08, $2                            ;; 05:551e  ; A5
    audio_note $2D, $08, $4                            ;; 05:5520  ; A#5
    audio_note $24, $08, $4                            ;; 05:5522  ; C#5
    audio_note $25, $08, $4                            ;; 05:5524  ; D5
    audio_note $26, $08, $4                            ;; 05:5526  ; D#5
    audio_note $27, $08, $4                            ;; 05:5528  ; E5
    audio_note $26, $08, $2                            ;; 05:552a  ; D#5
    audio_note $27, $08, $2                            ;; 05:552c  ; E5
    audio_note $26, $08, $4                            ;; 05:552e  ; D#5
    audio_note $26, $08, $4                            ;; 05:5530  ; D#5
    audio_note $26, $08, $4                            ;; 05:5532  ; D#5
    audio_end_pattern                                  ;; 05:5534

audio_05_5535_Pattern15:
; pattern $15
    audio_note $43, $0D, $2                            ;; 05:5535  ; G#7
    audio_note $42, $0D, $2                            ;; 05:5537  ; G7
    audio_note $43, $0D, $2                            ;; 05:5539  ; G#7
    audio_note $45, $0D, $2                            ;; 05:553b  ; A#7
    audio_note $46, $0D, $2                            ;; 05:553d  ; B7
    audio_note $45, $0D, $2                            ;; 05:553f  ; A#7
    audio_note $46, $0D, $2                            ;; 05:5541  ; B7
    audio_note $48, $0D, $2                            ;; 05:5543  ; C#8
    audio_note $49, $0D, $2                            ;; 05:5545  ; D8
    audio_note $48, $0D, $2                            ;; 05:5547  ; C#8
    audio_note $49, $0D, $2                            ;; 05:5549  ; D8
    audio_note $4B, $0D, $2                            ;; 05:554b  ; E8
    audio_note $4C, $0D, $2                            ;; 05:554d  ; F8
    audio_note $4B, $0D, $2                            ;; 05:554f  ; E8
    audio_note $4C, $0D, $2                            ;; 05:5551  ; F8
    audio_note $4E, $0D, $2                            ;; 05:5553  ; G8
    audio_note $4F, $0D, $2                            ;; 05:5555  ; G#8
    audio_note $4E, $0D, $2                            ;; 05:5557  ; G8
    audio_note $4F, $0D, $2                            ;; 05:5559  ; G#8
    audio_note $51, $0D, $2                            ;; 05:555b  ; A#8
    audio_note $52, $0D, $2                            ;; 05:555d  ; B8
    audio_note $51, $0D, $2                            ;; 05:555f  ; A#8
    audio_note $52, $0D, $2                            ;; 05:5561  ; B8
    audio_note $54, $0D, $2                            ;; 05:5563  ; C#9
    audio_note $55, $0D, $2                            ;; 05:5565  ; D9
    audio_note $54, $0D, $2                            ;; 05:5567  ; C#9
    audio_note $55, $0D, $2                            ;; 05:5569  ; D9
    audio_note $57, $0D, $2                            ;; 05:556b  ; E9
    audio_note $58, $0D, $2                            ;; 05:556d  ; F9
    audio_note $57, $0D, $2                            ;; 05:556f  ; E9
    audio_note $58, $0D, $2                            ;; 05:5571  ; F9
    audio_note $5A, $0D, $2                            ;; 05:5573  ; G9
    audio_note $5B, $0D, $2                            ;; 05:5575  ; G#9
    audio_note $5A, $0D, $2                            ;; 05:5577  ; G9
    audio_note $5B, $0D, $2                            ;; 05:5579  ; G#9
    audio_note $5A, $0D, $2                            ;; 05:557b  ; G9
    audio_note $58, $0D, $2                            ;; 05:557d  ; F9
    audio_note $57, $0D, $2                            ;; 05:557f  ; E9
    audio_note $58, $0D, $2                            ;; 05:5581  ; F9
    audio_note $57, $0D, $2                            ;; 05:5583  ; E9
    audio_note $55, $0D, $2                            ;; 05:5585  ; D9
    audio_note $54, $0D, $2                            ;; 05:5587  ; C#9
    audio_note $55, $0D, $2                            ;; 05:5589  ; D9
    audio_note $54, $0D, $2                            ;; 05:558b  ; C#9
    audio_note $52, $0D, $2                            ;; 05:558d  ; B8
    audio_note $54, $0D, $2                            ;; 05:558f  ; C#9
    audio_note $52, $0D, $2                            ;; 05:5591  ; B8
    audio_note $51, $0D, $2                            ;; 05:5593  ; A#8
    audio_note $4F, $0D, $2                            ;; 05:5595  ; G#8
    audio_note $4E, $0D, $2                            ;; 05:5597  ; G8
    audio_note $4F, $0D, $2                            ;; 05:5599  ; G#8
    audio_note $4E, $0D, $2                            ;; 05:559b  ; G8
    audio_note $4C, $0D, $2                            ;; 05:559d  ; F8
    audio_note $4B, $0D, $2                            ;; 05:559f  ; E8
    audio_note $4C, $0D, $2                            ;; 05:55a1  ; F8
    audio_note $4B, $0D, $2                            ;; 05:55a3  ; E8
    audio_note $49, $0D, $2                            ;; 05:55a5  ; D8
    audio_note $48, $0D, $2                            ;; 05:55a7  ; C#8
    audio_note $49, $0D, $2                            ;; 05:55a9  ; D8
    audio_note $48, $0D, $2                            ;; 05:55ab  ; C#8
    audio_note $46, $0D, $2                            ;; 05:55ad  ; B7
    audio_note $48, $0D, $2                            ;; 05:55af  ; C#8
    audio_note $46, $0D, $2                            ;; 05:55b1  ; B7
    audio_note $45, $0D, $2                            ;; 05:55b3  ; A#7
    audio_end_pattern                                  ;; 05:55b5

audio_05_55b6_Pattern16:
; pattern $16
    audio_note $30, $0D, $2                            ;; 05:55b6  ; C#6
    audio_note $31, $0D, $2                            ;; 05:55b8  ; D6
    audio_note $32, $0D, $2                            ;; 05:55ba  ; D#6
    audio_note $33, $0D, $2                            ;; 05:55bc  ; E6
    audio_note $34, $0D, $2                            ;; 05:55be  ; F6
    audio_note $35, $0D, $2                            ;; 05:55c0  ; F#6
    audio_note $36, $0D, $2                            ;; 05:55c2  ; G6
    audio_note $37, $0D, $2                            ;; 05:55c4  ; G#6
    audio_note $38, $0D, $2                            ;; 05:55c6  ; A6
    audio_note $39, $0D, $2                            ;; 05:55c8  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:55ca  ; B6
    audio_note $3B, $0D, $2                            ;; 05:55cc  ; C7
    audio_note $3C, $0D, $2                            ;; 05:55ce  ; C#7
    audio_note $3B, $0D, $2                            ;; 05:55d0  ; C7
    audio_note $3C, $0D, $2                            ;; 05:55d2  ; C#7
    audio_note $3B, $0D, $2                            ;; 05:55d4  ; C7
    audio_note $3C, $0D, $2                            ;; 05:55d6  ; C#7
    audio_note $3B, $0D, $2                            ;; 05:55d8  ; C7
    audio_note $3A, $0D, $2                            ;; 05:55da  ; B6
    audio_note $39, $0D, $2                            ;; 05:55dc  ; A#6
    audio_note $38, $0D, $2                            ;; 05:55de  ; A6
    audio_note $37, $0D, $2                            ;; 05:55e0  ; G#6
    audio_note $36, $0D, $2                            ;; 05:55e2  ; G6
    audio_note $35, $0D, $2                            ;; 05:55e4  ; F#6
    audio_note $34, $0D, $2                            ;; 05:55e6  ; F6
    audio_note $33, $0D, $2                            ;; 05:55e8  ; E6
    audio_note $32, $0D, $2                            ;; 05:55ea  ; D#6
    audio_note $33, $0D, $2                            ;; 05:55ec  ; E6
    audio_note $34, $0D, $2                            ;; 05:55ee  ; F6
    audio_note $33, $0D, $2                            ;; 05:55f0  ; E6
    audio_note $32, $0D, $2                            ;; 05:55f2  ; D#6
    audio_note $31, $0D, $2                            ;; 05:55f4  ; D6
    audio_end_pattern                                  ;; 05:55f6

audio_05_55f7_Pattern17:
; pattern $17
    audio_note $32, $0D, $2                            ;; 05:55f7  ; D#6
    audio_note $32, $0D, $4                            ;; 05:55f9  ; D#6
    audio_note $32, $0D, $2                            ;; 05:55fb  ; D#6
    audio_note $32, $0D, $4                            ;; 05:55fd  ; D#6
    audio_note $32, $0D, $2                            ;; 05:55ff  ; D#6
    audio_note $32, $0D, $4                            ;; 05:5601  ; D#6
    audio_note $32, $0D, $2                            ;; 05:5603  ; D#6
    audio_note $32, $0D, $4                            ;; 05:5605  ; D#6
    audio_note $33, $0D, $4                            ;; 05:5607  ; E6
    audio_note $33, $0D, $4                            ;; 05:5609  ; E6
    audio_note $32, $0D, $2                            ;; 05:560b  ; D#6
    audio_note $32, $0D, $4                            ;; 05:560d  ; D#6
    audio_note $32, $0D, $2                            ;; 05:560f  ; D#6
    audio_note $32, $0D, $4                            ;; 05:5611  ; D#6
    audio_note $32, $0D, $2                            ;; 05:5613  ; D#6
    audio_note $32, $0D, $4                            ;; 05:5615  ; D#6
    audio_note $32, $0D, $2                            ;; 05:5617  ; D#6
    audio_note $32, $0D, $4                            ;; 05:5619  ; D#6
    audio_note $34, $0D, $4                            ;; 05:561b  ; F6
    audio_note $34, $0D, $4                            ;; 05:561d  ; F6
    audio_end_pattern                                  ;; 05:561f

audio_05_5620_Pattern18:
; pattern $18
    audio_note $37, $0D, $2                            ;; 05:5620  ; G#6
    audio_note $36, $0D, $2                            ;; 05:5622  ; G6
    audio_note $37, $0D, $2                            ;; 05:5624  ; G#6
    audio_note $38, $0D, $2                            ;; 05:5626  ; A6
    audio_note $39, $0D, $2                            ;; 05:5628  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:562a  ; B6
    audio_note $39, $0D, $2                            ;; 05:562c  ; A#6
    audio_note $38, $0D, $2                            ;; 05:562e  ; A6
    audio_note $37, $0D, $2                            ;; 05:5630  ; G#6
    audio_note $36, $0D, $2                            ;; 05:5632  ; G6
    audio_note $37, $0D, $2                            ;; 05:5634  ; G#6
    audio_note $38, $0D, $2                            ;; 05:5636  ; A6
    audio_note $39, $0D, $2                            ;; 05:5638  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:563a  ; B6
    audio_note $39, $0D, $2                            ;; 05:563c  ; A#6
    audio_note $38, $0D, $2                            ;; 05:563e  ; A6
    audio_end_pattern                                  ;; 05:5640

audio_05_5641_Pattern19:
; pattern $19
    audio_note $3A, $09, $8                            ;; 05:5641  ; B6
    audio_note $3C, $09, $6                            ;; 05:5643  ; C#7
    audio_note $3E, $09, $6                            ;; 05:5645  ; D#7
    audio_note $39, $09, $A                            ;; 05:5647  ; A#6
    audio_end_pattern                                  ;; 05:5649

audio_05_564a_Pattern0B:
; pattern $0B
    audio_note $37, $09, $8                            ;; 05:564a  ; G#6
    audio_note $32, $09, $6                            ;; 05:564c  ; D#6
    audio_note $37, $09, $6                            ;; 05:564e  ; G#6
    audio_note $35, $09, $A                            ;; 05:5650  ; F#6
    audio_note $37, $09, $8                            ;; 05:5652  ; G#6
    audio_note $32, $09, $6                            ;; 05:5654  ; D#6
    audio_note $37, $09, $6                            ;; 05:5656  ; G#6
    audio_note $38, $09, $A                            ;; 05:5658  ; A6
    audio_end_pattern                                  ;; 05:565a

audio_05_565b_Pattern0C:
; pattern $0C
    audio_note $4F, $08, $6                            ;; 05:565b  ; G#8
    audio_note $37, $08, $2                            ;; 05:565d  ; G#6
    audio_note $37, $08, $2                            ;; 05:565f  ; G#6
    audio_note $37, $08, $2                            ;; 05:5661  ; G#6
    audio_note $37, $08, $2                            ;; 05:5663  ; G#6
    audio_note $49, $08, $8                            ;; 05:5665  ; D8
    audio_note $4F, $08, $6                            ;; 05:5667  ; G#8
    audio_note $37, $08, $2                            ;; 05:5669  ; G#6
    audio_note $37, $08, $2                            ;; 05:566b  ; G#6
    audio_note $37, $08, $2                            ;; 05:566d  ; G#6
    audio_note $37, $08, $2                            ;; 05:566f  ; G#6
    audio_note $4D, $08, $8                            ;; 05:5671  ; F#8
    audio_note $4F, $08, $6                            ;; 05:5673  ; G#8
    audio_note $37, $08, $2                            ;; 05:5675  ; G#6
    audio_note $37, $08, $2                            ;; 05:5677  ; G#6
    audio_note $37, $08, $2                            ;; 05:5679  ; G#6
    audio_note $37, $08, $2                            ;; 05:567b  ; G#6
    audio_note $49, $08, $8                            ;; 05:567d  ; D8
    audio_note $4F, $08, $6                            ;; 05:567f  ; G#8
    audio_note $37, $08, $2                            ;; 05:5681  ; G#6
    audio_note $37, $08, $2                            ;; 05:5683  ; G#6
    audio_note $37, $08, $2                            ;; 05:5685  ; G#6
    audio_note $37, $08, $2                            ;; 05:5687  ; G#6
    audio_note $49, $08, $8                            ;; 05:5689  ; D8
    audio_end_pattern                                  ;; 05:568b

audio_05_568c_Pattern0D:
; pattern $0D
    audio_note $43, $0D, $2                            ;; 05:568c  ; G#7
    audio_note $42, $0D, $2                            ;; 05:568e  ; G7
    audio_note $43, $0D, $2                            ;; 05:5690  ; G#7
    audio_note $45, $0D, $2                            ;; 05:5692  ; A#7
    audio_note $46, $0D, $2                            ;; 05:5694  ; B7
    audio_note $45, $0D, $2                            ;; 05:5696  ; A#7
    audio_note $46, $0D, $2                            ;; 05:5698  ; B7
    audio_note $48, $0D, $2                            ;; 05:569a  ; C#8
    audio_note $49, $0D, $2                            ;; 05:569c  ; D8
    audio_note $48, $0D, $2                            ;; 05:569e  ; C#8
    audio_note $49, $0D, $2                            ;; 05:56a0  ; D8
    audio_note $4B, $0D, $2                            ;; 05:56a2  ; E8
    audio_note $4C, $0D, $2                            ;; 05:56a4  ; F8
    audio_note $4B, $0D, $2                            ;; 05:56a6  ; E8
    audio_note $4C, $0D, $2                            ;; 05:56a8  ; F8
    audio_note $4B, $0D, $2                            ;; 05:56aa  ; E8
    audio_note $49, $0D, $2                            ;; 05:56ac  ; D8
    audio_note $48, $0D, $2                            ;; 05:56ae  ; C#8
    audio_note $49, $0D, $2                            ;; 05:56b0  ; D8
    audio_note $48, $0D, $2                            ;; 05:56b2  ; C#8
    audio_note $46, $0D, $2                            ;; 05:56b4  ; B7
    audio_note $45, $0D, $2                            ;; 05:56b6  ; A#7
    audio_note $46, $0D, $2                            ;; 05:56b8  ; B7
    audio_note $45, $0D, $2                            ;; 05:56ba  ; A#7
    audio_note $43, $0D, $2                            ;; 05:56bc  ; G#7
    audio_note $42, $0D, $2                            ;; 05:56be  ; G7
    audio_note $43, $0D, $2                            ;; 05:56c0  ; G#7
    audio_note $42, $0D, $2                            ;; 05:56c2  ; G7
    audio_note $40, $0D, $2                            ;; 05:56c4  ; F7
    audio_note $3F, $0D, $2                            ;; 05:56c6  ; E7
    audio_note $3D, $0D, $2                            ;; 05:56c8  ; D7
    audio_note $3C, $0D, $2                            ;; 05:56ca  ; C#7
    audio_note $3A, $0D, $2                            ;; 05:56cc  ; B6
    audio_note $39, $0D, $2                            ;; 05:56ce  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:56d0  ; B6
    audio_note $3C, $0D, $2                            ;; 05:56d2  ; C#7
    audio_note $3D, $0D, $2                            ;; 05:56d4  ; D7
    audio_note $3C, $0D, $2                            ;; 05:56d6  ; C#7
    audio_note $3D, $0D, $2                            ;; 05:56d8  ; D7
    audio_note $3F, $0D, $2                            ;; 05:56da  ; E7
    audio_note $40, $0D, $2                            ;; 05:56dc  ; F7
    audio_note $3F, $0D, $2                            ;; 05:56de  ; E7
    audio_note $40, $0D, $2                            ;; 05:56e0  ; F7
    audio_note $42, $0D, $2                            ;; 05:56e2  ; G7
    audio_note $43, $0D, $2                            ;; 05:56e4  ; G#7
    audio_note $42, $0D, $2                            ;; 05:56e6  ; G7
    audio_note $43, $0D, $2                            ;; 05:56e8  ; G#7
    audio_note $45, $0D, $2                            ;; 05:56ea  ; A#7
    audio_note $46, $0D, $2                            ;; 05:56ec  ; B7
    audio_note $45, $0D, $2                            ;; 05:56ee  ; A#7
    audio_note $46, $0D, $2                            ;; 05:56f0  ; B7
    audio_note $45, $0D, $2                            ;; 05:56f2  ; A#7
    audio_note $43, $0D, $2                            ;; 05:56f4  ; G#7
    audio_note $42, $0D, $2                            ;; 05:56f6  ; G7
    audio_note $43, $0D, $2                            ;; 05:56f8  ; G#7
    audio_note $42, $0D, $2                            ;; 05:56fa  ; G7
    audio_note $40, $0D, $2                            ;; 05:56fc  ; F7
    audio_note $3F, $0D, $2                            ;; 05:56fe  ; E7
    audio_note $40, $0D, $2                            ;; 05:5700  ; F7
    audio_note $3F, $0D, $2                            ;; 05:5702  ; E7
    audio_note $3D, $0D, $2                            ;; 05:5704  ; D7
    audio_note $3C, $0D, $2                            ;; 05:5706  ; C#7
    audio_note $3D, $0D, $2                            ;; 05:5708  ; D7
    audio_note $3C, $0D, $2                            ;; 05:570a  ; C#7
    audio_end_pattern                                  ;; 05:570c

audio_05_570d_Pattern0E:
; pattern $0E
    audio_note $3C, $09, $8                            ;; 05:570d  ; C#7
    audio_note $3F, $09, $6                            ;; 05:570f  ; E7
    audio_note $42, $09, $6                            ;; 05:5711  ; G7
    audio_note $43, $09, $8                            ;; 05:5713  ; G#7
    audio_note $3F, $09, $6                            ;; 05:5715  ; E7
    audio_note $3B, $09, $6                            ;; 05:5717  ; C7
    audio_note $3C, $09, $8                            ;; 05:5719  ; C#7
    audio_note $3F, $09, $6                            ;; 05:571b  ; E7
    audio_note $42, $09, $6                            ;; 05:571d  ; G7
    audio_note $44, $09, $8                            ;; 05:571f  ; A7
    audio_note $43, $09, $8                            ;; 05:5721  ; G#7
    audio_note $48, $09, $8                            ;; 05:5723  ; C#8
    audio_note $24, $00, $4                            ;; 05:5725  ; C#5
    audio_note $43, $09, $4                            ;; 05:5727  ; G#7
    audio_note $44, $09, $4                            ;; 05:5729  ; A7
    audio_note $41, $09, $4                            ;; 05:572b  ; F#7
    audio_note $43, $09, $8                            ;; 05:572d  ; G#7
    audio_note $24, $00, $4                            ;; 05:572f  ; C#5
    audio_note $41, $09, $4                            ;; 05:5731  ; F#7
    audio_note $3F, $09, $4                            ;; 05:5733  ; E7
    audio_note $3E, $09, $4                            ;; 05:5735  ; D#7
    audio_note $3F, $09, $6                            ;; 05:5737  ; E7
    audio_note $3C, $09, $8                            ;; 05:5739  ; C#7
    audio_note $3E, $09, $4                            ;; 05:573b  ; D#7
    audio_note $3F, $09, $4                            ;; 05:573d  ; E7
    audio_note $3B, $09, $A                            ;; 05:573f  ; C7
    audio_end_pattern                                  ;; 05:5741

audio_05_5742_Pattern0F:
; pattern $0F
    audio_note $3E, $09, $2                            ;; 05:5742  ; D#7
    audio_note $45, $09, $4                            ;; 05:5744  ; A#7
    audio_note $3E, $09, $2                            ;; 05:5746  ; D#7
    audio_note $45, $09, $4                            ;; 05:5748  ; A#7
    audio_note $3E, $09, $2                            ;; 05:574a  ; D#7
    audio_note $45, $09, $4                            ;; 05:574c  ; A#7
    audio_note $3E, $09, $2                            ;; 05:574e  ; D#7
    audio_note $41, $09, $4                            ;; 05:5750  ; F#7
    audio_note $45, $09, $4                            ;; 05:5752  ; A#7
    audio_note $3E, $09, $4                            ;; 05:5754  ; D#7
    audio_note $46, $09, $2                            ;; 05:5756  ; B7
    audio_note $45, $09, $2                            ;; 05:5758  ; A#7
    audio_note $44, $09, $2                            ;; 05:575a  ; A7
    audio_note $43, $09, $2                            ;; 05:575c  ; G#7
    audio_note $42, $09, $2                            ;; 05:575e  ; G7
    audio_note $41, $09, $2                            ;; 05:5760  ; F#7
    audio_note $40, $09, $2                            ;; 05:5762  ; F7
    audio_note $3F, $09, $2                            ;; 05:5764  ; E7
    audio_note $3E, $09, $2                            ;; 05:5766  ; D#7
    audio_note $3F, $09, $2                            ;; 05:5768  ; E7
    audio_note $40, $09, $2                            ;; 05:576a  ; F7
    audio_note $3F, $09, $2                            ;; 05:576c  ; E7
    audio_note $3E, $09, $4                            ;; 05:576e  ; D#7
    audio_note $3A, $09, $4                            ;; 05:5770  ; B6
    audio_end_pattern                                  ;; 05:5772

audio_05_5773_Pattern10:
; pattern $10
    audio_note $32, $09, $2                            ;; 05:5773  ; D#6
    audio_note $35, $09, $2                            ;; 05:5775  ; F#6
    audio_note $39, $09, $2                            ;; 05:5777  ; A#6
    audio_note $3E, $09, $2                            ;; 05:5779  ; D#7
    audio_note $41, $09, $4                            ;; 05:577b  ; F#7
    audio_note $45, $09, $2                            ;; 05:577d  ; A#7
    audio_note $4A, $09, $4                            ;; 05:577f  ; D#8
    audio_note $45, $09, $2                            ;; 05:5781  ; A#7
    audio_note $41, $09, $2                            ;; 05:5783  ; F#7
    audio_note $3E, $09, $2                            ;; 05:5785  ; D#7
    audio_note $41, $09, $4                            ;; 05:5787  ; F#7
    audio_note $45, $09, $4                            ;; 05:5789  ; A#7
    audio_note $46, $09, $5                            ;; 05:578b  ; B7
    audio_note $45, $09, $2                            ;; 05:578d  ; A#7
    audio_note $44, $09, $2                            ;; 05:578f  ; A7
    audio_note $43, $09, $2                            ;; 05:5791  ; G#7
    audio_note $42, $09, $2                            ;; 05:5793  ; G7
    audio_note $41, $09, $5                            ;; 05:5795  ; F#7
    audio_note $3F, $09, $4                            ;; 05:5797  ; E7
    audio_note $3A, $09, $4                            ;; 05:5799  ; B6
    audio_note $37, $09, $4                            ;; 05:579b  ; G#6
    audio_note $32, $09, $2                            ;; 05:579d  ; D#6
    audio_note $35, $09, $2                            ;; 05:579f  ; F#6
    audio_note $39, $09, $2                            ;; 05:57a1  ; A#6
    audio_note $3E, $09, $2                            ;; 05:57a3  ; D#7
    audio_note $41, $09, $2                            ;; 05:57a5  ; F#7
    audio_note $45, $09, $2                            ;; 05:57a7  ; A#7
    audio_note $4A, $09, $4                            ;; 05:57a9  ; D#8
    audio_note $4D, $09, $4                            ;; 05:57ab  ; F#8
    audio_note $4C, $09, $2                            ;; 05:57ad  ; F8
    audio_note $4A, $09, $4                            ;; 05:57af  ; D#8
    audio_note $4C, $09, $2                            ;; 05:57b1  ; F8
    audio_note $4D, $09, $4                            ;; 05:57b3  ; F#8
    audio_note $4B, $09, $4                            ;; 05:57b5  ; E8
    audio_note $46, $09, $4                            ;; 05:57b7  ; B7
    audio_note $43, $09, $2                            ;; 05:57b9  ; G#7
    audio_note $46, $09, $2                            ;; 05:57bb  ; B7
    audio_note $4B, $09, $4                            ;; 05:57bd  ; E8
    audio_note $4E, $09, $6                            ;; 05:57bf  ; G8
    audio_note $4B, $09, $4                            ;; 05:57c1  ; E8
    audio_note $46, $09, $4                            ;; 05:57c3  ; B7
    audio_note $4A, $09, $4                            ;; 05:57c5  ; D#8
    audio_note $45, $09, $2                            ;; 05:57c7  ; A#7
    audio_note $46, $09, $4                            ;; 05:57c9  ; B7
    audio_note $43, $09, $2                            ;; 05:57cb  ; G#7
    audio_note $45, $09, $2                            ;; 05:57cd  ; A#7
    audio_note $41, $09, $2                            ;; 05:57cf  ; F#7
    audio_note $43, $09, $4                            ;; 05:57d1  ; G#7
    audio_note $40, $09, $2                            ;; 05:57d3  ; F7
    audio_note $41, $09, $5                            ;; 05:57d5  ; F#7
    audio_note $3E, $09, $4                            ;; 05:57d7  ; D#7
    audio_note $3F, $09, $4                            ;; 05:57d9  ; E7
    audio_note $3A, $09, $4                            ;; 05:57db  ; B6
    audio_note $37, $09, $6                            ;; 05:57dd  ; G#6
    audio_note $24, $00, $2                            ;; 05:57df  ; C#5
    audio_note $3A, $09, $2                            ;; 05:57e1  ; B6
    audio_note $3F, $09, $2                            ;; 05:57e3  ; E7
    audio_note $43, $09, $2                            ;; 05:57e5  ; G#7
    audio_note $46, $09, $4                            ;; 05:57e7  ; B7
    audio_note $4B, $09, $4                            ;; 05:57e9  ; E8
    audio_note $4A, $09, $6                            ;; 05:57eb  ; D#8
    audio_note $45, $09, $5                            ;; 05:57ed  ; A#7
    audio_note $41, $09, $5                            ;; 05:57ef  ; F#7
    audio_note $3E, $09, $4                            ;; 05:57f1  ; D#7
    audio_note $41, $09, $4                            ;; 05:57f3  ; F#7
    audio_note $45, $09, $4                            ;; 05:57f5  ; A#7
    audio_note $3F, $09, $6                            ;; 05:57f7  ; E7
    audio_note $4B, $09, $4                            ;; 05:57f9  ; E8
    audio_note $3F, $09, $2                            ;; 05:57fb  ; E7
    audio_note $4B, $09, $4                            ;; 05:57fd  ; E8
    audio_note $3F, $09, $2                            ;; 05:57ff  ; E7
    audio_note $4B, $09, $4                            ;; 05:5801  ; E8
    audio_note $4B, $09, $4                            ;; 05:5803  ; E8
    audio_note $3F, $09, $4                            ;; 05:5805  ; E7
    audio_end_pattern                                  ;; 05:5807

audio_05_5808_Pattern11:
; pattern $11
    audio_note $39, $08, $2                            ;; 05:5808  ; A#6
    audio_note $39, $08, $4                            ;; 05:580a  ; A#6
    audio_note $39, $08, $2                            ;; 05:580c  ; A#6
    audio_note $39, $08, $4                            ;; 05:580e  ; A#6
    audio_note $39, $08, $2                            ;; 05:5810  ; A#6
    audio_note $39, $08, $4                            ;; 05:5812  ; A#6
    audio_note $39, $08, $2                            ;; 05:5814  ; A#6
    audio_note $39, $08, $4                            ;; 05:5816  ; A#6
    audio_note $3A, $08, $4                            ;; 05:5818  ; B6
    audio_note $3A, $08, $4                            ;; 05:581a  ; B6
    audio_note $39, $08, $2                            ;; 05:581c  ; A#6
    audio_note $39, $08, $4                            ;; 05:581e  ; A#6
    audio_note $39, $08, $2                            ;; 05:5820  ; A#6
    audio_note $39, $08, $4                            ;; 05:5822  ; A#6
    audio_note $39, $08, $2                            ;; 05:5824  ; A#6
    audio_note $39, $08, $4                            ;; 05:5826  ; A#6
    audio_note $39, $08, $2                            ;; 05:5828  ; A#6
    audio_note $39, $08, $4                            ;; 05:582a  ; A#6
    audio_note $38, $08, $4                            ;; 05:582c  ; A6
    audio_note $38, $08, $4                            ;; 05:582e  ; A6
    audio_end_pattern                                  ;; 05:5830

audio_05_5831_Pattern12:
; pattern $12
    audio_note $37, $09, $7                            ;; 05:5831  ; G#6
    audio_note $3A, $09, $7                            ;; 05:5833  ; B6
    audio_note $3E, $09, $6                            ;; 05:5835  ; D#7
    audio_note $3D, $09, $8                            ;; 05:5837  ; D7
    audio_note $3A, $09, $6                            ;; 05:5839  ; B6
    audio_note $36, $09, $6                            ;; 05:583b  ; G6
    audio_note $37, $09, $8                            ;; 05:583d  ; G#6
    audio_note $3A, $09, $6                            ;; 05:583f  ; B6
    audio_note $3E, $09, $6                            ;; 05:5841  ; D#7
    audio_note $3F, $09, $A                            ;; 05:5843  ; E7
    audio_note $43, $09, $8                            ;; 05:5845  ; G#7
    audio_note $3E, $09, $8                            ;; 05:5847  ; D#7
    audio_note $3F, $09, $6                            ;; 05:5849  ; E7
    audio_note $3E, $09, $6                            ;; 05:584b  ; D#7
    audio_note $3C, $09, $6                            ;; 05:584d  ; C#7
    audio_note $3A, $09, $6                            ;; 05:584f  ; B6
    audio_note $37, $09, $8                            ;; 05:5851  ; G#6
    audio_note $39, $09, $6                            ;; 05:5853  ; A#6
    audio_note $3A, $09, $6                            ;; 05:5855  ; B6
    audio_note $36, $09, $A                            ;; 05:5857  ; G6
    audio_end_pattern                                  ;; 05:5859

audio_05_585a_Pattern04:
; pattern $04
    audio_note $1F, $11, $4                            ;; 05:585a  ; G#4
    audio_note $1F, $11, $6                            ;; 05:585c  ; G#4
    audio_note $1F, $11, $4                            ;; 05:585e  ; G#4
    audio_note $26, $11, $6                            ;; 05:5860  ; D#5
    audio_note $1F, $11, $6                            ;; 05:5862  ; G#4
    audio_note $25, $11, $4                            ;; 05:5864  ; D5
    audio_note $25, $11, $6                            ;; 05:5866  ; D5
    audio_note $25, $11, $4                            ;; 05:5868  ; D5
    audio_note $25, $11, $6                            ;; 05:586a  ; D5
    audio_note $25, $11, $6                            ;; 05:586c  ; D5
    audio_note $1F, $11, $4                            ;; 05:586e  ; G#4
    audio_note $1F, $11, $6                            ;; 05:5870  ; G#4
    audio_note $1F, $11, $4                            ;; 05:5872  ; G#4
    audio_note $26, $11, $6                            ;; 05:5874  ; D#5
    audio_note $1F, $11, $6                            ;; 05:5876  ; G#4
    audio_note $25, $11, $4                            ;; 05:5878  ; D5
    audio_note $25, $11, $6                            ;; 05:587a  ; D5
    audio_note $25, $11, $4                            ;; 05:587c  ; D5
    audio_note $25, $11, $6                            ;; 05:587e  ; D5
    audio_note $20, $11, $6                            ;; 05:5880  ; A4
    audio_end_pattern                                  ;; 05:5882

audio_05_5883_Pattern05:
; pattern $05
    audio_note $1F, $12, $A                            ;; 05:5883  ; G#4
    audio_note $1F, $12, $A                            ;; 05:5885  ; G#4
    audio_note $24, $00, $A                            ;; 05:5887  ; C#5
    audio_note $1F, $12, $A                            ;; 05:5889  ; G#4
    audio_end_pattern                                  ;; 05:588b

audio_05_588c_Pattern06:
; pattern $06
    audio_note $18, $11, $4                            ;; 05:588c  ; C#4
    audio_note $19, $11, $4                            ;; 05:588e  ; D4
    audio_note $1A, $11, $5                            ;; 05:5890  ; D#4
    audio_note $1B, $11, $4                            ;; 05:5892  ; E4
    audio_note $1C, $11, $2                            ;; 05:5894  ; F4
    audio_note $1D, $11, $2                            ;; 05:5896  ; F#4
    audio_note $1E, $11, $2                            ;; 05:5898  ; G4
    audio_note $1F, $11, $2                            ;; 05:589a  ; G#4
    audio_note $20, $11, $2                            ;; 05:589c  ; A4
    audio_note $21, $11, $4                            ;; 05:589e  ; A#4
    audio_end_pattern                                  ;; 05:58a0

audio_05_58a1_Pattern07:
; pattern $07
    audio_note $18, $11, $4                            ;; 05:58a1  ; C#4
    audio_note $18, $11, $4                            ;; 05:58a3  ; C#4
    audio_note $24, $11, $5                            ;; 05:58a5  ; C#5
    audio_note $18, $11, $4                            ;; 05:58a7  ; C#4
    audio_note $18, $11, $4                            ;; 05:58a9  ; C#4
    audio_note $18, $11, $2                            ;; 05:58ab  ; C#4
    audio_note $24, $11, $4                            ;; 05:58ad  ; C#5
    audio_note $18, $11, $4                            ;; 05:58af  ; C#4
    audio_note $19, $11, $4                            ;; 05:58b1  ; D4
    audio_note $19, $11, $4                            ;; 05:58b3  ; D4
    audio_note $25, $11, $5                            ;; 05:58b5  ; D5
    audio_note $19, $11, $4                            ;; 05:58b7  ; D4
    audio_note $19, $11, $4                            ;; 05:58b9  ; D4
    audio_note $19, $11, $2                            ;; 05:58bb  ; D4
    audio_note $25, $11, $2                            ;; 05:58bd  ; D5
    audio_note $19, $11, $2                            ;; 05:58bf  ; D4
    audio_note $25, $11, $4                            ;; 05:58c1  ; D5

audio_05_58c3_Pattern08:
; pattern $08
    audio_note $18, $11, $4                            ;; 05:58c3  ; C#4
    audio_note $18, $11, $4                            ;; 05:58c5  ; C#4
    audio_note $24, $11, $5                            ;; 05:58c7  ; C#5
    audio_note $18, $11, $4                            ;; 05:58c9  ; C#4
    audio_note $18, $11, $4                            ;; 05:58cb  ; C#4
    audio_note $18, $11, $2                            ;; 05:58cd  ; C#4
    audio_note $24, $11, $2                            ;; 05:58cf  ; C#5
    audio_note $18, $11, $2                            ;; 05:58d1  ; C#4
    audio_note $24, $11, $4                            ;; 05:58d3  ; C#5
    audio_note $19, $11, $4                            ;; 05:58d5  ; D4
    audio_note $19, $11, $4                            ;; 05:58d7  ; D4
    audio_note $25, $11, $4                            ;; 05:58d9  ; D5
    audio_note $19, $11, $2                            ;; 05:58db  ; D4
    audio_note $25, $11, $4                            ;; 05:58dd  ; D5
    audio_note $19, $11, $2                            ;; 05:58df  ; D4
    audio_note $25, $11, $2                            ;; 05:58e1  ; D5
    audio_note $19, $11, $2                            ;; 05:58e3  ; D4
    audio_note $27, $11, $4                            ;; 05:58e5  ; E5
    audio_note $25, $11, $4                            ;; 05:58e7  ; D5
    audio_end_pattern                                  ;; 05:58e9

audio_05_58ea_Pattern09:
; pattern $09
    audio_note $26, $11, $2                            ;; 05:58ea  ; D#5
    audio_note $26, $11, $4                            ;; 05:58ec  ; D#5
    audio_note $26, $11, $2                            ;; 05:58ee  ; D#5
    audio_note $26, $11, $4                            ;; 05:58f0  ; D#5
    audio_note $26, $11, $2                            ;; 05:58f2  ; D#5
    audio_note $26, $11, $4                            ;; 05:58f4  ; D#5
    audio_note $26, $11, $2                            ;; 05:58f6  ; D#5
    audio_note $26, $11, $4                            ;; 05:58f8  ; D#5
    audio_note $20, $11, $4                            ;; 05:58fa  ; A4
    audio_note $20, $11, $4                            ;; 05:58fc  ; A4
    audio_note $26, $11, $2                            ;; 05:58fe  ; D#5
    audio_note $26, $11, $4                            ;; 05:5900  ; D#5
    audio_note $26, $11, $2                            ;; 05:5902  ; D#5
    audio_note $26, $11, $4                            ;; 05:5904  ; D#5
    audio_note $26, $11, $2                            ;; 05:5906  ; D#5
    audio_note $26, $11, $4                            ;; 05:5908  ; D#5
    audio_note $26, $11, $2                            ;; 05:590a  ; D#5
    audio_note $26, $11, $4                            ;; 05:590c  ; D#5
    audio_note $25, $11, $4                            ;; 05:590e  ; D5
    audio_note $25, $11, $4                            ;; 05:5910  ; D5
    audio_end_pattern                                  ;; 05:5912

audio_05_5913_Pattern0A:
; pattern $0A
    audio_note $1F, $11, $2                            ;; 05:5913  ; G#4
    audio_note $2B, $11, $4                            ;; 05:5915  ; G#5
    audio_note $1F, $11, $2                            ;; 05:5917  ; G#4
    audio_note $2B, $11, $4                            ;; 05:5919  ; G#5
    audio_note $1F, $11, $2                            ;; 05:591b  ; G#4
    audio_note $2B, $11, $4                            ;; 05:591d  ; G#5
    audio_note $1F, $11, $2                            ;; 05:591f  ; G#4
    audio_note $2B, $11, $4                            ;; 05:5921  ; G#5
    audio_note $1A, $11, $4                            ;; 05:5923  ; D#4
    audio_note $26, $11, $4                            ;; 05:5925  ; D#5
    audio_note $1B, $11, $2                            ;; 05:5927  ; E4
    audio_note $27, $11, $4                            ;; 05:5929  ; E5
    audio_note $1B, $11, $2                            ;; 05:592b  ; E4
    audio_note $27, $11, $4                            ;; 05:592d  ; E5
    audio_note $1B, $11, $2                            ;; 05:592f  ; E4
    audio_note $27, $11, $4                            ;; 05:5931  ; E5
    audio_note $1B, $11, $2                            ;; 05:5933  ; E4
    audio_note $27, $11, $4                            ;; 05:5935  ; E5
    audio_note $1E, $11, $4                            ;; 05:5937  ; G4
    audio_note $2A, $11, $4                            ;; 05:5939  ; G5
    audio_end_pattern                                  ;; 05:593b

audio_05_593c_Pattern01:
; pattern $01
    audio_note $18, $01, $4                            ;; 05:593c  ; C#4
    audio_note $1E, $03, $2                            ;; 05:593e  ; G4
    audio_note $1E, $03, $2                            ;; 05:5940  ; G4
    audio_note $1E, $03, $4                            ;; 05:5942  ; G4
    audio_note $1E, $03, $4                            ;; 05:5944  ; G4
    audio_note $18, $01, $4                            ;; 05:5946  ; C#4
    audio_note $1E, $03, $4                            ;; 05:5948  ; G4
    audio_note $18, $01, $4                            ;; 05:594a  ; C#4
    audio_note $1E, $03, $4                            ;; 05:594c  ; G4
    audio_note $18, $01, $4                            ;; 05:594e  ; C#4
    audio_note $1E, $03, $2                            ;; 05:5950  ; G4
    audio_note $1E, $03, $2                            ;; 05:5952  ; G4
    audio_note $1E, $03, $4                            ;; 05:5954  ; G4
    audio_note $1E, $03, $4                            ;; 05:5956  ; G4
    audio_note $18, $01, $4                            ;; 05:5958  ; C#4
    audio_note $1E, $03, $4                            ;; 05:595a  ; G4
    audio_note $18, $01, $4                            ;; 05:595c  ; C#4
    audio_note $1E, $03, $4                            ;; 05:595e  ; G4
    audio_end_pattern                                  ;; 05:5960

audio_05_5961_Pattern02:
; pattern $02
    audio_note $18, $01, $6                            ;; 05:5961  ; C#4
    audio_note $24, $00, $7                            ;; 05:5963  ; C#5
    audio_note $1E, $03, $2                            ;; 05:5965  ; G4
    audio_note $1E, $03, $2                            ;; 05:5967  ; G4
    audio_note $1E, $03, $4                            ;; 05:5969  ; G4
    audio_note $1E, $03, $4                            ;; 05:596b  ; G4
    audio_note $18, $01, $4                            ;; 05:596d  ; C#4
    audio_note $18, $01, $6                            ;; 05:596f  ; C#4
    audio_note $18, $01, $6                            ;; 05:5971  ; C#4
    audio_note $1E, $03, $2                            ;; 05:5973  ; G4
    audio_note $1E, $03, $2                            ;; 05:5975  ; G4
    audio_note $1E, $03, $4                            ;; 05:5977  ; G4
    audio_note $1E, $03, $4                            ;; 05:5979  ; G4
    audio_note $18, $01, $4                            ;; 05:597b  ; C#4
    audio_note $18, $01, $6                            ;; 05:597d  ; C#4
    audio_note $18, $01, $6                            ;; 05:597f  ; C#4
    audio_note $1E, $03, $2                            ;; 05:5981  ; G4
    audio_note $1E, $03, $2                            ;; 05:5983  ; G4
    audio_note $1E, $03, $4                            ;; 05:5985  ; G4
    audio_note $1E, $03, $4                            ;; 05:5987  ; G4
    audio_note $18, $01, $6                            ;; 05:5989  ; C#4
    audio_note $1A, $02, $5                            ;; 05:598b  ; D#4
    audio_note $1A, $02, $4                            ;; 05:598d  ; D#4
    audio_note $1A, $02, $2                            ;; 05:598f  ; D#4
    audio_note $1A, $02, $2                            ;; 05:5991  ; D#4
    audio_note $1A, $02, $2                            ;; 05:5993  ; D#4
    audio_note $1A, $02, $4                            ;; 05:5995  ; D#4
    audio_note $1A, $02, $4                            ;; 05:5997  ; D#4
    audio_end_pattern                                  ;; 05:5999

audio_05_599a_Pattern03:
; pattern $03
    audio_note $18, $01, $2                            ;; 05:599a  ; C#4
    audio_note $1E, $03, $2                            ;; 05:599c  ; G4
    audio_note $18, $01, $2                            ;; 05:599e  ; C#4
    audio_note $1E, $03, $2                            ;; 05:59a0  ; G4
    audio_note $1A, $02, $2                            ;; 05:59a2  ; D#4
    audio_note $1E, $03, $2                            ;; 05:59a4  ; G4
    audio_note $1E, $03, $2                            ;; 05:59a6  ; G4
    audio_note $18, $01, $2                            ;; 05:59a8  ; C#4
    audio_note $1E, $03, $2                            ;; 05:59aa  ; G4
    audio_note $18, $01, $2                            ;; 05:59ac  ; C#4
    audio_note $18, $01, $2                            ;; 05:59ae  ; C#4
    audio_note $1E, $03, $2                            ;; 05:59b0  ; G4
    audio_note $1A, $02, $2                            ;; 05:59b2  ; D#4
    audio_note $1E, $03, $2                            ;; 05:59b4  ; G4
    audio_note $1E, $03, $2                            ;; 05:59b6  ; G4
    audio_note $1E, $03, $2                            ;; 05:59b8  ; G4
    audio_note $18, $01, $2                            ;; 05:59ba  ; C#4
    audio_note $1E, $03, $2                            ;; 05:59bc  ; G4
    audio_note $1E, $03, $2                            ;; 05:59be  ; G4
    audio_note $1E, $03, $2                            ;; 05:59c0  ; G4
    audio_note $1A, $02, $2                            ;; 05:59c2  ; D#4
    audio_note $1E, $03, $2                            ;; 05:59c4  ; G4
    audio_note $1E, $03, $2                            ;; 05:59c6  ; G4
    audio_note $18, $01, $2                            ;; 05:59c8  ; C#4
    audio_note $1E, $03, $2                            ;; 05:59ca  ; G4
    audio_note $18, $01, $2                            ;; 05:59cc  ; C#4
    audio_note $18, $01, $2                            ;; 05:59ce  ; C#4
    audio_note $1E, $03, $2                            ;; 05:59d0  ; G4
    audio_note $1A, $02, $2                            ;; 05:59d2  ; D#4
    audio_note $1A, $02, $2                            ;; 05:59d4  ; D#4
    audio_note $1A, $02, $2                            ;; 05:59d6  ; D#4
    audio_note $1E, $03, $2                            ;; 05:59d8  ; G4
    audio_end_pattern                                  ;; 05:59da

audio_05_59db_Song_MysteryTv_Ch1:
; SONG_MYSTERY_TV (song $12) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:59db
    audio_tempo $B9                                    ;; 05:59dd
    audio_call $00, $00, 3                             ;; 05:59df
    audio_call $25, $E5, 1                             ;; 05:59e3
    audio_call $26, $E5, 1                             ;; 05:59e7
    audio_call $00, $00, 8                             ;; 05:59eb
    audio_call $27, $E5, 1                             ;; 05:59ef
    audio_call $27, $E3, 1                             ;; 05:59f3
    audio_call $28, $E5, 1                             ;; 05:59f7
    audio_call $29, $E5, 1                             ;; 05:59fb
    audio_call $00, $00, 1                             ;; 05:59ff
    audio_note $24, $00, $9                            ;; 05:5a03  ; C#5
    audio_note $24, $00, $D                            ;; 05:5a05  ; C#5
    audio_call $2A, $E5, 1                             ;; 05:5a07
    audio_call $2B, $E5, 1                             ;; 05:5a0b
    audio_call $2C, $E5, 1                             ;; 05:5a0f
    audio_marker $01                                   ;; 05:5a13
    audio_goto audio_05_59db_Song_MysteryTv_Ch1        ;; 05:5a15

audio_05_5a18_Song_MysteryTv_Ch2:
; SONG_MYSTERY_TV (song $12) channel 2
; AUDIO_CMD_GOTO target
    audio_call $2D, $FD, 5                             ;; 05:5a18
    audio_call $2D, $02, 4                             ;; 05:5a1c
    audio_call $2E, $FD, 5                             ;; 05:5a20
    audio_call $2E, $FB, 1                             ;; 05:5a24
    audio_call $2E, $02, 4                             ;; 05:5a28
    audio_call $2F, $FD, 2                             ;; 05:5a2c
    audio_call $30, $FD, 14                            ;; 05:5a30
    audio_call $31, $FD, 1                             ;; 05:5a34
    audio_call $32, $FD, 2                             ;; 05:5a38
    audio_goto audio_05_5a18_Song_MysteryTv_Ch2        ;; 05:5a3c

audio_05_5a3f_Song_MysteryTv_Ch3:
; SONG_MYSTERY_TV (song $12) channel 3
; AUDIO_CMD_GOTO target
    audio_call $1E, $F1, 5                             ;; 05:5a3f
    audio_call $1E, $EA, 4                             ;; 05:5a43
    audio_call $1F, $E5, 2                             ;; 05:5a47
    audio_call $20, $E5, 1                             ;; 05:5a4b
    audio_call $20, $E3, 1                             ;; 05:5a4f
    audio_call $20, $EA, 4                             ;; 05:5a53
    audio_call $21, $F1, 1                             ;; 05:5a57
    audio_call $22, $F1, 7                             ;; 05:5a5b
    audio_call $23, $F1, 1                             ;; 05:5a5f
    audio_call $24, $F1, 2                             ;; 05:5a63
    audio_goto audio_05_5a3f_Song_MysteryTv_Ch3        ;; 05:5a67

audio_05_5a6a_Song_MysteryTv_Ch4:
; SONG_MYSTERY_TV (song $12) channel 4
; AUDIO_CMD_GOTO target
    audio_call $1A, $00, 9                             ;; 05:5a6a
    audio_call $1B, $00, 1                             ;; 05:5a6e
    audio_call $1C, $00, 8                             ;; 05:5a72
    audio_call $1D, $00, 9                             ;; 05:5a76
    audio_call $1A, $00, 6                             ;; 05:5a7a
    audio_goto audio_05_5a6a_Song_MysteryTv_Ch4        ;; 05:5a7e

audio_05_5a81_Pattern2D:
; pattern $2D
    audio_note $15, $18, $6                            ;; 05:5a81  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a83  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a85  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a87  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a89  ; A#3
    audio_note $15, $18, $6                            ;; 05:5a8b  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a8d  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a8f  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a91  ; A#3
    audio_note $15, $18, $4                            ;; 05:5a93  ; A#3
    audio_note $1D, $16, $6                            ;; 05:5a95  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5a97  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5a99  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5a9b  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5a9d  ; F#4
    audio_note $1D, $16, $6                            ;; 05:5a9f  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5aa1  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5aa3  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5aa5  ; F#4
    audio_note $1D, $16, $4                            ;; 05:5aa7  ; F#4
    audio_end_pattern                                  ;; 05:5aa9

audio_05_5aaa_Pattern2E:
; pattern $2E
    audio_note $24, $00, $4                            ;; 05:5aaa  ; C#5
    audio_note $1A, $16, $2                            ;; 05:5aac  ; D#4
    audio_note $1A, $16, $2                            ;; 05:5aae  ; D#4
    audio_note $1A, $16, $4                            ;; 05:5ab0  ; D#4
    audio_note $1A, $16, $4                            ;; 05:5ab2  ; D#4
    audio_note $24, $00, $6                            ;; 05:5ab4  ; C#5
    audio_note $1A, $16, $6                            ;; 05:5ab6  ; D#4
    audio_note $24, $00, $4                            ;; 05:5ab8  ; C#5
    audio_note $1A, $16, $2                            ;; 05:5aba  ; D#4
    audio_note $1A, $16, $2                            ;; 05:5abc  ; D#4
    audio_note $1A, $16, $4                            ;; 05:5abe  ; D#4
    audio_note $1A, $16, $4                            ;; 05:5ac0  ; D#4
    audio_note $24, $00, $4                            ;; 05:5ac2  ; C#5
    audio_note $1A, $16, $4                            ;; 05:5ac4  ; D#4
    audio_note $24, $00, $4                            ;; 05:5ac6  ; C#5
    audio_note $1A, $16, $4                            ;; 05:5ac8  ; D#4
    audio_end_pattern                                  ;; 05:5aca

audio_05_5acb_Pattern2F:
; pattern $2F
    audio_note $24, $00, $6                            ;; 05:5acb  ; C#5
    audio_note $1F, $16, $4                            ;; 05:5acd  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5acf  ; G#4
    audio_note $24, $00, $6                            ;; 05:5ad1  ; C#5
    audio_note $1F, $16, $4                            ;; 05:5ad3  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5ad5  ; G#4
    audio_note $24, $00, $6                            ;; 05:5ad7  ; C#5
    audio_note $1E, $13, $4                            ;; 05:5ad9  ; G4
    audio_note $1E, $13, $4                            ;; 05:5adb  ; G4
    audio_note $24, $00, $6                            ;; 05:5add  ; C#5
    audio_note $1E, $13, $4                            ;; 05:5adf  ; G4
    audio_note $1E, $13, $4                            ;; 05:5ae1  ; G4
    audio_end_pattern                                  ;; 05:5ae3

audio_05_5ae4_Pattern30:
; pattern $30
    audio_note $1F, $16, $5                            ;; 05:5ae4  ; G#4
    audio_note $1F, $16, $2                            ;; 05:5ae6  ; G#4
    audio_note $1F, $16, $5                            ;; 05:5ae8  ; G#4
    audio_note $1F, $16, $2                            ;; 05:5aea  ; G#4
    audio_note $1A, $14, $5                            ;; 05:5aec  ; D#4
    audio_note $1A, $14, $2                            ;; 05:5aee  ; D#4
    audio_note $1A, $14, $5                            ;; 05:5af0  ; D#4
    audio_note $1A, $14, $2                            ;; 05:5af2  ; D#4
    audio_end_pattern                                  ;; 05:5af4

audio_05_5af5_Pattern31:
; pattern $31
    audio_note $1F, $16, $4                            ;; 05:5af5  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5af7  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5af9  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5afb  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5afd  ; G#4
    audio_note $1F, $16, $4                            ;; 05:5aff  ; G#4
    audio_note $18, $18, $4                            ;; 05:5b01  ; C#4
    audio_note $0C, $18, $4                            ;; 05:5b03  ; C#3
    audio_note $18, $18, $4                            ;; 05:5b05  ; C#4
    audio_note $0C, $18, $4                            ;; 05:5b07  ; C#3
    audio_note $18, $18, $4                            ;; 05:5b09  ; C#4
    audio_note $18, $18, $4                            ;; 05:5b0b  ; C#4
    audio_note $1A, $15, $4                            ;; 05:5b0d  ; D#4
    audio_note $1A, $15, $4                            ;; 05:5b0f  ; D#4
    audio_note $1A, $15, $4                            ;; 05:5b11  ; D#4
    audio_note $1A, $15, $4                            ;; 05:5b13  ; D#4
    audio_note $1A, $15, $4                            ;; 05:5b15  ; D#4
    audio_note $1A, $15, $4                            ;; 05:5b17  ; D#4
    audio_note $1F, $17, $4                            ;; 05:5b19  ; G#4
    audio_note $1F, $17, $4                            ;; 05:5b1b  ; G#4
    audio_note $1F, $17, $4                            ;; 05:5b1d  ; G#4
    audio_note $1F, $17, $4                            ;; 05:5b1f  ; G#4
    audio_note $1F, $17, $4                            ;; 05:5b21  ; G#4
    audio_note $1F, $17, $4                            ;; 05:5b23  ; G#4
    audio_note $1C, $15, $4                            ;; 05:5b25  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b27  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b29  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b2b  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b2d  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b2f  ; F4
    audio_note $21, $17, $4                            ;; 05:5b31  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b33  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b35  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b37  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b39  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b3b  ; A#4
    audio_note $1C, $15, $4                            ;; 05:5b3d  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b3f  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b41  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b43  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b45  ; F4
    audio_note $1C, $15, $4                            ;; 05:5b47  ; F4
    audio_note $21, $17, $4                            ;; 05:5b49  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b4b  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b4d  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b4f  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b51  ; A#4
    audio_note $21, $17, $4                            ;; 05:5b53  ; A#4
    audio_end_pattern                                  ;; 05:5b55

audio_05_5b56_Pattern32:
; pattern $32
    audio_note $24, $00, $4                            ;; 05:5b56  ; C#5
    audio_note $1C, $13, $4                            ;; 05:5b58  ; F4
    audio_note $1C, $13, $4                            ;; 05:5b5a  ; F4
    audio_note $1C, $13, $4                            ;; 05:5b5c  ; F4
    audio_note $1C, $13, $6                            ;; 05:5b5e  ; F4
    audio_note $24, $00, $4                            ;; 05:5b60  ; C#5
    audio_note $15, $18, $4                            ;; 05:5b62  ; A#3
    audio_note $15, $18, $4                            ;; 05:5b64  ; A#3
    audio_note $15, $18, $4                            ;; 05:5b66  ; A#3
    audio_note $15, $18, $6                            ;; 05:5b68  ; A#3
    audio_note $24, $00, $4                            ;; 05:5b6a  ; C#5
    audio_note $1C, $13, $4                            ;; 05:5b6c  ; F4
    audio_note $1C, $13, $4                            ;; 05:5b6e  ; F4
    audio_note $1C, $13, $4                            ;; 05:5b70  ; F4
    audio_note $1C, $13, $6                            ;; 05:5b72  ; F4
    audio_note $24, $00, $4                            ;; 05:5b74  ; C#5
    audio_note $1D, $13, $4                            ;; 05:5b76  ; F#4
    audio_note $1D, $13, $4                            ;; 05:5b78  ; F#4
    audio_note $1D, $13, $4                            ;; 05:5b7a  ; F#4
    audio_note $1D, $13, $6                            ;; 05:5b7c  ; F#4
    audio_note $24, $00, $4                            ;; 05:5b7e  ; C#5
    audio_note $1A, $17, $4                            ;; 05:5b80  ; D#4
    audio_note $1A, $17, $4                            ;; 05:5b82  ; D#4
    audio_note $1A, $17, $4                            ;; 05:5b84  ; D#4
    audio_note $1A, $17, $6                            ;; 05:5b86  ; D#4
    audio_note $24, $00, $4                            ;; 05:5b88  ; C#5
    audio_note $1A, $17, $4                            ;; 05:5b8a  ; D#4
    audio_note $1A, $17, $4                            ;; 05:5b8c  ; D#4
    audio_note $1A, $17, $4                            ;; 05:5b8e  ; D#4
    audio_note $1A, $17, $6                            ;; 05:5b90  ; D#4
    audio_note $24, $00, $4                            ;; 05:5b92  ; C#5
    audio_note $1C, $13, $4                            ;; 05:5b94  ; F4
    audio_note $1C, $13, $4                            ;; 05:5b96  ; F4
    audio_note $1C, $13, $4                            ;; 05:5b98  ; F4
    audio_note $1C, $13, $6                            ;; 05:5b9a  ; F4
    audio_note $24, $00, $4                            ;; 05:5b9c  ; C#5
    audio_note $15, $18, $4                            ;; 05:5b9e  ; A#3
    audio_note $15, $18, $4                            ;; 05:5ba0  ; A#3
    audio_note $15, $18, $4                            ;; 05:5ba2  ; A#3
    audio_note $15, $18, $6                            ;; 05:5ba4  ; A#3
    audio_end_pattern                                  ;; 05:5ba6

audio_05_5ba7_Pattern25:
; pattern $25
    audio_note $45, $0B, $8                            ;; 05:5ba7  ; A#7
    audio_note $48, $0B, $6                            ;; 05:5ba9  ; C#8
    audio_note $4D, $0B, $8                            ;; 05:5bab  ; F#8
    audio_note $4C, $0B, $6                            ;; 05:5bad  ; F8
    audio_note $44, $0B, $8                            ;; 05:5baf  ; A7
    audio_note $43, $0B, $6                            ;; 05:5bb1  ; G#7
    audio_note $41, $0B, $6                            ;; 05:5bb3  ; F#7
    audio_note $43, $0B, $6                            ;; 05:5bb5  ; G#7
    audio_note $44, $0B, $6                            ;; 05:5bb7  ; A7
    audio_note $45, $0B, $8                            ;; 05:5bb9  ; A#7
    audio_note $48, $0B, $6                            ;; 05:5bbb  ; C#8
    audio_note $4C, $0B, $8                            ;; 05:5bbd  ; F8
    audio_note $4D, $0B, $6                            ;; 05:5bbf  ; F#8
    audio_note $50, $0B, $9                            ;; 05:5bc1  ; A8
    audio_note $4D, $0B, $9                            ;; 05:5bc3  ; F#8
    audio_note $51, $0B, $8                            ;; 05:5bc5  ; A#8
    audio_note $4C, $0B, $6                            ;; 05:5bc7  ; F8
    audio_note $48, $0B, $6                            ;; 05:5bc9  ; C#8
    audio_note $45, $0B, $6                            ;; 05:5bcb  ; A#7
    audio_note $47, $0B, $4                            ;; 05:5bcd  ; C8
    audio_note $48, $0B, $4                            ;; 05:5bcf  ; C#8
    audio_note $44, $0B, $8                            ;; 05:5bd1  ; A7
    audio_note $41, $0B, $6                            ;; 05:5bd3  ; F#7
    audio_note $3C, $0B, $8                            ;; 05:5bd5  ; C#7
    audio_note $38, $0B, $6                            ;; 05:5bd7  ; A6
    audio_note $39, $0B, $4                            ;; 05:5bd9  ; A#6
    audio_note $3C, $0B, $4                            ;; 05:5bdb  ; C#7
    audio_note $40, $0B, $6                            ;; 05:5bdd  ; F7
    audio_note $45, $0B, $4                            ;; 05:5bdf  ; A#7
    audio_note $47, $0B, $4                            ;; 05:5be1  ; C8
    audio_note $48, $0B, $6                            ;; 05:5be3  ; C#8
    audio_note $47, $0B, $6                            ;; 05:5be5  ; C8
    audio_note $45, $0B, $6                            ;; 05:5be7  ; A#7
    audio_note $44, $0B, $B                            ;; 05:5be9  ; A7
    audio_end_pattern                                  ;; 05:5beb

audio_05_5bec_Pattern26:
; pattern $26
    audio_note $4A, $0B, $7                            ;; 05:5bec  ; D#8
    audio_note $45, $0B, $4                            ;; 05:5bee  ; A#7
    audio_note $46, $0B, $4                            ;; 05:5bf0  ; B7
    audio_note $43, $0B, $4                            ;; 05:5bf2  ; G#7
    audio_note $45, $0B, $4                            ;; 05:5bf4  ; A#7
    audio_note $41, $0B, $4                            ;; 05:5bf6  ; F#7
    audio_note $43, $0B, $4                            ;; 05:5bf8  ; G#7
    audio_note $40, $0B, $4                            ;; 05:5bfa  ; F7
    audio_note $41, $0B, $4                            ;; 05:5bfc  ; F#7
    audio_note $3E, $0B, $4                            ;; 05:5bfe  ; D#7
    audio_note $3D, $0B, $8                            ;; 05:5c00  ; D7
    audio_note $3A, $0B, $6                            ;; 05:5c02  ; B6
    audio_note $35, $0B, $6                            ;; 05:5c04  ; F#6
    audio_note $3A, $0B, $6                            ;; 05:5c06  ; B6
    audio_note $3D, $0B, $6                            ;; 05:5c08  ; D7
    audio_note $32, $0B, $4                            ;; 05:5c0a  ; D#6
    audio_note $34, $0B, $4                            ;; 05:5c0c  ; F6
    audio_note $35, $0B, $4                            ;; 05:5c0e  ; F#6
    audio_note $39, $0B, $4                            ;; 05:5c10  ; A#6
    audio_note $3E, $0B, $4                            ;; 05:5c12  ; D#7
    audio_note $40, $0B, $4                            ;; 05:5c14  ; F7
    audio_note $41, $0B, $4                            ;; 05:5c16  ; F#7
    audio_note $45, $0B, $4                            ;; 05:5c18  ; A#7
    audio_note $4A, $0B, $4                            ;; 05:5c1a  ; D#8
    audio_note $4C, $0B, $4                            ;; 05:5c1c  ; F8
    audio_note $4D, $0B, $4                            ;; 05:5c1e  ; F#8
    audio_note $4A, $0B, $4                            ;; 05:5c20  ; D#8
    audio_note $49, $0B, $8                            ;; 05:5c22  ; D8
    audio_note $46, $0B, $6                            ;; 05:5c24  ; B7
    audio_note $41, $0B, $6                            ;; 05:5c26  ; F#7
    audio_note $46, $0B, $6                            ;; 05:5c28  ; B7
    audio_note $49, $0B, $6                            ;; 05:5c2a  ; D8
    audio_note $4A, $0B, $4                            ;; 05:5c2c  ; D#8
    audio_note $45, $0B, $4                            ;; 05:5c2e  ; A#7
    audio_note $46, $0B, $4                            ;; 05:5c30  ; B7
    audio_note $43, $0B, $4                            ;; 05:5c32  ; G#7
    audio_note $45, $0B, $4                            ;; 05:5c34  ; A#7
    audio_note $41, $0B, $4                            ;; 05:5c36  ; F#7
    audio_note $43, $0B, $4                            ;; 05:5c38  ; G#7
    audio_note $40, $0B, $4                            ;; 05:5c3a  ; F7
    audio_note $41, $0B, $4                            ;; 05:5c3c  ; F#7
    audio_note $3E, $0B, $4                            ;; 05:5c3e  ; D#7
    audio_note $40, $0B, $4                            ;; 05:5c40  ; F7
    audio_note $3D, $0B, $4                            ;; 05:5c42  ; D7
    audio_note $3A, $0B, $8                            ;; 05:5c44  ; B6
    audio_note $35, $0B, $4                            ;; 05:5c46  ; F#6
    audio_note $3A, $0B, $4                            ;; 05:5c48  ; B6
    audio_note $3D, $0B, $4                            ;; 05:5c4a  ; D7
    audio_note $3A, $0B, $4                            ;; 05:5c4c  ; B6
    audio_note $35, $0B, $6                            ;; 05:5c4e  ; F#6
    audio_note $31, $0B, $6                            ;; 05:5c50  ; D6
    audio_note $32, $0B, $7                            ;; 05:5c52  ; D#6
    audio_note $34, $0B, $4                            ;; 05:5c54  ; F6
    audio_note $35, $0B, $4                            ;; 05:5c56  ; F#6
    audio_note $38, $0B, $4                            ;; 05:5c58  ; A6
    audio_note $39, $0B, $6                            ;; 05:5c5a  ; A#6
    audio_note $38, $0B, $6                            ;; 05:5c5c  ; A6
    audio_note $35, $0B, $4                            ;; 05:5c5e  ; F#6
    audio_note $32, $0B, $4                            ;; 05:5c60  ; D#6
    audio_note $31, $0B, $B                            ;; 05:5c62  ; D6
    audio_end_pattern                                  ;; 05:5c64

audio_05_5c65_Pattern27:
; pattern $27
    audio_note $3E, $08, $6                            ;; 05:5c65  ; D#7
    audio_note $41, $08, $6                            ;; 05:5c67  ; F#7
    audio_note $44, $08, $6                            ;; 05:5c69  ; A7
    audio_note $45, $08, $6                            ;; 05:5c6b  ; A#7
    audio_note $24, $00, $6                            ;; 05:5c6d  ; C#5
    audio_note $46, $08, $2                            ;; 05:5c6f  ; B7
    audio_note $45, $08, $2                            ;; 05:5c71  ; A#7
    audio_note $44, $08, $2                            ;; 05:5c73  ; A7
    audio_note $43, $08, $2                            ;; 05:5c75  ; G#7
    audio_note $42, $08, $2                            ;; 05:5c77  ; G7
    audio_note $41, $08, $2                            ;; 05:5c79  ; F#7
    audio_note $40, $08, $2                            ;; 05:5c7b  ; F7
    audio_note $3F, $08, $2                            ;; 05:5c7d  ; E7
    audio_note $3E, $08, $6                            ;; 05:5c7f  ; D#7
    audio_end_pattern                                  ;; 05:5c81

audio_05_5c82_Pattern28:
; pattern $28
    audio_note $37, $08, $6                            ;; 05:5c82  ; G#6
    audio_note $3A, $08, $6                            ;; 05:5c84  ; B6
    audio_note $3D, $08, $6                            ;; 05:5c86  ; D7
    audio_note $3E, $08, $6                            ;; 05:5c88  ; D#7
    audio_note $3F, $08, $8                            ;; 05:5c8a  ; E7
    audio_note $3E, $08, $7                            ;; 05:5c8c  ; D#7
    audio_note $3E, $08, $2                            ;; 05:5c8e  ; D#7
    audio_note $3F, $08, $2                            ;; 05:5c90  ; E7
    audio_note $41, $08, $6                            ;; 05:5c92  ; F#7
    audio_note $3F, $08, $6                            ;; 05:5c94  ; E7
    audio_note $3E, $08, $6                            ;; 05:5c96  ; D#7
    audio_note $3D, $08, $6                            ;; 05:5c98  ; D7
    audio_note $3E, $08, $A                            ;; 05:5c9a  ; D#7
    audio_note $3A, $08, $6                            ;; 05:5c9c  ; B6
    audio_note $37, $08, $6                            ;; 05:5c9e  ; G#6
    audio_note $3D, $08, $6                            ;; 05:5ca0  ; D7
    audio_note $3E, $08, $6                            ;; 05:5ca2  ; D#7
    audio_note $36, $08, $7                            ;; 05:5ca4  ; G6
    audio_note $37, $08, $2                            ;; 05:5ca6  ; G#6
    audio_note $39, $08, $2                            ;; 05:5ca8  ; A#6
    audio_note $37, $08, $6                            ;; 05:5caa  ; G#6
    audio_note $32, $08, $6                            ;; 05:5cac  ; D#6
    audio_note $37, $08, $6                            ;; 05:5cae  ; G#6
    audio_note $39, $08, $6                            ;; 05:5cb0  ; A#6
    audio_note $3A, $08, $6                            ;; 05:5cb2  ; B6
    audio_note $33, $08, $6                            ;; 05:5cb4  ; E6
    audio_note $32, $08, $A                            ;; 05:5cb6  ; D#6
    audio_end_pattern                                  ;; 05:5cb8

audio_05_5cb9_Pattern29:
; pattern $29
    audio_note $37, $08, $6                            ;; 05:5cb9  ; G#6
    audio_note $3A, $08, $6                            ;; 05:5cbb  ; B6
    audio_note $3D, $08, $6                            ;; 05:5cbd  ; D7
    audio_note $3E, $08, $6                            ;; 05:5cbf  ; D#7
    audio_note $36, $08, $6                            ;; 05:5cc1  ; G6
    audio_note $3A, $08, $6                            ;; 05:5cc3  ; B6
    audio_note $3D, $08, $6                            ;; 05:5cc5  ; D7
    audio_note $3E, $08, $6                            ;; 05:5cc7  ; D#7
    audio_note $37, $08, $6                            ;; 05:5cc9  ; G#6
    audio_note $3A, $08, $6                            ;; 05:5ccb  ; B6
    audio_note $3D, $08, $6                            ;; 05:5ccd  ; D7
    audio_note $3E, $08, $6                            ;; 05:5ccf  ; D#7
    audio_note $3F, $08, $7                            ;; 05:5cd1  ; E7
    audio_note $3E, $08, $2                            ;; 05:5cd3  ; D#7
    audio_note $3D, $08, $2                            ;; 05:5cd5  ; D7
    audio_note $3E, $08, $8                            ;; 05:5cd7  ; D#7
    audio_end_pattern                                  ;; 05:5cd9

audio_05_5cda_Pattern2A:
; pattern $2A
    audio_note $43, $08, $D                            ;; 05:5cda  ; G#7
    audio_note $45, $08, $D                            ;; 05:5cdc  ; A#7
    audio_note $46, $08, $E                            ;; 05:5cde  ; B7
    audio_note $46, $08, $D                            ;; 05:5ce0  ; B7
    audio_note $45, $08, $D                            ;; 05:5ce2  ; A#7
    audio_note $46, $08, $D                            ;; 05:5ce4  ; B7
    audio_note $45, $08, $D                            ;; 05:5ce6  ; A#7
    audio_note $43, $08, $6                            ;; 05:5ce8  ; G#7
    audio_note $24, $00, $E                            ;; 05:5cea  ; C#5
    audio_note $46, $08, $D                            ;; 05:5cec  ; B7
    audio_note $45, $08, $E                            ;; 05:5cee  ; A#7
    audio_note $43, $08, $D                            ;; 05:5cf0  ; G#7
    audio_note $42, $08, $E                            ;; 05:5cf2  ; G7
    audio_note $3F, $08, $D                            ;; 05:5cf4  ; E7
    audio_note $3E, $08, $E                            ;; 05:5cf6  ; D#7
    audio_note $24, $00, $E                            ;; 05:5cf8  ; C#5
    audio_note $3E, $08, $E                            ;; 05:5cfa  ; D#7
    audio_note $43, $08, $E                            ;; 05:5cfc  ; G#7
    audio_note $3F, $08, $D                            ;; 05:5cfe  ; E7
    audio_note $3E, $08, $E                            ;; 05:5d00  ; D#7
    audio_note $3C, $08, $D                            ;; 05:5d02  ; C#7
    audio_note $3E, $08, $D                            ;; 05:5d04  ; D#7
    audio_note $3F, $08, $D                            ;; 05:5d06  ; E7
    audio_note $3E, $08, $D                            ;; 05:5d08  ; D#7
    audio_note $3C, $08, $E                            ;; 05:5d0a  ; C#7
    audio_note $3A, $08, $D                            ;; 05:5d0c  ; B6
    audio_note $39, $08, $6                            ;; 05:5d0e  ; A#6
    audio_note $3A, $08, $E                            ;; 05:5d10  ; B6
    audio_note $36, $08, $D                            ;; 05:5d12  ; G6
    audio_note $3E, $08, $8                            ;; 05:5d14  ; D#7
    audio_note $37, $08, $D                            ;; 05:5d16  ; G#6
    audio_note $39, $08, $D                            ;; 05:5d18  ; A#6
    audio_note $3A, $08, $D                            ;; 05:5d1a  ; B6
    audio_note $3E, $08, $D                            ;; 05:5d1c  ; D#7
    audio_note $43, $08, $D                            ;; 05:5d1e  ; G#7
    audio_note $45, $08, $D                            ;; 05:5d20  ; A#7
    audio_note $46, $08, $6                            ;; 05:5d22  ; B7
    audio_note $45, $08, $E                            ;; 05:5d24  ; A#7
    audio_note $43, $08, $D                            ;; 05:5d26  ; G#7
    audio_note $46, $08, $E                            ;; 05:5d28  ; B7
    audio_note $45, $08, $D                            ;; 05:5d2a  ; A#7
    audio_note $43, $08, $E                            ;; 05:5d2c  ; G#7
    audio_note $42, $08, $D                            ;; 05:5d2e  ; G7
    audio_note $3F, $08, $8                            ;; 05:5d30  ; E7
    audio_note $3E, $08, $6                            ;; 05:5d32  ; D#7
    audio_note $42, $08, $6                            ;; 05:5d34  ; G7
    audio_note $43, $08, $6                            ;; 05:5d36  ; G#7
    audio_note $3E, $08, $6                            ;; 05:5d38  ; D#7
    audio_note $3C, $08, $E                            ;; 05:5d3a  ; C#7
    audio_note $3A, $08, $D                            ;; 05:5d3c  ; B6
    audio_note $39, $08, $D                            ;; 05:5d3e  ; A#6
    audio_note $3A, $08, $D                            ;; 05:5d40  ; B6
    audio_note $39, $08, $D                            ;; 05:5d42  ; A#6
    audio_note $37, $08, $8                            ;; 05:5d44  ; G#6
    audio_note $4A, $08, $6                            ;; 05:5d46  ; D#8
    audio_note $4A, $08, $6                            ;; 05:5d48  ; D#8
    audio_note $49, $08, $E                            ;; 05:5d4a  ; D8
    audio_note $46, $08, $D                            ;; 05:5d4c  ; B7
    audio_note $43, $08, $6                            ;; 05:5d4e  ; G#7
    audio_note $4A, $08, $6                            ;; 05:5d50  ; D#8
    audio_note $4A, $08, $6                            ;; 05:5d52  ; D#8
    audio_note $49, $08, $E                            ;; 05:5d54  ; D8
    audio_note $46, $08, $D                            ;; 05:5d56  ; B7
    audio_note $43, $08, $6                            ;; 05:5d58  ; G#7
    audio_note $46, $08, $6                            ;; 05:5d5a  ; B7
    audio_note $45, $08, $E                            ;; 05:5d5c  ; A#7
    audio_note $43, $08, $D                            ;; 05:5d5e  ; G#7
    audio_note $42, $08, $6                            ;; 05:5d60  ; G7
    audio_note $43, $08, $E                            ;; 05:5d62  ; G#7
    audio_note $45, $08, $D                            ;; 05:5d64  ; A#7
    audio_note $43, $08, $A                            ;; 05:5d66  ; G#7
    audio_end_pattern                                  ;; 05:5d68

audio_05_5d69_Pattern2B:
; pattern $2B
    audio_note $43, $08, $8                            ;; 05:5d69  ; G#7
    audio_note $45, $08, $4                            ;; 05:5d6b  ; A#7
    audio_note $46, $08, $4                            ;; 05:5d6d  ; B7
    audio_note $48, $08, $8                            ;; 05:5d6f  ; C#8
    audio_note $46, $08, $4                            ;; 05:5d71  ; B7
    audio_note $45, $08, $4                            ;; 05:5d73  ; A#7
    audio_note $42, $08, $8                            ;; 05:5d75  ; G7
    audio_note $43, $08, $4                            ;; 05:5d77  ; G#7
    audio_note $45, $08, $4                            ;; 05:5d79  ; A#7
    audio_note $46, $08, $4                            ;; 05:5d7b  ; B7
    audio_note $45, $08, $4                            ;; 05:5d7d  ; A#7
    audio_note $43, $08, $8                            ;; 05:5d7f  ; G#7
    audio_note $47, $08, $8                            ;; 05:5d81  ; C8
    audio_note $4A, $08, $4                            ;; 05:5d83  ; D#8
    audio_note $4D, $08, $4                            ;; 05:5d85  ; F#8
    audio_note $4C, $08, $7                            ;; 05:5d87  ; F8
    audio_note $4A, $08, $4                            ;; 05:5d89  ; D#8
    audio_note $48, $08, $6                            ;; 05:5d8b  ; C#8
    audio_note $47, $08, $7                            ;; 05:5d8d  ; C8
    audio_note $45, $08, $4                            ;; 05:5d8f  ; A#7
    audio_note $44, $08, $6                            ;; 05:5d91  ; A7
    audio_note $45, $08, $9                            ;; 05:5d93  ; A#7
    audio_end_pattern                                  ;; 05:5d95

audio_05_5d96_Pattern2C:
; pattern $2C
    audio_note $4C, $08, $4                            ;; 05:5d96  ; F8
    audio_note $4D, $08, $4                            ;; 05:5d98  ; F#8
    audio_note $4C, $08, $4                            ;; 05:5d9a  ; F8
    audio_note $4A, $08, $4                            ;; 05:5d9c  ; D#8
    audio_note $47, $08, $4                            ;; 05:5d9e  ; C8
    audio_note $40, $08, $4                            ;; 05:5da0  ; F7
    audio_note $4A, $08, $4                            ;; 05:5da2  ; D#8
    audio_note $4C, $08, $4                            ;; 05:5da4  ; F8
    audio_note $4A, $08, $4                            ;; 05:5da6  ; D#8
    audio_note $48, $08, $4                            ;; 05:5da8  ; C#8
    audio_note $45, $08, $4                            ;; 05:5daa  ; A#7
    audio_note $40, $08, $4                            ;; 05:5dac  ; F7
    audio_note $48, $08, $4                            ;; 05:5dae  ; C#8
    audio_note $4A, $08, $4                            ;; 05:5db0  ; D#8
    audio_note $48, $08, $4                            ;; 05:5db2  ; C#8
    audio_note $47, $08, $4                            ;; 05:5db4  ; C8
    audio_note $44, $08, $4                            ;; 05:5db6  ; A7
    audio_note $40, $08, $4                            ;; 05:5db8  ; F7
    audio_note $47, $08, $4                            ;; 05:5dba  ; C8
    audio_note $48, $08, $4                            ;; 05:5dbc  ; C#8
    audio_note $47, $08, $4                            ;; 05:5dbe  ; C8
    audio_note $45, $08, $4                            ;; 05:5dc0  ; A#7
    audio_note $41, $08, $4                            ;; 05:5dc2  ; F#7
    audio_note $3E, $08, $4                            ;; 05:5dc4  ; D#7
    audio_note $39, $08, $4                            ;; 05:5dc6  ; A#6
    audio_note $3A, $08, $4                            ;; 05:5dc8  ; B6
    audio_note $3B, $08, $4                            ;; 05:5dca  ; C7
    audio_note $3C, $08, $4                            ;; 05:5dcc  ; C#7
    audio_note $3D, $08, $4                            ;; 05:5dce  ; D7
    audio_note $3E, $08, $4                            ;; 05:5dd0  ; D#7
    audio_note $3F, $08, $4                            ;; 05:5dd2  ; E7
    audio_note $40, $08, $4                            ;; 05:5dd4  ; F7
    audio_note $41, $08, $4                            ;; 05:5dd6  ; F#7
    audio_note $42, $08, $4                            ;; 05:5dd8  ; G7
    audio_note $43, $08, $4                            ;; 05:5dda  ; G#7
    audio_note $44, $08, $4                            ;; 05:5ddc  ; A7
    audio_note $45, $08, $4                            ;; 05:5dde  ; A#7
    audio_note $46, $08, $4                            ;; 05:5de0  ; B7
    audio_note $47, $08, $4                            ;; 05:5de2  ; C8
    audio_note $48, $08, $4                            ;; 05:5de4  ; C#8
    audio_note $4A, $08, $4                            ;; 05:5de6  ; D#8
    audio_note $4B, $08, $4                            ;; 05:5de8  ; E8
    audio_note $4C, $08, $9                            ;; 05:5dea  ; F8
    audio_note $4C, $08, $4                            ;; 05:5dec  ; F8
    audio_note $4D, $08, $4                            ;; 05:5dee  ; F#8
    audio_note $4C, $08, $4                            ;; 05:5df0  ; F8
    audio_note $4A, $08, $4                            ;; 05:5df2  ; D#8
    audio_note $47, $08, $4                            ;; 05:5df4  ; C8
    audio_note $40, $08, $4                            ;; 05:5df6  ; F7
    audio_note $4A, $08, $4                            ;; 05:5df8  ; D#8
    audio_note $4C, $08, $4                            ;; 05:5dfa  ; F8
    audio_note $4A, $08, $4                            ;; 05:5dfc  ; D#8
    audio_note $48, $08, $4                            ;; 05:5dfe  ; C#8
    audio_note $45, $08, $4                            ;; 05:5e00  ; A#7
    audio_note $40, $08, $4                            ;; 05:5e02  ; F7
    audio_note $48, $08, $4                            ;; 05:5e04  ; C#8
    audio_note $4A, $08, $4                            ;; 05:5e06  ; D#8
    audio_note $48, $08, $4                            ;; 05:5e08  ; C#8
    audio_note $47, $08, $4                            ;; 05:5e0a  ; C8
    audio_note $44, $08, $4                            ;; 05:5e0c  ; A7
    audio_note $40, $08, $4                            ;; 05:5e0e  ; F7
    audio_note $47, $08, $4                            ;; 05:5e10  ; C8
    audio_note $48, $08, $4                            ;; 05:5e12  ; C#8
    audio_note $47, $08, $4                            ;; 05:5e14  ; C8
    audio_note $45, $08, $4                            ;; 05:5e16  ; A#7
    audio_note $41, $08, $4                            ;; 05:5e18  ; F#7
    audio_note $3E, $08, $4                            ;; 05:5e1a  ; D#7
    audio_note $39, $08, $4                            ;; 05:5e1c  ; A#6
    audio_note $3A, $08, $4                            ;; 05:5e1e  ; B6
    audio_note $3B, $08, $4                            ;; 05:5e20  ; C7
    audio_note $3C, $08, $4                            ;; 05:5e22  ; C#7
    audio_note $3D, $08, $4                            ;; 05:5e24  ; D7
    audio_note $3E, $08, $4                            ;; 05:5e26  ; D#7
    audio_note $3F, $08, $4                            ;; 05:5e28  ; E7
    audio_note $40, $08, $4                            ;; 05:5e2a  ; F7
    audio_note $41, $08, $4                            ;; 05:5e2c  ; F#7
    audio_note $42, $08, $4                            ;; 05:5e2e  ; G7
    audio_note $43, $08, $4                            ;; 05:5e30  ; G#7
    audio_note $44, $08, $4                            ;; 05:5e32  ; A7
    audio_note $45, $08, $4                            ;; 05:5e34  ; A#7
    audio_note $46, $08, $4                            ;; 05:5e36  ; B7
    audio_note $47, $08, $4                            ;; 05:5e38  ; C8
    audio_note $48, $08, $4                            ;; 05:5e3a  ; C#8
    audio_note $4A, $08, $4                            ;; 05:5e3c  ; D#8
    audio_note $4C, $08, $4                            ;; 05:5e3e  ; F8
    audio_note $51, $08, $9                            ;; 05:5e40  ; A#8
    audio_end_pattern                                  ;; 05:5e42

audio_05_5e43_Pattern1E:
; pattern $1E
    audio_note $21, $12, $8                            ;; 05:5e43  ; A#4
    audio_note $28, $12, $6                            ;; 05:5e45  ; F5
    audio_note $2D, $12, $8                            ;; 05:5e47  ; A#5
    audio_note $21, $12, $6                            ;; 05:5e49  ; A#4
    audio_note $1D, $12, $8                            ;; 05:5e4b  ; F#4
    audio_note $24, $12, $6                            ;; 05:5e4d  ; C#5
    audio_note $29, $12, $7                            ;; 05:5e4f  ; F#5
    audio_note $24, $12, $4                            ;; 05:5e51  ; C#5
    audio_note $20, $12, $4                            ;; 05:5e53  ; A4
    audio_note $1D, $12, $4                            ;; 05:5e55  ; F#4
    audio_end_pattern                                  ;; 05:5e57

audio_05_5e58_Pattern1F:
; pattern $1F
    audio_note $26, $11, $6                            ;; 05:5e58  ; D#5
    audio_note $29, $11, $6                            ;; 05:5e5a  ; F#5
    audio_note $2C, $11, $6                            ;; 05:5e5c  ; A5
    audio_note $2D, $11, $7                            ;; 05:5e5e  ; A#5
    audio_note $26, $11, $4                            ;; 05:5e60  ; D#5
    audio_note $29, $11, $6                            ;; 05:5e62  ; F#5
    audio_note $2C, $11, $6                            ;; 05:5e64  ; A5
    audio_note $2D, $11, $4                            ;; 05:5e66  ; A#5
    audio_note $21, $11, $4                            ;; 05:5e68  ; A#4
    audio_note $26, $11, $6                            ;; 05:5e6a  ; D#5
    audio_note $29, $11, $6                            ;; 05:5e6c  ; F#5
    audio_note $2C, $11, $6                            ;; 05:5e6e  ; A5
    audio_note $2D, $11, $7                            ;; 05:5e70  ; A#5
    audio_note $26, $11, $4                            ;; 05:5e72  ; D#5
    audio_note $29, $11, $6                            ;; 05:5e74  ; F#5
    audio_note $2C, $11, $6                            ;; 05:5e76  ; A5
    audio_note $2D, $11, $6                            ;; 05:5e78  ; A#5
    audio_end_pattern                                  ;; 05:5e7a

audio_05_5e7b_Pattern20:
; pattern $20
    audio_note $26, $11, $6                            ;; 05:5e7b  ; D#5
    audio_note $29, $11, $6                            ;; 05:5e7d  ; F#5
    audio_note $2C, $11, $6                            ;; 05:5e7f  ; A5
    audio_note $2D, $11, $7                            ;; 05:5e81  ; A#5
    audio_note $26, $11, $4                            ;; 05:5e83  ; D#5
    audio_note $29, $11, $6                            ;; 05:5e85  ; F#5
    audio_note $2C, $11, $6                            ;; 05:5e87  ; A5
    audio_note $2D, $11, $6                            ;; 05:5e89  ; A#5
    audio_end_pattern                                  ;; 05:5e8b

audio_05_5e8c_Pattern21:
; pattern $21
    audio_note $1F, $12, $8                            ;; 05:5e8c  ; G#4
    audio_note $21, $12, $6                            ;; 05:5e8e  ; A#4
    audio_note $22, $12, $6                            ;; 05:5e90  ; B4
    audio_note $1E, $12, $8                            ;; 05:5e92  ; G4
    audio_note $1F, $12, $6                            ;; 05:5e94  ; G#4
    audio_note $21, $12, $6                            ;; 05:5e96  ; A#4
    audio_note $1F, $12, $8                            ;; 05:5e98  ; G#4
    audio_note $21, $12, $6                            ;; 05:5e9a  ; A#4
    audio_note $22, $12, $6                            ;; 05:5e9c  ; B4
    audio_note $1E, $12, $8                            ;; 05:5e9e  ; G4
    audio_note $1A, $12, $8                            ;; 05:5ea0  ; D#4
    audio_end_pattern                                  ;; 05:5ea2

audio_05_5ea3_Pattern22:
; pattern $22
    audio_note $1F, $12, $6                            ;; 05:5ea3  ; G#4
    audio_note $22, $12, $6                            ;; 05:5ea5  ; B4
    audio_note $1E, $12, $6                            ;; 05:5ea7  ; G4
    audio_note $21, $12, $6                            ;; 05:5ea9  ; A#4
    audio_note $1F, $12, $6                            ;; 05:5eab  ; G#4
    audio_note $22, $12, $6                            ;; 05:5ead  ; B4
    audio_note $1A, $12, $6                            ;; 05:5eaf  ; D#4
    audio_note $1E, $12, $6                            ;; 05:5eb1  ; G4
    audio_end_pattern                                  ;; 05:5eb3

audio_05_5eb4_Pattern23:
; pattern $23
    audio_note $1F, $12, $8                            ;; 05:5eb4  ; G#4
    audio_note $21, $12, $4                            ;; 05:5eb6  ; A#4
    audio_note $22, $12, $4                            ;; 05:5eb8  ; B4
    audio_note $24, $12, $7                            ;; 05:5eba  ; C#5
    audio_note $26, $12, $4                            ;; 05:5ebc  ; D#5
    audio_note $27, $12, $4                            ;; 05:5ebe  ; E5
    audio_note $24, $12, $4                            ;; 05:5ec0  ; C#5
    audio_note $1E, $12, $8                            ;; 05:5ec2  ; G4
    audio_note $1F, $12, $4                            ;; 05:5ec4  ; G#4
    audio_note $21, $12, $4                            ;; 05:5ec6  ; A#4
    audio_note $1F, $12, $7                            ;; 05:5ec8  ; G#4
    audio_note $22, $12, $4                            ;; 05:5eca  ; B4
    audio_note $26, $12, $6                            ;; 05:5ecc  ; D#5
    audio_note $28, $12, $7                            ;; 05:5ece  ; F5
    audio_note $2A, $12, $4                            ;; 05:5ed0  ; G5
    audio_note $2C, $12, $4                            ;; 05:5ed2  ; A5
    audio_note $28, $12, $4                            ;; 05:5ed4  ; F5
    audio_note $2D, $12, $6                            ;; 05:5ed6  ; A#5
    audio_note $28, $12, $6                            ;; 05:5ed8  ; F5
    audio_note $24, $12, $4                            ;; 05:5eda  ; C#5
    audio_note $21, $12, $4                            ;; 05:5edc  ; A#4
    audio_note $20, $12, $7                            ;; 05:5ede  ; A4
    audio_note $21, $12, $4                            ;; 05:5ee0  ; A#4
    audio_note $23, $12, $4                            ;; 05:5ee2  ; C5
    audio_note $1C, $12, $4                            ;; 05:5ee4  ; F4
    audio_note $21, $12, $9                            ;; 05:5ee6  ; A#4
    audio_end_pattern                                  ;; 05:5ee8

audio_05_5ee9_Pattern24:
; pattern $24
    audio_note $1C, $12, $8                            ;; 05:5ee9  ; F4
    audio_note $1E, $12, $4                            ;; 05:5eeb  ; G4
    audio_note $20, $12, $4                            ;; 05:5eed  ; A4
    audio_note $21, $12, $7                            ;; 05:5eef  ; A#4
    audio_note $23, $12, $4                            ;; 05:5ef1  ; C5
    audio_note $24, $12, $4                            ;; 05:5ef3  ; C#5
    audio_note $26, $12, $4                            ;; 05:5ef5  ; D#5
    audio_note $28, $12, $9                            ;; 05:5ef7  ; F5
    audio_note $29, $12, $7                            ;; 05:5ef9  ; F#5
    audio_note $28, $12, $4                            ;; 05:5efb  ; F5
    audio_note $26, $12, $4                            ;; 05:5efd  ; D#5
    audio_note $24, $12, $4                            ;; 05:5eff  ; C#5
    audio_note $26, $12, $9                            ;; 05:5f01  ; D#5
    audio_note $28, $12, $9                            ;; 05:5f03  ; F5
    audio_note $28, $12, $7                            ;; 05:5f05  ; F5
    audio_note $26, $12, $4                            ;; 05:5f07  ; D#5
    audio_note $24, $12, $4                            ;; 05:5f09  ; C#5
    audio_note $23, $12, $4                            ;; 05:5f0b  ; C5
    audio_note $21, $12, $9                            ;; 05:5f0d  ; A#4
    audio_end_pattern                                  ;; 05:5f0f

audio_05_5f10_Pattern1A:
; pattern $1A
    audio_note $18, $01, $6                            ;; 05:5f10  ; C#4
    audio_note $1E, $03, $4                            ;; 05:5f12  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f14  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f16  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f18  ; G4
    audio_note $18, $01, $4                            ;; 05:5f1a  ; C#4
    audio_note $1E, $03, $2                            ;; 05:5f1c  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f1e  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f20  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f22  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f24  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f26  ; G4
    audio_note $18, $01, $6                            ;; 05:5f28  ; C#4
    audio_note $1E, $03, $4                            ;; 05:5f2a  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f2c  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f2e  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f30  ; G4
    audio_note $18, $01, $6                            ;; 05:5f32  ; C#4
    audio_note $1E, $03, $4                            ;; 05:5f34  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f36  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f38  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f3a  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f3c  ; G4
    audio_end_pattern                                  ;; 05:5f3e

audio_05_5f3f_Pattern1B:
; pattern $1B
    audio_note $25, $06, $9                            ;; 05:5f3f  ; D5
    audio_note $24, $00, $4                            ;; 05:5f41  ; C#5
    audio_note $1E, $03, $2                            ;; 05:5f43  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f45  ; G4
    audio_note $1E, $03, $7                            ;; 05:5f47  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f49  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f4b  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f4d  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f4f  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f51  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f53  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f55  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f57  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f59  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f5b  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f5d  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f5f  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f61  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f63  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f65  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f67  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f69  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f6b  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f6d  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f6f  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f71  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f73  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f75  ; G4
    audio_end_pattern                                  ;; 05:5f77

audio_05_5f78_Pattern1C:
; pattern $1C
    audio_note $24, $00, $4                            ;; 05:5f78  ; C#5
    audio_note $1E, $03, $2                            ;; 05:5f7a  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f7c  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f7e  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f80  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f82  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f84  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f86  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f88  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f8a  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f8c  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f8e  ; G4
    audio_note $1E, $03, $6                            ;; 05:5f90  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f92  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f94  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f96  ; G4
    audio_note $1E, $03, $2                            ;; 05:5f98  ; G4
    audio_note $1E, $03, $4                            ;; 05:5f9a  ; G4
    audio_end_pattern                                  ;; 05:5f9c

audio_05_5f9d_Pattern1D:
; pattern $1D
    audio_note $18, $01, $4                            ;; 05:5f9d  ; C#4
    audio_note $1E, $03, $2                            ;; 05:5f9f  ; G4
    audio_note $1E, $03, $2                            ;; 05:5fa1  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fa3  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fa5  ; G4
    audio_note $1A, $02, $4                            ;; 05:5fa7  ; D#4
    audio_note $1E, $03, $2                            ;; 05:5fa9  ; G4
    audio_note $1E, $03, $2                            ;; 05:5fab  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fad  ; G4
    audio_note $1E, $03, $4                            ;; 05:5faf  ; G4
    audio_note $18, $01, $2                            ;; 05:5fb1  ; C#4
    audio_note $1E, $03, $2                            ;; 05:5fb3  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fb5  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fb7  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fb9  ; G4
    audio_note $1A, $02, $4                            ;; 05:5fbb  ; D#4
    audio_note $1E, $03, $2                            ;; 05:5fbd  ; G4
    audio_note $1E, $03, $2                            ;; 05:5fbf  ; G4
    audio_note $1E, $03, $2                            ;; 05:5fc1  ; G4
    audio_note $1E, $03, $2                            ;; 05:5fc3  ; G4
    audio_note $1E, $03, $4                            ;; 05:5fc5  ; G4
    audio_end_pattern                                  ;; 05:5fc7

audio_05_5fc8_Song_MissionSuccess_Ch1:
; SONG_MISSION_SUCCESS (song $13) channel 1
    audio_panning $FF                                  ;; 05:5fc8
    audio_tempo $FF                                    ;; 05:5fca
    audio_call $33, $F2, 1                             ;; 05:5fcc
    audio_call $34, $F2, 3                             ;; 05:5fd0
    audio_note $24, $00, $0                            ;; 05:5fd4  ; C#5
    audio_marker $01                                   ;; 05:5fd6
    audio_end                                          ;; 05:5fd8

audio_05_5fd9_Song_MissionSuccess_Ch2:
; SONG_MISSION_SUCCESS (song $13) channel 2
    audio_call $35, $F2, 1                             ;; 05:5fd9
    audio_call $36, $F2, 3                             ;; 05:5fdd
    audio_note $24, $00, $0                            ;; 05:5fe1  ; C#5
    audio_end                                          ;; 05:5fe3

audio_05_5fe4_Song_MissionSuccess_Ch3:
; SONG_MISSION_SUCCESS (song $13) channel 3
    audio_call $37, $FE, 1                             ;; 05:5fe4
    audio_note $24, $00, $0                            ;; 05:5fe8  ; C#5
    audio_end                                          ;; 05:5fea

audio_05_5feb_Song_MissionSuccess_Ch4:
; SONG_MISSION_SUCCESS (song $13) channel 4
    audio_note $24, $00, $0                            ;; 05:5feb  ; C#5
    audio_end                                          ;; 05:5fed

audio_05_5fee_Pattern33:
; pattern $33
    audio_note $24, $00, $4                            ;; 05:5fee  ; C#5
    audio_note $2A, $08, $0                            ;; 05:5ff0  ; G5
    audio_note $2E, $08, $0                            ;; 05:5ff2  ; B5
    audio_note $31, $08, $0                            ;; 05:5ff4  ; D6
    audio_note $36, $08, $0                            ;; 05:5ff6  ; G6
    audio_note $3A, $08, $0                            ;; 05:5ff8  ; B6
    audio_note $2F, $08, $0                            ;; 05:5ffa  ; C6
    audio_note $32, $08, $0                            ;; 05:5ffc  ; D#6
    audio_note $37, $08, $0                            ;; 05:5ffe  ; G#6
    audio_note $3B, $08, $0                            ;; 05:6000  ; C7
    audio_note $30, $08, $0                            ;; 05:6002  ; C#6
    audio_note $33, $08, $0                            ;; 05:6004  ; E6
    audio_note $38, $08, $0                            ;; 05:6006  ; A6
    audio_note $3C, $08, $0                            ;; 05:6008  ; C#7
    audio_note $31, $08, $0                            ;; 05:600a  ; D6
    audio_note $34, $08, $0                            ;; 05:600c  ; F6
    audio_note $39, $08, $0                            ;; 05:600e  ; A#6
    audio_note $3D, $08, $0                            ;; 05:6010  ; D7
    audio_note $32, $08, $0                            ;; 05:6012  ; D#6
    audio_note $35, $08, $0                            ;; 05:6014  ; F#6
    audio_note $3A, $08, $0                            ;; 05:6016  ; B6
    audio_note $3E, $08, $0                            ;; 05:6018  ; D#7
    audio_note $33, $08, $0                            ;; 05:601a  ; E6
    audio_note $36, $08, $0                            ;; 05:601c  ; G6
    audio_note $3B, $08, $0                            ;; 05:601e  ; C7
    audio_note $3F, $08, $0                            ;; 05:6020  ; E7
    audio_note $34, $08, $0                            ;; 05:6022  ; F6
    audio_note $37, $08, $0                            ;; 05:6024  ; G#6
    audio_note $3C, $08, $0                            ;; 05:6026  ; C#7
    audio_note $40, $08, $0                            ;; 05:6028  ; F7
    audio_note $35, $08, $0                            ;; 05:602a  ; F#6
    audio_note $38, $08, $0                            ;; 05:602c  ; A6
    audio_note $3D, $08, $0                            ;; 05:602e  ; D7
    audio_note $41, $08, $0                            ;; 05:6030  ; F#7
    audio_note $36, $08, $0                            ;; 05:6032  ; G6
    audio_note $39, $08, $0                            ;; 05:6034  ; A#6
    audio_note $3E, $08, $0                            ;; 05:6036  ; D#7
    audio_note $42, $08, $0                            ;; 05:6038  ; G7
    audio_note $37, $08, $0                            ;; 05:603a  ; G#6
    audio_note $3A, $08, $0                            ;; 05:603c  ; B6
    audio_note $3F, $08, $0                            ;; 05:603e  ; E7
    audio_note $43, $08, $0                            ;; 05:6040  ; G#7
    audio_note $38, $08, $0                            ;; 05:6042  ; A6
    audio_note $3B, $08, $0                            ;; 05:6044  ; C7
    audio_note $40, $08, $0                            ;; 05:6046  ; F7
    audio_note $44, $08, $0                            ;; 05:6048  ; A7
    audio_note $39, $08, $0                            ;; 05:604a  ; A#6
    audio_note $3C, $08, $0                            ;; 05:604c  ; C#7
    audio_note $41, $08, $0                            ;; 05:604e  ; F#7
    audio_note $45, $08, $0                            ;; 05:6050  ; A#7
    audio_note $3A, $08, $0                            ;; 05:6052  ; B6
    audio_note $3D, $08, $0                            ;; 05:6054  ; D7
    audio_note $42, $08, $0                            ;; 05:6056  ; G7
    audio_note $46, $08, $0                            ;; 05:6058  ; B7
    audio_note $3B, $08, $0                            ;; 05:605a  ; C7
    audio_note $3E, $08, $0                            ;; 05:605c  ; D#7
    audio_note $43, $08, $0                            ;; 05:605e  ; G#7
    audio_note $47, $08, $0                            ;; 05:6060  ; C8
    audio_note $3C, $08, $0                            ;; 05:6062  ; C#7
    audio_note $3F, $08, $0                            ;; 05:6064  ; E7
    audio_note $44, $08, $0                            ;; 05:6066  ; A7
    audio_end_pattern                                  ;; 05:6068

audio_05_6069_Pattern34:
; pattern $34
    audio_note $49, $08, $0                            ;; 05:6069  ; D8
    audio_note $3D, $08, $0                            ;; 05:606b  ; D7
    audio_note $40, $08, $0                            ;; 05:606d  ; F7
    audio_note $45, $08, $0                            ;; 05:606f  ; A#7
    audio_note $49, $08, $0                            ;; 05:6071  ; D8
    audio_note $3D, $08, $0                            ;; 05:6073  ; D7
    audio_note $40, $08, $0                            ;; 05:6075  ; F7
    audio_note $45, $08, $0                            ;; 05:6077  ; A#7
    audio_note $49, $08, $0                            ;; 05:6079  ; D8
    audio_note $3D, $08, $0                            ;; 05:607b  ; D7
    audio_note $40, $08, $0                            ;; 05:607d  ; F7
    audio_note $45, $08, $0                            ;; 05:607f  ; A#7
    audio_note $49, $08, $0                            ;; 05:6081  ; D8
    audio_note $3D, $08, $0                            ;; 05:6083  ; D7
    audio_note $40, $08, $0                            ;; 05:6085  ; F7
    audio_note $45, $08, $0                            ;; 05:6087  ; A#7
    audio_end_pattern                                  ;; 05:6089

audio_05_608a_Pattern35:
; pattern $35
    audio_note $2C, $08, $E                            ;; 05:608a  ; A5
    audio_note $2A, $08, $0                            ;; 05:608c  ; G5
    audio_note $2E, $08, $0                            ;; 05:608e  ; B5
    audio_note $31, $08, $0                            ;; 05:6090  ; D6
    audio_note $36, $08, $0                            ;; 05:6092  ; G6
    audio_note $3A, $08, $0                            ;; 05:6094  ; B6
    audio_note $2F, $08, $0                            ;; 05:6096  ; C6
    audio_note $32, $08, $0                            ;; 05:6098  ; D#6
    audio_note $37, $08, $0                            ;; 05:609a  ; G#6
    audio_note $3B, $08, $0                            ;; 05:609c  ; C7
    audio_note $30, $08, $0                            ;; 05:609e  ; C#6
    audio_note $33, $08, $0                            ;; 05:60a0  ; E6
    audio_note $38, $08, $0                            ;; 05:60a2  ; A6
    audio_note $3C, $08, $0                            ;; 05:60a4  ; C#7
    audio_note $31, $08, $0                            ;; 05:60a6  ; D6
    audio_note $34, $08, $0                            ;; 05:60a8  ; F6
    audio_note $39, $08, $0                            ;; 05:60aa  ; A#6
    audio_note $3D, $08, $0                            ;; 05:60ac  ; D7
    audio_note $32, $08, $0                            ;; 05:60ae  ; D#6
    audio_note $35, $08, $0                            ;; 05:60b0  ; F#6
    audio_note $3A, $08, $0                            ;; 05:60b2  ; B6
    audio_note $3E, $08, $0                            ;; 05:60b4  ; D#7
    audio_note $33, $08, $0                            ;; 05:60b6  ; E6
    audio_note $36, $08, $0                            ;; 05:60b8  ; G6
    audio_note $3B, $08, $0                            ;; 05:60ba  ; C7
    audio_note $3F, $08, $D                            ;; 05:60bc  ; E7
    audio_note $24, $00, $8                            ;; 05:60be  ; C#5
    audio_note $24, $00, $8                            ;; 05:60c0  ; C#5
    audio_end_pattern                                  ;; 05:60c2

audio_05_60c3_Pattern36:
; pattern $36
    audio_note $45, $08, $0                            ;; 05:60c3  ; A#7
    audio_note $49, $08, $0                            ;; 05:60c5  ; D8
    audio_note $3D, $08, $0                            ;; 05:60c7  ; D7
    audio_note $40, $08, $0                            ;; 05:60c9  ; F7
    audio_note $45, $08, $0                            ;; 05:60cb  ; A#7
    audio_note $49, $08, $0                            ;; 05:60cd  ; D8
    audio_note $3D, $08, $0                            ;; 05:60cf  ; D7
    audio_note $40, $08, $0                            ;; 05:60d1  ; F7
    audio_note $45, $08, $0                            ;; 05:60d3  ; A#7
    audio_note $49, $08, $0                            ;; 05:60d5  ; D8
    audio_note $3D, $08, $0                            ;; 05:60d7  ; D7
    audio_note $40, $08, $0                            ;; 05:60d9  ; F7
    audio_note $45, $08, $0                            ;; 05:60db  ; A#7
    audio_note $49, $08, $0                            ;; 05:60dd  ; D8
    audio_note $3D, $08, $0                            ;; 05:60df  ; D7
    audio_note $40, $08, $0                            ;; 05:60e1  ; F7
    audio_end_pattern                                  ;; 05:60e3

audio_05_60e4_Pattern37:
; pattern $37
    audio_note $24, $00, $8                            ;; 05:60e4  ; C#5
    audio_note $2C, $11, $5                            ;; 05:60e6  ; A5
    audio_note $1C, $11, $2                            ;; 05:60e8  ; F4
    audio_note $1F, $11, $4                            ;; 05:60ea  ; G#4
    audio_note $1C, $11, $4                            ;; 05:60ec  ; F4
    audio_note $24, $11, $2                            ;; 05:60ee  ; C#5
    audio_note $21, $11, $2                            ;; 05:60f0  ; A#4
    audio_note $1F, $11, $2                            ;; 05:60f2  ; G#4
    audio_note $1C, $11, $5                            ;; 05:60f4  ; F4
    audio_note $1F, $11, $4                            ;; 05:60f6  ; G#4
    audio_note $18, $11, $4                            ;; 05:60f8  ; C#4
    audio_note $1C, $11, $4                            ;; 05:60fa  ; F4
    audio_note $13, $11, $6                            ;; 05:60fc  ; G#3
    audio_note $15, $11, $6                            ;; 05:60fe  ; A#3
    audio_note $24, $00, $6                            ;; 05:6100  ; C#5
    audio_note $24, $00, $8                            ;; 05:6102  ; C#5
    audio_note $15, $11, $6                            ;; 05:6104  ; A#3
    audio_note $24, $00, $6                            ;; 05:6106  ; C#5
    audio_end_pattern                                  ;; 05:6108

audio_05_6109_Song_AnimeChannel_Ch1:
; SONG_ANIME_CHANNEL (song $14) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:6109
    audio_tempo $AB                                    ;; 05:610b
    audio_call $45, $E5, 1                             ;; 05:610d
    audio_call $46, $E5, 2                             ;; 05:6111
    audio_call $47, $E5, 1                             ;; 05:6115
    audio_call $47, $E7, 1                             ;; 05:6119
    audio_call $46, $E7, 1                             ;; 05:611d
    audio_call $48, $E5, 2                             ;; 05:6121
    audio_call $47, $E7, 1                             ;; 05:6125
    audio_call $49, $E5, 2                             ;; 05:6129
    audio_call $48, $E3, 1                             ;; 05:612d
    audio_call $4A, $E5, 1                             ;; 05:6131
    audio_call $45, $E5, 1                             ;; 05:6135
    audio_marker $01                                   ;; 05:6139
    audio_goto audio_05_6109_Song_AnimeChannel_Ch1     ;; 05:613b

audio_05_613e_Song_AnimeChannel_Ch2:
; SONG_ANIME_CHANNEL (song $14) channel 2
; AUDIO_CMD_GOTO target
    audio_call $3F, $E5, 1                             ;; 05:613e
    audio_call $40, $E5, 2                             ;; 05:6142
    audio_call $41, $E5, 1                             ;; 05:6146
    audio_call $41, $E7, 1                             ;; 05:614a
    audio_call $40, $E7, 1                             ;; 05:614e
    audio_call $42, $E5, 2                             ;; 05:6152
    audio_call $41, $E7, 1                             ;; 05:6156
    audio_call $43, $E5, 2                             ;; 05:615a
    audio_call $42, $E3, 1                             ;; 05:615e
    audio_call $44, $E5, 1                             ;; 05:6162
    audio_call $3F, $E5, 1                             ;; 05:6166
    audio_goto audio_05_613e_Song_AnimeChannel_Ch2     ;; 05:616a

audio_05_616d_Song_AnimeChannel_Ch3:
; SONG_ANIME_CHANNEL (song $14) channel 3
; AUDIO_CMD_GOTO target
    audio_call $39, $F1, 1                             ;; 05:616d
    audio_call $3A, $F1, 2                             ;; 05:6171
    audio_call $3B, $F1, 1                             ;; 05:6175
    audio_call $3B, $F3, 1                             ;; 05:6179
    audio_call $3A, $F3, 1                             ;; 05:617d
    audio_call $3C, $F1, 2                             ;; 05:6181
    audio_call $3B, $F3, 1                             ;; 05:6185
    audio_call $3D, $F1, 2                             ;; 05:6189
    audio_call $3C, $EF, 1                             ;; 05:618d
    audio_call $3E, $F1, 1                             ;; 05:6191
    audio_call $39, $F1, 1                             ;; 05:6195
    audio_goto audio_05_616d_Song_AnimeChannel_Ch3     ;; 05:6199

audio_05_619c_Song_AnimeChannel_Ch4:
; SONG_ANIME_CHANNEL (song $14) channel 4
; AUDIO_CMD_GOTO target
    audio_call $38, $00, 38                            ;; 05:619c
    audio_goto audio_05_619c_Song_AnimeChannel_Ch4     ;; 05:61a0

audio_05_61a3_Pattern45:
; pattern $45
    audio_note $3C, $09, $A                            ;; 05:61a3  ; C#7
    audio_note $3B, $09, $A                            ;; 05:61a5  ; C7
    audio_note $39, $09, $A                            ;; 05:61a7  ; A#6
    audio_note $37, $09, $A                            ;; 05:61a9  ; G#6
    audio_end_pattern                                  ;; 05:61ab

audio_05_61ac_Pattern46:
; pattern $46
    audio_note $24, $00, $6                            ;; 05:61ac  ; C#5
    audio_note $45, $0C, $4                            ;; 05:61ae  ; A#7
    audio_note $43, $0C, $4                            ;; 05:61b0  ; G#7
    audio_note $45, $0C, $6                            ;; 05:61b2  ; A#7
    audio_note $48, $0C, $6                            ;; 05:61b4  ; C#8
    audio_note $40, $0C, $9                            ;; 05:61b6  ; F7
    audio_note $3E, $0C, $4                            ;; 05:61b8  ; D#7
    audio_note $3C, $0C, $4                            ;; 05:61ba  ; C#7
    audio_note $3E, $0C, $C                            ;; 05:61bc  ; D#7
    audio_note $24, $00, $6                            ;; 05:61be  ; C#5
    audio_note $45, $0C, $4                            ;; 05:61c0  ; A#7
    audio_note $43, $0C, $4                            ;; 05:61c2  ; G#7
    audio_note $45, $0C, $6                            ;; 05:61c4  ; A#7
    audio_note $48, $0C, $6                            ;; 05:61c6  ; C#8
    audio_note $40, $0C, $9                            ;; 05:61c8  ; F7
    audio_note $48, $0C, $4                            ;; 05:61ca  ; C#8
    audio_note $4C, $0C, $4                            ;; 05:61cc  ; F8
    audio_note $4A, $0C, $C                            ;; 05:61ce  ; D#8
    audio_end_pattern                                  ;; 05:61d0

audio_05_61d1_Pattern47:
; pattern $47
    audio_note $45, $08, $4                            ;; 05:61d1  ; A#7
    audio_note $45, $08, $2                            ;; 05:61d3  ; A#7
    audio_note $45, $08, $2                            ;; 05:61d5  ; A#7
    audio_note $43, $08, $4                            ;; 05:61d7  ; G#7
    audio_note $43, $08, $4                            ;; 05:61d9  ; G#7
    audio_note $40, $08, $4                            ;; 05:61db  ; F7
    audio_note $40, $08, $4                            ;; 05:61dd  ; F7
    audio_note $3C, $08, $4                            ;; 05:61df  ; C#7
    audio_note $3C, $08, $4                            ;; 05:61e1  ; C#7
    audio_note $3E, $08, $2                            ;; 05:61e3  ; D#7
    audio_note $40, $08, $2                            ;; 05:61e5  ; F7
    audio_note $3E, $08, $2                            ;; 05:61e7  ; D#7
    audio_note $3C, $08, $2                            ;; 05:61e9  ; C#7
    audio_note $39, $08, $4                            ;; 05:61eb  ; A#6
    audio_note $37, $08, $4                            ;; 05:61ed  ; G#6
    audio_note $39, $08, $8                            ;; 05:61ef  ; A#6
    audio_note $45, $08, $4                            ;; 05:61f1  ; A#7
    audio_note $45, $08, $2                            ;; 05:61f3  ; A#7
    audio_note $45, $08, $2                            ;; 05:61f5  ; A#7
    audio_note $43, $08, $4                            ;; 05:61f7  ; G#7
    audio_note $43, $08, $4                            ;; 05:61f9  ; G#7
    audio_note $40, $08, $4                            ;; 05:61fb  ; F7
    audio_note $40, $08, $4                            ;; 05:61fd  ; F7
    audio_note $3C, $08, $4                            ;; 05:61ff  ; C#7
    audio_note $3C, $08, $4                            ;; 05:6201  ; C#7
    audio_note $3E, $08, $2                            ;; 05:6203  ; D#7
    audio_note $40, $08, $2                            ;; 05:6205  ; F7
    audio_note $3E, $08, $2                            ;; 05:6207  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6209  ; C#7
    audio_note $3E, $08, $4                            ;; 05:620b  ; D#7
    audio_note $40, $08, $4                            ;; 05:620d  ; F7
    audio_note $40, $08, $8                            ;; 05:620f  ; F7
    audio_note $45, $08, $4                            ;; 05:6211  ; A#7
    audio_note $45, $08, $2                            ;; 05:6213  ; A#7
    audio_note $45, $08, $2                            ;; 05:6215  ; A#7
    audio_note $48, $08, $4                            ;; 05:6217  ; C#8
    audio_note $48, $08, $4                            ;; 05:6219  ; C#8
    audio_note $47, $08, $4                            ;; 05:621b  ; C8
    audio_note $47, $08, $4                            ;; 05:621d  ; C8
    audio_note $43, $08, $6                            ;; 05:621f  ; G#7
    audio_note $45, $08, $4                            ;; 05:6221  ; A#7
    audio_note $45, $08, $2                            ;; 05:6223  ; A#7
    audio_note $45, $08, $2                            ;; 05:6225  ; A#7
    audio_note $45, $08, $4                            ;; 05:6227  ; A#7
    audio_note $43, $08, $4                            ;; 05:6229  ; G#7
    audio_note $40, $08, $8                            ;; 05:622b  ; F7
    audio_note $3E, $08, $2                            ;; 05:622d  ; D#7
    audio_note $40, $08, $2                            ;; 05:622f  ; F7
    audio_note $3E, $08, $2                            ;; 05:6231  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6233  ; C#7
    audio_note $39, $08, $4                            ;; 05:6235  ; A#6
    audio_note $37, $08, $4                            ;; 05:6237  ; G#6
    audio_note $39, $08, $4                            ;; 05:6239  ; A#6
    audio_note $39, $08, $2                            ;; 05:623b  ; A#6
    audio_note $39, $08, $2                            ;; 05:623d  ; A#6
    audio_note $39, $08, $4                            ;; 05:623f  ; A#6
    audio_note $3C, $08, $4                            ;; 05:6241  ; C#7
    audio_note $3E, $08, $4                            ;; 05:6243  ; D#7
    audio_note $3E, $08, $2                            ;; 05:6245  ; D#7
    audio_note $3E, $08, $2                            ;; 05:6247  ; D#7
    audio_note $3E, $08, $4                            ;; 05:6249  ; D#7
    audio_note $3C, $08, $4                            ;; 05:624b  ; C#7
    audio_note $39, $08, $8                            ;; 05:624d  ; A#6
    audio_end_pattern                                  ;; 05:624f

audio_05_6250_Pattern48:
; pattern $48
    audio_note $47, $08, $6                            ;; 05:6250  ; C8
    audio_note $45, $08, $6                            ;; 05:6252  ; A#7
    audio_note $42, $08, $2                            ;; 05:6254  ; G7
    audio_note $43, $08, $2                            ;; 05:6256  ; G#7
    audio_note $42, $08, $2                            ;; 05:6258  ; G7
    audio_note $40, $08, $2                            ;; 05:625a  ; F7
    audio_note $42, $08, $6                            ;; 05:625c  ; G7
    audio_note $40, $08, $4                            ;; 05:625e  ; F7
    audio_note $40, $08, $2                            ;; 05:6260  ; F7
    audio_note $40, $08, $2                            ;; 05:6262  ; F7
    audio_note $40, $08, $4                            ;; 05:6264  ; F7
    audio_note $3E, $08, $4                            ;; 05:6266  ; D#7
    audio_note $42, $08, $8                            ;; 05:6268  ; G7
    audio_note $47, $08, $6                            ;; 05:626a  ; C8
    audio_note $45, $08, $6                            ;; 05:626c  ; A#7
    audio_note $42, $08, $2                            ;; 05:626e  ; G7
    audio_note $43, $08, $2                            ;; 05:6270  ; G#7
    audio_note $42, $08, $2                            ;; 05:6272  ; G7
    audio_note $3E, $08, $2                            ;; 05:6274  ; D#7
    audio_note $42, $08, $6                            ;; 05:6276  ; G7
    audio_note $40, $08, $4                            ;; 05:6278  ; F7
    audio_note $40, $08, $2                            ;; 05:627a  ; F7
    audio_note $40, $08, $2                            ;; 05:627c  ; F7
    audio_note $40, $08, $4                            ;; 05:627e  ; F7
    audio_note $3E, $08, $4                            ;; 05:6280  ; D#7
    audio_note $3B, $08, $8                            ;; 05:6282  ; C7
    audio_end_pattern                                  ;; 05:6284

audio_05_6285_Pattern49:
; pattern $49
    audio_note $3B, $08, $5                            ;; 05:6285  ; C7
    audio_note $39, $08, $2                            ;; 05:6287  ; A#6
    audio_note $36, $08, $4                            ;; 05:6289  ; G6
    audio_note $34, $08, $4                            ;; 05:628b  ; F6
    audio_note $36, $08, $6                            ;; 05:628d  ; G6
    audio_note $39, $08, $6                            ;; 05:628f  ; A#6
    audio_note $3B, $08, $A                            ;; 05:6291  ; C7
    audio_end_pattern                                  ;; 05:6293

audio_05_6294_Pattern4A:
; pattern $4A
    audio_note $3E, $08, $2                            ;; 05:6294  ; D#7
    audio_note $40, $08, $2                            ;; 05:6296  ; F7
    audio_note $3E, $08, $2                            ;; 05:6298  ; D#7
    audio_note $3C, $08, $2                            ;; 05:629a  ; C#7
    audio_note $39, $08, $4                            ;; 05:629c  ; A#6
    audio_note $37, $08, $4                            ;; 05:629e  ; G#6
    audio_note $39, $08, $4                            ;; 05:62a0  ; A#6
    audio_note $3C, $08, $4                            ;; 05:62a2  ; C#7
    audio_note $40, $08, $2                            ;; 05:62a4  ; F7
    audio_note $40, $08, $2                            ;; 05:62a6  ; F7
    audio_note $40, $08, $4                            ;; 05:62a8  ; F7
    audio_note $3E, $08, $2                            ;; 05:62aa  ; D#7
    audio_note $40, $08, $2                            ;; 05:62ac  ; F7
    audio_note $3E, $08, $2                            ;; 05:62ae  ; D#7
    audio_note $3C, $08, $2                            ;; 05:62b0  ; C#7
    audio_note $39, $08, $4                            ;; 05:62b2  ; A#6
    audio_note $3C, $08, $4                            ;; 05:62b4  ; C#7
    audio_note $40, $08, $8                            ;; 05:62b6  ; F7
    audio_note $3E, $08, $2                            ;; 05:62b8  ; D#7
    audio_note $40, $08, $2                            ;; 05:62ba  ; F7
    audio_note $3E, $08, $2                            ;; 05:62bc  ; D#7
    audio_note $3C, $08, $2                            ;; 05:62be  ; C#7
    audio_note $39, $08, $4                            ;; 05:62c0  ; A#6
    audio_note $37, $08, $2                            ;; 05:62c2  ; G#6
    audio_note $39, $08, $2                            ;; 05:62c4  ; A#6
    audio_note $3C, $08, $4                            ;; 05:62c6  ; C#7
    audio_note $39, $08, $4                            ;; 05:62c8  ; A#6
    audio_note $37, $08, $4                            ;; 05:62ca  ; G#6
    audio_note $34, $08, $4                            ;; 05:62cc  ; F6
    audio_note $37, $08, $2                            ;; 05:62ce  ; G#6
    audio_note $39, $08, $2                            ;; 05:62d0  ; A#6
    audio_note $3C, $08, $2                            ;; 05:62d2  ; C#7
    audio_note $39, $08, $2                            ;; 05:62d4  ; A#6
    audio_note $37, $08, $4                            ;; 05:62d6  ; G#6
    audio_note $34, $08, $4                            ;; 05:62d8  ; F6
    audio_note $39, $08, $8                            ;; 05:62da  ; A#6
    audio_end_pattern                                  ;; 05:62dc

audio_05_62dd_Pattern3F:
; pattern $3F
    audio_note $34, $09, $A                            ;; 05:62dd  ; F6
    audio_note $32, $09, $A                            ;; 05:62df  ; D#6
    audio_note $30, $09, $A                            ;; 05:62e1  ; C#6
    audio_note $2F, $09, $A                            ;; 05:62e3  ; C6
    audio_end_pattern                                  ;; 05:62e5

audio_05_62e6_Pattern40:
; pattern $40
    audio_note $24, $00, $6                            ;; 05:62e6  ; C#5
    audio_note $3C, $0F, $4                            ;; 05:62e8  ; C#7
    audio_note $3B, $0F, $4                            ;; 05:62ea  ; C7
    audio_note $3C, $0F, $6                            ;; 05:62ec  ; C#7
    audio_note $40, $0F, $6                            ;; 05:62ee  ; F7
    audio_note $39, $0F, $A                            ;; 05:62f0  ; A#6
    audio_note $35, $0F, $6                            ;; 05:62f2  ; F#6
    audio_note $37, $0F, $6                            ;; 05:62f4  ; G#6
    audio_note $39, $0F, $4                            ;; 05:62f6  ; A#6
    audio_note $37, $0F, $4                            ;; 05:62f8  ; G#6
    audio_note $35, $0F, $4                            ;; 05:62fa  ; F#6
    audio_note $34, $0F, $4                            ;; 05:62fc  ; F6
    audio_note $35, $0F, $6                            ;; 05:62fe  ; F#6
    audio_note $34, $0F, $6                            ;; 05:6300  ; F6
    audio_note $32, $0F, $6                            ;; 05:6302  ; D#6
    audio_note $35, $0F, $6                            ;; 05:6304  ; F#6
    audio_note $24, $00, $6                            ;; 05:6306  ; C#5
    audio_note $3C, $0F, $4                            ;; 05:6308  ; C#7
    audio_note $3B, $0F, $4                            ;; 05:630a  ; C7
    audio_note $3C, $0F, $6                            ;; 05:630c  ; C#7
    audio_note $40, $0F, $6                            ;; 05:630e  ; F7
    audio_note $39, $0F, $A                            ;; 05:6310  ; A#6
    audio_note $41, $0F, $6                            ;; 05:6312  ; F#7
    audio_note $43, $0F, $6                            ;; 05:6314  ; G#7
    audio_note $45, $0F, $4                            ;; 05:6316  ; A#7
    audio_note $43, $0F, $4                            ;; 05:6318  ; G#7
    audio_note $41, $0F, $4                            ;; 05:631a  ; F#7
    audio_note $40, $0F, $4                            ;; 05:631c  ; F7
    audio_note $41, $0F, $6                            ;; 05:631e  ; F#7
    audio_note $40, $0F, $6                            ;; 05:6320  ; F7
    audio_note $3E, $0F, $6                            ;; 05:6322  ; D#7
    audio_note $41, $0F, $6                            ;; 05:6324  ; F#7
    audio_end_pattern                                  ;; 05:6326

audio_05_6327_Pattern41:
; pattern $41
    audio_note $40, $0F, $4                            ;; 05:6327  ; F7
    audio_note $40, $0F, $2                            ;; 05:6329  ; F7
    audio_note $40, $0F, $2                            ;; 05:632b  ; F7
    audio_note $3E, $0F, $4                            ;; 05:632d  ; D#7
    audio_note $3E, $0F, $4                            ;; 05:632f  ; D#7
    audio_note $3C, $0F, $4                            ;; 05:6331  ; C#7
    audio_note $3C, $0F, $4                            ;; 05:6333  ; C#7
    audio_note $39, $0F, $4                            ;; 05:6335  ; A#6
    audio_note $39, $0F, $4                            ;; 05:6337  ; A#6
    audio_note $39, $0F, $6                            ;; 05:6339  ; A#6
    audio_note $35, $0F, $4                            ;; 05:633b  ; F#6
    audio_note $34, $0F, $4                            ;; 05:633d  ; F6
    audio_note $34, $0F, $8                            ;; 05:633f  ; F6
    audio_note $40, $0F, $4                            ;; 05:6341  ; F7
    audio_note $40, $0F, $2                            ;; 05:6343  ; F7
    audio_note $40, $0F, $2                            ;; 05:6345  ; F7
    audio_note $3E, $0F, $4                            ;; 05:6347  ; D#7
    audio_note $3E, $0F, $4                            ;; 05:6349  ; D#7
    audio_note $3C, $0F, $4                            ;; 05:634b  ; C#7
    audio_note $3C, $0F, $4                            ;; 05:634d  ; C#7
    audio_note $39, $0F, $4                            ;; 05:634f  ; A#6
    audio_note $39, $0F, $4                            ;; 05:6351  ; A#6
    audio_note $39, $0F, $6                            ;; 05:6353  ; A#6
    audio_note $39, $0F, $4                            ;; 05:6355  ; A#6
    audio_note $39, $0F, $4                            ;; 05:6357  ; A#6
    audio_note $38, $0F, $8                            ;; 05:6359  ; A6
    audio_note $3C, $0F, $4                            ;; 05:635b  ; C#7
    audio_note $3C, $0F, $2                            ;; 05:635d  ; C#7
    audio_note $3C, $0F, $2                            ;; 05:635f  ; C#7
    audio_note $40, $0F, $4                            ;; 05:6361  ; F7
    audio_note $40, $0F, $4                            ;; 05:6363  ; F7
    audio_note $3E, $0F, $4                            ;; 05:6365  ; D#7
    audio_note $3E, $0F, $4                            ;; 05:6367  ; D#7
    audio_note $3B, $0F, $6                            ;; 05:6369  ; C7
    audio_note $40, $0F, $4                            ;; 05:636b  ; F7
    audio_note $40, $0F, $2                            ;; 05:636d  ; F7
    audio_note $40, $0F, $2                            ;; 05:636f  ; F7
    audio_note $40, $0F, $4                            ;; 05:6371  ; F7
    audio_note $3E, $0F, $4                            ;; 05:6373  ; D#7
    audio_note $3C, $0F, $8                            ;; 05:6375  ; C#7
    audio_note $3B, $0F, $5                            ;; 05:6377  ; C7
    audio_note $39, $0F, $2                            ;; 05:6379  ; A#6
    audio_note $34, $0F, $4                            ;; 05:637b  ; F6
    audio_note $32, $0F, $4                            ;; 05:637d  ; D#6
    audio_note $34, $0F, $4                            ;; 05:637f  ; F6
    audio_note $34, $0F, $2                            ;; 05:6381  ; F6
    audio_note $34, $0F, $2                            ;; 05:6383  ; F6
    audio_note $34, $0F, $4                            ;; 05:6385  ; F6
    audio_note $39, $0F, $4                            ;; 05:6387  ; A#6
    audio_note $39, $0F, $4                            ;; 05:6389  ; A#6
    audio_note $39, $0F, $2                            ;; 05:638b  ; A#6
    audio_note $39, $0F, $2                            ;; 05:638d  ; A#6
    audio_note $39, $0F, $4                            ;; 05:638f  ; A#6
    audio_note $37, $0F, $4                            ;; 05:6391  ; G#6
    audio_note $34, $0F, $8                            ;; 05:6393  ; F6
    audio_end_pattern                                  ;; 05:6395

audio_05_6396_Pattern42:
; pattern $42
    audio_note $42, $08, $6                            ;; 05:6396  ; G7
    audio_note $40, $08, $6                            ;; 05:6398  ; F7
    audio_note $3E, $08, $6                            ;; 05:639a  ; D#7
    audio_note $3D, $08, $6                            ;; 05:639c  ; D7
    audio_note $3B, $08, $4                            ;; 05:639e  ; C7
    audio_note $3B, $08, $2                            ;; 05:63a0  ; C7
    audio_note $3B, $08, $2                            ;; 05:63a2  ; C7
    audio_note $3B, $08, $4                            ;; 05:63a4  ; C7
    audio_note $39, $08, $4                            ;; 05:63a6  ; A#6
    audio_note $3A, $08, $8                            ;; 05:63a8  ; B6
    audio_note $42, $08, $6                            ;; 05:63aa  ; G7
    audio_note $40, $08, $6                            ;; 05:63ac  ; F7
    audio_note $3E, $08, $6                            ;; 05:63ae  ; D#7
    audio_note $3D, $08, $6                            ;; 05:63b0  ; D7
    audio_note $3B, $08, $4                            ;; 05:63b2  ; C7
    audio_note $3B, $08, $2                            ;; 05:63b4  ; C7
    audio_note $3B, $08, $2                            ;; 05:63b6  ; C7
    audio_note $3B, $08, $4                            ;; 05:63b8  ; C7
    audio_note $39, $08, $4                            ;; 05:63ba  ; A#6
    audio_note $36, $08, $8                            ;; 05:63bc  ; G6
    audio_end_pattern                                  ;; 05:63be

audio_05_63bf_Pattern43:
; pattern $43
    audio_note $36, $08, $5                            ;; 05:63bf  ; G6
    audio_note $36, $08, $2                            ;; 05:63c1  ; G6
    audio_note $32, $08, $4                            ;; 05:63c3  ; D#6
    audio_note $31, $08, $4                            ;; 05:63c5  ; D6
    audio_note $32, $08, $6                            ;; 05:63c7  ; D#6
    audio_note $36, $08, $6                            ;; 05:63c9  ; G6
    audio_note $38, $08, $A                            ;; 05:63cb  ; A6
    audio_end_pattern                                  ;; 05:63cd

audio_05_63ce_Pattern44:
; pattern $44
    audio_note $35, $09, $2                            ;; 05:63ce  ; F#6
    audio_note $37, $09, $2                            ;; 05:63d0  ; G#6
    audio_note $35, $09, $2                            ;; 05:63d2  ; F#6
    audio_note $34, $09, $2                            ;; 05:63d4  ; F6
    audio_note $32, $09, $4                            ;; 05:63d6  ; D#6
    audio_note $30, $09, $4                            ;; 05:63d8  ; C#6
    audio_note $34, $09, $4                            ;; 05:63da  ; F6
    audio_note $39, $09, $4                            ;; 05:63dc  ; A#6
    audio_note $3C, $09, $2                            ;; 05:63de  ; C#7
    audio_note $3C, $09, $2                            ;; 05:63e0  ; C#7
    audio_note $3C, $09, $4                            ;; 05:63e2  ; C#7
    audio_note $35, $09, $2                            ;; 05:63e4  ; F#6
    audio_note $37, $09, $2                            ;; 05:63e6  ; G#6
    audio_note $35, $09, $2                            ;; 05:63e8  ; F#6
    audio_note $32, $09, $2                            ;; 05:63ea  ; D#6
    audio_note $35, $09, $4                            ;; 05:63ec  ; F#6
    audio_note $39, $09, $4                            ;; 05:63ee  ; A#6
    audio_note $3C, $09, $8                            ;; 05:63f0  ; C#7
    audio_note $35, $09, $2                            ;; 05:63f2  ; F#6
    audio_note $37, $09, $2                            ;; 05:63f4  ; G#6
    audio_note $35, $09, $2                            ;; 05:63f6  ; F#6
    audio_note $34, $09, $2                            ;; 05:63f8  ; F6
    audio_note $30, $09, $4                            ;; 05:63fa  ; C#6
    audio_note $2F, $09, $2                            ;; 05:63fc  ; C6
    audio_note $30, $09, $2                            ;; 05:63fe  ; C#6
    audio_note $39, $09, $4                            ;; 05:6400  ; A#6
    audio_note $34, $09, $4                            ;; 05:6402  ; F6
    audio_note $30, $09, $4                            ;; 05:6404  ; C#6
    audio_note $2D, $09, $4                            ;; 05:6406  ; A#5
    audio_note $34, $09, $2                            ;; 05:6408  ; F6
    audio_note $35, $09, $2                            ;; 05:640a  ; F#6
    audio_note $37, $09, $2                            ;; 05:640c  ; G#6
    audio_note $34, $09, $2                            ;; 05:640e  ; F6
    audio_note $34, $09, $4                            ;; 05:6410  ; F6
    audio_note $2F, $09, $4                            ;; 05:6412  ; C6
    audio_note $30, $09, $8                            ;; 05:6414  ; C#6
    audio_end_pattern                                  ;; 05:6416

audio_05_6417_Pattern39:
; pattern $39
    audio_note $2D, $12, $7                            ;; 05:6417  ; A#5
    audio_note $2B, $12, $4                            ;; 05:6419  ; G#5
    audio_note $28, $12, $6                            ;; 05:641b  ; F5
    audio_note $26, $12, $6                            ;; 05:641d  ; D#5
    audio_note $24, $12, $4                            ;; 05:641f  ; C#5
    audio_note $26, $12, $4                            ;; 05:6421  ; D#5
    audio_note $28, $12, $4                            ;; 05:6423  ; F5
    audio_note $24, $12, $4                            ;; 05:6425  ; C#5
    audio_note $21, $12, $6                            ;; 05:6427  ; A#4
    audio_note $1F, $12, $6                            ;; 05:6429  ; G#4
    audio_note $21, $12, $6                            ;; 05:642b  ; A#4
    audio_note $1F, $12, $6                            ;; 05:642d  ; G#4
    audio_note $21, $12, $6                            ;; 05:642f  ; A#4
    audio_note $24, $12, $6                            ;; 05:6431  ; C#5
    audio_note $1C, $12, $A                            ;; 05:6433  ; F4
    audio_end_pattern                                  ;; 05:6435

audio_05_6436_Pattern3A:
; pattern $3A
    audio_note $21, $12, $7                            ;; 05:6436  ; A#4
    audio_note $23, $12, $4                            ;; 05:6438  ; C5
    audio_note $24, $12, $6                            ;; 05:643a  ; C#5
    audio_note $28, $12, $6                            ;; 05:643c  ; F5
    audio_note $21, $12, $8                            ;; 05:643e  ; A#4
    audio_note $28, $12, $6                            ;; 05:6440  ; F5
    audio_note $2D, $12, $4                            ;; 05:6442  ; A#5
    audio_note $24, $12, $4                            ;; 05:6444  ; C#5
    audio_note $26, $12, $7                            ;; 05:6446  ; D#5
    audio_note $24, $12, $4                            ;; 05:6448  ; C#5
    audio_note $21, $12, $6                            ;; 05:644a  ; A#4
    audio_note $1D, $12, $6                            ;; 05:644c  ; F#4
    audio_note $1A, $12, $8                            ;; 05:644e  ; D#4
    audio_note $21, $12, $6                            ;; 05:6450  ; A#4
    audio_note $26, $12, $6                            ;; 05:6452  ; D#5
    audio_note $21, $12, $7                            ;; 05:6454  ; A#4
    audio_note $23, $12, $4                            ;; 05:6456  ; C5
    audio_note $24, $12, $6                            ;; 05:6458  ; C#5
    audio_note $28, $12, $6                            ;; 05:645a  ; F5
    audio_note $2D, $12, $8                            ;; 05:645c  ; A#5
    audio_note $2B, $12, $6                            ;; 05:645e  ; G#5
    audio_note $28, $12, $4                            ;; 05:6460  ; F5
    audio_note $24, $12, $4                            ;; 05:6462  ; C#5
    audio_note $26, $12, $7                            ;; 05:6464  ; D#5
    audio_note $24, $12, $4                            ;; 05:6466  ; C#5
    audio_note $21, $12, $6                            ;; 05:6468  ; A#4
    audio_note $1D, $12, $6                            ;; 05:646a  ; F#4
    audio_note $1A, $12, $7                            ;; 05:646c  ; D#4
    audio_note $1C, $12, $4                            ;; 05:646e  ; F4
    audio_note $1D, $12, $6                            ;; 05:6470  ; F#4
    audio_note $21, $12, $6                            ;; 05:6472  ; A#4
    audio_end_pattern                                  ;; 05:6474

audio_05_6475_Pattern3B:
; pattern $3B
    audio_note $21, $12, $7                            ;; 05:6475  ; A#4
    audio_note $1F, $12, $4                            ;; 05:6477  ; G#4
    audio_note $1C, $12, $6                            ;; 05:6479  ; F4
    audio_note $1F, $12, $6                            ;; 05:647b  ; G#4
    audio_note $21, $12, $7                            ;; 05:647d  ; A#4
    audio_note $1F, $12, $4                            ;; 05:647f  ; G#4
    audio_note $21, $12, $6                            ;; 05:6481  ; A#4
    audio_note $1C, $12, $6                            ;; 05:6483  ; F4
    audio_note $21, $12, $8                            ;; 05:6485  ; A#4
    audio_note $24, $12, $6                            ;; 05:6487  ; C#5
    audio_note $21, $12, $6                            ;; 05:6489  ; A#4
    audio_note $21, $12, $7                            ;; 05:648b  ; A#4
    audio_note $1F, $12, $4                            ;; 05:648d  ; G#4
    audio_note $1C, $12, $8                            ;; 05:648f  ; F4
    audio_note $21, $12, $8                            ;; 05:6491  ; A#4
    audio_note $26, $12, $8                            ;; 05:6493  ; D#5
    audio_note $28, $12, $A                            ;; 05:6495  ; F5
    audio_note $26, $12, $8                            ;; 05:6497  ; D#5
    audio_note $21, $12, $4                            ;; 05:6499  ; A#4
    audio_note $21, $12, $4                            ;; 05:649b  ; A#4
    audio_note $21, $12, $6                            ;; 05:649d  ; A#4
    audio_note $26, $12, $8                            ;; 05:649f  ; D#5
    audio_note $21, $12, $8                            ;; 05:64a1  ; A#4
    audio_end_pattern                                  ;; 05:64a3

audio_05_64a4_Pattern3C:
; pattern $3C
    audio_note $23, $11, $6                            ;; 05:64a4  ; C5
    audio_note $25, $11, $6                            ;; 05:64a6  ; D5
    audio_note $26, $11, $6                            ;; 05:64a8  ; D#5
    audio_note $2A, $11, $6                            ;; 05:64aa  ; G5
    audio_note $28, $11, $4                            ;; 05:64ac  ; F5
    audio_note $28, $11, $2                            ;; 05:64ae  ; F5
    audio_note $28, $11, $2                            ;; 05:64b0  ; F5
    audio_note $28, $11, $4                            ;; 05:64b2  ; F5
    audio_note $26, $11, $4                            ;; 05:64b4  ; D#5
    audio_note $2A, $11, $4                            ;; 05:64b6  ; G5
    audio_note $25, $11, $4                            ;; 05:64b8  ; D5
    audio_note $22, $11, $4                            ;; 05:64ba  ; B4
    audio_note $1E, $11, $4                            ;; 05:64bc  ; G4
    audio_note $23, $11, $6                            ;; 05:64be  ; C5
    audio_note $25, $11, $6                            ;; 05:64c0  ; D5
    audio_note $26, $11, $6                            ;; 05:64c2  ; D#5
    audio_note $2A, $11, $6                            ;; 05:64c4  ; G5
    audio_note $28, $11, $4                            ;; 05:64c6  ; F5
    audio_note $28, $11, $2                            ;; 05:64c8  ; F5
    audio_note $28, $11, $2                            ;; 05:64ca  ; F5
    audio_note $28, $11, $4                            ;; 05:64cc  ; F5
    audio_note $26, $11, $4                            ;; 05:64ce  ; D#5
    audio_note $23, $11, $4                            ;; 05:64d0  ; C5
    audio_note $21, $11, $4                            ;; 05:64d2  ; A#4
    audio_note $23, $11, $6                            ;; 05:64d4  ; C5
    audio_end_pattern                                  ;; 05:64d6

audio_05_64d7_Pattern3D:
; pattern $3D
    audio_note $23, $11, $5                            ;; 05:64d7  ; C5
    audio_note $23, $11, $2                            ;; 05:64d9  ; C5
    audio_note $23, $11, $4                            ;; 05:64db  ; C5
    audio_note $21, $11, $4                            ;; 05:64dd  ; A#4
    audio_note $1E, $11, $4                            ;; 05:64df  ; G4
    audio_note $21, $11, $4                            ;; 05:64e1  ; A#4
    audio_note $23, $11, $4                            ;; 05:64e3  ; C5
    audio_note $26, $11, $4                            ;; 05:64e5  ; D#5
    audio_note $28, $11, $6                            ;; 05:64e7  ; F5
    audio_note $28, $11, $4                            ;; 05:64e9  ; F5
    audio_note $28, $11, $2                            ;; 05:64eb  ; F5
    audio_note $28, $11, $2                            ;; 05:64ed  ; F5
    audio_note $28, $11, $4                            ;; 05:64ef  ; F5
    audio_note $28, $11, $2                            ;; 05:64f1  ; F5
    audio_note $28, $11, $2                            ;; 05:64f3  ; F5
    audio_note $28, $11, $4                            ;; 05:64f5  ; F5
    audio_note $28, $11, $4                            ;; 05:64f7  ; F5
    audio_end_pattern                                  ;; 05:64f9

audio_05_64fa_Pattern3E:
; pattern $3E
    audio_note $26, $12, $8                            ;; 05:64fa  ; D#5
    audio_note $24, $12, $4                            ;; 05:64fc  ; C#5
    audio_note $24, $12, $4                            ;; 05:64fe  ; C#5
    audio_note $24, $12, $6                            ;; 05:6500  ; C#5
    audio_note $23, $12, $7                            ;; 05:6502  ; C5
    audio_note $23, $12, $4                            ;; 05:6504  ; C5
    audio_note $21, $12, $4                            ;; 05:6506  ; A#4
    audio_note $21, $12, $4                            ;; 05:6508  ; A#4
    audio_note $21, $12, $6                            ;; 05:650a  ; A#4
    audio_note $26, $12, $8                            ;; 05:650c  ; D#5
    audio_note $24, $12, $8                            ;; 05:650e  ; C#5
    audio_note $1C, $12, $7                            ;; 05:6510  ; F4
    audio_note $23, $12, $4                            ;; 05:6512  ; C5
    audio_note $21, $12, $8                            ;; 05:6514  ; A#4
    audio_end_pattern                                  ;; 05:6516

audio_05_6517_Pattern38:
; pattern $38
    audio_note $18, $01, $4                            ;; 05:6517  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6519  ; G4
    audio_note $1E, $03, $2                            ;; 05:651b  ; G4
    audio_note $1E, $03, $4                            ;; 05:651d  ; G4
    audio_note $1E, $03, $4                            ;; 05:651f  ; G4
    audio_note $1A, $02, $6                            ;; 05:6521  ; D#4
    audio_note $1A, $02, $6                            ;; 05:6523  ; D#4
    audio_note $18, $01, $4                            ;; 05:6525  ; C#4
    audio_note $18, $01, $4                            ;; 05:6527  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6529  ; G4
    audio_note $1E, $03, $2                            ;; 05:652b  ; G4
    audio_note $1E, $03, $2                            ;; 05:652d  ; G4
    audio_note $1E, $03, $2                            ;; 05:652f  ; G4
    audio_note $1A, $02, $4                            ;; 05:6531  ; D#4
    audio_note $1A, $02, $2                            ;; 05:6533  ; D#4
    audio_note $1A, $02, $2                            ;; 05:6535  ; D#4
    audio_note $1A, $02, $4                            ;; 05:6537  ; D#4
    audio_note $1A, $02, $4                            ;; 05:6539  ; D#4
    audio_end_pattern                                  ;; 05:653b

audio_05_653c_Song_GameOverOrTimeUp_Ch1:
; SONG_GAME_OVER_OR_TIME_UP (song $15) channel 1
    audio_panning $FF                                  ;; 05:653c
    audio_tempo $C4                                    ;; 05:653e
    audio_call $4B, $EF, 1                             ;; 05:6540
    audio_note $24, $00, $0                            ;; 05:6544  ; C#5
    audio_marker $01                                   ;; 05:6546
    audio_end                                          ;; 05:6548

audio_05_6549_Song_GameOverOrTimeUp_Ch2:
; SONG_GAME_OVER_OR_TIME_UP (song $15) channel 2
    audio_call $4C, $EF, 1                             ;; 05:6549
    audio_note $24, $00, $0                            ;; 05:654d  ; C#5
    audio_end                                          ;; 05:654f

audio_05_6550_Song_GameOverOrTimeUp_Ch3:
; SONG_GAME_OVER_OR_TIME_UP (song $15) channel 3
    audio_call $4D, $FB, 1                             ;; 05:6550
    audio_note $24, $00, $0                            ;; 05:6554  ; C#5
    audio_end                                          ;; 05:6556

audio_05_6557_Song_GameOverOrTimeUp_Ch4:
; SONG_GAME_OVER_OR_TIME_UP (song $15) channel 4
    audio_note $24, $00, $0                            ;; 05:6557  ; C#5
    audio_end                                          ;; 05:6559

audio_05_655a_Pattern4B:
; pattern $4B
    audio_note $54, $08, $2                            ;; 05:655a  ; C#9
    audio_note $52, $08, $2                            ;; 05:655c  ; B8
    audio_note $50, $08, $2                            ;; 05:655e  ; A8
    audio_note $4E, $08, $2                            ;; 05:6560  ; G8
    audio_note $4C, $08, $2                            ;; 05:6562  ; F8
    audio_note $4A, $08, $2                            ;; 05:6564  ; D#8
    audio_note $48, $08, $2                            ;; 05:6566  ; C#8
    audio_note $46, $08, $2                            ;; 05:6568  ; B7
    audio_note $44, $08, $2                            ;; 05:656a  ; A7
    audio_note $42, $08, $2                            ;; 05:656c  ; G7
    audio_note $40, $08, $2                            ;; 05:656e  ; F7
    audio_note $3E, $08, $2                            ;; 05:6570  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6572  ; C#7
    audio_note $3A, $08, $2                            ;; 05:6574  ; B6
    audio_note $38, $08, $2                            ;; 05:6576  ; A6
    audio_note $36, $08, $2                            ;; 05:6578  ; G6
    audio_note $34, $08, $2                            ;; 05:657a  ; F6
    audio_note $32, $08, $2                            ;; 05:657c  ; D#6
    audio_note $30, $08, $2                            ;; 05:657e  ; C#6
    audio_note $2E, $08, $2                            ;; 05:6580  ; B5
    audio_note $2C, $08, $2                            ;; 05:6582  ; A5
    audio_note $2A, $08, $2                            ;; 05:6584  ; G5
    audio_note $28, $08, $2                            ;; 05:6586  ; F5
    audio_note $26, $08, $2                            ;; 05:6588  ; D#5
    audio_note $24, $08, $4                            ;; 05:658a  ; C#5
    audio_note $27, $08, $2                            ;; 05:658c  ; E5
    audio_note $2E, $08, $2                            ;; 05:658e  ; B5
    audio_note $2D, $08, $D                            ;; 05:6590  ; A#5
    audio_note $33, $08, $D                            ;; 05:6592  ; E6
    audio_note $30, $08, $D                            ;; 05:6594  ; C#6
    audio_note $36, $08, $D                            ;; 05:6596  ; G6
    audio_note $33, $08, $D                            ;; 05:6598  ; E6
    audio_note $39, $08, $D                            ;; 05:659a  ; A#6
    audio_note $36, $08, $4                            ;; 05:659c  ; G6
    audio_note $3C, $08, $1                            ;; 05:659e  ; C#7
    audio_note $39, $08, $1                            ;; 05:65a0  ; A#6
    audio_note $3C, $08, $D                            ;; 05:65a2  ; C#7
    audio_note $3F, $08, $1                            ;; 05:65a4  ; E7
    audio_note $3C, $08, $1                            ;; 05:65a6  ; C#7
    audio_note $3F, $08, $2                            ;; 05:65a8  ; E7
    audio_note $42, $08, $2                            ;; 05:65aa  ; G7
    audio_note $3F, $08, $2                            ;; 05:65ac  ; E7
    audio_note $42, $08, $6                            ;; 05:65ae  ; G7
    audio_end_pattern                                  ;; 05:65b0

audio_05_65b1_Pattern4C:
; pattern $4C
    audio_note $4C, $08, $D                            ;; 05:65b1  ; F8
    audio_note $48, $08, $D                            ;; 05:65b3  ; C#8
    audio_note $4A, $08, $D                            ;; 05:65b5  ; D#8
    audio_note $46, $08, $D                            ;; 05:65b7  ; B7
    audio_note $48, $08, $D                            ;; 05:65b9  ; C#8
    audio_note $44, $08, $D                            ;; 05:65bb  ; A7
    audio_note $46, $08, $D                            ;; 05:65bd  ; B7
    audio_note $42, $08, $D                            ;; 05:65bf  ; G7
    audio_note $44, $08, $D                            ;; 05:65c1  ; A7
    audio_note $40, $08, $D                            ;; 05:65c3  ; F7
    audio_note $42, $08, $D                            ;; 05:65c5  ; G7
    audio_note $3E, $08, $D                            ;; 05:65c7  ; D#7
    audio_note $40, $08, $D                            ;; 05:65c9  ; F7
    audio_note $3C, $08, $D                            ;; 05:65cb  ; C#7
    audio_note $3E, $08, $D                            ;; 05:65cd  ; D#7
    audio_note $3A, $08, $D                            ;; 05:65cf  ; B6
    audio_note $3C, $08, $D                            ;; 05:65d1  ; C#7
    audio_note $38, $08, $6                            ;; 05:65d3  ; A6
    audio_note $24, $08, $D                            ;; 05:65d5  ; C#5
    audio_note $27, $08, $D                            ;; 05:65d7  ; E5
    audio_note $2E, $08, $D                            ;; 05:65d9  ; B5
    audio_note $2D, $08, $D                            ;; 05:65db  ; A#5
    audio_note $33, $08, $D                            ;; 05:65dd  ; E6
    audio_note $30, $08, $D                            ;; 05:65df  ; C#6
    audio_note $36, $08, $1                            ;; 05:65e1  ; G6
    audio_note $33, $08, $D                            ;; 05:65e3  ; E6
    audio_note $36, $08, $1                            ;; 05:65e5  ; G6
    audio_note $39, $08, $1                            ;; 05:65e7  ; A#6
    audio_note $36, $08, $2                            ;; 05:65e9  ; G6
    audio_note $39, $08, $2                            ;; 05:65eb  ; A#6
    audio_note $3C, $08, $2                            ;; 05:65ed  ; C#7
    audio_note $39, $08, $2                            ;; 05:65ef  ; A#6
    audio_note $3C, $08, $2                            ;; 05:65f1  ; C#7
    audio_note $3F, $08, $2                            ;; 05:65f3  ; E7
    audio_note $3C, $08, $2                            ;; 05:65f5  ; C#7
    audio_note $3F, $08, $2                            ;; 05:65f7  ; E7
    audio_note $42, $08, $2                            ;; 05:65f9  ; G7
    audio_note $3F, $08, $2                            ;; 05:65fb  ; E7
    audio_note $42, $08, $2                            ;; 05:65fd  ; G7
    audio_note $42, $08, $2                            ;; 05:65ff  ; G7
    audio_note $3F, $08, $2                            ;; 05:6601  ; E7
    audio_note $42, $08, $6                            ;; 05:6603  ; G7
    audio_end_pattern                                  ;; 05:6605

audio_05_6606_Pattern4D:
; pattern $4D
    audio_note $18, $12, $B                            ;; 05:6606  ; C#4
    audio_note $18, $12, $C                            ;; 05:6608  ; C#4
    audio_end_pattern                                  ;; 05:660a

audio_05_660b_Song_BonusChannel_Ch1:
; SONG_BONUS_CHANNEL (song $16) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:660b
    audio_tempo $CD                                    ;; 05:660d
    audio_call $00, $00, 4                             ;; 05:660f
    audio_call $55, $E3, 1                             ;; 05:6613
    audio_call $56, $E3, 1                             ;; 05:6617
    audio_marker $01                                   ;; 05:661b
    audio_goto audio_05_660b_Song_BonusChannel_Ch1     ;; 05:661d

audio_05_6620_Song_BonusChannel_Ch2:
; SONG_BONUS_CHANNEL (song $16) channel 2
; AUDIO_CMD_GOTO target
    audio_call $52, $E3, 4                             ;; 05:6620
    audio_call $52, $E8, 2                             ;; 05:6624
    audio_call $52, $E3, 1                             ;; 05:6628
    audio_call $52, $EA, 1                             ;; 05:662c
    audio_call $52, $E8, 1                             ;; 05:6630
    audio_call $52, $E3, 1                             ;; 05:6634
    audio_call $53, $E3, 3                             ;; 05:6638
    audio_call $54, $E3, 1                             ;; 05:663c
    audio_call $52, $E3, 4                             ;; 05:6640
    audio_goto audio_05_6620_Song_BonusChannel_Ch2     ;; 05:6644

audio_05_6647_Song_BonusChannel_Ch3:
; SONG_BONUS_CHANNEL (song $16) channel 3
; AUDIO_CMD_GOTO target
    audio_call $4F, $EF, 4                             ;; 05:6647
    audio_call $4F, $F4, 2                             ;; 05:664b
    audio_call $4F, $EF, 1                             ;; 05:664f
    audio_call $4F, $F6, 1                             ;; 05:6653
    audio_call $4F, $F4, 1                             ;; 05:6657
    audio_call $4F, $EF, 1                             ;; 05:665b
    audio_call $50, $EF, 3                             ;; 05:665f
    audio_call $51, $EF, 1                             ;; 05:6663
    audio_call $4F, $EF, 4                             ;; 05:6667
    audio_goto audio_05_6647_Song_BonusChannel_Ch3     ;; 05:666b

audio_05_666e_Song_BonusChannel_Ch4:
; SONG_BONUS_CHANNEL (song $16) channel 4
; AUDIO_CMD_GOTO target
    audio_call $4E, $00, 16                            ;; 05:666e
    audio_goto audio_05_666e_Song_BonusChannel_Ch4     ;; 05:6672

audio_05_6675_Pattern55:
; pattern $55
    audio_note $43, $09, $4                            ;; 05:6675  ; G#7
    audio_note $46, $09, $4                            ;; 05:6677  ; B7
    audio_note $4A, $09, $4                            ;; 05:6679  ; D#8
    audio_note $4B, $09, $2                            ;; 05:667b  ; E8
    audio_note $4A, $09, $6                            ;; 05:667d  ; D#8
    audio_note $48, $09, $5                            ;; 05:667f  ; C#8
    audio_note $46, $09, $4                            ;; 05:6681  ; B7
    audio_note $48, $09, $6                            ;; 05:6683  ; C#8
    audio_note $46, $09, $4                            ;; 05:6685  ; B7
    audio_note $45, $09, $4                            ;; 05:6687  ; A#7
    audio_note $46, $09, $6                            ;; 05:6689  ; B7
    audio_note $42, $09, $6                            ;; 05:668b  ; G7
    audio_note $43, $09, $6                            ;; 05:668d  ; G#7
    audio_note $46, $09, $4                            ;; 05:668f  ; B7
    audio_note $4A, $09, $2                            ;; 05:6691  ; D#8
    audio_note $4B, $09, $6                            ;; 05:6693  ; E8
    audio_note $4A, $09, $5                            ;; 05:6695  ; D#8
    audio_note $48, $09, $4                            ;; 05:6697  ; C#8
    audio_note $4A, $09, $A                            ;; 05:6699  ; D#8
    audio_note $4F, $09, $6                            ;; 05:669b  ; G#8
    audio_note $4D, $09, $5                            ;; 05:669d  ; F#8
    audio_note $4B, $09, $5                            ;; 05:669f  ; E8
    audio_note $4A, $09, $4                            ;; 05:66a1  ; D#8
    audio_note $48, $09, $4                            ;; 05:66a3  ; C#8
    audio_note $47, $09, $4                            ;; 05:66a5  ; C8
    audio_note $48, $09, $4                            ;; 05:66a7  ; C#8
    audio_note $43, $09, $4                            ;; 05:66a9  ; G#7
    audio_note $44, $09, $4                            ;; 05:66ab  ; A7
    audio_note $41, $09, $2                            ;; 05:66ad  ; F#7
    audio_note $43, $09, $5                            ;; 05:66af  ; G#7
    audio_note $3F, $09, $4                            ;; 05:66b1  ; E7
    audio_note $41, $09, $4                            ;; 05:66b3  ; F#7
    audio_note $3E, $09, $4                            ;; 05:66b5  ; D#7
    audio_note $3F, $09, $4                            ;; 05:66b7  ; E7
    audio_note $3E, $09, $4                            ;; 05:66b9  ; D#7
    audio_note $3C, $09, $4                            ;; 05:66bb  ; C#7
    audio_note $3E, $09, $2                            ;; 05:66bd  ; D#7
    audio_note $3F, $09, $5                            ;; 05:66bf  ; E7
    audio_note $3E, $09, $4                            ;; 05:66c1  ; D#7
    audio_note $3C, $09, $4                            ;; 05:66c3  ; C#7
    audio_note $3F, $09, $4                            ;; 05:66c5  ; E7
    audio_note $3E, $09, $6                            ;; 05:66c7  ; D#7
    audio_note $3F, $09, $5                            ;; 05:66c9  ; E7
    audio_note $3C, $09, $8                            ;; 05:66cb  ; C#7
    audio_note $24, $00, $2                            ;; 05:66cd  ; C#5
    audio_note $37, $09, $2                            ;; 05:66cf  ; G#6
    audio_note $39, $09, $2                            ;; 05:66d1  ; A#6
    audio_note $3A, $09, $4                            ;; 05:66d3  ; B6
    audio_note $3E, $09, $4                            ;; 05:66d5  ; D#7
    audio_note $43, $09, $2                            ;; 05:66d7  ; G#7
    audio_note $45, $09, $4                            ;; 05:66d9  ; A#7
    audio_note $46, $09, $2                            ;; 05:66db  ; B7
    audio_note $45, $09, $4                            ;; 05:66dd  ; A#7
    audio_note $43, $09, $4                            ;; 05:66df  ; G#7
    audio_note $46, $09, $4                            ;; 05:66e1  ; B7
    audio_note $45, $09, $6                            ;; 05:66e3  ; A#7
    audio_note $43, $09, $5                            ;; 05:66e5  ; G#7
    audio_note $45, $09, $2                            ;; 05:66e7  ; A#7
    audio_note $46, $09, $6                            ;; 05:66e9  ; B7
    audio_note $43, $09, $6                            ;; 05:66eb  ; G#7
    audio_note $4A, $09, $7                            ;; 05:66ed  ; D#8
    audio_note $4B, $09, $2                            ;; 05:66ef  ; E8
    audio_note $4A, $09, $5                            ;; 05:66f1  ; D#8
    audio_note $48, $09, $4                            ;; 05:66f3  ; C#8
    audio_note $4A, $09, $4                            ;; 05:66f5  ; D#8
    audio_note $4B, $09, $4                            ;; 05:66f7  ; E8
    audio_note $4A, $09, $6                            ;; 05:66f9  ; D#8
    audio_note $48, $09, $4                            ;; 05:66fb  ; C#8
    audio_note $4A, $09, $8                            ;; 05:66fd  ; D#8
    audio_note $01, $09, $4                            ;; 05:66ff  ; D2
    audio_note $48, $09, $4                            ;; 05:6701  ; C#8
    audio_note $43, $09, $4                            ;; 05:6703  ; G#7
    audio_note $48, $09, $4                            ;; 05:6705  ; C#8
    audio_note $4A, $09, $2                            ;; 05:6707  ; D#8
    audio_note $4B, $09, $7                            ;; 05:6709  ; E8
    audio_note $24, $00, $2                            ;; 05:670b  ; C#5
    audio_note $4E, $09, $4                            ;; 05:670d  ; G8
    audio_note $4F, $09, $4                            ;; 05:670f  ; G#8
    audio_note $4B, $09, $4                            ;; 05:6711  ; E8
    audio_note $4A, $09, $4                            ;; 05:6713  ; D#8
    audio_note $48, $09, $2                            ;; 05:6715  ; C#8
    audio_note $4B, $09, $5                            ;; 05:6717  ; E8
    audio_note $4A, $09, $4                            ;; 05:6719  ; D#8
    audio_note $48, $09, $6                            ;; 05:671b  ; C#8
    audio_note $46, $09, $6                            ;; 05:671d  ; B7
    audio_note $45, $09, $4                            ;; 05:671f  ; A#7
    audio_note $46, $09, $4                            ;; 05:6721  ; B7
    audio_note $43, $09, $7                            ;; 05:6723  ; G#7
    audio_note $45, $09, $4                            ;; 05:6725  ; A#7
    audio_note $46, $09, $6                            ;; 05:6727  ; B7
    audio_note $48, $09, $4                            ;; 05:6729  ; C#8
    audio_note $46, $09, $4                            ;; 05:672b  ; B7
    audio_note $48, $09, $6                            ;; 05:672d  ; C#8
    audio_note $46, $09, $4                            ;; 05:672f  ; B7
    audio_note $45, $09, $4                            ;; 05:6731  ; A#7
    audio_note $4A, $09, $7                            ;; 05:6733  ; D#8
    audio_note $4D, $09, $4                            ;; 05:6735  ; F#8
    audio_note $51, $09, $6                            ;; 05:6737  ; A#8
    audio_note $4D, $09, $4                            ;; 05:6739  ; F#8
    audio_note $51, $09, $4                            ;; 05:673b  ; A#8
    audio_note $4A, $09, $6                            ;; 05:673d  ; D#8
    audio_note $4D, $09, $5                            ;; 05:673f  ; F#8
    audio_note $51, $09, $5                            ;; 05:6741  ; A#8
    audio_note $4D, $09, $4                            ;; 05:6743  ; F#8
    audio_note $4A, $09, $4                            ;; 05:6745  ; D#8
    audio_note $4D, $09, $4                            ;; 05:6747  ; F#8
    audio_note $4A, $09, $6                            ;; 05:6749  ; D#8
    audio_note $4D, $09, $5                            ;; 05:674b  ; F#8
    audio_note $51, $09, $5                            ;; 05:674d  ; A#8
    audio_note $4D, $09, $4                            ;; 05:674f  ; F#8
    audio_note $4A, $09, $4                            ;; 05:6751  ; D#8
    audio_note $4D, $09, $4                            ;; 05:6753  ; F#8
    audio_note $4A, $09, $8                            ;; 05:6755  ; D#8
    audio_note $48, $09, $6                            ;; 05:6757  ; C#8
    audio_note $46, $09, $4                            ;; 05:6759  ; B7
    audio_note $45, $09, $4                            ;; 05:675b  ; A#7
    audio_end_pattern                                  ;; 05:675d

audio_05_675e_Pattern56:
; pattern $56
    audio_note $37, $09, $6                            ;; 05:675e  ; G#6
    audio_note $3E, $09, $6                            ;; 05:6760  ; D#7
    audio_note $43, $09, $6                            ;; 05:6762  ; G#7
    audio_note $3E, $09, $6                            ;; 05:6764  ; D#7
    audio_note $38, $09, $6                            ;; 05:6766  ; A6
    audio_note $3F, $09, $6                            ;; 05:6768  ; E7
    audio_note $44, $09, $6                            ;; 05:676a  ; A7
    audio_note $3F, $09, $6                            ;; 05:676c  ; E7
    audio_note $37, $09, $6                            ;; 05:676e  ; G#6
    audio_note $3E, $09, $6                            ;; 05:6770  ; D#7
    audio_note $43, $09, $6                            ;; 05:6772  ; G#7
    audio_note $3E, $09, $4                            ;; 05:6774  ; D#7
    audio_note $37, $09, $4                            ;; 05:6776  ; G#6
    audio_note $38, $09, $6                            ;; 05:6778  ; A6
    audio_note $3F, $09, $6                            ;; 05:677a  ; E7
    audio_note $44, $09, $4                            ;; 05:677c  ; A7
    audio_note $3F, $09, $4                            ;; 05:677e  ; E7
    audio_note $38, $09, $4                            ;; 05:6780  ; A6
    audio_note $3F, $09, $4                            ;; 05:6782  ; E7
    audio_note $37, $09, $6                            ;; 05:6784  ; G#6
    audio_note $3E, $09, $6                            ;; 05:6786  ; D#7
    audio_note $43, $09, $6                            ;; 05:6788  ; G#7
    audio_note $3E, $09, $6                            ;; 05:678a  ; D#7
    audio_note $38, $09, $6                            ;; 05:678c  ; A6
    audio_note $3F, $09, $6                            ;; 05:678e  ; E7
    audio_note $44, $09, $6                            ;; 05:6790  ; A7
    audio_note $3F, $09, $6                            ;; 05:6792  ; E7
    audio_note $37, $09, $C                            ;; 05:6794  ; G#6
    audio_end_pattern                                  ;; 05:6796

audio_05_6797_Pattern52:
; pattern $52
    audio_note $37, $0D, $2                            ;; 05:6797  ; G#6
    audio_note $38, $0D, $2                            ;; 05:6799  ; A6
    audio_note $39, $0D, $2                            ;; 05:679b  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:679d  ; B6
    audio_note $3B, $0D, $2                            ;; 05:679f  ; C7
    audio_note $3A, $0D, $2                            ;; 05:67a1  ; B6
    audio_note $39, $0D, $2                            ;; 05:67a3  ; A#6
    audio_note $38, $0D, $2                            ;; 05:67a5  ; A6
    audio_note $37, $0D, $2                            ;; 05:67a7  ; G#6
    audio_note $38, $0D, $2                            ;; 05:67a9  ; A6
    audio_note $39, $0D, $2                            ;; 05:67ab  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:67ad  ; B6
    audio_note $3B, $0D, $2                            ;; 05:67af  ; C7
    audio_note $3A, $0D, $2                            ;; 05:67b1  ; B6
    audio_note $39, $0D, $2                            ;; 05:67b3  ; A#6
    audio_note $38, $0D, $2                            ;; 05:67b5  ; A6
    audio_note $37, $0D, $2                            ;; 05:67b7  ; G#6
    audio_note $38, $0D, $2                            ;; 05:67b9  ; A6
    audio_note $39, $0D, $2                            ;; 05:67bb  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:67bd  ; B6
    audio_note $3B, $0D, $2                            ;; 05:67bf  ; C7
    audio_note $3A, $0D, $2                            ;; 05:67c1  ; B6
    audio_note $39, $0D, $2                            ;; 05:67c3  ; A#6
    audio_note $38, $0D, $2                            ;; 05:67c5  ; A6
    audio_note $37, $0D, $2                            ;; 05:67c7  ; G#6
    audio_note $38, $0D, $2                            ;; 05:67c9  ; A6
    audio_note $39, $0D, $2                            ;; 05:67cb  ; A#6
    audio_note $3A, $0D, $2                            ;; 05:67cd  ; B6
    audio_note $3B, $0D, $2                            ;; 05:67cf  ; C7
    audio_note $3A, $0D, $2                            ;; 05:67d1  ; B6
    audio_note $39, $0D, $2                            ;; 05:67d3  ; A#6
    audio_note $38, $0D, $2                            ;; 05:67d5  ; A6
    audio_end_pattern                                  ;; 05:67d7

audio_05_67d8_Pattern53:
; pattern $53
    audio_note $2D, $08, $2                            ;; 05:67d8  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67da  ; A#5
    audio_note $2D, $08, $2                            ;; 05:67dc  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67de  ; A#5
    audio_note $2D, $08, $2                            ;; 05:67e0  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67e2  ; A#5
    audio_note $2D, $08, $2                            ;; 05:67e4  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67e6  ; A#5
    audio_note $2B, $08, $4                            ;; 05:67e8  ; G#5
    audio_note $2C, $08, $4                            ;; 05:67ea  ; A5
    audio_end_pattern                                  ;; 05:67ec

audio_05_67ed_Pattern54:
; pattern $54
    audio_note $2D, $08, $2                            ;; 05:67ed  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67ef  ; A#5
    audio_note $2D, $08, $2                            ;; 05:67f1  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67f3  ; A#5
    audio_note $2D, $08, $2                            ;; 05:67f5  ; A#5
    audio_note $2D, $08, $4                            ;; 05:67f7  ; A#5
    audio_note $24, $08, $2                            ;; 05:67f9  ; C#5
    audio_note $26, $08, $2                            ;; 05:67fb  ; D#5
    audio_note $24, $08, $2                            ;; 05:67fd  ; C#5
    audio_note $26, $08, $2                            ;; 05:67ff  ; D#5
    audio_note $24, $08, $2                            ;; 05:6801  ; C#5
    audio_note $21, $08, $2                            ;; 05:6803  ; A#4
    audio_note $1D, $08, $2                            ;; 05:6805  ; F#4
    audio_end_pattern                                  ;; 05:6807

audio_05_6808_Pattern4F:
; pattern $4F
    audio_note $1F, $11, $4                            ;; 05:6808  ; G#4
    audio_note $1F, $11, $4                            ;; 05:680a  ; G#4
    audio_note $1F, $11, $2                            ;; 05:680c  ; G#4
    audio_note $1D, $11, $2                            ;; 05:680e  ; F#4
    audio_note $1A, $11, $2                            ;; 05:6810  ; D#4
    audio_note $1F, $11, $4                            ;; 05:6812  ; G#4
    audio_note $1F, $11, $4                            ;; 05:6814  ; G#4
    audio_note $1F, $11, $2                            ;; 05:6816  ; G#4
    audio_note $1F, $11, $2                            ;; 05:6818  ; G#4
    audio_note $1D, $11, $2                            ;; 05:681a  ; F#4
    audio_note $1A, $11, $4                            ;; 05:681c  ; D#4
    audio_note $1F, $11, $4                            ;; 05:681e  ; G#4
    audio_note $1F, $11, $4                            ;; 05:6820  ; G#4
    audio_note $1F, $11, $2                            ;; 05:6822  ; G#4
    audio_note $1D, $11, $2                            ;; 05:6824  ; F#4
    audio_note $1A, $11, $2                            ;; 05:6826  ; D#4
    audio_note $1F, $11, $4                            ;; 05:6828  ; G#4
    audio_note $1F, $11, $4                            ;; 05:682a  ; G#4
    audio_note $1F, $11, $2                            ;; 05:682c  ; G#4
    audio_note $22, $11, $4                            ;; 05:682e  ; B4
    audio_note $1F, $11, $4                            ;; 05:6830  ; G#4
    audio_end_pattern                                  ;; 05:6832

audio_05_6833_Pattern50:
; pattern $50
    audio_note $26, $11, $2                            ;; 05:6833  ; D#5
    audio_note $26, $11, $4                            ;; 05:6835  ; D#5
    audio_note $26, $11, $2                            ;; 05:6837  ; D#5
    audio_note $26, $11, $4                            ;; 05:6839  ; D#5
    audio_note $26, $11, $2                            ;; 05:683b  ; D#5
    audio_note $26, $11, $4                            ;; 05:683d  ; D#5
    audio_note $26, $11, $2                            ;; 05:683f  ; D#5
    audio_note $26, $11, $4                            ;; 05:6841  ; D#5
    audio_note $24, $11, $4                            ;; 05:6843  ; C#5
    audio_note $25, $11, $4                            ;; 05:6845  ; D5
    audio_end_pattern                                  ;; 05:6847

audio_05_6848_Pattern51:
; pattern $51
    audio_note $26, $11, $2                            ;; 05:6848  ; D#5
    audio_note $26, $11, $4                            ;; 05:684a  ; D#5
    audio_note $26, $11, $2                            ;; 05:684c  ; D#5
    audio_note $26, $11, $4                            ;; 05:684e  ; D#5
    audio_note $26, $11, $2                            ;; 05:6850  ; D#5
    audio_note $26, $11, $4                            ;; 05:6852  ; D#5
    audio_note $24, $11, $2                            ;; 05:6854  ; C#5
    audio_note $26, $11, $2                            ;; 05:6856  ; D#5
    audio_note $24, $11, $2                            ;; 05:6858  ; C#5
    audio_note $26, $11, $2                            ;; 05:685a  ; D#5
    audio_note $24, $11, $2                            ;; 05:685c  ; C#5
    audio_note $21, $11, $2                            ;; 05:685e  ; A#4
    audio_note $1D, $11, $2                            ;; 05:6860  ; F#4
    audio_end_pattern                                  ;; 05:6862

audio_05_6863_Pattern4E:
; pattern $4E
    audio_note $18, $01, $2                            ;; 05:6863  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6865  ; G4
    audio_note $18, $01, $2                            ;; 05:6867  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6869  ; G4
    audio_note $1A, $02, $2                            ;; 05:686b  ; D#4
    audio_note $22, $06, $4                            ;; 05:686d  ; B4
    audio_note $18, $01, $2                            ;; 05:686f  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6871  ; G4
    audio_note $18, $01, $2                            ;; 05:6873  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6875  ; G4
    audio_note $18, $01, $2                            ;; 05:6877  ; C#4
    audio_note $1A, $02, $2                            ;; 05:6879  ; D#4
    audio_note $1E, $03, $2                            ;; 05:687b  ; G4
    audio_note $18, $01, $2                            ;; 05:687d  ; C#4
    audio_note $1E, $03, $2                            ;; 05:687f  ; G4
    audio_note $18, $01, $2                            ;; 05:6881  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6883  ; G4
    audio_note $18, $01, $2                            ;; 05:6885  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6887  ; G4
    audio_note $1A, $02, $2                            ;; 05:6889  ; D#4
    audio_note $1E, $03, $2                            ;; 05:688b  ; G4
    audio_note $18, $01, $2                            ;; 05:688d  ; C#4
    audio_note $18, $01, $2                            ;; 05:688f  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6891  ; G4
    audio_note $18, $01, $2                            ;; 05:6893  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6895  ; G4
    audio_note $18, $01, $2                            ;; 05:6897  ; C#4
    audio_note $1A, $02, $2                            ;; 05:6899  ; D#4
    audio_note $18, $01, $2                            ;; 05:689b  ; C#4
    audio_note $1A, $02, $2                            ;; 05:689d  ; D#4
    audio_note $22, $06, $2                            ;; 05:689f  ; B4
    audio_end_pattern                                  ;; 05:68a1

audio_05_68a2_Song_SuperheroShow_Ch1:
; SONG_SUPERHERO_SHOW (song $17) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:68a2
    audio_tempo $C8                                    ;; 05:68a4
    audio_call $00, $00, 9                             ;; 05:68a6
    audio_call $5C, $E4, 1                             ;; 05:68aa
    audio_call $5C, $E9, 1                             ;; 05:68ae
    audio_call $5C, $E4, 1                             ;; 05:68b2
    audio_call $5D, $E4, 1                             ;; 05:68b6
    audio_call $5E, $F0, 2                             ;; 05:68ba
    audio_call $5F, $F0, 1                             ;; 05:68be
    audio_call $60, $F0, 2                             ;; 05:68c2
    audio_note $24, $00, $A                            ;; 05:68c6  ; C#5
    audio_call $5C, $E4, 1                             ;; 05:68c8
    audio_call $5C, $E9, 1                             ;; 05:68cc
    audio_call $5C, $E4, 1                             ;; 05:68d0
    audio_call $5D, $E4, 1                             ;; 05:68d4
    audio_call $5E, $F0, 2                             ;; 05:68d8
    audio_call $61, $F0, 1                             ;; 05:68dc
    audio_marker $01                                   ;; 05:68e0
    audio_goto audio_05_68a2_Song_SuperheroShow_Ch1    ;; 05:68e2

audio_05_68e5_Song_SuperheroShow_Ch2:
; SONG_SUPERHERO_SHOW (song $17) channel 2
; AUDIO_CMD_GOTO target
    audio_call $5A, $FC, 2                             ;; 05:68e5
    audio_call $5A, $01, 2                             ;; 05:68e9
    audio_call $5A, $FC, 2                             ;; 05:68ed
    audio_call $5A, $03, 1                             ;; 05:68f1
    audio_call $5A, $01, 1                             ;; 05:68f5
    audio_call $5A, $FC, 5                             ;; 05:68f9
    audio_call $5A, $01, 4                             ;; 05:68fd
    audio_call $5A, $FC, 4                             ;; 05:6901
    audio_call $5A, $03, 2                             ;; 05:6905
    audio_call $5A, $01, 2                             ;; 05:6909
    audio_call $5A, $FC, 2                             ;; 05:690d
    audio_call $5A, $03, 2                             ;; 05:6911
    audio_call $5A, $FC, 8                             ;; 05:6915
    audio_call $5A, $01, 2                             ;; 05:6919
    audio_call $5B, $04, 2                             ;; 05:691d
    audio_call $5B, $FF, 2                             ;; 05:6921
    audio_call $5A, $01, 4                             ;; 05:6925
    audio_call $5B, $04, 2                             ;; 05:6929
    audio_call $5B, $FF, 2                             ;; 05:692d
    audio_call $5A, $01, 2                             ;; 05:6931
    audio_call $5A, $FC, 5                             ;; 05:6935
    audio_call $5A, $01, 4                             ;; 05:6939
    audio_call $5A, $FC, 4                             ;; 05:693d
    audio_call $5A, $03, 2                             ;; 05:6941
    audio_call $5A, $01, 2                             ;; 05:6945
    audio_call $5A, $FC, 2                             ;; 05:6949
    audio_call $5A, $03, 2                             ;; 05:694d
    audio_call $5A, $FC, 4                             ;; 05:6951
    audio_call $5A, $01, 1                             ;; 05:6955
    audio_call $5A, $03, 1                             ;; 05:6959
    audio_call $5A, $FC, 2                             ;; 05:695d
    audio_call $5A, $01, 1                             ;; 05:6961
    audio_call $5A, $03, 1                             ;; 05:6965
    audio_call $5A, $FC, 2                             ;; 05:6969
    audio_call $5A, $01, 1                             ;; 05:696d
    audio_call $5A, $03, 1                             ;; 05:6971
    audio_call $5B, $04, 1                             ;; 05:6975
    audio_call $5A, $03, 1                             ;; 05:6979
    audio_call $5A, $FC, 2                             ;; 05:697d
    audio_goto audio_05_68e5_Song_SuperheroShow_Ch2    ;; 05:6981

audio_05_6984_Song_SuperheroShow_Ch3:
; SONG_SUPERHERO_SHOW (song $17) channel 3
; AUDIO_CMD_GOTO target
    audio_call $58, $F0, 2                             ;; 05:6984
    audio_call $58, $F5, 2                             ;; 05:6988
    audio_call $58, $F0, 2                             ;; 05:698c
    audio_call $58, $F7, 1                             ;; 05:6990
    audio_call $58, $F5, 1                             ;; 05:6994
    audio_call $58, $F0, 5                             ;; 05:6998
    audio_call $58, $F5, 4                             ;; 05:699c
    audio_call $58, $F0, 4                             ;; 05:69a0
    audio_call $58, $F7, 2                             ;; 05:69a4
    audio_call $58, $F5, 2                             ;; 05:69a8
    audio_call $58, $F0, 2                             ;; 05:69ac
    audio_call $58, $F7, 2                             ;; 05:69b0
    audio_call $58, $F0, 8                             ;; 05:69b4
    audio_call $58, $F5, 2                             ;; 05:69b8
    audio_call $59, $F8, 2                             ;; 05:69bc
    audio_call $59, $F3, 2                             ;; 05:69c0
    audio_call $58, $F5, 4                             ;; 05:69c4
    audio_call $59, $F8, 2                             ;; 05:69c8
    audio_call $59, $F3, 2                             ;; 05:69cc
    audio_call $58, $F5, 2                             ;; 05:69d0
    audio_call $58, $F0, 5                             ;; 05:69d4
    audio_call $58, $F5, 4                             ;; 05:69d8
    audio_call $58, $F0, 4                             ;; 05:69dc
    audio_call $58, $F7, 2                             ;; 05:69e0
    audio_call $58, $F5, 2                             ;; 05:69e4
    audio_call $58, $F0, 2                             ;; 05:69e8
    audio_call $58, $F7, 2                             ;; 05:69ec
    audio_call $58, $F0, 4                             ;; 05:69f0
    audio_call $58, $F5, 1                             ;; 05:69f4
    audio_call $58, $F7, 1                             ;; 05:69f8
    audio_call $58, $F0, 2                             ;; 05:69fc
    audio_call $58, $F5, 1                             ;; 05:6a00
    audio_call $58, $F7, 1                             ;; 05:6a04
    audio_call $58, $F0, 2                             ;; 05:6a08
    audio_call $58, $F5, 1                             ;; 05:6a0c
    audio_call $58, $F7, 1                             ;; 05:6a10
    audio_call $59, $F8, 1                             ;; 05:6a14
    audio_call $58, $F7, 1                             ;; 05:6a18
    audio_call $58, $F0, 2                             ;; 05:6a1c
    audio_goto audio_05_6984_Song_SuperheroShow_Ch3    ;; 05:6a20

audio_05_6a23_Song_SuperheroShow_Ch4:
; SONG_SUPERHERO_SHOW (song $17) channel 4
; AUDIO_CMD_GOTO target
    audio_call $57, $00, 46                            ;; 05:6a23
    audio_goto audio_05_6a23_Song_SuperheroShow_Ch4    ;; 05:6a27

audio_05_6a2a_Pattern5C:
; pattern $5C
    audio_note $24, $00, $4                            ;; 05:6a2a  ; C#5
    audio_note $39, $08, $2                            ;; 05:6a2c  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6a2e  ; C#7
    audio_note $3E, $08, $4                            ;; 05:6a30  ; D#7
    audio_note $3F, $08, $2                            ;; 05:6a32  ; E7
    audio_note $40, $08, $4                            ;; 05:6a34  ; F7
    audio_note $43, $08, $2                            ;; 05:6a36  ; G#7
    audio_note $44, $08, $4                            ;; 05:6a38  ; A7
    audio_note $45, $08, $4                            ;; 05:6a3a  ; A#7
    audio_note $43, $08, $4                            ;; 05:6a3c  ; G#7
    audio_note $45, $08, $4                            ;; 05:6a3e  ; A#7
    audio_note $43, $08, $2                            ;; 05:6a40  ; G#7
    audio_note $45, $08, $2                            ;; 05:6a42  ; A#7
    audio_note $48, $08, $4                            ;; 05:6a44  ; C#8
    audio_note $45, $08, $2                            ;; 05:6a46  ; A#7
    audio_note $43, $08, $4                            ;; 05:6a48  ; G#7
    audio_note $40, $08, $2                            ;; 05:6a4a  ; F7
    audio_note $43, $08, $2                            ;; 05:6a4c  ; G#7
    audio_note $44, $08, $2                            ;; 05:6a4e  ; A7
    audio_note $45, $08, $2                            ;; 05:6a50  ; A#7
    audio_note $48, $08, $2                            ;; 05:6a52  ; C#8
    audio_note $4A, $08, $2                            ;; 05:6a54  ; D#8
    audio_note $4B, $08, $2                            ;; 05:6a56  ; E8
    audio_note $4C, $08, $4                            ;; 05:6a58  ; F8
    audio_note $4A, $08, $4                            ;; 05:6a5a  ; D#8
    audio_note $48, $08, $2                            ;; 05:6a5c  ; C#8
    audio_note $45, $08, $4                            ;; 05:6a5e  ; A#7
    audio_note $43, $08, $4                            ;; 05:6a60  ; G#7
    audio_note $45, $08, $2                            ;; 05:6a62  ; A#7
    audio_note $43, $08, $2                            ;; 05:6a64  ; G#7
    audio_note $40, $08, $2                            ;; 05:6a66  ; F7
    audio_note $43, $08, $4                            ;; 05:6a68  ; G#7
    audio_note $44, $08, $4                            ;; 05:6a6a  ; A7
    audio_note $45, $08, $6                            ;; 05:6a6c  ; A#7
    audio_note $45, $08, $2                            ;; 05:6a6e  ; A#7
    audio_note $43, $08, $2                            ;; 05:6a70  ; G#7
    audio_note $40, $08, $2                            ;; 05:6a72  ; F7
    audio_note $45, $08, $8                            ;; 05:6a74  ; A#7
    audio_note $24, $00, $2                            ;; 05:6a76  ; C#5
    audio_end_pattern                                  ;; 05:6a78

audio_05_6a79_Pattern5D:
; pattern $5D
    audio_note $24, $00, $4                            ;; 05:6a79  ; C#5
    audio_note $4C, $08, $2                            ;; 05:6a7b  ; F8
    audio_note $4F, $08, $2                            ;; 05:6a7d  ; G#8
    audio_note $51, $08, $2                            ;; 05:6a7f  ; A#8
    audio_note $52, $08, $4                            ;; 05:6a81  ; B8
    audio_note $53, $08, $4                            ;; 05:6a83  ; C9
    audio_note $51, $08, $2                            ;; 05:6a85  ; A#8
    audio_note $4F, $08, $2                            ;; 05:6a87  ; G#8
    audio_note $4C, $08, $2                            ;; 05:6a89  ; F8
    audio_note $4F, $08, $2                            ;; 05:6a8b  ; G#8
    audio_note $51, $08, $2                            ;; 05:6a8d  ; A#8
    audio_note $52, $08, $4                            ;; 05:6a8f  ; B8
    audio_note $53, $08, $4                            ;; 05:6a91  ; C9
    audio_note $51, $08, $4                            ;; 05:6a93  ; A#8
    audio_note $4F, $08, $2                            ;; 05:6a95  ; G#8
    audio_note $4C, $08, $4                            ;; 05:6a97  ; F8
    audio_note $4F, $08, $4                            ;; 05:6a99  ; G#8
    audio_note $4C, $08, $2                            ;; 05:6a9b  ; F8
    audio_note $4A, $08, $2                            ;; 05:6a9d  ; D#8
    audio_note $47, $08, $2                            ;; 05:6a9f  ; C8
    audio_note $4A, $08, $4                            ;; 05:6aa1  ; D#8
    audio_note $4C, $08, $6                            ;; 05:6aa3  ; F8
    audio_note $4D, $08, $2                            ;; 05:6aa5  ; F#8
    audio_note $4C, $08, $2                            ;; 05:6aa7  ; F8
    audio_note $4A, $08, $4                            ;; 05:6aa9  ; D#8
    audio_note $45, $08, $2                            ;; 05:6aab  ; A#7
    audio_note $4A, $08, $4                            ;; 05:6aad  ; D#8
    audio_note $4C, $08, $2                            ;; 05:6aaf  ; F8
    audio_note $4D, $08, $2                            ;; 05:6ab1  ; F#8
    audio_note $50, $08, $2                            ;; 05:6ab3  ; A8
    audio_note $51, $08, $4                            ;; 05:6ab5  ; A#8
    audio_note $4D, $08, $4                            ;; 05:6ab7  ; F#8
    audio_note $4A, $08, $4                            ;; 05:6ab9  ; D#8
    audio_note $4D, $08, $2                            ;; 05:6abb  ; F#8
    audio_note $4A, $08, $2                            ;; 05:6abd  ; D#8
    audio_note $45, $08, $4                            ;; 05:6abf  ; A#7
    audio_note $4A, $08, $2                            ;; 05:6ac1  ; D#8
    audio_note $45, $08, $2                            ;; 05:6ac3  ; A#7
    audio_note $41, $08, $4                            ;; 05:6ac5  ; F#7
    audio_note $45, $08, $2                            ;; 05:6ac7  ; A#7
    audio_note $41, $08, $2                            ;; 05:6ac9  ; F#7
    audio_note $3E, $08, $7                            ;; 05:6acb  ; D#7
    audio_note $39, $08, $2                            ;; 05:6acd  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6acf  ; C#7
    audio_note $3E, $08, $2                            ;; 05:6ad1  ; D#7
    audio_note $3F, $08, $2                            ;; 05:6ad3  ; E7
    audio_note $40, $08, $2                            ;; 05:6ad5  ; F7
    audio_note $43, $08, $2                            ;; 05:6ad7  ; G#7
    audio_note $44, $08, $2                            ;; 05:6ad9  ; A7
    audio_note $45, $08, $2                            ;; 05:6adb  ; A#7
    audio_note $48, $08, $2                            ;; 05:6add  ; C#8
    audio_note $4A, $08, $2                            ;; 05:6adf  ; D#8
    audio_note $4B, $08, $4                            ;; 05:6ae1  ; E8
    audio_note $4C, $08, $4                            ;; 05:6ae3  ; F8
    audio_note $4A, $08, $2                            ;; 05:6ae5  ; D#8
    audio_note $48, $08, $4                            ;; 05:6ae7  ; C#8
    audio_note $45, $08, $4                            ;; 05:6ae9  ; A#7
    audio_note $48, $08, $2                            ;; 05:6aeb  ; C#8
    audio_note $4A, $08, $2                            ;; 05:6aed  ; D#8
    audio_note $4C, $08, $2                            ;; 05:6aef  ; F8
    audio_note $4A, $08, $4                            ;; 05:6af1  ; D#8
    audio_note $48, $08, $4                            ;; 05:6af3  ; C#8
    audio_note $45, $08, $4                            ;; 05:6af5  ; A#7
    audio_note $48, $08, $6                            ;; 05:6af7  ; C#8
    audio_note $51, $08, $2                            ;; 05:6af9  ; A#8
    audio_note $52, $08, $2                            ;; 05:6afb  ; B8
    audio_note $53, $08, $2                            ;; 05:6afd  ; C9
    audio_note $51, $08, $2                            ;; 05:6aff  ; A#8
    audio_note $4F, $08, $2                            ;; 05:6b01  ; G#8
    audio_note $4C, $08, $2                            ;; 05:6b03  ; F8
    audio_note $4A, $08, $2                            ;; 05:6b05  ; D#8
    audio_note $4C, $08, $2                            ;; 05:6b07  ; F8
    audio_note $4F, $08, $2                            ;; 05:6b09  ; G#8
    audio_note $4C, $08, $2                            ;; 05:6b0b  ; F8
    audio_note $4A, $08, $2                            ;; 05:6b0d  ; D#8
    audio_note $47, $08, $2                            ;; 05:6b0f  ; C8
    audio_note $4A, $08, $2                            ;; 05:6b11  ; D#8
    audio_note $4C, $08, $2                            ;; 05:6b13  ; F8
    audio_note $4A, $08, $2                            ;; 05:6b15  ; D#8
    audio_note $45, $08, $2                            ;; 05:6b17  ; A#7
    audio_note $43, $08, $2                            ;; 05:6b19  ; G#7
    audio_note $45, $08, $2                            ;; 05:6b1b  ; A#7
    audio_note $47, $08, $2                            ;; 05:6b1d  ; C8
    audio_note $45, $08, $2                            ;; 05:6b1f  ; A#7
    audio_note $43, $08, $2                            ;; 05:6b21  ; G#7
    audio_note $40, $08, $2                            ;; 05:6b23  ; F7
    audio_note $43, $08, $4                            ;; 05:6b25  ; G#7
    audio_note $45, $08, $4                            ;; 05:6b27  ; A#7
    audio_note $47, $08, $4                            ;; 05:6b29  ; C8
    audio_note $43, $08, $4                            ;; 05:6b2b  ; G#7
    audio_end_pattern                                  ;; 05:6b2d

audio_05_6b2e_Pattern5E:
; pattern $5E
    audio_note $24, $00, $4                            ;; 05:6b2e  ; C#5
    audio_note $2D, $08, $4                            ;; 05:6b30  ; A#5
    audio_note $34, $08, $4                            ;; 05:6b32  ; F6
    audio_note $2D, $08, $2                            ;; 05:6b34  ; A#5
    audio_note $34, $08, $4                            ;; 05:6b36  ; F6
    audio_note $2D, $08, $2                            ;; 05:6b38  ; A#5
    audio_note $34, $08, $4                            ;; 05:6b3a  ; F6
    audio_note $2D, $08, $4                            ;; 05:6b3c  ; A#5
    audio_note $34, $08, $4                            ;; 05:6b3e  ; F6
    audio_note $33, $08, $4                            ;; 05:6b40  ; E6
    audio_note $2D, $08, $4                            ;; 05:6b42  ; A#5
    audio_note $33, $08, $4                            ;; 05:6b44  ; E6
    audio_note $2D, $08, $2                            ;; 05:6b46  ; A#5
    audio_note $33, $08, $4                            ;; 05:6b48  ; E6
    audio_note $2D, $08, $2                            ;; 05:6b4a  ; A#5
    audio_note $33, $08, $2                            ;; 05:6b4c  ; E6
    audio_note $2D, $08, $2                            ;; 05:6b4e  ; A#5
    audio_note $30, $08, $2                            ;; 05:6b50  ; C#6
    audio_note $32, $08, $2                            ;; 05:6b52  ; D#6
    audio_note $33, $08, $2                            ;; 05:6b54  ; E6
    audio_note $34, $08, $2                            ;; 05:6b56  ; F6
    audio_end_pattern                                  ;; 05:6b58

audio_05_6b59_Pattern5F:
; pattern $5F
    audio_note $2D, $08, $6                            ;; 05:6b59  ; A#5
    audio_note $30, $08, $6                            ;; 05:6b5b  ; C#6
    audio_note $34, $08, $6                            ;; 05:6b5d  ; F6
    audio_note $35, $08, $6                            ;; 05:6b5f  ; F#6
    audio_note $2D, $08, $8                            ;; 05:6b61  ; A#5
    audio_note $24, $00, $4                            ;; 05:6b63  ; C#5
    audio_note $2B, $08, $4                            ;; 05:6b65  ; G#5
    audio_note $28, $08, $4                            ;; 05:6b67  ; F5
    audio_note $2B, $08, $4                            ;; 05:6b69  ; G#5
    audio_note $2D, $08, $B                            ;; 05:6b6b  ; A#5
    audio_note $2E, $08, $0                            ;; 05:6b6d  ; B5
    audio_note $2F, $08, $0                            ;; 05:6b6f  ; C6
    audio_note $30, $08, $0                            ;; 05:6b71  ; C#6
    audio_note $31, $08, $0                            ;; 05:6b73  ; D6
    audio_note $32, $08, $0                            ;; 05:6b75  ; D#6
    audio_note $33, $08, $0                            ;; 05:6b77  ; E6
    audio_note $34, $08, $0                            ;; 05:6b79  ; F6
    audio_note $35, $08, $0                            ;; 05:6b7b  ; F#6
    audio_note $36, $08, $0                            ;; 05:6b7d  ; G6
    audio_note $37, $08, $0                            ;; 05:6b7f  ; G#6
    audio_note $38, $08, $0                            ;; 05:6b81  ; A6
    audio_note $39, $08, $0                            ;; 05:6b83  ; A#6
    audio_note $3A, $08, $0                            ;; 05:6b85  ; B6
    audio_note $3B, $08, $0                            ;; 05:6b87  ; C7
    audio_note $3C, $08, $0                            ;; 05:6b89  ; C#7
    audio_note $3D, $08, $0                            ;; 05:6b8b  ; D7
    audio_end_pattern                                  ;; 05:6b8d

audio_05_6b8e_Pattern60:
; pattern $60
    audio_note $32, $08, $2                            ;; 05:6b8e  ; D#6
    audio_note $35, $08, $2                            ;; 05:6b90  ; F#6
    audio_note $37, $08, $2                            ;; 05:6b92  ; G#6
    audio_note $38, $08, $2                            ;; 05:6b94  ; A6
    audio_note $39, $08, $4                            ;; 05:6b96  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6b98  ; C#7
    audio_note $3E, $08, $4                            ;; 05:6b9a  ; D#7
    audio_note $41, $08, $2                            ;; 05:6b9c  ; F#7
    audio_note $3E, $08, $2                            ;; 05:6b9e  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6ba0  ; C#7
    audio_note $39, $08, $2                            ;; 05:6ba2  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6ba4  ; C#7
    audio_note $3D, $08, $4                            ;; 05:6ba6  ; D7
    audio_note $3E, $08, $4                            ;; 05:6ba8  ; D#7
    audio_note $3C, $08, $4                            ;; 05:6baa  ; C#7
    audio_note $39, $08, $2                            ;; 05:6bac  ; A#6
    audio_note $37, $08, $4                            ;; 05:6bae  ; G#6
    audio_note $39, $08, $4                            ;; 05:6bb0  ; A#6
    audio_note $37, $08, $2                            ;; 05:6bb2  ; G#6
    audio_note $35, $08, $2                            ;; 05:6bb4  ; F#6
    audio_note $34, $08, $2                            ;; 05:6bb6  ; F6
    audio_note $35, $08, $4                            ;; 05:6bb8  ; F#6
    audio_note $37, $08, $4                            ;; 05:6bba  ; G#6
    audio_note $35, $08, $4                            ;; 05:6bbc  ; F#6
    audio_note $37, $08, $4                            ;; 05:6bbe  ; G#6
    audio_note $39, $08, $2                            ;; 05:6bc0  ; A#6
    audio_note $3C, $08, $4                            ;; 05:6bc2  ; C#7
    audio_note $41, $08, $4                            ;; 05:6bc4  ; F#7
    audio_note $43, $08, $2                            ;; 05:6bc6  ; G#7
    audio_note $45, $08, $2                            ;; 05:6bc8  ; A#7
    audio_note $43, $08, $2                            ;; 05:6bca  ; G#7
    audio_note $45, $08, $2                            ;; 05:6bcc  ; A#7
    audio_note $43, $08, $2                            ;; 05:6bce  ; G#7
    audio_note $41, $08, $2                            ;; 05:6bd0  ; F#7
    audio_note $3C, $08, $2                            ;; 05:6bd2  ; C#7
    audio_note $41, $08, $4                            ;; 05:6bd4  ; F#7
    audio_note $43, $08, $4                            ;; 05:6bd6  ; G#7
    audio_note $45, $08, $2                            ;; 05:6bd8  ; A#7
    audio_note $43, $08, $4                            ;; 05:6bda  ; G#7
    audio_note $41, $08, $4                            ;; 05:6bdc  ; F#7
    audio_note $3C, $08, $2                            ;; 05:6bde  ; C#7
    audio_note $41, $08, $2                            ;; 05:6be0  ; F#7
    audio_note $43, $08, $2                            ;; 05:6be2  ; G#7
    audio_note $45, $08, $4                            ;; 05:6be4  ; A#7
    audio_note $43, $08, $6                            ;; 05:6be6  ; G#7
    audio_note $34, $08, $2                            ;; 05:6be8  ; F6
    audio_note $37, $08, $2                            ;; 05:6bea  ; G#6
    audio_note $38, $08, $2                            ;; 05:6bec  ; A6
    audio_note $39, $08, $2                            ;; 05:6bee  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6bf0  ; C#7
    audio_note $3E, $08, $2                            ;; 05:6bf2  ; D#7
    audio_note $40, $08, $4                            ;; 05:6bf4  ; F7
    audio_note $3E, $08, $2                            ;; 05:6bf6  ; D#7
    audio_note $3C, $08, $4                            ;; 05:6bf8  ; C#7
    audio_note $39, $08, $2                            ;; 05:6bfa  ; A#6
    audio_note $37, $08, $2                            ;; 05:6bfc  ; G#6
    audio_note $39, $08, $2                            ;; 05:6bfe  ; A#6
    audio_note $3C, $08, $4                            ;; 05:6c00  ; C#7
    audio_note $39, $08, $4                            ;; 05:6c02  ; A#6
    audio_note $37, $08, $2                            ;; 05:6c04  ; G#6
    audio_note $34, $08, $4                            ;; 05:6c06  ; F6
    audio_note $37, $08, $5                            ;; 05:6c08  ; G#6
    audio_note $35, $08, $4                            ;; 05:6c0a  ; F#6
    audio_note $34, $08, $7                            ;; 05:6c0c  ; F6
    audio_note $32, $08, $2                            ;; 05:6c0e  ; D#6
    audio_note $35, $08, $2                            ;; 05:6c10  ; F#6
    audio_note $37, $08, $2                            ;; 05:6c12  ; G#6
    audio_note $38, $08, $2                            ;; 05:6c14  ; A6
    audio_note $39, $08, $2                            ;; 05:6c16  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6c18  ; C#7
    audio_note $3D, $08, $2                            ;; 05:6c1a  ; D7
    audio_note $3E, $08, $2                            ;; 05:6c1c  ; D#7
    audio_note $41, $08, $2                            ;; 05:6c1e  ; F#7
    audio_note $43, $08, $2                            ;; 05:6c20  ; G#7
    audio_note $45, $08, $4                            ;; 05:6c22  ; A#7
    audio_note $43, $08, $4                            ;; 05:6c24  ; G#7
    audio_note $45, $08, $4                            ;; 05:6c26  ; A#7
    audio_note $43, $08, $4                            ;; 05:6c28  ; G#7
    audio_note $41, $08, $2                            ;; 05:6c2a  ; F#7
    audio_note $3E, $08, $4                            ;; 05:6c2c  ; D#7
    audio_note $41, $08, $4                            ;; 05:6c2e  ; F#7
    audio_note $3E, $08, $2                            ;; 05:6c30  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6c32  ; C#7
    audio_note $39, $08, $2                            ;; 05:6c34  ; A#6
    audio_note $3C, $08, $4                            ;; 05:6c36  ; C#7
    audio_note $3E, $08, $4                            ;; 05:6c38  ; D#7
    audio_end_pattern                                  ;; 05:6c3a

audio_05_6c3b_Pattern61:
; pattern $61
    audio_note $32, $08, $6                            ;; 05:6c3b  ; D#6
    audio_note $35, $08, $6                            ;; 05:6c3d  ; F#6
    audio_note $39, $08, $6                            ;; 05:6c3f  ; A#6
    audio_note $35, $08, $6                            ;; 05:6c41  ; F#6
    audio_note $34, $08, $6                            ;; 05:6c43  ; F6
    audio_note $37, $08, $6                            ;; 05:6c45  ; G#6
    audio_note $3B, $08, $6                            ;; 05:6c47  ; C7
    audio_note $37, $08, $7                            ;; 05:6c49  ; G#6
    audio_note $3C, $08, $6                            ;; 05:6c4b  ; C#7
    audio_note $3B, $08, $4                            ;; 05:6c4d  ; C7
    audio_note $39, $08, $6                            ;; 05:6c4f  ; A#6
    audio_note $37, $08, $6                            ;; 05:6c51  ; G#6
    audio_note $39, $08, $4                            ;; 05:6c53  ; A#6
    audio_note $37, $08, $4                            ;; 05:6c55  ; G#6
    audio_note $34, $08, $4                            ;; 05:6c57  ; F6
    audio_note $32, $08, $4                            ;; 05:6c59  ; D#6
    audio_note $34, $08, $8                            ;; 05:6c5b  ; F6
    audio_note $32, $08, $2                            ;; 05:6c5d  ; D#6
    audio_note $35, $08, $2                            ;; 05:6c5f  ; F#6
    audio_note $37, $08, $2                            ;; 05:6c61  ; G#6
    audio_note $38, $08, $2                            ;; 05:6c63  ; A6
    audio_note $39, $08, $4                            ;; 05:6c65  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6c67  ; C#7
    audio_note $3E, $08, $4                            ;; 05:6c69  ; D#7
    audio_note $41, $08, $5                            ;; 05:6c6b  ; F#7
    audio_note $3E, $08, $4                            ;; 05:6c6d  ; D#7
    audio_note $3C, $08, $6                            ;; 05:6c6f  ; C#7
    audio_note $34, $08, $4                            ;; 05:6c71  ; F6
    audio_note $37, $08, $4                            ;; 05:6c73  ; G#6
    audio_note $3B, $08, $2                            ;; 05:6c75  ; C7
    audio_note $40, $08, $4                            ;; 05:6c77  ; F7
    audio_note $43, $08, $2                            ;; 05:6c79  ; G#7
    audio_note $45, $08, $4                            ;; 05:6c7b  ; A#7
    audio_note $47, $08, $4                            ;; 05:6c7d  ; C8
    audio_note $43, $08, $7                            ;; 05:6c7f  ; G#7
    audio_note $45, $08, $4                            ;; 05:6c81  ; A#7
    audio_note $43, $08, $2                            ;; 05:6c83  ; G#7
    audio_note $40, $08, $4                            ;; 05:6c85  ; F7
    audio_note $3E, $08, $2                            ;; 05:6c87  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6c89  ; C#7
    audio_note $3E, $08, $2                            ;; 05:6c8b  ; D#7
    audio_note $40, $08, $2                            ;; 05:6c8d  ; F7
    audio_note $3E, $08, $2                            ;; 05:6c8f  ; D#7
    audio_note $3C, $08, $4                            ;; 05:6c91  ; C#7
    audio_note $39, $08, $4                            ;; 05:6c93  ; A#6
    audio_note $37, $08, $4                            ;; 05:6c95  ; G#6
    audio_note $39, $08, $2                            ;; 05:6c97  ; A#6
    audio_note $3C, $08, $4                            ;; 05:6c99  ; C#7
    audio_note $39, $08, $4                            ;; 05:6c9b  ; A#6
    audio_note $37, $08, $2                            ;; 05:6c9d  ; G#6
    audio_note $34, $08, $2                            ;; 05:6c9f  ; F6
    audio_note $37, $08, $2                            ;; 05:6ca1  ; G#6
    audio_note $39, $08, $4                            ;; 05:6ca3  ; A#6
    audio_note $37, $08, $4                            ;; 05:6ca5  ; G#6
    audio_note $32, $08, $2                            ;; 05:6ca7  ; D#6
    audio_note $35, $08, $2                            ;; 05:6ca9  ; F#6
    audio_note $37, $08, $2                            ;; 05:6cab  ; G#6
    audio_note $38, $08, $2                            ;; 05:6cad  ; A6
    audio_note $39, $08, $4                            ;; 05:6caf  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6cb1  ; C#7
    audio_note $3E, $08, $5                            ;; 05:6cb3  ; D#7
    audio_note $3C, $08, $4                            ;; 05:6cb5  ; C#7
    audio_note $39, $08, $4                            ;; 05:6cb7  ; A#6
    audio_note $3C, $08, $6                            ;; 05:6cb9  ; C#7
    audio_note $40, $08, $2                            ;; 05:6cbb  ; F7
    audio_note $43, $08, $2                            ;; 05:6cbd  ; G#7
    audio_note $45, $08, $4                            ;; 05:6cbf  ; A#7
    audio_note $47, $08, $2                            ;; 05:6cc1  ; C8
    audio_note $45, $08, $4                            ;; 05:6cc3  ; A#7
    audio_note $43, $08, $2                            ;; 05:6cc5  ; G#7
    audio_note $40, $08, $2                            ;; 05:6cc7  ; F7
    audio_note $43, $08, $2                            ;; 05:6cc9  ; G#7
    audio_note $45, $08, $4                            ;; 05:6ccb  ; A#7
    audio_note $47, $08, $4                            ;; 05:6ccd  ; C8
    audio_note $48, $08, $4                            ;; 05:6ccf  ; C#8
    audio_note $47, $08, $4                            ;; 05:6cd1  ; C8
    audio_note $45, $08, $4                            ;; 05:6cd3  ; A#7
    audio_note $47, $08, $2                            ;; 05:6cd5  ; C8
    audio_note $48, $08, $4                            ;; 05:6cd7  ; C#8
    audio_note $41, $08, $2                            ;; 05:6cd9  ; F#7
    audio_note $45, $08, $4                            ;; 05:6cdb  ; A#7
    audio_note $47, $08, $4                            ;; 05:6cdd  ; C8
    audio_note $48, $08, $4                            ;; 05:6cdf  ; C#8
    audio_note $47, $08, $4                            ;; 05:6ce1  ; C8
    audio_note $43, $08, $4                            ;; 05:6ce3  ; G#7
    audio_note $40, $08, $4                            ;; 05:6ce5  ; F7
    audio_note $43, $08, $2                            ;; 05:6ce7  ; G#7
    audio_note $47, $08, $4                            ;; 05:6ce9  ; C8
    audio_note $43, $08, $2                            ;; 05:6ceb  ; G#7
    audio_note $40, $08, $4                            ;; 05:6ced  ; F7
    audio_note $43, $08, $4                            ;; 05:6cef  ; G#7
    audio_note $47, $08, $6                            ;; 05:6cf1  ; C8
    audio_note $45, $08, $2                            ;; 05:6cf3  ; A#7
    audio_note $43, $08, $2                            ;; 05:6cf5  ; G#7
    audio_note $40, $08, $4                            ;; 05:6cf7  ; F7
    audio_note $3E, $08, $2                            ;; 05:6cf9  ; D#7
    audio_note $3C, $08, $4                            ;; 05:6cfb  ; C#7
    audio_note $39, $08, $2                            ;; 05:6cfd  ; A#6
    audio_note $3C, $08, $2                            ;; 05:6cff  ; C#7
    audio_note $3E, $08, $2                            ;; 05:6d01  ; D#7
    audio_note $3F, $08, $2                            ;; 05:6d03  ; E7
    audio_note $40, $08, $2                            ;; 05:6d05  ; F7
    audio_note $3E, $08, $2                            ;; 05:6d07  ; D#7
    audio_note $3C, $08, $2                            ;; 05:6d09  ; C#7
    audio_note $39, $08, $A                            ;; 05:6d0b  ; A#6
    audio_end_pattern                                  ;; 05:6d0d

audio_05_6d0e_Pattern5A:
; pattern $5A
    audio_note $24, $00, $4                            ;; 05:6d0e  ; C#5
    audio_note $21, $16, $4                            ;; 05:6d10  ; A#4
    audio_note $24, $00, $2                            ;; 05:6d12  ; C#5
    audio_note $21, $16, $2                            ;; 05:6d14  ; A#4
    audio_note $24, $00, $4                            ;; 05:6d16  ; C#5
    audio_note $21, $16, $5                            ;; 05:6d18  ; A#4
    audio_note $21, $16, $2                            ;; 05:6d1a  ; A#4
    audio_note $24, $00, $4                            ;; 05:6d1c  ; C#5
    audio_note $21, $16, $4                            ;; 05:6d1e  ; A#4
    audio_end_pattern                                  ;; 05:6d20

audio_05_6d21_Pattern5B:
; pattern $5B
    audio_note $24, $00, $4                            ;; 05:6d21  ; C#5
    audio_note $21, $13, $4                            ;; 05:6d23  ; A#4
    audio_note $24, $00, $2                            ;; 05:6d25  ; C#5
    audio_note $21, $13, $2                            ;; 05:6d27  ; A#4
    audio_note $24, $00, $4                            ;; 05:6d29  ; C#5
    audio_note $21, $13, $5                            ;; 05:6d2b  ; A#4
    audio_note $21, $13, $2                            ;; 05:6d2d  ; A#4
    audio_note $24, $00, $4                            ;; 05:6d2f  ; C#5
    audio_note $21, $13, $4                            ;; 05:6d31  ; A#4
    audio_end_pattern                                  ;; 05:6d33

audio_05_6d34_Pattern58:
; pattern $58
    audio_note $21, $11, $6                            ;; 05:6d34  ; A#4
    audio_note $1F, $11, $5                            ;; 05:6d36  ; G#4
    audio_note $1C, $11, $4                            ;; 05:6d38  ; F4
    audio_note $1C, $11, $2                            ;; 05:6d3a  ; F4
    audio_note $1C, $11, $4                            ;; 05:6d3c  ; F4
    audio_note $1F, $11, $4                            ;; 05:6d3e  ; G#4
    audio_note $20, $11, $4                            ;; 05:6d40  ; A4
    audio_end_pattern                                  ;; 05:6d42

audio_05_6d43_Pattern59:
; pattern $59
    audio_note $21, $11, $6                            ;; 05:6d43  ; A#4
    audio_note $1F, $11, $5                            ;; 05:6d45  ; G#4
    audio_note $1C, $11, $4                            ;; 05:6d47  ; F4
    audio_note $1C, $11, $2                            ;; 05:6d49  ; F4
    audio_note $1C, $11, $4                            ;; 05:6d4b  ; F4
    audio_note $1F, $11, $4                            ;; 05:6d4d  ; G#4
    audio_note $20, $11, $4                            ;; 05:6d4f  ; A4
    audio_end_pattern                                  ;; 05:6d51

audio_05_6d52_Pattern57:
; pattern $57
    audio_note $18, $01, $2                            ;; 05:6d52  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6d54  ; G4
    audio_note $1E, $03, $2                            ;; 05:6d56  ; G4
    audio_note $1E, $03, $2                            ;; 05:6d58  ; G4
    audio_note $1A, $02, $2                            ;; 05:6d5a  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6d5c  ; G4
    audio_note $1E, $03, $2                            ;; 05:6d5e  ; G4
    audio_note $18, $01, $2                            ;; 05:6d60  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6d62  ; G4
    audio_note $18, $01, $2                            ;; 05:6d64  ; C#4
    audio_note $18, $01, $2                            ;; 05:6d66  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6d68  ; G4
    audio_note $1A, $02, $2                            ;; 05:6d6a  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6d6c  ; G4
    audio_note $18, $01, $2                            ;; 05:6d6e  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6d70  ; G4
    audio_note $18, $01, $2                            ;; 05:6d72  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6d74  ; G4
    audio_note $1E, $03, $2                            ;; 05:6d76  ; G4
    audio_note $1E, $03, $2                            ;; 05:6d78  ; G4
    audio_note $1A, $02, $2                            ;; 05:6d7a  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6d7c  ; G4
    audio_note $22, $06, $4                            ;; 05:6d7e  ; B4
    audio_note $1E, $03, $2                            ;; 05:6d80  ; G4
    audio_note $18, $01, $2                            ;; 05:6d82  ; C#4
    audio_note $18, $01, $2                            ;; 05:6d84  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6d86  ; G4
    audio_note $1A, $02, $2                            ;; 05:6d88  ; D#4
    audio_note $18, $01, $2                            ;; 05:6d8a  ; C#4
    audio_note $18, $01, $2                            ;; 05:6d8c  ; C#4
    audio_note $22, $06, $2                            ;; 05:6d8e  ; B4
    audio_end_pattern                                  ;; 05:6d90

audio_05_6d91_Song_ChannelZ_Ch1:
; SONG_CHANNEL_Z (song $18) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:6d91
    audio_tempo $F2                                    ;; 05:6d93
    audio_call $00, $00, 8                             ;; 05:6d95
    audio_call $65, $E5, 1                             ;; 05:6d99
    audio_call $66, $E5, 1                             ;; 05:6d9d
    audio_call $67, $E5, 1                             ;; 05:6da1
    audio_call $68, $E5, 1                             ;; 05:6da5
    audio_marker $01                                   ;; 05:6da9
    audio_goto audio_05_6d91_Song_ChannelZ_Ch1         ;; 05:6dab

audio_05_6dae_Song_ChannelZ_Ch2:
; SONG_CHANNEL_Z (song $18) channel 2
; AUDIO_CMD_GOTO target
    audio_call $64, $E5, 2                             ;; 05:6dae
    audio_call $64, $E1, 2                             ;; 05:6db2
    audio_call $64, $E5, 4                             ;; 05:6db6
    audio_call $64, $E1, 4                             ;; 05:6dba
    audio_call $64, $E8, 4                             ;; 05:6dbe
    audio_call $64, $E5, 1                             ;; 05:6dc2
    audio_call $64, $E1, 2                             ;; 05:6dc6
    audio_call $64, $E5, 2                             ;; 05:6dca
    audio_call $64, $E1, 2                             ;; 05:6dce
    audio_call $64, $E5, 1                             ;; 05:6dd2
    audio_goto audio_05_6dae_Song_ChannelZ_Ch2         ;; 05:6dd6

audio_05_6dd9_Song_ChannelZ_Ch3:
; SONG_CHANNEL_Z (song $18) channel 3
; AUDIO_CMD_GOTO target
    audio_call $63, $F1, 2                             ;; 05:6dd9
    audio_call $63, $ED, 2                             ;; 05:6ddd
    audio_call $63, $F1, 4                             ;; 05:6de1
    audio_call $63, $ED, 4                             ;; 05:6de5
    audio_call $63, $F4, 4                             ;; 05:6de9
    audio_call $63, $F1, 1                             ;; 05:6ded
    audio_call $63, $ED, 2                             ;; 05:6df1
    audio_call $63, $F1, 2                             ;; 05:6df5
    audio_call $63, $ED, 2                             ;; 05:6df9
    audio_call $63, $F1, 1                             ;; 05:6dfd
    audio_goto audio_05_6dd9_Song_ChannelZ_Ch3         ;; 05:6e01

audio_05_6e04_Song_ChannelZ_Ch4:
; SONG_CHANNEL_Z (song $18) channel 4
; AUDIO_CMD_GOTO target
    audio_call $62, $00, 12                            ;; 05:6e04
    audio_goto audio_05_6e04_Song_ChannelZ_Ch4         ;; 05:6e08

audio_05_6e0b_Pattern65:
; pattern $65
    audio_note $24, $00, $8                            ;; 05:6e0b  ; C#5
    audio_note $40, $09, $8                            ;; 05:6e0d  ; F7
    audio_note $47, $09, $8                            ;; 05:6e0f  ; C8
    audio_note $48, $09, $A                            ;; 05:6e11  ; C#8
    audio_note $47, $09, $4                            ;; 05:6e13  ; C8
    audio_note $48, $09, $6                            ;; 05:6e15  ; C#8
    audio_note $40, $09, $4                            ;; 05:6e17  ; F7
    audio_note $47, $09, $B                            ;; 05:6e19  ; C8
    audio_note $45, $09, $4                            ;; 05:6e1b  ; A#7
    audio_note $47, $09, $6                            ;; 05:6e1d  ; C8
    audio_note $48, $09, $4                            ;; 05:6e1f  ; C#8
    audio_note $4C, $09, $6                            ;; 05:6e21  ; F8
    audio_note $4D, $09, $4                            ;; 05:6e23  ; F#8
    audio_note $4C, $09, $6                            ;; 05:6e25  ; F8
    audio_note $4A, $09, $4                            ;; 05:6e27  ; D#8
    audio_note $48, $09, $6                            ;; 05:6e29  ; C#8
    audio_note $4C, $09, $8                            ;; 05:6e2b  ; F8
    audio_note $4A, $09, $6                            ;; 05:6e2d  ; D#8
    audio_note $48, $09, $6                            ;; 05:6e2f  ; C#8
    audio_note $45, $09, $A                            ;; 05:6e31  ; A#7
    audio_end_pattern                                  ;; 05:6e33

audio_05_6e34_Pattern66:
; pattern $66
    audio_note $35, $09, $8                            ;; 05:6e34  ; F#6
    audio_note $36, $09, $8                            ;; 05:6e36  ; G6
    audio_note $37, $09, $8                            ;; 05:6e38  ; G#6
    audio_note $36, $09, $8                            ;; 05:6e3a  ; G6
    audio_note $35, $09, $8                            ;; 05:6e3c  ; F#6
    audio_note $38, $09, $8                            ;; 05:6e3e  ; A6
    audio_note $37, $09, $8                            ;; 05:6e40  ; G#6
    audio_note $35, $09, $8                            ;; 05:6e42  ; F#6
    audio_note $35, $09, $8                            ;; 05:6e44  ; F#6
    audio_note $36, $09, $8                            ;; 05:6e46  ; G6
    audio_note $37, $09, $8                            ;; 05:6e48  ; G#6
    audio_note $36, $09, $8                            ;; 05:6e4a  ; G6
    audio_note $35, $09, $8                            ;; 05:6e4c  ; F#6
    audio_note $38, $09, $8                            ;; 05:6e4e  ; A6
    audio_note $37, $09, $8                            ;; 05:6e50  ; G#6
    audio_note $35, $09, $8                            ;; 05:6e52  ; F#6
    audio_end_pattern                                  ;; 05:6e54

audio_05_6e55_Pattern67:
; pattern $67
    audio_note $37, $09, $6                            ;; 05:6e55  ; G#6
    audio_note $3C, $09, $4                            ;; 05:6e57  ; C#7
    audio_note $3F, $09, $4                            ;; 05:6e59  ; E7
    audio_note $42, $09, $7                            ;; 05:6e5b  ; G7
    audio_note $43, $09, $9                            ;; 05:6e5d  ; G#7
    audio_note $24, $00, $4                            ;; 05:6e5f  ; C#5
    audio_note $44, $09, $6                            ;; 05:6e61  ; A7
    audio_note $45, $09, $8                            ;; 05:6e63  ; A#7
    audio_note $44, $09, $7                            ;; 05:6e65  ; A7
    audio_note $43, $09, $9                            ;; 05:6e67  ; G#7
    audio_note $24, $00, $4                            ;; 05:6e69  ; C#5
    audio_note $48, $09, $4                            ;; 05:6e6b  ; C#8
    audio_note $4A, $09, $4                            ;; 05:6e6d  ; D#8
    audio_note $4B, $09, $6                            ;; 05:6e6f  ; E8
    audio_note $48, $09, $6                            ;; 05:6e71  ; C#8
    audio_note $4A, $09, $4                            ;; 05:6e73  ; D#8
    audio_note $47, $09, $6                            ;; 05:6e75  ; C8
    audio_note $48, $09, $6                            ;; 05:6e77  ; C#8
    audio_note $43, $09, $4                            ;; 05:6e79  ; G#7
    audio_note $44, $09, $4                            ;; 05:6e7b  ; A7
    audio_note $41, $09, $4                            ;; 05:6e7d  ; F#7
    audio_note $43, $09, $4                            ;; 05:6e7f  ; G#7
    audio_note $3F, $09, $4                            ;; 05:6e81  ; E7
    audio_note $41, $09, $4                            ;; 05:6e83  ; F#7
    audio_note $3E, $09, $4                            ;; 05:6e85  ; D#7
    audio_note $3B, $09, $9                            ;; 05:6e87  ; C7
    audio_note $3C, $09, $4                            ;; 05:6e89  ; C#7
    audio_note $3E, $09, $4                            ;; 05:6e8b  ; D#7
    audio_note $3C, $09, $A                            ;; 05:6e8d  ; C#7
    audio_end_pattern                                  ;; 05:6e8f

audio_05_6e90_Pattern68:
; pattern $68
    audio_note $24, $00, $8                            ;; 05:6e90  ; C#5
    audio_note $34, $09, $4                            ;; 05:6e92  ; F6
    audio_note $39, $09, $6                            ;; 05:6e94  ; A#6
    audio_note $3C, $09, $4                            ;; 05:6e96  ; C#7
    audio_note $3F, $09, $8                            ;; 05:6e98  ; E7
    audio_note $40, $09, $8                            ;; 05:6e9a  ; F7
    audio_note $35, $09, $4                            ;; 05:6e9c  ; F#6
    audio_note $37, $09, $4                            ;; 05:6e9e  ; G#6
    audio_note $37, $09, $4                            ;; 05:6ea0  ; G#6
    audio_note $37, $09, $6                            ;; 05:6ea2  ; G#6
    audio_note $35, $09, $4                            ;; 05:6ea4  ; F#6
    audio_note $35, $09, $4                            ;; 05:6ea6  ; F#6
    audio_note $35, $09, $4                            ;; 05:6ea8  ; F#6
    audio_note $35, $09, $4                            ;; 05:6eaa  ; F#6
    audio_note $38, $09, $4                            ;; 05:6eac  ; A6
    audio_note $38, $09, $4                            ;; 05:6eae  ; A6
    audio_note $38, $09, $7                            ;; 05:6eb0  ; A6
    audio_note $37, $09, $6                            ;; 05:6eb2  ; G#6
    audio_note $35, $09, $4                            ;; 05:6eb4  ; F#6
    audio_note $38, $09, $6                            ;; 05:6eb6  ; A6
    audio_note $3C, $09, $7                            ;; 05:6eb8  ; C#7
    audio_note $41, $09, $4                            ;; 05:6eba  ; F#7
    audio_note $43, $09, $4                            ;; 05:6ebc  ; G#7
    audio_note $44, $09, $6                            ;; 05:6ebe  ; A7
    audio_note $41, $09, $6                            ;; 05:6ec0  ; F#7
    audio_note $43, $09, $6                            ;; 05:6ec2  ; G#7
    audio_note $44, $09, $6                            ;; 05:6ec4  ; A7
    audio_note $45, $09, $4                            ;; 05:6ec6  ; A#7
    audio_note $48, $09, $6                            ;; 05:6ec8  ; C#8
    audio_note $4C, $09, $7                            ;; 05:6eca  ; F8
    audio_note $4B, $09, $4                            ;; 05:6ecc  ; E8
    audio_note $4C, $09, $6                            ;; 05:6ece  ; F8
    audio_note $48, $09, $4                            ;; 05:6ed0  ; C#8
    audio_note $45, $09, $6                            ;; 05:6ed2  ; A#7
    audio_note $44, $09, $6                            ;; 05:6ed4  ; A7
    audio_note $45, $09, $6                            ;; 05:6ed6  ; A#7
    audio_note $40, $09, $6                            ;; 05:6ed8  ; F7
    audio_note $3E, $09, $6                            ;; 05:6eda  ; D#7
    audio_note $40, $09, $4                            ;; 05:6edc  ; F7
    audio_note $3C, $09, $6                            ;; 05:6ede  ; C#7
    audio_note $39, $09, $6                            ;; 05:6ee0  ; A#6
    audio_note $39, $09, $4                            ;; 05:6ee2  ; A#6
    audio_note $3B, $09, $4                            ;; 05:6ee4  ; C7
    audio_note $3C, $09, $6                            ;; 05:6ee6  ; C#7
    audio_note $3E, $09, $4                            ;; 05:6ee8  ; D#7
    audio_note $40, $09, $6                            ;; 05:6eea  ; F7
    audio_note $41, $09, $6                            ;; 05:6eec  ; F#7
    audio_note $43, $09, $4                            ;; 05:6eee  ; G#7
    audio_note $43, $09, $7                            ;; 05:6ef0  ; G#7
    audio_note $41, $09, $4                            ;; 05:6ef2  ; F#7
    audio_note $41, $09, $6                            ;; 05:6ef4  ; F#7
    audio_note $44, $09, $6                            ;; 05:6ef6  ; A7
    audio_note $44, $09, $6                            ;; 05:6ef8  ; A7
    audio_note $43, $09, $4                            ;; 05:6efa  ; G#7
    audio_note $41, $09, $4                            ;; 05:6efc  ; F#7
    audio_note $40, $09, $4                            ;; 05:6efe  ; F7
    audio_note $41, $09, $6                            ;; 05:6f00  ; F#7
    audio_note $3C, $09, $6                            ;; 05:6f02  ; C#7
    audio_note $38, $09, $4                            ;; 05:6f04  ; A6
    audio_note $37, $09, $6                            ;; 05:6f06  ; G#6
    audio_note $35, $09, $6                            ;; 05:6f08  ; F#6
    audio_note $37, $09, $6                            ;; 05:6f0a  ; G#6
    audio_note $38, $09, $6                            ;; 05:6f0c  ; A6
    audio_note $35, $09, $4                            ;; 05:6f0e  ; F#6
    audio_note $38, $09, $4                            ;; 05:6f10  ; A6
    audio_note $3C, $09, $4                            ;; 05:6f12  ; C#7
    audio_note $39, $09, $C                            ;; 05:6f14  ; A#6
    audio_end_pattern                                  ;; 05:6f16

audio_05_6f17_Pattern64:
; pattern $64
    audio_note $40, $0D, $4                            ;; 05:6f17  ; F7
    audio_note $39, $0D, $4                            ;; 05:6f19  ; A#6
    audio_note $3C, $0D, $4                            ;; 05:6f1b  ; C#7
    audio_note $40, $0D, $4                            ;; 05:6f1d  ; F7
    audio_note $41, $0D, $4                            ;; 05:6f1f  ; F#7
    audio_note $39, $0D, $4                            ;; 05:6f21  ; A#6
    audio_note $3C, $0D, $4                            ;; 05:6f23  ; C#7
    audio_note $41, $0D, $4                            ;; 05:6f25  ; F#7
    audio_note $42, $0D, $4                            ;; 05:6f27  ; G7
    audio_note $39, $0D, $4                            ;; 05:6f29  ; A#6
    audio_note $3C, $0D, $4                            ;; 05:6f2b  ; C#7
    audio_note $42, $0D, $4                            ;; 05:6f2d  ; G7
    audio_note $41, $0D, $4                            ;; 05:6f2f  ; F#7
    audio_note $39, $0D, $4                            ;; 05:6f31  ; A#6
    audio_note $3C, $0D, $4                            ;; 05:6f33  ; C#7
    audio_note $41, $0D, $4                            ;; 05:6f35  ; F#7
    audio_end_pattern                                  ;; 05:6f37

audio_05_6f38_Pattern63:
; pattern $63
    audio_note $21, $11, $6                            ;; 05:6f38  ; A#4
    audio_note $21, $11, $6                            ;; 05:6f3a  ; A#4
    audio_note $2D, $11, $4                            ;; 05:6f3c  ; A#5
    audio_note $2B, $11, $6                            ;; 05:6f3e  ; G#5
    audio_note $28, $11, $6                            ;; 05:6f40  ; F5
    audio_note $26, $11, $4                            ;; 05:6f42  ; D#5
    audio_note $24, $11, $4                            ;; 05:6f44  ; C#5
    audio_note $26, $11, $4                            ;; 05:6f46  ; D#5
    audio_note $27, $11, $4                            ;; 05:6f48  ; E5
    audio_note $28, $11, $4                            ;; 05:6f4a  ; F5
    audio_note $26, $11, $4                            ;; 05:6f4c  ; D#5
    audio_note $24, $11, $4                            ;; 05:6f4e  ; C#5
    audio_end_pattern                                  ;; 05:6f50

audio_05_6f51_Pattern62:
; pattern $62
    audio_note $18, $01, $2                            ;; 05:6f51  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f53  ; G4
    audio_note $18, $01, $2                            ;; 05:6f55  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f57  ; G4
    audio_note $22, $06, $4                            ;; 05:6f59  ; B4
    audio_note $18, $01, $2                            ;; 05:6f5b  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f5d  ; G4
    audio_note $1A, $02, $2                            ;; 05:6f5f  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6f61  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f63  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f65  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f67  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f69  ; G4
    audio_note $18, $01, $2                            ;; 05:6f6b  ; C#4
    audio_note $22, $06, $4                            ;; 05:6f6d  ; B4
    audio_note $1E, $03, $2                            ;; 05:6f6f  ; G4
    audio_note $18, $01, $2                            ;; 05:6f71  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f73  ; G4
    audio_note $18, $01, $2                            ;; 05:6f75  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f77  ; G4
    audio_note $1E, $03, $4                            ;; 05:6f79  ; G4
    audio_note $1A, $02, $2                            ;; 05:6f7b  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6f7d  ; G4
    audio_note $18, $01, $2                            ;; 05:6f7f  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f81  ; G4
    audio_note $18, $01, $2                            ;; 05:6f83  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f85  ; G4
    audio_note $18, $01, $2                            ;; 05:6f87  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f89  ; G4
    audio_note $18, $01, $2                            ;; 05:6f8b  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6f8d  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f8f  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f91  ; G4
    audio_note $18, $01, $2                            ;; 05:6f93  ; C#4
    audio_note $22, $06, $2                            ;; 05:6f95  ; B4
    audio_note $1E, $03, $2                            ;; 05:6f97  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f99  ; G4
    audio_note $1A, $02, $2                            ;; 05:6f9b  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6f9d  ; G4
    audio_note $1E, $03, $2                            ;; 05:6f9f  ; G4
    audio_note $1E, $03, $2                            ;; 05:6fa1  ; G4
    audio_note $22, $06, $4                            ;; 05:6fa3  ; B4
    audio_note $18, $01, $2                            ;; 05:6fa5  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6fa7  ; G4
    audio_note $1E, $03, $2                            ;; 05:6fa9  ; G4
    audio_note $1E, $03, $2                            ;; 05:6fab  ; G4
    audio_note $18, $01, $2                            ;; 05:6fad  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6faf  ; G4
    audio_note $18, $01, $2                            ;; 05:6fb1  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6fb3  ; G4
    audio_note $18, $01, $2                            ;; 05:6fb5  ; C#4
    audio_note $1E, $03, $2                            ;; 05:6fb7  ; G4
    audio_note $1A, $02, $2                            ;; 05:6fb9  ; D#4
    audio_note $1E, $03, $2                            ;; 05:6fbb  ; G4
    audio_note $1E, $03, $2                            ;; 05:6fbd  ; G4
    audio_note $1E, $03, $2                            ;; 05:6fbf  ; G4
    audio_note $1A, $02, $2                            ;; 05:6fc1  ; D#4
    audio_note $1A, $02, $2                            ;; 05:6fc3  ; D#4
    audio_note $1A, $02, $2                            ;; 05:6fc5  ; D#4
    audio_note $22, $06, $2                            ;; 05:6fc7  ; B4
    audio_end_pattern                                  ;; 05:6fc9

audio_05_6fca_Song_Credits_Ch1:
; SONG_CREDITS (song $19) channel 1
; AUDIO_CMD_GOTO target
    audio_panning $FF                                  ;; 05:6fca
    audio_tempo $BE                                    ;; 05:6fcc
    audio_call $69, $E4, 1                             ;; 05:6fce
    audio_marker $01                                   ;; 05:6fd2
    audio_goto audio_05_6fca_Song_Credits_Ch1          ;; 05:6fd4

audio_05_6fd7_Song_Credits_Ch2:
; SONG_CREDITS (song $19) channel 2
; AUDIO_CMD_GOTO target
    audio_call $6A, $E4, 1                             ;; 05:6fd7
    audio_goto audio_05_6fd7_Song_Credits_Ch2          ;; 05:6fdb

audio_05_6fde_Song_Credits_Ch3:
; SONG_CREDITS (song $19) channel 3
; AUDIO_CMD_GOTO target
    audio_call $6B, $F0, 1                             ;; 05:6fde
    audio_goto audio_05_6fde_Song_Credits_Ch3          ;; 05:6fe2

audio_05_6fe5_Song_Credits_Ch4:
; SONG_CREDITS (song $19) channel 4
; AUDIO_CMD_GOTO target
    audio_note $1A, $02, $6                            ;; 05:6fe5  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6fe7  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6fe9  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6feb  ; D#4
    audio_note $1A, $02, $6                            ;; 05:6fed  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6fef  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6ff1  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6ff3  ; D#4
    audio_note $1A, $02, $6                            ;; 05:6ff5  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6ff7  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6ff9  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6ffb  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6ffd  ; D#4
    audio_note $1A, $02, $D                            ;; 05:6fff  ; D#4
    audio_note $1A, $02, $D                            ;; 05:7001  ; D#4
    audio_note $1A, $02, $D                            ;; 05:7003  ; D#4
    audio_note $1A, $02, $D                            ;; 05:7005  ; D#4
    audio_note $1A, $02, $D                            ;; 05:7007  ; D#4
    audio_goto audio_05_6fe5_Song_Credits_Ch4          ;; 05:7009

audio_05_700c_Pattern69:
; pattern $69
    audio_note $42, $08, $6                            ;; 05:700c  ; G7
    audio_note $42, $08, $D                            ;; 05:700e  ; G7
    audio_note $40, $08, $D                            ;; 05:7010  ; F7
    audio_note $3E, $08, $D                            ;; 05:7012  ; D#7
    audio_note $40, $08, $6                            ;; 05:7014  ; F7
    audio_note $40, $08, $D                            ;; 05:7016  ; F7
    audio_note $40, $08, $D                            ;; 05:7018  ; F7
    audio_note $40, $08, $D                            ;; 05:701a  ; F7
    audio_note $42, $08, $6                            ;; 05:701c  ; G7
    audio_note $42, $08, $D                            ;; 05:701e  ; G7
    audio_note $40, $08, $D                            ;; 05:7020  ; F7
    audio_note $3E, $08, $D                            ;; 05:7022  ; D#7
    audio_note $40, $08, $6                            ;; 05:7024  ; F7
    audio_note $40, $08, $D                            ;; 05:7026  ; F7
    audio_note $3C, $08, $D                            ;; 05:7028  ; C#7
    audio_note $40, $08, $D                            ;; 05:702a  ; F7
    audio_note $42, $08, $6                            ;; 05:702c  ; G7
    audio_note $42, $08, $D                            ;; 05:702e  ; G7
    audio_note $40, $08, $D                            ;; 05:7030  ; F7
    audio_note $42, $08, $D                            ;; 05:7032  ; G7
    audio_note $43, $08, $6                            ;; 05:7034  ; G#7
    audio_note $43, $08, $D                            ;; 05:7036  ; G#7
    audio_note $42, $08, $D                            ;; 05:7038  ; G7
    audio_note $43, $08, $D                            ;; 05:703a  ; G#7
    audio_note $45, $08, $6                            ;; 05:703c  ; A#7
    audio_note $45, $08, $D                            ;; 05:703e  ; A#7
    audio_note $43, $08, $D                            ;; 05:7040  ; G#7
    audio_note $41, $08, $D                            ;; 05:7042  ; F#7
    audio_note $43, $08, $E                            ;; 05:7044  ; G#7
    audio_note $40, $08, $E                            ;; 05:7046  ; F7
    audio_note $3C, $08, $E                            ;; 05:7048  ; C#7
    audio_note $45, $08, $6                            ;; 05:704a  ; A#7
    audio_note $45, $08, $D                            ;; 05:704c  ; A#7
    audio_note $43, $08, $D                            ;; 05:704e  ; G#7
    audio_note $41, $08, $D                            ;; 05:7050  ; F#7
    audio_note $43, $08, $E                            ;; 05:7052  ; G#7
    audio_note $40, $08, $E                            ;; 05:7054  ; F7
    audio_note $3C, $08, $E                            ;; 05:7056  ; C#7
    audio_note $3E, $08, $6                            ;; 05:7058  ; D#7
    audio_note $3E, $08, $D                            ;; 05:705a  ; D#7
    audio_note $3C, $08, $D                            ;; 05:705c  ; C#7
    audio_note $3E, $08, $D                            ;; 05:705e  ; D#7
    audio_note $40, $08, $6                            ;; 05:7060  ; F7
    audio_note $44, $08, $6                            ;; 05:7062  ; A7
    audio_note $47, $08, $D                            ;; 05:7064  ; C8
    audio_note $47, $08, $D                            ;; 05:7066  ; C8
    audio_note $47, $08, $D                            ;; 05:7068  ; C8
    audio_note $44, $08, $D                            ;; 05:706a  ; A7
    audio_note $44, $08, $D                            ;; 05:706c  ; A7
    audio_note $44, $08, $D                            ;; 05:706e  ; A7
    audio_note $47, $08, $D                            ;; 05:7070  ; C8
    audio_note $47, $08, $D                            ;; 05:7072  ; C8
    audio_note $47, $08, $D                            ;; 05:7074  ; C8
    audio_note $44, $08, $D                            ;; 05:7076  ; A7
    audio_note $40, $08, $D                            ;; 05:7078  ; F7
    audio_note $3B, $08, $D                            ;; 05:707a  ; C7
    audio_note $3B, $08, $D                            ;; 05:707c  ; C7
    audio_note $3B, $08, $D                            ;; 05:707e  ; C7
    audio_note $3B, $08, $D                            ;; 05:7080  ; C7
    audio_note $40, $08, $D                            ;; 05:7082  ; F7
    audio_note $3B, $08, $D                            ;; 05:7084  ; C7
    audio_note $40, $08, $D                            ;; 05:7086  ; F7
    audio_note $40, $08, $6                            ;; 05:7088  ; F7
    audio_note $40, $08, $D                            ;; 05:708a  ; F7
    audio_note $40, $08, $D                            ;; 05:708c  ; F7
    audio_note $40, $08, $D                            ;; 05:708e  ; F7
    audio_end_pattern                                  ;; 05:7090

audio_05_7091_Pattern6A:
; pattern $6A
    audio_note $39, $08, $6                            ;; 05:7091  ; A#6
    audio_note $39, $08, $6                            ;; 05:7093  ; A#6
    audio_note $3C, $08, $6                            ;; 05:7095  ; C#7
    audio_note $3C, $08, $D                            ;; 05:7097  ; C#7
    audio_note $3C, $08, $D                            ;; 05:7099  ; C#7
    audio_note $3C, $08, $D                            ;; 05:709b  ; C#7
    audio_note $39, $08, $6                            ;; 05:709d  ; A#6
    audio_note $39, $08, $6                            ;; 05:709f  ; A#6
    audio_note $3C, $08, $6                            ;; 05:70a1  ; C#7
    audio_note $3C, $08, $D                            ;; 05:70a3  ; C#7
    audio_note $39, $08, $D                            ;; 05:70a5  ; A#6
    audio_note $3C, $08, $D                            ;; 05:70a7  ; C#7
    audio_note $39, $08, $6                            ;; 05:70a9  ; A#6
    audio_note $39, $08, $6                            ;; 05:70ab  ; A#6
    audio_note $3B, $08, $6                            ;; 05:70ad  ; C7
    audio_note $3B, $08, $6                            ;; 05:70af  ; C7
    audio_note $3C, $08, $6                            ;; 05:70b1  ; C#7
    audio_note $3C, $08, $6                            ;; 05:70b3  ; C#7
    audio_note $40, $08, $E                            ;; 05:70b5  ; F7
    audio_note $3C, $08, $E                            ;; 05:70b7  ; C#7
    audio_note $37, $08, $E                            ;; 05:70b9  ; G#6
    audio_note $3C, $08, $6                            ;; 05:70bb  ; C#7
    audio_note $3C, $08, $6                            ;; 05:70bd  ; C#7
    audio_note $40, $08, $E                            ;; 05:70bf  ; F7
    audio_note $3C, $08, $E                            ;; 05:70c1  ; C#7
    audio_note $37, $08, $E                            ;; 05:70c3  ; G#6
    audio_note $39, $08, $6                            ;; 05:70c5  ; A#6
    audio_note $39, $08, $6                            ;; 05:70c7  ; A#6
    audio_note $3B, $08, $6                            ;; 05:70c9  ; C7
    audio_note $40, $08, $6                            ;; 05:70cb  ; F7
    audio_note $44, $08, $D                            ;; 05:70cd  ; A7
    audio_note $44, $08, $D                            ;; 05:70cf  ; A7
    audio_note $44, $08, $D                            ;; 05:70d1  ; A7
    audio_note $40, $08, $D                            ;; 05:70d3  ; F7
    audio_note $40, $08, $D                            ;; 05:70d5  ; F7
    audio_note $40, $08, $D                            ;; 05:70d7  ; F7
    audio_note $44, $08, $D                            ;; 05:70d9  ; A7
    audio_note $40, $08, $E                            ;; 05:70db  ; F7
    audio_note $40, $08, $D                            ;; 05:70dd  ; F7
    audio_note $3B, $08, $D                            ;; 05:70df  ; C7
    audio_note $38, $08, $D                            ;; 05:70e1  ; A6
    audio_note $38, $08, $D                            ;; 05:70e3  ; A6
    audio_note $38, $08, $D                            ;; 05:70e5  ; A6
    audio_note $38, $08, $D                            ;; 05:70e7  ; A6
    audio_note $38, $08, $D                            ;; 05:70e9  ; A6
    audio_note $38, $08, $D                            ;; 05:70eb  ; A6
    audio_note $38, $08, $D                            ;; 05:70ed  ; A6
    audio_note $38, $08, $6                            ;; 05:70ef  ; A6
    audio_note $3C, $08, $D                            ;; 05:70f1  ; C#7
    audio_note $3C, $08, $D                            ;; 05:70f3  ; C#7
    audio_note $3C, $08, $D                            ;; 05:70f5  ; C#7
    audio_end_pattern                                  ;; 05:70f7

audio_05_70f8_Pattern6B:
; pattern $6B
    audio_note $26, $11, $6                            ;; 05:70f8  ; D#5
    audio_note $26, $11, $D                            ;; 05:70fa  ; D#5
    audio_note $24, $11, $D                            ;; 05:70fc  ; C#5
    audio_note $23, $11, $D                            ;; 05:70fe  ; C5
    audio_note $21, $11, $6                            ;; 05:7100  ; A#4
    audio_note $21, $11, $D                            ;; 05:7102  ; A#4
    audio_note $21, $11, $D                            ;; 05:7104  ; A#4
    audio_note $21, $11, $D                            ;; 05:7106  ; A#4
    audio_note $26, $11, $6                            ;; 05:7108  ; D#5
    audio_note $26, $11, $D                            ;; 05:710a  ; D#5
    audio_note $24, $11, $D                            ;; 05:710c  ; C#5
    audio_note $23, $11, $D                            ;; 05:710e  ; C5
    audio_note $21, $11, $6                            ;; 05:7110  ; A#4
    audio_note $21, $11, $D                            ;; 05:7112  ; A#4
    audio_note $21, $11, $D                            ;; 05:7114  ; A#4
    audio_note $21, $11, $D                            ;; 05:7116  ; A#4
    audio_note $26, $11, $6                            ;; 05:7118  ; D#5
    audio_note $26, $11, $D                            ;; 05:711a  ; D#5
    audio_note $26, $11, $D                            ;; 05:711c  ; D#5
    audio_note $26, $11, $D                            ;; 05:711e  ; D#5
    audio_note $28, $11, $6                            ;; 05:7120  ; F5
    audio_note $28, $11, $D                            ;; 05:7122  ; F5
    audio_note $28, $11, $D                            ;; 05:7124  ; F5
    audio_note $28, $11, $D                            ;; 05:7126  ; F5
    audio_note $29, $11, $6                            ;; 05:7128  ; F#5
    audio_note $29, $11, $D                            ;; 05:712a  ; F#5
    audio_note $28, $11, $D                            ;; 05:712c  ; F5
    audio_note $26, $11, $D                            ;; 05:712e  ; D#5
    audio_note $24, $11, $E                            ;; 05:7130  ; C#5
    audio_note $24, $11, $E                            ;; 05:7132  ; C#5
    audio_note $24, $11, $E                            ;; 05:7134  ; C#5
    audio_note $29, $11, $6                            ;; 05:7136  ; F#5
    audio_note $29, $11, $D                            ;; 05:7138  ; F#5
    audio_note $28, $11, $D                            ;; 05:713a  ; F5
    audio_note $26, $11, $D                            ;; 05:713c  ; D#5
    audio_note $24, $11, $E                            ;; 05:713e  ; C#5
    audio_note $24, $11, $E                            ;; 05:7140  ; C#5
    audio_note $24, $11, $E                            ;; 05:7142  ; C#5
    audio_note $26, $11, $6                            ;; 05:7144  ; D#5
    audio_note $26, $11, $D                            ;; 05:7146  ; D#5
    audio_note $26, $11, $D                            ;; 05:7148  ; D#5
    audio_note $26, $11, $D                            ;; 05:714a  ; D#5
    audio_note $28, $11, $6                            ;; 05:714c  ; F5
    audio_note $28, $11, $6                            ;; 05:714e  ; F5
    audio_note $28, $11, $D                            ;; 05:7150  ; F5
    audio_note $28, $11, $D                            ;; 05:7152  ; F5
    audio_note $28, $11, $D                            ;; 05:7154  ; F5
    audio_note $28, $11, $D                            ;; 05:7156  ; F5
    audio_note $28, $11, $D                            ;; 05:7158  ; F5
    audio_note $28, $11, $D                            ;; 05:715a  ; F5
    audio_note $28, $11, $D                            ;; 05:715c  ; F5
    audio_note $28, $11, $D                            ;; 05:715e  ; F5
    audio_note $28, $11, $D                            ;; 05:7160  ; F5
    audio_note $28, $11, $D                            ;; 05:7162  ; F5
    audio_note $28, $11, $D                            ;; 05:7164  ; F5
    audio_note $28, $11, $D                            ;; 05:7166  ; F5
    audio_note $28, $11, $D                            ;; 05:7168  ; F5
    audio_note $28, $11, $D                            ;; 05:716a  ; F5
    audio_note $28, $11, $D                            ;; 05:716c  ; F5
    audio_note $28, $11, $D                            ;; 05:716e  ; F5
    audio_note $28, $11, $D                            ;; 05:7170  ; F5
    audio_note $28, $11, $D                            ;; 05:7172  ; F5
    audio_note $28, $11, $6                            ;; 05:7174  ; F5
    audio_note $21, $11, $D                            ;; 05:7176  ; A#4
    audio_note $21, $11, $D                            ;; 05:7178  ; A#4
    audio_note $21, $11, $D                            ;; 05:717a  ; A#4
    audio_end_pattern                                  ;; 05:717c

data_05_717d_SongTable:
; 10 songs, AUDIO_SONG_SIZE bytes each: one starting pattern per hardware
; channel, then the note-length table those patterns index. The low nibble of a
; SONG_* id picks the row; the high nibble already picked this bank
    ; SONG_UNK10
    audio_song audio_05_5436_Song_Unk10_Ch1, audio_05_543f_Song_Unk10_Ch2, audio_05_5442_Song_Unk10_Ch3, audio_05_5445_Song_Unk10_Ch4, audio_05_71e1_NoteLengths  ;; 05:717d
    ; SONG_BOSS
    audio_song audio_05_5448_Song_Boss_Ch1, audio_05_5475_Song_Boss_Ch2, audio_05_54a0_Song_Boss_Ch3, audio_05_54c3_Song_Boss_Ch4, audio_05_71e1_NoteLengths  ;; 05:7187
    ; SONG_MYSTERY_TV
    audio_song audio_05_59db_Song_MysteryTv_Ch1, audio_05_5a18_Song_MysteryTv_Ch2, audio_05_5a3f_Song_MysteryTv_Ch3, audio_05_5a6a_Song_MysteryTv_Ch4, audio_05_71e1_NoteLengths  ;; 05:7191
    ; SONG_MISSION_SUCCESS
    audio_song audio_05_5fc8_Song_MissionSuccess_Ch1, audio_05_5fd9_Song_MissionSuccess_Ch2, audio_05_5fe4_Song_MissionSuccess_Ch3, audio_05_5feb_Song_MissionSuccess_Ch4, audio_05_71e1_NoteLengths  ;; 05:719b
    ; SONG_ANIME_CHANNEL
    audio_song audio_05_6109_Song_AnimeChannel_Ch1, audio_05_613e_Song_AnimeChannel_Ch2, audio_05_616d_Song_AnimeChannel_Ch3, audio_05_619c_Song_AnimeChannel_Ch4, audio_05_71e1_NoteLengths  ;; 05:71a5
    ; SONG_GAME_OVER_OR_TIME_UP
    audio_song audio_05_653c_Song_GameOverOrTimeUp_Ch1, audio_05_6549_Song_GameOverOrTimeUp_Ch2, audio_05_6550_Song_GameOverOrTimeUp_Ch3, audio_05_6557_Song_GameOverOrTimeUp_Ch4, audio_05_71e1_NoteLengths  ;; 05:71af
    ; SONG_BONUS_CHANNEL
    audio_song audio_05_660b_Song_BonusChannel_Ch1, audio_05_6620_Song_BonusChannel_Ch2, audio_05_6647_Song_BonusChannel_Ch3, audio_05_666e_Song_BonusChannel_Ch4, audio_05_71e1_NoteLengths  ;; 05:71b9
    ; SONG_SUPERHERO_SHOW
    audio_song audio_05_68a2_Song_SuperheroShow_Ch1, audio_05_68e5_Song_SuperheroShow_Ch2, audio_05_6984_Song_SuperheroShow_Ch3, audio_05_6a23_Song_SuperheroShow_Ch4, audio_05_71e1_NoteLengths  ;; 05:71c3
    ; SONG_CHANNEL_Z
    audio_song audio_05_6d91_Song_ChannelZ_Ch1, audio_05_6dae_Song_ChannelZ_Ch2, audio_05_6dd9_Song_ChannelZ_Ch3, audio_05_6e04_Song_ChannelZ_Ch4, audio_05_71e1_NoteLengths  ;; 05:71cd
    ; SONG_CREDITS
    audio_song audio_05_6fca_Song_Credits_Ch1, audio_05_6fd7_Song_Credits_Ch2, audio_05_6fde_Song_Credits_Ch3, audio_05_6fe5_Song_Credits_Ch4, audio_05_71e1_NoteLengths  ;; 05:71d7

audio_05_71e1_NoteLengths:
; note lengths for song $10
; note lengths for song $11
; note lengths for song $12
; note lengths for song $13
; note lengths for song $14
; note lengths for song $15
; note lengths for song $16
; note lengths for song $17
; note lengths for song $18
; note lengths for song $19
    db   $03, $04, $06, $09, $0c, $12, $18, $24        ;; 05:71e1  ; ticks per note-length index $0-$F
    db   $30, $48, $60, $90, $c0, $08, $10, $20        ;; 05:71e9

data_05_71f1_InstrumentPointers:
; AUDIO_INSTRUMENT_COUNT instruments. A note's parameter byte names one of the
; first 16; AUDIO_NOTE_INSTRUMENT_BANK on the note byte reaches the other 16
    dw   audio_05_7231_Instrument00                    ;; 05:71f1  ; instrument $00
    dw   audio_05_723d_Instrument01                    ;; 05:71f3  ; instrument $01
    dw   audio_05_7249_Instrument02                    ;; 05:71f5  ; instrument $02
    dw   audio_05_7255_Instrument03                    ;; 05:71f7  ; instrument $03
    dw   audio_05_7261_Instrument04                    ;; 05:71f9  ; instrument $04
    dw   audio_05_726d_Instrument05                    ;; 05:71fb  ; instrument $05
    dw   audio_05_7279_Instrument06                    ;; 05:71fd  ; instrument $06
    dw   audio_05_7285_Instrument07                    ;; 05:71ff  ; instrument $07
    dw   audio_05_7291_Instrument08                    ;; 05:7201  ; instrument $08
    dw   audio_05_729d_Instrument09                    ;; 05:7203  ; instrument $09
    dw   audio_05_72a9_Instrument0A                    ;; 05:7205  ; instrument $0A
    dw   audio_05_72b5_Instrument0B                    ;; 05:7207  ; instrument $0B
    dw   audio_05_72c1_Instrument0C                    ;; 05:7209  ; instrument $0C
    dw   audio_05_72cd_Instrument0D                    ;; 05:720b  ; instrument $0D
    dw   audio_05_72d9_Instrument0E                    ;; 05:720d  ; instrument $0E
    dw   audio_05_72e5_Instrument0F                    ;; 05:720f  ; instrument $0F
    dw   audio_05_72f1_Instrument10                    ;; 05:7211  ; instrument $10
    dw   audio_05_72fd_Instrument11                    ;; 05:7213  ; instrument $11
    dw   audio_05_7309_Instrument12                    ;; 05:7215  ; instrument $12
    dw   audio_05_7315_Instrument13                    ;; 05:7217  ; instrument $13
    dw   audio_05_7321_Instrument14                    ;; 05:7219  ; instrument $14
    dw   audio_05_732d_Instrument15                    ;; 05:721b  ; instrument $15
    dw   audio_05_7339_Instrument16                    ;; 05:721d  ; instrument $16
    dw   audio_05_7345_Instrument17                    ;; 05:721f  ; instrument $17
    dw   audio_05_7351_Instrument18                    ;; 05:7221  ; instrument $18
    dw   audio_05_735d_Instrument19                    ;; 05:7223  ; instrument $19
    dw   audio_05_7369_Instrument1A                    ;; 05:7225  ; instrument $1A
    dw   audio_05_7375_Instrument1B                    ;; 05:7227  ; instrument $1B
    dw   audio_05_7381_Instrument1C                    ;; 05:7229  ; instrument $1C
    dw   audio_05_738d_Instrument1D                    ;; 05:722b  ; instrument $1D
    dw   audio_05_7399_Instrument1E                    ;; 05:722d  ; instrument $1E
    dw   audio_05_73a5_Instrument1F                    ;; 05:722f  ; instrument $1F

audio_05_7231_Instrument00:
; instrument $00
    audio_instrument $80, $00, $02, $00, $0000, $00, $0000, $00, $0000  ;; 05:7231

audio_05_723d_Instrument01:
; instrument $01
    audio_instrument $C0, $BD, $00, $01, audio_05_73b1_Envelope, $01, audio_05_7552_PitchSlide, $00, $0000  ;; 05:723d

audio_05_7249_Instrument02:
; instrument $02
    audio_instrument $80, $80, $00, $01, audio_05_73ba_Envelope, $01, audio_05_7555_PitchSlide, $00, $0000  ;; 05:7249

audio_05_7255_Instrument03:
; instrument $03
    audio_instrument $C0, $BB, $61, $00, $0000, $01, audio_05_7576_PitchSlide, $00, $0000  ;; 05:7255

audio_05_7261_Instrument04:
; instrument $04
    audio_instrument $80, $80, $00, $01, audio_05_73c7_Envelope, $00, $0000, $01, audio_05_75eb_Arpeggio  ;; 05:7261

audio_05_726d_Instrument05:
; instrument $05
    audio_instrument $80, $00, $00, $01, audio_05_73d4_Envelope, $01, audio_05_7579_PitchSlide, $00, $0000  ;; 05:726d

audio_05_7279_Instrument06:
; instrument $06
    audio_instrument $80, $80, $00, $01, audio_05_73e1_Envelope, $01, audio_05_757e_PitchSlide, $00, $0000  ;; 05:7279

audio_05_7285_Instrument07:
; instrument $07
    audio_instrument $80, $80, $00, $01, audio_05_73ec_Envelope, $00, $0000, $01, audio_05_764e_Arpeggio  ;; 05:7285

audio_05_7291_Instrument08:
; instrument $08
    audio_instrument $80, $80, $00, $01, audio_05_73fb_Envelope, $00, $0000, $01, audio_05_766d_Arpeggio  ;; 05:7291

audio_05_729d_Instrument09:
; instrument $09
    audio_instrument $80, $80, $00, $01, audio_05_7423_Envelope, $00, $0000, $01, audio_05_76bf_Arpeggio  ;; 05:729d

audio_05_72a9_Instrument0A:
; instrument $0A
    audio_instrument $80, $80, $00, $01, audio_05_7484_Envelope, $04, audio_05_7589_PitchSlide, $00, $0000  ;; 05:72a9

audio_05_72b5_Instrument0B:
; instrument $0B
    audio_instrument $80, $40, $00, $01, audio_05_7491_Envelope, $04, audio_05_7589_PitchSlide, $05, audio_05_76bf_Arpeggio  ;; 05:72b5

audio_05_72c1_Instrument0C:
; instrument $0C
    audio_instrument $80, $80, $00, $01, audio_05_74a0_Envelope, $0C, audio_05_7594_PitchSlide, $00, $0000  ;; 05:72c1

audio_05_72cd_Instrument0D:
; instrument $0D
    audio_instrument $80, $00, $00, $01, audio_05_74b7_Envelope, $01, audio_05_7589_PitchSlide, $00, $0000  ;; 05:72cd

audio_05_72d9_Instrument0E:
; instrument $0E
    audio_instrument $80, $40, $00, $01, audio_05_74c4_Envelope, $02, audio_05_75bf_PitchSlide, $00, $0000  ;; 05:72d9

audio_05_72e5_Instrument0F:
; instrument $0F
    audio_instrument $80, $80, $00, $01, audio_05_74d3_Envelope, $0C, audio_05_7594_PitchSlide, $00, $0000  ;; 05:72e5

audio_05_72f1_Instrument10:
; instrument $10
    audio_instrument $C0, $00, $00, $01, audio_05_74e6_Envelope, $01, audio_05_75ca_PitchSlide, $00, $0000  ;; 05:72f1

audio_05_72fd_Instrument11:
; instrument $11
    audio_instrument $C0, $00, $00, $01, audio_05_74ef_Envelope, $01, audio_05_75ca_PitchSlide, $00, $0000  ;; 05:72fd

audio_05_7309_Instrument12:
; instrument $12
    audio_instrument $C0, $00, $00, $01, audio_05_74f8_Envelope, $01, audio_05_75ca_PitchSlide, $00, $0000  ;; 05:7309

audio_05_7315_Instrument13:
; instrument $13
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_05_76ce_Arpeggio  ;; 05:7315

audio_05_7321_Instrument14:
; instrument $14
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_05_76dd_Arpeggio  ;; 05:7321

audio_05_732d_Instrument15:
; instrument $15
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_05_76ec_Arpeggio  ;; 05:732d

audio_05_7339_Instrument16:
; instrument $16
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_05_76fb_Arpeggio  ;; 05:7339

audio_05_7345_Instrument17:
; instrument $17
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_05_770a_Arpeggio  ;; 05:7345

audio_05_7351_Instrument18:
; instrument $18
    audio_instrument $80, $40, $47, $00, $0000, $00, $0000, $01, audio_05_7719_Arpeggio  ;; 05:7351

audio_05_735d_Instrument19:
; instrument $19
    audio_instrument $C0, $00, $00, $01, audio_05_7503_Envelope, $01, audio_05_75ca_PitchSlide, $00, $0000  ;; 05:735d

audio_05_7369_Instrument1A:
; instrument $1A
    audio_instrument $80, $40, $00, $01, audio_05_7515_Envelope, $00, $0000, $01, audio_05_7728_Arpeggio  ;; 05:7369

audio_05_7375_Instrument1B:
; instrument $1B
    audio_instrument $80, $80, $00, $01, audio_05_7522_Envelope, $01, audio_05_75d5_PitchSlide, $00, $0000  ;; 05:7375

audio_05_7381_Instrument1C:
; instrument $1C
    audio_instrument $80, $00, $30, $00, $0000, $01, audio_05_7594_PitchSlide, $01, audio_05_7737_Arpeggio  ;; 05:7381

audio_05_738d_Instrument1D:
; instrument $1D
    audio_instrument $80, $00, $30, $00, $0000, $01, audio_05_7594_PitchSlide, $01, audio_05_775a_Arpeggio  ;; 05:738d

audio_05_7399_Instrument1E:
; instrument $1E
    audio_instrument $C0, $80, $00, $01, audio_05_7543_Envelope, $00, $0000, $01, audio_05_76ce_Arpeggio  ;; 05:7399

audio_05_73a5_Instrument1F:
; instrument $1F
    audio_instrument $80, $80, $00, $01, audio_05_7543_Envelope, $00, $0000, $01, audio_05_76fb_Arpeggio  ;; 05:73a5

audio_05_73b1_Envelope:
; volume envelope of instrument $01
    audio_env $F0, 1                                   ;; 05:73b1
    audio_env $00, 1                                   ;; 05:73b3
    audio_env $70, 1                                   ;; 05:73b5
    audio_env $00, 1                                   ;; 05:73b7
    audio_env_end                                      ;; 05:73b9

audio_05_73ba_Envelope:
; volume envelope of instrument $02
    audio_env $C0, 1                                   ;; 05:73ba
    audio_env $40, 2                                   ;; 05:73bc
    audio_env $30, 1                                   ;; 05:73be
    audio_env $20, 2                                   ;; 05:73c0
    audio_env $10, 5                                   ;; 05:73c2
    audio_env $00, 1                                   ;; 05:73c4
    audio_env_end                                      ;; 05:73c6

audio_05_73c7_Envelope:
; volume envelope of instrument $04
    audio_env $20, 8                                   ;; 05:73c7
    audio_env $50, 8                                   ;; 05:73c9
    audio_env $90, 4                                   ;; 05:73cb
    audio_env $40, 64                                  ;; 05:73cd
    audio_env $20, 32                                  ;; 05:73cf
    audio_env $00, 1                                   ;; 05:73d1
    audio_env_end                                      ;; 05:73d3

audio_05_73d4_Envelope:
; volume envelope of instrument $05
    audio_env $50, 2                                   ;; 05:73d4
    audio_env $30, 4                                   ;; 05:73d6
    audio_env $20, 8                                   ;; 05:73d8
    audio_env $10, 2                                   ;; 05:73da
    audio_env $10, 2                                   ;; 05:73dc
    audio_env $00, 1                                   ;; 05:73de
    audio_env_end                                      ;; 05:73e0

audio_05_73e1_Envelope:
; volume envelope of instrument $06
    audio_env $40, 1                                   ;; 05:73e1
    audio_env $30, 10                                  ;; 05:73e3
    audio_env $20, 10                                  ;; 05:73e5
    audio_env $10, 10                                  ;; 05:73e7
    audio_env $00, 1                                   ;; 05:73e9
    audio_env_end                                      ;; 05:73eb

audio_05_73ec_Envelope:
; volume envelope of instrument $07
    audio_env $F0, 2                                   ;; 05:73ec
    audio_env $80, 2                                   ;; 05:73ee
    audio_env $60, 2                                   ;; 05:73f0
    audio_env $30, 1                                   ;; 05:73f2
    audio_env $20, 2                                   ;; 05:73f4
    audio_env $10, 2                                   ;; 05:73f6
    audio_env $00, 1                                   ;; 05:73f8
    audio_env_end                                      ;; 05:73fa

audio_05_73fb_Envelope:
; volume envelope of instrument $08
    audio_env $70, 1                                   ;; 05:73fb
    audio_env $30, 2                                   ;; 05:73fd
    audio_env $60, 1                                   ;; 05:73ff
    audio_env $30, 2                                   ;; 05:7401
    audio_env $50, 1                                   ;; 05:7403
    audio_env $20, 2                                   ;; 05:7405
    audio_env $40, 1                                   ;; 05:7407
    audio_env $20, 2                                   ;; 05:7409
    audio_env $30, 1                                   ;; 05:740b
    audio_env $10, 2                                   ;; 05:740d
    audio_env $20, 1                                   ;; 05:740f
    audio_env $10, 2                                   ;; 05:7411
    audio_env $10, 40                                  ;; 05:7413
    audio_env $00, 1                                   ;; 05:7415
    audio_env_end                                      ;; 05:7417

data_05_7418_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $80, $01, $40, $01, $00, $02, $10, $01        ;; 05:7418
    db   $00, $01, $ff                                 ;; 05:7420

audio_05_7423_Envelope:
; volume envelope of instrument $09
    audio_env $40, 4                                   ;; 05:7423
    audio_env $00, 4                                   ;; 05:7425
    audio_env $40, 4                                   ;; 05:7427
    audio_env $00, 4                                   ;; 05:7429
    audio_env $50, 4                                   ;; 05:742b
    audio_env $00, 4                                   ;; 05:742d
    audio_env $50, 4                                   ;; 05:742f
    audio_env $00, 4                                   ;; 05:7431
    audio_env $40, 4                                   ;; 05:7433
    audio_env $00, 4                                   ;; 05:7435
    audio_env $40, 4                                   ;; 05:7437
    audio_env $00, 4                                   ;; 05:7439
    audio_env $00, 4                                   ;; 05:743b
    audio_env $30, 4                                   ;; 05:743d
    audio_env $00, 4                                   ;; 05:743f
    audio_env $30, 4                                   ;; 05:7441
    audio_env $00, 4                                   ;; 05:7443
    audio_env $30, 4                                   ;; 05:7445
    audio_env $00, 4                                   ;; 05:7447
    audio_env $30, 4                                   ;; 05:7449
    audio_env $00, 4                                   ;; 05:744b
    audio_env $30, 4                                   ;; 05:744d
    audio_env $00, 4                                   ;; 05:744f
    audio_env $30, 4                                   ;; 05:7451
    audio_env $00, 4                                   ;; 05:7453
    audio_env $20, 4                                   ;; 05:7455
    audio_env $00, 4                                   ;; 05:7457
    audio_env $20, 4                                   ;; 05:7459
    audio_env $00, 5                                   ;; 05:745b
    audio_env $20, 5                                   ;; 05:745d
    audio_env $00, 5                                   ;; 05:745f
    audio_env $20, 5                                   ;; 05:7461
    audio_env $00, 5                                   ;; 05:7463
    audio_env $10, 5                                   ;; 05:7465
    audio_env $00, 5                                   ;; 05:7467
    audio_env $10, 5                                   ;; 05:7469
    audio_env $00, 6                                   ;; 05:746b
    audio_env $10, 6                                   ;; 05:746d
    audio_env $00, 6                                   ;; 05:746f
    audio_env $10, 6                                   ;; 05:7471
    audio_env $00, 6                                   ;; 05:7473
    audio_env $10, 6                                   ;; 05:7475
    audio_env $00, 6                                   ;; 05:7477
    audio_env $10, 6                                   ;; 05:7479
    audio_env $00, 6                                   ;; 05:747b
    audio_env $10, 6                                   ;; 05:747d
    audio_env $00, 6                                   ;; 05:747f
    audio_env $10, 6                                   ;; 05:7481
    audio_env_end                                      ;; 05:7483

audio_05_7484_Envelope:
; volume envelope of instrument $0A
    audio_env $60, 1                                   ;; 05:7484
    audio_env $40, 4                                   ;; 05:7486
    audio_env $30, 20                                  ;; 05:7488
    audio_env $20, 60                                  ;; 05:748a
    audio_env $10, 60                                  ;; 05:748c
    audio_env $00, 1                                   ;; 05:748e
    audio_env_end                                      ;; 05:7490

audio_05_7491_Envelope:
; volume envelope of instrument $0B
    audio_env $50, 2                                   ;; 05:7491
    audio_env $40, 6                                   ;; 05:7493
    audio_env $30, 30                                  ;; 05:7495
    audio_env $20, 36                                  ;; 05:7497
    audio_env $10, 32                                  ;; 05:7499
    audio_env $10, 64                                  ;; 05:749b
    audio_env $00, 1                                   ;; 05:749d
    audio_env_end                                      ;; 05:749f

audio_05_74a0_Envelope:
; volume envelope of instrument $0C
    audio_env $10, 2                                   ;; 05:74a0
    audio_env $20, 1                                   ;; 05:74a2
    audio_env $30, 1                                   ;; 05:74a4
    audio_env $60, 3                                   ;; 05:74a6
    audio_env $50, 50                                  ;; 05:74a8
    audio_env $50, 10                                  ;; 05:74aa
    audio_env $40, 10                                  ;; 05:74ac
    audio_env $30, 10                                  ;; 05:74ae
    audio_env $20, 30                                  ;; 05:74b0
    audio_env $10, 30                                  ;; 05:74b2
    audio_env $00, 1                                   ;; 05:74b4
    audio_env_end                                      ;; 05:74b6

audio_05_74b7_Envelope:
; volume envelope of instrument $0D
    audio_env $40, 1                                   ;; 05:74b7
    audio_env $30, 12                                  ;; 05:74b9
    audio_env $20, 20                                  ;; 05:74bb
    audio_env $10, 60                                  ;; 05:74bd
    audio_env $10, 60                                  ;; 05:74bf
    audio_env $00, 1                                   ;; 05:74c1
    audio_env_end                                      ;; 05:74c3

audio_05_74c4_Envelope:
; volume envelope of instrument $0E
    audio_env $60, 2                                   ;; 05:74c4
    audio_env $50, 2                                   ;; 05:74c6
    audio_env $40, 3                                   ;; 05:74c8
    audio_env $30, 10                                  ;; 05:74ca
    audio_env $20, 40                                  ;; 05:74cc
    audio_env $10, 40                                  ;; 05:74ce
    audio_env $00, 1                                   ;; 05:74d0
    audio_env_end                                      ;; 05:74d2

audio_05_74d3_Envelope:
; volume envelope of instrument $0F
    audio_env $10, 2                                   ;; 05:74d3
    audio_env $20, 1                                   ;; 05:74d5
    audio_env $30, 1                                   ;; 05:74d7
    audio_env $40, 20                                  ;; 05:74d9
    audio_env $30, 80                                  ;; 05:74db
    audio_env $20, 10                                  ;; 05:74dd
    audio_env $10, 10                                  ;; 05:74df
    audio_env $10, 10                                  ;; 05:74e1
    audio_env $00, 1                                   ;; 05:74e3
    audio_env_end                                      ;; 05:74e5

audio_05_74e6_Envelope:
; volume envelope of instrument $10
    audio_env $20, 10                                  ;; 05:74e6
    audio_env $40, 90                                  ;; 05:74e8
    audio_env $60, 240                                 ;; 05:74ea
    audio_env $00, 1                                   ;; 05:74ec
    audio_env_end                                      ;; 05:74ee

audio_05_74ef_Envelope:
; volume envelope of instrument $11
    audio_env $20, 4                                   ;; 05:74ef
    audio_env $40, 20                                  ;; 05:74f1
    audio_env $60, 10                                  ;; 05:74f3
    audio_env $00, 1                                   ;; 05:74f5
    audio_env_end                                      ;; 05:74f7

audio_05_74f8_Envelope:
; volume envelope of instrument $12
    audio_env $20, 4                                   ;; 05:74f8
    audio_env $40, 80                                  ;; 05:74fa
    audio_env $60, 240                                 ;; 05:74fc
    audio_env $60, 240                                 ;; 05:74fe
    audio_env $00, 1                                   ;; 05:7500
    audio_env_end                                      ;; 05:7502

audio_05_7503_Envelope:
; volume envelope of instrument $19
    audio_env $20, 1                                   ;; 05:7503
    audio_env $40, 20                                  ;; 05:7505
    audio_env $60, 100                                 ;; 05:7507
    audio_env $00, 1                                   ;; 05:7509
    audio_env_end                                      ;; 05:750b

data_05_750c_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $20, $04, $40, $c8, $40, $64, $60, $28        ;; 05:750c
    db   $ff                                           ;; 05:7514

audio_05_7515_Envelope:
; volume envelope of instrument $1A
    audio_env $50, 4                                   ;; 05:7515
    audio_env $40, 10                                  ;; 05:7517
    audio_env $30, 20                                  ;; 05:7519
    audio_env $20, 40                                  ;; 05:751b
    audio_env $10, 30                                  ;; 05:751d
    audio_env $00, 1                                   ;; 05:751f
    audio_env_end                                      ;; 05:7521

audio_05_7522_Envelope:
; volume envelope of instrument $1B
    audio_env $60, 1                                   ;; 05:7522
    audio_env $40, 58                                  ;; 05:7524
    audio_env $20, 50                                  ;; 05:7526
    audio_env $00, 1                                   ;; 05:7528
    audio_env_end                                      ;; 05:752a

data_05_752b_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $20, $05, $30, $05, $40, $05, $70, $c8        ;; 05:752b
    db   $50, $c8, $30, $c8, $00, $01, $ff, $c0        ;; 05:7533
    db   $01, $00, $01, $30, $01, $00, $01, $ff        ;; 05:753b

audio_05_7543_Envelope:
; volume envelope of instrument $1E
; volume envelope of instrument $1F
    audio_env $20, 10                                  ;; 05:7543
    audio_env $10, 10                                  ;; 05:7545
    audio_env $20, 10                                  ;; 05:7547
    audio_env $30, 10                                  ;; 05:7549
    audio_env $40, 20                                  ;; 05:754b
    audio_env $50, 100                                 ;; 05:754d
    audio_env $60, 100                                 ;; 05:754f
    audio_env_end                                      ;; 05:7551

audio_05_7552_PitchSlide:
; pitch slide of instrument $01
    audio_pitch 97, 200                                ;; 05:7552
    audio_pitch_end                                    ;; 05:7554

audio_05_7555_PitchSlide:
; pitch slide of instrument $02
    audio_pitch 55, 2                                  ;; 05:7555
    audio_pitch 100, 2                                 ;; 05:7557
    audio_pitch 34, 1                                  ;; 05:7559
    audio_pitch 55, 1                                  ;; 05:755b
    audio_pitch 34, 1                                  ;; 05:755d
    audio_pitch 55, 1                                  ;; 05:755f
    audio_pitch 34, 1                                  ;; 05:7561
    audio_pitch 34, 1                                  ;; 05:7563
    audio_pitch 55, 1                                  ;; 05:7565
    audio_pitch 34, 1                                  ;; 05:7567
    audio_pitch 55, 1                                  ;; 05:7569
    audio_pitch 34, 1                                  ;; 05:756b
    audio_pitch 55, 1                                  ;; 05:756d
    audio_pitch 34, 1                                  ;; 05:756f
    audio_pitch 55, 1                                  ;; 05:7571
    audio_pitch 34, 16                                 ;; 05:7573
    audio_pitch_end                                    ;; 05:7575

audio_05_7576_PitchSlide:
; pitch slide of instrument $03
    audio_pitch 18, 200                                ;; 05:7576
    audio_pitch_end                                    ;; 05:7578

audio_05_7579_PitchSlide:
; pitch slide of instrument $05
    audio_pitch 34, 1                                  ;; 05:7579
    audio_pitch 16, 200                                ;; 05:757b
    audio_pitch_end                                    ;; 05:757d

audio_05_757e_PitchSlide:
; pitch slide of instrument $06
    audio_pitch 33, 200                                ;; 05:757e
    audio_pitch 34, 200                                ;; 05:7580
    audio_pitch 35, 10                                 ;; 05:7582
    audio_pitch 67, 10                                 ;; 05:7584
    audio_pitch 68, 200                                ;; 05:7586
    audio_pitch_end                                    ;; 05:7588

audio_05_7589_PitchSlide:
; pitch slide of instrument $0A
; pitch slide of instrument $0B
; pitch slide of instrument $0D
    audio_pitch 2, 3                                   ;; 05:7589
    audio_pitch -2, 3                                  ;; 05:758b
    audio_pitch -2, 3                                  ;; 05:758d
    audio_pitch 2, 3                                   ;; 05:758f
    audio_pitch_loop audio_05_7589_PitchSlide          ;; 05:7591

audio_05_7594_PitchSlide:
; pitch slide of instrument $0C
; pitch slide of instrument $0F
; pitch slide of instrument $1C
; pitch slide of instrument $1D
    audio_pitch 1, 3                                   ;; 05:7594
    audio_pitch -1, 3                                  ;; 05:7596
    audio_pitch -1, 3                                  ;; 05:7598
    audio_pitch 1, 3                                   ;; 05:759a
    audio_pitch 1, 3                                   ;; 05:759c
    audio_pitch -1, 3                                  ;; 05:759e
    audio_pitch -1, 3                                  ;; 05:75a0
    audio_pitch 1, 3                                   ;; 05:75a2
    audio_pitch 1, 3                                   ;; 05:75a4
    audio_pitch -1, 3                                  ;; 05:75a6
    audio_pitch -1, 3                                  ;; 05:75a8
    audio_pitch 1, 3                                   ;; 05:75aa
    audio_pitch 1, 3                                   ;; 05:75ac
    audio_pitch -1, 3                                  ;; 05:75ae
    audio_pitch -1, 3                                  ;; 05:75b0
    audio_pitch 1, 3                                   ;; 05:75b2

audio_05_75b4_PitchSlide:
    audio_pitch 2, 3                                   ;; 05:75b4
    audio_pitch -2, 3                                  ;; 05:75b6
    audio_pitch -2, 3                                  ;; 05:75b8
    audio_pitch 2, 3                                   ;; 05:75ba
    audio_pitch_loop audio_05_75b4_PitchSlide          ;; 05:75bc

audio_05_75bf_PitchSlide:
; pitch slide of instrument $0E
    audio_pitch 1, 2                                   ;; 05:75bf
    audio_pitch -1, 2                                  ;; 05:75c1
    audio_pitch 1, 2                                   ;; 05:75c3
    audio_pitch -1, 2                                  ;; 05:75c5
    audio_pitch_loop audio_05_7589_PitchSlide          ;; 05:75c7

audio_05_75ca_PitchSlide:
; pitch slide of instrument $10
; pitch slide of instrument $11
; pitch slide of instrument $12
; pitch slide of instrument $19
    audio_pitch 6, 2                                   ;; 05:75ca
    audio_pitch -6, 2                                  ;; 05:75cc
    audio_pitch -6, 2                                  ;; 05:75ce
    audio_pitch 6, 2                                   ;; 05:75d0
    audio_pitch_loop audio_05_75ca_PitchSlide          ;; 05:75d2

audio_05_75d5_PitchSlide:
; pitch slide of instrument $1B
    audio_pitch -3, 2                                  ;; 05:75d5
    audio_pitch 3, 2                                   ;; 05:75d7
    audio_pitch 3, 2                                   ;; 05:75d9
    audio_pitch -3, 2                                  ;; 05:75db
    audio_pitch_loop audio_05_75d5_PitchSlide          ;; 05:75dd

data_05_75e0_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $0d, $03, $f3, $03, $f3, $03, $0d, $03        ;; 05:75e0
    db   $7d, $89, $75                                 ;; 05:75e8

audio_05_75eb_Arpeggio:
; arpeggio of instrument $04
    audio_arp 3, 36                                    ;; 05:75eb
    audio_arp 1, 0                                     ;; 05:75ed
    audio_arp 3, 35                                    ;; 05:75ef
    audio_arp 1, 0                                     ;; 05:75f1
    audio_arp 3, 34                                    ;; 05:75f3
    audio_arp 1, 0                                     ;; 05:75f5
    audio_arp 3, 33                                    ;; 05:75f7
    audio_arp 1, 0                                     ;; 05:75f9
    audio_arp 3, 31                                    ;; 05:75fb
    audio_arp 1, 0                                     ;; 05:75fd
    audio_arp 3, 30                                    ;; 05:75ff
    audio_arp 1, 0                                     ;; 05:7601
    audio_arp 3, 29                                    ;; 05:7603
    audio_arp 1, 0                                     ;; 05:7605
    audio_arp 3, 28                                    ;; 05:7607
    audio_arp 1, 0                                     ;; 05:7609
    audio_arp 3, 27                                    ;; 05:760b
    audio_arp 1, 0                                     ;; 05:760d
    audio_arp 3, 26                                    ;; 05:760f
    audio_arp 1, 0                                     ;; 05:7611
    audio_arp 3, 25                                    ;; 05:7613
    audio_arp 1, 0                                     ;; 05:7615
    audio_arp 3, 24                                    ;; 05:7617
    audio_arp 1, 0                                     ;; 05:7619
    audio_arp 3, 23                                    ;; 05:761b
    audio_arp 1, 0                                     ;; 05:761d
    audio_arp 3, 22                                    ;; 05:761f
    audio_arp 1, 0                                     ;; 05:7621
    audio_arp 3, 21                                    ;; 05:7623
    audio_arp 1, 0                                     ;; 05:7625
    audio_arp 3, 20                                    ;; 05:7627
    audio_arp 1, 0                                     ;; 05:7629
    audio_arp 3, 19                                    ;; 05:762b
    audio_arp 1, 0                                     ;; 05:762d
    audio_arp 3, 18                                    ;; 05:762f
    audio_arp 1, 0                                     ;; 05:7631
    audio_arp 3, 17                                    ;; 05:7633
    audio_arp 1, 0                                     ;; 05:7635
    audio_arp 3, 16                                    ;; 05:7637
    audio_arp 1, 0                                     ;; 05:7639
    audio_arp 3, 15                                    ;; 05:763b
    audio_arp 1, 0                                     ;; 05:763d
    audio_arp 3, 14                                    ;; 05:763f
    audio_arp 1, 0                                     ;; 05:7641
    audio_arp 3, 13                                    ;; 05:7643
    audio_arp 1, 0                                     ;; 05:7645
    audio_arp 3, 12                                    ;; 05:7647
    audio_arp 1, 0                                     ;; 05:7649
    audio_arp_loop audio_05_75eb_Arpeggio              ;; 05:764b

audio_05_764e_Arpeggio:
; arpeggio of instrument $07
    audio_arp 1, -1                                    ;; 05:764e
    audio_arp 1, -2                                    ;; 05:7650
    audio_arp 1, -3                                    ;; 05:7652
    audio_arp 1, -4                                    ;; 05:7654
    audio_arp 1, -5                                    ;; 05:7656
    audio_arp 1, -6                                    ;; 05:7658
    audio_arp 1, -7                                    ;; 05:765a
    audio_arp 1, -8                                    ;; 05:765c
    audio_arp 1, -9                                    ;; 05:765e
    audio_arp 1, -10                                   ;; 05:7660
    audio_arp 1, -11                                   ;; 05:7662
    audio_arp 1, -12                                   ;; 05:7664
    audio_arp 1, -13                                   ;; 05:7666
    audio_arp 200, -13                                 ;; 05:7668
    audio_arp_loop audio_05_764e_Arpeggio              ;; 05:766a

audio_05_766d_Arpeggio:
; arpeggio of instrument $08
    audio_arp 3, 0                                     ;; 05:766d
    audio_arp 3, -12                                   ;; 05:766f
    audio_arp 3, 0                                     ;; 05:7671
    audio_arp 3, -12                                   ;; 05:7673
    audio_arp 3, 0                                     ;; 05:7675
    audio_arp 3, -12                                   ;; 05:7677
    audio_arp 3, 0                                     ;; 05:7679
    audio_arp 3, -12                                   ;; 05:767b
    audio_arp 3, 0                                     ;; 05:767d
    audio_arp 3, -12                                   ;; 05:767f
    audio_arp 3, 0                                     ;; 05:7681
    audio_arp 3, -12                                   ;; 05:7683
    audio_arp 3, 0                                     ;; 05:7685
    audio_arp 3, -12                                   ;; 05:7687
    audio_arp 3, 0                                     ;; 05:7689
    audio_arp 3, -12                                   ;; 05:768b
    audio_arp 3, 0                                     ;; 05:768d
    audio_arp 3, -12                                   ;; 05:768f
    audio_arp 3, 0                                     ;; 05:7691
    audio_arp 3, -12                                   ;; 05:7693
    audio_arp 3, 0                                     ;; 05:7695
    audio_arp 3, -12                                   ;; 05:7697
    audio_arp 3, 0                                     ;; 05:7699
    audio_arp 3, -12                                   ;; 05:769b
    audio_arp 3, 0                                     ;; 05:769d
    audio_arp 3, -12                                   ;; 05:769f
    audio_arp 3, 0                                     ;; 05:76a1
    audio_arp 3, -12                                   ;; 05:76a3
    audio_arp 3, 0                                     ;; 05:76a5
    audio_arp 3, -12                                   ;; 05:76a7
    audio_arp 3, 0                                     ;; 05:76a9
    audio_arp 3, -12                                   ;; 05:76ab
    audio_arp_loop audio_05_766d_Arpeggio              ;; 05:76ad

data_05_76b0_Unreferenced:
; nothing points here - padding, or a block the songs stopped using
    db   $03, $00, $03, $0c, $03, $00, $03, $0c        ;; 05:76b0
    db   $03, $00, $03, $0c, $ff, $b0, $76             ;; 05:76b8

audio_05_76bf_Arpeggio:
; arpeggio of instrument $09
; arpeggio of instrument $0B
    audio_arp 4, 12                                    ;; 05:76bf
    audio_arp 4, 0                                     ;; 05:76c1
    audio_arp 4, 12                                    ;; 05:76c3
    audio_arp 4, 0                                     ;; 05:76c5
    audio_arp 4, 12                                    ;; 05:76c7
    audio_arp 4, 0                                     ;; 05:76c9
    audio_arp_loop audio_05_76bf_Arpeggio              ;; 05:76cb

audio_05_76ce_Arpeggio:
; arpeggio of instrument $13
; arpeggio of instrument $1E
    audio_arp 1, 0                                     ;; 05:76ce
    audio_arp 1, 4                                     ;; 05:76d0
    audio_arp 1, 7                                     ;; 05:76d2
    audio_arp 1, 0                                     ;; 05:76d4
    audio_arp 1, 4                                     ;; 05:76d6
    audio_arp 1, 7                                     ;; 05:76d8
    audio_arp_loop audio_05_76ce_Arpeggio              ;; 05:76da

audio_05_76dd_Arpeggio:
; arpeggio of instrument $14
    audio_arp 1, 4                                     ;; 05:76dd
    audio_arp 1, 7                                     ;; 05:76df
    audio_arp 1, 12                                    ;; 05:76e1
    audio_arp 1, 4                                     ;; 05:76e3
    audio_arp 1, 7                                     ;; 05:76e5
    audio_arp 1, 12                                    ;; 05:76e7
    audio_arp_loop audio_05_76dd_Arpeggio              ;; 05:76e9

audio_05_76ec_Arpeggio:
; arpeggio of instrument $15
    audio_arp 1, 7                                     ;; 05:76ec
    audio_arp 1, 12                                    ;; 05:76ee
    audio_arp 1, 16                                    ;; 05:76f0
    audio_arp 1, 7                                     ;; 05:76f2
    audio_arp 1, 12                                    ;; 05:76f4
    audio_arp 1, 16                                    ;; 05:76f6
    audio_arp_loop audio_05_76ec_Arpeggio              ;; 05:76f8

audio_05_76fb_Arpeggio:
; arpeggio of instrument $16
; arpeggio of instrument $1F
    audio_arp 1, 0                                     ;; 05:76fb
    audio_arp 1, 3                                     ;; 05:76fd
    audio_arp 1, 7                                     ;; 05:76ff
    audio_arp 1, 0                                     ;; 05:7701
    audio_arp 1, 3                                     ;; 05:7703
    audio_arp 1, 7                                     ;; 05:7705
    audio_arp_loop audio_05_76fb_Arpeggio              ;; 05:7707

audio_05_770a_Arpeggio:
; arpeggio of instrument $17
    audio_arp 1, 3                                     ;; 05:770a
    audio_arp 1, 7                                     ;; 05:770c
    audio_arp 1, 12                                    ;; 05:770e
    audio_arp 1, 3                                     ;; 05:7710
    audio_arp 1, 7                                     ;; 05:7712
    audio_arp 1, 12                                    ;; 05:7714
    audio_arp_loop audio_05_770a_Arpeggio              ;; 05:7716

audio_05_7719_Arpeggio:
; arpeggio of instrument $18
    audio_arp 1, 7                                     ;; 05:7719
    audio_arp 1, 12                                    ;; 05:771b
    audio_arp 1, 15                                    ;; 05:771d
    audio_arp 1, 7                                     ;; 05:771f
    audio_arp 1, 12                                    ;; 05:7721
    audio_arp 1, 15                                    ;; 05:7723
    audio_arp_loop audio_05_7719_Arpeggio              ;; 05:7725

audio_05_7728_Arpeggio:
; arpeggio of instrument $1A
    audio_arp 2, 12                                    ;; 05:7728
    audio_arp 2, 0                                     ;; 05:772a
    audio_arp 2, 12                                    ;; 05:772c
    audio_arp 2, 0                                     ;; 05:772e
    audio_arp 2, 12                                    ;; 05:7730
    audio_arp 2, 0                                     ;; 05:7732
    audio_arp_loop audio_05_7728_Arpeggio              ;; 05:7734

audio_05_7737_Arpeggio:
; arpeggio of instrument $1C
    audio_arp 6, 0                                     ;; 05:7737
    audio_arp 6, 2                                     ;; 05:7739
    audio_arp 6, 3                                     ;; 05:773b
    audio_arp 6, 7                                     ;; 05:773d
    audio_arp 6, 12                                    ;; 05:773f
    audio_arp 6, 14                                    ;; 05:7741
    audio_arp 6, 15                                    ;; 05:7743
    audio_arp 6, 19                                    ;; 05:7745
    audio_arp 6, 24                                    ;; 05:7747
    audio_arp 6, 19                                    ;; 05:7749
    audio_arp 6, 15                                    ;; 05:774b
    audio_arp 6, 14                                    ;; 05:774d
    audio_arp 6, 12                                    ;; 05:774f
    audio_arp 6, 7                                     ;; 05:7751
    audio_arp 6, 3                                     ;; 05:7753
    audio_arp 6, 2                                     ;; 05:7755
    audio_arp_loop audio_05_7737_Arpeggio              ;; 05:7757

audio_05_775a_Arpeggio:
; arpeggio of instrument $1D
    audio_arp 6, 0                                     ;; 05:775a
    audio_arp 6, 2                                     ;; 05:775c
    audio_arp 6, 4                                     ;; 05:775e
    audio_arp 6, 7                                     ;; 05:7760
    audio_arp 6, 12                                    ;; 05:7762
    audio_arp 6, 14                                    ;; 05:7764
    audio_arp 6, 16                                    ;; 05:7766
    audio_arp 6, 19                                    ;; 05:7768
    audio_arp 6, 24                                    ;; 05:776a
    audio_arp 6, 19                                    ;; 05:776c
    audio_arp 6, 16                                    ;; 05:776e
    audio_arp 6, 14                                    ;; 05:7770
    audio_arp 6, 12                                    ;; 05:7772
    audio_arp 6, 7                                     ;; 05:7774
    audio_arp 6, 4                                     ;; 05:7776
    audio_arp 6, 2                                     ;; 05:7778
    audio_arp_loop audio_05_775a_Arpeggio              ;; 05:777a

data_05_777d_PatternPointers:
; The patterns AUDIO_CMD_CALL_PATTERN can name. Its argument is doubled into a
; byte offset and the carry out of that doubling picks the second 256-byte half
; of the table, which is how one byte reaches 256 patterns. This bank stops at
; $6B
    dw   audio_05_54d6_Pattern00                       ;; 05:777d  ; pattern $00
    dw   audio_05_593c_Pattern01                       ;; 05:777f  ; pattern $01
    dw   audio_05_5961_Pattern02                       ;; 05:7781  ; pattern $02
    dw   audio_05_599a_Pattern03                       ;; 05:7783  ; pattern $03
    dw   audio_05_585a_Pattern04                       ;; 05:7785  ; pattern $04
    dw   audio_05_5883_Pattern05                       ;; 05:7787  ; pattern $05
    dw   audio_05_588c_Pattern06                       ;; 05:7789  ; pattern $06
    dw   audio_05_58a1_Pattern07                       ;; 05:778b  ; pattern $07
    dw   audio_05_58c3_Pattern08                       ;; 05:778d  ; pattern $08
    dw   audio_05_58ea_Pattern09                       ;; 05:778f  ; pattern $09
    dw   audio_05_5913_Pattern0A                       ;; 05:7791  ; pattern $0A
    dw   audio_05_564a_Pattern0B                       ;; 05:7793  ; pattern $0B
    dw   audio_05_565b_Pattern0C                       ;; 05:7795  ; pattern $0C
    dw   audio_05_568c_Pattern0D                       ;; 05:7797  ; pattern $0D
    dw   audio_05_570d_Pattern0E                       ;; 05:7799  ; pattern $0E
    dw   audio_05_5742_Pattern0F                       ;; 05:779b  ; pattern $0F
    dw   audio_05_5773_Pattern10                       ;; 05:779d  ; pattern $10
    dw   audio_05_5808_Pattern11                       ;; 05:779f  ; pattern $11
    dw   audio_05_5831_Pattern12                       ;; 05:77a1  ; pattern $12
    dw   audio_05_54d9_Pattern13                       ;; 05:77a3  ; pattern $13
    dw   audio_05_550a_Pattern14                       ;; 05:77a5  ; pattern $14
    dw   audio_05_5535_Pattern15                       ;; 05:77a7  ; pattern $15
    dw   audio_05_55b6_Pattern16                       ;; 05:77a9  ; pattern $16
    dw   audio_05_55f7_Pattern17                       ;; 05:77ab  ; pattern $17
    dw   audio_05_5620_Pattern18                       ;; 05:77ad  ; pattern $18
    dw   audio_05_5641_Pattern19                       ;; 05:77af  ; pattern $19
    dw   audio_05_5f10_Pattern1A                       ;; 05:77b1  ; pattern $1A
    dw   audio_05_5f3f_Pattern1B                       ;; 05:77b3  ; pattern $1B
    dw   audio_05_5f78_Pattern1C                       ;; 05:77b5  ; pattern $1C
    dw   audio_05_5f9d_Pattern1D                       ;; 05:77b7  ; pattern $1D
    dw   audio_05_5e43_Pattern1E                       ;; 05:77b9  ; pattern $1E
    dw   audio_05_5e58_Pattern1F                       ;; 05:77bb  ; pattern $1F
    dw   audio_05_5e7b_Pattern20                       ;; 05:77bd  ; pattern $20
    dw   audio_05_5e8c_Pattern21                       ;; 05:77bf  ; pattern $21
    dw   audio_05_5ea3_Pattern22                       ;; 05:77c1  ; pattern $22
    dw   audio_05_5eb4_Pattern23                       ;; 05:77c3  ; pattern $23
    dw   audio_05_5ee9_Pattern24                       ;; 05:77c5  ; pattern $24
    dw   audio_05_5ba7_Pattern25                       ;; 05:77c7  ; pattern $25
    dw   audio_05_5bec_Pattern26                       ;; 05:77c9  ; pattern $26
    dw   audio_05_5c65_Pattern27                       ;; 05:77cb  ; pattern $27
    dw   audio_05_5c82_Pattern28                       ;; 05:77cd  ; pattern $28
    dw   audio_05_5cb9_Pattern29                       ;; 05:77cf  ; pattern $29
    dw   audio_05_5cda_Pattern2A                       ;; 05:77d1  ; pattern $2A
    dw   audio_05_5d69_Pattern2B                       ;; 05:77d3  ; pattern $2B
    dw   audio_05_5d96_Pattern2C                       ;; 05:77d5  ; pattern $2C
    dw   audio_05_5a81_Pattern2D                       ;; 05:77d7  ; pattern $2D
    dw   audio_05_5aaa_Pattern2E                       ;; 05:77d9  ; pattern $2E
    dw   audio_05_5acb_Pattern2F                       ;; 05:77db  ; pattern $2F
    dw   audio_05_5ae4_Pattern30                       ;; 05:77dd  ; pattern $30
    dw   audio_05_5af5_Pattern31                       ;; 05:77df  ; pattern $31
    dw   audio_05_5b56_Pattern32                       ;; 05:77e1  ; pattern $32
    dw   audio_05_5fee_Pattern33                       ;; 05:77e3  ; pattern $33
    dw   audio_05_6069_Pattern34                       ;; 05:77e5  ; pattern $34
    dw   audio_05_608a_Pattern35                       ;; 05:77e7  ; pattern $35
    dw   audio_05_60c3_Pattern36                       ;; 05:77e9  ; pattern $36
    dw   audio_05_60e4_Pattern37                       ;; 05:77eb  ; pattern $37
    dw   audio_05_6517_Pattern38                       ;; 05:77ed  ; pattern $38
    dw   audio_05_6417_Pattern39                       ;; 05:77ef  ; pattern $39
    dw   audio_05_6436_Pattern3A                       ;; 05:77f1  ; pattern $3A
    dw   audio_05_6475_Pattern3B                       ;; 05:77f3  ; pattern $3B
    dw   audio_05_64a4_Pattern3C                       ;; 05:77f5  ; pattern $3C
    dw   audio_05_64d7_Pattern3D                       ;; 05:77f7  ; pattern $3D
    dw   audio_05_64fa_Pattern3E                       ;; 05:77f9  ; pattern $3E
    dw   audio_05_62dd_Pattern3F                       ;; 05:77fb  ; pattern $3F
    dw   audio_05_62e6_Pattern40                       ;; 05:77fd  ; pattern $40
    dw   audio_05_6327_Pattern41                       ;; 05:77ff  ; pattern $41
    dw   audio_05_6396_Pattern42                       ;; 05:7801  ; pattern $42
    dw   audio_05_63bf_Pattern43                       ;; 05:7803  ; pattern $43
    dw   audio_05_63ce_Pattern44                       ;; 05:7805  ; pattern $44
    dw   audio_05_61a3_Pattern45                       ;; 05:7807  ; pattern $45
    dw   audio_05_61ac_Pattern46                       ;; 05:7809  ; pattern $46
    dw   audio_05_61d1_Pattern47                       ;; 05:780b  ; pattern $47
    dw   audio_05_6250_Pattern48                       ;; 05:780d  ; pattern $48
    dw   audio_05_6285_Pattern49                       ;; 05:780f  ; pattern $49
    dw   audio_05_6294_Pattern4A                       ;; 05:7811  ; pattern $4A
    dw   audio_05_655a_Pattern4B                       ;; 05:7813  ; pattern $4B
    dw   audio_05_65b1_Pattern4C                       ;; 05:7815  ; pattern $4C
    dw   audio_05_6606_Pattern4D                       ;; 05:7817  ; pattern $4D
    dw   audio_05_6863_Pattern4E                       ;; 05:7819  ; pattern $4E
    dw   audio_05_6808_Pattern4F                       ;; 05:781b  ; pattern $4F
    dw   audio_05_6833_Pattern50                       ;; 05:781d  ; pattern $50
    dw   audio_05_6848_Pattern51                       ;; 05:781f  ; pattern $51
    dw   audio_05_6797_Pattern52                       ;; 05:7821  ; pattern $52
    dw   audio_05_67d8_Pattern53                       ;; 05:7823  ; pattern $53
    dw   audio_05_67ed_Pattern54                       ;; 05:7825  ; pattern $54
    dw   audio_05_6675_Pattern55                       ;; 05:7827  ; pattern $55
    dw   audio_05_675e_Pattern56                       ;; 05:7829  ; pattern $56
    dw   audio_05_6d52_Pattern57                       ;; 05:782b  ; pattern $57
    dw   audio_05_6d34_Pattern58                       ;; 05:782d  ; pattern $58
    dw   audio_05_6d43_Pattern59                       ;; 05:782f  ; pattern $59
    dw   audio_05_6d0e_Pattern5A                       ;; 05:7831  ; pattern $5A
    dw   audio_05_6d21_Pattern5B                       ;; 05:7833  ; pattern $5B
    dw   audio_05_6a2a_Pattern5C                       ;; 05:7835  ; pattern $5C
    dw   audio_05_6a79_Pattern5D                       ;; 05:7837  ; pattern $5D
    dw   audio_05_6b2e_Pattern5E                       ;; 05:7839  ; pattern $5E
    dw   audio_05_6b59_Pattern5F                       ;; 05:783b  ; pattern $5F
    dw   audio_05_6b8e_Pattern60                       ;; 05:783d  ; pattern $60
    dw   audio_05_6c3b_Pattern61                       ;; 05:783f  ; pattern $61
    dw   audio_05_6f51_Pattern62                       ;; 05:7841  ; pattern $62
    dw   audio_05_6f38_Pattern63                       ;; 05:7843  ; pattern $63
    dw   audio_05_6f17_Pattern64                       ;; 05:7845  ; pattern $64
    dw   audio_05_6e0b_Pattern65                       ;; 05:7847  ; pattern $65
    dw   audio_05_6e34_Pattern66                       ;; 05:7849  ; pattern $66
    dw   audio_05_6e55_Pattern67                       ;; 05:784b  ; pattern $67
    dw   audio_05_6e90_Pattern68                       ;; 05:784d  ; pattern $68
    dw   audio_05_700c_Pattern69                       ;; 05:784f  ; pattern $69
    dw   audio_05_7091_Pattern6A                       ;; 05:7851  ; pattern $6A
    dw   audio_05_70f8_Pattern6B                       ;; 05:7853  ; pattern $6B
