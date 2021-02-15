`timescale 1ns / 1ps

module lutControl # (
	parameter WIDTH = 10
    )
    (
	input rst,
	input clk, // input clka
	input wea, // input [0 : 0] wea
    input[WIDTH - 1 : 0] addra, // input [9 : 0] addra
    input[WIDTH - 1 : 0] dina, // input [9 : 0] dina
	input[WIDTH - 1 : 0] addrb, // input [9 : 0] addrb
	output[WIDTH - 1 : 0] doutb // output [9 : 0] doutb
);

wire[9:0] doutb_w;

mergeControl lutMemory (
    .clka(clk),
    .wea(wea), 
    .addra(10'b0 + addra), 
    .dina(10'b0 + dina), 
    .clkb(clk),
    .addrb(10'b0 + addrb), 
    .doutb(doutb_w),
    .rstb(rst)
    );
  
assign doutb = doutb_w[WIDTH - 1:0];

endmodule