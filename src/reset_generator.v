module reset_generator(
    input clk,
    output rst
);

   reg 	   rst1 = 1'b1, rst2 = 1'b1;
   assign  rst = rst2;

   always @(posedge clk) begin
      rst1 <= 1'b0;
      rst2 <= rst1;
   end

endmodule // reset_generator
