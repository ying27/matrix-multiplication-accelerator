//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Drain Array module                                            //
//                                                                                  //
//    DESCRIPTION:    This module collects the data from the drain channel and      //
//                    delays the results in order to increase the memory access     //
//                    granularity to a full matrix row.                             //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

module drain_array # (
    parameter SIZE = 2
)(
    input                              clk_i,
    input                              rst_i,
    input                              ctrl_i,
    input  data_t           [SIZE-1:0] array_data_i,
    output data_t [SYS_ARRAY_SIZE-1:0] array_data_o
);

    typedef struct packed {
        data_t l;
        data_t r;
    }  pair_data_t;

    pair_data_t drain_pairs_i [SIZE-1:0];
    pair_data_t drain_pairs_o [SIZE-1:0];
    for (genvar gv_z=0; gv_z < SIZE; gv_z++) begin
        `FF_RESET_EN(clk_i, rst_i,  ctrl_i, array_data_i[gv_z], drain_pairs_i[gv_z].l, '0)
        if (gv_z == SIZE-1) begin
            //For the last element, we do not have to store it into a FF
            assign drain_pairs_i[gv_z].r = array_data_i[gv_z];
        end
        else begin
            `FF_RESET_EN(clk_i, rst_i, ~ctrl_i, array_data_i[gv_z], drain_pairs_i[gv_z].r, '0)
        end
    end

    `REVERSE_DELAY_ARRAY(clk_i, rst_i, ctrl_i, SIZE, drain_pairs_i, drain_pairs_o)

    for (genvar gv_z=0; gv_z < SIZE; gv_z++) begin
        assign array_data_o[ 2*gv_z   ] = drain_pairs_o[gv_z].l;
        if ((2*gv_z) < (SYS_ARRAY_SIZE-1)) begin
            assign array_data_o[(2*gv_z)+1] = drain_pairs_o[gv_z].r;
        end
    end

endmodule
