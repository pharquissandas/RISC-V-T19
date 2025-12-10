module data_mem #(
    parameter XLEN = 32,
    parameter ADDRESS_WIDTH = 17,
    parameter DATA_WIDTH = 8
) (
    input  logic clk,
    input  logic WE1, // write enable
    input  logic WE2, // write enable
    // verilator lint_off UNUSED
    input  logic [XLEN-1:0] A1, // memory address
    // verilator lint_on UNUSED
    input  logic [XLEN-1:0] A2, // memory address
    input  logic [XLEN-1:0] WD1, // data to write
    input  logic [XLEN-1:0] WD2, // data to write
    input  logic [2:0] AddressingControl1, // funct3 to determine load/store type
    input  logic [2:0] AddressingControl2, // funct3 to determine load/store type

    output logic [XLEN-1:0] RD1, // data read
    output logic [XLEN-1:0] RD2 // data read
);
    logic [DATA_WIDTH-1:0] ram_array [2**ADDRESS_WIDTH-1:0]; // 128KB data memory

    initial begin
        // Load the data.hex file into memory at the start of simulation (starts from middle of memory)
        $readmemh("data.hex", ram_array);
    end

    logic [ADDRESS_WIDTH-1:0] addr1;
    logic [ADDRESS_WIDTH-1:0] addr2;
    logic conflict = 1'b0;
    assign addr1 = A1[ADDRESS_WIDTH-1:0]; // use lower ADDRESS_WIDTH bits of address
    assign addr2 = A2[ADDRESS_WIDTH-1:0]; // use lower ADDRESS_WIDTH bits of address

    always_comb begin 

        if(WE1 && WE2)begin
                    if (addr1 == addr2) // if both instructions are trying to write the same location in memory we only write the result of the later instruction
                        //but this should never occur if we have handled dependencies correctly before
                        conflict = 1'b1;
        end

    end




    always_ff @(posedge clk) begin

        if (WE1) begin
            case (AddressingControl1)
                3'b000: ram_array[addr1] <= WD1[7:0]; // SB
                3'b001: begin                      // SH
                    ram_array[addr1]   <= WD1[7:0];
                    ram_array[addr1+1] <= WD1[15:8];
                end
                3'b010: begin                      // SW
                    ram_array[addr1]   <= WD1[7:0];
                    ram_array[addr1+1] <= WD1[15:8];
                    ram_array[addr1+2] <= WD1[23:16];
                    ram_array[addr1+3] <= WD1[31:24];
                end
                default: ; // ignore other funct3
            endcase
        end

        else if (WE2 && conflict == 1'b0) begin
            case (AddressingControl2)
                3'b000: ram_array[addr2] <= WD2[7:0]; // SB
                3'b001: begin                      // SH
                    ram_array[addr2]   <= WD2[7:0];
                    ram_array[addr2+1] <= WD2[15:8];
                end
                3'b010: begin                      // SW
                    ram_array[addr2]   <= WD2[7:0];
                    ram_array[addr2+1] <= WD2[15:8];
                    ram_array[addr2+2] <= WD2[23:16];
                    ram_array[addr2+3] <= WD2[31:24];
                end
                default: ; // ignore other funct3
            endcase
        end

    end

    always_comb begin
        case (AddressingControl1)
            3'b000: RD1 = {{24{ram_array[addr1][7]}}, ram_array[addr1]}; // LB (signed)
            3'b001: RD1 = {{16{ram_array[addr1+1][7]}}, ram_array[addr1+1], ram_array[addr1]}; // LH (signed)
            3'b010: RD1 = {ram_array[addr1+3], ram_array[addr1+2], ram_array[addr1+1], ram_array[addr1]}; // LW
            3'b100: RD1 = {24'b0, ram_array[addr1]}; // LBU
            3'b101: RD1 = {16'b0, ram_array[addr1+1], ram_array[addr1]}; // LHU
            default: RD1 = 32'b0;
        endcase

        case (AddressingControl2)
            3'b000: RD2 = {{24{ram_array[addr2][7]}}, ram_array[addr2]}; // LB (signed)
            3'b001: RD2 = {{16{ram_array[addr2+1][7]}}, ram_array[addr2+1], ram_array[addr2]}; // LH (signed)
            3'b010: RD2 = {ram_array[addr2+3], ram_array[addr2+2], ram_array[addr2+1], ram_array[addr2]}; // LW
            3'b100: RD2 = {24'b0, ram_array[addr2]}; // LBU
            3'b101: RD2 = {16'b0, ram_array[addr2+1], ram_array[addr2]}; // LHU
            default: RD2 = 32'b0;
        endcase

    end


endmodule
