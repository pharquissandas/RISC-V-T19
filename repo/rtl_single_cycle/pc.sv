module pc #(
    parameter WIDTH = 32
)(
    input  logic                clk,    // system clock
    input  logic                rst,    // asynchronous reset
    input  logic [1:0]          PCSrc,  // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
    input  logic [WIDTH-1:0]    ImmExt,  // immediate offset for branch target
            
    /* verilator lint_off UNUSED */

    input  logic [WIDTH-1:0]    ALUResult,

    /* verilator lint_on UNUSED */
    output logic [WIDTH-1:0]    PCPlus4, // PC + 4
    output logic [WIDTH-1:0]    PC      // current program counter
);

// next PC after the mux
logic [WIDTH-1:0] PCNext;

logic [WIDTH-1:0] PCTarget;


always_comb begin
    PCPlus4 = PC + 4;
    PCTarget = PC + ImmExt;

    case(PCSrc)
        2'b00: PCNext = PCPlus4;
        2'b01: PCNext = PCTarget;

        2'b10: PCNext = {ALUResult[31:2], 2'b00};  // word addressed << 2

        default: PCNext = PCPlus4;
    endcase
end



// program counter register with asynchronous reset
always_ff @(posedge clk) begin
    if (rst) 
        PC <= {WIDTH{1'b0}};      // Reset PC to 0
    else
        PC <= PCNext;            // Update PC normally
end

endmodule
