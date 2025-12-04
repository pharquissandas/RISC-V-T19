main:
    addi x1, x0, 5          # x1=5
    addi x2, x0, 10         # x2=10
    sw x1, 0(x2)            # mem[x2]=x1=5

    lw x3, 0(x2)            # x3=mem[x2]=x1=5 (RAW hazard on x1)
    add x4, x3, x1          # x4=x3+x1=10 (RAW hazard on x3)
    sub x5, x4, x2          # x5=x4-x2=0 (RAW hazard on x4)
    and x6, x5, x3          # x6=x5&x3=0 (RAW hazard on x5, x3)

    lw x7, 0(x2)            # x7=mem[x2]=5
    or x8, x7, x6           # x8=x7|x6=5 (RAW hazard on x7, x6)

    addi a0, x8, 1          # a0=x8+1=6 (RAW hazard on x8)
