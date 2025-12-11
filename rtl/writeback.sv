module writeback (
    input logic [31:0] ALUResultW1,
    input logic [31:0] ReadDataW1,
    input logic [31:0] PCPlus8W1,
    input logic [1:0] ResultSrcW1,

    input logic [31:0] ALUResultW2,
    input logic [31:0] ReadDataW2,
    input logic [31:0] PCPlus8W2,
    input logic [1:0] ResultSrcW2,

    output logic [31:0] ResultW1,
    output logic [31:0] ResultW2
);

    always_comb begin
        case (ResultSrcW1)
            2'b00: ResultW1 = ALUResultW1;
            2'b01: ResultW1 = ReadDataW1;
            2'b10: ResultW1 = PCPlus8W2; // Result should be current PC + 4 and PCPlus8W2 == PCPlus4W1
            default: ResultW1 = ALUResultW1;
        endcase

        case (ResultSrcW2)
            2'b00: ResultW2 = ALUResultW2;
            2'b01: ResultW2 = ReadDataW2;
            2'b10: ResultW2 = PCPlus8W1; 
            default: ResultW2 = ALUResultW2;
        endcase
    end

endmodule
