module decode_to_execute_register(

    input logic clk,
    input logic RegWriteD,
    input logic [1:0] ResultSrcD,
    input logic MemWriteD,
    input logic [1:0] JumpD,
    input logic BranchD,
    input logic [3:0] ALUControlD,
    input logic ALUSrcAD,
    input logic ALUSrcBD,
    input logic [2:0] ImmSrcD,
    input logic [2:0] AddressingControlD,
    input logic [2:0] BranchTypeD,

    input logic [31:0] RD1D,
    input logic [31:0] RD2D,
    input logic [31:0] PCD,
    input logic [4:0] Rs1D,
    input logic [4:0] Rs2D,
    input logic [4:0] RdD,
    input logic [31:0] ImmExtD,
    input logic [31:0] PCPlus4D,

    output logic RegWriteE,
    output logic [1:0] ResultSrcE,
    output logic MemWriteE,
    output logic [1:0] JumpE,
    output logic BranchE,
    output logic [3:0] ALUControlE,
    output logic ALUSrcAE,
    output logic ALUSrcBE,
    output logic [2:0] ImmSrcE,
    output logic [2:0] AddressingControlE,
    output logic [2:0] BranchTypeE,

    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] PCE,
    output logic [4:0] Rs1E,
    output logic [4:0] Rs2E,
    output logic [4:0] RdE,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCPlus4E
);
    always_ff @(posedge clk) begin
        RegWriteE          <= RegWriteD;
        ResultSrcE         <= ResultSrcD;
        MemWriteE          <= MemWriteD;
        JumpE              <= JumpD;
        BranchE            <= BranchD;
        ALUControlE        <= ALUControlD;
        ALUSrcAE           <= ALUSrcAD;
        ALUSrcBE           <= ALUSrcBD;
        ImmSrcE            <= ImmSrcD;
        AddressingControlE <= AddressingControlD;
        BranchTypeE        <= BranchTypeD;

        RD1E        <= RD1D;
        RD2E        <= RD2D;
        PCE         <= PCD;
        Rs1E        <= Rs1D;
        Rs2E        <= Rs2D;
        RdE         <= RdD;
        ImmExtE     <= ImmExtD;
        PCPlus4E    <= PCPlus4D;
    end

endmodule
