.equ TIMER1, 0xFF202000

.global start_timer
start_timer:
	movia r8, TIMER1		# Store base address of timer in r8
	add r9, r0, r4
	add r10, r0, r4
	movia r4, 0xFFFF0000
	and r9, r4, r9			# Contains upper16 bits of delay passed in from r4
	srli r9, r9, 16
	movia r4, 0x0000FFFF
	and r10, r4, r10	  # Contains lower16 bits of delay passed in from r4
	stwio r10, 8(r8)		# Store lower16 bits of delay in base+8
	stwio r9, 12(r8)		# Store high16 bits of delay in base+12

	movi r9, 5					# Start timer, interrupts enabled (least 3 significant bits all set to 1)
  stwio r9, 4(r8)

	ret
