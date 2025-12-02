# Branch to a label if two registers are not equal

.text
.globl main

main:
    li t0, 5
    li t1, 6
    bne t0, t1, pass
    j fail

pass:
    li a0, 1
    j finish

fail:
    li a0, 0
    j finish

finish:
    j finish
