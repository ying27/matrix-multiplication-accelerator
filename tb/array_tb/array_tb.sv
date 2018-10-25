`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;


    `ifndef TIMEOUT
        `define TIMEOUT 100
    `endif

module array_tb(
    input clk,
    input reset
    );

    /* verilator lint_off UNUSED */
    matrix_data_t [SYS_ARRAY_SIZE-1:0]     a_i;
    matrix_data_t [SYS_ARRAY_SIZE-1:0]     b_i;

    data_t        [DRAIN_CHANNEL_SIZE-1:0] c_o;
    /* verilator lint_on UNUSED */

    initial begin
        a_i = '0;
        b_i = '0;
    end

    systolic_array systolic_array(
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
