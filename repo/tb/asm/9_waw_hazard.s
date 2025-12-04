main:
    li x1, 0           # x1=0
    li x2, 10          # x2=10
    li x4, 10          # x4=10

    sw x4, 0(x2)       # First write to memory[x2]:
                       # memory[10] = 10

    sw x1, 0(x2)       # Second write to same address:
                       # memory[10] = 0
                       # This overwrites the previous store.
                       # This is a WAW hazard (Write-After-Write)
                       # to the *memory location*, since the second
                       # store must appear after the first but both
                       # target the same address.

    lw x5, 0(x2)       # Load the final value in memory[10]
                       # Should load 0, the result of the second store

    addi a0, x5, 0     # a0 = x5 (for checking)
