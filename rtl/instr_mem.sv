module instr_mem (
    /* verilator lint_off UNUSED */
    input logic [31:0] A1,
    input logic [31:0] A2,
    /* verilator lint_on UNUSED */
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    // instruction memory array: 4096 words of 32 bits each
    logic [31:0] rom_array [0:4095];

    // preload instructions from an external hex file at simulation start
    initial begin
        $readmemh("../rtl_cached_design/program.hex", rom_array);
    end

    // output the instruction corresponding to the PC address
    assign RD1 = rom_array[A1[13:2]];
    assign RD2 = rom_array[A2[13:2]];
endmodule
