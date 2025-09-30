class count_trans;
    rand logic       resetn;
    rand logic [3:0] din;
    rand logic       up_down;
    rand logic [3:0] load;
    logic      [3:0] count;

    constraint c1 {din inside{[3:8]};}
    constraint c2 {load dist{1:=100, 0:=0};}
    constraint c3 {up_down dist{0:=50, 1:=50};}
    constraint c4 {resetn dist{1:=100, 0:=0};}

    virtual function void display(input string s);
        $display("-----------------------------------%s-----------------------------------", s);
        $display("resetn: %d", resetn);
        $display("din: %d", din);
        $display("up_down: %d", up_down);
        $display("load: %d", load);
        $display("count: %d", count);
        $display("------------------------------------------------------------------------");
    endfunction

endclass