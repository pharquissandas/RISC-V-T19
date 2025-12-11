Name: Preet Harquissandas \
CID: 02589338 \
GitHub username: pharquissandas

---

## Table of Contents
* [Summary](#summary)
* [Contributions](#contributions)
    * [Reduced RISC-V CPU (Lab 4)](#reduced-risc-v-cpu-lab-4)
    * [Single-Cycle RV32I Design](#single-cycle-rv32i-design)
    * [Pipelined RV32I Design](#pipelined-risc-v-cpu)
    * [Full RV32I Design & Test Suite](#full-rv32i-design--test-suite)
    * [Other Extensions](#other-extensions)
* [Conclusion](#conclusion)
* [Self-Reflection](#self-reflection)

---

## Summary
I was deeply involved in nearly every phase of our design, from the foundational Lab 4 and single-cycle architectures through to the final pipelining stage. My core contributions included significant work on the **Control Unit**, **Instruction Memory**, and the **top-level file** for both single-cycle and pipelined designs. I ensured the robustness of the entire system by implementing most of the **testbenches** and adding critical features, such as the **Branch Predictor**.

As the **repository master**, my responsibility was managing our Git repository, handling all merging and branching, resolving conflicts, and setting up the repository structure.

---

## Contributions

### Reduced RISC-V CPU (Lab 4)

For the initial reduced RISC-V CPU design, I delegated parts of the work and personally focused on implementing core data-path components: 

* **Control Unit:** Designed the combinational logic for **Opcode Decoding** and the generation of all necessary control signals (e.g., `RegWrite`, `ALUsrc`, `PCsrc`). 
    * Commit: [`1fa77a0`](https://github.com/pharquissandas/RISC-V-T19/commit/1fa77a0fecea4949b321e9a90991a9beef985d96)
* **Instruction Memory:** Implemented the component to handle **Address Mapping** and correctly fetch a **32-bit instruction** using the Program Counter value.
    * Commit: [`ead1aaa`](https://github.com/pharquissandas/RISC-V-T19/commit/ead1aaad1bf962329ddfa14dffb50cd69831e4c8)
* **Sign Extend Unit:** Implemented logic to correctly convert a shorter-width immediate field into a full **32-bit value** (`ImmOp`), ensuring **sign preservation**.
    * Commit: [`fa70067`](https://github.com/pharquissandas/RISC-V-T19/commit/fa70067a8bb9b5d0cb9897bae69a39b1cbf83850)

---

### Single-Cycle RV32I Design

Mikhail and I strategically incorporated the **full RV32I instruction set** early to ensure consistency and prevent later architectural changes. This required refactoring core modules, which was a joint effort to integrate our work. 

#### Core Module Refactors (with Mikhail)
* **ALU (refactor):**
    * Increased the `ALUControl` signal width from 3 bits to **4 bits** to accommodate up to 16 unique operations (e.g., XOR shifts, SLTU, LUI).
    * Added logic for all missing operations (XOR, SLTU, SLL, SRL, SRA, LUI).
    * Commit: [`24ef564`](https://github.pharquissandas/RISC-V-T19/commit/24ef56489af87d1d3de3a645ac508def9d05a538)
* **Control Unit (refactor):**
    * Architectural upgrade to support the **entire RV32I base integer instruction set** (R, I, S, B, J, U-type instructions).
    * Introduced **hierarchical decoding** using `funct3` and `funct7` fields in addition to the opcode.
    * Commit: [`cf6d7b6`](https://github.pharquissandas/RISC-V-T19/commit/cf6d7b6df7c5a62373bf16329480c28ed68ac781)

---

### Pipelined RISC-V CPU

Ojas and I took on converting the single-cycle design into a fully working **5-stage pipelined version** while the rest of the team worked on the cached design.

#### Pipeline Registers
I created and implemented the four essential inter-stage pipeline registers to isolate the pipeline stages.

| Register Module | Stages | Key Data Transferred | Primary Function |
| :--- | :--- | :--- | :--- |
| `fetch_to_decode_register` | **F $\rightarrow$ D** | `PCF`, `PCPlus4F`, `InstrF` | Passes fetched instruction and PC values. |
| `decode_to_execute_register` | **D $\rightarrow$ E** | All Control Signals, `RD1D`, `RD2D`, `ImmExtD`, `RdD` | Transfers controls, register operands, and immediate data. |
| `execute_to_memory_register` | **E $\rightarrow$ M** | Subset of Control Signals, `ALUResultE`, `WriteDataE`, `RdE` | Passes ALU results and memory write data. |
| `memory_to_writeback_register` | **M $\rightarrow$ W** | Final Control Signals, `ALUResultM`, `ReadDataM`, `RdM` | Passes final result data source to the Writeback stage. |

Commit: [`7a3a2b6`](https://github.pharquissandas/RISC-V-T19/commit/7a3a2b6601475e6710e0844bdd1ed90d58ff3bb7)

#### Pipeline Stages
I implemented the core logic for the **Fetch**, **Decode**, **Execute**, **Memory**, and **Writeback** stages. 

| Module | Stage | Components / Key Contribution |
| :--- | :--- | :--- |
| `fetch` | **F** | Handles **PC advancement** and receives the branch/jump target from the Execute stage via `PCSrcE`. |
| `decode` | **D** | Logic for instruction field extraction (`Rs1`, `Rs2`, `Rd`) and ensuring the register file receives the final write signals from the W stage. |
| `execute` | **E** | Implemented the **Forwarding Unit** logic to select the ALU operands (`SrcA`, `SrcB`) from forwarded data (M/W stages) or the D/E register. |
| `memory` | **M** | Logic to send the ALU result as the memory address and control read/write operations for the **Data Memory**. |
| `writeback` | **W** | Implemented the **multiplexer** that uses `ResultSrcW` to select the final write data (`ALUResultW`, `ReadDataW`, or `PCPlus4W`). |

Commit: [`0c0a794`](https://github.pharquissandas/RISC-V-T19/commit/0c0a794b5dd62a039284c356115b27157f86f33a)

#### Hazard Unit (Detection and Forwarding)
I implemented the dedicated `hazard_unit` module, the central control system for resolving pipeline hazards. 

* **Data Hazards:** Handled primarily through **data forwarding (bypassing)**, prioritizing the newest data from the E/M or M/W registers via `ForwardAE` and `ForwardBE` signals. 
* **Control Hazards:**
    * **Stalling (Load-Use):** Detects **Load-Use hazards** and inserts a **stall** (via `StallFetch`/`StallDecode`) by freezing the F/D register and forcing a **NOP** into the D/E register.
    * **Flushing (Control Flow):** Sets `FlushDecode` and `FlushExecute` high to cancel instructions in the pipeline upon confirmed branch/jump.
    * **Branch Prediction:** Integrated with the **Branch Predictor** (see **Other** section) to minimize misprediction penalties.

| Output Signal | Function | Use Case |
| :--- | :--- | :--- |
| `ForwardAE`, `ForwardBE` | Select ALU source operand for register A and B. | **Data Forwarding** |
| `StallDecode`, `StallFetch` | Pause the F/D register and PC update. | **Load-Use Stall** |
| `FlushDecode`, `FlushExecute` | Force pipeline register controls to NOP. | **Branch/Jump Flush** |

Commit: [`d8545ae`](https://github.pharquissandas/RISC-V-T19/commit/d8545ae6191c9ed7dccdad999f8e24b22bb13cc7)

---

### Full RV32I Design & Test Suite

I was responsible for developing the **comprehensive test suite** to ensure full instruction set coverage and proper pipeline functionality.

* **Module Refactoring:** Standardized signal naming and bit widths across all modules and managed the top-level integration.
* **Comprehensive RV32I Test Suite:** Designed and implemented tests to cover all execution paths, verifying the final **Register File** and **Data Memory** states.

**Key Test Categories:**
1.  **Arithmetic and Logic Tests:** Covered all R/I-Type instructions (`add`, `sub`, shifts, logic ops).
2.  **Load and Store Tests:** Verified correct memory access, sign, and zero extension for all I/S-Type instructions.
3.  **Control Flow Tests:** Covered all branch conditions and jump instructions.
4.  **Architectural Tests:** Included `lui`, `auipc`, and the crucial `unwritable_zero_reg.s` to verify architectural adherence.
5.  **Pipelined Stress Tests:** Targeted programs specifically designed to trigger and verify the **Forwarding** and **Stalling** logic.

Commit: [`87f5558`](https://github.pharquissandas/RISC-V-T19/commit/87f5558ab4c87ebf607a8d9488a662170c69f138)
Commit: [`354eebc`](https://github.pharquissandas/RISC-V-T19/commit/354eebc87c0115990f2d5e72130384fd24c12863)

---

### Other Extensions

#### Branch Predictor
I implemented a dedicated **Branch Predictor** module to reduce control hazard penalties. 

* **Architecture:** Uses a **Branch History Table (`BHT`)** of **64 entries**, indexed by **`PC[7:2]`**. Each entry stores a **2-bit saturating counter**. 
* **Prediction:** The branch is predicted as **Taken** if the counter's state is **Weakly Taken (`2'b10`)** or **Strongly Taken (`2'b11`)** (i.e., if the MSB is '1').
* **Training (2-bit Hysteresis):** The BHT is updated in the Execute stage. It implements **2-bit saturating counter** behavior: the counter increments on a **Taken** outcome (saturates at `2'b11`) and decrements on a **Not Taken** outcome (saturates at `2'b00`). This hysteresis makes the prediction robust against transient misdirections.
* **Initialization:** All `BHT` entries are initialized to **`2'b00`** (**Strongly Not Taken**).

Commit: [`4d905bf`](https://github.pharquissandas/RISC-V-T19/commit/4d905bf1a7b7df67e2af1f3848eca083f2420d1a)
Commit: [`9b6736b`](https://github.pharquissandas/RISC-V-T19/commit/9b6736b42c9688ee06331edf854b2978da6e9128)

#### F1 Program (Code Change Analysis)
I redesigned the `F1` light sequence assembly code to create a more **concise and modular structure**, focusing on simplifying the delay and random number generation mechanisms.

| Feature | Old Approach | **New Approach (My Redesign)** |
| :--- | :--- | :--- |
| **Delay** | Separate `fixed_delay` and `random_delay` routines. | **Single `delay` subroutine** using `t2` for loop count. |
| **RNG** | Complex 32-bit XORshift RNG. | **Simplified `lfsr` subroutine** implementing a basic LFSR structure. |
| **RNG Output Range** | Masked for a 10-bit range (up to 1023 cycles). | **Masked for a 5-bit range** (up to **31 cycles**), drastically reducing wait time. |
| **Assembly Style** | Explicit instructions and checks. | Cleaner **`call`**, **`ret`**, and **`mv`** pseudo-instructions. |

Commit: [`29ac71d`](https://github.pharquissandas/RISC-V-T19/commit/29ac71dd589a8ba72cc016a3ff94712bff057245)

#### Vbuddy
I implemented the logic to interface with the Vbuddy for visual feedback, displaying the F1 lights sequence and, crucially, enabling the **verification of the PDF calculation** through visual plotting.

* **F1 Sequence Integration:** This involved the initial integration and a subsequent redesign of the `F1` light sequence assembly code to ensure successful execution and visualization on the designed hardware.
* **PDF Verification and Debugging (Achieved Today):** The most significant Vbuddy-related challenge was correctly visualizing the **PDF calculation** (`pdf.s`) output. This required extensive debugging and optimization of the simulation environment:

| Debug Area | Problem Identified | Solution Implemented | Impact on Verification |
| :--- | :--- | :--- | :--- |
| **Data Memory Loading** | **Initial Bug:** The `data_mem` module was loading input data (e.g., `gaussian.mem`) starting at address $0\text{x00000000}$ instead of the required base address $0\text{x00010000}$. | Updated the `$readmemh` Verilog directive to include the **base address offset** (`32'h00010000`). | Enabled the CPU to correctly read the input samples, resolving the issue of the output being a constant straight line (zero). |
| **Testbench Visualization** | The initial C++ testbench (`pdf_tb.cpp`) used a line plot (`vbdSetMode(0)`) and a fixed termination after 256 cycles, leading to a poor, jumpy visual and premature exit. | 1. **Switched to Bar Graph Mode** (`vbdSetMode(1)`) for clear histogram representation. 2. **Optimized Plotting Logic** to only plot when `a0` changed, ensuring 256 distinct, stable bin values were plotted. 3. **Removed termination logic** to allow the final graph to persist on the display until user input. | **Maximized visual clarity** for all distribution types (Gaussian, Noisy, Sine, Triangle) and ensured the entire output was fully captured. |
| **Dynamic Testing** | The plot scale was fixed, causing short distributions (like the *Triangle* wave's PDF) to look compressed. | Implemented logic to **dynamically adjust the Vbuddy Y-axis maximum** based on the input file name (e.g., a tighter range for *Triangle* and *Sine* files). | Ensured the resulting PDF curve appeared visually prominent and accurate for *all* test cases. |

* **Testing Procedure:** The Vbuddy was critical for final verification. The testing procedure used to confirm the PDF functionality was:
    1. `make reference` (to assemble `pdf.s`).
    2. `chmod +x attach_usb.sh` followed by `attach_usb.sh` (to connect to Vbuddy).
    3. `./pdf.sh reference/gaussian.mem` (and subsequently all other data files: `noisy.mem`, `sine.mem`, `triangle.mem`).

* More detailed explanation about the Vbuddy and the PDF program will be in `tb/reference/README.md`

* Commit: [`66936ba`](https://github.com/pharquissandas/RISC-V-T19/commit/66936ba3a238b9ef7c3b519abf49e65084b04c6a)

---

## Conclusion
The overall assembly of the RISC-V CPU demonstrates a robust and efficient implementation of a 5-stage pipelined processor. By successfully integrating critical components—including the Hazard Unit for data and control hazard resolution, a 2-bit saturating Branch Predictor, and fully decoded RV32I instruction support—the design achieves both correctness (verified through extensive testbenches) and performance (by maximising pipeline throughput). The modularity and scalability of the design ensure that it can be adapted for more complex architectures or instruction sets in the future. It was great fun working on this project; I learned so much and loved it!

---

## Self-Reflection
Before this project, apart from the structured Labs, I had no practical experience in hardware description languages or practical testing methodologies. I had only gained an insight into basic pipelining and computer architecture through GCSE Computer Science, and so this project has helped to consolidate and learn a lot more new information.

The process wasn't perfect—far from it—and I've made my fair share of mistakes along the way. Here is a non-exhaustive list containing some of them, and what could have been done better:

* Repo Management (Git): Although we weren't severely affected by merging issues, we could have made better use of feature branches to cleanly isolate major architectural changes (like moving from single-cycle to pipelined). This would have allowed us to keep a clean, tagged log of the single-cycle CPU in a separate branch, which we ended up resorting to by the end.
* Task Allocation: As the repo-master, I should have been more strict on people in completing work by a certain deadline, so we could have had a smoother process. Consequently, I feel like the workload was not always equal, and so some members ended up doing less than others, and due to timing pressures, some members ended up contributing less to the project.
