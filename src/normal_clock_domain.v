`timescale 1ns / 1ps

module normal_clock_domain(
    input clk,
    input rst,
    output miso,
    input mosi,
    input ss,
    input sclk
);

   wire [6:0] reg_num;
   wire reg_write;
   reg  [7:0] reg_data_read;
   wire [7:0] reg_data_write;

   regaccess reg_file
     (
      .clk(clk),
      .rst(rst),
      .ss(ss),
      .mosi(mosi),
      .miso(miso),
      .sck(sclk),
      .regnum(reg_num),
      .regdata_read(reg_data_read),
      .regdata_write(reg_data_write),
      .read(),
      .write(reg_write)
      );


   localparam VERSION = 8'h17;

   // Registers

   localparam REG_VERSION = 0;
   localparam REG_SCRATCHPAD = 1;

   reg [7:0]  scratchpad_d, scratchpad_q;

   always @(*) begin

      scratchpad_d = scratchpad_q;

      case (reg_num)
	REG_VERSION: reg_data_read = VERSION;
	REG_SCRATCHPAD: begin
	   reg_data_read = scratchpad_q;
	   if (reg_write) scratchpad_d = reg_data_write;
	end
	default: reg_data_read = 8'b00000000;
      endcase

   end

   always @(posedge clk) begin
      if (rst) begin
	 scratchpad_q <= 8'h73;
      end else begin
	 scratchpad_q <= scratchpad_d;
      end
   end

endmodule
