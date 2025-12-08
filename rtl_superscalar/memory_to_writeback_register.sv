module memory_to_writeback_register(

    input logic clk,
    input logic rst1,
    input logic rst2,
    input logic en1,
    input logic en2,

    input logic RegWriteM1,
    input logic [1:0] ResultSrcM1,
    input logic RegWriteM2,
    input logic [1:0] ResultSrcM2,

    input logic [31:0] ALUResultM1,
    input logic [31:0] ReadDataM1,
    input logic [4:0] RdM1,
    input logic [31:0] PCPlus8M1,
    input logic [31:0] ALUResultM2,
    input logic [31:0] ReadDataM2,
    input logic [4:0] RdM2,
    input logic [31:0] PCPlus8M2,

    output logic RegWriteW1,
    output logic [1:0] ResultSrcW1,
    output logic RegWriteW2,
    output logic [1:0] ResultSrcW2,

    output logic [31:0] ALUResultW1,
    output logic [31:0] ReadDataW1,
    output logic [4:0]  RdW1,
    output logic [31:0] PCPlus8W1,
    output logic [31:0] ALUResultW2,
    output logic [31:0] ReadDataW2,
    output logic [4:0]  RdW2,
    output logic [31:0] PCPlus8W2
);

    always_ff @(posedge clk) begin
        if (rst1) begin

            RegWriteW1    <= 1'b0;
            ResultSrcW1   <= 2'b0;

            ALUResultW1   <= 32'b0;
            ReadDataW1    <= 32'b0;
            RdW1          <= 5'b0;
            PCPlus8W1     <= 32'b0;

        end

        else if (en1) begin

            RegWriteW1    <= RegWriteM1;
            ResultSrcW1   <= ResultSrcM1;

            ALUResultW1   <= ALUResultM1;
            ReadDataW1    <= ReadDataM1;
            RdW1          <= RdM1;
            PCPlus8W1     <= PCPlus8M1;

        end
    end


always_ff @(posedge clk) begin

    if (rst2) begin
        
        RegWriteW2    <= 1'b0;
        ResultSrcW2   <= 2'b0;

        ALUResultW2   <= 32'b0;
        ReadDataW2    <= 32'b0;
        RdW2          <= 5'b0;
        PCPlus8W2     <= 32'b0;
    end

    else if (en2) begin

        RegWriteW2    <= RegWriteM2;
        ResultSrcW2   <= ResultSrcM2;

        ALUResultW2   <= ALUResultM2;
        ReadDataW2    <= ReadDataM2;
        RdW2          <= RdM2;
        PCPlus8W2     <= PCPlus8M2;

    end


end

endmodule
