# Add the two registers and put the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, 5
    li t1, 3
    add a0, t0, t1  # a0 = t0 + t1
    j finish

# a0 = 8
