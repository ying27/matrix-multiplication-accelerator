//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Processing Element (PE) of the Systolic Array                 //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    REVISION:       0.1 - PE supporting only Multiply–accumulate operations       //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;


module pe (
    input  logic         clk_i,
    input  logic         rst_i,
    input  matrix_data_t a_data_i,     
    input  matrix_data_t b_data_i,     
    output matrix_data_t a_data_o,
    output matrix_data_t b_data_o,
    output drain_data_t  drain_o
);
    //-----------------------------
    // Delay clock gate by 1 cycle
    //-----------------------------
    logic ab_data_en_n, ab_data_en_c, data_en_n;
    assign ab_data_en_n = (a_data_i.enable && b_data_i.enable);
    assign ab_data_en_c = (a_data_o.enable && b_data_o.enable);
    assign data_en_n = ab_data_en_n || ab_data_en_c;

    //-----------------------
    // Data Passthrough
    //-----------------------
    `FF_RESET_EN(clk_i, rst_i, data_en_n, a_data_i, a_data_o, '0)
    `FF_RESET_EN(clk_i, rst_i, data_en_n, b_data_i, b_data_o, '0)

    //-----------------------
    // Internal registers
    //-----------------------
    data_t result_n, result_q;
    `FF_RESET_EN(clk_i, rst_i, data_en_n, result_n, result_q, '0)

    logic emit_n, emit_q;
    `FF_RESET_EN(clk_i, rst_i, (emit_n || emit_q), emit_n, emit_q, '0) //Emit FF

    always_comb begin : MAC_OPERATION
        result_n = (result_q & {DATA_WIDTH{!emit_q}}) + (a_data_i.data * b_data_i.data);
        emit_n   = (a_data_i.last && b_data_i.last);
    end

    always_comb begin : DRAIN_CHANNEL
        drain_o.data   = result_q;
        drain_o.enable = emit_q;
    end

endmodule
