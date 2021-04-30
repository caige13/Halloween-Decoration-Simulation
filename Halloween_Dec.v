`define ON        '4b0000 //00=system, 00=ON
`define RESET     '4b0001 //00=system, 01=Reset
`define GREEN     '4b0100 //01=Color, 00=GREEN
`define PURPLE    '4b0101 //01=Color, 01=PURPLE
`define ORANGE    '4b0110 //01=Color, 10=ORANGE
`define SCREAMING '4b1000 //10=Sound, 00=SCREAMING
`define CACKLING  '4b1001 //10=Sound, 01=CACKLING
`define BOO       '4b1010 //10=Sound, 10=BOO
`define BOO       '4b1010 //10=Sound, 10=BOO
`define WAVEHANDS '4b1100 //11=Movement/Effect, 00=WAVEHANDS
`define MOVEJAW   '4b1101 //11=Movement/Effect, 01=MOVEJAW
`define FOG       '4b1110 //11=Movement/Effect, 10=FOG

module Mux(channels,select, b);
input [3:0][3:0]channels;
input [1:0] select;
output [3:0] b;
wire[3:0][3:0] channels;
reg [3:0] b;
always @(*)
begin
 b=channels[select]; 
end
endmodule

module DFF(clk,in,out);
	parameter n=2;//width
	input clk;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;

	always @(posedge clk)
	out = in;
endmodule

//HALF-ADDER
module Add_half (input a, b,  output c_out, sum);
   xor G1(sum, a, b);	 
   and G2(c_out, a, b);
endmodule

//FULL-ADDER
module Add_full (input a, b, c_in, output c_out, sum);
   wire w1, w2, w3;	 
   Add_half M1 (a, b, w1, w2);
   Add_half M0 (w2, c_in, w3, sum);
   or (c_out, w1, w3);
endmodule

//ADD operation
module ADDER(inputA,inputB,outputC,carry);
//---------------------------------------
input [1:0] inputA;
input [1:0] inputB;
wire [1:0] inputA;
wire [1:0] inputB;
//---------------------------------------
output [1:0] outputC;
output carry;
reg [1:0] outputC;
reg carry;
//---------------------------------------

wire [1:0] S;
wire [1:0] Cin;
wire [1:0] Cout;
//Link the wires between the Adders
assign Cin[0]=0;
assign Cin[1]=Cout[0];

//Declare and Allocate 4 Full adders
Add_full FA[1:0] (inputA,inputB,Cin,Cout,S);

always @(*)
begin
 carry=Cout[1];
 outputC=S;
end

endmodule

module breadboard(Data, A, C);
input [3:0] [3:0] Data;
input [1:0] A;
//input [1:0] select;
wire [3:0][3:0]channels;
wire [3:0]Data0 = Data[0];
wire [3:0]Data1 = Data[1];
wire [3:0]Data2 = Data[2];
wire [3:0]Data3 = Data[3];
wire [1:0] A;
wire [1:0] select;
wire [1:0] sum;
wire [3:0] b;
wire [1:0] S;

output [1:0] C;
reg [1:0] C;

//Registers for ADDER
reg [1:0] regA;
reg [1:0] regB = 01;
reg [1:0] next;

ADDER adds(regA, regB, sum, carry);
DFF accum(clk, next, select);
Mux mux1(channels,select,b);

assign channels[0]=Data0;//OpCode 1
assign channels[1]=Data1;//OpCode 2
assign channels[2]=Data2;//OpCode 3
assign channels[3]=Data3;//OpCode 4

always @(*)
begin
	regA = A;
	
	assign C=b
	assign next = sum;
end
endmodule

module testbench();
	reg clk;
	//reg [1:0] select;
	reg [3:0] [3:0] Data;
	reg [1:0] inputA;
	wire [1:0] outputC;
	
	breadboard bb8(Data, inputA, outputC);
	
	//CLOCK
   initial begin //Start Clock Thread
     forever //While TRUE
        begin //Do Clock Procedural
          clk=0; //square wave is low
          #7; //half a wave is 5 time units
          clk=1;//square wave is high
          #7; //half a wave is 5 time units
        end
    end
	
	initial begin //Start Output Thread
	forever
         begin
		 $display("(select:%2b)(Output:%4b)(regA:%2b)(data:%16b)",bb8.select, bb8.b, bb8.regA, bb8.Data0);
		 #14;
		 end
	end
	
	initial begin//Start Stimulous Thread
	#8
	//select = 2'b00;
	Data = 16'b0000111101011010;
	#56
	//select = 2'b01;
	Data = 16'b0000111101011010;
	#56
	//select = 2'b10;
	Data = 16'b0000111101011010;
	#56
	//select = 2'b11;
	Data = 16'b0000111101011010;
	#56
	
	$finish;
	end
endmodule
