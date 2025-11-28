.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, 5
    slli a0, a0, 2  # a0 = 5 << 2
    j finish