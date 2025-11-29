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

    output logic [31:0] SrcAE,
    output logic [31:0] WriteDataE
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
