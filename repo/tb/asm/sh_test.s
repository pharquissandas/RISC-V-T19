.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li a0, -1                    # -1 is all 1s in binary
    sh a0, 0(sp)                 # Store halfword on stack

    lw a0, 0(sp)                 # Load word to check only lower halfword
    j finish                     # Loop to check result