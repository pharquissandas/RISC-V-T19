.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, -8  # -8 in binary: 1111...1000
    li t1, 2
    srl a0, t0, t1  # a0 = t0 >> t1 (logical, should not sign extend)
    j finish