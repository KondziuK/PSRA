-makelib xcelium_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_2 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../Project.srcs/sources_1/ip/median_bin_5x5_0/ip/delayLineBRAM/sim/delayLineBRAM.v" \
  "../../../../Project.srcs/sources_1/ip/median_bin_5x5_0/imports/ip_repo/delayLinieBRAM_WP.v" \
  "../../../../Project.srcs/sources_1/ip/median_bin_5x5_0/imports/ip_repo/median_bin_5x5.v" \
  "../../../../Project.srcs/sources_1/ip/median_bin_5x5_0/sim/median_bin_5x5_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

