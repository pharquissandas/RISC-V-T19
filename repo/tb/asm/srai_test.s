# Shift the bits in a register right arithmetically by an immediate value (preserving the sign) and store the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, -8  # -8 in binary: 1111...1000
    srai a0, a0, 2  # a0 = -8 >> 2 (arithmetic, preserves sign)
    j finish
