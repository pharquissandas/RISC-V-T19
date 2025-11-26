module alu_decoder (
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic [3:0] ALUControl
);

    logic funct7_5;
    assign funct7_5 = funct7[5];

    always_comb begin
        case (ALUOp)
        
            2'b00: ALUControl = 4'b0000; // add for lw/sw/addi/auipc/jalr/

            2'b01: ALUControl = 4'b0001; // sub for beq/bne

            2'b10: begin // r-type/i-type
                unique case (funct3)
                    3'b000: begin
                        if ({funct7_5} == 1'b1)
                            ALUControl = 4'b0001; // sub
                        else
                            ALUControl = 4'b0000; // add
                    end

                    3'b001: ALUControl = 4'b0101; // sll

                    3'b010: ALUControl = 4'b1000; // slt

                    3'b011: ALUControl = 4'b1001; // sltu
                    3'b100: ALUControl = 4'b0100; // xor
                    3'b101: begin // SRL / SRA / SRLI / SRAI
                        if (funct7_5 == 1'b1)
                            ALUControl = 4'b0111; // sra
                        else
                            ALUControl = 4'b0110; // srl
                    end
                    3'b110: ALUControl = 4'b0011; // or
                    3'b111: ALUControl = 4'b0010; // and

                    default: ALUControl = 4'b0000;
                endcase
            end

            default: ALUControl = 4'b0000;
        endcase
    end
endmodule