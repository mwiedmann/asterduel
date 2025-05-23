.ifndef SOUND_S
SOUND_S = 1

SOUND_PRIORITY_SHOOT = 0
SOUND_PRIORITY_EXPLODE = 1
SOUND_PRIORITY_THRUST = 2
SOUND_PRIORITY_CRYSTAL = 1
SOUND_PRIORITY_MINE = 3
SOUND_PRIORITY_CUT = 3

zsmkit_filename: .asciiz "zsmkit.bin"

soundmuted: .byte 0

sound_init:
	; load the zsmkit code into banked RAM
	lda #ZSM_BANK
	sta BANK
    lda #10
    ldx #<zsmkit_filename
    ldy #>zsmkit_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #0
    ldx #<HIRAM
    ldy #>HIRAM
    jsr LOAD
	; Init zsmkit
	lda #ZSM_BANK
	sta BANK
    ldx #<zsmreserved
    ldy #>zsmreserved
	jsr zsm_init_engine
	lda #ZSM_BANK
	sta BANK
	jsr zsmkit_setisr
	jsr sound_set_bank
    rts

sound_set_bank:
	; Set bank for all priorities (currently all the same)
	ldx #0
	lda #SOUND_BANK
	jsr zsm_setbank
	ldx #1
	lda #SOUND_BANK
	jsr zsm_setbank
	ldx #2
	lda #SOUND_BANK
	jsr zsm_setbank
	ldx #3
	lda #SOUND_BANK
	jsr zsm_setbank
	rts

sound_shoot:
	lda soundmuted
	cmp #1
	beq @done
	lda #<MISSILE_SOUND
	ldx #SOUND_PRIORITY_SHOOT ; Priority
	ldy #>MISSILE_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_SHOOT
	jsr zsm_play
@done:
    rts

sound_explode:
	lda soundmuted
	cmp #1
	beq @done
	lda #<EXPLODE_SOUND
	ldx #SOUND_PRIORITY_EXPLODE ; Priority
	ldy #>EXPLODE_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_EXPLODE
	jsr zsm_play
@done:
    rts

sound_crystal:
	lda soundmuted
	cmp #1
	beq @done
	lda #<CRYSTAL_SOUND
	ldx #SOUND_PRIORITY_CRYSTAL ; Priority
	ldy #>CRYSTAL_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_CRYSTAL
	jsr zsm_play
@done:
    rts

sound_mine:
	lda soundmuted
	cmp #1
	beq @done
	lda #<MINE_SOUND
	ldx #SOUND_PRIORITY_MINE ; Priority
	ldy #>MINE_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_MINE
	jsr zsm_play
@done:
    rts

playing_thrust: .byte 0

sound_thrust_check:
	lda soundmuted
	cmp #1
	beq @done
	lda thrusting_1
	cmp #1
	beq @thrusting
	lda thrusting_2
	cmp #1
	beq @thrusting
	; not thrusting, turn sound off if playing
	lda playing_thrust
	cmp #0
	beq @done
	jsr sound_thrust_stop
	bra @done
@thrusting:
	lda playing_thrust
	cmp #1
	beq @done
	jsr sound_thrust_play
@done:
    rts

sound_thrust_stop:
	lda soundmuted
	cmp #1
	beq @done
	ldx #SOUND_PRIORITY_THRUST
	jsr zsm_stop
	lda #0
	sta playing_thrust
@done:
	rts

sound_thrust_play:
	lda soundmuted
	cmp #1
	beq @done
	lda #<THRUST_SOUND
	ldx #SOUND_PRIORITY_THRUST ; Priority
	ldy #>THRUST_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_THRUST
	jsr zsm_play
	lda #1
	sta playing_thrust
@done:
	rts

sound_cut_play:
	lda soundmuted
	cmp #1
	beq @done
	jsr sound_cut_stop
	lda #<CUT_SOUND
	ldx #SOUND_PRIORITY_CUT ; Priority
	ldy #>CUT_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_CUT
	jsr zsm_play
@done:
	rts

sound_cut_stop:
	lda soundmuted
	cmp #1
	beq @done
	ldx #SOUND_PRIORITY_CUT
	jsr zsm_stop
@done:
	rts

sound_toggle:
	lda soundmuted
	eor #%1
	sta soundmuted
	rts
	
sound_all_stop:
	jsr sound_thrust_stop
	rts

.endif