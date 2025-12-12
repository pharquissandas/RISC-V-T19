# Superscalar RISC-V CPU with Two Parallel Pipelines (RV32I Subset)

This repository contains the SystemVerilog implementation of a **32-bit RISC-V CPU** core with a **superscalar architecture**. The design supports a subset of the standard RV32I instruction set and incorporates logic for handling **data hazards** and **control hazards**.

---

## Project Contributors

This design was completed by modifying the Pipelined RISC-V CPU found in the pipeline branch of this repository. Ojas was wholly responsible for these modifications and the design of a superscalar architecture.

---

## Superscalar Architecture Overview

The CPU has two parallel pipelines each with five pipeline stages: Fetch, Decode, Execute, Memory and Writeback. Having two parallel pipelines means the processor can execute up to two instructions per cycle.
However, the CPU does not always execute two instructions per cycle due to the existence of jump and branch instructions and due to dependencies between the two parallel pipelines. See section 3 for more detail.



---

## Module Descriptions (Superscalar)

### 1. Core Functional Units
| Module | Description | Key Functionality |
| :--- | :--- | :--- |
| **`alu.sv`** | Arithmetic Logic Unit | Performs 32-bit arithmetic, logic, and comparison operations based on `ALUControl`. Also handles the `LUI` operation. Two ALUs are required one for each pipeline.|
| **`data_mem.sv`** | Synchronous Data Memory | Handles synchronous read/write operations for **Load** (LB, LH, LW, LBU, LHU) and **Store** (SB, SH, SW) instructions, including sign/zero extension and byte addressing. Handles two write operations and two read operations at a time |
| **`reg_file.sv`** | Register File | 6 Port register file, with 4 read ports and 2 write ports. Stores 32 general-purpose registers. Supports asynchronous reads and synchronous writes on the negative clock edge. Register **X0 is hardwired to zero**. |
| **`instr_mem.sv`** | Instruction Memory (ROM) | Combinational memory unit that fetches instructions based on the PC address. Has two address inputs and two outputs so that two instructions can be fetched per cycle.|
| **`sign_ext.sv`** | Sign Extend | Extends the immediate field of various instruction types (I, S, B, J, U) to a full 32-bit signed value. Two of these are required one for each pipeline |
| **`pc.sv`** | Program Counter (PC) | Synchronous register that holds the current instruction address and calculates the next PC based on branching logic (`PCSrcE`). |
| **`pcsrc_unit.sv`** | PC Source Unit | Combinational logic that determines the appropriate next PC source (PC+4, PC+8, Branch Target, or JALR Target) based on branch type, `Jump` signal, and ALU `Zero` flag. |
| **`control.sv`** | Control Unit | (Implied/Called in `decode.sv`) Decodes the instruction to generate all necessary control signals for the datapath and pipeline registers. Two control units are required, one for each pipeline stage. |
| **`writeback.sv`** | Result Mux | Selects the final result data (`ALUResultW`, `ReadDataW`, or `PCPlus4W`) to be written back to the Register File. The architecture contains two result muxes, one for each pipeline stage. |

### 2. Pipeline Registers
These modules are synchronous registers used to pass control and data signals between adjacent pipeline stages. Each pipeline register module has two reset and enable inputs, resulting in each module encompassing two registers (one for each pipeline). The reset and enable inputs are used to implement stalls and flushes to deal with different hazards and dependencies.
* **`fetch_to_decode_register` (F2D)**: Passes PC, PC+4 and Instruction (`InstrF`) from F to D.
* **`decode_to_execute_register` (D2E)**: Passes register data (`RD1D`, `RD2D` or `RD4D`, `RD5D`), immediate, PC, and control signals from D to E. Includes reset/flush logic (`FlushExecute`) for control hazards.
* **`execute_to_memory_register` (E2M)**: Passes ALU result, write data (`WriteDataE`), and control signals from E to M.
* **`memory_to_writeback_register` (M2W)**: Passes ALU result, read data, PC+4, and control signals from M to W.

### 3. Hazard Control
| Module | Description | Functionality |
| :--- | :--- | :--- |
| **`hazard_unit.sv`** | Central Hazard Detection | Detects data hazards (between E, M, and W stages across both pipelines) to generate forwarding signals (`ForwardAE1`, `ForwardBE1`,`ForwardAE2`, `ForwardBE2`). Detects load-use hazards (D depends on M/W) to generate stall signals. Detects control hazards (branches/jumps) to generate flush signals. Detects multiple jump/branch hazardsand generates appropriate stall and flush signals. |
| **`execute.sv`** | Execution Logic | Contains the forwarding muxes to select the correct operand data (`SrcA1`, `SrcB1`,`SrcA2`, `SrcB2`) from the register file output, the M-stage ALU result, or the W-stage result/read data. Forwarding can occur across pipeline stages, for example the result in the memory stage of pipeline 2 can be fowarded to the execute stage of pipeline 1 |

