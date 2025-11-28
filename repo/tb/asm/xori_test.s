.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, 5
    xori a0, a0, 3  # a0 = 5 ^ 3
    j finish
    