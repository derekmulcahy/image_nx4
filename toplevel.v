`timescale 1ns / 1ps

// Simple test program for Barco NX4 led panels.

`define INDEX_MAX_DEFAULT   576
`define GSCLK_WIDTH_DEFAULT 15

module toplevel(
    input clock,
    output led_sclk,
    output [6:1] led_l_sin,
    output [6:1] led_r_sin,
    input led_xerr,
    output led_mode,
    output led_blank,
    output led_xlat,
    output led_gsclk,
    output cpld_p8,
    output status_yellow,
    output status_orange,
    output status_red,
    output cpld_p2
  );

  parameter INDEX_MAX   = `INDEX_MAX_DEFAULT;
  parameter GSCLK_WIDTH = `GSCLK_WIDTH_DEFAULT;

  romimage #(
    .INDEX_MAX(INDEX_MAX),
    .GSCLK_WIDTH(GSCLK_WIDTH)
  ) driver (
    .clock(clock),
    .led_sclk(led_sclk),
    .led_l_sin(led_l_sin),
    .led_r_sin(led_r_sin),
    .led_mode(led_mode),
    .led_blank(led_blank),
    .led_xlat(led_xlat),
    .led_gsclk(led_gsclk)
  );

  reg blank_previous    = 0;
  reg [9:0] blank_count = 0;

  assign status_yellow = blank_count[9];
  assign status_orange = 0;
  assign status_red    = !led_xerr; // XERR is active low
  assign cpld_p8       = led_blank; // Activate CPLD watchdog
  assign cpld_p2       = 1;         // Enable cycling between rows

  always @(posedge clock) begin
    blank_previous <= led_blank;
    if (!blank_previous && led_blank) begin
        blank_count <= blank_count + 1;
    end
  end
endmodule
