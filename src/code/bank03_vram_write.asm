; ==================================================================
; Bank 3. The two routines that actually put a background strip into VRAM, and the
; unrolled copies they are built from. Four routines, and between them they are the
; last step of the whole background scrolling pipeline.
;
; What happens before this file
; -----------------------------
; When the camera crosses a block boundary, call_02_7305_MapScroll_CheckVertical or
; its horizontal twin raises a MAP_SCROLL_* bit. call_00_11c8_BgMap_LoadDirtyRegions
; then reads the level's blockmap, expands the blocks it needs into TILE IDS and CGB
; ATTRIBUTES, and leaves them in four scratch buffers in bank 0:
;
;   wCF00_BgMap_TempScratchRowTileIds      wCF80_BgMap_TempScratchRowAttributes
;   wCF40_BgMap_TempScratchColumnTileIds   wCFC0_BgMap_TempScratchColumnAttributes
;
; It also records where the strip belongs, in wDC21_BgMap_RowWritePosLo and
; wDC23_BgMap_ColumnWritePosLo. Nothing has touched VRAM yet.
;
; What happens here
; -----------------
; call_00_0b9f_VBlank_UpdateVRAM calls one of the two writers below during vblank,
; and each does the same thing twice: switch rVBK to VRAM_BANK_ATTRIBUTES and blit
; the attribute buffer, then switch to VRAM_BANK_TILE_IDS and blit the tile id
; buffer. Both halves target the SAME tilemap address - that is the whole point of
; the CGB's second VRAM bank.
;
; Both writers fall THROUGH into their copy helper for the second half rather than
; calling it, which is why neither has a visible `ret` and why the tile id load is
; the last instruction before the next label.
;
; Everything here is unrolled because it runs inside vblank. A row is thirty-two
; bytes twice over and there is no time for a loop counter; the REPT blocks below
; are the same instructions written once, and assemble to the same ROM.
;
; ------------------------------------------------------------------
; Notes for anyone reading this next to gex2's bank03_vram_write.asm
; ------------------------------------------------------------------
; Same job, and the row and column writers are recognisably the same pair - masked
; with $E0 for a row and $1F for a column, stepping by 1 and by $20. gex2's file is
; nearly three times the size, for two reasons:
;
;   the expansion  gex2 has no scratch buffers. Its writers do the blockmap lookup
;                  INLINE, one tile at a time, through the `ld B, $CF / ld C, [HL] /
;                  ld A, [BC]` indirection that turns a block id into a tile id
;                  while the write is happening. gex3 expands the whole strip into
;                  wCF00 and friends beforehand, so these routines are a pure
;                  memcpy and have no idea what a block is
;   the DMG path   every gex2 writer starts with `ld A, [wD59E_OnGBCFlag]` and has a
;                  second, shorter copy of itself for monochrome hardware. gex3 is
;                  CGB-only, so the attribute pass is unconditional
;
; gex2 also has a 16-byte copy here, used by the HUD tile loaders to move one 8x8
; tile. gex3's equivalents use general purpose DMA instead, so its only copies are
; the two strip-sized ones below
; ==================================================================

call_03_75e3_VRAM_WriteBgMapRow:
; Flushes the pending ROW strip - the one a vertical scroll asked for - into the
; tilemap, attributes first and then tile ids.
;
; The destination comes from wDC21_BgMap_RowWritePosLo and its high byte, with the
; low byte masked by BGMAP_ROW_MASK so the address always lands on the start of a
; tilemap row. That mask is what makes the `inc E` inside the copy safe.
;
; The address is recomputed from scratch for the second half rather than being kept
; in a register, because call_03_7604_VRAM_Copy32Bytes leaves DE at the end of the
; row it just wrote.
;
; Falls through into the copy for the tile id pass. gex2's
; call_03_6f5e_VRAM_WriteBgMapRowForVerticalScroll
    ld   A, $01                                       ;; 03:75e3 $3e $01
    ldh  [rVBK], A                                    ;; 03:75e5 $e0 $4f
    ld   HL, wDC21_BgMap_RowWritePosLo                ;; 03:75e7 $21 $21 $dc
    ld   A, [HL+]                                     ;; 03:75ea $2a
    and  A, $e0                                       ;; 03:75eb $e6 $e0
    ld   D, [HL]                                      ;; 03:75ed $56
    ld   E, A                                         ;; 03:75ee $5f
    ld   HL, wCF80_BgMap_TempScratchRowAttributes     ;; 03:75ef $21 $80 $cf
    call call_03_7604_VRAM_Copy32Bytes                ;; 03:75f2 $cd $04 $76
    ld   A, $00                                       ;; 03:75f5 $3e $00
    ldh  [rVBK], A                                    ;; 03:75f7 $e0 $4f
    ld   HL, wDC21_BgMap_RowWritePosLo                ;; 03:75f9 $21 $21 $dc
    ld   A, [HL+]                                     ;; 03:75fc $2a
    and  A, $e0                                       ;; 03:75fd $e6 $e0
    ld   D, [HL]                                      ;; 03:75ff $56
    ld   E, A                                         ;; 03:7600 $5f
    ld   HL, wCF00_BgMap_TempScratchRowTileIds        ;; 03:7601 $21 $00 $cf

