.ifndef LASER_S
LASER_S = 1


create_laser_sprites:
    jsr create_laser1_sprites
    jsr create_laser2_sprites
    rts

create_laser1_sprites:
    stz sp_entity_count
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
    stz param1
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
    lda #%01001000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00100000
    ldy #Entity::_collision_id
    sta (active_entity), y
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

create_laser2_sprites:
    stz sp_entity_count
    ldx #SHIP_2_LASER_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*SHIP_2_LASER_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*SHIP_2_LASER_ENTITY_NUM_START)
    stx sp_offset+1
@next_laser:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    stz param1
    jsr reset_active_entity
    lda #<SHIP_2_LASER_LOAD_ADDR ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>SHIP_2_LASER_LOAD_ADDR ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #<(SHIP_2_LASER_LOAD_ADDR>>16) ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    jsr set_laser_attr
    lda #%10001000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00010000
    ldy #Entity::_collision_id
    sta (active_entity), y
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
    cmp #SHIP_2_LASER_COUNT
    bne @next_laser
    rts

set_laser_attr:
    lda #0
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_active
    sta (active_entity), y
    ldy #Entity::_death_count
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
    lda #1
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y ; Laser wraps around screen
    rts

laser_offset: .word 0
laser_entity_count:.byte 0

fire_laser_1:
    lda ship_1+Entity::_active
    cmp #1
    beq @ship_active
    rts
@ship_active:
    stz laser_entity_count
    ldx #<(.sizeof(Entity)*SHIP_1_LASER_ENTITY_NUM_START)
    stx laser_offset
    ldx #>(.sizeof(Entity)*SHIP_1_LASER_ENTITY_NUM_START)
    stx laser_offset+1
@next_entity:
    clc
    lda #<entities
    adc laser_offset
    sta laser_entity
    lda #>entities
    adc laser_offset+1
    sta laser_entity+1
    ldy #Entity::_active
    lda (laser_entity), y
    cmp #0
    beq @good_entity
    ; try next entity
    clc
    lda laser_offset
    adc #.sizeof(Entity)
    sta laser_offset
    lda laser_offset+1
    adc #0
    sta laser_offset+1
    inc laser_entity_count
    lda laser_entity_count
    cmp #SHIP_1_LASER_COUNT
    bne @next_entity
    rts
@good_entity:
    ;jsr sound_shoot
    ; Found a free laser
    ; Move it to the ship position and launch it!
    ldy #0 ; copy bytes 0-20
@copy:
    lda ship_1, y
    sta (laser_entity), y
    iny
    cpy #21
    bne @copy
    lda #1
    ldy #Entity::_active
    sta (laser_entity), y
    lda #LASER_DESTROY_TICKS
    ldy #Entity::_destroy_ticks
    sta (laser_entity), y
    ; adjust position by 8 since missiles are smaller
    clc
    ldy #Entity::_x
    lda (laser_entity), y
    adc #<(8<<5)
    sta (laser_entity), y
    ldy #Entity::_x+1
    lda (laser_entity), y
    adc #>(8<<5)
    sta (laser_entity), y
    clc
    ldy #Entity::_y
    lda (laser_entity), y
    adc #<(8<<5)
    sta (laser_entity), y
    ldy #Entity::_y+1
    lda (laser_entity), y
    adc #>(8<<5)
    sta (laser_entity), y
    ldx #0
@initial_accel:
    ; Accelerate the laser a few times to get it started moving
    phx
    lda laser_entity
    sta acc_entity
    lda laser_entity+1
    sta acc_entity+1
    jsr accel_entity
    plx
    inx
    cpx #5
    bne @initial_accel
    ;jsr move_entity ; Move it once to get some distance from ship
    rts

fire_laser_2:
    lda ship_2+Entity::_active
    cmp #1
    beq @ship_active
    rts
@ship_active:
    stz laser_entity_count
    ldx #<(.sizeof(Entity)*SHIP_2_LASER_ENTITY_NUM_START)
    stx laser_offset
    ldx #>(.sizeof(Entity)*SHIP_2_LASER_ENTITY_NUM_START)
    stx laser_offset+1
@next_entity:
    clc
    lda #<entities
    adc laser_offset
    sta laser_entity
    lda #>entities
    adc laser_offset+1
    sta laser_entity+1
    ldy #Entity::_active
    lda (laser_entity), y
    cmp #0
    beq @good_entity
    ; try next entity
    clc
    lda laser_offset
    adc #.sizeof(Entity)
    sta laser_offset
    lda laser_offset+1
    adc #0
    sta laser_offset+1
    inc laser_entity_count
    lda laser_entity_count
    cmp #SHIP_2_LASER_COUNT
    bne @next_entity
    rts
@good_entity:
    ;jsr sound_shoot
    ; Found a free laser
    ; Move it to the ship position and launch it!
    ldy #0 ; copy bytes 0-20
@copy:
    lda ship_2, y
    sta (laser_entity), y
    iny
    cpy #21
    bne @copy
    lda #1
    ldy #Entity::_active
    sta (laser_entity), y
    lda #LASER_DESTROY_TICKS
    ldy #Entity::_destroy_ticks
    sta (laser_entity), y
    ; adjust position by 8 since missiles are smaller
    clc
    ldy #Entity::_x
    lda (laser_entity), y
    adc #<(8<<5)
    sta (laser_entity), y
    ldy #Entity::_x+1
    lda (laser_entity), y
    adc #>(8<<5)
    sta (laser_entity), y
    clc
    ldy #Entity::_y
    lda (laser_entity), y
    adc #<(8<<5)
    sta (laser_entity), y
    ldy #Entity::_y+1
    lda (laser_entity), y
    adc #>(8<<5)
    sta (laser_entity), y
    ldx #0
@initial_accel:
    ; Accelerate the laser a few times to get it started moving
    phx
    lda laser_entity
    sta acc_entity
    lda laser_entity+1
    sta acc_entity+1
    jsr accel_entity
    plx
    inx
    cpx #5
    bne @initial_accel
    ;jsr move_entity ; Move it once to get some distance from ship
    rts

.endif