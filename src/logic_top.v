`timescale 1ns / 1ps

module logic_top(
    input CLKIN48,
    input IFCLK,
    output LED,
    output MISO,
    input MOSI,
    input SS,
    input SCLK,
    output [7:0] PORT_B,
    output [7:0] PORT_D,
    output RDY0,
    input CTL0,
    input [15:0] PROBE
);

wire clksel, clkgen_rst; // async
wire fastclk, normalclk, ifclk_int;

wire fifo_valid_out;        // ifclk
wire [15:0] fifo_data_out;  // - " -

IBUFG clk48_ibuf(.I(CLKIN48), .O(normalclk));

OBUF fifo_valid_buf(.I(fifo_valid_out), .O(RDY0));
multi_obuf #(16) fifo_data_buf(.I(fifo_data_out), .O({PORT_D, PORT_B}));

clock_generators clkgen (.clk48(normalclk), .IFCLK(IFCLK),
			 .clkgen_rst(clkgen_rst),
			 .clksel(clksel), .fastclk(fastclk),
			 .ifclk_out(ifclk_int), .clocks_locked());

wire fifo_reset; // async

wire [15:0] sample_data;  // fast clock domain
wire sample_data_avail;   // - " -
wire fifo_overflow;       // - " -
wire fcd_rst;             // - " -

wire ncd_rst;             // normal clock domain

fifo_generator_v9_3 fifo(.rst(fifo_reset), .wr_clk(fastclk), .rd_clk(ifclk_int),
                         .din(sample_data), .wr_en(sample_data_avail),
                         .rd_en(~CTL0), .dout(fifo_data_out),
                         .full(), .overflow(fifo_overflow),
                         .empty(), .valid(fifo_valid_out));

// normal clock domain -> fast clock domain
wire acq_enable_ncd, acq_enable_fcd;
wire acq_reset_ncd, acq_reset_fcd;
wire [7:0] clkdiv_ncd, clkdiv_fcd;
wire [15:0] channel_enable_ncd, channel_enable_fcd;

// fast clock domain -> normal clock domain
wire acq_stalled_fcd, acq_stalled_ncd;

normal_clock_domain ncd(.clk(normalclk), .rst(ncd_rst), .miso(MISO),
			.mosi(MOSI), .ss(SS), .sclk(SCLK), .led_out(LED),
			.acq_enable(acq_enable_ncd), .acq_reset(acq_reset_ncd),
			.clock_select(clksel), .clock_divisor(clkdiv_ncd),
			.channel_enable(channel_enable_ncd),
			.fifo_overflow(acq_stalled_ncd));

synchronizer acq_enable_sync (.clk(fastclk),
			      .in(acq_enable_ncd), .out(acq_enable_fcd));

synchronizer acq_reset_sync (.clk(fastclk),
			     .in(acq_reset_ncd), .out(acq_reset_fcd));

synchronizer #(8) clkdiv_sync (.clk(fastclk),
			       .in(clkdiv_ncd), .out(clkdiv_fcd));

synchronizer #(16) channel_enable_sync (.clk(fastclk),
					.in(channel_enable_ncd),
					.out(channel_enable_fcd));

synchronizer acq_stalled_sync (.clk(normalclk),
			       .in(acq_stalled_fcd), .out(acq_stalled_ncd));

fast_clock_domain fcd(.clk(fastclk), .rst(fcd_rst), .probe(PROBE),
		      .sample_data(sample_data),
		      .sample_data_avail(sample_data_avail),
		      .overflow(fifo_overflow),
		      .acq_enable(acq_enable_fcd),
		      .clock_divisor(clkdiv_fcd),
		      .channel_enable(channel_enable_fcd),
		      .stalled(acq_stalled_fcd));

assign fcd_rst = acq_reset_fcd;
assign fifo_reset = acq_reset_fcd;

// Global reset
reset_generator rst_gen (.clk(normalclk), .rst(ncd_rst));
assign clkgen_rst = ncd_rst;

endmodule
