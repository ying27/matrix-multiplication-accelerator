//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Systolic Array (PEs + Drain Channels)                         //
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

module systolic_array (
    input  logic                                  clk_i,
    input  logic                                  rst_i,

    input  matrix_data_t [SYS_ARRAY_SIZE-1:0]     a_i,
    input  matrix_data_t [SYS_ARRAY_SIZE-1:0]     b_i,

    output data_t        [DRAIN_CHANNEL_SIZE-1:0] c_o
);

    // -----------------------------
    // PE wires
    // -----------------------------
    /* verilator lint_off UNUSED */
    matrix_data_t [SYS_ARRAY_SIZE:0][SYS_ARRAY_SIZE-1:0] a_wires;
    matrix_data_t [SYS_ARRAY_SIZE:0][SYS_ARRAY_SIZE-1:0] b_wires;
    /* verilator lint_on UNUSED */

    drain_data_t  [SYS_ARRAY_SIZE-1:0][SYS_ARRAY_SIZE:0] drain_wires;
    

    // -----------------------------
    // PE Instantiation
    // -----------------------------
    assign a_wires[0] = a_i;
    assign b_wires[0] = b_i;

    for (genvar i = 0; i < SYS_ARRAY_SIZE; i = i + 1) begin : ROWS
        for (genvar j = 0; j < SYS_ARRAY_SIZE; j = j + 1) begin : COLUMNS
            pe i_pe (
                .clk_i    ( clk_i             ),
                .rst_i    ( rst_i             ),
                .a_data_i ( a_wires[j  ][i]   ),
                .b_data_i ( b_wires[i  ][j]   ),
                .a_data_o ( a_wires[j+1][i]   ),
                .b_data_o ( b_wires[i+1][j]   ),
                .drain_o  ( drain_wires[i][j] )
            );
        end
    end


    // -----------------------------
    // Drain Channel wires
    // -----------------------------
    drain_data_t [SYS_ARRAY_SIZE:0][DRAIN_CHANNEL_SIZE-1:0] drain_bus;


    // -----------------------------
    // Drain Channel Instantiation
    // -----------------------------
    for (genvar k = 0; k < DRAIN_CHANNEL_SIZE; k++) begin
        assign c_o[k] = drain_bus[0][k].data;
    end
    assign drain_bus[SYS_ARRAY_SIZE] = '0;

    for (genvar i = 0; i < SYS_ARRAY_SIZE; i = i + 1) begin : DRAIN_ROWS
        for (genvar j = 0; j < DRAIN_CHANNEL_SIZE; j = j + 1) begin : DRAIN_COLUMNS
            drain_channel i_drain_channel (
                .clk_i      ( clk_i                     ),
                .rst_i      ( rst_i                     ),
                .left_pe_i  ( drain_wires[i  ][ 2*j   ] ),
                .right_pe_i ( drain_wires[i  ][(2*j)+1] ),
                .ch_down_i  ( drain_bus  [i+1][j      ] ),
                .ch_up_o    ( drain_bus  [i  ][j      ] )
            );
        end
    end


    // Set last column of the Drain Channel to 0s for the case when
    // matrix size is not multiple of the systolic array size
    for (genvar i = 0; i < SYS_ARRAY_SIZE; i = i + 1) begin : LAST_COL
        assign drain_wires[i][SYS_ARRAY_SIZE] = '0;
    end


endmodule
