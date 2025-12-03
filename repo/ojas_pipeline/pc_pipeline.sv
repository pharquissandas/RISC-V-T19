module pc_pipeline(
    input  logic                en, //enable input is low during a stall
    input  logic                clk,    // system clock
    input  logic                rst,    // asynchronous reset
    input  logic [1:0]          PCSrc,  // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
    input  logic [31:0]         PCTarget,  // branch target calculated in execute stage
    /* verilator lint_off UNUSED */
    input  logic [31:0]    ALUResult,
    /* verilator lint_on UNUSED */

    output logic [31:0]    PCPlus4, // PC + 4
    output logic [31:0]    PC      // current program counter
);

// next PC after the mux
logic [31:0] PCNext;

always_comb begin
    PCPlus4 = PC + 4;

    case(PCSrc)
        2'b00: PCNext = PCPlus4;
        2'b01: PCNext = PCTarget;

        2'b10: PCNext = {ALUResult[31:2], 2'b00};  // word addressed << 2

        default: PCNext = PCPlus4;
    endcase
end



// program counter register with asynchronous reset
always_ff @(posedge clk or posedge rst) begin
    if (rst) 
        PC <= {32{1'b0}};      // Reset PC to 0
    else if (en)
        PC <= PCNext;            // Update PC normally
    else
        PC <= PC;
end

endmodule
