`include "common.svh"
`include "common_pkg.sv"
import common_pkg::*;

module pe_checker(
    input  logic         clk_i,
    input  logic         rst_i,
    input  matrix_data_t a_data_i,     
    input  matrix_data_t b_data_i,     
    input  matrix_data_t a_data_o,
    input  matrix_data_t b_data_o,
    input  drain_data_t  drain_o
    );

    import "DPI-C" function integer add (input integer a, input integer b);

        always @(posedge clk_i) begin
            if(!reset)  add(a_data_i.data, b_data_i.data);
        end

endmodule
