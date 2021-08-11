`include "definitions.v"

module eightSegmentLEDdriver (
  input  wire clk,
  input  wire resetb,
  
  input wire [3:0] digits[8],
  
  output reg [7:0] AN,
  output [7:0] COUT
);

    localparam real CLK_PERIOD = `CLK_PERIOD;  //100 Mhz
    localparam real REFRESH_RATE = 16000000.0;  //16 ms (in unit of ns)
    localparam POSITION_CHANGE_CYCLE = int'((REFRESH_RATE/CLK_PERIOD) / 8);  
    localparam POSITION_CNT_WIDTH = $clog2(POSITION_CHANGE_CYCLE);

    logic [POSITION_CNT_WIDTH-1:0] change_position_cnt; //Counter for switching AN
    logic [2:0] digit_cnt;

    always_ff @(posedge clk or negedge resetb)
      if (!resetb) begin
        AN <= 8'b1111_1110;
        change_position_cnt <= {POSITION_CNT_WIDTH{1'b0}};
        digit_cnt <= 3'b000;
      end else begin
      
        if (change_position_cnt == POSITION_CHANGE_CYCLE) begin
           change_position_cnt <= {POSITION_CNT_WIDTH{1'b0}};
           digit_cnt <= digit_cnt + 1;
           AN <= {AN[6:0],AN[7]};
        end else change_position_cnt <= change_position_cnt + 1;
      end
 
     assign COUT = digitDisplayConvert(digits[digit_cnt],(digit_cnt == 'd2)); 
     
 //Active low
   function [7:0] digitDisplayConvert;
     input [3:0] value;
     input withDot;
     
     case (value)
        0:  digitDisplayConvert = {7'b0000001,~withDot}; 
        1:  digitDisplayConvert = {7'b1001111,~withDot}; 
        2:  digitDisplayConvert = {7'b0010010,~withDot}; 
        3:  digitDisplayConvert = {7'b0000110,~withDot}; 
        4:  digitDisplayConvert = {7'b1001100,~withDot}; 
        5:  digitDisplayConvert = {7'b0100100,~withDot}; 
        6:  digitDisplayConvert = {7'b0100000,~withDot}; 
        7:  digitDisplayConvert = {7'b0001111,~withDot}; 
        8:  digitDisplayConvert = {7'b0000000,~withDot}; 
        9:  digitDisplayConvert = {7'b0001100,~withDot};
        default: digitDisplayConvert = 8'b11111111;
      endcase
   endfunction 

endmodule     
      
      
         