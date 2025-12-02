# Shift the bits in a register right logically by an immediate value (fill with zeros) and store the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li a0, -8  # -8 in binary: 1111...1000 (assuming 32-bit)
    srli a0, a0, 2  # a0 = -8 >> 2 (logical, should not sign extend)
    j finish
