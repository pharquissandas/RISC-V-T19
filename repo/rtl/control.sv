module control (
    input logic [31:0] Instr,
    input logic Zero,
    
    output logic [2:0] AddressingControl, // hand to data memory for bit selection (000 = lb/sb, 001 = lh/sh, 010 = lw/sw, 100 = lbu, 101 = lhu)    
    output logic       RegWrite,   // enable writing to register file
    output logic       ALUSrc,     // selects ALU second operand (0 = register, 1 = immediate)
    output logic       MemWrite,   // enable writing to data memory
    output logic [1:0] ResultSrc,  // control the source of data to write back to register file (00 = ALU, 01 = Memory, 10 = PC+4, 11 = imm)
    output logic [1:0] PCSrc,      // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
    output logic       Branch,     // indicates branch instruction
    output logic       Jump,       // indicates jump instruction
    output logic [2:0] ImmSrc,     // selects type of immediate (I = 000, S = 001, B = 010, J = 011, U = 100)
    output logic [3:0] ALUControl    // selects ALU operation
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];
    assign AddressingControl = funct3; // store width

    // wires between decoders
    logic [1:0] ALUOp;

    main_decoder main_dec (
        .opcode(opcode),
        .funct3(funct3),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ImmSrc(ImmSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    alu_decoder alu_dec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    always_comb begin
        PCSrc = 2'b00; // default PC+4

        if (Branch) begin
            unique case (funct3)
                3'b000: PCSrc = Zero ? 2'b01 : 2'b00; // BEQ
                3'b001: PCSrc = ~Zero ? 2'b01 : 2'b00; // BNE
                3'b100: PCSrc = ~Zero ? 2'b01 : 2'b00; // BLT
                3'b101: PCSrc = Zero ? 2'b01 : 2'b00; // BGE
                3'b110: PCSrc = ~Zero ? 2'b01 : 2'b00; // BLTU
                3'b111: PCSrc = Zero ? 2'b01 : 2'b00; // BGEU
            endcase
        end

        if (opcode == 7'b1101111) PCSrc = 2'b01; // JAL
        if (opcode == 7'b1100111) PCSrc = 2'b10; // JALR
    end

endmodule
