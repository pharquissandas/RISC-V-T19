# Team Report RISC-V-T19

## Group Members:
- **Preet Harquissandas** (Repo Master, Team Report Writer)
- **Mikhail Agakov**
- **Ojas Parikh**
- **Fangnan Tan**

## Table of Contents
* [Personal Statements](#personal-statements)
* [Overview of Repository Structure](#overview-of-repository-structure)
* [Important Notes and Critical Points](#important-notes-and-critical-points)
* [Quick Start (Build and Run)](#quick-start-build-and-run)
* [Overview of Achieved Goals](#overview-of-achieved-goals)
    * [Contribution Table](#contribution-table)
* [Proof Of Working CPU on Vbuddy](#proof-of-working-cpu-on-vbuddy)

---

## Personal Statements
> **Note:** The individual statements provide detailed contribution logs, reflections, and links to specific commits, as required by the project brief.
- [Personal Statement Preet Harquissandas](https://github.com/pharquissandas/RISC-V-T19/blob/main/personal_statements/Personal%20Statement%20-%20Preet%20Harquissandas.md)
- [Personal Statement Mikhail Agakov](https://github.com/pharquissandas/RISC-V-T19/blob/main/personal_statements/Personal%20Statement%20-%20Mikhail%20Agakov.md)
- [Personal Statement Ojas Parikh](https://github.com/pharquissandas/RISC-V-T19/blob/main/personal_statements/Personal%20Statement%20-%20Ojas%20Parikh.md)
- [Personal Statement Fangnan Tan](https://github.com/pharquissandas/RISC-V-T19/blob/main/personal_statements/Personal%20Statement%20-%20Fangnan%20Tan.md)

---

## Overview of Repository Structure

This repository is organized to contain all deliverables, separating source code, verification files, and documentation. All core processor designs are contained within the **`rtl`** folder.

| Directory | Content | Deliverable Requirement |
| :--- | :--- | :--- |
| **`rtl`** | All SystemVerilog source code for the processor. Different architectural versions (Single-Cycle, Pipelined, Cached, etc.) are managed using Git branches/tags. | **Required.** Includes `rtl/README.md` listing module authorship. |
| **`tb`** | Testbench environment, including assembly programs, verification setup, and the **`Makefile`** for building/testing. | **Required.** Includes evidence and build automation. |
| **`personal_statements`** | Individual reflection and contribution reports. | **Required.**|
| **`README.md` (root)** | This joint team statement and project overview. | **Required.** |

---

## Important Notes and Critical Points

### Core Design Status
The highest level of achievement successfully verified is the **Cached Pipelined RV32I Design** (Stretch Goal 2).

### Critical Points for Assessment
1.  **Branch Management (Required):** All major processor versions are accessible via dedicated branches, which contain the correct design in the **`rtl`** folder:
    * **`main`**: Single-Cycle RV32I Design (Basic Goal)
    * **`pipelined`**: Pipelined RV32I Design (Stretch Goal 1)
    * **`cached`**: Pipelined + 2-Way Set-Associative Data Cache (Stretch Goal 2)
    * **`fpga`**: FPGA-optimized Pipelined Design (Specialized)
    * **`superscalar`**: Superscalar Pipelined Design (Advanced Extension)
2.  **Verification:** The **`cached`** design successfully passes:
    * The team's F1 starting light program.
    * The reference **`pdf.asm`** program (evidence below).
    * All five verification programs in the `tb/asm` folder.
3.  **Data Cache:** The implementation uses a **2-way set-associative data cache** with a capacity of **4096 bytes** (1k words) and LRU replacement.

---

## Quick Start (Build and Run)

This section provides the essential commands for the assessor to build and verify your processor. We recommend running the full test suite on the **`cached`** branch, as it represents the highest level of achievement (Stretch Goal 2: Pipelined with Data Cache).

### 1. Setup and Build

The process requires switching to the target branch and building the processor model.

1.  **Check out the required branch** (e.g., for the highest achievement):
    ```bash
    git checkout cached
    ```

2.  **Navigate to the testbench folder:**
    ```bash
    cd tb
    ```

3.  **Build the Processor Model:**
    *This step compiles the source code in `rtl/` into the simulation environment.*
    ```bash
    ./build.sh  # Use the name of your specific build script (eg ./doit.sh, ./f1.sh, ./gaussian.sh, ./triangle.sh, ./noisy.sh)
    ```

### 2. Available Test Commands

The following shell scripts in the `tb` directory are used to run all verification programs and generate the required evidence.

| Command | Behaviour | Deliverable Requirement |
| :--- | :--- | :--- |
| `./doit.sh` | Runs **all** the required verification test benches (e.g., from `tb/tests`) to ensure the processor passes the **five mandated tests**. | **Required** (Verification of 5 tests) |
| `./f1.sh` | Runs the **`f1-lights`** program. The successful execution must be captured as video evidence. | **Required** (F1 program evidence) |
| `./gaussian.sh` | Executes the program and plots the **`gaussian`** graph. | Evidence / Demonstration |
| `./triangle.sh` | Executes the program and plots the **`triangle`** graph. | Evidence / Demonstration |
| `./noisy.sh` | Executes the program and plots the **`noisy`** graph. | Evidence / Demonstration |

---

## Overview of Achieved Goals

The team successfully implemented the **Single-Cycle RV32I Design** and achieved **Stretch Goal 2** by implementing a **Pipelined Processor with a 2-way Set-Associative Data Cache**. Furthermore, specialized FPGA and Superscalar versions were explored.

### Contribution Table
| Design Phase | Contributions | Preet | Mikhail | Ojas | Fangnan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Reduced RISC-V CPU** | Program Counter | | X | | |
| | ALU | | | X | |
| | Register File | | | X | |
| | Instruction Memory | X | | | |
| | Control Unit | X | | | |
| | Sign Extend | X | | | |
| | Testbench | | | | X |
| | Topfile/implementation | | X | | X |
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
| | Testbenches | X | | | |
| **Pipelined RV32I** | Pipeline Registers | X | | | |
| | Pipeline Stages | X | | | X |
| | Hazard Unit (Detection/Forwarding) | X | | | X |
| **Data Memory Cache** | Memory (refactor) | | X | | |
| | Direct mapped cache | | X | | |
| | Two-way set associative cache | | X | | |
| **Full RV32I Design** | Testbenches | X | X | | |
| | Module Refactoring | X | X | | X |
| **Other** | F1 Program | X | | | X |
| | Branch Predictor | X | | | |
| | Vbuddy | X | | | |
| | FPGA | | X | | |
| | Superscalar Implementation | | | X | |

---

## Proof Of Working CPU on Vbuddy:

*(Evidence is taken from the fully functional Pipelined + Cache design on the **`cached`** branch)*

### **Reference Program: `pdf.asm`**
Successfully ran the probability distribution function program.


[Image of Probability Distribution Function Plot on Vbuddy Display]


### **F1 Starting Light Program**
Link to video (Showing the F1 lights sequence completing successfully)

### **Gaussian Test Program**
Link to video (Showing output/Vbuddy result)

### **Noisy Test Program**
Link to video (Showing output/Vbuddy result)

### **Triangle Test Program**
Link to video (Showing output/Vbuddy result)

### **FPGA Implementation**
Link to video (Demonstrating operation on the FPGA platform using the **`fpga`** branch code)
