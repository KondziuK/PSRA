`timescale 1ns / 1ps

module SinglePass_CCL # (
     parameter IMAGE_WIDTH = 1280, 
     parameter IMAGE_HEIGHT = 720,
     parameter FULL_WIDTH = 1650,
     parameter FULL_HEIGHT = 750,
     parameter MAX_LABELS_NUMBER = 1023
     )(
		input [23:0] rgb_in,
		input [23:0] move_in,  //MOV
		input rx_hsync,
		input rx_vsync,
        input rx_de,
        input rx_pclk,
		
		input immediateRead,
		
        output[1:0] led,
		output[159:0] params,  //MOV
		output validParams,
		
        output [23:0] rgb_out,
        output tx_hsync,
        output tx_vsync,
        output tx_de
    );

wire internalPixel;
wire internalMove;      //MOV

wire[9:0] L;
wire[9:0] Lmerged;
wire newLabel;
wire mergeLabel;

wire[7:0] algorithm_red;
wire[7:0] algorithm_green;
wire[7:0] algorithm_blue;
wire algorithm_de;
wire algorithm_vsync;
wire algorithm_hsync;

reg[8:0] address = 10'b0;
reg prev_vsync;

always @(posedge rx_pclk)
begin
	prev_vsync <= ~rx_vsync;
	
	if((~prev_vsync & ~rx_vsync) | immediateRead)
	begin
		address <= 0;
	end
		
	if(address < 511)
	begin
		address <= address + 1'b1;	
	end 
end

labeller #(
        .IMG_W(IMAGE_WIDTH),
        .IMG_H(IMAGE_HEIGHT),
        .BLANK_W(FULL_WIDTH),
        .BLANK_H(FULL_HEIGHT),
        .LABELS_NUM(MAX_LABELS_NUMBER)
	 ) 
	 algorithm 
	 (
        .clk(rx_pclk),
        .de(rx_de), 
		.reset(1'b0),
        .hsync(~rx_hsync), 
        .vsync(~rx_vsync), 
        .pixel(rgb_in[0]),
        .move(move_in[0]),
			
        .pixel_out(internalPixel),
        .move_out(internalMove),    //MOV
        .label(L),
        .labelMerged(Lmerged),
        .newL(newLabel),
        .mergeL(mergeLabel),		  
        .red(algorithm_red),
        .green(algorithm_green),
        .blue(algorithm_blue),
        .de_out(algorithm_de), 
        .hsync_out(algorithm_hsync), 
        .vsync_out(algorithm_vsync),		  
        .flags(led)
    ); 

extractor  #(
		.IMG_W(IMAGE_WIDTH),
		.IMG_H(IMAGE_HEIGHT),
		.LABELS_NUM(MAX_LABELS_NUMBER)
	) info (
		.clk(rx_pclk), 
		.reset(1'b0), 
		.L(L), 
		.Lmerged(Lmerged),
		.newLabel(newLabel),
		.mergeLabelIn(mergeLabel),
		.pixel(internalPixel), 
		.move(internalMove),             //MOV
		.de(algorithm_de), 
		.vsync(algorithm_vsync),
		.paramsAddr(address),
		.paramsOut(params),
		.containParams(validParams)
);

assign rgb_out = {algorithm_red,algorithm_green,algorithm_blue};
assign tx_hsync = ~algorithm_hsync;
assign tx_vsync = ~algorithm_vsync;
assign tx_de = algorithm_de;

endmodule
