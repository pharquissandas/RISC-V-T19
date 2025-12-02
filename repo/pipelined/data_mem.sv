// Data memory
module data_mem #(
    parameter XLEN = 32,
    parameter ADDRESS_WIDTH = 17
)(
    input  logic clk,
    input  logic WE,
    input  logic [XLEN-1:0] A,
    input  logic [XLEN-1:0] WD,
    input  logic [2:0] AddressingControl,
    output logic [XLEN-1:0] RD
);
    logic [7:0] ram_array [2**ADDRESS_WIDTH-1:0];
    initial $readmemh("data.hex", ram_array);

    logic [ADDRESS_WIDTH-1:0] addr;
    assign addr = A[ADDRESS_WIDTH-1:0];

    always_ff @(posedge clk) begin
        if (WE) begin
            case (AddressingControl)
                3'b000: ram_array[addr] <= WD[7:0]; // SB
                3'b001: begin // SH
                    ram_array[addr]   <= WD[7:0];
                    ram_array[addr+1] <= WD[15:8];
                end
                3'b010: begin // SW
                    ram_array[addr]   <= WD[7:0];
                    ram_array[addr+1] <= WD[15:8];
                    ram_array[addr+2] <= WD[23:16];
                    ram_array[addr+3] <= WD[31:24];
                end
                default: ;
            endcase
        end
    end

    byte0 = ram_array[addr]; // A[7:0]
    byte1 = ram_array[addr + 1]; // A[15:8]

    always_comb begin
        case (AddressingControl)
            3'b000: RD = {{24{ram_array[addr][7]}}, ram_array[addr]}; // LB
            3'b001: begin // LH: Reads bytes A[0] and A[1]
                logic [15:0] half_word = {byte1, byte0};
                RD = {{16{half_word[15]}}, half_word}; // Sign-extend 16 bits
            end
            3'b010: RD = {ram_array[addr+3], ram_array[addr+2], ram_array[addr+1], ram_array[addr]}; // LW
            3'b100: RD = {24'b0, ram_array[addr]}; // LBU
            3'b101: RD = {16'b0, ram_array[addr+1], ram_array[addr]}; // LHU
            default: RD = 32'b0;
        endcase
    end
endmodule
