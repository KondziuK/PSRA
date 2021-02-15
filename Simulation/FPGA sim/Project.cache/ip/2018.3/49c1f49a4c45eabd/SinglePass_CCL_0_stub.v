// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue May 19 22:09:56 2020
// Host        : DESKTOP-3UBI8F3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ SinglePass_CCL_0_stub.v
// Design      : SinglePass_CCL_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "SinglePass_CCL,Vivado 2018.3" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(rgb_in, move_in, rx_hsync, rx_vsync, rx_de, 
  rx_pclk, immediateRead, led, params, validParams, rgb_out, tx_hsync, tx_vsync, tx_de)
/* synthesis syn_black_box black_box_pad_pin="rgb_in[23:0],move_in[23:0],rx_hsync,rx_vsync,rx_de,rx_pclk,immediateRead,led[1:0],params[159:0],validParams,rgb_out[23:0],tx_hsync,tx_vsync,tx_de" */;
  input [23:0]rgb_in;
  input [23:0]move_in;
  input rx_hsync;
  input rx_vsync;
  input rx_de;
  input rx_pclk;
  input immediateRead;
  output [1:0]led;
  output [159:0]params;
  output validParams;
  output [23:0]rgb_out;
  output tx_hsync;
  output tx_vsync;
  output tx_de;
endmodule
