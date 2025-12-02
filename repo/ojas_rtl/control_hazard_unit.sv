module control_hazard_unit(

    input logic [1:0] PCSrcE,

    output logic RSTD,
    output logic RSTE

);


always_comb begin

    case(PCSrcE)
    2'b01: begin 
        RSTD = 1'b1; //branch/jump taken
        RSTE = 1'b1;
    end
    2'b10: begin
        RSTD = 1'b1; //branch/jump taken
        RSTE = 1'b1;
    end    
    default: RSTD = 1'b0;
    endcase

end

endmodule
