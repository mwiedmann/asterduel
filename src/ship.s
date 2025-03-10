.ifndef SHIP_S
SHIP_S = 1

create_ships:
    jsr create_ship_1
    jsr create_ship_2
    rts

create_ship_1:
    jsr set_ship_1_as_active
    lda #1 ; visible for test
    sta param1 ; ship should not be visible to start
    jsr reset_active_entity
    ; Top lane for ship_1
    lda #0
    ldy #Entity::_lane
    sta (active_entity), y
    lda #SHIP_1_SPRITE_NUM ; Ship sprite num
    ldy #Entity::_sprite_num
    sta (active_entity), y
    jsr create_ship
    lda #4
    ldy #Entity::_ang
    sta (active_entity), y
    jsr create_laser_sprites
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
    ; Bottom lane for ship_2
    lda #1
    ldy #Entity::_lane
    sta (active_entity), y
    lda #SHIP_2_SPRITE_NUM ; Ship sprite num
    ldy #Entity::_sprite_num
    sta (active_entity), y
    jsr create_ship
    lda #12
    ldy #Entity::_ang
    sta (active_entity), y
    lda #<(-32)
    ldy #Entity::_vel_x
    sta (active_entity), y
    lda #>(-32)
    ldy #Entity::_vel_x+1
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
    lda #1
    ldy #Entity::_is_scroll_focus
    sta (active_entity), y
    lda #SHIP_TYPE
    ldy #Entity::_type
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
    lda #%00111111
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%10000000
    ldy #Entity::_collision_id
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
    lda #<SHIP_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>SHIP_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #<(SHIP_LOAD_ADDR>>16) ; Ship img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
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

thrusting_ship_img:
    lda #<SHIP_THRUST_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_THRUST_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_THRUST_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

normal_ship_img:
    lda #<SHIP_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

.endif
