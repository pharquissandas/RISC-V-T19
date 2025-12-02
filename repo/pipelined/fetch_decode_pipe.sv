module fetch_decode_pipe #(
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  FlushD,
    input  logic                  IFIDWrite,
    input  logic [DATA_WIDTH-1:0] pcF,
    input  logic [DATA_WIDTH-1:0] instrF,
    input  logic [DATA_WIDTH-1:0] PCPlus4F,
    output logic [DATA_WIDTH-1:0] pcD,
    output logic [DATA_WIDTH-1:0] instrD,
    output logic [DATA_WIDTH-1:0] PCPlus4D
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pcD <= 32'b0;
            instrD <= 32'h00000013; // NOP
            PCPlus4D <= 32'b0;
        end else if (IFIDWrite) begin
            pcD <= pcF;
            instrD <= instrF;
            PCPlus4D <= PCPlus4F;
        end

        if (FlushD) begin
            instrD <= 32'h00000013; // Inject NOP
        end
    end
endmodule
