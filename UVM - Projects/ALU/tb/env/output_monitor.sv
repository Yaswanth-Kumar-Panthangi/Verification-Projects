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