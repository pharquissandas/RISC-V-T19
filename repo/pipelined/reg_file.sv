// Register file
module reg_file #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic [ADDRESS_WIDTH-1:0] AD3,
    input  logic [ADDRESS_WIDTH-1:0] AD1,
    input  logic [ADDRESS_WIDTH-1:0] AD2,
    input  logic [DATA_WIDTH-1:0] WD3,
    input  logic WE3,
    output logic [DATA_WIDTH-1:0] RD1,
    output logic [DATA_WIDTH-1:0] RD2,
    output logic [DATA_WIDTH-1:0] a0
);
    logic [DATA_WIDTH-1:0] ram_array [0:31];
    always_ff @(posedge clk) if (WE3 && AD3 != 0) ram_array[AD3] <= WD3;
    assign RD1 = ram_array[AD1];
    assign RD2 = ram_array[AD2];
    assign a0  = ram_array[10]; // x10
endmodule
