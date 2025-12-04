main:
    addi t0, zero, 354    # t0=354
    addi t1, zero, 256    # t1=256 (base address)
    sw t0, 0(t1)          # Store 354 into mem[256] - RAW hazard to memory: mem[256] now depends on t0
    lw a0, 0(t1)          # Load from the SAME address mem[256] - Load-use hazard: lw immediately uses the value written by the previous store
                          # a0 = 354
