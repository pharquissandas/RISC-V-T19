module execute(
    input logic [1:0]  JumpE1,
    input logic        BranchE1,
    input logic [3:0]  ALUControlE1,
    input logic        ALUSrcAE1,
    input logic        ALUSrcBE1,
    input logic [2:0]  BranchTypeE1,
    input logic [1:0]  JumpE2,
    input logic        BranchE2,
    input logic [3:0]  ALUControlE2,
    input logic        ALUSrcAE2,
    input logic        ALUSrcBE2,
    input logic [2:0]  BranchTypeE2,


    input logic [31:0] ResultW1,
    input logic [31:0] ALUResultM1,
    input logic [31:0] ResultW2,
    input logic [31:0] ALUResultM2,
    input logic [31:0] RD1E,
    input logic [31:0] RD2E,
    input logic [31:0] RD4E,
    input logic [31:0] RD5E,

    input logic [1:0] ForwardAE1,
    input logic [1:0] ForwardBE1,
    input logic [1:0] ForwardAE2,
    input logic [1:0] ForwardBE2,

    input logic [31:0] PCE1,
    input logic [31:0] PCE2,
    input logic [31:0] ImmExtE1,
    input logic [31:0] ImmExtE2,

    output logic [31:0] WriteDataE1,
    output logic [1:0]  PCSrcE1,
    output logic [31:0] ALUResultE1,
    output logic [31:0] PCTargetE1,
    output logic [31:0] WriteDataE2,
    output logic [1:0]  PCSrcE2,
    output logic [31:0] ALUResultE2,
    output logic [31:0] PCTargetE2

);

    logic ZeroE1;
    logic ZeroE2;
    logic [31:0] SrcB1, SrcA1, SrcB2, SrcA2;
    logic [31:0] SrcBE1, SrcAE1, SrcAE2,SrcBE2;

    always_comb begin
        case (ForwardAE1)
            2'b00: SrcA1 = RD1E;
            2'b01: SrcA1 = ResultW1;
            2'b10: SrcA1 = ALUResultM1;
            default: SrcA1 = RD1E;
        endcase

        case (ForwardBE1)
            2'b00: SrcB1 = RD2E;
            2'b01: SrcB1 = ResultW1;
            2'b10: SrcB1 = ALUResultM1;
            default: SrcB1 = RD2E;
        endcase

        SrcAE1 = ALUSrcAE1 ? PCE1 : SrcA1;
        SrcBE1 = ALUSrcBE1 ? ImmExtE1 : SrcB1;

        PCTargetE1  = PCE1 + ImmExtE1;
    
        WriteDataE1 = SrcB1;
    end

    always_comb begin
        case (ForwardAE2)
            2'b00: SrcA2 = RD4E;
            2'b01: SrcA2 = ResultW2;
            2'b10: SrcA2 = ALUResultM2;
            default: SrcA2 = RD4E;
        endcase

        case (ForwardBE2)
            2'b00: SrcB2 = RD5E;
            2'b01: SrcB2 = ResultW2;
            2'b10: SrcB2 = ALUResultM2;
            default: SrcB2 = RD5E;
        endcase

        SrcAE2 = ALUSrcAE2 ? PCE2 : SrcA2;
        SrcBE1 = ALUSrcBE2 ? ImmExtE2 : SrcB2;

        PCTargetE2  = PCE2 + ImmExtE2;
    
        WriteDataE2 = SrcB2;
    end

    alu alu_inst1 (
        .SrcA (SrcAE1),
        .SrcB (SrcBE1),
        .ALUControl (ALUControlE1),
        
        .ALUResult (ALUResultE1),
        .Zero (ZeroE1)
    );

    alu alu_inst2(
        .SrcA(SrcAE2),
        .SrcB(SrcBE2),
        .ALUControl(ALUControlE2),

        .ALUResult(ALUResultE2),
        .Zero(ZeroE2)

    );

    pcsrc_unit pcsrc_unit_inst1 (
        .Jump (JumpE1),
        .Branch (BranchE1),
        .Zero(ZeroE1),
        .BranchType (BranchTypeE1),
        
        .PCSrc (PCSrcE1)
    );

    pcsrc_unit pcsrc_unit_inst2 (
        .Jump (JumpE2),
        .Branch (BranchE2),
        .Zero(ZeroE2),
        .BranchType (BranchTypeE2),
        
        .PCSrc (PCSrcE2)
    );


endmodule
