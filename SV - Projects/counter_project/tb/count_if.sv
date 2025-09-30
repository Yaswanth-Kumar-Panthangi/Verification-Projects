interface count_if(input logic clock);
    logic       resetn;
    logic [3:0] din;
    logic       up_down;
    logic [3:0] load;
    logic [3:0] count;

    // clocking block for driver
    clocking dr_cb@(posedge clock);
        default input#1 output #1;
        output resetn;
        output din;
        output up_down;
        output load;
    endclocking

    // clocking block for write monitor
    clocking wr_cb@(posedge clock);
        default input#1 output #1; // default timing skew for write monitor
        input resetn;
        input din;
        input up_down;
        input load;
    endclocking

    // clocking block for read monitor
    clocking rd_cb@(posedge clock);
        default input#1 output #1; // default timing skew for read monitor
        input count;
    endclocking

    // modports for driver and monitors
    modport DRV_MP (clocking dr_cb);
    modport WR_MON_MP (clocking wr_cb);
    modport RD_MON_MP (clocking rd_cb);

endinterface