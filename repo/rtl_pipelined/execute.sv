module execute(

    input logic [1:0]  JumpE,
    input logic        BranchE,
    input logic [3:0]  ALUControlE,
    input logic        ALUSrcAE,
    input logic        ALUSrcBE,
    input logic [2:0]  BranchTypeE,

    input logic [31:0] ResultW,
    input logic [31:0] ALUResultM,
    input logic [31:0] RD1E,
    input logic [31:0] RD2E,

    input logic [1:0] ForwardAE,
    input logic [1:0] ForwardBE,

    input logic [31:0] PCE,
    input logic [31:0] ImmExtE,

    output logic [31:0] WriteDataE,
    output logic [1:0]  PCSrcE,
    output logic [31:0] ALUResultE,
    output logic [31:0] PCTargetE

);

    logic ZeroE;
    logic [31:0] SrcB, SrcA;
    logic [31:0] SrcBE, SrcAE;

    always_comb begin


        case (ForwardAE)
            2'b00: SrcA = RD1E;
            2'b01: SrcA = ResultW;
            2'b10: SrcA = ALUResultM;
            default: SrcA = RD1E;
        endcase

        case (ForwardBE)
            2'b00: SrcB = RD2E;
            2'b01: SrcB = ResultW;
            2'b10: SrcB = ALUResultM;
            default: SrcB = RD2E;
        endcase

        SrcAE = ALUSrcAE ? PCE : SrcA;
        SrcBE = ALUSrcBE ? ImmExtE : SrcB;

        PCTargetE  = PCE + ImmExtE;
        WriteDataE = SrcB;
    end

    alu alu_inst (
        .SrcA (SrcAE),
        .SrcB (SrcBE),
        .ALUControl (ALUControlE),
        .ALUResult (ALUResultE),
        .Zero (ZeroE)
    );

    pcsrc_unit pcsrc_unit_inst (
        .Jump (JumpE),
        .Branch (BranchE),
        .Zero(ZeroE),
        .BranchType (BranchTypeE),
        .PCSrc (PCSrcE)
    );

endmodule
