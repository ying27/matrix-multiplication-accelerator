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
    logic [ROW_BITS-1:0]     rdata_a;
    logic [ROW_BITS-1:0]     rdata_b;
    logic [ROW_BITS-1:0]     wdata_c;

    initial begin
        $readmemh("random.list", mem, 0);
    end

    always @(posedge clk_i) begin

        if (we_c_i == 1'b1) begin
            mem[addr_c] <= wdata_c;
        end

        if (en_a_i) rdata_a <= mem[addr_a];
        if (en_b_i) rdata_b <= mem[addr_b];

    end

    //Fix endianness
    generate for(genvar i=0; i < ROW_BYTES; i++) begin : ENDIANNESS
        assign rdata_a_o[(8*(i+1))-1:8*i] = rdata_a[(8*(ROW_BYTES-i))-1:(8*(ROW_BYTES-i-1))];
        assign rdata_b_o[(8*(i+1))-1:8*i] = rdata_b[(8*(ROW_BYTES-i))-1:(8*(ROW_BYTES-i-1))];
        assign wdata_c[(8*(i+1))-1:8*i] = wdata_c_i[(8*(ROW_BYTES-i))-1:(8*(ROW_BYTES-i-1))];
    end
    endgenerate

endmodule
