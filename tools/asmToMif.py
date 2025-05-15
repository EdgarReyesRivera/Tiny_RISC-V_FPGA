#!/usr/bin/env python3
"""
RISC-V Assembly to MIF Converter
Converts RISC-V assembly into Memory Initialization File (MIF) format.
Supports TinyRV1 format with reset vector at 0x200 (word address 0x80).

Usage: python asmToMif.py input_file.s output_file.mif
"""

import sys
import re

# Register mapping
registers = {
    'x0': 0, 'zero': 0, 'x1': 1, 'ra': 1, 'x2': 2, 'sp': 2,
    'x3': 3, 'gp': 3, 'x4': 4, 'tp': 4, 'x5': 5, 't0': 5,
    'x6': 6, 't1': 6, 'x7': 7, 't2': 7, 'x8': 8, 's0': 8, 'fp': 8,
    'x9': 9, 's1': 9, 'x10': 10, 'a0': 10, 'x11': 11, 'a1': 11,
    'x12': 12, 'a2': 12, 'x13': 13, 'a3': 13, 'x14': 14, 'a4': 14,
    'x15': 15, 'a5': 15, 'x16': 16, 'a6': 16, 'x17': 17, 'a7': 17,
    'x18': 18, 's2': 18, 'x19': 19, 's3': 19, 'x20': 20, 's4': 20,
    'x21': 21, 's5': 21, 'x22': 22, 's6': 22, 'x23': 23, 's7': 23,
    'x24': 24, 's8': 24, 'x25': 25, 's9': 25, 'x26': 26, 's10': 26,
    'x27': 27, 's11': 27, 'x28': 28, 't3': 28, 'x29': 29, 't4': 29,
    'x30': 30, 't5': 30, 'x31': 31, 't6': 31
}

# Constants
RESET_VECTOR_BYTE_ADDR = 0x200
RESET_VECTOR_WORD_ADDR = RESET_VECTOR_BYTE_ADDR // 4

def parse_reg(reg_str):
    """Convert register string to its number"""
    reg_str = reg_str.strip()
    if reg_str in registers:
        return registers[reg_str]
    else:
        raise ValueError(f"Unknown register: {reg_str}")

def parse_imm(imm_str):
    """Parse an immediate value, which can be decimal, hex, or binary"""
    imm_str = imm_str.strip()
    
    # Handle offset(reg) format
    if '(' in imm_str:
        imm_str = imm_str.split('(')[0].strip()
    
    # Determine base
    if imm_str.startswith('0x'):
        base = 16
        imm_str = imm_str[2:]
    elif imm_str.startswith('0b'):
        base = 2
        imm_str = imm_str[2:]
    else:
        base = 10
    
    return int(imm_str, base)

def encode_r_type(funct7, rs2, rs1, funct3, rd, opcode):
    """Encode R-type instruction"""
    instr = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return instr

def encode_i_type(imm, rs1, funct3, rd, opcode):
    """Encode I-type instruction"""
    # Ensure immediate is 12 bits
    imm = imm & 0xFFF
    instr = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return instr

def encode_s_type(imm, rs2, rs1, funct3, opcode):
    """Encode S-type instruction"""
    # Extract immediate fields
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0 = imm & 0x1F
    instr = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
    return instr

def encode_b_type(imm, rs2, rs1, funct3, opcode):
    """Encode B-type instruction"""
    # Extract immediate fields (imm is already in bytes, not words)
    imm = imm & 0x1FFE  # 13 bits, LSB is always 0
    imm_12 = (imm >> 12) & 0x1
    imm_11 = (imm >> 11) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1 = (imm >> 1) & 0xF
    instr = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
    return instr

