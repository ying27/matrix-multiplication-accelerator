
`timescale 1ps/1ps
`include "common.svh"
import common_pkg::*;

module tb ();


    logic clk, rst, ctrl, last;
    logic ready;

    /*Clock Generator*/
    initial clk = 1;
    initial ready = 0;
    initial ctrl = 0;
    always
    begin
        #(50) clk = ~clk;
    end
    /****************/

    always @(posedge clk) begin
	if (ready)
            ctrl = ~ctrl;
    end

    initial begin
        rst = 1;
        @(posedge clk)
        rst = 0;
    end

    initial begin
	ctrl = 1;
        #((T_D-1)*100)ready = 1;
    end

    data_t [SYS_ARRAY_SIZE-1:0] a, b, c;
    initial begin
        last = 0;
	@(posedge clk)
        last = 0;
        b[0]=1;
        b[1]=5;
        b[2]=3;
        b[3]=8;
        a[0]=4;
        a[1]=1;
        a[2]=2;
        a[3]=3;
	@ (posedge clk)
        last = 0;
        b[0]=2;
        b[1]=6;
        b[2]=4;
        b[3]=5;
        a[0]=7;
        a[1]=8;
        a[2]=5;
        a[3]=6;
	@ (posedge clk)
        last = 0;
        b[0]=3;
        b[1]=7;
        b[2]=1;
        b[3]=6;
        a[0]=2;
        a[1]=3;
        a[2]=4;
        a[3]=1;
	@ (posedge clk)
        last = 1;
        b[0]=4;
        b[1]=8;
        b[2]=2;
        b[3]=7;
        a[0]=6;
        a[1]=7;
        a[2]=8;
        a[3]=5;
	@ (posedge clk)
        last = 0;
        b[0]=0;
        b[1]=0;
        b[2]=0;
        b[3]=0;
        a[0]=0;
        a[1]=0;
        a[2]=0;
        a[3]=0;
    end



    systolic_array_wrap dut(
        .clk_i  ( clk  ),
        .rst_i  ( rst  ),
        .ctrl_i ( ctrl ),
        .last_i ( last ),
        .a      ( a    ),
        .b      ( b    ),
        .c      ( c    )
    );

endmodule
