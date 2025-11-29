module decode(

    input logic [31:0] InstrD, //instruction to decode
    input logic        WD3,    
    input logic [31:0] A3,    //data from writeback stage to write into regfile
    input logic        WE3, 

    output logic [31:0] RD1, //regfile output 1
    output logic [31:0] RD2, //regfile output 2
    output logic [31:0] ExtImmd,
    output logic [19:15] Rs1D,
    output logic [24:20] Rs2D,
    output logic        RegWriteD,
    output logic [1:0]  ResultSrcD,
    output logic        MemWriteD,
    output logic        JumpD,
    output logic        BranchD,
    output logic [2:0]  BranchTypeD,
    output logic [1:0]  ALUControlD,
    output logic        AluSrcBD,
    output logic        ALUSrcAD,
    output logic [2:0]  AddressingControlD,
    output logic [31:0] a0D

);

//Connections for control unit
logic [6:0] op;
logic [14:12] funct3;
logic         funct7;
logic [19:15] A1;
logic [24:20] A2;

//Connections for extend block
logic [1:0] ImmSrcD;
logic [31:7] Imm;

always_comb begin

    op = InstrD[6:0];
    funct3 = InstrD[14:12];
    funct7 = InstrD[30];
    A1 = InstrD[19:15];
    A2 = InstrD[24:20];
    Imm = InstrD[31:7];
    
    Rs1D = InstrD[19:15];
    Rs2D = InstrD[24:20];
    
end




control control1(

    .op(op),
    .funct3(funct3),
    .funct7(funct7),

    .RegWrite(RegWriteD),
    .ALUControl(ALUControlD),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(AluSrcBD),
    .MemWrite(MemWriteD),
    .Branch(BranchD),
    .BranchType(BranchTypeD), 
    .Jump(JumpD),
    .ImmSrc(ImmSrcD),
    .AddressingControl(AddressingControlD)

);


reg_file reg_file1(

.clk(clk),
.AD3(A3),
.AD1(A1),
.AD2(A2),
.WD3(WD3),
.WE3(WE3),

.RD1(RD1),
.RD2(RD2),
.a0(a0D)

);


sign_ext sign_ext1(

.Imm(Imm),
.ImmSrc(ImmSrcD),

.ImmExt(ExtImmd)

);


endmodule
