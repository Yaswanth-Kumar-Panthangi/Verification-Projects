class count_wr_mon;
    virtual count_if.WR_MON_MP wrmon_if;
    count_trans data2rm, wr_data;
    mailbox #(count_trans) mon2rm;
    function new(virtual count_if.WR_MON_MP wrmon_if, mailbox #(count_trans) mon2rm);
        this.wrmon_if = wrmon_if;
        this.mon2rm = mon2rm;
        wr_data = new();
    endfunction

    virtual task monitor();
        @(wrmon_if.wr_cb);
        wr_data.resetn = wrmon_if.wr_cb.resetn;
        wr_data.din = wrmon_if.wr_cb.din;
        wr_data.up_down = wrmon_if.wr_cb.up_down;
        wr_data.load = wrmon_if.wr_cb.load;
    endtask

    virtual task start();
        fork 
            begin
                forever begin
                    monitor();
                    data2rm = new wr_data;
                    mon2rm.put(data2rm);
                    data2rm.display("From Write_Monitor");
                end
            end
        join_none
    endtask

endclass