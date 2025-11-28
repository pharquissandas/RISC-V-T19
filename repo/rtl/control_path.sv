module control_path(
    output logic [31:0]  Instr,
    input  logic         Zero,

    output logic [1:0] PCSrc, // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
    output logic RegWrite,  // enable write to register
    output logic [3:0] ALUControl, // control operation in ALU
    output logic ALUSrcA, // choose PC (1) or register (0) for ALU operand A
    output logic ALUSrcB, // choose immediate (1) or register (0) operand    
    output logic MemWrite, // enable write into the data memory
    // output logic [1:0] PCSrc, // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
    output logic [1:0] ResultSrc, // control the source of data to write back to register file (00 = ALU, 01 = Memory, 10 = PC+4)
    output logic [2:0] ImmSrc, // selects type of immediate (I = 000, S = 001, B = 010, J = 011, U = 100)
    output logic [2:0] AddressingControl // choose which type of load/store instruction to perform 
);

    logic Branch;
    logic [2:0] BranchType;
    logic [1:0] Jump;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];

    control control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .BranchType(BranchType),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .AddressingControl(AddressingControl)
    );

    pcsrc_unit pcsrc_unit_inst (
        .Jump(Jump),
        .Branch(Branch),
        .Zero(Zero),
        .BranchType(BranchType),
        .PCSrc(PCSrc),
        .ALUResult(ALUResult)
    );
    
endmodule
