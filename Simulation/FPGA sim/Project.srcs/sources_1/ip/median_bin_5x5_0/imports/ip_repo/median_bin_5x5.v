`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2016 09:33:49
// Design Name: 
// Module Name: median_bin_7x7
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


module median_bin_5x5

#( parameter IMAGE_WIDTH = 1280,
   parameter IMAGE_HEIGHT = 720,
   parameter IMAGE_HSIZE = 1650
)
(
   input clk,
   input de_in,
   input hsync_in,
   input vsync_in, 
   
   input [23:0] fos_in,    
   input [23:0] cfd_in,    
            
   output de_out,
   output hsync_out,
   output vsync_out, 
   
   // Wyjscie z mediana
   output [23:0] rgb_fos_median_out,
   
   // Wyjscie z CFD
   output [23:0] rgb_cfd_out
   
      
);
    

wire bin_in;
assign bin_in = fos_in[0];

wire bin_roi; // binaryzacja wewnatrz ROI
assign bin_roi =  bin_in;

// mediana ...................................

reg [4:0]d11;
reg [4:0]d12;
reg [4:0]d13;
reg [4:0]d14;
reg [4:0]d15;

reg [4:0]d21;
reg [4:0]d22;
reg [4:0]d23;
reg [4:0]d24;
reg [4:0]d25;


reg [4:0]d31;
reg [4:0]d32;
reg [4:0]d33;
reg [4:0]d34;
reg [4:0]d35;

reg [4:0]d41;
reg [4:0]d42;
reg [4:0]d43;
reg [4:0]d44;
reg [4:0]d45;


reg [4:0]d51;
reg [4:0]d52;
reg [4:0]d53;
reg [4:0]d54;
reg [4:0]d55;



 
wire [4:0]delayLine1Out;
wire [4:0]delayLine2Out;
wire [4:0]delayLine3Out;
wire [4:0]delayLine4Out;
    
always @(posedge clk) begin
     d11 <= {hsync_in,vsync_in,de_in,cfd_in[0],bin_roi};
     d12 <= d11;
     d13 <= d12;
     d14 <= d13;
     d15 <= d14;
               
      
     d21 <= delayLine1Out;
     d22 <= d21;
     d23 <= d22;
     d24 <= d23;
     d25 <= d24;
               
      
     d31 <= delayLine2Out;
     d32 <= d31;
     d33 <= d32;
     d34 <= d33;
     d35 <= d34;
               
     d41 <= delayLine3Out;
     d42 <= d41;
     d43 <= d42;
     d44 <= d43;
     d45 <= d44;
           
     
     d51 <= delayLine4Out;
     d52 <= d51;
     d53 <= d52;
     d54 <= d53;
     d55 <= d54;
     
               
 end
 
 // cala linia ma 32
 
 delayLinieBRAM_WP 
 #(
     .WIDTH(30)
 ) delayLine (
     .clk(clk),
     .rst(0),
     .ce(1),
     .din({d45,d35,d25,d15}) ,
     .dout({delayLine4Out,delayLine3Out,delayLine2Out,delayLine1Out}),
     .h_size(IMAGE_HSIZE-5)
     );  

  reg [2:0] d1SumValue = 0;
  reg [2:0] d2SumValue = 0;
  reg [2:0] d3SumValue = 0;
  reg [2:0] d4SumValue = 0;
  reg [2:0] d5SumValue = 0;
    
  reg [6:0]sum=5'b0;
  reg binr = 0;
  
  reg d1DeValue = 0;
  reg d2DeValue = 0;
  reg d3DeValue = 0;
  reg d4DeValue = 0;
  reg d5DeValue = 0;
  
  reg deSum = 0;

              
  
always @(posedge clk) begin

    d1SumValue <= d11[0] + d12[0] + d13[0] + d14[0] + d15[0];
    d2SumValue <= d21[0] + d22[0] + d23[0] + d24[0] + d25[0];
    d3SumValue <= d31[0] + d32[0] + d33[0] + d34[0] + d35[0];
    d4SumValue <= d41[0] + d42[0] + d43[0] + d44[0] + d45[0];
    d5SumValue <= d51[0] + d52[0] + d53[0] + d54[0] + d55[0];
        
    d1DeValue <= d11[2] && d12[2] && d13[2] && d14[2] && d15[2];
    d2DeValue <= d21[2] && d22[2] && d23[2] && d24[2] && d25[2];
    d3DeValue <= d31[2] && d32[2] && d33[2] && d34[2] && d35[2];
    d4DeValue <= d41[2] && d42[2] && d43[2] && d44[2] && d45[2];
    d5DeValue <= d51[2] && d52[2] && d53[2] && d54[2] && d55[2];
  
    
    sum <= d1SumValue + d2SumValue + d3SumValue + d4SumValue + d5SumValue;
           
    deSum <=  d1DeValue && d2DeValue && d3DeValue && d4DeValue && d5DeValue;
                        
    binr <= (sum > 12) && (deSum == 1'b1) ? 1 : 0;
    
  end
  
  assign rgb_fos_median_out = (binr == 1'b1) ? 24'b111111111111111111111111 :0;
    
  assign rgb_cfd_out = (d35[1] == 1'b1) ? 24'b111111111111111111111111 :0;
    
  //assign bin_out   =   bin_roi;
  
       
  assign hsync_out = d35[4];  ///47
  assign vsync_out = d35[3];
  assign de_out    = d35[2];

endmodule
