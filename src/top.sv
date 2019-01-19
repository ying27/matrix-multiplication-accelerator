//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Top level of the accelerator                                  //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    REVISION:       0.1 - PE supporting only Multiply–accumulate operations       //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;


module top(
    input  logic         clk_i,
    input  logic         rst_i,
    //Input to the chip
    input  instruction_t inst_i,
    input  logic         inst_valid_i,
    output logic         inst_ready_o
    );

    logic enable;
    systolic_feed_t sys_input;
    data_t [SYS_ARRAY_SIZE-1:0] sys_output;
    ctrl_signals_t ctrl_signals;
    data_wire_t port_a;
    data_wire_t port_b;
    data_wire_t port_c;

    dualport_ram ram(
        .clk_i      ( clk_i         ),
        .addr_a_i   ( port_a.addr   ),
        .en_a_i     ( port_a.en     ),
        .rdata_a_o  ( port_a.row    ),
        .addr_b_i   ( port_b.addr   ),
        .en_b_i     ( port_b.en     ),
        .rdata_b_o  ( port_b.row    ),
        .addr_c_i   ( port_c.addr   ),
        .we_c_i     ( port_c.en     ),
        .wdata_c_i  ( port_c.row    )
        );

    rdata_handler read_handler(
        .clk_i      ( clk_i                     ),
        .rst_i      ( rst_i                     ),

        //Signals from control
        .valid_i    ( ctrl_signals.fetch.valid  ), 
        .addr_a_i   ( ctrl_signals.fetch.src1   ),
        .addr_b_i   ( ctrl_signals.fetch.src2   ),
        .we_i       ( ctrl_signals.fetch.drain  ),

        //Signals to RAM
        .en_a_o     ( port_a.en                 ),
        .addr_a_o   ( port_a.addr               ),
        .rdata_a_i  ( port_a.row                ),
        .en_b_o     ( port_b.en                 ),
        .addr_b_o   ( port_b.addr               ),
        .rdata_b_i  ( port_b.row                ),

        //Signals to systolic
        .a_o        ( sys_input.a               ),
        .b_o        ( sys_input.b               ),
        .last_o     ( sys_input.last            ),
        .en_o       ( enable                    )

        );

    wdata_handler write_handler(
        .clk_i      ( clk_i                     ),
        .rst_i      ( rst_i                     ),

        //Signals from control
        .valid_i    ( ctrl_signals.commit.valid ),
        .addr_c_i   ( ctrl_signals.commit.dest  ),

        //Signals to RAM
        .en_c_o     ( port_c.en                 ),
        .addr_c_o   ( port_c.addr               ),
        .wdata_c_o  ( port_c.row                ),

        //Signals from systolic
        .c_i        ( sys_output                )
        ); 

    systolic_array_wrap systolic(
        .clk_i     ( clk_i                     ),
        .en_i      ( enable                    ),
        .rst_i     ( rst_i                     ),

        //Input data
        .last_i    ( sys_input.last            ),
        .a         ( sys_input.a               ),
        .b         ( sys_input.b               ),

        //Output
        .c         ( sys_output                )
        );

    control ctrl(
        .clk_i          ( clk_i                     ),
        .rst_i          ( rst_i                     ),

        //Input from instruction queue
        .inst_i         ( inst_i                    ),
        .inst_valid_i   ( inst_valid_i              ),
        .inst_ready_o   ( inst_ready_o              ),

        //Output of control
        .ctrl_signals   ( ctrl_signals              )
        );

endmodule
