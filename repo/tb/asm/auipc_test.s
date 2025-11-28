# Add the upper 20 bits of an immediate to the PC and store the result in rd

.text
.globl main

finish:
    bne     a0, zero, finish     # loop forever

main:
    li a0, 1                     # wrong output value
    auipc t0, %hi(correct)

.org 8192
correct:
    li a0, 2                     # correct output value
    j finish
