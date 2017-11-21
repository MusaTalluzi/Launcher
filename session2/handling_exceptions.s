.equ TIMER1, 0xFF202000
.equ HEX0, 0xFF200020
.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ ADDR_JP2, 0xFF200070

# Interrupt service routine starts here at 0x20
.section .exceptions, "ax"
	/* Save registers to enable nested interrupts */
	addi sp, sp, -16
	stw et, 0(sp)
	rdctl et, ctl1
	stw et, 4(sp)
	stw ea, 8(sp)
	stw r16, 12(sp)

	rdctl et, ctl4				# Read in ipending to check the source of interrupt
	movi r16, 0x1
	andi et, et, 0x1			# Check if interrupt from IRQ0 (timer)
	beq et, r16, TIMER_1_INTERRUPT

	rdctl et, ctl4
	andi et, et, 0x2			# Check if interrupt from IRQ1 (bushbuttons)
	movi r16, 0x2
	beq et, r16, BUTTON_INTERRUPT

	br TIMER_1_INTERRUPT # Wasn't a button interrupt, go to the timer1 handler

BUTTON_INTERRUPT:
		# Push r4, r5 and ra to the stack:
		/* Save registers we will use here */
		addi sp, sp, -12
		stw r5, 0(sp)
		stw r4, 4(sp)
		stw ra, 8(sp)

		# Interrupt service routine starts here at 0x20
		movia et, ADDR_PUSHBUTTONS
		ldwio r16, 12(et)		# Get edge capture register to know which button interrupted
		andi r4, r16, 0x1		# Check button0:
		bne r4, r0, LAUNCH

		andi r4, r16, 0x2		# Check button1:
		bne r4, r0, STEER_LEFT

		andi r4, r16, 0x4		# Check button2:
		bne r4, r0, STEER_RIGHT

		# Else, just CONT:
		br CONT
		
		LAUNCH:
			call launch
			br CONT
		
		STEER_LEFT:
			call steer_left
			br CONT

		STEER_RIGHT:
			call steer_right
			br CONT

		CONT:
		movi r16, 0xF			# Clear edge capture register to prevent unexpected interrupt
		stwio r16, 12(et)
		movi r16, 1				# Turn on interrupts
		wrctl ctl0, r16

		#addi r16, r16, 1	# Decrement r16
		#add r4, r16, r0 	# Display content of r16 at HEX0
		#movia r5, HEX0
		#call display

		/* Pop pushed registered from stack */
		ldw ra, 8(sp)
		ldw r4, 4(sp)
		ldw r5, 0(sp)
		addi sp, sp, 12

		br EXIT

TIMER_1_INTERRUPT:
	movia et, TIMER1
	stwio r0, 0(et) 		# Clear timeout bit

	#ldwio r9, 0(r8)			# Clear timeout bit
	#movia r10, ~1
	#and r9, r9, r10
	#stwio r9, 0(r8) 

	movia et, ADDR_JP2    # et contains the address of the lego controller
	/* Save registers we will use */
	addi sp, sp, -4
	stw r5, 0(sp)

	movia r5, 0xFABFABFF  # Turn off all the motors, enable sensors 0, 1, 2
	stwio r5, 0(et)

	/* Restore the saved register */
	ldw r5, 0(sp)
	addi sp, sp, 4

	br EXIT

EXIT:
	ldw r16, 12(sp)
	ldw ea, 8(sp)
	ldw et, 4(sp)
	wrctl ctl4, et
	ldw et, 0(sp)
	addi sp, sp, 16

	addi ea, ea, -4
	eret
