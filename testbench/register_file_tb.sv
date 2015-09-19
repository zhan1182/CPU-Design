/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;

   
  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (CLK, nRST, rfif);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif


      
   
endmodule

program test(
	     input logic CLK,
	     output logic nRST,
	     register_file_if.tb rfif
);

   
  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;
   
      initial begin
      @(negedge CLK);
      nRST = 1'b0;
      @(posedge CLK);
      assert((rfif.rdat1 == rfif.rdat2) && (rfif.rdat1 == 0))
	$display("reset PASSED.");
      
      //test write to register 0
      @(negedge CLK);
      nRST = 1'b1;
      rfif.wdat = 4'h1;
      rfif.wsel = 0;
      rfif.rsel1 = 0;
      rfif.rsel2 = 0;
      rfif.WEN = 1;
      
      @(posedge CLK);
      @(negedge CLK);
      
      if((rfif.rdat1 == rfif.rdat2) && (rfif.rdat1 == 0))
	$display("Test write into register 0 PASSED.");
      else
	$display("Test write into register 0 FAILED.");
      // test for writes and reads to registers
      rfif.wdat = v1;
      rfif.wsel = 5;
      rfif.rsel1 = 5;
      @(posedge CLK);
      #(1ns);
      
      if(rfif.rdat1 == v1)begin
	 $display("Test 1 PASSED.");

      end

      @(negedge CLK);

      rfif.wsel = 31;
      rfif.rsel2 = 31;
      @(posedge CLK);
      #(1ns);
      if(rfif.rdat2 == v1)begin
	 $display("Test 2 PASSED.");
      end

      @(negedge CLK);
      nRST = 1'b0;
      @(posedge CLK);
      #(1ns);
      if((rfif.rdat1 == rfif.rdat2) && (rfif.rdat1 == 0))
	$display("Test 3 PASSED.");
      else
	$display("Test 3 FAILED.");
     
      @(negedge CLK);
      nRST = 1'b1;
      
      rfif.wdat = v3;
      rfif.wsel = 21;
      rfif.rsel1 = 21;
      @(posedge CLK);
      #(1ns);
      if(rfif.rdat1 == v3)begin
	 $display("Test 4 PASSED.");
      end
      @(negedge CLK);
      rfif.wsel = 17;
      rfif.rsel2 = 17;
      @(posedge CLK);
      #(1ns);
      if(rfif.rdat2 == v3)begin
	 $display("Test 5 PASSED.");
      end
      
      
      @(negedge CLK);
      rfif.rsel1 = 0;
      @(posedge CLK);
      #(1ns);
      if(rfif.rdat1 == 0)begin
	 $display("Test 6 PASSED.");
      end

      @(negedge CLK);

      rfif.rsel2 = 0;
      @(posedge CLK);
      #(1ns);
      if(rfif.rdat2 == 0)begin
	 $display("Test 7 PASSED.");
      end



   end // initial begin
   
endprogram
