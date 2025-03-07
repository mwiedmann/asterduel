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

.endif