class ahb_agt extends uvm_agent;
  `uvm_component_utils(ahb_agt)
  
   ahb_config hco_h;
   ahb_sequencer ahb_sequencer_h;
   ahb_driver ahb_driver_h;
   ahb_monitor ahb_monitor_h;
  
  function new(string name = "ahb_agt", uvm_component parent);
        super.new(name, parent);
  endfunction
   
  function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(ahb_config)::get(this, "", "ahb_config", hco_h))
	     `uvm_fatal("CONFIG_OBJ", "Can't get in ahb_agt")
	 
	  ahb_monitor_h = ahb_monitor::type_id::create("ahb_monitor_h", this);
	  if(hco_h.is_active==UVM_ACTIVE)
	  begin
	     ahb_sequencer_h = ahb_sequencer::type_id::create("ahb_sequencer_h", this);
		 ahb_driver_h = ahb_driver::type_id::create("ahb_driver_h", this);
	  end
  endfunction
  
  function void connect_phase(uvm_phase phase);
       if(hco_h.is_active)
	      ahb_driver_h.seq_item_port.connect(ahb_sequencer_h.seq_item_export);
  endfunction
  
endclass
