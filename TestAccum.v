
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

module DFF(rst,clk,in,out);
	parameter n=2;//width
	input clk;
	input rst;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;

	always @(posedge clk or posedge rst)
	if (rst)  
        out = 0;  
    else  
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

module breadboard(on, clk, data);
input clk; 
input on;
input [3:0] [3:0] data;
wire clk;
wire on;
wire [3:0][3:0]channels;
wire [3:0]Data0 = data[0];
wire [3:0]Data1 = data[1];
wire [3:0]Data2 = data[2];
wire [3:0]Data3 = data[3];
wire [3:0] opcode;

reg [1:0] regA;
reg [1:0] regB=01;
wire [1:0] outputADD;

reg  [1:0] next;
wire [1:0] cur;

ADDER add1(regA,regB,outputADD,carry);
DFF ACC1 (on,clk,next,cur);
Mux mux1(channels,cur,opcode);

assign channels[0]=Data0;//OpCode 1
assign channels[1]=Data1;//OpCode 2
assign channels[2]=Data2;//OpCode 3
assign channels[3]=Data3;//OpCode 4

always @(*)
begin
 regA=cur;

 assign next=outputADD;
end
endmodule

module testbench();
   reg [1:0] inputA;
   reg [1:0] inputB;
   reg [3:0] [3:0] data;
   reg clk;
   reg rst;
   
	breadboard bb8(rst, clk, data);
	
	//CLOCK
   initial begin //Start Clock Thread
     forever //While TRUE
        begin //Do Clock Procedural
          clk=0; //square wave is low
          #5; //half a wave is 5 time units
          clk=1;//square wave is high
          #5; //half a wave is 5 time units
        end
    end
	
	initial begin //Start Output Thread
	forever
         begin
		 $display("(regA:%2b)(sum:%2b)(output:%4b)",bb8.regA, bb8.outputADD, bb8.opcode);
		 #10;
		 end
	end
	
	initial begin//Start Stimulous Thread
	#6
	rst=1;
	data = 16'b0000111101011010;
	#5
	rst=0;
	#30
	data = 16'b1111111111111111;
	#40
	
	$finish;
	end
endmodule