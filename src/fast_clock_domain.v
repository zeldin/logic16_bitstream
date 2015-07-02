module fast_clock_domain(
    input clk,
    input rst,
    input [15:0] probe,
    output [15:0] sample_data,
    output sample_data_avail,
    input acq_enable,
    input [7:0] clock_divisor,
    input [15:0] channel_enable
);

   wire sample_tick;

   clock_divider ckd(clk, rst, acq_enable, clock_divisor, sample_tick);

   genvar i;
   generate
      for (i=0; i<16; i=i+1) begin : CHANNEL

	 wire probe_synced;
	 wire [15:0] chandata_parallel;
	 wire chandata_parallel_ready;

	 synchronizer probe_sync(clk, probe[i], probe_synced);

	 serial_to_parallel s2p(.clk(clk), .rst(rst), .tick(sample_tick),
				.enable(acq_enable & channel_enable[i]),
				.in(probe_synced), .out(chandata_parallel),
				.ready(chandata_parallel_ready));

      end
   endgenerate

   assign sample_data = 16'h0000;
   assign sample_data_avail = 1'b0;

endmodule // fast_clock_domain
