module decode(
    input logic        clk, 
    input logic        rst,
    input logic [31:0] InstrD1, //instruction to decode from pipeline 1
    input logic [31:0] InstrD2, //instruction to decode from pipeline 2
    input logic [31:0] ResultW1, //write data for pipeline 1 
    input logic [31:0] ResultW2, //write data for pipeline 2
    input logic [4:0] RdW1, // destination register address for pipeline 1
    input logic [4:0] RdW2, //destination register address for pipeline 2
    input logic RegWriteW1, // write enable for pipeline 1
    input logic RegWriteW2, // write enable for pipeline 2
    
    output logic [31:0] RD1D, //regfile output 1
    output logic [31:0] RD2D, //regfile output 2
    output logic [31:0] RD4D, //regfile output 4
    output logic [31:0] RD5D, //regfile output 5
    output logic [31:0] ImmExtD1,
    output logic [31:0] ImmExtD2,

    output logic [4:0] Rs1D,
    output logic [4:0] Rs2D,
    output logic [4:0] Rs4D,
    output logic [4:0] Rs5D,
    output logic [4:0] RdD1, //destination register for pipeline 1
    output logic [4:0] RdD2, //destination register for pipeline 2
    output logic        RegWriteD1,
    output logic [1:0]  ResultSrcD1,
    output logic        MemWriteD1,
    output logic [1:0]  JumpD1,
    output logic        BranchD1,
    output logic [2:0]  BranchTypeD1,
    output logic [3:0]  ALUControlD1,
    output logic        ALUSrcBD1,
    output logic        ALUSrcAD1,
    output logic [2:0]  AddressingControlD1,
    output logic        RegWriteD2,
    output logic [1:0]  ResultSrcD2,
    output logic        MemWriteD2,
    output logic [1:0]  JumpD2,
    output logic        BranchD2,
    output logic [2:0]  BranchTypeD2,
    output logic [3:0]  ALUControlD2,
    output logic        ALUSrcBD2,
    output logic        ALUSrcAD2,
    output logic [2:0]  AddressingControlD2,
    output logic [31:0] a0,
    output logic [31:0] a1
);

//Connections for extend block
    logic [2:0] ImmSrcD1;
    logic [2:0] ImmSrcD2;

    always_comb begin

        Rs1D = InstrD1[19:15];
        Rs2D = InstrD1[24:20];
        RdD1 = InstrD1[11:7];

        Rs4D = InstrD2[19:15];
        Rs5D = InstrD2[24:20];
        RdD2 = InstrD2[11:7];
    end

    control control_inst1(
        .opcode(InstrD1[6:0]),
        .funct3(InstrD1[14:12]),
        .funct7(InstrD1[31:25]),

        .RegWrite(RegWriteD1),
        .ALUControl(ALUControlD1),
        .ALUSrcA(ALUSrcAD1),
        .ALUSrcB(ALUSrcBD1),
        .MemWrite(MemWriteD1),
        .Branch(BranchD1),
        .BranchType(BranchTypeD1), 
        .Jump(JumpD1),
        .ImmSrc(ImmSrcD1),
        .AddressingControl(AddressingControlD1),
        .ResultSrc(ResultSrcD1)
    );

    control control_inst2(

        .opcode(InstrD2[6:0]),
        .funct3(InstrD2[14:12]),
        .funct7(InstrD2[31:25]),

        .RegWrite(RegWriteD2),
        .ALUControl(ALUControlD2),
        .ALUSrcA(ALUSrcAD2),
        .ALUSrcB(ALUSrcBD2),
        .MemWrite(MemWriteD2),
        .Branch(BranchD2),
        .BranchType(BranchTypeD2), 
        .Jump(JumpD2),
        .ImmSrc(ImmSrcD2),
        .AddressingControl(AddressingControlD2),
        .ResultSrc(ResultSrcD2)

    );


    reg_file reg_file_inst(
        .clk(clk),
        .AD3(RdW1),
        .AD1(InstrD1[19:15]),
        .AD2(InstrD1[24:20]),
        .AD4(InstrD2[19:15]),
        .AD5(InstrD2[24:20]),
        .AD6(RdW2),
        .WD3(ResultW1),
        .WD6(ResultW2),
        .WE3(RegWriteW1),
        .WE6(RegWriteW2),

        .RD1(RD1D),
        .RD2(RD2D),
        .RD4(RD4D),
        .RD5(RD5D),
        .a0(a0),
        .a1(a1)
    );


    sign_ext sign_ext1(
        .Imm(InstrD1[31:7]),
        .ImmSrc(ImmSrcD1),

        .ImmExt(ImmExtD1)
    );

    sign_ext sign_ext2(
        .Imm(InstrD2[31:7]),
        .ImmSrc(ImmSrcD2),

        .ImmExt(ImmExtD2)
    );


endmodule
