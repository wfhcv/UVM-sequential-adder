package my_testbench_pkg;
//     `include "my_driver.svh"
//     `include "my_sequence.svh"

	// Note the order of header files.
	`include "my_sequence.svh"
	`include "my_driver.svh"
    
    class monitor extends uvm_monitor;
        `uvm_component_utils(monitor)
        
        uvm_analysis_port #(transaction) send;
        
        function new(input string inst = "MON", uvm_component c);
            super.new(inst, c);
            send = new("Write", this);
        endfunction
        
        transaction t;
        virtual add_if aif;
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            t = transaction::type_id::create("TRANS");
            
            if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif)) 
                `uvm_error("MON","Unable to access uvm_config_db");
        
        endfunction: build_phase
        
        virtual task run_phase(uvm_phase phase);
            @(negedge aif.rst);

            forever begin
                repeat(2)@(posedge aif.clk);

                t.a = aif.a;
                t.b = aif.b;
                t.y = aif.y;

                `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d , b : %0d and y : %0d", t.a,t.b,t.y), UVM_NONE);
                
                send.write(t);
            end
        endtask: run_phase
    endclass: monitor
    
    ///////////////////////////////////////////////////////////////////////
    class scoreboard extends uvm_scoreboard;
        `uvm_component_utils(scoreboard)
        
        uvm_analysis_imp #(transaction,scoreboard) recv;
        
        transaction data;
        
        function new(input string inst = "SCO", uvm_component c);
            super.new(inst, c);
            recv = new("Read", this);
        endfunction
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            data = transaction::type_id::create("TRANS");
        endfunction
        
        virtual function void write(input transaction t);
            data = t;
            
            `uvm_info("SCO",$sformatf("Data rcvd from Monitor a: %0d , b : %0d and y : %0d",t.a,t.b,t.y), UVM_NONE);
            
            if(data.y == data.a + data.b)
                `uvm_info("SCO","Test Passed", UVM_NONE)
            else
                `uvm_info("SCO","Test Failed", UVM_NONE);

        endfunction: write
    endclass: scoreboard
    ////////////////////////////////////////////////
    
    class agent extends uvm_agent;
        `uvm_component_utils(agent)
        
        function new(input string inst = "AGENT", uvm_component c);
            super.new(inst, c);
        endfunction
        
        monitor m;
        driver d;
        uvm_sequencer #(transaction) seq;
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            m = monitor::type_id::create("MON",this);
            d = driver::type_id::create("DRV",this);
            seq = uvm_sequencer #(transaction)::type_id::create("SEQ",this);
        endfunction
        
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            d.seq_item_port.connect(seq.seq_item_export);
        endfunction
    endclass: agent
    
    /////////////////////////////////////////////////////
    
    class env extends uvm_env;
        `uvm_component_utils(env)

        function new(input string inst = "ENV", uvm_component c);
            super.new(inst, c);
        endfunction
        
        scoreboard s;
        agent a;
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            s = scoreboard::type_id::create("SCO",this);
            a = agent::type_id::create("AGENT",this);
        endfunction
        
        
        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            a.m.send.connect(s.recv);
        endfunction
    
    endclass: env
    
    ////////////////////////////////////////////
    
    class test extends uvm_test;
        `uvm_component_utils(test)
        
        
        function new(input string inst = "TEST", uvm_component c);
            super.new(inst, c);
        endfunction
        
        generator gen;
        env e;
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            gen = generator::type_id::create("GEN",this);
            e = env::type_id::create("ENV",this);
        endfunction
        
        virtual task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            gen.start(e.a.seq);
            #60;
            phase.drop_objection(this);
        
        endtask: run_phase
    endclass: test

endpackage: my_testbench_pkg