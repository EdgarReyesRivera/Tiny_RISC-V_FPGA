module alu(
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_op,
    output reg [31:0] result,
    output zero_flag
);
    // Explicit operation selection with simplified structure
    wire [31:0] add_result = a + b;
    wire [31:0] sub_result = a - b;
    wire [31:0] mul_result = a * b;
    
    // Explicit zero flag calculation to avoid comparator inference
    assign zero_flag = ~|result;
    
    // Simplified operation selection
    always @(*) begin
        case(alu_op)
            3'b000: result = add_result;
            3'b001: result = sub_result;
            3'b010: result = mul_result;
            default: result = 32'b0;
        endcase
    end
endmodule