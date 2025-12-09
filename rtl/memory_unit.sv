module memory (
    input logic clk,
    
    input logic [2:0] AddressingControlM,
    input logic MemWriteM,

    input logic [31:0] ALUResultM,
    input logic [31:0] WriteDataM,

    output logic [31:0] ReadDataM

);

    data_mem data_mem_inst (
        .A(ALUResultM),
        .AddressingControl(AddressingControlM),
        .clk(clk),
        .WE(MemWriteM),
        .WD(WriteDataM),
        .RD(ReadDataM)
    );

endmodule