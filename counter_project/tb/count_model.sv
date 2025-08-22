class count_model;

    count_trans w_data;

    static logic [3:0] ref_count;

    mailbox #(count_trans) rm2sb;
    mailbox #(count_trans) wrmon2rm;

    function new(
            mailbox #(count_trans) rm2sb,
            mailbox #(count_trans) wrmon2rm
        );
        this.rm2sb = rm2sb;
        this.wrmon2rm = wrmon2rm;
    endfunction

    virtual task count_mod(count_trans model_counter);
        begin
            if(model_counter.load)
                ref_count = model_counter.din;            
                // ref_count = 10;
            else
            begin 
                if(model_counter.up_down==0) begin
                    if(ref_count>12)
                        ref_count = 0;
                    else
                        ref_count = ref_count+1;
                end
                else begin
                    if(ref_count>10 || ref_count <2)
                        ref_count = 10;
                    else
                        ref_count = ref_count-1;
                end
            end            
        end
    endtask

    virtual task start();
        fork
            begin
                forever begin
                    wrmon2rm.get(w_data);

                    count_mod(w_data);
                    $display("========================ref_count = %0d",ref_count);
                    w_data.count= ref_count;
                    $display("========================w_data.count = %0d",w_data.count);
                    rm2sb.put(w_data);
                    w_data.display("From Reference Model=");
                end
              
            end
        join_none
    endtask
endclass

