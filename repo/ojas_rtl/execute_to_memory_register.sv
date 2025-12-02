module execute_to_memory_register (

    input logic clk,
    input logic rst,
    input logic RegWriteE,
    input logic [1:0] ResultSrcE,
    input logic MemWriteE,
    input logic [2:0] AddressingControlE,

    input logic [31:0] ALUResultE,
    input logic [31:0] WriteDataE,
    input logic [4:0] RdE,
    input logic [31:0] PCPlus4E,
    
    output logic RegWriteM,
    output logic [1:0] ResultSrcM,
    output logic MemWriteM,
    output logic [2:0] AddressingControlM,
    
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic [4:0] RdM,
    output logic [31:0] PCPlus4M

);
    always_ff @(posedge clk) begin
        if (rst) begin //flush
            RegWriteM          <= 1'b0;
            ResultSrcM         <= 2'b00;
            MemWriteM          <= 1'b0;
            AddressingControlM <= 3'b000; // is this correct behaviour in flush?

            ALUResultM   <= 32'b0;
            WriteDataM   <= 32'b0;
            RdM          <= 5'b0;
            PCPlus4M     <= 32'b0;
        end
        else begin
            RegWriteM          <= RegWriteE;
            ResultSrcM         <= ResultSrcE;
            MemWriteM          <= MemWriteE;
            AddressingControlM <= AddressingControlE;

            ALUResultM   <= ALUResultE;
            WriteDataM   <= WriteDataE;
            RdM          <= RdE;
            PCPlus4M     <= PCPlus4E;
        end
    end

endmodule
