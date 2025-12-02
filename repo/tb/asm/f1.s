.text
.globl main

# REGISTERS
# t1 -> light pattern counter
# t2 -> saved RNG seed
# t3 -> max light pattern value
# t0 -> loop counters for delays
# t4 -> temporary for RNG calculations
# a0 -> output to lights

# SUBROUTINES
# fixed_delay -> consistent delay for each light step
# random_delay -> pseudo-random delay using a simple LFSR

# Lights turn on from right to left until all 8 are on after random delay

# f1 starting light sequence

main:
    li t1, 0                    # initialise light pattern counter to 0
    li t2, 0x12345678           # seed for random delay generator
    li a0, 0                    # output register initialised to 0

# main light loop

light_loop:
    slli t1, t1, 1              # shift light pattern left by 1
    ori  t1, t1, 1              # set LSB to 1 (lights accumulate)

    addi a0, t1, 0              # update output register with current light pattern

    jal  ra, fixed_delay        # call fixed delay subroutine

    li t3, 0xFF                 # maximum light pattern (all 8 lights on)
    bne t1, t3, light_loop      # repeat loop until all lights are on

# random delay sequence
# runs a pseudo-random delay, updates the seed and turns off LEDs

    addi t1, t2, 0              # copy RNG seed into t1
    jal ra, random_delay        # call random delay subroutine
    addi t2, t1, 0              # update RNG seed

    li a0, 0                    # turn off lights before next sequence

# fixed delay subroutine
# runs a simple countdown, spaces out LED activations

fixed_delay:
    li t0, 50000                # set fixed countdown
fixed_loop:
    addi t0, t0, -1             # decrement counter
    bne t0, zero, fixed_loop    # loop until t0 = 0
    jalr x0, ra, 0              # return to caller

# random delay subroutine -> implements LFSR
# uses the lowest 10 bits for delay, xorshift random generator
random_delay:
    slli t4, t1, 7              # shift t1 left 7 bits
    xor  t1, t1, t4             # XOR to mix bits
    srli t4, t1, 9              # shift t1 right 9 bits
    xor  t1, t1, t4             # XOR to mix bits
    slli t4, t1, 8              # shift t1 left 8 bits
    xor  t1, t1, t4             # XOR to mix bits

    andi t0, t1, 0x3FF          # limit random delay to 10 bits (0-1023)

# random countdown loop
# wait a random number of cycles (0-1023)

random_loop:
    addi t0, t0, -1             # countdown random delay
    bne  t0, zero, random_loop  # loop until t0 = 0

    jalr x0, ra, 0              # return to caller
