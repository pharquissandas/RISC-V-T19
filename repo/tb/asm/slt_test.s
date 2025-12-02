# Set rd to 1 if the first register is less than the second register (signed comparison), otherwise set rd to 0

.text
.globl main

finish:
    bne a0, zero, finish

main:
    li t0, 5
    li t1, 10
    slt a0, t0, t1  # a0 = (t0 < t1) ? 1 : 0
    j finish
