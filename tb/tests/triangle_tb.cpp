#include <cstdio>
#include <utility>

#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "vbuddy.cpp"
#define MAX_SIM_CYC 1300000

int
main (int argc, char **argv, char **env)
{
  int simcyc;
  int tick;
  int lights = 0;

  std::ignore = system (("./assemble.sh asm/5_pdf.s"));

  // Copy the data.hex file
  system (("cp reference/triangle.mem data.hex"));

  Verilated::commandArgs (argc, argv);
  // init top verilog instance
  Vtop *top = new Vtop;
  // init trace dump
  Verilated::traceEverOn (true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("top.vcd");

  // init Vbuddy
  if (vbdOpen () != 1)
    return (-1);
  vbdHeader ("Triangle Graph");
  vbdSetMode (1); // Flag mode set to one-shot

  // initialize simulation inputs
  top->clk = 1;

  // run simulation for MAX_SIM_CYC clock cycles
  for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++)
    {
      // dump variables into VCD file and toggle clock
      for (tick = 0; tick < 2; tick++)
        {
          tfp->dump (2 * simcyc + tick);
          top->clk = !top->clk;
          top->eval ();
        }

      if (simcyc > 434300 && (top->a0) < 0x99ec && simcyc % 6 == 0)
        {
          vbdPlot (top->a0, 0, 255);
          vbdCycle (simcyc);
        }

      // Exit simulation if Vbuddy or Verilator finishes
      if (Verilated::gotFinish () || vbdGetkey () == '`')
        break;
    }

  vbdClose ();
  tfp->close ();
  if (top)
    delete top;
  if (tfp)
    delete tfp;

  std::ignore = std::remove ("data.hex");
  std::ignore = std::remove ("program.hex");

  exit (0);
}