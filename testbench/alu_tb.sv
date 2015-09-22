/*
 Zhaoyang Han
 han221@purdue.edu
 
 alu test bench
 */

`include "alu_if.vh"
`include "cpu_types_pkg.vh"
`timescale 1 ns / 1 ns

module alu_tb;
  
   // interface
   alu_if aluif ();

   // test program
   test X (aluif);

   //DUT
`ifndef MAPPED
   alu DUT(aluif);
`else
   alu DUT(
	   .\aluif.porta (aluif.porta),
	   .\aluif.portb (aluif.portb),
	   .\aluif.ALUOP (aluif.ALUOP),
	   .\aluif.negative (aluif.negative),
	   .\aluif.zero (aluif.zero),
	   .\aluif.overflow (aluif.overflow),
	   .\aluif.out (aluif.out)
	   );
`endif // !`ifndef MAPPED



   
endmodule // alu_tb

program test(
	    	     alu_if.alutb alutb
	     );
   import cpu_types_pkg::*;
   // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;
   initial begin
      //test each operation
      //test alu sll
      alutb.porta = v1;
      alutb.portb = 3;
      alutb.ALUOP = ALU_SLL;
      #(1ns);
      if(alutb.zero == 1)
	$display("Test 1 zero set wrong");

      if(alutb.overflow == 1)
	$display("Test 1 overflow set wrong");

      if(alutb.negative == 1)
	$display("Test 1 negative set wrong");
      
      #(5ns);
      //test alu srl
      alutb.porta = 32'h00000400;
      alutb.portb = 4;
      alutb.ALUOP = ALU_SRL;
      #(1ns);
      if(alutb.zero == 1)
	$display("Test 2 zero set wrong");

      if(alutb.overflow == 1)
	$display("Test 2 overflow set wrong");

      if(alutb.negative == 1)
	$display("Test 2 negative set wrong");
      
      #(5ns);
      //test alu add
      alutb.porta = 2;
      alutb.portb = 3;
      alutb.ALUOP = ALU_ADD;
      #(1ns);
      
      if(alutb.out != 5)
	$display("Test 3 output wrong");
      
      if(alutb.zero == 1)
	$display("Test 3 zero set wrong");

      if(alutb.negative == 1)
	$display("Test 3 negative set wrong, negative is %d", alutb.negative);

      // test add negative
      #(5ns);
      
      alutb.porta = -5;
      alutb.portb = 3;
      alutb.ALUOP = ALU_ADD;
      #(1ns);
      if(alutb.out != -2)
	$display("Test 4 output wrong");
      
      if(alutb.zero == 1)
	$display("Test 4 zero set wrong");

      
      if(alutb.negative == 0)
	$display("Test 4 negative set wrong");

      // test add overflow
      #(5ns);
      alutb.porta = 32'h80000000;
      alutb.portb = 32'h80000000;
      alutb.ALUOP = ALU_ADD;
      #(1ns);
      if(alutb.overflow == 0)
	$display("Test 5 overflow set wrong");

      // test sub pos, neg
      #(5ns);
      
      alutb.porta = 15;
      alutb.portb = -5;
      alutb.ALUOP = ALU_SUB;
      #(1ns);
      if(alutb.out != 20)
	$display("Test 6 output wrong");

      if(alutb.negative != 0)
	$display("Test 6 negative wrong");

      if(alutb.zero == 1)
	$display("Test 6 zero wrong");
      
      // test sub neg, pos
      #(5ns);
      alutb.porta = -3;
      alutb.portb = 20;
      alutb.ALUOP = ALU_SUB;
      #(1ns);
      if(alutb.out != -23)
	$display("Test 7 output wrong");

      if(alutb.negative != 1)
	$display("Test 7 negative wrong");

      if(alutb.zero != 0)
	$display("Test 7 zero wrong");
      // test sub zero
      #(5ns);
      alutb.porta = 5;
      alutb.portb = 5;
      alutb.ALUOP = ALU_SUB;
      #(1ns);
      if(alutb.out != 0)
	$display("Test 8 output wrong");

      if(alutb.negative != 0)
	$display("Test 8 negative wrong");

      if(alutb.zero != 1)
	$display("Test 8 zero wrong");


      // test sub overflow

      // test and
      #(5ns);
      
      alutb.porta = 32'h55555555;
      alutb.portb = 32'h11111111;
      alutb.ALUOP = ALU_AND;
      #(1ns);
      if(alutb.out != (alutb.porta & alutb.portb))
	$display("Test 9 output wrong");

      // test or
      #(5ns);
      
      alutb.porta = 32'h55555555;
      alutb.portb = 32'h11111111;
      alutb.ALUOP = ALU_OR;
      #(1ns);
      if(alutb.out != (alutb.porta | alutb.portb))
	$display("Test 10 output wrong");

      // test XOR
      #(5ns);
      alutb.porta = 32'h00000000;
      alutb.portb = 32'hFFFFFFFF;
      alutb.ALUOP = ALU_XOR;
      #(1ns);
      if(alutb.out != (alutb.porta ^ alutb.portb))
	$display("Test 11 output wrong");


      // test NOR
      #(5ns);
      alutb.porta = 32'h55555555;
      alutb.portb = 32'h11111111;
      alutb.ALUOP = ALU_NOR;
      #(1ns);
      if(alutb.out != (~(alutb.porta | alutb.portb)))
	$display("Test 12 output wrong");

      // test SLT
      #(5ns);
      alutb.porta = -5;
      alutb.portb = 0;
      alutb.ALUOP = ALU_SLT;
      #(1ns);
      if(alutb.out != 1)
	$display("Test 13 output wrong");

      // test SLTU
      #(5ns);
      alutb.porta = 30;
      alutb.portb = 5;
      alutb.ALUOP = ALU_SLTU;
      #(1ns);
      if(alutb.out != 0)
	$display("Test 14 output wrong");
      
   end // initial begin
endprogram // test
   
      
