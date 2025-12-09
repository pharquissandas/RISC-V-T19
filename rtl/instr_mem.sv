module instr_mem (
    input  logic        clk, // clock
    input  logic [31:0] A,
    output logic [31:0] RD
);

// replace array with rom_ip core
rom_ip rom_inst (
    .address (A[13:2]), // word aligned address
    .clock   (~clk),    // inverted clock for stability
    .q       (RD)
);

endmodule
