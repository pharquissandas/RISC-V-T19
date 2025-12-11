module fetch(
    input logic clk,
    input logic rst,
    input logic en1,
    input logic en2,
    input logic [1:0] PCSrcE1,
    input logic [31:0] PCTargetE1,
    input logic [31:0] ALUResultE1,
    input logic [1:0] PCSrcE2,
    input logic [31:0] PCTargetE2,
    input logic [31:0] ALUResultE2,

    input logic BranchIn1,
    input logic BranchIn2,

    
    output logic [31:0] InstrF1,
    output logic [31:0] InstrF2,
    output logic [31:0] PCF1,
    output logic [31:0] PCPlus8F1,
    output logic [31:0] PCF2,
    output logic [31:0] PCPlus8F2
);

    always_comb begin
        PCF1 = PCF1_IN;
        PCF2 = PCF2_IN;
    end


    logic  [31:0] PCF1_IN; //internal signal
    logic  [31:0] PCF2_IN; //internal signal

    pc_spsc pc_spsc_inst(
        .clk(clk),
        .rst(rst),
        .en1(en1),
        .en2(en2),
        .PCSrcE1(PCSrcE1),
        .ALUResultE1(ALUResultE1),
        .PCTargetE1(PCTargetE1),
        .PCSrcE2(PCSrcE2),
        .ALUResultE2(ALUResultE2),
        .PCTargetE2(PCTargetE2),
        .StallPipeline2(StallPipeline2),
        .StallPipeline1NC(StallPipeline1NC),
        .BranchIn1(BranchIn1),
        .BranchIn2(BranchIn2),

        .PCF1(PCF1_IN),
        .PCF2(PCF2_IN),
        .PCPlus8F1(PCPlus8F1),
        .PCPlus8F2(PCPlus8F2)
    );

    instr_mem instr_mem_inst(
        .A1(PCF1_IN),
        .A2(PCF2_IN),

        .RD1(InstrF1),
        .RD2(InstrF2)
    );


endmodule
