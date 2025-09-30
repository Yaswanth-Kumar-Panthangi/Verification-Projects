// Interface to connect the Testbench to the DUT
interface alu_if( input bit clk);
    logic       valid;
    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] opcode;
    logic [7:0] result;
    logic       carry;

    // Clocking block for the write driver
    clocking drv_wr_cb @(posedge clk);
        default input #1 output #1;
        output valid, a, b, opcode;
    endclocking

    // Clocking block for the write monitor
    clocking mon_wr_cb @(posedge clk);
        default input #1 output #1;
        input valid, a, b, opcode, result, carry;
    endclocking

    // Clocking block for the read monitor
    clocking mon_rd_cb @(posedge clk);
        default input #1 output #1;
        input valid, a, b, opcode, result, carry;
    endclocking

    // Modports defining direction for different components
    modport DRV_WR (clocking drv_wr_cb);
    modport MON_WR (clocking mon_wr_cb);
    modport MON_RD (clocking mon_rd_cb);
endinterface