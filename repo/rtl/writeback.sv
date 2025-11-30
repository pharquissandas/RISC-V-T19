module writeback(

input logic [31:0] ALUResultW,
input logic [31:0] ReadDataW,
input logic [31:0] PCPlus4W,
input logic [1:0]  ResultSrcW,

output logic [31:0] ResultW

);

mux3input mux3input2(

    .s(ResultSrcW),
    .d0(ALUResultW),
    .d1(ReadDataW),
    .d2(PCPlus4W),

    .y(ResultW)

);


endmodule
