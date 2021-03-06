
`timescale 1ps/1ps
`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

`ifndef TIMEOUT
    `define TIMEOUT 100
`endif

module array_wrap_tb (
    input clk,
    input reset
    );


    //Variable initialization
    logic last, read_last;

    data_t [SYS_ARRAY_SIZE-1:0] a, b;

    /* verilator lint_off UNUSED */
    data_t [SYS_ARRAY_SIZE-1:0] c;
    integer file, count;

    integer read_a[SYS_ARRAY_SIZE-1:0];
    integer read_b[SYS_ARRAY_SIZE-1:0];
    int i;
    /* verilator lint_on UNUSED */

    initial begin
        file = $fopen("transactions.txt", "r");
    end

    always_ff @(posedge clk) begin
        if(!reset) begin

            for(i = 0; i < SYS_ARRAY_SIZE; ++i) begin
                count <= $fscanf(file, "%d", read_a[i]);
                a[i] <= read_a[i][$bits(a[i]) -1:0];
            end

            for(i = 0; i < SYS_ARRAY_SIZE; ++i) begin
                count <= $fscanf(file, "%d", read_b[i]);
                b[i] <= read_b[i][$bits(b[i]) -1:0];
            end

            count <= $fscanf(file, "%b", read_last);
            last <= read_last;

            if($feof(file)) begin
                $display("Input ended");
                $finish;
            end 
        end

    end

    systolic_array_wrap dut(
        .clk_i  ( clk   ),
        .rst_i  ( reset ),
        .last_i ( last  ),
        .a      ( a     ),
        .b      ( b     ),
        .c      ( c     )
        );

endmodule
