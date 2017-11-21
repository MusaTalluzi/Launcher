/* Test timer, pushbuttons and hex display are working */
.equ IRQ_PUSHBUTTONS, 0x02
.equ HEX0, 0xFF200020

.global _start
_start:
	rdctl r16, ctl3
	#ori r16, r16, 1				# Set IRQ0 to enable TIMER interrupts
	ori r16, r16, IRQ_PUSHBUTTONS	# Set IRQ1 to enable PUSH_BUTTONS interrupts
	wrctl ctl3, r16					# Enable previous interrupts

	rdctl r16, ctl0					# Enable global interrupts
	ori r16, r16, 1
	wrctl ctl0, r16

	movi r16, 0				# Stores 5 in r16
	add r4, r16, r0 	# Display content of r16 at HEX0
	movia r5, HEX0
	call display

	#call init_timer
	call init_pushbuttons
	call init_lego

	movi r17, 5

LOOP:					# Loop until r16 = 0
	bne r16, r17, LOOP

END:
	br END
