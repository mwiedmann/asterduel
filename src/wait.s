.ifndef WAIT_S
WAIT_S = 1

wc: .byte 0
wc_temp: .byte 0

wait_count:
    lda wc
    sta wc_temp
@next:
    cmp #0
    beq @done
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    stz waitflag
    lda wc_temp
    sec
    sbc #1
    sta wc_temp
    bra @next
@done:
    rts
    
watch_for_joystick_press:
@initial:
    jsr joy1
    cmp #255
    bne @initial ; If pressing when they arrive, wait for a release. We want a full button press/release
@loop:
    jsr joy1
    cmp #255
    bne @release
    bra @loop ; Wait for press
@release:
    jsr joy1
    cmp #255 ; Wait for release
    bne @release
    rts

.endif
