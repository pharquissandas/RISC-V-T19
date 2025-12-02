module top (
    input logic clk,
    input logic rst,
    output logic [31:0] a0
);

// --- Wires for Pipeline Registers, Hazards, and Forwarding ---

// IF/ID Wires
logic [31:0] pcF, instrF, PCPlus4F;
logic [31:0] pcD, instrD, PCPlus4D;
logic PCWrite, IFIDWrite, FlushD;

// ID Wires (Outputs of ID stage, Inputs to ID/EX register)
logic RegWriteD, MemWriteD, MemReadD;
logic [1:0] ResultSrcD;
logic [3:0] ALUControlD;
logic ALUSrcA_Ctrl, ALUSrcB_Ctrl; 
logic [2:0] AddressingControlD;
logic Branch_Ctrl;
logic [2:0] BranchType_Ctrl;
logic [1:0] Jump_Ctrl;
logic [2:0] ImmSrcD;
logic [31:0] rd1D, rd2D, ImmExtD;
logic [4:0] Rs1D, Rs2D, RdD;

// ID/EX Register Outputs (Inputs to EX stage)
logic RegWriteE, MemWriteE, MemReadE;
logic [1:0] ResultSrcE;
logic [3:0] ALUControlE;
logic ALUSrcA_Reg; 
logic ALUSrcB_Reg; // Register control signals
logic [2:0] AddressingControlE;
logic BranchE; 
logic [2:0] BranchTypeE; 
logic [1:0] JumpE; 
logic [31:0] rd1E, rd2E, ImmExtE, pcE, PCPlus4E;
logic [4:0] Rs1E, Rs2E, RdE;
logic FlushE; // From Hazard Unit

// EX Wires (Outputs of EX stage)
logic [31:0] ALUResultE, WriteDataE_Store; // WriteDataE_Store is the data written to memory (Rd2 from RegFile)
logic Zero; // From ALU
logic BranchTakenE; // From pcsrc_unit
logic [1:0] PCSrc_Ctrl; // To PC Mux
logic [1:0] ForwardAE, ForwardBE; 

// EX/MEM Register Outputs (Inputs to MEM stage)
logic [31:0] ALUResultM, WriteDataM, PCPlus4M;
logic RegWriteM, MemWriteM, MemReadM;
logic [1:0] ResultSrcM;
logic [2:0] AddressingControlM;
logic [4:0] RdM;

// MEM Wires
logic [31:0] MemDataM;

// MEM/WB Register Outputs (Inputs to WB stage)
logic [31:0] ALUResultW, MemDataW, PCPlus4W;
logic RegWriteW;
logic [1:0] ResultSrcW;
logic [4:0] RdW;

// Final Writeback Data and Forwarding Mux Outputs
logic [31:0] ResultDataW; // Final value written to RegFile
logic [31:0] SrcA_Fwd, SrcB_Fwd; // Outputs of the forwarding MUXes
logic [31:0] ALUSrcA_Final, ALUSrcB_Final; // Final ALU inputs

// --- Muxes and Forwarding Logic (in EX stage) ---

// Forward A Mux: Selects the final Rs1 source
always_comb begin
    case (ForwardAE)
        2'b00: SrcA_Fwd = rd1E;    // Default: From Register File (ID/EX)
        2'b01: 
            case (ResultSrcW)     // Forward from MEM/WB (ResultDataW is chosen by ResultSrcW)
                2'b00: SrcA_Fwd = ALUResultW;  // ALU Result
                2'b01: SrcA_Fwd = MemDataW;   // Memory Read Data
                2'b10: SrcA_Fwd = PCPlus4W;   // PC+4 (JAL/JALR)
                default: SrcA_Fwd = 32'b0;
            endcase
        2'b10: SrcA_Fwd = ALUResultM;    // Forward from EX/MEM (ALUResultM)
        default: SrcA_Fwd = 32'b0;
    endcase
end

// Forward B Mux: Selects the final Rs2 source
always_comb begin
    case (ForwardBE)
        2'b00: SrcB_Fwd = rd2E;    // Default: From Register File (ID/EX)
        2'b01: 
            case (ResultSrcW)     // Forward from MEM/WB
                2'b00: SrcB_Fwd = ALUResultW; 
                2'b01: SrcB_Fwd = MemDataW;
                2'b10: SrcB_Fwd = PCPlus4W;
                default: SrcB_Fwd = 32'b0;
            endcase
        2'b10: SrcB_Fwd = ALUResultM;    // Forward from EX/MEM
        default: SrcB_Fwd = 32'b0;
    endcase
