`timescale 1ns / 1ps

module labeller # (
     parameter IMG_W = 1280, 
     parameter IMG_H = 720,
     parameter BLANK_W = 1980,
     parameter BLANK_H = 750,
     parameter LABELS_NUM = 63,
     parameter WIDTH = $clog2(LABELS_NUM + 1)
     )(
        input clk,
        input de,
        input reset,
        input hsync,
        input vsync,
        input pixel,
        input move,   //MOV
        
        output pixel_out, 
        output move_out, //MOV
        output[WIDTH - 1:0] label,
        output[WIDTH - 1:0] labelMerged,
        output newL,
        output mergeL,
        output[7:0] red,
        output[7:0] green,
        output[7:0] blue,
        output de_out,
        output hsync_out,
        output vsync_out,
        output reg[1:0] flags = 2'b00 // debug flags[0] -> max stack reached; flags[1] -> FREE TO USE
    );

reg[WIDTH - 1:0] A = 0; 
reg[WIDTH - 1:0] B = 0; 
reg[WIDTH - 1:0] C = 0; 
reg[WIDTH - 1:0] L = 0; 
reg[WIDTH - 1:0] Lmerged = 0;
reg[WIDTH - 1:0] Ldata = 0;
reg[1:0] counter = 2'b0;
reg[10:0] blankCounter = 11'b0;
reg blankUpdate = 1'b0;

// DEBUG
reg m = 0;
reg n = 0;
reg a = 0;
wire m_d;
wire n_d;
wire a_d;
//

wire newLabel_d;
wire newLabel_d2;
wire mergeLabel_d;
wire[WIDTH - 1:0] bufferOut;

wire eof = (contextD[0] & ~vsync) ? 1'b1 : 1'b0;
wire context = pixel & de;
wire newLabel = (context && B == 0 && A == 0 && C == 0 && L == 0) ? 1'b1 : 1'b0;
wire mergeAC = (context && B == 0 && A > 0 && C > 0 && A != C) ? 1'b1 : 1'b0;
wire mergeDC = (context && B == 0 && L > 0 && C > 0 && L != C) ? 1'b1 : 1'b0;

wire mergeLabel  = mergeAC | mergeDC;

wire bgDetected = (~context & (contextD[2] & contextD[3]));

wire[WIDTH - 1:0] bufferIn = L;

reg[WIDTH - 1:0] mergeAddress = 0;
reg[WIDTH - 1:0] mergeData = 0;
reg[WIDTH - 1:0] chainAddress = 0;
reg[WIDTH - 1:0] chainData = 0;

reg[WIDTH - 1:0] prevChainAddress = 0;
reg[WIDTH - 1:0] prevChainData = 0;

wire[4:0] contextD; // MOV

reg transition = 1'b0;
reg transition2 = 1'b0;

reg clearStack = 0;
reg updateStack = 0;
reg[9:0] labelPtr = 0;
reg[9:0] addressToReset = 0;
wire[10:0] labelTop;

reg[10:0] tempStack[31:0];
reg[4:0] tempPtr = 0;

always @(posedge clk)
begin
    if(reset | eof)
    begin
		A <= 0;
		B <= 0;
		C <= 0;
		L <= 0;
		mergeAddress <= 0;
		mergeData <= 0;
		chainAddress <= 0;
		chainData <= 0;
		flags <= 0;
		clearStack <= 1'b1;
		addressToReset <= 0;
    end
	else
    begin
		L <= 0;
		mergeAddress <= 0;
		mergeData <= 0;
		chainAddress <= 0;
		chainData <= 0;
		A <= B;
		B <= Bmux;
		C <= Cmux;

		m <= 1'b0;
		n <= 1'b0;
		a <= 1'b0;
		
		if(Lmerged > 0)
		begin
			counter <= counter + 1'b1;
			if(counter == 2'b01)
			begin
				Lmerged <= 0;
				Ldata <= 0;
				counter <= 2'b0;
			end
		end
		
		if(trueMerge)
		begin
			tempStack[tempPtr] <= mergeAddress_d;
			tempPtr <= tempPtr + 1'b1;
		end
		
		if(de)
		begin
			blankCounter <= 11'b0;
			
			if(newLabel)
			begin
				n <= 1'b1;
				if(labelPtr < LABELS_NUM)
				begin
					labelPtr <= labelPtr + 1'b1;
					L <= labelTop;
					mergeAddress <= labelTop;
					mergeData <= labelTop;
				end
				else
				begin
					flags[0] <= 1'b1;

					L <= labelTop;
					mergeAddress <= labelTop;
					mergeData <= labelTop;
				end	 
			end
			else if(mergeAC) 
			begin
				 m <= 1'b1;
				 if(A > C)
				 begin
					  L <= C;
					  mergeAddress <= A;
					  chainAddress <= A;
					  mergeData <= C;
					  chainData <= C;
					  
					  Lmerged <= A;
					  Ldata <= C;
				 end
				 else
				 begin
					  L <= A;
					  B <= A;
					  
					  if(lutOut == C)
							C <= A;
						
					  mergeAddress <= C;
					  mergeData <= A;
					  
					  Lmerged <= C;
					  Ldata <= A;
				 end
			end
			else if(mergeDC)
			begin
				 m <= 1'b1;
				 
				 if(L > C)
				 begin
					  L <= C;
					  mergeAddress <= L;
					  chainAddress <= L;
					  mergeData <= C;
					  chainData <= C;
					  Lmerged <= L;
					  Ldata <= C;
				 end
				 else
				 begin
					  L <= L;
					  B <= L;
					  
					  if(lutOut == C)
							C <= L;

					  mergeAddress <= C;
					  mergeData <= L;
					  
					  Lmerged <= C;
					  Ldata <= L; 
				 end
			end
			else if(pixel && L > 0)
			begin
				 a <= 1'b1;
				 L <= L;
			end
			else if(pixel && A > 0)
			begin
				 a <= 1'b1;
				 L <= A;
			end
			else if(pixel && B > 0)
			begin
				 a <= 1'b1;
				 L <= B;
			end
			else if(pixel && C > 0)
			begin
				 a <= 1'b1;
				 L <= C;
			end
		end
		else // de == 1'b0
		begin
			if(clearStack)
			begin
				addressToReset <= addressToReset + 1'b1;
				if(addressToReset == LABELS_NUM)
				begin
					clearStack <= 1'b0;
					labelPtr <= 0;
				end
			end
		
			if(contextD[2]) //prev_de == 1'b1
			begin
				blankCounter <= blankCounter + 1'b1;
				blankUpdate <= 1'b1;
				transition <= ~transition;
				if(tempPtr > 0)
				begin
					updateStack <= 1'b1;
					tempPtr <= tempPtr - 1'b1;
					labelPtr <= labelPtr - 1'b1;
				end
			end
			if(blankUpdate)
			begin
				if(tempPtr == 0)
					updateStack <= 1'b0;
				else
				begin
					labelPtr <= labelPtr - 1'b1;
					tempPtr <= tempPtr - 1'b1;
				end
					
				blankCounter <= blankCounter + 1'b1;
				if(blankCounter == (BLANK_W - IMG_W - 4))
				begin
                    transition2 <= ~transition2;
					blankUpdate <= 1'b0;
					blankCounter <= 11'b0;
				end
			end
		end	 
	end
end 

always @(posedge clk)
begin
    if(reset)
    begin
        prevChainAddress <= 0;
        prevChainData <= 0;
    end
    else
    begin
        if(prevChainAddress == stackOut[WIDTH - 1:0] && stackOut[WIDTH - 1:0] > 0 )
        begin
            {prevChainAddress, prevChainData} <= {stackOut[2*WIDTH - 1:WIDTH], prevChainData};
        end
        else
            {prevChainAddress, prevChainData} <= stackOut;
    end
end    

wire weaL = updateStack | clearStack;
wire[9:0] stackLAddr = clearStack ? addressToReset : labelPtr;
wire[10:0] reuseLabel = updateStack ? tempStack[tempPtr] : addressToReset + 1'b1;

stack2 labelStack (
  .clka(clk), // input clka
  .wea(weaL), // input [0 : 0] wea
  .addra(stackLAddr), // input [9 : 0] addra
  .dina(reuseLabel), // input [10 : 0] dina
  .douta(labelTop) // output [10 : 0] douta
);

wire chainOccured = (chainAddress > 0) ? 1'b1 : 1'b0;
wire[2*WIDTH - 1:0] stackOut;

wire blank = (blankCounter > 11'b0) ? 1'b1 : 1'b0;

chainStack # (
    .WIDTH(WIDTH)
    ) stack (
    .clk(clk),
    .rst(reset),
    .ce(1'b1),
    .din({chainAddress, chainData}),
    .dout(stackOut),
    .push(chainOccured),
    .pop(blank)
    );


delay_BRAM # (
    .WIDTH(WIDTH),
    .BRAM_SIZE(BLANK_W - 5)
    ) rowBuffer (
    .clk(clk), 
    .rst(reset),
    .ce(1'b1), 
    .din(bufferIn), 
    .dout(bufferOut)
    );
    
wire[WIDTH - 1:0] lutIn = blank ? chainLabel : bufferOut;
wire[WIDTH - 1:0] lutOut = (transition2 ^ blank) ? lutOut1 : lutOut2;
wire[WIDTH - 1:0] lutOut1;
wire[WIDTH - 1:0] lutOut2;

wire[WIDTH - 1:0] Bmux = (Lmerged > 0 && C == Lmerged) ?  Ldata : C;
wire[WIDTH - 1:0] Cmux = (Lmerged > 0 && lutOut == Lmerged) ?  Ldata : lutOut;

wire[WIDTH - 1:0] resolvedChain = (prevChainAddress == stackOut[WIDTH - 1:0] && stackOut[WIDTH - 1:0] > 0)? prevChainData : lutOut;
wire[2*WIDTH - 1:0] chainInfo = {prevChainAddress, resolvedChain};

wire[WIDTH - 1:0] chainLabel = (prevChainAddress == stackOut[WIDTH - 1:0]) ? resolvedChain : stackOut[WIDTH - 1:0];

wire[2*WIDTH - 1:0] mergeMux = blank ? chainInfo : {mergeAddress, mergeData};
wire[2*WIDTH - 1:0] mergeMux1 = (~transition & bgDetected) ? {L, L} : mergeMux;
wire[2*WIDTH - 1:0] mergeMux2 = (transition & bgDetected) ? {L, L} : mergeMux;

wire wea = (mergeMux > 0) ? 1'b1 : 1'b0;
wire wea1 = transition ? (wea & ~(newLabel_d | chainOccured)) : (wea | bgDetected);
wire wea2 = transition ? (wea | bgDetected) : (wea & ~(newLabel_d | chainOccured));
wire weaM = (mergeChainAddr > 0) ? 1'b1 : 1'b0;

wire[WIDTH - 1:0] prevMerged;
wire[WIDTH - 1:0] mergeChainAddr = newLabel ? labelTop : Lmerged;
wire[WIDTH - 1:0] mergeChainData = newLabel ? 0 : Ldata;

wire trueMerge = (mergeLabel_d && prevMerged != Ldata);

lineMergeControl mergeChain (
    .clka(clk), // input clka
    .wea(weaM), // input [0 : 0] wea
    .addra({10'b0 + mergeChainAddr}), // input [9 : 0] addra
    .dina({11'b0 + mergeChainData}), // input [10 : 0] dina
    .douta(prevMerged) // output [10 : 0] douta
);

lutControl  # (
    .WIDTH(WIDTH)
    ) LUT (
    .clk(clk),
    .wea(wea1), 
    .addra(mergeMux1[2*WIDTH - 1:WIDTH]), 
    .dina(mergeMux1[WIDTH - 1:0]), 
    .addrb(lutIn), 
    .doutb(lutOut1),
    .rst(reset)
    );

lutControl  # (
    .WIDTH(WIDTH)
    ) LUT_2 (
    .clk(clk),
    .wea(wea2), 
    .addra(mergeMux2[2*WIDTH - 1:WIDTH]), 
    .dina(mergeMux2[WIDTH - 1:0]), 
    .addrb(lutIn), 
    .doutb(lutOut2),
    .rst(reset)
    );

wire[WIDTH - 1 : 0] L_d;
wire[WIDTH - 1 : 0] mergeAddress_d;
wire[4:0] contextD_d;   // MOV

delay_line #(
        .N(6),  // MOV
        .DELAY(1)
    )del1(
    .clk(clk),
    .rst(reset),
    .idata({move, pixel, de, hsync, vsync, newLabel}), //MOV
    .odata({contextD, newLabel_d})
);

delay_line #(
		.N(1 + 1),
		.DELAY(2)
    )del2(
    .clk(clk),
    .rst(reset),
    .idata({mergeLabel, newLabel}), 
    .odata({mergeLabel_d, newLabel_d2})
);

delay_line #(
		.N(2*WIDTH + 5), // MOV
		.DELAY(1)
    )del1_1(
    .clk(clk),
    .rst(reset),
    .idata({ L, mergeAddress, contextD} ), 
    .odata({ L_d, mergeAddress_d, contextD_d})
);

delay_line #(
		.N(3 + 1),
		.DELAY(1)
    )del_DEBUG(
    .clk(clk),
    .rst(reset),
    .idata({m, n, a} ), 
    .odata({m_d, n_d, a_d})
);



assign label = L_d;
assign pixel_out = contextD_d[3];
assign move_out = contextD_d[4];   //MOV

assign newL = newLabel_d2;
assign mergeL = trueMerge;

assign labelMerged = mergeAddress_d;

assign de_out = contextD_d[2];
assign hsync_out = contextD_d[1];
assign vsync_out = contextD_d[0];

assign red = (m_d) ? 8'd255 : 8'd0;
assign green =  (n_d) ? 8'd255 : 8'd0;
assign blue = (a_d) ? 8'd255 : 8'd0;

endmodule
