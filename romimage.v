`timescale 1ns / 1ps

`define SIDX_MAX_DEFAULT    576
`define GSIDX_WIDTH_DEFAULT 12

module romimage (
    input  clock,
    output led_sclk,
    output [6:1] led_l_sin,
    output [6:1] led_r_sin,
    output reg led_mode = 0,
    output led_blank,
    output led_xlat,
    output led_gsclk
  );

  parameter GSIDX_WIDTH = `GSIDX_WIDTH_DEFAULT;
  parameter SIDX_MAX    = `SIDX_MAX_DEFAULT;

  reg [11:0] sins          = 0;
  reg [2:0]  sclk          = 0;
  reg        sclk_pulse    = 0;
  reg [12:0] sidx          = 0;
  reg        sclk_stopped  = 0;
  reg [2:0]  gsclk         = 0;
  reg        gsclk_pulse   = 0;
  reg [GSIDX_WIDTH - 1:0] gsidx =  0;
  reg        gsclk_stopped = 0;
  reg [2:0]  blank         = 0;
  reg [12:0] offset        = 0;

  assign {led_r_sin,led_l_sin} = sins;
  assign led_sclk     = sclk[2];
  assign led_gsclk    = gsclk[2];
  assign led_blank    = |blank;
  assign led_xlat     = blank > 2 && blank < 6 && sidx == 0;

  wire [10:0] sidx_max      = SIDX_MAX-1;

  reg [11:0] rom[SIDX_MAX*8-1:0];

  initial begin
    $readmemh("../image.hex", rom, 0, SIDX_MAX*8-1);
  end

  always @(posedge clock) begin
    sins = rom[sidx+offset];
    if (!sclk_stopped) begin
      {sclk_pulse, sclk} <= sclk + 1;
    end
    if (sclk_pulse) begin
      if (sidx == sidx_max) begin
        sidx <= 0;
        offset <= offset == SIDX_MAX*7 ? 0 : offset + SIDX_MAX;
        sclk_stopped <= 1;
      end else begin
        sidx <= sidx + 1;
      end
    end
    if (blank == 0) begin
      {gsclk_pulse, gsclk} <= gsclk + 1;
      if (gsclk_stopped) begin
        sclk_stopped <= 0;
      end
      gsclk_stopped = 0;
    end else begin
      blank <= blank + 1;
    end
    if (gsclk_pulse) begin
      if (&gsidx) begin
        gsclk_stopped = 1;
        gsidx <= 0;
        blank <= 1;
      end else begin
        gsidx <= gsidx + 1;
      end
    end
  end


endmodule