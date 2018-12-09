//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Top level of the system control                               //
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


module control(
    input  logic            clk_i,
    input  logic            rst_i,
    //Input to the chip
    input  instruction_t    inst_i,
    input  logic            inst_valid_i,
    output logic            inst_ready_o,
    //Control signals
    output ctrl_signals_t   ctrl_signals
    );

    ctrl_signals_t decoder_sigs; //Signals out of the decoder
    ctrl_signals_t safe_decoder_sigs; //Signals after hazard control

    logic stall_decode;

    generate begin: DRAIN_HAZARD_CONTROL
        int cycles_to_drain;
        int cycles_to_drain_next;
        `FF_RESET( clk_i, rst_i, cycles_to_drain_next, cycles_to_drain, '0);

        always_comb begin
            cycles_to_drain_next = cycles_to_drain-1;
            if(cycles_to_drain == 0) cycles_to_drain_next = 0;
            if(decoder_sigs.fetch.drain == 1) cycles_to_drain_next = T_D;
        end

        assign stall_decode = (!decoder_sigs.fetch.drain && decoder_sigs.fetch.valid) || (cycles_to_drain == 0);

        //The output valids need to be updated according to the stall
        always_comb begin
            safe_decoder_sigs = decoder_sigs;

            safe_decoder_sigs.fetch.valid = decoder_sigs.fetch.valid && !stall_decode;
            safe_decoder_sigs.commit.valid = decoder_sigs.commit.valid && !stall_decode;
        end

    end
    endgenerate

    assign inst_ready_o = !stall_decode;

    decoder decoder(
        .inst_i         ( inst_i        ),
        .inst_valid_i   ( inst_valid_i  ),
        .decoder_sigs   ( decoder_sigs  )
        );

    `FF_RESET_PIPE( clk_i, rst_i, 1,        safe_decoder_sigs.fetch,    ctrl_signals.fetch,     '0);
    `FF_RESET_PIPE( clk_i, rst_i, (T_D+1),  safe_decoder_sigs.commit,   ctrl_signals.commit,    '0);

endmodule