call_03_7604_VRAM_Copy32Bytes:
; Copies BGMAP_ROW_TILES bytes from HL into VRAM at DE - one full tilemap row.
;
; Fully unrolled in the ROM: thirty-two loads and stores with no counter, because a
; row has to land inside one vblank and a `dec B / jr NZ` per byte would cost a third
; again as long. Written here as a REPT so it stays one screen instead of ninety-six
; lines; it assembles to exactly the same bytes.
;
; The advance is `inc E`, not `inc DE`, so D never changes and the copy cannot cross a
; page boundary. That is safe only because the caller masked the destination with
; BGMAP_ROW_MASK, which snaps it to the start of a 32-byte row - and it is also why
; the last iteration drops the advance rather than leaving DE pointing past the row.
;
; gex2's call_03_6efd_VRAM_Copy32Bytes is the same idea at half the size: it copies
; two 8x8 tiles rather than a tilemap row, and falls into a 16-byte version for the
; second half
    REPT BGMAP_ROW_TILES - 1
    ld   A, [HL+]
    ld   [DE], A
    inc  E
    ENDR
    ld   A, [HL+]
    ld   [DE], A
    ret

call_03_7664_VRAM_WriteBgMapColumn:
; The same for the pending COLUMN strip, which a horizontal scroll asked for.
;
; wDC23_BgMap_ColumnWritePosLo is masked with BGMAP_COLUMN_MASK to a column index and
; used as the LOW byte of an address whose high byte is a fixed HIGH(_SCRN0) - so
; unlike the row writer, this one always starts at the top of the map and walks down
; through all BGMAP_COLUMN_TILES rows. The column's own high byte in
; wDC24_BgMap_ColumnWritePosHi is never read here.
;
; Falls through into call_03_7685_VRAM_WriteColumn32Bytes for the tile id pass.
; gex2's call_03_708d_VRAM_WriteBgMapColumnForHorizontalScroll
    ld   A, $01                                       ;; 03:7664 $3e $01
    ldh  [rVBK], A                                    ;; 03:7666 $e0 $4f
    ld   A, [wDC23_BgMap_ColumnWritePosLo]            ;; 03:7668 $fa $23 $dc
    and  A, $1f                                       ;; 03:766b $e6 $1f
    ld   L, A                                         ;; 03:766d $6f
    ld   H, $98                                       ;; 03:766e $26 $98
    ld   DE, wCFC0_BgMap_TempScratchColumnAttributes  ;; 03:7670 $11 $c0 $cf
    call call_03_7685_VRAM_WriteColumn32Bytes         ;; 03:7673 $cd $85 $76
    ld   A, $00                                       ;; 03:7676 $3e $00
    ldh  [rVBK], A                                    ;; 03:7678 $e0 $4f
    ld   A, [wDC23_BgMap_ColumnWritePosLo]            ;; 03:767a $fa $23 $dc
    and  A, $1f                                       ;; 03:767d $e6 $1f
    ld   L, A                                         ;; 03:767f $6f
    ld   H, HIGH(_SCRN0)                              ;; 03:7680 $26 $98
    ld   DE, wCF40_BgMap_TempScratchColumnTileIds     ;; 03:7682 $11 $40 $cf

call_03_7685_VRAM_WriteColumn32Bytes:
; Copies BGMAP_COLUMN_TILES bytes from DE into VRAM at HL, stepping down one tilemap
; row - BGMAP_ROW_STRIDE - after each byte. The vertical mirror of the routine above,
; and unrolled for the same reason.
;
; Note the source advances with `inc E` while the destination advances with
; `add HL, BC`: the buffer is contiguous and the tilemap is not.
;
; HL is a full 16-bit add here, so the column DOES walk from $9800 into $9900 and
; beyond as it descends - unlike the row copy, which is pinned to one page. The
; tilemap is only $400 bytes so thirty-two rows of $20 land exactly inside it.
;
; The label used to say 16; it copies thirty-two bytes, one for each row of the
; virtual screen
    ld   BC, BGMAP_ROW_STRIDE
    REPT BGMAP_COLUMN_TILES - 1
    ld   A, [DE]
    ld   [HL], A
    add  HL, BC
    inc  E
    ENDR
    ld   A, [DE]
    ld   [HL], A
    ret