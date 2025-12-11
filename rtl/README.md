# FPGA Implementation (DE10-Lite)

This directory contains the synthesis-ready SystemVerilog implementation of our Pipelined RISC-V CPU with Cache and Branch Prediction,
ported specifically for the Terasic DE10-Lite FPGA board (Intel MAX 10). This implementation bridges the gap between simulation and physical hardware,
adapting memory structures and clocking domains to meet real-world synthesis constraints.

---
## Project Contributors
The FPGA implementation was the final stage of the project (for the non superscalar design), focusing on physical synthesis and hardware verification. The following table outlines the specific contributions for this phase:

| Design Phase | Contributions | Preet | Mikhail | Ojas | Fangnan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FPGA Synthesis** | Top level Implementation | | X | | |
| | Mapping output to FPGA display and LEDs | | X | | |
| | IP Core Integration (RAM / ROM) | | X | | |
| | Validation | | X | | |

---

## Hardware Architecture & Modifications

To transition from simulation to physical hardware, significant architectural changes were required to adapt to the MAX 10 FPGA's resources and timing constraints.

### I/O Mapping & Top-level file ###
  - A new top-level wrapper, de10_lite_top.sv, was created to interface the CPU with the boards 7-segment displays and LEDs.
  - A display.sv module was created to decode the 32-bit output value into hexadecimal for the 7-segment displays.
  - The onboard 50MHz clock was too fast for visual debugging, so a clock divider was implemented to slow the execution speed to human-visible levels

### Memory IP Cores ###
The simulation arrays for instruction and data memory were replaced to make use of the FPGAs onboard memory. This was done by using the Quartus IP Cores:
- Instruction Memory: `rom_ip`, A single-port ROM was created and was initialised with the program in a `.mif` file format.
- Data Memory: `ram_ip`, A single-port RAM was created and used by the Data Cache for eviction and refill operations.

### Cache Optimisation ###
The original 2-way Set Associative Cache (4KB capacity) required excessive logic elements because the asynchronous read logic prevented Quartus from inferring Block RAM.
To fit the design within the DE10-Lite's 50K logic elements, the cache was parameterized and resized:
- Sets: Reduced from 512 to 64.
- Total Capacity: 512 Bytes.
- Associativity: Remains 2-way. This optimisation allowed the complex cache logic to synthesise successfully without altering the core microarchitecture.

---
## How to Run
Follow these steps to synthesise and program the FPGA:
1. Open Quartus Prime and create a valid repository.
2. Connect your DE10-Lite, and select it in the programmer menu (ensure you have the correct packages such as USB Blaster).
3. Select the 10M50DAF484C7G chip in the device assignments.
4. Create SystemVerilog files for each module in the `fpga` branch. Ensure that de_10_lite.sv is set as the top for the heirarchy.
5. Create an assembly program and convert it to a `.mif` file.
6. In the IP Catalog Library, create a 1-Port ROM (32 bits, 4096 words, no q output port, select your `.mif` file for initialisation).
7. Likewise create a 1-Port RAM (32 bits, 4096 words).
8. Import a pin assignment file for the DE10-Lite.
9. Compile and run.

Operation:
- Reset: Press KEY[0] to reset the CPU.
- Output: Observe the a0 register value changing in real-time on the HEX displays and LEDs.

---
## Verified Test Programs ##
Two primary programs were used to validate physical hardware correctness:
- Counter: An infinite loop incrementing a0, displayed on the 7-segment displays.
- LED Strip: A shift-register program moving a single lit LED across the LEDR array from left to right.

---

More detail about challenges and design decisions can be found in personal statements.
