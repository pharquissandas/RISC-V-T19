module fetch(

    input logic        clk,
    input  logic       rst,

    input logic PCSrcE,
        
    /* verilator lint_off UNUSED */
    input  logic [31:0]    ALUResultE,
    /* verilator lint_on UNUSED */

    input logic [31:0] PCE,
    input logic [31:0] ImmExtE, //immediate offset for branch target
    input logic [31:0] PCPlus4F,

    output logic [31:0] RD


);


pc pc_inst(

    .clk(clk),
    .rst(rst),
    .PCSrc(PCSrcE),
    .PCPlus4(PCPlus4F),
    .ImmExt(ImmExtE),
    .ALUResult(ALUResultE)
    .PC()




);


mux pcfmux();






endmodule
