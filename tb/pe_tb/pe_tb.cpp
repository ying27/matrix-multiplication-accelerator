#include "Vpe_tb.h"
#include "verilated.h"
#include <iostream>
using namespace std;

#ifndef TRACE
int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vpe_tb* top = new Vpe_tb;
    top->clk = 0;
    top->reset = 1;
    top->eval();
    while (!Verilated::gotFinish()) { 
        top->clk = 1;
        top->eval();
        top->reset = 0;
        top->clk = 0;
        top->eval();
    }
    delete top;
    exit(0);
}
#else 
#include "verilated_fst_c.h"

int main(int argc, char** argv, char** env) {
    
    Verilated::commandArgs(argc, argv);

    if(argc < 2) {
        cout << "Usage on trace: ./"<< argv[0] << " trace_target" << endl;
    }

    string tracefile = argv[1];

    Vpe_tb* top = new Vpe_tb;
    Verilated::traceEverOn(true);
    VerilatedFstC* tfp = new VerilatedFstC;
    int main_time = 0;
    top->trace (tfp, 99);
    tfp->open(tracefile.c_str());
    top->clk = 0;
    top->reset = 1;
    tfp->dump (main_time);
    top->eval();
    while (!Verilated::gotFinish()) {
        main_time += 1;
        tfp->dump (main_time);
        top->clk = 1;
        top->eval();
        main_time += 1;
        tfp->dump (main_time);
        top->reset = 0;
        top->clk = 0;
        top->eval();
    }
    tfp->close();
    delete top;
    exit(0);

}
#endif
