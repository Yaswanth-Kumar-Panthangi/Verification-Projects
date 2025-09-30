//----------------------------------------------------------------
// Design Under Test (DUT): 8-bit Arithmetic Logic Unit
//----------------------------------------------------------------
module alu_dut (
    input  logic clk,
    input  logic rst,
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] opcode,
    output logic [7:0] result,
    output logic carry
);
    // Sequential logic for ALU operations, triggered on clock edge
    always_ff @(posedge clk) begin
        if (rst) begin
            {carry,result} = '0;
        end
        else begin
            case(opcode)
                3'b000 : {carry,result} = a + b; // ADD
                3'b001 : {carry,result} = a - b; // SUB
                3'b010 : result         = a & b; // AND
                3'b011 : result         = a | b; // OR
                3'b100 : result         = a ^ b; // XOR
                3'b101 : result         = ~a;    // NOT
                3'b110 : result         = a << 1;// SLL
                3'b111 : result         = a >> 1;// SRL
                default: result         = 8'hXX;
            endcase
        end
    end
endmodule