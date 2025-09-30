// Placeholder for a read-side sequencer
class sequencer_rd extends uvm_sequencer #(trans);
    `uvm_component_utils(sequencer_rd)
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass