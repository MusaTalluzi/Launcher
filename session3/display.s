/* DISPLAY subroutine
 *  Converts a number of the form 0x1234 to that which can be displayed 
 *  on the HEX displays
 *
 * Subroutine arguments:
 * R4: the number in binary to be written to the 7-Seg
 * R5: address of the 7-Seg display
 *
 * Subroutine registers:
 * R8 : converted number
 * R9 : counter for the loop. counts from 4 to 1
 * R10: current digit to be converted
 * R11: current digit in 7-Seg form
 */
.global display
display:
  /* store registers used by this subroutine to the stack */
  addi  sp,  sp,-24			/* First reserve space on the stack */ 
  stw   r4,  0(sp)			/* Storing r4 on the stack */
  stw   r5,  4(sp)			/* Storing r5 on the stack */
  stw   r8,  8(sp)			/* Storing r8 on the stack */
  stw   r9,  12(sp)			/* Storing r9 on the stack */
  stw   r10, 16(sp)			/* Storing r10 on the stack */
  stw   r11, 20(sp)			/* Storing r11 on the stack */

  movi  r8,  0				/* Clear the result register */
  movi  r9,  4				/* Initialize the loop counter */

DIGIT_LOOP:

  andi  r10, r4, 0x0F		/* Get the current digit */
  ldbu  r11, PATTERNS(r10)	/* Load the 7-Seg format */
  or	r8,  r8, r11		/* Include the new digit */
  roli  r8,  r8, 24			/* Rotate the digit in the correct position */

  srli  r4,  r4, 4			/* Go to the next digit */

  subi  r9,  r9, 1			/* Decrement loop counter */
  bgtu  r9,  r0, DIGIT_LOOP	/* Loop if more digits need to be converted */ 
  
  stwio r8,  0(r5)			/* Store converted digits to 7-seg display */

DISPLAY_DONE:
  /* restore registers used by this subroutine from the stack */
  ldw   r4,  0(sp)			/* Loading r4 from the stack */
  ldw   r5,  4(sp)			/* Loading r5 from the stack */
  ldw   r8,  8(sp)			/* Loading r8 from the stack */
  ldw   r9,  12(sp)			/* Loading r9 from the stack */
  ldw   r10, 16(sp)			/* Loading r11 from the stack */
  ldw   r11, 20(sp)			/* Loading r11 from the stack */
  addi  sp,  sp, 24			/* Lastly, free up the space on the stack */

  ret						/* Return from the subroutine */

.data
  
/* Store the 7-segment patterns starting at memory address 0x200 */
PATTERNS:
.byte  0x3f           		/* 0 */
.byte  0x06           		/* 1 */
.byte  0x5b           		/* 2 */
.byte  0x4f           		/* 3 */
.byte  0x66           		/* 4 */
.byte  0x6d           		/* 5 */
.byte  0x7d           		/* 6 */
.byte  0x07           		/* 7 */
.byte  0xff           		/* 8 */
.byte  0x6f           		/* 9 */
.byte  0x77           		/* A */
.byte  0xfc           		/* B */
.byte  0x39           		/* C */
.byte  0x5e           		/* D */
.byte  0xf9           		/* E */
.byte  0xf1           		/* F */
	
/**** END ****/ 
