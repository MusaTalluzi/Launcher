.equ IRQ_PUSHBUTTONS, 0x2
.equ IRQ_TIMER1, 0x1
.equ IRQ_JP2, 0x1000
.equ HEX0, 0xFF200020

/*
* r20: Contains the score for player 1
* r21: Contains the score for player 2
* r22: Contains the randomly generated target number (values match with the lego edge register)
* r23: Contains the current player (0 = player 1, 1 = player 2)
*/
.global _start
_start:
	movia sp, 0x04000000	# Initialize stack
	call init_pushbuttons
	call init_lego
	call init_timer

	# Initialize all of the tracked registers
	add r20, r0, r0
	add r21, r0, r0
	addi r23, r0, 1 #	Start with player 2, will flip to player 1 the first time the start button is pressed

	rdctl r16, ctl3
	ori r16, r16, IRQ_TIMER1			# Set IRQ0 to enable TIMER interrupts
	ori r16, r16, IRQ_PUSHBUTTONS	# Set IRQ1 to enable PUSH_BUTTONS interrupts
	ori r16, r16, IRQ_JP2					# Set IRQ12 to enable JP2 interrupts
	wrctl ctl3, r16								# Enable previous interrupts

	rdctl r16, ctl0		# Enable global interrupts
	ori r16, r16, 1
	wrctl ctl0, r16

	movi r16, 0				# Stores 5 in r16
	add r4, r16, r0 	# Display content of r16 at HEX0
	movia r5, HEX0
	call display

	movi r17, 5

LOOP:
	# TODO: display the score and the player's turn
	br LOOP
