`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2021 09:34:34 AM
// Design Name: 
// Module Name: breakthecode
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


module breakthecode(
    input clk,           //Use for game logic (1 Mhz)
    
    //buttons input
    input reset,
    input confirm,
    input start,
    
    //Switches input
    input [15:0] switches,
    
    //LED output (bit [15:12] - A; bit[3:0] - B)
    //A = # of Correct Code
    //B = # of Correct Location
    output [3:0] A,
    output [3:0] B,
    
    //Display output
    output [7:0] AN,
    output [7:0] CN,
    
    //RGB LED
    output red,
    output blue,
    output green
    );

wire [3:0] display_digit[8];
wire timer_expires;
wire timer_enable;
wire reset_timer;
wire reset_b;
wire reset_dclk_b;
wire confirm_b;
wire start_b;
wire select_timerDisplay;
wire codeBreak;
wire gameStart;

pulse_synchronizer isync_reset   (.clk(clk), .in(reset), .outb (reset_b));
pulse_synchronizer isync_confirm (.clk(clk), .in(confirm), .outb (confirm_b));
pulse_synchronizer isync_start   (.clk(clk), .in(start), .outb (start_b));

timer i_timer (
    .clk    (clk),
    .resetb (reset_b),
    .enable (timer_enable),          //From Logic
    .reset_timer (reset_timer),
    .timer_expires (timer_expires),   //To logic
    .display_digit (display_digit)    //to LEDDriver
);

    
gameLogic i_gameLogic (
     .clk    (clk),
     .resetb (reset_b),
     .start  (~start_b),
     .confirmSel (~confirm_b),
     .switches (switches),
     
     //Timer
     .timer_enable (timer_enable),  
     .timer_expires (timer_expires),
     .reset_timer  (reset_timer),
     
     //LEDs
     .correctCode (A),
     .correctLoc  (B),
     
     //RGB LEDs
     .gameStart   (gameStart),
     .codeBreak   (codeBreak)
);
     
eightSegmentLEDdriver i_LEDDriver (
    .clk    (clk),
    .resetb (reset_b),
    .digits(display_digit),
    .AN (AN),
    .COUT (CN)
);

colorLEDDriver i_colorLEDDriver (
    .clk  (clk),
    .resetb (reset_b),
    .startgame (gameStart),   //From Logic
    .breakcode (codeBreak),   //From Logic
    .green (green),  //When code is break
    .red (red),    //When code is notbreak
    .blue (blue)    //always disable
 );

endmodule
