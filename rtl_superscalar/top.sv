module top (
    input logic clk,
    input logic rst,
    output logic [31:0] a0,
    output logic [31:0] a1
);

    logic [31:0] InstrF1;
    logic [31:0] PCF1;
    logic [31:0] PCPlus8F1;

    logic [31:0] InstrF2;
    logic [31:0] PCF2;
    logic [31:0] PCPlus8F2;



// Fetch
    fetch fetch_inst (
        .clk(clk),
        .rst(rst),
        .en(~StallFetch1),
        .PCSrcE1(PCSrcE1),
        .PCTargetE1(PCTargetE1),
        .ALUResultE1(ALUResultE1),
        .PCSrcE2(PCSrcE2),
        .PCTargetE2(PCTargetE2),
        .ALUResultE2(ALUResultE2),
        .StallPipeline2(StallPipeline2),
        .StallPipeline1NC(StallPipeline1NC),
        .BranchIn1(BranchIn1),
        .BranchIn2(BranchIn2),
        
        .InstrF1(InstrF1),
        .PCF1(PCF1),
        .PCPlus8F1(PCPlus8F1),
        .InstrF2(InstrF2),
        .PCF2(PCF2),
        .PCPlus8F2(PCPlus8F2)
    );

// Fetch to Decode Register
    logic [31:0] PCD1;
    logic [31:0] PCD2;
    logic [31:0] PCPlus8D1;
    logic [31:0] PCPlus8D2;
    logic [31:0] InstrD1;
    logic [31:0] InstrD2;

    fetch_to_decode_register fetch_to_decode_register_inst(
        .clk(clk),
        .en1(~StallDecode1),
        .rst1(FlushDecode1),
        .en2(~StallDecode2),
        .rst2(FlushDecode2),
        .PCF1(PCF1),
        .PCPlus8F1(PCPlus8F1),
        .InstrF1(InstrF1),
        .PCF2(PCF2),
        .PCPlus8F2(PCPlus8F2),
        .InstrF2(InstrF2),

        .PCD1(PCD1),
        .PCD2(PCD2),
        .PCPlus8D1(PCPlus8D1),
        .PCPlus8D2(PCPlus8D2),
        .InstrD1(InstrD1),
        .InstrD2(InstrD2)

    );

// Decode
    logic [31:0] RD1D; //regfile output 1
    logic [31:0] RD2D; //regfile output 2
    logic [31:0] RD4D; //regfile output 4
    logic [31:0] RD5D; //regfile output 5

    logic [31:0] ImmExtD1;
    logic [31:0] ImmExtD2;

    logic [4:0] Rs1D;
    logic [4:0] Rs2D;
    logic [4:0] Rs4D;
    logic [4:0] Rs5D;
    logic [4:0] RdD1;
    logic [4:0] RdD2;

    logic        RegWriteD1;
    logic [1:0]  ResultSrcD1;
    logic        MemWriteD1;
    logic [1:0]  JumpD1;
    logic        BranchD1;
    logic [2:0]  BranchTypeD1;
    logic [3:0]  ALUControlD1;
    logic        ALUSrcBD1;
    logic        ALUSrcAD1;
    logic [2:0]  AddressingControlD1; 


    logic        RegWriteD2;
    logic [1:0]  ResultSrcD2;
    logic        MemWriteD2;
    logic [1:0]  JumpD2;
    logic        BranchD2;
    logic [2:0]  BranchTypeD2;
    logic [3:0]  ALUControlD2;
    logic        ALUSrcBD2;
    logic        ALUSrcAD2;
    logic [2:0]  AddressingControlD2; 
    logic        StallPipeline2;
    logic        StallPipeline1NC;

    decode decode_inst (
        .clk(clk),
        .InstrD1(InstrD1),
        .InstrD2(InstrD2),
        .ResultW1(ResultW1),
        .ResultW2(ResultW2),
        .RdW1(RdW1),
        .RdW2(RdW2),
        .RegWriteW1(RegWriteW1),
        .RegWriteW2(RegWriteW2),

        .PCD1(PCD1),
        .PCD2(PCD2),

        .RD1D(RD1D),
        .RD2D(RD2D),
        .RD4D(RD4D),
        .RD5D(RD5D),
        .ImmExtD1(ImmExtD1),
        .ImmExtD2(ImmExtD2),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs4D(Rs4D),
        .Rs5D(Rs5D),
        .RdD1(RdD1),
        .RdD2(RdD2),
        .RegWriteD1(RegWriteD1),
        .RegWriteD2(RegWriteD2),
        .ResultSrcD1(ResultSrcD1),
        .ResultSrcD2(ResultSrcD2),
        .MemWriteD1(MemWriteD1),
        .MemWriteD2(MemWriteD2),
        .JumpD1(JumpD1),
        .JumpD2(JumpD2),
        .BranchD1(BranchD1),
        .BranchD2(BranchD2),
        .BranchTypeD1(BranchTypeD1),
        .BranchTypeD2(BranchTypeD2),
        .ALUControlD1(ALUControlD1),
        .ALUControlD2(ALUControlD2),
        .ALUSrcAD1(ALUSrcAD1),
        .ALUSrcBD1(ALUSrcBD1),
        .ALUSrcAD2(ALUSrcAD2),
        .ALUSrcBD2(ALUSrcBD2),
        .AddressingControlD1(AddressingControlD1),
        .AddressingControlD2(AddressingControlD2),
        .StallPipeline2(StallPipeline2),
        .StallPipeline1NC(StallPipeline1NC),
        .a0(a0),
        .a1(a1)

    );

