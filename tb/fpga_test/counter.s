main:
    li s0, 0    # s0 is counter

loop:
    mv      a0, s0      # update LED/Hex output
    addi    s0, s0, 1   # increment counter
    j loop              # repeat
