// Instruction memory
module instr_mem (
    input  logic [31:0] A,
    output logic [31:0] RD
);
    logic [31:0] rom_array [0:4095];
    initial $readmemh("../rtl/program.hex", rom_array);
    assign RD = rom_array[A[13:2]];
endmodule
