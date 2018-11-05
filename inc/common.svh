//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Common macros definitions                                     //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`ifndef __COMMON__
`define __COMMON__

`define FF_RESET(CLK, RESET, DATA_I, DATA_O, DEFAULT) \
    always_ff @ (posedge CLK) \
        if (RESET) DATA_O <= DEFAULT; \
        else       DATA_O <= DATA_I;

`define FF_EN(CLK, RESET, EN, DATA_I, DATA_O, DEFAULT) \
    always_ff @ (posedge CLK) \
        if (EN) DATA_O <= DATA_I;

`define FF_RESET_EN(CLK, RESET, EN, DATA_I, DATA_O, DEFAULT) \
    always_ff @ (posedge CLK) \
        if (RESET) DATA_O <= DEFAULT; \
        else if (EN) DATA_O <= DATA_I;

`define DELAY_ARRAY(CLK, RESET, EN, SIZE, ARRAY_DATA_I, ARRAY_DATA_O) \
    for (genvar gv_i=0; gv_i < SIZE; gv_i++) begin \
        if (gv_i == 0) begin\
            assign ARRAY_DATA_O[0] = (RESET == 1'b1) ? '0 : ARRAY_DATA_I[0];\
        end\
        else begin\
            logic [$bits(ARRAY_DATA_I[0])-1:0] delayer [gv_i:0];\
            for (genvar gv_j=0; gv_j < gv_i; gv_j++)\
                 `FF_RESET_EN(CLK, RESET, EN, delayer[gv_j], delayer[gv_j+1], '0)\
            assign delayer[0] = ARRAY_DATA_I[gv_i];\
            assign ARRAY_DATA_O[gv_i] = delayer[gv_i];\
        end\
    end

`define REVERSE_DELAY_ARRAY(CLK, RESET, EN, SIZE, ARRAY_DATA_I, ARRAY_DATA_O) \
    logic [$bits(ARRAY_DATA_I[0])-1:0] reversed [SIZE-1:0];\
    for (genvar gv_r=0; gv_r < SIZE; gv_r++) begin\
        assign reversed[gv_r] = ARRAY_DATA_I[(SIZE-1)-gv_r];\
    end\
    logic [$bits(ARRAY_DATA_I[0])-1:0] delayed [SIZE-1:0];\
    for (genvar gv_r=0; gv_r < SIZE; gv_r++) begin\
        assign ARRAY_DATA_O[gv_r] = delayed[(SIZE-1)-gv_r];\
    end\
    `DELAY_ARRAY(CLK, RESET, EN, SIZE, reversed, delayed)

`endif
