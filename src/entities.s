.ifndef ENTITIES_S
ENTITIES_S = 1

en_offset: .word 0
en_entity_count: .byte 0
en_hold: .word 0

process_entities:
    jsr set_ship_1_as_active
    jsr check_ship_1_drop_energy
    ldx #0
    stx en_entity_count
    ldx #0
    stx en_offset
    stx en_offset+1
@next_entity:
    jsr process_entity
    clc
    lda en_offset
    adc #.sizeof(Entity)
    sta en_offset
    lda en_offset+1
    adc #0
    sta en_offset+1
    inc en_entity_count
    lda en_entity_count
    cmp #ENTITY_COUNT
    bne @next_entity
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS
    bne @done
    stz accelwait
@done:
    rts

inactivate_entity:
    lda #0
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_active
    sta (active_entity), y
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
    inc param1
    jsr update_sprite
    rts

process_entity:
    clc
    lda #<entities
    adc en_offset
    sta active_entity
    lda #>entities
    adc en_offset+1
    sta active_entity+1
    ; see if entity needs to respawn
    ldy #Entity::_death_count
    lda (active_entity), y
    cmp #0
    beq @check_active
    jsr check_ship_death
@check_active:
    ldy #Entity::_active
    lda (active_entity), y
    cmp #0
    beq @skip_entity ; Skip if not visible
    jsr check_left_boundary ; check left boundary
    lda #1
    cmp boundary_collision
    bne @continue_boundary_check
    bra @skip_entity  ; There was a boundary collision, move to next entity
@continue_boundary_check:
    jsr check_right_boundary ; check left boundary
    lda #1
    cmp boundary_collision
    bne @continue_process
    bra @skip_entity  ; There was a boundary collision, move to next entity
@continue_process:
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS ; We only thrust entities every few ticks (otherwise they take off SUPER fast)
    bne @skip_accel
    ldy #Entity::_has_accel
    lda (active_entity), y
    cmp #0
    beq @skip_accel
    jsr accel_entity
@skip_accel:
    ldy #Entity::_destroy_ticks ; See if entity is destroyed after some time
    lda (active_entity), y
    cmp #0
    beq @skip_destroy
    dec
    sta (active_entity), y
    cmp #0
    bne @skip_destroy
    jsr inactivate_entity
    rts
@skip_destroy:
    jsr move_entity
    lda en_entity_count
    cmp #0
    bne @check1
    jsr scroll_lane
    lda scrolltemp
    sta scroll_lane1_x
    lda scrolltemp+1
    sta scroll_lane1_x+1
    bra @skip_scroll
@check1:
    lda en_entity_count
    cmp #1
    bne @not_a_ship
    jsr scroll_lane
    lda scrolltemp
    sta scroll_lane2_x
    lda scrolltemp+1
    sta scroll_lane2_x+1
    bra @skip_scroll
@not_a_ship:
    ; We only want to call update_sprite for the 2 main ships
    ; The rest we only wanted to move
    rts
@skip_scroll:
    ;jsr enemy_logic
    ;jsr mine_logic
    stz param1 ; make entity not visible if out of bounds
    ;jsr check_entity_bounds
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
@skip_entity:
    ; See if enemy firing should reset
    ;lda enemywait
    ;cmp #ENEMY_SHOOT_TIME
    ;bne @skip_enemywait_reset
    ;lda #0
    ;sta enemywait
    rts
@skip_enemywait_reset:
    ;inc enemywait
    rts

ghost_x: .word 0
ghost_y: .word 0

show_ghosts:
    ldx #0
    stx sp_entity_count
    ldx #0
    stx sp_offset
    stx sp_offset+1
@next_entity:
    lda sp_entity_count
    cmp #2
    bcs @double_ghost
    bra @ghost_done
@double_ghost:
    lda #1
    sta flip_lane
    jsr ghost_sprite
@ghost_done:
    stz flip_lane
    jsr ghost_sprite
    clc
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    inc sp_entity_count
    lda sp_entity_count
    cmp #ENTITY_COUNT
    bne @next_entity
@done:
    rts

flip_lane: .byte 0

ghost_sprite:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    ldy #Entity::_active
    lda (active_entity), y
    cmp #1
    beq @continue_ghost ; Skip if not visible
    rts
@continue_ghost:
    ldy #Entity::_lane
    lda (active_entity), y
    ldy flip_lane
    cpy #0
    beq @no_flip_lane
    eor #1
