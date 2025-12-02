// for 4096 byte capacity cache: 2048 byte per way, 512 sets, 9 bit set

module data_cache #(
    parameter XLEN = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic [XLEN-1:0] A,
    input  logic [XLEN-1:0] WD,
    input  logic WE,
    input  logic [2:0] AddressingControl,
    input  logic [31:0] mem_rd, // data read from main mem

    output logic [31:0] cache_dout, // data out to cpu
    output logic [31:0] mem_wd, // data write to ram
    output logic [31:0] mem_addr, // address to ram
    output logic wr_en, // write enable to ram
    output logic stall
);

logic [20:0] tag;
logic [8:0] set;

// WAY 0 ARRAYS
logic        v_way0    [511:0]; // valid bit
logic        d_way0    [511:0]; // dirty bit
logic [20:0] tag_way0  [511:0]; // tag
logic [31:0] data_way0 [511:0]; // data
// WAY 1 ARRAYS
logic        v_way1    [511:0]; // valid bit
logic        d_way1    [511:0]; // dirty bit
logic [20:0] tag_way1  [511:0]; // tag
logic [31:0] data_way1 [511:0]; // data

logic u_bit [511:0]; // 0 = way0 accessed most recently, 1 = way1 accessed most recently

logic hit0; // way 0 hit
logic hit1; // way 1 hit
logic hit;

logic [31:0] result; // result after SB SH SW logic
logic [1:0] byte_offset;

logic stalling0; // 0 = normal, 1 = stalling
logic stalling1; // 0 = normal, 1 = stalling

// clear cache valid bits on startup
initial begin
    for (int i = 0; i < 512; i++) begin
        v_way0[i] = 0;
        v_way1[i] = 0;
        u_bit [i] = 0;
        d_way0[i] = 0;
        d_way1[i] = 0;
    end
end

assign tag = A[31:11];
assign set = A[10:2];
assign byte_offset = A[1:0];

assign hit0 = v_way0[set] && (tag_way0[set] == tag);
assign hit1 = v_way1[set] && (tag_way1[set] == tag);
assign hit  = hit0 || hit1;

always_comb begin

    stall = 0;
    wr_en = 0;
    mem_wd = 32'h0;
    mem_addr = A;
    cache_dout = mem_rd;

    if (hit0)      cache_dout = data_way0[set];
    else if (hit1) cache_dout = data_way1[set];

    else if (stalling0) begin // stall way0
        stall = 1;
        wr_en = 1;
        mem_wd = data_way0[set];
        mem_addr = {tag_way0[set], set, 2'b00};
    end

    else if (stalling1) begin // stall way1
        stall = 1;
        wr_en = 1;
        mem_wd = data_way1[set];
        mem_addr = {tag_way1[set], set, 2'b00};
    end

    else if (!hit) begin // miss
        if (u_bit[set] == 1 && d_way0[set] && v_way0[set]) begin
            stall = 1; // way 0 is dirty: preemtively stall
        end
        else if (u_bit[set] == 0 && d_way1[set] && v_way1[set]) begin
            stall = 1; // way 1 dirty: preemtively stall
        end
    end
end

always_ff @(posedge clk) begin
    // reset valid bits on a rst signal
    if (rst) begin
        for(int i=0; i<512; i++) begin
            v_way0[i] = 0;
            v_way1[i] = 0;
            u_bit [i] = 0;
            d_way0[i] = 0;
            d_way1[i] = 0;
            stalling0 = 0;
            stalling1 = 0;
        end
    end
    else begin
        // just finished stalling
        if (stalling0) begin
            v_way0[set] <= 0; 
            d_way0[set] <= 0;
            stalling0   <= 0; // stop stalling
        end
        else if (stalling1) begin
            v_way1[set] <= 0;
            d_way1[set] <= 0;
            stalling1   <= 0; // stop stalling
        end
        // write: on a hit write to cache and set dirty bit true
        if (WE) begin

            // base result is the current cache line data for the hit way
            if (hit0) result = data_way0[set];
            else if (hit1) result = data_way1[set];
            else result = 32'h0;

            case (AddressingControl)
                3'b000: begin // SB
                    case (byte_offset)
                        2'b00: result[7:0]   = WD[7:0];
                        2'b01: result[15:8]  = WD[7:0];
                        2'b10: result[23:16] = WD[7:0];
                        2'b11: result[31:24] = WD[7:0];
                    endcase
                end
                3'b001: begin // SH
                    case (byte_offset[1]) // bit 1 determines lower or upper half
                        1'b0: result[15:0]  = WD[15:0];
                        1'b1: result[31:16] = WD[15:0];
                    endcase
                end
                3'b010: result = WD; // SW
                default: result = WD;
            endcase

            if (hit0) begin
                data_way0[set] <= result;
                u_bit[set]  <= 0;
                d_way0[set] <= 1;
            end
            else if (hit1) begin
                data_way1[set] <= result;
                u_bit[set]  <= 1;
                d_way1[set] <= 1;
            end
        end
        // on miss, bring data from ram to cache and update memory from cache if eviction
        else if (!hit) begin
            if (u_bit[set] == 1) begin // 1 most recently used so load into 0                

                if(d_way0[set] == 1 && !stalling0) begin // if dirty, start stalling
                    stalling0 <= 1;
                end
                else begin // else if clean, or if stalling = 1: already stalled
                    data_way0[set] <= mem_rd;
                    tag_way0[set]  <= tag;
                    v_way0[set] <= 1;
                    d_way0[set] <= 0;
                    u_bit[set]  <= 0; // way 0 most recently used
                end
            end
            else begin // 0 most recently used so load into 1

                if(d_way1[set] == 1 && !stalling1) begin // if dirty, start stalling
                    stalling1 <= 1;
                end
                else begin
                    data_way1[set] <= mem_rd;
                    tag_way1[set]  <= tag;
                    v_way1[set] <= 1;
                    d_way1[set] <= 0;
                    u_bit[set]  <= 1; // way 1 most recently used
                end
            end
        end
        else if (hit && !WE) begin // read hit: update
            if (hit0) u_bit[set] <= 0;
            if (hit1) u_bit[set] <= 1;
        end
    end
end

endmodule