def encode_j_type(imm, rd, opcode):
    """Encode J-type instruction"""
    # Extract immediate fields (imm is already in bytes, not words)
    imm = imm & 0x1FFFFE  # 20 bits, LSB is always 0
    imm_20 = (imm >> 20) & 0x1
    imm_10_1 = (imm >> 1) & 0x3FF
    imm_11 = (imm >> 11) & 0x1
    imm_19_12 = (imm >> 12) & 0xFF
    instr = (imm_20 << 31) | (imm_10_1 << 21) | (imm_11 << 20) | (imm_19_12 << 12) | (rd << 7) | opcode
    return instr

def process_line(line, labels, current_addr):
    """Process a single line of assembly"""
    # Remove comments
    line = re.sub(r'[#;].*$', '', line).strip()
    
    # Skip empty lines
    if not line:
        return None
        
    # Skip directives
    if line.startswith('.'):
        return None

    # Check for labels (ending with :)
    label_match = re.match(r'^(\w+):(.*)$', line)
    if label_match:
        # Extract any instruction after the label
        line = label_match.group(2).strip()
        if not line:
            return None
    
    # Parse instruction
    parts = re.split(r'[,\s]+', line)
    op = parts[0].lower()
    args = parts[1:]
    
    # Skip if no valid instruction
    if not op or not op[0].isalpha():
        return None
    
    # Resolve label references in operands
    for i, arg in enumerate(args):
        if arg in labels:
            offset = labels[arg] - current_addr
            args[i] = str(offset)
    
    # Encode based on instruction type
    if op in ['add', 'sub', 'mul']:
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        rs2 = parse_reg(args[2])
        
        if op == 'add':
            return encode_r_type(0b0000000, rs2, rs1, 0b000, rd, 0b0110011)
        elif op == 'sub':
            return encode_r_type(0b0100000, rs2, rs1, 0b000, rd, 0b0110011)
        elif op == 'mul':
            return encode_r_type(0b0000001, rs2, rs1, 0b000, rd, 0b0110011)
    
    elif op == 'addi':
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        imm = parse_imm(args[2])
        return encode_i_type(imm, rs1, 0b000, rd, 0b0010011)
    
    elif op == 'lw':
        rd = parse_reg(args[0])
        # Handle offset(rs1) format
        mem_ref = args[1]
        if '(' in mem_ref and ')' in mem_ref:
            imm_str, rs1_str = mem_ref.split('(')
            rs1_str = rs1_str.rstrip(')')
            imm = parse_imm(imm_str)
            rs1 = parse_reg(rs1_str)
            return encode_i_type(imm, rs1, 0b010, rd, 0b0000011)
    
    elif op == 'sw':
        rs2 = parse_reg(args[0])
        # Handle offset(rs1) format
        mem_ref = args[1]
        if '(' in mem_ref and ')' in mem_ref:
            imm_str, rs1_str = mem_ref.split('(')
            rs1_str = rs1_str.rstrip(')')
            imm = parse_imm(imm_str)
            rs1 = parse_reg(rs1_str)
            return encode_s_type(imm, rs2, rs1, 0b010, 0b0100011)
    
    elif op in ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']:
        rs1 = parse_reg(args[0])
        rs2 = parse_reg(args[1])
        imm = parse_imm(args[2])
        
        funct3 = {
            'beq': 0b000,
            'bne': 0b001,
            'blt': 0b100,
            'bge': 0b101,
            'bltu': 0b110,
            'bgeu': 0b111
        }[op]
        
        return encode_b_type(imm, rs2, rs1, funct3, 0b1100011)
    
    elif op == 'jal':
        rd = parse_reg(args[0]) if len(args) > 1 else 1  # Default to ra (x1)
        imm = parse_imm(args[-1])
        return encode_j_type(imm, rd, 0b1101111)
    
    elif op == 'jalr':
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        imm = parse_imm(args[2]) if len(args) > 2 else 0
        return encode_i_type(imm, rs1, 0b000, rd, 0b1100111)
    
    elif op == 'j':  # Pseudo-instruction for jal x0, offset
        imm = parse_imm(args[0])
        return encode_j_type(imm, 0, 0b1101111)
    
    elif op == 'jr':  # Pseudo-instruction for jalr x0, rs1, 0
        rs1 = parse_reg(args[0])
        return encode_i_type(0, rs1, 0b000, 0, 0b1100111)
    
    else:
        raise ValueError(f"Unsupported instruction: {op}")

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input_file.s output_file.mif")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    # First pass: collect labels
    labels = {}
    # Start at reset vector
    address = RESET_VECTOR_BYTE_ADDR
    
    with open(input_file, 'r') as f:
        for line in f:
            # Remove comments
            clean_line = re.sub(r'[#;].*$', '', line).strip()
            
            # Skip empty lines and directives
            if not clean_line or clean_line.startswith('.'):
                continue
            
            # Check for labels
            label_match = re.match(r'^(\w+):(.*)$', clean_line)
            if label_match:
                label = label_match.group(1)
                labels[label] = address
                # If there's an instruction after the label, count it
                remaining = label_match.group(2).strip()
                if remaining and not remaining.startswith('.'):
                    address += 4
            else:
                # Regular instruction
                address += 4
    
    # Second pass: generate code
    instructions = []
    # Start at reset vector
    address = RESET_VECTOR_BYTE_ADDR
    
    valid_line_count = 0
    
    with open(input_file, 'r') as f:
        all_lines = f.readlines()
        
    for line in all_lines:
        # Skip directives
        clean_line = re.sub(r'[#;].*$', '', line).strip()
        if not clean_line or clean_line.startswith('.'):
            continue
            
        # Check for label-only lines
        label_match = re.match(r'^(\w+):(.*)$', clean_line)
        if label_match and not label_match.group(2).strip():
            continue
        
        try:
            instr = process_line(line, labels, address)
            if instr is not None:
                instructions.append((address, instr))
                address += 4
                valid_line_count += 1
        except Exception as e:
            print(f"Error processing line '{line.strip()}': {e}")
            sys.exit(1)
    
    # Write output in MIF format
    depth = 1024  # Memory depth in words
    nop_instruction = 0x00000013  # addi x0, x0, 0 (NOP)
    
    with open(output_file, 'w') as f:
        # Write MIF header
        f.write("DEPTH = 1024;\n")
        f.write("WIDTH = 32;\n")
        f.write("ADDRESS_RADIX = HEX;\n")
        f.write("DATA_RADIX = HEX;\n\n")
        
        f.write("CONTENT\n")
        f.write("BEGIN\n")
        
        # Write comment explaining memory organization
        f.write("-- TinyRV1 program with reset vector at 0x200 (word address 0x80)\n")
        
        # Write instruction data at correct addresses
        for byte_addr, instr in instructions:
            # Convert byte address to word address for MIF file
            word_addr = byte_addr // 4
            word_addr_hex = format(word_addr, '03X')  # 3-digit hex address
            instr_hex = format(instr, '08X')  # 8-digit hex instruction
            
            # Write the instruction without byte address comments
            f.write(f"{word_addr_hex} : {instr_hex};\n")
        
        # Fill all other addresses with NOPs
        f.write("-- Fill remaining memory with NOPs\n")
        f.write(f"[000..{format(RESET_VECTOR_WORD_ADDR-1, '03X')}] : {format(nop_instruction, '08X')};\n")
        
        # Find highest used word address
        highest_used = max(addr // 4 for addr, _ in instructions)
        
        # Fill the gap from highest used to the end with NOPs
        if highest_used < 1023:  # 1023 is the last address in a 1024-depth memory
            f.write(f"[{format(highest_used+1, '03X')}..3FF] : {format(nop_instruction, '08X')};\n")
        
        f.write("END;\n")
    
    print(f"Converted {valid_line_count} instructions to {output_file}")
    print(f"Instructions start at reset vector 0x{RESET_VECTOR_BYTE_ADDR:08X} (word address 0x{RESET_VECTOR_WORD_ADDR:03X})")

if __name__ == "__main__":
    main()