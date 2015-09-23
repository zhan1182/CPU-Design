

`include "register_file_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

module register_file
(
 input logic CLK,
 input logic nRST,
 register_file_if.rf rf_if
);

   word_t [31:0] register;
   
   always_ff @ (negedge CLK, negedge nRST)
     begin :tagname   
	if(1'b0 == nRST)
	  begin
	     register <= '{default:0}; 
	  end
	else
	  begin
	     register[0] <= 0;
	     if(rf_if.WEN == 1'b1 && rf_if.wsel != 0)
	       begin
		  register[rf_if.wsel] <= rf_if.wdat;
	       end
	  end
     end
   
   assign rf_if.rdat1 = register[rf_if.rsel1];
   assign rf_if.rdat2 = register[rf_if.rsel2];
   
   
endmodule
