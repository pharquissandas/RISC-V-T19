module memory (
    input logic clk,
    input logic rst,
    
    input logic [2:0] AddressingControlM,
    input logic MemWriteM,

    input logic [31:0] ALUResultM,
    input logic [31:0] WriteDataM,

    output logic [31:0] ReadDataM,
    output logic CacheStall

);

    memory_unit memory_unit_inst (
        .clk(clk),
        .rst(rst),
        .A(ALUResultM),
        .AddressingControl(AddressingControlM),
        .WE(MemWriteM),
        .WD(WriteDataM),
        .RD(ReadDataM),
        .stall(CacheStall)
    );

endmodule
