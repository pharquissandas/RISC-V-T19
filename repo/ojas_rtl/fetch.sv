module fetch(

    input logic        clk,
    input logic        rst,
    input logic [1:0]  PCSrcE,
    input logic [31:0] PCTargetE,
    input logic [31:0] ALUResultE,


    output logic [31:0] InstrF,
    output logic [31:0] PCF,
    output logic [31:0] PCPlus4F

);

assign PCF = PCCurr;

logic [31:0] PCCurr;


pc_pipeline pc_inst(

    .clk(clk),
    .rst(rst),
    .PCSrc(PCSrcE),
    .ALUResult(ALUResultE),
    .PCTarget(PCTargetE),
    .PCPlus4(PCPlus4F),
    .PC(PCCurr)

);


instr_mem instr_mem1(

    .A(PCCurr),

    .RD(InstrF)

);


endmodule
