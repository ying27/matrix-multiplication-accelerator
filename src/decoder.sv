//////////////////////////////////////////////////////////////////////////////////////
//    TITLE:          Decoder of the accelerator                                    //
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


module decoder(
    input  instruction_t    inst_i,
    input  logic            inst_valid_i,
    output ctrl_signals_t   decoder_sigs
);

    always_comb begin
        decoder_sigs = '0;
        if(inst_valid_i) begin
            case(inst_i.op)
                //                           Instruction valid                              Enable write
                //                           |      Source 1        Source 2        Drain   |       Destination
                //                           |      |               |               |       |       |
                MMUL_D:     decoder_sigs = { `Y,    inst_i.src1,    inst_i.src2,    `Y,     `Y,     inst_i.dest };
                MMUL_ND:    decoder_sigs = { `Y,    inst_i.src1,    inst_i.src2,    `N,     `N,     inst_i.dest };
                default:    decoder_sigs = '0;
            endcase
        end
    end

endmodule
