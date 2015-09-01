// mapped needs this
`include "register_file_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module alu_tb;

   parameter PERIOD = 10;
   
   logic CLK = 0, nRST;

   // clock
   always #(PERIOD/2) CLK++;
   
   // interface
   alu_if alu_if ();
   // test program
   test PROG (alu_if);
   // DUT
`ifndef MAPPED
   alu DUT(alu_if);
`else
   alu DUT(
    .\alu_if.negative (alu_if.negative),
    .\alu_if.overflow (alu_if.overflow),
    .\alu_if.zero (alu_if.zero),
    .\alu_if.output_port (alu_if.output_port),
    .\alu_if.portA (alu_if.portA),
    .\alu_if.portB (alu_if.portB),
    .\alu_if.aluop (alu_if.aluop)
  );
`endif
  
endmodule

program test(
	     alu_if.alu_tb alutb
);

   // test vars
   int 	 v1 = 1;
   int 	 v2 = 4721;
   int 	 v3 = 25119;
   
   initial
     begin
	alutb.portA = 0;
	alutb.portB = 0;
	alutb.aluop = ALU_ADD;
	#(1);
	// Test case 1, zero flag, output = 0
	if (alutb.output_port == 0 && alutb.zero == 1 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 1;
	alutb.portB = 2;
	alutb.aluop = ALU_ADD;
	#(1);
	// Test case 2, no flag, output = 3
	if (alutb.output_port == 3 && alutb.zero == 0 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);


	alutb.portA = 32'h7fffffff;
	alutb.portB = 1;
	alutb.aluop = ALU_ADD;
	#(1);
	// Test case 3, negative and overflow flag, output = 32'h80000000
	if (alutb.output_port == 32'h80000000 && alutb.zero == 0 && alutb.negative == 1 && alutb.overflow == 1)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h80000000;
	alutb.portB = 32'h80000000;
	alutb.aluop = ALU_ADD;
	#(1);
	// Test case 3, zero and overflow flag, output = 32'h80000000
	if (alutb.output_port == 32'h00000000 && alutb.zero == 1 && alutb.negative == 0 && alutb.overflow == 1)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 1;
	alutb.portB = 2;
	alutb.aluop = ALU_SUB;
	#(1);
	// Test case 4, no flag, output = 3
	if (alutb.output_port == -1 && alutb.zero == 0 && alutb.negative == 1 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h7fffffff;
	alutb.portB = 32'hffffffff;
	alutb.aluop = ALU_SUB;
	#(1);
	// Test case 5,  overflow flag, output = 32'h80000000
	if (alutb.output_port == 32'h80000000 && alutb.zero == 0 && alutb.negative == 1 && alutb.overflow == 1)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h80000000;
	alutb.portB = 32'h7fffffff;
	alutb.aluop = ALU_SUB;
	#(1);
	// Test case 6,  overflow flag, output = 32'h00000001
	if (alutb.output_port == 32'h00000001 && alutb.zero == 0 && alutb.negative == 0 && alutb.overflow == 1)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h80000000;
	alutb.portB = 32'h0000000f;
	alutb.aluop = ALU_SLL;
	#(1);
	// Test case 7,  zero flag, output = 0
	if (alutb.output_port == 32'h00000000 && alutb.zero == 1 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h40000000;
	alutb.portB = 32'h00000001;
	alutb.aluop = ALU_SLL;
	#(1);
	// Test case 8,  zero flag, output = 0
	if (alutb.output_port == 32'h80000000 && alutb.zero == 0 && alutb.negative == 1 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);


	alutb.portA = 32'h80000000;
	alutb.portB = 32'h00000001;
	alutb.aluop = ALU_SRL;
	#(1);
	// Test case 9,  zero flag, output = 0
	if (alutb.output_port == 32'h40000000 && alutb.zero == 0 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h00000001;
	alutb.portB = 32'h0000000f;
	alutb.aluop = ALU_SRL;
	#(1);
	// Test case 10,  zero flag, output = 0
	if (alutb.output_port == 32'h00000000 && alutb.zero == 1 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	
	alutb.portA = 32'h0000ffff;
	alutb.portB = 32'hffff0000;
	alutb.aluop = ALU_AND;
	#(1);
	// Test case 11
	if (alutb.output_port == 32'h00000000 && alutb.zero == 1 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h0000ffff;
	alutb.portB = 32'hffff0000;
	alutb.aluop = ALU_OR;
	#(1);
	// Test case 12
	if (alutb.output_port == 32'hffffffff && alutb.zero == 0 && alutb.negative == 1 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);


	alutb.portA = 32'hff00ffff;
	alutb.portB = 32'hffff00ff;
	alutb.aluop = ALU_XOR;
	#(1);
	// Test case 13
	if (alutb.output_port == 32'h00ffff00 && alutb.zero == 0 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h0000ff00;
	alutb.portB = 32'h00ff0000;
	alutb.aluop = ALU_NOR;
	#(1);
	// Test case 14
	if (alutb.output_port == 32'hff0000ff && alutb.zero == 0 && alutb.negative == 1 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h0000ffff;
	alutb.portB = 32'hffff0000;
	alutb.aluop = ALU_SLT;
	#(1);
	// Test case 15
	if (alutb.output_port == 32'h00000000 && alutb.zero == 1 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);

	alutb.portA = 32'h0000ffff;
	alutb.portB = 32'hffff0000;
	alutb.aluop = ALU_SLTU;
	#(1);
	// Test case 16
	if (alutb.output_port == 32'h00000001 && alutb.zero == 0 && alutb.negative == 0 && alutb.overflow == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	#(1);
	
     end
   
endprogram
