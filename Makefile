ROM = rom.gb

SRCS = $(wildcard src/game.asm)
GFXS = $(shell find gfx/ -type f -name '*.png')

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink

all: $(ROM)

check: $(ROM)
	md5sum -c $(ROM).md5

clean:
	-rm -rf .bin .obj .dep .gfx $(ROM)

$(ROM): $(patsubst src/game.asm,.obj/%.o,$(SRCS))
	@mkdir -p $(@D)
	rgblink -w -m $(basename $@).map -n $(basename $@).sym -o $@ $^
	rgbfix --validate $(FIXFLAGS) $@


.obj/%.o $(DEPDIR)/%.mk: src/game.asm $(patsubst gfx/%.png,.gfx/%.bin,$(GFXS))
	@mkdir -p $(dir .obj/$* .dep/$*)
	rgbasm -Wall -Wextra --export-all -Isrc -I.gfx -M .dep/$*.mk -MP -MQ .obj/$*.o -MQ .dep/$*.mk -o .obj/$*.o $<

.gfx/object_sprites/%.bin: rgbgfx += --columns
.gfx/misc_sprites/%.bin: rgbgfx += --columns

.gfx/%.bin: gfx/%.png
	@mkdir -p $(dir .gfx/$*)
	$(RGBGFX) $(rgbgfx) -o $@ $<

ifneq ($(MAKECMDGOALS),clean)
-include $(patsubst src/game.asm,.dep/%.mk,$(SRCS))
endif

.PHONY: all clean
.SECONDARY:
