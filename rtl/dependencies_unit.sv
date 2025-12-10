module dependencies_unit(
    
    input clk,
    input [4:0] RdD1,
    input [4:0] RdD2,
  
    output logic StallPipeline2,
    output logic StallPipeline1NC

);


always_comb begin

    StallPipeline2 = 1'b0;


    if(RdD1 == RdD2)
        StallPipeline2 = 1'b1; // with a dependency we stall pipeline 2 first allow p1 to run
        //PCNextNew1 = PCD2
        //PCNextNew2 = PCF2 -> implement with MUX in fetch stage 
        //StallPipeline1NC = 1'b1;//cycle after p2 is stalled we stall p1 and let p2 run

end


always_ff @(posedge clk)begin

    if(StallPipeline2)
        StallPipeline1NC <= 1'b1;
    else
        StallPipeline1NC <= 1'b0;

end


endmodule
