module control (
    input  logic [31:0] instr,
    input  logic       EQ,        // ALU zero/equality flag

    output logic        RegWrite,
    output logic        ALUSrc,
    output logic [2:0]  ALUctrl,
    output logic [1:0]  ImmSrc,
    output logic [1:0]  ResultSrc,
    output logic        MemWrite,
    output logic        PCsrc    
);

    // fields
    logic [6:0] opcode = instr[6:0];
    logic [2:0] funct3 = instr[14:12];
    logic [6:0] funct7 = instr[31:25];

    // wires between decoders
    logic Branch;
    logic [1:0] ALUOp;

    // instantiate main decoder
    main_decoder main_dec (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ImmSrc(ImmSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

        // instantiate ALU decoder
    alu_decoder alu_dec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct75(funct7[5]),
        .ALUctrl(ALUctrl)
    );

    // PCsrc: branch AND zero
    assign PCsrc = Branch & EQ;

endmodule

