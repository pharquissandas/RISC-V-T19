module register(

    input logic clk,
    input logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk) 
        q <= d;

endmodule
