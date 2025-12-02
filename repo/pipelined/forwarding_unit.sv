module forwarding_unit (
    input  logic [4:0] Rs1E,
    input  logic [4:0] Rs2E,
    input  logic       RegWriteM,
    input  logic [4:0] RdM,
    input  logic       RegWriteW,
    input  logic [4:0] RdW,
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE
);

    // ForwardA
    always_comb begin
        if (RegWriteM && (RdM != 0) && (RdM == Rs1E))
            ForwardAE = 2'b10;      // EX/MEM forwarding
        else if (RegWriteW && (RdW != 0) && (RdW == Rs1E))
            ForwardAE = 2'b01;      // MEM/WB forwarding
        else
            ForwardAE = 2'b00;
    end

    // ForwardB
    always_comb begin
        if (RegWriteM && (RdM != 0) && (RdM == Rs2E))
            ForwardBE = 2'b10;      // EX/MEM forwarding
        else if (RegWriteW && (RdW != 0) && (RdW == Rs2E))
            ForwardBE = 2'b01;      // MEM/WB forwarding
        else
            ForwardBE = 2'b00;
    end

endmodule
