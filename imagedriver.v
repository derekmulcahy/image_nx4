`timescale 1ns / 1ps

module imagedriver(
    input  clock,
    output led_sclk,
    output [6:1] led_l_sin,
    output [6:1] led_r_sin,
    output led_cal_sin,
    output reg led_mode = 1,
    output reg led_blank = 1,
    output reg led_xlat = 0,
    output led_gsclk
  );

  parameter D = 2; // value used to divide the clock for gsclk and sclk

  reg [D:0]  gsclk_counter = ~0; // clock counter for gsclk
  reg [11:0] blank_count   =  0; // gsclk counter for blanking
  reg [D:0]  sclk_counter  = ~0; // clock counter for sclk
  reg        sclk_stopped  =  0; // sclk runs when data is being sent
  reg [9:0]  bit_count     =  0; // counts 576 grayscale bits or 288 dot-correction bits
  reg [2:0]  row_count     =  0; // rows 0 to 5 are connected to led_*sin pins, 6 and 7 are phantoms.

  wire [0:287] dc;              // one row of dot-correction bits, 6 * 16 * 3
  wire [0:95]  dcr, dcg, dcb;   // 96 bits for dot-correction of one color

  assign led_sclk     = sclk_counter[D];    // sclk is clock/8
  assign sclk_strobe  = sclk_counter == 0;  // 1 clock wide sclk pulse every clock/4 cycles
  assign led_gsclk    = gsclk_counter[D];   // gsclk is clock/8
  assign gsclk_strobe = gsclk_counter == 0; // 1 clock wide gsclk pulse every clock/4 cycles
  // assign led_blank    = blank_count == 0;   // generate blank pulse when blank_count wraps around
  assign dcr          = {16{6'b000010}};    // 6 red dot-correction bits
  assign dcg          = {16{6'b000010}};    // 6 red dot-correction bits
  assign dcb          = {16{6'b000010}};    // 6 red dot-correction bits, blue needs boosting
  assign dc           = {dcb,dcg,dcr};      // assemble a row of the blue, green and red dot-correction bits

`include "image.v"

