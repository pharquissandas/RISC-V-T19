module instr_mem (
    /* verilator lint_off UNUSED */
    input logic [31:0] A,
    /* verilator lint_on UNUSED */
    output logic [31:0] RD
);

    // instruction memory array: 4096 words of 32 bits each
    logic [31:0] rom_array [0:4095];

    // preload instructions from an external hex file at simulation start
    initial begin
        $readmemh("../rtl_cached_design/program.hex", rom_array);
    end

    // output the instruction corresponding to the PC address
    assign RD = rom_array[A[13:2]];
endmodule
