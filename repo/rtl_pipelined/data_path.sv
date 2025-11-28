module data_path (
    input logic clk,
    input logic rst,

    input logic [1:0] PCSrc,
    input logic RegWrite,
    input logic [3:0] ALUControl,
    input logic ALUSrcA,
    input logic ALUSrcB,
    input logic MemWrite,
    input logic [1:0] ResultSrc,
    input logic [2:0] ImmSrc,
    input logic [2:0] AddressingControl,
    
    output logic [31:0] Instr,
    output logic        Zero,
    output logic [31:0] a0
);

    logic [31:0] PC, PCPlus4, ImmExt, MemData, ALUResult, SrcA, SrcB, ReadData1, ReadData2, ResultData;

    assign SrcA = ALUSrcA ? PC : ReadData1;
    assign SrcB = ALUSrcB ? ImmExt : ReadData2;

    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .PCSrc(PCSrc),
        .ImmExt(ImmExt),
        .ALUResult(ALUResult),
        .PCPlus4(PCPlus4),
        .PC(PC)
    );

    alu alu_inst(
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    instr_mem instr_mem_inst(
        .A(PC),
        .RD(Instr)
    );

    data_mem data_mem_inst(
        .clk(clk),
        .WE(MemWrite),
        .A(ALUResult),
        .WD(ReadData2),
        .AddressingControl(AddressingControl),
        .RD(MemData)
    );

    reg_file reg_file_inst(
        .clk(clk),
        .AD1(Instr[19:15]),
        .AD2(Instr[24:20]),
        .AD3(Instr[11:7]),
        .WD3(ResultData),
        .WE3(RegWrite),
        .RD1(ReadData1),
        .RD2(ReadData2),
        .a0(a0)
    );

    sign_ext sign_ext_inst(
        .Imm(Instr[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );
    
    always_comb begin
        case (ResultSrc)
            2'b00: ResultData = ALUResult;
            2'b01: ResultData = MemData;
            2'b10: ResultData = PCPlus4;
            default: ResultData = 32'b0;
        endcase
    end

    
endmodule
