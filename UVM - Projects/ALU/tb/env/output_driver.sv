// Placeholder for a read-side driver (not used in this setup)
class driver_rd extends uvm_driver #(trans);
    `uvm_component_utils(driver_rd)
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass