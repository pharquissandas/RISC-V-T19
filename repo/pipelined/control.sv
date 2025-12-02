// CONTROL UNIT
module control(
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic RegWrite,
    output logic [3:0] ALUControl,
    output logic ALUSrcA,
    output logic ALUSrcB,
    output logic MemWrite,
    output logic [1:0] ResultSrc,
    output logic Branch,
    output logic [2:0] BranchType,
    output logic [1:0] Jump,
    output logic [2:0] ImmSrc,
    output logic [2:0] AddressingControl
);
    always_comb begin
        // Default assignments
        RegWrite = 1'b0;
        ALUControl = 4'b0000;
        ALUSrcA = 1'b0;
        ALUSrcB = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        BranchType = 3'b000;
        Jump = 2'b00;
        ImmSrc = 3'b000;
        AddressingControl = funct3;

        case(opcode)
            // R-type
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b0;
                case(funct3)
                    3'b000: ALUControl = (funct7==7'b0100000)? 4'b0001 : 4'b0000; // SUB or ADD
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b010: ALUControl = 4'b1000; // SLT
                    3'b011: ALUControl = 4'b1001; // SLTU
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = (funct7==7'b0100000)? 4'b0111 : 4'b0110; // SRA/SRL
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                endcase
            end
            // I-type arithmetic
            7'b0010011: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ImmSrc = 3'b000; // I-type
                case(funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b001: ALUControl = 4'b0101; // SLLI
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b101: ALUControl = (funct7==7'b0100000)? 4'b0111 : 4'b0110; // SRAI/SRLI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b111: ALUControl = 4'b0010; // ANDI
                endcase
            end
            // Load (I-type)
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ResultSrc = 2'b01;
                ImmSrc = 3'b000;
                ALUControl = 4'b0000;
                AddressingControl = funct3;
            end
            // Store (S-type)
            7'b0100011: begin
                MemWrite = 1'b1;
                ALUSrcB = 1'b1;
                ImmSrc = 3'b001;
                ALUControl = 4'b0000;
                AddressingControl = funct3;
            end
            // Branch (B-type)
            7'b1100011: begin
                Branch = 1'b1;
                ImmSrc = 3'b010;
                BranchType = funct3;
                case(funct3)
                    3'b000,3'b001: ALUControl = 4'b0001; // BEQ/BNE
                    3'b100,3'b101: ALUControl = 4'b1000; // BLT/BGE
                    3'b110,3'b111: ALUControl = 4'b1001; // BLTU/BGEU
                endcase
            end
            // JAL
            7'b1101111: begin
                RegWrite = 1'b1;
                ResultSrc = 2'b10;
                ImmSrc = 3'b011;
                Jump = 2'b01;
            end
            // JALR
            7'b1100111: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ResultSrc = 2'b10;
                ImmSrc = 3'b000;
                Jump = 2'b10;
            end
            // LUI
            7'b0110111: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ResultSrc = 2'b00;
                ImmSrc = 3'b100;
                ALUControl = 4'b1111;
            end
            // AUIPC
            7'b0010111: begin
                RegWrite = 1'b1;
                ALUSrcA = 1'b1;
                ALUSrcB = 1'b1;
                ImmSrc = 3'b100;
                ALUControl = 4'b0000;
            end
        endcase
    end
endmodule
