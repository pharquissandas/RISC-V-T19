main:
    li s0, 0x10004
    li s1, 0x10804
    li s2, 0x11004
    
    li t0, 0xAA
    li t1, 0xBB

    sw t0, 0(s0)   # way 0 dirty
    sw t1, 0(s1)   # way 1 dirty

    lw t3, 0(s2)   # evicts way 0 : writes to ram
    lw a0, 0(s0)   # should be 0xAA
