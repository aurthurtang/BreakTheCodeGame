`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2021 10:20:44 AM
// Design Name: 
// Module Name: colorLEDDriver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "definitions.v"

module colorLEDDriver(
    input  clk,
    input  resetb,
    input  startgame,
    input  breakcode,
    output logic green,
    output logic red,
    output logic blue
    );

    localparam real CLK_PERIOD = `CLK_PERIOD;  // 100 Mhz (ns)
    localparam real CARRIER_FREQ = `LED_CARRIER_FREQ; //50 (in KHz)
    localparam real PULSE_WIDTH = 1000000 / CARRIER_FREQ;  // kHz (1 Hz = 1000000000 ns; 1 kHz = 1000000 ns;
    localparam PULSE_COUNT = int'(PULSE_WIDTH / (2 * CLK_PERIOD));
    localparam PULSE_CNT_WIDTH = $clog2(PULSE_COUNT);

    logic [PULSE_CNT_WIDTH-1:0]  pulse_cnt;
               
    always_ff @(posedge clk or negedge resetb)
      if (!resetb) begin
        pulse_cnt <= {PULSE_CNT_WIDTH{1'b0}};
        green <= 1'b0;
        red   <= 1'b0;
        blue  <= 1'b0;
      end else begin
        if (startgame) begin
          if (pulse_cnt == PULSE_COUNT) begin
            pulse_cnt <= {PULSE_CNT_WIDTH{1'b0}};
            if (breakcode) begin
              green <= ~green;
              red  <= 1'b0;
              blue <= 1'b0;
            end else begin
              green <= 1'b0;
              red <= ~red;
              blue <= 1'b0;
            end
          end else pulse_cnt <= pulse_cnt + 1;
        end
      end
            
endmodule