@no_flip_lane:
    cmp #1
    beq @ghost_lane_1
@ghost_lane_0:
    jsr set_ship_2_as_ghost
    bra @calc_ghost
@ghost_lane_1:
    jsr set_ship_1_as_ghost
@calc_ghost:
    sec
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sbc (comp_entity1), y
    sta ghost_x
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sbc (comp_entity1), y
    sta ghost_x+1
    sec
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sbc (comp_entity1), y
    sta ghost_y
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sbc (comp_entity1), y
    sta ghost_y+1
    ; Adjust position
    ; First back them up
    ldy #Entity::_pixel_show_x
    lda (active_entity), y
    ldy #Entity::_pixel_hold_x
    sta (active_entity), y
    ldy #Entity::_pixel_show_x+1
    lda (active_entity), y
    ldy #Entity::_pixel_hold_x+1
    sta (active_entity), y
    ldy #Entity::_pixel_show_y
    lda (active_entity), y
    ldy #Entity::_pixel_hold_y
    sta (active_entity), y
    ldy #Entity::_pixel_show_y+1
    lda (active_entity), y
    ldy #Entity::_pixel_hold_y+1
    sta (active_entity), y
    clc
    ldy #Entity::_pixel_show_x
    lda (comp_entity1), y
    adc ghost_x
    sta (active_entity), y
    ldy #Entity::_pixel_show_x+1
    lda (comp_entity1), y
    adc ghost_x+1
    sta (active_entity), y

    ldy #Entity::_pixel_show_y
    lda (comp_entity1), y
    adc ghost_y
    sta (active_entity), y
    ldy #Entity::_pixel_show_y+1
    lda (comp_entity1), y
    adc ghost_y+1
    sta (active_entity), y

    ; Check if sprite off screen
    ldy #Entity::_pixel_show_x+1
    lda (active_entity), y
    cmp #>640
    bcc @show_ghost
    bne @hide_ghost
    ; check lower bits
    ldy #Entity::_pixel_show_x
    lda (active_entity), y
    cmp #<640
    bcc @show_ghost
    bne @hide_ghost
@show_ghost:
    lda #1
    bra @update_ghost
@hide_ghost:
    lda #0
@update_ghost:
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_sprite_num
    lda (active_entity), y
    ldy sp_entity_count
    cpy #2
    bcs @non_ship
    ; ship
    inc
@no_sprite_inc:
    sta param1
    jsr update_sprite
    bra @sprite_done
@non_ship:
    ldy flip_lane
    cpy #1
    beq @no_sprite_inc
    sta param1
    ; Just copy the other sprite
    jsr copy_sprite_set_pos
    bra @sprite_done
@sprite_done:
    lda #1 ; back to visible
    ldy #Entity::_visible
    sta (active_entity), y
    ; restore the values
    ldy #Entity::_pixel_hold_x
    lda (active_entity), y
    ldy #Entity::_pixel_show_x
    sta (active_entity), y
    ldy #Entity::_pixel_hold_x+1
    lda (active_entity), y
    ldy #Entity::_pixel_show_x+1
    sta (active_entity), y
    ldy #Entity::_pixel_hold_y
    lda (active_entity), y
    ldy #Entity::_pixel_show_y
    sta (active_entity), y
    ldy #Entity::_pixel_hold_y+1
    lda (active_entity), y
    ldy #Entity::_pixel_show_y+1
    sta (active_entity), y
    rts

scrolltemp: .word 0

scroll_lane:
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta scrolltemp
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta scrolltemp+1
    ; see if hit min
    lda scrolltemp+1
    cmp #>SHIP_MID
    bcc @less_than_mid
    bne @greater_than_mid
    ; check low bits
    lda scrolltemp
    cmp #<SHIP_MID
    bcs @greater_than_mid
@less_than_mid:
    stz scrolltemp
    stz scrolltemp+1
    bra @done
@greater_than_mid:
    ; see if greater than max
    ; see if hit min
    lda scrolltemp+1
    cmp #>SHIP_MAX
    bcc @less_than_max
    bne @greater_than_max
    ; check low bits
    lda scrolltemp
    cmp #<SHIP_MAX
    bcs @greater_than_max
    bra @less_than_max
