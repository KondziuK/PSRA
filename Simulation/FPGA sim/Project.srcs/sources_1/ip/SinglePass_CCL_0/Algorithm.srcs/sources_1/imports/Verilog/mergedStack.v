`timescale 1ns / 1ps

module mergedStack # (
	parameter WIDTH_L = 10
    )
    (
    input clk,
    input rst,
    input ce,
    input [WIDTH_L - 1:0] din,
    output [WIDTH_L - 1:0] dout,
    input push,
    input pop
    );
 
reg [9:0] ptr = 0;

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

stackMemory2 stack2 (
    .clka(clk), // input clka
    .wea(1'b1), // input [0 : 0] wea
    .addra(ptr), // input [9 : 0] addra
    .dina(din), // input [9 : 0] dina
    .douta(dout) // output [9 : 0] douta
    );

endmodule
