module data_mem #(
    parameter XLEN = 32,
    parameter ADDRESS_WIDTH = 17,
    parameter DATA_WIDTH = 8
) (
    input  logic clk,
    input  logic WE, // write enable
    // verilator lint_off UNUSED
    input  logic [XLEN-1:0] A, // memory address
    // verilator lint_on UNUSED
    input  logic [XLEN-1:0] WD, // data to write
    input  logic [2:0] AddressingControl, // funct3 to determine load/store type
    output logic [XLEN-1:0] RD // data read
);
    logic [DATA_WIDTH-1:0] ram_array [2**ADDRESS_WIDTH-1:0]; // 128KB data memory

    initial begin
        // Load the data.hex file into memory at the start of simulation (starts from middle of memory)
        $readmemh("data.hex", ram_array);
    end

    logic [ADDRESS_WIDTH-1:0] addr;
    assign addr = A[ADDRESS_WIDTH-1:0]; // use lower ADDRESS_WIDTH bits of address

    always_ff @(posedge clk) begin
        if (WE) begin
            case (AddressingControl)
                3'b000: ram_array[addr] <= WD[7:0]; // SB
                3'b001: begin                      // SH
                    ram_array[addr]   <= WD[7:0];
                    ram_array[addr+1] <= WD[15:8];
                end
                3'b010: begin                      // SW
                    ram_array[addr]   <= WD[7:0];
                    ram_array[addr+1] <= WD[15:8];
                    ram_array[addr+2] <= WD[23:16];
                    ram_array[addr+3] <= WD[31:24];
                end
                default: ; // ignore other funct3
            endcase
        end
    end

    always_comb begin
        case (AddressingControl)
            3'b000: RD = {{24{ram_array[addr][7]}}, ram_array[addr]}; // LB (signed)
            3'b001: RD = {{16{ram_array[addr+1][7]}}, ram_array[addr+1], ram_array[addr]}; // LH (signed)
            3'b010: RD = {ram_array[addr+3], ram_array[addr+2], ram_array[addr+1], ram_array[addr]}; // LW
            3'b100: RD = {24'b0, ram_array[addr]}; // LBU
            3'b101: RD = {16'b0, ram_array[addr+1], ram_array[addr]}; // LHU
            default: RD = 32'b0;
        endcase
    end


endmodule
