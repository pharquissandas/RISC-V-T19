module pcsrc_unit (
    input  logic [1:0] Jump,
    input  logic       Branch,
    input  logic       Zero,
    input  logic [2:0] BranchType,
    output logic [1:0] PCSrc // control the source for the next PC value (00 = PC+4, 01 = PC + imm(branch/jal), 10 = ALUResult (jalr))
);

    always_comb begin
        // default
        PCSrc = 2'b00;

        // handle jumps first
        case (Jump)
            2'b01: PCSrc = 2'b01; // JAL
            2'b10: PCSrc = 2'b10; // JALR
            2'b00: begin
                // if jump==00 then check branches
                if (Branch) begin
                    case (BranchType)
                        3'b000: PCSrc = Zero ? 2'b01 : 2'b00; // BEQ
                        3'b001: PCSrc = ~Zero ? 2'b01 : 2'b00; // BNE
                        3'b100: PCSrc = ~Zero ? 2'b01 : 2'b00; // BLT
                        3'b101: PCSrc = Zero ? 2'b01 : 2'b00; // BGE
                        3'b110: PCSrc = ~Zero ? 2'b01 : 2'b00; // BLTU
                        3'b111: PCSrc = Zero ? 2'b01 : 2'b00; // BGEU
                        default: PCSrc = 2'b00;
                    endcase
                end
            end
        endcase
    end

endmodule
