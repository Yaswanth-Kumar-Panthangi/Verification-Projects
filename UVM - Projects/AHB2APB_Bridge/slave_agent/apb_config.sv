class apb_config extends uvm_object;
  `uvm_object_utils(apb_config)
  
   //VIF
   virtual bridge_if vif;
   uvm_active_passive_enum is_active;
  
  function new(string name = "apb_config");
    super.new(name);
  endfunction

endclass
