@echo off
REM ============================================================
REM QuestaSim Flow: Compile + Run Simulation (using files.f)
REM ============================================================

REM Step 1: Clean old work directory
rmdir /s /q work

REM Step 2: Create work library
vlib work
vmap work work

REM Step 3: Compile all design + tb files
echo [INFO] Compiling sources...
vlog -sv -f files.f +acc

REM Step 4: Run simulation (replace tb_counter with your actual top tb module name)
echo [INFO] Running simulation...
vsim work.count_top -do "run -all; quit"

echo [INFO] Simulation completed.
