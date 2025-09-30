class env_config extends uvm_object;
  `uvm_object_utils(env_config)
  
   bit has_master_agent;
   bit has_slave_agent;
   int no_of_master_agents;
   int no_of_slave_agents;
   ahb_config hco_h[];
   apb_config pco_h[];
  
  function new(string name = "env_config");
    super.new(name);
  endfunction

endclass