// Decode to Execute Register
    logic RegWriteE1;
    logic [1:0] ResultSrcE1;
    logic MemWriteE1;
    logic [1:0] JumpE1;
    logic BranchE1;
    logic [3:0] ALUControlE1;
    logic ALUSrcAE1;
    logic ALUSrcBE1;
    logic [2:0] AddressingControlE1;
    logic [2:0] BranchTypeE1;

    logic RegWriteE2;
    logic [1:0] ResultSrcE2;
    logic MemWriteE2;
    logic [1:0] JumpE2;
    logic BranchE2;
    logic [3:0] ALUControlE2;
    logic ALUSrcAE2;
    logic ALUSrcBE2;
    logic [2:0] AddressingControlE2;
    logic [2:0] BranchTypeE2;

    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] RD4E;
    logic [31:0] RD5E;
    logic [31:0] PCE1;
    logic [31:0] PCE2;
    logic [4:0] Rs1E;
    logic [4:0] Rs2E;
    logic [4:0] Rs4E;
    logic [4:0] Rs5E;
    logic [4:0] RdE1;
    logic [4:0] RdE2;
    logic [31:0] ImmExtE1;
    logic [31:0] ImmExtE2;
    logic [31:0] PCPlus8E1;
    logic [31:0] PCPlus8E2;

    decode_to_execute_register decode_to_execute_register_inst (
        // clock & reset
        .clk              (clk),
        .rst1             (FlushExecute1),
        .en1              (~StallExecute1),
        .rst2             (FlushExecute2),
        .en2              (~StallExecute2),

        // control signals from Control.sv
        .RegWriteD1        (RegWriteD1),
        .ResultSrcD1       (ResultSrcD1),
        .MemWriteD1        (MemWriteD1),
        .JumpD1            (JumpD1),
        .BranchD1          (BranchD1),
        .ALUControlD1      (ALUControlD1),
        .ALUSrcAD1         (ALUSrcAD1),
        .ALUSrcBD1         (ALUSrcBD1),
        .AddressingControlD1(AddressingControlD1),
        .BranchTypeD1      (BranchTypeD1),

        .RegWriteD2        (RegWriteD2),
        .ResultSrcD2       (ResultSrcD2),
        .MemWriteD2        (MemWriteD2),
        .JumpD2            (JumpD2),
        .BranchD2          (BranchD2),
        .ALUControlD2      (ALUControlD2),
        .ALUSrcAD2         (ALUSrcAD2),
        .ALUSrcBD2         (ALUSrcBD2),
        .AddressingControlD2(AddressingControlD2),
        .BranchTypeD2      (BranchTypeD2),



        // data signals from reg_file.sv & instructions
        .RD1D             (RD1D),
        .RD2D             (RD2D),
        .RD4D             (RD4D),
        .RD5D             (RD5D),
        .PCD1             (PCD1),
        .PCD2             (PCD2),
        .Rs1D             (Rs1D),
        .Rs2D             (Rs2D),
        .Rs4D             (Rs4D),
        .Rs5D             (Rs5D),
        .RdD1             (RdD1),
        .RdD2             (RdD2),
        .ImmExtD1         (ImmExtD1),
        .ImmExtD2         (ImmExtD2),
        .PCPlus8D1         (PCPlus8D1),
        .PCPlus8D2         (PCPlus8D2),

        // outputs to Execute stage
        .RegWriteE1        (RegWriteE1),
        .ResultSrcE1       (ResultSrcE1),
        .MemWriteE1        (MemWriteE1),
        .JumpE1            (JumpE1),
        .BranchE1          (BranchE1),
        .ALUControlE1      (ALUControlE1),
        .ALUSrcAE1         (ALUSrcAE1),
        .ALUSrcBE1         (ALUSrcBE1),
        .AddressingControlE1(AddressingControlE1),
        .BranchTypeE1      (BranchTypeE1),

        .RegWriteE2        (RegWriteE2),
        .ResultSrcE2       (ResultSrcE2),
        .MemWriteE2        (MemWriteE2),
        .JumpE2            (JumpE2),
        .BranchE2          (BranchE2),
        .ALUControlE2      (ALUControlE2),
        .ALUSrcAE2         (ALUSrcAE2),
        .ALUSrcBE2         (ALUSrcBE2),
        .AddressingControlE2(AddressingControlE2),
        .BranchTypeE2      (BranchTypeE2),

        .RD1E             (RD1E),
        .RD2E             (RD2E),
        .RD4E             (RD4E),
        .RD5E             (RD5E),
        .PCE1             (PCE1),
        .PCE2             (PCE2),
        .Rs1E             (Rs1E),
        .Rs2E             (Rs2E),
        .Rs4E             (Rs4E),
        .Rs5E             (Rs5E),
        .RdE1             (RdE1),
        .RdE2             (RdE2),
        .ImmExtE1         (ImmExtE1),
        .ImmExtE2         (ImmExtE2),
        .PCPlus8E1         (PCPlus8E1),
        .PCPlus8E2         (PCPlus8E2)
    );

