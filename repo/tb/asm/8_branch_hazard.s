main:
    li x1, 0          # x1 = 0
    li x2, 10         # x2 = 10
    li x4, 10         # x4 = 10
    sw x4, 0(x2)      # Store x4 (10) into memory at address x2 (10)

    # Branch Test
    # beq takes the branch if x1 == x0
    # x1 = 0 and x0 = 0, so the branch WILL be taken
    beq x1, x0, branch

    # These instructions are skipped because the branch is taken
    add x4, x2, x2    # Would set x4 = 20, but DOES NOT EXECUTE
    add x4, x2, x2    # Skipped
    add x4, x2, x2    # Skipped

branch:
    # Execution resumes here after the branch
    # x4 is still 10 because the skipped instructions never ran
    addi a0, x4, 0    # a0 = x4 = 10  (used for checking)
