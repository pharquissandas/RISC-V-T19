SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl_single_cycle")
name="top"
test_name="triangle_tb"

rm -rf obj_dir
rm -f top.vcd

verilator -Wall --cc --trace \
    -I${RTL_FOLDER} \
    ${RTL_Y_FLAGS} \
    ${RTL_FOLDER}/${name}.sv \
    --exe ${TEST_FOLDER}/${test_name}.cpp \
    -o V${name}

make -j -C obj_dir/ -f V${name}.mk V${name}

obj_dir/V${name}

rm -rf top.vcd
rm -rf obj_dir