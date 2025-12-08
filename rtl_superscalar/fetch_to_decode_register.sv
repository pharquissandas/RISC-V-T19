module fetch_to_decode_register(

    input logic clk,
    input logic en1,
    input logic en2,
    input logic rst1,
    input logic rst2,
    input logic [31:0] PCF1,
    input logic [31:0] PCPlus8F1,
    input logic [31:0] InstrF1,
    input logic [31:0] PCF2,
    input logic [31:0] PCPlus8F2,
    input logic [31:0] InstrF2,

    output logic [31:0] PCD1,
    output logic [31:0] PCD2,
    output logic [31:0] PCPlus8D1,
    output logic [31:0] PCPlus8D2,
    output logic [31:0] InstrD1,
    output logic [31:0] InstrD2

);

    always_ff @(posedge clk) begin
        if (rst1) begin
            PCD1 <= 32'b0;
            PCPlus8D1 <= 32'b0;
            InstrD1 <= 32'b0;
        end
        else if (en1) begin
            PCD1 <= PCF1;
            PCPlus8D1 <= PCPlus8F1;
            InstrD1 <= InstrF1;
        end
    end

    always_ff @(posedge clk) begin
        
        if (rst2) begin
            PCD2 <= 32'b0;
            PCPlus8D2 <= 32'b0;
            InstrD2 <= 32'b0;
        end
        else if (en2) begin
            PCD2 <= PCF2;
            PCPlus8D2 <= PCPlus8F2;
            InstrD2 <= InstrF2;
        end
    end



endmodule

