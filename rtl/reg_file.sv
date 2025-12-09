module reg_file #(
    parameter   ADDRESS_WIDTH = 5,      // 32 registers
                DATA_WIDTH    = 32      // 32-bits
)(
    input  logic                        clk,          // clock
    input  logic [ADDRESS_WIDTH-1:0]    AD3,   // destination register 
    input  logic [ADDRESS_WIDTH-1:0]    AD1,   // source register 1 address (rs1)
    input  logic [ADDRESS_WIDTH-1:0]    AD2,   // source register 2 address (rs2)
    input  logic [ADDRESS_WIDTH-1:0]    AD4,   // source register 2 address (rs4)
    input  logic [ADDRESS_WIDTH-1:0]    AD5,   // source register 2 address (rs5)
    input  logic [ADDRESS_WIDTH-1:0]    AD6,   // destination register address
    input  logic [DATA_WIDTH-1:0]       WD3,   // write data
    input  logic [DATA_WIDTH-1:0]       WD6,   // write data
    input  logic                        WE3,   // write enable for pipeline 1
    input  logic                        WE6,   // write enable for pipeline 2 
    
    output logic [DATA_WIDTH-1:0]       RD1,   // register file output for rs1
    output logic [DATA_WIDTH-1:0]       RD2,   // register file output for rs2
    output logic [DATA_WIDTH-1:0]       RD4,   // register file output for rs4
    output logic [DATA_WIDTH-1:0]       RD5,   // register file output for rs5
    output logic [DATA_WIDTH-1:0]       a0,    // register file output for testbenches for pipeline 1
    output logic [DATA_WIDTH-1:0]       a1     // register file output for testbenches for pipeline 2

);

    // 32 32-bit registers
    logic [DATA_WIDTH-1:0] ram_array [2**ADDRESS_WIDTH-1:0];

    // write operation (synchronous) -> writes occur only if WE3 is asserted
    //write occurs on negative edge of clock cycle
    //register 0 is never written
    always_ff @(negedge clk) begin
        if (WE3 == 1'b1 && AD3 != 32'b0)
            ram_array[AD3] <= WD3;
        if (WE6 == 1'b1 && AD3 != 32'b0 && WE6 != WE3) //WE6!= WE3 should always be the case due to implementing a stall
            ram_array[AD6] <= WD6;
    end

    // read operations (combinational) -> outputs change immediately when read_addr changes
    assign RD1 = ram_array[AD1];
    assign RD2 = ram_array[AD2];
    assign RD4 = ram_array[AD4];
    assign RD5 = ram_array[AD5];

    assign a0  = ram_array[5'b01010]; //a0 = reg x10
    assign a1  = ram_array[5'b01011]; //a1 = reg x11

endmodule
