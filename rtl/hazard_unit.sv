module hazard_unit(

    input logic [4:0] Rs1E, //source register from instruction in execution stage
    input logic [4:0] Rs2E, //source register from instruction in execution stage
    input logic [4:0] Rs1D, //source register from instruction in execution stage
    input logic [4:0] Rs2D, //source register from instruction in execution stage
    input logic [4:0] RdM1,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdW1,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdE1,  
    input logic RegWriteW1, //tells us whether destination register is actually written
    input logic RegWriteM1,  //tells us whether destination register is actually written
    
    input logic [1:0] ResultSrcE1, //to identify load instructions in execute stage
    input logic [1:0] PCSrcE1, //to identify control hazards in execute stage


    input logic [4:0] Rs4E, //source register from instruction in execution stage
    input logic [4:0] Rs5E, //source register from instruction in execution stage
    input logic [4:0] Rs4D, //source register from instruction in execution stage
    input logic [4:0] Rs5D, //source register from instruction in execution stage
    input logic [4:0] RdM2,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdW2,  //destination register of an instruction in memory/writeback stage
    input logic [4:0] RdE2,  
    input logic RegWriteW2, //tells us whether destination register is actually written
    input logic RegWriteM2,  //tells us whether destination register is actually written
    
    input logic [1:0] ResultSrcE2, //to identify load instructions in execute stage
    input logic [1:0] PCSrcE2, //to identify control hazards in execute stage


    input logic BranchD1,
    input logic BranchD2,

    input [4:0] RdD1,
    input [4:0] RdD2,


    input logic [31:0] PCE1,//use the PC values to determine
    input logic [31:0] PCE2,// which branch instruction should be taken if branches in both pipelines


    //Forward outputs: 000 = no forwardin,
    //001 forwarding from writeback stage pipeline 1,
    //010 forwarding from alu result in memory stage in pipeline 1
    //011 forwarding from writeback stage pipeline 2,
    //100 forwarding from alu result in memory stage in pipeline 2


    output logic [2:0] ForwardAE1, //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback1 stage, 10 means forwarding of result from ALU in memory stage
    output logic [2:0] ForwardBE1,  //these are select inputs for muxes

    output logic [2:0] ForwardAE2, //these are select inputs for muxes, 00 means no forwarding, 01 means forwarding of result in writeback stage, 10 means forwarding of result from ALU in memory stage
    output logic [2:0] ForwardBE2,  //these are select inputs for muxes

    output logic StallFetch1,    
    output logic StallDecode1,
    output logic FlushDecode1,
    output logic FlushExecute1,

    output logic StallFetch2,    
    output logic StallDecode2,
    output logic FlushDecode2,
    output logic FlushExecute2,

    output logic BranchIn1,
    output logic BranchIn2,

    output logic StallExecute1,
    output logic StallExecute2,
    output logic StallMemory1,
    output logic StallMemory2,
    output logic FlushMemory1,
    output logic FlushMemory2,
    output logic StallWriteback1,
    output logic StallWriteback2,
    output logic FlushWriteback1,
    output logic FlushWriteback2

);

always_comb begin
    BranchIn1      = 1'b0;
    BranchIn2      = 1'b0;
    ForwardAE1     = 3'b000;
    ForwardBE1     = 3'b000;
    StallDecode1   = 1'b0;
    StallFetch1    = 1'b0;
    FlushExecute1  = 1'b0;
    FlushDecode1  = 1'b0;
    ForwardAE2     = 3'b000;
    ForwardBE2     = 3'b000;
    StallDecode2   = 1'b0;
    StallFetch2   = 1'b0;
    FlushExecute2  = 1'b0;
    FlushDecode2  = 1'b0;
    StallExecute1 = 1'b0;
    StallExecute2 = 1'b0;
    StallMemory1 = 1'b0;
    StallMemory2 = 1'b0;
    FlushMemory1 = 1'b0;
    FlushMemory2 = 1'b0;
    StallWriteback1 = 1'b0;
    StallWriteback2 = 1'b0;
    FlushWriteback1 = 1'b0;
    FlushWriteback2 = 1'b0;
    


    //Dependcy unit is not correct, we need to stop execution if dependency is recognised in decode stage
    //so flush execute? 
    //but then we need to execute the instruction taht was halted the cycle immediately after
///I THINK STALLPIPELINE NEEDS TO STALL EVERY STAGE
//in dependey uunit igonre if everything is 0s so we dont stall forever


