module data_unit(

    input logic [5:0] rs1,
    input logic [5:0] rs2,
    input logic [5:0] rd,
    input logic       reg_write,
    input logic [31:0] din,
    input logic [31:0] imm_op,
    input logic        alu_src,
    input logic        alu_ctrl, 


    output logic [31:0] a0,
    output logic eq_out

);

logic [31:0] mux_out;
logic [31:0] rd1;
logic [31:0] rd2;


reg_file1 reg_file(

    .read_addr1(rs1),
    .read_addr2(rs2),
    .write_addr(rd),
    .wd3(din),
    .dout1(rd1),
    .dout2(rd2),
    .a0(a0),
    .clk(clk),
    .we3(reg_write)

);

opsel mux(

    .in0(rd2),
    .in1(imm_op),
    .sel(alu_src),
    .out(mux_out)
);


alu1 alu(

    .alu_op1(rd1),
    .alu_op2(mux_out),
    .alu_ctrl(alu_ctrl),
    .alu_out(din),
    .eq(eq_out)

);


endmodule
