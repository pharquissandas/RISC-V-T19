# Branch to a label if the first register is greater than or equal to the second register

.text
.globl main

main:
    li t0, 5
    li t1, 5
    bge t0, t1, pass
    j fail

pass:
    li a0, 1
    j finish

fail:
    li a0, 0
    j finish

finish:
    j finish
