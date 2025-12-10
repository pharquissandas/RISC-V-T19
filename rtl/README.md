# Pipelined RISC-V CPU with Cache and Branch Prediction

This repository hosts the SystemVerilog implementation of a highly optimized **32-bit RISC-V CPU** core. The design features a **5-stage pipeline (F-D-E-M-W)** enhanced with a **2-way Set Associative Data Cache** and a **2-bit Saturating Branch History Table (BHT)** for improved performance and reduced latency.

---

## Detailed Project Contributions

The project evolved through several phases, from an initial reduced design to the final robust, cached, and pipelined core. The table below provides a comprehensive breakdown of contributions across the team.

| Design Phase | Contributions | Preet | Mikhail | Ojas | Fangnan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Single-Cycle RV32I** | ALU (refactor) | X | X | | |
| | Control Path | | | X | |
| | Control Unit (refactor) | X | X | | |
| | Data Memory | | X | | X |
| | Data Path | | | | X |
| | Instruction Memory (refactor) | | X | | |
| | Program Counter (refactor) | | | | X |
| | PCSRC Unit | | | | X |
| | Register File (refactor) | | | X | |
| | Sign Extend (refactor) | | X | | |
| | Topfile/implementation | X | X | | |
| **Pipelined RV32I** | Pipeline Registers | X | | | |
| | Pipeline Stages | X | | | X |
| | Hazard Unit (Detection/Forwarding) | X | | | X |
| **Data Memory Cache** | Memory (refactor) | | X | | |
| | Direct mapped cache | | X | | |
| | Two-way set associative cache | | X | | |
| **Full RV32I Design** | Testbenches | X | X | | |
| | Module Refactoring | X | X | | X |

---

## Architectural Features

| Feature | Details | Benefit |
| :--- | :--- | :--- |
| **Pipelined Core** | Classic 5-stage structure (IF, ID, EX, MEM, WB).  | Maximizes Instruction Level Parallelism (ILP). |
| **Data Hazard Control** | Full **Forwarding** from E, M, and W stages. | Reduces load/store/ALU instruction latency. |
| **Control Hazard Control** | **Branch Prediction (BHT)**, **Mispredict Flush**, and **Stalling** (for Load-Use). | Minimizes branch penalty and ensures correctness. |
| **Data Cache** | **4KB** 2-way Set-Associative, Write-Back/Allocate. | Significantly reduces average memory access time. |
| **Branch Predictor** | 64-entry, 2-bit Saturating Counter Branch History Table (BHT). | Predicts conditional branches to mitigate pipeline flushes. |

---

## Source Code Module Breakdown

The design is organized into functional units corresponding to the pipeline stages and advanced subsystems.

### 1. Pipelined Core & Control
| Module | Stage/Purpose | Description |
| :--- | :--- | :--- |
| **`top.sv`** | Top-Level | Instantiates all pipeline stages, registers, the Hazard Unit, and the Branch Predictor. |
| **`fetch.sv`** | F (Instruction Fetch) | Manages the Program Counter (PC), determines the next PC (PC+4 or Target), and implements PC redirection based on prediction or mispredicts. |
| **`decode.sv`** | D (Instruction Decode) | Decodes the instruction, reads the Register File, calculates immediates, and generates control signals. |
| **`execute.sv`** | E (Execute) | Contains the **ALU**, branch target calculation, and the **Forwarding Muxes** to select operands from the RegFile or prior pipeline stages. |
| **`memory_unit.sv`** | M (Memory Access) | Interfaces the core with the Data Cache, handling load data sign/zero extension and passing requests. |
| **`writeback.sv`**| W (Writeback) | Selects the final result from the ALU, Memory, or PC+4 to write back to the Register File. |

### 2. Advanced Subsystems
| Module | Purpose | Key Functionality |
| :--- | :--- | :--- |
| **`branch_predictor.sv`** | Control Flow Optimization | Implements a **64-entry Branch History Table (BHT)** using 2-bit saturating counters. Used in the F stage to predict if a branch is taken or not. Updates state upon branch resolution in the E stage.  |
| **`hazard_unit.sv`** | Pipeline Control | Generates **Forwarding Signals** to resolve data hazards (E/M $\rightarrow$ E), **Stall Signals** for Load-Use and Cache Misses, and **Flush/Redirect Signals** for Control Mispredicts. |

### 3. Memory Hierarchy

#### `data_cache.sv`
* **Capacity:** 4KB total (split into 2 ways of 2048 bytes each).
* **Structure:** **2-way Set Associative** (512 sets). 
* **Policy:** **Write-Back** (dirty bit `d_way`) and **Write-Allocate**.
* **Replacement:** **Least Recently Used (LRU)** approximation using a single `u_bit` per set.
* **Logic:** Handles Load (`LW`, `LH`, `LB`, `LHU`, `LBU`) and Store (`SW`, `SH`, `SB`) hits and misses. A **miss** triggers a stall and, if the evicted block is dirty, an eviction/write-back to main memory.

#### `data_mem.sv` (Main Memory)
* **Purpose:** Simulates the off-chip main memory (RAM).
* **Capacity:** 128KB (address width of 17 bits).
* **Interface:** Only interacts with the `data_cache` for fill (miss) and write-back (eviction) operations. Writes are word-aligned.

---

More information about individual contributions can be found in personal statements.
