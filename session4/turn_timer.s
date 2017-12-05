.equ TIMER2, 0xxFF202020

.global turn_timer
turn_timer:
	movia r8, TIMER2		# Store base address of timer in r8
	add r9, r0, r4
	add r10, r0, r4
	movia r4, 0xFFFF0000
	and r9, r4, r9			# Contains upper16 bits of delay passed in from r4
	srli r9, r9, 16
	movia r4, 0x0000FFFF
	and r10, r4, r10	  # Contains lower16 bits of delay passed in from r4
	stwio r10, 8(r8)		# Store lower16 bits of delay in base+8
	stwio r9, 12(r8)		# Store high16 bits of delay in base+12

	movi r9, 4					# Start timer
  stwio r9, 4(r8)

	ret

.global check_turn_timer
check_turn_timer:
  movia r8, TIMER2		# Store base address of timer in r8
  andi r2, r8, 1
  ret
