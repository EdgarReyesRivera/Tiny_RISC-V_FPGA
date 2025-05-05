module imm_gen(
	input [31:0] inst,
	input [2:0] imm_type,
	output reg [31:0] imm
);

	parameter I_IMM = 3'b000;
	parameter S_IMM = 3'b001;
   parameter B_IMM = 3'b010;
   parameter U_IMM = 3'b011;
   parameter J_IMM = 3'b100;
	
	always @(*) begin
        case (imm_type)
            // I-immediate format (used in ADDI, SLTI, SLTIU, XORI, ORI, ANDI, LW, JALR, etc.)
            I_IMM: imm = {{20{inst[31]}}, inst[31:20]};
            
            // S-immediate format (used in SW)
            S_IMM: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            
            // B-immediate format (used in BEQ, BNE, BLT, BGE, BLTU, BGEU)
            B_IMM: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            
            // U-immediate format (used in LUI, AUIPC)
            U_IMM: imm = {inst[31:12], 12'b0};
            
            // J-immediate format (used in JAL)
            J_IMM: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            
            // Default case
            default: imm = 32'b0;
        endcase
    end

endmodule