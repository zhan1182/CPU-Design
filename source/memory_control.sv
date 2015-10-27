/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 1;

   
   assign ccif.ramWEN = ccif.dWEN;
   assign ccif.ramREN = (ccif.dREN | ccif.iREN) & (~ccif.dWEN);
   assign ccif.ramaddr = (ccif.dWEN | ccif.dREN) ? ccif.daddr:((ccif.iREN == 1)?ccif.iaddr:0);
   

   assign ccif.ramstore = ccif.dstore;
   assign ccif.dload = ccif.ramload;
   assign ccif.iload = (ccif.iREN == 1) ? ccif.ramload:0;
   
   always_comb
     begin
   	ccif.dwait = 1;
   	ccif.iwait = 1;
	
   	casez(ccif.ramstate)

   	  FREE:
   	    begin
   	    end
   	  BUSY:
   	    begin
   	    end
   	  ACCESS:
   	    begin
   	       if(ccif.dWEN || ccif.dREN)
   		 begin
   		    ccif.dwait = 0;
   		 end
   	       if(ccif.iREN == 1 && ccif.dREN == 0 && ccif.dWEN == 0)
   		 begin
   		    ccif.iwait = 0;
   		 end
   	    end // case: ACCESS
   	  ERROR:
   	    begin
   	    end
	  
   	endcase // case (ccif.ramstate)
	
     end // always_comb
   
endmodule
