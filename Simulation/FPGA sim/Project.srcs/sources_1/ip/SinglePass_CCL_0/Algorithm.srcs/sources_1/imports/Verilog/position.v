`timescale 1ns / 1ps
 
module position # (
	parameter IMG_H = 576,
	parameter IMG_W = 720
	)
	(
	input clk,
	input vsync,
	input de,
	
	output [10:0] posX,
	output [10:0] posY	
    );
	
reg [10:0] tempPosX = 0;
reg [10:0] tempPosY = 0;
	
always @(posedge clk)
begin
	if(vsync == 1'b0)
	begin
		tempPosX <= 11'b0;
		tempPosY <= 11'b0;
	end
	else
	begin
		if(de == 1'b1)
			tempPosX <= tempPosX + 1;
			
		if(tempPosX == IMG_W - 1)
		begin
			tempPosX <= 11'b0;
			tempPosY <= tempPosY + 1;
			if(tempPosY == IMG_H - 1)
				tempPosY <= 11'b0;
		end
	end
end
	
assign posX = tempPosX;
assign posY = tempPosY;

endmodule
