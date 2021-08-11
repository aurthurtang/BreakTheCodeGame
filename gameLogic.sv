`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2021 08:13:41 PM
// Design Name: 
// Module Name: gameLogic
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

module gameLogic(
    clk,
    resetb,
    start,             //From push button to start the same
    confirmSel,        //From push button to set code before game and confirm sequence during game
    switches,    //From the switches to set the code before game
    
    timer_enable,
    timer_expires,      //Timer expires. This will end the game
    reset_timer,
    
    correctCode,  //# of correct Code match (1 hot) 
    correctLoc,   //# of correct location match (1 hot)
    
    gameStart,   //Start Game
    codeBreak    //Green when codeBreak == 1; else it will be red
    );
    
    (* mark_debug = "true" *) input   clk;
    (* mark_debug = "true" *) input   resetb;
    (* mark_debug = "true" *) input   start;             //From push button to start the same
    (* mark_debug = "true" *) input   confirmSel;        //From push button to set code before game and confirm sequence during game
    input [15:0]  switches;    //From the switches to set the code before game
    
    (* mark_debug = "true" *) output reg timer_enable;
    input  timer_expires;      //Timer expires. This will end the game
    output reg reset_timer;
    
    output reg [3:0] correctCode; //# of correct Code match (1 hot) 
    output reg [3:0] correctLoc;   //# of correct location match (1 hot)
    
 (* mark_debug = "true" *) output reg       gameStart;   //Start Game
 (* mark_debug = "true" *) output reg       codeBreak;    //Green when codeBreak == 1; else it will be red
    
 (* mark_debug = "true" *) enum logic [1:0] {PREGAME = 0, GAMERUN = 1, CHECKCODE = 2, DONE =3} state;
 (* mark_debug = "true" *) logic [15:0] breakcode;  //Currently need to set by user.  Consider adding a pseudo random generator
 integer i,j;
 
 logic       userSetCode;
 logic [3:0] matchPt[4];
 logic [31:0] rotated_Code;
 logic [15:0] random_code;
 logic [15:0] playercode;
 
 //Instantiation of prbs gen
  prbs_gen i_prbs_gen(
    .clk (clk),
    .resetb (resetb),
    
    .seed_in(`INITIAL_SEED),  //Use 7fe seed
    .datout(random_code)
    );
    
 assign rotated_Code = {playercode, playercode};
 //0   playercode[0 +: 16] playercode[15:0]
 //1   playercode[4 +: 16] playercode[3:0],playercode[15:4]
 //2   playercode[8 +: 16] playercode[7:4],playercode[15:8]
 //3   playercode[12 +: 16] playercode[11:8],playercode[15:12]
  always_comb begin
    for (i=0;i<4;i++)
      for (j=0;j<4;j++) matchPt[i][j] = ~|(rotated_Code[(i*4+(4*j)) +: 4] ^ breakcode[4*j +:4]);   
 end  
 
 always_ff @(posedge clk or negedge resetb)
   if (!resetb) begin
     correctCode <= 4'b0000;
     correctLoc <= 4'b0000;
     gameStart <= 1'b0;
     timer_enable <= 1'b0;
     codeBreak <= 1'b0;
     state <= PREGAME;
     breakcode <= 16'h0000;  
     playercode <= 16'h0000;
     reset_timer <= 1'b0;
     userSetCode <= 1'b0;
   end else begin
     case (state)
     PREGAME:
       begin
         if (start) begin
           state <= GAMERUN;
           reset_timer <= 1'b1;
           timer_enable <= 1'b1;
           gameStart <= 1'b0;
           breakcode <= (userSetCode) ? playercode : random_code;
         end else begin
           state <= PREGAME;

           if (confirmSel) begin
             playercode <= switches;
             userSetCode <= 1'b1;
           end
         end
       end
      GAMERUN:
        begin
          reset_timer <= 1'b0;
          userSetCode <= 1'b0;

          if (timer_expires) begin
            state <= DONE;
            timer_enable <= 1'b0;
          end else if (confirmSel) begin 
            playercode <= switches;
            state <= CHECKCODE;
          end
        end
      CHECKCODE:
        begin
          if (timer_expires) begin 
            state <= DONE;
            timer_enable <= 1'b0;
          end
          else begin
            gameStart <= 1'b1;
            correctLoc <= remapLED(matchPt[0]);
            correctCode <= remapLED(matchPt[0] | matchPt[1] | matchPt[2] | matchPt[3]);
            if (playercode == breakcode) begin
              state <= DONE;
              codeBreak <= 1'b1;
              timer_enable <= 1'b0;
            end else begin
              state <= GAMERUN;
              codeBreak <= 1'b0;
            end
          end
        end
       DONE: 
       begin
         if (start) begin
           state <= GAMERUN;
           reset_timer <= 1'b1;
           timer_enable <= 1'b1;
           gameStart <= 1'b0;
         end else state <= DONE;
       end
      endcase;
    end

function [3:0] remapLED;
  input [3:0] in;
  
  case(in)
    4'b0001, 4'b0010, 4'b0100, 4'b1000: remapLED = 4'b0001;
    4'b0011, 4'b0101, 4'b1001, 4'b0110, 4'b1010, 4'b1100: remapLED = 4'b0011; 
    4'b0111, 4'b1101, 4'b1110, 4'b1011: remapLED = 4'b0111;
    4'b1111: remapLED = 4'b1111;
    default: remapLED = 4'b0000;
  endcase
endfunction

                          
endmodule
