`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2021 09:32:53 AM
// Design Name: 
// Module Name: prbs_gen
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

module prbs_gen
 #(
  parameter BIT_COUNT = 16,
  parameter  REMAINDER_SIZE = 11,
  parameter [REMAINDER_SIZE:0] CRC_POLYNOMIAL = 'b1010_0000_0001 //       CRC Polynomial :===  g(x) = x11 + x9 + 1
) (
  input clk,
  input resetb,
  input [REMAINDER_SIZE-1:0] seed_in,    //Input of poly.  Initially load a seed, Then use poly_op data.
  output reg [BIT_COUNT-1:0] datout
);

reg [REMAINDER_SIZE:0] nCRC;                       // temp vaiables used in CRC calculation
reg [REMAINDER_SIZE-1:0] poly_ip;
reg load_seed;
reg [(BIT_COUNT-1):0] data;


//load data
always_ff @(posedge clk or negedge resetb)
  if (!resetb) begin
    datout <= 'b0;
    poly_ip <= 'b0;
    load_seed <= 'b1;
  end else begin
    load_seed <= 'b0;
    datout <= data; 
    if (load_seed) poly_ip <= seed_in;
    else poly_ip <= nCRC[REMAINDER_SIZE:1];  //Last CRC entry feed back to input
  end 
     

integer i;
always @ * begin
  nCRC = {poly_ip,^(CRC_POLYNOMIAL & {poly_ip,1'b0})};  //Calculate the first CRC bit
  for(i=1;i<BIT_COUNT;i=i+1) begin                     // Calculate remaining CRC for all other data bits in parallel
    data[i-1] = nCRC[0];                                 //Store previous result bit 0 as data
    nCRC = {nCRC,^(CRC_POLYNOMIAL & {nCRC[(REMAINDER_SIZE-1):0],1'b0})};  //cyclic redundant run for remaining bits
  end
  data[(BIT_COUNT-1)] = nCRC[0];  //final data bit
end

endmodule