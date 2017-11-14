.equ TIMER1, 0xFF202000 
.equ TIME_PERIOD, 1 << 27		# Almost 1.28s
.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ IRQ_PUSHBUTTONS, 0x02

.global init_timer
init_timer:
	movia r8, TIMER1			# Store base address of timer in r8
	movi r9, %hi(TIME_PERIOD)	# r9 contains upper16 bits of delay
	movi r10, %lo(TIME_PERIOD)	# r10 contains lower16 bits of delay
	stwio r10, 8(r8)			# Store lower16 bits of delay in base+8
	stwio r9, 12(r8)			# Store high16 bits of delay in base+12
	stwio r0, 0(r10) 			# clear timeout? bit, just in case¨
	
	movi r9, 7					# start timer, continuous, interrupt enabled (least 3 significant bits all set to 1)
    stwio r9, 4(r8)

	ret							# Resume execution

.global init_pushbuttons
init_pushbuttons:
	movia r8,ADDR_PUSHBUTTONS
	movia r9,0xF				# Enable interrrupt mask = 1111
	stwio r9,8(r8)  			# Enable interrupts on pushbuttons 1,2, and 3
	stwio r9,12(r8)				# Clear edge capture register to prevent unexpected interrupt
	
	ret
