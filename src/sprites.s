.ifndef SPRITES_S
SPRITES_S = 1

active_sprite: .word 0
sprite_offset: .word 0

sp_offset: .word 0
sp_num: .byte 0
sp_entity_count: .byte 0

us_img_addr: .dword 0
us_frame: .byte 0
us_ang: .byte 0
us_visible: .byte 0

pts_sprite_num: .byte 0

point_to_sprite:
    lda #<SPRITE_ADDR
    sta active_sprite
    lda #>SPRITE_ADDR
    sta active_sprite+1
    lda pts_sprite_num
    ldx #0
    stx sprite_offset+1 ; Clear it out for some shifting
@mult_8: ; Mult sprite num by 8 to get the memory offset of that sprite
    clc
    rol
    sta sprite_offset
    lda sprite_offset+1
    rol
    sta sprite_offset+1
    lda sprite_offset
    inx
    cpx #3
    bne @mult_8
    ; sprite_offset now ready to add to the active_sprite
    clc
    lda active_sprite
    adc sprite_offset
    sta active_sprite
    lda active_sprite+1
    adc sprite_offset+1
    sta active_sprite+1
    ; We have the address of the sprite...point to
    lda active_sprite
    sta VERA_ADDR_LO
    lda active_sprite+1
    sta VERA_ADDR_MID
    lda #(VERA_ADDR_HI_INC_BITS+1) ; Sprites are in 2nd bank of VRAM
    sta VERA_ADDR_HI_SET
    rts

cs_sprite_num: .byte 0
cs_size: .byte 0

create_sprite:
    lda cs_sprite_num
    sta pts_sprite_num
    jsr point_to_sprite
    lda #0
    sta VERA_DATA0
    lda #%10000000
    sta VERA_DATA0
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sta VERA_DATA0
    lda #0 ; z-depth
    sta VERA_DATA0
    lda cs_size ; #%10100000 ; 32x32 pixels
    sta VERA_DATA0
    rts

us_skip_flip: .byte 0

update_sprite:
    stz us_skip_flip
    lda param1
    ; cmp #SAFE_SPRITE_NUM_START ; don't show this sprite
    ; bne @continue
    ; rts
@continue:
    sta pts_sprite_num
    jsr point_to_sprite
    ldx #0
    stx us_ang
    stx us_frame
    ldy #Entity::_has_ang ; Does sprite change based on angle?
    lda (active_entity), y
    cmp #0 ; Yes, frame based on angle
    beq @update_ang_frame
    cmp #3
    bne @check_auto_rotate
    ; If here, then _has_ang=3 and we auto-rotate through 8 frames (warp)
    ldy #Entity::_ang
    lda (active_entity), y
    sta us_frame
    ldy #Entity::_ang_ticks
    lda (active_entity), y
    clc
    adc #1
    sta (active_entity), y
    cmp #6 ; Rotate every this many ticks
    bne @skip_update_ang_frame
    lda #0
    sta (active_entity), y ; Set ticks back to 0
    ldy #Entity::_ang ; Time to rotate, inc the angle
    lda (active_entity), y
    clc
    adc #1
    sta us_frame
    sta (active_entity), y
    cmp #4 ; Wrap back to 0 at 4
    bne @skip_update_ang_frame
    lda #0
    sta (active_entity), y
    sta us_frame
    bra @skip_update_ang_frame
@check_auto_rotate:
    cmp #2 ; Auto rotate through 16 frames
    bne @skip_auto_rotate
    ldy #Entity::_ang ; Entity's angle (0-15)
    lda (active_entity), y
    sta us_ang
    sta us_frame
    lda #1
    sta us_skip_flip
    ldy #Entity::_ang_ticks
    lda (active_entity), y
    clc
    adc #1
    sta (active_entity), y
    cmp #6 ; Rotate every this many ticks
    bne @skip_update_ang_frame
    lda #0
    sta (active_entity), y ; Set ticks back to 0
    ldy #Entity::_ang ; Time to rotate, inc the angle
    lda (active_entity), y
    clc
    adc #1
    cmp #16 ; Wrap back to 0 at 16
    bne @skip_back_to_zero
    lda #0
@skip_back_to_zero:
    sta (active_entity), y ; The updated ang
    sta us_frame ; We have full 16 frames for these
    bra @skip_update_ang_frame
@skip_auto_rotate:
    ldy #Entity::_ang ; Entity's angle (0-15)
    lda (active_entity), y
    sta us_ang
    sta us_frame
    tax
@update_ang_frame:
    lda ship_frame_ang, x ; Sprite frame based on angle (0-4)
    sta us_frame ; us_frame now has the sprite frame number
@skip_update_ang_frame:
    ldy #Entity::_visible ; Entity visibility
    lda (active_entity), y
    sta us_visible
    ldy #Entity::_type ; Entity visibility
    lda (active_entity), y
    cmp #SHIP_1_TYPE
    bne @check_ship_2
    lda thrusting_1
    cmp #0
    beq @not_thrust_1
    jsr thrusting_ship_img_1
    bra @start_move_frame
@not_thrust_1:
    jsr normal_ship_img_1
    bra @start_move_frame
@check_ship_2:
    cmp #SHIP_2_TYPE
    bne @skip_thrust
    lda thrusting_2
    cmp #0
    beq @not_thrust_2
    jsr thrusting_ship_img_2
    bra @start_move_frame
@not_thrust_2:
    jsr normal_ship_img_2
    bra @start_move_frame
