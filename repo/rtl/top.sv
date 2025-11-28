module top (
    input  logic clk,
    input  logic rst,
    input  logic trigger,
    output logic [31:0] a0
);

    // Control signals
    logic [1:0] PCSrc;
    logic       RegWrite;
    logic [3:0] ALUControl;
    logic       ALUSrcA;
    logic       ALUSrcB;
    logic       MemWrite;
    logic [1:0] ResultSrc;
    logic [2:0] ImmSrc;
    logic [2:0] AddressingControl;

    // Datapath outputs
    logic [31:0] Zero;
    logic [31:0] Instr1;

    // Datapath
    data_path dp_inst (
        .clk(clk),
        .rst(rst),

        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .ImmSrc(ImmSrc),
        .AddressingControl(AddressingControl),

        .Instr(Instr),
        .Zero(Zero),
        .a0(a0)
    );

    // Control path
    control_path ctrl_inst (
        .Instr(Instr),
        .Zero(Zero),

        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .ImmSrc(ImmSrc),
        .AddressingControl(AddressingControl)
    );

endmodule
