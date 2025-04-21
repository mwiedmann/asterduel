.ifndef IRQ_S
IRQ_S = 1

scroll_lane1_x: .word 0
scroll_lane2_x: .word 0
lineval: .byte 0

irq_routine:
    lda VERA_ISR
    and #1
    cmp #1
    beq @vsync
    ; Line IRQ
    lda lineval
    cmp #0
    beq @top
    ; bottom
    lda scroll_lane2_x
    sta VERA_L0_HSCROLL_L
    lda scroll_lane2_x+1
    sta VERA_L0_HSCROLL_H
    lda #<SCROLL_BOTTOM_ADJUST
    sta VERA_L0_VSCROLL_L
    lda #>SCROLL_BOTTOM_ADJUST
    sta VERA_L0_VSCROLL_H
    lda #0
    sta lineval
    lda #0
    sta VERA_SCANLINE_L
    bra @continue
@vsync:
    lda #1
    sta waitflag ; Signal that its ok to draw now
    inc accelwait
    bra @continue
@top:
    lda #0
    sta VERA_L0_VSCROLL_L
    sta VERA_L0_VSCROLL_H
    lda scroll_lane1_x
    sta VERA_L0_HSCROLL_L
    lda scroll_lane1_x+1
    sta VERA_L0_HSCROLL_H
    lda #1
    sta lineval
    lda #240
    sta VERA_SCANLINE_L
@continue:
    lda #10
    sta VERA_ISR
    jmp (default_irq)

irq_config:
    sei
    ; First, capture the default IRQ handler
    ; This is so we can call it after our custom handler
    lda IRQ_FUNC_ADDR
    sta default_irq
    lda IRQ_FUNC_ADDR+1
    sta default_irq+1
    ; Now replace it with our custom handler
    lda #<irq_routine
    sta IRQ_FUNC_ADDR
    lda #>irq_routine
    sta IRQ_FUNC_ADDR+1
    ; Just LINE and VSYNC
    lda #0
    sta lineval
    sta VERA_SCANLINE_L
    lda #%11
    sta VERA_IEN
    cli
    rts

irq_restore:
    sei
    lda default_irq
    sta IRQ_FUNC_ADDR
    lda default_irq+1
    sta IRQ_FUNC_ADDR+1
    cli
    rts

.endif