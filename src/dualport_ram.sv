//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Dual port RAM                                                 //
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

module dualport_ram (
    input  logic                    clk_i,

    /* verilator lint_off UNUSED */
    input  logic [ADDR_WIDTH-1:0]   addr_a_i,
    input  logic [ADDR_WIDTH-1:0]   addr_b_i,
    input  logic [ADDR_WIDTH-1:0]   addr_c_i,
    /* verilator lint_on UNUSED */

    input  logic                    en_a_i,
    output logic [ROW_BITS-1:0]     rdata_a_o,

    input  logic                    en_b_i,
    output logic [ROW_BITS-1:0]     rdata_b_o,

    input  logic [ROW_BITS-1:0]     wdata_c_i,
    input  logic                    we_c_i
);

    localparam lines = (2**ADDR_WIDTH)/ROW_BYTES;
    localparam lwidth = $clog2(ROW_BYTES);

    logic [ROW_BITS-1:0] mem [lines-1:0];
    logic [ADDR_WIDTH-1-lwidth:0] addr_a = addr_a_i[ADDR_WIDTH-1:lwidth];
    logic [ADDR_WIDTH-1-lwidth:0] addr_b = addr_b_i[ADDR_WIDTH-1:lwidth];
    logic [ADDR_WIDTH-1-lwidth:0] addr_c = addr_c_i[ADDR_WIDTH-1:lwidth];

    initial begin
        $readmemh("random.list", mem, 0);
    end

    always @(posedge clk_i) begin

        if (we_c_i == 1'b1) begin
            mem[addr_c] <= wdata_c_i;
        end

        if (en_a_i) rdata_a_o <= mem[addr_a];
        if (en_b_i) rdata_b_o <= mem[addr_b];

    end

endmodule
