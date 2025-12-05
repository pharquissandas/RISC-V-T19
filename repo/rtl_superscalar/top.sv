module top (
    input logic clk,
    input logic rst,
    output logic [31:0] a0
);
    logic predict_taken_F;
    logic predict_taken_D;
    logic pc_predict_redirect_D;
    logic [31:0] predicted_target_pc_D;
    logic branch_mispredict_E;
    logic execute_is_branch_E;
    logic execute_branch_taken_E;
    logic [31:0] mispredict_target_pc_E;
    logic pc_redirect_H;

    logic predict_taken_E;

    logic [31:0] InstrF;
    logic [31:0] PCF;
    logic [31:0] PCPlus4F;

// Branch Predictor
    branch_predictor bht_inst (
        .clk(clk),
        .rst(rst),
        .fetch_pc_i(PCF),
        .predict_taken_o(predict_taken_F),
        .execute_pc_i(PCE),
        .execute_is_branch_i(execute_is_branch_E),
        .execute_branch_taken_i(execute_branch_taken_E)
    );

// Fetch
    fetch fetch_inst (
        .clk(clk),
        .rst(rst),
        .en(~StallFetch),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ALUResultE(ALUResultE),

        .pc_redirect_i(pc_redirect_H),
        .mispredict_target_pc_i(mispredict_target_pc_E),
        .pc_predict_redirect_i(pc_predict_redirect_D),
        .predicted_target_pc_i(predicted_target_pc_D),
        
        .InstrF(InstrF),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F)
    );

// Fetch to Decode Register
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
        .predict_taken_F(predict_taken_F),

        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .InstrD(InstrD),
        .predict_taken_D(predict_taken_D)
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

        .PCD(PCD),
        .predict_taken_D(predict_taken_D),

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
        .a0(a0),

        .pc_predict_redirect_D(pc_predict_redirect_D),
        .predicted_target_pc_D(predicted_target_pc_D)
    );

// Decode to Execute Register
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

        .predict_taken_D(predict_taken_D),

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

        .predict_taken_E(predict_taken_E),

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

        .predict_taken_i(predict_taken_E),

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
        .PCTargetE    (PCTargetE),

        .branch_mispredict_o(branch_mispredict_E),
        .execute_is_branch_o(execute_is_branch_E),
        .execute_branch_taken_o(execute_branch_taken_E),
        .mispredict_target_pc_o(mispredict_target_pc_E)
    );

// Execute to Memory Register
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

// Memory to WriteBack Register
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
        .en         (~StallWriteback),

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
    logic StallWriteback;
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

        .branch_mispredict_i(branch_mispredict_E),

        // outputs to control forwarding & stalling
        .ForwardAE   (ForwardAE),
        .ForwardBE   (ForwardBE),

        .StallDecode (StallDecode),
        .StallFetch  (StallFetch),
        .StallExecute(StallExecute),
        .StallMemory (StallMemory),
        .StallWriteback (StallWriteback),
        .FlushExecute(FlushExecute),
        .FlushDecode (FlushDecode),
        .FlushWriteback (FlushWriteback),

        .pc_redirect_o(pc_redirect_H)
    );
endmodule
