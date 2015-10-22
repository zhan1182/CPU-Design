

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"


// mapped timing needs this. 
`timescale 1 ns / 1 ns

module icache_tb;

   // clock period
   parameter PERIOD = 20;
   
   // signals
   logic CLK = 1, nRST;
   
   // clock
   always #(PERIOD/2) CLK++;
   
   // interface
   cache_control_if ccif();
   datapath_cache_if dcif();
   
   // test program
   test                                PROG (CLK, nRST, dcif, ccif);
   
   // dut
   icache ICACHE(CLK, nRST, dcif, ccif);
   
endmodule

program test(input logic CLK, output logic nRST, datapath_cache_if.icache dcif, cache_control_if.icache ccif);

   import cpu_types_pkg::*;

   int 	 i;
   
   initial
     begin

	// Reset the icache
	nRST = 0;

	// Init values
	@(negedge CLK);
	dcif.imemaddr = 0;
	dcif.imemREN = 1;
	
	ccif.iwait = 1;
	ccif.iload = 0;	

	// Turn off reset
	@(negedge CLK);
	nRST = 1;
	
	@(posedge CLK);
	// Test 1 & 2, test ram read enable AND ihit
	if(ccif.iREN == 1 && dcif.ihit == 0)
	  begin
	     $display("PASSED.");
	  end
	else
	  begin
	     $display("FAILED.");
	  end

	@(negedge CLK);
	ccif.iwait = 0;
	
	// Test 2, test cache hit
	@(posedge CLK);
	if(ccif.iREN == 0 && dcif.ihit == 1)
	  begin
	     $display("PASSED.");
	  end
	else
	  begin
	     $display("FAILED.");
	  end

	// Test 3, test cache miss
	@(negedge CLK);
	dcif.imemaddr = 4;
	
	@(posedge CLK);
	if(ccif.iREN == 0 && dcif.ihit == 1)
	  begin
	     $display("PASSED.");
	  end
	else
	  begin
	     $display("FAILED.");
	  end
	
	
	
     end


endprogram
