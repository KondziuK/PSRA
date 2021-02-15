`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:50:29 03/03/2016 
// Design Name: 
// Module Name:    delay_line 
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
module delay_line #
	(
		parameter N = 8,
		parameter DELAY = 4
	)
	(
		input clk,
		input rst,
		input [N-1:0]idata,
		output [N-1:0]odata
    );

wire [N-1:0] lines[DELAY:0];

assign lines[0] = idata;

genvar i;
generate

for(i = 0; i < DELAY; i = i + 1)
begin
	delay #
	(
		.N(N)
	)
	delay_i 
	(
		.clk(clk),
		.rst(rst),
		.d(lines[i]),
		.q(lines[i+1])
	);
end

endgenerate

assign odata = lines[DELAY];

endmodule
