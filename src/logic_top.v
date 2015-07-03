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
wire fastclk, normalclk;

clock_generator clkgen (.U1_CLKIN_IN(CLKIN48), .U1_U2_SELECT_IN(clksel),
                        .U1_RST_IN(clkgen_rst), .U2_RST_IN(clkgen_rst),
			.U1_CLKIN_IBUFG_OUT(normalclk), .U1_U2_CLK_OUT(fastclk),
			.U1_LOCKED_OUT(), .U2_LOCKED_OUT());

wire fifo_reset; // async

wire [15:0] sample_data;  // fast clock domain
wire sample_data_avail;   // - " -
wire fcd_rst;             // - " -

wire ncd_rst;             // normal clock domain

fifo_generator_v9_3 fifo(.rst(fifo_reset), .wr_clk(fastclk), .rd_clk(~IFCLK),
                         .din(sample_data), .wr_en(sample_data_avail),
                         .rd_en(~CTL0), .dout({PORT_D, PORT_B}),
                         .full(), .overflow(),
                         .empty(), .valid(RDY0));

// normal clock domain -> fast clock domain
wire acq_enable_ncd, acq_enable_fcd;
wire acq_reset_ncd, acq_reset_fcd;
wire [7:0] clkdiv_ncd, clkdiv_fcd;
wire [15:0] channel_enable_ncd, channel_enable_fcd;

normal_clock_domain ncd(.clk(normalclk), .rst(ncd_rst), .miso(MISO),
			.mosi(MOSI), .ss(SS), .sclk(SCLK), .led_out(LED),
			.acq_enable(acq_enable_ncd), .acq_reset(acq_reset_ncd),
			.clock_select(clksel), .clock_divisor(clkdiv_ncd),
			.channel_enable(channel_enable_ncd));

synchronizer acq_enable_sync (.clk(fastclk),
			      .in(acq_enable_ncd), .out(acq_enable_fcd));

synchronizer acq_reset_sync (.clk(fastclk),
			     .in(acq_reset_ncd), .out(acq_reset_fcd));

synchronizer #(8) clkdiv_sync (.clk(fastclk),
			       .in(clkdiv_ncd), .out(clkdiv_fcd));

synchronizer #(16) channel_enable_sync (.clk(fastclk),
					.in(channel_enable_ncd),
					.out(channel_enable_fcd));

fast_clock_domain fcd(.clk(fastclk), .rst(fcd_rst), .probe(PROBE),
		      .sample_data(sample_data),
		      .sample_data_avail(sample_data_avail),
		      .acq_enable(acq_enable_fcd),
		      .clock_divisor(clkdiv_fcd),
		      .channel_enable(channel_enable_fcd));

assign fcd_rst = acq_reset_fcd;
assign fifo_reset = acq_reset_fcd;

// Global reset
wire reset_release;  // normal clock domain
synchronizer reset_release_delay (.clk(normalclk), .in(1'b1), .out(reset_release));
assign ncd_rst = ~reset_release;
assign clkgen_rst = ncd_rst;

endmodule
