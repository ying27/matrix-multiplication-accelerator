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

    `define Y 1'b1
    `define N 1'b0

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

    `define FF_RESET_PIPE(CLK, RST, STAGES, IN, OUT, INITVAL) \
    generate  \
        if (STAGES==0) \
        begin\
            assign OUT = IN; \
        end \
        else if (STAGES==1) \
        begin\
            `FF_RESET(CLK, RST, IN, OUT, INITVAL) \
        end \
        else \
        begin\
            logic [STAGES-1:0][$bits(IN)-1:0] delayed; \
            always_ff@(posedge CLK) begin \
                if (RST) begin \
                    for (int i = 0 ; i < STAGES; i++) delayed[i] <= INITVAL; \
                end else begin \
                    for (int i = 1 ; i < STAGES; i++) delayed[i] <= delayed[i-1]; \
                        delayed[0] <= IN; \
                end \
                OUT <= delayed[ STAGES - 1]; \
            end \
        end // else: !if(STAGES==1)  \
    endgenerate


    `define TRANSPOSE_ARRAY(CLK, RST, EN, SIZE, IN, OUT)\
    generate begin :TRANSPOSE_ARRAY\
        \
        logic[$clog2(SIZE)-1:0] counter, counter_next;\
        \
        `FF_RESET(CLK, RST, counter_next, counter, '0);\
        \
        assign counter_next = EN? (counter+1)%SIZE : '0;\
        \
        for(genvar gv_row = 0; gv_row < SIZE; ++gv_row) begin :TRANSPOSE_ROW\
            logic [$size(IN)-2:0][$size(IN[0])-1:0] ff_out;\
            logic [$size(IN)-1:0][$size(IN[0])-1:0] intercon;\
            \
            for(genvar gv_i=0; gv_i < $size(IN); ++gv_i) begin\
                `FF_RESET(CLK, RST, intercon[gv_i], ff_out[gv_i], '0);\
            end\
            \
            for(genvar gv_i=0; gv_i < $size(IN)-1; ++gv_i) begin\
                assign intercon[gv_i] = (EN && (counter == gv_row))? IN[gv_i] : ff_out[gv_i+1];\
            end\
            \
            assign intercon[$size(IN)-1] = EN? IN[$size(IN)-1] : '0;\
            assign OUT[gv_row] = ff_out[0];\
        end\
    end\
    endgenerate

`endif
