/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"
// `include "cpu_types_pkg.vh"

// import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;
   
   parameter PERIOD = 10;
   
   logic CLK = 0, nRST;
   
   // test vars
   int 	 v1 = 1;
   int 	 v2 = 4721;
   int 	 v3 = 25119;

   // clock
   always #(PERIOD/2) CLK++;
   
   // interface
   register_file_if rfif ();
   // test program
   test PROG (CLK, nRST, rfif);
   // DUT
`ifndef MAPPED
   register_file DUT(CLK, nRST, rfif);
`else
   register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif
  
endmodule

program test(
	     input logic CLK,
	     output logic nRST,
	     register_file_if.tb rfif
);
   

   // test vars
   int 	 v1 = 1;
   int 	 v2 = 4721;
   int 	 v3 = 25119;
 
   initial
     begin
	
	// Initialization
	nRST = 1'b0;
	rfif.WEN = 0;
	rfif.wsel = 0;
	rfif.wdat = 0;
	rfif.rsel1 = 0;
	rfif.rsel2 = 0;
       
	@(negedge CLK);
	nRST = 1'b1;	
	// Test Case 1, test register 0
	@(negedge CLK);
	rfif.rsel1 = 0;
	#(0.1);
	if (rfif.rdat1 == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");

	// Write to register 0
	@(negedge CLK);
	rfif.WEN = 1;
	rfif.wsel = 0;
	rfif.wdat = v2;
	@(posedge CLK);
	// Test case 2 Read from register 0
	@(negedge CLK);
	rfif.WEN = 0;
	rfif.rsel2 = 0;
	#(0.1);
	if (rfif.rdat2 == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");

	// Write to register 1
	@(negedge CLK);
	rfif.WEN = 1;
	rfif.wsel = v1;
	rfif.wdat = v2;	
	@(posedge CLK);
	// Test case 3, read from register 1
	@(negedge CLK);
	rfif.WEN = 0;
	rfif.rsel1 = v1;
	#(0.1);
	if (rfif.rdat1 == v2)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");

	// Write to register 15
	@(negedge CLK);
	rfif.WEN = 1;
	rfif.wsel = 15;
	rfif.wdat = v3;	
	@(posedge CLK);
	// Test case 5, read two position at the same time
	@(negedge CLK);
	rfif.WEN = 0;
	rfif.rsel2 = 15;
	#(0.1);
	if (rfif.rdat2 == v3)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	if (rfif.rdat1 == v2)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");


	// Test case 6, test async reset
	#(1);
	
	nRST = 1'b0;
	#(1);
	if (rfif.rdat2 == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	if (rfif.rdat1 == 0)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");
	
	
     end
   
endprogram
