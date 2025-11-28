.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li a0, -1                    # -1 is all 1s in binary
    sb a0, 0(sp)                 # Store byte on stack

    lw a0, 0(sp)                 # Load word to check only lower byte
    j finish                     # Loop to check result