module pc #(
    parameter WIDTH = 32
)(
    input  logic                clk,    // system clock
    input  logic                rst,    // asynchronous reset
    input  logic                en,     // enable signal
    input  logic [1:0]          PCSrcE,  // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))

    input logic pc_redirect_i,
    input logic [WIDTH-1:0]   mispredict_target_pc_i,

    input logic pc_predict_redirect_i,
    input logic [WIDTH-1:0]   predicted_target_pc_i,

    input  logic [WIDTH-1:0]    PCTargetE,
    /* verilator lint_on UNUSED */
    input  logic [WIDTH-1:0]    ALUResultE,
    /* verilator lint_on UNUSED */
    output logic [WIDTH-1:0]    PCPlus4F, // PC + 4
    output logic [WIDTH-1:0]    PCF,      // current program counter
    output logic [WIDTH-1:0]    PCPlus4F2,
    output logic [WIDTH-1:0]    PCF2 // current program counter in pipeline 2
);

// next PC after the mux
logic [WIDTH-1:0] PCNext;

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
    if (rst) begin 
        PCF1 <= {WIDTH{1'b0}};      // Reset PC to 0
        PCF2 <= {WIDTH{1'b0}} + 4; 
    end
    else if (pc_redirect_i) begin 
        PCF1 <= mispredict_target_pc_i; // Misprediction redirect
        PCF2 <= mispredict_target_pc_i  + 4; // Misprediction redirect
    end
    else if (pc_predict_redirect_i) begin 
        PCF1 <= predicted_target_pc_i; // Branch prediction redirect
        PCF2 <= predicted_target_pc_i + 4; // Branch prediction redirect

    end
    else if (en) begin // Update PC normally
        PCF1 <= PCNext; 
        PCF2 <= PCNext + 4;
    end           
end
endmodule

