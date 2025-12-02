module execute_memory_pipe #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] ALUResultE,
    input logic [DATA_WIDTH-1:0] WriteDataE,
    input logic [DATA_WIDTH-1:0] PCPlus4E,
    input logic MemWriteE, MemReadE,
    input logic [4:0] RdE,
    input logic RegWriteE,
    input logic [1:0] ResultSrcE,
    input logic [2:0] LS_modeE,
    output logic [DATA_WIDTH-1:0] ALUResultM,
    output logic [DATA_WIDTH-1:0] WriteDataM,
    output logic [DATA_WIDTH-1:0] PCPlus4M,
    output logic MemWriteM, MemReadM,
    output logic [4:0] RdM,
    output logic RegWriteM,
    output logic [1:0] ResultSrcM,
    output logic [2:0] LS_modeM
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ALUResultM <= 32'b0; WriteDataM <= 32'b0; PCPlus4M <= 32'b0;
            MemWriteM <= 1'b0; MemReadM <= 1'b0;
            RdM <= 5'b0; RegWriteM <= 1'b0;
            ResultSrcM <= 2'b0; LS_modeM <= 3'b0;
        end else begin
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            PCPlus4M <= PCPlus4E;
            MemWriteM <= MemWriteE;
            MemReadM <= MemReadE;
            RdM <= RdE;
            RegWriteM <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            LS_modeM <= LS_modeE;
        end
    end
endmodule
