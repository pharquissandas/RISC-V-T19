module decode(
    input logic        clk, 
    input logic [31:0] InstrD, //instruction to decode
    input logic [31:0] PCD,
    input logic predict_taken_D,
    input logic [31:0] ResultW,
    input logic [4:0] RdW,
    input logic RegWriteW,
    
    output logic [31:0] RD1D, //regfile output 1
    output logic [31:0] RD2D, //regfile output 2
    output logic [31:0] ImmExtD,

    output logic [4:0] Rs1D,
    output logic [4:0] Rs2D,
    output logic [4:0] RdD,

    output logic        RegWriteD,
    output logic [1:0]  ResultSrcD,
    output logic        MemWriteD,
    output logic [1:0]  JumpD,
    output logic        BranchD,
    output logic [2:0]  BranchTypeD,
    output logic [3:0]  ALUControlD,
    output logic        ALUSrcBD,
    output logic        ALUSrcAD,
    output logic [2:0]  AddressingControlD,
    output logic pc_predict_redirect_D,
    output logic [31:0] predicted_target_pc_D,

    output logic [31:0] a0
);

//Connections for extend block
    logic [2:0] ImmSrcD;
    logic [31:0] calculated_BTA_D;
    assign calculated_BTA_D = PCD + ImmExtD;
    assign predicted_target_pc_D = calculated_BTA_D;
    assign pc_predict_redirect_D = predict_taken_D && BranchD;

    always_comb begin
        Rs1D = InstrD[19:15];
        Rs2D = InstrD[24:20];
        RdD = InstrD[11:7];
    end

    control control_inst(
        .opcode(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),

        .RegWrite(RegWriteD),
        .ALUControl(ALUControlD),
        .ALUSrcA(ALUSrcAD),
        .ALUSrcB(ALUSrcBD),
        .MemWrite(MemWriteD),
        .Branch(BranchD),
        .BranchType(BranchTypeD), 
        .Jump(JumpD),
        .ImmSrc(ImmSrcD),
        .AddressingControl(AddressingControlD),
        .ResultSrc(ResultSrcD)
    );


    reg_file reg_file_inst(
        .clk(clk),
        .AD3(RdW),
        .AD1(InstrD[19:15]),
        .AD2(InstrD[24:20]),
        .WD3(ResultW),
        .WE3(RegWriteW),

        .RD1(RD1D),
        .RD2(RD2D),
        .a0(a0)
    );


    sign_ext sign_ext1(
        .Imm(InstrD[31:7]),
        .ImmSrc(ImmSrcD),

        .ImmExt(ImmExtD)
    );
endmodule
