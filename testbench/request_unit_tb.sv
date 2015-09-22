`include "request_unit_if.vh"

`include "cpu_types_pkg.vh"
`timescale 1 ns / 1 ns

module request_unit_tb;
   parameter PERIOD = 20;
   logic CLK = 1, nRST;

   always #(PERIOD/2) CLK++;

   request_unit_if ruif();

   test PROG (CLK, nRST, ruif);
   request_unit REQ (CLK, nRST, ruif);

endmodule // request_unit_tb

program test (
	      input logic CLK,
	      output logic nRST,
	      request_unit_if ruif);

   initial begin
      nRST = 0;
      #(posedge CLK);
      @(negedge CLK);
      
      nRST = 1;
      ruif.ihit = 1;
      ruif.dhit = 0;
      ruif.dREN = 1;
      ruif.dWEN = 0;

      @(posedge CLK);
      @(negedge CLK);
      
      nRST = 1;
      ruif.ihit = 0;
      ruif.dhit = 1;
      ruif.dREN = 1;
      ruif.dWEN = 0;

      @(posedge CLK);
      @(negedge CLK);
      
      nRST = 1;
      ruif.ihit = 1;
      ruif.dhit = 1;
      ruif.dREN = 1;
      ruif.dWEN = 0;

      @(posedge CLK);
      @(negedge CLK);
      
      nRST = 1;
      ruif.ihit = 0;
      ruif.dhit = 0;
      ruif.dREN = 1;
      ruif.dWEN = 0;

      @(posedge CLK);
      @(negedge CLK);
      
      nRST = 1;
      ruif.ihit = 1;
      ruif.dhit = 0;
      ruif.dREN = 0;
      ruif.dWEN = 1;

      @(posedge CLK);
      @(negedge CLK);
      
      nRST = 1;
      ruif.ihit = 0;
      ruif.dhit = 1;
      ruif.dREN = 0;
      ruif.dWEN = 1;

      @(posedge CLK);
   end // initial begin
endprogram // test
   
