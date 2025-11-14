module control (
    input  logic [6:0] opcode,
    input  logic       EQ,
    output logic       RegWrite,
    output logic       ALUsrc,
    output logic       ALUctrl,   // 0 = add, 1 = sub
    output logic       ImmSrc,    // 0 = I-type, 1 = B-type
    output logic       PCSrc
);
    logic branch;

    always_comb begin
        RegWrite = 0;
        ALUsrc   = 0;
        ALUctrl  = 0;
        ImmSrc   = 0;
        branch   = 0;

        case (opcode)
            7'b0010011: begin  // ADDI
                RegWrite = 1;
                ALUsrc   = 1;  // immediate
                ALUctrl  = 0;  // add
                ImmSrc   = 0;  // I-type
                branch   = 0;
            end

            7'b1100011: begin  // BNE
                RegWrite = 0;
                ALUsrc   = 0;
                ALUctrl  = 1;  // subtract
                ImmSrc   = 1;  // B-type immediate
                branch   = 1;
            end
        endcase
    end

    assign PCSrc = branch & (~EQ);

endmodule

