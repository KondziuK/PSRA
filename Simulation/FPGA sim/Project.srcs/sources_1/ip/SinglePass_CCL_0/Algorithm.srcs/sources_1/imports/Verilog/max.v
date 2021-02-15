`timescale 1ns / 1ps

module max # ( 
	parameter WIDTH = 11
	)
	(
	input [WIDTH - 1:0] in1,
	input [WIDTH - 1:0] in2,
	input [WIDTH - 1:0] in3,
	
	output [WIDTH - 1:0] result
	);


assign result = (in1 > in2) ? ((in1 > in3) ? in1 : in3) : ((in2 > in3) ? in2 : in3);

endmodule
