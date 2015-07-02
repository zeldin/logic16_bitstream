module synchronizer #(
   parameter BITS = 1
)  (
    input clk,
    input [BITS-1:0] in,
    output [BITS-1:0] out
    );

   reg [BITS-1:0]     stage1, stage2;

   always @(posedge clk) begin
      stage1 <= in;
      stage2 <= stage1;
   end

   assign out = stage2;

endmodule // synchronizer
