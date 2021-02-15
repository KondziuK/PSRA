`timescale 1ns / 1ps

module delay_BRAM # (
	parameter WIDTH = 16,
	parameter BRAM_SIZE = 1980
	)(
    input clk,
    input rst,
    input ce,
    input [WIDTH-1:0] din,
    output[WIDTH-1:0] dout
    );

reg[10:0] position = 0;

wire[9:0] dout_w;

always @(posedge clk)
begin
    if (ce == 1'b1)
    begin
        if (rst == 1'b1)
        begin
            position <= 0;
        end
        else
        begin
            position <= position + 1;
            if (position == BRAM_SIZE - 1)
            begin
                position <= 0;
            end
        end		
    end	
end

row_BRAM BRAM (
    .clka(clk), // input clka
    .ena(ce), // input ena
    .wea(1'b1), // input [0 : 0] wea //1'b1
    .addra(position), // input [10 : 0] addra
    .dina(10'b0 + din), // input [9 : 0] dina
    .douta(dout_w) // output [9 : 0] douta
);

assign dout = dout_w[WIDTH - 1:0];
	
endmodule