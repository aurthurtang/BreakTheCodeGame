`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2021 08:10:44 PM
// Design Name:  
// Module Name: timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//   This module is used to create acount down clock.  The digits will be send to the eightSegmentLEDdriver to display
//
//   Inputs:  
//       resetb  - This will reset to clock to 2 minutes
//       start   - From game Logic to start the count down
//       stop    - From game Logic to stop the clock when player solve the riddle
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "definitions.v"

module timer (
    input  wire  clk,
    input  wire  resetb,
    
    input  wire  enable,
    input  wire  reset_timer,
   
    output reg  timer_expires,
    output reg [3:0] display_digit[8]
    );

  localparam real CLK_PERIOD = `CLK_PERIOD;  //10 ns
  localparam SEC_DIV100_CNT = int'(10000000 / CLK_PERIOD);  //1/100 of a second = 1000000000 / 100 = 10000000
  localparam CLOCK_CNT_WIDTH = $clog2(SEC_DIV100_CNT);
  localparam  COUNTTIME = `MAX_TIMER_COUNT;
  localparam TIME_COUNT_WIDTH = $clog2(`MAX_TIMER_COUNT);

  integer i;
  
  logic [CLOCK_CNT_WIDTH-1:0] second_cnt;  //COunter to increment the time
  logic [6:0] loop_cnt;
  logic [TIME_COUNT_WIDTH-1:0] timer_cnt;

  wire  timer_finished = (timer_cnt == 0) && (loop_cnt == 0);

  //The last 2 digits are for the fractional part of a second
  //The rest is use for the second.
  always_ff @(posedge clk or negedge resetb)
    if (!resetb ) begin
      timer_expires <= 1'b0;
      second_cnt <= {CLOCK_CNT_WIDTH{1'b0}}; 
      loop_cnt <= 7'b0;
      for (i=0;i<8;i++) display_digit[i] <= 4'b0;
      timer_cnt <= COUNTTIME;   
    end else if (reset_timer) begin
      timer_expires <= 1'b0;
      second_cnt <= {CLOCK_CNT_WIDTH{1'b0}}; 
      loop_cnt <= 7'b0;
      for (i=0;i<8;i++) display_digit[i] <= 4'b0;
      timer_cnt <= COUNTTIME;    
    end else begin
       timer_expires <= timer_finished;
       for (i=0; i <= 5;i++) display_digit[i+2] <= (timer_cnt % (10**(i+1))) / (10 ** i);
	   for (i=0; i <= 1;i++) display_digit[i] <= (loop_cnt % (10**(i+1))) / (10 ** i);

       if (enable & ~timer_finished) begin

         if (second_cnt == SEC_DIV100_CNT) begin
             second_cnt <= {CLOCK_CNT_WIDTH{1'b0}};
            
            //Decrement the count
            if (loop_cnt == 'd0) begin
              loop_cnt <= 'd99;
              
              if (timer_cnt != 0) timer_cnt <= timer_cnt - 1;
              else timer_cnt <= 0;            
            end else loop_cnt <= loop_cnt - 1;  //if (loop_cnt == 'd99)
          end else second_cnt <= second_cnt + 1; //if (second_cnt == SEC_DIV100_COUNT)
        end  //if (startTimer) begin
      end

endmodule
