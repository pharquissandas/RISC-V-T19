module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 5
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);

logic RegWrite;
logic ALUsrc;
logic ALUctrl;
logic ImmSrc;
logic PCsrc;
logic EQ;

logic [DATA_WIDTH-1:0] pc;
logic [DATA_WIDTH-1:0] ImmOp;
logic [DATA_WIDTH-1:0] instr;

logic [ADDRESS_WIDTH-1:0] rs1;
logic [ADDRESS_WIDTH-1:0] rs2;
logic [ADDRESS_WIDTH-1:0] rd;

assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd  = instr[11:7];

PC pc_module (
    .clk(clk),
    .rst(rst),
    .ImmOp(ImmOp),
    .PCsrc(PCsrc),
    .pc(pc)
);

imem imem (
    .addr(pc),
    .instr(instr)
);

control control (
    .instr(instr),
    .EQ(EQ),
    .RegWrite(RegWrite),
    .ALUsrc(ALUsrc),
    .ALUctrl(ALUctrl),
    .ImmSrc(ImmSrc),
    .PCsrc(PCsrc)
);

signext signext (
    .instr(instr),
    .ImmSrc(ImmSrc),
    .ImmOp(ImmOp)
);

reg_alu_top reg_alu_top (
    .clk(clk),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(rd),
    .RegWrite(RegWrite),
    .ImmOp(ImmOp),
    .ALUsrc(ALUsrc),
    .ALUctrl(ALUctrl),
    .EQ(EQ),
    .a0(a0)
);

endmodule
