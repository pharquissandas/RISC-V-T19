//implementation of the hazard unit was based upon teachings from Chapter 7.5 of Digital Design and Computer Architecture RISC-V Edition by Harris and Harris

module hazard_unit_top(

    input logic [4:0] Rs1D, //source register from instruction in decode stage
    input logic [4:0] Rs2D, //source register from instruction in decode stage
    input logic [4:0] Rs1E, //source register from instruction in execution stage
    input logic [4:0] Rs2E, //source register from instruction in execution stage
    input logic [4:0] RdM,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdW,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdE,  //destination register of an instruction in execution stage
    input logic        RegWriteW, //tells us whether destination register is actually written
    input logic        RegWriteM,  //tells us whether destination register is actually written
    input logic [31:0] ALUResultM,
    input logic [31:0] ResultW,
    input logic [31:0] RD1E,
    input logic [31:0] RD2E,
    input logic [1:0]  ResultSrcE,
    input logic [1:0]  PCSrcE,

    output logic [31:0] SrcAE,
    output logic [31:0] WriteDataE,
    output logic        FEN,
    output logic        DEN,
    output logic        RSTE,
    output logic        RSTD

);

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

logic flushE1;
logic flushE2;

always_comb begin
    RSTE = (flushE1 | flushE2); //flush execution register if we stall or if we have a control hazard
end

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

stall_unit stall_unit1(

    .ResultSrcE(ResultSrcE),
    .RDE(RdE),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),

    .FEN(FEN),
    .DEN(DEN),
    .RSTE(flushE1)

);

//handles control hazards caused by branches (and jumps)
control_hazard_unit control_hazard_unit1(

    .PCSrcE(PCSrcE),

    .RSTD(RSTD),
    .RSTE(flushE2)

);


endmodule
