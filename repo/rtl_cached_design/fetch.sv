module fetch(
    input logic clk,
    input logic rst,
    input logic en,
    input logic [1:0] PCSrcE,
    input logic [31:0] PCTargetE,
    input logic [31:0] ALUResultE,
    input logic pc_redirect_i,
    input logic [31:0] mispredict_target_pc_i,
    input logic pc_predict_redirect_i,
    input logic [31:0] predicted_target_pc_i,

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
        .pc_redirect_i(pc_redirect_i),
        .mispredict_target_pc_i(mispredict_target_pc_i),
        .pc_predict_redirect_i(pc_predict_redirect_i),
        .predicted_target_pc_i(predicted_target_pc_i),
        .PCPlus4F(PCPlus4F),
        .PCF(PCF)
    );

    instr_mem instr_mem_inst(
        .A(PCF),
        .RD(InstrF)
    );
endmodule
