module main_decoder (
    input logic [6:0]  opcode,     // 7-bit opcode field from the instruction
    input logic [2:0]  funct3,     // 3-bit funct3 field from the instruction
    
    output logic       RegWrite,   // enable writing to register file
    output logic       ALUSrc,     // selects ALU second operand (0 = register, 1 = immediate)
    output logic       MemWrite,   // enable writing to data memory
    output logic [1:0] ResultSrc,  // control the source of data to write back to register file (00 = ALU, 01 = Memory, 10 = PC+4, 11 = imm)
    output logic       Branch,     // indicates branch instruction
    output logic       Jump,       // indicates jump instruction
    output logic [2:0] ImmSrc,     // selects type of immediate (I = 000, S = 001, B = 010, J = 011, U = 100)
    output logic [1:0] ALUOp       // encodes ALU operation type (00 = ADD category(load/store/addi/auipc/jalr), 01 = SUB category(branch), 10 = R-type/I-type)
    
);

// combinational logic to decode opcode and generate control signals
always_comb begin
    // default values (safe defaults)
    RegWrite = 1'b0;
    ALUSrc   = 1'b0;
    MemWrite = 1'b0;
    ResultSrc = 2'b00;
    Branch   = 1'b0;
    Jump     = 1'b0;
    ImmSrc   = 3'b000;
    ALUOp    = 2'b00;

    case(opcode)
    
        // load instructions: LB, LH, LW, LBU, LHU
        // opcode = 0000011 
        7'b0000011: begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ResultSrc = 2'b01;       // load data from memory
            ImmSrc    = 3'b000;   // I-type immediate
            ALUOp     = 2'b00;   // ALU does ADD for address
        end

        // store instructions: SB, SH, SW S-type
        // opcode = 0100011
        7'b0100011: begin
            MemWrite = 1'b1;
            ALUSrc   = 1'b1;
            ImmSrc   = 3'b001; // S-type immediate
        end

        // R-type instructions: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
        // opcode = 0110011
        7'b0110011: begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b0;
            ALUOp    = 2'b10;
        end

        // B-type instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
        // opcode = 1100011
        7'b1100011: begin
            Branch    = 1'b1;
            ImmSrc    = 3'b010;   // B-type immediate
            ALUOp     = 2'b01;   // ALU does SUB for BEQ/BNE (other comparisons handled in ALU decoder)
        end

        // I-type arithmetic: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        // opcode = 0010011
        7'b0010011: begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ImmSrc   = 3'b000; // I-type immediate

            case (funct3)
                3'b000: ALUOp = 2'b00;
            
            default: ALUOp = 2'b10;

            endcase
        end

        // AUIPC (U-type)
        // opcode = 0010111
        7'b0010111: begin
            RegWrite  = 1'b1;
            ImmSrc    = 3'b100;   // U-type immediate
            ALUSrc    = 1'b1;
            ALUOp     = 2'b00;
            ResultSrc = 2'b00;
        end

        // LUI (U-type)
        // opcode = 0110111
        7'b0110111: begin
            RegWrite  = 1'b1;
            ImmSrc    = 3'b100;   // U-type immediate
            ResultSrc = 2'b00;
            ALUSrc    = 1'b1;
            ALUOp     = 2'b00; //ALU does ADD with 0 + imm
        end

        // JAL (J-type)
        // opcode = 1101111
        7'b1101111: begin
            RegWrite  = 1'b1;
            Jump      = 1'b1;
            ResultSrc = 2'b10;       // return address is PC+4 written to rd
            ImmSrc    = 3'b011;   // J-type immediate
        end

        // JALR (I-type)
        // opcode = 1100111
        7'b1100111: begin
            RegWrite  = 1'b1;
            Jump      = 1'b1;
            ResultSrc = 2'b10;       // return address is PC+4 written to rd
            ImmSrc    = 3'b000;   // I-type immediate
            ALUSrc    = 1'b1;
            ALUOp     = 2'b00;   // ALU does ADD for address calculation
        end
    endcase
end

endmodule