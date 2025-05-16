# TinyRV1 RISC-V Processor Implementation for DE1-SoC FPGA

This repository contains a Verilog implementation of the TinyRV1 RISC-V processor subset for the Altera DE1-SoC FPGA board. TinyRV1 is a minimal subset of the RISC-V RV32IM architecture, featuring 8 key instructions for educational purposes.

## Features

- Complete TinyRV1 instruction set implementation (ADD, ADDI, MUL, LW, SW, JAL, JR, BNE)
- Memory-mapped I/O with 7-segment displays
- Clock control for single-stepping or continuous execution
- Register debugging via onboard display
- Python tool for converting RISC-V assembly to memory initialization files (MIF)

## Hardware Requirements

- Altera DE1-SoC FPGA Development Board
- USB Blaster for programming

## Software Requirements

- Intel Quartus Prime (18.0 or later)
- Python 3.x (for assembly conversion)

## Quick Start

1. Clone this repository
2. Connect your DE1-SoC board via USB
3. Open Quartus Programmer
4. Program your FPGA with one of the .sof files in the 'output_files' folder, the expected outputs for each .sof is in the 'output_files/Test_Files_Outputs.txt'

The design will begin execution from the reset vector (0x200) with the default program.

## Board Interaction

- KEY[0]: Reset (active low)
- KEY[1]: Toggle between continuous and single-step mode
- KEY[2]: Step execution (when in single-step mode)
- SW[9]: Switch between register display mode and instruction display mode
- SW[4:0]: Select register to view (in register mode)
- HEX displays: Show selected register value or processor state

## Creating Your Own Programs

1. Write your RISC-V assembly code, using only the TinyRV1 instruction subset
2. Use the conversion tool to generate a MIF file:   python tools/asmToMif.py your_program.s your_program.mif
3. Update the project to use your MIF file:
- Either replace `ip/program.mif` with your file
- Or update the reference in `instr_mem_ip.v` to point to your file
4. Recompile the project with Quartus
5. Program your FPGA with the new .sof file

## Project Structure

- `src/`: Verilog source files for the processor
- `ip/`: Memory IP cores and initialization files
- `test/`: Testbench files for simulation
- `programs/`: Assembly programs and MIF files
- `tools/`: Utility scripts
- `quartus/`: Quartus project files
- `output_files/`: Compiled FPGA bitstreams

## IP Cores and Memory Initialization

This project uses several Quartus IP cores for memory:
- `ip/instr_mem_ip.v`: Instruction memory implementation
- `ip/data_mem_ip.v`: Data memory implementation

The instruction memory is preloaded with `program.mif`, which must remain in the `ip/` directory for Quartus to find it correctly. If you want to use your own program:

1. Either replace `ip/program.mif` with your new MIF file (keeping the same name)
2. Or update the IP core settings to point to your custom MIF file location

### Regenerating IP Cores

If you need to modify the memory configuration:
1. Open the project in Quartus
2. Navigate to Tools → IP Catalog
3. Find and edit the appropriate memory IP core
4. Generate the updated IP files
5. Ensure your MIF file is in the correct location

## Debugging

- Use ModelSim for RTL simulation with the provided testbench
- Watch register values on the board's 7-segment displays
- Use the single-step mode to verify instruction execution

## Implementation Details

The TinyRV1 processor implements a subset of the RISC-V RV32IM instruction set, specifically designed for educational purposes. Key architectural features include:

- 32-bit datapath
- 32 general-purpose registers (x0-x31)
- 1MB addressable memory
- Little endian memory ordering
- Reset vector at 0x200 (byte address)

The design focuses on simplicity and observability, making it ideal for learning computer architecture concepts.

## Academic Context

This project was developed as part of a computer architecture course assignment. The implementation follows the TinyRV1 specification created by Christopher Batten.

## License

This project is licensed under the MIT License:

MIT License

Copyright (c) 2025 Edgar Reyes-Rivera

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Acknowledgments

- Based on the Tiny RISC-V ISA specification by Christopher Batten
- Developed as part of coursework for Computer Organization - ECE_289
- Thanks to the DE1-SoC documentation from Terasic
