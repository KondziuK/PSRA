`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:47:41 03/03/2016 
// Design Name: 
// Module Name:    delay 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module delay #
	(
	parameter N = 8
	)
	(
	input clk,
	input rst,
	input [N-1:0]d,
	output [N-1:0]q
    );

reg [N-1:0]delay = 0;

always @(posedge clk)
begin
    if(rst)
        delay <= 0;
    else
        delay <= d;
end

assign q = delay;

endmodule
