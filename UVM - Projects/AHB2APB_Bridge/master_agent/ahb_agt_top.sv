class ahb_agt_top extends uvm_env;
  `uvm_component_utils(ahb_agt_top)
  
   ahb_agt ahb_agt_h[];
   env_config eco_h;
  
   function new(string name = "ahb_agt_top", uvm_component parent);
        super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(env_config)::get(this, "", "env_config", eco_h))
	     `uvm_fatal("CONFIG_OBJ", "Can't get in ahb_agt_top")
	  if(eco_h.has_master_agent)
	     ahb_agt_h = new[eco_h.no_of_master_agents];
	  foreach(ahb_agt_h[i])
	     ahb_agt_h[i] = ahb_agt::type_id::create($sformatf("ahb_agt_h[%0d]", i), this);
   endfunction
endclass
