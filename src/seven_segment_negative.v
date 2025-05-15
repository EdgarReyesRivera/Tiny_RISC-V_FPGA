module seven_segment_negative(
    input i,
    output reg [6:0] o // a, b, c, d, e, f, g
);
    // Pre-computed patterns for more efficient synthesis
    localparam [6:0] BLANK = 7'b1111111;
    localparam [6:0] NEGATIVE = 7'b0111111;
    
    always @(*) begin
        case (i)
            1'b0: o = BLANK;
            1'b1: o = NEGATIVE;
        endcase
    end
endmodule