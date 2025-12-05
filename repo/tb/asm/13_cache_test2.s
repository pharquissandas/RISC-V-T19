main:
    li    t0, 0x80000000     # Base address 0x80000000
    li    t1, 0x80001000     # Another address, different cache block
    li    t2, 0x12345678
    li    t3, 0x87654321
    sw    t2, 0(t0)          # mem[t0] = t2
    sw    t3, 0(t1)          #,
    lw    a0, 0(t0)          # Load word from 0x80000000 (first access, cache miss)
    lw    a0, 0(t1)          # Load from a new block at 0x80001000 (different cache block, so miss)
    