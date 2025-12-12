module mux(

    input logic        s, //select pin
    input logic [31:0] d0,
    input logic [31:0] d1,

    output logic [31:0] y


);

assign y = s ? d1 : d0;

endmodule
