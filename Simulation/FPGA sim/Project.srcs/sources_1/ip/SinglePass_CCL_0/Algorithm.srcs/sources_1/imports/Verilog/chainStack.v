`timescale 1ns / 1ps

module chainStack # (
	parameter WIDTH = 10
    )
    (
    input clk,
    input rst,
    input ce,
    input [2*WIDTH - 1:0] din,
    output [2*WIDTH - 1:0] dout,
    input push,
    input pop
    );
 
wire[19:0] dinw;
wire[19:0] doutw; 
 
reg [7:0] ptr = 0;

always @(posedge clk) begin
    if (ce == 1'b1)
    begin
        if (rst)
            ptr <= 0;
        else if (push)
            ptr <= ptr + 1;
        else if (pop)
        begin
            if(ptr != 0)
                ptr <= ptr - 1;
        end
    end
end

stackMemory stack (
    .clka(clk), // input clka
    .wea(1'b1), // input [0 : 0] wea
    .addra(ptr), // input [7 : 0] addra
    .dina(dinw), // input [19 : 0] dina
    .douta(doutw) // output [19 : 0] douta
    );

assign dinw[2*WIDTH - 1:0] = din;
assign dout = doutw[2*WIDTH - 1:0];

endmodule
