.text
.globl main

finish:
    bne     a0, zero, finish     # Loop forever if a0 is not zero

main:
    li a0, -1                    # -1 is all 1s
    sw a0, 0(sp)                 # Store word

    lw a0, 0(sp)                 # Load word
    j finish                     # Loop to check result