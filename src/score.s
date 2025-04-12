.ifndef SCORE_S
SCORE_S = 1

bcd: .word 0,0
num_to_convert: .byte 0

convert_to_bcd:
    sed ; switch to decimal mode
    lda #0 ; ensure the result is clear
    sta bcd+0
    sta bcd+1
    ldx #8 ; the number of source bits
@cnvbit: 
    asl num_to_convert ; shift out one bit
    lda bcd+0 ; and add into result
    adc bcd+0
    sta bcd+0
    lda bcd+1 ; propagating any carry
    adc bcd+1
    sta bcd+1
    dex ; and repeat for next bit
    bne @cnvbit
    cld ; back to binary
    rts

show_base_1:
    
.endif