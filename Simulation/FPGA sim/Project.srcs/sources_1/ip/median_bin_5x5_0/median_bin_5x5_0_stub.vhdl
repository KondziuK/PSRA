-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri May 15 17:54:52 2020
-- Host        : DESKTOP-3UBI8F3 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top median_bin_5x5_0 -prefix
--               median_bin_5x5_0_ median_bin_5x5_0_stub.vhdl
-- Design      : median_bin_5x5_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity median_bin_5x5_0 is
  Port ( 
    clk : in STD_LOGIC;
    de_in : in STD_LOGIC;
    hsync_in : in STD_LOGIC;
    vsync_in : in STD_LOGIC;
    fos_in : in STD_LOGIC_VECTOR ( 23 downto 0 );
    cfd_in : in STD_LOGIC_VECTOR ( 23 downto 0 );
    de_out : out STD_LOGIC;
    hsync_out : out STD_LOGIC;
    vsync_out : out STD_LOGIC;
    rgb_fos_median_out : out STD_LOGIC_VECTOR ( 23 downto 0 );
    rgb_cfd_out : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );

end median_bin_5x5_0;

architecture stub of median_bin_5x5_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,de_in,hsync_in,vsync_in,fos_in[23:0],cfd_in[23:0],de_out,hsync_out,vsync_out,rgb_fos_median_out[23:0],rgb_cfd_out[23:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "median_bin_5x5,Vivado 2018.3";
begin
end;
