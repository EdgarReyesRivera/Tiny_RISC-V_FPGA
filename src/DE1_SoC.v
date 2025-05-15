module DE1_SoC(
    // Clock
    input CLOCK_50,
    
    // Key inputs (active low)
    input [3:0] KEY,
    
    // Switch inputs
    input [9:0] SW,
    
    // LED outputs
    output [9:0] LEDR,
    
    // 7-segment displays
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);
    // Internal wires
    wire slow_clk;
    wire rst = KEY[0];  // KEY[0] is active LOW
    
    // Use a smaller divider for the clock
    clock_divider #(.DIVIDER(10000000)) div(
        .clk(CLOCK_50),
        .rst(rst),
        .clk_out(slow_clk)
    );
    
    // Debug signals from TinyRV1
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_alu_result;
    wire [4:0] debug_rd;
    wire [31:0] debug_write_data;
    wire [31:0] debug_reg_data;
    
    // Display mode selection
    wire register_mode = SW[9];
    wire instruction_mode = ~SW[9];
    
    // Address selection
    wire [4:0] selected_reg = SW[4:0];
    
    // Register number to decimal conversion
    wire [3:0] reg_num_tens, reg_num_ones;
    reg_num_to_decimal reg_num_converter(
        .reg_num(selected_reg),
        .tens(reg_num_tens),
        .ones(reg_num_ones)
    );
    
    // Simplified key detection with edge detection
    reg [1:0] key1_prev, key2_prev;
    wire key1_pressed = (key1_prev == 2'b01); // Detect falling edge
    wire key2_pressed = (key2_prev == 2'b01);

    always @(posedge CLOCK_50 or negedge rst) begin
        if (!rst) begin
            key1_prev <= 2'b11;
            key2_prev <= 2'b11;
        end else begin
            key1_prev <= {key1_prev[0], KEY[1]};
            key2_prev <= {key2_prev[0], KEY[2]};
        end
    end
    
    // Simplified run mode toggle
    reg run_mode;
    
    always @(posedge CLOCK_50 or negedge rst) begin
        if (!rst)
            run_mode <= 1'b0;
        else if (key1_pressed)
            run_mode <= ~run_mode;
    end
    
    // Direct clock selection
    wire proc_clk = run_mode ? slow_clk : (key2_pressed & ~run_mode);
    
    // Reset synchronizer for processor
    reg [2:0] rst_sync;
    always @(posedge CLOCK_50) begin
        rst_sync <= {rst_sync[1:0], rst};
    end
    
    // Instantiate processor
    tinyrv1 processor(
        .clk(proc_clk),
        .rst(rst_sync[2]),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result(debug_alu_result),
        .debug_rd(debug_rd),
        .debug_write_data(debug_write_data),
        .debug_reg_addr(selected_reg),
        .debug_reg_data(debug_reg_data)
    );
    
    // Optimized display value selection with direct assignments
    // Register mode display
    wire [3:0] reg_hex5 = reg_num_tens;
    wire [3:0] reg_hex4 = reg_num_ones;
    wire [3:0] reg_hex3 = debug_reg_data[15:12];
    wire [3:0] reg_hex2 = debug_reg_data[11:8];
    wire [3:0] reg_hex1 = debug_reg_data[7:4];
    wire [3:0] reg_hex0 = debug_reg_data[3:0];

    // Instruction mode display
    wire [3:0] instr_hex5 = debug_pc[7:4];
    wire [3:0] instr_hex4 = debug_pc[3:0];
    wire [3:0] instr_hex3 = {2'b00, debug_instruction[6:5]};
    wire [3:0] instr_hex2 = debug_alu_result[11:8];
    wire [3:0] instr_hex1 = debug_alu_result[7:4];
    wire [3:0] instr_hex0 = debug_alu_result[3:0];

    // Mode selection muxes using explicit assignments
    wire [3:0] hex5_val = register_mode ? reg_hex5 : instr_hex5;
    wire [3:0] hex4_val = register_mode ? reg_hex4 : instr_hex4;
    wire [3:0] hex3_val = register_mode ? reg_hex3 : instr_hex3;
    wire [3:0] hex2_val = register_mode ? reg_hex2 : instr_hex2;
    wire [3:0] hex1_val = register_mode ? reg_hex1 : instr_hex1;
    wire [3:0] hex0_val = register_mode ? reg_hex0 : instr_hex0;
    
    // Reset handling for displays
    wire [3:0] display5 = rst ? hex5_val : 4'h0;
    wire [3:0] display4 = rst ? hex4_val : 4'h0;
    wire [3:0] display3 = rst ? hex3_val : 4'h0;
    wire [3:0] display2 = rst ? hex2_val : 4'h0;
    wire [3:0] display1 = rst ? hex1_val : 4'h0;
    wire [3:0] display0 = rst ? hex0_val : 4'h0;
    
    // Connect seven-segment displays
    seven_segment hex5_display(display5, HEX5);
    seven_segment hex4_display(display4, HEX4);
    seven_segment hex3_display(display3, HEX3);
    seven_segment hex2_display(display2, HEX2);
    seven_segment hex1_display(display1, HEX1);
    seven_segment hex0_display(display0, HEX0);
    
    // LED status
    assign LEDR[9] = register_mode;
    assign LEDR[8] = 1'b0; // No longer using this bit
    assign LEDR[7:0] = register_mode ? {3'b000, selected_reg} : {7'b0000000, run_mode};
endmodule