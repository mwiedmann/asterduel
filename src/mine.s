.ifndef MINE_S
MINE_S = 1

mine_y_pos: .word ((4*16)<<5), ((5*16)<<5), ((7*16)<<5), ((8*16)<<5), ((10*16)<<5), ((11*16)<<5)
mine_1_x_pos: .word (((3*16)-8)<<5), (((3*16)-8)<<5), (((5*16)-8)<<5), (((5*16)-8)<<5), (((3*16)-8)<<5), (((3*16)-8)<<5)
mine_1_offset: .byte 0
mine_2_x_pos: .word (1992<<5), (1992<<5), ((1992-32)<<5), ((1992-32)<<5), (1992<<5), (1992<<5)
mine_2_offset: .byte 0

create_mine_sprites:
    jsr create_mine_1_sprites
    jsr create_mine_2_sprites
    rts

create_mine_1_sprites:
    lda #<MINE_1_LOAD_ADDR
    sta us_img_addr
    lda #>MINE_1_LOAD_ADDR
    sta us_img_addr+1
    lda #<(MINE_1_LOAD_ADDR>>16)
    sta us_img_addr+2
    stz sp_entity_count
    ldx #MINE_1_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*MINE_1_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*MINE_1_ENTITY_NUM_START)
    stx sp_offset+1
next_mine_1:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    stz param1 ; Not visible
    jsr reset_active_entity
    clc
    lda sp_entity_count
    rol
    tax
    lda #0
    ldy #Entity::_x
    sta (active_entity), y
    ldy #Entity::_x+1
    sta (active_entity), y
    ldy #Entity::_y
    sta (active_entity), y
    ldy #Entity::_y+1
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    ;jsr move_entity ; Update the pixel positions
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda us_img_addr+2 ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #MINE_1_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #10
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #3
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%01000000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000010
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set mine sprite num
    sta cs_sprite_num ; pass the sprite_num for the mine and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
    jsr create_sprite
    inc cs_sprite_num
    jsr create_sprite ; create 2nd sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    clc
    inc sp_num
    inc sp_num ; 2 because of ghost sprites
    inc sp_entity_count
    lda sp_entity_count
    cmp #MINE_1_COUNT
    beq @done
    jmp next_mine_1
@done:
    rts

create_mine_2_sprites:
    lda #<MINE_2_LOAD_ADDR
    sta us_img_addr
    lda #>MINE_2_LOAD_ADDR
    sta us_img_addr+1
    lda #<(MINE_2_LOAD_ADDR>>16)
    sta us_img_addr+2
    stz sp_entity_count
    ldx #MINE_2_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*MINE_2_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*MINE_2_ENTITY_NUM_START)
    stx sp_offset+1
next_mine_2:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    stz param1 ; Not visible
    jsr reset_active_entity
    clc
    lda sp_entity_count
    rol
    tax
    lda #0
    ldy #Entity::_x
    sta (active_entity), y
    ldy #Entity::_x+1
    sta (active_entity), y
    ldy #Entity::_y
    sta (active_entity), y
    ldy #Entity::_y+1
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    ;jsr move_entity ; Update the pixel positions
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda us_img_addr+2 ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #MINE_2_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #10
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #3
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%10000000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000001
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set mine sprite num
    sta cs_sprite_num ; pass the sprite_num for the mine and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
    jsr create_sprite
    inc cs_sprite_num
    jsr create_sprite ; create 2nd sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    clc
    inc sp_num
    inc sp_num ; 2 because of ghost sprites
    inc sp_entity_count
    lda sp_entity_count
    cmp #MINE_2_COUNT
    beq @done
    jmp next_mine_2
@done:
    rts

mine_x: .word 32
mine_y: .word 32
mine_offset: .word 0
mine_entity_count:.byte 0

