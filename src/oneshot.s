.ifndef EXP_S
EXP_S = 1

exp_offset: .word 0

init_oneshots:
    ldx #0
    lda #<oneshots
    sta active_exp
    lda #>oneshots
    sta active_exp+1
@next_oneshot:
    lda #0
    ldy #Oneshot::_visible
    sta (active_exp), y
    clc
    txa
    adc #ONESHOT_SPRITE_NUM_START
    ldy #Oneshot::_sprite_num
    sta (active_exp), y
    clc
    lda active_exp
    adc #<(.sizeof(Oneshot))
    sta active_exp
    lda active_exp+1
    adc #>(.sizeof(Oneshot))
    sta active_exp+1
    inx
    cpx #ONESHOT_SPRITE_COUNT
    bne @next_oneshot
@done:
    rts


os_x: .word 0
os_y: .word 0
os_frame: .byte 0

create_explosion:
    jsr set_ship_1_as_ghost
    jsr explosion_work
    jsr set_ship_2_as_ghost
    jsr explosion_work
    rts

explosion_work:
    ldx #0
    lda #<oneshots
    sta active_exp
    lda #>oneshots
    sta active_exp+1
@next_oneshot:
    ldy #Oneshot::_visible
    lda (active_exp), y
    cmp #0
    beq @found_oneshot
    clc
    lda active_exp
    adc #<(.sizeof(Oneshot))
    sta active_exp
    lda active_exp+1
    adc #>(.sizeof(Oneshot))
    sta active_exp+1
    inx
    cpx #ONESHOT_SPRITE_COUNT
    beq @count_done
    bra @next_oneshot
@count_done:
    rts
@found_oneshot:
    ; Found available oneshot
    lda #<EXPLOSION_LOAD_ADDR
    ldy #Oneshot::_image_addr
    sta (active_exp), y
    lda #>EXPLOSION_LOAD_ADDR
    ldy #Oneshot::_image_addr+1
    sta (active_exp), y
    lda #<(EXPLOSION_LOAD_ADDR>>16)
    ldy #Oneshot::_image_addr+2
    sta (active_exp), y
    ; Calc position in lane
    sec
    ldy #Entity::_pixel_x
    lda os_x
    sbc (comp_entity1), y
    sta ghost_x
    ldy #Entity::_pixel_x+1
    lda os_x+1
    sbc (comp_entity1), y
    sta ghost_x+1
    sec
    ldy #Entity::_pixel_y
    lda os_y
    sbc (comp_entity1), y
    sta ghost_y
    ldy #Entity::_pixel_y+1
    lda os_y+1
    sbc (comp_entity1), y
    sta ghost_y+1
    ; Adjust position
    clc
    ldy #Entity::_pixel_show_x
    lda (comp_entity1), y
    adc ghost_x
    sta ghost_x
    ldy #Entity::_pixel_show_x+1
    lda (comp_entity1), y
    adc ghost_x+1
    sta ghost_x+1

    ldy #Entity::_pixel_show_y
    lda (comp_entity1), y
    adc ghost_y
    sta ghost_y
    ldy #Entity::_pixel_show_y+1
    lda (comp_entity1), y
    adc ghost_y+1
    sta ghost_y+1

    ; Check if sprite off screen
    lda ghost_x+1
    cmp #>640
    bcc @show_ghost
    bne @hide_ghost
    ; check lower bits
    lda ghost_x
    cmp #<640
    bcc @show_ghost
    bne @hide_ghost
@show_ghost:
    bra @update_ghost
@hide_ghost:
    rts
@update_ghost:
    lda ghost_x
    ldy #Oneshot::_pixel_x
    sta (active_exp), y
    lda ghost_x+1
    ldy #Oneshot::_pixel_x+1
    sta (active_exp), y
    lda ghost_y
    ldy #Oneshot::_pixel_y
    sta (active_exp), y
    lda ghost_y+1
    ldy #Oneshot::_pixel_y+1
    sta (active_exp), y
    lda #0
    ldy #Oneshot::_frame
    sta (active_exp), y
    ldy #Oneshot::_ticks
    sta (active_exp), y
    ldy #Oneshot::_type
    sta (active_exp), y
    lda #1
    ldy #Oneshot::_visible
    sta (active_exp), y ; make oneshot visible
