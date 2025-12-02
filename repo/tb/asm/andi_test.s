# Perform bitwise AND of a register with an immediate value and store the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, 5          # a0 = 5 (binary 0101)
    andi a0, a0, 3    # a0 = a0 & 3
    j finish

# a0 = 1
