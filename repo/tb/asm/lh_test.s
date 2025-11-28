.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li t0, 0x7FFF                # 0x7FFF is the highest positive halfword value, no sign extension
    sh t0, 2(sp)

    lh a0, 2(sp)
    j finish