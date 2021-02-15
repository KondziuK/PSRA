`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2020 17:12:33
// Design Name: 
// Module Name: txt_out
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


module txt_out_v2
#
(
    parameter prefix="out_",
    parameter folder="Bg/"
) 
(
  input hdmi_clk,
  input hdmi_vs,
  input hdmi_de,
  input [19:0] move,
  input [29:0] m10,
  input [29:0] m01,
  input [19:0] m00,
  input [10:0] xmax,
  input [10:0] xmin,
  input [10:0] ymax,
  input [10:0] ymin
);
//-----------------------------------------------
integer fm1=0;

reg [11:0]vsc=12'd0;
reg [11:0]next_vsc=12'd0;
reg prev_vsync=0;
//-----------------------------------------------
initial
begin
  //fm1 = $fopen("outA.ppm","wb");  
end
//-----------------------------------------------
always @(posedge hdmi_clk)
begin
    if(hdmi_vs == 1 && prev_vsync == 0)
    begin
        vsc<=next_vsc;
        next_vsc <= next_vsc+1;
    end
    if(hdmi_de == 1)
	begin
	   //just for good debugging
	    fm1 = $fopen({"C:/backup/FPGA/Results/",folder,prefix,vsc[11:0]/1000+8'h30,(vsc[11:0]%1000)/100+8'h30,(vsc[11:0]%100)/10+8'h30,vsc[11:0]%10+8'h30,".txt"},"ab");
	   	   $fwrite(fm1,"%0d ",move);
           $fwrite(fm1,"%0d ",m10);
           $fwrite(fm1,"%0d ",m01);
           $fwrite(fm1,"%0d ",m00);
           $fwrite(fm1,"%0d ",xmax);
           $fwrite(fm1,"%0d ",xmin);
           $fwrite(fm1,"%0d ",ymax);
           $fwrite(fm1,"%0d ",ymin);
           $fwrite(fm1,"\n");
           $fclose(fm1);
    end
    prev_vsync <= hdmi_vs;
end
//-----------------------------------------------
endmodule
//-----------------------------------------------
