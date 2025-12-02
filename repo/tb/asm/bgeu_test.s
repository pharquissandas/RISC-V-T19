# Branch to a label if the first register is greater than or equal to the second register (unsigned comparison)

.text
.globl main

main:
    li t0, 1            # 1 in both signed and unsigned
    li t1, 0xFFFFFFFF   # -1 in signed, but large in unsigned
    bgeu t0, t1, fail   # Should not branch because 1 !>= 0xFFFFFFFF in unsigned
    li a0, 1            # If we don't branch to fail, it's a success
    j finish

fail:
    li a0, 0
    j finish

finish:
    j finish
