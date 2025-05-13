.ifndef COLLISIONS_S
COLLISIONS_S = 1

hc_outer_entity_count: .byte 0
hc_inner_entity_count: .byte 0
hc_comp_val1: .word 0
hc_comp_val2: .word 0
hc_overlap: .byte 0

handle_collision:
    stz hc_outer_entity_count
    ldx #1
    stx hc_inner_entity_count
    ldx #<entities ; entity 0
    stx comp_entity1
    ldx #>entities
    stx comp_entity1+1
    ldx #<(entities+.sizeof(Entity)) ; entity 1
    stx comp_entity2
    ldx #>(entities+.sizeof(Entity))
    stx comp_entity2+1
check_entities:
    ; See if entities are colliding
    ; First check if these CAN collide
    ldy #Entity::_active ; Is this entity even visible
    lda (comp_entity1), y
    cmp #1
    beq @check_other_visible
    jmp last_inner_entity ; Outer entity isn't visible
@check_other_visible:
    lda (comp_entity2), y
    cmp #1
    beq @check_collision_flags
    jmp no_collision ; Inner entity isn't visible
@check_collision_flags:
    ldy #Entity::_type ; Same types can't collide
    lda (comp_entity1), y
    cmp (comp_entity2), y
    beq @jump_to_no_collision
    ; Different types, see if they can collide
    ldy #Entity::_collision_id
    lda (comp_entity1), y
    ldy #Entity::_collision_matrix
    and (comp_entity2), y
    cmp #0
    beq @jump_to_no_collision
    jmp @check_actual_collisions
@jump_to_no_collision:
    jmp no_collision
    ; Now check if they overlap
    ; 1st check if x1 > x2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_x into vars and increase x2 by size, then compare
@check_actual_collisions:
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_x+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_x+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_x+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    clc
    lda hc_comp_val2
    ldy #Entity::_coll_size
    adc (comp_entity2), y ; now add coll_size=x2+size
    sta hc_comp_val2
    lda hc_comp_val2+1
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val2+1
    cmp hc_comp_val1+1 ; compare the hi bytes
    bcc @jump_to_no_collision ; If hi bytes are not equal, they are too far apart to collide 
    bne @x2_check
    lda hc_comp_val2
    cmp hc_comp_val1 ; compare the lo bytes
    bcc @jump_to_no_collision ; A < B, no possible collision 
    ; 2nd check if x1+size < x2 (then it is to the left of the object and no collision)
    ; Load the _pixel_x into vars and increase x2 by size, then compare
@x2_check:
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_x+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    lda hc_comp_val1
    ldy #Entity::_coll_size
    adc (comp_entity1), y ; add coll_size=x1+size
    sta hc_comp_val1
    lda hc_comp_val1+1
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_x+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_x+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val1+1
    cmp hc_comp_val2+1 ; compare the hi bytes
    bcc @early_no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @y1_check
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc @early_no_collision ; A < B, no possible collision 
    ; 3rd check if y1 > y2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
    jmp @y1_check
@early_no_collision:
    jmp no_collision
