main:
    addi t0, zero, 10     # t0=10
    add t1, t0, t0        # t1=t0+t0=20 - RAW hazard: t1 depends on t0
    sub t2, t1, t0        # t2=t1-t0=20-10=10 - RAW hazard: t2 depends on t1
    addi a0, t2, 20       # a0=t2+20=30 - RAW hazard: a0 depends on t2
