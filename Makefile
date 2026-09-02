ROM := rom.gb
BUILDDIR := build

SRCS := $(wildcard src/main.asm)
GFXS := $(shell find src/gfx/ -type f -name '*.png')

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink

PYTHON  ?= python3
FONTGFX := $(PYTHON) tools/fontgfx.py

OBJS := $(patsubst src/main.asm,$(BUILDDIR)/rom.o,$(SRCS))
DEPS := $(patsubst src/main.asm,$(BUILDDIR)/rom.mk,$(SRCS))

all: $(ROM)

check: $(ROM)
	md5sum -c $(ROM).md5

clean:
	-rm -rf $(BUILDDIR) $(ROM) src/.gfx

$(ROM): $(OBJS)
	@mkdir -p $(@D)
	$(RGBLINK) -w -m $(BUILDDIR)/$(basename $@).map -n $(basename $@).sym -o $@ $^
	$(RGBFIX) --validate $(FIXFLAGS) $@

# assemble .asm → build/rom.o and build/rom.mk
$(BUILDDIR)/rom.o $(BUILDDIR)/rom.mk: src/main.asm $(patsubst src/gfx/%.png,src/.gfx/%.bin,$(GFXS))
	@mkdir -p $(BUILDDIR)
	$(RGBASM) -Wall -Wextra --export-all -Isrc -I.gfx \
		-M $(BUILDDIR)/rom.mk -MP -MQ $(BUILDDIR)/rom.o -MQ $(BUILDDIR)/rom.mk \
		-o $(BUILDDIR)/rom.o $<

# Special gfx processing flags
src/.gfx/entity_sprites/%.bin: rgbgfx += --columns
src/.gfx/player_sprites/%.bin: rgbgfx += --columns
src/.gfx/misc_sprites/%.bin: rgbgfx += --columns
src/.gfx/collision_tileset/%.bin: rgbgfx += -d 1

# png → .bin
src/.gfx/%.bin: src/gfx/%.png
	@mkdir -p $(dir $@)
	$(RGBGFX) $(rgbgfx) -o $@ $<

# The bank $01 menu fonts are not 8x8 tile data. data_01_5b77_FontDescriptors gives
# each font a height in PIXELS, and font0_text_small's is 7 - 1008 bytes is 504 rows,
# not a multiple of 8, so no rgbgfx invocation can describe that file. All four go
# through tools/fontgfx.py instead, which also lays them out as one readable row of
# glyphs. This pattern is more specific than the generic src/.gfx/%.bin rule above,
# so make prefers it (shorter stem wins).
src/.gfx/text/font0_text_small.bin:     fontgfx = --cols 1 --height 7
src/.gfx/text/font1_text_large.bin:     fontgfx = --cols 1 --height 8
src/.gfx/text/font2_password_small.bin: fontgfx = --cols 1 --height 8
src/.gfx/text/font3_password_large.bin: fontgfx = --cols 2 --height 16

src/.gfx/text/%.bin: src/gfx/text/%.png
	@mkdir -p $(dir $@)
	$(FONTGFX) encode $(fontgfx) -o $@ $<

# One-time bootstrap: turn font .bin files back into the .png sources.
fonts-png:
	$(FONTGFX) decode-all

# Assert that png → bin reproduces the original .bin byte for byte
fonts-verify:
	$(FONTGFX) verify-all

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

.PHONY: all clean check fonts-png fonts-verify
.SECONDARY:
