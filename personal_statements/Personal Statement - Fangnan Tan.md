# Personal Statement – [FANGNAN TAN] ([02571173])

EIE2 Instruction Set Architecture & Compiler (IAC)  
Team [19] – RISC-V RV32I Processor Project  
December 2025

## 1. Overall Role & Responsibilities

Throughout this project, I worked as one of the main designers responsible for turning our team’s initial drafts into a fully functional processor. Our early work followed an independent, module-by-module workflow, which led to mismatches and functional issues. Using these drafts as a base, I refactored the architecture and rebuilt most modules to achieve a correct and unified single-cycle CPU which matched the RV32I specification and executed the test programs correctly. Similarly, for the pipelined version, the team contributed preliminary versions of the four pipeline registers and a forwarding-only hazard unit. Using these as a starting point, I extended the hazard logic, corrected structural issues, integrated the pipeline, and debugged it until it became a fully verified 5-stage RV32I processor. In addition, I resolved multiple issues in the testbench, build scripts and independently used waveform tracing to diagnose and fix remaining architectural bugs, enabling both the single-cycle and pipelined CPUs to pass all verification programs.

In practice, this meant that I:

- Reconstructed the single-cycle datapath and control by refactoring and rewriting most modules contributed in the early independent-development stage.
- Ensured that the final single-cycle CPU correctly implemented all required RV32I behaviours and executed the reference programs without errors.
- Completed and corrected the preliminary pipelined design by integrating the four pipeline registers, extending the hazard unit with stalling and flushing, and resolving structural inconsistencies.
- Performed the majority of debugging for both CPU versions, using systematic waveform tracing to identify architectural and timing bugs.
- Fixed issues in the testbench and build scripts (including `doit` and `compile.sh`), restoring a functional automated verification flow.
- Implemented the F1 starting-light program and used it to drive early validation of the processor.
- Diagnosed and corrected memory-map and memory-size problems that caused reference-program failures, enabling all tests to run correctly.
- Ultimately brought both the single-cycle and pipelined RV32I processors to a fully verified state, passing the F1 test, the `pdf.asm` program, and all five tests in `tb/asm`.

## 2. Technical Contributions

### 2.1 Single-Cycle RV32I Processor

In the early stage of the project, our team adopted an independent development approach where each member implemented their assigned module separately. In the interest of rapid progress, we focused on our own components without fully examining how other modules behaved, which resulted in interface mismatches and functional issues once integration began. Using these draft modules as a starting point, I refactored the architecture into a coherent structure and rewrote or corrected most of the core components so that the processor matched the RV32I specification.

By reconstructing the design and validating correctness through systematic structural reasoning rather than relying on a testbench or waveform tools at this stage, I produced a clean, correct, and fully functional single-cycle RV32I CPU building on the initial contributions from my teammates. The implementation supports all required RV32I base instructions (and nearly the full RV32I instruction set, excluding only FENCE, ECALL/EBREAK and CSR instructions as noted in Stretch Goal 3), and is capable of running the F1 program, the reference `pdf.asm`, and all verification tests once the testbench infrastructure was operational.

