.text
.globl main
main:
    li t1, 0
    li t2, 0x12345678
    li a0, 0

light_loop:
    slli t1, t1, 1
    ori t1, t1, 1

    addi a0, t1, 0

    jal  ra, fixed_delay

    li t3, 0xFF
    bne t1, t3, light_loop

    addi t1, t2, 0
    jal ra, random_delay
    addi t2, t1, 0

    li a0, 0

fixed_delay:
    li t0, 50000
fixed_loop:
    addi t0, t0, -1
    bne t0, zero, fixed_loop
    jalr x0, ra, 0

random_delay:
    slli t4, t1, 7
    xor  t1, t1, t4

    srli t4, t1, 9
    xor  t1, t1, t4

    slli t4, t1, 8
    xor  t1, t1, t4

    andi t0, t1, 0x3FF

random_loop:
    addi t0, t0, -1
    bne  t0, zero, random_loop

    jalr x0, ra, 0