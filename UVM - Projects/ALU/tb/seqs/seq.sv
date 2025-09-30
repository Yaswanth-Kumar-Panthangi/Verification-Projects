// Base sequence to generate random ALU transactions
class base_sequence extends uvm_sequence #(trans);
    `uvm_object_utils(base_sequence)
    int num_transactions = 100;

    function new(string name="");
        super.new(name);
    endfunction

    // Task to generate and send a specified number of transactions
    task body();
        repeat(num_transactions) begin
            req = trans :: type_id :: create("req");
            start_item(req);
            void'(req.randomize());
            finish_item(req);
        end
    endtask
endclass