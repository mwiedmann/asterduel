.ifndef SHIP_S
SHIP_S = 1

ship_1_drop_count: .byte BASE_ENERGY_COUNT
ship_2_drop_count: .byte BASE_ENERGY_COUNT

create_ships:
    jsr create_ship_1
    jsr create_ship_2
    rts

check_ship_death:
    dec
    sta (active_entity), y
    cmp #0
    beq @respawn_ship
    rts
@respawn_ship:
    lda en_entity_count
    cmp #0
    bne @respawn_ship_2
    jsr create_ship_1
    rts
@respawn_ship_2:
    jsr create_ship_2
    rts

create_ship_1:
    jsr set_ship_1_as_active
    lda #1 ; visible for test
    sta param1 ; ship should not be visible to start
    jsr reset_active_entity
    lda #<(SHIP_1_X_START<<5)
    ldy #Entity::_x
    sta (active_entity), y
    lda #>(SHIP_1_X_START<<5)
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #<((120-8)<<5)
    ldy #Entity::_y
    sta (active_entity), y
    lda #>((120-8)<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    ; Top lane for ship_1
    lda #0
    ldy #Entity::_lane
    sta (active_entity), y
    lda #SHIP_1_SPRITE_NUM ; Ship sprite num
    ldy #Entity::_sprite_num
    sta (active_entity), y
    jsr create_ship
    lda #<SHIP_1_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>SHIP_1_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #<(SHIP_1_LOAD_ADDR>>16) ; Ship img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #SHIP_1_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #%01011100
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%10000000
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #4
    ldy #Entity::_ang
    sta (active_entity), y
    ; pass the sprite_num for the ship and create its sprite
    lda #SHIP_1_SPRITE_NUM
    sta cs_sprite_num
    lda #%10100000 ; 32x32
    sta cs_size
    jsr create_sprite
    lda #(SHIP_1_SPRITE_NUM+1)
    sta cs_sprite_num
    lda #%10100000 ; 32x32
    sta cs_size
    jsr create_sprite
    rts

create_ship_2:
    jsr set_ship_2_as_active
    lda #1 ; visible for test
    sta param1 ; ship should not be visible to start
    jsr reset_active_entity
    lda #<(SHIP_2_X_START<<5)
    ldy #Entity::_x
    sta (active_entity), y
    lda #>(SHIP_2_X_START<<5)
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #<((120-8)<<5)
    ldy #Entity::_y
    sta (active_entity), y
    lda #>((120-8)<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    ; Bottom lane for ship_2
    lda #1
    ldy #Entity::_lane
    sta (active_entity), y
    lda #SHIP_2_SPRITE_NUM ; Ship sprite num
    ldy #Entity::_sprite_num
    sta (active_entity), y
    jsr create_ship
    lda #<SHIP_2_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>SHIP_2_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #<(SHIP_2_LOAD_ADDR>>16) ; Ship img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #SHIP_2_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #%10101100
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%01000000
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #12
    ldy #Entity::_ang
    sta (active_entity), y
    lda #<(-32)
    ldy #Entity::_vel_x
    sta (active_entity), y
    lda #>(-32)
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    lda #<(-32)
    ldy #Entity::_vel_y
    sta (active_entity), y
    lda #>(-32)
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    ; pass the sprite_num for the ship and create its sprite
    lda #SHIP_2_SPRITE_NUM
    sta cs_sprite_num
    lda #%10100000 ; 32x32
    sta cs_size
    jsr create_sprite
    lda #(SHIP_2_SPRITE_NUM+1)
    sta cs_sprite_num
    lda #%10100000 ; 32x32
    sta cs_size
    jsr create_sprite
    rts

create_ship:
    lda #0
    ldy #Entity::_death_count
    sta (active_entity), y
    lda #1
    ldy #Entity::_is_scroll_focus
    sta (active_entity), y
    lda #32
    ldy #Entity::_size
    sta (active_entity), y
    lda #22
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #5
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #1 ; Ship active
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_active
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y ; Ship wraps around screen
    ldy #Entity::_has_ang
    sta (active_entity), y ; Ship sprite has angle based frames
    rts

set_ship_1_as_active:
    lda #<ship_1
    sta active_entity
    lda #>ship_1
    sta active_entity+1
    rts

set_ship_2_as_active:
    lda #<ship_2
    sta active_entity
    lda #>ship_2
    sta active_entity+1
    rts

set_ship_1_as_ghost:
    lda #<ship_1
    sta comp_entity1
    lda #>ship_1
    sta comp_entity1+1
    rts

