.equ IRQ_PUSHBUTTONS, 0x2
.equ IRQ_TIMER1, 0x1
.equ IRQ_JP2, 0x1000
.equ IRQ_PS2_KEYBOARD, 1 << 7
.equ HEX0, 0xFF200020

/*
* r20: Contains the score for player 1
* r21: Contains the score for player 2
* r22: Contains the randomly generated target number (values match with the lego edge register)
*/
.global _start
_start:
	# Init stack and devices:
	movia sp, 0x04000000
	call init_pushbuttons
	call init_lego
	call init_timer
	call init_keyboard

	# Enable devices interrupts:
	rdctl r16, ctl3
	ori r16, r16, IRQ_TIMER1			# Set IRQ0 to enable TIMER interrupts
	ori r16, r16, IRQ_PUSHBUTTONS		# Set IRQ1 to enable PUSH_BUTTONS interrupts
	ori r16, r16, IRQ_JP2				# Set IRQ12 to enable JP2 interrupts
	ori r16, r16, IRQ_PS2_KEYBOARD		# Set IRQ7 to enable PS2 keyboard interrupts
	wrctl ctl3, r16						# Enable previous interrupts

	rdctl r16, ctl0						# Enable global interrupts
	ori r16, r16, 1
	wrctl ctl0, r16

	## Start game:
	movi r16, 0				# Stores 5 in r16
	add r4, r16, r0 		# Display content of r16 at HEX0
	movia r5, HEX0
	call display

	movi r17, 5

LOOP:
	br LOOP
