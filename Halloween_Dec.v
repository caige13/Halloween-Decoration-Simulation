`define ON        '4b0000 //00=System, 00=ON
`define RESET     '4b0001 //00=System, 01=Reset
`define NOOP      '4b0010 //00=System, 10=NOOP
`define FOG       '4b0011 //11=System, 11=FOG
`define GREEN     '4b0100 //01=Color, 00=GREEN
`define PURPLE    '4b0101 //01=Color, 01=PURPLE
`define ORANGE    '4b0110 //01=Color, 10=ORANGE
`define SCREAMING '4b1000 //10=Sound, 00=SCREAMING
`define CACKLING  '4b1001 //10=Sound, 01=CACKLING
`define BOO       '4b1010 //10=Sound, 10=BOO
`define WAVEHANDS '4b1100 //11=Movement/Effect, 00=WAVEHANDS
`define MOVEJAW   '4b1101 //11=Movement/Effect, 01=MOVEJAW


module decoder_4x16 (d_out, d_in);

   output [15:0] d_out;
   input [3:0]   d_in;
   reg d_out;
   parameter tmp = 16'b0000_0000_0000_0001;
always @ (d_in)
	   d_out = (d_in == 4'b0000) ? tmp   :
               (d_in == 4'b0001) ? tmp<<1:
               (d_in == 4'b0010) ? tmp<<2:
               (d_in == 4'b0011) ? tmp<<3:
               (d_in == 4'b0100) ? tmp<<4:
               (d_in == 4'b0101) ? tmp<<5:
               (d_in == 4'b0110) ? tmp<<6:
               (d_in == 4'b0111) ? tmp<<7:
               (d_in == 4'b1000) ? tmp<<8:
               (d_in == 4'b1001) ? tmp<<9:
               (d_in == 4'b1010) ? tmp<<10:
               (d_in == 4'b1011) ? tmp<<11:
               (d_in == 4'b1100) ? tmp<<12:
               (d_in == 4'b1101) ? tmp<<13:
               (d_in == 4'b1110) ? tmp<<14:
               (d_in == 4'b1111) ? tmp<<15: 16'bxxxx_xxxx_xxxx_xxxx;

endmodule

///////////////////////////////////
module OR_1(output Y, input A, B);
   assign Y = A | B; 
endmodule 

///////////////////////////////////
module NOR_1(a, out);
input [3:0] a;
output out ;
reg out ;
    always @(a)
    begin
    out = ~(a[0]|a[1]|a[2]|a[3]);
    end
endmodule

///////////////////////////////////
module fulladder (input [1:0] a,  
                  input [1:0] b,    
                  output reg c_out,  
                  output reg [1:0] sum);  
  
  always @ (a or b) begin  
    {c_out, sum} = a + b;  
  end  
endmodule  

///////////////////////////////////
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

///////////////////////////////////
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

///////////////////////////////////
module breadboard( clk, B, data);
input clk; 
input [3:0] [3:0] data;
input [1:0]B;
input norout;
input orout;
wire clk;
wire [3:0][3:0]channels;
wire [3:0]Data0 = data[0];
wire [3:0]Data1 = data[1];
wire [3:0]Data2 = data[2];
wire [3:0]Data3 = data[3];
wire [3:0] opcode;
wire [1:0] wireB;
assign wireB=B;

reg [1:0] regA;
wire [1:0] addOut;

wire [1:0] cur;
wire norout;
wire orout;
wire [15:0] d_out;

decoder_4x16 decoder(d_out, opcode);
NOR_1 nor1(Data0, norout);
OR_1 or1(orout, norout, d_out[0]);
fulladder FA(regA,wireB,carry,addOut);
DFF ACC1 (orout,clk,addOut,cur);
Mux mux1(channels,cur,opcode);

	
assign channels[0]=Data0;//OpCode 1
assign channels[1]=Data1;//OpCode 2
assign channels[2]=Data2;//OpCode 3
assign channels[3]=Data3;//OpCode 4

always @(*)
begin
 regA=cur;
end
endmodule

///////////////////////////////////
module testbench();
   reg [1:0] inputA;
   reg [1:0] inputB;
   reg [3:0] [3:0] data;
   reg [1:0] B = 01;
   reg clk;
    
	breadboard bb8( clk, B, data);
	
	
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
	
	initial begin
      	forever begin
       		case(bb8.d_out)
				16'b0000000000001000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) ~~~~Fog~~~~~", clk, data, bb8.opcode);
		        16'b0000000000010000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) Green", clk,data, bb8.opcode);
		        16'b0000000000100000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) Purple", clk,data, bb8.opcode);
		        16'b0000000001000000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) Orange", clk,data, bb8.opcode);
		        16'b0000000100000000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) AAAAAARRGGGGHH!!!", clk,data, bb8.opcode);
		        16'b0000001000000000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) Nyehehehe!!", clk,data, bb8.opcode);
		        16'b0000010000000000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) BOO!", clk,data, bb8.opcode);		        
		        16'b0010000000000000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) *Jaw moves*", clk,data, bb8.opcode);
		        16'b0001000000000000 : $display("(clk: %1b)(data: %16b)(opcode: %4b) *Wave hands*", clk,data, bb8.opcode);
	    	endcase
	    	#10;
      	end
	end
	
	/*Channel 0 in MUX is the first 4 bits from the right
	Channel 1 is the 4 bits to the left of Channel 0's bits, etc */
	initial begin//Start Stimulous Thread
	//Turn on
	data = 16'b0000000000000000;
	#6
	//Button 1: Fog, Green, Purple, Screaming
	data = 16'b0011010001011000;
	#40
	//Button 2: Orange, Cackling, Move Jaw, Wave Hands
	data = 16'b0110100111011100;
	#40
	//Button 3: BOO, Green, Reset, NO-OP
	data = 16'b1010010000010010;
	#40
	
	
	$finish;
	end
endmodule