@done:
    rts

update_oneshots:
    ldx #0
    lda #<oneshots
    sta active_exp
    lda #>oneshots
    sta active_exp+1
@next_oneshot:
    ldy #Oneshot::_visible
    lda (active_exp), y
    cmp #0
    beq @not_visible
    ldy #Oneshot::_type
    lda (active_exp), y
    cmp #0
    bne @score_type
    phx
    jsr update_explosion
    plx
    bra @not_visible
@score_type:
    ; phx
    ; jsr update_score_type
    ; plx
@not_visible:
    clc
    lda active_exp
    adc #<(.sizeof(Oneshot))
    sta active_exp
    lda active_exp+1
    adc #>(.sizeof(Oneshot))
    sta active_exp+1
    inx
    cpx #ONESHOT_SPRITE_COUNT
    beq @done
    bra @next_oneshot
@done:
    rts

update_explosion:
    ; Update the oneshot
    ; Get the image
    ldy #Oneshot::_image_addr
    lda (active_exp), y
    sta us_img_addr
    ldy #Oneshot::_image_addr+1
    lda (active_exp), y
    sta us_img_addr+1
    ldy #Oneshot::_image_addr+2
    lda (active_exp), y
    sta us_img_addr+2
    ; See if time to advance frame
    ldy #Oneshot::_ticks
    lda (active_exp), y
    inc
    sta (active_exp), y
    cmp #ONESHOT_TICKS
    bne @not_next_frame
    lda #0
    sta (active_exp), y ; Reset the ticks
    ldy #Oneshot::_frame
    lda (active_exp), y
    inc ; Increase the frame count
    sta (active_exp), y
    cmp #EXPLOSION_FRAME_COUNT
    bne @adv_frame_image
    ; End of animation
    ldy #Oneshot::_visible
    lda #0
    sta (active_exp), y
    bra @not_next_frame
@adv_frame_image:
    clc ; Inc the frame image
    lda us_img_addr
    adc #<EXPLOSION_SPRITE_FRAME_SIZE
    ldy #Oneshot::_image_addr
    sta (active_exp), y
    sta us_img_addr
    lda us_img_addr+1
    adc #>EXPLOSION_SPRITE_FRAME_SIZE
    ldy #Oneshot::_image_addr+1
    sta (active_exp), y
    sta us_img_addr+1
    lda us_img_addr+2
    adc #<(EXPLOSION_SPRITE_FRAME_SIZE>>16)
    ldy #Oneshot::_image_addr+2
    sta (active_exp), y
    sta us_img_addr+2
@not_next_frame:
    ldx #0
@start_shift: ; Shift the image addr bits as sprites use bits 12:5 and 16:13 (we default 16 to 0)
    clc
    lda us_img_addr+2
    ror
    sta us_img_addr+2
    lda us_img_addr+1
    ror
    sta us_img_addr+1
    lda us_img_addr
    ror
    sta us_img_addr
    inx
    cpx #5
    bne @start_shift
    ldy #Oneshot::_sprite_num
    lda (active_exp), y
    sta pts_sprite_num
    jsr point_to_sprite
    lda us_img_addr ; Frame addr lo
    sta VERA_DATA0 ; Write the lo addr for the sprite frame based on ang
    lda us_img_addr+1 ; Frame addr hi
    ora #%10000000 ; Keep the 256 color mode on
    sta VERA_DATA0 ; Write the hi addr for the sprite frame based on ang
    ldy #Oneshot::_pixel_x
    lda (active_exp), y
    sta VERA_DATA0
    ldy #Oneshot::_pixel_x+1
    lda (active_exp), y
    sta VERA_DATA0
    ldy #Oneshot::_pixel_y
    lda (active_exp), y
    sta VERA_DATA0
    ldy #Oneshot::_pixel_y+1
    lda (active_exp), y
    sta VERA_DATA0
    ldy #Oneshot::_visible
    lda (active_exp), y
    cmp #1
    beq @show_sprite
    lda #%00000000 ; Not visible
    sta VERA_DATA0
    bra @done
@show_sprite:
    lda #%00001100 ; In front of all layers
    sta VERA_DATA0
    lda #%10100000 ; 32x32
    sta VERA_DATA0
@done:
    rts

.endif