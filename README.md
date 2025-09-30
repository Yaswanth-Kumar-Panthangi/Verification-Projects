# UVM Verification Environment for an 8-bit ALU

This repository contains a comprehensive UVM-based verification environment for a simple 8-bit Arithmetic Logic Unit (ALU). This project is designed to demonstrate the fundamental concepts and components of the Universal Verification Methodology (UVM) in a practical setting.

## ALU DUT Features
The Design Under Test (DUT) is a synchronous 8-bit ALU with the following features:
* **Inputs**: Two 8-bit data inputs (`a`, `b`) and a 3-bit `opcode`.
* **Outputs**: An 8-bit `result` and a 1-bit `carry` flag.
* **Supported Operations**:
    * ADD
    * SUB
    * AND
    * OR
    * XOR
    * NOT
    * Shift Left Logical (SLL)
    * Shift Right Logical (SRL)

## UVM Testbench Features
The verification environment is built using UVM and includes the following key features:

* **Modular Architecture**: The testbench uses two agents (`agent_wr`, `agent_rd`) to handle the DUT's input and output separately. The write agent is configured as `UVM_ACTIVE` to drive stimulus, while the read agent is `UVM_PASSIVE` to only monitor outputs.
* **Constrained-Random Stimulus**: A `uvm_sequence` generates random transactions (`trans` class) to thoroughly test the ALU's functionality. The opcode is randomized using `randc` to ensure all operations are covered cyclically.
* **Self-Checking Scoreboard**: The scoreboard acts as the "brain" of the testbench. It uses a predictive behavioral model (`predict_results`) to calculate the expected output for each input transaction and compares it against the actual output from the DUT.
* **Functional Coverage**: A `covergroup` is implemented in the read monitor to track which ALU operations have been tested, ensuring high-quality verification. The final coverage score is printed at the end of the simulation.
* **Configuration Object**: A dedicated configuration class (`alu_config`) is used to pass down settings like agent activity and the virtual interface handle, making the environment reusable and easy to configure.

## Testbench Architecture
The environment is structured with standard UVM components to ensure modularity and reusability.

* **`env`**: The top-level environment that instantiates and connects the agents and the scoreboard.
* **`agent_wr` (Active)**: Drives transactions to the DUT. Contains a sequencer, driver, and monitor.
* **`agent_rd` (Passive)**: Monitors the DUT's output. Contains only a monitor.
* **`scoreboard`**: Verifies data integrity by comparing actual results with predicted results.
* **`DUT`**: The ALU design being verified.

## How to Run the Simulation

The easiest way to run this simulation is by using the public EDA Playground link. This requires no local setup.

➡️ **[Run the full simulation on EDA Playground](https://edaplayground.com/x/XsuK)**

Alternatively, you can clone this repository and run the simulation using any standard SystemVerilog simulator that supports UVM.

## Author
* **Yaswanth Panthangi**
* **LinkedIn**: [www.linkedin.com/in/yaswanth-panthangi](https://www.linkedin.com/in/yaswanth-panthangi)
