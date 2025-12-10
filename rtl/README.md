# 32-bit Single-Cycle RISC-V CPU (RV32I Subset)

This repository contains the SystemVerilog implementation of a **32-bit RISC-V CPU** core based on a **single-cycle architecture**. The project evolved from an initial reduced implementation to a more complete design supporting a significant subset of the RV32I instruction set.

---

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
| **Single-Cycle RV32I** | ALU (refactor) | X | X | | |
| | Control Path | | | X | |
| | Control Unit (refactor) | X | X | | |
| | Data Memory | | X | | |
| | Data Path | | | | X |
| | Instruction Memory (refactor) | | X | | |
| | Program Counter (refactor) | | | | X |
| | PCSRC Unit | | | | X |
| | Register File (refactor) | | | X | |
| | Sign Extend (refactor) | | X | | |
| | Topfile/Implementation | X | X | | |

---

## Architecture Overview

The CPU uses a **single-cycle datapath** where every instruction completes in one clock cycle. The design is modular, separating the **Datapath** components (e.g., PC, ALU, Memories, Register File) and the **Control Unit** logic.

---

## Module Descriptions

The core logic is implemented in the following SystemVerilog modules:

### 1. `top.sv`
The **Top-Level Module** integrates the entire system, connecting the **Datapath** (`data_path`) and the **Control Unit** (`control_path`). It handles global signals like the clock (`clk`) and reset (`rst`).

### 2. `data_path.sv`
The **Datapath Module** instantiates all the functional blocks of the CPU and manages the data flow, using control signals to select operands and results. It outputs the instruction (`Instr`) and the zero flag (`Zero`) to the control logic.

### 3. `control_path.sv`
This structural module connects the Instruction output (`Instr`) to the decoding logic in **`control.sv`** and the next-PC determination logic in **`pcsrc_unit.sv`**.

### 4. `control.sv`
The **Control Unit** decodes the instruction fields (`opcode`, `funct3`, `funct7`) and generates all necessary control signals (`RegWrite`, `MemWrite`, `ALUControl`, `ResultSrc`, etc.) to drive the datapath.

### 5. `pcsrc_unit.sv`
The **PC Source Unit** is responsible for determining the next Program Counter value (`PCSrc`). It uses the `Jump`, `Branch` signals, and the ALU's `Zero` flag (for conditional branches) to select between PC+4, PC + Immediate, or ALUResult (for JALR).

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

### 10. `data_mem.sv`
The **Data Memory** is a synchronous RAM for load and store operations, supporting byte, half-word, and word access, initialized from `data.hex`.

### 11. `sign_ext.sv`
The **Sign Extend** module correctly expands the instruction's immediate field to 32 bits based on the instruction type (I, S, B, J, U).

---

More information about individual contributions can be found in personal statements.
