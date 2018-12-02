//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Write Data Handler Unit                                       //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    DESCRIPTION:    This Unit handles write accesses. Data comes from the         //
//                    Systolic Array and is written to the memory.                  //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`include "common_pkg.sv"
`include "common.svh"
import common_pkg::*;

module wdata_handler (
    // General signals
    input  logic                       clk_i,
    input  logic                       rst_i,

    // Coming from rdata handler signals
    input  logic                       valid_i,
    input  logic  [ADDR_WIDTH-1:0]     addr_c_i,

    // Coming from the Systolic Array
    input  data_t [SYS_ARRAY_SIZE-1:0] c_i,

    // Memory interface signals
    output  logic                      en_c_o,
    output  logic [ADDR_WIDTH-1:0]     addr_c_o,
    output  logic [ROW_BITS-1:0]       wdata_c_o
);

    // Logic to store the C address
    logic [ADDR_WIDTH-1:0] addr_c_n, addr_c_c;
    `FF_RESET(clk_i, rst_i, addr_c_n, addr_c_c, '0);

    //////////////////////////////////////////////////////
    // Moore FSM
    //////////////////////////////////////////////////////
    typedef enum {IDLE, WRITE} state;
    state current, next;

    //State is changed at posedge
    `FF_RESET(clk_i, rst_i, next, current, IDLE)

    //Count accesses
    countn_t ncount_n, ncount_c;
    `FF_RESET(clk_i, rst_i, ncount_n, ncount_c, '0);
    //Logic to decide the next state
    always_comb begin
        case (current)

            IDLE: begin
                next = (valid_i == 1'b1) ? WRITE : IDLE;
            end

            WRITE: begin
                next = (ncount_c == 1) ?  IDLE : WRITE;
            end

        endcase
    end

    //State dependant signals behaviour
    always_comb begin
        case (current)

            IDLE: begin
                en_c_o = valid_i;
                if (valid_i) begin
                    ncount_n = SYS_ARRAY_SIZE-1;
                    addr_c_n = addr_c_i + ROW_BYTES;
                end
            end

            WRITE: begin
                en_c_o = 1'b1;
                ncount_n = ncount_c - 1;
                addr_c_n = addr_c_c + ROW_BYTES;
            end

        endcase
    end

    // Memory interface variables
    assign addr_c_o  = (current == IDLE) ? addr_c_i : addr_c_c;
    assign wdata_c_o = c_i;

endmodule
