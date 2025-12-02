module memory_unit #(
    parameter XLEN = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic WE,
    input  logic [XLEN-1:0] A,
    input  logic [XLEN-1:0] WD,
    input  logic [2:0] AddressingControl,
    output logic [XLEN-1:0] RD,
    output logic stall
);

logic [31:0] ram_out;
logic [31:0] ram_in;
logic [31:0] ram_addr;   
logic        wr_en; 
logic [31:0] cache_out;
logic [1:0]  byte_offset;

assign byte_offset = A[1:0];

always_comb begin
    case (AddressingControl)
        3'b000: begin // LB (signed)
            case(byte_offset)
                2'b00: RD = {{24{cache_out[7]}},  cache_out[7:0]};
                2'b01: RD = {{24{cache_out[15]}}, cache_out[15:8]};
                2'b10: RD = {{24{cache_out[23]}}, cache_out[23:16]};
                2'b11: RD = {{24{cache_out[31]}}, cache_out[31:24]};
            endcase
        end
        3'b001: begin // LH (signed)
            case(byte_offset[1]) // check bit 1 (0 or 2)
                1'b0: RD = {{16{cache_out[15]}}, cache_out[15:0]};
                1'b1: RD = {{16{cache_out[31]}}, cache_out[31:16]};
            endcase
        end
        3'b010: RD = cache_out; // LW
        3'b100: begin // LBU (unsigned)
            case(byte_offset)
                2'b00: RD = {24'b0, cache_out[7:0]};
                2'b01: RD = {24'b0, cache_out[15:8]};
                2'b10: RD = {24'b0, cache_out[23:16]};
                2'b11: RD = {24'b0, cache_out[31:24]};
            endcase
        end
        3'b101: begin // LHU (unsigned)
            case(byte_offset[1])
                1'b0: RD = {16'b0, cache_out[15:0]};
                1'b1: RD = {16'b0, cache_out[31:16]};
            endcase
        end
        default: RD = 32'b0;
    endcase

end

data_mem data_mem_inst (
    .clk(clk),
    .WE(wr_en),
    .A(ram_addr),
    .WD(ram_in),
    .AddressingControl(AddressingControl),
    .RD(ram_out)
);

data_cache data_cache_inst (
    .clk(clk),
    .rst(rst),
    .A(A),
    .WD(WD),
    .WE(WE),
    .AddressingControl(AddressingControl),
    .mem_rd(ram_out),
    .cache_dout(cache_out),
    .mem_wd(ram_in),
    .mem_addr(ram_addr),
    .wr_en(wr_en),
    .stall(stall)
);

endmodule
