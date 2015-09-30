/*
 Zhaoyang Han & Jinyi Zhang
 han221 & zhan1128
 
 hazard unit source file
 */

`include "cpu_types_pkg.vh"
`include "hazard_if.vh"

module hazard(
	      hazard_if.hi hiif
	      );
   import cpu_types_pkg::*;

   
   ////////////////////// For EX Hazard /////////////////////
   always_comb begin
      hiif.forwardA = 0;
      hiif.forwardB = 0;
      hiif.forwardC = 0;
      
      
      // when 2nd line needs the result of 1st line
      if (hiif.RegWrite_out_3 && hiif.wsel_out_3 != 0 && hiif.wsel_out_3 == hiif.rs_out_2) begin
	 hiif.forwardA = 2'b10;
      end
      if (hiif.RegWrite_out_3 && hiif.wsel_out_3 != 0 && hiif.wsel_out_3 == hiif.rt_out_2) begin
	 hiif.forwardB = 2'b10;
      end
      // when 3rd line needs the result of 1st line
      if (hiif.RegWrite_out_4 && hiif.wsel_out_4 != 0 && hiif.wsel_out_4 == hiif.rs_out_2) begin
	 hiif.forwardA = 2'b01;
      end
      if (hiif.RegWrite_out_4 && hiif.wsel_out_4 != 0 && hiif.wsel_out_4 == hiif.rt_out_2) begin
	 hiif.forwardB = 2'b01;
      end

      if(hiif.dWEN_out_2 && hiif.wsel_out_3 != 0 && hiif.wsel_out_3 == hiif.rt_out_2)
	begin
	   hiif.forwardC = 1;
	end
      
      
   end // always_comb
   
   




   // potential adding: P311 MEM hazard, P314 hazard detection: load






endmodule // hazard
