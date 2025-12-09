module pc_spsc #(
    parameter WIDTH = 32
)(
//Pipeline 1:
    input  logic                clk,    // system clock
    input  logic                rst,    // asynchronous reset
    input  logic                en,     // enable signal
    input  logic [1:0]          PCSrcE1,  // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))

    input  logic [WIDTH-1:0]    PCTargetE1,
            
    /* verilator lint_off UNUSED */

    input  logic [WIDTH-1:0]    ALUResultE1,

    /* verilator lint_on UNUSED */
    output logic [WIDTH-1:0]    PCPlus8F1, // PC + 4
    output logic [WIDTH-1:0]    PCF1,      // current program counter

//Pipeline 2:
    //input  logic                rst2,    // asynchronous reset
    //input  logic                en2,     // enable signal
    input  logic [1:0]          PCSrcE2,  // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))

    input  logic [WIDTH-1:0]    PCTargetE2,
            
    /* verilator lint_off UNUSED */

    input  logic [WIDTH-1:0]    ALUResultE2,

    /* verilator lint_on UNUSED */

    input logic StallPipeline2,
    input logic StallPipeline1NC,

    input logic BranchIn1,
    input logic BranchIn2,

    output logic [WIDTH-1:0]    PCPlus8F2, // PC + 4
    output logic [WIDTH-1:0]    PCF2      // current program counter
);


// next PC after the mux
logic [WIDTH-1:0] PCNext1;
logic [WIDTH-1:0] PCNext2;

// logic [WIDTH-1:0] PCTarget;


always_comb begin
    PCPlus8F1 = PCF1 + 8;
    PCPlus8F2 = PCF2 + 8;

    case(PCSrcE1)
        2'b00: PCNext1 = PCPlus8F1;
        2'b01: PCNext1 = PCTargetE1;

        2'b10: PCNext1 = {ALUResultE1[31:2], 2'b00};  // word addressed << 2

        default: PCNext1 = PCPlus8F1;
    endcase

    case(PCSrcE2)
        2'b00: PCNext2 = PCPlus8F2;
        2'b01: PCNext2 = PCTargetE2;

        2'b10: PCNext2 = {ALUResultE2[31:2], 2'b00};  // word addressed << 2

        default: PCNext2 = PCPlus8F2;
    endcase


end



// program counter register with asynchronous reset
always_ff @(posedge clk) begin
    if (rst) begin
        PCF1 <= {WIDTH{1'b0}};      // Reset PC1 to 0
        PCF2 <= 32'h4;              //Reset PC2 to 4
    end
    else if (BranchIn1)begin
        PCF1 <= PCNext1; // if we branch in pipeline 1
        PCF2 <= PCNext1 + 4; // next instruction in pipeline 2 
        //will be next instruction in pipeline 1 + 4
    end
    else if (BranchIn2)begin //if we have branches in both this isnt evaluated
    //this is the desired behaviour
    //as then we want only the first branch to be taken
        PCF1 <= PCNext2 + 4;
        PCF2 <= PCNext2;
    end
    else if(StallPipeline2) begin
        PCF2 <= PCF2;
    end
    else if(StallPipeline1NC)begin
        PCF1 <= PCF1;
    end
    else if (en) begin
        PCF1 <= PCNext1;            // Update PC normally
        PCF2 <= PCNext2;
    end
end

endmodule
