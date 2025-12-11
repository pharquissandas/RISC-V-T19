# Personal Statement - Mikhail Agakov

Name: Mikhail Agakov \
CID: 02560202 \
GitHub username: minimish1

## Table of Contents
- [Summary](#summary)
- [Contributions](#contributions)
- [Lab 4 - Reduced RISC-V CPU](#lab-4-reduced-risc-v-cpu-1)
- [Single Cycle RV32I Design](#single-cycle-rv32i-design-1)
- [Full RV32I Design](#full-rv32i-design-1)
- [Set Associative Data Cache](#set-associative-data-cache-1)
- [FPGA Synthesis & Physical Implementation](#fpga-synthesis-&-physical-implementation-1)
- [Reflection](#reflection)

## Summary
I was involved in almost every part of our design. I focused mostly on implementing the cpu and I subsequently had to do a lot of testing and fault finding for the correct implementation. My core contributions were: implementing all of the RV32I instructions, implementing all of the set associative data cache, and synthesising our pipelined and cached cpu onto an FPGA.

## Contributions
- ### Lab 4 Reduced RISC-V CPU
    - I made the program counter file. [7a42e1b](https://github.com/pharquissandas/RISC-V-T19/commit/7a42e1bbace9fbe77d790de7073ae14264f541cc), [9fa7f4c](https://github.com/pharquissandas/RISC-V-T19/commit/9fa7f4c33ffbee6f2f82b0320135da0ced997e05)
    - I wired everything together in a top.sv file. [4daac63](https://github.com/pharquissandas/RISC-V-T19/commit/4daac632d355c869036806bf9aa48218f96c397c)
    - I did the testing and bugfixing for all the files. [c6cdc60](https://github.com/pharquissandas/RISC-V-T19/commit/c6cdc60196568d2247c20cc42b2bccc89acd872e)

- ### Single Cycle RV32I Design
    - I made the main decoder. [d5f21ca](https://github.com/pharquissandas/RISC-V-T19/commit/d5f21ca24a4701866944e75b916fdd81aae99e23)
    - I implemented the opcodes for all the instructions. [6ed0117](https://github.com/pharquissandas/RISC-V-T19/commit/6ed0117b40dc0a34054dfff9ee7254fb4d67efda)
    - I added the instruction memory. [6ed0117](https://github.com/pharquissandas/RISC-V-T19/commit/6ed0117b40dc0a34054dfff9ee7254fb4d67efda)

- ### Full RV32I Design
    - I implemented all the instructions of RV32I. [b7f1b1e](https://github.com/pharquissandas/RISC-V-T19/commit/b7f1b1e72302a3d90243256d9e1f2a8841f5ee43), [a8830bc](https://github.com/pharquissandas/RISC-V-T19/commit/a8830bcbb9a7402b08bae13e70c57cd25c3ab3e1), [43e6a66](https://github.com/pharquissandas/RISC-V-T19/commit/43e6a66e4839f1c52718d7b3579d6d54f9ebe2bd), [b10bc50](https://github.com/pharquissandas/RISC-V-T19/commit/b10bc50798ed436975e8e290881979f55fce8459)

- ### Pipelined RV32I Design
    - I created the pipeline registers for the fetch-decode, decode-execute, execute-memory, and memory-writeback stages. [57bd228](https://github.com/pharquissandas/RISC-V-T19/commit/57bd22886b0820a0d127476299e7bd2c1cbfcff9), [0ee181b](https://github.com/pharquissandas/RISC-V-T19/commit/0ee181b279f1eabb55375f525c3353fe0c43493f)\
    (These were later reworked by **Preet Harquissandas**)

- ### Set Associative Data Cache
    - I made the 2-way set associative data cache. [a7e3214](https://github.com/pharquissandas/RISC-V-T19/commit/a7e321481192b9d74ebab924f7ca49788ccb717a), [cfbba94](https://github.com/pharquissandas/RISC-V-T19/commit/cfbba942c9c1e48d73b71040414fc29c43263899), [1c53891](https://github.com/pharquissandas/RISC-V-T19/commit/1c5389125a0d7ccef079b709d263ed57cec48eb1)
    - I implemented writeback with stalling and dirty bit eviction. [1d9d03f](https://github.com/pharquissandas/RISC-V-T19/commit/1d9d03fb901625e0c36a4c739f80466abe8ad5ca), [833f717](https://github.com/pharquissandas/RISC-V-T19/commit/833f717eb3520c0d2eda6f82e81d63e3d70128f2)
    - I added cache testbenches and reworked cache logic. [b5965f5](https://github.com/pharquissandas/RISC-V-T19/commit/b5965f5192b2b5b66dba64c7fe4aff445c4f2931)

- ### FPGA Synthesis & Physical Implementation
    - I implemented our pipelined cpu with hazard handling, branch prediction and data cache on an FPGA. [9e74a0e](https://github.com/pharquissandas/RISC-V-T19/commit/9e74a0e8a1af568ef7b8b47b42c5a3c94d4f2f5c)
    - I created test programs for the FPGA in assembly and as a .mif for the FPGA's instruction memory rom. [8b38e0e](https://github.com/pharquissandas/RISC-V-T19/commit/8b38e0e85606f43dee206c08415aaa31e2c6ee35)

## Lab 4 Reduced RISC-V CPU
For the simple RISC-V CPU in lab 4 I implemented the program counter (PC) module, ensuring correct synchronous updates and asynchronous resets. The program counter module worked by incrementing the PC by 4 (due to the byte addressing of the instruction memory ROM). It would also increment PC by the immediate operand (for branch instructions) depending on the value of PCsrc.

Crucially, I was also responsible for the **top.sv** wrapper file including wiring between the program counter, instruction memory, control unit, sign extend, and data unit. This also allowed each module to be tested together, as previously it was impossible to test functionality of each module without the full design. Naturally I had to fix many errors in each module for correct functionality.

## Single Cycle RV32I Design
To transition from the reduced lab 4 CPU to a single cycle RV32I I expanded the control unit into the main decoder. The main decoder worked by getting the opcode from the instruction word to determine which type of instruction it is and outputting corresponding values which are used to execute the instruction operation: 
- **ResultSrc**: Selects data written to register file (ALU result or memory data)
- **MemWrite**: Enables writing to data memory
- **ALUsrc**: Selects ALU second operand (0 = register, 1 = immediate)
- **RegWrite**: Enables writing to registers
- **Branch**: Indicates branch instruction
- **ImmSrc**: Selects the type of immediate
- **ALUOp**: Encodes ALU operation type

At this point we decided as a team that it would be easier to implement the full RV32I instruction set straight away instead of only implementing some instructions and then changing everything later when we implement all the instructions so I implemented decoding logic for all instruction types (R, I, S, B, U, J). Here is an example of the main decoder for the load instructions:

```
// EXAMPLE FOR LOAD INSTRUCTIONS
// load instructions: LB, LH, LW, LBU, LHU
// opcode = 0000011 
7'b0000011: begin
    ResultSrc = 2'b01;  // load data from memory
    MemWrite  = 0;
    ALUsrc    = 1;      // use immediate for address
    RegWrite  = 1;
    Branch    = 0;
    ImmSrc    = 3'b0;   // I-type immediate
    ALUOp     = 2'b0;   // ALU does ADD for address
end
```

I also created the data memory and completed the data unit for the single cycle RV32I design. The data memory simply worked by creating an array of 2^32 32-bit memory locations (later this turned out to be too large to compile and was reduced). The writing to the data memory was synchronous, this is because the write enable wouldn't change instantly and so writing to the memory waited for a clock tick. For the CPU to be single-cycle, the read from memory was asynchronous which also drastically simplified further stages of the CPU, this made the read instant though for real CPU's it would take many clock cycles.

## Full RV32I Design
As stated earlier, we decided to implement all the RV32I instructions straight away. This meant I had to change ALUcontrol to 4 bits instead of 3 to allow the ALU to handle all instructions. I also had to change ImmOp from 2 bits to 3 bits so that the immediate extend block could handle all types of instructions (R, I, S, B, U, J). This implemented all the basic instructions.
```
// BASIC INSTRUCTION ALU LOGIC
case (ALUControl)
    4'b0000: ALUResult = SrcA + SrcB; // add
    4'b0001: ALUResult = SrcA - SrcB; // sub
    ...
```
For the load and store instructions, I had to change to the control unit to output funct3 so that the data memory would determine the byte addressing based on the instruction (SW, SB, LW, LB etc.)
```
// DATA MEMORY BYTE HANDLING
case(funct3) // asynchronous read
    3'b000: begin // LB
        assign dout = {{24{ram_array[wr_addr][7]}}, ram_array[wr_addr][7:0]};
    end
    3'b010: begin // LW
        assign dout = ram_array[wr_addr];
    end
    ...

case(funct3) // synchronous write
    3'b000: begin // SB
        ram_array[wr_addr][7:0] <= din[7:0];
    end
    3'b010: begin // SW
        ram_array[wr_addr] <= din;
    end
    ...
```
For the branch instructions, I changed the zero output from the ALU to be 3 bits to give an output for each of the conditions of SrcA and SrcB in the ALU not only if they are equal. Subsequently I added logic in the control to determine whether a branch should be taken for a specific branch instruction if the relevant condition is true.
```
// ALU CONDITIONAL LOGIC
if ($signed(SrcA) != $signed(SrcB)) begin
    assign Zero = 3'b001; // not equal
end
if ($signed(SrcA) < $signed (SrcB)) begin
    assign Zero = 3'b010; // less than
end
...
```
```
// CONTROL BRANCH TAKEN LOGIC
case(funct3) begin
    3'b001: begin // BNE
        if (EQ == 3'b001) begin
            PCsrc = 1'b1;
        end
    end
    3'b100: begin // BLT
        if (EQ == 3'b010) begin
            PCsrc = 1'b1;
        end
    end
...
```
For the last 4 instructions (JAL, JALR, LUI, AUIPC) I did the following:
- **JAL**: Changed ResultSrc from 1 bit to 2 bits and added an input of PC+4 to the result multiplexer which would be selected on a JAL and JALR instruction.
- **JALR**: Changed PCsrc from 1 bit to 2 bits and added an input of rs1 + imm from ALUout to the PC select register which would be selected on a JALR instruction.
- **LUI**: Added logic to ALU which would set ALUout to SrcB which is correctly shifted in the extend block for a LUI instruction.
- **AUIPC**: Added logic to ALU similar to LUI but also added the current value of PC for a AUIPC instruction.

This provided a working basis for the single cycle CPU with all RV32I instructions. However some of the instruction implementation was sloppy and unoptimised so **Fangnan Tan** later restructured this to optimise it for easier pipelining implementation.

## Set Associative Data Cache
I created the data cache and decided to implement a 2-Way Set Associative Data Cache. A data cache is meant to optimise performance by storing recently used memory data so that if that memory data is needed again it could be accessed from the cache (short access time) as opposed to the data memory (long access time). However, as I stated earlier, for this CPU implementation, the memory read is asynchronous and is basically instant whereas in reality it would take many many clock cycles. This means that for this CPU implemntation the data cache would actually make the design less efficient and it would take longer to execute instructions.

For a 2-Way Set Associative Data Cache, each set has 2 ways, each way in a set has a tag, data, a valid bit, and a dirty bit, finally each way also has a u-bit. The valid bit determines whether the data stored is meaningful, and the u-bit is used to determine which way was last recently used. The dirty bit is used if the cache has a write-back policy; if memory data is stored in the cache and then that memory location is written to, it is only written to the cache (cache location becomes dirty) and only written back to the data memory if that cache location gets evicted by other data memory. Initially I implemented a simple write-through cache (no dirty bit), if a memory location is written to it is immediately changed both in the cache and the data memory, but later I also implemented write-back with the dirty bit.

The design requirements specified a 4096 byte cache capacity, this means each way has a 2048 byte capacity, hence there are 512 sets (9 bit set index). I implemented the cache by having arrays for valid bit, dirty bit, data, and tag arrays for each way along with a u bit for each way for the last recently used replacement policy. The hit logic for each way was determined asynchronously by if the valid bit was true and if the tag of the way mached the tag of the address. Then synchronously, on a miss the data was written to the cache, on a miss the data was copied from the data memory to the cache to the way that was last recently used, always the u-bit is updated with the way thats last recently used.
```
...
// HIT LOGIC
// Asynchronous
assign hit0 = v_way0[set] && (tag_way0[set] == tag);
assign hit1 = v_way1[set] && (tag_way1[set] == tag);
assign hit  = hit0 || hit1;
...
// Synchronous
// On a write hit, write to cache
if (WE) begin
    if (hit0) begin
        data_way0[set] <= WD;
        u_bit[set]  <= 0;
        d_way0[set] <= 1;
    end
    else if (hit1) begin
        data_way1[set] <= WD;
        u_bit[set]  <= 1;
        d_way1[set] <= 1;
    end
end
...
// On a miss, bring data from ram to cache
else if (!hit) begin
    ram_write_en <= 0;
    // 1 most recently used so load into 0  
    if (u_bit[set] == 1) begin
        data_way0[set] <= mem_rd_data;
        tag_way0[set]  <= tag;
        v_way0[set] <= 1;
        d_way0[set] <= 0;
        u_bit[set]  <= 0; // way 0 most recently used
    end
...
```
I also restructured the memory unit to have seperate **data_mem.sv** and **data_cache.sv** modules which lay in an overarching **memory_unit.sv** file. As for the byte addressing of all the loading instructions (LB, LW etc.) I handled it all in the **memory_unit.sv** file and modified the data memory to only return full words with aligned bytes (It still handled storing instructions as normal). As this was the write-thorugh version the aligned word data would then be written to the cache and the output from the cache would then handle the byte addressing.
```
// MEMORY UNIT BYTE ADDRESS HANDLING
case (AddressingControl)
    3'b000: begin // LB (signed)
        case(byte_offset)
            2'b00: RD = {{24{cache_out[7]}},  cache_out[7:0]};
            ...
        endcase
    end
    3'b001: begin // LH (signed)
        case(byte_offset[1]) // check bit 1 (0 or 2)
            1'b0: RD = {{16{cache_out[15]}}, cache_out[15:0]};
            ...
        endcase
    end
    3'b010: RD = cache_out; // LW
    3'b100: begin // LBU (unsigned)
        case(byte_offset)
            2'b00: RD = {24'b0, cache_out[7:0]};
            ...
        endcase
    end
    3'b101: begin // LHU (unsigned)
        case(byte_offset[1])
            1'b0: RD = {16'b0, cache_out[15:0]};
            ...
        endcase
    end
    default: RD = 32'b0;
endcase
...
```
```
// DATA MEMORY CHANGE
logic [ADDRESS_WIDTH-1:0] word_addr;
assign word_addr = {addr[ADDRESS_WIDTH-1:2], 2'b00}; // align bytes as LB LH LW logic handled in cache

always_comb begin // return word
    RD = {ram_array[word_addr+3], ram_array[word_addr+2], ram_array[word_addr+1], ram_array[word_addr]};
end

```
Implementing the write-back cache with the dirty bit was a lot more challenging as I had to implement stalling when a dirty location in the cache is evicted. This is because you cannot write to the data memory from a cache location and in the same clock cycle read from the data memory and write to that same cache location. I went about this by having a write enable signal to the RAM and stall signals for both ways and a stall output which went to the hazard unit. Then, asynchronously: if either way was stalling, a stall would be set and data would be written to the RAM. Finally, synchronously: if stalling has finished -> stop stalling, and execute hit or miss logic as previously except set the stalling signals if there is a miss. I also changed it so that the data memory would also write the full word for store instructions as and handled the byte addressing in the data cache as this fixed issues with bits being lost when writing to the cache.
```
...
// DATA CACHE REWORK
// Asynchronous stall checking
always_comb begin

    stall = 0;
    wr_en = 0;
    mem_wd = 32'h0;
    mem_addr = A;
    cache_dout = mem_rd;

    if (hit0)      cache_dout = data_way0[set];
    else if (hit1) cache_dout = data_way1[set];

    else if (stalling0) begin // stall way0
        stall = 1;
        wr_en = 1;
        mem_wd = data_way0[set];
        mem_addr = {tag_way0[set], set, 2'b00};
    end

    else if (stalling1) begin // stall way1
        stall = 1;
        wr_en = 1;
        mem_wd = data_way1[set];
        mem_addr = {tag_way1[set], set, 2'b00};
    end

    else if (!hit) begin // miss
        stall = 1;
    end
end
...
// Synchronous logic
// just finished stalling
if (stalling0) begin
    v_way0[set] <= 0; 
    d_way0[set] <= 0;
    stalling0   <= 0; // stop stalling
end
else if (stalling1) begin
    v_way1[set] <= 0;
    d_way1[set] <= 0;
    stalling1   <= 0; // stop stalling
end
...
// on a miss and way 1 most recently used
if(d_way0[set] == 1 && !stalling0) begin // if dirty, start stalling
    stalling0 <= 1;
end
else begin // else if clean, or if stalling = 1: already stalled
    data_way0[set] <= mem_rd;
    tag_way0[set]  <= tag;
    v_way0[set] <= 1;
    d_way0[set] <= 0;
    u_bit[set]  <= 0; // way 0 most recently used
end
// way 0
...
// on a HIT: write to cache, set dirty bits, do byte address handling
case (AddressingControl)
    3'b000: begin // SB
        case (byte_offset)
            2'b00: result[7:0]   = WD[7:0];
            2'b01: result[15:8]  = WD[7:0];
            2'b10: result[23:16] = WD[7:0];
            2'b11: result[31:24] = WD[7:0];
        endcase
    end
    3'b001: begin // SH
        case (byte_offset[1]) // bit 1 determines lower or upper half
            1'b0: result[15:0]  = WD[15:0];
            1'b1: result[31:16] = WD[15:0];
        endcase
    end
    3'b010: result = WD; // SW
    default: result = WD;
endcase
// set DIRTY BITS
if (hit0) begin
    data_way0[set] <= result;
    u_bit[set]  <= 0;
    d_way0[set] <= 1;
end
else if (hit1) begin
    data_way1[set] <= result;
    u_bit[set]  <= 1;
    d_way1[set] <= 1;
end
...
```
For the stalling my first idea was to modify the hazard unit to also have StallExecute, StallMemory, and FlushWriteback signals. So when there would be a cache stall, the fetch, decode, execute, memory stages would be stalled and the writeback would be flushed (so you don't write garbage/duplicate data to the register file), meanwhile data would be written from the cache to the data memory. However this lead to data corruption issues which were very difficult to find, so I ended up also making a StallWriteback signal so that when there is a cache stall, every stage would be stalled effectively freezing the cpu while data is written from the cache to the data memory. This version of the 2-Way Set Associative Data Cache worked perfectly but indeed it made the CPU operation much slower and less efficient due to the stalling because of our simulation instant memory read, in reality it would drastically improve efficiency.

## FPGA Synthesis & Physical Implementation
An FPGA (Field Programmable Gate Array) is an integrated circuit which can be reprogrammed to create specific hardware functions, it is a great way to visualise the functionality of the CPU. For synthesising your CPU design onto an FPGA, I used the **Quartus Prime** software and the **DE-10 Lite** FPGA, and I was implementing our latest version of the CPU: **Pipelined CPU with Hazard Handling, Branch Prediction and Set Associative Data Cache**. Unfortunately, you cannot just load all the files into quartus and expect it to work.
- Firstly, I had to create a **de10_lite_top.sv** file and a **display.sv** file to interface the output from the CPU to the 7-segment displays and LEDs of the DE-10 Lite.
- For the displays, I mapped the bottom 24 bits of the output as there are 6 displays and each requires 4 bits as 2^4 = 16 to select a certain HEX letter.
- For the LEDs, I mapped the bottom 10 bits of the output as there are 10 LEDs.
- For simulation purposes, I also manually decreased the speed of the clock using a clock divider as by default the clock speed of the DE-10 Lite is 50MHz which is too fast to see any changes in the output displays and LEDs. In reality, you would keep the clock speed as fast as possible so that instructions could be executed faster.
```
// DE10 LITE TOP CLOCK DIVIDER
// clock divider 50MHz too fast
logic [24:0] counter;
always_ff @(posedge MAX10_CLK1_50) begin
    counter <= counter + 1;
end
// counter[0] = 50MHz, counter[1] = 25MHz, counter[24] ~ 1.5Hz
// using slower clock for simulation
logic cpu_clk;
assign cpu_clk = counter[15];

// LED ASSIGNMENT
assign LEDR = a0_val[9:0]; // bottom 10 bits to LEDs
```
```
// MAPPING OUTPUT TO DISPLAYS ON DE10 LITE
module display (
    input  logic [31:0] data,
    output logic [7:0]  display0, // LSB
    ...
    output logic [7:0]  display5  // MSB
);
    // instantiate a decoder for each 4-bits
    // top 8 bits (31:24) are ignored as there are only 6 displays
    decoder_hex d0 (
        .i_bin(data[3:0]),
        .o_dec(display0)
    );
    ...
    decoder_hex d5 (
        .i_bin(data[23:20]),
        .o_dec(display5)
    );
endmodule

// 4-bit binary to 7-segment hex decoder
// 0 = segment ON, 1 = segment OFF
module decoder_hex (
    input  logic [3:0] i_bin, 
    output logic [7:0] o_dec
);
    always_comb begin
        case (i_bin)
            4'h0:    o_dec = 8'b1100_0000; // 0
            ...
            4'hF:    o_dec = 8'b1000_1110; // F
            default: o_dec = 8'b1111_1111; // Off
        endcase
    end
endmodule
```
Another change I needed to make was to initialise the data and instruction memory Quartus IP Cores which use the built in memory of the FPGA instead of implementing the data and instruction memory in the logic along with everything else. There are many reasons for making this change:
- The massive memory arrays would take too much space in hardware and the design wouldn't fit without decreasing memory size.
- It improves efficiency by implementing the memory separately allowing the whole design to be implemented in hardware.
- Although Quartus can synthesise $readmemh for ROMs, it relies on absolute file paths which makes the project non-portable.

Crucially, this changed the the data and instruction memory to be synchronous, and as I discussed earlier, having a synchronous memory read would require drastic changes to the entire design. Luckily, this could be avoided by a clever trick: by setting the instruction memory to read from the ROM IP Core on a negative clock cycle. This makes the data appear on the falling edge, so it is ready and stable by the time the next rising edge (Fetch Stage) happens. To put it in another way:

1. Rising Edge: PC updates. Address sends to Memory.
2. Falling Edge (Half cycle later): Memory reads and outputs data.
3. Next Rising Edge: Data is ready at the Decode stage.

This effectively makes the read semi-asynchronous relative to the main clock meaning that the design would not need to be completely reworked.
```
// INSTRUCTION MEMORY USING ROM IP CORE FROM DE10 LITE
module instr_mem (
    input  logic        clk, // clock
    input  logic [31:0] A,
    output logic [31:0] RD
);

// replace array with rom_ip core
rom_ip rom_inst (
    .address (A[13:2]), // word aligned address
    .clock   (~clk),    // inverted clock for stability (Crucial)
    .q       (RD)
);

endmodule
```
```
// DATA MEMORY USING RAM IP CORE FROM DE10 LITE
module data_mem (
    input  logic        clk,
    input  logic        WE,
    input  logic [31:0] A,
    input  logic [31:0] WD,
    output logic [31:0] RD
);

// replace array with ram_ip core
ram_ip ram_inst (
    .address (A[13:2]), // word aligned address
    .clock   (clk),     
    .data    (WD),
    .wren    (WE),
    .q       (RD)
);

endmodule
```
As I was trying to implement the version of the CPU with the data cache onto the FPGA there were more changes that needed to be made. The data cache had a 4096 byte capacity meaning there were 512 sets. This meant that the data and tag arrays for each way was 32 x 512 bits and 21 x 512 bits respectively, and there were also the arrays for each of the valid, dirty bits and the u-bit. This meant that the cache was extremely large and did not fit onto the FPGA. Like previously, this could have been fixed by implementing the cache on the RAM IP Core, but this would have changed the cache to be synchronous and now this would have certainly required a drastic design change. Instead, I simply reduced the size of the cache from having a 4096 byte capacity, to a 512 byte capacity meaning there were now only 64 sets. This allowed the cache to fit in the hardware implementation of the FPGA allowing it to compile fine.

Finally, I had to load the instruction memory ROM IP Core with the program. I initially used the `.hex` files which were used for the simulation, however this led to byte addressing issues so I had to convert the programs to `.mif` files which were read fine by the FPGA and executed as expected.
```
// COUNTER.MIF FILE FOR INSTRUCTION MEMORY ROM
WIDTH=32;
DEPTH=4096;

ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;

CONTENT BEGIN
    000 : 00000413; -- li s0, 0
    001 : 00040513; -- mv a0, s0
    002 : 00140413; -- addi s0, s0, 1
    003 : ff9ff06f; -- j -4 (loop)
    [004..FFF] : 00000000;
END;
```
Lastly, This FPGA specific version of the CPU compiled perfectly fine and worked as required. I tested the FPGA implementation on two programs:
- A simple counter which was displayed on the 7-segment displays in HEX and counted up indefinitely.
- A LED strip program which moved a single LED light from right to left then repeated.

## Reflection
### What I learned
Before this project, I had little to no practical experience with HDLs, SystemVerilog, ISAs, or FPGAs and my understanding of computer architecture was limited. This project forced me to bridge the gap between theory and implementation. I learned that hardware design requires a fundamentally different mindset than software programming; specifically, thinking in terms of clock edges, propagation delays, and parallel execution rather than sequential logic. This was specifically apparent when changing the design for FPGA implementation. I also gained a deep appreciation for the RISC-V ISA, understanding not just what an instruction does, but how it physically manipulates the datapath signals to achieve that result.

### Challenges
One of the more significant challenges was debugging the interaction between the Pipelined CPU and the Write-Back Cache. Specifically, resolving the issue where a cache stall flushed the writeback stage causing data to be inadvertently lost. This taught me the fragility of pipeline dependencies, it forced me to meticulously trace signals cycle-by-cycle using GTKWave to understand exactly where data was being lost.

Additionally, porting the design to an FPGA was a massive challenge as I had never worked with FPGA's before. I learned to overcome many synthesis errors which were not present in the simulation. This taught me the intricacies of designing for hardware such as the physical constraints and that design decisions, such as cache associativity and size, are physical trade-offs, not just algorithmic choices.

### What I would have done differently
- While implementing all the instructions of RV32I, I wish I did a better job of structuring the design for future additional implementations. Instead I made logic that would make the instructions execute correctly but it made the pipelining stage very difficult to implement and cause a lot of trouble for other members which restructured the design for efficiency.

- I wish I also made testbench programs at the start which would fully test the functionality of the CPU. For instance when I was implementing the cache, it seemed like it worked fine for simple tests but only later after I made complex test programs did I discover there were hidden bugs in the whole implementation.

### Conclusion
Despite the complexity of the project, seeing the LED strip and counter run on the FPGA was incredibly satisfying. It validated that the complex logic: branch prediction, pipelining, and caching was not just theoretical, but functional hardware.