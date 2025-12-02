// Sign extension
module sign_ext (
    input  logic [31:7] Imm,
    input  logic [2:0]  ImmSrc,
    output logic [31:0] ImmExt
);
    always_comb begin
        case (ImmSrc)
            3'b000: ImmExt = {{20{Imm[31]}}, Imm[31:20]}; // I-type
            3'b001: ImmExt = {{20{Imm[31]}}, Imm[31:25], Imm[11:7]}; // S-type
            3'b010: ImmExt = {{19{Imm[31]}}, Imm[7], Imm[30:25], Imm[11:8], 1'b0}; // B-type
            3'b011: ImmExt = {{12{Imm[31]}}, Imm[19:12], Imm[20], Imm[30:21], 1'b0}; // J-type
            3'b100: ImmExt = {Imm[31:12], 12'b0}; // U-type
            default: ImmExt = 32'b0;
        endcase
    end
endmodule
