module data_mem (
    input  logic        clk,
    input  logic        WE,
    input  logic [31:0] A,
    input  logic [31:0] WD,
    output logic [31:0] RD
);

// replace array with ram_ip core
ram_ip ram_inst (
    .address (A[13:2]), // word aligned address
    .clock   (clk),     
    .data    (WD),
    .wren    (WE),
    .q       (RD)
);

endmodule
