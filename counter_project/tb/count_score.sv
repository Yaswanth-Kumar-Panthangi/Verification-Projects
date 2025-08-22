class count_sb;
    event done;
    count_trans r_data, sb_data;

    int ref_data, rm_data;
    int data_verified;

    mailbox #(count_trans) rdm2sb;
  mailbox #(count_trans) ref2sb;

    function new (
        mailbox #(count_trans) rdm2sb,
        mailbox #(count_trans) ref2sb
        );
        this.rdm2sb = rdm2sb;
        this.ref2sb = ref2sb;        
    endfunction

    virtual task check(count_trans rdata);
        if(r_data.count == rdata.count) begin
            $display($time, "Count match: %d", r_data.count);
        end 
        else begin
            $display($time, "Count mismatch: Expected %d, Got %d", r_data.count, rdata.count);
        end
        data_verified++;
        if(data_verified >= no_of_transactions) begin
            ->done;
        end
    endtask

    virtual task start();
        fork
            begin
                forever begin
                //   $display("------------------------SCORE_BOARD data_verified = %0d-",data_verified);

                    ref2sb.get(r_data);
                    ref_data++;
                    r_data.display("From Score Board - Reference Model");

                    rdm2sb.get(sb_data);
                    rm_data++;
                    sb_data.display("From Score Board - Read Monitor");

                    check(sb_data);
                end
            end
        join
    endtask


    virtual function void report();
        $display("------------------------SCORE_BOARD_REPORT-----------------------------");
        $display("No of Transactions: %d", no_of_transactions);
        $display("Data Generated: %d", rm_data);
        $display("Data Verified : %d", data_verified);
        $display("-----------------------------------------------------------------------");
    endfunction

endclass