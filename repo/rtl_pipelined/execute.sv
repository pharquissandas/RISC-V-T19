module execute(

input logic        RegWriteE,
input logic [1:0]  ResultSrcE,
input logic        MemWriteE,
input logic        JumpE,
input logic        BranchE,
input logic [1:0]  ALUControlE,
input logic        ALUSrcE,
input logic [31:0] RD1E,
input logic [31:0] RD2E,
input logic [31:0] PCE,
input logic [4:0]  Rs1E,
input logic [4:0]  Rs2E,
input logic [31:0] ExtImmE,
input logic [31:0] SrcAE,
input logic [31:0] WriteDataE,

output logic PCSrcE,
output logic [31:0] ALUResultE,
output logic [31:0] PCTargetE

);

logic ZeroE;
logic tmp;

always_comb begin

    tmp = (ZeroE & BranchE);
    PCSrcE = (tmp | JumpE);

    PCTargetE  = PCE + ExtImmE;

end



mux mux2(

    .s(ALUSrcE),
    .d0(WriteDataE),
    .d1(ExtImmE),
    
    .y(SrcBE)

);


alu alu1(

.SrcA(SrcAE),
.SrcB(SrcBE),
.ALUControl(ALUControlE),

.ALUResult(ALUResultE),
.Zero(ZeroE)

);

endmodule
