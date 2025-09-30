// Scoreboard for verifying DUT functionality
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // FIFOs to get transactions from monitors
    uvm_tlm_analysis_fifo #(trans) wr_mon_fifo;
    uvm_tlm_analysis_fifo #(trans) rd_mon_fifo;

    // Queue to store input transactions for later comparison
    protected trans wr_item_q[$];
    trans wr_trans, rd_trans, expected_trans;
    int error_count = 0, success_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: create FIFOs and transaction objects
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_mon_fifo = new("wr_mon_fifo", this);
        rd_mon_fifo = new("rd_mon_fifo", this);
        expected_trans = new("expected_trans");
    endfunction

    // Main checking logic
    task run_phase(uvm_phase phase);
        fork
            // Process 1: Collect input transactions and store them in a queue
            forever begin
                trans collected_wr_trans;
                wr_mon_fifo.get(collected_wr_trans);
                `uvm_info("SCOREBOARD_INPUT", $sformatf("Got write transaction: %s", collected_wr_trans.convert2string()), UVM_HIGH)
                wr_item_q.push_back(collected_wr_trans);
            end

            // Process 2: Collect output transactions, predict, and compare
            forever begin
                // Get the actual result from the output monitor
                rd_mon_fifo.get(rd_trans);
                `uvm_info("SCOREBOARD_OUTPUT", $sformatf("Got read transaction: %s", rd_trans.convert2string()), UVM_HIGH)
                
                // Wait for the corresponding input transaction
                wait (wr_item_q.size() > 0);
                wr_trans = wr_item_q.pop_front();

                // Predict the expected result
                predict_results(wr_trans, expected_trans);
                
                // Compare actual vs. expected
                if (compare_results(rd_trans, expected_trans)) begin
                    `uvm_info("SCOREBOARD", $sformatf("PASS: Input: (a=%0h, b=%0h, op=%s) -> Result: %0h",
                        wr_trans.a, wr_trans.b, wr_trans.opcode.name(), rd_trans.result), UVM_LOW)
                    success_count++;
                end else begin
                    `uvm_error("SCOREBOARD", $sformatf("FAIL: Mismatch detected!\n  Input:    %s\n  Expected: %s\n  Actual:   %s",
                        wr_trans.convert2string(), expected_trans.convert2string(), rd_trans.convert2string()))
                    error_count++;
                end
            end
        join
    endtask

    // Behavioral model of the DUT to predict results
    virtual function void predict_results(trans actual_in, inout trans predicted_out);
        predicted_out.a = actual_in.a;
        predicted_out.b = actual_in.b;
        predicted_out.opcode = actual_in.opcode;
        case(actual_in.opcode)
            trans::ADD:   {predicted_out.carry,predicted_out.result}= actual_in.a + actual_in.b;
            trans::SUB:   {predicted_out.carry,predicted_out.result}= actual_in.a - actual_in.b;
            trans::AND_OP: predicted_out.result = actual_in.a & actual_in.b;
            trans::OR_OP:  predicted_out.result = actual_in.a | actual_in.b;
            trans::XOR_OP: predicted_out.result = actual_in.a ^ actual_in.b;
            trans::NOT_OP: predicted_out.result = ~actual_in.a;
            trans::SLL:    predicted_out.result = actual_in.a << 1;
            trans::SRL:    predicted_out.result = actual_in.a >> 1;
        endcase
    endfunction

    // Comparison logic
    virtual function bit compare_results(trans actual, trans expected);
        bit is_match = 1;
        if (actual.result !== expected.result) is_match = 0;
        // Only check carry for relevant operations
        if ((expected.opcode == trans::ADD || expected.opcode == trans::SUB) && (actual.carry !== expected.carry)) begin
            is_match = 0;
        end
        return is_match;
    endfunction

    // Report final pass/fail summary
    function void report_phase(uvm_phase phase);
        `uvm_info(get_full_name(), $sformatf("SCOREBOARD SUMMARY: %0d PASSED, %0d FAILED", success_count, error_count), UVM_NONE)
    endfunction
endclass