end

// ALU Source A Mux (Selects PC or SrcA_Fwd)
assign ALUSrcA_Final = ALUSrcA_Reg ? pcE : SrcA_Fwd;

// ALU Source B Mux (Selects Immediate or SrcB_Fwd)
assign ALUSrcB_Final = ALUSrcB_Reg ? ImmExtE : SrcB_Fwd;

// Write Data for Stores (rs2 value, must be forwarded)
assign WriteDataE_Store = SrcB_Fwd;

// Final Writeback Mux (in WB stage)
always_comb begin
    case(ResultSrcW)
        2'b00: ResultDataW = ALUResultW; // R-Type, I-Type, JALR
        2'b01: ResultDataW = MemDataW;  // Load Instruction
        2'b10: ResultDataW = PCPlus4W;  // JAL 
        default: ResultDataW = 32'b0;
    endcase
end

// --- STAGE 1: Instruction Fetch (IF) ---

pc pc_inst (
    .clk(clk),
    .rst(rst),
    .PCWrite(PCWrite),    // Stall signal
    .PCSrc(PCSrc_Ctrl),
    .ImmExt(ImmExtE),    // Branch/Jump offset (from EX stage)
    .ALUResult(ALUResultE), // JALR target (from EX stage)
    .PCPlus4(PCPlus4F),
    .PC(pcF)
);

instr_mem instr_mem_inst (
    .A(pcF),
    .RD(instrF)
);

// IF/ID pipeline register
fetch_decode_pipe if_id (
    .clk(clk),
    .rst(rst),
    .IFIDWrite(IFIDWrite), // Stall control
    .FlushD(FlushD),    // Flush control for control hazards
    .pcF(pcF),
    .instrF(instrF),
    .PCPlus4F(PCPlus4F),
    .pcD(pcD),
    .instrD(instrD),
    .PCPlus4D(PCPlus4D)
);

// --- STAGE 2: Instruction Decode (ID) ---

// Register File (Write in WB, Read in ID)
reg_file reg_file_inst(
    .clk(clk),
    .AD3(RdW),       // Destination from WB
    .AD1(instrD[19:15]),  // Rs1
    .AD2(instrD[24:20]),  // Rs2
    .WD3(ResultDataW),   // Data from WB Mux
    .WE3(RegWriteW),    // Write Enable from WB
    .RD1(rd1D),
    .RD2(rd2D),
    .a0(a0)
);

// Control Unit (Generates all control signals)
control control_unit_inst(
    .opcode(instrD[6:0]),
    .funct3(instrD[14:12]),
    .funct7(instrD[31:25]),
    .RegWrite(RegWriteD),
    .ALUControl(ALUControlD),
    .ALUSrcA(ALUSrcA_Ctrl),
    .ALUSrcB(ALUSrcB_Ctrl),
    .MemWrite(MemWriteD),
    .ResultSrc(ResultSrcD),
    .Branch(Branch_Ctrl),
    .BranchType(BranchType_Ctrl),
    .Jump(Jump_Ctrl),
    .ImmSrc(ImmSrcD),
    .AddressingControl(AddressingControlD)
);

// Imm Extender
sign_ext sign_ext_inst(
    .Imm(instrD[31:7]),
    .ImmSrc(ImmSrcD),
    .ImmExt(ImmExtD)
);

