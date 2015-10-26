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

   
   assign ccif.ramWEN = ccif.dWEN[0];
   assign ccif.ramREN = (ccif.dREN[0] | ccif.iREN[0]) & (~ccif.dWEN[0]);
   assign ccif.ramaddr = (ccif.dWEN[0] | ccif.dREN[0]) ? ccif.daddr[0]:ccif.iaddr[0];
   

   assign ccif.ramstore = ccif.dstore[0];
   assign ccif.dload[0] = ccif.ramload;
   assign ccif.iload[0] = ccif.ramload;
   
   always_comb
     begin
   	ccif.dwait[0] = 1;
   	ccif.iwait[0] = 1;
	
   	casez(ccif.ramstate)

   	  FREE:
   	    begin
   	    end
   	  BUSY:
   	    begin
   	    end
   	  ACCESS:
   	    begin
   	       if(ccif.dWEN[0] | ccif.dREN[0])
   		 begin
   		    ccif.dwait[0] = 0;
   		 end
   	       else
   		 begin
   		    ccif.iwait[0] = 0;
   		 end
   	    end // case: ACCESS
   	  ERROR:
   	    begin
   	    end
	  
   	endcase // case (ccif.ramstate)
	
     end // always_comb
   
endmodule
