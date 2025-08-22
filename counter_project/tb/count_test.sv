class test;

    virtual count_if.DRV_MP dr_if;
    virtual count_if.WR_MON_MP wr_if;
    virtual count_if.RD_MON_MP rd_if;

    count_env env_h;

    function new(
        virtual count_if.DRV_MP dr_if,
        virtual count_if.WR_MON_MP wr_if,
        virtual count_if.RD_MON_MP rd_if
    );
        this.dr_if = dr_if;
        this.wr_if = wr_if;
        this.rd_if = rd_if;
        env_h = new(dr_if, wr_if, rd_if);
    endfunction

    virtual task build();
        env_h.build();
    endtask

    virtual task run();
        env_h.run();
    endtask

endclass