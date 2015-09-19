
`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module request_unit
(
 input logic CLK,
 input logic nRST,
 request_unit_if.ru ru_if
);

   logic     dREN_tmp;
   logic     dWEN_tmp;
   
   
   always_ff @ (posedge CLK, negedge nRST)
     begin
	if(nRST == 1'b0)
	  begin
	     ru_if.dmemREN <= 0;
	     ru_if.dmemWEN <= 0;	     
	  end
	else
	  begin
	     ru_if.dmemREN <= dREN_tmp;
	     ru_if.dmemWEN <= dWEN_tmp;	     
	  end
     end

   assign dREN_tmp = (~ru_if.dhit) & ru_if.dREN;
   assign dWEN_tmp = (~ru_if.dhit) & ru_if.dWEN;

   assign ru_if.imemREN = 1;
   
   
endmodule