@skip_thrust:
    ; Load the image addr so we can add to and bit shift it
    ldy #Entity::_image_addr
    lda (active_entity), y
    sta us_img_addr
    ldy #Entity::_image_addr+1
    lda (active_entity), y
    sta us_img_addr+1
    ldy #Entity::_image_addr+2
    lda (active_entity), y
    sta us_img_addr+2
@start_move_frame:
    ldx #0
@move_frame:
    cpx us_frame
    beq @frame_slide_done
    clc
    ldy #Entity::_size
    lda (active_entity), y
    adc #0 ;HITBOX_SHRINK ; We have shrunk the size for smaller collisions. Maybe need a separate value for this or that.
    cmp #32
    beq @size_32
@size_16:
    clc
    lda us_img_addr
    adc #<ASTSML_SPRITE_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>ASTSML_SPRITE_FRAME_SIZE
    sta us_img_addr+1
    lda us_img_addr+2
    adc #0
    sta us_img_addr+2
    bra @size_done
@size_32:
    clc
    lda us_img_addr
    adc #<DEFAULT_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>DEFAULT_FRAME_SIZE
    sta us_img_addr+1
    lda us_img_addr+2
    adc #0
    sta us_img_addr+2
@size_done:
    inx
    bra @move_frame
@frame_slide_done:
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

    ; Do the addr calc on the fly (>>5)
    lda us_img_addr ; Frame addr lo
    sta VERA_DATA0 ; Write the lo addr for the sprite frame based on ang
    lda us_img_addr+1 ; Frame addr hi
    ora #%10000000 ; Keep the 256 color mode on
    sta VERA_DATA0 ; Write the hi addr for the sprite frame based on ang
    
    ldy #Entity::_pixel_show_x
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_show_x+1
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_show_y
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_show_y+1
    lda (active_entity), y
    sta VERA_DATA0
    lda #0
    ldx us_skip_flip
    cpx #1
    beq @skip_flipping
    ldx us_ang
    ora ship_flip_ang, x
@skip_flipping:
    ora #%00001000
    ldy us_visible
    cpy #1
    beq @write_flip
    and #%11110011 ; Hide entity, z-depth=0
@write_flip:
    sta VERA_DATA0
    rts

sprite_temp: .res 8

copy_sprite_set_pos:
    lda param1
    sta pts_sprite_num
    jsr point_to_sprite
    lda VERA_DATA0
    sta sprite_temp
    lda VERA_DATA0
    sta sprite_temp+1
    lda VERA_DATA0
    sta sprite_temp+2
    lda VERA_DATA0
    sta sprite_temp+3
    lda VERA_DATA0
    sta sprite_temp+4
    lda VERA_DATA0
    sta sprite_temp+5
    lda VERA_DATA0
    sta sprite_temp+6
    lda VERA_DATA0
    sta sprite_temp+7
    lda param1
    inc
    sta pts_sprite_num
    jsr point_to_sprite
    lda sprite_temp
    sta VERA_DATA0
    lda sprite_temp+1
    sta VERA_DATA0
    ldy #Entity::_pixel_show_x
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_show_x+1
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_show_y
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_show_y+1
    lda (active_entity), y
    sta VERA_DATA0
    ; Check if entity visible in this lane
    ldy #Entity::_visible
    lda (active_entity), y
    cmp #0
    beq @hidden
    bra @visible
@hidden:
    lda sprite_temp+6
    and #%11110011 ; Hide entity, z-depth=0
    bra @lastbyte
@visible:
    lda sprite_temp+6
    ora #%00001000
@lastbyte:
    sta VERA_DATA0
    lda sprite_temp+7
    sta VERA_DATA0
    rts

; param1 = visible
reset_active_entity:
    lda #0
    ldy #Entity::_vel_x
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    ldy #Entity::_vel_y
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    lda param1
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_active
    sta (active_entity), y
    rts

accel_entity:
    ldy #Entity::_ang
    lda (acc_entity), y
    clc
    rol ; Shift the ship ang (mult 2) because ship_vel_ang_x are .word
    tax ; We now have a 0-31 index based on 0-15 angle
    ; First increase the x velocity
    ldy #Entity::_vel_x
    lda (acc_entity), y
    clc
    adc ship_vel_ang_x, x ; x thrust based on angle (lo byte)
    sta (acc_entity), y
    ldy #Entity::_vel_x+1
    lda (acc_entity), y
    adc ship_vel_ang_x+1, x ; x thrust based on angle (hi byte)
    sta (acc_entity), y
    ; Second increase the y velocity
    ldy #Entity::_vel_y
    lda (acc_entity), y
    clc
    adc ship_vel_ang_y, x ; y thrust based on angle (lo byte)
    sta (acc_entity), y
    ldy #Entity::_vel_y+1
    lda (acc_entity), y
    adc ship_vel_ang_y+1, x ; y thrust based on angle (hi byte)
    sta (acc_entity), y
    rts

hide_count: .byte 0

hide_all_sprites:
    lda #<SPRITE_Z_ADDR
    sta VERA_ADDR_LO
    lda #>SPRITE_Z_ADDR
    sta VERA_ADDR_MID
    lda #%01000001 ; Inc 8, Sprites are in 2nd bank of VRAM
    sta VERA_ADDR_HI_SET
    stz hide_count
@next:
    lda #0
    sta VERA_DATA0
    inc hide_count
    lda hide_count
    cmp #128
    bne @next
    rts

.endif
