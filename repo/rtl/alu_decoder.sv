module alu_decoder (
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic       funct75,       // funct7[5]
    output logic [2:0] ALUControl
);

// for the full RV32I ALU, add R-type, I-type shift instructions, and STLU and SLTIU

    always_comb begin
        unique case (ALUOp)

            // 00: Load/Store -> ADD
            2'b00: ALUControl = 3'b000;

            // 01: Branch -> SUB
            2'b01: ALUControl = 3'b001;

            // 10: R-type -> Use funct3 + funct7b5
            2'b10: begin
                unique case (funct3)
                    3'b000: ALUControl = funct75 ? 3'b001      // SUB
                                                 : 3'b000;     // ADD
                    3'b010: ALUControl = 3'b101; // SLT
                    3'b110: ALUControl = 3'b011; // OR
                    3'b111: ALUControl = 3'b010; // AND
                    default: ALUControl = 3'b000;
                endcase
            end

            // 11: I-type ALU (ADDI/ANDI/ORI/SLTI)
            2'b11: begin
                unique case (funct3)
                    3'b000: ALUControl = 3'b000; // ADDI
                    3'b010: ALUControl = 3'b101; // SLTI
                    3'b110: ALUControl = 3'b011; // ORI
                    3'b111: ALUControl = 3'b010; // ANDI
                    default: ALUControl = 3'b000;
                endcase
            end

            default: ALUControl = 3'b000;
        endcase
    end

endmodule
