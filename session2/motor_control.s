.equ ADDR_JP2, 0xFF200070  # Address GPIO JP2

.global launch
launch:
  # write to ADDR_JP2, enabling motor 1
  # call a delay so that the motor can launch the ball
  # turn off the motor
