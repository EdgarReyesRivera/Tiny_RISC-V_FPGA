module imm_gen(
    input [31:0] instruction,
    output reg [31:0] imm
);
    // Extract instruction components for clarity
    wire [6:0] opcode = instruction[6:0];
    
    // Pre-calculate common immediate components
    wire [19:0] sign_ext = {20{instruction[31]}};
    
    // Simplified immediate calculation
    always @(*) begin
        case(opcode)
            7'b0010011, // I-type (ADDI)
            7'b0000011, // I-type (LW)
            7'b1100111: // I-type (JR using JALR)
                imm = {sign_ext, instruction[31:20]};
                
            7'b0100011: // S-type (SW)
                imm = {sign_ext, instruction[31:25], instruction[11:7]};
                
            7'b1100011: // B-type (BNE)
                imm = {sign_ext, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                
            7'b1101111: // J-type (JAL)
                imm = {{12{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                
            default: 
                imm = 32'b0;
        endcase
    end
endmodule