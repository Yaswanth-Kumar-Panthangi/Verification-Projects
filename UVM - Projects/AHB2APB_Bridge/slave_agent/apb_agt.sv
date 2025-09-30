class apb_agt extends uvm_agent;
  `uvm_component_utils(apb_agt)
  
   apb_config pco_h;
   apb_sequencer apb_sequencer_h;
   apb_driver apb_driver_h;
   apb_monitor apb_monitor_h;
  
  function new(string name = "apb_agt", uvm_component parent);
        super.new(name, parent);
  endfunction
   
  function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(apb_config)::get(this, "", "apb_config", pco_h))
	     `uvm_fatal("CONFIG_OBJ", "Can't get in apb_agt")
	 
	  apb_monitor_h = apb_monitor::type_id::create("apb_monitor_h", this);
	  if(pco_h.is_active==UVM_ACTIVE)
	  begin
	     apb_sequencer_h = apb_sequencer::type_id::create("apb_sequencer_h", this);
		 apb_driver_h = apb_driver::type_id::create("apb_driver_h", this);
	  end
  endfunction
  
  function void connect_phase(uvm_phase phase);
     if(pco_h.is_active)
	   apb_driver_h.seq_item_port.connect(apb_sequencer_h.seq_item_export);
  endfunction
endclass
