// `include "count_if.sv"

// Driver class for the counter
class count_driver;
    virtual count_if.DRV_MP dr_if;
    count_trans data2duv;           
    mailbox #(count_trans) gen2dr;

    function new(virtual count_if.DRV_MP dr_if, mailbox #(count_trans) gen2dr);
        this.dr_if = dr_if;
        this.gen2dr = gen2dr;
    endfunction

    virtual task count();
        @(dr_if.dr_cb);
        dr_if.dr_cb.resetn  <= data2duv.resetn;
        dr_if.dr_cb.din     <= data2duv.din;
        dr_if.dr_cb.up_down <= data2duv.up_down;
        dr_if.dr_cb.load    <= data2duv.load;        
    endtask

    virtual task start();
        fork
            begin
                forever begin
                    gen2dr.get(data2duv);
                    count();
                    // data2duv.display("From Driver");
                end
            end
        join_none        

    endtask

endclass