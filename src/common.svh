//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Common macros definitions                                     //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    REVISION:       0.1 - Flipflop macro with reset support definition            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`define FF_RESET(CLK, RESET, DATA_I, DATA_O, DEFAULT) \
    always_ff @ (posedge CLK) \
        if (RESET) DATA_O <= DEFAULT; \
        else       DATA_O <= DATA_I;
