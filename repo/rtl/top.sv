module top (
    input  logic clk,
    input  logic rst,
    output logic [31:0] a0
);

    // Control signals
    logic [1:0] PCSrcE;
    logic       RegWrite;
    logic [3:0] ALUControl;
    logic       ALUSrcA;
    logic       ALUSrcB;
    logic       MemWrite;
    logic [1:0] ResultSrc;
    logic [2:0] ImmSrc;
    logic [2:0] AddressingControl;

    // Datapath outputs
    logic        Zero;
    logic [31:0] InstrF;
    logic [31:0] InstrD;
    logic [31:0] PCTargetE;
    logic [31:0] ALUResultE;
    logic [31:0] PCF;
    logic [31:0] PCD;
    logic [31:0] PCPlus4F;
    logic [31:0] PCPlus4D;
    logic [31:0] ResultW;
    logic        RdW;
    logic        RegWriteW;
    logic [31:0] RD1D;
    logic [31:0] RD2D;
    logic [31:0] ImmExtD;
    logic [4:0]  Rs1D;
    logic [4:0]  Rs2D;
    logic [4:0]  RdD;
    logic        RegWriteD;
    logic        ResultSrcD;
    logic        MemWriteD;
    logic [1:0]  JumpD;
    logic        BranchD;
    logic [2:0]  BranchTypeD;
    logic [3:0]  ALUControlD;
    logic        ALUSrcBD;
    logic        ALUSrcAD;
    logic [2:0]  AddressingControlD;
    logic        RegWriteE;
    logic [1:0] ResultSrcE;
    logic MemWriteE;
    logic [1:0] JumpE;
    logic BranchE;
    logic [3:0] ALUControlE;
    logic ALUSrcAE;
    logic ALUSrcBE;
    logic [31:0] SrcAE;
    logic [2:0] ImmSrcE;
    logic [2:0] AddressingControlE;
    logic [2:0] BranchTypeE;

    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] PCE;
    logic [4:0] Rs1E;
    logic [4:0] Rs2E;
    logic [4:0] RdE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4;




    logic RegWriteM;
    logic [1:0] ResultSrcM;
    logic MemWriteM;
    logic [2:0] AddressingControlM;
    logic [31:0] ALUResultM;
    logic WriteDataM;
    logic [4:0] RdM;
    logic [31:0] PCPlus4M;
    logic [31:0] RDM;


    logic [1:0] ResultSrcW;

    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;

    logic [31:0] PCPlus4W;


    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;

    logic [31:0] WriteDataE;
    logic [2:0] ImmSrcD;


    fetch fetch1(

        .clk(clk),
        .rst(rst),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .ALUResultE(ALUResultE),

        .InstrF(InstrF),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F)
    );

    fetch_to_decode_register ftdr(

        .clk(clk),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F),
        .InstrF(InstrF),


        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .InstrD(InstrD)

    );

    decode decode1(
        
        .clk(clk),
        .InstrD(InstrD),
        .WD3(ResultW),
        .A3(RdW),
        .WE3(RegWriteW),

        .RD1(RD1D),
        .RD2(RD2D),
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
        .ALUSrcBD(ALUSrcBD),
        .ALUSrcAD(ALUSrcAD),
        .AddressingControlD(AddressingControlD),
        .a0D(a0),
        .ImmSrcD(ImmSrcD)

    );

    decode_to_execute_register dter(

        .clk(clk),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcAD(ALUSrcAD),
        .ALUSrcBD(ALUSrcBD),
        .ImmSrcD(ImmSrcD),
        .AddressingControlD(AddressingControlD),
        .BranchTypeD(BranchTypeD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .PCD(PCD),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdD(RdD),
        .ImmExtD(ImmExtD),
        .PCPlus4D(PCPlus4D),

        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ImmSrcE(ImmSrcE),
        .AddressingControlE(AddressingControlE),
        .BranchTypeE(BranchTypeE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E)

    );



    execute execute1(

        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcAE(ALUSrcBE),
        .ALUSrcBE(ALUSrcBE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .ImmExtE(ImmExtE),
        .SrcAE(SrcAE),
        .WriteDataE(WriteDataE),
        .BranchTypeE(BranchTypeE),

        .PCSrcE(PCSrcE),
        .ALUResultE(ALUResultE),
        .PCTargetE(PCTargetE)

    );

    execute_to_memory_register etmr(

        .clk(clk),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .AddressingControlE(AddressingControlE),
        .ALUResultE(ALUResultE),
        .WriteDataE(WriteDataE),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),

        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .AddressingControlM(AddressingControlM),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .RdM(RdM),
        .PCPlus4M(PCPlus4M)

    );


    memory memory1(

        .clk(clk),
        .MemWriteM(MemWriteM),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .AddressingControlM(AddressingControlM),

        .RDM(RDM)

    );

    memory_to_writeback_register mtwr(

        .clk(clk),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .ALUResultM(ALUResultM),
        .ReadDataM(RDM),
        .RdM(RdM),
        .PCPlus4M(PCPlus4M),

        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW),
        .PCPlus4W(PCPlus4W)

    );

    writeback writeback1(

        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .PCPlus4W(PCPlus4W),
        .ResultSrcW(ResultSrcW),

        .ResultW(ResultW)

    );

    hazard_unit_top hazard_unit_top1(

        .Rs1E(Rs1E),
        .Rs2E,
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .RegWriteM(RegWriteM),
        .ALUResultM(ALUResultM),
        .ResultW(ResultW),
        .RD1E(RD1E),
        .RD2E(RD2E),

        .SrcAE(SrcAE),
        .WriteDataE(WriteDataE)

    );

endmodule