---

## Hazard Handling Strategy

### 1. Data Hazards (Register Dependencies)
* **Forwarding:** The `hazard_unit` detects if an instruction in the E or M stage in either pipeline is writing to a register that the current E-stage instruction in either pipeline is reading.
    | ForwardAE1/ForwardBE1/ForwardAE2/ForwardBE2 value | Description |
        * `2'b00`: Register File (no hazard)
        * `2'b10`: ALU result from **Memory stage** (`ALUResultM`)
        * `2'b01`: Result from **Writeback stage** (`ResultW`)

| ForwardAE1/ForwardBE1/ForwardAE2/ForwardBE2 | Description |
| :--- | :--- |
| **`3'b000`** | No Forwarding |
| **`3'b001`** | Forwarding from result in writeback stage in pipeline 1 | 
| **`3'b010`** | Fowarding from ALU result in memory stage in pipeline 1 |
| **`3'b011`** | Forwarding from result in writeback stage in pipeline 2 | 
| **`3'b100`** | Fowarding from ALU result in memory stage in pipeline 2 |

In the hazard unit, it is necessary to first check if a result should be forwarded from the memory stage in eithe pipeline and only if there is no result that should be forwarded from the memory stages should the writeback stages be checked.

### 2. Load-Use Hazards (Data Hazard requiring Stall)
* **Stall:** If the instruction in the Execute (E) stage is a Load instruction (`ResultSrcE == 2'b01`) and the instruction in the Decode (D) stage needs the result (`RdE == Rs1D` or `RdE == Rs2D`), the pipeline stalls for one cycle.
    * `StallDecode` and `StallFetch` are asserted, freezing the F and D stages and inserting a NOP (via `FlushExecute`) into the E stage, this occurs in both pipelines.

### 3. Control Hazards (Branches/Jumps)
* **Flushing:** If the `pcsrc_unit` determines a change in PC flow (`PCSrcE != 2'b00`) due to a branch or jump, the two subsequent instructions in the D and E stages of both pipelines are flushed (turned into NOPs) to ensure the correct instruction is fetched next.
    * `FlushDecode` and `FlushExecute` are asserted. If a branch is taken in pipeline 1 the memory stage of pipeline 2 should also be flushed, as this instruction should not have been executed and so the result should not pass to the memory or writeback stage either. This is not necessary the other way round as the instruction in pipeline 1 would have already executed had it been a scalar processor.
### 4. Dependencies and multiple branches/jumps between the pipelines
  * With the superscalar processor attempting to execute two instructions per cycle, not all dependencies can be solved with forwarding. When one pipeline has a source register which is the destination register in the other pipeline, a NOP must replace the instruction in the pipeline with the source register so that on the next cycle when the actual instruction executes, the required result can be forwarded.
  * Similarly in one cycle both pipelines could fetch a branch and/or a jump instruction. Or a branch instruction may be fetched which in a scalar processor would be fetched a cycle before the next instruction.

  | Instruction Pipeline 1| Instruction Pipeline 2 | Description |
  | :--- | :--- |  :--- | 
  | Branch | Branch | Execute the branch instruction with the lower program counter value, insert NOP in other pipeline and stall the program counter. |
  | Branch| Jump | Stall both program counters, execute the branch instruction in the next cycle but not the jump instruction |
  | Branch | Other | Execute both instructions in the next cycle assuming the branch is not taken, if it is taken then in the next cycle we flush decode and execute in pipeline 1 and 2 |
  | Jump | Other | Stall both program counters and flush decode in both pipelines |
  | Jump | Branch | Stall both program counters and flush decode and execute in pipeline stage 1 |
  | Other | Branch | Execute both instructions (if there are no dependencies) |
  | Other | Jump | If PCD2 < PCD1 of pipeline 2, stall program counters and flush decode in both pipelines. Flush execute in pipeline 1  |
  ---

## Memory Initialization

The following files are required for memory initialization:
* `program.hex`: Contains the machine code for the **Instruction Memory**.
* `data.hex`: Contains the initial contents of the **Data Memory**.

---

More information about individual contributions can be found in personal statements.

