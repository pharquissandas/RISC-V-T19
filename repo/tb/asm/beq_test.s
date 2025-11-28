# Branch to a label if two registers are equal

.text
.globl main

main:
    li t0, 5                     # Set a0 to 5
    li t1, 5                     # Set a1 to 5 (equal to a0)
    beq t0, t1, pass             # Branch to pass if a0 equals a1

    j fail                       # If not equal, jump to fail

pass:
    li a0, 1                     # Set a0 to 1 for success
    j finish                     # Loop to check result

fail:
    li a0, 0                     # Set a0 to 0 for failure
    j finish                     # Loop to check result

finish:
    j finish                     # Loop forever