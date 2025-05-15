module two_decimals_vals_w_neg (
    input signed [6:0] val,
    output [6:0] seg7_neg_sign,
    output [6:0] seg7_lsb,
    output [6:0] seg7_msb
);
    reg [3:0] result_one_digit;
    reg [3:0] result_ten_digit;
    reg result_is_negative;
    reg [6:0] abs_val;

    // Converting Binary Value into Digits and Negative Sign
    always @(*) begin
        if (val < 0) begin
            result_is_negative = 1;
            abs_val = -val;
        end else begin
            result_is_negative = 0;
            abs_val = val;
        end
        // Extracting Tens and Ones Digits
        result_ten_digit = abs_val / 10;
        result_one_digit = abs_val % 10;
    end

    // Instantiating 7-Segment Decoder Modules
    seven_segment msb(result_ten_digit, seg7_msb);
    seven_segment lsb(result_one_digit, seg7_lsb);
    seven_segment_negative neg(result_is_negative, seg7_neg_sign);
endmodule
