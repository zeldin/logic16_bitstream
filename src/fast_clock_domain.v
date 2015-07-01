module fast_clock_domain(
    input clk,
    input rst,
    input [15:0] probe,
    output [15:0] sample_data,
    output sample_data_avail
);

   assign sample_data = 16'h0000;
   assign sample_data_avail = 1'b0;

endmodule // fast_clock_domain
