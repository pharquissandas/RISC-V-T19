module memory (
    input logic clk,
    input logic rst,
    
    input logic [2:0] AddressingControlM1,
    input logic [2:0] AddressingControlM2,
    input logic MemWriteM1,
    input logic MemWriteM2,

    input logic [31:0] ALUResultM1,
    input logic [31:0] ALUResultM2,
    input logic [31:0] WriteDataM1,
    input logic [31:0] WriteDataM2,

    output logic [31:0] ReadDataM1,
    output logic [31:0] ReadDataM2

);

    data_mem data_mem_inst(

        .clk(clk),
        .A1(ALUResultM1),
        .A2(ALUResultM2),
        .WE1(MemWriteM1),
        .WE2(MemWriteM2),
        .WD1(WriteDataM1),
        .WD2(WriteDataM2),
        .AddressingControl1(AddressingControlM1),
        .AddressingControl2(AddressingControlM2),

        .RD1(ReadDataM1),
        .RD2(ReadDataM2)

    );



endmodule
