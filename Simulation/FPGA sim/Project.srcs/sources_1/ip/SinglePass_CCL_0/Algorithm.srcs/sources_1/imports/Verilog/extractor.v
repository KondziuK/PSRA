`timescale 1ns / 1ps

module extractor # (
        parameter IMG_W = 1280, 
        parameter IMG_H = 720,
        parameter LABELS_NUM = 63,
        parameter WIDTH_L = $clog2(LABELS_NUM + 1),
        parameter WIDTH_W = $clog2(IMG_W + 1),
        parameter WIDTH_H = $clog2(IMG_H + 1)
     )(
        input clk,
        input reset,
        input[WIDTH_L - 1:0] L,
        input[WIDTH_L - 1:0] Lmerged,
        input newLabel,
        input mergeLabelIn,
        input pixel,
        input move, // MOV
        input de,
        input vsync,
        
        input[8:0] paramsAddr,
        output[159:0] paramsOut, // MOV
        output containParams
    );

wire[10:0] posX;
wire[10:0] posY;

//Tracked is set outside this block but here we just reserve one bit
//Valid just equals (m00 > 0)
/*/ EMPTY   /|/ MOVE    /|/ TRACKED /|/ VALID /|/  M10   /|/  M01  /|/  M00  /|/ xmax  /|/ xmin  /|/ ymax  /|/  ymin /*/
/*/ 159:146 /|/ 145:126 /|/   125   /|/  124  /|/ 123:94 /|/ 93:64 /|/ 63:44 /|/ 43:33 /|/ 32:22 /|/ 21:11 /|/  10:0 /*/
wire[159:0] BRAM_out;           // MOV
wire[159:0] readyParams;        // MOV
reg [159:0] cachedData = 160'b0; // MOV

reg[13:0] padding = 0;

wire[29:0] m10;
wire[29:0] m01;
wire[19:0] m00;
wire[19:0] move00; // MOV

wire[10:0] xMin;
wire[10:0] xMax;
wire[10:0] yMin;
wire[10:0] yMax;

wire isValid = (m00 > 0 ? 1'b1 : 1'b0);

reg prev_context = 1'b0;
wire[WIDTH_L - 1:0] target_L;
wire[WIDTH_L - 1:0] Lmerged_d2;
wire[WIDTH_L - 1:0] Lmerged_d;
reg[WIDTH_L - 1:0] Lstored = 0;
wire[WIDTH_L - 1:0] L_d;
wire context = pixel & de;
wire we = prev_context & ~context;
wire we_d;
wire re = (context & ~prev_context);
wire re_d;

wire mergeLabel_d;
wire newLabel_d;
wire overlap_d;

reg       mergeMove = 0;
reg[22:0] mergeExtension = 23'b0;
reg[21:0] mergeExtensionBB = {{11-WIDTH_W{1'b0}}, {WIDTH_W{1'b1}}, {11-WIDTH_H{1'b0}}, {WIDTH_H{1'b1}}};

wire vsync_d;
wire de_d;
wire lineEnd = ~de & de_d;
wire lineEnd_d;

reg mergeLabel = 0;
reg transition = 1'b0;

always @(posedge clk)
begin
	mergeExtension <= 60'b0;
	mergeMove <=0;
	mergeExtensionBB <= {{11-WIDTH_W{1'b0}}, {WIDTH_W{1'b1}}, {11-WIDTH_H{1'b0}}, {WIDTH_H{1'b1}}};

	cachedData <= {padding, move00, 1'b0, isValid, m10, m01, m00, xMax, xMin, yMax, yMin}; // MOV
		
	if(we_d & ~re)
		Lstored <= 0;
	else if(L > 0 & (re | mergeLabel))
		Lstored <= L;
	
	if(context)
	begin
	    mergeMove <= move;
		mergeExtension <= {posX, posY, 1'b1};
		mergeExtensionBB <= {posX, posY};	
	end
end

always @(posedge clk)
begin
	mergeLabel <= mergeLabelIn;
	prev_context <= context;
	
	if(de)
	begin
		resetMerged <= 1'b0;
	end
	
	if(lineEnd_d)
	begin
		resetMerged <= 1'b1;
	end

	// reset earlier?
	if(vsync_d & ~vsync)
	begin
		resetMerged <= 1'b0;
		transition <= ~transition;
		resetMemory <= 1'b1;
		resetCnt <= resetCnt + 1'b1;
	end
	
	if(resetMemory)
	begin
		resetCnt <= resetCnt + 1'b1;
	end
	
	if(~vsync_d & vsync)
	begin
		resetMemory <= 1'b0;
		resetCnt <= 10'b0;
	end

end

position # (
		.IMG_H(IMG_H), 
		.IMG_W(IMG_W) 
	) getPos	(
		.clk(clk),
		.vsync(vsync),
		.de(de),
		.posX(posX),
		.posY(posY)
	);

reg resetMerged = 1'b0;
wire[9:0] stackOut;
wire[9:0] mergeAddr = mergeLabel_d ? ((Lmerged_d2 > target_L) ? Lmerged_d2 : target_L) : 10'b0;

mergedStack mergeStack (
    .clk(clk), 
    .rst(1'b0), 
    .ce(1'b1), 
    .din(mergeAddr), 
    .dout(stackOut),
    .push(mergeLabel_d), 
    .pop(resetMerged)
    );

reg resetMemory = 1'b0;
reg[8:0] resetCnt = 9'b0;

wire[8:0] readAddr = (mergeLabel ? ((Lstored == L_d) ? {9'b0, Lmerged_d} : {9'b0, L_d}) : {9'b0, L});
wire[8:0] writeAddr = resetMerged ? stackOut : (we_d ? {9'b0, target_L} : (resetMemory ? resetCnt : 9'b0));

wire resetMM = resetMemory | resetMerged;

wire we1 = transition ? 1'b0 : (((writeAddr > 0) & ~overlap) ? (resetMM | we_d) : 1'b0);
wire we2 = transition ? (((writeAddr > 0) & ~overlap) ? (resetMM | we_d) : 1'b0) : 1'b0;

wire[8:0] addra1 = transition ? 10'b0 : writeAddr;
wire[8:0] addra2 = transition ? writeAddr : 10'b0;

wire[8:0] addrb1 = transition ? paramsAddr : readAddr;
wire[8:0] addrb2 = transition ? readAddr : paramsAddr;

wire overlap = transition ? (addra2 > 0 && addra2 == addrb2) : (addra1 > 0 && addra1 == addrb1); 

wire[159:0]dataIn = resetMM ? 160'b0 : {padding, move00, 1'b0, isValid, m10, m01, m00, xMax, xMin, yMax, yMin}; //cachedData;  //MOV

wire[159:0] BRAM_out1;   //MOV
wire[159:0] BRAM_out2;   //MOV 

//MOV - zmiana rozmiaru RAM 128 -> 160
BRAM_params params_mem1 (
  .clka(clk), // input clka
  .wea(we1), // input [0 : 0] wea
  .addra(addra1), // input [9 : 0] addra
  .dina(dataIn), // input [127 : 0] dina
  .clkb(clk), // input clkb
  .addrb(addrb1), // input [9 : 0] addrb
  .doutb(BRAM_out1) // output [127 : 0] doutb
);

BRAM_params params_mem2 (
  .clka(clk), // input clka
  .wea(we2), // input [0 : 0] wea
  .addra(addra2), // input [9 : 0] addra
  .dina(dataIn), // input [127 : 0] dina
  .clkb(clk), // input clkb
  .addrb(addrb2), // input [9 : 0] addrb
  .doutb(BRAM_out2) // output [127 : 0] doutb
);

assign readyParams = transition ? BRAM_out1 : BRAM_out2;
assign BRAM_out = transition ? BRAM_out2 : BRAM_out1;
	
wire[159:0] processData = (re_d & ~overlap_d) ? BRAM_out : cachedData;

wire[19:0] addm00 = mergeLabel_d ? (BRAM_out[63:44] + mergeExtension[0]) : mergeExtension[0]; 
wire[19:0] m00_in = newLabel_d ? 20'b0 : processData[63:44];

add2 adder_m00 (
  .A(m00_in), // input [19 : 0] a
  .B(addm00), // input [19 : 0] b
  .S(m00) // output [19 : 0] s
);

// MOV dodanie sumowania

wire[19:0] addmove00 = mergeLabel_d ? (BRAM_out[145:126] + mergeMove) : mergeMove; 
wire[19:0] move00_in = newLabel_d ? 20'b0 : processData[145:126];

add2 adder_move00 (
  .A(move00_in), // input [19 : 0] a
  .B(addmove00), // input [19 : 0] b
  .S(move00) // output [19 : 0] s
);

wire[29:0] addm01 = mergeLabel_d ? (BRAM_out[93:64] + mergeExtension[11:1]) : mergeExtension[11:1]; 
wire[29:0] addm10 = mergeLabel_d ? (BRAM_out[123:94] + mergeExtension[22:12]) : mergeExtension[22:12]; 
wire[29:0] m01_in = newLabel_d ? 30'b0 : processData[93:64];
wire[29:0] m10_in = newLabel_d ? 30'b0 : processData[123:94];

add adder_m01 (
  .A(m01_in), // input [29 : 0] a
  .B(addm01), // input [29 : 0] b
  .S(m01) // output [29 : 0] s
);

add adder_m10 (
  .A(m10_in), // input [29 : 0] a
  .B(addm10), // input [29 : 0] b
  .S(m10) // output [29 : 0] s
);

// DEBUG
wire[29:0] m10_debug = cachedData[123:94];
wire[29:0] m01_debug = cachedData[93:64];
wire[19:0] m00_debug = cachedData[63:44];

wire[29:0] bramm10_debug = BRAM_out[123:94];
wire[29:0] bramm01_debug = BRAM_out[93:64];
wire[19:0] bramm00_debug = BRAM_out[63:44];

wire[10:0] ymin_debug = cachedData[10:0];
wire[10:0] ymax_debug = cachedData[21:11];
wire[10:0] xmin_debug = cachedData[32:22];
wire[10:0] xmax_debug = cachedData[43:33];

wire[10:0] bramymin_debug = BRAM_out[10:0];
wire[10:0] bramymax_debug = BRAM_out[21:11];
wire[10:0] bramxmin_debug = BRAM_out[32:22];
wire[10:0] bramxmax_debug = BRAM_out[43:33];
// -------

wire[10:0] xMax_in1 = {11'b0, mergeExtension[22:12]};
wire[10:0] xMax_in2 = newLabel_d ? 0 : processData[43:33];
wire[10:0] xMax_in3 = mergeLabel_d ? BRAM_out[43:33] : 0;

wire[10:0] xMin_in1 = {11'b0, mergeExtensionBB[21:11]};
wire[10:0] xMin_in2 = newLabel_d ? (IMG_W - 1) : processData[32:22];
wire[10:0] xMin_in3 = mergeLabel_d ? BRAM_out[32:22] : (IMG_W - 1);

wire[10:0] yMax_in1 = {11'b0, mergeExtension[11:1]};
wire[10:0] yMax_in2 = newLabel_d ? 0 : processData[21:11];
wire[10:0] yMax_in3 = mergeLabel_d ? BRAM_out[21:11] : 0;

wire[10:0] yMin_in1 = {11'b0, mergeExtensionBB[10:0]};
wire[10:0] yMin_in2 = newLabel_d ? (IMG_W - 1) : processData[10:0];
wire[10:0] yMin_in3 = mergeLabel_d ? BRAM_out[10:0] : (IMG_W - 1);

max xmax_result (
     .in1(xMax_in1), 
     .in2(xMax_in2), 
     .in3(xMax_in3), 
     .result(xMax)
	);

min xmin_result (
     .in1(xMin_in1), 
     .in2(xMin_in2), 
     .in3(xMin_in3), 
     .result(xMin)
	);

max ymax_result (
     .in1(yMax_in1), 
     .in2(yMax_in2), 
     .in3(yMax_in3), 
     .result(yMax)
	);

min ymin_result (
     .in1(yMin_in1), 
     .in2(yMin_in2), 
     .in3(yMin_in3), 
     .result(yMin)
	);

delay_line #(
		.N(2*WIDTH_L + 8),
		.DELAY(1)
    )del1(
        .clk(clk),
        .rst(reset),
        .idata({L, Lmerged, de, vsync, lineEnd, re, we, mergeLabel, newLabel, overlap}), 
        .odata({L_d, Lmerged_d, de_d, vsync_d, lineEnd_d, re_d, we_d, mergeLabel_d, newLabel_d, overlap_d})
);

delay_line #(
		.N(2*WIDTH_L),
		.DELAY(2)
    )del2(
        .clk(clk),
        .rst(reset),
        .idata({L, Lmerged}), 
        .odata({target_L, Lmerged_d2})
);

wire[55:0] centerX;
wire[55:0] centerY;

wire outputingParams = (paramsAddr < 511);

div_gen_0 div_x // 32 latency
(
    .aclk(clk),
    .s_axis_dividend_tdata({2'b0, readyParams[123:94]}),
    .s_axis_divisor_tdata({4'b0, readyParams[63:44]}),
    .m_axis_dout_tdata(centerX)
);

div_gen_0 div_y
(
    .aclk(clk),
    .s_axis_dividend_tdata({2'b0, readyParams[93:64]}),
    .s_axis_divisor_tdata({4'b0, readyParams[63:44]}),
    .m_axis_dout_tdata(centerY)
);

// -------

wire[35:0] delayedParams1;
wire[63:0] delayedParams2;  // MOV

delay_line #(
		.N(36+64 + 1),      // MOV
		.DELAY(32)
    )del32(
        .clk(clk),
        .rst(reset),
        .idata({readyParams[159:124], readyParams[63:0], outputingParams}),  // MOV
        .odata({delayedParams1, delayedParams2, containParams})
);

assign paramsOut = {delayedParams1, centerX[53:24], centerY[53:24], delayedParams2}; // MOV

endmodule
