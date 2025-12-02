module execute(

input logic [1:0]  JumpE,
input logic        BranchE,
input logic [3:0]  ALUControlE,
input logic        ALUSrcAE,
input logic        ALUSrcBE,
input logic [31:0] PCE,
input logic [31:0] ImmExtE,
input logic [31:0] SrcAE, //comes from hazard unit
input logic [31:0] WriteDataE,
input logic [2:0]  BranchTypeE,

output logic [1:0]  PCSrcE,
output logic [31:0] ALUResultE,
output logic [31:0] PCTargetE

);

logic ZeroE;
//logic tmp;


logic [31:0] SrcBE;
logic [31:0] SrcAEE;

always_comb begin

    //tmp = (ZeroE & BranchE); // is this needed?
    //PCSrcE = (tmp | JumpE);

    PCTargetE  = PCE + ImmExtE;

end



mux mux2(

    .s(ALUSrcBE),
    .d0(WriteDataE),
    .d1(ImmExtE),
    
    .y(SrcBE)

);

mux mux3(

    .s(ALUSrcAE),
    .d1(PCE),
    .d0(SrcAE),
    
    .y(SrcAEE)

);


alu alu1(

.SrcA(SrcAEE),
.SrcB(SrcBE),
.ALUControl(ALUControlE),

.ALUResult(ALUResultE),
.Zero(ZeroE)

);

pcsrc_unit pcsrc_unit1(

.Jump(JumpE),
.Branch(BranchE),
.Zero(ZeroE),
.BranchType(BranchTypeE),

.PCSrc(PCSrcE)

);

endmodule
