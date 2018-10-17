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

import pe_pkg::*;

module pe (
    input  logic         clk_i,
    input  logic         rst_i,
    input  matrix_data_t a_data_i,     
    input  matrix_data_t b_data_i,     
    output matrix_data_t a_data_o,
    output matrix_data_t b_data_o,
    output drain_data_t  drain_o
);

    matrix_data_t part_result_n, part_result_q;
    matrix_data_t next_a_n, next_a_q;
    matrix_data_t next_b_n, next_b_q;

    //-----------------------
    // Data Interface
    //-----------------------
    always_comb begin : data_interface
        next_a_n = a_data_i;
        next_b_n = b_data_i;
        a_data_o = next_a_q;
        b_data_o = next_b_q;
        // Drain channel
        drain_o.data   <= part_result_q.data;
        drain_o.enable <= part_result_q.last;
    end

    //-----------------------
    // Registers
    //-----------------------
    always_ff @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            next_a_q.data      <= '0;
            next_a_q.last      <= '0;
            next_b_q.data      <= '0;
            next_b_q.last      <= '0;
            part_result_q.data <= '0;
            part_result_q.last <= '0;
        end
        else begin
            // Passthrough to other PEs
            next_a_q      <= next_a_n;
            next_b_q      <= next_b_n;

            // Internal partial results
            part_result_q <= part_result_n;

        end
    end

    //-----------------------
    // MAC Operation
    //-----------------------
    always_comb begin 
        part_result_n.data = (part_result_q.data & {DATA_WIDTH{!part_result_q.last}}) + (a_data_i.data * b_data_i.data);
        part_result_n.last = (a_data_i.last && b_data_i.last);
    end

endmodule
