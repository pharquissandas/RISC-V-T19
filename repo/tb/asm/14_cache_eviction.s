main:              # tttt_tttt_tttt_tttt_tttt_tsss_ssss_ssoo
    li s0, 0x10004 # 0000_0000_0000_0001_0000_0000_0000_0100 tag1 set1
    li s1, 0x10804 # 0000_0000_0000_0001_0000_1000_0000_0100 tag2 set1
    li s2, 0x11004 # 0000_0000_0000_0001_0001_0000_0000_0100 tag3 set1

    li t0, 0xAA
    li t1, 0xBB
    li t2, 0xCC

    sw t0, 0(s0) # mem[s0] = t0
    sw t1, 0(s1) # mem[s1] = t1
    sw t2, 0(s2) # mem[s2] = t2 : evict way 0

    lw a0, 0(s0) # miss, should be 0xAA
