module alu(
	input [3:0] opCode,
	input [31:0] rs1, rs2,
	output reg [31:0] rd
);

parameter ADD = 4'd0;
parameter MUL = 4'd1;
parameter BNE = 4'd2;

wire signed [31:0] signed_rs1 = rs1;
wire signed [31:0] signed_rs2 = rs2;

always @(*)
	case (opCode)
		ADD: 
			rd = rs1 + rs2;
		MUL:
			rd = signed_rs1 * signed_rs2;
		BNE:
			rd = (rs1 != rs2) ? 32'b1 : 32'b0;
		default:
			rd = 32'd0;
	endcase
endmodule