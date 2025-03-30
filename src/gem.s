.ifndef GEM_S
GEM_S = 1

create_gem_sprites:
    lda #<GEM_LOAD_ADDR
    sta us_img_addr
    lda #>GEM_LOAD_ADDR
    sta us_img_addr+1
    lda #<(GEM_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #GEM_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset+1
next_gem:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    stz param1 ; Not visible
    jsr reset_active_entity
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda us_img_addr+2 ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #GEM_TYPE
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
    lda #%11000000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000100
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    lda #3
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set sprite num
    sta cs_sprite_num ; pass the sprite_num and create its sprite
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
    inc sp_num
    inc sp_num ; 2 because of ghost sprites
    inc sp_entity_count
    lda sp_entity_count
    cmp #GEM_COUNT
    beq @done
    jmp next_gem
@done:
    rts


dg_x: .word 0
dg_y: .word 0

drop_gem_from_active_entity:
    ldy #Entity::_x
    lda (active_entity), y
    sta dg_x
    ldy #Entity::_x+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta dg_x+1
    ldy #Entity::_y
    lda (active_entity), y
    sta dg_y
    ldy #Entity::_y+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta dg_y+1
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*GEM_ENTITY_NUM_START)
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
    bra @found_free_gem
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
    cmp #GEM_COUNT
    bne @next_entity
    rts
@found_free_gem:
    ; make it visible and config it
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_active
    sta (active_entity), y
    lda dg_x
    ldy #Entity::_x
    sta (active_entity), y
    lda dg_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda dg_y
    ldy #Entity::_y
    sta (active_entity), y
    lda dg_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    jsr set_gem_vel
@done:
    rts

GEM_VELOCITY=3

gem_vel: .word 65535-GEM_VELOCITY, 65535-GEM_VELOCITY, GEM_VELOCITY, 65535-GEM_VELOCITY, GEM_VELOCITY, GEM_VELOCITY, 65535-GEM_VELOCITY, GEM_VELOCITY
gem_vel_idx: .byte 0

set_gem_vel:
    ; _vel_x
    ldx gem_vel_idx
    lda gem_vel, x
    ldy #Entity::_vel_x 
    sta (active_entity), y
    inx
    lda gem_vel, x
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    inx
    ; _vel_y
    lda gem_vel, x
    ldy #Entity::_vel_y
    sta (active_entity), y
    inx
    lda gem_vel, x
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    inx
    cpx #16
    bne @done
    ldx #0
@done:
    stx gem_vel_idx
    rts

.endif
