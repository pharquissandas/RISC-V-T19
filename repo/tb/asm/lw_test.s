.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li a0, -1                    # -1 is all 1s in binary (0xFFFFFFFF)
    sw a0, 0(sp)

    lw a0, 0(sp)
    j finish