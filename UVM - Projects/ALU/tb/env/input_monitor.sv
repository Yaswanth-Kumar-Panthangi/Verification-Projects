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
