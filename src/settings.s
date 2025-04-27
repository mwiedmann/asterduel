.ifndef SETTINGS_S
SETTINGS_S = 1

ship_1_energy: .byte 0
ship_2_energy: .byte 0
shield_1_energy: .byte 0
shield_2_energy: .byte 0
base_1_energy: .byte 0
base_2_energy: .byte 0
game_over: .byte 0

shield_starting_energy: .byte 25
base_starting_energy: .byte 25

reset_settings:
    lda #0
    sta ship_1_energy
    sta ship_2_energy
    sta game_over
    lda shield_starting_energy
    sta shield_1_energy
    sta shield_2_energy
    lda base_starting_energy
    sta base_1_energy
    sta base_2_energy
    jsr test_settings
    rts

test_settings:
    lda #5
    sta ship_1_energy
    sta ship_2_energy
    rts

.endif