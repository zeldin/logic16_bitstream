module serial_to_parallel(
    input clk,
    input rst,
    input tick,
    input enable,
    input in,
    output [15:0] out,
    output ready
);

   reg [16:0] shiftreg_d, shiftreg_q;

   always @(*) begin

      if (enable) begin

	 shiftreg_d = shiftreg_q;

	 if (tick) begin
	    if (ready) begin
	       shiftreg_d = {16'h0001, in};
	    end else begin
	       shiftreg_d = {shiftreg_q[15:0], in};
	    end
	 end else if (ready) begin
	    shiftreg_d = 17'h00001;
	 end

      end else begin

	 shiftreg_d = 17'h00001;

      end

   end

   always @(posedge clk) begin
      if (rst) begin
	 shiftreg_q <= 17'h00001;
      end else begin
	 shiftreg_q <= shiftreg_d;
      end
   end

   assign out = shiftreg_q[15:0];
   assign ready = shiftreg_q[16];

endmodule // serial_to_parallel
