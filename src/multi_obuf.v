module multi_obuf #(
   parameter BITS = 8
)  (
    input [BITS-1:0] I,
    output [BITS-1:0] O
    );

   genvar n;
   generate
      for (n=0; n<BITS; n=n+1) begin : BITBUF
	 OBUF bit_obuf(.I(I[n]), .O(O[n]));
      end
   endgenerate

endmodule // multi_obuf
