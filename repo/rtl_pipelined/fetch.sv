module fetch(

    input logic        clk,
    input logic        rst,
    input logic        en,
    input logic [1:0]  PCSrcE,
    input logic [31:0] PCTargetE,
    input logic [31:0] ALUResultE,


    output logic [31:0] InstrF,
    output logic [31:0] PCF,
    output logic [31:0] PCPlus4F

);

    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .en(en),
        .PCSrcE(PCSrcE),
        .ALUResultE(ALUResultE),
        .PCTargetE(PCTargetE),
        .PCPlus4F(PCPlus4F),
        .PCF(PCF)

    );


    instr_mem instr_mem_inst(
        .A(PCF),
        .RD(InstrF)
    );


endmodule
