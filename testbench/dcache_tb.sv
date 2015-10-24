`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "cache_control_if.vh"

`timescale 1 ns / 1 ns

module dcache_tb;

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
   dcache DCACHE(CLK, nRST, dcif, ccif);
   
endmodule

program test(input logic CLK, output logic nRST, datapath_cache_if.dcache dcif, cache_control_if.dcache ccif);

   import cpu_types_pkg::*;

   int 	 i;
   
   initial
     begin
	nRST = 0;
	// test 1: write data, tag not match, write in the cache, use table 2
	@(negedge CLK);
	nRST = 1;
	ccif.dwait = 1;
	ccif.dload = 0;
	
	dcif.dmemREN = 0;
	dcif.dmemWEN = 1;
	dcif.dmemstore = 32'habababab;
	dcif.dmemaddr = 32'h11ab0000;
	@(posedge CLK);
	ccif.dwait = 0;
	@(posedge CLK);
	

	
	//check dstore, check if in the cache

	// test 2: write data, tag not match, write above into ram, write in the cache, use table 1
	@(negedge CLK);
	ccif.dwait = 1;
	
	dcif.dmemREN = 0;
	dcif.dmemWEN = 1;
	dcif.dmemstore = 32'hbabababa;
	dcif.dmemaddr = 32'h22ab0000;
	@(posedge CLK);
	ccif.dwait = 0;
	@(posedge CLK);
	
	//check dstore, check if in the cache, check if previous data in ramstore

	
	// test 3: write data, tag match, overwrite above, use table 2
	@(negedge CLK);
	ccif.dwait = 1;
	
	dcif.dmemREN = 0;
	dcif.dmemWEN = 1;
	dcif.dmemstore = 32'h12121212;
	dcif.dmemaddr = 32'h22ab0000;
	@(posedge CLK);
	ccif.dwait = 0;
	@(posedge CLK);
	
	// check dstore, check if the cache has it, if it has previous data, then wrong

	
	// test 4: read data, tag match, from the cache,  use table 1
	@(negedge CLK);
	ccif.dwait = 1;
	ccif.dload = 32'h12341234;
	
	dcif.dmemREN = 1;
	dcif.dmemWEN = 0;
	dcif.dmemstore = 0;
	dcif.dmemaddr = 32'h22ab0000;
	@(posedge CLK);
	ccif.dwait = 0;
	@(posedge CLK);
	
	
	//check dmemload, should equal to the above data
	
	// test 5: read data, tag not match, from the ram, use table 2
	@(negedge CLK);
	ccif.dwait = 1;
	ccif.dload = 32'hacacacac;
	
	dcif.dmemREN = 1;
	dcif.dmemWEN = 0;
	dcif.dmemstore = 0;
	dcif.dmemaddr = 32'h11ab0000;
	@(posedge CLK);
	ccif.dwait = 0;
	@(posedge CLK);
	
	// check dmemload, check if it equal to iload
     end
endprogram // test
   
