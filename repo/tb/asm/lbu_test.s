# Load a byte from memory into a register and zero-extend it to 32 bits

.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li a0, -1                    # -1 is all 1s in binary (0xFF for byte)
    sb a0, 0(sp)

    lbu a0, 0(sp)                # Load byte unsigned back into a0, zero-extended
    j finish
