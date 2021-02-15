`timescale 1ns / 1ps
//-----------------------------------------------
// Company: AGH
// Engineer: M. Komorkiewicz, T. Kryjak
// Create Date:    11:41:13 05/10/2011 
// Description: log image to ppm file
//-----------------------------------------------
module txt_out
#
(
    parameter prefix="out_",
    parameter folder="Bg/"
) 
(
  input hdmi_clk,
  input hdmi_de,
  input hdmi_vs,
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
reg [15:0]vsc=16'd0;
reg [11:0] vsc2=12'd0;
reg vse=1;
wire w_hdmi_vs_i = !hdmi_vs;
//-----------------------------------------------
always @(posedge hdmi_clk)
begin

    if(hdmi_de)
	 begin
	   	 vsc<=vsc+1;
	   //just for good debugging
	    fm1 = $fopen({"C:/backup/FPGA/Results/",folder,prefix,vsc[15:0]/1000+8'h30,(vsc[15:0]%1000)/100+8'h30,(vsc[15:0]%100)/10+8'h30,vsc[15:0]%10+8'h30,".txt"},"wb");
	       $fwrite(fm1,"%0d",vsc2);
           $fwrite(fm1,"\n");
	   	   $fwrite(fm1,"%0d",move);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",m10);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",m01);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",m00);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",xmax);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",xmin);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",ymax);
           $fwrite(fm1,"\n");
           $fwrite(fm1,"%0d",ymin);
           $fclose(fm1);
    end
    
    vse<=w_hdmi_vs_i;
    if((w_hdmi_vs_i==1'b1)&&(vse==1'b0))
    begin
        vsc2<=vsc2+1;
    end
        
end
//-----------------------------------------------
endmodule
//-----------------------------------------------
