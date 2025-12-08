.text
.globl main

main:
    li t3, 0b01010101       # Seed for LFSR
    li t1, 0b11111111       # Final state (0b11111111)
    li x2, 0x1000           # Store return address in x2
    li x3, 1                # Used in delay branch to exit
    # Enable interrupts and assign ISR

    la t6, isr
    csrrw x0, mtvec, t6     # Set mtvec to ISR address

    li t6, 1       # Enable interrupts (bit 11)
    slli t6, t6, 11
    csrrw x0, mie, t6

    li t6, 0x00000008        # Enable timer interrupt (bit 3)
    csrrw x0, mstatus, t6

main_loop:
    li t0, 0b00000000       # Initial light value (0b00000001)
    mv a0, t0
stage_loop:
    li t2, 9                # Approximate delay cycles for 1s
    call delay              # Wait 1 second

    slli t0, t0, 1          # Shift left and add another one in LSB
    ori t0, t0, 1

    mv a0, t0               # Set output
    bne t0, t1, stage_loop  # Not yet reached final state

    call lfsr               # Now all lights are on so call delay with random time before switching off
    call delay
    li t0, 0b00000000       # Switch off lights
    mv a0, t0
    li t2, 15               # Give the user time to react
    call delay
    j main_loop             # Reset

delay:                      # t2 is passed as a parameter
    addi t2, t2, -1         # Decrement t2
    blt x3, t2, delay
    ret

lfsr:
    srl t4, t3, 4
    srl t5, t3, 3
    xor t4, t4, t5

    andi t4, t4, 1          # Mask to get feedback bit
    slli t3, t3, 1
    or t3, t3, t4

    andi t2, t3, 0b11111    # Mask to 5 bits
    ret

isr:
    sw x1, 0(x2)           # Store return address in case interrupt occurs inside a subroutine
    # Flash the lights to indicate success and allow timing in testbench
    li a0, 0b11111111
    li t2, 2               # Delay time
    call delay
    li a0, 0b00000000
    li t2, 2               # Delay time, we have to load each time otherwise it goes negative and loop forever
    call delay
    li a0, 0b11111111
    li t2, 2               # Delay time
    call delay
    li a0, 0b00000000
    lw x1, 0(x2)
    # Don't need to store return address because the interrupt return address is stored in a CSR
    mret
