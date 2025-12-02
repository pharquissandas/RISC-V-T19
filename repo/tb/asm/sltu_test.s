# Set rd to 1 if the first register is less than the second register (unsigned comparison), otherwise set rd to 0

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, 0xFFFFFFFF  # -1 in signed, largest unsigned 32-bit number
    li t1, 1
    sltu a0, t0, t1    # a0 = (t0 < t1) in unsigned compare ? 1 : 0
    j finish
