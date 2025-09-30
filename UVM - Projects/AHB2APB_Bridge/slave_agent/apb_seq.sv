class apb_seq extends uvm_sequence #(apb_xtn);
	`uvm_object_utils(apb_seq)
	
	function new(string name="apb_seq");
		super.new(name);
	endfunction


	task body();
		req=apb_xtn::type_id::create("req");
		endtask
endclass
