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

   regbits_t rsel1, rsel2;
   assign rsel1 = hiif.instr_out_1[25:21]; //rs
   assign rsel2 = hiif.instr_out_1[20:16]; //rt
   
   ////////////////////// For EX Hazard /////////////////////
   always_comb begin
      hiif.forwardA = 0;
      hiif.forwardB = 0;

      // when 2nd line needs the result of 1st line
      if (hiif.RegWrite_out_3 && hiif.wsel_out_3 != 0 && hiif.wsel_out_3 == rsel1) begin
	 hiif.forwardA = 2'b10;
      end
      if (hiif.RegWrite_out_3 && hiif.wsel_out_3 != 0 && hiif.wsel_out_3 == rsel2) begin
	 hiif.forwardB = 2'b10;
      end
      // when 3rd line needs the result of 1st line
      if (hiif.RegWrite_out_4 && hiif.wsel_out_4 != 0 && hiif.wsel_out_4 == rsel1) begin
	 hiif.forwardA = 2'b01;
      end
      if (hiif.RegWrite_out_4 && hiif.wsel_out_4 != 0 && hiif.wsel_out_4 == rsel2) begin
	 hiif.forwardB = 2'b01;
      end
      

   end // always_comb
   
   











endmodule // hazard
