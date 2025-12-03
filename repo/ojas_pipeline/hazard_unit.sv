module hazard_unit(

    input logic [4:0] Rs1E, //source register from instruction in execution stage
    input logic [4:0] Rs2E, //source register from instruction in execution stage
    input logic [4:0] RdM,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdW,  //destination register of an instruction in memory/writeback stage
    input logic        RegWriteW, //tells us whether destination register is actually written
    input logic        RegWriteM,  //tells us whether destination register is actually written

    output logic [1:0] ForwardAE, //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback stage, 10 means forwarding of result from ALU in memory stage
    output logic [1:0] ForwardBE  //these are select inputs for muxes

);


always_comb begin

    ForwardAE = 2'b00; //default is no forwarding
    ForwardBE = 2'b00; //default is no forwarding

    if(Rs1E == 5'b0) // register x0 is never forwarded
        ForwardAE = 2'b00;

    else if((Rs1E == RdM) & RegWriteM)
        ForwardAE = 2'b10;
    else if((Rs1E == RdW) & RegWriteW)
        ForwardAE = 2'b01;

    if(Rs2E == 5'b0) // register x0 is never forwarded
        ForwardBE = 2'b00;

    else if((Rs2E == RdM) & RegWriteM)
        ForwardBE = 2'b10;
    else if((Rs2E == RdW) & RegWriteW)
        ForwardBE = 2'b01;

end

endmodule
