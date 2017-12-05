.equ TIMER1, 0xFF202000
.equ HEX0, 0xFF200020
.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ ADDR_JP2, 0xFF200070
.equ PS2_CONTROLLER1_ADDR, 0xFF200100
.equ SENSOR_MASK, 3 << 27
.equ TURN_TIME, 1 << 30 # Aprox. 10s

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

	# Check if interrupt from IRQ0 (timer):
	movi r16, 0x1
	andi et, et, 0x1
	beq et, r16, TIMER_1_INTERRUPT

	# Check if interrupt from IRQ1 (push buttons):
	rdctl et, ctl4
	andi et, et, 0x2
	movi r16, 0x2
	beq et, r16, BUTTON_INTERRUPT

	# Check if interrupt from IRQ7 (PS2 Keyboard):
	rdctl et, ctl4
	andi et, et, 0x80
	movi r16, 0x80
	beq et, r16, KEYBOARD_INTERRUPT

	# Check if interrupt from IRQ12 (JP2):
	rdctl et, ctl4
	andi et, et, 1 << 12
	movi r16, 1 << 12
	beq et, r16, LEGO_INTERRUPT

	# Unknown interrupt, exit:
	br EXIT

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

		andi r4, r16, 0x1		# Check if button0
		bne r4, r0, LAUNCH

		andi r4, r16, 0x2		# Check if button1
		bne r4, r0, STEER_LEFT

		andi r4, r16, 0x4		# Check if button2
		bne r4, r0, STEER_RIGHT

		# Otherwise, just CONT:
		br CONT

		LAUNCH:
			call launch
			br CONT

		STEER_LEFT:
			addi r20, r20, 1	# remove it later
			call steer_left
			br CONT

		STEER_RIGHT:
			addi r21, r21, 1	# remove it later
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

	#ldwio r9, 0(r8)		# Clear timeout bit
	#movia r10, ~1
	#and r9, r9, r10
	#stwio r9, 0(r8)

	movia et, ADDR_JP2		# et contains the address of the lego controller
	/* Save registers we will use */
	addi sp, sp, -4
	stw r5, 0(sp)

	movia r5, 0xFABFABFF	# Turn off all the motors, enable sensors 0, 1, 2
	stwio r5, 0(et)

	/* Restore the saved register */
	ldw r5, 0(sp)
	addi sp, sp, 4

	br EXIT

KEYBOARD_INTERRUPT:
	/* Save registers we will use here */
	addi sp, sp, -16
	stw r5, 0(sp)
	stw r4, 4(sp)
	stw ra, 8(sp)
	stw r6, 12(sp)

	READ_CHAR:
	movia et, PS2_CONTROLLER1_ADDR
	ldwio r4, 0(et)				# Read base register
	movia r5, 0xF000			# Ensure data is valid, if not exist
	and r5, r4, r5
	beq r5, r0, EXIT

	# If read value is E0, read next one:
	movi r6, 0xE0
	movia r5, 0xFF
	and r5, r4, r5
	beq r5, r6, READ_CHAR

	# Data is valid, see source key:
	movi r5, 0x6B				# Left arrow, steer left (TODO: should we also check E0?)
	add r6, r4, r0
	andi r6, r6, 0xFF
	beq r5, r6, KEYBOARD_STEER_LEFT

	movi r5, 0x74				# Right arrow, steer left (TODO: should we also check E0?)
	add r6, r4, r0
	andi r6, r6, 0xFF
	beq r5, r6, KEYBOARD_STEER_RIGHT

	movi r5, 0x5A				# Enter; launch
	add r6, r4, r0
	andi r6, r6, 0xFF
	beq r5, r6, KEYBOARD_LAUNCH

	movi r5, 0x29				# Space; switch player, set target
	add r6, r4, r0
	andi r6, r6, 0xFF
	beq r5, r6, PREPARE_TURN

	# If none of these, just exit:
	br KEYBOARD_CONT

		KEYBOARD_LAUNCH:
		# addi r23, r23, 1	# remove it later
		call launch
		br KEYBOARD_CONT

		KEYBOARD_STEER_LEFT:
			#addi r20, r20, 1	# remove it later
			call steer_left
			br KEYBOARD_CONT

		KEYBOARD_STEER_RIGHT:
			#addi r21, r21, 1	# remove it later
			call steer_right
			br KEYBOARD_CONT

		PREPARE_TURN:
			xori r23, r23, 1
			call get_random_target
			addi r22, r0, 1
			sll r22, r22, r2 # Store 1 shifted over by the target number

			call get_game_mode
			beq r2, r0, KEYBOARD_CONT # Continue if game mode = 0 (not timed)

			# Start the turn timer
			movia r4, TURN_TIME
			call turn_timer  # Not saving regs since they will not be used again

			br KEYBOARD_CONT

		EMPTY_BUF:
			ldwio r4, 0(et)			# Read base register
			movia r5, 0xF000	  # If data valid, keep reading
			and r5, r4, r5
			bne r5, r0, EMPTY_BUF
			br KEYBOARD_CONT

	KEYBOARD_CONT:
		# Delay for a while:
		movia r4, 1 << 20 # delay for 0.1s
		DELAY:
			subi r4, r4, 1
			bne r4, r0, DELAY

		EMPTY_LOOP:
			ldwio r4, 0(et)			# Read base register
			movia r5, 0xF000	    # If data valid, keep reading
			and r5, r4, r5
			bne r5, r0, EMPTY_LOOP

		movi r16, 1			# Clear edge capture register to prevent unexpected interrupt
		stwio r16, 4(et)
		movi r16, 1			# Turn on interrupts
		wrctl ctl0, r16

	/* Pop pushed registered from stack */
	ldw r6, 12(sp)
	ldw ra, 8(sp)
	ldw r4, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 16

	br EXIT

LEGO_INTERRUPT:
		/* Save registers we will use */
		addi sp, sp, -12
		stw r4, 0(sp)
		stw r5, 4(sp)
		stw ra, 8(sp)

		movia et, ADDR_JP2
		ldwio r4, 12(et) # Get the edge register

		movia r5, SENSOR_MASK
		and r4, r4, r5	# mask bit 27 & 28 (sensors 0 and 1)
		srli r4, r4, 27

		beq r4, r22, CORRECT_TARGET # Branch if the target hit is the one that was indicated (r22 holds the target)
		br FINISH_LEGO # Otherwise the incorrect target was hit

		CORRECT_TARGET:
			call check_turn_timer
			bne r2, r0, FINISH_LEGO # Check if the turn timer has completed

			#call beep 				# Beep the speakers

			beq r23, r0, PLAYER_1
			addi r21, r21, 1 	# Otherise, increment player 2 score
			br FINISH_LEGO

			PLAYER_1:
				addi r20, r20, 1 	# Increment player 1 score
				br FINISH_LEGO

		FINISH_LEGO:
			movia r4, 0xFFFFFFFF
			stwio r4, 12(et) # Clear the edge register

		/* Restore the saved register */
		ldw ra, 8(sp)
		ldw r5, 4(sp)
		ldw r4, 0(sp)
		addi sp, sp, 12

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
