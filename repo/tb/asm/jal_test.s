# Jump to a label and store the return address in rd (used for function calls)

.text
.globl main

finish:
    bne     a0, zero, finish     # loop forever (if a0 != 0)

main:
    li a0, 1                     # Wrong output value
    jal ra, correct              # Jump to 'correct' and save return address in 'ra'

    # This line should not be executed if 'correct' is reached
    li a0, 99                    # Wrong output value

.org 8192
correct:
    li a0, 2                     # Correct output value
    j finish
