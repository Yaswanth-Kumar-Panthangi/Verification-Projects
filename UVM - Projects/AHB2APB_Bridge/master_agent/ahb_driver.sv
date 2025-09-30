class ahb_driver extends uvm_driver#(ahb_xtn) ;
  `uvm_component_utils(ahb_driver)
   ahb_config aco_h;
  
   //VIF
   virtual bridge_if.M_DRV m_vif;
  
   function new(string name = "ahb_driver", uvm_component parent);
        super.new(name, parent);
   endfunction

      function void build_phase(uvm_phase phase);
           super.build_phase(phase);
           if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config", aco_h))
            `uvm_fatal("M_DRV_VIF_CONFIG", "Can't get")
      endfunction

      function void connect_phase(uvm_phase phase);
		 m_vif = aco_h.vif;
		 if(m_vif == aco_h.vif)
		   `uvm_info("DEBUG_MSG","VIF GET SUCCESSFULL", UVM_HIGH)
		 else
		   `uvm_info("DEBUG_MSG","VIF GET FAILED", UVM_HIGH)
      endfunction
      task run_phase(uvm_phase phase);
		@(m_vif.m_drv);
		
		m_vif.m_drv.Hrstn <= 0;
		@(m_vif.m_drv);
		m_vif.m_drv.Hrstn <= 1;
		@(m_vif.m_drv);
		
	forever begin	
		seq_item_port.get_next_item(req);

		drive(req);
	
		seq_item_port.item_done();
		end
	endtask
	
     task drive(ahb_xtn xtn);
		
		while(m_vif.m_drv.Hreadyout!==1)
			@(m_vif.m_drv);

		m_vif.m_drv.Htrans <= xtn.Htrans;
		m_vif.m_drv.Haddr <= xtn.Haddr;
		m_vif.m_drv.Hsize <= xtn.Hsize;
		m_vif.m_drv.Hburst <= xtn.Hburst;
		m_vif.m_drv.Hwrite <= xtn.Hwrite;
		m_vif.m_drv.Hreadyin <= 1'b1;

		@(m_vif.m_drv);

		while(m_vif.m_drv.Hreadyout!== 1)
			@(m_vif.m_drv);
			
		if(xtn.Hwrite)
			m_vif.m_drv.Hwdata <= xtn.Hwdata;
			else
			m_vif.m_drv.Hwdata <=0;
			`uvm_info("MASTER_DRIVER",$sformatf("printing from master driver \n %s",xtn.sprint()),UVM_LOW)
	endtask

endclass
