`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

`ifndef TIMEOUT
    `define TIMEOUT 100
`endif

module wdata_handler_tb(
    input clk,
    input reset
);

    integer i;

    /* verilator lint_off UNDRIVEN */
    logic en_a, en_b;
    addr_t  mem_addra, mem_addrb;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_off UNUSED */
    logic [ROW_BITS-1:0] mem_a, mem_b;
    /* verilator lint_on UNUSED */


    logic valid, rvalid;
    addr_t addrc, mem_addrc, raddrc;
    data_t [SYS_ARRAY_SIZE-1:0] c;
    logic en_c;
    integer read_c[SYS_ARRAY_SIZE-1:0];
    logic [ROW_BITS-1:0] mem_c;

    wdata_handler i_wdata_handler (
        .clk_i     ( clk       ),
        .rst_i     ( reset     ),

        .valid_i   ( valid     ),
        .addr_c_i  ( addrc     ),

        .c_i       ( c         ),

        .en_c_o    ( en_c      ),
        .addr_c_o  ( mem_addrc ),
        .wdata_c_o ( mem_c     )
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
        .we_c_i    ( en_c      )
    );

    integer file;
    initial begin
        file = $fopen("transactions.txt", "r");
    end

    always_ff @(posedge clk) begin
        if(!reset) begin

            $fscanf(file, "%d", rvalid);
            valid <= rvalid;

            $fscanf(file, "%d", raddrc);
            addrc <= raddrc[$bits(addrc)-1 : 0];
 
            for(i = 0; i < SYS_ARRAY_SIZE; ++i) begin
                $fscanf(file, "%d", read_c[i]);
                c[i] <= read_c[i][$bits(c[i])-1 : 0];
            end

        end
    end

    int cycle_counter;
    `FF_RESET(clk, reset, cycle_counter+1, cycle_counter, '0);

    always_comb begin
        if(cycle_counter == `TIMEOUT) $finish;
    end

    `FF_RESET(clk, reset, mem_addrc, mem_addra, '0);
    assign en_a = 1'b1;

endmodule
