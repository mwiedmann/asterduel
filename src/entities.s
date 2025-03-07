.ifndef ENTITIES_S
ENTITIES_S = 1

process_entities:
    ldx #0
    stx sp_entity_count
    ldx #0
    stx sp_offset
    stx sp_offset+1
@next_entity:
    jsr process_entity
    clc
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    inc sp_entity_count
    lda sp_entity_count
    cmp #2
    bne @next_entity
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS
    bne @done
    lda #0
    sta accelwait
@done:
    rts

process_entity:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    ldy #Entity::_visible
    lda (active_entity), y
    cmp #0
    beq @skip_entity ; Skip if not visible
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS ; We only thrust entities every few ticks (otherwise they take off SUPER fast)
    bne @skip_accel
    ldy #Entity::_has_accel
    lda (active_entity), y
    cmp #0
    beq @skip_accel
    ;jsr accel_entity
@skip_accel:
    ldy #Entity::_destroy_ticks ; See if entity is destroyed after some time
    lda (active_entity), y
    cmp #0
    beq @skip_destroy
    dec
    sta (active_entity), y
    cmp #0
    bne @skip_destroy
    ldy #Entity::_visible
    sta (active_entity), y
@skip_destroy:
    jsr move_entity
    lda sp_entity_count
    cmp #0
    bne @skip_scroll
    jsr scroll_lane
@skip_scroll:
    ;jsr enemy_logic
    ;jsr mine_logic
    lda #0
    sta param1 ; make entity not visible if out of bounds
    ;jsr check_entity_bounds
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
    ;jsr ghost_sprite
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
    cmp #2
    bne @next_entity
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS
    bne @done
    lda #0
    sta accelwait
@done:
    rts

ghost_sprite:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    ldy #Entity::_lane
    lda (active_entity), y
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

    ldy #Entity::_sprite_num
    lda (active_entity), y
    inc
    sta param1
    jsr update_sprite
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

scroll_lane:
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta scrollx
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta scrollx+1
    ; see if hit min
    lda scrollx+1
    cmp #>SHIP_MID
    bcc @less_than_mid
    bne @greater_than_mid
    ; check low bits
    lda scrollx
    cmp #<SHIP_MID
    bcs @greater_than_mid
@less_than_mid:
    lda #0
    sta scrollx
    sta scrollx+1
    bra @done
@greater_than_mid:
    ; see if greater than max
    ; see if hit min
    lda scrollx+1
    cmp #>SHIP_MAX
    bcc @less_than_max
    bne @greater_than_max
    ; check low bits
    lda scrollx
    cmp #<SHIP_MAX
    bcs @greater_than_max
    bra @less_than_max
@greater_than_max:
    lda #<SHIP_MAX_SCROLL
    sta scrollx
    lda #>SHIP_MAX_SCROLL
    sta scrollx+1
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
    lda scrollx
    sbc #<SHIP_MID
    sta scrollx
    lda scrollx+1
    sbc #>SHIP_MID
    sta scrollx+1
    ; put ship in middle
    lda #<SHIP_MID
    ldy #Entity::_pixel_show_x
    sta (active_entity), y
    lda #>SHIP_MID
    ldy #Entity::_pixel_show_x+1
    sta (active_entity), y
@done:
    rts

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
    ldy #Entity::_pixel_y ; Point to _pixel_y (lo bit) so we can update it
    sta (active_entity), y ; Copy _y to _pixel_y (lo bit)
    ldy #Entity::_y+1 ; Point to _y hi bit
    lda (active_entity), y ; Get the _y (hi bit)
    ldy #Entity::_vel_y+1 ; Point to the _vel_y (hi bit)
    adc (active_entity), y ; Add the _vel_y (hi bit, moves entity y position)
    ldy #Entity::_y+1 ; Point back to _y (hi bit) so we can update it
    sta (active_entity), y ; Store the updated _y (hi bit)
    ldy #Entity::_pixel_y+1 ; Point to _pixel_y (hi bit) so we can update it
    sta (active_entity), y ; Copy _y to _pixel_y (hi bit)
    ; Add velocity to x position
    ldy #Entity::_x ; Point to _x lo bit
    lda (active_entity), y ; Get the _x (lo bit)
    ldy #Entity::_vel_x ; Get the _vel_x (lo bit)
    clc
    adc (active_entity), y ; Add the _vel_x (lo bit, moves entity x position)
    ldy #Entity::_x ; Point back to _x (lo bit) so we can update it
    sta (active_entity), y ; Store the updated _x (lo bit)
    ldy #Entity::_pixel_x ; Point to _pixel_x (lo bit) so we can update it
    sta (active_entity), y ; Copy _x to _pixel_x (lo bit)
    ldy #Entity::_x+1 ; Point to _x hi bit
    lda (active_entity), y ; Get the _x (hi bit)
    ldy #Entity::_vel_x+1 ; Point to the _vel_x (hi bit)
    adc (active_entity), y ; Add the _vel_x (hi bit, moves entity x position)
    ldy #Entity::_x+1 ; Point back to _x (hi bit) so we can update it
    sta (active_entity), y ; Store the updated _x (hi bit)
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