module count_top;
  
    import count_pkg::*;

    bit clock;

    count_if DUV_IF(clock);

    test t_h;

    counter DUV(
        .clock(clock),
        .resetn(DUV_IF.resetn),
        .din(DUV_IF.din),
        .up_down(DUV_IF.up_down),
        .load(DUV_IF.load),
        .count(DUV_IF.count)
    );


    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        t_h = new(DUV_IF, DUV_IF, DUV_IF);
        no_of_transactions =1;
        t_h.build();
        t_h.run();
        $finish;
    end

endmodule