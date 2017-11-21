.equ TIMER1, 0xFF202000
.equ HEX0, 0xFF200020
.equ ADDR_PUSHBUTTONS, 0xFF200050

# Interrupt service routine starts here at 0x20
.section .exceptions, "ax"
	# Push r4, r5 and ra to the stack:
	addi sp, sp, -12
	stw r5, 0(sp)
	stw r4, 4(sp)
	stw ra, 8(sp)

	movia et, ADDR_PUSHBUTTONS
	movi r4, 0xF			# Clear edge capture register to prevent unexpected interrupt
	stwio r4,12(et)

	addi r16, r16, 1	# Decrement r16
	add r4, r16, r0 	# Display content of r16 at HEX0
	movia r5, HEX0
	call display

	# Pop pushed registered from stack:
	ldw ra, 8(sp)
	ldw r4, 4(sp)
	ldw r5, 0(sp)
	addi sp, sp, 12

	addi ea, ea, -4	# Decrement to resume the interupted instruction
	eret
