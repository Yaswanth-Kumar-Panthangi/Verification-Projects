# Clean previous work
vdel -all
vlib work
vmap work work

# Compile using file list
vlog -sv -f files.f +define+UVM_NO_DPI

# Elaborate top module
vsim -novopt work.tb_top -classdebug -uvmcontrol=all -sv_seed random

# Run simulation
run -all
