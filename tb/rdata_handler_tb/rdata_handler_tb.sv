`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

`ifndef TIMEOUT
    `define TIMEOUT 100
`endif

module rdata_handler_tb(
    input clk,
    input reset
);

    /* verilator lint_off UNDRIVEN */
    addr_t mem_addrc;
    data_t [SYS_ARRAY_SIZE-1:0] mem_c;
    logic we_c;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_off UNUSED */
    logic last;
    data_t [SYS_ARRAY_SIZE-1:0] a, b;
    /* verilator lint_on UNUSED */

    addr_t raddra, raddrb;
    logic valid, rvalid, we, rwe;
    addr_t  addra, addrb, mem_addra, mem_addrb;
    logic en_a, en_b;
    logic [ROW_BITS-1:0] mem_a, mem_b;

    rdata_handler i_rdata_handler (
        .clk_i     ( clk       ),
        .rst_i     ( reset     ),
        .valid_i   ( valid     ),
        .addr_a_i  ( addra     ),
        .addr_b_i  ( addrb     ),
        .we_i      ( we        ),
        .a_o       ( a         ),
        .b_o       ( b         ),
        .last_o    ( last      ),
        //Memory interfaces 
        .en_a_o    ( en_a      ),
        .addr_a_o  ( mem_addra ),
        .rdata_a_i ( mem_a     ),
        .en_b_o    ( en_b      ),
        .addr_b_o  ( mem_addrb ),
        .rdata_b_i ( mem_b     )
    );

    dualport_ram dp_mem_i (
        .clk_i     ( clk       ),
    
        .en_a_i    ( en_a      ),
        .addr_a_i  ( mem_addra ),
        .rdata_a_o ( mem_a     ),
    
        .en_b_i    ( en_b      ),
        .addr_b_i  ( mem_addrb ),
        .rdata_b_o ( mem_b     ),
    
        .addr_c_i  ( mem_addrc ),
        .wdata_c_i ( mem_c     ),
        .we_c_i    ( we_c      )
    );

    integer file;
    initial begin
        file = $fopen("transactions.txt", "r");
    end

    always_ff @(posedge clk) begin
        if(!reset) begin

            $fscanf(file, "%d", rvalid);
            valid <= rvalid;

            $fscanf(file, "%d", rwe);
            we    <= rwe;

            $fscanf(file, "%d", raddra);
            addra <= raddra[$bits(addra)-1 : 0];
 
            $fscanf(file, "%d", raddrb);
            addrb <= raddrb[$bits(addrb)-1 : 0];

        end
    end

    int cycle_counter;
    `FF_RESET(clk, reset, cycle_counter+1, cycle_counter, '0);

    always_comb begin
        if(cycle_counter == `TIMEOUT) $finish;
    end

endmodule
