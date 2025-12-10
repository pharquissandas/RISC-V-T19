#!/bin/sh

# Clean up any previous obj_dir
rm -rf obj_dir/
rm -rf test_out/obj_dir
rm -rf test_out/pdf/obj_dir/

# --- CRITICAL FIX 1: Create the output directory first ---
mkdir -p test_out/pdf

# Assemble the PDF program
# This command is assumed to create the hex file in the reference directory.
./assemble.sh reference/pdf.s

# --- CRITICAL FIX 2: Copy the assembled file (assuming it is named pdf.hex) to staging ---
# This fixes the "cannot stat 'reference/program.hex'" error.
cp reference/pdf.hex test_out/pdf/program.hex

# Copy data file (use gaussian by default, or first argument)
DATA_FILE=${1:-reference/gaussian.mem}
DIST_NAME=$(basename "$DATA_FILE" .mem)
cp "$DATA_FILE" test_out/pdf/data.hex

# Copy hex files for verilator (using the correct generic names for Verilog to read)
cp test_out/pdf/program.hex ./program.hex
cp test_out/pdf/data.hex ./data.hex

# Run Verilator with PDF testbench
verilator -Wall -Wno-fatal --trace \
      -cc ../rtl/top.sv \
      --exe ./tests/pdf_tb.cpp \
      -y ../rtl/ \
      --prefix "Vdut"

# Build C++ project
make -j -C obj_dir/ -f Vdut.mk Vdut

# Run executable with distribution name
obj_dir/Vdut "$DIST_NAME"

# Move waveform and obj_dir to test directory
mv waveform.vcd test_out/pdf/ 2>/dev/null
mv obj_dir test_out/pdf/

# Clean up
rm -f program.hex data.hex