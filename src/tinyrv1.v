module tinyrv1(
    input clk,
    input rst,
    output [31:0] debug_pc,
    output [31:0] debug_instruction,
    output [31:0] debug_alu_result,
    output [4:0] debug_rd,
    output [31:0] debug_write_data,
    input [4:0] debug_reg_addr,
    output [31:0] debug_reg_data
);
    // Processor State
    reg [31:0] pc;
    wire [31:0] next_pc;
    
    // Fetch Stage - Read instruction
    wire [31:0] instruction;
    instr_mem_ip instr_mem(
        .address(pc[11:2]),
        .clock(clk),
        .q(instruction)
    );
    
    // Decode Stage - Control signals & register read
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];
    
    // Control signals using direct assignments
    wire r_type = (opcode == 7'b0110011);
    wire i_type_alu = (opcode == 7'b0010011); // ADDI
    wire i_type_load = (opcode == 7'b0000011); // LW
    wire s_type = (opcode == 7'b0100011); // SW
    wire b_type = (opcode == 7'b1100011); // BNE
    wire j_type = (opcode == 7'b1101111); // JAL
    wire jr_type = (opcode == 7'b1100111) && (rd == 5'b00000) && (funct3 == 3'b000); // JR
    
    // Direct control signal assignment
    wire reg_write = r_type || i_type_alu || i_type_load || j_type;
    wire [2:0] alu_op = (r_type && funct7 == 7'b0000001) ? 3'b010 : 
                        b_type ? 3'b001 : 3'b000;
    wire [1:0] alu_src = s_type || i_type_alu || i_type_load ? 2'b01 : 
                        j_type ? 2'b11 : 2'b00;
    wire mem_read = i_type_load;
    wire mem_write = s_type;
    wire branch = b_type;
    wire jump = j_type;
    wire jump_reg = jr_type;
    
    // Register file
    wire [31:0] read_data1, read_data2;
    wire [31:0] write_data;
    
    reg_file regfile(
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg_data(debug_reg_data)
    );
    
    // Immediate generation
    wire [31:0] imm;
    imm_gen immgen(
        .instruction(instruction),
        .imm(imm)
    );
    
    // Execute Stage - ALU
    wire [31:0] alu_in_a = read_data1;
    wire [31:0] alu_in_b = (alu_src == 2'b00) ? read_data2 :
                           (alu_src == 2'b01) ? imm :
                           (alu_src == 2'b10) ? (pc + imm) : (pc + 4);
    
    wire [31:0] alu_result;
    wire zero_flag;
    
    alu alu_inst(
        .a(alu_in_a),
        .b(alu_in_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero_flag(zero_flag)
    );
    
    // Memory Stage
    wire [31:0] mem_data;
    wire [9:0] mem_addr = alu_result[11:2];  // Word address
    
    data_mem_ip data_mem(
        .address(mem_addr),
        .clock(clk),
        .data(read_data2),
        .wren(mem_write),
        .q(mem_data)
    );
    
    // Write-back Stage
    assign write_data = mem_read ? mem_data :
                        (jump || alu_src == 2'b11) ? (pc + 4) : alu_result;
    
    // Next PC calculation
    wire branch_taken = branch & ~zero_flag; // BNE
    wire [31:0] pc_plus_4 = pc + 4;
    wire [31:0] branch_target = pc + imm;
    
    assign next_pc = jump_reg ? read_data1 :
                     jump ? branch_target :
                     branch_taken ? branch_target : pc_plus_4;
    
    // PC update
    always @(posedge clk or negedge rst) begin
		 if (!rst)
			  pc <= 32'h00000200;  // Change from 32'h0 to match spec
		 else
			  pc <= next_pc;
	end
    
    // Debug outputs
    assign debug_pc = pc;
    assign debug_instruction = instruction;
    assign debug_alu_result = alu_result;
    assign debug_rd = rd;
    assign debug_write_data = write_data;
endmodule