module control #(
    input logic [6:0]  opcode,
    input logic [2:0]  funct3,
    input logic [6:0]  funct7,

    output logic RegWrite,  // enable write to register
    output logic [3:0] ALUControl, // control operation in ALU
    output logic ALUSrcA, // choose PC (1) or register (0) for ALU operand A
    output logic ALUSrcB, // choose immediate (1) or register (0) operand    
    output logic MemWrite, // enable write into the data memory
    // output logic [1:0] PCSrc, // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
    output logic [1:0] ResultSrc, // control the source of data to write back to register file (00 = ALU, 01 = Memory, 10 = PC+4)
    output logic Branch,
    output logic [2:0] BranchType, 
    output logic [1:0] Jump,       // indicates jump instruction (00 = no jump, 01 = JAL, 10 = JALR)
    output logic [2:0] ImmSrc, // selects type of immediate (I = 000, S = 001, B = 010, J = 011, U = 100)
    output logic [2:0] AddressingControl // choose which type of load/store instruction to perform 
);

    // logic [6:0] opcode;
    // logic [2:0] funct3;
    // logic [6:0] funct7;

    // assign opcode = Instr[6:0];
    // assign funct3 = Instr[14:12];
    // assign funct7 = Instr[31:25];
    assign AddressingControl = funct3; // store width

    always_comb begin
        // Default values to prevent latches
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
        AddressingControl = 3'b000;


        case(opcode)
            // R-type instructions
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
               
                case(funct3)
                    3'b000: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0000; // add
                            7'b0100000: ALUControl = 4'b0001; // sub
                            default:    ALUControl = 4'b0000;
                        endcase
                    end
                    3'b001: ALUControl = 4'b0101; // sll
                    3'b010: ALUControl = 4'b1000; // slt
                    3'b011: ALUControl = 4'b1001; // sltu
                    3'b100: ALUControl = 4'b0100; // xor
                    3'b101: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0110; // srl
                            7'b0100000: ALUControl = 4'b0111; // sra 
                            default:    ALUControl = 4'b0110;
                        endcase
                    end
                    3'b110: ALUControl = 4'b0011; // or
                    3'b111: ALUControl = 4'b0010; // and

                    default: ALUControl = 4'b0000;
                endcase
            end

            // I-type instructions (Arithmetic/Logic)
            7'b0010011: begin
                RegWrite = 1'b1;
                ImmSrc = 3'b000; // I-type imm
                ALUSrcB = 1'b1;
                
                case(funct3)
                    3'b000: ALUControl = 4'b0000; // addi
                    3'b001: ALUControl = 4'b0101; // slli
                    3'b010: ALUControl = 4'b1000; // slti (Added)
                    3'b011: ALUControl = 4'b1001; // sltiu (Added)
                    3'b100: ALUControl = 4'b0100; // xori
                    3'b101: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0110; // srli
                            7'b0100000: ALUControl = 4'b0111; // srai 
                            default:    ALUControl = 4'b0110;
                        endcase
                    end
                    3'b110: ALUControl = 4'b0011; // ori
                    3'b111: ALUControl = 4'b0010; // andi
                    default: ALUControl = 4'b0000;
                endcase
            end

            // I-type Load instructions
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1; // SrcB = imm
                ResultSrc = 2'b01; // From Memory
                ImmSrc = 3'b000; // I-type imm
                AddressingControl = funct3;
                ALUControl = 4'b0000; // Add for address
            end

            // S-type Store instructions
            7'b0100011: begin
                MemWrite = 1'b1;
                ALUSrcB   = 1'b1; // read from immediate
                ImmSrc   = 3'b001; // S-type immediate
                ALUControl = 4'b0000; // Add for address
                AddressingControl = funct3;
            end

            // B-type Branch instructions
            7'b1100011: begin
                Branch = 1'b1;
                ImmSrc = 3'b010; // B-type imm
                BranchType = funct3;
                
                case(funct3)
                    // BEQ, BNE: ALU does SUB (0001)
                    // If A == B, Result = 0, Zero = 1
                    3'b000: ALUControl = 4'b0001; // beq
                    3'b001: ALUControl = 4'b0001; // bne
                    
                    // BLT, BGE: ALU does SLT (1000)
                    // If A < B: Result = 1, Zero = 0. If A >= B: Result = 0, Zero = 1.
                    3'b100: ALUControl = 4'b1000; // blt
                    3'b101: ALUControl = 4'b1000; // bge
                    
                    // BLTU, BGEU: ALU does SLTU (1001)
                    3'b110: ALUControl = 4'b1001; // bltu
                    3'b111: ALUControl = 4'b1001; // bgeu
                endcase
            end

            // J-type JAL
            7'b1101111: begin
                RegWrite = 1'b1;
                ResultSrc = 2'b10; // PC+4
                ImmSrc = 3'b011;   // J-type imm
                Jump = 2'b01;
            end

            // I-type JALR
            7'b1100111: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1; // SrcB = imm
                ResultSrc = 2'b10; // PC+4
                ImmSrc = 3'b000; // I-type imm
                Jump = 2'b10;
                // ALUControl = 4'b0000; // Add for target address
            end

            // U-type LUI
            7'b0110111: begin
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ResultSrc = 2'b00;
                ImmSrc = 3'b100; // U-type imm
                ALUControl = 4'b1111; // LUI operation (0 + imm shifted)
            end

            // U-type AUIPC rd <- PC + imm << 12
            7'b0010111: begin
                RegWrite = 1'b1;
                MemWrite = 1'b0;
                ALUSrcA = 1'b1;     // Select PC
                ALUSrcB = 1'b1;     // Select Imm
                ImmSrc = 3'b100;   // U-type imm
                ALUControl = 4'b000; // AUIPC operation (PC + imm shifted)
            end
            
            default: begin
               // Already handled by defaults at top
            end
        endcase
    end
endmodule