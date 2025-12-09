# moves a single light left then resets

main:
    li      s0, 1           # start with bit 0 (0000000001)
    li      s1, 512         # 10th LED is 2^9 = 512    

loop_left:
    mv      a0, s0          # output to LEDs
    beq     s0, s1, reset   # reset if reached top
    slli    s0, s0, 1       # shift left by 1
    j       loop_left

reset:
    li      s0, 1
    j       loop_left
