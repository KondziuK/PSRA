`timescale 1ns / 1ps

module tracking (
        input rx_pclk,
        input[127:0] params,
        input valid,
        input startTracking,
        
        output trackingFinished,
        output[127:0] updatedParams
    );

localparam STATE_IDLE = 3'd0;
localparam STATE_DETECT = 3'd1;
localparam STATE_TRACKING = 3'd2;
localparam STATE_UPDATE = 3'd3;
localparam STATE_SEND = 3'd4;

reg[2:0] state = STATE_IDLE;
reg[2:0] prevState;

wire[10:0] centerY = params[105] ? 11'b0 : params[104:94];
wire[10:0] centerX = params[75] ? 11'b0 : params[74:64];

wire[19:0] field = params[63:44];

reg[127:0] delayParams;

reg[9:0] id = 0;
reg[9:0] candidateId = 0;
reg[11:0] candidateCoeff = 12'd4095;

reg[10:0] prevCenterX = 0;
reg[10:0] prevCenterY = 0;
reg[19:0] prevField = 0;

reg[10:0] candidateCenterX = 0;
reg[10:0] candidateCenterY = 0;

wire[11:0] tempVelX;
wire[11:0] tempVelY;

reg[10:0] regVelX = 0;
reg[10:0] regVelY = 0;

wire[11:0] velocityX;
wire[11:0] velocityY;

reg[10:0] assumedCenterX = 0;
reg[10:0] assumedCenterY = 0;

reg prevValid = 1'b0;
reg prevStartTracking = 1'b0;

reg toBeUpdated = 0;
reg updated = 0;

sub_11_11 calcVelX
(
    .clk(rx_pclk),
    .ce(toBeUpdated),
    .A(candidateCenterX),
    .B(prevCenterX),
    
    .S(tempVelX)
);

sub_11_11 calcVelY
(
    .clk(rx_pclk),
    .ce(toBeUpdated),
    .A(candidateCenterY),
    .B(prevCenterY),
    
    .S(tempVelY)
);

// A values are rolled right by 1 -> divided by 2

add_11_11 averageVelX
(
    .clk(rx_pclk),
    .ce(updated),
    .A(tempVelX[11:1]),
    .B(regVelX),
    
    .S(velocityX)
);

add_11_11 averageVelY
(
    .clk(rx_pclk),
    .ce(updated),
    .A(tempVelY[11:1]),
    .B(regVelY),
    
    .S(velocityY)
);

wire[19:0] fieldDiff = (prevField > field) ? (prevField - field) : (field - prevField);
wire[10:0] centerXDiff = (assumedCenterX > centerX) ? (assumedCenterX - centerX) : (centerX - assumedCenterX);
wire[10:0] centerYDiff = (assumedCenterX > centerY) ? (assumedCenterX - centerY) : (centerY - assumedCenterX);

always @(posedge rx_pclk)
begin    
    delayParams <= params;
    
    case(state)
    STATE_IDLE:
    begin
        if(startTracking & ~prevStartTracking)
        begin
            state <= STATE_DETECT;
            
            prevField <= 0;    
            prevCenterX <= 0;
            prevCenterY <= 0;
            
            candidateCenterX <= 0;
            candidateCenterY <= 0;

            assumedCenterX <= 0;
            assumedCenterY <= 0;
            
            regVelX <= 0;
            regVelY <= 0;
        end
    end
    STATE_DETECT: // We try to detect the biggest object on a frame
    begin
        if(prevStartTracking & ~startTracking)
            state <= STATE_IDLE;
        else if(valid)
        begin
            if(field > prevField)
            begin
                prevField <= field;
                prevCenterX <= centerX;
                prevCenterY <= centerY;  
                
                assumedCenterX <= centerX;
                assumedCenterY <= centerY;  
            end
        end
        else if(prevValid & (prevField > 0)) // We checked all objects and chose the biggest one
        begin
            id <= 0;
            candidateId <= 0;
            candidateCoeff <= 12'd4095;
            state <= STATE_TRACKING;
        end
    end
    STATE_TRACKING:
    begin
        if(prevStartTracking & ~startTracking)
            state <= STATE_IDLE;
        else if(valid)
        begin
            if((centerYDiff + centerXDiff) < candidateCoeff)
            begin
                candidateId <= id;
                candidateCoeff <= (centerYDiff + centerXDiff);
                
                candidateCenterX <= centerX;
                candidateCenterY <= centerY;
            end
            
            id <= id + 1;
        end
        else if(prevValid)
        begin
            id <= 0;
            toBeUpdated <= 1'b1;
            state <= STATE_UPDATE;
        end
    end
    STATE_UPDATE:
    begin
        toBeUpdated <= 1'b0;
        if(prevStartTracking & ~startTracking)
            state <= STATE_IDLE;
        else
        begin
            updated <= 1'b1;            
            prevCenterX <= candidateCenterX;
            prevCenterY <= candidateCenterY;
            
            // Roll right by 1 -> divide by 2
            regVelX <= velocityX[11:1];
            regVelY <= velocityY[11:1];
            state <= STATE_SEND;
        end
    end
    STATE_SEND:
    begin
        updated <= 1'b0;
        assumedCenterX <= prevCenterX + velocityX;
        assumedCenterY <= prevCenterY + velocityY;
        if(prevStartTracking & ~startTracking)
            state <= STATE_IDLE;
        else if(valid)
        begin
            if(id == candidateId)
                delayParams[125] <= 1'b1;
            id <= id + 1;
        end
        else if(prevValid)
        begin
            id <= 0;
            candidateId <= 0;
            candidateCoeff <= 12'd4095;            
            state <= STATE_TRACKING;
        end
    end
    endcase
    
    prevState <= state;
    prevValid <= valid;
    prevStartTracking <= startTracking;
end    
    
assign trackingFinished = (state == STATE_UPDATE);
assign updatedParams = (state == STATE_SEND) ? delayParams : 128'b0;

endmodule
