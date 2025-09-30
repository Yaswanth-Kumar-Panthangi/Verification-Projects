class base_test extends uvm_test;
   `uvm_component_utils(base_test)
    
   env_config eco_h;
   env env_h;
   bit has_master_agent = 1;
   bit has_slave_agent = 1;
   int no_of_master_agents = 1;
   int no_of_slave_agents = 1;
   ahb_config hco_h[];
   apb_config pco_h[];
   
   function new(string name = "base_test", uvm_component parent);
      super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
      eco_h = env_config::type_id::create("eco_h");
	  if(has_master_agent)
	  begin
	    hco_h = new[no_of_master_agents];
		foreach(hco_h[i])
		begin
		  hco_h[i] = ahb_config::type_id::create($sformatf("hco_h[%0d]", i));
		  hco_h[i].is_active = UVM_ACTIVE;
		  uvm_config_db #(ahb_config)::set(this, $sformatf("env_h.ahb_agt_top_h.ahb_agt_h[%0d]*", i), "ahb_config", hco_h[i]);
		  //get VIF
		  if(!uvm_config_db #(virtual bridge_if)::get(this, "", "vif_ahb", hco_h[i].vif))
               		`uvm_fatal("VIF CONFIG","Can't get vif")
		$display("test config get",hco_h[i].vif);			
		  eco_h.hco_h[i] = hco_h[i];
		end
	  end
	  
	  if(has_slave_agent)
	  begin
	    pco_h = new[no_of_slave_agents];
		foreach(pco_h[i])
		begin
		  pco_h[i] = apb_config::type_id::create($sformatf("pco_h[%0d]", i));
		  pco_h[i].is_active = UVM_ACTIVE;
		  uvm_config_db #(apb_config)::set(this, $sformatf("env_h.apb_agt_top_h.apb_agt_h[%0d]*", i), "apb_config", pco_h[i]);
		  //get VIF
		  if(!uvm_config_db #(virtual bridge_if)::get(this, "", "vif_apb", pco_h[i].vif))
               		`uvm_fatal("VIF CONFIG","Can't get vif")		
		  eco_h.pco_h[i] = pco_h[i];
		end
	  end
	  
	  uvm_config_db #(env_config)::set(this, "*", "env_config", eco_h);
	  eco_h.has_master_agent = has_master_agent;
	  eco_h.has_slave_agent = has_slave_agent;
	  eco_h.no_of_master_agents = no_of_master_agents;
	  eco_h.no_of_slave_agents = no_of_slave_agents;
	  
	  env_h = env::type_id::create("env_h", this);
	  
   endfunction
   
   function void start_of_simulation_phase(uvm_phase phase);
       uvm_top.print_topology();
   endfunction
   
endclass

class single_transfer_test extends base_test;
	`uvm_component_utils(single_transfer_test);

	single_transfer s_t;


	function new(string name="single_transfer_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		s_t=single_transfer::type_id::create("s_t");
		s_t.start(env_h.ahb_agt_top_h.ahb_agt_h[0].ahb_sequencer_h);
		#60;
		phase.drop_objection(this);
	endtask
endclass

class incr_transfer_test extends base_test;
	`uvm_component_utils(incr_transfer_test);

	incr_transfer incr_t;

	function new(string name="incr_transfer_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		incr_t=incr_transfer::type_id::create("incr_t");
		incr_t.start(env_h.ahb_agt_top_h.ahb_agt_h[0].ahb_sequencer_h);
		#200;
		phase.drop_objection(this);
	endtask
endclass

class wrap_transfer_test extends base_test;
	`uvm_component_utils(wrap_transfer_test);

	wrap_transfer wrap_h;

	function new(string name="wrap_transfer_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		wrap_h=wrap_transfer::type_id::create("wrap_h");
		wrap_h.start(env_h.ahb_agt_top_h.ahb_agt_h[0].ahb_sequencer_h);
		#100;
		phase.drop_objection(this);
	endtask
endclass
