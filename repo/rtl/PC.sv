module PC #(
    parameter WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic PCsrc,
    input logic immOp,
    output logic [WIDTH-1:0] pc
);

logic [WIDTH-1:0] branch_PC;
logic [WIDTH-1:0] inc_PC;

always_ff @(posedge clk)
    if (rst) pc <= {WIDTH{1'b0}};
    else
        assign inc_PC = pc + {{WIDTH-3{1'b0}}, 2'b100}; // pc + 4
        assign branch_PC = pc + immOp;
        if (PCsrc) pc <= branch_PC;
        else pc <= inc_PC;
endmodule
