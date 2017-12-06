`timescale 1ns / 1ps

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

  reg [11:0] sins  =  0;
  reg [2:0]  sclk  =  0;
  reg [12:0] sidx  =  0;
  reg        sclk_stopped  =  0;
  reg [2:0]  gsclk =  0;
  reg [11:0] gsidx =  0;
  reg        gsclk_stopped  =  0;
  reg [3:0]  blank = 0;
  reg [12:0] off   = 0;

  assign {led_r_sin,led_l_sin} = sins;
  assign led_sclk     = sclk[2];
  assign sclk_strobe  = sclk == 7;
  assign led_gsclk    = gsclk[2];
  assign gsclk_strobe = gsclk == 7;
  assign led_blank    = |blank;
  assign led_xlat     = blank > 4 && blank < 12 && sidx == 0;

  wire [10:0] sidx_max      = 575; // 575
  wire [11:0] gsidx_max     = 4095; // 4095

  reg [11:0] rom[4607:0];

  initial begin
    $readmemh("../image.hex", rom, 0, 4607);
  end

  always @(posedge clock) begin
    sins = rom[sidx+off];
    if (!sclk_stopped) begin
      sclk <= sclk + 1;
    end
    if (sclk_strobe) begin
      if (sidx == sidx_max) begin
        sidx <= 0;
        off <= off == 4032 ? 0 : off + 576;
        sclk_stopped <= 1;
      end else begin
        sidx <= sidx + 1;
      end
    end
    if (gsclk_stopped) begin
      blank <= blank + 1;
    end else begin
      gsclk <= gsclk + 1;
    end
    if (blank == 0) begin
      if (gsclk_stopped) begin
        sclk_stopped <= 0;
      end
      gsclk_stopped = 0;
      blank <= 0;
    end
    if (gsclk_strobe) begin
      if (gsidx == gsidx_max) begin
        gsclk_stopped = 1;
        gsidx <= 0;
        blank <= 1;
      end else begin
        gsidx <= gsidx + 1;
      end
    end
  end


endmodule