// Execute
    logic [31:0] WriteDataE1;
    logic [1:0]  PCSrcE1;
    logic [31:0] ALUResultE1;
    logic [31:0] PCTargetE1;

    logic [31:0] WriteDataE2;
    logic [1:0]  PCSrcE2;
    logic [31:0] ALUResultE2;
    logic [31:0] PCTargetE2;

    execute execute_inst (
        // control signals
        .JumpE1        (JumpE1),
        .BranchE1      (BranchE1),
        .ALUControlE1  (ALUControlE1),
        .ALUSrcAE1     (ALUSrcAE1),
        .ALUSrcBE1     (ALUSrcBE1),
        .BranchTypeE1  (BranchTypeE1),

        .JumpE2        (JumpE2),
        .BranchE2      (BranchE2),
        .ALUControlE2  (ALUControlE2),
        .ALUSrcAE2     (ALUSrcAE2),
        .ALUSrcBE2     (ALUSrcBE2),
        .BranchTypeE2  (BranchTypeE2),

        // data signals
        .ResultW1(ResultW1),
        .ALUResultM1(ALUResultM1),
        .RD1E         (RD1E),
        .RD2E         (RD2E),
        .ForwardAE1    (ForwardAE1),
        .ForwardBE1    (ForwardBE1),
        .PCE1          (PCE1),
        .ImmExtE1      (ImmExtE1),

        .ResultW2(ResultW2),
        .ALUResultM2(ALUResultM2),
        .RD4E         (RD4E),
        .RD5E         (RD5E),
        .ForwardAE2    (ForwardAE2),
        .ForwardBE2    (ForwardBE2),
        .PCE2          (PCE2),
        .ImmExtE2      (ImmExtE2),

        // outputs
        .WriteDataE1   (WriteDataE1),
        .PCSrcE1       (PCSrcE1),
        .ALUResultE1   (ALUResultE1),
        .PCTargetE1    (PCTargetE1),

        .WriteDataE2   (WriteDataE2),
        .PCSrcE2       (PCSrcE2),
        .ALUResultE2   (ALUResultE2),
        .PCTargetE2    (PCTargetE2)

    );

