class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
   apb_config aco_h;   
   //VIF
	uvm_analysis_port #(apb_xtn) ap_s;
   virtual bridge_if s_if;
	apb_xtn xtn_h;
   
   	function new(string name = "apb_monitor", uvm_component parent);
        	super.new(name, parent);
		ap_s = new("apb_xtn",this);
  	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(apb_config)::get(this,"","apb_config",aco_h))
			`uvm_fatal("[SLAVE_MONITOR]","can't get the slave_config in slave_monitor")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		s_if = aco_h.vif;
	endfunction


	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		@(s_if.s_mon);
		forever 
			begin	
				collect_data();
				`uvm_info("SLAVE MONITOR",$sformatf("printing from slave monitor \n %s",xtn_h.sprint()),UVM_LOW);

				ap_s.write(xtn_h);

			end

	endtask


		
	task collect_data();
		
		xtn_h = apb_xtn::type_id::create("xtn_h");
			@(s_if.s_mon);

		while(s_if.s_mon.Penable!==1)
			@(s_if.s_mon);
		
		while(s_if.s_drv.Psel==0)
		@(s_if.s_drv);

		xtn_h.Paddr = s_if.s_mon.Paddr;
		xtn_h.Pwrite = s_if.s_mon.Pwrite;
		xtn_h.Psel = s_if.s_mon.Psel;
		xtn_h.Penable = s_if.s_mon.Penable;

	

		if(s_if.s_mon.Pwrite)begin
			xtn_h.Pwdata = s_if.s_mon.Pwdata;
			$display("====================xtn_h.pwdata============================",s_if.s_mon.Pwdata);
				end	
		else 
			xtn_h.Prdata = s_if.s_mon.Prdata;


	//	repeat(2)
			@(s_if.s_mon);
			
		
	endtask
endclass
