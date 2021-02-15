vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/xbip_utils_v3_0_9
vlib activehdl/axi_utils_v2_0_5
vlib activehdl/xbip_pipe_v3_0_5
vlib activehdl/xbip_dsp48_wrapper_v3_0_4
vlib activehdl/xbip_dsp48_addsub_v3_0_5
vlib activehdl/xbip_bram18k_v3_0_5
vlib activehdl/mult_gen_v12_0_14
vlib activehdl/floating_point_v7_0_15
vlib activehdl/xbip_dsp48_mult_v3_0_5
vlib activehdl/xbip_dsp48_multadd_v3_0_5
vlib activehdl/div_gen_v5_1_14
vlib activehdl/c_reg_fd_v12_0_5
vlib activehdl/xbip_addsub_v3_0_5
vlib activehdl/c_addsub_v12_0_12
vlib activehdl/blk_mem_gen_v8_4_2

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap xbip_utils_v3_0_9 activehdl/xbip_utils_v3_0_9
vmap axi_utils_v2_0_5 activehdl/axi_utils_v2_0_5
vmap xbip_pipe_v3_0_5 activehdl/xbip_pipe_v3_0_5
vmap xbip_dsp48_wrapper_v3_0_4 activehdl/xbip_dsp48_wrapper_v3_0_4
vmap xbip_dsp48_addsub_v3_0_5 activehdl/xbip_dsp48_addsub_v3_0_5
vmap xbip_bram18k_v3_0_5 activehdl/xbip_bram18k_v3_0_5
vmap mult_gen_v12_0_14 activehdl/mult_gen_v12_0_14
vmap floating_point_v7_0_15 activehdl/floating_point_v7_0_15
vmap xbip_dsp48_mult_v3_0_5 activehdl/xbip_dsp48_mult_v3_0_5
vmap xbip_dsp48_multadd_v3_0_5 activehdl/xbip_dsp48_multadd_v3_0_5
vmap div_gen_v5_1_14 activehdl/div_gen_v5_1_14
vmap c_reg_fd_v12_0_5 activehdl/c_reg_fd_v12_0_5
vmap xbip_addsub_v3_0_5 activehdl/xbip_addsub_v3_0_5
vmap c_addsub_v12_0_12 activehdl/c_addsub_v12_0_12
vmap blk_mem_gen_v8_4_2 activehdl/blk_mem_gen_v8_4_2

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_9 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_5 -93 \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_14 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_0_15 -93 \
"../../../ipstatic/hdl/floating_point_v7_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_mult_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_dsp48_mult_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_multadd_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \

vcom -work div_gen_v5_1_14 -93 \
"../../../ipstatic/hdl/div_gen_v5_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/div_gen_0/sim/div_gen_0.vhd" \

vcom -work c_reg_fd_v12_0_5 -93 \
"../../../ipstatic/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work xbip_addsub_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_12 -93 \
"../../../ipstatic/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/add/sim/add.vhd" \
"../../../../Project.srcs/sources_1/ip/SinglePass_CCL_0/Algorithm.srcs/sources_1/ip/add2/sim/add2.vhd" \

vlog -work blk_mem_gen_v8_4_2  -v2k5 \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 \
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

vlog -work xil_defaultlib \
"glbl.v"

