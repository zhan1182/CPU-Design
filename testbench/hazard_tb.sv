`include "hazard_if.vh"
`include "cpu_types_pkg.vh"

`timescale 1 ns / 1 ns

module hazard_tb;
   parameter PERIOD = 20;
   logic CLK = 1, nRST;

   // clock
   always #(PERIOD/2) CLK++;

   hazard_if hiif();

   test PROG (hiif);

   hazard DUT (hiif);
endmodule // hazard_tb

program test(hazard_if.tb hiif);
   import cpu_types_pkg::word_t;

   initial begin
      // NO.1
      hiif.rt_out_2 = 5'b01000;
      hiif.rs_out_2 = 5'b00100;    
      hiif.RegWrite_out_3 = 1;
      hiif.wsel_out_3 = 5'b00100;
      hiif.RegWrite_out_4 = 0;
      hiif.wsel_out_4 = 0;
      hiif.dWEN_out_2 = 0; // forwardA will be 2'b10
      
      // NO.2
      hiif.rt_out_2 = 5'b01000;
      hiif.rs_out_2 = 5'b00100;    
      hiif.RegWrite_out_3 = 1;
      hiif.wsel_out_3 = 5'b01000;
      hiif.RegWrite_out_4 = 0;
      hiif.wsel_out_4 = 0;
      hiif.dWEN_out_2 = 0; // forwardB will be 2'b10

      // NO.3
      hiif.rt_out_2 = 5'b01000;
      hiif.rs_out_2 = 5'b00100;    
      hiif.RegWrite_out_3 = 0;
      hiif.wsel_out_3 = 5'b00100;
      hiif.RegWrite_out_4 = 1;
      hiif.wsel_out_4 = 5'b00100;
      hiif.dWEN_out_2 = 0; // forwardA will be 2'b01

      // NO.4
      hiif.rt_out_2 = 5'b01000;
      hiif.rs_out_2 = 5'b00100;    
      hiif.RegWrite_out_3 = 0;
      hiif.wsel_out_3 = 5'b00100;
      hiif.RegWrite_out_4 = 5'b01000;
      hiif.wsel_out_4 = 1;
      hiif.dWEN_out_2 = 0; // forwardB will be 2'b01

      // NO.5
      hiif.rt_out_2 = 5'b01000;
      hiif.rs_out_2 = 5'b00100;    
      hiif.RegWrite_out_3 = 1;
      hiif.wsel_out_3 = 5'b01000;
      hiif.RegWrite_out_4 = 0;
      hiif.wsel_out_4 = 0;
      hiif.dWEN_out_2 = 1; // forwardC will be 1

      // NO.6
      hiif.rt_out_2 = 5'b01000;
      hiif.rs_out_2 = 5'b00100;    
      hiif.RegWrite_out_3 = 1;
      hiif.wsel_out_3 = 5'b01010;
      hiif.RegWrite_out_4 = 1;
      hiif.wsel_out_4 = 5'b10101;
      hiif.dWEN_out_2 = 1; // every thing will be 0




   end
   


endprogram // test
   
