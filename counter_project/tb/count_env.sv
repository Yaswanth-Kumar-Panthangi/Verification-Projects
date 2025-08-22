class count_env;
    virtual count_if.DRV_MP dr_if;
    virtual count_if.WR_MON_MP wr_if;
    virtual count_if.RD_MON_MP rd_if;

    mailbox #(count_trans) gen2dr = new();
    mailbox #(count_trans) mon2rm = new();
    mailbox #(count_trans) mon2sb = new();
    mailbox #(count_trans) rm2sb  = new();

    count_gen gen_h;
    count_driver dri_h;
    count_wr_mon wrmon_h;
    count_rd_mon rdmon_h;
    count_model mod_h;
    count_sb sb_h;

    function new(
        virtual count_if.DRV_MP dr_if,
        virtual count_if.WR_MON_MP wr_if,
        virtual count_if.RD_MON_MP rd_if
    );
        this.dr_if = dr_if;
        this.wr_if = wr_if;
        this.rd_if = rd_if;
    endfunction

    virtual task build();
        gen_h   = new(gen2dr);
        dri_h   = new(dr_if, gen2dr);
        wrmon_h = new(wr_if, mon2rm);
        rdmon_h = new(rd_if, mon2sb);
        mod_h   = new(rm2sb, mon2rm);
        sb_h    = new(mon2sb, rm2sb);
    endtask

    virtual task start();
        gen_h.start();
        dri_h.start();
        wrmon_h.start();
        rdmon_h.start();
        mod_h.start();
        sb_h.start();
    endtask

    virtual task reset_duv();
        @(dr_if.dr_cb);
        dr_if.dr_cb.resetn <= 1'b0;
        repeat(2)
            @(dr_if.dr_cb);
        dr_if.dr_cb.resetn <= 1'b1;
    endtask

    virtual task stop();
        wait(sb_h.done.triggered);
    endtask

    virtual task run();
    // fork
        reset_duv();
        start();
        $display("-----]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]");
        stop();
        sb_h.report();
        $finish;

    // join
    endtask

endclass
