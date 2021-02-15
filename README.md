# PSRA
Detection system of lost baggage

Creating a system to detect lost baggage with usage of SoC board ZYBO Z7.
First phase was to create software model by using OpenCV library. Model consists of segmentation of foreground objects, segmentation of moving objects, filtration, indexation and analysis of detected objects.
Because of CoronaVirus crisis the implementation on real SoC was suspended. Instead, an fpga simulation model was created in Vivado by using Verilog and VHDL languages. The created model consisted of segmentation of foreground objects, segmentation of moving objects, filtration and indexation. Output images from the fpga model were then processed into part of previous created software model.This part was responsible of analysis of detected objects. By doing that way, the simulation of transferring data through AXI between PL and PS part was created.
