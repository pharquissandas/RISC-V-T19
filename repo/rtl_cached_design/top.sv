module top (
    input logic clk,
    input logic rst,
    
    output logic [31:0] a0
);

// Fetch

    logic [31:0] InstrF;
    logic [31:0] PCF;
    logic [31:0] PCPlus4F;

    fetch fetch_inst (
        .clk(clk),
        .rst(rst),
        .en(~StallFetch),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ALUResultE(ALUResultE),
        
        .InstrF(InstrF),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F)
    );

// F2D
    
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;
    logic [31:0] InstrD;

    fetch_to_decode_register fetch_to_decode_register_inst(
        .clk(clk),
        .en(~StallDecode),
        .rst(FlushDecode),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F),
        .InstrF(InstrF),

        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .InstrD(InstrD)
    );

// Decode

    logic [31:0] RD1D; //regfile output 1
    logic [31:0] RD2D; //regfile output 2
    logic [31:0] ImmExtD;

    logic [4:0] Rs1D;
    logic [4:0] Rs2D;
    logic [4:0] RdD;

    logic        RegWriteD;
    logic [1:0]  ResultSrcD;
    logic        MemWriteD;
    logic [1:0]  JumpD;
    logic        BranchD;
    logic [2:0]  BranchTypeD;
    logic [3:0]  ALUControlD;
    logic        ALUSrcBD;
    logic        ALUSrcAD;
    logic [2:0]  AddressingControlD;



    

    decode decode_inst (
        .clk(clk),
        .InstrD(InstrD),
        .ResultW(ResultW),
        .RdW(RdW),
        .RegWriteW(RegWriteW),

        .RD1D(RD1D),
        .RD2D(RD2D),
        .ImmExtD(ImmExtD),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdD(RdD),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .BranchTypeD(BranchTypeD),
        .ALUControlD(ALUControlD),
        .ALUSrcAD(ALUSrcAD),
        .ALUSrcBD(ALUSrcBD),
        .AddressingControlD(AddressingControlD),
        .a0(a0)
    );

// D2E

    logic RegWriteE;
    logic [1:0] ResultSrcE;
    logic MemWriteE;
    logic [1:0] JumpE;
    logic BranchE;
    logic [3:0] ALUControlE;
    logic ALUSrcAE;
    logic ALUSrcBE;
    logic [2:0] AddressingControlE;
    logic [2:0] BranchTypeE;

    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] PCE;
    logic [4:0] Rs1E;
    logic [4:0] Rs2E;
    logic [4:0] RdE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4E;

    decode_to_execute_register decode_to_execute_register_inst (
        // clock & reset
        .clk              (clk),
        .rst              (FlushExecute),
        .en               (~StallExecute),

        // control signals from Control.sv
        .RegWriteD        (RegWriteD),
        .ResultSrcD       (ResultSrcD),
        .MemWriteD        (MemWriteD),
        .JumpD            (JumpD),
        .BranchD          (BranchD),
        .ALUControlD      (ALUControlD),
        .ALUSrcAD         (ALUSrcAD),
        .ALUSrcBD         (ALUSrcBD),
        .AddressingControlD(AddressingControlD),
        .BranchTypeD      (BranchTypeD),

        // data signals from reg_file.sv & instructions
        .RD1D             (RD1D),
        .RD2D             (RD2D),
        .PCD              (PCD),
        .Rs1D             (Rs1D),
        .Rs2D             (Rs2D),
        .RdD              (RdD),
        .ImmExtD          (ImmExtD),
        .PCPlus4D         (PCPlus4D),

        // outputs to Execute stage
        .RegWriteE        (RegWriteE),
        .ResultSrcE       (ResultSrcE),
        .MemWriteE        (MemWriteE),
        .JumpE            (JumpE),
        .BranchE          (BranchE),
        .ALUControlE      (ALUControlE),
        .ALUSrcAE         (ALUSrcAE),
        .ALUSrcBE         (ALUSrcBE),
        .AddressingControlE(AddressingControlE),
        .BranchTypeE      (BranchTypeE),

        .RD1E             (RD1E),
        .RD2E             (RD2E),
        .PCE              (PCE),
        .Rs1E             (Rs1E),
        .Rs2E             (Rs2E),
        .RdE              (RdE),
        .ImmExtE          (ImmExtE),
        .PCPlus4E         (PCPlus4E)
    );

