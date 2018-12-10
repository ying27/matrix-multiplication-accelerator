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

    logic [500:1] tmp_opcode;
    addr_t tmp_src1;
    addr_t tmp_src2;
    addr_t tmp_dest;

    logic finish_sequence=0;
    int finish_counter;
    `FF_RESET_EN( clk, reset, finish_sequence, finish_counter-1, finish_counter, 2*T_D);
    always_comb if(reset == 0 && finish_counter == 0) $finish;

    always_ff @(posedge clk) begin
        if(ready || !valid) begin
            if($feof(file)) begin
                if(!finish_sequence) $display("Input ended");
                finish_sequence<=1;
            end
            else begin
                count = $fscanf(file, "%b %s %x %x %x\n", valid, tmp_opcode, tmp_dest, tmp_src1, tmp_src2);
            end
        end
    end
    /* verilator lint_off WIDTH */
    assign inst.op = (tmp_opcode == "mmul_d")? MMUL_D : MMUL_ND;
    /* verilator lint_on WIDTH */
    assign inst.src1 = tmp_src1;
    assign inst.src2 = tmp_src2;
    assign inst.dest = tmp_dest;

    always_ff @(posedge clk) begin
        if(valid && ready) begin
            $display("Instruction: 0x%x", inst);
            $display("Opcode: %0s Dest: %x Src1: %x Src2: %x\n", tmp_opcode, tmp_dest, tmp_src1, tmp_src2);
        end
    end
endmodule
