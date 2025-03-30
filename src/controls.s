.ifndef CONTROLS_S
CONTROLS_S = 1

check_controls:
    lda #0
    jsr JOYGET
    sta joy_a ; hold the joystick A state
    stx joy_x ; hold the joystick X state
    lda thrustwait
    cmp #0 ; We only thrust the ship every few ticks (otherwise it takes off SUPER fast)
    beq @thrust_ready
    sec
    sbc #1
    sta thrustwait
    bra @check_rotation
@thrust_ready:
    stz thrusting
    lda joy_a
    bit #%1000 ; See if pushing up (thrust)
    bne @check_rotation ; Skip thrust and jump to check rotation
    ldx #1
    stx thrusting
    ; User is pressing up
    ; Shift the ship ang (mult 2) because ship_vel_ang_x are .word
    ldx #SHIP_THRUST_TICKS
    stx thrustwait ; Reset thrust ticks
    clc
    lda ship_1+Entity::_ang
    rol
    tax ; We now have a 0-31 index based on 0-15 angle
    ; First increase the x velocity
    lda ship_1+Entity::_vel_x
    clc
    adc ship_vel_ang_x, x ; x thrust based on angle (lo byte)
    sta ship_1+Entity::_vel_x
    lda ship_1+Entity::_vel_x+1
    adc ship_vel_ang_x+1, x ; x thrust based on angle (hi byte)
    sta ship_1+Entity::_vel_x+1
    ; Second increase the y velocity
    lda ship_1+Entity::_vel_y
    clc
    adc ship_vel_ang_y, x ; y thrust based on angle (lo byte)
    sta ship_1+Entity::_vel_y
    lda ship_1+Entity::_vel_y+1
    adc ship_vel_ang_y+1, x ; y thrust based on angle (hi byte)
    sta ship_1+Entity::_vel_y+1
    ; Do we need to check the max velocity (we can just cap the x/y individually)?
    ; They must stay on screen so its unlikely high speed will matter...they will crash
@check_rotation:
    lda rotatewait
    cmp #0 ; We only rotate the ship every few ticks (otherwise it spins SUPER fast)
    beq @rotate_ready
    sec
    sbc #1
    sta rotatewait
    bra @check_fire
@rotate_ready:
    lda joy_a
    bit #%10 ; Pressing left?
    bne @check_x_right
    ldx #SHIP_ROTATE_TICKS
    stx rotatewait ; Reset rotate ticks
    ; User is pressing left
    lda ship_1+Entity::_ang
    sec
    sbc #1
    cmp #255 ; See if below min of 0
    bne @save_angle
    lda #15 ; Wrap around to 15 if below 0
    jmp @save_angle
@check_x_right:
    bit #%1 ; Pressing right?
    bne @check_fire
    ; User is pressing right
    ldx #SHIP_ROTATE_TICKS
    stx rotatewait ; Reset rotate ticks
    lda ship_1+Entity::_ang ; Inc the angle
    clc
    adc #1
    cmp #16 ; See if over max of 15
    bne @save_angle
    lda #0 ; Back to 0 if exceeded max
@save_angle:
    sta ship_1+Entity::_ang
@check_fire:
    lda firewait
    cmp #0 ; We only fire every few ticks
    beq @fire_ready
    sec
    sbc #1
    sta firewait
    bra @done
@fire_ready:
    lda joy_a
    eor #$FF
    and #%11000100 ; Pressing down, or B/Y (fire)
    cmp #0
    bne @firing
    lda joy_x
    eor #$FF
    and #%11110000 ; Pressing A/X/L/R (fire)
    cmp #0
    beq @done
@firing:
    ldx #SHIP_FIRE_TICKS
    stx firewait ; Reset fire ticks
    jsr fire_laser_1
    jsr fire_laser_2
    ;jsr set_ship_1_as_active
@done:
    rts

.endif