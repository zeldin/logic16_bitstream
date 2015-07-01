`timescale 1ns / 1ps

module normal_clock_domain(
    input clk,
    input rst,
    output miso,
    input mosi,
    input ss,
    input sclk,
    output led_out
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


   localparam VERSION = 8'h10;

   // Registers

   localparam REG_VERSION = 'h00;
   localparam REG_STATUS_CONTROL = 'h01;
   localparam REG_CHANNEL_SELECT_LOW = 'h02;
   localparam REG_CHANNEL_SELECT_HIGH = 'h03;
   localparam REG_SAMPLE_RATE_DIVISOR = 'h04;
   localparam REG_LED_BRIGHTNESS = 'h05;
   localparam REG_PRIMER_DATA1 = 'h06;
   localparam REG_PRIMER_CONTROL = 'h07;
   localparam REG_MODE = 'h0a;
   localparam REG_PRIMER_DATA2 = 'h0c;
   localparam REG_SCRATCHPAD = 'h0d;

   reg [7:0]  scratchpad_d, scratchpad_q;
   reg [7:0]  led_brightness_d, led_brightness_q;

   always @(*) begin

      scratchpad_d = scratchpad_q;
      led_brightness_d = led_brightness_q;

      case (reg_num)
	REG_VERSION: reg_data_read = VERSION;
	REG_LED_BRIGHTNESS: begin
	   reg_data_read = led_brightness_q;
	   if (reg_write) led_brightness_d = reg_data_write;
	end
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
	 led_brightness_q <= 8'h00;
      end else begin
	 scratchpad_q <= scratchpad_d;
	 led_brightness_q <= led_brightness_d;
      end
   end


   // LED

   wire led_pwm_out;

   pwm #(18, 8) led_pwm(.clk(clk), .rst(rst), .pulse_width(led_brightness_q),
			.out(led_pwm_out));

   assign led_out = ~led_pwm_out;

endmodule
