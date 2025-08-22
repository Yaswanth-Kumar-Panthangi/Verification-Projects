module counter (
    input  logic        clock, 
    input  logic        resetn,
    input  logic [3:0]  din,
    input  logic        up_down,
    input  logic        load,
    output logic [3:0]  count
    );

    always@(posedge clock) begin
        if(!resetn) begin
            count <= 0;
        end
        else begin
            if(load) begin
                count <= din;
            end
            else if(up_down==0) begin
                if(count>12)
                    count <=0;
                else
                    count <= count + 1;            
            end
            else begin
                if(count>10 || count <2)
                    count <= 4;
                else
                    count <= count-1;
            end
        end
    end
endmodule
