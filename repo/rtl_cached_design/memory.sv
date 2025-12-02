module memory(

input logic        clk,
input logic        rst,
input logic        MemWriteM, 
input logic [31:0] ALUResultM,
input logic [31:0] WriteDataM,
input logic [2:0]  AddressingControlM,

output logic [31:0] RDM

);

logic stall;

memory_unit data_mem1(

    .clk(clk),
    .rst(rst),
    .WE(MemWriteM),
    .A(ALUResultM),
    .WD(WriteDataM),
    .AddressingControl(AddressingControlM),
    .RD(RDM),
    .stall(stall)

);

endmodule
