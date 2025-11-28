# Branch to a label if the first register is less than the second register

.text
.globl main

main:
    li t0, 3
    li t1, 5
    blt t0, t1, pass
    j fail

pass:
    li a0, 1
    j finish

fail:
    li a0, 0
    j finish

finish:
    j finish