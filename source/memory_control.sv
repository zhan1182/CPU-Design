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

   assign ccif.iwait = (ccif.ramstate == ACCESS) ? (((ccif.iREN == 1)&&(ccif.dREN == 0)&&(ccif.dWEN == 0))?0:1):1;
   assign ccif.dwait = (ccif.ramstate == ACCESS) ? (((ccif.dREN == 1)||(ccif.dWEN == 1))?0:1):1;

   /*
   always_comb
     begin
   	ccif.dwait = 1;
   	ccif.iwait = 1;
	/*
	ccif.ramWEN = 0;
	ccif.ramREN = 0;

	if(ccif.dREN || ccif.iREN)begin
	   if(ccif.dWEN == 0)begin
	      ccif.ramREN = 1;
	      ccif.ramWEN = 0;
	      
	   end
	end
	if(ccif.dWEN == 1 && ccif.iREN == 1)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	if(ccif.dWEN == 1 && ccif.dREN == 1)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	if(ccif.dWEN == 1 && ccif.dREN == 0 && ccif.iREN == 0)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	if(ccif.dWEN == 1 && ccif.dREN == 1 && ccif.iREN == 1)begin
	   ccif.ramWEN = 1;
	   ccif.ramREN = 0;
	end
	
	
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
	
     end*/
endmodule
