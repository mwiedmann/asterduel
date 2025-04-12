.ifndef TILES_S
TILES_S = 1

TRANS_TILE = 58

point_to_mapbase_l1:
    lda #<MAPBASE_L1_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_L1_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    rts

point_to_mapbase_l0:
    lda #<MAPBASE_L0_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_L0_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    rts

stats_changed: .byte 1

update_stats:
    lda stats_changed
    cmp #0
    bne @show_stats
    stz stats_changed
    rts
@show_stats:
    lda base_1_energy
    sta num_to_convert
    jsr convert_to_bcd
    ; Point to the base energy section of mapbase
    lda #<(MAPBASE_L1_ADDR+BASE_1_ENERGY_TILE_COUNT)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+BASE_1_ENERGY_TILE_COUNT)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    jsr show_number

    lda ship_1_energy
    sta num_to_convert
    jsr convert_to_bcd
    ; Point to the base energy section of mapbase
    lda #<(MAPBASE_L1_ADDR+SHIP_1_ENERGY_TILE_COUNT)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+SHIP_1_ENERGY_TILE_COUNT)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    jsr show_single_digit

    lda shield_1_energy
    sta num_to_convert
    jsr convert_to_bcd
    ; Point to the base energy section of mapbase
    lda #<(MAPBASE_L1_ADDR+SHIELD_1_ENERGY_TILE_COUNT)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+SHIELD_1_ENERGY_TILE_COUNT)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    jsr show_number

    lda base_2_energy
    sta num_to_convert
    jsr convert_to_bcd
    ; Point to the base energy section of mapbase
    lda #<(MAPBASE_L1_ADDR+BASE_2_ENERGY_TILE_COUNT)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+BASE_2_ENERGY_TILE_COUNT)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    jsr show_number

    lda ship_2_energy
    sta num_to_convert
    jsr convert_to_bcd
    ; Point to the base energy section of mapbase
    lda #<(MAPBASE_L1_ADDR+SHIP_2_ENERGY_TILE_COUNT)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+SHIP_2_ENERGY_TILE_COUNT)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    jsr show_single_digit

    lda shield_2_energy
    sta num_to_convert
    jsr convert_to_bcd
    ; Point to the base energy section of mapbase
    lda #<(MAPBASE_L1_ADDR+SHIELD_2_ENERGY_TILE_COUNT)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+SHIELD_2_ENERGY_TILE_COUNT)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    jsr show_number
    rts

show_number:
    ldx #1
@next_num:
    lda bcd, x
    jsr get_font_num
    cpx #1
    beq @skip_hi_num
    lda num_high
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
@skip_hi_num:
    lda num_low
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    dex
    cpx #255
    bne @next_num
    rts

show_single_digit:
    lda bcd
    jsr get_font_num
    lda num_low
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    rts

; Assumes char is in A reg
get_font_char:
    cmp #193
    bcc @non_letter
    sec
    sbc #193
    rts
@non_letter:
    sec
    sbc #6
    rts


; Assumes num is in A reg
num_low: .byte 0
num_high: .byte 0

get_font_num:
    pha
    and #%1111 ; remove high part
    clc
    adc #42
    sta num_low
    pla
    ror
    ror
    ror
    ror
    and #%1111 ; remove high part
    clc
    adc #42
    sta num_high
    rts


.endif