//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Tomasz Kryjak
// 
// Create Date:    11:29:28 10/28/2013 
// Design Name: 
// Module Name:    tb_hdmi_psra_hsvs 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Simulation model for PSRA/HSVS remote classes
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tb_hdmi(
    );
	 

wire rx_pclk;

wire rx_de;
wire rx_hsync;
wire rx_vsync;

wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;


wire tx_de;
wire tx_hsync;
wire tx_vsync;

wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;

wire [23:0]     fos;
wire [23:0]     cfd;
wire [23:0]     bg;

wire            de_1;
wire            hsync_1;
wire            vsync_1;

wire            de_2;
wire            hsync_2;
wire            vsync_2;
wire [23:0]     rgb_fos_median_out;
wire [23:0]     rgb_cfd_out;

wire [1:0]      led;
wire [159:0]    params;
wire            validParams;
wire [23:0]     rgb_out;

// --------------------------------------
// HDMI input
// --------------------------------------
hdmi_in file_input (
    .hdmi_clk(rx_pclk), 
    .hdmi_de(rx_de), 
    .hdmi_hs(rx_hsync), 
    .hdmi_vs(rx_vsync), 
    .hdmi_r(rx_red), 
    .hdmi_g(rx_green), 
    .hdmi_b(rx_blue)
    );
	 

// --------------------------------------
// FOS CFD
fos_cfd 
#
(
    .FOS_TH(60),
    .CFD_TH(100)
)
test_fos_cfd
(
    .R_input(rx_red),
    .G_input(rx_green),
    .B_input(rx_blue),
    .rst(1'b0),
    .clk(rx_pclk),
    .ce(1'b1),
    .de_in(rx_de),
    .vsync_in(rx_vsync),
    .hsync_in(rx_hsync),
    .fos(fos),
    .cfd(cfd),
    .bg(bg),
    .vsync_out(vsync_1),
    .de_out(de_1),
    .hsync_out(hsync_1)
);

// --------------------------------------

// --------------------------------------
// MEDIAN 
// --------------------------------------

median_bin_5x5_0 my_precious_median (
  .clk(rx_pclk),                                // input wire clk
  .de_in(de_1),                            // input wire de_in
  .hsync_in(hsync_1),                      // input wire hsync_in
  .vsync_in(vsync_1),                      // input wire vsync_in
  .fos_in(fos),                          // input wire [23 : 0] fos_in
  .cfd_in(cfd),                          // input wire [23 : 0] cfd_in
  .de_out(de_2),                          // output wire de_out
  .hsync_out(hsync_2),                    // output wire hsync_out
  .vsync_out(vsync_2),                    // output wire vsync_out
  .rgb_fos_median_out(rgb_fos_median_out),  // output wire [23 : 0] rgb_fos_median_out
  .rgb_cfd_out(rgb_cfd_out)                // output wire [23 : 0] rgb_cfd_out
);

// --------------------------------------
// CCL 
// --------------------------------------

SinglePass_CCL_0 my_precious_CCL (
  .rgb_in(rgb_fos_median_out),             // input wire [23 : 0] rgb_in
  .move_in(rgb_cfd_out),              // input wire [23 : 0] move_in
  .rx_hsync(hsync_2),            // input wire rx_hsync
  .rx_vsync(vsync_2),            // input wire rx_vsync
  .rx_de(de_2),                  // input wire rx_de
  .rx_pclk(rx_pclk),              // input wire rx_pclk
  .immediateRead(0),  // input wire immediateRead
//  .led(led),                      // output wire [1 : 0] led
  .params(params),                // output wire [159 : 0] params
  .validParams(validParams),      // output wire validParams
//  .rgb_out(rgb_out),              // output wire [23 : 0] rgb_out
//  .tx_hsync(tx_hsync),            // output wire tx_hsync
  .tx_vsync(tx_vsync)            // output wire tx_vsync
//  .tx_de(tx_de)                  // output wire tx_de
);


// --------------------------------------
// Output assigment
// --------------------------------------
// --------------------------------------
// HDMI output
// --------------------------------------
hdmi_out 
   #(
    .prefix("out_bg_"),
    .folder("Bg/")
    )
hdm_out_1(
    .hdmi_clk(rx_pclk), 
    .hdmi_vs(vsync_1), 
    .hdmi_de(de_1), 
    .hdmi_data({8'b0,bg[23-:8],bg[15-:8],bg[7:0]})
    );
    
hdmi_out 
   #(
    .prefix("out_fos_"),
    .folder("Fos/")
    )
hdm_out_2(
    .hdmi_clk(rx_pclk), 
    .hdmi_vs(vsync_1), 
    .hdmi_de(de_1), 
    .hdmi_data({8'b0,fos[23-:8],fos[15-:8],fos[7:0]})
    );
    
hdmi_out 
   #(
    .prefix("out_cfd_"),
    .folder("Cfd/")
    )
hdm_out_3(
    .hdmi_clk(rx_pclk), 
    .hdmi_vs(vsync_1), 
    .hdmi_de(de_1), 
    .hdmi_data({8'b0,cfd[23-:8],cfd[15-:8],cfd[7:0]})
    );
    
hdmi_out 
   #(
    .prefix("out_median_"),
    .folder("Median_fos/")
    )
hdm_out_4(
    .hdmi_clk(rx_pclk), 
    .hdmi_vs(vsync_2), 
    .hdmi_de(de_2), 
    .hdmi_data({8'b0,rgb_fos_median_out[23-:8],rgb_fos_median_out[15-:8],rgb_fos_median_out[7:0]})
    );
    
hdmi_out 
   #(
    .prefix("out_cfd2_"),
    .folder("Cfd2/")
    )
hdm_out_5(
    .hdmi_clk(rx_pclk), 
    .hdmi_vs(vsync_2), 
    .hdmi_de(de_2), 
    .hdmi_data({8'b0,rgb_cfd_out[23-:8],rgb_cfd_out[15-:8],rgb_cfd_out[7:0]})
    );

txt_out_v2 
#
(
    .prefix("out_data_"),
    .folder("Data/")
)
my_precious_txt_v2
(
    .hdmi_clk(rx_pclk),
    .hdmi_vs(tx_vsync),
    .hdmi_de(validParams&params[124]),
    .move(params[145:126]),
    .m10(params[123:94]),
    .m01(params[93:64]),
    .m00(params[63:44]),
    .xmax(params[43:33]),
    .xmin(params[32:22]),
    .ymax(params[21:11]),
    .ymin(params[10:0])
);

endmodule
