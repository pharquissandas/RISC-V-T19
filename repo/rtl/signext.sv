module signext (
    input  logic [31:0] instr,
    input  logic [1:0]  ImmSrc,        // 2 bits
    output logic [31:0] ImmOp
);

    logic [31:0] immI, immS, immB, immU, immJ;

    // I-type
    assign immI = {{20{instr[31]}}, instr[31:20]};

    // S-type
    assign immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};

    // B-type
    assign immB = {{19{instr[31]}},
                    instr[31],
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0};

    // U-type (LUI, AUIPC)
    assign immU = {instr[31:12], 12'b0};

    // J-type (JAL)
    assign immJ = {{11{instr[31]}},
                    instr[31],
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0};

    always_comb begin
        unique case (ImmSrc)
            2'b00: ImmOp = immI;   // I-type
            2'b01: ImmOp = immS;   // S-type
            2'b10: ImmOp = immB;   // B-type
            2'b11: ImmOp = immU;   // U-type (could also be J-type depending on decoder)
            default: ImmOp = immI;
        endcase
    end

endmodule
