`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2021 08:44:51 AM
// Design Name: 
// Module Name: breakthecode_wrapper
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


module breakthecode_wrapper(
    input clk,           //Use for game logic (1 Mhz)
    
    //buttons input
    input reset,
    input confirm,
    input start,
    
    //Switches input
    input [15:0] SW,
    
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

    breakthecode i_breakthecode (
      .clk(clk),           //Use for game logic (1 Mhz)
      .reset(reset),
      .confirm(confirm),
      .start(start),
      .switches(SW),
      .A(A),
      .B(B),
      .AN(AN),
      .CN(CN),
      .red(red),
      .blue(blue),
      .green(green)
    );
    
endmodule
