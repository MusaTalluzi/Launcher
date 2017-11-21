# --- TIMER --- #
.equ TIMER1, 0xFF202000
.equ TIME_PERIOD, 1 << 27		# Almost 1.28s

# --- BUTTONS --- #
.equ IRQ_PUSHBUTTONS, 0x02
.equ ADDR_PUSHBUTTONS, 0xFF200050

# --- LEGO CONTROLLER --- #
.equ ADDR_JP2, 			0xFF200070	# Address GPIO JP2
.equ ADDR_JP2_IRQ, 	0x1000   		# IRQ line for GPIO JP2 (IRQ12)
.equ STATE_MODE, 		0xFADFFFFE
.equ ADDR_JP2_EDGE, 0xFF20007C  # Address Edge Capture register GPIO JP2

.global init_timer
init_timer:
	movia r8, TIMER1						# Store base address of timer in r8
	movi r9, %hi(TIME_PERIOD)		# r9 contains upper16 bits of delay
	movi r10, %lo(TIME_PERIOD)	# r10 contains lower16 bits of delay
	stwio r10, 8(r8)			# Store lower16 bits of delay in base+8
	stwio r9, 12(r8)			# Store high16 bits of delay in base+12
	stwio r0, 0(r10) 			# clear timeout bit, just in case
	movi r9, 7						# start timer, continuous, interrupt enabled (least 3 significant bits all set to 1)
  stwio r9, 4(r8)

	ret

.global init_pushbuttons
init_pushbuttons:
	movia r8, ADDR_PUSHBUTTONS
	movia r9, 0xF				# Enable interrrupt mask = 1111
	stwio r9, 8(r8)  		# Enable interrupts on pushbuttons 1,2, and 3
	stwio r9, 12(r8)		# Clear edge capture register to prevent unexpected interrupt

	ret

.global init_lego
init_lego:
	movia r8, ADDR_JP2         # r8 contains the address of the controller
	movia r9, 0x07F557FF       # Set motor, threshold and sensors bits to output, set state and sensor valid bits to inputs
	stwio r9, 4(r8)

	movia  r10,  0xFABFABFF    # Turn all motors off, enable sensors 0, 1, 2
  stwio  r10,  0(r8)

  movia r10, STATE_MODE      # Enable state mode
  stwio r10, 0(r8)

	movia r10, 0xF8000000      # Enable interrupts for the sensors
  stwio r10, 8(r8)

  movia r10, 0xFFFFFFFF			 # Clear the edge register
  stwio r10, 12(r8)
