
`include "common_pkg.sv"
`include "common.svh"
import common_pkg::*;

module systolic_array_wrap (
    input  logic                       clk_i,
    input  logic                       en_i,
    input  logic                       rst_i,
    input  logic                       last_i,
    input  data_t [SYS_ARRAY_SIZE-1:0] a,
    input  data_t [SYS_ARRAY_SIZE-1:0] b,
    output data_t [SYS_ARRAY_SIZE-1:0] c
);
    logic ctrl;
    int ctrl_counter, next_ctrl_counter;
 
    matrix_data_t [SYS_ARRAY_SIZE-1:0] m_a, m_b, d_a, d_b;
    drain_data_t [DRAIN_CHANNEL_SIZE-1:0] drain_c;

    for (genvar m_i=0; m_i < SYS_ARRAY_SIZE; m_i++) begin
        assign m_a[m_i].data   = a[m_i];
        assign m_a[m_i].last   = last_i;
        assign m_a[m_i].enable = en_i;
        assign m_b[m_i].data   = b[m_i];
        assign m_b[m_i].last   = last_i;
        assign m_b[m_i].enable = en_i;
    end

    `TRANSPOSE_ARRAY(clk_i, rst_i, m_a[0].enable, SYS_ARRAY_SIZE, last_i, m_a, d_a)
    `DELAY_ARRAY_CG(clk_i, rst_i, 1'b1, matrix_data_t, SYS_ARRAY_SIZE, m_b, d_b)

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
        .ctrl_i       ( ctrl    ),
        .array_data_i ( drain_c ),
        .array_data_o ( c       )
    );



    //////////////////////////////////////////////////////////
    // ctrl signal generator
    //////////////////////////////////////////////////////////

    assign ctrl = ctrl_counter[0];
    logic  ctrl_en;
    assign ctrl_en = (last_i || (ctrl_counter != 0));
    `FF_RESET_EN(clk_i, rst_i, ctrl_en, next_ctrl_counter, ctrl_counter, '0)

    always_comb begin
        next_ctrl_counter = ctrl_counter > 0 ? ctrl_counter - 1: 0;
        if (last_i) begin
            next_ctrl_counter = (2*SYS_ARRAY_SIZE) + 4; //+2: for 2 cycles less
        end                                             //+4: to leave the drain array with 0s
    end

endmodule
