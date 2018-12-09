`timescale 1ps/1ps
`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

`ifndef TIMEOUT
    `define TIMEOUT 100
`endif

module top_tb (
    input clk,
    input reset
    );

    instruction_t inst;
    logic valid;
    logic ready;

    instruction_queue in_queue(
        .clk( clk ),
        .reset( reset ),
        .inst( inst ),
        .valid( valid ),
        .ready( ready )
        );

    top dut(
        .clk_i  ( clk   ),
        .rst_i  ( reset ),
        .inst_i ( inst ),
        .inst_valid_i ( valid ),
        .inst_ready_o ( ready )
        );

endmodule
