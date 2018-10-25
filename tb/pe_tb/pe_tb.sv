`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;


    `ifndef TIMEOUT
        `define TIMEOUT 100
    `endif

module pe_tb(
    input clk,
    input reset
    );

    matrix_data_t a_data_i;     
    matrix_data_t b_data_i;     

    /* verilator lint_off UNUSED */
    matrix_data_t a_data_o;
    matrix_data_t b_data_o;
    drain_data_t  drain_o;
    /* verilator lint_on UNUSED */

    initial begin
        a_data_i = '0;
        b_data_i = '0;
    end

    pe pe(
        .clk_i(clk),
        .rst_i(reset),
        .*
    );

    
    int cycle_counter;
    `FF_RESET(clk, reset, cycle_counter+1, cycle_counter, '0);

    always_comb begin
        if(cycle_counter == `TIMEOUT) $finish;
    end

endmodule
