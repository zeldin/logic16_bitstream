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

	 reg [15:0] latch_d, latch_q;
	 reg 	    valid_d, valid_q;
	 wire [15:0] latch_chain;
	 wire 	     valid_chain;

	 always @(*) begin
	    if(acq_enable) begin
	       if (chandata_parallel_ready) begin
		  latch_d = chandata_parallel;
		  valid_d = 1'b1;
	       end else begin
		  latch_d = latch_chain;
		  valid_d = valid_chain;
	       end
	    end else begin
	       latch_d = 16'h0000;
	       valid_d = 1'b0;
	    end
	 end

	 always @(posedge clk) begin
	    if (rst) begin
	       latch_q <= 16'h0000;
	       valid_q <= 1'b0;
	    end else begin
	       latch_q <= latch_d;
	       valid_q <= valid_d;
	    end
	 end

      end
   endgenerate

   generate
      for (i=1; i<16; i=i+1) begin : CHAINING
	 assign CHANNEL[i-1].latch_chain = CHANNEL[i].latch_q;
	 assign CHANNEL[i-1].valid_chain = CHANNEL[i].valid_q;
      end
   endgenerate
   assign CHANNEL[15].latch_chain = 16'h0000;
   assign CHANNEL[15].valid_chain = 1'b0;

   assign sample_data = CHANNEL[0].latch_q;
   assign sample_data_avail = CHANNEL[0].valid_q;

endmodule // fast_clock_domain
