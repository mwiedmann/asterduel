.ifndef LOADING_S
LOADING_S = 1

star_tiles_filename: .asciiz "stars.bin"
star_field_filename: .asciiz "field.bin"
ship_1_filename: .asciiz "ship1.bin"
ship_1_thrust_filename: .asciiz "shipthr1.bin"
ship_2_filename: .asciiz "ship2.bin"
ship_2_thrust_filename: .asciiz "shipthr2.bin"

astbig_filename: .asciiz "astbig.bin"
astsml_filename: .asciiz "astsml.bin"
laser_1_filename: .asciiz "laser1.bin"
laser_2_filename: .asciiz "laser2.bin"
overlay_filename: .asciiz "overlay.bin"
exp_filename: .asciiz "exp.bin"
gem_filename: .asciiz "gem.bin"
font_filename: .asciiz "font.bin"
mine_filename: .asciiz "mine.bin"

load_sprites:
    jsr load_star_tiles
    jsr load_star_field
    jsr load_overlay
    jsr load_ship1
    jsr load_ship_thust1
    jsr load_ship2
    jsr load_ship_thust2
    jsr load_astbig
    jsr load_astsml
    jsr load_laser1
    jsr load_laser2
    jsr load_exp
    jsr load_gem
    jsr load_font
    jsr load_mine
    rts

load_star_tiles:
    lda #9
    ldx #<star_tiles_filename
    ldy #>star_tiles_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<TILEBASE_L0_ADDR 
    ldy #>TILEBASE_L0_ADDR
    jsr LOAD
    rts

load_star_field:
    lda #9
    ldx #<star_field_filename
    ldy #>star_field_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<MAPBASE_L0_ADDR 
    ldy #>MAPBASE_L0_ADDR
    jsr LOAD
    rts

load_overlay:
    lda #11
    ldx #<overlay_filename
    ldy #>overlay_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<MAPBASE_L1_ADDR 
    ldy #>MAPBASE_L1_ADDR
    jsr LOAD
    rts

load_ship1:
    lda #9
    ldx #<ship_1_filename
    ldy #>ship_1_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_1_LOAD_ADDR 
    ldy #>SHIP_1_LOAD_ADDR
    jsr LOAD
    rts

load_ship2:
    lda #9
    ldx #<ship_2_filename
    ldy #>ship_2_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<SHIP_2_LOAD_ADDR 
    ldy #>SHIP_2_LOAD_ADDR
    jsr LOAD
    rts

load_ship_thust1:
    lda #12
    ldx #<ship_1_thrust_filename
    ldy #>ship_1_thrust_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_1_THRUST_LOAD_ADDR 
    ldy #>SHIP_1_THRUST_LOAD_ADDR
    jsr LOAD
    rts


load_ship_thust2:
    lda #12
    ldx #<ship_2_thrust_filename
    ldy #>ship_2_thrust_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<SHIP_2_THRUST_LOAD_ADDR 
    ldy #>SHIP_2_THRUST_LOAD_ADDR
    jsr LOAD
    rts

load_astbig:
    lda #10
    ldx #<astbig_filename
    ldy #>astbig_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<ASTBIG_LOAD_ADDR 
    ldy #>ASTBIG_LOAD_ADDR
    jsr LOAD
    rts

load_astsml:
    lda #10
    ldx #<astsml_filename
    ldy #>astsml_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<ASTSML_LOAD_ADDR 
    ldy #>ASTSML_LOAD_ADDR
    jsr LOAD
    rts

load_laser1:
    lda #10
    ldx #<laser_1_filename
    ldy #>laser_1_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_1_LASER_LOAD_ADDR 
    ldy #>SHIP_1_LASER_LOAD_ADDR
    jsr LOAD
    rts

load_laser2:
    lda #10
    ldx #<laser_2_filename
    ldy #>laser_2_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<SHIP_2_LASER_LOAD_ADDR 
    ldy #>SHIP_2_LASER_LOAD_ADDR
    jsr LOAD
    rts

load_exp:
    lda #7
    ldx #<exp_filename
    ldy #>exp_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<EXPLOSION_LOAD_ADDR 
    ldy #>EXPLOSION_LOAD_ADDR
    jsr LOAD
    rts

load_gem:
    lda #7
    ldx #<gem_filename
    ldy #>gem_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<GEM_LOAD_ADDR 
    ldy #>GEM_LOAD_ADDR
    jsr LOAD
    rts

load_font:
    lda #8
    ldx #<font_filename
    ldy #>font_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<TILEBASE_L1_ADDR 
    ldy #>TILEBASE_L1_ADDR
    jsr LOAD
    rts

load_mine:
    lda #8
    ldx #<mine_filename
    ldy #>mine_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<MINE_1_LOAD_ADDR 
    ldy #>MINE_1_LOAD_ADDR
    jsr LOAD
    rts

.endif