@y1_check:
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_y+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_y+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_y+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    clc
    lda hc_comp_val2
    ldy #Entity::_coll_size
    adc (comp_entity2), y ; now add coll_size=x2+size
    sta hc_comp_val2
    lda hc_comp_val2+1
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val2+1
    cmp hc_comp_val1+1 ; compare the hi bytes
    bcc no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @y2_check
    lda hc_comp_val2
    cmp hc_comp_val1 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision 
     ; 4th check if y1+size < y2 (then it is to the left of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
@y2_check:
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_y+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    lda hc_comp_val1
    ldy #Entity::_coll_size
    adc (comp_entity1), y ; add coll_size=x1+size
    sta hc_comp_val1
    lda hc_comp_val1+1
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_y+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_y+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val1+1
    cmp hc_comp_val2+1 ; compare the hi bytes
    bcc no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @got_collision
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision
@got_collision: 
    ; If we made it here, we have a collision!
    jsr handle_collision_sprites
    lda hcs_keep_going
    cmp #1
    beq no_collision ; Look for more collisions or stop
    rts
    ; Need to look at the sprite type to decide what to do (player death, score points, etc.)
no_collision:
    ; Go to the next inner entity
    clc
    lda comp_entity2
    adc #.sizeof(Entity)
    sta comp_entity2
    lda comp_entity2+1
    adc #0
    sta comp_entity2+1
    inc hc_inner_entity_count
    lda hc_inner_entity_count
    cmp #ENTITY_COUNT
    beq last_inner_entity
    jmp check_entities
last_inner_entity:
    ; Reached last entity
    inc hc_outer_entity_count ; Update the outer index
    lda hc_outer_entity_count 
    cmp #OUTER_ENTITY_COUNT
    beq @done ; Reached end of list...stop
    inc ; Inc and store as the starting inner index
    sta hc_inner_entity_count 
    clc
    lda comp_entity1 ; Update the outer entity
    adc #.sizeof(Entity)
    sta comp_entity1
    lda comp_entity1+1
    adc #0
    sta comp_entity1+1
    clc
    lda comp_entity1 ; Set the inner entity to 1 more than the outer
    adc #.sizeof(Entity)
    sta comp_entity2
    lda comp_entity1+1
    adc #0
    sta comp_entity2+1
    jmp check_entities
@done:
    rts

boundary_collision: .byte 0

launch_ship_1_mine: .byte 0
launch_ship_2_mine: .byte 0

check_ship_1_drop_energy:
    lda ship_1_energy
    cmp #0
    beq @done ; no energy
    ldy #Entity::_x+1
    lda (active_entity), y
    cmp #>(BASE_SHIP_1_ENERGY_DROP_X)
    bcc @less_than_base1
    beq @check_low_bit
    bra @reset_drop_count
@check_low_bit:
    ldy #Entity::_x
    lda (active_entity), y
    cmp #<(BASE_SHIP_1_ENERGY_DROP_X)
    bcc @less_than_base1
    bra @reset_drop_count
@less_than_base1:
    dec ship_1_drop_count
    lda ship_1_drop_count
    cmp #0
    bne @done
    inc launch_ship_1_mine
    dec ship_1_energy
    inc stats_changed
    bra @reset_drop_count
@done:
    rts
@reset_drop_count:
    lda #BASE_ENERGY_COUNT
    sta ship_1_drop_count
    rts

check_ship_2_drop_energy:
    lda ship_2_energy
    cmp #0
    beq @done ; no energy
    ldy #Entity::_x+1
    lda (active_entity), y
    cmp #>(BASE_SHIP_2_ENERGY_DROP_X)
    bcc @reset_drop_count ; <
    beq @check_low_bit
    bra @greater_than_base2
@check_low_bit:
    ldy #Entity::_x
    lda (active_entity), y
    cmp #<(BASE_SHIP_2_ENERGY_DROP_X)
    bcc @reset_drop_count ; < 
@greater_than_base2:
    dec ship_2_drop_count
    lda ship_2_drop_count
    cmp #0
    bne @done
    inc launch_ship_2_mine
    dec ship_2_energy
    inc stats_changed
    bra @reset_drop_count
@done:
    rts
@reset_drop_count:
    lda #BASE_ENERGY_COUNT
    sta ship_2_drop_count
    rts

check_left_boundary:
    lda shield_1_energy
    cmp #0
    beq @done
    stz boundary_collision
    ldy #Entity::_collision_id
    lda (active_entity), y
    and #BOUNDARY_LEFT_COLLISION_MATRIX
    cmp #0
    beq @done
    ; can collide
    ldy #Entity::_x+1
    lda (active_entity), y
    cmp #>(BOUNDARY_LEFT_X)
    bcc @less_than_left
    beq @check_low_bit
    rts ; was > so not beyond boundary
@check_low_bit:
    ldy #Entity::_x
    lda (active_entity), y
    cmp #<(BOUNDARY_LEFT_X)
    bcc @less_than_left
    rts
@less_than_left:
    jsr handle_boundary_collision
    lda shield_1_energy
    sec
    sbc boundary_collision
    bcc @shield_dead
    beq @shield_dead
    sta shield_1_energy
    inc stats_changed
    rts
@shield_dead:
    stz shield_1_energy
    inc stats_changed
    rts
@done:
    stz boundary_collision
    rts

check_right_boundary:
    lda shield_2_energy
    cmp #0
    beq @done
    stz boundary_collision
    ldy #Entity::_collision_id
    lda (active_entity), y
    and #BOUNDARY_RIGHT_COLLISION_MATRIX
    cmp #0
    beq @done
    ; can collide
    ldy #Entity::_x+1
    lda (active_entity), y
    cmp #>(BOUNDARY_RIGHT_X)
    beq @check_low_bit
    bcs @gt_right
    rts ; was > so not beyond boundary
@check_low_bit:
    ldy #Entity::_x
    lda (active_entity), y
    cmp #<(BOUNDARY_RIGHT_X)
    bcs @gt_right
    rts
@gt_right:
    jsr handle_boundary_collision
    lda shield_2_energy
    sec
    sbc boundary_collision
    bcc @shield_dead
    beq @shield_dead
    sta shield_2_energy
    inc stats_changed
    rts
@shield_dead:
    stz shield_2_energy
    inc stats_changed
    rts
@done:
    stz boundary_collision
    rts

check_left_base:
    lda shield_1_energy
    cmp #0
    bne @done ; can't hit base if shield is up
    stz boundary_collision
    ldy #Entity::_collision_id
    lda (active_entity), y
    and #BOUNDARY_LEFT_COLLISION_MATRIX
    cmp #0
    beq @done
    ; can collide
    ldy #Entity::_x+1
    lda (active_entity), y
    cmp #>(BASE_SHIP_1_ENERGY_DROP_X)
    bcc @less_than_left
    beq @check_low_bit
    rts ; was > so not beyond boundary
@check_low_bit:
    ldy #Entity::_x
    lda (active_entity), y
    cmp #<(BASE_SHIP_1_ENERGY_DROP_X)
    bcc @less_than_left
    rts
@less_than_left:
    jsr handle_boundary_collision
    lda base_1_energy
    sec
    sbc boundary_collision
    bcc @shield_dead
    sta base_1_energy
    inc stats_changed
    rts
@shield_dead:
    stz base_1_energy
    inc stats_changed
    rts
@done:
    stz boundary_collision
    rts

check_right_base:
    lda shield_2_energy
    cmp #0
    bne @done ; can't hit base if shield is up
    stz boundary_collision
    ldy #Entity::_collision_id
    lda (active_entity), y
    and #BOUNDARY_RIGHT_COLLISION_MATRIX
    cmp #0
    beq @done
    ; can collide
    ldy #Entity::_x+1
    lda (active_entity), y
    cmp #>(BASE_SHIP_2_ENERGY_DROP_X)
    beq @check_low_bit
    bcs @gt_right
    rts ; was > so not beyond boundary
@check_low_bit:
    ldy #Entity::_x
    lda (active_entity), y
    cmp #<(BASE_SHIP_2_ENERGY_DROP_X)
    bcs @gt_right
    rts
@gt_right:
    jsr handle_boundary_collision
    lda base_2_energy
    sec
    sbc boundary_collision
    bcc @shield_dead
    sta base_2_energy
    inc stats_changed
    rts
@shield_dead:
    stz base_2_energy
    inc stats_changed
    rts
@done:
    stz boundary_collision
    rts

handle_boundary_collision:
    ; handle collision
    ldy #Entity::_type
    lda (active_entity), y
    cmp #SHIP_1_TYPE
    bne @check_ship_2
    jsr destroy_ship_1
    jsr create_explosion_active_entity
    lda #SHIELD_DAMAGE_SHIP
    sta boundary_collision
    rts
@check_ship_2:
    cmp #SHIP_2_TYPE
    bne @check_laser
    jsr destroy_ship_2
    jsr create_explosion_active_entity
    lda #SHIELD_DAMAGE_SHIP
    sta boundary_collision
    rts
@check_laser:
    cmp #LASER_TYPE
    bne @check_astsml
    jsr inactivate_entity
    jsr create_explosion_active_entity
    lda #SHIELD_DAMAGE_LASER
    sta boundary_collision
    rts
@check_astsml:
    cmp #ASTSML_TYPE
    bne @check_astbig
    jsr inactivate_entity
    jsr create_explosion_active_entity
    lda #SHIELD_DAMAGE_ASTSML
    sta boundary_collision
    rts
@check_astbig:
    cmp #ASTBIG_TYPE
    bne @check_mine_1
    jsr split_active_entity
    lda #SHIELD_DAMAGE_ASTBIG
    sta boundary_collision
    rts
@check_mine_1:
    cmp #MINE_1_TYPE
    bne @check_mine_2
    jsr inactivate_entity
    jsr create_explosion_active_entity
    lda #SHIELD_DAMAGE_MINE
    sta boundary_collision
    rts
@check_mine_2:
    cmp #MINE_2_TYPE
    bne @no_collision
    jsr inactivate_entity
    jsr create_explosion_active_entity
    lda #SHIELD_DAMAGE_MINE
    sta boundary_collision
    rts
@no_collision:
    stz boundary_collision
    rts

hcs_keep_going: .byte 0

handle_collision_sprites:
    stz hcs_keep_going
    ;jsr clear_amount_to_add ; Clear the scoring amount
    ldy #Entity::_type
    lda (comp_entity1), y
    cmp #SHIP_1_TYPE
    bne @check_ship_2
    jsr collision_ship
    bra @done
@check_ship_2:
    cmp #SHIP_2_TYPE
    bne @check_laser
    jsr collision_ship
    bra @done
@check_laser:
    cmp #LASER_TYPE
    bne @check_enemy
    jsr collision_laser
    bra @done
@check_enemy:
;     cmp #ENEMY_TYPE
;     bne @check_enemy_laser
;     jsr collision_enemy
;     bra @done
; @check_enemy_laser:
;     cmp #ENEMY_LASER_TYPE
;     bne @check_safe
;     jsr collision_enemy_laser
;     bra @done
; @check_safe:
;     cmp #SAFE_TYPE
;     bne @catch_all
;     jsr collision_safe
;     bra @done
; @catch_all:
;     ;jsr destroy_1 ; Catch all, shouldn't get here
;     bra @done
@done:
    ;jsr update_score
    rts

; count_gems:
;     clc
;     inc gem_count
; check_gems:
;     lda gem_count
;     cmp launch_amount
;     bcc @no_warp
;     jsr show_warp
; @no_warp:
;     rts

collision_ship:
    ldy #Entity::_type
    lda (comp_entity2), y
    ; cmp #ENEMY_TYPE
    ; beq @ship_enemy
    cmp #LASER_TYPE
    beq @ship_laser
    ; cmp #MINE_TYPE
    ; beq @ship_mine
    cmp #ASTSML_TYPE
    beq @ship_astsml
    cmp #ASTBIG_TYPE
    beq @ship_astbig
    cmp #GEM_TYPE
    beq @ship_gem
    cmp #MINE_1_TYPE
    beq @ship_mine_1
    cmp #MINE_2_TYPE
    beq @ship_mine_2
    rts
; @ship_enemy:
;     ; Both die
;     jsr destroy_ship
;     jsr destroy_2
;     rts
@ship_laser:
    ; Both die
    jsr destroy_ship
    jsr destroy_2
    jsr create_explosion_active_entity
    rts
; @ship_mine:
;     ; Both die
;     jsr destroy_ship
;     jsr destroy_2
;     dec current_mine_count
;     rts
@ship_astsml:
    ; Destroy both
    jsr destroy_ship
    jsr destroy_2
    jsr create_explosion_active_entity
    rts
@ship_astbig:
    ; Destroy both
    jsr destroy_ship
    jsr split_2
    rts
@ship_gem:
    jsr destroy_2
    jsr ship_energy ; increase ship energy count
    rts
@ship_mine_1:
@ship_mine_2:
    ; Destroy both
    jsr destroy_ship
    jsr create_explosion_active_entity
    rts
; @ship_warp:
;     lda #1
;     sta hit_warp
;     jsr destroy_1 ; Just hide the ship, doesn't count as a death
;     jsr destroy_2
;     rts

collision_laser:
    ldy #Entity::_type
    lda (comp_entity2), y
    ; cmp #ENEMY_TYPE
    ; beq @laser_enemy
    ; cmp #MINE_TYPE
    ; beq @laser_mine
    cmp #ASTSML_TYPE
    beq @laser_astsml
    cmp #ASTBIG_TYPE
    beq @laser_astbig
    ; cmp #GEM_TYPE
    ; beq @laser_gem
    rts
; @laser_enemy:
;     jsr destroy_both
;     rts
; @laser_mine:
;     jsr destroy_both
;     dec current_mine_count
;     rts
@laser_astsml:
    jsr destroy_both
    rts
@laser_astbig:
    jsr destroy_1
    jsr split_2
    rts
; @laser_gem:
;     ; Destroy both
;     jsr count_gems
;     jsr destroy_both
;     rts

; collision_enemy:
;     ldy #Entity::_type
;     lda (comp_entity2), y
;     cmp #ASTSML_TYPE
;     beq @enemy_astsml
;     cmp #ASTBIG_TYPE
;     beq @enemy_astbig
;     cmp #GEM_TYPE
;     beq @enemy_gem
;     cmp #SAFE_TYPE
;     beq @enemy_safe
;     rts
; @enemy_astsml:
;     ; Destroy ast
;     jsr create_explosion_2
;     jsr destroy_2
;     rts
; @enemy_astbig:
;     ; Split the big
;     jsr split_2
;     rts
; @enemy_gem:
;     ; Destroy gem
;     jsr create_explosion_2
;     jsr count_gems
;     jsr destroy_2
;     rts
; @enemy_safe:
;     jsr create_explosion_active_entity
;     jsr destroy_1
;     rts

; collision_enemy_laser:
;     ldy #Entity::_type
;     lda (comp_entity2), y
;     cmp #ASTSML_TYPE
;     beq @enemylsr_astsml
;     cmp #ASTBIG_TYPE
;     beq @enemylsr_astbig
;     cmp #GEM_TYPE
;     beq @enemylsr_gem
;     cmp #SAFE_TYPE
;     beq @enemylsr_safe
;     rts
; @enemylsr_astsml:
;     ; Destroy both
;     jsr destroy_both
;     rts
; @enemylsr_astbig:
;     ; Split the big, destroy laser
;     jsr destroy_1
;     jsr split_2
;     rts
; @enemylsr_gem:
;     ; Destroy both
;     jsr count_gems
;     jsr destroy_both
;     rts
; @enemylsr_safe:
;     jsr destroy_1
;     rts

; collision_safe:
;     ldy #Entity::_type
;     lda (comp_entity2), y
;     cmp #MINE_TYPE
;     beq @safe_mine
;     cmp #ASTSML_TYPE
;     beq @safe_astsml
;     cmp #ASTBIG_TYPE
;     beq @safe_astbig
;     cmp #GEM_TYPE
;     beq @safe_gem
;     rts
; @safe_mine:
;     jsr create_explosion_2
;     jsr destroy_2
;     dec current_mine_count
;     rts
; @safe_astsml:
;     jsr create_explosion_2
;     jsr destroy_2
;     rts
; @safe_astbig:
;     ; Split the big
;     jsr split_2
;     rts
; @safe_gem:
;     jsr create_explosion_2
;     jsr count_gems
;     jsr destroy_2
;     rts

create_explosion_active_entity:
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta os_x
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta os_x+1
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sta os_y
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sta os_y+1
    jsr create_explosion
    jsr sound_explode
    rts

ship_energy:
    jsr sound_crystal
    lda hc_outer_entity_count
    cmp #0
    bne @ship_2
    inc ship_1_energy
    inc stats_changed
    rts
@ship_2:
    inc ship_2_energy
    inc stats_changed
    rts

destroy_ship:
    lda hc_outer_entity_count
    cmp #0
    bne @ship_2
    jsr destroy_ship_1
    rts
@ship_2:
    jsr destroy_ship_2
    rts

destroy_ship_1:
    jsr set_ship_1_as_active
    ldy #Entity::_death_count
    lda #SHIP_RESPAWN_COUNT
    sta (active_entity), y
    stz ship_1_energy
    jsr inactivate_entity
    rts

destroy_ship_2:
    jsr set_ship_2_as_active
    ldy #Entity::_death_count
    lda #SHIP_RESPAWN_COUNT
    sta (active_entity), y
    stz ship_2_energy
    jsr inactivate_entity
    rts

destroy_1:
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr inactivate_entity
    rts

destroy_2:
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr inactivate_entity
    rts

destroy_both:
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr inactivate_entity
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr inactivate_entity
    jsr create_explosion_active_entity
    rts

; destroy_ship:
;     ; Ship is always entity1 in this case
;     lda comp_entity1
;     sta active_entity
;     lda comp_entity1+1
;     sta active_entity+1
;     jsr create_explosion_active_entity
;     jsr destroy_active_entity
;     lda #0
;     sta thrusting ; stop thrusting to stop sound
;     lda lives
;     cmp #0
;     bne @more_lives
;     ; game over
;     lda #1
;     sta game_over
;     jsr show_game_over
;     lda #DEAD_SHIP_TIME
;     sta ship_dead
;     rts
; @more_lives:
;     dec lives
;     jsr show_header
;     lda #DEAD_SHIP_TIME
;     sta ship_dead
;     rts

split_index_1: .byte 1
split_index_2: .byte 11
; split_index_3: .byte 11
; split_index_4: .byte 13

split_1:
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr split_active_entity
    rts

split_2:
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr split_active_entity
    rts

split_active_entity:
    jsr create_explosion_active_entity
    jsr inactivate_entity
    jsr drop_gem_from_active_entity
    ldy #Entity::_x
    lda (active_entity), y
    sta astsml_x
    ldy #Entity::_x+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta astsml_x+1
    ldy #Entity::_y
    lda (active_entity), y
    sta astsml_y
    ldy #Entity::_y+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta astsml_y+1
    ; All asteroids need to fly in slightly different directions
    lda split_index_1
    sta astsml_ang_index
    inc; stays between 1-7
    cmp #8
    bne @no_wrap_1
    lda #1
@no_wrap_1:
    sta split_index_1
    jsr launch_astsml
    ; 2nd astsml, active_entity now the astsml that was just launched
    lda split_index_2
    sta astsml_ang_index
    inc; stays between 9-15
    cmp #16
    bne @no_wrap_2
    lda #9
@no_wrap_2:
    sta split_index_2
    jsr launch_astsml
;     ; 3rd astsml, active_entity now the astsml that was just launched
;     lda split_index_3
;     sta astsml_ang_index
;     inc; stays between 8-12
;     cmp #13
;     bne @no_wrap_3
;     lda #8
; @no_wrap_3:
;     sta split_index_3
;     jsr launch_astsml
;     ; 4th astsml, active_entity now the astsml that was just launched
;     lda split_index_4
;     sta astsml_ang_index
;     inc; stays between 13-15
;     cmp #16
;     bne @no_wrap_4
;     lda #13
; @no_wrap_4:
;     sta split_index_4
;     jsr launch_astsml
    rts


; destroy_active_entity:
;     ldy #Entity::_type
;     lda (active_entity), y
;     ldy #Entity::_visible
;     lda #0 ; Hide it
;     sta (active_entity), y
;     ldy #Entity::_sprite_num
;     lda (active_entity), y
;     sta param1
;     jsr update_sprite
;     rts

.endif