/*
 Zhaoyang Han
 han221@purdue.edu
 
 Request Unit source code
 */

`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

module request_unit(
		    input logic CLK,
		    input logic nRST,
		    request_unit_if.ru ruif
		    );
   import cpu_types_pkg::*;

   logic 			dRENnext, dRENcurr, dWENnext, dWENcurr;

   assign ruif.imemREN = 1;
   assign ruif.dmemREN = dRENcurr;
   assign ruif.dmemWEN = dWENcurr;
   
   always_ff @(posedge CLK, negedge nRST) begin
      if (nRST == 0)begin
	 dRENcurr <= 0;
	 dWENcurr <= 0;

      end
      else begin
	 dRENcurr <= dRENnext;
	 dWENcurr <= dWENnext;
      end
      
   end
   always_comb begin
      dRENnext = dRENcurr;
      dWENnext = dWENcurr;
      
      if(ruif.dhit == 1)begin
	 dRENnext = 0;
	 dWENnext = 0;
      end
      else if (ruif.ihit == 1) begin
	 dRENnext = ruif.dREN;
	 dWENnext = ruif.dWEN;
      end
   end

endmodule // request_unit
