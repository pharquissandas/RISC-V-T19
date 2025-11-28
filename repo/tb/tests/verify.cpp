#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, TestAddiBne)
{
    setupTest("1_addi_bne");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 254);
}

TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    setData("reference/gaussian.mem");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 15363);
}

// /* Instruction Coverage */ 

// Upper and Jump/Link Instructions
TEST_F(CpuTestbench, TestLUI){
    setupTest("lui_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, (0b1010'1010'1010'1010'1010'0000'0000'0000) - 1);
}

TEST_F(CpuTestbench, TestAUIPC){
    setupTest("auipc_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 2);
}

TEST_F(CpuTestbench, TestJAL){
    setupTest("jal_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 2);
}

TEST_F(CpuTestbench, TestJALR){
    setupTest("jalr_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 2);
}

// PC-relative Branch Instructions
TEST_F(CpuTestbench, TestBEQ){
    setupTest("beq_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestBNE){ 
    setupTest("bne_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestBLT){
    setupTest("blt_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestBGE){
    setupTest("bge_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestBLTU){
    setupTest("bltu_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestBGEU){
    setupTest("bgeu_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

// Load Instructions
TEST_F(CpuTestbench, TestLB){
    setupTest("lb_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x7F);
}

TEST_F(CpuTestbench, TestLH){
    setupTest("lh_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x7FFF);
}

TEST_F(CpuTestbench, TestLW){
    setupTest("lw_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, -1);
}

TEST_F(CpuTestbench, TestLBU){
    setupTest("lbu_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0xFF);
}

TEST_F(CpuTestbench, TestLHU){
    setupTest("lhu_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0xFFFF);
}

// Store Instructions
TEST_F(CpuTestbench, TestSB){
    setupTest("sb_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0xFF);
}

TEST_F(CpuTestbench, TestSH){
    setupTest("sh_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0xFFFF);
}

TEST_F(CpuTestbench, TestSW){
    setupTest("sw_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, -1);
}

// Immediate Instructions
TEST_F(CpuTestbench, TestADDI){
    setupTest("addi_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 8); // 5 + 3
}

TEST_F(CpuTestbench, TestSLTI){
    setupTest("slti_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1); // 5 < 10, so true (1)
}

TEST_F(CpuTestbench, TestSLTIU){
    setupTest("sltiu_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0); // 0xFFFFFFFF < 1 in unsigned compare, so true (1)
}

TEST_F(CpuTestbench, TestXORI){
    setupTest("xori_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 6); // 5 ^ 3 = 6
}

TEST_F(CpuTestbench, TestORI){
    setupTest("ori_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 7); // 5 | 3 = 7
}

TEST_F(CpuTestbench, TestANDI){
    setupTest("andi_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1); // 5 & 3 = 1
}

TEST_F(CpuTestbench, TestSLLI){
    setupTest("slli_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 20); // 5 << 2 = 20
}

TEST_F(CpuTestbench, TestSRLI){
    setupTest("srli_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, (uint32_t) -8 >> 2);
}

TEST_F(CpuTestbench, TestSRAI){
    setupTest("srai_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, -2); // -8 >> 2 = -2 (arithmetic, preserves sign)
}

// Register-Register Instructions
TEST_F(CpuTestbench, TestADD){
    setupTest("add_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 8); // 5 + 3
}

TEST_F(CpuTestbench, TestSUB){
    setupTest("sub_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 2); // 5 - 3
}

TEST_F(CpuTestbench, TestXOR){
    setupTest("xor_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 6); // 5 ^ 3 = 6
}

TEST_F(CpuTestbench, TestSLL){
    setupTest("sll_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 20); // 5 << 2 = 20
}

TEST_F(CpuTestbench, TestSLT){
    setupTest("slt_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1); // 5 < 10, so true (1)
}

TEST_F(CpuTestbench, TestSLTU){
    setupTest("sltu_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0); // 0xFFFFFFFF is not less than 1 in unsigned compare, so false (0)
}

TEST_F(CpuTestbench, TestSRL){
    setupTest("srl_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, (uint32_t) -8 >> 2);
}

TEST_F(CpuTestbench, TestSRA){
    setupTest("sra_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, -2); // -8 >> 2 = -2 (arithmetic, preserves sign)
}

TEST_F(CpuTestbench, TestOR){
    setupTest("or_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 7); // 5 | 3 = 7
}

TEST_F(CpuTestbench, TestAND){
    setupTest("and_test");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1); // 5 & 3 = 1
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
