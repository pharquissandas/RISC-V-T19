module mux3input(

    input logic [1:0] s, //select pin
    input logic [31:0] d0,
    input logic [31:0] d1,
    input logic [31:0] d2,

    output logic [31:0] y


);

always_comb begin

    case(s)
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10:  y = d2;
        default: y = d0;
    endcase

end

endmodule
