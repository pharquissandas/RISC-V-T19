module pcsrc_unit (
  input logic [1:0] Jump,
  input logic    Branch,
  input logic    Zero,
  input logic [2:0] BranchType,
  output logic [1:0] PCSrc,
  output logic    BranchTaken // <--- NEW: Flag for Hazard Unit
);

  always_comb begin
    PCSrc = 2'b00;
        BranchTaken = 1'b0; // <--- NEW
    case (Jump)
      2'b01: begin PCSrc = 2'b01; BranchTaken = 1'b1; end // JAL
      2'b10: begin PCSrc = 2'b10; BranchTaken = 1'b1; end // JALR
      default: begin
        if (Branch) begin
          case (BranchType)
            3'b000: if (Zero) begin PCSrc = 2'b01; BranchTaken = 1'b1; end // BEQ
            3'b001: if (~Zero) begin PCSrc = 2'b01; BranchTaken = 1'b1; end // BNE
            3'b100: if (~Zero) begin PCSrc = 2'b01; BranchTaken = 1'b1; end // BLT
            3'b101: if (Zero) begin PCSrc = 2'b01; BranchTaken = 1'b1; end // BGE
            3'b110: if (~Zero) begin PCSrc = 2'b01; BranchTaken = 1'b1; end // BLTU
            3'b111: if (Zero) begin PCSrc = 2'b01; BranchTaken = 1'b1; end // BGEU
            default: ;
          endcase
        end
      end
    endcase
  end
endmodule
