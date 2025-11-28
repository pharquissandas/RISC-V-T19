.text
.globl main
main:
    lui t0, 0b10101010101010101010     # load top 20 bits
    addi t0, t0, -1 # load bottom 12 bits
    add a0, zero, t0                   # output = 0b10101010101010101010 - 1