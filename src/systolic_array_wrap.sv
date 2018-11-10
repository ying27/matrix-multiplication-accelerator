
`include "common_pkg.sv"
`include "common.svh"
import common_pkg::*;

module systolic_array_wrap (
    input  logic                       clk_i,
    input  logic                       rst_i,
    input  logic                       ctrl_i,
    input  logic                       last_i,
    input  data_t [SYS_ARRAY_SIZE-1:0] a,
    input  data_t [SYS_ARRAY_SIZE-1:0] b,
    output data_t [SYS_ARRAY_SIZE-1:0] c
);
 
    matrix_data_t [SYS_ARRAY_SIZE-1:0] m_a, m_b, d_a, d_b;
    data_t [DRAIN_CHANNEL_SIZE-1:0] drain_c;

    for (genvar m_i=0; m_i < SYS_ARRAY_SIZE; m_i++) begin
        m_a[m_i].data = a[m_i];
        m_a[m_i].last = last;
        m_b[m_i].data = b[m_i];
        m_b[m_i].last = last;
    end

    `DELAY_ARRAY(clk_i, rst_i, 1, SYS_ARRAY_SIZE, m_a, d_a)
    `DELAY_ARRAY(clk_i, rst_i, 1, SYS_ARRAY_SIZE, m_b, d_b)

    systolic_array i_systolic_array (
        .clk_i ( clk_i   ),
        .rst_i ( rst_i   ),
        .a_i   ( d_a     ),
        .b_i   ( d_b     ),
        .c_o   ( drain_c )
    );

    drain_array # (
        .SIZE(DRAIN_CHANNEL_SIZE)
    ) i_drain_array (
        .clk_i        ( clk_i   ),
        .rst_i        ( rst_i   ),
        .ctrl_i       ( ctrl_i  ),
        .array_data_i ( drain_c ),
        .array_data_o ( c       )
    );

endmodule
