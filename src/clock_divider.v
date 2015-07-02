module clock_divider(
    input clk,
    input rst,
    input enable,
    input [7:0] divisor,
    output tick
);

   reg [7:0] counter_d, counter_q;
   reg 	     tick_d, tick_q;

   always @(*) begin

      if (enable) begin
	 if (counter_q == divisor) begin
	    counter_d = 8'h00;
	    tick_d = 1'b1;
	 end else begin
	    counter_d = counter_q + 1;
	    tick_d = 1'b0;
	 end
      end else begin
	 counter_d = 8'h00;
	 tick_d = 1'b0;
      end

   end

   always @(posedge clk) begin
      if (rst) begin
	 counter_q <= 8'h00;
	 tick_q <= 1'b0;
      end else begin
	 counter_q <= counter_d;
	 tick_q <= tick_d;
      end
   end

   assign tick = tick_q;

endmodule // clock_divider
