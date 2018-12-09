#include "verilated.h"
#include <iostream>
using namespace std;
#include "verilated_fst_c.h"
#include <getopt.h>

#define PATH_LENGTH 1000

#define mStr(x) #x
#define mStr_(x) mStr(x)
#define topModuleInc mStr_(CXX_TOP_LEVEL.h)

#include topModuleInc

void usage(char* name) {
    cerr << "Usage: " << name << " [--trace traceFile.fst] [--timeout timeout] [--help]"<<endl;
    cerr << "\tTrace: off by default" << endl << "\tTimeout: default 1" << endl;
    exit(EXIT_FAILURE);
}

void getArgs(int argc, char* argv[], uint64_t &timeout, bool &trace, char* traceFile){

    trace = false;
    timeout = 1;

    struct option argOptions[] = {
        { "trace", required_argument, 0, 1},
        { "timeout", required_argument, 0, 2},
        { "help", no_argument, 0, 3}
    };

    int idx;
    while ( (idx = getopt_long(argc, argv, "", argOptions, NULL)) != -1 ){
        switch(idx){
            case 1:
                trace = true;
                strncpy(traceFile, optarg, PATH_LENGTH);
                break;
            case 2:
                timeout = strtol(optarg, NULL, 0);
                break;
            default:
                usage(argv[0]);
        }
    }
}

int main(int argc, char** argv, char** env) {

    Verilated::commandArgs(argc, argv);

    bool trace;
    char traceFile[PATH_LENGTH];
    uint64_t timeout;

    getArgs(argc, argv, timeout, trace, traceFile);

    CXX_TOP_LEVEL* top = new CXX_TOP_LEVEL ();

#ifdef TRACE
    VerilatedFstC* tfp = new VerilatedFstC;

    if(trace){
        Verilated::traceEverOn(true);
        top->trace(tfp, 99);
        tfp->open(traceFile);
    }
#endif

    int main_time = 0;
    top->clk = 0;
    top->reset = 1;

#ifdef TRACE
    if(trace) tfp->dump(main_time);
#endif

    top->eval();
    while (!Verilated::gotFinish() && main_time < timeout) {
        main_time += 1;

        top->clk = 1;
        top->eval();

#ifdef TRACE
        if(trace) tfp->dump (main_time);
#endif
        if(!Verilated::gotFinish()){

            main_time += 1;
            top->reset = 0;
            top->clk = 0;
            top->eval();

#ifdef TRACE
            if(trace) tfp->dump (main_time);
#endif
        }
    }

    if(main_time >= timeout) cout << "ERROR: timeout" << endl;

#ifdef TRACE
    if(trace) tfp->close();
#endif
    delete top;

    exit(0);
}
