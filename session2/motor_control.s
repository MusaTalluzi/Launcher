.equ ADDR_JP2, 0xFF200070           # Address GPIO JP2
.equ LAUNCH_TIME_PERIOD, 1 << 24	# 0.01s #About 1.28s
.equ STEER_TIME_PERIOD, 1 << 20		# 0.01s
.equ MOTOR1_FORWARD, 0xFABFABCF
.equ MOTOR1_BACKWARD, 0xFABFABEF
/*
 * Control motors 0 for launching and 1 for steering
 * Uses registers r4, r8, and r9
 */
 
.global launch
launch:
  # Push ra to stack:
  addi sp, sp, -4
  stw ra, 0(sp)

  movia r8, ADDR_JP2    # r8 contains the address of the controller
  movia r9, 0xFABFABFE  # Turn on motor 0, enable sensors 0, 1, 2
  stwio r9, 0(r8)

  movia r4, LAUNCH_TIME_PERIOD  # r4 contains the time the motors will run for
  call start_timer              # Motor will be turned off when an interrupt occurs (within the ISR)

  # Pop ra from stack:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
  
.global steer_right
steer_right:
  # Push ra to stack:
  addi sp, sp, -4
  stw ra, 0(sp)

  movia r8, ADDR_JP2			# r8 contains the address of the controller
  movia r9, MOTOR1_FORWARD		# Turn on motor 1 to the right, enable sensors 0, 1, 2
  stwio r9, 0(r8)

  movia r4, STEER_TIME_PERIOD   # r4 contains the time the motors will run for
  call start_timer              # Motor will be turned off when an interrupt occurs (within the ISR)
  
  # Pop ra from stack:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
  
.global steer_left
steer_left:
  # Push ra to stack:
  addi sp, sp, -4
  stw ra, 0(sp)

  movia r8, ADDR_JP2			# r8 contains the address of the controller
  movia r9, MOTOR1_BACKWARD		# Turn on motor 1 to the right, enable sensors 0, 1, 2
  stwio r9, 0(r8)

  movia r4, STEER_TIME_PERIOD   # r4 contains the time the motors will run for
  call start_timer              # Motor will be turned off when an interrupt occurs (within the ISR)

  # Pop ra from stack:
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
