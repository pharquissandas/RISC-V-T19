module memory(

input logic        clk,
input logic        MemWriteM,
input logic [31:0] ALUResultM,
input logic [31:0] WriteDataM,

output logic [31:0] RDM

);

data_mem data_mem1(

    .clk(clk),
    .WE(MemWriteM),
    .A(ALUResultM),
    .WD(WriteDataM),

    .RD(RDM)

);

endmodule
