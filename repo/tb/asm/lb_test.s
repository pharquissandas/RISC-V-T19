# Load a byte from memory into a register and sign-extend it to 32 bits

.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li t0, 0x7F                  # 0x7F is the highest positive byte value, no sign extension
    sb t0, 1(sp)

    lb a0, 1(sp)
    j finish
