`timescale 1ns / 1ps

module normal_clock_domain(
    input clk,
    output miso,
    input mosi,
    input ss,
    input sclk
);

assign miso = 1'b0;

endmodule
