// PC module
module pc #(
    parameter WIDTH = 32
)(
    input  logic clk,
    input  logic rst,
    input  logic [1:0] PCSrc,
    input  logic PCWrite,
    input  logic [WIDTH-1:0] ImmExt,
    input  logic [WIDTH-1:0] ALUResult,
    output logic [WIDTH-1:0] PCPlus4,
    output logic [WIDTH-1:0] PC
);

    logic [WIDTH-1:0] PCNext;
    logic [WIDTH-1:0] PCTarget;

    always_comb begin
        PCPlus4 = PC + 4;
        PCTarget = PC + ImmExt;
        case (PCSrc)
            2'b00: PCNext = PCPlus4;
            2'b01: PCNext = PCTarget;
            2'b10: PCNext = {ALUResult[31:2], 2'b00};
            default: PCNext = PCPlus4;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) PC <= 32'b0;
        else if (PCWrite) PC <= PCNext;
    end
endmodule
