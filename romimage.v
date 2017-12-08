`timescale 1ns / 1ps

`define INDEX_MAX_DEFAULT   576
`define GSCLK_WIDTH_DEFAULT 15

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

  parameter INDEX_MAX   = `INDEX_MAX_DEFAULT;
  parameter GSCLK_WIDTH = `GSCLK_WIDTH_DEFAULT;

  reg [11:0] sins          = 0;
  reg [2:0]  sclk          = 0;
  reg        sclk_pulse    = 0;
  reg        sclk_stopped  = 0;
  reg        gsclk_pulse   = 0;
  reg [GSCLK_WIDTH - 1:0] gsclk =  0;
  reg        gsclk_stopped = 0;
  reg [2:0]  blank         = 0;
  reg [11:0] rom[INDEX_MAX*8-1:0];
  reg [12:0] index         = 0;
  reg [12:0] offset        = 0;

  assign {led_r_sin,led_l_sin} = sins;
  assign led_sclk     = sclk[2];
  assign led_gsclk    = gsclk[2];
  assign led_blank    = |blank;
  assign led_xlat     = blank > 2 && blank < 6 && index == 0;

  initial begin
    $readmemh("../image.hex", rom, 0, INDEX_MAX*8-1);
  end

  always @(posedge clock) begin
    sins = rom[index + offset];
    if (!sclk_stopped) begin
      {sclk_pulse, sclk} <= sclk + 1;
    end
    if (sclk_pulse) begin
      if (index == INDEX_MAX-1) begin
        index <= 0;
        offset <= offset == INDEX_MAX*7 ? 0 : offset + INDEX_MAX;
        sclk_stopped <= 1;
      end else begin
        index <= index + 1;
      end
    end
    if (blank == 0) begin
      {gsclk_pulse, gsclk} <= gsclk + 1;
      if (gsclk_stopped) begin
        sclk_stopped <= 0;
      end
      gsclk_stopped <= 0;
    end else begin
      blank <= blank + 1;
    end
    if (gsclk_pulse) begin
      gsclk_stopped <= 1;
      gsclk <= 0;
      blank <= 1;
    end
  end

endmodule