launch_mine_1:
    ldx mine_1_offset
    lda mine_1_x_pos, x
    sta mine_x
    lda mine_1_x_pos+1, x
    sta mine_x+1
    lda mine_y_pos, x
    sta mine_y
    lda mine_y_pos+1, x
    sta mine_y+1
@mine_checks_done:
    stz mine_entity_count
    ldx #<(.sizeof(Entity)*MINE_1_ENTITY_NUM_START)
    stx mine_offset
    ldx #>(.sizeof(Entity)*MINE_1_ENTITY_NUM_START)
    stx mine_offset+1
@next_entity:
    clc
    lda #<entities
    adc mine_offset
    sta mine_entity
    lda #>entities
    adc mine_offset+1
    sta mine_entity+1
    ldy #Entity::_active
    lda (mine_entity), y
    cmp #0
    bne @skip_entity
    jsr found_free_mine
    ; ; Set its angle and vel
    lda mine_1_offset
    inc
    inc
    cmp #12
    bne @save_offset
    lda #0
@save_offset:
    sta mine_1_offset
    ; lda #4
    ; ldy #Entity::_ang
    ; sta (mine_entity), y
    lda #255
    ldy #Entity::_vel_x
    sta (mine_entity), y
    bra @done
@skip_entity:
    clc
    lda mine_offset
    adc #.sizeof(Entity)
    sta mine_offset
    lda mine_offset+1
    adc #0
    sta mine_offset+1
    inc mine_entity_count
    lda mine_entity_count
    cmp #MINE_1_COUNT
    bne @next_entity
@done:
    rts

launch_mine_2:
    ldx mine_2_offset
    lda mine_2_x_pos, x
    sta mine_x
    lda mine_2_x_pos+1, x
    sta mine_x+1
    lda mine_y_pos, x
    sta mine_y
    lda mine_y_pos+1, x
    sta mine_y+1
@mine_checks_done:
    stz mine_entity_count
    ldx #<(.sizeof(Entity)*MINE_2_ENTITY_NUM_START)
    stx mine_offset
    ldx #>(.sizeof(Entity)*MINE_2_ENTITY_NUM_START)
    stx mine_offset+1
@next_entity:
    clc
    lda #<entities
    adc mine_offset
    sta mine_entity
    lda #>entities
    adc mine_offset+1
    sta mine_entity+1
    ldy #Entity::_active
    lda (mine_entity), y
    cmp #0
    bne @skip_entity
    jsr found_free_mine
    lda mine_2_offset
    inc
    inc
    cmp #12
    bne @save_offset
    lda #0
@save_offset:
    sta mine_2_offset
    lda #<(-192)
    ldy #Entity::_vel_x
    sta (mine_entity), y
    lda #>(-192)
    ldy #Entity::_vel_x+1
    sta (mine_entity), y
    bra @done
@skip_entity:
    clc
    lda mine_offset
    adc #.sizeof(Entity)
    sta mine_offset
    lda mine_offset+1
    adc #0
    sta mine_offset+1
    inc mine_entity_count
    lda mine_entity_count
    cmp #MINE_2_COUNT
    bne @next_entity
@done:
    rts

found_free_mine:
    ; Clear any existing velocity
    lda #0
    ldy #Entity::_vel_x
    sta (mine_entity), y
    ldy #Entity::_vel_x+1
    sta (mine_entity), y
    ldy #Entity::_vel_y
    sta (mine_entity), y
    ldy #Entity::_vel_y+1
    sta (mine_entity), y
    lda #1
    ldy #Entity::_visible
    sta (mine_entity), y
    ldy #Entity::_active
    sta (mine_entity), y
    lda mine_x
    ldy #Entity::_x
    sta (mine_entity), y
    lda mine_x+1
    ldy #Entity::_x+1
    sta (mine_entity), y
    lda mine_y
    ldy #Entity::_y
    sta (mine_entity), y
    lda mine_y+1
    ldy #Entity::_y+1
    sta (mine_entity), y
    rts

.endif
