//once we detect a lw instruction in the execution stage
//we will stall the fetch and decode stages for the next cycle
//this means that once unstalled we can forward the correct output from data memory
module stall_unit(

    input logic [1:0]  ResultSrcE,
    input logic [4:0] RDE,  //destination register of a load instruction in execution stage
    input logic [4:0] Rs1D,
    input logic [4:0] Rs2D,

    output logic        FEN,
    output logic        DEN,
    output logic        RSTE

);

always_comb begin

//default values: 
    FEN = 1'b1;
    DEN = 1'b1; 
    RSTE = 1'b0;

    if((ResultSrcE == 2'b01) & ((Rs1D == RDE) | (Rs2D == RDE))) begin
        FEN = 1'b0;
        DEN = 1'b0;
        RSTE = 1'b1;
    end

end


endmodule
