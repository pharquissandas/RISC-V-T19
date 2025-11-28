.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, 5
    slti a0, a0, 10  # a0 = (5 < 10) ? 1 : 0
    j finish