// Execute

    logic [31:0] WriteDataE;
    logic [1:0]  PCSrcE;
    logic [31:0] ALUResultE;
    logic [31:0] PCTargetE;

    execute execute_inst (
        // control signals
        .JumpE        (JumpE),
        .BranchE      (BranchE),
        .ALUControlE  (ALUControlE),
        .ALUSrcAE     (ALUSrcAE),
        .ALUSrcBE     (ALUSrcBE),
        .BranchTypeE  (BranchTypeE),

        // data signals
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .RD1E         (RD1E),
        .RD2E         (RD2E),
        .ForwardAE    (ForwardAE),
        .ForwardBE    (ForwardBE),
        .PCE          (PCE),
        .ImmExtE      (ImmExtE),

        // outputs
        .WriteDataE   (WriteDataE),
        .PCSrcE       (PCSrcE),
        .ALUResultE   (ALUResultE),
        .PCTargetE    (PCTargetE)
    );

// E2M

    logic RegWriteM;
    logic [1:0] ResultSrcM;
    logic MemWriteM;
    logic [2:0] AddressingControlM;
    
    logic [31:0] ALUResultM;
    logic [31:0] WriteDataM;
    logic [4:0] RdM;
    logic [31:0] PCPlus4M;

    execute_to_memory_register execute_to_memory_register_inst (
        // clock
        .clk               (clk),
        .en                (~StallMemory),

        // inputs from Execute stage
        .RegWriteE         (RegWriteE),
        .ResultSrcE        (ResultSrcE),
        .MemWriteE         (MemWriteE),
        .AddressingControlE(AddressingControlE),

        .ALUResultE        (ALUResultE),
        .WriteDataE        (WriteDataE),
        .RdE               (RdE),
        .PCPlus4E          (PCPlus4E),

        // outputs to Memory stage
        .RegWriteM         (RegWriteM),
        .ResultSrcM        (ResultSrcM),
        .MemWriteM         (MemWriteM),
        .AddressingControlM(AddressingControlM),

        .ALUResultM        (ALUResultM),
        .WriteDataM        (WriteDataM),
        .RdM               (RdM),
        .PCPlus4M          (PCPlus4M)
    );

// Memory

    logic [31:0] ReadDataM;
    logic CacheStall;

    memory memory_inst (
        // clock & rst
        .clk              (clk),
        .rst              (rst),
        // inputs from Execute-to-Memory register
        .AddressingControlM (AddressingControlM),
        .MemWriteM          (MemWriteM),

        .ALUResultM         (ALUResultM),
        .WriteDataM         (WriteDataM),

        .CacheStall         (CacheStall),
        // outputs to Memory-to-Writeback register
        .ReadDataM          (ReadDataM)
    );

// M2W

    logic RegWriteW;
    logic [1:0] ResultSrcW;

    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [4:0] RdW;
    logic [31:0] PCPlus4W;

    memory_to_writeback_register memory_to_writeback_register_inst (
        // clock
        .clk        (clk),
        .rst        (FlushWriteback),

        // inputs from Memory stage
        .RegWriteM  (RegWriteM),
        .ResultSrcM (ResultSrcM),

        .ALUResultM (ALUResultM),
        .ReadDataM  (ReadDataM),
        .RdM        (RdM),
        .PCPlus4M   (PCPlus4M),

        // outputs to Writeback stage
        .RegWriteW  (RegWriteW),
        .ResultSrcW (ResultSrcW),

        .ALUResultW (ALUResultW),
        .ReadDataW  (ReadDataW),
        .RdW        (RdW),
        .PCPlus4W   (PCPlus4W)
    );

// WriteBack

    logic [31:0] ResultW;

    writeback writeback_inst (
        .ALUResultW (ALUResultW),
        .ReadDataW  (ReadDataW),
        .PCPlus4W   (PCPlus4W),
        .ResultSrcW (ResultSrcW),
        .ResultW    (ResultW)
    );

// Hazard Unit

    logic [1:0] ForwardAE; //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback stage, 10 means forwarding of result from ALU in memory stage
    logic [1:0] ForwardBE;  //these are select inputs for muxes

    logic StallDecode;
    logic StallFetch;
    logic StallExecute;
    logic StallMemory;
    logic FlushExecute;
    logic FlushDecode;
    logic FlushWriteback;

    hazard_unit hazard_unit_inst (
        // inputs from Decode & Execute stage
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .Rs1D        (Rs1D),
        .Rs2D        (Rs2D),
        .RdM         (RdM),
        .RdW         (RdW),
        .RdE         (RdE),
        .RegWriteW   (RegWriteW),
        .RegWriteM   (RegWriteM),

        .ResultSrcE  (ResultSrcE),
        .PCSrcE      (PCSrcE),
        .CacheStall  (CacheStall),
        // outputs to control forwarding & stalling
        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE),

        .StallDecode (StallDecode),
        .StallFetch  (StallFetch),
        .StallExecute(StallExecute),
        .StallMemory (StallMemory),
        .FlushExecute(FlushExecute),
        .FlushDecode (FlushDecode),
        .FlushWriteback (FlushWriteback)
    );



endmodule
