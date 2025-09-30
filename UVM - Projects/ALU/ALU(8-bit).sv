`include "uvm_macros.svh"
import uvm_pkg::*;

//----------------------------------------------------------------
// Design Under Test (DUT): 8-bit Arithmetic Logic Unit
//----------------------------------------------------------------
module alu_dut (
    input  logic clk,
    input  logic rst,
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] opcode,
    output logic [7:0] result,
    output logic carry
);
    // Sequential logic for ALU operations, triggered on clock edge
    always_ff @(posedge clk) begin
        if (rst) begin
            {carry,result} = '0;
        end
        else begin
            case(opcode)
                3'b000 : {carry,result} = a + b; // ADD
                3'b001 : {carry,result} = a - b; // SUB
                3'b010 : result         = a & b; // AND
                3'b011 : result         = a | b; // OR
                3'b100 : result         = a ^ b; // XOR
                3'b101 : result         = ~a;    // NOT
                3'b110 : result         = a << 1;// SLL
                3'b111 : result         = a >> 1;// SRL
                default: result         = 8'hXX;
            endcase
        end
    end
endmodule

// Interface to connect the Testbench to the DUT
interface alu_if( input bit clk);
    logic       valid;
    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] opcode;
    logic [7:0] result;
    logic       carry;

    // Clocking block for the write driver
    clocking drv_wr_cb @(posedge clk);
        default input #1 output #1;
        output valid, a, b, opcode;
    endclocking

    // Clocking block for the write monitor
    clocking mon_wr_cb @(posedge clk);
        default input #1 output #1;
        input valid, a, b, opcode, result, carry;
    endclocking

    // Clocking block for the read monitor
    clocking mon_rd_cb @(posedge clk);
        default input #1 output #1;
        input valid, a, b, opcode, result, carry;
    endclocking

    // Modports defining direction for different components
    modport DRV_WR (clocking drv_wr_cb);
    modport MON_WR (clocking mon_wr_cb);
    modport MON_RD (clocking mon_rd_cb);
endinterface


// Defines the transaction item sent through the testbench
class trans extends uvm_sequence_item;

    // Enum for ALU operations for readability
    typedef enum logic [2:0] {
        ADD    = 3'b000,
        SUB    = 3'b001,
        AND_OP = 3'b010,
        OR_OP  = 3'b011,
        XOR_OP = 3'b100,
        NOT_OP = 3'b101,
        SLL    = 3'b110,
        SRL    = 3'b111
    } alu_op_e;

    // Transaction data fields
    rand bit [7:0] a;
    rand bit [7:0] b;
    randc alu_op_e opcode; // randc ensures cyclic randomization
    bit [7:0] result;
    bit carry;

    // UVM field automation macros
    `uvm_object_utils_begin(trans)
        `uvm_field_int(a, UVM_ALL_ON)
        `uvm_field_int(b, UVM_ALL_ON)
        `uvm_field_enum(alu_op_e, opcode, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON)
        `uvm_field_int(carry, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "" );
        super.new(name);
    endfunction

    // Constraint to ensure opcode is always valid
    constraint c_opcode {
        opcode inside {ADD, SUB, AND_OP, OR_OP, XOR_OP, NOT_OP, SLL, SRL};
    }

    // Utility function to print transaction contents
    function string convert2string();
        return $sformatf("a=%0b, b=%0b, opcode=%s, result=%0b, carry=%0b", a, b, opcode.name(), result, carry);
    endfunction
endclass