// Register IDs for ID/EX pipe
assign Rs1D = instrD[19:15];
assign Rs2D = instrD[24:20];
assign RdD = instrD[11:7];
// MemRead is not directly output by the control unit; derive it from ResultSrc
// (ResultSrc == 2'b01 indicates a load instruction).
assign MemReadD = (ResultSrcD == 2'b01);
// ALUSrcA_Reg and ALUSrcB_Reg are outputs from the ID/EX pipeline register
// They should *not* be driven as continuous assignments here (that would create
// conflicting drivers with the non-blocking assignments inside the pipeline
// register). The ID/EX register instance `id_ex` will drive ALUSrcA_Reg and
// ALUSrcB_Reg (instantiated as ALUsrcAE/ALUsrcBE). Do not reassign them here.

// ID/EX pipeline register
decode_execute_pipe id_ex (
    .clk(clk),
    .rst(rst),
    .FlushE(FlushE),
    
    // Inputs: Control and Data from ID
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .MemReadD(MemReadD),
    .BranchD(Branch_Ctrl),    
    .BranchTypeD(BranchType_Ctrl), 
    .JumpD(Jump_Ctrl),      
    .ALUControlD(ALUControlD),
    .ALUsrcAD(ALUSrcA_Ctrl),    
    .ALUsrcBD(ALUSrcB_Ctrl),    
    .LS_modeD(AddressingControlD),

    .rd1D(rd1D),
    .rd2D(rd2D),
    .pcD(pcD),
    .PCPlus4D(PCPlus4D),
    .ImmExtD(ImmExtD),
    .Rs1D(Rs1D), .Rs2D(Rs2D),
    .RdD(RdD),

    // Outputs to EX
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .MemReadE(MemReadE),
    .BranchE(BranchE),
    .BranchTypeE(BranchTypeE),
    .JumpE(JumpE),
    .ALUControlE(ALUControlE),
    .ALUsrcAE(ALUSrcA_Reg),
    .ALUsrcBE(ALUSrcB_Reg),
    .LS_modeE(AddressingControlE),
    
    .rd1E(rd1E), .rd2E(rd2E), .pcE(pcE), .PCPlus4E(PCPlus4E),
    .ImmExtE(ImmExtE), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE)
);

// --- STAGE 3: Execute (EX) ---

// Forwarding Unit
forwarding_unit forwarding_unit_inst (
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RegWriteM(RegWriteM),
    .RdM(RdM),
    .RegWriteW(RegWriteW),
    .RdW(RdW),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE)
);

// ALU (operates on MUX outputs)
alu alu_inst(
    .SrcA(ALUSrcA_Final),
    .SrcB(ALUSrcB_Final),
    .ALUControl(ALUControlE),
    .ALUResult(ALUResultE),
    .Zero(Zero)
);

// Branch Resolution Unit
pcsrc_unit pcsrc_unit_inst(
    .Jump(JumpE),
    .Branch(BranchE),
    .Zero(Zero),
    .BranchType(BranchTypeE),
    .PCSrc(PCSrc_Ctrl),      
    .BranchTaken(BranchTakenE) 
);

// Hazard Unit (Resolves stalls and flushes)
hazard_unit hazard_unit_inst (
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .MemReadE(MemReadE),
    .RdE(RdE),
    .BranchTakenE(BranchTakenE),
    .JumpE(JumpE),
    .JALRE(1'b0), // JumpE covers JALR detection
    .PCWrite(PCWrite),   
    .IFIDWrite(IFIDWrite), 
    .FlushE(FlushE),    
    .FlushD(FlushD)    
);

// EX/MEM pipeline register
execute_memory_pipe ex_mem ( 
    .clk(clk),
    .rst(rst),
    .ALUResultE(ALUResultE),
    .WriteDataE(WriteDataE_Store), // Stored data is the forwarded Rd2
    .PCPlus4E(PCPlus4E),
    .MemWriteE(MemWriteE),
    .MemReadE(MemReadE),
    .RdE(RdE),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .LS_modeE(AddressingControlE),
    
    .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .PCPlus4M(PCPlus4M),
    .MemWriteM(MemWriteM), .MemReadM(MemReadM),
    .RdM(RdM), .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM), .LS_modeM(AddressingControlM)
);

// --- STAGE 4: Memory (MEM) ---

// Data Memory
data_mem data_mem_inst(
    .clk(clk),
    .WE(MemWriteM),
    .A(ALUResultM),
    .WD(WriteDataM),
    .AddressingControl(AddressingControlM),
    .RD(MemDataM)
);

// MEM/WB pipeline register
memory_writeback_pipe mem_wb (
    .clk(clk),
    .rst(rst),
    .ALUResultM(ALUResultM),
    .MemDataM(MemDataM),
    .RdM(RdM),
    .RegWriteM(RegWriteM),
    .PCPlus4M(PCPlus4M),
    .ResultSrcM(ResultSrcM),
    
    .ALUResultW(ALUResultW), .MemDataW(MemDataW), // Output signals
    .RdW(RdW), .RegWriteW(RegWriteW),
    .PCPlus4W(PCPlus4W), .ResultSrcW(ResultSrcW)
);

// --- STAGE 5: Writeback (WB) ---

// The writeback logic uses the ResultDataW MUX and drives the RegFile.

endmodule
