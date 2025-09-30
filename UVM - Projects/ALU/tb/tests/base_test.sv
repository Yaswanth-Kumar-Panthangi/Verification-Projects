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
