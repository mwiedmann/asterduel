.ifndef LASER_S
LASER_S = 1

fire_laser:
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*SHIP_1_LASER_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*SHIP_1_LASER_ENTITY_NUM_START)
    stx sp_offset+1
@next_entity:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    ldy #Entity::_active
    lda (active_entity), y
    cmp #0
    bne @skip_entity
    ;jsr sound_shoot
    ; Found a free laser
    ; Move it to the ship position and launch it!
    ldy #0 ; copy bytes 0-20
@copy:
    lda ship_1, y
    sta (active_entity), y
    iny
    cpy #21
    bne @copy
    lda #1
    ldy #Entity::_active
    sta (active_entity), y
    lda #LASER_DESTROY_TICKS
    ldy #Entity::_destroy_ticks
    sta (active_entity), y
    ; adjust position by 8 since missiles are smaller
    clc
    ldy #Entity::_x
    lda (active_entity), y
    adc #<(8<<5)
    sta (active_entity), y
    ldy #Entity::_x+1
    lda (active_entity), y
    adc #>(8<<5)
    sta (active_entity), y
    clc
    ldy #Entity::_y
    lda (active_entity), y
    adc #<(8<<5)
    sta (active_entity), y
    ldy #Entity::_y+1
    lda (active_entity), y
    adc #>(8<<5)
    sta (active_entity), y
    ldx #0
@initial_accel:
    ; Accelerate the laser a few times to get it started moving
    phx
    jsr accel_entity
    plx
    inx
    cpx #5
    bne @initial_accel
    bra @done
@skip_entity:
    clc
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    inc sp_entity_count
    lda sp_entity_count
    cmp #SHIP_1_LASER_COUNT
    bne @next_entity
@done:
    ;jsr move_entity ; Move it once to get some distance from ship
    rts

.endif