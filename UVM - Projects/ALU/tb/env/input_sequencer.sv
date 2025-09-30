// Sequencer to manage and arbitrate sequences for the write driver
class sequencer_wr extends uvm_sequencer #(trans);
    `uvm_component_utils(sequencer_wr)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass