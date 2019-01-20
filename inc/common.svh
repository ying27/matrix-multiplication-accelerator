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

    `define DELAY_ARRAY_CG(CLK, RESET, EN, DATA_TYPE, SIZE, ARRAY_DATA_I, ARRAY_DATA_O) \
    for (genvar gv_i=0; gv_i < SIZE; gv_i++) begin \
        if (gv_i == 0) begin\
            assign ARRAY_DATA_O[0] = (RESET == 1'b1) ? '0 : ARRAY_DATA_I[0];\
        end\
        else begin\
            DATA_TYPE delayer [gv_i:0];\
            for (genvar gv_j=0; gv_j < gv_i; gv_j++)\
                `FF_RESET_EN(CLK, RESET, (EN && (delayer[gv_j].enable || delayer[gv_j+1].enable)), delayer[gv_j], delayer[gv_j+1], '0)\
                assign delayer[0] = ARRAY_DATA_I[gv_i];\
                assign ARRAY_DATA_O[gv_i] = delayer[gv_i];\
        end\
    end

    `define REVERSE_DELAY_ARRAY_CG(CLK, RESET, EN, DATA_TYPE, SIZE, ARRAY_DATA_I, ARRAY_DATA_O) \
    logic [$bits(ARRAY_DATA_I[0])-1:0] reversed [SIZE-1:0];\
    for (genvar gv_r=0; gv_r < SIZE; gv_r++) begin\
        assign reversed[gv_r] = ARRAY_DATA_I[(SIZE-1)-gv_r];\
    end\
    DATA_TYPE delayed [SIZE-1:0];\
    for (genvar gv_r=0; gv_r < SIZE; gv_r++) begin\
        assign ARRAY_DATA_O[gv_r] = delayed[(SIZE-1)-gv_r];\
    end\
    `DELAY_ARRAY_CG(CLK, RESET, EN, DATA_TYPE, SIZE, reversed, delayed)
    //`DELAY_ARRAY(CLK, RESET, EN, SIZE, reversed, delayed)

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


    `define TRANSPOSE_ARRAY(CLK, RST, EN, SIZE, LAST, IN, OUT)\
    generate begin :TRANSPOSE_ARRAY\
        \
        logic[$clog2(SIZE)-1:0] counter, counter_next;\
        \
        `FF_RESET_EN(CLK, RST, EN, counter_next, counter, '0);\
        \
        assign counter_next = EN? ((counter == SIZE-1)? '0 :  counter+1) : '0;\
        \
        for(genvar gv_row = 0; gv_row < SIZE; ++gv_row) begin :TRANSPOSE_ROW\
            matrix_data_t [$size(IN)-1:1] ff_out;\
            matrix_data_t [$size(IN)-1:0] intercon;\
            \
            for(genvar gv_i=1; gv_i < $size(IN); ++gv_i) begin\
                `FF_RESET_EN(CLK, RST, (intercon[gv_i].enable || ff_out[gv_i].enable), intercon[gv_i], ff_out[gv_i], '0);\
            end\
            \
            for(genvar gv_i=0; gv_i < $size(IN)-1; ++gv_i) begin\
                if(gv_i != gv_row) begin\
                    assign intercon[gv_i].data = (EN && (counter == gv_row))? IN[gv_i].data : ff_out[gv_i+1].data;\
                    assign intercon[gv_i].enable = (EN && (counter == gv_row))? IN[gv_i].enable : ff_out[gv_i+1].enable;\
                    assign intercon[gv_i].last = (EN && (counter == gv_row))? 1'b0 : ff_out[gv_i+1].last;\
                end\
                else begin\
                    assign intercon[gv_i].data = (EN && (counter == gv_row))? IN[gv_i].data : ff_out[gv_i+1].data;\
                    assign intercon[gv_i].enable = (EN && (counter == gv_row))? IN[gv_i].enable : ff_out[gv_i+1].enable;\
                    assign intercon[gv_i].last = LAST;\
                end\
            end\
            \
            assign intercon[$size(IN)-1] = (EN && (counter == gv_row))? IN[$size(IN)-1] : '0;\
            assign OUT[gv_row] = intercon[0];\
        end\
    end\
    endgenerate

`endif
