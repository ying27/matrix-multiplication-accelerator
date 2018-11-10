#include "verilated.h"
#include <iostream>
#include "verilated_fst_c.h"
#include <getopt.h>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <algorithm>
#include <cctype>
#include <locale>
using namespace std;


#define PATH_LENGTH 1000

#define mStr(x) #x
#define mStr_(x) mStr(x)
#define topModuleInc mStr_(CXX_TOP_LEVEL.h)

#include topModuleInc

// trim from start (in place)
static inline void ltrim(string &s) {
    s.erase(s.begin(), find_if(s.begin(), s.end(), [](int ch) {
        return !isspace(ch);
    }));
}

// trim from end (in place)
static inline void rtrim(string &s) {
    s.erase(find_if(s.rbegin(), s.rend(), [](int ch) {
        return !isspace(ch);
    }).base(), s.end());
}

// trim from both ends (in place)
static inline void trim(string &s) {
    ltrim(s);
    rtrim(s);
}

void usage(char* name) {
    cerr << "Usage: " << name << " [--trace traceFile.fst] [--timeout timeout] [--help]"<<endl;
    cerr << "\tTrace: off by default" << endl << "\tTimeout: default 1" << endl;
    exit(EXIT_FAILURE);
}

void getArgs(int argc, char* argv[], uint64_t &timeout, bool &trace, char* traceFile, bool& signals, char* signalFile){

    trace = false;
    timeout = 1;
    signals = false;

    struct option argOptions[] = {
        { "trace", required_argument, 0, 1},
        { "timeout", required_argument, 0, 2},
        { "signals", required_argument, 0, 3},
        { "help", no_argument, 0, 4}
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
            case 3:
                signals = true;
                strncpy(signalFile, optarg, PATH_LENGTH);
                break;
            default:
                usage(argv[0]);
        }
    }
}

vector<string> getSignalNames(stringstream &file){
    string headerstring;
    vector<string> headers = vector<string>();
    if(getline(file, headerstring, '\n')){
        stringstream header_stream(headerstring);

        string header;
        while(getline(header_stream, header, ',')){
            trim(header);
            headers.push_back(header);
        }

    }
    return headers;
}

int main(int argc, char** argv, char** env) {

    Verilated::commandArgs(argc, argv);

    bool trace;
    char traceFile[PATH_LENGTH];
    bool signals;
    char signalFile[PATH_LENGTH];
    uint64_t timeout;

    getArgs(argc, argv, timeout, trace, traceFile, signals, signalFile);

    stringstream signalData;
    vector<string> signalNames;

    if(signals) {
        ifstream signal_file(signalFile);
        signalData << signal_file.rdbuf();
        signal_file.close();
        signalNames = getSignalNames(signalData);
        for(int i=0; i < signalNames.size(); ++i) cout << "Signal name: "  << signalNames[i] << endl;
    }

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

        main_time += 1;
        top->reset = 0;
        top->clk = 0;
        top->eval();

#ifdef TRACE
        if(trace) tfp->dump (main_time);
#endif
    }

    if(main_time >= timeout) cout << "ERROR: timeout" << endl;

#ifdef TRACE
    if(trace) tfp->close();
#endif
    delete top;

    exit(0);
}
