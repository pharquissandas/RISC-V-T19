#!/bin/bash

# Usage: ./assemble.sh <file.s>

# Default vars
SCRIPT_DIR=$(dirname "$(realpath "$0")") #SCRIPT_DIR is variable, $ accesses value of variable, $0 is the name of the script executing, realpath gives absolute path of this file, dirname get rid of file portion and gives directory part only
output_file="../rtl/program.hex" #giving path of output file

# Handle terminal arguments
if [[ $# -eq 0 ]]; then # $# gives number of arguments, this checks if number of arguments in command is equal to zero if so we need to tell user to give more arguments
    echo "Usage: ./assemble.sh <file.s>"
    exit 1
fi

input_file=$1 #$1 is the first argument sent to the script
basename=$(basename "$input_file" | sed 's/\.[^.]*$//') #basename removes anything including and past the last slash, here we have sed which is doing a substitution hence s, \.[^.]*$ are replaced with a /
parent=$(dirname "$input_file") 
file_extension="${input_file##*.}" #${input_file##*.} is the value of input_file's path with only whats after the . in the path kept and the rest removed
LOG_DIR="$SCRIPT_DIR/test_out/$basename" #LOG_DIR has value of script_dir followed by /test_out /value of basename

# Create output directory for disassembly, hex and waveforms
mkdir -p $LOG_DIR #makes a directory called value of LOG_DIR, with any non-existent intermediate directories created as necessary

#risc64-unknown-elf-as is an assembler for riscv
#-march=rv32im sets the ISA to be used in this case / the instructions that will be accepted
#-mabi=ilp32 sets the ABI (application binary interface) which defines the purpose of specific registers, its set to ILP32 here
#riscv64-unknown-elf-ld is the gnu linker it links together different files to create an executable file
# -o "a.out" "input_file" says the output of the assembler will be stored in the file a.out and the source code file is $input_file
#the linker will output to a.out.reloc with the source file being a.out, Ttext specifies the text start address, melf32lriscv tells the linker
#the objects being linked are 32-bit RISC-V code
# a.out.reloc is the executable that can be loaded to the processor's instruction memory
#-e is the entry point, the  address where the execution of the program begins - i.e. i think at what addresses to begin writing the output
#-O binary means we write the output file in binary format
#-j .text "a.out.reloc" "a.bin" copies only sections matching .text from a.out.reloc and writes it to a.bin
riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 \
                        -o "a.out" "$input_file"

riscv64-unknown-elf-ld -melf32lriscv \
                        -e 0xBFC00000 \
                        -Ttext 0xBFC00000 \
                        -o "a.out.reloc" "a.out"

riscv64-unknown-elf-objcopy -O binary \
                            -j .text "a.out.reloc" "a.bin"

rm *dis 2>/dev/null
#rm means remove, 2> redirects stderr to the file /dev/null, dis stands for dissambler, not sure yet what this means

# This generates a disassembly file
# Memory in wrong place, but makes it easier to read (should be main = 0xbfc00000)

#objdump displays information from object files
# -f means display summary infromation from the overall header of each of the objfile files
# -d means disassemble, it displays the assembler mnemonics for the machine instructions from the input file
# --source displays soruce code intermixed with disassembly
# -m specifies the architecture to use when disassembling the object files in this case riscv
# I believe we disassemble a.out.reloc and write this into the program.dis file
riscv64-unknown-elf-objdump -f -d --source -m riscv \
                            a.out.reloc > ${LOG_DIR}/program.dis

# Formats into a hex file
# od -v means we will write all input data even if its duplicated, -An specifies the input address base as no address
#-t is to specify the output format, x1 means x = hexadecimal and 1 is the size specifier here its 4 which represents the byte count, so we will
#output the hex 8 hex digits at a time
#"a.bin" is the input file
#tr is translate
#awk scans through the input file for lines matching a set of specified paterns
#$1 denotes a field, with an input line being made up of fields seperated by white space or by the regular expressions
#awk '{$1=$1};1' rewrites a.bin removing whitespace and outputs it to ${output_file}
od -v -An -t x4 "a.bin" | tr -s '\n' | awk '{$1=$1};1' > "${output_file}"


#this part removes the following files
rm "a.out.reloc"
rm "a.out"
rm "a.bin"

