module hazard_unit(

    input logic [4:0] Rs1E, //source register from instruction in execution stage
    input logic [4:0] Rs2E, //source register from instruction in execution stage
    input logic [4:0] Rs1D, //source register from instruction in execution stage
    input logic [4:0] Rs2D, //source register from instruction in execution stage
    input logic [4:0] RdM,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdW,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdE,  
    input logic RegWriteW, //tells us whether destination register is actually written
    input logic RegWriteM,  //tells us whether destination register is actually written
    
    input logic [1:0] ResultSrcE, //to identify load instructions in execute stage
    input logic [1:0] PCSrcE, //to identify control hazards in execute stage

    output logic [1:0] ForwardAE, //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback stage, 10 means forwarding of result from ALU in memory stage
    output logic [1:0] ForwardBE,  //these are select inputs for muxes

    output logic StallDecode,
    output logic StallFetch,
    output logic FlushExecute,
    output logic FlushDecode

);


always_comb begin

    ForwardAE = 2'b00; //default is no forwarding
    ForwardBE = 2'b00; //default is no forwarding
    ForwardAE     = 2'b00;
    ForwardBE     = 2'b00;
    StallDecode   = 1'b0;
    StallFetch    = 1'b0;
    FlushExecute  = 1'b0;
    FlushDecode   = 1'b0;

    if(Rs1E == 5'b0) // register x0 is never forwarded
        ForwardAE = 2'b00;
    else if((Rs1E == RdM) && RegWriteM && Rs1E != 0)
        ForwardAE = 2'b10;
    else if((Rs1E == RdW) && RegWriteW && Rs1E != 0)
        ForwardAE = 2'b01;

    if(Rs2E == 5'b0) // register x0 is never forwarded
        ForwardBE = 2'b00;
    else if((Rs2E == RdM) &&  RegWriteM && Rs2E != 0)
        ForwardBE = 2'b10;
    else if((Rs2E == RdW) && RegWriteW && Rs2E != 0)
        ForwardBE = 2'b01;

    // Load-use hazard
    if (ResultSrcE == 2'b01 && (RdE == Rs1D || RdE == Rs2D)) begin
        StallDecode = 1'b1;
        StallFetch = 1'b1;
    end
    else begin
        StallDecode = 1'b0;
        StallFetch = 1'b0;
    end

    FlushExecute = StallDecode | (PCSrcE != 2'b00); // flush execute stage on load-use hazard or control hazard

    FlushDecode = (PCSrcE != 2'b00); // flush decode stage on control hazard

end






endmodule
