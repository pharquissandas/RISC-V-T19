module decode_to_execute_register(
    input logic clk,
    input logic rst1,
    input logic rst2,
    input logic en1,
    input logic en2,

    // control signals from Control.sv
    input logic RegWriteD1,
    input logic [1:0] ResultSrcD1,
    input logic MemWriteD1,
    input logic [1:0] JumpD1,
    input logic BranchD1,
    input logic [3:0] ALUControlD1,
    input logic ALUSrcAD1,
    input logic ALUSrcBD1,
    input logic [2:0] AddressingControlD1,
    input logic [2:0] BranchTypeD1,

    input logic RegWriteD2,
    input logic [1:0] ResultSrcD2,
    input logic MemWriteD2,
    input logic [1:0] JumpD2,
    input logic BranchD2,
    input logic [3:0] ALUControlD2,
    input logic ALUSrcAD2,
    input logic ALUSrcBD2,
    input logic [2:0] AddressingControlD2,
    input logic [2:0] BranchTypeD2,

    // data signals from reg_file.sv & instructions
    input logic [31:0] RD1D,
    input logic [31:0] RD2D,
    input logic [31:0] RD4D,
    input logic [31:0] RD5D,
    input logic [31:0] PCD1,
    input logic [31:0] PCD2,
    input logic [4:0] Rs1D,
    input logic [4:0] Rs2D,
    input logic [4:0] Rs4D,
    input logic [4:0] Rs5D,
    input logic [4:0] RdD1,
    input logic [4:0] RdD2,
    input logic [31:0] ImmExtD1,
    input logic [31:0] ImmExtD2,
    input logic [31:0] PCPlus8D1,
    input logic [31:0] PCPlus8D2,

    output logic RegWriteE1,
    output logic [1:0] ResultSrcE1,
    output logic MemWriteE1,
    output logic [1:0] JumpE1,
    output logic BranchE1,
    output logic [3:0] ALUControlE1,
    output logic ALUSrcAE1,
    output logic ALUSrcBE1,
    output logic [2:0] AddressingControlE1,
    output logic [2:0] BranchTypeE1,

    output logic RegWriteE2,
    output logic [1:0] ResultSrcE2,
    output logic MemWriteE2,
    output logic [1:0] JumpE2,
    output logic BranchE2,
    output logic [3:0] ALUControlE2,
    output logic ALUSrcAE2,
    output logic ALUSrcBE2,
    output logic [2:0] AddressingControlE2,
    output logic [2:0] BranchTypeE2,

    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] RD4E,
    output logic [31:0] RD5E,
    output logic [31:0] PCE1,
    output logic [31:0] PCE2,
    output logic [4:0] Rs1E,
    output logic [4:0] Rs2E,
    output logic [4:0] Rs4E,
    output logic [4:0] Rs5E,
    output logic [4:0] RdE1,
    output logic [4:0] RdE2,
    output logic [31:0] ImmExtE1,
    output logic [31:0] ImmExtE2,
    output logic [31:0] PCPlus8E1,
    output logic [31:0] PCPlus8E2
);
    always_ff @(posedge clk) begin

        if(rst1) begin

            RegWriteE1 <= 1'b0;
            ResultSrcE1 <= 2'b0;
            MemWriteE1 <= 1'b0;
            JumpE1 <= 2'b0;
            BranchE1 <= 1'b0;
            ALUControlE1 <= 4'b0;
            ALUSrcAE1 <= 1'b0;
            ALUSrcBE1 <= 1'b0;
            AddressingControlE1 <= 3'b0;
            BranchTypeE1 <= 3'b0;

            RD1E <= 31'b0;
            RD2E <= 31'b0;
            PCE1 <= 31'b0;
            Rs1E <= 5'b0;
            Rs2E <= 5'b0;
            RdE1 <= 5'b0;
            ImmExtE1 <= 31'b0;
            PCPlus8E1 <= 31'b0;

        end

        else if (en1) begin
            RegWriteE1 <= RegWriteD1;
            ResultSrcE1 <= ResultSrcD1;
            MemWriteE1 <= MemWriteD1;
            JumpE1 <= JumpD1;
            BranchE1 <= BranchD1;
            ALUControlE1 <= ALUControlD1;
            ALUSrcAE1 <= ALUSrcAD1;
            ALUSrcBE1 <= ALUSrcBD1;
            AddressingControlE1 <= AddressingControlD1;
            BranchTypeE1 <= BranchTypeD1;
            
            

            RD1E <= RD1D;
            RD2E <= RD2D;
            PCE1 <= PCD1;
            Rs1E <= Rs1D;
            Rs2E <= Rs2D;
            RdE1 <= RdD1;
            ImmExtE1 <= ImmExtD1;
            PCPlus8E1 <= PCPlus8D1;
        end
    end


    always_ff @(posedge clk) begin

        if (rst2) begin
            
            RegWriteE2 <= 1'b0;
            ResultSrcE2 <= 2'b0;
            MemWriteE2 <= 1'b0;
            JumpE2 <= 2'b0;
            BranchE2 <= 1'b0;
            ALUControlE2 <= 4'b0;
            ALUSrcAE2 <= 1'b0;
            ALUSrcBE2 <= 1'b0;
            AddressingControlE2 <= 3'b0;
            BranchTypeE2 <= 3'b0;
            
            RD4E <= 31'b0;
            RD5E <= 31'b0;
            PCE2 <= 31'b0;
            Rs4E <= 5'b0;
            Rs5E <= 5'b0;
            RdE2 <= 5'b0;
            ImmExtE2 <= 31'b0;
            PCPlus8E2 <= 31'b0;

        end

        else if (en2) begin

            RegWriteE2 <= RegWriteD2;
            ResultSrcE2 <= ResultSrcD2;
            MemWriteE2 <= MemWriteD2;
            JumpE2 <= JumpD2;
            BranchE2 <= BranchD2;
            ALUControlE2 <= ALUControlD2;
            ALUSrcAE2 <= ALUSrcAD2;
            ALUSrcBE2 <= ALUSrcBD2;
            AddressingControlE2 <= AddressingControlD2;
            BranchTypeE2 <= BranchTypeD2;

            RD4E <= RD4D;
            RD5E <= RD5D;
            PCE2 <= PCD2;
            Rs4E <= Rs4D;
            Rs5E <= Rs5D;
            RdE2 <= RdD2;
            ImmExtE2 <= ImmExtD2;
            PCPlus8E2 <= PCPlus8D2;
        end


    end


endmodule
