/*
 Zhaoyang Han
 han221@purdue.edu
 
 Lab1 register file
*/

`include "register_file_if.vh"
`include "cpu_types_pkg.vh"

module register_file(
		     input logic 	 CLK,
		     input logic 	 nRST,
		     register_file_if.rf rfif
	     		     );

   import cpu_types_pkg::*;
   
   word_t [31:0] 			 curr_wdat;

   

   always_ff @ (posedge CLK, negedge nRST) begin
      if(!nRST)begin
	 curr_wdat <= 0;
      end
      else begin
	 if(rfif.WEN == 1'b1)begin
	    curr_wdat[rfif.wsel] <= rfif.wdat;
	 end
	 
	 curr_wdat[0] <= 0;	 
      end
   end

   
   assign rfif.rdat1 = curr_wdat[rfif.rsel1];
   assign rfif.rdat2 = curr_wdat[rfif.rsel2];
   
endmodule // 
