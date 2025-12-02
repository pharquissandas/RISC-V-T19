module pc #(
    parameter WIDTH = 32
)(
    input  logic                clk,    // system clock
    input  logic                rst,    // asynchronous reset
    input  logic                en,     // enable signal
    input  logic [1:0]          PCSrcE,  // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))

    input  logic [WIDTH-1:0]    PCTargetE,
            
    /* verilator lint_off UNUSED */

    input  logic [WIDTH-1:0]    ALUResultE,

    /* verilator lint_on UNUSED */
    output logic [WIDTH-1:0]    PCPlus4F, // PC + 4
    output logic [WIDTH-1:0]    PCF      // current program counter
);

// next PC after the mux
logic [WIDTH-1:0] PCNext;

// logic [WIDTH-1:0] PCTarget;


always_comb begin
    PCPlus4F = PCF + 4;

    case(PCSrcE)
        2'b00: PCNext = PCPlus4F;
        2'b01: PCNext = PCTargetE;

        2'b10: PCNext = {ALUResultE[31:2], 2'b00};  // word addressed << 2

        default: PCNext = PCPlus4F;
    endcase
end



// program counter register with asynchronous reset
always_ff @(posedge clk) begin
    if (rst) PCF <= {WIDTH{1'b0}};      // Reset PC to 0
    else if (en) PCF <= PCNext;            // Update PC normally
end

endmodule
