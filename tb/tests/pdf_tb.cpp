#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdut.h"
#include "../vbuddy.cpp"
#include <string>
#include <cctype>
#include <unistd.h> // for usleep
#include <algorithm> // for std::transform

#define MAX_SIM_CYC 100000000
#define DELAY_US 10000

int main(int argc, char **argv, char **env) {
    int simcyc;
    int tick;

    Verilated::commandArgs(argc, argv);
    Vdut* top = new Vdut;
    
    // Default settings
    std::string dist_name = "Default"; 
    int vbd_mode = 1; // Default to Bar Graph Mode
    int vbd_max_count = 300; // Default max Y-axis for good visibility

    // 1. Process command line argument for name and settings
    if (argc > 1) {
        dist_name = argv[1];
        
        // Extract base name and convert to lowercase for comparison
        size_t last_slash = dist_name.find_last_of('/');
        std::string base_name = dist_name.substr(last_slash + 1);
        std::string lower_name = base_name;
        std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(),
                       [](unsigned char c){ return std::tolower(c); });

        // Set optimal plot mode and scale based on file name
        if (lower_name.find("gaussian") != std::string::npos || 
            lower_name.find("noisy") != std::string::npos) {
            // Gaussian and Noisy data are best viewed as a histogram (Bar Graph Mode 1)
            vbd_mode = 1;
            vbd_max_count = 300; // Higher count for concentrated data
        } else if (lower_name.find("sine") != std::string::npos || 
                   lower_name.find("triangle") != std::string::npos) {
            // Sine and Triangle are often clearer as a continuous Line Plot (Mode 0)
            vbd_mode = 0;
            vbd_max_count = 250; // Use a slightly tighter scale for continuous signals
        }
        
        // Capitalize the first letter for the header display
        if (!dist_name.empty()) {
            dist_name[0] = std::toupper(dist_name[0]);
        }
    }
    
    std::string header = "PDF: " + dist_name;
    
    // Enable waveform tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");
 
    // Initialize Vbuddy
    if (vbdOpen()!=1) return(-1);
    vbdHeader(header.c_str());
    vbdSetMode(vbd_mode); // Use dynamic mode setting
    
    // Initialize signals
    top->clk = 1;
    top->rst = 1;
    top->trigger = 0;
    
    int current_a0 = 0;
    int prev_a0 = 0;
    
    for (simcyc=0; simcyc<MAX_SIM_CYC; simcyc++) {
        // Toggle clock
        for (tick=0; tick<2; tick++) {
            tfp->dump(2*simcyc+tick);
            top->clk = !top->clk;
            top->eval();
        }
        
        // Reset for first 2 cycles
        if (simcyc < 2) {
            top->rst = 1;
        } else {
            top->rst = 0;
        }

        current_a0 = top->a0;
        
        // Robust Plotting Logic: Plot only when a0 changes to a valid bin count (0-255)
        if (current_a0 != prev_a0 && (current_a0 >= 0) && (current_a0 <= 255)) {
            
            // Use the dynamically determined VBD_MAX_COUNT
            vbdPlot(current_a0 & 0xFF, 0, vbd_max_count); 
            usleep(DELAY_US);
        }
        
        // Update previous a0 value
        prev_a0 = current_a0;
        
        // Check for quit
        if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) {
            break;
        }
    }

    vbdClose();
    tfp->close();
    exit(0);
}