# Add an immediate value to a register and store the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, 5
    addi a0, a0, 3  # a0 = 5 + 3
    j finish

# a0 = 8