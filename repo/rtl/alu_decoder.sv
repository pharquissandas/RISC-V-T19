module alu_decoder (
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    input logic funct75,
    input logic [6:0] op,
    output logic [2:0] ALUControl
);

    logic op5;
    assign op5 = op[5];

    always_comb begin
        case (ALUOp)

            2'b00: ALUControl = 3'b000;

            2'b01: ALUControl = 3'b001;

            2'b10: begin
                unique case (funct3)
                    3'b000: begin
                        if ({op5, funct75} == 2'b11)
                            ALUControl = 3'b001;
                        else
                            ALUControl = 3'b000;
                    end

                    3'b010: ALUControl = 3'b101; // slt
                    3'b110: ALUControl = 3'b011; // or
                    3'b111: ALUControl = 3'b010; //and

                    default: ALUControl = 3'b000;
                endcase
            end

            default: ALUControl = 3'b000;
        endcase
    end

endmodule