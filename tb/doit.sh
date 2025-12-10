#!/bin/bash

# This script runs the testbench
# Usage: ./doit.sh <file1.cpp> <file2.cpp>

# Constants
SCRIPT_DIR=$(dirname "$(realpath "$0")") #SCRIPT_DIR is the directory this file is in
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests") #test folder is a folder in this directory with name tests
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl") #RTL_FOLDER is set to a file called rtl from the directory above this one
GREEN=$(tput setaf 2) #setting terminal text colour to green
RED=$(tput setaf 1) #setting terminal text colour to red
RESET=$(tput sgr0) #resets terminal text to black and white

# Variables
passes=0
fails=0

# Handle terminal arguments
# $# gives number of arguments, this checks if number of arguments in command is equal to zero 
# if so we run all the tests in the /test folder, so we set files equal to all the files ending in .cpp
# not sure how this works exactly is files a vector?
if [[ $# -eq 0 ]]; then
    # If no arguments provided, run all tests
    files=(${TEST_FOLDER}/*.cpp)
else
    # If arguments provided, use them as input files
    files=("$@") #$@ is an array of all arguments given to the script
fi

#change directory to this directory
cd $SCRIPT_DIR

# Wipe previous test output
# -r  rmoves file hierachy rooted in each file argument
# -f attempts to remove files regardless of file permissions
# test_out/* means we remove the files in test_out directory
rm -rf test_out/*

# Iterate through files
for file in "${files[@]}"; do
    name=$(basename "$file" _tb.cpp | cut -f1 -d\-) #basename ouptuts the filename with _tb.cpp chopped of
    #cut -f1 takes just column 1 with the delimiters being  \ and - is this correct?

    # If verify.cpp -> we are testing the top module
    if [ $name == "verify.cpp" ]; then
        name="top"
    fi

    #exe generates an executable
    #y specifies the directory to search for the modules
    #cc creates C++ output?
    #prefix specifies name of top-level class and makefile
    #name of final executable built if using --exe
    #CFLAGS C++ compiler arguments for makefile
    #LDFLAGS Linker pre-object arguments for makefile

    # Translate Verilog -> C++ including testbench
    verilator   -Wall --trace \
                -cc ${RTL_FOLDER}/${name}.sv \
                --exe ${file} \
                -y ${RTL_FOLDER} \
                --prefix "Vdut" \
                -o Vdut \
                -CFLAGS "-std=c++17 -isystem /opt/homebrew/Cellar/googletest/1.17.0/include"\
                -LDFLAGS "-L/opt/homebrew/Cellar/googletest/1.17.0/lib -lgtest -lgtest_main -lpthread" \

    # Build C++ project with automatically generated Makefile
    #-j specifies number of jobs, no argument is given so there is no limit
    #-C changes the directory to obj_dir/ in this case
    #-f specifes the make file which is Vdut.mk here
    make -j -C obj_dir/ -f Vdut.mk

    # Run executable simulation file
    ./obj_dir/Vdut

    # Check if the test succeeded or not
    #$? is the exit status of the command, zero means success of sorts
    
    if [ $? -eq 0 ]; then
        ((passes++))
    else
        ((fails++))
    fi

done

# Save obj_dir in test_out
#mv means move files, we move obj_dir files to test_out directory
mv obj_dir test_out/

