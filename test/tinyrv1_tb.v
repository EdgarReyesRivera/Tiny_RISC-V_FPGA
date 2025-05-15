`timescale 1ns / 1ps

module tinyrv1_tb();
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns = 100MHz
    
    // Testbench signals
    reg clk;
    reg rst;
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_alu_result;
    wire [4:0] debug_rd;
    wire [31:0] debug_write_data;
    reg [4:0] debug_reg_addr;
    wire [31:0] debug_reg_data;
    
    // Expected values for verification
    reg [31:0] expected_reg [0:31]; // Register array for verification
    integer i; // Loop variable
    
    // Instance of TinyRV1 processor
    tinyrv1 dut (
        .clk(clk),
        .rst(rst),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result(debug_alu_result),
        .debug_rd(debug_rd),
        .debug_write_data(debug_write_data),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg_data(debug_reg_data)
    );
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Initialize test
    initial begin
        $display("Starting TinyRV1 Processor Testbench");
        
        // Initialize signals
        clk = 0;
        rst = 0;
        debug_reg_addr = 0;
        
        // Initialize expected register values
        for (i = 0; i < 32; i = i + 1) begin
            expected_reg[i] = 0;
        end
        
        // Reset sequence
        #(CLK_PERIOD*2);
        rst = 1;
        #(CLK_PERIOD*2);
        
        // Wait for program to execute
        // Assuming our test program has at most 50 instructions
        #(CLK_PERIOD*50);
        
        // Verify register contents
        check_registers();
        
        // End simulation
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor processor execution
    always @(posedge clk) begin
        if (rst) begin
            $display("Time=%0t: PC=%h, Instr=%h, ALU=%h, RD=%d, WrData=%h", 
                     $time, debug_pc, debug_instruction, debug_alu_result, 
                     debug_rd, debug_write_data);
            
            // Update expected register values based on instruction execution
            if (debug_rd != 0 && is_reg_write_instr(debug_instruction)) begin
                expected_reg[debug_rd] = debug_write_data;
            end
        end
    end
    
    // Function to determine if instruction writes to register file
    function is_reg_write_instr;
        input [31:0] instr;
        reg [6:0] opcode;
        begin
            opcode = instr[6:0];
            
            is_reg_write_instr = 0; // Default to false
            
            case (opcode)
                7'b0110011: is_reg_write_instr = 1; // R-type
                7'b0010011: is_reg_write_instr = 1; // I-type ALU
                7'b0000011: is_reg_write_instr = 1; // LW
                7'b1101111: is_reg_write_instr = 1; // JAL
                default: is_reg_write_instr = 0;
            endcase
        end
    endfunction
    
    // Task to check register contents
    task check_registers;
        begin
            $display("Verifying register contents:");
            for (i = 1; i < 32; i = i + 1) begin
                debug_reg_addr = i;
                #1; // Allow time for debug_reg_data to update
                
                if (expected_reg[i] !== debug_reg_data) begin
                    $display("  x%0d: ERROR - Expected=%h, Actual=%h", 
                             i, expected_reg[i], debug_reg_data);
                end else begin
                    $display("  x%0d: OK - Value=%h", i, debug_reg_data);
                end
            end
        end
    endtask
    
    // Optional: Memory dump for debugging
    initial begin
        $dumpfile("tinyrv1_tb.vcd");
        $dumpvars(0, tinyrv1_tb);
    end
endmodule