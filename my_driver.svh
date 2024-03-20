

class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)
    
    function new(input string inst = " DRV", uvm_component c);
        super.new(inst, c);
    endfunction
    
    transaction data;
    virtual add_if aif;
    
    ///////////////////reset logic
    task reset_dut();
        aif.rst <= 1'b1;
        aif.a   <= 0;
        aif.b   <= 0;
        
        repeat(5) @(posedge aif.clk);

        aif.rst <= 1'b0; 

        `uvm_info("DRV", "Reset Done", UVM_NONE);
    endtask: reset_dut
    
    ////////////////////////////////////////////////////
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        data = transaction::type_id::create("data");
        
        if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif)) 
            `uvm_error("DRV","Unable to access uvm_config_db");
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        reset_dut();
        
        forever begin 
            seq_item_port.get_next_item(data);

            aif.a <= data.a;
            aif.b <= data.b;

            seq_item_port.item_done(); 
                    
            `uvm_info("DRV", $sformatf("Trigger DUT a: %0d ,b :  %0d",data.a, data.b), UVM_NONE); 
            
            @(posedge aif.clk);
            @(posedge aif.clk);
        end
    
    endtask: run_phase
endclass: driver