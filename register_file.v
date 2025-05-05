module register_file(
	input clk, rst, we, //write enable
	input [4:0] dir1, dir2, wr, //directory 1 and 2, write register
	input [31:0] info,
	output reg [31:0] rs1, rs2
);
	
	reg [1023:0] register_storage;
	
	always @(*) begin
		case (dir1)
			5'd0: rs1 = 32'd0;
			5'd1: rs1 = register_storage[63:32];
			5'd2: rs1 = register_storage[95:64];
			5'd3: rs1 = register_storage[127:96];
			5'd4: rs1 = register_storage[159:128];
			5'd5: rs1 = register_storage[191:160];
			5'd6: rs1 = register_storage[223:192];
			5'd7: rs1 = register_storage[255:224];
			5'd8: rs1 = register_storage[287:256];
			5'd9: rs1 = register_storage[319:289];
			5'd10: rs1 = register_storage[351:320];
			5'd11: rs1 = register_storage[383:352];
			5'd12: rs1 = register_storage[415:384];
			5'd13: rs1 = register_storage[447:416];
			5'd14: rs1 = register_storage[479:448];
			5'd15: rs1 = register_storage[511:480];
			5'd16: rs1 = register_storage[543:512];
			5'd18: rs1 = register_storage[607:576];
			5'd19: rs1 = register_storage[639:608];
			5'd20: rs1 = register_storage[671:640];
			5'd21: rs1 = register_storage[703:672];
			5'd22: rs1 = register_storage[735:704];
			5'd23: rs1 = register_storage[767:736];
			5'd24: rs1 = register_storage[799:768];
			5'd25: rs1 = register_storage[831:800];
			5'd26: rs1 = register_storage[863:832];
			5'd27: rs1 = register_storage[895:864];
			5'd28: rs1 = register_storage[927:896];
			5'd29: rs1 = register_storage[959:928];
			5'd30: rs1 = register_storage[991:960];
			5'd31: rs1 = register_storage[1023:992];
		endcase
			
		case (dir2)
			5'd0: rs2 = 32'd0;
			5'd1: rs2 = register_storage[63:32];
			5'd2: rs2 = register_storage[95:64];
			5'd3: rs2 = register_storage[127:96];
			5'd4: rs2 = register_storage[159:128];
			5'd5: rs2 = register_storage[191:160];
			5'd6: rs2 = register_storage[223:192];
			5'd7: rs2 = register_storage[255:224];
			5'd8: rs2 = register_storage[287:256];
			5'd9: rs2 = register_storage[319:289];
			5'd10: rs2 = register_storage[351:320];
			5'd11: rs2 = register_storage[383:352];
			5'd12: rs2 = register_storage[415:384];
			5'd13: rs2 = register_storage[447:416];
			5'd14: rs2 = register_storage[479:448];
			5'd15: rs2 = register_storage[511:480];
			5'd16: rs2 = register_storage[543:512];
			5'd18: rs2 = register_storage[607:576];
			5'd19: rs2 = register_storage[639:608];
			5'd20: rs2 = register_storage[671:640];
			5'd21: rs2 = register_storage[703:672];
			5'd22: rs2 = register_storage[735:704];
			5'd23: rs2 = register_storage[767:736];
			5'd24: rs2 = register_storage[799:768];
			5'd25: rs2 = register_storage[831:800];
			5'd26: rs2 = register_storage[863:832];
			5'd27: rs2 = register_storage[895:864];
			5'd28: rs2 = register_storage[927:896];
			5'd29: rs2 = register_storage[959:928];
			5'd30: rs2 = register_storage[991:960];
			5'd31: rs2 = register_storage[1023:992];
		endcase	
			
	end
	
	always @(posedge clk or negedge rst) begin
		if (rst == 1'b0)
			register_storage = 1024'd0;
		else 
			if (we == 1'b1) 
				case (wr)
					5'd0: register_storage[31:0] = info;
					5'd1: register_storage[63:32] = info;
					5'd2: register_storage[95:64] = info;
					5'd3: register_storage[127:96] = info;
					5'd4: register_storage[159:128] = info;
					5'd5: register_storage[191:160] = info;
					5'd6: register_storage[223:192] = info;
					5'd7: register_storage[255:224] = info;
					5'd8: register_storage[287:256] = info;
					5'd9: register_storage[319:289] = info;
					5'd10: register_storage[351:320] = info;
					5'd11: register_storage[383:352] = info;
					5'd12: register_storage[415:384] = info;
					5'd13: register_storage[447:416] = info;
					5'd14: register_storage[479:448] = info;
					5'd15: register_storage[511:480] = info;
					5'd16: register_storage[543:512] = info;
					5'd18: register_storage[607:576] = info;
					5'd19: register_storage[639:608] = info;
					5'd20: register_storage[671:640] = info;
					5'd21: register_storage[703:672] = info;
					5'd22: register_storage[735:704] = info;
					5'd23: register_storage[767:736] = info;
					5'd24: register_storage[799:768] = info;
					5'd25: register_storage[831:800] = info;
					5'd26: register_storage[863:832] = info;
					5'd27: register_storage[895:864] = info;
					5'd28: register_storage[927:896] = info;
					5'd29: register_storage[959:928] = info;
					5'd30: register_storage[991:960] = info;
					5'd31: register_storage[1023:992] = info;
				endcase
	end	
endmodule