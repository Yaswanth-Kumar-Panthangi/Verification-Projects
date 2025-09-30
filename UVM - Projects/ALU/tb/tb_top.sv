//----------------------------------------------------------------
// Testbench Top Module
// Instantiates DUT, interface, and starts the UVM test
//----------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;
import alu_pkg::*;

// Top-level module to instantiate DUT and testbench
module top;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    test testh;
    bit clk;
    bit rst;
    alu_if vif(clk); // Instantiate the interface

    // Instantiate the DUT and connect it to the interface
    alu_dut DUT (.clk(clk), .rst(rst), .a(vif.a), .b(vif.b), .opcode(vif.opcode), .result(vif.result), .carry(vif.carry));

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        rst = 1;
        #10 rst = 0;
    end

    // Main simulation block
    initial begin
        // Set the virtual interface in the config_db for the testbench to use
        uvm_config_db #(virtual alu_if)::set(null, "*", "alu_if", vif);
        // Run the UVM test
        run_test("test");
    end
endmodule