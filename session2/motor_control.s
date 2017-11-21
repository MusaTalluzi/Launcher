.equ ADDR_JP2, 0xFF200070           # Address GPIO JP2
.equ LAUNCH_TIME_PERIOD, 1 << 27		# About 1.28s

.global launch
launch:
  movia r8, ADDR_JP2    # r8 contains the address of the controller
	movia r9, 0xFABFABFE  # Turn on motor 0, enable sensors 0, 1, 2
  stwio r9, 0(r8)

  movia r4, LAUNCH_TIME_PERIOD  # r4 contains the time the motors will run for
  call start_timer              # Motor will be turned off when an interrupt occurs (within the ISR)
