module main_decoder (
    input logic [6:0]  opcode,
    output logic       ResultsSrc,
    output logic       MemWrite,
    output logic       ALUsrc,
    output logic       RegWrite,
    output logic       Branch,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUop
);

always_comb begin
    case(opcode)

        7'b0000011: begin 
            ResultsSrc = 1;
            MemWrite   = 0;
            ALUsrc     = 1;
            RegWrite   = 1;
            Branch     = 0;
            ImmSrc     = 2'b00;
            ALUop      = 2'b00;
        end

        7'b0100011: begin 
            ResultsSrc = X;
            MemWrite   = 1;
            ALUsrc     = 1;
            RegWrite   = 0;
            Branch     = 0;
            ImmSrc     = 2'b01;
            ALUop      = 2'b00;
        end

        7'b0110011: begin 
            ResultsSrc = 0;
            MemWrite   = 0;
            ALUsrc     = 0;
            RegWrite   = 1;
            Branch     = 0;
            ImmSrc     = 2'bXX;
            ALUop      = 2'b10;
        end

        7'b1100011: begin 
            ResultsSrc = X;
            MemWrite   = 0;
            ALUsrc     = 0;
            RegWrite   = 0;
            Branch     = 1;
            ImmSrc     = 2'b10;
            ALUop      = 2'b01;
        end

        default: begin
            ResultsSrc = 0;
            MemWrite   = 0;
            ALUsrc     = 0;
            RegWrite   = 0;
            Branch     = 0;
            ImmSrc     = 2'b00;
            ALUop      = 2'b00;
        end
    endcase
end

endmodule