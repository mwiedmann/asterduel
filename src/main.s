.zeropage
    active_entity: .res 2
    astbig_entity: .res 2
    astsml_entity: .res 2
    gem_entity: .res 2
    laser_entity: .res 2
    mine_entity: .res 2
    active_exp: .res 2
    comp_entity1: .res 2
    comp_entity2: .res 2
    param1: .res 2
    acc_entity: .res 2

.segment "STARTUP"
    jmp start

.segment "ONCE"

.include "x16.inc"
.include "config.inc"
.include "entities.inc"
.include "oneshot.inc"
.include "zsmkit.inc"

.segment "CODE"

entities:
ship_1: .res .sizeof(Entity)
ship_2: .res .sizeof(Entity)
other_entities: .res .sizeof(Entity)*(ENTITY_COUNT-2)

oneshots: .res .sizeof(Oneshot)*ONESHOT_SPRITE_COUNT

; Precalculated sin/cos (adjusted for a pixel velocity I want) for each angle
ship_vel_ang_x: .word 0,       3,       6,       7,       8, 7, 6, 3, 0, 65535-3, 65535-6, 65535-7, 65535-8, 65535-7, 65535-6, 65535-3
ship_vel_ang_y: .word 65535-8, 65535-7, 65535-6, 65535-3, 0, 3, 6, 7, 8, 7,       6,       3,       0,       65535-3, 65535-6, 65535-7

; What sprite frame to use for each angle
ship_frame_ang: .byte  0,         1,         2,         3,         4,         3,          2,        1,         0,         1,         2,         3,         4,         3,         2,         1

; We make use of the V/H-flip on the sprite to get reuse of the 5 frames. These are precalced for easy use
ship_flip_ang: .byte   %00001000, %00001000, %00001000, %00001000, %00001000, %00001010, %00001010, %00001010, %00001010, %00001011, %00001011, %00001011, %00001001, %00001001, %00001001, %00001001

; These are the V/H-Flip bits we use for each angle
; VFLip 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
; HFlip 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1

thrusting_1: .byte 0
thrusting_2: .byte 0

default_irq: .word 0
waitflag: .byte 0

rotatewait_1: .byte 0
thrustwait_1: .byte 0
firewait_1: .byte 0
rotatewait_2: .byte 0
thrustwait_2: .byte 0
firewait_2: .byte 0

accelwait: .byte 0
enemywait: .byte 0

joy_a: .byte 0
joy_x: .byte 0

zsmreserved: .res 256

.include "sound.s"
.include "config.s"
.include "irq.s"
.include "loading.s"
.include "wait.s"
.include "pal.s"
.include "title.s"
.include "ship.s"
.include "sprites.s"
.include "entities.s"
.include "controls.s"
.include "astbig.s"
.include "astsml.s"
.include "laser.s"
.include "collisions.s"
.include "oneshot.s"
.include "gem.s"
.include "mine.s"
.include "tiles.s"
.include "score.s"

start:
    jsr show_title
    ;jsr sound_init
    jsr load_mainpal
    jsr load_sprites
    ;jsr load_sounds
    jsr irq_config
    jsr config
    jsr create_ships
    jsr create_laser_sprites
    jsr create_astbig_sprites
    jsr create_astsml_sprites
    jsr create_gem_sprites
    jsr create_mine_sprites
    jsr init_oneshots
    jsr launch_astbigs
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    jsr update_stats
    jsr check_shields_and_bases
    jsr relaunch_astbig
    jsr check_controls_ship_1
    jsr check_controls_ship_2
    jsr process_entities
    jsr update_oneshots
    jsr show_ghosts
    jsr handle_collision
    lda launch_ship_1_mine
    cmp #0
    beq @skip_base1_mines
    jsr launch_mine_1
    stz launch_ship_1_mine
@skip_base1_mines:
    lda launch_ship_2_mine
    cmp #0
    beq @skip_base2_mines
    jsr launch_mine_2
    stz launch_ship_2_mine
@skip_base2_mines:
    stz waitflag
    bra @waiting