@greater_than_max:
    lda #<SHIP_MAX_SCROLL
    sta scrolltemp
    lda #>SHIP_MAX_SCROLL
    sta scrolltemp+1
    ; Ship sprite position is too big...put on screen correctly
    sec
    lda #<2048
    ldy #Entity::_pixel_show_x
    sbc (active_entity), y
    sta (active_entity), y
    lda #>2048
    ldy #Entity::_pixel_show_x+1
    sbc (active_entity), y
    sta (active_entity), y
    sec
    lda #<640
    ldy #Entity::_pixel_show_x
    sbc (active_entity), y
    sta (active_entity), y
    lda #>640
    ldy #Entity::_pixel_show_x+1
    sbc (active_entity), y
    sta (active_entity), y
    bra @done
@less_than_max:
    ; This is a normal scroll between the min/max areas of the map
    ; adjust scroll
    sec
    lda scrolltemp
    sbc #<SHIP_MID
    sta scrolltemp
    lda scrolltemp+1
    sbc #>SHIP_MID
    sta scrolltemp+1
    ; put ship in middle
    lda #<SHIP_MID
    ldy #Entity::_pixel_show_x
    sta (active_entity), y
    lda #>SHIP_MID
    ldy #Entity::_pixel_show_x+1
    sta (active_entity), y
@done:
    rts

lastx: .word 0

move_entity:
    ; active_entity holds the address of the entity to move
    ; Add velocity to y position
    ldy #Entity::_y ; Point to _y lo bit
    lda (active_entity), y ; Get the _y (lo bit)
    ldy #Entity::_vel_y ; Get the _vel_y (lo bit)
    clc
    adc (active_entity), y ; Add the _vel_y (lo bit, moves entity y position)
    ldy #Entity::_y ; Point back to _y (lo bit) so we can update it
    sta (active_entity), y ; Store the updated _y (lo bit)
    
    ldy #Entity::_y+1 ; Point to _y hi bit
    lda (active_entity), y ; Get the _y (hi bit)
    ldy #Entity::_vel_y+1 ; Point to the _vel_y (hi bit)
    adc (active_entity), y ; Add the _vel_y (hi bit, moves entity y position)
    ldy #Entity::_y+1 ; Point back to _y (hi bit) so we can update it
    sta (active_entity), y ; Store the updated _y (hi bit)
    
    ; Add velocity to x position
    ldy #Entity::_x ; Point to _x lo bit
    lda (active_entity), y ; Get the _x (lo bit)
    sta lastx
    ldy #Entity::_vel_x ; Get the _vel_x (lo bit)
    clc
    adc (active_entity), y ; Add the _vel_x (lo bit, moves entity x position)
    ldy #Entity::_x ; Point back to _x (lo bit) so we can update it
    sta (active_entity), y ; Store the updated _x (lo bit)
    
    ldy #Entity::_x+1 ; Point to _x hi bit
    lda (active_entity), y ; Get the _x (hi bit)
    sta lastx+1
    ldy #Entity::_vel_x+1 ; Point to the _vel_x (hi bit)
    adc (active_entity), y ; Add the _vel_x (hi bit, moves entity x position)
    ldy #Entity::_x+1 ; Point back to _x (hi bit) so we can update it
    sta (active_entity), y ; Store the updated _x (hi bit)

    ldy #Entity::_type
    lda (active_entity), y
    cmp #SHIP_1_TYPE
    bne @check_ship_2
    ; Check if X<0
    ldy #Entity::_x+1 ; Point to _y hi bit
    lda (active_entity), y
    cmp #>LANE_X_BIG
    bcc @skip_ship_x_checks
    bne @ship_ob
    ; check low bits
    ldy #Entity::_x ; Point to _y lo bit
    lda (active_entity), y
    cmp #<LANE_X_BIG
    bcs @ship_ob
    bra @skip_ship_x_checks

@check_ship_2:
    ; TODO: Check ship 2 X OB
    bra @skip_ship_x_checks
@ship_ob:
    ; Put to last position
    lda lastx
    ldy #Entity::_x
    sta (active_entity), y
    lda lastx+1
    ldy #Entity::_x+1
    sta (active_entity), y
    ; and reverse velocity
    ldy #Entity::_vel_x
    lda (active_entity), y
    eor #$FF
    clc
    adc #1
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    lda (active_entity), y
    eor #$FF
    adc #0
    sta (active_entity), y
