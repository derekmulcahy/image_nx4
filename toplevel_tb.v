`timescale 1ns / 1ps

`define INDEX_MAX_DEFAULT   24
`define GSCLK_WIDTH_DEFAULT 8

module toplevel_tb;

  // Inputs
  reg clock;
  reg led_xerr;

  // Outputs
  wire led_sclk;
  wire [6:1] led_l_sin;
  wire [6:1] led_r_sin;
  wire led_mode;
  wire led_blank;
  wire led_xlat;
  wire led_gsclk;
  wire status_yellow;
  wire status_orange;
  wire status_red;

  parameter INDEX_MAX   = `INDEX_MAX_DEFAULT;
  parameter GSCLK_WIDTH = `GSCLK_WIDTH_DEFAULT;

  // Instantiate the Unit Under Test (UUT)
  toplevel #(
    .INDEX_MAX(INDEX_MAX),
    .GSCLK_WIDTH(GSCLK_WIDTH)
  ) uut (
    .clock(clock),
    .led_sclk(led_sclk),
    .led_l_sin(led_l_sin),
    .led_r_sin(led_r_sin),
    .led_xerr(led_xerr),
    .led_mode(led_mode),
    .led_blank(led_blank),
    .led_xlat(led_xlat),
    .led_gsclk(led_gsclk),
    .status_yellow(status_yellow),
    .status_orange(status_orange),
    .status_red(status_red)
  );

  always
    #12.5 clock = !clock;

  initial begin
      // Initialize Inputs
      clock = 0;
      led_xerr = 0;

      // Wait 100 ns for global reset to finish
      #100;

      // Add stimulus here

  end

endmodule

