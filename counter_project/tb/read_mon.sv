class count_rd_mon;
    virtual count_if.RD_MON_MP rdmon_if;
    count_trans data2sb, rd_data;
    mailbox #(count_trans) mon2sb;

    function new(virtual count_if.RD_MON_MP rdmon_if, mailbox #(count_trans) mon2sb);
        this.rdmon_if = rdmon_if;
        this.mon2sb = mon2sb;
        rd_data=new();
    endfunction


    virtual task monitor();
        @(rdmon_if.rd_cb);
        rd_data.count = rdmon_if.rd_cb.count;
        rd_data.display("From Read Monitor");
      $display($time," >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>count = %d Read Monitor",rdmon_if.rd_cb.count);
    endtask

    virtual task start();
        fork 
            begin
                forever begin
                    monitor();
                    data2sb = new rd_data;
                    mon2sb.put(data2sb);
//                   data2sb.display("From Read Monitor");
                end
            end
        join_none
    endtask

endclass