class apb_driver extends uvm_driver ;
  `uvm_component_utils(apb_driver)
   apb_config aco_h;   
//    logic read_data;
   //VIF
   virtual bridge_if.S_DRV s_vif;
   
   function new(string name = "apb_driver", uvm_component parent);
        super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
		if(!uvm_config_db #(apb_config)::get(this,"","apb_config",aco_h))
			`uvm_fatal("S_DRV_VIF_CONFIG", "Can't get")
  endfunction
  
  function void connect_phase(uvm_phase phase);
	s_vif = aco_h.vif;
	if(s_vif == aco_h.vif)
		`uvm_info("DEBUG_MSG","VIF GET SUCCESSFULL", UVM_HIGH)
	else
		`uvm_info("DEBUG_MSG","VIF GET FAILED", UVM_HIGH)
  endfunction

  task run_phase(uvm_phase phase);
	super.run_phase(phase);
	
	forever
	  begin
	    drive();   
	  end
	
  endtask
 
  task drive();
	while(s_vif.s_drv.Psel===0)
		@(s_vif.s_drv);
		
	
	while(s_vif.s_drv.Penable===0)
		@(s_vif.s_drv);

   if(s_vif.s_drv.Pwrite==0)
     begin
	//repeat(2)  
           begin
	
	      s_vif.s_drv.Prdata <= $urandom;
			//$display("====================Prdata============================",s_vif.s_drv.Prdata);
	   end
     end
  
   else
       s_vif.s_drv.Prdata <= 0;

		repeat(2)
			@(s_vif.s_drv);			

	endtask

endclass
