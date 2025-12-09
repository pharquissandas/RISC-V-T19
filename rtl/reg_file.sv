module reg_file #(
    parameter   ADDRESS_WIDTH = 5,      // 32 registers
                DATA_WIDTH    = 32      // 32-bits
)(
    input  logic                        clk,          // clock
    input  logic [ADDRESS_WIDTH-1:0]    AD3,   // destination register 
    input  logic [ADDRESS_WIDTH-1:0]    AD1,   // source register 1 address (rs1)
    input  logic [ADDRESS_WIDTH-1:0]    AD2,   // source register 2 address (rs2)
    input  logic [DATA_WIDTH-1:0]       WD3,          // write data
    input  logic                        WE3,          // write enable
    output logic [DATA_WIDTH-1:0]       RD1,        // register file output for rs1
    output logic [DATA_WIDTH-1:0]       RD2,          // register file output for rs2
    output logic [DATA_WIDTH-1:0]       a0          // register file output for testbenches

);

    // 32 32-bit registers
    logic [DATA_WIDTH-1:0] ram_array [2**ADDRESS_WIDTH-1:0];

    // write operation (synchronous) -> writes occur only if WE3 is asserted
    always_ff @(posedge clk) begin
        if (WE3 == 1'b1 && AD3 != 0)
            ram_array[AD3] <= WD3;
    end

    // read operations (combinational) -> outputs change immediately when read_addr changes
    assign RD1 = ram_array[AD1];
    assign RD2 = ram_array[AD2];
    assign a0  = ram_array[5'b01010];

endmodule
