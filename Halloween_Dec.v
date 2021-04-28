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


//Accumulator DFF
//module DFF(clk, in, out);

//endmodule

module Mux(channels,select,b);
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

module breadboard(Data, select);
input [3:0] [3:0] Data;
input [1:0] select;
wire [3:0][3:0]channels;
wire [3:0]Data0 = Data[0];
wire [3:0]Data1 = Data[1];
wire [3:0]Data2 = Data[2];
wire [3:0]Data3 = Data[3];
wire [1:0] select;
wire [3:0] b;

Mux mux1(channels,select,b);
assign channels[0]=Data0;//OpCode 1
assign channels[1]=Data1;//OpCode 2
assign channels[2]=Data2;//OpCode 3
assign channels[3]=Data3;//OpCode 4

endmodule

module testbench();
	reg [1:0] select;
	reg [3:0] [3:0] Data;
	
	breadboard bb8(Data, select);
	
	initial begin //Start Output Thread
	forever
         begin
		 $display("(OPCODE:%4b)",bb8.b);
		 #10;
		 end
	end
	
	initial begin//Start Stimulous Thread
	#6
	select = 2'b00;
	Data = 16'b0000111101011010;
	#10
	select = 2'b01;
	Data = 16'b0000111101011010;
	#10
	select = 2'b10;
	Data = 16'b0000111101011010;
	#10
	select = 2'b11;
	Data = 16'b0000111101011010;
	#10
	
	$finish;
	end
endmodule
