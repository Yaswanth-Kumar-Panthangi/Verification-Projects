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