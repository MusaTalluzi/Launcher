.equ ADDR_AUDIO_DAC, 0xFF203040
.equ BEEP_LENGTH, 2000
.equ BEEP_FREQUENCY, 2000
.equ BEEP_AMPLITUDE, 10000000

.global beep
beep:

  /* Save registers that will be used */
  addi sp, sp, -12
  stw r4, 0(sp)
  stw r5, 4(sp)
  stw r6, 8(sp)
  stw r7, 12(sp)

  addi r4, r0, BEEP_LENGTH
  addi r5, r0, BEEP_FREQUENCY
  addi r6, r0, BEEP_AMPLITUDE
  movia r7, ADDR_AUDIO_DAC

  LOOP:
    subi r4, r4, 1

    POSITIVE:
      subi r5, r5, 1
      stwio r6, 8(r7)       # Echo amplitude to left channel
      stwio r6, 12(r7)      # Echo amplitude to right channel
      bne r5, r0, POSITIVE

      addi r5, r0, BEEP_FREQUENCY  # Reset the beep frequency for the negative

    NEGATIVE:
      subi r5, r5, 1
      stwio r6, 8(r7)      # amplitude Echo to left channel
      stwio r6, 12(r7)     # amplitude Echo to right channel
      bne r5, r0, NEGATIVE

      addi r5, r0, BEEP_FREQUENCY  # Reset the beep frequency for the positive

  bne r4, r0, LOOP

  /* Restore registers that were used */
  stw r7, 12(sp)
  stw r6, 8(sp)
  stw r5, 4(sp)
  stw r4, 0(sp)
  addi sp, sp, -8

  ret
