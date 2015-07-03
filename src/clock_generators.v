`timescale 1ns / 1ps

module clock_generators(
    input clk48,
    input IFCLK,
    input clkgen_rst,
    input clksel,
    output fastclk,
    output ifclk_out,
    output clocks_locked
);

  localparam period48 = 1000.0/48.0;

  wire fbclk, fbclk_buf;
  wire fbclk2, fbclk2_buf;
  wire clk100, clk160, clkif180;
  wire clk100_locked, clk160_locked, clk48_locked, clkif_locked;
  wire ifclk_buf;

  DCM_SP #( .CLKFX_MULTIPLY(4), .CLKFX_DIVIDE(1),
	    .CLKIN_PERIOD(period48), .CLKIN_DIVIDE_BY_2("FALSE"),
	    .CLK_FEEDBACK("1X"), .CLKDV_DIVIDE(2),
	    .PHASE_SHIFT(0), .CLKOUT_PHASE_SHIFT("NONE"),
	    .DUTY_CYCLE_CORRECTION("TRUE"), .STARTUP_WAIT("FALSE"),
	    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .FACTORY_JF(16'hc080),
	    .DFS_FREQUENCY_MODE("LOW"), .DLL_FREQUENCY_MODE("LOW") )
   dcm48 (.CLKIN(clk48), .CLKFB(fbclk_buf), .RST(clkgen_rst),
	  .CLK0(fbclk), .LOCKED(clk48_locked),
	  .PSEN(1'b0), .PSCLK(1'b0), .PSINCDEC(1'b0), .DSSEN(1'b0));

  BUFG fb_buf(.I(fbclk), .O(fbclk_buf));

  IBUFG ifin_buf(.I(IFCLK), .O(ifclk_buf));

  DCM_SP #( .CLKFX_MULTIPLY(4), .CLKFX_DIVIDE(1),
	    .CLKIN_PERIOD(period48), .CLKIN_DIVIDE_BY_2("FALSE"),
	    .CLK_FEEDBACK("1X"), .CLKDV_DIVIDE(2),
	    .PHASE_SHIFT(0), .CLKOUT_PHASE_SHIFT("NONE"),
	    .DUTY_CYCLE_CORRECTION("TRUE"), .STARTUP_WAIT("FALSE"),
	    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .FACTORY_JF(16'hc080),
	    .DFS_FREQUENCY_MODE("LOW"), .DLL_FREQUENCY_MODE("LOW") )
   dcmif (.CLKIN(ifclk_buf), .CLKFB(fbclk2_buf), .RST(clkgen_rst),
	  .CLK0(fbclk2), .CLK180(clkif180), .LOCKED(clkif_locked),
	  .PSEN(1'b0), .PSCLK(1'b0), .PSINCDEC(1'b0), .DSSEN(1'b0));

  BUFG fb2_buf(.I(fbclk2), .O(fbclk2_buf));

  BUFG ifout_buf(.I(clkif180), .O(ifclk_out));

  DCM_SP #( .CLKFX_MULTIPLY(25), .CLKFX_DIVIDE(12), // 48*25/12 = 100
	    .CLKIN_PERIOD(period48), .CLKIN_DIVIDE_BY_2("FALSE"),
	    .CLK_FEEDBACK("NONE"), .CLKDV_DIVIDE(2),
	    .PHASE_SHIFT(0), .CLKOUT_PHASE_SHIFT("NONE"),
	    .DUTY_CYCLE_CORRECTION("TRUE"), .STARTUP_WAIT("FALSE"),
	    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .FACTORY_JF(16'hc080),
	    .DFS_FREQUENCY_MODE("LOW"), .DLL_FREQUENCY_MODE("LOW") )
   dcm100 (.CLKIN(fbclk_buf), .CLKFB(1'b0), .RST(clkgen_rst),
	   .CLK0(), .CLKFX(clk100), .LOCKED(clk100_locked),
	   .PSEN(1'b0), .PSCLK(1'b0), .PSINCDEC(1'b0), .DSSEN(1'b0));

  DCM_SP #( .CLKFX_MULTIPLY(10), .CLKFX_DIVIDE(3), // 48*10/3 = 160
	    .CLKIN_PERIOD(period48), .CLKIN_DIVIDE_BY_2("FALSE"),
	    .CLK_FEEDBACK("NONE"), .CLKDV_DIVIDE(2),
	    .PHASE_SHIFT(0), .CLKOUT_PHASE_SHIFT("NONE"),
	    .DUTY_CYCLE_CORRECTION("TRUE"), .STARTUP_WAIT("FALSE"),
	    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .FACTORY_JF(16'hc080),
	    .DFS_FREQUENCY_MODE("LOW"), .DLL_FREQUENCY_MODE("LOW") )
   dcm160 (.CLKIN(fbclk_buf), .CLKFB(1'b0), .RST(clkgen_rst),
	   .CLK0(), .CLKFX(clk160), .LOCKED(clk160_locked),
	   .PSEN(1'b0), .PSCLK(1'b0), .PSINCDEC(1'b0), .DSSEN(1'b0));

  BUFGMUX fastclk_mux(.I0(clk100), .I1(clk160), .S(clksel), .O(fastclk));

  assign clocks_locked = clk100_locked & clk160_locked & clk48_locked && clkif_locked;

endmodule // clock_generators
