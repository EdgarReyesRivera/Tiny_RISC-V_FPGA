module seven_segment (
    input [3:0] i,
    output reg [6:0] o
);
    // Pre-computed patterns for each digit
    // Avoids complex decoding logic during synthesis
    localparam [6:0] PATTERN_0 = 7'b1000000;
    localparam [6:0] PATTERN_1 = 7'b1111001;
    localparam [6:0] PATTERN_2 = 7'b0100100;
    localparam [6:0] PATTERN_3 = 7'b0110000;
    localparam [6:0] PATTERN_4 = 7'b0011001;
    localparam [6:0] PATTERN_5 = 7'b0010010;
    localparam [6:0] PATTERN_6 = 7'b0000010;
    localparam [6:0] PATTERN_7 = 7'b1111000;
    localparam [6:0] PATTERN_8 = 7'b0000000;
    localparam [6:0] PATTERN_9 = 7'b0011000;
    localparam [6:0] PATTERN_A = 7'b0001000;
    localparam [6:0] PATTERN_B = 7'b0000011;
    localparam [6:0] PATTERN_C = 7'b1000110;
    localparam [6:0] PATTERN_D = 7'b0100001;
    localparam [6:0] PATTERN_E = 7'b0000110;
    localparam [6:0] PATTERN_F = 7'b0001110;
    localparam [6:0] PATTERN_BLANK = 7'b1111111;
    
    // Use pre-computed patterns for efficient synthesis
    always @(*) begin
        case (i)
            4'b0000: o = PATTERN_0;
            4'b0001: o = PATTERN_1;
            4'b0010: o = PATTERN_2;
            4'b0011: o = PATTERN_3;
            4'b0100: o = PATTERN_4;
            4'b0101: o = PATTERN_5;
            4'b0110: o = PATTERN_6;
            4'b0111: o = PATTERN_7;
            4'b1000: o = PATTERN_8;
            4'b1001: o = PATTERN_9;
            4'b1010: o = PATTERN_A;
            4'b1011: o = PATTERN_B;
            4'b1100: o = PATTERN_C;
            4'b1101: o = PATTERN_D;
            4'b1110: o = PATTERN_E;
            4'b1111: o = PATTERN_F;
            default: o = PATTERN_BLANK;
        endcase
    end
endmodule