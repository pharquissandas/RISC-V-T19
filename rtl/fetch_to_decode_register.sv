module fetch_to_decode_register(

    input logic clk,
    input logic en,
    input logic rst,
    input logic [31:0] PCF,
    input logic [31:0] PCPlus4F,
    input logic [31:0] InstrF,

    input logic predict_taken_F,

    output logic [31:0] PCD,
    output logic [31:0] PCPlus4D,
    output logic [31:0] InstrD,

    output logic predict_taken_D

);

    always_ff @(posedge clk) begin
        if (rst) begin
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;
            InstrD <= 32'b0;
            predict_taken_D <= 1'b0;
        end
        else if (en) begin
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
            InstrD <= InstrF;
            predict_taken_D <= predict_taken_F;
        end
    end
endmodule
