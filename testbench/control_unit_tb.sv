/*
 han221@purdue.edu
 Zhaoyang Han
 
 control unit testbench
 */

`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"

`timescale 1 ns / 1 ns

module control_unit_tb;
   parameter PERIOD = 20;
   
   logic CLK = 1, nRST;
   
   always #(PERIOD/2) CLK++;

   // interface
   control_unit_if cuif();
   control_unit CON (cuif);
   
   test PROG (CLK, nRST, cuif);

endmodule // control_unit_tb

program test (
	      input logic CLK,
	      output logic nRST,
	      control_unit_if cuif);
   initial begin
      @(negedge CLK);
      
      cuif.instr = 32'h0EF30000;

      @(posedge CLK);
      @(negedge CLK);
      
      cuif.instr = 32'h00CD0000;
      @(posedge CLK);
      
      @(negedge CLK);
      cuif.instr = 32'hA0C000B0;
      @(posedge CLK);
      @(negedge CLK);
      cuif.instr = 32'h10040803;
      @(posedge CLK);

   end // initial begin
endprogram // test
   
		   
