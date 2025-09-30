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