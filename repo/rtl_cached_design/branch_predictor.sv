module branch_predictor(
    input logic clk,
    input logic rst,
    input logic [31:0] fetch_pc_i,
    input logic [31:0] execute_pc_i,
    input logic execute_is_branch_i,
    input logic execute_branch_taken_i,
    output logic predict_taken_o
);

localparam BHT_SIZE = 64;
localparam PC_INDEX_BITS = $clog2(BHT_SIZE);

reg [1:0] bht [0:BHT_SIZE-1]; // 2-bit saturating counters

logic [PC_INDEX_BITS-1:0] fetch_bht_index;
logic [PC_INDEX_BITS-1:0] execute_bht_index;

assign fetch_bht_index = fetch_pc_i[PC_INDEX_BITS+1:2];
assign execute_bht_index = execute_pc_i[PC_INDEX_BITS+1:2];

assign predict_taken_o = bht[fetch_bht_index][1]; // Predict taken if MSB is 1

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i=0; i<BHT_SIZE; i++) begin
            bht[i] <= 2'b00; // Initialize to weakly not taken
        end
    end else if (execute_is_branch_i) begin
        logic [1:0] current_state = bht[execute_bht_index];

        if (execute_branch_taken_i) begin
            bht[execute_bht_index] <= (current_state == 2'b11) ? 2'b11 : current_state + 1;
        end else begin
            bht[execute_bht_index] <= (current_state == 2'b00) ? 2'b00 : current_state - 1;
        end
    end
end
endmodule
