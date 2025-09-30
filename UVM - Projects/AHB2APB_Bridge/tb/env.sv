class env extends uvm_env;
   `uvm_component_utils(env)
   
    ahb_agt_top ahb_agt_top_h;
    apb_agt_top apb_agt_top_h;
    env_config eco_h;
    sb sbh;
   function new(string name = "env", uvm_component parent);
        super.new(name, parent);
   endfunction
	
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(env_config)::get(this, "", "env_config", eco_h))
	     `uvm_fatal("CONFIG_OBJ", "Can't get in env")
	  if(eco_h.has_master_agent)
	      ahb_agt_top_h = ahb_agt_top::type_id::create("ahb_agt_top_h", this);
	  if(eco_h.has_slave_agent)
	      apb_agt_top_h = apb_agt_top::type_id::create("apb_agt_top_h", this);
	sbh = sb::type_id::create("sbh",this);	
   endfunction

function void connect_phase(uvm_phase phase);
	      super.connect_phase(phase);
     for(int i=0;i<eco_h.no_of_master_agents;i++)		
	ahb_agt_top_h.ahb_agt_h[i].ahb_monitor_h.a_port.connect(sbh.ahb_fifo[i].analysis_export);
     for(int i=0;i<eco_h.no_of_slave_agents;i++)		
	ahb_agt_top_h.ahb_agt_h[i].ahb_monitor_h.a_port.connect(sbh.ahb_fifo[i].analysis_export);
endfunction
endclass
