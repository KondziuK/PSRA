-makelib xcelium_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xbip_utils_v3_0_9 \
  "../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_utils_v2_0_5 \
  "../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_pipe_v3_0_5 \
  "../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_wrapper_v3_0_4 \
  "../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_addsub_v3_0_5 \
  "../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_bram18k_v3_0_5 \
  "../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/mult_gen_v12_0_14 \
  "../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/floating_point_v7_0_15 \
  "../../../ipstatic/hdl/floating_point_v7_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_mult_v3_0_5 \
  "../../../ipstatic/hdl/xbip_dsp48_mult_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_multadd_v3_0_5 \
  "../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/div_gen_v5_1_14 \
  "../../../ipstatic/hdl/div_gen_v5_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/div_gen_0/sim/div_gen_0.vhd" \
-endlib
-makelib xcelium_lib/c_reg_fd_v12_0_5 \
  "../../../ipstatic/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_addsub_v3_0_5 \
  "../../../ipstatic/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_addsub_v12_0_12 \
  "../../../ipstatic/hdl/c_addsub_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/add/sim/add.vhd" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/add2/sim/add2.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_2 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/BRAM_params/sim/BRAM_params.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/stackMemory2/sim/stackMemory2.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/mergeControl/sim/mergeControl.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/lineMergeControl/sim/lineMergeControl.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/row_BRAM/sim/row_BRAM.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/stackMemory/sim/stackMemory.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/stack2/sim/stack2.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/chainStack.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/delay.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/delay_BRAM.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/delay_line.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/extractor.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/labeller.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/lutControl.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/max.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/mergedStack.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/min.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/imports/Verilog/position.v" \
  "../../../ipstatic/xil_defaultlib/Algorithm.srcs/sources_1/imports/Verilog/sp_ccl.v" \
  "../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/sim/SinglePass_CCL_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

