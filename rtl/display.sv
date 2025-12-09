module display (
    input  logic [31:0] data,
    output logic [7:0]  display0, // LSB
    output logic [7:0]  display1,
    output logic [7:0]  display2,
    output logic [7:0]  display3,
    output logic [7:0]  display4,
    output logic [7:0]  display5  // MSB
);

    // instantiate a decoder for each 4-bits
    // top 8 bits (31:24) are ignored as there are only 6 displays
    decoder_hex d0 (
        .i_bin(data[3:0]),
        .o_dec(display0)
    );
    decoder_hex d1 (
        .i_bin(data[7:4]),
        .o_dec(display1)
    );
    decoder_hex d2 (
        .i_bin(data[11:8]),
          .o_dec(display2)
    );
    decoder_hex d3 (
        .i_bin(data[15:12]),
        .o_dec(display3)
    );
    decoder_hex d4 (
        .i_bin(data[19:16]),
        .o_dec(display4)
    );
    decoder_hex d5 (
        .i_bin(data[23:20]),
        .o_dec(display5)
    );

endmodule


// 4-bit binary to 7-segment hex decoder
// 0 = segment ON, 1 = segment OFF
module decoder_hex (
    input  logic [3:0] i_bin, 
    output logic [7:0] o_dec
);

    always_comb begin
        case (i_bin)
            4'h0:    o_dec = 8'b1100_0000; // 0
            4'h1:    o_dec = 8'b1111_1001; // 1
            4'h2:    o_dec = 8'b1010_0100; // 2
            4'h3:    o_dec = 8'b1011_0000; // 3
            4'h4:    o_dec = 8'b1001_1001; // 4
            4'h5:    o_dec = 8'b1001_0010; // 5
            4'h6:    o_dec = 8'b1000_0010; // 6
            4'h7:    o_dec = 8'b1111_1000; // 7
            4'h8:    o_dec = 8'b1000_0000; // 8
            4'h9:    o_dec = 8'b1001_0000; // 9
            4'hA:    o_dec = 8'b1000_1000; // A
            4'hB:    o_dec = 8'b1000_0011; // B
            4'hC:    o_dec = 8'b1100_0110; // C
            4'hD:    o_dec = 8'b1010_0001; // D
            4'hE:    o_dec = 8'b1000_0110; // E
            4'hF:    o_dec = 8'b1000_1110; // F
            default: o_dec = 8'b1111_1111; // Off
        endcase
    end

endmodule
