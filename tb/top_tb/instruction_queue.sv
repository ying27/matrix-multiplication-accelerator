`timescale 1ps/1ps
`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

`ifndef TIMEOUT
    `define TIMEOUT 100
`endif

module instruction_queue(
    input               clk,
    input               reset,
    output instruction_t  inst,
    output              valid,
    input               ready
    );

    integer file;
    initial begin
        file = $fopen("code.s", "r");
    end

    integer count;

    string tmp_opcode;
    addr_t tmp_src1;
    addr_t tmp_src2;
    addr_t tmp_dest;

    always_ff @(posedge clk) begin
        if(ready || !valid) begin
            if($feof(file)) begin
                $display("Input ended");
                $finish;
            end
            else begin
                count <= $fscanf(file, "%b", valid);
                count <= $fscanf(file, "%s", tmp_opcode);
                count <= $fscanf(file, "%x", tmp_dest);
                count <= $fscanf(file, "%x", tmp_src1);
                count <= $fscanf(file, "%x", tmp_src2);
            end
        end
    end
    assign inst.op = (tmp_opcode == "mmul_d")? MMUL_D : MMUL_ND;
    assign inst.src1 = tmp_src1;
    assign inst.src2 = tmp_src2;
    assign inst.dest = tmp_dest;

endmodule
