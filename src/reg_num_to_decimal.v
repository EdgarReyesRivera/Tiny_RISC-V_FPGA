module reg_num_to_decimal(
    input [4:0] reg_num,     // Register number (0-31)
    output [3:0] tens,       // Tens digit (0-3)
    output [3:0] ones        // Ones digit (0-9)
);
    // Simple division for 2-digit conversion
    assign tens = reg_num / 10;
    assign ones = reg_num % 10;
endmodule