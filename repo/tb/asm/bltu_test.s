# Branch to a label if the first register is less than the second register (unsigned comparison)

.text
.globl main

main:
    li t0, 0xFFFFFFFF   # -1 in signed, but large in unsigned
    li t1, 1            # 1 in both signed and unsigned
    bltu t0, t1, fail   # Should branch because 0xFFFFFFFF < 1 in unsigned comparison
    j pass              # If we don't branch, we fail the test

pass:
    li a0, 1            # Set to 1 for pass
    j finish

fail:
    li a0, 0            # Set to 0 for fail
    j finish

finish:
    j finish