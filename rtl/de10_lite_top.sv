module de10_lite_top (
    input  logic        MAX10_CLK1_50, // 50 MHz clock
    input  logic [1:0]  KEY, // buttons: key0, key1
    output logic [9:0]  LEDR, // LEDs
    output logic [7:0]  HEX0, // displays
    output logic [7:0]  HEX1,
    output logic [7:0]  HEX2,
    output logic [7:0]  HEX3,
    output logic [7:0]  HEX4,
    output logic [7:0]  HEX5
);

    // clock divider 50MHz : clock could be too fast
    logic [24:0] counter;
    always_ff @(posedge MAX10_CLK1_50) begin
        counter <= counter + 1;
    end
    // counter[0] = 50MHz, counter[1] = 25MHz, counter[24] ~ 1.5Hz
	 // using slower clock for testing
    logic cpu_clk;
    assign cpu_clk = counter[15]; 

    //  key 0: reset
    logic rst;
    assign rst = ~KEY[0]; 
    
    logic [31:0] a0_val;
    
    top cpu_inst (
        .clk (cpu_clk),
        .rst (rst),
        .a0  (a0_val)
    );

    // map a0 to LEDs and Hex
    assign LEDR = a0_val[9:0]; // bottom 10 bits to LEDs

    display display_map (
        .data(a0_val),
        .display0(HEX0),
        .display1(HEX1),
        .display2(HEX2),
        .display3(HEX3),
        .display4(HEX4),
        .display5(HEX5)
    );

endmodule
