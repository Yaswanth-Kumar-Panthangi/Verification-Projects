package count_pkg;
    int no_of_transactions = 1; // Number of transactions to generate
    
    `include "count_trans.sv"
    `include "count_gen.sv"
    `include "driver.sv"
    `include "write_mon.sv"
    `include "read_mon.sv"
    `include "count_model.sv"
    `include "count_score.sv"
    `include "count_env.sv"
    `include "count_test.sv"

endpackage