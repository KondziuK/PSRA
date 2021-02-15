`timescale 1ns / 1ps

module fos_cfd
#
(
    //progi binaryzacji
    parameter [31:0] FOS_TH=0,
    parameter [31:0] CFD_TH=0
)
(
    input [7:0]     R_input,
    input [7:0]     G_input,
    input [7:0]     B_input,
    input           rst,
    input           clk,
    input           ce,
    input           de_in,
    input           vsync_in,
    input           hsync_in,
    
    output [23:0]   fos,
    output [23:0]   cfd,
    output [23:0]   bg,
    output          vsync_out,
    output          hsync_out,
    output          de_out
);

reg [14:0]  pixel_addres = 0;       //Pixel address
reg [14:0]  pixel_addres_del=0;     //Pixel address delayed x1
reg [14:0]  pixel_addres_del_2=0;   //Pixel address delayed x2
reg [23:0]  bg_model_write;         //Bg model to write to RAM
reg [23:0] r_fos=0;
reg [23:0] r_cfd=0;
reg [7:0]   R_del=0;                //R delayed x1 
reg [7:0]   G_del=0;                //G delayed x1
reg [7:0]   B_del=0;                //B delayed x1
reg [7:0]   R_del_2=0;              //R delayed x2
reg [7:0]   G_del_2=0;              //G delayed x2
reg [7:0]   B_del_2=0;              //B delayed x2
reg         de_del=0;               //de delayed x1
reg         vsync_del=0;            //vsync delayed x1
reg         hsync_del=0;            //hsync delayed x1
reg         de_del_2=0;             //de delayed x2
reg         vsync_del_2=0;          //vsync delayed x2
reg         hsync_del_2=0;          //hsync delayed x2
reg         first_frame=1;          //Signal of first frame

wire [7:0] bg_model_read_R;         //Bg model read from RAM- R
wire [7:0] bg_model_read_G;         //Bg model read from RAM- G
wire [7:0] bg_model_read_B;         //Bg model read from RAM- B
wire [23:0] bg_model_compare;       //Bg model - bg_model_read/0 - depends of first frame
wire [7:0] R_prev;                  //Previous pixel value -R
wire [7:0] G_prev;                  //Previous pixel value -G
wire [7:0] B_prev;                  //Previous pixel value -B
wire [7:0]  pix_pix_diff_1;         //Difference between current pixel and previous -R
wire [7:0]  pix_pix_diff_2;         //Difference between current pixel and previous -G
wire [7:0]  pix_pix_diff_3;         //Difference between current pixel and previous -B
wire [7:0]  pix_bg_diff_1;          //Difference between current pixel and bg model -R
wire [7:0]  pix_bg_diff_2;          //Difference between current pixel and bg model -G
wire [7:0]  pix_bg_diff_3;          //Difference between current pixel and bg model -B
wire [23:0] w_fos;                  //Wire for fos to Bg calculation
wire [23:0] w_cfd;                  //Wire for cfd to Bg calculation

assign pix_pix_diff_1= first_frame==0 ? ((R_del>R_prev) ? (R_del-R_prev):(R_prev-R_del)) : 7'b0;
assign pix_pix_diff_2= first_frame==0 ? ((G_del>G_prev) ? (G_del-G_prev):(G_prev-G_del)) : 7'b0;
assign pix_pix_diff_3= first_frame==0 ? ((B_del>B_prev) ? (B_del-B_prev):(B_prev-B_del)) : 7'b0;

assign pix_bg_diff_1= (R_del > bg_model_compare[23-:8])?(R_del - bg_model_compare[23-:8]) :(bg_model_compare[23-:8] - R_del);
assign pix_bg_diff_2= (G_del > bg_model_compare[15-:8])?(G_del - bg_model_compare[15-:8]) :(bg_model_compare[15-:8] - G_del);
assign pix_bg_diff_3= (B_del > bg_model_compare[7:0])?(B_del - bg_model_compare[7:0]) :(bg_model_compare[7:0] - B_del);

assign bg_model_compare= first_frame==1 ? {R_del,G_del,B_del} : {bg_model_read_R,bg_model_read_G,bg_model_read_B};

assign w_fos=(pix_bg_diff_1+pix_bg_diff_2+pix_bg_diff_3) > FOS_TH ? 24'b111111111111111111111111 : 24'b0;
assign w_cfd=(pix_pix_diff_1+pix_pix_diff_2+pix_pix_diff_3) > CFD_TH ? 24'b111111111111111111111111 : 24'b0;


//Delaying fos,cfd to properly synchronize
always@(posedge clk)
begin
     r_cfd<= w_cfd;
     r_fos<= w_fos;
end

//Delta-sigma implementation 
always@(posedge clk)
begin
    begin
        if(w_cfd== 0)
        begin
            if(w_fos==0)
            begin
            
                if(R_del>bg_model_compare[23-:8])
                    bg_model_write[23-:8]<= bg_model_compare[23-:8]+8'b00000001;
                else
                    if(R_del<bg_model_compare[23-:8])
                        bg_model_write[23-:8]<=bg_model_compare[23-:8]-8'b00000001;
                    else
                        bg_model_write[23-:8]<=bg_model_compare[23-:8];
                        
                        
                if(G_del>bg_model_compare[15-:8])
                    bg_model_write[15-:8]<=bg_model_compare[15-:8]+8'b00000001;
                else
                    if(G_del<bg_model_compare[15-:8])
                        bg_model_write[15-:8]<=bg_model_compare[15-:8]-8'b00000001;
                    else
                        bg_model_write[15-:8]<=bg_model_compare[15-:8];
                        
                        
                if(B_del>bg_model_compare[7:0])
                    bg_model_write[7:0]<=bg_model_compare[7:0]+8'b00000001;
                else
                    if(B_del<bg_model_compare[7:0])
                        bg_model_write[7:0]<=bg_model_compare[7:0]-8'b00000001;
                    else
                        bg_model_write[7:0]<=bg_model_compare[7:0];
                        
            end
            else
                bg_model_write<=bg_model_compare;
        end
        else
            bg_model_write<=bg_model_compare;
    end
end


//Delaying signals
always@(posedge clk)
begin
    R_del<=R_input;
    G_del<=G_input;
    B_del<=B_input;
    R_del_2<=R_del;
    G_del_2<=G_del;
    B_del_2<=B_del;
    de_del<=de_in;
    de_del_2<=de_del;
    vsync_del<=vsync_in;
    vsync_del_2<=vsync_del;
    hsync_del<=hsync_in;
    hsync_del_2<=hsync_del;
    pixel_addres_del<=pixel_addres;
    pixel_addres_del_2<=pixel_addres_del;
    
end

//Calculating pixel_adress and first frame
always @(posedge clk)
begin
    // New frame
    if ( vsync_in == 1 )
        pixel_addres <= 0;
    else
    begin
    // A valid pixel
    if (de_in == 1)
        pixel_addres <= pixel_addres + 1;
        if(pixel_addres==25919)
            first_frame<=0;
    end
end

//RAM instance
fos_cfd_ram my_precious_ram 
(
  .clka(clk),    // input wire clka
  .wea(de_del_2),      // input wire [0 : 0] wea
  .addra(pixel_addres_del_2),  // input wire [14 : 0] addra
  .dina({bg_model_write,{R_del_2,G_del_2,B_del_2}}),    // input wire [47 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(pixel_addres),  // input wire [14 : 0] addrb
  .doutb({{bg_model_read_R,bg_model_read_G,bg_model_read_B},{R_prev,G_prev,B_prev}})  // output wire [47 : 0] doutb
);
//Exit assigments
assign bg=bg_model_write;
assign de_out=de_del_2;
assign vsync_out=vsync_del_2;
assign hsync_out=hsync_del_2;
assign fos=r_fos;
assign cfd=r_cfd;
endmodule
