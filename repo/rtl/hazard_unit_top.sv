//implementation of the hazard unit was based upon teachings from Chapter 7.5 of Digital Design and Computer Architecture RISC-V Edition by Harris and Harris

module hazard_unit_top(

    input logic [4:0] Rs1E, //source register from instruction in execution stage
    input logic [4:0] Rs2E, //source register from instruction in execution stage
    input logic [4:0] RdM,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdW,  //destination register of an instruction in memory/writeback stage
    input logic        RegWriteW, //tells us whether destination register is actually written
    input logic        RegWriteM,  //tells us whether destination register is actually written
    input logic [31:0] ALUResultM,
    input logic [31:0] ResultW,
    input logic [31:0] RD1E,
    input logic [31:0] RD2E,
    input logic [1:0]  ResultSrcE,

    output logic [31:0] SrcAE,
    output logic [31:0] WriteDataE,
    output logic        FEN,
    output logic        DEN
);

//when we have a lw instruction in exectution stage the ResultSrcE = 01
//this is when we stall the fetch and decode stages (for next cycle) to avoid
//lw data hazard


always_comb begin

    case(ResultSrcE)
        
        default: begin 
            FEN = 1; 
            DEN = 1;
        end
        2'b00: begin 
            FEN = 1; 
            DEN = 1;
        end
        2'b01: begin
             FEN = 0; 
             DEN = 0;
        end
        2'b10: begin
            FEN = 1; 
            DEN = 1;
        end
    endcase


end

logic [1:0] selAE;
logic [1:0] selBE;

hazard_unit hazard_unit1(

    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdM(RdM),
    .RdW(RdW),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),

    .ForwardAE(selAE),
    .ForwardBE(selBE)

);



mux3input aemux(

    .s(selAE),
    .d0(RD1E),
    .d1(ResultW),
    .d2(ALUResultM),

    .y(SrcAE)
);


mux3input bemux(

    .s(selBE),
    .d0(RD2E),
    .d1(ResultW),
    .d2(ALUResultM),

    .y(WriteDataE)
);



endmodule
