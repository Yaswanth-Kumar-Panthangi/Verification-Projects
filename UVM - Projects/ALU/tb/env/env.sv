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
