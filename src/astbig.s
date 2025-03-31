.ifndef ASTBIG_S
ASTBIG_S = 1

astbig_start_x:         .word AST_LAUNCH_X_START<<5, (AST_LAUNCH_X_START+AST_LAUNCH_X_ADJ)<<5, (AST_LAUNCH_X_START+(AST_LAUNCH_X_ADJ*2))<<5, (AST_LAUNCH_X_START+(AST_LAUNCH_X_ADJ*3))<<5, (AST_LAUNCH_X_START+(AST_LAUNCH_X_ADJ*4))<<5, (AST_LAUNCH_X_START+(AST_LAUNCH_X_ADJ*5))<<5
astbig_start_ang:       .word 1, 7, 1, 9, 15, 9
astbig_accel:           .byte 1, 2, 2, 1, 1,  2

create_astbig_sprites:
    lda #<ASTBIG_LOAD_ADDR
    sta us_img_addr
    lda #>ASTBIG_LOAD_ADDR
    sta us_img_addr+1
    lda #<(ASTBIG_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #ASTBIG_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx sp_offset+1
next_astbig:
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
    lda sp_entity_count ; Use this to get an index into astbig_start_?
    rol
    tax
    lda astbig_start_x, x
    ldy #Entity::_x
    sta (active_entity), y
    lda astbig_start_x+1, x
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #0
    ldy #Entity::_lane
    sta (active_entity), y
    ;lda astbig_start_y, x
    lda #<(120<<5)
    ldy #Entity::_y
    sta (active_entity), y
    ;lda astbig_start_y+1, x
    lda #>(120<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    lda astbig_start_ang, x
    ;lda #3
    ldy #Entity::_ang
    sta (active_entity), y
    jsr move_entity ; Update the pixel positions
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda us_img_addr+2 ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #ASTBIG_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #2
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda #32
    ldy #Entity::_size
    sta (active_entity), y
    lda #20
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #6
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%11110000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00001000
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_death_count
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set enemy sprite num
    sta cs_sprite_num ; pass the sprite_num for the enemy and create its sprite
    lda #%10100000
    sta cs_size ; 32x32
    jsr create_sprite
    inc cs_sprite_num
    jsr create_sprite ; create 2nd sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    ; Increase the ASTBIG img addr
    clc
    inc sp_num
    inc sp_num ; 2 because of ghost sprites
    inc sp_entity_count
    lda sp_entity_count
    cmp #ASTBIG_COUNT
    beq @done
    jmp next_astbig
@done:
    rts

launch_amount: .byte 0
astbig_offset: .word 0
astbig_entity_count:.byte 0

launch_astbigs:
    lda #ASTBIG_COUNT ; might be over max
    sta launch_amount
    ldx #0
@next_astbig:
    stx launch_big_accel_index
    phx
    jsr launch_astbig
    plx
    inx
    cpx launch_amount
    bne @next_astbig
    rts

launch_big_accel_index: .byte 0

launch_astbig:
    ldx #0
    stx astbig_entity_count
    ldx #<(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx astbig_offset
    ldx #>(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx astbig_offset+1
@next_entity:
    clc
    lda #<entities
    adc astbig_offset
    sta astbig_entity
    lda #>entities
    adc astbig_offset+1
    sta astbig_entity+1
    ldy #Entity::_active
    lda (astbig_entity), y
    cmp #1
    beq @skip_entity
    ; Found a free astbig
    lda #1
    ldy #Entity::_visible
    sta (astbig_entity), y
    ldy #Entity::_active
    sta (astbig_entity), y
    ldx launch_big_accel_index ; Accelerate the astbig a few times to get it started moving
    lda astbig_accel, x
@initial_accel:
    pha
    lda astbig_entity
    sta acc_entity
    lda astbig_entity+1
    sta acc_entity+1
    jsr accel_entity
    pla
    dec
    cmp #0
    beq @done
    bra @initial_accel
@skip_entity:
    clc
    lda astbig_offset
    adc #.sizeof(Entity)
    sta astbig_offset
    lda astbig_offset+1
    adc #0
    sta astbig_offset+1
    inc astbig_entity_count
    lda astbig_entity_count
    cmp #ASTBIG_COUNT
    bne @next_entity
@done:
    rts

.endif
