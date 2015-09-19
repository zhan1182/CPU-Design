
`include "request_unit_if.vh"


// types
`include "cpu_types_pkg.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns


module request_unit_tb;
   // clock period
   parameter PERIOD = 20;
   
   // signals
   logic CLK = 1, nRST;
   
   // clock
   always #(PERIOD/2) CLK++;
   
   // interface
   request_unit_if ru_if();

   // test program
   test PROG (CLK,nRST, ru_if);

   request_unit DUT (CLK,nRST,ru_if);

endmodule
   
program test(input logic CLK, output logic nRST, request_unit_if.rutb ru_if);

   // import word type
   import cpu_types_pkg::word_t;

   initial
    begin
       // Init
       parameter PERIOD = 20;
       
       nRST = 1'b0;
       #(PERIOD);
       nRST = 1'b1;
       #(PERIOD);

       ru_if.iREN = 1;
       ru_if.dREN = 0;
       ru_if.dWEN = 0;
       ru_if.dhit = 0;
       #(PERIOD);
       
       if(ru_if.imemREN == 1)
	  $display("Default Test Case PASSED");
	else // Test case failed
	  $display("Default Test Case FAILED");

       if(ru_if.dmemREN == 0)
	 $display("Default Test Case PASSED");
       else // Test case failed
	 $display("Default Test Case FAILED");
       
       if(ru_if.dmemWEN == 0)
	 $display("Default Test Case PASSED");
       else // Test case failed
	 $display("Default Test Case FAILED");
       
       #(PERIOD);

       ru_if.dREN = 1;
       ru_if.dWEN = 1;

       #(PERIOD);
       
       if(ru_if.dmemREN == 1)
	 $display("Default Test Case PASSED");
       else // Test case failed
	 $display("Default Test Case FAILED");
       
       if(ru_if.dmemWEN == 1)
	 $display("Default Test Case PASSED");
       else // Test case failed
	 $display("Default Test Case FAILED");

       #(PERIOD);
       
       ru_if.dhit = 1;

       #(PERIOD);
       
       if(ru_if.dmemREN == 0)
	 $display("Default Test Case PASSED");
       else // Test case failed
	 $display("Default Test Case FAILED");
       
       if(ru_if.dmemWEN == 0)
	 $display("Default Test Case PASSED");
       else // Test case failed
	 $display("Default Test Case FAILED");
       
    end


endprogram
