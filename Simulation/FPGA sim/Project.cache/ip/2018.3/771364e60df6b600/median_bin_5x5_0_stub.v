// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri May 15 17:54:52 2020
// Host        : DESKTOP-3UBI8F3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ median_bin_5x5_0_stub.v
// Design      : median_bin_5x5_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "median_bin_5x5,Vivado 2018.3" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk, de_in, hsync_in, vsync_in, fos_in, cfd_in, 
  de_out, hsync_out, vsync_out, rgb_fos_median_out, rgb_cfd_out)
/* synthesis syn_black_box black_box_pad_pin="clk,de_in,hsync_in,vsync_in,fos_in[23:0],cfd_in[23:0],de_out,hsync_out,vsync_out,rgb_fos_median_out[23:0],rgb_cfd_out[23:0]" */;
  input clk;
  input de_in;
  input hsync_in;
  input vsync_in;
  input [23:0]fos_in;
  input [23:0]cfd_in;
  output de_out;
  output hsync_out;
  output vsync_out;
  output [23:0]rgb_fos_median_out;
  output [23:0]rgb_cfd_out;
endmodule
