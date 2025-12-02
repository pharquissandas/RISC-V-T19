module memory_writeback_pipe #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] ALUResultM,
    input logic [DATA_WIDTH-1:0] MemDataM,
    input logic [4:0] RdM,
    input logic RegWriteM,
    input logic [DATA_WIDTH-1:0] PCPlus4M,
    input logic [1:0] ResultSrcM,
    // Expose MemDataW (memory read data) as the name used throughout the
    // pipelined modules (top.sv uses MemDataW). There was an extraneous
    // ReadDataW output here which was never connected by top; remove it.
    output logic [DATA_WIDTH-1:0] MemDataW,
    output logic [4:0] RdW,
    output logic RegWriteW,
    output logic [DATA_WIDTH-1:0] PCPlus4W,
    output logic [DATA_WIDTH-1:0] ALUResultW,
    output logic [1:0] ResultSrcW
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            MemDataW <= 32'b0; RdW <= 5'b0; RegWriteW <= 1'b0;
            ALUResultW <= 32'b0; PCPlus4W <= 32'b0; ResultSrcW <= 2'b0;
        end else begin
            MemDataW <= MemDataM;
            RdW <= RdM;
            RegWriteW <= RegWriteM;
            ALUResultW <= ALUResultM;
            PCPlus4W <= PCPlus4M;
            ResultSrcW <= ResultSrcM;
        end
    end
endmodule
