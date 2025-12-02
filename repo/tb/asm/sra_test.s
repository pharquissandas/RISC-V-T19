# Shift the bits in a register right arithmetically (preserving the sign) and store the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, -8  # -8 in binary: 1111...1000
    li t1, 2
    sra a0, t0, t1  # a0 = t0 >> t1 (arithmetic, preserves sign)
    j finish
