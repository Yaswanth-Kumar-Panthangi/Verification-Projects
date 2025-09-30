class ahb_seq extends uvm_sequence #(ahb_xtn);
	`uvm_object_utils(ahb_seq)
	
//=================global variables======================//
	bit [31:0] haddr;
	bit hwrite;
	bit [2:0] hsize,hburst;
	bit [9:0]hlength;

	function new(string name="ahb_seq");
		super.new(name);
	endfunction

endclass


//============================================ SINGLE TRANSFER SEQUENCE ================================//
class single_transfer extends ahb_seq;
	`uvm_object_utils(single_transfer)
		
	function new(string name="single_transfer");
		super.new(name);	
	endfunction

	task body;
//repeat(1)
	begin
		req = ahb_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with{Hburst==3'b000; Htrans==2'b10;});
		`uvm_info("single_sequence",$sformatf("printing from sequence \n %s", req.sprint()),UVM_MEDIUM) 
		finish_item(req);
	end
	endtask
		

endclass



//============================================= INCR TRANSFER SEQUENCE =============================//
class incr_transfer extends ahb_seq;
	`uvm_object_utils(incr_transfer)
	
	function new(string name = "incr_transfer");
		super.new(name);
	endfunction
//--------------------------------------------- NON SEQUENTIAL --------------------------------------//
	task body;
//	repeat(1)
	begin
		req = ahb_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans==2'b10; Hburst inside{3}; Hwrite==1;});
		finish_item(req); 
	
//----------------------------------------update local properities with xtn data ------------------------------------//
	haddr = req.Haddr;
	hsize = req.Hsize;
	hwrite = req.Hwrite;
	hburst = req.Hburst;
	hlength = req.Hlength;

 
//-------------------------------------------- SEQUENTIAL ------------------------------------------------------//
	for(int i=1; i<hlength; i++)
		begin
	//	req = src_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans==2'b11;
						Hwrite==hwrite;
						Hsize==hsize;
						Hburst==hburst;
					//	Haddr==haddr;
						Haddr==haddr+(2**hsize);});
		finish_item(req);
		haddr = req.Haddr;
		end
	end
	endtask




endclass



//======================================================= WRAP SEQUENCE ================================================//
class wrap_transfer extends ahb_seq;
	`uvm_object_utils(wrap_transfer)


	bit[31:0] start_addr,boundary_addr;


	function new(string name="wrap_transfer");
		super.new(name);
	endfunction

//--------------------------------------------- NON SEQUENTIAL --------------------------------------//
	task body;
//	repeat(1)
		begin
		req = ahb_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Htrans==2'b10; Hburst inside{2,4,6};});
                // req.print();
		finish_item(req); 
	req.print();
	
	haddr = req.Haddr;
	hsize = req.Hsize;
	hwrite = req.Hwrite;
	hburst = req.Hburst;
	hlength = req.Hlength;


	start_addr=int'((haddr/((2**hsize)*hlength))*((2**hsize)*hlength));

	boundary_addr=start_addr+((2**hsize)*hlength);

	haddr = (req.Haddr+(2**hsize));


//-------------------------------------------- SEQUENTIAL ------------------------------------------------------//

	for(int i=1; i<hlength; i++)
		begin
			if(haddr==boundary_addr)
				haddr=start_addr;

				start_item(req);
				assert(req.randomize() with {Haddr == haddr;
							Htrans == 2'b11;
							Hsize == hsize;
							Hburst == hburst;
							Hwrite == hwrite;});
                             //  req.print();

				finish_item(req);
		haddr=req.Haddr+(2**req.Hsize);
  		end
	end
	endtask
	
endclass