The following contributions are traceable in this [representative commit](https://github.com/pharquissandas/RISC-V-T19/commit/c4ae1357ca70b64cff745d25ec3ec5ade91b6f79):



- **Control Path**
  - Implemented the `control.sv` module, integrating the `main_decoder` and `alu_decoder` logics into a coherent control unit to minimise redundancy and avoid rewrite issue between two sub-modules.
    - Introduced the `BranchType` and `Branch` control signals to support all B-type instructions in coordination with the ALU’s Zero flag, without requiring additional condition flags.
    - Structured the decoding logic by distinguishing I-type and B-type instructions explicitly, allowing the control unit to determine the required ALU operation directly and unambiguously by `ALUControl` signal.
    - Added the `ALUSrcA` signal to support the AUIPC instruction by selecting the PC as an ALU operand.
    - Introduced the `AddressingControl` signal to correctly identify data types (byte, halfword, word, signed/unsigned) in the Data Memory module.
  - Designed a dedicated `PCSrcUnit` module for computing the next-PC selection using `BranchType`, `Zero`, and `Branch` signals, separating this logic from the main control unit to avoid cross-stage dependencies in the pipelined CPU.
  - Ensured consistency across all control modules and integrated them into a clean `ControlPath` sub-top layer that interfaces with the `DataPath` to form a coherent single-cycle architecture.
- **Data Path**
  - Developed the `pc.sv` module, generating `PCNext` according to the `PCSrc` signal and supporting `PC+4`, `PCTarget` for branch/jump instructions, and the JALR alignment rule internally.
  - Implemented a clean and instruction-agnostic `alu.sv` module focused exclusively on arithmetic and logical operations. The ALU executes ADD/SUB/AND/OR/XOR/SLT/SLTU/shift variants purely from the `ALUControl` signal generated by the control logic, allowing instructions such as BLT to be handled via SLT without modifying ALU internals.
  - Rewrote `data_mem.sv` to a correct **byte-addressed memory model**, replacing the earlier word-addressed version that could not support LB/LH/LBU/LHU/SB/SH/SW correctly. The new implementation supports partial stores and performs correct sign/zero extension for all load types using `AddressingControl`.
  - Removed the standalone `mux.sv` module and replaced it with integrated combinational logic (`always_comb` and `assign`) inside `data_path.sv` to reduce unnecessary module fragmentation and improve readability.
  - Implemented the final writeback multiplexer (`ResultSrc`) inside the datapath, ensuring correct selection between `ALUResult`, memory read data, and `PC+4`.
  - Ensured architectural consistency across all datapath modules and integrated them into a clean `DataPath` sub-top layer that cooperates with the `ControlPath` to form a coherent and verifiable single-cycle RV32I CPU.
- **Integration & Testing**
  - Verified datapath correctness through structural reasoning—manually tracing operand flow, PC sequencing, immediate generation, and control interactions—before the testbench was functional.
  - Debugged datapath behaviour by isolating discrepancies between expected and actual data movement, allowing the early identification of load/store width issues, ALU operand selection errors, and immediate decoding edge cases.
  - Ensured that the final integrated datapath executed all RV32I base instructions correctly once the repaired testbench was available.

### 2.2 Five-Stage Pipelined RV32I Processor

Based on our experience from the single-cycle design, our team again divided the work. 
After my teammates produced an initial forwarding-only hazard unit and preliminary 
pipeline registers, I took over the integration work. Through extensive GTKWAVE tracing 
and structural debugging, I completed the full 5-stage pipelined RV32I processor.

The following contributions are traceable in this [representative commit](https://github.com/pharquissandas/RISC-V-T19/commit/0c0a794b5dd62a039284c356115b27157f86f33a):

- **Integrated the complete 5-stage pipeline architecture**  
  Built the top-level datapath and control path into stage-specific modules 
  (`fetch`, `decode`, `execute`, `memory`, `writeback`) to replace earlier 
  incomplete or inconsistent wiring. Ensured correct signal propagation across 
  the IF → ID → EX → MEM → WB stages.

- **Extended the [Hazard Unit](https://github.com/pharquissandas/RISC-V-T19/commit/c6f24e36656ec07e608edcfd358ae70999142483) beyond forwarding**  
  Added full support for:
  - load-use hazard detection,  
  - decode/fetch stalling,  
  - pipeline flushing for control hazards,  
  - and protection against hazards involving `x0`.

  This transformed the forwarding-only draft into a complete hardware hazard-mitigation system.

- **Implemented and refined all pipeline registers**  
  Completed the behaviour of `fetch_to_decode`, `decode_to_execute`, 
  `execute_to_memory`, and `memory_to_writeback` registers with correct handling of:
  - stall conditions,  
  - flush conditions,  
  - control-signal propagation,  
  - ALU results, immediates, writeback values, and PC+4.

- **Reworked PC update logic for pipelining**  
  Introduced an enable signal to allow the PC to stall cleanly during load-use hazards and decode-stage stalls. Set `PCSrcUnit` into the EX stage to match the design philosophy established in the single-cycle CPU and avoid unnecessary dependencies in earlier pipeline stages. Additionally separated the computation of `PCTarget` from `pc.sv`, avoiding cross-stage coupling and enabling correct, stage-local branch resolution within the pipeline.

- **Refined and completed the forwarding logic**  
  Corrected the draft forwarding unit by ensuring that ALU operand multiplexers receive the latest valid value through fully specified EX/MEM and MEM/WB forwarding paths, and by preventing false hazards such as unintended forwarding from register x0. This guarantees that both ALU inputs always use the correct, most recently produced data across all pipeline stages.

- **Debugged and validated pipeline behaviour end-to-end**  
  Using **GTKWAVE**, identified and corrected several *non-obvious* structural issues, including:
  - an incorrectly ordered multiplexer inside the EX stage, leading to wrong operand selection,
  - an incorrect writeback-path selection that only manifested under specific instructions.  
  
  After resolving these subtle bugs, the pipelined processor successfully executed the F1 program, the reference `pdf.asm`, and all verification tests.

### 2.3 F1 Program, Debugging and Verification

Although the assembly programming and testbench infrastructure were shared within the team, I contributed substantially in both program development and debugging/verification.

- **Development of the [F1 assembly program](https://github.com/pharquissandas/RISC-V-T19/commit/866e0357b9b43a246460f48eae1534d9f98766ac)**  
  I originally implemented the complete `f1.s` program from scratch. The program followed the official F1 Starting Light specification and included:
  - sequential LED illumination,
  - detection of the “all-lights-on” condition,
  - randomised delay generation,
  - correct extinguishing behaviour after the random interval.

  This version provided a fully functional and specification-accurate stimulus for testing the CPU. Although later file rearrangements caused the original program to be overwritten, the design and logic I contributed formed the basis of the final working version.

- **Restoring a working [toolchain](https://github.com/pharquissandas/RISC-V-T19/commit/1af1b7f325f1a88627847bbfe52ace9ceb3898ab) when the testbench was unusable**  
  At the time I completed the single-cycle CPU, our team still did not have a functioning testbench. During the following lab session — as the toolchain had not yet been brought into a working state — I focused on restoring the build and test pipeline by:

  - fixing `assemble.sh` and `doit.sh` so assembly files were correctly compiled and integrated with the GoogleTest + Verilator framework,
  - ensuring reference tests and custom programs could be loaded and executed.

  This work effectively re-enabled the entire verification workflow for the team.

- **Debugging the per-instruction testbench and identifying root-cause failures**  
  After receiving the per-instruction verification tests, the initial runs aborted immediately. To regain progress, I proposed a systematic debugging strategy by isolating the failing instruction category and running only a few instructions at a time. This approach unblocked the team’s progress at a point where the project had stalled.

  Through this targeted method, I traced the failure to jump/branch-related tests and eventually identified the precise cause: **the instruction memory had been allocated with insufficient capacity**.

  After expanding the IMEM size, the single-cycle CPU implementation — which I had independently reconstructed from the early draft before any working testbench or downstream module fixes were available — passed:  
  - all base RV32I ISA instructions,
  - all verification tests in `tb/asm`.

  This debugging and repair were completed within a tight 2-hour lab session and were essential for restoring momentum in the project and enabling the subsequent pipeline development.

## 3. Design Decisions & Trade-offs

Several architectural choices during both the single-cycle and pipelined implementations required conscious design decisions and trade-offs:

- **Consolidation and Structuring of Control Logic**  
  A key design decision was to unify the Main and ALU decoders into a single `control.sv` module. This avoided duplicated logic and conflicting ALUControl generation—for example, ensuring B-type and I-type SLT/SLTU behaviours were produced consistently without two separate decoders rewiring `funct3/7`, and allowing cases like JALR to specify their ALU behaviour directly in a single place.

- **Independent and minimal branch-resolution logic**  
  In parallel, I moved all PC-update decisions into a dedicated PCSrcUnit, using the compact BranchType + Branch + Zero scheme together with a 2-bit Jump signal (for JAL/JALR) to generate PCSrc.
  This replaced earlier multi-flag or multi-signal approaches, producing a much cleaner interface, reducing cross-module coupling, and creating a structure that naturally supports EX-stage branch resolution in the pipelined CPU.

- **Rebuilding Instead of Patching**  
  Early drafts were conceptually helpful but fragmented, inconsistent, and often contained incomplete logic, so I chose to rebuild the architecture cleanly while preserving the intended behaviour. This came with a clear trade-off — it temporarily replaced parts of the earlier work and required the team to adapt to a unified structure — but the benefits were significant: consistent naming and control conventions, simplified module interfaces, and a far cleaner architectural flow.
  The reconstruction enabled a coherent, minimal, and logically rigorous style across modules, greatly reducing integration effort and making later debugging and pipelining much easier.

- **Using a fully specified byte-addressed memory model**  
  I replaced the initial word-addressed design with a byte-addressed model to properly support LB/LH/LBU/LHU/SB/SH/SW.  
  This increased implementation complexity, but aligned the processor with the RV32I spec and avoided subtle correctness issues in the pipeline.

- **Choosing a forwarding-first + minimal stall strategy**  
  The hazard unit was designed to prioritise forwarding wherever possible, introducing stalls only for unavoidable load-use hazards.  
  This balances performance and design complexity, avoiding overly aggressive or brittle optimisations.

## 4. Reflection and Future Work

This was my first time designing a complete CPU cooperatively—from reading the RV32I ISA, to defining the microarchitecture, to implementing the design in SystemVerilog and verifying it with a custom testbench. Because our team initially worked in a loosely coordinated, module-by-module manner, I often needed to understand not only my own components but also the partially completed drafts contributed across the team, integrating and strengthening them into a coherent microarchitecture.
This required me to build a deeper architectural understanding than I had anticipated: instead of focusing only on the blocks I was responsible for, I had to understand all modules, how they interacted, and how to innovate or adjust design logic to make the overall CPU coherent and efficient.

Rebuilding large parts of the design meant continually weighing my own architectural choices against the early drafts.
Decisions such as moving PC-update logic into a dedicated PCSrcUnit, or unifying the decoders into a single consistent control module, emerged from recognising how fragmented structures quickly become difficult to extend, debug, or pipeline.
Through this process, I began to appreciate what an educational-level single-cycle and pipelined RV32I CPU truly requires—not only understanding the function of each individual block, but understanding the behaviour, constraints, and interactions of the microarchitecture as a whole.

Looking forward, there are several improvements I would make both technically and in our team workflow:

- **Stronger upfront architectural planning**  
  Establishing a shared block diagram, naming conventions, and clear signal definitions at the start would have prevented many integration issues.  
  Agreeing early on the behavioural requirements of key modules (e.g., PC update logic, hazard behaviour, decoding boundaries) would also have ensured that independently written components remained compatible.

- **More collaborative development workflow**  
  Assigning modules individually without shared checkpoints led to mismatches that only surfaced during integration, concentrating debugging on a few people.  
  Iterative design reviews, pair-development for critical modules, and earlier small-scale integrations would have distributed workload more evenly and reduced the need for major rewrites.

- **More structured technical practices**  
  Even simple unit tests for the ALU, control logic, and hazard unit would have caught bugs much earlier.  
  Incorporating differential testing against an ISA reference model during development—not only at the end—would have increased confidence in correctness throughout the process.

- **Improved communication and expectation alignment**  
  The project showed how easily inconsistent assumptions can accumulate when people work in isolation.  
  Being more proactive in discussing interfaces, intermediate results, and design intentions would reduce misunderstandings and make the final integration far smoother.


Overall, this project developed both my technical skills—pipelining, control-logic design, debugging with waveforms—and my understanding of how important coordination and architectural clarity are when building a processor collaboratively.
It taught me that correctness and simplicity at the architectural level are as important as the SystemVerilog code itself, and that good communication can save far more time than clever optimisations.