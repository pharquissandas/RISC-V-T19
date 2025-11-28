.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li a0, -1                    # -1 is all 1s in binary (0xFFFF for halfword)
    sh a0, 0(sp)

    lhu a0, 0(sp)                # Load halfword unsigned back into a0, zero-extended
    j finish