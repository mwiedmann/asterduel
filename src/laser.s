.ifndef LASER_S
LASER_S = 1


create_laser_sprites:
    ldx #0
    stx sp_entity_count
    ldx #SHIP_1_LASER_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*SHIP_1_LASER_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*SHIP_1_LASER_ENTITY_NUM_START)
    stx sp_offset+1
@next_laser:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    lda #0
    sta param1
    jsr reset_active_entity
    lda #<SHIP_1_LASER_LOAD_ADDR ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>SHIP_1_LASER_LOAD_ADDR ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #<(SHIP_1_LASER_LOAD_ADDR>>16) ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    jsr set_laser_attr
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y
    sta cs_sprite_num ; pass the sprite_num for the enemy and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
    jsr create_sprite
    inc cs_sprite_num
    jsr create_sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    inc sp_num
    inc sp_num ; 2 because of ghost sprites
    inc sp_entity_count
    lda sp_entity_count
    cmp #SHIP_1_LASER_COUNT
    bne @next_laser
    rts

set_laser_attr:
    lda #0
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_active
    sta (active_entity), y
    lda #LASER_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #12
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #2
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%00110110
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%01000000
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #1
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y ; Laser wraps around screen
    rts

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