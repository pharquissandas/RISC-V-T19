module decode_execute_pipe #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic FlushE, // From Hazard Unit: Flushes the pipe (inserts NOP)
    
    // --- Control signals from ID ---
    input logic RegWriteD,
    input logic [1:0] ResultSrcD,
    input logic MemWriteD,
    input logic MemReadD,
    input logic [3:0] ALUControlD,
    input logic ALUsrcAD,    // Source A Mux control (PC or Rs1)
    input logic ALUsrcBD,    // Source B Mux control (Imm or Rs2)
    input logic [2:0] LS_modeD,   // Load/Store Addressing Control
    input logic BranchD,    // Branch instruction flag (for pcsrc_unit)
    input logic [2:0] BranchTypeD, // Branch type (BEQ, BNE, etc.)
    input logic [1:0] JumpD,    // Jump instruction flag (JAL, JALR)

    // --- Data signals from ID ---
    input logic [DATA_WIDTH-1:0] rd1D,   // Read Data 1 (Rs1 value)
    input logic [DATA_WIDTH-1:0] rd2D,   // Read Data 2 (Rs2 value/Store Data)
    input logic [DATA_WIDTH-1:0] pcD,    // Current PC (for AUIPC)
    input logic [DATA_WIDTH-1:0] PCPlus4D, // PC + 4 (for JAL, JALR)
    input logic [DATA_WIDTH-1:0] ImmExtD,  // Sign-extended Immediate
    input logic [4:0] Rs1D,      // Rs1 Register Address
    input logic [4:0] Rs2D,      // Rs2 Register Address
    input logic [4:0] RdD,       // Rd Register Address

    // --- Outputs to EX ---
    output logic RegWriteE,
    output logic [1:0] ResultSrcE,
    output logic MemWriteE,
    output logic MemReadE,
    output logic [3:0] ALUControlE,
    output logic ALUsrcAE,    // Source A Mux control (PC or Rs1)
    output logic ALUsrcBE,    // Source B Mux control (Imm or Rs2)
    output logic [2:0] LS_modeE,
    output logic BranchE,
    output logic [2:0] BranchTypeE,
    output logic [1:0] JumpE,
    
    output logic [DATA_WIDTH-1:0] rd1E,
    output logic [DATA_WIDTH-1:0] rd2E,
    output logic [DATA_WIDTH-1:0] pcE,
    output logic [DATA_WIDTH-1:0] PCPlus4E,
    output logic [DATA_WIDTH-1:0] ImmExtE,
    output logic [4:0] Rs1E, 
    output logic [4:0] Rs2E,
    output logic [4:0] RdE
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst || FlushE) begin
            // Reset/Flush: Insert NOP (RegWrite=0, everything else cleared)
            RegWriteE <= 1'b0; 
            MemWriteE <= 1'b0; 
            MemReadE  <= 1'b0;
            ResultSrcE <= 2'b00; 
            ALUControlE <= 4'b0000;
            ALUsrcAE  <= 1'b0; 
            ALUsrcBE  <= 1'b0; 
            LS_modeE  <= 3'b000;
            BranchE  <= 1'b0; // Important: Clear all branch/jump signals on flush
            BranchTypeE <= 3'b000;
            JumpE   <= 2'b00;

            rd1E    <= 32'b0; 
            rd2E    <= 32'b0; 
            pcE    <= 32'b0; 
            PCPlus4E  <= 32'b0;
            ImmExtE  <= 32'b0; 
            Rs1E    <= 5'b0; 
            Rs2E    <= 5'b0; 
            RdE    <= 5'b0;
        end else begin
            // Pass-through (Normal operation)
            RegWriteE <= RegWriteD; 
            ResultSrcE <= ResultSrcD; 
            MemWriteE <= MemWriteD; 
            MemReadE  <= MemReadD;
            ALUControlE <= ALUControlD;
            ALUsrcAE  <= ALUsrcAD; 
            ALUsrcBE  <= ALUsrcBD; 
            LS_modeE  <= LS_modeD;
            BranchE  <= BranchD;
            BranchTypeE <= BranchTypeD;
            JumpE   <= JumpD;

            rd1E    <= rd1D; 
            rd2E    <= rd2D; 
            pcE    <= pcD; 
            PCPlus4E  <= PCPlus4D;
            ImmExtE  <= ImmExtD; 
            Rs1E    <= Rs1D; 
            Rs2E    <= Rs2D; 
            RdE    <= RdD;
        end
    end
endmodule
