CC=cl65
EMU=../../x16emur46/x16emu

make:
	$(CC) --cpu 65C02 -Or -Cl -C cx16-zsm-bank.cfg -o ./build/ADUEL.PRG -t cx16 -l ADUEL.list -Ln ADUEL.sym \
	src/main.s

run:
	cd build && \
	$(EMU) -prg ADUEL.PRG -run

emu:
	cd build && \
	$(EMU)

debug:
	cd build && \
	$(EMU) -prg ADUEL.PRG -debug

pal:
	node tools/gimp-pal-convert.js gfx/sprites.data.pal build/MAINPAL.BIN
	node tools/gimp-pal-convert.js gfx/title.data.pal build/TPAL.BIN

img:
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIP1.BIN 32 32 8 0 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIPTHR1.BIN 32 32 8 8 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/LASER1.BIN 16 16 16 64 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIP2.BIN 32 32 8 24 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIPTHR2.BIN 32 32 8 32 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/LASER2.BIN 16 16 16 80 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/MINE.BIN 16 16 16 160 2 1
	node tools/gimp-img-convert.js gfx/sprites.data build/ASTBIG.BIN 32 32 8 48 8 2
	node tools/gimp-img-convert.js gfx/sprites.data build/ASTSML.BIN 16 16 16 256 16 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GEM.BIN 16 16 16 272 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/EXP.BIN 32 32 8 72 8 1
	node tools/gimp-img-convert.js gfx/sprites.data build/FONT.BIN 16 16 16 384 16 4
	node tools/gimp-img-convert.js gfx/sprites.data build/STARS.BIN 16 16 16 320 16 4 49

title:
	node tools/gimp-img-convert.js gfx/title.data build/TITLE.BIN 320 240 1 0 1 1
	node tools/gimp-img-convert.js gfx/instr.data build/INSTR.BIN 320 240 1 0 1 1

field:
	node tools/starfield.js

overlay:
	node tools/overlay.js

zip:
	cd build && \
	rm -f aduel.zip && \
	zip aduel.zip *
