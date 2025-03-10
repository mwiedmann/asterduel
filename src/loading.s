.ifndef LOADING_S
LOADING_S = 1

star_tiles_filename: .asciiz "stars.bin"
star_field_filename: .asciiz "field.bin"
ship_filename: .asciiz "ship.bin"
ship_thrust_filename: .asciiz "shipthr.bin"
astbig_filename: .asciiz "astbig.bin"
laser_filename: .asciiz "laser.bin"
overlay_filename: .asciiz "overlay.bin"

load_sprites:
    jsr load_star_tiles
    jsr load_star_field
    jsr load_overlay
    jsr load_ship
    jsr load_ship_thust
    jsr load_astbig
    jsr load_laser
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

load_ship:
    lda #8
    ldx #<ship_filename
    ldy #>ship_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_LOAD_ADDR 
    ldy #>SHIP_LOAD_ADDR
    jsr LOAD
    rts

load_ship_thust:
    lda #11
    ldx #<ship_thrust_filename
    ldy #>ship_thrust_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_THRUST_LOAD_ADDR 
    ldy #>SHIP_THRUST_LOAD_ADDR
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

load_laser:
    lda #9
    ldx #<laser_filename
    ldy #>laser_filename
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

.endif