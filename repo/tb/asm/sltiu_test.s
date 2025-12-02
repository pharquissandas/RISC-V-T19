# Set rd to 1 if the register is less than an immediate value (unsigned comparison), otherwise set rd to 0

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, 0xFFFFFFFF  # -1 in signed, largest unsigned 32-bit number
    sltiu a0, a0, 1    # a0 = (0xFFFFFFFF < 1) in unsigned compare ? 1 : 0
    j finish
