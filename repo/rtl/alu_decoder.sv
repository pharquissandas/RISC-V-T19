module alu_decoder (
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic       funct75,       // funct7[5]
    output logic [3:0] ALUControl     // extended to 4 bits
);

    // ALUControl encoding (4 bits)
    // 0000 = ADD
    // 0001 = SUB
    // 0010 = AND
    // 0011 = OR
    // 0100 = XOR
    // 0101 = SLL
    // 0110 = SRL
    // 0111 = SRA
    // 1000 = SLT (signed)
    // 1001 = SLTU (unsigned)
    // (leave others for future)

    always_comb begin
        unique case (ALUOp)
            // Load/Store/AUIPC: always ADD (address calculation)
            2'b00: ALUControl = 4'b0000; // ADD

            // Branch comparison: set to SUB (we also use Zero and SLT flags)
            2'b01: ALUControl = 4'b0001; // SUB

            // R-type: decode by funct3 + funct7
            2'b10: begin
                unique case (funct3)
                    3'b000: ALUControl = funct75 ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b010: ALUControl = 4'b1000; // SLT (signed)
                    3'b011: ALUControl = 4'b1001; // SLTU (unsigned)
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = funct75 ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                    default: ALUControl = 4'b0000;
                endcase
            end

            // I-type: similar to R-type but shifts use funct7[5] as well
            2'b11: begin
                unique case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b001: ALUControl = 4'b0101; // SLLI (shamt)
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b101: ALUControl = funct75 ? 4'b0111 : 4'b0110; // SRAI : SRLI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b111: ALUControl = 4'b0010; // ANDI
                    default: ALUControl = 4'b0000;
                endcase
            end

            default: ALUControl = 4'b0000;
        endcase
    end

endmodule
*/