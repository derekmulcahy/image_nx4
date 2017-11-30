`timescale 1ns / 1ps

module imagedriver(
    input  clock,
    output led_sclk,
    output [6:1] led_l_sin,
    output [6:1] led_r_sin,
    output led_cal_sin,
    output reg led_mode = 1,
    output led_blank,
    output reg led_xlat = 0,
    output led_gsclk
  );

  parameter D = 4; // value used to divide the clock for gsclk and sclk

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
  assign led_blank    = blank_count == 0;   // generate blank pulse when blank_count wraps around
  assign dcr          = {16{6'b000001}};    // 6 red dot-correction bits
  assign dcg          = {16{6'b000001}};    // 6 red dot-correction bits
  assign dcb          = {16{6'b000010}};    // 6 red dot-correction bits, blue needs boosting
  assign dc           = {dcb,dcg,dcr};      // assemble a row of the blue, green and red dot-correction bits

  wire [0:575] lgs0 = {576'h000_000_0FF_000_000_000_000_000_009_067_0DB_0E8_01C_000_000_000__0FF_000_000_000_000_000_000_000_009_067_0DB_0E8_01C_000_000_000__000_000_000_000_000_000_000_000_009_067_0DB_0E8_01C_000_000_000};
  wire [0:575] lgs1 = {576'h000_0FF_000_000_000_000_000_000_0C0_0FF_0FF_022_000_000_000_000__000_000_000_000_000_000_000_000_0C0_0FF_0FF_022_000_000_000_000__000_000_000_000_000_000_000_000_0C0_0FF_0FF_022_000_000_000_000};
  wire [0:575] lgs2 = {576'h000_0FF_0FF_000_000_000_000_077_0FF_0FD_04A_000_000_000_000_000__000_000_000_000_000_000_000_077_0FF_0FD_04A_000_000_000_000_000__000_000_000_000_000_000_000_077_0FF_0FD_04A_000_000_000_000_000};
  wire [0:575] lgs3 = {576'h0FF_000_000_000_000_000_000_0F3_0FF_0FE_05F_000_000_000_000_022__000_000_000_000_000_000_000_0F3_0FF_0FE_05F_000_000_000_000_022__000_000_000_000_000_000_000_0F3_0FF_0FE_05F_000_000_000_000_022};
  wire [0:575] lgs4 = {576'h0FF_000_0FF_000_000_000_011_0F9_0FF_0FF_0FF_064_000_000_02F_0EC__000_000_000_000_000_000_011_0F9_0FF_0FF_0FF_064_000_000_02F_0EC__000_000_000_000_000_000_011_0F9_0FF_0FF_0FF_064_000_000_02F_0EC};
  wire [0:575] lgs5 = {576'h0FF_0FF_000_000_000_000_000_0F7_0FF_0FF_0FF_0FF_082_00F_0EE_0D3__000_000_000_000_000_000_000_0F7_0FF_0FF_0FF_0FF_082_00F_0EE_0D3__000_000_0FF_000_000_000_000_0F7_0FF_0FF_0FF_0FF_082_00F_0EE_0D3};
  wire [0:575] lgs;

  //assign lgs = (row_count == 0) ? lgs0 : (row_count == 1) ? lgs1 : (row_count == 2) ? lgs2 : (row_count == 3) ? lgs3 : (row_count == 4) ? lgs4 : (row_count == 5) ? lgs5 : {384'b0,36'h0FF0FF0FF,156'b0};
  assign lgs = (row_count == 0) ? {12'h0FF,12'h0FF,552'b0} : 576'b0;

  //assign led_l_sin    = led_mode ? {6{dc[bit_count]}} : {6{lgs[bit_count]}};
  assign led_l_sin[1]    = led_mode ? dc[bit_count] : lgs[bit_count];
  assign led_l_sin[6:2]  = 0;
  assign led_r_sin       = 0;
  assign led_cal_sin     = 0; // calibration leds are off

  always @(posedge clock)
  begin
    gsclk_counter <= gsclk_counter + 1;
    if (gsclk_strobe) begin
      blank_count <= blank_count + 1;
    end
  end

  reg led_mode_n = 1;

  // TODO: Make xlat long, clear @negedge of gsclk

  always @(posedge clock)
  begin
    // if (gsclk_strobe) begin
      led_xlat <= 0;
      led_mode <= led_mode_n;
    // end
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
        led_mode_n   <= !led_mode;
        if (!led_mode) begin
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

endmodule