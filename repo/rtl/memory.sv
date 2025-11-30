module memory(

input logic        clk,
input logic        MemWriteM, 
input logic [31:0] ALUResultM,
input logic [31:0] WriteDataM,
input logic AddressingControlM,

output logic [31:0] RDM

);

data_mem data_mem1(

    .clk(clk),
    .WE(MemWriteM),
    .A(ALUResultM),
    .WD(WriteDataM),
    .AddressingControl(AddressingControlM),

    .RD(RDM)

);

endmodule
