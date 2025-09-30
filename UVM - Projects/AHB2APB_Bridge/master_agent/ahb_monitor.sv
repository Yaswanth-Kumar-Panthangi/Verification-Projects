class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
   ahb_config aco_h;
   ahb_xtn xtn;

	  uvm_analysis_port #(ahb_xtn) a_port;

   //VIF
   virtual bridge_if.M_MON m_vif;
   
   function new(string name = "ahb_monitor", uvm_component parent);
        super.new(name, parent);
	a_port = new("a_port", this);
   endfunction

	  function void build_phase(uvm_phase phase);
	    if(!uvm_config_db #(ahb_config)::get(this, "", "ahb_config", aco_h))
		   `uvm_fatal("M_MON_VIF_CONFIG","Can't get")
	  endfunction
	  
	  function void connect_phase(uvm_phase phase);
	     m_vif = aco_h.vif;
	  endfunction
	  
	  task run_phase(uvm_phase phase);
	      super.run_phase(phase);
		  `uvm_info("DEBUG_MSG", "Run_phase of M_MON started", UVM_HIGH);
		  forever
		    data_from_dut();
	  endtask

	 task data_from_dut();
		xtn=ahb_xtn::type_id::create("xtn");
	//	@(m_vif.m_mon);
		while(m_vif.m_mon.Hreadyout!==1)
			@(m_vif.m_mon);
		while((m_vif.m_mon.Htrans!==2'b10) && (m_vif.m_mon.Htrans!==2'b11))
			@(m_vif.m_mon);


	//	wait(m_vif.m_mon.Htrans===2 || m_vif.m_mon.Htrans===3)begin


		xtn.Haddr=m_vif.m_mon.Haddr;
		xtn.Hresetn=m_vif.m_mon.Hrstn;
		xtn.Hwrite=m_vif.m_mon.Hwrite;
		xtn.Htrans=m_vif.m_mon.Htrans;
		xtn.Hsize=m_vif.m_mon.Hsize;
		xtn.Hburst=m_vif.m_mon.Hburst;
		xtn.Hresp=m_vif.m_mon.Hresp;
		
	
		@(m_vif.m_mon);

		while(m_vif.m_mon.Hreadyout!==1)
			@(m_vif.m_mon);
		while((m_vif.m_mon.Htrans!==2'b10) && (m_vif.m_mon.Htrans!==2'b11))
			@(m_vif.m_mon);

		
//	while(m_vif.m_mon.Hreadyout && (m_vif.m_mon.Htrans!==2'b10) && (m_vif.m_mon.Htrans!==2'b11))
//			@(m_vif.m_mon);
		
		if(m_vif.m_mon.Hwrite)
			xtn.Hwdata=m_vif.m_mon.Hwdata;
		
		else
			xtn.Hrdata=m_vif.m_mon.Hrdata;
		
				`uvm_info("MASTER_MONITOR",$sformatf("printing from master monitor \n %s",xtn.sprint()),UVM_LOW)
	
	endtask
endclass