// Execute to Memory Register
    logic RegWriteM1;
    logic [1:0] ResultSrcM1;
    logic MemWriteM1;
    logic [2:0] AddressingControlM1;

    logic RegWriteM2;
    logic [1:0] ResultSrcM2;
    logic MemWriteM2;
    logic [2:0] AddressingControlM2;
    
    logic [31:0] ALUResultM1;
    logic [31:0] WriteDataM1;
    logic [4:0] RdM1;
    logic [31:0] PCPlus8M1;

    logic [31:0] ALUResultM2;
    logic [31:0] WriteDataM2;
    logic [4:0] RdM2;
    logic [31:0] PCPlus8M2;


    execute_to_memory_register execute_to_memory_register_inst (
        // clock
        .clk               (clk),
        .en1               (~StallMemory1),
        .en2               (~StallMemory2),

        // inputs from Execute stage
        .RegWriteE1         (RegWriteE1),
        .ResultSrcE1        (ResultSrcE1),
        .MemWriteE1         (MemWriteE1),
        .AddressingControlE1(AddressingControlE1),

        .RegWriteE2         (RegWriteE2),
        .ResultSrcE2        (ResultSrcE2),
        .MemWriteE2         (MemWriteE2),
        .AddressingControlE2(AddressingControlE2),

        .ALUResultE1        (ALUResultE1),
        .WriteDataE1        (WriteDataE1),
        .RdE1               (RdE1),
        .PCPlus8E1          (PCPlus8E1),

        .ALUResultE2        (ALUResultE2),
        .WriteDataE2        (WriteDataE2),
        .RdE2               (RdE2),
        .PCPlus8E2          (PCPlus8E2),

        // outputs to Memory stage
        .RegWriteM1         (RegWriteM1),
        .ResultSrcM1        (ResultSrcM1),
        .MemWriteM1         (MemWriteM1),
        .AddressingControlM1(AddressingControlM1),

        .RegWriteM2         (RegWriteM2),
        .ResultSrcM2        (ResultSrcM2),
        .MemWriteM2         (MemWriteM2),
        .AddressingControlM2(AddressingControlM2),

        .ALUResultM1        (ALUResultM1),
        .WriteDataM1        (WriteDataM1),
        .RdM1               (RdM1),
        .PCPlus8M1          (PCPlus8M1),


        .ALUResultM2        (ALUResultM2),
        .WriteDataM2        (WriteDataM2),
        .RdM2               (RdM2),
        .PCPlus8M2          (PCPlus8M2)
    );

// Memory
    logic [31:0] ReadDataM1;
    logic [31:0] ReadDataM2;

    memory memory_inst (
        // clock & rst
        .clk              (clk),
        .rst              (rst),
        // inputs from Execute-to-Memory register
        .AddressingControlM1 (AddressingControlM1),
        .AddressingControlM2 (AddressingControlM2),
        .MemWriteM1          (MemWriteM1),
        .MemWriteM2          (MemWriteM2),

        .ALUResultM1         (ALUResultM1),
        .ALUResultM2         (ALUResultM2),
        .WriteDataM1         (WriteDataM1),
        .WriteDataM2         (WriteDataM2),

        // outputs to Memory-to-Writeback register
        .ReadDataM1          (ReadDataM1),
        .ReadDataM2          (ReadDataM2)
    );

// Memory to WriteBack Register
    logic RegWriteW1;
    logic RegWriteW2;
    logic [1:0] ResultSrcW1;
    logic [1:0] ResultSrcW2;

    logic [31:0] ALUResultW1;
    logic [31:0] ReadDataW1;
    logic [4:0] RdW1;
    logic [31:0] PCPlus8W1;

    logic [31:0] ALUResultW2;
    logic [31:0] ReadDataW2;
    logic [4:0] RdW2;
    logic [31:0] PCPlus8W2;

    memory_to_writeback_register memory_to_writeback_register_inst (
        // clock
        .clk        (clk),
        .rst1        (FlushWriteback1),
        .rst2        (FlushWriteback2),
        .en1         (~StallWriteback1),
        .en2         (~StallWriteback2),

        // inputs from Memory stage
        .RegWriteM1  (RegWriteM1),
        .ResultSrcM1 (ResultSrcM1),
        .RegWriteM2  (RegWriteM2),
        .ResultSrcM2 (ResultSrcM2),

        .ALUResultM1 (ALUResultM1),
        .ReadDataM1  (ReadDataM1),
        .RdM1        (RdM1),
        .PCPlus8M1   (PCPlus8M1),

        .ALUResultM2 (ALUResultM2),
        .ReadDataM2  (ReadDataM2),
        .RdM2        (RdM2),
        .PCPlus8M2   (PCPlus8M2),

        // outputs to Writeback stage
        .RegWriteW1  (RegWriteW1),
        .RegWriteW2  (RegWriteW2),
        .ResultSrcW1 (ResultSrcW1),
        .ResultSrcW2 (ResultSrcW2),

        .ALUResultW1 (ALUResultW1),
        .ReadDataW1  (ReadDataW1),
        .RdW1        (RdW1),
        .PCPlus8W1   (PCPlus8W1),

        .ALUResultW2 (ALUResultW2),
        .ReadDataW2  (ReadDataW2),
        .RdW2        (RdW2),
        .PCPlus8W2   (PCPlus8W2)
    );