//Need to account for dependency between source and destinationr egisters in same cycle between p1 and p2

    /*if((Rs1D == RdD2 || Rs2D == RdD2) && !(RdD2 == 0)) begin

        StallExecute1 = 1'b1;
        StallDecode1 = 1'b1;
        StallDecode2 = 1'b1; //needed?
        StallFetch1 = 1'b1;
        StallFetch2 = 1'b1;
        FlushDecode1 = 1'b1;
        FlushExecute2 = 1'b1;

    end*/

    if((Rs4D == RdD1 || Rs5D == RdD1) && !(RdD1 == 0))begin

        StallExecute2 = 1'b1;
        StallDecode2 = 1'b1; 
        StallDecode1 = 1'b1;    //needed?
        StallFetch1 = 1'b1; 
        StallFetch2 = 1'b1;
        FlushDecode1 = 1'b1;
        FlushExecute2 = 1'b1;

    end


    if((RdD1 == RdD2) && !(BranchD1 || BranchD2) && !(RdD1 == 0 || RdD2 == 0))begin

        StallExecute2 = 1'b1;
        StallDecode1 = 1'b1;
        StallDecode2 = 1'b1;
        StallFetch1 = 1'b1;
        StallFetch2 = 1'b1;
        FlushDecode1 = 1'b1;
        FlushExecute2 = 1'b1;
    
    end





    
    if(BranchD1 && BranchD2)begin
    
        FlushDecode2 = 1'b1;
        FlushExecute2 = 1'b1;
        StallFetch2 = 1'b1;
        StallDecode2 = 1'b1;

        
        //We also need to flush decode and fetch ? for both pipelines
        //So that we execute the correct next instruction
        //however if no branch taken
        //we dont need to do this for both pipelines


    end

    if(PCSrcE1 != 2'b00 && PCSrcE2 != 2'b00)begin//branches in both pipelines

        FlushDecode2 = 1'b1;
        FlushExecute2 = 1'b1;

        FlushDecode1 = 1'b1;
        FlushExecute1 = 1'b1;

        if(PCE1 < PCE2) begin //take branch of Pipeline 1 and ignore branch result of pipeline 2
            
            BranchIn1 = 1'b1;

        end

        else if (PCE1 > PCE2) begin

            BranchIn2 = 1'b1;
        
        end

    end

    else if (PCSrcE1 != 2'b00) begin

        //StallFetch1 = 1'b1;
        FlushDecode1 = 1'b1;
        FlushExecute1 = 1'b1;

       // StallFetch2 = 1'b1;
        FlushDecode2 = 1'b1;
        FlushExecute2 = 1'b1;
        FlushMemory2 = 1'b1;

        BranchIn1 = 1'b1;

    end


    else if (PCSrcE2 != 2'b00) begin
        
       // StallFetch1 = 1'b1;
        FlushDecode1 = 1'b1;
        FlushExecute1 = 1'b1;

        //StallFetch2 = 1'b1;
        FlushDecode2 = 1'b1;
        FlushExecute2 = 1'b1;

        BranchIn2 = 1'b1;

    end


    if(Rs1E == 5'b0) // register x0 is never forwarded
        ForwardAE1 = 3'b000;
    else if((Rs1E == RdM1) && RegWriteM1 && Rs1E != 0)
        ForwardAE1 = 3'b010;
    else if((Rs1E == RdM2) && RegWriteM2 && Rs1E != 0)
        ForwardAE1 = 3'b011;
    else if((Rs1E == RdW1) && RegWriteW1 && Rs1E != 0)
        ForwardAE1 = 3'b001;
    else if((Rs1E == RdW2) && RegWriteW2 && Rs1E != 0)
        ForwardAE1 = 3'b100;

    if(Rs2E == 5'b0) // register x0 is never forwarded
        ForwardBE1 = 3'b000;
    else if((Rs2E == RdM1) &&  RegWriteM1 && Rs2E != 0)
        ForwardBE1 = 3'b010;
    else if((Rs2E == RdM2) &&  RegWriteM2 && Rs2E != 0)
        ForwardBE1 = 3'b011;
    else if((Rs2E == RdW1) && RegWriteW1 && Rs2E != 0)
        ForwardBE1 = 3'b001;
    else if((Rs2E == RdW2) && RegWriteW2 && Rs2E != 0)
        ForwardBE1 = 3'b100;

    // unconditional jump control hazard (branch taken)

    // load-use hazard (data hazard)
    if (ResultSrcE1 == 2'b01 && (RdE1 != 0) && (RdE1 == Rs1D || RdE1 == Rs2D)) begin
        StallDecode1 = 1'b1;
        StallFetch1 = 1'b1;
        FlushExecute1 = 1'b1;
    end

    if(ResultSrcE1 == 2'b01 && (RdE1 != 0) && (RdE1 == Rs4D || RdE1 == Rs5D)) begin
        StallDecode2 = 1'b1;
        StallFetch2 = 1'b1;
        FlushExecute2 = 1'b1;
    end


    if(Rs4E == 5'b0) // register x0 is never forwarded
        ForwardAE2 = 3'b000;
    else if((Rs4E == RdM2) && RegWriteM2 && Rs4E != 0)
        ForwardAE2 = 3'b010;
    else if((Rs4E == RdM1) && RegWriteM1 && Rs4E != 0)
        ForwardAE2 = 3'b011;
    else if((Rs4E == RdW2) && RegWriteW2 && Rs4E != 0)
        ForwardAE2 = 3'b001;
    else if((Rs4E == RdW1) && RegWriteW1 && Rs4E != 0)
        ForwardAE2 = 3'b100;

    if(Rs5E == 5'b0) // register x0 is never forwarded
        ForwardBE2 = 3'b000;
    else if((Rs5E == RdM2) &&  RegWriteM2 && Rs5E != 0)
        ForwardBE2 = 3'b010;
    else if((Rs5E == RdM1) &&  RegWriteM1 && Rs5E != 0)
        ForwardBE2 = 3'b011;
    else if((Rs5E == RdW2) && RegWriteW2 && Rs5E != 0)
        ForwardBE2 = 3'b001;
    else if((Rs5E == RdW1) && RegWriteW1 && Rs5E != 0)
        ForwardBE2 = 3'b100;

    // load-use hazard (data hazard)
    if (ResultSrcE2 == 2'b01 && (RdE2 != 0) && (RdE2 == Rs4D || RdE2 == Rs5D)) begin
        StallDecode2 = 1'b1;
        StallFetch2 = 1'b1;
        FlushExecute2 = 1'b1;
    end
    if (ResultSrcE2 == 2'b01 && (RdE2 != 0) &&  (RdE2 == Rs1D || RdE2 == Rs2D)) begin

        StallDecode1 = 1'b1;
        StallFetch1 = 1'b1;
        FlushExecute1  = 1'b1;

    end
end

endmodule
