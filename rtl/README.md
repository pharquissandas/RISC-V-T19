# 32-bit Single-Cycle RISC-V CPU (RV32I — Stretch Goal 3 Level)

This branch contains the SystemVerilog implementation of our single-cycle RV32I processor, built on top of the Lab 4 reduced RISC-V CPU and extended into a complete architectural design.
The core supports **all RV32I base instructions**, excluding only FENCE, ECALL/EBREAK, and CSR instructions—meeting the specification of **Stretch Goal 3: Full RV32I Design**.
This extended instruction coverage was completed before constructing the pipelined CPU, and provided a stable, fully verified baseline for the later stages of the project.

## Project Contributors

The project was completed in two phases: the **Reduced RISC-V CPU** and the expanded **Single-Cycle RV32I** implementation. The following table outlines the specific contributions from each team member across both phases:

| Design Phase | Contributions | Preet | Mikhail | Ojas | Fangnan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Reduced RISC-V CPU** | Program Counter | | X | | |
| | ALU | | | X | |
| | Register File | | | X | |
| | Instruction Memory | X | | | |
| | Control Unit | X | | | |
| | Sign Extend | X | | | |
| | Testbench | | | | X |
| | Topfile/Implementation | | X | | X |
| **Single-Cycle RV32I** | ALU (refactor) | X | X | | X |
| | Control Path | | | X | X |
| | Control Unit (refactor) | X | X | | X |
| | Data Memory | | X | | X |
| | Data Path | | | | X |
| | Instruction Memory (refactor) | | X | | |
| | Program Counter (refactor) | | | | X |
| | PCSRC Unit | | | | X |
| | Register File (refactor) | | | X | |
| | Sign Extend (refactor) | | X | | X |
| | Topfile/Implementation | X | X | | X |


## Architecture Overview

The CPU adopts a single-cycle microarchitecture, with each instruction executing in one clock cycle. The implementation follows a clean modular structure, with a clearly defined **Data Path** (PC, ALU, memories, register file, sign-extension, multiplexers) and a dedicated **Control Path** responsible for decoding instructions and generating all control signals.

## Module Descriptions

The core logic is implemented in the following SystemVerilog modules:

### 1. `top.sv`
  The top-level module instantiates and connects the Control Path and Data Path. It carries only global signals (clk, rst) and the internal control/data signals exchanged between the two subsystems. Its purpose is purely structural, keeping the architecture clean and readable.

### 2. `data_path.sv`
The **Datapath Module** instantiates all the functional blocks (`pc.sc`, `alu.sv`, `reg_file.sv`, `instr_mem.sv`, `data_mem.sv`, `sign_ext.sv`) of the CPU and manages the data flow, using control signals to select operands and produce results. It outputs the instruction (`Instr`) and the zero flag (`Zero`) to the control logic.

### 3. `control_path.sv`
A structural wrapper that routes the instruction (`Instr`) and ALU status (`Zero`) into: the unified decoder (`control.sv`), and the next-PC selection logic (`pcsrc_unit.sv`). This separation avoids cross-module coupling and keeps the control logic clean and pipeline-ready.

### 4. `control.sv`
Unified instruction decoder combining main-decoder and ALU-decoder functionality to minimise redundancy and avoid rewrite issue between two sub-modules. Generates all control signals (`RegWrite`, `MemWrite`, `ALUControl`, `ResultSrc`, etc.) by decoding (`Instr`) to drive the datapath.

### 5. `pcsrc_unit.sv`
The **PC Source Unit** is responsible for determining the next Program Counter value by generating (`PCSrc`). It uses the `Jump`, `Branch` signals, and the ALU's `Zero` flag (for conditional branches) to select between PC+4, PC + Immediate, or ALUResult (for JALR).

### 6. `pc.sv`
The **Program Counter (PC)** is the register holding the address of the current instruction. It updates synchronously on the clock edge based on the next address selected by `PCSrc`.

### 7. `alu.sv`
The **Arithmetic Logic Unit (ALU)** performs the core 32-bit arithmetic and logic operations defined by the `ALUControl` signal.

| ALUControl | Operation |
| :---: | :--- |
| `4'b0000` | ADD |
| `4'b0001` | SUB |
| `4'b0010` | AND |
| `4'b0011` | OR |
| `4'b0100` | XOR |
| `4'b0101` | SLL |
| `4'b0110` | SRL |
| `4'b0111` | SRA |
| `4'b1000` | SLT (signed) |
| `4'b1001` | SLTU (unsigned) |
| `4'b1111` | LUI |

### 8. `reg_file.sv`
The **Register File** implements the 32 general-purpose registers, supporting two asynchronous reads and one synchronous write.

### 9. `instr_mem.sv`
The **Instruction Memory** is a ROM that stores the program, initialized from `program.hex`.

### 10. `data_mem.sv`3
The byte-addressed **Data Memory** is a synchronous RAM for load and store operations, supporting byte, half-word, and word access, initialized from `data.hex`.

### 11. `sign_ext.sv`
The **Sign Extend** module correctly expands the instruction's immediate field to 32 bits based on the instruction type (I, S, B, J, U).

---

More information about individual contributions can be found in personal statements.
