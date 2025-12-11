# 5-Stage Pipelined RISC-V CPU (RV32I Subset)

This repository contains the SystemVerilog implementation of a **32-bit RISC-V CPU** core utilizing a **5-stage pipeline** (Fetch, Decode, Execute, Memory, Writeback). The design supports a subset of the standard RV32I instruction set and incorporates logic for handling **data hazards (forwarding)** and **control hazards (stalling/flushing)**.

---

## Project Contributors

The project was completed in several phases, from an initial reduced single-cycle design to the final robust pipeline. The following table outlines the specific contributions from each team member across both the single-cycle and pipelined phases:

| Design Phase | Contributions | Preet | Mikhail | Ojas | Fangnan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Pipelined RV32I** | Pipeline Registers | X | | | |
| | Pipeline Stages | X | | | X |
| | Hazard Unit (Detection/Forwarding) | X | | | X |
| | Topfile/Implementation | X | X | | |

---

## Pipelined Architecture Overview

The CPU is structured around the five classic pipeline stages to maximize instruction throughput.



### Pipeline Stages
1.  **F (Fetch):** Reads the instruction from **Instruction Memory** and increments the **Program Counter (PC)**.
2.  **D (Decode):** Reads the **Register File**, decodes the instruction, calculates the immediate value (**Sign Extend**), and generates control signals (**Control Unit**).
3.  **E (Execute):** Performs arithmetic/logic operations (**ALU**), calculates memory addresses, and determines branch/jump targets (**pcsrc_unit**).
4.  **M (Memory):** Performs memory access (**Data Memory**) for load (`LW`, `LH`, `LB`) and store (`SW`, `SH`, `SB`) instructions.
5.  **W (Writeback):** Writes the final result back to the **Register File**.

---

## Module Descriptions (Pipelined)

### 1. Core Functional Units
| Module | Description | Key Functionality |
| :--- | :--- | :--- |
| **`alu.sv`** | Arithmetic Logic Unit | Performs 32-bit arithmetic, logic, and comparison operations based on `ALUControl`. Also handles the `LUI` operation. |
| **`data_mem.sv`** | Synchronous Data Memory | Handles synchronous read/write operations for **Load** (LB, LH, LW, LBU, LHU) and **Store** (SB, SH, SW) instructions, including sign/zero extension and byte addressing. |
| **`reg_file.sv`** | Register File | Stores 32 general-purpose registers. Supports asynchronous reads and synchronous writes on the negative clock edge. Register **X0 is hardwired to zero**. |
| **`instr_mem.sv`** | Instruction Memory (ROM) | Combinational memory unit that fetches instructions based on the PC address. |
| **`sign_ext.sv`** | Sign Extend | Extends the immediate field of various instruction types (I, S, B, J, U) to a full 32-bit signed value. |
| **`pc.sv`** | Program Counter (PC) | Synchronous register that holds the current instruction address and calculates the next PC based on branching logic (`PCSrcE`). |
| **`pcsrc_unit.sv`** | PC Source Unit | Combinational logic that determines the appropriate next PC source (PC+4, Branch Target, or JALR Target) based on branch type, `Jump` signal, and ALU `Zero` flag. |
| **`control.sv`** | Control Unit | (Implied/Called in `decode.sv`) Decodes the instruction to generate all necessary control signals for the datapath and pipeline registers. |
| **`writeback.sv`** | Result Mux | Selects the final result data (`ALUResultW`, `ReadDataW`, or `PCPlus4W`) to be written back to the Register File. |

### 2. Pipeline Registers
These modules are synchronous registers used to pass control and data signals between adjacent pipeline stages.
* **`fetch_to_decode_register` (F2D)**: Passes PC, PC+4, and Instruction (`InstrF`) from F to D.
* **`decode_to_execute_register` (D2E)**: Passes register data (`RD1D`, `RD2D`), immediate, PC, and control signals from D to E. Includes reset/flush logic (`FlushExecute`) for control hazards.
* **`execute_to_memory_register` (E2M)**: Passes ALU result, write data (`WriteDataE`), and control signals from E to M.
* **`memory_to_writeback_register` (M2W)**: Passes ALU result, read data, PC+4, and control signals from M to W.

### 3. Hazard Control
| Module | Description | Functionality |
| :--- | :--- | :--- |
| **`hazard_unit.sv`** | Central Hazard Detection | Detects **Data Hazards** (between E, M, and W stages) to generate **Forwarding Signals** (`ForwardAE`, `ForwardBE`). Detects **Load-Use Hazards** (D depends on M/W) to generate **Stall Signals** (`StallDecode`, `StallFetch`). Detects **Control Hazards** (branches/jumps) to generate **Flush Signals** (`FlushExecute`, `FlushDecode`). |
| **`execute.sv`** | Execution Logic | Contains the **forwarding muxes** to select the correct operand data (`SrcA`, `SrcB`) from the Register File output, the M-stage ALU result, or the W-stage result/read data. |

---

## Hazard Handling Strategy

### 1. Data Hazards (Register Dependencies)
* **Forwarding:** The `hazard_unit` detects if an instruction in the E or M stage is writing to a register that the current E-stage instruction is reading.
    * `ForwardAE`/`ForwardBE` selects:
        * `2'b00`: Register File (no hazard)
        * `2'b10`: ALU result from **Memory stage** (`ALUResultM`)
        * `2'b01`: Result from **Writeback stage** (`ResultW`)

### 2. Load-Use Hazards (Data Hazard requiring Stall)
* **Stall:** If the instruction in the **Execute (E)** stage is a **Load instruction** (`ResultSrcE == 2'b01`) and the instruction in the **Decode (D)** stage needs the result (`RdE == Rs1D` or `RdE == Rs2D`), the pipeline stalls for one cycle.
    * `StallDecode` and `StallFetch` are asserted, freezing the F and D stages and inserting a **NOP** (via `FlushExecute`) into the E stage.

### 3. Control Hazards (Branches/Jumps)
* **Flushing:** If the `pcsrc_unit` determines a change in PC flow (`PCSrcE != 2'b00`) due to a branch or jump, the two subsequent instructions in the D and E stages are flushed (turned into NOPs) to ensure the correct instruction is fetched next.
    * `FlushDecode` and `FlushExecute` are asserted.

---

## Memory Initialization

The following files are required for memory initialization:
* `program.hex`: Contains the machine code for the **Instruction Memory**.
* `data.hex`: Contains the initial contents of the **Data Memory**.

---

More information about individual contributions can be found in personal statements.
