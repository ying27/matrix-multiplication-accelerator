//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//    TITLE:          Read Data Handler Unit                                        //
//                                                                                  //
//    PROJECT:        Processor Design (PD) - MIRI UPC                              //
//                                                                                  //
//    AUTHORS:        Ying hao Xu - yinghao.xu27@gmail.com                          //
//                    Jordi Solà  - jsmont.sol@gmail.com                            //
//                                                                                  //
//    DESCRIPTION:    This Unit handles read accesses. Generates the correct        //
//                    addresses and feeds the Systolic Array at the correct pace.   //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

`include "common_pkg.sv"
`include "common.svh"
import common_pkg::*;

module rdata_handler (
    // General signals
    input  logic                       clk_i,
    input  logic                       rst_i,

    // Coming from controller signals
    input  logic                       valid_i,
    input  logic  [ADDR_WIDTH-1:0]     addr_a_i,
    input  logic  [ADDR_WIDTH-1:0]     addr_b_i,
    input  logic                       we_i,

    // Going to Systolic Array signals
    output data_t [SYS_ARRAY_SIZE-1:0] a_o,
    output data_t [SYS_ARRAY_SIZE-1:0] b_o,
    output                             last_o,
    output logic                       en_o,

    // Memory interface signals
    output logic                       en_a_o,
    output logic [ADDR_WIDTH-1:0]      addr_a_o,
    input  logic [ROW_BITS-1:0]        rdata_a_i,

    output logic                       en_b_o,
    output logic [ADDR_WIDTH-1:0]      addr_b_o,
    input  logic [ROW_BITS-1:0]        rdata_b_i
);


    // Flip-flops storing the read memory addresses
    logic [ADDR_WIDTH-1:0] addr_a_n, addr_a_c;
    logic [ADDR_WIDTH-1:0] addr_b_n, addr_b_c;
    `FF_RESET(clk_i, rst_i, addr_a_n, addr_a_c, '0);
    `FF_RESET(clk_i, rst_i, addr_b_n, addr_b_c, '0);

    //////////////////////////////////////////////////////
    // Moore FSM
    //////////////////////////////////////////////////////
    typedef enum {IDLE, READ, READ_LAST, LAST} state;
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
                if (valid_i == 1'b1) begin
                    next = (we_i == 1'b1) ? READ_LAST : READ;
                end
                else begin
                    next = IDLE;
                end
            end

            READ: begin
                next = (ncount_c == 1) ? IDLE : READ;
            end

            READ_LAST: begin
                next = (ncount_c == 2) ? LAST : READ_LAST;
            end

            LAST: begin
                next = IDLE;
            end

        endcase
    end

    //Unified Memory Enable
    logic en_mem;
    //Last signal delayer
    logic last_n, last_c;
    assign last_o = last_c;
    `FF_RESET(clk_i, rst_i, last_n, last_c, '0);
    //Valid data to accelerator delayer
    logic acc_val; 
    `FF_RESET(clk_i, rst_i, en_mem, acc_val, '0);
    //State dependant signals behaviour
    always_comb begin
        case (current)

            IDLE: begin
                last_n = 1'b0;
                en_mem = valid_i;

                if (valid_i) begin
                    ncount_n = SYS_ARRAY_SIZE-1;
                    addr_a_n = addr_a_i + ROW_BYTES;
                    addr_b_n = addr_b_i + ROW_BYTES;
                end
            end

            READ, READ_LAST: begin
                last_n = 1'b0;
                en_mem = 1'b1;
                addr_a_n = addr_a_c + ROW_BYTES;
                addr_b_n = addr_b_c + ROW_BYTES;
                ncount_n = ncount_c - 1;
            end

            LAST: begin
                last_n = 1'b1;
                en_mem = 1'b1;
                addr_a_n = addr_a_c + ROW_BYTES;
                addr_b_n = addr_b_c + ROW_BYTES;
                ncount_n = 0;
            end

        endcase
    end

    // Memory interface variables
    assign en_a_o   = en_mem;
    assign en_b_o   = en_mem;
    assign addr_a_o = (current == IDLE) ? addr_a_i : addr_a_c;
    assign addr_b_o = (current == IDLE) ? addr_b_i : addr_b_c;
    assign a_o      = (acc_val == 1'b1) ? rdata_a_i : '0; //TODO: temporal until we support smaller Ns
    assign b_o      = (acc_val == 1'b1) ? rdata_b_i : '0; //TODO: temporal until we support smaller Ns

    assign en_o = acc_val;

endmodule
