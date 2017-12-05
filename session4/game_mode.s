.equ SWITCHES, 0xFF200040

/*
 * Will place 1 in r2 if the game mode is set to timed. 0 otherwise.
 */
.global get_game_mode
get_game_mode:

  # Store registers that we will use on the stack
  addi sp, sp, -8
  stw r8, 4(sp)
	stw r9, 8(sp)

  movia r8, SWITCHES
  ldwio r9, 0(r8)     # Read the switches

  andi r2, r9, 1      # Mask the lsb (for the switch we want), store in the return address

  # Restore the registers
  ldwio r9, 8(sp)
  ldwio r8, 4(sp)
  addi sp, sp, 8

  ret
