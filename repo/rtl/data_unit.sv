module data_unit #(
    parameter DATA_WIDTH = 32,
              ADDRESS_WIDTH = 5
) (
    input  logic                       clk,
    input  logic [ADDRESS_WIDTH-1:0]   AD1,    // rs1 address
    input  logic [ADDRESS_WIDTH-1:0]   AD2,    // rs2 address
    input  logic [ADDRESS_WIDTH-1:0]   AD3,    // rd address
    input  logic [DATA_WIDTH-1:0]      ImmOp,  // immediate value
    input  logic                       RegWrite, // write enable to register file
    input  logic                       MemWrite, // write enable to memory
    input  logic                       ALUctrl,  // ALU control
    input  logic                       ALUsrc,   // select imm or reg
    input  logic [1:0]                 ResultSrc, // select ALU or mem data
    input  logic [2:0]                 funct3,   // for memory access size
    input logic  [DATA_WIDTH-1:0]      PCtarget, // branch target address
    input logic [DATA_WIDTH-1:0]       PC,
    input logic [6:0]                  opcode,
    output logic [2:0]                 EQ,       // ALU equality flag
    output logic [DATA_WIDTH-1:0]      a0,        // x10 output
    output logic [DATA_WIDTH-1:0]      ALUout    // ALU result
);

logic [DATA_WIDTH-1:0] ALUop1;   // ALU operand 1
logic [DATA_WIDTH-1:0] ALUop2;   // ALU operand 2
logic [DATA_WIDTH-1:0] WriteData;   // register file output 2
logic [DATA_WIDTH-1:0] ReadData;    // data memory output
logic [DATA_WIDTH-1:0] result;      // data to write back to register file

// register file: read rs1/rs2, write rd
reg_file reg_file (
    .clk(clk),
    .read_addr1(AD1),
    .read_addr2(AD2),
    .write_addr(AD3),
    .wd3(ALUout),
    .we3(RegWrite),
    .dout1(ALUop1),
    .dout2(WriteData),
    .a0(a0)
);

// select ALU operand 2: register or immediate
mux mux1 (
    .in0(WriteData),
    .in1(ImmOp),
    .sel(ALUsrc),
    .out(ALUop2)
);

// ALU executes operation and sets EQ
alu alu (
    .alu_op1(ALUop1),
    .alu_op2(ALUop2),
    .alu_ctrl(ALUctrl),
    .alu_out(ALUout),
    .eq(EQ),
    .PC(PC)
);

// memory
data_mem data_mem (
    .clk(clk),
    .en(MemWrite),
    .wr_addr(ALUout),
    .din(WriteData),
    .dout(ReadData),
    .funct3(funct3)
);

always_comb begin

    case (ResultSrc)
        2'b00: assign ALUout = ALUout;        // ALU result
        2'b01: assign ALUout = ReadData;      // Memory data
        2'b10: assign ALUout = PCtarget;      // PC + 4 for JAL/JALR
        default: assign ALUout = ALUout;      // Default to ALU result
    endcase

end

endmodule
