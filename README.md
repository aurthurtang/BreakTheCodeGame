# BreakTheCodeGame
This is a game created using Nexys A7 FPGA board.  The goal of the game is to guess the code within time limit.  The time limit can be change in the definition file. 
Default is set to 3 minutes.  The code is a 4 digits code from 0 to 15.  The player will be using the switches to guess the code.  There are total of 16 switches, 
4 per digit.  With each guess, the game will return 2 hints (A and B). A is represent number of correct digit(s) in your guess, and B is represent number of correct 
digit(s) in the right location.  When the guess is wrong or the timer is expired, the RGB LED will give red light.  When the player guesses the correct code, the RGB LED 
will give green light.  LED[15:11] is a one-hot indicator for number of correct digit(s); 1 correct digit when 1 light is on and so on.  LED[3:0] is a one-hot indicator 
for number of correct digit(s) in correct location.  

