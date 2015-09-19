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

   always_comb begin
      ccif.iload = 0;
      ccif.dload = 0;
      ccif.ramstore = 0;
      ccif.ramREN = 0;
      ccif.ramWEN = 0;
      ccif.ramaddr = 0;
      
      if (ccif.dWEN == 1)begin
	 ccif.ramaddr = ccif.daddr;
	 ccif.ramWEN = 1;
	 ccif.ramREN = 0;
	 ccif.ramstore = ccif.dstore;

      end
      else if (ccif.dREN == 1)begin
	 ccif.dload = ccif.ramload;
	 ccif.ramaddr = ccif.daddr;
	 ccif.ramREN = 1;
	 ccif.ramWEN = 0;
      end
      else if (ccif.iREN == 1)begin
	 ccif.iload = ccif.ramload;
	 ccif.ramaddr = ccif.iaddr;
	 ccif.ramREN = 1;
	 ccif.ramWEN = 0;
      end
      
      case(ccif.ramstate)
	FREE:begin
	   ccif.iwait = 1;
	   ccif.dwait = 1;
	end
	BUSY:begin
	   ccif.iwait = 1;
	   ccif.dwait = 1;
	end
	ACCESS:begin
	   ccif.iwait = (ccif.iREN == 1 && ccif.dREN == 0 && ccif.dWEN == 0) ? 0 : 1;
	   ccif.dwait = (ccif.dREN == 1 || ccif.dWEN == 1) ? 0:1;
	end
	ERROR:begin
	   ccif.iwait = 1;
	   ccif.dwait = 1;
	end
	endcase
      end // always_comb begin
endmodule
