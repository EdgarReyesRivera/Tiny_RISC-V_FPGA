module reg_file(
    input clk,
    input rst,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2,
    input [4:0] debug_reg_addr,
    output reg [31:0] debug_reg_data
);
    // Single register storage for all 32 registers
    reg [1023:0] reg_storage;
    
    // Read port 1
    always @(*) begin
        case (rs1)
            5'd0: read_data1 = 32'd0;
            5'd1: read_data1 = reg_storage[63:32];
            5'd2: read_data1 = reg_storage[95:64];
            5'd3: read_data1 = reg_storage[127:96];
            5'd4: read_data1 = reg_storage[159:128];
            5'd5: read_data1 = reg_storage[191:160];
            5'd6: read_data1 = reg_storage[223:192];
            5'd7: read_data1 = reg_storage[255:224];
            5'd8: read_data1 = reg_storage[287:256];
            5'd9: read_data1 = reg_storage[319:288];
            5'd10: read_data1 = reg_storage[351:320];
            5'd11: read_data1 = reg_storage[383:352];
            5'd12: read_data1 = reg_storage[415:384];
            5'd13: read_data1 = reg_storage[447:416];
            5'd14: read_data1 = reg_storage[479:448];
            5'd15: read_data1 = reg_storage[511:480];
            5'd16: read_data1 = reg_storage[543:512];
            5'd17: read_data1 = reg_storage[575:544];
            5'd18: read_data1 = reg_storage[607:576];
            5'd19: read_data1 = reg_storage[639:608];
            5'd20: read_data1 = reg_storage[671:640];
            5'd21: read_data1 = reg_storage[703:672];
            5'd22: read_data1 = reg_storage[735:704];
            5'd23: read_data1 = reg_storage[767:736];
            5'd24: read_data1 = reg_storage[799:768];
            5'd25: read_data1 = reg_storage[831:800];
            5'd26: read_data1 = reg_storage[863:832];
            5'd27: read_data1 = reg_storage[895:864];
            5'd28: read_data1 = reg_storage[927:896];
            5'd29: read_data1 = reg_storage[959:928];
            5'd30: read_data1 = reg_storage[991:960];
            5'd31: read_data1 = reg_storage[1023:992];
        endcase
    end
    
    // Read port 2
    always @(*) begin
        case (rs2)
            5'd0: read_data2 = 32'd0;
            5'd1: read_data2 = reg_storage[63:32];
            5'd2: read_data2 = reg_storage[95:64];
            5'd3: read_data2 = reg_storage[127:96];
            5'd4: read_data2 = reg_storage[159:128];
            5'd5: read_data2 = reg_storage[191:160];
            5'd6: read_data2 = reg_storage[223:192];
            5'd7: read_data2 = reg_storage[255:224];
            5'd8: read_data2 = reg_storage[287:256];
            5'd9: read_data2 = reg_storage[319:288];
            5'd10: read_data2 = reg_storage[351:320];
            5'd11: read_data2 = reg_storage[383:352];
            5'd12: read_data2 = reg_storage[415:384];
            5'd13: read_data2 = reg_storage[447:416];
            5'd14: read_data2 = reg_storage[479:448];
            5'd15: read_data2 = reg_storage[511:480];
            5'd16: read_data2 = reg_storage[543:512];
            5'd17: read_data2 = reg_storage[575:544];
            5'd18: read_data2 = reg_storage[607:576];
            5'd19: read_data2 = reg_storage[639:608];
            5'd20: read_data2 = reg_storage[671:640];
            5'd21: read_data2 = reg_storage[703:672];
            5'd22: read_data2 = reg_storage[735:704];
            5'd23: read_data2 = reg_storage[767:736];
            5'd24: read_data2 = reg_storage[799:768];
            5'd25: read_data2 = reg_storage[831:800];
            5'd26: read_data2 = reg_storage[863:832];
            5'd27: read_data2 = reg_storage[895:864];
            5'd28: read_data2 = reg_storage[927:896];
            5'd29: read_data2 = reg_storage[959:928];
            5'd30: read_data2 = reg_storage[991:960];
            5'd31: read_data2 = reg_storage[1023:992];
        endcase
    end
    
    // Debug port
    always @(*) begin
        case (debug_reg_addr)
            5'd0: debug_reg_data = 32'd0;
            5'd1: debug_reg_data = reg_storage[63:32];
            5'd2: debug_reg_data = reg_storage[95:64];
            5'd3: debug_reg_data = reg_storage[127:96];
            5'd4: debug_reg_data = reg_storage[159:128];
            5'd5: debug_reg_data = reg_storage[191:160];
            5'd6: debug_reg_data = reg_storage[223:192];
            5'd7: debug_reg_data = reg_storage[255:224];
            5'd8: debug_reg_data = reg_storage[287:256];
            5'd9: debug_reg_data = reg_storage[319:288];
            5'd10: debug_reg_data = reg_storage[351:320];
            5'd11: debug_reg_data = reg_storage[383:352];
            5'd12: debug_reg_data = reg_storage[415:384];
            5'd13: debug_reg_data = reg_storage[447:416];
            5'd14: debug_reg_data = reg_storage[479:448];
            5'd15: debug_reg_data = reg_storage[511:480];
            5'd16: debug_reg_data = reg_storage[543:512];
            5'd17: debug_reg_data = reg_storage[575:544];
            5'd18: debug_reg_data = reg_storage[607:576];
            5'd19: debug_reg_data = reg_storage[639:608];
            5'd20: debug_reg_data = reg_storage[671:640];
            5'd21: debug_reg_data = reg_storage[703:672];
            5'd22: debug_reg_data = reg_storage[735:704];
            5'd23: debug_reg_data = reg_storage[767:736];
            5'd24: debug_reg_data = reg_storage[799:768];
            5'd25: debug_reg_data = reg_storage[831:800];
            5'd26: debug_reg_data = reg_storage[863:832];
            5'd27: debug_reg_data = reg_storage[895:864];
            5'd28: debug_reg_data = reg_storage[927:896];
            5'd29: debug_reg_data = reg_storage[959:928];
            5'd30: debug_reg_data = reg_storage[991:960];
            5'd31: debug_reg_data = reg_storage[1023:992];
        endcase
    end
    
    // Write operation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            reg_storage <= 1024'd0;
        end
        else if (reg_write && rd != 0) begin
            case (rd)
                5'd1: reg_storage[63:32] <= write_data;
                5'd2: reg_storage[95:64] <= write_data;
                5'd3: reg_storage[127:96] <= write_data;
                5'd4: reg_storage[159:128] <= write_data;
                5'd5: reg_storage[191:160] <= write_data;
                5'd6: reg_storage[223:192] <= write_data;
                5'd7: reg_storage[255:224] <= write_data;
                5'd8: reg_storage[287:256] <= write_data;
                5'd9: reg_storage[319:288] <= write_data;
                5'd10: reg_storage[351:320] <= write_data;
                5'd11: reg_storage[383:352] <= write_data;
                5'd12: reg_storage[415:384] <= write_data;
                5'd13: reg_storage[447:416] <= write_data;
                5'd14: reg_storage[479:448] <= write_data;
                5'd15: reg_storage[511:480] <= write_data;
                5'd16: reg_storage[543:512] <= write_data;
                5'd17: reg_storage[575:544] <= write_data;
                5'd18: reg_storage[607:576] <= write_data;
                5'd19: reg_storage[639:608] <= write_data;
                5'd20: reg_storage[671:640] <= write_data;
                5'd21: reg_storage[703:672] <= write_data;
                5'd22: reg_storage[735:704] <= write_data;
                5'd23: reg_storage[767:736] <= write_data;
                5'd24: reg_storage[799:768] <= write_data;
                5'd25: reg_storage[831:800] <= write_data;
                5'd26: reg_storage[863:832] <= write_data;
                5'd27: reg_storage[895:864] <= write_data;
                5'd28: reg_storage[927:896] <= write_data;
                5'd29: reg_storage[959:928] <= write_data;
                5'd30: reg_storage[991:960] <= write_data;
                5'd31: reg_storage[1023:992] <= write_data;
                // Register x0 is hardwired to 0, so we don't include it in the write case
            endcase
        end
    end
endmodule