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
        // always write full word otherwise data bits will be lost and SW SH SB logic is done
        // after the data is then recieved from the cache in memory_unit
        if (WE) begin
            ram_array[addr]   <= WD[7:0];
            ram_array[addr+1] <= WD[15:8];
            ram_array[addr+2] <= WD[23:16];
            ram_array[addr+3] <= WD[31:24];
        end
    end

    logic [ADDRESS_WIDTH-1:0] word_addr;
    assign word_addr = {addr[ADDRESS_WIDTH-1:2], 2'b00}; // align bytes as LB LH LW logic handled in cache

    always_comb begin // return word
        RD = {ram_array[word_addr+3], ram_array[word_addr+2], ram_array[word_addr+1], ram_array[word_addr]};
    end


endmodule
