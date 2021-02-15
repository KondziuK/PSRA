onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib median_bin_5x5_0_opt

do {wave.do}

view wave
view structure
view signals

do {median_bin_5x5_0.udo}

run -all

quit -force
