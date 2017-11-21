.equ TIMER1, 0xFF202000

.global start_timer
start_timer:
	movia r8, TIMER1		# Store base address of timer in r8
	movi r9, %hi(r4)		# Contains upper16 bits of delay passed in from r4
	movi r10, %lo(r4)	  # Contains lower16 bits of delay passed in from r4
	stwio r10, 8(r8)		# Store lower16 bits of delay in base+8
	stwio r9, 12(r8)		# Store high16 bits of delay in base+12
	stwio r0, 0(r10) 		# Clear timeout bit
	movi r9, 7					# Start timer, continuous, interrupts enabled (least 3 significant bits all set to 1)
  stwio r9, 4(r8)
	ret
