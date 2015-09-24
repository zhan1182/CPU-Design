
`include "control_unit_if.vh"

// types
`include "cpu_types_pkg.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns


module control_unit_tb;
   // clock period
   parameter PERIOD = 20;
   
   // signals
   logic CLK = 1, nRST;
   
   // clock
   always #(PERIOD/2) CLK++;
   
   // interface
   control_unit_if cu_if();

   // test program
   test PROG (cu_if);

   control_unit DUT (cu_if);

endmodule


program test(control_unit_if.cutb cu_if);

   // import word type
   import cpu_types_pkg::word_t;

   initial
     begin

	// clock period
	parameter PERIOD = 20;
	
	#(PERIOD);
	
	cu_if.instruction = 32'h341EFFFC;
	cu_if.overflow = 0;

	#(PERIOD);
	
	cu_if.instruction = 32'h341DFFFC;
	cu_if.overflow = 0;

	#(PERIOD);
	
	cu_if.instruction = 32'h34040304;
	cu_if.overflow = 0;

	#(PERIOD);
	
	cu_if.instruction = 32'h8C100300;
	cu_if.overflow = 0;

	#(PERIOD);
	
	cu_if.instruction = 32'h02002842;
	cu_if.overflow = 0;
	
	#(PERIOD);

	cu_if.instruction = 32'h00048825;
	cu_if.overflow = 1;
	
	
     end
   
endprogram
