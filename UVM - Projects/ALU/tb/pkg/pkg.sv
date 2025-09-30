//----------------------------------------------------------------
// ALU Package
// Includes all UVM class files to be compiled together
//----------------------------------------------------------------
package alu_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "../trans/alu_transaction.sv"
    `include "../seqs/alu_sequences.sv"
    `include "../env/alu_driver.sv"
    `include "../env/alu_monitor.sv"
    `include "../env/alu_sequencer.sv" // <-- ADDED: New sequencer file in correct order
    `include "../env/alu_agent.sv"
    `include "../env/alu_scoreboard.sv"
    `include "../env/alu_env.sv"
    `include "../tests/alu_tests.sv"
endpackage

