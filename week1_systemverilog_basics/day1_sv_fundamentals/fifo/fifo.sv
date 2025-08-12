module fifo #(parameter WIDTH=8, DEPTH=16) (
    input logic clk, rst_n, wr_en, rd_en,
    input logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout,
    output logic full, empty
);
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [$clog2(DEPTH):0] wptr, rptr, count;

    assign full = (count == DEPTH);
    assign empty = (count == 0);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0;
            count <= 0;
        end else if (wr_en && !full) begin
            mem[wptr] <= din;
            wptr <= wptr + 1;
            count <= count + 1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rptr <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rptr];
            rptr <= rptr + 1;
            count <= count - 1;
        end
    end
endmodule
