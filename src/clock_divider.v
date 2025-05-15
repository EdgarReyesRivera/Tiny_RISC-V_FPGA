module clock_divider(
    input clk,
    input rst,
    output reg clk_out
);
    parameter DIVIDER = 25000000; // 25MHz / 25M = 1Hz
    
    // Explicit terminal count logic for better synthesis
    localparam TERMINAL_VALUE = DIVIDER - 1;
    reg [31:0] counter;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 32'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter == TERMINAL_VALUE) begin
                counter <= 32'b0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule