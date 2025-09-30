
// Defines the transaction item sent through the testbench
class trans extends uvm_sequence_item;

    // Enum for ALU operations for readability
    typedef enum logic [2:0] {
        ADD    = 3'b000,
        SUB    = 3'b001,
        AND_OP = 3'b010,
        OR_OP  = 3'b011,
        XOR_OP = 3'b100,
        NOT_OP = 3'b101,
        SLL    = 3'b110,
        SRL    = 3'b111
    } alu_op_e;

    // Transaction data fields
    rand bit [7:0] a;
    rand bit [7:0] b;
    randc alu_op_e opcode; // randc ensures cyclic randomization
    bit [7:0] result;
    bit carry;

    // UVM field automation macros
    `uvm_object_utils_begin(trans)
        `uvm_field_int(a, UVM_ALL_ON)
        `uvm_field_int(b, UVM_ALL_ON)
        `uvm_field_enum(alu_op_e, opcode, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON)
        `uvm_field_int(carry, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "" );
        super.new(name);
    endfunction

    // Constraint to ensure opcode is always valid
    constraint c_opcode {
        opcode inside {ADD, SUB, AND_OP, OR_OP, XOR_OP, NOT_OP, SLL, SRL};
    }

    // Utility function to print transaction contents
    function string convert2string();
        return $sformatf("a=%0b, b=%0b, opcode=%s, result=%0b, carry=%0b", a, b, opcode.name(), result, carry);
    endfunction
endclass