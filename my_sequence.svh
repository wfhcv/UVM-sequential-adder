

class transaction extends uvm_sequence_item;
    rand bit [3:0] a;
    rand bit [3:0] b;
    bit [4:0] y;
    
    function new(input string inst = "transaction");
        super.new(inst);
    endfunction
    
    `uvm_object_utils_begin(transaction)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end
 
endclass: transaction
 
//////////////////////////////////////////////////////////////
class generator extends uvm_sequence #(transaction);
    `uvm_object_utils(generator)
    
    transaction t;
    
    function new(input string inst = "GEN");
        super.new(inst);
    endfunction
    
    
    virtual task body();
    t = transaction::type_id::create("t");

    repeat(10) 
        begin
            start_item(t);
            t.randomize();
            finish_item(t);

            `uvm_info("GEN",$sformatf("Data send to Driver a :%0d , b :%0d",t.a,t.b), UVM_NONE);  
        end
    endtask
 
endclass: generator