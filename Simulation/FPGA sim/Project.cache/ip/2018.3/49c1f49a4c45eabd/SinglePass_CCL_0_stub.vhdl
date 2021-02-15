-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Tue May 19 22:09:56 2020
-- Host        : DESKTOP-3UBI8F3 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ SinglePass_CCL_0_stub.vhdl
-- Design      : SinglePass_CCL_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    rgb_in : in STD_LOGIC_VECTOR ( 23 downto 0 );
    move_in : in STD_LOGIC_VECTOR ( 23 downto 0 );
    rx_hsync : in STD_LOGIC;
    rx_vsync : in STD_LOGIC;
    rx_de : in STD_LOGIC;
    rx_pclk : in STD_LOGIC;
    immediateRead : in STD_LOGIC;
    led : out STD_LOGIC_VECTOR ( 1 downto 0 );
    params : out STD_LOGIC_VECTOR ( 159 downto 0 );
    validParams : out STD_LOGIC;
    rgb_out : out STD_LOGIC_VECTOR ( 23 downto 0 );
    tx_hsync : out STD_LOGIC;
    tx_vsync : out STD_LOGIC;
    tx_de : out STD_LOGIC
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rgb_in[23:0],move_in[23:0],rx_hsync,rx_vsync,rx_de,rx_pclk,immediateRead,led[1:0],params[159:0],validParams,rgb_out[23:0],tx_hsync,tx_vsync,tx_de";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "SinglePass_CCL,Vivado 2018.3";
begin
end;
