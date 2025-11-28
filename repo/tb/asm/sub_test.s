.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, 5
    li t1, 3
    sub a0, t0, t1  # a0 = t0 - t1
    j finish