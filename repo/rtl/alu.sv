module alu(

    input logic [31:0] alu_op1,
    input logic [31:0] alu_op2,
    input logic        alu_ctrl,

    output logic [31:0] alu_out,
    output logic        eq

);

logic [31:0] equality;
logic [31:0] sum;

always_comb begin

    equality = alu_op1 - alu_op2;
    sum = alu_op1 + alu_op2;

    if(alu_ctrl == 1'b0)
        alu_out = sum;
    else
        alu_out = equality;

    if(equality == 32'b0)
        eq = 1;
    else
        eq = 0;

end

endmodule
