module writeback (
    input logic [31:0] ALUResultW,
    input logic [31:0] ReadDataW,
    input logic [31:0] PCPlus4W,
    input logic [1:0] ResultSrcW,

    output logic [31:0] ResultW
);

    always_comb begin
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;
            2'b01: ResultW = ReadDataW;
            2'b10: ResultW = PCPlus4W;
            default: ResultW = ALUResultW;
        endcase
    end

endmodule