@skip_ship_x_checks:
    ; Check y bounds
    ; First check for a LARGE y pos (means went off top to negative number)
    ldy #Entity::_y+1 ; Point to _y hi bit
    lda (active_entity), y
    cmp #>LANE_BOTTOM_Y_BIG
    bcc @less_than_lane_bottom_big
    bne @greater_than_lane_bottom_big
    ; check low bits
    ldy #Entity::_y ; Point to _y lo bit
    lda (active_entity), y
    cmp #<LANE_BOTTOM_Y_BIG
    bcs @greater_than_lane_bottom_big
    bra @less_than_lane_bottom_big
@greater_than_lane_bottom_big:
    ; set to bottom of lane
    ldy #Entity::_y ; Point to _y lo bit
    lda #<LANE_BOTTOM_Y
    sta (active_entity), y
    ldy #Entity::_y+1
    lda #>LANE_BOTTOM_Y
    sta (active_entity), y
    bra @update_pixels
@less_than_lane_bottom_big:
    ; Second check for a smaller y pos (means went off bottom of lane)
    ldy #Entity::_y+1 ; Point to _y hi bit
    lda (active_entity), y
    cmp #>LANE_BOTTOM_Y
    bcc @less_than_lane_bottom
    bne @greater_than_lane_bottom
    ; check low bits
    ldy #Entity::_y ; Point to _y lo bit
    lda (active_entity), y
    cmp #<LANE_BOTTOM_Y
    bcs @greater_than_lane_bottom
    bra @less_than_lane_bottom
@greater_than_lane_bottom:
    ; set to top of lane
    ldy #Entity::_y ; Point to _y lo bit
    lda #0
    sta (active_entity), y
    ldy #Entity::_y+1
    sta (active_entity), y
@less_than_lane_bottom:
@update_pixels:
    ; update pixels
    ldy #Entity::_y ; Point to _y lo bit
    lda (active_entity), y ; Get the _y (lo bit)
    ldy #Entity::_pixel_y ; Point to _pixel_y (lo bit) so we can update it
    sta (active_entity), y ; Copy _y to _pixel_y (lo bit)

    ldy #Entity::_y+1 ; Point to _y hi bit
    lda (active_entity), y ; Get the _y (hi bit)
    ldy #Entity::_pixel_y+1 ; Point to _pixel_y (hi bit) so we can update it
    sta (active_entity), y ; Copy _y to _pixel_y (hi bit)

    ldy #Entity::_x ; Point to _x lo bit
    lda (active_entity), y ; Get the _x (lo bit)
    ldy #Entity::_pixel_x ; Point to _pixel_x (lo bit) so we can update it
    sta (active_entity), y ; Copy _x to _pixel_x (lo bit)

    ldy #Entity::_x+1 ; Point to _x hi bit
    lda (active_entity), y ; Get the _x (hi bit)
    ldy #Entity::_pixel_x+1 ; Point to _pixel_x (hi bit) so we can update it
    sta (active_entity), y ; Copy _x to _pixel_x (hi bit)

    ldx #0
@shift_x:
    ; The ship+Entity::_x/y is a larger number (shifted up 5 bits) to simulate a fractional number
    ; We need to shift it back down to get to the actual pixel position
    clc
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    ror
    sta (active_entity), y
    ldy #Entity::_pixel_x
    lda (active_entity), y
    ror
    sta (active_entity), y
    inx
    cpx #5
    bne @shift_x
    ldx #0
@shift_y:
    clc
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    ror
    sta (active_entity), y
    ldy #Entity::_pixel_y
    lda (active_entity), y
    ror
    sta (active_entity), y
    inx
    cpx #5
    bne @shift_y
    ; Check pixel limits

    ; Copy to pixel_show
    ldy #Entity::_pixel_x
    lda (active_entity), y
    ldy #Entity::_pixel_show_x
    sta (active_entity), y
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    ldy #Entity::_pixel_show_x+1
    sta (active_entity), y
    ldy #Entity::_pixel_y
    lda (active_entity), y
    ldy #Entity::_pixel_show_y
    sta (active_entity), y
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    ldy #Entity::_pixel_show_y+1
    sta (active_entity), y
    ; Set show pixel based on lane
    ldy #Entity::_lane
    lda (active_entity), y
    cmp #1
    bne @pixel_done
    ; bottom lane needs pixel adjust
    clc
    ldy #Entity::_pixel_show_y
    lda (active_entity), y
    adc #LANE_PIXEL_ADJUST
    sta (active_entity), y
    ldy #Entity::_pixel_show_y+1
    adc #0
    sta (active_entity), y
@pixel_done:
    rts

.endif