wire [0:575] lgsa;
wire [0:575] lgsb;
wire [0:575] lgsc;
wire [0:575] lgsd;
wire [0:575] lgse;
wire [0:575] lgsf;
wire [0:575] rgsa;
wire [0:575] rgsb;
wire [0:575] rgsc;
wire [0:575] rgsd;
wire [0:575] rgse;
wire [0:575] rgsf;

  assign lgsa = (row_count == 0) ?  lgs0 : (row_count == 1) ?  lgs1 : (row_count == 2) ?  lgs2 : (row_count == 3) ?  lgs3 : (row_count == 4) ?  lgs4 : (row_count == 5) ? lgs5  : 0;
  assign lgsb = (row_count == 0) ?  lgs6 : (row_count == 1) ?  lgs7 : (row_count == 2) ?  lgs8 : (row_count == 3) ?  lgs9 : (row_count == 4) ? lgs10 : (row_count == 5) ? lgs11 : 0;
  assign lgsc = (row_count == 0) ? lgs12 : (row_count == 1) ? lgs13 : (row_count == 2) ? lgs14 : (row_count == 3) ? lgs15 : (row_count == 4) ? lgs16 : (row_count == 5) ? lgs17 : 0;
  assign lgsd = (row_count == 0) ? lgs18 : (row_count == 1) ? lgs19 : (row_count == 2) ? lgs20 : (row_count == 3) ? lgs21 : (row_count == 4) ? lgs22 : (row_count == 5) ? lgs23 : 0;
  assign lgse = (row_count == 0) ? lgs24 : (row_count == 1) ? lgs25 : (row_count == 2) ? lgs26 : (row_count == 3) ? lgs27 : (row_count == 4) ? lgs28 : (row_count == 5) ? lgs29 : 0;
  assign lgsf = (row_count == 0) ? lgs30 : (row_count == 1) ? lgs31 : (row_count == 2) ? lgs32 : (row_count == 3) ? lgs33 : (row_count == 4) ? lgs34 : (row_count == 5) ? lgs35 : 0;
  // assign lgsa = (row_count == 0) ? {12'h0FF,12'h0FF,552'b0} : 576'b0;

  assign led_l_sin[1] = led_mode ? dc[bit_count] : lgsa[bit_count];
  assign led_l_sin[2] = led_mode ? dc[bit_count] : lgsb[bit_count];
  assign led_l_sin[3] = led_mode ? dc[bit_count] : lgsc[bit_count];
  assign led_l_sin[4] = led_mode ? dc[bit_count] : lgsd[bit_count];
  assign led_l_sin[5] = led_mode ? dc[bit_count] : lgse[bit_count];
  assign led_l_sin[6] = led_mode ? dc[bit_count] : lgsf[bit_count];

  assign rgsa = (row_count == 0) ?  rgs0 : (row_count == 1) ?  rgs1 : (row_count == 2) ?  rgs2 : (row_count == 3) ?  rgs3 : (row_count == 4) ?  rgs4 : (row_count == 5) ? rgs5  : 0;
  assign rgsb = (row_count == 0) ?  rgs6 : (row_count == 1) ?  rgs7 : (row_count == 2) ?  rgs8 : (row_count == 3) ?  rgs9 : (row_count == 4) ? rgs10 : (row_count == 5) ? rgs11 : 0;
  assign rgsc = (row_count == 0) ? rgs12 : (row_count == 1) ? rgs13 : (row_count == 2) ? rgs14 : (row_count == 3) ? rgs15 : (row_count == 4) ? rgs16 : (row_count == 5) ? rgs17 : 0;
  assign rgsd = (row_count == 0) ? rgs18 : (row_count == 1) ? rgs19 : (row_count == 2) ? rgs20 : (row_count == 3) ? rgs21 : (row_count == 4) ? rgs22 : (row_count == 5) ? rgs23 : 0;
  assign rgse = (row_count == 0) ? rgs24 : (row_count == 1) ? rgs25 : (row_count == 2) ? rgs26 : (row_count == 3) ? rgs27 : (row_count == 4) ? rgs28 : (row_count == 5) ? rgs29 : 0;
  assign rgsf = (row_count == 0) ? rgs30 : (row_count == 1) ? rgs31 : (row_count == 2) ? rgs32 : (row_count == 3) ? rgs33 : (row_count == 4) ? rgs34 : (row_count == 5) ? rgs35 : 0;
  // assign rgsa = (row_count == 0) ? {12'h0FF,12'h0FF,552'b0} : 576'b0;

  assign led_r_sin[1] = led_mode ? dc[bit_count] : rgsa[bit_count];
  assign led_r_sin[2] = led_mode ? dc[bit_count] : rgsb[bit_count];
  assign led_r_sin[3] = led_mode ? dc[bit_count] : rgsc[bit_count];
  assign led_r_sin[4] = led_mode ? dc[bit_count] : rgsd[bit_count];
  assign led_r_sin[5] = led_mode ? dc[bit_count] : rgse[bit_count];
  assign led_r_sin[6] = led_mode ? dc[bit_count] : rgsf[bit_count];

  assign led_cal_sin  = 0; // calibration leds are off

  reg [7:0] delay = 0;

  always @(posedge clock)
  begin
    if (!delay) begin
      gsclk_counter <= gsclk_counter + 1;
      led_blank <= 0;
      if (gsclk_strobe) begin
        if (blank_count == 0) begin
          led_blank <= 1;
        end
        blank_count <= blank_count + 1;
      end
    end
  end

  reg led_mode_n = 1;
  reg led_mode_nn = 1;

  // TODO: Make xlat long, clear @negedge of gsclk

  always @(posedge clock)
  begin
    if (delay) begin
      delay <= delay - 1;
    end else begin
      if (gsclk_strobe) begin
        led_xlat <= 0;
        led_mode <= led_mode_nn;
        led_mode_nn <= led_mode_n;
      end
      if (!sclk_stopped && !led_blank) begin
        sclk_counter <= sclk_counter + 1;
      end
      if (led_blank) begin
        sclk_stopped <= 0;
      end
      if (sclk_strobe) begin
        if (bit_count == (led_mode ? 287 : 575)) begin
          bit_count    <= 0;
          sclk_stopped <= led_mode_n ? 0 : 1;
          led_xlat     <= 1;
          led_mode_n   <= 0;
          // led_mode_n   <= !led_mode;
          if (!led_mode) begin
            delay <= 255;
            if (row_count == 7) begin
              row_count <= 0;
            end else begin
              row_count <= row_count + 1;
            end
          end
        end else begin
          bit_count <= bit_count + 1;
        end
      end
    end
  end

endmodule