// Configuration object for the environment
class alu_config extends uvm_object;
    `uvm_object_utils(alu_config)

    function new(string name ="");
        super.new(name);
    endfunction

    // Controls whether agents are active (driving) or passive (monitoring)
    uvm_active_passive_enum is_active_wr;
    uvm_active_passive_enum is_active_rd;

    // Virtual interface handle to be shared across components
    virtual alu_if vif;
endclass

// Drives input transactions to the DUT
class driver_wr extends uvm_driver #(trans);
    `uvm_component_utils(driver_wr)

    virtual alu_if.DRV_WR vif;
    alu_config cfg;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Get the configuration object from the config_db
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(! uvm_config_db #(alu_config) :: get(this,"","alu_config",cfg))
            `uvm_fatal("DRV_VIF_CONFIG","Cannot get VIF");
    endfunction

    // Assign the virtual interface handle
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    // Task to drive a single transaction onto the interface
    task send(trans req);
        @(vif.drv_wr_cb);
        vif.drv_wr_cb.a      <= req.a;
        vif.drv_wr_cb.b      <= req.b;
        vif.drv_wr_cb.opcode <= req.opcode;
        vif.drv_wr_cb.valid  <= 1'b1;
        @(vif.drv_wr_cb);
        vif.drv_wr_cb.valid  <= 1'b0;
    endtask

    // Main task to get items from sequencer and drive them
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            send(req);
            seq_item_port.item_done();
        end
    endtask
endclass

// Monitors DUT inputs and broadcasts them to the scoreboard
class monitor_wr extends uvm_monitor;
    `uvm_component_utils(monitor_wr)

    trans transh;
    alu_config cfg;
    virtual alu_if.MON_WR vif;
    uvm_analysis_port #(trans) ap; // Analysis port to send transactions out

    function new(string name, uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(! uvm_config_db #(alu_config) :: get(this,"","alu_config",cfg))
            `uvm_fatal("MON_VIF_CONFIG","Cannot get VIF");
        ap = new("ap", this);
        transh = trans::type_id::create("transh");
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    // Task to sample interface signals and form a transaction
    task mon();
        @(vif.mon_wr_cb);
        wait (vif.mon_wr_cb.valid == 1'b1);
        transh.a = vif.mon_wr_cb.a;
        transh.b = vif.mon_wr_cb.b;
        transh.opcode = vif.mon_wr_cb.opcode;
        ap.write(transh); // Send the collected transaction
        @(vif.mon_wr_cb);
    endtask

    // Main task to continuously monitor the interface
    task run_phase(uvm_phase phase);
        forever begin
            mon();
        end
    endtask
endclass

// Sequencer to manage and arbitrate sequences for the write driver
class sequencer_wr extends uvm_sequencer #(trans);
    `uvm_component_utils(sequencer_wr)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass

// Placeholder for a read-side driver (not used in this setup)
class driver_rd extends uvm_driver #(trans);
    `uvm_component_utils(driver_rd)
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

// Monitors DUT outputs, broadcasts them, and collects functional coverage
class monitor_rd extends uvm_monitor;
    `uvm_component_utils(monitor_rd)
    trans transh;
    trans transh_cg;
    uvm_analysis_port #(trans) ap;
    virtual alu_if.MON_RD vif;
    alu_config cfg;

    // Covergroup for functional coverage collection
    covergroup alu_cg;
        option.per_instance=1;
        coverpoint transh_cg.a { bins others = default;}
        coverpoint transh_cg.b { bins others = default;}
        coverpoint transh_cg.opcode { bins ops[]={ trans::ADD, trans::SUB, trans::AND_OP, trans::OR_OP, trans::XOR_OP, trans::NOT_OP, trans::SLL, trans::SRL}; }
    endgroup

    function new(string name, uvm_component parent = null);
        super.new(name,parent);
        alu_cg = new(); // Instantiate the covergroup
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(alu_config) ::get(this,"","alu_config",cfg))
            `uvm_fatal("MON_VIF_CONFIG","Cannot get VIF");
        ap = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    // Task to sample DUT outputs
    task mon();
        transh = trans::type_id::create("trans");
        wait (vif.mon_rd_cb.valid == 1'b1); // Assuming valid is pipelined
        repeat(2) @(vif.mon_rd_cb); // Latency of 2 cycles
        transh.a = vif.mon_rd_cb.a;
        transh.b = vif.mon_rd_cb.b;
        transh.opcode = vif.mon_rd_cb.opcode;
        transh.result = vif.mon_rd_cb.result;
        transh.carry  = vif.mon_rd_cb.carry;
        ap.write(transh);
        transh_cg = transh;
        alu_cg.sample(); // Sample data for coverage
    endtask

    task run_phase(uvm_phase phase);
        forever begin
            mon();
        end
    endtask

    // Report coverage at the end of the test
    function void report_phase(uvm_phase phase);
      `uvm_info(get_full_name(), $sformatf("Functional Coverage: %0d%%", alu_cg.get_coverage()), UVM_NONE)
    endfunction
endclass

// Placeholder for a read-side sequencer
class sequencer_rd extends uvm_sequencer #(trans);
    `uvm_component_utils(sequencer_rd)
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass

// Agent for the DUT input (write side)
class agent_wr extends uvm_agent;
    `uvm_component_utils(agent_wr)

    driver_wr drvh;
    monitor_wr monh;
    sequencer_wr seqrh;
    alu_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build driver, sequencer, and monitor based on is_active setting
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(alu_config) ::get(this,"","alu_config",cfg))
            `uvm_fatal("MON_VIF_CONFIG","Cannot get VIF");
        monh = monitor_wr::type_id::create("monh",this);
        if(cfg.is_active_wr) begin
            drvh = driver_wr::type_id::create("drvh",this);
            seqrh = sequencer_wr::type_id::create("seqrh",this);
        end
    endfunction

    // Connect the driver and sequencer
    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.is_active_wr == UVM_ACTIVE) begin
            drvh.seq_item_port.connect(seqrh.seq_item_export);
        end
    endfunction
endclass

// Agent for the DUT output (read side)
class agent_rd  extends uvm_agent;
    `uvm_component_utils(agent_rd)

    driver_rd drvh;
    monitor_rd monh;
    sequencer_rd seqrh;
    alu_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monh = monitor_rd::type_id::create("monh",this); // Always build monitor
        if(!uvm_config_db #(alu_config) ::get(this, "", "alu_config",cfg))
            `uvm_fatal("MON_VIF_CONFIG","Cannot get VIF");
        if(cfg.is_active_rd) begin // Build driver/sequencer if active
            drvh = driver_rd::type_id::create("drvh",this);
            seqrh = sequencer_rd::type_id::create("seqrh",this);
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.is_active_rd == UVM_ACTIVE) begin
            drvh.seq_item_port.connect(seqrh.seq_item_export);
        end
    endfunction
endclass

// Scoreboard for verifying DUT functionality
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // FIFOs to get transactions from monitors
    uvm_tlm_analysis_fifo #(trans) wr_mon_fifo;
    uvm_tlm_analysis_fifo #(trans) rd_mon_fifo;

    // Queue to store input transactions for later comparison
    protected trans wr_item_q[$];
    trans wr_trans, rd_trans, expected_trans;
    int error_count = 0, success_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create FIFOs and transaction objects
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_mon_fifo = new("wr_mon_fifo", this);
        rd_mon_fifo = new("rd_mon_fifo", this);
        expected_trans = new("expected_trans");
    endfunction

    // Main checking logic
    task run_phase(uvm_phase phase);
        fork
            // Process 1: Collect input transactions and store them in a queue
            forever begin
                trans collected_wr_trans;
                wr_mon_fifo.get(collected_wr_trans);
                `uvm_info("SCOREBOARD_INPUT", $sformatf("Got write transaction: %s", collected_wr_trans.convert2string()), UVM_HIGH)
                wr_item_q.push_back(collected_wr_trans);
            end

            // Process 2: Collect output transactions, predict, and compare
            forever begin
                // Get the actual result from the output monitor
                rd_mon_fifo.get(rd_trans);
                `uvm_info("SCOREBOARD_OUTPUT", $sformatf("Got read transaction: %s", rd_trans.convert2string()), UVM_HIGH)
                
                // Wait for the corresponding input transaction
                wait (wr_item_q.size() > 0);
                wr_trans = wr_item_q.pop_front();

                // Predict the expected result
                predict_results(wr_trans, expected_trans);
                
                // Compare actual vs. expected
                if (compare_results(rd_trans, expected_trans)) begin
                    `uvm_info("SCOREBOARD", $sformatf("PASS: Input: (a=%0h, b=%0h, op=%s) -> Result: %0h",
                        wr_trans.a, wr_trans.b, wr_trans.opcode.name(), rd_trans.result), UVM_LOW)
                    success_count++;
                end else begin
                    `uvm_error("SCOREBOARD", $sformatf("FAIL: Mismatch detected!\n  Input:    %s\n  Expected: %s\n  Actual:   %s",
                        wr_trans.convert2string(), expected_trans.convert2string(), rd_trans.convert2string()))
                    error_count++;
                end
            end
        join
    endtask

    // Behavioral model of the DUT to predict results
    virtual function void predict_results(trans actual_in, inout trans predicted_out);
        predicted_out.a = actual_in.a;
        predicted_out.b = actual_in.b;
        predicted_out.opcode = actual_in.opcode;
        case(actual_in.opcode)
            trans::ADD:   {predicted_out.carry,predicted_out.result}= actual_in.a + actual_in.b;
            trans::SUB:   {predicted_out.carry,predicted_out.result}= actual_in.a - actual_in.b;
            trans::AND_OP: predicted_out.result = actual_in.a & actual_in.b;
            trans::OR_OP:  predicted_out.result = actual_in.a | actual_in.b;
            trans::XOR_OP: predicted_out.result = actual_in.a ^ actual_in.b;
            trans::NOT_OP: predicted_out.result = ~actual_in.a;
            trans::SLL:    predicted_out.result = actual_in.a << 1;
            trans::SRL:    predicted_out.result = actual_in.a >> 1;
        endcase
    endfunction

    // Comparison logic
    virtual function bit compare_results(trans actual, trans expected);
        bit is_match = 1;
        if (actual.result !== expected.result) is_match = 0;
        // Only check carry for relevant operations
        if ((expected.opcode == trans::ADD || expected.opcode == trans::SUB) && (actual.carry !== expected.carry)) begin
            is_match = 0;
        end
        return is_match;
    endfunction

    // Report final pass/fail summary
    function void report_phase(uvm_phase phase);
        `uvm_info(get_full_name(), $sformatf("SCOREBOARD SUMMARY: %0d PASSED, %0d FAILED", success_count, error_count), UVM_NONE)
    endfunction
endclass

// Top-level environment class
class env extends uvm_env;
    `uvm_component_utils(env)
    agent_wr agt_wrh;
    agent_rd agt_rdh;
    scoreboard sbh;
    alu_config cfg;
    virtual alu_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create config, agents, and scoreboard
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg = alu_config :: type_id :: create("cfg");
        cfg.is_active_wr = UVM_ACTIVE;  // Write agent is active
        cfg.is_active_rd = UVM_PASSIVE; // Read agent is passive
        uvm_config_db #(virtual alu_if) :: get(this,"","alu_if", cfg.vif);
        uvm_config_db #(alu_config)     :: set(this,"*","alu_config",cfg);

        agt_wrh = agent_wr   :: type_id :: create("agent_wr",   this);
        agt_rdh = agent_rd   :: type_id :: create("agent_rd",   this);
        sbh     = scoreboard :: type_id :: create("scoreboard", this);
    endfunction

    // Connect phase: connect monitor analysis ports to scoreboard FIFOs
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt_wrh.monh.ap.connect(sbh.wr_mon_fifo.analysis_export);
        agt_rdh.monh.ap.connect(sbh.rd_mon_fifo.analysis_export);
    endfunction
endclass

// Base sequence to generate random ALU transactions
class base_sequence extends uvm_sequence #(trans);
    `uvm_object_utils(base_sequence)
    int num_transactions = 100;

    function new(string name="");
        super.new(name);
    endfunction

    // Task to generate and send a specified number of transactions
    task body();
        repeat(num_transactions) begin
            req = trans :: type_id :: create("req");
            start_item(req);
            void'(req.randomize());
            finish_item(req);
        end
    endtask
endclass

// Top-level test class
class test extends uvm_test;
    `uvm_component_utils(test)
    env envh;
    base_sequence seqh;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    // Build the environment and sequence
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        envh = env::type_id::create("env",this);
        seqh = base_sequence::type_id::create("seqh");
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        uvm_top.print_topology();
    endfunction

    // Start the main sequence on the write sequencer
    task run_phase(uvm_phase phase);
        phase.raise_objection(this, "Starting ALU test sequence");
        seqh.start(envh.agt_wrh.seqrh);
        #100ns; // Add a small delay for final transactions to complete
        phase.drop_objection(this, "Finishing ALU test sequence");
    endtask
endclass

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