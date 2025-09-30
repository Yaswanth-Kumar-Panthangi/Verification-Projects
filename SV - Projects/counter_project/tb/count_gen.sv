// Counter generator class
class count_gen;
    count_trans trans_h;        // Transaction handle
    count_trans data2send;      // Data to send handle

    mailbox #(count_trans) gen2dr;  // Mailbox for communication between generator and driver
    function new( mailbox #(count_trans) gen2dr);  // Constructor
        this.gen2dr = gen2dr;
        trans_h = new();
    endfunction    

    virtual task start(); // function to start the generator
        fork
            begin
                for(int i=0; i<no_of_transactions; i++) begin
                    assert(trans_h.randomize());    // Randomize transaction data
                    data2send = new trans_h;    // Assign randomized transaction to data2send
                    gen2dr.put(data2send);  // Send data to driver
                    data2send.display("From Generator");
//                   $display("From Generator");
                end
            end
        join_any
    endtask

endclass