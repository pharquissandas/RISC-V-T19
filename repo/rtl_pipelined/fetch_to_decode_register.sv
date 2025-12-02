module fetch_to_decode_register(

    input logic clk,
    input logic en,
    input logic rst,
    input logic [31:0] PCF,
    input logic [31:0] PCPlus4F,
    input logic [31:0] InstrF,

    output logic [31:0] PCD,
    output logic [31:0] PCPlus4D,
    output logic [31:0] InstrD

);

    always_ff @(posedge clk) begin
        if (rst) begin
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;
            InstrD <= 32'b0;
        end
        else if (en) begin
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
            InstrD <= InstrF;
        end
    end
endmodule
