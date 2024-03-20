////////////////////////// Testbench Code
 
`timescale 1ns / 1ps
 
 
/////////////////////////Transaction
`include "uvm_macros.svh"
import uvm_pkg::*;
 
// `include "my_sequence.svh"
// `include "my_driver.svh"
`include "my_testbench_pkg.svh"

import my_testbench_pkg::*;
 
////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////
    
module add_tb();
    
    add_if aif();
    
    initial begin
        aif.clk = 0;
        aif.rst = 0;
    end  
    
    always #10 aif.clk = ~aif.clk;
    
    add dut (.a(aif.a), .b(aif.b), .y(aif.y), .clk(aif.clk), .rst(aif.rst));
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    
    initial begin  
        uvm_config_db #(virtual add_if)::set(null, "*", "aif", aif);
        run_test("test");
    end
 
endmodule: add_tb