`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2015 22:42:14
// Design Name: 
// Module Name: delayLinieBRAM_WP
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


module delayLinieBRAM_WP
#(  parameter WIDTH = 36,
		      BRAM_SIZE_W = 13
 )(
    input clk,
    input rst,
    input ce,
    input [WIDTH-1:0] din ,
    output[WIDTH-1:0] dout,
    input [BRAM_SIZE_W-1:0] h_size
    );

	reg [BRAM_SIZE_W-1:0] position = 0;
	
	wire [35:0] dina;
	wire [35:0] douta;
	
	
	// RAM controller
	always @(posedge clk)
	begin
		if ( ce == 1'b1)
		begin
			if (rst == 1'b1)
			begin
				position <= 0;
			end
			else
			begin
				position <= position+1;
				if (position == h_size-2)
				begin
					position <= 0;
				end
			end		
		end	
	end
	
	
  	// Block RAM
       delayLineBRAM BRAM (
                .clka(clk), // input clka
                .wea(1'b1), // input [0 : 0] wea
                .addra(position), // input [9 : 0] addra
                .dina(dina), // input [10 : 0] dina
                .douta(douta) // output [10 : 0] douta
     );
	
	assign dina[WIDTH-1:0]=din;
	assign dout = douta[WIDTH-1:0];
	
endmodule