set_ship_2_as_ghost:
    lda #<ship_2
    sta comp_entity1
    lda #>ship_2
    sta comp_entity1+1
    rts

thrusting_ship_img_1:
    lda #<SHIP_1_THRUST_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_1_THRUST_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_1_THRUST_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

normal_ship_img_1:
    lda #<SHIP_1_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_1_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_1_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

thrusting_ship_img_2:
    lda #<SHIP_2_THRUST_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_2_THRUST_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_2_THRUST_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

normal_ship_img_2:
    lda #<SHIP_2_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_2_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_2_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

shield_1_cleared: .byte 0
shield_2_cleared: .byte 0

check_shields_and_bases:
    lda shield_1_cleared
    cmp #1
    beq @check_shield_2
    lda shield_1_energy
    cmp #0
    bne @check_shield_2
    ; shield 1 down
    jsr clear_shield_1
@check_shield_2:
    lda shield_2_cleared
    cmp #1
    beq @check_base_1
    lda shield_2_energy
    cmp #0
    bne @check_base_1
    ; shield 2 down
    jsr clear_shield_2
@check_base_1:
    lda base_1_energy
    cmp #0
    bne @check_base_2
    jsr ship_2_wins
@check_base_2:
    lda base_2_energy
    cmp #0
    bne @done
    lda #1
    sta game_over
    jsr create_ship_2
@done:
    rts

clear_shield_1:
    lda #<(MAPBASE_L0_ADDR+(BOUNDARY_LEFT_TILE_X*2))
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L0_ADDR+(BOUNDARY_LEFT_TILE_X*2))
    sta VERA_ADDR_MID
    lda #%10010000
    sta VERA_ADDR_HI_SET
    ldx #0
    lda #0
@next_eraser:
    inc
    cmp #5
    bne @erase_section
    lda #1
@erase_section:
    sta VERA_DATA0
    inx
    cpx #15
    beq @shield_erased
    bra @next_eraser
@shield_erased:
    lda #1
    sta shield_1_cleared
    rts

clear_shield_2:
    lda #<(MAPBASE_L0_ADDR+(BOUNDARY_RIGHT_TILE_X*2))
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L0_ADDR+(BOUNDARY_RIGHT_TILE_X*2))
    sta VERA_ADDR_MID
    lda #%10010000
    sta VERA_ADDR_HI_SET
    ldx #0
    lda #0
@next_eraser:
    inc
    cmp #5
    bne @erase_section
    lda #1
@erase_section:
    sta VERA_DATA0
    inx
    cpx #15
    beq @shield_erased
    bra @next_eraser
@shield_erased:
    lda #1
    sta shield_1_cleared
    rts

end_game_count: .byte 0
end_exp_y: .byte 0
end_game_exp_count: .byte 0

create_explosion_base2:
    jsr set_ship_2_as_active
    ldy #Entity::_pixel_x
    lda #<BASE_SHIP_2_ENERGY_DROP_X
    sta (active_entity), y
    ldy #Entity::_pixel_x+1
    lda #>BASE_SHIP_2_ENERGY_DROP_X
    sta (active_entity), y
    lda #<600
    ldy #Entity::_pixel_show_x
    sta (active_entity), y
    lda #>600
    ldy #Entity::_pixel_show_x+1
    sta (active_entity), y

    ldy #Entity::_pixel_y+1
    lda end_exp_y
    sta (active_entity), y
    ldy #Entity::_pixel_y+1
    lda #0
    sta (active_entity), y
    clc
    lda end_exp_y
    adc #240
    ldy #Entity::_pixel_show_y
    sta (active_entity), y
    lda #0
    adc #0
    ldy #Entity::_pixel_show_y+1
    sta (active_entity), y
    clc
    lda end_exp_y
    adc #75
    sta end_exp_y
    jsr create_explosion_active_entity
    ;jsr sound_explode
    rts

ship_1_wins:
    stz end_game_count
    stz end_game_exp_count
    jsr destroy_ship_2
    jsr update_oneshots
    jsr show_ghosts
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    lda end_game_count
    cmp #5
    bne @continue
    stz end_game_count
    jsr create_explosion_base2
    inc end_game_exp_count
    lda end_game_exp_count
    cmp #45
    beq @done
@continue:
    inc end_game_count
    jsr update_oneshots
    stz waitflag
    bra @waiting
@done:
    rts

ship_2_wins:
    lda #1
    sta game_over
    rts

.endif
