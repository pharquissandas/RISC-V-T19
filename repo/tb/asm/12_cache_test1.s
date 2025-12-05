main:
    li    t0, 0x80000000     # Base address in memory
    li    t1, 0x12345678     # t1 = 0x12345678
    sw    t1, 0(t0)          # mem[t0] = t1
    lw    a0, 0(t0)          # Load word from address 0x80000000 (first access, cache miss)
    lw    a1, 0(t0)          # Load from the same address (this should be a cache hit)
