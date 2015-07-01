module pwm #(
   parameter COUNTER_BITS = 32, PW_BITS = 8
)  (
    input clk,
    input rst,
    input [0:PW_BITS-1] pulse_width,
    output out
    );

   reg [0:COUNTER_BITS-1] counter_f;
   reg 	      state;

   always @(posedge clk) begin
      if (rst) begin
	 counter_f <= 0;
      end else begin
	 counter_f <= counter_f + 1;
      end

      if (rst) begin
	 state <= 0;
      end else if (counter_f[0:PW_BITS-1] == pulse_width
		   && ~pulse_width != 0) begin
	 state <= 0;
      end else if (counter_f == 0) begin
	 state <= 1;
      end
   end // always @ (posedge clk)

   assign out = state;

endmodule // pwm
