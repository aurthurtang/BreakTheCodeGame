`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2021 09:49:15 AM
// Design Name: 
// Module Name: pulse_synchronizer
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


module pulse_synchronizer(
    input clk,
    input in,
    output outb
    );

logic [1:0] ff_delay;

    always_ff @(posedge clk or posedge in)
      if (in) ff_delay <= 2'b00;
      else ff_delay <= {ff_delay[0],1'b1};

assign outb = ff_delay[1];

endmodule
