main:
    addi x1, x0, 5    # x1=5=0101
    addi x2, x0, 10   # x2=10=1010
    add x3, x1, x2    # x3=x1+x2=1111 (RAW hazard on x1,x2) 
    sub x4, x3, x1    # x4=x3-x1=1010 (RAW hazard on x3)
    and x5, x4, x2    # x5=x4&x2=1010 (RAW hazard on x4,x2)
    or x6, x5, x3     # x6=x5|x3=1111 (RAW hazard on x5,x3)
    addi a0, x6, 1    # a0=x6+1 (RAW hazard on x6)

