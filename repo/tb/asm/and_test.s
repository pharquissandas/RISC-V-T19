# Perform bitwise AND of two registers and store the result in rd

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, 5        # t0 = 5  (binary 0101)
    li t1, 3        # t1 = 3  (binary 0011)
    and a0, t0, t1  # a0 = t0 & t1
    j finish

# a0 = 1