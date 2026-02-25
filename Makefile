ROM := rom.gb
BUILDDIR := build

SRCS := $(wildcard src/main.asm)
GFXS := $(shell find src/gfx/ -type f -name '*.png')

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink

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
src/.gfx/misc_sprites/%.bin: rgbgfx += --columns
src/.gfx/text/%.bin: rgbgfx += --columns
src/.gfx/collision_tileset/%.bin: rgbgfx += -d 1

# png → .bin
src/.gfx/%.bin: src/gfx/%.png
	@mkdir -p $(dir $@)
	$(RGBGFX) $(rgbgfx) -o $@ $<

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

.PHONY: all clean
.SECONDARY:
