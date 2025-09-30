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