// WriteBack
    logic [31:0] ResultW1;
    logic [31:0] ResultW2;

    writeback writeback_inst (
        .ALUResultW1 (ALUResultW1),
        .ReadDataW1  (ReadDataW1),
        .PCPlus8W1   (PCPlus8W1),
        .ResultSrcW1 (ResultSrcW1),

        .ALUResultW2 (ALUResultW2),
        .ReadDataW2  (ReadDataW2),
        .PCPlus8W2   (PCPlus8W2),
        .ResultSrcW2 (ResultSrcW2),
        
        .ResultW1    (ResultW1),
        .ResultW2    (ResultW2)
    );

// Hazard Unit
    logic [1:0] ForwardAE1; //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback stage, 10 means forwarding of result from ALU in memory stage
    logic [1:0] ForwardBE1;  //these are select inputs for muxes

    logic [1:0] ForwardAE2; //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback stage, 10 means forwarding of result from ALU in memory stage
    logic [1:0] ForwardBE2;  //these are select inputs for muxes

    logic StallDecode1;
    logic StallFetch1;
    logic StallExecute1;
    logic StallMemory1;
    logic StallWriteback1;
    logic FlushExecute1;
    logic FlushDecode1;
    logic FlushWriteback1;

    logic StallDecode2;
    logic StallFetch2;
    logic StallExecute2;
    logic StallMemory2;
    logic StallWriteback2;
    logic FlushExecute2;
    logic FlushDecode2;
    logic FlushWriteback2;
    logic BranchIn1;
    logic BranchIn2;

    hazard_unit hazard_unit_inst (
        // inputs from Decode & Execute stage
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .Rs4E        (Rs4E),
        .Rs5E        (Rs5E),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .Rs4D        (Rs4D),
        .Rs5D        (Rs5D),
        .RdM1         (RdM1),
        .RdM2         (RdM2),
        .RdW1         (RdW1),
        .RdW2         (RdW2),
        .RdE1         (RdE1),
        .RdE2         (RdE2),
        .RegWriteW1   (RegWriteW1),
        .RegWriteM1   (RegWriteM1),
        .RegWriteW2   (RegWriteW2),
        .RegWriteM2   (RegWriteM2),

        .ResultSrcE1  (ResultSrcE1),
        .ResultSrcE2  (ResultSrcE2),
        .PCSrcE1      (PCSrcE1),
        .PCSrcE2      (PCSrcE2),

        // outputs to control forwarding & stalling
        .ForwardAE1   (ForwardAE1),
        .ForwardBE1   (ForwardBE1),
        .ForwardAE2   (ForwardAE2),
        .ForwardBE2   (ForwardBE2),

        .StallDecode1 (StallDecode1),
        .StallDecode2 (StallDecode2),
        .StallFetch1  (StallFetch1),
        .StallFetch2  (StallFetch2),
        .StallExecute1 (StallExecute1),
        .StallExecute2 (StallExecute2),
        .StallMemory1 (StallMemory1),
        .StallMemory2 (StallMemory2),
        .StallWriteback1 (StallWriteback1),
        .StallWriteback2 (StallWriteback2),
        .FlushExecute1 (FlushExecute1),
        .FlushExecute2 (FlushExecute2),
        .FlushDecode1 (FlushDecode1),
        .FlushDecode2 (FlushDecode2),
        .FlushWriteback1 (FlushWriteback1),
        .FlushWriteback2 (FlushWriteback2),

        .BranchIn1(BranchIn1),
        .BranchIn2 (BranchIn2)
    );


endmodule
