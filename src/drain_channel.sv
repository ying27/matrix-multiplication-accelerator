//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Drain Channel shareed between two PEs                         //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`include "common_pkg.sv"
`include "common.svh"
import common_pkg::*;

module drain_channel(
    input  logic        clk_i,
    input  logic        rst_i,

    input  drain_data_t left_pe_i,
    input  drain_data_t right_pe_i,

    input  data_t       ch_down_i,
    output data_t       ch_up_o
);

    data_t data_pipe_n, data_pipe_q;

    `FF_RESET(clk_i, rst_i, data_pipe_n, data_pipe_q, '0)

    always_comb begin
        if ((left_pe_i.enable || right_pe_i.enable) == 1'b0) begin
            data_pipe_n = ch_down_i;
        end
        else begin
            if (left_pe_i.enable == 1'b1) begin
                data_pipe_n = left_pe_i.data;
            end
            else begin
                data_pipe_n = right_pe_i.data;
            end
        end
    end

    assign ch_up_o = data_pipe_q;

endmodule
