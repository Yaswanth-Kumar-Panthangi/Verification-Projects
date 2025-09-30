// Configuration object for the environment
class alu_config extends uvm_object;
    `uvm_object_utils(alu_config)

    function new(string name ="");
        super.new(name);
    endfunction

    // Controls whether agents are active (driving) or passive (monitoring)
    uvm_active_passive_enum is_active_wr;
    uvm_active_passive_enum is_active_rd;

    // Virtual interface handle to be shared across components
    virtual alu_if vif;
endclass