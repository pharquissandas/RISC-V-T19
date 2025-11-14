module signext (
    input  logic [31:0] instr,
    input  logic        ImmSrc,
    output logic [31:0] ImmOp
);

    logic [31:0] immI;
    logic [31:0] immB;

    assign immI = {{20{instr[31]}}, instr[31:20]};

    assign immB = {{19{instr[31]}},
                   instr[31],        // imm[12]
                   instr[7],         // imm[11]
                   instr[30:25],     // imm[10:5]
                   instr[11:8],      // imm[4:1]
                   1'b0              // imm[0]
                  };

    assign ImmOp = (ImmSrc == 0) ? immI : immB;
endmodule

