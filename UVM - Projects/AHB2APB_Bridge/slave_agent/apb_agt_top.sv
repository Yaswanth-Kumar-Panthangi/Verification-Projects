class apb_agt_top extends uvm_env;
  `uvm_component_utils(apb_agt_top)
  
   apb_agt apb_agt_h[];
   env_config eco_h;
  
   function new(string name = "apb_agt_top", uvm_component parent);
        super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(env_config)::get(this, "", "env_config", eco_h))
	     `uvm_fatal("CONFIG_OBJ", "Can't get in apb_agt_top")
	  if(eco_h.has_slave_agent)
	     apb_agt_h = new[eco_h.no_of_slave_agents];
	  foreach(apb_agt_h[i])
	     apb_agt_h[i] = apb_agt::type_id::create($sformatf("apb_agt_h[%0d]", i), this);
   endfunction
endclass
