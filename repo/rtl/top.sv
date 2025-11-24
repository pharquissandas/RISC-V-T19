module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 5
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    // x10 output
);

// control signals
logic RegWrite;
logic ALUSrc;
logic [2:0] ALUctrl;                    // 3-bit ALU control
logic [1:0] ImmSrc;                     // 2-bit immediate 
logic [1:0] ResultSrc;
logic PCsrc;
logic MemWrite;
logic EQ;

// data wires
logic [DATA_WIDTH-1:0] pc;
logic [DATA_WIDTH-1:0] instr;
logic [DATA_WIDTH-1:0] ImmOp;

// register file address fields
logic [ADDRESS_WIDTH-1:0] rs1;
logic [ADDRESS_WIDTH-1:0] rs2;
logic [ADDRESS_WIDTH-1:0] rd;

// decode instruction fields
assign rs1 = instr[19:15]; // source register 1
assign rs2 = instr[24:20]; // source register 2
assign rd  = instr[11:7];  // destination register

// program Counter: holds current instruction address
PC pc_module (
    .clk(clk),
    .rst(rst),
    .PCsrc(PCsrc),
    .ImmOp(ImmOp),
    .pc(pc)
);

// instruction memory: fetch instruction at PC
imem imem (
    .addr(pc),
    .instr(instr)
);

// control unit: generate control signals based on opcode
control control (
    .instr(instr),
    .EQ(EQ),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .ALUctrl(ALUctrl),
    .ImmSrc(ImmSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .PCsrc(PCsrc)
);

// sign-extension unit: generate immediate values
signext signext (
    .instr(instr),
    .ImmSrc(ImmSrc),
    .ImmOp(ImmOp)
);

// datapath unit: ALU + register file + muxes
data_unit data_unit (
    .clk(clk),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(rd),
    .RegWrite(RegWrite),
    .ImmOp(ImmOp),
    .ALUSrc(ALUSrc),
    .ALUctrl(ALUctrl),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .EQ(EQ),
    .a0(a0)
);

endmodule
