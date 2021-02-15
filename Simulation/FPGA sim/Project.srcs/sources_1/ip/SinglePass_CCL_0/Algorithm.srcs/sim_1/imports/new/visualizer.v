`timescale 1ns / 1ps

module visualization # (
        parameter IMAGE_WIDTH = 1280, 
        parameter IMAGE_HEIGHT = 720,
        parameter OBJECTS = 7,
        parameter MIN_AREA = 1,
        parameter WIDTH = $clog2(OBJECTS + 1)
     )(
        input[127:0] params,
        input pixel,
        input rx_hsync,
        input rx_vsync,
        input rx_de,
        input rx_pclk,
       
        output[7:0] tx_red,
        output[7:0] tx_green,
        output[7:0] tx_blue,
        output tx_hsync,
        output tx_vsync,
        output tx_de
    );


wire isTracked_in = params[125];
wire[10:0] centerX_in = params[104:94];
wire[10:0] centerY_in = params[74:64];
wire[19:0] field = params[63:44];
wire[10:0] xMax_in = params[43:33];
wire[10:0] xMin_in = params[32:22];
wire[10:0] yMax_in = params[21:11];
wire[10:0] yMin_in = params[10:0];

reg[WIDTH - 1:0] i = 0;

wire[10:0] posX;
wire[10:0] posY;

reg prev_vsync = 0;

wire transition = rx_vsync & ~prev_vsync;

wire prev_pixel;

reg[OBJECTS - 1:0] box_pixel = 0;
reg[OBJECTS - 1:0] center_pixel = 0;
reg[OBJECTS - 1:0] tracked_pixel = 0;

reg[10:0] posX_d [OBJECTS - 2:0];
reg[10:0] posY_d [OBJECTS - 2:0];

reg[10:0] xMax [OBJECTS - 1:0];
reg[10:0] xMin [OBJECTS - 1:0];
reg[10:0] yMax [OBJECTS - 1:0];
reg[10:0] yMin [OBJECTS - 1:0];

reg[10:0] centerX [OBJECTS - 1:0];
reg[10:0] centerY [OBJECTS - 1:0];

reg isTracked [OBJECTS - 1:0];

reg[WIDTH - 1:0] ptr = 0;

position # (
		.IMG_H(IMAGE_HEIGHT), 
		.IMG_W(IMAGE_WIDTH) 
	) getPos	(
		.clk(rx_pclk),
		.vsync(~rx_vsync),
		.de(rx_de),
		.posX(posX),
		.posY(posY)
	);

always @(posedge rx_pclk)
begin
	prev_vsync <= rx_vsync;
	
	if(transition)
		ptr <= 0;
		
	if(field >= MIN_AREA)
	begin
		if(ptr < OBJECTS)
		begin
			{xMax[ptr],  xMin[ptr],  yMax[ptr],  yMin[ptr],  centerX[ptr],   centerY[ptr],   isTracked[ptr]} <= 
			{xMax_in,    xMin_in,    yMax_in,    yMin_in,    centerX_in,     centerY_in,     isTracked_in};

			ptr <= ptr + 1;
		end
	end
	
	posX_d[0] <= posX;
	posY_d[0] <= posY;
	
	if((((posX == xMin[0] || posX == xMax[0]) && (posY >= yMin[0] && posY <= yMax[0]))|| 
		((posY == yMin[0] || posY == yMax[0]) && (posX >= xMin[0] && posX <= xMax[0]))) && ptr > 0)
	begin
        if(isTracked[0])
            tracked_pixel[0] <= 1'b1;
        else  
            box_pixel[0] <= 1'b1;
	end
	else
	begin
        tracked_pixel[0] <= 1'b0;
		box_pixel[0] <= 1'b0;
	end
	
	if(((posX == centerX[0] || posX == (centerX[0] - 1) || posX == (centerX[0] + 1)) && 
		(posY == centerY[0] || posY == (centerY[0] - 1) || posY == (centerY[0] + 1))) && ptr > 0)
		center_pixel[0] <= 1'b1;
	else
		center_pixel[0] <= 1'b0;
	
	for (i = 0; i < OBJECTS - 2; i = i + 1)
	begin
		if((((posX_d[i] == xMin[i + 1] || posX_d[i] == xMax[i + 1]) && (posY_d[i] >= yMin[i + 1] && posY_d[i] <= yMax[i + 1])) || 
			((posY_d[i] == yMin[i + 1] || posY_d[i] == yMax[i + 1]) && (posX_d[i] >= xMin[i + 1] && posX_d[i] <= xMax[i + 1]))) && ptr > i + 1)
		begin
			if(isTracked[i + 1])
			    tracked_pixel[i + 1] <= 1'b1;
			else
			    box_pixel[i + 1] <= 1'b1;
        end
		else
		begin
            tracked_pixel[i + 1] <= tracked_pixel[i];
			box_pixel[i + 1] <= box_pixel[i];
		end
		
		if(((posX_d[i] == centerX[i + 1] || posX_d[i] == (centerX[i + 1] - 1) || posX_d[i] == (centerX[i + 1] + 1)) && 
			(posY_d[i] == centerY[i + 1] || posY_d[i] == (centerY[i + 1] - 1) || posY_d[i] == (centerY[i + 1] + 1))) && ptr > i + 1)
			center_pixel[i + 1] <= 1'b1;
		else
			center_pixel[i + 1] <= center_pixel[i];
		
		posX_d[i + 1] <= posX_d[i];
		posY_d[i + 1] <= posY_d[i];
	end
	
	if((((posX_d[OBJECTS - 2] == xMin[OBJECTS - 1] || posX_d[OBJECTS - 2] == xMax[OBJECTS - 1]) && (posY_d[OBJECTS - 2] >= yMin[OBJECTS - 1] && posY_d[OBJECTS - 2] <= yMax[OBJECTS - 1]))|| 
		((posY_d[OBJECTS - 2] == yMin[OBJECTS - 1] || posY_d[OBJECTS - 2] == yMax[OBJECTS - 1]) && (posX_d[OBJECTS - 2] >= xMin[OBJECTS - 1] && posX_d[OBJECTS - 2] <= xMax[OBJECTS - 1]))) && ptr > OBJECTS - 1)
    begin
        if(isTracked[OBJECTS - 1])
            tracked_pixel[OBJECTS - 1] <= 1'b1;
        else
            box_pixel[OBJECTS - 1] <= 1'b1;
    end
	else
	begin
        tracked_pixel[OBJECTS - 1] <= tracked_pixel[OBJECTS - 2];
		box_pixel[OBJECTS - 1] <= box_pixel[OBJECTS - 2];
	end
	
	if(((posX_d[OBJECTS - 2] == centerX[OBJECTS - 1] || posX_d[OBJECTS - 2] == (centerX[OBJECTS - 1] - 1) || posX_d[OBJECTS - 2] == (centerX[OBJECTS - 1] + 1)) && 
		(posY_d[OBJECTS - 2] == centerY[OBJECTS - 1] || posY_d[OBJECTS - 2] == (centerY[OBJECTS - 1] - 1) || posY_d[OBJECTS - 2] == (centerY[OBJECTS - 1] + 1))) && ptr > OBJECTS - 1)
		center_pixel[OBJECTS - 1] <= 1'b1;
	else
		center_pixel[OBJECTS - 1] <= center_pixel[OBJECTS - 2];
	
end

delay_line #(
        .N(4),
        .DELAY(OBJECTS)
    )del11(
        .clk(rx_pclk),
        .rst(),
        .idata({pixel, rx_de, rx_hsync, rx_vsync}), 
        .odata({prev_pixel, tx_de, tx_hsync, tx_vsync})
);


assign tx_red =   center_pixel[OBJECTS - 1] ? 8'd128   : 
                (tracked_pixel[OBJECTS - 1] ? 8'd0     : 
                    (box_pixel[OBJECTS - 1] ? 8'd255   : 
                                (prev_pixel ? 8'd255   : 0)));
                           
assign tx_green = center_pixel[OBJECTS - 1] ? 8'd0     : 
                (tracked_pixel[OBJECTS - 1] ? 8'd255   : 
                    (box_pixel[OBJECTS - 1] ? 8'd0     : 
                                (prev_pixel ? 8'd255   : 0)));
                             
assign tx_blue =  center_pixel[OBJECTS - 1] ? 8'd255   : 
                (tracked_pixel[OBJECTS - 1] ? 8'd0     : 
                    (box_pixel[OBJECTS - 1] ? 8'd0     : 
                                (prev_pixel ? 8'd255   : 0)));


endmodule
