// CONTROL PATH
module control_path(
    input logic [31:0] Instr,
    input logic Zero,
    output logic [1:0] PCSrc,
    output logic RegWrite,
    output logic [3:0] ALUControl,
    output logic ALUSrcA,
    output logic ALUSrcB,
    output logic MemWrite,
    output logic [1:0] ResultSrc,
    output logic [2:0] ImmSrc,
    output logic [2:0] AddressingControl
);
    logic Branch;
    logic [2:0] BranchType;
    logic [1:0] Jump;

    logic [6:0] opcode = Instr[6:0];
    logic [2:0] funct3 = Instr[14:12];
    logic [6:0] funct7 = Instr[31:25];

    control control_unit(
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

    pcsrc_unit pcsrc_unit_inst(
        .Jump(Jump),
        .Branch(Branch),
        .Zero(Zero),
        .BranchType(BranchType),
        .PCSrc(PCSrc)
    );
endmodule
